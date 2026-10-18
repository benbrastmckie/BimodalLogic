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
| 9-sep | `(a, 0, n)` vs `(a, 0, n+m)`, `4 ∤ m`, `n ≥ 1` | `X(¬p ∧ X(p ∧ (p U (¬p ∧ ℓ ((n+2) mod 4)))))` (`phi9 n`) | SEPARATION, COMPILED (`gate9_sep_cell_ne`; `¬ 4 ∣ m` the only hypothesis on `m`, `1 ≤ n` kept from the target statement and not needed): at `c = 0, j = 1` the window is `{n-1, n, n+1}`, three of four residues, so residue `n+2` is never the next region's end index from `(a, 0, n)` (`not_phi9_of_path`) and is from `(a, 0, n+m)` for every `m ≢ 0 (mod 4)` (`exists_phi9_mem_cell`) | `forward_window` at `c = 0`; `nside_collides` (`nside-modulus-gate.lean`: the index collides at every `(T, P, B)` whose modulus is `P + 1`, so the semantic half decides) |
| short-idle | `(a, 2, 2)` vs `(a, 2 + P, 2 + P)`, `P ≥ 1` | `ψ₁ := p ∧ Y(¬p ∧ Y(p ∧ Y(¬p ∧ ¬(⊤ S p))))` (`psi1`) | SEPARATION (compiled at `k = 1`; family at the arithmetic level by `iter_doubling`, not compiled): `short_idle_cell_ne` (every `P ≥ 1`), with `short_idle_shape_collides` (the six-coordinate SHAPE agrees on the pair for every threshold `T ≤ 2` and every modulus `P' + 1` dividing the shift) and `short_idle_threshold_refuted` (both at once: a same-class pair with different cells for every `K` of the forced shape with `T ≤ 2`). The bound was COMPUTED before the pair was written: first region countdown `0`, idle run `1`, `region_doubling` at `L = 0`, `j = 1` gives `L₁ ≤ 2`, attained by `doubling_attained 0` (`growRay 0 3 = (true, 2, 2)` by `decide`) | `iter_doubling`, `doubling_attained`, `backward_constraint`, `region_doubling` |
| 9-col | `(a, 0, n)` vs `(a, 0, n+4)`, `n ≥ 2` | the closure of `phi9 n` | COLLISION, COMPILED (`gate9_col_cell_eq`: an EQUALITY of `cellAt` values) -- DECISION GATE PASSED. The closure sees one finite datum from `0` (`datum9`: position `2` idle, or the end index of the region starting there); equal data give equal types (`tpOf_eq_of_datum`, by a structural induction over the closure, `agree9`); the achievable data are `{none, some (idx (n-1)), some (idx n), some (idx (n+1))}` as a two-sided set equality (`datum_achievable`: `⊆` by the pin and `Drift`, `⊇` by `region4` with `j ∈ {1, 2}`), and the same set at `n + 4` (`datum_achievable_shift`); the past is the pending-forever past throughout. No contingency taken | `forward_window`; `second_region_any_length`; per-member truth lemmas |
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

/-! ## Gate 9, separation

The n-side separation at `c = 0`, `j = 1`: on a fixture of product period `4` the forward window
`{n - 1, n, n + 1}` covers three of four residues, so a shift `m` with `4 ∤ m` is observable.
The index-level collision half is `nside_collides` (`nside-modulus-gate.lean`: the six-coordinate
shape collides on the n-side shift at EVERY `(T, P, B)` whose modulus is `P + 1`); it is cited,
not re-proved, and the semantic half below decides: `K`'s `n`-modulus must be a multiple of the
product period. -/

section Gate9Sep

/-! ### Run lemmas from an arbitrary origin (the gates read the NEXT region) -/

section Run4Shift
variable {g : ℤ → LadderState Q4 pend4}
  (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1)
include hg

theorem shift4 (a : ℤ) :
    ∀ t, Rlad step4 pend4 t ((fun t => g (t + a)) t).1 ((fun t => g (t + a)) (t + 1)).1 := by
  intro t
  have := hg (t + a)
  rw [show t + a + 1 = t + 1 + a by ring] at this
  exact this

/-- `pending_walk4` from the origin `a`. -/
theorem pending_walk4_at (a : ℤ) (i : Fin 4) (c n : ℕ) (h0 : (g a).1 = ((true, i), c, n)) :
    ∀ m : ℕ, m ≤ c →
      (g (a + m)).1.1 = (true, i + idx m) ∧ (g (a + m)).1.2.1 = c - m := by
  intro m hm
  have h0' : ((fun t => g (t + a)) 0).1 = ((true, i), c, n) := by
    simp only [zero_add]
    exact h0
  have := pending_walk4 (shift4 hg a) i c n h0' m hm
  rw [show a + (m : ℤ) = (m : ℤ) + a by ring]
  exact this

/-- `idle_at4` from the origin `a`. -/
theorem idle_at4_at (a : ℤ) (i : Fin 4) (c n : ℕ) (h0 : (g a).1 = ((true, i), c, n)) :
    (g (a + c + 1)).1.1 = (false, i + idx c) ∧ (g (a + c + 1)).1.2.1 = 0 := by
  have h0' : ((fun t => g (t + a)) 0).1 = ((true, i), c, n) := by
    simp only [zero_add]
    exact h0
  have := idle_at4 (shift4 hg a) i c n h0'
  rw [show a + (c : ℤ) + 1 = (c : ℤ) + 1 + a by ring]
  exact this

end Run4Shift

/-- `X (¬p ∧ X (p ∧ (p U (¬p ∧ ℓ ((n + 2) mod 4)))))`: after one idle state the next region
starts and ends at index `(n + 2) mod 4`. -/
def phi9 (n : ℕ) : PlusFormula :=
  X (p.neg.and (X (p.and (.untl p (p.neg.and (ℓ (idx (n + 2))))))))

/-- The gate-9 witness at `(a, 0, n + m)`: one idle state, then a region of countdown `L`. -/
def wit9 (n m L : ℕ) : ℤ → Q4 × ℕ × ℕ := gPast4 0 0 (n + m) (region4 0 0 (n + m) 1 L)

theorem wit9_rlad (n m L : ℕ) (hL1 : L ≤ n + m + 1) (hL2 : n + m ≤ L + 1) :
    ∀ t, Rlad step4 pend4 t (wit9 n m L t) (wit9 n m L (t + 1)) :=
  gPast4_rlad 0 0 (n + m) _ (region4_zero 0 0 (n + m) 1 L)
    (region4_rlad 0 0 (n + m) 1 L le_rfl (by omega) (by omega))

theorem wit9_zero (n m L : ℕ) : wit9 n m L 0 = ((true, 0), 0, n + m) := by
  rw [wit9, show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, gPast4_nat, region4_zero]

/-- `phi9 n` holds at `0` along the witness whenever `L ≡ n + 2 (mod 4)`. -/
theorem phi9_pos (n m L : ℕ) (hL1 : L ≤ n + m + 1) (hL2 : n + m ≤ L + 1)
    (hLr : L % 4 = (n + 2) % 4) (σ : WorldHistory F4)
    (hσ : σ.path = fun t => (t + 0, liftAdm (wit9 n m L) (wit9_rlad n m L hL1 hL2) t)) :
    PlusTruthAt M4 σ 0 (phi9 n) := by
  rw [phi9, truth_X4, PlusTruth.and_iff, truth_np4 hσ, truth_X4, PlusTruth.and_iff, truth_p4 hσ]
  rw [show (0 : ℤ) + 1 = ((1 : ℕ) : ℤ) by norm_num, show ((1 : ℕ) : ℤ) + 1 = ((2 : ℕ) : ℤ) by norm_num]
  refine ⟨?_, ?_, ((L + 3 : ℕ) : ℤ), show ((2 : ℕ) : ℤ) < ((L + 3 : ℕ) : ℤ) by omega, ?_, ?_⟩
  · simp only [liftAdm_val, wit9, gPast4_nat]
    rw [region4_idle₁ 0 0 (n + m) 1 L 1 (by omega) (by omega)]
  · simp only [liftAdm_val, wit9, gPast4_nat]
    rw [region4_pend₂ 0 0 (n + m) 1 L 2 (by omega) (by omega)]
  · rw [PlusTruth.and_iff, truth_np4 hσ, truth_l4 hσ]
    simp only [liftAdm_val, wit9, gPast4_nat]
    rw [region4_idle₂ 0 0 (n + m) 1 L (L + 3) (by omega)]
    refine ⟨rfl, ?_⟩
    show 0 + idx 0 + idx L = idx (n + 2)
    rw [idx_zero, add_zero, zero_add, idx_eq_iff]
    exact hLr
  · intro (r : ℤ) h1 h2
    have h1' : ((2 : ℕ) : ℤ) < r := h1
    have h2' : r < ((L + 3 : ℕ) : ℤ) := h2
    rw [truth_p4 hσ]
    have hrn : ((r.toNat : ℕ) : ℤ) = r := Int.toNat_of_nonneg (by omega)
    rw [← hrn]
    simp only [liftAdm_val, wit9, gPast4_nat]
    rw [region4_pend₂ 0 0 (n + m) 1 L r.toNat (by omega) (by omega)]

