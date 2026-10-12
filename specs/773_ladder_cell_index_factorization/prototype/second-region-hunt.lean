/-
PROTOTYPE TEST (not a wired probe): the THIRD gate on the re-scoped six-coordinate cell-index
candidate -- an attack where the sufficiency argument for it is weakest.

## The target

`residue-index-gate.lean`'s `ladderIndexRes T P B`, the six-coordinate candidate
  `(q, min c T, c % (P+1), min n T, n % (P+1), clip (n - c) [-B, B])`,
which survived the two CHEAP gates (the gap pair that killed the two-coordinate index, the parity
pair that kills the three-coordinate one).

## The argument under attack

From `(q, c, n)` the first idle state sits at distance exactly `c + 1`, where the next-deadline
has drifted to somewhere in `[max(0, gap - 1), n + c + 1]` -- an interval of width `2c + 3`.
The argument the re-scope rests on is that the position of that window is `(n - c - 1) mod (P+1)`,
which the two residue coordinates already determine, and that its width exceeds the modulus
exactly when `min c T` saturates; so one region further out nothing new is observable.

## The three attempts, with their predictions written before they were run

**(iii-a) The second region's end.**
  PREDICTION (from the plan, at plan time): NO refutation once `T >= P`, because the window's
  position is `(n - c - 1) mod (P+1)`, which the two residue coordinates already determine, and
  its width `2c + 3` exceeds the modulus exactly when `min c T` saturates.
  RESULT: **No refutation -- and the predicted REASON is wrong, in the candidate's favour.** The
  window is not determined by the residue coordinates at all; it is not a window. `Count false
  false` holds the countdown at `0` through an idle interval of ANY length while `Drift` moves the
  next deadline by one per step in either direction, so from the first idle state EVERY value of
  the next deadline is reachable before the next region starts, and `Count false true` hands that
  value to the new region as its length. `second_region_any_length` proves exactly this: from
  EVERY pending state, a second region of EVERY length is reachable. Hence
  `second_region_end_tag_achievable` -- both parities of the second region's end tag are
  achievable from every pending state -- and `second_region_sets_agree`: any two pending states
  with the same object component have the SAME achievable second-region-end tag set, both sets
  being everything, for ANY values of either counter. The second region's end therefore separates
  nothing, and it separates nothing for a reason independent of `T`, `P` and `B`: idle drift
  freedom, not residue determinacy.

**(iii-b) The past direction.**
  PREDICTION (from the plan, at plan time): no separation for a formula whose past-depth is below
  the clip, and a refutation if one is found at or above it -- in which case the clip bound's
  `phi`-derivation must cover past depth too.
  RESULT: **No refutation, and the recorded finding is the clip-bound refinement.** The report's
  finding F7 was an ARGUMENT; it is now an arithmetic bound. Along a forward pending chain the gap
  rises by at most two per step (`gap_step_le`), and at a region start it is at most one
  (`gap_region_start_le_one`), so a state reached `k` steps after its region start has gap at most
  `2k - 1` (`gap_le_region_age`). Contrapositively `region_start_beyond_depth`: a state whose gap
  exceeds `2k - 1` has NO region start within `k` backward steps. On the attempt's own pair --
  countdown `1`, next deadlines `2B+1` and `2B+2`, so true gaps `2B` and `2B+1`, both above the
  clip and both saturating it (`clipped_gap_collides`) -- every region start is at least `B + 1`
  steps back, beyond the reach of any formula of past-depth at most `B`. So the clipped gap does
  serve the past, CONDITIONALLY: the clip bound's `phi`-derivation must cover `snce`-nesting depth
  as well as `X`-nesting depth. That is a refinement of the parameter-origin rule, not a
  refutation of the candidate.

**(iii-c) One region further.**
  PREDICTION (from the plan, at plan time): subsumed by (iii-a)'s determinacy argument; run only
  if (iii-a) closes without a refutation, and stop after it either way.
  RESULT: **Subsumed, and more cleanly than predicted.** (iii-a) closed without a refutation, so
  this attempt was run. Because (iii-a)'s reachability theorem is stated from an ARBITRARY pending
  state, iterating it is one application of transitivity: `third_region_any_length` reaches a
  third region of every length through a second region of every length. The achievable-interval
  widths do not compound because there is no interval to compound -- the same drift freedom
  applies at every region boundary. Stopped here, per the binding stop condition.

