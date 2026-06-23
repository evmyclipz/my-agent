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

---

## Default Inbox

When a request doesn't specify Gmail or Outlook, JZ should default to:

```
DEFAULT_INBOX=Outlook
```

---

## Project Priority Order

List active projects in the order JZ should surface them in digests and status checks. Add entries using the project slugs from `projects.md`.

```
1. spy-strat
2. moto-mod
3. hyper-agent
4. shopping
5. summer-travel
6. minecraft-calc
```

---

## Notes

<!-- Any other routing rules, exceptions, or edge cases -->

---

## Next Session Tasks

1. Connect Gmail MCP — Google official remote MCP (Pro plan): `gmailmcp.googleapis.com`
2. Connect Outlook MCP — Anthropic official Microsoft 365 Connector
3. Connect Discord MCP — `v-3/discordmcp` (simple read/send)
4. Update `agent.md` — add Discord draft+confirm hard rule (no autonomous sends)
5. Add `skills/discord-message/SKILL.md` stub
