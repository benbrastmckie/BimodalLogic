# Research Report: Task #133

**Task**: 133 - Build Canonical Model Constructors in Completeness.lean
**Started**: 2026-01-12T10:00:00Z
**Completed**: 2026-01-12T10:45:00Z
**Effort**: Medium-High (25-35 hours estimated)
**Priority**: High (blocks remaining completeness proof)
**Dependencies**: Task 132 (Lindenbaum lemma - completed)
**Sources/Inputs**: Mathlib.Order.Zorn, Bimodal.Semantics.*, Bimodal.ProofSystem.*, Bimodal.Metalogic.DeductionTheorem
**Artifacts**: This report (specs/133_build_canonical_model_constructors_in_completeness/reports/research-001.md)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Task 133 requires implementing 7 axiom stubs in Completeness.lean related to canonical model construction
- The deduction theorem is already fully implemented (`deduction_theorem` in DeductionTheorem.lean), enabling proofs of maximal consistent set properties
- Key challenge: Constructing `canonical_frame : TaskFrame Int` requires proving nullity and compositionality properties for the task relation defined via formula membership
- All required type signatures (TaskFrame, TaskModel, WorldHistory) are well-defined and documented in the codebase
- Recommended approach: Implement in order (1) maximal_consistent_closed, (2) maximal_negation_complete, (3) canonical_task_rel, (4) canonical_frame, (5) canonical_valuation, (6) canonical_model, (7) canonical_history

## Context & Scope

### Current State of Completeness.lean

