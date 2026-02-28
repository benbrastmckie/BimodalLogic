/-!
# BONEYARD: Archived from TemporalCoherentConstruction.lean (Task 932, 2026-02-25)

## WHY THIS IS HERE
These definitions implement temporal saturation predicates and a constant-family
bundle structure for temporal saturation. The approach is fundamentally flawed because
constant families cannot satisfy temporal coherence (forward_F, backward_P).

## THE FLAWED APPROACH
TemporalEvalSaturatedBundle requires F(psi)->psi and P(psi)->psi within a SINGLE MCS.
This is impossible for consistent sets like {F(psi), neg(psi)}.
Counterexample: {F(psi), neg(psi)} is consistent but cannot be temporally saturated.

## DO NOT RESURRECT
- Do NOT use TemporalForwardSaturated/TemporalBackwardSaturated for constant family construction
- Do NOT use TemporalEvalSaturatedBundle structure
- Do NOT assume a single MCS can be both consistent and temporally saturated

## ALSO ARCHIVED
- temporal_coherent_family_exists (generic D version) - sorry-backed, only Int is instantiated
- construct_temporal_bfmcs (uses deprecated singleFamilyBFMCS wrapper)
- construct_saturated_bfmcs (polymorphic, uses deprecated fully_saturated_bfmcs_exists axiom)
- fully_saturated_bfmcs_exists (deprecated polymorphic AXIOM - use _int version instead)

## SEE ALSO
- specs/932_remove_constant_witness_family_metalogic/reports/ (research-001 through research-004)
- specs/843_*/reports/research-016.md - Analysis of false single-family axiom
-/

-- Original definitions from TemporalCoherentConstruction.lean:

/-
-- =================================================================
-- Temporal Saturation Predicates (lines 315-328)
-- =================================================================

def TemporalForwardSaturated (M : Set Formula) : Prop :=
  forall psi : Formula, Formula.some_future psi in M -> psi in M

def TemporalBackwardSaturated (M : Set Formula) : Prop :=
  forall psi : Formula, Formula.some_past psi in M -> psi in M

def TemporallySaturated (M : Set Formula) : Prop :=
  TemporalForwardSaturated M /\ TemporalBackwardSaturated M

-- =================================================================
-- TemporalEvalSaturatedBundle Structure (lines 338-386)
-- =================================================================

structure TemporalEvalSaturatedBundle (D : Type*) [Preorder D] where
  baseMCS : Set Formula
  is_mcs : SetMaximalConsistent baseMCS
  forward_saturated : TemporalForwardSaturated baseMCS
  backward_saturated : TemporalBackwardSaturated baseMCS

noncomputable def TemporalEvalSaturatedBundle.toFMCS ...
lemma TemporalEvalSaturatedBundle.toFMCS_constant ...
noncomputable def TemporalEvalSaturatedBundle.toTemporalCoherentFamily ...

-- =================================================================
-- Generic D temporal_coherent_family_exists (lines 605-611)
-- =================================================================

theorem temporal_coherent_family_exists (D : Type*) [Preorder D] [Zero D]
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (fam : FMCS D), ... := by sorry

-- =================================================================
-- construct_temporal_bfmcs (lines 635-678)
-- Uses singleFamilyBFMCS (also archived from Construction.lean)
-- =================================================================

noncomputable def construct_temporal_bfmcs ...
lemma construct_temporal_bfmcs_eval_eq ...
theorem construct_temporal_bfmcs_contains_context ...
theorem construct_temporal_bfmcs_temporally_coherent ...

-- =================================================================
-- Deprecated polymorphic axiom (lines 752-758)
-- =================================================================

axiom fully_saturated_bfmcs_exists (D : Type*) [Preorder D] [Zero D]
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS D), ... /\ B.temporally_coherent /\ is_modally_saturated B

-- =================================================================
-- Polymorphic construct_saturated_bfmcs (lines 844-868)
-- Uses the deprecated axiom
-- =================================================================

noncomputable def construct_saturated_bfmcs ...
theorem construct_saturated_bfmcs_contains_context ...
theorem construct_saturated_bfmcs_temporally_coherent ...
theorem construct_saturated_bfmcs_is_modally_saturated ...
-/
