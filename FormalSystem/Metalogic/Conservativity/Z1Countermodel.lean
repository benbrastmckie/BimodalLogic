/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.BaseLanguageSoundness
import FormalSystem.Metalogic.Conservativity.TMCompletenessReduction
import FormalSystem.Metalogic.Soundness
import FormalSystem.Semantics.LexCarrier
import FormalSystem.Metalogic.Algebraic.FlowFrame

/-!
# The `Z1` countermodel and the two CEF deliverables

Machine-checks `¬ ⊢ᴮᴸ[Discrete] Z1 p` at the non-Archimedean discrete carrier `ℚ ×ₗ ℤ`, closing
CEF with **both** halves in-tree (`Conservativity.z1_translate` is the other half, already
sorry-free), and refutes `TM_f`'s weak completeness over ℤ-time (report §6.1).

## The countermodel

`D := ℚ ×ₗ ℤ`, `F := multiFamTaskFrameGen (TemporalOrder.of D) Unit`,
`τ := multiFamHistoryGen () 0` (total, by `multiFamHistoryGen_total`),
`M.valuation w _ := 1 ≤ (ofLex w.2).1`. The refuting structure **is** a task frame — a
lexicographic product of ordered abelian groups is an ordered abelian group — so the CEF
refutation never leaves `TaskFrame`; `Semantics/LexCarrier.lean` supplies the `SuccOrder`/
`PredOrder` instances `bl_soundness_discrete_succ` needs, and `Metalogic/BXCanonical/
DiscreteCarrierProbe.lean` already probes this carrier for the four `FrameClass.Base` binders,
so the two modules read as one story.

By Hölder (paper `def:TMplus-f`, line 4613) `ValidDiscrete` is validity over ℤ-time up to
isomorphism, which is what makes Deliverable 2 the `TM_f`-vs-`TM⁺_f` completeness gap rather
than a weaker claim.

## Main Results

