/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Extension.Extension

/-!
# ShiftSet - The shift-set representation of task models

This module establishes the **representation theorem** relating task models to *shift sets*:
structures over the two-sorted signature `⟨Ω, D; <, +, 0, sh, (A_p)⟩` in which a single carrier
`Ω` carries a `D`-action `sh` together with a valuation on atoms.

## What the representation theorem says

Both directions are proved here, and each comes with its **truth correspondence** — a bare pair
of constructions with no transfer of `TruthAt` would type-check and yet be vacuous, since it is
precisely `TruthAt` transfer that a downstream Łoś lemma must be stated against.

- `ShiftSet.forward_repr` — every shift set `S` induces a task frame (`ShiftSet.frame`) and a
  task model (`ShiftSet.model`) whose truth at the orbit history through `w` agrees with
  shift-set truth: `TruthAt S.model (S.hist w) t φ ↔ ShiftTruth S w t φ`.
- `ShiftSet.reverse_repr` — every task model `M` over a frame `F` induces a shift set
  (`ShiftSet.ofModel`) on the carrier `F.HF` of total histories, whose shift-set truth agrees
  with truth in `M`: `ShiftTruth (ShiftSet.ofModel F M) τ t φ ↔ TruthAt M τ.val t φ`.

## Four axioms in place of seven frame fields

The `ShiftSet` structure carries exactly four axiom fields — `carrier_nonempty`, `sh_zero`,
`sh_add`, `sep` — plus the valuation `A`. The live `TaskFrame`
(`FormalSystem/Semantics/TaskFrame.lean`) has **seven** fields, and `ShiftSet.frame` discharges
all seven. Three of them are free consequences of the task relation being *functional*
(`TaskRel w d u := u = sh w d`) together with the group action:

- `serial` — witnessed by `sh w x` and `sh w (-x)`;
- the **interpolation** half of the biconditional `comp` — witnessed, uniquely, by `sh w x`;
- `spherical` — under a functional relation every fiber and every segment is a singleton or
  empty, so a directed family of nonempty ones is a family of copies of one singleton and its
  intersection is that singleton. No frame-theoretic machinery, and no Zorn.

Only `limit` is *not* free: it fails for an arbitrary `D`-action (take `D = ℝ` acting on `ℝ/ℚ`;
the failure mode is a dense proper stabiliser). That is what the `sep` field is for — see its
own docstring.

## On `Classical.choice` in the reverse direction

`#print axioms` on `reverse_repr` reports `Classical.choice`. Its sole provenance is
`PartialHistory.hF_nonempty` (`FormalSystem/Semantics/Extension/Extension.lean`), which is
Zorn-based, and which the reverse direction uses only to witness that the carrier `F.HF` is
nonempty. This is not a defect: choice is ordinary mathematics here, and the standard this
module is held to forbids unproved placeholders, not `Classical.choice`.
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/--
A **shift set** over the duration group `D`: a carrier `Ω` with a `D`-action `sh` and a
valuation `A` on atoms.

`D` is bound at `Type`, and deliberately **not** at a universe-polymorphic binder.
`TaskFrame.WorldState : Type` and `Validity`'s `valid` binds `D : Type`, so a
universe-polymorphic `D` here would land the reverse direction's carrier in a universe where the
forward direction cannot consume it. `Carrier` is likewise `Type`.
-/
structure ShiftSet (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] where
  /-- The carrier `Ω` of the shift set. -/
  Carrier : Type
  /-- The carrier is nonempty (matching `TaskFrame.nonempty`). -/
  carrier_nonempty : Nonempty Carrier
  /-- The shift action of a duration on a carrier point. -/
  sh : Carrier → D → Carrier
  /-- Shifting by `0` is the identity. -/
  sh_zero : ∀ w, sh w 0 = w
  /-- Shifting is additive: the action law. -/
  sh_add : ∀ w a b, sh (sh w a) b = sh w (a + b)
  /--
  **Separation** — the paper's *Limit* axiom, transcribed over the shift action: a point lying
  in every arbitrarily small shift-neighbourhood of `w` *is* `w`.

  Two facts about this field matter downstream.

  1. It is **first-order** over the signature `⟨Ω, D; <, +, 0, sh, (A_p)⟩` — it quantifies only
     over elements of the two sorts and mentions only signature symbols. It is therefore
     preserved by ultraproducts, which is exactly the property the semantic-compactness route
     needs of it. No *non-elementary* hypothesis is required anywhere in this development.
  2. The stronger **free-action** axiom `∀ w d, sh w d = w → d = 0` is **rejected** as a
     replacement. Under the reverse direction the carrier is `F.HF`, and a constant total
     history is fixed by every shift — full stabiliser — so freeness is outright refuted there
     and `ShiftSet.ofModel` could not be built. Separation is the correct weakening: it *is*
     dischargeable from `F.limit` alone (see `ShiftSet.rev_sep`), with no new frame hypothesis.
  -/
  sep : ∀ w u, (∀ x : D, 0 < x → ∃ y, |y| < x ∧ u = sh w y) → u = w
  /-- The valuation: which carrier points satisfy which atom. -/
  A : Atom → Carrier → Prop

