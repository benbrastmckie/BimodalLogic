/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Extension.Extension
import Mathlib.GroupTheory.QuotientGroup.Basic
import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Algebra.Order.Floor.Ring
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Data.Nat.GCD.Basic

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
`sh_add`, `sep` — plus the valuation `A`. The live frame
(`FormalSystem/Semantics/TaskFrame.lean`) has **seven** fields, and `ShiftSet.frame` discharges
all seven. Three of them are free consequences of the task relation being *functional*
(`TaskRel w d u := u = sh w d`) together with the group action:

- `serial` — witnessed by `sh w x` and `sh w (-x)`;
- the **interpolation** half of the biconditional `comp` — witnessed, uniquely, by `sh w x`;
- `saturation` — under a functional relation every fiber and every segment is a singleton or
  empty, so a directed family of nonempty ones is a family of copies of one singleton and its
  intersection is that singleton. No frame-theoretic machinery, and no Zorn.

Only `limit` is *not* free: it fails for an arbitrary `D`-action, and this module *proves* that
it fails, in `ShiftSet.SepNotDerivable.sep_not_derivable`: `D = ℚ` acting on `ℚ ⧸ (dyadics)`
satisfies both action laws and refutes the separation condition. The failure mode is a dense
proper stabiliser. That is what the `sep` field is for — see its own docstring.

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

`D` is a `TemporalOrder` — the reified `def:temporal-order` — rather than a bare `Type` plus the
four algebra binders hand-copied. That is what lets `ShiftSet.fibre` land in `FrameOver D`
directly, with no `TemporalOrder.of` in the way, and what makes `ofModel`'s target
`ShiftSet F.Duration` typecheck on the nose.

The universe discipline the earlier binder shape recorded is preserved, not relaxed:
`TemporalOrder.carrier : Type`, so `↑D : Type`, `WorldState : Type` and `Carrier : Type` all sit
where they did. A universe-polymorphic duration here would still land the reverse direction's
carrier where the forward direction could not consume it; nothing about this change opens that
door.
-/
structure ShiftSet (D : TemporalOrder) where
  /-- The carrier `Ω` of the shift set. -/
  Carrier : Type
  /-- The carrier is nonempty (matching `FrameOver.worldNonempty`). -/
  carrier_nonempty : Nonempty Carrier
  /-- The shift action of a duration on a carrier point. -/
  sh : Carrier → ↑D → Carrier
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

variable {D : TemporalOrder}

/-- Shifting by `d` and then by `-d` returns to the start. -/
theorem sh_neg (S : ShiftSet D) (w : S.Carrier) (d : ↑D) : S.sh (S.sh w d) (-d) = w := by
  rw [S.sh_add, add_neg_cancel, S.sh_zero]

/-- Shifting by `-d` and then by `d` returns to the start. -/
theorem sh_neg' (S : ShiftSet D) (w : S.Carrier) (d : ↑D) : S.sh (S.sh w (-d)) d = w := by
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
theorem wh_ext {F : TaskFrame} {σ τ : WorldHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : F.Duration) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
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

All **seven** live `FrameOver` fields are discharged here. Three come for free from
functionality plus the group action and require no shift-set axiom of their own — `serial`, the
*interpolation* half of the biconditional `comp`, and `saturation` — correcting the design
document's list, which was written against an earlier five-field frame structure and named only the
other four. The one field that is genuinely *not* free is `limit`; it is exactly `S.sep`.
-/
@[reducible] def fibre (S : ShiftSet D) : FrameOver D where
  WorldState := S.Carrier
  worldNonempty := S.carrier_nonempty
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
  -- The task relation is *functional* (`u = sh w d`), so Helper D applies verbatim: every
  -- fibre is a subsingleton, and `Seg` is a subset of a fibre. No frame machinery, no Zorn.
  saturation := TaskFrame.saturation_of_fib_subsingleton
    (TaskFrame.fib_subsingleton_of_functional (f := S.sh) (fun _ _ _ => Iff.rfl))

/--
The task frame induced by a shift set: its fibre, included into the total space.

The inclusion is the constructor `⟨TemporalOrder.of D, S.fibre⟩`, so `S.frame.toFibre` is
`S.fibre` and `S.frame.WorldState` is `S.Carrier`, both by `rfl`. `@[reducible]` is preserved
from the pre-fibration definition and is load bearing: `hist`'s `respects_task` proof rewrites
under `S.frame.Duration`.
-/
@[reducible] def frame (S : ShiftSet D) : TaskFrame := S.fibre.toTaskFrame

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
def ShiftTruth (S : ShiftSet D) : S.Carrier → ↑D → Formula → Prop
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
theorem forward_repr (S : ShiftSet D) (w : S.Carrier) (t : ↑D) (φ : Formula) :
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

