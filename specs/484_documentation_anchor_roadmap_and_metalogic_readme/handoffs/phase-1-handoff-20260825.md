# Phase 1 handoff (ROADMAP A1 + D1)

**Next action**: Phase 2 — ROADMAP A2/A3 (45 constructors, nine layers), `:15`, `:354-357`, table `:363-443`.

**State**: `specs/ROADMAP.md` `:109-115` rewritten (sound direction landed / completeness open,
transcribed from `Correctness.lean:209-224`); `decide_sound'` re-cited `:66` -> `:71`;
D1 applied as a single-clause narrowing at `:27-31`.

**Verified at implementation time**: `sound_of_isValid` `Correctness.lean:100`,
`isValid_sound` `:111`, `decide_sound'` `:71`. `git diff -U0` shows exactly two hunks.

**Deviations**: the stale `**ADD, task 480**` pointer (`bridge_isvalid_bool_to_semantic_validity`)
was dropped from the rewritten bullet — its named target is exactly what landed as `isValid_sound`.

**Baselines recorded**: `check-module-invariants.sh` ALL CHECKS PASSED; `readme-lint.sh`
9 missing READMEs / 5 broken references.
