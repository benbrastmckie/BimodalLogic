# Research Report: Task #841

**Task**: Remove axiom from task 827 via complete multi-family saturation construction
**Date**: 2026-02-03
**Focus**: Research how to implement complete multi-family saturation construction to remove singleFamily_modal_backward_axiom

## Summary

The `singleFamily_modal_backward_axiom` in `SaturatedConstruction.lean` and `Construction.lean` represents mathematical debt: it asserts that `phi in fam.mcs t` implies `Box phi in fam.mcs t`, which is NOT provable from first principles. This research analyzes the infrastructure required to eliminate this axiom via a complete multi-family saturation construction with well-founded termination.

## Current State Analysis

### The Axiom (Technical Debt)

Located at:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean:228-231`
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean:171-174`

```lean
axiom singleFamily_modal_backward_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_phi_in : phi ∈ fam.mcs t) :
    Formula.box phi ∈ fam.mcs t
```

**Why it exists**: In a single-family BMCS, `modal_backward` requires proving `phi -> Box phi`, which is NOT valid in modal logic. The axiom captures the metatheoretic fact that a saturated canonical model exists.

### Existing Infrastructure

**SaturatedConstruction.lean** (lines 239-309) provides:
1. `FamilyCollection` structure - a set of families with eval_family
2. `FamilyCollection.isSaturated` - saturation predicate for closure formulas
3. `FamilyCollection.toBMCS` - converts saturated collection to BMCS (has 2 sorries)
4. `closure_saturation_implies_modal_backward_for_closure` - PROVEN theorem showing saturation implies modal_backward

**SubformulaClosure.lean** provides:
1. `subformulaClosure : Formula -> Finset Formula` - finite subformula set
2. `subformulaClosureCard : Formula -> Nat` - cardinality (useful for termination)
3. `closureWithNeg` - closure plus negations
4. `diamondSubformulas : Formula -> Finset Formula` - Diamond formulas in closure
5. `diamondCount : Formula -> Nat` - count of Diamond formulas (bounds iterations)

**ModalSaturation.lean** provides:
1. `is_modally_saturated : BMCS D -> Prop` - full saturation predicate
2. `saturated_modal_backward` - PROVEN theorem: saturation implies modal_backward
3. `constructWitnessFamily` - creates witness family for consistent formula
4. `diamond_implies_psi_consistent` - Diamond psi in MCS implies {psi} is consistent

### Key Proven Theorem

The core mathematical result is already proven at `ModalSaturation.lean:418-457`:

```lean
theorem saturated_modal_backward (B : BMCS D) (h_sat : is_modally_saturated B)
    (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families) (phi : Formula) (t : D)
    (h_all : ∀ fam' ∈ B.families, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t
```

**The path to eliminating the axiom**: Construct a BMCS that is provably saturated, then use this theorem.

## Well-Founded Recursion Patterns from Mathlib

### Relevant Lemmas Found

| Lemma | Module | Purpose |
|-------|--------|---------|
| `Finset.isWF` | Mathlib.Order.WellFoundedSet | Finsets are well-founded |
| `Set.Finite.isWF` | Mathlib.Order.WellFoundedSet | Finite sets are well-founded |
| `Finset.card_lt_card` | Mathlib.Data.Finset.Card | `s ⊂ t -> s.card < t.card` |
| `Finset.card_erase_lt_of_mem` | Mathlib.Data.Finset.Card | Erasing decreases card |
| `Finset.exists_mem_notMem_of_card_lt_card` | Mathlib.Data.Finset.Card | Card difference implies element difference |
| `Nat.decreasingInduction` | Mathlib.Data.Nat.Init | Induction on decreasing naturals |

### Recommended Termination Pattern

Use `termination_by` with `Finset.card` on unsatisfied Diamond formulas:

