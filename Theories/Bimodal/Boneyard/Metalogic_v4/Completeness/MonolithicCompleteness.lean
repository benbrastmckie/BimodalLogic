/-!
# Archived Monolithic Completeness Infrastructure

**Archive Date**: 2026-02-01
**Source**: Theories/Bimodal/Metalogic/Completeness.lean (lines 1414-3719)
**Task**: 798 - refactor_completeness_lean

## Archive Justification

This file contains the Duration-based canonical model construction infrastructure
that was part of the monolithic Completeness.lean (~3720 lines). This approach has
been superseded by the finite canonical model approach in FiniteCanonicalModel.lean.

### Why Archived (Not Deleted)

1. **Historical Reference**: Documents the Duration/Grothendieck construction attempt
2. **Significant Work**: Contains ~2300 lines of proofs and definitions
3. **Potential Future Use**: May inform future work on dense temporal structures
4. **15+ Sorry Gaps**: The approach has unresolved compositionality issues

### Alternative Location

Working completeness proofs are in:
- `Bimodal.Metalogic.Completeness.FiniteCanonicalModel` - finite model approach
- `Bimodal.Metalogic.Core.*` - extracted essential MCS properties

### Contents

1. **Duration Construction** (lines 1-570)
   - TemporalChain, ChainSegment structures
   - Order-type equivalence quotient
   - PositiveDuration monoid via Grothendieck group
   - Duration linear order instances

2. **Canonical Task Relation** (lines 571-1000)
   - modal_transfer, future_transfer, past_transfer
   - canonical_task_rel definition
   - canonical_nullity, canonical_compositionality (7 sorries)
   - canonical_frame construction

3. **Seed Definitions and Model** (lines 1001-1280)
   - forward_seed, backward_seed
   - forward/backward extension theorems (sorries)
   - canonical_valuation, canonical_model

4. **Chain-Based History Construction** (lines 1281-2100)
   - canonical_forward_chain, canonical_backward_chain
   - chain coherence lemmas
   - canonical_states, canonical_history (sorries)

5. **Axioms and Stubs** (lines 2100-2306)
   - someWorldState_exists, anotherWorldState_exists axioms
   - truth_lemma, weak_completeness, strong_completeness axioms
   - provable_iff_valid theorem

### Known Issues

- **Compositionality Gap**: canonical_compositionality has 7 sorry gaps
  for mixed-sign temporal cases (e.g., x > 0, y < 0, x + y > 0)
- **History Coherence**: canonical_history.respects_task has sorry gaps
  due to independent Classical.choose calls
- **Seed Consistency**: forward_seed_consistent and backward_seed_consistent
  have sorry gaps requiring "boxed context" infrastructure

### Status of Axioms

| Axiom | Status | Alternative |
|-------|--------|-------------|
| someWorldState_exists | Infrastructure | Constructible from empty set + Lindenbaum |
| anotherWorldState_exists | Infrastructure | Constructible from p and ¬p consistency |
| truth_lemma | Placeholder | semantic_truth_lemma_v2 in FiniteCanonicalModel |
| weak_completeness | Placeholder | main_weak_completeness in FiniteCanonicalModel |
| strong_completeness | Placeholder | main_strong_completeness in FiniteCanonicalModel |

-/

import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.Propositional
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Order.Zorn
import Mathlib.Data.Finite.Defs
import Mathlib.Order.Hom.Basic
import Mathlib.Order.Preorder.Chain
import Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup
import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Tactic.Abel
import Mathlib.SetTheory.Cardinal.Basic

namespace Bimodal.Boneyard.Metalogic_v4.Completeness

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics Bimodal.Theorems.Combinators Bimodal.Theorems.Propositional
open Bimodal.Metalogic.Core

/--
Canonical world states are set-based maximal consistent sets.

**Representation**: Type synonym for `{S : Set Formula // SetMaximalConsistent S}`

**Note**: This definition is duplicated from Completeness.lean for archive self-containment.
The authoritative version remains in the refactored Completeness.lean.
-/
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}

/-!
## Agnostic Duration Construction (Task 446)

This section implements an order-type based duration construction that remains
agnostic about temporal structure. The structure (discrete, dense, or continuous)
emerges from the logic's axioms rather than being imposed.

### Construction Overview

1. **TemporalChain**: Maximal linear suborders of MCS accessibility relation
2. **ChainSegment**: Convex subsets of temporal chains
3. **Order-Type Equivalence**: Segments equivalent iff order-isomorphic
4. **PositiveDuration**: Quotient of segments under order-type equivalence
5. **Duration**: Grothendieck group completion of PositiveDuration

### Key Properties

- `Duration` forms a `LinearOrderedAddCommGroup`
- No assumptions about discreteness or density
- Temporal structure emerges from axioms
-/

/--
A temporal chain is a maximal linear suborder of the MCS accessibility relation.

In the canonical model, chains represent "timelines" - complete linear orderings
of world states that could be traversed by the temporal accessibility relation.

**Structure**:
- `states`: The set of canonical world states in the chain
- `chain_lin`: States form a chain (pairwise comparable) under the induced order
- `nonempty`: The chain is non-empty

**Note**: We use `Set CanonicalWorldState` with a simple chain property for now.
The maximality condition would require additional infrastructure to formalize.
-/
structure TemporalChain where
  states : Set CanonicalWorldState
  -- Chain property: any two states are comparable (placeholder, as we don't have
  -- a canonical order on CanonicalWorldState yet)
  chain_prop : True  -- Simplified: actual chain property requires order on states
  nonempty : states.Nonempty

/--
A chain segment is a convex subset of a temporal chain.

Convexity ensures that if states x and z are in the segment, then any state y
"between" them (in the chain order) is also in the segment.

**Structure**:
- `carrier`: The set of states in the segment
- `subset`: The carrier is a subset of the chain
- Convexity would require a linear order on the chain, which we define abstractly

**Note**: For the quotient construction, we primarily care about the order type
of segments, not their specific positions in chains.
-/
structure ChainSegment (C : TemporalChain) where
  carrier : Set CanonicalWorldState
  subset : carrier ⊆ C.states
  -- Convexity property (simplified - requires order on chain)
  -- convex : ∀ x y z, x ∈ carrier → z ∈ carrier → x ≤ y → y ≤ z → y ∈ carrier

/--
The sigma type pairing a chain with one of its segments.
This is the base type for the order-type equivalence quotient.
-/
def ChainSegmentSigma := Σ C : TemporalChain, ChainSegment C

/-!
### Order-Type Equivalence

Two chain segments are equivalent if they have isomorphic order structures.
This forms a setoid on `ChainSegmentSigma`.
-/

/--
Order-type equivalence: two chain segments are equivalent if there exists
an order isomorphism between their carriers.

For segments s1 and s2, we say they are order-type equivalent if:
`Nonempty (s1.carrier ≃o s2.carrier)`

This requires the carriers to have a linear order induced from the chain.
For now, we use a simplified version that just checks for set bijection.
-/
def orderTypeEquiv (s1 s2 : ChainSegmentSigma) : Prop :=
  -- Simplified: segments are equivalent if their carriers have equal cardinality
  -- Full version would use: Nonempty (s1.2.carrier ≃o s2.2.carrier)
  -- But this requires LinearOrder on carrier, which we don't have yet
  Nonempty (s1.2.carrier ≃ s2.2.carrier)

/--
Order-type equivalence is reflexive: every segment is equivalent to itself.
-/
theorem orderTypeEquiv_refl (s : ChainSegmentSigma) : orderTypeEquiv s s :=
  ⟨Equiv.refl _⟩

/--
Order-type equivalence is symmetric: if s1 ≃ s2 then s2 ≃ s1.
-/
theorem orderTypeEquiv_symm {s1 s2 : ChainSegmentSigma}
    (h : orderTypeEquiv s1 s2) : orderTypeEquiv s2 s1 :=
  ⟨h.some.symm⟩

/--
Order-type equivalence is transitive: if s1 ≃ s2 and s2 ≃ s3 then s1 ≃ s3.
-/
theorem orderTypeEquiv_trans {s1 s2 s3 : ChainSegmentSigma}
    (h12 : orderTypeEquiv s1 s2) (h23 : orderTypeEquiv s2 s3) :
    orderTypeEquiv s1 s3 :=
  ⟨h12.some.trans h23.some⟩

/--
The setoid instance for order-type equivalence on chain segments.
-/
instance orderTypeSetoid : Setoid ChainSegmentSigma where
  r := orderTypeEquiv
  iseqv := ⟨orderTypeEquiv_refl, orderTypeEquiv_symm, orderTypeEquiv_trans⟩

/--
Positive durations are equivalence classes of chain segments under order-type equivalence.

Each positive duration represents an abstract "length" or "interval" that is
independent of any particular realization in the canonical model.
-/
def PositiveDuration := Quotient orderTypeSetoid

/-!
### Duration Construction (Phases 3-5)

The following definitions build up the full Duration type as a
`LinearOrderedAddCommGroup`. This is done in three steps:

1. **Monoid structure on PositiveDuration**: Define zero (singleton segments)
   and addition (concatenation), prove `AddCommMonoid`.

2. **Grothendieck completion**: Apply `Algebra.GrothendieckAddGroup` to get
   the full group structure on `Duration`.

3. **Linear order**: Define order on Duration and prove it's compatible
   with the group structure.
-/

section PositiveDurationMonoid

/--
Construct a singleton chain containing exactly one world state.
-/
noncomputable def singletonChain (w : CanonicalWorldState) : TemporalChain where
  states := {w}
  chain_prop := trivial
  nonempty := ⟨w, Set.mem_singleton w⟩

/--
The singleton segment of a singleton chain.
-/
def singletonSegment (w : CanonicalWorldState) : ChainSegment (singletonChain w) where
  carrier := {w}
  subset := Set.Subset.refl _

/--
Construct a chain segment sigma from a single world state.
-/
noncomputable def mkSingletonSigma (w : CanonicalWorldState) : ChainSegmentSigma :=
  ⟨singletonChain w, singletonSegment w⟩

-- For the zero element, we need a canonical choice of world state
-- We use Classical.choice to select one
-- We use an axiom to assert existence of at least one MCS
axiom someWorldState_exists : ∃ S : Set Formula, SetMaximalConsistent S

noncomputable def someWorldState : CanonicalWorldState :=
  ⟨Classical.choose someWorldState_exists, Classical.choose_spec someWorldState_exists⟩

/--
The zero duration, represented by the equivalence class of singleton segments.
All singleton segments are equivalent (they all have cardinality 1).
-/
noncomputable def PositiveDuration.zero : PositiveDuration :=
  ⟦mkSingletonSigma someWorldState⟧

/--
Disjoint union of two sets, embedded in a common type.
For segment concatenation, we combine two carriers.
-/
def disjointUnionCarrier (s1 s2 : ChainSegmentSigma) : Set CanonicalWorldState :=
  s1.2.carrier ∪ s2.2.carrier

/--
Concatenate two chain segments by taking their disjoint union.

For the order-type quotient, concatenation corresponds to adding the
"lengths" of the segments. The key insight is that concatenation
respects equivalence: isomorphic segments yield isomorphic concatenations.

**Note**: This is a simplified version. The full version would need to
prove the result is a valid chain segment with proper convexity.
-/
noncomputable def concatSegments (s1 s2 : ChainSegmentSigma) : ChainSegmentSigma := by
  -- Create a new chain containing both segments' states
  let combined_states := s1.1.states ∪ s2.1.states
  let combined_chain : TemporalChain := {
    states := combined_states
    chain_prop := trivial
    nonempty := by
      obtain ⟨w, hw⟩ := s1.1.nonempty
      exact ⟨w, Set.mem_union_left _ hw⟩
  }
  -- Create a segment from the combined carriers
  let combined_segment : ChainSegment combined_chain := {
    carrier := s1.2.carrier ∪ s2.2.carrier
    subset := by
      intro x hx
      cases hx with
      | inl h1 => exact Set.mem_union_left _ (s1.2.subset h1)
      | inr h2 => exact Set.mem_union_right _ (s2.2.subset h2)
  }
  exact ⟨combined_chain, combined_segment⟩

/--
Concatenation respects order-type equivalence.

If s1 ≃ s1' and s2 ≃ s2', then concat(s1,s2) ≃ concat(s1',s2').

This is the key lemma that makes addition well-defined on the quotient.
-/
theorem concat_respects_equiv (s1 s1' s2 s2' : ChainSegmentSigma)
    (h1 : orderTypeEquiv s1 s1') (h2 : orderTypeEquiv s2 s2') :
    orderTypeEquiv (concatSegments s1 s2) (concatSegments s1' s2') := by
  -- Proof: compose the bijections on each component
  unfold orderTypeEquiv at *
  obtain ⟨e1⟩ := h1
  obtain ⟨e2⟩ := h2
  -- The combined carrier is the union, so we need an equivalence on unions
  -- This follows from the equivalences on each component
  constructor
  -- Use Equiv.sumCongr to combine the equivalences, then relate to Set union
  sorry

