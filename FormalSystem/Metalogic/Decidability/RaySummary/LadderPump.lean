/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

/-!
# The type-preserving pump layer: index-map surgery on ladder paths and their types

## Contract

This module is CERTIFICATE-FREE under the same grep as `LadderAgree.lean`: it mentions no
certificate object at all — not the certificate conditions, not the maximum certified subset,
not the closure-component type of the certificate layer, not the consistency bundle, not the
idle-extended coherence relation, and not the periodicity fixpoint's threshold or period — and
it imports `LadderAgree` alone. It holds ONE argument: what
happens to a ladder path, and to the closure types realized along it, under the two index-map
surgeries — duplicating a block of positions (the splice of `LadderAgree.lean`, read through its
retraction `spliceIdx`) and deleting one (the mirror, read through the monotone embedding
`delIdx`). The admissibility half of each surgery says the surgered walk lifts to a ladder path;
the type half says a block whose two ends carry the same object state and the same realized type
can be duplicated or deleted without changing the realized type at ANY position, read through
the index map. The type half is HWZ 2000 Lemma 17 (deletion) and its duplication mirror, over
`ℤ` and for the stab-free fragment of the closure.

## The two windows of the register

The next-deadline register is read by the cell in BOTH directions. Backward,
`cntAt_le_nxtAt_succ_of_idle_past` (`LadderAgree.lean`): a pending position with an idle
position in its past has countdown at most its register plus one. Forward,
`nxtAt_le_cntAt_add_of_next_region` (below): the register at a position is at most the countdown
there plus the length of the next idle run plus the countdown at the start of the next region.
The forward window is what the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` reads to refute
the depth-`0` cell obligation at a gap clip bounded by the backward exactness depth alone, and
what `(K4)`'s forward conjunct (`CounterQuotient.lean`, `dFwd`) must dominate.

## What this module does NOT hold

No cell-level agreement, no `ParamsOk`-level assembly (that is `LadderChain.lean`'s, which is
NOT certificate-free by design), no bisimulation or truth-congruence framework beyond the two
index-map transports the pump consumes, and no `⊡`-letter transport: every type statement here
carries the stab-free hypothesis, as `tpOf_stabFree_eq_of_objAt_eq` does.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The deletion index map

`delIdx a l` sends the positions of the DELETED walk to the positions of the original: a position
before the block is itself, a position at or after the block's start is the original's `l`
positions later. It is strictly monotone, its image is `ℤ \ [a, a + l)`, and it is a section of
the splice retraction `spliceIdx a l`. It coincides with the landed order embedding `spliceEmb`
of the splice, which is the mechanical form of the duality between the two surgeries. -/

section DelIdx

/-- The deletion index map: the original position a deleted-walk position reads. -/
def delIdx (a : ℤ) (l : ℕ) (v : ℤ) : ℤ := if v < a then v else v + (l : ℤ)

theorem delIdx_of_lt (a : ℤ) (l : ℕ) (v : ℤ) (h : v < a) : delIdx a l v = v := by
  simp only [delIdx, if_pos h]

theorem delIdx_of_ge (a : ℤ) (l : ℕ) (v : ℤ) (h : a ≤ v) : delIdx a l v = v + (l : ℤ) := by
  simp only [delIdx, if_neg (by omega : ¬ v < a)]

/-- The deletion map IS the splice's order embedding. -/
theorem delIdx_eq_spliceEmb (a : ℤ) (l : ℕ) (v : ℤ) : delIdx a l v = spliceEmb a l v := rfl

theorem delIdx_strictMono (a : ℤ) (l : ℕ) : StrictMono (delIdx a l) := by
  intro u v huv
  simp only [delIdx]
  split <;> split <;> omega

theorem delIdx_mono (a : ℤ) (l : ℕ) : Monotone (delIdx a l) := (delIdx_strictMono a l).monotone

theorem delIdx_lt_iff (a : ℤ) (l : ℕ) (u v : ℤ) : delIdx a l u < delIdx a l v ↔ u < v :=
  (delIdx_strictMono a l).lt_iff_lt

/-- The retraction retracts the deletion map. -/
theorem spliceIdx_delIdx (a : ℤ) (l : ℕ) (v : ℤ) : spliceIdx a l (delIdx a l v) = v :=
  spliceIdx_spliceEmb a l v

/-- The deletion map inverts the retraction OFF the deleted block. -/
theorem delIdx_spliceIdx (a : ℤ) (l : ℕ) (w : ℤ) (h : w < a ∨ a + (l : ℤ) ≤ w) :
    delIdx a l (spliceIdx a l w) = w := by
  simp only [delIdx, spliceIdx]
  split_ifs <;> omega

/-- The image of the deletion map misses the block. -/
theorem delIdx_not_mem_block (a : ℤ) (l : ℕ) (v : ℤ) :
    delIdx a l v < a ∨ a + (l : ℤ) ≤ delIdx a l v := by
  simp only [delIdx]
  split <;> omega

end DelIdx

/-! ## The deletion admissibility layer

The mirror of the splice layer of `LadderAgree.lean`: the deleted walk and the countdown it
forces, the three local readings of `Count`, and the lift to a ladder path in the pending-forever
regime. Deleting the block `[a, a + l)` of a region SHORTENS that region by `l`, so every
position at or before `a` whose region reaches `a` has its countdown lowered by `l`; positions
after the block read the original `l` positions later. -/

section Path

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

section Del

variable (g : ℤ → LadderState Q pend) (a : ℤ) (l : ℕ)

/-- The deleted walk: the original read along `delIdx`. -/
def delObj : ℤ → Q := fun v => objAt g (delIdx a l v)

/-- The countdown the deleted walk forces: lowered by `l` at the positions before the block whose
region reaches the block, unchanged at the other positions before it, and the original's `l`
positions later from the block's start on. -/
def delCnt : ℤ → ℕ := fun v =>
  if v < a then (if a ≤ v + (cntAt g v : ℤ) then cntAt g v - l else cntAt g v)
  else cntAt g (v + (l : ℤ))

variable {g a l}

theorem delObj_of_lt (v : ℤ) (h : v < a) : delObj g a l v = objAt g v := by
  simp only [delObj, delIdx_of_lt a l v h]

theorem delObj_of_ge (v : ℤ) (h : a ≤ v) : delObj g a l v = objAt g (v + (l : ℤ)) := by
  simp only [delObj, delIdx_of_ge a l v h]

theorem delCnt_of_lt (v : ℤ) (h : v < a) :
    delCnt g a l v = (if a ≤ v + (cntAt g v : ℤ) then cntAt g v - l else cntAt g v) := by
  simp only [delCnt, if_pos h]

theorem delCnt_of_ge (v : ℤ) (h : a ≤ v) : delCnt g a l v = cntAt g (v + (l : ℤ)) := by
  simp only [delCnt, if_neg (by omega : ¬ v < a)]

/-- The block's start is pending whenever the block is non-empty and inside its region. -/
theorem pend_of_del (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a) :
    pend (objAt g a) = true := by
  by_contra h
  rw [Bool.not_eq_true] at h
  have := cntAt_eq_zero_of_idle g hg a h
  omega

/-- Inside the block the original walk is pending and its countdown is the distance to the
region's end; the block `[a, a + l]` lies inside `a`'s region because `l ≤ cntAt g a`. -/
theorem delSeg (hg : IsLadderPath step pend g) (hpa : pend (objAt g a) = true)
    (hcl : l ≤ cntAt g a) (v : ℤ) (h1 : a ≤ v) (h2 : v ≤ a + (l : ℤ)) :
    pend (objAt g v) = true ∧ (cntAt g v : ℤ) + (v - a) = (cntAt g a : ℤ) := by
  obtain ⟨hp, hc⟩ := cntAt_sub_of_pend g hg a hpa (v - a).toNat (by omega)
  rw [show a + (((v - a).toNat : ℕ) : ℤ) = v by omega] at hp hc
  exact ⟨hp, by omega⟩

/-- A position before the block whose region reaches the block carries a countdown of at least
the block's length plus its distance to the block. -/
theorem cntAt_ge_of_reaches (hg : IsLadderPath step pend g)
    (v : ℤ) (hv : v ≤ a) (hpv : pend (objAt g v) = true) (hreg : a ≤ v + (cntAt g v : ℤ)) :
    (cntAt g v : ℤ) = (cntAt g a : ℤ) + (a - v) := by
  obtain ⟨-, hc⟩ := cntAt_sub_of_pend g hg v hpv (a - v).toNat (by omega)
  rw [show v + (((a - v).toNat : ℕ) : ℤ) = a by omega] at hc
  omega

/-- **The deleted walk steps along `step`.** The only new step is the one INTO the block's start,
where the original's `a - 1` steps to `a`, which is `objAt g (a + l)` by the repetition
hypothesis — exactly what the deleted walk carries at `a`. -/
theorem delObj_step (hg : IsLadderPath step pend g)
    (hrep : objAt g a = objAt g (a + (l : ℤ))) (v : ℤ) :
    step (delObj g a l v) (delObj g a l (v + 1)) = true := by
  rcases lt_trichotomy (v + 1) a with hv | hv | hv
  · rw [delObj_of_lt v (by omega), delObj_of_lt (v + 1) hv]
    exact objAt_step g hg v
  · rw [delObj_of_lt v (by omega), delObj_of_ge (v + 1) (by omega), hv, ← hrep, ← hv]
    exact objAt_step g hg v
  · rw [delObj_of_ge v (by omega), delObj_of_ge (v + 1) (by omega),
      show v + 1 + (l : ℤ) = v + (l : ℤ) + 1 by ring]
    exact objAt_step g hg (v + (l : ℤ))

/-- **The deleted countdown is idle-zero**: the first local reading of `Count`. -/
theorem delCnt_idle (hg : IsLadderPath step pend g)
    (v : ℤ) (h : pend (delObj g a l v) = false) : delCnt g a l v = 0 := by
  rcases lt_or_ge v a with hv | hv
  · rw [delObj_of_lt v hv] at h
    have hz : cntAt g v = 0 := cntAt_eq_zero_of_idle g hg v h
    rw [delCnt_of_lt v hv, if_neg (by omega : ¬ a ≤ v + (cntAt g v : ℤ)), hz]
  · rw [delObj_of_ge v hv] at h
    rw [delCnt_of_ge v hv]
    exact cntAt_eq_zero_of_idle g hg _ h

/-- **The deleted countdown counts down inside a region**: the second local reading of `Count`.
The one new transition is at `a - 1 → a`, where the countdown continues from `cntAt g a + 1 - l`
to `cntAt g (a + l) = cntAt g a - l`. -/
theorem delCnt_pend_pend (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (v : ℤ) (hx : pend (delObj g a l v) = true) (hy : pend (delObj g a l (v + 1)) = true) :
    delCnt g a l (v + 1) + 1 = delCnt g a l v := by
  have hpa : pend (objAt g a) = true := pend_of_del hg hl hcl
  rcases lt_trichotomy (v + 1) a with hv | hv | hv
  · rw [delObj_of_lt v (by omega)] at hx
    rw [delObj_of_lt (v + 1) hv] at hy
    have hstep := cntAt_succ_of_pend_pend g hg v hx hy
    rw [delCnt_of_lt v (by omega), delCnt_of_lt (v + 1) hv]
    by_cases hc : a ≤ v + (cntAt g v : ℤ)
    · rw [if_pos hc, if_pos (by omega : a ≤ v + 1 + (cntAt g (v + 1) : ℤ))]
      have := cntAt_ge_of_reaches hg v (by omega) hx hc
      omega
    · rw [if_neg hc, if_neg (by omega : ¬ a ≤ v + 1 + (cntAt g (v + 1) : ℤ))]
      omega
  · have hva : v = a - 1 := by omega
    rw [delObj_of_lt v (by omega)] at hx
    have hstep := cntAt_succ_of_pend_pend g hg v hx (by rw [hv]; exact hpa)
    have hseg := delSeg hg hpa hcl (a + (l : ℤ)) (by omega) le_rfl
    rw [delCnt_of_lt v (by omega), delCnt_of_ge (v + 1) (by omega), hv,
      if_pos (by rw [hv] at hstep; omega : a ≤ v + (cntAt g v : ℤ))]
    rw [hv] at hstep
    omega
  · rw [delObj_of_ge v (by omega)] at hx
    rw [delObj_of_ge (v + 1) (by omega), show v + 1 + (l : ℤ) = v + (l : ℤ) + 1 by ring] at hy
    have hstep := cntAt_succ_of_pend_pend g hg (v + (l : ℤ)) hx hy
    rw [delCnt_of_ge v (by omega), delCnt_of_ge (v + 1) (by omega),
      show v + 1 + (l : ℤ) = v + (l : ℤ) + 1 by ring]
    exact hstep

/-- **The deleted countdown is exhausted at a region end**: the third local reading of `Count`.
The transition into the block's start is never a region end, because the block's end is
pending. -/
theorem delCnt_pend_idle (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (v : ℤ) (hx : pend (delObj g a l v) = true)
    (hy : pend (delObj g a l (v + 1)) = false) : delCnt g a l v = 0 := by
  have hpa : pend (objAt g a) = true := pend_of_del hg hl hcl
  rcases lt_trichotomy (v + 1) a with hv | hv | hv
  · rw [delObj_of_lt v (by omega)] at hx
    rw [delObj_of_lt (v + 1) hv] at hy
    have hz : cntAt g v = 0 := (cntAt_eq_zero_of_pend_idle g hg v hx hy).1
    rw [delCnt_of_lt v (by omega), if_neg (by omega : ¬ a ≤ v + (cntAt g v : ℤ)), hz]
  · exfalso
    rw [delObj_of_ge (v + 1) (by omega), hv] at hy
    exact Bool.false_ne_true (hy.symm.trans (delSeg hg hpa hcl (a + (l : ℤ)) (by omega) le_rfl).1)
  · rw [delObj_of_ge v (by omega)] at hx
    rw [delObj_of_ge (v + 1) (by omega), show v + 1 + (l : ℤ) = v + (l : ℤ) + 1 by ring] at hy
    rw [delCnt_of_ge v (by omega)]
    exact (cntAt_eq_zero_of_pend_idle g hg (v + (l : ℤ)) hx hy).1

/-- **THE PAYOFF OF THE DELETION.** At a position at or before the block whose region reaches the
block, the deleted countdown is the original's MINUS `l`, exactly: the mirror of
`spliceCnt_add_of_mem_region`. -/
theorem delCnt_sub_of_mem_region (hg : IsLadderPath step pend g) (hl : 0 < l)
    (hcl : l ≤ cntAt g a) (v : ℤ) (hv : v ≤ a) (hreg : a ≤ v + (cntAt g v : ℤ)) :
    delCnt g a l v = cntAt g v - l := by
  rcases lt_or_eq_of_le hv with hlt | rfl
  · rw [delCnt_of_lt v hlt, if_pos hreg]
  · rw [delCnt_of_ge v le_rfl]
    have hpa : pend (objAt g v) = true := pend_of_del hg hl hcl
    have := (delSeg hg hpa hcl (v + (l : ℤ)) (by omega) le_rfl).2
    omega

/-- **The object of the deletion is unmoved before the block**, so a position before `a` keeps
its object state while its countdown moves. -/
theorem delObj_eq_of_lt (v : ℤ) (hv : v < a) : delObj g a l v = objAt g v :=
  delObj_of_lt v hv

/-- **The object at the block's start is unmoved too**, by the repetition hypothesis. -/
theorem delObj_eq_of_le (hrep : objAt g a = objAt g (a + (l : ℤ))) (v : ℤ) (hv : v ≤ a) :
    delObj g a l v = objAt g v := by
  rcases lt_or_eq_of_le hv with hlt | rfl
  · exact delObj_of_lt v hlt
  · rw [delObj_of_ge v le_rfl, hrep]

/-- In the pending-forever regime every position of the deleted walk at or before the block's
start is pending. -/
theorem delObj_pend_of_le_of_pend_past (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (hpast : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true)
    (s : ℤ) (hs : s ≤ a) : pend (delObj g a l s) = true := by
  rw [delObj_eq_of_le hrep s hs]
  exact hpast s hs

/-- **THE ADMISSIBILITY HALF OF THE DELETION, UNCONDITIONAL IN THE PENDING-FOREVER REGIME.** No
pin side condition: the deleted walk's region starts are exactly the original's, displaced by
`-l`, so `pinCompat_of_ladderPath` on the original discharges both pin hypotheses, with the
deadline register's own value `l` positions after the origin as the base pin. The mirror of
`exists_spliced_ladderPath_of_pend_past`. -/
theorem exists_deleted_ladderPath_of_pend_past
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hpast : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ))) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = delObj g a l v) ∧ (∀ v, cntAt g' v = delCnt g a l v) := by
  -- every region start of the deleted walk sits above `a`
  have hstart : ∀ s : ℤ, pend (delObj g a l s) = false → a < s := by
    intro s hs
    by_contra hle
    exact Bool.false_ne_true
      (hs.symm.trans (delObj_pend_of_le_of_pend_past hrep hpast s (by omega)))
  -- and is the original's own region start, displaced by `-l`
  have hpull : ∀ s : ℤ, pend (delObj g a l s) = false →
      pend (delObj g a l (s + 1)) = true →
      pend (objAt g (s + (l : ℤ))) = false ∧ pend (objAt g (s + (l : ℤ) + 1)) = true ∧
        delCnt g a l (s + 1) = cntAt g (s + (l : ℤ) + 1) := by
    intro s h0 h1
    have hgt := hstart s h0
    rw [delObj_of_ge s (by omega)] at h0
    rw [delObj_of_ge (s + 1) (by omega), show s + 1 + (l : ℤ) = s + (l : ℤ) + 1 by ring] at h1
    refine ⟨h0, h1, ?_⟩
    rw [delCnt_of_ge (s + 1) (by omega), show s + 1 + (l : ℤ) = s + (l : ℤ) + 1 by ring]
  refine exists_ladderPath_of_walk (delObj g a l) (delCnt g a l) (nxtAt g (l : ℤ))
    (delObj_step hg hrep) (delCnt_idle hg) (delCnt_pend_pend hg hl hcl)
    (delCnt_pend_idle hg hl hcl) (fun s v hs0 hs1 hv0 hv1 => ?_) (fun v hv0 hv1 => ?_)
  · obtain ⟨hs0', hs1', hsc⟩ := hpull s hs0 hs1
    obtain ⟨hv0', hv1', hvc⟩ := hpull v hv0 hv1
    rw [hsc, hvc]
    have := pinCompat_of_ladderPath g hg (s + (l : ℤ)) (v + (l : ℤ)) hs0' hs1' hv0' hv1'
    rw [show s + (l : ℤ) - (v + (l : ℤ)) = s - v by ring] at this
    exact this
  · obtain ⟨hv0', hv1', hvc⟩ := hpull v hv0 hv1
    rw [hvc, cntAt_eq_nxtAt_of_idle_pend g hg (v + (l : ℤ)) hv0' hv1']
    have := nxtAt_lipschitz_two_sided g hg (v + (l : ℤ)) (l : ℤ)
    rw [show v + (l : ℤ) - (l : ℤ) = v by ring] at this
    exact this

end Del

end Path

end FormalSystem.Metalogic.Decidability.RaySummary
