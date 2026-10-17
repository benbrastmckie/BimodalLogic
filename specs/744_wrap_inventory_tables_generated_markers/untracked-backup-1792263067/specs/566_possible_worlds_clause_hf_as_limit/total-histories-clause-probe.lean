/-
Research probe for the *Total Histories* clause of `app:presheaf-dictionary`:

    H_F ≅ lim_{x ∈ D⁺} Beh(F)(2x)   along the central restrictions Tr (x' − x) : 2x → 2x'

VERIFIED 2026-10-13 against the live tree via `lean_run_code`: elaborates green, no `sorry`,
no vacuous definition. Measured axiom profile, by `#print axioms`:

  read_eq, respects, toWorld, ofWorld, toWorld_ofWorld,
  abs_le_of_mem, ofWorld_toWorld_sec, ofWorld_toWorld, worldsEquiv   [propext, Quot.sound]
  lim_nonempty                                   [propext, Classical.choice, Quot.sound]

So the ISOMORPHISM IS CHOICE-FREE and only the clause's closing "and is nonempty" tail reaches
Zorn, through `PartialHistory.hF_nonempty`. Two things earn that and would lose it if rewritten:
`lo'` and `abs_le_of_mem` use explicit `rwa [neg_add_cancel]` / `rwa [zero_sub]` /
`rwa [add_sub_cancel_right]` rather than `simpa`, which pulls `Classical.choice`; and the
backward map reads each time out of the CANONICAL window `|t|` rather than through
`Presheaf.directedSup`, which is independently non-constructive.

This file is a research artifact, not library code: it is not in any Lake root closure and is
not expected to be built by `lake build`. The implementation round should transcribe it into
`FormalSystem/Semantics/Presheaf/Worlds.lean` with docstrings, the `Constraints consumed:`
markers, the `## References` block, and the closing `assert_not_exists` lock.
-/
import FormalSystem.Semantics.Presheaf.Determinism
import FormalSystem.Semantics.Presheaf.Directed

open FormalSystem.Semantics FormalSystem.Semantics.Presheaf

namespace Probe566

variable {F : TaskFrame}

/-- The central restriction's fit condition: `Tr (x' − x)` is a morphism `2x → 2x'`. -/
theorem fit {x x' : F.Duration} (h : x ≤ x') : x' - x + (x + x) ≤ x' + x' := by
  have e : x' - x + (x + x) = x' + x := by abel
  rw [e]; exact add_le_add (le_refl x') h

/-- A point of the limit: a compatible family of centred sections. -/
structure Lim (F : TaskFrame) where
  sec : ∀ x : Obj F.Duration, Beh F (x.val + x.val)
  compat : ∀ {x x' : Obj F.Duration} (h : x.val ≤ x'.val),
    Beh.restrict (x'.val - x.val) (x.val + x.val) (sub_nonneg.mpr h)
      (add_nonneg x.property x.property) (fit h) (sec x') = sec x

theorem Lim.ext' {L L' : Lim F} (h : ∀ x, L.sec x = L'.sec x) : L = L' := by
  obtain ⟨s, c⟩ := L; obtain ⟨s', c'⟩ := L'
  obtain rfl : s = s' := funext h
  rfl

/-- `0 ≤ t + x` when the window `x` contains `t`. Choice-free: do NOT write this with `simpa`. -/
theorem lo' {s x : F.Duration} (h : |s| ≤ x) : 0 ≤ s + x := by
  have h1 : -x ≤ s := le_trans (neg_le_neg h) (neg_abs_le s)
  have h2 := add_le_add h1 (le_refl x)
  rwa [neg_add_cancel] at h2

/-- `t + x ≤ 2x` when the window `x` contains `t`. -/
theorem hi' {s x : F.Duration} (h : |s| ≤ x) : s + x ≤ x + x :=
  add_le_add (le_trans (le_abs_self s) h) (le_refl x)

/-- The canonical window index of a time: the paper's own witness, `t ∈ [−|t|, |t|]`. -/
def absObj (t : F.Duration) : Obj F.Duration := ⟨|t|, abs_nonneg t⟩

/-- The state at `t`, read out of the canonical window. -/
def readAt (L : Lim F) (t : F.Duration) : F.WorldState :=
  (L.sec (absObj t)).val.states (t + (absObj t).val)
    (Beh.mem_dom _ (lo' (le_refl (absObj t).val)) (hi' (le_refl (absObj t).val)))

/-- `readAt`'s defining equation. Needed because `rw [readAt]` has no equation lemma. -/
theorem readAt_def (L : Lim F) (t : F.Duration) :
    readAt L t = (L.sec (absObj t)).val.states (t + (absObj t).val)
      (Beh.mem_dom _ (lo' (le_refl (absObj t).val)) (hi' (le_refl (absObj t).val))) := rfl

/-- **The keystone**: every window at least as large as `|t|` reads the same state at `t`. Every
later proof goes through this rather than through `compat` directly. -/
theorem read_eq (L : Lim F) (t : F.Duration) (x : Obj F.Duration)
    (hx : (absObj t).val ≤ x.val) :
    readAt L t = (L.sec x).val.states (t + x.val) (Beh.mem_dom _ (lo' hx) (hi' hx)) := by
  have hc := L.compat (x := absObj t) (x' := x) hx
  have hzd : (Beh.restrict (x.val - (absObj t).val) ((absObj t).val + (absObj t).val)
      (sub_nonneg.mpr hx) (add_nonneg (absObj t).property (absObj t).property) (fit hx)
      (L.sec x)).val.domain (t + (absObj t).val) :=
    ⟨lo' (le_refl (absObj t).val), hi' (le_refl (absObj t).val)⟩
  have e1 := states_eq_of_eq hc (t + (absObj t).val) hzd
    (Beh.mem_dom _ (lo' (le_refl (absObj t).val)) (hi' (le_refl (absObj t).val)))
  have hin : (L.sec x).val.domain (x.val - (absObj t).val + (t + (absObj t).val)) := by
    have e : x.val - (absObj t).val + (t + (absObj t).val) = t + x.val := by abel
    exact Beh.mem_dom _ (by rw [e]; exact lo' hx) (by rw [e]; exact hi' hx)
  rw [readAt_def, ← e1,
    Beh.restrict_states (x.val - (absObj t).val) ((absObj t).val + (absObj t).val)
      (sub_nonneg.mpr hx) (add_nonneg (absObj t).property (absObj t).property) (fit hx)
      (L.sec x) (t + (absObj t).val) hzd hin]
  exact PartialHistory.states_eq_of_time_eq _ _ _ (by abel) _ _

/-- Task-respect for the glued state function: read both times out of the common window
`max |s| |t|`. -/
theorem respects (L : Lim F) (s t : F.Duration) :
    F.TaskRel (readAt L s) (t - s) (readAt L t) := by
  have hx0 : (0 : F.Duration) ≤ max |s| |t| := le_trans (abs_nonneg s) (le_max_left _ _)
  have hs : (absObj s).val ≤ (⟨max |s| |t|, hx0⟩ : Obj F.Duration).val := le_max_left _ _
  have ht : (absObj t).val ≤ (⟨max |s| |t|, hx0⟩ : Obj F.Duration).val := le_max_right _ _
  rw [read_eq L s ⟨max |s| |t|, hx0⟩ hs, read_eq L t ⟨max |s| |t|, hx0⟩ ht]
  have h := (L.sec ⟨max |s| |t|, hx0⟩).val.respects_task
    (s + max |s| |t|) (t + max |s| |t|) (Beh.mem_dom _ (lo' hs) (hi' hs))
    (Beh.mem_dom _ (lo' ht) (hi' ht))
  rwa [show (t + max |s| |t|) - (s + max |s| |t|) = t - s from by abel] at h

/-- **Backward map**: a compatible family IS a possible world. Totality is structural — the
canonical window covers every time, so no extension step and no `thm:extension` is needed. -/
def toWorld (L : Lim F) : WorldHistory F :=
  WorldHistory.ofTotal F (readAt L) (respects L)

/-- **Forward map**: a possible world, cut to each of its centred windows. -/
noncomputable def ofWorld (w : WorldHistory F) : Lim F where
  sec x := secOf w (-x.val) (x.val + x.val) (add_nonneg x.property x.property)
  compat {x x'} h := by
    refine Beh.ext (partialHistory_ext rfl ?_)
    intro r hr hr'
    have hin : (secOf w (-x'.val) (x'.val + x'.val)
        (add_nonneg x'.property x'.property)).val.domain (x'.val - x.val + r) :=
      Beh.mem_dom _ (add_nonneg (sub_nonneg.mpr h) hr.1)
        (le_trans (add_le_add (le_refl _) hr.2) (fit h))
    rw [Beh.restrict_states (x'.val - x.val) (x.val + x.val) (sub_nonneg.mpr h)
      (add_nonneg x.property x.property) (fit h) _ r hr hin,
      secOf_states w (-x'.val) (x'.val + x'.val) (add_nonneg x'.property x'.property) hin,
      secOf_states w (-x.val) (x.val + x.val) (add_nonneg x.property x.property) hr']
    exact w.state_congr (by abel)

/-- Round trip one: gluing a world's own centred family returns the world. -/
theorem toWorld_ofWorld (w : WorldHistory F) : toWorld (ofWorld w) = w := by
  refine WorldHistory.ext_state ?_
  intro t
  have hL : readAt (ofWorld w) t
      = (secOf w (-(absObj t).val) ((absObj t).val + (absObj t).val)
            (add_nonneg (absObj t).property (absObj t).property)).val.states
          (t + (absObj t).val)
          (Beh.mem_dom _ (lo' (le_refl (absObj t).val)) (hi' (le_refl (absObj t).val))) := rfl
  change readAt (ofWorld w) t = w.state t
  rw [hL, secOf_states w (-(absObj t).val) ((absObj t).val + (absObj t).val)
    (add_nonneg (absObj t).property (absObj t).property)
    (Beh.mem_dom _ (lo' (le_refl (absObj t).val)) (hi' (le_refl (absObj t).val)))]
  exact w.state_congr (by abel)

/-- A point of `[0, 2x]`, recentred, lies within `|·| ≤ x`. Choice-free: do NOT use `simpa`. -/
theorem abs_le_of_mem (r x : F.Duration) (h0 : 0 ≤ r) (h1 : r ≤ x + x) : |r - x| ≤ x := by
  refine abs_le.mpr ⟨?_, ?_⟩
  · have h2 : (0 : F.Duration) - x ≤ r - x := sub_le_sub_right h0 x
    rwa [zero_sub] at h2
  · have h2 : r - x ≤ x + x - x := sub_le_sub_right h1 x
    rwa [add_sub_cancel_right] at h2

/-- Round trip two, componentwise. Note `states_eq_of_eq hL`, not `rw [hL]`: rewriting a section
equality under a dependent `states` witness fails with "motive is not type correct". -/
theorem ofWorld_toWorld_sec (L : Lim F) (x : Obj F.Duration) :
    (ofWorld (toWorld L)).sec x = L.sec x := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ x.val + x.val) = (L.sec x).val.domain z
    exact propext ((L.sec x).property z).symm
  · intro r hr hr'
    have hd : (0 : F.Duration) ≤ r ∧ r ≤ x.val + x.val :=
      (((ofWorld (toWorld L)).sec x).property r).mp hr
    have hb : (absObj (r + -x.val)).val ≤ x.val := by
      rw [show (absObj (r + -x.val)).val = |r - x.val| from by
            change |r + -x.val| = |r - x.val|; rw [show r + -x.val = r - x.val from by abel]]
      exact abs_le_of_mem r x.val hd.1 hd.2
    have hsec : (secOf (toWorld L) (-x.val) (x.val + x.val)
        (add_nonneg x.property x.property)).val.domain r := ⟨hd.1, hd.2⟩
    have hL : (ofWorld (toWorld L)).sec x
        = secOf (toWorld L) (-x.val) (x.val + x.val)
            (add_nonneg x.property x.property) := rfl
    rw [states_eq_of_eq hL r hr hsec,
      secOf_states (toWorld L) (-x.val) (x.val + x.val)
        (add_nonneg x.property x.property) hsec]
    change readAt L (r + -x.val) = _
    rw [read_eq L (r + -x.val) x hb]
    exact PartialHistory.states_eq_of_time_eq _ _ _ (by abel) _ _

theorem ofWorld_toWorld (L : Lim F) : ofWorld (toWorld L) = L :=
  Lim.ext' (ofWorld_toWorld_sec L)

/-- **The *Total Histories* clause**: `H_F ≅ lim Beh(F)(2x)` along the central restrictions.
At NO frame constraint. Do not bundle `[F.IsRegular]` onto this: only the nonemptiness tail
below needs it. -/
noncomputable def worldsEquiv (F : TaskFrame) : WorldHistory F ≃ Lim F where
  toFun := ofWorld
  invFun := toWorld
  left_inv := toWorld_ofWorld
  right_inv := ofWorld_toWorld

/-- The clause's closing tail: the limit is nonempty. This is the one declaration that reaches
`Classical.choice`, and it is attributable — `cor:occurrence` through Zorn, which is where the
paper puts it too. -/
theorem lim_nonempty (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : Nonempty (Lim F) :=
  (PartialHistory.hF_nonempty F w).elim fun τ => ⟨ofWorld τ⟩

end Probe566
