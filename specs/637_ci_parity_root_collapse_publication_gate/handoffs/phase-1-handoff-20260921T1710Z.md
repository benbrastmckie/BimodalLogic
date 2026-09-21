# Phase 1 handoff (task 637)

- **State**: Phase 1 [COMPLETED], commit `234578e7e`. 21 header-linter files fixed; full probe sweep 503/503 silent; `lake build --wfail` green.
- **Next action**: Phase 2 (atomic batch): create `FormalSystem/Version.lean`, delete `FormalSystem/FormalSystem.lean`, `lake exe mk_all --lib FormalSystem`, sweep prose references, re-emit inventories, re-run the sweep from the repo root.
- **Probe**: `<scratch>/hdr637/probe.sh` (scratch-CWD, `lean --root=<repo>`); rebuildable from the plan's Phase 1 block.
- **Decisions**: plain deletion of `import Lean` sufficed (5 files); `Tactic/Attr.lean` untouched and silent.
- **Watch**: generated README inventories (INV check) go stale on any line-count change; `--emit-inventory` rewrites numeric cells, including in task 614's README territory.
- **Siblings observed**: 614 and 644 committing in their own scopes; uncommitted foreign edits in `typst/chapters/p4-dataset-pipeline.typ` and `typst/sync-check-whitelist.txt` (not this task's).
