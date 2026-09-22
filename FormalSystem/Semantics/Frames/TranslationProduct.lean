/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Tactic.Abel
import FormalSystem.StarLanguage.StarValidity
import FormalSystem.Semantics.HistoryMorphism

/-!
# The translation product of a task frame

**Standing caveat.** The translation product is a *proof device*, never an intended model. It
exists to show what the three object languages `L`, `L⁺` and `L⋆` cannot see of a task frame —
recurrence (one history visiting a world state twice) and transposition (two histories passing
through the same world states in opposite orders). A state of the product carries a clock
reading, and a state carrying a clock reading is not a world state in the manuscript's sense:
world states are what recur, and the whole point of the product is that its states cannot. No
result here should be read as endorsing clocked states as a semantics.

## The construction: time-unfolding

The product `F.translationProduct` of a frame `F` over the temporal order `D` has world states
`F.WorldState × D` and task relation

  `(w, e) ⇒ₓ (u, e')  iff  w ⇒ₓ u  and  e' = e + x`.

A task of duration `x` advances the clock by `x`. This is the manuscript's own description of
the branching structure of a frame — `sub:Conclusion`: "the branching tree of states is not
posited but may be recovered by unfolding the transitions that the task relation permits" —
carried out with an absolute clock rather than a tree, so that the unfolding of a *history*
is a history of the product (`liftH`) and every history of the product projects back
(`projH`). Histories of the product are exactly history-plus-offset pairs (`liftH_projH`,
`projH_liftH`), with no appeal to the Extension Theorem. Every frame condition transfers from
the base relation alone: reflection, Compositionality, Seriality and Saturation each from the
matching condition on `R`, and *Limit* from the single clause `R w 0 u → u = w` — the clock
supplies the rest (`prodRel_limit`, through `TaskFrame.limit_of_shift`).

## Main Definitions

- `prodRel R` — the product relation on `W × D` over a bare relation `R`
- `colourClock` — a task frame over any temporal order from a finite reflective, serial,
  compositional relation whose zero-fibres are trivial; Saturation is `cor:saturation-finite`
- `FrameOver.translationProduct` — the translation product of a live frame (`def:frame`)
- `liftH`, `projH` — lifting and projecting world histories (`def:world-history`)
- `liftModel` — the lift of a model; the valuation ignores the clock (`def:BL-semantics`)

## Main Results

- `prodRel_reflection`, `prodRel_comp`, `prodRel_serial`, `prodRel_limit`,
  `prodRel_saturation` — each frame condition of the product from the matching condition on
  the base relation; `saturation_of_prodRel` — and Saturation back again
- `FrameOver.translationProduct_sat` — the product lies in every frame class its base does
- `FrameOver.translationProduct_deterministic_iff` — the product is neutral on determinism
  (`def:deterministic`)
- `projH_liftH`, `liftH_projH`, `clock_eq` — histories of the product are history-plus-offset
  pairs
- `no_recurrence`, `no_transposition`, `translationProduct_recurrenceFree` — no history of the
  product visits a state twice and no two histories transpose two states
- `truth_invariance`, `plus_invariance`, `star_invariance` — truth in `L`, `L⁺` and `L⋆` is
  preserved by the projection, for lifted models
- `validOn_of_prod`, `plusValidOn_of_prod`, `starValidOn_of_prod` — frame validity on the
  product implies frame validity on the base
- `validIn_iff_recurrenceFree`, `plusValidIn_iff_recurrenceFree`,
  `starValidIn_iff_recurrenceFree` — at every frame class, validity over the class equals
  validity over its recurrence-free members, in all three languages
- `frame_validity_not_reflected` — the converse of `validOn_of_prod` fails
- `FrameOver.translationProductProj` — the projection is a history-lifting morphism

## Frame-level validity is not reflected

Frame validity passes from the product to the base but not back. On the one-state frame every
history is constant, so `p → Gp` is valid there; on its product — whose states are clock
readings — the valuation `V (u, e) p := e ≤ 0` refutes it at time `0`
(`frame_validity_not_reflected`). The product validates strictly fewer formulas than its base:
the projection transports truth for *lifted* valuations only, and the extra valuations on
`W × D` are exactly the manuscript's abundant two-dimensional models — `sub:AbsoluteTime`'s
*Abundance*: "a two-dimensional model … is abundant iff for every `w ∈ W` and `x, y ∈ T`, there
is some `w' ∈ W` that is time-shifted from `x` to `y`". This is why the class-level theorems
are stated over frame *classes* (every member is covered by its product, which is in the same
class) and never frame by frame.

## What the device does not settle

