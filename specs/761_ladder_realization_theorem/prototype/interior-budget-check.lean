/-
THE INTERIOR-PAIRWISE BUDGET, RE-DERIVED AT THE LARGER FIGURE.

The type-respecting-block route pigeonholes on `(objAt v, tpOf v)` PAIRS, and its STEP 0 — that
the available countdown dominates the pigeonhole budget `card (ProdState Q φ) + 1` without
strengthening `ParamsOk` — is settled in `step0-budget-check.lean`.

What STEP 0 does NOT settle is the risk the blocker research records against its Step 2: endpoint
type equality is not known to propagate to the block's INTERIOR positions. If it does not, the
fallback is a pigeonhole for a loop whose interior types also match pairwise, and that pigeonhole
runs at a LARGER figure. The record names the candidate figure — the exponential gap between
`card (ProdState Q φ)` and `2 ^ card (ProdState Q φ)` — and says, correctly, that no claim was
made about how wide is wide enough. This file settles that arithmetic question, and ONLY that one.

## What is settled here

The larger budget `2 ^ card (ProdState Q φ) + 1` is dominated by `(K2)`'s `cascadeBound` conjunct
too, by the SAME route STEP 0 uses and with no new parameter:

  `cascadeBound pend φ = 2 ^ card (ProdState Q φ) * (tIdle pend + 2)`

carries `2 ^ card (ProdState Q φ)` as its own leading FACTOR, not merely as an exponent. So the
re-derivation costs exactly the `(tIdle pend + 2)` factor and nothing else: `tIdle pend + 2 ≥ 2`
already pays for it (`pairwise_budget_le_cascadeBound`), and the full factor remains as slack
(`cascadeBound_slack`). The chain to `Tc` and then to the compared countdowns is then
STEP 0's own, unchanged: `(K2)` via `hp.2.1.1`, then `eq_or_both_ge_of_min_eq` in the saturated
regime.

`budget_hierarchy` records that the larger figure does dominate STEP 0's, so nothing proved at
the smaller figure is lost by moving to it.

## What this does NOT show

It does NOT show that the interior-pairwise pigeonhole SUFFICES for the propagation, and it does
not show that `2 ^ card (ProdState Q φ)` is the right figure for that pigeonhole. Both are
combinatorial claims about the type sequence along a ladder path, not arithmetic ones, and
neither is touched here. What is removed is the budget objection ALONE: whatever the propagation
argument turns out to need, up to and including a pigeonhole over the whole powerset of the
product carrier, `(K2)` already pays for it at the parameters the periodicity fixpoint defines.

It adds no parameter, strengthens no parameter source, leaves `ParamsOk` untouched, raises no
`Tc`, and cites `cascadeBound` alone — `satThreshold`, `satPeriod`, `prodPre_periodic`,
`prodPreStep` and `cohIdle` do not appear.

## Verification

`#print axioms` on every theorem below. No `sorry`, no axiom, no `native_decide`, no placeholder
body, no vacuous definition.

Compile: `lake env lean` on this file. NOT a wired probe and NOT gate-covered; a prototype, to be
landed in the library by the revision that adopts the route.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace InteriorBudget

/-- **The larger figure dominates STEP 0's**, so moving to it loses nothing proved at the
smaller one. -/
theorem budget_hierarchy (Q : Type) [Fintype Q] (φ : PlusFormula) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1
      ≤ 2 ^ Fintype.card (ProdState Q φ) + 1 := by
  classical
  have hcard : Fintype.card (ProdState Q φ)
      = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by
    show Fintype.card (Q × ClType φ) = _
    rw [Fintype.card_prod]
    congr 1
    rw [show Fintype.card (ClType φ) = ((plusSubformulaClosure φ).powerset).card from
      Fintype.card_coe _, Finset.card_powerset]
  have h : Fintype.card (ProdState Q φ) < 2 ^ Fintype.card (ProdState Q φ) :=
    Nat.lt_two_pow_self
  omega

/-- **THE RE-DERIVATION.** `(K2)`'s cascade bound dominates the interior-pairwise budget as
well, because `2 ^ card (ProdState Q φ)` is `cascadeBound`'s own leading FACTOR. -/
theorem pairwise_budget_le_cascadeBound {Q : Type} [Fintype Q] (pend : Q → Bool)
    (φ : PlusFormula) :
    2 ^ Fintype.card (ProdState Q φ) + 1 ≤ cascadeBound pend φ := by
  rw [cascadeBound]
  have hpos : 1 ≤ 2 ^ Fintype.card (ProdState Q φ) := Nat.one_le_two_pow
  calc 2 ^ Fintype.card (ProdState Q φ) + 1
      ≤ 2 ^ Fintype.card (ProdState Q φ) * 2 := by omega
    _ ≤ 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2) :=
        Nat.mul_le_mul_left _ (by omega)

/-- **What the re-derivation costs**: the `(tIdle pend + 2)` factor is the only slack consumed,
and it remains available in full. -/
theorem cascadeBound_slack {Q : Type} [Fintype Q] (pend : Q → Bool) (φ : PlusFormula) :
    2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2) = cascadeBound pend φ := rfl

/-- **The larger budget is available at every `Tc` the parameter conditions admit**, through
`(K2)` and `cascadeBound` ALONE. No parameter added, `ParamsOk` not strengthened. -/
theorem pairwise_budget_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    2 ^ Fintype.card (ProdState Q φ) + 1 ≤ Tc :=
  le_trans (pairwise_budget_le_cascadeBound pend φ) hp.2.1.1

/-- **And therefore at the compared countdowns in the saturated regime**, by STEP 0's own
regime split: either the countdowns are equal (nothing to pump) or both clear the larger
budget. -/
theorem pairwise_budget_le_cnt {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (c c' : ℕ)
    (hmin : min c Tc = min c' Tc) :
    c = c' ∨ (2 ^ Fintype.card (ProdState Q φ) + 1 ≤ c ∧
      2 ^ Fintype.card (ProdState Q φ) + 1 ≤ c') := by
  rcases eq_or_both_ge_of_min_eq Tc c c' hmin with h | ⟨h1, h2⟩
  · exact Or.inl h
  · exact Or.inr ⟨le_trans (pairwise_budget_le_Tc step pend lab φ Tc Tn P B hp) h1,
      le_trans (pairwise_budget_le_Tc step pend lab φ Tc Tn P B hp) h2⟩

end InteriorBudget

#print axioms InteriorBudget.budget_hierarchy
#print axioms InteriorBudget.pairwise_budget_le_cascadeBound
#print axioms InteriorBudget.cascadeBound_slack
#print axioms InteriorBudget.pairwise_budget_le_Tc
#print axioms InteriorBudget.pairwise_budget_le_cnt
