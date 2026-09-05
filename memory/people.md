# People

Contact routing/relationship notes. One row per person (consolidated from `memory/people/*.md` on 2026-09-04 — six files felt like more structure than six people warrant). See note at bottom on why this stays Markdown, not SQL.

| Name | Email(s) | Discord | Inbox | Relationship | Urgency | Tone | Tags |
|---|---|---|---|---|---|---|---|
| Ankit Pulivendula | ankit.pulivendula@gmail.com | | Gmail | Close friend | P2 | Funny, casual, occasionally sarcastic | #personal |
| Ansh Gupta | ansh2004projects@gmail.com | | Gmail | Close friend + quant project collaborator — primary POC for spy-strat, treat spy-strat emails from him as P1 | P1 (always P1 if touches spy-strat) | Casual, funny, occasionally sarcastic | #personal #projects #finance |
| Contento Francesa | | | Outlook | Internship Relocation Assistant | P0 | Formal and professional | #travel #finances #relocation |
| Dad — Kiran Kumar Malipeddi | kkmallipeddi@gmail.com · kmaliped@qti.qualcomm.com | | Both | Father | P1 | Casual | #personal |
| Michael | Le13977367777@gmail.com | TKperson | Gmail | Best friend | P2 | Casual, sarcastic, jokey — anything goes on tech | #personal #buddy |
| Mom — Padmini Banavathula | krmini2005@gmail.com | | Gmail | Mother | P1 | Funny and casual | #personal |

## Why Markdown, not SQL

Considered a SQLite table for this (per Rohan's suggestion) — not worth it at 6 rows.
A query layer only pays off once lookups need filtering/joins at real volume; for a
handful of contacts it just adds a tool call and a schema to maintain, with no
token savings (this table is already smaller than a `SELECT *` result would be).
Revisit if this list grows into the dozens.
