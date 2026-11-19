/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Semantics.TruthClauses

/-!
# Generic pointed-semantic proof-mode rules (P4/P5)

Pure semantic rules for the pointed proof mode, written once over the operator classes of
`Semantics/TruthClauses.lean`. Every statement is about the existing `TruthEnv.T M τ t e A`; there
is no new formula type, model, or recursor, and each lemma names only the clause classes its proof
consumes. Everything is a Lean proof reconstructed from those clauses; no derivation, soundness or
completeness theorem is reachable from this module (see the `assert_not_exists` below).

## Main Definitions

- `next`, `prev` — `U(⊥, A)` and `S(⊥, A)` over `BotClause` + `UntlClause`/`SnceClause`. They
  coincide character for character with `Formula.next`/`prev` and `PlusFormula.next`/`prev`
  (`Formula.untl Formula.bot φ` and `PlusFormula.untl PlusFormula.bot φ`).
- `Point`, `At`, `ImpAt`, `IffAt` — a pointed judgment: history, time and inert environment, at a
  fixed frame and model.
- `Oriented`, `Step` — the semantic scope-demand kernel: a formula position with a
  predicate-transformer demand, its pointwise transfer theorem, demand monotonicity and demand
  necessitation. `Step.comp` nests positions outermost first.
- `Step.impLeft`, `.impRight`, `.box`, `.stab`, `.untilGuard`, `.untilEvent`, `.sinceGuard`,
  `.sinceEvent`, `.future`, `.past`, `.nextCover`, `.prevCover` — the primitive and G/H positions,
  and the derived views `.negBody`, `.andLeft`, `.andRight`, `.orLeft`, `.orRight`,
  `.diamondBody`, `.dstabBody`, `.someFutureEvent`, `.somePastEvent`, `.nextFuture`, `.prevPast`.
- `FactTransport`, `GoalTransport` — one-way certificates between fully indexed judgments.

## Main Results

- `next_iff`, `prev_iff` — `U(⊥,A)` at `t` iff `A` at a covering time `t ⋖ s` (resp. `s ⋖ t`).
  No discreteness or successor function is assumed: existence of the cover is the content.
- `Step.rewriteFact`, `.rewriteGoal`, `.rewriteFactOfIff`, `.rewriteGoalOfIff`, `.ofClosed` —
  leaf discharge in the polarity table of plan §3.1.
- `allFuture_persist`, `allPast_persist` — `G P` (`H P`) holds at every strictly later (earlier)
  point on the same history.
- `someFuture_bind`, `someFuture_bind_keeping` (and past mirrors) — eventuality bind retaining
  selected `G`/`H` facts at the witness.
- `rank_progress`, `rank_progress_strict` — well-founded progress over any preorder of times,
  and `rank_progress_truth`, `rank_progress_truth_strict` at a pointed truth target.

## Design notes

* **Positions.** Each `Step` fixes its formula constructor in `wrap`; the names in
  `Automation/ProofMode/Positions.lean` map one-to-one: `impLeft`/`impRight` ↦ `Step.impLeft C` /
  `Step.impRight C` (the sibling is retained), `boxBody` ↦ `Step.box`, `stabilityBody` ↦
  `Step.stab`, `futureBody`/`pastBody` ↦ `Step.future`/`Step.past`, `untilGuard`/`untilEvent` ↦
  `Step.untilGuard e`/`Step.untilEvent g`, `sinceGuard`/`sinceEvent` likewise, `nextBody` ↦
  `Step.nextCover` or the conservative `Step.nextFuture`, `prevBody` ↦ `Step.prevCover` /
  `Step.prevPast`, and the derived views `negBody`, `andLeft`, … ↦ the compositions below, whose
  `wrap` equals the derived operator by `rfl`.
* **Polarity.** As in the native `Congruence.Step`: `flips` is the polarity, composition takes the
  exclusive or, demands compose outermost first. The proofs are separate `Prop` builders.
* **Demand necessitation.** `Step.demandAll` is the semantic counterpart of closed necessitation: a
  fact true at *every* point of the model discharges any demand (`Step.ofClosed`). A point-specific
  `Iff` discharges only the identity demand; nothing generalizes a point silently.
* **Until/Since.** Guard and event positions use the conservative `G`/`H` demands, as the native
  table does; the transfers read the actual strict open-interval clause, and the guard is never
  required at an endpoint.