The product is neutral on Saturation (`prodRel_saturation` and `saturation_of_prodRel`) and on
determinism (`translationProduct_deterministic_iff`): it neither buys nor loses either. It is
silent on the stability modal beyond state-locality — the `⊡` clause of `plus_invariance` and
`star_invariance` lifts a history through the given product state, which is all that
state-locality asks — and says nothing about what a stronger stability reading could see.

## Limit

Limit's contribution to validity is nil beyond the zero loops of `lem:nullity`: the product
satisfies Limit for free, from the zero-fibre clause alone, so any frame with trivial
zero-fibres is covered by a Limit frame in its own class. A Mathlib-only mirror over the plain
history type records the corresponding facts about idle Limit hypotheses outside the library,
at `specs/evidence/translation-product/limit-idle-mirror.lean`, because no non-Limit frame type
exists in the tree against which to state them.

## Paper correspondence

The manuscript defines no product of task frames; the construction is formalization-native.
World histories are `def:world-history`'s possible worlds; recurrence and transposition are the
phenomena the manuscript's construction section (`sec:Construction`) describes in the passages
"nothing prevents a world state from occurring at many times in a single history" and "nothing
prevents two histories … from passing through the same world states in a different order".

Axioms: every result here is at `[propext, Classical.choice, Quot.sound]` or below;
`Classical.choice` enters only through `TaskFrame.limit_of_shift`'s use of `exists_ne`, not
through any choice principle of the construction. `prodRel_saturation` is at
`[propext, Quot.sound]`.
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.StarLanguage

/-! ## The product relation over a bare relation -/

section Bare
variable {D : TemporalOrder} {W : Type} (R : W → ↑D → W → Prop)

/-- The translation-product relation on `W × D`: a task of duration `x` advances the clock by
`x`, stated over `↑D` for a `TemporalOrder`. -/
def prodRel : (W × ↑D) → ↑D → (W × ↑D) → Prop :=
  fun a x b => R a.1 x b.1 ∧ b.2 = a.2 + x

/-- **Reflection** of the product needs only reflection of `R`. -/
theorem prodRel_reflection (hR : ∀ w d u, R w d u ↔ R u (-d) w) :
    ∀ a d b, prodRel R a d b ↔ prodRel R b (-d) a := by
  intro a d b
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨(hR _ _ _).1 h1, by rw [h2]; abel⟩
  · rintro ⟨h1, h2⟩
    exact ⟨(hR _ _ _).2 h1, by rw [h2]; abel⟩

/-- **Compositionality** (biconditional) of the product needs only Compositionality of `R`. -/
theorem prodRel_comp (hC : TaskFrame.Compositional R) : TaskFrame.Compositional (prodRel R) := by
  intro a b x y hx hy
  constructor
  · rintro ⟨h1, h2⟩
    obtain ⟨u, hu1, hu2⟩ := (hC a.1 b.1 x y hx hy).1 h1
    exact ⟨(u, a.2 + x), ⟨hu1, rfl⟩, ⟨hu2, by change b.2 = a.2 + x + y; rw [h2]; abel⟩⟩
  · rintro ⟨u, ⟨h1, h2⟩, ⟨h3, h4⟩⟩
    exact ⟨(hC a.1 b.1 x y hx hy).2 ⟨u.1, h1, h3⟩, by show b.2 = a.2 + (x + y); rw [h4, h2]; abel⟩

/-- **Seriality** of the product needs only Seriality of `R`. -/
theorem prodRel_serial (hS : TaskFrame.Serial R) : TaskFrame.Serial (prodRel R) := by
  intro a x hx
  obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := hS a.1 x hx
  exact ⟨⟨(u, a.2 + x), hu, rfl⟩, ⟨(v, a.2 - x), hv, by rw [sub_add_cancel]⟩⟩

/-- **Limit is free**: it needs only trivial zero-fibres in `R` — no Limit hypothesis on `R`
and no hypothesis on cones. The clock coordinate is a shift, and `TaskFrame.limit_of_shift`
does the rest. -/
theorem prodRel_limit (h0 : ∀ w u, R w 0 u → u = w) :
    ∀ a b, (∀ x : ↑D, 0 < x → ∃ y, |y| < x ∧ prodRel R a y b) → b = a :=
  TaskFrame.limit_of_shift (D := ↑D) Prod.snd (fun _ _ _ h => h.2)
    (fun a b h => Prod.ext (h0 _ _ h.1) (by rw [h.2, add_zero]))

