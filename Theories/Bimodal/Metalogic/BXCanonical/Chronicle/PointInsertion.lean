import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Theorems.TemporalDerived

/-!
# Point Insertion Lemmas (Burgess 2.4-2.8)

Implements the core point insertion machinery for the Burgess chronicle
construction, adapted for strict (irreflexive) temporal semantics on the
`irr_until` branch.

## Key Adaptations from Burgess 1982

Burgess uses axioms A3a and A4a which are **not valid** under strict semantics
(see counterexample in `TemporalDerived.lean`). We replace them with BX axioms:

- **A3a's role** (Lemma 2.4 seed consistency): BX4 (`connect_future: φ → G(P(φ))`)
  + BX5 (`self_accum_until`) provide the algebraic content directly.
- **A4a's role** (Lemma 2.6 point insertion): BX5 + BX6 (`absorb_until`)
  + BX7 (`linear_until`) provide the needed structural properties.

## Strict Semantics Considerations

Under strict Until semantics with half-open guard [t,s):
- U(γ,β) at t means ∃s>t, β(s) ∧ ∀u∈[t,s), γ(u)
- The guard γ covers the current point t but NOT the witness point s
- BX9 (until_elim) gives γ ∨ β at t (guard covers current point)
- The witness point only has β, not necessarily γ

This means Burgess's Lemma 2.4 must be adapted: we produce an endpoint MCS
with β and g_content(A), plus evidence that U(γ,β) was active in the past
(via BX4: connect_future). The guard γ is handled by the interval DCS
construction in Phase 4.

## Definitions (local, pending Phase 2)

Phase 2 defines `ChronicleTypes.lean` and `RRelation.lean` in parallel. We define
local versions of needed concepts here. These will be unified with Phase 2 when
both phases are complete.

## Main Results

- `lemma_2_4`: Until witness endpoint construction
- `lemma_2_5b`: Composition of g_content ordering (transitivity)
- `lemma_2_6`: Counterexample insertion (delta not in C -> insert D with neg delta)
- `lemma_2_7_guard`: Guard extraction at current point from Until
- `lemma_2_7`: Until witness insertion (fully sorry'd, requires complex BX7 argument)
- `lemma_2_8`: Variant of 2.7 with neg-disjunction condition at C

## References

- Burgess 1982: "Basic tense logic", Section 2, Lemmas 2.4-2.8
- Task 107 implementation plan, Phase 3
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.TemporalDerived

/-! ## Helper: F(neg phi) from G(phi) not in A

A common pattern: if G(φ) ∉ MCS A, then F(¬φ) ∈ A.
This requires going through double-negation elimination under G,
since F(¬φ) = ¬G(¬¬φ) which is not definitionally equal to ¬G(φ).
-/

/-- If G(φ) ∉ MCS A, then F(¬φ) ∈ A.

Proof: G(φ) ∉ A. Suppose G(¬¬φ) ∈ A. By temporal necessitation of DNE
and temp_k_dist, G(¬¬φ) → G(φ). So G(φ) ∈ A, contradiction.
Therefore G(¬¬φ) ∉ A, i.e., ¬G(¬¬φ) ∈ A = F(¬φ) ∈ A. -/
theorem F_neg_of_G_not {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ : Formula)
    (h_Gφ_not : Formula.all_future φ ∉ A) :
    Formula.some_future φ.neg ∈ A := by
  -- Show G(¬¬φ) ∉ A
  have h_G_nnφ_not : Formula.all_future φ.neg.neg ∉ A := by
    intro h_G_nnφ
    -- DNE: ¬¬φ → φ
    have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    -- G(¬¬φ → φ) by temporal necessitation
    have h_G_dne : DerivationTree [] (Formula.all_future (φ.neg.neg.imp φ)) :=
      DerivationTree.temporal_necessitation _ h_dne
    -- G(¬¬φ → φ) → (G(¬¬φ) → G(φ)) by temp_k_dist
    have h_kd : DerivationTree [] ((φ.neg.neg.imp φ).all_future.imp
        (φ.neg.neg.all_future.imp φ.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist φ.neg.neg φ)
    have h1 := theorem_in_mcs h_mcs h_G_dne
    have h2 := theorem_in_mcs h_mcs h_kd
    have h3 := SetMaximalConsistent.implication_property h_mcs h2 h1
    have h_Gφ := SetMaximalConsistent.implication_property h_mcs h3 h_G_nnφ
    exact h_Gφ_not h_Gφ
  -- ¬G(¬¬φ) ∈ A by negation completeness
  rcases SetMaximalConsistent.negation_complete h_mcs
      (Formula.all_future φ.neg.neg) with h | h
  · exact absurd h h_G_nnφ_not
  · exact h

/-! ## Lemma 2.4: Until Witness Endpoint Construction

Given MCS A with U(γ, β) ∈ A, construct an MCS C (the "endpoint") with:
- β ∈ C (the Until witness holds)
- g_content(A) ⊆ C (temporal coherence)
- P(U(γ,β)) ∈ C (the Until was active in the past, via BX4)

Under strict semantics, we cannot guarantee γ ∈ C (the guard covers [t,s)
not {s}). The guard γ is handled by the interval DCS in the full chronicle
construction (Phase 4).
-/

/-- The Until witness seed: {β} ∪ g_content(A) is consistent when
U(γ,β) ∈ MCS A. Uses BX10 (until_F) to get F(β) ∈ A, then
forward_temporal_witness_seed_consistent. -/
theorem until_witness_seed_consistent {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    SetConsistent ({β} ∪ g_content A) := by
  -- BX10: U(γ,β) → F(β)
  have h_F_β : Formula.some_future β ∈ A := by
    have h_ax : DerivationTree [] ((Formula.untl γ β).imp (Formula.some_future β)) :=
      DerivationTree.axiom [] _ (Axiom.until_F γ β)
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_ax) h_until
  exact forward_temporal_witness_seed_consistent A h_mcs β h_F_β

/--
**Lemma 2.4** (adapted for strict semantics): Given MCS A with U(γ, β) ∈ A,
there exists MCS C with β ∈ C, g_content(A) ⊆ C, and P(U(γ,β)) ∈ C.

The P(U(γ,β)) ∈ C condition records that the Until formula was active in
the past of C, which is the key information needed by the chronicle
construction for the interval set.

Uses:
- BX10 (until_F): U(γ,β) → F(β), giving F(β) ∈ A
- BX4 (connect_future): U(γ,β) → G(P(U(γ,β))), giving P(U(γ,β)) ∈ g_content(A)
- forward_temporal_witness_seed_consistent for seed consistency
- Lindenbaum extension
-/
noncomputable def lemma_2_4 {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    ∃ C : Set Formula, SetMaximalConsistent C ∧
      β ∈ C ∧ g_content A ⊆ C ∧
      Formula.some_past (Formula.untl γ β) ∈ C := by
  -- Step 1: Seed consistency
  have h_seed_cons := until_witness_seed_consistent h_mcs γ β h_until
  -- Step 2: Lindenbaum extension
  obtain ⟨C, h_sup, h_C_mcs⟩ := set_lindenbaum _ h_seed_cons
  -- Step 3: Extract membership facts
  have h_β_C : β ∈ C := h_sup (Set.mem_union_left _ (Set.mem_singleton β))
  have h_g_sub : g_content A ⊆ C := fun χ hχ => h_sup (Set.mem_union_right _ hχ)
  -- Step 4: P(U(γ,β)) ∈ C via BX4
  -- BX4: U(γ,β) → G(P(U(γ,β)))
  have h_GP : Formula.all_future (Formula.some_past (Formula.untl γ β)) ∈ A := by
    have h_ax : DerivationTree [] ((Formula.untl γ β).imp
        (Formula.all_future (Formula.some_past (Formula.untl γ β)))) :=
      DerivationTree.axiom [] _ (Axiom.connect_future (Formula.untl γ β))
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_ax) h_until
  -- G(P(U(γ,β))) ∈ A means P(U(γ,β)) ∈ g_content(A) ⊆ C
  have h_P_until_C : Formula.some_past (Formula.untl γ β) ∈ C :=
    h_g_sub h_GP
  exact ⟨C, h_C_mcs, h_β_C, h_g_sub, h_P_until_C⟩

/-! ## BX9 Guard Extraction

A key helper: from U(γ,β) ∈ MCS A, extract γ ∈ A or β ∈ A.
Under strict semantics with half-open guard [t,s), BX9 gives γ ∨ β at t
(since t ∈ [t,s)).
-/

/-- BX9 at MCS level: U(γ,β) ∈ A implies (γ ∨ β) ∈ A, which means
either γ ∈ A or β ∈ A by negation completeness of MCS. -/
theorem until_elim_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    γ ∈ A ∨ β ∈ A := by
  have h_ax : DerivationTree [] ((Formula.untl γ β).imp (Formula.or γ β)) :=
    DerivationTree.axiom [] _ (Axiom.until_elim γ β)
  have h_or : Formula.or γ β ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_ax) h_until
  -- or = neg.imp, so h_or : γ.neg.imp β ∈ A
  rcases SetMaximalConsistent.negation_complete h_mcs γ with h_γ | h_neg_γ
  · exact Or.inl h_γ
  · -- ¬γ ∈ A and (¬γ → β) ∈ A gives β ∈ A
    exact Or.inr (SetMaximalConsistent.implication_property h_mcs h_or h_neg_γ)

/-- BX10 at MCS level: U(γ,β) ∈ A implies F(β) ∈ A. -/
theorem until_F_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    Formula.some_future β ∈ A := by
  have h_ax : DerivationTree [] ((Formula.untl γ β).imp (Formula.some_future β)) :=
    DerivationTree.axiom [] _ (Axiom.until_F γ β)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_until

/-- BX5 at MCS level: U(γ,β) ∈ A implies U(γ∧U(γ,β), β) ∈ A. -/
theorem self_accum_until_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (γ β : Formula)
    (h_until : Formula.untl γ β ∈ A) :
    Formula.untl (Formula.and γ (Formula.untl γ β)) β ∈ A := by
  have h_ax : DerivationTree [] ((Formula.untl γ β).imp
      (Formula.untl (Formula.and γ (Formula.untl γ β)) β)) :=
    DerivationTree.axiom [] _ (Axiom.self_accum_until γ β)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_until

/-- BX4 at MCS level: φ ∈ A implies G(P(φ)) ∈ A. -/
theorem connect_future_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ : Formula)
    (h_φ : φ ∈ A) :
    Formula.all_future (Formula.some_past φ) ∈ A := by
  have h_ax : DerivationTree [] (φ.imp (Formula.all_future (Formula.some_past φ))) :=
    DerivationTree.axiom [] _ (Axiom.connect_future φ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_φ

/-- Conjunction introduction at MCS level: if φ ∈ A and ψ ∈ A then φ ∧ ψ ∈ A. -/
theorem conj_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ ψ : Formula)
    (h_φ : φ ∈ A) (h_ψ : ψ ∈ A) :
    Formula.and φ ψ ∈ A := by
  -- and φ ψ = (φ.imp ψ.neg).neg
  -- If (φ.imp ψ.neg) ∈ A: from φ ∈ A get ψ.neg ∈ A, contradicting ψ ∈ A
  rcases SetMaximalConsistent.negation_complete h_mcs (φ.imp ψ.neg) with h | h
  · -- (φ → ¬ψ) ∈ A: from φ ∈ A get ¬ψ ∈ A
    have h_neg_ψ := SetMaximalConsistent.implication_property h_mcs h h_φ
    exact absurd h_ψ (SetMaximalConsistent.neg_excludes h_mcs _ h_neg_ψ)
  · exact h

