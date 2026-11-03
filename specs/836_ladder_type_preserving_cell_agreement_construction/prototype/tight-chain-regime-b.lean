/-
THE REGIME-B DECISION GATE: the tight doubling chain, and the spanning-block condition the
backward and forward cascades would need — stated in both directions and REFUTED in both.

Prototype, compiled standalone with `lake env lean` through the build guard; NOT a wired probe.
It settles the gate of the plan's Phase 3: whether a type-respecting block SPANNING a region
start (so each copy of the block carries a pin, and pumping the copies can rebuild the register)
is derivable from `ParamsOk`, in the backward direction (a block containing a region start in the
past of `z`) and in the forward direction (a block containing the start of the region after
`z`'s).

**The tight doubling chain** (`wT`, `cT`, `tightChain_isLadderPath`, `tightChain_pin`,
`tightChain_slack_zero`): regions of lengths `2^j - 1` for `j = 1..J`, separated by unit idle
runs at the positions `2^j - 2`, with the next-deadline register climbing by exactly `1` per
step (`n v = v` at every pin). Every backward gap between consecutive pins has Lipschitz slack
`0`: `s' - s = n s' - n s`. Lengthening the last region by `l` raises its pin by `l` and forces
`l` more positions before it; lengthening the previous region by duplicating a block inside it
raises THAT region's pin by the same amount; so the cascade reaches every pin of the chain. The
chain is built through the landed lift `exists_ladderPath_of_walk`, with `n₀ := 0`.

**The spanning-block condition** (`SpanningBlockBwd`, `SpanningBlockFwd`): under `ParamsOk`, for
a stab-free closure, every ladder path with an idle position below `z` and `Tc ≤ cntAt g z`
carries, in the past of `z`, a block `[u, u + l)` with equal object state and equal realized type
at its two ends that contains an idle position followed by a pending one (a region start); and
the forward mirror, with the block above `z`.

**Both are REFUTED**, each by a compiled object smaller than the chain.
* BACKWARD (`spanningBlockBwd_refuted`): the path `gB` pending forever into the past, idle at
  `0`, pending on `[1, L]`, idle from `L + 1` on, with `L := Tc + 2` so that `z := 2` has
  countdown `Tc`. The closure of `chiB := a S ¬a` (`dBack = 1`, `dFwd = 0`, stab-free) separates
  every position `u ≤ 0` (no idle position in the past: `chiB` false) from the position `2`
  (`chiB` true through the idle position `0`). The only region start in the past of `2` is at
  `1`, so a spanning block has `u ≤ 0` and `u + l = 2`, and its ends carry different types.
* FORWARD (`spanningBlockFwd_refuted`): Probe761C's own path `gC` (pending on `(-∞, c₀]`, idle
  forever after, constant register) has NO idle position followed by a pending one above any
  `z`, so no block above `z` contains a region start at all; `z := 0` with `c₀ := Tc`.

**What this does and does not say.** It refutes the spanning-block DEVICE as a consequence of
the parameter conditions, in both directions, and so it is the FAIL branch of the gate. It says
nothing about the depth-`0` obligation under the repaired `(K4)` at these two objects: on `gB` the
register before the single idle position is free of every pin, and on `gC` the register after
`z`'s region is free of every pin, so at THESE objects the register can be rebuilt without any
spanning block. The open core is the chain, where every pin is tight and the device was the only
candidate for rebuilding the register type-respectingly; no derivation of the device from
`(K1)`-`(K4)` is possible, because the device is false where the parameter conditions hold.

