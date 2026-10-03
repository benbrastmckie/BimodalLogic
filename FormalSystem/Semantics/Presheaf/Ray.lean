/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.Presheaf.Behavior

/-!
# The ray layer: half-line sections at a seam

The behavior presheaf's sections `Beh F l` are **bounded**: their domain is exactly `[0, l]`. The
objects a decidability construction quantifies over are not bounded — a possible world extends
indefinitely in both directions — and the structure it needs is the pair of **rays** at a seam
time: the half-line `(-∞, t]` running backward out of the seam, and the half-line `[t, ∞)` running
forward out of it.

`PastRay F t` and `FutRay F t` are those two half-line sections. Each is a dependent function on a
**time subtype** — `{x : F.Duration // x ≤ t}` and `{x // t ≤ x}` — carrying the all-pairs task
constraint. No new structure is introduced to present them: `Semantics/PartialHistory.lean`'s
`domain` field is an arbitrary predicate on `F.Duration`, so a half-line domain is already
expressible there, and `PastRay.toPH`/`FutRay.toPH` are exactly that reading.

## Why the subtype domain, and why both presentations

The subtype-of-dependent-function form is load-bearing and is **not** interchangeable with the
`PartialHistory` form. Two rays are equal exactly when their values agree, by `funext` on the time
subtype; that is what `seamFibreEquiv`'s `right_inv` round trip is proved by. A
`PartialHistory`-valued presentation would instead require `partialHistory_ext` and a domain-level
argument at every such step.

Both presentations are therefore kept, as separate declarations rather than as one retyped
definition: the dependent-function form is primary and carries every statement, and `toPH` is the
bridge that buys access to the shared `PartialHistory` API — in particular
`PartialHistory.rel_across_seam`, which is where the seam step of the gluing operator is actually
proved. `FutRay.toBeh` is the bridge in the other direction, cutting a bounded section `Beh F l`
out of a forward ray at `0`.

## What is deliberately absent

**The colimit-of-bounded-sections route is not taken here.** Presenting a ray as a directed
colimit of the sections `Beh F l` over increasing `l` is the route that incurs *Saturation*: the
union of an increasing chain of bounded sections need not admit a value at the limit point, and
the directed gluing case that would repair it rests on the Extension Theorem. The rays are
therefore defined directly on their half-lines, where no limit is taken and no frame constraint
beyond the one the gluing operator's seam step needs is in play. The directed/colimit case is
elsewhere by charter, and nothing in this module may be read as having settled it.

## The gluing operator at the ray layer

`Ray.seamGlue` takes a past ray and a future ray agreeing at the seam to the possible world
following the first up to and including the seam and the second after it. This is the paper's own
`⌢_z`, in the case its pasting passage applies it in: that passage defines the operator by
applying the gluing lemma to the restrictions of two histories to `(−∞, z]` and `[z, ∞)`, so the
**ray layer is the primary case** and `PlusLanguage.PlusPasting.paste` — the same operator on
two *total* histories — is its total-history instance. Neither `paste` nor `Presheaf.glue` is
re-derived here; the material below is the half-line operator only, with its two reading
equations, its two restriction identities, uniqueness, and totality.

**The frame law actually used is `TaskFrame.comp` together with the reflection convention, and
nothing else.** The seam step is not proved here either: it is delegated to
`PartialHistory.rel_across_seam` at the two rays' `toPH` readings, with both seam coordinates
taken at `t`, which is the de-duplication that lemma exists to create. The bracketed
`[F.IsRegular]` binder supplies more than the construction consumes — the explicit, binder-free
form of the content is `rel_across_seam`'s own signature, which takes `TaskFrame.Compositional`
as a hypothesis — and the binder is carried here because the promoted keystone statement below is
to be the probed statement, hypothesis for hypothesis.

**Choice-freedom, measured.** `#print axioms` reports `[propext, Quot.sound]` on every
declaration of the ray layer and its gluing operator — `seamGlueFun` needs only `[propext]` —
with no `Classical.choice` anywhere. One step earns that and would lose it if rewritten: the
mixed-orientation case of `seamGlue_rel`, which runs *backwards* across the seam, goes through the
off-zero reflection law `TaskFrame.reflection_of_ne` rather than the unrestricted
`TaskFrame.reflection`, and suffices because that case is strict. Substituting the unrestricted
law reinstates `Classical.choice` on `seamGlue_rel` and on everything downstream of it, the promoted
keystone included.

