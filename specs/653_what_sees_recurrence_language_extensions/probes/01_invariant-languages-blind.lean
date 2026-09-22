/-
Probe 01 — what stays blind to recurrence: every language whose truth is invariant along the
translation projection, and the stability-class bijection the projection respects.

Research probe only (sorry-free, compiled with `lake env lean`); nothing here is proposed for
`FormalSystem/`. Names live in `Probe653`.

Contents:
* `classValid_iff_recurrenceFree_of_prodInvariant` — the abstract meta-theorem: for ANY
  semantics `S` (a truth predicate at model, history, time, for every task frame) that is
  invariant along the translation projection for lifted models, class validity equals validity
  over the recurrence-free members of the class. The three landed `*ValidIn_iff_recurrenceFree`
  theorems are its instances, and so is every language below.
* Q1 — `stabClass_lift_unique`: the projection restricts to a bijection between the stability
  class `⟨τ'⟩_t` of a product history and the stability class `⟨projH τ'⟩_t` of its projection;
  this is exactly the clause of the `⊡` semantics the product respects.
* Q1 — `open_invariance`, `openValidIn_iff_recurrenceFree`: the manuscript's open-future and
  open-past modals (`FormalSystem/OpenLanguage/`) are blind to recurrence as well.
* Q1 — `regFree_prod_invariance`, `regFreeValidIn_iff_recurrenceFree`: the class-level
  corollary for L⁺ + `[≡]` that `HybridLanguage/HybridInvariance.lean` records as not
  formalized, now compiled through `FrameOver.translationProductProj`.
* Q1 — `starValidIn_iff_recurrenceFree'`: the landed L⋆ result re-derived from the meta-theorem.
* Q3 — `boxFree_histMap_invariance`: the since/until fragment (no `□`) is invariant along ANY
  history-lifting *map* — `onto` is never used, because `U`/`S` consult one history only.
-/

import FormalSystem.Semantics.Frames.TranslationProduct
import FormalSystem.OpenLanguage.OpenValidity
import FormalSystem.HybridLanguage.HybridInvariance
import FormalSystem.HybridLanguage.HybridValidity

namespace Probe653

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.OpenLanguage
open FormalSystem.HybridLanguage

/-! ## The meta-theorem: invariance along the projection is all that is needed -/

/-- **Any semantics invariant along the translation projection is blind to recurrence at the
level of a frame class.** `S G M τ t` is an arbitrary truth predicate over every task frame; the
only hypothesis is invariance for lifted models along `projH`. The conclusion is the shape of
`validIn_iff_recurrenceFree`, `plusValidIn_iff_recurrenceFree` and
`starValidIn_iff_recurrenceFree`. -/
theorem classValid_iff_recurrenceFree_of_prodInvariant
    (S : (G : TaskFrame) → TaskModel G → WorldHistory G → G.Duration → Prop)
    (hinv : ∀ {D : TemporalOrder} (F : FrameOver D) (M : TaskModel F.toTaskFrame)
      (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D),
      S F.translationProduct.toTaskFrame (liftModel F M) τ' t ↔ S F.toTaskFrame M (projH F τ') t)
    (fc : FrameClass) :
    (∀ G : TaskFrame, fc.Sat G → ∀ M τ t, S G M τ t) ↔
      (∀ G : TaskFrame, fc.Sat G ∧ G.RecurrenceFree → ∀ M τ t, S G M τ t) := by
  constructor
  · intro h G hG; exact h G hG.1
  · intro h G hG M τ t
    have hp := h G.toFibre.translationProduct.toTaskFrame
      ⟨(FrameOver.translationProduct_sat G.toFibre fc).2 hG,
        translationProduct_recurrenceFree G.toFibre⟩
      (liftModel G.toFibre M) (liftH G.toFibre τ 0) t
    have := (hinv G.toFibre M _ t).1 hp
    rwa [projH_liftH] at this