**The past-extension attempt on the chain** (the plan's third task) stops at the type
condition: for the register alone, duplicating a block of length `l` spanning the pin `2^J - 2`
needs `2^(J-1) ≤ l ≤ 2^J` (the pin of the inserted region is `l - 2`, and the two gaps around it
must each have slack `≥ 0`); but the closure of a formula of `U`-nesting depth `D` distinguishes
the last `D` regions of the chain from each other (`a U (¬a ∧ X ¬a)` sees the idle-forever tail
one region ahead, its `U`-nested iterates see it `D` regions ahead), so for `J ≤ D + 1` no
spanning block exists at any pin of the chain for that formula, and the attempt does not reach
the register rebuild.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe836B

/-! ### The object: Probe761C's own -/

abbrev Qc : Type := Fin 2

def pendC : Qc → Bool := fun q => decide (q = 0)

def stepC : Qc → Qc → Bool := fun _ _ => true

def pC : Atom := ⟨"p", none⟩

def labC : Qc → Atom → Bool := fun q at_ => decide (at_ = pC ∧ q = 0)

theorem pendC_zero : pendC 0 = true := by decide

theorem pendC_one : pendC 1 = false := by decide

theorem labC_pC (q : Qc) : labC q pC = pendC q := by
  simp [labC, pendC]

theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) (by simp)

theorem fwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC t x y := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · cases c with
    | zero =>
        refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_one]
    | succ d =>
        refine ⟨⟨(0, d, n), admZeroC d n⟩, rfl, hx, Or.inl rfl, ?_⟩
        simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    refine ⟨⟨(1, 0, n), fun _ => rfl⟩, rfl, hx, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_one]

theorem bwdC : ∀ (t : ℤ) (x : LadderState Qc pendC), ∃ y, RladAdm stepC pendC (t - 1) y x := by
  intro _ x
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  by_cases hq : pendC q = true
  · refine ⟨⟨(0, c + 1, n), admZeroC (c + 1) n⟩, rfl, admZeroC (c + 1) n,
      Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero]
  · rw [Bool.not_eq_true] at hq
    have hc : c = 0 := hx hq
    refine ⟨⟨(0, 0, n), admZeroC 0 n⟩, rfl, admZeroC 0 n, Or.inl rfl, ?_⟩
    simp [Count, hq, pendC_zero, hc]

/-! ### The tight doubling chain -/

section Chain

open Classical

variable (J : ℕ)

/-- The idle positions of the chain: everything at or before `0`, the pins `2^j - 2` for
`1 ≤ j ≤ J`, and everything from `2^(J+1) - 2` on. -/
def idleT (v : ℤ) : Prop :=
  v ≤ 0 ∨ (2 : ℤ) ^ (J + 1) - 2 ≤ v ∨ ∃ j, 1 ≤ j ∧ j ≤ J ∧ v = (2 : ℤ) ^ j - 2

noncomputable def wT (v : ℤ) : Qc := if idleT J v then 1 else 0

theorem pendC_wT_iff (v : ℤ) : pendC (wT J v) = false ↔ idleT J v := by
  unfold wT
  split_ifs with h <;> simp [pendC, h]

theorem pendC_wT_true_iff (v : ℤ) : pendC (wT J v) = true ↔ ¬ idleT J v := by
  rw [← Bool.not_eq_false, pendC_wT_iff]

theorem two_pow_pos' (n : ℕ) : (0 : ℤ) < (2 : ℤ) ^ n := by positivity

theorem two_pow_mono {m n : ℕ} (h : m ≤ n) : (2 : ℤ) ^ m ≤ (2 : ℤ) ^ n :=
  pow_le_pow_right₀ (by norm_num) h

theorem two_pow_strict_mono {m n : ℕ} (h : m < n) : (2 : ℤ) ^ m < (2 : ℤ) ^ n :=
  pow_lt_pow_right₀ (by norm_num) h

theorem two_pow_lt_iff {m n : ℕ} : (2 : ℤ) ^ m < (2 : ℤ) ^ n ↔ m < n :=
  pow_lt_pow_iff_right₀ (by norm_num)

/-- There is an idle position after every position. -/
theorem exists_idle_after (v : ℤ) : ∃ k : ℕ, idleT J (v + (k : ℤ) + 1) := by
  refine ⟨((2 : ℤ) ^ (J + 1) - 2 - v).toNat, Or.inr (Or.inl ?_)⟩
  omega

/-- The countdown of the chain: `0` at an idle position, the distance to the next idle position
minus one at a pending one. -/
noncomputable def cT (v : ℤ) : ℕ :=
  if idleT J v then 0 else Nat.find (exists_idle_after J v)

theorem cT_of_idle (v : ℤ) (h : idleT J v) : cT J v = 0 := by
  unfold cT; rw [if_pos h]

