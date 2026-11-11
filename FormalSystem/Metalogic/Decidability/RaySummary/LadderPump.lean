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

The three `Idle`-prefixed sections at the end of the module are the IDLE mirror of the same one
argument: the idle-cycle vocabulary and the run bound without one (`IdleCycle`), the
idle-block duplication with its countdown and its pin clause (`IdleSplice`), and the
idle-restricted `(objAt, tpOf)` pigeonhole (`IdlePigeonhole`). They add no certificate object and
no `ParamsOk` — the idle-block surgery consumes neither.
The idle mirror is not merely the pending argument with `pend` negated at one place: the pin
condition the pending splice carries as a genuine SIDE CONDITION is FREE for an idle block
(`idleSplice_pins`), because the duplicated block contributes no region start of its own and the
pins above it move farther from those below while their countdowns stay put. The
register-anchored assembly that consumes these three sections, and the sharpened lengthening
schema it proves, live in the leaf module `LadderIdle.lean`.

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
index-map transports the pump consumes, and no `⊡`-letter transport: every type statement of the
layer carries the stab-free hypothesis, as `tpOf_stabFree_eq_of_objAt_eq` does.
-/

set_option linter.style.longFile 2000

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

/-! ## The duplication type lemma

HWZ 2000 Lemma 17's duplication mirror, over `ℤ` and for the stab-free fragment: duplicating a
block `[u, u + l)` whose two ends carry the same realized type preserves the realized type at
EVERY position of the spliced history, read through the retraction `spliceIdx u l`. The
statement is proved at the truth level first, in the pinned-letter form the landed transport
layer uses (`truthAt_iff_of_objAt_eq_of_stabPinned`): the `⊡` letters are carried by a parameter
`L`, and the stab-free theorem is the `L := fun _ => False` instance.

The device of the temporal cases is the ENDPOINT EQUALITY `E(θ)`: for every `θ` in the closure,
`θ` is true at `u` iff it is true at `u + l` on the original. It is read off the hypothesis
`hty : tpOf … σ u = tpOf … σ (u + l)` through `mem_tpOf_iff`, and it is used for `ψ U χ`
ITSELF at the two endpoints — never the induction hypothesis for it — and for `ψ` and `χ` at
exactly one position each. Where the retraction folds the second copy of the block back onto
the first (a witness in the second copy retracting to a position at or before the evaluation
point, `spliceIdx_seam_lt`), the fold is undone by passing through `E(ψ U χ)` at the block's
ends. Nothing here needs a pending-region hypothesis, `ParamsOk`, or a pin condition: those are
the admissibility layer's. -/

section SpliceTransport

variable {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)

/-- The endpoint equality of every closure formula, read off the type equality at the block's
ends. -/
theorem endpoint_iff_of_tpOf_eq (φ : PlusFormula) (σ : WorldHistory F.toTaskFrame) (u : ℤ)
    (l : ℕ) (hty : tpOf M φ σ u = tpOf M φ σ (u + (l : ℤ))) (θ : PlusFormula)
    (hθ : θ ∈ plusSubformulaClosure φ) :
    PlusTruthAt M σ u θ ↔ PlusTruthAt M σ (u + (l : ℤ)) θ := by
  have h1 := mem_tpOf_iff M φ σ u θ
  have h2 := mem_tpOf_iff M φ σ (u + (l : ℤ)) θ
  rw [hty] at h1
  constructor
  · intro h
    exact (h2.mp (h1.mpr ⟨hθ, h⟩)).2
  · intro h
    exact (h1.mp (h2.mpr ⟨hθ, h⟩)).2

