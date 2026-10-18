/-
THE COUNTER-LIFT GATE TABLE: the counter arithmetic of the ladder compiled (forward window,
backward constraint, region doubling, iterated doubling), the POSITIONWISE lift refuted for every
finite counter quotient (`no_positionwise_lift`), and the gate rows of the counter-lift record --
gates 1, 2, 9 (both halves), the short-idle gate and the gap-shift gate -- to be run on a 4-cycle
fixture at the model layer, each row flipped from DESIGNED to a compiled verdict as it lands.
The counter-lift lemma itself is NOT proved here: a green table LICENSES its two halves in
pumping form for the successor record; a compiled refutation at a decision gate CLOSES the
ladder route.

## What was asked

The presentation decision for the ladder cell (the set-valued per-state datum `D`, the maximum
`certAdm`-certified subset of `Q × ClType φ × K`, with the realization theorem the fibre
equation and the factorization lemma for `K` its corollary) rests on one unproved lemma: that
every `RladAdm` history projects to a certificate chain over `Q × ClType φ × K` (soundness), and
that every such chain lifts back to a history with the same type sequence (completeness).  The
certified chains of record are REGION-INTERIOR (`no-pending-forever-ray.lean`), so the lift must
compose regions across idle runs under `Count`/`Drift`.  Before any sufficiency attempt, a gate
table is to be compiled on a fixture of product period at least four: gates 1, 2 and 9 (both
halves), the gap-shift gate and the short-idle gate.  The three derived arithmetic items (the
forward window, the backward constraint, the region-doubling inequality) are the first compile
targets.

## What is settled (the arithmetic layer; `Rlad` of `RunLayer.lean` and nothing else)

  1. `Count` unfolded, one clause per letter pair (`count_tt/tf/ft/ff`); the Lipschitz bound of
     `Drift` per step and along a ray (`drift_step`, `drift_ray`); the pins (`pin_region_start`:
     an idle state followed by a pending one hands its next deadline to the new countdown;
     `pin_region_end`: a region ends exactly at countdown `0`; `count_pending_step`).
  2. **The forward window** (`forward_window`): from pending `(q, c, n)`, if the state at offset
     `c + j` is idle and the one at `c + j + 1` is pending, the new region's countdown `L` is the
     idle state's next deadline and `|L - n| ≤ c + j`.
  3. **The backward constraint** (`backward_constraint`): if the current region started `s` steps
     ago, the pin at the region start is `c + s` and `n ∈ [c - 1, c + 2s + 1]`.
  4. **Region doubling** (`region_doubling`): across one region of countdown `L` and the idle run
     of length `j` after it, the next region's countdown `L'` satisfies `|L' - L| ≤ L + j + 1`,
     hence `L' ≤ 2L + j + 1`; `doubling_attained` exhibits the bound attained at `j = 1` on the
     two-state object; `iter_doubling` iterates it to `a k + J + 1 ≤ 2^k (a 0 + J + 1)`.
  5. **The positionwise lift is impossible for EVERY finite counter quotient**
     (`no_positionwise_lift`): for every finite `K`, every `κ : ℕ × ℕ → K`, and every relation
     `R` on `Bool × K` that is SOUND for the two-state object, some `R`-chain is the projection
     of no history.  Mechanism: a Lipschitz-TIGHT history (a length-one region pinning `0`, an
     idle climb to `m`, a region of countdown `m` pinning `m`), a class repeat along the climb
     (pigeonhole), and the cut chain whose two pins are at distance `< m`, which `Drift` forbids.
     So the completeness clause cannot be positionwise for any `K` and any local `R_K`; it must
     be allowed to PUMP.

Per-theorem axiom profile (the `#print axioms` block at the end of this file):
`forward_window`, `backward_constraint`, `region_doubling`, `no_positionwise_lift` on
`[propext, Classical.choice, Quot.sound]` (`Classical.choice` enters through `omega` on `Int`);
`iter_doubling`, `doubling_attained` on `[propext, Quot.sound]`.

## The gate table

Fixture `Q4 := Bool × Fin 4` (the pending walk a deterministic 4-cycle, product period `4`;
built at the model layer below once the fixture section lands); `a := (true, 0)`;
`X χ := ⊥ U χ`; `Y χ := ⊥ S χ`; `ℓ i` the index letter.