## The branch this file records: BRANCH P

**No refutation was found on these three attempts.** The honest caveat, which this file states
rather than leaves to a reader: three attempts on one fixture family show that the known
mechanisms and the nearest unknown one do not lift to the six-coordinate shape. They do NOT show
that the general factorization holds. The positive factorization lemma -- for this candidate or
any other index -- is OPEN, is stated nowhere in this file, and is nowhere weakened,
hypothesised, axiomatised or discharged by a placeholder body. No fourth attempt was opened, no
coordinate was added, and no sufficiency proof was begun.

Two limits on what the (iii-a) theorems are: they are REACHABILITY statements about the
admissible ladder carrier, not truth statements about `cellAt`. They say the achievable
second-region-end tag sets coincide; they do not say that every formula's truth value at the two
states coincides, which would be the factorization lemma. And the (iii-b) bound locates a region
START, which is not the same as showing no `snce`-formula separates the pair -- only that the
region start itself is out of a bounded formula's reach.

Compile: `lake env lean specs/773_ladder_cell_index_factorization/prototype/second-region-hunt.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace SecondRegionHunt

/-! ## The `Count` branches, as rewriting lemmas -/

theorem count_tt (c n c' : ℕ) : Count true true c n c' ↔ c' + 1 = c := by simp [Count]
theorem count_tf (c n c' : ℕ) : Count true false c n c' ↔ c' = 0 ∧ c = 0 := by simp [Count]
theorem count_ft (c n c' : ℕ) : Count false true c n c' ↔ c' = n := by simp [Count]
theorem count_ff (c n c' : ℕ) : Count false false c n c' ↔ c' = 0 := by simp [Count]

/-! ## The fixture: the parity object, extended minimally so a region can restart -/

/-- Object states `(pending?, tag)`, as in `parity-index-refutation.lean`. -/
abbrev Q2 : Type := Bool × Bool

def pend2 : Q2 → Bool := fun q => q.1

/-- The parity object extended MINIMALLY: the idle clause drops its `!y.1` conjunct, so an idle
state may step to a PENDING one carrying the tag.  Every other clause is unchanged, so every
region's end still carries the parity of that region's length -- including the second and the
third, which is what this file needs. -/
def step2 : Q2 → Q2 → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (y.2 == x.2)

theorem rlad2_iff (t : ℤ) (x y : Q2 × ℕ × ℕ) :
    Rlad step2 pend2 t x y ↔
      step2 x.1 y.1 = true ∧ (x.1.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧
        Count x.1.1 y.1.1 x.2.1 x.2.2 y.2.1 := Iff.rfl

/-- A pending admissible ladder state. -/
def pnd (tg : Bool) (c n : ℕ) : LadderState Q2 pend2 :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

/-- An idle admissible ladder state; `Adm` forces its countdown to `0`. -/
def idl (tg : Bool) (n : ℕ) : LadderState Q2 pend2 :=
  ⟨((false, tg), 0, n), fun _ => rfl⟩

/-- Reachability by admissible ladder steps.  `Rlad` ignores its time argument, so fixing it at
`0` loses nothing. -/
abbrev RladStar : LadderState Q2 pend2 → LadderState Q2 pend2 → Prop :=
  Relation.ReflTransGen (RladAdm step2 pend2 0)

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

/-! ## Attempt (iii-a): the second region's end -/

/-- One pending step: the countdown falls by exactly one and the tag flips. -/
theorem step_pend_down (tg : Bool) (c n : ℕ) :
    RladAdm step2 pend2 0 (pnd tg (c + 1) n) (pnd (!tg) c n) := by
  show Rlad step2 pend2 0 _ _
  rw [rlad2_iff]
  refine ⟨?_, by simp [pnd], Or.inl rfl, ?_⟩
  · show step2 (true, tg) (true, !tg) = true
    cases tg <;> simp [step2]
  · show Count true true (c + 1) n c
    rw [count_tt]

/-- **The countdown runs down with `n` held fixed**, so the region's last pending state carries
the tag `tagN tg c`: the parity of the region's length is in the tag. -/
theorem run_down (tg : Bool) (c n : ℕ) : RladStar (pnd tg c n) (pnd (tagN tg c) 0 n) := by
  induction c generalizing tg with
  | zero => rw [tagN_zero]
  | succ c ih =>
    rw [tagN_succ]
    exact Relation.ReflTransGen.head (step_pend_down tg c n) (ih (!tg))

/-- **The region ends on an idle state carrying the tag.**  `Count true true` cannot fire at
countdown `0`, so the successor is idle, and `step2` copies the tag. -/
theorem step_region_end (tg : Bool) (n : ℕ) :
    RladAdm step2 pend2 0 (pnd tg 0 n) (idl tg n) := by
  show Rlad step2 pend2 0 _ _
  rw [rlad2_iff]
  refine ⟨?_, by simp [pnd], Or.inl rfl, ?_⟩
  · show step2 (true, tg) (false, tg) = true
    cases tg <;> simp [step2]
  · show Count true false 0 n 0
    rw [count_tf]
    exact ⟨rfl, rfl⟩

/-- **The idle interval drifts the next deadline freely**: `Count false false` pins the countdown
at `0` and places no constraint on the next deadline beyond `Drift`. -/
theorem step_idle_drift (tg : Bool) (n n' : ℕ) (h : Drift n n') :
    RladAdm step2 pend2 0 (idl tg n) (idl tg n') := by
  show Rlad step2 pend2 0 _ _
  rw [rlad2_iff]
  refine ⟨?_, fun _ => rfl, h, ?_⟩
  · show step2 (false, tg) (false, tg) = true
    cases tg <;> simp [step2]
  · show Count false false 0 n 0
    rw [count_ff]

/-- **Hence EVERY next-deadline value is reachable within the idle interval.**  Drift down to
`0`, then up to the target: the idle interval may be of any length, so no bound survives it.
This is the fact that dissolves the "achievable window" the prediction expected. -/
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

/-- **A region starts, handed the next deadline as its length.**  `Count false true` sets the new
countdown to the idle state's next deadline. -/
theorem step_region_start (tg : Bool) (m : ℕ) :
    RladAdm step2 pend2 0 (idl tg m) (pnd tg m m) := by
  show Rlad step2 pend2 0 _ _
  rw [rlad2_iff]
  refine ⟨?_, fun _ => rfl, Or.inl rfl, ?_⟩
  · show step2 (false, tg) (true, tg) = true
    cases tg <;> simp [step2]
  · show Count false true 0 m m
    rw [count_ft]

/-- **(iii-a), the measurement**: from EVERY pending state, a second region of EVERY length is
reachable.  The target state's countdown is `m` for an arbitrary `m`, with no dependence on the
source state's counters whatsoever -- the achievable second-region lengths are not an interval of
width `2c + 3` positioned by the residues, they are all of `ℕ`. -/
theorem second_region_any_length (tg : Bool) (c n m : ℕ) :
    RladStar (pnd tg c n) (pnd (tagN tg c) m m) :=
  ((run_down tg c n).tail (step_region_end (tagN tg c) n)).trans
    ((idle_to_any (tagN tg c) n m).tail (step_region_start (tagN tg c) m))

/-- **(iii-a), the consequence**: both parities of the second region's end tag are achievable
from every pending state.  `m = 0` keeps the tag, `m = 1` flips it. -/
theorem second_region_end_tag_achievable (tg : Bool) (c n : ℕ) (b : Bool) :
    ∃ m : ℕ, RladStar (pnd tg c n) (pnd (tagN tg c) m m) ∧ tagN (tagN tg c) m = b := by
  by_cases h : tagN tg c = b
  · exact ⟨0, second_region_any_length tg c n 0, by rw [tagN_zero]; exact h⟩
  · refine ⟨1, second_region_any_length tg c n 1, ?_⟩
    rw [tagN_one]
    revert h
    cases tagN tg c <;> cases b <;> simp

/-- **(iii-a), the verdict: NO REFUTATION.**  Any two pending states with the same object
component have the SAME achievable second-region-end tag set -- both sets are everything -- for
ANY values of either counter.  The second region's end separates nothing, and it does so
independently of `T`, `P` and `B`. -/
theorem second_region_sets_agree (tg : Bool) (c1 n1 c2 n2 : ℕ) (b : Bool) :
    (∃ m : ℕ, RladStar (pnd tg c1 n1) (pnd (tagN tg c1) m m) ∧ tagN (tagN tg c1) m = b) ∧
      (∃ m : ℕ, RladStar (pnd tg c2 n2) (pnd (tagN tg c2) m m) ∧ tagN (tagN tg c2) m = b) :=
  ⟨second_region_end_tag_achievable tg c1 n1 b, second_region_end_tag_achievable tg c2 n2 b⟩

/-! ## Attempt (iii-b): the past direction -/

/-- The gap `n - c`, over `ℤ` so that it is not truncated. -/
def gapZ {Q : Type} (x : Q × ℕ × ℕ) : ℤ := (x.2.2 : ℤ) - (x.2.1 : ℤ)

/-- **Along a forward pending chain the gap rises by at most two per step**: `Count true true`
forces `c' + 1 = c` while `Drift` moves `n` by at most one.  (This is pre-landed finding (A),
restated as the per-step bound the backward reading needs.) -/
theorem gap_step_le {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x y : Q × ℕ × ℕ) (hx : pend x.1 = true) (hy : pend y.1 = true)
    (h : Rlad step pend 0 x y) : gapZ y ≤ gapZ x + 2 := by
  obtain ⟨-, -, hd, hc⟩ := h
  rw [hx, hy, count_tt] at hc
  simp only [Drift] at hd
  simp only [gapZ]
  omega