/-- **The `until` clause, from the spliced history to the original.** -/
theorem untl_spliceIdx_mp (σ σ' : WorldHistory F.toTaskFrame) (u : ℤ) (l : ℕ)
    (ψ χ : PlusFormula)
    (ihψ : ∀ w : ℤ, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (spliceIdx u l w) ψ)
    (ihχ : ∀ w : ℤ, PlusTruthAt M σ' w χ ↔ PlusTruthAt M σ (spliceIdx u l w) χ)
    (Eψ : PlusTruthAt M σ u ψ ↔ PlusTruthAt M σ (u + (l : ℤ)) ψ)
    (Eχ : PlusTruthAt M σ u χ ↔ PlusTruthAt M σ (u + (l : ℤ)) χ)
    (EU : PlusTruthAt M σ u (.untl ψ χ) ↔ PlusTruthAt M σ (u + (l : ℤ)) (.untl ψ χ))
    (w : ℤ) (h : PlusTruthAt M σ' w (.untl ψ χ)) :
    PlusTruthAt M σ (spliceIdx u l w) (.untl ψ χ) := by
  rw [PlusTruth.untl_iff] at h ⊢
  obtain ⟨s, hs, hχ, hgd⟩ := h
  obtain ⟨s', rfl⟩ : ∃ s' : ℤ, s' = s := ⟨s, rfl⟩
  have hs' : w < s' := hs
  rw [ihχ s'] at hχ
  have hgd' : ∀ r : ℤ, w < r → r < s' → PlusTruthAt M σ (spliceIdx u l r) ψ :=
    fun r h1 h2 => (ihψ r).mp (hgd r h1 h2)
  by_cases hA : s' < u + (l : ℤ)
  · -- the retraction is the identity on `[w, s']`
    rw [spliceIdx_of_lt u l w (by omega)]
    rw [spliceIdx_of_lt u l s' hA] at hχ
    refine ⟨s', hs', hχ, fun r h1 h2 => ?_⟩
    obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
    have h1' : w < r' := h1
    have h2' : r' < s' := h2
    have := hgd' r' h1' h2'
    rwa [spliceIdx_of_lt u l r' (by omega)] at this
  · rw [not_lt] at hA
    rw [spliceIdx_of_ge u l s' hA] at hχ
    by_cases hB : u + (l : ℤ) ≤ w
    · -- everything shifts by `l`
      rw [spliceIdx_of_ge u l w hB]
      refine ⟨s' - (l : ℤ), by change (_ : ℤ) < _; omega, hχ, fun r h1 h2 => ?_⟩
      obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : w - (l : ℤ) < r' := h1
      have h2' : r' < s' - (l : ℤ) := h2
      have := hgd' (r' + (l : ℤ)) (by omega) (by omega)
      rwa [spliceIdx_of_ge u l (r' + (l : ℤ)) (by omega),
        show r' + (l : ℤ) - (l : ℤ) = r' by ring] at this
    · rw [not_le] at hB
      rw [spliceIdx_of_lt u l w hB]
      -- `ψ` on the original at every `r ∈ (w, u + l)` and at every `r ∈ [u, s' - l)`
      have hψ1 : ∀ r : ℤ, w < r → r < u + (l : ℤ) → PlusTruthAt M σ r ψ := fun r h1 h2 => by
        have := hgd' r h1 (by omega)
        rwa [spliceIdx_of_lt u l r h2] at this
      have hψ2 : ∀ r : ℤ, u ≤ r → r < s' - (l : ℤ) → PlusTruthAt M σ r ψ := fun r h1 h2 => by
        have := hgd' (r + (l : ℤ)) (by omega) (by omega)
        rwa [spliceIdx_of_ge u l (r + (l : ℤ)) (by omega),
          show r + (l : ℤ) - (l : ℤ) = r by ring] at this
      by_cases hC : w < s' - (l : ℤ)
      · -- the witness retracts to a later position
        refine ⟨s' - (l : ℤ), hC, hχ, fun r h1 h2 => ?_⟩
        obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : w < r' := h1
        have h2' : r' < s' - (l : ℤ) := h2
        by_cases hr : r' < u + (l : ℤ)
        · exact hψ1 r' h1' hr
        · exact hψ2 r' (by omega) h2'
      · -- the fold-back: `u ≤ w < u + l ≤ s' ≤ w + l`
        rw [not_lt] at hC
        rcases lt_or_eq_of_le (show u ≤ s' - (l : ℤ) by omega) with hD | hD
        · -- `ψ U χ` holds at `u` on the original; pass to `u + l` through `E(ψ U χ)`
          have hUu : PlusTruthAt M σ u (.untl ψ χ) := by
            rw [PlusTruth.untl_iff]
            refine ⟨s' - (l : ℤ), hD, hχ, fun r h1 h2 => ?_⟩
            obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
            have h1' : u < r' := h1
            have h2' : r' < s' - (l : ℤ) := h2
            exact hψ2 r' (by omega) h2'
          have hUul := EU.mp hUu
          rw [PlusTruth.untl_iff] at hUul
          obtain ⟨s₂, hs₂, hχ₂, hgd₂⟩ := hUul
          obtain ⟨s₂', rfl⟩ : ∃ s₂' : ℤ, s₂' = s₂ := ⟨s₂, rfl⟩
          have hs₂' : u + (l : ℤ) < s₂' := hs₂
          refine ⟨s₂', by change (_ : ℤ) < _; omega, hχ₂, fun r h1 h2 => ?_⟩
          obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : w < r' := h1
          have h2' : r' < s₂' := h2
          rcases lt_trichotomy r' (u + (l : ℤ)) with hr | hr | hr
          · exact hψ1 r' h1' hr
          · rw [hr]; exact Eψ.mp (hψ2 u le_rfl hD)
          · exact hgd₂ r' hr h2'
        · -- the witness retracts to `u` itself; pass `χ` to `u + l` through `E(χ)`
          rw [← hD] at hχ
          refine ⟨u + (l : ℤ), hB, Eχ.mp hχ, fun r h1 h2 => ?_⟩
          obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : w < r' := h1
          have h2' : r' < u + (l : ℤ) := h2
          exact hψ1 r' h1' h2'

/-- **The `until` clause, from the original to the spliced history.** -/
theorem untl_spliceIdx_mpr (σ σ' : WorldHistory F.toTaskFrame) (u : ℤ) (l : ℕ)
    (ψ χ : PlusFormula)
    (ihψ : ∀ w : ℤ, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (spliceIdx u l w) ψ)
    (ihχ : ∀ w : ℤ, PlusTruthAt M σ' w χ ↔ PlusTruthAt M σ (spliceIdx u l w) χ)
    (Eψ : PlusTruthAt M σ u ψ ↔ PlusTruthAt M σ (u + (l : ℤ)) ψ)
    (Eχ : PlusTruthAt M σ u χ ↔ PlusTruthAt M σ (u + (l : ℤ)) χ)
    (EU : PlusTruthAt M σ u (.untl ψ χ) ↔ PlusTruthAt M σ (u + (l : ℤ)) (.untl ψ χ))
    (w : ℤ) (h : PlusTruthAt M σ (spliceIdx u l w) (.untl ψ χ)) :
    PlusTruthAt M σ' w (.untl ψ χ) := by
  rw [PlusTruth.untl_iff] at h ⊢
  obtain ⟨s, hs, hχ, hgd⟩ := h
  obtain ⟨s₀, rfl⟩ : ∃ s₀ : ℤ, s₀ = s := ⟨s, rfl⟩
  have hs₀ : spliceIdx u l w < s₀ := hs
  -- a guard position of the spliced history is checked on the original through the retraction
  have hgd' : ∀ r : ℤ, spliceIdx u l w < r → r < s₀ → PlusTruthAt M σ r ψ := hgd
  by_cases hB : u + (l : ℤ) ≤ w
  · -- everything shifts by `l`
    rw [spliceIdx_of_ge u l w hB] at hs₀ hgd'
    refine ⟨s₀ + (l : ℤ), by change (_ : ℤ) < _; omega, ?_, fun r h1 h2 => ?_⟩
    · rw [ihχ, spliceIdx_of_ge u l (s₀ + (l : ℤ)) (by omega),
        show s₀ + (l : ℤ) - (l : ℤ) = s₀ by ring]
      exact hχ
    · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : w < r' := h1
      have h2' : r' < s₀ + (l : ℤ) := h2
      rw [ihψ, spliceIdx_of_ge u l r' (by omega)]
      exact hgd' (r' - (l : ℤ)) (by omega) (by omega)
  · rw [not_le] at hB
    rw [spliceIdx_of_lt u l w hB] at hs₀ hgd'
    by_cases hA : s₀ < u + (l : ℤ)
    · -- the witness sits before the seam: the identity transports it
      refine ⟨s₀, hs₀, ?_, fun r h1 h2 => ?_⟩
      · rw [ihχ, spliceIdx_of_lt u l s₀ hA]; exact hχ
      · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : w < r' := h1
        have h2' : r' < s₀ := h2
        rw [ihψ, spliceIdx_of_lt u l r' (by omega)]
        exact hgd' r' h1' h2'
    · rw [not_lt] at hA
      by_cases hw : w < u
      · -- the evaluation point is before the block: the witness shifts by `l`
        refine ⟨s₀ + (l : ℤ), by change (_ : ℤ) < _; omega, ?_, fun r h1 h2 => ?_⟩
        · rw [ihχ, spliceIdx_of_ge u l (s₀ + (l : ℤ)) (by omega),
            show s₀ + (l : ℤ) - (l : ℤ) = s₀ by ring]
          exact hχ
        · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : w < r' := h1
          have h2' : r' < s₀ + (l : ℤ) := h2
          rw [ihψ]
          by_cases hr : r' < u + (l : ℤ)
          · rw [spliceIdx_of_lt u l r' hr]; exact hgd' r' h1' (by omega)
          · rw [spliceIdx_of_ge u l r' (by omega)]; exact hgd' (r' - (l : ℤ)) (by omega) (by omega)
      · -- the evaluation point is inside the first copy: `u ≤ w < u + l ≤ s₀`
        rw [not_lt] at hw
        rcases lt_or_eq_of_le hA with hD | hD
        · -- `s₀ > u + l`: `ψ U χ` holds at `u + l`, hence at `u` through `E(ψ U χ)`
          have hUul : PlusTruthAt M σ (u + (l : ℤ)) (.untl ψ χ) := by
            rw [PlusTruth.untl_iff]
            refine ⟨s₀, hD, hχ, fun r h1 h2 => ?_⟩
            obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
            have h1' : u + (l : ℤ) < r' := h1
            have h2' : r' < s₀ := h2
            exact hgd' r' (by omega) h2'
          have hUu := EU.mpr hUul
          rw [PlusTruth.untl_iff] at hUu
          obtain ⟨s₂, hs₂, hχ₂, hgd₂⟩ := hUu
          obtain ⟨s₂', rfl⟩ : ∃ s₂' : ℤ, s₂' = s₂ := ⟨s₂, rfl⟩
          have hs₂' : u < s₂' := hs₂
          have hgd₂' : ∀ r : ℤ, u < r → r < s₂' → PlusTruthAt M σ r ψ := hgd₂
          -- `ψ` at `u`, from `ψ` at `u + l` through `E(ψ)`
          have hψu : PlusTruthAt M σ u ψ := Eψ.mpr (hgd' (u + (l : ℤ)) (by omega) hD)
          by_cases hE : w < s₂' ∧ s₂' < u + (l : ℤ)
          · -- the new witness lies in the first copy, after the evaluation point
            refine ⟨s₂', hE.1, ?_, fun r h1 h2 => ?_⟩
            · rw [ihχ, spliceIdx_of_lt u l s₂' hE.2]; exact hχ₂
            · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
              have h1' : w < r' := h1
              have h2' : r' < s₂' := h2
              rw [ihψ, spliceIdx_of_lt u l r' (by omega)]
              exact hgd₂' r' (by omega) h2'
          · -- otherwise read the new witness in the second copy
            refine ⟨s₂' + (l : ℤ), by change (_ : ℤ) < _; omega, ?_, fun r h1 h2 => ?_⟩
            · rw [ihχ, spliceIdx_of_ge u l (s₂' + (l : ℤ)) (by omega),
                show s₂' + (l : ℤ) - (l : ℤ) = s₂' by ring]
              exact hχ₂
            · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
              have h1' : w < r' := h1
              have h2' : r' < s₂' + (l : ℤ) := h2
              rw [ihψ]
              by_cases hr : r' < u + (l : ℤ)
              · rw [spliceIdx_of_lt u l r' hr]; exact hgd' r' h1' (by omega)
              · rw [spliceIdx_of_ge u l r' (by omega)]
                rcases lt_or_eq_of_le (show u ≤ r' - (l : ℤ) by omega) with hr2 | hr2
                · exact hgd₂' (r' - (l : ℤ)) hr2 (by omega)
                · rw [← hr2]; exact hψu
        · -- `s₀ = u + l`: `χ` at `u + l`, hence at `u` through `E(χ)`
          rw [← hD] at hχ
          refine ⟨u + (l : ℤ), hB, ?_, fun r h1 h2 => ?_⟩
          · rw [ihχ, spliceIdx_of_ge u l (u + (l : ℤ)) le_rfl,
              show u + (l : ℤ) - (l : ℤ) = u by ring]
            exact Eχ.mpr hχ
          · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
            have h1' : w < r' := h1
            have h2' : r' < u + (l : ℤ) := h2
            rw [ihψ, spliceIdx_of_lt u l r' h2']
            exact hgd' r' h1' (by omega)

/-- **The `since` clause, from the spliced history to the original.** The fold is in the FIRST
copy: a witness before the seam for an evaluation point in the second copy. -/
theorem snce_spliceIdx_mp (σ σ' : WorldHistory F.toTaskFrame) (u : ℤ) (l : ℕ)
    (ψ χ : PlusFormula)
    (ihψ : ∀ w : ℤ, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (spliceIdx u l w) ψ)
    (ihχ : ∀ w : ℤ, PlusTruthAt M σ' w χ ↔ PlusTruthAt M σ (spliceIdx u l w) χ)
    (ES : PlusTruthAt M σ u (.snce ψ χ) ↔ PlusTruthAt M σ (u + (l : ℤ)) (.snce ψ χ))
    (w : ℤ) (h : PlusTruthAt M σ' w (.snce ψ χ)) :
    PlusTruthAt M σ (spliceIdx u l w) (.snce ψ χ) := by
  rw [PlusTruth.snce_iff] at h ⊢
  obtain ⟨s, hs, hχ, hgd⟩ := h
  obtain ⟨s', rfl⟩ : ∃ s' : ℤ, s' = s := ⟨s, rfl⟩
  have hs' : s' < w := hs
  rw [ihχ s'] at hχ
  have hgd' : ∀ r : ℤ, s' < r → r < w → PlusTruthAt M σ (spliceIdx u l r) ψ :=
    fun r h1 h2 => (ihψ r).mp (hgd r h1 h2)
  by_cases hA : w < u + (l : ℤ)
  · -- the retraction is the identity on `(-∞, w]`
    rw [spliceIdx_of_lt u l w hA]
    rw [spliceIdx_of_lt u l s' (by omega)] at hχ
    refine ⟨s', hs', hχ, fun r h1 h2 => ?_⟩
    obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
    have h1' : s' < r' := h1
    have h2' : r' < w := h2
    have := hgd' r' h1' h2'
    rwa [spliceIdx_of_lt u l r' (by omega)] at this
  · rw [not_lt] at hA
    rw [spliceIdx_of_ge u l w hA]
    by_cases hB : u + (l : ℤ) ≤ s'
    · -- everything shifts by `l`
      rw [spliceIdx_of_ge u l s' hB] at hχ
      refine ⟨s' - (l : ℤ), by change (_ : ℤ) < _; omega, hχ, fun r h1 h2 => ?_⟩
      obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : s' - (l : ℤ) < r' := h1
      have h2' : r' < w - (l : ℤ) := h2
      have := hgd' (r' + (l : ℤ)) (by omega) (by omega)
      rwa [spliceIdx_of_ge u l (r' + (l : ℤ)) (by omega),
        show r' + (l : ℤ) - (l : ℤ) = r' by ring] at this
    · rw [not_le] at hB
      rw [spliceIdx_of_lt u l s' hB] at hχ
      -- `ψ` on the original at every `r ∈ (s', u + l)` and at every `r ∈ [u, w - l)`
      have hψ1 : ∀ r : ℤ, s' < r → r < u + (l : ℤ) → PlusTruthAt M σ r ψ := fun r h1 h2 => by
        have := hgd' r h1 (by omega)
        rwa [spliceIdx_of_lt u l r h2] at this
      have hψ2 : ∀ r : ℤ, u ≤ r → r < w - (l : ℤ) → PlusTruthAt M σ r ψ := fun r h1 h2 => by
        have := hgd' (r + (l : ℤ)) (by omega) (by omega)
        rwa [spliceIdx_of_ge u l (r + (l : ℤ)) (by omega),
          show r + (l : ℤ) - (l : ℤ) = r by ring] at this
      by_cases hC : s' < w - (l : ℤ)
      · -- the witness is before the evaluation point's image
        refine ⟨s', hC, hχ, fun r h1 h2 => ?_⟩
        obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : s' < r' := h1
        have h2' : r' < w - (l : ℤ) := h2
        by_cases hr : r' < u + (l : ℤ)
        · exact hψ1 r' h1' hr
        · exact hψ2 r' (by omega) h2'
      · -- the fold: `w - l ≤ s' < u + l`, so `ψ S χ` holds at `u + l`; pass to `u`
        rw [not_lt] at hC
        have hSul : PlusTruthAt M σ (u + (l : ℤ)) (.snce ψ χ) := by
          rw [PlusTruth.snce_iff]
          refine ⟨s', hB, hχ, fun r h1 h2 => ?_⟩
          obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : s' < r' := h1
          have h2' : r' < u + (l : ℤ) := h2
          exact hψ1 r' h1' h2'
        have hSu := ES.mpr hSul
        rw [PlusTruth.snce_iff] at hSu
        obtain ⟨s₂, hs₂, hχ₂, hgd₂⟩ := hSu
        obtain ⟨s₂', rfl⟩ : ∃ s₂' : ℤ, s₂' = s₂ := ⟨s₂, rfl⟩
        have hs₂' : s₂' < u := hs₂
        refine ⟨s₂', by change (_ : ℤ) < _; omega, hχ₂, fun r h1 h2 => ?_⟩
        obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : s₂' < r' := h1
        have h2' : r' < w - (l : ℤ) := h2
        by_cases hr : r' < u
        · exact hgd₂ r' h1' hr
        · exact hψ2 r' (by omega) h2'

/-- **The `since` clause, from the original to the spliced history.** -/
theorem snce_spliceIdx_mpr (σ σ' : WorldHistory F.toTaskFrame) (u : ℤ) (l : ℕ)
    (ψ χ : PlusFormula)
    (ihψ : ∀ w : ℤ, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (spliceIdx u l w) ψ)
    (ihχ : ∀ w : ℤ, PlusTruthAt M σ' w χ ↔ PlusTruthAt M σ (spliceIdx u l w) χ)
    (ES : PlusTruthAt M σ u (.snce ψ χ) ↔ PlusTruthAt M σ (u + (l : ℤ)) (.snce ψ χ))
    (w : ℤ) (h : PlusTruthAt M σ (spliceIdx u l w) (.snce ψ χ)) :
    PlusTruthAt M σ' w (.snce ψ χ) := by
  rw [PlusTruth.snce_iff] at h ⊢
  obtain ⟨s, hs, hχ, hgd⟩ := h
  obtain ⟨s₀, rfl⟩ : ∃ s₀ : ℤ, s₀ = s := ⟨s, rfl⟩
  have hs₀ : s₀ < spliceIdx u l w := hs
  have hgd' : ∀ r : ℤ, s₀ < r → r < spliceIdx u l w → PlusTruthAt M σ r ψ := hgd
  by_cases hA : w < u + (l : ℤ)
  · -- the retraction is the identity on `(-∞, w]`
    rw [spliceIdx_of_lt u l w hA] at hs₀ hgd'
    refine ⟨s₀, hs₀, ?_, fun r h1 h2 => ?_⟩
    · rw [ihχ, spliceIdx_of_lt u l s₀ (by omega)]; exact hχ
    · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : s₀ < r' := h1
      have h2' : r' < w := h2
      rw [ihψ, spliceIdx_of_lt u l r' (by omega)]
      exact hgd' r' h1' h2'
  · rw [not_lt] at hA
    rw [spliceIdx_of_ge u l w hA] at hs₀ hgd'
    by_cases hB : u ≤ s₀
    · -- the witness is in the block or after it: it shifts by `l`
      refine ⟨s₀ + (l : ℤ), by change (_ : ℤ) < _; omega, ?_, fun r h1 h2 => ?_⟩
      · rw [ihχ, spliceIdx_of_ge u l (s₀ + (l : ℤ)) (by omega),
          show s₀ + (l : ℤ) - (l : ℤ) = s₀ by ring]
        exact hχ
      · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : s₀ + (l : ℤ) < r' := h1
        have h2' : r' < w := h2
        rw [ihψ, spliceIdx_of_ge u l r' (by omega)]
        exact hgd' (r' - (l : ℤ)) (by omega) (by omega)
    · -- the witness is before the block: `ψ S χ` holds at `u`, hence at `u + l`
      rw [not_le] at hB
      have hSu : PlusTruthAt M σ u (.snce ψ χ) := by
        rw [PlusTruth.snce_iff]
        refine ⟨s₀, hB, hχ, fun r h1 h2 => ?_⟩
        obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : s₀ < r' := h1
        have h2' : r' < u := h2
        exact hgd' r' h1' (by omega)
      have hSul := ES.mp hSu
      rw [PlusTruth.snce_iff] at hSul
      obtain ⟨s₂, hs₂, hχ₂, hgd₂⟩ := hSul
      obtain ⟨s₂', rfl⟩ : ∃ s₂' : ℤ, s₂' = s₂ := ⟨s₂, rfl⟩
      have hs₂' : s₂' < u + (l : ℤ) := hs₂
      have hgd₂' : ∀ r : ℤ, s₂' < r → r < u + (l : ℤ) → PlusTruthAt M σ r ψ := hgd₂
      refine ⟨s₂', by change (_ : ℤ) < _; omega, ?_, fun r h1 h2 => ?_⟩
      · rw [ihχ, spliceIdx_of_lt u l s₂' hs₂']; exact hχ₂
      · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : s₂' < r' := h1
        have h2' : r' < w := h2
        rw [ihψ]
        by_cases hr : r' < u + (l : ℤ)
        · rw [spliceIdx_of_lt u l r' hr]; exact hgd₂' r' h1' hr
        · rw [spliceIdx_of_ge u l r' (by omega)]
          exact hgd' (r' - (l : ℤ)) (by omega) (by omega)

end SpliceTransport

section SpliceType

/-- **The pinned-letter transport along the splice retraction**, at the truth level: for every
closure formula whose `⊡` letters are pinned by `L`, truth on the spliced history at `w` is
truth on the original at `spliceIdx u l w`. The induction is one case per clause; the two
temporal clauses are the four lemmas above. -/
theorem plusTruthAt_iff_spliceIdx_of_tpOf_eq_of_stabPinned {Q : Type} [Finite Q] [Nonempty Q]
    {step : Q → Q → Bool} {pend : Q → Bool}
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (L : PlusFormula → Prop) (u : ℤ) (l : ℕ)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hobj : ∀ w : ℤ, objAt g' w = objAt g (spliceIdx u l w))
    (hL : ∀ χ : PlusFormula, L (PlusFormula.stab χ) → ∀ w : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ' w (PlusFormula.stab χ) ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ (spliceIdx u l w)
          (PlusFormula.stab χ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) :
    ∀ ψ : PlusFormula, ψ ∈ plusSubformulaClosure φ → StabPinned L ψ → ∀ w : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ' w ψ ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ (spliceIdx u l w) ψ) := by
  have E := endpoint_iff_of_tpOf_eq (ladderModel step pend fwd bwd lab) φ σ u l hty
  intro ψ
  induction ψ with
  | atom p =>
      intro _ _ w
      rw [PlusTruth.atom_iff, PlusTruth.atom_iff, hσ' w, hσ (spliceIdx u l w)]
      change lab (objAt g' w) p = true ↔ lab (objAt g (spliceIdx u l w)) p = true
      rw [hobj w]
  | bot => intro _ _ _; exact Iff.rfl
  | imp a b iha ihb =>
      intro hm h w
      exact imp_congr (iha (plusClosure_imp_left φ a b hm) h.1 w)
        (ihb (plusClosure_imp_right φ a b hm) h.2 w)
  | box a _ =>
      intro hm _ w
      have h1 := mem_tpOf_iff (ladderModel step pend fwd bwd lab) φ σ' w (.box a)
      have h2 := mem_tpOf_iff (ladderModel step pend fwd bwd lab) φ σ (spliceIdx u l w) (.box a)
      have ht := box_mem_tpOf_transfer (ladderModel step pend fwd bwd lab) φ σ' σ w
        (spliceIdx u l w) hm
      constructor
      · intro h; exact (h2.mp (ht.mp (h1.mpr ⟨hm, h⟩))).2
      · intro h; exact (h1.mp (ht.mpr (h2.mpr ⟨hm, h⟩))).2
  | untl a b iha ihb =>
      intro hm h w
      have hma := plusClosure_untl_right φ b a hm
      have hmb := plusClosure_untl_left φ b a hm
      exact ⟨untl_spliceIdx_mp _ σ σ' u l a b (iha hma h.1) (ihb hmb h.2) (E a hma) (E b hmb)
          (E _ hm) w,
        untl_spliceIdx_mpr _ σ σ' u l a b (iha hma h.1) (ihb hmb h.2) (E a hma) (E b hmb)
          (E _ hm) w⟩
  | snce a b iha ihb =>
      intro hm h w
      have hma := plusClosure_snce_right φ b a hm
      have hmb := plusClosure_snce_left φ b a hm
      exact ⟨snce_spliceIdx_mp _ σ σ' u l a b (iha hma h.1) (ihb hmb h.2) (E _ hm) w,
        snce_spliceIdx_mpr _ σ σ' u l a b (iha hma h.1) (ihb hmb h.2) (E _ hm) w⟩
  | stab a _ => intro _ h w; exact hL a h w

-- `linter.unusedVariables` and `linter.unusedFintypeInType`, scoped to this declaration. The
-- signature is pinned by the plan's Lean Challenge Statements block: `hl : 0 < l` is carried in
-- step with `exists_spliced_ladderPath_of_pend_past` (the lemma holds for `l = 0` as well, where
-- the retraction is the identity, so the proof does not read it), and `[Fintype Q]` is the
-- block's instance binder where `ladderModel` reads only the `Finite Q` it implies.
set_option linter.unusedVariables false in
set_option linter.unusedFintypeInType false in
/-- **THE DUPLICATION TYPE LEMMA.** Duplicating a block whose two ends carry the same realized
stab-free type preserves the realized type at EVERY position, read through the retraction: the
stab-free instance of the pinned-letter transport. HWZ 2000 Lemma 17 is the deletion form, of
which this is the mirror. Needs no pending-region hypothesis, no `ParamsOk` and no pin
condition — those are the admissibility layer's. -/
theorem tpOf_eq_spliceIdx_of_tpOf_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (u : ℤ) (l : ℕ) (hl : 0 < l)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t))
    (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hobj : ∀ w : ℤ, objAt g' w = objAt g (spliceIdx u l w))
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) :
    ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
      = tpOf (ladderModel step pend fwd bwd lab) φ σ (spliceIdx u l w) := by
  intro w
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  exact and_congr_right fun hmem =>
    plusTruthAt_iff_spliceIdx_of_tpOf_eq_of_stabPinned fwd bwd lab φ (fun _ => False) u l σ σ'
      hσ hσ' hobj (fun _ h => absurd h (fun h => h)) hty ψ hmem
      (stabPinned_false_of_mem_closure hno ψ hmem) w

end SpliceType

/-! ## The deletion type lemma

HWZ 2000 Lemma 17 over `ℤ`, for the stab-free fragment: deleting a block `[u, u + l)` whose two
ends carry the same realized type preserves the realized type at EVERY position of the deleted
history, read through the monotone embedding `delIdx u l`. Because the embedding is monotone,
a temporal witness transports forward trivially; the only gap is the deleted block itself, when
it lies inside a guard interval or carries the witness. Those cases pass through the endpoint
equality `E(ψ U χ)` at the block's ends (a witness inside the block is replaced by one beyond
it) and through `E(ψ)`/`E(χ)` at exactly one position each. As for the duplication lemma,
nothing here needs a pending-region hypothesis, `ParamsOk` or a pin condition: the admissibility
side `exists_deleted_ladderPath_of_pend_past` is where the pins enter. -/

section DelTransport

variable {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)

/-- **The `until` clause, from the deleted history to the original.** -/
theorem untl_delIdx_mp (σ σ' : WorldHistory F.toTaskFrame) (u : ℤ) (l : ℕ)
    (ψ χ : PlusFormula)
    (ihψ : ∀ w : ℤ, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (delIdx u l w) ψ)
    (ihχ : ∀ w : ℤ, PlusTruthAt M σ' w χ ↔ PlusTruthAt M σ (delIdx u l w) χ)
    (Eψ : PlusTruthAt M σ u ψ ↔ PlusTruthAt M σ (u + (l : ℤ)) ψ)
    (Eχ : PlusTruthAt M σ u χ ↔ PlusTruthAt M σ (u + (l : ℤ)) χ)
    (EU : PlusTruthAt M σ u (.untl ψ χ) ↔ PlusTruthAt M σ (u + (l : ℤ)) (.untl ψ χ))
    (w : ℤ) (h : PlusTruthAt M σ' w (.untl ψ χ)) :
    PlusTruthAt M σ (delIdx u l w) (.untl ψ χ) := by
  rw [PlusTruth.untl_iff] at h ⊢
  obtain ⟨s, hs, hχ, hgd⟩ := h
  obtain ⟨s', rfl⟩ : ∃ s' : ℤ, s' = s := ⟨s, rfl⟩
  have hs' : w < s' := hs
  rw [ihχ s'] at hχ
  have hgd' : ∀ r : ℤ, w < r → r < s' → PlusTruthAt M σ (delIdx u l r) ψ :=
    fun r h1 h2 => (ihψ r).mp (hgd r h1 h2)
  by_cases hB : u ≤ w
  · -- everything shifts by `l`
    rw [delIdx_of_ge u l w hB]
    rw [delIdx_of_ge u l s' (by omega)] at hχ
    refine ⟨s' + (l : ℤ), (show w + (l : ℤ) < s' + (l : ℤ) by omega), hχ, fun r h1 h2 => ?_⟩
    obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
    have h1' : w + (l : ℤ) < r' := h1
    have h2' : r' < s' + (l : ℤ) := h2
    have := hgd' (r' - (l : ℤ)) (by omega) (by omega)
    rwa [delIdx_of_ge u l (r' - (l : ℤ)) (by omega),
      show r' - (l : ℤ) + (l : ℤ) = r' by ring] at this
  · rw [not_le] at hB
    rw [delIdx_of_lt u l w hB]
    by_cases hA : s' < u
    · -- the witness is before the block: the identity transports it
      rw [delIdx_of_lt u l s' hA] at hχ
      refine ⟨s', hs', hχ, fun r h1 h2 => ?_⟩
      obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : w < r' := h1
      have h2' : r' < s' := h2
      have := hgd' r' h1' h2'
      rwa [delIdx_of_lt u l r' (by omega)] at this
    · rw [not_lt] at hA
      rw [delIdx_of_ge u l s' hA] at hχ
      -- `ψ` on the original at every `r ∈ (w, u)` and at every `r + l` with `r ∈ [u, s')`
      have hψ1 : ∀ r : ℤ, w < r → r < u → PlusTruthAt M σ r ψ := fun r h1 h2 => by
        have := hgd' r h1 (by omega)
        rwa [delIdx_of_lt u l r h2] at this
      have hψ2 : ∀ r : ℤ, u ≤ r → r < s' → PlusTruthAt M σ (r + (l : ℤ)) ψ := fun r h1 h2 => by
        have := hgd' r (by omega) h2
        rwa [delIdx_of_ge u l r h1] at this
      rcases lt_or_eq_of_le hA with hD | hD
      · -- the witness is beyond the block: `ψ U χ` holds at `u + l`, hence at `u`
        have hUul : PlusTruthAt M σ (u + (l : ℤ)) (.untl ψ χ) := by
          rw [PlusTruth.untl_iff]
          refine ⟨s' + (l : ℤ), (show u + (l : ℤ) < s' + (l : ℤ) by omega), hχ,
            fun r h1 h2 => ?_⟩
          obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : u + (l : ℤ) < r' := h1
          have h2' : r' < s' + (l : ℤ) := h2
          have := hψ2 (r' - (l : ℤ)) (by omega) (by omega)
          rwa [show r' - (l : ℤ) + (l : ℤ) = r' by ring] at this
        have hUu := EU.mpr hUul
        rw [PlusTruth.untl_iff] at hUu
        obtain ⟨s₂, hs₂, hχ₂, hgd₂⟩ := hUu
        obtain ⟨s₂', rfl⟩ : ∃ s₂' : ℤ, s₂' = s₂ := ⟨s₂, rfl⟩
        have hs₂' : u < s₂' := hs₂
        refine ⟨s₂', (show w < s₂' by omega), hχ₂, fun r h1 h2 => ?_⟩
        obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : w < r' := h1
        have h2' : r' < s₂' := h2
        rcases lt_trichotomy r' u with hr | hr | hr
        · exact hψ1 r' h1' hr
        · rw [hr]; exact Eψ.mpr (hψ2 u le_rfl hD)
        · exact hgd₂ r' hr h2'
      · -- the witness is the block's start: `χ` at `u + l`, hence at `u`
        rw [← hD] at hχ
        refine ⟨u, hB, Eχ.mpr hχ, fun r h1 h2 => ?_⟩
        obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : w < r' := h1
        have h2' : r' < u := h2
        exact hψ1 r' h1' h2'

/-- **The `until` clause, from the original to the deleted history.** HWZ 2000 Lemma 17's
`⇒`-case for `ψ₁ U ψ₂`: a witness beyond the block shifts back by `l`; a witness inside the
block is replaced, through `E(ψ U χ)`, by one beyond it; a witness at the block's start passes
through `E(χ)`. -/
theorem untl_delIdx_mpr (σ σ' : WorldHistory F.toTaskFrame) (u : ℤ) (l : ℕ)
    (ψ χ : PlusFormula)
    (ihψ : ∀ w : ℤ, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (delIdx u l w) ψ)
    (ihχ : ∀ w : ℤ, PlusTruthAt M σ' w χ ↔ PlusTruthAt M σ (delIdx u l w) χ)
    (Eψ : PlusTruthAt M σ u ψ ↔ PlusTruthAt M σ (u + (l : ℤ)) ψ)
    (Eχ : PlusTruthAt M σ u χ ↔ PlusTruthAt M σ (u + (l : ℤ)) χ)
    (EU : PlusTruthAt M σ u (.untl ψ χ) ↔ PlusTruthAt M σ (u + (l : ℤ)) (.untl ψ χ))
    (w : ℤ) (h : PlusTruthAt M σ (delIdx u l w) (.untl ψ χ)) :
    PlusTruthAt M σ' w (.untl ψ χ) := by
  rw [PlusTruth.untl_iff] at h ⊢
  obtain ⟨s, hs, hχ, hgd⟩ := h
  obtain ⟨s₀, rfl⟩ : ∃ s₀ : ℤ, s₀ = s := ⟨s, rfl⟩
  have hs₀ : delIdx u l w < s₀ := hs
  have hgd' : ∀ r : ℤ, delIdx u l w < r → r < s₀ → PlusTruthAt M σ r ψ := hgd
  by_cases hB : u ≤ w
  · -- everything shifts by `l`
    rw [delIdx_of_ge u l w hB] at hs₀ hgd'
    refine ⟨s₀ - (l : ℤ), (show w < s₀ - (l : ℤ) by omega), ?_, fun r h1 h2 => ?_⟩
    · rw [ihχ, delIdx_of_ge u l (s₀ - (l : ℤ)) (by omega),
        show s₀ - (l : ℤ) + (l : ℤ) = s₀ by ring]
      exact hχ
    · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : w < r' := h1
      have h2' : r' < s₀ - (l : ℤ) := h2
      rw [ihψ, delIdx_of_ge u l r' (by omega)]
      exact hgd' (r' + (l : ℤ)) (by omega) (by omega)
  · rw [not_le] at hB
    rw [delIdx_of_lt u l w hB] at hs₀ hgd'
    by_cases hA : s₀ < u
    · -- the witness is before the block
      refine ⟨s₀, hs₀, ?_, fun r h1 h2 => ?_⟩
      · rw [ihχ, delIdx_of_lt u l s₀ hA]; exact hχ
      · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : w < r' := h1
        have h2' : r' < s₀ := h2
        rw [ihψ, delIdx_of_lt u l r' (by omega)]
        exact hgd' r' h1' h2'
    · rw [not_lt] at hA
      by_cases hC : u + (l : ℤ) ≤ s₀
      · -- the witness is beyond the block: it shifts back by `l`
        refine ⟨s₀ - (l : ℤ), (show w < s₀ - (l : ℤ) by omega), ?_, fun r h1 h2 => ?_⟩
        · rw [ihχ, delIdx_of_ge u l (s₀ - (l : ℤ)) (by omega),
            show s₀ - (l : ℤ) + (l : ℤ) = s₀ by ring]
          exact hχ
        · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : w < r' := h1
          have h2' : r' < s₀ - (l : ℤ) := h2
          rw [ihψ]
          by_cases hr : r' < u
          · rw [delIdx_of_lt u l r' hr]; exact hgd' r' h1' (by omega)
          · rw [delIdx_of_ge u l r' (by omega)]; exact hgd' (r' + (l : ℤ)) (by omega) (by omega)
      · rw [not_le] at hC
        -- the witness is inside the block
        rcases lt_or_eq_of_le hA with hD | hD
        · -- `s₀ > u`: `ψ U χ` holds at `u`, hence at `u + l` through `E(ψ U χ)`
          have hUu : PlusTruthAt M σ u (.untl ψ χ) := by
            rw [PlusTruth.untl_iff]
            refine ⟨s₀, hD, hχ, fun r h1 h2 => ?_⟩
            obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
            have h1' : u < r' := h1
            have h2' : r' < s₀ := h2
            exact hgd' r' (by omega) h2'
          have hUul := EU.mp hUu
          rw [PlusTruth.untl_iff] at hUul
          obtain ⟨s₂, hs₂, hχ₂, hgd₂⟩ := hUul
          obtain ⟨s₂', rfl⟩ : ∃ s₂' : ℤ, s₂' = s₂ := ⟨s₂, rfl⟩
          have hs₂' : u + (l : ℤ) < s₂' := hs₂
          have hgd₂' : ∀ r : ℤ, u + (l : ℤ) < r → r < s₂' → PlusTruthAt M σ r ψ := hgd₂
          have hψul : PlusTruthAt M σ (u + (l : ℤ)) ψ := Eψ.mp (hgd' u hB hD)
          refine ⟨s₂' - (l : ℤ), (show w < s₂' - (l : ℤ) by omega), ?_, fun r h1 h2 => ?_⟩
          · rw [ihχ, delIdx_of_ge u l (s₂' - (l : ℤ)) (by omega),
              show s₂' - (l : ℤ) + (l : ℤ) = s₂' by ring]
            exact hχ₂
          · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
            have h1' : w < r' := h1
            have h2' : r' < s₂' - (l : ℤ) := h2
            rw [ihψ]
            by_cases hr : r' < u
            · rw [delIdx_of_lt u l r' hr]; exact hgd' r' h1' (by omega)
            · rw [delIdx_of_ge u l r' (by omega)]
              rcases lt_or_eq_of_le (show u ≤ r' by omega) with hr2 | hr2
              · exact hgd₂' (r' + (l : ℤ)) (by omega) (by omega)
              · rw [← hr2]; exact hψul
        · -- `s₀ = u`: `χ` at `u`, hence at `u + l` through `E(χ)`
          rw [← hD] at hχ
          refine ⟨u, hB, ?_, fun r h1 h2 => ?_⟩
          · rw [ihχ, delIdx_of_ge u l u le_rfl]; exact Eχ.mp hχ
          · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
            have h1' : w < r' := h1
            have h2' : r' < u := h2
            rw [ihψ, delIdx_of_lt u l r' h2']
            exact hgd' r' h1' (by omega)

/-- **The `since` clause, from the deleted history to the original.** -/
theorem snce_delIdx_mp (σ σ' : WorldHistory F.toTaskFrame) (u : ℤ) (l : ℕ)
    (ψ χ : PlusFormula)
    (ihψ : ∀ w : ℤ, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (delIdx u l w) ψ)
    (ihχ : ∀ w : ℤ, PlusTruthAt M σ' w χ ↔ PlusTruthAt M σ (delIdx u l w) χ)
    (ES : PlusTruthAt M σ u (.snce ψ χ) ↔ PlusTruthAt M σ (u + (l : ℤ)) (.snce ψ χ))
    (w : ℤ) (h : PlusTruthAt M σ' w (.snce ψ χ)) :
    PlusTruthAt M σ (delIdx u l w) (.snce ψ χ) := by
  rw [PlusTruth.snce_iff] at h ⊢
  obtain ⟨s, hs, hχ, hgd⟩ := h
  obtain ⟨s', rfl⟩ : ∃ s' : ℤ, s' = s := ⟨s, rfl⟩
  have hs' : s' < w := hs
  rw [ihχ s'] at hχ
  have hgd' : ∀ r : ℤ, s' < r → r < w → PlusTruthAt M σ (delIdx u l r) ψ :=
    fun r h1 h2 => (ihψ r).mp (hgd r h1 h2)
  by_cases hA : w < u
  · -- everything is before the block
    rw [delIdx_of_lt u l w hA]
    rw [delIdx_of_lt u l s' (by omega)] at hχ
    refine ⟨s', hs', hχ, fun r h1 h2 => ?_⟩
    obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
    have h1' : s' < r' := h1
    have h2' : r' < w := h2
    have := hgd' r' h1' h2'
    rwa [delIdx_of_lt u l r' (by omega)] at this
  · rw [not_lt] at hA
    rw [delIdx_of_ge u l w hA]
    by_cases hB : u ≤ s'
    · -- everything shifts by `l`
      rw [delIdx_of_ge u l s' hB] at hχ
      refine ⟨s' + (l : ℤ), (show s' + (l : ℤ) < w + (l : ℤ) by omega), hχ, fun r h1 h2 => ?_⟩
      obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : s' + (l : ℤ) < r' := h1
      have h2' : r' < w + (l : ℤ) := h2
      have := hgd' (r' - (l : ℤ)) (by omega) (by omega)
      rwa [delIdx_of_ge u l (r' - (l : ℤ)) (by omega),
        show r' - (l : ℤ) + (l : ℤ) = r' by ring] at this
    · rw [not_le] at hB
      rw [delIdx_of_lt u l s' hB] at hχ
      -- the block lies inside the guard interval: `ψ S χ` holds at `u`, hence at `u + l`
      have hSu : PlusTruthAt M σ u (.snce ψ χ) := by
        rw [PlusTruth.snce_iff]
        refine ⟨s', hB, hχ, fun r h1 h2 => ?_⟩
        obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : s' < r' := h1
        have h2' : r' < u := h2
        have := hgd' r' h1' (by omega)
        rwa [delIdx_of_lt u l r' h2'] at this
      have hSul := ES.mp hSu
      rw [PlusTruth.snce_iff] at hSul
      obtain ⟨s₂, hs₂, hχ₂, hgd₂⟩ := hSul
      obtain ⟨s₂', rfl⟩ : ∃ s₂' : ℤ, s₂' = s₂ := ⟨s₂, rfl⟩
      have hs₂' : s₂' < u + (l : ℤ) := hs₂
      have hgd₂' : ∀ r : ℤ, s₂' < r → r < u + (l : ℤ) → PlusTruthAt M σ r ψ := hgd₂
      refine ⟨s₂', (show s₂' < w + (l : ℤ) by omega), hχ₂, fun r h1 h2 => ?_⟩
      obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : s₂' < r' := h1
      have h2' : r' < w + (l : ℤ) := h2
      rcases lt_trichotomy r' (u + (l : ℤ)) with hr | hr | hr
      · exact hgd₂' r' h1' hr
      · rw [hr]
        have := hgd' u (by omega) (by omega)
        rwa [delIdx_of_ge u l u le_rfl] at this
      · have := hgd' (r' - (l : ℤ)) (by omega) (by omega)
        rwa [delIdx_of_ge u l (r' - (l : ℤ)) (by omega),
          show r' - (l : ℤ) + (l : ℤ) = r' by ring] at this

/-- **The `since` clause, from the original to the deleted history.** -/
theorem snce_delIdx_mpr (σ σ' : WorldHistory F.toTaskFrame) (u : ℤ) (l : ℕ)
    (ψ χ : PlusFormula)
    (ihψ : ∀ w : ℤ, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (delIdx u l w) ψ)
    (ihχ : ∀ w : ℤ, PlusTruthAt M σ' w χ ↔ PlusTruthAt M σ (delIdx u l w) χ)
    (ES : PlusTruthAt M σ u (.snce ψ χ) ↔ PlusTruthAt M σ (u + (l : ℤ)) (.snce ψ χ))
    (w : ℤ) (h : PlusTruthAt M σ (delIdx u l w) (.snce ψ χ)) :
    PlusTruthAt M σ' w (.snce ψ χ) := by
  rw [PlusTruth.snce_iff] at h ⊢
  obtain ⟨s, hs, hχ, hgd⟩ := h
  obtain ⟨s₀, rfl⟩ : ∃ s₀ : ℤ, s₀ = s := ⟨s, rfl⟩
  have hs₀ : s₀ < delIdx u l w := hs
  have hgd' : ∀ r : ℤ, s₀ < r → r < delIdx u l w → PlusTruthAt M σ r ψ := hgd
  by_cases hA : w < u
  · -- everything is before the block
    rw [delIdx_of_lt u l w hA] at hs₀ hgd'
    refine ⟨s₀, hs₀, ?_, fun r h1 h2 => ?_⟩
    · rw [ihχ, delIdx_of_lt u l s₀ (by omega)]; exact hχ
    · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
      have h1' : s₀ < r' := h1
      have h2' : r' < w := h2
      rw [ihψ, delIdx_of_lt u l r' (by omega)]
      exact hgd' r' h1' h2'
  · rw [not_lt] at hA
    rw [delIdx_of_ge u l w hA] at hs₀ hgd'
    by_cases hB : u + (l : ℤ) ≤ s₀
    · -- the witness is beyond the block: it shifts back by `l`
      refine ⟨s₀ - (l : ℤ), (show s₀ - (l : ℤ) < w by omega), ?_, fun r h1 h2 => ?_⟩
      · rw [ihχ, delIdx_of_ge u l (s₀ - (l : ℤ)) (by omega),
          show s₀ - (l : ℤ) + (l : ℤ) = s₀ by ring]
        exact hχ
      · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
        have h1' : s₀ - (l : ℤ) < r' := h1
        have h2' : r' < w := h2
        rw [ihψ, delIdx_of_ge u l r' (by omega)]
        exact hgd' (r' + (l : ℤ)) (by omega) (by omega)
    · rw [not_le] at hB
      by_cases hC : s₀ < u
      · -- the witness is before the block
        refine ⟨s₀, (show s₀ < w by omega), ?_, fun r h1 h2 => ?_⟩
        · rw [ihχ, delIdx_of_lt u l s₀ hC]; exact hχ
        · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : s₀ < r' := h1
          have h2' : r' < w := h2
          rw [ihψ]
          by_cases hr : r' < u
          · rw [delIdx_of_lt u l r' hr]; exact hgd' r' h1' (by omega)
          · rw [delIdx_of_ge u l r' (by omega)]; exact hgd' (r' + (l : ℤ)) (by omega) (by omega)
      · rw [not_lt] at hC
        -- the witness is inside the block: `ψ S χ` holds at `u + l`, hence at `u`
        have hSul : PlusTruthAt M σ (u + (l : ℤ)) (.snce ψ χ) := by
          rw [PlusTruth.snce_iff]
          refine ⟨s₀, hB, hχ, fun r h1 h2 => ?_⟩
          obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : s₀ < r' := h1
          have h2' : r' < u + (l : ℤ) := h2
          exact hgd' r' h1' (by omega)
        have hSu := ES.mpr hSul
        rw [PlusTruth.snce_iff] at hSu
        obtain ⟨s₂, hs₂, hχ₂, hgd₂⟩ := hSu
        obtain ⟨s₂', rfl⟩ : ∃ s₂' : ℤ, s₂' = s₂ := ⟨s₂, rfl⟩
        have hs₂' : s₂' < u := hs₂
        have hgd₂' : ∀ r : ℤ, s₂' < r → r < u → PlusTruthAt M σ r ψ := hgd₂
        refine ⟨s₂', (show s₂' < w by omega), ?_, fun r h1 h2 => ?_⟩
        · rw [ihχ, delIdx_of_lt u l s₂' hs₂']; exact hχ₂
        · obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
          have h1' : s₂' < r' := h1
          have h2' : r' < w := h2
          rw [ihψ]
          by_cases hr : r' < u
          · rw [delIdx_of_lt u l r' hr]; exact hgd₂' r' h1' hr
          · rw [delIdx_of_ge u l r' (by omega)]
            exact hgd' (r' + (l : ℤ)) (by omega) (by omega)

end DelTransport

section DelType

/-- **The pinned-letter transport along the deletion embedding**, at the truth level. -/
theorem plusTruthAt_iff_delIdx_of_tpOf_eq_of_stabPinned {Q : Type} [Finite Q] [Nonempty Q]
    {step : Q → Q → Bool} {pend : Q → Bool}
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (L : PlusFormula → Prop) (u : ℤ) (l : ℕ)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hobj : ∀ w : ℤ, objAt g' w = objAt g (delIdx u l w))
    (hL : ∀ χ : PlusFormula, L (PlusFormula.stab χ) → ∀ w : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ' w (PlusFormula.stab χ) ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ (delIdx u l w)
          (PlusFormula.stab χ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) :
    ∀ ψ : PlusFormula, ψ ∈ plusSubformulaClosure φ → StabPinned L ψ → ∀ w : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ' w ψ ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ (delIdx u l w) ψ) := by
  have E := endpoint_iff_of_tpOf_eq (ladderModel step pend fwd bwd lab) φ σ u l hty
  intro ψ
  induction ψ with
  | atom p =>
      intro _ _ w
      rw [PlusTruth.atom_iff, PlusTruth.atom_iff, hσ' w, hσ (delIdx u l w)]
      change lab (objAt g' w) p = true ↔ lab (objAt g (delIdx u l w)) p = true
      rw [hobj w]
  | bot => intro _ _ _; exact Iff.rfl
  | imp a b iha ihb =>
      intro hm h w
      exact imp_congr (iha (plusClosure_imp_left φ a b hm) h.1 w)
        (ihb (plusClosure_imp_right φ a b hm) h.2 w)
  | box a _ =>
      intro hm _ w
      have h1 := mem_tpOf_iff (ladderModel step pend fwd bwd lab) φ σ' w (.box a)
      have h2 := mem_tpOf_iff (ladderModel step pend fwd bwd lab) φ σ (delIdx u l w) (.box a)
      have ht := box_mem_tpOf_transfer (ladderModel step pend fwd bwd lab) φ σ' σ w
        (delIdx u l w) hm
      constructor
      · intro h; exact (h2.mp (ht.mp (h1.mpr ⟨hm, h⟩))).2
      · intro h; exact (h1.mp (ht.mpr (h2.mpr ⟨hm, h⟩))).2
  | untl a b iha ihb =>
      intro hm h w
      have hma := plusClosure_untl_right φ b a hm
      have hmb := plusClosure_untl_left φ b a hm
      exact ⟨untl_delIdx_mp _ σ σ' u l a b (iha hma h.1) (ihb hmb h.2) (E a hma) (E b hmb)
          (E _ hm) w,
        untl_delIdx_mpr _ σ σ' u l a b (iha hma h.1) (ihb hmb h.2) (E a hma) (E b hmb)
          (E _ hm) w⟩
  | snce a b iha ihb =>
      intro hm h w
      have hma := plusClosure_snce_right φ b a hm
      have hmb := plusClosure_snce_left φ b a hm
      exact ⟨snce_delIdx_mp _ σ σ' u l a b (iha hma h.1) (ihb hmb h.2) (E _ hm) w,
        snce_delIdx_mpr _ σ σ' u l a b (iha hma h.1) (ihb hmb h.2) (E _ hm) w⟩
  | stab a _ => intro _ h w; exact hL a h w

-- `linter.unusedVariables` and `linter.unusedFintypeInType`, scoped to this declaration. The
-- signature is pinned by the plan's Lean Challenge Statements block: `hl : 0 < l` is carried in
-- step with `exists_deleted_ladderPath_of_pend_past` (the lemma holds for `l = 0` as well, where
-- the embedding is the identity, so the proof does not read it), and `[Fintype Q]` is the
-- block's instance binder where `ladderModel` reads only the `Finite Q` it implies.
set_option linter.unusedVariables false in
set_option linter.unusedFintypeInType false in
/-- **THE DELETION TYPE LEMMA**, HWZ 2000 Lemma 17 over `ℤ`: deleting a block whose two ends
carry the same realized stab-free type preserves the realized type at EVERY position, read
through the monotone embedding — the stab-free instance of the pinned-letter transport. Needs
no pending-region hypothesis, no `ParamsOk` and no pin condition; the admissibility side
`exists_deleted_ladderPath_of_pend_past` is where the pins enter. -/
theorem tpOf_eq_delIdx_of_tpOf_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (u : ℤ) (l : ℕ) (hl : 0 < l)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t))
    (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hobj : ∀ w : ℤ, objAt g' w = objAt g (delIdx u l w))
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) :
    ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
      = tpOf (ladderModel step pend fwd bwd lab) φ σ (delIdx u l w) := by
  intro w
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  exact and_congr_right fun hmem =>
    plusTruthAt_iff_delIdx_of_tpOf_eq_of_stabPinned fwd bwd lab φ (fun _ => False) u l σ σ'
      hσ hσ' hobj (fun _ h => absurd h (fun h => h)) hty ψ hmem
      (stabPinned_false_of_mem_closure hno ψ hmem) w

end DelType

/-! ## The forward window of the register

The mirror of the landed backward window `cntAt_le_nxtAt_succ_of_idle_past`. The register at a
pending position is read FORWARD by the cell through the next region's pin: at the first idle
position after the region the register's value is the countdown of the region that follows
(`cntAt_eq_nxtAt_of_idle_pend`), and the register is `1`-Lipschitz, so the register at `z` is at
most the countdown there plus the length of the next idle run plus the countdown at the next
region's start. This is the quantity `(K4)`'s forward conjunct must dominate, and the quantity the
wired probe `ladder-cell-obligation-refutation.lean` pins with a `U`-only formula. -/

section Window

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE FORWARD WINDOW.** With the next idle run of length `I` starting right after `z`'s
region and the next region starting after it, the register at `z` is at most
`cntAt g z + I + cntAt g (start of the next region)`. -/
theorem nxtAt_le_cntAt_add_of_next_region
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (I : ℕ)
    (hI : 0 < I)
    (hidle : ∀ i : ℕ, i < I →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false)
    (hnext : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true) :
    nxtAt g z ≤ cntAt g z + I + cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) := by
  -- the last idle position before the next region, and its pin
  have h0 : pend (objAt g (z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ))) = false :=
    hidle (I - 1) (by omega)
  have h1 : pend (objAt g (z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ) + 1
        = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring]
    exact hnext
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg _ h0 h1
  rw [show z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ) + 1
      = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring]
    at hpin
  -- the register is `1`-Lipschitz over the `cntAt g z + I` steps from `z` to that idle position
  have hlip := nxtAt_lipschitz g hg z (cntAt g z + I)
  rw [show z + ((cntAt g z + I : ℕ) : ℤ) = z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ) by
    push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring] at hlip
  omega

end Window

/-! ## The `(objAt, tpOf)` pigeonhole, and the iterated duplication

A region of countdown at least the budget `|Q| · 2^|cl φ|` (written out, never through the
certificate layer's product carrier) carries a type-respecting block of length at most the
budget; iterating its duplication `d` times raises every countdown before the block by `d · l`
and preserves the realized type there, by `tpOf_eq_spliceIdx_of_tpOf_eq` at each step. -/

section Pigeonhole

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE TYPE PIGEONHOLE, with the block's position recorded**: the block lies within the first
`budget + 1` positions of `z`'s region. -/
theorem exists_typeBlock_of_budget_le_cnt_within
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hg : IsLadderPath step pend g) (z : ℤ) (hz : pend (objAt g z) = true)
    (hbud : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ≤ cntAt g z) :
    ∃ (u : ℤ) (l : ℕ), 0 < l ∧
      l ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      z ≤ u ∧ l ≤ cntAt g u ∧
      u + (l : ℤ) ≤ z + (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card : ℕ) ∧
      objAt g u = objAt g (u + (l : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ)) := by
  classical
  set b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card with hb
  let f : Fin (b + 1) → Q × {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset} :=
    fun i => (objAt g (z + ((i : ℕ) : ℤ)),
      ⟨tpOf (ladderModel step pend fwd bwd lab) φ σ (z + ((i : ℕ) : ℤ)),
        Finset.mem_powerset.mpr (tpOf_subset _ φ σ _)⟩)
  obtain ⟨a, c, hac, hf⟩ := Fintype.exists_ne_map_eq_of_card_lt f (by
    rw [Fintype.card_prod, Fintype.card_coe, Finset.card_powerset, Fintype.card_fin]
    omega)
  have hf' : f a = f c := hf
  simp only [f, Prod.mk.injEq, Subtype.mk.injEq] at hf'
  obtain ⟨hobj, hty⟩ := hf'
  have ha : (a : ℕ) ≤ b := by omega
  have hc : (c : ℕ) ≤ b := by omega
  rcases lt_or_gt_of_ne (fun h : (a : ℕ) = (c : ℕ) => hac (Fin.ext h)) with hlt | hlt
  · have hcast : z + ((a : ℕ) : ℤ) + (((c : ℕ) - (a : ℕ) : ℕ) : ℤ) = z + ((c : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    refine ⟨z + ((a : ℕ) : ℤ), (c : ℕ) - (a : ℕ), by omega, by omega, by omega, ?_,
      by rw [hcast]; omega, ?_, ?_⟩
    · have := (cntAt_sub_of_pend g hg z hz (a : ℕ) (by omega)).2
      omega
    · rw [hcast]; exact hobj
    · rw [hcast]; exact hty
  · have hcast : z + ((c : ℕ) : ℤ) + (((a : ℕ) - (c : ℕ) : ℕ) : ℤ) = z + ((a : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    refine ⟨z + ((c : ℕ) : ℤ), (a : ℕ) - (c : ℕ), by omega, by omega, by omega, ?_,
      by rw [hcast]; omega, ?_, ?_⟩
    · have := (cntAt_sub_of_pend g hg z hz (c : ℕ) (by omega)).2
      omega
    · rw [hcast]; exact hobj.symm
    · rw [hcast]; exact hty.symm

-- `linter.unusedVariables`, scoped to this declaration: the signature is pinned by the plan's
-- Lean Challenge Statements block, and `hσ` (the history's offset) is not read — the pigeonhole
-- is a statement about one history's types along the walk, whatever its offset.
set_option linter.unusedVariables false in
/-- **THE TYPE PIGEONHOLE.** A region of countdown at least the budget carries a type-respecting
block of length at most the budget, at or after the chosen position. -/
theorem exists_typeBlock_of_budget_le_cnt
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    {k : ℤ} {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t))
    (hg : IsLadderPath step pend g) (z : ℤ) (hz : pend (objAt g z) = true)
    (hbud : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ≤ cntAt g z) :
    ∃ (u : ℤ) (l : ℕ), 0 < l ∧
      l ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      z ≤ u ∧ l ≤ cntAt g u ∧
      objAt g u = objAt g (u + (l : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ)) := by
  obtain ⟨u, l, hl, hlb, hzu, hcl, -, hrep, hty⟩ :=
    exists_typeBlock_of_budget_le_cnt_within step pend fwd bwd lab φ σ hg z hz hbud
  exact ⟨u, l, hl, hlb, hzu, hcl, hrep, hty⟩

end Pigeonhole

section Iterate

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE ITERATED DUPLICATION.** `d` duplications of a type-respecting block `[u, u + l)` of a
pending-forever region: the walk agrees with the original before `u + l`, carries `objAt g u`
at `u + l`, every countdown before the block whose region reaches it is raised by `d · l`, the
`d + 1` copies are pending, the walk from `u + (d + 1) l` on is the original `d · l` earlier,
and the realized type is the original's before `u + l` (and `u`'s at `u + l`). -/
theorem exists_iterSpliced_ladderPath_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u)
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, v < u + (l : ℤ) → objAt g' v = objAt g v) ∧
      objAt g' (u + (l : ℤ)) = objAt g u ∧
      (∀ v : ℤ, v ≤ u → u ≤ v + (cntAt g v : ℤ) → cntAt g' v = cntAt g v + d * l) ∧
      (∀ v : ℤ, u ≤ v → v < u + ((d + 1) * l : ℕ) → pend (objAt g' v) = true) ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v →
        objAt g' v = objAt g (v - (d * l : ℕ)) ∧ cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        (∀ w : ℤ, w < u + (l : ℤ) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' w
            = tpOf (ladderModel step pend fwd bwd lab) φ σ w) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ' (u + (l : ℤ))
          = tpOf (ladderModel step pend fwd bwd lab) φ σ u := by
  have hpu : pend (objAt g u) = true := hpast u le_rfl
  induction d with
  | zero =>
      refine ⟨g, hg, fun _ _ => rfl, hrep.symm, fun v _ _ => by simp, fun v hv1 hv2 => ?_,
        fun v _ => by simp, fun σ' hσ' => ?_⟩
      · have := (cntAt_sub_of_pend g hg u hpu (v - u).toNat (by
          have : v < u + (l : ℤ) := by simpa using hv2
          omega)).1
        rwa [show u + (((v - u).toNat : ℕ) : ℤ) = v by omega] at this
      have hsame : ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ w := fun w =>
        tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ
          (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
          (fun _ => rfl) hno w
      exact ⟨fun w _ => hsame w, by rw [hsame, hty]⟩
  | succ d ih =>
      obtain ⟨g₁, hg₁, hobj₁, hend₁, hcnt₁, hpend₁, habove₁, hty₁⟩ := ih
      have e1 : (((d + 1) * l : ℕ) : ℤ) = (d : ℤ) * l + l := by push_cast; ring
      have e2 : (((d + 1 + 1) * l : ℕ) : ℤ) = (d : ℤ) * l + l + l := by push_cast; ring
      -- the block of `g₁` is still type-respecting, pending-forever below, and inside its region
      have hpast₁ : ∀ p : ℤ, p ≤ u → pend (objAt g₁ p) = true := fun p hp => by
        rw [hobj₁ p (by omega)]; exact hpast p hp
      have hrep₁ : objAt g₁ u = objAt g₁ (u + (l : ℤ)) := by
        rw [hobj₁ u (by omega), hend₁]
      have hcu₁ : cntAt g₁ u = cntAt g u + d * l := hcnt₁ u le_rfl (by omega)
      have hcl₁ : l ≤ cntAt g₁ u := by rw [hcu₁]; omega
      obtain ⟨g₂, hg₂, hobj₂, hcnt₂⟩ :=
        exists_spliced_ladderPath_of_pend_past hg₁ hl hcl₁ hpast₁ hrep₁
      refine ⟨g₂, hg₂, fun v hv => ?_, ?_, fun v hv hreg => ?_, fun v hv1 hv2 => ?_,
        fun v hv => ?_, fun σ₂ hσ₂ => ?_⟩
      · rw [hobj₂ v, spliceObj_of_lt v hv, hobj₁ v hv]
      · rw [hobj₂ (u + (l : ℤ)), spliceObj_of_ge (u + (l : ℤ)) le_rfl,
          show u + (l : ℤ) - (l : ℤ) = u by ring, hobj₁ u (by omega)]
      · have hreg₁ : u ≤ v + (cntAt g₁ v : ℤ) := by rw [hcnt₁ v hv hreg]; push_cast; omega
        rw [hcnt₂ v, spliceCnt_add_of_mem_region hl v hv hreg₁, hcnt₁ v hv hreg]
        ring
      · -- the copies are pending
        have hv2' : v < u + ((d + 1 + 1) * l : ℕ) := hv2
        rw [e2] at hv2'
        rw [hobj₂ v]
        by_cases hvl : v < u + (l : ℤ)
        · rw [spliceObj_of_lt v hvl]
          exact hpend₁ v hv1 (by rw [e1]; omega)
        · rw [spliceObj_of_ge v (by omega)]
          exact hpend₁ (v - (l : ℤ)) (by omega) (by rw [e1]; omega)
      · -- above the copies the walk is the original, `(d + 1) · l` earlier
        have hv' : u + ((d + 1 + 1) * l : ℕ) ≤ v := hv
        rw [e2] at hv'
        have hge : u + ((d + 1) * l : ℕ) ≤ v - (l : ℤ) := by rw [e1]; omega
        obtain ⟨ho, hc⟩ := habove₁ (v - (l : ℤ)) hge
        refine ⟨?_, ?_⟩
        · rw [hobj₂ v, spliceObj_of_ge v (by omega), ho]
          congr 1; push_cast; ring
        · rw [hcnt₂ v, spliceCnt_of_ge v (by omega), hc]
          congr 1; push_cast; ring
      · obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
        obtain ⟨hlt₁, hend_ty₁⟩ := hty₁ σ₁ hσ₁
        have hty₁' : tpOf (ladderModel step pend fwd bwd lab) φ σ₁ u
            = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (u + (l : ℤ)) := by
          rw [hlt₁ u (by omega), hend_ty₁]
        have hobj₂' : ∀ w : ℤ, objAt g₂ w = objAt g₁ (spliceIdx u l w) := fun w => by
          rw [hobj₂ w, spliceObj_eq_objAt_spliceIdx]
        have htr : ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ₂ w
            = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (spliceIdx u l w) := fun w => by
          ext ψ
          rw [mem_tpOf_iff, mem_tpOf_iff]
          exact and_congr_right fun hmem =>
            plusTruthAt_iff_spliceIdx_of_tpOf_eq_of_stabPinned fwd bwd lab φ (fun _ => False) u l
              (k := 0) (k' := 0) σ₁ σ₂ (fun t => by rw [add_zero]; exact hσ₁ t)
              (fun t => by rw [add_zero]; exact hσ₂ t) hobj₂' (fun _ h => absurd h (fun h => h))
              hty₁' ψ hmem (stabPinned_false_of_mem_closure hno ψ hmem) w
        refine ⟨fun w hw => ?_, ?_⟩
        · rw [htr w, spliceIdx_of_lt u l w hw, hlt₁ w hw]
        · rw [htr (u + (l : ℤ)), spliceIdx_of_ge u l (u + (l : ℤ)) le_rfl,
            show u + (l : ℤ) - (l : ℤ) = u by ring, hlt₁ u (by omega)]

end Iterate

/-! ## The idle mirror: idle cycles, and the run bound without one

`objCycleLens` (`CounterQuotient.lean`) collects the cycle lengths of the object's own PENDING
graph, which is what a long pending region forces. The idle mirror is what a long idle RUN
forces, and it is the premise the idle-gap lengthening needs. A ladder path's object walk steps
along `step` at every position (`objAt_step`), so an idle run of length two already requires an
idle-to-idle edge: `no_consecutive_idle_of_no_idle_step` is the generic reading of that
obstruction, promoted here out of the decision gate's prototype. `idleCycleLens_of_idle_segment`
and `exists_idleCycle_of_card_le_run` are the two halves of the pigeonhole that turns a long
enough idle run into an idle cycle, and `idle_run_lt_tIdle_of_no_idleCycle` is the NECESSITY
direction: without an idle cycle every idle run is shorter than `tIdle pend`. That direction is
what makes the idle-cycle premise the right one rather than an arbitrary strengthening.

The binders are written out declaration by declaration rather than taken from a `variable`
block, because `no_consecutive_idle_of_no_idle_step` reads no `Fintype Q` and an included
section instance would add a hypothesis its statement does not need. -/

section IdleCycle

/-- **Cycle lengths among the IDLE object states**: the mirror of `objCycleLens`, with
`pend (f i) = false` in place of `pend (f i) = true`. A member of this set is a closed walk of
the object's step graph that never leaves the idle states — exactly what duplicating a block of
an idle run forces the walk to traverse. -/
def idleCycleLens {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool) : Set ℕ :=
  {l | 0 < l ∧ l ≤ Fintype.card Q ∧
    ∃ f : ℕ → Q, (∀ i, step (f i) (f (i + 1)) = true) ∧ (∀ i, pend (f i) = false) ∧ f l = f 0}

/-- **AN IDLE RUN OF LENGTH TWO NEEDS AN IDLE-TO-IDLE EDGE.** The whole content of the idle-gap
lengthening's FAIL verdict, stated once and generically: the object walk of a ladder path steps
along `step` at every position, so an object with no idle-to-idle edge forces every idle position
to be followed by a pending one. The idle run's length is therefore a datum of the object's step
graph, not a parameter a construction may raise. -/
theorem no_consecutive_idle_of_no_idle_step {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (hstep : ∀ x y : Q, pend x = false → pend y = false → step x y = false)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (v : ℤ)
    (h0 : pend (objAt g v) = false) : pend (objAt g (v + 1)) = true := by
  by_contra h
  rw [Bool.not_eq_true] at h
  have hs := objAt_step g hg v
  rw [hstep _ _ h0 h] at hs
  exact Bool.false_ne_true hs

/-- **A repeated object state inside an idle run yields an idle cycle.** The periodic walk
`j ↦ objAt g (a + (j % k))` steps along `step`, is idle throughout because the whole block lies
inside the run, and closes up at `k` because the two ends agree. The mirror of
`objCycleLens_of_segment` (`LadderAgree.lean`), with the block's idleness supplied directly
rather than read off `cntAt_sub_of_pend`. -/
theorem idleCycleLens_of_idle_segment {Q : Type} [Fintype Q] {step : Q → Q → Bool}
    {pend : Q → Bool} (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (a : ℤ) (k : ℕ) (hk : 0 < k) (hcard : k ≤ Fintype.card Q)
    (hidle : ∀ i : ℕ, i < k → pend (objAt g (a + (i : ℤ))) = false)
    (hrep : objAt g a = objAt g (a + (k : ℤ))) :
    k ∈ idleCycleLens step pend := by
  refine ⟨hk, hcard, fun j => objAt g (a + ((j % k : ℕ) : ℤ)), ?_, ?_, ?_⟩
  · intro j
    dsimp only
    have hmod : j % k < k := Nat.mod_lt _ hk
    have hs : (j + 1) % k = (j % k + 1) % k := (Nat.mod_add_mod j k 1).symm
    by_cases hlast : j % k + 1 = k
    · -- the wrap-around step: the block's last position steps to the block's first
      have hj1 : (j + 1) % k = 0 := by rw [hs, hlast, Nat.mod_self]
      have hstep := objAt_step g hg (a + ((j % k : ℕ) : ℤ))
      have hcast : ((j % k : ℕ) : ℤ) + 1 = (k : ℤ) := by exact_mod_cast hlast
      rw [show a + ((j % k : ℕ) : ℤ) + 1 = a + (k : ℤ) by rw [← hcast]; ring] at hstep
      rw [hj1, Nat.cast_zero, add_zero, hrep]
      exact hstep
    · -- an interior step of the block
      have hj1 : (j + 1) % k = j % k + 1 := by
        rw [hs, Nat.mod_eq_of_lt (by omega)]
      have hstep := objAt_step g hg (a + ((j % k : ℕ) : ℤ))
      rw [hj1, show ((j % k + 1 : ℕ) : ℤ) = ((j % k : ℕ) : ℤ) + 1 by push_cast; ring,
        ← add_assoc]
      exact hstep
  · intro j
    exact hidle (j % k) (Nat.mod_lt _ hk)
  · dsimp only
    rw [Nat.mod_self, Nat.zero_mod]

/-- **AN IDLE RUN AT LEAST AS LONG AS THE IDLE-STATE COUNT CARRIES AN IDLE CYCLE.** The
pigeonhole on the `m + 1` positions `z, …, z + m` of the run, where `m` is the number of idle
object states: all of them are idle, so they land in the idle states, and two must agree. The
mirror of `exists_objCycle_of_card_le_cnt`, with the pigeonhole taken over the idle-state count
rather than `Fintype.card Q`. -/
theorem exists_idleCycle_of_card_le_run {Q : Type} [Fintype Q] {step : Q → Q → Bool}
    {pend : Q → Bool} (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) (L : ℕ)
    (hrun : ∀ i : ℕ, i ≤ L → pend (objAt g (z + (i : ℤ))) = false)
    (hlen : (Finset.univ.filter (fun q : Q => pend q = false)).card ≤ L) :
    ∃ i k : ℕ, 0 < k ∧ k ≤ (Finset.univ.filter (fun q : Q => pend q = false)).card ∧
      i + k ≤ L ∧
      objAt g (z + (i : ℤ)) = objAt g (z + (i : ℤ) + (k : ℤ)) ∧
      k ∈ idleCycleLens step pend := by
  classical
  set m := (Finset.univ.filter (fun q : Q => pend q = false)).card with hm
  have hmQ : m ≤ Fintype.card Q := by
    rw [hm]
    simpa using Finset.card_filter_le (Finset.univ : Finset Q) (fun q => pend q = false)
  obtain ⟨x, hx, y, hy, hxy, hfe⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to
      (s := Finset.range (m + 1))
      (t := Finset.univ.filter (fun q : Q => pend q = false))
      (by rw [Finset.card_range]; omega)
      (f := fun j : ℕ => objAt g (z + (j : ℤ)))
      (fun j hj => Finset.mem_filter.mpr ⟨Finset.mem_univ _,
        hrun j (by simp only [Finset.mem_coe, Finset.mem_range] at hj; omega)⟩)
  rw [Finset.mem_range] at hx hy
  rcases lt_or_gt_of_ne hxy with hlt | hlt
  · have hcast : z + (x : ℤ) + ((y - x : ℕ) : ℤ) = z + (y : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    refine ⟨x, y - x, by omega, by omega, by omega, by rw [hcast]; exact hfe, ?_⟩
    exact idleCycleLens_of_idle_segment g hg (z + (x : ℤ)) (y - x) (by omega) (by omega)
      (fun i hi => by
        rw [show z + (x : ℤ) + (i : ℤ) = z + ((x + i : ℕ) : ℤ) by push_cast; ring]
        exact hrun (x + i) (by omega))
      (by rw [hcast]; exact hfe)
  · have hcast : z + (y : ℤ) + ((x - y : ℕ) : ℤ) = z + (x : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    refine ⟨y, x - y, by omega, by omega, by omega, by rw [hcast]; exact hfe.symm, ?_⟩
    exact idleCycleLens_of_idle_segment g hg (z + (y : ℤ)) (x - y) (by omega) (by omega)
      (fun i hi => by
        rw [show z + (y : ℤ) + (i : ℤ) = z + ((y + i : ℕ) : ℤ) by push_cast; ring]
        exact hrun (y + i) (by omega))
      (by rw [hcast]; exact hfe.symm)

/-- **WITHOUT AN IDLE CYCLE EVERY IDLE RUN IS SHORTER THAN `tIdle pend`.** The contraposition of
`exists_idleCycle_of_card_le_run`, read against `tIdle`'s own shape — `tIdle pend` IS the
idle-state count plus one (`CounterQuotient.lean`), so a run of length `tIdle pend` or more is
exactly a run long enough for the pigeonhole to fire. This is the direction that makes the
idle-cycle premise the RIGHT premise for the lengthening: an object with no idle cycle admits no
idle run long enough to duplicate, so nothing weaker than an idle cycle will do. -/
theorem idle_run_lt_tIdle_of_no_idleCycle {Q : Type} [Fintype Q] {step : Q → Q → Bool}
    {pend : Q → Bool} (hno : idleCycleLens step pend = ∅)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (L : ℕ)
    (hrun : ∀ i : ℕ, i ≤ L → pend (objAt g (z + (i : ℤ))) = false) :
    L < tIdle pend := by
  by_contra hcon
  rw [Nat.not_lt] at hcon
  have hlen : (Finset.univ.filter (fun q : Q => pend q = false)).card ≤ L := by
    unfold tIdle at hcon
    omega
  obtain ⟨-, k, -, -, -, -, hmem⟩ := exists_idleCycle_of_card_le_run g hg z L hrun hlen
  rw [hno] at hmem
  exact hmem

end IdleCycle

/-! ## The idle-block splice: the countdown it forces, and its FREE pin clause

Duplicating a block of an IDLE run is the same index-map surgery as duplicating a block of a
pending region, and the object half transfers verbatim: `spliceObj_step` (`LadderAgree.lean`)
needs only the endpoint repeat `objAt g a = objAt g (a + l)` and no `pend` hypothesis at all, so
`spliceObj` is reused here unchanged.

`spliceCnt` is NOT reusable. Its below-the-seam clause raises the countdown by `l` at every
position whose region REACHES `a` — and at an in-block position `v` that condition
`a ≤ v + cntAt g v` holds vacuously, because `v` is idle and so carries `cntAt g v = 0` while
`a ≤ v`. It would therefore return `l` where an idle position is forced to carry `0`.
`idleSpliceCnt` is the correct countdown: unchanged below the block's upper end, and the
original's `l` positions earlier from there on. Nothing is raised anywhere, because duplicating
an idle block lengthens no region.

The payoff is the pin clause. For the pending splice it is a genuine SIDE CONDITION, carried by
`exists_spliced_ladderPath` and discharged only in the pending-forever regime: lengthening one
region by `l` raises that region's pin by `l` while leaving every earlier region start where it
is. For an idle block it is FREE, and `idleSplice_pins` discharges it outright with no regime
hypothesis. The reason is the classification `idleSplice_pull` records: the duplicated block
contributes no pin of its own (both `a + l - 1` and `a + l` are idle, the latter reading
`objAt g a`), so every pin of the spliced walk is a pin of the original — at its own position
below the block and `l` positions lower above it, with its countdown UNCHANGED. The upper pins
therefore move farther from the lower ones while their values stay put, which is exactly the
direction the FAIL verdict's own docstring predicted would loosen. -/

section IdleSplice

/-- The countdown the idle-block-duplicated walk forces: unchanged below the block's upper end,
and the original's `l` positions earlier from there on. NOT `spliceCnt`, whose region-raise
clause fires vacuously at an in-block position and returns `l` where `0` is forced. -/
def idleSpliceCnt {Q : Type} {pend : Q → Bool} (g : ℤ → LadderState Q pend) (a : ℤ) (l : ℕ) :
    ℤ → ℕ :=
  fun v => if v < a + (l : ℤ) then cntAt g v else cntAt g (v - (l : ℤ))

section Inputs

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool} {g : ℤ → LadderState Q pend}
  {a : ℤ} {l : ℕ}

theorem idleSpliceCnt_of_lt (v : ℤ) (h : v < a + (l : ℤ)) :
    idleSpliceCnt g a l v = cntAt g v := by
  simp only [idleSpliceCnt, if_pos h]

theorem idleSpliceCnt_of_ge (v : ℤ) (h : a + (l : ℤ) ≤ v) :
    idleSpliceCnt g a l v = cntAt g (v - (l : ℤ)) := by
  simp only [idleSpliceCnt, if_neg (by omega : ¬ v < a + (l : ℤ))]

/-- **The idle-spliced countdown is idle-zero**: the first local reading of `Count`. Both
position cases read an idle position of the ORIGINAL, so `cntAt_eq_zero_of_idle` closes each. -/
theorem idleSpliceCnt_idle (hg : IsLadderPath step pend g) (v : ℤ)
    (h : pend (spliceObj g a l v) = false) : idleSpliceCnt g a l v = 0 := by
  rcases lt_or_ge v (a + (l : ℤ)) with hv | hv
  · rw [spliceObj_of_lt v hv] at h
    rw [idleSpliceCnt_of_lt v hv]
    exact cntAt_eq_zero_of_idle g hg v h
  · rw [spliceObj_of_ge v hv] at h
    rw [idleSpliceCnt_of_ge v hv]
    exact cntAt_eq_zero_of_idle g hg _ h

/-- **The idle-spliced countdown counts down inside a region**: the second local reading of
`Count`. The seam case `v + 1 = a + l` is VACUOUS: `spliceObj g a l v = objAt g (a + l - 1)` is
idle because the block is, so the hypothesis `pend (spliceObj g a l v) = true` is unsatisfiable
there. -/
theorem idleSpliceCnt_pend_pend (hg : IsLadderPath step pend g) (hl : 0 < l)
    (hidle : ∀ i : ℕ, i < l → pend (objAt g (a + (i : ℤ))) = false)
    (v : ℤ) (hx : pend (spliceObj g a l v) = true)
    (hy : pend (spliceObj g a l (v + 1)) = true) :
    idleSpliceCnt g a l (v + 1) + 1 = idleSpliceCnt g a l v := by
  rcases lt_trichotomy (v + 1) (a + (l : ℤ)) with hv | hv | hv
  · rw [spliceObj_of_lt v (by omega)] at hx
    rw [spliceObj_of_lt (v + 1) hv] at hy
    rw [idleSpliceCnt_of_lt v (by omega), idleSpliceCnt_of_lt (v + 1) hv]
    exact cntAt_succ_of_pend_pend g hg v hx hy
  · -- the seam: `v` is the block's last position, which is idle
    exfalso
    rw [spliceObj_of_lt v (by omega)] at hx
    have hb := hidle (l - 1) (by omega)
    rw [show a + (((l - 1 : ℕ)) : ℤ) = v by
      rw [Nat.cast_sub (by omega : 1 ≤ l), Nat.cast_one]; omega] at hb
    exact Bool.false_ne_true (hb.symm.trans hx)
  · have hge : a + (l : ℤ) ≤ v := by omega
    rw [spliceObj_of_ge v hge] at hx
    rw [spliceObj_of_ge (v + 1) (by omega),
      show v + 1 - (l : ℤ) = v - (l : ℤ) + 1 by ring] at hy
    rw [idleSpliceCnt_of_ge v hge, idleSpliceCnt_of_ge (v + 1) (by omega),
      show v + 1 - (l : ℤ) = v - (l : ℤ) + 1 by ring]
    exact cntAt_succ_of_pend_pend g hg (v - (l : ℤ)) hx hy

/-- **The idle-spliced countdown is exhausted at a region end**: the third local reading of
`Count`. The seam case is vacuous for the same reason as in `idleSpliceCnt_pend_pend`. -/
theorem idleSpliceCnt_pend_idle (hg : IsLadderPath step pend g) (hl : 0 < l)
    (hidle : ∀ i : ℕ, i < l → pend (objAt g (a + (i : ℤ))) = false)
    (v : ℤ) (hx : pend (spliceObj g a l v) = true)
    (hy : pend (spliceObj g a l (v + 1)) = false) :
    idleSpliceCnt g a l v = 0 := by
  rcases lt_trichotomy (v + 1) (a + (l : ℤ)) with hv | hv | hv
  · rw [spliceObj_of_lt v (by omega)] at hx
    rw [spliceObj_of_lt (v + 1) hv] at hy
    rw [idleSpliceCnt_of_lt v (by omega)]
    exact (cntAt_eq_zero_of_pend_idle g hg v hx hy).1
  · exfalso
    rw [spliceObj_of_lt v (by omega)] at hx
    have hb := hidle (l - 1) (by omega)
    rw [show a + (((l - 1 : ℕ)) : ℤ) = v by
      rw [Nat.cast_sub (by omega : 1 ≤ l), Nat.cast_one]; omega] at hb
    exact Bool.false_ne_true (hb.symm.trans hx)
  · have hge : a + (l : ℤ) ≤ v := by omega
    rw [spliceObj_of_ge v hge] at hx
    rw [spliceObj_of_ge (v + 1) (by omega),
      show v + 1 - (l : ℤ) = v - (l : ℤ) + 1 by ring] at hy
    rw [idleSpliceCnt_of_ge v hge]
    exact (cntAt_eq_zero_of_pend_idle g hg (v - (l : ℤ)) hx hy).1

/-- **EVERY PIN OF THE IDLE-SPLICED WALK IS A PIN OF THE ORIGINAL, WITH ITS COUNTDOWN
UNCHANGED.** The duplicated block contributes no pin: the position `a + l - 1` is idle because
the block is, and `a + l` reads `objAt g a`, which is idle for the same reason, so the seam is an
idle-to-idle transition and not a region start. Every other pin is the original's — at its own
position strictly below `a - 1`, or `l` positions lower at or above `a + l`. The two classes are
separated by the whole block, which is what makes the pin clause free. The classification reads
`spliceObj` and the block's idleness alone and consumes no `IsLadderPath` hypothesis. -/
theorem idleSplice_pull (hl : 0 < l)
    (hidle : ∀ i : ℕ, i < l → pend (objAt g (a + (i : ℤ))) = false)
    (s : ℤ) (h0 : pend (spliceObj g a l s) = false)
    (h1 : pend (spliceObj g a l (s + 1)) = true) :
    ∃ t : ℤ, pend (objAt g t) = false ∧ pend (objAt g (t + 1)) = true ∧
      idleSpliceCnt g a l (s + 1) = cntAt g (t + 1) ∧
      ((t = s ∧ s + 1 ≤ a - 1) ∨ (t = s - (l : ℤ) ∧ a ≤ t)) := by
  rcases lt_trichotomy (s + 1) (a + (l : ℤ)) with hs | hs | hs
  · rw [spliceObj_of_lt s (by omega)] at h0
    rw [spliceObj_of_lt (s + 1) hs] at h1
    have hb : s + 1 ≤ a - 1 := by
      by_contra hcon
      have hin := hidle (s + 1 - a).toNat (by omega)
      rw [show a + (((s + 1 - a).toNat : ℕ) : ℤ) = s + 1 by omega] at hin
      exact Bool.false_ne_true (hin.symm.trans h1)
    exact ⟨s, h0, h1, idleSpliceCnt_of_lt (s + 1) hs, Or.inl ⟨rfl, hb⟩⟩
  · exfalso
    rw [spliceObj_of_ge (s + 1) (by omega), show s + 1 - (l : ℤ) = a by omega] at h1
    have hin := hidle 0 hl
    rw [Nat.cast_zero, add_zero] at hin
    exact Bool.false_ne_true (hin.symm.trans h1)
  · have hge : a + (l : ℤ) ≤ s := by omega
    rw [spliceObj_of_ge s hge] at h0
    rw [spliceObj_of_ge (s + 1) (by omega),
      show s + 1 - (l : ℤ) = s - (l : ℤ) + 1 by ring] at h1
    refine ⟨s - (l : ℤ), h0, h1, ?_, Or.inr ⟨rfl, by omega⟩⟩
    rw [idleSpliceCnt_of_ge (s + 1) (by omega),
      show s + 1 - (l : ℤ) = s - (l : ℤ) + 1 by ring]

/-- **THE PIN CLAUSE OF THE IDLE SPLICE IS FREE.** Unconditionally — no regime hypothesis, no
`ParamsOk`, no side condition carried to the caller. The three cases of `idleSplice_pull`'s
classification: both pins below the block (the original's own compatibility,
`pinCompat_of_ladderPath`), both at or above it (positions and values shifted by `+l` and `0`,
so the distance is unchanged), and mixed (the upper pin's position rises by `l` while its
countdown does not, so the demand is strictly looser). This is the clause the idle-gap
lengthening's FAIL verdict predicted would loosen; here it is the pending splice's carried side
condition becoming free. -/
theorem idleSplice_pins (hg : IsLadderPath step pend g) (hl : 0 < l)
    (hidle : ∀ i : ℕ, i < l → pend (objAt g (a + (i : ℤ))) = false) :
    ∀ s v : ℤ, pend (spliceObj g a l s) = false → pend (spliceObj g a l (s + 1)) = true →
      pend (spliceObj g a l v) = false → pend (spliceObj g a l (v + 1)) = true →
      ((idleSpliceCnt g a l (s + 1) : ℤ) - idleSpliceCnt g a l (v + 1)).natAbs
        ≤ (s - v).natAbs := by
  intro s v hs0 hs1 hv0 hv1
  obtain ⟨t, ht0, ht1, htc, htcase⟩ := idleSplice_pull hl hidle s hs0 hs1
  obtain ⟨r, hr0, hr1, hrc, hrcase⟩ := idleSplice_pull hl hidle v hv0 hv1
  rw [htc, hrc]
  refine le_trans (pinCompat_of_ladderPath g hg t r ht0 ht1 hr0 hr1) ?_
  rcases htcase with ⟨hte, htb⟩ | ⟨hte, htb⟩ <;>
    rcases hrcase with ⟨hre, hrb⟩ | ⟨hre, hrb⟩ <;> omega

end Inputs

/-- **THE ADMISSIBILITY HALF OF THE IDLE-BLOCK DUPLICATION, UNCONDITIONAL.** An idle block whose
two ends carry the same object state may be duplicated outright: the spliced walk lifts to a
ladder path whose object walk is `spliceObj` and whose countdown is `idleSpliceCnt`. No pin side
condition and no regime hypothesis — `idleSplice_pins` discharges the lift's pin slot, and
`exists_ladderPath_of_walk_of_pins` derives the anchor from it. -/
theorem exists_idleSpliced_ladderPath {Q : Type}
    {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (a : ℤ) (l : ℕ) (hl : 0 < l)
    (hidle : ∀ i : ℕ, i < l → pend (objAt g (a + (i : ℤ))) = false)
    (hrep : objAt g a = objAt g (a + (l : ℤ))) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = spliceObj g a l v) ∧
      (∀ v : ℤ, cntAt g' v = idleSpliceCnt g a l v) :=
  exists_ladderPath_of_walk_of_pins (spliceObj g a l) (idleSpliceCnt g a l)
    (spliceObj_step hg hrep) (idleSpliceCnt_idle hg) (idleSpliceCnt_pend_pend hg hl hidle)
    (idleSpliceCnt_pend_idle hg hl hidle) (idleSplice_pins hg hl hidle)

end IdleSplice

/-! ## The idle-restricted `(objAt, tpOf)` pigeonhole

The pending pigeonhole above budgets `|Q| · 2^|cl φ|` against a region's COUNTDOWN. The idle
mirror budgets the IDLE-state count against a run's LENGTH, which is the quantity the idle-gap
lengthening's premise is about. The restriction matters twice: the carrier is the idle subtype
rather than all of `Q`, so the budget is smaller, and the block the pigeonhole returns matches in
realized TYPE as well as in object state — which is what makes sub-question (ii) of the decision
gate reachable instead of deferred. -/

section IdlePigeonhole

/-- **The idle-restricted `(objAt, tpOf)` pigeonhole budget**: the idle-restricted form of the
budget `exists_typeBlock_of_budget_le_cnt` uses, with the idle-state count in place of
`Fintype.card Q`. An OVER-ESTIMATE of the quantity it names — the product counts every
`(idle state, closure type)` pair, and a run need not realize all of them. -/
def idleBudget {Q : Type} [Fintype Q] (pend : Q → Bool) (φ : PlusFormula) : ℕ :=
  (Finset.univ.filter (fun q : Q => pend q = false)).card * 2 ^ (plusSubformulaClosure φ).card

-- `linter.unusedVariables`, scoped to this declaration, is only half the remedy. `hg` is unread
-- here — the idle mirror hypothesizes the run's idleness directly via `hrun`, where the pending
-- form reads it off `cntAt_sub_of_pend` — but dropping it relocates the finding one layer up
-- into `LadderWindow.lean`. The scoped `set_option` cannot reach a Batteries `@[env_linter]`,
-- which runs post-hoc over an imported environment, hence the paired attribute and allowlist row.
set_option linter.unusedVariables false in
/-- **A LONG ENOUGH IDLE RUN CARRIES A BLOCK MATCHING IN OBJECT STATE AND IN REALIZED TYPE.**
The mirror of `exists_typeBlock_of_budget_le_cnt_within`: the pigeonhole on the `idleBudget + 1`
positions of the run, into `{q // pend q = false} × {T // T ∈ (cl φ).powerset}`, whose
cardinality IS `idleBudget pend φ`. The conclusion exposes the block's own idleness and its
containment in the run, because the idle-block duplication consumes both. -/
@[nolint unusedArguments]
theorem exists_idleTypeBlock_of_budget_le_run {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hg : IsLadderPath step pend g) (z : ℤ) (L : ℕ)
    (hrun : ∀ i : ℕ, i ≤ L → pend (objAt g (z + (i : ℤ))) = false)
    (hbud : idleBudget pend φ ≤ L) :
    ∃ (a : ℤ) (k : ℕ), 0 < k ∧ k ≤ idleBudget pend φ ∧ z ≤ a ∧
      a + (k : ℤ) ≤ z + (L : ℤ) ∧
      (∀ i : ℕ, i < k → pend (objAt g (a + (i : ℤ))) = false) ∧
      objAt g a = objAt g (a + (k : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ a
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)) := by
  classical
  set b := idleBudget pend φ with hb
  let f : Fin (b + 1) → {q : Q // pend q = false} ×
      {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset} :=
    fun i => (⟨objAt g (z + ((i : ℕ) : ℤ)), hrun (i : ℕ) (by have := i.isLt; omega)⟩,
      ⟨tpOf (ladderModel step pend fwd bwd lab) φ σ (z + ((i : ℕ) : ℤ)),
        Finset.mem_powerset.mpr (tpOf_subset _ φ σ _)⟩)
  obtain ⟨x, y, hxy, hf⟩ := Fintype.exists_ne_map_eq_of_card_lt f (by
    rw [Fintype.card_prod, Fintype.card_subtype, Fintype.card_coe, Finset.card_powerset,
      Fintype.card_fin, hb]
    unfold idleBudget
    omega)
  have hf' : f x = f y := hf
  simp only [f, Prod.mk.injEq, Subtype.mk.injEq] at hf'
  obtain ⟨hobj, hty⟩ := hf'
  have hxb : (x : ℕ) ≤ b := by have := x.isLt; omega
  have hyb : (y : ℕ) ≤ b := by have := y.isLt; omega
  rcases lt_or_gt_of_ne (fun h : (x : ℕ) = (y : ℕ) => hxy (Fin.ext h)) with hlt | hlt
  · have hcast : z + ((x : ℕ) : ℤ) + (((y : ℕ) - (x : ℕ) : ℕ) : ℤ) = z + ((y : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    refine ⟨z + ((x : ℕ) : ℤ), (y : ℕ) - (x : ℕ), by omega, by omega, by omega, ?_, ?_, ?_, ?_⟩
    · rw [hcast]
      have : ((y : ℕ) : ℤ) ≤ (L : ℤ) := by exact_mod_cast le_trans hyb hbud
      omega
    · intro i hi
      rw [show z + ((x : ℕ) : ℤ) + (i : ℤ) = z + (((x : ℕ) + i : ℕ) : ℤ) by push_cast; ring]
      exact hrun ((x : ℕ) + i) (by omega)
    · rw [hcast]; exact hobj
    · rw [hcast]; exact hty
  · have hcast : z + ((y : ℕ) : ℤ) + (((x : ℕ) - (y : ℕ) : ℕ) : ℤ) = z + ((x : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    refine ⟨z + ((y : ℕ) : ℤ), (x : ℕ) - (y : ℕ), by omega, by omega, by omega, ?_, ?_, ?_, ?_⟩
    · rw [hcast]
      have : ((x : ℕ) : ℤ) ≤ (L : ℤ) := by exact_mod_cast le_trans hxb hbud
      omega
    · intro i hi
      rw [show z + ((y : ℕ) : ℤ) + (i : ℤ) = z + (((y : ℕ) + i : ℕ) : ℤ) by push_cast; ring]
      exact hrun ((y : ℕ) + i) (by omega)
    · rw [hcast]; exact hobj.symm
    · rw [hcast]; exact hty.symm

end IdlePigeonhole

end FormalSystem.Metalogic.Decidability.RaySummary
