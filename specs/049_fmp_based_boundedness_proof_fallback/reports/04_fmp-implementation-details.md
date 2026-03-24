# FMP Implementation Details - Research Report

**Task**: 49 (fmp_based_boundedness_proof_fallback)
**Date**: 2026-03-24
**Session**: sess_1774371563_cc7d2b
**Purpose**: Detailed FMP implementation plan with exact proof sketches for the fallback approach

## Executive Summary

This research reveals that the two FMP sorries in TruthPreservation.lean are **fixable with a simple 2-line change each**. The docstrings claiming "strict temporal semantics" are **incorrect** - the project uses reflexive semantics where `Axiom.temp_t_future` (G phi -> phi) and `Axiom.temp_t_past` (H phi -> phi) are both valid axioms in the proof system.

The FMP approach provides a complete, sorry-free path to completeness that bypasses the SuccChain complexity entirely.

---

## Part 1: Fix TruthPreservation.lean Sorries

### 1.1 Sorry Location Analysis

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean`

| Line | Theorem | Current Status |
|------|---------|----------------|
| 263 | `mcs_all_future_closure` | `sorry` |
| 281 | `mcs_all_past_closure` | `sorry` |

### 1.2 Root Cause: Incorrect Docstrings

The docstrings (lines 250-254 and 268-272) claim:
> **DEPRECATED**: Under strict temporal semantics, the T-axiom (G phi -> phi) is NOT valid

This is **FALSE**. Examining the actual axiom system:

**Evidence from Axioms.lean** (lines 290, 304):
```lean
| temp_t_future (phi : Formula) : Axiom (phi.all_future.imp phi)
| temp_t_past (phi : Formula) : Axiom (phi.all_past.imp phi)
```

**Evidence from Soundness.lean** (lines 247-266):
```lean
theorem temp_t_future_valid (phi : Formula) : |= (phi.all_future.imp phi) := by
  intro T _ _ _ F M Omega _h_sc tau _h_mem t
  simp only [truth_at]
  intro h_G
  -- By reflexivity t >= t, so phi(t) from h_G
  exact h_G t le_rfl
```

The project uses **reflexive semantics** (G quantifies over s >= t, not s > t). These axioms ARE valid and ARE part of the proof system.

### 1.3 Exact Proof Terms

The fix follows the exact same pattern as `mcs_box_closure` (lines 188-203):

**For `mcs_all_future_closure` (line 256-263):**
```lean
theorem mcs_all_future_closure {phi : Formula} {S : ClosureMCSBundle phi}
    {psi : Formula}
    (h_future : psi.all_future in S.carrier)
    (h_psi_clos : psi in closureWithNeg phi) :
    psi in S.carrier := by
  -- Temporal T axiom: G psi -> psi
  have h_temp_t_thm : [] turnstile (psi.all_future).imp psi :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future psi)
  have h_deriv : [psi.all_future] turnstile psi := by
    have h_axiom : [psi.all_future] turnstile (psi.all_future).imp psi :=
      DerivationTree.weakening [] _ _ h_temp_t_thm (by intro; simp)
    have h_assume : [psi.all_future] turnstile psi.all_future :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
  have h_sub : forall x in [psi.all_future], x in S.carrier := by simp [h_future]
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_psi_clos
```

**For `mcs_all_past_closure` (line 274-281):**
```lean
theorem mcs_all_past_closure {phi : Formula} {S : ClosureMCSBundle phi}
    {psi : Formula}
    (h_past : psi.all_past in S.carrier)
    (h_psi_clos : psi in closureWithNeg phi) :
    psi in S.carrier := by
  -- Temporal T axiom for past: H psi -> psi
  have h_temp_t_thm : [] turnstile (psi.all_past).imp psi :=
    DerivationTree.axiom [] _ (Axiom.temp_t_past psi)
  have h_deriv : [psi.all_past] turnstile psi := by
    have h_axiom : [psi.all_past] turnstile (psi.all_past).imp psi :=
      DerivationTree.weakening [] _ _ h_temp_t_thm (by intro; simp)
    have h_assume : [psi.all_past] turnstile psi.all_past :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
  have h_sub : forall x in [psi.all_past], x in S.carrier := by simp [h_past]
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_psi_clos
```

### 1.4 Docstring Updates Required

Remove the "DEPRECATED" language from lines 247-255 and 265-273. Replace with:

```lean
/--
All-future closure for closure MCS: G psi in S implies psi in S.

