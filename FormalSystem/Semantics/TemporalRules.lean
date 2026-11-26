/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve, Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TruthClauses

/-!
# Covering-time Next and Previous, persistence, and witness composition

The rules work over the duration order of the frame. Next and Previous require an order
cover. The bind rules carry only the named future or past guarantees to their witnesses.

Every result is stated over the clause classes of `FormalSystem/Semantics/TruthClauses.lean`, so
each one is proved once for every language instantiating the classes it names rather than at a
single syntax.

## Main Results

- `next_iff`, `prev_iff` — `Xφ` and `Yφ` as existentials over a covering time
- `next_at`, `prev_at` — elimination of `Xφ` and `Yφ` at a known covering time
- `next_iff_succ`, `prev_iff_pred` — the discrete collapse of the covering-time reading to
  `Order.succ`/`Order.pred` on a carrier with successors and no maximum (resp. predecessors and
  no minimum)
- `allFuture_persist`, `allPast_persist` — `Gφ` and `Hφ` persist along `<`
- `allFuture_persist_of_tense`, `allPast_persist_of_tense` — the same persistence for a
  tense-primitive language, asking for `AllFutureClause`/`AllPastClause` alone
- `someFuture_bind`, `somePast_bind` — composition at an eventuality witness
- `someFuture_bind_keeping`, `somePast_bind_keeping` — the same, carrying named `G`/`H` facts

## References

* `FormalSystem/Semantics/TruthClauses.lean` — the clause classes
* `FormalSystem/Syntax/Connectives.lean` — the derived tense operators, with `Sig.next` and
  `Sig.prev`, the one `⊥ U φ` / `⊥ S φ` encoding the covering-time rules are stated about
* `FormalSystem/Semantics/TemporalIntervals.lean` — the inclusive, weak and strict dual clauses
* `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` — the per-language test rows

## Tags

temporal · next · previous · persistence · eventuality · covering-time · generic
-/

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree

namespace FormalSystem.Semantics.TemporalRules

open TruthClauses
open FormalSystem.Syntax FormalSystem.Syntax.Sig

section NextPrev
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] {F : TaskFrame}

/-- Truth of `Xφ`: `φ` holds at a time covering the current one. The `⊥` guard on the open
interval is exactly the covering condition; no successor function or discreteness is assumed. -/
theorem next_iff [HasUntl L] [UntlClause L] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (next φ) ↔ ∃ s : F.Duration, t ⋖ s ∧ TruthEnv.T M τ s e φ := by
  rw [next, UntlClause.untl_clause]
  constructor
  · rintro ⟨s, hts, hφ, hguard⟩
    exact ⟨s, ⟨hts, fun r htr hrs => BotClause.bot_clause M τ r e (hguard r htr hrs)⟩, hφ⟩
  · rintro ⟨s, hcov, hφ⟩
    exact ⟨s, hcov.1, hφ, fun r htr hrs => absurd hrs (hcov.2 htr)⟩

/-- Truth of `Yφ`: `φ` held at a time covered by the current one. -/
theorem prev_iff [HasSnce L] [SnceClause L] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
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
theorem next_at [HasUntl L] [UntlClause L] {M : TaskModel F} {τ : WorldHistory F} {t s : F.Duration}
    {e : TruthEnv.Env L F} {φ : L} (hcov : t ⋖ s) (h : TruthEnv.T M τ t e (next φ)) :
    TruthEnv.T M τ s e φ := by
  obtain ⟨s', hcov', hφ⟩ := (next_iff M τ t e φ).mp h
  exact CovBy.unique_right hcov' hcov ▸ hφ

/-- Eliminate `Yφ` at a known covered time. -/
theorem prev_at [HasSnce L] [SnceClause L] {M : TaskModel F} {τ : WorldHistory F} {t s : F.Duration}
    {e : TruthEnv.Env L F} {φ : L} (hcov : s ⋖ t) (h : TruthEnv.T M τ t e (prev φ)) :
    TruthEnv.T M τ s e φ := by
  obtain ⟨s', hcov', hφ⟩ := (prev_iff M τ t e φ).mp h
  exact CovBy.unique_left hcov' hcov ▸ hφ

