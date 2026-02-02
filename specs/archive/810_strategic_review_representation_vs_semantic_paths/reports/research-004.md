# Research Report: Porting Advanced Metalogic Results to FMP Approach

**Task**: 810 - strategic_review_representation_vs_semantic_paths
**Report**: research-004
**Focus**: Feasibility of achieving finite_strong_completeness, infinitary_strong_completeness, and compactness solely via FMP
**Date**: 2026-02-02
**Session**: sess_1770012115_125443

---

## Executive Summary

The FMP (Finite Model Property) approach **can fully support** all three target results:
1. `finite_strong_completeness` - **Already proven** via FMP path
2. `infinitary_strong_completeness` - **Feasible** with new Set-based FMP infrastructure
3. `compactness` - **Feasible** as corollary of infinitary_strong_completeness

The gap is **definitional, not theoretical**. The FMP approach can handle infinite context sets; it simply lacks the infrastructure currently. The Representation approach provides a `truth_lemma` that works with arbitrary formula sets, while FMP's `semantic_truth_at_v2` is restricted to single-formula closures.

---

## 1. Current FMP Infrastructure Analysis

### 1.1 Core Components (FMP/)

| File | Key Definitions | Status |
|------|-----------------|--------|
| `Closure.lean` | `closure`, `closureWithNeg`, `ClosureMaximalConsistent`, `mcs_projection_is_closure_mcs` | Proven |
| `FiniteWorldState.lean` | `FiniteWorldState`, `worldStateFromClosureMCS`, `FiniteHistory` | Proven |
| `SemanticCanonicalModel.lean` | `SemanticWorldState`, `semantic_weak_completeness` | **Proven (sorry-free)** |
| `BoundedTime.lean` | `BoundedTime k` | Proven |

### 1.2 What FMP Currently Proves

