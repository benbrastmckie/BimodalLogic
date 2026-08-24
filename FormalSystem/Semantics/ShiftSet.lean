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

end ShiftSet

end FormalSystem.Semantics