/-- **Non-vacuity**: for every shift `m` with `4 ∤ m`, some type realized at `(a, 0, n + m)`
contains `phi9 n` — the next region's countdown is chosen in the window `{n+m-1, n+m, n+m+1}`
with residue `n + 2`. -/
theorem exists_phi9_mem_cell (n m : ℕ) (hm : ¬ 4 ∣ m) :
    ∃ T ∈ cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 (n + m)) 0, phi9 n ∈ T := by
  have hL : ∃ L, L ≤ n + m + 1 ∧ n + m ≤ L + 1 ∧ L % 4 = (n + 2) % 4 := by
    have h4 : m % 4 = 1 ∨ m % 4 = 2 ∨ m % 4 = 3 := by omega
    rcases h4 with h | h | h
    · exact ⟨n + m + 1, le_rfl, by omega, by omega⟩
    · exact ⟨n + m, by omega, by omega, by omega⟩
    · exact ⟨n + m - 1, by omega, by omega, by omega⟩
  obtain ⟨L, hL1, hL2, hLr⟩ := hL
  obtain ⟨σ, hσ, hmem⟩ :=
    cell_of_raw (phi9 n) (wit9 n m L) (wit9_rlad n m L hL1 hL2) 0 0 (n + m) (wit9_zero n m L)
  refine ⟨_, hmem, ?_⟩
  rw [mem_tpOf_iff]
  exact ⟨self_mem_plusSubformulaClosure _, phi9_pos n m L hL1 hL2 hLr σ hσ⟩

/-- **The obstruction**: along every path through `(a, 0, n)` with `1 ≤ n`, position `1` is
idle, position `2` (if pending) starts a region whose countdown `L'` is the deadline at `1`, so
`L' ∈ {n - 1, n, n + 1}` (`forward_window` at `c = 0`, `j = 1`) and the first idle state after it
has index `idx L' ≠ idx (n + 2)`. -/
theorem not_phi9_of_path (σ : WorldHistory F4) (k : ℤ) (g : ℤ → LadderState Q4 pend4)
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1) (n : ℕ)
    (h0 : (g 0).1 = ((true, 0), 0, n)) : ¬ PlusTruthAt M4 σ 0 (phi9 n) := by
  intro h
  rw [phi9, truth_X4, PlusTruth.and_iff, truth_np4 hσ, truth_X4, PlusTruth.and_iff,
    truth_p4 hσ] at h
  rw [show (0 : ℤ) + 1 = 1 by norm_num, show (1 : ℤ) + 1 = 2 by norm_num] at h
  obtain ⟨-, hp2, (s : ℤ), hs, hD, hguard⟩ := h
  have hs' : (2 : ℤ) < s := hs
  -- position `1` is idle at index `0`, position `2` starts a region with the pin
  obtain ⟨hidle1, -⟩ := idle_at4 hg 0 0 n h0
  simp only [Nat.cast_zero, zero_add] at hidle1
  have hidle1' : (g 1).1.1.1 = false := congrArg Prod.fst hidle1
  obtain ⟨hq2, hc2⟩ := region_start4 hg 1 hidle1' (by rw [show (1 : ℤ) + 1 = 2 by norm_num]; exact hp2)
  rw [show (1 : ℤ) + 1 = 2 by norm_num] at hq2 hc2
  rw [hidle1] at hq2
  -- the deadline at `1` lies in the window
  have hn0 : (g 0).1.2.2 = n := congrArg (fun x : Q4 × ℕ × ℕ => x.2.2) h0
  have hdr := drift_path4 hg 0 1
  simp only [Nat.cast_one, zero_add, hn0] at hdr
  -- the run from `2`
  have h2 : (g 2).1 = ((true, 0), (g 1).1.2.2, (g 2).1.2.2) := by
    rw [← hc2]
    exact Prod.ext hq2 rfl
  obtain ⟨hidleE, -⟩ := idle_at4_at hg 2 0 (g 1).1.2.2 _ h2
  rw [zero_add] at hidleE
  rw [PlusTruth.and_iff, truth_np4 hσ, truth_l4 hσ] at hD
  obtain ⟨hDp, hDl⟩ := hD
  rcases lt_trichotomy s (2 + ((g 1).1.2.2 : ℤ) + 1) with hlt | heq | hgt
  · -- `2 < s ≤ 2 + L'`: pending
    have hsn : (((s - 2).toNat : ℕ) : ℤ) = s - 2 := Int.toNat_of_nonneg (by omega)
    have hle : (s - 2).toNat ≤ (g 1).1.2.2 := by omega
    obtain ⟨hq, -⟩ := pending_walk4_at hg 2 0 (g 1).1.2.2 _ h2 (s - 2).toNat hle
    rw [hsn, show (2 : ℤ) + (s - 2) = s by ring] at hq
    rw [hq] at hDp
    exact Bool.noConfusion hDp
  · -- `s = 3 + L'`: the index there is `idx L'`, and `L' ≡ n + 2` is impossible in the window
    subst heq
    rw [hidleE] at hDl
    have hl' : idx (g 1).1.2.2 = idx (n + 2) := hDl
    rw [idx_eq_iff] at hl'
    omega
  · -- `s > 3 + L'`: the guard fails at the idle state `3 + L'`
    have hp := hguard (2 + ((g 1).1.2.2 : ℤ) + 1)
      (show (2 : ℤ) < 2 + ((g 1).1.2.2 : ℤ) + 1 by omega) hgt
    rw [truth_p4 hσ, hidleE] at hp
    exact Bool.noConfusion hp

/-- Every type realized at `(a, 0, n)` omits `phi9 n`. -/
theorem phi9_not_mem_of_mem_cell (n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 n) 0) : phi9 n ∉ T := by
  obtain ⟨σ, k, g, hσ, hg, h0, rfl⟩ := of_mem_cell4 (phi9 n) 0 0 n T hT
  intro hmem
  rw [mem_tpOf_iff] at hmem
  exact not_phi9_of_path σ k g hσ hg n h0 hmem.2

set_option linter.unusedVariables false in
/-- **GATE 9, SEPARATION HALF — SEPARATION**: the cells at `(a, 0, n)` and `(a, 0, n + m)`
differ for every `n ≥ 1` and every shift `m` that is not a multiple of the product period
`4`.  `¬ 4 ∣ m` is the only hypothesis on `m`.  The hypothesis `1 ≤ n` is the target statement's
and is kept verbatim; the fixture obstruction does not need it (at `n = 0` the window is
`{0, 1}`, which also misses residue `2`), so the linter is silenced for this one declaration
rather than the statement widened silently. -/
theorem gate9_sep_cell_ne (n m : ℕ) (hn : 1 ≤ n) (hm : ¬ 4 ∣ m) :
    cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 n) 0 ≠ cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 (n + m)) 0 := by
  intro heq
  obtain ⟨T, hT, hmem⟩ := exists_phi9_mem_cell n m hm
  rw [← heq] at hT
  exact phi9_not_mem_of_mem_cell n T hT hmem

end Gate9Sep

/-! ## The short-idle gate (exponential threshold)

A formula pinning a rigid past — idle forever, one pending state, an idle run of length `1`,
then the current region starting now — bounds the current region's countdown: with the first
region's countdown `0` and the idle run `1`, `region_doubling` at `L = 0`, `j = 1` gives
`L₁ ≤ 2·0 + 1 + 1 = 2`, attained (`doubling_attained` at `L = 0`; on `Q4`,
`growRay 0 3 = (true, 2, 2)` by `decide` below).  So the bound is COMPUTED, not guessed: the pair
is `(a, 2, 2)` vs `(a, 2 + P, 2 + P)`, and every `K` of the forced shape whose countdown
threshold is `≤ 2` identifies the two (`short_idle_shape_collides`, a SHAPE statement on the
index body in the sense of `nside-modulus-gate.lean`) while their cells differ
(`short_idle_cell_ne`). -/

section ShortIdle

/-- The hand computation, checked: the maximal-growth ray from an idle end with deadline `0`
reaches countdown `2` three steps later. -/
example : growRay 0 3 = (true, 2, 2) := by decide