```lean
-- Weak completeness: valid formulas are provable
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

**Key insight**: This works via contrapositive:
1. If phi is not provable, {phi.neg} is consistent
2. Extend to MCS via Lindenbaum
3. Project to closure MCS
4. Build FiniteWorldState where phi is false
5. This contradicts universal validity

### 1.3 Finite Strong Completeness (Already Proven)

`FiniteStrongCompleteness.lean` achieves:
```lean
theorem finite_strong_completeness (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> ContextDerivable Gamma phi
```

**How it works**:
1. Build `impChain Gamma phi` = `psi1 -> (psi2 -> ... -> phi)...`
2. Show `valid (impChain Gamma phi)` (from semantic consequence)
3. Apply `semantic_weak_completeness` to get `|- impChain Gamma phi`
4. Unfold implication chain using context assumptions to get `Gamma |- phi`

**Verdict**: This is pure FMP. No Representation required.

---

## 2. What Infinitary/Compactness Need

### 2.1 Current Infinitary Strong Completeness (Boneyard/Metalogic_v5/)

```lean
theorem infinitary_strong_completeness (Gamma : Set Formula) (phi : Formula) :
    set_semantic_consequence Gamma phi ->
    exists (Delta : Finset Formula), Delta.val subset Gamma /\ ContextDerivable Delta.toList phi
```

**Current approach** (uses Representation):
1. Assume no finite Delta subset Gamma derives phi
2. Show `Gamma union {phi.neg}` is SetConsistent
3. Extend to MCS via Lindenbaum
4. **Build canonical model via IndexedMCSFamily** (Representation)
5. **Apply truth_lemma to show all of Gamma true** (Representation)
6. Contradiction: phi should be true (semantic consequence) but phi.neg in MCS

### 2.2 Why Current Approach Needs Representation

The critical step is **Step 5**: showing that all formulas in an arbitrary set Gamma are true in the canonical model. This requires:

- `truth_lemma`: `psi in family.mcs t <-> truth_at (canonical_model family) ... t psi`

The FMP approach only has:
- `semantic_truth_at_v2 phi w t psi` - truth for formulas in `closure phi`
- `worldStateFromClosureMCS_models_iff` - MCS membership equals truth, but only for closure members

**The gap**: FMP's truth correspondence is bounded by the closure of a single target formula, not an arbitrary formula set.

---

## 3. Gap Analysis: Definitional vs Theoretical

### 3.1 Is the Gap Theoretical?

**No.** The FMP approach works for any finite formula set via:
1. Take union of closures: `bigUnion { closure psi | psi in Gamma }`
2. Build finite world state over this extended closure
3. Truth lemma works the same way

The infinite case requires:
- For **infinitary_strong_completeness**: We only need to show a **finite witness** exists
- The contrapositive argument handles infinite Gamma by finding a finite Delta

### 3.2 Why FMP Can Handle It

The key insight from `no_finite_witness_implies_union_consistent`:

```lean
-- If no finite Delta subset Gamma derives phi,
-- then Gamma union {neg phi} is SetConsistent
lemma no_finite_witness_implies_union_consistent (Gamma : Set Formula) (phi : Formula) :
    (not exists (Delta : Finset Formula), Delta subset Gamma /\ ContextDerivable Delta.toList phi) ->
    SetConsistent (Gamma union {phi.neg})
```

This is already proven! The Representation approach's advantage is only the model construction, not the core logic.

---

## 4. What FMP Needs to Support These Results

### 4.1 Extended Closure Infrastructure

**New Definitions Needed**:

```lean
-- Extended closure for finite formula sets
def closureUnion (Gamma : Finset Formula) : Finset Formula :=
  Gamma.biUnion closure

-- Extended FiniteWorldState over a formula set
structure ExtendedFiniteWorldState (Gamma : Finset Formula) where
  assignment : { psi : Formula // psi in closureUnionWithNeg Gamma } -> Bool
  consistent : IsExtendedLocallyConsistent Gamma assignment

-- Extended truth predicate
def extended_models (w : ExtendedFiniteWorldState Gamma) (psi : Formula)
    (h : psi in closureUnion Gamma) : Prop := ...
```

### 4.2 Extended Truth Lemma

```lean
-- For finite Gamma, membership in ClosureMCS equals truth
theorem extended_truth_lemma (Gamma : Finset Formula) (S : Set Formula)
    (h_mcs : ExtendedClosureMaximalConsistent Gamma S)
    (psi : Formula) (h_mem : psi in closureUnion Gamma) :
    psi in S <-> (extendedWorldStateFromMCS Gamma S h_mcs).models psi h_mem
```

### 4.3 Infinitary Completeness via FMP

**Strategy**:
1. Use `no_finite_witness_implies_union_consistent` (already proven)
2. Get MCS extending `Gamma union {phi.neg}` via Lindenbaum
3. For any finite subset Delta of Gamma:
   - Form `closureUnion (Delta union {phi})`
   - Project MCS to this extended closure
   - Build ExtendedFiniteWorldState
   - Show Delta is satisfied but phi is false
4. Contradiction with semantic consequence

---

## 5. Concrete Implementation Path

### Phase 1: Extended Closure (1-2 days)

New file: `FMP/ExtendedClosure.lean`
- `closureUnion : Finset Formula -> Finset Formula`
- `closureUnionWithNeg : Finset Formula -> Finset Formula`
- `ExtendedClosureConsistent`, `ExtendedClosureMaximalConsistent`
- `extended_mcs_projection_is_closure_mcs`

### Phase 2: Extended World State (2-3 days)

New file: `FMP/ExtendedFiniteWorldState.lean`
- `ExtendedFiniteWorldState Gamma`
- `IsExtendedLocallyConsistent`
- `extendedWorldStateFromMCS`
- `extended_models`
- Fintype instance with cardinality bound

### Phase 3: Extended Truth Lemma (2-3 days)

New file: `FMP/ExtendedTruthLemma.lean`
- `extended_truth_lemma` for all closure members
- Bridge lemmas connecting to single-formula case

### Phase 4: Infinitary Completeness via FMP (1-2 days)

Update: `Completeness/InfinitaryStrongCompleteness.lean`
- Replace Representation imports with FMP/Extended imports
- Prove `infinitary_strong_completeness` using extended infrastructure
- Prove `compactness` as corollary

**Total Effort**: 6-10 days

---

## 6. Alternative: Simpler Approach

An even simpler approach exists that avoids new infrastructure:

### 6.1 Direct Semantic Argument

For `infinitary_strong_completeness`, we need to show: if Gamma semantically entails phi, then some finite Delta derives phi.

**Observation**: The contrapositive proof only requires showing `Gamma union {phi.neg}` is satisfiable. We can use:

1. `no_finite_witness_implies_union_consistent` - already proven via FMP
2. For satisfiability, use **any** finite subset:
   - Take Delta = {} (empty)
   - By `semantic_weak_completeness`, if phi.neg is consistent, it's satisfiable
   - This gives a model where phi.neg is true
   - Since Delta subset Gamma is satisfied (vacuously), we have our countermodel

This approach works because:
- Semantic consequence is **anti-monotonic** in premises
- If empty set satisfies (vacuous), any superset also satisfies
- The truth of phi.neg in some model contradicts Gamma |= phi

### 6.2 No New FMP Infrastructure Needed

This approach only requires:
1. `semantic_weak_completeness` (proven)
2. `no_finite_witness_implies_union_consistent` (proven)
3. Bridge lemma: consistent formula is satisfiable in general models

The bridge lemma can be proven using FMP directly:
```lean
-- If phi is consistent, there exists a (general) model where phi is true
lemma consistent_satisfiable (phi : Formula) (h_cons : SetConsistent {phi}) :
    set_satisfiable {phi} := by
  -- Use semantic_weak_completeness contrapositive
  -- If phi.neg were valid, it would be provable, contradicting phi consistent
```

---

## 7. Recommendations

### 7.1 Primary Recommendation: Simpler Approach

Use the direct semantic argument (Section 6) to achieve all three results with minimal new code:

1. **Prove bridge lemma** `consistent_satisfiable` using FMP contrapositive
2. **Update infinitary_strong_completeness** to use this bridge
3. **Compactness** follows as direct corollary

**Estimated effort**: 2-3 days

### 7.2 Secondary: Extended Infrastructure (If Needed Later)

If more sophisticated model constructions are needed in the future:
- Implement the extended closure infrastructure (Section 5)
- This provides a principled FMP-based replacement for all Representation use cases

### 7.3 Representation Deprecation Path

Once FMP-based infinitary completeness is proven:
1. Archive `Metalogic_v5/Completeness/InfinitaryStrongCompleteness.lean`
2. Archive `Metalogic_v5/Compactness/Compactness.lean`
3. Create new sorry-free versions in `Metalogic/Completeness/` and `Metalogic/Compactness/`
4. Update module documentation

---

## 8. Conclusion

**FMP can fully support all target results.** The Representation approach is not required for any theoretical reason - it simply provided a more general truth lemma. The FMP approach can achieve the same results through:

1. **Already proven**: `finite_strong_completeness` uses FMP path
2. **Straightforward**: `infinitary_strong_completeness` via direct semantic argument
3. **Corollary**: `compactness` follows from infinitary completeness

The recommended implementation effort is 2-3 days using the simpler approach, with no new FMP infrastructure required.

---

## Appendix A: File Locations

| Result | Current Location | Target Location |
|--------|------------------|-----------------|
| `finite_strong_completeness` | `Metalogic/Completeness/FiniteStrongCompleteness.lean` | No change (already FMP-based) |
| `infinitary_strong_completeness` | `Boneyard/Metalogic_v5/Completeness/InfinitaryStrongCompleteness.lean` | `Metalogic/Completeness/InfinitaryStrongCompleteness.lean` |
| `compactness` | `Boneyard/Metalogic_v5/Compactness/Compactness.lean` | `Metalogic/Compactness/Compactness.lean` |

## Appendix B: Key Dependencies

The FMP path requires only:
- `Metalogic/Core/MaximalConsistent.lean` - Lindenbaum, MCS properties
- `Metalogic/Core/DeductionTheorem.lean` - Deduction theorem
- `Metalogic/FMP/*` - Closure, world states, semantic completeness
- `Theorems/Propositional.lean` - Double negation elimination

No dependencies on:
- `Boneyard/Metalogic_v5/Representation/*`
- `IndexedMCSFamily`, `CoherentConstruction`, `truth_lemma`
