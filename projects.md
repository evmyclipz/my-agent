# Projects

Active project registry. JZ uses this file to contextualize email, surface relevant threads, and track status.

**JZ will never rewrite this file wholesale.** Any update is proposed as a specific diff and applied only after explicit confirmation.

---

## Entry Format

```markdown
## [Project Name]

- **Slug:** <!-- short identifier used in priorities.md and elsewhere, e.g., `trading-research` -->
- **Status:** Active | On Hold | Waiting | Winding Down
- **Inbox(es):** Gmail | Outlook | Both | N/A
- **Summary:** <!-- 1-3 sentences: what is this, what's the current state -->
- **Next action:** <!-- the single most important next step, if any -->
- **Key contacts:** <!-- names/slugs from contacts.md, if any -->
- **Notes:** <!-- constraints, background, anything JZ should know -->
- **Last updated:** <!-- YYYY-MM-DD -->
```

---

## Projects

## Senior Design — Neuroprocessor

- **Slug:** `senior-design`
- **Status:** Active
- **Inbox(es):** Outlook
- **Summary:** ECE 460 Capstone Design. Assigned 2026-09-04 to project "Neuroprocessor" (Rohan's #1 preference). Team: Matt Bonilla, Thiago Henrique Costa, Brooklyn Jennings, J.J. Moe, Rohan Malipeddi. Faculty mentor: Dr. Ahmed Sammoud. Reports to two project sponsors/clients: Dr. Mario Simoni and Dr. Daniel Chang.
- **Next action:** Team email introductions this week, then the team reaches out to Simoni/Chang to schedule a kickoff meeting to learn about the application/need.
- **Key contacts:** Dr. Ahmed Sammoud (mentor), Dr. Mario Simoni + Dr. Daniel Chang (sponsors) — see `contacts.md`
- **Notes:** Coursework deliverables (syllabus quiz, etc.) for ECE 460 live in the Notion Homework Tracker, not here — this entry tracks the team/client relationship side, which the tracker doesn't cover.
- **Last updated:** 2026-09-04

---

## SPY Directional Trading Strategy

- **Slug:** `spy-strat`
- **Status:** Active research/backtesting — NOT live trading
- **Inbox(es):** Gmail
- **Summary:** PCA-based regime detection + feature construction (price/VIX/put-call ratio) feeding a directional classifier (logistic regression or GBM). 1–5 day horizon. Backtest on 0DTE options revealed payoff asymmetry (losses ~3x wins despite >53% accuracy) — needs resolving before any real capital is used.
- **Next action:** Address payoff asymmetry in backtest
- **Key contacts:** Ansh Gupta (main POC)
- **Notes:** Research and backtesting only. Never execute or suggest trades. Ansh is the primary collaborator — emails from him on this topic are P1.
- **Last updated:** 2026-06-22

---

_2026-09-04: removed Motorcycle Modification, Summer Travel, Minecraft Calculator, Hyper Agent, and Shopping — all confirmed inactive by Rohan (same cleanup as `TASKS.md` and `memory/`). See git history for the prior version._
