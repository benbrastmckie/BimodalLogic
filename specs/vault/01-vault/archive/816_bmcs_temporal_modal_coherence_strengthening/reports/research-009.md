# Research Report: Task #816 - Hybrid BoundedBMCS Architecture

**Task**: 816 - bmcs_temporal_modal_coherence_strengthening
**Date**: 2026-02-02
**Focus**: Design a hybrid approach combining multi-family modal saturation with bounded time domains

## Executive Summary

This report proposes a **BoundedBMCS** architecture that combines insights from two existing completeness approaches:

1. **FMP's Bounded Time Domain** (`BoundedTime k = Fin (2*k+1)`) - Eliminates temporal sorries by restricting to finite time
2. **BMCS's Multi-Family Modal Saturation** (Option 3 from research-008.md) - Eliminates modal sorries by construction

The key insight is that both the omega-rule problem (temporal) and the modal saturation problem share a common root cause: they require witnessing infinitely many formulas. By restricting to bounded time AND using multi-family construction, we can achieve a **fully sorry-free biconditional truth lemma**.

## Analysis of FMP's Bounded Time Mechanism

### BoundedTime Definition

From `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean`:

```lean
/-- Bounded time domain with 2k+1 elements, representing time offsets from -k to +k. -/
abbrev BoundedTime (k : Nat) := Fin (2 * k + 1)
```

Key properties:
- **Automatic Fintype**: Definitionally `Fin (2*k+1)`, so finite by construction
- **Integer interpretation**: `toInt : BoundedTime k -> Int` maps to [-k, k]
- **Origin**: `BoundedTime.origin k = k` (the middle element, maps to 0)
- **Bounded successor/predecessor**: `succ?` and `pred?` return `Option` (may hit boundary)

### temporalBound Function

From `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean`:

```lean
def temporalBound (phi : Formula) : Nat := phi.temporalDepth
```

The temporal bound is formula-dependent. For a formula `phi`:
- The time domain is `BoundedTime (temporalBound phi)`
- This gives `2 * temporalDepth + 1` time points

### Why FMP Avoids Temporal Sorries

The FMP truth lemma in `SemanticCanonicalModel.lean` is **completely sorry-free** because:

1. **Finite quantification**: "For all future times" becomes "for all `s > t` in `BoundedTime k`" - a finite set
2. **No omega-rule needed**: With finite time, the backward temporal direction is just a finite conjunction
3. **Closure MCS structure**: Uses `ClosureMaximalConsistent` sets that are restricted to the subformula closure

The FMP completeness theorem:

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

This is proven entirely via contrapositive without any sorries.

### Key Limitation of FMP

The FMP approach uses:
- **Constant histories** (`FiniteHistory.constant w`) - same world state at all times
- **Permissive task relation** (always `True`) - trivializes modal accessibility
- **Single world state** per construction - no multi-family structure

This works for weak completeness but does NOT provide the rich BMCS structure needed for bundled modal semantics.

## Analysis of BMCS's Modal Saturation Requirement

### Current BMCS Architecture

From `Theories/Bimodal/Metalogic/Bundle/Construction.lean`:

```lean
noncomputable def singleFamilyBMCS (fam : IndexedMCSFamily D) : BMCS D where
  families := {fam}
  modal_forward := ... -- Proven via T-axiom
  modal_backward := ... -- SORRY: requires phi in M -> Box phi in M
```

The `modal_backward` sorry exists because:
- With ONE family, the condition becomes: `phi in M -> Box phi in M`
- This is NOT a theorem in general modal logic (only holds for necessary truths)

### Multi-Family Solution (from research-008.md)

The idea: instead of one family, construct a **saturated** set of families where:
- Every Diamond witness has a corresponding family
- Modal backward becomes: "if phi is in ALL families at time t, then Box phi is in fam"
- With proper saturation, this becomes provable

## Proposed Hybrid Architecture: BoundedBMCS

### Core Design

```
BoundedBMCS combines:
  1. Time domain: BoundedTime (temporalBound phi) instead of arbitrary D
  2. Family structure: Multi-family with modal saturation
  3. Truth lemma: Full biconditional with NO sorries
```

