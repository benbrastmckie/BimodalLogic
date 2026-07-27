/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.TemporalContent
import FormalSystem.Metalogic.Bundle.CanonicalFrame
import FormalSystem.Metalogic.Bundle.WitnessSeed
import FormalSystem.Metalogic.Core.MCSProperties

/-!
ARCHIVED (Boneyard) — never compiled.

Origin: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`, the
`/-! ## Until/Since Step Properties -/` section (7 declarations, 7 sorries). The rest of
`SuccRelation.lean` is live and stays in place — this is a declaration excision, not a file move.

Archived declarations, in source order:

- `until_unfold_in_mcs`
- `since_unfold_in_mcs`
- `until_persists_through_succ`
- `or_until_in_mcs`
- `or_since_in_mcs`
- `g_content_subset_mcs`
- `h_content_subset_mcs`

Reason. All seven were proved under BX1 / BX8 / BX9 (reflexive `G`, reflexive Until/Since
introduction, Until/Since elimination to a disjunction), every one of which was removed as
unsound under the current open-guard `(t,s)` irreflexive semantics. Their original proofs are
archived in `../OpenGuardInvalid/`.

`g_content_subset_mcs` and `h_content_subset_mcs` are a stronger case: they are not merely
unproven but **false** under irreflexive semantics. `g_content u ⊆ u` unfolds to `G φ ∈ u → φ ∈ u`
— precisely the T-axiom for `G` (dually `H`), already recorded as unsound in
`../TAxiomDependentCode/`. The same two holes, inlined, were the entire sorry content of
`Bundle/SuccExistence.lean`, archived in the same pass to `../BundleSuccessorSeed/`.

Zero external consumers. Each of the seven names was grepped by word boundary across `Theories/`
(Boneyard excluded) and `Tests/`; every occurrence outside `SuccRelation.lean` itself is prose
inside a docstring (`Bundle/TemporalCoherence.lean`, `Bundle/UntilSinceCoherence.lean`, both
re-pointed here at excision time). A whole-environment `Lean.collectAxioms` scan independently
confirms this: each of the seven appears in the tainted set only as itself, with no downstream
declaration inheriting its taint.

Import lines above are copied verbatim from the source file and are not repaired.

Do not import from live code.
-/

#exit

/-!
## Until/Since Step Properties

Properties of Until/Since formulas in MCS, derived from until_unfold/since_unfold axioms.
These are used by the dovetailed chain construction to track Until/Since obligations.
-/

/-- `(φ U ψ) → X(ψ ∨ (φ ∧ (φ U ψ)))`: X-wrapped Until unfolding in an MCS.
  Derived from BX5 (self-accumulation) + BX9 (elimination) + BX8 (reflexive intro). -/
theorem until_unfold_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_U : Formula.untl ψ φ ∈ M) :
    Formula.untl (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))) Formula.bot ∈ M := by
  -- TOMBSTONE: was TemporalDerived.until_unfold_wrapped; archived to Boneyard/OpenGuardInvalid/
  -- Reason: BX9 removed + reflexive Until intro invalid under open guard (t,s) semantics
  sorry

/-- `(φ S ψ) → Y(ψ ∨ (φ ∧ (φ S ψ)))`: Y-wrapped Since unfolding in an MCS.
  Derived from BX5' (self-accumulation) + BX9' (elimination) + BX8' (reflexive intro). -/
theorem since_unfold_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_S : Formula.snce ψ φ ∈ M) :
    Formula.snce (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))) Formula.bot ∈ M := by
  -- TOMBSTONE: was TemporalDerived.since_unfold_wrapped; archived to Boneyard/OpenGuardInvalid/
  -- Reason: BX9 removed + reflexive Since intro invalid under open guard (t,s) semantics
  sorry

/--
U-step for Succ with G-persistence.

