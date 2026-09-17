---
name: daily-triage
description: Use at session start, or when the user sends a bare greeting with no other request attached ("Hi", "Yo", "Hey", "Run startup", "What's up", "Good morning", etc.).
---

# Daily Triage

## Overview

A full sweep of Gmail and Outlook, classified against `priorities.md`'s urgency tiers and presented as one combined digest. It observes, classifies, marks scanned messages read, and — per `agent.md` → Operating Mode — **applies `keep`/`archive`/`label` recommendations autonomously**, then reports the list. `junk`/`delete` (Trash-level) still wait for one explicit batch "yes". Drafting replies and creating reminders/calendar/tracker entries are `skills/act-on-triage/SKILL.md`'s job, not this one's.

## When to Use / When Not To

- Fires on session start, or on a bare greeting with no substantive content attached ("Hi", "Yo", "Hey", "Run startup", "What's up", "Good morning").
- Does **not** fire when a greeting is bundled with an actual ask (e.g. "hey can you check on the Ansh thread") — handle that request directly instead.
- Runs every time it's triggered. No once-per-day gating — but scoped to **unread mail from today (calendar day) only** (see [[feedback_unread_only_triage]], [[feedback_triage_today_only]]). Older unread backlog is explicitly out of scope for this skill — it is not scanned, not surfaced, and not mark-read. A full inbox snapshot or a backlog sweep is opt-in only, on explicit request.

## Pre-flight

Load before scanning:
- `priorities.md` — urgency tiers (P0–P3) and the `OUTLOOK_ACCOUNT` constant
- `contacts.md` — sender routing / relationship context
- `projects.md` — for project-match annotations

## Quick Reference

| Inbox | Mechanism | Scope |
|---|---|---|
| Gmail | `search_threads`, `query="in:inbox is:unread after:<today>"` | unread, today only |
| Outlook | `osascript` against `exchange account <OUTLOOK_ACCOUNT>` → `mail folder "Inbox"`, filtered to unread + received today | unread, today only |

## Implementation

**Gmail** — one call, scoped to unread AND today's calendar date (not a rolling 24h window — use the actual date, not `newer_than:1d`):
```
# Tool: search_threads (or equivalent)
# Parameters: query="in:inbox is:unread after:YYYY/MM/DD", where YYYY/MM/DD is today's date
# Returns: list of {id, threadId, snippet, from, subject, date}
```
Do not run a bare `is:unread` scan — that pulls in the entire historical unread backlog (which may span months or years), not just today's mail. If `after:<today>` still returns nothing because Gmail's date boundary rolled differently than expected, that's fine — report zero for today rather than falling back to the full unread scan.

**Outlook** — via `osascript`, scoped through the exchange account (see Common Mistakes for why), filtered to unread AND received today. Iterate with an indexed `repeat ... item i of msgs` (not `repeat with m in msgs`) wrapped in `try`, since a bad record coercion on one message otherwise aborts the whole scan — see Common Mistakes:
```applescript
tell application "Microsoft Outlook"
    set acct to exchange account "<OUTLOOK_ACCOUNT>"
    set theInbox to mail folder "Inbox" of acct
    set todayStart to (current date) - (time of (current date))
    set msgs to messages of theInbox whose is read is false and time received ≥ todayStart
    -- per message, extract:
    --   subject of m as string
    --   name of (sender of m) as string
    --   time received of m as string
end tell
```
Note: this account's inbox carries a large legacy backlog (thousands of read messages, plus a large stale unread backlog) — the `is read is false and time received ≥ todayStart` filter keeps the scan bounded to what's actually new today.

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
`archive`/`label` recommendations are applied autonomously and the list is reported. Only `junk`/`delete` (Trash-level — see Hard Constraints, never permanent delete) waits for an explicit "yes"; "no"/partial/silence means those stay put. Don't itemize P2/P3/skip-tier messages by default — counts only, expand on request.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Querying bare `mail folder "Inbox"` at the application level | Returns 0 silently. Always scope through `exchange account "<addr>"` first. |
| Extracting `sender`/other record fields via `properties of` | AppleScript errors trying to coerce the whole record. Coerce the specific field with `as string` at the point of extraction instead (`name of (sender of m) as string`). |
| Treating an empty Outlook result as "no mail" | Could mean New Outlook mode silently came back. Check `exchange accounts` isn't empty before reporting zero. |
| Trashing an obvious-looking junk message without the batch "yes" | Archive is autonomous; `junk`/`delete` (Trash) still waits. Recommendation confidence ≠ approval to trash. |

## Hard Constraints

- Mark-read, archive, and label are autonomous — applied every run, then reported. No pre-approval.
- `junk`/`delete` are NOT auto-executed — always show the list and wait for one explicit batch "yes".
- "Junk"/"delete" execute as a move to Trash, never `mcp__gmail__delete_email` — that tool is permanently off-limits regardless of confirmation.
- No drafting, no sending — that's `skills/act-on-triage/SKILL.md`.
- If a pattern surfaces that looks `lessons-learned.md`-worthy, propose it through the existing propose→confirm flow. Never self-apply.
