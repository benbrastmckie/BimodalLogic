# Task 337 Phase 2 Handoff — cycle 10 (sess_1783610916_b79fd5)

## Immediate Next Action
Dispatch Phase 3 (`kvE2_sepHonest_bracket_holds`): from the Phase-2 chain delivered by
`kvE2_sepHonest_witnesses` — `psL`/`psR` with full engine `Forall₂` data, per-side bounds
`x < · < w` / `w < · < t`, and `(interleaveK psL ++ w :: interleaveK psR).Pairwise (· < ·)` —
prove the per-slot point-type realizations and the three `kvE2_sepSegs` segment families, then
close `(kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds` via
`IntervalPattern.holds_eq_succ.mpr`. This is where the per-slot `Fin (N+1)` re-indexing over
`kvE2_sepSlotsLOf/ROf wo` happens (halign trio + value-sortedness + pair pools).

## Current State
- Phases 1 AND 2 COMPLETE (plan headings updated). Phases 3-5 NOT STARTED.
- `kvE2_sepHonest_witnesses` + 5 helpers landed green + axiom-clean
  (`{propext, Classical.choice, Quot.sound}`) in SharedWitness.lean, +229/-0 additive,
  commit `e1637a864` (on top of Phase-1 `a7ea7b9dc`).
- sorry count in SharedWitness.lean: 0. Build: scoped GREEN
  (`lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`).

## Key Decisions (this dispatch)
1. **List-form chain, not Fin-indexed ws**: the Phase-2 deliverable is the stitched chain
   `interleaveK psL ++ w :: interleaveK psR` (pivot `w` at position `|interleaveK psL|`) with
   the engine `Forall₂` exposed — NOT a `Fin (|lL|+1+|lR|)`-indexed function. Rationale: the
   engine's per-gap points are dedup'd by TYPE while the bracket needs one point PER SLOT, an
   `rXW` value can fall outside `(x,w)`, and folded types are absent from gaps — so a per-slot
   index map is inseparable from Phase 3's point-type/meet-fold step (the carried-forward
   caveats). The plan checklist item is annotated as altered accordingly.
2. **Upper bound by a new dual lemma**: the stitcher `k1v_stitch_regions` only bounds below
   (`lo < y`); the new `kvE2_sepInterleaveK_lt` bounds the whole interleave strictly below a
   global `hi` given per-region `hi ≤ global hi` (from the new `kvE2_sepGapRegions_hi_le`,
   whose head case uses `List.chain_iff_pairwise` on the strict anchor chain).
3. **Skeleton transfer through `Forall₂`**: engine point lists inherit `hpos`/`hlink`/bounds
   from the regions via two private helpers — `kvE2_sepForall₂_mem_left` (left-membership
   extraction) and `kvE2_sepForall₂_chain'` (boundary-link `Chain'` transfer using the shared
   boundary equalities). Phase 3 can reuse both.
4. **Global pairwise assembly**: `List.pairwise_append` with L-block `< w` from the upper
   bound, `w <` R-block from the stitcher's lower bound at `lo = w` — `w` is the single shared
   pivot exactly as `hbdry` promised. No `x1 < e_i` literal anywhere; every bound rides
   `x`/`w`/`t` and region endpoints (F4/LITMUS preserved).

## Sorry Inventory
[] (empty — zero sorries introduced; pre-existing Boneyard/ legacy sorries and
EANegation.lean:834,1129 are out of scope and untouched)

## References
- Plan: specs/337_.../plans/04_joint-disjunct-holds-codesign.md (Phase 2 heading has the
  cycle-10 landed note; Phase 3 section is next — read its structure notes at plan lines
  287-311 before dispatching)
- Summary: specs/337_.../summaries/10_global-witness-landed-summary.md
- New declarations: SharedWitness.lean, section "Task 337 Phase 2 — global monotone bracket
  witness" (directly after `kvE2_sepHonest_engineInputs`)
- Engine: SubBracket2V.lean:633-646; structural dual `kvE2_sepDisjunct_extract` (SW:3773 area)
