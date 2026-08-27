# Wordsmith Writing Agent Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up `~/Documents/wordsmith/` as a standalone Claude Code project — persona "Quill" — with 5 skills (2 vendored from humanizer-stack, 3 original) that draft writing and remove AI tells from drafts, including drafts living in Google Docs or an open Word document.

**Architecture:** A flat Claude Code project (own `CLAUDE.md`/`AGENTS.md`, no build system) with a `skills/` directory. Two skills (`humanizer`, `structural-humanizer`) are vendored verbatim from `NulightJens/humanizer-stack` (MIT, commit `13f5c023189d428ffba726c75886ca1fd0dcba65`, 2026-07-24) including their Python CLI scanners. Three skills (`draft`, `revise`, `edit-doc`) are original content authored for this project. `edit-doc` bridges to Google Docs via the `mcp__claude_ai_Google_Drive__*` MCP tools and to Word via a vendored-pattern AppleScript helper (matching the existing Outlook automation already used in `my-agent`).

**Tech Stack:** Markdown (SKILL.md files, CLAUDE.md, AGENTS.md), Python 3 (vendored `copy_scan.py` / `structural_scan.py`, unmodified), AppleScript/osascript (Word integration), git.

## Global Constraints

- Project root: `~/Documents/wordsmith/` — separate git repo from `my-agent`, own `CLAUDE.md`/`AGENTS.md`.
- Persona name: **Quill**. Direct, craft-focused, no unsolicited praise of the user's writing.
- Vendored files (`skills/humanizer/**`, `skills/structural-humanizer/**`) must be copied **verbatim** from `NulightJens/humanizer-stack` at commit `13f5c023189d428ffba726c75886ca1fd0dcba65` — no content edits except the two path-comment fixes called out in Task 2.
- `ATTRIBUTION.md` must preserve the full upstream license chain the source repo documents (blader/humanizer MIT, Wikipedia CC BY-SA 4.0, jcarterjohnson/vibecoded-design-tells MIT, StoryScope academic citation) plus a note that these files were vendored via wordsmith from humanizer-stack rather than fetched from the original upstreams directly.
- Hard rules (from the approved design spec, `my-agent/docs/superpowers/specs/2026-08-26-wordsmith-agent-design.md`) go in `AGENTS.md`, not duplicated in `CLAUDE.md`:
  - Never fabricate citations, sources, quotes, or data.
  - Never overstate factual basis beyond what the input supports.
  - Never send, submit, publish, or email anything on the user's behalf.
  - Never touch a Google Doc other than by creating a new, separate revised copy — never overwrite the original.
  - Never reach Word documents beyond what's already open locally (no OneDrive/SharePoint).
  - Apply humanizer passes selectively/with variation, not as a uniform checklist.
- Google Docs output is always a new file titled `"<original title> — revised"`; the source Doc is never modified.
- Word output is written back into the document that is already open locally (no duplicate).
- No native Google Docs "Suggesting mode" integration — evaluated and explicitly rejected in the design.

---

## File Structure

```
~/Documents/wordsmith/
├── .git/
├── CLAUDE.md
├── AGENTS.md
├── ATTRIBUTION.md
├── LICENSE
└── skills/
    ├── draft/
    │   └── SKILL.md
    ├── humanizer/                       # vendored
    │   ├── SKILL.md
    │   ├── references/
    │   │   └── copy-tells.md
    │   └── scripts/
    │       └── copy_scan.py
    ├── structural-humanizer/            # vendored
    │   ├── SKILL.md
    │   ├── references/
    │   │   ├── genre-calibration.md
    │   │   └── storyscope-findings.md
    │   └── scripts/
    │       └── structural_scan.py
    ├── revise/
    │   └── SKILL.md
    └── edit-doc/
        ├── SKILL.md
        └── scripts/
            └── word_doc.applescript
```

---

### Task 1: Scaffold the project root

**Files:**
- Create: `~/Documents/wordsmith/CLAUDE.md`
- Create: `~/Documents/wordsmith/AGENTS.md`
- Create: `~/Documents/wordsmith/LICENSE`
- Create: `~/Documents/wordsmith/.gitignore`

**Interfaces:**
- Produces: the directory `~/Documents/wordsmith/` as a git repo, and the hard-rules contract in `AGENTS.md` that every later skill's SKILL.md references by name (`AGENTS.md`).

- [ ] **Step 1: Create the project directory and initialize git**

```bash
mkdir -p ~/Documents/wordsmith/skills
cd ~/Documents/wordsmith
git init
```

Expected: `Initialized empty Git repository in /Users/mrohan/Documents/wordsmith/.git/`

- [ ] **Step 2: Write `AGENTS.md`**