* **Progress.** `rank_progress` keeps the occurrence premise `∃ u, s < u ∧ …` in its step. A rank
  that only decreases *if* a step happens proves nothing here.
-/

-- Lower semantic layer: must not reach the proof system, soundness, or a concrete language.
assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass
  FormalSystem.Semantics.TruthAt

namespace FormalSystem.Semantics.ProofModeRules

open TruthClauses

/-! ## Next and Previous over covering times -/

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

/-! ## Pointed judgments -/

/-- A point of evaluation: a typed world history, a time and the inert environment. -/
structure Point (L : Type) [TruthEnv L] (F : TaskFrame) where
  /-- The world history. -/
  history : WorldHistory F
  /-- The evaluation time. -/
  time : F.Duration
  /-- The inert environment (`PUnit.unit` for TM/TM⁺). -/
  env : TruthEnv.Env L F

section Pointed
variable {L : Type} [TruthEnv L] {F : TaskFrame}

/-- The existing truth relation at a point. -/
abbrev At (M : TaskModel F) (p : Point L F) (A : L) : Prop :=
  TruthEnv.T M p.history p.time p.env A

/-- Pointwise truth implication `At p A → At p B`: the leaf predicate of a rewrite. -/
abbrev ImpAt (M : TaskModel F) (A B : L) (p : Point L F) : Prop := At M p A → At M p B

/-- Pointwise truth equivalence. -/
abbrev IffAt (M : TaskModel F) (A B : L) (p : Point L F) : Prop := At M p A ↔ At M p B

/-- An implication oriented by a polarity: `X → Y` when positive, `Y → X` when flipped. -/
def Oriented : Bool → Prop → Prop → Prop
  | false, X, Y => X → Y
  | true, X, Y => Y → X

/-- The leaf predicate needed to move `wrap A` to `wrap B` at polarity `flips`. -/
def OrientedAt (M : TaskModel F) (flips : Bool) (A B : L) (p : Point L F) : Prop :=
  Oriented flips (At M p A) (At M p B)

end Pointed

/-! ## The semantic scope-demand kernel -/

/--
One formula position for pointed truth in a fixed model: the constructor context `wrap`, the
predicate-transformer `demand` under which a rewrite at that position must hold, and the polarity
`flips`. The transfer is pointwise:

```text
demand (ImpAt A B) p → (At p (wrap A) → At p (wrap B))     -- flips = false
demand (ImpAt A B) p → (At p (wrap B) → At p (wrap A))     -- flips = true
```
-/
structure Step (L : Type) [TruthEnv L] {F : TaskFrame} (M : TaskModel F) where
  /-- Plug a formula into this position. -/
  wrap : L → L
  /-- The points at which a replacement must hold, as a predicate transformer. -/
  demand : (Point L F → Prop) → Point L F → Prop
  /-- Whether the position is antitone (an implication antecedent). -/
  flips : Bool
  /-- Pointwise transfer of a demanded implication, oriented by `flips`. -/
  transfer : ∀ (A B : L) (p : Point L F), demand (ImpAt M A B) p →
    Oriented flips (At M p (wrap A)) (At M p (wrap B))
  /-- The demand is monotone under pointwise implication. -/
  demandMono : ∀ {Q R : Point L F → Prop}, (∀ q, Q q → R q) → ∀ p, demand Q p → demand R p
  /-- A predicate true at every point of the model meets the demand everywhere. -/
  demandAll : ∀ {Q : Point L F → Prop}, (∀ q, Q q) → ∀ p, demand Q p

namespace Step

variable {L : Type} [TruthEnv L] {F : TaskFrame} {M : TaskModel F}

/-- The empty path: identity wrap and demand. -/
def identity (M : TaskModel F) : Step L M where
  wrap x := x
  demand Q := Q
  flips := false
  transfer _ _ _ h := h
  demandMono h := h
  demandAll h := h

