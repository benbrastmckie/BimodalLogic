/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.TruthClauses

/-!
# Inclusive and weak temporal clauses, and their strict duals

Inclusive Until and Since expand a derived formula into a half-open interval. The guard
includes the current point when the witness is strictly later or earlier. Weak Until and
Since retain strict endpoints and allow a continuing guard.

Every clause is stated over the classes of `FormalSystem/Semantics/TruthClauses.lean`, so each
reading is proved once for every language instantiating the classes it names.

## Main Results

- `inclusiveUntil_iff`, `inclusiveSince_iff` — the half-open interval readings
- `release_iff`, `trigger_iff` — the strict duals, as the negation of an `U`/`S` clause
- `weakUntil_iff`, `weakSince_iff` — strict `U`/`S` or a strict universal guard

## References

* `FormalSystem/Semantics/TruthClauses.lean` — the clause classes
* `FormalSystem/Syntax/Connectives.lean` — the interval operators `inclusiveUntil`,
  `inclusiveSince`, `release`, `trigger`, `weakUntil`, `weakSince` the clauses are stated about
* `FormalSystem/Semantics/TemporalRules.lean` — the covering-time and persistence rules
* `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` — the per-language test rows

## Tags

temporal · interval · until · since · release · trigger · weak-until · generic
-/

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree

namespace FormalSystem.Semantics.TemporalIntervals

open TruthClauses
open FormalSystem.Syntax FormalSystem.Syntax.Sig

section Generic
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] {F : TaskFrame}

/-- **Inclusive Until.** `e ∨ (g ∧ U g e)` holds at `t` exactly when `e` holds at some `s ≥ t`
and `g` holds on the half-open interval `[t, s)`. -/
theorem inclusiveUntil_iff [HasUntl L] [UntlClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (g ev : L) :
    TruthEnv.T M τ t e (inclusiveUntil g ev) ↔
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
theorem inclusiveSince_iff [HasSnce L] [SnceClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (g ev : L) :
    TruthEnv.T M τ t e (inclusiveSince g ev) ↔
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
theorem release_iff {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L]
    [HasUntl L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (release event guard) ↔
      ¬ ∃ s, t < s ∧ ¬ TruthEnv.T M τ s e event ∧
        ∀ r, t < r → r < s → ¬ TruthEnv.T M τ r e guard := by
  simp only [neg_iff, UntlClause.untl_clause]

/-- The strict past mirror of release, event first. -/
theorem trigger_iff {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L]
    [HasSnce L] [SnceClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (trigger event guard) ↔
      ¬ ∃ s, s < t ∧ ¬ TruthEnv.T M τ s e event ∧
        ∀ r, s < r → r < t → ¬ TruthEnv.T M τ r e guard := by
  simp only [neg_iff, SnceClause.snce_clause]

/-- **The positive reading of release.** The same clause as `release_iff`, stated as a direct
universal-existential claim rather than as the negation of an `U` clause: at every strictly later
time the event holds, or the guard has already fired strictly in between. This is the form a
refutation script consumes, since it names a witness rather than denying one. -/
theorem release_iff_forall {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L]
    [HasUntl L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (release event guard) ↔
      ∀ s : F.Duration, t < s → TruthEnv.T M τ s e event ∨
        ∃ r : F.Duration, t < r ∧ r < s ∧ TruthEnv.T M τ r e guard := by
  rw [release_iff]
  constructor
  · intro h s hts
    by_contra hc
    push Not at hc
    exact h ⟨s, hts, hc.1, hc.2⟩
  · rintro h ⟨s, hts, hne, hguard⟩
    rcases h s hts with hev | ⟨r, htr, hrs, hg⟩
    · exact hne hev
    · exact hguard r htr hrs hg

/-- **The positive reading of trigger**, the strict past mirror of `release_iff_forall`: at every
strictly earlier time the event held, or the guard had already fired strictly in between. -/
theorem trigger_iff_forall {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L]
    [HasSnce L] [SnceClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (trigger event guard) ↔
      ∀ s : F.Duration, s < t → TruthEnv.T M τ s e event ∨
        ∃ r : F.Duration, s < r ∧ r < t ∧ TruthEnv.T M τ r e guard := by
  rw [trigger_iff]
  constructor
  · intro h s hst
    by_contra hc
    push Not at hc
    exact h ⟨s, hst, hc.1, hc.2⟩
  · rintro h ⟨s, hst, hne, hguard⟩
    rcases h s hst with hev | ⟨r, hsr, hrt, hg⟩
    · exact hne hev
    · exact hguard r hsr hrt hg

/-- Weak Until is strict Until or a strict universal guard; event first. -/
theorem weakUntil_iff {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L]
    [HasUntl L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (weakUntil event guard) ↔
      (∃ s, t < s ∧ TruthEnv.T M τ s e event ∧
        ∀ r, t < r → r < s → TruthEnv.T M τ r e guard) ∨
      ∀ s, t < s → TruthEnv.T M τ s e guard := by
  simp only [or_iff, UntlClause.untl_clause, allFuture_iff]

/-- The strict past mirror of weak Until, event first. -/
theorem weakSince_iff {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L]
    [HasSnce L] [SnceClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (weakSince event guard) ↔
      (∃ s, s < t ∧ TruthEnv.T M τ s e event ∧
        ∀ r, s < r → r < t → TruthEnv.T M τ r e guard) ∨
      ∀ s, s < t → TruthEnv.T M τ s e guard := by
  simp only [or_iff, SnceClause.snce_clause, allPast_iff]

end FormalSystem.Semantics.TemporalIntervals
