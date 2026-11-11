/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

/-!
# The idle pump: the register-anchored iterate, and the sharpened lengthening schema

## Contract

This module holds the idle pump's REGISTER-ANCHORED assembly and nothing else of its own
machinery: the `d`-fold duplication of an idle block that holds the next-deadline register at a
chosen position `z`, holds every countdown at and below the block, lengthens the idle run by
`d · k`, and preserves the realized stab-free type below the block. The pump-layer inputs it
consumes — `idleSpliceCnt` and its three local readings of `Count`, the free pin clause
`idleSplice_pins`, the unanchored lift `exists_idleSpliced_ladderPath`, the idle-cycle vocabulary,
and the idle-restricted `(objAt, tpOf)` pigeonhole — all live in `LadderPump.lean` and are
imported, not restated.

It imports `LadderChain` for ONE declaration, `exists_ladderPath_of_walk_nxt_at`: the only landed
lift that exposes the register at a chosen position rather than at the hardwired origin, which is
what the schema's register clause `nxtAt g' z = nxtAt g z` reads. That lift sits downstream of
`LadderPump.lean`, which is why this module exists at all rather than the content landing beside
its inputs.

Nothing imports this module. It states NO cell-level consequence: no `cellAt` claim, no
agreement of class-equivalent cells, and no discharge of any obligation reserved in
`LadderCell.lean`. The premise it runs on is an OBJECT/RUN hypothesis and not a consequence of
`ParamsOk` (`idle_run_lt_tIdle_of_no_idleCycle`, `LadderPump.lean`, is the bound without it), so
it cannot and does not remove a `ParamsOk`-level restriction anywhere.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The register-anchored iterated idle pump

`exists_idleSpliced_ladderPath` duplicates an idle block once, with no pin side condition, but
the lift it uses exposes no register value. The iterate below re-performs the duplication through
`exists_ladderPath_of_walk_nxt_at` instead, anchored at `z`, so the register at `z` survives
every step. The anchor condition that lift asks for is discharged from `idleSplice_pull`'s
classification exactly as the pin clause is: a pin of the spliced walk is a pin of the original
at `v` or at `v - k`, its countdown is the register's value there
(`cntAt_eq_nxtAt_of_idle_pend`), the register is two-sidedly `1`-Lipschitz
(`nxtAt_lipschitz_two_sided`), and the displaced class lies ABOVE the block and hence above `z`,
so its distance to `z` only shrinks.

The induction carries one clause more than the statement exposes: the realized type at `a + k`
itself, which is `tpOf σ a`. That clause is what forms the next step's own `hty` hypothesis, and
it is dropped at the end because the pump's consumers read the type only strictly below the
block, mirroring the exposure discipline `exists_iterSpliced_ladderPath_of_pend_past` follows. -/

section Iterate

-- `linter.unusedFintypeInType`, scoped to this declaration: the signature is pinned by the
-- plan's Lean Challenge Statements block. `[Fintype Q]` is read inside the proof (by
-- `tpOf_eq_spliceIdx_of_tpOf_eq`) but not by the statement, and it is the instance shape every
-- declaration of the idle layer carries; weakening it here alone would split that shape.
set_option linter.unusedFintypeInType false in
/-- **THE ITERATED IDLE PUMP, WITH THE REGISTER HELD AT `z`.** `d` duplications of an idle block
`[a, a + k)` whose two ends carry the same object state and the same realized stab-free type: the
walk agrees with the original at every position strictly below `a + k` in BOTH the object and the
countdown, the next-deadline register at `z` is unmoved, the idle run at `a` has length
`(d + 1) · k`, the walk from `a + (d + 1) k` on is the original `d · k` earlier, and the realized
type below `a + k` is the original's.

No pin side condition, no pending-forever regime hypothesis, and no `ParamsOk`: the idle-block
surgery consumes none of them. What it does consume is the premise — the block, its idleness, its
endpoint object repeat and its endpoint type repeat — which is a datum of the object's step graph
met by this path. -/
theorem exists_iterIdleSpliced_ladderPath {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (z a : ℤ) (k : ℕ) (hk : 0 < k) (hza : z < a)
    (hidle : ∀ i : ℕ, i < k → pend (objAt g (a + (i : ℤ))) = false)
    (hrep : objAt g a = objAt g (a + (k : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ a
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, v < a + (k : ℤ) → objAt g' v = objAt g v ∧ cntAt g' v = cntAt g v) ∧
      nxtAt g' z = nxtAt g z ∧
      (∀ i : ℕ, i < (d + 1) * k → pend (objAt g' (a + (i : ℤ))) = false) ∧
      (∀ v : ℤ, a + (((d + 1) * k : ℕ) : ℤ) ≤ v →
        objAt g' v = objAt g (v - ((d * k : ℕ) : ℤ)) ∧
          cntAt g' v = cntAt g (v - ((d * k : ℕ) : ℤ))) ∧
      (∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, w < a + (k : ℤ) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' w
            = tpOf (ladderModel step pend fwd bwd lab) φ σ w) := by
  -- the induction carries the realized type at `a + k` as well; the statement drops it
  suffices H : ∀ e : ℕ, ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, v < a + (k : ℤ) → objAt g' v = objAt g v ∧ cntAt g' v = cntAt g v) ∧
      nxtAt g' z = nxtAt g z ∧
      (∀ i : ℕ, i < (e + 1) * k → pend (objAt g' (a + (i : ℤ))) = false) ∧
      (∀ v : ℤ, a + (((e + 1) * k : ℕ) : ℤ) ≤ v →
        objAt g' v = objAt g (v - ((e * k : ℕ) : ℤ)) ∧
          cntAt g' v = cntAt g (v - ((e * k : ℕ) : ℤ))) ∧
      objAt g' (a + (k : ℤ)) = objAt g a ∧
      (∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        (∀ w : ℤ, w < a + (k : ℤ) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' w
            = tpOf (ladderModel step pend fwd bwd lab) φ σ w) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ' (a + (k : ℤ))
          = tpOf (ladderModel step pend fwd bwd lab) φ σ a) by
    obtain ⟨g', hg', hbelow, hnxt, hrun, habove, -, htyc⟩ := H d
    exact ⟨g', hg', hbelow, hnxt, hrun, habove, fun σ' hσ' w hw => (htyc σ' hσ').1 w hw⟩
  intro e
  induction e with
  | zero =>
      refine ⟨g, hg, fun _ _ => ⟨rfl, rfl⟩, rfl, fun i hi => hidle i (by omega),
        fun v _ => ?_, hrep.symm, fun σ' hσ' => ⟨fun w _ => ?_, ?_⟩⟩
      · simp
      · exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := (0 : ℤ)) (k' := (0 : ℤ)) σ' σ
          (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
          (fun _ => rfl) hno w
      · rw [tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := (0 : ℤ)) (k' := (0 : ℤ)) σ' σ
          (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
          (fun _ => rfl) hno (a + (k : ℤ)), hty]
  | succ e ih =>
      obtain ⟨g₁, hg₁, hbelow₁, hnxt₁, hrun₁, habove₁, hend₁, htyc₁⟩ := ih
      have hkle : k ≤ (e + 1) * k := Nat.le_mul_of_pos_left k (by omega)
      have n1 : (e + 1 + 1) * k = (e + 1) * k + k := by ring
      have e1 : (((e + 1) * k : ℕ) : ℤ) = (e : ℤ) * k + k := by push_cast; ring
      have e2 : (((e + 1 + 1) * k : ℕ) : ℤ) = (e : ℤ) * k + k + k := by push_cast; ring
      have e0 : ((e * k : ℕ) : ℤ) = (e : ℤ) * k := by push_cast; ring
      have hek : (0 : ℤ) ≤ (e : ℤ) * k := by
        have h := Int.natCast_nonneg (e * k)
        rwa [e0] at h
      -- the block of `g₁` is still idle and still carries the endpoint object repeat
      have hidle₁ : ∀ i : ℕ, i < k → pend (objAt g₁ (a + (i : ℤ))) = false :=
        fun i hi => hrun₁ i (by omega)
      have hrep₁ : objAt g₁ a = objAt g₁ (a + (k : ℤ)) := by
        rw [(hbelow₁ a (by omega)).1, hend₁]
      -- the anchor condition of the register-exposing lift
      have hanch : ∀ v : ℤ, pend (spliceObj g₁ a k v) = false →
          pend (spliceObj g₁ a k (v + 1)) = true →
          ((idleSpliceCnt g₁ a k (v + 1) : ℤ) - nxtAt g₁ z).natAbs ≤ (v - z).natAbs := by
        intro v hv0 hv1
        obtain ⟨t, ht0, ht1, htc, htcase⟩ := idleSplice_pull hk hidle₁ v hv0 hv1
        rw [htc, cntAt_eq_nxtAt_of_idle_pend g₁ hg₁ t ht0 ht1]
        refine le_trans (nxtAt_lipschitz_two_sided g₁ hg₁ t z) ?_
        rcases htcase with ⟨hte, htb⟩ | ⟨hte, htb⟩ <;> omega
      obtain ⟨g₂, hg₂, hobj₂, hcnt₂, hnxt₂⟩ :=
        exists_ladderPath_of_walk_nxt_at (spliceObj g₁ a k) (idleSpliceCnt g₁ a k) z
          (nxtAt g₁ z) (spliceObj_step hg₁ hrep₁) (idleSpliceCnt_idle hg₁)
          (idleSpliceCnt_pend_pend hg₁ hk hidle₁) (idleSpliceCnt_pend_idle hg₁ hk hidle₁)
          (idleSplice_pins hg₁ hk hidle₁) hanch
      refine ⟨g₂, hg₂, fun v hv => ⟨?_, ?_⟩, hnxt₂.trans hnxt₁, fun i hi => ?_,
        fun v hv => ?_, ?_, fun σ₂ hσ₂ => ?_⟩
      · rw [hobj₂ v, spliceObj_of_lt v hv, (hbelow₁ v hv).1]
      · rw [hcnt₂ v, idleSpliceCnt_of_lt v hv, (hbelow₁ v hv).2]
      · -- the `(e + 2) · k` copies are idle: each reads a position of the original block
        rw [n1] at hi
        rw [hobj₂ (a + (i : ℤ))]
        by_cases hik : i < k
        · rw [spliceObj_of_lt (a + (i : ℤ)) (by omega)]
          exact hrun₁ i (by omega)
        · rw [spliceObj_of_ge (a + (i : ℤ)) (by omega),
            show a + (i : ℤ) - (k : ℤ) = a + ((i - k : ℕ) : ℤ) by
              rw [Nat.cast_sub (by omega)]; ring]
          exact hrun₁ (i - k) (by omega)
      · -- above the copies the walk is the original, `(e + 1) · k` earlier
        rw [e2] at hv
        have hvk : a + (((e + 1) * k : ℕ) : ℤ) ≤ v - (k : ℤ) := by rw [e1]; omega
        obtain ⟨ho, hc⟩ := habove₁ (v - (k : ℤ)) hvk
        refine ⟨?_, ?_⟩
        · rw [hobj₂ v, spliceObj_of_ge v (by omega), ho]
          congr 1
          rw [e0, e1]; omega
        · rw [hcnt₂ v, idleSpliceCnt_of_ge v (by omega), hc]
          congr 1
          rw [e0, e1]; omega
      · rw [hobj₂ (a + (k : ℤ)), spliceObj_of_ge (a + (k : ℤ)) le_rfl,
          show a + (k : ℤ) - (k : ℤ) = a by ring, (hbelow₁ a (by omega)).1]
      · obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
        obtain ⟨hlt₁, hend_ty₁⟩ := htyc₁ σ₁ hσ₁
        have hty₁ : tpOf (ladderModel step pend fwd bwd lab) φ σ₁ a
            = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (a + (k : ℤ)) := by
          rw [hlt₁ a (by omega), hend_ty₁]
        have hobj₂' : ∀ w : ℤ, objAt g₂ w = objAt g₁ (spliceIdx a k w) := fun w => by
          rw [hobj₂ w, spliceObj_eq_objAt_spliceIdx]
        have htr := tpOf_eq_spliceIdx_of_tpOf_eq step pend fwd bwd lab φ a k hk
          (k := (0 : ℤ)) (k' := (0 : ℤ)) σ₁ σ₂
          (fun t => by rw [add_zero]; exact hσ₁ t) (fun t => by rw [add_zero]; exact hσ₂ t)
          hobj₂' hno hty₁
        refine ⟨fun w hw => ?_, ?_⟩
        · rw [htr w, spliceIdx_of_lt a k w hw, hlt₁ w hw]
        · rw [htr (a + (k : ℤ)), spliceIdx_of_ge a k (a + (k : ℤ)) le_rfl,
            show a + (k : ℤ) - (k : ℤ) = a by ring, hlt₁ a (by omega)]

end Iterate

/-! ## The sharpened lengthening schema, and its verdict

`Probe838C.IdleGapLengthening`
(`specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean`) is
REFUTED: `idleGapLengthening_refuted` exhibits a two-state object with no idle-to-idle edge, on
which no ladder path whatever carries an idle run of length two, so the lengthening is denied one
level below the pin condition — by `step` itself. The schema below is the sharpening that
refutation's own docstring names as open: the premise under which the lengthening IS available,
stated explicitly as a run-local hypothesis, with the increment restricted to the multiples of
the repeat length.

Two differences from the refuted schema are deliberate and are recorded here rather than left to
be inferred. `ParamsOk` and `Tc ≤ cntAt g z` are NOT hypotheses: the construction is pure
idle-run surgery and consumes neither, so dropping both makes this schema strictly stronger than
the corresponding restriction of the original. And the free increment `l` is replaced by `d · k`,
`k` being the repeat length — not a weakening for convenience but a necessity, which
`IdleGapLengtheningAllIncrements` and its refutation below compile. -/

section Schema

/-- **THE SHARPENED LENGTHENING.** The idle gap above `z`'s region may be lengthened by `d · k`
when the run carries a `k`-block matching in object state and in realized type — the idle-cycle
premise, met inside the run rather than merely somewhere in the object. `ParamsOk` and
`Tc ≤ cntAt g z` are NOT hypotheses: the construction is idle-run surgery and consumes neither.

The premise is a datum of the object's step graph MET BY THIS PATH, and it is not a consequence
of `ParamsOk`: `idle_run_lt_tIdle_of_no_idleCycle` (`LadderPump.lean`) is the generic bound
without an idle cycle, and nothing in the parameter conditions supplies one. Assuming it is a
restriction of the obligation, never a proof of it. -/
def IdleGapLengtheningOfIdleRunRepeat {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : Prop :=
  (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
    ∀ (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      (∀ t : ℤ, σ.state t = (t, g t)) →
    ∀ (z : ℤ) (I k d : ℕ) (a : ℤ),
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) →
      nxtAt g z + 2 ≤ cntAt g z →
      0 < I → 0 < k → 0 < d →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      z + (cntAt g z : ℤ) + 1 ≤ a →
      a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ) →
      objAt g a = objAt g (a + (k : ℤ)) →
      tpOf (ladderModel step pend fwd bwd lab) φ σ a
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)) →
      ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
        objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
        (∀ i : ℕ, i < I + d * k →
          pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + (i : ℤ))) = false) ∧
        pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + d * k : ℕ) : ℤ))) = true ∧
        cntAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + d * k : ℕ) : ℤ))
          = cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) ∧
        ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
          (∀ t : ℤ, σ'.state t = (t, g' t)) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' z
            = tpOf (ladderModel step pend fwd bwd lab) φ σ z

/-- **THE SHARPENED LENGTHENING IS A THEOREM.** `exists_iterIdleSpliced_ladderPath` applied at
the block the premise supplies, with the schema's seven conclusion clauses read off the pump's:
the three agreements at `z` from the below-block clause and the register clause; the lengthened
run from the below-block, pumped-run and shift clauses together, split at `a` and at
`a + (d + 1) k`; the displaced region start and its countdown from the shift clause; and the type
at `z` from the type clause, `z` lying below the block.

**Sub-question (ii), TYPE PRESERVATION, is DISCHARGED here and not deferred.** The idle-gap
decision gate never reached it: its refutation closed from `step` alone. Here the premise's block
matches in realized type as well as in object state, and
`exists_idleTypeBlock_of_budget_le_run` is what produces such a block from a long enough run, so
the type clause the FAIL verdict left untouched follows rather than being assumed away.

Four of the schema's own hypotheses are NOT consumed by this proof — the pending-forever past,
the gap `nxtAt g z + 2 ≤ cntAt g z`, `0 < I`, and `0 < d`. They are kept because the schema is
stated in the shape its intended consumer uses, clause for clause against the refuted original;
the proof not reading them records that the construction is available more widely than the
schema asks, never that the schema asks for too little. -/
theorem idleGapLengtheningOfIdleRunRepeat_holds {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) :
    IdleGapLengtheningOfIdleRunRepeat step pend fwd bwd lab φ := by
  intro hno g hg σ hσ z I k d a _ _ _ hk _ hrun hstart hRa hak hrep hty
  set R : ℤ := z + (cntAt g z : ℤ) + 1 with hR
  have nd : (d + 1) * k = d * k + k := by ring
  have zd : (((d + 1) * k : ℕ) : ℤ) = ((d * k : ℕ) : ℤ) + (k : ℤ) := by
    rw [nd]; push_cast; ring
  have hsplit : ((I + d * k : ℕ) : ℤ) = (I : ℤ) + ((d * k : ℕ) : ℤ) := by push_cast; ring
  have hza : z < a := by omega
  -- the block lies inside the run, so it is idle throughout
  have hidleBlk : ∀ i : ℕ, i < k → pend (objAt g (a + (i : ℤ))) = false := by
    intro i hi
    have h := hrun (a + (i : ℤ) - R).toNat (by omega)
    rw [show R + (((a + (i : ℤ) - R).toNat : ℕ) : ℤ) = a + (i : ℤ) by omega] at h
    exact h
  obtain ⟨g', hg', hbelow, hnxt, hpumprun, habove, htyc⟩ :=
    exists_iterIdleSpliced_ladderPath step pend fwd bwd lab φ hno hg z a k hk hza hidleBlk
      hrep σ hσ hty d
  have hoz : objAt g' z = objAt g z := (hbelow z (by omega)).1
  have hcz : cntAt g' z = cntAt g z := (hbelow z (by omega)).2
  have hpos : ∀ i : ℤ, z + (cntAt g' z : ℤ) + 1 + i = R + i := by
    intro i; rw [hcz, hR]
  -- the displaced region start lies above the copies
  have hge : a + (((d + 1) * k : ℕ) : ℤ) ≤ R + ((I + d * k : ℕ) : ℤ) := by
    rw [zd, hsplit]; omega
  obtain ⟨hstartObj, hstartCnt⟩ := habove (R + ((I + d * k : ℕ) : ℤ)) hge
  have hback : R + ((I + d * k : ℕ) : ℤ) - ((d * k : ℕ) : ℤ) = R + (I : ℤ) := by
    rw [hsplit]; ring
  refine ⟨g', hg', hoz, hcz, hnxt, fun i hi => ?_, ?_, ?_, fun σ' hσ' => ?_⟩
  · rw [hpos (i : ℤ)]
    by_cases hc : R + (i : ℤ) < a + (((d + 1) * k : ℕ) : ℤ)
    · by_cases hlow : R + (i : ℤ) < a
      · -- below the block: the walk is the original, and the position is in the original run
        rw [(hbelow (R + (i : ℤ)) (by omega)).1]
        have h := hrun i (by omega)
        exact h
      · -- inside the `(d + 1) · k` copies
        have h := hpumprun (R + (i : ℤ) - a).toNat (by omega)
        rw [show a + (((R + (i : ℤ) - a).toNat : ℕ) : ℤ) = R + (i : ℤ) by omega] at h
        exact h
    · -- above the copies: the walk is the original, `d · k` earlier
      obtain ⟨ho, -⟩ := habove (R + (i : ℤ)) (by omega)
      rw [ho]
      have h := hrun (i - d * k) (by omega)
      rw [show R + ((i - d * k : ℕ) : ℤ) = R + (i : ℤ) - ((d * k : ℕ) : ℤ) by
        rw [Nat.cast_sub (by omega)]; ring] at h
      exact h
  · rw [hpos ((I + d * k : ℕ) : ℤ), hstartObj, hback]
    exact hstart
  · rw [hpos ((I + d * k : ℕ) : ℤ), hstartCnt, hback]
  · exact htyc σ' hσ' z (by omega)

end Schema

end FormalSystem.Metalogic.Decidability.RaySummary