end NextPrev

section DiscreteCollapse
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] {F : TaskFrame}

/-- **The discrete collapse of `next_iff`.** On a carrier with successors and no maximum the
covering witness is `Order.succ t`, so `Xφ` is `φ` at the successor.

`next_iff` is the theorem and this is its corollary: the covering-time reading holds over any
temporal order, while this one needs discreteness. On a dense carrier `Xφ` is unsatisfiable, so a
reading that asserted the successor form unconditionally would be false. -/
theorem next_iff_succ [HasUntl L] [UntlClause L] [SuccOrder F.Duration] [NoMaxOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (next φ) ↔ TruthEnv.T M τ (Order.succ t) e φ := by
  rw [next_iff]
  constructor
  · rintro ⟨s, hcov, hs⟩
    rcases lt_or_eq_of_le (Order.succ_le_of_lt hcov.1) with h | h
    · exact absurd h (hcov.2 (Order.lt_succ t))
    · exact h ▸ hs
  · intro h
    exact ⟨Order.succ t, ⟨Order.lt_succ t, fun _r hr hrs =>
      absurd hr (not_lt.mpr (Order.le_of_lt_succ hrs))⟩, h⟩

/-- **The discrete collapse of `prev_iff`**, dual of `next_iff_succ`. `prev_iff` is the theorem;
this is the corollary that discreteness buys. -/
theorem prev_iff_pred [HasSnce L] [SnceClause L] [PredOrder F.Duration] [NoMinOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (prev φ) ↔ TruthEnv.T M τ (Order.pred t) e φ := by
  rw [prev_iff]
  constructor
  · rintro ⟨s, hcov, hs⟩
    rcases lt_or_eq_of_le (Order.le_pred_of_lt hcov.1) with h | h
    · exact absurd (Order.pred_lt t) (hcov.2 h)
    · exact h ▸ hs
  · intro h
    exact ⟨Order.pred t, ⟨Order.pred_lt t, fun _r hr =>
      not_lt.mpr (Order.le_of_pred_lt hr)⟩, h⟩

end DiscreteCollapse

section Persistence
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] {F : TaskFrame}
  {M : TaskModel F} {τ : WorldHistory F} {e : TruthEnv.Env L F}

/-- `G P` persists to every strictly later point of the same history (transitivity of `<`). -/
theorem allFuture_persist [HasUntl L] [UntlClause L] {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (allFuture P)) (hts : t < s) :
    TruthEnv.T M τ s e (allFuture P) :=
  (allFuture_iff M τ s e P).mpr fun u hsu =>
    (allFuture_iff M τ t e P).mp h u (lt_trans hts hsu)

/-- `H P` persists to every strictly earlier point of the same history. -/
theorem allPast_persist [HasSnce L] [SnceClause L] {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (allPast P)) (hst : s < t) :
    TruthEnv.T M τ s e (allPast P) :=
  (allPast_iff M τ s e P).mpr fun u hus =>
    (allPast_iff M τ t e P).mp h u (lt_trans hus hst)

omit [BotClause L] in
/-- **Eventuality bind.** Focus the `F A` witness; an eventual conclusion `F B` there yields `F B`
at the original point. The witness's strict ordering is supplied to the body. -/
theorem someFuture_bind [HasUntl L] [UntlClause L] {t : F.Duration} {A B : L}
    (hA : TruthEnv.T M τ t e (someFuture A))
    (body : ∀ s, t < s → TruthEnv.T M τ s e A → TruthEnv.T M τ s e (someFuture B)) :
    TruthEnv.T M τ t e (someFuture B) := by
  obtain ⟨s, hts, hs⟩ := (someFuture_iff M τ t e A).mp hA
  obtain ⟨u, hsu, hu⟩ := (someFuture_iff M τ s e B).mp (body s hts hs)
  exact (someFuture_iff M τ t e B).mpr ⟨u, lt_trans hts hsu, hu⟩

/-- **Eventuality bind keeping `G` facts.** Every selected guarantee `G P` is available at the
witness, by `allFuture_persist`. Other point-local facts are not carried. -/
theorem someFuture_bind_keeping [HasUntl L] [UntlClause L] {t : F.Duration} {A B : L}
    (keep : List L)
    (hkeep : ∀ P ∈ keep, TruthEnv.T M τ t e (allFuture P))
    (hA : TruthEnv.T M τ t e (someFuture A))
    (body : ∀ s, t < s → (∀ P ∈ keep, TruthEnv.T M τ s e (allFuture P)) →
      TruthEnv.T M τ s e A → TruthEnv.T M τ s e (someFuture B)) :
    TruthEnv.T M τ t e (someFuture B) :=
  someFuture_bind hA fun s hts hs =>
    body s hts (fun P hP => allFuture_persist (hkeep P hP) hts) hs

omit [BotClause L] in
/-- Past eventuality bind. -/
theorem somePast_bind [HasSnce L] [SnceClause L] {t : F.Duration} {A B : L}
    (hA : TruthEnv.T M τ t e (somePast A))
    (body : ∀ s, s < t → TruthEnv.T M τ s e A → TruthEnv.T M τ s e (somePast B)) :
    TruthEnv.T M τ t e (somePast B) := by
  obtain ⟨s, hst, hs⟩ := (somePast_iff M τ t e A).mp hA
  obtain ⟨u, hus, hu⟩ := (somePast_iff M τ s e B).mp (body s hst hs)
  exact (somePast_iff M τ t e B).mpr ⟨u, lt_trans hus hst, hu⟩

/-- Past eventuality bind keeping selected `H` facts. -/
theorem somePast_bind_keeping [HasSnce L] [SnceClause L] {t : F.Duration} {A B : L} (keep : List L)
    (hkeep : ∀ P ∈ keep, TruthEnv.T M τ t e (allPast P))
    (hA : TruthEnv.T M τ t e (somePast A))
    (body : ∀ s, s < t → (∀ P ∈ keep, TruthEnv.T M τ s e (allPast P)) →
      TruthEnv.T M τ s e A → TruthEnv.T M τ s e (somePast B)) :
    TruthEnv.T M τ t e (somePast B) :=
  somePast_bind hA fun s hst hs =>
    body s hst (fun P hP => allPast_persist (hkeep P hP) hst) hs

end Persistence

section TensePersistence

/-- `G P` persists to every strictly later point, for a **tense-primitive** language. This is the
primitive-tense sibling of `allFuture_persist`: that one routes through `untl`, so it reaches only
a language carrying `UntlClause`, while this one asks for `AllFutureClause` alone and so is the
form L⁻ — which has `TenseClauses` and no `untl` — can use. -/
theorem allFuture_persist_of_tense {L : Type} [TruthEnv L] [HasAllFuture L] [AllFutureClause L]
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {e : TruthEnv.Env L F}
    {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (HasAllFuture.allFuture P)) (hts : t < s) :
    TruthEnv.T M τ s e (HasAllFuture.allFuture P) :=
  (AllFutureClause.allFuture_clause M τ s e P).mpr fun u hsu =>
    (AllFutureClause.allFuture_clause M τ t e P).mp h u (lt_trans hts hsu)

/-- `H P` persists to every strictly earlier point, for a **tense-primitive** language: the
primitive-tense sibling of `allPast_persist`, asking for `AllPastClause` alone and so reaching
L⁻, which has no `snce`. -/
theorem allPast_persist_of_tense {L : Type} [TruthEnv L] [HasAllPast L] [AllPastClause L]
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {e : TruthEnv.Env L F}
    {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (HasAllPast.allPast P)) (hst : s < t) :
    TruthEnv.T M τ s e (HasAllPast.allPast P) :=
  (AllPastClause.allPast_clause M τ s e P).mpr fun u hus =>
    (AllPastClause.allPast_clause M τ t e P).mp h u (lt_trans hus hst)

end TensePersistence

end FormalSystem.Semantics.TemporalRules