/-- Sanity instance: the landed L⋆ theorem is the meta-theorem at `StarTruthAt`. -/
theorem starValidIn_iff_recurrenceFree' (fc : FrameClass) (φ : StarFormula) :
    StarValidIn fc φ ↔ StarValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ :=
  classValid_iff_recurrenceFree_of_prodInvariant
    (fun G M τ t => ∀ v : ℕ → G.Duration, StarTruthAt M τ t v φ)
    (fun F M τ' t => forall_congr' fun v => star_invariance F M φ τ' t v) fc

/-! ## Q1 — which clause of the stability semantics the product respects -/

section Stab
variable {D : TemporalOrder} (F : FrameOver D)

/-- **The projection is a bijection from `⟨τ'⟩_t` onto `⟨projH τ'⟩_t`.** Every history `σ` of
`F` through the projected state at `t` is the projection of exactly one history of the product
through `τ'`'s own state at `t`: the lift at the clock offset of `τ'`. This is the `lift` clause
of `HistMorphism` made unique, and it is precisely what the `⊡` case of `plus_invariance` and
`star_invariance` consumes. -/
theorem stabClass_lift_unique (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D)
    (σ : WorldHistory F.toTaskFrame) (hσ : σ.state t = (projH F τ').state t) :
    ∃! σ' : WorldHistory F.translationProduct.toTaskFrame,
      σ'.state t = τ'.state t ∧ projH F σ' = σ := by
  refine ⟨liftH F σ ((τ'.state t).2 - t), ⟨liftH_through F σ (τ'.state t) t hσ.symm,
    projH_liftH F σ _⟩, ?_⟩
  rintro ρ' ⟨hρt, hρp⟩
  -- `ρ'` is the lift of its projection at its own clock offset; that offset is `τ'`'s.
  have hclk : (ρ'.state 0).2 = (τ'.state t).2 - t := by
    have h1 := clock_eq F ρ' t
    rw [hρt] at h1
    rw [h1]; abel
  calc ρ' = liftH F (projH F ρ') (ρ'.state 0).2 := (liftH_projH F ρ').symm
    _ = liftH F σ ((τ'.state t).2 - t) := by rw [hρp, hclk]

/-- The projection maps `⟨τ'⟩_t` into `⟨projH τ'⟩_t` (the easy direction). -/
theorem projH_mem_stabClass (τ' σ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D)
    (h : σ'.state t = τ'.state t) : (projH F σ').state t = (projH F τ').state t :=
  congrArg Prod.fst h

end Stab

/-! ## Q1 — the open-future and open-past modals are blind -/

section Open
variable {D : TemporalOrder} (F : FrameOver D)

/-- A history of the product agrees with the lift of its projection at its own clock offset
everywhere; in particular up to or from any time. -/
theorem state_eq_lift (τ' : WorldHistory F.translationProduct.toTaskFrame) (s : ↑D) :
    τ'.state s = ((projH F τ').state s, (τ'.state 0).2 + s) :=
  Prod.ext rfl (clock_eq F τ' s)

/-- **L^▷: truth is preserved by the projection**, for lifted models. The two new clauses are
where the clock offset is read off the history rather than the state: a history of `F` agreeing
with `projH τ'` up to `t` lifts, at `τ'`'s offset, to a history agreeing with `τ'` up to `t`.
Note that this is NOT a consequence of `HistMorphism` alone — its `lift` clause fixes one time —
but the product supplies the stronger lift. -/
theorem open_invariance (M : TaskModel F.toTaskFrame) :
    ∀ (φ : OpenFormula) (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D),
      OpenTruthAt (liftModel F M) τ' t φ ↔ OpenTruthAt M (projH F τ') t φ := by
  intro φ
  induction φ with
  | atom p => intro τ' t; exact Iff.rfl
  | bot => intro τ' t; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t; exact imp_congr (ih1 τ' t) (ih2 τ' t)
  | box a ih =>
    intro τ' t
    constructor
    · intro h ρ
      have := (ih (liftH F ρ 0) t).1 (h _)
      rwa [projH_liftH] at this
    · intro h σ'; exact (ih σ' t).2 (h _)
  | untl a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | snce a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | stab a ih =>
    intro τ' t
    constructor
    · intro h ρ hρ
      have hl := liftH_through F ρ (τ'.state t) t hρ
      have := (ih _ t).1 (h _ hl.symm)
      rwa [projH_liftH] at this
    · intro h σ' he
      exact (ih σ' t).2 (h _ (congrArg Prod.fst he))
  | ofut a ih =>
    intro τ' t
    constructor
    · intro h ρ hρ
      have hag : AgreeUpTo τ' (liftH F ρ (τ'.state 0).2) t := by
        intro s hs
        rw [liftH_state, state_eq_lift F τ' s, hρ s hs]
      have := (ih _ t).1 (h _ hag)
      rwa [projH_liftH] at this
    · intro h σ' he
      exact (ih σ' t).2 (h _ fun s hs => congrArg Prod.fst (he s hs))
  | opast a ih =>
    intro τ' t
    constructor
    · intro h ρ hρ
      have hag : AgreeFrom τ' (liftH F ρ (τ'.state 0).2) t := by
        intro s hs
        rw [liftH_state, state_eq_lift F τ' s, hρ s hs]
      have := (ih _ t).1 (h _ hag)
      rwa [projH_liftH] at this
    · intro h σ' he
      exact (ih σ' t).2 (h _ fun s hs => congrArg Prod.fst (he s hs))

end Open

/-- **At every frame class, L^▷-validity over the class equals L^▷-validity over its
recurrence-free members.** The open-future and open-past modals cannot see recurrence or
transposition. -/
theorem openValidIn_iff_recurrenceFree (fc : FrameClass) (φ : OpenFormula) :
    OpenValidIn fc φ ↔ OpenValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ :=
  classValid_iff_recurrenceFree_of_prodInvariant
    (fun _G M τ t => OpenTruthAt M τ t φ)
    (fun F M τ' t => open_invariance F M φ τ' t) fc

/-! ## Q1 — the same-state modality `[≡]`: the class-level corollary -/

section RegFree
variable {D : TemporalOrder} (F : FrameOver D)

/-- `regFree_invariance` at the translation projection, with the register vectors folded in as
validity folds them: for a register-free formula, truth at every register vector on the product
equals truth at every register vector on the base. -/
theorem regFree_prod_invariance (M : TaskModel F.toTaskFrame) (φ : HybridFormula)
    (hφ : φ.RegFree) (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D) :
    (∀ r' : ℕ → F.translationProduct.WorldState, HybridTruthAt (liftModel F M) τ' t r' φ) ↔
      (∀ r : ℕ → F.WorldState, HybridTruthAt M (projH F τ') t r φ) := by
  have key : ∀ (r' : ℕ → F.translationProduct.WorldState) (r : ℕ → F.WorldState),
      HybridTruthAt (liftModel F M) τ' t r' φ ↔ HybridTruthAt M (projH F τ') t r φ :=
    fun r' r => regFree_invariance (FrameOver.translationProductProj F) M φ hφ τ' t r' r
  constructor
  · intro h r; exact (key (fun _ => τ'.state t) r).1 (h _)
  · intro h r'; exact (key r' (fun _ => (projH F τ').state t)).2 (h _)

end RegFree

/-- **At every frame class, validity of a register-free hybrid formula (L⁺ plus `[≡]`) over the
class equals validity over its recurrence-free members.** The corollary
`HybridLanguage/HybridInvariance.lean` lists as not formalized. -/
theorem regFreeValidIn_iff_recurrenceFree (fc : FrameClass) (φ : HybridFormula)
    (hφ : φ.RegFree) :
    HybridValidIn fc φ ↔ HybridValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ :=
  classValid_iff_recurrenceFree_of_prodInvariant
    (fun G M τ t => ∀ r : ℕ → G.WorldState, HybridTruthAt M τ t r φ)
    (fun F M τ' t => regFree_prod_invariance F M φ hφ τ' t) fc

/-! ## Q3 — since and until consult one history: invariance along any history-lifting map -/

/-- The `□`-free fragment of the base language: since, until and the Booleans. -/
def BoxFree : Formula → Prop
  | .atom _ => True
  | .bot => True
  | .imp a b => BoxFree a ∧ BoxFree b
  | .box _ => False
  | .untl a b => BoxFree a ∧ BoxFree b
  | .snce a b => BoxFree a ∧ BoxFree b

/-- **The since/until fragment is invariant along ANY history-lifting map** — `onto` is never
consulted, and neither is `lift`: the `U`/`S` clauses range over the times of the one history of
evaluation, whose image has the same times and the pulled-back valuation. A fortiori it cannot
separate a frame from its translation product. -/
theorem boxFree_histMap_invariance {D : TemporalOrder} {F' F : FrameOver D}
    (g : HistMap F' F) (M : TaskModel F.toTaskFrame) :
    ∀ (φ : Formula), BoxFree φ → ∀ (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
      TruthAt (g.pullM M) τ' t φ ↔ TruthAt M (g.mapH τ') t φ := by
  intro φ
  induction φ with
  | atom p => intro _ τ' t; exact Iff.rfl
  | bot => intro _ τ' t; exact Iff.rfl
  | imp a b ih1 ih2 =>
    intro h τ' t
    exact imp_congr (ih1 h.1 τ' t) (ih2 h.2 τ' t)
  | box a _ => intro h; exact False.elim h
  | untl a b ih1 ih2 =>
    intro h τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 h.2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 h.1 τ' r)
  | snce a b ih1 ih2 =>
    intro h τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 h.2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 h.1 τ' r)

/-- The since/until fragment at the translation projection, in the shape of `truth_invariance`. -/
theorem boxFree_prod_invariance {D : TemporalOrder} (F : FrameOver D) (M : TaskModel F.toTaskFrame)
    (φ : Formula) (hφ : BoxFree φ) (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D) :
    TruthAt (liftModel F M) τ' t φ ↔ TruthAt M (projH F τ') t φ :=
  boxFree_histMap_invariance (FrameOver.translationProductProj F).toHistMap M φ hφ τ' t

end Probe653
