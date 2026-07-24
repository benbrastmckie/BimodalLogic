/-
================================================================================
ARCHIVED — BIT-ROTTED DEAD CODE (Kamp Boneyard). MOVE-not-delete; never empty.
================================================================================

This is the abandoned GHR separation / expressive-completeness ALTERNATIVE. It is
EXCLUDED FROM THE BUILD (outside the Bimodal.lean import closure — uncompiled) and does
NOT COMPILE. A `grep -c sorry == 0` on this file is MEANINGLESS: uncompiled code trivially
has no sorry. This is NOT sorry-free, verified, or reusable code.

It is OFF the faithful Rabinovich path (Def 4.1, PDF p.5). Do NOT consume or reuse it for
the k>=2 E[Sigma] re-architecture.

Key declarations: (bit-rotted GHR hierarchy: HierarchyDefs)
-/
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.TemporalClosure
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.DedekindZ.Cases
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.FormulaOps

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Separation Hierarchy Definitions: U/S-Type Predicates, Abstraction, and Junction-Depth Monotonicity

Single U/S-type predicates, Lemma 10.2.5 (single-U separability), U/S-formula
abstraction, semantic correctness, preservation lemmas, count properties, and
junction-depth monotonicity.
-/

#exit

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

For the `snce` case, we use `snce_separable` (temporal closure theorem)
applied to the inductively separable arguments.
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

-- [Removed: single_U_formula_separable, snce_single_U_top_level_separable,
--  single_U_neg_separable, single_U_or_separable, single_U_and_separable
--  These originally used the `snce_separable` axiom.
--  Replaced by single_U_formula_separable_no_oracle (oracle-free, later in file).]

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

The full hierarchy is now proved oracle-free, culminating in
`all_formulas_separable` which uses junction-depth induction.

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

-- [Removed: multi_U_formula_separable, two_U_types_separable, multi_U_neg_separable,
--  multi_U_or_separable, multi_U_and_separable
--  These used all_separable/snce_separable. Replaced by no_S_nested_sep (later in file).]

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

/-- Key theorem: abstracting S(A,B) from the U-argument that achieves
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


/-! ### GHR94-Faithful Strengthening: Separation preserving single U-type

GHR94 Lemma 10.2.5 states: "D is equivalent to a syntactically separated wff
in which U only appears as the formula U(A,B)." This is STRONGER than our
`is_separable`, which only guarantees existence of a separated equivalent
without constraining its U-type structure.

By proving this stronger claim, we eliminate the oracle from 10.2.5 entirely:
at snce_depth_of_U >= 2, the IH gives separated forms C', F' that PRESERVE
has_single_U_type. Box-normalizing and applying 10.2.4 directly works because
the `.snce C'' F''` retains the single U-type structure. -/

/-- Stronger separability: separated equivalent with preserved single U-type.
    This is the property guaranteed by GHR94 Lemma 10.2.5. -/
def is_separable_with_U_type (φ A B : Formula) : Prop :=
  ∃ ψ : Formula, is_syntactically_separated ψ = true ∧ int_equiv φ ψ ∧ has_single_U_type ψ A B

/-- is_separable_with_U_type implies is_separable. -/
theorem separable_with_type_imp_separable {φ A B : Formula}
    (h : is_separable_with_U_type φ A B) : is_separable φ := by
  obtain ⟨ψ, hsep, hequiv, _⟩ := h
  exact ⟨ψ, hsep, hequiv⟩

/-- Equivalence transfer for is_separable_with_U_type. -/
theorem is_separable_with_U_type_of_equiv {φ χ A B : Formula}
    (hequiv : int_equiv φ χ) (h : is_separable_with_U_type χ A B) :
    is_separable_with_U_type φ A B := by
  obtain ⟨ψ, hsep, hequiv2, hsingle⟩ := h
  exact ⟨ψ, hsep, int_equiv_trans hequiv hequiv2, hsingle⟩