theorem cT_of_pend (v : ℤ) (h : ¬ idleT J v) : cT J v = Nat.find (exists_idle_after J v) := by
  unfold cT; rw [if_neg h]

/-- A pin — an idle position followed by a pending one — is one of the `2^j - 2`. -/
theorem pin_eq (v : ℤ) (h0 : idleT J v) (h1 : ¬ idleT J (v + 1)) :
    ∃ j, 1 ≤ j ∧ j ≤ J ∧ v = (2 : ℤ) ^ j - 2 := by
  rcases h0 with h | h | h
  · -- `v ≤ 0`: then `v = 0`, which is `2^1 - 2`, and `J ≥ 1` since `1` is pending
    have hv : v = 0 := by
      by_contra hne
      exact h1 (Or.inl (by omega))
    subst hv
    refine ⟨1, le_rfl, ?_, by norm_num⟩
    by_contra hJ
    have hJ0 : J = 0 := by omega
    subst hJ0
    exact h1 (Or.inr (Or.inl (by norm_num)))
  · exact absurd (Or.inr (Or.inl (by omega))) h1
  · exact h

/-- No idle position lies strictly between two consecutive pins. -/
theorem no_idle_between (j : ℕ) (hj1 : 1 ≤ j) (hjJ : j ≤ J) (v : ℤ)
    (hlo : (2 : ℤ) ^ j - 2 < v) (hhi : v < (2 : ℤ) ^ (j + 1) - 2) : ¬ idleT J v := by
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := by
    calc (2 : ℤ) = (2 : ℤ) ^ 1 := by norm_num
      _ ≤ (2 : ℤ) ^ j := two_pow_mono hj1
  have hJ1 : (2 : ℤ) ^ (j + 1) ≤ (2 : ℤ) ^ (J + 1) := two_pow_mono (by omega)
  rintro (h | h | ⟨i, hi1, hiJ, rfl⟩)
  · omega
  · omega
  · have hlt1 : (2 : ℤ) ^ j < (2 : ℤ) ^ i := by omega
    have hlt2 : (2 : ℤ) ^ i < (2 : ℤ) ^ (j + 1) := by omega
    have := two_pow_lt_iff.mp hlt1
    have := two_pow_lt_iff.mp hlt2
    omega

/-- The position `2^(j+1) - 2` after a pin is idle. -/
theorem idle_next_pin (j : ℕ) (hj1 : 1 ≤ j) (hjJ : j ≤ J) : idleT J ((2 : ℤ) ^ (j + 1) - 2) := by
  rcases lt_or_eq_of_le hjJ with h | h
  · exact Or.inr (Or.inr ⟨j + 1, by omega, by omega, rfl⟩)
  · subst h; exact Or.inr (Or.inl le_rfl)

