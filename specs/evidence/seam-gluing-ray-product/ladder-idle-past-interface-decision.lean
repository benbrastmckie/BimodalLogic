/-
# THE IDLE-PAST INTERFACE DECISION PROBE, ON THE COMPILED TIGHT CHAIN

A DECISION GATE, not a deliverable. The cascade's interface-level existential —
`exists_ladderPath_at_region_of_idle_past`, the idle-past half of
`exists_ladderPath_at_region` — is unlanded in `LadderAgree.lean` and unclaimed. The
pending-forever half (`exists_ladderPath_at_region_of_pend_past`) is landed and cheap. This probe
asks the one question that can be settled without building the general construction: **is the
restated existential REFUTED on the one compiled object that refutes the `spliceObj`-shaped
conclusion?**

That object is the tight doubling chain of `ladder-tight-chain-nonliftability.lean`: `Fin 2` with
state `0` pending and state `1` idle, `step` total, idle at every `v ≤ 0` and exactly at the pins
`2 ^ j - 2` for `j ≥ 1`, pins UNBOUNDED ABOVE. Its register equals the POSITION at every pin, so
every gap between consecutive pins has Lipschitz slack exactly `0` and there is no slack anywhere
to absorb a surgery. The chain's objects are RE-DERIVED here rather than imported: a probe is
compiled with `lake env lean` and sits outside the Lake module graph, so no probe can import
another, and `ladder-tight-chain-nonliftability.lean` is NOT edited or re-signed by this file.

## The instance

Fixed, explicit, and non-vacuous — every clause below is a compiled fact of this file, not a
hypothesis of it:

```
region start (a pin of the chain)  s = 2 = 2 ^ 2 - 2        (pin_eq's own form)
splice point   a = 3    (the region `s` opens is the pending run 3, 4, 5)
comparison pos v = 3    (`v ≤ a` and `a ≤ v + cntAt tightChain v = 3 + 2`)
cycle length   l = 1    (`0 < l` and `l ≤ cntAt tightChain a = 2`)
idle witness   p = 2    (`p ≤ a` and `pendC (objAt tightChain p) = false`)
```

`hrep : objAt tightChain a = objAt tightChain (a + l)` holds at this `l` because no idle position
lies strictly inside a region (`no_idle_between`), so both `3` and `4` carry the pending state.
The regime is therefore POPULATED on this object, and in the strongest possible sense: the chain is
idle at every `v ≤ 0`, so NO position of it has a pending-forever past at all and the
pending-forever half `exists_ladderPath_at_region_of_pend_past` is VACUOUS here. The idle-past half
is the only half this object exercises.

## The verdict: WITNESSED

`idle_past_interface_witnessed` exhibits a ladder path `gW` over `(stepC, pendC)` with

```
objAt gW 3 = objAt tightChain 3   and   cntAt gW 3 = cntAt tightChain 3 + 1.
```

So the restated interface-level existential is **NOT refuted** on the object that refutes the
`spliceObj` shape. `exists_ladderPath_at_region_of_idle_past` survives its sharpest available
test.

The witness is the CASCADE walk, and its shape is the finding this probe hands forward. It is not
the splice: `spliceObj tightChain 3 1` keeps the chain's past below the splice point fixed, and
that walk's pins are incompatible — its region start `2` would carry countdown `3` while the pin
at `0` below it still carries `0`, and `|3 - 0| = 3 > |2 - 0| = 2` violates the pairwise condition
`pinCompat_of_ladderPath` proves NECESSARY for any ladder path whatsoever. The witness repairs
exactly that, by the two moves the cascade names:

* **lengthen the region** `3, 4, 5` to `3, 4, 5, 6` and displace everything above it up by `l = 1`
  (`idle` at `7, 15, 31, …` in place of `6, 14, 30, …`), which is what raises the countdown at the
  comparison position by `l`; and
* **insert `l = 1` copy of the idle object into the idle run at the witness** `p = 2`, pushing the
  past strictly below it down by `1` (`idle` at `1, 2`; `pending` at `0`; `idle` at every
  `x ≤ -1`), which moves every pin BELOW the comparison position down by `1` and restores pin
  compatibility.

The resulting walk `wW` is idle exactly at `x ≤ -1`, at `1`, at `2`, and at `2 ^ j - 1` for
`j ≥ 3`. Its pins are `-1`, `2` and `2 ^ j - 1` (`j ≥ 3`), carrying region-start countdowns `s + 1`
at the two low pins and `s - 1` at every high one, which is pairwise compatible (`hpinsW`) and
compatible with the base register `n₀ = 1` (`hn0W`). `exists_ladderPath_of_walk` then lifts it,
with `hw` discharged by `rfl` because `stepC` is total.

## NON-GENERALITY. What this probe does NOT establish.

