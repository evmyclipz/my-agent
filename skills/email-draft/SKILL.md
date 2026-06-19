# Skill: email-draft

Compose and draft email. No MCP required — all output is shown in chat for user review. Nothing is sent or saved to any inbox without explicit user action.

---

## Trigger

Use this skill when the user asks to:
- Draft a new email
- Draft a reply to an email (user pastes or describes the original)
- Draft a forward with a covering note
- Revise a draft already shown in chat

---

## Pre-flight Checks

Before drafting:

1. **Confirm recipient(s).** If not specified, ask. Do not invent recipients.
2. **Check contacts.md.** If the recipient is a known contact, apply their drafting notes (tone, formality, CC rules).
3. **Confirm inbox context if relevant.** If the draft is a reply, confirm which inbox the original came from (affects signature or formatting conventions, if any are set in priorities.md).
4. **Clarify intent if ambiguous.** If the user's request could produce meaningfully different drafts (e.g., firm vs. gentle decline), ask which direction before drafting.

---

## Drafting Guidelines

### Tone defaults (in order of precedence)
1. Explicit user instruction for this draft
2. Contact-specific notes from `contacts.md`
3. Match the register of the thread being replied to
4. Fallback: warm-but-professional

### Length
- Match the occasion. A quick confirmation doesn't need four paragraphs.
- Prefer shorter over longer when in doubt.
- Never pad.

### What NOT to include unless explicitly asked
- Legal disclaimers or footers
- Filler phrases ("I hope this email finds you well", "Please don't hesitate to reach out")
- Multiple sign-off options
- Excessive hedging ("perhaps", "possibly", "you might want to consider")

---

## Output Format

Present every draft as a fenced block so it is clearly copy-pasteable:

```
DRAFT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
To: [recipient(s)]
CC: [if applicable]
Subject: [subject line]

[body]

[sign-off],
[name placeholder — or ask user what sign-off to use if unknown]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After the draft, on a new line, add a short one-line note on any choices made that the user might want to change (tone, omitted detail, assumed context). If no notable choices, omit the note.

---

## Revision Loop

If the user asks to revise:
- Apply the change and re-present the full draft in the same format.
- Do not summarize the change; just show the updated draft.
- If the revision request is ambiguous, ask for clarification before re-drafting.

---

## Hard Constraints

- **Never send.** This skill produces text in chat only. It does not call any MCP send endpoint, ever.
- **Never save a draft to an inbox** (Gmail Drafts, Outlook Drafts) without explicit user instruction to do so — and even then, confirm once before calling the save endpoint (which is not yet connected).
- If asked to draft on behalf of someone other than the user, flag this and confirm it's intentional.
