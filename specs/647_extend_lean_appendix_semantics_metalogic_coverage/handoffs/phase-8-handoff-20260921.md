# Phase 8 Handoff

- Next action: Phase 9, project overview and directory tour in `lean-appendix-lake`, consuming
  the new `status.typ` bindings via an `#import` addition.
- Done, as one atomic batch: `scripts/typst-status-counts.sh` emits three version pins
  (`lean_toolchain_pin`, `mathlib_tag`, `mathlib_rev`) and six per-tree scale figures in BOTH
  the `--json` payload and the `status.typ` write path, all filesystem reads so `--json` still
  runs build-free. `scripts/typst-sync-check.sh` Check 2 gained the six integer keys in
  `scalar_fields` and a NEW `string_fields` comparison path for the three pins, since the
  existing path matches `(\d+)` only. `typst/generated/status.typ` regenerated.
- Perturbation test, both halves recorded: `formalsystem-line-count` set to 999999 produced
  `VIOLATION: formalsystem-line-count: committed=999999 live=283236` and FAIL;
  `mathlib-tag` set to `v0.0.0-bogus` produced
  `VIOLATION: mathlib-tag: committed=v0.0.0-bogus live=v4.33.0-rc1` and FAIL. Restoring each
  returned MISMATCH_COUNT=0 and PASS.
- The `FormalSystem.lean` import-count cross-check is kept and currently agrees (524 = 524). It
  warns on stderr rather than aborting, so an unrelated `mk_all` drift cannot brick the sync
  check and hide every other figure it polices.
- CONCURRENCY NOTE for Phase 10: another task is committing Lean source during this run, and
  the `Tests/` and `FormalSystem/` counts moved twice mid-phase. `status.typ` must be
  regenerated immediately before the final commit, and the generator's write path needs a built
  library (it failed once mid-phase with "Run 'lake build' first" while a source file was being
  edited).
- Deviation annotated on the plan: the repo-wide tracked-file count was dropped.