/-- Composite transfer. The inner transfer is lifted through the outer demand, then the outer
transfer is applied at swapped arguments when the inner position flips. -/
theorem compTransfer (outer inner : Step L M) (A B : L) (p : Point L F)
    (h : outer.demand (inner.demand (ImpAt M A B)) p) :
    Oriented (outer.flips ^^ inner.flips)
      (At M p (outer.wrap (inner.wrap A))) (At M p (outer.wrap (inner.wrap B))) := by
  have hFwd := outer.transfer (inner.wrap A) (inner.wrap B) p
  have hRev := outer.transfer (inner.wrap B) (inner.wrap A) p
  have hInner : ∀ q, inner.demand (ImpAt M A B) q →
      Oriented inner.flips (At M q (inner.wrap A)) (At M q (inner.wrap B)) :=
    inner.transfer A B
  revert hFwd hRev hInner
  cases outer.flips <;> cases inner.flips <;> intro hFwd hRev hInner
  · exact hFwd (outer.demandMono hInner p h)
  · exact hRev (outer.demandMono hInner p h)
  · exact hFwd (outer.demandMono hInner p h)
  · exact hRev (outer.demandMono hInner p h)

/-- Compose an outer position with an inner one: wraps and demands nest outermost first,
polarities combine by exclusive or. -/
def comp (outer inner : Step L M) : Step L M where
  wrap x := outer.wrap (inner.wrap x)
  demand Q := outer.demand (inner.demand Q)
  flips := outer.flips ^^ inner.flips
  transfer := compTransfer outer inner
  demandMono h := outer.demandMono (inner.demandMono h)
  demandAll h := outer.demandAll (inner.demandAll h)

/-- Compose a list of positions, outermost first. -/
def path (M : TaskModel F) : List (Step L M) → Step L M
  | [] => identity M
  | s :: ss => s.comp (path M ss)

/-! ### Leaf discharge, by target role and total polarity (plan §3.1) -/

/-- **Fact rewriting.** Turn the fact `wrap A` into `wrap B`. A positive position needs
`A → B` under the demand, a negative one `B → A`. -/
theorem rewriteFact (S : Step L M) {A B : L} {p : Point L F}
    (h : S.demand (OrientedAt M S.flips A B) p) : At M p (S.wrap A) → At M p (S.wrap B) := by
  have hT := S.transfer
  revert h hT
  cases S.flips <;> intro h hT
  · exact hT A B p h
  · exact hT B A p h

/-- **Goal rewriting.** Reduce the goal `wrap A` to the new goal `wrap B`. A positive position
needs `B → A` under the demand, a negative one `A → B`. -/
theorem rewriteGoal (S : Step L M) {A B : L} {p : Point L F}
    (h : S.demand (OrientedAt M S.flips B A) p) : At M p (S.wrap B) → At M p (S.wrap A) :=
  S.rewriteFact h

/-- A scoped equivalence supplies the fact direction at either polarity. -/
theorem rewriteFactOfIff (S : Step L M) {A B : L} {p : Point L F}
    (h : S.demand (IffAt M A B) p) : At M p (S.wrap A) → At M p (S.wrap B) := by
  refine S.rewriteFact (S.demandMono (fun q hq => ?_) p h)
  unfold OrientedAt
  cases S.flips
  · exact hq.mp
  · exact hq.mpr

/-- A scoped equivalence supplies the goal direction at either polarity. -/
theorem rewriteGoalOfIff (S : Step L M) {A B : L} {p : Point L F}
    (h : S.demand (IffAt M A B) p) : At M p (S.wrap B) → At M p (S.wrap A) :=
  S.rewriteFactOfIff (S.demandMono (fun _ hq => hq.symm) p h)

/-- A model-wide (closed) leaf predicate meets any demand. -/
theorem ofClosed (S : Step L M) {Q : Point L F → Prop} (h : ∀ q, Q q) (p : Point L F) :
    S.demand Q p :=
  S.demandAll h p

end Step

/-! ### Primitive positions -/

namespace Step

variable {L : Type} [TruthEnv L] {F : TaskFrame} {M : TaskModel F}

/-- The `G` demand: every strictly later point on the same history. -/
def futureDemand (Q : Point L F → Prop) (p : Point L F) : Prop :=
  ∀ s : F.Duration, p.time < s → Q ⟨p.history, s, p.env⟩

/-- The `H` demand: every strictly earlier point on the same history. -/
def pastDemand (Q : Point L F → Prop) (p : Point L F) : Prop :=
  ∀ s : F.Duration, s < p.time → Q ⟨p.history, s, p.env⟩

