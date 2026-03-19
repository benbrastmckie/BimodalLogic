import Bimodal.Metalogic.Bundle.ClosedFlagBundle
import Bimodal.Metalogic.Bundle.ChainFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.BFMCS

/-!
# FlagBFMCS: Flag-Indexed Bimodal Bundle (Task 1003)

This module defines `FlagBFMCS`, a bundle structure for bimodal completeness that
indexes families by Flags (maximal chains) rather than using a fixed common domain.

## Overview

The key insight from task 1003 research is that achieving modal saturation in BFMCS
requires families with genuinely different `mcs` functions. However, temporal coherence
(forward_G, backward_H) combined with the absence of G-T axioms makes this impossible
with any shared common domain. FlagBFMCS resolves this by:

1. Each Flag provides a `chainFMCS` with its own domain (ChainFMCSDomain flag)
2. Modal accessibility connects corresponding positions across Flags
3. Temporal coherence is maintained per-Flag via the existing chainFMCS infrastructure
4. Modal saturation is ensured via `closedFlags_closed_under_witnesses`

## Semantics

A **bimodal world** in FlagBFMCS is a (Flag, element) pair where:
- The Flag represents a complete temporal timeline
- The element is a position within that timeline (an MCS in the Flag)

**Modal accessibility**: (F, x) R (F', x') iff BoxContent(x.world) ⊆ BoxContent(x'.world)
**Temporal accessibility**: Within each Flag, via the chainFMCS preorder

## Main Definitions

- `FlagBFMCS`: The Flag-indexed bundle structure
- `canonicalFlagBFMCS`: Construction using closedFlags
- Accessors for MCS at (Flag, element) positions

## References

- Task 1003 team research: specs/1003_implement_modal_coherence/reports/04_team-research.md
- ClosedFlagBundle.lean: closedFlags, closedFlags_closed_under_witnesses
- ChainFMCS.lean: chainFMCS, ChainFMCSDomain
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## FlagBFMCS Structure Definition
-/

/--
A Flag-indexed Bundle of Maximal Consistent Sets (FlagBFMCS).

Unlike BFMCS which requires a fixed common domain D, FlagBFMCS bundles Flags
directly, where each Flag has its own domain type `ChainFMCSDomain flag`.

**Key Properties**:
- `flags`: A set of Flags (maximal chains in CanonicalMCS)
- `flags_nonempty`: The flag set is non-empty
- `modally_saturated`: Every Diamond obligation has a witness in some Flag
- `eval_flag`: Distinguished Flag for evaluation (contains the root MCS)
- `eval_element`: Distinguished element in eval_flag for truth evaluation

**Modal Coherence**:
In this structure, modal coherence is encoded semantically via the accessibility
relation: Box(phi) at world (F, x) means phi holds at all (F', x') where
BoxContent(x.world) ⊆ x'.world. The `modally_saturated` field ensures Diamond
witnesses exist.
-/
structure FlagBFMCS where
  /-- The root MCS from which the bundle is constructed -/
  root : CanonicalMCS
  /-- The set of Flags in the bundle -/
  flags : Set (Flag CanonicalMCS)
  /-- The flag set is non-empty -/
  flags_nonempty : flags.Nonempty
  /--
  Modal saturation with accessibility: every Diamond formula in any MCS in any Flag
  has an accessible witness preserving BoxContent.

  For any Flag F in flags, any MCS M in F, and any formula psi,
  if Diamond(psi) is in M.world, then there exists a Flag F' in flags
  containing an MCS W with:
  - psi in W.world (the witness satisfies the formula)
  - MCSBoxContent M.world ⊆ W.world (BoxContent is preserved)

  The second condition ensures the witness is modally accessible from M,
  which is required for the truth lemma's Box case.
  -/
  modally_saturated : ∀ flag ∈ flags, ∀ M : CanonicalMCS, M ∈ flag →
    ∀ psi : Formula, psi.diamond ∈ M.world →
      ∃ flag' ∈ flags, ∃ W : CanonicalMCS, W ∈ flag' ∧ psi ∈ W.world ∧
        MCSBoxContent M.world ⊆ W.world
  /-- The distinguished evaluation Flag containing the root MCS -/
  eval_flag : Flag CanonicalMCS
  /-- The evaluation Flag is in the bundle -/
  eval_flag_mem : eval_flag ∈ flags
  /-- The root MCS is in the evaluation Flag -/
  root_in_eval_flag : root ∈ eval_flag

/-!
## Accessors and Basic Properties
-/

/--
Get the chainFMCS for a Flag in the bundle.

Each Flag in the FlagBFMCS has an associated chainFMCS providing temporal coherence.
-/
noncomputable def FlagBFMCS.chainFMCS_at (B : FlagBFMCS) (F : Flag CanonicalMCS)
    (_ : F ∈ B.flags) : FMCS (ChainFMCSDomain F) :=
  chainFMCS F

/--
Get the MCS at a position (Flag, element) in the bundle.

This extracts the underlying Set Formula from the ChainFMCSDomain element.
-/
def FlagBFMCS.mcs_at (B : FlagBFMCS) (F : Flag CanonicalMCS) (_ : F ∈ B.flags)
    (x : ChainFMCSDomain F) : Set Formula :=
  (chainFMCS F).mcs x

/--
The evaluation element: the root MCS viewed as an element of eval_flag.
-/
def FlagBFMCS.eval_element (B : FlagBFMCS) : ChainFMCSDomain B.eval_flag :=
  ⟨B.root, B.root_in_eval_flag⟩

/--
The MCS at the evaluation position equals the root MCS's world.
-/
theorem FlagBFMCS.eval_mcs_eq_root (B : FlagBFMCS) :
    B.mcs_at B.eval_flag B.eval_flag_mem B.eval_element = B.root.world := by
  simp only [mcs_at, eval_element, chainFMCS, chainFMCS_mcs]

/--
The MCS at any position is maximal consistent.
-/
theorem FlagBFMCS.mcs_at_is_mcs (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) : SetMaximalConsistent (B.mcs_at F hF x) :=
  (chainFMCS F).is_mcs x

/-!
## Modal Accessibility Relation

Modal accessibility in FlagBFMCS is defined via BoxContent inclusion.
This captures the standard modal semantics where accessible worlds
must satisfy all Box obligations.
-/

/--
Modal accessibility between positions in FlagBFMCS.

(F, x) is modally accessible to (F', x') iff BoxContent(x.world) ⊆ BoxContent(x'.world).

This is weaker than requiring BoxContent(x.world) ⊆ x'.world, making the
accessibility relation an equivalence (in S5 style).
-/
def FlagBFMCS.ModalR (B : FlagBFMCS) (F : Flag CanonicalMCS) (_ : F ∈ B.flags)
    (x : ChainFMCSDomain F) (F' : Flag CanonicalMCS) (_ : F' ∈ B.flags)
    (x' : ChainFMCSDomain F') : Prop :=
  MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world

/--
Modal accessibility is reflexive.
-/
theorem FlagBFMCS.ModalR_refl (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) : B.ModalR F hF x F hF x :=
  Set.Subset.rfl

/--
BoxContent at any position in the bundle is a subset of the MCS at that position.

This follows from the T-axiom: Box(phi) implies phi.
-/
theorem FlagBFMCS.boxcontent_subset_mcs (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) : MCSBoxContent (B.mcs_at F hF x) ⊆ B.mcs_at F hF x := by
  simp only [mcs_at]
  exact MCSBoxContent_subset_self _ (chainFMCS_is_mcs F x)

/-!
## canonicalFlagBFMCS Construction

The canonical FlagBFMCS uses `closedFlags` to provide a witness-closed set of Flags.
-/

/--
The canonical FlagBFMCS construction from a root MCS.

Uses `closedFlags M0` which is:
- Non-empty (by closedFlags_nonempty)
- Witness-closed (by closedFlags_closed_under_witnesses)
- Contains a Flag with M0 (by root_in_closedFlags)
-/
noncomputable def canonicalFlagBFMCS (M0 : CanonicalMCS) : FlagBFMCS where
  root := M0
  flags := closedFlags M0
  flags_nonempty := closedFlags_nonempty M0
  modally_saturated := closedFlags_closed_under_witnesses M0
  eval_flag := (root_in_closedFlags M0).choose
  eval_flag_mem := (root_in_closedFlags M0).choose_spec.1
  root_in_eval_flag := (root_in_closedFlags M0).choose_spec.2

/--
The root MCS is in the evaluation Flag of canonicalFlagBFMCS.
-/
theorem canonicalFlagBFMCS_root_in_eval_flag (M0 : CanonicalMCS) :
    M0 ∈ (canonicalFlagBFMCS M0).eval_flag :=
  (canonicalFlagBFMCS M0).root_in_eval_flag

/--
The evaluation MCS of canonicalFlagBFMCS is the root MCS's world.
-/
theorem canonicalFlagBFMCS_eval_mcs (M0 : CanonicalMCS) :
    (canonicalFlagBFMCS M0).mcs_at
      (canonicalFlagBFMCS M0).eval_flag
      (canonicalFlagBFMCS M0).eval_flag_mem
      (canonicalFlagBFMCS M0).eval_element = M0.world :=
  FlagBFMCS.eval_mcs_eq_root (canonicalFlagBFMCS M0)

/-!
## Temporal Coherence Properties

The temporal coherence properties are inherited from chainFMCS for each Flag.
-/

/--
Forward G coherence within a Flag: if G(phi) is at position x and x < x',
then phi is at position x'.
-/
theorem FlagBFMCS.forward_G (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x x' : ChainFMCSDomain F) (phi : Formula) (h_lt : x < x')
    (h_G : Formula.all_future phi ∈ B.mcs_at F hF x) :
    phi ∈ B.mcs_at F hF x' := by
  simp only [mcs_at] at h_G ⊢
  exact chainFMCS_forward_G F x x' phi h_lt h_G

/--
Backward H coherence within a Flag: if H(phi) is at position x and x' < x,
then phi is at position x'.
-/
theorem FlagBFMCS.backward_H (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x x' : ChainFMCSDomain F) (phi : Formula) (h_lt : x' < x)
    (h_H : Formula.all_past phi ∈ B.mcs_at F hF x) :
    phi ∈ B.mcs_at F hF x' := by
  simp only [mcs_at] at h_H ⊢
  exact chainFMCS_backward_H F x x' phi h_lt h_H

/--
BoxContent propagates through temporal accessibility within a Flag.

If x ≤ x' in a Flag, then BoxContent(mcs(x)) ⊆ BoxContent(mcs(x')).
This is because Box formulas persist through temporal succession via MF axiom.
-/
theorem FlagBFMCS.boxcontent_temporal_propagation (B : FlagBFMCS)
    (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x x' : ChainFMCSDomain F) (h_le : x ≤ x') :
    MCSBoxContent (B.mcs_at F hF x) ⊆ MCSBoxContent (B.mcs_at F hF x') := by
  simp only [mcs_at]
  exact chainFMCS_boxcontent_propagation F x x' h_le

end Bimodal.Metalogic.Bundle