/-- **The countdown at a region start is the pin's position**: the next idle position after
`2^j - 2 + 1` is `2^(j+1) - 2`. -/
theorem cT_pin_succ (j : ℕ) (hj1 : 1 ≤ j) (hjJ : j ≤ J) :
    cT J ((2 : ℤ) ^ j - 2 + 1) = ((2 : ℤ) ^ j - 2).toNat := by
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := by
    calc (2 : ℤ) = (2 : ℤ) ^ 1 := by norm_num
      _ ≤ (2 : ℤ) ^ j := two_pow_mono hj1
  have hpend : ¬ idleT J ((2 : ℤ) ^ j - 2 + 1) :=
    no_idle_between J j hj1 hjJ _ (by omega) (by rw [pow_succ]; omega)
  rw [cT_of_pend J _ hpend, Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · have : (2 : ℤ) ^ j - 2 + 1 + ((((2 : ℤ) ^ j - 2).toNat : ℕ) : ℤ) + 1 = (2 : ℤ) ^ (j + 1) - 2 := by
      rw [pow_succ]; omega
    rw [this]
    exact idle_next_pin J j hj1 hjJ
  · intro n hn
    apply no_idle_between J j hj1 hjJ
    · omega
    · rw [pow_succ]; omega

/-- Inside a region the countdown counts down. -/
theorem cT_pend_pend (v : ℤ) (h0 : ¬ idleT J v) (h1 : ¬ idleT J (v + 1)) :
    cT J (v + 1) + 1 = cT J v := by
  rw [cT_of_pend J v h0, cT_of_pend J (v + 1) h1]
  symm
  rw [Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · have := Nat.find_spec (exists_idle_after J (v + 1))
    rw [show v + ((Nat.find (exists_idle_after J (v + 1)) + 1 : ℕ) : ℤ) + 1
        = v + 1 + ((Nat.find (exists_idle_after J (v + 1)) : ℕ) : ℤ) + 1 by push_cast; ring]
    exact this
  · intro n hn
    cases n with
    | zero => simpa using h1
    | succ m =>
        have hm : m < Nat.find (exists_idle_after J (v + 1)) := by omega
        have := Nat.find_min (exists_idle_after J (v + 1)) hm
        rwa [show v + ((m + 1 : ℕ) : ℤ) + 1 = v + 1 + (m : ℤ) + 1 by push_cast; ring]

/-- At a region's last pending position the countdown is `0`. -/
theorem cT_pend_idle (v : ℤ) (h0 : ¬ idleT J v) (h1 : idleT J (v + 1)) : cT J v = 0 := by
  rw [cT_of_pend J v h0, Nat.find_eq_zero]
  simpa using h1

/-- **THE TIGHT DOUBLING CHAIN IS A LADDER PATH**, through the landed lift of a walk with its
forced countdown, with the register's base value `0`. -/
theorem tightChain_isLadderPath :
    ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
      (∀ v, objAt g v = wT J v) ∧ (∀ v, cntAt g v = cT J v) := by
  -- every pin carries countdown equal to its position
  have hpin : ∀ s : ℤ, pendC (wT J s) = false → pendC (wT J (s + 1)) = true →
      (cT J (s + 1) : ℤ) = s := by
    intro s h0 h1
    rw [pendC_wT_iff] at h0
    rw [pendC_wT_true_iff] at h1
    obtain ⟨j, hj1, hjJ, rfl⟩ := pin_eq J s h0 h1
    rw [cT_pin_succ J j hj1 hjJ]
    have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := by
      calc (2 : ℤ) = (2 : ℤ) ^ 1 := by norm_num
        _ ≤ (2 : ℤ) ^ j := two_pow_mono hj1
    omega
  refine exists_ladderPath_of_walk (wT J) (cT J) 0 (fun _ => rfl) ?_ ?_ ?_ ?_ ?_
  · intro v h
    exact cT_of_idle J v ((pendC_wT_iff J v).mp h)
  · intro v h0 h1
    exact cT_pend_pend J v ((pendC_wT_true_iff J v).mp h0) ((pendC_wT_true_iff J (v + 1)).mp h1)
  · intro v h0 h1
    exact cT_pend_idle J v ((pendC_wT_true_iff J v).mp h0) ((pendC_wT_iff J (v + 1)).mp h1)
  · intro s v hs0 hs1 hv0 hv1
    rw [hpin s hs0 hs1, hpin v hv0 hv1]
  · intro v h0 h1
    rw [hpin v h0 h1]
    simp

/-- **The register equals the position at every pin of the chain.** -/
theorem tightChain_pin (g : ℤ → LadderState Qc pendC) (hg : IsLadderPath stepC pendC g)
    (hobj : ∀ v, objAt g v = wT J v) (hcnt : ∀ v, cntAt g v = cT J v)
    (s : ℤ) (h0 : pendC (objAt g s) = false) (h1 : pendC (objAt g (s + 1)) = true) :
    (nxtAt g s : ℤ) = s := by
  rw [← cntAt_eq_nxtAt_of_idle_pend g hg s h0 h1, hcnt]
  rw [hobj, pendC_wT_iff] at h0
  rw [hobj, pendC_wT_true_iff] at h1
  obtain ⟨j, hj1, hjJ, rfl⟩ := pin_eq J s h0 h1
  rw [cT_pin_succ J j hj1 hjJ]
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := by
    calc (2 : ℤ) = (2 : ℤ) ^ 1 := by norm_num
      _ ≤ (2 : ℤ) ^ j := two_pow_mono hj1
  omega

/-- **EVERY GAP BETWEEN PINS HAS LIPSCHITZ SLACK `0`**: the register climbs by exactly the
distance between any two pins. -/
theorem tightChain_slack_zero (g : ℤ → LadderState Qc pendC) (hg : IsLadderPath stepC pendC g)
    (hobj : ∀ v, objAt g v = wT J v) (hcnt : ∀ v, cntAt g v = cT J v)
    (s s' : ℤ) (hs0 : pendC (objAt g s) = false) (hs1 : pendC (objAt g (s + 1)) = true)
    (hs0' : pendC (objAt g s') = false) (hs1' : pendC (objAt g (s' + 1)) = true)
    (hle : s ≤ s') :
    s' - s = ((nxtAt g s' : ℤ) - nxtAt g s).natAbs := by
  rw [tightChain_pin J g hg hobj hcnt s hs0 hs1, tightChain_pin J g hg hobj hcnt s' hs0' hs1']
  omega

/-- The chain has `J` pins, so it is not the degenerate all-idle walk once `J ≥ 1`. -/
theorem tightChain_pins (j : ℕ) (hj1 : 1 ≤ j) (hjJ : j ≤ J) :
    pendC (wT J ((2 : ℤ) ^ j - 2)) = false ∧ pendC (wT J ((2 : ℤ) ^ j - 2 + 1)) = true := by
  refine ⟨(pendC_wT_iff J _).mpr (Or.inr (Or.inr ⟨j, hj1, hjJ, rfl⟩)), ?_⟩
  rw [pendC_wT_true_iff]
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := by
    calc (2 : ℤ) = (2 : ℤ) ^ 1 := by norm_num
      _ ≤ (2 : ℤ) ^ j := two_pow_mono hj1
  exact no_idle_between J j hj1 hjJ _ (by omega) (by rw [pow_succ]; omega)

end Chain

/-! ### The spanning-block condition, in both directions -/

section Condition

variable {Q : Type} [Fintype Q] [Nonempty Q]

/-- **BACKWARD.** Under the parameter conditions, for a stab-free closure, every ladder path with
an idle position below `z` and `Tc ≤ cntAt g z` carries, in the past of `z`, a block
`[u, u + l)` with equal object state and equal realized type at its ends that contains a region
start (an idle position `s` with `s + 1` pending). -/
def SpanningBlockBwd (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
    ∀ (z p : ℤ), p < z → pend (objAt g p) = false → Tc ≤ cntAt g z →
    ∀ (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      (∀ t : ℤ, σ.state t = (t, g t)) →
      ∃ (u : ℤ) (l : ℕ) (s : ℤ), 0 < l ∧ u ≤ s ∧ s + 1 < u + (l : ℤ) ∧ u + (l : ℤ) ≤ z ∧
        pend (objAt g s) = false ∧ pend (objAt g (s + 1)) = true ∧
        objAt g u = objAt g (u + (l : ℤ)) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ u
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))

/-- **FORWARD.** The mirror: a block above `z` containing a region start. -/
def SpanningBlockFwd (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (g : ℤ → LadderState Q pend), IsLadderPath step pend g →
    ∀ z : ℤ, pend (objAt g z) = true → Tc ≤ cntAt g z →
    ∀ (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      (∀ t : ℤ, σ.state t = (t, g t)) →
      ∃ (u : ℤ) (l : ℕ) (s : ℤ), 0 < l ∧ z < u ∧ u ≤ s ∧ s + 1 < u + (l : ℤ) ∧
        pend (objAt g s) = false ∧ pend (objAt g (s + 1)) = true ∧
        objAt g u = objAt g (u + (l : ℤ)) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ u
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))

end Condition

/-! ### The formula `a S ¬a`, and the parameters -/

def aD : PlusFormula := .atom pC

def naD : PlusFormula := PlusFormula.neg aD

/-- `a S ¬a`: there is an idle position in the past with only pending positions after it. -/
def chiB : PlusFormula := .snce aD naD

theorem no_stab_in_closure_chiB :
    ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure chiB := by
  intro χ h
  simp [plusSubformulaClosure, chiB, aD, naD, PlusFormula.neg, PlusFormula.subformulas] at h

noncomputable def TcB : ℕ := Tcof stepC pendC labC chiB
noncomputable def TnB : ℕ := Tnof stepC pendC labC chiB
noncomputable def PB : ℕ := Pof stepC pendC labC chiB
noncomputable def BB : ℕ := Bof stepC pendC labC chiB

theorem paramsOkB : ParamsOk stepC pendC labC chiB TcB TnB PB BB :=
  paramsOk_params stepC pendC labC chiB

noncomputable abbrev MB := ladderModel stepC pendC fwdC bwdC labC

abbrev HistB := WorldHistory (ladderFrameAdm stepC pendC fwdC bwdC).toTaskFrame

theorem atom_iff_pend {g : ℤ → LadderState Qc pendC} (τ : HistB)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (t : ℤ) :
    PlusTruthAt MB τ t aD ↔ pendC (objAt g t) = true := by
  rw [aD, PlusTruth.atom_iff, hτ t]
  change labC (objAt g t) pC = true ↔ _
  rw [labC_pC]

theorem natom_iff_idle {g : ℤ → LadderState Qc pendC} (τ : HistB)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) (t : ℤ) :
    PlusTruthAt MB τ t naD ↔ pendC (objAt g t) = false := by
  rw [naD, PlusTruth.neg_iff, atom_iff_pend τ hτ t]
  simp