### Type Definitions

```lean
/-- A family of MCS indexed over bounded time -/
structure BoundedIndexedMCSFamily (phi : Formula) where
  mcs : BoundedTime (temporalBound phi) -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  -- Temporal coherence for bounded time
  forward_G : forall t t' psi, t < t' -> Formula.all_future psi in mcs t -> psi in mcs t'
  backward_H : forall t t' psi, t' < t -> Formula.all_past psi in mcs t -> psi in mcs t'
  forward_H : forall t t' psi, t < t' -> Formula.all_past psi in mcs t' -> psi in mcs t
  backward_G : forall t t' psi, t' < t -> Formula.all_future psi in mcs t' -> psi in mcs t
  -- NEW: Bounded temporal saturation (key to eliminating temporal sorries)
  temporal_backward_G : forall t psi,
    (forall s, t <= s -> psi in mcs s) -> Formula.all_future psi in mcs t
  temporal_backward_H : forall t psi,
    (forall s, s <= t -> psi in mcs s) -> Formula.all_past psi in mcs t

/-- A BMCS with bounded time and saturated families -/
structure BoundedBMCS (phi : Formula) where
  families : Set (BoundedIndexedMCSFamily phi)
  nonempty : families.Nonempty
  -- Modal coherence (same as BMCS)
  modal_forward : forall fam in families, forall psi t,
    Formula.box psi in fam.mcs t -> forall fam' in families, psi in fam'.mcs t
  modal_backward : forall fam in families, forall psi t,
    (forall fam' in families, psi in fam'.mcs t) -> Formula.box psi in fam.mcs t
  -- Evaluation point
  eval_family : BoundedIndexedMCSFamily phi
  eval_family_mem : eval_family in families
```

### Key Insight: Temporal Backward Becomes Finite

With bounded time, the temporal backward direction that required sorry:

```lean
-- OLD (BMCS with unbounded D): Requires omega-rule
intro h_all  -- h_all : forall s >= t, phi in fam.mcs s
sorry        -- Cannot witness infinite conjunction

-- NEW (BoundedBMCS): Finite conjunction
intro h_all  -- h_all : forall s in BoundedTime k, s >= t -> phi in fam.mcs s
exact fam.temporal_backward_G t phi h_all  -- Uses saturation condition
```

The saturation condition `temporal_backward_G` is **constructively achievable** because:
1. `BoundedTime k` is finite (exactly `2k+1` elements)
2. "For all s >= t" is a finite conjunction
3. We can saturate the MCS construction to include this condition

## Construction Strategy for BoundedBMCS

### Phase 1: Closure Saturation for Temporal Backward

For a formula `phi`, define:
```lean
def temporalClosure (phi : Formula) : Finset Formula :=
  closure phi ++
  -- Add G-saturation witnesses
  (closure phi).filter Formula.is_all_future ++
  -- Add H-saturation witnesses
  (closure phi).filter Formula.is_all_past
```

### Phase 2: Multi-Family Modal Saturation

For modal saturation, we need the families to satisfy:
- If `neg (Box psi)` is consistent with some family, there exists another family where `neg psi` holds
- This is the standard Henkin witnessing construction

Concrete approach:
```lean
def constructSaturatedFamilies (baseFam : BoundedIndexedMCSFamily phi) :
    Set (BoundedIndexedMCSFamily phi) :=
  -- Start with base family
  -- For each diamond formula Diamond psi = neg (Box (neg psi)) that's consistent,
  -- ensure there's a witness family where psi holds
  sorry -- Construction details require Zorn's lemma analog
```

### Phase 3: Truth Lemma

