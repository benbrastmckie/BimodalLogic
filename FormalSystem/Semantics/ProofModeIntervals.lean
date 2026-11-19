/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.Truth
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.PlusLanguage.TemporalViews

/-!
# Temporal truth views for the pointed proof mode

The derived inclusive views `event ∨ (guard ∧ U guard event)` and its past mirror, read through
the existing strict clauses. The generic statements use only `BotClause`, `ImpClause` and
`UntlClause`/`SnceClause`; the durations are those of an arbitrary frame, so any linearly
ordered abelian group (`ℤ`, `ℚ`, `ℝ`, …) is covered. There is no integer induction and no
successor function.

## Main Results

- `inclusiveUntil_iff` — `e ∨ (g ∧ U g e)` at `t` iff `∃ s ≥ t`, `e` at `s` and `g` on `[t, s)`.
- `inclusiveSince_iff` — `e ∨ (g ∧ S g e)` at `t` iff `∃ s ≤ t`, `e` at `s` and `g` on `(s, t]`.
- `truthAt_inclusiveUntil_iff`, `truthAt_inclusiveSince_iff`, `plusTruthAt_inclusiveUntil_iff`,
  `plusTruthAt_inclusiveSince_iff` — the same at the literal `Formula.inclusiveUntil`/`Since` and
  `PlusFormula.inclusiveUntil`/`Since` views of `PlusLanguage/TemporalViews.lean`.

## Endpoints

The guard interval is closed at the evaluation time and open at the event time. The event may
occur at the evaluation time itself, and then nothing is demanded of the guard. The strict clause
is never weakened: the right disjunct still requires `t < s` and the guard only on `(t, s)`; the
extra current-time guard comes from the conjunct `g`.
-/

-- Lower semantic layer: no proof system, soundness or completeness.
assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.FrameClass

namespace FormalSystem.Semantics.ProofModeIntervals

open TruthClauses

section Generic
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] {F : TaskFrame}

