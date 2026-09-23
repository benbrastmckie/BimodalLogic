/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenValidity

/-!
# Time reversal of frames, histories and L^▷ truth

The manuscript's time-reflection lemma (`lem:time-reflection`) passes from a task frame to its
**converse frame**, whose task relation is `w ⇒⁻_x u := w ⇒_{-x} u`, and from a possible world
`τ` to the world `x ↦ τ(-x)` over the converse frame. This module builds both *semantically*, for
an arbitrary task frame, and proves the one transport theorem that turns every validity about the
open-future operator into a validity about the open-past operator:

```
M, τ, t ⊨ φ     iff     M⁻, τ⁻, -t ⊨ φ.reflectTime
```

The reversal exchanges the two agreement classes — `σ ∈ |τ⟩_t` iff `σ⁻ ∈ ⟨τ⁻|_{-t}` — and fixes
`⟨τ⟩_t`, which is why `reflectTime` exchanges `▷` with `◁` and fixes `⊡`
(`OpenLanguage/Formula.lean`).

The repository's existing reflection machinery (`TruthAntiIso`, `Semantics/TruthTransport.lean`)
cannot serve here: it transports the six L clauses along an atom-level agreement, and a clause
that quantifies over a *class* of histories needs the class itself to be transported.

**Siting.** `FrameOver.rev` is language-independent. It lives in this component because this is
its only consumer; the frame-level half may be promoted to `Semantics/` later.

## Main Definitions

- `FrameOver.rev`, `TaskFrame.rev`, `TaskModel.rev`, `WorldHistory.rev`

## Main Results

