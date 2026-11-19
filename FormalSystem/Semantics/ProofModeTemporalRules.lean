/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.ProofModeRules

/-!
# Explicit indexed temporal rule interfaces

Thin applications of the shared semantic transfer, bind and persistence theorems. Every
semantic index is explicit, so manual callers and the frontend consume the same opaque API.
-/

assert_not_exists FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass

namespace FormalSystem.Semantics.ProofModeTemporalRules

open FormalSystem.Semantics FormalSystem.Semantics.TruthClauses
open FormalSystem.Semantics.ProofModeRules

variable {L : Type} [TruthEnv L] {F : TaskFrame}

/-- A scoped implication `G(A → B)` meets the kernel's `G` demand at its point. -/
theorem futureDemand_of_allFuture [BotClause L] [ImpClause L] [UntlClause L]
    {M : TaskModel F} {p : Point L F} {A B : L}
    (h : At M p (allFuture (ImpClause.imp A B))) : Step.futureDemand (ImpAt M A B) p :=
  fun s hs => (ImpClause.imp_clause M p.history s p.env A B).mp
    ((allFuture_iff M p.history p.time p.env _).mp h s hs)

/-- A scoped implication `H(A → B)` meets the kernel's `H` demand at its point. -/
theorem pastDemand_of_allPast [BotClause L] [ImpClause L] [SnceClause L]
    {M : TaskModel F} {p : Point L F} {A B : L}
    (h : At M p (allPast (ImpClause.imp A B))) : Step.pastDemand (ImpAt M A B) p :=
  fun s hs => (ImpClause.imp_clause M p.history s p.env A B).mp
    ((allPast_iff M p.history p.time p.env _).mp h s hs)

