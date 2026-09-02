# Task 521 — Phase 2 handoff checkpoint

## State at write time
- Phase 1 COMMITTED (`9cd75e280`): `FormalSystem/Automation/TruthNormAttr.lean` created
  (`truth_norm`, `swap_norm`, `truth_simp` macro), `baseline.txt` + `measure.sh` written.
- Phase 2 edits APPLIED, not yet committed: Truth.lean (+11 lemmas untagged, `@[truth_norm]`
  tags, "Simp-normal form" docstring section, import), Formula.lean (import + `attribute
  [swap_norm]` over the eleven `swap_temporal_*`).
- Phase 5 edits APPLIED, not yet committed: `validOn_iff_total` moved from
  `Correspondence/FwdRec.lean` to `Semantics/Validity.lean` as `TaskFrame.validOn_iff_total`;
  3 references updated (FwdRec :84, FwdRecBridge :158, doc bullet removed).
- Both files elaborate under `lake env lean`. Full `lake build` in flight (near-total rebuild:
  Formula.lean is deep in the dependency chain; ~430 modules).
- `FormalSystem/Scratch521.lean` is a temporary reachability probe — **delete before commit**.

## Immediate next action
1. Read the in-flight build result. If green, delete `FormalSystem/Scratch521.lean`, mark
   Phases 2 and 5 `[COMPLETED]`, commit both.
2. Phase 3: add `@[simp]` to the ten new lemmas + `attribute [simp] bot_false imp_iff box_iff`.
   PLANNED DEVIATION: land Phase 7's three Truth.lean lemmas in the same edit (purely additive,
   cannot strand a proof) so the tree pays one full rebuild instead of two. Phase 7 then becomes
   Soundness.lean-only.

## Measured baseline (all plan hypotheses confirmed except two, recorded in baseline.txt)
- (A) eleven named decls: 14 sites, 298 lines. Target <=2 sites.
- (B) Soundness 67, CoValidity 1, Truth 19, BLTruth 5, other four scoped files 0. Tree-wide 199.
- Bare-simp audit regenerated at 258 lines, NOT the plan's 48 (superset; still a valid upper
  bound on Phase 3 blast radius).
