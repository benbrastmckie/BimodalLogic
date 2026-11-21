/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.TruthClauses

/-! Inclusive and weak temporal clauses, and their strict duals.

Inclusive Until and Since expand a derived formula into a half-open interval. The guard
includes the current point when the witness is strictly later or earlier. Weak Until and
Since retain strict endpoints and allow a continuing guard.
 -/

assert_not_exists FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass

namespace FormalSystem.Semantics.TemporalIntervals

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

end FormalSystem.Semantics.TemporalIntervals
