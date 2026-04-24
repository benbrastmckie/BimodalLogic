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
A **C4 counterexample** for a chronicle: adjacent points x < y with
`¬(γ U δ) ∈ f(x)` and `γ ∈ f(y)`, but no intermediate z in dom with `¬δ ∈ f(z)`.
-/
structure C4Counterexample (χ : Chronicle) where
  x : Rat
  y : Rat
  x_mem : x ∈ χ.dom
  y_mem : y ∈ χ.dom
  adj : Adjacent χ.dom x y
  γ : Formula
  δ : Formula
  neg_until_mem : (Formula.untl γ δ).neg ∈ χ.f x
  guard_mem : γ ∈ χ.f y
  no_witness : ¬∃ z ∈ χ.dom, x < z ∧ z < y ∧ δ.neg ∈ χ.f z

/--
A **C4' counterexample** (Since mirror): adjacent points y < x with
`¬(γ S δ) ∈ f(x)` and `γ ∈ f(y)`, but no intermediate z with `¬δ ∈ f(z)`.
-/
structure C4'Counterexample (χ : Chronicle) where
  x : Rat
  y : Rat
  x_mem : x ∈ χ.dom
  y_mem : y ∈ χ.dom
  adj : Adjacent χ.dom y x
  γ : Formula
  δ : Formula
  neg_since_mem : (Formula.snce γ δ).neg ∈ χ.f x
  guard_mem : γ ∈ χ.f y
  no_witness : ¬∃ z ∈ χ.dom, y < z ∧ z < x ∧ δ.neg ∈ χ.f z

/-! ## Lemma 2.9: C4 Counterexample Elimination -/

/--
**Lemma 2.9** (C4 Counterexample Elimination): Given a chronicle satisfying C0
and a C4 counterexample (x, y, gamma, delta), eliminate it by inserting a new
point z between x and y with `¬δ ∈ f(z)`.

The construction proceeds by cases on the number of domain points strictly
between x and y:

- **Base case** (no intermediate points, i.e., x and y are truly adjacent in dom):
  Use `lemma_2_6` to insert a point z = (x + y) / 2 with an MCS containing ¬δ.
  The seed set {¬δ} ∪ g_content(f(x)) is consistent because ¬(γ U δ) ∈ f(x)
  and the r-relation decomposition.

- **Inductive case** (k+1 intermediate points): The nearest intermediate point
  z₀ either has δ ∈ f(z₀) or ¬δ ∈ f(z₀). If ¬δ ∈ f(z₀), we're done.
  If δ ∈ f(z₀), then by the r-relation and ¬(γ U δ) ∈ f(x), we get a
  sub-counterexample with fewer intermediate points.

Sorry'd pending Phase 4 implementation using `lemma_2_6` (non-strong version).
`lemma_2_6_strong` was withdrawn in Phase 3 (false under strict semantics).
C4 elimination only needs neg delta in D and g_content(A) subset D, which
`lemma_2_6` provides.
-/
noncomputable def eliminate_C4_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (ce : C4Counterexample χ) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ x ∈ χ.dom, χ'.f x = χ.f x) ∧
      χ'.c0 ∧
      (∃ z ∈ χ'.dom, ce.x < z ∧ z < ce.y ∧ ce.δ.neg ∈ χ'.f z) ∧
      χ.dom ⊂ χ'.dom := by
  -- The elimination requires inserting a new point between x and y.
  -- Since x and y are adjacent in dom (no intermediate domain points),
  -- we can place the new point at the midpoint.
  -- The MCS at the new point must contain ¬δ and be compatible with
  -- g_content(f(x)) via the r-relation.
  -- This reduces to lemma_2_6 (PointInsertion.lean), which is sorry'd
  -- in Phase 3. We sorry this pending that dependency.
  sorry

/--
**Lemma 2.9'** (C4' Counterexample Elimination): Mirror of Lemma 2.9 for Since.
-/
noncomputable def eliminate_C4'_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (ce : C4'Counterexample χ) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ x ∈ χ.dom, χ'.f x = χ.f x) ∧
      χ'.c0 ∧
      (∃ z ∈ χ'.dom, ce.y < z ∧ z < ce.x ∧ ce.δ.neg ∈ χ'.f z) ∧
      χ.dom ⊂ χ'.dom := by
  -- Mirror of C4 elimination for Since direction.
  -- Sorry'd pending Phase 4 implementation using `lemma_2_6` (non-strong).
  -- `lemma_2_6_strong` was withdrawn in Phase 3 (false under strict semantics).
  sorry

/-! ## Potential Counterexample Interface -/

/--
The **kind** of a potential counterexample, distinguishing between
C4 (backward counterexample) and C5 (forward witness) conditions,
each in forward (Until) and backward (Since) directions.
-/
inductive PotentialCounterexampleKind : Type where
  | c4_forward  : PotentialCounterexampleKind  -- C4: Until backward counterexample
  | c4_backward : PotentialCounterexampleKind  -- C4': Since backward counterexample
  | c5_forward  : PotentialCounterexampleKind  -- C5: Until forward witness
  | c5_backward : PotentialCounterexampleKind  -- C5': Since forward witness
  deriving DecidableEq, Countable

/--
A **potential counterexample** encodes a tuple (x, y, xi, eta, kind) that MIGHT
be a C4/C4'/C5/C5' counterexample depending on the current chronicle state.

