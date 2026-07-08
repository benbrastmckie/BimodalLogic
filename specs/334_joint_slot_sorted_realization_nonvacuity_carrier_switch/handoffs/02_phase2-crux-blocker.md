# Task 334 Handoff 02 — Phase 2 crux BLOCKER (fresh-anchor / base-χ distinctness)

- **Session**: sess_1783529677_8c950d
- **Status**: PARTIAL / BLOCKED at Phase 2. Build GREEN (`lake build …SharedWitness` exit 0).
- **HEAD after this dispatch**: Phase 1 switch + reduced crux lemma committed.
- **Sorry inventory**: 2 Phase-1 scaffold (`kvE2_sepSlotsL_valid`, `kvE2_sepSlotsR_valid`) + 2
  pre-existing strategic (`kvE2_sepSingleton_coverage_left`, `kvE2_sepBody_singleton_complete_left`).
  0 vacuous defs. 0 new axioms.

## The precise obstruction

Phase 4's joint mergeSort (`πL := (kvE2_sepSlotsL qnf).mergeSort (fun a b => decide (pt a ≤ pt b))`)
produces only `pt a ≤ pt b`. The two binding cross-σ validity cases need STRICT `<`:

- **Case A**: foreign base-χ slot `a` (owner τ) before `.lX1 σ`; need `pt a < x1_σ` to place `pt a`
  in σ's OPEN zone `kvE_sub2_zXU = (x, x1_σ)` and read σ's before-fresh bit via the fold ⇐.
- **Case B**: `.lX1 σ` before foreign base-χ slot `b`; symmetric, needs `x1_σ < pt b` and zone
  `kvE_sub2_zUW = (x1_σ, w)`.

Both need `pt(base-slot) ≠ x1_σ`. The needed lemma is the UNCONDITIONAL
`kvE2_sepFreshAnchor_ne_baseChiPoint : p ≠ x1_σ` for any base-χ point `p`.

### Why it is unprovable as needed

1. **Exact reduction**: `p = x1_σ` ⟹ (by `nf_eval_nf0_cons_factor`, `NfEFold.lean:283`, which gives
   `x1_σ` realizes its own base type `nf0_projFresh σ.1`; then `nf_eval_unique`, `NormalForm.lean:245`)
   `χ = nf0_projFresh σ.1`. So the unconditional lemma ⟺ `χ ≠ nf0_projFresh σ.1` for every foreign χ.
2. **The residual is false in general**: `χ` ranges over arbitrary foreign base types
   (`kvE2_sepS τ z`); `nf0_projFresh σ.1` is σ's fresh-coordinate base type. Distinct positive owners
   may carry the same base type, and nothing forces a foreign owner's χ-witness off σ's anchor.
3. **The coincidence genuinely breaks the arrangement**: if `pt a = x1_σ`, the point is in NEITHER
   open zone `(x, x1_σ)` nor `(x1_σ, w)` (not strict), so `kvE_subBracket2_complete_extract`'s
   zone→witness channels cannot supply the fold-bit witness for EITHER placement. The single-`pt`
   mergeSort cannot separate the two owners' witnesses at a fresh anchor.
4. **No separation lemma exists**: full `WeakCanonical/` search found no fresh-vs-base / nf1-vs-nf0
   discriminator. The "E[Σ]-atom incompatible with base type at a point" intuition is UNSOUND —
   `charK = existF` (`NavigatedSpine.lean:411`) is existential; a point may satisfy both a depth-1
   fresh type and a depth-0 base type. `nfk_projFresh σ : NormalForm sig 1 1` constrains only the
   depth-1 layer, not the point's base type beyond its characteristic `nf0_projFresh σ.1`.

### What landed (reusable, sorry-free, axiom-clean)

`kvE2_sepFreshAnchor_ne_baseChiPoint` (SharedWitness.lean ~:1133) in REDUCED form — `p ≠ x1_σ` FROM
hypothesis `χ ≠ nf0_projFresh σ.1`. This is the correct, honest distinctness engine and IS reusable
by any successful resolution that can supply the base-type inequality.

## Candidate resolution directions (none confirmed; for a research sub-task)

1. **Witness avoidance**: choose χ-witnesses avoiding the finitely-many fresh anchors — needs an
   interval-infinitude/density property of `M.carrier` NOT available for a general `LinearOrder`.
2. **Global fold-bit disjointness**: prove no positive owner's before/after-fresh slot set contains
   another owner's `nf0_projFresh σ.1` — provability unknown; likely needs deep qnf structure.
3. **Non-mergeSort joint arrangement**: an interleaving whose validity does not route strictness
   through the fresh-anchor boundary (would replace the Def-3.1 strictly-increasing encoding).

## Resume guidance

- Do NOT proceed to Phases 3-7 (per plan: STOP before 4-6 if Phase 2 fails). Do NOT weaken the filter
  to vacuity.
- If a clean baseline is preferred while the crux is researched, the Phase-1 switch can be reverted
  (git) to restore `kvE2_sepBody_nonvacuous` to sorry-free; the reduced crux lemma is switch-independent
  and can be kept.
