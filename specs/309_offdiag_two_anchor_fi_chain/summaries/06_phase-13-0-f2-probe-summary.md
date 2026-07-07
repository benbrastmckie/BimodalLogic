# Task 309 Phase 13.0 Summary — F2 Decision Probe (2026-07-06)

## Verdict

**F2 CONFIRMED — fully machine-checked.** The UZ/SZ-relativized k=2 correctness statement for
the current carrier `bracketEndChar_kv` (NfMultiAnchorBridge.lean:3630) is FALSE, for every
provider family `charF`. The verdict theorem is
`Bimodal.Metalogic.WeakCanonical.Kamp.f2_relativized_refutation` — sorry-free, `lean_verify`
axioms exactly `[propext, Classical.choice, Quot.sound]`.

**Routing consequence (plan v6 three-way gate)**: proceed to Phase 13.1 and the FULL ladder
13.2 → 13.3 → 13.4 → 14. No surgery-only collapse; no kv-gate strengthening.

## Phase executed

Phase 13.0 only (single-phase dispatch, per orchestrator contract). v6 heading count now
11 of 16 (1-5, 6.1, 9-12, 13.0 complete; 13.1-13.4, 14 remain).

## What was proved (all in NfMultiAnchorBridge.lean, additive, after the F1 record)

1. **Prior model**: `F2M` = `(ℤ, <)` with `P = {0, 10, 20}`; `f2_UZ`/`f2_SZ` machine-check
   `semantic_prior_UZ`/`semantic_prior_SZ` (PriorDefs:22/:33) via ℤ least/greatest-element
   principles (`f2_int_first`/`f2_int_last`, `Nat.find`). This closes the F1-model escape
   route (F1's `(ℚ, <)` with finite `P` fails UZ).
2. **The F-B pair**: `f2qnf` (depth-2 characteristic 3-type of `[15, 2, 18]`, realized at
   `w = 15`), `f2sub1`/`f2sub2` (the `u₁ = 12` / `u₂ = 4` depth-1 arity-4 subs), `f2qnf'`
   (`qnf` with `sub₂` un-marked).
3. **Channel agreements** feeding `bracketEndChar_kv_factors`: `f2_sub_atom_eq` (shared atom
   layer), `f2_sub_proj_eq` (shared depth-1 fresh point type via the realized-2-type transfer
   `f2_proj2_iff`), `f2_hoff`, `f2_hb` — giving `f2_carrier_eq`: the carrier cannot
   distinguish `qnf` from `qnf'`. Distinctness `f2_sub_ne` via the entry `e*` =
   "`P z ∧ x < z < u`".
4. **No witness**: `f2_no_witness` — no `w'` realizes `qnf'` in `M*`: atom layer pins
   `w' ∈ (2, 18) \ P`; `f2_sub1_forces` pins `w' ≥ 12`; `f2_sub2_transfer` (cell-by-cell via
   `f2_congr5_wshift`) realizes the un-marked `sub₂` at `u = 4` for all `12 ≤ w' ≤ 16`;
   `w' = 17` dies on the discrete-gap type `f2tau`.
5. **Verdict theorem**: `f2_relativized_refutation` + the N1/N2/N3-compliant F2 verdict
   doc-block (leading with the Def 3.1 evidence per rule N3).

## Report-05 caveat resolution

The honest caveat (discreteness makes gap-emptiness depth-1-visible, so the per-entry
type-match check might fail) resolved AFFIRMATIVELY: the check SUCCEEDS on `12 ≤ w' ≤ 16`
(one point beyond the report's density sketch) and the discrete-gap type `τ` covers `w' = 17`.

## Final verification

- `lake build` full tree: GREEN (1705 jobs).
- Sorries in probe material: 0. New live-path sorries: 0 (census cross-checked; all remaining
  census entries pre-date this dispatch).
- Vacuous definitions introduced: 0 (the single repo-wide grep hit,
  Examples/TemporalStructures.lean:269, pre-dates this dispatch).
- Axiom count: 2 (unchanged baseline; both in Boneyard).
- `lean_verify` on `f2_relativized_refutation` and `f2_no_witness`: exactly
  `[propext, Classical.choice, Quot.sound]`, no warnings.
- Additive-only: git diff vs dispatch base shows 1 Theories file, 822+ insertions,
  0 deletions — `bracketEndChar_kv`, the F1 record, and every preserved asset byte-identical.

## Plan deviations

None in substance; one over-delivery: the plan allowed an UNSETTLED outcome or a
comment-record with partial checked lemmas; the dispatch closed the full refutation
(≈890 lines vs the 80-200 estimate, justified by the decision-gate value of a fully checked
verdict). One additive Mathlib-free project import (`PriorDefs`) added to
NfMultiAnchorBridge.lean with a house-style NOTE (cycle-free, verified).

## Sorry inventory

Unchanged from the prior handoff (no new sorries): KampPrior:351 (strategic, Phase 14),
KampPrior:354 (strategic, task 305), EANegation:1090/:1249 (pre-existing, outside scope).
