---
name: email-read
description: Use when reading, searching, or opening email across Gmail and Outlook inboxes outside of the daily-triage flow.
---

# Skill: email-read

Read and search email across inboxes. Gmail is connected via `@gongrzhe/server-gmail-autoauth-mcp` (community MCP, credentials at `~/.gmail-mcp/credentials.json`). Outlook is read via `osascript` against Microsoft Outlook.app (Legacy mode) — no MCP involved; the account address is `OUTLOOK_ACCOUNT` in `priorities.md`.

---

## Trigger

Use this skill when the user asks to:
- Check, read, or open a specific email
- Search for emails matching criteria (sender, subject, date range, keyword)
- List recent emails or unread emails
- Get a summary of an email thread

---

## Pre-flight Checks

Before executing any read operation:

1. **Confirm the inbox.** If the user's request does not specify Gmail or Outlook, check `priorities.md` for a configured default. If no default is set, ask: _"Which inbox — Gmail or Outlook?"_
2. **Check access.** Gmail MCP is connected. Outlook is read via `osascript` — before treating a result as "0 messages", confirm `exchange accounts` returns non-empty (see Common Mistakes-style guard in `skills/daily-triage/SKILL.md`); if empty, Outlook has likely reverted to New Outlook mode and needs Help > Revert to Legacy Outlook again. Say so explicitly rather than reporting an empty inbox.

---

## Operations

### List / fetch recent emails

**Gmail** (connected via `mcp__gmail__search_emails`)
```
# Tool: mcp__gmail__search_emails
# Parameters: query (Gmail search syntax string), maxResults (int)
# To list recent: query="in:inbox", maxResults=20
# Returns: list of {id, threadId, snippet, from, subject, date}
```

**Outlook** (`osascript` against Microsoft Outlook.app, Legacy mode)
```applescript
tell application "Microsoft Outlook"
    set acct to exchange account "<OUTLOOK_ACCOUNT>"
    set theInbox to mail folder "Inbox" of acct
    set msgs to messages of theInbox
    -- per message: subject as string, name of (sender of m) as string,
    -- time received of m as string, is read of m
end tell
```

---

### Search emails

**Gmail** (connected via `mcp__gmail__search_emails`)
```
# Tool: mcp__gmail__search_emails
# Uses Gmail search syntax: from:, to:, subject:, before:, after:, is:unread, etc.
# Parameters: query (string), maxResults (int)
# Returns: matching messages
```

**Outlook** (`osascript` against Microsoft Outlook.app, Legacy mode)
```applescript
tell application "Microsoft Outlook"
    set acct to exchange account "<OUTLOOK_ACCOUNT>"
    set theInbox to mail folder "Inbox" of acct
    -- fetch messages of theInbox, then filter in-script by subject/sender/date
    -- (AppleScript's "whose" filters work on some properties, e.g.:
    --  messages of theInbox whose subject contains "keyword")
end tell
```

---

### Read a specific email / thread

**Gmail** (connected via `mcp__gmail__read_email`)
```
# Tool: mcp__gmail__read_email
# Parameters: messageId (string)
# Returns: full message body (text/plain preferred), headers, attachments list
```

**Outlook** (`osascript` against Microsoft Outlook.app, Legacy mode)
```applescript
tell application "Microsoft Outlook"
    -- given a specific message reference m (e.g. from a prior list/search):
    -- content of m as string, subject of m as string, name of (sender of m) as string,
    -- time received of m as string
end tell
```

---

## Output Format

After fetching, present results to the user as:

```
[Inbox: Gmail | Outlook]
[n unread / n results]

1. From: [name <email>] | [date]
   Subject: [subject]
   Preview: [first ~100 chars of body]
   Urgency: [P0–P3 per priorities.md, or "?" if unclear]

2. ...
```

For a single opened email, show full context: from, to, cc, date, subject, body. Note attachments by name only (do not open or execute attachments).

---

## Hard Constraints

- Read-only. Do not attempt any state mutation (archive, label, delete, move, mark-read) in this skill.
- If urgency classification is ambiguous, mark as `?` and surface it to the user; do not guess.
- If an email relates to a tracked project in `projects.md`, note that explicitly in the output.
