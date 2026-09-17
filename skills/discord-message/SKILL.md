---
name: discord-message
description: Use when reading, searching, or drafting a Discord DM or channel message. Discord MCP is NOT CONNECTED YET — this skill is currently a stub.
---

# Skill: discord-message

Read and draft Discord messages. Discord MCP is **NOT CONNECTED YET** — this skill is a stub.

---

## Trigger

Use this skill when the user asks to:
- Check or read a Discord DM or channel message
- Draft a reply or new message in Discord
- Search Discord message history

---

## Pre-flight Checks

Before executing any Discord operation:

1. **Confirm Discord MCP is connected.** If not, stop and say: _"The Discord MCP is not connected yet."_
2. **Confirm the target.** Which server/channel or DM? If not specified, ask.

---

## Operations

### Read messages

**Discord** (`PLACEHOLDER — Discord MCP not connected`)
```
# PLACEHOLDER: replace with actual Discord MCP call when connected
# Expected operation: fetch recent messages from a channel or DM
# Parameters: channelId or userId, limit (count)
# Returns: list of {id, author, content, timestamp}
```

---

### Draft and send a message

**Hard rule: never send autonomously.** Always produce draft in chat first.

**Discord** (`PLACEHOLDER — Discord MCP not connected`)
```
# PLACEHOLDER: replace with actual Discord MCP call when connected
# Expected operation: send a message to a channel or DM
# Parameters: channelId or userId, content (string)
# Pre-send: show full draft to user and wait for explicit "send it" confirmation
```

---

## Output Format

For reading messages:
```
[Discord — #channel | DM: username]
[n messages]

1. [author] | [timestamp]
   [content]

2. ...
```

For a draft:
```
Draft — Discord DM to [username] / #[channel]:
---
[message content]
---
Send this? (yes / edit / cancel)
```

---

## Hard Constraints

- Never send a Discord message without explicit per-message user confirmation.
- Never batch-send multiple messages in one operation.
- If message content could affect external parties (e.g., a project collaborator), flag before confirming send.
- Read-only operations do not require confirmation, but must still state the channel/DM being read.
