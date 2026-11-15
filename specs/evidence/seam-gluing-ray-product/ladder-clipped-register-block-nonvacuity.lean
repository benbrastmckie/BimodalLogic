/-
NO REGISTER CONJUNCT SURVIVES AT THE PUMP'S OWN POSITION PAIRS: the clipped-register block
selection is VACUOUS, and the gap-shaped conjunct is REFUTED on the same fixture.

Two decisions are held in place here, both on one compiled fixture, the ramp.

**(1) The block-selection condition on a clipped register is refuted as non-vacuous.** The
condition restricts the pump's block selection to blocks across which the original's register is
clipped-constant, on top of `exists_typeBlock_of_spacing`. Such blocks do NOT exist at spacing
`P + 1` inside the room the invariant has, for every ladder path in scope.

* `clipped_seam_necessary` — the exact register condition a block must satisfy for ANY ladder
  path to carry the original's clipped register at copies `0` and `1`: the block's last and first
  registers may not sit two apart below the threshold. Generic in the object and the path, which
  is why the refutation covers the whole family of such conditions and not one formulation.
* `no_clipped_block_on_ramp` — a finite object (`Fin 4`: a pending 3-cycle and an idle sink) and
  a ladder path, pending forever into the past, countdown `C` at `0`, register `0` at `0`, on
  which NO block `[u, u + l)` of the region `[0, C]` with a repeated object state admits a ladder
  path carrying the clipped register at copies `0` and `1` — at every `Tn` with `C ≤ Tn + 1`,
  every block length, hence every spacing and every `P`. No type hypothesis is used, so the
  statement covers every type-respecting block a fortiori.
* `paramsOk_Tc_le_Tn_succ` — `(K3)` puts `Tc ≤ Tn + 1`, so `C := Tc` is in the theorem's scope:
  the room the depth-stratified invariant guarantees is entirely below the register threshold.
* `clipped_pigeonhole_room_exceeds_Tc` — the naive repair (add the clipped register as a third
  pigeonhole coordinate) needs room `b · (Tn + 1) · (P + 1)`, which `ParamsOk` itself puts
  strictly above `Tc`. So no `ParamsOk`-compatible re-basing repairs the condition.
* `fwd4`, `bwd4`, `no_clipped_block_at_params` — the fixture is in the pump's scope: the admissible
  ladder relation is serial both ways on it (so `ladderFrameAdm step4 pend4 fwd4 bwd4` exists), and
  the refutation holds at the parameters `paramsOk_params` itself discharges.
* `exists_clipped_block_on_plateau_shape` — the condition is INHABITED (a constant register
  satisfies the seam condition at every block), so it is not contradictory; it is not universal.

**(2) The gap-shaped register conjunct is refuted on the ramp.** `stab_gapR_iff`
(`LadderCell.lean`) measures a `⊡` bit at a PENDING ladder state as a threshold on the signed gap
`n − c`, and `stab_gapR_eq_of_gap_eq` consumes equality of that gap. The producer-side question is
whether a ladder path can carry the original's gap at copies `0` and `1` of a block while pending
there, which is the shape the iterated splice's position pairs have.

* `gap_conjunct_refuted_on_ramp` — on the ramp at EVERY height `C`, for every block
  `[u, u + l)` of the region `[0, C]` with `2 ≤ l`, NO ladder path is pending at copies `0` and
  `1` and carries the ramp's signed gap there. The ramp's gap is `2 v − C`, rising by two per
  position, and `iterSpliced_gap_interior_forces_block_gap_le` forbids any rise across the block.
  No object-repeat hypothesis, no type hypothesis, no threshold and no parameter is used.
* `gap_conjunct_refuted_at_params` — the same at the discharged parameters, at spacing
  `Pof + 1`, in the shape of `no_clipped_block_at_params`.

**What this probe does NOT establish.** It refutes two universal claims on one fixture and proves
no agreement of any `⊡` bit or cell. It does not say cell agreement fails at the fixture's states,
only that no path-level correspondence carrying a clipped-register conjunct, or an exact-gap
conjunct, through pump copies exists there. Sufficiency of the seam condition is not compiled
here. The gap conjunct refuted is the EXACT signed gap; a gap clipped to a window is a strictly
weaker conjunct and is neither landed nor refuted here.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/ladder-clipped-register-block-nonvacuity.lean
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace ProbeB1

