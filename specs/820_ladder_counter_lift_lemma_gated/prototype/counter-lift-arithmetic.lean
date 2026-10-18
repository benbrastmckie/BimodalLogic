/-
THE COUNTER ARITHMETIC OF THE LADDER, COMPILED, AND THE POSITIONWISE LIFT REFUTED.

Research-level prototype for the counter-lift record (not wired into the evidence gate).  Four
things are settled here, all over `Rlad` of `RunLayer.lean` and nothing else.

  1. The three derived items of the decision record are theorems, generic in the object:
     - `forward_window`: from pending `(q, c, n)`, if the state at offset `c + j` is idle and the
       one at `c + j + 1` is pending, the new region's countdown `L` is the idle state's next
       deadline and `|L - n| ≤ c + j`.
     - `backward_constraint`: if the current region started `s` steps ago (the state `s + 1`
       steps back is idle, the `s + 1` states from there to now pending), then
       `n ∈ [c - 1, c + 2s + 1]`, and the pin at the region start is `c + s`.
     - `region_doubling`: across one region and the idle run after it, consecutive pins satisfy
       `|L' - L| ≤ L + j + 1`, hence `L' ≤ 2L + j + 1`; `doubling_attained` exhibits the bound
       attained at `j = 1` on the two-state object; `iter_doubling` iterates it to
       `a k + J + 1 ≤ 2^k (a 0 + J + 1)`.
     Each is two pins and the `Drift` Lipschitz bound; no pending run is needed in between, which
     is why the statements carry only the idle/pending letters at the pin positions.

  2. **The positionwise lift is impossible for EVERY finite counter quotient**
     (`no_positionwise_lift`).  Take any finite `K`, any `κ : ℕ × ℕ → K`, and any relation `R`
     on `Bool × K` that is SOUND (every consecutive pair of a two-state-object history projects
     into `R`).  Then some `R`-chain is the projection of NO history.  Mechanism: a history with
     a length-one region (which pins the next deadline before it at `0`), an idle run whose next
     deadline climbs by one per step to `m`, and then a region of length `m + 1` (which pins the
     deadline before it at `m`) is Lipschitz-TIGHT; the finite quotient repeats a class along the
     climb (pigeonhole on `ℕ → K`); cutting the loop between the repeat leaves an `R`-chain whose
     two pins are `0` and `m` at distance `< m`, which `Drift` forbids.  So the dispatch's
     "completeness (the lift): every such chain lifts to a history with the same sequence" cannot
     hold positionwise for any `K` and any local `R_K`; the viable completeness clause is the
     PUMPING form (loops inserted or deleted in saturated zones, the state at position `0` kept),
     which is what the research report recommends be stated instead.

What this does NOT say: nothing here is a factorization lemma, a cell index, a `LadderCons`, a
`ladderRealized`, or any part of one; no `cellAt`, no model, no formula appears.  No bound is
claimed: `c + j`, `2s + 1`, `2L + j + 1` and `2^k` are counts read off `Drift` and `Count`.  No
finiteness is added.  The refutation in 2 is of a STATEMENT SHAPE, not of the datum: it says the
lift must pump, not that no lift exists.

