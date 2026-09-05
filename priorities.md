# Priorities

## Email Urgency Tiers

JZ uses these tiers to classify incoming email. Fill in the criteria and examples for each tier.

---

### P0 — Respond within hours

**Criteria:**
Any email with a hard deadline where missing the window has real consequences. Payments of any kind (owed or incoming), offer letter signing, insurance, medical bills, or any financial action item.

**Examples of senders or subjects that always land here:**
- Subject contains: "payment due", "invoice", "offer letter", "sign by", "deadline", "action required"
- Geico insurance, hospital/medical billing, any payment processor
- Internship or job offer logistics with a response deadline

---

### P1 — Respond within 24 hours

**Criteria:**
Family. Close friends with something real to discuss (not casual chat). Work and internship coordination. Emails from professors (not general university/department blasts).

**Examples:**
- Parents (kkmallipeddi@gmail.com, kmaliped@qti.qualcomm.com, krmini2005@gmail.com)
- Internship coordinator / employer logistics
- A professor's direct email — not a mass course announcement
- Bank transaction confirmations
- **Job application status updates** — any email reporting status on a job already applied to: "your application", "next steps", "interview", "assessment invite", rejection language — regardless of sender. This lands here even from a job-board platform (Handshake, Indeed, etc.) if it's a status update rather than a generic listing.

---

### P2 — Respond within a few days

**Criteria:**
Casual messages from friends or peers that need a reply but have no urgency. Social coordination, catching up, low-stakes questions.

**Examples:**
- Casual email from Ankit or Ansh with no hard question
- Peer group chats or threads where a reply is expected but not urgent

---

### P3 — No response required / FYI / Archive candidate

**Criteria:**
Purely informational — no reply expected. Receipts, confirmations, FYI forwards, announcements, mass course emails.

**Examples:**
- Order confirmations, shipping notifications
- University department announcements
- Mass emails from professors to the whole class

---

### Automatic Skip (never surface these)

**Criteria:**
Newsletters, marketing emails, promotional offers, mailing lists. Automated system notifications (GitHub alerts, app pings, login alerts).
- **Job-board blasts** — generic "X is hiring", "new jobs matching your profile", "jobs for you" style subjects from Handshake/Indeed/iHireTechnology/LinkedIn etc. (Contrast with job *status* updates, which are P1 — see above.)
- **Protected newsletters, never recommend junking**: TLDR, Seeking Alpha — the only two newsletters worth keeping.
- **Filtered at the source, won't appear in triage at all**: Macro Mornings, MaxDividends, all Substack mail (`no-reply@substack.com`), Google Alerts — see `Next Session Tasks` for filter status.

---

## Default Inbox

When a request doesn't specify Gmail or Outlook, JZ should default to:

```
DEFAULT_INBOX=Outlook
OUTLOOK_ACCOUNT=maliper@rose-hulman.edu
```

---

## Project Priority Order

List active projects in the order JZ should surface them in digests and status checks. Add entries using the project slugs from `projects.md`.

```

```

---

## Notes

<!-- Any other routing rules, exceptions, or edge cases -->

---

## Next Session Tasks

1. ~~Connect Gmail MCP~~ — Connected 2026-08-11 via `claude.ai Gmail` connector, tools under `mcp__claude_ai_Gmail__*`.
2. ~~Connect Outlook MCP~~ — superseded. Microsoft 365 MCP requires tenant admin access we don't have (school account); Outlook is read directly via `osascript` against Microsoft Outlook.app in Legacy mode instead (see `skills/daily-triage/SKILL.md`, `skills/email-read/SKILL.md`).
3. Connect Discord MCP — `v-3/discordmcp` (simple read/send). Still the only open item here.
4. ~~Update `agent.md` — add Discord draft+confirm hard rule~~ — done, Hard Rule 4.
5. ~~Add `skills/discord-message/SKILL.md` stub~~ — done, exists as a stub awaiting the MCP.
6. ~~Connect Todoist~~ — Connected 2026-08-11 via `claude.ai Todoist` connector, now the default target for `act-on-triage` tasks.