/-! ### The backward witness: pending forever into the past, idle at `0`, a region of length
`L` on `[1, L]`, idle from `L + 1` on; constant register `L - 1`. -/

def wB (L : ℕ) : ℤ → Qc := fun v => if v = 0 then 1 else if v ≤ (L : ℤ) then 0 else 1

def cB (L : ℕ) : ℤ → ℕ := fun v =>
  if v < 0 then (-1 - v).toNat else if v = 0 then 0 else if v ≤ (L : ℤ) then ((L : ℤ) - v).toNat else 0

theorem pendC_wB_iff (L : ℕ) (v : ℤ) :
    pendC (wB L v) = false ↔ (v = 0 ∨ (L : ℤ) < v) := by
  unfold wB
  split_ifs with h1 h2 <;> simp [pendC] <;> omega

theorem pendC_wB_true_iff (L : ℕ) (v : ℤ) :
    pendC (wB L v) = true ↔ (v ≠ 0 ∧ v ≤ (L : ℤ)) := by
  rw [← Bool.not_eq_false, pendC_wB_iff]; omega

/-- The walk `wB` with its countdown `cB` lifts to a ladder path. -/
theorem exists_gB (L : ℕ) (hL : 1 ≤ L) :
    ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
      (∀ v, objAt g v = wB L v) ∧ (∀ v, cntAt g v = cB L v) := by
  -- the only pin is at `0`
  have hpin : ∀ s : ℤ, pendC (wB L s) = false → pendC (wB L (s + 1)) = true → s = 0 := by
    intro s h0 h1
    rw [pendC_wB_iff] at h0
    rw [pendC_wB_true_iff] at h1
    omega
  refine exists_ladderPath_of_walk (wB L) (cB L) (L - 1) (fun _ => rfl) ?_ ?_ ?_ ?_ ?_
  · intro v h
    rw [pendC_wB_iff] at h
    unfold cB; split_ifs <;> omega
  · intro v h0 h1
    rw [pendC_wB_true_iff] at h0 h1
    unfold cB; split_ifs <;> omega
  · intro v h0 h1
    rw [pendC_wB_true_iff] at h0
    rw [pendC_wB_iff] at h1
    unfold cB; split_ifs <;> omega
  · intro s v hs0 hs1 hv0 hv1
    rw [hpin s hs0 hs1, hpin v hv0 hv1]
    simp
  · intro v h0 h1
    rw [hpin v h0 h1]
    simp only [cB]
    rw [if_neg (by omega), if_neg (by omega), if_pos (by omega)]
    omega

