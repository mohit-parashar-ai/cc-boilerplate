# Feature spec: Async anomaly detection pipeline

> Status: In Progress
> Author: Mohit Parshar
> Created: 2025-05-22

## Overview
Move anomaly detection from a synchronous endpoint (blocks for 200–800ms) to an
async Celery task. The API returns a `task_id` immediately; clients poll a status
endpoint or receive a webhook when the result is ready.

## User stories
- As an API consumer, I want anomaly detection to return within 100ms so my
  pipeline doesn't time out.
- As an API consumer, I want to poll for the detection result using a task ID.
- As an API consumer, I want an optional webhook callback when detection completes.

## Acceptance criteria
- [ ] `POST /api/v1/events/{id}/detect` returns `202 Accepted` with `{"task_id": "..."}`
- [ ] Response time P99 < 100ms (down from ~600ms)
- [ ] `GET /api/v1/tasks/{task_id}` returns status: `pending | processing | completed | failed`
- [ ] Completed result includes `score`, `is_anomaly`, `completed_at`
- [ ] Failed result includes `error` message (no stack trace)
- [ ] Optional `callback_url` field on the detection request — POST result on completion
- [ ] Tasks retry up to 3 times with 60s backoff on failure
- [ ] Tasks are idempotent — re-submitting same event returns existing task

## Technical approach

### New Celery task
```
app/tasks/anomaly.py
  run_anomaly_detection(event_id, org_id, callback_url=None)
```

### Schema changes
```python
# New table: task_results
class TaskResult(Base):
    __tablename__ = "task_results"
    id: str               # = celery task_id
    org_id: str
    status: str           # pending | processing | completed | failed
    result: dict | None   # JSON — detection output
    error: str | None
    created_at: datetime
    completed_at: datetime | None
```

### API changes
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/events/{id}/detect` | Submit detection job, returns task_id |
| GET | `/api/v1/tasks/{task_id}` | Poll task status and result |

### Component changes
- `app/tasks/anomaly.py` — Celery task (new)
- `app/db/models/task_result.py` — TaskResult model (new)
- `app/db/repository/task_repo.py` — Repository (new)
- `app/api/v1/endpoints/detections.py` — Updated to fire task, return 202
- `app/api/v1/endpoints/tasks.py` — New polling endpoint

## Out of scope
- WebSocket push for real-time status (use polling for v1)
- Batch detection endpoint (separate spec)
- Task cancellation

## Open questions
- [ ] Webhook delivery: retry on failure? How many attempts? (leaning: 3 retries, exp backoff)
- [ ] Task result retention: how long to keep `task_results` rows? (leaning: 30 days)
