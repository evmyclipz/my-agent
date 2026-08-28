---
name: act-on-triage
description: Use immediately after skills/daily-triage/SKILL.md produces its digest, for any message that asks a direct question, explicitly mentions the user, or is classified P0 (due / needs immediate attention).
---

# Act on Triage

## Overview

Bounded, reversible actions layered on top of a completed triage digest: drafting replies, creating local reminders/calendar entries for deadlines, and **proposing coursework updates to the Notion Homework Tracker**. Never sends anything, and never touches Gmail/Outlook mutation state — mark-read/archive/junk/delete all live in `skills/daily-triage/SKILL.md`, gated by its own batch-approval step, not here.

Per `agent.md` → Operating Mode (2026-08-28), Homework Tracker writes are **autonomous and reported**: apply the add/update, then list what changed in the digest (course · title · type · due date · new vs. update). The user corrects anything wrong. No pre-approval step.

## When to Use / When Not To

- Fires per-message as part of the same run that produced the `daily-triage` digest — not standalone, not a separate trigger.
- Does not fire for messages already classified skip/junk in that digest.

## Quick Reference

| Condition | Action | Mechanism |
|---|---|---|
| Direct question / explicit mention of the user | Draft a reply | `skills/email-draft/SKILL.md` conventions, shown in chat |
| P0 tier (due / needs immediate attention) | Create task in Todoist | `mcp__claude_ai_Todoist__add-tasks`, project chosen by content (school → Education 📚, personal → Personal 🙂) |
| A previously-flagged P0 item is resolved or the user confirms it's handled | Complete/delete the task | `mcp__claude_ai_Todoist__complete-tasks` / `delete-object`, matched via a stable key in the task description |
| Email/Moodle announces or changes a **coursework** item (assignment, exam, reading, quiz, lab, project, or a due-date change) for a tracked course | Add/update a Homework Tracker row, then report it | Per `~/.claude/skills/homework-tracker/SKILL.md`; autonomous + listed in the digest |

## Implementation

**Auto-draft** — reuse `skills/email-draft/SKILL.md` verbatim: same output format, same tone-precedence rules, same "never send" constraint. The drafted reply appears directly under its digest line, not as a separate wall of text.

**Task creation** (`mcp__claude_ai_Todoist__add-tasks`, connected 2026-08-11 — this is now the default target, superseding the old Reminders.app/osascript approach):
```
projectId: Education 📚 (6JfVW2mGC2642g3j) for school items, Personal 🙂 (6JfVW2pm9Cm87FMM) otherwise
content: "<subject>"
description: "<stable key> | <context, e.g. source email deadline vs. inferred date>"
dueString: natural language date (reminder lead time, not necessarily the hard deadline)
priority: p1 for P0-tier source items, p2/p3 otherwise
```
Note: `deadlineDate` (Todoist's separate hard-deadline field) is Premium-only and fails on this account's Free plan — fold any hard due date into the task content/description instead of relying on that field.

Embed a stable key (Gmail message ID, or Outlook subject + received-time) in the task description so later runs can find it again.

**Reconciliation, every run**: `mcp__claude_ai_Todoist__find-tasks` in the relevant project(s), matched by stored key. If the source item is gone from the inbox or the user says it's handled, complete it via `complete-tasks` (or `delete-object` if it was created in error). Never leave orphaned tasks behind.

**Fallback**: if Todoist is unreachable, fall back to `osascript` → Reminders.app (`list "JZ Tasks"`) using the same stable-key convention, and flag to the user that it landed in Reminders instead of Todoist.

**Homework Tracker (Notion) — autonomous, reported.** For any message that announces or changes a coursework item for a tracked course (prof email, Moodle notification, TA email), follow `~/.claude/skills/homework-tracker/SKILL.md`: identify the course, reconcile against the Assignments & Exams database by `Source` key (`outlook:<messageId>` / `gmail:<messageId>` / `moodle:<id>`), then **write** the add or update. List every Homework Tracker change in the digest summary (course · title · type · due date · new vs. update) so the user can correct it. A P0 coursework item gets *both* a Todoist reminder (lead-time nudging) and a Homework Tracker row (the durable record) — not redundant.

Recurring club/team/committee **meetings** are not coursework: they belong in `class_schedule_fall_2026_27` memory + Google Calendar, not the Homework Tracker. A meeting that carries a graded deliverable → propose a Homework Tracker row for the deliverable only.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Creating a reminder without a stable key in its body/notes | Future runs can't find it to reconcile/delete — always embed the key at creation time. |
| Drafting a reply for a CC'd thread with no direct question | Only draft when the user is the addressee or explicitly asked something — CC-only mentions don't qualify. |
| Writing a Homework Tracker row silently | Autonomous is fine, but every add/update must be listed in the digest so the user can catch a wrong course/date. |
| Adding a club/team meeting to the Homework Tracker | Meetings → schedule memory + Calendar. Only graded deliverables go in the tracker. |

## Hard Constraints

- Never send a drafted reply — chat presentation only, per `skills/email-draft/SKILL.md`.
- Never touch Gmail/Outlook message state. Mark-read/archive/junk/delete belong to `skills/daily-triage/SKILL.md`, not this skill.
- Reminders/Calendar and Notion Homework Tracker writes are autonomous (agent.md → Operating Mode) — scoped to items this skill created or that clearly belong to the user's workspace, keyed for reconciliation, and always listed in the digest.
- Still never without a "yes": sending a reply, trashing/deleting email in bulk. Drafts and archive/label are fine.
