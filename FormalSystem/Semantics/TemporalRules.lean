/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.TruthClauses

/-! Covering-time Next and Previous, strict G/H persistence, and F/P witness composition.

The rules work over the duration order of the frame. Next and Previous require an order
cover. The bind rules carry only the named future or past guarantees to their witnesses.
 -/

assert_not_exists FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass

namespace FormalSystem.Semantics.TemporalRules

open TruthClauses

section NextPrev
variable {L : Type} [TruthEnv L] [BotClause L] {F : TaskFrame}

/-- Next (`Xφ`): `⊥ U φ`, guard first. Same encoding as `Formula.next`/`PlusFormula.next`. -/
abbrev next [UntlClause L] (φ : L) : L := UntlClause.untl BotClause.bot φ

/-- Previous (`Yφ`): `⊥ S φ`, guard first. Same encoding as `Formula.prev`/`PlusFormula.prev`. -/
abbrev prev [SnceClause L] (φ : L) : L := SnceClause.snce BotClause.bot φ

/-- Truth of `Xφ`: `φ` holds at a time covering the current one. The `⊥` guard on the open
interval is exactly the covering condition; no successor function or discreteness is assumed. -/
theorem next_iff [UntlClause L] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (next φ) ↔ ∃ s : F.Duration, t ⋖ s ∧ TruthEnv.T M τ s e φ := by
  rw [next, UntlClause.untl_clause]
  constructor
  · rintro ⟨s, hts, hφ, hguard⟩
    exact ⟨s, ⟨hts, fun r htr hrs => BotClause.bot_clause M τ r e (hguard r htr hrs)⟩, hφ⟩
  · rintro ⟨s, hcov, hφ⟩
    exact ⟨s, hcov.1, hφ, fun r htr hrs => absurd hrs (hcov.2 htr)⟩

/-- Truth of `Yφ`: `φ` held at a time covered by the current one. -/
theorem prev_iff [SnceClause L] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (prev φ) ↔ ∃ s : F.Duration, s ⋖ t ∧ TruthEnv.T M τ s e φ := by
  rw [prev, SnceClause.snce_clause]
  constructor
  · rintro ⟨s, hst, hφ, hguard⟩
    exact ⟨s, ⟨hst, fun r hsr hrt => BotClause.bot_clause M τ r e (hguard r hsr hrt)⟩, hφ⟩
  · rintro ⟨s, hcov, hφ⟩
    exact ⟨s, hcov.1, hφ, fun r hsr hrt => absurd hrt (hcov.2 hsr)⟩

/-- Eliminate `Xφ` at a **known** cover: the cover of `t` is unique in a linear order, so the
`Xφ` witness is that time. -/
theorem next_at [UntlClause L] {M : TaskModel F} {τ : WorldHistory F} {t s : F.Duration}
    {e : TruthEnv.Env L F} {φ : L} (hcov : t ⋖ s) (h : TruthEnv.T M τ t e (next φ)) :
    TruthEnv.T M τ s e φ := by
  obtain ⟨s', hcov', hφ⟩ := (next_iff M τ t e φ).mp h
  exact CovBy.unique_right hcov' hcov ▸ hφ

/-- Eliminate `Yφ` at a known covered time. -/
theorem prev_at [SnceClause L] {M : TaskModel F} {τ : WorldHistory F} {t s : F.Duration}
    {e : TruthEnv.Env L F} {φ : L} (hcov : s ⋖ t) (h : TruthEnv.T M τ t e (prev φ)) :
    TruthEnv.T M τ s e φ := by
  obtain ⟨s', hcov', hφ⟩ := (prev_iff M τ t e φ).mp h
  exact CovBy.unique_left hcov' hcov ▸ hφ

end NextPrev

section Persistence
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] {F : TaskFrame}
  {M : TaskModel F} {τ : WorldHistory F} {e : TruthEnv.Env L F}

