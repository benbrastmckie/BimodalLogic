# Research Report: Task #257

**Task**: Completeness Proofs for TM Bimodal Logic
**Date**: 2026-01-12
**Focus**: Canonical model construction and Mathlib dependencies

## Summary

The completeness proof infrastructure in `Theories/Bimodal/Metalogic/Completeness.lean` is well-documented with type signatures and proof strategies. Implementation requires proving 11 axiom placeholders and 1 sorry. Key dependencies are Zorn's lemma from Mathlib (`zorn_le_nonempty₀`) and the existing deduction theorem. The estimated 70-90 hours effort is realistic given the complexity of the truth lemma mutual induction.

## Findings

### Current Infrastructure Analysis

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`

The file contains:

1. **Type Definitions** (complete):
   - `Consistent (Γ : Context) : Prop` - No derivation of bottom
   - `MaximalConsistent (Γ : Context) : Prop` - Consistent + maximality property
   - `CanonicalWorldState : Type` - Subtype of maximal consistent sets
   - `CanonicalTime : Type` - Alias for `Int`

2. **Axiom Placeholders** (11 total, requiring implementation):

   | Axiom | Type Signature | Est. Effort |
   |-------|---------------|-------------|
   | `lindenbaum` | `Consistent Γ → ∃ Δ, Γ ⊆ Δ ∧ MaximalConsistent Δ` | 15-20 hrs |
   | `maximal_consistent_closed` | `MaximalConsistent Γ → DerivationTree Γ φ → φ ∈ Γ` | 3-4 hrs |
   | `maximal_negation_complete` | `MaximalConsistent Γ → φ ∉ Γ → ¬φ ∈ Γ` | 2-3 hrs |
   | `canonical_task_rel` | `CanonicalWorldState → CanonicalTime → CanonicalWorldState → Prop` | 4-5 hrs |
   | `canonical_frame` | `TaskFrame Int` | 6-8 hrs |
   | `canonical_valuation` | `CanonicalWorldState → String → Bool` | 1-2 hrs |
   | `canonical_model` | `TaskModel canonical_frame` | 2-3 hrs |
   | `canonical_history` | `CanonicalWorldState → WorldHistory canonical_frame` | 4-5 hrs |
   | `truth_lemma` | `φ ∈ Γ.val` (placeholder) | 25-30 hrs |
   | `weak_completeness` | `valid φ → DerivationTree [] φ` | 10-15 hrs |
   | `strong_completeness` | `semantic_consequence Γ φ → DerivationTree Γ φ` | 10-15 hrs |

3. **Theorem with Sorry** (1):
   - `provable_iff_valid` - needs semantic consequence equivalence to validity

### Mathlib Dependencies

**Zorn's Lemma** (critical for Lindenbaum):

```lean
-- From Mathlib.Order.Zorn
theorem zorn_le_nonempty₀ {α : Type*} [Preorder α] (s : Set α)
  (h : ∀ c ⊆ s, IsChain (· ≤ ·) c → ∀ y ∈ c, ∃ ub ∈ s, ∀ z ∈ c, z ≤ ub) :
  ∀ x ∈ s, ∃ m, x ≤ m ∧ Maximal (· ∈ s) m

-- Also available:
theorem zorn_le {α : Type*} [Preorder α]
  (h : ∀ c, IsChain (· ≤ ·) c → BddAbove c) :
  ∃ m, IsMax m
```

**Maximal Element Properties**:
```lean
-- From Mathlib.Order.Max
structure Maximal (P : α → Prop) (x : α) : Prop where
  prop : P x
  and_iff : ∀ y, P y → x ≤ y → y ≤ x