/-! ## Lemma 2.5: g_content Ordering Composition

The key composition property: if g_content(A) ⊆ D and g_content(D) ⊆ C
(for MCS A, D, C), then g_content(A) ⊆ C. This is transitivity of the
canonical temporal ordering, using temp_4 (G → GG).
-/

/--
**Lemma 2.5** (composition): g_content ordering is transitive.
If g_content(A) ⊆ D and g_content(D) ⊆ C, then g_content(A) ⊆ C.

Proof: G(φ) ∈ A → G(G(φ)) ∈ A (temp_4) → G(φ) ∈ g_content(A) ⊆ D
→ φ ∈ g_content(D) ⊆ C.
-/
theorem lemma_2_5b {A D C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_AD : g_content A ⊆ D) (h_DC : g_content D ⊆ C) :
    g_content A ⊆ C := by
  intro φ hφ
  -- hφ : G(φ) ∈ A
  -- By temp_4: G(G(φ)) ∈ A
  have h_GGφ : Formula.all_future (Formula.all_future φ) ∈ A :=
    SetMaximalConsistent.all_future_all_future h_mcs_A hφ
  -- G(φ) ∈ D (since G(φ) ∈ g_content(A) and g_content(A) ⊆ D)
  have h_Gφ_D : Formula.all_future φ ∈ D := h_AD h_GGφ
  -- φ ∈ C (since φ ∈ g_content(D) and g_content(D) ⊆ C)
  exact h_DC h_Gφ_D

/--
Dual of lemma_2_5b: h_content ordering is transitive (past direction).
If h_content(C) ⊆ D and h_content(D) ⊆ A, then h_content(C) ⊆ A.

Proof: H(φ) ∈ C → H(H(φ)) ∈ C (past_4) → H(φ) ∈ h_content(C) ⊆ D
→ φ ∈ h_content(D) ⊆ A.
-/
theorem lemma_2_5b_past {A D C : Set Formula}
    (h_mcs_C : SetMaximalConsistent C)
    (h_CD : h_content C ⊆ D) (h_DA : h_content D ⊆ A) :
    h_content C ⊆ A := by
  intro φ hφ
  have h_HHφ : Formula.all_past (Formula.all_past φ) ∈ C :=
    SetMaximalConsistent.all_past_all_past h_mcs_C hφ
  have h_Hφ_D : Formula.all_past φ ∈ D := h_CD h_HHφ
  exact h_DA h_Hφ_D

/-! ## Lemma 2.6: Counterexample Insertion (Negative Insertion)

Given MCS A and C with g_content(A) ⊆ C, if δ ∉ C, insert D between
A and C with ¬δ ∈ D. The argument: δ ∉ C implies G(δ) ∉ A (otherwise
δ ∈ g_content(A) ⊆ C), so F(¬δ) ∈ A. Build D via Lindenbaum.
-/

/--
**Lemma 2.6** (adapted): Given MCS A and C with g_content(A) ⊆ C,
if δ ∉ C, then there exists MCS D with ¬δ ∈ D and g_content(A) ⊆ D.

This is the "negative insertion" lemma used in counterexample elimination:
any formula that fails at a future point C can be negated at an intermediate
point D while maintaining g_content coherence with A.

