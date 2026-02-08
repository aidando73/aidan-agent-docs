---
name: debug-protocol
description: Structured debug protocol for investigating hard-to-diagnose issues. Maintains a debug log to prevent re-trying failed approaches and preserve institutional knowledge. Use when the user says "debug", is investigating a bug, hang, performance regression, or any issue that isn't immediately obvious.
---

# Debug Protocol

When working on a hard-to-diagnose issue, **maintain a debug log** in the project's working doc (e.g., `progress.md`, `debug.md`, or a task-specific doc). The purpose is to prevent future agents from re-trying failed approaches and to preserve institutional knowledge.

## The Protocol

### 1. Before you start: Check existing debug logs

Search the project's working docs (`progress.md`, `debug.md`, etc.) for keywords related to your issue. Someone may have already tried what you're about to try.

### 2. Document as you go

For each attempt, record:

```
### Attempt N: <short description>

**Hypothesis:** Why you think this might work.
**What you did:** Exact commands, code changes, config changes.
**Result:** What happened. Include exact error messages, timings, or output.
**Conclusion:** What this tells us. Why it worked/failed. What it rules out.
```

### 3. Maintain the "What to try next" list

After each attempt, update the "What to try next" section. Add new ideas that emerged, remove or check off things you've tried, and re-prioritize based on what you learned.

### 4. Build minimal repros

Strip away as much as possible and see if the issue still reproduces. Remove unrelated code, simplify inputs, reduce problem size. If it stops reproducing, the last thing you removed is likely involved.

### 5. Summarize key differences

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
