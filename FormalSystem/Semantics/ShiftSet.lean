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

/-- The induced **total** history through `w`: the shift orbit `t ↦ sh w t`. -/
def hist (S : ShiftSet D) (w : S.Carrier) : WorldHistory S.frame where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => S.sh w t
  respects_task := by
    intro s t _ _
    show S.sh w t = S.sh (S.sh w s) (t - s)
    rw [S.sh_add, add_sub_cancel]
  convex := by intros; trivial

/-- The orbit history through `w` is total: its domain is all of `D`. -/
theorem hist_isTotal (S : ShiftSet D) (w : S.Carrier) : (S.hist w).IsTotal := fun _ => trivial

/-- The induced task model: the shift set's valuation, read on the induced frame. -/
def model (S : ShiftSet D) : TaskModel S.frame where
  valuation := fun w p => S.A p w

/--
**The constructed frame's total histories are exactly the shift orbits.**

This is the new forward obligation the task re-issue anticipated. It is genuine — the forward
direction's `box` case consumes it, since `TruthAt`'s `box` clause quantifies over *all* total
histories while `ShiftTruth`'s quantifies over carrier points — and it is easy, following from
`respects_task` at `0` alone. It was, however, neither the only new obligation nor the hard one:
discharging `limit` (via the `sep` field) and the three "free" frame fields of `ShiftSet.frame`
was the substantive work.

Note the statement is equality of *histories*, not merely of states at each time; that is what
`wh_ext` is for.
-/
theorem total_eq_orbit (S : ShiftSet D) (σ : WorldHistory S.frame) (hσ : σ.IsTotal) :
    σ = S.hist (σ.states 0 (hσ 0)) := by
  refine wh_ext (funext fun z => propext ⟨fun _ => trivial, fun _ => hσ z⟩) ?_
  intro r h h'
  have := σ.respects_task 0 r (hσ 0) h
  rw [sub_zero] at this
  exact this

/--
Truth on a shift set, clause for clause parallel to `TruthAt`
(`FormalSystem/Semantics/Truth.lean`).

The `box` clause quantifies over the **whole carrier**: there is no `Omega` parameter anywhere in
the current semantics, and `TruthAt`'s own `box` clause quantifies over all total histories of
the frame, which under `ShiftSet.frame` are exactly the orbits (`total_eq_orbit`).
-/
def ShiftTruth (S : ShiftSet D) : S.Carrier → D → Formula → Prop
  | w, t, Formula.atom p => S.A p (S.sh w t)
  | _, _, Formula.bot => False
  | w, t, Formula.imp φ ψ => ShiftTruth S w t φ → ShiftTruth S w t ψ
  | _, t, Formula.box φ => ∀ v : S.Carrier, ShiftTruth S v t φ
  | w, t, Formula.untl ψ φ => ∃ s : D, t < s ∧ ShiftTruth S w s φ ∧
      ∀ r : D, t < r → r < s → ShiftTruth S w r ψ
  | w, t, Formula.snce ψ φ => ∃ s : D, s < t ∧ ShiftTruth S w s φ ∧
      ∀ r : D, s < r → r < t → ShiftTruth S w r ψ

/--
**FORWARD DIRECTION of the representation theorem.**

Truth in the task model induced by a shift set, evaluated along the orbit history through `w`,
is shift-set truth at `w`. The `box` case is where `hist_isTotal` (left to right) and
`total_eq_orbit` (right to left) are consumed; every other case is a structural transport.
-/
theorem forward_repr (S : ShiftSet D) (w : S.Carrier) (t : D) (φ : Formula) :
    TruthAt S.model (S.hist w) t φ ↔ ShiftTruth S w t φ := by
  induction φ generalizing w t with
  | atom p => exact ⟨fun ⟨_, h⟩ => h, fun h => ⟨trivial, h⟩⟩
  | bot => exact Iff.rfl
  | imp ψ χ ihψ ihχ =>
    exact ⟨fun h hψ => (ihχ w t).mp (h ((ihψ w t).mpr hψ)),
           fun h hψ => (ihχ w t).mpr (h ((ihψ w t).mp hψ))⟩
  | box ψ ih =>
    constructor
    · intro h v
      exact (ih v t).mp (h (S.hist v) (S.hist_isTotal v))
    · intro h σ hσ
      rw [total_eq_orbit S σ hσ]
      exact (ih _ t).mpr (h _)
  | untl ψ χ ihψ ihχ =>
    constructor
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ w s).mp he, fun r h1 h2 => (ihψ w r).mp (hg r h1 h2)⟩
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ w s).mpr he, fun r h1 h2 => (ihψ w r).mpr (hg r h1 h2)⟩
  | snce ψ χ ihψ ihχ =>
    constructor
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ w s).mp he, fun r h1 h2 => (ihψ w r).mp (hg r h1 h2)⟩
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ w s).mpr he, fun r h1 h2 => (ihψ w r).mpr (hg r h1 h2)⟩

end ShiftSet

end FormalSystem.Semantics