Compile: `lake env lean specs/820_ladder_counter_lift_lemma_gated/prototype/counter-lift-arithmetic.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import Mathlib.Data.Fintype.Pigeonhole

open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe820

/-! ## `Count` unfolded, one clause per letter pair -/

theorem count_tt (c n c' : ℕ) : Count true true c n c' ↔ c' + 1 = c := by simp [Count]
theorem count_tf (c n c' : ℕ) : Count true false c n c' ↔ c' = 0 ∧ c = 0 := by simp [Count]
theorem count_ft (c n c' : ℕ) : Count false true c n c' ↔ c' = n := by simp [Count]
theorem count_ff (c n c' : ℕ) : Count false false c n c' ↔ c' = 0 := by simp [Count]

section Generic

variable {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (t : ℤ)

/-! ### The Lipschitz bound of `Drift`, per step and along a ray -/

/-- One `Rlad` step moves the next deadline by at most one, in both directions. -/
theorem drift_step (x y : Q × ℕ × ℕ) (h : Rlad step pend t x y) :
    y.2.2 ≤ x.2.2 + 1 ∧ x.2.2 ≤ y.2.2 + 1 := by
  have hd := h.2.2.1
  simp only [Drift] at hd
  omega

/-- Along a forward `Rlad` ray the next deadline is `1`-Lipschitz in the offset. -/
theorem drift_ray (f : ℕ → Q × ℕ × ℕ) (hf : ∀ i, Rlad step pend t (f i) (f (i + 1))) (j : ℕ) :
    (f j).2.2 ≤ (f 0).2.2 + j ∧ (f 0).2.2 ≤ (f j).2.2 + j := by
  induction j with
  | zero => simp
  | succ j ih =>
    have := drift_step step pend t (f j) (f (j + 1)) (hf j)
    omega

/-! ### The pins: what `Count` fixes at a region start and a region end -/

/-- The pin at a region start: an idle state followed by a pending one hands its next deadline
to the new countdown (`Count false true`). -/
theorem pin_region_start (x y : Q × ℕ × ℕ) (h : Rlad step pend t x y)
    (hx : pend x.1 = false) (hy : pend y.1 = true) : y.2.1 = x.2.2 := by
  have hc := h.2.2.2
  rw [hx, hy, count_ft] at hc
  exact hc

/-- A pending state followed by an idle one has countdown `0` (`Count true false`): a region
ends exactly when the countdown is exhausted. -/
theorem pin_region_end (x y : Q × ℕ × ℕ) (h : Rlad step pend t x y)
    (hx : pend x.1 = true) (hy : pend y.1 = false) : x.2.1 = 0 := by
  have hc := h.2.2.2
  rw [hx, hy, count_tf] at hc
  exact hc.2

/-- Along a pending-to-pending step the countdown drops by exactly one (`Count true true`). -/
theorem count_pending_step (x y : Q × ℕ × ℕ) (h : Rlad step pend t x y)
    (hx : pend x.1 = true) (hy : pend y.1 = true) : y.2.1 + 1 = x.2.1 := by
  have hc := h.2.2.2
  rw [hx, hy, count_tt] at hc
  exact hc

/-! ### First compile target: the forward window -/

/-- **The forward window.**  From a pending state with countdown `c` and next deadline `n`, if
the state at offset `c + j` is idle and the state at offset `c + j + 1` is pending, then the
new region's countdown `L` is the idle state's next deadline, and `|L - n| ≤ c + j`.  (The
pending run of offsets `0..c` and the first idle state at `c + 1` are forced by `Count` and are
not needed here: the window is the pin at `c + j` plus the Lipschitz bound.)  `c + j` is a count
of steps and nothing else. -/
theorem forward_window (f : ℕ → Q × ℕ × ℕ) (hf : ∀ i, Rlad step pend t (f i) (f (i + 1)))
    (j : ℕ) (hidle : pend (f ((f 0).2.1 + j)).1 = false)
    (hnext : pend (f ((f 0).2.1 + j + 1)).1 = true) :
    (f ((f 0).2.1 + j + 1)).2.1 = (f ((f 0).2.1 + j)).2.2 ∧
      (f ((f 0).2.1 + j + 1)).2.1 ≤ (f 0).2.2 + ((f 0).2.1 + j) ∧
      (f 0).2.2 ≤ (f ((f 0).2.1 + j + 1)).2.1 + ((f 0).2.1 + j) := by
  have hpin := pin_region_start step pend t _ _ (hf ((f 0).2.1 + j)) hidle hnext
  have hdr := drift_ray step pend t f hf ((f 0).2.1 + j)
  refine ⟨hpin, ?_, ?_⟩ <;> omega

/-! ### Second compile target: the backward constraint -/

/-- Along a backward pending chain the countdown rises by one per step back. -/
theorem countdown_back (x : ℕ → Q × ℕ × ℕ) (hx : ∀ i, Rlad step pend t (x (i + 1)) (x i))
    (s : ℕ) (hp : ∀ i, i ≤ s → pend (x i).1 = true) :
    ∀ i, i ≤ s → (x i).2.1 = (x 0).2.1 + i := by
  intro i
  induction i with
  | zero => intro _; simp
  | succ i ih =>
    intro hi
    have h1 := count_pending_step step pend t (x (i + 1)) (x i) (hx i)
      (hp (i + 1) hi) (hp i (by omega))
    have h2 := ih (by omega)
    omega

/-- **The backward constraint.**  `x i` is the state `i` steps back.  If the states `0..s` are
pending and the state `s + 1` steps back is idle (the current region started `s` steps ago),
then the pin at the region start is `c + s`, and `n ∈ [c - 1, c + 2s + 1]`.  Contrapositively a
state with `n < c - 1` has NO region start in its past at any distance, and a state with gap
`n - c` has its region start at least `(n - c - 1) / 2` steps back. -/
theorem backward_constraint (x : ℕ → Q × ℕ × ℕ) (hx : ∀ i, Rlad step pend t (x (i + 1)) (x i))
    (s : ℕ) (hp : ∀ i, i ≤ s → pend (x i).1 = true) (hs : pend (x (s + 1)).1 = false) :
    (x (s + 1)).2.2 = (x 0).2.1 + s ∧
      (x 0).2.1 ≤ (x 0).2.2 + 1 ∧ (x 0).2.2 ≤ (x 0).2.1 + 2 * s + 1 := by
  have hcs := countdown_back step pend t x hx s hp s le_rfl
  have hpin := pin_region_start step pend t _ _ (hx s) hs (hp s le_rfl)
  -- `Drift` backward over `s + 1` steps: the reversed ray
  have hdr : ∀ k, (x k).2.2 ≤ (x 0).2.2 + k ∧ (x 0).2.2 ≤ (x k).2.2 + k := by
    intro k
    induction k with
    | zero => simp
    | succ k ih =>
      have := drift_step step pend t (x (k + 1)) (x k) (hx k)
      omega
  have := hdr (s + 1)
  refine ⟨by omega, by omega, by omega⟩

/-! ### Third compile target: the region-doubling inequality -/

/-- **Region doubling.**  `f 0` idle, `f 1` pending (a region starts, with countdown `L` the pin
`(f 0).2.2`); the state at offset `L + 1 + j` idle and the one at `L + 1 + j + 1` pending (the next
region starts after an idle run reaching offset `L + 1 + j`).  Then the next region's countdown
`L'` satisfies `|L' - L| ≤ L + j + 1`, in particular `L' ≤ 2L + j + 1`.  Two pins and one
Lipschitz bound; the pending run between is forced by `Count` and not used. -/
theorem region_doubling (f : ℕ → Q × ℕ × ℕ) (hf : ∀ i, Rlad step pend t (f i) (f (i + 1)))
    (h0 : pend (f 0).1 = false) (h1 : pend (f 1).1 = true) (j : ℕ)
    (hidle : pend (f ((f 0).2.2 + 1 + j)).1 = false)
    (hnext : pend (f ((f 0).2.2 + 1 + j + 1)).1 = true) :
    (f 1).2.1 = (f 0).2.2 ∧
      (f ((f 0).2.2 + 1 + j + 1)).2.1 = (f ((f 0).2.2 + 1 + j)).2.2 ∧
      (f ((f 0).2.2 + 1 + j + 1)).2.1 ≤ 2 * (f 0).2.2 + j + 1 ∧
      (f 0).2.2 ≤ (f ((f 0).2.2 + 1 + j + 1)).2.1 + (f 0).2.2 + j + 1 := by
  have hpin0 := pin_region_start step pend t _ _ (hf 0) h0 h1
  have hpin1 := pin_region_start step pend t _ _ (hf ((f 0).2.2 + 1 + j)) hidle hnext
  have hdr := drift_ray step pend t f hf ((f 0).2.2 + 1 + j)
  refine ⟨hpin0, hpin1, ?_, ?_⟩ <;> omega

