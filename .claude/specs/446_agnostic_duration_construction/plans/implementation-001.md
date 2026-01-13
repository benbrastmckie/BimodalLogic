# Implementation Plan: Task #446 - Agnostic Duration Construction

- **Task**: 446 - Agnostic Duration Construction
- **Status**: [NOT STARTED]
- **Effort**: 15-20 hours
- **Priority**: Medium
- **Dependencies**: Task 445 (MCS Properties - Completed)
- **Research Inputs**: [research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement order-type based duration construction from chain segments of maximal consistent sets (MCSs). The construction builds Duration as a totally ordered commutative group that remains agnostic about temporal structure - the structure (discrete, dense, or continuous) emerges from the logic's axioms rather than being imposed by the implementation. This is Phase 3 of the completeness proof implementation plan (Task 257).

### Research Integration

Key findings from research-001.md integrated into this plan:
1. **Quotient approach**: Use `Setoid` + `Quotient` for order-type equivalence classes
2. **Grothendieck construction**: Use `Algebra.GrothendieckAddGroup` for monoid-to-group completion
3. **Target typeclass**: `LinearOrderedAddCommGroup` is the target abstraction for Duration
4. **Ordinal pattern**: Follow Mathlib's `Ordinal` construction pattern (order isomorphism quotient)
5. **Key challenges**: Commutativity of order-type addition, totality of Duration order

## Goals & Non-Goals

**Goals**:
- Define `TemporalChain` structure representing maximal linear suborders of MCS reachability
- Define `ChainSegment` structure with convexity property
- Define `orderTypeEquiv` equivalence relation via order isomorphism
- Define `PositiveDuration` as quotient of chain segments under order isomorphism
- Implement `AddCommMonoid PositiveDuration` instance with proven axioms
- Define `Duration` via Grothendieck group construction
- Implement `LinearOrder Duration` instance
- Implement `IsOrderedAddMonoid Duration` instance (translation invariance)

**Non-Goals**:
- Integrating Duration with `CanonicalTime` (Task 447 scope)
- Canonical history construction (Task 450 scope)
- Truth lemma proofs (Task 448 scope)
- Proving completeness theorems (Task 449 scope)
- Optimizing for computational efficiency

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Commutativity proof complexity | High | Medium | Use simpler singleton-based approach first; leverage that segments lie on common total order |
| Totality proof for Duration order | High | Medium | Follow Grothendieck group ordering pattern; every element is p1 - p2 for positive p1, p2 |
| Chain segment formalization issues | Medium | Medium | Prototype structures in isolation before integration; use simplified subtype pattern |
| Mathlib API mismatch | Medium | Low | Study `Algebra.GrothendieckAddGroup` and `OrderIso` APIs first in Phase 1 |
| Type universe issues | Medium | Low | Keep types universe-polymorphic where possible; align with existing Completeness.lean patterns |

## Implementation Phases

### Phase 1: Foundation Types and Imports [IN PROGRESS]

**Goal**: Establish the basic type structures and required Mathlib imports

**Tasks**:
- [ ] Add required Mathlib imports to Completeness.lean:
  - `Mathlib.Order.Hom.Basic` (OrderIso)
  - `Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup`
  - `Mathlib.Algebra.Order.Group.Defs` (LinearOrderedAddCommGroup)
- [ ] Define `TemporalChain` structure:
  ```lean
  structure TemporalChain where
    states : Set CanonicalWorldState
    chain_lin : IsChain (· ≤ ·) states
    nonempty : states.Nonempty
  ```
- [ ] Define `ChainSegment` structure with convexity:
  ```lean
  structure ChainSegment (C : TemporalChain) where
    carrier : Set CanonicalWorldState
    subset : carrier ⊆ C.states
    convex : ∀ x y z, x ∈ carrier → z ∈ carrier → x ≤ y → y ≤ z → y ∈ carrier
  ```
- [ ] Verify definitions compile with `lean_diagnostic_messages`

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add imports and foundation types

**Verification**:
- `lake build Bimodal.Metalogic.Completeness` succeeds
- `lean_diagnostic_messages` shows no errors on new definitions
- `lean_hover_info` confirms type signatures

---

### Phase 2: Order-Type Equivalence [NOT STARTED]

**Goal**: Define order-type equivalence relation and prove it forms a setoid

**Tasks**:
- [ ] Define carrier type for quotient:
  ```lean
  def ChainSegmentSigma := Σ C : TemporalChain, ChainSegment C
  ```
- [ ] Define order-type equivalence relation:
  ```lean
  def orderTypeEquiv (s1 s2 : ChainSegmentSigma) : Prop :=
    Nonempty (s1.2.carrier ≃o s2.2.carrier)
  ```
- [ ] Prove reflexivity: `OrderIso.refl` witness
- [ ] Prove symmetry: `OrderIso.symm` witness
- [ ] Prove transitivity: `OrderIso.trans` composition
- [ ] Bundle into `Setoid ChainSegmentSigma`:
  ```lean
  instance orderTypeSetoid : Setoid ChainSegmentSigma where
    r := orderTypeEquiv
    iseqv := ⟨refl_proof, symm_proof, trans_proof⟩
  ```
- [ ] Define `PositiveDuration` as quotient type:
  ```lean
  def PositiveDuration := Quotient orderTypeSetoid
  ```

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add equivalence relation and quotient

**Verification**:
- `PositiveDuration` type compiles
- Equivalence proofs have no `sorry`
- `lean_goal` at each proof shows correct goal structure

---

### Phase 3: Monoid Operations on PositiveDuration [NOT STARTED]

**Goal**: Define zero, addition, and prove `AddCommMonoid` instance

**Tasks**:
- [ ] Define singleton segment construction (for zero):
  ```lean
  def singletonSegment (w : CanonicalWorldState) : ChainSegmentSigma := ...
  ```
- [ ] Define zero duration:
  ```lean
  noncomputable def PositiveDuration.zero : PositiveDuration :=
    ⟦singletonSegment (some_witness)⟧
  ```
- [ ] Define segment concatenation operation:
  ```lean
  def concatSegments (s1 s2 : ChainSegmentSigma) : ChainSegmentSigma := ...
  ```
- [ ] Prove concatenation respects equivalence (key lemma):
  ```lean
  theorem concat_respects_equiv :
    orderTypeEquiv s1 s1' → orderTypeEquiv s2 s2' →
    orderTypeEquiv (concatSegments s1 s2) (concatSegments s1' s2')
  ```
- [ ] Define addition via `Quotient.lift2`:
  ```lean
  noncomputable def PositiveDuration.add : PositiveDuration → PositiveDuration → PositiveDuration :=
    Quotient.lift₂ (fun s1 s2 => ⟦concatSegments s1 s2⟧) concat_respects_equiv
  ```
- [ ] Prove `add_zero`: singleton is right identity
- [ ] Prove `zero_add`: singleton is left identity
- [ ] Prove `add_assoc`: concatenation associativity
- [ ] Prove `add_comm`: **KEY DIFFICULTY** - order-type sum is commutative
  - Strategy: For finite segments, use `Fintype.orderIsoFinOfCardEq`
  - For general case: segments on common total order can be rearranged
- [ ] Bundle into `AddCommMonoid PositiveDuration` instance

**Timing**: 5-7 hours (commutativity is the main challenge)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add monoid operations and proofs

**Verification**:
- `AddCommMonoid PositiveDuration` instance compiles
- All axiom proofs have no `sorry`
- `lean_hover_info` on `PositiveDuration` shows `AddCommMonoid` instance

---

### Phase 4: Duration via Grothendieck Construction [NOT STARTED]

**Goal**: Apply Grothendieck construction to get full group, define ordering

**Tasks**:
- [ ] Define Duration as Grothendieck group:
  ```lean
  def Duration := Algebra.GrothendieckAddGroup PositiveDuration
  ```
- [ ] Verify automatic `AddCommGroup Duration` instance from Mathlib
- [ ] Define embedding from PositiveDuration to Duration:
  ```lean
  def positiveToDuration : PositiveDuration →+ Duration :=
    Algebra.GrothendieckAddGroup.of
  ```
- [ ] Prove embedding is injective (requires `IsCancelAdd PositiveDuration`)
- [ ] Define ordering on Duration:
  ```lean
  instance : LE Duration where
    le d1 d2 := ∃ p : PositiveDuration, d1 + positiveToDuration p = d2
  ```
- [ ] Prove `le_refl`: `⟨0, add_zero d⟩`
- [ ] Prove `le_trans`: compose positive differences
- [ ] Prove `le_antisymm`: by group cancellation
- [ ] Prove `le_total`: **KEY DIFFICULTY** - totality requires showing every difference is positive or negative
  - Strategy: Every Duration element is `p1 - p2` for positive p1, p2; compare via difference
- [ ] Bundle into `LinearOrder Duration` instance

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add Grothendieck construction and ordering

**Verification**:
- `Duration` type compiles with `AddCommGroup` and `LinearOrder` instances
- `lean_hover_info` on `Duration` shows both instances
- Ordering proofs have no `sorry`

---

### Phase 5: Ordered Group Integration [NOT STARTED]

**Goal**: Prove translation invariance and establish `LinearOrderedAddCommGroup` instance

**Tasks**:
- [ ] Prove `add_le_add_left`: translation invariance
  ```lean
  theorem add_le_add_left (a b : Duration) (h : a ≤ b) (c : Duration) : c + a ≤ c + b := ...
  ```
- [ ] Bundle into `OrderedAddCommGroup Duration` instance
- [ ] Verify `LinearOrderedAddCommGroup Duration` instance synthesizes (combines LinearOrder + OrderedAddCommGroup)
- [ ] Create type alias or section for canonical time:
  ```lean
  -- Replace the existing CanonicalTime := Int with:
  -- def CanonicalTime : Type := Duration
  -- (or leave as comment for Task 447 integration)
  ```
- [ ] Add documentation comments explaining the agnostic construction
- [ ] Verify no `sorry` remains in duration construction

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Complete the Duration typeclass hierarchy

**Verification**:
- `LinearOrderedAddCommGroup Duration` instance compiles
- `#check @Duration` shows all expected instances
- `lake build Bimodal.Metalogic.Completeness` succeeds with no warnings
- Grep for `sorry` in duration section returns empty

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] `lake build` full project succeeds
- [ ] No `sorry` in duration construction section
- [ ] `#check @Duration` shows `LinearOrderedAddCommGroup` instance
- [ ] `#check @PositiveDuration` shows `AddCommMonoid` instance
- [ ] `#check @positiveToDuration` shows `AddMonoidHom` type
- [ ] `lean_diagnostic_messages` shows no warnings for new declarations
- [ ] `lean_hover_info` on Duration shows expected type signature

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness.lean` - Extended with duration construction
- `.claude/specs/446_agnostic_duration_construction/plans/implementation-001.md` - This plan
- `.claude/specs/446_agnostic_duration_construction/summaries/implementation-summary-YYYYMMDD.md` - Final summary (on completion)

## Rollback/Contingency

If the full agnostic construction proves too complex:

1. **Fallback to Int-based**: Keep existing `CanonicalTime := Int` and document agnostic construction as future work
2. **Relativized approach**: Parameterize completeness by abstract `Duration` type with `[LinearOrderedAddCommGroup Duration]` constraint
3. **Partial construction**: Complete PositiveDuration monoid but use `axiom` for group completion if Grothendieck API issues arise
4. **Research iteration**: If blockers emerge, create research-002.md documenting specific issues

The existing `CanonicalTime := Int` serves as a safe fallback - we can always complete the completeness proof with integers and revisit the agnostic construction later.

## Notes

- This task implements Phase 3 of the parent plan (Task 257, implementation-002.md)
- The commutativity proof (Phase 3) is the novel contribution and main challenge
- Consider extracting to `Duration.lean` if the file becomes too large (>1500 lines)
- The Grothendieck construction handles most group boilerplate automatically
- For Task 447 integration, Duration will replace `CanonicalTime := Int`
- The construction is intentionally abstract - no axioms about discreteness or density