/-- `⊤ S p`: some strictly earlier position is pending. -/
theorem truth_Sp4 (σ : WorldHistory F4) (s : ℤ) :
    PlusTruthAt M4 σ s (.snce PlusFormula.top p) ↔ ∃ s' : ℤ, s' < s ∧ PlusTruthAt M4 σ s' p := by
  constructor
  · rintro ⟨(s' : ℤ), h1, h2, -⟩
    exact ⟨s', h1, h2⟩
  · rintro ⟨s', h1, h2⟩
    exact ⟨s', h1, h2, fun _ _ _ => PlusTruth.top_true _ _ _⟩

/-- `p ∧ Y (¬p ∧ Y (p ∧ Y (¬p ∧ ¬(⊤ S p))))`: the current region starts now, the previous idle
run has length `1`, before it a single pending state, before that idle forever. -/
def psi1 : PlusFormula :=
  p.and (Y (p.neg.and (Y (p.and (Y (p.neg.and (PlusFormula.snce PlusFormula.top p).neg))))))

/-- The rigid past of the witness: time `-1` idle with deadline `2`, time `-2` the single
pending state (countdown `0`, deadline `1`), time `-3` idle with deadline `0`, idle with
deadline `0` forever before. -/
def pastSI (k : ℕ) : Q4 × ℕ × ℕ :=
  if k = 0 then ((false, 0), 0, 2) else if k = 1 then ((true, 0), 0, 1) else ((false, 0), 0, 0)

theorem pastSI_rlad : ∀ k, Rlad step4 pend4 0 (pastSI (k + 1)) (pastSI k) := by
  intro k
  rcases k with _ | _ | k
  · simp [pastSI, rlad4_iff, step4, Drift, Count]
  · simp [pastSI, rlad4_iff, step4, Drift, Count]
  · simp [pastSI, rlad4_iff, step4, Drift, Count]

/-- The witness: the rigid past, then from `(a, 2, 2)` the forced region and a free future. -/
def witSI : ℤ → Q4 × ℕ × ℕ := twoRay pastSI (region4 0 2 2 1 2)

theorem witSI_rlad : ∀ t, Rlad step4 pend4 t (witSI t) (witSI (t + 1)) :=
  twoRay_rlad _ _ pastSI_rlad
    (by rw [region4_zero]; simp [pastSI, rlad4_iff, step4, Drift, Count])
    (region4_rlad 0 2 2 1 2 le_rfl (by omega) (by omega))

theorem witSI_zero : witSI 0 = ((true, 0), 2, 2) := by
  rw [witSI, show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, twoRay_nat, region4_zero]

theorem witSI_neg (m : ℕ) : witSI (-((m : ℤ) + 1)) = pastSI m := twoRay_neg _ _ m

/-- `psi1` holds at `0` along the witness. -/
theorem psi1_pos (σ : WorldHistory F4)
    (hσ : σ.path = fun t => (t + 0, liftAdm witSI witSI_rlad t)) :
    PlusTruthAt M4 σ 0 psi1 := by
  rw [psi1, PlusTruth.and_iff, truth_p4 hσ, truth_Y4, PlusTruth.and_iff, truth_np4 hσ, truth_Y4,
    PlusTruth.and_iff, truth_p4 hσ, truth_Y4, PlusTruth.and_iff, truth_np4 hσ, PlusTruth.neg_iff,
    truth_Sp4]
  rw [show (0 : ℤ) - 1 = -(((0 : ℕ) : ℤ) + 1) by norm_num,
    show -(((0 : ℕ) : ℤ) + 1) - 1 = -(((1 : ℕ) : ℤ) + 1) by norm_num,
    show -(((1 : ℕ) : ℤ) + 1) - 1 = -(((2 : ℕ) : ℤ) + 1) by norm_num]
  simp only [liftAdm_val, witSI_zero, witSI_neg]
  refine ⟨trivial, by simp [pastSI], by simp [pastSI], by simp [pastSI], ?_⟩
  rintro ⟨s', hs', hp⟩
  rw [truth_p4 hσ] at hp
  obtain ⟨m, hm⟩ : ∃ m : ℕ, s' = -((m : ℤ) + 1) ∧ 3 ≤ m := ⟨(-s' - 1).toNat, by omega, by omega⟩
  rw [hm.1, liftAdm_val, witSI_neg] at hp
  have h0 : m ≠ 0 := by omega
  have h1 : m ≠ 1 := by omega
  simp [pastSI, h0, h1] at hp

/-- **Non-vacuity**: some type realized at `(a, 2, 2)` contains `psi1`. -/
theorem exists_psi1_mem_cell : ∃ T ∈ cellAt M4 psi1 ((0 : ℤ), st4 0 2 2) 0, psi1 ∈ T := by
  obtain ⟨σ, hσ, hmem⟩ := cell_of_raw psi1 witSI witSI_rlad 0 2 2 witSI_zero
  refine ⟨_, hmem, ?_⟩
  rw [mem_tpOf_iff]
  exact ⟨self_mem_plusSubformulaClosure _, psi1_pos σ hσ⟩

/-- **The obstruction**: along any path through `(a, c, n)` on which `psi1` holds at `0`, the
single pending state at `-2` has countdown `0` (`pin_region_end`), so the deadline at `-3` is `0`
(`pin_region_start`), the deadline at `-1` is at most `2` (`Drift` over two steps), and the pin
at the region start makes `c ≤ 2` (`region_doubling` with `L = 0`, `j = 1`, read off the
pins). -/
theorem countdown_le_two_of_psi1 (σ : WorldHistory F4) (k : ℤ) (g : ℤ → LadderState Q4 pend4)
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1) (c n : ℕ)
    (h0 : (g 0).1 = ((true, 0), c, n)) (h : PlusTruthAt M4 σ 0 psi1) : c ≤ 2 := by
  rw [psi1, PlusTruth.and_iff, truth_p4 hσ, truth_Y4, PlusTruth.and_iff, truth_np4 hσ, truth_Y4,
    PlusTruth.and_iff, truth_p4 hσ, truth_Y4, PlusTruth.and_iff, truth_np4 hσ] at h
  obtain ⟨hp0, hi1, hp2, hi3, -⟩ := h
  rw [show (0 : ℤ) - 1 = -1 by norm_num] at hi1
  rw [show (0 : ℤ) - 1 - 1 = -2 by norm_num] at hp2
  rw [show (0 : ℤ) - 1 - 1 - 1 = -3 by norm_num] at hi3
  -- the pin at the current region's start: `c` is the deadline at `-1`
  obtain ⟨-, hc0⟩ := region_start4 hg (-1) hi1 (by rw [show (-1 : ℤ) + 1 = 0 by norm_num]; exact hp0)
  rw [show (-1 : ℤ) + 1 = 0 by norm_num, h0] at hc0
  -- the pending state at `-2` ends its region: countdown `0`
  have hend := pin_region_end step4 pend4 (-2) _ _ (hg (-2)) hp2
    (by rw [show (-2 : ℤ) + 1 = -1 by norm_num]; exact hi1)
  -- the pin at `-3`: the deadline there is that countdown
  obtain ⟨-, hc2⟩ := region_start4 hg (-3) hi3 (by rw [show (-3 : ℤ) + 1 = -2 by norm_num]; exact hp2)
  rw [show (-3 : ℤ) + 1 = -2 by norm_num] at hc2
  -- `Drift` over the two steps from `-3` to `-1`
  have hdr := (drift_path4 hg (-3) 2).1
  rw [show (-3 : ℤ) + ((2 : ℕ) : ℤ) = -1 by norm_num] at hdr
  simp only at hc0 hend hc2 hdr
  omega

/-- Every type realized at `(a, 2 + P, 2 + P)` with `1 ≤ P` omits `psi1`. -/
theorem psi1_not_mem_of_mem_cell (P : ℕ) (hP : 1 ≤ P) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M4 psi1 ((0 : ℤ), st4 0 (2 + P) (2 + P)) 0) : psi1 ∉ T := by
  obtain ⟨σ, k, g, hσ, hg, h0, rfl⟩ := of_mem_cell4 psi1 0 (2 + P) (2 + P) T hT
  intro hmem
  rw [mem_tpOf_iff] at hmem
  have := countdown_le_two_of_psi1 σ k g hσ hg (2 + P) (2 + P) h0 hmem.2
  omega

/-- **THE SHORT-IDLE GATE — SEPARATION** at `k = 1`: the cells at `(a, 2, 2)` and
`(a, 2 + P, 2 + P)` differ for every `P ≥ 1`. -/
theorem short_idle_cell_ne (P : ℕ) (hP : 1 ≤ P) :
    cellAt M4 psi1 ((0 : ℤ), st4 0 2 2) 0 ≠ cellAt M4 psi1 ((0 : ℤ), st4 0 (2 + P) (2 + P)) 0 := by
  intro heq
  obtain ⟨T, hT, hmem⟩ := exists_psi1_mem_cell
  rw [heq] at hT
  exact psi1_not_mem_of_mem_cell P hP T hT hmem

/-! ### The class-collision companion, on the index BODY as a shape

Ported from `specs/evidence/seam-gluing-ray-product/nside-modulus-gate.lean` with the statement
unchanged.  This is a statement about a SHAPE gated for a carrier coordinate, in that probe's
own sense: the six-coordinate body belongs to a REFUTED candidate and is not revived as an
index; no tuple index is stated as a candidate at any parameters. -/

