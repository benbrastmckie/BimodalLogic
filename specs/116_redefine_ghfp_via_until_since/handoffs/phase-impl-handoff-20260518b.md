# Task 116 Implementation Handoff

## Session: sess_1779150566_0009bb
## Date: 2026-05-18

## Completed Work

### Build Errors Fixed (3 files, all now building)

1. **RestrictedParametricTruthLemma.lean**: Removed invalid `| all_future` / `| all_past` match arms from two induction proofs. These are now handled by the generic `imp` case.

2. **Frame.lean**: Simplified `g_content_set_consistent` and `h_content_set_consistent`. Old proofs went through `G(neg_top)` intermediate; new proofs use the definitional equality `G(bot) = neg(F(top))` directly.

3. **SuccRelation.lean**: Rewrote 4 lemmas that relied on `F(phi) = neg(G(neg phi))` being structurally `rfl`:
   - `G_neg_implies_not_F`: Uses BX3 event monotonicity + DNE + contrapositive
   - `neg_FF_implies_GG_neg_in_mcs`: Complete rewrite with BX3 double-application chain
   - `H_neg_implies_not_P`: Mirror using BX3' + past necessitation
   - `neg_PP_implies_HH_neg_in_mcs`: Mirror of future version

### SoundnessLemmas.lean (15 of 21 sorries eliminated)

- **axiom_swap_valid** (370-line proof): Restored from commented-out code with fixes:
  - `temp_k_dist`: Added `Truth.past_iff` rewrite
  - `serial_future/past`: Provide guard `fun _ _ _ h => h` for expanded `some_future/some_past`
  - `left/right_mono_until_G/since_H`: Use `Truth.future_iff`/`past_iff` to convert `all_future`/`all_past` to quantifiers
  - `connect_future/past`: Use characterization theorems for G/H + F/P
  - `temp_linearity/past`: Complete rewrite with 4-component existentials
  - `until_F/since_P`: Weaken guard to top
  - `discrete_propagate_fwd/bwd`: Use `Truth.future_iff`/`past_iff` for G/H wrappers

- **axiom_locally_valid**: Same fixes applied to the non-swap version
- **Helper theorems fixed**: `axiom_density_valid`, `axiom_modal_future_valid`, `axiom_temp_l_valid`, `axiom_temp_linearity_valid`, `axiom_temp_linearity_past_valid`, `axiom_F_until_equiv_valid`, `axiom_P_since_equiv_valid`

### Truth.lean Enhancement

Added `@[simp]` attribute to 4 characterization theorems:
- `Truth.some_future_iff`, `Truth.some_past_iff`, `Truth.past_iff`, `Truth.future_iff`

## Remaining Work

### SoundnessLemmas.lean (6 sorries)

1. **`axiom_swap_valid_general`** (line ~1515): Identical to `axiom_swap_valid` but without `[DenselyOrdered D]`. Fix: uncomment and apply same temporal case fixes.

2. **`axiom_locally_valid_general`** (line ~1845): Same as `axiom_locally_valid` without `[DenselyOrdered D]`. Fix: uncomment and apply same fixes.

3. **`prior_UZ_is_valid`** (line ~2183): Discrete axiom `F(phi) -> U(phi, neg phi)`. Fix: add `Formula.some_future, Formula.top` to simp set, adjust existential for 4-component form.

4. **`prior_SZ_is_valid`** (line ~2228): Past mirror of prior_UZ. Same fix pattern.

5. **`z1_is_valid`** (line ~2274): Discrete Zorn axiom. Fix: use `Truth.future_iff`/`some_future_iff` rewrites.

6. **`z1_past_is_valid`** (line ~2347): Past mirror. Same fix.

### Other Target Files (34 sorries, untouched)

- **SubformulaClosure.lean** (13 sorries): noConfusion/injection proofs for closure membership
- **WitnessSeed.lean** (8 sorries): All 8 use `h_F_eq : some_future psi = neg (all_future (neg psi))` which is no longer `rfl`. Fix approach: same as SuccRelation -- use BX3 + DNE + contrapositive derivation chains.
- **Table.lean** (2 sorries): truth_at unfolding for G/H in table correctness
- **TemporalContent.lean** (2 sorries): F/G duality proofs
- **TemporalCoherence.lean** (3 sorries, 2 are task-116 related): neg_neg_in_mcs helper + temporal coherence

### Core Pattern for Remaining Fixes

The same pattern repeats in ALL remaining sorry files:

**Pattern**: Code assumed `some_future phi = (all_future phi.neg).neg` was `rfl`. Now it is NOT (they are structurally different). The fix is always:
1. Use BX3 (event monotonicity) + DNE to derive `F(phi.neg.neg) -> F(phi)`
2. Contrapositive gives `neg(F(phi)) -> neg(F(phi.neg.neg))` = `neg(F(phi)) -> G(phi.neg)`
3. This bridges between `some_future`-based and `all_future`-based forms

### Pre-existing Build Errors (57 errors in 6 files)

These are NOT from task 116. They exist in files modified by prior agents:
- `SuccExistence.lean` (7 errors)
- `TruthLemma.lean` (2 errors)
- `OrderedSeedConsistency.lean` (1 error)
- `RRelation.lean` (7 errors)
- `CanonicalTaskRelation.lean` (2 errors)
- `Realization.lean` (varies)

## Key Decisions

1. **@[simp] on characterization theorems**: Added to enable `simp` to normalize temporal forms automatically. No negative impact on existing proofs.

2. **BX3 + DNE + contrapositive pattern**: The fundamental bridge between `some_future phi` and `all_future (phi.neg)` in the new definition system.

3. **Removed unused lemmas**: `swap_axiom_ta_valid`, `swap_axiom_tl_valid` corresponded to no actual axiom constructor.