```lean
def saturateFamilies (phi : Formula) (families : Set (IndexedMCSFamily D))
    (unsatisfied : Finset Formula) : Set (IndexedMCSFamily D) :=
  if h : unsatisfied.Nonempty then
    let ⟨diamond, h_mem⟩ := h
    let inner := extractDiamondInner diamond |>.get!  -- extract psi from Diamond psi
    -- Get witness for this Diamond formula
    let h_cons := ... -- prove {inner} is consistent
    let witness := constructWitnessFamily inner h_cons
    let new_families := families ∪ {witness}
    let new_unsatisfied := unsatisfied.erase diamond  -- or compute fresh
    saturateFamilies phi new_families new_unsatisfied
  else
    families
termination_by unsatisfied.card
decreasing_by simp [Finset.card_erase_lt_of_mem, h_mem]
```

### Alternative: Finset.strongInduction

Mathlib provides `Finset.strongInduction` for recursion on finsets:

```lean
def Finset.strongInduction {α : Type*} {p : Finset α → Sort*}
    (H : ∀ s, (∀ t, t ⊂ s → p t) → p s) : ∀ s, p s
```

This enables defining the saturation by strong induction on the set of unsatisfied Diamond formulas.

## Termination Measure Analysis

### Why Closure is Finite

The subformula closure of any formula phi is finite:
- `subformulaClosure phi : Finset Formula` is a `Finset`, not `Set`
- `diamondSubformulas phi ⊆ subformulaClosure phi`
- `diamondCount phi := (diamondSubformulas phi).card` is a natural number

### Termination Argument

The saturation loop terminates because:
1. We only need witnesses for Diamond formulas in `diamondSubformulas phi`
2. Each step either:
   - Satisfies at least one Diamond formula (reduces unsatisfied count)
   - Or finds existing witness (no new family needed)
3. The measure `diamondCount - satisfied_count` strictly decreases
4. Bounded below by 0, so terminates

### Key Insight: Witnesses Don't Create New Requirements

When we add a witness family for `Diamond psi`:
- The witness MCS contains psi at all times (by construction)
- This satisfies the Diamond psi requirement
- New Diamond formulas in the witness MCS are OUTSIDE the closure
- We only require saturation for closure formulas

This is the critical insight that makes termination work.

## Remaining Sorries Analysis

### Sorry 1: `FamilyCollection.toBMCS.modal_forward` (Line 279)

**Location**: `SaturatedConstruction.lean:279`

**Challenge**: Proving that Box phi in any family propagates phi to all families.

**Proof Strategy**:
1. Use the T-axiom: `Box phi -> phi` gives phi in the original family
2. For other families, need to track that all families "share" boxed formulas
3. This requires adding structure to FamilyCollection: a constraint that all families agree on boxed formulas at each time

**Estimated Effort**: Medium (4-6 hours)

**Approach**: Add a `box_coherence` field to FamilyCollection ensuring:
```lean
box_coherence : ∀ fam ∈ families, ∀ phi t,
  Formula.box phi ∈ fam.mcs t → ∀ fam' ∈ families, phi ∈ fam'.mcs t
```

Then modal_forward follows directly.

### Sorry 2: `FamilyCollection.toBMCS.modal_backward` (Line 284)

**Location**: `SaturatedConstruction.lean:284`

**Challenge**: Proving that phi in all families implies Box phi in each family.

**Proof Strategy**:
1. Use `closure_saturation_implies_modal_backward_for_closure` (already proven!)
2. Requires phi and neg phi both in closure
3. For completeness theorem, this is guaranteed because we work within closure

**Estimated Effort**: Low (2-4 hours)

**Approach**: The proof is essentially done in lines 100-141. Just need to:
1. Ensure we're working with closure-restricted formulas
2. Verify neg phi is in closure when phi is (by closureWithNeg construction)
3. Connect saturation predicate to the existing theorem

### Missing Piece: `saturateFamilies` Implementation

**What's Needed**: A function that iteratively adds witness families until saturation.

```lean
noncomputable def saturateFamilies (phi : Formula)
    (initial : IndexedMCSFamily D) : FamilyCollection D phi :=
  -- Implementation using well-founded recursion
```

**Estimated Effort**: High (8-12 hours)

**Key Components**:
1. Track unsatisfied Diamond formulas as `Finset Formula`
2. Pick one unsatisfied Diamond formula
3. Prove inner formula is consistent (via `diamond_implies_psi_consistent`)
4. Construct witness via `constructWitnessFamily`
5. Add witness to collection
6. Recurse with decreased unsatisfied count
7. Prove termination via `Finset.card` decrease

