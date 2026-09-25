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
- **Summary:** ECE 460 Capstone Design. Assigned 2026-09-04 to project "Neuroprocessor" (Rohan's #1 preference). Team: Matt Bonilla, Thiago Henrique Costa, Brooklyn Jennings, J.J. Moe, Rohan Malipeddi. Faculty mentor: Dr. Ahmed Sammoud. Reports to two project sponsors/clients: Dr. Mario Simoni and Dr. Daniel Chang. Weekly advisor meeting with Dr. Sammoud (Wed, J203). Platform decision: ASIC/Caravel path dead post-Efabless → moving to Kria KR260 FPGA.
- **Next action:** Rohan's assignment (2026-09-23): research the AMD Kria KR260 for migrating the current Caravel SoC design onto it — clients are committed to moving entirely to KR260. Deliverable = one research memo per paper/video/math source (AI-drafting approved by team + advisor; format: `02-researchMemo.docx` — heading w/ title, author, creation date, team/project; why it fits the project; technical summary; bibliography; figures; change log; posted to team SharePoint). First two sources: Beaubois et al. 2024 (fnins.2024.1457774, KR260 HH emulator) — important sections read 2026-09-24, research memo #1 next; Miedema et al. 2024 ExaFlexHH (fninf.2024.1330875) — reading Fri 9/25.
- **Weekly memo:** team memo to instructor + client every week (format: `01-weeklyMemoAssignment-2627.docx` — SMART tasks w/ owner + due date + hours, labor-cost table, feedback sections), placed in MS Teams folder, due before 2 PM every Wednesday. Must be **human-written** — JZ may turn meeting minutes into raw content for Rohan to pick from, but never writes the memo text itself.
- **Key contacts:** Dr. Ahmed Sammoud (mentor), Dr. Mario Simoni + Dr. Daniel Chang (sponsors) — see `contacts.md`
- **Notes:** Coursework deliverables (syllabus quiz, etc.) for ECE 460 live in the Notion Homework Tracker, not here — this entry tracks the team/client relationship side, which the tracker doesn't cover.
- **Last updated:** 2026-09-25

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
