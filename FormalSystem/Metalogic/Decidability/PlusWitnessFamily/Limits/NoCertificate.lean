/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Fintype.Pigeonhole
import Mathlib.Tactic.Ring
import Mathlib.Tactic.WLOG
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Limits.Targets

/-!
# The Landed Certificate Class Is Incomplete

`Limits/HopFree.lean` bounds one *strategy* for producing L⁺ certificates. This module bounds the
**class**: there is a ℤ-time non-validity of `PlusFormula`, namely `pumpTarget p`, that **no**
`PlusSharingWitnessFamily` certifies — at any time, for any lasso count, for any segment lengths,
and under no hypothesis whatsoever on the succession relation. The theorem below is what makes the
withdrawal of the L⁺ compression statement a theorem of this tree rather than a note in a report.

## The argument

`pumpTarget p` is `□⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))`. The inserted `Fp → Fp` is inert
semantically and decisive syntactically: it is what puts `Fp` and its guard `⊤` in the closure, so
that (C1')'s `untl` clause can be read at `Fp` and (C2') can be made to demand its fulfilment.

1. (C4) and (C1')'s `imp` clause force `□⟐Xp` and `□⟐X¬p` into the main label at `t`; (C3) spreads
   `⟐Xp` and `⟐X¬p` to every index at every time; (C5), (C1') and the reflexive `untl` clause then
   give every position a share-class member branching to `p` and one branching to `¬p`. These
   three steps are exactly `HopFree.lean`'s, and they are re-derived here rather than imported,
   because they are facts about a *different closure*: `hopClosure p` and `pumpClosure p` are
   distinct `Finset PlusFormula` values and no membership fact transports between them.
2. Choose successors: `fP` for the `p`-branch and `fN` for the `¬p`-branch. Build the
   **long-postponement path** `seqPostpone`: start on the main index at time `S.NM` — inside the
   forward-periodic region, so that the periodicity congruences apply — take `¬p`-successors for
   `k := S.lassos.length * S.perFwd + 1` steps, and take a `p`-successor at step `k`.
3. That is a state path, so `lift` tracks it by a succession path `τ`. (C0) transports the atom
   facts from the state path onto `τ`, so `p` is absent from `τ`'s labels at every time strictly
   between the start and the single `p`-step, and present at the `p`-step.
4. `⊤` is in every label (by (C1')'s `imp` clause at `⊥ → ⊥`), so (C1')'s `untl` clause propagates
   `Fp` **backwards** along `τ` from the `p`-step to every earlier time of the run.
5. Pigeonhole `τ` over the `S.lassos.length + 1` times spaced by the forward period `S.NF`, all of
   which lie inside the run: two of them, `v < v'`, carry the same index. Their gap `D` is a
   positive multiple of `S.NF`.
6. **Loop the thread** between `v` and `v'`: `fold w` is `w` below `v` and `v + (w - v) % D` above.
   `transRaw_congr_NF` and `data_congr_fwd` are what make `fun w => τ (fold w)` a genuine
   `S.Thread` with the *same labels* — the folded time and the real time are congruent mod `S.NF`
   above `S.NM`, so both the succession matrix and the per-time data agree.
7. That thread carries `Fp` at `v` (step 4) and never reads `p` (step 3, since `fold` never leaves
   `[v, v')`). (C2') demands a fulfilling time; there is none. Contradiction.

## The scope of the failure

The defect is not a missing bound and no bound repairs it. It is this: (C2') is a demand about
**every** thread of the presented structure, and the presented structure is finite and eventually
periodic, so *every* cycle reachable in the periodic region is a thread. A target whose
countermodels must contain, inside the periodic region, a **cycle with an exit under a pending
eventuality** therefore has no certificate: the certificate's own finiteness manufactures a thread
that stays in the cycle forever, and (C2') reads that thread as an unfulfilled eventuality even
though the countermodel fulfils the eventuality by leaving the cycle.

`pumpTarget p` is the minimal instance. Its `□⟐Xp`/`□⟐X¬p` pair forces the branching that creates
the exit, and the inserted `Fp → Fp` supplies the pending eventuality. Raising the lasso count, the
window length, or the two periods raises `k` — and the pigeonhole raises with it, because `k` is
defined *from* the family's own numbers. Weakening (C2') to quantify over some restricted class of
threads is not an option either while `plusRefutes_of_certifies` is to survive: the soundness
direction reads (C2') at exactly the threads the joint countermodel construction builds.

The repair is therefore structural, and it is the business of this plan's Stage 2: a certificate
whose fulfilment obligation is **time-indexed** rather than thread-indexed, so that a cycle with an
exit is not read as a cycle without one.

## What survives unchanged

`plusTruth_iff_mem` and `plusRefutes_of_certifies` are untouched by this module and remain true:
soundness of the certificate class was never in question, and is not in question here. What fails
is completeness — the converse direction — and it fails at a specific, exhibited formula.

## Provenance

Transcription of the compiled no-certificate probe recorded with the second research round on L⁺
compression. The argument is unchanged; the target, its non-validity and its seventeen-step closure
chain are now `Limits/Targets.lean`'s library declarations, and the theorem is parametric in the
atom.

## Main Definitions

- `PlusSharingWitnessFamily.seqPostpone` — the long-postponement branching sequence

## Main Results

- `PlusSharingWitnessFamily.not_plusCertifies_pumpTarget` — no family certifies `pumpTarget p`
- `PlusSharingWitnessFamily.not_exists_plusCertifies_pumpTarget` — the same, existentially
- `PlusSharingWitnessFamily.plusCompression_fails_at_pumpTarget` — the non-validity and the
  absence of a certificate, bundled: the L⁺ compression statement's counterexample

## Tags

plus-language · certificate · incompleteness · eventuality · pumping
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.ProofSystem

namespace PlusSharingWitnessFamily

variable {p : Atom}

/-! ## The long-postponement sequence -/

/--
**Follow `¬p`-successors, except at step `k`, where a `p`-successor is taken.**

Stated over abstract successor functions so that it is a plain recursion with no family in it: the
two limit arguments differ only in how `fP` and `fN` are obtained.
-/
def seqPostpone {n : ℕ} (i0 : Fin n) (fP fN : Fin n → ℤ → Fin n) (u0 : ℤ) (k : ℕ) : ℕ → Fin n
  | 0 => i0
  | m + 1 =>
      if m = k then fP (seqPostpone i0 fP fN u0 k m) (u0 + m + 1)
      else fN (seqPostpone i0 fP fN u0 k m) (u0 + m + 1)

/-! ## The limit -/

/--
**No `PlusSharingWitnessFamily` certifies `pumpTarget p`.**

Quantified over **every** family and **every** time: no lasso-count hypothesis, no bound on the
window or the periods, and no hypothesis on `trans`. A stray hypothesis here would make the
theorem far weaker than the withdrawal it records, so the statement is the load-bearing part.

Paper: — (a formalization-native limit; the paper states no such result)
-/
theorem not_plusCertifies_pumpTarget
    (S : PlusSharingWitnessFamily ([] : PlusContext) (pumpDelta p)) (t : ℤ) :
    ¬ S.PlusCertifies t := by
  rintro ⟨hat, ⟨hloc, hful⟩, hbox, htgt, hstab⟩
  classical
  have himp : ∀ (i : Fin S.lassos.length) (u : ℤ) (a b : PlusFormula),
      PlusFormula.imp a b ∈ pumpClosure p →
      (PlusFormula.imp a b ∈ S.L i u ↔ (a ∈ S.L i u → b ∈ S.L i u)) :=
    fun i u a b h => (hloc i u).2.1 a b h
  have hbot : ∀ (i : Fin S.lassos.length) (u : ℤ), PlusFormula.bot ∉ S.L i u :=
    fun i u => (hloc i u).1
  have hbx : ∀ (i : Fin S.lassos.length) (u : ℤ) (χ : PlusFormula),
      PlusFormula.box χ ∈ pumpClosure p →
      (PlusFormula.box χ ∈ S.L i u ↔ S.bx χ = true) :=
    fun i u χ h => (hloc i u).2.2.1 χ h
  have huntl : ∀ (i : Fin S.lassos.length) (u : ℤ) (j : Fin S.lassos.length), S.trans u i j →
      ∀ g e : PlusFormula, PlusFormula.untl g e ∈ pumpClosure p →
      (PlusFormula.untl g e ∈ S.L i u ↔
        (e ∈ S.L j (u + 1) ∨ (g ∈ S.L j (u + 1) ∧ PlusFormula.untl g e ∈ S.L j (u + 1)))) :=
    fun i u j h => (hloc i u).2.2.2.1 j h
  -- Step 1: the target forces both boxes, and (C3) spreads them everywhere.
  have hphi : pumpTarget p ∉ S.L S.mainIdx t := htgt.2 (pumpTarget p) (List.mem_singleton_self _)
  have h1 : PlusFormula.box (someNextTrue p) ∈ S.L S.mainIdx t := by
    by_contra h
    exact hphi ((himp _ _ _ _ (pumpTarget_mem_pumpClosure p)).mpr (fun h' => absurd h' h))
  have hrest : PlusFormula.imp (PlusFormula.box (someNextFalse p))
      (PlusFormula.imp (PlusFormula.imp (someFuture p) (someFuture p)) PlusFormula.bot)
      ∉ S.L S.mainIdx t :=
    fun h => hphi ((himp _ _ _ _ (pumpTarget_mem_pumpClosure p)).mpr (fun _ => h))
  have h2 : PlusFormula.box (someNextFalse p) ∈ S.L S.mainIdx t := by
    by_contra h
    exact hrest ((himp _ _ _ _ (impBoxSomeNextFalse_mem_pumpClosure p)).mpr
      (fun h' => absurd h' h))
  have hall1 : ∀ (i : Fin S.lassos.length) (u : ℤ), someNextTrue p ∈ S.L i u :=
    (hbox (someNextTrue p) (boxSomeNextTrue_mem_pumpClosure p)).mp
      ((hbx _ _ (someNextTrue p) (boxSomeNextTrue_mem_pumpClosure p)).mp h1)
  have hall2 : ∀ (i : Fin S.lassos.length) (u : ℤ), someNextFalse p ∈ S.L i u :=
    (hbox (someNextFalse p) (boxSomeNextFalse_mem_pumpClosure p)).mp
      ((hbx _ _ (someNextFalse p) (boxSomeNextFalse_mem_pumpClosure p)).mp h2)
  -- Every position has a `p`-successor and a `¬p`-successor.
  have stepP : ∀ (i : Fin S.lassos.length) (u : ℤ),
      ∃ j, S.share u i j ∧ PlusFormula.atom p ∈ S.L j (u + 1) := by
    intro i u
    have hns : PlusFormula.stab (PlusFormula.imp (nextTrue p) PlusFormula.bot) ∉ S.L i u :=
      fun hs => hbot i u ((himp i u _ _ (someNextTrue_mem_pumpClosure p)).mp (hall1 i u) hs)
    have hex : ¬ ∀ j, S.share u i j →
        PlusFormula.imp (nextTrue p) PlusFormula.bot ∈ S.L j u :=
      fun hh => hns ((hstab i u _ (stabNotNextTrue_mem_pumpClosure p)).mpr hh)
    push Not at hex
    obtain ⟨j, hsh, hj⟩ := hex
    refine ⟨j, hsh, ?_⟩
    have hX : nextTrue p ∈ S.L j u := by
      by_contra h
      exact hj ((himp j u _ _ (notNextTrue_mem_pumpClosure p)).mpr (fun h' => absurd h' h))
    rcases (huntl j u j (S.trans_refl' u j) _ _ (nextTrue_mem_pumpClosure p)).mp hX with
      h | ⟨h, -⟩
    · exact h
    · exact absurd h (hbot j (u + 1))
  have stepN : ∀ (i : Fin S.lassos.length) (u : ℤ),
      ∃ j, S.share u i j ∧ PlusFormula.atom p ∉ S.L j (u + 1) := by
    intro i u
    have hns : PlusFormula.stab (PlusFormula.imp (nextFalse p) PlusFormula.bot) ∉ S.L i u :=
      fun hs => hbot i u ((himp i u _ _ (someNextFalse_mem_pumpClosure p)).mp (hall2 i u) hs)
    have hex : ¬ ∀ j, S.share u i j →
        PlusFormula.imp (nextFalse p) PlusFormula.bot ∈ S.L j u :=
      fun hh => hns ((hstab i u _ (stabNotNextFalse_mem_pumpClosure p)).mpr hh)
    push Not at hex
    obtain ⟨j, hsh, hj⟩ := hex
    refine ⟨j, hsh, ?_⟩
    have hX : nextFalse p ∈ S.L j u := by
      by_contra h
      exact hj ((himp j u _ _ (notNextFalse_mem_pumpClosure p)).mpr (fun h' => absurd h' h))
    have hnp : PlusFormula.imp (PlusFormula.atom p) PlusFormula.bot ∈ S.L j (u + 1) := by
      rcases (huntl j u j (S.trans_refl' u j) _ _ (nextFalse_mem_pumpClosure p)).mp hX with
        h | ⟨h, -⟩
      · exact h
      · exact absurd h (hbot j (u + 1))
    exact fun hp => hbot j (u + 1)
      ((himp j (u + 1) _ _ (notAtom_mem_pumpClosure p)).mp hnp hp)
  choose fP hfP1 hfP2 using stepP
  choose fN hfN1 hfN2 using stepN
  -- Step 2: start in the forward-periodic region, run longer than the position count.
  set u0 : ℤ := S.NM with hu0
  set k : ℕ := S.lassos.length * S.perFwd + 1 with hk
  set a : ℕ → Fin S.lassos.length := seqPostpone S.mainIdx fP fN u0 k with ha
  have ha_succ : ∀ m, a (m + 1) =
      if m = k then fP (a m) (u0 + m + 1) else fN (a m) (u0 + m + 1) := fun m => rfl
  have ha_share : ∀ m : ℕ, S.share (u0 + m + 1) (a m) (a (m + 1)) := by
    intro m
    rw [ha_succ]
    split_ifs
    · exact hfP1 _ _
    · exact hfN1 _ _
  have ha_p : ∀ m : ℕ, (m = k → PlusFormula.atom p ∈ S.L (a (m + 1)) (u0 + m + 1 + 1)) ∧
      (m ≠ k → PlusFormula.atom p ∉ S.L (a (m + 1)) (u0 + m + 1 + 1)) := by
    intro m
    rw [ha_succ]
    constructor
    · intro h; rw [if_pos h]; exact hfP2 _ _
    · intro h; rw [if_neg h]; exact hfN2 _ _
  -- The state path, and its tracking succession path.
  set σ : ℤ → Fin S.lassos.length := fun u => a (u - u0).toNat with hσ
  have hσ_at : ∀ m : ℕ, σ (u0 + m) = a m := by
    intro m
    simp only [hσ]
    congr 1
    omega
  have hσstep : ∀ u : ℤ,
      stepOf S.lassos.length S.repBack S.repMid S.repFwd u (σ u) (σ (u + 1)) := by
    intro u
    by_cases hu : u0 ≤ u
    · obtain ⟨m, rfl⟩ : ∃ m : ℕ, u = u0 + m := ⟨(u - u0).toNat, by omega⟩
      rw [hσ_at, show u0 + (m : ℤ) + 1 = u0 + ((m + 1 : ℕ) : ℤ) by push_cast; ring, hσ_at]
      exact ⟨a m, rfl, ha_share m⟩
    · have e1 : σ u = a 0 := by simp only [hσ]; congr 1; omega
      have e2 : σ (u + 1) = a 0 := by simp only [hσ]; congr 1; omega
      rw [e1, e2]
      exact ⟨a 0, rfl, rfl⟩
  obtain ⟨τ, hτ, hτσ⟩ := S.lift σ hσstep
  have hτstep : ∀ u : ℤ, S.trans u (τ u) (τ (u + 1)) := hτ
  have hτshare : ∀ u : ℤ, S.share u (σ u) (τ u) := hτσ
  -- Step 3: transport the atom facts onto the tracking path, by (C0).
  have hτp : ∀ m : ℕ, (m = k → PlusFormula.atom p ∈ S.L (τ (u0 + m + 2)) (u0 + m + 2)) ∧
      (m ≠ k → PlusFormula.atom p ∉ S.L (τ (u0 + m + 2)) (u0 + m + 2)) := by
    intro m
    have hsh1 : S.share (u0 + m + 2) (a (m + 1)) (a (m + 2)) := by
      have := ha_share (m + 1)
      rw [show u0 + ((m + 1 : ℕ) : ℤ) + 1 = u0 + (m : ℤ) + 2 by push_cast; ring] at this
      exact this
    have hsh2 : S.share (u0 + m + 2) (a (m + 2)) (τ (u0 + m + 2)) := by
      have := hτshare (u0 + m + 2)
      rw [show u0 + (m : ℤ) + 2 = u0 + ((m + 2 : ℕ) : ℤ) by push_cast; ring, hσ_at] at this
      rw [show u0 + (m : ℤ) + 2 = u0 + ((m + 2 : ℕ) : ℤ) by push_cast; ring]
      exact this
    have hsh : S.share (u0 + m + 2) (a (m + 1)) (τ (u0 + m + 2)) := share_trans hsh1 hsh2
    have hco := hat (u0 + m + 2) _ _ hsh p
    have hap := ha_p m
    rw [show u0 + (m : ℤ) + 1 + 1 = u0 + (m : ℤ) + 2 by ring] at hap
    exact ⟨fun h => hco.mp (hap.1 h), fun h hp => hap.2 h (hco.mpr hp)⟩
  -- Step 4: `⊤` is labelled everywhere, so `Fp` propagates backwards along `τ`.
  have htp : ∀ (i : Fin S.lassos.length) (u : ℤ), PlusFormula.top ∈ S.L i u := fun i u =>
    (himp i u PlusFormula.bot PlusFormula.bot (top_mem_pumpClosure p)).mpr (fun h => h)
  have hFback : ∀ v w : ℤ, w = v + 1 →
      (PlusFormula.atom p ∈ S.L (τ w) w ∨ someFuture p ∈ S.L (τ w) w) →
      someFuture p ∈ S.L (τ v) v := by
    intro v w hw h
    subst hw
    refine (huntl (τ v) v (τ (v + 1)) (hτstep v) PlusFormula.top (PlusFormula.atom p)
      (someFuture_mem_pumpClosure p)).mpr ?_
    rcases h with h | h
    · exact Or.inl h
    · exact Or.inr ⟨htp _ _, h⟩
  have hF : ∀ d : ℕ, someFuture p ∈ S.L (τ (u0 + k + 1 - d)) (u0 + k + 1 - d) := by
    intro d
    induction d with
    | zero =>
      refine hFback _ (u0 + k + 2) (by push_cast; ring) (Or.inl ?_)
      exact (hτp k).1 rfl
    | succ d ih =>
      refine hFback _ (u0 + k + 1 - d) (by push_cast; ring) (Or.inr ih)
  -- Step 5: pigeonhole on the thread's index at `n + 1` times one forward period apart.
  have hNF : (0 : ℤ) < S.NF := S.NF_pos
  obtain ⟨x, y, hxy, hg⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun m : Fin (S.lassos.length + 1) => τ (u0 + 2 + (m : ℕ) * S.NF)) (by simp)
  wlog hlt : (x : ℕ) < (y : ℕ) generalizing x y
  · exact this y x hxy.symm hg.symm
      (lt_of_le_of_ne (not_lt.mp hlt) (fun h => hxy (Fin.ext h.symm)))
  have hg' : τ (u0 + 2 + (x : ℕ) * S.NF) = τ (u0 + 2 + (y : ℕ) * S.NF) := hg
  set v : ℤ := u0 + 2 + (x : ℕ) * S.NF with hv
  set v' : ℤ := u0 + 2 + (y : ℕ) * S.NF with hv'
  set c : ℤ := ((y : ℕ) : ℤ) - ((x : ℕ) : ℤ) with hc
  have hcpos : 0 < c := by simp only [hc]; omega
  set D : ℤ := S.NF * c with hD
  have hDpos : 0 < D := mul_pos hNF hcpos
  have hvv' : v' = v + D := by simp only [hv, hv', hD, hc]; ring
  have hvlo : u0 + 2 ≤ v := by
    have : (0 : ℤ) ≤ ((x : ℕ) : ℤ) * S.NF := mul_nonneg (Int.natCast_nonneg _) hNF.le
    simp only [hv]; omega
  have hv'hi : v' ≤ u0 + k + 1 := by
    have hy : ((y : ℕ) : ℤ) ≤ (S.lassos.length : ℤ) := by
      have := y.2
      omega
    have : ((y : ℕ) : ℤ) * S.NF ≤ (S.lassos.length : ℤ) * S.NF :=
      mul_le_mul_of_nonneg_right hy hNF.le
    have hkc : ((k : ℕ) : ℤ) = (S.lassos.length : ℤ) * S.NF + 1 := by
      simp only [hk]; push_cast; rfl
    simp only [hv']; omega
  -- No `p` on the thread strictly between `v` and `v'`.
  have hnop : ∀ w : ℤ, v ≤ w → w < v' → PlusFormula.atom p ∉ S.L (τ w) w := by
    intro w h1 h2
    obtain ⟨m, rfl⟩ : ∃ m : ℕ, w = u0 + m + 2 := ⟨(w - u0 - 2).toNat, by omega⟩
    exact (hτp m).2 (by omega)
  -- Step 6: the looped thread.
  set fold : ℤ → ℤ := fun w => if w < v then w else v + (w - v) % D with hfold
  have hfold_lt : ∀ w, w < v → fold w = w := fun w h => by simp only [hfold, if_pos h]
  have hfold_ge : ∀ w, v ≤ w → fold w = v + (w - v) % D := fun w h => by
    simp only [hfold, if_neg (not_lt.mpr h)]
  have hr_nonneg : ∀ w, 0 ≤ (w - v) % D := fun w => Int.emod_nonneg _ hDpos.ne'
  have hr_lt : ∀ w, (w - v) % D < D := fun w => Int.emod_lt_of_pos _ hDpos
  have hcong : ∀ w, v ≤ w → (w - S.NM) % S.NF = (fold w - S.NM) % S.NF := by
    intro w hw
    rw [hfold_ge w hw]
    have hdecomp : w - v = (w - v) % D + D * ((w - v) / D) := (Int.emod_add_mul_ediv _ _).symm
    have : w - S.NM = (v + (w - v) % D - S.NM) + S.NF * (c * ((w - v) / D)) := by
      have : D * ((w - v) / D) = S.NF * (c * ((w - v) / D)) := by simp only [hD]; ring
      omega
    rw [this, Int.add_mul_emod_self_left]
  have hfold_NM : ∀ w, v ≤ w → S.NM ≤ fold w := by
    intro w hw
    rw [hfold_ge w hw]
    have := hr_nonneg w
    omega
  have hloopstep : ∀ w : ℤ, S.trans w (τ (fold w)) (τ (fold (w + 1))) := by
    intro w
    by_cases hw : w < v
    · have e1 := hfold_lt w hw
      have e2 : fold (w + 1) = w + 1 := by
        by_cases hw' : w + 1 < v
        · exact hfold_lt _ hw'
        · have : w + 1 = v := by omega
          rw [hfold_ge _ (by omega), this]
          simp
      rw [e1, e2]
      exact hτstep w
    · have hw' : v ≤ w := not_lt.mp hw
      have hrn := hr_nonneg w
      have hrl := hr_lt w
      have key : S.trans (fold w) (τ (fold w)) (τ (fold (w + 1))) := by
        rw [hfold_ge w hw', hfold_ge (w + 1) (by omega)]
        have hsplit : w + 1 - v = ((w - v) % D + 1) + D * ((w - v) / D) := by
          have := Int.emod_add_mul_ediv (w - v) D
          omega
        by_cases hwrap : (w - v) % D + 1 < D
        · have : (w + 1 - v) % D = (w - v) % D + 1 := by
            rw [hsplit, Int.add_mul_emod_self_left]
            exact Int.emod_eq_of_lt (by omega) hwrap
          rw [this, show v + ((w - v) % D + 1) = v + (w - v) % D + 1 by ring]
          exact hτstep _
        · have hD' : (w - v) % D + 1 = D := by omega
          have : (w + 1 - v) % D = 0 := by
            rw [hsplit, Int.add_mul_emod_self_left, hD']
            exact Int.emod_self
          rw [this, add_zero]
          have hst := hτstep (v + (w - v) % D)
          rw [show v + (w - v) % D + 1 = v' by rw [hvv']; omega] at hst
          have hgv : τ v' = τ v := hg'.symm
          rw [hgv] at hst
          exact hst
      have hNMw : S.NM ≤ w := by omega
      have hNMf : S.NM ≤ fold w := hfold_NM w hw'
      have hraw : S.transRaw w = S.transRaw (fold w) :=
        S.transRaw_congr_NF hNMw hNMf (hcong w hw')
      have hcong1 : (w + 1 - S.NM) % S.NF = (fold w + 1 - S.NM) % S.NF := by
        have := hcong w hw'
        have e1 : w + 1 - S.NM = (w - S.NM) + 1 := by ring
        have e2 : fold w + 1 - S.NM = (fold w - S.NM) + 1 := by ring
        rw [e1, e2, Int.add_emod, this, ← Int.add_emod]
      have hrep : S.rep (w + 1) = S.rep (fold w + 1) :=
        (S.data_congr_fwd (by omega) (by omega) hcong1).1
      rw [S.trans_def] at key ⊢
      refine ⟨by rw [hraw]; exact key.1, ?_⟩
      rw [S.share_def, hrep]
      exact (S.share_def _ _ _).mp key.2
  have hfoldv : fold v = v := by rw [hfold_ge v le_rfl]; simp
  let θ : S.Thread := ⟨fun w => τ (fold w), hloopstep⟩
  have hθv : θ.idx v = τ v := congrArg τ hfoldv
  -- Step 7: `Fp` at the loop's entry, no `p` anywhere on the loop.
  have hFv : someFuture p ∈ S.L (τ v) v := by
    have := hF (u0 + k + 1 - v).toNat
    rw [show u0 + (k : ℤ) + 1 - ((u0 + (k : ℤ) + 1 - v).toNat : ℤ) = v by omega] at this
    exact this
  obtain ⟨s, hs, hps, -⟩ :=
    hful.1 (τ v) v PlusFormula.top (PlusFormula.atom p) hFv θ hθv
  have hθL : S.L (θ.idx s) s = S.L (τ (fold s)) (fold s) :=
    (S.data_congr_fwd (by omega) (hfold_NM s hs.le) (hcong s hs.le)).2 _
  rw [hθL] at hps
  refine hnop (fold s) ?_ ?_ hps
  · rw [hfold_ge s hs.le]
    have := hr_nonneg s
    omega
  · rw [hfold_ge s hs.le, hvv']
    have := hr_lt s
    omega

/--
**No family certifies `pumpTarget p`**, existentially.

Paper: — (a formalization-native limit; the paper states no such result)
-/
theorem not_exists_plusCertifies_pumpTarget (p : Atom) :
    ¬ ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) (pumpDelta p)) (t : ℤ),
        S.PlusCertifies t :=
  fun ⟨S, t, h⟩ => not_plusCertifies_pumpTarget S t h

/--
**The L⁺ compression statement fails at `pumpTarget p`.**

A genuine ℤ-time non-validity with no certifying family of any size: the two halves of the
counterexample, bundled so that the withdrawal can be cited as one declaration.
-/
theorem plusCompression_fails_at_pumpTarget (p : Atom) :
    ¬ PlusValidZTime (pumpTarget p) ∧
      ¬ ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) (pumpDelta p)) (t : ℤ),
          S.PlusCertifies t :=
  ⟨not_plusValidZTime_pumpTarget p, not_exists_plusCertifies_pumpTarget p⟩

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
