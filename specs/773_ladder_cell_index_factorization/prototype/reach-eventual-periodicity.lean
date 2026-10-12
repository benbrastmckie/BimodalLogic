/-
PROTOTYPE TEST (not a wired probe): the generic theorem that makes the re-scoped index's two
RESIDUE coordinates well-founded rather than ad hoc.

## What this exhibits

The refutation of the three-coordinate candidate (sibling prototype
`parity-index-refutation.lean`) says that what `cellAt` can read at the region end -- a distance
exactly `c + 1` away, because `Count true true` admits no early discharge -- must survive
whatever the countdown coordinate does to `c`.  That datum is a `step`-REACHABILITY datum: which
object states are reachable in `c + 1` steps.  Reachability sets live in `Finset Q`, which is
finite whenever the object is, and iteration of any endofunction of a finite type is EVENTUALLY
PERIODIC.  So the datum is determined by `min c T` together with `c % (P + 1)` for a threshold
`T` and a period `P` that the OBJECT supplies.

`iterate_eventually_periodic` is that fact in general; `reachN_eventually_periodic` is it for the
reachability map.  Together they EXHIBIT the `T` and `P` at which the re-scoped index
(`residue-index-gate.lean`'s `ladderIndexRes`) takes its two residue coordinates, instead of
assuming them.

## What this does NOT say

**This is not the factorization lemma and claims no sufficiency.**  It says the region-end datum
is eventually periodic in the number of steps; it says NOTHING about whether the six coordinates
of `ladderIndexRes` determine `cellAt`, and no declaration here states, or partially states, a
factorization lemma for this or any index.  The positive factorization lemma remains OPEN and
unclaimed.

Two further limits, stated rather than left implicit:

  - The threshold and period here are those of the reachability map on `Finset Q` from ONE
    starting set.  Nothing claims they are optimal, and no bound of any kind is asserted -- every
    quantity named is a count.
  - The gap coordinate's clip bound `B` is FORMULA-derived (the X-nesting depth of `phi`, or
    `|cl phi|`) and is untouched by this file.  `T` and `P` come from the object; `B` does not,
    and the parameter origins are never crossed.

## Provenance of the proof

`lean_local_search` for a local eventual-periodicity declaration returned nothing, but reported
its symbol index as `warming` rather than `consulted`, so that is NOT proof of absence;
`lean_leansearch` was unreachable (HTTP 500) at the time of writing.  `lean_loogle` on the
pattern `?f^[?n + ?p] ?a = ?f^[?n] ?a` surfaced only
`Function.iterate_add_minimalPeriod_eq`, which needs `x ∈ Function.periodicPts f` and so does not
cover an arbitrary starting point.  The proof below is therefore the plan's named route --
pigeonhole (`Finite.exists_ne_map_eq_of_infinite`) on `n => f^[n] a`, then
`Function.iterate_add_apply` -- and is 14 lines; the deliverable is the exhibited pair, not a
novel proof.

Compile: `lake env lean specs/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace ReachEventualPeriodicity

/-! ## The generic fact: iteration on a finite type is eventually periodic -/

/-- **Iteration of an endofunction of a finite type is eventually periodic**, with a threshold
`T` and a GENUINELY POSITIVE period `P`.  Pigeonhole on `n => f^[n] a` (infinite domain, finite
codomain) gives `i ≠ j` with equal iterates; `T` is the smaller and `P` their difference, and the
conclusion propagates by `Function.iterate_add_apply`.

The period is `1 ≤ P`, not `0 ≤ P`: at `P = 0` the conclusion would be a tautology. -/
theorem iterate_eventually_periodic {A : Type} [Finite A] (f : A → A) (a : A) :
    ∃ T P : ℕ, 1 ≤ P ∧ ∀ k, T ≤ k → f^[k + P] a = f^[k] a := by
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n] a)
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨i, j - i, by omega, ?_⟩
    intro k hk
    obtain ⟨m, rfl⟩ : ∃ m, k = i + m := ⟨k - i, by omega⟩
    have hkey : i + m + (j - i) = m + j := by omega
    rw [hkey, Function.iterate_add_apply, ← hfe, ← Function.iterate_add_apply]
    congr 1
    omega
  · refine ⟨j, i - j, by omega, ?_⟩
    intro k hk
    obtain ⟨m, rfl⟩ : ∃ m, k = j + m := ⟨k - j, by omega⟩
    have hkey : j + m + (i - j) = m + i := by omega
    rw [hkey, Function.iterate_add_apply, hfe, ← Function.iterate_add_apply]
    congr 1
    omega

/-! ## The reachability map, and the exhibited threshold and period -/

/-- One step of reachability under the object's step relation: the states reachable in one
`step` from somewhere in `S`. -/
def reachStep {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool)
    (S : Finset Q) : Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))

/-- **The step-reachability set of a finite object is eventually periodic in the number of
steps.**  `Finset Q` is a `Fintype` whenever `Q` is one with decidable equality, so the generic
lemma applies at `A := Finset Q`.

This is what EXHIBITS the `T` and `P` the re-scoped index's residue coordinates are taken at: the
region-end observable is reachability in `c + 1` steps, and the pair above says `min c T` plus
`c % (P + 1)` determines it.  It does NOT say the six coordinates suffice. -/
theorem reachN_eventually_periodic {Q : Type} [Fintype Q] [DecidableEq Q]
    (step : Q → Q → Bool) (S : Finset Q) :
    ∃ T P : ℕ, 1 ≤ P ∧
      ∀ k, T ≤ k → (reachStep step)^[k + P] S = (reachStep step)^[k] S :=
  iterate_eventually_periodic (reachStep step) S

end ReachEventualPeriodicity

/-! ## Axiom check -/

#print axioms ReachEventualPeriodicity.iterate_eventually_periodic
#print axioms ReachEventualPeriodicity.reachN_eventually_periodic