/-- The `X` covering demand: the covering point(s) of the current time. -/
def nextDemand (Q : Point L F → Prop) (p : Point L F) : Prop :=
  ∀ s : F.Duration, p.time ⋖ s → Q ⟨p.history, s, p.env⟩

/-- The `Y` covering demand. -/
def prevDemand (Q : Point L F → Prop) (p : Point L F) : Prop :=
  ∀ s : F.Duration, s ⋖ p.time → Q ⟨p.history, s, p.env⟩

/-- The `□` demand: every history at the same time. -/
def boxDemand (Q : Point L F → Prop) (p : Point L F) : Prop :=
  ∀ σ : WorldHistory F, Q ⟨σ, p.time, p.env⟩

/-- The `⊡` demand: every history in the same current state at the same time. -/
def stabDemand (Q : Point L F → Prop) (p : Point L F) : Prop :=
  ∀ σ : WorldHistory F, p.history.state p.time = σ.state p.time → Q ⟨σ, p.time, p.env⟩

/-- Implication antecedent `X ↦ X → C`: identity demand, flipped polarity. -/
def impLeft [ImpClause L] (C : L) : Step L M where
  wrap X := ImpClause.imp X C
  demand Q := Q
  flips := true
  transfer A B p h := by
    change At M p (ImpClause.imp B C) → At M p (ImpClause.imp A C)
    simp only [At, ImpClause.imp_clause]
    exact fun hB hA => hB (h hA)
  demandMono h := h
  demandAll h := h

/-- Implication consequent `X ↦ C → X`: identity demand. -/
def impRight [ImpClause L] (C : L) : Step L M where
  wrap X := ImpClause.imp C X
  demand Q := Q
  flips := false
  transfer A B p h := by
    change At M p (ImpClause.imp C A) → At M p (ImpClause.imp C B)
    simp only [At, ImpClause.imp_clause]
    exact fun hA hC => h (hA hC)
  demandMono h := h
  demandAll h := h

/-- `□` body: every history at the same time. -/
def box [BoxClause L] : Step L M where
  wrap := BoxClause.box
  demand := boxDemand
  flips := false
  transfer A B p h := by
    change At M p (BoxClause.box A) → At M p (BoxClause.box B)
    simp only [At, BoxClause.box_clause]
    exact fun hA σ => h σ (hA σ)
  demandMono h _ hp σ := h _ (hp σ)
  demandAll h _ σ := h _

/-- `⊡` body: every history in the same state at the same time. -/
def stab [StabClause L] : Step L M where
  wrap := StabClause.stab
  demand := stabDemand
  flips := false
  transfer A B p h := by
    change At M p (StabClause.stab A) → At M p (StabClause.stab B)
    simp only [At, StabClause.stab_clause]
    exact fun hA σ hs => h σ hs (hA σ hs)
  demandMono h _ hp σ hs := h _ (hp σ hs)
  demandAll h _ _ _ := h _

/-- Until guard `X ↦ U(X, event)`, under the conservative `G` demand. The guard is read only on
the strict open interval before the witness. -/
def untilGuard [UntlClause L] (event : L) : Step L M where
  wrap X := UntlClause.untl X event
  demand := futureDemand
  flips := false
  transfer A B p h := by
    change At M p (UntlClause.untl A event) → At M p (UntlClause.untl B event)
    simp only [At, UntlClause.untl_clause]
    rintro ⟨s, hts, hev, hg⟩
    exact ⟨s, hts, hev, fun r htr hrs => h r htr (hg r htr hrs)⟩
  demandMono h _ hp s hs := h _ (hp s hs)
  demandAll h _ _ _ := h _

/-- Until event `X ↦ U(guard, X)`, under the `G` demand. -/
def untilEvent [UntlClause L] (guard : L) : Step L M where
  wrap X := UntlClause.untl guard X
  demand := futureDemand
  flips := false
  transfer A B p h := by
    change At M p (UntlClause.untl guard A) → At M p (UntlClause.untl guard B)
    simp only [At, UntlClause.untl_clause]
    rintro ⟨s, hts, hev, hg⟩
    exact ⟨s, hts, h s hts hev, hg⟩
  demandMono h _ hp s hs := h _ (hp s hs)
  demandAll h _ _ _ := h _

