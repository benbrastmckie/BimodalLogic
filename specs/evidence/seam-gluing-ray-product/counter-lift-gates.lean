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
| 1 | `(a, B, B+1)` vs `(a, B, B+2)` | `p U (¬p ∧ X(p ∧ X ¬p))` (`phi1`) | SEPARATION, COMPILED (`gate1_cell_ne`, every `B`): the next region has countdown `0` after one idle state from the first (`wit1`, `exists_phi1_mem_cell`) and countdown `≥ 1` from the second (`not_phi1_of_gap_two`: the deadline at the first idle state is `≥ 1` by `Drift`, the pin makes the next countdown `≥ 1`) | `forward_window` (lower edge); `cell_ne` (two-state, `ladder-cell-refutation.lean`), `gate1_gap_separates` (index) |
| 2 | `(a, c, n)` vs `(a, c+1, n)` | `p U (¬p ∧ ℓ (c mod 4))` (`phi2 c`) | SEPARATION, COMPILED (`gate2_cell_ne`, every `c`, `n`): the forced run ends at index `idx c` from the first (`phi2_of_path`, along EVERY path) and at `idx (c+1) ≠ idx c` from the second (`not_phi2_of_path`) | `count_pending_step`, `pin_region_end`; `gate2_residue_separates` (index) |
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
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import Mathlib.Data.Fintype.Pigeonhole

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
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

/-! ## The 4-cycle fixture at the model layer

Object `Q4 := Bool × Fin 4`: the pending walk is the deterministic 4-cycle `0 → 1 → 2 → 3 → 0`
(product period `4`), every pending state steps to its idle copy, idle states self-loop and
restart a region at their own index.  Built in the shape of the `Q5` fixture of
`ladder-residue-index-refutation.lean` (same carrier type, a different step relation). -/

section Fixture4

/-- Object states `(pending?, index)`. -/
abbrev Q4 : Type := Bool × Fin 4

def pend4 : Q4 → Bool := fun q => q.1

/-- Exactly the edges `(true, i) → (true, i + 1)`, `(true, i) → (false, i)`,
`(false, i) → (false, i)`, `(false, i) → (true, i)`, indices in `Fin 4`. -/
def step4 : Q4 → Q4 → Bool := fun x y =>
  if x.1 then (if y.1 then y.2 == x.2 + 1 else y.2 == x.2) else (y.2 == x.2)

/-- `step4` has exactly sixteen edges: four indices times four edge kinds. -/
theorem step4_card :
    (Finset.univ.filter (fun xy : Q4 × Q4 => step4 xy.1 xy.2 = true)).card = 16 := by decide

theorem step4_pend_succ : ∀ i : Fin 4, step4 (true, i) (true, i + 1) = true := by decide
theorem step4_pend_prev : ∀ i : Fin 4, step4 (true, i - 1) (true, i) = true := by decide
theorem step4_pend_idle : ∀ i : Fin 4, step4 (true, i) (false, i) = true := by decide
theorem step4_idle_self : ∀ i : Fin 4, step4 (false, i) (false, i) = true := by decide
theorem step4_idle_start : ∀ i : Fin 4, step4 (false, i) (true, i) = true := by decide

/-- The pending walk is deterministic: the only pending successor of `(true, i)` is
`(true, i + 1)`. -/
theorem step4_pend_iff : ∀ i j : Fin 4, step4 (true, i) (true, j) = true ↔ j = i + 1 := by decide
theorem step4_pi_iff : ∀ i j : Fin 4, step4 (true, i) (false, j) = true ↔ j = i := by decide
/-- An idle state keeps its index, whether it stays idle or restarts a region. -/
theorem step4_idle_iff : ∀ (i j : Fin 4) (b : Bool), step4 (false, i) (b, j) = true ↔ j = i := by
  decide

theorem rlad4_iff (t : ℤ) (x y : Q4 × ℕ × ℕ) :
    Rlad step4 pend4 t x y ↔
      step4 x.1 y.1 = true ∧ (x.1.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧
        Count x.1.1 y.1.1 x.2.1 x.2.2 y.2.1 := Iff.rfl

/-- The index reached after `m` pending steps from index `0`: `m mod 4`. -/
def idx (m : ℕ) : Fin 4 := ⟨m % 4, Nat.mod_lt _ (by norm_num)⟩

theorem idx_zero : idx 0 = 0 := by decide

theorem idx_succ (m : ℕ) : idx (m + 1) = idx m + 1 := by
  apply Fin.ext
  simp only [idx, Fin.val_add, Fin.val_one]
  omega

theorem idx_add (m m' : ℕ) : idx (m + m') = idx m + idx m' := by
  apply Fin.ext
  simp only [idx, Fin.val_add]
  omega

theorem idx_eq_iff (m m' : ℕ) : idx m = idx m' ↔ m % 4 = m' % 4 := by
  simp [idx, Fin.ext_iff]

theorem idx_val (m : ℕ) : (idx m).val = m % 4 := rfl

theorem fin_sub_succ : ∀ i j : Fin 4, i - (j + 1) + 1 = i - j := by decide

/-! ### Seriality, the frame and the model -/

theorem fwd4 : ∀ t x, ∃ y, RladAdm step4 pend4 t x y := by
  rintro t ⟨⟨⟨b, i⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad4_iff, step4, Drift, Count]⟩
  | true =>
    cases c with
    | zero =>
      exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
        simp [RladAdm, rlad4_iff, step4, Drift, Count]⟩
    | succ c =>
      exact ⟨⟨((true, i + 1), c, n), fun h => by cases h⟩, by
        simp [RladAdm, rlad4_iff, Drift, Count, step4_pend_succ]⟩

theorem bwd4 : ∀ t x, ∃ y, RladAdm step4 pend4 (t - 1) y x := by
  rintro t ⟨⟨⟨b, i⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad4_iff, step4, Drift, Count]⟩
  | true =>
    exact ⟨⟨((true, i - 1), c + 1, n), fun h => by cases h⟩, by
      simp [RladAdm, rlad4_iff, Drift, Count, step4_pend_prev]⟩

def F4 : FrameOver intOrder := ladderFrameAdm step4 pend4 fwd4 bwd4

instance : F4.IsRegular := ladderFrameAdm_isRegular step4 pend4 fwd4 bwd4

/-- `p` reads the pending bit; `ℓ i` reads the index. -/
def pA : Atom := ⟨"p", none⟩
def lA (i : Fin 4) : Atom := ⟨"l", some i.val⟩

