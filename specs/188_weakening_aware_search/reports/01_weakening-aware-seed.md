# Seed Research Report: Weakening-Aware Proof Search

**Task**: #188 — Weakening-aware proof search
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The weakening rule (`DerivationTree.weakening`) is one of the most frequently used inference rules in the TM proof system, with 50 uses across `Theorems/` and 186 uses across `Metalogic/`. The pattern is always the same: prove from a smaller context (often `[]`), then weaken to the actual goal context. Currently, every one of these applications is manual — the user must explicitly write `DerivationTree.weakening G D p d (List.nil_subset D)` or equivalent.

Neither `modal_search` (Tactics.lean) nor the computable `bounded_search_with_proof` (ProofSearch.lean) apply weakening automatically. The tactic `modal_search` extracts the goal context and formula at line 488 (`extractDerivationGoal`), then searches for axioms/assumptions/modus ponens within that exact context. If a theorem is proven from `[]` but the goal context is `[p, q]`, the tactic cannot find it unless it explicitly knows to weaken.

This limitation means the tactics are blind to any previously-proven theorem or lemma that was established from a smaller context. Since most axioms and derived theorems operate from `[]` (empty context), and most goals in Metalogic/ have non-empty contexts, this is a pervasive gap. Closing it would enable the tactics to automatically close many goals that currently require 2-3 manual steps (prove from smaller context + weaken + apply).

## Current State

### Weakening Constructor (Derivation.lean:146)

```lean
| weakening (Γ Δ : Context) (φ : Formula)
    (d : DerivationTree Γ φ)
    (h : Γ ⊆ Δ) : DerivationTree Δ φ
```

### Manual Weakening Patterns

The dominant pattern in the codebase is weakening from empty context:

```lean
-- Pattern 1: Weaken theorem to non-empty context (most common, ~150 instances)
DerivationTree.weakening [] Γ φ theorem_proof (List.nil_subset Γ)

-- Pattern 2: Weaken from subset context (Metalogic, ~30 instances)
DerivationTree.weakening G D φ proof (subset_proof)
```

In `AesopRules.lean`, the weakening pattern appears explicitly:
- `axiom_temp_4` (line 101-103): Proves from `[]` then weakens to `Γ`
- `axiom_temp_a` (line 107-109): Direct axiom (no weakening needed)

### Current Search Architecture (Tactics.lean)

The `searchProof` function (line 862) extracts the context and formula from the goal:

```lean
let some (ctx, formula) ← extractDerivationGoal goalType
```

Then tries strategies in order:
1. `tryAxiomMatch` — checks if formula matches an axiom schema (ignores context)
2. `tryAssumptionMatch` — checks if formula is in `ctx` via `simp`
3. `tryModusPonens` — searches for `ψ → φ` literally in `ctx`
4. `tryModalK` / `tryTemporalK` — context-transforming rules

Strategy 1 (axiom match) already implicitly handles weakening for axioms: it constructs `DerivationTree.axiom G φ h` which works for any context `G`. But strategies 3-5 and the lemma database (task 187) do not handle the case where a known result has a smaller context than the goal.

### Computable Search (ProofSearch.lean)

The `bounded_search` function (line 779) and `bounded_search_with_proof` (line 886) both only check `Γ.contains φ` for assumptions. Neither tries to find proofs from subsets of `Γ`.

## Proposed Approach

### Phase 1: Context Subsumption Checker

Implement a `MetaM` function that checks whether one context is a subset of another:

```lean
def isContextSubset (smallCtx goalCtx : Expr) : MetaM Bool := do
  let smallFormulas ← extractContextFormulas smallCtx
  let goalFormulas ← extractContextFormulas goalCtx
  -- Check each formula in small is in goal (using isDefEq for matching)
  for f in smallFormulas do
    let found ← goalFormulas.anyM (isDefEq f)
    if !found then return false
  return true
```

### Phase 2: Weakening-Aware Axiom/Theorem Application

Extend `tryAxiomMatch` to also try registered theorems from smaller contexts:

```lean
def tryWeakenedLemma (goal : MVarId) (ctx formula : Expr) 
    (lemmaDb : LemmaDatabase) : TacticM Bool := do
  for (lemmaName, lemmaCtx, lemmaFormula) in lemmaDb.entries do
    if ← isDefEq formula lemmaFormula then
      if ← isContextSubset lemmaCtx ctx then
        -- Build: DerivationTree.weakening lemmaCtx ctx formula lemmaProof subsetProof
        ...
        return true
  return false
```

### Phase 3: Integration with Lemma Database (Task 187)

The lemma database (task 187) will register theorems with their contexts. The weakening-aware search adds a new strategy to `searchProof`:

```
Strategy order:
1. Axiom match (already handles weakening for axioms)
2. Assumption match
3. **Weakened lemma match** (NEW — check registered lemmas from smaller contexts)
4. Modus ponens
5. Modal K / Temporal K
```

### Phase 4: Subset Proof Construction

The subset proof `h : Γ ⊆ Δ` needs to be constructed automatically. For the common case `[] ⊆ Δ`, this is `List.nil_subset Δ`. For general subsets, use `simp` or `decide` on the list membership goals.

## Key Questions for Research Phase

1. What is the performance cost of checking context subsumption for every candidate lemma? Should we index lemmas by formula and only check subsumption on matches?
2. Should we integrate with `simp` for constructing `Γ ⊆ Δ` proofs, or build a dedicated subset prover that handles the common cases (nil subset, cons subset, subset refl)?
3. How does this interact with the modal K and temporal K rules, which transform contexts? Should we try weakening before or after context transformation?
4. For the computable search (`ProofSearch.lean`), context subsumption is decidable — should `bounded_search_with_proof` also gain weakening awareness?
5. Should the lemma database store "canonical forms" (context-free versions of theorems from `[]`) separately for O(1) lookup?

## Estimated Scope

- **Phase 1**: Context subsumption checker — 2 hours
- **Phase 2**: Weakening-aware lemma application — 4 hours  
- **Phase 3**: Lemma database integration — 3 hours
- **Phase 4**: Subset proof construction + testing — 3 hours
- **Total**: ~12 hours (medium effort)

## Dependencies

- **Depends on**: Task 187 (backward-chaining lemma database) — needs the registered lemma infrastructure
- **Depends on**: Task 185 (complete axiom coverage) — ensures full axiom set available
- **Depended on by**: Task 192 (master tactic dispatch) — weakening awareness feeds into the unified tactic
- **Depended on by**: Task 193 (codebase-wide refactor) — many manual weakening calls become automatable

## References

- `Theories/Bimodal/ProofSystem/Derivation.lean:146` — weakening constructor
- `Theories/Bimodal/Automation/Tactics.lean:862` — `searchProof` function
- `Theories/Bimodal/Automation/Tactics.lean:507` — `tryAxiomMatch` (implicit weakening for axioms)
- `Theories/Bimodal/Automation/Tactics.lean:579` — `tryAssumptionMatch`
- `Theories/Bimodal/Automation/ProofSearch.lean:886` — `bounded_search_with_proof`
- `Theories/Bimodal/Automation/AesopRules.lean:101` — manual weakening pattern in aesop rules
- Mathlib `solve_by_elim` — Lean 4 backward chaining tactic (context-aware application)