Proof:
1. δ ∉ C and g_content(A) ⊆ C → G(δ) ∉ A
2. F(¬δ) ∈ A (via F_neg_of_G_not)
3. {¬δ} ∪ g_content(A) is consistent (forward_temporal_witness_seed_consistent)
4. Lindenbaum extension gives D
-/
noncomputable def lemma_2_6 {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_g_AC : g_content A ⊆ C)
    (δ : Formula)
    (h_δ_not_C : δ ∉ C) :
    ∃ D : Set Formula, SetMaximalConsistent D ∧
      δ.neg ∈ D ∧ g_content A ⊆ D := by
  -- Step 1: G(δ) ∉ A
  have h_Gδ_not_A : Formula.all_future δ ∉ A := by
    intro h_Gδ; exact h_δ_not_C (h_g_AC h_Gδ)
  -- Step 2: F(¬δ) ∈ A
  have h_F_neg_δ := F_neg_of_G_not h_mcs_A δ h_Gδ_not_A
  -- Step 3: Seed consistency
  have h_seed_cons := forward_temporal_witness_seed_consistent A h_mcs_A δ.neg h_F_neg_δ
  -- Step 4: Lindenbaum extension
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed_cons
  exact ⟨D, h_D_mcs,
    h_sup (Set.mem_union_left _ (Set.mem_singleton _)),
    fun χ hχ => h_sup (Set.mem_union_right _ hχ)⟩

/--
Strengthened Lemma 2.6: additionally, g_content(D) ⊆ C (D is "between" A and C).

This requires a more careful seed construction that includes h_content(C)
in addition to g_content(A), ensuring the new MCS D flows forward to C.
The proof builds on the observation that {¬δ} ∪ g_content(A) ∪ h_content(C)
is consistent when δ ∉ C and g_content(A) ⊆ C.
-/
noncomputable def lemma_2_6_strong {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_g_AC : g_content A ⊆ C)
    (δ : Formula)
    (h_δ_not_C : δ ∉ C) :
    ∃ D : Set Formula, SetMaximalConsistent D ∧
      δ.neg ∈ D ∧ g_content A ⊆ D ∧ g_content D ⊆ C := by
  -- Step 1: G(δ) ∉ A
  have h_Gδ_not_A : Formula.all_future δ ∉ A := by
    intro h_Gδ; exact h_δ_not_C (h_g_AC h_Gδ)
  -- Step 2: F(¬δ) ∈ A
  have h_F_neg_δ := F_neg_of_G_not h_mcs_A δ h_Gδ_not_A
  -- Step 3: Show {¬δ} ∪ g_content(A) ∪ h_content(C) is consistent.
  -- This is consistent because:
  -- - g_content(A) ⊆ C (hypothesis)
  -- - h_content(C) ⊆ any MCS that g_content flows to (by duality)
  -- - ¬δ is compatible because δ ∉ C
  -- The proof of consistency uses: if L ⊆ seed and L ⊢ ⊥, then...
  -- This is a complex consistency argument. For the chronicle construction,
  -- the simpler lemma_2_6 (without g_content(D) ⊆ C) suffices for
  -- Phase 4, which establishes the full interval structure.
  -- We sorry the consistency proof here (Phase 2 dependency for duality).
  sorry

/-! ## Lemma 2.7: Until Guard Propagation and Witness Insertion

The key mathematical content: given U(ξ, η) ∈ A and a future point C
with g_content(A) ⊆ C where η ∉ C, we need to show that ξ holds at
intermediate points.

Under strict semantics, the argument proceeds via BX7 (linear_until)
combined with BX5 (self_accum) and BX12 (F_until_equiv).

### Proof Strategy

From U(ξ, η) ∈ A:
1. BX5: U(ξ∧U(ξ,η), η) ∈ A (self-accumulation)
2. η ∉ C, g_content(A) ⊆ C → G(η) ∉ A → F(¬η) ∈ A
3. BX12: F(¬η) → ⊤ U ¬η, so (⊤ U ¬η) ∈ A
4. BX7 applied to U(ξ∧U(ξ,η), η) ∧ (⊤ U ¬η):
   Three disjuncts, the third gives U(guard, (ξ∧U(ξ,η))∧¬η)
5. BX10 on the third disjunct: F((ξ∧U(ξ,η))∧¬η) ∈ A
6. Build seed {(ξ∧U(ξ,η))∧¬η} ∪ g_content(A), extend to MCS D
7. Extract ξ ∈ D from (ξ∧U(ξ,η))∧¬η ∈ D
-/

/-- Guard extraction: U(ξ,η) ∈ A with η ∉ A implies ξ ∈ A.
By BX9: ξ ∨ η ∈ A. Since η ∉ A, we get ξ ∈ A. -/
theorem lemma_2_7_guard {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ A)
    (h_η_not : η ∉ A) :
    ξ ∈ A := by
  rcases until_elim_mcs h_mcs ξ η h_until with h | h
  · exact h
  · exact absurd h h_η_not

/-- Conjunction membership gives left component in MCS. -/
theorem conj_left_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ ψ : Formula)
    (h_conj : Formula.and φ ψ ∈ A) :
    φ ∈ A := by
  -- and φ ψ = (φ.imp ψ.neg).neg ∈ A means (φ.imp ψ.neg) ∉ A
  -- lce_imp : (A ∧ B) → A
  have h_ax : DerivationTree [] ((Formula.and φ ψ).imp φ) :=
    lce_imp φ ψ
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_conj

/-- Conjunction membership gives right component in MCS. -/
theorem conj_right_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ ψ : Formula)
    (h_conj : Formula.and φ ψ ∈ A) :
    ψ ∈ A := by
  have h_ax : DerivationTree [] ((Formula.and φ ψ).imp ψ) :=
    rce_imp φ ψ
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_conj

/--
**Lemma 2.7** (adapted): Given MCS A with U(ξ, η) ∈ A and MCS C with
g_content(A) ⊆ C and η ∉ C, there exists MCS D with ξ ∈ D,
g_content(A) ⊆ D.

This is the "positive insertion" lemma: the Until guard ξ can be realized
at an intermediate point D.

### Proof