/-- `chiB` holds at `2` along the witness: the idle position `0` is in the past, with the pending
position `1` between. -/
theorem chiB_true_two (L : ℕ) (hL : 2 ≤ L) {g : ℤ → LadderState Qc pendC}
    (hobj : ∀ v, objAt g v = wB L v) (τ : HistB) (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    PlusTruthAt MB τ 2 chiB := by
  rw [chiB, PlusTruth.snce_iff]
  refine ⟨0, by norm_num, ?_, ?_⟩
  · rw [natom_iff_idle τ hτ, hobj, pendC_wB_iff]
    exact Or.inl rfl
  · intro r h1 h2
    obtain ⟨r', rfl⟩ : ∃ r' : ℤ, r' = r := ⟨r, rfl⟩
    have h1' : (0 : ℤ) < r' := h1
    have h2' : r' < (2 : ℤ) := h2
    rw [atom_iff_pend τ hτ, hobj, pendC_wB_true_iff]
    omega

/-- `chiB` fails at every position at or before `0`: nothing in the past is idle. -/
theorem chiB_false_of_le_zero (L : ℕ) {g : ℤ → LadderState Qc pendC}
    (hobj : ∀ v, objAt g v = wB L v) (τ : HistB) (hτ : ∀ t : ℤ, τ.state t = (t, g t))
    (u : ℤ) (hu : u ≤ 0) : ¬ PlusTruthAt MB τ u chiB := by
  rw [chiB, PlusTruth.snce_iff]
  rintro ⟨s, hs, hna, -⟩
  obtain ⟨s', rfl⟩ : ∃ s' : ℤ, s' = s := ⟨s, rfl⟩
  have hs' : s' < u := hs
  rw [natom_iff_idle τ hτ, hobj, pendC_wB_iff] at hna
  omega

/-- **THE BACKWARD SPANNING-BLOCK CONDITION IS REFUTED** at the periodicity fixpoint's own
outputs, on a path with a single idle position in the past. -/
theorem spanningBlockBwd_refuted :
    ¬ SpanningBlockBwd stepC pendC fwdC bwdC labC chiB TcB TnB PB BB := by
  intro h
  obtain ⟨g, hg, hobj, hcnt⟩ := exists_gB (TcB + 2) (by omega)
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC g hg
  have hp0 : pendC (objAt g 0) = false := by rw [hobj, pendC_wB_iff]; exact Or.inl rfl
  have hc2 : TcB ≤ cntAt g 2 := by
    rw [hcnt]; simp only [cB]
    rw [if_neg (by omega), if_neg (by omega), if_pos (by omega)]
    omega
  obtain ⟨u, l, s, hl, hus, hsl, hlz, hs0, hs1, -, hty⟩ :=
    h paramsOkB no_stab_in_closure_chiB g hg 2 0 (by norm_num) hp0 hc2 τ hτ
  -- the only region start in the past of `2` is at `1`
  have hs : s = 0 := by
    rw [hobj, pendC_wB_iff] at hs0
    rw [hobj, pendC_wB_true_iff] at hs1
    omega
  subst hs
  have hul : u + (l : ℤ) = 2 := by omega
  -- the types at `u ≤ 0` and at `2` differ on `chiB`
  have hmem : chiB ∈ tpOf MB chiB τ (u + (l : ℤ)) := by
    rw [hul, mem_tpOf_iff]
    exact ⟨self_mem_plusSubformulaClosure chiB, chiB_true_two (TcB + 2) (by omega) hobj τ hτ⟩
  rw [← hty, mem_tpOf_iff] at hmem
  exact chiB_false_of_le_zero (TcB + 2) hobj τ hτ u (by omega) hmem.2

/-! ### The forward witness: Probe761C's own path, pending on `(-∞, c₀]` and idle forever after -/

def wC (c₀ : ℕ) : ℤ → Qc := fun v => if v ≤ (c₀ : ℤ) then 0 else 1

def cC (c₀ : ℕ) : ℤ → ℕ := fun v => ((c₀ : ℤ) - v).toNat

theorem pendC_wC_of_le (c₀ : ℕ) (v : ℤ) (h : v ≤ (c₀ : ℤ)) : pendC (wC c₀ v) = true := by
  simp [wC, pendC, h]

theorem pendC_wC_of_gt (c₀ : ℕ) (v : ℤ) (h : ¬ (v ≤ (c₀ : ℤ))) : pendC (wC c₀ v) = false := by
  simp [wC, pendC, h]

theorem admC (c₀ : ℕ) (v : ℤ) : pendC (wC c₀ v) = false → cC c₀ v = 0 := by
  intro h
  by_cases hv : v ≤ (c₀ : ℤ)
  · exact absurd ((pendC_wC_of_le c₀ v hv).symm.trans h) (by simp)
  · simp only [cC]; omega

def gC (c₀ n₀ : ℕ) : ℤ → LadderState Qc pendC :=
  fun v => ⟨(wC c₀ v, cC c₀ v, n₀), admC c₀ v⟩

theorem gC_isPath (c₀ n₀ : ℕ) : IsLadderPath stepC pendC (gC c₀ n₀) := by
  intro u
  refine ⟨rfl, admC c₀ u, Or.inl rfl, ?_⟩
  by_cases h1 : u + 1 ≤ (c₀ : ℤ)
  · have h0 : u ≤ (c₀ : ℤ) := by omega
    rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl, show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
    simp only [Count, pendC_wC_of_le c₀ u h0, pendC_wC_of_le c₀ (u + 1) h1, if_true]
    show cC c₀ (u + 1) + 1 = cC c₀ u
    simp only [cC]; omega
  · by_cases h0 : u ≤ (c₀ : ℤ)
    · rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
        show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
      simp only [Count, pendC_wC_of_le c₀ u h0, pendC_wC_of_gt c₀ (u + 1) h1]
      refine ⟨?_, ?_⟩
      · show cC c₀ (u + 1) = 0
        simp only [cC]; omega
      · intro _
        show cC c₀ u = 0
        simp only [cC]; omega
    · rw [show (gC c₀ n₀ u).1.1 = wC c₀ u from rfl,
        show (gC c₀ n₀ (u + 1)).1.1 = wC c₀ (u + 1) from rfl]
      simp only [Count, pendC_wC_of_gt c₀ u h0, pendC_wC_of_gt c₀ (u + 1) h1]
      refine ⟨?_, ?_⟩
      · show cC c₀ (u + 1) = 0
        simp only [cC]; omega
      · intro h
        exact absurd h (by simp)

/-- **THE FORWARD SPANNING-BLOCK CONDITION IS REFUTED** at the periodicity fixpoint's own
outputs, on a path with no region start above `z` at all. -/
theorem spanningBlockFwd_refuted :
    ¬ SpanningBlockFwd stepC pendC fwdC bwdC labC chiB TcB TnB PB BB := by
  intro h
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwdC bwdC (gC TcB 0) (gC_isPath TcB 0)
  have hz : pendC (objAt (gC TcB 0) 0) = true := pendC_wC_of_le TcB 0 (by omega)
  have hc : TcB ≤ cntAt (gC TcB 0) 0 := by
    show TcB ≤ cC TcB 0
    simp only [cC]; omega
  obtain ⟨u, l, s, -, -, -, -, hs0, hs1, -, -⟩ :=
    h paramsOkB no_stab_in_closure_chiB (gC TcB 0) (gC_isPath TcB 0) 0 hz hc τ hτ
  -- an idle position followed by a pending one does not exist on `gC`
  have h0 : ¬ (s ≤ (TcB : ℤ)) := by
    intro hle
    exact Bool.false_ne_true (hs0.symm.trans (pendC_wC_of_le TcB s hle))
  have h1 : s + 1 ≤ (TcB : ℤ) := by
    by_contra hgt
    exact absurd (hs1.symm.trans (pendC_wC_of_gt TcB (s + 1) hgt)) (by decide)
  omega

end Probe836B

#print axioms Probe836B.tightChain_isLadderPath
#print axioms Probe836B.tightChain_pin
#print axioms Probe836B.tightChain_slack_zero
#print axioms Probe836B.tightChain_pins
#print axioms Probe836B.spanningBlockBwd_refuted
#print axioms Probe836B.spanningBlockFwd_refuted
