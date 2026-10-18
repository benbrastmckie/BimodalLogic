/-
NO FORWARD `Rlad` RAY IS PENDING FOREVER: from a state with countdown `c₀`, an idle state is
reached within `c₀ + 1` steps.  `Count true true` forces `c' + 1 = c`, so the countdown of a
pending run is strictly decreasing in `ℕ` and the run ends.  Consequence for the set-valued
presentation on record: the coherence relations `coh`/`cohBi` of the eighteenth to twenty-first
probes require `pend` at BOTH endpoints, so every bi-infinite `cohBi`-chain (`Realizes`) is an
all-pending object walk, and by this theorem no such walk is the object projection of any
`Rlad` history.  The certified realizability of record is therefore region-interior
realizability, not ladder realizability; composing regions across idle runs under `Count`/`Drift`
is the step the ladder datum still owes.

Research-level prototype for the presentation design decision; nothing here is a factorization
lemma, a cell index, a `LadderCons`, a `ladderRealized`, or any part of one.  No declaration
mentions `cellAt`, `HitPresented` or `PlusValidZTime`.  Every quantity named is a count.

Compile: `lake env lean specs/819_ladder_cell_presentation_design_decision/prototype/no-pending-forever-ray.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer

open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe819

/-- Along an `Rlad` step between two pending states the countdown drops by exactly one
(`Count true true`). -/
theorem count_pending_step {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (t : ℤ)
    (x y : Q × ℕ × ℕ) (h : Rlad step pend t x y) (hx : pend x.1 = true) (hy : pend y.1 = true) :
    y.2.1 + 1 = x.2.1 := by
  have hc := h.2.2.2
  simpa [Count, hx, hy] using hc

/-- **No forward `Rlad` ray is pending forever**: an idle state is reached within `c₀ + 1`
steps of a state with countdown `c₀`.  The bound `c₀ + 1` is a count of steps and nothing
else. -/
theorem exists_idle_of_rlad_ray {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (t : ℤ)
    (f : ℕ → Q × ℕ × ℕ) (hf : ∀ i, Rlad step pend t (f i) (f (i + 1))) :
    ∃ i, i ≤ (f 0).2.1 + 1 ∧ pend (f i).1 = false := by
  by_contra hcon
  have hpend : ∀ i, i ≤ (f 0).2.1 + 1 → pend (f i).1 = true := by
    intro i hi
    by_contra h
    exact hcon ⟨i, hi, by simpa using h⟩
  have key : ∀ i, i ≤ (f 0).2.1 → (f i).2.1 + i = (f 0).2.1 := by
    intro i hi
    induction i with
    | zero => simp
    | succ n ih =>
      have h1 := count_pending_step step pend t (f n) (f (n + 1)) (hf n)
        (hpend n (by omega)) (hpend (n + 1) (by omega))
      have h2 := ih (by omega)
      omega
  have h0 : (f (f 0).2.1).2.1 = 0 := by
    have := key (f 0).2.1 le_rfl
    omega
  have h1 := count_pending_step step pend t (f (f 0).2.1) (f ((f 0).2.1 + 1)) (hf (f 0).2.1)
    (hpend (f 0).2.1 (by omega)) (hpend ((f 0).2.1 + 1) le_rfl)
  omega

/-- The contrapositive in the form the design decision uses: an object walk that is pending at
every forward position is the object projection of NO forward `Rlad` ray. -/
theorem no_rlad_ray_of_pending_forever {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (t : ℤ) (f : ℕ → Q × ℕ × ℕ) (hp : ∀ i, pend (f i).1 = true) :
    ¬ ∀ i, Rlad step pend t (f i) (f (i + 1)) := by
  intro hf
  obtain ⟨i, _, hi⟩ := exists_idle_of_rlad_ray step pend t f hf
  rw [hp i] at hi
  exact Bool.noConfusion hi

end Probe819
