import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Representation.CanonicalWorld
import Bimodal.Syntax.Formula
import Bimodal.Boneyard.Metalogic.Completeness  -- For set_mcs_closed_under_derivation and set_mcs_all_future_all_future
import Bimodal.Theorems.GeneralizedNecessitation  -- For generalized_temporal_k
import Mathlib.Algebra.Order.Group.Defs

/-!
# Indexed MCS Family for Universal Parametric Canonical Model

This module defines the `IndexedMCSFamily` structure that assigns a maximal consistent
set (MCS) to each time point in D, with temporal coherence conditions ensuring
proper formula propagation.

## Overview

The key insight from research-004.md: The same-MCS-at-all-times approach fails because
it requires temporal T-axioms (`G phi -> phi`, `H phi -> phi`) that TM logic does NOT have.
G/H are IRREFLEXIVE operators that exclude the present moment.

**Solution**: Build a family of MCS indexed by time, where each time point has its own
MCS connected to adjacent times via temporal coherence conditions.

## Main Definitions

- `IndexedMCSFamily D`: Structure pairing each time `t : D` with an MCS, plus coherence
- `forward_G`: G formulas at t propagate to all future t' > t
- `backward_H`: H formulas at t propagate to all past t' < t
- `forward_H`: H formulas at future times connect to past
- `backward_G`: G formulas at past times connect to future

## Design Rationale

The coherence conditions are weaker than T-axioms:
- T-axiom would say: `G phi in MCS(t) -> phi in MCS(t)` (REFLEXIVE - NOT VALID for TM)
- Our condition says: `G phi in MCS(t) -> phi in MCS(t')` for t' > t (STRICTLY FUTURE)

This matches the irreflexive semantics of G ("strictly future") and H ("strictly past").

## References

- Research report: specs/654_.../reports/research-004.md (indexed family approach)
- Implementation plan: specs/654_.../plans/implementation-004.md
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
-- Use Core's SetMaximalConsistent, but Boneyard.Metalogic for set_mcs_closed_under_derivation

/-!
## Indexed MCS Family Structure
-/

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
A family of maximal consistent sets indexed by time, with temporal coherence.

**Type Parameters**:
- `D`: Duration/time type with ordered additive group structure

**Fields**:
- `mcs`: Function assigning an MCS to each time point
- `is_mcs`: Proof that each assigned set is maximal consistent
- `forward_G`: G formulas propagate to strictly future times
- `backward_H`: H formulas propagate to strictly past times
- `forward_H`: H formulas at future times connect back to present
- `backward_G`: G formulas at past times connect forward to present

**Key Properties**:
- The coherence conditions are STRICT inequalities (< not ≤)
- This matches TM's irreflexive temporal operators
- No T-axiom is required or used

**Design Note**:
The `forward_X` conditions handle propagation FROM time t TO future times.
The `backward_X` conditions handle propagation FROM time t TO past times.
Both directions (forward/backward in coherence name) are needed for compositionality.
-/
structure IndexedMCSFamily where
  /-- The MCS assignment: each time t gets an MCS -/
  mcs : D → Set Formula
  /-- Each assigned set is maximal consistent -/
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  /--
  Forward G coherence: G phi at time t implies phi at all strictly future times.

  Semantic justification: If `G phi` means "phi at all strictly future times",
  and `G phi` is in the MCS at t, then phi must be in the MCS at any t' > t.
  -/
  forward_G : ∀ t t' phi, t < t' → Formula.all_future phi ∈ mcs t → phi ∈ mcs t'
  /--
  Backward H coherence: H phi at time t implies phi at all strictly past times.

  Semantic justification: If `H phi` means "phi at all strictly past times",
  and `H phi` is in the MCS at t, then phi must be in the MCS at any t' < t.
  -/
  backward_H : ∀ t t' phi, t' < t → Formula.all_past phi ∈ mcs t → phi ∈ mcs t'
  /--
  Forward H coherence: H phi at a future time t' implies phi at present time t.

  This is the "looking back from the future" condition. If at some future time t' > t
  we have "phi was always true in the past", then phi must have been true at t.
  -/
  forward_H : ∀ t t' phi, t < t' → Formula.all_past phi ∈ mcs t' → phi ∈ mcs t
  /--
  Backward G coherence: G phi at a past time t' implies phi at present time t.

  This is the "looking forward from the past" condition. If at some past time t' < t
  we have "phi will always be true in the future", then phi must be true at t.
  -/
  backward_G : ∀ t t' phi, t' < t → Formula.all_future phi ∈ mcs t' → phi ∈ mcs t

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Basic Accessors
-/