## Implementation Strategy

### Recommended Phases

**Phase 1**: Add `box_coherence` field to FamilyCollection
- Extend structure with coherence property
- Update `isSaturated` definition if needed
- Estimated: 2-3 hours

**Phase 2**: Implement `saturateFamilies` with termination proof
- Define the recursive function
- Track unsatisfied Diamond formulas
- Use `termination_by unsatisfied.card`
- Prove `decreasing_by` obligations
- Estimated: 8-12 hours

**Phase 3**: Prove `modal_forward` in toBMCS
- Use new `box_coherence` field
- Apply T-axiom reasoning
- Estimated: 2-4 hours

**Phase 4**: Prove `modal_backward` in toBMCS
- Connect to `closure_saturation_implies_modal_backward_for_closure`
- Handle closure membership conditions
- Estimated: 2-4 hours

**Phase 5**: Replace axiom with proven construction
- Create `construct_saturated_bmcs` using new infrastructure
- Update Completeness.lean to use new construction
- Verify `singleFamily_modal_backward_axiom` is no longer referenced
- Remove axiom declaration
- Estimated: 2-3 hours

### Total Estimated Effort: 16-26 hours

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Termination proof difficult | High | Medium | Use Finset.strongInduction as fallback |
| Box coherence too restrictive | Medium | Low | Weaken to closure-restricted coherence |
| Witness construction needs new lemmas | Medium | Medium | Reuse existing diamond_implies_psi_consistent |
| Integration breaks existing proofs | Low | Low | Add new construction, don't modify old |

## Key Questions Answered

### Q1: What termination measure should be used for saturateFamilies?

**Answer**: Use `(diamondSubformulas phi \ satisfiedDiamonds).card` or track an explicit `unsatisfied : Finset Formula` that decreases each step. The relevant Mathlib lemma is `Finset.card_erase_lt_of_mem`.

### Q2: How to prove modal_forward is preserved when adding witness families?

**Answer**: Add a `box_coherence` field to FamilyCollection that requires Box phi to propagate to all families. The witness construction must maintain this property by ensuring new families satisfy it (which they do, since witness families are constant MCS).

### Q3: What well-founded recursion patterns from Mathlib are applicable?

**Answer**:
- `Finset.strongInduction` - direct recursion on finsets
- `Finset.card_lt_card` - strict subset implies smaller card
- `Nat.decreasingInduction` - decreasing nat induction
- `termination_by` with `decreasing_by` for custom measures

### Q4: What is the estimated complexity/effort for each sorry?

| Sorry/Component | Complexity | Effort |
|-----------------|------------|--------|
| `modal_forward` in toBMCS | Medium | 2-4 hours |
| `modal_backward` in toBMCS | Low | 2-4 hours |
| `saturateFamilies` implementation | High | 8-12 hours |
| Integration and axiom removal | Low | 2-3 hours |
| **Total** | | **14-23 hours** |

## Recommendations

1. **Start with Phase 2** (saturateFamilies) - this is the core challenge and will clarify what additional structure is needed.

2. **Use termination_by with Finset.card** - this is the most natural fit for the finite closure bound.

3. **Preserve existing theorems** - don't modify `saturated_modal_backward` or `closure_saturation_implies_modal_backward_for_closure`, just use them.

4. **Add box_coherence property** - this makes modal_forward trivial and is mathematically natural.

5. **Test incrementally** - implement saturateFamilies first, verify it compiles, then connect to toBMCS.

## References

- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Current infrastructure
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Saturation theory and witness construction
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Current single-family construction
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Closure infrastructure
- `specs/archive/827_complete_multi_family_bmcs_construction/reports/research-002.md` - Mathematical approach
- Mathlib.Data.Finset.Card - Finset cardinality lemmas
- Mathlib.Order.WellFoundedSet - Well-founded set theory

## Next Steps

1. Create implementation plan with detailed phases
2. Start with `saturateFamilies` skeleton and termination proof
3. Fill in witness construction and coherence preservation
4. Connect to BMCS construction
5. Remove axiom and verify transitively sorry-free
