import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleTypes
import Bimodal.Metalogic.BXCanonical.Chronicle.RRelation
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

### Withdrawn (Phase 3, Task 107)

- `lemma_2_6_strong`: FALSE under strict semantics (g_content(D) <= C unprovable)
- `lemma_2_7`: FALSE under strict semantics (D2 branch cannot produce xi at future MCS)
- `lemma_2_8`: Depends on `lemma_2_7`; also has false D2-style reasoning

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

/-- If H(φ) ∉ MCS A, then P(¬φ) ∈ A.

Dual of `F_neg_of_G_not`. Proof: H(φ) ∉ A. Suppose H(¬¬φ) ∈ A.
By past necessitation of DNE and past_k_dist, H(¬¬φ) → H(φ).
So H(φ) ∈ A, contradiction. Therefore H(¬¬φ) ∉ A, i.e.,
¬H(¬¬φ) ∈ A = P(¬φ) ∈ A. -/
theorem P_neg_of_H_not {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (φ : Formula)
    (h_Hφ_not : Formula.all_past φ ∉ A) :
    Formula.some_past φ.neg ∈ A := by
  -- Show H(¬¬φ) ∉ A
  have h_H_nnφ_not : Formula.all_past φ.neg.neg ∉ A := by
    intro h_H_nnφ
    have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    have h_H_dne : DerivationTree [] (Formula.all_past (φ.neg.neg.imp φ)) :=
      Bimodal.Theorems.past_necessitation _ h_dne
    have h_kd : DerivationTree [] ((φ.neg.neg.imp φ).all_past.imp
        (φ.neg.neg.all_past.imp φ.all_past)) :=
      Bimodal.Theorems.past_k_dist φ.neg.neg φ
    have h1 := theorem_in_mcs h_mcs h_H_dne
    have h2 := theorem_in_mcs h_mcs h_kd
    have h3 := SetMaximalConsistent.implication_property h_mcs h2 h1
    have h_Hφ := SetMaximalConsistent.implication_property h_mcs h3 h_H_nnφ
    exact h_Hφ_not h_Hφ
  -- ¬H(¬¬φ) ∈ A by negation completeness
  rcases SetMaximalConsistent.negation_complete h_mcs
      (Formula.all_past φ.neg.neg) with h | h
  · exact absurd h h_H_nnφ_not
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

/-!
**`lemma_2_6_strong` withdrawn**: The conclusion `g_content(D) ⊆ C` is **false**
under strict (irreflexive) semantics. Under reflexive semantics, `g_content(M) ⊆ M`
for all MCS M (the T-axiom `Gφ → φ`), which makes the "between" property provable.
Under strict semantics this fails: `G(φ) ∈ A` does NOT imply `φ ∈ A`.

The non-strong `lemma_2_6` (which provides `¬δ ∈ D` and `g_content(A) ⊆ D` without
the `g_content(D) ⊆ C` conclusion) suffices for C4 counterexample elimination.
The between-point structure is provided by the chronicle's g-function and C3,
not by individual lemma conclusions. See Phase 4 of the implementation plan.
-/

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

/-!
### Withdrawn Lemmas

**`lemma_2_7` withdrawn** (Phase 3, Task 107): The original statement

  `U(xi, eta) in A, g_content(A) subset C, eta not in C ==> exists D, MCS D, xi in D, g_content(A) subset D`

is **false under strict (irreflexive) semantics**. The BX7 three-way case split produces:

- **D1**: `U(_, eta AND neg eta)` -- absurd (F(contradiction) impossible in MCS). Proven.
- **D2**: `U(_, eta AND top)` -- the witness has eta but NOT xi. Under strict semantics,
  g_content does not propagate Until formulas, so the guard xi cannot be transferred to
  a future MCS via g_content alone. Counterexample: on Z with strict `<`, let xi be true
  only at time 0, eta true everywhere except 0, `U(xi, eta)` at 0 with witness at 1.
  No future MCS contains xi.
- **D3**: `U(_, (xi AND U(xi,eta)) AND neg eta)` -- produces `F((xi AND U(xi,eta)) AND neg eta)`,
  from which a future MCS D with xi follows via Lindenbaum extension. Proven sorry-free.

The D3 case is the only sound branch. Phase 4 (C5 elimination) uses the D3 proof
pattern directly by checking the BX7 disjunction at each inductive step and routing
through the D3 branch. The D3 proof code is self-contained and does not reference D2.

**`lemma_2_6_strong` withdrawn** (Phase 3, Task 107): The conclusion
`g_content(D) subset C` is false under strict semantics. See note above `lemma_2_7_guard`.

**`lemma_2_8` withdrawn** (Phase 3, Task 107): The eta-not-in-C case called `lemma_2_7`
directly, and the eta-in-C case had its own false D2-style reasoning. With both
`lemma_2_7` and `lemma_2_6_strong` withdrawn, `lemma_2_8` has no correct foundation.

### Available Building Blocks for Phase 4

The following sorry-free lemmas remain available for C5 elimination:

- `lemma_2_4`: Until witness endpoint construction (beta, g_content(A), P(U(gamma,beta)))
- `lemma_2_6`: Negative insertion (neg delta in D, g_content(A) subset D)
- `lemma_2_5b`: g_content ordering transitivity
- `lemma_2_7_guard`: Guard extraction (U(xi,eta) in A, eta not in A ==> xi in A)
- `conj_left_mcs`, `conj_right_mcs`: Conjunction component extraction
- `conj_mcs`: Conjunction introduction in MCS
- `until_elim_mcs`: BX9 at MCS level (U(gamma,beta) ==> gamma or beta)
- `until_F_mcs`: BX10 at MCS level (U(gamma,beta) ==> F(beta))
- `self_accum_until_mcs`: BX5 at MCS level (U(gamma,beta) ==> U(gamma AND U(gamma,beta), beta))
- `connect_future_mcs`: BX4 at MCS level (phi ==> G(P(phi)))
- `F_neg_of_G_not`: G(phi) not in A ==> F(neg phi) in A

Phase 4 will inline the D3 case proof using these building blocks, applying BX7 with
appropriate formulas and handling only the D1 (absurd) and D3 (witness) branches,
with an additional hypothesis or case analysis that ensures D2 does not arise.
-/

/-! ## G/H Implies F/P (Seriality + BX3 + BX10/BX12)

Key lemma for g_content chain property: G(α) in an MCS implies F(α) in the same MCS.
This is NOT immediate under irreflexive semantics (there is no axiom G(α) → α),
but it IS derivable using seriality, BX3 (right monotonicity), BX10, and BX12.

Proof sketch: G(α) → G(⊤ → α)   (weakening under G, via temporal necessitation)
              F(⊤) → (⊤ U ⊤)    (BX12, seriality gives F(⊤))
              G(⊤ → α) → ((⊤ U ⊤) → (⊤ U α))  (BX3)
              (⊤ U α) → F(α)    (BX10)
-/

/-- In an MCS, G(α) implies F(α). Uses seriality + BX3 + BX10 + BX12. -/
theorem G_implies_F_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (α : Formula)
    (h_G : Formula.all_future α ∈ A) :
    Formula.some_future α ∈ A := by
  -- Step 1: G(⊤ �� α) ∈ A from G(α)
  -- ⊢ α → (⊤ → α) by prop_s
  set top := Formula.bot.imp Formula.bot with top_def
  have h_weak : DerivationTree [] (Formula.imp α (Formula.imp top α)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s α top)
  have h_G_top_α : Formula.all_future (Formula.imp top α) ∈ A := by
    have h1 := theorem_in_mcs h_mcs (DerivationTree.temporal_necessitation _ h_weak)
    have h2 := theorem_in_mcs h_mcs
      (DerivationTree.axiom [] _ (Axiom.temp_k_dist α (Formula.imp top α)))
    exact SetMaximalConsistent.implication_property h_mcs
      (SetMaximalConsistent.implication_property h_mcs h2 h1) h_G
  -- Step 2: F(⊤) ∈ A by seriality
  have h_top_in : top ∈ A :=
    theorem_in_mcs h_mcs (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_F_top : Formula.some_future top ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.serial_future)) h_top_in
  -- Step 3: (⊤ U ⊤) ∈ A by BX12
  have h_TUT : Formula.untl top top ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.F_until_equiv top))) h_F_top
  -- Step 4: (⊤ U α) ∈ A by BX3: G(⊤ → α) → ((⊤ U ⊤) → (⊤ U α))
  have h_TUα : Formula.untl top α ∈ A := by
    have h1 := SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.right_mono_until top α top)))
      h_G_top_α
    exact SetMaximalConsistent.implication_property h_mcs h1 h_TUT
  -- Step 5: F(α) ∈ A by BX10
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.until_F top α))) h_TUα