```lean
theorem bounded_bmcs_truth_lemma (B : BoundedBMCS phi)
    (fam : BoundedIndexedMCSFamily phi) (hfam : fam in B.families)
    (t : BoundedTime (temporalBound phi)) (psi : Formula) (h_cl : psi in closure phi) :
    psi in fam.mcs t <-> bounded_bmcs_truth_at B fam t psi := by
  induction psi generalizing fam t with
  | atom p => -- Trivial
  | bot => -- By consistency
  | imp => -- By MCS properties (same as current)
  | box psi ih =>
    -- SORRY-FREE by modal saturation (same as current BMCS)
    ...
  | all_future psi ih =>
    constructor
    · -- Forward: G psi in MCS -> truth at all future times (SAME AS CURRENT)
      intro hG s hts
      exact (ih fam hfam s _).mp (mcs_all_future_implies_phi_at_future ...)
    · -- Backward: truth at all future times -> G psi in MCS (NEW: PROVABLE!)
      intro h_all
      -- Use temporal_backward_G saturation condition
      apply fam.temporal_backward_G t psi
      intro s hts
      exact (ih fam hfam s _).mpr (h_all s hts)
  | all_past psi ih =>
    -- Symmetric to all_future
```

## Obstacles to Integration

### Obstacle 1: Temporal Saturation Construction

The `temporal_backward_G` condition requires that whenever `phi` holds at ALL future bounded times, `G phi` is in the MCS. This means:

**Current approach (constant MCS)**: Same MCS at all times, so this holds trivially via T-axiom.

**Multi-family approach**: Each family may have different MCSes at different times. We need to ensure the construction produces temporally saturated families.

**Proposed solution**: Use a two-phase construction:
1. First, extend the consistent set to closure-maximal with temporal saturation witnesses
2. Then, perform modal saturation on top

### Obstacle 2: Modal Saturation for Multi-Family

The modal backward condition requires constructing witness families for every consistent diamond formula. This is conceptually the same as standard Henkin construction but:

**Challenge**: We need witnesses that are ALSO temporally saturated.

**Proposed solution**: Define "bounded-saturated family" as one satisfying BOTH:
- Temporal saturation (for all bounded times)
- Modal witness condition (exists in bundle)