**This probe decides REFUTABILITY and never PROVABILITY.** The carrier is `Qc := Fin 2` with
`stepC : Qc → Qc → Bool := fun _ _ => true`, which is totally permissive: a witness here pays
NONE of the self-loop cost the general statement pays, because the general statement's object
relation may forbid the repeated-state transitions an insertion walk needs, and
`exists_ladderPath_of_walk`'s `hw` hypothesis is then a real obligation rather than `rfl`. A
positive answer on this object is consequently NOT a proof of
`exists_ladderPath_at_region_of_idle_past`, and nothing here is a step toward one. The one thing
it is: the witness's index map is a worked example of the insertion walk, and the pin arithmetic
`hpinsW`/`hn0W` is the worked example of the cascade's side condition.

Nothing under the names `exists_ladderPath_at_region_of_idle_past`,
`exists_ladderPath_at_region` or `exists_spliced_ladderPath_of_idle_past` is landed by this file,
in the library or here.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

set_option autoImplicit false

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761IdlePast

/-! ### The object -/

abbrev Qc : Type := Fin 2

def pendC : Qc → Bool := fun q => decide (q = 0)

def stepC : Qc → Qc → Bool := fun _ _ => true

theorem pendC_zero : pendC 0 = true := by decide

theorem pendC_one : pendC 1 = false := by decide

theorem admZeroC (d n : ℕ) : ((0 : Qc), d, n).2.1 ∈ Adm pendC ((0 : Qc), d, n).1 :=
  fun h => absurd (pendC_zero.symm.trans h) (by simp)

/-! ### The tight doubling chain, with its pins unbounded above -/

open Classical

theorem two_pow_mono {m n : ℕ} (h : m ≤ n) : (2 : ℤ) ^ m ≤ (2 : ℤ) ^ n :=
  pow_le_pow_right₀ (by norm_num) h

theorem two_pow_lt_iff {m n : ℕ} : (2 : ℤ) ^ m < (2 : ℤ) ^ n ↔ m < n :=
  pow_lt_pow_iff_right₀ (by norm_num)

theorem two_le_two_pow {j : ℕ} (hj : 1 ≤ j) : (2 : ℤ) ≤ (2 : ℤ) ^ j := by
  calc (2 : ℤ) = (2 : ℤ) ^ 1 := by norm_num
    _ ≤ (2 : ℤ) ^ j := two_pow_mono hj

/-- The idle positions of the chain: everything at or before `0`, and the pins `2^j - 2` for
every `j ≥ 1`. The pin set is UNBOUNDED ABOVE; there is no idle-forever tail. -/
def idleT (v : ℤ) : Prop :=
  v ≤ 0 ∨ ∃ j : ℕ, 1 ≤ j ∧ v = (2 : ℤ) ^ j - 2

noncomputable def wT (v : ℤ) : Qc := if idleT v then 1 else 0

theorem pendC_wT_iff (v : ℤ) : pendC (wT v) = false ↔ idleT v := by
  unfold wT
  split_ifs with h <;> simp [pendC, h]

theorem pendC_wT_true_iff (v : ℤ) : pendC (wT v) = true ↔ ¬ idleT v := by
  rw [← Bool.not_eq_false, pendC_wT_iff]

/-- Some power of two overshoots any integer. -/
theorem exists_pow_gt (v : ℤ) : ∃ j : ℕ, 1 ≤ j ∧ v < (2 : ℤ) ^ j - 2 := by
  refine ⟨(v + 3).toNat + 1, by omega, ?_⟩
  have h : ((v + 3).toNat : ℤ) < (2 : ℤ) ^ ((v + 3).toNat) := by
    exact_mod_cast Nat.lt_two_pow_self (n := (v + 3).toNat)
  have h2 : (2 : ℤ) ^ ((v + 3).toNat) ≤ (2 : ℤ) ^ ((v + 3).toNat + 1) :=
    two_pow_mono (by omega)
  have h3 : (2 : ℤ) ^ ((v + 3).toNat + 1) = 2 * (2 : ℤ) ^ ((v + 3).toNat) := by
    rw [pow_succ]; ring
  omega

/-- There is an idle position after every position. -/
theorem exists_idle_after (v : ℤ) : ∃ k : ℕ, idleT (v + (k : ℤ) + 1) := by
  obtain ⟨j, hj1, hj⟩ := exists_pow_gt v
  refine ⟨((2 : ℤ) ^ j - 2 - v - 1).toNat, Or.inr ⟨j, hj1, ?_⟩⟩
  omega

/-- The countdown of the chain: `0` at an idle position, the distance to the next idle position
minus one at a pending one. -/
noncomputable def cT (v : ℤ) : ℕ :=
  if idleT v then 0 else Nat.find (exists_idle_after v)

theorem cT_of_idle (v : ℤ) (h : idleT v) : cT v = 0 := by
  unfold cT; rw [if_pos h]