**Why `seamGlue` and not `glue`.** `Semantics/Presheaf/Sheaf.lean` already declares `glue`,
`glue_states_le`, `glue_states_not_le` and `glue_unique` for two *bounded* sections. A
sub-namespace is not enough separation: the repository's dead-declaration census keys on the last
dot-segment, so two declarations sharing a base name mask each other and neither can be reported
dead. The half-line operator therefore carries its own base name throughout, which also keeps the
parallel with `Sheaf.lean` legible rather than accidental.

**The branch test is the order's own.** `seamGlueFun` splits on `if h : s ≤ t`, whose `Decidable`
instance comes from the `LinearOrder` carried by the frame's temporal order rather than from
`Classical.propDecidable`, so the split is computational and contributes no axiom. It is a `dite`
and not an `ite` because each branch needs its own half-line witness, which is also what makes
`seamGlue_states_le`/`seamGlue_states_not_le` literally `dif_pos` and `dif_neg`.

## Main Definitions

- `PastRay F t`, `FutRay F t`: the half-line sections at `t`, as dependent functions on the time
  subtypes `{x // x ≤ t}` and `{x // t ≤ x}` with the unconditional all-pairs task constraint.
- `PastRay.seam`, `FutRay.seam`: a ray's state at the seam — the right endpoint of a past ray, the
  left endpoint of a future ray.
- `pastOf`, `futOf`: the two restriction maps from a possible world to its rays at a time.
- `PastRay.toPH`, `FutRay.toPH`: the same rays read as `PartialHistory F` with a half-line domain,
  the form that reaches the shared `PartialHistory` API.
- `FutRay.toBeh`: the ray-layer-to-`Beh F l` restriction — a forward ray at `0` cut down to the
  bounded section over `l`.
- `Ray.seamGlueFun`, `Ray.seamGlue`: the pasted state function of a ray pair, and the possible
  world it determines.
- `StabFibre F t s`: the `⊡` quantification domain at `(t, s)` — the possible worlds in state `s`
  at time `t`, which is `PlusTruth.stab_iff`'s domain verbatim.
- `RayPair F t s`: the fibre product of the past-ray and future-ray spaces over the seam state.

## Main Results

- `PastRay.toPH_states`, `FutRay.toPH_states`, `FutRay.toBeh_states`: the reading equations of the
  three bridges, all `rfl`.
- `Ray.seamGlue_rel_le_lt`: the task relation across the seam, delegated to
  `PartialHistory.rel_across_seam`.
- `Ray.seamGlue_rel`: the glued state function respects the task relation at every pair of times —
  four cases, because `PartialHistory.respects_task` is unconditional.
- `Ray.seamGlue_states_le`, `Ray.seamGlue_states_not_le`: the two reading equations of
  `Ray.seamGlue`, one per branch of its dependent `if`. Every later proof reads the gluing
  through these.
- `Ray.seamGlue_isTotal`: **totality** — the glued object is total on all of `F.Duration`.
- `Ray.pastOf_seamGlue`, `Ray.futOf_seamGlue`: the two restriction identities. The second is
  where the seam hypothesis is consumed, because at the seam point itself the branch test is
  *true*.
- `Ray.seamGlue_unique`: any possible world restricting to the two rays is the gluing.
- `Ray.seamGlue_clause`: the clause as the `∃!` those three results package — the half-line
  counterpart of `Presheaf.sheaf_clause` for two bounded sections.
- `seamFibreEquiv`: **the keystone** — the `⊡` fibre over a seam state *is* the fibre product of
  the past-ray and future-ray spaces over that state. Forward: restrict. Backward: glue. The two
  round trips are `WorldHistory.ext_state` and funext, at any duration.

## References

