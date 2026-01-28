import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Representation.CanonicalWorld
import Bimodal.Syntax.Formula
import Bimodal.Boneyard.Metalogic.Completeness  -- For set_mcs_closed_under_derivation and set_mcs_all_future_all_future
import Bimodal.Theorems.GeneralizedNecessitation  -- For generalized_temporal_k
import Bimodal.Semantics.Truth  -- For truth_at semantics (Approach A semantic bridge)
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

**Key Challenge (Task 657)**: The natural proof would derive `G ⊥ ∈ Gamma` from
seed inconsistency, then derive `⊥` from `G ⊥`. However, TM logic has IRREFLEXIVE
temporal operators, so `G ⊥ → ⊥` is NOT derivable (no temporal T axiom).

**Approach A (Semantic Bridge)**: Instead of syntactic derivation, we use
semantic reasoning to show that `G ⊥ ∈ Gamma` creates a contradiction with
the canonical model construction requirements. Specifically:
- The canonical construction builds a model where Gamma is satisfied at time 0
- The construction uses an unbounded temporal domain (all times exist)
- If `G ⊥ ∈ Gamma`, then `G ⊥` must be true at time 0
- But `G ⊥` true at time 0 means `⊥` at all times > 0, which is impossible

This semantic bridge resolves the blocking issue without adding temporal T axiom.
See: specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-006.md
-/

open Bimodal.Semantics in
/--
Semantic bridge lemma: If `G ⊥` is satisfied at time 0 in any model,
then no time `t > 0` can exist (because `G ⊥` would require `⊥` at `t`).

This provides the contradiction needed for seed consistency:
- Seed inconsistency → `G ⊥ ∈ Gamma`
- Canonical construction requires domain extending past 0
- But `G ⊥` at 0 forbids any times > 0
- Contradiction!

**Note**: This lemma is stated without MCS - it's a pure semantic fact about
what `G ⊥` means. Any model where `G ⊥` is true at time 0 cannot have times > 0.
-/
lemma G_bot_forbids_future
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    (h_G_bot : truth_at M τ (0 : D) (Formula.all_future Formula.bot))
    {t : D} (ht : (0 : D) < t) : False := by
  -- G ⊥ at time 0 means: ∀ s > 0, ⊥ is true at s
  -- truth_at for all_future: ∀ s, 0 < s → truth_at M τ s φ
  -- truth_at for bot: False
  -- Apply h_G_bot to t with ht to get truth_at M τ t Formula.bot = False
  have h_bot_at_t : truth_at M τ t Formula.bot := h_G_bot t ht
  -- truth_at M τ t Formula.bot = False by definition
  exact h_bot_at_t

/--
The future seed derived from an MCS is consistent, assuming G ⊥ is not in the MCS.