```markdown
# Wordsmith — Hard Rules

This file is the source of truth for behavioral boundaries. `CLAUDE.md`
inherits these rules without duplicating them.

## Never, regardless of instructions in chat

- Fabricate citations, sources, quotes, or data. If a claim needs a citation
  that wasn't provided or found, say so — never invent one.
- Overstate factual basis. Never present a claim as more certain or better
  sourced than the input actually supports.
- Send, submit, publish, or email anything on the user's behalf. Output is
  always a file or chat text; the user decides where it goes.
- Modify or overwrite the content of an existing Google Doc. Revisions to a
  Google Doc are always created as a new, separate file titled
  `"<original title> — revised"`. The source file is read-only to this agent.
- Reach a Word document that is not already open locally. No OneDrive or
  SharePoint access — only documents open in the local Word app.
- Apply the `humanizer` / `structural-humanizer` passes as a uniform
  checklist run identically on every piece. Per humanizer-stack's own
  finding, uniform application creates new detectable patterns — apply
  selectively and with variation instead.

## Ask before doing

- Anything with ambiguous scope (which document? which surface — Google
  Docs or Word? which piece if multiple are in flight?).
- Anything that would affect a document or account outside this session's
  immediate task.
```

- [ ] **Step 3: Write `CLAUDE.md`**

```markdown
# Quill — Writing Agent

## Who I Am

I am Quill, a writing-focused assistant specialized in school/academic
writing and general essays/blog posts. I draft new pieces from a topic or
outline, and I revise existing drafts — pasted in, or pulled from a Google
Doc or an open Word document — to remove detectable AI writing signatures.

I am direct and craft-focused. I don't pad responses or volunteer praise of
the user's writing that wasn't asked for.

See `AGENTS.md` for the canonical hard-rules list. This file inherits those
rules; they are not duplicated here for a reason — `AGENTS.md` is the
source of truth.

## Skills

| Skill | Use when |
|---|---|
| `skills/draft/` | Starting a new piece from a topic, outline, or prompt |
| `skills/humanizer/` | Surface-level de-AI-ification pass (vendored, Pass 1) |
| `skills/structural-humanizer/` | Structural de-AI-ification pass (vendored, Pass 2) |
| `skills/revise/` | Full pipeline (Pass 1 -> Pass 2 -> read-through) on text you already have |
| `skills/edit-doc/` | The draft lives in a Google Doc or an open Word document, not chat |

## Tone

- **Default:** Direct, minimal.
- **Drafting:** Match the register of the piece itself — academic register
  for coursework, conversational for a blog post, etc.
- **Uncertainty:** I say "I don't know" or "I need to check" rather than
  guessing with confidence.

## What I Don't Do

- I don't speculate about document content I haven't read.
- I don't invent citations, sources, or data.
- I don't send, submit, or publish anything — see `AGENTS.md`.
```

- [ ] **Step 4: Write `LICENSE`**