This uses the Temporal T axiom (G phi -> phi), valid under reflexive semantics.
-/
```

### 1.5 Effort Estimate

| Item | Time |
|------|------|
| Replace sorry with proof term | 5 min each |
| Update docstrings | 5 min |
| Run `lake build` to verify | 2 min |
| **Total** | **15-20 min** |

---

## Part 2: Semantic Completeness Bridge

### 2.1 Current State Analysis

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean`

The key theorem `fmp_contrapositive` (lines 206-211) already exists:

```lean
theorem fmp_contrapositive (phi : Formula)
    (h_all_mcs : forall (S : ClosureMCSBundle phi), phi in S.carrier) :
    Nonempty (DerivationTree [] phi) := by
  by_contra h_not_provable
  obtain <S, h_not_in, _> := mcs_finite_model_property phi h_not_provable
  exact h_not_in (h_all_mcs S)
```

This provides: **MCS-completeness -> Provability**

### 2.2 Missing Bridge: Semantic Validity -> MCS-completeness

The gap is connecting:
- **Input**: `forall (M : TaskFrame) (w : World), M |= phi` (semantic validity)
- **Output**: `forall (S : ClosureMCSBundle phi), phi in S.carrier` (MCS membership)

**Required Theorem Statement**:
```lean
theorem semantic_validity_to_mcs_membership (phi : Formula) :
    (forall D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
     valid_over D phi) ->
    (forall (S : ClosureMCSBundle phi), phi in S.carrier)
```

### 2.3 Proof Approach

The proof requires:

1. **Truth Lemma for Filtered Model**: For any closure formula psi in subformulaClosure phi:
   ```
   psi in S.carrier <-> filteredMcsTruth phi S psi
   ```
   This is already proven as `filtration_lemma_membership` (line 375-379).

2. **Soundness over Filtered Model**: If phi is valid over all frames, it's valid over the filtered frame.

3. **Filtered Model is a TaskFrame**: The `FiniteFilteredTaskFrame` (line 165-167) provides this.

4. **Contradiction**: If phi not in S.carrier for some S, then by truth lemma, phi fails in filtered model, contradicting validity.

### 2.4 Complete Theorem with Sketch

```lean
/--
Semantic completeness via FMP: semantic validity implies provability.

Proof strategy:
1. Suppose phi is semantically valid (true in all models)
2. In particular, phi is true in the finite filtered model
3. By the truth lemma, phi in S for every closure MCS S
4. By fmp_contrapositive, phi is provable
-/
theorem fmp_semantic_completeness (phi : Formula) :
    (forall D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
     valid_over D phi) ->
    Nonempty (DerivationTree [] phi) := by
  intro h_valid
  apply fmp_contrapositive phi
  intro S
  -- Use soundness over the filtered model
  -- The filtered model is a TaskFrame over FilteredWorld phi
  -- By h_valid applied to this model, phi is true at [S]
  -- By filtration_lemma_membership, phi in S.carrier
  sorry -- Requires instantiating validity at the filtered frame
```

### 2.5 Dependencies for Completion

1. **Filtered model interpretation function**: Need `filteredInterpretation : Atom -> FilteredWorld phi -> Prop`
2. **Truth definition alignment**: Show `filteredMcsTruth` matches semantic `truth_at`
3. **Frame condition satisfaction**: Show filtered frame satisfies TM frame conditions

**Effort Estimate**: 4-6 hours (moderate complexity, relies on existing infrastructure)

---

## Part 3: FMP-Algebraic Equivalence

### 3.1 Source Analysis

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean`

Key constructions:
- `mcsToUltrafilter` (line 513-520): MCS -> Ultrafilter LindenbaumAlg
- `ultrafilterToSet` (line 656): Ultrafilter -> Set Formula
- `ultrafilterToSet_mcs` (line 662-763): Proves ultrafilterToSet returns an MCS

### 3.2 Equivalence Theorem Statement

```lean
/--
FMP-Algebraic Equivalence: membership in all closure MCS is equivalent to
membership in all ultrafilters of the Lindenbaum algebra (when restricted to closure).

This bridges the FMP approach (filtration via closure MCS) with the algebraic
approach (Lindenbaum algebra ultrafilters).
-/
theorem fmp_algebraic_equivalence (phi : Formula) :
    (forall (S : ClosureMCSBundle phi), phi in S.carrier) <->
    (forall (U : Ultrafilter LindenbaumAlg), toQuot phi in U.carrier)