/-- In an MCS, H(α) implies P(α). Mirror of G_implies_F_mcs using past axioms. -/
theorem H_implies_P_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (α : Formula)
    (h_H : Formula.all_past α ∈ A) :
    Formula.some_past α ∈ A := by
  set top := Formula.bot.imp Formula.bot with top_def
  -- H(⊤ → α) ∈ A
  have h_weak : DerivationTree [] (Formula.imp α (Formula.imp top α)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s α top)
  have h_H_top_α : Formula.all_past (Formula.imp top α) ∈ A := by
    have h1 := theorem_in_mcs h_mcs (Bimodal.Theorems.past_necessitation _ h_weak)
    have h2 := theorem_in_mcs h_mcs (Bimodal.Theorems.past_k_dist α (Formula.imp top α))
    exact SetMaximalConsistent.implication_property h_mcs
      (SetMaximalConsistent.implication_property h_mcs h2 h1) h_H
  -- P(⊤) ∈ A by seriality
  have h_top_in : top ∈ A :=
    theorem_in_mcs h_mcs (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_P_top : Formula.some_past top ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.serial_past)) h_top_in
  -- (⊤ S ⊤) ∈ A by BX12'
  have h_TST : Formula.snce top top ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.P_since_equiv top))) h_P_top
  -- BX3': H(⊤ → α) → ((⊤ S ⊤) → (⊤ S α))
  have h_TSα : Formula.snce top α ∈ A := by
    have h1 := SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.right_mono_since top α top)))
      h_H_top_α
    exact SetMaximalConsistent.implication_property h_mcs h1 h_TST
  -- BX10': (⊤ S α) → P(α)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.since_P top α))) h_TSα

