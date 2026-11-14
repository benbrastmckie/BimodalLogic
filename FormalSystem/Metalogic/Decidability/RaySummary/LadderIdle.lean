/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

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

It imports `LadderCell` for VOCABULARY only — `ForwardSlackWitnessed`, in whose terms the final
section's cell-level conclusion is phrased. The edge is acyclic: `LadderCell` imports
`LadderChain`, not this module.

`LadderWindow.lean` imports this module. It states a CONDITIONAL cell-level consequence —
`forwardSlackWitnessed_of_cell_idleRunPumpable`, the final section — which discharges NOTHING
reserved in `LadderCell.lean`. The premise it runs on is an OBJECT/RUN hypothesis and not a
consequence of `ParamsOk` (`idle_run_lt_tIdle_of_no_idleCycle`, `LadderPump.lean`, is the bound
without it), so it cannot and does not remove a `ParamsOk`-level restriction anywhere, and
`ForwardSlackWitnessed` stays a carried hypothesis on all five depth-`0` cell-equality schemas of
`LadderCell.lean`.

## What this buys

Three determinations, each against a named declaration, about the idle-gap lengthening whose
unrestricted schema is REFUTED by the compiled prototype `idleGapLengthening_refuted` (namespace
`Probe838C`), the decision gate's own evidence record.

**(i) ADMISSIBILITY is available under the run-repeat premise, with the increment restricted to
the multiples of the repeat length.** `idleGapLengtheningOfIdleRunRepeat_holds` is the theorem.
The premise is run-local: a block of the idle run whose two ends carry the same object state and
the same realized type. The pin clause — the one the FAIL verdict's own docstring predicted would
loosen — does not merely loosen, it DISCHARGES OUTRIGHT: `idleSplice_pins` (`LadderPump.lean`)
carries no regime hypothesis, no endpoint repeat and no side condition, because the duplicated
idle block contributes no pin of its own and the pins above it move farther from those below
while their values stay put. The restriction to multiples of `k` is a necessity and not a
convenience: `idleGapLengtheningAllIncrements_refuted` compiles the exclusion.

**(ii) TYPE PRESERVATION is DISCHARGED, not untouched.** The decision gate never reached its
sub-question (ii): the refutation closed from `step` alone. The premise route here runs through
the idle-restricted `(objAt, tpOf)` pigeonhole (`exists_idleTypeBlock_of_budget_le_run`), which
hands back a block matching in realized type as well as in object state, and the landed
duplication type lemma (`tpOf_eq_spliceIdx_of_tpOf_eq`) then preserves the realized type at every
position below the block — `z` among them. The type clause is therefore proved, not assumed away.

**(iii) The premise is an object/run hypothesis and NOT a consequence of `ParamsOk`, so NOTHING
here is claimed about the cell-level obligations.** `idle_run_lt_tIdle_of_no_idleCycle`
(`LadderPump.lean`) is the bound in the other direction: without an idle cycle every idle run is
shorter than `tIdle pend`, so no parameter condition supplies the premise and assuming it is a
RESTRICTION of an obligation rather than a proof of one. In particular: the
`ForwardSlackWitnessed` hypothesis of `cellAt_subset_of_shift_of_pend_past_rev` is NOT removed,
the reserved unrestricted cell obligation stays reserved, and `LadderCell.lean` is not edited.
That is a statement about what is NOT claimed.
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

The unrestricted schema `IdleGapLengthening` of the idle-gap decision gate (namespace
`Probe838C`, a compiled standalone prototype) is
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

/-! ## The increment is NOT free, even under the premise

The sharpened schema restricts the increment to the multiples of the repeat length `k`. That
restriction is a NECESSITY and not a convenience: an object whose idle states carry a `2`-cycle
and no self-loop admits only EVEN-length idle runs, so a run of length `4` meeting the premise at
`k = 2` admits no lengthening to `5` whatever. `IdleGapLengtheningAllIncrements` names the
freed-increment form so the verdict on it is a theorem about a named object, and
`idleGapLengtheningAllIncrements_refuted` is that verdict.

The witness is declared fresh rather than reused: the sibling probes' objects admit every edge
(`stepC = fun _ _ => true`) or have a single idle state, and neither carries this exclusion. -/

section Freed

/-- **THE FREED-INCREMENT FORM.** `IdleGapLengtheningOfIdleRunRepeat` with the increment freed
from the multiples of the repeat length: every clause is identical, including the run-repeat
premise, and only `d * k` is replaced by an unconstrained `l`. Named so the verdict on it is a
theorem about a named object. -/
def IdleGapLengtheningAllIncrements {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : Prop :=
  (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
    ∀ (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      (∀ t : ℤ, σ.state t = (t, g t)) →
    ∀ (z : ℤ) (I k l : ℕ) (a : ℤ),
      (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) →
      nxtAt g z + 2 ≤ cntAt g z →
      0 < I → 0 < k → 0 < l →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      z + (cntAt g z : ℤ) + 1 ≤ a →
      a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ) →
      objAt g a = objAt g (a + (k : ℤ)) →
      tpOf (ladderModel step pend fwd bwd lab) φ σ a
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)) →
      ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
        objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
        (∀ i : ℕ, i < I + l →
          pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + (i : ℤ))) = false) ∧
        pend (objAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + l : ℕ) : ℤ))) = true ∧
        cntAt g' (z + (cntAt g' z : ℤ) + 1 + ((I + l : ℕ) : ℤ))
          = cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) ∧
        ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
          (∀ t : ℤ, σ'.state t = (t, g' t)) →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' z
            = tpOf (ladderModel step pend fwd bwd lab) φ σ z

/-! ### The refuting object: one pending state, two idle states, and a `2`-cycle between them

Three states with exactly five admitted edges — `pnd → pnd`, `pnd → idl0`, `idl0 → idl1`,
`idl1 → idl0`, `idl1 → pnd`. The four denied ones carry the exclusion: `idl0 → idl0` and
`idl1 → idl1` deny an idle self-loop, `idl0 → pnd` denies an exit from `idl0`, and
`pnd → idl1` denies an entry at `idl1`. So every idle run BEGINS at `idl0`, alternates, ENDS at
`idl1`, and therefore has EVEN length. -/

namespace IdleIncrementWitness

/-- The witness object: one pending state and two idle states. -/
inductive QI where
  /-- The pending state. -/
  | pnd : QI
  /-- The idle state an idle run begins at. -/
  | idl0 : QI
  /-- The idle state an idle run ends at. -/
  | idl1 : QI
  deriving DecidableEq

/-- The three states, as a `Fintype`. Written out rather than derived: the `Fintype` deriving
handler's generated membership proof does not elaborate on this toolchain. -/
instance : Fintype QI :=
  ⟨{QI.pnd, QI.idl0, QI.idl1}, fun x => by cases x <;> decide⟩

instance : Inhabited QI := ⟨QI.pnd⟩

instance : Nonempty QI := ⟨QI.pnd⟩

/-- `pnd` is the pending state; both `idl0` and `idl1` are idle. -/
def pendI : QI → Bool
  | .pnd => true
  | .idl0 => false
  | .idl1 => false

/-- The five admitted edges, and no others. -/
def stepI : QI → QI → Bool
  | .pnd, .pnd => true
  | .pnd, .idl0 => true
  | .idl0, .idl1 => true
  | .idl1, .idl0 => true
  | .idl1, .pnd => true
  | _, _ => false

