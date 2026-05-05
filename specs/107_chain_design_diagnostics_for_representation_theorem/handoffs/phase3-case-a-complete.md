# Handoff: Phase 3 Case A Complete, Case B Blocked

## Session ID
sess_1778001650_86e871

## What Was Done

### Phase 3: Lemma 2.6 Pos Sub-case -- Case A Proved, Case B Blocked

Restructured `burgess_D0_finite_subset_consistent_incons` (PointInsertion.lean) to case-split on `SetMaximalConsistent B` BEFORE constructing `c_list`:

**Case A (B not MCS) -- FULLY PROVED:**
1. Extract delta' not in B with {delta'}∪B consistent (from `¬SetMaximalConsistent B`)
2. Apply `BurgessR3Maximal_extension_fails` to get `¬burgessR3(A, DC({delta'}∪B), C)`
3. By contradiction (same pattern as `burgess_D0_seed_consistent`), extract neg-until witness: beta0 in B, gamma0 in C, `(untl(beta0∧delta', gamma0)).neg ∈ A`
4. Add gamma0 to c_list (prepended, so gamma0 is first element)
5. Construct γ_hat = list_conj(gamma0 :: γ₀ :: c_list_raw), giving `⊢ γ_hat → gamma0`
6. In the pos sub-case: from `untl(b∧β, γ_hat) ∈ A` and `⊢ (b∧β) → ⊥` (since β.neg is a conjunct of b), by left_mono + EFQ: `untl(beta0∧delta', γ_hat) ∈ A`, then by right_mono with `γ_hat → gamma0`: `untl(beta0∧delta', gamma0) ∈ A`, contradicting the neg-until witness
7. The neg sub-case works as before (burgess_zeta_consistent), adapted for the extended c_list (gamma0 at index 0, γ₀ at index 1, c_list_raw elements at index 2+)

**Case B (B is MCS) -- sorry remains:**
The neg sub-case is duplicated inside Case B with the original c_list (no gamma0). Works fine. The pos sub-case has a `sorry` because:

1. When B is MCS, every delta' not in B has delta'.neg in B, making {delta'}∪B inconsistent
2. `BurgessR3Maximal_extension_fails` requires a consistent extension, so cannot be invoked
3. Therefore no neg-until witness can be extracted
4. Without a neg-until witness, BX14 cannot fire (since untl(r, γ_hat) ∈ A for ALL r when (b∧β) → ⊥)
5. This gap exists because our `BurgessR3Maximal` maximality clause uses `SetDeductivelyClosed D` (consistent) rather than Burgess's original `ClosedUnderDerivation D` (allows inconsistent extensions)

### Root Cause Analysis

Burgess 1982 defines "deductively closed" WITHOUT requiring consistency. His maximality R(A,B,C) says B is maximal among ALL extensions (including inconsistent Set.univ). This gives the witness for ANY delta not in B.

Our `SetDeductivelyClosed` requires `SetConsistent`, so our maximality only applies to consistent extensions. When B is MCS, no consistent proper extension exists, making the maximality vacuously true and providing no information.

### Options to Resolve Case B

1. **Strengthen BurgessR3Maximal maximality clause**: Change `SetDeductivelyClosed D →` to `ClosedUnderDerivation D →`. This matches Burgess exactly. The Zorn construction (`burgessR3Maximal_extension_exists`) would need to additionally show `¬burgessR3(A, Set.univ, C)`. This is NOT provable in general from J₀ axioms alone -- it requires semantic reasoning about intermediate points in a dense order. May need to be added as a hypothesis.

2. **Add `¬burgessR3(A, Set.univ, C)` as hypothesis**: Thread this through `BurgessR3Maximal_extension_fails` and downstream. Call sites must provide it. In the chronicle construction, this should be provable from the structure of the model being built.

3. **Show B is never MCS in practice**: In the chronicle omega-chain construction, g(x,y) values are produced by Zorn's lemma from seeds. If we can show the seed always produces a non-MCS B, the Case B sorry becomes unreachable. However, this is not obviously true.

## File Changes

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Lines ~1871-2283: Complete rewrite of `burgess_D0_finite_subset_consistent_incons`
  - Structure: MCS case-split before c_list, Case A fully proved, Case B neg sub-case duplicated

## Sorry Locations (7 in Chronicle, unchanged count but narrowed scope)

- PointInsertion.lean:1951 -- sorry in Case B pos sub-case (NARROWED: was unconditional, now conditional on B being MCS)
- PointInsertion.lean:2717 -- sorry #2 (lemma_2_7_seed_consistent)
- PointInsertion.lean:2847 -- sorry #3 (lemma_2_7 inconsistent case)
- CounterexampleElimination.lean:412 -- sorry #4 (C4 forward hard case)
- CounterexampleElimination.lean:510 -- sorry #5 (C4' backward hard case)
- ChronicleToCountermodel.lean:615 -- sorry #11 (FUC coherence)
- ChronicleToCountermodel.lean:619 -- sorry #12 (FSC coherence)

## Build Status
`lake build` passes with 0 errors.

## Convention Reminder
Our `untl(guard, event)` = Burgess `U(event, guard)`. Arguments are SWAPPED.
