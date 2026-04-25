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
    (ce : C5Counterexample χ) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ x ∈ χ.dom, χ'.f x = χ.f x) ∧
      χ'.c0 ∧
      (∃ y ∈ χ'.dom, ce.x < y ∧ ce.η ∈ χ'.f y) ∧
      χ.dom ⊂ χ'.dom := by
  -- Step 1: Get a fresh point y > all domain points
  obtain ⟨y, hy_gt, hy_notin⟩ := exists_rat_gt_finset χ.dom
  -- Step 2: Use Lemma 2.4 to get an MCS with eta and g_content(f(x))
  have h_mcs_x := h_c0 ce.x ce.x_mem
  obtain ⟨C, h_C_mcs, h_η_C, _, _⟩ :=
    lemma_2_4 h_mcs_x ce.ξ ce.η ce.until_mem
  -- Step 3: Build the new chronicle
  -- f' agrees with f on old domain, assigns C to y
  -- g' is unchanged (placeholder; full interval assignment in ChronicleConstruction)
  refine ⟨⟨fun q => if q = y then C else χ.f q, χ.g, insert y χ.dom⟩,
    Finset.subset_insert y χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hy_notin⟩
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
      χ.dom ⊂ χ'.dom := by
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
    Finset.subset_insert y χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hy_notin⟩
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

/-! ## C4/C4' Counterexample Structures -/

/--
A **C4 counterexample** for a chronicle (Burgess C4a): points x < y in dom with
`¬(γ U δ) ∈ f(x)` and `δ ∈ f(y)` (EVENT at y), but no intermediate z in dom
with `¬γ ∈ f(z)` (negated GUARD at z).

In `untl γ δ`: γ = GUARD, δ = EVENT.
-/
structure C4Counterexample (χ : Chronicle) where
  x : Rat
  y : Rat
  x_mem : x ∈ χ.dom
  y_mem : y ∈ χ.dom
  hxy : x < y
  γ : Formula
  δ : Formula
  neg_until_mem : (Formula.untl γ δ).neg ∈ χ.f x
  event_mem : δ ∈ χ.f y
  no_witness : ¬∃ z ∈ χ.dom, x < z ∧ z < y ∧ γ.neg ∈ χ.f z

/--
A **C4' counterexample** (Since mirror, Burgess C4b): points y < x in dom with
`¬(γ S δ) ∈ f(x)` and `δ ∈ f(y)` (EVENT at y), but no intermediate z
with `¬γ ∈ f(z)` (negated GUARD at z).

In `snce γ δ`: γ = GUARD, δ = EVENT.
-/
structure C4'Counterexample (χ : Chronicle) where
  x : Rat
  y : Rat
  x_mem : x ∈ χ.dom
  y_mem : y ∈ χ.dom
  hyx : y < x
  γ : Formula
  δ : Formula
  neg_since_mem : (Formula.snce γ δ).neg ∈ χ.f x
  event_mem : δ ∈ χ.f y
  no_witness : ¬∃ z ∈ χ.dom, y < z ∧ z < x ∧ γ.neg ∈ χ.f z

/-! ## Lemma 2.9: C4 Counterexample Elimination -/

/--
**Lemma 2.9** (C4 Counterexample Elimination, Burgess C4a): Given a chronicle
satisfying C0 and a C4 counterexample (x, y, γ, δ), eliminate it by inserting
a new point z = (x + y) / 2 between x and y with `¬γ ∈ f(z)` (negated GUARD).

With the correct C4 (check EVENT δ at f(y), negate GUARD γ at f(z)):

