# Shipping Your First Managed Agent — Code w/ Claude London workshop

- **Video:** https://www.youtube.com/watch?v=lbi0rHHIoMw
- **Title:** "Anthropic Just Released the Ultimate AI Agent Guide (For Free)"
- **Speaker:** Isabella He, Member of Technical Staff, Applied AI team, Anthropic
- **Duration:** 36:49
- **Repo:** https://github.com/anthropics/cwc-workshops — subfolder `ship-your-first-managed-agent/`

> Note: this doc summarizes and quotes the talk rather than reproducing the full
> caption transcript verbatim (copyright). Timestamps below refer to the video;
> exact wording beyond the quoted lines is one click away at the video link.

## What she's saying

### 0:00–8:56 — Conceptual framing (Claude Managed Agents)

Evolution of how you build on Claude:
1. **Messages API** (2023) — raw tokens in/out. You implement every primitive
   yourself: context management, the agent loop, compaction.
2. **Agent SDK** — programmatic access to Claude Code as a harness. More
   powerful, but you still host and scale it yourself.
3. **Claude Managed Agents (CMA)** — Anthropic runs the agent loop server-side:
   sandboxing, observability, tool runtime, compaction, caching all handled
   for you. She frames this as "the fastest way to build production-ready
   agents on Claude," citing 10–15x faster time-to-production internally.

Key anecdote on why harnesses need to be centrally maintained: Sonnet 4.5
exhibited "context anxiety" — wrapping up tasks early even with context
budget to spare — which Anthropic mitigated inside the harness. When Opus 4.5
shipped, the behavior disappeared on its own, making that harness work
obsolete. Her point: maintaining a harness against model behavior changes is
real, ongoing work, which is why CMA centralizes it instead of every team
re-doing it.

Three core resources:
- **Agent** — the "brain": model, system prompt, tools, skills. Created once, reused.
- **Environment** — the "hands": the sandboxed container where tool execution happens.
- **Session** — binds an Agent instance to an Environment; the persisted unit of conversation.

Architectural decision she calls out specifically: the agent loop (brain) is
**decoupled** from tool execution (hands). Reasons given:
- Security — credentials never have to touch the model's container; vaults
  sit on a separate encrypted endpoint.
- Latency — no more spinning up a full container per session; she cites
  "over 90% reduction in TTFT for our P95 metrics."

CMA speaks in **events** (`user.message`, `agent.tool_use`, `agent.message`,
etc.) appended to a session log, not a single request/response — this is what
makes sessions resumable, streamable, and independently observable, and lets
a container crash/restart without losing the agent loop's place.

> "Harnesses should evolve alongside your agents." — on why CMA exists at all.

### 8:56–27:00 — Live coding workshop (the replicable part)

