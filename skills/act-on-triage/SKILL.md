---
name: act-on-triage
description: Use immediately after skills/daily-triage/SKILL.md produces its digest, for any message that asks a direct question, explicitly mentions the user, or is classified P0 (due / needs immediate attention).
---

# Act on Triage

## Overview

Two bounded, reversible actions layered on top of a completed triage digest: drafting replies, and creating local reminders/calendar entries for deadlines. Never sends anything, and never touches Gmail/Outlook mutation state — mark-read/archive/junk/delete all live in `skills/daily-triage/SKILL.md`, gated by its own batch-approval step, not here.

## When to Use / When Not To

- Fires per-message as part of the same run that produced the `daily-triage` digest — not standalone, not a separate trigger.
- Does not fire for messages already classified skip/junk in that digest.

## Quick Reference

| Condition | Action | Mechanism |
|---|---|---|
| Direct question / explicit mention of the user | Draft a reply | `skills/email-draft/SKILL.md` conventions, shown in chat |
| P0 tier (due / needs immediate attention) | Create task in Todoist | `mcp__claude_ai_Todoist__add-tasks`, project chosen by content (school → Education 📚, personal → Personal 🙂) |
| A previously-flagged P0 item is resolved or the user confirms it's handled | Complete/delete the task | `mcp__claude_ai_Todoist__complete-tasks` / `delete-object`, matched via a stable key in the task description |

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

## Common Mistakes

| Mistake | Fix |
|---|---|
| Creating a reminder without a stable key in its body/notes | Future runs can't find it to reconcile/delete — always embed the key at creation time. |
| Drafting a reply for a CC'd thread with no direct question | Only draft when the user is the addressee or explicitly asked something — CC-only mentions don't qualify. |

## Hard Constraints

- Never send a drafted reply — chat presentation only, per `skills/email-draft/SKILL.md`.
- Never touch Gmail/Outlook message state. Mark-read/archive/junk/delete belong to `skills/daily-triage/SKILL.md`, not this skill.
- Reminders/Calendar create-and-delete is the one autonomous action this skill takes (agent.md rule 8) — scoped only to items it created itself, identified by their stable key.