1. BX5: U(ξ∧U(ξ,η), η) ∈ A
2. η ∉ C → G(η) ∉ A → F(¬η) ∈ A
3. BX12: (⊤ U ¬η) ∈ A
4. BX7: three-way disjunction from U(ξ∧U(ξ,η), η) ∧ (⊤ U ¬η)
5. First disjunct (witness η∧¬η) is absurd
6. Third disjunct gives F((ξ∧U(ξ,η))∧¬η) → seed with ξ
7. Second disjunct also gives ξ via BX9 (guard contains ξ)
-/
noncomputable def lemma_2_7 {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_g_AC : g_content A ⊆ C)
    (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ A)
    (h_η_not_C : η ∉ C) :
    ∃ D : Set Formula, SetMaximalConsistent D ∧
      ξ ∈ D ∧ g_content A ⊆ D := by
  -- Setup: BX5, F(¬η), BX12
  have h_self_accum := self_accum_until_mcs h_mcs_A ξ η h_until
  have h_Gη_not : Formula.all_future η ∉ A := by
    intro h; exact h_η_not_C (h_g_AC h)
  have h_F_neg_η := F_neg_of_G_not h_mcs_A η h_Gη_not
  -- BX12: F(¬η) → ⊤ U ¬η
  let top := Formula.bot.imp Formula.bot
  have h_top_until : Formula.untl top η.neg ∈ A := by
    have h_ax : DerivationTree [] ((Formula.some_future η.neg).imp (Formula.untl top η.neg)) :=
      DerivationTree.axiom [] _ (Axiom.F_until_equiv η.neg)
    exact SetMaximalConsistent.implication_property h_mcs_A
      (theorem_in_mcs h_mcs_A h_ax) h_F_neg_η

  -- Build conjunction for BX7
  have h_conj := conj_mcs h_mcs_A _ _ h_self_accum h_top_until

  -- Apply BX7
  let φ := Formula.and ξ (Formula.untl ξ η)
  let ψ := η
  let χ := top
  let θ := η.neg
  have h_ax_linear : DerivationTree [] (
      Formula.and (Formula.untl φ ψ) (Formula.untl χ θ) |>.imp
      (Formula.or
        (Formula.or
          (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.untl (Formula.and φ χ) (Formula.and φ θ)))) :=
    DerivationTree.axiom [] _ (Axiom.linear_until φ ψ χ θ)

  have h_disj := SetMaximalConsistent.implication_property h_mcs_A
    (theorem_in_mcs h_mcs_A h_ax_linear) h_conj

  -- Three-way case split
  -- D1: U(φ∧χ, ψ∧θ) = U(φ∧⊤, η∧¬η) -- absurd (F(η∧¬η) = F(⊥))
  -- D2: U(φ∧χ, ψ∧χ) = U(φ∧⊤, η∧⊤) -- witness has η
  -- D3: U(φ∧χ, φ∧θ) = U(φ∧⊤, φ∧¬η) -- witness has ξ∧U(ξ,η)∧¬η

  -- First, check if D1 is in A or its negation
  rcases SetMaximalConsistent.negation_complete h_mcs_A
    (Formula.untl (Formula.and φ χ) (Formula.and ψ θ)) with h_D1 | h_neg_D1
  · -- D1: U(_, η∧¬η) ∈ A. By BX10: F(η∧¬η) ∈ A.
    -- η∧¬η = (η.imp (η.neg).neg).neg. In MCS, this is a contradiction.
    -- BX10: U(φ∧χ, η∧¬η) → F(η∧¬η)
    have h_F_contr := until_F_mcs h_mcs_A (Formula.and φ χ) (Formula.and ψ θ) h_D1
    -- F(η ∧ ¬η) ∈ A. But η ∧ ¬η is inconsistent.
    -- η ∧ ¬η = (η.imp (η.neg).neg).neg = (η.imp (η.imp bot).imp bot).neg
    -- Actually, F(η ∧ ¬η) = ¬G(¬(η ∧ ¬η)). We need to show this leads to ⊥.
    -- (η ∧ ¬η) → ⊥ is a theorem. So G(η∧¬η → ⊥) is provable.
    -- G(¬(η∧¬η)) is provable. So F(η∧¬η) = ¬G(¬(η∧¬η)) leads to contradiction.
    -- Use: (η ∧ ¬η) ∈ any MCS is impossible (contradiction).
    -- So F(η ∧ ¬η) should be impossible in any MCS.
    -- Formally: ⊢ (η ∧ ¬η) → ⊥. By temporal necessitation: ⊢ G((η∧¬η) → ⊥).
    -- By temp_k_dist: G((η∧¬η)→⊥) → (G(η∧¬η) → G(⊥)).
    -- But we need ¬G(¬(η∧¬η)) ∈ A. If G(¬(η∧¬η)) ∈ A, that's fine.
    -- The issue is ¬G(¬(η∧¬η)) ∈ A means G(¬(η∧¬η)) ∉ A.
    -- But ¬(η∧¬η) is a theorem, so G(¬(η∧¬η)) is provable, hence in all MCS.
    -- Contradiction with G(¬(η∧¬η)) ∉ A.
    --
    -- Show: ¬(η ∧ ¬η) is a theorem (tautology)
    -- ¬(η ∧ ¬η) = (η.and η.neg).neg = ((η.imp η.neg.neg).neg).neg
    --           = (η.imp η.neg.neg)  (double negation of negation)
    -- Hmm, let's just show F(η ∧ ¬η) leads to contradiction.
    -- and ψ θ = and η (η.neg) = (η.imp (η.neg).neg).neg
    -- F(and η η.neg) = some_future (and η η.neg)
    --               = (and η η.neg).neg.all_future.neg
    -- We know (and η η.neg) → ⊥ is provable (it's a contradiction).
    -- So G((and η η.neg) → ⊥) is provable (temporal necessitation of tautology).
    -- Then: by g_content logic, if there were a future point with η∧¬η,
    -- that would violate consistency.
    -- But proving this formally requires showing ⊢ (η ∧ ¬η) → ⊥.
    -- This is: ⊢ (η.imp η.neg.neg).neg → ⊥, i.e., ⊢ ¬¬(η → ¬¬η).
    -- Hmm. Let's use the identity: conj_and_neg_bot.
    -- Actually: and η η.neg = (η.imp η.neg.neg).neg = (η.imp (η.imp ⊥).imp ⊥).neg
    -- Let me just sorry this case since it requires building a complex derivation
    -- tree for the propositional tautology ¬(η ∧ ¬η). The other cases are
    -- more interesting mathematically.
    -- For now, handle this via exfalso: MCS cannot contain η∧¬η.
    exfalso
    -- We have F(η ∧ ¬η) ∈ A. This means ¬G(¬(η ∧ ¬η)) ∈ A.
    -- But ¬(η ∧ ¬η) is a tautology, so G(¬(η ∧ ¬η)) is provable, hence in A.
    -- This contradicts ¬G(¬(η ∧ ¬η)) ∈ A.
    -- ⊢ (η ∧ ¬η) → ⊥
    -- and η η.neg = (η.imp η.neg.neg).neg = (η → (η → ⊥) → ⊥) → ⊥
    -- This is: ¬(η → ¬¬η). But η → ¬¬η is DNI, which is provable.
    -- So ¬DNI is provable? No! DNI is provable, so ¬DNI → ⊥ is provable.
    -- That is, (η → ¬¬η) → ⊥ → ⊥ is fine but we need ¬(η → ¬¬η) → ⊥.
    -- Actually, (η → ¬¬η) is DNI, which IS provable. So DNI ∈ A.
    -- (η → ¬¬η) = (η.imp η.neg.neg) ∈ A (it's a theorem).
    -- and η η.neg = (η.imp η.neg.neg).neg, which is the negation of DNI.
    -- ¬DNI ∈ A contradicts DNI ∈ A (by set_consistent_not_both).
    -- So η ∧ ¬η ∉ A for any MCS A. And F(η ∧ ¬η) ∉ A for any MCS A? No!
    -- F(η ∧ ¬η) = ¬G(¬(η ∧ ¬η)). G(¬(η ∧ ¬η)) = G(DNI).
    -- DNI is a theorem, so G(DNI) is provable (temporal necessitation of theorem).
    -- So G(DNI) ∈ A. Hence ¬G(DNI) ∉ A. Hence F(η ∧ ¬η) ∉ A.
    -- But h_F_contr says F(η ∧ ¬η) ∈ A. Contradiction!
    have h_dni : DerivationTree [] (η.imp η.neg.neg) := dni η
    have h_dni_in_A := theorem_in_mcs h_mcs_A h_dni
    -- h_F_contr : (and η η.neg).some_future ∈ A
    --           = ((η.imp η.neg.neg).neg).neg.all_future.neg ∈ A
    --           = (η.imp η.neg.neg).all_future.neg ∈ A
    -- So: ¬G(η → ¬¬η) ∈ A.
    -- But: G(η → ¬¬η) ∈ A (temporal necessitation of DNI)
    have h_G_dni : DerivationTree [] (Formula.all_future (η.imp η.neg.neg)) :=
      DerivationTree.temporal_necessitation _ h_dni
    have h_G_dni_in_A := theorem_in_mcs h_mcs_A h_G_dni
    -- h_F_contr : some_future (and η η.neg) ∈ A
    -- some_future X = X.neg.all_future.neg
    -- and η η.neg = (η.imp η.neg.neg).neg
    -- So some_future (and η η.neg) = (and η η.neg).neg.all_future.neg
    --   = (η.imp η.neg.neg).neg.neg.all_future.neg
    --   = (η.imp η.neg.neg).all_future.neg  (since neg.neg = id syntactically? NO!)
    -- Actually: neg X = X.imp bot. neg.neg X = (X.imp bot).imp bot.
    -- So (and η η.neg).neg = ((η.imp η.neg.neg).neg).imp bot
    --   = ((η.imp η.neg.neg).imp bot).imp bot -- this is ¬¬(η → ¬¬η)
    -- This is NOT the same as (η.imp η.neg.neg).
    -- F(η∧¬η) = (η∧¬η).neg.all_future.neg
    -- = ((η∧¬η).imp bot).all_future.imp bot
    -- = ((((η.imp η.neg.neg).neg).imp bot).all_future).imp bot
    -- = (((η.imp η.neg.neg).neg.imp bot).all_future).imp bot
    --
    -- This is ¬G(¬¬(η→¬¬η)). NOT ¬G(η→¬¬η).
    -- So we need G(¬¬(η→¬¬η)) ∈ A, not G(η→¬¬η) ∈ A.
    -- G(¬¬X) follows from G(X) + G(X → ¬¬X) by temp_k_dist.
    -- X → ¬¬X is DNI itself. So G(X → ¬¬X) by temporal necessitation.
    -- Then G(X → ¬¬X) → (G(X) → G(¬¬X)) by temp_k_dist.
    -- Applied to X = (η → ¬¬η):
    -- G(η→¬¬η) ∈ A (from h_G_dni_in_A)
    -- G((η→¬¬η) → ¬¬(η→¬¬η)) ∈ A (temporal necessitation of DNI for η→¬¬η)
    have h_dni2 : DerivationTree [] ((η.imp η.neg.neg).imp (η.imp η.neg.neg).neg.neg) :=
      dni (η.imp η.neg.neg)
    have h_G_dni2 : DerivationTree [] (Formula.all_future
        ((η.imp η.neg.neg).imp (η.imp η.neg.neg).neg.neg)) :=
      DerivationTree.temporal_necessitation _ h_dni2
    have h_kd : DerivationTree [] (
        ((η.imp η.neg.neg).imp (η.imp η.neg.neg).neg.neg).all_future.imp
        ((η.imp η.neg.neg).all_future.imp (η.imp η.neg.neg).neg.neg.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist (η.imp η.neg.neg) (η.imp η.neg.neg).neg.neg)
    have h1 := theorem_in_mcs h_mcs_A h_G_dni2
    have h2 := theorem_in_mcs h_mcs_A h_kd
    have h3 := SetMaximalConsistent.implication_property h_mcs_A h2 h1
    have h_G_nn_dni := SetMaximalConsistent.implication_property h_mcs_A h3 h_G_dni_in_A
    -- h_G_nn_dni : G(¬¬(η→¬¬η)) ∈ A = (η.imp η.neg.neg).neg.neg.all_future ∈ A
    -- h_F_contr : F(η∧¬η) = ((η.imp η.neg.neg).neg.imp bot).all_future.imp bot ∈ A
    --           = (η.imp η.neg.neg).neg.neg.all_future.neg ∈ A
    -- (since neg X = X.imp bot, so neg.neg X = (X.imp bot).imp bot)
    -- Wait: (and η η.neg).neg = ((η.imp η.neg.neg).neg).neg
    --                         = ((η.imp η.neg.neg).neg).imp bot
    -- some_future (and η η.neg) = ((and η η.neg).neg).all_future.neg
    --   = ((((η.imp η.neg.neg).neg).imp bot)).all_future.neg
    --   = ((η.imp η.neg.neg).neg.neg).all_future.neg
    --   (since neg.neg X = (X.imp bot).imp bot, BUT neg.imp bot = neg.neg. Actually
    --    neg X = X.imp bot, so (neg X).imp bot = (X.imp bot).imp bot = neg.neg X.)
    -- Great, so: some_future (and η η.neg) = (η.imp η.neg.neg).neg.neg.all_future.neg
    -- This is ¬(G(¬¬(η→¬¬η))). We have G(¬¬(η→¬¬η)) ∈ A AND ¬G(¬¬(η→¬¬η)) ∈ A.
    -- Contradiction!
    -- h_G_nn_dni : (η.imp η.neg.neg).neg.neg.all_future ∈ A
    -- h_F_contr is F(and η η.neg) ∈ A
    -- Let's verify the types match
    -- some_future X = X.neg.all_future.neg
    -- X = and η η.neg = (η.imp η.neg.neg).neg
    -- X.neg = (η.imp η.neg.neg).neg.neg  (since neg (neg Y) = (Y.imp bot).imp bot)
    -- Wait: neg X = X.imp bot. X = (η.imp η.neg.neg).neg = (η.imp η.neg.neg).imp bot.
    -- X.neg = ((η.imp η.neg.neg).imp bot).imp bot = (η.imp η.neg.neg).neg.neg? No!
    -- neg X for X = (η.imp η.neg.neg).neg:
    -- neg ((η.imp η.neg.neg).neg) = ((η.imp η.neg.neg).neg).imp bot
    -- But (η.imp η.neg.neg).neg = (η.imp η.neg.neg).imp bot
    -- So neg ((η.imp η.neg.neg).imp bot) = ((η.imp η.neg.neg).imp bot).imp bot
    -- And (η.imp η.neg.neg).neg.neg = ((η.imp η.neg.neg).imp bot).imp bot
    -- YES, these are the same! So X.neg = (η.imp η.neg.neg).neg.neg.
    -- Therefore: some_future (and η η.neg)
    --   = X.neg.all_future.neg
    --   = (η.imp η.neg.neg).neg.neg.all_future.neg
    -- And h_G_nn_dni : (η.imp η.neg.neg).neg.neg.all_future ∈ A
    -- So we need: (η.imp η.neg.neg).neg.neg.all_future.neg ∈ A contradicts
    --             (η.imp η.neg.neg).neg.neg.all_future ∈ A.
    -- These are φ and φ.neg for φ = (η.imp η.neg.neg).neg.neg.all_future.
    exact set_consistent_not_both h_mcs_A.1
      ((η.imp η.neg.neg).neg.neg.all_future) h_G_nn_dni h_F_contr

  · -- ¬D1 ∈ A. From the disjunction (D1 ∨ D2) ∨ D3:
    -- ¬D1 → (D2 ∨ D3)
    -- (D1 ∨ D2) ∨ D3 and ¬(D1 ∨ D2) → D3
    -- Actually the disjunction structure is: (D1.or D2).or D3
    -- = D1.neg.imp D2 gives D2 if ¬D1.
    -- So from ¬D1 and ((D1.or D2).or D3):

    -- First, derive D2 ∨ D3 from ¬D1 and (D1 ∨ D2) ∨ D3
    -- or X Y = X.neg.imp Y.
    -- h_disj : ((D1.or D2).or D3) = (D1.or D2).neg.imp D3 ∈ A
    -- But we want: from ¬D1, get D2 ∨ D3.
    -- D1.or D2 = D1.neg.imp D2 ∈ A (since from ¬D1 we get D2)
    -- Check: does ¬D1 → (D1.neg.imp D2) ∈ A? ¬D1 = D1.neg ∈ A.
    -- D1.neg.imp D2: if D1.neg ∈ A, does D2 ∈ A follow? Only if D1.neg.imp D2 ∈ A.

    -- Let me just handle both D2 and D3 via negation completeness.
    rcases SetMaximalConsistent.negation_complete h_mcs_A
      (Formula.untl (Formula.and φ χ) (Formula.and φ θ)) with h_D3 | h_neg_D3
    · -- D3: U(φ∧⊤, φ∧¬η) ∈ A. By BX10: F(φ∧¬η) = F((ξ∧U(ξ,η))∧¬η) ∈ A
      have h_F_target := until_F_mcs h_mcs_A (Formula.and φ χ) (Formula.and φ θ) h_D3
      -- Seed: {(ξ∧U(ξ,η))∧¬η} ∪ g_content(A) is consistent
      have h_seed := forward_temporal_witness_seed_consistent A h_mcs_A
        (Formula.and φ θ) h_F_target
      -- Extend to MCS D
      obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed
      have h_target_D : Formula.and φ θ ∈ D :=
        h_sup (Set.mem_union_left _ (Set.mem_singleton _))
      -- Extract φ = ξ∧U(ξ,η) from (ξ∧U(ξ,η))∧¬η
      have h_φ_D := conj_left_mcs h_D_mcs φ θ h_target_D
      -- Extract ξ from ξ∧U(ξ,η)
      have h_ξ_D := conj_left_mcs h_D_mcs ξ (Formula.untl ξ η) h_φ_D
      exact ⟨D, h_D_mcs, h_ξ_D, fun w hw => h_sup (Set.mem_union_right _ hw)⟩

    · -- ¬D3 ∈ A. From (D1∨D2)∨D3 and ¬D3, get D1∨D2.
      -- h_disj : (D1.or D2).neg.imp D3' ∈ A where D3' = D3 above
      -- Actually: h_disj is the full disjunction.
      -- From ¬D3 and the outer or: (D1.or D2).or D3 and ¬D3 → D1.or D2
      -- or X Y = X.neg.imp Y, so ((D1.or D2).or D3) = (D1.or D2).neg.imp D3
      -- h_disj : (D1.or D2).neg.imp (Formula.untl (Formula.and φ χ) (Formula.and φ θ)) ∈ A
      -- Wait, h_disj has the ORIGINAL formula from BX7:
      -- Formula.or (Formula.or D1 D2) D3
      -- = (Formula.or D1 D2).neg.imp D3
      -- So h_disj : ¬(D1 ∨ D2) → D3 ∈ A
      -- From ¬D3 and ¬(D1 ∨ D2) → D3: ¬¬(D1 ∨ D2) by contrapositive
      -- Then by DNE: D1 ∨ D2.
      -- D1 ∨ D2 and ¬D1: D2.

      -- D2 = U(φ∧χ, ψ∧χ) = U(φ∧⊤, η∧⊤)
      -- BX9: (φ∧⊤) ∨ (η∧⊤) ∈ A
      -- BX10: F(η∧⊤) ∈ A
      -- From BX9: if φ∧⊤ ∈ A then φ ∈ A, so ξ∧U(ξ,η) ∈ A, so ξ ∈ A.
      -- If η∧⊤ ∈ A then η ∈ A. Either way we get F(something with ξ).
      -- BX4 on ξ: ξ → G(P(ξ)). So P(ξ) ∈ g_content(A).
      -- But we need ξ in a FUTURE MCS D, and P(ξ) at D doesn't give ξ at D.

      -- Actually, for D2: U(φ∧⊤, η∧⊤) ∈ A.
      -- BX5 on this: U((φ∧⊤)∧U(φ∧⊤,η∧⊤), η∧⊤) ∈ A.
      -- BX10: F(η∧⊤) ∈ A.
      -- At the witness point: η∧⊤ holds. But we need ξ at intermediate point.
      -- The guard (φ∧⊤) contains ξ (via φ = ξ∧U(ξ,η)).
      -- By BX9 on D2: (φ∧⊤) ∈ A or (η∧⊤) ∈ A.

      -- Let me use a simpler approach: D2 gives U(_, η∧⊤).
      -- BX10: F(η∧⊤) ∈ A. Actually, η∧⊤ simplifies...
      -- The guard is φ∧⊤ which contains ξ.
      -- If BX9 gives φ∧⊤ ∈ A: then ξ ∈ A (via conj_left twice).
      -- If BX9 gives η∧⊤ ∈ A: then η ∈ A.
      -- In either case, we can use enriched_resolving_seed_consistent.

      -- For this case, we need F(ξ ∧ something) or F(η ∧ something).
      -- We know ¬D3 ∈ A and ¬D1 ∈ A, so from the full disjunction: D2 ∈ A.

      -- First derive D2 ∈ A from ¬D1, ¬D3, and the disjunction.
      -- The outer or: (D1∨D2) ∨ D3 = (D1∨D2).neg → D3
      -- Contrapositive: ¬D3 → ¬¬(D1∨D2) → (D1∨D2) (by DNE)
      -- Then D1∨D2 and ¬D1 → D2.
      -- h_disj is (or (or D1 D2) D3) ∈ A
      -- From ¬D3 (h_neg_D3) and h_disj: (D1 ∨ D2) ∈ A? Not directly.
      -- Actually: (or X Y) = X.neg.imp Y.
      -- So h_disj : (or D1 D2).neg.imp D3_formula ∈ A
      -- where D3_formula = Formula.untl (Formula.and φ χ) (Formula.and φ θ)
      -- Wait, the structure is:
      -- h_disj : (Formula.or (Formula.or D1_f D2_f) D3_f) ∈ A
      -- = ((Formula.or D1_f D2_f).neg.imp D3_f) ∈ A
      -- h_neg_D3 : D3_f.neg ∈ A
      -- We want: (Formula.or D1_f D2_f) ∈ A
      -- If (Formula.or D1_f D2_f).neg ∈ A: from h_disj (MP): D3_f ∈ A
      --   But D3_f.neg ∈ A (h_neg_D3), contradiction.
      -- So (Formula.or D1_f D2_f).neg ∉ A, hence (Formula.or D1_f D2_f) ∈ A.

      have h_D1_or_D2 : Formula.or (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)) ∈ A := by
        rcases SetMaximalConsistent.negation_complete h_mcs_A
          (Formula.or (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.untl (Formula.and φ χ) (Formula.and ψ χ))) with h | h_neg
        · exact h
        · -- ¬(D1∨D2) ∈ A. From h_disj ((D1∨D2)∨D3): ¬(D1∨D2) → D3.
          -- MP: D3 ∈ A. But ¬D3 ∈ A. Contradiction.
          have h_D3' := SetMaximalConsistent.implication_property h_mcs_A h_disj h_neg
          exact absurd h_D3' (SetMaximalConsistent.neg_excludes h_mcs_A _ h_neg_D3)

      -- Now from D1∨D2 and ¬D1, get D2.
      have h_D2 : Formula.untl (Formula.and φ χ) (Formula.and ψ χ) ∈ A :=
        SetMaximalConsistent.implication_property h_mcs_A h_D1_or_D2 h_neg_D1

      -- D2 = U(φ∧⊤, η∧⊤) ∈ A. By BX10: F(η∧⊤) ∈ A.
      have h_F_D2_wit := until_F_mcs h_mcs_A (Formula.and φ χ) (Formula.and ψ χ) h_D2
      -- BX9 on D2: (φ∧⊤) ∈ A ∨ (η∧⊤) ∈ A
      rcases until_elim_mcs h_mcs_A (Formula.and φ χ) (Formula.and ψ χ) h_D2 with h_guard | h_wit
      · -- Guard φ∧⊤ ∈ A: extract ξ∧U(ξ,η) from φ∧⊤, then ξ from ξ∧U(ξ,η)
        have h_φ := conj_left_mcs h_mcs_A φ χ h_guard
        have h_ξ := conj_left_mcs h_mcs_A ξ (Formula.untl ξ η) h_φ
        -- ξ ∈ A. BX4: G(P(ξ)) ∈ A. P(ξ) ∈ g_content(A).
        -- But we need ξ at a FUTURE point D with g_content(A) ⊆ D.
        -- P(ξ) ∈ D doesn't give ξ ∈ D.
        -- However: we also have U(ξ∧U(ξ,η), η) ∈ A (h_self_accum).
        -- At D (future of A), if η ∉ D (which we can't guarantee from D2),
        -- BX9 gives ξ∧U(ξ,η) ∈ D or η ∈ D... but U(ξ∧U(ξ,η), η) needs
        -- to be in D first, which requires g_content propagation.
        -- U(...) is NOT in g_content(A) (Until formulas aren't G-formulas).
        -- So we can't use g_content to propagate Until.
        --
        -- Alternative: use the enriched seed.
        -- We have F(η∧⊤) ∈ A (from D2 via BX10). And ξ ∈ A.
        -- enriched_resolving_seed_consistent: F(ψ ∧ α) ∈ A → {ψ, α} ∪ g_content consistent
        -- We'd need F(ξ ∧ something) or to build ξ into the seed directly.
        -- Actually: we have D2 = U(φ∧⊤, η∧⊤). Apply BX5 to D2:
        -- U((φ∧⊤)∧U(φ∧⊤,η∧⊤), η∧⊤) ∈ A.
        -- BX10: F(η∧⊤) ∈ A. The guard (φ∧⊤)∧U(φ∧⊤,η∧⊤) contains φ,
        -- which contains ξ.
        -- enriched_resolving_seed_consistent on U(guard, η∧⊤):
        -- F((η∧⊤) ∧ guard)? We need F of the conjunction.
        -- temp_linearity can get F(η∧⊤ ∧ guard) but this is complex.
        --
        -- Simplest: F(η∧⊤) ∈ A. Use forward_temporal_witness for η∧⊤.
        -- Get MCS D with (η∧⊤) ∈ D and g_content(A) ⊆ D.
        -- Then η ∈ D. But we wanted ξ ∈ D, not η ∈ D.
        --
        -- This case requires showing that the GUARD ξ persists to the
        -- intermediate point. This is precisely the hard part of Lemma 2.7.
        -- Under strict semantics, the guard only covers [t,s), and we're
        -- looking for ξ at a point between A and the η-witness.
        --
        -- The guard (φ∧⊤) is at the current point A. For future points,
        -- we need the self-accumulated Until's guard.
        -- But the Until doesn't propagate via g_content.
        --
        -- This is the FUNDAMENTAL challenge of Lemma 2.7 under strict semantics.
        -- The BX7 argument in the D3 case works because it directly gives
        -- F(φ∧¬η) which contains ξ. The D2 case is harder.
        --
        -- For the D2 case: we use BX7 AGAIN on D2 and (⊤ U ¬η).
        -- But we already did that and got into this case.
        -- The issue is that D2 is the case where η comes BEFORE ¬η.
        -- So at intermediate points between A and the η-witness, the guard
        -- φ∧⊤ holds, giving ξ. BUT: between the η-witness and the ¬η-witness,
        -- the guard might not hold anymore.
        -- However, we just need ONE point with ξ, and the intermediate
        -- points before η have the guard.
        --
        -- OK, I think we need to use BX5 on D2 and then BX10 to get
        -- F((φ∧⊤)∧(η∧⊤)) or similar. Let me try:
        -- BX5 on D2: U((φ∧⊤)∧D2, η∧⊤) where D2 = U(φ∧⊤, η∧⊤)
        -- BX10: F(η∧⊤).
        -- temp_linearity on F(η∧⊤) and F(¬η):
        -- F((η∧⊤)∧¬η) ∨ F((η∧⊤)∧F(¬η)) ∨ F(F(η∧⊤)∧¬η)
        -- The first is absurd (η∧¬η essentially).
        -- The second: F(η∧⊤∧F(¬η)). At this point, η holds AND F(¬η) holds.
        --   i.e., η now and ¬η later.
        -- The third: F(F(η∧⊤)∧¬η). At this point, ¬η holds AND F(η∧⊤) ahead.
        --   i.e., ¬η now and η later.
        -- In case 3: ¬η ∈ D and F(η∧⊤) ∈ D. The original D2 U-formula
        -- had guard φ∧⊤ containing ξ. At D's time, ¬η holds, so D is
        -- in the guard interval of D2 (between A and the η-witness).
        -- Therefore φ∧⊤ should hold at D, giving ξ.
        -- BUT this is a semantic argument! Syntactically, we don't have
        -- the Until formula at D.
        --
        -- This analysis shows that Lemma 2.7 in the D2 case genuinely
        -- requires a complex chain of BX axiom applications. The D3 case
        -- is the clean one.
        --
        -- For now, sorry this case.
        sorry

      · -- Witness η∧⊤ ∈ A: η ∈ A
        -- Similar analysis. η ∈ A and U(ξ,η) ∈ A.
        -- Under strict Until: U(ξ,η) at t means ∃s>t, η(s), ξ on [t,s).
        -- η at t is consistent with U(ξ,η) at t.
        -- We still need ξ at a future point.
        sorry

/-! ## Lemma 2.8: Variant with Neg-Disjunction at C

Given U(ξ, η) ∈ A and ¬(ξ ∨ (η ∧ U(ξ,η))) ∈ C with g_content(A) ⊆ C,
insert D between A and C with ξ ∈ D.

The condition ¬(ξ ∨ (η ∧ U(ξ,η))) ∈ C decomposes (via MCS properties) to:
- ξ ∉ C (so ξ fails at C)
- η ∉ C or U(ξ,η) ∉ C

When η ∉ C, this reduces to Lemma 2.7 directly.
-/

/--
**Lemma 2.8** (adapted): Given U(ξ, η) ∈ A and
¬(ξ ∨ (η ∧ U(ξ,η))) ∈ C with g_content(A) ⊆ C,
there exists MCS D with ξ ∈ D and g_content(A) ⊆ D.

Under strict semantics, the neg-disjunction condition ensures that
at C, neither ξ nor the conjunction η∧U(ξ,η) holds. This means the
Until U(ξ,η) is still "unresolved" relative to C, guaranteeing that
the guard ξ must hold at intermediate points.
-/
noncomputable def lemma_2_8 {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_g_AC : g_content A ⊆ C)
    (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ A)
    (h_neg_disj : (ξ.or (η.and (Formula.untl ξ η))).neg ∈ C) :
    ∃ D : Set Formula, SetMaximalConsistent D ∧
      ξ ∈ D ∧ g_content A ⊆ D := by
  -- The neg_disj condition: ¬(ξ ∨ (η ∧ U(ξ,η))) ∈ C
  -- or = neg.imp, so this is ¬(ξ.neg → (η ∧ U(ξ,η))) ∈ C
  -- For MCS: ¬(A → B) ∈ M iff A ∈ M and B ∉ M
  -- So: ξ.neg ∈ C (i.e., ξ ∉ C) and (η ∧ U(ξ,η)) ∉ C

  -- First: ξ ∉ C
  have h_or_not_C : (ξ.or (η.and (Formula.untl ξ η))) ∉ C :=
    SetMaximalConsistent.neg_excludes h_mcs_C _ h_neg_disj

  -- ξ ∉ C implies η ∉ C (we'll show this or handle both cases)
  -- Actually: from ¬(ξ ∨ (η∧U(ξ,η))) ∈ C, the neg-or decomposes to:
  -- ¬ξ ∈ C AND ¬(η∧U(ξ,η)) ∈ C (De Morgan for MCS)
  -- More precisely: ξ.neg ∈ C. Since or X Y = X.neg.imp Y, and
  -- ¬(X.neg.imp Y) ∈ C iff X.neg ∈ C and Y ∉ C (by MCS implication property).
  -- So: ξ.neg ∈ C (hence ξ ∉ C) and (η.and (Formula.untl ξ η)) ∉ C.

  -- Extract ξ.neg ∈ C
  have h_ξ_neg_C : ξ.neg ∈ C := by
    -- ¬(ξ.neg.imp (η.and (Formula.untl ξ η))) ∈ C
    -- By MCS property: if ξ.neg ∉ C, then ¬ξ.neg ∈ C, i.e., ξ.neg.neg ∈ C.
    -- Then ξ.neg.imp anything ∈ C (by implication vacuity? No.)
    -- Actually: ¬(A → B) ∈ M means A ∈ M. Here A = ξ.neg.
    -- ¬(ξ.neg.imp (η.and (Formula.untl ξ η))).neg is just h_neg_disj already.
    -- neg_disj = (ξ.neg.imp (η.and (Formula.untl ξ η))).imp bot ∈ C
    -- By MCS: if ξ.neg.imp (η.and ...) ∈ C, then its neg ∉ C. Contradiction.
    -- So ξ.neg.imp (η.and ...) ∉ C.
    -- By MCS negation complete: ¬(ξ.neg.imp (η.and ...)) ∈ C. That's h_neg_disj.
    -- Now: ¬(A → B) ∈ M implies A ∈ M.
    -- Proof: ¬(A → B) = (A → B) → ⊥ ∈ M.
    -- Suppose A ∉ M. Then ¬A ∈ M. But ¬A → (A → B) is provable (ex falso on A).
    -- So (A → B) ∈ M. Then (A → B) → ⊥ and (A → B) both in M: contradiction.
    -- Therefore A ∈ M.
    by_contra h_ξ_neg_not
    rcases SetMaximalConsistent.negation_complete h_mcs_C ξ.neg with h | h
    · exact h_ξ_neg_not h
    · -- ξ.neg.neg ∈ C, i.e., ¬¬ξ ∈ C
      -- From ¬¬ξ, derive ξ (by DNE), then ξ → (ξ ∨ (η∧U(ξ,η))) is provable
      -- (left disjunction introduction). So ξ ∈ C → ξ ∨ ... ∈ C.
      -- But we have ¬(ξ ∨ ...) ∈ C, contradiction.
      -- Actually, we don't directly have ξ ∈ C, we have ξ.neg.neg ∈ C.
      -- ξ.neg.neg = (ξ.imp bot).imp bot. DNE gives (ξ.neg.neg → ξ).
      have h_dne : DerivationTree [] (ξ.neg.neg.imp ξ) :=
        Bimodal.Theorems.Propositional.double_negation ξ
      have h_ξ_C := SetMaximalConsistent.implication_property h_mcs_C
        (theorem_in_mcs h_mcs_C h_dne) h
      -- ξ ∈ C. Now ξ → (ξ ∨ (η∧U(ξ,η))).
      -- or X Y = X.neg.imp Y. So ξ.or Z = ξ.neg.imp Z.
      -- ξ → ξ.neg.imp Z: suppose ξ. Then ξ.neg → Z (ex falso from ξ and ξ.neg).
      -- Hmm, ξ → (ξ.neg → Z). This is: ξ → ¬ξ → Z. In classical logic this
      -- is valid: if ξ and ¬ξ, then anything.
      -- Derivation: from ξ and ξ.neg (= ξ → ⊥), get ⊥, then Z by ex_falso.
      -- So ⊢ ξ → (ξ.neg → Z) for any Z. i.e., ⊢ ξ → ξ.or Z.
      -- This means ξ.or (η.and ...) ∈ C from ξ ∈ C.
      -- But ¬(ξ.or ...) ∈ C: contradiction.
      have h_disj_intro : DerivationTree [] (ξ.imp (ξ.or (η.and (Formula.untl ξ η)))) := by
        -- ξ → (ξ.neg → (η.and ...)) which is ξ → ξ.or (η.and ...)
        -- This is the same as: ξ → ¬ξ → Z
        -- Use context [ξ.neg, ξ] (matching deduction_theorem [ξ] ξ.neg)
        let Z := η.and (Formula.untl ξ η)
        have h1 : DerivationTree [ξ.neg, ξ] Formula.bot :=
          DerivationTree.modus_ponens [ξ.neg, ξ] ξ Formula.bot
            (DerivationTree.assumption [ξ.neg, ξ] ξ.neg (by simp))
            (DerivationTree.assumption [ξ.neg, ξ] ξ (by simp))
        have h2 : DerivationTree [ξ.neg, ξ] Z :=
          DerivationTree.modus_ponens [ξ.neg, ξ] Formula.bot _
            (DerivationTree.weakening [] [ξ.neg, ξ] _ (DerivationTree.axiom [] _
              (Axiom.ex_falso Z)) (List.nil_subset _))
            h1
        have h3 : DerivationTree [ξ] (ξ.neg.imp Z) :=
          deduction_theorem [ξ] ξ.neg _ h2
        exact deduction_theorem [] ξ _ h3
      have h_or_C := SetMaximalConsistent.implication_property h_mcs_C
        (theorem_in_mcs h_mcs_C h_disj_intro) h_ξ_C
      exact absurd h_or_C h_or_not_C

  -- ξ ∉ C (from ξ.neg ∈ C)
  have h_ξ_not_C : ξ ∉ C :=
    SetMaximalConsistent.neg_excludes h_mcs_C ξ h_ξ_neg_C

  -- Now case split on whether η ∈ C
  by_cases h_η_C : η ∈ C
  · -- η ∈ C: then (η.and (Formula.untl ξ η)) ∉ C, so U(ξ,η) ∉ C.
    -- G(U(ξ,η)) ∉ A (otherwise U(ξ,η) ∈ g_content(A) ⊆ C).
    -- F(¬U(ξ,η)) ∈ A.
    -- But we need ξ at an intermediate point, not ¬U(ξ,η).
    -- From U(ξ,η) ∈ A and F(¬U(ξ,η)) ∈ A:
    -- BX7 applied to U(ξ,η) and (⊤ U ¬U(ξ,η))...
    -- This leads to a complex analysis similar to Lemma 2.7.
    -- For now, sorry this case (the η ∉ C case below is the main case).
    sorry
  · -- η ∉ C: reduces to lemma_2_7
    exact lemma_2_7 h_mcs_A h_mcs_C h_g_AC ξ η h_until h_η_C

end Bimodal.Metalogic.BXCanonical.Chronicle
