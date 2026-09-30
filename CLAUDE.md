# Task routing
- Delegate simple, low-risk tasks (file lookup, small edits, renames, formatting, single commands) to the `quick-task` subagent.
- Delegate hard tasks (non-obvious debugging, architecture, large multi-file refactors, security-sensitive work) to the `deep-task` subagent.
- Handle medium tasks directly in the main session.
