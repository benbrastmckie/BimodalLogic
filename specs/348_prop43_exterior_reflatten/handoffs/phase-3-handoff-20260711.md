# Task 348 Phase 3 Handoff (2026-07-11) — Future-side clause family COMPLETE

## Immediate Next Action

Phase 4 (Wave 3, unblocked): `kvE2_extNegFut_complete` for all `zFutT3`-marked σ under the
Phase-2 pins `(hxw, hwt, henv, hbelow)` PLUS the two syntactic σ-side hypotheses recorded in
`progress/phase3-fut-clause-family.md` (`nf0_dropFresh σ.1 = qnf.1`; below-bits =
`kvE2_futAnyBit qnf`). Before stating it, read OuterGate.lean:147
`bracketEndChar_kvE2_complete_two_prior` consumption shape (read budget: that theorem + the
fold's per-σ biconditional only). Phase 5 (past-side mirror, `ExteriorNegationPast.lean`)
may run in parallel (disjoint territory).

## Current State

- Phase 3 of 8 COMPLETED. Phases 1, 2, 3 done; 4-8 pending (4 ∥ 5, then 6, 7, 8).
- Full `lake build` GREEN (1721 jobs). Zero sorries in task files. Axioms on all delivered
  AND preserved lemmas = `{propext, Classical.choice, Quot.sound}`.
- `ExteriorNegation.lean` now 1323 lines (+483); new import: `ExteriorZoneTriage` (additive).
- Commit: a2c4a2552.

## Key Decisions (Phase 3, within the Phase-2 binding signature — H6 clean)

1. **Clause shape**: `kvE2_extNegFut atomMap h_surj σ = (kvE2_futPos σ).neg`; `kvE2_futPos` =
   `if kvE2_futAdmissible σ then formula_disjList (permutations of gap-list chains) else ⊥`.
   The permutation disjunction over `kvE2_futChain` (D-guarded Until nest ending in
   `kvE2_futEnd`) is the Cor 5.4 O_n device at general finite gap content; the spike is the
   `S_gap = {χmid}, S_ray = ∅` instance. No qnf parameter (as in the spike clause).
2. **Admissibility gate is load-bearing both ways**: soundness proves a realizer FORCES the
   gate (`kvE2_futRealizer_admissible`, order bits only — zone marking via Phase 1's
   `kvE2_exterior_zone_determination_fut`); Phase 4 gets gate-truth for free from a true
   positive form (else-branch is `⊥`).
3. **Soundness strengthened**: `kvE2_extNegFut_sound` holds for ALL σ (no marking
   hypothesis), under exactly `(hxw, hwt)`. Signature drift from Phase 2: NONE.
4. **Ray content generalized**: exact-ray-content `kvE2_futRayForm` = `¬F(¬D_ray) ∧
   ⋀_{χ∈S_ray} F(char χ)`; the spike's `¬F⊤` is the `S_ray = ∅` instance (every point has a
   profile, so profile-exhaustion = emptiness).
5. **`HasAttainedINF` still not needed**: chains are finite (length = |gap list| ≤ alphabet)
   and unbounded content never arises at this rung. Phase 4 budget note stands.

## Sorry Inventory

Empty for task 348. (Pre-existing out-of-scope: KampPrior.lean strategic sorry — 309-owned
per plan R1; EANegation.lean:834/:1129 pre-existing; Boneyard/BXCanonical/Expressiveness
pre-existing, unrelated.)

## References

- Plan: `specs/348_prop43_exterior_reflatten/plans/01_prop43-exterior-reflatten.md`
  (Phase 3 [COMPLETED] with per-task annotations; Phase 4/5 next).
- Progress: `specs/348_prop43_exterior_reflatten/progress/phase3-fut-clause-family.md`
  (includes the recorded Phase-4 obligations).
- Prior handoffs: phase-2-handoff-20260711.md (binding signature), phase-1-handoff (triage).