/-! ## Reverse direction: the shift set induced by a task model -/

/-- Time-shifting a history by `0` is the identity. -/
theorem ts_zero {F : TaskFrame} (σ : WorldHistory F) :
    WorldHistory.timeShift σ 0 = σ := by
  refine wh_ext (funext fun z => by simp [WorldHistory.timeShift]) ?_
  intro r h h'
  exact WorldHistory.states_eq_of_time_eq σ (r + 0) r (add_zero r) h h'

/-- Time-shifting is additive. -/
theorem ts_add {F : TaskFrame} (σ : WorldHistory F) (a b : F.Duration) :
    WorldHistory.timeShift (WorldHistory.timeShift σ a) b = WorldHistory.timeShift σ (a + b) := by
  refine wh_ext (funext fun z => ?_) ?_
  · show σ.domain ((z + b) + a) = σ.domain (z + (a + b))
    rw [add_assoc, add_comm b a]
  · intro r h h'
    exact WorldHistory.states_eq_of_time_eq σ ((r + b) + a) (r + (a + b))
      (by rw [add_assoc, add_comm b a]) h h'

/--
The separation condition, discharged on total histories **straight out of `F.limit`**.

At each time `t`, `σ.respects_task t (t + y)` turns a witnessing shift `τ = σ.timeShift y` into
`F.TaskRel (σ.states t) y (τ.states t)`, and `F.limit` then collapses the two states; `wh_ext`
lifts that to equality of histories.

**No new frame hypothesis is needed.** That is precisely why the `sep` field is the right axiom
and the stronger free-action axiom is not: freeness is not dischargeable here at all — a
constant total history is fixed by every shift.
-/
theorem rev_sep {F : TaskFrame} (σ τ : F.HF)
    (h : ∀ x : F.Duration, 0 < x → ∃ y : F.Duration, |y| < x ∧ τ = σ.timeShift y) : τ = σ := by
  apply Subtype.ext
  refine wh_ext (funext fun z => propext ⟨fun _ => σ.property z, fun _ => τ.property z⟩) ?_
  intro t ht ht'
  refine F.limit (σ.val.states t ht') (τ.val.states t ht) ?_
  intro x hx
  obtain ⟨y, hy, hEq⟩ := h x hx
  refine ⟨y, hy, ?_⟩
  subst hEq
  have h2 := σ.val.respects_task t (t + y) ht' (σ.property (t + y))
  rw [add_sub_cancel_left] at h2
  exact h2

/--
**REVERSE DIRECTION**: every task model induces a shift set.

The carrier is `F.HF`, the total histories of the frame; the action is time shift; the
separation field is `rev_sep`, and there is deliberately **no** freeness field. The valuation
reads each atom off at time `0` of the history.

`carrier_nonempty` is where `Classical.choice` enters the reverse direction, and its only
entry point: `PartialHistory.hF_nonempty` is Zorn-based.
-/
def ofModel (F : TaskFrame) (M : TaskModel F) : ShiftSet F.Duration where
  Carrier := F.HF
  carrier_nonempty := PartialHistory.hF_nonempty F F.worldNonempty.some
  sh := TaskFrame.HF.timeShift
  sh_zero := by intro w; apply Subtype.ext; exact ts_zero w.val
  sh_add := by intro w a b; apply Subtype.ext; exact ts_add w.val a b
  sep := fun w u h => rev_sep w u h
  A := fun p τ => TruthAt M τ.val 0 (Formula.atom p)

/--
**REVERSE DIRECTION of the representation theorem, with its truth correspondence.**

Shift-set truth on `ofModel F M` is truth in `M`. The `atom` case is where
`TimeShift.time_shift_preserves_truth` (`FormalSystem/Semantics/Truth.lean`, which is
*unconditional* — the shift-closure hypothesis it once carried is retired, not renamed) and
`TaskFrame.HF.timeShift_val` are consumed; every other case is a structural transport.
-/
theorem reverse_repr (F : TaskFrame) (M : TaskModel F) (τ : F.HF) (t : F.Duration)
    (φ : Formula) :
    ShiftTruth (ShiftSet.ofModel F M) τ t φ ↔ TruthAt M τ.val t φ := by
  induction φ generalizing τ t with
  | atom p =>
    show TruthAt M ((TaskFrame.HF.timeShift τ t).val) 0 (Formula.atom p) ↔ _
    rw [TaskFrame.HF.timeShift_val]
    have := TimeShift.time_shift_preserves_truth M τ.val 0 t (Formula.atom p)
    rw [sub_zero] at this
    exact this
  | bot => exact Iff.rfl
  | imp ψ χ ihψ ihχ =>
    exact ⟨fun h hψ => (ihχ τ t).mp (h ((ihψ τ t).mpr hψ)),
           fun h hψ => (ihχ τ t).mpr (h ((ihψ τ t).mp hψ))⟩
  | box ψ ih =>
    constructor
    · intro h σ hσ
      exact (ih ⟨σ, hσ⟩ t).mp (h ⟨σ, hσ⟩)
    · intro h v
      exact (ih v t).mpr (h v.val v.property)
  | untl ψ χ ihψ ihχ =>
    constructor
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ τ s).mp he, fun r h1 h2 => (ihψ τ r).mp (hg r h1 h2)⟩
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ τ s).mpr he, fun r h1 h2 => (ihψ τ r).mpr (hg r h1 h2)⟩
  | snce ψ χ ihψ ihχ =>
    constructor
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ τ s).mp he, fun r h1 h2 => (ihψ τ r).mp (hg r h1 h2)⟩
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ τ s).mpr he, fun r h1 h2 => (ihψ τ r).mpr (hg r h1 h2)⟩

