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

## Main Results

- `PastRay.toPH_states`, `FutRay.toPH_states`, `FutRay.toBeh_states`: the reading equations of the
  three bridges, all `rfl`.

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

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
