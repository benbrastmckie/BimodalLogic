# Task 309 Phase 15 Summary — Site/Coverage Probe (DECISION GATE)

- **Date**: 2026-07-11
- **Session**: sess_1783796165_b5b482_309
- **Plan**: plans/09_offdiag-fi-chain-v9.md, Phase 15 → [COMPLETED]
- **Verdict**: **GO-k1** (with corrected arm indexing — see below)

## Phase Executed

Phase 15 only (single-phase hard-mode dispatch): machine-establish F-i (fragment coverage) and
F-ii (depth-ladder wiring) at the `KampPrior.lean:361` site, land the green site-shape lemmas,
record the routing verdict.

## Theorems Delivered (all sorry-free, all axioms exactly `[propext, Classical.choice, Quot.sound]`)

Appended at end of `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (the
`:361`/`:364` line citations preserved):

1. `kampPrior_site_env_bridge` — the `Fin 1` env bridge (`h_env_eq` extracted as a named lemma).
2. `kampPrior_site_trichotomy` — past/diagonal/future split of the site RHS
   (consumes `nf_zone_exists_trichotomy_k1`).
3. `kampPrior_site_perQnf_seam` — the named per-`qnf` obligation (`Iff.rfl`): at match-arm `k`,
   `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` over `qnf : NormalForm sig k 3` — depth `k`.
4. `kampPrior_site_rung0_match` — arm-0 certificate (unconditional rung-0).
5. `kampPrior_site_rung1_match` — arm-1 certificate (unconditional rung-1) — the F-i certificate
   for the depth-2 instance.
6. `kampPrior_site_rung2_gate_match` — arm-2 certificate: the 348 enriched gate
   `bracketEndChar_kvE2Ext_correct_two_prior_frag` types verbatim at the k=2 arm (hypotheses
   restated exactly; `hexclExt` internal, V9-2 honored).
7. `kampPrior_site_fragment_qnf_exists` — F-i positive exhibit (fragment scope non-empty).
8. `kampPrior_site_nonfragment_qnf_exists` — F-i negative exhibit (two-interior-positive
   witness; fragment complement non-empty → 321-N2 residue per option (a)).

Plus the in-file VERDICT RECORD comment block (house style of 13.0/13.3/13.35, Def 3.1 lead).

## Verdict Detail

- **F-i**: COVERED at the k=1 arm, vacuously — the depth-2 instance's per-`qnf` population is
  `NormalForm sig 1 3`, served by the UNCONDITIONAL `bracketEndChar_kv_correct_one_prior`;
  `kvE2_sepFragment` does not type-apply at depth 1.
- **F-ii**: rung-index = arm-index. Arms 0/1 unconditional; arm 2 = the kvE2Ext gate
  (fragment-scoped); arms ≥ 3 have NO landed rung → symbolic-k gate family required → the
  pre-committed GO-k1 residual routing, now narrowed to arms k ≥ 3.
- **Corrected arm indexing (binding on Phases 16-19)**: the gate's consumption point is the
  k=2 arm (depth-3 obligations), not the k=1 arm; Phase 18's depth-2 instance closes via
  rung-1 with no fragment condition; Phase 19's strategic-sorry residual is arms k ≥ 3.

## Final Verification

- Scoped build: GREEN (1021 jobs). Full-tree build: GREEN (1724 jobs = baseline).
- Sorries in territory: exactly the two pre-existing strategic targets (`:361` Phases 18-19;
  `:364` task 305). New material: 0 sorries.
- Vacuous definitions: 0. New axioms: 0.
- Frozen provider files (V9-1): byte-unchanged. No `hexclExt` reference in new material (V9-2).

## Plan Deviations

- None against Phase 15's own spec. The verdict CORRECTS the plan's informal arm labeling
  (recorded in the plan's Phase-15 verdict block and the in-file record); the plan's
  pre-committed GO-k1 routing absorbs this refinement without re-planning.

## Commits

- `765054d5a` — task 309 phase 15.1: site lemmas + depth-ladder certificates + fragment exhibits
- (final) — task 309 phase 15: site/coverage probe — fragment triage + depth-ladder verdict
