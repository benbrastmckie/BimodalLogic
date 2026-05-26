import Bimodal.Metalogic.WeakCanonical.ExpressiveCompleteness.QuantifierElimination

/-!
# Expressive Completeness Theorem (Theorem 10.2.10)

Core expressiveness lemma and final Theorem 10.2.10 linking FO-definability
to temporal definability. Every property expressible in monadic first-order
logic over (Z, <) is expressible by a temporal formula using Since and Until.

## Main Results

- `separation_implies_expressiveness` (Theorem 9.3.1): If every temporal
  formula is equivalent to a separated formula, then {U,S} is expressively
  complete.
- `US_expressively_complete_over_Z` (Theorem 10.2.10): {U,S} is expressively
  complete over integer time.

## References

- GHR94, Chapter 9, Section 9.3, Theorem 9.3.1
- GHR94, Theorem 10.2.10
- Reynolds (2010), Theorem 5
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ### Core Expressiveness Lemma

The proof uses nested induction: outer strong induction on quantifier depth,
inner structural recursion on the formula. The quantifier-free cases are handled
by structural recursion. The quantifier cases use the outer IH at lower depth
with the extended signature, then apply atom elimination.

The `atomMap_base` parameter tracks the base string used for atomMap construction,
enabling disjointness proofs between atomMap and freshAM at each level. -/

/-- Helper: derive injectivity from the mk_fresh form. -/
private theorem mk_fresh_atomMap_inj {sig : MonadicSignature} (base : String) :
    Function.Injective (fun p : sig.preds => Atom.mk_fresh base (Fintype.equivFin sig.preds p).val) := by
  intro a b hab
  have := Atom.mk_fresh_injective base hab
  exact (Fintype.equivFin sig.preds).injective (Fin.ext (Nat.cast_injective this))

/-- Helper: Atom.mk_fresh with different base strings gives different atoms. -/
private theorem mk_fresh_base_ne {s1 s2 : String} (h : s1 ≠ s2) (n m : Nat) :
    Atom.mk_fresh s1 n ≠ Atom.mk_fresh s2 m := by
  intro heq
  simp only [Atom.mk_fresh, Atom.mk.injEq] at heq
  exact h heq.1

/-- Inner structural recursion: handles quantifier-free cases directly and
    delegates quantifier cases to the outer WF IH.

    Each atomMap is of the form `fun p => mk_fresh atomMap_base (equivFin p).val`,
    which ensures disjointness from freshAM at each level (different base strings).
    The output includes atom containment: all atoms of A are in atomMap's image. -/
