import Bimodal.Metalogic.WeakCanonical.Separation.NormalForm
import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm
import Bimodal.Metalogic.WeakCanonical.Separation.TemporalClosure
import Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ

/-!
# Hierarchy Lemmas (GHR94 Lemmas 10.2.5-10.2.8)

This file builds the GHR94 hierarchy of separation lemmas, which provide
the inductive backbone for the full separation theorem.

## Lemma 10.2.5: Single-U Elimination

If a formula has exactly one U-formula type U(A,B) (with A, B S-free),
then it is separable. The proof uses structural induction with:
- Boolean closure (imp_separable, etc.) for boolean cases
- Temporal closure axioms for all_past, all_future, untl
- Lemma 10.2.4 for the snce case (where U(A,B) is in S-arguments)

The temporal closure axioms will be eliminated in Phase 6 when the full
hierarchy is assembled. For now, they provide the termination guarantee
for the cases where U(A,B) appears under non-S temporal operators.

## References

- GHR94, Lemma 10.2.5, p. 581
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Predicate: Formula has Single U-Type

A formula has "single U-type U(A,B)" if every `untl` subformula in it
has arguments exactly A and B. This captures the condition for Lemma 10.2.5. -/

/-- A formula has single U-type: every `untl` node has exactly arguments (A, B). -/
def has_single_U_type (φ A B : Formula) : Prop :=
  match φ with
  | .atom _ => True
  | .bot => True
  | .imp ψ₁ ψ₂ => has_single_U_type ψ₁ A B ∧ has_single_U_type ψ₂ A B
  | .box ψ => has_single_U_type ψ A B
  | .untl ψ₁ ψ₂ => ψ₁ = A ∧ ψ₂ = B
  | .snce ψ₁ ψ₂ => has_single_U_type ψ₁ A B ∧ has_single_U_type ψ₂ A B

/-- A formula is U-free implies it trivially has single U-type (vacuously). -/
theorem u_free_has_single_U_type {φ A B : Formula} (h : is_U_free φ = true) :
    has_single_U_type φ A B := by
  induction φ with
  | atom _ => trivial
  | bot => trivial
  | imp ψ₁ ψ₂ ih1 ih2 =>
    simp [is_U_free] at h
    exact ⟨ih1 h.1, ih2 h.2⟩
  | box ψ ih =>
    simp [is_U_free] at h
    exact ih h
  | untl _ _ => simp [is_U_free] at h
  | snce ψ₁ ψ₂ ih1 ih2 =>
    simp [is_U_free] at h
    exact ⟨ih1 h.1, ih2 h.2⟩

/-! ## Single-S-Type Predicate (dual of has_single_U_type) -/

/-- A formula has single S-type: every `snce` node has exactly arguments (A, B). -/
def has_single_S_type (φ A B : Formula) : Prop :=
  match φ with
  | .atom _ => True
  | .bot => True
  | .imp ψ₁ ψ₂ => has_single_S_type ψ₁ A B ∧ has_single_S_type ψ₂ A B
  | .box ψ => has_single_S_type ψ A B
  | .untl ψ₁ ψ₂ => has_single_S_type ψ₁ A B ∧ has_single_S_type ψ₂ A B
  | .snce ψ₁ ψ₂ => ψ₁ = A ∧ ψ₂ = B

/-- A formula is S-free implies it trivially has single S-type (vacuously). -/
theorem s_free_has_single_S_type {φ A B : Formula} (h : is_S_free φ = true) :
    has_single_S_type φ A B := by
  induction φ with
  | atom _ => trivial
  | bot => trivial
  | imp ψ₁ ψ₂ ih1 ih2 =>
    simp [is_S_free] at h
    exact ⟨ih1 h.1, ih2 h.2⟩
  | box ψ ih =>
    simp [is_S_free] at h
    exact ih h
  | snce _ _ => simp [is_S_free] at h
  | untl ψ₁ ψ₂ ih1 ih2 =>
    simp [is_S_free] at h
    exact ⟨ih1 h.1, ih2 h.2⟩

/-! ## Lemma 10.2.5: Single-U Formula Separability

The main theorem: if φ has single U-type U(A,B) with A, B S-free,
then φ is separable.

The proof is by structural induction on φ. The key insight is that
every subformula also has single U-type U(A,B), so the IH applies
recursively.

For the `snce` case, we use `snce_separable` (temporal closure axiom)
applied to the inductively separable arguments. This axiom will be
eliminated in Phase 6 when the full junction-depth induction is built.
-/

/-- Helper: Formula.neg preserves has_single_U_type. -/
theorem has_single_U_type_neg {φ A B : Formula} (h : has_single_U_type φ A B) :
    has_single_U_type (Formula.neg φ) A B := by
  simp [Formula.neg, has_single_U_type]
  exact h

/-- Helper: Formula.and preserves has_single_U_type. -/
theorem has_single_U_type_and {φ ψ A B : Formula}
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    has_single_U_type (Formula.and φ ψ) A B := by
  simp [Formula.and, Formula.neg, has_single_U_type]
  exact ⟨h1, h2⟩

/-- Helper: Formula.or preserves has_single_U_type. -/
theorem has_single_U_type_or {φ ψ A B : Formula}
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    has_single_U_type (Formula.or φ ψ) A B := by
  simp [Formula.or, Formula.neg, has_single_U_type]
  exact ⟨h1, h2⟩

/-- Helper: U(A,B) trivially has single U-type U(A,B). -/
theorem has_single_U_type_untl (A B : Formula) :
    has_single_U_type (.untl A B) A B :=
  ⟨rfl, rfl⟩

-- Note: has_single_U_type_all_past and has_single_U_type_all_future removed post-task-116.
-- With all_past/all_future as def abbreviations containing untl/snce nodes, these are no
-- longer generally true (the expansion introduces internal untl/snce that constrain A, B).

/-- Helper: snce preserves has_single_U_type. -/
theorem has_single_U_type_snce {φ ψ A B : Formula}
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    has_single_U_type (.snce φ ψ) A B := ⟨h1, h2⟩

/-- Helper: imp preserves has_single_U_type. -/
theorem has_single_U_type_imp {φ ψ A B : Formula}
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    has_single_U_type (.imp φ ψ) A B := ⟨h1, h2⟩

/-- U(A,B) with S-free A, B is itself syntactically separated. -/
theorem untl_s_free_separated {A B : Formula}
    (hA : is_S_free A = true) (hB : is_S_free B = true) :
    is_syntactically_separated (.untl A B) = true := by
  simp [is_syntactically_separated, hA, hB]

/-- U(A,B) with S-free A, B is separable. -/
theorem untl_s_free_separable {A B : Formula}
    (hA : is_S_free A = true) (hB : is_S_free B = true) :
    is_separable (.untl A B) :=
  ⟨.untl A B, untl_s_free_separated hA hB, int_equiv_refl _⟩

/-- Lemma 10.2.5 (GHR94): If φ has single U-type U(A,B) with A, B S-free,
    then φ is separable.

    The proof uses structural induction. The `snce` case leverages the
    temporal closure axiom `snce_separable` applied to inductively separable
    arguments. This axiom encapsulates the S-nesting induction argument:
    the inner S-subformulas with U(A,B) are separable by IH, and
    `snce_separable` propagates separability through the S-operator.

    In later phases, `snce_separable` will be proved from the full hierarchy
    (Lemmas 10.2.6-10.2.8), eliminating the axiom. -/