- `z1_atom_iff` — the valuation lemma
- `z1_gp_iff_p` — `Gp ↔ p`, pointwise
- `not_bl_derivable_z1` — **Deliverable 1**: `¬ ⊢ᴮᴸ[Discrete] Z1 p`
- `blValidDiscrete_z1` — **Deliverable 2**: `BLValidDiscrete (Z1 p)`, stated as the negation of
  `TMCompleteDiscrete` (Phase 4's `Prop`), so the two phases visibly compose

## References

* `specs/495_determine_tm_completeness_status_over_task_frames/reports/01_tm-completeness-status.md` §6.1
* `FormalSystem/Metalogic/Conservativity/Backward.lean` — `Z1`, `z1_translate` (the TM⁺_f half)
* `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` — `TMCompleteDiscrete`
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.BaseLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

/-! ## The model -/

/-- The countermodel's temporal order: `ℚ ×ₗ ℤ`. -/
noncomputable abbrev z1D : TemporalOrder := TemporalOrder.of (ℚ ×ₗ ℤ)

/-- The countermodel's frame: the deterministic multi-family flow frame at `z1D`, with a
single (`Unit`) family. -/
noncomputable abbrev z1F : TaskFrame := multiFamTaskFrameGen z1D Unit

/-- The countermodel's valuation: `p` holds at `w` iff `w`'s `ℚ`-coordinate is `≥ 1`. -/
noncomputable def z1TM : TaskModel z1F where
  valuation := fun w _ => 1 ≤ (ofLex w.2).1

/-- The countermodel's history: the flow line through family `()` starting at `0`. Total by
`multiFamHistoryGen_total`. -/
noncomputable abbrev z1τ : WorldHistory z1F := multiFamHistoryGen () (0 : (z1D : Type))

theorem z1τ_total : z1τ.IsTotal := multiFamHistoryGen_total (D := z1D) () 0

/-! ## The valuation lemma -/

/-- `p` holds at `t` along `z1τ` iff `t`'s `ℚ`-coordinate is `≥ 1`. -/
theorem z1_atom_iff (p : Atom) (t : (z1D : Type)) :
    BLTruthAt z1TM z1τ t (BLFormula.atom p) ↔ 1 ≤ (ofLex t).1 := by
  constructor
  · rintro ⟨_, h⟩
    simpa [z1TM, multiFamHistoryGen] using h
  · intro h
    refine ⟨trivial, ?_⟩
    simpa [z1TM, multiFamHistoryGen] using h

/-! ## `Gp ↔ p` pointwise -/

/-- **`Gp ↔ p`, pointwise.** If `t.1 ≥ 1`, every `s > t` also has `s.1 ≥ 1` (the first
coordinate is monotone under `<`, by `Prod.Lex.monotone_fst`). If `t.1 < 1`, the witness
`s := (t.1, t.2 + 1)` is `> t` (same first coordinate, second coordinate strictly larger) and
`s.1 = t.1 < 1`, so `p` fails there. -/
theorem z1_gp_iff_p (p : Atom) (t : (z1D : Type)) :
    BLTruthAt z1TM z1τ t (BLFormula.atom p).allFuture ↔ BLTruthAt z1TM z1τ t (BLFormula.atom p) := by
  rw [BLTruth.future_iff, z1_atom_iff]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have hlt : t < toLex ((ofLex t).1, (ofLex t).2 + 1) := by
      rw [Prod.Lex.lt_iff]
      exact Or.inr ⟨rfl, lt_add_one _⟩
    have h2 := h _ hlt
    rw [z1_atom_iff] at h2
    change 1 ≤ (ofLex t).1 at h2
    exact absurd h2 (not_le.mpr hc)
  · intro h s hs
    rw [z1_atom_iff]
    have := Prod.Lex.monotone_fst t s hs.le
    exact h.trans this

/-! ## Evaluation at `(0, 0)` -/

/-- The base point `(0, 0) : ℚ ×ₗ ℤ`. -/
noncomputable abbrev z1pt : (z1D : Type) := toLex ((0 : ℚ), (0 : ℤ))

/-- The `F(Gp)` witness `(1, 0) : ℚ ×ₗ ℤ`. -/
noncomputable abbrev z1pt1 : (z1D : Type) := toLex ((1 : ℚ), (0 : ℤ))

/-- The `¬Gp` witness `(0, 1) : ℚ ×ₗ ℤ`. -/
noncomputable abbrev z1pt2 : (z1D : Type) := toLex ((0 : ℚ), (1 : ℤ))

/-- `G(Gp → p)` is true at `(0, 0)`: immediate from `z1_gp_iff_p`. -/
theorem z1_G_Gp_imp_p (p : Atom) :
    BLTruthAt z1TM z1τ z1pt ((BLFormula.atom p).allFuture.imp (BLFormula.atom p)).allFuture := by
  rw [BLTruth.future_iff]
  intro s _
  rw [BLTruth.imp_iff]
  exact (z1_gp_iff_p p s).mp

/-- `F(Gp)` is true at `(0, 0)`, witnessed by `(1, 0)`. -/
theorem z1_F_Gp (p : Atom) :
    BLTruthAt z1TM z1τ z1pt (BLFormula.atom p).allFuture.someFuture := by
  rw [BLTruth.someFuture_iff]
  refine ⟨z1pt1, ?_, ?_⟩
  · show z1pt < z1pt1
    rw [Prod.Lex.lt_iff]
    exact Or.inl (show (0:ℚ) < 1 by norm_num)
  · rw [(z1_gp_iff_p p _), z1_atom_iff]
    exact le_refl (1 : ℚ)

/-- `Gp` is false at `(0, 0)`, witnessed by `(0, 1)`. -/
theorem z1_not_Gp (p : Atom) :
    ¬ BLTruthAt z1TM z1τ z1pt (BLFormula.atom p).allFuture := by
  rw [BLTruth.future_iff]
  push_neg
  refine ⟨z1pt2, ?_, ?_⟩
  · show z1pt < z1pt2
    rw [Prod.Lex.lt_iff]
    exact Or.inr ⟨rfl, show (0:ℤ) < 1 by norm_num⟩
  · rw [z1_atom_iff]
    exact not_le.mpr (by norm_num : (0:ℚ) < 1)

/-- **`¬ BLTruthAt z1TM z1τ (0,0) (Z1 p)`.** The antecedent `G(Gp → p)` holds, but the
consequent `F(Gp) → Gp` fails: `F(Gp)` holds while `Gp` does not. -/
theorem z1_not_true_at_zero (p : Atom) :
    ¬ BLTruthAt z1TM z1τ z1pt (Conservativity.Z1 (BLFormula.atom p)) := by
  intro h
  unfold Conservativity.Z1 at h
  rw [BLTruth.imp_iff] at h
  have h_cons := h (z1_G_Gp_imp_p p)
  rw [BLTruth.imp_iff] at h_cons
  exact z1_not_Gp p (h_cons (z1_F_Gp p))

/-! ## The two CEF deliverables -/

/--
**Deliverable 1.** `Z1 p` is not `TM_f`-derivable: soundness of `bl_soundness_discrete_succ`
against the countermodel, whose `SuccOrder`/`PredOrder` instances come from
`Semantics/LexCarrier.lean`. Combined with `Conservativity.z1_translate`, this is CEF refuted
with both halves machine-checked.
-/
theorem not_bl_derivable_z1 (p : Atom) :
    ¬ BaseLanguage.Derivable FrameClass.Discrete [] (Conservativity.Z1 (BLFormula.atom p)) := by
  rintro ⟨d⟩
  exact z1_not_true_at_zero p
    (bl_soundness_discrete_succ [] _ d z1F z1TM z1τ z1τ_total z1pt (by simp))

/--
**Deliverable 2.** `Z1 p` is `BLValidDiscrete`: from `Conservativity.z1_translate`
(`⊢[Discrete] tr (Z1 p)`), `soundness_discrete_valid` (BL⁺'s empty-context discrete soundness)
gives `ValidDiscrete (tr (Z1 p))`, and `blValidDiscrete_iff_validDiscrete_tr` crosses the
bridge.

Combined with `not_bl_derivable_z1`, this refutes the `.Discrete` row of Phase 4's reduction:
**`TM_f` is not weakly complete over ℤ-time.** Stated as the negation of `TMCompleteDiscrete`
so the two phases visibly compose.
-/
theorem blValidDiscrete_z1 (p : Atom) : BLValidDiscrete (Conservativity.Z1 (BLFormula.atom p)) := by
  rw [blValidDiscrete_iff_validDiscrete_tr]
  obtain ⟨d⟩ := Conservativity.z1_translate (BLFormula.atom p)
  exact soundness_discrete_valid d

/-- **TM_f is not weakly complete over ℤ-time.** The negation of Phase 4's `TMCompleteDiscrete`,
witnessed by `Z1 p`: `BLValidDiscrete (Z1 p)` holds (`blValidDiscrete_z1`) yet `Z1 p` is not
`TM_f`-derivable (`not_bl_derivable_z1`). -/
theorem tmCompleteDiscrete_refuted (p : Atom) : ¬ TMCompleteDiscrete :=
  fun h => not_bl_derivable_z1 p (h _ (blValidDiscrete_z1 p))

end FormalSystem.Metalogic