/-- `G P` persists to every strictly later point of the same history (transitivity of `<`). -/
theorem allFuture_persist [UntlClause L] {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (allFuture P)) (hts : t < s) :
    TruthEnv.T M τ s e (allFuture P) :=
  (allFuture_iff M τ s e P).mpr fun u hsu =>
    (allFuture_iff M τ t e P).mp h u (lt_trans hts hsu)

/-- `H P` persists to every strictly earlier point of the same history. -/
theorem allPast_persist [SnceClause L] {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (allPast P)) (hst : s < t) :
    TruthEnv.T M τ s e (allPast P) :=
  (allPast_iff M τ s e P).mpr fun u hus =>
    (allPast_iff M τ t e P).mp h u (lt_trans hus hst)

/-- **Eventuality bind.** Focus the `F A` witness; an eventual conclusion `F B` there yields `F B`
at the original point. The witness's strict ordering is supplied to the body. -/
theorem someFuture_bind [UntlClause L] {t : F.Duration} {A B : L}
    (hA : TruthEnv.T M τ t e (someFuture A))
    (body : ∀ s, t < s → TruthEnv.T M τ s e A → TruthEnv.T M τ s e (someFuture B)) :
    TruthEnv.T M τ t e (someFuture B) := by
  obtain ⟨s, hts, hs⟩ := (someFuture_iff M τ t e A).mp hA
  obtain ⟨u, hsu, hu⟩ := (someFuture_iff M τ s e B).mp (body s hts hs)
  exact (someFuture_iff M τ t e B).mpr ⟨u, lt_trans hts hsu, hu⟩

/-- **Eventuality bind keeping `G` facts.** Every selected guarantee `G P` is available at the
witness, by `allFuture_persist`. Other point-local facts are not carried. -/
theorem someFuture_bind_keeping [UntlClause L] {t : F.Duration} {A B : L} (keep : List L)
    (hkeep : ∀ P ∈ keep, TruthEnv.T M τ t e (allFuture P))
    (hA : TruthEnv.T M τ t e (someFuture A))
    (body : ∀ s, t < s → (∀ P ∈ keep, TruthEnv.T M τ s e (allFuture P)) →
      TruthEnv.T M τ s e A → TruthEnv.T M τ s e (someFuture B)) :
    TruthEnv.T M τ t e (someFuture B) :=
  someFuture_bind hA fun s hts hs =>
    body s hts (fun P hP => allFuture_persist (hkeep P hP) hts) hs

/-- Past eventuality bind. -/
theorem somePast_bind [SnceClause L] {t : F.Duration} {A B : L}
    (hA : TruthEnv.T M τ t e (somePast A))
    (body : ∀ s, s < t → TruthEnv.T M τ s e A → TruthEnv.T M τ s e (somePast B)) :
    TruthEnv.T M τ t e (somePast B) := by
  obtain ⟨s, hst, hs⟩ := (somePast_iff M τ t e A).mp hA
  obtain ⟨u, hus, hu⟩ := (somePast_iff M τ s e B).mp (body s hst hs)
  exact (somePast_iff M τ t e B).mpr ⟨u, lt_trans hus hst, hu⟩

/-- Past eventuality bind keeping selected `H` facts. -/
theorem somePast_bind_keeping [SnceClause L] {t : F.Duration} {A B : L} (keep : List L)
    (hkeep : ∀ P ∈ keep, TruthEnv.T M τ t e (allPast P))
    (hA : TruthEnv.T M τ t e (somePast A))
    (body : ∀ s, s < t → (∀ P ∈ keep, TruthEnv.T M τ s e (allPast P)) →
      TruthEnv.T M τ s e A → TruthEnv.T M τ s e (somePast B)) :
    TruthEnv.T M τ t e (somePast B) :=
  somePast_bind hA fun s hst hs =>
    body s hst (fun P hP => allPast_persist (hkeep P hP) hst) hs

end Persistence

end FormalSystem.Semantics.TemporalRules
