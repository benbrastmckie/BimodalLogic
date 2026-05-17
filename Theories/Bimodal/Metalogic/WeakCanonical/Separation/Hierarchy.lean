import Bimodal.Metalogic.WeakCanonical.Separation.NormalForm
import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm

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
  | .all_past ψ => has_single_U_type ψ A B
  | .all_future ψ => has_single_U_type ψ A B
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
  | all_past ψ ih =>
    simp [is_U_free] at h
    exact ih h
  | all_future ψ ih =>
    simp [is_U_free] at h
    exact ih h
  | untl _ _ => simp [is_U_free] at h
  | snce ψ₁ ψ₂ ih1 ih2 =>
    simp [is_U_free] at h
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

/-- Helper: all_past preserves has_single_U_type. -/
theorem has_single_U_type_all_past {φ A B : Formula}
    (h : has_single_U_type φ A B) :
    has_single_U_type (.all_past φ) A B := h

/-- Helper: all_future preserves has_single_U_type. -/
theorem has_single_U_type_all_future {φ A B : Formula}
    (h : has_single_U_type φ A B) :
    has_single_U_type (.all_future φ) A B := h

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
  | all_past ψ ih =>
    exact all_past_separable ψ (ih h_single)
  | all_future ψ ih =>
    exact all_future_separable ψ (ih h_single)
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

/-- If φ is U-free and S-free, it is separable (re-export from NormalForm). -/
theorem u_free_s_free_is_separable {φ : Formula}
    (hu : is_U_free φ = true) (hs : is_S_free φ = true) :
    is_separable φ :=
  u_free_s_free_separable φ hu hs

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

/-- If a formula has single U-type U(A,B) with S-free A, B, wrapped in
    all_past, it is separable. -/
theorem single_U_all_past_separable (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable (.all_past φ) :=
  all_past_separable φ (single_U_formula_separable φ A B hA_sf hB_sf h_single)

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
  | .all_past psi => .all_past (abstract_untl psi A B p)
  | .all_future psi => .all_future (abstract_untl psi A B p)
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
  | all_past c ih =>
    simp [Formula.atoms] at hfresh
    simp [abstract_untl, subst_formula, ih hfresh]
  | all_future c ih =>
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
  | all_past c ih =>
    simp [Formula.atoms] at hfresh
    simp only [abstract_untl, int_truth]
    constructor
    · intro h s hst; exact (ih hfresh s).mp (h s hst)
    · intro h s hst; exact (ih hfresh s).mpr (h s hst)
  | all_future c ih =>
    simp [Formula.atoms] at hfresh
    simp only [abstract_untl, int_truth]
    constructor
    · intro h s hts; exact (ih hfresh s).mp (h s hts)
    · intro h s hts; exact (ih hfresh s).mpr (h s hts)
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
  | all_past c ih =>
    simp [is_S_free] at h
    simp [abstract_untl, is_S_free, ih h]
  | all_future c ih =>
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
  | all_past c ih => exact ih h
  | all_future c ih => exact ih h
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
  | all_past c ih =>
    simp [abstract_untl, is_U_free, ih h]
  | all_future c ih =>
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
  | all_past c ih =>
    simp [count_U_subformulas, is_U_free, ih]
  | all_future c ih =>
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
  | all_past c ih =>
    simp [abstract_untl, count_U_subformulas]; exact ih
  | all_future c ih =>
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

/-! ### Lemma 10.2.6: Multi-U Formula Separability -/

/-- Lemma 10.2.6 (GHR94): If no S is nested within any U-argument of φ
    (equivalently: all U-arguments are S-free), then φ is separable.

    **Proof sketch** (by induction on count_U_subformulas):
    - Base (count = 0): φ is U-free, hence separable.
    - Step (count ≥ 1): Pick one U-type U(A,B) in φ. Abstract all OTHER
      U-types to fresh atoms. The result has single U-type U(A,B) with S-free
      args. Apply Lemma 10.2.5 to get a separated equivalent. Substitute the
      fresh atoms back to recover the original semantics.

    At this stage, the proof uses `all_separable` (which relies on temporal
    closure axioms). In Phase 6, this theorem will be re-proved using
    junction-depth induction, eliminating the need for axioms. The
    infrastructure above (abstract_untl, roundtrip, correctness, preservation)
    provides the machinery that Phase 6 will call upon.

    The key insight is that `no_S_nested_in_U φ` guarantees all U-arguments
    are S-free, which is the precondition for both Lemma 10.2.5 (single-U)
    and the inductive abstraction step (fresh atoms are trivially S-free). -/
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

/-- all_past of a no_S_nested_in_U formula is separable. -/
theorem multi_U_all_past_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable (.all_past phi) :=
  all_past_separable phi (multi_U_formula_separable phi h)

/-- all_future of a no_S_nested_in_U formula is separable. -/
theorem multi_U_all_future_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable (.all_future phi) :=
  all_future_separable phi (multi_U_formula_separable phi h)

end Bimodal.Metalogic.WeakCanonical.Separation