/-- The six-coordinate shape `(q, min c T, c mod (P+1), min n T, n mod (P+1), clip (n - c))`,
byte-for-byte the body of `nside-modulus-gate.lean`'s `ladderIndexJnt`. -/
def ladderIndexJnt (T P B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) × Fin (2 * B + 1) :=
  (x.1.1,
    ⟨min x.1.2.1 T, by omega⟩,
    ⟨x.1.2.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min x.1.2.2 T, by omega⟩,
    ⟨x.1.2.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-- **The shape collides on the short-idle pair for every threshold `T ≤ 2`** and every modulus
`P' + 1` dividing the shift `P`: both countdowns and both deadlines saturate `T`, the residues
agree because the shift is a multiple of the modulus, and both clipped gaps are `B`. -/
theorem short_idle_shape_collides (T P' B P : ℕ) (hT : T ≤ 2) (hP : (P' + 1) ∣ P) :
    ladderIndexJnt T P' B (st4 0 2 2) = ladderIndexJnt T P' B (st4 0 (2 + P) (2 + P)) := by
  obtain ⟨q, rfl⟩ := hP
  simp only [ladderIndexJnt, st4, Prod.mk.injEq, Fin.mk.injEq, true_and]
  refine ⟨by omega, ?_, by omega, ?_, by omega⟩ <;>
    rw [show 2 + (P' + 1) * q = 2 + q * (P' + 1) by ring, Nat.add_mul_mod_self_right]

