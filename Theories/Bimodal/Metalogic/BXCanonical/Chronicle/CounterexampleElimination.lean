import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleTypes
import Bimodal.Metalogic.BXCanonical.Chronicle.RRelation
import Bimodal.Metalogic.BXCanonical.Chronicle.PointInsertion
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Data.Finset.Max
import Mathlib.Tactic.Linarith

/-!
# Counterexample Elimination (Burgess 2.9-2.10)

This module implements the key step of the Burgess chronicle construction:
given a chronicle satisfying C0, eliminate individual C5/C5' counterexamples
by inserting new points into the domain.

## Main Results

- `C5Counterexample` / `C5'Counterexample`: Structures representing missing
  Until/Since witnesses.

- `eliminate_C5_counterexample`: (Lemma 2.10) Given x in dom with xi U eta in f(x)
  but no Until witness, extend the chronicle with a new point y such that
  eta in f'(y).

- `eliminate_C5'_counterexample`: Mirror for Since counterexamples.

- `PotentialCounterexample` / `eliminate_potential_counterexample`: Uniform
  interface for the omega-chain construction.

## References

- Burgess 1982: "Axioms for tense logic II: Time periods", Section 2
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/-! ## C5/C5' Counterexample Structures -/

/--
A **C5 counterexample** for a chronicle: a point x and formulas xi, eta such that
xi U eta in f(x) but no witness exists in the current domain.
-/
structure C5Counterexample (χ : Chronicle) where
  x : Rat
  x_mem : x ∈ χ.dom
  ξ : Formula
  η : Formula
  until_mem : Formula.untl ξ η ∈ χ.f x
  no_witness : ¬∃ y ∈ χ.dom, x < y ∧ η ∈ χ.f y ∧
    ∀ z ∈ χ.dom, x < z → z < y → ξ ∈ χ.f z ∧ Formula.untl ξ η ∈ χ.f z

/--
A **C5' counterexample** (Since direction): a point x and formulas xi, eta such that
xi S eta in f(x) but no backward witness exists.
-/
structure C5'Counterexample (χ : Chronicle) where
  x : Rat
  x_mem : x ∈ χ.dom
  ξ : Formula
  η : Formula
  since_mem : Formula.snce ξ η ∈ χ.f x
  no_witness : ¬∃ y ∈ χ.dom, y < x ∧ η ∈ χ.f y ∧
    ∀ z ∈ χ.dom, y < z → z < x → ξ ∈ χ.f z ∧ Formula.snce ξ η ∈ χ.f z

/-! ## Helper: Finding Fresh Rationals -/

/--
There exists a rational strictly greater than all elements of a finite set
of rationals. (The rationals are unbounded above.)
-/
theorem exists_rat_gt_finset (S : Finset Rat) :
    ∃ q : Rat, (∀ s ∈ S, s < q) ∧ q ∉ S := by
  by_cases h : S.Nonempty
  · refine ⟨S.max' h + 1, ?_, ?_⟩
    · intro s hs
      calc s ≤ S.max' h := Finset.le_max' S s hs
        _ < S.max' h + 1 := lt_add_one _
    · intro hmem
      have h1 := Finset.le_max' S _ hmem
      linarith
  · rw [Finset.not_nonempty_iff_eq_empty] at h
    subst h
    exact ⟨0, fun s hs => absurd hs (Finset.not_mem_empty s), Finset.not_mem_empty 0⟩

/--
There exists a rational strictly less than all elements of a finite set
of rationals. (The rationals are unbounded below.)
-/
theorem exists_rat_lt_finset (S : Finset Rat) :
    ∃ q : Rat, (∀ s ∈ S, q < s) ∧ q ∉ S := by
  by_cases h : S.Nonempty
  · refine ⟨S.min' h - 1, ?_, ?_⟩
    · intro s hs
      calc S.min' h - 1 < S.min' h := sub_one_lt _
        _ ≤ s := Finset.min'_le S s hs
    · intro hmem
      have h1 := Finset.min'_le S _ hmem
      linarith
  · rw [Finset.not_nonempty_iff_eq_empty] at h
    subst h
    exact ⟨0, fun s hs => absurd hs (Finset.not_mem_empty s), Finset.not_mem_empty 0⟩

/--
There exists a rational strictly between x and y that is NOT in a finite set S.
Since S is finite and Q is dense, the open interval (x,y) is infinite while
S ∩ (x,y) is finite, so there must be a point outside S.

We construct it explicitly: take z = (x + y) / 2. If z ∉ S, done. Otherwise,
the interval (x, z) still has no elements of S strictly between x and z that
block finding a midpoint — but we use a simpler argument: among the finitely
many points of S in [x,y], there must be a gap, and the midpoint of that gap
works. We use the simpler approach: (x + y) / 2 works when Adjacent, and for
the general case we find any gap in the finite set S within (x,y).
-/
theorem exists_rat_between_not_in_finset (S : Finset Rat) (x y : Rat) (hxy : x < y) :
    ∃ z : Rat, x < z ∧ z < y ∧ z ∉ S := by
  -- The set of S-elements strictly between x and y
  set T := S.filter (fun s => x < s ∧ s < y) with hT_def
  by_cases hT : T.Nonempty
  · -- There are S-elements between x and y. Find the minimum, take midpoint with x.
    set t := T.min' hT with ht_def
    have ht_mem : t ∈ T := Finset.min'_mem T hT
    have ht_prop : x < t ∧ t < y := by
      rw [hT_def] at ht_mem; exact (Finset.mem_filter.mp ht_mem).2
    -- z = (x + t) / 2 is strictly between x and t, hence between x and y
    set z := (x + t) / 2 with hz_def
    have hxz : x < z := by linarith
    have hzt : z < t := by linarith
    have hzy : z < y := lt_trans hzt ht_prop.2
    refine ⟨z, hxz, hzy, ?_⟩
    -- z ∉ S because z < t = min of S-elements in (x,y), and z > x
    intro hz_mem
    have hz_in_T : z ∈ T := by
      rw [hT_def]; exact Finset.mem_filter.mpr ⟨hz_mem, hxz, hzy⟩
    have : t ≤ z := Finset.min'_le T z hz_in_T
    linarith
  · -- No S-elements between x and y. Midpoint works.
    rw [Finset.not_nonempty_iff_eq_empty] at hT
    set z := (x + y) / 2 with hz_def
    have hxz : x < z := by linarith
    have hzy : z < y := by linarith
    refine ⟨z, hxz, hzy, ?_⟩
    intro hz_mem
    have : z ∈ T := by
      rw [hT_def]; exact Finset.mem_filter.mpr ⟨hz_mem, hxz, hzy⟩
    rw [hT] at this
    exact Finset.not_mem_empty z this

/-! ## BurgessR3Maximal Helper Lemmas -/

/--
**BurgessR3Maximal implies g_content subset**: If BurgessR3Maximal(A, B, C) holds with
A and C both MCS, then g_content(A) ⊆ C.

Proof: Suppose G(φ) ∈ A but φ ∉ C. Then φ.neg ∈ C (MCS). Since B is CUD, ⊤ ∈ B (a
theorem is in any CUD set). From burgessRSet(A, B, C): untl(⊤, φ.neg) ∈ A. By BX10
(until_F), F(φ.neg) ∈ A. But G(φ) ∈ A gives ¬F(φ.neg) ∈ A (by G = ¬F¬ equivalence
in MCS), contradicting consistency of A.
-/
theorem BurgessR3Maximal_g_content_sub {A B C : Set Formula}
    (h_r3m : BurgessR3Maximal A B C)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C) :
    g_content A ⊆ C := by
  intro φ hφ
  -- hφ : G(φ) ∈ A, i.e., all_future(φ) ∈ A
  change Formula.all_future φ ∈ A at hφ
  -- Suppose φ ∉ C, derive contradiction
  by_contra h_not_C
  have h_neg_C : φ.neg ∈ C := by
    rcases SetMaximalConsistent.negation_complete h_mcs_C φ with h | h
    · exact absurd h h_not_C
    · exact h
  -- ⊤ ∈ B (CUD contains all theorems)
  set top := Formula.bot.imp Formula.bot with top_def
  have h_top_B : top ∈ B :=
    cud_contains_theorems h_r3m.1 (Bimodal.Theorems.Combinators.identity Formula.bot)
  -- burgessRSet(A, B, C): ∀ β ∈ B, ∀ γ ∈ C, untl(β, γ) ∈ A
  have h_untl : Formula.untl top φ.neg ∈ A :=
    h_r3m.2.1.1 top h_top_B φ.neg h_neg_C
  -- BX10: untl(γ, δ) ∈ A → F(δ) ∈ A, here F(φ.neg) ∈ A
  have h_F_neg : Formula.some_future φ.neg ∈ A :=
    until_F_mcs h_mcs_A top φ.neg h_untl
  -- G(φ) ∈ A implies F(φ.neg) ∉ A
  -- F(φ.neg) = some_future(φ.neg) = (all_future(φ.neg.neg)).neg
  -- G(φ) ∈ A → G(φ.neg.neg) ∈ A (by φ → ¬¬φ inside G) → F(φ.neg) ∉ A
  -- Derive ⊢ φ → ¬¬φ, i.e., ⊢ φ → (φ.neg → ⊥)
  -- This is ⊢ φ → ((φ → ⊥) → ⊥), which follows from prop_s, prop_k, identity
  have h_dni : DerivationTree [] (φ.imp φ.neg.neg) := by
    -- φ.neg.neg = (φ.imp bot).imp bot
    -- Need: ⊢ φ → ((φ → ⊥) → ⊥)
    -- Proof: by deduction, assume φ.neg and φ, apply to get ⊥
    have h1 : DerivationTree [φ.neg, φ] Formula.bot :=
      DerivationTree.modus_ponens [φ.neg, φ] φ Formula.bot
        (DerivationTree.assumption _ φ.neg (by simp))
        (DerivationTree.assumption _ φ (by simp))
    have h2 : DerivationTree [φ] φ.neg.neg :=
      deduction_theorem [φ] φ.neg Formula.bot h1
    exact deduction_theorem [] φ φ.neg.neg h2
  -- G(φ → ¬¬φ) and temp_k_dist give G(φ) → G(¬¬φ)
  have h_G_dni : DerivationTree [] (Formula.all_future (φ.imp φ.neg.neg)) :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_kd : DerivationTree [] ((φ.imp φ.neg.neg).all_future.imp
      (φ.all_future.imp φ.neg.neg.all_future)) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist φ φ.neg.neg)
  have h1 := theorem_in_mcs h_mcs_A h_G_dni
  have h2 := theorem_in_mcs h_mcs_A h_kd
  have h3 := SetMaximalConsistent.implication_property h_mcs_A h2 h1
  have h_G_nn : Formula.all_future φ.neg.neg ∈ A :=
    SetMaximalConsistent.implication_property h_mcs_A h3 hφ
  -- all_future(φ.neg.neg) ∈ A and some_future(φ.neg) = (all_future(φ.neg.neg)).neg ∈ A
  -- contradicts MCS consistency
  exact absurd h_G_nn (SetMaximalConsistent.neg_excludes h_mcs_A (Formula.all_future φ.neg.neg) h_F_neg)

/--
**BurgessR3Maximal implies SetDeductivelyClosed**: If BurgessR3Maximal(A, B, C) holds with
A and C both MCS and NoUnivBurgessR3, then B is SetDeductivelyClosed (consistent + CUD).

Proof: B is CUD from BurgessR3Maximal definition. If B were inconsistent, then B contains
⊥ (CUD), so B contains every formula (ex falso), making B = Set.univ. But NoUnivBurgessR3
says ¬burgessR3(A, Set.univ, C), while BurgessR3Maximal gives burgessR3(A, B, C) =
burgessR3(A, Set.univ, C). Contradiction.
-/
theorem BurgessR3Maximal_sdc {A B C : Set Formula}
    (h_r3m : BurgessR3Maximal A B C)
    (h_nubr3 : NoUnivBurgessR3)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C) :
    SetDeductivelyClosed B := by
  refine ⟨?_, h_r3m.1⟩
  -- Show SetConsistent B
  intro L hL ⟨d⟩
  -- If B is inconsistent: ⊥ ∈ B (CUD), so everything is in B, hence B = Set.univ
  have h_bot_B : Formula.bot ∈ B := h_r3m.1 L Formula.bot hL d
  -- From ⊥ ∈ B (CUD): for any φ, ⊥ → φ is a theorem, so φ ∈ B
  have h_univ : ∀ φ : Formula, φ ∈ B := by
    intro φ
    have h_efq : DerivationTree [] (Formula.bot.imp φ) :=
      Bimodal.Theorems.Propositional.efq_axiom φ
    exact cud_modus_ponens h_r3m.1 (cud_contains_theorems h_r3m.1 h_efq) h_bot_B
  -- B = Set.univ
  have h_B_eq : B = Set.univ := Set.eq_univ_iff_forall.mpr h_univ
  -- burgessR3(A, B, C) = burgessR3(A, Set.univ, C), contradicting NoUnivBurgessR3
  exact h_nubr3 A C h_mcs_A h_mcs_C (h_B_eq ▸ h_r3m.2.1)