/--
G-propagation seed consistency: if G(α) ∈ MCS A, then {α} ∪ g_content(A) is consistent.

Proof: G(α) → F(α) (by `G_implies_F_mcs`), then apply `forward_temporal_witness_seed_consistent`.
-/
theorem g_propagation_seed_consistent {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (α : Formula)
    (h_G : Formula.all_future α ∈ A) :
    SetConsistent (forward_temporal_witness_seed A α) := by
  exact forward_temporal_witness_seed_consistent A h_mcs α (G_implies_F_mcs h_mcs α h_G)

/--
G-propagation insertion: given G(α) ∈ f(x) (an MCS), produce an MCS D with α ∈ D
and g_content(f(x)) ⊆ D.

This is the key building block for G-propagation counterexample elimination.
-/
noncomputable def g_propagation_witness {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (α : Formula)
    (h_G : Formula.all_future α ∈ A) :
    ∃ D : Set Formula, SetMaximalConsistent D ∧ α ∈ D ∧ g_content A ⊆ D := by
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ (g_propagation_seed_consistent h_mcs α h_G)
  exact ⟨D, h_D_mcs,
    h_sup (Set.mem_union_left _ (Set.mem_singleton _)),
    fun χ hχ => h_sup (Set.mem_union_right _ hχ)⟩

/-! ## Seed Consistency for DCS Extension

Helper lemma: if S is a DCS and phi not in S, then {neg phi} union S is consistent.
Used in the full Lemma 2.6 below.
-/

/--
If S is a DCS and φ ∉ S, then {φ.neg} ∪ S is consistent.

Proof: If inconsistent, then L ⊆ {φ.neg} ∪ S derives bot. Filter out φ.neg
to get L' ⊆ S. By weakening, (φ.neg :: L') ⊢ bot. By deduction theorem,
L' ⊢ φ.neg.neg. By DCS closure, φ.neg.neg ∈ S. By DNE, φ ∈ S. Contradiction.
-/
theorem dcs_neg_union_consistent {S : Set Formula} (h_dcs : SetDeductivelyClosed S)
    {φ : Formula} (h_not : φ ∉ S) :
    SetConsistent ({φ.neg} ∪ S) := by
  intro L hL ⟨d⟩
  apply h_not
  -- L ⊆ {φ.neg} ∪ S and L ⊢ bot. We derive φ ∈ S.
  -- Key idea: weaken L to (φ.neg :: L') where L' = S-elements of L.
  -- By deduction theorem: L' ⊢ φ.neg.neg. By DCS + DNE: φ ∈ S.
  by_cases h_neg_in_L : φ.neg ∈ L
  · -- φ.neg ∈ L.
    -- Weaken L to (φ.neg :: L): trivially L ⊆ φ.neg :: L
    have d_ext : DerivationTree (φ.neg :: L) Formula.bot :=
      DerivationTree.weakening L (φ.neg :: L) Formula.bot d (List.subset_cons_of_subset _ (List.Subset.refl L))
    -- By deduction theorem: L ⊢ φ.neg → bot = φ.neg.neg
    have d_imp : DerivationTree L φ.neg.neg :=
      deduction_theorem L φ.neg Formula.bot d_ext
    -- All of L is in {φ.neg} ∪ S. Elements equal to φ.neg: skip.
    -- Elements not equal to φ.neg: in S.
    -- But we need ALL of L in S for DCS closure.
    -- Actually, weaken further: remove all φ.neg from L.
    -- Use weakening the other direction: from L ⊢ bot, since φ.neg ∈ L,
    -- we have (φ.neg :: L) ⊢ bot. By deduction theorem: L ⊢ φ.neg.neg.
    -- But L might contain φ.neg itself. We need L_S (S-elements only).
    -- Approach: from L ⊢ φ.neg.neg (proved above), filter out φ.neg elements.
    -- All non-φ.neg elements of L are in S. The derivation still works because
    -- we can weaken from L_filtered to L (adding φ.neg back won't help, but
    -- φ.neg ∈ S or φ.neg ∉ S doesn't matter because we derive φ.neg.neg).
    -- Actually, let's just sorry this step and focus on the structure.
    -- From d_imp (L ⊢ φ.neg.neg) and DNE, derive L ⊢ φ
    have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    have d_phi : DerivationTree L φ :=
      DerivationTree.modus_ponens L φ.neg.neg φ
        (DerivationTree.weakening [] L (φ.neg.neg.imp φ) h_dne (List.nil_subset L)) d_imp
    -- Let M = L.filter (· ≠ φ.neg), the S-elements of L
    set M := L.filter (fun x => !decide (x = φ.neg)) with hM_def
    have hM_sub_S : ∀ ψ ∈ M, ψ ∈ S := by
      intro ψ hψ; rw [hM_def] at hψ
      have h_mem := List.mem_filter.mp hψ
      have h1 : ψ ∈ L := h_mem.1
      have h2 : ψ ≠ φ.neg := by simp at h_mem; exact h_mem.2
      rcases hL ψ h1 with h_sing | h_S
      · exact absurd (Set.mem_singleton_iff.mp h_sing) h2
      · exact h_S
    have hL_sub : L ⊆ φ.neg :: M := by
      intro x hx
      by_cases heq : x = φ.neg
      · subst heq; exact .head M
      · exact .tail _ (List.mem_filter.mpr ⟨hx, by simp; exact heq⟩)
    have d_phi_w : DerivationTree (φ.neg :: M) φ :=
      DerivationTree.weakening L (φ.neg :: M) φ d_phi hL_sub
    have d_neg_imp : DerivationTree M (φ.neg.imp φ) :=
      deduction_theorem M φ.neg φ d_phi_w
    -- Peirce: [] ⊢ (φ.neg → φ) → φ
    have h_peirce : DerivationTree [] ((φ.neg.imp φ).imp φ) := by
      have s1 : DerivationTree [φ.neg, φ.neg.imp φ] φ :=
        DerivationTree.modus_ponens [φ.neg, φ.neg.imp φ] φ.neg φ
          (DerivationTree.assumption _ (φ.neg.imp φ) (by simp))
          (DerivationTree.assumption _ φ.neg (by simp))
      have s2 : DerivationTree [φ.neg, φ.neg.imp φ] Formula.bot :=
        DerivationTree.modus_ponens [φ.neg, φ.neg.imp φ] φ Formula.bot
          (DerivationTree.assumption _ φ.neg (by simp)) s1
      have s3 := deduction_theorem [φ.neg.imp φ] φ.neg Formula.bot s2
      have s4 : DerivationTree [φ.neg.imp φ] φ :=
        DerivationTree.modus_ponens [φ.neg.imp φ] φ.neg.neg φ
          (DerivationTree.weakening [] [φ.neg.imp φ] (φ.neg.neg.imp φ) h_dne (List.nil_subset _)) s3
      exact deduction_theorem [] (φ.neg.imp φ) φ s4
    -- MP: M ⊢ φ
    have d_phi_M : DerivationTree M φ :=
      DerivationTree.modus_ponens M (φ.neg.imp φ) φ
        (DerivationTree.weakening [] M ((φ.neg.imp φ).imp φ) h_peirce (List.nil_subset M)) d_neg_imp
    -- DCS closure: M ⊆ S and M ⊢ φ gives φ ∈ S
    exact h_dcs.2 M φ hM_sub_S d_phi_M
  · -- φ.neg ∉ L, so all elements of L are in S
    have hL_S : ∀ ψ ∈ L, ψ ∈ S := by
      intro ψ hψ
      have h_mem := hL ψ hψ
      rcases h_mem with h_sing | h_S
      · -- ψ ∈ {φ.neg}, so ψ = φ.neg
        have : ψ = φ.neg := Set.mem_singleton_iff.mp h_sing
        exact absurd (this ▸ hψ) h_neg_in_L
      · exact h_S
    exact absurd (h_dcs.1 L hL_S ⟨d⟩) (not_false)

/-! ## R3Maximal Negation Completeness

Key property: R3Maximal DCS have a weak form of negation completeness.
If δ ∉ B and R3Maximal(A, B, C), then ¬δ ∈ B.

This follows from maximality: if ¬δ ∉ B, then {¬δ} ∪ B is consistent
(by dcs_neg_union_consistent since δ ∉ B), and deductiveClosure({¬δ} ∪ B)
properly extends B while preserving r3Relation(A, -, C). This contradicts
the maximality of B.
-/

/--
**R3Maximal negation completeness**: If B is R3Maximal(A, B, C) and δ ∉ B,
then δ.neg ∈ B.

This is the key lemma that makes the C4 hard case provable: when
R3Maximal(f(x), g(x,y), f(y)) and δ ∉ g(x,y), we get ¬δ ∈ g(x,y),
which gives ¬δ at any intermediate point z (by C3: g(x,y) ⊆ f(z)).
-/
theorem r3Maximal_neg_of_not_mem {A B C : Set Formula}
    (h_R3 : R3Maximal A B C) (δ : Formula) (h_not : δ ∉ B) :
    δ.neg ∈ B := by
  by_contra h_neg_not
  -- ¬δ ∉ B and δ ∉ B. Show deductiveClosure({¬δ} ∪ B) properly extends B
  -- and satisfies r3Relation, contradicting R3Maximal.
  -- Step 1: {¬δ} ∪ B is consistent (since δ ∉ B and B is DCS)
  have h_cons := dcs_neg_union_consistent h_R3.1 h_not
  -- Step 2: deductiveClosure({¬δ} ∪ B) is a DCS
  have h_dc_dcs := deductiveClosure_is_dcs h_cons
  -- Step 3: B ⊆ deductiveClosure({¬δ} ∪ B)
  have h_B_sub : B ⊆ deductiveClosure ({δ.neg} ∪ B) :=
    fun φ hφ => subset_deductiveClosure _ (Set.mem_union_right _ hφ)
  -- Step 4: ¬δ ∈ deductiveClosure({¬δ} ∪ B) but ¬δ ∉ B, so proper extension
  have h_neg_in : δ.neg ∈ deductiveClosure ({δ.neg} ∪ B) :=
    subset_deductiveClosure _ (Set.mem_union_left _ (Set.mem_singleton δ.neg))
  have h_proper : B ⊂ deductiveClosure ({δ.neg} ∪ B) :=
    ⟨h_B_sub, fun h_eq => h_neg_not (h_eq h_neg_in)⟩
  -- Step 5: r3Relation(A, deductiveClosure({¬δ} ∪ B), C) holds
  -- by monotonicity: B ⊆ ext and r3Relation(A, B, C)
  have h_r3 : r3Relation A (deductiveClosure ({δ.neg} ∪ B)) C :=
    r3Relation_subset h_R3.2.1 h_B_sub
  -- Step 6: Contradiction with R3Maximal
  exact h_R3.2.2 _ h_dc_dcs h_proper h_r3

/-! ## R3Maximal Forces MCS (Key Discovery)

The codebase's r3Relation is **monotone** in B: if r3Relation(A, B, C) and B ⊆ B',
then r3Relation(A, B', C) (by `r3Relation_subset`). This is because rRelation and
rRelationSince only require membership conditions (δ ∈ B or γ ∈ B ∧ ...), which
are preserved by supersets.

Combined with R3Maximal (which says no proper DCS extension of B satisfies r3Relation),
this forces B to be an MCS: any non-MCS DCS B has a proper DCS extension
(via `dcs_neg_union_consistent` + `deductiveClosure_is_dcs`), and that extension
would satisfy r3Relation by monotonicity, contradicting R3Maximal.

This simplifies Lemma 2.6 dramatically: since B is an MCS, δ ∉ B implies ¬δ ∈ B
by negation completeness, and we can set D = B' = B'' = B.

**Note**: This is a departure from Burgess's formalization where r(A, B, C) uses
the Burgess r-relation (content-based: ∀β∈B, ∀γ∈C, (β U γ)∈A), which is NOT
monotone in B. The codebase's r3Relation is obligation-propagation-based, which
happens to be monotone. Burgess's R-maximality produces genuinely non-MCS DCS;
the codebase's R3Maximal collapses to MCS.
-/

/--
**R3Maximal forces MCS**: Any DCS B that is R3-maximal between MCS A and C
must itself be a maximal consistent set.

The proof exploits monotonicity of r3Relation: for any formula φ ∉ B,
`dcs_neg_union_consistent` gives a consistent seed {φ.neg} ∪ B, whose
deductive closure is a proper DCS extension of B that still satisfies
r3Relation(A, -, C) by `r3Relation_subset`. This contradicts R3Maximal.
-/
theorem R3Maximal_is_mcs {A B C : Set Formula}
    (h_R3 : R3Maximal A B C) : SetMaximalConsistent B := by
  refine ⟨h_R3.1.1, ?_⟩
  intro φ h_not_φ h_cons_insert
  have h_cons : SetConsistent ({φ} ∪ B) := by rwa [Set.insert_eq] at h_cons_insert
  have h_dc_dcs := deductiveClosure_is_dcs h_cons
  have h_B_sub : B ⊆ deductiveClosure ({φ} ∪ B) :=
    fun ψ hψ => subset_deductiveClosure _ (Set.mem_union_right _ hψ)
  have h_φ_in : φ ∈ deductiveClosure ({φ} ∪ B) :=
    subset_deductiveClosure _ (Set.mem_union_left _ (Set.mem_singleton φ))
  exact h_R3.2.2 _ h_dc_dcs ⟨h_B_sub, fun h_eq => h_not_φ (h_eq h_φ_in)⟩
    (r3Relation_subset h_R3.2.1 h_B_sub)

/-- An MCS has no proper DCS extension (any DCS extending an MCS is inconsistent
    or equal to it). Used for R3Maximal closure. -/
theorem mcs_no_proper_dcs_extension {B D : Set Formula}
    (h_mcs : SetMaximalConsistent B) (h_dcs : SetDeductivelyClosed D)
    (hBD : B ⊂ D) : False := by
  obtain ⟨φ, h_φ_D, h_φ_not_B⟩ := Set.not_subset.mp hBD.2
  have h_incons := h_mcs.2 φ h_φ_not_B
  apply h_incons
  intro L hL ⟨d⟩
  exact h_dcs.1 L (fun ψ hψ => (Set.insert_subset h_φ_D hBD.1) (hL ψ hψ)) ⟨d⟩

/-- rRelation is reflexive for MCS: any Until formula γ U δ in B has either
    δ ∈ B or (γ ∈ B ∧ γ U δ ∈ B), which follows from BX9 and MCS completeness. -/
theorem rRelation_self_mcs {B : Set Formula}
    (h_mcs : SetMaximalConsistent B) : rRelation B B := by
  intro γ δ h_until
  rcases SetMaximalConsistent.negation_complete h_mcs γ with h_γ | h_neg_γ
  · exact Or.inr ⟨h_γ, h_until⟩
  · exact Or.inl (SetMaximalConsistent.implication_property h_mcs
      (until_disjunction_in_mcs h_mcs h_until) h_neg_γ)

/-- rRelationSince is reflexive for MCS: mirror of rRelation_self_mcs using BX9'. -/
theorem rRelationSince_self_mcs {B : Set Formula}
    (h_mcs : SetMaximalConsistent B) : rRelationSince B B := by
  intro γ δ h_since
  rcases SetMaximalConsistent.negation_complete h_mcs γ with h_γ | h_neg_γ
  · exact Or.inr ⟨h_γ, h_since⟩
  · exact Or.inl (SetMaximalConsistent.implication_property h_mcs
      (since_disjunction_in_mcs h_mcs h_since) h_neg_γ)

/-! ## Full Lemma 2.6: Three-Way Decomposition (Burgess 1982)

The full Lemma 2.6 is the key to C4 counterexample elimination with g-value tracking.
Given R3Maximal(A, B, C) and delta not in B, it produces a three-way decomposition:
- MCS D with neg(delta) in D
- R3Maximal(A, B', D) with B subset B'
- R3Maximal(D, B'', C) with B subset B''

**Proof strategy (simplified by R3Maximal_is_mcs)**:

Since r3Relation is monotone in B (via r3Relation_subset), R3Maximal forces B to
be an MCS. Therefore delta not in B implies neg(delta) in B by MCS negation
completeness. Setting D = B' = B'' = B satisfies all conditions:
- neg(delta) in D = B (negation completeness)
- B subset D = B (reflexivity)
- R3Maximal(A, B, B) (rRelation from original, rRelationSince reflexive, MCS maximality)
- R3Maximal(B, B, C) (rRelation reflexive, rRelationSince from original, MCS maximality)

This bypasses the need for Burgess's axiom A4a entirely, since the codebase's
R3Maximal is a stronger condition than Burgess's (forcing B to be an MCS rather
than merely a maximal DCS in the Burgess r-relation sense).
-/

/--
**Full Lemma 2.6** (Burgess 1982): Three-way decomposition.

Given R3Maximal(A, B, C) and δ ∉ B, produces:
- MCS D with ¬δ ∈ D
- B ⊆ D, B ⊆ B', B ⊆ B''
- R3Maximal(A, B', D) and R3Maximal(D, B'', C)

The proof is simplified by the discovery that R3Maximal forces B to be an MCS
(see `R3Maximal_is_mcs`). All witnesses are B itself.
-/
noncomputable def lemma_2_6_full {A C : Set Formula}
    (_h_mcs_A : SetMaximalConsistent A)
    (_h_mcs_C : SetMaximalConsistent C)
    {B : Set Formula}
    (h_R3 : R3Maximal A B C)
    (δ : Formula)
    (h_δ_not_B : δ ∉ B) :
    ∃ (D B' B'' : Set Formula),
      SetMaximalConsistent D ∧
      δ.neg ∈ D ∧
      B ⊆ D ∧
      B ⊆ B' ∧
      B ⊆ B'' ∧
      R3Maximal A B' D ∧
      R3Maximal D B'' C := by
  -- Key insight: R3Maximal forces B to be an MCS (r3Relation is monotone in B)
  have h_mcs_B := R3Maximal_is_mcs h_R3
  -- δ ∉ B implies δ.neg ∈ B by MCS negation completeness
  have h_neg_δ : δ.neg ∈ B := by
    rcases SetMaximalConsistent.negation_complete h_mcs_B δ with h | h
    · exact absurd h h_δ_not_B
    · exact h
  -- Set D = B, B' = B, B'' = B
  have h_dcs := mcs_is_dcs h_mcs_B
  refine ⟨B, B, B, h_mcs_B, h_neg_δ, le_refl _, le_refl _, le_refl _, ?_, ?_⟩
  · -- R3Maximal A B B: rRelation from original R3Maximal, rRelationSince reflexive
    exact ⟨h_dcs, ⟨h_R3.2.1.1, rRelationSince_self_mcs h_mcs_B⟩,
      fun D hD_dcs hBD _ => mcs_no_proper_dcs_extension h_mcs_B hD_dcs hBD⟩
  · -- R3Maximal B B C: rRelation reflexive, rRelationSince from original R3Maximal
    exact ⟨h_dcs, ⟨rRelation_self_mcs h_mcs_B, h_R3.2.1.2⟩,
      fun D hD_dcs hBD _ => mcs_no_proper_dcs_extension h_mcs_B hD_dcs hBD⟩

end Bimodal.Metalogic.BXCanonical.Chronicle
