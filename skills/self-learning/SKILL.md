---
name: self-learning
description: Use at session start when lessons-learned.md's Last self-review marker is >=7 days old, or when the user asks — mines recent mistakes and proposes lessons-learned entries and persona/skill fixes for confirmation. Propose-only, never self-applies.
---

# Self-Learning Review

A weekly reflection so JZ improves from past mistakes instead of repeating them. Builds on the `lessons-learned.md` propose→confirm flow; it does not bypass it.

## When
- Session start, if the `**Last self-review:**` marker in `lessons-learned.md` is `none yet` or ≥ 7 days ago.
- Or on explicit user request.

## Procedure
1. Gather mistake signals:
   - Recent memory entries (`~/.claude/projects/-Users-mrohan-Documents-my-agent/memory/`).
   - Corrections the user gave in recent sessions.
   - Dispatch outcomes: denied-tool hits, failed/aborted runs, diffs the user rejected.
   - Existing `lessons-learned.md` entries (to spot repeats).
2. Identify recurring patterns worth a behavioral correction.
3. For each, draft a `lessons-learned.md` entry in the file's existing format with `Status: Proposed`.
4. Where a lesson is really a process fix, also draft a specific diff to `CLAUDE.md`, `agent.md`, or a skill.
5. Present all proposals to the user and wait. Never silently write `lessons-learned.md`; never self-apply a lesson.
6. After presenting — whether or not anything was proposed — update the `**Last self-review:**` marker in `lessons-learned.md` to today's date.

## Guard
This skill proposes. It never edits persona/skills or dispatches agents on its own — it is a reflection step, not an action step.
