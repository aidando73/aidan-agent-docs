---
name: debug
description: Structured debug protocol for investigating hard-to-diagnose issues. Maintains a debug log to prevent re-trying failed approaches and preserve institutional knowledge. Use when the user says "debug", is investigating a bug, hang, performance regression, or any issue that isn't immediately obvious.
---

# Debug Protocol

When working on a hard-to-diagnose issue, **maintain a debug log** in the project's working doc (e.g., `progress.md`, `debug.md`, or a task-specific doc). The purpose is to prevent future agents from re-trying failed approaches and to preserve institutional knowledge.

## Repeated `/debug` commands

When the user sends `/debug` again (or says "debug" again), it means: **try the next thing** from the "What to try next" list. Read `progress.md`, pick the highest-priority untried item, execute it, and document the result.

## The Protocol

### 1. Document the bug

Before diving in, write down the bug in `progress.md`:
- **What's happening** — exact error messages, symptoms, conditions under which it occurs
- **Command to reproduce** — the exact command or steps to trigger the bug
- **Useful links** — logs, dashboards, related PRs, docs, stack traces

### 2. Check existing debug logs

Search the project's working docs (`progress.md`, `debug.md`, etc.) for keywords related to your issue. Someone may have already tried what you're about to try.

### 3. Document as you go

For each attempt, record:

```
### Attempt N: <short description>

**Hypothesis:** Why you think this might work.
**What you did:** Exact commands, code changes, config changes.
**Result:** What happened. Include exact error messages, timings, or output.
**Conclusion:** What this tells us. Why it worked/failed. What it rules out.
```

### 4. Maintain the "What to try next" list

After each attempt, update the "What to try next" section. Add new ideas that emerged, remove or check off things you've tried, and re-prioritize based on what you learned.

### 5. Build minimal repros

Strip away as much as possible and see if the issue still reproduces. Remove unrelated code, simplify inputs, reduce problem size. If it stops reproducing, the last thing you removed is likely involved.

### 6. Summarize key differences

When comparing a working case vs a broken case (e.g., a minimal repro that works vs the real code that hangs), maintain a table of **key differences**. This is often the fastest path to root cause — systematically eliminate differences until you find the one that matters.

## Template

Copy this template when starting a new investigation:

```markdown
### <Issue Title>

**Status:** Open / Resolved / Won't Fix
**Symptom:** <What goes wrong — exact error messages, behavior>
**Environment:** <GPU, driver, CUDA, relevant tool versions>
**Related files:** <Kernel files, repros, profiles>

---

#### Attempt N: <short description>

**Hypothesis:** <Why you think this might work>
**What you did:** <Exact commands, code changes>
**Result:** <What happened — exact output>
**Conclusion:** <What this tells us>

---

#### Key Differences: <Working Case> vs <Broken Case>

(table)

---

#### What to Try Next

1. ...
2. ...
```
