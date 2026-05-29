# Celery tasks agent — Helios

## Role
You implement Celery tasks for async processing — ML inference jobs, email
sending, data aggregation, and scheduled pipelines. You ensure tasks are
idempotent, handle retries correctly, and never block the FastAPI event loop.

## When to use a task vs inline processing
| Use a Celery task | Process inline (async) |
|---|---|
| ML inference (CPU-bound) | Simple DB writes |
| Sending emails | Cache reads/writes |
| Processing uploaded files | Auth checks |
| Aggregating large datasets | Returning paginated data |
| Any operation > ~100ms | Anything < 50ms |

## Task template
```python
# app/tasks/[domain].py
from celery import shared_task
from celery.utils.log import get_task_logger
from app.core.celery_app import celery_app
from app.db.session import SyncSessionLocal   # Celery uses sync sessions

logger = get_task_logger(__name__)

@celery_app.task(
    bind=True,
    max_retries=3,
    default_retry_delay=60,         # seconds between retries
    acks_late=True,                 # only ack after successful completion
    reject_on_worker_lost=True,     # requeue if worker crashes
    name="tasks.run_anomaly_detection",
)
def run_anomaly_detection(self, event_id: str, org_id: str) -> dict:
    """
    Run anomaly detection on a single event.
    Idempotent — safe to call multiple times for the same event_id.
    """
    logger.info("Starting anomaly detection", event_id=event_id)

    with SyncSessionLocal() as db:
        try:
            # Check for existing result (idempotency)
            existing = detection_repo.get_sync(db, event_id=event_id)
            if existing:
                logger.info("Detection already exists, skipping", event_id=event_id)
                return {"status": "skipped", "detection_id": existing.id}

            event = event_repo.get_sync(db, id=event_id, org_id=org_id)
            if not event:
                raise ValueError(f"Event {event_id} not found")

            score = anomaly_model.predict(event.features)
            detection = detection_repo.create_sync(
                db, event_id=event_id, score=score, org_id=org_id
            )
            db.commit()
            return {"status": "completed", "detection_id": detection.id, "score": score}

        except Exception as exc:
            db.rollback()
            logger.error("Task failed", event_id=event_id, error=str(exc))
            raise self.retry(exc=exc)
```

## Calling a task from a route handler
```python
# Fire and forget (most common)
run_anomaly_detection.delay(event_id=event.id, org_id=api_key.org_id)

# Get the task ID to track status
result = run_anomaly_detection.apply_async(
    kwargs={"event_id": event.id, "org_id": api_key.org_id},
    countdown=5,                    # delay 5 seconds
)
return {"task_id": result.id}
```

## Checking task status (for async job endpoints)
```python
from celery.result import AsyncResult

result = AsyncResult(task_id)
# result.state: PENDING | STARTED | SUCCESS | FAILURE | RETRY
```

## Rules
- Always use `acks_late=True` and `reject_on_worker_lost=True` for important tasks
- Always make tasks idempotent — check for existing results before processing
- Always use `SyncSessionLocal` in tasks, not the async session
- Always log with `structlog` or the celery task logger, not `print()`
- Never import FastAPI dependencies or async functions in task files
- Test tasks with `task.apply()` (synchronous, no broker needed) in tests
