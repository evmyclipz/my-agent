# Session Context — my-agent

Path: /Users/mrohan/Documents/my-agent
Last updated: 2026-07-27 by JZ (orchestrator)

## Current state
- JZ's core role (email triage + project tracking) is stable: `agent.md` hard-rules, `CLAUDE.md` persona, `contacts.md`/`priorities.md`/`projects.md` filled in.
- Orchestrator Mode is now live: JZ can dispatch headless `claude -p` sessions into 4 registered projects (alpaca-trading-bot, covered-call-income, Quant/cryptoquantproject, my-agent) via `skills/orchestrate/SKILL.md`.
- `projects-registry.md` is the authoritative dispatch target list; the 3 trading/crypto projects are EXTRA-LOCKED (no live-order/execution changes without a per-run greenlight).
- Weekly `self-learning` review skill added (`skills/self-learning/SKILL.md`), triggered at session start when `lessons-learned.md`'s `Last self-review:` marker is ≥7 days stale.
- Session-context rollout (this file + pointer pattern) is in progress across the SDD task list — this is Task 5 of 7, proving the pattern in my-agent itself before extending to the 3 external repos.

## Active threads / open questions
- Task 6: roll session-context files + pointers out to the 3 external project repos (alpaca-trading-bot, covered-call-income, cryptoquantproject).
- Task 7: end-to-end verification of the full orchestrator + session-context setup.
- Discord token is set but needs a restart + pairing with Michael (carried over from earlier scaffolding work, not yet resolved).
- Outlook integration remains skipped (Rose-Hulman IT blocked it).

## Next actions
1. Complete Task 6 — session-context files for the 3 external repos.
2. Complete Task 7 — end-to-end verification of orchestrator mode + session-context.
3. Restart and verify Discord, then pair Michael.

## Key files / entry points
- `CLAUDE.md` — JZ persona + orchestrator mode
- `agent.md` — canonical hard-rules
- `projects-registry.md` — orchestration targets
- `skills/` — orchestrate, self-learning, email-*
- `lessons-learned.md`, `priorities.md`, `contacts.md`, `projects.md` — live context files

## Recent activity
- 2026-07-27 — Task 5: added this SESSION_CONTEXT.md + session-start pointer in CLAUDE.md.
- Orchestrator Mode implemented: project registry, `orchestrate` dispatch skill, weekly `self-learning` skill, Orchestrator Mode section added to `CLAUDE.md`.
- Orchestrator-mode design spec and implementation plan written.
- Contacts, priorities, and projects filled in for JZ agent; email-read and email-draft skills added.