theorem lA_ne_pA (i : Fin 4) : lA i ≠ pA := by simp [lA, pA]
theorem lA_inj {i j : Fin 4} : lA i = lA j ↔ i = j := by simp [lA, Fin.ext_iff]

def lab4 : Q4 → Atom → Bool := fun q a => if a = pA then q.1 else decide (a = lA q.2)

def M4 : TaskModel F4.toTaskFrame := ladderModel step4 pend4 fwd4 bwd4 lab4

def p : PlusFormula := .atom pA
def ℓ (i : Fin 4) : PlusFormula := .atom (lA i)
/-- Next: `X χ := ⊥ U χ`. -/
def X (χ : PlusFormula) : PlusFormula := .untl .bot χ
/-- Previous: `Y χ := ⊥ S χ`. -/
def Y (χ : PlusFormula) : PlusFormula := .snce .bot χ

/-- A pending admissible ladder state. -/
def st4 (i : Fin 4) (c n : ℕ) : LadderState Q4 pend4 :=
  ⟨((true, i), c, n), fun h => by cases h⟩

/-- An idle admissible ladder state (countdown `0`). -/
def idl4 (i : Fin 4) (n : ℕ) : LadderState Q4 pend4 := ⟨((false, i), 0, n), fun _ => rfl⟩

def a4 : Q4 := (true, 0)

/-! ### Histories of `F4` and the letters along them -/

theorem hist_path4 (σ : WorldHistory F4) :
    ∃ (k : ℤ) (g : ℤ → LadderState Q4 pend4),
      IsSlicedStepPath (RladAdm step4 pend4) k g ∧ σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step4 pend4) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwd4 bwd4 σ.path).mp ⟨σ, rfl⟩

theorem hist_of_path4 (k : ℤ) (g : ℤ → LadderState Q4 pend4)
    (hg : IsSlicedStepPath (RladAdm step4 pend4) k g) :
    ∃ σ : WorldHistory F4, σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step4 pend4) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwd4 bwd4 _).mpr ⟨k, g, hg, rfl⟩

section Along4
variable {σ : WorldHistory F4} {k : ℤ} {g : ℤ → LadderState Q4 pend4}
  (hσ : σ.path = fun t => (t + k, g t))
include hσ

theorem state_eq4 (s : ℤ) : σ.state s = (s + k, g s) := congrFun hσ s

theorem truth_p4 (s : ℤ) : PlusTruthAt M4 σ s p ↔ (g s).1.1.1 = true := by
  change M4.valuation (σ.state s) pA ↔ _
  rw [state_eq4 hσ s]
  simp [M4, ladderModel, lab4]

theorem truth_l4 (s : ℤ) (i : Fin 4) : PlusTruthAt M4 σ s (ℓ i) ↔ (g s).1.1.2 = i := by
  change M4.valuation (σ.state s) (lA i) ↔ _
  rw [state_eq4 hσ s]
  show lab4 (g s).1.1 (lA i) = true ↔ _
  simp only [lab4, if_neg (lA_ne_pA i), decide_eq_true_eq, lA_inj]
  exact eq_comm

theorem truth_np4 (s : ℤ) : PlusTruthAt M4 σ s p.neg ↔ (g s).1.1.1 = false := by
  rw [PlusTruth.neg_iff, truth_p4 hσ]
  cases (g s).1.1.1 <;> simp

end Along4

