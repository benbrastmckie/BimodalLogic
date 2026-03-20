import Bimodal.Metalogic.Bundle.FlagBFMCS
import Bimodal.Metalogic.Bundle.FlagBFMCSTruthLemma

/-!
# FlagBFMCS Completeness Infrastructure (Task 1003 Phase 5)

This module wires the FlagBFMCS construction to the completeness theorem.

## Overview

The completeness theorem for bimodal logic states:
  If Γ is consistent, then Γ is satisfiable.

Using FlagBFMCS, we construct a canonical model from any consistent context Γ:
1. Extend Γ to an MCS M0 via Lindenbaum's lemma
2. Construct canonicalFlagBFMCS(M0)
3. Use the truth lemma to show M0's formulas are satisfied

## Main Results

- `FlagBFMCS_satisfies_root`: Every formula in the root MCS is satisfied
- `FlagBFMCS_completeness`: The completeness theorem

## References

- FlagBFMCS.lean: FlagBFMCS structure
- FlagBFMCSTruthLemma.lean: Truth lemma
- MaximalConsistent.lean: set_lindenbaum (Lindenbaum's lemma)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Satisfaction at Root

The key lemma: formulas in the root MCS are satisfied at the evaluation position.
-/

/--
Any formula in the root MCS of a FlagBFMCS is satisfied at the evaluation position.

This follows directly from the truth lemma and the fact that the evaluation MCS
equals the root MCS.

**Note**: Requires `h_complete : B.temporally_complete` for the truth lemma.
-/
theorem FlagBFMCS_satisfies_root (B : FlagBFMCS) (h_complete : B.temporally_complete)
    (φ : Formula) (h_mem : φ ∈ B.root.world) :
    satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ := by
  rw [satisfies_at_iff_mem B h_complete]
  -- B.eval_element is in B.eval_flag, and its MCS is B.root.world
  simp only [FlagBFMCS.eval_element, chainFMCS, chainFMCS_mcs]
  exact h_mem

/--
Any formula in the root MCS of allFlagsBFMCS is satisfied at its evaluation position.

Uses allFlagsBFMCS (which uses Set.univ) instead of canonicalFlagBFMCS,
because allFlagsBFMCS has trivial temporal completeness.
-/
theorem allFlagsBFMCS_satisfies_root (M0 : CanonicalMCS) (φ : Formula)
    (h_mem : φ ∈ M0.world) :
    satisfies_at (allFlagsBFMCS M0)
      (allFlagsBFMCS M0).eval_flag
      (allFlagsBFMCS M0).eval_flag_mem
      (allFlagsBFMCS M0).eval_element φ :=
  FlagBFMCS_satisfies_root (allFlagsBFMCS M0) (allFlagsBFMCS_temporally_complete M0) φ h_mem

/-!
## Completeness Theorem

We state the completeness theorem in terms of FlagBFMCS satisfaction.
The full proof requires connecting to the standard semantic framework.
-/

/--
**Completeness Theorem (FlagBFMCS version)**:

If a set S is consistent, then there exists a FlagBFMCS B and an evaluation
position where all formulas in S are satisfied.

**Proof Sketch**:
1. S consistent implies S can be extended to an MCS M0 (Lindenbaum)
2. Construct B = allFlagsBFMCS(M0) (uses all Flags for temporal completeness)
3. For each φ ∈ S, φ ∈ M0.world (by extension)
4. By truth lemma: φ satisfied at B's evaluation position
-/
theorem FlagBFMCS_completeness_set (S : Set Formula)
    (h_cons : SetConsistent S) :
    ∃ (B : FlagBFMCS),
      ∀ φ ∈ S, satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ := by
  -- Extend S to an MCS via set_lindenbaum
  obtain ⟨M_ext, h_ext_sub, h_ext_mcs⟩ := set_lindenbaum S h_cons
  -- Convert to CanonicalMCS
  let M0 : CanonicalMCS := ⟨M_ext, h_ext_mcs⟩
  -- Construct the FlagBFMCS using all Flags (for temporal completeness)
  let B := allFlagsBFMCS M0
  use B
  intro φ hφ
  -- φ ∈ S implies φ ∈ M0.world (by h_ext_sub)
  have h_mem : φ ∈ M0.world := h_ext_sub hφ
  exact allFlagsBFMCS_satisfies_root M0 φ h_mem

/--
**Completeness Theorem (list context version)**:

If a list context Γ is consistent, then there exists a FlagBFMCS B and an
evaluation position where all formulas in Γ are satisfied.
-/
theorem FlagBFMCS_completeness (Γ : List Formula)
    (h_cons : SetConsistent { φ | φ ∈ Γ }) :
    ∃ (B : FlagBFMCS),
      ∀ φ ∈ Γ, satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ := by
  obtain ⟨B, hB⟩ := FlagBFMCS_completeness_set { φ | φ ∈ Γ } h_cons
  use B
  intro φ hφ
  exact hB φ hφ

/-!
## Connection to Standard Completeness

The following connects FlagBFMCS completeness to the standard semantic formulation.
This requires defining a bimodal model from a FlagBFMCS.
-/

/--
World type for a FlagBFMCS model: pairs (Flag, element).
-/
def FlagBFMCS.World (B : FlagBFMCS) :=
  Σ (F : { f : Flag CanonicalMCS // f ∈ B.flags }), ChainFMCSDomain F.val

/--
Modal accessibility in the FlagBFMCS model.
-/
def FlagBFMCS.ModalAccessible (B : FlagBFMCS)
    (w w' : B.World) : Prop :=
  MCSBoxContent w.2.val.world ⊆ MCSBoxContent w'.2.val.world

/--
Temporal future accessibility in the FlagBFMCS model (within same Flag).
-/
def FlagBFMCS.TemporalFuture (B : FlagBFMCS)
    (w w' : B.World) : Prop :=
  ∃ (h : w.1 = w'.1), h ▸ w.2 < w'.2

/--
Temporal past accessibility in the FlagBFMCS model (within same Flag).
-/
def FlagBFMCS.TemporalPast (B : FlagBFMCS)
    (w w' : B.World) : Prop :=
  ∃ (h : w.1 = w'.1), h ▸ w'.2 < w.2

/--
Valuation in the FlagBFMCS model: atoms are true iff in the MCS.
-/
def FlagBFMCS.Valuation (B : FlagBFMCS)
    (w : B.World) (p : Atom) : Prop :=
  Formula.atom p ∈ w.2.val.world

/--
The evaluation world in a FlagBFMCS model.
-/
def FlagBFMCS.evalWorld (B : FlagBFMCS) : B.World :=
  ⟨⟨B.eval_flag, B.eval_flag_mem⟩, B.eval_element⟩

end Bimodal.Metalogic.Bundle