/-- The denied edges, read off the table: no idle self-loop, no exit from `idl0`, and no entry
at `idl1` from the pending state. The parity argument rests on this table and on nothing else. -/
theorem stepI_denied :
    stepI QI.idl0 QI.idl0 = false ∧ stepI QI.idl1 QI.idl1 = false ∧
      stepI QI.idl0 QI.pnd = false ∧ stepI QI.pnd QI.idl1 = false := by decide

theorem pendI_eq_true_iff : ∀ q : QI, pendI q = true ↔ q = QI.pnd := by decide

/-- **An idle run begins at `idl0`**: the only admitted pending-to-idle edge is `pnd → idl0`. -/
theorem stepI_pnd_idle : ∀ x y : QI, pendI x = true → pendI y = false → stepI x y = true →
    y = QI.idl0 := by decide

/-- **An idle run ends at `idl1`**: the only admitted idle-to-pending edge is `idl1 → pnd`. -/
theorem stepI_idle_pnd : ∀ x y : QI, pendI y = true → stepI x y = true → pendI x = false →
    x = QI.idl1 := by decide

/-- **Inside an idle run the walk alternates**: from `idl0` the only admitted idle successor is
`idl1`. -/
theorem stepI_idl0_idle : ∀ y : QI, pendI y = false → stepI QI.idl0 y = true →
    y = QI.idl1 := by decide

/-- **Inside an idle run the walk alternates**: from `idl1` the only admitted idle successor is
`idl0`. -/
theorem stepI_idl1_idle : ∀ y : QI, pendI y = false → stepI QI.idl1 y = true →
    y = QI.idl0 := by decide

/-- A pending triple is admissible at any pair of counters. -/
theorem admPndI (c n : ℕ) :
    ((QI.pnd, c, n) : QI × ℕ × ℕ).2.1 ∈ Adm pendI ((QI.pnd, c, n) : QI × ℕ × ℕ).1 :=
  fun h => by simp [pendI] at h

