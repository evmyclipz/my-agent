# Session Context — my-agent

Path: /Users/mrohan/Documents/my-agent
Last updated: 2026-07-27 by JZ (orchestrator)

## Current state
- JZ's core role (email triage + project tracking) is stable: `agent.md` hard-rules, `CLAUDE.md` persona, `contacts.md`/`priorities.md`/`projects.md` filled in.
- Orchestrator Mode is now live: JZ can dispatch headless `claude -p` sessions into 4 registered projects (alpaca-trading-bot, covered-call-income, Quant/cryptoquantproject, my-agent) via `skills/orchestrate/SKILL.md`.
- `projects-registry.md` is the authoritative dispatch target list; the 3 trading/crypto projects are EXTRA-LOCKED (no live-order/execution changes without a per-run greenlight).
- Weekly `self-learning` review skill added (`skills/self-learning/SKILL.md`), triggered at session start when `lessons-learned.md`'s `Last self-review:` marker is ≥7 days stale.
- Session-context rollout complete: this file + pointer here, and SESSION_CONTEXT.md + CLAUDE.md pointers in all 3 external repos (created, left UNCOMMITTED for user review).
- End-to-end verification passed: dry-run dispatch reads SESSION_CONTEXT then completes (exit 0); guardrail confirmed — an ordered `git push` was DENIED and nothing was pushed.

## Active threads / open questions
- ⚠️ SECURITY: `cryptoquantproject` has secrets tracked in git (`binanceapikey.txt`, `binanceapisecret.txt`, `Failed Quant Project/.env`). Rotate + `git rm --cached` + gitignore. Not remediated.
- 3 external repos have uncommitted SESSION_CONTEXT.md/CLAUDE.md awaiting user review + commit.
- Discord token is set but needs a restart + pairing with Michael (carried over, not yet resolved).
- Outlook integration remains skipped (Rose-Hulman IT blocked it).

## Next actions
1. Review + commit the uncommitted session-context files in the 3 external repos.
2. Remediate the cryptoquantproject tracked-secrets issue.
3. Restart and verify Discord, then pair Michael.

## Key files / entry points
- `CLAUDE.md` — JZ persona + orchestrator mode
- `agent.md` — canonical hard-rules
- `projects-registry.md` — orchestration targets
- `skills/` — orchestrate, self-learning, email-*
- `lessons-learned.md`, `priorities.md`, `contacts.md`, `projects.md` — live context files

## Recent activity
- 2026-07-27 — Orchestrator mode fully implemented + verified (all 7 SDD tasks): persona section, registry, orchestrate skill, self-learning skill, session-context files (my-agent + 3 external), end-to-end tests. Fixed dispatch template needing `--verbose`.
- Orchestrator-mode design spec and implementation plan written.
- Contacts, priorities, and projects filled in for JZ agent; email-read and email-draft skills added.