/-- **Inclusive Until.** `e ∨ (g ∧ U g e)` holds at `t` exactly when `e` holds at some `s ≥ t`
and `g` holds on the half-open interval `[t, s)`. -/
theorem inclusiveUntil_iff [UntlClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (g ev : L) :
    TruthEnv.T M τ t e (or ev (and g (UntlClause.untl g ev))) ↔
      ∃ s : F.Duration, t ≤ s ∧ TruthEnv.T M τ s e ev ∧
        ∀ r : F.Duration, t ≤ r → r < s → TruthEnv.T M τ r e g := by
  rw [or_iff, and_iff, UntlClause.untl_clause]
  constructor
  · rintro (hev | ⟨hg, s, hts, hev, hguard⟩)
    · exact ⟨t, le_rfl, hev, fun r htr hrt => absurd hrt (not_lt.mpr htr)⟩
    · refine ⟨s, hts.le, hev, fun r htr hrs => ?_⟩
      rcases htr.lt_or_eq with htr | rfl
      · exact hguard r htr hrs
      · exact hg
  · rintro ⟨s, hts, hev, hguard⟩
    rcases hts.lt_or_eq with hts | rfl
    · exact Or.inr ⟨hguard t le_rfl hts, s, hts, hev, fun r htr hrs => hguard r htr.le hrs⟩
    · exact Or.inl hev

/-- **Inclusive Since**, the past mirror: `e ∨ (g ∧ S g e)` holds at `t` exactly when `e` held
at some `s ≤ t` and `g` holds on the half-open interval `(s, t]`. -/
theorem inclusiveSince_iff [SnceClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (g ev : L) :
    TruthEnv.T M τ t e (or ev (and g (SnceClause.snce g ev))) ↔
      ∃ s : F.Duration, s ≤ t ∧ TruthEnv.T M τ s e ev ∧
        ∀ r : F.Duration, s < r → r ≤ t → TruthEnv.T M τ r e g := by
  rw [or_iff, and_iff, SnceClause.snce_clause]
  constructor
  · rintro (hev | ⟨hg, s, hst, hev, hguard⟩)
    · exact ⟨t, le_rfl, hev, fun r htr hrt => absurd hrt (not_le.mpr htr)⟩
    · refine ⟨s, hst.le, hev, fun r hsr hrt => ?_⟩
      rcases hrt.lt_or_eq with hrt | rfl
      · exact hguard r hsr hrt
      · exact hg
  · rintro ⟨s, hst, hev, hguard⟩
    rcases hst.lt_or_eq with hst | rfl
    · exact Or.inr ⟨hguard t hst le_rfl, s, hst, hev, fun r hsr hrt => hguard r hsr hrt.le⟩
    · exact Or.inl hev

end Generic

/-! ## The literal TM and TM⁺ views -/

section Concrete
variable {F : TaskFrame}

/-- `inclusiveUntil_iff` at the literal TM view `Formula.inclusiveUntil guard event`. -/
theorem truthAt_inclusiveUntil_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (g ev : Syntax.Formula) :
    TruthAt M τ t (Syntax.Formula.inclusiveUntil g ev) ↔
      ∃ s : F.Duration, t ≤ s ∧ TruthAt M τ s ev ∧
        ∀ r : F.Duration, t ≤ r → r < s → TruthAt M τ r g :=
  inclusiveUntil_iff (L := Syntax.Formula) M τ t PUnit.unit g ev

/-- `inclusiveSince_iff` at the literal TM view `Formula.inclusiveSince guard event`. -/
theorem truthAt_inclusiveSince_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (g ev : Syntax.Formula) :
    TruthAt M τ t (Syntax.Formula.inclusiveSince g ev) ↔
      ∃ s : F.Duration, s ≤ t ∧ TruthAt M τ s ev ∧
        ∀ r : F.Duration, s < r → r ≤ t → TruthAt M τ r g :=
  inclusiveSince_iff (L := Syntax.Formula) M τ t PUnit.unit g ev

/-- `inclusiveUntil_iff` at the literal TM⁺ view `PlusFormula.inclusiveUntil guard event`. -/
theorem plusTruthAt_inclusiveUntil_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (g ev : PlusLanguage.PlusFormula) :
    PlusLanguage.PlusTruthAt M τ t (PlusLanguage.PlusFormula.inclusiveUntil g ev) ↔
      ∃ s : F.Duration, t ≤ s ∧ PlusLanguage.PlusTruthAt M τ s ev ∧
        ∀ r : F.Duration, t ≤ r → r < s → PlusLanguage.PlusTruthAt M τ r g :=
  inclusiveUntil_iff (L := PlusLanguage.PlusFormula) M τ t PUnit.unit g ev

/-- `inclusiveSince_iff` at the literal TM⁺ view `PlusFormula.inclusiveSince guard event`. -/
theorem plusTruthAt_inclusiveSince_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (g ev : PlusLanguage.PlusFormula) :
    PlusLanguage.PlusTruthAt M τ t (PlusLanguage.PlusFormula.inclusiveSince g ev) ↔
      ∃ s : F.Duration, s ≤ t ∧ PlusLanguage.PlusTruthAt M τ s ev ∧
        ∀ r : F.Duration, s < r → r ≤ t → PlusLanguage.PlusTruthAt M τ r g :=
  inclusiveSince_iff (L := PlusLanguage.PlusFormula) M τ t PUnit.unit g ev

end Concrete

end FormalSystem.Semantics.ProofModeIntervals

namespace FormalSystem.Semantics.ProofModeIntervals

open TruthClauses FormalSystem.Syntax FormalSystem.PlusLanguage

/-- Exact strict release clause; event first, guard second, with no inclusive endpoints. -/
theorem release_iff {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (neg (UntlClause.untl (neg guard) (neg event))) ↔
      ¬ ∃ s, t < s ∧ ¬ TruthEnv.T M τ s e event ∧
        ∀ r, t < r → r < s → ¬ TruthEnv.T M τ r e guard := by
  simp only [neg_iff, UntlClause.untl_clause]

/-- The strict past mirror of release, event first. -/
theorem trigger_iff {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [SnceClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (neg (SnceClause.snce (neg guard) (neg event))) ↔
      ¬ ∃ s, s < t ∧ ¬ TruthEnv.T M τ s e event ∧
        ∀ r, s < r → r < t → ¬ TruthEnv.T M τ r e guard := by
  simp only [neg_iff, SnceClause.snce_clause]

/-- Weak Until is strict Until or a strict universal guard; event first. -/
theorem weakUntil_iff {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (or (UntlClause.untl guard event) (allFuture guard)) ↔
      (∃ s, t < s ∧ TruthEnv.T M τ s e event ∧
        ∀ r, t < r → r < s → TruthEnv.T M τ r e guard) ∨
      ∀ s, t < s → TruthEnv.T M τ s e guard := by
  simp only [or_iff, UntlClause.untl_clause, allFuture_iff]

/-- The strict past mirror of weak Until, event first. -/
theorem weakSince_iff {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [SnceClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (or (SnceClause.snce guard event) (allPast guard)) ↔
      (∃ s, s < t ∧ TruthEnv.T M τ s e event ∧
        ∀ r, s < r → r < t → TruthEnv.T M τ r e guard) ∨
      ∀ s, s < t → TruthEnv.T M τ s e guard := by
  simp only [or_iff, SnceClause.snce_clause, allPast_iff]

/-- Pin the generic clause to the literal event-first Formula view. -/
theorem truthAt_release_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (event guard : Formula) :
    TruthAt M τ t (Formula.release event guard) ↔
      ¬ ∃ s, t < s ∧ ¬ TruthAt M τ s event ∧
        ∀ r, t < r → r < s → ¬ TruthAt M τ r guard :=
  release_iff (L := Formula) M τ t () event guard

/-- Pin the generic clause to the literal event-first PlusFormula view. -/
theorem plusTruthAt_release_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (event guard : PlusFormula) :
    PlusTruthAt M τ t (PlusFormula.release event guard) ↔
      ¬ ∃ s, t < s ∧ ¬ PlusTruthAt M τ s event ∧
        ∀ r, t < r → r < s → ¬ PlusTruthAt M τ r guard :=
  release_iff (L := PlusFormula) M τ t () event guard

/-- Pin the generic clause to the literal event-first Formula view. -/
theorem truthAt_trigger_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (event guard : Formula) :
    TruthAt M τ t (Formula.trigger event guard) ↔
      ¬ ∃ s, s < t ∧ ¬ TruthAt M τ s event ∧
        ∀ r, s < r → r < t → ¬ TruthAt M τ r guard :=
  trigger_iff (L := Formula) M τ t () event guard

/-- Pin the generic clause to the literal event-first PlusFormula view. -/
theorem plusTruthAt_trigger_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (event guard : PlusFormula) :
    PlusTruthAt M τ t (PlusFormula.trigger event guard) ↔
      ¬ ∃ s, s < t ∧ ¬ PlusTruthAt M τ s event ∧
        ∀ r, s < r → r < t → ¬ PlusTruthAt M τ r guard :=
  trigger_iff (L := PlusFormula) M τ t () event guard

/-- Pin the generic clause to the literal event-first Formula view. -/
theorem truthAt_weakUntil_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (event guard : Formula) :
    TruthAt M τ t (Formula.weakUntil event guard) ↔
      (∃ s, t < s ∧ TruthAt M τ s event ∧
        ∀ r, t < r → r < s → TruthAt M τ r guard) ∨
      ∀ s, t < s → TruthAt M τ s guard :=
  weakUntil_iff (L := Formula) M τ t () event guard

/-- Pin the generic clause to the literal event-first PlusFormula view. -/
theorem plusTruthAt_weakUntil_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (event guard : PlusFormula) :
    PlusTruthAt M τ t (PlusFormula.weakUntil event guard) ↔
      (∃ s, t < s ∧ PlusTruthAt M τ s event ∧
        ∀ r, t < r → r < s → PlusTruthAt M τ r guard) ∨
      ∀ s, t < s → PlusTruthAt M τ s guard :=
  weakUntil_iff (L := PlusFormula) M τ t () event guard

/-- Pin the generic clause to the literal event-first Formula view. -/
theorem truthAt_weakSince_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (event guard : Formula) :
    TruthAt M τ t (Formula.weakSince event guard) ↔
      (∃ s, s < t ∧ TruthAt M τ s event ∧
        ∀ r, s < r → r < t → TruthAt M τ r guard) ∨
      ∀ s, s < t → TruthAt M τ s guard :=
  weakSince_iff (L := Formula) M τ t () event guard

/-- Pin the generic clause to the literal event-first PlusFormula view. -/
theorem plusTruthAt_weakSince_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (event guard : PlusFormula) :
    PlusTruthAt M τ t (PlusFormula.weakSince event guard) ↔
      (∃ s, s < t ∧ PlusTruthAt M τ s event ∧
        ∀ r, s < r → r < t → PlusTruthAt M τ r guard) ∨
      ∀ s, s < t → PlusTruthAt M τ s guard :=
  weakSince_iff (L := PlusFormula) M τ t () event guard

end FormalSystem.Semantics.ProofModeIntervals
