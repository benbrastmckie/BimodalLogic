/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.Presheaf.Determinism
import FormalSystem.Semantics.Extension.Extension

/-!
# *Total Histories*: `H_F ≅ lim Beh(F)(2x)` along the central restrictions

The *Total Histories* clause of `app:presheaf-dictionary` — the clause
`docs/reference/paper-definitions-of-record.md` records under the name *Possible Worlds* — states
that the possible worlds of a task frame are the limit of the behavior presheaf along the central
restrictions:

    H_F ≅ lim_{x ∈ D⁺} Beh(F)(2x)   along   Tr (x' − x) : 2x → 2x',   and is nonempty.

The statement was read from the recorded paper text that the sentinel commit of
`docs/reference/paper-definitions-of-record.md` pins; the live paper no longer defines the label.

The limit is presented concretely, as `sheaf_clause` presents the sheaf condition concretely: a
point of `Lim F` is a **compatible family of centred sections** `(σ_x)_{x ∈ D⁺}`,
`σ_x ∈ Beh(F)(2x)`, each restricting to the next along the central translation. The forward map
cuts a world to each centred window; the backward map reads each time `t` out of its **canonical
window** `|t|` and glues with `WorldHistory.ofTotal`. Totality is structural — the centred chain
already covers the temporal order — so no extension step is consumed.

## Main Definitions

- `twice`: the object `2x` of the site, written `x.val + x.val` because an abstract temporal order
  carries no `OfNat` literal `2`.
- `centralTr`: the central morphism `Tr (twice x) (twice x')` with shift `x' − x`.
- `Lim`: a point of the limit — a compatible family of centred sections.
- `absObj`: the canonical window index `|t|` of a time `t`.
- `Lim.readAt`, `Lim.toWorld`: the backward map and the state function it glues.
- `Lim.ofWorld`: the forward map, a world cut to each of its centred windows.

## Main Results

- `restrictTr_central`: restriction along the central morphism **is** the raw-data restriction.
- `Lim.compat_site`: the clause's compatibility in the site's own vocabulary.
- `Lim.read_eq`: the keystone — every window at least `|t|` reads the same state at `t`.
- `Lim.respects`, `Lim.toWorld_ofWorld`, `Lim.ofWorld_toWorld`: task-respect and both round trips.
- `worldsEquiv`: the clause, `WorldHistory F ≃ Lim F`, at no frame constraint.
- `lim_nonempty`: the clause's closing tail, at `[F.IsRegular]`.

## Implementation Notes

(Filled in with the measured axiom table once every declaration of the module is in place.)

## References

* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Total Histories* clause this
  module discharges. **`DANGLING`**: cut from the paper with `app:Structure` and recorded in
  `docs/reference/paper-definitions-of-record.md`
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrict`, `Beh.restrictTr`
* `FormalSystem/Semantics/Presheaf/Site.lean` — `Obj`, `Tr`
* `FormalSystem/Semantics/Presheaf/Sheaf.lean` — `states_eq_of_eq`, `restrictTr_coverLeft`
* `FormalSystem/Semantics/Presheaf/Determinism.lean` — `secOf`, `secOf_states`

## Tags

presheaf, limit, possible worlds, total histories, behavior presheaf, interval site
-/

namespace FormalSystem.Semantics.Presheaf

variable {F : TaskFrame}

/-! ## The central restriction -/

/-- The central restriction's fit condition: `Tr (x' − x)` is a morphism `2x → 2x'`. Proved by
`abel` and `add_le_add (le_refl x') h`, never by an `*_iff_*` round trip, which would measure
`Classical.choice`. -/
theorem central_fit {x x' : F.Duration} (h : x ≤ x') : x' - x + (x + x) ≤ x' + x' := by
  have e : x' - x + (x + x) = x' + x := by abel
  rw [e]; exact add_le_add (le_refl x') h

/-- The object `2x` of the site. There is no `OfNat F.Duration 2` on an abstract temporal order,
which is why `2x` is written `x.val + x.val` throughout. -/
abbrev twice (x : Obj F.Duration) : Obj F.Duration :=
  ⟨x.val + x.val, add_nonneg x.property x.property⟩

/-- The central morphism `Tr (x' − x) : 2x → 2x'` of the interval site, for `x ≤ x'`. -/
def centralTr {x x' : Obj F.Duration} (h : x.val ≤ x'.val) : Tr (twice x) (twice x') :=
  ⟨x'.val - x.val, sub_nonneg.mpr h, central_fit h⟩

/-- Restriction along the central morphism **is** the raw-data restriction by `x' − x` onto
`[0, 2x]`, definitionally — the same reading `restrictTr_coverLeft` gives the covering family. -/
theorem restrictTr_central {x x' : Obj F.Duration} (h : x.val ≤ x'.val)
    (σ : Beh F (x'.val + x'.val)) :
    Beh.restrictTr (centralTr h) σ
      = Beh.restrict (x'.val - x.val) (x.val + x.val) (sub_nonneg.mpr h)
          (add_nonneg x.property x.property) (central_fit h) σ :=
  rfl

/-! ## The limit -/

/-- A point of the limit `lim_{x ∈ D⁺} Beh(F)(2x)`: a compatible family of centred sections, one
over each window `[0, 2x]`, each restricting to the next along the central translation. The
compatibility is stated at raw data, which is what the proofs consume; the site form is
`Lim.compat_site`. -/
structure Lim (F : TaskFrame) where
  /-- The centred section over `[0, 2x]`. -/
  sec : ∀ x : Obj F.Duration, Beh F (x.val + x.val)
  /-- Compatibility along the central restriction `2x → 2x'`. -/
  compat : ∀ {x x' : Obj F.Duration} (h : x.val ≤ x'.val),
    Beh.restrict (x'.val - x.val) (x.val + x.val) (sub_nonneg.mpr h)
      (add_nonneg x.property x.property) (central_fit h) (sec x') = sec x

/-- Points of the limit are determined by their sections. Written by hand rather than by `@[ext]`,
so that no second extensionality lemma is generated under the same name. -/
theorem Lim.ext {L L' : Lim F} (h : ∀ x, L.sec x = L'.sec x) : L = L' := by
  obtain ⟨s, c⟩ := L; obtain ⟨s', c'⟩ := L'
  obtain rfl : s = s' := funext h
  rfl

/-- The clause's compatibility in the site's own vocabulary: restriction along the central
morphism `centralTr h` carries the section over `2x'` to the section over `2x`. No transport, no
cast — `restrictTr_central` and `compat` are the whole proof. -/
theorem Lim.compat_site (L : Lim F) {x x' : Obj F.Duration} (h : x.val ≤ x'.val) :
    Beh.restrictTr (centralTr h) (L.sec x') = L.sec x := by
  rw [restrictTr_central]; exact L.compat h

/-! ## Window arithmetic -/

/-- `0 ≤ s + x` when the window `x` contains `s`. Choice-free: written with an explicit
`rwa [neg_add_cancel]`, **never** `simpa`, which measures `Classical.choice` here. -/
theorem window_lo {s x : F.Duration} (h : |s| ≤ x) : 0 ≤ s + x := by
  have h1 : -x ≤ s := le_trans (neg_le_neg h) (neg_abs_le s)
  have h2 := add_le_add h1 (le_refl x)
  rwa [neg_add_cancel] at h2

/-- `s + x ≤ 2x` when the window `x` contains `s`. -/
theorem window_hi {s x : F.Duration} (h : |s| ≤ x) : s + x ≤ x + x :=
  add_le_add (le_trans (le_abs_self s) h) (le_refl x)

/-- The canonical window index of a time: the paper's own witness, `t ∈ [−|t|, |t|]`. -/
def absObj (t : F.Duration) : Obj F.Duration := ⟨|t|, abs_nonneg t⟩

/-- The canonical window index, by definition. -/
theorem absObj_val (t : F.Duration) : (absObj t).val = |t| := rfl

/-! ## The backward map: a compatible family is a possible world -/

/-- The state at `t`, read out of the canonical window `absObj t` at position `t + |t|`. -/
def Lim.readAt (L : Lim F) (t : F.Duration) : F.WorldState :=
  (L.sec (absObj t)).val.states (t + (absObj t).val)
    (Beh.mem_dom _ (window_lo (le_refl (absObj t).val)) (window_hi (le_refl (absObj t).val)))

/-- `Lim.readAt`'s defining equation. An unpinned rewriting device: `rw [Lim.readAt]` has no
equation lemma, so the definition is restated as a `rfl` and rewritten with. -/
theorem Lim.readAt_def (L : Lim F) (t : F.Duration) :
    L.readAt t = (L.sec (absObj t)).val.states (t + (absObj t).val)
      (Beh.mem_dom _ (window_lo (le_refl (absObj t).val)) (window_hi (le_refl (absObj t).val))) :=
  rfl

/-- **The keystone**: every window at least as large as `|t|` reads the same state at `t`. Every
later proof goes through this rather than through `compat` directly. The hypothesis `|t| ≤ x.val`
is definitionally `(absObj t).val ≤ x.val`, so it feeds `compat` at `(absObj t, x)` directly. -/
theorem Lim.read_eq (L : Lim F) (t : F.Duration) (x : Obj F.Duration) (hx : |t| ≤ x.val) :
    L.readAt t
      = (L.sec x).val.states (t + x.val) (Beh.mem_dom _ (window_lo hx) (window_hi hx)) := by
  have hc := L.compat (x := absObj t) (x' := x) hx
  have hzd : (Beh.restrict (x.val - (absObj t).val) ((absObj t).val + (absObj t).val)
      (sub_nonneg.mpr hx) (add_nonneg (absObj t).property (absObj t).property) (central_fit hx)
      (L.sec x)).val.domain (t + (absObj t).val) :=
    ⟨window_lo (le_refl (absObj t).val), window_hi (le_refl (absObj t).val)⟩
  have e1 := states_eq_of_eq hc (t + (absObj t).val) hzd
    (Beh.mem_dom _ (window_lo (le_refl (absObj t).val)) (window_hi (le_refl (absObj t).val)))
  have hin : (L.sec x).val.domain (x.val - (absObj t).val + (t + (absObj t).val)) := by
    have e : x.val - (absObj t).val + (t + (absObj t).val) = t + x.val := by abel
    exact Beh.mem_dom _ (by rw [e]; exact window_lo hx) (by rw [e]; exact window_hi hx)
  rw [Lim.readAt_def, ← e1,
    Beh.restrict_states (x.val - (absObj t).val) ((absObj t).val + (absObj t).val)
      (sub_nonneg.mpr hx) (add_nonneg (absObj t).property (absObj t).property) (central_fit hx)
      (L.sec x) (t + (absObj t).val) hzd hin]
  exact PartialHistory.states_eq_of_time_eq _ _ _ (by abel) _ _

/-- Task-respect for the glued state function: read both times out of the common window
`max |s| |t|` and use the section's own `respects_task`. -/
theorem Lim.respects (L : Lim F) (s t : F.Duration) :
    F.TaskRel (L.readAt s) (t - s) (L.readAt t) := by
  have hx0 : (0 : F.Duration) ≤ max |s| |t| := le_trans (abs_nonneg s) (le_max_left _ _)
  have hs : |s| ≤ (⟨max |s| |t|, hx0⟩ : Obj F.Duration).val := le_max_left _ _
  have ht : |t| ≤ (⟨max |s| |t|, hx0⟩ : Obj F.Duration).val := le_max_right _ _
  rw [L.read_eq s ⟨max |s| |t|, hx0⟩ hs, L.read_eq t ⟨max |s| |t|, hx0⟩ ht]
  have h := (L.sec ⟨max |s| |t|, hx0⟩).val.respects_task
    (s + max |s| |t|) (t + max |s| |t|) (Beh.mem_dom _ (window_lo hs) (window_hi hs))
    (Beh.mem_dom _ (window_lo ht) (window_hi ht))
  rwa [show (t + max |s| |t|) - (s + max |s| |t|) = t - s from by abel] at h

/-- **Backward map**: a compatible family **is** a possible world. Totality is structural — the
canonical window covers every time, so no extension step and no `thm:extension` is consumed. -/
def Lim.toWorld (L : Lim F) : WorldHistory F :=
  WorldHistory.ofTotal F L.readAt L.respects

/-! ## The forward map: a possible world, cut to its centred windows -/

/-- **Forward map**: a possible world, cut to each of its centred windows `[−x, x]` through
`secOf`. Noncomputable because `secOf` is. -/
noncomputable def Lim.ofWorld (w : WorldHistory F) : Lim F where
  sec x := secOf w (-x.val) (x.val + x.val) (add_nonneg x.property x.property)
  compat {x x'} h := by
    refine Beh.ext (partialHistory_ext rfl ?_)
    intro r hr hr'
    have hin : (secOf w (-x'.val) (x'.val + x'.val)
        (add_nonneg x'.property x'.property)).val.domain (x'.val - x.val + r) :=
      Beh.mem_dom _ (add_nonneg (sub_nonneg.mpr h) hr.1)
        (le_trans (add_le_add (le_refl _) hr.2) (central_fit h))
    rw [Beh.restrict_states (x'.val - x.val) (x.val + x.val) (sub_nonneg.mpr h)
      (add_nonneg x.property x.property) (central_fit h) _ r hr hin,
      secOf_states w (-x'.val) (x'.val + x'.val) (add_nonneg x'.property x'.property) hin,
      secOf_states w (-x.val) (x.val + x.val) (add_nonneg x.property x.property) hr']
    exact w.state_congr (by abel)

/-! ## The round trips and the clause -/

/-- Round trip one: gluing a world's own centred family returns the world. -/
theorem Lim.toWorld_ofWorld (w : WorldHistory F) : (Lim.ofWorld w).toWorld = w := by
  refine WorldHistory.ext_state ?_
  intro t
  have hL : (Lim.ofWorld w).readAt t
      = (secOf w (-(absObj t).val) ((absObj t).val + (absObj t).val)
            (add_nonneg (absObj t).property (absObj t).property)).val.states
          (t + (absObj t).val)
          (Beh.mem_dom _ (window_lo (le_refl (absObj t).val))
            (window_hi (le_refl (absObj t).val))) := rfl
  change (Lim.ofWorld w).readAt t = w.state t
  rw [hL, secOf_states w (-(absObj t).val) ((absObj t).val + (absObj t).val)
    (add_nonneg (absObj t).property (absObj t).property)
    (Beh.mem_dom _ (window_lo (le_refl (absObj t).val)) (window_hi (le_refl (absObj t).val)))]
  exact w.state_congr (by abel)

/-- A point of `[0, 2x]`, recentred, lies within `|·| ≤ x`. Choice-free: written with explicit
`rwa [zero_sub]` / `rwa [add_sub_cancel_right]`, **never** `simpa`, which measures
`Classical.choice` here. -/
theorem abs_sub_le_of_mem (r x : F.Duration) (h0 : 0 ≤ r) (h1 : r ≤ x + x) : |r - x| ≤ x := by
  refine abs_le.mpr ⟨?_, ?_⟩
  · have h2 : (0 : F.Duration) - x ≤ r - x := sub_le_sub_right h0 x
    rwa [zero_sub] at h2
  · have h2 : r - x ≤ x + x - x := sub_le_sub_right h1 x
    rwa [add_sub_cancel_right] at h2

/-- Round trip two, componentwise: cutting the glued world back to the window `2x` returns the
family's own section there. Note `states_eq_of_eq hL`, not `rw [hL]`: rewriting a section
equality under a dependent `states` witness fails with "motive is not type correct". -/
theorem Lim.ofWorld_toWorld_sec (L : Lim F) (x : Obj F.Duration) :
    (Lim.ofWorld L.toWorld).sec x = L.sec x := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ x.val + x.val) = (L.sec x).val.domain z
    exact propext ((L.sec x).property z).symm
  · intro r hr hr'
    have hd : (0 : F.Duration) ≤ r ∧ r ≤ x.val + x.val :=
      (((Lim.ofWorld L.toWorld).sec x).property r).mp hr
    have hb : |r + -x.val| ≤ x.val := by
      rw [show r + -x.val = r - x.val from by abel]
      exact abs_sub_le_of_mem r x.val hd.1 hd.2
    have hsec : (secOf L.toWorld (-x.val) (x.val + x.val)
        (add_nonneg x.property x.property)).val.domain r := ⟨hd.1, hd.2⟩
    have hL : (Lim.ofWorld L.toWorld).sec x
        = secOf L.toWorld (-x.val) (x.val + x.val) (add_nonneg x.property x.property) := rfl
    rw [states_eq_of_eq hL r hr hsec,
      secOf_states L.toWorld (-x.val) (x.val + x.val) (add_nonneg x.property x.property) hsec]
    change L.readAt (r + -x.val) = _
    rw [L.read_eq (r + -x.val) x hb]
    exact PartialHistory.states_eq_of_time_eq _ _ _ (by abel) _ _

/-- Round trip two: cutting the glued world back to its centred family returns the family. -/
theorem Lim.ofWorld_toWorld (L : Lim F) : Lim.ofWorld L.toWorld = L :=
  Lim.ext (Lim.ofWorld_toWorld_sec L)

/-- **The *Total Histories* clause**: `H_F ≅ lim_{x ∈ D⁺} Beh(F)(2x)` along the central
restrictions — a possible world **is** a compatible family of centred sections. At **no** frame
constraint: only the nonemptiness tail `lim_nonempty` below reaches `[F.IsRegular]`, and
bundling the binder here would claim strictly less than the recorded clause. Measured
choice-free, `[propext, Quot.sound]`. -/
noncomputable def worldsEquiv (F : TaskFrame) : WorldHistory F ≃ Lim F where
  toFun := Lim.ofWorld
  invFun := Lim.toWorld
  left_inv := Lim.toWorld_ofWorld
  right_inv := Lim.ofWorld_toWorld

/--
The clause's closing tail: the limit is nonempty. This is the one declaration of the module that
reaches `Classical.choice`, and it is attributable — `cor:occurrence` through Zorn's lemma, via
`PartialHistory.hF_nonempty`, which is where the paper puts it too.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem lim_nonempty (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : Nonempty (Lim F) :=
  (PartialHistory.hF_nonempty F w).elim fun τ => ⟨Lim.ofWorld τ⟩

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