/-- imp preserves is_separable_with_U_type. -/
theorem imp_separable_with_type {a b A B : Formula}
    (ha : is_separable_with_U_type a A B) (hb : is_separable_with_U_type b A B) :
    is_separable_with_U_type (.imp a b) A B := by
  obtain ⟨ψa, hsepa, hequiva, hsinglea⟩ := ha
  obtain ⟨ψb, hsepb, hequivb, hsingleb⟩ := hb
  exact ⟨.imp ψa ψb, by simp [is_syntactically_separated, hsepa, hsepb],
         fun M t => ⟨fun h hp => (hequivb M t).mp (h ((hequiva M t).mpr hp)),
                     fun h hp => (hequivb M t).mpr (h ((hequiva M t).mp hp))⟩,
         ⟨hsinglea, hsingleb⟩⟩

/-- U-free formulas are separable_with_U_type (vacuously). -/
theorem u_free_separable_with_type {φ A B : Formula} (h : is_U_free φ = true) :
    is_separable_with_U_type φ A B := by
  have hsep := separated_imp_separable φ (restricted_u_free_separated φ (has_no_allpast_allfuture_true φ) h)
  obtain ⟨ψ, hsep_ψ, hequiv⟩ := hsep
  -- The separated witness of a U-free formula is itself (identity equivalence works)
  exact ⟨φ, by {
    -- φ is U-free, so we need is_syntactically_separated φ
    -- Actually, φ might not be syntactically separated (could have .snce with non-U-free args)
    -- But wait, φ IS U-free, so every .snce in φ has U-free children (since all subformulas are U-free)
    -- And φ has no .untl (U-free), so .untl condition is vacuous
    -- So φ IS syntactically separated... only if has_no_allpast_allfuture
    -- Actually restricted_u_free_separated handles this
    exact restricted_u_free_separated φ (has_no_allpast_allfuture_true φ) h
  }, int_equiv_refl φ, u_free_has_single_U_type h⟩

/-- .untl A B with S-free args is separable_with_U_type. -/
theorem untl_s_free_separable_with_type {A B : Formula}
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true) :
    is_separable_with_U_type (.untl A B) A B := by
  exact ⟨.untl A B, by simp [is_syntactically_separated, hA_sf, hB_sf],
         int_equiv_refl _, has_single_U_type_untl A B⟩

/-! ### Combinators for is_separable_with_U_type -/

/-- or preserves is_separable_with_U_type. -/
theorem or_separable_with_U_type {a b A B : Formula}
    (ha : is_separable_with_U_type a A B) (hb : is_separable_with_U_type b A B) :
    is_separable_with_U_type (Formula.or a b) A B := by
  obtain ⟨ψa, hsepa, hequiva, hsinglea⟩ := ha
  obtain ⟨ψb, hsepb, hequivb, hsingleb⟩ := hb
  refine ⟨Formula.or ψa ψb, ?_, ?_, ?_⟩
  · simp [Formula.or, Formula.neg, is_syntactically_separated, hsepa, hsepb]
  · intro M t; constructor
    · intro h; rcases int_truth_or_iff.mp h with hp | hq
      · exact int_truth_or_iff.mpr (Or.inl ((hequiva M t).mp hp))
      · exact int_truth_or_iff.mpr (Or.inr ((hequivb M t).mp hq))
    · intro h; rcases int_truth_or_iff.mp h with hp | hq
      · exact int_truth_or_iff.mpr (Or.inl ((hequiva M t).mpr hp))
      · exact int_truth_or_iff.mpr (Or.inr ((hequivb M t).mpr hq))
  · exact has_single_U_type_or hsinglea hsingleb

/-- and preserves is_separable_with_U_type. -/
theorem and_separable_with_U_type {a b A B : Formula}
    (ha : is_separable_with_U_type a A B) (hb : is_separable_with_U_type b A B) :
    is_separable_with_U_type (Formula.and a b) A B := by
  obtain ⟨ψa, hsepa, hequiva, hsinglea⟩ := ha
  obtain ⟨ψb, hsepb, hequivb, hsingleb⟩ := hb
  refine ⟨Formula.and ψa ψb, and_separated hsepa hsepb, ?_, has_single_U_type_and hsinglea hsingleb⟩
  intro M t; constructor
  · intro h; rw [int_truth_and_iff] at h ⊢
    exact ⟨(hequiva M t).mp h.1, (hequivb M t).mp h.2⟩
  · intro h; rw [int_truth_and_iff] at h ⊢
    exact ⟨(hequiva M t).mpr h.1, (hequivb M t).mpr h.2⟩

