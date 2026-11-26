/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.TruthClauses

/-!
# Well-founded progress with an explicit later occurrence premise

A decreasing rank or arrival at the target gives satisfaction now or at some later time.
The pointed specialization interprets the target on a fixed history.

The step premise asserts that a later point **exists**. That occurrence premise is what makes
descent productive over a bare preorder of times: no discreteness, successor function or
order cover is assumed anywhere in this module.

## Main Results

- `rank_progress` — the target holds now or at a strictly later point, over any preorder
- `rank_progress_strict` — the strictly later form, from a point missing the target
- `rank_progress_truth`, `rank_progress_truth_strict` — the pointed specializations, with the
  target read as truth of a formula on a fixed history

## References

* `FormalSystem/Semantics/TruthClauses.lean` — the clause classes and `someFuture`
* `FormalSystem/Semantics/TemporalRules.lean` — the eventuality bind rules
* `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` — the per-language test rows

## Tags

well-founded · rank · progress · eventuality · descent · generic
-/

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree

namespace FormalSystem.Semantics.RankProgress

open TruthClauses

section Progress

/--
**Well-founded rank progress**, over any preorder of times. From a point satisfying the invariant,
the target holds now or at a strictly later point, provided each non-target invariant point has a
strictly later invariant point that reaches the target or decreases the rank.

The step asserts that a later point **exists**; that occurrence premise is what makes descent
productive.
-/
theorem rank_progress {D : Type*} [Preorder D] {α : Type*} {r : α → α → Prop}
    (hwf : WellFounded r) (I Q : D → Prop) (rank : D → α)
    (step : ∀ s, I s → ¬ Q s → ∃ u, s < u ∧ I u ∧ (Q u ∨ r (rank u) (rank s)))
    {t : D} (ht : I t) : Q t ∨ ∃ u, t < u ∧ Q u := by
  suffices key : ∀ a, ∀ s, rank s = a → I s → Q s ∨ ∃ u, s < u ∧ Q u from
    key (rank t) t rfl ht
  intro a
  induction a using hwf.induction with
  | _ a ih =>
    intro s hs hI
    by_cases hQ : Q s
    · exact Or.inl hQ
    obtain ⟨u, hsu, hIu, hu⟩ := step s hI hQ
    rcases hu with hQu | hr
    · exact Or.inr ⟨u, hsu, hQu⟩
    · rcases ih (rank u) (hs ▸ hr) u rfl hIu with hQu | ⟨w, huw, hQw⟩
      · exact Or.inr ⟨u, hsu, hQu⟩
      · exact Or.inr ⟨w, lt_trans hsu huw, hQw⟩

/-- Strict eventuality from `rank_progress`, when the target is not already true now. -/
theorem rank_progress_strict {D : Type*} [Preorder D] {α : Type*} {r : α → α → Prop}
    (hwf : WellFounded r) (I Q : D → Prop) (rank : D → α)
    (step : ∀ s, I s → ¬ Q s → ∃ u, s < u ∧ I u ∧ (Q u ∨ r (rank u) (rank s)))
    {t : D} (ht : I t) (hnow : ¬ Q t) : ∃ u, t < u ∧ Q u :=
  (rank_progress hwf I Q rank step ht).resolve_left hnow

variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L] {F : TaskFrame}

/-- `rank_progress` along a fixed history with a pointed-truth target: `ψ` now, or `F ψ`. -/
theorem rank_progress_truth (M : TaskModel F) (τ : WorldHistory F) (e : TruthEnv.Env L F)
    (ψ : L) {α : Type*} {r : α → α → Prop} (hwf : WellFounded r)
    (I : F.Duration → Prop) (rank : F.Duration → α)
    (step : ∀ s, I s → ¬ TruthEnv.T M τ s e ψ →
      ∃ u, s < u ∧ I u ∧ (TruthEnv.T M τ u e ψ ∨ r (rank u) (rank s)))
    {t : F.Duration} (ht : I t) :
    TruthEnv.T M τ t e ψ ∨ TruthEnv.T M τ t e (someFuture ψ) :=
  (rank_progress hwf I (fun s => TruthEnv.T M τ s e ψ) rank step ht).imp_right
    (someFuture_iff M τ t e ψ).mpr

/-- Strict pointed-truth progress: `F ψ`, when `ψ` is false now. -/
theorem rank_progress_truth_strict (M : TaskModel F) (τ : WorldHistory F) (e : TruthEnv.Env L F)
    (ψ : L) {α : Type*} {r : α → α → Prop} (hwf : WellFounded r)
    (I : F.Duration → Prop) (rank : F.Duration → α)
    (step : ∀ s, I s → ¬ TruthEnv.T M τ s e ψ →
      ∃ u, s < u ∧ I u ∧ (TruthEnv.T M τ u e ψ ∨ r (rank u) (rank s)))
    {t : F.Duration} (ht : I t) (hnow : ¬ TruthEnv.T M τ t e ψ) :
    TruthEnv.T M τ t e (someFuture ψ) :=
  (rank_progress_truth M τ e ψ hwf I rank step ht).resolve_left hnow

end Progress

end FormalSystem.Semantics.RankProgress
