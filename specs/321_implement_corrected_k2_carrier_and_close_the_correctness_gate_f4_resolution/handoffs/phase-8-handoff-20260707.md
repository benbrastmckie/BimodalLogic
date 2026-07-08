# Phase 8 Handoff — Joint Soundness Extraction (O3)

- **Session**: sess_1783487859_3f6358
- **Date**: 2026-07-07
- **Status**: Phase 8 COMPLETED (commits 2c55cf3f1, 8c22e01c5)

## Immediate Next Action (Phase 9 = O4, MAKE-OR-BREAK, one dedicated dispatch)

For each positive σ, at the Phase-8-extracted shared `w`, derive the 6-conjunct `hgate`
bundle that `kvE_subBracket2V_correctness_pair` (`SubBracket2V.lean:1855`, bundle spec at
`:1868-1882`) and `kvE_subBracket2V_sound_of_parts` (`:1025`) require — from the joint
carrier's realized refined segments + endpoint literals. Entry points:

- `kvE2_sepBundleL_parts` gives the EXACT `(x1, hxx1, hx1t, hanchor, hbelow)` argument
  5-tuple of `kvE_subBracket2V_sound_of_parts` for each left-interior positive σ.
- `kvE2_sepDisjunct_halves` gives both halves of the count-normalized joint bracket
  realized at the shared `w` — the refined-conjunction SEGMENT realizations for the zone
  biconditionals live there (`leftPart`/`rightPart` preserve `segmentTypes` by definition,
  offset by the split index `|lL.map slotType|`).
- Re-derive an N-point analog of the zone-consistency plumbing
  (`kvE_sub2V_zone_consistent`, private `SubBracket2V.lean:1270`, template only); the
  arity-3 outer analog `kvE2_sep_zone3_consistent` (private, Phase 7) shows the case-bash
  shape.

## Current State

- `SharedWitness.lean` is now 1,393 lines (943 Phase 7 + ~450 Phase 8, append-only).
  `git diff` for Phase 8 touches ONLY this file. Full `lake build` green.
- All 10 Phase 8 public theorems axiom-clean (exactly
  `[propext, Classical.choice, Quot.sound]`); 0 sorries in the file; litmus grep 0 hits;
  no vacuous defs.

## Landed API (Phase 8, all top-level)

| Object | Role |
|--------|------|
| `kvE2_sepDisjunct_extract` | MAIN O3: realized disjunct (valid `lL`/`lR`) → `epL@x ∧ epR@t ∧ ∃ w, x<w<t ∧ ptW@w ∧ (∀ σ left-interior, BundleL at w) ∧ (∀ σ right-interior, BundleR at w)` |
| `kvE2_sepBody_extract` | Same conclusion from `(kvE2_sepBody …).holds` — NO gate hypothesis (gate-failure branch is `False` via `kvE2_sepBody_gate_fail`) |
| `kvE2_sepDisjunct_halves` | Shared-`w` pivot: `ptW@w` + `leftPart`/`rightPart` of the count-normalized bracket hold on `(x,w)`/`(w,t)` — the Lemma 5.1 kit consumed via `kvE2_sepBracket_split_at` |
| `kvE2_sepBracket_split_at` | Generic: any realized `BracketFormula (n+1)`, any index `i` → witness + point type + both halves (consumes `leftPart_holds`/`rightPart_holds`) |
| `kvE2_sepBundleL charBase charK σ M atomMap w x` | `∃ x1 ∈ (x,w)` realizing `kvE2_sepPtX1L` + every `zXU`-positive χ realized in `(x,x1)` |
| `kvE2_sepBundleR charBase charK σ M atomMap w t` | Mirror: `∃ x1 ∈ (w,t)` realizing `kvE2_sepPtX1R` + every `zWX1`-positive χ realized in `(w,x1)` |
| `kvE2_sepBundleL_parts` (needs `w < t`) | The task-326 `sound_of_parts` input 5-tuple, verbatim shapes (`⟨charK (nfk_projFresh σ)⟩` anchor, `⟨charBase χ⟩` below-witnesses) |
| `kvE2_sepBundleR_parts` (needs `x < w`) | Mirrored bounded-anchor fragment (no landed consumer — Phase 9/10 arbitration input) |
| `kvE2_sepPtX1L_anchor` / `kvE2_sepPtX1R_anchor` | `charK` head projection out of the folded fresh point types |
| `kvE2_sepCastBracket` + `kvE2_sepCastBracket_holds` | Witness-count normalization `|lL|+1+|lR| → (|lL|+|lR|)+1` (defeq under `rfl`; semantics preserved) |
| `kvE2_sepPos_mem` | `σ ∈ kvE2_sepPos qnf ↔ qnf.2 σ = true` |
| private: `kvE2_sep_getElem_mid/left/right`, `kvE2_sep_index_lt_of_rank_lt`, `kvE2_sep_{lX1,lXU,rX1,rWX1}_mem_slots{L,R}For`, `kvE2_sep_mem_arrL/R`, `kvE2_sep_arrL/R_pairwise`, `kvE2_sep_zWT3_ne_zXW3` | Structural navigation plumbing (reusable by Phase 9) |