- If `¬γ ∈ f(x)`: assign f(z) = f(x), which already has ¬γ.
- If `γ ∈ f(x)` but `¬γ ∈ f(y)`: assign f(z) = f(y).
- If `γ ∈ f(x)` and `γ ∈ f(y)`: hard case, requires Lemma 2.6 (Phase 2).
-/
noncomputable def eliminate_C4_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (ce : C4Counterexample χ) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ x ∈ χ.dom, χ'.f x = χ.f x) ∧
      χ'.c0 ∧
      (∃ z ∈ χ'.dom, ce.x < z ∧ z < ce.y ∧ ce.γ.neg ∈ χ'.f z) ∧
      χ.dom ⊂ χ'.dom := by
  -- Step 1: Find a fresh rational z between x and y, not in the finite domain.
  obtain ⟨z, hx_lt_z, hz_lt_y, hz_notin⟩ := exists_rat_between_not_in_finset χ.dom ce.x ce.y ce.hxy
  -- Step 2: Find an MCS D containing ¬γ (negated GUARD).
  -- By MCS negation completeness: either γ ∈ f(x) or ¬γ ∈ f(x).
  have h_mcs_x := h_c0 ce.x ce.x_mem
  have h_mcs_y := h_c0 ce.y ce.y_mem
  rcases SetMaximalConsistent.negation_complete h_mcs_x ce.γ with h_γ_x | h_neg_γ_x
  · -- Case 1: γ ∈ f(x). Check f(y) for ¬γ.
    rcases SetMaximalConsistent.negation_complete h_mcs_y ce.γ with h_γ_y | h_neg_γ_y
    · -- Sub-case 1a: γ ∈ f(x) and γ ∈ f(y). Both endpoints contain γ (GUARD).
      -- Strategy: split on G(γ) ∈ f(x), then H(γ) ∈ f(y).
      -- If G(γ) ∉ f(x): F(¬γ) ∈ f(x), seed {¬γ} ∪ g_content(f(x)) consistent.
      -- If H(γ) ∉ f(y): P(¬γ) ∈ f(y), seed {¬γ} ∪ h_content(f(y)) consistent.
      rcases SetMaximalConsistent.negation_complete h_mcs_x ce.γ.all_future with h_Gγ_x | h_nGγ_x
      · -- G(γ) ∈ f(x). Check H(γ) ∈ f(y).
        rcases SetMaximalConsistent.negation_complete h_mcs_y ce.γ.all_past with h_Hγ_y | h_nHγ_y
        · -- G(γ) ∈ f(x) and H(γ) ∈ f(y). Genuinely hard sub-case.
          -- Requires guard-strengthening for Until (not available in BX without A4a).
          -- This case is contradictory in any sound model (G(γ) at x with x < y
          -- means γ everywhere between x and y, but ¬(γ U δ) at x with δ at y
          -- requires ¬γ somewhere between). Resolving syntactically needs
          -- additional axioms or g_ordered invariant from the omega chain.
          sorry
        · -- G(γ) ∈ f(x) but H(γ) ∉ f(y). Use P(¬γ) ∈ f(y) via P_neg_of_H_not.
          have h_Hγ_not : ce.γ.all_past ∉ χ.f ce.y :=
            SetMaximalConsistent.neg_excludes h_mcs_y _ h_nHγ_y
          have h_P_neg := P_neg_of_H_not h_mcs_y ce.γ h_Hγ_not
          have h_seed := past_temporal_witness_seed_consistent (χ.f ce.y) h_mcs_y ce.γ.neg h_P_neg
          obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed
          have h_neg_γ_D : ce.γ.neg ∈ D := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
          refine ⟨⟨fun q => if q = z then D else χ.f q, χ.g, insert z χ.dom⟩,
            Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
          · intro x hx
            have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
            exact if_neg h_ne
          · intro x hx
            simp only [Finset.mem_insert] at hx
            rcases hx with rfl | hx
            · simp only [ite_true]; exact h_D_mcs
            · have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
              simp only [h_ne, ite_false]; exact h_c0 x hx
          · refine ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y, ?_⟩
            simp only [ite_true]
            exact h_neg_γ_D
      · -- G(γ) ∉ f(x). Use F(¬γ) ∈ f(x) via F_neg_of_G_not.
        have h_Gγ_not : ce.γ.all_future ∉ χ.f ce.x :=
          SetMaximalConsistent.neg_excludes h_mcs_x _ h_nGγ_x
        have h_F_neg := F_neg_of_G_not h_mcs_x ce.γ h_Gγ_not
        have h_seed := forward_temporal_witness_seed_consistent (χ.f ce.x) h_mcs_x ce.γ.neg h_F_neg
        obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed
        have h_neg_γ_D : ce.γ.neg ∈ D := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
        refine ⟨⟨fun q => if q = z then D else χ.f q, χ.g, insert z χ.dom⟩,
          Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
        · intro x hx
          have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
          exact if_neg h_ne
        · intro x hx
          simp only [Finset.mem_insert] at hx
          rcases hx with rfl | hx
          · simp only [ite_true]; exact h_D_mcs
          · have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
            simp only [h_ne, ite_false]; exact h_c0 x hx
        · refine ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y, ?_⟩
          simp only [ite_true]
          exact h_neg_γ_D
    · -- Sub-case 1b: γ ∈ f(x) and ¬γ ∈ f(y). Use D = f(y).
      refine ⟨⟨fun q => if q = z then χ.f ce.y else χ.f q, χ.g, insert z χ.dom⟩,
        Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
      · intro x hx
        have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
        exact if_neg h_ne
      · intro x hx
        simp only [Finset.mem_insert] at hx
        rcases hx with rfl | hx
        · simp only [ite_true]; exact h_mcs_y
        · have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
          simp only [h_ne, ite_false]; exact h_c0 x hx
      · refine ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y, ?_⟩
        simp only [ite_true]
        exact h_neg_γ_y
  · -- Case 2: ¬γ ∈ f(x). Use D = f(x).
    refine ⟨⟨fun q => if q = z then χ.f ce.x else χ.f q, χ.g, insert z χ.dom⟩,
      Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
    · -- f agrees on old points
      intro x hx
      have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
      exact if_neg h_ne
    · -- C0: every point maps to MCS
      intro x hx
      simp only [Finset.mem_insert] at hx
      rcases hx with rfl | hx
      · simp only [ite_true]; exact h_mcs_x
      · have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
        simp only [h_ne, ite_false]; exact h_c0 x hx
    · -- Witness: z is between x and y with ¬γ ∈ f'(z) = f(x)
      refine ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y, ?_⟩
      simp only [ite_true]
      exact h_neg_γ_x

