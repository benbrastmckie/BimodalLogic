/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient

/-!
# The rigid anchors of a ladder history, and the agreement of class-equivalent cells

## Why the agreement is proved on its own ground

The agreement of class-equivalent cells is proved HERE, at the history level, and not as a
corollary of the soundness and completeness obligations. The reason is a compiled circularity.
The `⊡` bit of a realized type is a datum of the cell at the point's own world state
(`stab_mem_tpOf_iff_cell`, below); the acceptance condition of the certificate layer collapses
the `⊡` bits across a counter class at every certified set; and the bi-infinity condition of
that layer forbids confining a certified set to one state's cell. So discharging the acceptance
condition on any set containing a realized item already REQUIRES the agreement, and deriving the
agreement from the certificate side would close a cycle. This module therefore mentions no
certificate object at all — not the certificate conditions, not the maximum certified subset, not
the closure-component type of the certificate layer, and not the consistency bundle — and the
certificate-freedom of its `import` list and of its statements is the mechanical form of that
claim. `CounterQuotient` is imported for `kappa` and `ParamsOk` only; neither is a certificate
condition.

## What a ladder history's counters are, and what they are not

The results below are the RIGID ANCHORS of a ladder history, and they are what any replacement
argument has to respect.

* `cntAt_sub_of_pend` and `not_pend_of_count`: inside a pending region the current deadline
  counts down by exactly one per step and the region's first idle position sits at distance
  EXACTLY `cntAt g u + 1`. The countdown is not an annotation on a walk; it is the distance to
  the end of the region, forced by `Count` alone.
* `cntAt_eq_of_obj_eq`: two ladder paths with the SAME object walk carry the SAME countdown at
  every position. This is the mechanical reason a replacement argument cannot keep the object
  walk fixed and move the counters: changing the countdown at a position REQUIRES changing the
  walk, by lengthening or shortening the pending region the position sits in. It is also why the
  positionwise statement shape is refuted (`no_positionwise_lift`, compiled in the gate table)
  and the pumping form is the licensed one.
* `nxtAt_drift_le`: the next-deadline register is `1`-Lipschitz along the path, so its value at
  one position constrains its value at another only up to the distance between them. This is the
  anchor the `n` coordinate of the counter quotient reads.

## What this module does NOT hold

* **THE AGREEMENT ITSELF IS NOT LANDED.** The statement this module exists for — that the cell at
  a pending position is constant on the classes of the counter quotient, under the parameter
  conditions — is NOT proved here and is not assumed anywhere. What landed is the rigid-anchor
  layer above, which any proof of it has to respect, and the cell-level reading of the `⊡` bit.
  Three obstructions are on the record for it, each a consequence of what IS compiled here.
  First, by `cntAt_eq_of_obj_eq` no replacement can keep the object walk and move the counters, so
  the argument must pump the object walk itself. Second, pumping the walk changes the realized
  type at the position only through a model-level periodicity statement about truth along a ladder
  path, and the only landed periodicity statement (the backward-reachability fixpoint of the
  certificate graph) is a statement about the certificate relation, whose bridge to truth along a
  ladder path is exactly the soundness and completeness obligations that READ the agreement — so
  that machinery cannot be reused here without closing a cycle, and a model-level pumping lemma
  has to be authored instead. Third, the `⊡` bit inside a realized type is by
  `stab_mem_tpOf_iff_cell` a datum of the cell being compared, so the agreement's own proof runs
  by induction on `⊡`-nesting depth whatever the phase order is; what the history-level route buys
  is that the stratification is at the MODEL level and needs no stratified certificate family.
* **No certificate object.** See the first paragraph. `CounterQuotient` is imported for `kappa`
  and `ParamsOk`, which the agreement statement consumes; with that statement not yet landed, the
  import is the one the module's own route declares and nothing in the results above reads it.
* **No positionwise completeness clause.** Nothing here lifts a class-level chain positionwise;
  that statement shape is refuted for every finite counter quotient.
* **No finite-fibre and no finite-width hypothesis.** `[Finite Q]` is on the OBJECT only, and the
  admissible carrier is infinite.
* **No decision procedure and no bound.** Every quantity named is a count.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The `⊡` bit of a realized type is a cell-level datum -/

section Stab

variable {F : FrameOver intOrder}