Audience clones the repo and fills in 7 stub functions in `agent.py` (from
`agent_complete.py`) to bring an offline "SRE Agent" online, wired into a
Streamlit incident dashboard. Scenario (from the repo's README): a checkout
service commit at 14:31:18 UTC replaces a batched DB query with per-row
iterations; p99 latency climbs 65ms → 3,600ms, connection pools saturate, ~20%
of checkouts fail.

She demos it live twice (first attempt fails, second succeeds) — the agent
calls its sandbox bash tool to inspect the mounted log, calls local tools
(`get_recent_deploys`, `get_metrics`, `get_diff`), and returns a root-cause
finding: a commit from "Alice" refactoring the order-summary builder
introduced a query that exhausted the DB connection pool, plus recommended
actions. She notes the natural next step — giving the agent Cloud Code access
and PR-creation ability — is out of scope for the demo but clearly implied as
where this goes.

Also demoed live: session persistence across a hard page refresh, and
deleting a session (which also purges its logs) as a proactive
security/data-retention control.

### 27:00–36:49 — Recap + "beyond the basics"

Recaps the event/session/local-tool/persistence model, then names — without
demoing — the advanced CMA surface:
- **Sub-agents / multi-agent** — an orchestrator agent spins up sub-agents
  with their own context windows for parallelization and context management.
- **Memory + "dreaming"** — a service where Claude reviews its own memory
  logs and decides what to retain, aimed at self-improving agents that learn
  user preferences/corrections across sessions.
- **Outcomes** — define a rubric for what the agent should produce; the agent
  figures out which tool calls get it there, instead of just executing calls
  with no tie to a desired result.
- **Vaults** — encrypted, per-user/per-session credential storage on a
  separate endpoint from the agent, relying on the brain/hands separation
  described earlier.
- Briefly mentioned without detail: webhooks (resume/trigger sessions on
  external events), fine-grained permission policies, new MCP server
  controls, and a console-based agent builder with an observability
  dashboard.

## How to replicate their work

Repo is public; contents below are pulled directly from source, not
transcribed off screen.

### Setup

```bash
git clone https://github.com/anthropics/cwc-workshops
cd cwc-workshops/ship-your-first-managed-agent
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env      # put your ANTHROPIC_API_KEY in it
streamlit run app.py
```

`requirements.txt`: `anthropic>=0.97.0`, `streamlit>=1.40.0`, `plotly>=5.20.0`,
`python-dotenv>=1.0.0`. First run auto-generates `data/app.log`.

### The 7 functions in `agent.py`

Each one teaches a single Managed Agents concept — ~38 lines total per the README.

1. **`setup_agent()`** — creates a custom skill from `incident-triage-runbook/`
   (`client.beta.skills.create(display_title=..., files=files_from_dir(...))`,
   title suffixed with a uuid since `display_title` must be unique per org),
   then creates the Agent:
   ```python
   agent = client.beta.agents.create(
       name="SRE Agent",
       model="claude-opus-4-8",
       system=SYSTEM,
       tools=TOOLS,
       skills=[{"type": "custom", "skill_id": skill.id, "version": "latest"}],
   )
   ```
2. **`setup_environment()`**:
   ```python
   env = client.beta.environments.create(
       name=f"sre-agent-{uuid.uuid4().hex[:6]}",
       config={"type": "cloud", "networking": {"type": "unrestricted"}},
   )
   ```
3. **`upload_log()`** — pushes `data/app.log` via `client.beta.files.upload(file=open(...))`.
4. **`start_session(agent_id, env_id, log_file_id)`**:
   ```python
   session = client.beta.sessions.create(
       agent=agent_id,
       environment_id=env_id,
       resources=[{"type": "file", "file_id": log_file_id, "mount_path": "app.log"}],
   )
   ```
5. **`stream_reply(session_id, user_text)`** — opens
   `client.beta.sessions.events.stream(session_id)`, sends a `user.message`
   event, and on each streamed `agent.custom_tool_use` event calls
   `handle_tool()` and posts a `user.custom_tool_result` back into the same
   stream, yielding all events for the UI.
6. **`handle_tool(name, args)`** — the actual local tool implementations
   (`get_metrics`, `get_recent_deploys`, `get_diff`) answering from JSON
   fixtures in `data/`. This is the brain/hands split in miniature: the cloud
   agent decides to call a tool, your process executes it and returns a
   result.
7. **`delete_session(session_id)`** — `client.beta.sessions.delete(session_id)`.

### Pre-built, not touched (`provided.py`)

- System prompt: the agent is told it's an "SRE Agent... embedded in an
  incident dashboard," that the log is mounted at
  `/mnt/session/uploads/app.log` and is large ("use grep/python... don't read
  it whole"), and to "correlate evidence and state findings plainly and
  concisely."
- `TOOLS` list — includes the built-in sandbox toolset
  (`{"type": "agent_toolset_20260401", "default_config": {"enabled": True}}`,
  i.e. bash/sandbox access) plus the three custom tool schemas
  (`get_metrics`, `get_recent_deploys`, `get_diff`).
- A full Streamlit `chat_panel()`: session picker, history replay via
  `client.beta.sessions.events.list()`, and live rendering of the event
  stream (tool-call boxes with args/results, streaming assistant text).

### Extending beyond the workshop (named, not demoed — treat as pointers into Anthropic's docs)

- Add a runbook-fetching skill for real postmortems (this is literally what
  `incident-triage-runbook/` already is — a custom skill).
- Swap `get_metrics` from local JSON to a real DataDog client — same wire
  protocol, per her comment.
- Add sub-agents for parallelized investigation.
- Wire up memory/dreaming for cross-session learning of user
  preferences/corrections.
- Define an outcomes rubric instead of open-ended chat.
- Use vaults instead of hand-rolling credential storage.
- Give the agent Cloud Code access + PR-creation ability to close the loop
  from "diagnose" to "fix."