/-- **The two together**: for every `K` of the forced six-coordinate shape with countdown
threshold `T ≤ 2`, whatever its modulus and clip, the pair `(a, 2, 2)` / `(a, 2 + (P' + 1),
2 + (P' + 1))` is a same-class pair with different cells — the threshold is a cascade OUTPUT
(`region_doubling` iterated: `iter_doubling`), at least exponential in the depth of the rigid
past, never a formula-depth guess. -/
theorem short_idle_threshold_refuted (T P' B : ℕ) (hT : T ≤ 2) :
    ladderIndexJnt T P' B (st4 0 2 2) = ladderIndexJnt T P' B (st4 0 (2 + (P' + 1)) (2 + (P' + 1))) ∧
      cellAt M4 psi1 ((0 : ℤ), st4 0 2 2) 0 ≠
        cellAt M4 psi1 ((0 : ℤ), st4 0 (2 + (P' + 1)) (2 + (P' + 1))) 0 :=
  ⟨short_idle_shape_collides T P' B (P' + 1) hT (dvd_refl _), short_idle_cell_ne (P' + 1) (by omega)⟩

end ShortIdle

/-! ## Gate 9, collision (DECISION GATE)

The closure of `phi9 n` at position `0` of a path through `(a, 0, n)` sees exactly one thing
beyond `n mod 4`: whether position `2` is pending and, if so, the end index of the region it
starts (`datum9`).  Two paths with equal data have equal types (`tpOf_eq_of_datum`); the data
achievable from `(a, 0, n)` form the set `{none, some (idx (n-1)), some (idx n), some (idx (n+1))}`
(`datum_achievable`, a two-sided set equality), which is the same set at `n + 4`; hence the
cells are EQUAL (`gate9_col_cell_eq`).  The past is replaced by a pending-forever past
throughout: the closure is `snce`-free. -/

section Gate9Col

/-- The raw constructor forms of the closure members, so that `simp` on
`PlusFormula.subformulas` matches them. -/
abbrev negp : PlusFormula := .imp (.atom pA) .bot
abbrev andF (a b : PlusFormula) : PlusFormula := .imp (.imp a (.imp b .bot)) .bot
abbrev Draw (r : Fin 4) : PlusFormula := andF negp (.atom (lA r))
abbrev Craw (r : Fin 4) : PlusFormula := .untl (.atom pA) (Draw r)
abbrev Braw (r : Fin 4) : PlusFormula := andF (.atom pA) (Craw r)
abbrev XBraw (r : Fin 4) : PlusFormula := .untl .bot (Braw r)
abbrev Araw (r : Fin 4) : PlusFormula := andF negp (XBraw r)
abbrev phi9raw (r : Fin 4) : PlusFormula := .untl .bot (Araw r)

theorem phi9_eq_raw (n : ℕ) : phi9 n = phi9raw (idx (n + 2)) := rfl

/-- The finite datum the closure sees from position `0`: `none` if position `2` is idle, else
the end index of the region starting there (`idx` of its countdown; the start index is `0`). -/
def datum9 (g : ℤ → LadderState Q4 pend4) : Option (Fin 4) :=
  if (g 2).1.1.1 = true then some (idx (g 2).1.2.1) else none

section Truth9
variable {σ : WorldHistory F4} {k : ℤ} {g : ℤ → LadderState Q4 pend4}
  (hσ : σ.path = fun t => (t + k, g t))
  (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1)
include hσ

theorem truth_atom_p (s : ℤ) : PlusTruthAt M4 σ s (.atom pA) ↔ (g s).1.1.1 = true :=
  truth_p4 hσ s

theorem truth_atom_l (s : ℤ) (i : Fin 4) :
    PlusTruthAt M4 σ s (.atom (lA i)) ↔ (g s).1.1.2 = i :=
  truth_l4 hσ s i

theorem truth_Draw (s : ℤ) (r : Fin 4) :
    PlusTruthAt M4 σ s (Draw r) ↔ (g s).1.1.1 = false ∧ (g s).1.1.2 = r := by
  show PlusTruthAt M4 σ s (p.neg.and (ℓ r)) ↔ _
  rw [PlusTruth.and_iff, truth_np4 hσ, truth_l4 hσ]

theorem truth_Braw (s : ℤ) (r : Fin 4) :
    PlusTruthAt M4 σ s (Braw r) ↔ (g s).1.1.1 = true ∧ PlusTruthAt M4 σ s (Craw r) := by
  show PlusTruthAt M4 σ s (p.and (Craw r)) ↔ _
  rw [PlusTruth.and_iff, truth_p4 hσ]

theorem truth_Araw (s : ℤ) (r : Fin 4) :
    PlusTruthAt M4 σ s (Araw r) ↔ (g s).1.1.1 = false ∧ PlusTruthAt M4 σ (s + 1) (Braw r) := by
  show PlusTruthAt M4 σ s (p.neg.and (X (Braw r))) ↔ _
  rw [PlusTruth.and_iff, truth_np4 hσ, truth_X4]

include hg

/-- **`C` at a pending position reads the end index of the region there**: from `(true, i)` with
countdown `L'` at time `a`, `p U (¬p ∧ ℓ r)` holds iff the first idle state after the region,
at index `i + idx L'`, carries `ℓ r`. -/
theorem truth_Craw_at (a : ℤ) (i : Fin 4) (L' n2 : ℕ) (ha : (g a).1 = ((true, i), L', n2))
    (r : Fin 4) : PlusTruthAt M4 σ a (Craw r) ↔ i + idx L' = r := by
  obtain ⟨hidle, -⟩ := idle_at4_at hg a i L' n2 ha
  constructor
  · rintro ⟨(s : ℤ), hs, hD, hguard⟩
    have hs' : a < s := hs
    rw [truth_Draw hσ] at hD
    obtain ⟨hDp, hDl⟩ := hD
    rcases lt_trichotomy s (a + L' + 1) with hlt | heq | hgt
    · have hsn : (((s - a).toNat : ℕ) : ℤ) = s - a := Int.toNat_of_nonneg (by omega)
      have hle : (s - a).toNat ≤ L' := by omega
      obtain ⟨hq, -⟩ := pending_walk4_at hg a i L' n2 ha (s - a).toNat hle
      rw [hsn, show a + (s - a) = s by ring] at hq
      rw [hq] at hDp
      exact Bool.noConfusion hDp
    · subst heq
      rw [hidle] at hDl
      exact hDl
    · have hp := hguard (a + L' + 1) (show a < a + L' + 1 by omega) hgt
      rw [truth_atom_p hσ, hidle] at hp
      exact Bool.noConfusion hp
  · intro hr
    refine ⟨a + L' + 1, show a < a + L' + 1 by omega, ?_, ?_⟩
    · rw [truth_Draw hσ, hidle]
      exact ⟨rfl, hr⟩
    · intro (s : ℤ) h1 h2
      have h1' : a < s := h1
      have h2' : s < a + L' + 1 := h2
      rw [truth_atom_p hσ]
      have hsn : (((s - a).toNat : ℕ) : ℤ) = s - a := Int.toNat_of_nonneg (by omega)
      have hle : (s - a).toNat ≤ L' := by omega
      obtain ⟨hq, -⟩ := pending_walk4_at hg a i L' n2 ha (s - a).toNat hle
      rw [hsn, show a + (s - a) = s by ring] at hq
      rw [hq]

variable {m : ℕ} (h0 : (g 0).1 = ((true, 0), 0, m))
include h0

omit hg in
/-- At `0`, `p` holds. -/
theorem at0_p : PlusTruthAt M4 σ 0 (.atom pA) ↔ True := by
  rw [truth_atom_p hσ, h0]
  simp

omit hg in
/-- At `0`, `ℓ i` holds iff `i = 0`. -/
theorem at0_l (i : Fin 4) : PlusTruthAt M4 σ 0 (.atom (lA i)) ↔ i = 0 := by
  rw [truth_atom_l hσ, h0]
  exact eq_comm

/-- At `0`, `C` holds iff `r = 0` (the region ends at once, at index `0`). -/
theorem at0_C (r : Fin 4) : PlusTruthAt M4 σ 0 (Craw r) ↔ r = 0 := by
  rw [truth_Craw_at hσ hg 0 0 0 m h0 r, idx_zero, add_zero]
  exact eq_comm

/-- At `0`, `X B` fails: position `1` is idle. -/
theorem at0_XB (r : Fin 4) : PlusTruthAt M4 σ 0 (XBraw r) ↔ False := by
  show PlusTruthAt M4 σ 0 (X (Braw r)) ↔ _
  rw [truth_X4, truth_Braw hσ, show (0 : ℤ) + 1 = 1 by norm_num]
  obtain ⟨hidle, -⟩ := idle_at4 hg 0 0 m h0
  simp only [Nat.cast_zero, zero_add] at hidle
  rw [hidle]
  simp

/-- At `0`, `phi9` holds iff the datum is `some r`. -/
theorem at0_phi (r : Fin 4) : PlusTruthAt M4 σ 0 (phi9raw r) ↔ datum9 g = some r := by
  show PlusTruthAt M4 σ 0 (X (Araw r)) ↔ _
  rw [truth_X4, truth_Araw hσ, truth_Braw hσ]
  rw [show (0 : ℤ) + 1 = 1 by norm_num, show (1 : ℤ) + 1 = 2 by norm_num]
  obtain ⟨hidle, -⟩ := idle_at4 hg 0 0 m h0
  simp only [Nat.cast_zero, zero_add] at hidle
  have hidle' : (g 1).1.1.1 = false := congrArg Prod.fst hidle
  unfold datum9
  constructor
  · rintro ⟨-, hp2, hC⟩
    obtain ⟨hq2, -⟩ := region_start4 hg 1 hidle' (by rw [show (1 : ℤ) + 1 = 2 by norm_num]; exact hp2)
    rw [show (1 : ℤ) + 1 = 2 by norm_num, hidle] at hq2
    have h2 : (g 2).1 = ((true, 0), (g 2).1.2.1, (g 2).1.2.2) := Prod.ext hq2 rfl
    rw [truth_Craw_at hσ hg 2 0 _ _ h2 r, zero_add] at hC
    rw [if_pos hp2, hC]
  · intro h
    split_ifs at h with hp2
    · refine ⟨hidle', hp2, ?_⟩
      obtain ⟨hq2, -⟩ := region_start4 hg 1 hidle' (by rw [show (1 : ℤ) + 1 = 2 by norm_num]; exact hp2)
      rw [show (1 : ℤ) + 1 = 2 by norm_num, hidle] at hq2
      have h2 : (g 2).1 = ((true, 0), (g 2).1.2.1, (g 2).1.2.2) := Prod.ext hq2 rfl
      rw [truth_Craw_at hσ hg 2 0 _ _ h2 r, zero_add]
      exact Option.some.inj h

end Truth9

/-- **Every closure member of `phi9` has the same truth at `0` along two paths with equal
data**: a structural induction over the closure (atoms and the three `untl` members by the
atomic lemmas, `imp` by the closure's closedness, no `box`/`snce`/`stab` in the closure). -/
theorem agree9 {σ σ' : WorldHistory F4} {k k' : ℤ} {g g' : ℤ → LadderState Q4 pend4}
    (hσ : σ.path = fun t => (t + k, g t)) (hσ' : σ'.path = fun t => (t + k', g' t))
    (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1)
    (hg' : ∀ t, Rlad step4 pend4 t (g' t).1 (g' (t + 1)).1) {m m' : ℕ}
    (h0 : (g 0).1 = ((true, 0), 0, m)) (h0' : (g' 0).1 = ((true, 0), 0, m'))
    (hd : datum9 g = datum9 g') (r : Fin 4) :
    ∀ ψ ∈ plusSubformulaClosure (phi9raw r),
      (PlusTruthAt M4 σ 0 ψ ↔ PlusTruthAt M4 σ' 0 ψ) := by
  intro ψ
  induction ψ with
  | atom a =>
    intro h
    simp [plusSubformulaClosure, PlusFormula.subformulas] at h
    rcases h with rfl | rfl <;>
      first
      | rw [at0_p hσ h0, at0_p hσ' h0']
      | rw [at0_l hσ h0, at0_l hσ' h0']
  | bot => intro _; exact Iff.rfl
  | imp φ₁ φ₂ ih1 ih2 =>
    intro h
    have h1 := plusClosure_imp_left _ _ _ h
    have h2 := plusClosure_imp_right _ _ _ h
    rw [PlusTruth.imp_iff, PlusTruth.imp_iff, ih1 h1, ih2 h2]
  | box φ _ =>
    intro h
    exfalso
    simp [plusSubformulaClosure, PlusFormula.subformulas] at h
  | untl χ ψ _ _ =>
    intro h
    simp [plusSubformulaClosure, PlusFormula.subformulas] at h
    rcases h with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · rw [at0_phi hσ hg h0, at0_phi hσ' hg' h0', hd]
    · rw [at0_XB hσ hg h0, at0_XB hσ' hg' h0']
    · rw [at0_C hσ hg h0, at0_C hσ' hg' h0']
  | snce χ ψ _ _ =>
    intro h
    exfalso
    simp [plusSubformulaClosure, PlusFormula.subformulas] at h
  | stab φ _ =>
    intro h
    exfalso
    simp [plusSubformulaClosure, PlusFormula.subformulas] at h

/-- **Two paths with equal data realize the same type at `0`.** -/
theorem tpOf_eq_of_datum {σ σ' : WorldHistory F4} {k k' : ℤ} {g g' : ℤ → LadderState Q4 pend4}
    (hσ : σ.path = fun t => (t + k, g t)) (hσ' : σ'.path = fun t => (t + k', g' t))
    (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1)
    (hg' : ∀ t, Rlad step4 pend4 t (g' t).1 (g' (t + 1)).1) {m m' : ℕ}
    (h0 : (g 0).1 = ((true, 0), 0, m)) (h0' : (g' 0).1 = ((true, 0), 0, m'))
    (hd : datum9 g = datum9 g') (n : ℕ) :
    tpOf M4 (phi9 n) σ 0 = tpOf M4 (phi9 n) σ' 0 := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  constructor
  · rintro ⟨hcl, ht⟩
    exact ⟨hcl, (agree9 hσ hσ' hg hg' h0 h0' hd (idx (n + 2)) ψ hcl).mp ht⟩
  · rintro ⟨hcl, ht⟩
    exact ⟨hcl, (agree9 hσ hσ' hg hg' h0 h0' hd (idx (n + 2)) ψ hcl).mpr ht⟩

/-- Every cell member is the type at `0` of a sliced path with offset `0` through the state. -/
theorem of_mem_cell4_zero (φ : PlusFormula) (i : Fin 4) (c n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M4 φ ((0 : ℤ), st4 i c n) 0) :
    ∃ (σ : WorldHistory F4) (g : ℤ → LadderState Q4 pend4),
      σ.path = (fun t => (t + 0, g t)) ∧ (∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1) ∧
      (g 0).1 = ((true, i), c, n) ∧ tpOf M4 φ σ 0 = T := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path4 σ
  have hst : ((0 : ℤ) + k, g 0) = ((0 : ℤ), st4 i c n) := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hk : k = 0 := by
    have := congrArg Prod.fst hst
    simpa using this
  subst hk
  exact ⟨σ, g, hpath, fun t => hg t,
    congrArg (fun w : ℤ × LadderState Q4 pend4 => w.2.1) hst, rfl⟩

/-- A datum is realized at `(a, 0, m)` when some offset-`0` sliced path through that state
carries it. -/
def datum_realized (m : ℕ) (d : Option (Fin 4)) : Prop :=
  ∃ (σ : WorldHistory F4) (g : ℤ → LadderState Q4 pend4),
    σ.path = (fun t => (t + 0, g t)) ∧ (∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1) ∧
    (g 0).1 = ((true, 0), 0, m) ∧ datum9 g = d

/-- A raw chain through `(a, 0, m)` realizes its own datum. -/
theorem datum_realized_of_raw (m : ℕ) (raw : ℤ → Q4 × ℕ × ℕ)
    (h : ∀ t, Rlad step4 pend4 t (raw t) (raw (t + 1))) (h0 : raw 0 = ((true, 0), 0, m)) :
    datum_realized m (datum9 (liftAdm raw h)) := by
  obtain ⟨σ, hσ⟩ := hist_of_raw raw h
  exact ⟨σ, _, hσ, fun t => h t, h0, rfl⟩

/-- **The data achievable from `(a, 0, m)`, `1 ≤ m`**: position `2` idle, or pending with a
countdown in the window `{m - 1, m, m + 1}` (`forward_window` at `c = 0`, `j = 1`) — a
two-sided set equality. -/
theorem datum_achievable (m : ℕ) (hm : 1 ≤ m) :
    {d | datum_realized m d} =
      {none, some (idx (m - 1)), some (idx m), some (idx (m + 1))} := by
  ext d
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · rintro ⟨σ, g, hσ, hg, h0, rfl⟩
    unfold datum9
    split_ifs with hp2
    · -- the region at `2` has the deadline at `1` as countdown, within one of `m`
      obtain ⟨hidle, -⟩ := idle_at4 hg 0 0 m h0
      simp only [Nat.cast_zero, zero_add] at hidle
      have hidle' : (g 1).1.1.1 = false := congrArg Prod.fst hidle
      obtain ⟨-, hc2⟩ := region_start4 hg 1 hidle' (by rw [show (1 : ℤ) + 1 = 2 by norm_num]; exact hp2)
      rw [show (1 : ℤ) + 1 = 2 by norm_num] at hc2
      have hn0 : (g 0).1.2.2 = m := congrArg (fun x : Q4 × ℕ × ℕ => x.2.2) h0
      have hdr := drift_path4 hg 0 1
      simp only [Nat.cast_one, zero_add, hn0] at hdr
      rw [hc2]
      have : (g 1).1.2.2 = m - 1 ∨ (g 1).1.2.2 = m ∨ (g 1).1.2.2 = m + 1 := by omega
      rcases this with h | h | h <;> rw [h] <;> simp
    · left; rfl
  · rintro (rfl | rfl | rfl | rfl)
    · -- `none`: an idle run of length `2`
      have hr := gPast4_rlad 0 0 m (region4 0 0 m 2 m) (region4_zero 0 0 m 2 m)
        (region4_rlad 0 0 m 2 m (by omega) (by omega) (by omega))
      have := datum_realized_of_raw m _ hr (by
        rw [show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, gPast4_nat, region4_zero])
      convert this using 1
      unfold datum9
      rw [liftAdm_val, show (2 : ℤ) = ((2 : ℕ) : ℤ) by rfl, gPast4_nat,
        region4_idle₁ 0 0 m 2 m 2 (by omega) (by omega)]
      simp
    · -- `some (idx (m - 1))`
      have hr := gPast4_rlad 0 0 m (region4 0 0 m 1 (m - 1)) (region4_zero 0 0 m 1 (m - 1))
        (region4_rlad 0 0 m 1 (m - 1) le_rfl (by omega) (by omega))
      have := datum_realized_of_raw m _ hr (by
        rw [show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, gPast4_nat, region4_zero])
      convert this using 1
      unfold datum9
      rw [liftAdm_val, show (2 : ℤ) = ((2 : ℕ) : ℤ) by rfl, gPast4_nat,
        region4_pend₂ 0 0 m 1 (m - 1) 2 (by omega) (by omega)]
      simp only [if_true]
      congr 2
      omega
    · -- `some (idx m)`
      have hr := gPast4_rlad 0 0 m (region4 0 0 m 1 m) (region4_zero 0 0 m 1 m)
        (region4_rlad 0 0 m 1 m le_rfl (by omega) (by omega))
      have := datum_realized_of_raw m _ hr (by
        rw [show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, gPast4_nat, region4_zero])
      convert this using 1
      unfold datum9
      rw [liftAdm_val, show (2 : ℤ) = ((2 : ℕ) : ℤ) by rfl, gPast4_nat,
        region4_pend₂ 0 0 m 1 m 2 (by omega) (by omega)]
      simp only [if_true]
      congr 2
      omega
    · -- `some (idx (m + 1))`
      have hr := gPast4_rlad 0 0 m (region4 0 0 m 1 (m + 1)) (region4_zero 0 0 m 1 (m + 1))
        (region4_rlad 0 0 m 1 (m + 1) le_rfl (by omega) (by omega))
      have := datum_realized_of_raw m _ hr (by
        rw [show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, gPast4_nat, region4_zero])
      convert this using 1
      unfold datum9
      rw [liftAdm_val, show (2 : ℤ) = ((2 : ℕ) : ℤ) by rfl, gPast4_nat,
        region4_pend₂ 0 0 m 1 (m + 1) 2 (by omega) (by omega)]
      simp only [if_true]
      congr 2
      omega

/-- The achievable data at `m` and at `m + 4` coincide: the window shifts by the product
period. -/
theorem datum_achievable_shift (m : ℕ) (hm : 1 ≤ m) :
    {d | datum_realized m d} = {d | datum_realized (m + 4) d} := by
  rw [datum_achievable m hm, datum_achievable (m + 4) (by omega)]
  have e1 : idx (m + 4 - 1) = idx (m - 1) := by rw [idx_eq_iff]; omega
  have e2 : idx (m + 4) = idx m := by rw [idx_eq_iff]; omega
  have e3 : idx (m + 4 + 1) = idx (m + 1) := by rw [idx_eq_iff]; omega
  rw [e1, e2, e3]

/-- One inclusion of cells from one inclusion of achievable data. -/
theorem cell_subset_of_datum (n m m' : ℕ)
    (hsub : {d | datum_realized m d} ⊆ {d | datum_realized m' d}) :
    cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 m) 0 ⊆ cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 m') 0 := by
  intro T hT
  obtain ⟨σ, g, hσ, hg, h0, rfl⟩ := of_mem_cell4_zero (phi9 n) 0 0 m T hT
  have hd : datum9 g ∈ {d | datum_realized m d} := ⟨σ, g, hσ, hg, h0, rfl⟩
  obtain ⟨σ', g', hσ', hg', h0', hd'⟩ := hsub hd
  refine ⟨σ', ?_, ?_⟩
  · rw [state_eq4 hσ' 0]
    exact Prod.ext (by simp) (Subtype.ext h0')
  · exact tpOf_eq_of_datum hσ' hσ hg' hg h0' h0 hd' n

/-- **GATE 9, COLLISION HALF — COLLISION**: the cells at `(a, 0, n)` and `(a, 0, n + 4)` are
EQUAL for the closure of `phi9 n`, every `n ≥ 2`. -/
theorem gate9_col_cell_eq (n : ℕ) (hn : 2 ≤ n) :
    cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 n) 0 = cellAt M4 (phi9 n) ((0 : ℤ), st4 0 0 (n + 4)) 0 :=
  Set.Subset.antisymm
    (cell_subset_of_datum n n (n + 4) (datum_achievable_shift n (by omega)).le)
    (cell_subset_of_datum n (n + 4) n (datum_achievable_shift n (by omega)).ge)

end Gate9Col

/-! ## The gap-shift gate (DECISION GATE)

The closure `chi`: a `snce` member reading the region start's letter (`p S (ℓ 0 ∧ Y ¬p)`), one
pinning the previous idle run to length exactly `1` (`p S (¬p ∧ Y p)`), and the next region's
start letter (`p U (¬p ∧ X (p ∧ ℓ j))`, `j := idx c`).  The hand computation of `T₀` on `Q4`:
the current region's start pin is `c + s₀` at `-s₀-1`, and `Drift` to `n` at `0` needs
`|n - (c + s₀)| ≤ s₀ + 1`, which with `n = c + g₀` does not mention `c`; the previous idle run,
when pinned to length `1`, is preceded by a region the closure does NOT pin, which may be
pending forever with its deadline unconstrained, so the cascade terminates at depth `2` at that
unpinned previous region (or at the idle-forever run when the length is not pinned).  So
`T₀ = 0` (a count), `g₀ = 1`, `i₀ = 0`, `j₀ = idx c`; the absorber is `absorber4` below: the
previous region / idle run carrying the shifted pin with the same letters. -/

section GapShift

/-- The fixture threshold, computed from the cascade above: `0`. -/
def T₀ : ℕ := 0
/-- The fixed gap inside the clip. -/
def g₀ : ℕ := 1

/-- `p S (ℓ 0 ∧ Y ¬p)`: the region start's letter is `ℓ 0`. -/
abbrev S1raw : PlusFormula := .snce (.atom pA) (andF (.atom (lA 0)) (.snce .bot negp))
/-- `p S (¬p ∧ Y p)`: the previous idle run has length exactly `1`. -/
abbrev S2raw : PlusFormula := .snce (.atom pA) (andF negp (.snce .bot (.atom pA)))
/-- `p ∧ ℓ j`. -/
abbrev B3raw (j : Fin 4) : PlusFormula := andF (.atom pA) (.atom (lA j))
/-- `p U (¬p ∧ X (p ∧ ℓ j))`: the next region starts at once, at letter `ℓ j`. -/
abbrev U1raw (j : Fin 4) : PlusFormula := .untl (.atom pA) (andF negp (.untl .bot (B3raw j)))
abbrev chiRaw (j : Fin 4) : PlusFormula := andF S1raw (andF S2raw (U1raw j))

/-- The gap-shift closure, with `j` the current region's end residue (`idx c`). -/
def chi (j : Fin 4) : PlusFormula :=
  (PlusFormula.snce p ((ℓ 0).and (Y p.neg))).and
    ((PlusFormula.snce p (p.neg.and (Y p))).and (PlusFormula.untl p (p.neg.and (X (p.and (ℓ j))))))

theorem chi_eq_raw (j : Fin 4) : chi j = chiRaw j := rfl

/-! ### The backward structure of a path: a region start, or pending forever -/

/-- The current region started `s₀` steps ago: positions `-s₀ .. 0` pending, `-(s₀+1)` idle. -/
def StartAt (g : ℤ → LadderState Q4 pend4) (s₀ : ℕ) : Prop :=
  (∀ t : ℕ, t ≤ s₀ → (g (-(t : ℤ))).1.1.1 = true) ∧ (g (-((s₀ : ℤ) + 1))).1.1.1 = false

theorem startAt_unique {g : ℤ → LadderState Q4 pend4} {s₀ s₁ : ℕ} (h₀ : StartAt g s₀)
    (h₁ : StartAt g s₁) : s₀ = s₁ := by
  by_contra hne
  rcases Nat.lt_or_gt_of_ne hne with hlt | hgt
  · have := h₁.1 (s₀ + 1) (by omega)
    rw [Nat.cast_succ] at this
    rw [h₀.2] at this
    exact Bool.noConfusion this
  · have := h₀.1 (s₁ + 1) (by omega)
    rw [Nat.cast_succ] at this
    rw [h₁.2] at this
    exact Bool.noConfusion this

/-- Either some position `≤ 0` is idle (and then the region containing `0` has a start), or the
past is pending forever. -/
theorem startAt_or_forever (g : ℤ → LadderState Q4 pend4) (h0 : (g 0).1.1.1 = true) :
    (∃ s₀, StartAt g s₀) ∨ ∀ t : ℕ, (g (-(t : ℤ))).1.1.1 = true := by
  by_cases h : ∃ t : ℕ, (g (-(t : ℤ))).1.1.1 = false
  · left
    classical
    let t₁ := Nat.find h
    have ht₁ : (g (-(t₁ : ℤ))).1.1.1 = false := Nat.find_spec h
    have hmin : ∀ t, t < t₁ → (g (-(t : ℤ))).1.1.1 = true := by
      intro t ht
      have := Nat.find_min h ht
      cases hb : (g (-(t : ℤ))).1.1.1 with
      | true => rfl
      | false => exact absurd hb this
    have h1 : 1 ≤ t₁ := by
      by_contra hlt
      have : t₁ = 0 := by omega
      rw [this] at ht₁
      simp only [Nat.cast_zero, neg_zero] at ht₁
      rw [h0] at ht₁
      exact Bool.noConfusion ht₁
    refine ⟨t₁ - 1, fun t ht => hmin t (by omega), ?_⟩
    rw [show ((t₁ - 1 : ℕ) : ℤ) + 1 = (t₁ : ℤ) by omega]
    exact ht₁
  · right
    intro t
    push Not at h
    cases hb : (g (-(t : ℤ))).1.1.1 with
    | true => rfl
    | false => exact absurd hb (h t)

section Back4
variable {g : ℤ → LadderState Q4 pend4}
  (hg : ∀ t, Rlad step4 pend4 t (g t).1 (g (t + 1)).1)
include hg

/-- Along a backward pending run from index `0` at `0`, position `-t` has index `-(idx t)`. -/
theorem back_index (h0 : (g 0).1.1 = (true, 0)) (s₀ : ℕ)
    (hp : ∀ t : ℕ, t ≤ s₀ → (g (-(t : ℤ))).1.1.1 = true) :
    ∀ t : ℕ, t ≤ s₀ → (g (-(t : ℤ))).1.1.2 = -(idx t) := by
  intro t
  induction t with
  | zero =>
    intro _
    simp only [Nat.cast_zero, neg_zero, idx_zero]
    rw [h0]
  | succ t ih =>
    intro ht
    have hi := ih (by omega)
    obtain ⟨hs, -, -, -⟩ := (rlad4_iff _ _ _).mp (hg (-((t + 1 : ℕ) : ℤ)))
    rw [show -((t + 1 : ℕ) : ℤ) + 1 = -(t : ℤ) by push_cast; ring] at hs
    have hq1 : (g (-((t + 1 : ℕ) : ℤ))).1.1 = (true, (g (-((t + 1 : ℕ) : ℤ))).1.1.2) :=
      Prod.ext (hp (t + 1) ht) rfl
    have hq0 : (g (-(t : ℤ))).1.1 = (true, -(idx t)) :=
      Prod.ext (hp t (by omega)) hi
    rw [hq1, hq0] at hs
    have := (step4_pend_iff _ _).mp hs
    rw [idx_succ]
    revert this
    generalize (g (-((t + 1 : ℕ) : ℤ))).1.1.2 = a
    generalize idx t = b
    revert a b
    decide

/-- A pending state followed by an idle one hands over its index. -/
theorem pend_idle_index (t : ℤ) (hp : (g t).1.1.1 = true) (hi : (g (t + 1)).1.1.1 = false) :
    (g (t + 1)).1.1.2 = (g t).1.1.2 := by
  obtain ⟨hs, -, -, -⟩ := (rlad4_iff _ _ _).mp (hg t)
  have hq0 : (g t).1.1 = (true, (g t).1.1.2) := Prod.ext hp rfl
  have hq1 : (g (t + 1)).1.1 = (false, (g (t + 1)).1.1.2) := Prod.ext hi rfl
  rw [hq0, hq1] at hs
  exact (step4_pi_iff _ _).mp hs

/-- Any state followed by an idle state hands over its index. -/
theorem index_of_next_idle (t : ℤ) (hi : (g (t + 1)).1.1.1 = false) :
    (g (t + 1)).1.1.2 = (g t).1.1.2 := by
  cases hb : (g t).1.1.1 with
  | true => exact pend_idle_index hg t hb hi
  | false => exact idle_run4 hg t hb

end Back4

/-! ### The witness family: a region start `s₀` steps back, the previous idle run of length `1`
(`pp = true`, the previous region pending forever) or longer (`pp = false`, idle forever), the
forced region, an idle run of length `j`, a region of countdown `n`, idle forever -/

/-- The past ray: `k ↦` the state at time `-(k+1)`. -/
def past7 (c n s₀ : ℕ) (pp : Bool) (k : ℕ) : Q4 × ℕ × ℕ :=
  if k < s₀ then ((true, 0 - idx (k + 1)), c + k + 1, toward (c + s₀) n (s₀ - k))
  else if k = s₀ then ((false, 0 - idx s₀), 0, c + s₀)
  else if pp then ((true, 0 - idx s₀ - idx (k - s₀ - 1)), k - s₀ - 1, c + s₀)
  else ((false, 0 - idx s₀), 0, c + s₀)

theorem step4_sub_succ : ∀ a b : Fin 4, step4 (true, a - (b + 1)) (true, a - b) = true := by
  decide

/-! The four evaluations of `past7`: inside the current region, at its start, and before it —
the unpinned previous region (`pp = true`) or the idle-forever run (`pp = false`). -/

theorem past7_in (c n s₀ : ℕ) (pp : Bool) (k : ℕ) (h : k < s₀) :
    past7 c n s₀ pp k = ((true, 0 - idx (k + 1)), c + k + 1, toward (c + s₀) n (s₀ - k)) := by
  rw [past7, if_pos h]

theorem past7_start (c n s₀ : ℕ) (pp : Bool) :
    past7 c n s₀ pp s₀ = ((false, 0 - idx s₀), 0, c + s₀) := by
  rw [past7, if_neg (lt_irrefl s₀), if_pos (rfl : s₀ = s₀)]

theorem past7_deep_true (c n s₀ k : ℕ) (h : s₀ < k) :
    past7 c n s₀ true k = ((true, 0 - idx s₀ - idx (k - s₀ - 1)), k - s₀ - 1, c + s₀) := by
  rw [past7, if_neg (by omega : ¬ k < s₀), if_neg (by omega : ¬ k = s₀),
    if_pos (rfl : true = true)]

theorem past7_deep_false (c n s₀ k : ℕ) (h : s₀ < k) :
    past7 c n s₀ false k = ((false, 0 - idx s₀), 0, c + s₀) := by
  rw [past7, if_neg (by omega : ¬ k < s₀), if_neg (by omega : ¬ k = s₀),
    if_neg (by decide : ¬ (false = true))]

/-- **The absorber**: the past ray is an `Rlad` ray for EVERY `c` with the same `s₀`, letters
and idle-run shape — the shifted pin `c + s₀` is carried by the unpinned previous region
(`pp = true`, pending forever) or the idle-forever run (`pp = false`), whose deadline is
unconstrained. -/
theorem absorber4 (c n s₀ : ℕ) (pp : Bool) (hw1 : c + s₀ ≤ n + s₀ + 1)
    (hw2 : n ≤ c + s₀ + s₀ + 1) :
    ∀ k, Rlad step4 pend4 0 (past7 c n s₀ pp (k + 1)) (past7 c n s₀ pp k) := by
  intro k
  rw [rlad4_iff]
  rcases Nat.lt_or_ge (k + 1) s₀ with hlt | hge
  · -- pending to pending inside the current region
    rw [past7_in c n s₀ pp (k + 1) hlt, past7_in c n s₀ pp k (by omega)]
    dsimp only
    refine ⟨?_, by simp, ?_, ?_⟩
    · rw [idx_succ (k + 1)]
      exact step4_sub_succ _ _
    · rw [show s₀ - k = s₀ - (k + 1) + 1 by omega]
      exact toward_drift _ _ _
    · simp only [Count, if_true]
      omega
  rcases Nat.eq_or_lt_of_le hge with heq | hgt
  · -- the region start: the idle state hands its deadline to the countdown
    subst heq
    rw [past7_start c n (k + 1) pp, past7_in c n (k + 1) pp k (by omega)]
    dsimp only
    refine ⟨step4_idle_start _, by simp, ?_, ?_⟩
    · rw [show k + 1 - k = 1 by omega]
      unfold toward Drift
      split_ifs <;> omega
    · simp only [Count, Bool.false_eq_true, if_true, if_false]
      omega
  · -- before the region start
    rcases Nat.eq_or_lt_of_le (show s₀ ≤ k by omega) with heq | hlt'
    · -- the previous idle run's last state steps to the region start's idle state
      have hy : past7 c n s₀ pp k = ((false, 0 - idx s₀), 0, c + s₀) := by
        rw [← heq]
        exact past7_start c n s₀ pp
      cases pp with
      | true =>
        rw [past7_deep_true c n s₀ (k + 1) hgt, hy, show k + 1 - s₀ - 1 = 0 by omega, idx_zero,
          sub_zero]
        dsimp only
        exact ⟨step4_pend_idle _, by simp, by simp [Drift], by simp [Count]⟩
      | false =>
        rw [past7_deep_false c n s₀ (k + 1) hgt, hy]
        dsimp only
        exact ⟨step4_idle_self _, by simp, by simp [Drift], by simp [Count]⟩
    · -- deeper in the past: both states inside the unpinned previous region, or both idle
      cases pp with
      | true =>
        rw [past7_deep_true c n s₀ (k + 1) (by omega), past7_deep_true c n s₀ k hlt']
        dsimp only
        refine ⟨?_, by simp, by simp [Drift], ?_⟩
        · rw [show k + 1 - s₀ - 1 = (k - s₀ - 1) + 1 by omega, idx_succ]
          exact step4_sub_succ _ _
        · simp only [Count, if_true]
          omega
      | false =>
        rw [past7_deep_false c n s₀ (k + 1) (by omega), past7_deep_false c n s₀ k hlt']
        dsimp only
        exact ⟨step4_idle_self _, by simp, by simp [Drift], by simp [Count]⟩

/-- The junction: the last past state steps to `(true, 0), c, n`. -/
theorem past7_junction (c n s₀ : ℕ) (pp : Bool) (hw1 : c + s₀ ≤ n + s₀ + 1)
    (hw2 : n ≤ c + s₀ + s₀ + 1) :
    Rlad step4 pend4 0 (past7 c n s₀ pp 0) ((true, 0), c, n) := by
  rw [rlad4_iff]
  rcases Nat.eq_zero_or_pos s₀ with h0 | hpos
  · subst h0
    simp only [past7, show ¬ (0 < 0) by omega, if_false, if_true, idx_zero, sub_zero, add_zero]
    refine ⟨step4_idle_start _, by simp, ?_, by simp [Count]⟩
    simp only [Drift]
    omega
  · simp only [past7, hpos, if_true, Nat.sub_zero, add_zero]
    refine ⟨?_, fun h => by simp at h, ?_, by simp [Count]⟩
    · have h1 : idx (0 + 1) = 1 := by decide
      rw [h1]
      exact step4_pend_prev 0
    · have := toward_drift (c + s₀) n s₀
      rwa [toward_eq (c + s₀) n (s₀ + 1) (by omega) (by omega)] at this

/-- The whole witness: the past ray, then from `(true, 0), c, n` the forced region, an idle run
of length `j`, a region of countdown `n`, idle forever. -/
def wit7 (c n s₀ : ℕ) (pp : Bool) (j : ℕ) : ℤ → Q4 × ℕ × ℕ :=
  twoRay (past7 c n s₀ pp) (region4 0 c n j n)

theorem wit7_rlad (c n s₀ : ℕ) (pp : Bool) (j : ℕ) (hj : 1 ≤ j) (hw1 : c + s₀ ≤ n + s₀ + 1)
    (hw2 : n ≤ c + s₀ + s₀ + 1) :
    ∀ t, Rlad step4 pend4 t (wit7 c n s₀ pp j t) (wit7 c n s₀ pp j (t + 1)) :=
  twoRay_rlad _ _ (absorber4 c n s₀ pp hw1 hw2)
    (by rw [region4_zero]; exact past7_junction c n s₀ pp hw1 hw2)
    (region4_rlad 0 c n j n hj (by omega) (by omega))

theorem wit7_zero (c n s₀ : ℕ) (pp : Bool) (j : ℕ) : wit7 c n s₀ pp j 0 = ((true, 0), c, n) := by
  rw [wit7, show (0 : ℤ) = ((0 : ℕ) : ℤ) by rfl, twoRay_nat, region4_zero]

theorem wit7_neg (c n s₀ : ℕ) (pp : Bool) (j m : ℕ) :
    wit7 c n s₀ pp j (-((m : ℤ) + 1)) = past7 c n s₀ pp m := twoRay_neg _ _ m

theorem wit7_nat (c n s₀ : ℕ) (pp : Bool) (j m : ℕ) :
    wit7 c n s₀ pp j (m : ℤ) = region4 0 c n j n m := twoRay_nat _ _ m

/-- The witness has its region start exactly `s₀` steps back. -/
theorem wit7_startAt (c n s₀ : ℕ) (pp : Bool) (j : ℕ)
    (h : ∀ t, Rlad step4 pend4 t (wit7 c n s₀ pp j t) (wit7 c n s₀ pp j (t + 1))) :
    StartAt (liftAdm (wit7 c n s₀ pp j) h) s₀ := by
  refine ⟨?_, ?_⟩
  · intro t ht
    rw [liftAdm_val]
    rcases Nat.eq_zero_or_pos t with h0 | hpos
    · subst h0
      simp only [Nat.cast_zero, neg_zero, wit7_zero]
    · rw [show -(t : ℤ) = -(((t - 1 : ℕ) : ℤ) + 1) by omega, wit7_neg]
      simp [past7, show t - 1 < s₀ by omega]
  · rw [liftAdm_val, wit7_neg]
    simp [past7]

/-- The witness's previous idle run has length `1` iff `pp`. -/
theorem wit7_prev (c n s₀ : ℕ) (pp : Bool) (j : ℕ)
    (h : ∀ t, Rlad step4 pend4 t (wit7 c n s₀ pp j t) (wit7 c n s₀ pp j (t + 1))) :
    (liftAdm (wit7 c n s₀ pp j) h (-((s₀ : ℤ) + 2))).1.1.1 = pp := by
  rw [liftAdm_val, show -((s₀ : ℤ) + 2) = -(((s₀ + 1 : ℕ) : ℤ) + 1) by push_cast; ring, wit7_neg]
  cases pp <;> simp [past7]

/-- The witness's next region starts at once iff `j = 1` (for `j ∈ {1, 2}`). -/
theorem wit7_next (c n s₀ : ℕ) (pp : Bool) (j : ℕ) (hj : j = 1 ∨ j = 2)
    (h : ∀ t, Rlad step4 pend4 t (wit7 c n s₀ pp j t) (wit7 c n s₀ pp j (t + 1))) :
    (liftAdm (wit7 c n s₀ pp j) h ((c : ℤ) + 2)).1.1.1 = decide (j = 1) := by
  rw [liftAdm_val, show (c : ℤ) + 2 = ((c + 2 : ℕ) : ℤ) by push_cast; ring, wit7_nat]
  rcases hj with rfl | rfl
  · rw [region4_pend₂ 0 c n 1 n (c + 2) (by omega) (by omega)]
    simp
  · rw [region4_idle₁ 0 c n 2 n (c + 2) (by omega) (by omega)]
    simp

end GapShift

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
#print axioms Probe820.gate9_sep_cell_ne
#print axioms Probe820.short_idle_cell_ne
#print axioms Probe820.short_idle_shape_collides
#print axioms Probe820.short_idle_threshold_refuted
#print axioms Probe820.gate9_col_cell_eq
