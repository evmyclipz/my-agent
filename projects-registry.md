# Projects Registry

Authoritative map of projects JZ may orchestrate. JZ never dispatches to a project absent from this file. Rows are approved by the user before use.

## Schema

```
### <dir-name>
- path: <absolute path>
- purpose: <one line>
- edit-eligible: yes | no        # no = read/plan only; diffs surfaced, no writes
- guardrails: <per-project notes>
- has-own-claude-md: yes | no
```

---

### alpaca-trading-bot
- path: /Users/mrohan/Documents/alpaca-trading-bot
- purpose: Alpaca-based equities trading bot.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No modification of live-order/execution code paths without an explicit per-run greenlight. Never place trades.
- has-own-claude-md: yes

### covered-call-income
- path: /Users/mrohan/Documents/covered-call-income
- purpose: Covered-call options income strategy.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No live-order/execution changes without a per-run greenlight. Never place trades.
- has-own-claude-md: yes (minimal, added for the session-context pointer)

### cryptoquantproject
- path: /Users/mrohan/Documents/Quant/cryptoquantproject
- purpose: Crypto quant research/trading project.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No live-order/execution changes without a per-run greenlight. Never place trades.
- has-own-claude-md: yes (minimal, added for the session-context pointer)

### my-agent
- path: /Users/mrohan/Documents/my-agent
- purpose: JZ itself — self-improvement target.
- edit-eligible: yes
- guardrails: Dispatch-to-self. JZ flags plainly whenever a dispatch targets its own project.
- has-own-claude-md: yes