The file currently contains:
- **Proven**: `set_lindenbaum` - Extends consistent sets to maximal consistent sets (fully proven using Zorn's lemma)
- **Proven supporting lemmas**: `usedFormulas_subset`, `derivation_uses_finite_context`, `finite_list_in_chain_member`, `consistent_chain_union`
- **Type definitions**: `Consistent`, `MaximalConsistent`, `SetConsistent`, `SetMaximalConsistent`, `CanonicalWorldState`, `CanonicalTime`

### Axioms to Implement (7 total)

1. `maximal_consistent_closed` - Maximal consistent sets are deductively closed
2. `maximal_negation_complete` - Maximal consistent sets are negation complete
3. `canonical_task_rel` - Task relation between canonical world states
4. `canonical_frame` - TaskFrame with nullity and compositionality
5. `canonical_valuation` - Valuation based on formula membership
6. `canonical_model` - TaskModel combining frame and valuation
7. `canonical_history` - WorldHistory construction from maximal consistent set

## Findings

### Type Analysis

#### TaskFrame (from Semantics/TaskFrame.lean)

```lean
structure TaskFrame (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T] where
  WorldState : Type
  task_rel : WorldState → T → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

For canonical model:
- `T = Int` (integers as time durations)
- `WorldState = CanonicalWorldState = {Γ : Context // MaximalConsistent Γ}`

#### TaskModel (from Semantics/TaskModel.lean)

```lean
structure TaskModel {T : Type*} [...] (F : TaskFrame T) where
  valuation : F.WorldState → String → Prop
```

For canonical model:
- `valuation Γ p := (Formula.atom p) ∈ Γ.val`

#### WorldHistory (from Semantics/WorldHistory.lean)

```lean
structure WorldHistory {T : Type*} [...] (F : TaskFrame T) where
  domain : T → Prop
  convex : ∀ (x z : T), domain x → domain z → ∀ (y : T), x ≤ y → y ≤ z → domain y
  states : (t : T) → domain t → F.WorldState
  respects_task : ∀ (s t : T) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

### Maximal Consistent Set Properties

#### 1. Deductive Closure (`maximal_consistent_closed`)

**Statement**: `MaximalConsistent Γ → DerivationTree Γ φ → φ ∈ Γ`

**Proof Strategy**:
1. Assume `Γ ⊢ φ` but `φ ∉ Γ`
2. By maximality, `φ :: Γ` is inconsistent, so `φ :: Γ ⊢ ⊥`
3. By deduction theorem (`deduction_theorem` already proven!): `Γ ⊢ φ → ⊥`, i.e., `Γ ⊢ ¬φ`
4. By modus ponens with `Γ ⊢ φ`: `Γ ⊢ ⊥`
5. This contradicts consistency of Γ

**Key Dependency**: `deduction_theorem` from DeductionTheorem.lean (fully implemented)

```lean
noncomputable def deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B
```

#### 2. Negation Completeness (`maximal_negation_complete`)

**Statement**: `MaximalConsistent Γ → φ ∉ Γ → Formula.neg φ ∈ Γ`

**Proof Strategy**:
1. Assume `φ ∉ Γ`
2. By maximality, `φ :: Γ ⊢ ⊥`
3. By deduction theorem: `Γ ⊢ φ → ⊥ = ¬φ`
4. By deductive closure: `¬φ ∈ Γ`

**Note**: This builds on deductive closure.

### Canonical Task Relation

#### Definition Concept

The canonical task relation should capture modal/temporal reachability:

```lean
def canonical_task_rel (Γ : CanonicalWorldState) (t : Int) (Δ : CanonicalWorldState) : Prop :=
  -- All necessary formulas transfer
  (∀ φ, Formula.box φ ∈ Γ.val → φ ∈ Δ.val) ∧
  -- Future formulas transfer for positive time
  (t > 0 → ∀ φ, Formula.all_future φ ∈ Γ.val → φ ∈ Δ.val) ∧
  -- Past formulas transfer for negative time
  (t < 0 → ∀ φ, Formula.all_past φ ∈ Γ.val → φ ∈ Δ.val)
```

#### Nullity Proof

For `canonical_task_rel Γ 0 Γ`:
- Modal transfer: `□φ ∈ Γ → φ ∈ Γ` by T axiom (`□φ → φ`) and deductive closure
- Temporal conditions are vacuously true (0 is neither > 0 nor < 0)

**Required Lemma**: Modal T axiom closure
```lean
lemma box_implies_self_in_maximal (Γ : Context) (φ : Formula)
    (hmax : MaximalConsistent Γ) (h : Formula.box φ ∈ Γ) : φ ∈ Γ
```

Proof: The T axiom `□φ → φ` is derivable. Combined with `□φ ∈ Γ` and modus ponens, we get `Γ ⊢ φ`. By deductive closure, `φ ∈ Γ`.

#### Compositionality Proof

For `canonical_task_rel Γ x Δ → canonical_task_rel Δ y Σ → canonical_task_rel Γ (x+y) Σ`:

This requires careful analysis of how modal and temporal formulas compose. The key insight is:
- Modal 4 axiom (`□φ → □□φ`) enables composing modal transfers
- Temporal 4 axiom (`Fφ → FFφ`) enables composing temporal transfers
- The sign of (x+y) determines which temporal direction applies

**Complexity Note**: Compositionality is the most complex property to prove due to case analysis on time directions.

### Canonical Valuation

Simple membership check:

```lean
def canonical_valuation (Γ : CanonicalWorldState) (p : String) : Bool :=
  decide (Formula.atom p ∈ Γ.val)
```

Or as a `Prop`:

```lean
def canonical_valuation (Γ : CanonicalWorldState) (p : String) : Prop :=
  Formula.atom p ∈ Γ.val
```

### Canonical History Construction

This is the most complex construction. Given a maximal consistent set Γ, we need to build a WorldHistory that:
- Has a convex domain containing 0
- Assigns states at each time in the domain
- Respects the task relation

**Approach Options**:

1. **Full Integer Domain**: Use domain `= fun _ => True` (all integers)
   - Requires: For each t, construct a maximal consistent set Γ_t related to Γ
   - Challenge: Need to show these exist and respect task relation

2. **Singleton Domain**: Use domain `= fun t => t = 0`
   - Simpler: Only need Γ at time 0
   - Trivially convex and respects task relation (vacuously for t ≠ 0)
   - May not be sufficient for full truth lemma

3. **Generated Domain**: Build domain from formulas in Γ
   - More complex but potentially more faithful to canonical construction

**Recommendation**: Start with approach 2 (singleton domain) for initial implementation, then extend to full domain if needed for truth lemma.

### Mathlib Resources

#### From Mathlib.Order.Zorn

- `zorn_subset_nonempty` - Already used in `set_lindenbaum`
  ```lean
  theorem zorn_subset_nonempty {α : Type*} (S : Set (Set α))
    (H : ∀ c ⊆ S, IsChain (· ⊆ ·) c → c.Nonempty → ∃ ub ∈ S, ∀ s ∈ c, s ⊆ ub)
    (x : Set α) (hx : x ∈ S) : ∃ m, x ⊆ m ∧ Maximal (· ∈ S) m
  ```

#### From Mathlib.ModelTheory.Satisfiability

- `FirstOrder.Language.Theory.IsMaximal` - Maximal theory concept (similar pattern)
- `Theory.IsMaximal.mem_iff_models` - Membership iff models (analogous to truth lemma)

**Note**: Mathlib's first-order logic framework is more general than our propositional modal logic. We cannot directly reuse their canonical model construction but can follow similar patterns.

### Formula Structure

From Syntax/Formula.lean:
```lean
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past : Formula → Formula
  | all_future : Formula → Formula
```

Derived operators:
- `neg φ = φ.imp bot`
- `diamond φ = φ.neg.box.neg`
- `some_past φ = φ.neg.all_past.neg`
- `some_future φ = φ.neg.all_future.neg`

### Axiom Schema (for reference)

From ProofSystem/Axioms.lean, relevant axioms for canonical model:
- `modal_t (φ)` : `□φ → φ` - Used for nullity
- `modal_4 (φ)` : `□φ → □□φ` - Used for compositionality
- `modal_k_dist (φ ψ)` : `□(φ → ψ) → (□φ → □ψ)` - Distribution
- `temp_4 (φ)` : `Fφ → FFφ` - Temporal transitivity
- `temp_k_dist (φ ψ)` : `F(φ → ψ) → (Fφ → Fψ)` - Temporal distribution

## Decisions

1. **Use Prop-valued valuation**: `canonical_valuation : CanonicalWorldState → String → Prop` rather than Bool, matching TaskModel's type
2. **Start with singleton domain for canonical_history**: Simplest approach that may suffice
3. **Implement in dependency order**: maximal properties first, then frame, then model/history
4. **Use existing deduction theorem**: No need to re-prove; it's fully implemented

## Recommendations

### Implementation Order

1. **maximal_consistent_closed** (3-4 hours)
   - Straightforward application of deduction theorem
   - Key dependency already proven

2. **maximal_negation_complete** (2-3 hours)
   - Builds directly on (1)
   - Simple proof once closure is established

3. **canonical_task_rel** (4-5 hours)
   - Define the relation as a structure/predicate
   - Careful handling of modal and temporal cases

4. **Nullity proof** (3-4 hours)
   - Prove `∀ Γ, canonical_task_rel Γ 0 Γ`
   - Uses modal T axiom and deductive closure

5. **Compositionality proof** (6-8 hours)
   - Most complex proof
   - Case analysis on time signs
   - Uses 4 axioms for transitivity

6. **canonical_frame** (1 hour)
   - Package the above into TaskFrame structure

7. **canonical_valuation** (1 hour)
   - Simple membership definition

8. **canonical_model** (1 hour)
   - Package frame and valuation

9. **canonical_history** (4-5 hours)
   - Start with singleton domain
   - Prove convexity (trivial for singleton)
   - Prove respects_task (uses nullity for t=0)

### Helper Lemmas to Develop

Before main implementations:

```lean
-- Modal T closure in maximal sets
lemma box_elim_maximal (Γ : Context) (φ : Formula)
    (hmax : MaximalConsistent Γ) (h : Formula.box φ ∈ Γ) : φ ∈ Γ

-- Implication property in maximal sets
lemma imp_elim_maximal (Γ : Context) (φ ψ : Formula)
    (hmax : MaximalConsistent Γ) (h1 : φ.imp ψ ∈ Γ) (h2 : φ ∈ Γ) : ψ ∈ Γ

-- Conjunction property (derived)
lemma and_iff_maximal (Γ : Context) (φ ψ : Formula)
    (hmax : MaximalConsistent Γ) : φ.and ψ ∈ Γ ↔ (φ ∈ Γ ∧ ψ ∈ Γ)

-- Modal 4 property
lemma box_4_maximal (Γ : Context) (φ : Formula)
    (hmax : MaximalConsistent Γ) (h : Formula.box φ ∈ Γ) :
    Formula.box (Formula.box φ) ∈ Γ
```

## Risks & Mitigations

### Risk 1: Compositionality Proof Complexity

**Risk**: The compositionality proof requires intricate case analysis on time signs and may be more complex than estimated.

**Mitigation**:
- Start with modal-only case (t = 0) which is simpler
- Develop helper lemmas incrementally
- Consider splitting into separate lemmas for each case

### Risk 2: Canonical History Domain Choice

**Risk**: Singleton domain may not suffice for the full truth lemma.

**Mitigation**:
- Implement singleton first as MVP
- Document what additional properties would be needed for full domain
- The truth lemma (separate task) will reveal if extension is needed

### Risk 3: Set vs List Context Issues

**Risk**: The codebase uses `Context = List Formula` but maximal consistent sets are inherently infinite.

**Mitigation**:
- Use `Set Formula` internally where possible (already done in set_lindenbaum)
- Accept that some conversions may require `sorry` for now
- Document the mathematical vs implementation gap

### Risk 4: Modal-Temporal Interaction

**Risk**: The MF and TF axioms (`□φ → □Fφ` and `□φ → F□φ`) may require additional infrastructure.

**Mitigation**:
- Focus on pure modal case first
- Temporal extensions can be added incrementally
- The semantic side (Truth.lean) already handles these interactions

## Appendix

### Search Queries Used

1. LeanSearch: "maximal consistent set deductive closure" - Found Mathlib.ModelTheory.Types patterns
2. LeanSearch: "deductive closure of consistent set is consistent" - Limited results
3. Loogle: `zorn_subset_nonempty` - Confirmed usage pattern from set_lindenbaum
4. Loogle: `IsChain (_ ⊆ _)` - Chain lemmas for set operations
5. LeanFinder: "canonical model construction modal logic Lindenbaum lemma" - First-order model theory patterns

### Key Files Examined

1. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/Metalogic/Completeness.lean` - Current implementation
2. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame type
3. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/Semantics/TaskModel.lean` - TaskModel type
4. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory type
5. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/Metalogic/DeductionTheorem.lean` - Deduction theorem (key dependency)
6. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/ProofSystem/Derivation.lean` - DerivationTree structure
7. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/ProofSystem/Axioms.lean` - Axiom schemata
8. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/Semantics/Truth.lean` - Truth evaluation
9. `/home/benjamin/Projects/ProofChecker-refactor-agent_system/Theories/Bimodal/Syntax/Formula.lean` - Formula type

### References

1. Modal Logic, Blackburn et al., Chapter 4 (Canonical Models)
2. Handbook of Modal Logic, van Benthem & Blackburn (2006)
3. Mathlib.ModelTheory.Satisfiability - First-order completeness patterns
4. Mathlib.Order.Zorn - Zorn's lemma infrastructure