```

### Existing Project Infrastructure

**Deduction Theorem** (`Bimodal/Metalogic/DeductionTheorem.lean`):
- Complete implementation with termination proof
- Key function: `deduction_theorem : (A :: Γ) ⊢ B → Γ ⊢ A.imp B`
- Uses well-founded recursion on derivation height
- Essential for maximal consistent set properties

**Soundness Theorem** (`Bimodal/Metalogic/Soundness.lean`):
- Complete implementation: `soundness : (Γ ⊢ φ) → (Γ ⊨ φ)`
- 14/14 axiom validity lemmas proven
- 7/7 soundness cases handled
- Time-shift invariance techniques for MF/TF axioms

**Derivation System** (`Bimodal/ProofSystem/Derivation.lean`):
- `DerivationTree` is a `Type` (not `Prop`) - enables pattern matching
- Height function computable: `height : DerivationTree Γ φ → Nat`
- 7 inference rules: axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening

**Semantic Types**:
- `TaskFrame T` - frame with WorldState, task_rel, nullity, compositionality
- `WorldHistory F` - histories with domain, states, convexity, task_respect
- `TaskModel F` - model with valuation function
- `truth_at M τ t ht φ` - truth evaluation

### Proof Strategy Analysis

**Lindenbaum's Lemma** (most complex):
1. Define preorder on contexts by inclusion
2. Define set S = {Δ | Γ ⊆ Δ ∧ Consistent Δ}
3. Show chains in S have upper bounds (union of chain)
4. Apply `zorn_le_nonempty₀` to get maximal element
5. Show maximal in S implies MaximalConsistent

Key challenge: Proving union of chain of consistent sets is consistent.
Approach: If union inconsistent, derivation of ⊥ uses finitely many assumptions, all in some Δ_i ⊆ chain.

**Maximal Consistent Properties**:
1. `maximal_consistent_closed`: Use contrapositive + deduction theorem
2. `maximal_negation_complete`: Direct from maximality + deduction theorem

**Canonical Frame Construction**:
1. WorldState := `CanonicalWorldState` (subtype)
2. Time := `Int` (with standard group structure)
3. task_rel: Define via modal/temporal witness transfer
4. Prove nullity: task_rel Γ 0 Γ (reflexivity of □ accessibility)
5. Prove compositionality: Combine temporal chains

**Truth Lemma** (most effort-intensive):
- Mutual induction on formula structure
- 6 cases: atom, bot, imp, box, all_future, all_past
- Atom case: Definition of canonical valuation
- Bot case: Consistency prevents ⊥ ∈ Γ
- Imp case: Maximal consistent implication property
- Box case: Modal saturation (□φ ∈ Γ ↔ ∀ accessible Δ, φ ∈ Δ)
- Temporal cases: Temporal witness properties

### Modal Saturation Lemma (Key for Truth Lemma)

Need to prove: `MaximalConsistent Γ → (□φ ∈ Γ ↔ ∀ Δ accessible from Γ, φ ∈ Δ)`

Direction 1 (→): If □φ ∈ Γ, modal T axiom gives Γ ⊢ φ, so by closure φ ∈ Γ, and similarly for accessible Δ.

Direction 2 (←): Contrapositive. If □φ ∉ Γ, then ◇¬φ ∈ Γ (by negation completeness and duality). Need to construct witness Δ where ¬φ holds. Use Lindenbaum on consistent extension.

### Temporal Witness Properties

For all_future (F):
- If Fφ ∈ Γ, need φ at all future times
- Canonical time uses Int, so t+1 > t always
- Must construct maximal consistent sets at each time point

Challenge: Relating time in the canonical frame to membership in maximal consistent sets.

## Recommendations

### Implementation Order

1. **Phase 1: Maximal Consistent Properties** (5-7 hrs)
   - Prove `maximal_consistent_closed`
   - Prove `maximal_negation_complete`
   - These depend only on deduction theorem

2. **Phase 2: Lindenbaum's Lemma** (15-20 hrs)
   - Import `Mathlib.Order.Zorn`
   - Define consistent extensions preorder
   - Prove chain union is consistent
   - Apply Zorn's lemma

3. **Phase 3: Canonical Frame** (10-15 hrs)
   - Define `canonical_task_rel`
   - Construct `canonical_frame`
   - Prove frame properties (nullity, compositionality)

4. **Phase 4: Canonical Model** (5-8 hrs)
   - Define `canonical_valuation`
   - Construct `canonical_model`
   - Define `canonical_history`

5. **Phase 5: Truth Lemma** (25-30 hrs)
   - Prove modal saturation lemma
   - Prove temporal witness properties
   - Full truth lemma by mutual induction

6. **Phase 6: Completeness Theorems** (10-15 hrs)
   - Prove `weak_completeness`
   - Prove `strong_completeness`
   - Remove sorry from `provable_iff_valid`

### Technical Considerations

1. **Context Representation**: Currently `Context = List Formula`. For Lindenbaum, may need to work with `Set Formula` or quotient by permutation. Consider using Mathlib's `Finset` for finite subsets.

2. **Decidability**: The current definitions don't assume decidable membership. For computational purposes, may need classical axioms throughout.

3. **Universe Issues**: `valid` quantifies over `Type` (not `Type*`) to avoid universe level issues. Ensure canonical model construction respects this.

4. **Termination**: Truth lemma induction must be on formula structure. Ensure well-founded recursion terminates.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Lindenbaum requires infinite sets | High | Use `Set Formula` with Mathlib's set theory |
| Truth lemma mutual recursion issues | High | Use indexed inductive or two-function approach |
| Frame property proofs complex | Medium | Factor into small lemmas |
| Time quantification mismatch | Medium | Carefully align Int with temporal operators |

## Appendix

### Search Queries Used

1. LeanSearch: "Zorn's lemma for extending consistent sets to maximal"
2. LeanSearch: "deduction theorem for propositional logic derivability"
3. LeanSearch: "canonical model construction modal logic completeness proof"
4. Loogle: `IsChain _ _ → BddAbove _`
5. Loogle: `zorn`
6. LeanFinder: "maximal consistent set lindenbaum lemma modal logic"
7. Local search: `DerivationTree`, `semantic_consequence`, `TaskFrame`, `WorldHistory`

### Relevant Mathlib Imports

```lean
import Mathlib.Order.Zorn
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Finite
```

### References

- Completeness.lean file: Lines 1-386
- Soundness.lean file: Lines 1-681
- DeductionTheorem.lean file: Lines 1-454
- Derivation.lean file: Lines 1-313
- Validity.lean file: Lines 1-172
- Mathlib.Order.Zorn documentation
- Modal Logic (Blackburn et al.), Chapter 4