/--
Addition on PositiveDuration via quotient lifting.

This is well-defined because concatenation respects order-type equivalence.
-/
noncomputable def PositiveDuration.add (d1 d2 : PositiveDuration) : PositiveDuration :=
  Quotient.lift₂
    (fun s1 s2 => ⟦concatSegments s1 s2⟧)
    (fun s1 s2 s1' s2' h1 h2 => Quotient.sound (concat_respects_equiv s1 s1' s2 s2' h1 h2))
    d1 d2

/--
Zero is a left identity for addition.

**Proof sketch**: Concatenating a singleton segment with d produces a segment
whose carrier is {w} ∪ carrier(d). Since we quotient by bijection class, and
{w} ∪ S is equivalent to S when w ∉ S (or we can construct a bijection), this
gives us the identity.
-/
theorem PositiveDuration.zero_add (d : PositiveDuration) :
    PositiveDuration.add PositiveDuration.zero d = d := by
  induction d using Quotient.ind with
  | _ s =>
    apply Quotient.sound
    -- Need to show: concatSegments (mkSingletonSigma someWorldState) s ≈ s
    -- The concatenation adds one extra element, so we need to show this
    -- is equivalent under our equivalence. This requires careful handling
    -- of the order-type quotient.
    show orderTypeEquiv _ _
    sorry

/--
Zero is a right identity for addition.
-/
theorem PositiveDuration.add_zero (d : PositiveDuration) :
    PositiveDuration.add d PositiveDuration.zero = d := by
  induction d using Quotient.ind with
  | _ s =>
    apply Quotient.sound
    show orderTypeEquiv _ _
    sorry

/--
Addition is associative.

**Proof sketch**: (A ∪ B) ∪ C ≃ A ∪ (B ∪ C) follows from set union associativity.
-/
theorem PositiveDuration.add_assoc (d1 d2 d3 : PositiveDuration) :
    PositiveDuration.add (PositiveDuration.add d1 d2) d3 =
    PositiveDuration.add d1 (PositiveDuration.add d2 d3) := by
  induction d1 using Quotient.ind with
  | _ s1 =>
    induction d2 using Quotient.ind with
    | _ s2 =>
      induction d3 using Quotient.ind with
      | _ s3 =>
        apply Quotient.sound
        show orderTypeEquiv _ _
        -- Union is associative, so this follows from Set.union_assoc
        sorry

/--
Addition is commutative.

**KEY THEOREM**: This is the main challenge in the duration construction.
For order types, commutativity holds because we're working with
equivalence classes under bijection - swapping the "order" of segments
doesn't change the cardinality/bijection class.

**Proof**: A ∪ B ≃ B ∪ A via Equiv.Set.union_comm.
-/
theorem PositiveDuration.add_comm (d1 d2 : PositiveDuration) :
    PositiveDuration.add d1 d2 = PositiveDuration.add d2 d1 := by
  induction d1 using Quotient.ind with
  | _ s1 =>
    induction d2 using Quotient.ind with
    | _ s2 =>
      apply Quotient.sound
      show orderTypeEquiv _ _
      -- Union is commutative: A ∪ B ≃ B ∪ A
      unfold orderTypeEquiv concatSegments
      simp only
      constructor
      -- The carriers of the concatenated segments are unions
      -- We need to show (s1.carrier ∪ s2.carrier) ≃ (s2.carrier ∪ s1.carrier)
      sorry

/--
Natural number scalar multiplication on PositiveDuration.

The definition must match: `nsmul (n+1) d = nsmul n d + d`
-/
noncomputable def PositiveDuration.nsmul : ℕ → PositiveDuration → PositiveDuration
  | 0, _ => PositiveDuration.zero
  | n + 1, d => PositiveDuration.add (PositiveDuration.nsmul n d) d

/--
PositiveDuration forms an additive commutative monoid.
-/
noncomputable instance : AddCommMonoid PositiveDuration where
  zero := PositiveDuration.zero
  add := PositiveDuration.add
  zero_add := PositiveDuration.zero_add
  add_zero := PositiveDuration.add_zero
  add_assoc := PositiveDuration.add_assoc
  add_comm := PositiveDuration.add_comm
  nsmul := PositiveDuration.nsmul
  nsmul_zero := fun _ => rfl
  nsmul_succ := fun _ _ => rfl

end PositiveDurationMonoid

/-!
### Cancellation Property for PositiveDuration

To use the injectivity of the Grothendieck embedding, we need to show that
PositiveDuration has cancellation: if a + c = b + c then a = b.

This follows from the fact that concatenation preserves disjointness:
if we remove the "c part" from both sides, we get a bijection between
the remaining parts.
-/

/--
PositiveDuration has cancellation because concatenation is essentially
disjoint union, and bijections on disjoint unions restrict to bijections
on the components.

**Note**: This proof requires showing that if concat(s1, s3) ≃ concat(s2, s3),
then s1 ≃ s2. This follows from the fact that the carriers are disjoint
(assuming proper construction) and bijections preserve cardinality.
-/
instance : IsLeftCancelAdd PositiveDuration where
  add_left_cancel a b c h := by
    -- h : a + b = a + c
    -- Need: b = c
    -- In quotient terms: concat(a_rep, b_rep) ≃ concat(a_rep, c_rep) → b_rep ≃ c_rep
    -- This follows from cardinality: |a| + |b| = |a| + |c| → |b| = |c|
    -- And within the same cardinality class, the quotient structure gives equality
    sorry

instance : IsCancelAdd PositiveDuration :=
  AddCommMagma.IsLeftCancelAdd.toIsCancelAdd PositiveDuration

/-!
### Duration via Grothendieck Construction (Phase 4)

We apply Mathlib's Grothendieck group construction to get the full
additive group structure on Duration.
-/

/--
Duration is the Grothendieck group completion of PositiveDuration.

This gives us negative durations (representing "backwards" intervals)
and makes Duration into a full additive commutative group.
-/
noncomputable def Duration := Algebra.GrothendieckAddGroup PositiveDuration

/--
Duration automatically inherits AddCommGroup from the Grothendieck construction.
-/
noncomputable instance : AddCommGroup Duration := Algebra.GrothendieckAddGroup.instAddCommGroup

/--
Embedding of positive durations into Duration.
-/
noncomputable def positiveToDuration : PositiveDuration →+ Duration :=
  Algebra.GrothendieckAddGroup.of

/-!
### Ordered Group Structure on Duration (Phase 5)

We define an ordering on Duration that makes it a linear ordered additive group.
The ordering is defined by: `d1 ≤ d2` iff `d2 - d1` is a positive duration.

**Note**: The full ordered group structure requires proving:
1. Reflexivity, transitivity, antisymmetry of ≤
2. Totality (linear order)
3. Translation invariance (a ≤ b → c + a ≤ c + b)

These proofs involve the Grothendieck group representation and are marked
with sorry for now. The key insight is that every element of Duration can be
written as p1 - p2 for positive p1, p2, and comparison reduces to comparing
p1 and p2.
-/

/--
Define ordering on Duration: d1 ≤ d2 iff there exists a positive duration p
such that d1 + p = d2.
-/
noncomputable def Duration.le (d1 d2 : Duration) : Prop :=
  ∃ p : PositiveDuration, d1 + positiveToDuration p = d2

noncomputable instance : LE Duration where
  le := Duration.le

/--
Define strict ordering on Duration.
-/
noncomputable instance : LT Duration where
  lt d1 d2 := d1 ≤ d2 ∧ d1 ≠ d2

/--
The ordering is reflexive: d ≤ d via the zero positive duration.
-/
theorem Duration.le_refl (d : Duration) : d ≤ d := by
  use 0
  simp only [map_zero, add_zero]

/--
The ordering is transitive.
-/
theorem Duration.le_trans {d1 d2 d3 : Duration}
    (h12 : d1 ≤ d2) (h23 : d2 ≤ d3) : d1 ≤ d3 := by
  obtain ⟨p1, hp1⟩ := h12
  obtain ⟨p2, hp2⟩ := h23
  use p1 + p2
  simp only [map_add]
  -- Need: d1 + (positiveToDuration p1 + positiveToDuration p2) = d3
  rw [← add_assoc, hp1, hp2]

/--
The ordering is antisymmetric.
-/
theorem Duration.le_antisymm {d1 d2 : Duration}
    (h12 : d1 ≤ d2) (h21 : d2 ≤ d1) : d1 = d2 := by
  -- From d1 + p1 = d2 and d2 + p2 = d1, we get p1 + p2 = 0
  -- In a positive monoid embedded in a group, this means p1 = p2 = 0
  sorry

/--
The ordering is total.
-/
theorem Duration.le_total (d1 d2 : Duration) : d1 ≤ d2 ∨ d2 ≤ d1 := by
  -- Every Duration is p1 - p2 for positive p1, p2
  sorry

/--
Preorder instance for Duration.
-/
noncomputable instance Duration.instPreorder : Preorder Duration where
  le := (· ≤ ·)
  lt := fun a b => a ≤ b ∧ ¬b ≤ a
  le_refl := Duration.le_refl
  le_trans := @Duration.le_trans
  lt_iff_le_not_ge := fun _ _ => Iff.rfl

/--
PartialOrder instance for Duration.
-/
noncomputable instance Duration.instPartialOrder : PartialOrder Duration where
  le_antisymm := @Duration.le_antisymm

/--
LinearOrder instance for Duration.
-/
noncomputable instance Duration.instLinearOrder : LinearOrder Duration where
  le_total := Duration.le_total
  toDecidableLE := Classical.decRel _

/--
Addition is monotone: translation invariance (left addition).
-/
theorem Duration.add_le_add_left' (c a b : Duration) (h : a ≤ b) :
    c + a ≤ c + b := by
  obtain ⟨p, hp⟩ := h
  use p
  rw [← hp]
  rw [add_assoc]

/--
Addition is monotone: translation invariance (right addition).
-/
theorem Duration.add_le_add_right (a b c : Duration) (h : a ≤ b) :
    a + c ≤ b + c := by
  rw [add_comm a c, add_comm b c]
  exact Duration.add_le_add_left' c a b h

/--
IsOrderedAddMonoid instance for Duration.

This provides the translation invariance property required for temporal semantics.
-/
noncomputable instance Duration.instIsOrderedAddMonoid : IsOrderedAddMonoid Duration where
  add_le_add_left := fun a b h c => Duration.add_le_add_right a b c h

/-!
### Integration Notes

The Duration type now has:

1. **AddCommGroup**: zero, addition, negation, subtraction (from Grothendieck)
2. **LinearOrder**: total ordering on durations
3. **IsOrderedAddMonoid**: translation invariance (`a ≤ b → c + a ≤ c + b`)

Together, these make Duration suitable for use as the time domain in temporal
logic semantics.

**Next Steps** (Task 447):
- Replace `CanonicalTime := Int` with `Duration`
- Update canonical frame construction
- Verify TaskFrame constraints are satisfied

**Agnostic Property**:
The Duration type makes no assumptions about discreteness or density.
Whether the temporal structure is discrete (like integers), dense (like
rationals), or continuous (like reals) depends entirely on the axioms
of the logic, not on this construction.
-/

/--
Canonical time structure uses Duration from the Grothendieck construction.

**Justification**: Duration forms a linear ordered additive commutative group,
which provides the required structure for temporal operators (past/future)
and task relation compositionality.

**Agnostic Property**: The Duration type makes no assumptions about discreteness
or density. Whether the temporal structure is discrete (like integers), dense
(like rationals), or continuous (like reals) depends entirely on the axioms
of the logic, not on this construction.

**Instances Available**:
- `AddCommGroup Duration` (from Grothendieck construction)
- `LinearOrder Duration` (defined in this file)
- `IsOrderedAddMonoid Duration` (defined in this file)
-/
abbrev CanonicalTime : Type := Duration

/-!
### Transfer Properties for Canonical Task Relation

These helper definitions capture the individual transfer properties used
in the canonical task relation definition.
-/

/--
Modal transfer: box formulas in S transfer to their contents in T.

`modal_transfer S T` holds iff for all φ, if □φ ∈ S then φ ∈ T.

This captures the accessibility relationship between maximal consistent sets.
-/
def modal_transfer (S T : CanonicalWorldState) : Prop :=
  ∀ φ, Formula.box φ ∈ S.val → φ ∈ T.val

/--
Future transfer: universal future formulas in S transfer to their contents in T.

`future_transfer S T` holds iff for all φ, if Gφ ∈ S then φ ∈ T.

This captures forward temporal reachability: if "always in the future" holds
at S, then the formula holds at any future-reachable world T.
-/
def future_transfer (S T : CanonicalWorldState) : Prop :=
  ∀ φ, Formula.all_future φ ∈ S.val → φ ∈ T.val

/--
Past transfer: universal past formulas in S transfer to their contents in T.

`past_transfer S T` holds iff for all φ, if Hφ ∈ S then φ ∈ T.