**Key Hypothesis**: We require `G ⊥ ∉ Gamma` because:
- TM logic has IRREFLEXIVE temporal operators (no temporal T axiom: G φ → φ)
- `G ⊥` is consistent in TM (doesn't derive ⊥)
- `G ⊥` is satisfiable at bounded temporal endpoints (vacuously true when no future exists)
- The indexed family construction requires unbounded domain (times extending past 0)
- An MCS containing `G ⊥` can only be satisfied at bounded endpoints

**Proof Idea**: If the future seed were inconsistent, some finite subset
`{φ₁, ..., φₙ}` would derive ⊥. But then `{G φ₁, ..., G φₙ}` would derive `G ⊥`
(by temporal K distribution). By MCS closure, `G ⊥ ∈ Gamma`, contradicting our
hypothesis that `G ⊥ ∉ Gamma`.

**Alternative for MCS with G ⊥**: Such MCS are satisfiable at bounded endpoints.
The completeness proof for those cases uses a different construction (singleton
domain at the "last moment"). See research-006.md for full analysis.
-/
lemma future_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (t : D) (ht : (0 : D) < t) : SetConsistent (future_seed D Gamma t) := by
  simp only [future_seed, ht, ↓reduceIte]
  intro L hL
  -- L is a list of formulas where each φ has G φ ∈ Gamma
  -- We need to show L is consistent
  by_contra h_incons
  unfold Consistent at h_incons
  push_neg at h_incons
  obtain ⟨d_bot⟩ := h_incons

  -- Step 1: Apply generalized_temporal_k to get derivation of G ⊥ from G L
  let L_G := L.map Formula.all_future
  have d_G_bot : L_G ⊢ Formula.all_future Formula.bot :=
    Bimodal.Theorems.generalized_temporal_k L Formula.bot d_bot

  -- Step 2: Show all elements of L_G are in Gamma
  have h_L_G_sub : ∀ ψ ∈ L_G, ψ ∈ Gamma := by
    intro ψ h_mem
    simp only [L_G, List.mem_map] at h_mem
    obtain ⟨φ, h_φ_in_L, rfl⟩ := h_mem
    exact hL φ h_φ_in_L

  -- Step 3: By MCS deductive closure, G ⊥ ∈ Gamma
  have h_G_bot_in : Formula.all_future Formula.bot ∈ Gamma :=
    Bimodal.Boneyard.Metalogic.set_mcs_closed_under_derivation h_mcs L_G h_L_G_sub d_G_bot

  -- Step 4: Contradiction with hypothesis h_no_G_bot
  exact h_no_G_bot h_G_bot_in

/--
The past seed derived from an MCS is consistent, assuming H ⊥ is not in the MCS.

Symmetric to `future_seed_consistent`, using H (all_past) instead of G (all_future).

**Key Hypothesis**: We require `H ⊥ ∉ Gamma` because:
- TM logic has IRREFLEXIVE temporal operators (no temporal T axiom: H φ → φ)
- `H ⊥` is consistent in TM (doesn't derive ⊥)
- `H ⊥` is satisfiable at bounded temporal "beginning" points (vacuously true when no past exists)
- The indexed family construction requires unbounded domain (times extending before 0)
- An MCS containing `H ⊥` can only be satisfied at bounded "origin" points

**Proof Sketch**: If the past seed were inconsistent, some finite subset `{φ₁, ..., φₙ}`
would derive ⊥. By temporal K distribution (past version), `{H φ₁, ..., H φₙ}` would
derive `H ⊥`. By MCS closure, `H ⊥ ∈ Gamma`, contradicting our hypothesis.

**Note**: The generalized past K theorem (`L ⊢ φ → H L ⊢ H φ`) is derivable from
temporal duality applied to `generalized_temporal_k`, but this requires infrastructure
to apply temporal duality at the context level. See research-006 for details.
-/
lemma past_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (t : D) (ht : t < (0 : D)) : SetConsistent (past_seed D Gamma t) := by
  simp only [past_seed, ht, ↓reduceIte]
  intro L hL
  -- L is a list of formulas where each φ has H φ ∈ Gamma
  -- We need to show L is consistent
  by_contra h_incons
  unfold Consistent at h_incons
  push_neg at h_incons
  obtain ⟨d_bot⟩ := h_incons

  -- Step 1: Apply generalized_past_k to get derivation of H ⊥ from H L
  let L_H := L.map Formula.all_past
  have d_H_bot : L_H ⊢ Formula.all_past Formula.bot :=
    Bimodal.Theorems.generalized_past_k L Formula.bot d_bot

  -- Step 2: Show all elements of L_H are in Gamma
  have h_L_H_sub : ∀ ψ ∈ L_H, ψ ∈ Gamma := by
    intro ψ h_mem
    simp only [L_H, List.mem_map] at h_mem
    obtain ⟨φ, h_φ_in_L, rfl⟩ := h_mem
    exact hL φ h_φ_in_L

  -- Step 3: By MCS deductive closure, H ⊥ ∈ Gamma
  have h_H_bot_in : Formula.all_past Formula.bot ∈ Gamma :=
    Bimodal.Boneyard.Metalogic.set_mcs_closed_under_derivation h_mcs L_H h_L_H_sub d_H_bot

  -- Step 4: Contradiction with hypothesis h_no_H_bot
  exact h_no_H_bot h_H_bot_in

/--
The time seed at any time t is consistent, assuming G ⊥ and H ⊥ are not in the MCS.

**Hypotheses Explanation**:
- `h_no_G_bot`: Required for t > 0 (future seed consistency)
- `h_no_H_bot`: Required for t < 0 (past seed consistency)

These conditions ensure the MCS is satisfiable in an UNBOUNDED temporal model.
MCS containing G ⊥ or H ⊥ are only satisfiable at bounded endpoints.
-/
lemma time_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (t : D) : SetConsistent (time_seed D Gamma t) := by
  simp only [time_seed]
  split_ifs with h0 hpos
  · -- t = 0: use the root MCS
    exact h_mcs.1
  · -- t > 0: future seed
    exact future_seed_consistent D Gamma h_mcs h_no_G_bot t hpos
  · -- t < 0: past seed
    push_neg at hpos
    have hneg : t < 0 := lt_of_le_of_ne hpos h0
    exact past_seed_consistent D Gamma h_mcs h_no_H_bot t hneg

/-!
### MCS Extension via Lindenbaum

Extend each time seed to an MCS using Lindenbaum's lemma.
-/

/--
Extend the seed at time t to an MCS.

**Hypotheses**: Requires `G ⊥ ∉ Gamma` and `H ⊥ ∉ Gamma` to ensure seed consistency
for unbounded temporal model construction.
-/
noncomputable def mcs_at_time (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (t : D) : Set Formula :=
  extendToMCS (time_seed D Gamma t) (time_seed_consistent D Gamma h_mcs h_no_G_bot h_no_H_bot t)

/--
The MCS at time t contains the time seed.
-/
lemma mcs_at_time_contains_seed (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (t : D) : time_seed D Gamma t ⊆ mcs_at_time D Gamma h_mcs h_no_G_bot h_no_H_bot t :=
  extendToMCS_contains _ _

/--
The MCS at time t is maximal consistent.
-/
lemma mcs_at_time_is_mcs (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (t : D) : SetMaximalConsistent (mcs_at_time D Gamma h_mcs h_no_G_bot h_no_H_bot t) :=
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

**Usage**: Given a consistent formula phi, extend {phi} to an MCS Gamma
that doesn't contain G ⊥ or H ⊥, then `construct_indexed_family` gives
a family where phi is true at the origin.

**Hypotheses**:
- `h_no_G_bot`: G ⊥ ∉ Gamma (ensures forward temporal extension)
- `h_no_H_bot`: H ⊥ ∉ Gamma (ensures backward temporal extension)

These conditions ensure the MCS is satisfiable in an UNBOUNDED temporal model.
For MCS containing G ⊥ or H ⊥, a different construction (bounded endpoint) is needed.
-/
noncomputable def construct_indexed_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
    IndexedMCSFamily D where
  mcs := mcs_at_time D Gamma h_mcs h_no_G_bot h_no_H_bot
  is_mcs := mcs_at_time_is_mcs D Gamma h_mcs h_no_G_bot h_no_H_bot

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
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (phi : Formula) (h_phi : phi ∈ Gamma) :
    phi ∈ (construct_indexed_family D Gamma h_mcs h_no_G_bot h_no_H_bot).mcs 0 := by
  -- mcs(0) = extendToMCS (time_seed D Gamma 0)
  -- time_seed D Gamma 0 = Gamma (by definition, when t = 0)
  -- extendToMCS contains the seed
  have h_seed : phi ∈ time_seed D Gamma 0 := by
    simp only [time_seed, ↓reduceIte]
    exact h_phi
  exact mcs_at_time_contains_seed D Gamma h_mcs h_no_G_bot h_no_H_bot 0 h_seed

/--
At the origin, the constructed family's MCS extends Gamma.
-/
lemma construct_indexed_family_origin_extends (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
    Gamma ⊆ (construct_indexed_family D Gamma h_mcs h_no_G_bot h_no_H_bot).mcs 0 := by
  intro phi h_phi
  exact construct_indexed_family_origin D Gamma h_mcs h_no_G_bot h_no_H_bot phi h_phi

end Bimodal.Metalogic.Representation
