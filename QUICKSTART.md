# Quick Start Guide

Get Claude Code fully configured in your project in under 5 minutes — no coding experience required.

---

## What this does

Running one command sets up a `.claude/` folder in your project that teaches Claude Code about your project. After setup, Claude will:

- Know your project's tech stack and conventions before it writes a single line
- Automatically check for errors after every file change
- Block dangerous commands before they run
- Respond to shortcuts like `/review`, `/commit`, and `/debug`

---

## Before you start

You need two things installed on your computer.

### 1. Node.js

Node.js is a tool that lets you run JavaScript programs.

**Check if you already have it:**

Open your Terminal (Mac) or Command Prompt (Windows) and type:

```
node --version
```

If you see a number like `v20.0.0` or higher, you are good. If you see an error, download and install Node.js from [nodejs.org](https://nodejs.org) — click the "LTS" button.

**How to open Terminal:**
- **Mac:** Press `Command + Space`, type `Terminal`, press Enter
- **Windows:** Press `Windows key`, type `cmd`, press Enter

---

### 2. Claude Code

Claude Code is the AI assistant you will be using.

**Install it by typing this in your Terminal:**

```
npm install -g @anthropic-ai/claude-code
```

Wait for it to finish (about 30 seconds), then check it worked:

```
claude --version
```

You should see a version number.

---

## Running the setup

### Step 1 — Open your Terminal and go to your project folder

Type `cd` followed by a space, then the path to your project folder. For example:

```
cd /Users/yourname/Documents/my-project
```

**Tip:** On a Mac you can drag your project folder from Finder into the Terminal window after typing `cd ` and it will fill in the path automatically.

If you do not have a project folder yet, create one:

```
mkdir my-project
cd my-project
```

---

### Step 2 — Download the setup script

Copy and paste this command into your Terminal, then press Enter:

```
curl -O https://raw.githubusercontent.com/mohit-parashar-ai/cc-boilerplate/main/bootstrap.sh
```

This downloads a file called `bootstrap.sh` into your project folder.

---

### Step 3 — Run the setup script

Type this command, replacing `my-project` with your actual project name:

```
bash bootstrap.sh my-project
```

The script will ask:

```
Bootstrap here? [y/N]
```

Type `y` and press Enter.

You will see a list of files being created. When it finishes you will see:

```
Bootstrap complete!
```

---

### Step 4 — Fill in your project details

Open the file called `CLAUDE.md` that was just created in your project folder. This is the most important file — it tells Claude everything about your project.

Look for every line that starts with `<!-- TODO` and replace the example text with your real information.

The sections to fill in:

| Section | What to write |
|---------|--------------|
| **What this is** | One or two sentences describing your project |
| **Current focus** | What you are working on right now |
| **Tech stack** | What programming languages and tools you use |
| **Key commands** | The commands you run to start, test, and build your project |

If you are not sure what to put, leave the example text for now — you can update it at any time.

---

### Step 5 — Start Claude Code

In your Terminal, while still in your project folder, type:

```
claude
```

Claude Code will open. It has already read your `CLAUDE.md` and knows your project.

**To verify it worked**, type this in Claude Code:

```
What is this project and what stack does it use?
```

Claude should answer using the information from your `CLAUDE.md`. If it does, everything is working correctly.

---

## What was created

After running the script, your project folder contains:

```
your-project/
├── CLAUDE.md                    ← Fill this in — Claude reads it every session
├── .env.example                 ← Template for secret keys and config values
├── Makefile                     ← Common commands (make dev, make test, etc.)
├── .gitignore                   ← Prevents secrets from being accidentally saved to git
│
└── .claude/
    ├── settings.json            ← Controls what Claude is allowed to do
    ├── hooks/                   ← Automatic actions (type-checking, logging, safety checks)
    ├── agents/                  ← Specialist modes (reviewer, tester, docs writer)
    ├── commands/                ← Shortcuts you can type (see below)
    └── skills/                  ← Step-by-step guides for complex tasks
```

---

## Shortcuts (slash commands)

Once Claude Code is open, you can type these shortcuts:

| Shortcut | What it does |
|----------|-------------|
| `/review` | Reviews your recent code changes and flags problems |
| `/commit` | Writes a proper commit message for your staged changes |
| `/test` | Generates tests for a file you specify |
| `/spec` | Writes a feature specification document |
| `/debug` | Helps diagnose and fix a bug systematically |
| `/migrate` | Walks through a safe database migration |

---

## After setup — checklist

- [ ] Fill in `CLAUDE.md` with your real project details
- [ ] Copy `.env.example` to `.env.local` and add your real secret values: `cp .env.example .env.local`
- [ ] Open `.claude/settings.json` and update the `allow` list if you use `yarn` or `npm` instead of `pnpm`

---

## Troubleshooting

### "command not found: bash"

You are on Windows without WSL. Either install WSL (Windows Subsystem for Linux) from the Microsoft Store, or use Git Bash which comes with Git for Windows.

### "command not found: curl"

On Windows, use this instead of the `curl` command:

```
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/mohit-parashar-ai/cc-boilerplate/main/bootstrap.sh" -OutFile "bootstrap.sh"
```

Then run the script with `bash bootstrap.sh my-project` inside Git Bash or WSL.

### "bad substitution" error

You ran the script with `sh` instead of `bash`. Use:

```
bash bootstrap.sh my-project
```

### Hooks not running

Check that the hook scripts are executable:

```
chmod +x .claude/hooks/*.sh
```

### Claude does not know about my project

Make sure you are running `claude` from inside your project folder (the same folder that contains `CLAUDE.md`). Use `cd your-project-folder` first, then run `claude`.

---

## Updating your setup

The `CLAUDE.md` file is a plain text file. Open it in any text editor and update it whenever your project changes — new tools, new conventions, new team members.

The more accurate and specific your `CLAUDE.md` is, the better Claude will perform.