/-!
## `sep` is not derivable from the action laws

The `sep` field is a genuine axiom of the shift-set notion, not a strengthening that could be
dropped and recovered. The witness below is a concrete `D`-action satisfying `sh_zero` and
`sh_add` for which the separation condition is false: `D = ℚ` acting by translation on
`ℚ ⧸ H`, where `H` is the group of dyadic rationals — a *dense proper* subgroup of `ℚ`.
Density gives the arbitrarily-small witnesses the separation hypothesis asks for; properness
(`1/3 ∉ H`) makes its conclusion false.

The `ℝ`/`ℚ` variant named in the design discussion is avoided here only because
`Mathlib.Data.Real.Irrational` is not part of this checkout's partial Mathlib build; the dyadic
variant is elementary and self-contained.
-/

namespace SepNotDerivable

/-- The dyadic rationals `{a / 2 ^ n}`, as a dense proper additive subgroup of `ℚ`. -/
def DyadicGroup : AddSubgroup ℚ where
  carrier := {q : ℚ | ∃ (a : ℤ) (n : ℕ), q = (a : ℚ) / 2 ^ n}
  zero_mem' := ⟨0, 0, by norm_num⟩
  add_mem' := by
    rintro p q ⟨a, m, rfl⟩ ⟨b, n, rfl⟩
    refine ⟨a * 2 ^ n + b * 2 ^ m, m + n, ?_⟩
    have h1 : ((2:ℚ) ^ m) ≠ 0 := by positivity
    have h2 : ((2:ℚ) ^ n) ≠ 0 := by positivity
    field_simp
    push_cast
    ring
  neg_mem' := by
    rintro p ⟨a, n, rfl⟩
    exact ⟨-a, n, by push_cast; ring⟩

/-- `1/3` is not dyadic: `2 ^ n = 3 * a` would force `3 ∣ 2 ^ n`. This is *properness*. -/
theorem third_not_dyadic : (1/3 : ℚ) ∉ DyadicGroup := by
  rintro ⟨a, n, h⟩
  have h2 : ((2:ℚ) ^ n) ≠ 0 := by positivity
  have hq : (2:ℚ) ^ n = 3 * a := by
    field_simp at h
    linarith
  have hz : (2:ℤ) ^ n = 3 * a := by exact_mod_cast hq
  have hd : (3:ℤ) ∣ 2 ^ n := ⟨a, hz⟩
  have hd' : (3:ℕ) ∣ 2 ^ n := by
    have hc : ((3:ℕ):ℤ) ∣ ((2 ^ n : ℕ) : ℤ) := by push_cast; exact hd
    exact_mod_cast hc
  have hcop : Nat.Coprime 3 (2 ^ n) := Nat.Coprime.pow_right n (by decide)
  have h3 : (3:ℕ) = 1 := Nat.Coprime.eq_one_of_dvd hcop hd'
  exact absurd h3 (by decide)