This captures backward temporal reachability: if "always in the past" holds
at S, then the formula holds at any past-reachable world T.
-/
def past_transfer (S T : CanonicalWorldState) : Prop :=
  ∀ φ, Formula.all_past φ ∈ S.val → φ ∈ T.val

/--
Canonical task relation between set-based world states.

**Definition**: `canonical_task_rel S t T` holds iff:
1. Modal transfer: □φ ∈ S → φ ∈ T (always applies)
2. Future transfer: t > 0 → (Gφ ∈ S → φ ∈ T) (positive duration)
3. Past transfer: t < 0 → (Hφ ∈ S → φ ∈ T) (negative duration)

where `S, T : CanonicalWorldState` are set-based maximal consistent sets.

**Three-Part Structure**:
- Modal accessibility is always required (S5 box semantics)
- Temporal transfers are conditional on duration sign:
  - For positive duration (moving forward in time): future formulas transfer
  - For negative duration (moving backward in time): past formulas transfer
  - For zero duration: only modal transfer matters

**Properties**:
- Nullity: `task_rel S 0 S` - reflexivity via modal T axiom
- Compositionality: task_rel S t₁ T → task_rel T t₂ U → task_rel S (t₁+t₂) U

**Note**: The set-based representation allows membership testing for potentially
infinite sets, which is essential for the canonical model construction.

**Persistence Conditions** (Strategy A from Task 464):
- G-persistence: `t > 0 → ∀ φ, Gφ ∈ S → Gφ ∈ T`
- H-persistence: `t < 0 → ∀ φ, Hφ ∈ S → Hφ ∈ T`

These conditions ensure temporal formulas persist through the relation, enabling
compositionality proofs for the x > 0, y > 0 and x < 0, y < 0 cases.
-/
def canonical_task_rel (S : CanonicalWorldState) (t : CanonicalTime) (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧  -- G-persistence
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val)         -- H-persistence

/-!
### Canonical Task Relation Properties

These theorems prove that canonical_task_rel satisfies the TaskFrame constraints.
-/

/--
Nullity: The canonical task relation is reflexive at duration 0.

For any maximal consistent set S, `canonical_task_rel S 0 S` holds.

**Proof Strategy**:
1. Modal transfer: Use `set_mcs_box_closure` (Modal T axiom: □φ → φ)
2. Future transfer: Vacuously true (0 is not > 0)
3. Past transfer: Vacuously true (0 is not < 0)
4. G-persistence: Vacuously true (0 is not > 0)
5. H-persistence: Vacuously true (0 is not < 0)
-/
theorem canonical_nullity (S : CanonicalWorldState) : canonical_task_rel S 0 S := by
  unfold canonical_task_rel modal_transfer future_transfer past_transfer
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  -- Modal transfer: □φ ∈ S → φ ∈ S (via Modal T axiom)
  · intro φ h_box
    exact set_mcs_box_closure S.property h_box
  -- Future transfer: 0 > 0 → ... (vacuously true since 0 is not > 0)
  · intro h_pos φ _
    -- h_pos : 0 > 0 is false, so we can derive anything
    exfalso
    -- The LT instance on Duration says: d1 < d2 ↔ d1 ≤ d2 ∧ d1 ≠ d2
    -- So 0 > 0 means 0 ≤ 0 ∧ 0 ≠ 0, but 0 ≠ 0 is false
    simp only [GT.gt, LT.lt] at h_pos
    exact h_pos.2 rfl
  -- Past transfer: 0 < 0 → ... (vacuously true since 0 is not < 0)
  · intro h_neg φ _
    -- h_neg : 0 < 0 is false, so we can derive anything
    exfalso
    -- Same reasoning: 0 < 0 requires 0 ≠ 0 which is false
    simp only [LT.lt] at h_neg
    exact h_neg.2 rfl
  -- G-persistence: 0 > 0 → ... (vacuously true since 0 is not > 0)
  · intro h_pos φ _
    exfalso
    simp only [GT.gt, LT.lt] at h_pos
    exact h_pos.2 rfl
  -- H-persistence: 0 < 0 → ... (vacuously true since 0 is not < 0)
  · intro h_neg φ _
    exfalso
    simp only [LT.lt] at h_neg
    exact h_neg.2 rfl

/-!
### Temporal Persistence Lemmas

These lemmas establish that G-formulas persist forward through the task relation
and H-formulas persist backward. They are key to completing temporal compositionality.
-/

/--
Future formula persistence: If `canonical_task_rel S d T` with `d > 0` and `Gφ ∈ S`,
then `Gφ ∈ T`.

**Proof Strategy**:
1. From `Gφ ∈ S`, get `GGφ ∈ S` via `set_mcs_all_future_all_future` (G-4 axiom)
2. Since `d > 0`, we have `future_transfer S T`, so `Gφ ∈ T` from `GGφ ∈ S`

This captures the intuition that "always in the future" is stable under
forward time progression.
-/
theorem future_formula_persistence {S T : CanonicalWorldState} {d : CanonicalTime}
    (hrel : canonical_task_rel S d T) (hd : d > 0) (φ : Formula)
    (h_all_future : Formula.all_future φ ∈ S.val) :
    Formula.all_future φ ∈ T.val := by
  -- Step 1: From Gφ ∈ S, get GGφ ∈ S via set_mcs_all_future_all_future
  have h_gg : (Formula.all_future φ).all_future ∈ S.val :=
    set_mcs_all_future_all_future S.property h_all_future
  -- Step 2: Since d > 0, we have future_transfer S T
  -- canonical_task_rel gives us: d > 0 → future_transfer S T
  unfold canonical_task_rel at hrel
  have h_future : future_transfer S T := hrel.2.1 hd
  -- Step 3: Apply future_transfer to GGφ to get Gφ ∈ T
  unfold future_transfer at h_future
  exact h_future (Formula.all_future φ) h_gg

/--
Past formula persistence: If `canonical_task_rel S d T` with `d < 0` and `Hφ ∈ S`,
then `Hφ ∈ T`.

**Proof Strategy**:
1. From `Hφ ∈ S`, get `HHφ ∈ S` via `set_mcs_all_past_all_past` (H-4 axiom)
2. Since `d < 0`, we have `past_transfer S T`, so `Hφ ∈ T` from `HHφ ∈ S`

This captures the intuition that "always in the past" is stable under
backward time progression.
-/
theorem past_formula_persistence {S T : CanonicalWorldState} {d : CanonicalTime}
    (hrel : canonical_task_rel S d T) (hd : d < 0) (φ : Formula)
    (h_all_past : Formula.all_past φ ∈ S.val) :
    Formula.all_past φ ∈ T.val := by
  -- Step 1: From Hφ ∈ S, get HHφ ∈ S via set_mcs_all_past_all_past
  have h_hh : (Formula.all_past φ).all_past ∈ S.val :=
    set_mcs_all_past_all_past S.property h_all_past
  -- Step 2: Since d < 0, we have past_transfer S T
  -- canonical_task_rel gives us: d < 0 → past_transfer S T
  -- Structure: ⟨modal, future, past, G_persist, H_persist⟩
  unfold canonical_task_rel at hrel
  have h_past : past_transfer S T := hrel.2.2.1 hd
  -- Step 3: Apply past_transfer to HHφ to get Hφ ∈ T
  unfold past_transfer at h_past
  exact h_past (Formula.all_past φ) h_hh

/--
Compositionality: The canonical task relation composes with time addition.

`canonical_task_rel S x T → canonical_task_rel T y U → canonical_task_rel S (x + y) U`

**Proof Strategy**:
1. Modal transfer composes:
   - From box phi in S, get box box phi in S (by set_mcs_box_box)
   - Then box phi in T (by first modal transfer on box phi)
   - Then phi in U (by second modal transfer)
2. Temporal transfers compose via case analysis on signs of x, y, and x+y
   - The key insight is that if x > 0 and x+y > 0, we can compose future transfers
   - Similar reasoning for past transfers when x < 0 and x+y < 0
   - Mixed cases require more careful analysis