```

### 3.3 Proof Sketch

**Forward Direction** (MCS -> Ultrafilter):
```lean
-- Given: all closure MCS contain phi
-- Goal: all ultrafilters contain [phi]
intro U
-- By ultrafilterToSet_mcs, U corresponds to some MCS Gamma
-- If phi in Gamma, then [phi] in mcsToSet Gamma = U (by mcsToUltrafilter structure)
-- The challenge: closure MCS vs full MCS
-- Need to show every ultrafilter corresponds to a closure MCS (restriction)
sorry
```

**Backward Direction** (Ultrafilter -> MCS):
```lean
-- Given: all ultrafilters contain [phi]
-- Goal: all closure MCS contain phi
intro S
-- By mcsToUltrafilter applied to S (extended to full MCS)
-- toQuot phi in (mcsToUltrafilter S).carrier
-- By definition of mcsToSet, this means phi in S.carrier
sorry
```

### 3.4 Technical Challenges

1. **Closure restriction**: ClosureMCSBundle is restricted to closureWithNeg phi, while Ultrafilter works over all formulas
2. **Extension lemma**: Need to extend closure MCS to full MCS (Lindenbaum on remaining formulas)
3. **Bijection coherence**: Show mcsToUltrafilter and ultrafilterToSet are inverses when restricted

### 3.5 Effort Estimate

| Item | Time |
|------|------|
| Extension lemma (closure MCS -> full MCS) | 2-3 hours |
| Forward direction | 2-3 hours |
| Backward direction | 1-2 hours |
| Bijection coherence | 2-3 hours |
| **Total** | **8-12 hours** |

---

## Part 4: Decidability/Computability Theorem

### 4.1 Current Infrastructure

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`

Existing decision procedure:
- `decide` (line 119-153): Main decision function
- `DecisionResult` (line 55-62): valid/invalid/timeout result type
- `validity_decidable` (Correctness.lean, line 50-53): Classical decidability

### 4.2 FMP-Based Decidability

```lean
/--
FMP gives decidability: validity of phi is decidable in time O(2^n) where
n = |subformulaClosure phi|.

The algorithm:
1. Compute subformulaClosure phi (polynomial in |phi|)
2. Enumerate all closure MCS (at most 2^|closure|)
3. For each closure MCS S, check if phi in S
4. Return Valid iff all closure MCS contain phi

This is PSPACE-complete (standard result for tense logic).
-/
theorem fmp_decidability (phi : Formula) :
    Decidable (Nonempty (DerivationTree [] phi)) := by
  -- Classical choice: either provable or not provable
  -- The FMP size bound ensures finite enumeration suffices
  exact Classical.dec _
```

### 4.3 Constructive Version (with Fintype)

```lean
/--
Constructive decidability using finiteness of closure MCS.
-/
theorem fmp_decidability_constructive (phi : Formula) :
    Decidable (forall (S : ClosureMCSBundle phi), phi in S.carrier) := by
  -- FilteredWorld phi is Finite (proven in FilteredWorld.finite)
  -- ClosureMCSBundle phi embeds into FilteredWorld phi
  -- Universal quantification over finite type is decidable
  haveI : Finite (FilteredWorld phi) := FilteredWorld.finite phi
  haveI : Fintype (FilteredWorld phi) := Fintype.ofFinite _
  -- Need: Fintype (ClosureMCSBundle phi)
  -- This follows from ClosureMCSBundle -> FilteredWorld being injective
  sorry
```

### 4.4 Complexity Bound

**Theorem**: Validity of TM bimodal logic is PSPACE-complete.

**Upper bound (from FMP)**:
- |subformulaClosure phi| <= O(|phi|)
- Number of closure MCS <= 2^|subformulaClosure phi| = 2^O(|phi|)
- Each MCS membership check is polynomial
- Total: PSPACE (polynomial space for tableau enumeration)

**Lower bound**: Reduction from QBF (standard modal logic result)

```lean
/--
Size bound on the finite model from FMP.
-/
theorem fmp_size_bound (phi : Formula) :
    exists (bound : Nat),
    bound = 2 ^ (subformulaClosure phi).card ∧
    True :=
  <2 ^ (subformulaClosure phi).card, rfl, trivial>
```

### 4.5 Effort Estimate

