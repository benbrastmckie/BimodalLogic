/-
NO FORWARD `Rlad` RAY IS PENDING FOREVER: from a state with countdown `c₀` an idle state is
reached within `c₀ + 1` steps, because `Count true true` forces `c' + 1 = c` along every pending
step, so the countdown of a pending run is strictly decreasing in `ℕ` and the run ends.  Hence
every `Realizes`-chain of the certificate rounds -- whose relations `coh`/`cohBi` require `pend`
at BOTH endpoints, so that every bi-infinite chain is an all-pending object walk -- is
REGION-INTERIOR and is the object projection of no `Rlad` history.  The certified realizability
of record is realizability for the interior of one region, not ladder realizability; composing
regions across idle runs under `Count`/`Drift` is the step the ladder datum still owes.

## What was asked

The presentation decision for a ladder cell -- a set-valued per-state datum over a quotient
against a parameter-coupled index -- needed to know whether the certified realizability of record
(the label-level sufficiency `realizes_of_certAdm_cohBi` over `cohBi`) is already ladder
realizability: whether a certified `Realizes`-chain is the object projection of an `Rlad` history
through its states.  If it were, the semantic step (obligation (d)) could be taken from it
directly; if not, the remaining work sits in the composition of regions.

## What is settled

- `count_pending_step`: along an `Rlad` step between two pending states the countdown drops by
  exactly one, `y.2.1 + 1 = x.2.1`.  Axioms `[propext]`.
- `exists_idle_of_rlad_ray`: for every forward `Rlad` ray `f` some `i ≤ (f 0).2.1 + 1` has
  `pend (f i).1 = false`.  Axioms `[propext, Quot.sound]`.
- `no_rlad_ray_of_pending_forever`: an object walk pending at every forward position is a forward
  `Rlad` ray for no `step`, `pend` and `t`: `¬ ∀ i, Rlad step pend t (f i) (f (i + 1))`.  Axioms
  `[propext, Quot.sound]`.

## What this does NOT say

Nothing here is a factorization lemma, a cell index, a `LadderCons`, a `ladderRealized`, or any
part of one.  No declaration mentions `cellAt`, `HitPresented` or `PlusValidZTime`.  Nothing is
said about the backward direction: `gPast_isPath` stands, and backward-infinite pending histories
exist.  `c₀ + 1` is a count of steps and nothing else.  The composition of regions across idle
runs under `Count`/`Drift` -- the two `pend` conjuncts of `coh` replaced by `Count`/`Drift`
clauses on the counter classes, the counter-lift lemma -- is the successor's obligation and is
not discharged here.  No gate verdict changes; no finiteness is added.

Compile: `lake env lean specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean`
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

#print axioms Probe819.count_pending_step
#print axioms Probe819.exists_idle_of_rlad_ray
#print axioms Probe819.no_rlad_ray_of_pending_forever