/-- **At a region start the gap is at most one**: `Count false true` hands the new countdown the
idle state's next deadline, and `Drift` moves that deadline by at most one. -/
theorem gap_region_start_le_one {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x y : Q × ℕ × ℕ) (hx : pend x.1 = false) (hy : pend y.1 = true)
    (h : Rlad step pend 0 x y) : gapZ y ≤ 1 := by
  obtain ⟨-, -, hd, hc⟩ := h
  rw [hx, hy, count_ft] at hc
  simp only [Drift] at hd
  simp only [gapZ]
  omega

/-- **A state reached `j` steps after its region start has gap at most `2j - 1`.**  The two
per-step bounds above, chained: the region start contributes at most `1` and each further pending
step at most `2`. -/
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

/-- **(iii-b), the verdict as a bound**: a state whose gap exceeds `2k - 1` has NO region start
within `k` backward steps.  So a formula whose past-depth is at most `k` cannot see the region
start of such a state, and two such states are not separated THERE. -/
theorem region_start_beyond_depth {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x : ℕ → Q × ℕ × ℕ) (k : ℕ) (hk : 1 ≤ k)
    (hstep : ∀ i, i < k → Rlad step pend 0 (x i) (x (i + 1)))
    (h0 : pend (x 0).1 = false)
    (hp : ∀ i, 1 ≤ i → i ≤ k → pend (x i).1 = true)
    (hgap : 2 * (k : ℤ) - 1 < gapZ (x k)) : False :=
  absurd (gap_le_region_age step pend x k hstep h0 hp k hk le_rfl) (by omega)

