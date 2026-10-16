/-
THE SIX-COORDINATE CELL INDEX OF THE ADMISSIBLE LADDER CARRIER IS REFUTED AT PARAMETERS DERIVED
FROM THE OBJECT AND THE FORMULA JOINTLY, IN THE SENSE THE PARAMETER-ORIGIN RULE STATES -- the
threshold and the clip bound read off the formula survive their gates, and the modulus clause, a
multiple of the period of every LETTER-DEFINABLE sub-object, does not, because a formula can carve
out a sub-object that forbids no letter; what survives is a strictly stronger necessary condition
on the modulus -- the period of every sub-object the formula's CLOSURE can carve out, which is the
object-closure product -- and no positive lemma, which remains OPEN and is stated nowhere.

## What was asked

Define the candidate index at parameters derived from the OBJECT AND THE FORMULA JOINTLY, as the
parameter-origin rule of `ladder-counter-observables.md` requires -- `B` from the formula's
`X`-nesting and `snce`-nesting depth, `T` from at least its `untl`-nesting depth, `P + 1` a
multiple of the period of every letter-definable sub-object of the object -- and run the five-part
falsification gate against it as compiled theorems BEFORE any sufficiency attempt.  That candidate
was the named successor of the three already refuted on compiled ground (counter-pair clipping;
gap-carrying clipping; the six-coordinate residue-carrying candidate at its OBJECT-EXHIBITED
parameters) and had been gated by no predecessor.  The index's definitional body is the fifteenth
probe's `ladderIndexRes` byte-for-byte; the only thing this record changes is where the parameters
come from, which is the whole content of the rule.

## The verdict

**REFUTED, at a sixth mechanism the rule does not cover.**  Gates 1, 2 and 3 pass; gates 4 and 5,
which refute every object-exhibited threshold and the full graph's reach-set period, are DISARMED
by the formula-derived threshold and the formula-coupled modulus respectively, and the probe
exhibits each disarming directly rather than observing that a hypothesis has become unsatisfiable.
A sixth gate then refutes the candidate: the rule's modulus clause quantifies over the sub-objects
a formula's LETTERS can name, and a formula can carve out a sub-object its letters cannot name, by
forbidding a PATTERN instead of a letter.

## Gates 1-3: passed

* **Gate 1** (`gate1_gap_separates`), mechanism (1)'s pair -- counters `(B, B+1)` against
  `(B, B+2)` -- is separated by the gap coordinate for every clip bound of at least two.
* **Gate 2** (`gate2_residue_separates`), mechanism (2)'s pair -- counters `(2B, 4B+2)` against
  `(2B+1, 4B+2)`, equal next deadlines, both gaps saturating the clip -- is separated by the
  countdown residue for every modulus of at least two, which `RuleParams.mod_ge_two` supplies.
  Both at the rule's own parameters in `gates_one_two_at_rule_params`.
* **Gate 3** (`second_region_sets_agree`, `third_region_any_length`, `region_start_beyond_depth`,
  `clipped_gap_collides`), the second region and the past direction: the forward half still finds
  NO refutation, and for the same reason as before -- `Count false false` holds the countdown at
  `0` through an idle interval of any length while `Drift` moves the next deadline freely, so the
  achievable second-region lengths are all of `ℕ` from every pending state and the verdict does not
  depend on `(T, P, B)` at all.  The past half's collision pair is likewise unchanged; under the
  rule it is no longer a defect, since `B` covers the `snce`-nesting depth and
  `region_start_beyond_depth` puts both region starts beyond that depth.

## Gate 4: DISARMED, by a diagonal that cannot be closed

Mechanism (4) separates its collision pair by the depth-`(T+1)` next-chain `phiDepth T`.  That
formula costs `untl`-nesting depth exactly `T + 1` (`untlDepth_phiDepth`), and the `untl`-nesting
depth is monotone along subformulas, so `phiDepth T` lies in the closure of NO formula whose
`untl`-depth is at most `T` (`gate4_witness_not_in_closure`).  At the rule's own threshold
`T = thrJ φ = untlDepth φ` the witness is therefore outside `cl φ` for EVERY `φ`
(`gate4_disarmed`), and taking the witness itself as the formula does not recover the refutation:
the threshold the rule then derives is `T + 1`, strictly above the depth that witness reads
(`gate4_diagonal_escapes`).  The decision gate recorded: **a formula-derived threshold leaves
mechanism (4) no witness, and the diagonal does not close.**

## Gate 5: DISARMED, at a rule-admissible modulus

On the coprime-cycle object with mechanism (5)'s own labelling, `l_d` is true at the pending state
`d` and at no other state (`lab5_d_only`), so the `d`-free sub-object IS letter-definable, and its
`a`-to-`a` walk lengths are exactly the multiples of three (`dfree_walk_mod3`).  The rule's modulus
clause therefore forces `3 ∣ P + 1` here.  Mechanism (5)'s refutation is stated under `¬ 3 ∣ P + 1`
(`reach_period_refuted`, ported and re-run at the renamed index), and at a rule-admissible modulus
its witness pair is no longer separated by its own formula: BOTH cells contain a type lacking
`phi5`, because both countdowns are then divisible by three and the reference 3-cycle history runs
through each of them (`gate5_disarmed`).  The decision gate recorded: **the modulus clause, read as
the rule states it, disarms mechanism (5) on the object that produced it.**

## Gate 6: the REFUTATION -- a sub-object the formula's letters cannot name

Gate 6 runs on the SAME object with ONE change: `d` is given the letter of `b`.  Then no atom
whatsoever distinguishes the pending state `d` from the pending state `b` (`lab6_d_eq_b`), so every
letter-restricted sub-object keeps `d` exactly when it keeps `b` (`lab6_keep_d_iff_b`); the 3-cycle
`{a, b, c}`, whose `a`-to-`a` walk lengths are the multiples of three, is cut out by no set of atoms
(`cycle_not_letter_definable`); and wherever a letter restriction keeps the 3-cycle it keeps the
2-cycle beside it, so the shortest `a`-to-`a` return in any letter-definable sub-object is `2`
(`letter_definable_keeps_two_cycle`).  The full graph's exhibited period is `1` from threshold `4`,
in exactly the shape `reachN_eventually_periodic` returns (`reach5_eventually_constant`).  The
rule's modulus clause thus forces nothing beyond `2 ≤ P + 1` on this object, and `P + 1 = 2` is the
least modulus it admits.

A formula nonetheless carves the 3-cycle out, by forbidding a PATTERN rather than a letter.  The
pattern is `psi2 := (p ∧ l_a) ∧ X X (p ∧ l_a)` -- a pending `a` with a pending `a` exactly two
instants later -- which the 2-cycle `a → d → a` exhibits and the 3-cycle does not; `psi2` requires
`l_a` and forbids no letter at all, and mentions no atom of `b`, `c` or `d`.  Under
`chi := ¬psi2 ∧ ¬(⊤ U psi2)` every pending `d` strictly inside the region is impossible, since `d`'s
only pending predecessor and only pending successor are `a` (`pred_of_d`, `succ_of_d`), and a `d` at
the region's last position would hand the idle end the index `d`, which `endA` forbids
(`chi_forces_dfree`).  So `endA ∧ chi` forces the region's length to be a multiple of three, while
the reference 3-cycle history realizes `endA ∧ chi` at every such length (`chi_ref`, `endA_refL`).

Machine-checked: `period_collision` (the pair `(a, C, n)` against `(a, C + (P+1), n)` at
`n = C + (P+1) + B` with `C = 3(P+1)(T+1)` collides in the index for EVERY `(T, P, B)`),
`exists_cell_not_phi6`, `phi6_mem_of_mem_cell`, `cell6_ne` (the cells differ for every modulus
coprime to three), `joint_parameters_refuted`, and `rule_derived_parameters_refuted`, which
instantiates the refutation at `T = thrJ phi6`, `B = clipJ phi6` and `P + 1 = 2` with `RuleParams
phi6 (thrJ phi6) 1 (clipJ phi6)` discharged.  The decision gate recorded: **the modulus must be a
multiple of the period of every sub-object the formula's CLOSURE can carve out, not of every
sub-object its LETTERS can name; the two differ, and the index at the weaker condition fails.**

## What the refutation leaves standing

A strictly stronger necessary condition on the modulus, and nothing positive.  The sub-object a
formula carves out is the projection of the product of the object with the formula's closure, which
is precisely the first of the four proof obligations already on record for a successor -- eventual
periodicity of the realizable types in the countdown over the product of the object with the
closure.  That obligation is therefore not merely a step a proof would have to take: it is a
NECESSARY condition on the modulus of any index of this shape.  The other three obligations are
untouched and unmet: a region-length pumping lemma for `untl`/`snce`-depth-bounded formulas; the
next deadline's coupling through `Drift`; and the `box`/`stab` letters through the anchor-layer
equations (`box_mem_tpOf_iff`, `stab_mem_tpOf_iff`).

## What this probe does NOT say

- **No weakened successor, and no substitute for the refuted statements.**  No `ladderRealized`, no
  `LadderCons`, no `ladderCons_localRun`, under those names or any other; in particular nothing
  without the `box`/`stab` clause, which `stab_mem_tpOf_iff` pins per cell.  No declaration is added
  under the main library and no library module is created.
- **No positive factorization lemma, in any shape.**  Not at object-exhibited parameters (already
  refuted); not at the rule's jointly-derived parameters (refuted here); not at a modulus satisfying
  the stronger condition above, which is OPEN and asserted nowhere.  Nothing here says such a
  modulus exists, is computable, or would suffice.
- **No seventh coordinate and no new index candidate.**  The direction on record for a successor is
  unchanged: a different presentation of a cell -- a set-valued per-state datum over a quotient --
  not a wider tuple.  This record chooses no successor.
- **Gate 6 refutes the rule's clause, not every conceivable joint derivation.**  What is refuted is
  the modulus clause AS THE RULE STATES IT (letter-definable sub-objects of the object).  A
  candidate whose modulus is derived from the object-closure product is a DIFFERENT candidate, not
  gated here.
- **The gates' scope.**  A gate probing one coordinate certifies one coordinate.  Gates 1-3 passing
  says nothing about 4, 5 and 6; gates 4 and 5 being disarmed says nothing about 6 -- which is the
  whole shape of this record, since the candidate that reaches gate 6 is the one that cleared the
  five before it.
- The earlier negatives are untouched and not re-derived: the gap coordinate, the countdown parity,
  the bounded carrier, the object-exhibited threshold and the full-graph reach-set period.
- No upper bound and no complexity bound; every quantity named is a COUNT.  No finiteness is added
  or removed: the SET of cells of a regular Z-model is finite and bounded (`anchorCells_finite`,
  `anchorCells_ncard_le`) and is untouched here, as it is not in question -- only the computable
  INDEX is, and it remains absent.
- Nothing about `HitPresented`; no declaration mentions `PlusValidZTime`.
- No fixture-level sufficiency theorem is restated or extended; the fifteenth probe's
  `qp_cell_eq_of_depth_parity` is the one positive result on record and is not the factorization
  lemma.

## Axioms

`lab6_d_eq_b` depends on `[propext]`; `gate1_gap_separates`, `region_start_beyond_depth`,
`clipped_gap_collides`, `untlDepth_phiDepth`, `gate4_diagonal_escapes` and `dfree_walk_mod3` on
`[propext, Quot.sound]`; every other theorem named above on
`[propext, Classical.choice, Quot.sound]`.  No new axiom, no placeholder body, no `sorry`, no
`native_decide` and no vacuous definition appears anywhere in this file.