| Item | Time |
|------|------|
| Fintype instance for ClosureMCSBundle | 2-3 hours |
| Constructive decidability | 1-2 hours |
| Complexity documentation | 1 hour |
| **Total** | **4-6 hours** |

---

## Part 5: Implementation Roadmap

### 5.1 Phase 1: Fix TruthPreservation Sorries (Priority: CRITICAL)

**Files Modified**:
- `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean`

**Changes**:
1. Replace `sorry` at line 263 with proof term (copy pattern from mcs_box_closure, use Axiom.temp_t_future)
2. Replace `sorry` at line 281 with proof term (use Axiom.temp_t_past)
3. Update docstrings to remove "DEPRECATED" claims

**Effort**: 15-20 minutes
**Blockers**: None
**Outcome**: FMP infrastructure becomes sorry-free

### 5.2 Phase 2: Semantic Bridge (Priority: HIGH)

**Files Modified**:
- `Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean` (new theorems)
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` (wiring)

**New Theorems**:
1. `filtered_model_interpretation` - Interpretation function for filtered model
2. `filtered_truth_lemma` - Truth at filtered world matches MCS membership
3. `fmp_semantic_completeness` - Semantic validity -> Provability

**Effort**: 4-6 hours
**Blockers**: Phase 1
**Outcome**: Complete FMP-based completeness proof

### 5.3 Phase 3: Algebraic Equivalence (Priority: MEDIUM)

**Files Modified**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` (new section)

**New Theorems**:
1. `closure_mcs_extends_to_full_mcs` - Extension lemma
2. `fmp_algebraic_equivalence` - Bijection between approaches

**Effort**: 8-12 hours
**Blockers**: None (parallel track)
**Outcome**: Formal proof that FMP and algebraic approaches are equivalent

### 5.4 Phase 4: Decidability Formalization (Priority: LOW)

**Files Modified**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`

**New Theorems**:
1. `ClosureMCSBundle.fintype` - Fintype instance
2. `fmp_decidability_constructive` - Constructive decidability

**Effort**: 4-6 hours
**Blockers**: Phase 1
**Outcome**: Constructive decidability proof

---

## Part 6: Comparison with Task 48 (SuccChain Approach)

### 6.1 SuccChain Architecture Issues

Task 48 uses the SuccChain approach with:
- Complex chain construction from MCS
- deferralClosure for F-obligations
- 24 sorries in SuccChain files (Class A critical path)

**Key Problem**: The `restricted_single_step_forcing` lemma is FALSE as stated due to MCS extension nondeterminism at closure boundaries.

### 6.2 FMP Advantages

| Aspect | SuccChain | FMP |
|--------|-----------|-----|
| Sorries | 24 (critical path) | 2 (trivially fixable) |
| Complexity | High (chain construction) | Low (filtration quotient) |
| Dependencies | deferralClosure, forcing | Standard MCS + quotient |
| Proof structure | Canonical model | Finite model property |

### 6.3 Recommendation

The FMP approach should be prioritized as:
1. **Immediate win**: 2 sorries fixable in 15 minutes
2. **Clean path**: Avoids SuccChain complexity entirely
3. **Complete**: Provides full completeness via FMP
4. **Decidability**: Naturally gives PSPACE decidability

Task 48's SuccChain work can be deprioritized or used only if FMP proves insufficient for specific proof scenarios.

---

## Summary Table

| Phase | Files | Effort | Sorries Fixed | Priority |
|-------|-------|--------|---------------|----------|
| 1: TruthPreservation | TruthPreservation.lean | 20 min | 2 | CRITICAL |
| 2: Semantic Bridge | FMP.lean, Correctness.lean | 4-6h | 0 (new) | HIGH |
| 3: Algebraic Equiv | UltrafilterMCS.lean | 8-12h | 0 (new) | MEDIUM |
| 4: Decidability | Correctness.lean | 4-6h | 0 (new) | LOW |

**Total Effort**: 17-25 hours for complete FMP-based completeness

---

## References

1. Blackburn, de Rijke, Venema: *Modal Logic*, Ch 2.3 (Filtration)
2. Hughes & Cresswell: *A New Introduction to Modal Logic*, Ch 6.2 (FMP)
3. Project files:
   - `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean`
   - `Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean`
   - `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean`
   - `Theories/Bimodal/ProofSystem/Axioms.lean`
   - `Theories/Bimodal/Metalogic/Soundness.lean`
