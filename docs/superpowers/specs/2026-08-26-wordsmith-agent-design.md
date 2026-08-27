# Wordsmith — Writing Agent Design

**Date:** 2026-08-26
**Status:** Approved

## Purpose

A standalone Claude Code project at `~/Documents/wordsmith/`, separate from the
`my-agent` (JZ) project, specialized in writing school/academic work and
general essays/blog posts. It drafts new pieces from a topic or outline, and
revises existing drafts (including ones already sitting in Google Docs or an
open Word document) to remove detectable AI writing signatures.

This is a new, independent project — its own `CLAUDE.md`, `AGENTS.md`, and
`skills/`. It does not integrate with JZ's email/project-tracking role.

## Persona

**Quill** — direct, craft-focused. No unsolicited praise of the user's
writing, no padding. Tone default: plain and efficient for planning/status,
matches the register of the piece itself when drafting or revising prose.

## Scope

In scope:
- Drafting new essays / blog posts / academic writing from a topic or outline
- Revising/humanizing existing drafts (pasted in, or pulled from Google Docs
  / a locally open Word document)
- The two-pass humanization pipeline vendored from
  [humanizer-stack](https://github.com/NulightJens/humanizer-stack)

Out of scope:
- Fiction/creative writing, business/marketing copy (not requested)
- Sending, submitting, publishing, or emailing anything on the user's behalf
- Editing documents in true native "Suggesting mode" inside Google Docs — no
  available tool supports the Docs API's suggestion-mode `batchUpdate`, and
  driving the web UI via browser automation to fake it was evaluated and
  explicitly rejected as too fragile. Google Docs output is always a
  separate, clearly-labeled revised copy.
- Reaching Word documents that aren't already open locally (no OneDrive/
  SharePoint remote access — Microsoft 365 MCP requires an account the user
  doesn't have through school)

## Architecture

```
~/Documents/wordsmith/
├── CLAUDE.md              # persona + operating instructions (Quill)
├── AGENTS.md               # hard rules (source of truth, mirrors my-agent's pattern)
├── ATTRIBUTION.md          # MIT credit to humanizer-stack + StoryScope citation
├── LICENSE                 # MIT, for wordsmith's own original code
└── skills/
    ├── draft/
    │   └── SKILL.md
    ├── humanizer/                    # vendored from humanizer-stack, Pass 1
    │   ├── SKILL.md
    │   └── references/
    │       └── copy-tells.md
    ├── structural-humanizer/         # vendored from humanizer-stack, Pass 2
    │   ├── SKILL.md
    │   ├── references/
    │   │   ├── storyscope-findings.md
    │   │   └── genre-calibration.md
    │   └── scripts/
    │       └── structural_scan.py
    ├── revise/
    │   └── SKILL.md
    └── edit-doc/
        ├── SKILL.md
        └── scripts/
            └── word_doc.applescript   # osascript helper for local Word docs
```

## Skills

### `draft`
Takes a topic, outline, or prompt and produces a new piece. Before writing,
asks (in one pass, not interrogation-style) about: audience, target length,
tone/register, and whether citations/sources are required. If citations are
required, only cites sources actually provided or found — never fabricates
one (see hard rules).

### `humanizer` (vendored, Pass 1)
Surface-level de-AI-ification: em-dashes, promotional/inflated language,
vague attribution, AI-specific word choices. Ported as-is from
humanizer-stack's `skills/humanizer/`, including its `copy-tells.md`
reference and the standalone `copy_scan.py` deterministic scanner (kept at
`skills/humanizer/scripts/copy_scan.py` in the new project, adjusting the
path reference from the original repo's top-level `scripts/`).

### `structural-humanizer` (vendored, Pass 2)
Six structural audits: theme explicitness, structural tidiness, emotion
presentation, reference specificity, reader engagement, shape consistency.
Ported as-is from humanizer-stack's `skills/structural-humanizer/`, including
`structural_scan.py` and both reference docs. Per the source repo's own
caveat, these are applied selectively and with variation — not uniformly
across every piece — to avoid creating new detectable patterns.

### `revise`
Orchestrates the full pipeline on a piece of text (freshly drafted or
user-supplied): `humanizer` (Pass 1) → `structural-humanizer` (Pass 2) → a
final read-through pass. This is the general "make this sound human" entry
point when the user isn't going through `edit-doc`.

### `edit-doc`
Entry point for revising a document that lives in Google Docs or is open
locally in Word, rather than pasted text.

- **Detection:** if the user's request doesn't make clear which surface they
  mean (Google Doc vs. Word), ask.
- **Google Docs:** find the file via `mcp__claude_ai_Google_Drive__search_files`
  (or take an ID/link directly), read its content with
  `read_file_content`/`download_file_content`, run it through `revise`, then
  create a new Doc via `create_file` titled `"<original title> — revised"`.
  The original file is never modified. The user is told the new file's name/
  location and can merge or discard it themselves.
- **Word:** uses an `osascript`/AppleScript helper (same integration pattern
  as JZ's existing Outlook automation) to read the text of the frontmost/
  target open Word document and, after producing the revision, write it back
  into that same open document directly — no duplicate needed since it's
  local and the user is present to undo/review live. Only ever touches a
  document that is already open in the local Word app; never reaches
  OneDrive or SharePoint.

## Hard Rules (`AGENTS.md`)

Mirrors `my-agent`'s pattern of a single source-of-truth hard-rules file that
`CLAUDE.md` inherits without duplicating:

- Never fabricate citations, sources, quotes, or data. If a claim needs a
  citation that wasn't provided or found, say so rather than inventing one.
- Never overstate factual basis — don't present a claim as more certain or
  better-sourced than the input actually supports.
- Never send, submit, publish, or email anything on the user's behalf.
  Output is always a file or chat text; the user decides where it goes.
- Never touch a Google Doc other than by creating a new, separate revised
  copy — never overwrite or modify the original file's content.
- Never reach Word documents beyond what's already open locally.
- Apply humanizer passes selectively/with variation (per humanizer-stack's
  own finding that uniform application creates new detectable patterns) —
  not as a rigid checklist run identically on every piece.

## Attribution

`ATTRIBUTION.md` credits humanizer-stack (MIT) as the source of the
`humanizer` and `structural-humanizer` skills verbatim, and cites the
StoryScope study (Russell et al. 2026) that `structural-humanizer`'s
approach is grounded in, per the original repo's own attribution file.

## Testing / Validation

- After scaffolding, run `draft` on a short sample topic and confirm it asks
  the right clarifying questions before writing.
- Run `revise` on a sample AI-sounding paragraph and confirm both passes
  visibly change surface and structural patterns.
- Run `edit-doc` against a real (test) Google Doc to confirm a new "—
  revised" copy is created correctly and the original is untouched.
- Word path validated manually by the user, since it depends on Word being
  open locally at test time.