/-- **The witness object is serial forwards on the admissible carrier.** An idle state carries
countdown `0` and steps to the other idle state; a pending state at countdown `0` steps to
`idl0`, and at countdown `d + 1` stays pending. -/
theorem fwdI : ∀ (t : ℤ) (x : LadderState QI pendI), ∃ y, RladAdm stepI pendI t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  cases q with
  | pnd =>
      cases c with
      | zero =>
          exact ⟨⟨(QI.idl0, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, by simp [Count, pendI]⟩
      | succ d =>
          exact ⟨⟨(QI.pnd, d, n), admPndI d n⟩, rfl, hx, Or.inl rfl, by simp [Count, pendI]⟩
  | idl0 =>
      have hc : c = 0 := hx rfl
      subst hc
      exact ⟨⟨(QI.idl1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, by simp [Count, pendI]⟩
  | idl1 =>
      have hc : c = 0 := hx rfl
      subst hc
      exact ⟨⟨(QI.idl0, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, by simp [Count, pendI]⟩

/-- **The witness object is serial backwards on the admissible carrier.** A pending state is
reached from the pending state one countdown higher; `idl0` is reached from the pending state at
countdown `0`; and `idl1` is reached from `idl0`, which is the only edge into it. -/
theorem bwdI : ∀ (t : ℤ) (x : LadderState QI pendI), ∃ y, RladAdm stepI pendI (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  cases q with
  | pnd =>
      exact ⟨⟨(QI.pnd, c + 1, n), admPndI (c + 1) n⟩, rfl, admPndI (c + 1) n, Or.inl rfl,
        by simp [Count, pendI]⟩
  | idl0 =>
      have hc : c = 0 := hx rfl
      subst hc
      exact ⟨⟨(QI.pnd, 0, n), admPndI 0 n⟩, rfl, admPndI 0 n, Or.inl rfl,
        by simp [Count, pendI]⟩
  | idl1 =>
      have hc : c = 0 := hx rfl
      subst hc
      exact ⟨⟨(QI.idl0, 0, n), fun _ => rfl⟩, rfl, fun _ => rfl, Or.inl rfl,
        by simp [Count, pendI]⟩

/-! ### The stab-free atomic closure -/

/-- The single atom the witness reads. -/
def pI : Atom := ⟨"p", none⟩

/-- The labelling: the atom holds exactly at the pending state. -/
def labI : QI → Atom → Bool := fun q at_ => decide (at_ = pI ∧ q = QI.pnd)

/-- The stab-free atomic formula the witness is run at. -/
def aI : PlusFormula := .atom pI

theorem closure_aI : plusSubformulaClosure aI = {aI} := by
  simp [plusSubformulaClosure, aI, PlusFormula.subformulas]

theorem no_stab_in_closure_aI :
    ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure aI := by
  intro χ h
  rw [closure_aI, Finset.mem_singleton] at h
  exact PlusFormula.noConfusion h

/-- **At an atomic closure the realized type is a datum of the object state alone.** Two
positions of one history carrying the same object state realize the same type, because the
closure is the singleton `{aI}` and an atomic letter's bit is `lab` at the position's own object
state (`atom_mem_tpOf_ladder_iff`). This is what makes the run-repeat premise's TYPE clause
checkable on the witness without any periodicity hypothesis. -/
theorem tpOf_aI_eq_of_objAt_eq {g : ℤ → LadderState QI pendI}
    (σ : WorldHistory (ladderFrameAdm stepI pendI fwdI bwdI).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t)) (u v : ℤ) (h : objAt g u = objAt g v) :
    tpOf (ladderModel stepI pendI fwdI bwdI labI) aI σ u
      = tpOf (ladderModel stepI pendI fwdI bwdI labI) aI σ v := by
  have hσ' : ∀ t : ℤ, σ.state t = (t + (0 : ℤ), g t) := fun t => by rw [add_zero]; exact hσ t
  ext ψ
  by_cases hmem : ψ ∈ plusSubformulaClosure aI
  · have hψ : ψ = aI := by rw [closure_aI, Finset.mem_singleton] at hmem; exact hmem
    subst hψ
    change PlusFormula.atom pI ∈ _ ↔ PlusFormula.atom pI ∈ _
    rw [atom_mem_tpOf_ladder_iff fwdI bwdI labI aI σ hσ' u pI,
      atom_mem_tpOf_ladder_iff fwdI bwdI labI aI σ hσ' v pI, h]
  · simp [mem_tpOf_iff, hmem]

/-! ### The witnessing path: one long region through `0`, then idle runs of length exactly four

`wI C` is pending at every position at or below `C` and above it is periodic with period `5`:
four idle positions `idl0, idl1, idl0, idl1` then one pending. The countdown `cI C` is the
distance up to `C`, clipped at `0`, which is the countdown the region through `0` forces together
with the singleton regions above it; the register is constantly `0`, which the pins allow because
every pin hands its region start the countdown `0`. -/

/-- The witnessing walk. -/
def wI (C : ℕ) : ℤ → QI := fun v =>
  if v ≤ (C : ℤ) then QI.pnd
  else if (v - (C : ℤ)) % 5 = 1 then QI.idl0
  else if (v - (C : ℤ)) % 5 = 2 then QI.idl1
  else if (v - (C : ℤ)) % 5 = 3 then QI.idl0
  else if (v - (C : ℤ)) % 5 = 4 then QI.idl1
  else QI.pnd

/-- The countdown the witnessing walk forces. -/
def cI (C : ℕ) : ℤ → ℕ := fun v => ((C : ℤ) - v).toNat

theorem wI_of_le (C : ℕ) (v : ℤ) (h : v ≤ (C : ℤ)) : wI C v = QI.pnd := by
  simp only [wI, if_pos h]

theorem wI_pnd_iff (C : ℕ) (v : ℤ) :
    wI C v = QI.pnd ↔ (v ≤ (C : ℤ) ∨ (v - (C : ℤ)) % 5 = 0) := by
  have hm : (v - (C : ℤ)) % 5 = 0 ∨ (v - (C : ℤ)) % 5 = 1 ∨ (v - (C : ℤ)) % 5 = 2 ∨
      (v - (C : ℤ)) % 5 = 3 ∨ (v - (C : ℤ)) % 5 = 4 := by omega
  by_cases h1 : v ≤ (C : ℤ)
  · simp [wI, h1]
  · rcases hm with h | h | h | h | h <;> simp [wI, h1, h]

theorem pendI_wI_true_iff (C : ℕ) (v : ℤ) :
    pendI (wI C v) = true ↔ (v ≤ (C : ℤ) ∨ (v - (C : ℤ)) % 5 = 0) :=
  (pendI_eq_true_iff _).trans (wI_pnd_iff C v)

theorem pendI_wI_false_iff (C : ℕ) (v : ℤ) :
    pendI (wI C v) = false ↔ ((C : ℤ) < v ∧ ¬ (v - (C : ℤ)) % 5 = 0) := by
  rw [← Bool.not_eq_true, pendI_wI_true_iff]
  omega

theorem wI_eq_idl0_of_mod_one (C : ℕ) (v : ℤ) (h1 : (C : ℤ) < v)
    (h : (v - (C : ℤ)) % 5 = 1) : wI C v = QI.idl0 := by
  have hnl : ¬ v ≤ (C : ℤ) := by omega
  simp [wI, hnl, h]

theorem wI_eq_idl0_of_mod_three (C : ℕ) (v : ℤ) (h1 : (C : ℤ) < v)
    (h : (v - (C : ℤ)) % 5 = 3) : wI C v = QI.idl0 := by
  have hnl : ¬ v ≤ (C : ℤ) := by omega
  simp [wI, hnl, h]

/-- **The witnessing walk with its forced countdown lifts to a ladder path whose register at `0`
is `0`.** Through `exists_ladderPath_of_walk_nxt_at`, the lift that exposes the register at a
chosen position — here the origin. -/
theorem exists_gI (C : ℕ) : ∃ g : ℤ → LadderState QI pendI, IsLadderPath stepI pendI g ∧
    (∀ v, objAt g v = wI C v) ∧ (∀ v, cntAt g v = cI C v) ∧ nxtAt g 0 = 0 := by
  refine exists_ladderPath_of_walk_nxt_at (wI C) (cI C) 0 0 ?_ ?_ ?_ ?_ ?_ ?_
  · -- the walk steps along `stepI` at every position
    intro v
    have hm : (v - (C : ℤ)) % 5 = 0 ∨ (v - (C : ℤ)) % 5 = 1 ∨ (v - (C : ℤ)) % 5 = 2 ∨
        (v - (C : ℤ)) % 5 = 3 ∨ (v - (C : ℤ)) % 5 = 4 := by omega
    by_cases h1 : v + 1 ≤ (C : ℤ)
    · rw [wI_of_le C v (by omega), wI_of_le C (v + 1) h1]
      decide
    · by_cases h2 : v ≤ (C : ℤ)
      · have hv : v = (C : ℤ) := by omega
        subst hv
        rw [wI_of_le C (C : ℤ) le_rfl,
          wI_eq_idl0_of_mod_one C ((C : ℤ) + 1) (by omega) (by omega)]
        decide
      · rcases hm with h | h | h | h | h
        · have h' : (v + 1 - (C : ℤ)) % 5 = 1 := by omega
          simp [wI, h1, h2, h, h', stepI]
        · have h' : (v + 1 - (C : ℤ)) % 5 = 2 := by omega
          simp [wI, h1, h2, h, h', stepI]
        · have h' : (v + 1 - (C : ℤ)) % 5 = 3 := by omega
          simp [wI, h1, h2, h, h', stepI]
        · have h' : (v + 1 - (C : ℤ)) % 5 = 4 := by omega
          simp [wI, h1, h2, h, h', stepI]
        · have h' : (v + 1 - (C : ℤ)) % 5 = 0 := by omega
          simp [wI, h1, h2, h, h', stepI]
  · -- idle positions carry countdown `0`
    intro v hv
    rw [pendI_wI_false_iff] at hv
    unfold cI
    omega
  · -- the countdown counts down inside the region through `0`
    intro v h0 h1
    rw [pendI_wI_true_iff] at h0
    rw [pendI_wI_true_iff] at h1
    unfold cI
    omega
  · -- the countdown is exhausted at a region end
    intro v h0 h1
    rw [pendI_wI_true_iff] at h0
    rw [pendI_wI_false_iff] at h1
    unfold cI
    omega
  · -- every pin hands its region start the countdown `0`, so the pins are compatible outright
    intro s v hs0 _ hv0 _
    rw [pendI_wI_false_iff] at hs0
    rw [pendI_wI_false_iff] at hv0
    unfold cI
    have hs : ((C : ℤ) - (s + 1)).toNat = 0 := by omega
    have hv : ((C : ℤ) - (v + 1)).toNat = 0 := by omega
    rw [hs, hv]
    simp
  · -- the anchor at the origin, with the register constantly `0`
    intro v hv0 _
    rw [pendI_wI_false_iff] at hv0
    unfold cI
    have hv : ((C : ℤ) - (v + 1)).toNat = 0 := by omega
    rw [hv]
    simp

/-! ### The parameter tuple the witness sits at -/

/-- The periodicity fixpoint's own `T_c` for the witness. -/
noncomputable def TcI : ℕ := Tcof stepI pendI labI aI

/-- The periodicity fixpoint's own `T_n` for the witness. -/
noncomputable def TnI : ℕ := Tnof stepI pendI labI aI

/-- The periodicity fixpoint's own `P` for the witness. -/
noncomputable def PI : ℕ := Pof stepI pendI labI aI

/-- The cascade recurrence's own `B` for the witness. -/
noncomputable def BI : ℕ := Bof stepI pendI labI aI

/-- **THE EXCLUSION IS NOT AN ARTEFACT OF THE SHARPENED SCHEMA'S DROPPED PARAMETER
HYPOTHESIS.** The witness object admits `ParamsOk` at the periodicity fixpoint's own outputs,
discharged by the landed `paramsOk_params`, so the refutation below sits at a parameter tuple the
parameter conditions genuinely admit rather than at a vacuous hypothesis. -/
theorem paramsOkI : ParamsOk stepI pendI labI aI TcI TnI PI BI :=
  paramsOk_params stepI pendI labI aI

/-- `(K3)` bounds `T_c` from below by `2 T_short + T_idle + 2`, so the witnessing region's
countdown already exceeds the gap `nxtAt g 0 + 2 ≤ cntAt g 0` demands of it at the register
value `0`. -/
theorem two_le_TcI : 2 ≤ TcI := by
  have h := paramsOkI.2.2.1.2
  omega

/-! ### The parity lemma: on this object every idle run has EVEN length

The whole content of the exclusion, stated once on the object's own step table. An idle run
BEGINS at `idl0`, because `pnd → idl0` is the only admitted pending-to-idle edge; it ALTERNATES,
because neither idle state has a self-loop; and it ENDS at `idl1`, because `idl1 → pnd` is the
only admitted idle-to-pending edge. The position at distance `i` into the run therefore carries
`idl0` for even `i` and `idl1` for odd `i`, and the run's last position carrying `idl1` forces
the length to be even. Every step of the argument reads the table by `decide`. -/

/-- **ON THIS OBJECT EVERY IDLE RUN HAS EVEN LENGTH.** For every ladder path: an idle run of
length `L` beginning at `r` — pending at `r - 1`, idle at `r, …, r + L - 1`, pending again at
`r + L` — has `L` even. -/
theorem idleRun_even {g : ℤ → LadderState QI pendI} (hg : IsLadderPath stepI pendI g)
    (r : ℤ) (L : ℕ)
    (hprev : pendI (objAt g (r - 1)) = true)
    (hidle : ∀ i : ℕ, i < L → pendI (objAt g (r + (i : ℤ))) = false)
    (hnext : pendI (objAt g (r + (L : ℤ))) = true) : L % 2 = 0 := by
  rcases Nat.eq_zero_or_pos L with hL | hL
  · simp [hL]
  have hpat : ∀ i : ℕ, i < L →
      objAt g (r + (i : ℤ)) = (if i % 2 = 0 then QI.idl0 else QI.idl1) := by
    intro i
    induction i with
    | zero =>
        intro _
        have hi0 : pendI (objAt g r) = false := by
          have hz := hidle 0 (by omega); simpa using hz
        have hs := objAt_step g hg (r - 1)
        rw [show r - 1 + 1 = r by ring] at hs
        have hres := stepI_pnd_idle _ _ hprev hi0 hs
        simpa using hres
    | succ j ih =>
        intro hj
        have hij := ih (by omega)
        have hs := objAt_step g hg (r + (j : ℤ))
        rw [hij, show r + (j : ℤ) + 1 = r + ((j + 1 : ℕ) : ℤ) by push_cast; ring] at hs
        have hj1 : pendI (objAt g (r + ((j + 1 : ℕ) : ℤ))) = false := hidle (j + 1) hj
        by_cases hp : j % 2 = 0
        · rw [if_pos hp] at hs
          rw [stepI_idl0_idle _ hj1 hs, if_neg (by omega : ¬ (j + 1) % 2 = 0)]
        · rw [if_neg hp] at hs
          rw [stepI_idl1_idle _ hj1 hs, if_pos (by omega : (j + 1) % 2 = 0)]
  have hlast := hpat (L - 1) (by omega)
  have hs := objAt_step g hg (r + ((L - 1 : ℕ) : ℤ))
  rw [show r + ((L - 1 : ℕ) : ℤ) + 1 = r + (L : ℤ) by
    rw [Nat.cast_sub (by omega), Nat.cast_one]; ring] at hs
  have hpi : pendI (objAt g (r + ((L - 1 : ℕ) : ℤ))) = false := hidle (L - 1) (by omega)
  have he := stepI_idle_pnd _ _ hnext hs hpi
  rw [hlast] at he
  by_cases hp : (L - 1) % 2 = 0
  · rw [if_pos hp] at he
    exact absurd he (by decide)
  · omega

end IdleIncrementWitness

/-! ### The verdict on the freed increment -/

open IdleIncrementWitness in
/-- **THE INCREMENT IS NOT FREE, EVEN UNDER THE PREMISE.** On the three-state object whose idle
states carry a `2`-cycle and no self-loop, every idle run has EVEN length (`idleRun_even`), so
the run of length `4` the witnessing path carries above its region through `0` — which MEETS the
run-repeat premise at `k = 2`, with both ends of the block at `idl0` and with the same realized
type there — admits no lengthening to `5`.

The refutation therefore does not turn on the premise being unmet: it is met. What fails is the
freed increment, exactly as `IdleGapLengtheningOfIdleRunRepeat`'s restriction to the multiples of
`k` anticipates. The parameters are the periodicity fixpoint's own outputs for a stab-free atomic
closure (`paramsOkI`, `two_le_TcI`), so the exclusion is not an artefact of the sharpened
schema's dropped parameter hypothesis either. -/
theorem idleGapLengtheningAllIncrements_refuted :
    ¬ ∀ (Q : Type) [Fintype Q] [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool)
        (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
        (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
        (lab : Q → Atom → Bool) (φ : PlusFormula),
        IdleGapLengtheningAllIncrements step pend fwd bwd lab φ := by
  intro h
  obtain ⟨g, hg, hobj, hcnt, hnxt⟩ := exists_gI TcI
  obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath fwdI bwdI g hg
  have h2 := two_le_TcI
  have hC : cntAt g 0 = TcI := by rw [hcnt]; unfold cI; omega
  -- the hypotheses, at `z = 0`, `I = 4`, `k = 2`, `l = 1`, and the block at the run's first
  -- position
  have hpast : ∀ p : ℤ, p ≤ 0 → pendI (objAt g p) = true := by
    intro p hp
    rw [hobj, pendI_wI_true_iff]
    exact Or.inl (by omega)
  have hgap : nxtAt g 0 + 2 ≤ cntAt g 0 := by rw [hnxt, hC]; omega
  have hrun : ∀ i : ℕ, i < 4 →
      pendI (objAt g (0 + (cntAt g 0 : ℤ) + 1 + (i : ℤ))) = false := by
    intro i hi
    rw [hobj, pendI_wI_false_iff, hC]
    exact ⟨by omega, by omega⟩
  have hstart : pendI (objAt g (0 + (cntAt g 0 : ℤ) + 1 + ((4 : ℕ) : ℤ))) = true := by
    rw [hobj, pendI_wI_true_iff, hC]
    exact Or.inr (by omega)
  have hRa : (0 : ℤ) + (cntAt g 0 : ℤ) + 1 ≤ (TcI : ℤ) + 1 := by rw [hC]; omega
  have hak : (TcI : ℤ) + 1 + ((2 : ℕ) : ℤ)
      ≤ 0 + (cntAt g 0 : ℤ) + 1 + ((4 : ℕ) : ℤ) := by rw [hC]; omega
  have hrep : objAt g ((TcI : ℤ) + 1) = objAt g ((TcI : ℤ) + 1 + ((2 : ℕ) : ℤ)) := by
    rw [hobj, hobj, show (TcI : ℤ) + 1 + ((2 : ℕ) : ℤ) = (TcI : ℤ) + 3 by push_cast; ring,
      wI_eq_idl0_of_mod_one TcI ((TcI : ℤ) + 1) (by omega) (by omega),
      wI_eq_idl0_of_mod_three TcI ((TcI : ℤ) + 3) (by omega) (by omega)]
  have hty := tpOf_aI_eq_of_objAt_eq σ hσ ((TcI : ℤ) + 1) ((TcI : ℤ) + 1 + ((2 : ℕ) : ℤ)) hrep
  obtain ⟨g', hg', hoz, hcz, -, hrun', hstart', -, -⟩ :=
    h QI stepI pendI fwdI bwdI labI aI no_stab_in_closure_aI g hg σ hσ 0 4 2 1
      ((TcI : ℤ) + 1) hpast hgap (by omega) (by omega) (by omega) hrun hstart hRa hak hrep hty
  -- the lengthened path carries an idle run of length five, which the parity lemma forbids
  have hcz' : cntAt g' 0 = TcI := by rw [hcz, hC]
  have hz0 : pendI (objAt g' 0) = true := by
    rw [hoz, hobj, pendI_wI_true_iff]
    exact Or.inl (by omega)
  have hprev : pendI (objAt g' ((TcI : ℤ) + 1 - 1)) = true := by
    have he : (0 : ℤ) + (cntAt g' 0 : ℤ) = (TcI : ℤ) + 1 - 1 := by rw [hcz']; ring
    rw [← he]
    exact (cntAt_sub_of_pend g' hg' 0 hz0 (cntAt g' 0) le_rfl).1
  have hidle5 : ∀ i : ℕ, i < 5 → pendI (objAt g' ((TcI : ℤ) + 1 + (i : ℤ))) = false := by
    intro i hi
    have he : (0 : ℤ) + (cntAt g' 0 : ℤ) + 1 + (i : ℤ) = (TcI : ℤ) + 1 + (i : ℤ) := by
      rw [hcz']; ring
    rw [← he]
    exact hrun' i (by omega)
  have hnext5 : pendI (objAt g' ((TcI : ℤ) + 1 + ((5 : ℕ) : ℤ))) = true := by
    have he : (0 : ℤ) + (cntAt g' 0 : ℤ) + 1 + (((4 + 1 : ℕ)) : ℤ)
        = (TcI : ℤ) + 1 + ((5 : ℕ) : ℤ) := by rw [hcz']; push_cast; ring
    rw [← he]
    exact hstart'
  have hpar := idleRun_even hg' ((TcI : ℤ) + 1) 5 hprev hidle5 hnext5
  omega

end Freed

/-! ## The run-local discharge route: `ForwardSlackWitnessed` at EVERY amount

The three declarations below are a cascade-free, deletion-free discharge route for
`ForwardSlackWitnessed`, assembled entirely from landed machinery. The route passes through no
block deletion inside the first region above `z`'s region — the route
`exists_deleted_ladderPath_of_next_region_nxt` (`LadderChain.lean`) refutes — and spends none of
`(K2)`'s `cascadeBound`: the only surgery is the duplication of an idle block inside the idle run
SEPARATING `z`'s region from the next one, whose pin clause `idleSplice_pins` (`LadderPump.lean`)
discharges unconditionally.

Why no pin obligation survives. The regime asks `K ≤ n + cntAt g z + I - l`, where `K` is the
next region's countdown and `I` the length of the intervening idle run. The free Lipschitz bound
every ladder path already carries is `K ≤ n + cntAt g z + I` (`nxtAt_lipschitz_two_sided`
composed with `cntAt_eq_nxtAt_of_idle_pend`). The idle pump leaves `K` UNTOUCHED —
`idleGapLengtheningOfIdleRunRepeat_holds`'s displaced-region-start clause — and raises `I` by
`d · k`, so the deficit is paid out of the pumped run and the original bound is reused verbatim.
Pin compatibility never enters: the duplicated idle block contributes no pin of its own, and the
pins above it move FARTHER from those below while their values stay put.

What remains open is the complementary side, where the intervening idle run has length `1`. -/

section Pumpable

-- `linter.unusedFintypeInType`, scoped to this declaration, on the precedent of
-- `exists_iterIdleSpliced_ladderPath` above: the signature is pinned by the plan's Lean
-- Challenge Statements block, `[Fintype Q]` is read inside the proof and not by the statement,
-- and it is the instance shape every declaration of the idle layer carries.
set_option linter.unusedFintypeInType false in
/-- **THE PATH LEVEL.** The pumped path sits at the same ladder state at `z`, realizes the same
stab-free type there, and carries the forward-slack regime at amount `l`.

Scope, in three clauses.

**(i) The premise is an object/run datum and is NOT `ParamsOk`-derivable.**
`idle_run_lt_tIdle_of_no_idleCycle` (`LadderPump.lean`) is the bound in the other direction:
absent an idle cycle, every idle run is SHORTER than `tIdle pend`. No parameter condition
supplies one — `(K1)` quantifies `prodCycleLens`, `objCycleLens` and `satPeriod`, and never
`idleCycleLens`. Assuming the premise is therefore a RESTRICTION of an obligation, not a proof
of one.

**(ii) `ForwardSlackWitnessed` is NOT removed from the five depth-`0` cell-equality schemas of
`LadderCell.lean`.** It stays a carried hypothesis there and every consumer must still supply it.

**(iii) Nothing else moves.** The reserved name `cellLE_zero_const_of_kappa_eq` stays claimed by
nothing, the ordinary window regime `c ≤ n + 1` stays uncovered, and the room bounds remain. -/
theorem hasForwardSlack_of_idleRunRepeat {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (z : ℤ) (I k d l : ℕ) (a : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hgap : nxtAt g z + 2 ≤ cntAt g z)
    (hI : 0 < I) (hk : 0 < k) (hd : 0 < d)
    (hrun : ∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false)
    (hstart : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true)
    (hRa : z + (cntAt g z : ℤ) + 1 ≤ a)
    (hak : a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ))
    (hrep : objAt g a = objAt g (a + (k : ℤ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ a
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)))
    (hpay : l ≤ d * k) :
    ∃ (g' : ℤ → LadderState Q pend)
      (σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      IsLadderPath step pend g' ∧ (∀ t : ℤ, σ'.state t = (t, g' t)) ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z l (nxtAt g z) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ' z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  obtain ⟨g', hg', hoz, hcz, hnz, hrun', hstart', hcnt', htyc⟩ :=
    idleGapLengtheningOfIdleRunRepeat_holds step pend fwd bwd lab φ hno g hg σ hσ
      z I k d a hpast hgap hI hk hd hrun hstart hRa hak hrep hty
  obtain ⟨σ', hσ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine ⟨g', σ', hg', hσ', hoz, hcz, hnz, ?_, htyc σ' hσ'⟩
  refine hasForwardSlack_of_next_region_cnt_le g' hg' z l (nxtAt g z) ?_
  intro J hJ hidleJ hpendJ
  -- the pumped idle run has length EXACTLY `I + d * k`, so the regime's `∀ I` is one instance
  have hJeq : J = I + d * k := by
    by_contra hne
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact Bool.false_ne_true ((hrun' J hlt).symm.trans hpendJ)
    · exact Bool.false_ne_true ((hidleJ (I + d * k) (by omega)).symm.trans hstart')
  subst hJeq
  have hidleu : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ))) = false := by
    have h := hrun (I - 1) (by omega)
    rwa [show z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ)
        = z + (cntAt g z : ℤ) + (I : ℤ) by
      push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring] at h
  have hpendu : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rwa [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
  have hK := cntAt_eq_nxtAt_of_idle_pend g hg _ hidleu hpendu
  have hlip := nxtAt_lipschitz_two_sided g hg (z + (cntAt g z : ℤ) + (I : ℤ)) z
  rw [hcnt', hcz]
  rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ)
    by ring] at hK
  rw [hK]
  have hc0 : (0 : ℤ) ≤ (cntAt g z : ℤ) := Int.natCast_nonneg _
  have hI0 : (0 : ℤ) ≤ (I : ℤ) := Int.natCast_nonneg _
  push_cast at hlip ⊢
  omega

-- `linter.unusedFintypeInType`, scoped to this declaration, on the same precedent as
-- `exists_iterIdleSpliced_ladderPath`: the signature is pinned by the plan's Lean Challenge
-- Statements block, and `[Fintype Q]` is the instance shape the whole idle layer carries.
set_option linter.unusedFintypeInType false in
/-- **THE RUN-LOCAL PREMISE.** The path is pending forever into the past at `z`, sits in the
pending-forever gap, and its intervening idle run carries an `(objAt, tpOf)`-repeat block. The
third conjunct is what `exists_idleTypeBlock_of_budget_le_run` produces from a run of length at
least `idleBudget pend φ`.

Scope, in three clauses.

**(i) This predicate is an object/run datum and is NOT `ParamsOk`-derivable.**
`idle_run_lt_tIdle_of_no_idleCycle` (`LadderPump.lean`) bounds every idle run BELOW `tIdle pend`
when the object has no idle cycle, and no parameter condition supplies one — `(K1)` quantifies
`prodCycleLens`, `objCycleLens` and `satPeriod`, and never `idleCycleLens`. So this is a
hypothesis a path may or may not meet, not a consequence of the parameter regime.

**(ii) `ForwardSlackWitnessed` is NOT removed from the five depth-`0` cell-equality schemas of
`LadderCell.lean`.** This predicate relocates that obligation onto a checkable, amount-free
run-local condition; it does not discharge it.

**(iii) Nothing else moves.** The reserved name `cellLE_zero_const_of_kappa_eq` stays claimed by
nothing, the ordinary window regime `c ≤ n + 1` stays uncovered, and the room bounds remain. -/
def IdleRunPumpable {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (g : ℤ → LadderState Q pend)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) : Prop :=
  (∀ p : ℤ, p ≤ z → pend (objAt g p) = true) ∧
  nxtAt g z + 2 ≤ cntAt g z ∧
  ∃ (I k : ℕ) (a : ℤ), 0 < I ∧ 0 < k ∧
    (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) ∧
    pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true ∧
    z + (cntAt g z : ℤ) + 1 ≤ a ∧ a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ) ∧
    objAt g a = objAt g (a + (k : ℤ)) ∧
    tpOf (ladderModel step pend fwd bwd lab) φ σ a
      = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ))

-- `linter.unusedFintypeInType`, scoped to this declaration, on the same precedent as
-- `exists_iterIdleSpliced_ladderPath`: the signature is pinned by the plan's Lean Challenge
-- Statements block, and `[Fintype Q]` is the instance shape the whole idle layer carries.
set_option linter.unusedFintypeInType false in
/-- **THE CELL LEVEL: `ForwardSlackWitnessed` AT EVERY AMOUNT.** The amount `l` is universally
quantified in the conclusion and appears NOWHERE in the premise — `d := l + 1` pumps as much idle
run as the amount demands. That asymmetry is what makes this route work where the deletion route
could not: the deletion had to buy `l` units of a quantity the saturated register had already
spent, whereas the pump MANUFACTURES `d · k` units of idle run at a cost of nothing.

Scope, in three clauses. **This is a CONDITIONAL discharge and must not be read as an
unconditional one.**

**(i) `IdleRunPumpable` is an object/run datum and is NOT `ParamsOk`-derivable.**
`idle_run_lt_tIdle_of_no_idleCycle` (`LadderPump.lean`) is the bound the other way — absent an
idle cycle every idle run is shorter than `tIdle pend` — and `(K1)` quantifies `prodCycleLens`,
`objCycleLens` and `satPeriod`, and never `idleCycleLens`. No parameter condition supplies the
premise, so this theorem restricts the obligation rather than proving it.

**(ii) `ForwardSlackWitnessed` is NOT removed from the five depth-`0` cell-equality schemas of
`LadderCell.lean`.** It remains a carried hypothesis on every one of them, every consumer must
still supply it, and `LadderCell.lean` is not edited. What is open after this theorem is exactly
the complementary side: the paths whose intervening idle run has length `1`.

**(iii) Nothing else moves.** The reserved name `cellLE_zero_const_of_kappa_eq` stays claimed by
nothing, the ordinary window regime `c ≤ n + 1` stays uncovered, and the room bounds remain. -/
theorem forwardSlackWitnessed_of_cell_idleRunPumpable {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (x : LadderState Q pend) (z : ℤ) (l : ℕ)
    (hprem : ∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z,
      ∃ (g : ℤ → LadderState Q pend)
        (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        IsLadderPath step pend g ∧ g z = x ∧ (∀ t : ℤ, σ.state t = (t, g t)) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ z = T ∧
        IdleRunPumpable step pend fwd bwd lab φ g σ z) :
    ForwardSlackWitnessed step pend fwd bwd lab φ x z l x.1.2.2 := by
  intro T hT
  obtain ⟨g, σ, hg, hgz, hσ, htp, hpast, hgap, I, k, a, hI, hk, hrun, hstart, hRa, hak,
    hrep, hty⟩ := hprem T hT
  have hpay : l ≤ (l + 1) * k := by
    calc l ≤ (l + 1) * 1 := by omega
    _ ≤ (l + 1) * k := Nat.mul_le_mul_left _ hk
  obtain ⟨g', σ', hg', hσ', hoz, hcz, hnz, hslack, htyeq⟩ :=
    hasForwardSlack_of_idleRunRepeat step pend fwd bwd lab φ hno hg σ hσ z I k (l + 1) l a
      hpast hgap hI hk (by omega) hrun hstart hRa hak hrep hty hpay
  have hnxtx : nxtAt g z = x.1.2.2 := by rw [← hgz]; rfl
  have hg'z : g' z = x := by
    refine Subtype.ext (Prod.ext ?_ (Prod.ext ?_ ?_))
    · rw [← hgz]; exact hoz
    · rw [← hgz]; exact hcz
    · rw [← hgz]; exact hnz
  exact ⟨g', σ', hg', hg'z, hσ', hnxtx ▸ hslack, htyeq.trans htp⟩

end Pumpable

section IOne

/-!
## `I = 1`: the idle-run complement is REFUTED at the every-amount shape

The section above discharges `ForwardSlackWitnessed` at every amount from `IdleRunPumpable`,
and names its complement — the paths whose intervening idle run has length exactly `1`, where
no repeat block exists to pump — as the remaining frontier. That complement was recorded as
"dischargeable on the pumpable side rather than refuted outright". **This section compiles the
counterexample that falsifies that reading for the every-amount shape.**

**The object.** `stepOr x y = x || y` on `Q := Bool`, serial in both directions (`fwdOr`,
`bwdOr`), with NO idle self-loop: `stepOr false false = false` is impossible, so every idle run
on every ladder path has length exactly `1`. On it, `forwardSlackWitnessed_refuted_I_one` shows
`ForwardSlackWitnessed` is FALSE at amount `4` at the state `xState = (true, 2, 0)`. That state
sits in the pending-forever gap `n + 2 ≤ c` and is realized by the plateau path, so the
refutation is not vacuous: `xState_regime` compiles the regime membership with a concrete
witness.

**Why the existential-over-paths escape closes here.** This is the first CELL-level refutation
of `ForwardSlackWitnessed` in this development. The mechanism is the amount ceiling
`hasForwardSlack_amount_le` (`LadderChain.lean`), which forces `(l : ℤ) ≤ n + cntAt g z + I`
whenever a genuine next region exists. The ceiling is forced by the OBJECT — no idle self-loop,
hence `I = 1` on every path — rather than by a choice of path, so it binds uniformly over every
path through the state. That is exactly the escape route which stops the pin-cascade refutation
at the path level, and it is unavailable here.
`forwardSlackWitnessed_holds_below_ceiling` compiles the sharp boundary: the SAME state carries
`ForwardSlackWitnessed` at every amount `l ≤ 3 = n + c + 1`. So the ceiling, and not some
further obstruction, is precisely what the `I = 1` regime refuses.

**Consistency with the conditional discharge is compiled, not argued.** `not_idleRunPumpable`
shows `IdleRunPumpable` is unsatisfiable for every path, history and anchor on this object, so
`forwardSlackWitnessed_of_cell_idleRunPumpable`'s premise is simply false here and the two
results cannot collide.

**What this section does NOT establish.** It does NOT reach the five depth-`0` cell-equality
schemas of `LadderCell.lean` (`cellLE_zero_const_of_kappa_eq_of_forwardSlack` and its
`_commonShift_`, `_monotone_`, `_antitone_`, `_antitone_bounded_` siblings). Those schemas ask
for `ForwardSlackWitnessed` at amount `m * (P + 1)` at the HIGHER state, whose countdown is
`c + m * (P + 1)`; `ceiling_slack_at_consumer_amount` compiles that the ceiling
`l ≤ n + cntAt + I` is then satisfied for free whenever `0 < I`. All five schemas therefore KEEP
`ForwardSlackWitnessed` as a carried hypothesis, no schema signature is touched, and
`LadderCell.lean` is not edited by this section. For the same reason `certStabK`'s restatement
obligation stays PROVISIONAL, not permanent.

The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by NOTHING here, and this section
bears on its truth value in neither direction. The surviving frontier is route 4 at the cell
level — simultaneous multi-region shortening — which this section records but does not attempt.

**No `docs/theorem-index.md` row and no `Paper:` line** is added for any declaration below.
That is a deliberate choice, not an omission: the index row is what incurs the `Paper:` line
obligation, so adding no row incurs none. These are negative results about an internal
obstruction, not results the manual states.
-/

namespace IdleRunOne

open ClimbWitness (pendT plateau plateauRaw)

/-- Two-state object with NO idle self-loop: `step x y = x || y`. -/
def stepOr : Bool → Bool → Bool := fun x y => x || y

/-- The defining negative fact: two consecutive idle positions are impossible. -/
theorem stepOr_idle_idle : stepOr false false = false := rfl

/-- `stepOr` is forward serial: every admissible ladder state has an admissible successor. -/
theorem fwdOr : ∀ (t : ℤ) (x : LadderState Bool pendT), ∃ y, RladAdm stepOr pendT t x y := by
  rintro t ⟨⟨q, c, n⟩, hadm⟩
  cases q with
  | false =>
      have hc : c = 0 := hadm rfl
      subst hc
      refine ⟨⟨(true, n, n), by intro h; simp [pendT] at h⟩, ?_⟩
      refine ⟨rfl, by intro _; rfl, Or.inl rfl, ?_⟩
      simp [Count, pendT]
  | true =>
      cases c with
      | zero =>
          refine ⟨⟨(false, 0, n), by intro _; rfl⟩, ?_⟩
          refine ⟨rfl, by intro h; simp [pendT] at h, Or.inl rfl, ?_⟩
          simp [Count, pendT]
      | succ k =>
          refine ⟨⟨(true, k, n), by intro h; simp [pendT] at h⟩, ?_⟩
          refine ⟨rfl, by intro h; simp [pendT] at h, Or.inl rfl, ?_⟩
          simp [Count, pendT]

/-- `stepOr` is backward serial: every admissible ladder state has an admissible predecessor. -/
theorem bwdOr : ∀ (t : ℤ) (x : LadderState Bool pendT), ∃ y, RladAdm stepOr pendT (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hadm⟩
  cases q with
  | false =>
      have hc : c = 0 := hadm rfl
      subst hc
      refine ⟨⟨(true, 0, n), by intro h; simp [pendT] at h⟩, ?_⟩
      refine ⟨rfl, by intro h; simp [pendT] at h, Or.inl rfl, ?_⟩
      simp [Count, pendT]
  | true =>
      refine ⟨⟨(true, c + 1, n), by intro h; simp [pendT] at h⟩, ?_⟩
      refine ⟨rfl, by intro h; simp [pendT] at h, Or.inl rfl, ?_⟩
      simp [Count, pendT]

/-- The plateau path is a ladder path for `stepOr` too. -/
theorem plateau_isLadderPath_stepOr (C : ℕ) : IsLadderPath stepOr pendT (plateau C) := by
  intro u
  change Rlad stepOr pendT u (plateauRaw C u) (plateauRaw C (u + 1))
  unfold Rlad Drift Count plateauRaw stepOr pendT
  split_ifs <;> simp_all <;> omega

/-- The constant-`false` labelling: no atom is ever true, so `⊥` is the only formula in play. -/
def labB : Bool → Atom → Bool := fun _ _ => false

/-- The state `(true, 2, 0)`: pending, countdown `2`, register `0` — in the pending-forever
gap `n + 2 ≤ c`. -/
def xState : LadderState Bool pendT := ⟨(true, 2, 0), by intro h; simp [pendT] at h⟩

/-- The plateau path at `C = 2` passes through `xState` at time `0`. -/
theorem plateau_two_at_zero : plateau 2 0 = xState := by
  apply Subtype.ext
  change plateauRaw 2 0 = ((true, 2, 0) : Bool × ℕ × ℕ)
  unfold plateauRaw
  decide

/-- Every ladder path on `stepOr` whose idle run above `z`'s region starts at `z + c + 1`
has that run of length EXACTLY `1`: `stepOr false false = false`, so no two consecutive
idle positions exist. -/
theorem next_pend_of_idle (g : ℤ → LadderState Bool pendT) (hg : IsLadderPath stepOr pendT g)
    (u : ℤ) (hu : pendT (objAt g u) = false) : pendT (objAt g (u + 1)) = true := by
  have hs := objAt_step g hg u
  have : objAt g u = false := hu
  rw [this] at hs
  change objAt g (u + 1) = true
  simpa [stepOr] using hs

/-- **THE `I = 1` AMOUNT CEILING, ON EVERY PATH THROUGH THE STATE.** Amount `4` exceeds
`n + cntAt g 0 + I = 0 + 2 + 1`, so `hasForwardSlack_amount_le` refuses it on every ladder path
through `xState`, with no choice of path left to make. -/
theorem not_hasForwardSlack_of_four
    (g : ℤ → LadderState Bool pendT) (hg : IsLadderPath stepOr pendT g)
    (hgz : g 0 = xState) : ¬ HasForwardSlack g 0 4 0 := by
  intro hs
  have hc : cntAt g 0 = 2 := by rw [show cntAt g 0 = (g 0).1.2.1 from rfl, hgz]; rfl
  have hp0 : pendT (objAt g 0) = true := by
    rw [show objAt g 0 = (g 0).1.1 from rfl, hgz]; rfl
  have h3 : pendT (objAt g (0 + (cntAt g 0 : ℤ) + 1)) = false := not_pend_of_count g hg 0 hp0
  rw [hc] at h3
  have h4 : pendT (objAt g (0 + ((2 : ℕ) : ℤ) + 1 + ((1 : ℕ) : ℤ))) = true := by
    have := next_pend_of_idle g hg _ h3
    simpa using this
  have hidle : ∀ i : ℕ, i < 1 →
      pendT (objAt g (0 + (cntAt g 0 : ℤ) + 1 + (i : ℤ))) = false := by
    intro i hi
    have : i = 0 := by omega
    subst this
    rw [hc]; simpa using h3
  have hnx : pendT (objAt g (0 + (cntAt g 0 : ℤ) + 1 + ((1 : ℕ) : ℤ))) = true := by
    rw [hc]; exact h4
  have hb := hasForwardSlack_amount_le g hg 0 4 0 1 (by omega) hidle hnx hs
  rw [hc] at hb
  norm_num at hb

/-- **THE CELL-LEVEL REFUTATION.** `ForwardSlackWitnessed` is FALSE at amount `4` at the state
`(true, 2, 0)`, which sits in the pending-forever gap `n + 2 ≤ c` and is realized by a ladder
path pending forever into the past. No `I = 1` discharge can conclude `ForwardSlackWitnessed`
at every amount. -/
theorem forwardSlackWitnessed_refuted_I_one :
    ¬ ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB PlusFormula.bot xState 0 4 0 := by
  intro hw
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdOr bwdOr (plateau 2)
    (plateau_isLadderPath_stepOr 2)
  have hT : tpOf (ladderModel stepOr pendT fwdOr bwdOr labB) PlusFormula.bot τ 0
      ∈ cellAt (ladderModel stepOr pendT fwdOr bwdOr labB) PlusFormula.bot
        ((0, xState) : (ladderFrameAdm stepOr pendT fwdOr bwdOr).WorldState) 0 :=
    (mem_cellAt_ladder_iff fwdOr bwdOr labB PlusFormula.bot xState 0 _).mpr
      ⟨plateau 2, τ, plateau_isLadderPath_stepOr 2, plateau_two_at_zero, hτ, rfl⟩
  obtain ⟨g, σ, hg, hgz, hσ, hslack, -⟩ := hw _ hT
  exact not_hasForwardSlack_of_four g hg hgz hslack

/-- The refuted state IS in the pending-forever regime, witnessed by a concrete path. -/
theorem xState_regime :
    IsLadderPath stepOr pendT (plateau 2) ∧ plateau 2 0 = xState ∧
      (∀ p : ℤ, p ≤ 0 → pendT (objAt (plateau 2) p) = true) ∧
      nxtAt (plateau 2) 0 + 2 ≤ cntAt (plateau 2) 0 :=
  ⟨plateau_isLadderPath_stepOr 2, plateau_two_at_zero, ClimbWitness.plateau_pend_past 2,
    by rw [ClimbWitness.plateau_nxt, ClimbWitness.plateau_cnt_zero]⟩

/-- **THE CONDITIONAL DISCHARGE'S PREMISE IS UNSATISFIABLE ON THIS OBJECT.** `IdleRunPumpable`
fails for EVERY path, history and anchor on `stepOr`: an object with no idle self-loop has
every idle run of length `1`, and a length-`1` run admits no `(objAt, tpOf)`-repeat block. This
is the `I = 1` frontier exhibited as a whole object rather than as one path, and it is why this
section and `forwardSlackWitnessed_of_cell_idleRunPumpable` cannot collide. -/
theorem not_idleRunPumpable (φ : PlusFormula) (g : ℤ → LadderState Bool pendT)
    (hg : IsLadderPath stepOr pendT g)
    (σ : WorldHistory (ladderFrameAdm stepOr pendT fwdOr bwdOr).toTaskFrame) (z : ℤ) :
    ¬ IdleRunPumpable stepOr pendT fwdOr bwdOr labB φ g σ z := by
  rintro ⟨-, -, I, k, a, hI, hk, hrun, hstart, hRa, hak, hrep, -⟩
  -- no two consecutive idle positions, so the run has length exactly `1`
  have hI1 : I = 1 := by
    by_contra hne
    have h0 := hrun 0 (by omega)
    have h1 := hrun 1 (by omega)
    have hx := next_pend_of_idle g hg _ (by simpa using h0)
    simp only [Nat.cast_one] at h1
    exact Bool.false_ne_true (h1.symm.trans hx)
  subst hI1
  have hk1 : k = 1 := by omega
  have ha : a = z + (cntAt g z : ℤ) + 1 := by omega
  subst hk1
  subst ha
  have hidle : pendT (objAt g (z + (cntAt g z : ℤ) + 1)) = false := by
    have := hrun 0 (by omega); simpa using this
  have hpend : pendT (objAt g (z + (cntAt g z : ℤ) + 1 + ((1 : ℕ) : ℤ))) = true := by
    simpa using hstart
  rw [hrep] at hidle
  simp only [Nat.cast_one] at hidle hpend
  exact Bool.false_ne_true (hidle.symm.trans hpend)

/-- **THE CEILING NEVER BITES AT THE CONSUMER'S INSTANTIATION.** The five depth-`0` schemas ask
for `ForwardSlackWitnessed` at amount `m · (P + 1)` at the HIGHER state, whose countdown is
`c + m · (P + 1)`; the amount ceiling `l ≤ n + cntAt + I` is then satisfied for free. So the
refutation above does NOT reach the consumer-relevant instantiation, and all five schemas keep
`ForwardSlackWitnessed` as a carried hypothesis. -/
theorem ceiling_slack_at_consumer_amount (n c m P I : ℕ) (hI : 0 < I) :
    ((m * (P + 1) : ℕ) : ℤ) ≤ (n : ℤ) + ((c + m * (P + 1) : ℕ) : ℤ) + (I : ℤ) := by
  push_cast
  omega

/-- At `φ = ⊥` every closure type is empty, so the cell at `xState` is the singleton `{∅}`. -/
theorem tpOf_bot_eq_empty
    (σ : WorldHistory (ladderFrameAdm stepOr pendT fwdOr bwdOr).toTaskFrame) (z : ℤ) :
    tpOf (ladderModel stepOr pendT fwdOr bwdOr labB) PlusFormula.bot σ z = ∅ := by
  classical
  ext ψ
  rw [mem_tpOf_iff]
  constructor
  · rintro ⟨hm, ht⟩
    have : ψ = PlusFormula.bot := by
      revert hm
      unfold plusSubformulaClosure PlusFormula.subformulas
      simp
    subst this
    exact absurd ht (by simp [PlusTruthAt])
  · intro h; exact absurd h (Finset.notMem_empty ψ)

/-- **THE BOUNDARY IS SHARP AT `φ = ⊥`.** The same state carries `ForwardSlackWitnessed` at
every amount `l ≤ 3 = n + c + 1`, and fails at `4`. So the ceiling, not some further
obstruction, is exactly what the `I = 1` regime refuses. -/
theorem forwardSlackWitnessed_holds_below_ceiling (l : ℕ) (hl : l ≤ 3) :
    ForwardSlackWitnessed stepOr pendT fwdOr bwdOr labB PlusFormula.bot xState 0 l 0 := by
  intro T hT
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdOr bwdOr (plateau 2)
    (plateau_isLadderPath_stepOr 2)
  have hTe : T = ∅ := by
    obtain ⟨σ, -, hty⟩ := hT
    rw [← hty, tpOf_bot_eq_empty]
  refine ⟨plateau 2, τ, plateau_isLadderPath_stepOr 2, plateau_two_at_zero, hτ, ?_, ?_⟩
  · exact ClimbWitness.hasForwardSlack_plateau 2 l (by omega)
  · rw [hTe, tpOf_bot_eq_empty]

end IdleRunOne

end IOne

end FormalSystem.Metalogic.Decidability.RaySummary

#print axioms FormalSystem.Metalogic.Decidability.RaySummary.idleGapLengtheningOfIdleRunRepeat_holds
#print axioms FormalSystem.Metalogic.Decidability.RaySummary.idleGapLengtheningAllIncrements_refuted
-- The three names of the run-local discharge route. Their fully qualified forms exceed the
-- 100-character line limit, so the namespace is opened for this block rather than repeated.
section
open FormalSystem.Metalogic.Decidability.RaySummary
#print axioms hasForwardSlack_of_idleRunRepeat
#print axioms IdleRunPumpable
#print axioms forwardSlackWitnessed_of_cell_idleRunPumpable
end