| Gate | Pair | Formula / closure | Verdict | Compiled ground |
|---|---|---|---|---|
| 1 | `(a, B, B+1)` vs `(a, B, B+2)` | `p U (¬p ∧ X(p ∧ X ¬p))` | DESIGNED, NOT YET COMPILED (expected SEPARATION: the next region can have countdown `0` from the first, `L ≥ n - c - j = 0`, and not from the second, `L ≥ 1`) | `forward_window` (lower edge); `cell_ne` (two-state, `ladder-cell-refutation.lean`), `gate1_gap_separates` (index) |
| 2 | `(a, c, n)` vs `(a, c+1, n)` | `p U (¬p ∧ ℓ (c mod 4))` | DESIGNED, NOT YET COMPILED (expected SEPARATION: the forced run ends at index `c mod 4`) | `count_pending_step`, `pin_region_end`; `gate2_residue_separates` (index) |
| 9-sep | `(a, 0, n)` vs `(a, 0, n+m)`, `4 ∤ m`, `n ≥ 1` | `X(¬p ∧ X(p ∧ (p U (¬p ∧ ℓ ((n+2) mod 4)))))` | DESIGNED, NOT YET COMPILED (expected SEPARATION: at `c = 0, j = 1` the window is `{n-1, n, n+1}`, three of four residues) | `forward_window` at `c = 0`; `nside_collides` (`nside-modulus-gate.lean`: the index collides at every `(T, P, B)` whose modulus is `P + 1`, so the semantic half decides) |
| short-idle | `(a, 2, 2)` vs `(a, 2 + P, 2 + P)`, `P ≥ 1` (`k = 1`; the family `(a, 2^(k+1) - 2, ·)` a stretch) | `ψ₁ := p ∧ Y(¬p ∧ Y(p ∧ Y(¬p ∧ ¬(⊤ S p))))` | DESIGNED, NOT YET COMPILED (expected SEPARATION for every threshold `T ≤ 2`: the bound is COMPUTED by `region_doubling` at `L = 0`, `j = 1`, not guessed) | `iter_doubling`, `doubling_attained`, `backward_constraint`, `region_doubling` |
| 9-col | `(a, 0, n)` vs `(a, 0, n+4)`, `n ≥ 2` | the closure of the 9-sep formula | DESIGNED, NOT YET COMPILED (expected COLLISION, closure-specific: pump the next region by `4` with `n` raised by `4`; the closure is `snce`-free) -- DECISION GATE | `forward_window`; `second_region_any_length`; per-member truth lemmas |
| gap-shift | `(a, c, n)` vs `(a, c+4, n+4)`, `c ≥ T₀`, same clipped gap | a closure with a `snce` member reading the region start's letter and one pinning the previous idle run's length | DESIGNED, NOT YET COMPILED (expected COLLISION: the pin cascade terminates at an absorbing idle run or a pending-forever past) -- DECISION GATE | `backward_constraint`, `region_doubling`, `doubling_attained`; `gPast_isPath` (pending-forever pasts) |
| statement-shape | generic (`K`, `κ`, sound `R`) | -- | REFUTED, COMPILED: no positionwise lift | `no_positionwise_lift` (this file) |

A gate probing one coordinate certifies one coordinate; passing an earlier row says nothing
about a later one.  Gate 8 stays SIDESTEPPED (no `stab` member in any closure above); gate 3
stays CARRIED.

## The licensed shape of the counter-lift lemma (NOT a theorem of this file)

Recorded verbatim from the research round as the shape a successor record may state; nothing
below is pinned, proved, or cited as proved here.

Fix the object `(Q, step, pend, lab)` and `φ`.  Let `K` be the quotient
`(min c T_c, c mod P, min n T_n, n mod P, clip (n - c) [-B, B])` and `R_K` the image of
`Count`/`Drift` on classes (decidable; its static nonemptiness per class is part of the carrier).
The certificate graph is `Q × ClType φ × K` under the idle-extended `cohBi` (the two `pend`
conjuncts of `coh` dropped; `R_K` on the `K` component; `certStab` per `(q, κ)`); `D` is its
maximum `certAdm`-certified subset.

- **(S) Soundness.**  Every `RladAdm` history projects to a bi-infinite chain in `D` (types by
  the truth clauses and fulfilment along the history, `box` by `box_mem_tpOf_iff`, `stab` by
  `stab_mem_tpOf_iff` GIVEN the consequence below at lower `stab`-depth).