/-- The doubling recurrence iterated: with every idle run of length at most `J`, the `k`-th
region's length is at most `2^k` times the first's (plus the constant).  A count, exhibited to
show that a rigid chain of `k` short regions bounds the current region EXPONENTIALLY in `k`
and not linearly -- the arithmetic core of the short-idle gate. -/
theorem iter_doubling (a : ℕ → ℕ) (J : ℕ) (h : ∀ k, a (k + 1) ≤ 2 * a k + J + 1) :
    ∀ k, a k + J + 1 ≤ 2 ^ k * (a 0 + J + 1) := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
    have h1 := h k
    have h2 : 2 * (a k + J + 1) ≤ 2 * (2 ^ k * (a 0 + J + 1)) := Nat.mul_le_mul_left 2 ih
    rw [pow_succ, mul_comm (2 ^ k) 2, mul_assoc]
    generalize 2 ^ k * (a 0 + J + 1) = X at h2 ⊢
    omega

end Generic

/-! ## The two-state object: the doubling bound attained, and the positionwise lift refuted -/

section TwoState

/-- Every object step is allowed; the object state is its own pending bit. -/
def stepB : Bool → Bool → Bool := fun _ _ => true
def pendB : Bool → Bool := fun q => q

theorem rladB_iff (t : ℤ) (x y : Bool × ℕ × ℕ) :
    Rlad stepB pendB t x y ↔
      (x.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧ Count x.1 y.1 x.2.1 x.2.2 y.2.1 := by
  simp [Rlad, stepB, pendB]

/-! ### The doubling bound is attained at `j = 1` -/

/-- The maximal-growth ray: idle end with next deadline `L`; a region of countdown `L` during
which the next deadline climbs by one per step; one idle state, still climbing; the next region
starts with countdown `2L + 2 = 2L + j + 1` at `j = 1`. -/
def growRay (L : ℕ) : ℕ → Bool × ℕ × ℕ := fun i =>
  if i = 0 then (false, 0, L)
  else if i ≤ L + 1 then (true, L + 1 - i, L + i)
  else if i = L + 2 then (false, 0, 2 * L + 2)
  else if i = L + 3 then (true, 2 * L + 2, 2 * L + 2)
  else (true, 2 * L + 2 - (i - (L + 3)), 2 * L + 2)

theorem growRay_zero (L : ℕ) : growRay L 0 = (false, 0, L) := by simp [growRay]

theorem growRay_pend (L i : ℕ) (h1 : 1 ≤ i) (h2 : i ≤ L + 1) :
    growRay L i = (true, L + 1 - i, L + i) := by
  have h1' : i ≠ 0 := by omega
  simp [growRay, h1', h2]

theorem growRay_idle (L : ℕ) : growRay L (L + 2) = (false, 0, 2 * L + 2) := by
  have h2 : ¬ L + 2 ≤ L + 1 := by omega
  simp [growRay, h2]

theorem growRay_next (L : ℕ) : growRay L (L + 3) = (true, 2 * L + 2, 2 * L + 2) := by
  have h2 : ¬ L + 3 ≤ L + 1 := by omega
  simp [growRay, h2]

theorem growRay_isRay (L : ℕ) (t : ℤ) :
    ∀ i, i ≤ L + 2 → Rlad stepB pendB t (growRay L i) (growRay L (i + 1)) := by
  intro i hi
  rw [rladB_iff]
  rcases Nat.eq_zero_or_pos i with h0 | hpos
  · subst h0
    rw [growRay_zero, growRay_pend L 1 le_rfl (by omega)]
    simp [Drift, Count]
  rcases lt_or_eq_of_le (show i ≤ L + 2 from hi) with hlt | heq
  · rcases lt_or_eq_of_le (show i ≤ L + 1 by omega) with hlt2 | heq2
    · rw [growRay_pend L i hpos (by omega), growRay_pend L (i + 1) (by omega) (by omega)]
      simp [Drift, Count]
      omega
    · subst heq2
      rw [growRay_pend L (L + 1) (by omega) le_rfl, growRay_idle]
      simp [Drift, Count]
      omega
  · subst heq
    rw [growRay_idle, growRay_next]
    simp [Drift, Count]

/-- **The doubling bound is attained**: on the two-state object, from an idle end with next
deadline `L`, a region of countdown `L` followed by one idle state can be followed by a region of
countdown exactly `2L + 2`. -/
theorem doubling_attained (L : ℕ) :
    pendB (growRay L 0).1 = false ∧ (growRay L 0).2.2 = L ∧
      pendB (growRay L (L + 2)).1 = false ∧ pendB (growRay L (L + 3)).1 = true ∧
      (growRay L (L + 3)).2.1 = 2 * L + 2 := by
  rw [growRay_zero, growRay_idle, growRay_next]
  simp [pendB]

/-! ### The positionwise lift refuted for every finite quotient -/

/-- A history, directly on the triples: a bi-infinite `Rlad` chain. -/
def IsHist (σ : ℤ → Bool × ℕ × ℕ) : Prop := ∀ t, Rlad stepB pendB t (σ t) (σ (t + 1))

/-- The class-level projection of a ladder state through a counter quotient `κ`. -/
def proj {K : Type} (κ : ℕ × ℕ → K) (x : Bool × ℕ × ℕ) : Bool × K := (x.1, κ (x.2.1, x.2.2))

/-- Along a history the next deadline is `1`-Lipschitz. -/
theorem drift_hist (σ : ℤ → Bool × ℕ × ℕ) (h : IsHist σ) (a : ℤ) (k : ℕ) :
    (σ (a + k)).2.2 ≤ (σ a).2.2 + k ∧ (σ a).2.2 ≤ (σ (a + k)).2.2 + k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hs := h (a + k)
    rw [rladB_iff] at hs
    have hd := hs.2.1
    simp only [Drift] at hd
    rw [show a + ((k + 1 : ℕ) : ℤ) = a + k + 1 by push_cast; omega]
    omega

/-- Along a history, a pending run ending at a pending state followed by an idle one has
countdown `k` at the state `k` steps before its end. -/
theorem countdown_of_run (σ : ℤ → Bool × ℕ × ℕ) (h : IsHist σ) (b : ℤ) (m : ℕ)
    (hp : ∀ k : ℕ, k ≤ m → (σ (b - k)).1 = true) (hb : (σ (b + 1)).1 = false) :
    ∀ k : ℕ, k ≤ m → (σ (b - k)).2.1 = k := by
  intro k
  induction k with
  | zero =>
    intro _
    have hs := h b
    rw [rladB_iff] at hs
    have hc := hs.2.2
    have hp0 := hp 0 (by omega)
    simp only [Nat.cast_zero, sub_zero] at hp0
    rw [hp0, hb, count_tf] at hc
    simp only [Nat.cast_zero, sub_zero]
    exact hc.2
  | succ k ih =>
    intro hk
    have hs := h (b - (k + 1 : ℕ))
    rw [rladB_iff] at hs
    have hc := hs.2.2
    have hpk := hp k (by omega)
    have hpk1 := hp (k + 1) hk
    rw [show b - ((k + 1 : ℕ) : ℤ) + 1 = b - k by push_cast; omega] at hc
    rw [hpk1, hpk, count_tt, ih (by omega)] at hc
    exact hc.symm

/-- The tight history, parametrised by `m ≥ 2`: idle with next deadline `0` up to time `0`; a
length-one region at time `1` (so the deadline before it is pinned at `0`); an idle run over
times `2..m` with the next deadline climbing by one per step to `m`; a region of countdown `m`
over times `m+1 .. 2m+1` (so the deadline before it is pinned at `m`); idle with next deadline
`m` afterwards.  The two pins, `0` at time `0` and `m` at time `m`, are at distance exactly `m`:
`Drift` has no slack. -/
def tightHist (m : ℕ) : ℤ → Bool × ℕ × ℕ := fun t =>
  if t ≤ 0 then (false, 0, 0)
  else if t = 1 then (true, 0, 1)
  else if t ≤ m then (false, 0, t.toNat)
  else if t ≤ 2 * m + 1 then (true, (2 * m + 1 - t).toNat, m)
  else (false, 0, m)

theorem tightHist_isHist (m : ℕ) (hm : 2 ≤ m) : IsHist (tightHist m) := by
  intro t
  rw [rladB_iff]
  by_cases h0 : t ≤ 0
  · by_cases h0' : t + 1 ≤ 0
    · simp [tightHist, h0, h0', Drift, Count]
    · have ht : t = 0 := by omega
      subst ht
      simp [tightHist, Drift, Count]
  · by_cases h1 : t = 1
    · subst h1
      have h2 : (2 : ℤ) ≤ m := by omega
      simp [tightHist, h2, Drift, Count]
    · by_cases h2 : t ≤ m
      · by_cases h2' : t + 1 ≤ m
        · have h1' : t + 1 ≠ 1 := by omega
          have h0'' : ¬ t + 1 ≤ 0 := by omega
          simp only [tightHist, h0, h1, h2, h0'', h1', h2', if_false, if_true, Drift, Count]
          simp
          omega
        · have ht : t = m := by omega
          have h1' : t + 1 ≠ 1 := by omega
          have h0'' : ¬ t + 1 ≤ 0 := by omega
          have h3 : t + 1 ≤ 2 * m + 1 := by omega
          simp only [tightHist, h0, h1, h2, h0'', h1', h2', h3, if_false, if_true, Drift, Count]
          simp
          omega
      · by_cases h3 : t ≤ 2 * m + 1
        · by_cases h3' : t + 1 ≤ 2 * m + 1
          · have h1' : t + 1 ≠ 1 := by omega
            have h0'' : ¬ t + 1 ≤ 0 := by omega
            have h2' : ¬ t + 1 ≤ m := by omega
            simp only [tightHist, h0, h1, h2, h3, h0'', h1', h2', h3', if_false, if_true, Drift,
              Count]
            simp
            omega
          · have ht : t = 2 * m + 1 := by omega
            have h1' : t + 1 ≠ 1 := by omega
            have h0'' : ¬ t + 1 ≤ 0 := by omega
            have h2' : ¬ t + 1 ≤ m := by omega
            simp only [tightHist, h0, h1, h2, h3, h0'', h1', h2', h3', if_false, if_true, Drift,
              Count]
            simp
            omega
        · have h1' : t + 1 ≠ 1 := by omega
          have h0'' : ¬ t + 1 ≤ 0 := by omega
          have h2' : ¬ t + 1 ≤ m := by omega
          have h3' : ¬ t + 1 ≤ 2 * m + 1 := by omega
          simp [tightHist, h0, h1, h2, h3, h0'', h1', h2', h3', Drift, Count]

/-- The chain obtained from a history by cutting out the times `(i, i']`. -/
def cutChain {K : Type} (κ : ℕ × ℕ → K) (σ : ℤ → Bool × ℕ × ℕ) (i d : ℕ) : ℤ → Bool × K :=
  fun t => if t ≤ i then proj κ (σ t) else proj κ (σ (t + d))

/-- **The positionwise lift is impossible for every finite counter quotient.**  For every finite
`K`, every `κ : ℕ × ℕ → K`, and every relation `R` on `Bool × K` that is sound for the two-state
object (every consecutive pair of a history projects into `R`), there is an `R`-chain that is the
projection of no history.  So a completeness clause of the shape "every chain satisfying the
class relation is the projection of a history, position by position" is false for every `K` of
any shape and every local `R_K`, sound or not; the lift must be allowed to pump. -/
theorem no_positionwise_lift {K : Type} [Finite K] (κ : ℕ × ℕ → K)
    (R : Bool × K → Bool × K → Prop)
    (sound : ∀ σ : ℤ → Bool × ℕ × ℕ, IsHist σ → ∀ t, R (proj κ (σ t)) (proj κ (σ (t + 1)))) :
    ¬ ∀ ξ : ℤ → Bool × K, (∀ t, R (ξ t) (ξ (t + 1))) →
      ∃ σ : ℤ → Bool × ℕ × ℕ, IsHist σ ∧ ∀ t, proj κ (σ t) = ξ t := by
  intro hcomplete
  -- pigeonhole on the idle classes `κ (0, k + 2)`
  obtain ⟨k, k', hne, hκ⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fun k : ℕ => κ (0, k + 2))
  -- orient the repeat
  wlog hlt : k < k' generalizing k k'
  · exact this k' k hne.symm hκ.symm (by omega)
  -- the tight history with `m := k' + 2`, cut at `(k + 2, k' + 2]`
  set i : ℕ := k + 2 with hi
  set m : ℕ := k' + 2 with hm
  set d : ℕ := m - i with hd
  clear_value i m d
  have hd1 : 1 ≤ d := by omega
  have hH := tightHist_isHist m (by omega)
  -- the cut chain is an `R`-chain
  have hchain : ∀ t, R (cutChain κ (tightHist m) i d t) (cutChain κ (tightHist m) i d (t + 1)) := by
    intro t
    by_cases ht : t + 1 ≤ i
    · have ht' : t ≤ i := by omega
      simp only [cutChain, ht, ht', if_true]
      exact sound _ hH t
    · by_cases ht' : t ≤ i
      · have hti : t = i := by omega
        subst hti
        simp only [cutChain, ht, ht', if_true, if_false]
        -- the pair `(σ i, σ (i + 1 + d))` projects like `(σ m, σ (m + 1))`
        have hpi : proj κ (tightHist m i) = proj κ (tightHist m m) := by
          have h1 : ¬ ((i : ℤ) ≤ 0) := by omega
          have h2 : (i : ℤ) ≠ 1 := by omega
          have h3 : (i : ℤ) ≤ m := by omega
          have h4 : ¬ ((m : ℤ) ≤ 0) := by omega
          have h5 : (m : ℤ) ≠ 1 := by omega
          simp only [proj, tightHist, h1, h2, h3, h4, h5, le_refl, if_false, if_true,
            Int.toNat_natCast]
          rw [hκ]
        have hs := sound _ hH m
        rw [show (i : ℤ) + 1 + d = (m : ℤ) + 1 by omega]
        rw [hpi]
        exact hs
      · simp only [cutChain, ht, ht', if_false]
        rw [show t + 1 + d = (t + d) + 1 by omega]
        exact sound _ hH (t + d)
  obtain ⟨σ, hσ, hproj⟩ := hcomplete _ hchain
  -- read the letters of `σ` off the chain
  have hletter : ∀ t, (σ t).1 = (cutChain κ (tightHist m) i d t).1 := by
    intro t
    rw [← hproj t]
    rfl
  -- time `0` idle, time `1` pending, time `2` idle: the length-one region pins `(σ 0).2.2 = 0`
  have hl0 : (σ 0).1 = false := by
    rw [hletter]
    have h0 : (0 : ℤ) ≤ i := by omega
    show (if (0 : ℤ) ≤ i then proj κ (tightHist m 0) else proj κ (tightHist m (0 + d))).1 = false
    rw [if_pos h0]
    show (tightHist m 0).1 = false
    simp only [tightHist, le_refl, if_true]
  have hl1 : (σ 1).1 = true := by
    rw [hletter]
    have h0 : (1 : ℤ) ≤ i := by omega
    show (if (1 : ℤ) ≤ i then proj κ (tightHist m 1) else proj κ (tightHist m (1 + d))).1 = true
    rw [if_pos h0]
    show (tightHist m 1).1 = true
    have h1 : ¬ ((1 : ℤ) ≤ 0) := by omega
    simp only [tightHist, h1, if_false, if_true]
  have hl2 : (σ 2).1 = false := by
    rw [hletter]
    have h0 : (2 : ℤ) ≤ i := by omega
    show (if (2 : ℤ) ≤ i then proj κ (tightHist m 2) else proj κ (tightHist m (2 + d))).1 = false
    rw [if_pos h0]
    show (tightHist m 2).1 = false
    have h1 : ¬ ((2 : ℤ) ≤ 0) := by omega
    have h2 : (2 : ℤ) ≠ 1 := by omega
    have h3 : (2 : ℤ) ≤ m := by omega
    simp only [tightHist, h1, h2, h3, if_false, if_true]
  have hpin0 : (σ 0).2.2 = 0 := by
    have hs0 := hσ 0
    have hs1 := hσ 1
    rw [rladB_iff] at hs0 hs1
    have hc0 := hs0.2.2
    have hc1 := hs1.2.2
    simp only [zero_add] at hc0
    rw [hl0, hl1, count_ft] at hc0
    rw [show (1 : ℤ) + 1 = 2 by norm_num, hl1, hl2, count_tf] at hc1
    omega
  -- times `i + 1 .. i + 1 + m` pending, time `i + 2 + m` idle: the region pins `(σ i).2.2 = m`
  have hli : (σ i).1 = false := by
    rw [hletter]
    show (if (i : ℤ) ≤ i then proj κ (tightHist m i) else proj κ (tightHist m (i + d))).1 = false
    rw [if_pos le_rfl]
    show (tightHist m i).1 = false
    have h1 : ¬ ((i : ℤ) ≤ 0) := by omega
    have h2 : (i : ℤ) ≠ 1 := by omega
    have h3 : (i : ℤ) ≤ m := by omega
    simp only [tightHist, h1, h2, h3, if_false, if_true]
  have hrun : ∀ k : ℕ, k ≤ m → (σ ((i : ℤ) + 1 + m - k)).1 = true := by
    intro k hk
    rw [hletter]
    have h1 : ¬ ((i : ℤ) + 1 + m - k ≤ i) := by omega
    show (if (i : ℤ) + 1 + m - k ≤ i then proj κ (tightHist m ((i : ℤ) + 1 + m - k))
      else proj κ (tightHist m ((i : ℤ) + 1 + m - k + d))).1 = true
    rw [if_neg h1]
    show (tightHist m ((i : ℤ) + 1 + m - k + d)).1 = true
    have h2 : ¬ ((i : ℤ) + 1 + m - k + d ≤ 0) := by omega
    have h3 : (i : ℤ) + 1 + m - k + d ≠ 1 := by omega
    have h4 : ¬ ((i : ℤ) + 1 + m - k + d ≤ m) := by omega
    have h5 : (i : ℤ) + 1 + m - k + d ≤ 2 * m + 1 := by omega
    simp only [tightHist, h2, h3, h4, h5, if_false, if_true]
  have hend : (σ ((i : ℤ) + 1 + m + 1)).1 = false := by
    rw [hletter]
    have h1 : ¬ ((i : ℤ) + 1 + m + 1 ≤ i) := by omega
    show (if (i : ℤ) + 1 + m + 1 ≤ i then proj κ (tightHist m ((i : ℤ) + 1 + m + 1))
      else proj κ (tightHist m ((i : ℤ) + 1 + m + 1 + d))).1 = false
    rw [if_neg h1]
    show (tightHist m ((i : ℤ) + 1 + m + 1 + d)).1 = false
    have h2 : ¬ ((i : ℤ) + 1 + m + 1 + d ≤ 0) := by omega
    have h3 : (i : ℤ) + 1 + m + 1 + d ≠ 1 := by omega
    have h4 : ¬ ((i : ℤ) + 1 + m + 1 + d ≤ m) := by omega
    have h5 : ¬ ((i : ℤ) + 1 + m + 1 + d ≤ 2 * m + 1) := by omega
    simp only [tightHist, h2, h3, h4, h5, if_false]
  have hcount := countdown_of_run σ hσ ((i : ℤ) + 1 + m) m hrun hend m le_rfl
  have hstart : (σ ((i : ℤ) + 1)).2.1 = m := by
    rw [show (i : ℤ) + 1 = (i : ℤ) + 1 + m - m by omega]
    exact hcount
  have hpinm : (σ i).2.2 = m := by
    have hs := hσ i
    rw [rladB_iff] at hs
    have hc := hs.2.2
    have hli1 : (σ ((i : ℤ) + 1)).1 = true := by
      have := hrun m le_rfl
      rwa [show (i : ℤ) + 1 + m - m = i + 1 by omega] at this
    rw [hli, hli1, count_ft, hstart] at hc
    exact hc.symm
  -- `Drift` from time `0` to time `i`: `m ≤ 0 + i`, i.e. `k' ≤ k`
  have hdr := drift_hist σ hσ 0 i
  rw [zero_add] at hdr
  omega

end TwoState

end Probe820

/-! ## Axiom check -/

#print axioms Probe820.forward_window
#print axioms Probe820.backward_constraint
#print axioms Probe820.region_doubling
#print axioms Probe820.iter_doubling
#print axioms Probe820.doubling_attained
#print axioms Probe820.no_positionwise_lift
