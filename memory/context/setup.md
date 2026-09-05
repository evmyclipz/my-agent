# Setup & Tools Context

## Default Inbox
Outlook (when not specified by the user) — see `priorities.md` for the `OUTLOOK_ACCOUNT` constant.

## MCPs / Connections — Status (2026-09-04)
| Tool | Status |
|------|--------|
| Gmail | Connected (`mcp__gmail__*` / `mcp__claude_ai_Gmail__*`) |
| Outlook | Not possible via MCP — school tenant blocks the Microsoft 365 connector. Read via `osascript` against Outlook.app in Legacy mode instead (`skills/email-read/SKILL.md`, `skills/daily-triage/SKILL.md`). Working. |
| Discord | Not connected — needs reconnect. `skills/discord-message/SKILL.md` is still a stub; `agent.md` Hard Rule 4 (never send autonomously) already covers it for whenever it's live. |
| Notion | Connected via the claude.ai Notion connector — Homework Tracker, project pages. |
| Todoist | Connected 2026-08-11 — default for triage-driven tasks. |
| Google Drive | Connected — used by `skills/coursework-sync/SKILL.md` for the CSSE416 calendar sheet. |

## Pending Setup Tasks
1. Reconnect Discord MCP.

## Schedule
- User works evenings (8–9pm) — morning is work, after work is gym, then dinner.