/-! ## The seam condition, generic -/

section Seam

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE SEAM CONDITION IS NECESSARY.** If any ladder path `g'` carries the original's clipped
register at position `j` of copies `0` and `1` of the block `[u, u + l)`, then the original's
register does NOT climb by two or more from the block's first position to its last while the
first sits two below the threshold. -/
theorem clipped_seam_necessary
    (g : ℤ → LadderState Q pend) {g' : ℤ → LadderState Q pend}
    (hg' : IsLadderPath step pend g') (u : ℤ) (l Tn : ℕ) (hl : 0 < l)
    (hreg : ∀ i j : ℕ, i ≤ 1 → j < l →
      min (nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))) Tn
        = min (nxtAt g (u + (j : ℤ))) Tn) :
    ¬ (nxtAt g u + 2 ≤ nxtAt g (u + ((l - 1 : ℕ) : ℤ)) ∧ nxtAt g u + 2 ≤ Tn) := by
  rintro ⟨hclimb, hlow⟩
  have hcast : ((l - 1 : ℕ) : ℤ) = (l : ℤ) - 1 := by omega
  have h0 := hreg 0 (l - 1) (by omega) (by omega)
  have e0 : u + ((0 * l : ℕ) : ℤ) + ((l - 1 : ℕ) : ℤ) = u + ((l - 1 : ℕ) : ℤ) := by
    push_cast; ring
  rw [e0] at h0
  have h1 := hreg 1 0 le_rfl hl
  have e1 : u + ((1 * l : ℕ) : ℤ) + ((0 : ℕ) : ℤ) = u + ((l - 1 : ℕ) : ℤ) + 1 := by
    rw [hcast]; push_cast; ring
  rw [e1] at h1
  simp only [Nat.cast_zero, add_zero] at h1
  have hd := nxtAt_drift g' hg' (u + ((l - 1 : ℕ) : ℤ))
  unfold Drift at hd
  omega

end Seam

/-! ## The ramp fixture: a pending 3-cycle with an idle sink, register climbing through the room -/

/-- Four-state object: `0 → 1 → 2 → 0` pending, `3` an idle sink reachable from everywhere. -/
def step4 : Fin 4 → Fin 4 → Bool := fun a b =>
  decide (b = 3 ∨ (a = 0 ∧ b = 1) ∨ (a = 1 ∧ b = 2) ∨ (a = 2 ∧ b = 0))

/-- Pending: everything but the sink. -/
def pend4 : Fin 4 → Bool := fun a => decide (a ≠ 3)

/-- The object walk round the 3-cycle. -/
def cyc (v : ℤ) : Fin 4 := if v % 3 = 0 then 0 else if v % 3 = 1 then 1 else 2

/-- The ramp at height `C`: pending forever up to `C` with countdown `C - v` on the 3-cycle,
register `0` for `v ≤ 0` climbing by one per step; idle at the sink from `C + 1` on, register
`C + 1`. -/
def rampRaw (C : ℕ) (v : ℤ) : Fin 4 × ℕ × ℕ :=
  if v ≤ (C : ℤ) then (cyc v, ((C : ℤ) - v).toNat, (max 0 v).toNat)
  else (3, 0, C + 1)

theorem cyc_ne_three (v : ℤ) : cyc v ≠ 3 := by
  unfold cyc; split_ifs <;> decide

theorem rampRaw_adm (C : ℕ) (v : ℤ) : (rampRaw C v).2.1 ∈ Adm pend4 (rampRaw C v).1 := by
  intro h
  unfold rampRaw at *
  split_ifs at * with h1
  · exfalso
    simp only [pend4, decide_eq_false_iff_not, not_not] at h
    exact cyc_ne_three v h
  · rfl

/-- The ramp as a ladder state function. -/
def ramp (C : ℕ) (v : ℤ) : LadderState (Fin 4) pend4 := ⟨rampRaw C v, rampRaw_adm C v⟩