private noncomputable def expressiveness_inner
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (m : Nat)
    (outerIH : ∀ k < m, ∀ (sig' : MonadicSignature)
      (atomMap' : sig'.preds → Atom) (atomMap_base' : String),
      (∀ p, atomMap' p = Atom.mk_fresh atomMap_base' (Fintype.equivFin sig'.preds p).val) →
      atomMap_base' ≠ "e" ++ toString (Fintype.card sig'.preds) →
      ∀ (psi' : MonadicFormula sig' 1), psi'.quantifier_depth ≤ k →
      { A : Formula //
        (∀ (M : IntStructureFromSig sig') (t : Int),
          eval (int_to_ordered sig' M) (fun _ => t) psi' ↔
          Separation.int_truth (to_int_struct M atomMap') t A) ∧
        (Separation.formula_atoms A ⊆ Set.range atomMap') })
    (sig : MonadicSignature)
    (atomMap : sig.preds → Atom) (atomMap_base : String)
    (h_am_form : ∀ p, atomMap p = Atom.mk_fresh atomMap_base (Fintype.equivFin sig.preds p).val)
    (h_base_ne : atomMap_base ≠ "e" ++ toString (Fintype.card sig.preds)) :
    (psi : MonadicFormula sig 1) → (hm : psi.quantifier_depth ≤ m) →
    { A : Formula //
      (∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A) ∧
      (Separation.formula_atoms A ⊆ Set.range atomMap) }
  | .atom p _, _ =>
    ⟨Formula.atom (atomMap p), ⟨fun M t => by
      have hinj : Function.Injective atomMap := by
        intro a b hab; rw [h_am_form a, h_am_form b] at hab
        exact mk_fresh_atomMap_inj atomMap_base |>.eq_iff.mp (by rw [← h_am_form a, ← h_am_form b]; exact hab)
      simp only [eval, Separation.int_truth, to_int_struct, Set.mem_setOf_eq]
      exact ⟨fun h => ⟨p, rfl, h⟩, fun ⟨q, hq, hi⟩ => hinj hq ▸ hi⟩,
    fun a ha => by
      simp only [Separation.formula_atoms, Set.mem_singleton_iff] at ha
      exact ⟨p, ha.symm⟩⟩⟩
  | .lt _ _, _ =>
    ⟨Formula.bot, ⟨fun M t => by
      simp only [eval, Separation.int_truth]
      exact ⟨fun h => absurd h (lt_irrefl _), False.elim⟩,
    fun a ha => by simp [Separation.formula_atoms] at ha⟩⟩
  | .not alpha, hm =>
    have hm' : alpha.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; exact hm
    let ihA := expressiveness_inner h_sep m outerIH sig atomMap atomMap_base h_am_form alpha hm'
    ⟨Formula.neg ihA.val, ⟨fun M t => by
      simp only [eval, Separation.int_truth, Formula.neg]
      exact ⟨fun h hAt => h (ihA.property.1 M t |>.mpr hAt),
             fun h ha => h (ihA.property.1 M t |>.mp ha)⟩,
    fun a ha => by
      simp only [Formula.neg, Separation.formula_atoms, Set.mem_union, Set.mem_empty_iff_false,
                 or_false] at ha
      exact ihA.property.2 ha⟩⟩
  | .and alpha beta, hm =>
    have hm_a : alpha.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have hm_b : beta.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    let ihA := expressiveness_inner h_sep m outerIH sig atomMap atomMap_base h_am_form alpha hm_a
    let ihB := expressiveness_inner h_sep m outerIH sig atomMap atomMap_base h_am_form beta hm_b
    ⟨Formula.and ihA.val ihB.val, ⟨fun M t => by
      have hA := ihA.property.1 M t; have hB := ihB.property.1 M t
      simp only [eval]; rw [Separation.int_truth_and_iff]
      exact ⟨fun ⟨ha, hb⟩ => ⟨hA.mp ha, hB.mp hb⟩,
             fun ⟨ha, hb⟩ => ⟨hA.mpr ha, hB.mpr hb⟩⟩,
    fun a ha => by
      simp only [Formula.and, Separation.formula_atoms, Set.mem_union] at ha
      rcases ha with ha | ha
      · exact ihA.property.2 ha
      · exact ihB.property.2 ha⟩⟩
  | .ex alpha, hm =>
    have h_lt_m : alpha.quantifier_depth < m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have h_red_depth : (reduceElimLast 1 alpha).quantifier_depth ≤ alpha.quantifier_depth :=
      qdepth_reduceElimLast_le 1 Nat.zero_lt_one alpha
    have hinj : Function.Injective atomMap := by
      intro a b hab; rw [h_am_form a, h_am_form b] at hab
      exact mk_fresh_atomMap_inj atomMap_base |>.eq_iff.mp (by rw [← h_am_form a, ← h_am_form b]; exact hab)
    -- Construct freshAM with a base string encoding the signature size
    let freshBase := "e" ++ toString (Fintype.card sig.preds)
    let freshAM : (extSignature sig).preds → Atom :=
      fun ep => Atom.mk_fresh freshBase (Fintype.equivFin (extSignature sig).preds ep).val
    have freshAM_inj : Function.Injective freshAM := mk_fresh_atomMap_inj freshBase
    have h_fm_form : ∀ ep, freshAM ep =
        Atom.mk_fresh freshBase (Fintype.equivFin (extSignature sig).preds ep).val :=
      fun _ => rfl
    -- h_base_ne for the recursive call: freshBase ≠ "e" ++ toString (card (extSignature sig).preds)
    -- This holds because card (extSignature sig).preds = card (ExtPred sig) = 2 * card sig.preds + 2 ≠ card sig.preds
    have h_base_ne_rec : freshBase ≠ "e" ++ toString (Fintype.card (extSignature sig).preds) := by
      intro heq
      simp only [freshBase] at heq
      have := String.append_left_cancel heq
      have h_ne : Fintype.card sig.preds ≠ Fintype.card (extSignature sig).preds := by
        intro hcard
        -- card (ExtPred sig) = 2 * card sig.preds + 2, which is > card sig.preds
        simp only [extSignature] at hcard
        omega
      exact h_ne (Nat.repr_injective this)
    -- Apply outer IH at lower depth with freshAM
    let ihExt := outerIH alpha.quantifier_depth h_lt_m
      (extSignature sig) freshAM freshBase h_fm_form h_base_ne_rec
      (reduceElimLast 1 alpha) (le_trans h_red_depth (le_refl _))
    let A_ext := ihExt.val
    -- Use atom-preserving separation for B_sep
    let h_ps := Separation.proper_separation_preserves_atoms (q_exists A_ext)
    let B_sep := h_ps.choose
    have hB_sep := h_ps.choose_spec.1
    have hB_equiv := h_ps.choose_spec.2.1
    have hB_atom_sub := h_ps.choose_spec.2.2
    -- Derive hB_atoms: atoms of B_sep ⊆ range freshAM
    have hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM := by
      intro a ha
      have ha_qe := hB_atom_sub ha
      -- formula_atoms (q_exists A_ext) ⊆ formula_atoms A_ext
      -- (q_exists unfolds to or/neg/all_past/all_future which just union atoms of A_ext)
      -- and formula_atoms A_ext ⊆ range freshAM by IH
      have hA_atoms := ihExt.property.2
      -- Need to show: formula_atoms (q_exists A_ext) ⊆ range freshAM
      -- q_exists A_ext = or(or(some_past(A_ext), A_ext), some_future(A_ext))
      -- Atoms of q_exists A_ext = atoms of A_ext
      simp only [q_exists, Formula.or, Formula.some_past, Formula.some_future, Formula.neg,
                 Separation.formula_atoms, Set.union_empty, Set.empty_union] at ha_qe
      -- After simp, ha_qe should reduce to something involving formula_atoms A_ext
      exact hA_atoms (by tauto)
    -- Prove h_disj: atomMap and freshAM have disjoint ranges (using h_base_ne)
    have h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep := by
      intro p ep
      rw [h_am_form p]
      exact mk_fresh_base_ne h_base_ne _ _
    -- Build the quantifier elimination formula
    let A := quantElimFormula atomMap freshAM B_sep
    ⟨A, ⟨fun M t => by
      simp only [eval]
      let M_ext := to_int_struct (extIntStruct M t) freshAM
      have h_chain : (∃ z : ℤ, eval (int_to_ordered sig M) (Fin.cons z fun _ => t) alpha) ↔
          Separation.int_truth M_ext t B_sep := by
        constructor
        · intro ⟨z, hz⟩
          have h1 := (reduceElimLast_correct_at_one alpha M z t).mp hz
          have h2 := (ihExt.property.1 (extIntStruct M t) z).mp h1
          have h3 := (q_exists_correct A_ext M_ext t).mpr ⟨z, h2⟩
          exact (hB_equiv M_ext t).mp h3
        · intro h_bsep
          have h1 := (hB_equiv M_ext t).mpr h_bsep
          obtain ⟨z, hz⟩ := (q_exists_correct A_ext M_ext t).mp h1
          exact ⟨z, (reduceElimLast_correct_at_one alpha M z t).mpr
            ((ihExt.property.1 (extIntStruct M t) z).mpr hz)⟩
      exact h_chain.trans (atom_elim_correct atomMap hinj freshAM freshAM_inj h_disj M t B_sep hB_sep hB_atoms),
    -- Atom containment for quantElimFormula
    fun a ha => formula_atoms_quantElimFormula_subset atomMap freshAM freshAM_inj h_disj B_sep hB_atoms ha⟩⟩
  | .all alpha, hm =>
    have h_lt_m : alpha.quantifier_depth < m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have h_red_depth : (reduceElimLast 1 (.not alpha)).quantifier_depth ≤ alpha.quantifier_depth := by
      have := qdepth_reduceElimLast_le 1 Nat.zero_lt_one (MonadicFormula.not alpha)
      simp [MonadicFormula.quantifier_depth] at this; exact this
    have hinj : Function.Injective atomMap := by
      intro a b hab; rw [h_am_form a, h_am_form b] at hab
      exact mk_fresh_atomMap_inj atomMap_base |>.eq_iff.mp (by rw [← h_am_form a, ← h_am_form b]; exact hab)
    let freshBase := "e" ++ toString (Fintype.card sig.preds)
    let freshAM : (extSignature sig).preds → Atom :=
      fun ep => Atom.mk_fresh freshBase (Fintype.equivFin (extSignature sig).preds ep).val
    have freshAM_inj : Function.Injective freshAM := mk_fresh_atomMap_inj freshBase
    have h_fm_form : ∀ ep, freshAM ep =
        Atom.mk_fresh freshBase (Fintype.equivFin (extSignature sig).preds ep).val :=
      fun _ => rfl
    have h_base_ne_rec : freshBase ≠ "e" ++ toString (Fintype.card (extSignature sig).preds) := by
      intro heq
      simp only [freshBase] at heq
      have := String.append_left_cancel heq
      have h_ne : Fintype.card sig.preds ≠ Fintype.card (extSignature sig).preds := by
        simp only [extSignature]; omega
      exact h_ne (Nat.repr_injective this)
    let ihExt := outerIH alpha.quantifier_depth h_lt_m
      (extSignature sig) freshAM freshBase h_fm_form h_base_ne_rec
      (reduceElimLast 1 (.not alpha)) (le_trans h_red_depth (le_refl _))
    let A_neg_ext := ihExt.val
    let h_ps := Separation.proper_separation_preserves_atoms (q_exists A_neg_ext)
    let B_sep := h_ps.choose
    have hB_equiv := h_ps.choose_spec.2.1
    have hB_atom_sub := h_ps.choose_spec.2.2
    have hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM := by
      intro a ha
      have ha_qe := hB_atom_sub ha
      have hA_atoms := ihExt.property.2
      simp only [q_exists, Formula.or, Formula.some_past, Formula.some_future, Formula.neg,
                 Separation.formula_atoms, Set.union_empty, Set.empty_union] at ha_qe
      exact hA_atoms (by tauto)
    have h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep := by
      intro p ep
      rw [h_am_form p]
      exact mk_fresh_base_ne h_base_ne _ _
    let A_ex := quantElimFormula atomMap freshAM B_sep
    ⟨Formula.neg A_ex, ⟨fun M t => by
      simp only [eval]
      rw [Separation.int_truth_neg_iff]
      let M_ext := to_int_struct (extIntStruct M t) freshAM
      have h_chain_neg : (∃ z : ℤ, ¬eval (int_to_ordered sig M) (Fin.cons z fun _ => t) alpha) ↔
          Separation.int_truth M_ext t B_sep := by
        constructor
        · intro ⟨z, hz⟩
          have h1 : eval (int_to_ordered sig M) (Fin.cons z fun _ => t) (.not alpha) := hz
          have h2 := (reduceElimLast_correct_at_one (.not alpha) M z t).mp h1
          have h3 := (ihExt.property.1 (extIntStruct M t) z).mp h2
          exact (hB_equiv M_ext t).mp ((q_exists_correct A_neg_ext M_ext t).mpr ⟨z, h3⟩)
        · intro h_bsep
          obtain ⟨z, hz⟩ := (q_exists_correct A_neg_ext M_ext t).mp
            ((hB_equiv M_ext t).mpr h_bsep)
          have h1 := (ihExt.property.1 (extIntStruct M t) z).mpr hz
          have h2 := (reduceElimLast_correct_at_one (.not alpha) M z t).mpr h1
          exact ⟨z, h2⟩
      have h_elim : Separation.int_truth M_ext t B_sep ↔
          Separation.int_truth (to_int_struct M atomMap) t A_ex :=
        atom_elim_correct atomMap hinj freshAM freshAM_inj h_disj M t B_sep h_ps.choose_spec.1 hB_atoms
      constructor
      · intro h_all h_Aex
        have h_bsep := h_elim.mpr h_Aex
        obtain ⟨z, hz⟩ := h_chain_neg.mpr h_bsep
        exact hz (h_all z)
      · intro h_neg z
        by_contra h_not
        have h_bsep := h_chain_neg.mp ⟨z, h_not⟩
        exact h_neg (h_elim.mp h_bsep),
    -- Atom containment for neg A_ex
    fun a ha => by
      simp only [Formula.neg, Separation.formula_atoms, Set.mem_union, Set.mem_empty_iff_false,
                 or_false] at ha
      exact formula_atoms_quantElimFormula_subset atomMap freshAM freshAM_inj h_disj B_sep hB_atoms ha⟩⟩

/-- Outer well-founded recursion: proves the expressiveness lemma by strong induction
    on quantifier depth with atom containment tracking. -/
private noncomputable def expressiveness_wf
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (m : Nat) (sig : MonadicSignature)
    (atomMap : sig.preds → Atom) (atomMap_base : String)
    (h_am_form : ∀ p, atomMap p = Atom.mk_fresh atomMap_base (Fintype.equivFin sig.preds p).val)
    (h_base_ne : atomMap_base ≠ "e" ++ toString (Fintype.card sig.preds))
    (psi : MonadicFormula sig 1) (hm : psi.quantifier_depth ≤ m) :
    { A : Formula //
      (∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A) ∧
      (Separation.formula_atoms A ⊆ Set.range atomMap) } :=
  m.strongRecOn
    (motive := fun m => ∀ (sig : MonadicSignature)
      (atomMap : sig.preds → Atom) (atomMap_base : String),
      (∀ p, atomMap p = Atom.mk_fresh atomMap_base (Fintype.equivFin sig.preds p).val) →
      atomMap_base ≠ "e" ++ toString (Fintype.card sig.preds) →
      ∀ (psi : MonadicFormula sig 1), psi.quantifier_depth ≤ m →
      { A : Formula //
        (∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A) ∧
        (Separation.formula_atoms A ⊆ Set.range atomMap) })
    (fun m ih => expressiveness_inner h_sep m ih)
    sig atomMap atomMap_base h_am_form h_base_ne psi hm

/-- Core lemma: for a FIXED injective atomMap of mk_fresh form, every MonadicFormula sig 1
    has a temporal equivalent (Theorem 9.3.1, GHR94). -/
private noncomputable def expressiveness_fixed_atomMap
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (sig : MonadicSignature) (atomMap : sig.preds → Atom)
    (atomMap_base : String)
    (h_am_form : ∀ p, atomMap p = Atom.mk_fresh atomMap_base (Fintype.equivFin sig.preds p).val)
    (h_base_ne : atomMap_base ≠ "e" ++ toString (Fintype.card sig.preds))
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      (∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A) ∧
      (Separation.formula_atoms A ⊆ Set.range atomMap) } :=
  expressiveness_wf h_sep psi.quantifier_depth sig atomMap atomMap_base h_am_form h_base_ne psi (le_refl _)

theorem separation_implies_expressiveness
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi) :
    ∀ (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      ∃ (A : Formula) (atomMap : sig.preds -> Atom),
        ∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A := by
  intro sig psi
  let atomMap : sig.preds -> Bimodal.Syntax.Atom :=
    fun q => Bimodal.Syntax.Atom.mk_fresh "p" (Fintype.equivFin sig.preds q).val
  have h_am_form : ∀ p, atomMap p =
      Bimodal.Syntax.Atom.mk_fresh "p" (Fintype.equivFin sig.preds p).val :=
    fun _ => rfl
  have h_base_ne : "p" ≠ "e" ++ toString (Fintype.card sig.preds) := by
    exact fun h => by have := congrArg (fun s => s.toList.head!) h; simp at this; exact absurd this (by decide)
  exact ⟨(expressiveness_fixed_atomMap h_sep sig atomMap "p" h_am_form h_base_ne psi).val,
         atomMap,
         (expressiveness_fixed_atomMap h_sep sig atomMap "p" h_am_form h_base_ne psi).property.1⟩

/-! ## Theorem 10.2.10: The Final Result -/

/-- Theorem 10.2.10 (GHR94): The language {U, S} is expressively complete
    over integer time.

    Combines the Proper Separation Theorem (10.2.9, strong form) with
    Theorem 9.3.1. The proper separation ensures semantic purity of the
    decomposition, which is required for the substitution step. -/
theorem US_expressively_complete_over_Z :
    ∀ (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      ∃ (A : Formula) (atomMap : sig.preds → Atom),
        ∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A :=
  separation_implies_expressiveness (fun phi => proper_separation_theorem_int phi)

end Bimodal.Metalogic.WeakCanonical