**BLOCKED** under strict semantics: The old argument relied on the non-strict `until_unfold`
giving `ψ ∨ (φ ∧ G(φ U ψ))`, where `G(φ U ψ)` propagates via g_content. Under the
BX axiom system, `until_unfold_wrapped` gives `(⊥ U (ψ ∨ (φ ∧ (φ U ψ))))` instead,
and there is no G-wrapped Until formula to propagate through g_content. The bot-Until
formula gives `F(ψ ∨ ...)` via eventuality extraction, placing the disjunction in
`f_content(u)`. By Succ.f_step, it reaches `v ∪ f_content(v)`. However, if it lands
in `v` and the `ψ` branch holds, `ψ → (φ U ψ)` uses BX8 (reflexive intro). If it
lands in `f_content(v)`, we get `F(ψ ∨ ...) ∈ v` but not `(φ U ψ) ∈ v`.

This theorem requires the Succ relation to additionally propagate bot-Until content,
or a fundamentally different approach. The dovetailed chain construction bypasses this
by resolving Until obligations through fair scheduling rather than Succ-based propagation.
-/
theorem until_persists_through_succ (u v : Set Formula)
    (h_mcs_u : SetMaximalConsistent (fc := FrameClass.Base) u) (h_mcs_v : SetMaximalConsistent (fc := FrameClass.Base) v) (h_succ : Succ u v)
    (φ ψ : Formula) (h_U : Formula.untl ψ φ ∈ u) (h_neg_psi : Formula.neg ψ ∈ u) :
    Formula.untl ψ φ ∈ v := by
  -- BLOCKED: requires X-content propagation infrastructure.
  -- See docstring for detailed analysis.
  sorry

/-!
## Until/Since Introduction at the MCS Level — TOMBSTONED

These theorems are sorry'd stubs. The original proofs assumed reflexive Until/Since
semantics, which is invalid under open guard (t,s) semantics.
Archived proofs are in Boneyard/OpenGuardInvalid/.
-/

/--
In any MCS: `(ψ ∨ (φ ∧ (φ U ψ))) ∈ M → (φ U ψ) ∈ M`.

This is the reflexive version of `until_intro`. Under reflexive Until semantics,
the disjunction `ψ ∨ (φ ∧ (φ U ψ))` immediately gives `(φ U ψ)`:
- If ψ holds, by BX8 (reflexive intro): `ψ → (φ U ψ)`
- If `φ ∧ (φ U ψ)` holds, by conjunction elimination: `(φ U ψ)` directly
-/
theorem or_until_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula)
    (h : Formula.or ψ (Formula.and φ (Formula.untl ψ φ)) ∈ M) :
    Formula.untl ψ φ ∈ M := by
  -- TOMBSTONE: was TemporalDerived.psi_imp_until; archived to Boneyard/OpenGuardInvalid/
  -- Reason: reflexive Until intro invalid under open guard (t,s) semantics
  sorry

/--
In any MCS: `(ψ ∨ (φ ∧ (φ S ψ))) ∈ M → (φ S ψ) ∈ M`.

Temporal dual of `or_until_in_mcs`. Uses BX8' (reflexive Since intro) and
conjunction elimination.
-/
theorem or_since_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula)
    (h : Formula.or ψ (Formula.and φ (Formula.snce ψ φ)) ∈ M) :
    Formula.snce ψ φ ∈ M := by
  -- TOMBSTONE: was TemporalDerived.psi_imp_since; archived to Boneyard/OpenGuardInvalid/
  -- Reason: reflexive Since intro invalid under open guard (t,s) semantics
  sorry

/--
`g_content(u) ⊆ u` for any MCS u under BX1 (reflexive G).

Under BX1, `G(φ) → φ`, so `G(φ) ∈ u` and MCS derivation closure give `φ ∈ u`.
-/
theorem g_content_subset_mcs (u : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) u) :
    g_content u ⊆ u := by
  intro chi h_gc
  -- Under irreflexive semantics, G(φ) → φ is no longer valid. Sorry.
  sorry

/--
`h_content(u) ⊆ u` for any MCS u under BX1' (reflexive H).
Under irreflexive semantics, H(φ) → φ is no longer valid.
-/
theorem h_content_subset_mcs (u : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) u) :
    h_content u ⊆ u := by
  sorry
