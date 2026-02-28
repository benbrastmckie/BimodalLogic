/-!
# BONEYARD: Archived from Construction.lean (Task 932, 2026-02-25)

## WHY THIS IS HERE
singleFamilyBFMCS wraps a single FMCS into a BFMCS, but the modal_backward field
uses sorry because single-family modal backward (phi in MCS -> Box phi in MCS) is
NOT provable from first principles. This definition is deprecated in favor of the
multi-family construction via fully_saturated_bfmcs_exists_int.

## THE FLAWED APPROACH
Single-family modal backward requires: if phi is in the ONLY family's MCS at time t,
then Box phi is in that MCS. This is equivalent to phi -> Box phi, which is FALSE
in general modal logic.

## DO NOT RESURRECT
- Do NOT use singleFamilyBFMCS for new BFMCS constructions
- Do NOT try to prove modal_backward for single-family BFMCS
- Use multi-family constructions with modal saturation instead

## SEE ALSO
- ModalSaturation.lean - saturated_modal_backward (the correct approach)
- TemporalCoherentConstruction.lean - construct_saturated_bfmcs_int (the replacement)
- specs/905_*/reports/ - Analysis of the false single-family axiom
-/

-- Original definitions from Construction.lean (lines 177-204):

/-
noncomputable def singleFamilyBFMCS (fam : FMCS D) : BFMCS D where
  families := {fam}
  nonempty := ⟨fam, Set.mem_singleton fam⟩
  modal_forward := fun fam' hfam' phi t hBox fam'' hfam'' =>
    have h_eq' : fam' = fam := Set.mem_singleton_iff.mp hfam'
    have h_eq'' : fam'' = fam := Set.mem_singleton_iff.mp hfam''
    let h_mcs := fam.is_mcs t
    let h_T := DerivationTree.axiom []
      ((Formula.box phi).imp phi) (Axiom.modal_t phi)
    let h_T_in_mcs := theorem_in_mcs h_mcs h_T
    h_eq'' ▸ set_mcs_implication_property h_mcs h_T_in_mcs (h_eq' ▸ hBox)
  modal_backward := fun _fam' _hfam' _phi _t _h_all =>
    sorry  -- NOT PROVABLE: single-family modal backward is false
  eval_family := fam
  eval_family_mem := Set.mem_singleton fam

lemma singleFamilyBFMCS_eval_family_eq (fam : FMCS D) :
    (singleFamilyBFMCS fam (D := D)).eval_family = fam := rfl
-/