/-- Every fibre and every segment of the product has a constant clock coordinate. -/
theorem prodRel_const_clock (s : Set (W × ↑D))
    (h : TaskFrame.IsFiber (prodRel R) s ∨ TaskFrame.IsSegment (prodRel R) s) :
    ∃ c, ∀ b ∈ s, b.2 = c := by
  rcases h with ⟨a, x, rfl⟩ | ⟨a, a', x, y, _, _, rfl⟩
  · exact ⟨a.2 + x, fun b hb => hb.2⟩
  · exact ⟨a.2 + x, fun b hb => hb.1.2⟩

/-- The state-projection of a product fibre is the corresponding fibre of `R`. -/
theorem prodRel_fib_image (a : W × ↑D) (x : ↑D) :
    Prod.fst '' TaskFrame.Fib (prodRel R) a x = TaskFrame.Fib R a.1 x := by
  ext u
  constructor
  · rintro ⟨b, hb, rfl⟩; exact hb.1
  · intro hu; exact ⟨(u, a.2 + x), ⟨hu, rfl⟩, rfl⟩

/-- The state-projection of a nonempty product segment is the corresponding segment of `R`. -/
theorem prodRel_seg_image (a a' : W × ↑D) (x y : ↑D)
    (hne : (TaskFrame.Seg (prodRel R) a a' x y).Nonempty) :
    Prod.fst '' TaskFrame.Seg (prodRel R) a a' x y = TaskFrame.Seg R a.1 a'.1 x y := by
  obtain ⟨b₀, hb₀⟩ := hne
  have hclk : a.2 + x = a'.2 + -y := by rw [← hb₀.1.2, ← hb₀.2.2]
  ext u
  constructor
  · rintro ⟨b, hb, rfl⟩; exact ⟨hb.1.1, hb.2.1⟩
  · intro hu; exact ⟨(u, a.2 + x), ⟨⟨hu.1, rfl⟩, ⟨hu.2, hclk⟩⟩, rfl⟩

/-- **Saturation of the product from Saturation of `R`**: members of a `⊇`-directed family of
fibres and segments share one clock value (`prodRel_const_clock`), so the family projects to a
directed family of nonempty fibres and segments of `R`, whose common point re-clocks to a
common point of the product. -/
theorem prodRel_saturation (hsat : TaskFrame.Saturation R) :
    TaskFrame.Saturation (prodRel R) := by
  intro S hdir hmem
  obtain ⟨⟨s₀, hs₀⟩, hd⟩ := hdir
  obtain ⟨b₀, hb₀⟩ := (hmem s₀ hs₀).2
  -- every member has the clock value of `b₀`
  have hclk : ∀ s ∈ S, ∀ b ∈ s, b.2 = b₀.2 := by
    intro s hs b hb
    obtain ⟨s', hs', hsub⟩ := hd s₀ hs₀ s hs
    obtain ⟨b', hb'⟩ := (hmem s' hs').2
    have h1 := hsub hb'
    obtain ⟨c₀, hc₀⟩ := prodRel_const_clock R s₀ (hmem s₀ hs₀).1
    obtain ⟨c₁, hc₁⟩ := prodRel_const_clock R s (hmem s hs).1
    calc b.2 = c₁ := hc₁ b hb
      _ = b'.2 := (hc₁ b' h1.2).symm
      _ = c₀ := hc₀ b' h1.1
      _ = b₀.2 := (hc₀ b₀ hb₀).symm
  -- the projected family
  let S₀ : Set (Set W) := (fun s => Prod.fst '' s) '' S
  have hdir₀ : TaskFrame.DirectedFamily S₀ := by
    refine ⟨⟨_, s₀, hs₀, rfl⟩, ?_⟩
    rintro _ ⟨s₁, hs₁, rfl⟩ _ ⟨s₂, hs₂, rfl⟩
    obtain ⟨s', hs', hsub⟩ := hd s₁ hs₁ s₂ hs₂
    refine ⟨Prod.fst '' s', ⟨s', hs', rfl⟩, ?_⟩
    rintro _ ⟨b, hb, rfl⟩
    exact ⟨⟨b, (hsub hb).1, rfl⟩, ⟨b, (hsub hb).2, rfl⟩⟩
  have hmem₀ : ∀ s ∈ S₀, (TaskFrame.IsFiber R s ∨ TaskFrame.IsSegment R s) ∧ s.Nonempty := by
    rintro _ ⟨s, hs, rfl⟩
    obtain ⟨hcls, ⟨b, hb⟩⟩ := hmem s hs
    refine ⟨?_, ⟨b.1, b, hb, rfl⟩⟩
    rcases hcls with ⟨a, x, rfl⟩ | ⟨a, a', x, y, hx, hy, rfl⟩
    · exact Or.inl ⟨a.1, x, prodRel_fib_image R a x⟩
    · exact Or.inr ⟨a.1, a'.1, x, y, hx, hy, prodRel_seg_image R a a' x y ⟨b, hb⟩⟩
  obtain ⟨u, hu⟩ := hsat S₀ hdir₀ hmem₀
  refine ⟨(u, b₀.2), fun s hs => ?_⟩
  obtain ⟨b, hb, hb1⟩ : u ∈ Prod.fst '' s := Set.mem_sInter.1 hu _ ⟨s, hs, rfl⟩
  have : b = (u, b₀.2) := Prod.ext hb1 (hclk s hs b hb)
  exact this ▸ hb

/-- **Saturation of `R` from Saturation of the product**: the product is neutral on
Saturation. Each member of a directed family of `R` embeds at clock `0`. -/
theorem saturation_of_prodRel (hsat : TaskFrame.Saturation (prodRel R)) :
    TaskFrame.Saturation R := by
  intro S hdir hmem
  obtain ⟨⟨s₀, hs₀⟩, hd⟩ := hdir
  -- embed each member at clock `0`
  let e : Set W → Set (W × ↑D) := fun s => {b | b.1 ∈ s ∧ b.2 = 0}
  let S' : Set (Set (W × ↑D)) := e '' S
  have hdir' : TaskFrame.DirectedFamily S' := by
    refine ⟨⟨_, s₀, hs₀, rfl⟩, ?_⟩
    rintro _ ⟨s₁, hs₁, rfl⟩ _ ⟨s₂, hs₂, rfl⟩
    obtain ⟨s', hs', hsub⟩ := hd s₁ hs₁ s₂ hs₂
    exact ⟨e s', ⟨s', hs', rfl⟩, fun b hb => ⟨⟨(hsub hb.1).1, hb.2⟩, ⟨(hsub hb.1).2, hb.2⟩⟩⟩
  have hmem' : ∀ s ∈ S', (TaskFrame.IsFiber (prodRel R) s ∨ TaskFrame.IsSegment (prodRel R) s)
      ∧ s.Nonempty := by
    rintro _ ⟨s, hs, rfl⟩
    obtain ⟨hcls, ⟨u, hu⟩⟩ := hmem s hs
    refine ⟨?_, ⟨(u, 0), hu, rfl⟩⟩
    rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · refine Or.inl ⟨(w, -x), x, ?_⟩
      ext b
      change b.1 ∈ TaskFrame.Fib R w x ∧ b.2 = 0 ↔ R w x b.1 ∧ b.2 = -x + x
      rw [neg_add_cancel]; exact Iff.rfl
    · refine Or.inr ⟨(w, -x), (v, y), x, y, hx, hy, ?_⟩
      ext b
      change b.1 ∈ TaskFrame.Seg R w v x y ∧ b.2 = 0 ↔
        (R w x b.1 ∧ b.2 = -x + x) ∧ (R v (-y) b.1 ∧ b.2 = y + -y)
      rw [neg_add_cancel, add_neg_cancel]
      constructor
      · rintro ⟨⟨h1, h2⟩, h3⟩; exact ⟨⟨h1, h3⟩, ⟨h2, h3⟩⟩
      · rintro ⟨⟨h1, h3⟩, ⟨h2, _⟩⟩; exact ⟨⟨h1, h2⟩, h3⟩
  obtain ⟨b, hb⟩ := hsat S' hdir' hmem'
  exact ⟨b.1, fun s hs => (Set.mem_sInter.1 hb _ ⟨s, hs, rfl⟩).1⟩

/-- **Any finite reflective, serial, compositional relation with trivial zero-fibres clocks to
a task frame over any temporal order.** No Limit hypothesis: the clock supplies it. Saturation
of the base relation is `cor:saturation-finite`. The frame conditions are therefore not the
obstacle to realising a finite colouring as a task frame; only Limit was, and the clock
removes it. -/
def colourClock [Finite W] [Nonempty W]
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hC : TaskFrame.Compositional R)
    (hS : TaskFrame.Serial R) (h0 : ∀ w u, R w 0 u → u = w) : FrameOver D :=
  haveI : Nonempty ↑D := ⟨0⟩
  FrameOver.ofReflective (W × ↑D) (prodRel R) (prodRel_reflection R hR) (prodRel_comp R hC)
    (prodRel_serial R hS) (prodRel_limit R h0)
    (prodRel_saturation R (TaskFrame.saturation_of_finite R))

end Bare

/-! ## The product of a live frame -/

section Frame
variable {D : TemporalOrder} (F : FrameOver D)

/-- **The translation product of a live frame** (`def:frame`). Each field is discharged from
the corresponding field of `F`; the Limit field uses only `F.eq_of_taskRel_zero`.

A proof device, never an intended model: see the module docstring. -/
def FrameOver.translationProduct : FrameOver D :=
  haveI : Nonempty ↑D := ⟨0⟩
  FrameOver.ofReflective (F.WorldState × ↑D) (prodRel F.TaskRel) (prodRel_reflection _ F.reflection)
    (prodRel_comp _ F.comp) (prodRel_serial _ F.serial)
    (prodRel_limit _ fun _ _ h => (F.eq_of_taskRel_zero h).symm)
    (prodRel_saturation _ F.saturation)

/-- The task relation of the product, unfolded. -/
@[simp] theorem FrameOver.translationProduct_taskRel (a : F.WorldState × ↑D) (x : ↑D)
    (b : F.WorldState × ↑D) :
    F.translationProduct.TaskRel a x b ↔ F.TaskRel a.1 x b.1 ∧ b.2 = a.2 + x :=
  FrameOver.ofReflective_taskRel

/-- The product lies in exactly the same frame class as `F`, at every tag: the four tags
constrain the temporal order only, and the product keeps `D`. -/
theorem FrameOver.translationProduct_sat (fc : FormalSystem.ProofSystem.FrameClass) :
    fc.Sat F.translationProduct.toTaskFrame ↔ fc.Sat F.toTaskFrame := by
  cases fc <;> exact Iff.rfl

/-- The product preserves and reflects determinism (`def:deterministic`): it is neutral on
it. -/
theorem FrameOver.translationProduct_deterministic_iff :
    F.translationProduct.toTaskFrame.Deterministic ↔ F.toTaskFrame.Deterministic := by
  constructor
  · intro h w d u hu u' hu'
    have hu1 : (u, (0 : ↑D) + d) ∈ TaskFrame.Fib F.translationProduct.TaskRel (w, 0) d :=
      (FrameOver.translationProduct_taskRel F (w, 0) d (u, 0 + d)).2 ⟨TaskFrame.mem_Fib.1 hu, rfl⟩
    have hu2 : (u', (0 : ↑D) + d) ∈ TaskFrame.Fib F.translationProduct.TaskRel (w, 0) d :=
      (FrameOver.translationProduct_taskRel F (w, 0) d (u', 0 + d)).2
        ⟨TaskFrame.mem_Fib.1 hu', rfl⟩
    exact congrArg Prod.fst (h (w, 0) d hu1 hu2)
  · intro h a d b hb b' hb'
    have hb := (FrameOver.translationProduct_taskRel F _ _ _).1 hb
    have hb' := (FrameOver.translationProduct_taskRel F _ _ _).1 hb'
    exact Prod.ext (h a.1 d (TaskFrame.mem_Fib.2 hb.1) (TaskFrame.mem_Fib.2 hb'.1))
      (hb.2.trans hb'.2.symm)

/-! ### Histories of the product -/

/-- The lift of a history of `F` with clock offset `c`: at time `t` it occupies
`(ρ.state t, c + t)`. -/
def liftH (ρ : WorldHistory F.toTaskFrame) (c : ↑D) :
    WorldHistory F.translationProduct.toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => (ρ.state t, c + t)) (by
    intro s t
    exact (FrameOver.translationProduct_taskRel F _ _ _).2
      ⟨ρ.respects_task s t, by change c + t = c + s + (t - s); abel⟩)

/-- The projection of a history of the product: forget the clock. -/
def projH (τ' : WorldHistory F.translationProduct.toTaskFrame) : WorldHistory F.toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => (τ'.state t).1)
    (fun s t => ((FrameOver.translationProduct_taskRel F _ _ _).1 (τ'.respects_task s t)).1)

/-- The state of a lifted history. -/
@[simp] theorem liftH_state (ρ : WorldHistory F.toTaskFrame) (c t : ↑D) :
    (liftH F ρ c).state t = (ρ.state t, c + t) := rfl

/-- The state of a projected history. -/
@[simp] theorem projH_state (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D) :
    (projH F τ').state t = (τ'.state t).1 := rfl

/-- Projecting a lift recovers the history. -/
theorem projH_liftH (ρ : WorldHistory F.toTaskFrame) (c : ↑D) : projH F (liftH F ρ c) = ρ :=
  WorldHistory.ext_state fun _ => rfl

/-- The clock along any history of the product is time plus a constant. -/
theorem clock_eq (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D) :
    (τ'.state t).2 = (τ'.state 0).2 + t := by
  have := ((FrameOver.translationProduct_taskRel F _ _ _).1 (τ'.respects_task 0 t)).2
  rwa [sub_zero] at this

/-- **Histories of the product are exactly history-plus-offset pairs**: lifting the projection
at the clock reading at `0` recovers the history. Lifts are unique and no Extension Theorem is
needed. -/
theorem liftH_projH (τ' : WorldHistory F.translationProduct.toTaskFrame) :
    liftH F (projH F τ') (τ'.state 0).2 = τ' :=
  WorldHistory.ext_state fun t => Prod.ext rfl (clock_eq F τ' t).symm

/-- **No history of the product visits a world state twice.** -/
theorem no_recurrence (τ' : WorldHistory F.translationProduct.toTaskFrame) {s t : ↑D}
    (h : τ'.state s = τ'.state t) : s = t := by
  have h2 : (τ'.state s).2 = (τ'.state t).2 := by rw [h]
  rw [clock_eq F τ' s, clock_eq F τ' t] at h2
  exact add_left_cancel h2

/-- **No two histories of the product transpose two world states**: the clock is monotone, so
the same pair of states cannot be visited in opposite orders. (In an ordered abelian group
`s + s = t + t` forces `s = t`.) -/
theorem no_transposition :
    ¬ ∃ (τ σ : WorldHistory F.translationProduct.toTaskFrame) (s t : ↑D),
      s ≠ t ∧ τ.state s = σ.state t ∧ τ.state t = σ.state s := by
  rintro ⟨τ, σ, s, t, hne, h1, h2⟩
  have e1 : (τ.state 0).2 + s = (σ.state 0).2 + t := by
    rw [← clock_eq, ← clock_eq, h1]
  have e2 : (τ.state 0).2 + t = (σ.state 0).2 + s := by
    rw [← clock_eq, ← clock_eq, h2]
  have h4 : ((τ.state 0).2 + (σ.state 0).2) + (s + s)
      = ((τ.state 0).2 + (σ.state 0).2) + (t + t) := by
    calc ((τ.state 0).2 + (σ.state 0).2) + (s + s)
        = ((τ.state 0).2 + s) + ((σ.state 0).2 + s) := by abel
      _ = ((σ.state 0).2 + t) + ((τ.state 0).2 + t) := by rw [e1, ← e2]
      _ = ((τ.state 0).2 + (σ.state 0).2) + (t + t) := by abel
  have h5 : s + s = t + t := add_left_cancel h4
  rcases lt_trichotomy s t with hlt | heq | hgt
  · exact absurd h5 (ne_of_lt (add_lt_add hlt hlt))
  · exact hne heq
  · exact absurd h5 (ne_of_gt (add_lt_add hgt hgt))

/-- The product is recurrence-free, against the live predicate `TaskFrame.RecurrenceFree`. -/
theorem translationProduct_recurrenceFree : F.translationProduct.toTaskFrame.RecurrenceFree :=
  fun τ' _ _ h => no_recurrence F τ' h

/-- The lift of a model: the valuation ignores the clock, since sentence letters denote sets
of world states (`def:BL-semantics`). -/
def liftModel (M : TaskModel F.toTaskFrame) : TaskModel F.translationProduct.toTaskFrame :=
  ⟨fun a p => M.valuation a.1 p⟩

/-- The lift of a history through a given product state at a given time: choosing the offset
`a.2 - t` puts the lift at `a` at time `t`. -/
theorem liftH_through (ρ : WorldHistory F.toTaskFrame) (a : F.WorldState × ↑D) (t : ↑D)
    (h : a.1 = ρ.state t) : (liftH F ρ (a.2 - t)).state t = a :=
  Prod.ext h.symm (by change a.2 - t + t = a.2; exact sub_add_cancel _ _)

/-! ### Truth invariance under the projection, for `L`, `L⁺` and `L⋆` -/

/-- **`L`: truth is preserved by the projection**, for lifted models. The `□` clause ranges over
all histories of the product; each is the lift of its projection, so the quantifier transfers. -/
theorem truth_invariance (M : TaskModel F.toTaskFrame) :
    ∀ (φ : Formula) (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D),
      TruthAt (liftModel F M) τ' t φ ↔ TruthAt M (projH F τ') t φ := by
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

/-- **`L⁺`: truth is preserved by the projection**, for lifted models. The `⊡` clause is where
the clock matters: a history through the projected state lifts to a history through the product
state itself, with the clock offset read off that state (`liftH_through`). -/
theorem plus_invariance (M : TaskModel F.toTaskFrame) :
    ∀ (φ : PlusFormula) (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D),
      PlusTruthAt (liftModel F M) τ' t φ ↔ PlusTruthAt M (projH F τ') t φ := by
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

/-- **`L⋆`: truth is preserved by the projection, at every register vector**, for lifted
models. The two register clauses are inert (`def:BLstar-semantics`): `timeStore` updates the
vector and `timeRecall` moves the time, and neither touches the history. Recurrence is
therefore invisible to `L⋆` as well. -/
theorem star_invariance (M : TaskModel F.toTaskFrame) :
    ∀ (φ : StarFormula) (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D)
      (v : ℕ → ↑D),
      StarTruthAt (liftModel F M) τ' t v φ ↔ StarTruthAt M (projH F τ') t v φ := by
  intro φ
  induction φ with
  | atom p => intro τ' t v; exact Iff.rfl
  | bot => intro τ' t v; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t v; exact imp_congr (ih1 τ' t v) (ih2 τ' t v)
  | box a ih =>
    intro τ' t v
    constructor
    · intro h ρ
      have := (ih (liftH F ρ 0) t v).1 (h _)
      rwa [projH_liftH] at this
    · intro h σ'; exact (ih σ' t v).2 (h _)
  | untl a b ih1 ih2 =>
    intro τ' t v
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s v) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r v)
  | snce a b ih1 ih2 =>
    intro τ' t v
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s v) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r v)
  | stab a ih =>
    intro τ' t v
    constructor
    · intro h ρ hρ
      have hl := liftH_through F ρ (τ'.state t) t hρ
      have := (ih _ t v).1 (h _ hl.symm)
      rwa [projH_liftH] at this
    · intro h σ' he
      exact (ih σ' t v).2 (h _ (congrArg Prod.fst he))
  | timeStore i a ih => intro τ' t v; exact ih τ' t _
  | timeRecall i a ih => intro τ' t v; exact ih τ' _ v

/-! ### Frame validity passes from the product to the base -/

/-- Frame validity of an `L⁺` formula on the product implies frame validity on `F`: lift the
model and the history. The converse fails — see `frame_validity_not_reflected`. -/
theorem plusValidOn_of_prod (φ : PlusFormula)
    (h : F.translationProduct.toTaskFrame.PlusValidOn φ) : F.toTaskFrame.PlusValidOn φ := by
  intro M τ t
  have := (plus_invariance F M φ (liftH F τ 0) t).1 (h _ _ _)
  rwa [projH_liftH] at this

/-- Frame validity of an `L⋆` formula on the product implies frame validity on `F`. The
converse fails — see `frame_validity_not_reflected`. -/
theorem starValidOn_of_prod (φ : StarFormula)
    (h : F.translationProduct.toTaskFrame.StarValidOn φ) : F.toTaskFrame.StarValidOn φ := by
  intro M τ t v
  have := (star_invariance F M φ (liftH F τ 0) t v).1 (h _ _ _ _)
  rwa [projH_liftH] at this

/-- Frame validity of an `L` formula on the product implies frame validity on `F`. The
converse fails — see `frame_validity_not_reflected`. -/
theorem validOn_of_prod (φ : Formula)
    (h : F.translationProduct.toTaskFrame.ValidOn φ) : F.toTaskFrame.ValidOn φ := by
  intro M τ t
  have := (truth_invariance F M φ (liftH F τ 0) t).1 (h _ _ _)
  rwa [projH_liftH] at this

/-- **The projection is a history-lifting morphism** — the intended instance of `HistMorphism`.
`forth` is the first conjunct of the task relation, `lift` is `liftH_through`, `onto` is the
lift at offset `0`. -/
def FrameOver.translationProductProj : HistMorphism F.translationProduct F where
  toFun := Prod.fst
  forth := fun _ _ _ h => ((FrameOver.translationProduct_taskRel F _ _ _).1 h).1
  lift := fun τ a t h => ⟨liftH F τ (a.2 - t), liftH_through F τ a t h, fun _ => rfl⟩
  onto := fun τ => ⟨liftH F τ 0, fun _ => rfl⟩

end Frame

/-! ## Class validity equals validity over the recurrence-free members -/

section ClassValidity

/-- **At every frame class, `L⁺`-validity over the class equals `L⁺`-validity over its
recurrence-free members.** The recurrence-free members are a subclass (⇒); every frame of the
class is covered by its translation product, which is recurrence-free and lies in the class (⇐).
The two object languages therefore cannot see recurrence at the level of a frame class — the
class-level statement behind `HybridLanguage/`'s and `QuantLanguage/`'s frame-level invariances.

Paper: — (formalization-native; the paper defines no product of task frames) -/
theorem plusValidIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass)
    (φ : PlusFormula) :
    PlusValidIn fc φ ↔ PlusValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ := by
  constructor
  · intro h G hG; exact h G hG.1
  · intro h G hG
    have hp : G.toFibre.translationProduct.toTaskFrame.PlusValidOn φ :=
      h _ ⟨(FrameOver.translationProduct_sat G.toFibre fc).2 hG,
        translationProduct_recurrenceFree G.toFibre⟩
    exact plusValidOn_of_prod G.toFibre φ hp

/-- **At every frame class, `L`-validity over the class equals `L`-validity over its
recurrence-free members.** See `plusValidIn_iff_recurrenceFree`.

Paper: — (formalization-native; the paper defines no product of task frames) -/
theorem validIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass) (φ : Formula) :
    ValidIn fc φ ↔ ValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ := by
  constructor
  · intro h G hG; exact h G hG.1
  · intro h G hG
    have hp : G.toFibre.translationProduct.toTaskFrame.ValidOn φ :=
      h _ ⟨(FrameOver.translationProduct_sat G.toFibre fc).2 hG,
        translationProduct_recurrenceFree G.toFibre⟩
    exact validOn_of_prod G.toFibre φ hp

/-- **At every frame class, `L⋆`-validity over the class equals `L⋆`-validity over its
recurrence-free members.** See `plusValidIn_iff_recurrenceFree`; the register clauses are inert
(`star_invariance`).

Paper: — (formalization-native; the paper defines no product of task frames) -/
theorem starValidIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass)
    (φ : StarFormula) :
    StarValidIn fc φ ↔ StarValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) φ := by
  constructor
  · intro h G hG; exact h G hG.1
  · intro h G hG
    have hp : G.toFibre.translationProduct.toTaskFrame.StarValidOn φ :=
      h _ ⟨(FrameOver.translationProduct_sat G.toFibre fc).2 hG,
        translationProduct_recurrenceFree G.toFibre⟩
    exact starValidOn_of_prod G.toFibre φ hp

/-- **Frame-level validity is not reflected by the product.** On the one-state frame `p → Gp`
is valid (every history is constant); on its product — the translation frame on `D` — the
clock-dependent valuation `V (u, e) p := e ≤ 0` refutes it at time `0`. The product validates
strictly fewer formulas than its base: the projection transports truth for lifted valuations
only, and the extra valuations on `W × D` are exactly the manuscript's abundant two-dimensional
models (`sub:AbsoluteTime`, *Abundance*: "for every `w ∈ W` and `x, y ∈ T`, there is some
`w' ∈ W` that is time-shifted from `x` to `y`"). This is why the class-level theorems above
quantify over a frame class and never argue frame by frame. -/
theorem frame_validity_not_reflected {D : TemporalOrder} :
    ∃ φ : PlusFormula,
      (FrameOver.trivialFrame (D := ↑D)).toTaskFrame.PlusValidOn φ ∧
      ¬ (FrameOver.trivialFrame (D := ↑D)).translationProduct.toTaskFrame.PlusValidOn φ := by
  refine ⟨(PlusFormula.atom ⟨"p", none⟩).imp
    (PlusFormula.allFuture (PlusFormula.atom ⟨"p", none⟩)), ?_, ?_⟩
  · intro M τ t hp
    rw [PlusTruth.allFuture_iff]
    intro s _
    haveI : Subsingleton (FrameOver.trivialFrame (D := ↑D)).WorldState :=
      inferInstanceAs (Subsingleton Unit)
    have : τ.state s = τ.state t := Subsingleton.elim _ _
    change M.valuation (τ.state s) ⟨"p", none⟩
    rw [this]; exact hp
  · intro h
    obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
    let M : TaskModel (FrameOver.trivialFrame (D := ↑D)).translationProduct.toTaskFrame :=
      ⟨fun a _ => a.2 ≤ 0⟩
    let τ : WorldHistory (FrameOver.trivialFrame (D := ↑D)).translationProduct.toTaskFrame :=
      liftH _ (WorldHistory.ofTotal _ (fun _ => ()) fun _ _ =>
        FrameOver.trivialFrame_taskRel.mpr True.intro) 0
    have h1 := h M τ 0
    have hp : PlusTruthAt M τ 0 (PlusFormula.atom ⟨"p", none⟩) := by
      change (0 : ↑D) + 0 ≤ 0
      rw [add_zero]
    have h2 := (PlusTruth.allFuture_iff _ _ _ _).1 (h1 hp) x hx
    have h3 : (0 : ↑D) + x ≤ 0 := h2
    rw [zero_add] at h3
    exact absurd hx (not_lt.2 h3)

end ClassValidity

end FormalSystem.Semantics
