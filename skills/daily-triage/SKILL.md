---
name: daily-triage
description: Use at session start, or when the user sends a bare greeting with no other request attached ("Hi", "Yo", "Hey", "Run startup", "What's up", "Good morning", etc.).
---

# Daily Triage

## Overview

A full sweep of Gmail and Outlook, classified against `priorities.md`'s urgency tiers and presented as one combined digest. It observes, classifies, and marks scanned messages read — then *proposes* an action (keep/archive/junk/delete) per message and waits for one explicit batch approval before executing any of it. Mark-read is the one autonomous mutation (agent.md rule 2's sole exception); everything beyond that always waits for the user's "yes." Drafting replies and creating reminders/calendar entries are `skills/act-on-triage/SKILL.md`'s job, not this one's.

## When to Use / When Not To

- Fires on session start, or on a bare greeting with no substantive content attached ("Hi", "Yo", "Hey", "Run startup", "What's up", "Good morning").
- Does **not** fire when a greeting is bundled with an actual ask (e.g. "hey can you check on the Ansh thread") — handle that request directly instead.
- Runs every time it's triggered. No once-per-day gating — but scoped to **unread mail only** (see [[feedback_unread_only_triage]]). A full inbox snapshot is opt-in only, on explicit request.

## Pre-flight

Load before scanning:
- `priorities.md` — urgency tiers (P0–P3) and the `OUTLOOK_ACCOUNT` constant
- `contacts.md` — sender routing / relationship context
- `projects.md` — for project-match annotations

## Quick Reference

| Inbox | Mechanism | Scope |
|---|---|---|
| Gmail | `mcp__gmail__search_emails`, `query="in:inbox"`, high `maxResults` | full snapshot |
| Outlook | `osascript` against `exchange account <OUTLOOK_ACCOUNT>` → `mail folder "Inbox"` | full snapshot |

## Implementation

**Gmail** — one call, scoped to unread:
```
# Tool: mcp__gmail__search_emails
# Parameters: query="in:inbox is:unread", maxResults=<high, e.g. 100>
# Returns: list of {id, threadId, snippet, from, subject, date}
```

**Outlook** — via `osascript`, scoped through the exchange account (see Common Mistakes for why), filtered to unread. Iterate with an indexed `repeat ... item i of msgs` (not `repeat with m in msgs`) wrapped in `try`, since a bad record coercion on one message otherwise aborts the whole scan — see Common Mistakes:
```applescript
tell application "Microsoft Outlook"
    set acct to exchange account "<OUTLOOK_ACCOUNT>"
    set theInbox to mail folder "Inbox" of acct
    set msgs to messages of theInbox whose is read is false
    -- per message, extract:
    --   subject of m as string
    --   name of (sender of m) as string
    --   time received of m as string
end tell
```
Note: this account's inbox carries a large legacy backlog (thousands of read messages) — the `whose is read is false` filter keeps the scan bounded to what's actually new.

**Pre-flight guard** — before treating an Outlook result as "0 messages," first confirm `exchange accounts` returns non-empty:
```applescript
tell application "Microsoft Outlook" to get name of every exchange account
```
If empty, Outlook has likely silently reverted to New Outlook mode. Surface this explicitly to the user ("Outlook appears to be back in New Outlook mode — re-run Help > Revert to Legacy Outlook") rather than reporting an empty inbox.

**Classification**: every message gets a tier (P0–P3) per `priorities.md`. Ambiguous cases are marked `?` and surfaced — never guessed (agent.md rule 4).

**Project matching**: note when a message relates to a tracked project in `projects.md`.

**Mark-read** (autonomous, every run, no confirmation — the one exception to agent.md rule 2):
```
# Gmail: mcp__gmail__batch_modify_emails, removeLabelIds=["UNREAD"], messageIds=<all scanned ids>
# Outlook: osascript — set is read of m to true, for each scanned message
```

**Recommend an action** per message — `keep` / `archive` / `junk` / `delete` — based on its tier and the hygiene rules in `priorities.md` (e.g. a sender matching a known junk-filter target recommends `junk`; P0/P1 recommends `keep`; P3/skip-tier recommends `archive` or `junk` by judgment).

**Output** — see [[feedback_digest_format]]: short, leads with what needs a response, everything else collapsed to counts:
```
🔴 Needs you (P0/P1)
- [Inbox] Sender — Subject → why it matters

🟡 Everything else
- N × P2, N × P3, N × junk/promo (say the word to expand any bucket)

Apply the junk/archive recommendations for [list]?
```
Only an explicit "yes" executes the batch (via Trash-level mutation — see Hard Constraints — never permanent delete). A "no," a partial edit, or silence means nothing beyond mark-read happens. Don't itemize P2/P3/skip-tier messages by default — counts only, expand on request.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Querying bare `mail folder "Inbox"` at the application level | Returns 0 silently. Always scope through `exchange account "<addr>"` first. |
| Extracting `sender`/other record fields via `properties of` | AppleScript errors trying to coerce the whole record. Coerce the specific field with `as string` at the point of extraction instead (`name of (sender of m) as string`). |
| Treating an empty Outlook result as "no mail" | Could mean New Outlook mode silently came back. Check `exchange accounts` isn't empty before reporting zero. |
| Treating an obvious-looking junk message as pre-approved | Still propose it and wait. Recommendation confidence is not the same as user approval, no matter how confident the classification. |

## Hard Constraints

- Mark-read is the only autonomous mutation — every scanned message, every run, no confirmation.
- Archive, junk, and delete are never auto-executed. Always propose, always wait for one explicit batch "yes" before touching anything beyond mark-read.
- "Junk"/"delete" recommendations execute as a move to Trash, never `mcp__gmail__delete_email` — that tool is permanently off-limits regardless of confirmation.
- No drafting, no sending — that's `skills/act-on-triage/SKILL.md`.
- If a pattern surfaces that looks `lessons-learned.md`-worthy, propose it through the existing propose→confirm flow. Never self-apply.
