/-!
# BONEYARD: Archived from ModalSaturation.lean (Task 932, 2026-02-25)

## WHY THIS IS HERE
These definitions implement the constant witness family approach, which is fundamentally flawed.

## THE FLAWED APPROACH
The constant witness family pattern (mapping all time points to the SAME MCS) cannot satisfy
temporal coherence requirements (forward_F, backward_P). Counterexample: {F(psi), neg(psi)}
is consistent but violates F(psi)->psi required for temporal saturation.

## DO NOT RESURRECT
- Do NOT copy these definitions back into active code
- Do NOT use constant witness families for modal saturation in Int-indexed BFMCS
- The constructWitnessFamily approach is only valid when temporal coherence is not needed

## WHAT WENT WRONG
constantWitnessFamily maps every time point to the same MCS. While this trivially satisfies
forward_G and backward_H (via T-axioms), the resulting family cannot participate in
temporal saturation because a single MCS cannot contain both F(psi) and psi for every
F-obligation.

## SEE ALSO
- specs/932_remove_constant_witness_family_metalogic/reports/ (research-001 through research-004)
-/

-- Original definitions from ModalSaturation.lean (lines 225-288):

/-
noncomputable def extendToMCS (psi : Formula) (h_cons : SetConsistent {psi}) :
    Set Formula :=
  Classical.choose (set_lindenbaum {psi} h_cons)

lemma extendToMCS_contains (psi : Formula) (h_cons : SetConsistent {psi}) :
    psi ∈ extendToMCS psi h_cons :=
  (Classical.choose_spec (set_lindenbaum {psi} h_cons)).1 (Set.mem_singleton psi)

lemma extendToMCS_is_mcs (psi : Formula) (h_cons : SetConsistent {psi}) :
    SetMaximalConsistent (extendToMCS psi h_cons) :=
  (Classical.choose_spec (set_lindenbaum {psi} h_cons)).2

noncomputable def constantWitnessFamily (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    FMCS D where
  mcs := fun _ => M
  is_mcs := fun _ => h_mcs
  forward_G := fun t t' phi _ hG =>
    let h_T := DerivationTree.axiom []
      (phi.all_future.imp phi) (Axiom.temp_t_future phi)
    let h_T_in_M := theorem_in_mcs h_mcs h_T
    set_mcs_implication_property h_mcs h_T_in_M hG
  backward_H := fun t t' phi _ hH =>
    let h_T := DerivationTree.axiom []
      (phi.all_past.imp phi) (Axiom.temp_t_past phi)
    let h_T_in_M := theorem_in_mcs h_mcs h_T
    set_mcs_implication_property h_mcs h_T_in_M hH

lemma constantWitnessFamily_mcs_eq (M : Set Formula) (h_mcs : SetMaximalConsistent M) (t : D) :
    (constantWitnessFamily M h_mcs (D := D)).mcs t = M := rfl

noncomputable def constructWitnessFamily (psi : Formula) (h_cons : SetConsistent {psi}) :
    FMCS D :=
  let M := extendToMCS psi h_cons
  let h_mcs := extendToMCS_is_mcs psi h_cons
  constantWitnessFamily M h_mcs

lemma constructWitnessFamily_contains (psi : Formula) (h_cons : SetConsistent {psi}) (t : D) :
    psi ∈ (constructWitnessFamily psi h_cons (D := D)).mcs t := by
  simp only [constructWitnessFamily, constantWitnessFamily_mcs_eq]
  exact extendToMCS_contains psi h_cons
-/