/-- neg preserves is_separable_with_U_type. -/
theorem neg_separable_with_U_type {a A B : Formula}
    (ha : is_separable_with_U_type a A B) :
    is_separable_with_U_type (Formula.neg a) A B := by
  obtain ⟨ψa, hsepa, hequiva, hsinglea⟩ := ha
  refine ⟨Formula.neg ψa, neg_separated hsepa, ?_, has_single_U_type_neg hsinglea⟩
  intro M t; constructor
  · intro hn hp; exact hn ((hequiva M t).mpr hp)
  · intro hn hp; exact hn ((hequiva M t).mp hp)

/-! ### U-Type Argument Replacement Bridge

When a separated witness has `has_single_U_type ψ A' B'` but we need
`has_single_U_type _ A B`, this bridge replaces U-arguments while preserving
separation and semantic equivalence. Used when box-normalized types A', B'
(`replace_box_with_top A/B`) need to be converted back to the original A, B. -/

/-- Replace U-type arguments in a formula: every `.untl _ _` node gets new arguments
    `A_new B_new`. Only meaningful when `has_single_U_type ψ A_old B_old`. -/
def replace_untl_args (ψ A_new B_new : Formula) : Formula :=
  match ψ with
  | .atom a => .atom a
  | .bot => .bot
  | .imp p q => .imp (replace_untl_args p A_new B_new) (replace_untl_args q A_new B_new)
  | .box p => .box (replace_untl_args p A_new B_new)
  | .untl _ _ => .untl A_new B_new
  | .snce p q => .snce (replace_untl_args p A_new B_new) (replace_untl_args q A_new B_new)

/-- `replace_untl_args` produces `has_single_U_type _ A_new B_new`. -/
theorem replace_untl_args_has_single_U_type (ψ A_new B_new : Formula) :
    has_single_U_type (replace_untl_args ψ A_new B_new) A_new B_new := by
  induction ψ with
  | atom _ => exact trivial
  | bot => exact trivial
  | imp _ _ ih1 ih2 => exact ⟨ih1, ih2⟩
  | box _ ih => exact ih
  | untl _ _ => exact ⟨rfl, rfl⟩
  | snce _ _ ih1 ih2 => exact ⟨ih1, ih2⟩