/-- The dyadics are *dense*: `1/3` has dyadic translates arbitrarily close to it. -/
theorem dyadic_approx (x : ℚ) (hx : 0 < x) :
    ∃ y : ℚ, |y| < x ∧ (1/3 : ℚ) - y ∈ DyadicGroup := by
  obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one hx (show (1/2:ℚ) < 1 by norm_num)
  have h2n : (0:ℚ) < 2 ^ n := by positivity
  set k : ℤ := ⌊(1/3 : ℚ) * 2 ^ n⌋ with hk
  set d : ℚ := (k : ℚ) / 2 ^ n with hdd
  have hfl : (k : ℚ) ≤ (1/3 : ℚ) * 2 ^ n := Int.floor_le _
  have hfl2 : (1/3 : ℚ) * 2 ^ n < (k : ℚ) + 1 := Int.lt_floor_add_one _
  have hpow : (1/2 : ℚ) ^ n = 1 / 2 ^ n := by rw [div_pow]; norm_num
  have hd0 : 0 ≤ (1/3 : ℚ) - d := by
    rw [sub_nonneg, hdd, div_le_iff₀ h2n]
    linarith
  have hd1 : (1/3 : ℚ) - d < (1/2 : ℚ) ^ n := by
    have expand : ((1:ℚ)/3 - (k:ℚ)/2^n) * 2^n = (1/3)*2^n - (k:ℚ) := by field_simp
    rw [hpow, hdd, lt_div_iff₀ h2n, expand]
    linarith
  refine ⟨(1/3 : ℚ) - d, ?_, ?_⟩
  · rw [abs_of_nonneg hd0]; exact hd1.trans hn
  · have hsimp : (1/3 : ℚ) - ((1/3 : ℚ) - d) = d := by ring
    rw [hsimp, hdd]
    exact ⟨k, n, rfl⟩

/-- Translation of `ℚ ⧸ DyadicGroup` by a rational: the action of the counterexample. -/
def qsh (w : ℚ ⧸ DyadicGroup) (d : ℚ) : ℚ ⧸ DyadicGroup := w + (QuotientAddGroup.mk d)

theorem qsh_zero (w : ℚ ⧸ DyadicGroup) : qsh w 0 = w := by simp [qsh]

theorem qsh_add (w : ℚ ⧸ DyadicGroup) (a b : ℚ) : qsh (qsh w a) b = qsh w (a + b) := by
  simp [qsh, add_assoc]

/--
**The separation condition is not derivable from the two action laws.**

This is what justifies `sep` being a field of `ShiftSet` rather than a lemma about it: there is
a `ℚ`-action satisfying `sh_zero` and `sh_add` whose separation condition is false. Without the
field, `ShiftSet.frame` could not discharge `FrameOver.limit`, so `ShiftSet` without `sep` would
not induce a task frame at all.
-/
theorem sep_not_derivable :
    ∃ (Ω : Type) (sh : Ω → ℚ → Ω),
      (∀ w, sh w 0 = w) ∧
      (∀ w a b, sh (sh w a) b = sh w (a + b)) ∧
      ¬ (∀ w u : Ω, (∀ x : ℚ, 0 < x → ∃ y : ℚ, |y| < x ∧ u = sh w y) → u = w) := by
  refine ⟨ℚ ⧸ DyadicGroup, qsh, qsh_zero, qsh_add, ?_⟩
  intro hsep
  have hmem : ((1/3 : ℚ) : ℚ ⧸ DyadicGroup) = (0 : ℚ ⧸ DyadicGroup) := by
    refine hsep 0 (QuotientAddGroup.mk (1/3 : ℚ)) ?_
    intro x hx
    obtain ⟨y, hy, hmemy⟩ := dyadic_approx x hx
    refine ⟨y, hy, ?_⟩
    show ((1/3 : ℚ) : ℚ ⧸ DyadicGroup) = 0 + (QuotientAddGroup.mk y)
    rw [zero_add]
    exact (QuotientAddGroup.eq (s := DyadicGroup)).mpr
      (by have h := AddSubgroup.neg_mem DyadicGroup hmemy
          rwa [neg_sub, sub_eq_neg_add] at h)
  exact third_not_dyadic ((QuotientAddGroup.eq_zero_iff _).mp hmem)

end SepNotDerivable

end ShiftSet

end FormalSystem.Semantics