Compile: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`
-/import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe805

/-! ## The pinned definitional bodies, ported byte-for-byte from the fifteenth probe -/

/-- **The candidate, at JOINTLY DERIVED parameters.**  The body is the fifteenth probe's
`ladderIndexRes` byte-for-byte; what changes is only where `(T, P, B)` come from, which is the
whole content of the parameter-origin rule.  Renamed so that what is gated below is the index at
rule-derived parameters and not the index at object-exhibited ones. -/
def ladderIndexJnt (T P B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) × Fin (2 * B + 1) :=
  (x.1.1,
    ⟨min x.1.2.1 T, by omega⟩,
    ⟨x.1.2.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min x.1.2.2 T, by omega⟩,
    ⟨x.1.2.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-- One step of reachability under the object's step relation, ported byte-for-byte: the map
whose iteration `reachN_eventually_periodic` shows eventually periodic. -/
def reachStep {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool)
    (S : Finset Q) : Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))

/-! ## Generic facts about `Count`, and the forced run in any object -/

theorem count_tt (c n c' : ℕ) : Count true true c n c' ↔ c' + 1 = c := by simp [Count]
theorem count_tf (c n c' : ℕ) : Count true false c n c' ↔ c' = 0 ∧ c = 0 := by simp [Count]
theorem count_ff (c n c' : ℕ) : Count false false c n c' ↔ c' = 0 := by simp [Count]
theorem count_ft (c n c' : ℕ) : Count false true c n c' ↔ c' = n := by simp [Count]

section RunGen
variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
  {g : ℤ → LadderState Q pend} (hg : ∀ t, Rlad step pend t (g t).1 (g (t + 1)).1)
include hg

/-- **Forward determinism of the countdown, in ANY object**: from a pending state with countdown
`c`, every position `i ≤ c` is pending with countdown `c - i`. -/
theorem pending_run_gen (q : Q) (c n : ℕ) (hq : pend q = true) (h0 : (g 0).1 = (q, c, n)) :
    ∀ i : ℕ, i ≤ c → pend (g (i : ℤ)).1.1 = true ∧ (g (i : ℤ)).1.2.1 = c - i := by
  intro i
  induction i with
  | zero =>
    intro _
    rw [Nat.cast_zero, h0]
    exact ⟨hq, by simp⟩
  | succ i ih =>
    intro hi
    obtain ⟨hq1, hc⟩ := ih (by omega)
    rw [show ((i + 1 : ℕ) : ℤ) = (i : ℤ) + 1 by push_cast; ring]
    obtain ⟨-, -, -, hcount⟩ := hg (i : ℤ)
    rw [hq1] at hcount
    cases hy : pend (g ((i : ℤ) + 1)).1.1 with
    | false =>
      rw [hy, count_tf] at hcount
      omega
    | true =>
      rw [hy, count_tt] at hcount
      exact ⟨rfl, by omega⟩

/-- **The first idle state sits at distance exactly `c + 1`, in ANY object**. -/
theorem idle_at_gen (q : Q) (c n : ℕ) (hq : pend q = true) (h0 : (g 0).1 = (q, c, n)) :
    pend (g ((c : ℤ) + 1)).1.1 = false := by
  obtain ⟨hq1, hc⟩ := pending_run_gen hg q c n hq h0 c le_rfl
  obtain ⟨-, -, -, hcount⟩ := hg (c : ℤ)
  rw [hq1, hc, Nat.sub_self] at hcount
  cases hy : pend (g ((c : ℤ) + 1)).1.1 with
  | true =>
    rw [hy, count_tt] at hcount
    omega
  | false => rfl

end RunGen

/-! ## Nested nexts: `X chi := bot U chi` -/

/-- `k` nested nexts. -/
def nextPow : ℕ → PlusFormula → PlusFormula
  | 0, chi => chi
  | k + 1, chi => .untl .bot (nextPow k chi)

/-- **Over integer time `bot U chi` is `chi` at the next instant**, so `k` nested nexts read
`chi` exactly `k` instants later. -/
theorem truth_nextPow {G : FrameOver intOrder} (N : TaskModel G.toTaskFrame)
    (σ : WorldHistory G.toTaskFrame) (k : ℕ) (chi : PlusFormula) (s : ℤ) :
    PlusTruthAt N σ s (nextPow k chi) ↔ PlusTruthAt N σ (s + k) chi := by
  induction k generalizing s with
  | zero => simp [nextPow]
  | succ k ih =>
    simp only [nextPow]
    constructor
    · rintro ⟨(s' : ℤ), hs, hψ, hguard⟩
      have hs' : (s : ℤ) < s' := hs
      have hs1 : s' = s + 1 := by
        by_contra hne
        exact hguard (s + 1) (show (s : ℤ) < s + 1 by omega) (show (s + 1 : ℤ) < s' by omega)
      subst hs1
      rw [ih] at hψ
      rw [show s + ((k + 1 : ℕ) : ℤ) = s + 1 + (k : ℤ) by push_cast; ring]
      exact hψ
    · intro h
      refine ⟨s + 1, show (s : ℤ) < s + 1 by omega, ?_, ?_⟩
      · rw [ih, show s + 1 + (k : ℤ) = s + ((k + 1 : ℕ) : ℤ) by push_cast; ring]
        exact h
      · intro (r : ℤ) h1 h2
        exfalso
        have h1' : (s : ℤ) < r := h1
        have h2' : r < s + 1 := h2
        omega

/-! ## Part I: the parameters, derived from the formula

`T` and `B` are functions of the formula alone; the modulus is a natural number constrained by a
DIVISIBILITY condition that couples the object to the formula's letters.  Nothing below chooses a
modulus: every refutation is stated for a range of moduli and every separation for a range. -/

/-- The `untl`-nesting depth.  `X chi = bot U chi`, so the `X`-nesting depth of a formula is at
most this, and mechanism (4)'s observable at depth `k` costs `untlDepth` exactly `k`. -/
def untlDepth : PlusFormula → ℕ
  | .atom _ => 0
  | .bot => 0
  | .imp ψ χ => max (untlDepth ψ) (untlDepth χ)
  | .box ψ => untlDepth ψ
  | .untl ψ χ => max (untlDepth ψ) (untlDepth χ) + 1
  | .snce ψ χ => max (untlDepth ψ) (untlDepth χ)
  | .stab ψ => untlDepth ψ

/-- The `snce`-nesting depth: the past-direction counterpart, which the third gate's past half
shows the clip bound must also cover. -/
def snceDepth : PlusFormula → ℕ
  | .atom _ => 0
  | .bot => 0
  | .imp ψ χ => max (snceDepth ψ) (snceDepth χ)
  | .box ψ => snceDepth ψ
  | .untl ψ χ => max (snceDepth ψ) (snceDepth χ)
  | .snce ψ χ => max (snceDepth ψ) (snceDepth χ) + 1
  | .stab ψ => snceDepth ψ

/-- **The threshold, derived from the formula**: at least the `untl`-nesting depth, which is what
mechanism (4) forces. -/
def thrJ (φ : PlusFormula) : ℕ := untlDepth φ

/-- **The clip bound, derived from the formula**: the `X`-nesting depth (bounded by the
`untl`-nesting depth) plus the `snce`-nesting depth, which is what mechanism (1) and the past
half of the third gate jointly force. -/
def clipJ (φ : PlusFormula) : ℕ := untlDepth φ + snceDepth φ

/-- **The parameter-origin rule, as a predicate on a parameter triple.**  The first two clauses
are the formula-derived ones; the third is the lower bound a modulus must clear for the residue
coordinates not to be constant.  The fourth clause -- that the modulus is a multiple of the
period of every letter-definable sub-object of the object -- is object-dependent and enters each
fixture below as its own hypothesis, since it cannot be stated once for all objects. -/
structure RuleParams (φ : PlusFormula) (T P B : ℕ) : Prop where
  /-- The threshold is at least the formula's `untl`-nesting depth. -/
  thr_ge : thrJ φ ≤ T
  /-- The clip bound covers the `X`- and `snce`-nesting depths. -/
  clip_ge : clipJ φ ≤ B
  /-- The modulus `P + 1` is at least two: at `P = 0` both residue coordinates are constant and
  the index collapses to the clipped-coordinate candidate already refuted. -/
  mod_ge_two : 1 ≤ P

theorem ruleParams_derived (φ : PlusFormula) (P : ℕ) (hP : 1 ≤ P) :
    RuleParams φ (thrJ φ) P (clipJ φ) := ⟨le_rfl, le_rfl, hP⟩

/-! ## Part II: gates 1 and 2, re-run at rule-derived parameters -/

/-- Object states `(pending?, tag)` of the two-state fixture. -/
abbrev Qp : Type := Bool × Bool

def pendP : Qp → Bool := fun q => q.1

/-- While pending the tag flips on every pending step and is COPIED onto the idle state that ends
the region; an idle state steps to any state carrying the tag, so a second region may start. -/
def stepP : Qp → Qp → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (y.2 == x.2)

theorem rladP_iff (t : ℤ) (x y : Qp × ℕ × ℕ) :
    Rlad stepP pendP t x y ↔
      stepP x.1 y.1 = true ∧ (x.1.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧
        Count x.1.1 y.1.1 x.2.1 x.2.2 y.2.1 := Iff.rfl

/-- A pending admissible ladder state with countdown `c` and next deadline `n`. -/
def st (tg : Bool) (c n : ℕ) : LadderState Qp pendP :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

/-- An idle admissible ladder state; `Adm` forces its countdown to `0`. -/
def idl (tg : Bool) (n : ℕ) : LadderState Qp pendP :=
  ⟨((false, tg), 0, n), fun _ => rfl⟩

/-- **GATE 1 PASSES, for `2 ≤ B`.**  On mechanism (1)'s own pair -- counters `(B, B+1)` against
`(B, B+2)`, where both counters saturate every threshold -- the gap coordinate gives `B+1`
against `B+2`, which the clip keeps apart as soon as `2 ≤ B`. -/
theorem gate1_gap_separates (T P B : ℕ) (hB : 2 ≤ B) :
    ladderIndexJnt T P B (st false B (B + 1)) ≠ ladderIndexJnt T P B (st false B (B + 2)) := by
  intro h
  have h6 := congrArg (fun z : Qp × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) ×
      Fin (2 * B + 1) => z.2.2.2.2.2.val) h
  simp only [ladderIndexJnt, st] at h6
  omega

/-- Two consecutive naturals cannot be congruent modulo `P + 1` once `1 ≤ P`. -/
theorem consec_mod_ne (P B : ℕ) (hP : 1 ≤ P) :
    2 * B % (P + 1) ≠ (2 * B + 1) % (P + 1) := by
  intro h
  have hm : Nat.ModEq (P + 1) (2 * B) (2 * B + 1) := h
  have hd := Nat.ModEq.dvd hm
  have h1 : ((P : ℤ) + 1) ∣ 1 := by
    have he : ((2 * B + 1 : ℕ) : ℤ) - ((2 * B : ℕ) : ℤ) = 1 := by push_cast; ring
    push_cast at hd
    push_cast at he
    rw [he] at hd
    exact_mod_cast hd
  have := Int.le_of_dvd (by norm_num) h1
  omega

/-- **GATE 2 PASSES, for `1 ≤ P`** -- which `RuleParams.mod_ge_two` supplies.  On mechanism (2)'s
own pair -- counters `(2B, 4B+2)` against `(2B+1, 4B+2)`, with EQUAL next deadlines, both
countdowns saturating the threshold coordinate and both gaps saturating the clip -- the
separating coordinate is the countdown residue. -/
theorem gate2_residue_separates (T P B : ℕ) (hP : 1 ≤ P) :
    ladderIndexJnt T P B (st false (2 * B) (4 * B + 2))
      ≠ ladderIndexJnt T P B (st false (2 * B + 1) (4 * B + 2)) := by
  intro h
  have h3 := congrArg (fun z : Qp × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) ×
      Fin (2 * B + 1) => z.2.2.1.val) h
  simp only [ladderIndexJnt, st] at h3
  exact consec_mod_ne P B hP h3

/-- **GATES 1 AND 2 AT THE RULE'S OWN PARAMETERS.**  For any formula whose clip bound is at least
two, the rule-derived triple separates both earlier refutations' pairs. -/
theorem gates_one_two_at_rule_params (φ : PlusFormula) (P : ℕ) (hP : 1 ≤ P)
    (hB : 2 ≤ clipJ φ) :
    ladderIndexJnt (thrJ φ) P (clipJ φ) (st false (clipJ φ) (clipJ φ + 1))
        ≠ ladderIndexJnt (thrJ φ) P (clipJ φ) (st false (clipJ φ) (clipJ φ + 2)) ∧
      ladderIndexJnt (thrJ φ) P (clipJ φ) (st false (2 * clipJ φ) (4 * clipJ φ + 2))
        ≠ ladderIndexJnt (thrJ φ) P (clipJ φ) (st false (2 * clipJ φ + 1) (4 * clipJ φ + 2)) :=
  ⟨gate1_gap_separates _ _ _ hB, gate2_residue_separates _ _ _ hP⟩

/-! ## Part III: gate 3, re-run -- one region further out, and in the past direction -/

/-- Reachability by admissible ladder steps.  `Rlad` ignores its time argument, so fixing it at
`0` loses nothing. -/
abbrev RladStar : LadderState Qp pendP → LadderState Qp pendP → Prop :=
  Relation.ReflTransGen (RladAdm stepP pendP 0)

/-- The tag `i` pending steps after a state tagged `tg`. -/
def tagN (tg : Bool) (i : ℕ) : Bool := if i % 2 = 0 then tg else !tg

theorem tagN_zero (tg : Bool) : tagN tg 0 = tg := by simp [tagN]
theorem tagN_one (tg : Bool) : tagN tg 1 = !tg := by simp [tagN]

theorem tagN_succ (tg : Bool) (i : ℕ) : tagN tg (i + 1) = tagN (!tg) i := by
  unfold tagN
  rcases Nat.even_or_odd i with h | h
  · have h1 : i % 2 = 0 := Nat.even_iff.mp h
    have h2 : (i + 1) % 2 = 1 := by omega
    simp [h1, h2]
  · have h1 : i % 2 = 1 := Nat.odd_iff.mp h
    have h2 : (i + 1) % 2 = 0 := by omega
    simp [h1, h2]

/-- One pending step: the countdown falls by exactly one and the tag flips. -/
theorem step_pend_down (tg : Bool) (c n : ℕ) :
    RladAdm stepP pendP 0 (st tg (c + 1) n) (st (!tg) c n) := by
  show Rlad stepP pendP 0 _ _
  rw [rladP_iff]
  refine ⟨?_, by simp [st], Or.inl rfl, ?_⟩
  · show stepP (true, tg) (true, !tg) = true
    cases tg <;> simp [stepP]
  · show Count true true (c + 1) n c
    rw [count_tt]

/-- **The countdown runs down with `n` held fixed**, so the region's last pending state carries
the tag `tagN tg c`. -/
theorem run_down (tg : Bool) (c n : ℕ) : RladStar (st tg c n) (st (tagN tg c) 0 n) := by
  induction c generalizing tg with
  | zero => rw [tagN_zero]
  | succ c ih =>
    rw [tagN_succ]
    exact Relation.ReflTransGen.head (step_pend_down tg c n) (ih (!tg))

/-- **The region ends on an idle state carrying the tag.** -/
theorem step_region_end (tg : Bool) (n : ℕ) :
    RladAdm stepP pendP 0 (st tg 0 n) (idl tg n) := by
  show Rlad stepP pendP 0 _ _
  rw [rladP_iff]
  refine ⟨?_, by simp [st], Or.inl rfl, ?_⟩
  · show stepP (true, tg) (false, tg) = true
    cases tg <;> simp [stepP]
  · show Count true false 0 n 0
    rw [count_tf]
    exact ⟨rfl, rfl⟩

/-- **The idle interval drifts the next deadline freely.** -/
theorem step_idle_drift (tg : Bool) (n n' : ℕ) (h : Drift n n') :
    RladAdm stepP pendP 0 (idl tg n) (idl tg n') := by
  show Rlad stepP pendP 0 _ _
  rw [rladP_iff]
  refine ⟨?_, fun _ => rfl, h, ?_⟩
  · show stepP (false, tg) (false, tg) = true
    cases tg <;> simp [stepP]
  · show Count false false 0 n 0
    rw [count_ff]

/-- **Hence EVERY next-deadline value is reachable within the idle interval.** -/
theorem idle_to_any (tg : Bool) (n m : ℕ) : RladStar (idl tg n) (idl tg m) := by
  have hdown : ∀ k, RladStar (idl tg k) (idl tg 0) := by
    intro k
    induction k with
    | zero => exact Relation.ReflTransGen.refl
    | succ k ih =>
      exact Relation.ReflTransGen.head
        (step_idle_drift tg (k + 1) k (Or.inr (Or.inr rfl))) ih
  have hup : ∀ k, RladStar (idl tg 0) (idl tg k) := by
    intro k
    induction k with
    | zero => exact Relation.ReflTransGen.refl
    | succ k ih =>
      exact ih.tail (step_idle_drift tg k (k + 1) (Or.inr (Or.inl rfl)))
  exact (hdown n).trans (hup m)

/-- **A region starts, handed the next deadline as its length.** -/
theorem step_region_start (tg : Bool) (m : ℕ) :
    RladAdm stepP pendP 0 (idl tg m) (st tg m m) := by
  show Rlad stepP pendP 0 _ _
  rw [rladP_iff]
  refine ⟨?_, fun _ => rfl, Or.inl rfl, ?_⟩
  · show stepP (false, tg) (true, tg) = true
    cases tg <;> simp [stepP]
  · show Count false true 0 m m
    rw [count_ft]

/-- **GATE 3, forward half: from EVERY pending state a second region of EVERY length is
reachable**, with no dependence on either counter of the source state. -/
theorem second_region_any_length (tg : Bool) (c n m : ℕ) :
    RladStar (st tg c n) (st (tagN tg c) m m) :=
  ((run_down tg c n).tail (step_region_end (tagN tg c) n)).trans
    ((idle_to_any (tagN tg c) n m).tail (step_region_start (tagN tg c) m))

/-- Both parities of the second region's end tag are achievable from every pending state. -/
theorem second_region_end_tag_achievable (tg : Bool) (c n : ℕ) (b : Bool) :
    ∃ m : ℕ, RladStar (st tg c n) (st (tagN tg c) m m) ∧ tagN (tagN tg c) m = b := by
  by_cases h : tagN tg c = b
  · exact ⟨0, second_region_any_length tg c n 0, by rw [tagN_zero]; exact h⟩
  · refine ⟨1, second_region_any_length tg c n 1, ?_⟩
    rw [tagN_one]
    revert h
    cases tagN tg c <;> cases b <;> simp

/-- **GATE 3, forward verdict: NO REFUTATION, and the rule's parameters change nothing.**  Any
two pending states with the same object component have the SAME achievable second-region-end tag
set -- both sets are everything -- for ANY values of either counter, hence in particular for the
pairs the earlier gates separate.  The verdict is independent of `(T, P, B)` and so is not
affected by moving their origin to the formula. -/
theorem second_region_sets_agree (tg : Bool) (c1 n1 c2 n2 : ℕ) (b : Bool) :
    (∃ m : ℕ, RladStar (st tg c1 n1) (st (tagN tg c1) m m) ∧ tagN (tagN tg c1) m = b) ∧
      (∃ m : ℕ, RladStar (st tg c2 n2) (st (tagN tg c2) m m) ∧ tagN (tagN tg c2) m = b) :=
  ⟨second_region_end_tag_achievable tg c1 n1 b, second_region_end_tag_achievable tg c2 n2 b⟩

/-- **GATE 3, one region further: SUBSUMED.**  The forward half is stated from an ARBITRARY
pending state, so iterating it is one application of transitivity. -/
theorem third_region_any_length (tg : Bool) (c n m2 m3 : ℕ) :
    RladStar (st tg c n) (st (tagN (tagN tg c) m2) m3 m3) :=
  (second_region_any_length tg c n m2).trans
    (second_region_any_length (tagN tg c) m2 m2 m3)

/-! ### Gate 3, past half: the region start is beyond the formula's past depth -/

/-- The gap `n - c`, over `ℤ` so that it is not truncated. -/
def gapZ {Q : Type} (x : Q × ℕ × ℕ) : ℤ := (x.2.2 : ℤ) - (x.2.1 : ℤ)

/-- **Along a forward pending chain the gap rises by at most two per step.** -/
theorem gap_step_le {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x y : Q × ℕ × ℕ) (hx : pend x.1 = true) (hy : pend y.1 = true)
    (h : Rlad step pend 0 x y) : gapZ y ≤ gapZ x + 2 := by
  obtain ⟨-, -, hd, hc⟩ := h
  rw [hx, hy, count_tt] at hc
  simp only [Drift] at hd
  simp only [gapZ]
  omega

/-- **At a region start the gap is at most one.** -/
theorem gap_region_start_le_one {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x y : Q × ℕ × ℕ) (hx : pend x.1 = false) (hy : pend y.1 = true)
    (h : Rlad step pend 0 x y) : gapZ y ≤ 1 := by
  obtain ⟨-, -, hd, hc⟩ := h
  rw [hx, hy, count_ft] at hc
  simp only [Drift] at hd
  simp only [gapZ]
  omega

/-- **A state reached `j` steps after its region start has gap at most `2j - 1`.** -/
theorem gap_le_region_age {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x : ℕ → Q × ℕ × ℕ) (k : ℕ)
    (hstep : ∀ i, i < k → Rlad step pend 0 (x i) (x (i + 1)))
    (h0 : pend (x 0).1 = false)
    (hp : ∀ i, 1 ≤ i → i ≤ k → pend (x i).1 = true) :
    ∀ j, 1 ≤ j → j ≤ k → gapZ (x j) ≤ 2 * (j : ℤ) - 1 := by
  intro j
  induction j with
  | zero => intro h _; omega
  | succ j ih =>
    intro _ hjk
    rcases Nat.eq_zero_or_pos j with hj0 | hj0
    · subst hj0
      have h1 := gap_region_start_le_one step pend (x 0) (x 1) h0
        (hp 1 le_rfl hjk) (hstep 0 (by omega))
      push_cast
      omega
    · have hprev := ih hj0 (by omega)
      have hstp := gap_step_le step pend (x j) (x (j + 1))
        (hp j hj0 (by omega)) (hp (j + 1) (by omega) hjk) (hstep j (by omega))
      push_cast at hprev hstp ⊢
      omega

/-- **GATE 3, past verdict as a bound**: a state whose gap exceeds `2k - 1` has NO region start
within `k` backward steps, so a formula of past depth at most `k` cannot see it. -/
theorem region_start_beyond_depth {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x : ℕ → Q × ℕ × ℕ) (k : ℕ) (hk : 1 ≤ k)
    (hstep : ∀ i, i < k → Rlad step pend 0 (x i) (x (i + 1)))
    (h0 : pend (x 0).1 = false)
    (hp : ∀ i, 1 ≤ i → i ≤ k → pend (x i).1 = true)
    (hgap : 2 * (k : ℤ) - 1 < gapZ (x k)) : False :=
  absurd (gap_le_region_age step pend x k hstep h0 hp k hk le_rfl) (by omega)

/-- The pair the past half turns on: countdown `1`, next deadlines `2B+1` and `2B+2`, so true
gaps `2B` and `2B+1` -- both at or above the clip, so the clipped gap coordinate CANNOT separate
them.  Under the rule this is not a defect: `B` covers the `snce`-nesting depth, and the bound
above puts both region starts beyond that depth. -/
theorem clipped_gap_collides (B : ℕ) (hB : 1 ≤ B) :
    min ((2 * B + 1 + B) - 1) (2 * B) = min ((2 * B + 2 + B) - 1) (2 * B) := by omega

/-! ## Part IV: gate 4, re-run against the FORMULA-derived threshold -/

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩
def dA : Atom := ⟨"d", none⟩

theorem pA_ne_rA : pA ≠ rA := by simp [pA, rA]
theorem aA_ne_pA : aA ≠ pA := by simp [aA, pA]
theorem aA_ne_rA : aA ≠ rA := by simp [aA, rA]
theorem dA_ne_pA : dA ≠ pA := by simp [dA, pA]
theorem dA_ne_rA : dA ≠ rA := by simp [dA, rA]
theorem dA_ne_aA : dA ≠ aA := by simp [dA, aA]

def p : PlusFormula := .atom pA
def r : PlusFormula := .atom rA

/-- Mechanism (4)'s observable: the depth-`(T+1)` next-chain ending in the idle letter, true
exactly when the region's forced first idle state sits at distance exactly `T + 1`. -/
def phiDepth (T : ℕ) : PlusFormula := nextPow (T + 1) r

/-- `k` nested nexts cost `untl`-nesting depth exactly `k`. -/
theorem untlDepth_nextPow (k : ℕ) (chi : PlusFormula) :
    untlDepth (nextPow k chi) = k + untlDepth chi := by
  induction k with
  | zero => simp [nextPow]
  | succ k ih =>
    simp only [nextPow, untlDepth, ih]
    omega

/-- **Mechanism (4)'s observable costs `untl`-depth `T + 1`.** -/
theorem untlDepth_phiDepth (T : ℕ) : untlDepth (phiDepth T) = T + 1 := by
  simp [phiDepth, untlDepth_nextPow, untlDepth, r]

/-- The `untl`-nesting depth is monotone along subformulas. -/
theorem untlDepth_le_of_mem_subformulas {ψ φ : PlusFormula}
    (hmem : ψ ∈ PlusFormula.subformulas φ) : untlDepth ψ ≤ untlDepth φ := by
  induction φ with
  | atom q =>
    simp only [PlusFormula.subformulas, List.mem_singleton] at hmem
    subst hmem
    exact le_rfl
  | bot =>
    simp only [PlusFormula.subformulas, List.mem_singleton] at hmem
    subst hmem
    exact le_rfl
  | imp a b iha ihb =>
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at hmem
    rcases hmem with rfl | h | h
    · exact le_rfl
    · exact le_trans (iha h) (by simp only [untlDepth]; omega)
    · exact le_trans (ihb h) (by simp only [untlDepth]; omega)
  | box a iha =>
    simp only [PlusFormula.subformulas, List.mem_cons] at hmem
    rcases hmem with rfl | h
    · exact le_rfl
    · exact iha h
  | untl a b iha ihb =>
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at hmem
    rcases hmem with rfl | h | h
    · exact le_rfl
    · exact le_trans (ihb h) (by simp only [untlDepth]; omega)
    · exact le_trans (iha h) (by simp only [untlDepth]; omega)
  | snce a b iha ihb =>
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at hmem
    rcases hmem with rfl | h | h
    · exact le_rfl
    · exact le_trans (ihb h) (by simp only [untlDepth]; omega)
    · exact le_trans (iha h) (by simp only [untlDepth]; omega)
  | stab a iha =>
    simp only [PlusFormula.subformulas, List.mem_cons] at hmem
    rcases hmem with rfl | h
    · exact le_rfl
    · exact iha h

theorem untlDepth_le_of_mem_closure {ψ φ : PlusFormula}
    (h : ψ ∈ plusSubformulaClosure φ) : untlDepth ψ ≤ untlDepth φ :=
  untlDepth_le_of_mem_subformulas (List.mem_toFinset.mp h)

/-- **GATE 4 IS DISARMED, and by a diagonal that cannot be closed.**  Mechanism (4) separates its
collision pair by the depth-`(T+1)` next-chain; that formula costs `untl`-depth `T + 1`, so it
lies in the closure of no formula whose `untl`-depth is at most `T`.  At the rule's own threshold
`T = thrJ φ = untlDepth φ` the observable is therefore outside `cl φ` for EVERY `φ`: the
refutation that kills every object-exhibited threshold has no witness left once the threshold is
read off the formula. -/
theorem gate4_witness_not_in_closure (φ : PlusFormula) (T : ℕ) (hT : untlDepth φ ≤ T) :
    phiDepth T ∉ plusSubformulaClosure φ := by
  intro hmem
  have h := untlDepth_le_of_mem_closure hmem
  rw [untlDepth_phiDepth] at h
  omega

/-- **GATE 4, at the rule's own threshold.** -/
theorem gate4_disarmed (φ : PlusFormula) : phiDepth (thrJ φ) ∉ plusSubformulaClosure φ :=
  gate4_witness_not_in_closure φ (thrJ φ) le_rfl

/-- **The diagonal does not close.**  Taking mechanism (4)'s own observable as the formula does
not recover the refutation: the threshold the rule then derives is `T + 1`, strictly above the
depth that observable reads, so the pair the index must keep apart moves with the formula and the
witness never catches it. -/
theorem gate4_diagonal_escapes (T : ℕ) : T < thrJ (phiDepth T) := by
  simp only [thrJ, untlDepth_phiDepth]
  omega

/-! ## The shared object of gates 5 and 6: two pending cycles of coprime lengths sharing a state

The OBJECT below is the fifteenth probe's coprime-cycle fixture, ported unchanged: pending edges
`a → b → c → a` and `a → d → a`.  Frames do not depend on a labelling, so the frame, its
regularity, its histories and the reference run are shared by both gates; what the two gates
differ in is the LABELLING -- gate 5 gives `d` a letter of its own, gate 6 makes `d`
label-identical to `b` -- and the separating formula. -/

/-- Object states `(pending?, index)`; pending indices `0 = a`, `1 = b`, `2 = c`, `3 = d`. -/
abbrev Q5 : Type := Bool × Fin 4

def pend5 : Q5 → Bool := fun q => q.1

/-- Pending edges `a → b → c → a` and `a → d → a` (a 3-cycle and a 2-cycle sharing `a`); every
pending `(true, i)` steps to its idle copy `(false, i)`; idle states self-loop. -/
def step5 : Q5 → Q5 → Bool := fun x y =>
  if x.1 then
    (if y.1 then
      ((x.2 == 0 && (y.2 == 1 || y.2 == 3)) || (x.2 == 1 && y.2 == 2) ||
        (x.2 == 2 && y.2 == 0) || (x.2 == 3 && y.2 == 0))
     else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

theorem rlad5_iff (t : ℤ) (x y : Q5 × ℕ × ℕ) :
    Rlad step5 pend5 t x y ↔
      step5 x.1 y.1 = true ∧ (x.1.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧
        Count x.1.1 y.1.1 x.2.1 x.2.2 y.2.1 := Iff.rfl

/-- A pending successor index: `a → b`, `b → c`, `c → a`, `d → a`. -/
def nxt : Fin 4 → Fin 4 := fun i => if i = 0 then 1 else if i = 1 then 2 else 0

/-- A pending predecessor index: `a` from `c`, `b` from `a`, `c` from `b`, `d` from `a`. -/
def prv : Fin 4 → Fin 4 := fun i =>
  if i = 0 then 2 else if i = 1 then 0 else if i = 2 then 1 else 0

theorem step5_nxt : ∀ i : Fin 4, step5 (true, i) (true, nxt i) = true := by decide

theorem step5_prv : ∀ i : Fin 4, step5 (true, prv i) (true, i) = true := by decide

theorem fwd5 : ∀ t x, ∃ y, RladAdm step5 pend5 t x y := by
  rintro t ⟨⟨⟨b, i⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad5_iff, step5, Drift, Count]⟩
  | true =>
    cases c with
    | zero =>
      exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
        simp [RladAdm, rlad5_iff, step5, Drift, Count]⟩
    | succ c =>
      exact ⟨⟨((true, nxt i), c, n), fun h => by cases h⟩, by
        simp [RladAdm, rlad5_iff, Drift, Count, step5_nxt]⟩

theorem bwd5 : ∀ t x, ∃ y, RladAdm step5 pend5 (t - 1) y x := by
  rintro t ⟨⟨⟨b, i⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, i), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad5_iff, step5, Drift, Count]⟩
  | true =>
    exact ⟨⟨((true, prv i), c + 1, n), fun h => by cases h⟩, by
      simp [RladAdm, rlad5_iff, Drift, Count, step5_prv]⟩

def F5 : FrameOver intOrder := ladderFrameAdm step5 pend5 fwd5 bwd5

instance : F5.IsRegular := ladderFrameAdm_isRegular step5 pend5 fwd5 bwd5

/-- A pending admissible ladder state of the shared object. -/
def st5 (i : Fin 4) (c n : ℕ) : LadderState Q5 pend5 :=
  ⟨((true, i), c, n), fun h => by cases h⟩

def a5 : Q5 := (true, 0)

/-! ### The exhibited threshold and period of the shared object's full-graph reach sets -/

/-- From `a`, four steps reach every state. -/
theorem reach5_four : (reachStep step5)^[4] {a5} = Finset.univ := by decide

/-- Every state has a predecessor, so the full set is a fixed point of `reachStep`. -/
theorem reachStep5_univ : reachStep step5 Finset.univ = Finset.univ := by decide

/-- **Period `1` is an exhibited period of this object, from threshold `4`** -- exactly the shape
`reachN_eventually_periodic` returns, with the minimal period. -/
theorem reach5_eventually_constant :
    ∀ k : ℕ, 4 ≤ k → (reachStep step5)^[k + 1] {a5} = (reachStep step5)^[k] {a5} := by
  intro k hk
  obtain ⟨m, rfl⟩ : ∃ m, k = 4 + m := ⟨k - 4, by omega⟩
  have huniv : ∀ m, (reachStep step5)^[4 + m] {a5} = Finset.univ := by
    intro m
    induction m with
    | zero => exact reach5_four
    | succ m ih =>
      rw [show 4 + (m + 1) = (4 + m) + 1 by omega, Function.iterate_succ_apply', ih,
        reachStep5_univ]
  rw [show 4 + m + 1 = 4 + (m + 1) by omega, huniv, huniv]

/-! ### The 3-cycle as a function of distance -/

/-- The index `i` pending steps after `a` along the 3-cycle. -/
def cyc (i : ℤ) : Fin 4 := ⟨(i % 3).toNat, by omega⟩

theorem cyc_cases (i : ℤ) :
    (cyc i = 0 ∧ cyc (i + 1) = 1) ∨ (cyc i = 1 ∧ cyc (i + 1) = 2) ∨
      (cyc i = 2 ∧ cyc (i + 1) = 0) := by
  have h3 : i % 3 = 0 ∨ i % 3 = 1 ∨ i % 3 = 2 := by omega
  rcases h3 with h | h | h
  · exact Or.inl ⟨Fin.ext (by change (i % 3).toNat = 0; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 1; omega)⟩
  · exact Or.inr (Or.inl ⟨Fin.ext (by change (i % 3).toNat = 1; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 2; omega)⟩)
  · exact Or.inr (Or.inr ⟨Fin.ext (by change (i % 3).toNat = 2; omega),
      Fin.ext (by change ((i + 1) % 3).toNat = 0; omega)⟩)

/-- The 3-cycle never visits `d`. -/
theorem cyc_ne_three (i : ℤ) : cyc i ≠ 3 := fun h => by
  have h' : (i % 3).toNat = 3 := congrArg Fin.val h
  omega

theorem step5_cyc_succ (i : ℤ) : step5 (true, cyc i) (true, cyc (i + 1)) = true := by
  rcases cyc_cases i with ⟨h0, h1⟩ | ⟨h0, h1⟩ | ⟨h0, h1⟩ <;> rw [h0, h1] <;> decide

/-- **The `d`-free pending successor of a 3-cycle state is the next 3-cycle state.** -/
theorem step5_cyc (i : ℤ) (j : Fin 4) (hs : step5 (true, cyc i) (true, j) = true)
    (hj : j ≠ 3) : j = cyc (i + 1) := by
  rcases cyc_cases i with ⟨h0, h1⟩ | ⟨h0, h1⟩ | ⟨h0, h1⟩ <;>
    (rw [h0] at hs; rw [h1]; revert j; decide)

theorem cyc_zero (c : ℕ) (h : 3 ∣ c) : cyc c = 0 :=
  Fin.ext (by change ((c : ℤ) % 3).toNat = 0; omega)

theorem dvd_of_cyc_zero (c : ℕ) (h : cyc c = 0) : 3 ∣ c := by
  have h' : ((c : ℤ) % 3).toNat = 0 := congrArg Fin.val h
  omega

/-- **`d`'s only pending predecessor is `a`.** -/
theorem pred_of_d (i : Fin 4) (hs : step5 (true, i) (true, 3) = true) : i = 0 := by
  revert i; decide

/-- **`d`'s only pending successor is `a`.** -/
theorem succ_of_d (j : Fin 4) (hs : step5 (true, 3) (true, j) = true) : j = 0 := by
  revert j; decide

/-! ### Histories of the shared frame -/

theorem hist_path5 (σ : WorldHistory F5) :
    ∃ (k : ℤ) (g : ℤ → LadderState Q5 pend5),
      IsSlicedStepPath (RladAdm step5 pend5) k g ∧ σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step5 pend5) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwd5 bwd5 σ.path).mp ⟨σ, rfl⟩

theorem hist_of_path5 (k : ℤ) (g : ℤ → LadderState Q5 pend5)
    (hg : IsSlicedStepPath (RladAdm step5 pend5) k g) :
    ∃ σ : WorldHistory F5, σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step5 pend5) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwd5 bwd5 _).mpr ⟨k, g, hg, rfl⟩

/-! ### The forced run: the index follows the 3-cycle while `d` is avoided -/

section Run5
variable {g : ℤ → LadderState Q5 pend5}
  (hg : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1)
include hg

/-- **Along a `d`-free pending run from `a`, position `i` is `(true, cyc i)`**, so the run is back
at `a` only at `i ≡ 0 (mod 3)`. -/
theorem walk_mod3 (c n : ℕ) (h0 : (g 0).1 = ((true, 0), c, n)) :
    ∀ i : ℕ, i ≤ c → (∀ j : ℕ, 1 ≤ j → j ≤ i → (g (j : ℤ)).1.1 ≠ (true, 3)) →
      (g (i : ℤ)).1.1 = (true, cyc (i : ℤ)) := by
  intro i
  induction i with
  | zero =>
    intro _ _
    have h00 : cyc 0 = 0 := by decide
    rw [Nat.cast_zero, h0, h00]
  | succ i ih =>
    intro hi hd
    have hprev := ih (by omega) (fun j h1 h2 => hd j h1 (by omega))
    have hpend : (g ((i + 1 : ℕ) : ℤ)).1.1.1 = true :=
      (pending_run_gen hg (true, 0) c n rfl h0 (i + 1) hi).1
    have hne : (g ((i + 1 : ℕ) : ℤ)).1.1 ≠ (true, 3) := hd (i + 1) (by omega) le_rfl
    obtain ⟨hs, -, -, -⟩ := hg (i : ℤ)
    rw [show ((i + 1 : ℕ) : ℤ) = (i : ℤ) + 1 by push_cast; ring] at hpend hne ⊢
    have hsplit : (g ((i : ℤ) + 1)).1.1 = (true, (g ((i : ℤ) + 1)).1.1.2) :=
      Prod.ext hpend rfl
    rw [hsplit, hprev] at hs
    have hj : (g ((i : ℤ) + 1)).1.1.2 ≠ 3 := fun h => hne (by rw [hsplit, h])
    rw [hsplit, step5_cyc (i : ℤ) _ hs hj]

/-- **The idle state ending a region copies the index of the last pending state.** -/
theorem idle_copy5 (i0 : Fin 4) (c n : ℕ) (h0 : (g 0).1 = ((true, i0), c, n)) :
    (g ((c : ℤ) + 1)).1.1.2 = (g (c : ℤ)).1.1.2 := by
  have hq1 : (g (c : ℤ)).1.1.1 = true :=
    (pending_run_gen hg (true, i0) c n rfl h0 c le_rfl).1
  have hy : (g ((c : ℤ) + 1)).1.1.1 = false := idle_at_gen hg (true, i0) c n rfl h0
  obtain ⟨hs, -, -, -⟩ := hg (c : ℤ)
  simpa [step5, hq1, hy] using hs

end Run5

/-! ### The reference history along the 3-cycle -/

/-- Counts the region down along the 3-cycle with `n` fixed, idle at the copy of the last pending
index ever after; extended backwards along the 3-cycle. -/
def g5RefRaw (c n : ℕ) (t : ℤ) : Q5 × ℕ × ℕ :=
  if t ≤ (c : ℤ) then ((true, cyc t), ((c : ℤ) - t).toNat, n)
  else ((false, cyc (c : ℤ)), 0, n)

theorem g5RefRaw_adm (c n : ℕ) (t : ℤ) :
    (g5RefRaw c n t).2.1 ∈ Adm pend5 (g5RefRaw c n t).1 := by
  change (g5RefRaw c n t).1.1 = false → (g5RefRaw c n t).2.1 = 0
  unfold g5RefRaw
  split_ifs <;> simp

def g5Ref (c n : ℕ) (t : ℤ) : LadderState Q5 pend5 :=
  ⟨g5RefRaw c n t, g5RefRaw_adm c n t⟩

theorem g5RefRaw_step (c n : ℕ) (t : ℤ) :
    Rlad step5 pend5 0 (g5RefRaw c n t) (g5RefRaw c n (t + 1)) := by
  rw [rlad5_iff]
  unfold g5RefRaw
  rcases lt_trichotomy t (c : ℤ) with hlt | heq | hgt
  · have h1 : t ≤ (c : ℤ) := le_of_lt hlt
    have h2 : t + 1 ≤ (c : ℤ) := by omega
    rw [if_pos h1, if_pos h2]
    refine ⟨step5_cyc_succ t, by simp, Or.inl rfl, ?_⟩
    change Count true true (((c : ℤ) - t).toNat) n (((c : ℤ) - (t + 1)).toNat)
    rw [count_tt]
    omega
  · have h1 : t ≤ (c : ℤ) := le_of_eq heq
    have h2 : ¬ (t + 1 ≤ (c : ℤ)) := by omega
    rw [if_pos h1, if_neg h2, heq]
    refine ⟨by simp [step5], by simp, Or.inl rfl, ?_⟩
    change Count true false (((c : ℤ) - (c : ℤ)).toNat) n 0
    rw [count_tf]
    omega
  · have h1 : ¬ (t ≤ (c : ℤ)) := by omega
    have h2 : ¬ (t + 1 ≤ (c : ℤ)) := by omega
    rw [if_neg h1, if_neg h2]
    refine ⟨by simp [step5], by simp, Or.inl rfl, ?_⟩
    change Count false false 0 n 0
    rw [count_ff]

theorem g5Ref_isPath (c n : ℕ) :
    IsSlicedStepPath (RladAdm step5 pend5) 0 (g5Ref c n) := by
  intro t
  change Rlad step5 pend5 (t + 0) (g5RefRaw c n t) (g5RefRaw c n (t + 1))
  have h : Rlad step5 pend5 (t + 0) (g5RefRaw c n t) (g5RefRaw c n (t + 1)) ↔
      Rlad step5 pend5 0 (g5RefRaw c n t) (g5RefRaw c n (t + 1)) := Iff.rfl
  rw [h]
  exact g5RefRaw_step c n t

theorem g5Ref_zero (c n : ℕ) : (g5Ref c n 0).1 = ((true, 0), c, n) := by
  change g5RefRaw c n 0 = ((true, 0), c, n)
  unfold g5RefRaw
  rw [if_pos (by positivity : (0 : ℤ) ≤ (c : ℤ))]
  have h00 : cyc 0 = 0 := by decide
  simp [h00]

/-! ### The truth layer, generic in the labelling

`p`, `r` and `l_a` are read the same way under every labelling that assigns them as below, so the
whole until-reading of a region's end is proved once and instantiated twice. -/

def la : PlusFormula := .atom aA

/-- `p U (r AND l_a)`: the region ends on the idle copy of `a`. -/
def endA : PlusFormula := .untl p (r.and la)

/-- The model over the shared frame with a given labelling. -/
def Mof (lab : Q5 → Atom → Bool) : TaskModel F5.toTaskFrame :=
  ladderModel step5 pend5 fwd5 bwd5 lab

theorem state_eqL {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) : σ.state s = (s + k, g s) := congrFun hσ s

theorem truth_pL (lab : Q5 → Atom → Bool) (hlp : ∀ q, lab q pA = q.1)
    {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) :
    PlusTruthAt (Mof lab) σ s p ↔ (g s).1.1.1 = true := by
  change (Mof lab).valuation (σ.state s) pA ↔ _
  rw [state_eqL hσ s]
  simp [Mof, ladderModel, hlp]

theorem truth_rL (lab : Q5 → Atom → Bool) (hlr : ∀ q, lab q rA = !q.1)
    {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) :
    PlusTruthAt (Mof lab) σ s r ↔ (g s).1.1.1 = false := by
  change (Mof lab).valuation (σ.state s) rA ↔ _
  rw [state_eqL hσ s]
  simp [Mof, ladderModel, hlr]

theorem truth_laL (lab : Q5 → Atom → Bool) (hla : ∀ q, lab q aA = (q.2 == 0))
    {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) :
    PlusTruthAt (Mof lab) σ s la ↔ (g s).1.1.2 = 0 := by
  change (Mof lab).valuation (σ.state s) aA ↔ _
  rw [state_eqL hσ s]
  simp [Mof, ladderModel, hla]

/-- **`p U (r AND l_a)` at a pending state reads the index of the region's idle end**: the until
is forced to fire at `c + 1`, the first idle position, and nowhere else. -/
theorem endA_at_zero_iffL (lab : Q5 → Atom → Bool) (hlp : ∀ q, lab q pA = q.1)
    (hlr : ∀ q, lab q rA = !q.1) (hla : ∀ q, lab q aA = (q.2 == 0))
    {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1)
    (i0 : Fin 4) (c n : ℕ) (h0 : (g 0).1 = ((true, i0), c, n)) :
    PlusTruthAt (Mof lab) σ 0 endA ↔ (g ((c : ℤ) + 1)).1.1.2 = 0 := by
  constructor
  · rintro ⟨(s : ℤ), hs, hχ, hguard⟩
    have hs' : (0 : ℤ) < s := hs
    rw [PlusTruth.and_iff, truth_rL lab hlr hσ, truth_laL lab hla hσ] at hχ
    obtain ⟨hr, ha⟩ := hχ
    rcases lt_trichotomy s ((c : ℤ) + 1) with hlt | heq | hgt
    · have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg (by omega)
      have hle : s.toNat ≤ c := by omega
      have hq1 : (g ((s.toNat : ℕ) : ℤ)).1.1.1 = true :=
        (pending_run_gen hg (true, i0) c n rfl h0 s.toNat hle).1
      rw [hsn, hr] at hq1
      exact absurd hq1 Bool.false_ne_true
    · subst heq
      exact ha
    · have hp := hguard ((c : ℤ) + 1) (show (0 : ℤ) < (c : ℤ) + 1 by omega) hgt
      rw [truth_pL lab hlp hσ] at hp
      have hidle : (g ((c : ℤ) + 1)).1.1.1 = false := idle_at_gen hg (true, i0) c n rfl h0
      rw [hidle] at hp
      exact absurd hp Bool.false_ne_true
  · intro ha
    refine ⟨(c : ℤ) + 1, show (0 : ℤ) < (c : ℤ) + 1 by omega, ?_, ?_⟩
    · rw [PlusTruth.and_iff, truth_rL lab hlr hσ, truth_laL lab hla hσ]
      exact ⟨idle_at_gen hg (true, i0) c n rfl h0, ha⟩
    · intro (s' : ℤ) h1 h2
      have h1' : (0 : ℤ) < s' := h1
      have h2' : s' < (c : ℤ) + 1 := h2
      rw [truth_pL lab hlp hσ]
      have hsn : ((s'.toNat : ℕ) : ℤ) = s' := Int.toNat_of_nonneg (by omega)
      have hle : s'.toNat ≤ c := by omega
      have hq1 : (g ((s'.toNat : ℕ) : ℤ)).1.1.1 = true :=
        (pending_run_gen hg (true, i0) c n rfl h0 s'.toNat hle).1
      rw [hsn] at hq1
      exact hq1

/-- Along the reference history with `3 ∣ c`, the region ends on the idle copy of `a`. -/
theorem endA_refL (lab : Q5 → Atom → Bool) (hlp : ∀ q, lab q pA = q.1)
    (hlr : ∀ q, lab q rA = !q.1) (hla : ∀ q, lab q aA = (q.2 == 0))
    (c n : ℕ) (hc : 3 ∣ c) {σ : WorldHistory F5}
    (hσ : σ.path = fun t => (t + 0, g5Ref c n t)) : PlusTruthAt (Mof lab) σ 0 endA := by
  rw [endA_at_zero_iffL lab hlp hlr hla hσ (fun t => g5Ref_isPath c n t) 0 c n (g5Ref_zero c n)]
  change (g5RefRaw c n ((c : ℤ) + 1)).1.2 = 0
  unfold g5RefRaw
  rw [if_neg (by omega)]
  exact cyc_zero c hc

/-- The index collision recipe, at an arbitrary countdown `C ≥ T`: both countdowns saturate the
threshold, the residues agree modulo `P + 1`, the next deadline is shared, both gaps clip. -/
theorem collide5 (T P B C : ℕ) (hTC : T ≤ C) :
    ladderIndexJnt T P B (st5 0 C (C + (P + 1) + B))
      = ladderIndexJnt T P B (st5 0 (C + (P + 1)) (C + (P + 1) + B)) := by
  simp only [ladderIndexJnt, st5, Prod.mk.injEq, Fin.mk.injEq, true_and]
  and_intros <;> first | omega | exact (Nat.add_mod_right C (P + 1)).symm

/-- A countdown divisible by `3` and by `P + 1`, at or above every threshold `T`. -/
def c5 (T P : ℕ) : ℕ := 3 * (P + 1) * (T + 1)

theorem c5_dvd (T P : ℕ) : 3 ∣ c5 T P := ⟨(P + 1) * (T + 1), by unfold c5; ring⟩

theorem le_c5 (T P : ℕ) : T ≤ c5 T P := by
  have h := Nat.le_mul_of_pos_left (T + 1) (show 0 < 3 * (P + 1) by positivity)
  unfold c5
  generalize 3 * (P + 1) * (T + 1) = C at h ⊢
  omega

def x5 (T P B : ℕ) : LadderState Q5 pend5 :=
  st5 0 (c5 T P) (c5 T P + (P + 1) + B)

def y5 (T P B : ℕ) : LadderState Q5 pend5 :=
  st5 0 (c5 T P + (P + 1)) (c5 T P + (P + 1) + B)

/-- **The pair collides in the index for EVERY `(T, P, B)`.** -/
theorem period_collision (T P B : ℕ) :
    ladderIndexJnt T P B (x5 T P B) = ladderIndexJnt T P B (y5 T P B) :=
  collide5 T P B (c5 T P) (le_c5 T P)

/-! ## Part V: gate 5, re-run against the FORMULA-COUPLED modulus

Gate 5's labelling gives `d` a letter of its own.  The sub-object that forbids that letter is
therefore LETTER-DEFINABLE, its `a`-to-`a` walks all have length divisible by three, and the
rule's modulus clause consequently forces `3 ∣ P + 1` on this object.  Mechanism (5)'s refutation
is stated under `¬ 3 ∣ P + 1`, so at a rule-admissible modulus its witness is gone -- and the
theorems below exhibit that directly, rather than observing that a hypothesis has become
unsatisfiable. -/

/-- `p` pending, `r` idle, `a` index `0`, `d` PENDING index `3`. -/
def lab5 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1
  else if at_ = aA then (q.2 == 0) else if at_ = dA then (q.1 && q.2 == 3) else false

theorem lab5_p : ∀ q, lab5 q pA = q.1 := fun _ => by simp [lab5]
theorem lab5_r : ∀ q, lab5 q rA = !q.1 := fun _ => by simp [lab5, pA_ne_rA.symm]
theorem lab5_a : ∀ q, lab5 q aA = (q.2 == 0) := fun _ => by simp [lab5, aA_ne_pA, aA_ne_rA]
theorem lab5_d : ∀ q, lab5 q dA = (q.1 && q.2 == 3) := fun _ => by
  simp [lab5, dA_ne_pA, dA_ne_rA, dA_ne_aA]

/-- **`d` carries a letter of its own**: `l_d` is true at the pending state `d` and at no other
state, so the `d`-free sub-object is LETTER-DEFINABLE -- which is what makes gate 5's object fall
under the rule's modulus clause. -/
theorem lab5_d_only (q : Q5) : lab5 q dA = true ↔ q = (true, 3) := by
  rw [lab5_d]
  constructor
  · intro h
    simp only [Bool.and_eq_true, beq_iff_eq] at h
    exact Prod.ext h.1 h.2
  · intro h
    subst h
    decide

def M5 : TaskModel F5.toTaskFrame := Mof lab5

def ld : PlusFormula := .atom dA

/-- `top U l_d`, with `top := bot -> bot`: some strictly later state is pending `d`. -/
def evD : PlusFormula := .untl (.imp .bot .bot) ld

/-- Gate 5's probe formula; both observables are in its closure. -/
def phi5 : PlusFormula := .imp endA evD

theorem truth_ld5 {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) :
    PlusTruthAt M5 σ s ld ↔ (g s).1.1.1 = true ∧ (g s).1.1.2 = 3 := by
  change M5.valuation (σ.state s) dA ↔ _
  rw [state_eqL hσ s]
  simp [M5, Mof, ladderModel, lab5_d]

/-- A pending-`d` position strictly after `0` makes `top U l_d` true at `0`. -/
theorem evD_of_ld {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (j : ℕ) (hj : 1 ≤ j)
    (hld : (g (j : ℤ)).1.1 = (true, 3)) : PlusTruthAt M5 σ 0 evD := by
  refine ⟨(j : ℤ), show (0 : ℤ) < (j : ℤ) by omega, ?_, ?_⟩
  · rw [truth_ld5 hσ]
    exact ⟨congrArg Prod.fst hld, congrArg Prod.snd hld⟩
  · intro _ _ _ h
    exact h

/-- Along the reference history no position carries `l_d`. -/
theorem not_evD_ref (c n : ℕ) {σ : WorldHistory F5}
    (hσ : σ.path = fun t => (t + 0, g5Ref c n t)) : ¬ PlusTruthAt M5 σ 0 evD := by
  rintro ⟨(s : ℤ), -, hld, -⟩
  rw [truth_ld5 hσ] at hld
  obtain ⟨hp, hd⟩ := hld
  change (g5RefRaw c n s).1.1 = true at hp
  change (g5RefRaw c n s).1.2 = 3 at hd
  unfold g5RefRaw at hp hd
  by_cases h : s ≤ (c : ℤ)
  · rw [if_pos h] at hd
    exact cyc_ne_three s hd
  · rw [if_neg h] at hp
    exact Bool.false_ne_true hp

/-- **The cell at `(a, c, n)` with `3 ∣ c` contains a type WITHOUT `phi5`**: the reference history
satisfies `endA` and refutes `evD`. -/
theorem exists_cell_not_phi5 (c n : ℕ) (hc : 3 ∣ c) :
    ∃ T', T' ∈ cellAt M5 phi5 ((0 : ℤ), st5 0 c n) 0 ∧ phi5 ∉ T' := by
  obtain ⟨σ, hσ⟩ := hist_of_path5 0 (g5Ref c n) (g5Ref_isPath c n)
  refine ⟨tpOf M5 phi5 σ 0, ⟨σ, ?_, rfl⟩, ?_⟩
  · have hw : ((0 : ℤ), g5Ref c n 0) = ((0 : ℤ), st5 0 c n) :=
      Prod.ext rfl (Subtype.ext (g5Ref_zero c n))
    rw [← hw]
    exact congrFun hσ 0
  · rw [mem_tpOf_iff]
    rintro ⟨-, hφ⟩
    have hφ' : PlusTruthAt M5 σ 0 endA → PlusTruthAt M5 σ 0 evD := hφ
    exact not_evD_ref c n hσ
      (hφ' (endA_refL lab5 lab5_p lab5_r lab5_a c n hc hσ))

/-- **The `d`-free sub-object's `a`-to-`a` walk lengths are exactly the multiples of three.**  The
sub-object is letter-definable (`lab5_d_only`), so this is the period the rule's modulus clause
must divide on gate 5's object. -/
theorem dfree_walk_mod3 {g : ℤ → LadderState Q5 pend5}
    (hg : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1) (c n : ℕ)
    (h0 : (g 0).1 = ((true, 0), c, n))
    (hfree : ∀ j : ℕ, 1 ≤ j → j ≤ c → (g (j : ℤ)).1.1 ≠ (true, 3))
    (hback : (g (c : ℤ)).1.1.2 = 0) : 3 ∣ c := by
  have hw := walk_mod3 hg c n h0 c le_rfl hfree
  have h2 := congrArg Prod.snd hw
  rw [hback] at h2
  exact dvd_of_cyc_zero c h2.symm

/-- **Every type in the cell at `(a, C + (P+1), n)` with `3 ∣ C` and `3 ∤ P + 1` contains
`phi5`**: if the region ends on the idle copy of `a`, the run returned to `a` after `C + (P+1)`
pending steps, which is not a multiple of `3`, so the run left the 3-cycle through `d`. -/
theorem phi5_mem_of_mem_cell (C P n : ℕ) (hC : 3 ∣ C) (h3 : ¬ 3 ∣ (P + 1))
    (T' : Finset PlusFormula)
    (hT : T' ∈ cellAt M5 phi5 ((0 : ℤ), st5 0 (C + (P + 1)) n) 0) : phi5 ∈ T' := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path5 σ
  have hst : ((0 : ℤ) + k, g 0) = ((0 : ℤ), st5 0 (C + (P + 1)) n) := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, 0), C + (P + 1), n) :=
    congrArg (fun w : ℤ × LadderState Q5 pend5 => w.2.1) hst
  have hg' : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1 := fun t => hg t
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
  change PlusTruthAt M5 σ 0 endA → PlusTruthAt M5 σ 0 evD
  intro hendA
  have hidx : (g ((C + (P + 1) : ℕ) : ℤ)).1.1.2 = 0 := by
    have h1 := (endA_at_zero_iffL lab5 lab5_p lab5_r lab5_a hpath hg' 0 (C + (P + 1)) n hg0).mp
      hendA
    rw [idle_copy5 hg' 0 (C + (P + 1)) n hg0] at h1
    exact h1
  by_cases hd : ∃ j : ℕ, 1 ≤ j ∧ j ≤ C + (P + 1) ∧ (g (j : ℤ)).1.1 = (true, 3)
  · obtain ⟨j, hj1, -, hjd⟩ := hd
    exact evD_of_ld hpath j hj1 hjd
  · exfalso
    have hfree : ∀ j : ℕ, 1 ≤ j → j ≤ C + (P + 1) → (g (j : ℤ)).1.1 ≠ (true, 3) :=
      fun j h1 h2 heq => hd ⟨j, h1, h2, heq⟩
    have hdvd := dfree_walk_mod3 hg' (C + (P + 1)) n hg0 hfree hidx
    omega

/-- **Gate 5's refutation, re-stated at the parameters it actually refutes**: for every threshold,
every clip bound and every modulus coprime to `3`, the index does not factor this fixture's
cells.  The rule's modulus clause is exactly what excludes those moduli here. -/
theorem reach_period_refuted (T P B : ℕ) (h3 : ¬ 3 ∣ (P + 1)) :
    ¬ ∀ x y : LadderState Q5 pend5, ladderIndexJnt T P B x = ladderIndexJnt T P B y →
        cellAt M5 phi5 ((0 : ℤ), x) 0 = cellAt M5 phi5 ((0 : ℤ), y) 0 := by
  intro h
  have hne : cellAt M5 phi5 ((0 : ℤ), x5 T P B) 0 ≠ cellAt M5 phi5 ((0 : ℤ), y5 T P B) 0 := by
    intro heq
    unfold x5 y5 at heq
    obtain ⟨T', hT', hnot⟩ :=
      exists_cell_not_phi5 (c5 T P) (c5 T P + (P + 1) + B) (c5_dvd T P)
    rw [heq] at hT'
    exact hnot (phi5_mem_of_mem_cell (c5 T P) P (c5 T P + (P + 1) + B) (c5_dvd T P) h3 T' hT')
  exact hne (h _ _ (period_collision T P B))

/-- **GATE 5 IS DISARMED.**  At a modulus the rule admits on this object -- `3 ∣ P + 1`, forced by
the letter-definable `d`-free sub-object whose walk lengths are the multiples of three -- gate 5's
witness pair is no longer separated by its own formula: BOTH cells contain a type lacking `phi5`,
because both countdowns are divisible by three and the reference 3-cycle history runs through each
of them.  This is the separation failing, not a hypothesis going unsatisfiable. -/
theorem gate5_disarmed (T P B : ℕ) (h3 : 3 ∣ (P + 1)) :
    (∃ T', T' ∈ cellAt M5 phi5 ((0 : ℤ), x5 T P B) 0 ∧ phi5 ∉ T') ∧
      (∃ T', T' ∈ cellAt M5 phi5 ((0 : ℤ), y5 T P B) 0 ∧ phi5 ∉ T') := by
  refine ⟨exists_cell_not_phi5 (c5 T P) (c5 T P + (P + 1) + B) (c5_dvd T P), ?_⟩
  exact exists_cell_not_phi5 (c5 T P + (P + 1)) (c5 T P + (P + 1) + B)
    (Nat.dvd_add (c5_dvd T P) h3)

/-! ## Part VI: gate 6 -- the modulus against a sub-object the formula's LETTERS cannot name

Gate 6 runs on the SAME object as gate 5 with one change: `d` is given the letter of `b`, so no
atom separates them.  Every letter-definable sub-object therefore contains `d` whenever it
contains `b`, the 3-cycle is not letter-definable, and the rule's modulus clause -- a multiple of
the period of every letter-definable sub-object -- imposes nothing beyond what the full graph's
exhibited period `1` imposes.  Yet a formula that forbids NO letter still carves the 3-cycle out,
by forbidding the PATTERN that only the 2-cycle exhibits. -/

/-- The letter shared by `b`, `c` and `d`. -/
def bA : Atom := ⟨"b", none⟩

theorem bA_ne_pA : bA ≠ pA := by simp [bA, pA]
theorem bA_ne_rA : bA ≠ rA := by simp [bA, rA]
theorem bA_ne_aA : bA ≠ aA := by simp [bA, aA]

/-- Gate 6's labelling: `p` pending, `r` idle, `l_a` index `0`, `l_b` every index OTHER than `0`
-- so `b`, `c` and `d` share one letter and `l_d` does not exist. -/
def lab6 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1
  else if at_ = aA then (q.2 == 0) else if at_ = bA then !(q.2 == 0) else false

theorem lab6_p : ∀ q, lab6 q pA = q.1 := fun _ => by simp [lab6]
theorem lab6_r : ∀ q, lab6 q rA = !q.1 := fun _ => by simp [lab6, pA_ne_rA.symm]
theorem lab6_a : ∀ q, lab6 q aA = (q.2 == 0) := fun _ => by simp [lab6, aA_ne_pA, aA_ne_rA]

/-- **`d` AND `b` ARE LABEL-IDENTICAL.**  No atom whatsoever distinguishes the pending state `d`
from the pending state `b`, so no formula's letters can: every letter-definable sub-object either
keeps both or drops both, and the 3-cycle `{a, b, c}` -- whose `a`-to-`a` walk lengths are the
multiples of three -- is not letter-definable.  This is the whole mechanism of gate 6, and it is
what makes the rule's modulus clause vacuous on this object. -/
theorem lab6_d_eq_b : ∀ at_ : Atom, lab6 ((true, 3) : Q5) at_ = lab6 ((true, 1) : Q5) at_ := by
  intro at_
  unfold lab6
  split_ifs <;> rfl

/-- The same fact as the rule uses it: a letter-restricted sub-object -- the states at which every
atom of a finite set `S` is false -- keeps `d` exactly when it keeps `b`. -/
theorem lab6_keep_d_iff_b (S : Finset Atom) :
    (∀ at_ ∈ S, lab6 ((true, 3) : Q5) at_ = false) ↔
      (∀ at_ ∈ S, lab6 ((true, 1) : Q5) at_ = false) := by
  constructor
  · intro h at_ hat
    rw [← lab6_d_eq_b at_]
    exact h at_ hat
  · intro h at_ hat
    rw [lab6_d_eq_b at_]
    exact h at_ hat

/-- **THE SUB-OBJECT WHOSE PERIOD THE FORMULA SEES IS NOT LETTER-DEFINABLE.**  The 3-cycle
`{a, b, c}` -- whose `a`-to-`a` walk lengths are exactly the multiples of three -- is cut out by no
set of atoms: any set of atoms false throughout it is false at `d` as well, and `d` is not in it.
This is the precise sense in which the rule's modulus clause, which quantifies over
LETTER-DEFINABLE sub-objects, never reaches the period that separates gate 6's pair. -/
theorem cycle_not_letter_definable :
    ¬ ∃ S : Finset Atom, ∀ q : Q5,
        (∀ at_ ∈ S, lab6 q at_ = false) ↔
          q ∈ ({(true, 0), (true, 1), (true, 2)} : Finset Q5) := by
  rintro ⟨S, hS⟩
  have hb : ((true, 1) : Q5) ∈ ({(true, 0), (true, 1), (true, 2)} : Finset Q5) := by decide
  have hkeepb := (hS (true, 1)).mpr hb
  have hkeepd := (lab6_keep_d_iff_b S).mpr hkeepb
  have hd := (hS (true, 3)).mp hkeepd
  exact absurd hd (by decide)

/-- **Wherever a letter restriction keeps the 3-cycle it keeps the 2-cycle too.**  So in every
letter-definable sub-object in which the long cycle survives, the short one survives beside it and
the shortest `a`-to-`a` return is `2`, not `3`: no letter restriction of this object exhibits a
period divisible by three. -/
theorem letter_definable_keeps_two_cycle (S : Finset Atom)
    (hb : ∀ at_ ∈ S, lab6 ((true, 1) : Q5) at_ = false) :
    (∀ at_ ∈ S, lab6 ((true, 3) : Q5) at_ = false) ∧
      step5 (true, 0) (true, 3) = true ∧ step5 (true, 3) (true, 0) = true :=
  ⟨(lab6_keep_d_iff_b S).mpr hb, by decide, by decide⟩

def M6 : TaskModel F5.toTaskFrame := Mof lab6

theorem truth_p6 {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) :
    PlusTruthAt M6 σ s p ↔ (g s).1.1.1 = true := truth_pL lab6 lab6_p hσ s

theorem truth_la6 {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) :
    PlusTruthAt M6 σ s la ↔ (g s).1.1.2 = 0 := truth_laL lab6 lab6_a hσ s

/-- The pending `a` state as a formula: `p AND l_a`. -/
def pa : PlusFormula := p.and la

/-- The PATTERN the 2-cycle exhibits and the 3-cycle does not: a pending `a` with a pending `a`
exactly two instants later.  It forbids no letter -- `l_a` is required, never forbidden, and no
atom of `b`, `c` or `d` appears at all. -/
def psi2 : PlusFormula := pa.and (nextPow 2 pa)

/-- Gate 6's constraint: the pattern fails here and at every strictly later instant. -/
def chi : PlusFormula := psi2.neg.and (PlusFormula.untl (.imp .bot .bot) psi2).neg

/-- Gate 6's probe formula. -/
def phi6 : PlusFormula := .imp endA chi.neg

theorem someFuture_iff (N : TaskModel F5.toTaskFrame) (σ : WorldHistory F5)
    (ψ : PlusFormula) (t : ℤ) :
    PlusTruthAt N σ t (PlusFormula.untl (.imp .bot .bot) ψ) ↔
      ∃ s : ℤ, t < s ∧ PlusTruthAt N σ s ψ := by
  constructor
  · rintro ⟨s, hs, hψ, -⟩
    exact ⟨s, hs, hψ⟩
  · rintro ⟨s, hs, hψ⟩
    exact ⟨s, hs, hψ, fun _ _ _ h => h⟩

theorem truth_pa6 {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) :
    PlusTruthAt M6 σ s pa ↔ (g s).1.1 = (true, 0) := by
  change PlusTruthAt M6 σ s (p.and la) ↔ _
  rw [PlusTruth.and_iff, truth_p6 hσ, truth_la6 hσ]
  constructor
  · intro h
    exact Prod.ext h.1 h.2
  · intro h
    exact ⟨congrArg Prod.fst h, congrArg Prod.snd h⟩

theorem truth_psi2 {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) (s : ℤ) :
    PlusTruthAt M6 σ s psi2 ↔ (g s).1.1 = (true, 0) ∧ (g (s + 2)).1.1 = (true, 0) := by
  change PlusTruthAt M6 σ s (pa.and (nextPow 2 pa)) ↔ _
  rw [PlusTruth.and_iff, truth_pa6 hσ, truth_nextPow, truth_pa6 hσ]
  norm_num

/-- Gate 6's constraint, unpacked: the pattern fails at every position from `0` on. -/
theorem chi_iff {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t)) :
    PlusTruthAt M6 σ 0 chi ↔
      ∀ s : ℤ, 0 ≤ s → ¬ ((g s).1.1 = (true, 0) ∧ (g (s + 2)).1.1 = (true, 0)) := by
  change PlusTruthAt M6 σ 0 (psi2.neg.and (PlusFormula.untl (.imp .bot .bot) psi2).neg) ↔ _
  rw [PlusTruth.and_iff, PlusTruth.neg_iff, PlusTruth.neg_iff, someFuture_iff]
  constructor
  · rintro ⟨h0, hlater⟩ s hs hψ
    rcases eq_or_lt_of_le hs with heq | hlt
    · exact h0 ((truth_psi2 hσ 0).mpr (by rw [← heq] at hψ; exact hψ))
    · exact hlater ⟨s, hlt, (truth_psi2 hσ s).mpr hψ⟩
  · intro h
    refine ⟨fun h0 => h 0 le_rfl ((truth_psi2 hσ 0).mp h0), ?_⟩
    rintro ⟨s, hs, hψ⟩
    exact h s (le_of_lt hs) ((truth_psi2 hσ s).mp hψ)

theorem cycZ_zero_iff (i : ℤ) : cyc i = 0 ↔ i % 3 = 0 := by
  constructor
  · intro h
    have h' : (i % 3).toNat = 0 := congrArg Fin.val h
    omega
  · intro h
    exact Fin.ext (by change (i % 3).toNat = 0; omega)

/-- **The reference 3-cycle history satisfies gate 6's constraint.**  A pending `a` sits exactly
at the positions `≡ 0 (mod 3)` of the region, and no two of those are two apart. -/
theorem chi_ref (c n : ℕ) {σ : WorldHistory F5}
    (hσ : σ.path = fun t => (t + 0, g5Ref c n t)) : PlusTruthAt M6 σ 0 chi := by
  rw [chi_iff hσ]
  rintro s hs ⟨h1, h2⟩
  have e1 : (g5RefRaw c n s).1 = (true, 0) := h1
  have e2 : (g5RefRaw c n (s + 2)).1 = (true, 0) := h2
  unfold g5RefRaw at e1 e2
  by_cases hc1 : s ≤ (c : ℤ)
  · by_cases hc2 : s + 2 ≤ (c : ℤ)
    · rw [if_pos hc1] at e1
      rw [if_pos hc2] at e2
      have hd1 : cyc s = 0 := congrArg Prod.snd e1
      have hd2 : cyc (s + 2) = 0 := congrArg Prod.snd e2
      rw [cycZ_zero_iff] at hd1 hd2
      omega
    · rw [if_neg hc2] at e2
      exact Bool.false_ne_true (congrArg Prod.fst e2)
  · rw [if_neg hc1] at e1
    exact Bool.false_ne_true (congrArg Prod.fst e1)

/-- **GATE 6's CORE STEP: the letter-free constraint forces the walk off the 2-cycle.**  A pending
`d` at a position strictly inside the region has pending `a` as its only predecessor and pending
`a` as its only successor, so it exhibits the forbidden pattern; at the region's last position it
would hand the idle end the index `d`, which `endA` forbids. -/
theorem chi_forces_dfree {σ : WorldHistory F5} {k : ℤ} {g : ℤ → LadderState Q5 pend5}
    (hσ : σ.path = fun t => (t + k, g t))
    (hg : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1) (C' n : ℕ)
    (h0 : (g 0).1 = ((true, 0), C', n)) (hchi : PlusTruthAt M6 σ 0 chi)
    (hidx : (g (C' : ℤ)).1.1.2 = 0) :
    ∀ j : ℕ, 1 ≤ j → j ≤ C' → (g (j : ℤ)).1.1 ≠ (true, 3) := by
  rw [chi_iff hσ] at hchi
  intro j hj1 hjC hjd
  rcases eq_or_lt_of_le hjC with heq | hlt
  · subst heq
    rw [hjd] at hidx
    exact absurd hidx (by decide)
  · -- the successor is pending, hence `a`
    have hsucc : (g ((j : ℤ) + 1)).1.1 = (true, 0) := by
      have hpend : pend5 (g ((j + 1 : ℕ) : ℤ)).1.1 = true :=
        (pending_run_gen hg (true, 0) C' n rfl h0 (j + 1) (by omega)).1
      rw [show ((j + 1 : ℕ) : ℤ) = (j : ℤ) + 1 by push_cast; ring] at hpend
      obtain ⟨hs, -, -, -⟩ := hg (j : ℤ)
      have hsplit : (g ((j : ℤ) + 1)).1.1 = (true, (g ((j : ℤ) + 1)).1.1.2) :=
        Prod.ext hpend rfl
      rw [hjd, hsplit] at hs
      rw [hsplit, succ_of_d _ hs]
    -- the predecessor is pending, hence `a`
    have hpre : (g ((j : ℤ) - 1)).1.1 = (true, 0) := by
      have hcast : ((j - 1 : ℕ) : ℤ) = (j : ℤ) - 1 := by
        have : 1 ≤ j := hj1
        push_cast [Nat.cast_sub this]
        ring
      have hpend : pend5 (g ((j - 1 : ℕ) : ℤ)).1.1 = true :=
        (pending_run_gen hg (true, 0) C' n rfl h0 (j - 1) (by omega)).1
      rw [hcast] at hpend
      obtain ⟨hs, -, -, -⟩ := hg ((j : ℤ) - 1)
      rw [show (j : ℤ) - 1 + 1 = (j : ℤ) by ring, hjd] at hs
      have hsplit : (g ((j : ℤ) - 1)).1.1 = (true, (g ((j : ℤ) - 1)).1.1.2) :=
        Prod.ext hpend rfl
      rw [hsplit] at hs
      rw [hsplit, pred_of_d _ hs]
    refine hchi ((j : ℤ) - 1) (by omega) ⟨hpre, ?_⟩
    rw [show (j : ℤ) - 1 + 2 = (j : ℤ) + 1 by ring]
    exact hsucc

/-- **The cell at `(a, c, n)` with `3 ∣ c` contains a type WITHOUT `phi6`**: the reference history
satisfies `endA` and satisfies `chi`. -/
theorem exists_cell_not_phi6 (c n : ℕ) (hc : 3 ∣ c) :
    ∃ T', T' ∈ cellAt M6 phi6 ((0 : ℤ), st5 0 c n) 0 ∧ phi6 ∉ T' := by
  obtain ⟨σ, hσ⟩ := hist_of_path5 0 (g5Ref c n) (g5Ref_isPath c n)
  refine ⟨tpOf M6 phi6 σ 0, ⟨σ, ?_, rfl⟩, ?_⟩
  · have hw : ((0 : ℤ), g5Ref c n 0) = ((0 : ℤ), st5 0 c n) :=
      Prod.ext rfl (Subtype.ext (g5Ref_zero c n))
    rw [← hw]
    exact congrFun hσ 0
  · rw [mem_tpOf_iff]
    rintro ⟨-, hφ⟩
    have hφ' : PlusTruthAt M6 σ 0 endA → ¬ PlusTruthAt M6 σ 0 chi := hφ
    exact hφ' (endA_refL lab6 lab6_p lab6_r lab6_a c n hc hσ) (chi_ref c n hσ)

/-- **Every type in the cell at `(a, C + (P+1), n)` with `3 ∣ C` and `3 ∤ P + 1` contains
`phi6`**: `endA` puts the region's return at `a` after `C + (P+1)` pending steps, `chi` keeps the
walk on the 3-cycle, and the 3-cycle returns to `a` only after a multiple of three. -/
theorem phi6_mem_of_mem_cell (C P n : ℕ) (hC : 3 ∣ C) (h3 : ¬ 3 ∣ (P + 1))
    (T' : Finset PlusFormula)
    (hT : T' ∈ cellAt M6 phi6 ((0 : ℤ), st5 0 (C + (P + 1)) n) 0) : phi6 ∈ T' := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path5 σ
  have hst : ((0 : ℤ) + k, g 0) = ((0 : ℤ), st5 0 (C + (P + 1)) n) := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, 0), C + (P + 1), n) :=
    congrArg (fun w : ℤ × LadderState Q5 pend5 => w.2.1) hst
  have hg' : ∀ t, Rlad step5 pend5 t (g t).1 (g (t + 1)).1 := fun t => hg t
  rw [mem_tpOf_iff]
  refine ⟨self_mem_plusSubformulaClosure _, ?_⟩
  change PlusTruthAt M6 σ 0 endA → ¬ PlusTruthAt M6 σ 0 chi
  intro hendA hchi
  have hidx : (g ((C + (P + 1) : ℕ) : ℤ)).1.1.2 = 0 := by
    have h1 := (endA_at_zero_iffL lab6 lab6_p lab6_r lab6_a hpath hg' 0 (C + (P + 1)) n hg0).mp
      hendA
    rw [idle_copy5 hg' 0 (C + (P + 1)) n hg0] at h1
    exact h1
  have hfree := chi_forces_dfree hpath hg' (C + (P + 1)) n hg0 hchi hidx
  have hdvd := dfree_walk_mod3 hg' (C + (P + 1)) n hg0 hfree hidx
  omega

/-- **The cells differ whenever `3 ∤ P + 1`.** -/
theorem cell6_ne (T P B : ℕ) (h3 : ¬ 3 ∣ (P + 1)) :
    cellAt M6 phi6 ((0 : ℤ), x5 T P B) 0 ≠ cellAt M6 phi6 ((0 : ℤ), y5 T P B) 0 := by
  intro heq
  unfold x5 y5 at heq
  obtain ⟨T', hT', hnot⟩ :=
    exists_cell_not_phi6 (c5 T P) (c5 T P + (P + 1) + B) (c5_dvd T P)
  rw [heq] at hT'
  exact hnot (phi6_mem_of_mem_cell (c5 T P) P (c5 T P + (P + 1) + B) (c5_dvd T P) h3 T' hT')

/-- **GATE 6 REFUTES THE JOINTLY-DERIVED CANDIDATE.**  For every threshold, every clip bound and
every modulus coprime to three -- in particular for the thresholds and clip bounds the formula
derives, and for the modulus `2`, which is the least one the rule admits on this object, since the
full graph's exhibited period is `1` (`reach5_eventually_constant`) and `d` is label-identical to
`b` (`lab6_d_eq_b`), so no letter-definable sub-object exhibits the period three that the
separating formula sees -- the index does not factor this fixture's cells. -/
theorem joint_parameters_refuted (T P B : ℕ) (h3 : ¬ 3 ∣ (P + 1)) :
    ¬ ∀ x y : LadderState Q5 pend5, ladderIndexJnt T P B x = ladderIndexJnt T P B y →
        cellAt M6 phi6 ((0 : ℤ), x) 0 = cellAt M6 phi6 ((0 : ℤ), y) 0 := by
  intro h
  exact cell6_ne T P B h3 (h _ _ (period_collision T P B))

/-- **The same refutation at the rule's OWN parameters**, with the least rule-admissible modulus
`P + 1 = 2`: the threshold and the clip bound are read off `phi6` itself, the modulus is a
multiple of every letter-definable sub-object's exhibited period, `RuleParams` holds, and the
index still fails. -/
theorem rule_derived_parameters_refuted :
    RuleParams phi6 (thrJ phi6) 1 (clipJ phi6) ∧
      ¬ ∀ x y : LadderState Q5 pend5,
          ladderIndexJnt (thrJ phi6) 1 (clipJ phi6) x
              = ladderIndexJnt (thrJ phi6) 1 (clipJ phi6) y →
            cellAt M6 phi6 ((0 : ℤ), x) 0 = cellAt M6 phi6 ((0 : ℤ), y) 0 :=
  ⟨ruleParams_derived phi6 1 le_rfl,
    joint_parameters_refuted (thrJ phi6) 1 (clipJ phi6) (by decide)⟩

end Probe805

/-! ## Axiom check -/

#print axioms Probe805.gate1_gap_separates
#print axioms Probe805.gate2_residue_separates
#print axioms Probe805.gates_one_two_at_rule_params
#print axioms Probe805.second_region_sets_agree
#print axioms Probe805.third_region_any_length
#print axioms Probe805.region_start_beyond_depth
#print axioms Probe805.clipped_gap_collides
#print axioms Probe805.untlDepth_phiDepth
#print axioms Probe805.gate4_witness_not_in_closure
#print axioms Probe805.gate4_disarmed
#print axioms Probe805.gate4_diagonal_escapes
#print axioms Probe805.reach5_eventually_constant
#print axioms Probe805.lab5_d_only
#print axioms Probe805.dfree_walk_mod3
#print axioms Probe805.reach_period_refuted
#print axioms Probe805.gate5_disarmed
#print axioms Probe805.lab6_d_eq_b
#print axioms Probe805.lab6_keep_d_iff_b
#print axioms Probe805.cycle_not_letter_definable
#print axioms Probe805.letter_definable_keeps_two_cycle
#print axioms Probe805.chi_ref
#print axioms Probe805.chi_forces_dfree
#print axioms Probe805.exists_cell_not_phi6
#print axioms Probe805.phi6_mem_of_mem_cell
#print axioms Probe805.cell6_ne
#print axioms Probe805.joint_parameters_refuted
#print axioms Probe805.rule_derived_parameters_refuted