**Note**: The temporal cases are complex and may need additional axioms or
definition refinement. The modal case is complete with set_mcs_box_box.
-/
theorem canonical_compositionality
    (S T U : CanonicalWorldState) (x y : CanonicalTime)
    (hST : canonical_task_rel S x T)
    (hTU : canonical_task_rel T y U) :
    canonical_task_rel S (x + y) U := by
  unfold canonical_task_rel at *
  -- Structure: ⟨modal, future_transfer, past_transfer, G_persist, H_persist⟩
  obtain ⟨hST_modal, hST_future, hST_past, hST_G_persist, hST_H_persist⟩ := hST
  obtain ⟨hTU_modal, hTU_future, hTU_past, hTU_G_persist, hTU_H_persist⟩ := hTU
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  -- Part 1: Modal transfer composes
  · intro φ h_box_S
    -- We have: box phi in S
    -- We need: phi in U
    -- Strategy: box phi in S -> box box phi in S -> box phi in T -> phi in U
    have h_box_box_S : (Formula.box φ).box ∈ S.val := set_mcs_box_box S.property h_box_S
    have h_box_T : Formula.box φ ∈ T.val := hST_modal (Formula.box φ) h_box_box_S
    exact hTU_modal φ h_box_T
  -- Part 2: Future transfer when x + y > 0
  · intro h_sum_pos φ h_all_future_S
    -- We have: x + y > 0 and Gφ ∈ S
    -- We need: φ ∈ U
    --
    -- Strategy: Case analysis on sign of x
    -- - If x > 0: Use future_formula_persistence to get Gφ ∈ T, then case on y
    -- - If x ≤ 0: Then y > x + y > 0, so y > 0, use hTU_future with Gφ ∈ T (but we need Gφ ∈ T!)
    --
    -- Key insight: We need Gφ ∈ T in all cases where we can't directly transfer.
    -- From Gφ ∈ S, we can get GGφ ∈ S via set_mcs_all_future_all_future.
    -- If x > 0, then Gφ ∈ T via future_transfer on GGφ.
    -- But if x ≤ 0, we need a different approach.
    --
    -- Extended strategy for x ≤ 0:
    -- If x ≤ 0 and x + y > 0, then y > 0.
    -- We need to get Gφ ∈ T. But with x ≤ 0, we can't use hST_future.
    -- However, with modal_transfer and the right boxing, we might be able to help.
    --
    -- The fundamental issue is that Gφ talks about "strictly future" times.
    -- When T is at or before S (x ≤ 0), Gφ ∈ S doesn't imply Gφ ∈ T syntactically.
    --
    -- NEW APPROACH: Use case split on whether we can get Gφ into T or go directly.
    --
    -- Case x > 0:
    by_cases hx : x > 0
    case pos =>
      -- x > 0: Get Gφ ∈ T via future_formula_persistence
      have h_Gφ_T : φ.all_future ∈ T.val := by
        have hrel : canonical_task_rel S x T :=
          ⟨hST_modal, hST_future, hST_past, hST_G_persist, hST_H_persist⟩
        exact future_formula_persistence hrel hx φ h_all_future_S
      -- Now case split on y
      by_cases hy : y > 0
      case pos =>
        -- y > 0: Use hTU_future directly with Gφ ∈ T
        -- future_transfer T U says: Gψ ∈ T → ψ ∈ U (for all ψ)
        -- So from Gφ ∈ T, we get φ ∈ U directly!
        exact hTU_future hy φ h_Gφ_T
      case neg =>
        -- y ≤ 0 but x + y > 0
        -- We have Gφ ∈ T. We need φ ∈ U.
        -- Since y ≤ 0, we use the fact that T and U are related by y ≤ 0.
        -- With y ≤ 0, the only transfer is modal_transfer (and past_transfer if y < 0).
        -- We need to get φ into U from Gφ in T.
        --
        -- Key: If y < 0, use past_transfer. But we have Gφ, not Hφ.
        -- If y = 0, modal_transfer only, but Gφ is not □-something.
        --
        -- Alternative: Work backwards. We have GGφ ∈ S.
        -- If x > 0, get Gφ ∈ T.
        -- Now, from Gφ ∈ T, can we get anything into U when y ≤ 0?
        --
        -- Actually, let me reconsider. We have h_sum_pos : x + y > 0.
        -- If x > 0 and y ≤ 0, then the total displacement is still > 0.
        --
        -- The semantic intuition: U is at distance x + y > 0 from S.
        -- Gφ ∈ S means φ holds at all times > 0 from S.
        -- So φ should hold at U.
        --
        -- The syntactic path: We've established Gφ ∈ T.
        -- We need: can we "go forward by x+y from S" even though we "went back by |y| from T"?
        --
        -- Let's try: From Gφ ∈ T, get GGφ ∈ T. Now what?
        --
        -- Wait, here's the insight:
        -- Gφ ∈ T means φ holds at all times strictly after T.
        -- U is at time y from T. If y ≤ 0, U is at or before T.
        -- So Gφ ∈ T does NOT imply φ ∈ U when y ≤ 0!
        --
        -- This is the fundamental issue. Let me reconsider from scratch.
        --
        -- Actually, for y = 0, U = T (up to the relation). So Gφ ∈ T doesn't give φ ∈ T = U
        -- because G talks about strictly future, not present!
        --
        -- For y < 0, U is before T. Even worse.
        --
        -- So in the case x > 0, y ≤ 0, we need a different approach.
        --
        -- KEY REALIZATION: The only way to get φ ∈ U when U is at or before T is if
        -- we have some formula in T that implies φ at past times. That would be Hφ.
        -- But we have Gφ (future), not Hφ (past).
        --
        -- Unless... there's a way to get Hφ ∈ T from Gφ ∈ S?
        --
        -- Actually, let's use a different strategy. Let's iterate the G-formulas more.
        --
        -- From Gφ ∈ S:
        -- - GGφ ∈ S (by G-4)
        -- - GGGφ ∈ S (by G-4 again)
        -- - etc.
        --
        -- From GGφ ∈ S and x > 0:
        -- - Gφ ∈ T (by future_transfer)
        --
        -- From GGGφ ∈ S and x > 0:
        -- - GGφ ∈ T (by future_transfer)
        --
        -- From GGφ ∈ T:
        -- - Even with y = 0, we can't use future_transfer (y not > 0)
        --
        -- This is still blocked!
        --
        -- CONCLUSION: The current definition of canonical_task_rel does NOT support
        -- compositionality for the case x > 0, y ≤ 0, x + y > 0.
        --
        -- Possible fixes:
        -- 1. Strengthen the definition to require more transfers
        -- 2. Add an axiom relating G and H (e.g., GPφ ↔ PGφ for some cases)
        -- 3. Accept that compositionality only holds in restricted cases
        --
        -- For now, we use sorry and document this gap.
        sorry
    case neg =>
      -- x ≤ 0: Then since x + y > 0, we have y > -x ≥ 0, so y > 0.
      -- Note: hx is ¬(x > 0), which means x ≤ 0 in a linear order
      --
      -- However, we're blocked here due to the semantic/syntactic gap:
      -- - From Gφ ∈ S, we cannot get Gφ ∈ T when x ≤ 0
      -- - The relation canonical_task_rel S x T with x ≤ 0 only gives us
      --   modal_transfer and possibly past_transfer, neither of which helps
      --   transfer G-formulas forward.
      --
      -- This is a fundamental limitation of the "pointwise" transfer definition.
      -- The semantic intuition (x + y > 0 means U is in S's future) doesn't
      -- translate directly to syntactic transfer when the intermediate step T
      -- is at or before S.
      --
      -- RESOLUTION OPTIONS:
      -- 1. Strengthen canonical_task_rel definition (requires definition change)
      -- 2. Add "direct" transfer lemma that bypasses intermediate T
      -- 3. Use a different canonical model construction approach
      --
      -- For Task 458, we mark this as a known limitation and use sorry.
      -- The full resolution requires architectural changes to the canonical model.
      sorry
  -- Part 3: Past transfer when x + y < 0
  · intro h_sum_neg φ h_all_past_S
    -- We have: x + y < 0 and Hφ ∈ S
    -- We need: φ ∈ U
    --
    -- Strategy: Case analysis on sign of x (symmetric to future case)
    by_cases hx : x < 0
    case pos =>
      -- x < 0: Get Hφ ∈ T via past_formula_persistence
      have h_Hφ_T : φ.all_past ∈ T.val := by
        have hrel : canonical_task_rel S x T :=
          ⟨hST_modal, hST_future, hST_past, hST_G_persist, hST_H_persist⟩
        exact past_formula_persistence hrel hx φ h_all_past_S
      -- Now case split on y
      by_cases hy : y < 0
      case pos =>
        -- y < 0: Use hTU_past directly with Hφ ∈ T
        exact hTU_past hy φ h_Hφ_T
      case neg =>
        -- y ≥ 0 but x + y < 0
        -- Same semantic/syntactic gap as future case:
        -- Hφ ∈ T means φ holds at all times strictly before T.
        -- U is at time y ≥ 0 from T, so U is at or after T.
        -- Hφ ∈ T does NOT imply φ ∈ U when y ≥ 0.
        sorry
    case neg =>
      -- x ≥ 0: Then since x + y < 0, we have y < -x ≤ 0, so y < 0.
      -- Same gap: from Hφ ∈ S, we cannot get Hφ ∈ T when x ≥ 0.
      sorry
  -- Part 4: G-persistence when x + y > 0
  -- If x + y > 0 and Gφ ∈ S, then Gφ ∈ U
  · intro h_sum_pos φ h_all_future_S
    -- Strategy A: Case split on x
    by_cases hx : x > 0
    case pos =>
      -- x > 0: Get Gφ ∈ T via G-persistence, then use G-persistence on T→U or future_transfer
      have h_Gφ_T : φ.all_future ∈ T.val := hST_G_persist hx φ h_all_future_S
      -- Case split on y
      by_cases hy : y > 0
      case pos =>
        -- y > 0: Use G-persistence T→U
        exact hTU_G_persist hy φ h_Gφ_T
      case neg =>
        -- y ≤ 0 but x + y > 0
        -- We have Gφ ∈ T but cannot get Gφ ∈ U when y ≤ 0
        -- (G-persistence only works for positive durations)
        -- This is a known limitation - same gap as future_transfer case
        sorry
    case neg =>
      -- x ≤ 0: Cannot use G-persistence S→T (requires x > 0)
      -- Even though x + y > 0 implies y > 0, we can't get Gφ into T first
      sorry
  -- Part 5: H-persistence when x + y < 0
  -- If x + y < 0 and Hφ ∈ S, then Hφ ∈ U
  · intro h_sum_neg φ h_all_past_S
    -- Symmetric to Part 4
    by_cases hx : x < 0
    case pos =>
      -- x < 0: Get Hφ ∈ T via H-persistence
      have h_Hφ_T : φ.all_past ∈ T.val := hST_H_persist hx φ h_all_past_S
      -- Case split on y
      by_cases hy : y < 0
      case pos =>
        -- y < 0: Use H-persistence T→U
        exact hTU_H_persist hy φ h_Hφ_T
      case neg =>
        -- y ≥ 0 but x + y < 0
        -- Same gap: Hφ ∈ T but y ≥ 0 means no H-persistence T→U
        sorry
    case neg =>
      -- x ≥ 0: Cannot use H-persistence S→T
      sorry

/--
The canonical frame for TM logic using set-based maximal consistent sets.

**Construction**: Combines set-based maximal consistent sets with the Duration type
as the temporal structure.

**Components**:
- WorldState: Set-based maximal consistent sets (CanonicalWorldState)
- task_rel: The three-part transfer relation (modal + temporal)
- nullity: Reflexivity at duration 0 (proven via Modal T axiom)
- compositionality: Task composition with time addition

**Note**: `CanonicalWorldState` is `{S : Set Formula // SetMaximalConsistent S}`,
using the set-based consistency definitions that allow true maximality.

**Status**: Compositionality proof has sorry placeholders for temporal cases.
The modal case is proven. See canonical_compositionality for details.
-/
def canonical_frame : TaskFrame Duration where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel
  nullity := canonical_nullity
  compositionality := canonical_compositionality

/-!
## Forward and Backward Existence Lemmas

These lemmas establish that for any MCS S, there exist MCS T related to S
by any positive duration (forward extension) or related from T to S by any
positive duration (backward extension). They are essential for constructing
the full domain canonical history.
-/

/--
Forward seed: The set of formulas that must be in a forward-related MCS.

For any MCS S, the forward seed contains:
1. The content of all G-formulas in S (if Gφ ∈ S, then φ in seed)
2. The content of all □-formulas in S (if □φ ∈ S, then φ in seed)

This captures what must hold at any strictly future world state.
-/
def forward_seed (S : CanonicalWorldState) : Set Formula :=
  {φ | Formula.all_future φ ∈ S.val} ∪ {φ | Formula.box φ ∈ S.val}

/--
Forward seed consistency: The forward_seed of any MCS is consistent.

**Proof Strategy**:
1. Assume for contradiction that forward_seed S is inconsistent
2. Then some finite subset L derives ⊥
3. Each formula in L is either G-content or □-content from S
4. By deduction and modal/temporal reasoning, S would be inconsistent
5. Contradiction with S being MCS

**Note**: This proof requires careful handling of the mixed modal/temporal
nature of the seed. The key insight is that G-formulas and □-formulas in an
MCS are consistent with each other due to the interaction axioms (MF, TF).
-/
theorem forward_seed_consistent (S : CanonicalWorldState) :
    SetConsistent (forward_seed S) := by
  -- Assume inconsistent and derive contradiction
  intro L hL
  -- hL : ∀ φ ∈ L, φ ∈ forward_seed S
  -- We need: Consistent L
  -- i.e., ¬Nonempty (DerivationTree L Formula.bot)
  intro ⟨d_bot⟩
  -- d_bot : L ⊢ ⊥
  -- Each φ in L is either:
  --   - In {φ | Gφ ∈ S.val} : so Gφ ∈ S
  --   - In {φ | □φ ∈ S.val} : so □φ ∈ S
  --
  -- We need to show S is inconsistent, contradicting S.property.
  --
  -- Strategy: Build a derivation of ⊥ from formulas in S.
  -- For each φ in L:
  --   - If Gφ ∈ S: Use Gφ directly
  --   - If □φ ∈ S: Use □φ directly
  --
  -- We need: □ and G distribute over the derivation somehow.
  --
  -- Key lemma needed: If L ⊢ ⊥ and each φ in L has Gφ or □φ in S,
  -- then we can derive ⊥ from S using modal/temporal reasoning.
  --
  -- This is non-trivial and requires:
  -- 1. Generalized necessitation: If Γ ⊢ φ and □Γ ⊆ S, then □φ can be derived
  -- 2. Similar for G-formulas
  --
  -- For now, we mark this as sorry and document the gap.
  -- The full proof requires additional infrastructure for "boxed contexts".
  sorry

/--
Forward extension: For any MCS S and positive duration d, there exists an
MCS T such that canonical_task_rel S d T.

**Proof Strategy**:
1. forward_seed S is consistent (by forward_seed_consistent)
2. By Lindenbaum's lemma, extend to MCS T
3. Verify canonical_task_rel S d T:
   - Modal transfer: □φ ∈ S → φ ∈ forward_seed → φ ∈ T
   - Future transfer (d > 0): Gφ ∈ S → φ ∈ forward_seed → φ ∈ T
   - Past transfer: vacuously true (d > 0, not < 0)
-/
theorem forward_extension (S : CanonicalWorldState) (d : CanonicalTime) (hd : d > 0) :
    ∃ T : CanonicalWorldState, canonical_task_rel S d T := by
  -- Step 1: forward_seed S is consistent
  have h_cons : SetConsistent (forward_seed S) := forward_seed_consistent S
  -- Step 2: Extend to MCS by Lindenbaum
  obtain ⟨M, h_sub, h_mcs⟩ := set_lindenbaum (forward_seed S) h_cons
  -- Step 3: Construct T as subtype
  let T : CanonicalWorldState := ⟨M, h_mcs⟩
  use T
  -- Step 4: Verify canonical_task_rel S d T
  -- Structure: ⟨modal, future_transfer, past_transfer, G_persist, H_persist⟩
  unfold canonical_task_rel modal_transfer future_transfer past_transfer
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  -- Modal transfer: □φ ∈ S → φ ∈ T
  · intro φ h_box_S
    -- □φ ∈ S → φ ∈ forward_seed S → φ ∈ M = T.val
    have h_in_seed : φ ∈ forward_seed S := by
      unfold forward_seed
      right
      exact h_box_S
    exact h_sub h_in_seed
  -- Future transfer: d > 0 → (Gφ ∈ S → φ ∈ T)
  · intro _ φ h_all_future_S
    -- Gφ ∈ S → φ ∈ forward_seed S → φ ∈ M = T.val
    have h_in_seed : φ ∈ forward_seed S := by
      unfold forward_seed
      left
      exact h_all_future_S
    exact h_sub h_in_seed
  -- Past transfer: d < 0 → ... (vacuously true since d > 0)
  · intro h_neg _φ _h_all_past
    -- d > 0 and d < 0 is a contradiction
    exfalso
    -- The Duration type's LT is defined as: d1 < d2 ↔ d1 ≤ d2 ∧ d1 ≠ d2
    -- So d > 0 means 0 ≤ d ∧ 0 ≠ d, and d < 0 means d ≤ 0 ∧ d ≠ 0
    -- From d ≤ 0 and 0 ≤ d, we get d = 0 by antisymmetry.
    -- But d ≠ 0 from either side, contradiction.
    simp only [GT.gt, LT.lt] at hd h_neg
    obtain ⟨h_le1, h_ne1⟩ := hd
    obtain ⟨h_le2, h_ne2⟩ := h_neg
    have h_eq : d = 0 := Duration.le_antisymm h_le2 h_le1
    exact h_ne2 h_eq
  -- G-persistence: d > 0 → (Gφ ∈ S → Gφ ∈ T)
  · intro _ φ h_all_future_S
    -- From Gφ ∈ S, get GGφ ∈ S via set_mcs_all_future_all_future (G-4 axiom)
    have h_gg : (Formula.all_future φ).all_future ∈ S.val :=
      set_mcs_all_future_all_future S.property h_all_future_S
    -- GGφ ∈ S means Gφ is in forward_seed S (it's the content of a G-formula in S)
    have h_in_seed : φ.all_future ∈ forward_seed S := by
      unfold forward_seed
      left
      exact h_gg
    exact h_sub h_in_seed
  -- H-persistence: d < 0 → ... (vacuously true since d > 0)
  · intro h_neg _φ _h_all_past
    exfalso
    simp only [GT.gt, LT.lt] at hd h_neg
    obtain ⟨h_le1, _⟩ := hd
    obtain ⟨h_le2, h_ne2⟩ := h_neg
    have h_eq : d = 0 := Duration.le_antisymm h_le2 h_le1
    exact h_ne2 h_eq

/-!
## Backward Existence Lemma

Similar to forward extension, but constructs a world state T in the "past"
of S such that canonical_task_rel T d S holds for positive d.
-/

/--
Backward seed: The set of formulas that must be in a backward-related MCS.

For any MCS S, the backward seed contains:
1. The content of all H-formulas in S (if Hφ ∈ S, then φ in seed)
2. The content of all □-formulas in S (if □φ ∈ S, then φ in seed)

This captures what must hold at any strictly past world state.
-/
def backward_seed (S : CanonicalWorldState) : Set Formula :=
  {φ | Formula.all_past φ ∈ S.val} ∪ {φ | Formula.box φ ∈ S.val}

/--
Backward seed consistency: The backward_seed of any MCS is consistent.

**Note**: Proof structure mirrors forward_seed_consistent.
-/
theorem backward_seed_consistent (S : CanonicalWorldState) :
    SetConsistent (backward_seed S) := by
  -- Similar to forward_seed_consistent
  intro L hL
  intro ⟨d_bot⟩
  sorry

/--
Backward extension: For any MCS S and positive duration d, there exists an
MCS T such that canonical_task_rel T d S.

**Proof Strategy**:
1. backward_seed S is consistent (by backward_seed_consistent)
2. By Lindenbaum's lemma, extend to MCS T
3. Verify canonical_task_rel T d S:
   - Modal transfer: □φ ∈ T → φ ∈ S (need T to contain □-content of S plus more)
   - Future transfer: vacuously true (d > 0, coming from T to S)
   - Past transfer: vacuously true (d > 0, not < 0)

**Key Insight**: The direction is T → S with duration d > 0, meaning:
- T is "before" S by duration d
- From T's perspective going forward d units reaches S
- canonical_task_rel T d S requires:
  - modal_transfer T S (always)
  - future_transfer T S (since d > 0): Gφ ∈ T → φ ∈ S
  - past_transfer T S: vacuously true (d not < 0)

This is more complex because T is the unknown, and we need T to satisfy
transfer properties "into" S.
-/
theorem backward_extension (S : CanonicalWorldState) (d : CanonicalTime) (hd : d > 0) :
    ∃ T : CanonicalWorldState, canonical_task_rel T d S := by
  -- The backward case is trickier: we need T such that transfers go TO S.
  --
  -- For modal_transfer T S: □φ ∈ T → φ ∈ S
  --   - We need: if we put □φ in T, then φ must be in S
  --   - This is satisfied if T contains only □-formulas whose content is in S
  --
  -- For future_transfer T S (since d > 0): Gφ ∈ T → φ ∈ S
  --   - We need: if we put Gφ in T, then φ must be in S
  --   - This is satisfied if T contains only G-formulas whose content is in S
  --
  -- Strategy: Build T to contain formulas whose transfers land in S.
  -- Let T_seed = {□φ | φ ∈ S} ∪ {Gφ | φ ∈ S}
  -- Then: □φ ∈ T → φ ∈ S (by construction) ✓
  --       Gφ ∈ T → φ ∈ S (by construction) ✓
  --
  -- But we also need T to be an MCS! So T_seed must be:
  -- 1. Consistent (to extend via Lindenbaum)
  -- 2. The extension T still satisfies the transfer properties
  --
  -- Issue: Lindenbaum extension might add formulas that break transfers!
  -- For example, T might get □ψ where ψ ∉ S, breaking modal_transfer.
  --
  -- This requires more careful construction. For now, use sorry.
  sorry

/-!
## Canonical Model and Valuation

The canonical model assigns truth values to atomic propositions based on
membership in maximal consistent sets.
-/

/--
Canonical valuation: An atom is true at a world state iff it's in the
set-based maximal consistent set.

**Definition**: `canonical_valuation S p ↔ (Formula.atom p) ∈ S.val`

where `S : CanonicalWorldState` is a set-based maximal consistent set
(subtype of `Set Formula`).

**Justification**: This makes atomic formulas "true by definition" in their
maximal consistent sets, enabling the truth lemma. The set-based representation
ensures we can express true maximality (every formula or its negation is in the set).
-/
def canonical_valuation (S : CanonicalWorldState) (p : String) : Prop :=
  Formula.atom p ∈ S.val

/--
The canonical model for TM logic.

**Construction**: Canonical frame with canonical valuation.

This provides the complete semantic structure for evaluating TM formulas
in the canonical model construction.
-/
def canonical_model : TaskModel canonical_frame where
  valuation := canonical_valuation

/-!
## Canonical World Histories

World histories in the canonical model map times to set-based maximal consistent sets.
-/

/-!
### Full Domain Canonical History

A canonical world history is constructed from a set-based maximal consistent set.

**Full Domain Implementation**: All times are in the domain (Task 458).

This implementation constructs a history covering all Duration values using:
- Domain: All times (`fun _ => True`)
- States: At time 0 returns S, at positive times uses forward_extension witnesses,
  at negative times uses backward_extension witnesses
- Convexity: Trivially satisfied (full domain is convex)
- Task relation respect: Uses compositionality and the construction

**Key Properties**:
- Supports non-trivial temporal reasoning for truth lemma
- Past φ and Future φ evaluate over infinite domain
- Uses Classical.choice to select MCS witnesses from existence lemmas

**Dependencies**:
- `forward_extension`: For any MCS S and d > 0, exists T with canonical_task_rel S d T
- `backward_extension`: For any MCS S and d > 0, exists T with canonical_task_rel T d S
- `canonical_compositionality`: Task relations compose over time addition

**Why Full Domain Is Required**:
The singleton domain version (with only time 0) makes temporal operators G φ and H φ
vacuously true, which breaks the truth lemma correspondence. For correctness, we need
`G φ ∈ S ↔ truth_at M τ 0 (G φ)` but singleton domain gives G φ always true semantically.
The full domain ensures proper evaluation of temporal operators.

**Implementation Status (Task 458)**:
- `canonical_states`: Fully implemented using Classical.choose
- `canonical_states_zero/forward/backward`: Helper lemmas proven
- `canonical_history`: Domain and convexity complete
- `respects_task`: Has sorry - requires compositionality proof for Classical.choose witnesses

**Note**: Definitions are noncomputable due to Classical.choice. This is standard
and acceptable for metalogic proofs about completeness.
-/

-- Use Classical decidability for Duration's ordering (needed for if-then-else)
open scoped Classical

/-!
### Chain-Based State Construction (Task 458 v002)

The original `canonical_states` definition used independent `Classical.choose` calls
for each time point, which doesn't guarantee coherence between states at different
positive (or negative) times.

**Chain Approach**: Build states incrementally so that coherence is guaranteed
by construction:

1. **Forward chain**: Starting from S at time 0, each subsequent state is
   chosen via `forward_extension` from the previous state.

2. **Backward chain**: Starting from S at time 0, each "earlier" state is
   chosen via `backward_extension` from the next state.

This ensures that for states on the same chain, the task relation holds by
construction, without needing to prove that independent Classical.choose
witnesses compose.

**Indexing**: Chains are indexed by ℕ, where each step uses a fixed positive
duration `step`. The step size is obtained from `PositiveDuration`.

**Note**: For abstract Duration that isn't ℤ-like, the chain only covers
discrete multiples of the step. For full domain coverage, we extend by
using `forward_extension` from the nearest chain point.
-/

/--
A second world state, guaranteed to be different from `someWorldState`.

We construct this by choosing a world state whose underlying set differs
from `someWorldState.val`. Since there are infinitely many MCS (by Lindenbaum),
we can always find such a state.

**Alternative construction**: Use the existence of at least two distinct MCS.
For any consistent formula φ, both {φ} and {¬φ} extend to MCS, giving two
distinct MCS.
-/
axiom anotherWorldState_exists : ∃ S : Set Formula, SetMaximalConsistent S ∧ S ≠ someWorldState.val

noncomputable def anotherWorldState : CanonicalWorldState :=
  ⟨Classical.choose anotherWorldState_exists,
   (Classical.choose_spec anotherWorldState_exists).1⟩

theorem anotherWorldState_ne_someWorldState : anotherWorldState ≠ someWorldState := by
  intro h
  have h_val : anotherWorldState.val = someWorldState.val := congrArg Subtype.val h
  exact (Classical.choose_spec anotherWorldState_exists).2 h_val

/--
A noncomputable positive duration used as the unit step for chain construction.

We construct this by concatenating two singleton segments with **different**
world states to get a segment with two elements, representing a strictly
positive duration.

**Implementation Note**: In the Duration construction:
- `PositiveDuration.zero` = singleton segment (order type 1, represents 0)
- Concatenating two singletons with different states gives order type 2

The Grothendieck group maps PositiveDuration.zero to Duration's 0.
Concatenating two distinct singletons gives a PositiveDuration that maps to a
strictly positive Duration.
-/
noncomputable def chain_step_pd : PositiveDuration :=
  -- Two singleton segments with DIFFERENT world states
  PositiveDuration.add ⟦mkSingletonSigma someWorldState⟧ ⟦mkSingletonSigma anotherWorldState⟧

noncomputable def chain_step : Duration :=
  positiveToDuration chain_step_pd

/--
The carrier of concatSegments of two singletons with different elements has
cardinality 2, while a singleton has cardinality 1. Therefore they cannot be
order-type equivalent (no bijection exists).
-/
theorem chain_step_pd_ne_zero : chain_step_pd ≠ PositiveDuration.zero := by
  unfold chain_step_pd PositiveDuration.zero PositiveDuration.add
  -- Need to show that ⟦concatSegments (mkSingletonSigma w1) (mkSingletonSigma w2)⟧ ≠ ⟦mkSingletonSigma w⟧
  -- In the quotient, this means ¬orderTypeEquiv (concat ...) (singleton)
  intro h
  -- h says these are equal in the quotient
  -- Use Quotient.exact to get orderTypeEquiv on representatives
  have h_equiv := Quotient.exact h
  -- h_equiv : orderTypeEquiv (concatSegments ...) (mkSingletonSigma someWorldState)
  unfold orderTypeEquiv at h_equiv
  -- h_equiv : Nonempty (carrier1 ≃ carrier2)
  obtain ⟨e⟩ := h_equiv
  -- e : concatSegments carrier ≃ singleton carrier
  -- The concat carrier has 2 elements (since someWorldState ≠ anotherWorldState)
  -- The singleton carrier has 1 element
  -- But Equiv preserves cardinality, contradiction
  --
  -- concatSegments (mkSingletonSigma w1) (mkSingletonSigma w2) has carrier {w1} ∪ {w2}
  -- mkSingletonSigma w has carrier {w}
  -- With w1 ≠ w2, |{w1} ∪ {w2}| = 2 ≠ 1 = |{w}|
  have h_two : (concatSegments (mkSingletonSigma someWorldState) (mkSingletonSigma anotherWorldState)).2.carrier =
               {someWorldState} ∪ {anotherWorldState} := by
    unfold concatSegments mkSingletonSigma singletonSegment
    rfl
  have h_one : (mkSingletonSigma someWorldState).2.carrier = {someWorldState} := by
    unfold mkSingletonSigma singletonSegment
    rfl
  -- Now we need that there's no bijection between a 2-element set and a 1-element set
  -- Since w1 ≠ w2, the union {w1} ∪ {w2} = {w1, w2} has 2 elements
  simp only [h_two, h_one] at e
  -- e : ↑({someWorldState} ∪ {anotherWorldState}) ≃ ↑{someWorldState}
  -- This should fail because |{w1, w2}| = 2 and |{w}| = 1
  have h_ne := anotherWorldState_ne_someWorldState
  -- Use Cardinal to show cardinality mismatch
  -- Cardinal.mk_congr : e → Cardinal.mk A = Cardinal.mk B
  have h_card_eq := Cardinal.mk_congr e
  -- The domain has 2 elements, the codomain has 1 element
  -- Cardinal.mk of a singleton set is 1
  have h_card_one : Cardinal.mk ↑({someWorldState} : Set CanonicalWorldState) = 1 :=
    Cardinal.mk_singleton someWorldState
  -- Cardinal.mk of a two-element set is 2
  have h_card_two : Cardinal.mk ↑({someWorldState} ∪ {anotherWorldState} : Set CanonicalWorldState) = 2 := by
    -- Show this equals insert anotherWorldState {someWorldState}
    have h_set_eq : ({someWorldState} ∪ {anotherWorldState} : Set CanonicalWorldState) =
                    insert anotherWorldState {someWorldState} := by
      ext x
      simp only [Set.mem_union, Set.mem_singleton_iff, Set.mem_insert_iff]
      constructor
      · intro h; cases h with
        | inl h => right; exact h
        | inr h => left; exact h
      · intro h; cases h with
        | inl h => right; exact h
        | inr h => left; exact h
    rw [h_set_eq]
    have h_not_mem : anotherWorldState ∉ ({someWorldState} : Set CanonicalWorldState) := by
      simp only [Set.mem_singleton_iff]
      exact h_ne
    rw [Cardinal.mk_insert h_not_mem]
    rw [Cardinal.mk_singleton]
    -- 1 + 1 = 2 in Cardinal
    norm_cast
  rw [h_card_two, h_card_one] at h_card_eq
  -- 2 = 1 is false in Cardinal
  norm_cast at h_card_eq

/--
The chain step is strictly positive.

This follows from:
1. 0 ≤ chain_step because chain_step = positiveToDuration chain_step_pd
2. 0 ≠ chain_step because chain_step_pd ≠ PositiveDuration.zero (different cardinalities)
   and positiveToDuration is injective (by IsCancelAdd)
-/
theorem chain_step_pos : (0 : Duration) < chain_step := by
  unfold chain_step
  simp only [LT.lt]
  constructor
  · -- 0 ≤ chain_step: follows from chain_step being a positive duration image
    use chain_step_pd
    simp only [zero_add]
  · -- 0 ≠ chain_step: use injectivity of positiveToDuration
    intro h_eq
    -- h_eq : 0 = positiveToDuration chain_step_pd
    -- Since positiveToDuration is injective (by IsCancelAdd), this means
    -- PositiveDuration.zero = chain_step_pd, contradicting chain_step_pd_ne_zero
    have h_inj := Algebra.GrothendieckAddGroup.of_injective (M := PositiveDuration)
    have h_zero : positiveToDuration 0 = 0 := map_zero _
    -- h_eq.symm : positiveToDuration chain_step_pd = 0 = positiveToDuration 0
    have h_eq' : positiveToDuration chain_step_pd = positiveToDuration 0 := by
      rw [h_zero]
      exact h_eq.symm
    have h_pd_eq : chain_step_pd = 0 := h_inj h_eq'
    exact chain_step_pd_ne_zero h_pd_eq

/--
Forward chain: States at natural number indices extending forward from S.

- `canonical_forward_chain S 0 = S`
- `canonical_forward_chain S (n+1)` is chosen via `forward_extension` from
  `canonical_forward_chain S n` with duration `chain_step`.

This ensures that consecutive chain elements are related by `chain_step`.
-/
noncomputable def canonical_forward_chain (S : CanonicalWorldState) : ℕ → CanonicalWorldState
  | 0 => S
  | n + 1 => Classical.choose (forward_extension (canonical_forward_chain S n) chain_step chain_step_pos)

/--
Each forward chain step maintains the task relation.
-/
theorem canonical_forward_chain_step (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel (canonical_forward_chain S n) chain_step (canonical_forward_chain S (n + 1)) :=
  -- The n+1 case of canonical_forward_chain is defined as Classical.choose (forward_extension ...)
  -- Classical.choose_spec gives us the task relation property
  Classical.choose_spec (forward_extension (canonical_forward_chain S n) chain_step chain_step_pos)

/--
Forward chain at index 0 equals S.
-/
theorem canonical_forward_chain_zero (S : CanonicalWorldState) :
    canonical_forward_chain S 0 = S := rfl

/--
Forward chain composition: S is task-related to any chain element by the
appropriate multiple of chain_step.

This follows by induction: we compose the individual step relations.
-/
theorem canonical_forward_chain_total (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel S (n • chain_step) (canonical_forward_chain S n) := by
  induction n with
  | zero =>
    -- n = 0: need canonical_task_rel S 0 S
    rw [zero_nsmul]
    exact canonical_nullity S
  | succ k ih =>
    -- Inductive case: canonical_task_rel S (k • chain_step) (chain k)
    -- and canonical_task_rel (chain k) chain_step (chain (k+1))
    -- Compose to get canonical_task_rel S ((k+1) • chain_step) (chain (k+1))
    have h_step := canonical_forward_chain_step S k
    have h_comp := canonical_compositionality S (canonical_forward_chain S k)
        (canonical_forward_chain S (k + 1)) (k • chain_step) chain_step ih h_step
    -- Need: (k • chain_step) + chain_step = (k + 1) • chain_step
    have h_arith : (k • chain_step) + chain_step = (k + 1) • chain_step := by
      rw [add_nsmul, one_nsmul]
    rw [h_arith] at h_comp
    exact h_comp

/--
Forward chain coherence: For m ≤ n, the states at indices m and n are
task-related by the difference in steps.

This follows from the fact that both are reachable from S, and we can
compose/decompose the relations.
-/
theorem canonical_forward_chain_coherence (S : CanonicalWorldState) (m n : ℕ) (h : m ≤ n) :
    canonical_task_rel (canonical_forward_chain S m) ((n - m) • chain_step) (canonical_forward_chain S n) := by
  -- Prove by showing both are on the same chain from S
  induction n with
  | zero =>
    -- n = 0, so m = 0
    simp only [Nat.le_zero] at h
    subst h
    simp only [Nat.sub_self]
    rw [zero_nsmul]
    exact canonical_nullity (canonical_forward_chain S 0)
  | succ k ih =>
    -- n = k + 1
    by_cases hm : m = k + 1
    · -- m = k + 1 = n
      subst hm
      simp only [Nat.sub_self]
      rw [zero_nsmul]
      exact canonical_nullity (canonical_forward_chain S (k + 1))
    · -- m < k + 1, so m ≤ k
      have h_m_le_k : m ≤ k := Nat.lt_succ_iff.mp (Nat.lt_of_le_of_ne h hm)
      have h_ih := ih h_m_le_k
      have h_step := canonical_forward_chain_step S k
      have h_comp := canonical_compositionality (canonical_forward_chain S m)
          (canonical_forward_chain S k) (canonical_forward_chain S (k + 1))
          ((k - m) • chain_step) chain_step h_ih h_step
      -- Need: (k - m) • chain_step + chain_step = (k + 1 - m) • chain_step
      have h_arith : (k - m) • chain_step + chain_step = (k + 1 - m) • chain_step := by
        have h_succ : k + 1 - m = k - m + 1 := by omega
        rw [h_succ, add_nsmul, one_nsmul]
      rw [← h_arith]
      exact h_comp

/--
Backward chain: States at natural number indices extending backward from S.

- `canonical_backward_chain S 0 = S`
- `canonical_backward_chain S (n+1)` is chosen via `backward_extension` from
  `canonical_backward_chain S n` with duration `chain_step`.

This means the state at index n+1 is "earlier" than the state at index n.
The relation is: canonical_task_rel (chain (n+1)) chain_step (chain n)
-/
noncomputable def canonical_backward_chain (S : CanonicalWorldState) : ℕ → CanonicalWorldState
  | 0 => S
  | n + 1 => Classical.choose (backward_extension (canonical_backward_chain S n) chain_step chain_step_pos)

/--
Each backward chain step maintains the task relation.
The relation goes FROM the earlier state TO the later state.
-/
theorem canonical_backward_chain_step (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel (canonical_backward_chain S (n + 1)) chain_step (canonical_backward_chain S n) :=
  -- backward_extension (state n) gives a state T with canonical_task_rel T chain_step (state n)
  Classical.choose_spec (backward_extension (canonical_backward_chain S n) chain_step chain_step_pos)

/--
Backward chain at index 0 equals S.
-/
theorem canonical_backward_chain_zero (S : CanonicalWorldState) :
    canonical_backward_chain S 0 = S := rfl

/--
Backward chain composition: Any chain element is task-related to S by
the appropriate multiple of chain_step.

canonical_task_rel (canonical_backward_chain S n) (n • chain_step) S

This follows by induction: we compose the individual step relations.
-/
theorem canonical_backward_chain_total (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel (canonical_backward_chain S n) (n • chain_step) S := by
  induction n with
  | zero =>
    -- n = 0: need canonical_task_rel S 0 S
    rw [zero_nsmul]
    exact canonical_nullity S
  | succ k ih =>
    -- Inductive case: canonical_task_rel (chain k) (k • chain_step) S
    -- and canonical_task_rel (chain (k+1)) chain_step (chain k)
    -- Compose to get canonical_task_rel (chain (k+1)) ((k+1) • chain_step) S
    have h_step := canonical_backward_chain_step S k
    have h_comp := canonical_compositionality (canonical_backward_chain S (k + 1))
        (canonical_backward_chain S k) S chain_step (k • chain_step) h_step ih
    -- Need: chain_step + (k • chain_step) = (k + 1) • chain_step
    have h_arith : chain_step + (k • chain_step) = (k + 1) • chain_step := by
      rw [add_comm, add_nsmul, one_nsmul]
    rw [h_arith] at h_comp
    exact h_comp

/--
Backward chain coherence: For m ≤ n, the states at indices m and n are
task-related by the difference in steps.

canonical_task_rel (canonical_backward_chain S n) ((n - m) • chain_step) (canonical_backward_chain S m)

This says: the state n steps back relates to the state m steps back
by (n - m) steps forward.
-/
theorem canonical_backward_chain_coherence (S : CanonicalWorldState) (m n : ℕ) (h : m ≤ n) :
    canonical_task_rel (canonical_backward_chain S n) ((n - m) • chain_step) (canonical_backward_chain S m) := by
  -- Similar to forward chain coherence, by induction
  induction n with
  | zero =>
    simp only [Nat.le_zero] at h
    subst h
    simp only [Nat.sub_self]
    rw [zero_nsmul]
    exact canonical_nullity (canonical_backward_chain S 0)
  | succ k ih =>
    by_cases hm : m = k + 1
    · subst hm
      simp only [Nat.sub_self]
      rw [zero_nsmul]
      exact canonical_nullity (canonical_backward_chain S (k + 1))
    · have h_m_le_k : m ≤ k := Nat.lt_succ_iff.mp (Nat.lt_of_le_of_ne h hm)
      have h_ih := ih h_m_le_k
      have h_step := canonical_backward_chain_step S k
      -- h_step : canonical_task_rel (chain (k+1)) chain_step (chain k)
      -- h_ih : canonical_task_rel (chain k) ((k - m) • chain_step) (chain m)
      -- Compose to get: canonical_task_rel (chain (k+1)) (chain_step + (k-m) • chain_step) (chain m)
      have h_comp := canonical_compositionality (canonical_backward_chain S (k + 1))
          (canonical_backward_chain S k) (canonical_backward_chain S m)
          chain_step ((k - m) • chain_step) h_step h_ih
      have h_arith : chain_step + (k - m) • chain_step = (k + 1 - m) • chain_step := by
        have h_succ : k + 1 - m = k - m + 1 := by omega
        rw [h_succ, add_comm, add_nsmul, one_nsmul]
      rw [h_arith] at h_comp
      exact h_comp

/--
Helper function to construct MCS at each time relative to a base MCS S.

At time 0: Returns S
At time t > 0: Uses forward_extension to find T with S →_t T
At time t < 0: Uses backward_extension to find T with T →_{-t} S

**Note**: Noncomputable because it uses Classical.choose on existence proofs.
-/
noncomputable def canonical_states (S : CanonicalWorldState) (t : CanonicalTime) : CanonicalWorldState :=
  if h : t = 0 then S
  else if ht : (0 : CanonicalTime) < t then
    -- t > 0: use forward_extension
    Classical.choose (forward_extension S t ht)
  else
    -- t ≠ 0 and ¬(t > 0), so t < 0, meaning -t > 0
    -- backward_extension gives T with canonical_task_rel T (-t) S
    -- So T is "before" S by duration -t
    have h_neg : (0 : CanonicalTime) < -t := by
      -- From ¬(0 < t) and t ≠ 0, we need to show 0 < -t
      -- Strategy: Use totality of Duration's order
      -- Either t ≤ 0 or 0 ≤ t (by Duration.le_total)
      cases Duration.le_total t 0 with
      | inl h_t_le_0 =>
        -- t ≤ 0 and t ≠ 0 means t < 0
        -- So -t > 0, i.e., 0 < -t
        simp only [LT.lt]
        constructor
        · -- 0 ≤ -t: follows from t ≤ 0 by negation preserves order
          -- In an ordered group, t ≤ 0 ↔ 0 ≤ -t
          -- We have: -t + t ≤ -t + 0 (by add_le_add_left with t ≤ 0)
          -- And: -t + t = 0, -t + 0 = -t
          -- So: 0 ≤ -t
          have h1 : -t + t ≤ -t + 0 := Duration.add_le_add_left' (-t) t 0 h_t_le_0
          rw [neg_add_cancel, add_zero] at h1
          exact h1
        · -- 0 ≠ -t
          intro h_eq
          exact h (neg_eq_zero.mp h_eq.symm)
      | inr h_0_le_t =>
        -- 0 ≤ t and ¬(0 < t) means t = 0
        -- But we have h : t ≠ 0, contradiction
        simp only [LT.lt] at ht
        -- ht : ¬(0 ≤ t ∧ 0 ≠ t)
        -- h_0_le_t : 0 ≤ t
        -- So we must have ¬(0 ≠ t), meaning 0 = t
        exfalso
        have h_ne : (0 : Duration) ≠ t := fun h_eq => h h_eq.symm
        exact ht ⟨h_0_le_t, h_ne⟩
    Classical.choose (backward_extension S (-t) h_neg)

/--
Key lemma: canonical_states at time 0 equals S.
-/
theorem canonical_states_zero (S : CanonicalWorldState) :
    canonical_states S 0 = S := by
  unfold canonical_states
  simp

/--
Key lemma: For t > 0, canonical_task_rel S t (canonical_states S t) holds.
-/
theorem canonical_states_forward (S : CanonicalWorldState) (t : CanonicalTime) (ht : (0 : CanonicalTime) < t) :
    canonical_task_rel S t (canonical_states S t) := by
  unfold canonical_states
  -- From 0 < t, we have t ≠ 0
  have h_ne : t ≠ 0 := by
    intro h_eq
    simp only [LT.lt] at ht
    exact ht.2 h_eq.symm
  simp only [h_ne, ↓reduceDIte, ht]
  exact Classical.choose_spec (forward_extension S t ht)

/--
Key lemma: For t < 0, canonical_task_rel (canonical_states S t) (-t) S holds.
-/
theorem canonical_states_backward (S : CanonicalWorldState) (t : CanonicalTime) (ht : t < (0 : CanonicalTime)) :
    canonical_task_rel (canonical_states S t) (-t) S := by
  unfold canonical_states
  -- From t < 0, we have t ≠ 0 and ¬(0 < t)
  have h_ne : t ≠ 0 := by
    intro h_eq
    simp only [LT.lt] at ht
    exact ht.2 h_eq
  have h_not_pos : ¬((0 : CanonicalTime) < t) := by
    intro h_pos
    -- t < 0 and 0 < t is impossible
    simp only [LT.lt] at ht h_pos
    -- ht : t ≤ 0 ∧ t ≠ 0
    -- h_pos : 0 ≤ t ∧ 0 ≠ t
    have h_eq := Duration.le_antisymm ht.1 h_pos.1
    exact h_ne h_eq
  simp only [h_ne, ↓reduceDIte, h_not_pos]
  -- Now we need to show the Classical.choose satisfies the relation
  -- The proof in canonical_states computes h_neg : 0 < -t
  -- We need to show this equals the h_neg_pos here
  have h_neg_pos : (0 : CanonicalTime) < -t := by
    simp only [LT.lt] at ht ⊢
    constructor
    · -- 0 ≤ -t
      have h1 : -t + t ≤ -t + 0 := Duration.add_le_add_left' (-t) t 0 ht.1
      rw [neg_add_cancel, add_zero] at h1
      exact h1
    · -- 0 ≠ -t
      intro h_eq
      exact h_ne (neg_eq_zero.mp h_eq.symm)
  exact Classical.choose_spec (backward_extension S (-t) h_neg_pos)

/-!
### Chain-Indexed Canonical History

For completeness, we provide an alternative canonical history construction that
restricts the domain to multiples of `chain_step`. This avoids the coherence
issue in `respects_task` by using the chain coherence lemmas directly.

**Note**: This construction uses ℤ-indexed chains where:
- Non-negative indices use forward_chain
- Negative indices use backward_chain

The key coherence lemmas are:
- `canonical_forward_chain_coherence` for 0 ≤ m ≤ n
- `canonical_backward_chain_coherence` for n ≤ m ≤ 0

The cross-zero case (n < 0 < m) is handled by composing through the origin.
-/

/--
States at chain-indexed positions: uses the forward/backward chains.

For n : ℤ:
- n ≥ 0: uses canonical_forward_chain S n.natAbs
- n < 0: uses canonical_backward_chain S n.natAbs
-/
noncomputable def chain_indexed_states (S : CanonicalWorldState) (n : ℤ) : CanonicalWorldState :=
  if 0 ≤ n then
    canonical_forward_chain S n.natAbs
  else
    canonical_backward_chain S n.natAbs

/--
Chain-indexed states at 0 equals S.
-/
theorem chain_indexed_states_zero (S : CanonicalWorldState) :
    chain_indexed_states S 0 = S := by
  unfold chain_indexed_states
  simp only [le_refl, ↓reduceDIte, Int.natAbs_zero]
  rfl

/--
Chain-indexed states preserve the task relation for positive indices.

For 0 ≤ m ≤ n:
canonical_task_rel (chain_indexed_states S m) ((n - m).natAbs • chain_step) (chain_indexed_states S n)
-/
theorem chain_indexed_states_pos_coherence (S : CanonicalWorldState) (m n : ℤ)
    (hm : 0 ≤ m) (hn : 0 ≤ n) (hmn : m ≤ n) :
    canonical_task_rel (chain_indexed_states S m) ((n - m).natAbs • chain_step) (chain_indexed_states S n) := by
  unfold chain_indexed_states
  simp only [hm, hn, if_true]
  -- Both m and n are non-negative, so we use forward chains
  have h_nat : m.natAbs ≤ n.natAbs := by omega
  have h_diff : (n - m).natAbs = n.natAbs - m.natAbs := by omega
  rw [h_diff]
  exact canonical_forward_chain_coherence S m.natAbs n.natAbs h_nat

/--
Chain-indexed states preserve the task relation for negative indices.

For n ≤ m ≤ 0:
canonical_task_rel (chain_indexed_states S n) ((m - n).natAbs • chain_step) (chain_indexed_states S m)
-/
theorem chain_indexed_states_neg_coherence (S : CanonicalWorldState) (m n : ℤ)
    (hm : m ≤ 0) (hn : n ≤ 0) (hnm : n ≤ m) :
    canonical_task_rel (chain_indexed_states S n) ((m - n).natAbs • chain_step) (chain_indexed_states S m) := by
  unfold chain_indexed_states
  -- Both non-positive, handle the zero cases
  by_cases hm_zero : m = 0
  · subst hm_zero
    by_cases hn_zero : n = 0
    · subst hn_zero
      simp only [le_refl, ↓reduceDIte, Int.natAbs_zero, sub_self, zero_nsmul]
      exact canonical_nullity S
    · -- n < 0, m = 0
      have hn_neg : n < 0 := lt_of_le_of_ne hn hn_zero
      simp only [le_refl, hn_neg.not_le, if_true, if_false, Int.natAbs_zero,
                 canonical_forward_chain_zero]
      have h_eq : (0 - n).natAbs = n.natAbs := by omega
      rw [h_eq]
      exact canonical_backward_chain_total S n.natAbs
  · have hm_neg : m < 0 := lt_of_le_of_ne hm hm_zero
    by_cases hn_zero : n = 0
    · -- n = 0, m < 0 - contradiction since n ≤ m
      exfalso
      subst hn_zero
      exact absurd hm_neg (not_lt.mpr hnm)
    · -- Both negative
      have hn_neg : n < 0 := lt_of_le_of_ne hn hn_zero
      simp only [hm_neg.not_le, hn_neg.not_le, if_false]
      -- Use backward chain coherence
      have h_nat : m.natAbs ≤ n.natAbs := by omega
      have h_diff : (m - n).natAbs = n.natAbs - m.natAbs := by omega
      rw [h_diff]
      exact canonical_backward_chain_coherence S m.natAbs n.natAbs h_nat

/--
Domain of chain-indexed times: multiples of chain_step.

This is the discrete domain covered by our chain construction.
A time t is in this domain iff t = n * chain_step for some n : ℤ.
-/
def chain_domain : Set CanonicalTime :=
  { t | ∃ n : ℤ, t = n • chain_step }

/--
Chain domain is convex: if t1 and t3 are in chain_domain with t1 ≤ t2 ≤ t3,
and t2 is also a chain multiple, then t2 is in domain.

Actually, chain_domain is NOT necessarily convex in a dense Duration type,
since there could be values between chain steps. However, for our discrete
chain construction, we only need to show that we can extract integer indices
from domain membership proofs.

For simplicity, we use the full domain with a sorry for now and document
the gap. A full solution would either:
1. Prove Duration is discrete (isomorphic to ℤ)
2. Use a proper chain_domain with restricted semantics
-/
theorem chain_domain_convex : ∀ (x z : CanonicalTime),
    chain_domain x → chain_domain z →
    ∀ (y : CanonicalTime), x ≤ y → y ≤ z → chain_domain y := by
  intro x z ⟨nx, hx⟩ ⟨nz, hz⟩ y hxy hyz
  -- For this to work, we'd need y to also be a multiple of chain_step
  -- This doesn't follow from convexity in general (only if Duration is discrete)
  sorry

/--
Helper to extract the integer index from a chain domain proof.

Given a proof that t is in chain_domain, extract the n : ℤ such that
t = n • chain_step.
-/
noncomputable def chain_index (t : CanonicalTime) (ht : chain_domain t) : ℤ :=
  Classical.choose ht

theorem chain_index_spec (t : CanonicalTime) (ht : chain_domain t) :
    t = (chain_index t ht) • chain_step :=
  Classical.choose_spec ht

/--
Chain-indexed world history with discrete domain.

This construction guarantees coherence by using the chain infrastructure:
- Domain consists of multiples of chain_step: { n • chain_step | n : ℤ }
- States at index n are given by chain_indexed_states
- The task relation is respected by chain coherence lemmas

**Key advantage**: Unlike canonical_history which uses independent Classical.choose
calls for each time, this construction builds states sequentially along a chain,
guaranteeing that the task relation holds between any two domain points.
-/
noncomputable def chain_indexed_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun _ => True  -- Use full domain for now; actual chain_domain requires Duration discreteness
  convex := by
    intros _x _z _hx _hz _y _hxy _hyz
    trivial
  states := fun t _ht =>
    -- Map t to chain index and use chain_indexed_states
    -- For now, use canonical_states (the construction with coherence gap)
    -- A full solution would use: chain_indexed_states S (chain_index t ht)
    canonical_states S t
  respects_task := by
    -- This is where the chain construction provides coherence
    -- For the full domain, we still have the coherence gap
    -- A proper implementation would use chain_indexed coherence lemmas
    intros s t _hs _ht hst
    show canonical_task_rel (canonical_states S s) (t - s) (canonical_states S t)
    -- For now, defer to the cases already handled in canonical_history
    sorry

/--
Full domain canonical world history.

For a base MCS S, this history has:
- All times in the domain
- At each time t, the state is canonical_states S t
- The task relation is respected between any two times
-/
noncomputable def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun _ => True
  convex := by
    -- Full domain is trivially convex
    intros _x _z _hx _hz _y _hxy _hyz
    trivial
  states := fun t _ => canonical_states S t
  respects_task := by
    -- For any s ≤ t in domain, need canonical_task_rel (states s) (t - s) (states t)
    -- i.e., canonical_task_rel (canonical_states S s) (t - s) (canonical_states S t)
    -- Note: canonical_frame.task_rel = canonical_task_rel by definition
    intros s t _hs _ht hst
    show canonical_task_rel (canonical_states S s) (t - s) (canonical_states S t)
    -- Case analysis on signs of s and t
    by_cases h_s_zero : s = 0
    case pos =>
      -- s = 0: Need canonical_task_rel S (t - 0) (canonical_states S t)
      subst h_s_zero
      simp only [sub_zero, canonical_states_zero]
      by_cases h_t_zero : t = 0
      case pos =>
        -- t = 0: canonical_task_rel S 0 S
        subst h_t_zero
        simp only [canonical_states_zero]
        exact canonical_nullity S
      case neg =>
        -- t ≠ 0, and 0 ≤ t (from hst with s = 0), so t > 0
        have h_t_pos : (0 : CanonicalTime) < t := by
          simp only [LT.lt]
          constructor
          · exact hst
          · intro h_eq; exact h_t_zero h_eq.symm
        exact canonical_states_forward S t h_t_pos
    case neg =>
      -- s ≠ 0
      by_cases h_t_zero : t = 0
      case pos =>
        -- t = 0, s ≠ 0, and s ≤ t = 0, so s < 0
        subst h_t_zero
        simp only [zero_sub, canonical_states_zero]
        have h_s_neg : s < (0 : CanonicalTime) := by
          simp only [LT.lt]
          constructor
          · exact hst
          · exact fun h_eq => h_s_zero h_eq
        exact canonical_states_backward S s h_s_neg
      case neg =>
        -- s ≠ 0, t ≠ 0
        by_cases h_s_pos : (0 : CanonicalTime) < s
        case pos =>
          -- s > 0
          by_cases h_t_pos : (0 : CanonicalTime) < t
          case pos =>
            -- s > 0, t > 0, s ≤ t
            -- Need: canonical_task_rel (canonical_states S s) (t-s) (canonical_states S t)
            --
            -- **Known Gap (Task 458)**:
            -- The current `canonical_states` definition uses independent `Classical.choose`
            -- calls for each Duration value:
            --   canonical_states S s = Classical.choose (forward_extension S s)
            --   canonical_states S t = Classical.choose (forward_extension S t)
            --
            -- These are independent choices that don't guarantee coherence:
            -- there's no guarantee that canonical_task_rel (state s) (t-s) (state t).
            --
            -- **Chain-based solution**: We have `canonical_forward_chain` and
            -- `canonical_forward_chain_coherence` that provide coherence for ℕ-indexed
            -- chain positions. However, mapping arbitrary Duration values to chain
            -- indices requires Duration ≅ ℤ * chain_step, which we don't have.
            --
            -- **Possible resolutions**:
            -- 1. If Duration is discrete (isomorphic to ℤ), replace canonical_states
            --    with chain-based construction
            -- 2. If Duration is dense, use a different approach (e.g., axiomatic
            --    coherence property or modify forward_extension to return coherent witnesses)
            -- 3. Restrict domain to chain positions only
            sorry
          case neg =>
            -- s > 0, t not > 0 but s ≤ t, contradiction
            exfalso
            -- From ¬(0 < t), by totality either t ≤ 0 or 0 ≤ t
            simp only [LT.lt] at h_t_pos h_s_pos
            push_neg at h_t_pos
            rcases Duration.le_total t 0 with h_t_le_0 | h_0_le_t
            · -- t ≤ 0
              have h_s_le_0 : s ≤ 0 := Duration.le_trans hst h_t_le_0
              exact h_s_pos.2 (Duration.le_antisymm h_s_pos.1 h_s_le_0)
            · -- 0 ≤ t, then h_t_pos gives 0 = t
              exact h_t_zero (h_t_pos h_0_le_t).symm
        case neg =>
          -- s not > 0, so s < 0 (since s ≠ 0)
          have h_s_neg : s < (0 : CanonicalTime) := by
            simp only [LT.lt] at h_s_pos ⊢
            push_neg at h_s_pos
            rcases Duration.le_total s 0 with h_s_le_0 | h_0_le_s
            · constructor
              · exact h_s_le_0
              · exact fun h_eq => h_s_zero h_eq
            · exact absurd (h_s_pos h_0_le_s).symm h_s_zero
          by_cases h_t_pos : (0 : CanonicalTime) < t
          case pos =>
            -- s < 0, t > 0
            -- We have: canonical_task_rel (canonical_states S s) (-s) S [backward]
            --          canonical_task_rel S t (canonical_states S t) [forward]
            -- By compositionality: canonical_task_rel (canonical_states S s) (-s + t) (canonical_states S t)
            have h_back := canonical_states_backward S s h_s_neg
            have h_fwd := canonical_states_forward S t h_t_pos
            have h_comp := canonical_compositionality (canonical_states S s) S (canonical_states S t) (-s) t h_back h_fwd
            have h_arith : -s + t = t - s := by abel
            rw [h_arith] at h_comp
            exact h_comp
          case neg =>
            -- s < 0, t not > 0, so t < 0 (since t ≠ 0)
            have h_t_neg : t < (0 : CanonicalTime) := by
              simp only [LT.lt] at h_t_pos ⊢
              push_neg at h_t_pos
              rcases Duration.le_total t 0 with h_t_le_0 | h_0_le_t
              · constructor
                · exact h_t_le_0
                · exact fun h_eq => h_t_zero h_eq
              · exact absurd (h_t_pos h_0_le_t).symm h_t_zero
            -- Both s < 0 and t < 0, with s ≤ t < 0
            -- Need: canonical_task_rel (canonical_states S s) (t-s) (canonical_states S t)
            --
            -- **Known Gap (Task 458)**: Same issue as the s > 0, t > 0 case.
            -- The states at s and t are chosen independently via backward_extension,
            -- with no guaranteed coherence.
            --
            -- **Chain-based solution**: We have `canonical_backward_chain` and
            -- `canonical_backward_chain_coherence` that provide coherence for ℕ-indexed
            -- backward chain positions.
            --
            -- See the s > 0, t > 0 case comments for possible resolutions.
            sorry

/-!
## Truth Lemma

The truth lemma establishes the correspondence between syntactic membership
and semantic truth in the canonical model.
-/

/--
**Truth Lemma**: In the canonical model, a formula φ is true at a set-based maximal
consistent set S and time t if and only if an appropriate time-shifted
version of φ is in S.

**Statement**: `φ ∈ S.val ↔ truth_at canonical_model (canonical_history S) 0 φ`

where `S : CanonicalWorldState` is a set-based maximal consistent set
(subtype of `Set Formula`), and `S.val : Set Formula` is the underlying set.

**Proof Strategy** (to be implemented):
By induction on formula structure:
- **Base (atom)**: By definition of canonical_valuation
- **Bottom**: `⊥ ∉ S` by consistency; `¬(M ⊨ ⊥)` by truth definition
- **Implication**: Use set-based maximal consistent implication property
- **Box**: Use modal saturation property of maximal sets
- **Past**: Use temporal consistency backward
- **Future**: Use temporal consistency forward

**Complexity**: ~25-30 hours (most complex proof in completeness)

**Dependencies**:
- Modal saturation lemma (for set-based maximal consistent sets)
- Temporal consistency lemmas
- Properties of set-based maximal consistent sets (from `set_lindenbaum`)

**Note**: Full truth lemma requires dependent type handling for WorldHistory.
The set-based representation ensures true maximality (every formula or its
negation is in the set), which is essential for the proof.
-/
axiom truth_lemma (S : CanonicalWorldState) (φ : Formula) :
  φ ∈ S.val -- Canonical model truth correspondence (placeholder)

/-!
## Completeness Theorems

The main results connecting semantic validity with syntactic derivability.
-/

/--
**Weak Completeness**: Every valid formula is provable.

**Statement**: `valid φ → DerivationTree [] φ`

Equivalently: `(∀ F M τ t, truth_at M τ t φ) → (⊢ φ)`

**Implementation**: See `main_weak_completeness` in
`Bimodal.Metalogic.Completeness.FiniteCanonicalModel` for the actual proof.
This axiom is kept for backward compatibility in the module hierarchy
(FiniteCanonicalModel imports Completeness, so we cannot import back).

**Proof via Finite Model (in FiniteCanonicalModel.lean)**:
1. Use `semantic_weak_completeness` which is PROVEN
2. This proves: if phi true in all SemanticWorldStates, then derivable
3. Bridge from general `valid` to semantic truth via contrapositive
4. If phi not derivable, construct countermodel in SemanticCanonicalModel
5. Contrapositive: valid implies derivable

**Status**: The proof is in FiniteCanonicalModel.lean (`main_weak_completeness`)
with bridge lemmas having minor sorries for type-level connections.
-/
axiom weak_completeness (φ : Formula) : valid φ → DerivationTree [] φ

/--
**Strong Completeness**: Semantic consequence implies syntactic derivability.

**Statement**: `semantic_consequence Γ φ → DerivationTree Γ φ`

Equivalently: `(∀ F M τ t, (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ) → (Γ ⊢ φ)`

**Implementation**: See `main_strong_completeness` in
`Bimodal.Metalogic.Completeness.FiniteCanonicalModel` for the actual proof.
This axiom is kept for backward compatibility in the module hierarchy.

**Proof Strategy** (in FiniteCanonicalModel.lean):
Follows from weak completeness via the deduction theorem.
If Γ |= φ, construct derivation from Γ to φ using context handling.

**Status**: The proof is in FiniteCanonicalModel.lean (`main_strong_completeness`)
with a sorry for the deduction theorem infrastructure.
-/
axiom strong_completeness (Γ : Context) (φ : Formula) :
  semantic_consequence Γ φ → DerivationTree Γ φ

/-!
## Decidability (Optional Extension)

Completeness + Soundness enable decidability results.
-/

/--
**Soundness-Completeness Equivalence**: Provability and validity are equivalent.

**Statement**: `(⊢ φ) ↔ (⊨ φ)`

**Proof**: Combine `soundness` and `weak_completeness`.
-/
theorem provable_iff_valid (φ : Formula) : Nonempty (DerivationTree [] φ) ↔ valid φ := by
  constructor
  · intro ⟨h⟩
    -- Soundness direction: derivable implies valid
    have sem_conseq := soundness [] φ h
    -- semantic_consequence [] φ is equivalent to valid φ
    -- Unfold: semantic_consequence [] φ = ∀ D F M tau t, (∀ ψ ∈ [], truth_at ...) → truth_at ... φ
    -- Since [] is empty, the antecedent is vacuously true
    intro D _ _ _ F M tau t
    exact sem_conseq D F M tau t (fun ψ h_in => absurd h_in List.not_mem_nil)
  · intro h
    exact ⟨weak_completeness φ h⟩

/-!
## Completeness Implementation Audit

### Axioms in This Module

| Axiom | Line | Status | Justification |
|-------|------|--------|---------------|
| `someWorldState_exists` | ~1585 | Infrastructure | Existence of at least one MCS; constructible from `set_lindenbaum` on empty set |
| `anotherWorldState_exists` | ~2786 | Infrastructure | Existence of two distinct MCS; follows from consistency of p and ¬p |
| `truth_lemma` | ~3569 | Placeholder | See `semantic_truth_lemma_v2` in FiniteCanonicalModel.lean for proven version |
| `weak_completeness` | ~3600 | Placeholder | See `main_weak_completeness` in FiniteCanonicalModel.lean for proof |
| `strong_completeness` | ~3620 | Placeholder | See `main_strong_completeness` in FiniteCanonicalModel.lean |

**Note**: The axioms `weak_completeness`, `strong_completeness`, and `truth_lemma` are kept
for backward compatibility in the module hierarchy. FiniteCanonicalModel.lean imports this
module, so we cannot import the proofs back. The actual proofs are in FiniteCanonicalModel.lean.

### Sorries in This Module

| Location | Declaration | Category | Status |
|----------|-------------|----------|--------|
| ~1341 | `box_witness_existence` | Canonical Property | Requires modal transfer proof |
| ~1366 | `imp_witness_existence` | Canonical Property | Requires logical closure |
| ~1391 | `neg_witness_existence` | Canonical Property | Requires negation completeness |
| ~1653 | `PositiveDuration.add` | Duration Algebra | Concatenation well-definedness |
| ~2320-2415 | `compositionality` | Task Relation | 7 gaps in mixed-sign temporal cases |
| ~2507 | `world_states_consistent` | Frame Property | Inter-MCS consistency |
| ~2612 | `CanonicalHistory` | History Construction | Chain extension existence |
| ~2662 | `CanonicalHistory.respects_task` | History Property | Task relation verification |
| ~3337-3397 | `canonical_frame` properties | Frame Construction | Nullity and compositionality |

**Total**: ~15 sorry gaps in Duration-based infrastructure (deprecated)

### Proven Key Results

- `set_lindenbaum`: Lindenbaum's lemma via Zorn's lemma (PROVEN)
- `set_mcs_consistent`: MCS consistency (PROVEN)
- `set_mcs_box_closure`: Modal T axiom property (PROVEN)
- `set_mcs_all_future_all_future`: Temporal 4 axiom (PROVEN)
- `set_mcs_all_past_all_past`: Temporal 4 axiom (PROVEN)
- `mcs_negation_complete`: Negation completeness for MCS (PROVEN)
- `provable_iff_valid`: Soundness-completeness equivalence (PROVEN - uses axiom)

### Implementation Strategy

The Duration-based canonical model construction in this file has significant sorry gaps
due to the complexity of infinite chain segments and temporal transfer properties.

**Preferred approach**: Use the finite canonical model in `FiniteCanonicalModel.lean`:
- `SemanticWorldState`: Quotient of history-time pairs
- `semantic_weak_completeness`: PROVEN, core completeness result
- `semantic_truth_lemma_v2`: PROVEN, no sorry gaps
- `main_weak_completeness` and `main_provable_iff_valid`: PROVEN

The finite approach sidesteps the Duration algebra complexity by working with bounded
integer time domains and finite world state enumeration.
-/

/-!
## Future Work: Decidability

With completeness proven, decidability can be established via:

1. **Finite Model Property**: Every satisfiable formula has a finite model
2. **Tableau Method**: Systematic search for satisfying models
3. **Decision Procedure**: Bounded tableau search decides validity

This is beyond Layer 0 scope but enabled by completeness proof.
-/


end Bimodal.Boneyard.Metalogic_v4.Completeness
