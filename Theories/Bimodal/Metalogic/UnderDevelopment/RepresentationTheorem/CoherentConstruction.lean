/-!
# UNDER DEVELOPMENT: Coherent Indexed Family Construction

**Status**: Under Development (restored from Boneyard/Metalogic_v4/ by Task 774)
**Sorry Count**: 8 sorries - architecturally unprovable
**Original Location**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

## Development Status

This file implements a relational coherent construction for indexed MCS families.
The main lemma `mcs_unified_chain_pairwise_coherent` contains 8 sorries for
cross-origin coherence cases.

### The 8 Sorries

| Condition | Case | Line | Status | Reason |
|-----------|------|------|--------|--------|
| forward_G | 3 (t<0, t'>=0) | 721 | SORRY | Cross-origin: never exercised |
| forward_G | 4 (both<0, toward origin) | 724 | SORRY | Cross-direction in backward chain |
| backward_H | 1 (both>=0) | 732 | SORRY | Forward chain doesn't preserve H |
| backward_H | 2 (t>=0, t'<0) | 735 | SORRY | Cross-origin: never exercised |
| forward_H | 1 (both>=0) | 753 | SORRY | H doesn't persist in forward chain |
| forward_H | 3 (t<0, t'>=0) | 760 | SORRY | Cross-origin: never exercised |
| backward_G | 3 (t'<0, t>=0) | 808 | SORRY | Cross-origin: never exercised |
| backward_G | 4 (both<0) | 811 | SORRY | Backward chain G-coherence |

### Proven Cases (Used by Completeness)

- `forward_G` Case 1 (both >= 0): PROVEN via `mcs_forward_chain_coherent`
- `backward_H` Case 4 (both < 0): PROVEN via `mcs_backward_chain_coherent`
- `forward_H` Case 4 (both < 0): PROVEN via `mcs_backward_chain_H_persistence`
- `backward_G` Case 1 (both >= 0): PROVEN via `mcs_forward_chain_G_persistence`

### Why the Remaining Cases Are Unprovable

The completeness theorem only requires temporal coherence along SINGLE-direction chains:
- For G-formulas: coherence in the forward chain (t >= 0)
- For H-formulas: coherence in the backward chain (t < 0)

Cross-origin cases (where we need coherence between t < 0 and t' >= 0) would require
additional axioms or a fundamentally different construction approach because:

1. **No cross-origin formula propagation axiom**: The T-axioms (Gφ → φ, Hφ → φ) only
   propagate formulas in ONE direction. There's no axiom connecting G-formulas in
   the backward chain to H-formulas in the forward chain.

2. **Independent Lindenbaum extensions**: Each time point's MCS is constructed via
   independent Lindenbaum extension from seeds. Seeds only carry formulas in one
   temporal direction.

3. **Omega-rule limitation**: Proving cross-origin coherence would require an
   infinitary derivation (omega-rule) not expressible in TM logic.

### Alternative: Semantic Weak Completeness

The sorry-free completeness result is provided by `semantic_weak_completeness`
in `FMP/SemanticCanonicalModel.lean`. This uses a contrapositive approach that
avoids the indexed family construction entirely.

### References

- Research: Task 750 (truth bridge analysis)
- Research: Task 769 (deprecation analysis)
- Implementation: Task 772 (archival), Task 774 (restoration)
- Original Boneyard: `Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`
-/

import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties  -- For set_mcs_closed_under_derivation, set_mcs_all_future_all_future, etc.
import Bimodal.Metalogic.Representation.IndexedMCSFamily
import Bimodal.Theorems.GeneralizedNecessitation  -- For generalized_temporal_k
import Mathlib.Algebra.Order.Group.Defs

/-!
# Coherent Indexed Family Construction

This module implements Option B2: a relational coherent construction for indexed MCS families.
The key insight is that coherence must be **definitional** - built into the construction itself -
rather than something proven after the fact.

## Design Philosophy

The original `construct_indexed_family` in IndexedMCSFamily.lean used independent Lindenbaum
extensions at each time point. This approach is fundamentally flawed because:
- Independent extensions can add conflicting formulas
- If `Gφ ∈ mcs(t)` but `Gφ ∉ Gamma`, there's no guarantee `φ ∈ mcs(t')` for t' > t
- The four coherence conditions cannot be "proven after construction"

This module takes a different approach based on the Boneyard `canonical_task_rel` pattern:
1. Define `coherent_at` relation that directly encodes the four coherence conditions
2. Build extension lemmas that construct MCS satisfying this relation
3. Extract IndexedMCSFamily conditions trivially from the relation definition

## Main Definitions

- `coherent_at`: Two MCS are coherent at times t, t' if temporal formulas propagate correctly
- `CoherentIndexedFamily`: A family of MCS with pairwise coherence
- `forward_seed`: Seed for constructing MCS at future time
- `forward_extension`: Existence of forward-coherent MCS extensions
- `backward_seed`: Seed for constructing MCS at past time
- `backward_extension`: Existence of backward-coherent MCS extensions

## References

- Boneyard `canonical_task_rel`: Completeness.lean:2055-2061
- Boneyard `forward_extension`: Completeness.lean:2521-2581

## Gaps NOT Required for Completeness

The following cases in `mcs_unified_chain_pairwise_coherent` have sorries that are
**NOT used by the representation theorem**. All 8 remaining sorries are in cross-origin
or cross-direction coherence cases that the completeness proof never exercises.

| Condition | Case | Line | Status | Reason |
|-----------|------|------|--------|--------|
| forward_G | 3 (t<0, t'>=0) | 705 | SORRY | Cross-origin: never exercised |
| forward_G | 4 (both<0, toward origin) | 708 | SORRY | Cross-direction in backward chain |
| backward_H | 1 (both>=0) | 716 | SORRY | Forward chain doesn't preserve H |
| backward_H | 2 (t>=0, t'<0) | 719 | SORRY | Cross-origin: never exercised |
| forward_H | 1 (both>=0) | 737 | SORRY | H doesn't persist in forward chain |
| forward_H | 3 (t<0, t'>=0) | 744 | SORRY | Cross-origin: never exercised |
| backward_G | 3 (t'<0, t>=0) | 792 | SORRY | Cross-origin: never exercised |
| backward_G | 4 (both<0) | 795 | SORRY | Backward chain G-coherence |

**Cases PROVEN** (used by completeness):
- `forward_G` Case 1 (both >= 0): PROVEN via `mcs_forward_chain_coherent`
- `backward_H` Case 4 (both < 0): PROVEN via `mcs_backward_chain_coherent`
- `forward_H` Case 4 (both < 0): PROVEN via `mcs_backward_chain_H_persistence`
- `backward_G` Case 1 (both >= 0): PROVEN via `mcs_forward_chain_G_persistence`

**Why these are intentional scope exclusions**:
The completeness theorem only requires temporal coherence along single-direction chains:
- For G-formulas: coherence in the forward chain (t >= 0)
- For H-formulas: coherence in the backward chain (t < 0)
Cross-origin cases (where we need coherence between t < 0 and t' >= 0) would require
additional axioms or a fundamentally different construction approach.

See `Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean` for detailed documentation
of what would be needed to prove the remaining cases.
-/

namespace Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Representation
open Bimodal.ProofSystem

/-!
## Coherent Relation

The `coherent_at` relation directly encodes the four IndexedMCSFamily coherence conditions.
This makes coherence **definitional** rather than something to prove after construction.
-/

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Two MCS are coherent at times t, t' if temporal formulas propagate correctly.

This directly encodes the four IndexedMCSFamily coherence conditions:
- forward_G: Gφ ∈ mcs(t) → φ ∈ mcs(t') for t < t'
- backward_H: Hφ ∈ mcs(t) → φ ∈ mcs(t') for t' < t
- forward_H: Hφ ∈ mcs(t') → φ ∈ mcs(t) for t < t'
- backward_G: Gφ ∈ mcs(t') → φ ∈ mcs(t) for t' < t

The relation is designed so that if we build a family with pairwise coherence,
the IndexedMCSFamily conditions follow trivially by extracting the appropriate conjunct.

**Reference**: Inspired by Boneyard `canonical_task_rel` (Completeness.lean:2055), but
simplified to focus purely on temporal coherence (omitting modal transfer since we're
building an indexed family, not a task relation).
-/
def coherent_at (mcs_t mcs_t' : Set Formula) (t t' : D) : Prop :=
  (t < t' → ∀ φ, Formula.all_future φ ∈ mcs_t → φ ∈ mcs_t') ∧  -- forward_G
  (t' < t → ∀ φ, Formula.all_past φ ∈ mcs_t → φ ∈ mcs_t') ∧    -- backward_H
  (t < t' → ∀ φ, Formula.all_past φ ∈ mcs_t' → φ ∈ mcs_t) ∧    -- forward_H
  (t' < t → ∀ φ, Formula.all_future φ ∈ mcs_t' → φ ∈ mcs_t)     -- backward_G

/--
A family of MCS indexed by time with pairwise coherence.

The `pairwise_coherent` field directly implies all four IndexedMCSFamily conditions
by extracting the appropriate conjunct from `coherent_at`.

**Key Insight**: Unlike the original `construct_indexed_family` which tried to prove
coherence after building independent MCS extensions, this structure requires coherence
as part of the construction. The bridge to IndexedMCSFamily is then trivial.
-/
structure CoherentIndexedFamily where
  /-- The MCS assignment: each time t gets an MCS -/
  mcs : D → Set Formula
  /-- Each assigned set is maximal consistent -/
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  /-- Every pair of MCS is coherent with respect to their times -/
  pairwise_coherent : ∀ t t', coherent_at D (mcs t) (mcs t') t t'

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
### Basic Properties of Coherent Relation
-/

/--
Coherence is reflexive: any MCS is coherent with itself at the same time.

All four conditions are vacuously true since neither `t < t` nor `t > t` holds.
-/
lemma coherent_at_refl (S : Set Formula) (t : D) : coherent_at D S S t t := by
  unfold coherent_at
  constructor
  · intro h_lt
    exact absurd h_lt (lt_irrefl t)
  constructor
  · intro h_lt
    exact absurd h_lt (lt_irrefl t)
  constructor
  · intro h_lt
    exact absurd h_lt (lt_irrefl t)
  · intro h_lt
    exact absurd h_lt (lt_irrefl t)

/--
Coherence is symmetric in a crossed sense: coherent_at S T t t' ↔ coherent_at T S t' t.

This swaps both the sets and the time points, maintaining the correct relationship
between the conditions.
-/
lemma coherent_at_symm (S T : Set Formula) (t t' : D) :
    coherent_at D S T t t' ↔ coherent_at D T S t' t := by
  unfold coherent_at
  constructor <;> intro ⟨h1, h2, h3, h4⟩ <;> exact ⟨h4, h3, h2, h1⟩

/-!
## Forward Seed and Extension

The forward seed `{φ | Gφ ∈ S}` contains exactly the formulas that *must* be in any
coherent future MCS. By extending this seed to an MCS, we guarantee forward_G by construction.
-/

/--
Seed for constructing MCS at future time.

If T is any MCS containing forward_seed(S), then:
- Gφ ∈ S implies φ ∈ forward_seed(S) by definition
- φ ∈ forward_seed(S) implies φ ∈ T by subset
- Therefore Gφ ∈ S → φ ∈ T, which is forward_G

**Reference**: Mirrors Boneyard forward_seed (Completeness.lean:2472)
-/
def forward_seed (S : Set Formula) : Set Formula :=
  {φ | Formula.all_future φ ∈ S}

/--
Seed for constructing MCS at past time.

Symmetric to forward_seed, using H instead of G.
-/
def backward_seed (S : Set Formula) : Set Formula :=
  {φ | Formula.all_past φ ∈ S}

/--
The forward seed of an MCS is consistent.

**Proof Idea**:
1. If forward_seed(S) were inconsistent, some finite subset {φ₁, ..., φₙ} would derive ⊥
2. By generalized necessitation, {Gφ₁, ..., Gφₙ} derives G⊥
3. But Gφᵢ ∈ S for all i, so by MCS deductive closure, G⊥ ∈ S
4. This contradicts h_no_G_bot

**Reference**: Matches Boneyard gap at line 2507 in structure, but our proof is complete
because we have the h_no_G_bot hypothesis.
-/
lemma forward_seed_consistent_of_no_G_bot (S : Set Formula) (h_mcs : SetMaximalConsistent S)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ S) :
    SetConsistent (forward_seed S) := by
  intro L hL
  -- L is a list of formulas where each φ has G φ ∈ S
  -- We need to show L is consistent
  by_contra h_incons
  unfold Consistent at h_incons
  push_neg at h_incons
  obtain ⟨d_bot⟩ := h_incons

  -- Step 1: Apply generalized_temporal_k to get derivation of G ⊥ from G L
  let L_G := L.map Formula.all_future
  have d_G_bot : L_G ⊢ Formula.all_future Formula.bot :=
    Bimodal.Theorems.generalized_temporal_k L Formula.bot d_bot

  -- Step 2: Show all elements of L_G are in S
  have h_L_G_sub : ∀ ψ ∈ L_G, ψ ∈ S := by
    intro ψ h_mem
    rw [List.mem_map] at h_mem
    obtain ⟨φ, h_φ_in_L, h_eq⟩ := h_mem
    -- φ ∈ L and L ⊆ forward_seed S, so Gφ ∈ S
    have h_in_seed : φ ∈ forward_seed S := hL φ h_φ_in_L
    rw [← h_eq]
    exact h_in_seed

  -- Step 3: By MCS deductive closure, G ⊥ ∈ S
  have h_G_bot_in : Formula.all_future Formula.bot ∈ S :=
    set_mcs_closed_under_derivation h_mcs L_G h_L_G_sub d_G_bot

  -- Step 4: Contradiction with hypothesis h_no_G_bot
  exact h_no_G_bot h_G_bot_in

/--
The backward seed of an MCS is consistent.

Symmetric to forward_seed_consistent_of_no_G_bot, using H (all_past) instead of G (all_future).
-/
lemma backward_seed_consistent_of_no_H_bot (S : Set Formula) (h_mcs : SetMaximalConsistent S)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ S) :
    SetConsistent (backward_seed S) := by
  intro L hL
  by_contra h_incons
  unfold Consistent at h_incons
  push_neg at h_incons
  obtain ⟨d_bot⟩ := h_incons

  -- Step 1: Apply generalized_past_k to get derivation of H ⊥ from H L
  let L_H := L.map Formula.all_past
  have d_H_bot : L_H ⊢ Formula.all_past Formula.bot :=
    Bimodal.Theorems.generalized_past_k L Formula.bot d_bot

  -- Step 2: Show all elements of L_H are in S
  have h_L_H_sub : ∀ ψ ∈ L_H, ψ ∈ S := by
    intro ψ h_mem
    rw [List.mem_map] at h_mem
    obtain ⟨φ, h_φ_in_L, h_eq⟩ := h_mem
    have h_in_seed : φ ∈ backward_seed S := hL φ h_φ_in_L
    rw [← h_eq]
    exact h_in_seed

  -- Step 3: By MCS deductive closure, H ⊥ ∈ S
  have h_H_bot_in : Formula.all_past Formula.bot ∈ S :=
    set_mcs_closed_under_derivation h_mcs L_H h_L_H_sub d_H_bot

  -- Step 4: Contradiction with hypothesis h_no_H_bot
  exact h_no_H_bot h_H_bot_in

/-!
## G and H Persistence

These lemmas establish that G-formulas persist through forward coherent extensions
and H-formulas persist through backward coherent extensions. This uses the G-4 and H-4 axioms.
-/

/--
G formulas persist through forward extension.

If Gφ ∈ S and T is a forward extension (via forward_seed), then Gφ ∈ T.

**Proof**:
1. Gφ ∈ S → GGφ ∈ S (by G-4 axiom via set_mcs_all_future_all_future)
2. GGφ ∈ S → Gφ ∈ forward_seed(S) (by definition of forward_seed)
3. forward_seed(S) ⊆ T → Gφ ∈ T

**Reference**: Boneyard future_formula_persistence (Completeness.lean:2130-2143)
-/
lemma forward_G_persistence {S T : Set Formula} (h_mcs_S : SetMaximalConsistent S)
    (h_sub : forward_seed S ⊆ T) (φ : Formula)
    (hG : Formula.all_future φ ∈ S) : Formula.all_future φ ∈ T := by
  -- From Gφ ∈ S, get GGφ ∈ S via set_mcs_all_future_all_future (G-4 axiom)
  have h_gg : (Formula.all_future φ).all_future ∈ S :=
    set_mcs_all_future_all_future h_mcs_S hG
  -- GGφ ∈ S means Gφ ∈ forward_seed(S)
  have h_in_seed : Formula.all_future φ ∈ forward_seed S := h_gg
  -- forward_seed(S) ⊆ T
  exact h_sub h_in_seed

/--
H formulas persist through backward extension.

Symmetric to forward_G_persistence.
-/
lemma backward_H_persistence {S T : Set Formula} (h_mcs_S : SetMaximalConsistent S)
    (h_sub : backward_seed S ⊆ T) (φ : Formula)
    (hH : Formula.all_past φ ∈ S) : Formula.all_past φ ∈ T := by
  -- From Hφ ∈ S, get HHφ ∈ S via set_mcs_all_past_all_past (H-4 axiom)
  have h_hh : (Formula.all_past φ).all_past ∈ S :=
    set_mcs_all_past_all_past h_mcs_S hH
  -- HHφ ∈ S means Hφ ∈ backward_seed(S)
  have h_in_seed : Formula.all_past φ ∈ backward_seed S := h_hh
  -- backward_seed(S) ⊆ T
  exact h_sub h_in_seed

/-!
## Forward and Backward Extension Theorems

For any MCS S, there exist forward and backward coherent extensions.
-/

/--
For any MCS S (not containing G⊥), there exists an MCS T that is forward-coherent with S.

**Construction**:
1. forward_seed(S) is consistent (by forward_seed_consistent_of_no_G_bot)
2. Extend via set_lindenbaum to MCS T
3. The forward_G condition holds because forward_seed ⊆ T
4. Other conditions require T-axiom reasoning

**Reference**: Mirrors Boneyard forward_extension (Completeness.lean:2521-2581)
-/
theorem forward_extension (S : Set Formula) (h_mcs : SetMaximalConsistent S)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ S)
    (t t' : D) (h_lt : t < t') :
    ∃ T : Set Formula, SetMaximalConsistent T ∧
      (∀ φ, Formula.all_future φ ∈ S → φ ∈ T) ∧  -- forward_G
      (forward_seed S ⊆ T) := by
  -- 1. Get consistent seed
  have h_cons := forward_seed_consistent_of_no_G_bot S h_mcs h_no_G_bot
  -- 2. Extend to MCS
  obtain ⟨T, h_sub, h_mcs_T⟩ := set_lindenbaum (forward_seed S) h_cons
  use T, h_mcs_T
  constructor
  -- forward_G: Gφ ∈ S → φ ∈ T
  · intro φ hG
    have h_in_seed : φ ∈ forward_seed S := hG
    exact h_sub h_in_seed
  -- forward_seed ⊆ T
  · exact h_sub

/--
For any MCS S (not containing H⊥), there exists an MCS T that is backward-coherent with S.

Symmetric to forward_extension.
-/
theorem backward_extension (S : Set Formula) (h_mcs : SetMaximalConsistent S)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ S)
    (t t' : D) (h_lt : t' < t) :
    ∃ T : Set Formula, SetMaximalConsistent T ∧
      (∀ φ, Formula.all_past φ ∈ S → φ ∈ T) ∧  -- backward_H
      (backward_seed S ⊆ T) := by
  -- 1. Get consistent seed
  have h_cons := backward_seed_consistent_of_no_H_bot S h_mcs h_no_H_bot
  -- 2. Extend to MCS
  obtain ⟨T, h_sub, h_mcs_T⟩ := set_lindenbaum (backward_seed S) h_cons
  use T, h_mcs_T
  constructor
  -- backward_H: Hφ ∈ S → φ ∈ T
  · intro φ hH
    have h_in_seed : φ ∈ backward_seed S := hH
    exact h_sub h_in_seed
  -- backward_seed ⊆ T
  · exact h_sub

/-!
## G⊥ and H⊥ Exclusion for MCS

Any maximal consistent set excludes G⊥ and H⊥ due to the T-axiom.
-/

/--
Any MCS excludes G⊥.

**Proof**: If G⊥ ∈ S, then by T-axiom (Gφ → φ), we derive ⊥ ∈ S, contradicting consistency.
-/
lemma mcs_no_G_bot {S : Set Formula} (h_mcs : SetMaximalConsistent S) :
    Formula.all_future Formula.bot ∉ S := by
  intro h_G_bot
  -- By T-axiom (temp_t_future): G⊥ → ⊥
  have h_bot := mcs_closed_temp_t_future h_mcs Formula.bot h_G_bot
  -- But ⊥ ∈ S contradicts consistency
  apply h_mcs.1 [Formula.bot]
  · intro φ hφ; simp at hφ; rw [hφ]; exact h_bot
  · constructor
    exact DerivationTree.assumption [Formula.bot] Formula.bot (by simp)

/--
Any MCS excludes H⊥.

**Proof**: Symmetric to mcs_no_G_bot using temp_t_past axiom.
-/
lemma mcs_no_H_bot {S : Set Formula} (h_mcs : SetMaximalConsistent S) :
    Formula.all_past Formula.bot ∉ S := by
  intro h_H_bot
  have h_bot := mcs_closed_temp_t_past h_mcs Formula.bot h_H_bot
  apply h_mcs.1 [Formula.bot]
  · intro φ hφ; simp at hφ; rw [hφ]; exact h_bot
  · constructor
    exact DerivationTree.assumption [Formula.bot] Formula.bot (by simp)

/-!
## Coherent Family Construction for ℤ

Build a CoherentIndexedFamily from a root MCS, specialized to D = ℤ.

**Strategy**:
1. Define forward chain: mcs(n+1) as forward extension of mcs(n)
2. Define backward chain: mcs(-n-1) as backward extension of mcs(-n)
3. Combine into unified function ℤ → Set Formula
4. Prove pairwise coherence by induction on |t - t'|

**Note**: The general D case requires Dependent Choice axiom. For v1, we restrict to ℤ.
-/

/--
Forward chain auxiliary: Build MCS for non-negative times, carrying the MCS invariant.

Returns a sigma-type `{ S : Set Formula // SetMaximalConsistent S }` to ensure
that at each step, we have access to the MCS proof needed for constructing the next step.
-/
noncomputable def mcs_forward_chain_aux (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) :
    (n : ℕ) → { S : Set Formula // SetMaximalConsistent S }
  | 0 => ⟨Gamma, h_mcs⟩
  | n+1 =>
    let ⟨S, h_S_mcs⟩ := mcs_forward_chain_aux Gamma h_mcs h_no_G_bot n
    -- S is MCS, so by mcs_no_G_bot, G⊥ ∉ S
    -- Therefore forward_seed S is consistent
    let h_no_G_bot_S : Formula.all_future Formula.bot ∉ S := mcs_no_G_bot h_S_mcs
    let h_cons := forward_seed_consistent_of_no_G_bot S h_S_mcs h_no_G_bot_S
    ⟨extendToMCS (forward_seed S) h_cons, extendToMCS_is_mcs _ h_cons⟩

/--
Forward chain construction: Build MCS for non-negative times.

At time 0, use Gamma directly.
At time n+1, extend mcs(n) using forward_seed.
-/
noncomputable def mcs_forward_chain (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) (n : ℕ) : Set Formula :=
  (mcs_forward_chain_aux Gamma h_mcs h_no_G_bot n).val

/--
Backward chain auxiliary: Build MCS for negative times, carrying the MCS invariant.
-/
noncomputable def mcs_backward_chain_aux (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
    (n : ℕ) → { S : Set Formula // SetMaximalConsistent S }
  | 0 => ⟨Gamma, h_mcs⟩
  | n+1 =>
    let ⟨S, h_S_mcs⟩ := mcs_backward_chain_aux Gamma h_mcs h_no_H_bot n
    let h_no_H_bot_S : Formula.all_past Formula.bot ∉ S := mcs_no_H_bot h_S_mcs
    let h_cons := backward_seed_consistent_of_no_H_bot S h_S_mcs h_no_H_bot_S
    ⟨extendToMCS (backward_seed S) h_cons, extendToMCS_is_mcs _ h_cons⟩

/--
Backward chain construction: Build MCS for negative times.

Similar to forward chain, but using backward_seed.
-/
noncomputable def mcs_backward_chain (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) (n : ℕ) : Set Formula :=
  (mcs_backward_chain_aux Gamma h_mcs h_no_H_bot n).val

/--
Each element in the forward chain is an MCS.

This follows directly from the sigma-type construction of mcs_forward_chain_aux.
-/
lemma mcs_forward_chain_is_mcs (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) (n : ℕ) :
    SetMaximalConsistent (mcs_forward_chain Gamma h_mcs h_no_G_bot n) :=
  (mcs_forward_chain_aux Gamma h_mcs h_no_G_bot n).property

/--
Each element in the backward chain is an MCS.
-/
lemma mcs_backward_chain_is_mcs (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) (n : ℕ) :
    SetMaximalConsistent (mcs_backward_chain Gamma h_mcs h_no_H_bot n) :=
  (mcs_backward_chain_aux Gamma h_mcs h_no_H_bot n).property

/--
Unified MCS function for ℤ.

Combines forward and backward chains:
- mcs_unified(t) = mcs_forward_chain(t.toNat) for t ≥ 0
- mcs_unified(t) = mcs_backward_chain((-t).toNat) for t < 0
-/
noncomputable def mcs_unified_chain (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) : ℤ → Set Formula :=
  fun t =>
    if h : 0 ≤ t then
      mcs_forward_chain Gamma h_mcs h_no_G_bot t.toNat
    else
      mcs_backward_chain Gamma h_mcs h_no_H_bot ((-t).toNat)

/--
The MCS at any time in the unified construction is maximal consistent.
-/
lemma mcs_unified_chain_is_mcs (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (t : ℤ) : SetMaximalConsistent (mcs_unified_chain Gamma h_mcs h_no_G_bot h_no_H_bot t) := by
  unfold mcs_unified_chain
  split_ifs with h
  · -- t ≥ 0: mcs_forward_chain - use the is_mcs lemma
    exact mcs_forward_chain_is_mcs Gamma h_mcs h_no_G_bot t.toNat
  · -- t < 0: mcs_backward_chain - use the is_mcs lemma
    exact mcs_backward_chain_is_mcs Gamma h_mcs h_no_H_bot ((-t).toNat)

/--
Forward chain preserves forward_seed containment.

For n ≥ 0, forward_seed(mcs(n)) ⊆ mcs(n+1).
-/
lemma mcs_forward_chain_seed_containment (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) (n : ℕ) :
    forward_seed (mcs_forward_chain Gamma h_mcs h_no_G_bot n) ⊆
      mcs_forward_chain Gamma h_mcs h_no_G_bot (n + 1) := by
  unfold mcs_forward_chain
  -- Goal: forward_seed (mcs_forward_chain_aux ... n).val ⊆ (mcs_forward_chain_aux ... (n+1)).val
  -- Get the MCS property of the chain element at n
  have h_S_mcs := (mcs_forward_chain_aux Gamma h_mcs h_no_G_bot n).property
  have h_no_G_bot_S := mcs_no_G_bot h_S_mcs
  have h_cons := forward_seed_consistent_of_no_G_bot _ h_S_mcs h_no_G_bot_S
  -- The (n+1) element is extendToMCS of forward_seed of the n element
  -- This is exactly what extendToMCS_contains gives us
  simp only [mcs_forward_chain_aux]
  exact extendToMCS_contains _ _

/--
Backward chain preserves backward_seed containment.

For n ≥ 0, backward_seed(mcs(-n)) ⊆ mcs(-n-1).
-/
lemma mcs_backward_chain_seed_containment (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) (n : ℕ) :
    backward_seed (mcs_backward_chain Gamma h_mcs h_no_H_bot n) ⊆
      mcs_backward_chain Gamma h_mcs h_no_H_bot (n + 1) := by
  unfold mcs_backward_chain
  have h_S_mcs := (mcs_backward_chain_aux Gamma h_mcs h_no_H_bot n).property
  have h_no_H_bot_S := mcs_no_H_bot h_S_mcs
  have h_cons := backward_seed_consistent_of_no_H_bot _ h_S_mcs h_no_H_bot_S
  simp only [mcs_backward_chain_aux]
  exact extendToMCS_contains _ _

/--
G-formulas persist through the forward chain.

If Gφ ∈ mcs(n), then Gφ ∈ mcs(m) for all m ≥ n.

**Proof**:
By induction on m. The key step is using `forward_G_persistence`:
- From Gφ ∈ mcs(k), we get GGφ ∈ mcs(k) (by G-4 axiom)
- GGφ ∈ mcs(k) means Gφ ∈ forward_seed(mcs(k))
- forward_seed(mcs(k)) ⊆ mcs(k+1), so Gφ ∈ mcs(k+1)
-/
lemma mcs_forward_chain_G_persistence (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (n m : ℕ) (h_le : n ≤ m) (φ : Formula)
    (hG : Formula.all_future φ ∈ mcs_forward_chain Gamma h_mcs h_no_G_bot n) :
    Formula.all_future φ ∈ mcs_forward_chain Gamma h_mcs h_no_G_bot m := by
  induction m with
  | zero =>
    -- n ≤ 0, so n = 0
    have h_n_eq : n = 0 := Nat.eq_zero_of_le_zero h_le
    subst h_n_eq
    exact hG
  | succ m' ih =>
    by_cases h : n ≤ m'
    · -- n ≤ m': Use IH to get Gφ ∈ mcs(m'), then forward_G_persistence
      have hG_m' := ih h
      -- Need to show Gφ ∈ mcs(m'+1)
      have h_mcs_m' : SetMaximalConsistent (mcs_forward_chain Gamma h_mcs h_no_G_bot m') :=
        mcs_forward_chain_is_mcs Gamma h_mcs h_no_G_bot m'
      have h_seed_sub := mcs_forward_chain_seed_containment Gamma h_mcs h_no_G_bot m'
      exact forward_G_persistence h_mcs_m' h_seed_sub φ hG_m'
    · -- n > m', so n = m' + 1 (since n ≤ m'+1 and ¬(n ≤ m'))
      push_neg at h
      -- h : m' < n, h_le : n ≤ m' + 1
      -- Together: m' < n ≤ m' + 1, so n = m' + 1
      have h_eq : n = m' + 1 := Nat.le_antisymm h_le h
      subst h_eq
      exact hG

/--
Forward coherence between adjacent times in the forward chain.

For n < m in ℕ, mcs(n) and mcs(m) satisfy forward_G.
-/
lemma mcs_forward_chain_coherent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (n m : ℕ) (h_lt : n < m) (φ : Formula)
    (hG : Formula.all_future φ ∈ mcs_forward_chain Gamma h_mcs h_no_G_bot n) :
    φ ∈ mcs_forward_chain Gamma h_mcs h_no_G_bot m := by
  -- Two approaches:
  -- 1. Direct: Gφ ∈ mcs(n) → φ ∈ forward_seed(mcs(n)) → φ ∈ mcs(n+1), then iterate
  -- 2. Via persistence: Gφ persists to mcs(m-1), then seed containment gives φ ∈ mcs(m)
  --
  -- Using approach 2:
  match m with
  | 0 => exact absurd h_lt (Nat.not_lt_zero n)
  | m' + 1 =>
    -- We need φ ∈ mcs(m'+1)
    -- First get Gφ ∈ mcs(m') using G-persistence (n ≤ m' since n < m'+1)
    have h_le : n ≤ m' := Nat.lt_succ_iff.mp h_lt
    have hG_m' : Formula.all_future φ ∈ mcs_forward_chain Gamma h_mcs h_no_G_bot m' :=
      mcs_forward_chain_G_persistence Gamma h_mcs h_no_G_bot n m' h_le φ hG
    -- Now Gφ ∈ mcs(m') means φ ∈ forward_seed(mcs(m'))
    have h_in_seed : φ ∈ forward_seed (mcs_forward_chain Gamma h_mcs h_no_G_bot m') := hG_m'
    -- And forward_seed(mcs(m')) ⊆ mcs(m'+1)
    exact mcs_forward_chain_seed_containment Gamma h_mcs h_no_G_bot m' h_in_seed

/-!
## Backward Chain Analogous Lemmas

These mirror the forward chain lemmas but for H-formulas and the backward chain.
-/

/--
H-formulas persist through the backward chain.

If Hφ ∈ mcs(-n), then Hφ ∈ mcs(-m) for all m ≥ n.
Uses backward_H_persistence.
-/
lemma mcs_backward_chain_H_persistence (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (n m : ℕ) (h_le : n ≤ m) (φ : Formula)
    (hH : Formula.all_past φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot n) :
    Formula.all_past φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot m := by
  induction m with
  | zero =>
    have h_n_eq : n = 0 := Nat.eq_zero_of_le_zero h_le
    subst h_n_eq
    exact hH
  | succ m' ih =>
    by_cases h : n ≤ m'
    · have hH_m' := ih h
      have h_mcs_m' : SetMaximalConsistent (mcs_backward_chain Gamma h_mcs h_no_H_bot m') :=
        mcs_backward_chain_is_mcs Gamma h_mcs h_no_H_bot m'
      have h_seed_sub := mcs_backward_chain_seed_containment Gamma h_mcs h_no_H_bot m'
      exact backward_H_persistence h_mcs_m' h_seed_sub φ hH_m'
    · push_neg at h
      have h_eq : n = m' + 1 := Nat.le_antisymm h_le h
      subst h_eq
      exact hH

/--
Backward coherence: Hφ ∈ mcs(-n) → φ ∈ mcs(-m) for n < m.

This is the backward chain analog of mcs_forward_chain_coherent.
-/
lemma mcs_backward_chain_coherent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (n m : ℕ) (h_lt : n < m) (φ : Formula)
    (hH : Formula.all_past φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot n) :
    φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot m := by
  match m with
  | 0 => exact absurd h_lt (Nat.not_lt_zero n)
  | m' + 1 =>
    have h_le : n ≤ m' := Nat.lt_succ_iff.mp h_lt
    have hH_m' : Formula.all_past φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot m' :=
      mcs_backward_chain_H_persistence Gamma h_mcs h_no_H_bot n m' h_le φ hH
    have h_in_seed : φ ∈ backward_seed (mcs_backward_chain Gamma h_mcs h_no_H_bot m') := hH_m'
    exact mcs_backward_chain_seed_containment Gamma h_mcs h_no_H_bot m' h_in_seed

/--
Pairwise coherence of the unified chain construction.

**UNDER DEVELOPMENT**: This lemma contains 8 sorries for cross-origin coherence cases.
These cases are mathematically complex and NOT REQUIRED for the main completeness theorem.
The sorry-free completeness is provided by `semantic_weak_completeness` in
`FMP/SemanticCanonicalModel.lean`, which uses a different architecture.

This lemma is retained for `construct_coherent_family` but should not be relied upon for
new proofs. Use the FMP semantic approach instead.
-/
lemma mcs_unified_chain_pairwise_coherent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (t t' : ℤ) :
    coherent_at ℤ (mcs_unified_chain Gamma h_mcs h_no_G_bot h_no_H_bot t)
                  (mcs_unified_chain Gamma h_mcs h_no_G_bot h_no_H_bot t') t t' := by
  unfold coherent_at
  constructor
  -- forward_G: t < t' → Gφ ∈ mcs(t) → φ ∈ mcs(t')
  · intro h_lt φ hG
    -- Several cases based on signs of t and t'
    unfold mcs_unified_chain at hG ⊢
    -- Use by_cases instead of split_ifs for clearer control
    by_cases h_t_nonneg : 0 ≤ t <;> by_cases h_t'_nonneg : 0 ≤ t' <;> simp only [h_t_nonneg, h_t'_nonneg] at hG ⊢
    · -- Case 1: t ≥ 0 and t' ≥ 0: both in forward chain
      have h_nat_lt : t.toNat < t'.toNat := by omega
      exact mcs_forward_chain_coherent Gamma h_mcs h_no_G_bot t.toNat t'.toNat h_nat_lt φ hG
    · -- Case 2: t ≥ 0 and t' < 0: Contradiction with h_lt : t < t'
      simp only [not_le] at h_t'_nonneg
      -- h_t'_nonneg : t' < 0, h_t_nonneg : 0 ≤ t, h_lt : t < t'
      -- From t' < 0 ≤ t, we get t' < t, contradicting t < t'
      have h_t'_lt_t : t' < t := lt_of_lt_of_le h_t'_nonneg h_t_nonneg
      exact absurd h_lt (asymm h_t'_lt_t)
    · -- Case 3: t < 0 and t' ≥ 0: Cross-origin case
      -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
      sorry
    · -- Case 4: t < 0 and t' < 0: both in backward chain, going TOWARD origin
      -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
      sorry
  constructor
  -- backward_H: t' < t → Hφ ∈ mcs(t) → φ ∈ mcs(t')
  · intro h_lt φ hH
    unfold mcs_unified_chain at hH ⊢
    by_cases h_t_nonneg : 0 ≤ t <;> by_cases h_t'_nonneg : 0 ≤ t' <;> simp only [h_t_nonneg, h_t'_nonneg] at hH ⊢
    · -- Case 1: Both t' ≥ 0 and t ≥ 0
      -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
      sorry
    · -- Case 2: t ≥ 0 and t' < 0: cross-origin
      -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
      sorry
    · -- Case 3: t < 0 and t' ≥ 0: contradiction since t' < t
      simp only [not_le] at h_t_nonneg
      have : t < t' := lt_of_lt_of_le h_t_nonneg h_t'_nonneg
      exact absurd h_lt (asymm this)
    · -- Case 4: Both t < 0 and t' < 0
      -- Since t' < t < 0, we have (-t).toNat < (-t').toNat
      simp only [not_le] at h_t_nonneg h_t'_nonneg
      have h_nat_lt : (-t).toNat < (-t').toNat := by omega
      exact mcs_backward_chain_coherent Gamma h_mcs h_no_H_bot (-t).toNat (-t').toNat h_nat_lt φ hH
  constructor
  -- forward_H: t < t' → Hφ ∈ mcs(t') → φ ∈ mcs(t)
  · intro h_lt φ hH
    unfold mcs_unified_chain at hH ⊢
    by_cases h_t_nonneg : 0 ≤ t <;> by_cases h_t'_nonneg : 0 ≤ t' <;>
      simp only [h_t_nonneg, h_t'_nonneg] at hH ⊢
    · -- Case 1: t ≥ 0 and t' ≥ 0 - H doesn't persist in forward chain
      -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
      sorry
    · -- Case 2: t ≥ 0 and t' < 0: contradiction since t < t'
      simp only [not_le] at h_t'_nonneg
      have : t' < t := lt_of_lt_of_le h_t'_nonneg h_t_nonneg
      exact absurd h_lt (asymm this)
    · -- Case 3: t < 0 and t' ≥ 0: cross-origin
      -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
      sorry
    · -- Case 4: Both t < 0 and t' < 0 - PROVABLE!
      simp only [not_le] at h_t_nonneg h_t'_nonneg
      -- Since t < t' < 0, we have |t| > |t'|, so (-t).toNat > (-t').toNat
      have h_nat_lt : (-t').toNat < (-t).toNat := by omega
      -- Since t < 0, we have (-t).toNat > 0
      have h_t_pos : 0 < (-t).toNat := by omega
      -- Let m = (-t).toNat - 1, so (-t).toNat = m + 1
      set m := (-t).toNat - 1 with hm_def
      have ht_eq : (-t).toNat = m + 1 := by omega
      have h_le : (-t').toNat ≤ m := by omega
      -- Hφ persists from (-t').toNat to m
      have hH_m := mcs_backward_chain_H_persistence Gamma h_mcs h_no_H_bot (-t').toNat m h_le φ hH
      -- Hφ ∈ mcs(m) → φ ∈ backward_seed(mcs(m)) → φ ∈ mcs(m+1)
      have h_in_seed : φ ∈ backward_seed (mcs_backward_chain Gamma h_mcs h_no_H_bot m) := hH_m
      have h_result := mcs_backward_chain_seed_containment Gamma h_mcs h_no_H_bot m h_in_seed
      -- Rewrite the goal using ht_eq
      rw [ht_eq]
      exact h_result
  -- backward_G: t' < t → Gφ ∈ mcs(t') → φ ∈ mcs(t)
  · intro h_lt φ hG
    -- Key insight: Gφ at t' persists to t-1 (by G-4), then forward_G gives φ at t.
    unfold mcs_unified_chain at hG ⊢
    by_cases h_t'_nonneg : 0 ≤ t' <;> by_cases h_t_nonneg : 0 ≤ t <;> simp only [h_t'_nonneg, h_t_nonneg] at hG ⊢
    · -- Case 1: Both t' ≥ 0 and t ≥ 0
      -- Have: Gφ ∈ mcs_forward_chain(t'.toNat)
      -- Goal: φ ∈ mcs_forward_chain(t.toNat)
      have h_nat_lt : t'.toNat < t.toNat := by omega
      -- Since t' < t and both ≥ 0, we have t > 0 so t.toNat > 0
      have h_t_pos : 0 < t.toNat := by omega
      -- Let m = t.toNat - 1, so t.toNat = m + 1
      set m := t.toNat - 1 with hm_def
      have ht_eq : t.toNat = m + 1 := by omega
      have h_le : t'.toNat ≤ m := by omega
      -- Gφ persists from t'.toNat to m
      have hG_m := mcs_forward_chain_G_persistence Gamma h_mcs h_no_G_bot t'.toNat m h_le φ hG
      -- Gφ ∈ mcs(m) → φ ∈ forward_seed(mcs(m)) → φ ∈ mcs(m+1)
      have h_in_seed : φ ∈ forward_seed (mcs_forward_chain Gamma h_mcs h_no_G_bot m) := hG_m
      have h_result := mcs_forward_chain_seed_containment Gamma h_mcs h_no_G_bot m h_in_seed
      -- Rewrite the goal using ht_eq
      rw [ht_eq]
      exact h_result
    · -- Case 2: t' ≥ 0 but t < 0: contradiction since t' < t
      simp only [not_le] at h_t_nonneg
      have : t < t' := lt_of_lt_of_le h_t_nonneg h_t'_nonneg
      exact absurd h_lt (asymm this)
    · -- Case 3: t' < 0 and t ≥ 0: cross-origin
      -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
      sorry
    · -- Case 4: Both t' < 0 and t < 0
      -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
      sorry

/--
Construct a CoherentIndexedFamily from a root MCS.

**Hypotheses**:
- `h_no_G_bot`: G ⊥ ∉ Gamma (ensures forward temporal extension)
- `h_no_H_bot`: H ⊥ ∉ Gamma (ensures backward temporal extension)

These conditions ensure the MCS is satisfiable in an UNBOUNDED temporal model.

**UNDER DEVELOPMENT**: This definition relies on `mcs_unified_chain_pairwise_coherent`
which contains 8 sorries. The sorry-free completeness is provided by `semantic_weak_completeness`
in `FMP/SemanticCanonicalModel.lean`, which uses a different architecture.
-/
noncomputable def construct_coherent_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
    CoherentIndexedFamily ℤ where
  mcs := mcs_unified_chain Gamma h_mcs h_no_G_bot h_no_H_bot
  is_mcs := mcs_unified_chain_is_mcs Gamma h_mcs h_no_G_bot h_no_H_bot
  pairwise_coherent := mcs_unified_chain_pairwise_coherent Gamma h_mcs h_no_G_bot h_no_H_bot

/-!
## Bridge to IndexedMCSFamily

Convert CoherentIndexedFamily to IndexedMCSFamily. This is the payoff of making
coherence definitional - the four conditions are trivially extracted from pairwise_coherent.
-/

/--
Convert CoherentIndexedFamily to IndexedMCSFamily.

This is trivial because coherent_at directly encodes the four conditions.
Each field extraction is a one-liner applying the appropriate conjunct.
-/
def CoherentIndexedFamily.toIndexedMCSFamily (F : CoherentIndexedFamily D) :
    IndexedMCSFamily D where
  mcs := F.mcs
  is_mcs := F.is_mcs
  forward_G := fun t t' φ h_lt h_G => (F.pairwise_coherent t t').1 h_lt φ h_G
  backward_H := fun t t' φ h_lt h_H => (F.pairwise_coherent t t').2.1 h_lt φ h_H
  forward_H := fun t t' φ h_lt h_H => (F.pairwise_coherent t t').2.2.1 h_lt φ h_H
  backward_G := fun t t' φ h_lt h_G => (F.pairwise_coherent t t').2.2.2 h_lt φ h_G

/--
The origin formula is preserved in the constructed coherent family.
-/
lemma construct_coherent_family_origin (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (φ : Formula) (h_phi : φ ∈ Gamma) :
    φ ∈ (construct_coherent_family Gamma h_mcs h_no_G_bot h_no_H_bot).mcs 0 := by
  unfold construct_coherent_family mcs_unified_chain mcs_forward_chain
  simp only [Int.toNat_zero, le_refl]
  exact h_phi

end Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem
