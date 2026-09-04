# Memory Index

This file lists the project's durable rules, gotchas, workflows, decisions, and
references. Each row links to a focused entry. New entries are appended at the
bottom by the `/memory` command.

- [Integration tests: one scenario per setup](rule_integration_tests_one_scenario_per_setup.md) — BDD rule; one test function per scenario, never split assertions for the same setup across multiple defns.
- [Integration tests: Gherkin comments](rule_integration_tests_gherkin_comments.md) — `;; When` and `;; Then` describe the action and outcome; `;; Given` only when there is real setup beyond imports.