/-- The pair the attempt turns on: countdown `1`, next deadlines `2B+1` and `2B+2`, so true gaps
`2B` and `2B+1` -- both above the clip and both saturating it, so the clipped gap coordinate
CANNOT separate them.  Both region starts are at least `B + 1` steps back by the bound above, so
no formula of past-depth at most `B` reaches either: the clip bound's `phi`-derivation must cover
`snce`-nesting depth as well as `X`-nesting depth. -/
theorem clipped_gap_collides (B : ℕ) (hB : 1 ≤ B) :
    min ((2 * B + 1 + B) - 1) (2 * B) = min ((2 * B + 2 + B) - 1) (2 * B) := by omega

/-! ## Attempt (iii-c): one region further -/

/-- **(iii-c), the verdict: SUBSUMED.**  (iii-a)'s reachability theorem is stated from an
ARBITRARY pending state, so iterating it is one application of transitivity: a third region of
every length is reachable through a second region of every length.  The achievable widths do not
compound because there is no interval to compound -- the same idle drift freedom applies at every
region boundary.  Stopped here, per the binding stop condition. -/
theorem third_region_any_length (tg : Bool) (c n m2 m3 : ℕ) :
    RladStar (pnd tg c n) (pnd (tagN (tagN tg c) m2) m3 m3) :=
  (second_region_any_length tg c n m2).trans
    (second_region_any_length (tagN tg c) m2 m2 m3)

end SecondRegionHunt

/-! ## Axiom check -/

#print axioms SecondRegionHunt.second_region_any_length
#print axioms SecondRegionHunt.second_region_sets_agree
#print axioms SecondRegionHunt.gap_le_region_age
#print axioms SecondRegionHunt.region_start_beyond_depth
#print axioms SecondRegionHunt.third_region_any_length
