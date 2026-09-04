---
description: Save a durable project rule, gotcha, workflow, or decision into .opencode/memory/ via the memory skill
agent: build
---

Load the `memory` skill and follow its procedure end-to-end.

Candidate memory:

$ARGUMENTS

If $ARGUMENTS is empty, ask the user what they want to remember before proceeding. Do not invent content.

Steps:

1. Read `.opencode/memory/MEMORY.md` if it exists. Note any entry whose `description` overlaps with the candidate.
2. Classify the candidate as `rule`, `gotcha`, `workflow`, `decision`, or `reference`. If classification is ambiguous, ask.
3. Compose the body using the schema in the skill (frontmatter + takeaway / Why / How to apply / Examples).
4. Show the proposed body to the user and ask for confirmation before writing.
5. Write the file at `.opencode/memory/<type>_<slug>.md` and append the row to `MEMORY.md`.
6. Report the saved id and remind the user to commit (`docs(memory): <type> <slug>`).

If the candidate is non-durable (one-off task, derivable from code, restatement of AGENTS.md / .semgrep/, secret, or ephemeral state), refuse with the template from the skill and explain why.
