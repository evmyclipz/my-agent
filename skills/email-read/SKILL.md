# Skill: email-read

Read and search email across inboxes. Provider-agnostic interface — Gmail and Outlook calls are marked `PLACEHOLDER` until their MCPs are connected.

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
2. **Check MCP availability.** If the required MCP is not connected, stop immediately and say: _"The [Gmail/Outlook] MCP is not connected yet. I can't read from that inbox until it is set up."_

---

## Operations

### List / fetch recent emails

**Gmail** (`PLACEHOLDER — Gmail MCP not connected`)
```
# PLACEHOLDER: replace with actual Gmail MCP call when connected
# Expected operation: list messages in inbox, with optional query/filter
# Parameters: maxResults, query (Gmail search syntax), labelIds
# Returns: list of {id, threadId, snippet, from, subject, date}
```

**Outlook** (`PLACEHOLDER — Outlook MCP not connected`)
```
# PLACEHOLDER: replace with actual Outlook MCP call when connected
# Expected operation: list messages in inbox/folder, with optional filter
# Parameters: top (count), filter (OData), select (fields)
# Returns: list of {id, conversationId, bodyPreview, from, subject, receivedDateTime}
```

---

### Search emails

**Gmail** (`PLACEHOLDER — Gmail MCP not connected`)
```
# PLACEHOLDER: replace with actual Gmail MCP call when connected
# Uses Gmail search syntax: from:, to:, subject:, before:, after:, is:unread, etc.
# Parameters: query (string), maxResults
# Returns: matching messages
```

**Outlook** (`PLACEHOLDER — Outlook MCP not connected`)
```
# PLACEHOLDER: replace with actual Outlook MCP call when connected
# Uses OData $filter or $search
# Parameters: search (string) or filter (OData expression), top
# Returns: matching messages
```

---

### Read a specific email / thread

**Gmail** (`PLACEHOLDER — Gmail MCP not connected`)
```
# PLACEHOLDER: replace with actual Gmail MCP call when connected
# Parameters: messageId or threadId
# Returns: full message body (text/plain preferred), headers, attachments list
```

**Outlook** (`PLACEHOLDER — Outlook MCP not connected`)
```
# PLACEHOLDER: replace with actual Outlook MCP call when connected
# Parameters: messageId or conversationId
# Returns: body (text/plain preferred), from, to, cc, subject, receivedDateTime
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