/--
Helper: for adjacent pairs in a chronicle satisfying c2', when inserting a new point
that splits an existing adjacent pair, the old adjacent pairs that don't involve the
split are preserved. Adjacent pairs involving the split point need BurgessR3Maximal
from lemma_2_6_splitting or lemma_2_7.
-/
theorem c2'_preserved_on_old_adjacent {χ χ' : Chronicle}
    (h_c2' : χ.c2')
    (h_f_agrees : ∀ x ∈ χ.dom, χ'.f x = χ.f x)
    (h_g_agrees : ∀ a b, a ∈ χ.dom → b ∈ χ.dom → χ'.g a b = χ.g a b)
    (h_dom_sub : χ.dom ⊆ χ'.dom)
    {a b : Rat}
    (h_adj' : Adjacent χ'.dom a b)
    (h_a_old : a ∈ χ.dom) (h_b_old : b ∈ χ.dom)
    (h_adj_old : Adjacent χ.dom a b) :
    BurgessR3Maximal (χ'.f a) (χ'.g a b) (χ'.f b) := by
  rw [h_f_agrees a h_a_old, h_g_agrees a b h_a_old h_b_old, h_f_agrees b h_b_old]
  exact h_c2' a b h_adj_old

/--
**BurgessR3Maximal from h_content subset (backward direction)**:
If h_content(C) ⊆ A (i.e., H(φ) ∈ C → φ ∈ A), then ∃ B, BurgessR3Maximal(A, B, C).

This is the backward mirror of `burgessR3Maximal_from_g_content_sub`:
- Forward: g_content(A) ⊆ C gives BurgessR3Maximal(A, _, C)
- Backward: h_content(C) ⊆ A gives BurgessR3Maximal(A, _, C)

Proof: Use η = ⊤ as the seed element.
- burgessR(A, ⊤, C): F(γ) ∈ A for all γ ∈ C.
  Proof: By BX4' (connect_past), γ → H(F(γ)), so γ ∈ C → H(F(γ)) ∈ C → F(γ) ∈ h_content(C) ⊆ A.
  Then F(γ) → U(⊤, γ) by F_until_equiv.
- burgessRSince(C, ⊤, A): P(α) ∈ C for all α ∈ A.
  Proof: If H(α.neg) ∈ C, then α.neg ∈ h_content(C) ⊆ A, contradicting α ∈ A. So P(α) ∈ C.
  Then P(α) → S(⊤, α) by P_since_equiv.
-/
theorem burgessR3Maximal_from_h_content_sub {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_hc : h_content C ⊆ A)
    (h_no_univ : ¬burgessR3 A Set.univ C) :
    ∃ B : Set Formula, BurgessR3Maximal A B C := by
  set top := Formula.bot.imp Formula.bot with top_def
  have h_top_A : top ∈ A :=
    theorem_in_mcs h_mcs_A (Bimodal.Theorems.Combinators.identity Formula.bot)
  -- burgessR(A, ⊤, C): ∀ γ ∈ C, U(⊤, γ) ∈ A
  have h_bR : burgessR A top C := by
    intro γ hγ
    -- BX4': γ → H(F(γ))
    have h_ax_cp : DerivationTree [] (γ.imp (Formula.all_past (Formula.some_future γ))) :=
      DerivationTree.axiom [] _ (Axiom.connect_past γ)
    have h_HF : Formula.all_past (Formula.some_future γ) ∈ C :=
      SetMaximalConsistent.implication_property h_mcs_C
        (theorem_in_mcs h_mcs_C h_ax_cp) hγ
    -- H(F(γ)) ∈ C → F(γ) ∈ h_content(C) ⊆ A
    have h_F : Formula.some_future γ ∈ A := h_hc h_HF
    -- F(γ) → U(⊤, γ) by F_until_equiv
    have h_bx12 : DerivationTree [] ((Formula.some_future γ).imp (Formula.untl top γ)) :=
      DerivationTree.axiom [] _ (Axiom.F_until_equiv γ)
    exact SetMaximalConsistent.implication_property h_mcs_A
      (theorem_in_mcs h_mcs_A h_bx12) h_F
  -- burgessRSince(C, ⊤, A): ∀ α ∈ A, S(⊤, α) ∈ C
  have h_bRS : burgessRSince C top A := by
    intro α hα
    -- If H(α.neg) ∈ C, then α.neg ∈ h_content(C) ⊆ A, contradicting α ∈ A
    have h_P : Formula.some_past α ∈ C := by
      by_contra h_not_P
      have h_H_neg : Formula.all_past α.neg ∈ C := by
        rcases SetMaximalConsistent.negation_complete h_mcs_C (Formula.all_past α.neg) with h | h
        · exact h
        · exact absurd h h_not_P
      have h_neg_A : α.neg ∈ A := h_hc h_H_neg
      exact SetMaximalConsistent.neg_excludes h_mcs_A α h_neg_A hα
    -- P(α) → S(⊤, α) by P_since_equiv
    have h_bx12' : DerivationTree [] ((Formula.some_past α).imp (Formula.snce top α)) :=
      DerivationTree.axiom [] _ (Axiom.P_since_equiv α)
    exact SetMaximalConsistent.implication_property h_mcs_C
      (theorem_in_mcs h_mcs_C h_bx12') h_P
  exact burgessR3Maximal_exists_from_seed A C top h_mcs_A h_mcs_C h_bR h_bRS h_top_A h_no_univ

/-! ## Lemma 2.10: C5 Counterexample Elimination -/

/--
**Lemma 2.10** (C5 Counterexample Elimination): Given a chronicle satisfying C0
and a C5 counterexample (x, xi, eta), extend the chronicle by adding a new point y
with eta in f'(y).

The construction uses Lemma 2.4 to obtain an MCS C with:
- eta in C (the Until eventuality is witnessed)
- g_content(f(x)) subset of C (temporal coherence)

The new point y is placed beyond all current domain points.
-/
noncomputable def eliminate_C5_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (ce : C5Counterexample χ)
    (h_nubr3 : NoUnivBurgessR3) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ x ∈ χ.dom, χ'.f x = χ.f x) ∧
      χ'.c0 ∧
      (∃ y ∈ χ'.dom, ce.x < y ∧ ce.η ∈ χ'.f y) ∧
      χ.dom ⊂ χ'.dom ∧
      (∀ a b, a ∈ χ.dom → b ∈ χ.dom → χ'.g a b = χ.g a b) ∧
      (∀ a b, χ'.g a b = χ.g a b) := by
  -- Step 1: Get a fresh point y > all domain points
  obtain ⟨y, hy_gt, hy_notin⟩ := exists_rat_gt_finset χ.dom
  -- Step 2: Use Lemma 2.4 to get an MCS with eta and g_content(f(x)), plus interval DCS B
  have h_mcs_x := h_c0 ce.x ce.x_mem
  obtain ⟨_B, C, h_C_mcs, h_η_C, _, _, _⟩ :=
    lemma_2_4 h_mcs_x ce.ξ ce.η ce.until_mem h_nubr3
  -- Step 3: Build the new chronicle
  -- f' agrees with f on old domain, assigns C to y
  -- g' is unchanged (placeholder; full interval assignment in ChronicleConstruction)
  refine ⟨⟨fun q => if q = y then C else χ.f q, χ.g, insert y χ.dom⟩,
    Finset.subset_insert y χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hy_notin,
    fun _ _ _ _ => rfl, fun _ _ => rfl⟩
  · -- f agrees on old points
    intro x hx
    have h_ne : x ≠ y := fun h => hy_notin (h ▸ hx)
    exact if_neg h_ne
  · -- C0
    intro x hx
    simp only [Finset.mem_insert] at hx
    rcases hx with rfl | hx
    · simp only [ite_true]; exact h_C_mcs
    · have h_ne : x ≠ y := fun h => hy_notin (h ▸ hx)
      simp only [h_ne, ite_false]; exact h_c0 x hx
  · -- Witness
    refine ⟨y, Finset.mem_insert_self y χ.dom, hy_gt ce.x ce.x_mem, ?_⟩
    simp only [ite_true]
    exact h_η_C

/--
**Lemma 2.10'** (C5' Counterexample Elimination): Mirror of Lemma 2.10 for Since.
Given a C5' counterexample (x, xi, eta), extend the chronicle by adding a new point
y < x with eta in f'(y).
-/
noncomputable def eliminate_C5'_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (ce : C5'Counterexample χ) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ x ∈ χ.dom, χ'.f x = χ.f x) ∧
      χ'.c0 ∧
      (∃ y ∈ χ'.dom, y < ce.x ∧ ce.η ∈ χ'.f y) ∧
      χ.dom ⊂ χ'.dom ∧
      (∀ a b, a ∈ χ.dom → b ∈ χ.dom → χ'.g a b = χ.g a b) ∧
      (∀ a b, χ'.g a b = χ.g a b) := by
  -- Step 1: Get a fresh point y < all domain points
  obtain ⟨y, hy_lt, hy_notin⟩ := exists_rat_lt_finset χ.dom
  -- Step 2: Construct MCS with eta via BX10' (since_P)
  have h_mcs_x := h_c0 ce.x ce.x_mem
  have h_P_η : Formula.some_past ce.η ∈ χ.f ce.x := by
    have h_ax : DerivationTree [] ((Formula.snce ce.ξ ce.η).imp (Formula.some_past ce.η)) :=
      DerivationTree.axiom [] _ (Axiom.since_P ce.ξ ce.η)
    exact SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x h_ax) ce.since_mem
  have h_seed := past_temporal_witness_seed_consistent (χ.f ce.x) h_mcs_x ce.η h_P_η
  obtain ⟨C, h_sup, h_C_mcs⟩ := set_lindenbaum _ h_seed
  have h_η_C : ce.η ∈ C := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
  -- Step 3: Build new chronicle
  refine ⟨⟨fun q => if q = y then C else χ.f q, χ.g, insert y χ.dom⟩,
    Finset.subset_insert y χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hy_notin,
    fun _ _ _ _ => rfl, fun _ _ => rfl⟩
  · intro x hx
    have h_ne : x ≠ y := fun h => hy_notin (h ▸ hx)
    exact if_neg h_ne
  · intro x hx
    simp only [Finset.mem_insert] at hx
    rcases hx with rfl | hx
    · simp only [ite_true]; exact h_C_mcs
    · have h_ne : x ≠ y := fun h => hy_notin (h ▸ hx)
      simp only [h_ne, ite_false]; exact h_c0 x hx
  · refine ⟨y, Finset.mem_insert_self y χ.dom, hy_lt ce.x ce.x_mem, ?_⟩
    simp only [ite_true]
    exact h_η_C

/-! ## G-Propagation Counterexample Elimination

When G(α) ∈ f(x) and α ∉ f(y) for adjacent x < y, insert a new point z between
x and y with α ∈ f(z) and g_content(f(x)) ⊆ f(z). This breaks the adjacency of
(x, y), ensuring the G-propagation failure cannot persist to the limit.

The seed {α} ∪ g_content(f(x)) is consistent because G(α) → F(α) (by
`G_implies_F_mcs`), so `forward_temporal_witness_seed_consistent` applies.
-/

/--
**G-propagation counterexample elimination**: Given G(α) ∈ f(x) and α ∉ f(y)
for adjacent x < y, insert z = (x+y)/2 between x and y with α ∈ f(z) and
g_content(f(x)) ⊆ f(z).
-/
noncomputable def eliminate_g_prop_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (x y : Rat) (α : Formula)
    (h_x_mem : x ∈ χ.dom) (h_y_mem : y ∈ χ.dom)
    (h_adj : Adjacent χ.dom x y)
    (h_G : Formula.all_future α ∈ χ.f x)
    (h_not : α ∉ χ.f y) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ q ∈ χ.dom, χ'.f q = χ.f q) ∧
      χ'.c0 ∧
      χ.dom ⊂ χ'.dom ∧
      (∀ a b, a ∈ χ.dom → b ∈ χ.dom → χ'.g a b = χ.g a b) ∧
      (∀ a b, χ'.g a b = χ.g a b) := by
  set z := (x + y) / 2 with hz_def
  have hxy := h_adj.2.2.1
  have hz_lt_y : z < y := by linarith
  have hx_lt_z : x < z := by linarith
  have hz_notin : z ∉ χ.dom := by
    intro h_mem; exact h_adj.2.2.2 z h_mem ⟨hx_lt_z, hz_lt_y⟩
  have h_mcs_x := h_c0 x h_x_mem
  -- Use g_propagation_witness to get an MCS D with α ∈ D and g_content(f(x)) ⊆ D
  obtain ⟨D, h_D_mcs, h_α_D, _h_g_sub⟩ := g_propagation_witness h_mcs_x α h_G
  refine ⟨⟨fun q => if q = z then D else χ.f q, χ.g, insert z χ.dom⟩,
    Finset.subset_insert z χ.dom, ?_, ?_, Finset.ssubset_insert hz_notin,
    fun _ _ _ _ => rfl, fun _ _ => rfl⟩
  · intro q hq
    have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
    exact if_neg h_ne
  · intro q hq
    simp only [Finset.mem_insert] at hq
    rcases hq with rfl | hq
    · simp only [ite_true]; exact h_D_mcs
    · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
      simp only [h_ne, ite_false]; exact h_c0 q hq

/--
**H-propagation counterexample elimination**: Mirror for backward direction.
Given H(α) ∈ f(x) and α ∉ f(y) for adjacent y < x, insert z between y and x.
-/
noncomputable def eliminate_h_prop_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (x y : Rat) (α : Formula)
    (h_x_mem : x ∈ χ.dom) (h_y_mem : y ∈ χ.dom)
    (h_adj : Adjacent χ.dom y x)
    (h_H : Formula.all_past α ∈ χ.f x)
    (h_not : α ∉ χ.f y) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ q ∈ χ.dom, χ'.f q = χ.f q) ∧
      χ'.c0 ∧
      χ.dom ⊂ χ'.dom ∧
      (∀ a b, a ∈ χ.dom → b ∈ χ.dom → χ'.g a b = χ.g a b) ∧
      (∀ a b, χ'.g a b = χ.g a b) := by
  set z := (y + x) / 2 with hz_def
  have hyx := h_adj.2.2.1
  have hz_lt_x : z < x := by linarith
  have hy_lt_z : y < z := by linarith
  have hz_notin : z ∉ χ.dom := by
    intro h_mem; exact h_adj.2.2.2 z h_mem ⟨hy_lt_z, hz_lt_x⟩
  have h_mcs_x := h_c0 x h_x_mem
  -- P(α) ∈ f(x) by H_implies_P_mcs, then past_temporal_witness_seed gives us D
  have h_P := H_implies_P_mcs h_mcs_x α h_H
  have h_seed := past_temporal_witness_seed_consistent (χ.f x) h_mcs_x α h_P
  obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed
  have h_α_D : α ∈ D := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
  refine ⟨⟨fun q => if q = z then D else χ.f q, χ.g, insert z χ.dom⟩,
    Finset.subset_insert z χ.dom, ?_, ?_, Finset.ssubset_insert hz_notin,
    fun _ _ _ _ => rfl, fun _ _ => rfl⟩
  · intro q hq
    have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
    exact if_neg h_ne
  · intro q hq
    simp only [Finset.mem_insert] at hq
    rcases hq with rfl | hq
    · simp only [ite_true]; exact h_D_mcs
    · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
      simp only [h_ne, ite_false]; exact h_c0 q hq

/-! ## Density Elimination

For breaking adjacency: insert a midpoint z = (x+y)/2 between adjacent x < y.
Uses f(x) as the MCS for z (any MCS works; we just need to break adjacency).
-/

/--
**Density elimination**: Given adjacent x < y in the domain, insert z = (x+y)/2
with f(z) = f(x). Preserves C0 and f-agreement.
-/
noncomputable def eliminate_density_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (x y : Rat)
    (h_x_mem : x ∈ χ.dom) (h_y_mem : y ∈ χ.dom)
    (h_adj : Adjacent χ.dom x y) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ q ∈ χ.dom, χ'.f q = χ.f q) ∧
      χ'.c0 ∧
      (∃ z ∈ χ'.dom, x < z ∧ z < y) ∧
      χ.dom ⊂ χ'.dom ∧
      (∀ a b, a ∈ χ.dom → b ∈ χ.dom → χ'.g a b = χ.g a b) ∧
      (∀ a b, χ'.g a b = χ.g a b) := by
  set z := (x + y) / 2 with hz_def
  have hxy := h_adj.2.2.1
  have hz_lt_y : z < y := by linarith
  have hx_lt_z : x < z := by linarith
  have hz_notin : z ∉ χ.dom := by
    intro h_mem; exact h_adj.2.2.2 z h_mem ⟨hx_lt_z, hz_lt_y⟩
  refine ⟨⟨fun q => if q = z then χ.f x else χ.f q, χ.g, insert z χ.dom⟩,
    Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin,
    fun _ _ _ _ => rfl, fun _ _ => rfl⟩
  · intro q hq
    have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
    exact if_neg h_ne
  · intro q hq
    simp only [Finset.mem_insert] at hq
    rcases hq with rfl | hq
    · simp only [ite_true]; exact h_c0 x h_x_mem
    · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
      simp only [h_ne, ite_false]; exact h_c0 q hq
  · refine ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y⟩

/-! ## Potential Counterexample Interface -/

/--
The **kind** of a potential counterexample, distinguishing between
C4 (backward counterexample) and C5 (forward witness) conditions,
each in forward (Until) and backward (Since) directions.
-/
inductive PotentialCounterexampleKind : Type where
  | c4_forward    : PotentialCounterexampleKind  -- C4: Until backward counterexample
  | c4_backward   : PotentialCounterexampleKind  -- C4': Since backward counterexample
  | c5_forward    : PotentialCounterexampleKind  -- C5: Until forward witness
  | c5_backward   : PotentialCounterexampleKind  -- C5': Since forward witness
  | density       : PotentialCounterexampleKind  -- Density: insert midpoint between adjacent x < y
  deriving DecidableEq, Countable

/--
A **potential counterexample** encodes a tuple (x, y, xi, eta, kind) that MIGHT
be a C4/C4'/C5/C5' counterexample depending on the current chronicle state.

- For C5/C5' counterexamples: only `x`, `ξ`, `η` are relevant; `y` is ignored.
- For C4/C4' counterexamples: both `x` and `y` identify the adjacent pair,
  `γ = ξ` is the GUARD formula, and `δ = η` is the EVENT formula.
  C4 checks EVENT (η) at f(y) and negates GUARD (ξ) at f(z).
-/
structure PotentialCounterexample where
  x : Rat
  y : Rat
  ξ : Formula
  η : Formula
  kind : PotentialCounterexampleKind

/--
Result type for `eliminate_potential_counterexample`, bundling the core
properties (domain extension, C0, f-agreement) together with the
C5/C5' witness guarantees needed by the limit construction.

The `c5_forward_witness` field states: if the input counterexample is c5_forward
and the point x is in the domain with U(ξ,η) ∈ f(x), then a witness exists
in the result domain. Similarly for `c5_backward_witness` and Since.
-/
structure EliminationResult (χ : Chronicle) (pc : PotentialCounterexample) where
  val : Chronicle
  dom_sub : χ.dom ⊆ val.dom
  c0 : val.c0
  f_agrees : ∀ x ∈ χ.dom, val.f x = χ.f x
  g_agrees : ∀ a b, a ∈ χ.dom → b ∈ χ.dom → val.g a b = χ.g a b
  /-- c2' is preserved: for all adjacent pairs in the new chronicle that were
  also adjacent in the original, BurgessR3Maximal holds. New adjacent pairs
  from the elimination also satisfy BurgessR3Maximal. -/
  c2' : val.c2'
  c5_forward_witness : pc.kind = .c5_forward → pc.x ∈ χ.dom →
    Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
    ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y
  c5_backward_witness : pc.kind = .c5_backward → pc.x ∈ χ.dom →
    Formula.snce pc.ξ pc.η ∈ χ.f pc.x →
    ∃ y ∈ val.dom, y < pc.x ∧ pc.η ∈ val.f y
  c4_forward_witness : pc.kind = .c4_forward → pc.x ∈ χ.dom → pc.y ∈ χ.dom →
    pc.x < pc.y →
    (Formula.untl pc.ξ pc.η).neg ∈ χ.f pc.x →
    pc.η ∈ χ.f pc.y →
    ∃ z ∈ val.dom, pc.x < z ∧ z < pc.y ∧ pc.ξ.neg ∈ val.f z
  c4_backward_witness : pc.kind = .c4_backward → pc.x ∈ χ.dom → pc.y ∈ χ.dom →
    pc.y < pc.x →
    (Formula.snce pc.ξ pc.η).neg ∈ χ.f pc.x →
    pc.η ∈ χ.f pc.y →
    ∃ z ∈ val.dom, pc.y < z ∧ z < pc.x ∧ pc.ξ.neg ∈ val.f z
  density_witness : pc.kind = .density → pc.x ∈ χ.dom → pc.y ∈ χ.dom →
    pc.x < pc.y →
    ∃ z ∈ val.dom, pc.x < z ∧ z < pc.y
  /-- Old g-values flow into new f-values: when a point w is inserted between
  adjacent (a,b) in the old domain, the old interval set g(a,b) is contained
  in f'(w). This follows from B ⊆ D in all splitting lemmas (2.6, 2.7, 2.8).
  Vacuously true when no new point is inserted. -/
  g_sub_f_insert : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom →
    a < w → w < b → χ.g a b ⊆ val.f w
  g_sub_g_new : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom →
    a < w → w < b → χ.g a b ⊆ val.g a w ∧ χ.g a b ⊆ val.g w b
  dom_new_unique : ∀ u v, u ∈ val.dom → u ∉ χ.dom → v ∈ val.dom → v ∉ χ.dom → u = v

/--
Attempt to eliminate a potential counterexample. If it is not an actual
counterexample for the current chronicle, the chronicle is returned unchanged.
Otherwise, a new chronicle with the counterexample eliminated is returned.

Returns an `EliminationResult` bundling domain extension, C0, f-agreement,
and C5/C5' witness guarantees.
-/
noncomputable def eliminate_potential_counterexample
    (χ : Chronicle) (h_c0 : χ.c0) (h_c2' : χ.c2')
    (pc : PotentialCounterexample)
    (h_nubr3 : NoUnivBurgessR3) :
    EliminationResult χ pc := by
  -- Helper for impossible kind discriminants
  have absurd_kind {k : PotentialCounterexampleKind} {P : Prop}
      (h : k = .c5_forward) (hk : k = .c4_forward ∨ k = .c4_backward ∨ k = .c5_backward) : P :=
    by rcases hk with rfl | rfl | rfl <;> exact absurd h (by decide)
  match h_kind : pc.kind with
  | .c5_forward =>
    -- Forward (Until) C5 case
    -- Burgess C5a counterexample check (g-value based per Burgess 2.10):
    -- Actual counterexample iff NO y exists with event ∈ f(y) AND guard ∈ g(x,y).
    by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.untl pc.ξ pc.η ∈ χ.f pc.x ∧
        ¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧ pc.ξ ∈ χ.g pc.x y
    · obtain ⟨h_mem, h_until, h_no_wit⟩ := h_actual
      have h_mcs_x := h_c0 pc.x h_mem
      have h_dom_ne : χ.dom.Nonempty := ⟨pc.x, h_mem⟩
      set max_old := χ.dom.max' h_dom_ne with max_old_def
      have h_max_mem : max_old ∈ χ.dom := Finset.max'_mem χ.dom h_dom_ne
      have h_max_le : ∀ s ∈ χ.dom, s ≤ max_old := fun s hs => Finset.le_max' χ.dom s hs
      -- Split on whether pc.x is the last point (n=0) or not (n≥1)
      by_cases h_eq_max : pc.x = max_old
      · -- **Case n=0**: pc.x is the maximum domain point.
        -- Use Lemma 2.4: place y after all points (only new pair is (pc.x, y)).
        have h_fresh := exists_rat_gt_finset χ.dom
        let y := h_fresh.choose
        have hy_gt : ∀ s ∈ χ.dom, s < y := h_fresh.choose_spec.1
        have hy_notin : y ∉ χ.dom := h_fresh.choose_spec.2
        have h_l24 := lemma_2_4 h_mcs_x pc.ξ pc.η h_until h_nubr3
        let B := h_l24.choose
        let C := h_l24.choose_spec.choose
        have h_l24_prop := h_l24.choose_spec.choose_spec
        have h_C_mcs : SetMaximalConsistent C := h_l24_prop.1
        have h_η_C : pc.η ∈ C := h_l24_prop.2.1
        have h_r3m : BurgessR3Maximal (χ.f pc.x) B C := h_l24_prop.2.2.2.2
        have h_max_lt_y : max_old < y := hy_gt max_old h_max_mem
        let g' := fun a b =>
          if a = max_old ∧ b = y then B
          else χ.g a b
        let χ' : Chronicle := ⟨fun q => if q = y then C else χ.f q, g', insert y χ.dom⟩
        have h_c2'_new : χ'.c2' := by
          intro a b h_adj_new
          obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
          simp only [χ', Finset.mem_insert] at ha hb
          rcases ha with rfl | ha <;> rcases hb with rfl | hb
          · exact absurd hab (lt_irrefl _)
          · exact absurd hab (not_lt.mpr (le_of_lt (hy_gt b hb)))
          · have ha_eq : a = max_old := by
              by_contra ha_ne
              have ha_le : a ≤ max_old := h_max_le a ha
              have ha_lt : a < max_old := lt_of_le_of_ne ha_le ha_ne
              exact h_no_between max_old (Finset.mem_insert_of_mem h_max_mem) ⟨ha_lt, h_max_lt_y⟩
            subst ha_eq
            show BurgessR3Maximal
              (if max_old = y then C else χ.f max_old)
              (g' max_old y)
              (if y = y then C else χ.f y)
            have hmax_ne_y : max_old ≠ y := ne_of_lt h_max_lt_y
            simp only [hmax_ne_y, ite_false, ite_true, g']
            simp only [and_self, ite_true]
            rw [← h_eq_max]; exact h_r3m
          · have ha_ne : a ≠ y := fun h => hy_notin (h ▸ ha)
            have hb_ne : b ≠ y := fun h => hy_notin (h ▸ hb)
            show BurgessR3Maximal
              (if a = y then C else χ.f a)
              (g' a b)
              (if b = y then C else χ.f b)
            simp only [ha_ne, hb_ne, ite_false, ite_true]
            show BurgessR3Maximal (χ.f a)
              (if a = max_old ∧ b = y then B else χ.g a b) (χ.f b)
            rw [if_neg (fun ⟨_, hby⟩ => hb_ne hby)]
            have h_adj_old : Adjacent χ.dom a b := by
              refine ⟨ha, hb, hab, ?_⟩
              intro u hu ⟨hau, hub⟩
              exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
            exact h_c2' a b h_adj_old
        exact { val := χ'
                dom_sub := Finset.subset_insert y χ.dom
                c0 := by
                  intro q hq
                  show SetMaximalConsistent (if q = y then C else χ.f q)
                  change q ∈ insert y χ.dom at hq
                  simp only [Finset.mem_insert] at hq
                  rcases hq with rfl | hq
                  · simp only [ite_true]; exact h_C_mcs
                  · have h_ne : q ≠ y := fun h => hy_notin (h ▸ hq)
                    simp only [h_ne, ite_false]; exact h_c0 q hq
                f_agrees := by
                  intro x hx
                  have h_ne : x ≠ y := fun h => hy_notin (h ▸ hx)
                  exact if_neg h_ne
                g_agrees := by
                  intro a b ha hb
                  show g' a b = χ.g a b
                  simp only [g']
                  have hb_ne : b ≠ y := fun h => hy_notin (h ▸ hb)
                  simp only [hb_ne, and_false, ite_false]
                c2' := h_c2'_new
                c5_forward_witness := by
                  intro _ _ _
                  refine ⟨y, Finset.mem_insert_self y χ.dom, hy_gt pc.x h_mem, ?_⟩
                  simp only [χ', ite_true]
                  exact h_η_C
                c5_backward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
                c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                g_sub_f_insert := by
                  intro a b h_adj w hw hw_not haw hwb
                  simp only [χ', Finset.mem_insert] at hw
                  rcases hw with rfl | hw
                  · exact absurd hwb (not_lt.mpr (le_of_lt (hy_gt b h_adj.2.1)))
                  · exact absurd hw hw_not
                g_sub_g_new := by
                  intro a b h_adj w hw hw_not haw hwb
                  simp only [χ', Finset.mem_insert] at hw
                  rcases hw with rfl | hw
                  · exact absurd hwb (not_lt.mpr (le_of_lt (hy_gt b h_adj.2.1)))
                  · exact absurd hw hw_not
                dom_new_unique := by
                  intro u v hu hu_not hv hv_not
                  simp only [χ', Finset.mem_insert] at hu hv
                  rcases hu with rfl | hu <;> rcases hv with rfl | hv
                  · rfl
                  · exact absurd hv hv_not
                  · exact absurd hu hu_not
                  · exact absurd hu hu_not }
      · -- **Case n≥1**: pc.x is NOT the maximum. Burgess 2.10 induction case.
        -- Find x' = immediate successor of pc.x in dom.
        set T_succ := χ.dom.filter (fun v => decide (pc.x < v)) with T_succ_def
        have hT_ne : T_succ.Nonempty := by
          have h_pc_lt_max : pc.x < max_old := lt_of_le_of_ne (h_max_le pc.x h_mem) h_eq_max
          exact ⟨max_old, Finset.mem_filter.mpr ⟨h_max_mem, by simp [h_pc_lt_max]⟩⟩
        set x' := T_succ.min' hT_ne with x'_def
        have hx'_mem_T := Finset.min'_mem T_succ hT_ne
        have hx'_dom : x' ∈ χ.dom := (Finset.mem_filter.mp hx'_mem_T).1
        have hx_lt_x' : pc.x < x' := by
          have := (Finset.mem_filter.mp hx'_mem_T).2
          simp only [decide_eq_true_eq] at this; exact this
        have h_adj_xx' : Adjacent χ.dom pc.x x' := by
          refine ⟨h_mem, hx'_dom, hx_lt_x', ?_⟩
          intro u hu ⟨hxu, hux'⟩
          have hu_T : u ∈ T_succ := Finset.mem_filter.mpr ⟨hu, by simp [hxu]⟩
          have := Finset.min'_le T_succ u hu_T
          linarith
        -- Key fact: x' is NOT a C5 witness (eta ∉ f(x')), because x' is adjacent
        -- to pc.x so the guard condition is vacuous, and h_no_wit would be violated.
        have h_mcs_x' := h_c0 x' hx'_dom
        -- Burgess 2.10 (ii): guard ∈ g(x,x') implies event ∉ f(x')
        have h_guard_implies_no_event : pc.ξ ∈ χ.g pc.x x' → pc.η ∉ χ.f x' :=
          fun h_guard h_event => h_no_wit ⟨x', hx'_dom, hx_lt_x', h_event, h_guard⟩
        -- Get BurgessR3Maximal for the adjacent pair (pc.x, x') from c2'
        have h_r3m_adj := h_c2' pc.x x' h_adj_xx'
        have h_B_sdc := BurgessR3Maximal_sdc h_r3m_adj h_nubr3 h_mcs_x h_mcs_x'
        have h_gc_adj := BurgessR3Maximal_g_content_sub h_r3m_adj h_mcs_x h_mcs_x'
        -- Strategy: split the pair (pc.x, x') by inserting z between them.
        -- Use lemma_2_6_splitting with β = eta.neg (need eta.neg ∉ g(pc.x, x')),
        -- OR lemma_2_7 (need xi ∉ g(pc.x, x')),
        -- OR (when eta ∈ g) lemma_2_6_splitting with β = ⊥.
        -- Since g is SDC (consistent), ⊥ ∉ g and at most one of {eta, eta.neg} is in g.
        have h_bot_not_g : Formula.bot ∉ χ.g pc.x x' := by
          intro h_bot
          exact h_B_sdc.1 [Formula.bot] (fun φ hφ => by simp at hφ; rw [hφ]; exact h_bot)
            ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
        -- Burgess 2.10: check condition (i) — does the conjunction persist into f(x')
        -- AND is the guard in g(x, x')? Both parts are needed for the forward walk.
        -- If condition (i) holds, splitting at (pc.x, x') fails; use forward walk.
        -- If not, the existing splitting lemmas handle all cases.
        by_cases h_cond_i : Formula.and pc.ξ (Formula.untl pc.ξ pc.η) ∈ χ.f x' ∧ pc.ξ ∈ χ.g pc.x x'
        · -- **Condition (i)**: xi∧U(xi,eta) ∈ f(x') and xi ∈ g(x,x'), so U(xi,eta) ∈ f(x').
          -- Forward walk: find the last domain point w ≥ pc.x where U(xi,eta) ∈ f(w),
          -- then either apply lemma_2_4 (if w = max_old) or split at (w, w_next).
          have h_untl_x' : Formula.untl pc.ξ pc.η ∈ χ.f x' :=
            conj_right_mcs h_mcs_x' pc.ξ (Formula.untl pc.ξ pc.η) h_cond_i.1
          -- Walk set U: domain points w ≥ pc.x with U(xi,eta) ∈ f(w)
          haveI : DecidablePred (fun w => pc.x ≤ w ∧ Formula.untl pc.ξ pc.η ∈ χ.f w) :=
            fun _ => Classical.dec _
          set U := χ.dom.filter (fun w => pc.x ≤ w ∧ Formula.untl pc.ξ pc.η ∈ χ.f w) with U_def
          have hU_ne : U.Nonempty := by
            exact ⟨pc.x, Finset.mem_filter.mpr ⟨h_mem, le_refl _, h_until⟩⟩
          set u_max := U.max' hU_ne with u_max_def
          have hu_max_mem_U := Finset.max'_mem U hU_ne
          have hu_max_dom : u_max ∈ χ.dom :=
            (Finset.mem_filter.mp hu_max_mem_U).1
          have hu_max_ge : pc.x ≤ u_max :=
            (Finset.mem_filter.mp hu_max_mem_U).2.1
          have h_untl_u_max : Formula.untl pc.ξ pc.η ∈ χ.f u_max :=
            (Finset.mem_filter.mp hu_max_mem_U).2.2
          have h_mcs_u_max := h_c0 u_max hu_max_dom
          -- Case split: is u_max the domain maximum?
          by_cases h_u_is_max : u_max = max_old
          · -- **Walk Case A**: U(xi,eta) persists to max_old. Use lemma_2_4.
            -- u_max = max_old, so apply lemma_2_4 at f(max_old) = f(u_max)
            have h_fresh := exists_rat_gt_finset χ.dom
            let y := h_fresh.choose
            have hy_gt : ∀ s ∈ χ.dom, s < y := h_fresh.choose_spec.1
            have hy_notin : y ∉ χ.dom := h_fresh.choose_spec.2
            have h_l24 := lemma_2_4 h_mcs_u_max pc.ξ pc.η h_untl_u_max h_nubr3
            let B_l24 := h_l24.choose
            let C_l24 := h_l24.choose_spec.choose
            have h_l24_prop := h_l24.choose_spec.choose_spec
            have h_C_mcs : SetMaximalConsistent C_l24 := h_l24_prop.1
            have h_η_C : pc.η ∈ C_l24 := h_l24_prop.2.1
            have h_r3m_l24 : BurgessR3Maximal (χ.f u_max) B_l24 C_l24 := h_l24_prop.2.2.2.2
            have h_max_lt_y : max_old < y := hy_gt max_old h_max_mem
            have h_umax_lt_y : u_max < y := h_u_is_max ▸ h_max_lt_y
            let g' := fun a b =>
              if a = max_old ∧ b = y then B_l24
              else χ.g a b
            let χ' : Chronicle := ⟨fun q => if q = y then C_l24 else χ.f q, g', insert y χ.dom⟩
            have h_c2'_new : χ'.c2' := by
              intro a b h_adj_new
              obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
              simp only [χ', Finset.mem_insert] at ha hb
              rcases ha with rfl | ha <;> rcases hb with rfl | hb
              · exact absurd hab (lt_irrefl _)
              · exact absurd hab (not_lt.mpr (le_of_lt (hy_gt b hb)))
              · have ha_eq : a = max_old := by
                  by_contra ha_ne
                  have ha_le : a ≤ max_old := h_max_le a ha
                  have ha_lt : a < max_old := lt_of_le_of_ne ha_le ha_ne
                  exact h_no_between max_old (Finset.mem_insert_of_mem h_max_mem) ⟨ha_lt, h_max_lt_y⟩
                subst ha_eq
                show BurgessR3Maximal
                  (if max_old = y then C_l24 else χ.f max_old)
                  (g' max_old y)
                  (if y = y then C_l24 else χ.f y)
                have hmax_ne_y : max_old ≠ y := ne_of_lt h_max_lt_y
                simp only [hmax_ne_y, ite_false, ite_true, g']
                simp only [and_self, ite_true]
                rw [← h_u_is_max]; exact h_r3m_l24
              · have ha_ne : a ≠ y := fun h => hy_notin (h ▸ ha)
                have hb_ne : b ≠ y := fun h => hy_notin (h ▸ hb)
                show BurgessR3Maximal
                  (if a = y then C_l24 else χ.f a)
                  (g' a b)
                  (if b = y then C_l24 else χ.f b)
                simp only [ha_ne, hb_ne, ite_false, ite_true]
                show BurgessR3Maximal (χ.f a)
                  (if a = max_old ∧ b = y then B_l24 else χ.g a b) (χ.f b)
                rw [if_neg (fun ⟨_, hby⟩ => hb_ne hby)]
                have h_adj_old : Adjacent χ.dom a b := by
                  refine ⟨ha, hb, hab, ?_⟩
                  intro u hu ⟨hau, hub⟩
                  exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
                exact h_c2' a b h_adj_old
            exact { val := χ'
                    dom_sub := Finset.subset_insert y χ.dom
                    c0 := by
                      intro q hq
                      show SetMaximalConsistent (if q = y then C_l24 else χ.f q)
                      change q ∈ insert y χ.dom at hq
                      simp only [Finset.mem_insert] at hq
                      rcases hq with rfl | hq
                      · simp only [ite_true]; exact h_C_mcs
                      · have h_ne : q ≠ y := fun h => hy_notin (h ▸ hq)
                        simp only [h_ne, ite_false]; exact h_c0 q hq
                    f_agrees := by
                      intro x hx
                      have h_ne : x ≠ y := fun h => hy_notin (h ▸ hx)
                      exact if_neg h_ne
                    g_agrees := by
                      intro a b ha hb
                      show g' a b = χ.g a b
                      simp only [g']
                      have hb_ne : b ≠ y := fun h => hy_notin (h ▸ hb)
                      simp only [hb_ne, and_false, ite_false]
                    c2' := h_c2'_new
                    c5_forward_witness := by
                      intro _ _ _
                      refine ⟨y, Finset.mem_insert_self y χ.dom, ?_, ?_⟩
                      · exact lt_of_le_of_lt hu_max_ge h_umax_lt_y
                      · simp only [χ', ite_true]
                        exact h_η_C
                    c5_backward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
                    c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                    c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                    density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                    g_sub_f_insert := by
                      intro a b h_adj w hw hw_not haw hwb
                      simp only [χ', Finset.mem_insert] at hw
                      rcases hw with rfl | hw
                      · exact absurd hwb (not_lt.mpr (le_of_lt (hy_gt b h_adj.2.1)))
                      · exact absurd hw hw_not
                    g_sub_g_new := by
                      intro a b h_adj w hw hw_not haw hwb
                      simp only [χ', Finset.mem_insert] at hw
                      rcases hw with rfl | hw
                      · exact absurd hwb (not_lt.mpr (le_of_lt (hy_gt b h_adj.2.1)))
                      · exact absurd hw hw_not
                    dom_new_unique := by
                      intro u v hu hu_not hv hv_not
                      simp only [χ', Finset.mem_insert] at hu hv
                      rcases hu with rfl | hu <;> rcases hv with rfl | hv
                      · rfl
                      · exact absurd hv hv_not
                      · exact absurd hu hu_not
                      · exact absurd hu hu_not }
          · -- **Walk Case B**: u_max < max_old. Find successor and split there.
            have h_u_lt_max : u_max < max_old :=
              lt_of_le_of_ne (h_max_le u_max hu_max_dom) h_u_is_max
            -- Find u_next = immediate successor of u_max in dom
            set T_u := χ.dom.filter (fun v => decide (u_max < v)) with T_u_def
            have hT_u_ne : T_u.Nonempty := by
              exact ⟨max_old, Finset.mem_filter.mpr ⟨h_max_mem, by simp [h_u_lt_max]⟩⟩
            set u_next := T_u.min' hT_u_ne with u_next_def
            have hu_next_mem_T := Finset.min'_mem T_u hT_u_ne
            have hu_next_dom : u_next ∈ χ.dom := (Finset.mem_filter.mp hu_next_mem_T).1
            have h_u_lt_next : u_max < u_next := by
              have := (Finset.mem_filter.mp hu_next_mem_T).2
              simp only [decide_eq_true_eq] at this; exact this
            have h_adj_u : Adjacent χ.dom u_max u_next := by
              refine ⟨hu_max_dom, hu_next_dom, h_u_lt_next, ?_⟩
              intro u hu ⟨huu, hun⟩
              have hu_T : u ∈ T_u := Finset.mem_filter.mpr ⟨hu, by simp [huu]⟩
              have := Finset.min'_le T_u u hu_T
              linarith
            -- Key: U(xi,eta) ∉ f(u_next) by maximality of u_max in U
            have h_untl_not_next : Formula.untl pc.ξ pc.η ∉ χ.f u_next := by
              intro h_in
              have h_next_ge : pc.x ≤ u_next := le_of_lt (lt_of_le_of_lt hu_max_ge h_u_lt_next)
              have h_next_U : u_next ∈ U :=
                Finset.mem_filter.mpr ⟨hu_next_dom, h_next_ge, h_in⟩
              exact absurd (Finset.le_max' U u_next h_next_U) (not_le.mpr h_u_lt_next)
            -- Therefore conj ∉ f(u_next) (conjunction requires untl component)
            have h_conj_not_next : Formula.and pc.ξ (Formula.untl pc.ξ pc.η) ∉ χ.f u_next := by
              intro h_conj
              exact h_untl_not_next (conj_right_mcs (h_c0 u_next hu_next_dom) pc.ξ
                (Formula.untl pc.ξ pc.η) h_conj)
            have h_mcs_u_next := h_c0 u_next hu_next_dom
            have h_r3m_u := h_c2' u_max u_next h_adj_u
            have h_B_sdc_u := BurgessR3Maximal_sdc h_r3m_u h_nubr3 h_mcs_u_max h_mcs_u_next
            have h_gc_u := BurgessR3Maximal_g_content_sub h_r3m_u h_mcs_u_max h_mcs_u_next
            -- eta may or may not be in f(u_next). If it is, we have a direct C5 witness.
            by_cases h_eta_u_next : pc.η ∈ χ.f u_next
            · -- eta ∈ f(u_next): u_next is a direct C5 witness (no guard needed).
              -- Return the unchanged chronicle.
              exact { val := χ
                      dom_sub := Finset.Subset.refl _
                      c0 := h_c0
                      f_agrees := fun _ _ => rfl
                      g_agrees := fun _ _ _ _ => rfl
                      c2' := h_c2'
                      c5_forward_witness := by
                        intro _ _ _
                        exact ⟨u_next, hu_next_dom,
                          lt_of_le_of_lt hu_max_ge h_u_lt_next, h_eta_u_next⟩
                      c5_backward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
                      c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      g_sub_f_insert := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
                      g_sub_g_new := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
                      dom_new_unique := fun u _ hu hu_not _ _ => absurd hu hu_not }
            · -- eta ∉ f(u_next): split at (u_max, u_next). Condition (i) fails here.
              have h_eta_neg_u_next : pc.η.neg ∈ χ.f u_next := by
                rcases SetMaximalConsistent.negation_complete h_mcs_u_next pc.η with h | h
                · exact absurd h h_eta_u_next
                · exact h
              have h_bot_not_g_u : Formula.bot ∉ χ.g u_max u_next := by
                intro h_bot
                exact h_B_sdc_u.1 [Formula.bot] (fun φ hφ => by simp at hφ; rw [hφ]; exact h_bot)
                  ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
              -- Splitting at (u_max, u_next): full case analysis.
              -- Condition (i) is excluded because conj ∉ f(u_next).
              have h_split_result_u : ∃ B' D B'' : Set Formula,
                  BurgessR3Maximal (χ.f u_max) B' D ∧
                  BurgessR3Maximal D B'' (χ.f u_next) ∧
                  SetMaximalConsistent D ∧
                  pc.η ∈ D ∧
                  χ.g u_max u_next ⊆ D ∧
                  χ.g u_max u_next ⊆ B' ∧
                  χ.g u_max u_next ⊆ B'' := by
                by_cases h_eta_g_u : pc.η ∈ χ.g u_max u_next
                · by_cases h_xi_g_u : pc.ξ ∈ χ.g u_max u_next
                  · have h_eta_neg_not_g_u : pc.η.neg ∉ χ.g u_max u_next := by
                      intro h_neg
                      exact set_consistent_not_both h_B_sdc_u.1 pc.η h_eta_g_u h_neg
                    have h_sp := lemma_2_6_splitting h_mcs_u_max h_mcs_u_next h_r3m_u
                      h_B_sdc_u h_gc_u pc.η.neg h_eta_neg_not_g_u h_nubr3
                    obtain ⟨B', D, B'', hB', hB'', hD_mcs, h_dne_D, h_B_sub_D, hBB', hBB''⟩ := h_sp
                    exact ⟨B', D, B'', hB', hB'', hD_mcs, by
                      exact SetMaximalConsistent.implication_property hD_mcs
                        (theorem_in_mcs hD_mcs (Bimodal.Theorems.Propositional.double_negation pc.η))
                        h_dne_D, h_B_sub_D, hBB', hBB''⟩
                  · obtain ⟨B', D, B'', hB', hB'', hD, hη, hBB', h_B_sub_D, hBB''⟩ :=
                      lemma_2_7 h_mcs_u_max h_mcs_u_next h_r3m_u h_B_sdc_u h_gc_u
                        pc.ξ pc.η h_untl_u_max h_xi_g_u h_nubr3
                    exact ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_D, hBB', hBB''⟩
                · by_cases h_eta_neg_g_u : pc.η.neg ∈ χ.g u_max u_next
                  · by_cases h_xi_g_u : pc.ξ ∈ χ.g u_max u_next
                    · by_cases h_conj_g_u : Formula.and pc.ξ (Formula.untl pc.ξ pc.η) ∈ χ.g u_max u_next
                      · -- conj ∈ g but conj ∉ f(u_next): Lemma 2.8 applies.
                        have h_neg_disj_u : (Formula.or pc.η (Formula.and pc.ξ (Formula.untl pc.ξ pc.η))).neg ∈ χ.f u_next := by
                          have h_neg_conj_u : (pc.η.neg.and (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)).neg) ∈ χ.f u_next := by
                            have h2 : (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)).neg ∈ χ.f u_next := by
                              rcases SetMaximalConsistent.negation_complete h_mcs_u_next
                                (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)) with h | h
                              · exact absurd h h_conj_not_next
                              · exact h
                            exact conj_mcs h_mcs_u_next pc.η.neg
                              (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)).neg h_eta_neg_u_next h2
                          exact SetMaximalConsistent.implication_property h_mcs_u_next
                            (theorem_in_mcs h_mcs_u_next
                              (Bimodal.Theorems.Propositional.demorgan_disj_neg_backward pc.η
                                (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)))) h_neg_conj_u
                        have h_l28 := lemma_2_8 h_mcs_u_max h_mcs_u_next h_r3m_u h_B_sdc_u h_gc_u
                          pc.ξ pc.η h_untl_u_max h_neg_disj_u h_nubr3
                        obtain ⟨B', D, B'', hB', hB'', hD_mcs, hη_D, h_B_sub_D, hBB', hBB''⟩ := h_l28
                        exact ⟨B', D, B'', hB', hB'', hD_mcs, hη_D, h_B_sub_D, hBB', hBB''⟩
                      · have h_bx5_u := self_accum_until_mcs h_mcs_u_max pc.ξ pc.η h_untl_u_max
                        have h_l27 := lemma_2_7 h_mcs_u_max h_mcs_u_next h_r3m_u h_B_sdc_u h_gc_u
                          (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)) pc.η h_bx5_u h_conj_g_u h_nubr3
                        obtain ⟨B', D, B'', hB', hB'', hD_mcs, hη_D, hBB', h_B_sub_D, hBB''⟩ := h_l27
                        exact ⟨B', D, B'', hB', hB'', hD_mcs, hη_D, h_B_sub_D, hBB', hBB''⟩
                    · obtain ⟨B', D, B'', hB', hB'', hD, hη, hBB', h_B_sub_D, hBB''⟩ :=
                        lemma_2_7 h_mcs_u_max h_mcs_u_next h_r3m_u h_B_sdc_u h_gc_u
                          pc.ξ pc.η h_untl_u_max h_xi_g_u h_nubr3
                      exact ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_D, hBB', hBB''⟩
                  · have h_sp := lemma_2_6_splitting h_mcs_u_max h_mcs_u_next h_r3m_u
                      h_B_sdc_u h_gc_u pc.η.neg h_eta_neg_g_u h_nubr3
                    obtain ⟨B', D, B'', hB', hB'', hD_mcs, h_dne_D, h_B_sub_D, hBB', hBB''⟩ := h_sp
                    exact ⟨B', D, B'', hB', hB'', hD_mcs, by
                      exact SetMaximalConsistent.implication_property hD_mcs
                        (theorem_in_mcs hD_mcs (Bimodal.Theorems.Propositional.double_negation pc.η))
                        h_dne_D, h_B_sub_D, hBB', hBB''⟩
              let B' := h_split_result_u.choose
              let D := h_split_result_u.choose_spec.choose
              let B'' := h_split_result_u.choose_spec.choose_spec.choose
              have h_split_prop := h_split_result_u.choose_spec.choose_spec.choose_spec
              have h_B'_max : BurgessR3Maximal (χ.f u_max) B' D := h_split_prop.1
              have h_B''_max : BurgessR3Maximal D B'' (χ.f u_next) := h_split_prop.2.1
              have h_D_mcs : SetMaximalConsistent D := h_split_prop.2.2.1
              have h_η_D : pc.η ∈ D := h_split_prop.2.2.2.1
              have h_g_sub_D : χ.g u_max u_next ⊆ D := h_split_prop.2.2.2.2.1
              have h_g_sub_B' : χ.g u_max u_next ⊆ B' := h_split_prop.2.2.2.2.2.1
              have h_g_sub_B'' : χ.g u_max u_next ⊆ B'' := h_split_prop.2.2.2.2.2.2
              -- Insert z = midpoint of u_max and u_next
              set z := (u_max + u_next) / 2 with hz_def
              have hz_lt_next : z < u_next := by linarith
              have hu_lt_z : u_max < z := by linarith
              have hz_notin : z ∉ χ.dom := by
                intro h_mem_z; exact h_adj_u.2.2.2 z h_mem_z ⟨hu_lt_z, hz_lt_next⟩
              let g' := fun a b =>
                if a = u_max ∧ b = z then B'
                else if a = z ∧ b = u_next then B''
                else χ.g a b
              let χ' : Chronicle := ⟨fun q => if q = z then D else χ.f q, g', insert z χ.dom⟩
              have h_c2'_new : χ'.c2' := by
                intro a b h_adj_new
                obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
                simp only [χ', Finset.mem_insert] at ha hb
                rcases ha with rfl | ha <;> rcases hb with rfl | hb
                · exact absurd hab (lt_irrefl _)
                · have hb_eq : b = u_next := by
                    by_contra hb_ne
                    have hb_ge : u_next ≤ b := by
                      by_contra hlt; push_neg at hlt
                      have : u_max < b := lt_trans hu_lt_z hab
                      exact h_adj_u.2.2.2 b hb ⟨this, hlt⟩
                    have hb_gt : u_next < b := lt_of_le_of_ne hb_ge (Ne.symm hb_ne)
                    exact h_no_between u_next (Finset.mem_insert_of_mem hu_next_dom) ⟨hz_lt_next, hb_gt⟩
                  subst hb_eq
                  show BurgessR3Maximal
                    (if z = z then D else χ.f z)
                    (g' z u_next)
                    (if u_next = z then D else χ.f u_next)
                  have h_ne : u_next ≠ z := by linarith
                  simp only [ite_true, h_ne, ite_false, g']
                  simp only [ite_false, ite_true, and_false, and_self]
                  exact h_B''_max
                · have ha_eq : a = u_max := by
                    by_contra ha_ne
                    have ha_le : a ≤ u_max := by
                      by_contra hgt; push_neg at hgt
                      exact h_adj_u.2.2.2 a ha ⟨hgt, lt_trans hab hz_lt_next⟩
                    have ha_lt : a < u_max := lt_of_le_of_ne ha_le ha_ne
                    exact h_no_between u_max (Finset.mem_insert_of_mem hu_max_dom) ⟨ha_lt, hu_lt_z⟩
                  subst ha_eq
                  show BurgessR3Maximal
                    (if u_max = z then D else χ.f u_max)
                    (g' u_max z)
                    (if z = z then D else χ.f z)
                  have hx_ne : u_max ≠ z := by linarith
                  simp only [hx_ne, ite_false, ite_true, g']
                  exact h_B'_max
                · have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                  have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                  show BurgessR3Maximal
                    (if a = z then D else χ.f a)
                    (g' a b)
                    (if b = z then D else χ.f b)
                  simp only [ha_ne, hb_ne, ite_false, g', and_false, false_and]
                  have h_adj_old : Adjacent χ.dom a b := by
                    refine ⟨ha, hb, hab, ?_⟩
                    intro u hu ⟨hau, hub⟩
                    exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
                  exact h_c2' a b h_adj_old
              exact { val := χ'
                      dom_sub := Finset.subset_insert z χ.dom
                      c0 := by
                        intro q hq
                        show SetMaximalConsistent (if q = z then D else χ.f q)
                        change q ∈ insert z χ.dom at hq
                        simp only [Finset.mem_insert] at hq
                        rcases hq with rfl | hq
                        · simp only [ite_true]; exact h_D_mcs
                        · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                          simp only [h_ne, ite_false]; exact h_c0 q hq
                      f_agrees := by
                        intro x hx
                        have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
                        exact if_neg h_ne
                      g_agrees := by
                        intro a b ha hb
                        show g' a b = χ.g a b
                        simp only [g']
                        have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                        have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                        simp only [ha_ne, hb_ne, false_and, and_false, ite_false]
                      c2' := h_c2'_new
                      c5_forward_witness := by
                        intro _ _ _
                        refine ⟨z, Finset.mem_insert_self z χ.dom, ?_, ?_⟩
                        · exact lt_of_le_of_lt hu_max_ge hu_lt_z
                        · show pc.η ∈ (if z = z then D else χ.f z)
                          simp only [ite_true]
                          exact h_η_D
                      c5_backward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
                      c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      g_sub_f_insert := by
                        intro a b h_adj w hw hw_not haw hwb
                        simp only [χ', Finset.mem_insert] at hw
                        rcases hw with rfl | hw
                        · show χ.g a b ⊆ (if z = z then D else χ.f z)
                          simp only [ite_true]
                          have ha_eq : a = u_max := by
                            by_contra ha_ne
                            rcases lt_or_gt_of_ne ha_ne with h | h
                            · exact h_adj.2.2.2 u_max hu_max_dom ⟨h, lt_trans hu_lt_z hwb⟩
                            · exact h_adj_u.2.2.2 a h_adj.1 ⟨h, lt_trans haw hz_lt_next⟩
                          have hb_eq : b = u_next := by
                            by_contra hb_ne
                            rcases lt_or_gt_of_ne hb_ne with h | h
                            · exact h_adj_u.2.2.2 b h_adj.2.1 ⟨lt_trans hu_lt_z hwb, h⟩
                            · exact h_adj.2.2.2 u_next hu_next_dom ⟨lt_trans haw hz_lt_next, h⟩
                          rw [ha_eq, hb_eq]; exact h_g_sub_D
                        · exact absurd hw hw_not
                      g_sub_g_new := by
                        intro a b h_adj w hw hw_not haw hwb
                        simp only [χ', Finset.mem_insert] at hw
                        rcases hw with rfl | hw
                        · have ha_eq : a = u_max := by
                            by_contra ha_ne
                            rcases lt_or_gt_of_ne ha_ne with h | h
                            · exact h_adj.2.2.2 u_max hu_max_dom ⟨h, lt_trans hu_lt_z hwb⟩
                            · exact h_adj_u.2.2.2 a h_adj.1 ⟨h, lt_trans haw hz_lt_next⟩
                          have hb_eq : b = u_next := by
                            by_contra hb_ne
                            rcases lt_or_gt_of_ne hb_ne with h | h
                            · exact h_adj_u.2.2.2 b h_adj.2.1 ⟨lt_trans hu_lt_z hwb, h⟩
                            · exact h_adj.2.2.2 u_next hu_next_dom ⟨lt_trans haw hz_lt_next, h⟩
                          subst ha_eq; subst hb_eq
                          constructor
                          · show χ.g u_max u_next ⊆ g' u_max z
                            simp only [g', and_self, ite_true]
                            exact h_g_sub_B'
                          · show χ.g u_max u_next ⊆ g' z u_next
                            simp only [g']
                            have : ¬(z = u_max ∧ u_next = z) := by
                              intro ⟨h1, _⟩; linarith
                            simp only [this, ite_false, and_self, ite_true]
                            exact h_g_sub_B''
                        · exact absurd hw hw_not
                      dom_new_unique := by
                        intro u v hu hu_not hv hv_not
                        simp only [χ', Finset.mem_insert] at hu hv
                        rcases hu with rfl | hu <;> rcases hv with rfl | hv
                        · rfl
                        · exact absurd hv hv_not
                        · exact absurd hu hu_not
                        · exact absurd hu hu_not }
        · -- **Not condition (i)**: splitting at (pc.x, x') succeeds.
          -- Get the splitting result: B', D, B'' with eta ∈ D.
          -- Case split on eta ∈ g(pc.x, x'):
          have h_split_result : ∃ B' D B'' : Set Formula,
              BurgessR3Maximal (χ.f pc.x) B' D ∧
              BurgessR3Maximal D B'' (χ.f x') ∧
              SetMaximalConsistent D ∧
              pc.η ∈ D ∧
              χ.g pc.x x' ⊆ D ∧
              χ.g pc.x x' ⊆ B' ∧
              χ.g pc.x x' ⊆ B'' := by
            by_cases h_eta_g : pc.η ∈ χ.g pc.x x'
            · by_cases h_xi_g : pc.ξ ∈ χ.g pc.x x'
              · have h_eta_neg_not_g : pc.η.neg ∉ χ.g pc.x x' := by
                  intro h_neg
                  exact set_consistent_not_both h_B_sdc.1 pc.η h_eta_g h_neg
                have h_split2 := lemma_2_6_splitting h_mcs_x h_mcs_x' h_r3m_adj h_B_sdc h_gc_adj
                  pc.η.neg h_eta_neg_not_g h_nubr3
                obtain ⟨B'2, D2, B''2, h_B'2, h_B''2, h_D2_mcs, h_eta_neg_neg_D2, h_B_sub_D2, h_B_sub_B'2, h_B_sub_B''2⟩ := h_split2
                have h_eta_D2 : pc.η ∈ D2 := by
                  have h_dne : DerivationTree [] (pc.η.neg.neg.imp pc.η) :=
                    Bimodal.Theorems.Propositional.double_negation pc.η
                  exact SetMaximalConsistent.implication_property h_D2_mcs
                    (theorem_in_mcs h_D2_mcs h_dne) h_eta_neg_neg_D2
                exact ⟨B'2, D2, B''2, h_B'2, h_B''2, h_D2_mcs, h_eta_D2, h_B_sub_D2, h_B_sub_B'2, h_B_sub_B''2⟩
              · obtain ⟨B'3, D3, B''3, h_B'3, h_B''3, h_D3_mcs, h_eta_D3, h_B_sub_B'3, h_B_sub_D3, h_B_sub_B''3⟩ :=
                  lemma_2_7 h_mcs_x h_mcs_x' h_r3m_adj h_B_sdc h_gc_adj
                    pc.ξ pc.η h_until h_xi_g h_nubr3
                exact ⟨B'3, D3, B''3, h_B'3, h_B''3, h_D3_mcs, h_eta_D3, h_B_sub_D3, h_B_sub_B'3, h_B_sub_B''3⟩
            · by_cases h_eta_neg_g : pc.η.neg ∈ χ.g pc.x x'
              · by_cases h_xi_g : pc.ξ ∈ χ.g pc.x x'
                · by_cases h_conj_g : Formula.and pc.ξ (Formula.untl pc.ξ pc.η) ∈ χ.g pc.x x'
                  · -- conj ∈ g and xi ∈ g but condition (i) fails: conj ∉ f(x'). Lemma 2.8 applies.
                    have h_conj_not_f : Formula.and pc.ξ (Formula.untl pc.ξ pc.η) ∉ χ.f x' :=
                      fun h_conj_f => h_cond_i ⟨h_conj_f, h_xi_g⟩
                    have h_neg_disj : (Formula.or pc.η (Formula.and pc.ξ (Formula.untl pc.ξ pc.η))).neg ∈ χ.f x' := by
                      have h_neg_conj : (pc.η.neg.and (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)).neg) ∈ χ.f x' := by
                        have h1 : pc.η.neg ∈ χ.f x' := by
                          rcases SetMaximalConsistent.negation_complete h_mcs_x' pc.η with h | h
                          · exact absurd h (h_guard_implies_no_event h_xi_g)
                          · exact h
                        have h2 : (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)).neg ∈ χ.f x' := by
                          rcases SetMaximalConsistent.negation_complete h_mcs_x' (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)) with h | h
                          · exact absurd h h_conj_not_f
                          · exact h
                        exact conj_mcs h_mcs_x' pc.η.neg (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)).neg h1 h2
                      have h_dm := Bimodal.Theorems.Propositional.demorgan_disj_neg_backward pc.η (Formula.and pc.ξ (Formula.untl pc.ξ pc.η))
                      exact SetMaximalConsistent.implication_property h_mcs_x'
                        (theorem_in_mcs h_mcs_x' h_dm) h_neg_conj
                    have h_l28 := lemma_2_8 h_mcs_x h_mcs_x' h_r3m_adj h_B_sdc h_gc_adj
                      pc.ξ pc.η h_until h_neg_disj h_nubr3
                    obtain ⟨B'5, D5, B''5, h_B'5, h_B''5, h_D5_mcs, h_eta_D5, h_B_sub_D5, h_B_sub_B'5, h_B_sub_B''5⟩ := h_l28
                    exact ⟨B'5, D5, B''5, h_B'5, h_B''5, h_D5_mcs, h_eta_D5, h_B_sub_D5, h_B_sub_B'5, h_B_sub_B''5⟩
                  · have h_bx5 := self_accum_until_mcs h_mcs_x pc.ξ pc.η h_until
                    obtain ⟨B'6, D6, B''6, h_B'6, h_B''6, h_D6_mcs, h_eta_D6, h_B_sub_B'6, h_B_sub_D6, h_B_sub_B''6⟩ :=
                      lemma_2_7 h_mcs_x h_mcs_x' h_r3m_adj h_B_sdc h_gc_adj
                        (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)) pc.η h_bx5 h_conj_g h_nubr3
                    exact ⟨B'6, D6, B''6, h_B'6, h_B''6, h_D6_mcs, h_eta_D6, h_B_sub_D6, h_B_sub_B'6, h_B_sub_B''6⟩
                · obtain ⟨B'4, D4, B''4, h_B'4, h_B''4, h_D4_mcs, h_eta_D4, h_B_sub_B'4, h_B_sub_D4, h_B_sub_B''4⟩ :=
                    lemma_2_7 h_mcs_x h_mcs_x' h_r3m_adj h_B_sdc h_gc_adj
                      pc.ξ pc.η h_until h_xi_g h_nubr3
                  exact ⟨B'4, D4, B''4, h_B'4, h_B''4, h_D4_mcs, h_eta_D4, h_B_sub_D4, h_B_sub_B'4, h_B_sub_B''4⟩
              · have h_split5 := lemma_2_6_splitting h_mcs_x h_mcs_x' h_r3m_adj h_B_sdc h_gc_adj
                  pc.η.neg h_eta_neg_g h_nubr3
                obtain ⟨B'5, D5, B''5, h_B'5, h_B''5, h_D5_mcs, h_eta_neg_neg_D5, h_B_sub_D5, h_B_sub_B'5, h_B_sub_B''5⟩ := h_split5
                have h_eta_D5 : pc.η ∈ D5 := by
                  have h_dne : DerivationTree [] (pc.η.neg.neg.imp pc.η) :=
                    Bimodal.Theorems.Propositional.double_negation pc.η
                  exact SetMaximalConsistent.implication_property h_D5_mcs
                    (theorem_in_mcs h_D5_mcs h_dne) h_eta_neg_neg_D5
                exact ⟨B'5, D5, B''5, h_B'5, h_B''5, h_D5_mcs, h_eta_D5, h_B_sub_D5, h_B_sub_B'5, h_B_sub_B''5⟩
          let B' := h_split_result.choose
          let D := h_split_result.choose_spec.choose
          let B'' := h_split_result.choose_spec.choose_spec.choose
          have h_split_prop := h_split_result.choose_spec.choose_spec.choose_spec
          have h_B'_max : BurgessR3Maximal (χ.f pc.x) B' D := h_split_prop.1
          have h_B''_max : BurgessR3Maximal D B'' (χ.f x') := h_split_prop.2.1
          have h_D_mcs : SetMaximalConsistent D := h_split_prop.2.2.1
          have h_η_D : pc.η ∈ D := h_split_prop.2.2.2.1
          have h_g_sub_D : χ.g pc.x x' ⊆ D := h_split_prop.2.2.2.2.1
          have h_g_sub_B' : χ.g pc.x x' ⊆ B' := h_split_prop.2.2.2.2.2.1
          have h_g_sub_B'' : χ.g pc.x x' ⊆ B'' := h_split_prop.2.2.2.2.2.2
          -- Insert z = midpoint of pc.x and x'
          set z := (pc.x + x') / 2 with hz_def
          have hz_lt_x' : z < x' := by linarith
          have hx_lt_z : pc.x < z := by linarith
          have hz_notin : z ∉ χ.dom := by
            intro h_mem_z; exact h_adj_xx'.2.2.2 z h_mem_z ⟨hx_lt_z, hz_lt_x'⟩
          -- Build new chronicle with f'(z) = D
          let g' := fun a b =>
            if a = pc.x ∧ b = z then B'
            else if a = z ∧ b = x' then B''
            else χ.g a b
          let χ' : Chronicle := ⟨fun q => if q = z then D else χ.f q, g', insert z χ.dom⟩
          -- Prove c2' for the new chronicle
          have h_c2'_new : χ'.c2' := by
            intro a b h_adj_new
            obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
            simp only [χ', Finset.mem_insert] at ha hb
            rcases ha with rfl | ha <;> rcases hb with rfl | hb
            · exact absurd hab (lt_irrefl _)
            · -- a = z, b ∈ old dom: must be (z, x')
              have hb_eq : b = x' := by
                by_contra hb_ne
                have hb_ge : x' ≤ b := by
                  by_contra hlt; push_neg at hlt
                  have : pc.x < b := lt_trans hx_lt_z hab
                  exact h_adj_xx'.2.2.2 b hb ⟨this, hlt⟩
                have hb_gt : x' < b := lt_of_le_of_ne hb_ge (Ne.symm hb_ne)
                exact h_no_between x' (Finset.mem_insert_of_mem hx'_dom) ⟨hz_lt_x', hb_gt⟩
              subst hb_eq
              show BurgessR3Maximal
                (if z = z then D else χ.f z)
                (g' z x')
                (if x' = z then D else χ.f x')
              have hx'_ne : x' ≠ z := by linarith
              simp only [ite_true, hx'_ne, ite_false, g']
              simp only [ite_false, ite_true, and_false, and_self]
              exact h_B''_max
            · -- a ∈ old dom, b = z: must be (pc.x, z)
              have ha_eq : a = pc.x := by
                by_contra ha_ne
                have ha_le : a ≤ pc.x := by
                  by_contra hgt; push_neg at hgt
                  exact h_adj_xx'.2.2.2 a ha ⟨hgt, lt_trans hab hz_lt_x'⟩
                have ha_lt : a < pc.x := lt_of_le_of_ne ha_le ha_ne
                exact h_no_between pc.x (Finset.mem_insert_of_mem h_mem) ⟨ha_lt, hx_lt_z⟩
              subst ha_eq
              show BurgessR3Maximal
                (if pc.x = z then D else χ.f pc.x)
                (g' pc.x z)
                (if z = z then D else χ.f z)
              have hx_ne : pc.x ≠ z := by linarith
              simp only [hx_ne, ite_false, ite_true, g']
              exact h_B'_max
            · -- Both old: preserved
              have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
              have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
              show BurgessR3Maximal
                (if a = z then D else χ.f a)
                (g' a b)
                (if b = z then D else χ.f b)
              simp only [ha_ne, hb_ne, ite_false, g', and_false, false_and]
              have h_adj_old : Adjacent χ.dom a b := by
                refine ⟨ha, hb, hab, ?_⟩
                intro u hu ⟨hau, hub⟩
                exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
              exact h_c2' a b h_adj_old
          exact { val := χ'
                  dom_sub := Finset.subset_insert z χ.dom
                  c0 := by
                    intro q hq
                    show SetMaximalConsistent (if q = z then D else χ.f q)
                    change q ∈ insert z χ.dom at hq
                    simp only [Finset.mem_insert] at hq
                    rcases hq with rfl | hq
                    · simp only [ite_true]; exact h_D_mcs
                    · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                      simp only [h_ne, ite_false]; exact h_c0 q hq
                  f_agrees := by
                    intro x hx
                    have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
                    exact if_neg h_ne
                  g_agrees := by
                    intro a b ha hb
                    show g' a b = χ.g a b
                    simp only [g']
                    have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                    have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                    simp only [ha_ne, hb_ne, false_and, and_false, ite_false]
                  c2' := h_c2'_new
                  c5_forward_witness := by
                    intro _ _ _
                    refine ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, ?_⟩
                    show pc.η ∈ (if z = z then D else χ.f z)
                    simp only [ite_true]
                    exact h_η_D
                  c5_backward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
                  c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                  c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                  density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                  g_sub_f_insert := by
                    intro a b h_adj w hw hw_not haw hwb
                    simp only [χ', Finset.mem_insert] at hw
                    rcases hw with rfl | hw
                    · show χ.g a b ⊆ (if z = z then D else χ.f z)
                      simp only [ite_true]
                      have hab : a = pc.x ∧ b = x' := by
                        constructor
                        · by_contra ha_ne
                          have : a < pc.x ∨ pc.x < a := lt_or_gt_of_ne ha_ne
                          rcases this with h | h
                          · exact h_adj.2.2.2 pc.x h_mem ⟨h, lt_trans hx_lt_z hwb⟩
                          · exact h_adj_xx'.2.2.2 a h_adj.1 ⟨h, lt_trans haw hz_lt_x'⟩
                        · by_contra hb_ne
                          have : b < x' ∨ x' < b := lt_or_gt_of_ne hb_ne
                          rcases this with h | h
                          · exact h_adj_xx'.2.2.2 b h_adj.2.1 ⟨lt_trans hx_lt_z hwb, h⟩
                          · exact h_adj.2.2.2 x' hx'_dom ⟨lt_trans haw hz_lt_x', h⟩
                      rw [hab.1, hab.2]; exact h_g_sub_D
                    · exact absurd hw hw_not
                  g_sub_g_new := by
                    intro a b h_adj w hw hw_not haw hwb
                    simp only [χ', Finset.mem_insert] at hw
                    rcases hw with rfl | hw
                    · have ha_eq : a = pc.x := by
                        by_contra ha_ne
                        rcases lt_or_gt_of_ne ha_ne with h | h
                        · exact h_adj.2.2.2 pc.x h_mem ⟨h, lt_trans hx_lt_z hwb⟩
                        · exact h_adj_xx'.2.2.2 a h_adj.1 ⟨h, lt_trans haw hz_lt_x'⟩
                      have hb_eq : b = x' := by
                        by_contra hb_ne
                        rcases lt_or_gt_of_ne hb_ne with h | h
                        · exact h_adj_xx'.2.2.2 b h_adj.2.1 ⟨lt_trans hx_lt_z hwb, h⟩
                        · exact h_adj.2.2.2 x' hx'_dom ⟨lt_trans haw hz_lt_x', h⟩
                      subst ha_eq; subst hb_eq
                      constructor
                      · show χ.g pc.x x' ⊆ g' pc.x z
                        simp only [g', and_self, ite_true]
                        exact h_g_sub_B'
                      · show χ.g pc.x x' ⊆ g' z x'
                        simp only [g']
                        have : ¬(z = pc.x ∧ x' = z) := by
                          intro ⟨h1, _⟩; linarith
                        simp only [this, ite_false, and_self, ite_true]
                        exact h_g_sub_B''
                    · exact absurd hw hw_not
                  dom_new_unique := by
                    intro u v hu hu_not hv hv_not
                    simp only [χ', Finset.mem_insert] at hu hv
                    rcases hu with rfl | hu <;> rcases hv with rfl | hv
                    · rfl
                    · exact absurd hv hv_not
                    · exact absurd hu hu_not
                    · exact absurd hu hu_not }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              g_agrees := fun _ _ _ _ => rfl
              c2' := by exact h_c2'
              c5_forward_witness := by
                intro _ h_mem h_until
                push_neg at h_actual
                obtain ⟨y, hy_dom, hy_lt, hy_η, _⟩ := h_actual h_mem h_until
                exact ⟨y, hy_dom, hy_lt, hy_η⟩
              c5_backward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              g_sub_f_insert := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              g_sub_g_new := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              dom_new_unique := fun u _ hu hu_not _ _ => absurd hu hu_not }
  | .c5_backward =>
    -- Backward (Since) C5' case
    -- Burgess C5b counterexample check (g-value based, mirror of C5a):
    by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.snce pc.ξ pc.η ∈ χ.f pc.x ∧
        ¬∃ y ∈ χ.dom, y < pc.x ∧ pc.η ∈ χ.f y ∧ pc.ξ ∈ χ.g y pc.x
    · obtain ⟨h_mem, h_since, h_no_wit⟩ := h_actual
      have h_mcs_x := h_c0 pc.x h_mem
      have h_dom_ne : χ.dom.Nonempty := ⟨pc.x, h_mem⟩
      set min_old := χ.dom.min' h_dom_ne with min_old_def
      have h_min_mem : min_old ∈ χ.dom := Finset.min'_mem χ.dom h_dom_ne
      have h_min_le : ∀ s ∈ χ.dom, min_old ≤ s := fun s hs => Finset.min'_le χ.dom s hs
      -- Split on whether pc.x is the first point (n=0) or not (n≥1)
      by_cases h_eq_min : pc.x = min_old
      · -- **Case n=0**: pc.x is the minimum domain point.
        -- Place y before all points. Only new pair is (y, pc.x).
        have h_fresh := exists_rat_lt_finset χ.dom
        let y := h_fresh.choose
        have hy_lt : ∀ s ∈ χ.dom, y < s := h_fresh.choose_spec.1
        have hy_notin : y ∉ χ.dom := h_fresh.choose_spec.2
        have h_P_η : Formula.some_past pc.η ∈ χ.f pc.x := by
          have h_ax : DerivationTree [] ((Formula.snce pc.ξ pc.η).imp (Formula.some_past pc.η)) :=
            DerivationTree.axiom [] _ (Axiom.since_P pc.ξ pc.η)
          exact SetMaximalConsistent.implication_property h_mcs_x
            (theorem_in_mcs h_mcs_x h_ax) h_since
        have h_seed := past_temporal_witness_seed_consistent (χ.f pc.x) h_mcs_x pc.η h_P_η
        have h_lind := set_lindenbaum _ h_seed
        let C := h_lind.choose
        have h_sup : past_temporal_witness_seed (χ.f pc.x) pc.η ⊆ C := h_lind.choose_spec.1
        have h_C_mcs : SetMaximalConsistent C := h_lind.choose_spec.2
        have h_η_C : pc.η ∈ C := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
        have h_hc_sub : h_content (χ.f pc.x) ⊆ C :=
          Set.Subset.trans (h_content_subset_past_temporal_witness_seed (χ.f pc.x) pc.η) h_sup
        have h_y_lt_min : y < min_old := hy_lt min_old h_min_mem
        have h_B_exists := burgessR3Maximal_from_h_content_sub h_C_mcs h_mcs_x h_hc_sub
          (h_nubr3 C (χ.f pc.x) h_C_mcs h_mcs_x)
        let B_new := h_B_exists.choose
        have h_B_new_r3m : BurgessR3Maximal C B_new (χ.f pc.x) := h_B_exists.choose_spec
        let g' := fun a b =>
          if a = y ∧ b = min_old then B_new
          else χ.g a b
        let χ' : Chronicle := ⟨fun q => if q = y then C else χ.f q, g', insert y χ.dom⟩
        have h_c2'_new : χ'.c2' := by
          intro a b h_adj_new
          obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
          simp only [χ', Finset.mem_insert] at ha hb
          rcases ha with rfl | ha <;> rcases hb with rfl | hb
          · exact absurd hab (lt_irrefl _)
          · have hb_eq : b = min_old := by
              by_contra hb_ne
              have hb_ge : min_old ≤ b := h_min_le b hb
              have hb_gt : min_old < b := lt_of_le_of_ne hb_ge (Ne.symm hb_ne)
              exact h_no_between min_old (Finset.mem_insert_of_mem h_min_mem) ⟨h_y_lt_min, hb_gt⟩
            subst hb_eq
            show BurgessR3Maximal
              (if y = y then C else χ.f y)
              (g' y min_old)
              (if min_old = y then C else χ.f min_old)
            have hmin_ne_y : min_old ≠ y := ne_of_gt h_y_lt_min
            simp only [ite_true, hmin_ne_y, ite_false, g', and_self]
            rw [← h_eq_min]; exact h_B_new_r3m
          · exact absurd hab (not_lt.mpr (le_of_lt (hy_lt a ha)))
          · have ha_ne : a ≠ y := fun h => hy_notin (h ▸ ha)
            have hb_ne : b ≠ y := fun h => hy_notin (h ▸ hb)
            show BurgessR3Maximal
              (if a = y then C else χ.f a)
              (g' a b)
              (if b = y then C else χ.f b)
            simp only [ha_ne, hb_ne, ite_false]
            show BurgessR3Maximal (χ.f a)
              (if a = y ∧ b = min_old then B_new else χ.g a b) (χ.f b)
            rw [if_neg (fun ⟨hay, _⟩ => ha_ne hay)]
            have h_adj_old : Adjacent χ.dom a b := by
              refine ⟨ha, hb, hab, ?_⟩
              intro u hu ⟨hau, hub⟩
              exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
            exact h_c2' a b h_adj_old
        exact { val := χ'
                dom_sub := Finset.subset_insert y χ.dom
                c0 := by
                  intro q hq
                  show SetMaximalConsistent (if q = y then C else χ.f q)
                  change q ∈ insert y χ.dom at hq
                  simp only [Finset.mem_insert] at hq
                  rcases hq with rfl | hq
                  · simp only [ite_true]; exact h_C_mcs
                  · have h_ne : q ≠ y := fun h => hy_notin (h ▸ hq)
                    simp only [h_ne, ite_false]; exact h_c0 q hq
                f_agrees := by
                  intro x hx
                  have h_ne : x ≠ y := fun h => hy_notin (h ▸ hx)
                  exact if_neg h_ne
                g_agrees := by
                  intro a b ha hb
                  show g' a b = χ.g a b
                  simp only [g']
                  have ha_ne : a ≠ y := fun h => hy_notin (h ▸ ha)
                  simp only [ha_ne, false_and, ite_false]
                c2' := h_c2'_new
                c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                c5_backward_witness := by
                  intro _ _ _
                  refine ⟨y, Finset.mem_insert_self y χ.dom, hy_lt pc.x h_mem, ?_⟩
                  show pc.η ∈ (if y = y then C else χ.f y)
                  simp only [ite_true]
                  exact h_η_C
                c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                g_sub_f_insert := by
                  intro a b h_adj w hw hw_not haw hwb
                  change w ∈ insert y χ.dom at hw
                  simp only [Finset.mem_insert] at hw
                  rcases hw with rfl | hw
                  · exact absurd haw (not_lt.mpr (le_of_lt (hy_lt a h_adj.1)))
                  · exact absurd hw hw_not
                g_sub_g_new := by
                  intro a b h_adj w hw hw_not haw hwb
                  change w ∈ insert y χ.dom at hw
                  simp only [Finset.mem_insert] at hw
                  rcases hw with rfl | hw
                  · exact absurd haw (not_lt.mpr (le_of_lt (hy_lt a h_adj.1)))
                  · exact absurd hw hw_not
                dom_new_unique := by
                  intro u v hu hu_not hv hv_not
                  change u ∈ insert y χ.dom at hu
                  change v ∈ insert y χ.dom at hv
                  simp only [Finset.mem_insert] at hu hv
                  rcases hu with rfl | hu <;> rcases hv with rfl | hv
                  · rfl
                  · exact absurd hv hv_not
                  · exact absurd hu hu_not
                  · exact absurd hu hu_not }
      · -- **Case n≥1**: pc.x is NOT the minimum. Burgess 2.10' induction case (backward mirror).
        -- Find x'' = immediate predecessor of pc.x in dom.
        set T_pred := χ.dom.filter (fun v => decide (v < pc.x)) with T_pred_def
        have hT_ne_pred : T_pred.Nonempty := by
          have h_pc_gt_min : min_old < pc.x := lt_of_le_of_ne (h_min_le pc.x h_mem) (Ne.symm h_eq_min)
          exact ⟨min_old, Finset.mem_filter.mpr ⟨h_min_mem, by simp [h_pc_gt_min]⟩⟩
        set x'' := T_pred.max' hT_ne_pred with x''_def
        have hx''_mem_T := Finset.max'_mem T_pred hT_ne_pred
        have hx''_dom : x'' ∈ χ.dom := (Finset.mem_filter.mp hx''_mem_T).1
        have hx''_lt_x : x'' < pc.x := by
          have := (Finset.mem_filter.mp hx''_mem_T).2
          simp only [decide_eq_true_eq] at this; exact this
        have h_adj_x''x : Adjacent χ.dom x'' pc.x := by
          refine ⟨hx''_dom, h_mem, hx''_lt_x, ?_⟩
          intro u hu ⟨hx''u, hux⟩
          have hu_T : u ∈ T_pred := Finset.mem_filter.mpr ⟨hu, by simp [hux]⟩
          have := Finset.le_max' T_pred u hu_T
          linarith
        have h_mcs_x'' := h_c0 x'' hx''_dom
        -- Burgess 2.10' (ii): guard ∈ g(x'',x) implies event ∉ f(x'')
        have h_guard_implies_no_event_back : pc.ξ ∈ χ.g x'' pc.x → pc.η ∉ χ.f x'' :=
          fun h_guard h_event => h_no_wit ⟨x'', hx''_dom, hx''_lt_x, h_event, h_guard⟩
        -- Get BurgessR3Maximal for the adjacent pair (x'', pc.x)
        have h_r3m_adj := h_c2' x'' pc.x h_adj_x''x
        have h_B_sdc := BurgessR3Maximal_sdc h_r3m_adj h_nubr3 h_mcs_x'' h_mcs_x
        have h_gc_adj := BurgessR3Maximal_g_content_sub h_r3m_adj h_mcs_x'' h_mcs_x
        -- Backward condition (i) check: xi ∧ snce(xi, eta) ∈ f(x'') AND xi ∈ g(x'', pc.x)?
        -- Both parts needed for backward walk (Burgess 2.10 mirror).
        -- If yes, the Since counterexample persists backward. We walk backward.
        -- If no, splitting at (x'', pc.x) succeeds.
        by_cases h_cond_i_back : Formula.and pc.ξ (Formula.snce pc.ξ pc.η) ∈ χ.f x'' ∧ pc.ξ ∈ χ.g x'' pc.x
        · -- **Condition (i) backward**: conj_since ∈ f(x'') and xi ∈ g(x'',pc.x), so snce(xi,eta) ∈ f(x'').
          -- Backward walk: find leftmost w ≤ pc.x with snce(xi,eta) ∈ f(w)
          have h_snce_x'' : Formula.snce pc.ξ pc.η ∈ χ.f x'' :=
            conj_right_mcs h_mcs_x'' pc.ξ (Formula.snce pc.ξ pc.η) h_cond_i_back.1
          haveI : DecidablePred (fun w => w ≤ pc.x ∧ Formula.snce pc.ξ pc.η ∈ χ.f w) :=
            fun _ => Classical.dec _
          set W := χ.dom.filter (fun w => w ≤ pc.x ∧ Formula.snce pc.ξ pc.η ∈ χ.f w) with W_def
          have hW_ne : W.Nonempty :=
            ⟨pc.x, Finset.mem_filter.mpr ⟨h_mem, le_refl _, h_since⟩⟩
          set w_min := W.min' hW_ne with w_min_def
          have hw_min_mem_W := Finset.min'_mem W hW_ne
          have hw_min_dom : w_min ∈ χ.dom := (Finset.mem_filter.mp hw_min_mem_W).1
          have hw_min_le : w_min ≤ pc.x := (Finset.mem_filter.mp hw_min_mem_W).2.1
          have h_snce_w_min : Formula.snce pc.ξ pc.η ∈ χ.f w_min :=
            (Finset.mem_filter.mp hw_min_mem_W).2.2
          have h_mcs_w_min := h_c0 w_min hw_min_dom
          by_cases h_w_is_min : w_min = min_old
          · -- Walk Case A: snce persists to min_old. Insert point below min_old.
            -- Use past_temporal_witness_seed approach (mirror of n=0 case).
            have h_fresh := exists_rat_lt_finset χ.dom
            let y := h_fresh.choose
            have hy_lt : ∀ s ∈ χ.dom, y < s := h_fresh.choose_spec.1
            have hy_notin : y ∉ χ.dom := h_fresh.choose_spec.2
            have h_P_eta := since_implies_P_in_mcs h_mcs_w_min h_snce_w_min
            have h_seed := past_temporal_witness_seed_consistent (χ.f w_min) h_mcs_w_min pc.η h_P_eta
            have h_lind := set_lindenbaum _ h_seed
            let C' := h_lind.choose
            have h_sup : past_temporal_witness_seed (χ.f w_min) pc.η ⊆ C' := h_lind.choose_spec.1
            have h_C'_mcs : SetMaximalConsistent C' := h_lind.choose_spec.2
            have h_η_C' : pc.η ∈ C' := h_sup (psi_mem_past_temporal_witness_seed (χ.f w_min) pc.η)
            have h_hc_sub : h_content (χ.f w_min) ⊆ C' :=
              Set.Subset.trans (h_content_subset_past_temporal_witness_seed (χ.f w_min) pc.η) h_sup
            have h_B_exists := burgessR3Maximal_from_h_content_sub h_C'_mcs h_mcs_w_min h_hc_sub
              (h_nubr3 C' (χ.f w_min) h_C'_mcs h_mcs_w_min)
            let B_new := h_B_exists.choose
            have h_B_new_max : BurgessR3Maximal C' B_new (χ.f w_min) := h_B_exists.choose_spec
            have h_min_lt_y : y < min_old := hy_lt min_old h_min_mem
            let g' := fun a b => if a = y ∧ b = min_old then B_new else χ.g a b
            let χ' : Chronicle := ⟨fun q => if q = y then C' else χ.f q, g', insert y χ.dom⟩
            have h_c2'_new : χ'.c2' := by
              intro a b h_adj_new
              obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
              simp only [χ', Finset.mem_insert] at ha hb
              rcases ha with rfl | ha <;> rcases hb with rfl | hb
              · exact absurd hab (lt_irrefl _)
              · -- a = y, b ∈ old dom: must be (y, min_old)
                have hb_eq : b = min_old := by
                  by_contra hb_ne
                  have hb_le : min_old ≤ b := h_min_le b hb
                  have hb_gt : min_old < b := lt_of_le_of_ne hb_le (Ne.symm hb_ne)
                  exact h_no_between min_old (Finset.mem_insert_of_mem h_min_mem) ⟨h_min_lt_y, hb_gt⟩
                subst hb_eq
                show BurgessR3Maximal (if y = y then C' else χ.f y) (g' y min_old) (if min_old = y then C' else χ.f min_old)
                have hmin_ne_y : min_old ≠ y := ne_of_gt h_min_lt_y
                simp only [ite_true, hmin_ne_y, ite_false, g', and_self, ite_true]
                rw [← h_w_is_min]; exact h_B_new_max
              · -- a ∈ old dom, b = y: impossible (y < all dom)
                exact absurd hab (not_lt.mpr (le_of_lt (hy_lt a ha)))
              · -- Both old: preserved
                have ha_ne : a ≠ y := fun h => hy_notin (h ▸ ha)
                have hb_ne : b ≠ y := fun h => hy_notin (h ▸ hb)
                show BurgessR3Maximal (if a = y then C' else χ.f a) (g' a b) (if b = y then C' else χ.f b)
                simp only [ha_ne, hb_ne, ite_false, g', false_and, ite_false]
                exact h_c2' a b ⟨ha, hb, hab, fun u hu huab => h_no_between u (Finset.mem_insert_of_mem hu) huab⟩
            exact { val := χ'
                    dom_sub := Finset.subset_insert y χ.dom
                    c0 := by
                      intro q hq; show SetMaximalConsistent (if q = y then C' else χ.f q)
                      change q ∈ insert y χ.dom at hq
                      simp only [Finset.mem_insert] at hq
                      rcases hq with rfl | hq
                      · simp only [ite_true]; exact h_C'_mcs
                      · have h_ne : q ≠ y := fun h => hy_notin (h ▸ hq)
                        simp only [h_ne, ite_false]; exact h_c0 q hq
                    f_agrees := by
                      intro x hx
                      have h_ne : x ≠ y := fun h => hy_notin (h ▸ hx)
                      exact if_neg h_ne
                    g_agrees := by
                      intro a b ha hb; show g' a b = χ.g a b; simp only [g']
                      have ha_ne : a ≠ y := fun h => hy_notin (h ▸ ha)
                      simp only [ha_ne, false_and, ite_false]
                    c2' := h_c2'_new
                    c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                    c5_backward_witness := by
                      intro _ _ _
                      refine ⟨y, Finset.mem_insert_self y χ.dom, ?_, ?_⟩
                      · exact lt_of_lt_of_le (hy_lt w_min hw_min_dom) hw_min_le
                      · show pc.η ∈ (if y = y then C' else χ.f y)
                        simp only [ite_true]; exact h_η_C'
                    c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                    c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                    density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                    g_sub_f_insert := by
                      intro a b h_adj w hw hw_not haw hwb
                      change w ∈ insert y χ.dom at hw
                      simp only [Finset.mem_insert] at hw
                      rcases hw with rfl | hw
                      · exact absurd haw (not_lt.mpr (le_of_lt (hy_lt a h_adj.1)))
                      · exact absurd hw hw_not
                    g_sub_g_new := by
                      intro a b h_adj w hw hw_not haw hwb
                      change w ∈ insert y χ.dom at hw
                      simp only [Finset.mem_insert] at hw
                      rcases hw with rfl | hw
                      · exact absurd haw (not_lt.mpr (le_of_lt (hy_lt a h_adj.1)))
                      · exact absurd hw hw_not
                    dom_new_unique := by
                      intro u v hu hu_not hv hv_not
                      change u ∈ insert y χ.dom at hu
                      change v ∈ insert y χ.dom at hv
                      simp only [Finset.mem_insert] at hu hv
                      rcases hu with rfl | hu <;> rcases hv with rfl | hv
                      · rfl
                      · exact absurd hv hv_not
                      · exact absurd hu hu_not
                      · exact absurd hu hu_not }
          · -- Walk Case B: w_min > min_old. Find predecessor and split.
            have h_w_gt_min : min_old < w_min :=
              lt_of_le_of_ne (h_min_le w_min hw_min_dom) (Ne.symm h_w_is_min)
            set T_w := χ.dom.filter (fun v => decide (v < w_min)) with T_w_def
            have hT_w_ne : T_w.Nonempty :=
              ⟨min_old, Finset.mem_filter.mpr ⟨h_min_mem, by simp [h_w_gt_min]⟩⟩
            set w_prev := T_w.max' hT_w_ne
            have hw_prev_mem_T := Finset.max'_mem T_w hT_w_ne
            have hw_prev_dom : w_prev ∈ χ.dom := (Finset.mem_filter.mp hw_prev_mem_T).1
            have h_prev_lt_w : w_prev < w_min := by
              have := (Finset.mem_filter.mp hw_prev_mem_T).2; simp only [decide_eq_true_eq] at this; exact this
            have h_adj_pw : Adjacent χ.dom w_prev w_min := by
              refine ⟨hw_prev_dom, hw_min_dom, h_prev_lt_w, ?_⟩
              intro u hu ⟨hpu, huw⟩
              have hu_T : u ∈ T_w := Finset.mem_filter.mpr ⟨hu, by simp [huw]⟩
              linarith [Finset.le_max' T_w u hu_T]
            -- snce(xi,eta) ∉ f(w_prev) by minimality of w_min
            have h_snce_not_prev : Formula.snce pc.ξ pc.η ∉ χ.f w_prev := by
              intro h_in
              exact absurd (Finset.min'_le W w_prev
                (Finset.mem_filter.mpr ⟨hw_prev_dom, le_of_lt (lt_of_lt_of_le h_prev_lt_w hw_min_le), h_in⟩))
                (not_le.mpr h_prev_lt_w)
            have h_conj_not_prev : Formula.and pc.ξ (Formula.snce pc.ξ pc.η) ∉ χ.f w_prev :=
              fun h_conj => h_snce_not_prev (conj_right_mcs (h_c0 w_prev hw_prev_dom) pc.ξ (Formula.snce pc.ξ pc.η) h_conj)
            have h_mcs_w_prev := h_c0 w_prev hw_prev_dom
            have h_r3m_pw := h_c2' w_prev w_min h_adj_pw
            have h_B_sdc_pw := BurgessR3Maximal_sdc h_r3m_pw h_nubr3 h_mcs_w_prev h_mcs_w_min
            have h_gc_pw := BurgessR3Maximal_g_content_sub h_r3m_pw h_mcs_w_prev h_mcs_w_min
            by_cases h_eta_w_prev : pc.η ∈ χ.f w_prev
            · -- eta ∈ f(w_prev): direct backward witness
              exact { val := χ
                      dom_sub := Finset.Subset.refl _
                      c0 := h_c0
                      f_agrees := fun _ _ => rfl
                      g_agrees := fun _ _ _ _ => rfl
                      c2' := h_c2'
                      c5_forward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
                      c5_backward_witness := by
                        intro _ _ _
                        exact ⟨w_prev, hw_prev_dom, lt_of_lt_of_le h_prev_lt_w hw_min_le, h_eta_w_prev⟩
                      c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      g_sub_f_insert := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
                      g_sub_g_new := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
                      dom_new_unique := fun u _ hu hu_not _ _ => absurd hu hu_not }
            · -- eta ∉ f(w_prev): split at (w_prev, w_min). Condition (i) fails here.
              have h_eta_neg_w_prev : pc.η.neg ∈ χ.f w_prev := by
                rcases SetMaximalConsistent.negation_complete h_mcs_w_prev pc.η with h | h
                · exact absurd h h_eta_w_prev
                · exact h
              -- Full splitting case analysis at (w_prev, w_min)
              have h_split_pw : ∃ B' D B'' : Set Formula,
                  BurgessR3Maximal (χ.f w_prev) B' D ∧
                  BurgessR3Maximal D B'' (χ.f w_min) ∧
                  SetMaximalConsistent D ∧ pc.η ∈ D ∧
                  χ.g w_prev w_min ⊆ D ∧
                  χ.g w_prev w_min ⊆ B' ∧
                  χ.g w_prev w_min ⊆ B'' := by
                by_cases h_eta_g_pw : pc.η ∈ χ.g w_prev w_min
                · have h_sp := lemma_2_6_splitting h_mcs_w_prev h_mcs_w_min h_r3m_pw h_B_sdc_pw h_gc_pw
                    pc.η.neg (fun h_neg => set_consistent_not_both h_B_sdc_pw.1 pc.η h_eta_g_pw h_neg) h_nubr3
                  obtain ⟨B', D, B'', hB', hB'', hD, h_dne, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩ := h_sp
                  exact ⟨B', D, B'', hB', hB'', hD,
                    SetMaximalConsistent.implication_property hD
                      (theorem_in_mcs hD (Bimodal.Theorems.Propositional.double_negation pc.η)) h_dne, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
                · by_cases h_eta_neg_g_pw : pc.η.neg ∈ χ.g w_prev w_min
                  · by_cases h_xi_g_pw : pc.ξ ∈ χ.g w_prev w_min
                    · by_cases h_conj_g_pw : Formula.and pc.ξ (Formula.snce pc.ξ pc.η) ∈ χ.g w_prev w_min
                      · -- conj ∈ g, condition (i) false at w_prev: lemma_2_8_since
                        have h2 : (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)).neg ∈ χ.f w_prev := by
                          rcases SetMaximalConsistent.negation_complete h_mcs_w_prev
                            (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)) with h | h
                          · exact absurd h h_conj_not_prev
                          · exact h
                        have h_neg_disj_pw : (Formula.or pc.η (Formula.and pc.ξ (Formula.snce pc.ξ pc.η))).neg ∈ χ.f w_prev :=
                          SetMaximalConsistent.implication_property h_mcs_w_prev
                            (theorem_in_mcs h_mcs_w_prev
                              (Bimodal.Theorems.Propositional.demorgan_disj_neg_backward pc.η
                                (Formula.and pc.ξ (Formula.snce pc.ξ pc.η))))
                            (conj_mcs h_mcs_w_prev pc.η.neg _ h_eta_neg_w_prev h2)
                        obtain ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩ := lemma_2_8_since h_mcs_w_prev h_mcs_w_min h_r3m_pw h_B_sdc_pw h_gc_pw
                          pc.ξ pc.η h_snce_w_min h_neg_disj_pw h_nubr3
                        exact ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
                      · obtain ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_B', h_B_sub_D, h_B_sub_B''⟩ := lemma_2_7_since h_mcs_w_prev h_mcs_w_min h_r3m_pw h_B_sdc_pw h_gc_pw
                          (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)) pc.η (self_accum_since_mcs h_mcs_w_min pc.ξ pc.η h_snce_w_min) h_conj_g_pw h_nubr3
                        exact ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
                    · obtain ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_B', h_B_sub_D, h_B_sub_B''⟩ :=
                        lemma_2_7_since h_mcs_w_prev h_mcs_w_min h_r3m_pw h_B_sdc_pw h_gc_pw
                          pc.ξ pc.η h_snce_w_min h_xi_g_pw h_nubr3
                      exact ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
                  · have h_sp := lemma_2_6_splitting h_mcs_w_prev h_mcs_w_min h_r3m_pw h_B_sdc_pw h_gc_pw
                      pc.η.neg h_eta_neg_g_pw h_nubr3
                    obtain ⟨B', D, B'', hB', hB'', hD, h_dne, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩ := h_sp
                    exact ⟨B', D, B'', hB', hB'', hD,
                      SetMaximalConsistent.implication_property hD
                        (theorem_in_mcs hD (Bimodal.Theorems.Propositional.double_negation pc.η)) h_dne, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
              let B' := h_split_pw.choose
              let D := h_split_pw.choose_spec.choose
              let B'' := h_split_pw.choose_spec.choose_spec.choose
              have h_split_prop := h_split_pw.choose_spec.choose_spec.choose_spec
              have h_g_sub_B' : χ.g w_prev w_min ⊆ B' := h_split_prop.2.2.2.2.2.1
              have h_g_sub_B'' : χ.g w_prev w_min ⊆ B'' := h_split_prop.2.2.2.2.2.2
              -- Insert z = midpoint of w_prev and w_min
              set z := (w_prev + w_min) / 2 with hz_def
              have hz_lt_w : z < w_min := by linarith
              have hprev_lt_z : w_prev < z := by linarith
              have hz_notin : z ∉ χ.dom := fun h_mem_z => h_adj_pw.2.2.2 z h_mem_z ⟨hprev_lt_z, hz_lt_w⟩
              let g' := fun a b =>
                if a = w_prev ∧ b = z then B'
                else if a = z ∧ b = w_min then B''
                else χ.g a b
              let χ' : Chronicle := ⟨fun q => if q = z then D else χ.f q, g', insert z χ.dom⟩
              have h_c2'_new : χ'.c2' := by
                intro a b h_adj_new
                obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
                simp only [χ', Finset.mem_insert] at ha hb
                rcases ha with rfl | ha <;> rcases hb with rfl | hb
                · exact absurd hab (lt_irrefl _)
                · -- a = z, b ∈ old: must be (z, w_min)
                  have hb_eq : b = w_min := by
                    by_contra hb_ne
                    have hb_ge : w_min ≤ b := by
                      by_contra hlt; push_neg at hlt
                      exact h_adj_pw.2.2.2 b hb ⟨lt_trans hprev_lt_z hab, hlt⟩
                    exact h_no_between w_min (Finset.mem_insert_of_mem hw_min_dom)
                      ⟨hz_lt_w, lt_of_le_of_ne hb_ge (Ne.symm hb_ne)⟩
                  subst hb_eq
                  show BurgessR3Maximal (if z = z then D else χ.f z) (g' z w_min) (if w_min = z then D else χ.f w_min)
                  simp only [ite_true, show w_min ≠ z from by linarith, ite_false, g', and_false, ite_false, and_self, ite_true]
                  exact h_split_prop.2.1
                · -- a ∈ old, b = z: must be (w_prev, z)
                  have ha_eq : a = w_prev := by
                    by_contra ha_ne
                    have ha_le : a ≤ w_prev := by
                      by_contra hgt; push_neg at hgt
                      exact h_adj_pw.2.2.2 a ha ⟨hgt, lt_trans hab hz_lt_w⟩
                    exact h_no_between w_prev (Finset.mem_insert_of_mem hw_prev_dom)
                      ⟨lt_of_le_of_ne ha_le ha_ne, hprev_lt_z⟩
                  subst ha_eq
                  show BurgessR3Maximal (if w_prev = z then D else χ.f w_prev) (g' w_prev z) (if z = z then D else χ.f z)
                  simp only [show w_prev ≠ z from by linarith, ite_false, ite_true, g']
                  exact h_split_prop.1
                · -- Both old
                  have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                  have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                  show BurgessR3Maximal (if a = z then D else χ.f a) (g' a b) (if b = z then D else χ.f b)
                  simp only [ha_ne, hb_ne, ite_false, g', and_false, false_and]
                  exact h_c2' a b ⟨ha, hb, hab, fun u hu huab => h_no_between u (Finset.mem_insert_of_mem hu) huab⟩
              exact { val := χ'
                      dom_sub := Finset.subset_insert z χ.dom
                      c0 := by
                        intro q hq; show SetMaximalConsistent (if q = z then D else χ.f q)
                        change q ∈ insert z χ.dom at hq
                        simp only [Finset.mem_insert] at hq
                        rcases hq with rfl | hq
                        · simp only [ite_true]; exact h_split_prop.2.2.1
                        · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                          simp only [h_ne, ite_false]; exact h_c0 q hq
                      f_agrees := by
                        intro x hx
                        have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
                        exact if_neg h_ne
                      g_agrees := by
                        intro a b ha hb; show g' a b = χ.g a b; simp only [g']
                        have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                        have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                        simp only [ha_ne, hb_ne, false_and, and_false, ite_false]
                      c2' := h_c2'_new
                      c5_forward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
                      c5_backward_witness := by
                        intro _ _ _
                        refine ⟨z, Finset.mem_insert_self z χ.dom, ?_, ?_⟩
                        · exact lt_of_lt_of_le hz_lt_w hw_min_le
                        · show pc.η ∈ (if z = z then D else χ.f z); simp only [ite_true]; exact h_split_prop.2.2.2.1
                      c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                      g_sub_f_insert := by
                        intro a b h_adj w hw hw_not haw hwb
                        simp only [χ', Finset.mem_insert] at hw
                        rcases hw with rfl | hw
                        · show χ.g a b ⊆ (if z = z then D else χ.f z)
                          simp only [ite_true]
                          have hab : a = w_prev ∧ b = w_min := by
                            constructor
                            · by_contra ha_ne
                              have : a < w_prev ∨ w_prev < a := lt_or_gt_of_ne ha_ne
                              rcases this with h | h
                              · exact h_adj.2.2.2 w_prev hw_prev_dom ⟨h, lt_trans hprev_lt_z hwb⟩
                              · exact h_adj_pw.2.2.2 a h_adj.1 ⟨h, lt_trans haw hz_lt_w⟩
                            · by_contra hb_ne
                              have : b < w_min ∨ w_min < b := lt_or_gt_of_ne hb_ne
                              rcases this with h | h
                              · exact h_adj_pw.2.2.2 b h_adj.2.1 ⟨lt_trans hprev_lt_z hwb, h⟩
                              · exact h_adj.2.2.2 w_min hw_min_dom ⟨lt_trans haw hz_lt_w, h⟩
                          rw [hab.1, hab.2]; exact h_split_prop.2.2.2.2.1
                        · exact absurd hw hw_not
                      g_sub_g_new := by
                        intro a b h_adj w hw hw_not haw hwb
                        simp only [χ', Finset.mem_insert] at hw
                        rcases hw with rfl | hw
                        · have ha_eq : a = w_prev := by
                            by_contra ha_ne
                            rcases lt_or_gt_of_ne ha_ne with h | h
                            · exact h_adj.2.2.2 w_prev hw_prev_dom ⟨h, lt_trans hprev_lt_z hwb⟩
                            · exact h_adj_pw.2.2.2 a h_adj.1 ⟨h, lt_trans haw hz_lt_w⟩
                          have hb_eq : b = w_min := by
                            by_contra hb_ne
                            rcases lt_or_gt_of_ne hb_ne with h | h
                            · exact h_adj_pw.2.2.2 b h_adj.2.1 ⟨lt_trans hprev_lt_z hwb, h⟩
                            · exact h_adj.2.2.2 w_min hw_min_dom ⟨lt_trans haw hz_lt_w, h⟩
                          subst ha_eq; subst hb_eq
                          constructor
                          · show χ.g w_prev w_min ⊆ g' w_prev z
                            simp only [g', and_self, ite_true]
                            exact h_g_sub_B'
                          · show χ.g w_prev w_min ⊆ g' z w_min
                            simp only [g']
                            have : ¬(z = w_prev ∧ w_min = z) := by
                              intro ⟨h1, _⟩; linarith
                            simp only [this, ite_false, and_self, ite_true]
                            exact h_g_sub_B''
                        · exact absurd hw hw_not
                      dom_new_unique := by
                        intro u v hu hu_not hv hv_not
                        simp only [χ', Finset.mem_insert] at hu hv
                        rcases hu with rfl | hu <;> rcases hv with rfl | hv
                        · rfl
                        · exact absurd hv hv_not
                        · exact absurd hu hu_not
                        · exact absurd hu hu_not }
        · -- **Not condition (i) backward**: splitting at (x'', pc.x) succeeds.
          have h_bot_not_g : Formula.bot ∉ χ.g x'' pc.x := by
            intro h_bot
            exact h_B_sdc.1 [Formula.bot] (fun φ hφ => by simp at hφ; rw [hφ]; exact h_bot)
              ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
          have h_split_result : ∃ B' D B'' : Set Formula,
            BurgessR3Maximal (χ.f x'') B' D ∧
            BurgessR3Maximal D B'' (χ.f pc.x) ∧
            SetMaximalConsistent D ∧
            pc.η ∈ D ∧
            χ.g x'' pc.x ⊆ D ∧
            χ.g x'' pc.x ⊆ B' ∧
            χ.g x'' pc.x ⊆ B'' := by
            by_cases h_eta_g : pc.η ∈ χ.g x'' pc.x
            · have h_eta_neg_not_g : pc.η.neg ∉ χ.g x'' pc.x :=
                fun h_neg => set_consistent_not_both h_B_sdc.1 pc.η h_eta_g h_neg
              have h_split := lemma_2_6_splitting h_mcs_x'' h_mcs_x h_r3m_adj h_B_sdc h_gc_adj
                pc.η.neg h_eta_neg_not_g h_nubr3
              obtain ⟨B', D, B'', h_B', h_B'', h_D_mcs, h_eta_neg_neg_D, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩ := h_split
              have h_eta_D : pc.η ∈ D :=
                SetMaximalConsistent.implication_property h_D_mcs
                  (theorem_in_mcs h_D_mcs (Bimodal.Theorems.Propositional.double_negation pc.η)) h_eta_neg_neg_D
              exact ⟨B', D, B'', h_B', h_B'', h_D_mcs, h_eta_D, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
            · by_cases h_eta_neg_g : pc.η.neg ∈ χ.g x'' pc.x
              · by_cases h_xi_g : pc.ξ ∈ χ.g x'' pc.x
                · by_cases h_conj_g : Formula.and pc.ξ (Formula.snce pc.ξ pc.η) ∈ χ.g x'' pc.x
                  · have h_conj_not_f_back : Formula.and pc.ξ (Formula.snce pc.ξ pc.η) ∉ χ.f x'' :=
                      fun h_conj_f => h_cond_i_back ⟨h_conj_f, h_xi_g⟩
                    have h_neg_disj_x'' : (Formula.or pc.η (Formula.and pc.ξ (Formula.snce pc.ξ pc.η))).neg ∈ χ.f x'' := by
                      have h_neg_conj_x'' : (pc.η.neg.and (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)).neg) ∈ χ.f x'' := by
                        have h2 : (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)).neg ∈ χ.f x'' := by
                          rcases SetMaximalConsistent.negation_complete h_mcs_x''
                            (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)) with h | h
                          · exact absurd h h_conj_not_f_back
                          · exact h
                        have h_eta_neg_x''_local : pc.η.neg ∈ χ.f x'' := by
                          rcases SetMaximalConsistent.negation_complete h_mcs_x'' pc.η with h | h
                          · exact absurd h (h_guard_implies_no_event_back h_xi_g)
                          · exact h
                        exact conj_mcs h_mcs_x'' pc.η.neg
                          (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)).neg h_eta_neg_x''_local h2
                      exact SetMaximalConsistent.implication_property h_mcs_x''
                        (theorem_in_mcs h_mcs_x''
                          (Bimodal.Theorems.Propositional.demorgan_disj_neg_backward pc.η
                            (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)))) h_neg_conj_x''
                    obtain ⟨B', D, B'', hB', hB'', hD_mcs, hη_D, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩ := lemma_2_8_since h_mcs_x'' h_mcs_x h_r3m_adj h_B_sdc h_gc_adj
                      pc.ξ pc.η h_since h_neg_disj_x'' h_nubr3
                    exact ⟨B', D, B'', hB', hB'', hD_mcs, hη_D, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
                  · have h_bx5_since := self_accum_since_mcs h_mcs_x pc.ξ pc.η h_since
                    obtain ⟨B', D, B'', hB', hB'', hD_mcs, hη_D, h_B_sub_B', h_B_sub_D, h_B_sub_B''⟩ := lemma_2_7_since h_mcs_x'' h_mcs_x h_r3m_adj h_B_sdc h_gc_adj
                      (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)) pc.η h_bx5_since h_conj_g h_nubr3
                    exact ⟨B', D, B'', hB', hB'', hD_mcs, hη_D, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
                · obtain ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_B', h_B_sub_D, h_B_sub_B''⟩ :=
                    lemma_2_7_since h_mcs_x'' h_mcs_x h_r3m_adj h_B_sdc h_gc_adj
                      pc.ξ pc.η h_since h_xi_g h_nubr3
                  exact ⟨B', D, B'', hB', hB'', hD, hη, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
              · have h_split := lemma_2_6_splitting h_mcs_x'' h_mcs_x h_r3m_adj h_B_sdc h_gc_adj
                  pc.η.neg h_eta_neg_g h_nubr3
                obtain ⟨B', D, B'', h_B', h_B'', h_D_mcs, h_eta_neg_neg_D, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩ := h_split
                have h_eta_D : pc.η ∈ D :=
                  SetMaximalConsistent.implication_property h_D_mcs
                    (theorem_in_mcs h_D_mcs (Bimodal.Theorems.Propositional.double_negation pc.η)) h_eta_neg_neg_D
                exact ⟨B', D, B'', h_B', h_B'', h_D_mcs, h_eta_D, h_B_sub_D, h_B_sub_B', h_B_sub_B''⟩
          let B' := h_split_result.choose
          let D := h_split_result.choose_spec.choose
          let B'' := h_split_result.choose_spec.choose_spec.choose
          have h_split_prop := h_split_result.choose_spec.choose_spec.choose_spec
          have h_B'_max : BurgessR3Maximal (χ.f x'') B' D := h_split_prop.1
          have h_B''_max : BurgessR3Maximal D B'' (χ.f pc.x) := h_split_prop.2.1
          have h_D_mcs : SetMaximalConsistent D := h_split_prop.2.2.1
          have h_η_D : pc.η ∈ D := h_split_prop.2.2.2.1
          have h_g_sub_D : χ.g x'' pc.x ⊆ D := h_split_prop.2.2.2.2.1
          have h_g_sub_B' : χ.g x'' pc.x ⊆ B' := h_split_prop.2.2.2.2.2.1
          have h_g_sub_B'' : χ.g x'' pc.x ⊆ B'' := h_split_prop.2.2.2.2.2.2
          -- Insert z = midpoint of x'' and pc.x
          set z := (x'' + pc.x) / 2 with hz_def
          have hz_lt_x : z < pc.x := by linarith
          have hx''_lt_z : x'' < z := by linarith
          have hz_notin : z ∉ χ.dom := by
            intro h_mem_z; exact h_adj_x''x.2.2.2 z h_mem_z ⟨hx''_lt_z, hz_lt_x⟩
          -- Build new chronicle with f'(z) = D
          let g' := fun a b =>
            if a = x'' ∧ b = z then B'
            else if a = z ∧ b = pc.x then B''
            else χ.g a b
          let χ' : Chronicle := ⟨fun q => if q = z then D else χ.f q, g', insert z χ.dom⟩
          have h_c2'_new : χ'.c2' := by
            intro a b h_adj_new
            obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
            simp only [χ', Finset.mem_insert] at ha hb
            rcases ha with rfl | ha <;> rcases hb with rfl | hb
            · exact absurd hab (lt_irrefl _)
            · -- a = z, b ∈ old dom: must be (z, pc.x)
              have hb_eq : b = pc.x := by
                by_contra hb_ne
                have hb_ge : pc.x ≤ b := by
                  by_contra hlt; push_neg at hlt
                  have : x'' < b := lt_trans hx''_lt_z hab
                  exact h_adj_x''x.2.2.2 b hb ⟨this, hlt⟩
                have hb_gt : pc.x < b := lt_of_le_of_ne hb_ge (Ne.symm hb_ne)
                exact h_no_between pc.x (Finset.mem_insert_of_mem h_mem) ⟨hz_lt_x, hb_gt⟩
              subst hb_eq
              show BurgessR3Maximal
                (if z = z then D else χ.f z)
                (g' z pc.x)
                (if pc.x = z then D else χ.f pc.x)
              have hx_ne : pc.x ≠ z := by linarith
              simp only [ite_true, hx_ne, ite_false, g']
              simp only [ite_false, ite_true, and_false, and_self]
              exact h_B''_max
            · -- a ∈ old dom, b = z: must be (x'', z)
              have ha_eq : a = x'' := by
                by_contra ha_ne
                have ha_le : a ≤ x'' := by
                  by_contra hgt; push_neg at hgt
                  exact h_adj_x''x.2.2.2 a ha ⟨hgt, lt_trans hab hz_lt_x⟩
                have ha_lt : a < x'' := lt_of_le_of_ne ha_le ha_ne
                exact h_no_between x'' (Finset.mem_insert_of_mem hx''_dom) ⟨ha_lt, hx''_lt_z⟩
              subst ha_eq
              show BurgessR3Maximal
                (if x'' = z then D else χ.f x'')
                (g' x'' z)
                (if z = z then D else χ.f z)
              have hx''_ne : x'' ≠ z := by linarith
              simp only [hx''_ne, ite_false, ite_true, g']
              exact h_B'_max
            · -- Both old: preserved
              have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
              have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
              show BurgessR3Maximal
                (if a = z then D else χ.f a)
                (g' a b)
                (if b = z then D else χ.f b)
              simp only [ha_ne, hb_ne, ite_false, g', and_false, false_and]
              have h_adj_old : Adjacent χ.dom a b := by
                refine ⟨ha, hb, hab, ?_⟩
                intro u hu ⟨hau, hub⟩
                exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
              exact h_c2' a b h_adj_old
          exact { val := χ'
                  dom_sub := Finset.subset_insert z χ.dom
                  c0 := by
                    intro q hq
                    show SetMaximalConsistent (if q = z then D else χ.f q)
                    change q ∈ insert z χ.dom at hq
                    simp only [Finset.mem_insert] at hq
                    rcases hq with rfl | hq
                    · simp only [ite_true]; exact h_D_mcs
                    · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                      simp only [h_ne, ite_false]; exact h_c0 q hq
                  f_agrees := by
                    intro x hx
                    have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
                    exact if_neg h_ne
                  g_agrees := by
                    intro a b ha hb
                    show g' a b = χ.g a b
                    simp only [g']
                    have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                    have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                    simp only [ha_ne, hb_ne, false_and, and_false, ite_false]
                  c2' := h_c2'_new
                  c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                  c5_backward_witness := by
                    intro _ _ _
                    refine ⟨z, Finset.mem_insert_self z χ.dom, hz_lt_x, ?_⟩
                    show pc.η ∈ (if z = z then D else χ.f z)
                    simp only [ite_true]
                    exact h_η_D
                  c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                  c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                  density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
                  g_sub_f_insert := by
                    intro a b h_adj w hw hw_not haw hwb
                    simp only [χ', Finset.mem_insert] at hw
                    rcases hw with rfl | hw
                    · show χ.g a b ⊆ (if z = z then D else χ.f z)
                      simp only [ite_true]
                      have hab : a = x'' ∧ b = pc.x := by
                        constructor
                        · by_contra ha_ne
                          have : a < x'' ∨ x'' < a := lt_or_gt_of_ne ha_ne
                          rcases this with h | h
                          · exact h_adj.2.2.2 x'' hx''_dom ⟨h, lt_trans hx''_lt_z hwb⟩
                          · exact h_adj_x''x.2.2.2 a h_adj.1 ⟨h, lt_trans haw hz_lt_x⟩
                        · by_contra hb_ne
                          have : b < pc.x ∨ pc.x < b := lt_or_gt_of_ne hb_ne
                          rcases this with h | h
                          · exact h_adj_x''x.2.2.2 b h_adj.2.1 ⟨lt_trans hx''_lt_z hwb, h⟩
                          · exact h_adj.2.2.2 pc.x h_mem ⟨lt_trans haw hz_lt_x, h⟩
                      rw [hab.1, hab.2]; exact h_g_sub_D
                    · exact absurd hw hw_not
                  g_sub_g_new := by
                    intro a b h_adj w hw hw_not haw hwb
                    simp only [χ', Finset.mem_insert] at hw
                    rcases hw with rfl | hw
                    · have ha_eq : a = x'' := by
                        by_contra ha_ne
                        rcases lt_or_gt_of_ne ha_ne with h | h
                        · exact h_adj.2.2.2 x'' hx''_dom ⟨h, lt_trans hx''_lt_z hwb⟩
                        · exact h_adj_x''x.2.2.2 a h_adj.1 ⟨h, lt_trans haw hz_lt_x⟩
                      have hb_eq : b = pc.x := by
                        by_contra hb_ne
                        rcases lt_or_gt_of_ne hb_ne with h | h
                        · exact h_adj_x''x.2.2.2 b h_adj.2.1 ⟨lt_trans hx''_lt_z hwb, h⟩
                        · exact h_adj.2.2.2 pc.x h_mem ⟨lt_trans haw hz_lt_x, h⟩
                      subst ha_eq; subst hb_eq
                      constructor
                      · show χ.g x'' pc.x ⊆ g' x'' z
                        simp only [g', and_self, ite_true]
                        exact h_g_sub_B'
                      · show χ.g x'' pc.x ⊆ g' z pc.x
                        simp only [g']
                        have : ¬(z = x'' ∧ pc.x = z) := by
                          intro ⟨h1, _⟩; linarith
                        simp only [this, ite_false, and_self, ite_true]
                        exact h_g_sub_B''
                    · exact absurd hw hw_not
                  dom_new_unique := by
                    intro u v hu hu_not hv hv_not
                    simp only [χ', Finset.mem_insert] at hu hv
                    rcases hu with rfl | hu <;> rcases hv with rfl | hv
                    · rfl
                    · exact absurd hv hv_not
                    · exact absurd hu hu_not
                    · exact absurd hu hu_not }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              g_agrees := fun _ _ _ _ => rfl
              c2' := by exact h_c2'
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := by
                intro _ h_mem h_since
                push_neg at h_actual
                obtain ⟨y, hy_dom, hy_lt, hy_η, _⟩ := h_actual h_mem h_since
                exact ⟨y, hy_dom, hy_lt, hy_η⟩
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              g_sub_f_insert := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              g_sub_g_new := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              dom_new_unique := fun u _ hu hu_not _ _ => absurd hu hu_not }
  | .c4_forward =>
    -- Forward C4 case (corrected Burgess C4a: check EVENT η at f(y), negate GUARD ξ at f(z))
    -- Now checks ALL pairs x < y, not just adjacent pairs.
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧
        pc.x < pc.y ∧
        (Formula.untl pc.ξ pc.η).neg ∈ χ.f pc.x ∧
        pc.η ∈ χ.f pc.y ∧
        ¬∃ z ∈ χ.dom, pc.x < z ∧ z < pc.y ∧ pc.ξ.neg ∈ χ.f z
    · obtain ⟨h_xm, h_ym, h_lt, h_neg_until, h_event, h_no_wit⟩ := h_actual
      -- Inline C4 elimination with c2' preservation.
      -- Strategy: find an adjacent pair (w, w_next) between x and y where
      -- ξ ∉ g(w, w_next), then split using lemma_2_6_splitting with β = ξ.
      --
      -- Key fact: if neg(untl(ξ,η)) ∈ f(w) and η ∈ f(w_next), then ξ ∉ g(w, w_next).
      -- Proof: if ξ ∈ g, burgessRSet gives U(ξ, η) = untl(ξ,η) ∈ f(w),
      -- contradicting neg(untl(ξ,η)) ∈ f(w).
      --
      -- Find w = rightmost domain point in [x, y) with neg(untl(ξ,η)) ∈ f(w).
      -- x is always a valid candidate. w_next is the successor of w in dom.
      -- If w_next = y (or δ ∈ f(w_next)): η ∈ f(w_next), so ξ ∉ g(w, w_next).
      -- If w_next < y and η ∉ f(w_next): hard case (Burgess 2.9 induction needed).
      have h_mcs_x := h_c0 pc.x h_xm
      have h_mcs_y := h_c0 pc.y h_ym
      -- Find w (rightmost with neg-until) and w_next (its successor)
      haveI : DecidablePred (fun w => w < pc.y ∧
          (Formula.untl pc.ξ pc.η).neg ∈ χ.f w) :=
        fun w => Classical.dec _
      set S_w := χ.dom.filter (fun w => w < pc.y ∧ (Formula.untl pc.ξ pc.η).neg ∈ χ.f w)
      have hS_ne : S_w.Nonempty := by
        refine ⟨pc.x, Finset.mem_filter.mpr ⟨h_xm, h_lt, h_neg_until⟩⟩
      set w := S_w.max' hS_ne
      have hw_mem_S := Finset.max'_mem S_w hS_ne
      have hw_dom : w ∈ χ.dom := (Finset.mem_filter.mp hw_mem_S).1
      have hw_lt_y : w < pc.y := (Finset.mem_filter.mp hw_mem_S).2.1
      have hw_neg_until : (Formula.untl pc.ξ pc.η).neg ∈ χ.f w :=
        (Finset.mem_filter.mp hw_mem_S).2.2
      have hw_rightmost : ∀ v ∈ χ.dom, w < v → v < pc.y →
          (Formula.untl pc.ξ pc.η).neg ∉ χ.f v := by
        intro v hv hwv hvy h_neg_v
        have hv_in_S : v ∈ S_w := Finset.mem_filter.mpr ⟨hv, hvy, h_neg_v⟩
        have := Finset.le_max' S_w v hv_in_S
        linarith
      -- Find w_next = successor of w in dom (smallest domain element > w ≤ y)
      set T_w := χ.dom.filter (fun v => decide (w < v))
      have hT_ne : T_w.Nonempty :=
        ⟨pc.y, Finset.mem_filter.mpr ⟨h_ym, by simp [hw_lt_y]⟩⟩
      set w_next := T_w.min' hT_ne
      have hw_next_mem_T := Finset.min'_mem T_w hT_ne
      have hw_next_dom : w_next ∈ χ.dom := (Finset.mem_filter.mp hw_next_mem_T).1
      have hw_lt_next : w < w_next := by
        have := (Finset.mem_filter.mp hw_next_mem_T).2
        simp only [decide_eq_true_eq] at this; exact this
      have hw_next_le_y : w_next ≤ pc.y := by
        have : pc.y ∈ T_w := Finset.mem_filter.mpr ⟨h_ym, by simp [hw_lt_y]⟩
        exact Finset.min'_le T_w pc.y this
      have h_adj_w : Adjacent χ.dom w w_next := by
        refine ⟨hw_dom, hw_next_dom, hw_lt_next, ?_⟩
        intro u hu ⟨hwu, hu_next⟩
        have hu_T : u ∈ T_w := Finset.mem_filter.mpr ⟨hu, by simp [hwu]⟩
        have := Finset.min'_le T_w u hu_T
        linarith
      -- w_next = y: η ∈ f(w_next) = f(y), so ξ ∉ g(w, w_next)
      -- w_next < y: neg(untl(ξ,η)) ∉ f(w_next) (w is rightmost), need different argument
      have h_mcs_w := h_c0 w hw_dom
      have h_mcs_wn := h_c0 w_next hw_next_dom
      have h_r3m_w := h_c2' w w_next h_adj_w
      -- Key lemma: ξ ∉ g(w, w_next) when η ∈ f(w_next)
      -- (which holds when w_next = y since h_event : η ∈ f(y))
      -- When w_next ≤ y and neg(untl) ∉ f(w_next): untl ∈ f(w_next).
      -- If w_next = y: η ∈ f(w_next) from h_event.
      -- Use this to prove ξ ∉ g(w, w_next).
      have h_xi_not_g : pc.ξ ∉ χ.g w w_next := by
        intro h_xi_g
        -- Burgess 2.9 case analysis (both sub-cases proved):
        -- Case 1: η ∈ f(w_next) → direct contradiction via burgessRSet.
        -- Case 2: η ∉ f(w_next) → use ξ ∈ f(w_next) (from h_no_wit) and
        --   untl(ξ,η) ∈ f(w_next) (from w rightmost with neg-until) to form
        --   ξ ∧ untl(ξ,η) ∈ f(w_next), then BX6 absorption gives contradiction.
        by_cases h_eta_wn : pc.η ∈ χ.f w_next
        · -- η ∈ f(w_next): direct contradiction
          have h_untl := h_r3m_w.2.1.1 pc.ξ h_xi_g pc.η h_eta_wn
          exact absurd h_untl (SetMaximalConsistent.neg_excludes h_mcs_w (Formula.untl pc.ξ pc.η) hw_neg_until)
        · -- η ∉ f(w_next): need more involved argument
          -- w_next must be < y (if w_next = y, then η ∈ f(y) = f(w_next) by h_event)
          have hw_next_lt_y : w_next < pc.y := by
            rcases lt_or_eq_of_le hw_next_le_y with h | h
            · exact h
            · exact absurd (h ▸ h_event) h_eta_wn
          -- untl(ξ,η) ∈ f(w_next) (since neg(untl) ∉ f(w_next) by w rightmost)
          have h_untl_wn : Formula.untl pc.ξ pc.η ∈ χ.f w_next := by
            rcases SetMaximalConsistent.negation_complete h_mcs_wn (Formula.untl pc.ξ pc.η) with h | h
            · exact h
            · exact absurd h (hw_rightmost w_next hw_next_dom hw_lt_next hw_next_lt_y)
          -- Burgess 2.9 case n=m+1: derive contradiction using BX6 absorption.
          -- Key: ξ ∈ f(w_next) (since no ξ.neg between pc.x and pc.y, and pc.x < w_next < pc.y).
          have hx_le_w : pc.x ≤ w := by
            have : pc.x ∈ S_w := Finset.mem_filter.mpr ⟨h_xm, h_lt, h_neg_until⟩
            exact Finset.le_max' S_w pc.x this
          have hx_lt_wn : pc.x < w_next := lt_of_le_of_lt hx_le_w hw_lt_next
          have h_xi_wn : pc.ξ ∈ χ.f w_next := by
            rcases SetMaximalConsistent.negation_complete h_mcs_wn pc.ξ with h | h
            · exact h
            · -- ξ.neg ∈ f(w_next), but w_next is between pc.x and pc.y, contradicting h_no_wit
              exact absurd ⟨w_next, hw_next_dom, hx_lt_wn, hw_next_lt_y, h⟩ h_no_wit
          -- Form ξ ∧ untl(ξ,η) ∈ f(w_next) by conjunction closure in MCS
          have h_conj_wn : Formula.and pc.ξ (Formula.untl pc.ξ pc.η) ∈ χ.f w_next :=
            dcs_conj_closed (mcs_is_dcs h_mcs_wn) h_xi_wn h_untl_wn
          -- From burgessRSet: untl(ξ, ξ ∧ untl(ξ,η)) ∈ f(w)
          have h_untl_conj := h_r3m_w.2.1.1 pc.ξ h_xi_g
            (Formula.and pc.ξ (Formula.untl pc.ξ pc.η)) h_conj_wn
          -- BX6 absorption: untl(φ, φ ∧ untl(φ, ψ)) → untl(φ, ψ)
          have h_bx6 : DerivationTree []
            ((Formula.untl pc.ξ (Formula.and pc.ξ (Formula.untl pc.ξ pc.η))).imp
              (Formula.untl pc.ξ pc.η)) :=
            DerivationTree.axiom [] _ (Axiom.absorb_until pc.ξ pc.η)
          have h_bx6_in := theorem_in_mcs h_mcs_w h_bx6
          have h_untl_eta := SetMaximalConsistent.implication_property h_mcs_w h_bx6_in h_untl_conj
          -- Now untl(ξ,η) ∈ f(w) contradicts neg(untl(ξ,η)) ∈ f(w)
          exact absurd h_untl_eta
            (SetMaximalConsistent.neg_excludes h_mcs_w (Formula.untl pc.ξ pc.η) hw_neg_until)
      -- Now: ξ ∉ g(w, w_next). Apply lemma_2_6_splitting with β = ξ.
      have h_B_sdc_w := BurgessR3Maximal_sdc h_r3m_w h_nubr3 h_mcs_w h_mcs_wn
      have h_gc_w := BurgessR3Maximal_g_content_sub h_r3m_w h_mcs_w h_mcs_wn
      have h_split := lemma_2_6_splitting h_mcs_w h_mcs_wn h_r3m_w h_B_sdc_w h_gc_w
        pc.ξ h_xi_not_g h_nubr3
      let B' := h_split.choose
      let D := h_split.choose_spec.choose
      let B'' := h_split.choose_spec.choose_spec.choose
      have h_split_prop := h_split.choose_spec.choose_spec.choose_spec
      have h_B'_max : BurgessR3Maximal (χ.f w) B' D := h_split_prop.1
      have h_B''_max : BurgessR3Maximal D B'' (χ.f w_next) := h_split_prop.2.1
      have h_D_mcs : SetMaximalConsistent D := h_split_prop.2.2.1
      have h_xi_neg_D : pc.ξ.neg ∈ D := h_split_prop.2.2.2.1
      have h_g_sub_D : χ.g w w_next ⊆ D := h_split_prop.2.2.2.2.1
      have h_g_sub_B' : χ.g w w_next ⊆ B' := h_split_prop.2.2.2.2.2.1
      have h_g_sub_B'' : χ.g w w_next ⊆ B'' := h_split_prop.2.2.2.2.2.2
      -- Insert z between w and w_next
      set z := (w + w_next) / 2 with hz_def
      have hz_lt_wn : z < w_next := by linarith
      have hw_lt_z : w < z := by linarith
      have hz_notin : z ∉ χ.dom := by
        intro h_mem; exact h_adj_w.2.2.2 z h_mem ⟨hw_lt_z, hz_lt_wn⟩
      -- z is between x and y: w ≥ x (w ∈ dom with neg-until, could be x itself)
      -- and w_next ≤ y.
      have hx_le_w : pc.x ≤ w := by
        have : pc.x ∈ S_w := Finset.mem_filter.mpr ⟨h_xm, h_lt, h_neg_until⟩
        exact Finset.le_max' S_w pc.x this
      have hx_lt_z : pc.x < z := lt_of_le_of_lt hx_le_w hw_lt_z
      have hz_lt_y : z < pc.y := lt_of_lt_of_le hz_lt_wn hw_next_le_y
      -- Build new chronicle with f'(z) = D, updated g
      let g' := fun a b =>
        if a = w ∧ b = z then B'
        else if a = z ∧ b = w_next then B''
        else χ.g a b
      let χ' : Chronicle := ⟨fun q => if q = z then D else χ.f q, g', insert z χ.dom⟩
      -- Prove c2' for the new chronicle
      have h_c2'_new : χ'.c2' := by
        intro a b h_adj_new
        obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
        simp only [χ', Finset.mem_insert] at ha hb
        rcases ha with rfl | ha <;> rcases hb with rfl | hb
        · exact absurd hab (lt_irrefl _)
        · -- a = z, b ∈ old dom: must be (z, w_next)
          have hb_eq : b = w_next := by
            by_contra hb_ne
            have hb_ge : w_next ≤ b := by
              by_contra hlt; push_neg at hlt
              have : w < b := lt_trans hw_lt_z hab
              exact h_adj_w.2.2.2 b hb ⟨this, hlt⟩
            have hb_gt : w_next < b := lt_of_le_of_ne hb_ge (Ne.symm hb_ne)
            exact h_no_between w_next (Finset.mem_insert_of_mem hw_next_dom) ⟨hz_lt_wn, hb_gt⟩
          subst hb_eq
          show BurgessR3Maximal
            (if z = z then D else χ.f z)
            (g' z w_next)
            (if w_next = z then D else χ.f w_next)
          have hwn_ne : w_next ≠ z := by linarith
          simp only [ite_true, hwn_ne, ite_false, g']
          simp only [ite_false, ite_true, and_false, and_self]
          exact h_B''_max
        · -- a ∈ old dom, b = z: must be (w, z)
          have ha_eq : a = w := by
            by_contra ha_ne
            have ha_le : a ≤ w := by
              by_contra hgt; push_neg at hgt
              exact h_adj_w.2.2.2 a ha ⟨hgt, lt_trans hab hz_lt_wn⟩
            have ha_lt : a < w := lt_of_le_of_ne ha_le ha_ne
            exact h_no_between w (Finset.mem_insert_of_mem hw_dom) ⟨ha_lt, hw_lt_z⟩
          subst ha_eq
          show BurgessR3Maximal
            (if w = z then D else χ.f w)
            (g' w z)
            (if z = z then D else χ.f z)
          have hw_ne : w ≠ z := by linarith
          simp only [hw_ne, ite_false, ite_true, g']
          exact h_B'_max
        · -- Both old: preserved
          have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
          have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
          show BurgessR3Maximal
            (if a = z then D else χ.f a)
            (g' a b)
            (if b = z then D else χ.f b)
          simp only [ha_ne, hb_ne, ite_false, g', and_false, false_and]
          have h_adj_old : Adjacent χ.dom a b := by
            refine ⟨ha, hb, hab, ?_⟩
            intro u hu ⟨hau, hub⟩
            exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
          exact h_c2' a b h_adj_old
      exact { val := χ'
              dom_sub := Finset.subset_insert z χ.dom
              c0 := by
                intro q hq
                show SetMaximalConsistent (if q = z then D else χ.f q)
                change q ∈ insert z χ.dom at hq
                simp only [Finset.mem_insert] at hq
                rcases hq with rfl | hq
                · simp only [ite_true]; exact h_D_mcs
                · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                  simp only [h_ne, ite_false]; exact h_c0 q hq
              f_agrees := by
                intro x hx
                have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
                exact if_neg h_ne
              g_agrees := by
                intro a b ha hb
                show g' a b = χ.g a b
                simp only [g']
                have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                simp only [ha_ne, hb_ne, false_and, and_false, ite_false]
              c2' := h_c2'_new
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := by
                intro _ _ _ _ _ _
                refine ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y, ?_⟩
                show pc.ξ.neg ∈ (if z = z then D else χ.f z)
                simp only [ite_true]
                exact h_xi_neg_D
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              g_sub_f_insert := by
                intro a b h_adj w0 hw0 hw0_not haw0 hw0b
                simp only [χ', Finset.mem_insert] at hw0
                rcases hw0 with rfl | hw0
                · show χ.g a b ⊆ (if z = z then D else χ.f z)
                  simp only [ite_true]
                  have hab : a = w ∧ b = w_next := by
                    constructor
                    · by_contra ha_ne
                      have : a < w ∨ w < a := lt_or_gt_of_ne ha_ne
                      rcases this with h | h
                      · exact h_adj.2.2.2 w hw_dom ⟨h, lt_trans hw_lt_z hw0b⟩
                      · exact h_adj_w.2.2.2 a h_adj.1 ⟨h, lt_trans haw0 hz_lt_wn⟩
                    · by_contra hb_ne
                      have : b < w_next ∨ w_next < b := lt_or_gt_of_ne hb_ne
                      rcases this with h | h
                      · exact h_adj_w.2.2.2 b h_adj.2.1 ⟨lt_trans hw_lt_z hw0b, h⟩
                      · exact h_adj.2.2.2 w_next hw_next_dom ⟨lt_trans haw0 hz_lt_wn, h⟩
                  rw [hab.1, hab.2]; exact h_g_sub_D
                · exact absurd hw0 hw0_not
              g_sub_g_new := by
                intro a b h_adj w0 hw0 hw0_not haw0 hw0b
                simp only [χ', Finset.mem_insert] at hw0
                rcases hw0 with rfl | hw0
                · have ha_eq : a = w := by
                    by_contra ha_ne
                    rcases lt_or_gt_of_ne ha_ne with h | h
                    · exact h_adj.2.2.2 w hw_dom ⟨h, lt_trans hw_lt_z hw0b⟩
                    · exact h_adj_w.2.2.2 a h_adj.1 ⟨h, lt_trans haw0 hz_lt_wn⟩
                  have hb_eq : b = w_next := by
                    by_contra hb_ne
                    rcases lt_or_gt_of_ne hb_ne with h | h
                    · exact h_adj_w.2.2.2 b h_adj.2.1 ⟨lt_trans hw_lt_z hw0b, h⟩
                    · exact h_adj.2.2.2 w_next hw_next_dom ⟨lt_trans haw0 hz_lt_wn, h⟩
                  subst ha_eq; subst hb_eq
                  constructor
                  · show χ.g w w_next ⊆ g' w z
                    simp only [g', and_self, ite_true]
                    exact h_g_sub_B'
                  · show χ.g w w_next ⊆ g' z w_next
                    simp only [g']
                    have : ¬(z = w ∧ w_next = z) := by
                      intro ⟨h1, _⟩; linarith
                    simp only [this, ite_false, and_self, ite_true]
                    exact h_g_sub_B''
                · exact absurd hw0 hw0_not
              dom_new_unique := by
                intro u v hu hu_not hv hv_not
                simp only [χ', Finset.mem_insert] at hu hv
                rcases hu with rfl | hu <;> rcases hv with rfl | hv
                · rfl
                · exact absurd hv hv_not
                · exact absurd hu hu_not
                · exact absurd hu hu_not }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              g_agrees := fun _ _ _ _ => rfl
              c2' := by exact h_c2'
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := by
                intro _ h_xm' h_ym' h_lt' h_neg_until' h_event'
                push_neg at h_actual
                exact h_actual h_xm' h_ym' h_lt' h_neg_until' h_event'
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              g_sub_f_insert := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              g_sub_g_new := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              dom_new_unique := fun u _ hu hu_not _ _ => absurd hu hu_not }
  | .c4_backward =>
    -- Backward C4' case (corrected Burgess C4b: check EVENT η at f(y), negate GUARD ξ at f(z))
    -- Now checks ALL pairs y < x, not just adjacent pairs.
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧
        pc.y < pc.x ∧
        (Formula.snce pc.ξ pc.η).neg ∈ χ.f pc.x ∧
        pc.η ∈ χ.f pc.y ∧
        ¬∃ z ∈ χ.dom, pc.y < z ∧ z < pc.x ∧ pc.ξ.neg ∈ χ.f z
    · obtain ⟨h_xm, h_ym, h_lt, h_neg_since, h_event, h_no_wit⟩ := h_actual
      -- Inline C4' elimination with c2' preservation (Since mirror of c4_forward).
      -- Strategy: find adjacent pair (w_prev, w) between y and x where
      -- ξ ∉ g(w_prev, w), then split using lemma_2_6_splitting with β = ξ.
      --
      -- Key fact: if neg(snce(ξ,η)) ∈ f(w) and η ∈ f(w_prev), then ξ ∉ g(w_prev, w).
      -- Proof: if ξ ∈ g, burgessRSetSince gives S(ξ, η) = snce(ξ,η) ∈ f(w),
      -- contradicting neg(snce(ξ,η)) ∈ f(w).
      --
      -- Find w = leftmost domain point in (y, x] with neg(snce(ξ,η)) ∈ f(w).
      -- x is always a valid candidate. w_prev is the predecessor of w in dom.
      -- If w_prev = y (or η ∈ f(w_prev)): η ∈ f(w_prev), so ξ ∉ g(w_prev, w).
      have h_mcs_x := h_c0 pc.x h_xm
      have h_mcs_y := h_c0 pc.y h_ym
      -- Find w (leftmost with neg-since in (y, x])
      haveI : DecidablePred (fun w => pc.y < w ∧
          (Formula.snce pc.ξ pc.η).neg ∈ χ.f w) :=
        fun w => Classical.dec _
      set S_w := χ.dom.filter (fun w => pc.y < w ∧ (Formula.snce pc.ξ pc.η).neg ∈ χ.f w)
      have hS_ne : S_w.Nonempty := by
        refine ⟨pc.x, Finset.mem_filter.mpr ⟨h_xm, h_lt, h_neg_since⟩⟩
      set w := S_w.min' hS_ne
      have hw_mem_S := Finset.min'_mem S_w hS_ne
      have hw_dom : w ∈ χ.dom := (Finset.mem_filter.mp hw_mem_S).1
      have hy_lt_w : pc.y < w := (Finset.mem_filter.mp hw_mem_S).2.1
      have hw_neg_since : (Formula.snce pc.ξ pc.η).neg ∈ χ.f w :=
        (Finset.mem_filter.mp hw_mem_S).2.2
      have hw_leftmost : ∀ v ∈ χ.dom, pc.y < v → v < w →
          (Formula.snce pc.ξ pc.η).neg ∉ χ.f v := by
        intro v hv hyv hvw h_neg_v
        have hv_in_S : v ∈ S_w := Finset.mem_filter.mpr ⟨hv, hyv, h_neg_v⟩
        have := Finset.min'_le S_w v hv_in_S
        linarith
      -- Find w_prev = predecessor of w in dom (largest domain element < w with w_prev ≥ y)
      set T_w := χ.dom.filter (fun v => decide (v < w))
      have hT_ne : T_w.Nonempty :=
        ⟨pc.y, Finset.mem_filter.mpr ⟨h_ym, by simp [hy_lt_w]⟩⟩
      set w_prev := T_w.max' hT_ne
      have hw_prev_mem_T := Finset.max'_mem T_w hT_ne
      have hw_prev_dom : w_prev ∈ χ.dom := (Finset.mem_filter.mp hw_prev_mem_T).1
      have hw_prev_lt : w_prev < w := by
        have := (Finset.mem_filter.mp hw_prev_mem_T).2
        simp only [decide_eq_true_eq] at this; exact this
      have hy_le_prev : pc.y ≤ w_prev := by
        have : pc.y ∈ T_w := Finset.mem_filter.mpr ⟨h_ym, by simp [hy_lt_w]⟩
        exact Finset.le_max' T_w pc.y this
      have h_adj_w : Adjacent χ.dom w_prev w := by
        refine ⟨hw_prev_dom, hw_dom, hw_prev_lt, ?_⟩
        intro u hu ⟨hpu, huw⟩
        have hu_T : u ∈ T_w := Finset.mem_filter.mpr ⟨hu, by simp [huw]⟩
        have := Finset.le_max' T_w u hu_T
        linarith
      have h_mcs_w := h_c0 w hw_dom
      have h_mcs_wp := h_c0 w_prev hw_prev_dom
      have h_r3m_w := h_c2' w_prev w h_adj_w
      -- Key: ξ ∉ g(w_prev, w) when η ∈ f(w_prev)
      -- burgessRSetSince(f(w), g(w_prev,w), f(w_prev)): ∀ β ∈ g, α ∈ f(w_prev), S(β,α) ∈ f(w)
      -- If ξ ∈ g and η ∈ f(w_prev): snce(ξ,η) ∈ f(w), contradicting neg(snce(ξ,η)) ∈ f(w).
      have h_xi_not_g : pc.ξ ∉ χ.g w_prev w := by
        intro h_xi_g
        by_cases h_eta_wp : pc.η ∈ χ.f w_prev
        · -- η ∈ f(w_prev): S(ξ, η) ∈ f(w) by burgessRSetSince, contradiction
          have h_snce := h_r3m_w.2.1.2 pc.ξ h_xi_g pc.η h_eta_wp
          exact absurd h_snce (SetMaximalConsistent.neg_excludes h_mcs_w (Formula.snce pc.ξ pc.η) hw_neg_since)
        · -- η ∉ f(w_prev): need more involved argument
          have hy_lt_prev : pc.y < w_prev := by
            rcases lt_or_eq_of_le hy_le_prev with h | h
            · exact h
            · exact absurd (h ▸ h_event) h_eta_wp
          have h_snce_wp : Formula.snce pc.ξ pc.η ∈ χ.f w_prev := by
            rcases SetMaximalConsistent.negation_complete h_mcs_wp (Formula.snce pc.ξ pc.η) with h | h
            · exact h
            · exact absurd h (hw_leftmost w_prev hw_prev_dom hy_lt_prev hw_prev_lt)
          -- Burgess 2.9' case n=m+1 (Since mirror): derive contradiction using BX6' absorption.
          -- Key: ξ ∈ f(w_prev) (since no ξ.neg between pc.y and pc.x, and pc.y < w_prev < pc.x).
          have hw_le_x : w ≤ pc.x := by
            have : pc.x ∈ S_w := Finset.mem_filter.mpr ⟨h_xm, h_lt, h_neg_since⟩
            exact Finset.min'_le S_w pc.x this
          have hwp_lt_x : w_prev < pc.x := lt_of_lt_of_le hw_prev_lt hw_le_x
          have h_xi_wp : pc.ξ ∈ χ.f w_prev := by
            rcases SetMaximalConsistent.negation_complete h_mcs_wp pc.ξ with h | h
            · exact h
            · exact absurd ⟨w_prev, hw_prev_dom, hy_lt_prev, hwp_lt_x, h⟩ h_no_wit
          -- Form ξ ∧ snce(ξ,η) ∈ f(w_prev) by conjunction closure in MCS
          have h_conj_wp : Formula.and pc.ξ (Formula.snce pc.ξ pc.η) ∈ χ.f w_prev :=
            dcs_conj_closed (mcs_is_dcs h_mcs_wp) h_xi_wp h_snce_wp
          -- From burgessRSetSince: snce(ξ, ξ ∧ snce(ξ,η)) ∈ f(w)
          have h_snce_conj := h_r3m_w.2.1.2 pc.ξ h_xi_g
            (Formula.and pc.ξ (Formula.snce pc.ξ pc.η)) h_conj_wp
          -- BX6' absorption: snce(φ, φ ∧ snce(φ, ψ)) → snce(φ, ψ)
          have h_bx6' : DerivationTree []
            ((Formula.snce pc.ξ (Formula.and pc.ξ (Formula.snce pc.ξ pc.η))).imp
              (Formula.snce pc.ξ pc.η)) :=
            DerivationTree.axiom [] _ (Axiom.absorb_since pc.ξ pc.η)
          have h_bx6'_in := theorem_in_mcs h_mcs_w h_bx6'
          have h_snce_eta := SetMaximalConsistent.implication_property h_mcs_w h_bx6'_in h_snce_conj
          -- Now snce(ξ,η) ∈ f(w) contradicts neg(snce(ξ,η)) ∈ f(w)
          exact absurd h_snce_eta
            (SetMaximalConsistent.neg_excludes h_mcs_w (Formula.snce pc.ξ pc.η) hw_neg_since)
      -- Now: ξ ∉ g(w_prev, w). Apply lemma_2_6_splitting with β = ξ.
      have h_B_sdc_w := BurgessR3Maximal_sdc h_r3m_w h_nubr3 h_mcs_wp h_mcs_w
      have h_gc_w := BurgessR3Maximal_g_content_sub h_r3m_w h_mcs_wp h_mcs_w
      have h_split := lemma_2_6_splitting h_mcs_wp h_mcs_w h_r3m_w h_B_sdc_w h_gc_w
        pc.ξ h_xi_not_g h_nubr3
      let B' := h_split.choose
      let D := h_split.choose_spec.choose
      let B'' := h_split.choose_spec.choose_spec.choose
      have h_split_prop := h_split.choose_spec.choose_spec.choose_spec
      have h_B'_max : BurgessR3Maximal (χ.f w_prev) B' D := h_split_prop.1
      have h_B''_max : BurgessR3Maximal D B'' (χ.f w) := h_split_prop.2.1
      have h_D_mcs : SetMaximalConsistent D := h_split_prop.2.2.1
      have h_xi_neg_D : pc.ξ.neg ∈ D := h_split_prop.2.2.2.1
      have h_g_sub_D : χ.g w_prev w ⊆ D := h_split_prop.2.2.2.2.1
      have h_g_sub_B' : χ.g w_prev w ⊆ B' := h_split_prop.2.2.2.2.2.1
      have h_g_sub_B'' : χ.g w_prev w ⊆ B'' := h_split_prop.2.2.2.2.2.2
      -- Insert z between w_prev and w
      set z := (w_prev + w) / 2 with hz_def
      have hz_lt_w : z < w := by linarith
      have hwp_lt_z : w_prev < z := by linarith
      have hz_notin : z ∉ χ.dom := by
        intro h_mem; exact h_adj_w.2.2.2 z h_mem ⟨hwp_lt_z, hz_lt_w⟩
      -- z is between y and x: w_prev ≥ y and w ≤ x
      have hw_le_x : w ≤ pc.x := by
        have : pc.x ∈ S_w := Finset.mem_filter.mpr ⟨h_xm, h_lt, h_neg_since⟩
        exact Finset.min'_le S_w pc.x this
      have hy_lt_z : pc.y < z := lt_of_le_of_lt hy_le_prev hwp_lt_z
      have hz_lt_x : z < pc.x := lt_of_lt_of_le hz_lt_w hw_le_x
      -- Build new chronicle
      let g' := fun a b =>
        if a = w_prev ∧ b = z then B'
        else if a = z ∧ b = w then B''
        else χ.g a b
      let χ' : Chronicle := ⟨fun q => if q = z then D else χ.f q, g', insert z χ.dom⟩
      -- Prove c2'
      have h_c2'_new : χ'.c2' := by
        intro a b h_adj_new
        obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
        simp only [χ', Finset.mem_insert] at ha hb
        rcases ha with rfl | ha <;> rcases hb with rfl | hb
        · exact absurd hab (lt_irrefl _)
        · -- a = z, b ∈ old dom: must be (z, w)
          have hb_eq : b = w := by
            by_contra hb_ne
            have hb_ge : w ≤ b := by
              by_contra hlt; push_neg at hlt
              have : w_prev < b := lt_trans hwp_lt_z hab
              exact h_adj_w.2.2.2 b hb ⟨this, hlt⟩
            have hb_gt : w < b := lt_of_le_of_ne hb_ge (Ne.symm hb_ne)
            exact h_no_between w (Finset.mem_insert_of_mem hw_dom) ⟨hz_lt_w, hb_gt⟩
          subst hb_eq
          show BurgessR3Maximal
            (if z = z then D else χ.f z)
            (g' z w)
            (if w = z then D else χ.f w)
          have hw_ne : w ≠ z := by linarith
          simp only [ite_true, hw_ne, ite_false, g']
          simp only [ite_false, ite_true, and_false, and_self]
          exact h_B''_max
        · -- a ∈ old dom, b = z: must be (w_prev, z)
          have ha_eq : a = w_prev := by
            by_contra ha_ne
            have ha_le : a ≤ w_prev := by
              by_contra hgt; push_neg at hgt
              exact h_adj_w.2.2.2 a ha ⟨hgt, lt_trans hab hz_lt_w⟩
            have ha_lt : a < w_prev := lt_of_le_of_ne ha_le ha_ne
            exact h_no_between w_prev (Finset.mem_insert_of_mem hw_prev_dom) ⟨ha_lt, hwp_lt_z⟩
          subst ha_eq
          show BurgessR3Maximal
            (if w_prev = z then D else χ.f w_prev)
            (g' w_prev z)
            (if z = z then D else χ.f z)
          have hwp_ne : w_prev ≠ z := by linarith
          simp only [hwp_ne, ite_false, ite_true, g']
          exact h_B'_max
        · -- Both old: preserved
          have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
          have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
          show BurgessR3Maximal
            (if a = z then D else χ.f a)
            (g' a b)
            (if b = z then D else χ.f b)
          simp only [ha_ne, hb_ne, ite_false, g', and_false, false_and]
          have h_adj_old : Adjacent χ.dom a b := by
            refine ⟨ha, hb, hab, ?_⟩
            intro u hu ⟨hau, hub⟩
            exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
          exact h_c2' a b h_adj_old
      exact { val := χ'
              dom_sub := Finset.subset_insert z χ.dom
              c0 := by
                intro q hq
                show SetMaximalConsistent (if q = z then D else χ.f q)
                change q ∈ insert z χ.dom at hq
                simp only [Finset.mem_insert] at hq
                rcases hq with rfl | hq
                · simp only [ite_true]; exact h_D_mcs
                · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                  simp only [h_ne, ite_false]; exact h_c0 q hq
              f_agrees := by
                intro x hx
                have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
                exact if_neg h_ne
              g_agrees := by
                intro a b ha hb
                show g' a b = χ.g a b
                simp only [g']
                have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                simp only [ha_ne, hb_ne, false_and, and_false, ite_false]
              c2' := h_c2'_new
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := by
                intro _ _ _ _ _ _
                refine ⟨z, Finset.mem_insert_self z χ.dom, hy_lt_z, hz_lt_x, ?_⟩
                show pc.ξ.neg ∈ (if z = z then D else χ.f z)
                simp only [ite_true]
                exact h_xi_neg_D
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              g_sub_f_insert := by
                intro a b h_adj w0 hw0 hw0_not haw0 hw0b
                simp only [χ', Finset.mem_insert] at hw0
                rcases hw0 with rfl | hw0
                · show χ.g a b ⊆ (if z = z then D else χ.f z)
                  simp only [ite_true]
                  have hab : a = w_prev ∧ b = w := by
                    constructor
                    · by_contra ha_ne
                      have : a < w_prev ∨ w_prev < a := lt_or_gt_of_ne ha_ne
                      rcases this with h | h
                      · exact h_adj.2.2.2 w_prev hw_prev_dom ⟨h, lt_trans hwp_lt_z hw0b⟩
                      · exact h_adj_w.2.2.2 a h_adj.1 ⟨h, lt_trans haw0 hz_lt_w⟩
                    · by_contra hb_ne
                      have : b < w ∨ w < b := lt_or_gt_of_ne hb_ne
                      rcases this with h | h
                      · exact h_adj_w.2.2.2 b h_adj.2.1 ⟨lt_trans hwp_lt_z hw0b, h⟩
                      · exact h_adj.2.2.2 w hw_dom ⟨lt_trans haw0 hz_lt_w, h⟩
                  rw [hab.1, hab.2]; exact h_g_sub_D
                · exact absurd hw0 hw0_not
              g_sub_g_new := by
                intro a b h_adj w0 hw0 hw0_not haw0 hw0b
                simp only [χ', Finset.mem_insert] at hw0
                rcases hw0 with rfl | hw0
                · have ha_eq : a = w_prev := by
                    by_contra ha_ne
                    rcases lt_or_gt_of_ne ha_ne with h | h
                    · exact h_adj.2.2.2 w_prev hw_prev_dom ⟨h, lt_trans hwp_lt_z hw0b⟩
                    · exact h_adj_w.2.2.2 a h_adj.1 ⟨h, lt_trans haw0 hz_lt_w⟩
                  have hb_eq : b = w := by
                    by_contra hb_ne
                    rcases lt_or_gt_of_ne hb_ne with h | h
                    · exact h_adj_w.2.2.2 b h_adj.2.1 ⟨lt_trans hwp_lt_z hw0b, h⟩
                    · exact h_adj.2.2.2 w hw_dom ⟨lt_trans haw0 hz_lt_w, h⟩
                  subst ha_eq; subst hb_eq
                  constructor
                  · show χ.g w_prev w ⊆ g' w_prev z
                    simp only [g', and_self, ite_true]
                    exact h_g_sub_B'
                  · show χ.g w_prev w ⊆ g' z w
                    simp only [g']
                    have : ¬(z = w_prev ∧ w = z) := by
                      intro ⟨h1, _⟩; linarith
                    simp only [this, ite_false, and_self, ite_true]
                    exact h_g_sub_B''
                · exact absurd hw0 hw0_not
              dom_new_unique := by
                intro u v hu hu_not hv hv_not
                simp only [χ', Finset.mem_insert] at hu hv
                rcases hu with rfl | hu <;> rcases hv with rfl | hv
                · rfl
                · exact absurd hv hv_not
                · exact absurd hu hu_not
                · exact absurd hu hu_not }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              g_agrees := fun _ _ _ _ => rfl
              c2' := by exact h_c2'
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := by
                intro _ h_xm' h_ym' h_lt' h_neg_since' h_event'
                push_neg at h_actual
                exact h_actual h_xm' h_ym' h_lt' h_neg_since' h_event'
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              g_sub_f_insert := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              g_sub_g_new := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              dom_new_unique := fun u _ hu hu_not _ _ => absurd hu hu_not }
  | .density =>
    -- Density: if x and y are adjacent in dom, insert midpoint z = (x+y)/2
    -- with f(z) = f(x) (any MCS will do; we just need to break adjacency).
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧ Adjacent χ.dom pc.x pc.y
    · obtain ⟨h_xm, h_ym, h_adj⟩ := h_actual
      set z := (pc.x + pc.y) / 2 with hz_def
      have hxy := h_adj.2.2.1
      have hz_lt_y : z < pc.y := by linarith
      have hx_lt_z : pc.x < z := by linarith
      have hz_notin : z ∉ χ.dom := by
        intro h_mem; exact h_adj.2.2.2 z h_mem ⟨hx_lt_z, hz_lt_y⟩
      -- Get BurgessR3Maximal for old adjacent pair and derive helper properties
      have h_mcs_x := h_c0 pc.x h_xm
      have h_mcs_y := h_c0 pc.y h_ym
      have h_r3m := h_c2' pc.x pc.y h_adj
      have h_B_sdc := BurgessR3Maximal_sdc h_r3m h_nubr3 h_mcs_x h_mcs_y
      have h_gc := BurgessR3Maximal_g_content_sub h_r3m h_mcs_x h_mcs_y
      -- Find β ∉ g(pc.x, pc.y): g is SDC (consistent), so g ≠ Set.univ, so ∃ β ∉ g
      have h_g_ne_univ : χ.g pc.x pc.y ≠ Set.univ := by
        intro h_eq
        exact h_nubr3 (χ.f pc.x) (χ.f pc.y) h_mcs_x h_mcs_y (h_eq ▸ h_r3m.2.1)
      have h_exists_beta : ∃ β, β ∉ χ.g pc.x pc.y := by
        by_contra h_all; push_neg at h_all
        exact h_g_ne_univ (Set.eq_univ_iff_forall.mpr h_all)
      -- Extract β using .choose (noncomputable)
      let β := h_exists_beta.choose
      have h_beta_not : β ∉ χ.g pc.x pc.y := h_exists_beta.choose_spec
      -- Apply lemma_2_6_splitting to get B', D, B'' for new adjacent pairs
      -- Use .choose to extract data from existential (noncomputable context)
      have h_split := lemma_2_6_splitting h_mcs_x h_mcs_y h_r3m h_B_sdc h_gc β h_beta_not h_nubr3
      let B' := h_split.choose
      let D := h_split.choose_spec.choose
      let B'' := h_split.choose_spec.choose_spec.choose
      have h_split_prop := h_split.choose_spec.choose_spec.choose_spec
      have h_B'_max : BurgessR3Maximal (χ.f pc.x) B' D := h_split_prop.1
      have h_B''_max : BurgessR3Maximal D B'' (χ.f pc.y) := h_split_prop.2.1
      have h_D_mcs : SetMaximalConsistent D := h_split_prop.2.2.1
      have h_g_sub_D : χ.g pc.x pc.y ⊆ D := h_split_prop.2.2.2.2.1
      have h_g_sub_B' : χ.g pc.x pc.y ⊆ B' := h_split_prop.2.2.2.2.2.1
      have h_g_sub_B'' : χ.g pc.x pc.y ⊆ B'' := h_split_prop.2.2.2.2.2.2
      -- Define g' that updates g for new adjacent pairs
      let g' := fun a b =>
        if a = pc.x ∧ b = z then B'
        else if a = z ∧ b = pc.y then B''
        else χ.g a b
      exact { val := ⟨fun q => if q = z then D else χ.f q, g', insert z χ.dom⟩
              dom_sub := Finset.subset_insert z χ.dom
              c0 := by
                intro q hq
                simp only [Finset.mem_insert] at hq
                rcases hq with rfl | hq
                · simp only [ite_true]; exact h_D_mcs
                · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                  simp only [h_ne, ite_false]; exact h_c0 q hq
              f_agrees := by
                intro q hq
                have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                exact if_neg h_ne
              g_agrees := by
                intro a b ha hb
                -- g'(a, b) = χ.g(a, b) for a, b in old domain (since z ∉ old domain)
                show g' a b = χ.g a b
                simp only [g']
                have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                simp only [ha_ne, hb_ne, false_and, and_false, ite_false]
              c2' := by
                -- Prove c2' for new chronicle with updated g
                intro a b h_adj_new
                -- Case analysis: which adjacent pair in insert z χ.dom?
                -- z splits (pc.x, pc.y). New pairs: (pc.x, z) and (z, pc.y).
                -- Other pairs: old adjacent pairs (a, b) ≠ (pc.x, pc.y), preserved.
                obtain ⟨ha, hb, hab, h_no_between⟩ := h_adj_new
                simp only [Finset.mem_insert] at ha hb
                rcases ha with rfl | ha <;> rcases hb with rfl | hb
                · -- a = z, b = z: impossible (z < z)
                  exact absurd hab (lt_irrefl _)
                · -- a = z, b ∈ old dom: new pair (z, b)
                  -- Must be (z, pc.y): z < b, and no element between z and b in new dom.
                  -- f'(z) = D, g'(z, b) = B'' if b = pc.y, else χ.g z b
                  -- Since z = (pc.x+pc.y)/2, the only old element > z that can be adjacent to z is pc.y
                  -- (because pc.x and pc.y were adjacent: no old element in (pc.x, pc.y))
                  have hb_eq : b = pc.y := by
                    -- b > z = (pc.x+pc.y)/2. b ∈ old dom. No old element between pc.x and pc.y.
                    -- So b ≥ pc.y. If b > pc.y, then pc.y ∈ old dom is between z and b.
                    -- pc.y ∈ insert z χ.dom, and z < pc.y < b, contradicting adjacency.
                    by_contra hb_ne
                    have hb_ge_y : pc.y ≤ b := by
                      by_contra hlt; push_neg at hlt
                      -- b < pc.y and b > z > pc.x, so pc.x < b < pc.y
                      have : pc.x < b := lt_trans hx_lt_z hab
                      exact h_adj.2.2.2 b hb ⟨this, hlt⟩
                    have hb_gt_y : pc.y < b := lt_of_le_of_ne hb_ge_y (Ne.symm hb_ne)
                    exact h_no_between pc.y (Finset.mem_insert_of_mem h_ym) ⟨hz_lt_y, hb_gt_y⟩
                  subst hb_eq
                  -- Now a = z, b = pc.y: f'(z) = D, g'(z, pc.y) = B'', f'(pc.y) = f(pc.y)
                  show BurgessR3Maximal
                    (if z = z then D else χ.f z)
                    (g' z pc.y)
                    (if pc.y = z then D else χ.f pc.y)
                  have hy_ne : pc.y ≠ z := by linarith
                  simp only [ite_true, hy_ne, ite_false, g']
                  simp only [ite_false, ite_true, and_false, and_self]
                  exact h_B''_max
                · -- a ∈ old dom, b = z: new pair (a, z)
                  -- Must be (pc.x, z): similar argument
                  have ha_eq : a = pc.x := by
                    -- a < z = (pc.x+pc.y)/2. a ∈ old dom.
                    -- No old element between pc.x and pc.y. So a ≤ pc.x.
                    -- If a < pc.x, then pc.x ∈ old dom is between a and z.
                    -- pc.x ∈ insert z χ.dom, and a < pc.x < z, contradicting adjacency.
                    by_contra ha_ne
                    have ha_le_x : a ≤ pc.x := by
                      by_contra hgt; push_neg at hgt
                      -- a > pc.x and a < z < pc.y, so pc.x < a < pc.y
                      exact h_adj.2.2.2 a ha ⟨hgt, lt_trans hab hz_lt_y⟩
                    have ha_lt_x : a < pc.x := lt_of_le_of_ne ha_le_x ha_ne
                    exact h_no_between pc.x (Finset.mem_insert_of_mem h_xm) ⟨ha_lt_x, hx_lt_z⟩
                  subst ha_eq
                  -- Now a = pc.x, b = z: f'(pc.x) = f(pc.x), g'(pc.x, z) = B', f'(z) = D
                  show BurgessR3Maximal
                    (if pc.x = z then D else χ.f pc.x)
                    (g' pc.x z)
                    (if z = z then D else χ.f z)
                  have hx_ne : pc.x ≠ z := by linarith
                  simp only [hx_ne, ite_false, ite_true, g']
                  exact h_B'_max
                · -- Both a, b ∈ old dom: old adjacent pair
                  -- f'(a) = f(a), f'(b) = f(b), g'(a, b) = χ.g(a, b)
                  have ha_ne : a ≠ z := fun h => hz_notin (h ▸ ha)
                  have hb_ne : b ≠ z := fun h => hz_notin (h ▸ hb)
                  show BurgessR3Maximal
                    (if a = z then D else χ.f a)
                    (g' a b)
                    (if b = z then D else χ.f b)
                  simp only [ha_ne, hb_ne, ite_false, g', and_false, false_and]
                  -- (a, b) was adjacent in old dom (z doesn't fall between them)
                  have h_adj_old : Adjacent χ.dom a b := by
                    refine ⟨ha, hb, hab, ?_⟩
                    intro u hu ⟨hau, hub⟩
                    -- u is between a and b in old dom. Is u between a and b in new dom too?
                    -- z is between a and b? If so, z is in (a, b) which means
                    -- a < z < b, but a, b ∈ old dom and old adjacency means no old point between.
                    -- Since z = midpoint of (pc.x, pc.y) and (a, b) is an old pair different from (pc.x, pc.y),
                    -- z is NOT between a and b.
                    exact h_no_between u (Finset.mem_insert_of_mem hu) ⟨hau, hub⟩
                  exact h_c2' a b h_adj_old
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := by
                intro _ _ _ h_lt
                exact ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y⟩
              g_sub_f_insert := by
                intro a b h_adj' w0 hw0 hw0_not haw0 hw0b
                simp only [Finset.mem_insert] at hw0
                rcases hw0 with rfl | hw0
                · show χ.g a b ⊆ (if z = z then D else χ.f z)
                  simp only [ite_true]
                  have hab : a = pc.x ∧ b = pc.y := by
                    constructor
                    · by_contra ha_ne
                      have : a < pc.x ∨ pc.x < a := lt_or_gt_of_ne ha_ne
                      rcases this with h | h
                      · exact h_adj'.2.2.2 pc.x h_xm ⟨h, lt_trans hx_lt_z hw0b⟩
                      · exact h_adj.2.2.2 a h_adj'.1 ⟨h, lt_trans haw0 hz_lt_y⟩
                    · by_contra hb_ne
                      have : b < pc.y ∨ pc.y < b := lt_or_gt_of_ne hb_ne
                      rcases this with h | h
                      · exact h_adj.2.2.2 b h_adj'.2.1 ⟨lt_trans hx_lt_z hw0b, h⟩
                      · exact h_adj'.2.2.2 pc.y h_ym ⟨lt_trans haw0 hz_lt_y, h⟩
                  rw [hab.1, hab.2]; exact h_g_sub_D
                · exact absurd hw0 hw0_not
              g_sub_g_new := by
                intro a b h_adj' w0 hw0 hw0_not haw0 hw0b
                simp only [Finset.mem_insert] at hw0
                rcases hw0 with rfl | hw0
                · have ha_eq : a = pc.x := by
                    by_contra ha_ne
                    rcases lt_or_gt_of_ne ha_ne with h | h
                    · exact h_adj'.2.2.2 pc.x h_xm ⟨h, lt_trans hx_lt_z hw0b⟩
                    · exact h_adj.2.2.2 a h_adj'.1 ⟨h, lt_trans haw0 hz_lt_y⟩
                  have hb_eq : b = pc.y := by
                    by_contra hb_ne
                    rcases lt_or_gt_of_ne hb_ne with h | h
                    · exact h_adj.2.2.2 b h_adj'.2.1 ⟨lt_trans hx_lt_z hw0b, h⟩
                    · exact h_adj'.2.2.2 pc.y h_ym ⟨lt_trans haw0 hz_lt_y, h⟩
                  subst ha_eq; subst hb_eq
                  constructor
                  · show χ.g pc.x pc.y ⊆ g' pc.x z
                    simp only [g', and_self, ite_true]
                    exact h_g_sub_B'
                  · show χ.g pc.x pc.y ⊆ g' z pc.y
                    simp only [g']
                    have : ¬(z = pc.x ∧ pc.y = z) := by
                      intro ⟨h1, _⟩; linarith
                    simp only [this, ite_false, and_self, ite_true]
                    exact h_g_sub_B''
                · exact absurd hw0 hw0_not
              dom_new_unique := by
                intro u v hu hu_not hv hv_not
                simp only [Finset.mem_insert] at hu hv
                rcases hu with rfl | hu <;> rcases hv with rfl | hv
                · rfl
                · exact absurd hv hv_not
                · exact absurd hu hu_not
                · exact absurd hu hu_not }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              g_agrees := fun _ _ _ _ => rfl
              c2' := by exact h_c2'
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := by
                intro _ h_xm h_ym h_lt
                -- h_actual : ¬(x ∈ dom ∧ y ∈ dom ∧ Adjacent dom x y)
                -- With h_xm and h_ym, we get ¬Adjacent
                have h_not_adj : ¬Adjacent χ.dom pc.x pc.y := fun hadj =>
                  h_actual ⟨h_xm, h_ym, hadj⟩
                -- Since x, y ∈ dom, x < y, but not adjacent, ∃ w between them
                by_contra h_no_w
                push_neg at h_no_w
                exact h_not_adj ⟨h_xm, h_ym, h_lt, fun z hz ⟨hxz, hzy⟩ =>
                  absurd hzy (not_lt.mpr (h_no_w z hz hxz))⟩
              g_sub_f_insert := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              g_sub_g_new := fun _ _ _ w hw hw_not _ _ => absurd hw hw_not
              dom_new_unique := fun u _ hu hu_not _ _ => absurd hu hu_not }

end Bimodal.Metalogic.BXCanonical.Chronicle