/--
**Lemma 2.9'** (C4' Counterexample Elimination, Burgess C4b): Mirror of Lemma 2.9
for Since. Insert z between y and x with `¬γ ∈ f(z)` (negated GUARD).

- If `¬γ ∈ f(x)`: assign f(z) = f(x).
- If `γ ∈ f(x)` but `¬γ ∈ f(y)`: assign f(z) = f(y).
- If `γ ∈ f(x)` and `γ ∈ f(y)`: hard case (Phase 2).
-/
noncomputable def eliminate_C4'_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (ce : C4'Counterexample χ) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ x ∈ χ.dom, χ'.f x = χ.f x) ∧
      χ'.c0 ∧
      (∃ z ∈ χ'.dom, ce.y < z ∧ z < ce.x ∧ ce.γ.neg ∈ χ'.f z) ∧
      χ.dom ⊂ χ'.dom := by
  -- Mirror of C4 elimination for Since direction.
  -- Find a fresh rational z between y and x, not in the finite domain.
  obtain ⟨z, hy_lt_z, hz_lt_x, hz_notin⟩ := exists_rat_between_not_in_finset χ.dom ce.y ce.x ce.hyx
  have h_mcs_x := h_c0 ce.x ce.x_mem
  have h_mcs_y := h_c0 ce.y ce.y_mem
  -- Case split on γ ∈ f(x) vs ¬γ ∈ f(x), then on f(y).
  rcases SetMaximalConsistent.negation_complete h_mcs_x ce.γ with h_γ_x | h_neg_γ_x
  · -- Case 1: γ ∈ f(x). Check f(y).
    rcases SetMaximalConsistent.negation_complete h_mcs_y ce.γ with h_γ_y | h_neg_γ_y
    · -- Sub-case 1a: γ ∈ f(x) and γ ∈ f(y). Mirror of C4 hard case.
      -- Strategy: split on H(γ) at f(x), then G(γ) at f(y).
      rcases SetMaximalConsistent.negation_complete h_mcs_x ce.γ.all_past with h_Hγ_x | h_nHγ_x
      · -- H(γ) ∈ f(x). Check G(γ) ∈ f(y).
        rcases SetMaximalConsistent.negation_complete h_mcs_y ce.γ.all_future with h_Gγ_y | h_nGγ_y
        · -- H(γ) ∈ f(x) and G(γ) ∈ f(y). Genuinely hard sub-case (mirror).
          -- See C4 hard case comment: requires A4a-equivalent or g_ordered.
          sorry
        · -- H(γ) ∈ f(x) but G(γ) ∉ f(y). Use F(¬γ) ∈ f(y) via F_neg_of_G_not.
          have h_Gγ_not : ce.γ.all_future ∉ χ.f ce.y :=
            SetMaximalConsistent.neg_excludes h_mcs_y _ h_nGγ_y
          have h_F_neg := F_neg_of_G_not h_mcs_y ce.γ h_Gγ_not
          have h_seed := forward_temporal_witness_seed_consistent (χ.f ce.y) h_mcs_y ce.γ.neg h_F_neg
          obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed
          have h_neg_γ_D : ce.γ.neg ∈ D := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
          refine ⟨⟨fun q => if q = z then D else χ.f q, χ.g, insert z χ.dom⟩,
            Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
          · intro x hx
            have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
            exact if_neg h_ne
          · intro x hx
            simp only [Finset.mem_insert] at hx
            rcases hx with rfl | hx
            · simp only [ite_true]; exact h_D_mcs
            · have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
              simp only [h_ne, ite_false]; exact h_c0 x hx
          · refine ⟨z, Finset.mem_insert_self z χ.dom, hy_lt_z, hz_lt_x, ?_⟩
            simp only [ite_true]
            exact h_neg_γ_D
      · -- H(γ) ∉ f(x). Use P(¬γ) ∈ f(x) via P_neg_of_H_not.
        have h_Hγ_not : ce.γ.all_past ∉ χ.f ce.x :=
          SetMaximalConsistent.neg_excludes h_mcs_x _ h_nHγ_x
        have h_P_neg := P_neg_of_H_not h_mcs_x ce.γ h_Hγ_not
        have h_seed := past_temporal_witness_seed_consistent (χ.f ce.x) h_mcs_x ce.γ.neg h_P_neg
        obtain ⟨D, h_sup, h_D_mcs⟩ := set_lindenbaum _ h_seed
        have h_neg_γ_D : ce.γ.neg ∈ D := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
        refine ⟨⟨fun q => if q = z then D else χ.f q, χ.g, insert z χ.dom⟩,
          Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
        · intro x hx
          have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
          exact if_neg h_ne
        · intro x hx
          simp only [Finset.mem_insert] at hx
          rcases hx with rfl | hx
          · simp only [ite_true]; exact h_D_mcs
          · have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
            simp only [h_ne, ite_false]; exact h_c0 x hx
        · refine ⟨z, Finset.mem_insert_self z χ.dom, hy_lt_z, hz_lt_x, ?_⟩
          simp only [ite_true]
          exact h_neg_γ_D
    · -- Sub-case 1b: γ ∈ f(x) and ¬γ ∈ f(y). Use D = f(y).
      refine ⟨⟨fun q => if q = z then χ.f ce.y else χ.f q, χ.g, insert z χ.dom⟩,
        Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
      · intro x hx
        have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
        exact if_neg h_ne
      · intro x hx
        simp only [Finset.mem_insert] at hx
        rcases hx with rfl | hx
        · simp only [ite_true]; exact h_mcs_y
        · have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
          simp only [h_ne, ite_false]; exact h_c0 x hx
      · refine ⟨z, Finset.mem_insert_self z χ.dom, hy_lt_z, hz_lt_x, ?_⟩
        simp only [ite_true]
        exact h_neg_γ_y
  · -- Case 2: ¬γ ∈ f(x). Use D = f(x).
    refine ⟨⟨fun q => if q = z then χ.f ce.x else χ.f q, χ.g, insert z χ.dom⟩,
      Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
    · intro x hx
      have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
      exact if_neg h_ne
    · intro x hx
      simp only [Finset.mem_insert] at hx
      rcases hx with rfl | hx
      · simp only [ite_true]; exact h_mcs_x
      · have h_ne : x ≠ z := fun h => hz_notin (h ▸ hx)
        simp only [h_ne, ite_false]; exact h_c0 x hx
    · refine ⟨z, Finset.mem_insert_self z χ.dom, hy_lt_z, hz_lt_x, ?_⟩
      simp only [ite_true]
      exact h_neg_γ_x

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
      χ.dom ⊂ χ'.dom := by
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
    Finset.subset_insert z χ.dom, ?_, ?_, Finset.ssubset_insert hz_notin⟩
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
      χ.dom ⊂ χ'.dom := by
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
    Finset.subset_insert z χ.dom, ?_, ?_, Finset.ssubset_insert hz_notin⟩
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
      χ.dom ⊂ χ'.dom := by
  set z := (x + y) / 2 with hz_def
  have hxy := h_adj.2.2.1
  have hz_lt_y : z < y := by linarith
  have hx_lt_z : x < z := by linarith
  have hz_notin : z ∉ χ.dom := by
    intro h_mem; exact h_adj.2.2.2 z h_mem ⟨hx_lt_z, hz_lt_y⟩
  refine ⟨⟨fun q => if q = z then χ.f x else χ.f q, χ.g, insert z χ.dom⟩,
    Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin⟩
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
  | g_prop_forward  : PotentialCounterexampleKind  -- G-propagation: G(α) ∈ f(x), α ∉ f(y), x < y adj
  | g_prop_backward : PotentialCounterexampleKind  -- H-propagation: H(α) ∈ f(x), α ∉ f(y), y < x adj
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