Use transfinite construction (Zorn's lemma) to build the maximal bundle.

### Obstacle 3: Complexity of Full Construction

The full BoundedBMCS construction requires:
1. Lindenbaum extension with closure restriction
2. Temporal saturation within bounded time
3. Modal saturation via multi-family
4. Compatibility between temporal and modal saturation

This is significantly more complex than either:
- FMP (single world state, constant history)
- Current BMCS (single family with sorries)

## Pseudocode for BoundedBMCS Construction

```lean
/-- Construct a BoundedBMCS from a consistent formula -/
noncomputable def construct_bounded_bmcs (phi : Formula)
    (h_cons : SetConsistent ({phi} : Set Formula)) : BoundedBMCS phi := by
  -- Step 1: Extend {phi} to full MCS M
  obtain ⟨M, h_sub, h_mcs⟩ := set_lindenbaum {phi} h_cons

  -- Step 2: Build base family with bounded time domain
  let base_fam : BoundedIndexedMCSFamily phi := {
    mcs := fun t => M ∩ closureWithNeg phi  -- Same MCS at all bounded times
    is_mcs := ...,
    forward_G := ...,  -- From T-axiom (since constant)
    backward_H := ..., -- From T-axiom (since constant)
    forward_H := ...,  -- From T-axiom (since constant)
    backward_G := ..., -- From T-axiom (since constant)
    temporal_backward_G := fun t psi h_all =>
      -- With bounded time, h_all is a finite conjunction
      -- The finite conjunction can be internalized into MCS
      ...,
    temporal_backward_H := ...
  }

  -- Step 3: Modal saturation to get full family set
  let saturated_families := constructSaturatedFamilies base_fam

  -- Step 4: Build BoundedBMCS
  exact {
    families := saturated_families,
    nonempty := ...,
    modal_forward := ...,  -- From saturation construction
    modal_backward := ..., -- From saturation construction
    eval_family := base_fam,
    eval_family_mem := ...
  }
```

## Alternative: Simplified BoundedBMCS

If full multi-family construction is too complex, a **simplified version** could:

1. Keep single family (like current BMCS)
2. Use bounded time (from FMP)
3. Accept `modal_backward` sorry as documented axiom
4. Eliminate temporal sorries via bounded time saturation

This would give:
- **Sorry-free temporal cases** (G, H backward)
- **One sorry for modal** (`modal_backward` - documented as construction assumption)
- **Cleaner architecture** than current unbounded BMCS

### Simplified BoundedBMCS Definition

```lean
structure SimplifiedBoundedBMCS (phi : Formula) where
  family : BoundedIndexedMCSFamily phi
  eval_time : BoundedTime (temporalBound phi)

/-- Truth lemma with only modal_backward sorry -/
theorem simplified_truth_lemma (B : SimplifiedBoundedBMCS phi)
    (t : BoundedTime (temporalBound phi)) (psi : Formula) (h_cl : psi in closure phi) :
    psi in B.family.mcs t <-> simplified_truth_at B t psi := by
  induction psi with
  | all_future psi ih =>
    -- SORRY-FREE because bounded time makes backward direction finite
    ...
  | all_past psi ih =>
    -- SORRY-FREE because bounded time makes backward direction finite
    ...
  | box psi ih =>
    -- STILL REQUIRES SORRY for modal_backward (same as current)
    ...
```

## Recommendations

### Option A: Full BoundedBMCS (Maximum Rigor)

**Effort**: High (estimated 40-60 hours)
**Sorries**: Zero
**Architecture**: BoundedBMCS with multi-family modal saturation

Implement:
1. `BoundedIndexedMCSFamily` with temporal saturation conditions
2. `constructSaturatedFamilies` with modal witnessing
3. Full truth lemma proof

### Option B: Simplified BoundedBMCS (Pragmatic)

**Effort**: Medium (estimated 15-25 hours)
**Sorries**: One (`modal_backward` - documented as axiom)
**Architecture**: Single-family BoundedBMCS

Implement:
1. `BoundedIndexedMCSFamily` with bounded time
2. `temporal_backward_G` and `temporal_backward_H` saturation
3. Truth lemma with sorry-free temporal cases

### Option C: Use FMP for Publication, BMCS for Exposition

**Effort**: Low (documentation only)
**Sorries**: Zero (use existing FMP)
**Architecture**: No new construction

Present:
1. `semantic_weak_completeness` from FMP as main result (sorry-free)
2. BMCS as supplementary construction with documented axioms
3. Note the omega-rule limitation as foundational

### Recommendation: Option B

**Rationale**:
- Eliminates 2 of 3 current sorries (temporal backward cases)
- Modal backward sorry is **architecturally distinct** (modal saturation vs omega-rule)
- Provides clear path to Option A if needed
- Balances rigor with implementation effort

## Architectural Changes Summary

| Component | Current BMCS | BoundedBMCS (Option B) | Full BoundedBMCS (Option A) |
|-----------|--------------|------------------------|------------------------------|
| Time domain | Arbitrary D | `BoundedTime (temporalBound phi)` | Same |
| Family structure | Single | Single | Multi-family saturated |
| Temporal forward | Proven | Proven | Proven |
| Temporal backward | SORRY | Proven (finite!) | Proven |
| Modal forward | Proven | Proven | Proven |
| Modal backward | SORRY | SORRY (axiom) | Proven |
| Total sorries | 3 | 1 | 0 |

## References

### Codebase Files Analyzed
- `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean` - Bounded time definition
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - Finite world states
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - FMP completeness (sorry-free)
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Subformula closure
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` - Bridge lemma (blocked)
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - BMCS definition
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` - Indexed MCS families
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - BMCS construction (1 sorry)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Truth lemma (2 sorries)

### Previous Research
- `specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-008.md` - Option 3 analysis

## Next Steps

1. **Implement `BoundedIndexedMCSFamily`**: Define the bounded time variant with temporal saturation conditions
2. **Prove temporal saturation**: Show that the constant-MCS construction satisfies `temporal_backward_G/H`
3. **Update truth lemma**: Prove temporal backward cases using saturation conditions
4. **Document modal_backward**: Convert remaining sorry to explicit axiom declaration
5. **Integration testing**: Verify completeness theorems still work with bounded architecture