/-- Since guard `X ↦ S(X, event)`, under the conservative `H` demand. -/
def sinceGuard [SnceClause L] (event : L) : Step L M where
  wrap X := SnceClause.snce X event
  demand := pastDemand
  flips := false
  transfer A B p h := by
    change At M p (SnceClause.snce A event) → At M p (SnceClause.snce B event)
    simp only [At, SnceClause.snce_clause]
    rintro ⟨s, hst, hev, hg⟩
    exact ⟨s, hst, hev, fun r hsr hrt => h r hrt (hg r hsr hrt)⟩
  demandMono h _ hp s hs := h _ (hp s hs)
  demandAll h _ _ _ := h _

/-- Since event `X ↦ S(guard, X)`, under the `H` demand. -/
def sinceEvent [SnceClause L] (guard : L) : Step L M where
  wrap X := SnceClause.snce guard X
  demand := pastDemand
  flips := false
  transfer A B p h := by
    change At M p (SnceClause.snce guard A) → At M p (SnceClause.snce guard B)
    simp only [At, SnceClause.snce_clause]
    rintro ⟨s, hst, hev, hg⟩
    exact ⟨s, hst, h s hst hev, hg⟩
  demandMono h _ hp s hs := h _ (hp s hs)
  demandAll h _ _ _ := h _

/-- `G` body, through the generic `allFuture_iff`. -/
def future [BotClause L] [ImpClause L] [UntlClause L] : Step L M where
  wrap := allFuture
  demand := futureDemand
  flips := false
  transfer A B p h := by
    change At M p (allFuture A) → At M p (allFuture B)
    simp only [At, allFuture_iff]
    exact fun hA s hs => h s hs (hA s hs)
  demandMono h _ hp s hs := h _ (hp s hs)
  demandAll h _ _ _ := h _

/-- `H` body, through the generic `allPast_iff`. -/
def past [BotClause L] [ImpClause L] [SnceClause L] : Step L M where
  wrap := allPast
  demand := pastDemand
  flips := false
  transfer A B p h := by
    change At M p (allPast A) → At M p (allPast B)
    simp only [At, allPast_iff]
    exact fun hA s hs => h s hs (hA s hs)
  demandMono h _ hp s hs := h _ (hp s hs)
  demandAll h _ _ _ := h _

/-- `X` body under the covering demand, through `next_iff`. -/
def nextCover [BotClause L] [UntlClause L] : Step L M where
  wrap := next
  demand := nextDemand
  flips := false
  transfer A B p h := by
    change At M p (next A) → At M p (next B)
    simp only [At, next_iff]
    rintro ⟨s, hcov, hA⟩
    exact ⟨s, hcov, h s hcov hA⟩
  demandMono h _ hp s hs := h _ (hp s hs)
  demandAll h _ _ _ := h _

/-- `Y` body under the covering demand, through `prev_iff`. -/
def prevCover [BotClause L] [SnceClause L] : Step L M where
  wrap := prev
  demand := prevDemand
  flips := false
  transfer A B p h := by
    change At M p (prev A) → At M p (prev B)
    simp only [At, prev_iff]
    rintro ⟨s, hcov, hA⟩
    exact ⟨s, hcov, h s hcov hA⟩
  demandMono h _ hp s hs := h _ (hp s hs)
  demandAll h _ _ _ := h _

/-! ### Derived views, as compositions of primitive positions

Each view's `wrap` is the derived operator by `rfl` (checked by the `example`s), so a derived view
selects exactly one primitive occurrence. -/

/-- `X` body under the conservative `G` demand: the Until event position at guard `⊥`. -/
abbrev nextFuture [BotClause L] [UntlClause L] : Step L M := untilEvent BotClause.bot

/-- `Y` body under the conservative `H` demand. -/
abbrev prevPast [BotClause L] [SnceClause L] : Step L M := sinceEvent BotClause.bot

/-- `F` event: the Until event at guard `⊤`. -/
abbrev someFutureEvent [BotClause L] [ImpClause L] [UntlClause L] : Step L M := untilEvent top

/-- `P` event: the Since event at guard `⊤`. -/
abbrev somePastEvent [BotClause L] [ImpClause L] [SnceClause L] : Step L M := sinceEvent top

/-- `¬` body: the antecedent of `X → ⊥`. -/
abbrev negBody [BotClause L] [ImpClause L] : Step L M := impLeft BotClause.bot