/--
Attempt to eliminate a potential counterexample. If it is not an actual
counterexample for the current chronicle, the chronicle is returned unchanged.
Otherwise, a new chronicle with the counterexample eliminated is returned.

Returns an `EliminationResult` bundling domain extension, C0, f-agreement,
and C5/C5' witness guarantees.
-/
noncomputable def eliminate_potential_counterexample
    (χ : Chronicle) (h_c0 : χ.c0)
    (pc : PotentialCounterexample) :
    EliminationResult χ pc := by
  -- Helper for impossible kind discriminants
  have absurd_kind {k : PotentialCounterexampleKind} {P : Prop}
      (h : k = .c5_forward) (hk : k = .c4_forward ∨ k = .c4_backward ∨ k = .c5_backward) : P :=
    by rcases hk with rfl | rfl | rfl <;> exact absurd h (by decide)
  match h_kind : pc.kind with
  | .c5_forward =>
    -- Forward (Until) C5 case
    by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.untl pc.ξ pc.η ∈ χ.f pc.x ∧
        ¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
          ∀ z ∈ χ.dom, pc.x < z → z < y →
            pc.ξ ∈ χ.f z ∧ Formula.untl pc.ξ pc.η ∈ χ.f z
    · obtain ⟨h_mem, h_until, h_no_wit⟩ := h_actual
      have h_elim := eliminate_C5_counterexample h_c0
        (⟨pc.x, h_mem, pc.ξ, pc.η, h_until, h_no_wit⟩ : C5Counterexample χ)
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact { val := χ'
              dom_sub := h_prop.1
              c0 := h_prop.2.2.1
              f_agrees := h_prop.2.1
              c5_forward_witness := by
                intro _ _ _; exact h_prop.2.2.2.1
              c5_backward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              c5_forward_witness := by
                intro _ h_mem h_until
                push_neg at h_actual
                obtain ⟨y, hy_dom, hy_lt, hy_η, _⟩ := h_actual h_mem h_until
                exact ⟨y, hy_dom, hy_lt, hy_η⟩
              c5_backward_witness := fun h => absurd h (by rw [h_kind] at h; exact absurd h (by decide))
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
  | .c5_backward =>
    -- Backward (Since) C5' case
    by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.snce pc.ξ pc.η ∈ χ.f pc.x ∧
        ¬∃ y ∈ χ.dom, y < pc.x ∧ pc.η ∈ χ.f y ∧
          ∀ z ∈ χ.dom, y < z → z < pc.x →
            pc.ξ ∈ χ.f z ∧ Formula.snce pc.ξ pc.η ∈ χ.f z
    · obtain ⟨h_mem, h_since, h_no_wit⟩ := h_actual
      have h_elim := eliminate_C5'_counterexample h_c0
        (⟨pc.x, h_mem, pc.ξ, pc.η, h_since, h_no_wit⟩ : C5'Counterexample χ)
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact { val := χ'
              dom_sub := h_prop.1
              c0 := h_prop.2.2.1
              f_agrees := h_prop.2.1
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := by
                intro _ _ _; exact h_prop.2.2.2.1
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := by
                intro _ h_mem h_since
                push_neg at h_actual
                obtain ⟨y, hy_dom, hy_lt, hy_η, _⟩ := h_actual h_mem h_since
                exact ⟨y, hy_dom, hy_lt, hy_η⟩
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
  | .c4_forward =>
    -- Forward C4 case (corrected Burgess C4a: check EVENT η at f(y), negate GUARD ξ at f(z))
    -- Now checks ALL pairs x < y, not just adjacent pairs.
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧
        pc.x < pc.y ∧
        (Formula.untl pc.ξ pc.η).neg ∈ χ.f pc.x ∧
        pc.η ∈ χ.f pc.y ∧
        ¬∃ z ∈ χ.dom, pc.x < z ∧ z < pc.y ∧ pc.ξ.neg ∈ χ.f z
    · obtain ⟨h_xm, h_ym, h_lt, h_neg_until, h_event, h_no_wit⟩ := h_actual
      have h_elim := eliminate_C4_counterexample h_c0
        (⟨pc.x, pc.y, h_xm, h_ym, h_lt, pc.ξ, pc.η, h_neg_until, h_event, h_no_wit⟩ : C4Counterexample χ)
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact { val := χ'
              dom_sub := h_prop.1
              c0 := h_prop.2.2.1
              f_agrees := h_prop.2.1
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun _ _ _ _ _ _ => h_prop.2.2.2.1
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := by
                intro _ h_xm' h_ym' h_lt' h_neg_until' h_event'
                push_neg at h_actual
                exact h_actual h_xm' h_ym' h_lt' h_neg_until' h_event'
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
  | .c4_backward =>
    -- Backward C4' case (corrected Burgess C4b: check EVENT η at f(y), negate GUARD ξ at f(z))
    -- Now checks ALL pairs y < x, not just adjacent pairs.
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧
        pc.y < pc.x ∧
        (Formula.snce pc.ξ pc.η).neg ∈ χ.f pc.x ∧
        pc.η ∈ χ.f pc.y ∧
        ¬∃ z ∈ χ.dom, pc.y < z ∧ z < pc.x ∧ pc.ξ.neg ∈ χ.f z
    · obtain ⟨h_xm, h_ym, h_lt, h_neg_since, h_event, h_no_wit⟩ := h_actual
      have h_elim := eliminate_C4'_counterexample h_c0
        (⟨pc.x, pc.y, h_xm, h_ym, h_lt, pc.ξ, pc.η, h_neg_since, h_event, h_no_wit⟩ : C4'Counterexample χ)
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact { val := χ'
              dom_sub := h_prop.1
              c0 := h_prop.2.2.1
              f_agrees := h_prop.2.1
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun _ _ _ _ _ _ => h_prop.2.2.2.1
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := by
                intro _ h_xm' h_ym' h_lt' h_neg_since' h_event'
                push_neg at h_actual
                exact h_actual h_xm' h_ym' h_lt' h_neg_since' h_event'
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
  | .g_prop_forward =>
    -- G-propagation forward: G(η) ∈ f(x), η ∉ f(y), x < y adjacent
    -- Here ξ = formula α, η encodes α, x and y are the adjacent pair
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧
        Adjacent χ.dom pc.x pc.y ∧
        Formula.all_future pc.η ∈ χ.f pc.x ∧
        pc.η ∉ χ.f pc.y
    · obtain ⟨h_xm, h_ym, h_adj, h_G, h_not⟩ := h_actual
      have h_elim := eliminate_g_prop_counterexample h_c0 pc.x pc.y pc.η h_xm h_ym h_adj h_G h_not
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact { val := χ'
              dom_sub := h_prop.1
              c0 := h_prop.2.2.1
              f_agrees := h_prop.2.1
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
  | .g_prop_backward =>
    -- H-propagation backward: H(η) ∈ f(x), η ∉ f(y), y < x adjacent
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧
        Adjacent χ.dom pc.y pc.x ∧
        Formula.all_past pc.η ∈ χ.f pc.x ∧
        pc.η ∉ χ.f pc.y
    · obtain ⟨h_xm, h_ym, h_adj, h_H, h_not⟩ := h_actual
      have h_elim := eliminate_h_prop_counterexample h_c0 pc.x pc.y pc.η h_xm h_ym h_adj h_H h_not
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact { val := χ'
              dom_sub := h_prop.1
              c0 := h_prop.2.2.1
              f_agrees := h_prop.2.1
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide) }
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
      exact { val := ⟨fun q => if q = z then χ.f pc.x else χ.f q, χ.g, insert z χ.dom⟩
              dom_sub := Finset.subset_insert z χ.dom
              c0 := by
                intro q hq
                simp only [Finset.mem_insert] at hq
                rcases hq with rfl | hq
                · simp only [ite_true]; exact h_c0 pc.x h_xm
                · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                  simp only [h_ne, ite_false]; exact h_c0 q hq
              f_agrees := by
                intro q hq
                have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
                exact if_neg h_ne
              c5_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c5_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_forward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              c4_backward_witness := fun h => by rw [h_kind] at h; exact absurd h (by decide)
              density_witness := by
                intro _ _ _ h_lt
                exact ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y⟩ }
    · exact { val := χ
              dom_sub := Finset.Subset.refl _
              c0 := h_c0
              f_agrees := fun _ _ => rfl
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
                  absurd hzy (not_lt.mpr (h_no_w z hz hxz))⟩ }

end Bimodal.Metalogic.BXCanonical.Chronicle
