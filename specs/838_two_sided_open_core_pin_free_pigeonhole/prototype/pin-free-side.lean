/-
THE PIN-FREE SIDE OF BOTH REFUTING OBJECTS, and the pin count of the tight doubling chain.

Prototype, compiled standalone with `lake env lean` through the build guard; NOT a wired probe.

The spanning-block device is refuted in both directions by two compiled objects, and this file
records what those two refutations do NOT settle: each refuting object carries a PIN-FREE SIDE on
which the next-deadline register is rebuildable without any spanning block at all, so neither
refutation touches the depth-`0` cell obligation at those objects.

* `gB_pinFree_below`: on the backward witness `gB` — pending forever into the past, idle at `0`,
  a region on `[1, L]`, idle from `L + 1` on — no pin lies at or below `-1`, so the landed
  dichotomy `pend_past_or_idle_of_no_pin_below` puts the past below the single idle position in
  the uniformly pending regime: the hypothesis the upward cell inclusion already consumes.
* `gC_pinFree_above`: on the forward witness `gC` — Probe761C's own path, pending on `(-∞, c₀]`
  and idle forever after — no pin lies anywhere at all, so in particular none lies above any `z`.
  That is the very fact the forward refutation consumes, read here as a statement about the
  object rather than as a step inside a refutation.
* `tightChain_pin_count_ge`: the QUANTITATIVE half. On the tight doubling chain, a pending
  position whose countdown is at least `2 ^ k` has at least `k` pins strictly below it, enumerated
  strictly monotonically at the positions `2 ^ (i + 1) - 2` — exactly the data the pigeonhole over
  region starts consumes. The route is the landed backward window plus the chain's own tightness:
  the register equals the position at every pin (`tightChain_pin`, which reads `pin_eq` and
  `cT_pin_succ`), the register is `1`-Lipschitz from the pin at `0`, so the countdown at a pending
  `z` is at most `z + 1`, and the exponential hypothesis then puts `2 ^ k - 1` below `z`.

**What this does and does not say.** It says the two refuting objects are refuting objects for the
spanning-block DEVICE and not for the obligation, and it says the chain's pin count grows with the
exponent of its countdowns. It does NOT say that the obligation holds at those objects, it does
NOT claim the pin count is derivable from the parameter conditions at a general path, and it
revives nothing: the pigeonhole it feeds has the pin count as a HYPOTHESIS.

The two objects are RE-DECLARED below rather than imported: the sibling prototype is a standalone
file under `specs/**`, not a module on the Lake library path, so there is no module name to
import. Every declaration between the markers below is a verbatim re-declaration of that file's.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderPin

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe838A

/-! ## Re-declared from the sibling prototype: the object, the chain, and the two witnesses -/

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


/-! ## The pin-free side of the backward witness -/

/-- **`gB` HAS A PIN-FREE SIDE BELOW ITS ONLY IDLE POSITION.** No pin lies at or below `-1` on the
backward witness: every position at or below `-1` is pending, so the idle half of a pin is never
available there. -/
theorem gB_noPin_below (L : ℕ) : ∀ s : ℤ, s + 1 ≤ -1 → pendC (wB L s) = false →
    pendC (wB L (s + 1)) = true → False := by
  intro s hs h0 _
  rw [pendC_wB_iff] at h0
  omega

/-- **THE PIN-FREE SIDE, read through the landed dichotomy.** On `gB` the past at or below `-1`
is uniformly pending from some position down — the regime-A hypothesis — because the
uniformly-idle side of `pend_past_or_idle_of_no_pin_below` is refuted at `-1` itself, where `gB`
is pending. The register below the single idle position at `0` is therefore free of every pin, and
the upward cell inclusion `cellAt_subset_of_shift_of_pend_past` applies at this object with no
spanning block anywhere in sight. -/
theorem gB_pinFree_below (L : ℕ) (hL : 1 ≤ L) {g : ℤ → LadderState Qc pendC}
    (hobj : ∀ v, objAt g v = wB L v) :
    ∃ v : ℤ, v ≤ -1 ∧ ∀ w : ℤ, w ≤ v → pendC (objAt g w) = true := by
  have hnp : ∀ s : ℤ, s + 1 ≤ -1 → pendC (objAt g s) = false →
      pendC (objAt g (s + 1)) = true → False := by
    intro s hs h0 h1
    rw [hobj] at h0 h1
    exact gB_noPin_below L s hs h0 h1
  rcases pend_past_or_idle_of_no_pin_below g (-1) hnp with hall | hex
  · exfalso
    have h1 : pendC (objAt g (-1)) = true := by
      rw [hobj, pendC_wB_true_iff]; omega
    exact Bool.false_ne_true ((hall (-1) le_rfl).symm.trans h1)
  · exact hex

/-! ## The pin-free side of the forward witness -/