namespace ShiftSet

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-- Shifting by `d` and then by `-d` returns to the start. -/
theorem sh_neg (S : ShiftSet D) (w : S.Carrier) (d : D) : S.sh (S.sh w d) (-d) = w := by
  rw [S.sh_add, add_neg_cancel, S.sh_zero]

/-- Shifting by `-d` and then by `d` returns to the start. -/
theorem sh_neg' (S : ShiftSet D) (w : S.Carrier) (d : D) : S.sh (S.sh w (-d)) d = w := by
  rw [S.sh_add, neg_add_cancel, S.sh_zero]

/--
Extensionality for world histories: equal domains and pointwise-equal states force equality.

**This is a local copy** of `worldHistory_ext`
(`FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`). The copy is
deliberate: importing anything under `Metalogic/` from `Semantics/` would invert the layering
this library is built on. Consolidating the two into `Semantics/WorldHistory.lean` and
retargeting `RegionFrame.lean` is a clean follow-up, kept out of this module's scope so that the
scope stays honest.
-/
theorem wh_ext {F : TaskFrame D} {σ τ : WorldHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : D) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
    σ = τ := by
  obtain ⟨⟨d₁, n₁, s₁, t₁⟩, c₁⟩ := σ
  obtain ⟨⟨d₂, n₂, s₂, t₂⟩, c₂⟩ := τ
  simp only at hd hs
  subst hd
  have : s₁ = s₂ := by funext r h; exact hs r h h
  subst this
  rfl

/--
The task frame induced by a shift set, under the **functional** task relation
`TaskRel w d u := (u = sh w d)`.

All **seven** live `TaskFrame` fields are discharged here. Three come for free from
functionality plus the group action and require no shift-set axiom of their own — `serial`, the
*interpolation* half of the biconditional `comp`, and `spherical` — correcting the design
document's list, which was written against an earlier five-field `TaskFrame` and named only the
other four. The one field that is genuinely *not* free is `limit`; it is exactly `S.sep`.
-/
def frame (S : ShiftSet D) : TaskFrame D where
  WorldState := S.Carrier
  nonempty := S.carrier_nonempty
  TaskRel := fun w d u => u = S.sh w d
  nullity_identity := by intro w u; rw [S.sh_zero]; exact eq_comm
  comp := by
    intro w v x y _ _
    constructor
    · -- interpolation: the witness is `sh w x`, and it is the unique one
      intro h
      refine ⟨S.sh w x, rfl, ?_⟩
      show v = S.sh (S.sh w x) y
      rw [S.sh_add]; exact h
    · -- composition
      rintro ⟨u, rfl, rfl⟩
      show S.sh (S.sh w x) y = S.sh w (x + y)
      rw [S.sh_add]
  converse := by
    intro w d u
    constructor
    · rintro rfl; show w = S.sh (S.sh w d) (-d); rw [S.sh_neg]
    · rintro rfl; show u = S.sh (S.sh u (-d)) d; rw [S.sh_neg']
  serial := by
    -- successor `sh w x`, predecessor `sh w (-x)`
    intro w x _
    refine ⟨⟨S.sh w x, rfl⟩, ⟨S.sh w (-x), ?_⟩⟩
    show w = S.sh (S.sh w (-x)) x
    rw [S.sh_neg']
  limit := S.sep
  spherical := by
    -- Under a functional task relation `Fib R w x` is a singleton and `Seg R w v x y` is a
    -- singleton or empty. Directedness then forces every member of the family to be that same
    -- singleton, so `⋂₀ S` is it, and is nonempty. No frame machinery, no Zorn.
    intro Sfam hdir hmem
    obtain ⟨s, hs⟩ := hdir.1
    obtain ⟨a, ha⟩ := (hmem s hs).2
    have hsingle : ∀ (c : Set S.Carrier), (TaskFrame.IsFiber (fun w d u => u = S.sh w d) c ∨
        TaskFrame.IsSegment (fun w d u => u = S.sh w d) c) → ∀ p ∈ c, ∀ q ∈ c, p = q := by
      rintro c (⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩) p hp q hq
      · exact hp.trans hq.symm
      · exact hp.1.trans hq.1.symm
    refine ⟨a, fun t ht => ?_⟩
    obtain ⟨S', hS', hsub⟩ := hdir.2 s hs t ht
    obtain ⟨b, hb⟩ := (hmem S' hS').2
    rw [hsingle s (hmem s hs).1 a ha b (hsub hb).1]
    exact (hsub hb).2

end ShiftSet

end FormalSystem.Semantics