- `FrameOver.rev_taskRel`, `FrameOver.rev_taskRel_neg` (the manuscript's `w ⇒⁻_x u := w ⇒_{-x} u`),
  and `FrameOver.rev_rev`, `TaskFrame.rev_rev`, `TaskModel.rev_rev` — all three by `rfl`
- `WorldHistory.rev_rev_hist` — reversal of histories is an involution (propositional, not `rfl`),
  whence `WorldHistory.rev_surjective`: the manuscript's bijection `H_F → H_{F⁻}`
- `sameState_rev_iff`, `agreeUpTo_rev_iff`, `agreeFrom_rev_iff` — the class swaps
- `openTruthAt_rev` — the transport theorem
- `openValidOn_rev_iff` and `openValid_reflectTime` — validity is closed under time reflection

## References

* JPL paper `lem:time-reflection` — the converse frame and the reflected world
* JPL paper `def:frame` — *Compositionality*, *Seriality*, *Limit* and *Saturation*, each of
  which the converse frame inherits
* `FormalSystem/Semantics/TaskFrame.lean` — `FrameOver`, `TaskFrame.reflect`,
  `FrameOver.reflection`

## Tags

open-language · time-reflection · converse-frame
-/

namespace FormalSystem.OpenLanguage

/-! The reversal operations are declared in `FormalSystem.Semantics`, for dot notation on
`FrameOver`, `TaskFrame`, `TaskModel` and `WorldHistory`; the L^▷ transport theorems follow in
this namespace. -/

end FormalSystem.OpenLanguage

namespace FormalSystem.Semantics

open FormalSystem.Semantics.TaskFrame

/-! ## The converse frame -/

variable {D : TemporalOrder}

/-- **The converse frame.** The primitive relation is reversed: `PosRel' w x u := PosRel u x w`.
All four axioms of `def:frame` are inherited: *Compositionality* by commuting the two factors,
*Seriality* by exchanging its conjuncts, *Limit* by symmetry of equality, and *Saturation* by
mapping each fibre and segment to its mirror through the reflection convention. -/
def FrameOver.rev (F : FrameOver D) : FrameOver D where
  WorldState := F.WorldState
  worldNonempty := F.worldNonempty
  PosRel := fun w x u => F.PosRel u x w
  comp := by
    intro w v x y hx hy
    have h := F.comp v w y x hy hx
    rw [add_comm] at h
    change reflect F.PosRel v (x + y) w ↔ ∃ u, reflect F.PosRel u x w ∧ reflect F.PosRel v y u
    rw [h]
    constructor
    · rintro ⟨u, h1, h2⟩; exact ⟨u, h2, h1⟩
    · rintro ⟨u, h1, h2⟩; exact ⟨u, h2, h1⟩
  serial := by
    intro w x hx
    obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := F.serial w x hx
    exact ⟨⟨v, hv⟩, ⟨u, hu⟩⟩
  limit := by
    intro w u h
    exact (F.limit u w h).symm
  saturation := by
    intro S hdir hmem
    refine F.saturation S hdir ?_
    intro s hs
    obtain ⟨hcls, hne⟩ := hmem s hs
    refine ⟨?_, hne⟩
    rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · left
      refine ⟨w, -x, ?_⟩
      ext u
      change F.TaskRel u x w ↔ F.TaskRel w (-x) u
      exact F.reflection u x w
    · right
      refine ⟨v, w, y, x, hy, hx, ?_⟩
      ext u
      change F.TaskRel u x w ∧ F.TaskRel u (-y) v ↔ F.TaskRel v y u ∧ F.TaskRel w (-x) u
      rw [F.reflection u x w, F.reflection u (-y) v, neg_neg, and_comm]

/-- **The converse of a regular frame is regular.** All four `def:frame` constraints are
inherited: *Compositionality* by commuting the two factors, *Seriality* by exchanging its
conjuncts, *Limit* by symmetry of equality, and *Saturation* by mapping each fibre and segment to
its mirror through the reflection convention. Stated as a class instance on the general frame, so
that `F.rev.comp` and its siblings are found by synthesis exactly where `F.comp` is. -/
instance FrameOver.rev_isRegular (F : FrameOver D) [F.IsRegular] : F.rev.IsRegular where
  comp := by
    intro w v x y hx hy
    have h := F.comp v w y x hy hx
    rw [add_comm] at h
    change reflect F.PosRel v (x + y) w ↔ ∃ u, reflect F.PosRel u x w ∧ reflect F.PosRel v y u
    rw [h]
    constructor
    · rintro ⟨u, h1, h2⟩; exact ⟨u, h2, h1⟩
    · rintro ⟨u, h1, h2⟩; exact ⟨u, h2, h1⟩
  serial := by
    intro w x hx
    obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := F.serial w x hx
    exact ⟨⟨v, hv⟩, ⟨u, hu⟩⟩
  limit := by
    intro w u h
    exact (F.limit u w h).symm
  saturation := by
    intro S hdir hmem
    refine F.saturation S hdir ?_
    intro s hs
    obtain ⟨hcls, hne⟩ := hmem s hs
    refine ⟨?_, hne⟩
    rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · left
      refine ⟨w, -x, ?_⟩
      ext u
      change F.TaskRel u x w ↔ F.TaskRel w (-x) u
      exact F.reflection u x w
    · right
      refine ⟨v, w, y, x, hy, hx, ?_⟩
      ext u
      change F.TaskRel u x w ∧ F.TaskRel u (-y) v ↔ F.TaskRel v y u ∧ F.TaskRel w (-x) u
      rw [F.reflection u x w, F.reflection u (-y) v, neg_neg, and_comm]


/-- The converse frame's task relation is the converse of the original's. -/
theorem FrameOver.rev_taskRel (F : FrameOver D) (w : F.WorldState) (d : ↑D) (u : F.WorldState) :
    F.rev.TaskRel w d u ↔ F.TaskRel u d w := Iff.rfl

/-- The manuscript's form of the converse relation: `w ⇒⁻_x u := w ⇒_{-x} u`. -/
theorem FrameOver.rev_taskRel_neg (F : FrameOver D) (w : F.WorldState) (d : ↑D)
    (u : F.WorldState) : F.rev.TaskRel w d u ↔ F.TaskRel w (-d) u :=
  F.reflection u d w

/-- Reversal of frames is an involution, definitionally. -/
theorem FrameOver.rev_rev (F : FrameOver D) : F.rev.rev = F := rfl

/-- The converse of a bundled task frame: the same temporal order, the converse fibre. -/
@[reducible] def TaskFrame.rev (F : TaskFrame) : TaskFrame := ⟨F.Duration, F.toFibre.rev⟩

/-- Reversal of bundled task frames is an involution, definitionally. -/
theorem TaskFrame.rev_rev (F : TaskFrame) : F.rev.rev = F := rfl

/-- A model over the converse frame: the same world states, so the same valuation. -/
def TaskModel.rev {F : TaskFrame} (M : TaskModel F) : TaskModel F.rev := ⟨M.valuation⟩

/-- Reversal of models is an involution, definitionally. -/
theorem TaskModel.rev_rev {F : TaskFrame} (M : TaskModel F) : M.rev.rev = M := rfl

/-- **The reflected world**: `τ⁻(t) = τ(-t)`, a possible world over the converse frame. -/
def WorldHistory.rev {F : TaskFrame} (τ : WorldHistory F) : WorldHistory F.rev :=
  WorldHistory.ofTotal F.rev (fun t => τ.state (-t)) (fun s t => by
    change F.TaskRel (τ.state (-t)) (t - s) (τ.state (-s))
    have := τ.respects_task (-t) (-s)
    rwa [show (-s : F.Duration) - -t = t - s by abel] at this)

@[simp] theorem WorldHistory.rev_state {F : TaskFrame} (τ : WorldHistory F) (t : F.Duration) :
    τ.rev.state t = τ.state (-t) := rfl

/-- Reversal of world histories is an involution. Propositional, not `rfl`: the two histories
have the states `τ(- -t)` and `τ(t)`. -/
theorem WorldHistory.rev_rev_hist {F : TaskFrame} (τ : WorldHistory F) :
    (τ.rev.rev : WorldHistory F) = τ := by
  apply WorldHistory.ext_state
  intro t
  change τ.state (- -t) = τ.state t
  rw [neg_neg]

/-- Every world over the converse frame is the reflection of a world over the original: with
`rev_rev_hist`, the manuscript's bijection `H_F → H_{F⁻}`. -/
theorem WorldHistory.rev_surjective {F : TaskFrame} (σ : WorldHistory F.rev) :
    ∃ τ : WorldHistory F, τ.rev = σ :=
  ⟨(σ.rev : WorldHistory F), WorldHistory.rev_rev_hist (F := F.rev) σ⟩

end FormalSystem.Semantics

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage.OpenFormula
open FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## The class swaps -/

/-- Reversal fixes `⟨τ⟩_t`: the class is defined by a same-time condition. -/
theorem sameState_rev_iff (τ σ : WorldHistory F) (t : F.Duration) :
    τ.state t = σ.state t ↔ τ.rev.state (-t) = σ.rev.state (-t) := by
  change _ ↔ τ.state (- -t) = σ.state (- -t)
  rw [neg_neg]

/-- Reversal sends `|τ⟩_t` to `⟨τ⁻|_{-t}`. -/
theorem agreeUpTo_rev_iff (τ σ : WorldHistory F) (t : F.Duration) :
    AgreeUpTo τ σ t ↔ AgreeFrom τ.rev σ.rev (-t) := by
  constructor
  · intro h s hs
    change τ.state (-s) = σ.state (-s)
    exact h (-s) (neg_le.mp hs)
  · intro h s hs
    have := h (-s) (neg_le_neg hs)
    change τ.state (- -s) = σ.state (- -s) at this
    rwa [neg_neg] at this

/-- Reversal sends `⟨τ|_t` to `|τ⁻⟩_{-t}`. -/
theorem agreeFrom_rev_iff (τ σ : WorldHistory F) (t : F.Duration) :
    AgreeFrom τ σ t ↔ AgreeUpTo τ.rev σ.rev (-t) := by
  constructor
  · intro h s hs
    change τ.state (-s) = σ.state (-s)
    exact h (-s) (le_neg.mp hs)
  · intro h s hs
    have := h (-s) (neg_le_neg hs)
    change τ.state (- -s) = σ.state (- -s) at this
    rwa [neg_neg] at this

/-! ## The transport theorem -/

/--
**L^▷ truth commutes with time reversal.** A formula is true at `(M, τ, t)` exactly when its time
reflection is true at the reflected point `(M⁻, τ⁻, -t)` of the converse frame.

By induction on `φ`, generalizing the history and the time. `box` uses the surjectivity of
reversal on histories; `untl` and `snce` negate the bounds; `stab` is `sameState_rev_iff`; `ofut`
and `opast` are the two agreement swaps.
-/
theorem openTruthAt_rev (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula) :
    OpenTruthAt M τ t φ ↔ OpenTruthAt M.rev τ.rev (-t) φ.reflectTime := by
  induction φ generalizing τ t with
  | atom p =>
    change M.valuation (τ.state t) p ↔ M.valuation (τ.state (- -t)) p
    rw [neg_neg]
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih =>
    constructor
    · intro h σ'
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ)
    · intro h σ
      exact (ih σ t).mpr (h σ.rev)
  | untl ψ φ ihψ ihφ =>
    constructor
    · rintro ⟨s, hts, hφ, hψ⟩
      refine ⟨-s, neg_lt_neg hts, (ihφ τ s).mp hφ, ?_⟩
      intro r' h1 h2
      obtain ⟨r, rfl⟩ : ∃ r : F.Duration, r' = -r := ⟨-r', (neg_neg r').symm⟩
      exact (ihψ τ r).mp (hψ r (neg_lt_neg_iff.mp h2) (neg_lt_neg_iff.mp h1))
    · rintro ⟨s', hs't, hφ, hψ⟩
      obtain ⟨s, rfl⟩ : ∃ s : F.Duration, s' = -s := ⟨-s', (neg_neg s').symm⟩
      refine ⟨s, neg_lt_neg_iff.mp hs't, (ihφ τ s).mpr hφ, ?_⟩
      intro r h1 h2
      exact (ihψ τ r).mpr (hψ (-r) (neg_lt_neg h2) (neg_lt_neg h1))
  | snce ψ φ ihψ ihφ =>
    constructor
    · rintro ⟨s, hst, hφ, hψ⟩
      refine ⟨-s, neg_lt_neg hst, (ihφ τ s).mp hφ, ?_⟩
      intro r' h1 h2
      obtain ⟨r, rfl⟩ : ∃ r : F.Duration, r' = -r := ⟨-r', (neg_neg r').symm⟩
      exact (ihψ τ r).mp (hψ r (neg_lt_neg_iff.mp h2) (neg_lt_neg_iff.mp h1))
    · rintro ⟨s', hts', hφ, hψ⟩
      obtain ⟨s, rfl⟩ : ∃ s : F.Duration, s' = -s := ⟨-s', (neg_neg s').symm⟩
      refine ⟨s, neg_lt_neg_iff.mp hts', (ihφ τ s).mpr hφ, ?_⟩
      intro r h1 h2
      exact (ihψ τ r).mpr (hψ (-r) (neg_lt_neg h2) (neg_lt_neg h1))
  | stab φ ih =>
    constructor
    · intro h σ' hs
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ ((sameState_rev_iff τ σ t).mpr hs))
    · intro h σ hs
      exact (ih σ t).mpr (h σ.rev ((sameState_rev_iff τ σ t).mp hs))
  | ofut φ ih =>
    constructor
    · intro h σ' hs
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ ((agreeUpTo_rev_iff τ σ t).mpr hs))
    · intro h σ hs
      exact (ih σ t).mpr (h σ.rev ((agreeUpTo_rev_iff τ σ t).mp hs))
  | opast φ ih =>
    constructor
    · intro h σ' hs
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ ((agreeFrom_rev_iff τ σ t).mpr hs))
    · intro h σ hs
      exact (ih σ t).mpr (h σ.rev ((agreeFrom_rev_iff τ σ t).mp hs))

/-! ## Validity is closed under time reflection -/

/-- A formula is valid over a frame exactly when its time reflection is valid over the converse
frame. -/
theorem openValidOn_rev_iff (F : TaskFrame) (φ : OpenFormula) :
    F.rev.OpenValidOn φ.reflectTime ↔ F.OpenValidOn φ := by
  constructor
  · intro h M τ t
    exact (openTruthAt_rev M τ t φ).mpr (h M.rev τ.rev (-t))
  · intro h M' τ' t'
    obtain ⟨τ, rfl⟩ := WorldHistory.rev_surjective τ'
    have key := (openTruthAt_rev (M'.rev : TaskModel F) τ (-t') φ).mp (h _ τ (-t'))
    rw [neg_neg] at key
    exact key

/-- **Validity is closed under time reflection.** Every task frame is the converse of its own
converse (`TaskFrame.rev_rev`), so a validity about `▷` yields the mirrored validity about `◁`.
Stated at the unconstrained class only.

Paper: — (formalization-native; `lem:time-reflection` is stated for the base language, and this
is its extension to `⊡`, `▷` and `◁` at the level of validity) -/
theorem openValid_reflectTime (φ : OpenFormula) : OpenValid φ → OpenValid φ.reflectTime := by
  intro h
  refine OpenValid.of_forall fun F M τ t => ?_
  have hrev : F.rev.OpenValidOn φ := fun M' τ' t' => h.apply F.rev M' τ' t'
  exact (openValidOn_rev_iff F.rev φ).mpr hrev M τ t

end FormalSystem.OpenLanguage
