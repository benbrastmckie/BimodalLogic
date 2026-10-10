/-
Research scratch for requirement (W)'s run layer, phase 1 (the design question): **the
deadline-ladder unfolding has two-sided finite branching, generically over any finite object.**

`b2b-frame-constructor-branching.lean` (Probe746) refutes both countdown-with-reset shapes:
`Rbad` (reset to `0` from any level) has an infinite backward preimage, and `Rok` (choose a fresh
deadline at level `0`) has infinite forward branching — "the unbounded nondeterministic choice is
infinite-branching on whichever side it fires". The `Node` shape of `Limits/NoFiniteWidth.lean`
avoids both because its single deadline is never chosen at a state: thread `k` carries it from
`-∞`. That shape serves a formula whose every history has ONE pending region; a general run
layer needs a deadline per pending region, with pending regions recurring along a history.

This file tests the obvious generalization: carry TWO counters, the current deadline `c`
(deterministic countdown while pending; `0` while idle) and the next deadline `n`, which
drifts by at most one per step (`n' ∈ {n - 1, n, n + 1}`) at EVERY step, so that by the time a
new pending region starts the value handed over has been assembled gradually rather than chosen
at once. Nothing here says the ladder realizes the right types — that is phases 2-3 of the
record and is not costed here. What is established is only the branching verdict: the ladder
relation `Rlad` over `Q × ℕ × ℕ` has `FwdFinBranch` and `BwdFinBranch` for EVERY finite `Q`,
every `step` and every `pend`, so Probe746's `fib_finite_of_finBranch` applies to it and the
regularity half of obligation (i) goes through unchanged. Seriality is NOT established and is
an obligation on the object (a pending state at `c = 0` needs a discharging successor).

Compile: `lake env lean specs/750_w_run_layer_closure_wide_lift/evidence/01_deadline-ladder-branching.lean`
-/
import FormalSystem.Semantics.SlicedFrame

namespace Scratch750

open FormalSystem.Semantics

/-- Forward finite branching (Probe746's definition, transcribed). -/
def FwdFinBranch {W : Type} (R : ℤ → W → W → Prop) : Prop :=
  ∀ t w, {u | R t w u}.Finite

/-- Backward finite branching (Probe746's definition, transcribed). -/
def BwdFinBranch {W : Type} (R : ℤ → W → W → Prop) : Prop :=
  ∀ t u, {w | R t w u}.Finite

/-- The next-deadline counter drifts by at most one per step. -/
def Drift (n n' : ℕ) : Prop := n' = n ∨ n' = n + 1 ∨ n' + 1 = n

/-- The current-deadline counter: deterministic countdown while a region continues, handed the
next-deadline value when a region starts, and `0` while idle. A region ends exactly when the
countdown reaches `0` (no early discharge with leftover — that is what keeps the backward side
finite). -/
def Count (px py : Bool) (c n c' : ℕ) : Prop :=
  if py then (if px then c' + 1 = c else c' = n) else (c' = 0 ∧ (px = true → c = 0))

/-- **The deadline ladder** over a finite object `(step, pend)`: states `(q, c, n)`. -/
def Rlad {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) :
    ℤ → (Q × ℕ × ℕ) → (Q × ℕ × ℕ) → Prop :=
  fun _ x y => step x.1 y.1 = true ∧ (pend x.1 = false → x.2.1 = 0) ∧
    Drift x.2.2 y.2.2 ∧ Count (pend x.1) (pend y.1) x.2.1 x.2.2 y.2.1

/-- The three values a counter can take after one step, as a finite set. -/
def tri (a b c : ℕ) : Set ℕ := {a, b, c}

theorem tri_finite (a b c : ℕ) : (tri a b c).Finite :=
  ((Set.finite_singleton c).insert b).insert a

/-- **Forward branching is finite**: from `(q, c, n)` the successor is in
`Q × {c - 1, n, 0} × {n - 1, n, n + 1}`. -/
theorem Rlad_fwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    FwdFinBranch (Rlad step pend) := by
  intro t x
  refine Set.Finite.subset
    ((Set.finite_univ (α := Q)).prod ((tri_finite (x.2.1 - 1) x.2.2 0).prod
      (tri_finite (x.2.2 - 1) x.2.2 (x.2.2 + 1)))) ?_
  rintro ⟨q', c', n'⟩ ⟨-, -, hd, hc⟩
  refine ⟨Set.mem_univ _, ?_, ?_⟩
  · simp only [Count] at hc
    simp only [tri, Set.mem_insert_iff, Set.mem_singleton_iff]
    split_ifs at hc with h1 h2
    · left; omega
    · right; left; exact hc
    · right; right; exact hc.1
  · simp only [Drift] at hd
    simp only [tri, Set.mem_insert_iff, Set.mem_singleton_iff]
    omega

/-- **Backward branching is finite**: into `(q', c', n')` the predecessor is in
`Q × {c' + 1, 0, 0} × {n' - 1, n', n' + 1}`. This is the side `Rbad` fails and the side the
"no early discharge" clause of `Count` is for. -/
theorem Rlad_bwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    BwdFinBranch (Rlad step pend) := by
  intro t y
  refine Set.Finite.subset
    ((Set.finite_univ (α := Q)).prod ((tri_finite (y.2.1 + 1) 0 0).prod
      (tri_finite (y.2.2 - 1) y.2.2 (y.2.2 + 1)))) ?_
  rintro ⟨q, c, n⟩ ⟨-, hidle, hd, hc⟩
  refine ⟨Set.mem_univ _, ?_, ?_⟩
  · simp only [Count] at hc
    simp only [tri, Set.mem_insert_iff, Set.mem_singleton_iff]
    split_ifs at hc with h1 h2
    · left; omega
    · right; left
      simp only [Bool.not_eq_true] at h2
      exact hidle h2
    · right; left
      by_cases hp : pend q = true
      · exact hc.2 hp
      · exact hidle (by simpa using hp)
  · simp only [Drift] at hd
    simp only [tri, Set.mem_insert_iff, Set.mem_singleton_iff]
    omega

/-- The ladder's carrier slice is infinite whenever `Q` is inhabited: the deadlines are unbounded. -/
theorem Rlad_slice_infinite {Q : Type} [Nonempty Q] : ¬ Finite (Q × ℕ × ℕ) := by
  intro h
  have : Finite ℕ := Finite.of_injective (fun n : ℕ => ((Classical.arbitrary Q), n, 0))
    (fun a b hab => by simpa using hab)
  exact not_finite ℕ

end Scratch750

#print axioms Scratch750.Rlad_fwd
#print axioms Scratch750.Rlad_bwd
#print axioms Scratch750.Rlad_slice_infinite
