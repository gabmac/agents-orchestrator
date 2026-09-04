---
name: memory
description: Persist a durable project fact, gotcha, workflow convention, or agent rule into .opencode/memory/ (committed to git). Triggers on — remember this, save this rule, note for future agents, persist this preference, log this gotcha. Refuses non-durable entries and refuses entries that duplicate existing repo rules (AGENTS.md, .semgrep/, etc).
---

# /memory

Operational arm of the project memory protocol. Reads `.opencode/memory/MEMORY.md`, classifies the candidate, writes one file per entry, and updates the index.

**All memory writes for this repo go through this skill.** Do not write to `.opencode/memory/` directly without updating the index in the same step.

## When to use

Invoke when the user says any of:

- "Remember this — ..."
- "Save this rule / preference / gotcha."
- "Note this for future agents."
- "Persist this so the agents remember."
- "Add to memory: ..."
- After a correction that revealed a durable project fact.
- After a non-obvious workaround took >2 messages to find.
- When an agent itself decides a piece of knowledge should outlive this session.

## When to refuse

Refuse if the candidate is:

- **One-off task instructions** ("for this PR, do X") → track in a TODO, not memory.
- **Information derivable from current code** → grep/read instead.
- **Conversation state / in-progress work** → use a plan.
- **A restatement of what's already in `AGENTS.md` or `.semgrep/`** → link instead.
- **A near-duplicate of an existing memory** → propose a new file that supersedes it (see "Superseding" below).
- **Secrets, tokens, PII, ephemeral URLs, current branch** → memory is committed.

Surface the reason so the user can rephrase if they meant something else.

## Procedure

### 1. Read the index

Read `.opencode/memory/MEMORY.md`. Scan each entry's `description` (from its frontmatter) for overlap with the candidate. Detect:

- **Conflict** — the existing memory contradicts the new candidate.
- **Duplicate** — the existing memory already says this. Refuse and reference the existing file.
- **Adjacent** — related topic, distinct rule. Note it for the new file's `Related` section.
- **Supersede** — same topic, the existing one is stale or wrong. Write a new file, update the index row, leave the old file in place (don't edit or delete it).

### 2. Classify

| Type | When | File prefix |
|---|---|---|
| `rule` | Project-wide convention, layer rule, or invariant | `rule_<topic>.md` |
| `gotcha` | Non-obvious tool behavior, library quirk, or workaround | `gotcha_<topic>.md` |
| `workflow` | How work flows here (CI commands, deploy, release, etc.) | `workflow_<topic>.md` |
| `decision` | An architectural decision and its rationale (ADR-style) | `decision_<topic>.md` |
| `reference` | Pointer to an external system (Linear, Grafana, etc.) | `reference_<topic>.md` |

If you can't classify confidently, ask the user.

### 3. Compose the body

Pick a slug: lowercase kebab-case, ≤ 40 chars, specific. `rule_diplomat_layer_order` not `rule_layers`. The full filename is `<type>_<slug>.md`.

**Frontmatter** (always):

```yaml
---
name: <short kebab-case title>
description: <one-line summary — used to decide relevance in future sessions>
type: <rule | gotcha | workflow | decision | reference>
originSessionId: <current session id if available, else "unknown">
related: [<slug-of-related-memory>, ...]
---
```

**Body structure** for `rule` / `gotcha` / `workflow` / `decision`:

1. Lead with the rule or fact — one short paragraph, the takeaway.
2. `**Why:**` — motivation, past incident, or stated user preference.
3. `**How to apply:**` — when/where the rule kicks in. Bullet list.
4. `**Examples:**` — at least one concrete example (code, command, file path).

For `reference`: free-form, but concise (≤ 30 lines). Lead with the URL/ID, then the relevant context.

Always convert relative dates ("Thursday") to absolute dates in the body.

### 4. Confirm and write

For first-time entries in a session, show the proposed body to the user before writing. For routine appends during a long session where the user has already approved the workflow, you may write directly and report what you saved.

1. Write the file at `.opencode/memory/<type>_<slug>.md`.
2. Append a row to `.opencode/memory/MEMORY.md`:
   ```
   - [<Title>](<type>_<slug>.md) — <one-line hook, ≤ 150 chars>
   ```
3. If **superseding**: leave the old file alone; insert a new row for the new file and update the old row's hook to point to the new file ("Superseded by [[new-slug]]"). Never edit or delete the old body.

### 5. Remind to commit

End by reminding the user that the memory change should land in their next commit so the team sees it. Suggested commit message: `docs(memory): <type> <slug>`.

## Loading memory.md in agents

The agents that should benefit from prior context include this in their prompt body:

```markdown
## Memory

Before answering, read `./opencode/memory/MEMORY.md` if it exists. Each row
links to a focused entry; click through only those whose `description`
matches the current task. Ignore `reference` entries unless the task
involves the referenced system.
```

This is already wired in via the project's `AGENTS.md`.

## Refusal template

> This looks like a one-off task instruction, not a durable rule — I'd track it in a TODO instead. If you meant "from now on, do X for all future Y," rephrase and I'll save it.

## Anti-patterns

- Never edit an existing memory file's body. Always supersede via a new file.
- Never write to `.opencode/memory/` without also appending to `MEMORY.md`.
- Never save a memory whose body could be inferred by reading current code, `AGENTS.md`, or `.semgrep/`.
- Never include secrets, tokens, current branch names, or ephemeral URLs.
- Never write without showing the body to the user on first use in a session.

## Related

- `AGENTS.md` — the canonical rules. Memory is for what doesn't fit there.
- `docs/llm-rules/` — additional LLM conventions. Memory complements, doesn't replace.
