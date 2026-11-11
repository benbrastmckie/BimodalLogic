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

end FormalSystem.Metalogic.Decidability.RaySummary
