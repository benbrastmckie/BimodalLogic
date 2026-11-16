# Phase 11.43 handoff — the branching-pending fixture `B5` landed (outcome (a))

**Status**: Phase 11.43 `[COMPLETED]` (plan v26, dispatch 76). 56 of 69 phase headings (plan v26 added three; the dispatch's "55 of 66" predates them) closed.

**Immediate next action**: dispatch Phase 11.44 — state the object-dependent threshold relation
(`Mrel`) and ATTEMPT TO REFUTE the path forth from it on `R4` AND on `B5`, before any proof
attempt. Any statement over `B5` carries `6 ∣ P + 1` (from `two_mem_objCycleLens_B5` and
`three_mem_objCycleLens_B5`) as a hypothesis; it is not a parameter condition.

**Current state**:
- Probe `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` is 827
  lines (568 at entry; 259 appended, 0 edited). The `B5` block is lines 569-827, in a re-opened
  `namespace ProbeRowResidue`.
- Landed: `B5`, `stepB`, `pendB`, `branching_pendB`, `two_mem_objCycleLens_B5`, `cyc3B`,
  `three_mem_objCycleLens_B5`, `fwdB`, `bwdB`, `walkB`, `pendB_walkB`, `gB`, `gB_isLadderPath`,
  `gB_takes_both_branches`, `cntAt_gB_neg`, seven `#guard_msgs` axiom pins.
- No library module edited. Full build exit 0 (2976 jobs); evidence gate PASS (65 wired, unchanged);
  verify-deploy PASS.
- Record: `records/round-26-threshold-relation-verdict.md` section 1.

**Key facts for 11.44**:
- `exists_path_through fwdB bwdB x z` gives a ladder path through any `B5` ladder state.
- `stepB idle q` holds only at `q = idle`: a pending region is never entered from idle, so every
  pending position has an all-pending past.
- There is NO `B5` analogue of `objAt_rot`/`stepR_pend` — by design the walk is not forced. A
  refutation over `B5` must quantify over the second path's walk; a path forth may choose it.

**Deviations**: the block is appended at end of file in a re-opened namespace rather than
physically after the `R4` block (whose namespace is closed before the headline's axiom pin).
Two lemmas beyond the five items (`gB_takes_both_branches`, `cntAt_gB_neg`), both non-vacuity.