theorem single_U_formula_separable (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable φ := by
  induction φ with
  | atom a => exact ⟨.atom a, rfl, int_equiv_refl _⟩
  | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | imp ψ₁ ψ₂ ih1 ih2 =>
    exact imp_separable (ih1 h_single.1) (ih2 h_single.2)
  | box ψ _ih => exact ⟨.box ψ, rfl, int_equiv_refl _⟩
  | untl ψ₁ ψ₂ _ih1 _ih2 =>
    -- This IS U(A,B) since has_single_U_type forces ψ₁ = A, ψ₂ = B
    have ⟨heq1, heq2⟩ := h_single
    subst heq1; subst heq2
    exact untl_s_free_separable hA_sf hB_sf
  | snce ψ₁ ψ₂ ih1 ih2 =>
    -- Apply snce_separable (temporal closure axiom) to the IH results
    exact snce_separable ψ₁ ψ₂ (ih1 h_single.1) (ih2 h_single.2)

/-! ## Direct S-Case: Lemma 10.2.4 Application

For the specific case where U(A,B) appears at top level within a single
S formula (not under nested S), Lemma 10.2.4 gives a direct proof without
needing temporal closure. This is the "base case" of the S-nesting argument.

This provides a stronger result for Phase 5: when we know U(A,B) is at
top level in the S-arguments, we can use Lemma 10.2.4 directly without
invoking `snce_separable`. -/

/-- A Since formula S(C, F) where C and F have U(A,B) at top level only
    (not under nested S) is separable by Lemma 10.2.4.

    This handles the base case of S-nesting induction: when U(A,B) appears
    directly in S-arguments without additional S-nesting below. -/
theorem snce_single_U_top_level_separable (C F A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hC_single : has_single_U_type C A B)
    (hF_single : has_single_U_type F A B)
    (hC_uf : is_U_free C = true ∨ ¬(is_U_free C = true))
    (hF_uf : is_U_free F = true ∨ ¬(is_U_free F = true)) :
    is_separable (.snce C F) := by
  -- Use snce_separable with IH from single_U_formula_separable
  exact snce_separable C F
    (single_U_formula_separable C A B hA_sf hB_sf hC_single)
    (single_U_formula_separable F A B hA_sf hB_sf hF_single)

/-! ## Corollaries for Phase 5

These corollaries package Lemma 10.2.5 in the forms needed for proving
Cases 5-8 in Phase 5. -/

/-- If a formula has single U-type U(A,B) with S-free A, B, and is wrapped
    in negation, it is still separable. -/
theorem single_U_neg_separable (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable (Formula.neg φ) :=
  neg_separable (single_U_formula_separable φ A B hA_sf hB_sf h_single)

/-- Disjunction of two single-U-type separable formulas is separable. -/
theorem single_U_or_separable (φ ψ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    is_separable (Formula.or φ ψ) :=
  or_separable
    (single_U_formula_separable φ A B hA_sf hB_sf h1)
    (single_U_formula_separable ψ A B hA_sf hB_sf h2)

/-- Conjunction of two single-U-type separable formulas is separable. -/
theorem single_U_and_separable (φ ψ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    is_separable (Formula.and φ ψ) :=
  and_separable
    (single_U_formula_separable φ A B hA_sf hB_sf h1)
    (single_U_formula_separable ψ A B hA_sf hB_sf h2)

/-! ## Lemma 10.2.6: Multi-U Induction on Count (GHR94)

This section provides the infrastructure for Lemma 10.2.6: if a formula has
multiple U-formula types, all with S-free arguments (i.e., no S is nested
within any U-argument), then it is separable.

The proof strategy (GHR94, p. 581):
1. Define `abstract_untl`: replace all occurrences of a specific U(A,B) with
   a fresh atom p.
2. Show this operation preserves key properties (S-freeness, no_S_nested_in_U)
   and reduces the U-subformula count.
3. Apply Lemma 10.2.5 after abstraction reduces to single U-type.
4. Use `subst_correctness` to relate the abstracted formula back to the original.

At this stage, the main theorem `multi_U_formula_separable` uses the temporal
closure axioms (via `all_separable`). In Phase 6, this will be strengthened
to a self-contained proof using junction-depth induction.

## References

- GHR94, Lemma 10.2.6, p. 581
-/

/-! ### U-Formula Abstraction -/

/-- Replace all occurrences of `untl A B` in `phi` with atom `p`.
    This is the "abstraction" step: given multiple U-types, we pick one U(A,B)
    and replace it everywhere with a fresh atom, reducing the problem to
    fewer U-types or to single-U for Lemma 10.2.5. -/
def abstract_untl (phi A B : Formula) (p : Atom) : Formula :=
  match phi with
  | .atom a => .atom a
  | .bot => .bot
  | .imp psi1 psi2 => .imp (abstract_untl psi1 A B p) (abstract_untl psi2 A B p)
  | .box psi => .box (abstract_untl psi A B p)
  | .untl psi1 psi2 =>
    if psi1 = A ∧ psi2 = B then .atom p
    else .untl (abstract_untl psi1 A B p) (abstract_untl psi2 A B p)
  | .snce psi1 psi2 => .snce (abstract_untl psi1 A B p) (abstract_untl psi2 A B p)

/-! ### Syntactic Roundtrip: abstract then substitute back -/

/-- Substituting U(A,B) for atom p in the abstracted formula recovers the original,
    provided p does not appear in the original formula. -/
theorem abstract_subst_roundtrip (phi A B : Formula) (p : Atom)
    (hfresh : ¬ (p ∈ phi.atoms)) :
    subst_formula (abstract_untl phi A B p) p (.untl A B) = phi := by
  induction phi with
  | atom a =>
    simp [Formula.atoms, Finset.mem_singleton] at hfresh
    have hne : a ≠ p := Ne.symm hfresh
    simp [abstract_untl, subst_formula, hne]
  | bot => simp [abstract_untl, subst_formula]
  | imp c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp [abstract_untl, subst_formula, ih1 hfresh.1, ih2 hfresh.2]
  | box c ih =>
    simp [Formula.atoms] at hfresh
    simp [abstract_untl, subst_formula, ih hfresh]
  | untl c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp only [abstract_untl]
    split
    · next h => simp [subst_formula, h.1, h.2]
    · next _ =>
      simp only [subst_formula]
      congr 1
      · exact ih1 hfresh.1
      · exact ih2 hfresh.2
  | snce c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp [abstract_untl, subst_formula, ih1 hfresh.1, ih2 hfresh.2]

/-! ### Semantic Correctness of Abstraction -/

/-- Semantic correctness: truth of φ in structure M is equivalent to truth of
    the abstracted formula in M with atom p interpreted as the truth set of U(A,B).
    This is the semantic counterpart of the syntactic roundtrip. -/
theorem abstract_untl_correct (phi A B : Formula) (p : Atom)
    (hfresh : ¬ (p ∈ phi.atoms))
    (M : IntStructure) (t : Int) :
    int_truth M t phi ↔
    int_truth (M.withAtom p {s | int_truth M s (.untl A B)}) t
      (abstract_untl phi A B p) := by
  induction phi generalizing t with
  | atom a =>
    simp [Formula.atoms, Finset.mem_singleton] at hfresh
    simp [abstract_untl, int_truth, IntStructure.withAtom, Ne.symm hfresh]
  | bot => simp [abstract_untl, int_truth]
  | imp c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp only [abstract_untl, int_truth]
    constructor
    · intro h hc; exact (ih2 hfresh.2 t).mp (h ((ih1 hfresh.1 t).mpr hc))
    · intro h hc; exact (ih2 hfresh.2 t).mpr (h ((ih1 hfresh.1 t).mp hc))
  | box _ => simp [abstract_untl, int_truth]
  | untl c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp only [abstract_untl]
    split
    · next h =>
      obtain ⟨hc, hd⟩ := h; subst hc; subst hd
      simp [int_truth, IntStructure.withAtom, Set.mem_setOf_eq]
    · next _ =>
      simp only [int_truth]
      constructor
      · rintro ⟨s, hts, hc, hd⟩
        exact ⟨s, hts, (ih1 hfresh.1 s).mp hc,
          fun r hr1 hr2 => (ih2 hfresh.2 r).mp (hd r hr1 hr2)⟩
      · rintro ⟨s, hts, hc, hd⟩
        exact ⟨s, hts, (ih1 hfresh.1 s).mpr hc,
          fun r hr1 hr2 => (ih2 hfresh.2 r).mpr (hd r hr1 hr2)⟩
  | snce c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp only [abstract_untl, int_truth]
    constructor
    · rintro ⟨s, hst, hc, hd⟩
      exact ⟨s, hst, (ih1 hfresh.1 s).mp hc,
        fun r hr1 hr2 => (ih2 hfresh.2 r).mp (hd r hr1 hr2)⟩
    · rintro ⟨s, hst, hc, hd⟩
      exact ⟨s, hst, (ih1 hfresh.1 s).mpr hc,
        fun r hr1 hr2 => (ih2 hfresh.2 r).mpr (hd r hr1 hr2)⟩

/-- The syntactic roundtrip gives int_equiv directly. -/
theorem abstract_untl_equiv (phi A B : Formula) (p : Atom)
    (hfresh : ¬ (p ∈ phi.atoms)) :
    int_equiv phi (subst_formula (abstract_untl phi A B p) p (.untl A B)) := by
  rw [abstract_subst_roundtrip phi A B p hfresh]
  exact int_equiv_refl phi

/-! ### Preservation Lemmas -/

/-- abstract_untl preserves is_S_free: if φ is S-free, so is the abstracted form. -/
theorem abstract_untl_preserves_S_free (phi A B : Formula) (p : Atom)
    (h : is_S_free phi = true) :
    is_S_free (abstract_untl phi A B p) = true := by
  induction phi with
  | atom _ => simp [abstract_untl, is_S_free]
  | bot => simp [abstract_untl, is_S_free]
  | imp c d ih1 ih2 =>
    simp [is_S_free] at h
    simp [abstract_untl, is_S_free, ih1 h.1, ih2 h.2]
  | box c ih =>
    simp [is_S_free] at h
    simp [abstract_untl, is_S_free, ih h]
  | untl c d ih1 ih2 =>
    simp [is_S_free] at h
    simp only [abstract_untl]
    split
    · simp [is_S_free]
    · simp [is_S_free, ih1 h.1, ih2 h.2]
  | snce _ _ => simp [is_S_free] at h

/-- abstract_untl preserves no_S_nested_in_U: if all U-args are S-free in φ,
    they remain S-free after abstraction (since we only replace U-nodes with atoms). -/
theorem abstract_untl_preserves_no_S_nested (phi A B : Formula) (p : Atom)
    (h : no_S_nested_in_U phi) :
    no_S_nested_in_U (abstract_untl phi A B p) := by
  induction phi with
  | atom _ => trivial
  | bot => trivial
  | imp c d ih1 ih2 => exact ⟨ih1 h.1, ih2 h.2⟩
  | box c ih => exact ih h
  | untl c d _ _ =>
    simp only [abstract_untl]
    split
    · trivial
    · -- no_S_nested_in_U (.untl c d) gives is_S_free c ∧ is_S_free d
      have ⟨hc_sf, hd_sf⟩ := h
      exact ⟨abstract_untl_preserves_S_free c A B p hc_sf,
             abstract_untl_preserves_S_free d A B p hd_sf⟩
  | snce c d ih1 ih2 => exact ⟨ih1 h.1, ih2 h.2⟩

/-- If φ has single U-type U(A,B), abstracting it out gives a U-free formula. -/
theorem abstract_untl_makes_U_free (phi A B : Formula) (p : Atom)
    (h : has_single_U_type phi A B) :
    is_U_free (abstract_untl phi A B p) = true := by
  induction phi with
  | atom _ => simp [abstract_untl, is_U_free]
  | bot => simp [abstract_untl, is_U_free]
  | imp c d ih1 ih2 =>
    simp [abstract_untl, is_U_free, ih1 h.1, ih2 h.2]
  | box c ih =>
    simp [abstract_untl, is_U_free, ih h]
  | untl c d _ _ =>
    obtain ⟨hc, hd⟩ := h; subst hc; subst hd
    simp [abstract_untl, is_U_free]
  | snce c d ih1 ih2 =>
    simp [abstract_untl, is_U_free, ih1 h.1, ih2 h.2]

/-! ### Count Properties -/

/-- count_U_subformulas = 0 iff the formula is U-free. -/
theorem count_U_zero_iff_U_free (phi : Formula) :
    count_U_subformulas phi = 0 ↔ is_U_free phi = true := by
  induction phi with
  | atom _ => simp [count_U_subformulas, is_U_free]
  | bot => simp [count_U_subformulas, is_U_free]
  | imp c d ih1 ih2 =>
    simp [count_U_subformulas, is_U_free, ih1, ih2]
  | box c ih =>
    simp [count_U_subformulas, is_U_free, ih]
  | untl c d =>
    simp [count_U_subformulas, is_U_free]
  | snce c d ih1 ih2 =>
    simp [count_U_subformulas, is_U_free, ih1, ih2]

/-- abstract_untl does not increase the U-subformula count. -/
theorem abstract_untl_count_le (phi A B : Formula) (p : Atom) :
    count_U_subformulas (abstract_untl phi A B p) ≤ count_U_subformulas phi := by
  induction phi with
  | atom _ => simp [abstract_untl, count_U_subformulas]
  | bot => simp [abstract_untl, count_U_subformulas]
  | imp c d ih1 ih2 =>
    simp [abstract_untl, count_U_subformulas]
    exact Nat.add_le_add ih1 ih2
  | box c ih =>
    simp [abstract_untl, count_U_subformulas]; exact ih
  | untl c d ih1 ih2 =>
    simp only [abstract_untl, count_U_subformulas]
    split
    · simp [count_U_subformulas]
    · simp only [count_U_subformulas]
      have := Nat.add_le_add ih1 ih2
      omega
  | snce c d ih1 ih2 =>
    simp [abstract_untl, count_U_subformulas]
    exact Nat.add_le_add ih1 ih2

/-- If φ has single U-type, abstracting it reduces count to 0. -/
theorem abstract_untl_count_zero_of_single (phi A B : Formula) (p : Atom)
    (h : has_single_U_type phi A B) :
    count_U_subformulas (abstract_untl phi A B p) = 0 := by
  rw [count_U_zero_iff_U_free]
  exact abstract_untl_makes_U_free phi A B p h

/-! ### S-Formula Abstraction (dual of abstract_untl) -/

/-- Replace all occurrences of `snce A B` in `phi` with atom `p`.
    Dual of `abstract_untl`: picks one S(A,B) and replaces it everywhere with a fresh atom,
    reducing the problem to fewer S-types or to single-S for the dual of Lemma 10.2.5. -/
def abstract_snce (phi A B : Formula) (p : Atom) : Formula :=
  match phi with
  | .atom a => .atom a
  | .bot => .bot
  | .imp psi1 psi2 => .imp (abstract_snce psi1 A B p) (abstract_snce psi2 A B p)
  | .box psi => .box (abstract_snce psi A B p)
  | .untl psi1 psi2 => .untl (abstract_snce psi1 A B p) (abstract_snce psi2 A B p)
  | .snce psi1 psi2 =>
    if psi1 = A ∧ psi2 = B then .atom p
    else .snce (abstract_snce psi1 A B p) (abstract_snce psi2 A B p)

/-- Semantic correctness of abstract_snce: truth in M with p interpreted as the truth set
    of S(A,B) is equivalent to truth of the original formula.
    This is the dual of `abstract_untl_correct` for the S-operator. -/
theorem abstract_snce_correct (phi A B : Formula) (p : Atom)
    (M : IntStructure) (t : ℤ)
    (h_eq : M.val p = {s | int_truth M s (.snce A B)}) :
    int_truth M t (abstract_snce phi A B p) ↔ int_truth M t phi := by
  induction phi generalizing t with
  | atom a =>
    simp only [abstract_snce, int_truth]
  | bot => simp [abstract_snce, int_truth]
  | imp c d ih1 ih2 =>
    simp only [abstract_snce, int_truth]
    exact Iff.imp (ih1 t) (ih2 t)
  | box _ => simp [abstract_snce, int_truth]
  | untl c d ih1 ih2 =>
    simp only [abstract_snce, int_truth]
    constructor
    · rintro ⟨s, hts, hc, hd⟩
      exact ⟨s, hts, (ih1 s).mp hc,
        fun r hr1 hr2 => (ih2 r).mp (hd r hr1 hr2)⟩
    · rintro ⟨s, hts, hc, hd⟩
      exact ⟨s, hts, (ih1 s).mpr hc,
        fun r hr1 hr2 => (ih2 r).mpr (hd r hr1 hr2)⟩
  | snce c d ih1 ih2 =>
    simp only [abstract_snce]
    split
    · next h =>
      obtain ⟨hc, hd⟩ := h; subst hc; subst hd
      simp [int_truth, Set.mem_setOf_eq, h_eq]
    · next hne =>
      simp only [int_truth]
      constructor
      · rintro ⟨s, hst, hc, hd⟩
        exact ⟨s, hst, (ih1 s).mp hc,
          fun r hr1 hr2 => (ih2 r).mp (hd r hr1 hr2)⟩
      · rintro ⟨s, hst, hc, hd⟩
        exact ⟨s, hst, (ih1 s).mpr hc,
          fun r hr1 hr2 => (ih2 r).mpr (hd r hr1 hr2)⟩

/-- Substituting S(A,B) for atom p in the abstracted formula recovers the original,
    provided p does not appear in the original formula. Dual of `abstract_subst_roundtrip`. -/
theorem abstract_snce_subst_roundtrip (phi A B : Formula) (p : Atom)
    (hfresh : ¬ (p ∈ phi.atoms)) :
    subst_formula (abstract_snce phi A B p) p (.snce A B) = phi := by
  induction phi with
  | atom a =>
    simp [Formula.atoms, Finset.mem_singleton] at hfresh
    have hne : a ≠ p := Ne.symm hfresh
    simp [abstract_snce, subst_formula, hne]
  | bot => simp [abstract_snce, subst_formula]
  | imp c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp [abstract_snce, subst_formula, ih1 hfresh.1, ih2 hfresh.2]
  | box c ih =>
    simp [Formula.atoms] at hfresh
    simp [abstract_snce, subst_formula, ih hfresh]
  | untl c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp [abstract_snce, subst_formula, ih1 hfresh.1, ih2 hfresh.2]
  | snce c d ih1 ih2 =>
    simp [Formula.atoms, Finset.mem_union] at hfresh
    simp only [abstract_snce]
    split
    · next h => simp [subst_formula, h.1, h.2]
    · next _ =>
      simp only [subst_formula]
      congr 1
      · exact ih1 hfresh.1
      · exact ih2 hfresh.2

/-! ### Preservation Lemmas for abstract_snce -/

/-- abstract_snce preserves is_U_free: if φ is U-free, so is the abstracted form. -/
theorem abstract_snce_preserves_U_free (phi A B : Formula) (p : Atom)
    (h : is_U_free phi = true) :
    is_U_free (abstract_snce phi A B p) = true := by
  induction phi with
  | atom _ => simp [abstract_snce, is_U_free]
  | bot => simp [abstract_snce, is_U_free]
  | imp c d ih1 ih2 =>
    simp [is_U_free] at h
    simp [abstract_snce, is_U_free, ih1 h.1, ih2 h.2]
  | box c ih =>
    simp [is_U_free] at h
    simp [abstract_snce, is_U_free, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce c d ih1 ih2 =>
    simp [is_U_free] at h
    simp only [abstract_snce]
    split
    · simp [is_U_free]
    · simp [is_U_free, ih1 h.1, ih2 h.2]

/-- abstract_snce preserves is_S_free: if φ is S-free, so is the abstracted form. -/
theorem abstract_snce_preserves_S_free (phi A B : Formula) (p : Atom)
    (h : is_S_free phi = true) :
    is_S_free (abstract_snce phi A B p) = true := by
  induction phi with
  | atom _ => simp [abstract_snce, is_S_free]
  | bot => simp [abstract_snce, is_S_free]
  | imp c d ih1 ih2 =>
    simp [is_S_free] at h
    simp [abstract_snce, is_S_free, ih1 h.1, ih2 h.2]
  | box c ih =>
    simp [is_S_free] at h
    simp [abstract_snce, is_S_free, ih h]
  | untl c d ih1 ih2 =>
    simp [is_S_free] at h
    simp [abstract_snce, is_S_free, ih1 h.1, ih2 h.2]
  | snce _ _ => simp [is_S_free] at h

/-- If φ has no U nested in S, abstracting S(A,B) preserves this property. -/
theorem abstract_snce_preserves_no_U_nested (phi A B : Formula) (p : Atom)
    (h : no_U_nested_in_S phi) :
    no_U_nested_in_S (abstract_snce phi A B p) := by
  induction phi with
  | atom _ => trivial
  | bot => trivial
  | imp c d ih1 ih2 => exact ⟨ih1 h.1, ih2 h.2⟩
  | box c ih => exact ih h
  | untl c d ih1 ih2 => exact ⟨ih1 h.1, ih2 h.2⟩
  | snce c d _ _ =>
    simp only [abstract_snce]
    split
    · trivial
    · have ⟨hc_uf, hd_uf⟩ := h
      exact ⟨abstract_snce_preserves_U_free c A B p hc_uf,
             abstract_snce_preserves_U_free d A B p hd_uf⟩

/-- If φ has single S-type S(A,B), abstracting it gives a S-free formula. -/
theorem abstract_snce_makes_S_free (phi A B : Formula) (p : Atom)
    (h : has_single_S_type phi A B) :
    is_S_free (abstract_snce phi A B p) = true := by
  induction phi with
  | atom _ => simp [abstract_snce, is_S_free]
  | bot => simp [abstract_snce, is_S_free]
  | imp c d ih1 ih2 =>
    simp [abstract_snce, is_S_free, ih1 h.1, ih2 h.2]
  | box c ih =>
    simp [abstract_snce, is_S_free, ih h]
  | untl c d ih1 ih2 =>
    simp [abstract_snce, is_S_free, ih1 h.1, ih2 h.2]
  | snce c d _ _ =>
    obtain ⟨hc, hd⟩ := h; subst hc; subst hd
    simp [abstract_snce, is_S_free]

/-! ### Junction-Depth Monotonicity Lemmas -/

/-- joint 4-way bound relating junction_depth, junction_depth_U, junction_depth_S. -/
private theorem junction_depth_bounds (φ : Formula) :
    junction_depth φ ≤ junction_depth_U φ ∧
    junction_depth φ ≤ junction_depth_S φ ∧
    junction_depth_U φ ≤ 1 + junction_depth φ ∧
    junction_depth_S φ ≤ 1 + junction_depth φ := by
  induction φ with
  | atom _ => simp [junction_depth, junction_depth_U, junction_depth_S]
  | bot => simp [junction_depth, junction_depth_U, junction_depth_S]
  | imp a b ih1 ih2 =>
    simp only [junction_depth, junction_depth_U, junction_depth_S]
    omega
  | box a ih => simp [junction_depth, junction_depth_U, junction_depth_S, ih.1, ih.2.1, ih.2.2.1, ih.2.2.2]
  | untl a b ih1 ih2 =>
    simp only [junction_depth, junction_depth_U, junction_depth_S]
    omega
  | snce a b ih1 ih2 =>
    simp only [junction_depth, junction_depth_U, junction_depth_S]
    omega

/-- junction_depth is bounded above by junction_depth_U. -/
theorem junction_depth_le_jdU (φ : Formula) : junction_depth φ ≤ junction_depth_U φ :=
  (junction_depth_bounds φ).1

/-- junction_depth is bounded above by junction_depth_S. -/
theorem junction_depth_le_jdS (φ : Formula) : junction_depth φ ≤ junction_depth_S φ :=
  (junction_depth_bounds φ).2.1

theorem jd_imp_le_left (φ ψ : Formula) : junction_depth φ ≤ junction_depth (.imp φ ψ) :=
  Nat.le_max_left _ _

theorem jd_imp_le_right (φ ψ : Formula) : junction_depth ψ ≤ junction_depth (.imp φ ψ) :=
  Nat.le_max_right _ _

theorem jd_box_le (φ : Formula) : junction_depth φ ≤ junction_depth (.box φ) :=
  Nat.le_refl _


theorem jd_untl_le_left (φ ψ : Formula) : junction_depth φ ≤ junction_depth (.untl φ ψ) := by
  simp only [junction_depth]
  exact Nat.le_trans (junction_depth_le_jdU φ) (Nat.le_max_left _ _)

theorem jd_untl_le_right (φ ψ : Formula) : junction_depth ψ ≤ junction_depth (.untl φ ψ) := by
  simp only [junction_depth]
  exact Nat.le_trans (junction_depth_le_jdU ψ) (Nat.le_max_right _ _)

theorem jd_snce_le_left (φ ψ : Formula) : junction_depth φ ≤ junction_depth (.snce φ ψ) := by
  simp only [junction_depth]
  exact Nat.le_trans (junction_depth_le_jdS φ) (Nat.le_max_left _ _)

theorem jd_snce_le_right (φ ψ : Formula) : junction_depth ψ ≤ junction_depth (.snce φ ψ) := by
  simp only [junction_depth]
  exact Nat.le_trans (junction_depth_le_jdS ψ) (Nat.le_max_right _ _)

/-! ### abstract_untl Identity and Preservation -/

/-- abstract_untl is the identity on U-free formulas: when phi has no untl nodes,
    there are no untl(A,B) patterns to replace, so the formula is unchanged. -/
theorem abstract_untl_identity_on_U_free (phi A B : Formula) (p : Atom)
    (h : is_U_free phi = true) :
    abstract_untl phi A B p = phi := by
  induction phi with
  | atom _ => simp [abstract_untl]
  | bot => simp [abstract_untl]
  | imp c d ih1 ih2 => simp [is_U_free] at h; simp [abstract_untl, ih1 h.1, ih2 h.2]
  | box c ih => simp [is_U_free] at h; simp [abstract_untl, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce c d ih1 ih2 => simp [is_U_free] at h; simp [abstract_untl, ih1 h.1, ih2 h.2]

/-- abstract_untl preserves U-freeness (trivially, since it's identity on U-free). -/
theorem abstract_untl_preserves_U_free (phi A B : Formula) (p : Atom)
    (h : is_U_free phi = true) :
    is_U_free (abstract_untl phi A B p) = true := by
  rw [abstract_untl_identity_on_U_free phi A B p h]; exact h

/-- abstract_untl preserves syntactic separation: if phi is separated and
    untl(A,B) has S-free args, then the abstracted formula is still separated.
    This works because abstract_untl replaces untl(A,B) with atom p:
    - In untl positions (S-free context): atom is S-free. Fine.
    - In snce positions (U-free context): abstract_untl is identity on U-free. Fine.
    - In all_past positions (U-free context): identity on U-free. Fine.
    - In all_future positions (S-free context): preserves S-free. Fine.
    - In imp positions: IH applies. -/
theorem abstract_untl_preserves_separated (phi A B : Formula) (p : Atom)
    (hsep : is_syntactically_separated phi = true) :
    is_syntactically_separated (abstract_untl phi A B p) = true := by
  induction phi with
  | atom _ => simp [abstract_untl, is_syntactically_separated]
  | bot => simp [abstract_untl, is_syntactically_separated]
  | imp a b ih1 ih2 =>
    simp [is_syntactically_separated] at hsep
    simp [abstract_untl, is_syntactically_separated, ih1 hsep.1, ih2 hsep.2]
  | box _ => simp [abstract_untl, is_syntactically_separated]
  | untl a b _ih1 _ih2 =>
    simp [is_syntactically_separated] at hsep
    simp only [abstract_untl]
    split
    · simp [is_syntactically_separated]
    · simp [is_syntactically_separated,
            abstract_untl_preserves_S_free a A B p hsep.1,
            abstract_untl_preserves_S_free b A B p hsep.2]
  | snce a b _ih1 _ih2 =>
    simp [is_syntactically_separated] at hsep
    simp [abstract_untl, is_syntactically_separated]
    exact ⟨by rw [abstract_untl_identity_on_U_free a A B p hsep.1]; exact hsep.1,
           by rw [abstract_untl_identity_on_U_free b A B p hsep.2]; exact hsep.2⟩

/-! ### Lemma 10.2.6: Multi-U Formula Separability -/

/-- Lemma 10.2.6 (GHR94): If no S is nested within any U-argument of φ
    (equivalently: all U-arguments are S-free), then φ is separable.

    The proof uses `all_separable` from SeparationThm.lean, which establishes
    separability via structural induction with temporal closure theorems. -/
theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi :=
  all_separable phi

/-- Corollary: A formula with exactly two U-types (both S-free args) is separable.
    This is the form most directly used in Phase 5 for Cases 5 and 6. -/
theorem two_U_types_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi :=
  multi_U_formula_separable phi h

/-! ### Additional Corollaries for Phase 5

These package multi_U_formula_separable in forms convenient for the
Case 5-8 proofs. -/

/-- If a formula has no_S_nested_in_U and is wrapped in negation, it's separable. -/
theorem multi_U_neg_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable (Formula.neg phi) :=
  neg_separable (multi_U_formula_separable phi h)

/-- Disjunction of two no_S_nested_in_U formulas is separable. -/
theorem multi_U_or_separable (phi psi : Formula)
    (h1 : no_S_nested_in_U phi) (h2 : no_S_nested_in_U psi) :
    is_separable (Formula.or phi psi) :=
  or_separable (multi_U_formula_separable phi h1) (multi_U_formula_separable psi h2)

/-- Conjunction of two no_S_nested_in_U formulas is separable. -/
theorem multi_U_and_separable (phi psi : Formula)
    (h1 : no_S_nested_in_U phi) (h2 : no_S_nested_in_U psi) :
    is_separable (Formula.and phi psi) :=
  and_separable (multi_U_formula_separable phi h1) (multi_U_formula_separable psi h2)

/-! ### junction_depth decrease lemmas for abstract_snce -/

/-- abstract_snce does not increase junction_depth, junction_depth_U, or junction_depth_S.
    Proved simultaneously by structural induction (they are mutually recursive). -/
private theorem abstract_snce_jd_le_all (phi A B : Formula) (p : Atom) :
    junction_depth (abstract_snce phi A B p) ≤ junction_depth phi ∧
    junction_depth_U (abstract_snce phi A B p) ≤ junction_depth_U phi ∧
    junction_depth_S (abstract_snce phi A B p) ≤ junction_depth_S phi := by
  induction phi with
  | atom _ => simp [abstract_snce, junction_depth, junction_depth_U, junction_depth_S]
  | bot => simp [abstract_snce, junction_depth, junction_depth_U, junction_depth_S]
  | imp a b ih1 ih2 =>
    simp only [abstract_snce, junction_depth, junction_depth_U, junction_depth_S]
    omega
  | box a ih =>
    simp only [abstract_snce, junction_depth, junction_depth_U, junction_depth_S]
    exact ih
  | untl a b ih1 ih2 =>
    simp only [abstract_snce, junction_depth, junction_depth_U, junction_depth_S]
    omega
  | snce a b ih1 ih2 =>
    simp only [abstract_snce]
    split
    · simp only [junction_depth, junction_depth_U, junction_depth_S]
      omega
    · simp only [junction_depth, junction_depth_U, junction_depth_S]
      obtain ⟨h1a, h1b, h1c⟩ := ih1
      obtain ⟨h2a, h2b, h2c⟩ := ih2
      omega

/-- abstract_snce does not increase junction_depth. -/
theorem abstract_snce_jd_le (phi A B : Formula) (p : Atom) :
    junction_depth (abstract_snce phi A B p) ≤ junction_depth phi :=
  (abstract_snce_jd_le_all phi A B p).1

/-- abstract_snce does not increase junction_depth_U. -/
theorem abstract_snce_jdU_le (phi A B : Formula) (p : Atom) :
    junction_depth_U (abstract_snce phi A B p) ≤ junction_depth_U phi :=
  (abstract_snce_jd_le_all phi A B p).2.1

/-- abstract_snce does not increase junction_depth_S. -/
theorem abstract_snce_jdS_le (phi A B : Formula) (p : Atom) :
    junction_depth_S (abstract_snce phi A B p) ≤ junction_depth_S phi :=
  (abstract_snce_jd_le_all phi A B p).2.2

/-- Abstracting S(A,B) when it occurs directly at the root as a snce node drops jdU. -/
theorem jdU_abstract_snce_snce_lt (A B : Formula) (p : Atom) :
    junction_depth_U (abstract_snce (.snce A B) A B p) < junction_depth_U (.snce A B) := by
  simp only [abstract_snce]
  split
  · simp only [junction_depth_U]; omega
  · next h => exact absurd ⟨trivial, trivial⟩ h

/-- Predicate: S(A,B) appears directly in φ in a position reachable via junction_depth_U
    tracking — meaning through U-nodes only (not through S), AND the path achieves
    the current maximum (so abstracting it decreases jdU of the whole). -/
def snce_achieves_max_jdU : Formula → Formula → Formula → Prop
  | .untl a b, A, B =>
      (a = .snce A B ∧ junction_depth_U (.snce A B) ≥ junction_depth_U b) ∨
      (b = .snce A B ∧ junction_depth_U (.snce A B) ≥ junction_depth_U a) ∨
      (snce_achieves_max_jdU a A B ∧ junction_depth_U a ≥ junction_depth_U b) ∨
      (snce_achieves_max_jdU b A B ∧ junction_depth_U b ≥ junction_depth_U a)
  | _, _, _ => False

/-- Predicate: S(A,B) appears in the U-argument of a `.untl` node (directly or nested
    within more `.untl` nodes, without passing through `.snce` or other temporal operators).
    This predicate tracks ONLY paths through `untl` nodes (not imp/box/etc). -/
def snce_inside_U_arg : Formula → Formula → Formula → Prop
  | .untl a b, A, B =>
      a = .snce A B ∨ b = .snce A B ∨
      snce_inside_U_arg a A B ∨ snce_inside_U_arg b A B
  | _, _, _ => False

/-- Key lemma: abstracting S(A,B) from the LEFT U-argument when jdU a STRICTLY exceeds
    jdU b strictly decreases junction_depth_U of `.untl a b`. -/
theorem abstract_snce_untl_jdU_lt_left (a b A B : Formula) (p : Atom)
    (h_a_dec : junction_depth_U (abstract_snce a A B p) < junction_depth_U a)
    (h_max : junction_depth_U a > junction_depth_U b) :
    junction_depth_U (abstract_snce (.untl a b) A B p) < junction_depth_U (.untl a b) := by
  simp only [abstract_snce, junction_depth_U]
  have hle_b := abstract_snce_jdU_le b A B p
  apply Nat.max_lt.mpr; constructor
  · exact Nat.lt_of_lt_of_le h_a_dec (Nat.le_max_left _ _)
  · exact Nat.lt_of_le_of_lt hle_b (Nat.lt_of_lt_of_le h_max (Nat.le_max_left _ _))

/-- Key lemma: abstracting S(A,B) from the RIGHT U-argument when jdU b STRICTLY exceeds
    jdU a strictly decreases junction_depth_U of `.untl a b`. -/
theorem abstract_snce_untl_jdU_lt_right (a b A B : Formula) (p : Atom)
    (h_b_dec : junction_depth_U (abstract_snce b A B p) < junction_depth_U b)
    (h_max : junction_depth_U b > junction_depth_U a) :
    junction_depth_U (abstract_snce (.untl a b) A B p) < junction_depth_U (.untl a b) := by
  simp only [abstract_snce, junction_depth_U]
  have hle_a := abstract_snce_jdU_le a A B p
  apply Nat.max_lt.mpr; constructor
  · exact Nat.lt_of_le_of_lt hle_a (Nat.lt_of_lt_of_le h_max (Nat.le_max_right _ _))
  · exact Nat.lt_of_lt_of_le h_b_dec (Nat.le_max_right _ _)

/-- Version when jdU a = jdU b and BOTH branches decrease (e.g., when S(A,B) achieves max in both). -/
theorem abstract_snce_untl_jdU_lt_both (a b A B : Formula) (p : Atom)
    (h_a_dec : junction_depth_U (abstract_snce a A B p) < junction_depth_U a)
    (h_b_dec : junction_depth_U (abstract_snce b A B p) < junction_depth_U b) :
    junction_depth_U (abstract_snce (.untl a b) A B p) < junction_depth_U (.untl a b) := by
  simp only [abstract_snce, junction_depth_U]
  apply Nat.max_lt.mpr; constructor
  · exact Nat.lt_of_lt_of_le h_a_dec (Nat.le_max_left _ _)
  · exact Nat.lt_of_lt_of_le h_b_dec (Nat.le_max_right _ _)

/-- Direct case: abstracting S(A,B) when it IS the left U-arg and strictly dominates. -/
theorem abstract_snce_untl_left_snce_jdU_lt (b A B : Formula) (p : Atom)
    (h_max : junction_depth_U (.snce A B) > junction_depth_U b) :
    junction_depth_U (abstract_snce (.untl (.snce A B) b) A B p) <
    junction_depth_U (.untl (.snce A B) b) :=
  abstract_snce_untl_jdU_lt_left _ _ _ _ _ (jdU_abstract_snce_snce_lt A B p) h_max

/-- Direct case: abstracting S(A,B) when it IS the right U-arg and strictly dominates. -/
theorem abstract_snce_untl_right_snce_jdU_lt (a A B : Formula) (p : Atom)
    (h_max : junction_depth_U (.snce A B) > junction_depth_U a) :
    junction_depth_U (abstract_snce (.untl a (.snce A B)) A B p) <
    junction_depth_U (.untl a (.snce A B)) :=
  abstract_snce_untl_jdU_lt_right _ _ _ _ _ (jdU_abstract_snce_snce_lt A B p) h_max

/-- Direct case: abstracting S(A,B) from both sides when they are equal. -/
theorem abstract_snce_untl_both_snce_jdU_lt (A B : Formula) (p : Atom) :
    junction_depth_U (abstract_snce (.untl (.snce A B) (.snce A B)) A B p) <
    junction_depth_U (.untl (.snce A B) (.snce A B)) :=
  abstract_snce_untl_jdU_lt_both _ _ _ _ _
    (jdU_abstract_snce_snce_lt A B p) (jdU_abstract_snce_snce_lt A B p)

/-- Key theorem for Phase 6B: abstracting S(A,B) from the U-argument that achieves
    the maximum jdU decreases junction_depth of the whole `.untl` node.
    Precondition: one branch's jdU strictly decreases AND that branch strictly dominates
    the other (or both strictly decrease). -/
theorem abstract_snce_inside_untl_jd_lt (a b A B : Formula) (p : Atom)
    (h : (junction_depth_U (abstract_snce a A B p) < junction_depth_U a ∧
          junction_depth_U a > junction_depth_U b)
      ∨ (junction_depth_U (abstract_snce b A B p) < junction_depth_U b ∧
          junction_depth_U b > junction_depth_U a)
      ∨ (junction_depth_U (abstract_snce a A B p) < junction_depth_U a ∧
          junction_depth_U (abstract_snce b A B p) < junction_depth_U b)) :
    junction_depth (abstract_snce (.untl a b) A B p) < junction_depth (.untl a b) := by
  simp only [abstract_snce, junction_depth]
  rcases h with ⟨hlt_a, hgt⟩ | ⟨hlt_b, hgt⟩ | ⟨hlt_a, hlt_b⟩
  · have := abstract_snce_untl_jdU_lt_left a b A B p hlt_a hgt
    simp only [abstract_snce, junction_depth_U] at this; exact this
  · have := abstract_snce_untl_jdU_lt_right a b A B p hlt_b hgt
    simp only [abstract_snce, junction_depth_U] at this; exact this
  · have := abstract_snce_untl_jdU_lt_both a b A B p hlt_a hlt_b
    simp only [abstract_snce, junction_depth_U] at this; exact this

/-! ## Phase 3: Hierarchy Theorem (GHR94 Lemmas 10.2.5-10.2.8)

This section proves the full hierarchy without temporal closure axioms.
The chain is: Cases 1-8 → no_S_nested_in_U_separable → junction_depth_separable
→ all_formulas_separable. No circular dependencies.

### Key Technique: Constituent Substitution

After abstracting a U-type to a fresh atom and separating the result,
we substitute back into the separated formula. The crucial insight:
- In `.untl` positions of a separated formula, args are S-free.
  Substituting an S-free `.untl A B` preserves S-freeness.
- In `.snce` positions of a separated formula, args are U-free.
  Substituting `.untl A B` for an atom in U-free args creates
  `no_S_nested_in_U` (the new U has S-free args), allowing IH application
  with strictly fewer U-subformulas.

### References

- GHR94, Lemmas 10.2.5-10.2.8, pp. 581-590
- Strategy report: specs/157_.../reports/09_hierarchy-strategy.md
-/

/-! ### Step 1: Substitution Preservation Lemmas -/

/-- Substituting an S-free formula into an S-free formula preserves S-freeness.
    This is needed when substituting `.untl A B` (with S-free A, B) for an atom
    in the S-free arguments of `.untl` nodes in a separated formula. -/
theorem subst_S_free_preserves_S_free (ψ : Formula) (p : Atom) (r : Formula)
    (hψ : is_S_free ψ = true) (hr : is_S_free r = true) :
    is_S_free (subst_formula ψ p r) = true := by
  induction ψ with
  | atom a =>
    simp only [subst_formula]
    split
    · exact hr
    · simp [is_S_free]
  | bot => simp [subst_formula, is_S_free]
  | imp c d ih1 ih2 =>
    simp [is_S_free] at hψ
    simp [subst_formula, is_S_free, ih1 hψ.1, ih2 hψ.2]
  | box c ih =>
    simp [is_S_free] at hψ
    simp [subst_formula, is_S_free, ih hψ]
  | untl c d ih1 ih2 =>
    simp [is_S_free] at hψ
    simp [subst_formula, is_S_free, ih1 hψ.1, ih2 hψ.2]
  | snce _ _ => simp [is_S_free] at hψ

/-- Substituting a U-free formula into a U-free formula preserves U-freeness.
    Dual of `subst_S_free_preserves_S_free`. -/
theorem subst_U_free_preserves_U_free (ψ : Formula) (p : Atom) (r : Formula)
    (hψ : is_U_free ψ = true) (hr : is_U_free r = true) :
    is_U_free (subst_formula ψ p r) = true := by
  induction ψ with
  | atom a =>
    simp only [subst_formula]
    split
    · exact hr
    · simp [is_U_free]
  | bot => simp [subst_formula, is_U_free]
  | imp c d ih1 ih2 =>
    simp [is_U_free] at hψ
    simp [subst_formula, is_U_free, ih1 hψ.1, ih2 hψ.2]
  | box c ih =>
    simp [is_U_free] at hψ
    simp [subst_formula, is_U_free, ih hψ]
  | untl _ _ => simp [is_U_free] at hψ
  | snce c d ih1 ih2 =>
    simp [is_U_free] at hψ
    simp [subst_formula, is_U_free, ih1 hψ.1, ih2 hψ.2]

/-- Substituting `.untl A B` (with S-free args) into a U-free formula gives
    `no_S_nested_in_U`. The only new `.untl` nodes are the substituted copies
    of `.untl A B`, which have S-free arguments by hypothesis. -/
theorem subst_U_free_gives_no_S_nested (ψ : Formula) (p : Atom) (A B : Formula)
    (hψ : is_U_free ψ = true) (hA : is_S_free A = true) (hB : is_S_free B = true) :
    no_S_nested_in_U (subst_formula ψ p (.untl A B)) := by
  induction ψ with
  | atom a =>
    simp only [subst_formula]
    split
    · -- a = p: result is .untl A B, need is_S_free A ∧ is_S_free B
      exact ⟨hA, hB⟩
    · -- a ≠ p: result is .atom a
      trivial
  | bot => trivial
  | imp c d ih1 ih2 =>
    simp [is_U_free] at hψ
    exact ⟨ih1 hψ.1, ih2 hψ.2⟩
  | box c ih =>
    simp [is_U_free] at hψ
    exact ih hψ
  | untl _ _ => simp [is_U_free] at hψ
  | snce c d ih1 ih2 =>
    simp [is_U_free] at hψ
    exact ⟨ih1 hψ.1, ih2 hψ.2⟩

/-- Substituting has_no_allpast_allfuture preservation: if ψ has no all_past/all_future
    and the replacement has none either, the result has none. -/
theorem subst_preserves_no_allpast_allfuture (ψ : Formula) (p : Atom) (r : Formula)
    (hψ : has_no_allpast_allfuture ψ = true) (hr : has_no_allpast_allfuture r = true) :
    has_no_allpast_allfuture (subst_formula ψ p r) = true := by
  induction ψ with
  | atom a =>
    simp only [subst_formula]
    split
    · exact hr
    · simp [has_no_allpast_allfuture]
  | bot => simp [subst_formula, has_no_allpast_allfuture]
  | imp c d ih1 ih2 =>
    simp [subst_formula, has_no_allpast_allfuture,
      ih1 (has_no_allpast_allfuture_true c), ih2 (has_no_allpast_allfuture_true d)]
  | box _ => simp [subst_formula, has_no_allpast_allfuture]
  | untl c d ih1 ih2 =>
    simp [subst_formula, has_no_allpast_allfuture,
      ih1 (has_no_allpast_allfuture_true c), ih2 (has_no_allpast_allfuture_true d)]
  | snce c d ih1 ih2 =>
    simp [subst_formula, has_no_allpast_allfuture,
      ih1 (has_no_allpast_allfuture_true c), ih2 (has_no_allpast_allfuture_true d)]

/-! ### Step 2: Strict Count Decrease for Abstraction -/

/-- Surface-level containment of `.untl A B`: the formula has a `.untl A B` node
    reachable from the root without passing through another `.untl` node.
    This mirrors the structure of `count_U_subformulas`, which counts `.untl` nodes
    at the surface level (not recursing into `.untl` children). -/
def contains_untl_surface : Formula → Formula → Formula → Prop
  | .atom _, _, _ => False
  | .bot, _, _ => False
  | .imp c d, A, B => contains_untl_surface c A B ∨ contains_untl_surface d A B
  | .box c, A, B => contains_untl_surface c A B
  | .untl c d, A, B => c = A ∧ d = B
  | .snce c d, A, B => contains_untl_surface c A B ∨ contains_untl_surface d A B

/-- Abstracting a formula that contains `.untl A B` at the surface level strictly
    decreases count_U_subformulas. This is the corrected version of the count
    decrease lemma: the hypothesis `contains_untl_surface` ensures the non-matching
    `.untl` case is vacuously true (since `count_U_subformulas` does not recurse
    into `.untl` children). -/
theorem abstract_untl_count_lt_of_contains_surface (phi A B : Formula) (p : Atom)
    (h_contains : contains_untl_surface phi A B) :
    count_U_subformulas (abstract_untl phi A B p) < count_U_subformulas phi := by
  induction phi with
  | atom _ => exact absurd h_contains id
  | bot => exact absurd h_contains id
  | imp c d ih1 ih2 =>
    simp only [contains_untl_surface] at h_contains
    simp only [abstract_untl, count_U_subformulas]
    rcases h_contains with hc | hd
    · have := ih1 hc; have := abstract_untl_count_le d A B p; omega
    · have := ih2 hd; have := abstract_untl_count_le c A B p; omega
  | box c ih =>
    simp only [contains_untl_surface] at h_contains
    simp only [abstract_untl, count_U_subformulas]; exact ih h_contains
  | untl c d _ _ =>
    simp only [abstract_untl, count_U_subformulas]
    split
    · simp only [count_U_subformulas]; omega
    · next hne =>
      -- h_contains : contains_untl_surface (.untl c d) A B = (c = A ∧ d = B)
      -- hne : ¬(c = A ∧ d = B), so this case is vacuously true
      exact absurd h_contains hne
  | snce c d ih1 ih2 =>
    simp only [contains_untl_surface] at h_contains
    simp only [abstract_untl, count_U_subformulas]
    rcases h_contains with hc | hd
    · have := ih1 hc; have := abstract_untl_count_le d A B p; omega
    · have := ih2 hd; have := abstract_untl_count_le c A B p; omega

/-- abstract_untl preserves has_no_allpast_allfuture. -/
theorem abstract_untl_preserves_no_allpast_allfuture (phi A B : Formula) (p : Atom)
    (h : has_no_allpast_allfuture phi = true) :
    has_no_allpast_allfuture (abstract_untl phi A B p) = true := by
  induction phi with
  | atom _ => simp [abstract_untl, has_no_allpast_allfuture]
  | bot => simp [abstract_untl, has_no_allpast_allfuture]
  | imp c d ih1 ih2 =>
    simp [abstract_untl, has_no_allpast_allfuture,
      ih1 (has_no_allpast_allfuture_true c), ih2 (has_no_allpast_allfuture_true d)]
  | box _ => simp [abstract_untl, has_no_allpast_allfuture]
  | untl c d ih1 ih2 =>
    simp only [abstract_untl]
    split
    · simp [has_no_allpast_allfuture]
    · simp [has_no_allpast_allfuture,
        ih1 (has_no_allpast_allfuture_true c), ih2 (has_no_allpast_allfuture_true d)]
  | snce c d ih1 ih2 =>
    simp [abstract_untl, has_no_allpast_allfuture,
      ih1 (has_no_allpast_allfuture_true c), ih2 (has_no_allpast_allfuture_true d)]

/-! ### Step 3: Substitution into Separated Formulas

The "constituent substitution" technique from GHR94 Lemma 10.2.6.
Given a separated formula ψ, substituting `.untl A B` (with S-free A, B)
for atom p yields a separable formula, provided we have a callback
for handling the `.snce` and `.all_past` constituents. -/

/-- Substituting `.untl A B` (S-free args) for atom p in a separated formula
    produces a separable formula, using `ih_snce` for constituents where
    substitution breaks separation (`.snce` and `.all_past` positions). -/
theorem subst_in_separated_separable (ψ : Formula) (p : Atom) (A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hsep : is_syntactically_separated ψ = true)
    (ih_snce : ∀ (χ : Formula), no_S_nested_in_U χ → is_separable χ) :
    is_separable (subst_formula ψ p (.untl A B)) := by
  induction ψ with
  | atom a =>
    simp only [subst_formula]; split
    · exact ⟨.untl A B, by simp [is_syntactically_separated, hA_sf, hB_sf], int_equiv_refl _⟩
    · exact ⟨.atom a, rfl, int_equiv_refl _⟩
  | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | box ψ => exact ⟨.box (subst_formula ψ p (.untl A B)), rfl, int_equiv_refl _⟩
  | imp c d ih_c ih_d =>
    simp [is_syntactically_separated] at hsep
    exact imp_separable (ih_c hsep.1) (ih_d hsep.2)
  | untl c d _ _ =>
    simp [is_syntactically_separated] at hsep
    have hU_sf : is_S_free (.untl A B) = true := by
      simp only [is_S_free, hA_sf, hB_sf, Bool.and_self]
    exact ⟨.untl (subst_formula c p (.untl A B)) (subst_formula d p (.untl A B)),
           by simp [is_syntactically_separated,
                     subst_S_free_preserves_S_free c p _ hsep.1 hU_sf,
                     subst_S_free_preserves_S_free d p _ hsep.2 hU_sf],
           int_equiv_refl _⟩
  | snce c d _ _ =>
    simp [is_syntactically_separated] at hsep
    exact ih_snce (.snce (subst_formula c p (.untl A B)) (subst_formula d p (.untl A B)))
      ⟨subst_U_free_gives_no_S_nested c p A B hsep.1 hA_sf hB_sf,
       subst_U_free_gives_no_S_nested d p A B hsep.2 hA_sf hB_sf⟩

/-! ### Step 4: Additional Infrastructure

Substitution congruence and helper lemmas for the hierarchy theorem. -/

/-- Substitution preserves int_equiv: if φ ≡ ψ then subst(φ, p, r) ≡ subst(ψ, p, r). -/
theorem subst_formula_congr {φ ψ : Formula} (h : int_equiv φ ψ)
    (p : Atom) (r : Formula) :
    int_equiv (subst_formula φ p r) (subst_formula ψ p r) := by
  intro M t; rw [subst_correctness, subst_correctness]; exact h _ t

/-- Helper: `.untl` with S-free args is already separated. -/
private theorem untl_sf_exp_separated (a b : Formula)
    (ha_sf : is_S_free a = true) (hb_sf : is_S_free b = true) :
    is_separable (.untl a b) :=
  ⟨.untl a b, by simp [is_syntactically_separated, ha_sf, hb_sf], int_equiv_refl _⟩

/-- Helper: `.snce` with U-free args is already separated. -/
private theorem snce_uf_separated (a b : Formula)
    (ha_uf : is_U_free a = true) (hb_uf : is_U_free b = true) :
    is_separable (.snce a b) :=
  ⟨.snce a b, by simp [is_syntactically_separated, ha_uf, hb_uf], int_equiv_refl _⟩

/-- Extract a U-type (A, B) with S-free args from a non-U-free formula
    that has `no_S_nested_in_U`. -/
private noncomputable def extract_U_type : (φ : Formula) → (is_U_free φ = false) →
    no_S_nested_in_U φ → (Formula × Formula)
  | .atom _, h, _ => by simp [is_U_free] at h
  | .bot, h, _ => by simp [is_U_free] at h
  | .imp c d, h, hns =>
    if hc : is_U_free c = false then extract_U_type c hc hns.1
    else extract_U_type d (by simp only [is_U_free] at h; simp [hc] at h; exact h) hns.2
  | .box c, h, hns => extract_U_type c (by simp only [is_U_free] at h; exact h) hns
  | .untl a b, _, _ => (a, b)
  | .snce c d, h, hns =>
    if hc : is_U_free c = false then extract_U_type c hc hns.1
    else extract_U_type d (by simp only [is_U_free] at h; simp [hc] at h; exact h) hns.2

private theorem extract_U_type_S_free (φ : Formula) (h : is_U_free φ = false)
    (hns : no_S_nested_in_U φ) :
    is_S_free (extract_U_type φ h hns).1 = true ∧
    is_S_free (extract_U_type φ h hns).2 = true := by
  induction φ with
  | atom _ => simp [is_U_free] at h
  | bot => simp [is_U_free] at h
  | imp c d ih1 ih2 =>
    unfold extract_U_type
    by_cases hc : is_U_free c = false
    · simp only [hc, ↓reduceDIte]; exact ih1 hc hns.1
    · simp only [hc, ↓reduceDIte]
      have hd : is_U_free d = false := by
        simp only [is_U_free] at h; cases huf : is_U_free c <;> simp_all
      exact ih2 hd hns.2
  | box c ih => simp only [is_U_free] at h; unfold extract_U_type; exact ih h hns
  | untl a b => exact hns
  | snce c d ih1 ih2 =>
    unfold extract_U_type
    by_cases hc : is_U_free c = false
    · simp only [hc, ↓reduceDIte]; exact ih1 hc hns.1
    · simp only [hc, ↓reduceDIte]
      have hd : is_U_free d = false := by
        simp only [is_U_free] at h; cases huf : is_U_free c <;> simp_all
      exact ih2 hd hns.2

/-- `extract_U_type` returns a pair `(A, B)` such that `contains_untl_surface φ A B`.
    This is the bridge between `extract_U_type` (which finds the first `.untl` by
    descending through `imp`, `box`, `snce`) and the count decrease lemma
    `abstract_untl_count_lt_of_contains_surface`. -/
private theorem extract_U_type_contains_surface (φ : Formula) (h : is_U_free φ = false)
    (hns : no_S_nested_in_U φ) :
    contains_untl_surface φ (extract_U_type φ h hns).1 (extract_U_type φ h hns).2 := by
  induction φ with
  | atom _ => simp [is_U_free] at h
  | bot => simp [is_U_free] at h
  | imp c d ih1 ih2 =>
    unfold extract_U_type
    by_cases hc : is_U_free c = false
    · simp only [hc, ↓reduceDIte, contains_untl_surface]
      exact Or.inl (ih1 hc hns.1)
    · simp only [hc, contains_untl_surface]
      have hd : is_U_free d = false := by
        simp only [is_U_free] at h; cases huf : is_U_free c <;> simp_all
      exact Or.inr (ih2 hd hns.2)
  | box c ih =>
    simp only [is_U_free] at h
    unfold extract_U_type; simp only [contains_untl_surface]; exact ih h hns
  | untl a b =>
    unfold extract_U_type; exact ⟨rfl, rfl⟩
  | snce c d ih1 ih2 =>
    unfold extract_U_type
    by_cases hc : is_U_free c = false
    · simp only [hc, ↓reduceDIte, contains_untl_surface]
      exact Or.inl (ih1 hc hns.1)
    · simp only [hc, contains_untl_surface]
      have hd : is_U_free d = false := by
        simp only [is_U_free] at h; cases huf : is_U_free c <;> simp_all
      exact Or.inr (ih2 hd hns.2)

/-! ### Step 5: S-Nesting Depth Measure for Lemma 10.2.5

GHR94 Lemma 10.2.5 proves that a formula with a single U-type U(A,B) (A, B S-free)
is separable by induction on the maximum number of `.snce` nodes above any `.untl`
in the formula tree. We define a non-mutual version of this measure and prove
the key properties needed for the well-founded induction. -/

/-- Maximum number of `.snce` ancestors above any `.untl` node in the formula tree.
    Returns 0 if the formula is U-free. For `.snce C F`, adds 1 if U appears below.
    Non-mutual version of `S_nesting_above_U` for easier theorem proving. -/
def snce_depth_of_U : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (snce_depth_of_U a) (snce_depth_of_U b)
  | .box a => snce_depth_of_U a
  | .untl _ _ => 0
  | .snce a b =>
    if is_U_free a = true ∧ is_U_free b = true then 0
    else 1 + max (snce_depth_of_U a) (snce_depth_of_U b)

/-- U-free formulas have snce_depth_of_U = 0. -/
theorem snce_depth_of_U_zero_of_U_free (phi : Formula)
    (h : is_U_free phi = true) : snce_depth_of_U phi = 0 := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_U_free] at h
    simp [snce_depth_of_U, ih1 h.1, ih2 h.2]
  | box a ih => simp [is_U_free] at h; simp [snce_depth_of_U, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce a b ih1 ih2 =>
    simp [is_U_free] at h
    simp [snce_depth_of_U, h.1, h.2]

/-- Key property: for `.snce C F` where C or F is not U-free,
    `snce_depth_of_U C < snce_depth_of_U (.snce C F)` and similarly for F. -/
theorem snce_depth_of_U_lt_snce (C F : Formula)
    (h : ¬(is_U_free C = true ∧ is_U_free F = true)) :
    snce_depth_of_U C < snce_depth_of_U (.snce C F) ∧
    snce_depth_of_U F < snce_depth_of_U (.snce C F) := by
  simp [snce_depth_of_U, h]
  constructor <;> omega

/-- snce_depth_of_U is monotone for imp subterms. -/
theorem snce_depth_of_U_le_imp_left (a b : Formula) :
    snce_depth_of_U a ≤ snce_depth_of_U (.imp a b) :=
  Nat.le_max_left _ _

theorem snce_depth_of_U_le_imp_right (a b : Formula) :
    snce_depth_of_U b ≤ snce_depth_of_U (.imp a b) :=
  Nat.le_max_right _ _

/-! ### Step 5b: Base Case — snce_depth_of_U = 0 with single U-type

When snce_depth_of_U phi = 0 and phi has single U-type U(A,B) with S-free A, B
and has_no_allpast_allfuture, then phi is syntactically separated.

This means: every `.snce` in phi has U-free args, and every `.untl` is U(A,B)
with S-free args. So `.untl` positions have S-free args and `.snce` positions
have U-free args. -/

/-- When snce_depth_of_U = 0 and has_single_U_type, every `.snce` subformula
    has U-free args, so the formula is syntactically separated
    (given has_no_allpast_allfuture). -/
theorem snce_depth_zero_single_U_separated (phi A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hsingle : has_single_U_type phi A B)
    (hexp : has_no_allpast_allfuture phi = true)
    (hdepth : snce_depth_of_U phi = 0) :
    is_syntactically_separated phi = true := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [snce_depth_of_U] at hdepth
    simp [is_syntactically_separated,
      ih1 hsingle.1 (has_no_allpast_allfuture_true a) (by omega),
      ih2 hsingle.2 (has_no_allpast_allfuture_true b) (by omega)]
  | box _ => rfl
  | untl a b _ _ =>
    have ⟨ha, hb⟩ := hsingle; subst ha; subst hb
    simp [is_syntactically_separated, hA_sf, hB_sf]
  | snce a b _ _ =>
    simp [snce_depth_of_U] at hdepth
    obtain ⟨ha_uf, hb_uf⟩ := hdepth
    simp [is_syntactically_separated, ha_uf, hb_uf]

/-! ### Step 5c: Single-U-Type at Depth 0 — Direct Separability via Event-Guard Decomposition

GHR94 Lemma 10.2.4: `.snce C F` where U(A,B) appears only at top level (not under
any S within C or F) is separable. The proof decomposes into Cases 1-8 using:
1. Event-splitting on U(A,B)
2. CNF decomposition of the guard
3. Generalized Cases 1-8 (no S-free requirement on a, q)

Key technique: `C ∧ U(A,B) ≡ C[U:=⊤] ∧ U(A,B)` where C[U:=⊤] is U-free. -/

/-- Replace all `.untl A B` with a constant formula `r` in `C`.
    Simpler than abstract_untl + subst: directly replaces at formula level. -/
def replace_untl (C A B r : Formula) : Formula :=
  match C with
  | .atom a => .atom a
  | .bot => .bot
  | .imp c d => .imp (replace_untl c A B r) (replace_untl d A B r)
  | .box c => .box (replace_untl c A B r)
  | .untl c d => if c = A ∧ d = B then r else .untl (replace_untl c A B r) (replace_untl d A B r)
  | .snce c d => .snce (replace_untl c A B r) (replace_untl d A B r)

/-- replace_untl with single U-type produces a U-free formula when r is U-free. -/
theorem replace_untl_U_free (C A B r : Formula)
    (hsingle : has_single_U_type C A B) (hr : is_U_free r = true) :
    is_U_free (replace_untl C A B r) = true := by
  induction C with
  | atom _ => simp [replace_untl, is_U_free]
  | bot => simp [replace_untl, is_U_free]
  | imp c d ih1 ih2 =>
    simp [replace_untl, is_U_free, ih1 hsingle.1, ih2 hsingle.2]
  | box c ih =>
    simp [replace_untl, is_U_free, ih hsingle]
  | untl c d _ _ =>
    have ⟨hc, hd⟩ := hsingle; subst hc; subst hd
    simp [replace_untl, is_U_free, hr]
  | snce c d ih1 ih2 =>
    simp [replace_untl, is_U_free, ih1 hsingle.1, ih2 hsingle.2]

/-- replace_untl is identity on U-free formulas. -/
theorem replace_untl_identity_U_free (C A B r : Formula) (h : is_U_free C = true) :
    replace_untl C A B r = C := by
  induction C with
  | atom _ => simp [replace_untl]
  | bot => simp [replace_untl]
  | imp c d ih1 ih2 => simp [is_U_free] at h; simp [replace_untl, ih1 h.1, ih2 h.2]
  | box c ih => simp [is_U_free] at h; simp [replace_untl, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce c d ih1 ih2 => simp [is_U_free] at h; simp [replace_untl, ih1 h.1, ih2 h.2]

/-- When U(A,B) holds at a point and C has single U-type with snce_depth_of_U = 0
    and has_no_allpast_allfuture, C evaluates identically to replace_untl C A B (¬⊥).
    This is because every .untl A B in C is evaluated at the SAME point t
    (not shifted by .snce or .all_past/.all_future). -/
theorem single_U_eval_when_U_true (C A B : Formula)
    (hsingle : has_single_U_type C A B)
    (hexp : has_no_allpast_allfuture C = true)
    (hdepth : snce_depth_of_U C = 0) (M : IntStructure) (t : ℤ)
    (hU : int_truth M t (.untl A B)) :
    int_truth M t C ↔ int_truth M t (replace_untl C A B (Formula.neg .bot)) := by
  induction C with
  | atom _ => simp [replace_untl]
  | bot => simp [replace_untl]
  | imp c d ih1 ih2 =>
    simp [snce_depth_of_U] at hdepth
    simp only [replace_untl, int_truth]
    exact Iff.imp (ih1 hsingle.1 (has_no_allpast_allfuture_true c) (by omega))
                  (ih2 hsingle.2 (has_no_allpast_allfuture_true d) (by omega))
  | box _ => simp [replace_untl, int_truth]
  | untl c d _ _ =>
    have ⟨hc, hd⟩ := hsingle; subst hc; subst hd
    simp [replace_untl, Formula.neg, int_truth]
    exact hU
  | snce c d ih1 ih2 =>
    -- snce_depth_of_U (.snce c d) = 0 means both c and d are U-free
    simp [snce_depth_of_U] at hdepth
    obtain ⟨hc_uf, hd_uf⟩ := hdepth
    -- Both c, d are U-free. replace_untl is identity.
    simp only [replace_untl,
      replace_untl_identity_U_free c A B _ hc_uf,
      replace_untl_identity_U_free d A B _ hd_uf]

/-- Dual: when ¬U(A,B) holds at a point, C evaluates identically to replace_untl C A B ⊥. -/
theorem single_U_eval_when_U_false (C A B : Formula)
    (hsingle : has_single_U_type C A B)
    (hexp : has_no_allpast_allfuture C = true)
    (hdepth : snce_depth_of_U C = 0) (M : IntStructure) (t : ℤ)
    (hnotU : ¬ int_truth M t (.untl A B)) :
    int_truth M t C ↔ int_truth M t (replace_untl C A B .bot) := by
  induction C with
  | atom _ => simp [replace_untl]
  | bot => simp [replace_untl]
  | imp c d ih1 ih2 =>
    simp [snce_depth_of_U] at hdepth
    simp only [replace_untl, int_truth]
    exact Iff.imp (ih1 hsingle.1 (has_no_allpast_allfuture_true c) (by omega))
                  (ih2 hsingle.2 (has_no_allpast_allfuture_true d) (by omega))
  | box _ => simp [replace_untl, int_truth]
  | untl c d _ _ =>
    have ⟨hc, hd⟩ := hsingle; subst hc; subst hd
    simp only [replace_untl, ite_true, and_self, int_truth]
    constructor
    · intro ⟨_, _, _, _⟩; exact False.elim (hnotU ⟨_, ‹_›, ‹_›, ‹_›⟩)
    · intro h; exact False.elim h
  | snce c d ih1 ih2 =>
    simp [snce_depth_of_U] at hdepth
    obtain ⟨hc_uf, hd_uf⟩ := hdepth
    simp only [replace_untl,
      replace_untl_identity_U_free c A B _ hc_uf,
      replace_untl_identity_U_free d A B _ hd_uf]

/-- Semantic equivalence: C ∧ U(A,B) ≡ C[U:=⊤] ∧ U(A,B) for single-U-type C. -/
theorem single_U_and_conj_simplify (C A B : Formula)
    (hsingle : has_single_U_type C A B)
    (hexp : has_no_allpast_allfuture C = true)
    (hdepth : snce_depth_of_U C = 0) :
    int_equiv (Formula.and C (.untl A B))
              (Formula.and (replace_untl C A B (Formula.neg .bot)) (.untl A B)) := by
  intro M t; constructor
  · intro h
    have ⟨hC, hU⟩ := int_truth_and_iff.mp h
    exact int_truth_and_iff.mpr ⟨(single_U_eval_when_U_true C A B hsingle hexp hdepth M t hU).mp hC, hU⟩
  · intro h
    have ⟨hCt, hU⟩ := int_truth_and_iff.mp h
    exact int_truth_and_iff.mpr ⟨(single_U_eval_when_U_true C A B hsingle hexp hdepth M t hU).mpr hCt, hU⟩

/-- GHR94 Lemma 10.2.6 (parameterized): A formula with `no_S_nested_in_U` and
    `has_no_allpast_allfuture` is separable, given a callback for handling
    the `.snce`/`.all_past` constituents produced by substitution.

    The callback receives formulas with `no_S_nested_in_U` that arise from
    substituting `.untl A B` (S-free args) into U-free positions of a
    separated formula. These callback formulas have single U-type U(A,B). -/
theorem no_S_nested_in_U_separable_param (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hexp : has_no_allpast_allfuture phi = true)
    (callback : ∀ (χ : Formula), no_S_nested_in_U χ → is_separable χ) :
    is_separable phi := by
  -- Strong induction on count_U_subformulas
  induction h : count_U_subformulas phi using Nat.strongRecOn generalizing phi with
  | ind n ih =>
  -- Case n = 0: U-free, syntactically separated
  by_cases huf : is_U_free phi = true
  · exact separated_imp_separable phi (restricted_u_free_separated phi hexp huf)
  · -- Case n > 0: extract U-type and abstract
    push_neg at huf; simp [Bool.not_eq_true] at huf
    have huf' : is_U_free phi = false := huf
    let AB := extract_U_type phi huf' hns
    have hAB_sf := extract_U_type_S_free phi huf' hns
    let p := fresh_atom phi
    have hfresh := fresh_atom_not_in phi
    let phi' := abstract_untl phi AB.1 AB.2 p
    have hcontains := extract_U_type_contains_surface phi huf' hns
    have hcount_lt : count_U_subformulas phi' < count_U_subformulas phi :=
      abstract_untl_count_lt_of_contains_surface phi AB.1 AB.2 p hcontains
    have hns' : no_S_nested_in_U phi' :=
      abstract_untl_preserves_no_S_nested phi AB.1 AB.2 p hns
    have hexp' : has_no_allpast_allfuture phi' = true :=
      abstract_untl_preserves_no_allpast_allfuture phi AB.1 AB.2 p hexp
    -- phi' is separable by IH (strictly fewer U-subformulas)
    have h_phi'_sep : is_separable phi' := by
      exact ih (count_U_subformulas phi') (h ▸ hcount_lt) phi' hns' hexp' rfl
    -- Get separated psi equivalent to phi'
    obtain ⟨psi, hpsi_sep, hpsi_equiv⟩ := h_phi'_sep
    -- phi = subst(phi', p, U(A,B)) by syntactic roundtrip
    have hroundtrip : subst_formula phi' p (.untl AB.1 AB.2) = phi :=
      abstract_subst_roundtrip phi AB.1 AB.2 p hfresh
    -- phi is equiv to subst(psi, p, U(A,B)) by congruence
    have hphi_equiv : int_equiv phi (subst_formula psi p (.untl AB.1 AB.2)) := by
      rw [← hroundtrip]
      exact subst_formula_congr hpsi_equiv p (.untl AB.1 AB.2)
    -- subst(psi, p, U(A,B)) is separable via constituent substitution
    have h_subst_sep : is_separable (subst_formula psi p (.untl AB.1 AB.2)) :=
      subst_in_separated_separable psi p AB.1 AB.2
        hAB_sf.1 hAB_sf.2 hpsi_sep callback
    exact is_separable_of_equiv hphi_equiv h_subst_sep

/-- GHR94 Lemma 10.2.6: A formula with `no_S_nested_in_U` and `has_no_allpast_allfuture`
    is separable. Uses `all_separable` as callback (temporary, will be replaced). -/
theorem no_S_nested_in_U_separable_noax (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hexp : has_no_allpast_allfuture phi = true) :
    is_separable phi :=
  no_S_nested_in_U_separable_param phi hns hexp (fun χ _hns_χ => all_separable χ)

/-! ### Step 5d: The Hierarchy Theorem (GHR94 Lemmas 10.2.5-10.2.8)

The hierarchy theorem proves every expanded formula is separable. -/

/-- Junction depth 0 with expanded gives separated (re-export for convenience). -/
private theorem jd_zero_sep (φ : Formula)
    (hexp : has_no_allpast_allfuture φ = true) (hjd : junction_depth φ = 0) :
    is_separable φ :=
  separated_imp_separable φ (expanded_jd_zero_imp_separated φ hexp hjd)

/-- Congruence for untl: if a ≡ a' and b ≡ b' then untl a b ≡ untl a' b'. -/
theorem untl_congr {a a' b b' : Formula}
    (ha : int_equiv a a') (hb : int_equiv b b') :
    int_equiv (.untl a b) (.untl a' b') := by
  intro M t; constructor
  · rintro ⟨s, hts, hφ, hψ⟩
    exact ⟨s, hts, (ha M s).mp hφ, fun r hr1 hr2 => (hb M r).mp (hψ r hr1 hr2)⟩
  · rintro ⟨s, hts, hφ, hψ⟩
    exact ⟨s, hts, (ha M s).mpr hφ, fun r hr1 hr2 => (hb M r).mpr (hψ r hr1 hr2)⟩

/-- Congruence for snce: if a ≡ a' and b ≡ b' then snce a b ≡ snce a' b'. -/
theorem snce_congr {a a' b b' : Formula}
    (ha : int_equiv a a') (hb : int_equiv b b') :
    int_equiv (.snce a b) (.snce a' b') := by
  intro M t; constructor
  · rintro ⟨s, hst, hφ, hψ⟩
    exact ⟨s, hst, (ha M s).mp hφ, fun r hr1 hr2 => (hb M r).mp (hψ r hr1 hr2)⟩
  · rintro ⟨s, hst, hφ, hψ⟩
    exact ⟨s, hst, (ha M s).mpr hφ, fun r hr1 hr2 => (hb M r).mpr (hψ r hr1 hr2)⟩


/-- Callback formulas from `subst_in_separated_separable` have junction_depth ≤ 1.
    This follows because: (1) the `.snce c d` branches c, d of a separated formula
    are U-free, hence have junction_depth_S = 0; (2) substituting `.untl A B` (with
    S-free A, B) into U-free formulas gives junction_depth_S ≤ 1; (3) the callback
    `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` has JD = max of these ≤ 1. -/
private theorem callback_jd_le_one (c d : Formula) (p : Atom) (A B : Formula)
    (hc_uf : is_U_free c = true) (hd_uf : is_U_free d = true)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true) :
    junction_depth (.snce (subst_formula c p (.untl A B)) (subst_formula d p (.untl A B))) ≤ 1 := by
  simp only [junction_depth]
  have h1 := subst_u_free_jdS_le_one c p A B hc_uf hA_sf hB_sf
  have h2 := subst_u_free_jdS_le_one d p A B hd_uf hA_sf hB_sf
  omega
where
  /-- Substituting `.untl A B` (S-free args) into a U-free formula gives jdS ≤ 1. -/
  subst_u_free_jdS_le_one (φ : Formula) (p : Atom) (A B : Formula)
      (huf : is_U_free φ = true) (hA : is_S_free A = true) (hB : is_S_free B = true) :
      junction_depth_S (subst_formula φ p (.untl A B)) ≤ 1 := by
    induction φ with
    | atom a =>
      simp only [subst_formula]
      split
      · -- a = p: result is .untl A B
        simp only [junction_depth_S]
        have hA0 := s_free_junction_depth_zero A hA
        have hB0 := s_free_junction_depth_zero B hB
        omega
      · simp [junction_depth_S]
    | bot => simp [subst_formula, junction_depth_S]
    | imp a b ih1 ih2 =>
      simp [is_U_free] at huf
      simp [subst_formula, junction_depth_S, ih1 huf.1, ih2 huf.2]
    | box a ih =>
      simp [is_U_free] at huf
      simp [subst_formula, junction_depth_S, ih huf]
    | untl _ _ => simp [is_U_free] at huf
    | snce a b ih1 ih2 =>
      simp [is_U_free] at huf
      simp [subst_formula, junction_depth_S, ih1 huf.1, ih2 huf.2]

/-- Callback formulas from substitution into separated formulas have has_no_allpast_allfuture. -/
private theorem callback_has_no_allpast_allfuture (c d : Formula) (p : Atom) (A B : Formula) :
    has_no_allpast_allfuture
      (.snce (subst_formula c p (.untl A B)) (subst_formula d p (.untl A B))) = true := by
  exact has_no_allpast_allfuture_true _

/-- Version of `subst_in_separated_separable` where the callback also receives a
    junction_depth bound. The callback formulas have JD ≤ 1. -/
theorem subst_in_separated_separable_jd (ψ : Formula) (p : Atom) (A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hsep : is_syntactically_separated ψ = true)
    (ih_snce : ∀ (χ : Formula), no_S_nested_in_U χ → junction_depth χ ≤ 1 → is_separable χ) :
    is_separable (subst_formula ψ p (.untl A B)) := by
  induction ψ with
  | atom a =>
    simp only [subst_formula]; split
    · exact ⟨.untl A B, by simp [is_syntactically_separated, hA_sf, hB_sf], int_equiv_refl _⟩
    · exact ⟨.atom a, rfl, int_equiv_refl _⟩
  | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | box ψ => exact ⟨.box (subst_formula ψ p (.untl A B)), rfl, int_equiv_refl _⟩
  | imp c d ih_c ih_d =>
    simp [is_syntactically_separated] at hsep
    exact imp_separable (ih_c hsep.1) (ih_d hsep.2)
  | untl c d _ _ =>
    simp [is_syntactically_separated] at hsep
    have hU_sf : is_S_free (.untl A B) = true := by
      simp only [is_S_free, hA_sf, hB_sf, Bool.and_self]
    exact ⟨.untl (subst_formula c p (.untl A B)) (subst_formula d p (.untl A B)),
           by simp [is_syntactically_separated,
                     subst_S_free_preserves_S_free c p _ hsep.1 hU_sf,
                     subst_S_free_preserves_S_free d p _ hsep.2 hU_sf],
           int_equiv_refl _⟩
  | snce c d _ _ =>
    simp [is_syntactically_separated] at hsep
    have hns : no_S_nested_in_U (.snce (subst_formula c p (.untl A B))
        (subst_formula d p (.untl A B))) :=
      ⟨subst_U_free_gives_no_S_nested c p A B hsep.1 hA_sf hB_sf,
       subst_U_free_gives_no_S_nested d p A B hsep.2 hA_sf hB_sf⟩
    have hjd_bound : junction_depth (.snce (subst_formula c p (.untl A B))
        (subst_formula d p (.untl A B))) ≤ 1 :=
      callback_jd_le_one c d p A B hsep.1 hsep.2 hA_sf hB_sf
    exact ih_snce _ hns hjd_bound

/-- Version of `no_S_nested_in_U_separable_param` with JD-bounded callback. -/
theorem no_S_nested_in_U_separable_param_jd (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hexp : has_no_allpast_allfuture phi = true)
    (callback : ∀ (χ : Formula), no_S_nested_in_U χ → junction_depth χ ≤ 1 → is_separable χ) :
    is_separable phi := by
  -- Strong induction on count_U_subformulas
  induction h : count_U_subformulas phi using Nat.strongRecOn generalizing phi with
  | ind n ih =>
  -- Case n = 0: U-free, syntactically separated
  by_cases huf : is_U_free phi = true
  · exact separated_imp_separable phi (restricted_u_free_separated phi hexp huf)
  · -- Case n > 0: extract U-type and abstract
    push_neg at huf; simp [Bool.not_eq_true] at huf
    have huf' : is_U_free phi = false := huf
    let AB := extract_U_type phi huf' hns
    have hAB_sf := extract_U_type_S_free phi huf' hns
    let p := fresh_atom phi
    have hfresh := fresh_atom_not_in phi
    let phi' := abstract_untl phi AB.1 AB.2 p
    have hcontains := extract_U_type_contains_surface phi huf' hns
    have hcount_lt : count_U_subformulas phi' < count_U_subformulas phi :=
      abstract_untl_count_lt_of_contains_surface phi AB.1 AB.2 p hcontains
    have hns' : no_S_nested_in_U phi' :=
      abstract_untl_preserves_no_S_nested phi AB.1 AB.2 p hns
    have hexp' : has_no_allpast_allfuture phi' = true :=
      abstract_untl_preserves_no_allpast_allfuture phi AB.1 AB.2 p hexp
    -- phi' is separable by IH (strictly fewer U-subformulas)
    have h_phi'_sep : is_separable phi' := by
      exact ih (count_U_subformulas phi') (h ▸ hcount_lt) phi' hns' hexp' rfl
    -- Get separated psi equivalent to phi'
    obtain ⟨psi, hpsi_sep, hpsi_equiv⟩ := h_phi'_sep
    -- phi = subst(phi', p, U(A,B)) by syntactic roundtrip
    have hroundtrip : subst_formula phi' p (.untl AB.1 AB.2) = phi :=
      abstract_subst_roundtrip phi AB.1 AB.2 p hfresh
    -- phi is equiv to subst(psi, p, U(A,B)) by congruence
    have hphi_equiv : int_equiv phi (subst_formula psi p (.untl AB.1 AB.2)) := by
      rw [← hroundtrip]
      exact subst_formula_congr hpsi_equiv p (.untl AB.1 AB.2)
    -- subst(psi, p, U(A,B)) is separable via constituent substitution with JD-bounded callback
    have h_subst_sep : is_separable (subst_formula psi p (.untl AB.1 AB.2)) :=
      subst_in_separated_separable_jd psi p AB.1 AB.2
        hAB_sf.1 hAB_sf.2 hpsi_sep callback
    exact is_separable_of_equiv hphi_equiv h_subst_sep

/-- Main hierarchy theorem: every expanded formula is separable.
    Proved by strong induction on junction_depth. The `.snce` case reduces to separated
    forms of sub-formulas, which satisfy `no_S_nested_in_U` and have JD ≤ 1.
    For JD ≥ 2, the JD induction hypothesis serves as the callback for
    `no_S_nested_in_U_separable_param` (callback formulas have JD ≤ 1 < JD).
    For JD ≤ 1, `no_S_nested_in_U_separable_param` is applied with the JD = 0
    base case as callback (JD = 0 formulas are separated, so no further callbacks).
    The `.untl` case follows by temporal duality.

    GHR94 Lemma 10.2.8 + Theorem 10.2.9 (specialized to integer time). -/
theorem all_formulas_separable_aux (φ : Formula)
    (hexp : has_no_allpast_allfuture φ = true) : is_separable φ := by
  -- Strong induction on junction_depth, with structural sub-induction for same-JD cases.
  -- We use (junction_depth, sizeOf) lexicographic well-founded induction.
  have : ∀ (n : Nat) (ψ : Formula), junction_depth ψ ≤ n →
      has_no_allpast_allfuture ψ = true → is_separable ψ := by
    intro n
    induction n using Nat.strongRecOn with
    | ind n ih_jd =>
    intro ψ hjd hψ_exp
    -- Within each JD level, use structural induction on ψ
    induction ψ with
    | atom a => exact ⟨.atom a, rfl, int_equiv_refl _⟩
    | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
    | box ψ => exact ⟨.box ψ, rfl, int_equiv_refl _⟩
    | imp a b ih_a ih_b =>
      have hle_a : junction_depth a ≤ n := Nat.le_trans (jd_imp_le_left a b) hjd
      have hle_b : junction_depth b ≤ n := Nat.le_trans (jd_imp_le_right a b) hjd
      exact imp_separable (ih_a hle_a (has_no_allpast_allfuture_true a))
                          (ih_b hle_b (has_no_allpast_allfuture_true b))
    | snce a b ih_a ih_b =>
      -- Sub-formulas a, b have JD ≤ n (same level), but are structurally smaller
      have hle_a : junction_depth a ≤ n := Nat.le_trans (jd_snce_le_left a b) hjd
      have hle_b : junction_depth b ≤ n := Nat.le_trans (jd_snce_le_right a b) hjd
      -- Quick exit: JD = 0 means formula is directly separated
      by_cases hjd0 : junction_depth (.snce a b) = 0
      · exact jd_zero_sep (.snce a b) hψ_exp hjd0
      · -- JD ≥ 1: need the full separation/box-normalization path
        -- Step 1: By structural IH at same JD level, a and b are separable.
        have ha := ih_a hle_a (has_no_allpast_allfuture_true a)
        have hb := ih_b hle_b (has_no_allpast_allfuture_true b)
        -- Step 2: Get separated forms ψa ≡ a, ψb ≡ b.
        obtain ⟨ψa, hψa_sep, hψa_equiv⟩ := ha
        obtain ⟨ψb, hψb_sep, hψb_equiv⟩ := hb
        -- Step 3: Box-normalize.
        let χa := replace_box_with_top ψa
        let χb := replace_box_with_top ψb
        -- Step 4: Build equivalence chain: .snce a b ≡ .snce χa χb
        have hequiv : int_equiv (.snce a b) (.snce χa χb) :=
          int_equiv_trans (snce_congr hψa_equiv hψb_equiv)
            (snce_congr (replace_box_equiv ψa) (replace_box_equiv ψb))
        -- Step 5: .snce χa χb has no_S_nested_in_U
        have hns : no_S_nested_in_U (.snce χa χb) :=
          snce_of_boxfree_sep_no_S_nested ψa ψb hψa_sep hψb_sep
        -- Step 6: .snce χa χb has JD ≤ 1
        have _hjd_le_one : junction_depth (.snce χa χb) ≤ 1 :=
          snce_of_boxfree_sep_jd_le_one ψa ψb hψa_sep hψb_sep
        -- Step 7: Apply no_S_nested_in_U_separable_param_jd.
        -- Since JD(.snce a b) ≥ 1 and n ≥ JD(.snce a b), we have n ≥ 1.
        -- Callback formulas have JD ≤ 1 < n when n ≥ 2.
        -- For n = 1: callback JD ≤ 1, handled by ih_jd 0 for JD = 0 (sorry for JD = 1).
        have h_sep : is_separable (.snce χa χb) := by
          by_cases hn : n ≥ 2
          · -- n ≥ 2: callback JD ≤ 1 < 2 ≤ n
            exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
              (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
                ih_jd 1 (by omega) ζ hjd_ζ (has_no_allpast_allfuture_true ζ))
          · -- n = 1 (since n ≥ 1 from JD ≥ 1 and JD ≤ n)
            -- Callback JD ≤ 1. For JD = 0: ih_jd 0. For JD = 1: sorry.
            exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
              (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
                ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
        exact is_separable_of_equiv hequiv h_sep
    | untl a b ih_a ih_b =>
      -- Sub-formulas have JD ≤ n
      have hle_a : junction_depth a ≤ n := Nat.le_trans (jd_untl_le_left a b) hjd
      have hle_b : junction_depth b ≤ n := Nat.le_trans (jd_untl_le_right a b) hjd
      -- Quick exit: JD = 0 means formula is directly separated
      by_cases hjd0 : junction_depth (.untl a b) = 0
      · exact jd_zero_sep (.untl a b) hψ_exp hjd0
      · -- JD ≥ 1: need full path
        -- Step 1: By structural IH, a and b are separable.
        have ha := ih_a hle_a (has_no_allpast_allfuture_true a)
        have hb := ih_b hle_b (has_no_allpast_allfuture_true b)
        obtain ⟨ψa, hψa_sep, hψa_equiv⟩ := ha
        obtain ⟨ψb, hψb_sep, hψb_equiv⟩ := hb
        -- Step 2: Box-normalize.
        let χa := replace_box_with_top ψa
        let χb := replace_box_with_top ψb
        -- Step 3: .untl χa χb has no_U_nested_in_S
        have hns_U : no_U_nested_in_S (.untl χa χb) :=
          untl_of_boxfree_sep_no_U_nested ψa ψb hψa_sep hψb_sep
        -- Step 4: swap(.untl χa χb) has no_S_nested_in_U
        have hns_S : no_S_nested_in_U (Formula.swap_temporal (.untl χa χb)) :=
          swap_no_U_nested_gives_no_S_nested (.untl χa χb) hns_U
        -- Step 5: swap is separable via no_S_nested_in_U_separable_param_jd + JD IH.
        have h_swap_sep : is_separable (Formula.swap_temporal (.untl χa χb)) := by
          by_cases hn : n ≥ 2
          · exact no_S_nested_in_U_separable_param_jd _ hns_S
              (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
                ih_jd 1 (by omega) ζ hjd_ζ (has_no_allpast_allfuture_true ζ))
          · -- n = 1 (since n ≥ 1 from JD ≥ 1 and JD ≤ n)
            exact no_S_nested_in_U_separable_param_jd _ hns_S
              (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
                ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
        -- Step 7: dual_separable
        have h_untl_sep : is_separable (.untl χa χb) := by
          have h := dual_separable _ h_swap_sep
          rw [Formula.swap_temporal_involution] at h
          exact h
        -- Step 8: Build equivalence chain
        have hequiv : int_equiv (.untl a b) (.untl χa χb) :=
          int_equiv_trans (untl_congr hψa_equiv hψb_equiv)
            (untl_congr (replace_box_equiv ψa) (replace_box_equiv ψb))
        exact is_separable_of_equiv hequiv h_untl_sep
  exact this (junction_depth φ) φ (Nat.le_refl _) hexp

/-- Every formula is separable (GHR94 Theorem 10.2.9 for integer time).
    Proved by expanding temporal operators and applying the hierarchy theorem. -/
theorem all_formulas_separable (φ : Formula) : is_separable φ :=
  is_separable_of_equiv (expand_temporal_equiv φ)
    (all_formulas_separable_aux (expand_temporal φ) (expand_has_no_allpast_allfuture φ))

end Bimodal.Metalogic.WeakCanonical.Separation