- For C5/C5' counterexamples: only `x`, `ξ`, `η` are relevant; `y` is ignored.
- For C4/C4' counterexamples: both `x` and `y` identify the adjacent pair,
  `γ = ξ` is the guard formula, and `δ = η` is the eventuality formula.
-/
structure PotentialCounterexample where
  x : Rat
  y : Rat
  ξ : Formula
  η : Formula
  kind : PotentialCounterexampleKind

/--
Attempt to eliminate a potential counterexample. If it is not an actual
counterexample for the current chronicle, the chronicle is returned unchanged.
Otherwise, a new chronicle with the counterexample eliminated is returned.

Returns: a chronicle chi' with dom extends, C0, and f agreement on old points.
-/
noncomputable def eliminate_potential_counterexample
    (χ : Chronicle) (h_c0 : χ.c0)
    (pc : PotentialCounterexample) :
    { χ' : Chronicle // χ.dom ⊆ χ'.dom ∧ χ'.c0 ∧
      (∀ x ∈ χ.dom, χ'.f x = χ.f x) } := by
  match pc.kind with
  | .c5_forward =>
    -- Forward (Until) C5 case
    by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.untl pc.ξ pc.η ∈ χ.f pc.x ∧
        ¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
          ∀ z ∈ χ.dom, pc.x < z → z < y →
            pc.ξ ∈ χ.f z ∧ Formula.untl pc.ξ pc.η ∈ χ.f z
    · obtain ⟨h_mem, h_until, h_no_wit⟩ := h_actual
      have ce : C5Counterexample χ := ⟨pc.x, h_mem, pc.ξ, pc.η, h_until, h_no_wit⟩
      have h_elim := eliminate_C5_counterexample h_c0 ce
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact ⟨χ', h_prop.1, h_prop.2.2.1, h_prop.2.1⟩
    · exact ⟨χ, Finset.Subset.refl _, h_c0, fun _ _ => rfl⟩
  | .c5_backward =>
    -- Backward (Since) C5' case
    by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.snce pc.ξ pc.η ∈ χ.f pc.x ∧
        ¬∃ y ∈ χ.dom, y < pc.x ∧ pc.η ∈ χ.f y ∧
          ∀ z ∈ χ.dom, y < z → z < pc.x →
            pc.ξ ∈ χ.f z ∧ Formula.snce pc.ξ pc.η ∈ χ.f z
    · obtain ⟨h_mem, h_since, h_no_wit⟩ := h_actual
      have ce : C5'Counterexample χ := ⟨pc.x, h_mem, pc.ξ, pc.η, h_since, h_no_wit⟩
      have h_elim := eliminate_C5'_counterexample h_c0 ce
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact ⟨χ', h_prop.1, h_prop.2.2.1, h_prop.2.1⟩
    · exact ⟨χ, Finset.Subset.refl _, h_c0, fun _ _ => rfl⟩
  | .c4_forward =>
    -- Forward C4 case: ¬(ξ U η) ∈ f(x) and ξ ∈ f(y) with x,y adjacent
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧
        Adjacent χ.dom pc.x pc.y ∧
        (Formula.untl pc.ξ pc.η).neg ∈ χ.f pc.x ∧
        pc.ξ ∈ χ.f pc.y ∧
        ¬∃ z ∈ χ.dom, pc.x < z ∧ z < pc.y ∧ pc.η.neg ∈ χ.f z
    · obtain ⟨h_xm, h_ym, h_adj, h_neg_until, h_guard, h_no_wit⟩ := h_actual
      have ce : C4Counterexample χ :=
        ⟨pc.x, pc.y, h_xm, h_ym, h_adj, pc.ξ, pc.η, h_neg_until, h_guard, h_no_wit⟩
      have h_elim := eliminate_C4_counterexample h_c0 ce
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact ⟨χ', h_prop.1, h_prop.2.2.1, h_prop.2.1⟩
    · exact ⟨χ, Finset.Subset.refl _, h_c0, fun _ _ => rfl⟩
  | .c4_backward =>
    -- Backward C4' case: ¬(ξ S η) ∈ f(x) and ξ ∈ f(y) with y,x adjacent (y < x)
    by_cases h_actual : pc.x ∈ χ.dom ∧ pc.y ∈ χ.dom ∧
        Adjacent χ.dom pc.y pc.x ∧
        (Formula.snce pc.ξ pc.η).neg ∈ χ.f pc.x ∧
        pc.ξ ∈ χ.f pc.y ∧
        ¬∃ z ∈ χ.dom, pc.y < z ∧ z < pc.x ∧ pc.η.neg ∈ χ.f z
    · obtain ⟨h_xm, h_ym, h_adj, h_neg_since, h_guard, h_no_wit⟩ := h_actual
      have ce : C4'Counterexample χ :=
        ⟨pc.x, pc.y, h_xm, h_ym, h_adj, pc.ξ, pc.η, h_neg_since, h_guard, h_no_wit⟩
      have h_elim := eliminate_C4'_counterexample h_c0 ce
      let χ' := h_elim.choose
      have h_prop := h_elim.choose_spec
      exact ⟨χ', h_prop.1, h_prop.2.2.1, h_prop.2.1⟩
    · exact ⟨χ, Finset.Subset.refl _, h_c0, fun _ _ => rfl⟩

end Bimodal.Metalogic.BXCanonical.Chronicle