/-- For U-free formulas, `replace_untl_args` is the identity. -/
theorem replace_untl_args_u_free_eq (ψ A_new B_new : Formula)
    (h : is_U_free ψ = true) : replace_untl_args ψ A_new B_new = ψ := by
  induction ψ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp [is_U_free] at h
    simp [replace_untl_args, ih1 h.1, ih2 h.2]
  | box _ ih =>
    simp [is_U_free] at h
    simp [replace_untl_args, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce _ _ ih1 ih2 =>
    simp [is_U_free] at h
    simp [replace_untl_args, ih1 h.1, ih2 h.2]

/-- `replace_untl_args` preserves `is_S_free` for `.untl` sub-arguments when the
    new arguments are S-free. -/
private theorem replace_untl_args_preserves_S_free (ψ A_new B_new : Formula)
    (h : is_S_free ψ = true) (hA : is_S_free A_new = true) (hB : is_S_free B_new = true) :
    is_S_free (replace_untl_args ψ A_new B_new) = true := by
  induction ψ with
  | atom _ => simp [replace_untl_args, is_S_free]
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp [is_S_free] at h; simp [replace_untl_args, is_S_free, ih1 h.1, ih2 h.2]
  | box _ ih =>
    simp [is_S_free] at h; simp [replace_untl_args, is_S_free, ih h]
  | untl _ _ =>
    simp [replace_untl_args, is_S_free, hA, hB]
  | snce _ _ => simp [is_S_free] at h

/-- `replace_untl_args` preserves `is_syntactically_separated`. -/
theorem replace_untl_args_preserves_separated (ψ A_new B_new : Formula)
    (h_sep : is_syntactically_separated ψ = true)
    (hA_sf : is_S_free A_new = true) (hB_sf : is_S_free B_new = true) :
    is_syntactically_separated (replace_untl_args ψ A_new B_new) = true := by
  induction ψ with
  | atom _ => simp [replace_untl_args, is_syntactically_separated]
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp [is_syntactically_separated] at h_sep
    simp [replace_untl_args, is_syntactically_separated, ih1 h_sep.1, ih2 h_sep.2]
  | box _ => simp [replace_untl_args, is_syntactically_separated]
  | untl _ _ =>
    simp [replace_untl_args, is_syntactically_separated, hA_sf, hB_sf]
  | snce p q ih1 ih2 =>
    simp [is_syntactically_separated] at h_sep
    -- snce case: args must be U-free, replace_untl_args on U-free formulas is identity
    simp only [replace_untl_args, is_syntactically_separated]
    rw [replace_untl_args_u_free_eq p A_new B_new h_sep.1,
        replace_untl_args_u_free_eq q A_new B_new h_sep.2]
    simp [h_sep.1, h_sep.2]

/-- `replace_untl_args` preserves `int_equiv` when `has_single_U_type ψ A_old B_old`
    and `int_equiv A_old A_new` and `int_equiv B_old B_new`. -/
theorem replace_untl_args_equiv (ψ A_old B_old A_new B_new : Formula)
    (h_single : has_single_U_type ψ A_old B_old)
    (hA_equiv : int_equiv A_old A_new) (hB_equiv : int_equiv B_old B_new) :
    int_equiv ψ (replace_untl_args ψ A_new B_new) := by
  induction ψ with
  | atom _ => intro M t; rfl
  | bot => intro M t; rfl
  | imp p q ih1 ih2 =>
    obtain ⟨h1, h2⟩ := h_single
    intro M t; simp only [replace_untl_args, int_truth]
    exact Iff.imp (ih1 h1 M t) (ih2 h2 M t)
  | box _ ih =>
    intro M t; simp only [replace_untl_args, int_truth]
  | untl p q =>
    obtain ⟨hp, hq⟩ := h_single
    subst hp; subst hq
    intro M t; simp only [replace_untl_args, int_truth]
    constructor
    · rintro ⟨s, hts, h1, h2⟩
      exact ⟨s, hts, (hA_equiv M s).mp h1,
        fun r hr1 hr2 => (hB_equiv M r).mp (h2 r hr1 hr2)⟩
    · rintro ⟨s, hts, h1, h2⟩
      exact ⟨s, hts, (hA_equiv M s).mpr h1,
        fun r hr1 hr2 => (hB_equiv M r).mpr (h2 r hr1 hr2)⟩
  | snce p q ih1 ih2 =>
    obtain ⟨h1, h2⟩ := h_single
    intro M t; simp only [replace_untl_args, int_truth]
    constructor
    · rintro ⟨s, hst, h1', h2'⟩
      exact ⟨s, hst, (ih1 h1 M s).mp h1',
        fun r hr1 hr2 => (ih2 h2 M r).mp (h2' r hr1 hr2)⟩
    · rintro ⟨s, hst, h1', h2'⟩
      exact ⟨s, hst, (ih1 h1 M s).mpr h1',
        fun r hr1 hr2 => (ih2 h2 M r).mpr (h2' r hr1 hr2)⟩

/-- Bridge lemma: convert `is_separable_with_U_type φ A' B'` to
    `is_separable_with_U_type φ A B` given `int_equiv A A'`, `int_equiv B B'`,
    and S-freeness of A, B. -/
theorem is_separable_with_U_type_replace_args {φ A A' B B' : Formula}
    (h : is_separable_with_U_type φ A' B')
    (hA_equiv : int_equiv A A') (hB_equiv : int_equiv B B')
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true) :
    is_separable_with_U_type φ A B := by
  obtain ⟨ψ, h_sep, h_equiv, h_single⟩ := h
  exact ⟨replace_untl_args ψ A B,
    replace_untl_args_preserves_separated ψ A B h_sep hA_sf hB_sf,
    int_equiv_trans h_equiv (replace_untl_args_equiv ψ A' B' A B h_single
      (int_equiv_symm hA_equiv) (int_equiv_symm hB_equiv)),
    replace_untl_args_has_single_U_type ψ A B⟩

end Bimodal.Metalogic.WeakCanonical.Separation