* JPL paper `app:gluing` — the gluing lemma for convex histories agreeing on their overlap, whose
  seam case is the one this module's rays are cut for. Cited as a **pointer only**: its record row
  in `docs/reference/paper-definitions-of-record.md` is `LIVE-UNPINNED` precisely because no
  docstring quotes its text, and this one does not either
* JPL paper `def:world-history` — partial, convex and world histories; a ray is the convex-history
  case at a half-line domain
* `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory`, whose `domain` field is an
  arbitrary predicate and so already expresses a half-line, and `WorldHistory`
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, the bounded sections `FutRay.toBeh`
  lands in, and `partialHistory_ext`
* `FormalSystem/Semantics/Presheaf/Sheaf.lean` — the *Sheaf* clause for two **bounded** sections,
  the binary gluing this module's seam operator is the half-line counterpart of
* `FormalSystem/Semantics/Extension/Extension.lean` — the Extension Theorem, where the directed
  gluing case takes on its dependence on *Saturation*
* `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory.rel_across_seam`, the seam
  argument the gluing operator delegates to, stated once off totality with two independent seam
  coordinates
* `FormalSystem/PlusLanguage/PlusPasting.lean` — `paste`, `paste_rel`, `paste_agreeFrom` and
  `paste_agreeUpTo`: the same operator on two *total* histories, the total-history instance of the
  half-line operator here, and not re-derived in this module
-/

namespace FormalSystem.Semantics.Presheaf

variable {F : TaskFrame}

/-! ## The two ray types -/