theorem step4_cyc (v : ℤ) : step4 (cyc v) (cyc (v + 1)) = true := by
  have h : v % 3 = 0 ∨ v % 3 = 1 ∨ v % 3 = 2 := by omega
  unfold cyc step4
  rcases h with h | h | h
  · have h' : (v + 1) % 3 = 1 := by omega
    simp [h, h']
  · have h' : (v + 1) % 3 = 2 := by omega
    simp [h, h']
  · have h' : (v + 1) % 3 = 0 := by omega
    simp [h, h']

theorem pend4_cyc (v : ℤ) : pend4 (cyc v) = true := by
  simp [pend4, cyc_ne_three]

theorem ramp_isLadderPath (C : ℕ) : IsLadderPath step4 pend4 (ramp C) := by
  intro u
  change Rlad step4 pend4 u (rampRaw C u) (rampRaw C (u + 1))
  unfold Rlad rampRaw
  by_cases h1 : u ≤ (C : ℤ)
  · by_cases h2 : u + 1 ≤ (C : ℤ)
    · simp only [if_pos h1, if_pos h2, pend4_cyc]
      refine ⟨step4_cyc u, by simp, ?_, ?_⟩
      · unfold Drift; omega
      · unfold Count; simp; omega
    · simp only [if_pos h1, if_neg h2, pend4_cyc]
      refine ⟨by simp [step4], by simp, ?_, ?_⟩
      · unfold Drift; omega
      · unfold Count; simp [pend4]; omega
  · have h2 : ¬ u + 1 ≤ (C : ℤ) := by omega
    simp only [if_neg h1, if_neg h2]
    refine ⟨by simp [step4], by simp, ?_, ?_⟩
    · unfold Drift; omega
    · unfold Count; simp [pend4]

theorem ramp_pend_past (C : ℕ) : ∀ p : ℤ, p ≤ 0 → pend4 (objAt (ramp C) p) = true := by
  intro p hp
  have : p ≤ (C : ℤ) := by omega
  simp [objAt, ramp, rampRaw, this, pend4_cyc]

theorem ramp_cnt_zero (C : ℕ) : cntAt (ramp C) 0 = C := by
  simp [cntAt, ramp, rampRaw]

theorem ramp_nxt_zero (C : ℕ) : nxtAt (ramp C) 0 = 0 := by
  simp [nxtAt, ramp, rampRaw]

theorem ramp_nxt (C : ℕ) (v : ℤ) (h0 : 0 ≤ v) (hC : v ≤ (C : ℤ)) :
    (nxtAt (ramp C) v : ℤ) = v := by
  simp [nxtAt, ramp, rampRaw, hC]
  omega

theorem ramp_obj (C : ℕ) (v : ℤ) (hC : v ≤ (C : ℤ)) : objAt (ramp C) v = cyc v := by
  simp [objAt, ramp, rampRaw, hC]

theorem cyc_eq_imp (v w : ℤ) (h : cyc v = cyc w) : v % 3 = w % 3 := by
  have hv : v % 3 = 0 ∨ v % 3 = 1 ∨ v % 3 = 2 := by omega
  have hw : w % 3 = 0 ∨ w % 3 = 1 ∨ w % 3 = 2 := by omega
  unfold cyc at h
  rcases hv with hv | hv | hv <;> rcases hw with hw | hw | hw <;>
    simp [hv, hw] at h <;> omega

/-- **NON-VACUITY REFUTED.** On the ramp at height `C`, at every register threshold `Tn` with
`C ≤ Tn + 1`: the path is a ladder path, pending forever into the past of `0`, with countdown `C`
and register `0` at `0`; and for EVERY block `[u, u + l)` of the region `[0, C]` whose two ends
share the object state, NO ladder path carries the original's clipped register `min · Tn` at
copies `0` and `1`. The block length is arbitrary, so this holds at every spacing; no type
hypothesis is assumed, so it holds for every type-respecting block. -/
theorem no_clipped_block_on_ramp (C Tn : ℕ) (hC : C ≤ Tn + 1) :
    IsLadderPath step4 pend4 (ramp C) ∧
    (∀ p : ℤ, p ≤ 0 → pend4 (objAt (ramp C) p) = true) ∧
    cntAt (ramp C) 0 = C ∧ nxtAt (ramp C) 0 = 0 ∧
    ∀ (u : ℤ) (l : ℕ), 0 ≤ u → 0 < l → u + (l : ℤ) ≤ (C : ℤ) →
      objAt (ramp C) u = objAt (ramp C) (u + (l : ℤ)) →
      ∀ g' : ℤ → LadderState (Fin 4) pend4, IsLadderPath step4 pend4 g' →
        ¬ ∀ i j : ℕ, i ≤ 1 → j < l →
            min (nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))) Tn
              = min (nxtAt (ramp C) (u + (j : ℤ))) Tn := by
  refine ⟨ramp_isLadderPath C, ramp_pend_past C, ramp_cnt_zero C, ramp_nxt_zero C, ?_⟩
  intro u l hu hl hend hobj g' hg' hreg
  rw [ramp_obj C u (by omega), ramp_obj C _ hend] at hobj
  have hmod := cyc_eq_imp _ _ hobj
  have hl3 : 3 ≤ l := by omega
  have hn0 := ramp_nxt C u hu (by omega)
  have hn1 := ramp_nxt C (u + ((l - 1 : ℕ) : ℤ)) (by omega) (by omega)
  exact clipped_seam_necessary (ramp C) hg' u l Tn hl hreg ⟨by omega, by omega⟩

/-! ## The room: `C := Tc` is in scope, and the clipped pigeonhole does not fit -/

/-- `(K3)` puts the countdown threshold at most one above the register threshold. -/
theorem paramsOk_Tc_le_Tn_succ {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) : Tc ≤ Tn + 1 := by
  have := hp.2.2.1.1
  omega

/-- **The clipped pigeonhole's room exceeds `Tc`.** Adding the clipped register as a third
pigeonhole coordinate multiplies the sample count by `Tn + 1`; at spacing `P + 1` the window is
`b · (Tn + 1) · (P + 1)`, and `ParamsOk` itself puts that strictly above `Tc`. -/
theorem clipped_pigeonhole_room_exceeds_Tc {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    Tc < Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (Tn + 1) * (P + 1) := by
  have hle := paramsOk_Tc_le_Tn_succ step pend lab φ Tc Tn P B hp
  have hQ : 1 ≤ Fintype.card Q := Fintype.card_pos
  have hcl : 1 ≤ (plusSubformulaClosure φ).card :=
    Finset.card_pos.mpr ⟨φ, self_mem_plusSubformulaClosure φ⟩
  have h2 : 2 ≤ 2 ^ (plusSubformulaClosure φ).card := by
    calc 2 = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ (plusSubformulaClosure φ).card := Nat.pow_le_pow_right (by norm_num) hcl
  have hb : 2 ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by nlinarith
  have : 2 * (Tn + 1) * 1 ≤
      Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (Tn + 1) * (P + 1) :=
    Nat.mul_le_mul (Nat.mul_le_mul hb le_rfl) (by omega)
  omega

/-- The fixture's scope instance: the ramp at height `Tc` under any `ParamsOk`-shaped ordering
`Tc ≤ Tn + 1` has no block at all. Stated to make the composition explicit. -/
theorem no_clipped_block_at_Tc (Tc Tn : ℕ) (h : Tc ≤ Tn + 1) (P d : ℕ) (hd : 0 < d) (u : ℤ)
    (hu : 0 ≤ u) (hend : u + ((d * (P + 1) : ℕ) : ℤ) ≤ (Tc : ℤ))
    (hobj : objAt (ramp Tc) u = objAt (ramp Tc) (u + ((d * (P + 1) : ℕ) : ℤ)))
    (g' : ℤ → LadderState (Fin 4) pend4) (hg' : IsLadderPath step4 pend4 g') :
    ¬ ∀ i j : ℕ, i ≤ 1 → j < d * (P + 1) →
        min (nxtAt g' (u + ((i * (d * (P + 1)) : ℕ) : ℤ) + (j : ℤ))) Tn
          = min (nxtAt (ramp Tc) (u + (j : ℤ))) Tn :=
  (no_clipped_block_on_ramp Tc Tn h).2.2.2.2 u (d * (P + 1)) hu (Nat.mul_pos hd (Nat.succ_pos P))
    hend hobj g' hg'

/-! ## The fixture is in the pump's scope: the ladder frame exists on it and `ParamsOk` holds -/

/-- The cycle predecessor / successor on the pending states. -/
def nxt4 : Fin 4 → Fin 4 := fun a => if a = 0 then 1 else if a = 1 then 2 else 0

def prv4 : Fin 4 → Fin 4 := fun a => if a = 0 then 2 else if a = 1 then 0 else 1

theorem pend4_three : pend4 3 = false := by decide

theorem step4_nxt4 : ∀ q : Fin 4, q ≠ 3 → step4 q (nxt4 q) = true := by decide

theorem step4_prv4 : ∀ q : Fin 4, q ≠ 3 → step4 (prv4 q) q = true := by decide

/-- Forward seriality of the admissible ladder relation on the fixture. -/
theorem fwd4 : ∀ t x, ∃ y, RladAdm step4 pend4 t x y := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  by_cases hq : q = 3
  · subst hq
    have hc : c = 0 := hx pend4_three
    subst hc
    exact ⟨⟨(3, 0, n), fun _ => rfl⟩, by
      change Rlad step4 pend4 t (3, 0, n) (3, 0, n)
      unfold Rlad Drift Count; simp [step4, pend4]⟩
  · rcases Nat.eq_zero_or_pos c with hc | hc
    · subst hc
      exact ⟨⟨(3, 0, n), fun _ => rfl⟩, by
        change Rlad step4 pend4 t (q, 0, n) (3, 0, n)
        unfold Rlad Drift Count; simp [step4, pend4]⟩
    · have hn : nxt4 q ≠ 3 := by unfold nxt4; split_ifs <;> decide
      refine ⟨⟨(nxt4 q, c - 1, n), fun h => ?_⟩, ?_⟩
      · exact absurd h (by simp [pend4, hn])
      · change Rlad step4 pend4 t (q, c, n) (nxt4 q, c - 1, n)
        have hs : step4 q (nxt4 q) = true := step4_nxt4 q hq
        unfold Rlad Drift Count
        simp [hs, pend4, hq, hn]
        omega

/-- Backward seriality of the admissible ladder relation on the fixture. -/
theorem bwd4 : ∀ t x, ∃ y, RladAdm step4 pend4 (t - 1) y x := by
  rintro t ⟨⟨q, c, n⟩, hx⟩
  by_cases hq : q = 3
  · subst hq
    have hc : c = 0 := hx pend4_three
    subst hc
    exact ⟨⟨(3, 0, n), fun _ => rfl⟩, by
      change Rlad step4 pend4 (t - 1) (3, 0, n) (3, 0, n)
      unfold Rlad Drift Count; simp [step4, pend4]⟩
  · have hn : prv4 q ≠ 3 := by unfold prv4; split_ifs <;> decide
    refine ⟨⟨(prv4 q, c + 1, n), fun h => ?_⟩, ?_⟩
    · exact absurd h (by simp [pend4, hn])
    · change Rlad step4 pend4 (t - 1) (prv4 q, c + 1, n) (q, c, n)
      have hs : step4 (prv4 q) q = true := step4_prv4 q hq
      unfold Rlad Drift Count
      simp [hs, pend4, hq, hn]

/-- **THE CAPSTONE, AT THE FIXTURE'S OWN DISCHARGED PARAMETERS.** For every labelling and every
formula, at the parameters `paramsOk_params` discharges (`Tcof`, `Tnof`, `Pof`, `Bof`):
`ParamsOk` holds, the ramp at height `Tcof` is a pending-forever-past ladder path whose state at
`0` has countdown exactly `Tcof` and register `0`, and NO block of the region at spacing
`Pof + 1` with a repeated object state admits a ladder path carrying the clipped register at
copies `0` and `1`. -/
theorem no_clipped_block_at_params (lab : Fin 4 → Atom → Bool) (φ : PlusFormula) :
    ParamsOk step4 pend4 lab φ (Tcof step4 pend4 lab φ) (Tnof step4 pend4 lab φ)
      (Pof step4 pend4 lab φ) (Bof step4 pend4 lab φ) ∧
    IsLadderPath step4 pend4 (ramp (Tcof step4 pend4 lab φ)) ∧
    (∀ p : ℤ, p ≤ 0 → pend4 (objAt (ramp (Tcof step4 pend4 lab φ)) p) = true) ∧
    cntAt (ramp (Tcof step4 pend4 lab φ)) 0 = Tcof step4 pend4 lab φ ∧
    nxtAt (ramp (Tcof step4 pend4 lab φ)) 0 = 0 ∧
    ∀ (u : ℤ) (d : ℕ), 0 ≤ u → 0 < d →
      u + ((d * (Pof step4 pend4 lab φ + 1) : ℕ) : ℤ) ≤ (Tcof step4 pend4 lab φ : ℤ) →
      objAt (ramp (Tcof step4 pend4 lab φ)) u
        = objAt (ramp (Tcof step4 pend4 lab φ))
            (u + ((d * (Pof step4 pend4 lab φ + 1) : ℕ) : ℤ)) →
      ∀ g' : ℤ → LadderState (Fin 4) pend4, IsLadderPath step4 pend4 g' →
        ¬ ∀ i j : ℕ, i ≤ 1 → j < d * (Pof step4 pend4 lab φ + 1) →
            min (nxtAt g' (u + ((i * (d * (Pof step4 pend4 lab φ + 1)) : ℕ) : ℤ) + (j : ℤ)))
                (Tnof step4 pend4 lab φ)
              = min (nxtAt (ramp (Tcof step4 pend4 lab φ)) (u + (j : ℤ)))
                  (Tnof step4 pend4 lab φ) := by
  have hp := paramsOk_params step4 pend4 lab φ
  have hle := paramsOk_Tc_le_Tn_succ step4 pend4 lab φ _ _ _ _ hp
  have h := no_clipped_block_on_ramp (Tcof step4 pend4 lab φ) (Tnof step4 pend4 lab φ) hle
  exact ⟨hp, h.1, h.2.1, h.2.2.1, h.2.2.2.1, fun u d hu hd hend hobj g' hg' =>
    no_clipped_block_at_Tc _ _ hle _ d hd u hu hend hobj g' hg'⟩

/-! ## The condition is inhabited: it is not contradictory, only not universal -/

/-- On any ladder path whose register is constant, the path itself carries its own clipped
register at copies `0` and `1` of every block — the plateau shape. So the block condition is
satisfiable; what fails is its universality. -/
theorem exists_clipped_block_on_plateau_shape {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (n : ℕ)
    (hconst : ∀ v : ℤ, nxtAt g v = n) (u : ℤ) (l Tn : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      ∀ i j : ℕ, i ≤ 1 → j < l →
        min (nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))) Tn
          = min (nxtAt g (u + (j : ℤ))) Tn :=
  ⟨g, hg, fun i j _ _ => by rw [hconst, hconst]⟩

/-! ## The gap-shaped register conjunct, on the same ramp -/

theorem ramp_cnt (C : ℕ) (v : ℤ) (hC : v ≤ (C : ℤ)) :
    (cntAt (ramp C) v : ℤ) = (C : ℤ) - v := by
  simp [cntAt, ramp, rampRaw, hC]

/-- **THE GAP-SHAPED CONJUNCT IS REFUTED ON THE RAMP.** On the ramp at every height `C`: the path
is a ladder path, pending forever into the past of `0`, with countdown `C` at `0`; and for EVERY
block `[u, u + l)` of the region `[0, C]` of length at least two, NO ladder path is pending at
position `j` of copies `0` and `1` while carrying the ramp's signed gap `n − c` at `u + j`. The
ramp's gap rises by two per position; the conjunct forbids it to rise across the block at all. -/
theorem gap_conjunct_refuted_on_ramp (C : ℕ) :
    IsLadderPath step4 pend4 (ramp C) ∧
    (∀ p : ℤ, p ≤ 0 → pend4 (objAt (ramp C) p) = true) ∧
    cntAt (ramp C) 0 = C ∧
    ∀ (u : ℤ) (l : ℕ), 0 ≤ u → 2 ≤ l → u + (l : ℤ) ≤ (C : ℤ) →
      ∀ g' : ℤ → LadderState (Fin 4) pend4, IsLadderPath step4 pend4 g' →
        ¬ ∀ i j : ℕ, i ≤ 1 → j < l →
            pend4 (objAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))) = true ∧
            (nxtAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ)) : ℤ)
                - cntAt g' (u + ((i * l : ℕ) : ℤ) + (j : ℤ))
              = (nxtAt (ramp C) (u + (j : ℤ)) : ℤ) - cntAt (ramp C) (u + (j : ℤ)) := by
  refine ⟨ramp_isLadderPath C, ramp_pend_past C, ramp_cnt_zero C, ?_⟩
  intro u l hu hl hend g' hg' hgap
  have h := iterSpliced_gap_interior_forces_block_gap_le (ramp C) hg' u l (by omega) hgap
  have hn0 := ramp_nxt C u hu (by omega)
  have hn1 := ramp_nxt C (u + ((l - 1 : ℕ) : ℤ)) (by omega) (by omega)
  have hc0 := ramp_cnt C u (by omega)
  have hc1 := ramp_cnt C (u + ((l - 1 : ℕ) : ℤ)) (by omega)
  omega

/-- **THE SAME, AT THE FIXTURE'S OWN DISCHARGED PARAMETERS**, in the shape of
`no_clipped_block_at_params`: at the height `Tcof` and spacing `Pof + 1`, for every block with a
repeated object state, no ladder path carries the gap-shaped conjunct at copies `0` and `1`. The
object repeat is what puts the block length at three or more. -/
theorem gap_conjunct_refuted_at_params (lab : Fin 4 → Atom → Bool) (φ : PlusFormula) :
    ParamsOk step4 pend4 lab φ (Tcof step4 pend4 lab φ) (Tnof step4 pend4 lab φ)
      (Pof step4 pend4 lab φ) (Bof step4 pend4 lab φ) ∧
    ∀ (u : ℤ) (d : ℕ), 0 ≤ u → 0 < d →
      u + ((d * (Pof step4 pend4 lab φ + 1) : ℕ) : ℤ) ≤ (Tcof step4 pend4 lab φ : ℤ) →
      objAt (ramp (Tcof step4 pend4 lab φ)) u
        = objAt (ramp (Tcof step4 pend4 lab φ))
            (u + ((d * (Pof step4 pend4 lab φ + 1) : ℕ) : ℤ)) →
      ∀ g' : ℤ → LadderState (Fin 4) pend4, IsLadderPath step4 pend4 g' →
        ¬ ∀ i j : ℕ, i ≤ 1 → j < d * (Pof step4 pend4 lab φ + 1) →
            pend4 (objAt g' (u + ((i * (d * (Pof step4 pend4 lab φ + 1)) : ℕ) : ℤ) + (j : ℤ)))
                = true ∧
            (nxtAt g' (u + ((i * (d * (Pof step4 pend4 lab φ + 1)) : ℕ) : ℤ) + (j : ℤ)) : ℤ)
                - cntAt g' (u + ((i * (d * (Pof step4 pend4 lab φ + 1)) : ℕ) : ℤ) + (j : ℤ))
              = (nxtAt (ramp (Tcof step4 pend4 lab φ)) (u + (j : ℤ)) : ℤ)
                  - cntAt (ramp (Tcof step4 pend4 lab φ)) (u + (j : ℤ)) := by
  refine ⟨paramsOk_params step4 pend4 lab φ, fun u d hu hd hend hobj g' hg' => ?_⟩
  have hpos : 0 < d * (Pof step4 pend4 lab φ + 1) := Nat.mul_pos hd (Nat.succ_pos _)
  rw [ramp_obj _ u (by omega), ramp_obj _ _ hend] at hobj
  have hmod := cyc_eq_imp _ _ hobj
  exact (gap_conjunct_refuted_on_ramp (Tcof step4 pend4 lab φ)).2.2.2 u _ hu (by omega) hend
    g' hg'

end ProbeB1

#print axioms ProbeB1.clipped_seam_necessary
#print axioms ProbeB1.no_clipped_block_on_ramp
#print axioms ProbeB1.no_clipped_block_at_Tc
#print axioms ProbeB1.fwd4
#print axioms ProbeB1.bwd4
#print axioms ProbeB1.no_clipped_block_at_params
#print axioms ProbeB1.paramsOk_Tc_le_Tn_succ
#print axioms ProbeB1.clipped_pigeonhole_room_exceeds_Tc
#print axioms ProbeB1.exists_clipped_block_on_plateau_shape
#print axioms ProbeB1.gap_conjunct_refuted_on_ramp
#print axioms ProbeB1.gap_conjunct_refuted_at_params