- **(C') Completeness, pumping form.**  For every bi-infinite certificate chain `ξ` and every
  `(c, n) ∈ ξ(0).κ` there is an `RladAdm` history `σ` through `(q, c, n)` whose projection is a
  certificate chain `ξ'` with `ξ'(0) = ξ(0)`, and `tpOf σ 0 = ξ(0).T`.  The history is obtained
  by replacing saturated segments of `ξ` (between rigid anchors: exact `c`, exact `n`, exact gap)
  by certificate paths of other lengths in the same residue class, until the pin lemma's
  inequalities hold, then applying the pin lemma and the label-level sufficiency on the
  resulting walk.  Replacement preserves local coherence and fulfilment.  NO positionwise
  completeness clause is stated anywhere (`no_positionwise_lift`).
- **(K) Parameters as outputs, three sources.**  (K1) `P`: a common multiple of the cycle
  lengths of the certificate graph restricted to saturated classes (eventual periodicity of
  path-length sets in a finite graph; `prodPreN_eventually_periodic` is the set-level form).
  (K2) `T_c`: at least the cascade bound -- the largest region countdown a rigid (all-exact) past
  can force -- which `iter_doubling` shows is exponential in the number of pinned regions; and
  at least the semantic periodicity threshold.  (K3) Ordering: `T_n ≥ T_c + 2ℓ₀ - 1` where `ℓ₀`
  is the longest shortest-path between saturated states; and `T_c ≥ 2 T_short + T_idle + 2` so
  that a short region followed by a long one forces a long (absorbing) idle run between them.
  (K4) `B`: at least `2 d_back + 1` for the formula's backward exactness depth, and at least `2`
  (gate 1).
- **Consequence** (the successor's, not this file's): by induction on `stab`-nesting depth,
  `cellAt` is constant on `K`-classes; `ladderRealized` is the fibre equation; the factorization
  lemma is a corollary and `K`'s parameters its outputs.

## What this does NOT say

  - No tuple index is stated as a candidate at any parameters: `K` is a carrier coordinate, not
    an index.  Where a class-collision statement is needed (the short-idle row) it is stated on
    the index BODY as a SHAPE, in the sense and wording of `nside-modulus-gate.lean`'s header.
  - No seventh coordinate is proposed.  No complexity claim and no upper bound: `c + j`,
    `2s + 1`, `2L + j + 1`, `2^k`, `c₀ + 1` are counts read off `Drift` and `Count`.
  - No finiteness is added: `anchorCells_finite` and `anchorCells_ncard_le` are untouched.
  - The `box`/`stab` acceptance clause is never dropped from any statement sketched above.
  - No `LadderCons`, no `ladderRealized`, no factorization lemma for `K`, under any name; no
    declaration mentions `HitPresented` or `PlusValidZTime`.
  - Gate 8 SIDESTEPPED (no `stab` member in any closure); gate 3 CARRIED.
  - Zero debt: no Buchi/MSO lemma is cited in place of a proof.  Route A is not entered (the
    decision record is the presentation-decision report).
  - The refutation of the positionwise lift is of a STATEMENT SHAPE, not of the datum: it says
    the lift must pump, not that no lift exists.

Compile: `lake env lean specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
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

/-- A history, directly on the triples: a bi-infinite `Rlad` chain.  (Kept for the proof body of
`no_positionwise_lift_core`; the pinned statement `no_positionwise_lift` inlines it.) -/
def IsHist (σ : ℤ → Bool × ℕ × ℕ) : Prop := ∀ t, Rlad stepB pendB t (σ t) (σ (t + 1))

/-- The class-level projection of a ladder state through a counter quotient `κ`.  (Kept for the
proof body; the pinned statement inlines it.) -/
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

/-- The proof body of the positionwise-lift refutation, stated through `IsHist` and `proj`.
The pinned, self-contained statement is `no_positionwise_lift` below. -/
theorem no_positionwise_lift_core {K : Type} [Finite K] (κ : ℕ × ℕ → K)
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

/-- **The positionwise lift is impossible for every finite counter quotient.**  For every finite
`K`, every `κ : ℕ × ℕ → K`, and every relation `R` on `Bool × K` that is sound for the two-state
object (every consecutive pair of a history projects into `R`), there is an `R`-chain that is the
projection of no history.  So a completeness clause of the shape "every chain satisfying the
class relation is the projection of a history, position by position" is false for every `K` of
any shape and every local `R_K`, sound or not; the lift must be allowed to pump.  The statement
is self-contained: the two-state object is `(fun _ _ => true, fun q => q)` and the projection is
`(x.1, κ (x.2.1, x.2.2))`, both written out. -/
theorem no_positionwise_lift {K : Type} [Finite K] (κ : ℕ × ℕ → K)
    (R : Bool × K → Bool × K → Prop)
    (sound : ∀ σ : ℤ → Bool × ℕ × ℕ,
      (∀ t, Rlad (Q := Bool) (fun _ _ => true) (fun q => q) t (σ t) (σ (t + 1))) →
      ∀ t, R ((σ t).1, κ ((σ t).2.1, (σ t).2.2))
        ((σ (t + 1)).1, κ ((σ (t + 1)).2.1, (σ (t + 1)).2.2))) :
    ¬ ∀ ξ : ℤ → Bool × K, (∀ t, R (ξ t) (ξ (t + 1))) →
      ∃ σ : ℤ → Bool × ℕ × ℕ,
        (∀ t, Rlad (Q := Bool) (fun _ _ => true) (fun q => q) t (σ t) (σ (t + 1))) ∧
        ∀ t, ((σ t).1, κ ((σ t).2.1, (σ t).2.2)) = ξ t :=
  no_positionwise_lift_core κ R sound

end Probe820

/-! ## Axiom check -/

#print axioms Probe820.forward_window
#print axioms Probe820.backward_constraint
#print axioms Probe820.region_doubling
#print axioms Probe820.iter_doubling
#print axioms Probe820.doubling_attained
#print axioms Probe820.no_positionwise_lift