/-- **`gC` HAS NO PIN AT ALL**, so in particular none above any `z`: it is pending on `(-∞, c₀]`
and idle forever after, and the single transition at `c₀` runs pending-to-idle, which is the
mirror image of a pin. This is the fact the forward refutation of the spanning-block device
consumes; above `z`'s region the register is free of every pin, so there too the register is
rebuildable with no spanning block. -/
theorem gC_pinFree_above (c₀ n₀ : ℕ) (z : ℤ) : ∀ s : ℤ, z ≤ s →
    pendC (objAt (gC c₀ n₀) s) = false → pendC (objAt (gC c₀ n₀) (s + 1)) = true → False := by
  intro s _ h0 h1
  have e0 : objAt (gC c₀ n₀) s = wC c₀ s := rfl
  have e1 : objAt (gC c₀ n₀) (s + 1) = wC c₀ (s + 1) := rfl
  rw [e0] at h0
  rw [e1] at h1
  have hs : ¬ (s ≤ (c₀ : ℤ)) := by
    intro hle
    exact Bool.false_ne_true (h0.symm.trans (pendC_wC_of_le c₀ s hle))
  exact Bool.false_ne_true ((pendC_wC_of_gt c₀ (s + 1) (by omega)).symm.trans h1)

/-! ## The pin count of the tight doubling chain -/

/-- **THE QUANTITATIVE HALF OF THE PIN-FREE ROUTE.** On the tight doubling chain, a pending
position whose countdown is at least `2 ^ k` carries at least `k` pins strictly below it, and they
are enumerated strictly monotonically at the positions `2 ^ (i + 1) - 2`. This is the shape the
pigeonhole over region starts consumes: a strictly monotone enumeration of pins, all of them below
the position in question.

The route is the chain's own tightness. The register equals the position at every pin
(`tightChain_pin`, through `pin_eq` and `cT_pin_succ`), so it is `0` at the pin `2 ^ 1 - 2 = 0`;
it is `1`-Lipschitz, so it is at most `z` at any `z ≥ 0`; and the landed backward window
`cntAt_le_nxtAt_succ_of_idle_past`, available because every position at or below `0` is idle, then
bounds the countdown at `z` by `z + 1`. The exponential hypothesis puts `2 ^ k - 1` at or below
`z`, which is exactly enough room for the `k` pins below it. -/
theorem tightChain_pin_count_ge (J k : ℕ) (hk : 1 ≤ k) (hkJ : k ≤ J)
    (g : ℤ → LadderState Qc pendC) (hg : IsLadderPath stepC pendC g)
    (hobj : ∀ v, objAt g v = wT J v) (hcnt : ∀ v, cntAt g v = cT J v)
    (z : ℤ) (hz : pendC (objAt g z) = true) (hzc : (2 : ℤ) ^ k ≤ (cntAt g z : ℤ)) :
    ∃ s : ℕ → ℤ, StrictMono s ∧
      (∀ i : ℕ, i < k → pendC (objAt g (s i)) = false ∧
        pendC (objAt g (s i + 1)) = true) ∧
      (∀ i : ℕ, i < k → s i < z) := by
  have hJ1 : 1 ≤ J := le_trans hk hkJ
  -- the pin at `0`, which is `2 ^ 1 - 2`
  have hpin0 := tightChain_pins J 1 le_rfl hJ1
  rw [show (2 : ℤ) ^ 1 - 2 = 0 by norm_num] at hpin0
  have h00 : pendC (objAt g 0) = false := by rw [hobj]; exact hpin0.1
  have h01 : pendC (objAt g (0 + 1)) = true := by
    rw [hobj, show (0 : ℤ) + 1 = 0 + 1 from rfl]; exact hpin0.2
  -- the register is `0` at that pin and `1`-Lipschitz, so at most `z` at any `z ≥ 0`
  have hn0 : (nxtAt g 0 : ℤ) = 0 := tightChain_pin J g hg hobj hcnt 0 h00 h01
  have hz0 : 0 ≤ z := by
    by_contra hneg
    rw [hobj, pendC_wT_true_iff] at hz
    exact hz (Or.inl (by omega))
  have hlip := nxtAt_lipschitz_two_sided g hg z 0
  have hnz : (nxtAt g z : ℤ) ≤ z := by
    rw [hn0] at hlip; omega
  -- the backward window at `z`, with the idle position `0` in its past
  have hwin := cntAt_le_nxtAt_succ_of_idle_past g hg z 0 hz hz0 h00
  have hzb : (2 : ℤ) ^ k ≤ z + 1 := by omega
  refine ⟨fun i => (2 : ℤ) ^ (i + 1) - 2, ?_, ?_, ?_⟩
  · intro a b hab
    show (2 : ℤ) ^ (a + 1) - 2 < (2 : ℤ) ^ (b + 1) - 2
    have hsm := two_pow_strict_mono (show a + 1 < b + 1 by omega)
    omega
  · intro i hi
    have hp := tightChain_pins J (i + 1) (by omega) (by omega)
    exact ⟨by rw [hobj]; exact hp.1, by rw [hobj]; exact hp.2⟩
  · intro i hi
    show (2 : ℤ) ^ (i + 1) - 2 < z
    have hle : (2 : ℤ) ^ (i + 1) ≤ (2 : ℤ) ^ k := two_pow_mono (by omega)
    omega

end Probe838A

#print axioms Probe838A.gB_pinFree_below
#print axioms Probe838A.gC_pinFree_above
#print axioms Probe838A.tightChain_pin_count_ge
