import Bimodal.Syntax.Formula

/-!
# Big Conjunction over Lists of Formulas

Defines `bigconj : List Formula → Formula` folding conjunction over a list,
with base case `⊤` (represented as `¬ ⊥`, i.e. `bot.neg`), plus the derived
negation `neg_bigconj`.

This file provides only the syntactic / `Formula`-level scaffolding needed by
the Fisher-Ladner `EnrichedClosure` (task 98 plan v3, Phase 1). The
derivation-tree level lemmas `bigconj_intro` and `bigconj_mem_iff` (conjunction
introduction and elimination) are consumed only by the chain-step seed
consistency argument in Phase 4 and are therefore colocated with that proof
rather than added here, keeping Phase 1 self-contained and `DerivationTree`-free.

## Main Definitions

- `bigconj : List Formula → Formula`
- `neg_bigconj : List Formula → Formula`

## References

- Teammate A findings (specs/098/reports/03_teammate-a-findings.md §3.2)
-/

namespace Bimodal.Syntax

/-- Big conjunction over a list of formulas: `bigconj [φ₁, …, φₙ] = φ₁ ∧ … ∧ φₙ`.
    Base case: the empty list folds to `⊤`, represented as `¬ ⊥ = bot.imp bot`. -/
def bigconj : List Formula → Formula
  | []      => Formula.bot.neg  -- `⊤` ≝ `¬ ⊥`
  | [φ]     => φ
  | φ :: ψ :: rest => Formula.and φ (bigconj (ψ :: rest))

/-- Negated big conjunction. -/
def neg_bigconj (L : List Formula) : Formula := (bigconj L).neg

@[simp] theorem bigconj_nil : bigconj [] = Formula.bot.neg := rfl

@[simp] theorem bigconj_singleton (φ : Formula) : bigconj [φ] = φ := rfl

@[simp] theorem bigconj_cons_cons (φ ψ : Formula) (rest : List Formula) :
    bigconj (φ :: ψ :: rest) = Formula.and φ (bigconj (ψ :: rest)) := rfl

@[simp] theorem neg_bigconj_def (L : List Formula) :
    neg_bigconj L = (bigconj L).neg := rfl

end Bimodal.Syntax