/-- Over integer time `⊥ U χ` is `χ` at the next instant. -/
theorem truth_X4 (σ : WorldHistory F4) (s : ℤ) (χ : PlusFormula) :
    PlusTruthAt M4 σ s (X χ) ↔ PlusTruthAt M4 σ (s + 1) χ := by
  constructor
  · rintro ⟨(s' : ℤ), hlt, hχ, hgap⟩
    have hlt' : (s : ℤ) < s' := hlt
    have hs' : s' = s + 1 := by
      by_contra hne
      exact hgap (s + 1) (show (s : ℤ) < s + 1 by omega) (show (s + 1 : ℤ) < s' by omega)
    rw [hs'] at hχ
    exact hχ
  · intro h
    refine ⟨s + 1, show (s : ℤ) < s + 1 by omega, h, fun (r' : ℤ) h1 h2 => ?_⟩
    have h1' : (s : ℤ) < r' := h1
    have h2' : (r' : ℤ) < s + 1 := h2
    omega

/-- Over integer time `⊥ S χ` is `χ` at the previous instant. -/
theorem truth_Y4 (σ : WorldHistory F4) (s : ℤ) (χ : PlusFormula) :
    PlusTruthAt M4 σ s (Y χ) ↔ PlusTruthAt M4 σ (s - 1) χ := by
  constructor
  · rintro ⟨(s' : ℤ), hlt, hχ, hgap⟩
    have hlt' : (s' : ℤ) < s := hlt
    have hs' : s' = s - 1 := by
      by_contra hne
      exact hgap (s - 1) (show (s' : ℤ) < s - 1 by omega) (show (s - 1 : ℤ) < s by omega)
    rw [hs'] at hχ
    exact hχ
  · intro h
    refine ⟨s - 1, show (s - 1 : ℤ) < s by omega, h, fun (r' : ℤ) h1 h2 => ?_⟩
    have h1' : (s - 1 : ℤ) < r' := h1
    have h2' : (r' : ℤ) < s := h2
    omega

/-! ### Run lemmas on `Q4`: the forced walk, idle runs, region starts -/

section Run4
variable {g : ℤ → LadderState Q4 pend4}
  (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1)
include hg

/-- **The pending walk is deterministic**: from `(true, i)` with countdown `c`, position
`m ≤ c` is pending at index `i + idx m` with countdown `c - m`. -/
theorem pending_walk4 (i : Fin 4) (c n : ℕ) (h0 : (g 0).1 = ((true, i), c, n)) :
    ∀ m : ℕ, m ≤ c → (g (m : ℤ)).1.1 = (true, i + idx m) ∧ (g (m : ℤ)).1.2.1 = c - m := by
  intro m
  induction m with
  | zero =>
    intro _
    rw [Nat.cast_zero, h0, idx_zero, add_zero]
    exact ⟨rfl, by simp⟩
  | succ m ih =>
    intro hm
    obtain ⟨hq, hc⟩ := ih (by omega)
    rw [show ((m + 1 : ℕ) : ℤ) = (m : ℤ) + 1 by push_cast; ring]
    obtain ⟨hs, -, -, hcount⟩ := (rlad4_iff _ _ _).mp (hg (m : ℤ))
    rw [hq] at hs hcount
    rw [hc] at hcount
    cases hy : (g ((m : ℤ) + 1)).1.1.1 with
    | false =>
      rw [hy, count_tf] at hcount
      omega
    | true =>
      rw [hy, count_tt] at hcount
      refine ⟨?_, by omega⟩
      have hs' : step4 (true, i + idx m) (g ((m : ℤ) + 1)).1.1 = true := hs
      rw [show (g ((m : ℤ) + 1)).1.1 = (true, (g ((m : ℤ) + 1)).1.1.2) from
        Prod.ext hy rfl] at hs' ⊢
      rw [(step4_pend_iff _ _).mp hs', idx_succ, add_assoc]

/-- **The first idle state sits at distance exactly `c + 1`**, at the index `i + idx c` the walk
has reached, with countdown `0`. -/
theorem idle_at4 (i : Fin 4) (c n : ℕ) (h0 : (g 0).1 = ((true, i), c, n)) :
    (g ((c : ℤ) + 1)).1.1 = (false, i + idx c) ∧ (g ((c : ℤ) + 1)).1.2.1 = 0 := by
  obtain ⟨hq, hc⟩ := pending_walk4 hg i c n h0 c le_rfl
  obtain ⟨hs, -, -, hcount⟩ := (rlad4_iff _ _ _).mp (hg (c : ℤ))
  rw [hq] at hs hcount
  rw [hc, Nat.sub_self] at hcount
  cases hy : (g ((c : ℤ) + 1)).1.1.1 with
  | true =>
    rw [hy, count_tt] at hcount
    omega
  | false =>
    rw [hy, count_tf] at hcount
    refine ⟨?_, hcount.1⟩
    have hs' : step4 (true, i + idx c) (g ((c : ℤ) + 1)).1.1 = true := hs
    rw [show (g ((c : ℤ) + 1)).1.1 = (false, (g ((c : ℤ) + 1)).1.1.2) from
      Prod.ext hy rfl] at hs' ⊢
    rw [(step4_pi_iff _ _).mp hs']

/-- An idle state keeps its index, and its successor is idle or starts a region whose countdown
is the idle state's next deadline (`pin_region_start`). -/
theorem after_idle4 (t : ℤ) (hidle : (g t).1.1.1 = false) :
    (g (t + 1)).1.1.2 = (g t).1.1.2 ∧
      ((g (t + 1)).1.1.1 = false ∨
        ((g (t + 1)).1.1.1 = true ∧ (g (t + 1)).1.2.1 = (g t).1.2.2)) := by
  obtain ⟨hs, -, -, hcount⟩ := (rlad4_iff _ _ _).mp (hg t)
  rw [hidle] at hcount
  have hq : (g t).1.1 = (false, (g t).1.1.2) := Prod.ext hidle rfl
  have hs' : step4 (false, (g t).1.1.2) ((g (t + 1)).1.1.1, (g (t + 1)).1.1.2) = true := by
    rw [← hq]
    exact hs
  refine ⟨(step4_idle_iff _ _ _).mp hs', ?_⟩
  cases hy : (g (t + 1)).1.1.1 with
  | false => exact Or.inl rfl
  | true =>
    rw [hy, count_ft] at hcount
    exact Or.inr ⟨rfl, hcount⟩

/-- **A region start keeps the index and takes the pin**: idle at `t`, pending at `t + 1`. -/
theorem region_start4 (t : ℤ) (hidle : (g t).1.1.1 = false) (hp : (g (t + 1)).1.1.1 = true) :
    (g (t + 1)).1.1 = (true, (g t).1.1.2) ∧ (g (t + 1)).1.2.1 = (g t).1.2.2 := by
  obtain ⟨hi, h⟩ := after_idle4 hg t hidle
  rcases h with h | ⟨-, hc⟩
  · rw [h] at hp; exact Bool.noConfusion hp
  · exact ⟨Prod.ext hp hi, hc⟩

/-- An idle run stays at its index. -/
theorem idle_run4 (t : ℤ) (hidle : (g t).1.1.1 = false) :
    (g (t + 1)).1.1.2 = (g t).1.1.2 := (after_idle4 hg t hidle).1

/-- A pending state with `1 ≤ c` is followed by a pending state. -/
theorem after_pending4 (t : ℤ) (hp : (g t).1.1.1 = true) (hc : 1 ≤ (g t).1.2.1) :
    (g (t + 1)).1.1.1 = true := by
  obtain ⟨-, -, -, hcount⟩ := (rlad4_iff _ _ _).mp (hg t)
  rw [hp] at hcount
  cases hy : (g (t + 1)).1.1.1 with
  | false =>
    rw [hy, count_tf] at hcount
    omega
  | true => rfl

/-- The next deadline is `1`-Lipschitz along the path, forward and backward. -/
theorem drift_path4 (a : ℤ) (m : ℕ) :
    (g (a + m)).1.2.2 ≤ (g a).1.2.2 + m ∧ (g a).1.2.2 ≤ (g (a + m)).1.2.2 + m := by
  induction m with
  | zero => simp
  | succ m ih =>
    obtain ⟨-, -, hd, -⟩ := (rlad4_iff _ _ _).mp (hg (a + m))
    simp only [Drift] at hd
    rw [show a + ((m + 1 : ℕ) : ℤ) = a + m + 1 by push_cast; omega]
    omega

/-- Every state of a path is admissible as a source: idle means countdown `0`. -/
theorem adm_of_path4 (t : ℤ) (hidle : (g t).1.1.1 = false) : (g t).1.2.1 = 0 :=
  ((rlad4_iff _ _ _).mp (hg t)).2.1 hidle

end Run4

/-! ### Generic history constructors -/

/-- A bi-infinite raw chain from a backward ray (`past k` the state at time `-(k + 1)`) and a
forward ray (`fut k` the state at time `k`). -/
def twoRay (past fut : ℕ → Q4 × ℕ × ℕ) (t : ℤ) : Q4 × ℕ × ℕ :=
  if t < 0 then past (-t - 1).toNat else fut t.toNat

theorem twoRay_nat (past fut : ℕ → Q4 × ℕ × ℕ) (m : ℕ) : twoRay past fut (m : ℤ) = fut m := by
  simp [twoRay]

theorem twoRay_neg (past fut : ℕ → Q4 × ℕ × ℕ) (m : ℕ) :
    twoRay past fut (-((m : ℤ) + 1)) = past m := by
  have h : -((m : ℤ) + 1) < 0 := by omega
  simp only [twoRay, h, if_true]
  congr 1
  omega

theorem twoRay_rlad (past fut : ℕ → Q4 × ℕ × ℕ)
    (hp : ∀ k, Rlad step4 pend4 0 (past (k + 1)) (past k))
    (hj : Rlad step4 pend4 0 (past 0) (fut 0))
    (hf : ∀ k, Rlad step4 pend4 0 (fut k) (fut (k + 1))) :
    ∀ t, Rlad step4 pend4 t (twoRay past fut t) (twoRay past fut (t + 1)) := by
  intro t
  have hT : Rlad step4 pend4 t (twoRay past fut t) (twoRay past fut (t + 1)) ↔
      Rlad step4 pend4 0 (twoRay past fut t) (twoRay past fut (t + 1)) := Iff.rfl
  rw [hT]
  rcases lt_trichotomy t (-1) with hlt | heq | hgt
  · have h1 : t < 0 := by omega
    have h2 : t + 1 < 0 := by omega
    simp only [twoRay, h1, h2, if_true]
    rw [show (-t - 1).toNat = (-(t + 1) - 1).toNat + 1 by omega]
    exact hp _
  · subst heq
    simp only [twoRay, show (-1 : ℤ) < 0 by norm_num, show ¬ ((-1 : ℤ) + 1 < 0) by norm_num,
      if_true, if_false, show (-(-1 : ℤ) - 1).toNat = 0 by rfl, show ((-1 : ℤ) + 1).toNat = 0 by rfl]
    exact hj
  · have h1 : ¬ t < 0 := by omega
    have h2 : ¬ t + 1 < 0 := by omega
    simp only [twoRay, h1, h2, if_false]
    rw [show (t + 1).toNat = t.toNat + 1 by omega]
    exact hf _

/-- A raw `Rlad` chain lifts to the admissible carrier: every state is the source of a step. -/
def liftAdm (raw : ℤ → Q4 × ℕ × ℕ) (h : ∀ t, Rlad step4 pend4 t (raw t) (raw (t + 1))) (t : ℤ) :
    LadderState Q4 pend4 :=
  ⟨raw t, fun h' => (h t).2.1 h'⟩

theorem liftAdm_val (raw : ℤ → Q4 × ℕ × ℕ) (h : ∀ t, Rlad step4 pend4 t (raw t) (raw (t + 1)))
    (t : ℤ) : (liftAdm raw h t).1 = raw t := rfl

theorem liftAdm_isPath (raw : ℤ → Q4 × ℕ × ℕ)
    (h : ∀ t, Rlad step4 pend4 t (raw t) (raw (t + 1))) :
    IsSlicedStepPath (RladAdm step4 pend4) 0 (liftAdm raw h) := fun t => h t

/-- Every raw `Rlad` chain is the path of a history of `F4`. -/
theorem hist_of_raw (raw : ℤ → Q4 × ℕ × ℕ)
    (h : ∀ t, Rlad step4 pend4 t (raw t) (raw (t + 1))) :
    ∃ σ : WorldHistory F4, σ.path = fun t => (t + 0, liftAdm raw h t) :=
  hist_of_path4 0 _ (liftAdm_isPath raw h)

/-- The type realized at `0` by a raw chain through `(true, i), c, n` lies in that state's
cell. -/
theorem cell_of_raw (φ : PlusFormula) (raw : ℤ → Q4 × ℕ × ℕ)
    (h : ∀ t, Rlad step4 pend4 t (raw t) (raw (t + 1))) (i : Fin 4) (c n : ℕ)
    (h0 : raw 0 = ((true, i), c, n)) :
    ∃ σ : WorldHistory F4, σ.path = (fun t => (t + 0, liftAdm raw h t)) ∧
      tpOf M4 φ σ 0 ∈ cellAt M4 φ ((0 : ℤ), st4 i c n) 0 := by
  obtain ⟨σ, hσ⟩ := hist_of_raw raw h
  refine ⟨σ, hσ, σ, ?_, rfl⟩
  have hw : ((0 : ℤ), liftAdm raw h 0) = ((0 : ℤ), st4 i c n) :=
    Prod.ext rfl (Subtype.ext h0)
  rw [← hw]
  exact congrFun hσ 0

/-- Every type in the cell of `(true, i), c, n` is the type at `0` of some sliced path through
that state. -/
theorem of_mem_cell4 (φ : PlusFormula) (i : Fin 4) (c n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M4 φ ((0 : ℤ), st4 i c n) 0) :
    ∃ (σ : WorldHistory F4) (k : ℤ) (g : ℤ → LadderState Q4 pend4),
      σ.path = (fun t => (t + k, g t)) ∧ (∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1) ∧
      (g 0).1 = ((true, i), c, n) ∧ tpOf M4 φ σ 0 = T := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path4 σ
  have hst : ((0 : ℤ) + k, g 0) = ((0 : ℤ), st4 i c n) := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  exact ⟨σ, k, g, hpath, fun t => hg t,
    congrArg (fun w : ℤ × LadderState Q4 pend4 => w.2.1) hst, rfl⟩

/-! ### The pending-forever past -/

/-- The state `k + 1` steps before `(true, i), c, n` along the backward pending walk: index
`i - idx (k + 1)`, countdown `c + k + 1`, next deadline `n`. -/
def pastRay4 (i : Fin 4) (c n : ℕ) (k : ℕ) : Q4 × ℕ × ℕ :=
  ((true, i - idx (k + 1)), c + k + 1, n)

theorem pastRay4_rlad (i : Fin 4) (c n : ℕ) :
    ∀ k, Rlad step4 pend4 0 (pastRay4 i c n (k + 1)) (pastRay4 i c n k) := by
  intro k
  rw [rlad4_iff]
  simp only [pastRay4]
  rw [idx_succ (k + 1)]
  refine ⟨?_, fun h => by simp at h, ?_, ?_⟩
  · have := step4_pend_succ (i - (idx (k + 1) + 1))
    rwa [fin_sub_succ] at this
  · simp [Drift]
  · simp [Count]
    omega

/-- The junction: the last past state steps to any forward ray starting at `(true, i), c, n`. -/
theorem pastRay4_junction (i : Fin 4) (c n : ℕ) (fut : ℕ → Q4 × ℕ × ℕ)
    (h0 : fut 0 = ((true, i), c, n)) : Rlad step4 pend4 0 (pastRay4 i c n 0) (fut 0) := by
  rw [h0, rlad4_iff]
  simp only [pastRay4]
  refine ⟨?_, fun h => by simp at h, ?_, ?_⟩
  · have h1 : idx 1 = 1 := by decide
    rw [h1]
    exact step4_pend_prev i
  · simp [Drift]
  · simp [Count]

/-- The pending-forever past glued to a forward ray starting at `(true, i), c, n`. -/
def gPast4 (i : Fin 4) (c n : ℕ) (fut : ℕ → Q4 × ℕ × ℕ) : ℤ → Q4 × ℕ × ℕ :=
  twoRay (pastRay4 i c n) fut

theorem gPast4_rlad (i : Fin 4) (c n : ℕ) (fut : ℕ → Q4 × ℕ × ℕ)
    (h0 : fut 0 = ((true, i), c, n)) (hf : ∀ k, Rlad step4 pend4 0 (fut k) (fut (k + 1))) :
    ∀ t, Rlad step4 pend4 t (gPast4 i c n fut t) (gPast4 i c n fut (t + 1)) :=
  twoRay_rlad _ _ (pastRay4_rlad i c n) (pastRay4_junction i c n fut h0) hf

theorem gPast4_nat (i : Fin 4) (c n : ℕ) (fut : ℕ → Q4 × ℕ × ℕ) (m : ℕ) :
    gPast4 i c n fut (m : ℤ) = fut m := twoRay_nat _ _ m

theorem gPast4_neg (i : Fin 4) (c n : ℕ) (fut : ℕ → Q4 × ℕ × ℕ) (m : ℕ) :
    gPast4 i c n fut (-((m : ℤ) + 1)) = ((true, i - idx (m + 1)), c + m + 1, n) :=
  twoRay_neg _ _ m

/-- The past is pending at every time `≤ 0`. -/
theorem gPast4_pending (i : Fin 4) (c n : ℕ) (fut : ℕ → Q4 × ℕ × ℕ)
    (h0 : fut 0 = ((true, i), c, n)) (z : ℤ) (hz : z ≤ 0) :
    (gPast4 i c n fut z).1.1 = true := by
  rcases lt_or_eq_of_le hz with hlt | heq
  · obtain ⟨m, hm⟩ : ∃ m : ℕ, z = -((m : ℤ) + 1) := ⟨(-z - 1).toNat, by omega⟩
    rw [hm, gPast4_neg]
  · subst heq
    rw [show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, gPast4_nat, h0]

/-! ### A region, an idle run, a region in the forward window, then idle forever -/

/-- The next deadline walking one step per step from `n` toward `L`. -/
def toward (n L m : ℕ) : ℕ :=
  if n + m ≤ L then n + m else if L + m ≤ n then n - m else L

theorem toward_zero (n L : ℕ) : toward n L 0 = n := by
  unfold toward
  split_ifs <;> omega

theorem toward_drift (n L m : ℕ) : Drift (toward n L m) (toward n L (m + 1)) := by
  unfold toward Drift
  split_ifs <;> omega

theorem toward_eq (n L m : ℕ) (h1 : L ≤ n + m) (h2 : n ≤ L + m) : toward n L m = L := by
  unfold toward
  split_ifs <;> omega

/-- From `(true, i), c, n` at `0`: the forced region (positions `0 .. c`, the deadline walking
toward `L`), an idle run of length `j` at index `i + idx c` (positions `c + 1 .. c + j`, the
deadline reaching `L` at `c + j`), a region of countdown `L` (positions `c + j + 1 ..
c + j + 1 + L`), then idle forever at index `i + idx c + idx L` with deadline `L`. -/
def region4 (i : Fin 4) (c n j L : ℕ) (m : ℕ) : Q4 × ℕ × ℕ :=
  if m ≤ c then ((true, i + idx m), c - m, toward n L m)
  else if m ≤ c + j then ((false, i + idx c), 0, toward n L m)
  else if m ≤ c + j + 1 + L then
    ((true, i + idx c + idx (m - (c + j + 1))), c + j + 1 + L - m, L)
  else ((false, i + idx c + idx L), 0, L)

theorem region4_zero (i : Fin 4) (c n j L : ℕ) : region4 i c n j L 0 = ((true, i), c, n) := by
  simp [region4, idx_zero, toward_zero]

theorem region4_pend (i : Fin 4) (c n j L m : ℕ) (hm : m ≤ c) :
    region4 i c n j L m = ((true, i + idx m), c - m, toward n L m) := by
  simp [region4, hm]

theorem region4_idle₁ (i : Fin 4) (c n j L m : ℕ) (h1 : c < m) (h2 : m ≤ c + j) :
    region4 i c n j L m = ((false, i + idx c), 0, toward n L m) := by
  have h1' : ¬ m ≤ c := by omega
  simp [region4, h1', h2]

theorem region4_pend₂ (i : Fin 4) (c n j L m : ℕ) (h1 : c + j < m) (h2 : m ≤ c + j + 1 + L) :
    region4 i c n j L m = ((true, i + idx c + idx (m - (c + j + 1))), c + j + 1 + L - m, L) := by
  have h1' : ¬ m ≤ c := by omega
  have h1'' : ¬ m ≤ c + j := by omega
  simp [region4, h1', h1'', h2]

theorem region4_idle₂ (i : Fin 4) (c n j L m : ℕ) (h : c + j + 1 + L < m) :
    region4 i c n j L m = ((false, i + idx c + idx L), 0, L) := by
  have h1' : ¬ m ≤ c := by omega
  have h1'' : ¬ m ≤ c + j := by omega
  have h1''' : ¬ m ≤ c + j + 1 + L := by omega
  simp [region4, h1', h1'', h1''']

/-- **`region4` is an `Rlad` ray** whenever the idle run is nonempty and `L` lies in the forward
window `|L - n| ≤ c + j`. -/
theorem region4_rlad (i : Fin 4) (c n j L : ℕ) (hj : 1 ≤ j) (hL1 : L ≤ n + c + j)
    (hL2 : n ≤ L + c + j) :
    ∀ m, Rlad step4 pend4 0 (region4 i c n j L m) (region4 i c n j L (m + 1)) := by
  intro m
  rw [rlad4_iff]
  rcases Nat.lt_or_ge m c with hmc | hmc
  · -- pending to pending inside the first region
    rw [region4_pend i c n j L m (by omega), region4_pend i c n j L (m + 1) (by omega)]
    refine ⟨?_, fun h => by simp at h, toward_drift n L m, ?_⟩
    · rw [idx_succ, ← add_assoc]
      exact step4_pend_succ _
    · simp [Count]
      omega
  rcases Nat.lt_or_ge m (c + j) with hmj | hmj
  · rcases Nat.eq_or_lt_of_le hmc with heq | hlt
    · -- the region ends: pending with countdown `0` to the first idle state
      rw [← heq, region4_pend i c n j L c le_rfl,
        region4_idle₁ i c n j L (c + 1) (by omega) (by omega)]
      refine ⟨step4_pend_idle _, fun h => by simp at h, toward_drift n L c, ?_⟩
      simp [Count]
    · -- idle to idle
      rw [region4_idle₁ i c n j L m hlt (by omega), region4_idle₁ i c n j L (m + 1) (by omega) hmj]
      exact ⟨step4_idle_self _, fun _ => rfl, toward_drift n L m, by simp [Count]⟩
  rcases Nat.lt_or_ge m (c + j + 1 + L) with hmL | hmL
  · rcases Nat.eq_or_lt_of_le hmj with heq | hlt
    · -- the second region starts: the pin
      rw [← heq, region4_idle₁ i c n j L (c + j) (by omega) le_rfl,
        region4_pend₂ i c n j L (c + j + 1) (by omega) (by omega)]
      rw [toward_eq n L (c + j) (by omega) (by omega), Nat.sub_self, idx_zero, add_zero]
      refine ⟨step4_idle_start _, fun _ => rfl, by simp [Drift], ?_⟩
      simp [Count]
    · -- pending to pending inside the second region
      rw [region4_pend₂ i c n j L m hlt (by omega), region4_pend₂ i c n j L (m + 1) (by omega) hmL]
      refine ⟨?_, fun h => by simp at h, by simp [Drift], ?_⟩
      · rw [show m + 1 - (c + j + 1) = m - (c + j + 1) + 1 by omega, idx_succ, ← add_assoc]
        exact step4_pend_succ _
      · simp [Count]
        omega
  rcases Nat.eq_or_lt_of_le hmL with heq | hlt
  · -- the second region ends
    rw [← heq, region4_pend₂ i c n j L (c + j + 1 + L) (by omega) le_rfl,
      region4_idle₂ i c n j L (c + j + 1 + L + 1) (by omega)]
    rw [show c + j + 1 + L - (c + j + 1) = L by omega, Nat.sub_self]
    exact ⟨step4_pend_idle _, fun h => by simp at h, by simp [Drift], by simp [Count]⟩
  · -- idle forever
    rw [region4_idle₂ i c n j L m hlt, region4_idle₂ i c n j L (m + 1) (by omega)]
    exact ⟨step4_idle_self _, fun _ => rfl, by simp [Drift], by simp [Count]⟩

/-- **Any countdown in the forward window is realized by the next region** (the `Q4` port of
`second_region_any_length`): through `(true, i), c, n` there is a history whose state at
`c + j + 1` is pending at index `i + idx c` with countdown `L`, for every `L` with
`|L - n| ≤ c + j` and every idle-run length `j ≥ 1`. -/
theorem second_region_any_length4 (i : Fin 4) (c n j L : ℕ) (hj : 1 ≤ j) (hL1 : L ≤ n + c + j)
    (hL2 : n ≤ L + c + j) :
    ∃ (σ : WorldHistory F4) (g : ℤ → LadderState Q4 pend4),
      σ.path = (fun t => (t + 0, g t)) ∧ (g 0).1 = ((true, i), c, n) ∧
      (g ((c + j + 1 : ℕ) : ℤ)).1 = ((true, i + idx c), L, L) := by
  have hr := gPast4_rlad i c n (region4 i c n j L) (region4_zero i c n j L)
    (region4_rlad i c n j L hj hL1 hL2)
  obtain ⟨σ, hσ⟩ := hist_of_raw _ hr
  refine ⟨σ, _, hσ, ?_, ?_⟩
  · rw [liftAdm_val, show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, gPast4_nat, region4_zero]
  · rw [liftAdm_val, gPast4_nat, region4_pend₂ i c n j L (c + j + 1) (by omega) (by omega),
      Nat.sub_self, idx_zero, add_zero]
    simp

/-- **Non-vacuity of the fixture**: every pending state `(true, i), c, n` lies on a history. -/
theorem exists_hist4 (i : Fin 4) (c n : ℕ) :
    ∃ σ : WorldHistory F4, σ.state 0 = ((0 : ℤ), st4 i c n) := by
  obtain ⟨σ, g, hσ, h0, -⟩ := second_region_any_length4 i c n 1 n le_rfl (by omega) (by omega)
  refine ⟨σ, ?_⟩
  rw [state_eq4 hσ 0]
  exact Prod.ext (by simp) (Subtype.ext h0)

end Fixture4

/-! ## Gates 1 and 2

Gate 1: the gap is observable at large counters — `(a, B, B+1)` admits a next region of
countdown `0` after one idle state (`L ≥ n - c - j = 0`) and `(a, B, B+2)` does not
(`forward_window`'s lower edge: `L ≥ 1`).  Gate 2: consecutive countdowns are observable through
the end letter — the forced run from `(a, c, n)` ends at index `idx c`, from `(a, c+1, n)` at
`idx (c+1)`. -/

section Gates12

/-- `p U (¬p ∧ X (p ∧ X ¬p))`: the current region ends, and the next region has length one. -/
def phi1 : PlusFormula := .untl p (p.neg.and (X (p.and (X p.neg))))

/-- The gate-1 witness: the pending-forever past, the forced region, one idle state with the
deadline walked down to `0`, a region of countdown `0`, idle forever. -/
def wit1 (B : ℕ) : ℤ → Q4 × ℕ × ℕ := gPast4 0 B (B + 1) (region4 0 B (B + 1) 1 0)

theorem wit1_rlad (B : ℕ) : ∀ t, Rlad step4 pend4 t (wit1 B t) (wit1 B (t + 1)) :=
  gPast4_rlad 0 B (B + 1) _ (region4_zero 0 B (B + 1) 1 0)
    (region4_rlad 0 B (B + 1) 1 0 le_rfl (by omega) (by omega))

theorem wit1_zero (B : ℕ) : wit1 B 0 = ((true, 0), B, B + 1) := by
  rw [wit1, show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, gPast4_nat, region4_zero]

/-- `phi1` holds at `0` along the witness. -/
theorem phi1_pos (B : ℕ) (σ : WorldHistory F4)
    (hσ : σ.path = fun t => (t + 0, liftAdm (wit1 B) (wit1_rlad B) t)) :
    PlusTruthAt M4 σ 0 phi1 := by
  refine ⟨((B + 1 : ℕ) : ℤ), show (0 : ℤ) < ((B + 1 : ℕ) : ℤ) by omega, ?_, ?_⟩
  · rw [PlusTruth.and_iff, truth_np4 hσ, truth_X4, PlusTruth.and_iff, truth_p4 hσ, truth_X4,
      truth_np4 hσ]
    rw [show ((B + 1 : ℕ) : ℤ) + 1 = ((B + 2 : ℕ) : ℤ) by push_cast; ring,
      show ((B + 2 : ℕ) : ℤ) + 1 = ((B + 3 : ℕ) : ℤ) by push_cast; ring]
    simp only [liftAdm_val, wit1, gPast4_nat]
    rw [region4_idle₁ 0 B (B + 1) 1 0 (B + 1) (by omega) (by omega),
      region4_pend₂ 0 B (B + 1) 1 0 (B + 2) (by omega) (by omega),
      region4_idle₂ 0 B (B + 1) 1 0 (B + 3) (by omega)]
    simp
  · intro (s' : ℤ) h1 h2
    have h1' : (0 : ℤ) < s' := h1
    have h2' : s' < ((B + 1 : ℕ) : ℤ) := h2
    rw [truth_p4 hσ]
    have hsn : ((s'.toNat : ℕ) : ℤ) = s' := Int.toNat_of_nonneg (by omega)
    have hle : s'.toNat ≤ B := by omega
    rw [← hsn]
    simp only [liftAdm_val, wit1, gPast4_nat]
    rw [region4_pend 0 B (B + 1) 1 0 s'.toNat hle]

/-- **Non-vacuity**: some type realized at `(a, B, B + 1)` contains `phi1`. -/
theorem exists_phi1_mem_cell (B : ℕ) :
    ∃ T ∈ cellAt M4 phi1 ((0 : ℤ), st4 0 B (B + 1)) 0, phi1 ∈ T := by
  obtain ⟨σ, hσ, hmem⟩ := cell_of_raw phi1 (wit1 B) (wit1_rlad B) 0 B (B + 1) (wit1_zero B)
  refine ⟨_, hmem, ?_⟩
  rw [mem_tpOf_iff]
  exact ⟨self_mem_plusSubformulaClosure phi1, phi1_pos B σ hσ⟩

/-- **The obstruction**: along every path through `(a, B, B + 2)` the first idle state (at
`B + 1`) carries a deadline `≥ 1` (`Drift` over `B + 1` steps from `B + 2`), so the next region
has countdown `≥ 1` (`region_start4`) and `X ¬p` fails at its first state. -/
theorem not_phi1_of_gap_two (σ : WorldHistory F4) (k : ℤ) (g : ℤ → LadderState Q4 pend4)
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1) (B : ℕ)
    (h0 : (g 0).1 = ((true, 0), B, B + 2)) : ¬ PlusTruthAt M4 σ 0 phi1 := by
  rintro ⟨(s : ℤ), hs, hχ, hguard⟩
  have hs' : (0 : ℤ) < s := hs
  rw [PlusTruth.and_iff, truth_np4 hσ] at hχ
  obtain ⟨hr, hX⟩ := hχ
  obtain ⟨hidle, -⟩ := idle_at4 hg 0 B (B + 2) h0
  rcases lt_trichotomy s ((B : ℤ) + 1) with hlt | heq | hgt
  · -- `0 < s ≤ B`: the state at `s` is pending, so `¬p` fails there
    have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg (by omega)
    have hle : s.toNat ≤ B := by omega
    obtain ⟨hq, -⟩ := pending_walk4 hg 0 B (B + 2) h0 s.toNat hle
    rw [← hsn, hq] at hr
    exact Bool.noConfusion hr
  · -- `s = B + 1`: the next region has countdown at least one
    subst heq
    rw [truth_X4, PlusTruth.and_iff, truth_p4 hσ, truth_X4, truth_np4 hσ] at hX
    obtain ⟨hp2, hr3⟩ := hX
    have hn0 : (g 0).1.2.2 = B + 2 := congrArg (fun x : Q4 × ℕ × ℕ => x.2.2) h0
    have hdr := (drift_path4 hg 0 (B + 1)).2
    rw [zero_add, hn0] at hdr
    push_cast at hdr
    have hidle' : (g ((B : ℤ) + 1)).1.1.1 = false := congrArg Prod.fst hidle
    obtain ⟨-, hc⟩ := region_start4 hg ((B : ℤ) + 1) hidle' hp2
    have := after_pending4 hg ((B : ℤ) + 1 + 1) hp2 (by omega)
    rw [this] at hr3
    exact Bool.noConfusion hr3
  · -- `s > B + 1`: the guard `p` fails at the idle state `B + 1`
    have hp := hguard ((B : ℤ) + 1) (show (0 : ℤ) < (B : ℤ) + 1 by omega) hgt
    rw [truth_p4 hσ] at hp
    have hidle' : (g ((B : ℤ) + 1)).1.1.1 = false := congrArg Prod.fst hidle
    rw [hidle'] at hp
    exact Bool.noConfusion hp

/-- Every type realized at `(a, B, B + 2)` omits `phi1`. -/
theorem phi1_not_mem_of_mem_cell (B : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M4 phi1 ((0 : ℤ), st4 0 B (B + 2)) 0) : phi1 ∉ T := by
  obtain ⟨σ, k, g, hσ, hg, h0, rfl⟩ := of_mem_cell4 phi1 0 B (B + 2) T hT
  intro hmem
  rw [mem_tpOf_iff] at hmem
  exact not_phi1_of_gap_two σ k g hσ hg B h0 hmem.2

/-- **GATE 1 — SEPARATION**: the cells at `(a, B, B + 1)` and `(a, B, B + 2)` differ, for every
`B`. -/
theorem gate1_cell_ne (B : ℕ) :
    cellAt M4 phi1 ((0 : ℤ), st4 0 B (B + 1)) 0 ≠ cellAt M4 phi1 ((0 : ℤ), st4 0 B (B + 2)) 0 := by
  intro heq
  obtain ⟨T, hT, hmem⟩ := exists_phi1_mem_cell B
  rw [heq] at hT
  exact phi1_not_mem_of_mem_cell B T hT hmem

/-- `p U (¬p ∧ ℓ (c mod 4))`: the current region ends at index `c mod 4`. -/
def phi2 (c : ℕ) : PlusFormula := .untl p (p.neg.and (ℓ (idx c)))

/-- Along EVERY path through `(a, c, n)`, `phi2 c` holds at `0`: the first idle state is at
`c + 1` with index `idx c`, and positions `1 .. c` are pending. -/
theorem phi2_of_path (σ : WorldHistory F4) (k : ℤ) (g : ℤ → LadderState Q4 pend4)
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1) (c n : ℕ)
    (h0 : (g 0).1 = ((true, 0), c, n)) : PlusTruthAt M4 σ 0 (phi2 c) := by
  obtain ⟨hidle, -⟩ := idle_at4 hg 0 c n h0
  rw [zero_add] at hidle
  refine ⟨(c : ℤ) + 1, show (0 : ℤ) < (c : ℤ) + 1 by omega, ?_, ?_⟩
  · rw [PlusTruth.and_iff, truth_np4 hσ, truth_l4 hσ, hidle]
    exact ⟨rfl, rfl⟩
  · intro (s' : ℤ) h1 h2
    have h1' : (0 : ℤ) < s' := h1
    have h2' : s' < (c : ℤ) + 1 := h2
    rw [truth_p4 hσ]
    have hsn : ((s'.toNat : ℕ) : ℤ) = s' := Int.toNat_of_nonneg (by omega)
    have hle : s'.toNat ≤ c := by omega
    obtain ⟨hq, -⟩ := pending_walk4 hg 0 c n h0 s'.toNat hle
    rw [← hsn, hq]

/-- Along EVERY path through `(a, c + 1, n)`, `phi2 c` fails at `0`: the first idle state is at
`c + 2` with index `idx (c + 1) ≠ idx c`, and no later witness has a pending guard across it. -/
theorem not_phi2_of_path (σ : WorldHistory F4) (k : ℤ) (g : ℤ → LadderState Q4 pend4)
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1) (c n : ℕ)
    (h0 : (g 0).1 = ((true, 0), c + 1, n)) : ¬ PlusTruthAt M4 σ 0 (phi2 c) := by
  rintro ⟨(s : ℤ), hs, hχ, hguard⟩
  have hs' : (0 : ℤ) < s := hs
  rw [PlusTruth.and_iff, truth_np4 hσ, truth_l4 hσ] at hχ
  obtain ⟨hr, hl⟩ := hχ
  obtain ⟨hidle, -⟩ := idle_at4 hg 0 (c + 1) n h0
  rw [zero_add] at hidle
  push_cast at hidle
  rcases lt_trichotomy s ((c : ℤ) + 1 + 1) with hlt | heq | hgt
  · -- `0 < s ≤ c + 1`: pending
    have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg (by omega)
    have hle : s.toNat ≤ c + 1 := by omega
    obtain ⟨hq, -⟩ := pending_walk4 hg 0 (c + 1) n h0 s.toNat hle
    rw [← hsn, hq] at hr
    exact Bool.noConfusion hr
  · -- `s = c + 2`: the index there is `idx (c + 1)`, not `idx c`
    subst heq
    rw [hidle] at hl
    have hl' : idx (c + 1) = idx c := hl
    rw [idx_eq_iff] at hl'
    omega
  · -- `s > c + 2`: the guard fails at the idle state `c + 2`
    have hp := hguard ((c : ℤ) + 1 + 1) (show (0 : ℤ) < (c : ℤ) + 1 + 1 by omega) hgt
    rw [truth_p4 hσ, hidle] at hp
    exact Bool.noConfusion hp

/-- **Non-vacuity**: some type realized at `(a, c, n)` contains `phi2 c`. -/
theorem exists_phi2_mem_cell (c n : ℕ) :
    ∃ T ∈ cellAt M4 (phi2 c) ((0 : ℤ), st4 0 c n) 0, phi2 c ∈ T := by
  obtain ⟨σ, hσ0⟩ := exists_hist4 0 c n
  refine ⟨tpOf M4 (phi2 c) σ 0, ⟨σ, hσ0, rfl⟩, ?_⟩
  obtain ⟨k, g, hg, hpath⟩ := hist_path4 σ
  have hst : ((0 : ℤ) + k, g 0) = ((0 : ℤ), st4 0 c n) := by
    rw [← hσ0]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, 0), c, n) :=
    congrArg (fun w : ℤ × LadderState Q4 pend4 => w.2.1) hst
  rw [mem_tpOf_iff]
  exact ⟨self_mem_plusSubformulaClosure _, phi2_of_path σ k g hpath (fun t => hg t) c n hg0⟩

/-- Every type realized at `(a, c + 1, n)` omits `phi2 c`. -/
theorem phi2_not_mem_of_mem_cell (c n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M4 (phi2 c) ((0 : ℤ), st4 0 (c + 1) n) 0) : phi2 c ∉ T := by
  obtain ⟨σ, k, g, hσ, hg, h0, rfl⟩ := of_mem_cell4 (phi2 c) 0 (c + 1) n T hT
  intro hmem
  rw [mem_tpOf_iff] at hmem
  exact not_phi2_of_path σ k g hσ hg c n h0 hmem.2

/-- **GATE 2 — SEPARATION**: the cells at `(a, c, n)` and `(a, c + 1, n)` differ, for every `c`
and `n`. -/
theorem gate2_cell_ne (c n : ℕ) :
    cellAt M4 (phi2 c) ((0 : ℤ), st4 0 c n) 0 ≠ cellAt M4 (phi2 c) ((0 : ℤ), st4 0 (c + 1) n) 0 := by
  intro heq
  obtain ⟨T, hT, hmem⟩ := exists_phi2_mem_cell c n
  rw [heq] at hT
  exact phi2_not_mem_of_mem_cell c n T hT hmem

end Gates12

end Probe820

/-! ## Axiom check -/

#print axioms Probe820.forward_window
#print axioms Probe820.backward_constraint
#print axioms Probe820.region_doubling
#print axioms Probe820.iter_doubling
#print axioms Probe820.doubling_attained
#print axioms Probe820.no_positionwise_lift
#print axioms Probe820.gate1_cell_ne
#print axioms Probe820.gate2_cell_ne