theorem cT_of_pend (v : ℤ) (h : ¬ idleT v) : cT v = Nat.find (exists_idle_after v) := by
  unfold cT; rw [if_neg h]

/-- A pin — an idle position followed by a pending one — is one of the `2^j - 2`. -/
theorem pin_eq (v : ℤ) (h0 : idleT v) (h1 : ¬ idleT (v + 1)) :
    ∃ j : ℕ, 1 ≤ j ∧ v = (2 : ℤ) ^ j - 2 := by
  rcases h0 with h | h
  · have hv : v = 0 := by
      by_contra hne
      exact h1 (Or.inl (by omega))
    exact ⟨1, le_rfl, by omega⟩
  · exact h

/-- No idle position lies strictly between two consecutive pins. -/
theorem no_idle_between (j : ℕ) (hj1 : 1 ≤ j) (v : ℤ)
    (hlo : (2 : ℤ) ^ j - 2 < v) (hhi : v < (2 : ℤ) ^ (j + 1) - 2) : ¬ idleT v := by
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj1
  rintro (h | ⟨i, hi1, rfl⟩)
  · omega
  · have hlt1 : (2 : ℤ) ^ j < (2 : ℤ) ^ i := by omega
    have hlt2 : (2 : ℤ) ^ i < (2 : ℤ) ^ (j + 1) := by omega
    have := two_pow_lt_iff.mp hlt1
    have := two_pow_lt_iff.mp hlt2
    omega

/-- The position `2^(j+1) - 2` after a pin is idle. -/
theorem idle_next_pin (j : ℕ) (hj1 : 1 ≤ j) : idleT ((2 : ℤ) ^ (j + 1) - 2) :=
  Or.inr ⟨j + 1, by omega, rfl⟩