/-- Left conjunct of `and X C = ¬(X → ¬C)`. -/
abbrev andLeft [BotClause L] [ImpClause L] (C : L) : Step L M :=
  (impLeft BotClause.bot).comp (impLeft (neg C))

/-- Right conjunct of `and C X = ¬(C → ¬X)`. -/
abbrev andRight [BotClause L] [ImpClause L] (C : L) : Step L M :=
  (impLeft BotClause.bot).comp ((impRight C).comp (impLeft BotClause.bot))

/-- Left disjunct of `or X C = ¬X → C`. -/
abbrev orLeft [BotClause L] [ImpClause L] (C : L) : Step L M :=
  (impLeft C).comp (impLeft BotClause.bot)

/-- Right disjunct of `or C X = ¬C → X`. -/
abbrev orRight [BotClause L] [ImpClause L] (C : L) : Step L M := impRight (neg C)

/-- `◇` body: `¬□¬X`. -/
abbrev diamondBody [BotClause L] [ImpClause L] [BoxClause L] : Step L M :=
  (impLeft BotClause.bot).comp (box.comp (impLeft BotClause.bot))

/-- `⟐` body: `¬⊡¬X`. -/
abbrev dstabBody [BotClause L] [ImpClause L] [StabClause L] : Step L M :=
  (impLeft BotClause.bot).comp (stab.comp (impLeft BotClause.bot))

section Pins
variable [BotClause L] [ImpClause L] [BoxClause L] [StabClause L] [UntlClause L] [SnceClause L]

example (X : L) : (nextFuture (M := M)).wrap X = next X := rfl
example (X : L) : (prevPast (M := M)).wrap X = prev X := rfl
example (X : L) : (someFutureEvent (M := M)).wrap X = someFuture X := rfl
example (X : L) : (somePastEvent (M := M)).wrap X = somePast X := rfl
example (X : L) : (negBody (M := M)).wrap X = neg X := rfl
example (X C : L) : (andLeft (M := M) C).wrap X = and X C := rfl
example (X C : L) : (andRight (M := M) C).wrap X = and C X := rfl
example (X C : L) : (orLeft (M := M) C).wrap X = or X C := rfl
example (X C : L) : (orRight (M := M) C).wrap X = or C X := rfl
example (X : L) : (diamondBody (M := M)).wrap X = diamond X := rfl
example (X : L) : (dstabBody (M := M)).wrap X = dstab X := rfl
example (C : L) : (andLeft (M := M) C).flips = false := rfl
example (C : L) : (andRight (M := M) C).flips = false := rfl
example (C : L) : (orLeft (M := M) C).flips = false := rfl
example : (diamondBody (L := L) (M := M)).flips = false := rfl

end Pins

end Step

/-! ## Persistence, eventuality bind and keeping -/

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

/-! ## Well-founded rank progress -/

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

/-! ## One-way fact and goal transport

A certificate relates two fully indexed judgments: source and target language, frame, model,
point and formula all stay explicit. A fact certificate moves a fact forward only; a goal
certificate reduces a goal backward only. Neither is derived from the other. -/