/-- A **past ray** at `t`: a convex history on `(-∞, t]`, as a dependent function on the times
`≤ t` with the all-pairs task constraint. The domain is a subtype rather than a predicate on all
of `F.Duration` so that two rays are equal exactly when their values agree (funext). -/
def PastRay (F : TaskFrame) (t : F.Duration) : Type _ :=
  {g : {x : F.Duration // x ≤ t} → F.WorldState //
    ∀ x y : {x : F.Duration // x ≤ t}, F.TaskRel (g x) (y.1 - x.1) (g y)}

/-- A **future ray** at `t`: a convex history on `[t, ∞)`. -/
def FutRay (F : TaskFrame) (t : F.Duration) : Type _ :=
  {g : {x : F.Duration // t ≤ x} → F.WorldState //
    ∀ x y : {x : F.Duration // t ≤ x}, F.TaskRel (g x) (y.1 - x.1) (g y)}

/-- The seam value of a past ray: its state at `t`, the right endpoint. -/
def PastRay.seam {t : F.Duration} (b : PastRay F t) : F.WorldState := b.1 ⟨t, le_rfl⟩

/-- The seam value of a future ray: its state at `t`, the left endpoint. -/
def FutRay.seam {t : F.Duration} (f : FutRay F t) : F.WorldState := f.1 ⟨t, le_rfl⟩

/-! ## Restriction of a possible world to its two rays -/

/-- Restriction of a possible world to the past half-line. -/
def pastOf (σ : WorldHistory F) (t : F.Duration) : PastRay F t :=
  ⟨fun x => σ.state x.1, fun x y => σ.respects_task x.1 y.1⟩

/-- Restriction of a possible world to the future half-line. -/
def futOf (σ : WorldHistory F) (t : F.Duration) : FutRay F t :=
  ⟨fun x => σ.state x.1, fun x y => σ.respects_task x.1 y.1⟩

/-! ## The bridges to the shared `PartialHistory` API and to `Beh` -/

/-- A past ray read as a `PartialHistory` with the half-line domain `fun x => x ≤ t`. This is the
form that reaches `PartialHistory.rel_across_seam`; the dependent-function form above stays
primary, because it is the one whose equality is funext. -/
def PastRay.toPH {t : F.Duration} (b : PastRay F t) : PartialHistory F where
  domain := fun x => x ≤ t
  nonempty_domain := ⟨t, le_rfl⟩
  states := fun x hx => b.1 ⟨x, hx⟩
  respects_task := fun s s' hs hs' => b.2 ⟨s, hs⟩ ⟨s', hs'⟩

/-- A future ray read as a `PartialHistory` with the half-line domain `fun x => t ≤ x`. -/
def FutRay.toPH {t : F.Duration} (f : FutRay F t) : PartialHistory F where
  domain := fun x => t ≤ x
  nonempty_domain := ⟨t, le_rfl⟩
  states := fun x hx => f.1 ⟨x, hx⟩
  respects_task := fun s s' hs hs' => f.2 ⟨s, hs⟩ ⟨s', hs'⟩

@[simp] theorem PastRay.toPH_states {t : F.Duration} (b : PastRay F t) {x : F.Duration}
    (hx : b.toPH.domain x) : b.toPH.states x hx = b.1 ⟨x, hx⟩ := rfl

@[simp] theorem FutRay.toPH_states {t : F.Duration} (f : FutRay F t) {x : F.Duration}
    (hx : f.toPH.domain x) : f.toPH.states x hx = f.1 ⟨x, hx⟩ := rfl

/-- The **ray-layer-to-`Beh` restriction**: a forward ray at `0`, cut down to the bounded section
over `l`. The domain is written as the literal predicate `fun t => 0 ≤ t ∧ t ≤ l`, so the section
condition is `Iff.rfl` — the discharge the behavior presheaf's own Implementation Notes record. -/
def FutRay.toBeh (f : FutRay F 0) (l : F.Duration) (hl : 0 ≤ l) : Beh F l :=
  ⟨{ domain := fun t => 0 ≤ t ∧ t ≤ l
     nonempty_domain := ⟨0, le_rfl, hl⟩
     states := fun t ht => f.1 ⟨t, ht.1⟩
     respects_task := fun s t hs ht => f.2 ⟨s, hs.1⟩ ⟨t, ht.1⟩ },
   fun _ => Iff.rfl⟩

@[simp] theorem FutRay.toBeh_states (f : FutRay F 0) (l : F.Duration) (hl : 0 ≤ l)
    {t : F.Duration} (ht : (f.toBeh l hl).val.domain t) :
    (f.toBeh l hl).val.states t ht = f.1 ⟨t, ht.1⟩ := rfl

/-! ## The ray-layer gluing operator -/

namespace Ray

/-- The pasted state function of a ray pair: the past ray up to and including `t`, the future ray
after. The split is a dependent `if` so each branch carries the half-line witness it needs, and
the test's `Decidable` instance is the temporal order's own `LinearOrder` — so the split is
computational and contributes no axiom. -/
def seamGlueFun {t : F.Duration} (b : PastRay F t) (f : FutRay F t) :
    F.Duration → F.WorldState :=
  fun s => if h : s ≤ t then b.1 ⟨s, h⟩ else f.1 ⟨s, (not_le.mp h).le⟩

/-- The task relation across the seam, from the past ray at `s ≤ t` to the future ray at
`s' > t`: composition through the shared seam state. Delegated to the shared seam argument
`PartialHistory.rel_across_seam` at the two rays' `toPH` readings, with both seam coordinates
taken at `t`; the frame law reaching it is `TaskFrame.comp` and nothing else. -/
theorem seamGlue_rel_le_lt [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) {s s' : F.Duration} (hs : s ≤ t) (hs' : ¬ s' ≤ t) :
    F.TaskRel (b.1 ⟨s, hs⟩) (s' - s) (f.1 ⟨s', (not_le.mp hs').le⟩) :=
  PartialHistory.rel_across_seam (F.comp) (σ := b.toPH) (τ := f.toPH)
    (hσm := le_rfl) (hτm' := le_rfl) (hmatch := hseam)
    (hs := hs) (hs' := (not_le.mp hs').le) (hsm := hs) (hm's' := (not_le.mp hs').le)
    (hd := by rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm)

/-- The glued state function respects the task relation at every pair of times. Four cases,
because `PartialHistory.respects_task` is unconditional: both inside the past ray, both inside
the future ray, and the two mixed orientations. The mixed case running *backwards* across the
seam goes through the off-zero reflection law `TaskFrame.reflection_of_ne`, which suffices
because that case is strict — and which is what keeps the construction clear of
`Classical.choice`. -/
theorem seamGlue_rel [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) :
    ∀ s s' : F.Duration, F.TaskRel (seamGlueFun b f s) (s' - s) (seamGlueFun b f s') := by
  intro s s'
  unfold seamGlueFun
  by_cases hs : s ≤ t <;> by_cases hs' : s' ≤ t
  · rw [dif_pos hs, dif_pos hs']; exact b.2 ⟨s, hs⟩ ⟨s', hs'⟩
  · rw [dif_pos hs, dif_neg hs']; exact seamGlue_rel_le_lt b f hseam hs hs'
  · rw [dif_neg hs, dif_pos hs']
    have hne : s' - s ≠ 0 := sub_ne_zero.mpr (by intro h; exact hs (h ▸ hs'))
    rw [F.reflection_of_ne hne, neg_sub]
    exact seamGlue_rel_le_lt b f hseam hs' hs
  · rw [dif_neg hs, dif_neg hs']
    exact f.2 ⟨s, (not_le.mp hs).le⟩ ⟨s', (not_le.mp hs').le⟩

/-- **Seam gluing at the ray layer.** A past ray and a future ray agreeing at the seam glue to a
possible world — the paper's `⌢_z` in the case its own pasting passage applies it in. -/
def seamGlue [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) : WorldHistory F :=
  WorldHistory.ofTotal F (seamGlueFun b f) (seamGlue_rel b f hseam)

@[simp]
theorem seamGlue_states_le [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) {s : F.Duration} (hs : s ≤ t) :
    (seamGlue b f hseam).state s = b.1 ⟨s, hs⟩ := by
  change seamGlueFun b f s = _
  rw [seamGlueFun, dif_pos hs]

@[simp]
theorem seamGlue_states_not_le [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) {s : F.Duration} (hs : ¬ s ≤ t) :
    (seamGlue b f hseam).state s = f.1 ⟨s, (not_le.mp hs).le⟩ := by
  change seamGlueFun b f s = _
  rw [seamGlueFun, dif_neg hs]

/-- **Totality.** The glued object is a world history — total on all of `F.Duration` — because
the two half-lines cover the duration type and meet in exactly one point. Stated as a named fact
rather than left implicit in the type, because the effective-extension verdict recorded in this
module's final section rests on it. -/
theorem seamGlue_isTotal [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) : (seamGlue b f hseam).val.IsTotal :=
  (seamGlue b f hseam).property

/-- **The first restriction identity**: the glued world's past ray at the seam is the past ray it
was glued from. -/
theorem pastOf_seamGlue [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) : pastOf (seamGlue b f hseam) t = b := by
  refine Subtype.ext (funext fun x => ?_)
  change (seamGlue b f hseam).state x.1 = b.1 x
  rw [seamGlue_states_le _ _ _ x.2]

/-- **The second restriction identity**: the glued world's future ray at the seam is the future
ray it was glued from. This is where the seam hypothesis is consumed — at the seam point itself
the branch test is *true*, so the glued world reads the **past** ray there, and only `hseam`
closes the gap. -/
theorem futOf_seamGlue [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) : futOf (seamGlue b f hseam) t = f := by
  refine Subtype.ext (funext fun x => ?_)
  change (seamGlue b f hseam).state x.1 = f.1 x
  by_cases hx : x.1 ≤ t
  · have hxt : x.1 = t := le_antisymm hx x.2
    rw [seamGlue_states_le _ _ _ hx]
    have hb' : b.1 ⟨x.1, hx⟩ = b.seam := by
      rw [show (⟨x.1, hx⟩ : {y : F.Duration // y ≤ t}) = ⟨t, le_rfl⟩ from Subtype.ext hxt]
      rfl
    have hf' : f.1 x = f.seam := by
      rw [show x = (⟨t, le_rfl⟩ : {y : F.Duration // t ≤ y}) from Subtype.ext hxt]
      rfl
    rw [hb', hf', hseam]
  · rw [seamGlue_states_not_le _ _ _ hx]

/-- **Uniqueness**: any possible world restricting to `b` and `f` at the seam is the gluing. -/
theorem seamGlue_unique [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) (σ : WorldHistory F) (hb : pastOf σ t = b) (hf : futOf σ t = f) :
    σ = seamGlue b f hseam := by
  refine WorldHistory.ext_state fun r => ?_
  by_cases hr : r ≤ t
  · rw [seamGlue_states_le _ _ _ hr, ← hb]; rfl
  · rw [seamGlue_states_not_le _ _ _ hr, ← hf]; rfl

/-- **The ray-layer gluing clause**, as the `∃!` its two restriction identities and uniqueness
package — the half-line counterpart of `Presheaf.sheaf_clause`'s statement for two bounded
sections. -/
theorem seamGlue_clause [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) :
    ∃! σ : WorldHistory F, pastOf σ t = b ∧ futOf σ t = f :=
  ⟨seamGlue b f hseam, ⟨pastOf_seamGlue b f hseam, futOf_seamGlue b f hseam⟩,
    fun _ hσ => seamGlue_unique b f hseam _ hσ.1 hσ.2⟩

end Ray

/-! ## The stab fibre and its ray-product presentation -/

/-- The `⊡` quantification domain at `(t, s)`: the possible worlds in state `s` at time `t`.
This is `PlusTruth.stab_iff`'s domain verbatim. -/
def StabFibre (F : TaskFrame) (t : F.Duration) (s : F.WorldState) : Type _ :=
  {σ : WorldHistory F // σ.state t = s}

/-- The **fibre product** of the past-ray and future-ray spaces over the seam state `s`. -/
def RayPair (F : TaskFrame) (t : F.Duration) (s : F.WorldState) : Type _ :=
  {bf : PastRay F t × FutRay F t // bf.1.seam = s ∧ bf.2.seam = s}

/--
**THE KEYSTONE.** The `⊡` fibre over a seam state is the fibre product of the past-ray and
future-ray spaces over that state.

Forward: restrict. Backward: glue. The two round trips are `WorldHistory.ext_state` and funext,
at any duration — see the module docstring for the frame law the gluing step reaches and for why
nothing stronger is in play.
-/
def seamFibreEquiv [F.IsRegular] (t : F.Duration) (s : F.WorldState) :
    StabFibre F t s ≃ RayPair F t s where
  toFun σ := ⟨(pastOf σ.1 t, futOf σ.1 t), σ.2, σ.2⟩
  invFun bf := ⟨Ray.seamGlue bf.1.1 bf.1.2 (bf.2.1.trans bf.2.2.symm),
    by rw [Ray.seamGlue_states_le _ _ _ le_rfl]; exact bf.2.1⟩
  left_inv := by
    rintro ⟨σ, hσ⟩
    refine Subtype.ext (WorldHistory.ext_state fun r => ?_)
    by_cases hr : r ≤ t
    · rw [Ray.seamGlue_states_le _ _ _ hr]; rfl
    · rw [Ray.seamGlue_states_not_le _ _ _ hr]; rfl
  right_inv := by
    rintro ⟨⟨b, f⟩, hb, hf⟩
    have hseam : b.seam = f.seam := hb.trans hf.symm
    refine Subtype.ext (Prod.ext (Subtype.ext (funext fun x => ?_))
      (Subtype.ext (funext fun x => ?_)))
    · change (Ray.seamGlue b f hseam).state x.1 = b.1 x
      rw [Ray.seamGlue_states_le _ _ _ x.2]
    · change (Ray.seamGlue b f hseam).state x.1 = f.1 x
      by_cases hx : x.1 ≤ t
      · have hxt : x.1 = t := le_antisymm hx x.2
        rw [Ray.seamGlue_states_le _ _ _ hx]
        have hb' : b.1 ⟨x.1, hx⟩ = s := by
          rw [show (⟨x.1, hx⟩ : {y : F.Duration // y ≤ t}) = ⟨t, le_rfl⟩ from Subtype.ext hxt]
          exact hb
        have hf' : f.1 x = s := by
          rw [show x = (⟨t, le_rfl⟩ : {y : F.Duration // t ≤ y}) from Subtype.ext hxt]
          exact hf
        rw [hb', hf']
      · rw [Ray.seamGlue_states_not_le _ _ _ hx]

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