/-- **THE COUNTDOWN AT A REGION START IS THE PIN'S OWN POSITION.** -/
theorem cT_pin_succ (j : ℕ) (hj1 : 1 ≤ j) :
    cT ((2 : ℤ) ^ j - 2 + 1) = ((2 : ℤ) ^ j - 2).toNat := by
  have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj1
  have hpend : ¬ idleT ((2 : ℤ) ^ j - 2 + 1) :=
    no_idle_between j hj1 _ (by omega) (by rw [pow_succ]; omega)
  rw [cT_of_pend _ hpend, Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · have hcast : (2 : ℤ) ^ j - 2 + 1 + ((((2 : ℤ) ^ j - 2).toNat : ℕ) : ℤ) + 1
        = (2 : ℤ) ^ (j + 1) - 2 := by
      rw [pow_succ]; omega
    rw [hcast]
    exact idle_next_pin j hj1
  · intro n hn
    apply no_idle_between j hj1
    · omega
    · rw [pow_succ]; omega

/-- Inside a region the countdown counts down. -/
theorem cT_pend_pend (v : ℤ) (h0 : ¬ idleT v) (h1 : ¬ idleT (v + 1)) :
    cT (v + 1) + 1 = cT v := by
  rw [cT_of_pend v h0, cT_of_pend (v + 1) h1]
  symm
  rw [Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · have hspec := Nat.find_spec (exists_idle_after (v + 1))
    rw [show v + ((Nat.find (exists_idle_after (v + 1)) + 1 : ℕ) : ℤ) + 1
        = v + 1 + ((Nat.find (exists_idle_after (v + 1)) : ℕ) : ℤ) + 1 by push_cast; ring]
    exact hspec
  · intro n hn
    cases n with
    | zero => simpa using h1
    | succ m =>
        have hm : m < Nat.find (exists_idle_after (v + 1)) := by omega
        have hmin := Nat.find_min (exists_idle_after (v + 1)) hm
        rwa [show v + ((m + 1 : ℕ) : ℤ) + 1 = v + 1 + (m : ℤ) + 1 by push_cast; ring]

/-- At a region's last pending position the countdown is `0`. -/
theorem cT_pend_idle (v : ℤ) (h0 : ¬ idleT v) (h1 : idleT (v + 1)) : cT v = 0 := by
  rw [cT_of_pend v h0, Nat.find_eq_zero]
  simpa using h1

/-- **THE TIGHT DOUBLING CHAIN IS A LADDER PATH**, through the landed lift of a walk with its
forced countdown, with the register's base value `0`. -/
theorem tightChain_exists :
    ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
      (∀ v, objAt g v = wT v) ∧ (∀ v, cntAt g v = cT v) := by
  have hpin : ∀ s : ℤ, pendC (wT s) = false → pendC (wT (s + 1)) = true →
      (cT (s + 1) : ℤ) = s := by
    intro s h0 h1
    rw [pendC_wT_iff] at h0
    rw [pendC_wT_true_iff] at h1
    obtain ⟨j, hj1, rfl⟩ := pin_eq s h0 h1
    rw [cT_pin_succ j hj1]
    have h2j : (2 : ℤ) ≤ (2 : ℤ) ^ j := two_le_two_pow hj1
    omega
  refine exists_ladderPath_of_walk wT cT 0 (fun _ => rfl) ?_ ?_ ?_ ?_ ?_
  · intro v h
    exact cT_of_idle v ((pendC_wT_iff v).mp h)
  · intro v h0 h1
    exact cT_pend_pend v ((pendC_wT_true_iff v).mp h0) ((pendC_wT_true_iff (v + 1)).mp h1)
  · intro v h0 h1
    exact cT_pend_idle v ((pendC_wT_true_iff v).mp h0) ((pendC_wT_iff (v + 1)).mp h1)
  · intro s v hs0 hs1 hv0 hv1
    rw [hpin s hs0 hs1, hpin v hv0 hv1]
  · intro v h0 h1
    rw [hpin v h0 h1]
    simp

/-- The chain itself, as a function. -/
noncomputable def tightChain : ℤ → LadderState Qc pendC := tightChain_exists.choose

theorem tightChain_isLadderPath : IsLadderPath stepC pendC tightChain :=
  tightChain_exists.choose_spec.1

theorem tightChain_objAt (v : ℤ) : objAt tightChain v = wT v :=
  tightChain_exists.choose_spec.2.1 v

theorem tightChain_cntAt (v : ℤ) : cntAt tightChain v = cT v :=
  tightChain_exists.choose_spec.2.2 v


/-! ### The chain at the instance: `s = 2`, `a = 3`, `v = 3`, `l = 1`, `p = 2`

Everything the instance asserts about the chain, compiled. Nothing here is a hypothesis.
-/

/-- A power of two with `1 ≤ j` is `2`, `4`, or at least `8`. The arithmetic that rules out the
small non-powers `5`, `6` and `7`. -/
theorem pow_two_cases (j : ℕ) (hj : 1 ≤ j) :
    (2 : ℤ) ^ j = 2 ∨ (2 : ℤ) ^ j = 4 ∨ 8 ≤ (2 : ℤ) ^ j := by
  rcases Nat.lt_or_ge j 3 with h | h
  · interval_cases j
    · exact Or.inl (by norm_num)
    · exact Or.inr (Or.inl (by norm_num))
  · refine Or.inr (Or.inr ?_)
    calc (8 : ℤ) = (2 : ℤ) ^ 3 := by norm_num
      _ ≤ (2 : ℤ) ^ j := two_pow_mono h

/-- `2` is a pin of the chain: `2 = 2 ^ 2 - 2`. -/
theorem idleT_two : idleT 2 := Or.inr ⟨2, by omega, by norm_num⟩

/-- `6` is the next pin: `6 = 2 ^ 3 - 2`. -/
theorem idleT_six : idleT 6 := Or.inr ⟨3, by omega, by norm_num⟩

/-- The region the pin `2` opens is the pending run `3, 4, 5`. -/
theorem not_idleT_mid (v : ℤ) (hlo : 3 ≤ v) (hhi : v ≤ 5) : ¬ idleT v := by
  rintro (h | ⟨j, hj1, rfl⟩)
  · omega
  · rcases pow_two_cases j hj1 with h | h | h <;> omega

theorem not_idleT_three : ¬ idleT 3 := not_idleT_mid 3 (by norm_num) (by norm_num)

/-- **THE CHAIN'S COUNTDOWN AT THE COMPARISON POSITION.** `cntAt tightChain 3 = 2`. -/
theorem cT_three : cT 3 = 2 := by
  rw [cT_of_pend 3 not_idleT_three, Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · show idleT (3 + ((2 : ℕ) : ℤ) + 1)
    rw [show (3 : ℤ) + ((2 : ℕ) : ℤ) + 1 = 6 by norm_num]
    exact idleT_six
  · intro n hn
    interval_cases n
    · show ¬ idleT (3 + ((0 : ℕ) : ℤ) + 1)
      rw [show (3 : ℤ) + ((0 : ℕ) : ℤ) + 1 = 4 by norm_num]
      exact not_idleT_mid 4 (by norm_num) (by norm_num)
    · show ¬ idleT (3 + ((1 : ℕ) : ℤ) + 1)
      rw [show (3 : ℤ) + ((1 : ℕ) : ℤ) + 1 = 5 by norm_num]
      exact not_idleT_mid 5 (by norm_num) (by norm_num)

/-- **THE INSTANCE IS IN THE REGIME, CLAUSE BY CLAUSE.** Non-vacuity, compiled: the splice point
lies in the region the pin `2` opens, the comparison position sees it, the cycle length is
positive and fits inside the countdown, the repetition hypothesis holds at that length, and the
past carries an idle position at or below the splice point. -/
theorem instance_is_in_regime :
    -- the pin and its region
    idleT 2 ∧ ¬ idleT 3 ∧
    -- `0 < l` and `l ≤ cntAt tightChain a`
    (0 : ℕ) < 1 ∧ (1 : ℕ) ≤ cntAt tightChain 3 ∧
    -- `v ≤ a` and `a ≤ v + cntAt tightChain v`
    (3 : ℤ) ≤ 3 ∧ (3 : ℤ) ≤ 3 + (cntAt tightChain 3 : ℤ) ∧
    -- `hrep` at the chosen `l`
    objAt tightChain 3 = objAt tightChain (3 + ((1 : ℕ) : ℤ)) ∧
    -- the idle witness, at or below the splice point
    (2 : ℤ) ≤ 3 ∧ pendC (objAt tightChain 2) = false := by
  have hc : cntAt tightChain 3 = 2 := by rw [tightChain_cntAt]; exact cT_three
  refine ⟨idleT_two, not_idleT_three, by omega, by omega, le_rfl, by omega, ?_, by omega, ?_⟩
  · rw [tightChain_objAt, tightChain_objAt, show (3 : ℤ) + ((1 : ℕ) : ℤ) = 4 by norm_num]
    unfold wT
    rw [if_neg not_idleT_three, if_neg (not_idleT_mid 4 (by norm_num) (by norm_num))]
  · rw [tightChain_objAt, pendC_wT_iff]
    exact idleT_two


/-! ### The cascade walk

The witness. Two moves on the chain, both forced by the pin arithmetic:

* the region `3, 4, 5` the pin `2` opens is LENGTHENED to `3, 4, 5, 6`, and everything above it is
  displaced up by `l = 1` — the chain's idle positions `2 ^ j - 2` for `j ≥ 3` become `2 ^ j - 1`.
  This is what raises the countdown at the comparison position `3` from `2` to `3`;
* `l = 1` copy of the idle object is INSERTED into the idle run at the witness `p = 2`, and the
  past strictly below it is pushed down by `1` — the chain's pins `0` and `2` become `-1` and `2`
  (the chain's `2` stays idle and acquires an idle neighbour at `1`, and the chain's pin at `0`
  moves to `-1`). This moves every pin below the comparison position down by `1`, which is what
  restores pin compatibility against the raised region start.

So `wW` is idle exactly at `x ≤ -1`, at `1`, at `2`, and at `2 ^ j - 1` for `j ≥ 3`, and its pins
are `-1`, `2` and `2 ^ j - 1` (`j ≥ 3`).
-/

/-- The idle set of the cascade walk. -/
def idleW (x : ℤ) : Prop :=
  x ≤ -1 ∨ x = 1 ∨ x = 2 ∨ ∃ j : ℕ, 3 ≤ j ∧ x = (2 : ℤ) ^ j - 1

noncomputable def wW (x : ℤ) : Qc := if idleW x then 1 else 0

theorem pendC_wW_iff (v : ℤ) : pendC (wW v) = false ↔ idleW v := by
  unfold wW
  split_ifs with h <;> simp [pendC, h]

theorem pendC_wW_true_iff (v : ℤ) : pendC (wW v) = true ↔ ¬ idleW v := by
  rw [← Bool.not_eq_false, pendC_wW_iff]

theorem eight_le_pow (j : ℕ) (hj : 3 ≤ j) : (8 : ℤ) ≤ (2 : ℤ) ^ j := by
  calc (8 : ℤ) = (2 : ℤ) ^ 3 := by norm_num
    _ ≤ (2 : ℤ) ^ j := two_pow_mono hj

theorem idleW_one : idleW 1 := Or.inr (Or.inl rfl)

theorem idleW_two : idleW 2 := Or.inr (Or.inr (Or.inl rfl))

theorem idleW_pow (j : ℕ) (hj : 3 ≤ j) : idleW ((2 : ℤ) ^ j - 1) :=
  Or.inr (Or.inr (Or.inr ⟨j, hj, rfl⟩))

theorem idleW_seven : idleW 7 := by
  have h : (7 : ℤ) = (2 : ℤ) ^ 3 - 1 := by norm_num
  rw [h]; exact idleW_pow 3 le_rfl

theorem not_idleW_zero : ¬ idleW 0 := by
  rintro (h | h | h | ⟨j, hj, heq⟩)
  · omega
  · omega
  · omega
  · have := eight_le_pow j hj; omega

/-- The lengthened region: `3, 4, 5, 6` all pending. -/
theorem not_idleW_region (x : ℤ) (hlo : 3 ≤ x) (hhi : x ≤ 6) : ¬ idleW x := by
  rintro (h | h | h | ⟨j, hj, rfl⟩)
  · omega
  · omega
  · omega
  · have := eight_le_pow j hj; omega

/-- No idle position lies strictly between two consecutive high idle positions. -/
theorem not_idleW_between (j : ℕ) (hj : 3 ≤ j) (x : ℤ)
    (hlo : (2 : ℤ) ^ j - 1 < x) (hhi : x < (2 : ℤ) ^ (j + 1) - 1) : ¬ idleW x := by
  have h8 : (8 : ℤ) ≤ (2 : ℤ) ^ j := eight_le_pow j hj
  have hsucc : (2 : ℤ) ^ (j + 1) = 2 * (2 : ℤ) ^ j := by rw [pow_succ]; ring
  rintro (h | h | h | ⟨i, hi, rfl⟩)
  · omega
  · omega
  · omega
  · have h8i : (8 : ℤ) ≤ (2 : ℤ) ^ i := eight_le_pow i hi
    have hlt1 : (2 : ℤ) ^ j < (2 : ℤ) ^ i := by omega
    have hlt2 : (2 : ℤ) ^ i < (2 : ℤ) ^ (j + 1) := by omega
    have hji := two_pow_lt_iff.mp hlt1
    have hij := two_pow_lt_iff.mp hlt2
    omega

theorem exists_idleW_after (v : ℤ) : ∃ k : ℕ, idleW (v + (k : ℤ) + 1) := by
  obtain ⟨j, hj1, hj⟩ := exists_pow_gt v
  have hmono : (2 : ℤ) ^ j ≤ (2 : ℤ) ^ (j + 3) := two_pow_mono (by omega)
  refine ⟨((2 : ℤ) ^ (j + 3) - 1 - v - 1).toNat, ?_⟩
  have h : v + (((2 : ℤ) ^ (j + 3) - 1 - v - 1).toNat : ℤ) + 1 = (2 : ℤ) ^ (j + 3) - 1 := by
    omega
  rw [h]
  exact idleW_pow (j + 3) (by omega)

/-- The countdown of the cascade walk, forced by its idle set exactly as the chain's is. -/
noncomputable def cW (v : ℤ) : ℕ :=
  if idleW v then 0 else Nat.find (exists_idleW_after v)

theorem cW_of_idle (v : ℤ) (h : idleW v) : cW v = 0 := by
  unfold cW; rw [if_pos h]

theorem cW_of_pend (v : ℤ) (h : ¬ idleW v) : cW v = Nat.find (exists_idleW_after v) := by
  unfold cW; rw [if_neg h]

/-- Inside a region the countdown counts down. -/
theorem cW_pend_pend (v : ℤ) (h0 : ¬ idleW v) (h1 : ¬ idleW (v + 1)) :
    cW (v + 1) + 1 = cW v := by
  rw [cW_of_pend v h0, cW_of_pend (v + 1) h1]
  symm
  rw [Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · have hspec := Nat.find_spec (exists_idleW_after (v + 1))
    rw [show v + ((Nat.find (exists_idleW_after (v + 1)) + 1 : ℕ) : ℤ) + 1
        = v + 1 + ((Nat.find (exists_idleW_after (v + 1)) : ℕ) : ℤ) + 1 by push_cast; ring]
    exact hspec
  · intro n hn
    cases n with
    | zero => simpa using h1
    | succ m =>
        have hm : m < Nat.find (exists_idleW_after (v + 1)) := by omega
        have hmin := Nat.find_min (exists_idleW_after (v + 1)) hm
        rwa [show v + ((m + 1 : ℕ) : ℤ) + 1 = v + 1 + (m : ℤ) + 1 by push_cast; ring]

/-- At a region's last pending position the countdown is `0`. -/
theorem cW_pend_idle (v : ℤ) (h0 : ¬ idleW v) (h1 : idleW (v + 1)) : cW v = 0 := by
  rw [cW_of_pend v h0, Nat.find_eq_zero]
  simpa using h1

/-! #### The pins of the cascade walk, and their region-start countdowns -/

/-- The pins are `-1`, `2`, and `2 ^ j - 1` for `j ≥ 3`. -/
theorem pinW_eq (s : ℤ) (h0 : idleW s) (h1 : ¬ idleW (s + 1)) :
    s = -1 ∨ s = 2 ∨ ∃ j : ℕ, 3 ≤ j ∧ s = (2 : ℤ) ^ j - 1 := by
  rcases h0 with h | h | h | ⟨j, hj, hs⟩
  · refine Or.inl ?_
    by_contra hne
    exact h1 (Or.inl (by omega))
  · exact absurd (Or.inr (Or.inr (Or.inl (by omega)))) h1
  · exact Or.inr (Or.inl h)
  · exact Or.inr (Or.inr ⟨j, hj, hs⟩)

/-- The region start the lowest pin opens: countdown `0`, the single pending position `0`. -/
theorem cW_zero : cW 0 = 0 := by
  rw [cW_of_pend 0 not_idleW_zero, Nat.find_eq_zero]
  show idleW (0 + ((0 : ℕ) : ℤ) + 1)
  rw [show (0 : ℤ) + ((0 : ℕ) : ℤ) + 1 = 1 by norm_num]
  exact idleW_one

/-- **THE RAISED REGION START.** The countdown at the comparison position is `3`, one more than
the chain's own `2` — which is the whole point of the surgery. -/
theorem cW_three : cW 3 = 3 := by
  rw [cW_of_pend 3 (not_idleW_region 3 (by norm_num) (by norm_num)), Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · show idleW (3 + ((3 : ℕ) : ℤ) + 1)
    rw [show (3 : ℤ) + ((3 : ℕ) : ℤ) + 1 = 7 by norm_num]
    exact idleW_seven
  · intro n hn
    interval_cases n
    · show ¬ idleW (3 + ((0 : ℕ) : ℤ) + 1)
      rw [show (3 : ℤ) + ((0 : ℕ) : ℤ) + 1 = 4 by norm_num]
      exact not_idleW_region 4 (by norm_num) (by norm_num)
    · show ¬ idleW (3 + ((1 : ℕ) : ℤ) + 1)
      rw [show (3 : ℤ) + ((1 : ℕ) : ℤ) + 1 = 5 by norm_num]
      exact not_idleW_region 5 (by norm_num) (by norm_num)
    · show ¬ idleW (3 + ((2 : ℕ) : ℤ) + 1)
      rw [show (3 : ℤ) + ((2 : ℕ) : ℤ) + 1 = 6 by norm_num]
      exact not_idleW_region 6 (by norm_num) (by norm_num)

/-- The high region starts: the countdown at `2 ^ j` is `2 ^ j - 2`, one LESS than the pin's own
position. -/
theorem cW_pow (j : ℕ) (hj : 3 ≤ j) : cW ((2 : ℤ) ^ j) = ((2 : ℤ) ^ j - 2).toNat := by
  have h8 : (8 : ℤ) ≤ (2 : ℤ) ^ j := eight_le_pow j hj
  have hsucc : (2 : ℤ) ^ (j + 1) = 2 * (2 : ℤ) ^ j := by rw [pow_succ]; ring
  have hpend : ¬ idleW ((2 : ℤ) ^ j) := not_idleW_between j hj _ (by omega) (by omega)
  rw [cW_of_pend _ hpend, Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · have harg : (2 : ℤ) ^ j + ((((2 : ℤ) ^ j - 2).toNat : ℕ) : ℤ) + 1 = (2 : ℤ) ^ (j + 1) - 1 := by
      omega
    rw [harg]
    exact idleW_pow (j + 1) (by omega)
  · intro n hn
    have hn' : (n : ℤ) < (2 : ℤ) ^ j - 2 := by omega
    exact not_idleW_between j hj _ (by omega) (by omega)

/-- **THE PIN ARITHMETIC OF THE CASCADE WALK.** At the two low pins the region-start countdown is
the pin's own position plus one; at every high pin it is the pin's own position minus one. That
asymmetry is exactly what the insertion bought: the low pins moved down by `1` while their regions
kept their lengths, and the high pins moved up by `1` while theirs did too. -/
theorem cW_pin (s : ℤ) (h0 : idleW s) (h1 : ¬ idleW (s + 1)) :
    ((cW (s + 1) : ℤ) = s + 1 ∧ s ≤ 2) ∨ ((cW (s + 1) : ℤ) = s - 1 ∧ 7 ≤ s) := by
  rcases pinW_eq s h0 h1 with rfl | rfl | ⟨j, hj, rfl⟩
  · refine Or.inl ⟨?_, by norm_num⟩
    rw [show (-1 : ℤ) + 1 = 0 by norm_num, cW_zero]; norm_num
  · refine Or.inl ⟨?_, le_rfl⟩
    rw [show (2 : ℤ) + 1 = 3 by norm_num, cW_three]; norm_num
  · have h8 : (8 : ℤ) ≤ (2 : ℤ) ^ j := eight_le_pow j hj
    refine Or.inr ⟨?_, by omega⟩
    rw [show (2 : ℤ) ^ j - 1 + 1 = (2 : ℤ) ^ j by ring, cW_pow j hj]
    omega

/-- **PAIRWISE PIN COMPATIBILITY.** The side condition `pinCompat_of_ladderPath` proves NECESSARY
for any ladder path whatsoever, discharged for the cascade walk. This is the clause the plain
splice `spliceObj tightChain 3 1` FAILS: it raises the region start `2` to countdown `3` while
leaving the pin at `0` below it with countdown `0`, and `|3 - 0| = 3 > |2 - 0| = 2`. -/
theorem hpinsW (s v : ℤ) (hs0 : pendC (wW s) = false) (hs1 : pendC (wW (s + 1)) = true)
    (hv0 : pendC (wW v) = false) (hv1 : pendC (wW (v + 1)) = true) :
    ((cW (s + 1) : ℤ) - cW (v + 1)).natAbs ≤ (s - v).natAbs := by
  rw [pendC_wW_iff] at hs0 hv0
  rw [pendC_wW_true_iff] at hs1 hv1
  rcases cW_pin s hs0 hs1 with ⟨hs, hsle⟩ | ⟨hs, hsge⟩ <;>
    rcases cW_pin v hv0 hv1 with ⟨hv, hvle⟩ | ⟨hv, hvge⟩ <;> omega

/-- **THE BASE REGISTER.** `n₀ = 1` is compatible with every pin: the two low pins force it into
`[1, 1]` and every high pin admits it with room to spare. -/
theorem hn0W (v : ℤ) (hv0 : pendC (wW v) = false) (hv1 : pendC (wW (v + 1)) = true) :
    ((cW (v + 1) : ℤ) - ((1 : ℕ) : ℤ)).natAbs ≤ v.natAbs := by
  rw [pendC_wW_iff] at hv0
  rw [pendC_wW_true_iff] at hv1
  rcases cW_pin v hv0 hv1 with ⟨hv, hvle⟩ | ⟨hv, hvge⟩ <;> omega

/-- **THE CASCADE WALK LIFTS TO A LADDER PATH.** All six hypotheses of
`exists_ladderPath_of_walk` discharged: `hw` by `rfl` because `stepC` is total (see the
NON-GENERALITY paragraph of this file's header — this is precisely the cost the general statement
pays and this object does not), `hidle`/`hpp`/`hpi` from the walk's own countdown lemmas, and
`hpins`/`hn₀` from the pin arithmetic above. -/
theorem cascadeWalk_exists :
    ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
      (∀ v, objAt g v = wW v) ∧ (∀ v, cntAt g v = cW v) :=
  exists_ladderPath_of_walk wW cW 1 (fun _ => rfl)
    (fun v h => cW_of_idle v ((pendC_wW_iff v).mp h))
    (fun v h0 h1 =>
      cW_pend_pend v ((pendC_wW_true_iff v).mp h0) ((pendC_wW_true_iff (v + 1)).mp h1))
    (fun v h0 h1 =>
      cW_pend_idle v ((pendC_wW_true_iff v).mp h0) ((pendC_wW_iff (v + 1)).mp h1))
    hpinsW hn0W

noncomputable def gW : ℤ → LadderState Qc pendC := cascadeWalk_exists.choose

theorem gW_isLadderPath : IsLadderPath stepC pendC gW := cascadeWalk_exists.choose_spec.1

theorem gW_objAt (v : ℤ) : objAt gW v = wW v := cascadeWalk_exists.choose_spec.2.1 v

theorem gW_cntAt (v : ℤ) : cntAt gW v = cW v := cascadeWalk_exists.choose_spec.2.2 v

/-! ### THE VERDICT: WITNESSED -/

/-- **THE DECISION.** At the comparison position `3` of the region the chain's pin `2` opens — a
position whose past carries the idle witness `2`, and in fact idle positions at every `v ≤ 0`, so
that the pending-forever half is VACUOUS on this object — there IS a ladder path over
`(stepC, pendC)` carrying the chain's own object state with the countdown raised by exactly the
cycle length `l = 1`.

So the restated interface-level existential
`exists_ladderPath_at_region_of_idle_past` is **NOT REFUTED** on the one compiled object that
refutes the `spliceObj`-shaped conclusion. Read the NON-GENERALITY paragraph of this file's header
before carrying this anywhere: `stepC` is total, so this decides REFUTABILITY and never
PROVABILITY. -/
theorem idle_past_interface_witnessed :
    IsLadderPath stepC pendC gW ∧
      objAt gW 3 = objAt tightChain 3 ∧
      cntAt gW 3 = cntAt tightChain 3 + 1 := by
  refine ⟨gW_isLadderPath, ?_, ?_⟩
  · rw [gW_objAt, tightChain_objAt]
    unfold wW wT
    rw [if_neg (not_idleW_region 3 (by norm_num) (by norm_num)), if_neg not_idleT_three]
  · rw [gW_cntAt, tightChain_cntAt, cW_three, cT_three]

/-- The same verdict in the existential shape the unlanded interface declaration carries, at the
instance. NOT a proof of that declaration, and not named after it. -/
theorem exists_ladderPath_at_region_on_tightChain_instance :
    ∃ g' : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g' ∧
      objAt g' 3 = objAt tightChain 3 ∧ cntAt g' 3 = cntAt tightChain 3 + 1 :=
  ⟨gW, idle_past_interface_witnessed.1, idle_past_interface_witnessed.2.1,
    idle_past_interface_witnessed.2.2⟩


end Probe761IdlePast