section Transport
variable {L L' L'' : Type} [TruthEnv L] [TruthEnv L'] [TruthEnv L'']
  {F F' F'' : TaskFrame}

/-- `R p q → At M p A → At M' q B`. -/
def FactTransport (R : Point L F → Point L' F' → Prop) (M : TaskModel F) (M' : TaskModel F')
    (A : L) (B : L') : Prop :=
  ∀ p q, R p q → At M p A → At M' q B

/-- `R p q → At M' q B → At M p A`: proving the target at `q` proves the source goal at `p`. -/
def GoalTransport (R : Point L F → Point L' F' → Prop) (M : TaskModel F) (M' : TaskModel F')
    (A : L) (B : L') : Prop :=
  ∀ p q, R p q → At M' q B → At M p A

variable {R : Point L F → Point L' F' → Prop} {M : TaskModel F} {M' : TaskModel F'}
  {A : L} {B : L'}

/-- Move a fact along a fact certificate. -/
theorem FactTransport.apply (h : FactTransport R M M' A B) {p : Point L F} {q : Point L' F'}
    (hR : R p q) (hA : At M p A) : At M' q B :=
  h p q hR hA

/-- Reduce a goal along a goal certificate. -/
theorem GoalTransport.reduce (h : GoalTransport R M M' A B) {p : Point L F} {q : Point L' F'}
    (hR : R p q) (hB : At M' q B) : At M p A :=
  h p q hR hB

/-- A pointwise `Iff` certificate supplies both directions. -/
theorem FactTransport.ofIff (h : ∀ p q, R p q → (At M p A ↔ At M' q B)) :
    FactTransport R M M' A B :=
  fun p q hR => (h p q hR).mp

/-- A pointwise `Iff` certificate supplies both directions. -/
theorem GoalTransport.ofIff (h : ∀ p q, R p q → (At M p A ↔ At M' q B)) :
    GoalTransport R M M' A B :=
  fun p q hR => (h p q hR).mpr

/-- Chain fact certificates through an intermediate judgment. -/
theorem FactTransport.trans {R' : Point L' F' → Point L'' F'' → Prop} {M'' : TaskModel F''}
    {C : L''} (h₁ : FactTransport R M M' A B) (h₂ : FactTransport R' M' M'' B C) :
    FactTransport (fun p r => ∃ q, R p q ∧ R' q r) M M'' A C :=
  fun p r ⟨q, hpq, hqr⟩ hA => h₂ q r hqr (h₁ p q hpq hA)

/-- Chain goal certificates through an intermediate judgment. -/
theorem GoalTransport.trans {R' : Point L' F' → Point L'' F'' → Prop} {M'' : TaskModel F''}
    {C : L''} (h₁ : GoalTransport R M M' A B) (h₂ : GoalTransport R' M' M'' B C) :
    GoalTransport (fun p r => ∃ q, R p q ∧ R' q r) M M'' A C :=
  fun p r ⟨q, hpq, hqr⟩ hC => h₁ p q hpq (h₂ q r hqr hC)

end Transport

section TransportFixture
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] {F : TaskFrame}

/-- The plan's one-way fixture: disjunction introduction at the same point, from the clauses. -/
theorem orIntroLeft_fact (M : TaskModel F) (A B : L) :
    FactTransport (fun p q : Point L F => p = q) M M A (or A B) := by
  rintro p q rfl hA
  exact (or_iff M p.history p.time p.env A B).mpr (Or.inl hA)

/-- Its goal direction fails at `A = ⊥`, `B = ⊤` as soon as the model has any point. -/
theorem not_orIntroLeft_goal (M : TaskModel F) (p : Point L F) :
    ¬ GoalTransport (fun p q : Point L F => p = q) M M (BotClause.bot : L)
      (or BotClause.bot top) := fun h =>
  BotClause.bot_clause M p.history p.time p.env
    (h p p rfl ((or_iff M p.history p.time p.env _ _).mpr (Or.inr (top_true M _ _ _))))

end TransportFixture

end FormalSystem.Semantics.ProofModeRules

namespace FormalSystem.Semantics.ProofModeRules

open TruthClauses

/-- Pointwise Boolean simplification, valid in every model with the two indicated clauses. -/
theorem doubleNegation_iff {L : Type} [TruthEnv L] [BotClause L] [ImpClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (A : L) :
    TruthEnv.T M τ t e (neg (neg A)) ↔ TruthEnv.T M τ t e A := by
  simp only [neg_iff, not_not]

/-- Idempotent conjunction, as an indexed semantic equivalence for bounded simplification. -/
theorem conjunctionSelf_iff {L : Type} [TruthEnv L] [BotClause L] [ImpClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (A : L) :
    TruthEnv.T M τ t e (and A A) ↔ TruthEnv.T M τ t e A := by
  simp only [and_iff, and_self]

/-- Strict transitivity contracts two future eventualities; the reverse needs more hypotheses. -/
theorem futureCollapse_at {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (A : L)
    (h : TruthEnv.T M τ t e (someFuture (someFuture A))) : TruthEnv.T M τ t e (someFuture A) := by
  obtain ⟨u, htu, hu⟩ := (someFuture_iff M τ t e _).mp h
  obtain ⟨v, huv, hv⟩ := (someFuture_iff M τ u e _).mp hu
  exact (someFuture_iff M τ t e _).mpr ⟨v, lt_trans htu huv, hv⟩

end FormalSystem.Semantics.ProofModeRules