/-- `G(A → B)` and `G A` give `G B` (the `G` position's transfer). -/
theorem future_map [BotClause L] [ImpClause L] [UntlClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (A B : L)
    (h : TruthEnv.T M τ t e (allFuture (ImpClause.imp A B)))
    (hA : TruthEnv.T M τ t e (allFuture A)) : TruthEnv.T M τ t e (allFuture B) :=
  (Step.future (M := M)).transfer A B ⟨τ, t, e⟩ (futureDemand_of_allFuture h) hA

/-- `G(A → B)` and `F A` give `F B` (the `F` event position's transfer). -/
theorem someFuture_map [BotClause L] [ImpClause L] [UntlClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (A B : L)
    (h : TruthEnv.T M τ t e (allFuture (ImpClause.imp A B)))
    (hA : TruthEnv.T M τ t e (someFuture A)) : TruthEnv.T M τ t e (someFuture B) :=
  (Step.someFutureEvent (M := M)).transfer A B ⟨τ, t, e⟩ (futureDemand_of_allFuture h) hA

/-- `H(A → B)` and `H A` give `H B`. -/
theorem past_map [BotClause L] [ImpClause L] [SnceClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (A B : L)
    (h : TruthEnv.T M τ t e (allPast (ImpClause.imp A B)))
    (hA : TruthEnv.T M τ t e (allPast A)) : TruthEnv.T M τ t e (allPast B) :=
  (Step.past (M := M)).transfer A B ⟨τ, t, e⟩ (pastDemand_of_allPast h) hA

/-- `H(A → B)` and `P A` give `P B`. -/
theorem somePast_map [BotClause L] [ImpClause L] [SnceClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (A B : L)
    (h : TruthEnv.T M τ t e (allPast (ImpClause.imp A B)))
    (hA : TruthEnv.T M τ t e (somePast A)) : TruthEnv.T M τ t e (somePast B) :=
  (Step.somePastEvent (M := M)).transfer A B ⟨τ, t, e⟩ (pastDemand_of_allPast h) hA

/-- Until guard monotonicity: `G(A → g)` turns `U(A, ev)` into `U(g, ev)`. -/
theorem until_guard_map [BotClause L] [ImpClause L] [UntlClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (A g ev : L)
    (h : TruthEnv.T M τ t e (allFuture (ImpClause.imp A g)))
    (hU : TruthEnv.T M τ t e (UntlClause.untl A ev)) :
    TruthEnv.T M τ t e (UntlClause.untl g ev) :=
  (Step.untilGuard (M := M) ev).transfer A g ⟨τ, t, e⟩ (futureDemand_of_allFuture h) hU

/-- Until event monotonicity: `G(A → ev)` turns `U(g, A)` into `U(g, ev)`. -/
theorem until_event_map [BotClause L] [ImpClause L] [UntlClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (g A ev : L)
    (h : TruthEnv.T M τ t e (allFuture (ImpClause.imp A ev)))
    (hU : TruthEnv.T M τ t e (UntlClause.untl g A)) :
    TruthEnv.T M τ t e (UntlClause.untl g ev) :=
  (Step.untilEvent (M := M) g).transfer A ev ⟨τ, t, e⟩ (futureDemand_of_allFuture h) hU

/-- Since guard monotonicity: `H(A → g)` turns `S(A, ev)` into `S(g, ev)`. -/
theorem since_guard_map [BotClause L] [ImpClause L] [SnceClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (A g ev : L)
    (h : TruthEnv.T M τ t e (allPast (ImpClause.imp A g)))
    (hS : TruthEnv.T M τ t e (SnceClause.snce A ev)) :
    TruthEnv.T M τ t e (SnceClause.snce g ev) :=
  (Step.sinceGuard (M := M) ev).transfer A g ⟨τ, t, e⟩ (pastDemand_of_allPast h) hS

/-- Since event monotonicity: `H(A → ev)` turns `S(g, A)` into `S(g, ev)`. -/
theorem since_event_map [BotClause L] [ImpClause L] [SnceClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (g A ev : L)
    (h : TruthEnv.T M τ t e (allPast (ImpClause.imp A ev)))
    (hS : TruthEnv.T M τ t e (SnceClause.snce g A)) :
    TruthEnv.T M τ t e (SnceClause.snce g ev) :=
  (Step.sinceEvent (M := M) g).transfer A ev ⟨τ, t, e⟩ (pastDemand_of_allPast h) hS

/-- `someFuture_bind` with explicit indices. -/
theorem future_bind [BotClause L] [ImpClause L] [UntlClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (A B : L)
    (hA : TruthEnv.T M τ t e (someFuture A))
    (body : ∀ s, t < s → TruthEnv.T M τ s e A → TruthEnv.T M τ s e (someFuture B)) :
    TruthEnv.T M τ t e (someFuture B) :=
  someFuture_bind hA body

/-- `somePast_bind` with explicit indices. -/
theorem past_bind [BotClause L] [ImpClause L] [SnceClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (A B : L)
    (hA : TruthEnv.T M τ t e (somePast A))
    (body : ∀ s, s < t → TruthEnv.T M τ s e A → TruthEnv.T M τ s e (somePast B)) :
    TruthEnv.T M τ t e (somePast B) :=
  somePast_bind hA body

/-- `allFuture_persist` with explicit indices. -/
theorem future_persist [BotClause L] [ImpClause L] [UntlClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t s : F.Duration) (e : TruthEnv.Env L F) (P : L)
    (h : TruthEnv.T M τ t e (allFuture P)) (hts : t < s) : TruthEnv.T M τ s e (allFuture P) :=
  allFuture_persist h hts

/-- `allPast_persist` with explicit indices. -/
theorem past_persist [BotClause L] [ImpClause L] [SnceClause L] (M : TaskModel F)
    (τ : WorldHistory F) (t s : F.Duration) (e : TruthEnv.Env L F) (P : L)
    (h : TruthEnv.T M τ t e (allPast P)) (hst : s < t) : TruthEnv.T M τ s e (allPast P) :=
  allPast_persist h hst

/-- `next_at` with explicit indices: `X P` at `t` gives `P` at a known cover `s`. -/
theorem next_at' [BotClause L] [UntlClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t s : F.Duration) (e : TruthEnv.Env L F) (P : L) (hcov : t ⋖ s)
    (h : TruthEnv.T M τ t e (next P)) : TruthEnv.T M τ s e P :=
  next_at hcov h

/-- `prev_at` with explicit indices: `Y P` at `t` gives `P` at a known covered `s`. -/
theorem prev_at' [BotClause L] [SnceClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t s : F.Duration) (e : TruthEnv.Env L F) (P : L) (hcov : s ⋖ t)
    (h : TruthEnv.T M τ t e (prev P)) : TruthEnv.T M τ s e P :=
  prev_at hcov h

end FormalSystem.Semantics.ProofModeTemporalRules