## Key Decisions (this phase)

1. **"EVERY positive σ" read per the Phase 7 scope decision**: bundles extracted for the
   two interior classes only; non-interior positives have NO bracket slots by
   construction — their content is the σ-level `epL`/`epR`/`ptW` literals, which the
   extraction surfaces verbatim as its first two conjuncts (`epL@x`, `epR@t`) and the
   `ptW@w` conjunct.
2. **Right-interior bundles extracted anyway** (watch item honored): `kvE2_sepBundleR`
   mirrors the left bundle with `zWX1` (the `(w,x1)` region) as the below-anchor content —
   extraction is symmetric even though no landed per-σ closer serves the class yet.
3. **Positions structurally**: `x1_σ` located by slot INDEX via `List.mem_iff_getElem` +
   region-rank pairwise (`kvE2_sep_index_lt_of_rank_lt`); all bounds from `hmono`/`hrange`
   of the realized bracket (FM-x1t discipline; LITMUS-clean).
4. **Count normalization instead of `▸` casts**: `kvE2_sepCastBracket` re-types
   `BracketFormula (|L|+1+|R|)` to successor form so `leftPart`/`rightPart` apply; the
   cast equation is proved by `simp only [kvE2_sepDisjunct]; omega` (the Sigma `.fst`
   projection is opaque to bare `omega`).
5. **Defeq re-typing for point reads** (`hpt'` pattern from the private extract template):
   avoids `rw`-through-beta-redex failures; all getElem navigation via three private
   helpers matched up to proof irrelevance.

## Watch Items for Phases 9-10

- **Right-interior kit gap persists** (inherited from Phase 7): `kvE2_sepBundleR` is
  extracted but `kvE_subBracket2V_correctness_pair`/`sound_of_parts` serve `x < x1 < w`
  only. Phase 9 must either derive a mirrored consumer fragment or Phase 10 narrows scope
  (N-fragment). The F4 `ℤ` counterexample's σ'' is left-interior, so fragments stay
  testable.
- **The O4 crux residue is untouched**: bracket points inside another σ's zone are not
  covered by segment exclusions (points sit between segments). The `hgate` zone
  biconditionals must come from refined segments (via `kvE2_sepDisjunct_halves`'
  `leftPart`/`rightPart` segment content) + E[Σ]-atom literals + endpoint literals — do
  NOT patch with chain splicing (FM-merge) or `x1 < e_i` literals (LITMUS).
- **Inner nine-zone gate clause is LEFT-interior only** (`kvE2_sepGate` conjunct (iv)) —
  if Phase 9 needs the mirrored clause for right-interior `hgate`, extending
  `kvE2_sepGate` is additive and file-internal, but O1b/O2 proofs
  (`kvE2_sepGate_holds_of_honest`, non-vacuity) must be updated in the same dispatch.
- **Pre-existing task-external sorries** (not introduced, not on the task live path):
  `Kamp/Boneyard/*` (2), `Kamp/EANegation.lean:1090/:1249` (DO-NOT-EDIT F-record),
  `Kamp/KampPrior.lean:351/:354` (the strategic-sorry hook a GO verdict later rewires —
  plan Non-Goal). SharedWitness.lean itself has 0.

## Sorry Inventory

Empty. No sorries introduced in Phase 8; none inherited (Phase 7 inventory was empty).