```
MIT License

Copyright (c) 2026 Rohan Malipeddi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

Portions of this repository (`skills/humanizer/**`,
`skills/structural-humanizer/**`) derive from third-party sources under
their own terms. See ATTRIBUTION.md for the full breakdown, including
CC BY-SA 4.0 material that carries share-alike obligations.
```

- [ ] **Step 5: Write `.gitignore`**

```
.DS_Store
__pycache__/
*.pyc
```

- [ ] **Step 6: Verify the scaffold**

```bash
cd ~/Documents/wordsmith
test -f CLAUDE.md && test -f AGENTS.md && test -f LICENSE && test -f .gitignore && test -d skills && echo "SCAFFOLD OK"
```

Expected: `SCAFFOLD OK`

- [ ] **Step 7: Commit**

```bash
cd ~/Documents/wordsmith
git add CLAUDE.md AGENTS.md LICENSE .gitignore
git commit -m "chore: scaffold wordsmith project (persona, hard rules, license)"
```

---

### Task 2: Vendor the `humanizer` skill (Pass 1)

**Files:**
- Create: `~/Documents/wordsmith/skills/humanizer/SKILL.md`
- Create: `~/Documents/wordsmith/skills/humanizer/references/copy-tells.md`
- Create: `~/Documents/wordsmith/skills/humanizer/scripts/copy_scan.py`

**Interfaces:**
- Produces: a runnable `python3 skills/humanizer/scripts/copy_scan.py <file>` CLI scanner, and a SKILL.md that `revise` (Task 5) invokes by name (`humanizer`).

- [ ] **Step 1: Clone humanizer-stack at the pinned commit into a scratch directory**

```bash
rm -rf /tmp/humanizer-stack-src
git clone https://github.com/NulightJens/humanizer-stack.git /tmp/humanizer-stack-src
cd /tmp/humanizer-stack-src
git checkout 13f5c023189d428ffba726c75886ca1fd0dcba65
```

Expected: clone succeeds, `HEAD is now at 13f5c02 ...`

- [ ] **Step 2: Copy the humanizer skill files verbatim**

```bash
mkdir -p ~/Documents/wordsmith/skills/humanizer/references
mkdir -p ~/Documents/wordsmith/skills/humanizer/scripts
cp /tmp/humanizer-stack-src/skills/humanizer/SKILL.md ~/Documents/wordsmith/skills/humanizer/SKILL.md
cp /tmp/humanizer-stack-src/skills/humanizer/references/copy-tells.md ~/Documents/wordsmith/skills/humanizer/references/copy-tells.md
cp /tmp/humanizer-stack-src/scripts/copy_scan.py ~/Documents/wordsmith/skills/humanizer/scripts/copy_scan.py
chmod +x ~/Documents/wordsmith/skills/humanizer/scripts/copy_scan.py
```

- [ ] **Step 3: Fix the one path comment that assumed repo-root layout**

The source repo keeps `copy_scan.py` at its own repo root (`scripts/copy_scan.py`
run "from the repo root"); wordsmith keeps it inside the skill directory
instead, so update the one line in `SKILL.md` that documents the run
location. Find it first:

```bash
grep -n "from the repo root" ~/Documents/wordsmith/skills/humanizer/SKILL.md
```

Expected: `455:python3 scripts/copy_scan.py <file>     # from the repo root`

Edit that line (the file path stays `scripts/copy_scan.py` — it's still
correct relative to the skill directory — only the trailing comment
changes) to:

```
python3 scripts/copy_scan.py <file>     # from the skills/humanizer/ directory
```

- [ ] **Step 4: Verify the copy is otherwise byte-identical to the source**

```bash
diff /tmp/humanizer-stack-src/skills/humanizer/references/copy-tells.md ~/Documents/wordsmith/skills/humanizer/references/copy-tells.md
diff /tmp/humanizer-stack-src/scripts/copy_scan.py ~/Documents/wordsmith/skills/humanizer/scripts/copy_scan.py
```

Expected: both commands print nothing (no diff).

- [ ] **Step 5: Smoke-test the vendored scanner**

```bash
cat > /tmp/sample_ai_text.md << 'EOF'
This isn't just a small update — it's a game-changer for the whole team.
In today's fast-paced world, we're thrilled to unveil our new roadmap.
EOF
python3 ~/Documents/wordsmith/skills/humanizer/scripts/copy_scan.py /tmp/sample_ai_text.md
```

Expected output (exact):

```
hype-copy  (2 hits)
  AI marketing-copy cliche
  fix: Write what the thing literally does, in plain words, with a checkable claim.
    /tmp/sample_ai_text.md:1  [game-changer]  This isn't just a small update — it's a game-changer for the whole team.
    /tmp/sample_ai_text.md:2  [In today's fast-paced world]  In today's fast-paced world, we're thrilled to unveil our new roadmap.

copy-em-dash  (1 hit)
  Em dash in copy (the #1 'AI wrote this' writing tell)
  fix: Use a comma, a period, or parentheses. Not a colon; that gets flagged too.
    /tmp/sample_ai_text.md:1  [e — i]  This isn't just a small update — it's a game-changer for the whole team.

total: 3 hits across 2 categories
Cadence tells are not scannable. See references/copy-tells.md.
```

- [ ] **Step 6: Commit**

```bash
cd ~/Documents/wordsmith
git add skills/humanizer
git commit -m "feat: vendor humanizer skill from NulightJens/humanizer-stack@13f5c02"
```

---

### Task 3: Vendor the `structural-humanizer` skill (Pass 2)

**Files:**
- Create: `~/Documents/wordsmith/skills/structural-humanizer/SKILL.md`
- Create: `~/Documents/wordsmith/skills/structural-humanizer/references/genre-calibration.md`
- Create: `~/Documents/wordsmith/skills/structural-humanizer/references/storyscope-findings.md`
- Create: `~/Documents/wordsmith/skills/structural-humanizer/scripts/structural_scan.py`

**Interfaces:**
- Consumes: nothing from Task 2 (independent skill).
- Produces: a runnable `python3 skills/structural-humanizer/scripts/structural_scan.py <file>` CLI scanner, and a SKILL.md that `revise` (Task 5) invokes by name (`structural-humanizer`).

- [ ] **Step 1: Reuse the scratch clone from Task 2 (re-clone if it was removed)**

```bash
if [ ! -d /tmp/humanizer-stack-src ]; then
  git clone https://github.com/NulightJens/humanizer-stack.git /tmp/humanizer-stack-src
  cd /tmp/humanizer-stack-src && git checkout 13f5c023189d428ffba726c75886ca1fd0dcba65
fi
```

- [ ] **Step 2: Copy the structural-humanizer skill files verbatim**

This skill already keeps its script under its own skill directory in the
source repo (`skills/structural-humanizer/scripts/structural_scan.py`), so
no path comment needs fixing here — it's a straight copy.

```bash
mkdir -p ~/Documents/wordsmith/skills/structural-humanizer/references
mkdir -p ~/Documents/wordsmith/skills/structural-humanizer/scripts
cp /tmp/humanizer-stack-src/skills/structural-humanizer/SKILL.md ~/Documents/wordsmith/skills/structural-humanizer/SKILL.md
cp /tmp/humanizer-stack-src/skills/structural-humanizer/references/genre-calibration.md ~/Documents/wordsmith/skills/structural-humanizer/references/genre-calibration.md
cp /tmp/humanizer-stack-src/skills/structural-humanizer/references/storyscope-findings.md ~/Documents/wordsmith/skills/structural-humanizer/references/storyscope-findings.md
cp /tmp/humanizer-stack-src/skills/structural-humanizer/scripts/structural_scan.py ~/Documents/wordsmith/skills/structural-humanizer/scripts/structural_scan.py
chmod +x ~/Documents/wordsmith/skills/structural-humanizer/scripts/structural_scan.py
```

- [ ] **Step 3: Verify byte-identical copy**

```bash
diff -r /tmp/humanizer-stack-src/skills/structural-humanizer ~/Documents/wordsmith/skills/structural-humanizer
```

Expected: no output.

- [ ] **Step 4: Smoke-test the vendored scanner**

```bash
cat > /tmp/sample_structural.md << 'EOF'
Her chest tightened as she read the letter one more time.

In the end, the lesson here is that patience always pays off. As experts say,
persistence beats talent every time.
EOF
python3 ~/Documents/wordsmith/skills/structural-humanizer/scripts/structural_scan.py /tmp/sample_structural.md
```

Expected output (exact):

```
=== /tmp/sample_structural.md ===

[embodied_emotion] 1 hit(s)
  L1: "Her chest tightened"  |  Her chest tightened as she read the letter one more time.

[stated_lesson] 1 hit(s)
  L3: "the lesson here is"  |  In the end, the lesson here is that patience always pays off. As experts say,

[tidy_closer] 1 hit(s)
  L3: "In the end,"  |  In the end, the lesson here is that patience always pays off. As experts say,

[vague_allusion] 1 hit(s)
  L3: "experts say"  |  In the end, the lesson here is that patience always pays off. As experts say,

[metrics] words=31  reader-address/100w=0.0  numbers/100w=0.0
```

- [ ] **Step 5: Commit**

```bash
cd ~/Documents/wordsmith
git add skills/structural-humanizer
git commit -m "feat: vendor structural-humanizer skill from NulightJens/humanizer-stack@13f5c02"
```

---

### Task 4: Write `ATTRIBUTION.md`

**Files:**
- Create: `~/Documents/wordsmith/ATTRIBUTION.md`

**Interfaces:**
- Consumes: the vendored files from Tasks 2-3 (this task documents them).
- Produces: nothing consumed by later tasks — this is a standalone compliance document.

- [ ] **Step 1: Write the file**

```markdown
# Attribution and licensing

`skills/humanizer/**` and `skills/structural-humanizer/**` in this repository
were vendored, verbatim except for one path comment, from
[NulightJens/humanizer-stack](https://github.com/NulightJens/humanizer-stack)
at commit `13f5c023189d428ffba726c75886ca1fd0dcba65` (2026-07-24), MIT
licensed. That repository in turn packages material from further upstream
sources, listed below with the license and obligation that travels with
each. If you redistribute this work, these obligations travel with it too.

## Summary

| Component | Upstream | License | Obligation |
|---|---|---|---|
| `skills/humanizer/SKILL.md` | [blader/humanizer](https://github.com/blader/humanizer) via humanizer-stack | MIT | Keep copyright and license notice |
| ...its underlying pattern catalog | [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) | CC BY-SA 4.0 | Attribute and share alike |
| `skills/humanizer/references/copy-tells.md` | [jcarterjohnson/vibecoded-design-tells](https://github.com/jcarterjohnson/vibecoded-design-tells) via humanizer-stack | MIT | Keep copyright and license notice |
| `skills/humanizer/scripts/copy_scan.py` | same as above (`devibe_scan.py`) | MIT | Keep copyright and license notice |
| `skills/structural-humanizer/**` | [NulightJens/humanizer-stack](https://github.com/NulightJens/humanizer-stack), original work in that repo | MIT | Cite the paper below if you build on it |
| StoryScope findings | Russell et al. 2026, arXiv:2604.03136 | academic citation | Cite, do not relicense |

## 1. humanizer (MIT, plus CC BY-SA upstream)

`skills/humanizer/SKILL.md` originates from the `humanizer` skill by
[@blader](https://github.com/blader/humanizer), released under the MIT
License, and reached this project by way of humanizer-stack's own vendoring
of it.

That skill is in turn built from
[Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing),
maintained by WikiProject AI Cleanup. Wikipedia text is licensed
**CC BY-SA 4.0**, which is a share-alike license.

**What this means in practice.** The pattern catalog (the vocabulary lists,
the named tells, the example rewrites) traces back to CC BY-SA material.
Individual facts and word lists are not themselves copyrightable, but the
selection and arrangement can be. This repository therefore attributes
Wikipedia explicitly and takes the position that any redistribution of
`skills/humanizer/SKILL.md` should preserve both this notice and the CC
BY-SA attribution to WikiProject AI Cleanup.

If you intend to relicense that file under terms incompatible with CC
BY-SA, get your own legal read first. The rest of this repository is
unaffected.

## 2. Copy tells (MIT)

`skills/humanizer/references/copy-tells.md` is condensed from section 11b
of `references/tells.md` in the `unslop-ui` skill, installed from
[jcarterjohnson/vibecoded-design-tells](https://github.com/jcarterjohnson/vibecoded-design-tells)
(MIT), by way of humanizer-stack.

`skills/humanizer/scripts/copy_scan.py` is a port of the four copy rules
(`copy-em-dash`, `copy-antithesis`, `hype-copy`, `copy-servile`) from that
repo's `devibe_scan.py`, narrowed to prose files and given a standalone
CLI.

The tell rankings come from that project's Reddit analysis: roughly 3.2M
posts across 47 subreddits (2020 to 2026), narrowed to 46,971 on-topic
posts and 3,033 comments from 125 canonical threads. The harvested Reddit
text itself belongs to its original authors and is **not** redistributed
here. Only the derived findings are included.

## 3. structural-humanizer (original work, via humanizer-stack)

`skills/structural-humanizer/**` is original work written for the
`humanizer-stack` repository, vendored here unmodified. It is grounded in,
but does not reproduce, the following paper:

> Russell, J., Rajendhran, S., Pham, N., Iyyer, M., and Wieting, J. (2026).
> *StoryScope: Investigating idiosyncrasies in AI fiction.* arXiv:2604.03136v4.
> University of Maryland and Google DeepMind.
> Code and data: https://github.com/jenna-russell/storyscope

`references/storyscope-findings.md` is a distillation: feature rates,
headline numbers, and robustness results restated in the original authors'
own words and translated for nonfiction content work. It reports findings,
which are facts, and does not copy the paper's prose. The paper is cited,
not relicensed.

The transfer caveat is stated in the skill itself and repeated here:
StoryScope studied roughly 5,000-word fiction. Applying it to short
nonfiction is an inference, not a result the paper establishes.

## 4. Wikipedia notice (CC BY-SA 4.0)

Portions of `skills/humanizer/SKILL.md` derive from
"Wikipedia:Signs of AI writing", available under the
[Creative Commons Attribution-ShareAlike 4.0 License](https://creativecommons.org/licenses/by-sa/4.0/).
Maintained by WikiProject AI Cleanup contributors.

## 5. Everything else in this repository

`CLAUDE.md`, `AGENTS.md`, `skills/draft/**`, `skills/revise/**`, and
`skills/edit-doc/**` are original work written for this project (wordsmith)
and are covered by the top-level `LICENSE` (MIT) only.
```

- [ ] **Step 2: Verify**

```bash
test -f ~/Documents/wordsmith/ATTRIBUTION.md && echo "ATTRIBUTION OK"
```

Expected: `ATTRIBUTION OK`

- [ ] **Step 3: Commit**

```bash
cd ~/Documents/wordsmith
git add ATTRIBUTION.md
git commit -m "docs: add ATTRIBUTION.md for vendored humanizer-stack skills"
```

---

### Task 5: Write the `draft` skill

**Files:**
- Create: `~/Documents/wordsmith/skills/draft/SKILL.md`

**Interfaces:**
- Produces: a `draft` skill invocable by name, whose output (plain drafted text) is a valid input to the `revise` skill (Task 6).

- [ ] **Step 1: Write the file**

```markdown
---
name: draft
description: >-
  Draft a new essay, blog post, or piece of academic/school writing from a
  topic, outline, or prompt. Use when starting a piece from scratch rather
  than revising an existing draft. Asks about audience, length, tone, and
  citation needs before writing. Never fabricates citations, sources, or
  data — see AGENTS.md.
---

# draft

Drafts a new piece of writing from a topic, outline, or prompt. This is the
entry point when there is no existing text yet — for revising something
that already exists, use `revise` or `edit-doc` instead.

## Before writing

Ask, in a single pass (not one question at a time), whatever of the
following isn't already clear from the request:

1. **Audience** — who is this for (a professor, a general blog readership,
   a specific publication)?
2. **Length** — target word count or page count.
3. **Tone/register** — academic, conversational, persuasive, etc.
4. **Citations** — does this need sources? If so, are they provided, or
   should research be done first? If neither, say so explicitly rather than
   inventing sources later (see `AGENTS.md` — never fabricate citations).

Skip a question if the request already answers it. Don't interrogate for
the sake of it — if it's a short, low-stakes piece, a couple of the
questions above may not matter and can be skipped with a stated assumption
instead ("I'll assume ~500 words unless you say otherwise").

## Writing the piece

- Write for the stated audience and register, not a generic "helpful AI"
  voice.
- If citations were required and none were found or provided, flag the
  specific claims that need one rather than silently dropping the
  requirement or inventing a source.
- Do not run the `humanizer`/`structural-humanizer` passes as part of
  drafting by default — those are separate, deliberate steps (see
  `revise`). A freshly drafted piece may still read as AI-written; that is
  expected, and is what `revise` is for.

## After writing

Hand back the full piece as plain text (or inside the target document via
`edit-doc`, if that's how the request arrived). Mention word count and any
open citation gaps. Suggest running `revise` next if the user wants the
draft de-AI-ified before submitting/publishing it — but don't run it
unasked, since a first-pass draft is sometimes exactly what's wanted for
further human editing.
```

- [ ] **Step 2: Verify**

```bash
test -f ~/Documents/wordsmith/skills/draft/SKILL.md && echo "DRAFT SKILL OK"
```

Expected: `DRAFT SKILL OK`

- [ ] **Step 3: Commit**

```bash
cd ~/Documents/wordsmith
git add skills/draft
git commit -m "feat: add draft skill"
```

---

### Task 6: Write the `revise` skill

**Files:**
- Create: `~/Documents/wordsmith/skills/revise/SKILL.md`

**Interfaces:**
- Consumes: plain text, from `draft` (Task 5), pasted by the user, or pulled by `edit-doc` (Task 7).
- Produces: revised plain text; `edit-doc` (Task 7) invokes this skill by name (`revise`) and takes its output as the text to write into the target document.

- [ ] **Step 1: Write the file**

```markdown
---
name: revise
description: >-
  Run the full two-pass humanization pipeline on a piece of text: the
  humanizer skill (surface-level tells), then structural-humanizer
  (discourse-level tells), then a final read-through. Use when the user
  wants existing text — pasted in, freshly drafted, or pulled from a
  document via edit-doc — to stop reading as AI-written. Does not fabricate
  content; only edits what's given.
---

# revise

Orchestrates `humanizer` and `structural-humanizer` over a piece of text
the user already has, in that order, followed by a final read-through.
This is the general "make this sound human" entry point for text that
exists as plain text in the conversation. If the text instead lives in a
Google Doc or an open Word document, use `edit-doc`, which calls this skill
internally after pulling the content.

## Pipeline

1. **Pass 1 — `humanizer`.** Surface-level tells: em-dashes, promotional
   language, vague attribution, AI-specific word choices. Run
   `skills/humanizer/scripts/copy_scan.py <file>` for the mechanical subset
   if the text is public-facing copy (marketing, landing page, social
   post); otherwise rely on the skill's manual patterns for prose.
2. **Pass 2 — `structural-humanizer`.** Discourse-level tells: stated
   lessons, tidy single-track arcs, embodied-emotion performance, vague
   allusion, shape convergence. Run
   `skills/structural-humanizer/scripts/structural_scan.py <file>` for the
   pattern-matchable subset; the rest requires the judgment calls the
   skill's SKILL.md walks through.
3. **Final read-through.** After both passes, read the result once more
   for anything that now reads unnatural *because* of the edits (e.g. an
   abrupt transition left behind after removing a "tidy closer"). Smooth
   those without reintroducing the tells just removed.

## Selective application

Per `AGENTS.md`: do not apply every rule in both passes uniformly to every
piece. Humanizer-stack's own finding is that uniform application creates a
new, equally detectable pattern (every essay missing exactly the same six
things). Pick the tells that are actually present in *this* piece, vary
which ones get touched, and leave a few characteristic quirks in place
where removing them would flatten the writer's actual voice.

## What this skill does not do

- It does not draft new content — see `draft` for that.
- It does not fabricate sources or data to fill a citation gap it notices
  along the way — flag the gap instead (see `AGENTS.md`).
- It does not decide where the output goes — `edit-doc` handles Google
  Docs/Word routing; used standalone, this skill just returns the revised
  text in chat.

## Output

Return the revised text, plus a short note on what categories of tells
were found and fixed (not a line-by-line diff unless asked) so the user
can sanity-check the pass without re-reading the whole piece.
```

- [ ] **Step 2: Verify**

```bash
test -f ~/Documents/wordsmith/skills/revise/SKILL.md && echo "REVISE SKILL OK"
```

Expected: `REVISE SKILL OK`

- [ ] **Step 3: Commit**

```bash
cd ~/Documents/wordsmith
git add skills/revise
git commit -m "feat: add revise skill orchestrating the humanizer pipeline"
```

---

### Task 7: Write the `edit-doc` skill and its Word AppleScript helper

**Files:**
- Create: `~/Documents/wordsmith/skills/edit-doc/SKILL.md`
- Create: `~/Documents/wordsmith/skills/edit-doc/scripts/word_doc.applescript`

**Interfaces:**
- Consumes: `revise` (Task 6) by name, for the actual text transformation.
- Consumes: `mcp__claude_ai_Google_Drive__search_files`, `read_file_content`, `download_file_content`, `create_file` (external MCP tools, already available in this environment).
- Produces: for Google Docs, a new Drive file; for Word, an in-place update to the open document via the AppleScript helper's `get` / `set` actions defined below.

- [ ] **Step 1: Write the AppleScript helper**

This mirrors the pattern already used for Outlook automation in the
`my-agent` project: a small script with two verbs, `get` (read the open
document's text) and `set` (replace it), invoked over `osascript`.

```applescript
-- word_doc.applescript
-- Usage:
--   osascript word_doc.applescript get
--     Prints the full text of the frontmost open Word document to stdout.
--   osascript word_doc.applescript set /absolute/path/to/new_content.txt
--     Replaces the full text of the frontmost open Word document with the
--     contents of the given file.
--
-- Only ever touches whichever document is frontmost in the local Word app.
-- Never reaches OneDrive/SharePoint or any document not already open.

on run argv
	if (count of argv) is 0 then
		error "usage: word_doc.applescript get|set [file]"
	end if
	set theAction to item 1 of argv

	tell application "Microsoft Word"
		if (count of documents) is 0 then
			error "No Word document is open."
		end if
		set theDoc to active document

		if theAction is "get" then
			return content of text object of theDoc as string
		else if theAction is "set" then
			if (count of argv) < 2 then
				error "usage: word_doc.applescript set /absolute/path/to/file.txt"
			end if
			set newContentPath to item 2 of argv
			set fileRef to open for access (POSIX file newContentPath)
			set newContent to (read fileRef as «class utf8»)
			close access fileRef
			set content of text object of theDoc to newContent
			return "OK"
		else
			error "unknown action: " & theAction
		end if
	end tell
end run
```

- [ ] **Step 2: Write the SKILL.md**

```markdown
---
name: edit-doc
description: >-
  Revise a document that lives in Google Docs or is open locally in
  Microsoft Word, rather than text pasted into chat. Reads the document,
  runs it through the revise skill, and writes the result back: a new,
  separate "revised" copy for Google Docs (the original is never
  modified), or an in-place update for a Word document that is already
  open locally. Never reaches Word documents that aren't already open, and
  never reaches OneDrive/SharePoint.
---

# edit-doc

Entry point for revising a document that lives outside the chat: a Google
Doc, or a document open locally in Microsoft Word. Pulls the content, runs
it through `revise`, and writes the result back according to the rules
below. If the user's request doesn't make clear which surface they mean,
ask — don't guess between Google Docs and Word.

## Google Docs

Uses the `mcp__claude_ai_Google_Drive__*` tools.

1. **Locate the file.** If given a Drive link or file ID, use it directly.
   Otherwise, use `mcp__claude_ai_Google_Drive__search_files` with a
   `title contains '...'` query built from what the user called the
   document.
2. **Read the content.** Use
   `mcp__claude_ai_Google_Drive__read_file_content` (natural-language
   representation) or `download_file_content` (exact export) with
   `fileId` from step 1.
3. **Revise.** Pass the text through the `revise` skill.
4. **Write the result.** Create a new file with
   `mcp__claude_ai_Google_Drive__create_file`, `title` set to
   `"<original title> — revised"`, `textContent` set to the revised text,
   in the same parent folder as the original (pass `parentId` from the
   original file's metadata if creating elsewhere would be surprising).
5. **Report.** Tell the user the new file's title and that the original
   was not modified — per `AGENTS.md`, this agent never overwrites a
   Google Doc's existing content.

There is no supported way to insert native Google Docs "Suggesting mode"
edits from this skill — that would require the Docs API's suggestion-mode
`batchUpdate`, which isn't exposed by the available tools. Driving the web
UI via browser automation to fake it was evaluated during design and
rejected as too fragile for real use. A separate revised copy is the
supported path.

## Word (local only)

Uses the AppleScript helper at `scripts/word_doc.applescript`, the same
integration pattern already used for Outlook automation elsewhere in this
user's setup: read via a `get` call, write back via a `set` call.

1. **Confirm a document is open.** If ambiguous which one (multiple Word
   windows open), ask which one.
2. **Read the content:**

   ```bash
   osascript ~/Documents/wordsmith/skills/edit-doc/scripts/word_doc.applescript get
   ```

3. **Revise.** Pass the text through the `revise` skill.
4. **Write the result back.** Write the revised text to a temp file, then:

   ```bash
   osascript ~/Documents/wordsmith/skills/edit-doc/scripts/word_doc.applescript set /path/to/revised.txt
   ```

   Expected output: `OK`

5. **Report.** Tell the user the document was updated in place, and that
   only the currently-open document was touched — this never reaches
   OneDrive or SharePoint content that isn't already open locally.

## Detecting which surface the user means

- A Drive link, a mention of "Google Doc(s)", or "Doc" (capital D, in a
  Google context) -> Google Docs path.
- A mention of "Word", ".docx", or an already-open Word window -> Word
  path.
- Ambiguous ("edit my essay") -> ask which one, and if there could be more
  than one matching document either way, ask which document too.
```

- [ ] **Step 3: Make the AppleScript helper's expected companion setup verifiable without Word actually open**

Since a live Word document can't be guaranteed at plan-execution time, verify
the script is syntactically valid AppleScript (compiles) rather than running
it end-to-end here:

```bash
osacompile -o /tmp/word_doc_check.scpt ~/Documents/wordsmith/skills/edit-doc/scripts/word_doc.applescript && echo "APPLESCRIPT COMPILES"
```

Expected: `APPLESCRIPT COMPILES`

- [ ] **Step 4: Verify the SKILL.md exists**

```bash
test -f ~/Documents/wordsmith/skills/edit-doc/SKILL.md && test -f ~/Documents/wordsmith/skills/edit-doc/scripts/word_doc.applescript && echo "EDIT-DOC SKILL OK"
```

Expected: `EDIT-DOC SKILL OK`

- [ ] **Step 5: Commit**

```bash
cd ~/Documents/wordsmith
git add skills/edit-doc
git commit -m "feat: add edit-doc skill for Google Docs and local Word integration"
```

---

### Task 8: End-to-end manual validation

**Files:** none created — this task exercises what Tasks 1-7 built.

**Interfaces:** none — terminal validation task.

- [ ] **Step 1: Confirm the full tree matches the design**

```bash
find ~/Documents/wordsmith -type f -not -path "*/.git/*" | sort
```

Expected (order may vary slightly, but this exact file set):

```
/Users/mrohan/Documents/wordsmith/.gitignore
/Users/mrohan/Documents/wordsmith/AGENTS.md
/Users/mrohan/Documents/wordsmith/ATTRIBUTION.md
/Users/mrohan/Documents/wordsmith/CLAUDE.md
/Users/mrohan/Documents/wordsmith/LICENSE
/Users/mrohan/Documents/wordsmith/skills/draft/SKILL.md
/Users/mrohan/Documents/wordsmith/skills/edit-doc/SKILL.md
/Users/mrohan/Documents/wordsmith/skills/edit-doc/scripts/word_doc.applescript
/Users/mrohan/Documents/wordsmith/skills/humanizer/SKILL.md
/Users/mrohan/Documents/wordsmith/skills/humanizer/references/copy-tells.md
/Users/mrohan/Documents/wordsmith/skills/humanizer/scripts/copy_scan.py
/Users/mrohan/Documents/wordsmith/skills/revise/SKILL.md
/Users/mrohan/Documents/wordsmith/skills/structural-humanizer/SKILL.md
/Users/mrohan/Documents/wordsmith/skills/structural-humanizer/references/genre-calibration.md
/Users/mrohan/Documents/wordsmith/skills/structural-humanizer/references/storyscope-findings.md
/Users/mrohan/Documents/wordsmith/skills/structural-humanizer/scripts/structural_scan.py
```

- [ ] **Step 2: Confirm git history is clean and complete**

```bash
cd ~/Documents/wordsmith
git log --oneline
git status
```

Expected: 6 commits (scaffold, humanizer, structural-humanizer,
attribution, draft, revise, edit-doc — 7 total by this point), and
`nothing to commit, working tree clean`.

- [ ] **Step 3: Manual functional check (done by the user, in a fresh Claude Code session opened at `~/Documents/wordsmith`)**

Not automatable from this session — record as a follow-up for the user:

1. Open a Claude Code session with working directory `~/Documents/wordsmith`.
2. Ask Quill to draft a short (~150 word) piece on a test topic; confirm it
   asks about audience/length/tone/citations first.
3. Paste a paragraph containing an em-dash and a "the lesson here is"
   phrase and ask to revise it; confirm both passes visibly change the
   text.
4. If a test Google Doc is available, ask to revise it via `edit-doc`;
   confirm a new "— revised" file appears and the original is untouched.
5. If Word is open with a test document, ask to revise it via `edit-doc`;
   confirm the open document's content updates in place.

- [ ] **Step 4: Clean up the scratch clone**

```bash
rm -rf /tmp/humanizer-stack-src /tmp/sample_ai_text.md /tmp/sample_structural.md /tmp/word_doc_check.scpt
```

---

## Self-Review Notes

- **Spec coverage:** all 5 skills from the approved design
  (`2026-08-26-wordsmith-agent-design.md`) are covered — `draft` (Task 5),
  `humanizer`/`structural-humanizer` vendored verbatim (Tasks 2-3),
  `revise` (Task 6), `edit-doc` for both Google Docs and Word (Task 7).
  `CLAUDE.md`/`AGENTS.md`/`ATTRIBUTION.md`/`LICENSE` covered in Tasks 1 and
  4. The rejected "Suggesting mode" approach is documented directly in
  `edit-doc`'s SKILL.md so a future reader doesn't re-propose it.
- **Placeholder scan:** no TBD/TODO markers; every step has literal file
  content or an exact command with expected output.
- **Type/interface consistency:** `revise` is referenced by name
  identically in `draft`, `edit-doc`, and its own SKILL.md. The AppleScript
  helper's two verbs (`get`, `set`) are used identically in the helper
  script and in `edit-doc`'s SKILL.md instructions.