/-- **The `⊡` bit of a realized type IS a cell-level datum**: `stab_mem_tpOf_iff` read through
`cellAt`. A statement about `tpOf` and `cellAt` only, which is why it belongs beside the
agreement and not in the certificate layer. -/
theorem stab_mem_tpOf_iff_cell (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {χ : PlusFormula}
    (h : PlusFormula.stab χ ∈ plusSubformulaClosure φ) :
    PlusFormula.stab χ ∈ tpOf M φ σ z ↔ ∀ T ∈ cellAt M φ (σ.state z) z, χ ∈ T := by
  rw [stab_mem_tpOf_iff M φ σ z h]
  constructor
  · rintro H T ⟨σ', hs', rfl⟩
    exact H σ' hs'.symm
  · intro H σ' hσ'
    exact H _ ⟨σ', hσ'.symm, rfl⟩

end Stab

/-! ## The components of a ladder path

A history of `ladderFrameAdm` is exactly an offset step path of `RladAdm`
(`ofSlicedStepFinBranch_mem_HF_iff`), and `RladAdm` ignores its time argument, so every statement
below is about a function `g : ℤ → LadderState Q pend` stepping along `RladAdm`. The three
accessors name the components `Rlad` constrains. -/

section Path

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- The object component of a ladder path at a position. -/
def objAt (g : ℤ → LadderState Q pend) (u : ℤ) : Q := (g u).1.1

/-- The current-deadline component of a ladder path at a position. -/
def cntAt (g : ℤ → LadderState Q pend) (u : ℤ) : ℕ := (g u).1.2.1

/-- The next-deadline component of a ladder path at a position. -/
def nxtAt (g : ℤ → LadderState Q pend) (u : ℤ) : ℕ := (g u).1.2.2

/-- A ladder path: a function stepping along `RladAdm` at every position. The time argument is
quantified away because `RladAdm` ignores it. -/
def IsLadderPath (step : Q → Q → Bool) (pend : Q → Bool) (g : ℤ → LadderState Q pend) : Prop :=
  ∀ u : ℤ, RladAdm step pend u (g u) (g (u + 1))

/-! ### The four readings of `Count` along a path -/

/-- The step relation of a ladder path, read at the three components. -/
theorem isLadderPath_components (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) :
    step (objAt g u) (objAt g (u + 1)) = true ∧
      (pend (objAt g u) = false → cntAt g u = 0) ∧
      Drift (nxtAt g u) (nxtAt g (u + 1)) ∧
      Count (pend (objAt g u)) (pend (objAt g (u + 1))) (cntAt g u) (nxtAt g u)
        (cntAt g (u + 1)) :=
  hg u

/-- The object walk of a ladder path steps along `step`. -/
theorem objAt_step (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (u : ℤ) :
    step (objAt g u) (objAt g (u + 1)) = true := (isLadderPath_components g hg u).1

/-- An idle position of a ladder path carries countdown `0`. -/
theorem cntAt_eq_zero_of_idle (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (h : pend (objAt g u) = false) : cntAt g u = 0 :=
  (isLadderPath_components g hg u).2.1 h

/-- **The next-deadline register is `1`-Lipschitz along the path.** Its value at one position
constrains its value at another only up to the distance between them; this is the anchor the
next-deadline coordinate of the counter quotient reads. -/
theorem nxtAt_drift (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (u : ℤ) :
    Drift (nxtAt g u) (nxtAt g (u + 1)) := (isLadderPath_components g hg u).2.2.1

/-- **Pending to pending**: the countdown decreases by exactly one. -/
theorem cntAt_succ_of_pend_pend (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hx : pend (objAt g u) = true) (hy : pend (objAt g (u + 1)) = true) :
    cntAt g (u + 1) + 1 = cntAt g u := by
  have h := (isLadderPath_components g hg u).2.2.2
  simp only [Count, hx, hy, if_true] at h
  exact h

/-- **Pending to idle**: the countdown is exhausted at the region's last pending position, and
the idle position that follows carries `0`. -/
theorem cntAt_eq_zero_of_pend_idle (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hx : pend (objAt g u) = true) (hy : pend (objAt g (u + 1)) = false) :
    cntAt g u = 0 ∧ cntAt g (u + 1) = 0 := by
  have h := (isLadderPath_components g hg u).2.2.2
  simp only [Count, hy, Bool.false_eq_true, if_false] at h
  exact ⟨h.2 hx, h.1⟩

/-- **Idle to pending**: the new region's countdown is the next-deadline register's value at the
transition. -/
theorem cntAt_eq_nxtAt_of_idle_pend (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hx : pend (objAt g u) = false) (hy : pend (objAt g (u + 1)) = true) :
    cntAt g (u + 1) = nxtAt g u := by
  have h := (isLadderPath_components g hg u).2.2.2
  simp only [Count, hx, hy, if_true, Bool.false_eq_true, if_false] at h
  exact h

/-! ### The rigid pending region

`cntAt g u` is the distance from `u` to the LAST pending position of the region `u` sits in, so
the region's first idle position sits at distance exactly `cntAt g u + 1`. The countdown is
therefore not free data on a walk: it is read off the walk. -/

/-- **Inside a pending region the countdown is the distance to the region's end.** For every
`j ≤ cntAt g u`, the position `u + j` is pending and carries countdown `cntAt g u - j`. -/
theorem cntAt_sub_of_pend (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hu : pend (objAt g u) = true) :
    ∀ j : ℕ, j ≤ cntAt g u →
      pend (objAt g (u + (j : ℤ))) = true ∧ cntAt g (u + (j : ℤ)) = cntAt g u - j := by
  intro j
  induction j with
  | zero => intro _; simpa using hu
  | succ j ih =>
    intro hj
    obtain ⟨hp, hc⟩ := ih (by omega)
    have hcast : u + ((j + 1 : ℕ) : ℤ) = u + (j : ℤ) + 1 := by push_cast; ring
    have hnext : pend (objAt g (u + (j : ℤ) + 1)) = true := by
      by_contra hne
      rw [Bool.not_eq_true] at hne
      have := (cntAt_eq_zero_of_pend_idle g hg (u + (j : ℤ)) hp hne).1
      omega
    have hstep := cntAt_succ_of_pend_pend g hg (u + (j : ℤ)) hp hnext
    rw [hcast]
    exact ⟨hnext, by omega⟩

/-- **The region's first idle position sits at distance exactly `cntAt g u + 1`.** At the
region's last pending position the countdown is `0`, and `Count true true` cannot produce a
successor countdown there, so the next position is idle. -/
theorem not_pend_of_count (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hu : pend (objAt g u) = true) :
    pend (objAt g (u + (cntAt g u : ℤ) + 1)) = false := by
  obtain ⟨hp, hc⟩ := cntAt_sub_of_pend g hg u hu (cntAt g u) le_rfl
  by_contra hne
  rw [Bool.not_eq_false] at hne
  have := cntAt_succ_of_pend_pend g hg (u + (cntAt g u : ℤ)) hp hne
  omega

/-- **THE RIGIDITY OF THE COUNTDOWN.** Two ladder paths with the same object walk carry the same
countdown at every position. The countdown is read off the walk — at an idle position it is `0`,
and at a pending position it is the distance to the region's last pending position — so a
replacement argument that changes a countdown MUST change the walk. This is the mechanical
content of the refutation of the positionwise statement shape. -/
theorem cntAt_eq_of_obj_eq (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g')
    (hobj : ∀ v : ℤ, objAt g v = objAt g' v) (u : ℤ) : cntAt g u = cntAt g' u := by
  by_cases hu : pend (objAt g u) = true
  · have hu' : pend (objAt g' u) = true := by rw [← hobj u]; exact hu
    by_contra hne
    rcases Nat.lt_or_ge (cntAt g u) (cntAt g' u) with hlt | hge
    · have h1 := not_pend_of_count g hg u hu
      have h2 := (cntAt_sub_of_pend g' hg' u hu' (cntAt g u + 1) (by omega)).1
      rw [show u + ((cntAt g u + 1 : ℕ) : ℤ) = u + (cntAt g u : ℤ) + 1 by push_cast; ring] at h2
      rw [hobj] at h1
      rw [h1] at h2
      simp at h2
    · have hlt' : cntAt g' u < cntAt g u := by omega
      have h1 := not_pend_of_count g' hg' u hu'
      have h2 := (cntAt_sub_of_pend g hg u hu (cntAt g' u + 1) (by omega)).1
      rw [show u + ((cntAt g' u + 1 : ℕ) : ℤ) = u + (cntAt g' u : ℤ) + 1 by push_cast; ring] at h2
      rw [hobj] at h2
      rw [h1] at h2
      simp at h2
  · rw [Bool.not_eq_true] at hu
    have hu' : pend (objAt g' u) = false := by rw [← hobj u]; exact hu
    rw [cntAt_eq_zero_of_idle g hg u hu, cntAt_eq_zero_of_idle g' hg' u hu']

/-! ### The window the next-deadline register imposes, and the two regimes of a pending position

The next-deadline register is `1`-Lipschitz and a region's countdown at its START is that
register's value at the idle position before it. Those two facts together bound the countdown at
any pending position whose past contains an idle position — the window `c ≤ n + 1`. Its
contrapositive is the DICHOTOMY: a pending position whose countdown exceeds its next deadline by
two or more lies on a path that is pending at every earlier position. Both regimes are populated:
the second is the thirteenth wired probe's forward-only liveness witness
(`ladder-liveness-forward-only.lean`: an admissible path pending at every past time with its
countdown growing without bound into the past), and the gap coordinate of the counter quotient is
what separates them. -/

/-- **The next-deadline register is `1`-Lipschitz over any number of steps.** `Drift` iterated. -/
theorem nxtAt_lipschitz (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) : ∀ j : ℕ, ((nxtAt g u : ℤ) - (nxtAt g (u + (j : ℤ)))).natAbs ≤ j := by
  intro j
  induction j with
  | zero => simp
  | succ j ih =>
    have hd := nxtAt_drift g hg (u + (j : ℤ))
    rw [show u + ((j + 1 : ℕ) : ℤ) = u + (j : ℤ) + 1 by push_cast; ring]
    simp only [Drift] at hd
    omega

/-- **The countdown counts UP into the past inside a pending run**: if every position of
`[z - j, z]` is pending then the countdown at `z - j` is `cntAt g z + j`. The backward reading of
the rigid region. -/
theorem cntAt_add_of_pend_back (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) : ∀ j : ℕ, (∀ i : ℕ, i ≤ j → pend (objAt g (z - (i : ℤ))) = true) →
      cntAt g (z - (j : ℤ)) = cntAt g z + j := by
  intro j
  induction j with
  | zero => intro _; simp
  | succ j ih =>
    intro hp
    have ihv := ih (fun i hi => hp i (by omega))
    have h1 : pend (objAt g (z - ((j + 1 : ℕ) : ℤ))) = true := hp (j + 1) le_rfl
    have h2 : pend (objAt g (z - ((j + 1 : ℕ) : ℤ) + 1)) = true := by
      rw [show z - ((j + 1 : ℕ) : ℤ) + 1 = z - (j : ℤ) by push_cast; ring]
      exact hp j (by omega)
    have hstep := cntAt_succ_of_pend_pend g hg (z - ((j + 1 : ℕ) : ℤ)) h1 h2
    rw [show z - ((j + 1 : ℕ) : ℤ) + 1 = z - (j : ℤ) by push_cast; ring] at hstep
    omega

/-- **THE WINDOW.** If a pending position has ANY idle position in its past, its countdown is at
most its next deadline plus one. The region containing it then has a start, the start's countdown
is the next-deadline register's value at the idle position before it, and the register is
`1`-Lipschitz — so the countdown cannot outrun the deadline by more than the one step the
transition itself contributes. -/
theorem cntAt_le_nxtAt_succ_of_idle_past (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z p : ℤ) (hz : pend (objAt g z) = true)
    (hp : p ≤ z) (hpi : pend (objAt g p) = false) :
    cntAt g z ≤ nxtAt g z + 1 := by
  classical
  -- the least backward distance at which the path is idle
  have hex : ∃ j : ℕ, pend (objAt g (z - (j : ℤ))) = false :=
    ⟨(z - p).toNat, by rw [show z - ((z - p).toNat : ℤ) = p by omega]; exact hpi⟩
  set j₀ := Nat.find hex with hj₀
  have hfind : pend (objAt g (z - (j₀ : ℤ))) = false := Nat.find_spec hex
  have hlt : ∀ i : ℕ, i < j₀ → pend (objAt g (z - (i : ℤ))) = true := by
    intro i hi
    have := Nat.find_min hex (m := i) (by omega)
    rw [Bool.not_eq_false] at this
    exact this
  have hj₀pos : 0 < j₀ := by
    rcases Nat.eq_zero_or_pos j₀ with h | h
    · exfalso
      rw [h, show z - ((0 : ℕ) : ℤ) = z by push_cast; ring] at hfind
      exact Bool.false_ne_true (hfind.symm.trans hz)
    · exact h
  -- the region start sits at `z - (j₀ - 1)`
  set d := j₀ - 1 with hd
  have hdj : j₀ = d + 1 := by omega
  have hrun : ∀ i : ℕ, i ≤ d → pend (objAt g (z - (i : ℤ))) = true :=
    fun i hi => hlt i (by omega)
  have hcnt : cntAt g (z - (d : ℤ)) = cntAt g z + d := cntAt_add_of_pend_back g hg z d hrun
  -- the start's countdown is the register's value at the idle position before it
  have hstart : pend (objAt g (z - (j₀ : ℤ)) ) = false := hfind
  have hsucc : z - (j₀ : ℤ) + 1 = z - (d : ℤ) := by rw [hdj]; push_cast; ring
  have hpd : pend (objAt g (z - (j₀ : ℤ) + 1)) = true := by
    rw [hsucc]; exact hrun d le_rfl
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg (z - (j₀ : ℤ)) hstart hpd
  rw [hsucc] at hpin
  -- the register is `1`-Lipschitz from that idle position up to `z`
  have hlip := nxtAt_lipschitz g hg (z - (j₀ : ℤ)) j₀
  rw [show z - (j₀ : ℤ) + (j₀ : ℤ) = z by ring] at hlip
  omega

/-- **THE DICHOTOMY.** The contrapositive of the window: a pending position whose countdown
exceeds its next deadline by two or more lies on a path that is pending at EVERY earlier
position. Such paths exist — the thirteenth wired probe's witness is one — so this is a genuine
second regime and not a vacuous case, and the gap coordinate of the counter quotient is what
separates the two. -/
theorem pend_past_of_nxtAt_lt (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) (hz : pend (objAt g z) = true) (hgap : nxtAt g z + 2 ≤ cntAt g z) :
    ∀ p : ℤ, p ≤ z → pend (objAt g p) = true := by
  intro p hp
  by_contra hne
  rw [Bool.not_eq_true] at hne
  have := cntAt_le_nxtAt_succ_of_idle_past g hg z p hz hp hne
  omega

/-! ### What a class collision of the counter quotient actually says

The three lemmas below read a collision of the class map off its coordinates. The last is the one
that matters for the two regimes above: at `2 ≤ B` — which `(K4)` requires — a collision at a
FIXED next deadline cannot straddle the window and the pending-forever regime. It puts both
counter values on the same side, so a replacement argument may be given separately in the two
regimes and never has to carry a path from one into the other. This is the gap coordinate's own
content, and it is why `(K4)`'s `2 ≤ B` is not cosmetic. -/

/-- A collision of the class map, read coordinate by coordinate. -/
theorem kappa_eq_components (Tc Tn P B c n c' n' : ℕ)
    (h : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    min c Tc = min c' Tc ∧ c % (P + 1) = c' % (P + 1) ∧
      min n Tn = min n' Tn ∧ n % (P + 1) = n' % (P + 1) ∧
      clipIdx B c n = clipIdx B c' n' := by
  simp only [kappa, Prod.mk.injEq, Fin.mk.injEq] at h
  exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2⟩

/-- **The clipped coordinate is an EXACT reading below its threshold.** A collision at the
clipped countdown coordinate either pins the two values equal or puts both at or above the
threshold — there is no third case, which is why the threshold separates the small countdowns
exactly and the pumping regime begins at `Tc`. -/
theorem eq_or_both_ge_of_min_eq (T a b : ℕ) (h : min a T = min b T) :
    a = b ∨ (T ≤ a ∧ T ≤ b) := by omega

/-- **THE GAP COORDINATE SEGREGATES THE TWO REGIMES.** At `2 ≤ B` a collision of the gap
coordinate at a fixed next deadline forces both countdowns into the SAME regime of
`cntAt_le_nxtAt_succ_of_idle_past`/`pend_past_of_nxtAt_lt`: either the larger one still lies
inside the window `c ≤ n`, or the smaller one already exceeds the deadline by two. A collision
straddling the two — one state reachable with an idle position in its past and the other only by
a path pending forever into the past — is therefore impossible, and that is what keeps the two
regimes from having to be related to each other. -/
theorem clipIdx_regime_of_eq (B c c' n : ℕ) (hB : 2 ≤ B) (hlt : c < c')
    (h : clipIdx B c n = clipIdx B c' n) : c' ≤ n ∨ n + 2 ≤ c := by
  unfold clipIdx at h
  split at h <;> split at h <;> omega

end Path

end FormalSystem.Metalogic.Decidability.RaySummary