/-- Get the MCS at a specific time -/
def IndexedMCSFamily.at (family : IndexedMCSFamily D) (t : D) : Set Formula :=
  family.mcs t

/-- The MCS at any time is consistent -/
lemma IndexedMCSFamily.consistent (family : IndexedMCSFamily D) (t : D) :
    SetConsistent (family.mcs t) :=
  (family.is_mcs t).1

/-- The MCS at any time is maximal (cannot be consistently extended) -/
lemma IndexedMCSFamily.maximal (family : IndexedMCSFamily D) (t : D) :
    ∀ φ : Formula, φ ∉ family.mcs t → ¬SetConsistent (insert φ (family.mcs t)) :=
  (family.is_mcs t).2

/-!
## Derived Coherence Lemmas

These lemmas follow from the basic coherence conditions and are useful for proofs.
-/

/--
G phi propagates transitively through future times.

If `G phi ∈ mcs(t)` and `t < t' < t''`, then `phi ∈ mcs(t')` and `phi ∈ mcs(t'')`.
-/
lemma IndexedMCSFamily.forward_G_chain (family : IndexedMCSFamily D)
    {t t' : D} (htt' : t < t') (phi : Formula) (hG : Formula.all_future phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.forward_G t t' phi htt' hG

/--
H phi propagates transitively through past times.

If `H phi ∈ mcs(t)` and `t'' < t' < t`, then `phi ∈ mcs(t')` and `phi ∈ mcs(t'')`.
-/
lemma IndexedMCSFamily.backward_H_chain (family : IndexedMCSFamily D)
    {t t' : D} (ht't : t' < t) (phi : Formula) (hH : Formula.all_past phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.backward_H t t' phi ht't hH

/--
GG phi implies G phi propagation (using Temporal 4 axiom).

If `G(G phi) ∈ mcs(t)` and `t < t'`, then `G phi ∈ mcs(t')`.

This uses the Temporal 4 axiom `G phi -> GG phi` in the contrapositive direction:
From `GG phi ∈ mcs(t)`, we have `G phi` will be at all strictly future times.
-/
lemma IndexedMCSFamily.GG_to_G (family : IndexedMCSFamily D)
    {t t' : D} (htt' : t < t') (phi : Formula)
    (hGG : Formula.all_future (Formula.all_future phi) ∈ family.mcs t) :
    Formula.all_future phi ∈ family.mcs t' :=
  family.forward_G t t' (Formula.all_future phi) htt' hGG

/--
HH phi implies H phi propagation (using Temporal 4 dual for H).

If `H(H phi) ∈ mcs(t)` and `t' < t`, then `H phi ∈ mcs(t')`.
-/
lemma IndexedMCSFamily.HH_to_H (family : IndexedMCSFamily D)
    {t t' : D} (ht't : t' < t) (phi : Formula)
    (hHH : Formula.all_past (Formula.all_past phi) ∈ family.mcs t) :
    Formula.all_past phi ∈ family.mcs t' :=
  family.backward_H t t' (Formula.all_past phi) ht't hHH

/-!
## Negation Completeness in Family MCS

Note: Full negation completeness proofs are available in the Boneyard MCS theory.
For now, we expose the MCS structure directly which provides maximality.
The set-based negation completeness theorem `set_mcs_negation_complete` in
`Bimodal.Boneyard.Metalogic.Completeness` can be imported if needed.
-/

/-!
## Theorem Membership in Family MCS

Theorems (provable formulas) are in every MCS of the family.
-/

/--
Theorems are in every MCS of the family.
-/
lemma IndexedMCSFamily.theorem_mem (family : IndexedMCSFamily D)
    (t : D) (phi : Formula) (h_deriv : Bimodal.ProofSystem.DerivationTree [] phi) :
    phi ∈ family.mcs t :=
  theorem_in_mcs (family.is_mcs t) h_deriv

/-!
## Properties for Task Relation

These lemmas will be used when proving the canonical task relation properties.
-/

/--
If G phi is in the MCS at time t, then for any strictly future time t' > t,
phi is in the MCS at t'.

This is just a restatement of forward_G for clarity in task relation proofs.
-/
lemma IndexedMCSFamily.G_implies_future_phi (family : IndexedMCSFamily D)
    {t t' : D} (hlt : t < t') {phi : Formula} (hG : Formula.all_future phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.forward_G t t' phi hlt hG

/--
If H phi is in the MCS at time t, then for any strictly past time t' < t,
phi is in the MCS at t'.

This is just a restatement of backward_H for clarity in task relation proofs.
-/
lemma IndexedMCSFamily.H_implies_past_phi (family : IndexedMCSFamily D)
    {t t' : D} (hlt : t' < t) {phi : Formula} (hH : Formula.all_past phi ∈ family.mcs t) :
    phi ∈ family.mcs t' :=
  family.backward_H t t' phi hlt hH

/-!
## Indexed Family Construction

Given an MCS at the origin (time 0), we construct a coherent indexed family.

**Construction Strategy**:
1. At the origin: use the given MCS directly
2. For future times t > 0: seed with formulas phi where G phi is in origin MCS
3. For past times t < 0: seed with formulas phi where H phi is in origin MCS
4. Extend each seed to MCS via Lindenbaum's lemma

**Key Insight**: The seed sets are consistent because they come from an MCS:
- If G phi ∈ origin, then {phi | G phi ∈ origin} is consistent
- If it were inconsistent, some finite subset would derive bot
- But that would contradict origin being consistent (by G propagation)

**Coherence Proof Strategy**:
- forward_G: If G phi ∈ mcs(t), phi is in the seed for t' > t (by definition or transitivity)
- backward_H: Symmetric to forward_G for past direction
- forward_H/backward_G: These require careful case analysis using Temporal 4 axiom
-/

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
### Seed Set Definitions

The seed set at time t collects formulas that MUST be in the MCS at t,
based on the temporal operators in the root MCS.
-/

/--
Future seed: formulas that must be true at time t based on G formulas in the root MCS.

If t > 0 (strictly future of origin), include phi whenever G phi is in root.
If t = 0, include the root MCS itself.
If t < 0, this seed is empty (past times use past_seed).

Actually, for a unified construction, we define:
- future_seed collects phi where G phi is in root AND t > 0
- past_seed collects phi where H phi is in root AND t < 0
- At t = 0, we use the root MCS directly
-/
def future_seed (Gamma : Set Formula) (t : D) : Set Formula :=
  if (0 : D) < t then {phi | Formula.all_future phi ∈ Gamma}
  else ∅

/--
Past seed: formulas that must be true at time t based on H formulas in the root MCS.

If t < 0 (strictly past of origin), include phi whenever H phi is in root.
-/
def past_seed (Gamma : Set Formula) (t : D) : Set Formula :=
  if t < (0 : D) then {phi | Formula.all_past phi ∈ Gamma}
  else ∅

/--
Combined seed for time t, based on position relative to origin.

- t > 0: future_seed (phi where G phi in root)
- t < 0: past_seed (phi where H phi in root)
- t = 0: the root MCS itself
-/
def time_seed (Gamma : Set Formula) (t : D) : Set Formula :=
  if t = 0 then Gamma
  else if (0 : D) < t then future_seed D Gamma t
  else past_seed D Gamma t

/-!
### Seed Set Consistency

The key lemma: seed sets are consistent when derived from an MCS.
-/

/--
The future seed derived from an MCS is consistent.

**Proof Idea**: If the future seed were inconsistent, some finite subset
{phi_1, ..., phi_n} would derive bot. But then {G phi_1, ..., G phi_n}
would derive G bot (by temporal K distribution), and G bot is derivable
to bot (vacuous), contradicting the root MCS being consistent.

**Note**: This proof is subtle and requires careful use of temporal axioms.
For now, we axiomatize it and note it can be proven from temporal K.
-/
lemma future_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) (ht : (0 : D) < t) : SetConsistent (future_seed D Gamma t) := by
  simp only [future_seed, ht, ↓reduceIte]
  intro L hL
  -- L is a list of formulas where each phi has G phi ∈ Gamma
  -- We need to show L is consistent
  -- The proof uses the fact that if L were inconsistent, we could derive
  -- a contradiction in Gamma using temporal K distribution
  by_contra h_incons
  -- Get derivation of bot from L
  unfold Consistent at h_incons
  push_neg at h_incons
  obtain ⟨d_bot⟩ := h_incons
  -- For each phi in L, G phi ∈ Gamma
  -- Use temporal K to show that if L ⊢ bot, then {G phi | phi ∈ L} ⊢ G bot
  -- Since all elements of L.map all_future are in Gamma (by seed definition),
  -- and Gamma is deductively closed, G bot ∈ Gamma
  -- We then derive a contradiction using the interaction between G bot and MCS properties

  -- Step 1: Apply generalized_temporal_k to get derivation of G bot from G L
  let L_G := L.map Formula.all_future
  have d_G_bot : L_G ⊢ Formula.all_future Formula.bot :=
    Bimodal.Theorems.generalized_temporal_k L Formula.bot d_bot

  -- Step 2: Show all elements of L_G are in Gamma
  have h_L_G_sub : ∀ ψ ∈ L_G, ψ ∈ Gamma := by
    intro ψ h_mem
    simp only [L_G, List.mem_map] at h_mem
    obtain ⟨φ, h_φ_in_L, rfl⟩ := h_mem
    -- φ ∈ L means φ ∈ {phi | G phi ∈ Gamma}, so G φ ∈ Gamma
    exact hL φ h_φ_in_L

  -- Step 3: By MCS deductive closure, G bot ∈ Gamma
  have h_G_bot_in : Formula.all_future Formula.bot ∈ Gamma :=
    Bimodal.Boneyard.Metalogic.set_mcs_closed_under_derivation h_mcs L_G h_L_G_sub d_G_bot

  -- Step 4: Now we need to derive a contradiction from G bot ∈ Gamma
  --
  -- **Analysis**: In TM logic with IRREFLEXIVE temporal operators (G looks at strictly
  -- future times only), we CANNOT derive `bot` from `G bot` syntactically. This is
  -- because TM lacks the temporal T axiom (`G phi → phi`), which would require the
  -- temporal accessibility relation to be reflexive.
  --
  -- The formula `G bot` means "at all STRICTLY future times, bot holds", which is
  -- vacuously true if there are no future times. So `G bot` is actually SATISFIABLE
  -- in models with bounded future (e.g., at the last moment of a finite time structure).
  --
  -- **Semantic Argument**: In canonical models with UNBOUNDED time structures (like Z
  -- or R), there are always future times, so `G bot` is false (since bot is never true).
  -- This means `G bot ∉ Gamma` for any MCS Gamma that's satisfiable in such a model.
  --
  -- **Resolution Options**:
  -- 1. Restrict to unbounded time structures (add axiom `sometime_future top`)
  -- 2. Use semantic satisfiability from soundness/completeness (circular for proving completeness)
  -- 3. Strengthen the MCS construction to exclude `G bot` by construction
  --
  -- For now, we note that in the standard TM canonical construction with Z as the time
  -- domain, this holds by the completeness theorem itself. The sorry marks where this
  -- semantic property needs to be formally connected.
  --
  -- **Key Insight**: The issue is that `¬(G bot)` = `sometime_future top` is VALID in
  -- unbounded time models but NOT derivable as a theorem in TM without an additional
  -- axiom asserting unbounded time (like `sometime_future top`).
  sorry

/--
The past seed derived from an MCS is consistent.

Symmetric to future_seed_consistent, using H instead of G.
-/
lemma past_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) (ht : t < (0 : D)) : SetConsistent (past_seed D Gamma t) := by
  simp only [past_seed, ht, ↓reduceIte]
  intro L hL
  -- L is a list of formulas where each phi has H phi ∈ Gamma
  -- We need to show L is consistent
  by_contra h_incons
  unfold Consistent at h_incons
  push_neg at h_incons
  obtain ⟨d_bot⟩ := h_incons

  -- Step 1: Apply temporal duality to get generalized_past_k
  -- From L ⊢ bot, we derive H L ⊢ H bot
  -- This uses the temporal duality: if we have G-version proofs, we can get H-version
  -- by swapping past/future operators.
  --
  -- The generalized past K rule: If L ⊢ phi, then (L.map all_past) ⊢ all_past phi
  -- is derivable via temporal duality applied to generalized_temporal_k.

  -- Step 2: Show all elements of L.map all_past are in Gamma
  -- For each phi ∈ L, H phi ∈ Gamma (by past_seed definition)

  -- Step 3: By MCS deductive closure, H bot ∈ Gamma

  -- Step 4: Same issue as future_seed_consistent - we cannot derive bot from H bot
  -- in TM logic because H is also irreflexive (looks at strictly PAST times only).
  --
  -- **Symmetric Analysis**: Just as G bot is vacuously true if there are no future times,
  -- H bot is vacuously true if there are no past times. In canonical models with
  -- unbounded past, H bot would be false, so H bot ∉ any satisfiable MCS.
  --
  -- The proof requires the same infrastructure as future_seed_consistent.
  sorry

/--
The time seed at any time t is consistent.
-/
lemma time_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) : SetConsistent (time_seed D Gamma t) := by
  simp only [time_seed]
  split_ifs with h0 hpos
  · -- t = 0: use the root MCS
    exact h_mcs.1
  · -- t > 0: future seed
    exact future_seed_consistent D Gamma h_mcs t hpos
  · -- t < 0: past seed
    push_neg at hpos
    have hneg : t < 0 := lt_of_le_of_ne hpos h0
    exact past_seed_consistent D Gamma h_mcs t hneg

/-!
### MCS Extension via Lindenbaum

Extend each time seed to an MCS using Lindenbaum's lemma.
-/

/--
Extend the seed at time t to an MCS.
-/
noncomputable def mcs_at_time (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) : Set Formula :=
  extendToMCS (time_seed D Gamma t) (time_seed_consistent D Gamma h_mcs t)

/--
The MCS at time t contains the time seed.
-/
lemma mcs_at_time_contains_seed (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) : time_seed D Gamma t ⊆ mcs_at_time D Gamma h_mcs t :=
  extendToMCS_contains _ _

/--
The MCS at time t is maximal consistent.
-/
lemma mcs_at_time_is_mcs (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) : SetMaximalConsistent (mcs_at_time D Gamma h_mcs t) :=
  extendToMCS_is_mcs _ _

/-!
### The Indexed Family Construction

Now we assemble everything into an IndexedMCSFamily.
-/

/--
Construct an indexed MCS family from a root MCS at the origin.

**Construction**:
- `mcs(t)` = extend time_seed to MCS via Lindenbaum
- Coherence conditions follow from seed definitions and Lindenbaum extension

**Usage**: Given a consistent formula phi, extend {phi} to an MCS Gamma,
then `construct_indexed_family Gamma h_mcs` gives a family where phi
is true at the origin.
-/
noncomputable def construct_indexed_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
    IndexedMCSFamily D where
  mcs := mcs_at_time D Gamma h_mcs
  is_mcs := mcs_at_time_is_mcs D Gamma h_mcs

  -- Forward G coherence: G phi ∈ mcs(t) → phi ∈ mcs(t') for t < t'
  forward_G := by
    intro t t' phi hlt hG
    -- **Key Insight**: This proof relies on the relationship between
    -- G phi ∈ mcs(t) and the seed structure. We use:
    -- 1. MCS deductive closure (set_mcs_closed_under_derivation)
    -- 2. Temporal 4 axiom (G phi → GG phi, via set_mcs_all_future_all_future)
    -- 3. Seed containment in MCS (mcs_at_time_contains_seed)
    --
    -- The proof proceeds by showing phi is in the seed for mcs(t'),
    -- which requires relating G phi ∈ mcs(t) to G phi ∈ Gamma.
    --
    -- **Case Analysis on t**:
    -- When t = 0: G phi ∈ mcs(0) = extendToMCS(Gamma)
    -- When t > 0: G phi ∈ mcs(t) = extendToMCS(future_seed), need GG phi ∈ Gamma
    -- When t < 0: G phi ∈ mcs(t) = extendToMCS(past_seed), cross-origin case
    --
    -- **Main Strategy**:
    -- Use the contrapositive with MCS negation completeness (neg_complete).
    -- If phi ∉ mcs(t'), then ¬phi ∈ mcs(t') by negation completeness.
    -- This should lead to G phi ∉ mcs(t) by temporal semantics.
    --
    -- However, this strategy requires connecting different MCS at different times,
    -- which is exactly what the indexed family construction is trying to establish.
    --
    -- **Current Status**: This proof is incomplete. The construction may need
    -- refinement to ensure coherence. See research-001.md for detailed analysis.
    --
    -- The sorries mark where additional infrastructure is needed:
    -- - Lemma relating MCS extension to seed membership
    -- - Lemma for cross-time-point MCS coherence
    sorry

  -- Backward H coherence: H phi ∈ mcs(t) → phi ∈ mcs(t') for t' < t
  backward_H := by
    intro t t' phi hlt hH
    -- **Symmetric to forward_G** but using H (all_past) and past direction.
    --
    -- **Key Components**:
    -- 1. Temporal 4 for H: H phi → HH phi (via set_mcs_all_past_all_past)
    -- 2. Past seed: {psi | H psi ∈ Gamma} for t < 0
    -- 3. Seed containment in MCS
    --
    -- **Main Strategy**: Similar to forward_G, use temporal axioms and
    -- MCS closure properties to show phi is in the seed or extension at t'.
    --
    -- **Current Status**: This proof mirrors forward_G and has the same
    -- infrastructure requirements.
    sorry

  -- Forward H coherence: H phi ∈ mcs(t') → phi ∈ mcs(t) for t < t'
  forward_H := by
    intro t t' phi hlt hH
    -- **The "inverse" direction**: "Looking back from the future"
    --
    -- If H phi ∈ mcs(t') where t < t', then phi ∈ mcs(t).
    -- Semantically: if "phi was always true in the past" holds at t',
    -- then phi must have been true at the earlier time t.
    --
    -- **Key Difference from forward_G**:
    -- This is NOT about seed propagation but semantic coherence.
    -- The MCS at t' claims something about ALL past times, including t.
    --
    -- **Proof Strategy (Contrapositive)**:
    -- 1. Assume phi ∉ mcs(t)
    -- 2. By MCS negation completeness: ¬phi ∈ mcs(t)
    -- 3. Show this contradicts H phi ∈ mcs(t') for t < t'
    --    (Because H phi means phi at ALL past times, but t is past of t')
    --
    -- This requires connecting mcs(t) and mcs(t') through temporal semantics.
    -- The key lemma needed: if ¬phi ∈ mcs(t) and t < t', then ¬(H phi) ∈ mcs(t')
    -- which uses the Temporal A axiom or similar.
    --
    -- **Current Status**: Requires negation completeness lemma (neg_complete)
    -- which has a sorry in CanonicalWorld.lean.
    sorry

  -- Backward G coherence: G phi ∈ mcs(t') → phi ∈ mcs(t) for t' < t
  backward_G := by
    intro t t' phi hlt hG
    -- **The "inverse" direction**: "Looking forward from the past"
    --
    -- If G phi ∈ mcs(t') where t' < t, then phi ∈ mcs(t).
    -- Semantically: if "phi will always be true in the future" holds at t',
    -- then phi must be true at the later time t.
    --
    -- **Proof Strategy (Contrapositive)**: Similar to forward_H
    -- 1. Assume phi ∉ mcs(t)
    -- 2. By MCS negation completeness: ¬phi ∈ mcs(t)
    -- 3. Show this contradicts G phi ∈ mcs(t') for t' < t
    --    (Because G phi means phi at ALL future times, but t is future of t')
    --
    -- **Key Lemma Needed**: if ¬phi ∈ mcs(t) and t' < t, then ¬(G phi) ∈ mcs(t')
    --
    -- **Current Status**: Requires negation completeness and cross-time
    -- coherence infrastructure.
    sorry

/-!
### Properties of the Constructed Family
-/

/--
The MCS at the origin is exactly the extended root MCS.

At t = 0, time_seed returns Gamma directly, so mcs(0) is
the Lindenbaum extension of Gamma, which contains Gamma.
-/
lemma construct_indexed_family_origin (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (phi : Formula) (h_phi : phi ∈ Gamma) :
    phi ∈ (construct_indexed_family D Gamma h_mcs).mcs 0 := by
  -- mcs(0) = extendToMCS (time_seed D Gamma 0)
  -- time_seed D Gamma 0 = Gamma (by definition, when t = 0)
  -- extendToMCS contains the seed
  have h_seed : phi ∈ time_seed D Gamma 0 := by
    simp only [time_seed, ↓reduceIte]
    exact h_phi
  exact mcs_at_time_contains_seed D Gamma h_mcs 0 h_seed

/--
At the origin, the constructed family's MCS extends Gamma.
-/
lemma construct_indexed_family_origin_extends (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
    Gamma ⊆ (construct_indexed_family D Gamma h_mcs).mcs 0 := by
  intro phi h_phi
  exact construct_indexed_family_origin D Gamma h_mcs phi h_phi

end Bimodal.Metalogic.Representation
