# Seed Research Report: Backward-Chaining Lemma Database (solve_by_elim Analogue)

**Task**: #187 — Backward-chaining lemma database (solve_by_elim analogue)
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The `modal_search` tactic currently knows only two categories of proof steps: axiom schemata (via `tryAxiomMatch`) and context assumptions (via `tryAssumptionMatch`). It cannot apply any of the ~85 derived theorems across `Combinators.lean`, `Propositional.lean`, `ModalS5.lean`, `TemporalDerived.lean`, `Perpetuity.lean`, and `GeneralizedNecessitation.lean`. This means goals that could be closed by a single `exact imp_trans h1 h2` or `exact rcp ...` require manual intervention.

The gap is particularly acute for proofs that need multi-step chains of derived lemmas. For example, proving `⊢ A.neg.neg.imp A` requires knowing about `double_negation`; proving `[A.and B] ⊢ A` requires `lce`. Users currently write these steps manually, even though the proof is mechanical.

A backward-chaining lemma database — analogous to Mathlib's `solve_by_elim` — would register derived theorems and allow `modal_search` to automatically backward-chain through them. This is the single most impactful Tier 2 improvement: it turns the tactic from a shallow axiom/assumption matcher into a genuine theorem prover that knows the library.

## Current State

### Mathlib's solve_by_elim

Mathlib's `solve_by_elim` works by:
1. Maintaining a list of lemmas (from `@[solve_by_elim]` attributes or explicit parameters)
2. For the current goal, trying `apply` with each lemma in sequence
3. If `apply` succeeds, recursively solving the new subgoals
4. Backtracking if all recursive attempts fail
5. Depth-limited to prevent infinite loops

Key features: attribute-driven registration, configurable lemma lists, depth limits, backtracking via `observing?`, integration with `simp` for side conditions.

### Current tactic architecture (modal_search)

`searchProof` (Tactics.lean:862-893) uses a fixed 5-strategy pipeline. Modus ponens (`tryModusPonens`, line 655) only finds implications `φ → ψ` that are literally in the context list `Γ`. It does NOT:
- Search for implications that could be derived from axioms + theorems
- Try applying derived theorems to decompose the goal
- Backward-chain through multi-step theorem applications

Example failure: Given goal `⊢ (A.box).imp A.diamond`, `modal_search` cannot close it because `t_box_to_diamond` (ModalS5.lean:105) is not in its database. The user must manually write:
```lean
exact Bimodal.Theorems.ModalS5.t_box_to_diamond A
```

### Derived theorem inventory (~85 theorems)

**Combinators.lean** (12 theorems, all `⊢ φ` type):
- `imp_trans`: `⊢ A→B` and `⊢ B→C` gives `⊢ A→C`
- `identity`: `⊢ A→A`
- `b_combinator`: `⊢ (B→C) → (A→B) → (A→C)`
- `theorem_flip`: `⊢ (A→B→C) → B→A→C`
- `theorem_app1`: `⊢ A → (A→B) → B`
- `theorem_app2`: `⊢ A → B → (A→B→C) → C`
- `pairing`: `⊢ A → B → A∧B`
- `dni`: `⊢ A → ¬¬A`
- `combine_imp_conj`: takes two imps, returns conj
- `temp_future_derived`: `⊢ □φ → G□φ`

**Propositional.lean** (30+ theorems, mixed types):
- Empty context (`⊢ φ`): `lem`, `double_negation`, `raa`, `efq`, `lce_imp`, `rce_imp`, `classical_merge`, `contrapose_imp`, `demorgan_*`, `bi_imp`
- With context (`Γ ⊢ φ`): `ecq`, `ldi`, `rdi`, `rcp`, `lce`, `rce`, `ni`, `ne`, `de`, `or_elim_neg_neg`
- Polymorphic (`Γ` as parameter): `contraposition` (takes `⊢ A→B`, returns `⊢ ¬B→¬A`)

**ModalS5.lean** (15 theorems): `t_box_to_diamond`, `box_disj_intro`, `box_contrapose`, `k_dist_diamond`, `box_iff_intro`, `t_box_consistency`, `box_conj_iff`, `diamond_disj_iff`, `s5_diamond_box`, `s5_diamond_box_to_truth`

**TemporalDerived.lean** (15 theorems): `temp_k_dist_derived`, `temp_4_derived`, `G_distribution`, `H_distribution`, `G_transitivity`, `H_transitivity`, various bridge lemmas

**GeneralizedNecessitation.lean** (6 theorems): `reverse_deduction`, `past_necessitation`, `past_k_dist`, `generalized_modal_k`, `generalized_temporal_k`, `generalized_past_k`

### Type signatures that matter

Theorems fall into several categories by signature:

1. **Closed theorems** (`⊢ φ`): Can be applied to any goal `Γ ⊢ φ` via weakening. Examples: `identity`, `double_negation`, `lem`, `b_combinator`, most axiom-like derived theorems.

2. **Context-specific** (`[A, B] ⊢ C`): Require the goal context to contain specific formulas. Examples: `ecq : [A, ¬A] ⊢ B`, `lce : [A∧B] ⊢ A`.

3. **Inference rules** (`(⊢ A→B) → (⊢ B→C) → (⊢ A→C)`): Take proof arguments and return proofs. Examples: `imp_trans`, `contraposition`, `mp`.

4. **Necessitation variants** (`(⊢ A) → (⊢ □A)`): Take empty-context proofs and wrap in modality. Examples: `necessitation`, `temporal_necessitation`, `generalized_modal_k`.

Each category requires a different backward-chaining strategy.

## Proposed Approach

### Phase 1: @[tm_lemma] attribute infrastructure

Define a custom attribute `@[tm_lemma]` that registers theorems in an environment extension:

```lean
initialize tmLemmaExt : TagAttribute ←
  registerTagAttribute `tm_lemma "Register a theorem for TM proof search backward chaining"
```

This allows incremental registration: annotate theorems in their defining files, and the database grows as files are imported.

### Phase 2: Lemma database query function

Create a function that, given a goal `Γ ⊢ φ`, retrieves all registered lemmas whose conclusion could match:

```lean
def queryTMLemmas (goalType : Expr) : MetaM (List Name) := do
  let lemmas ← tmLemmaExt.getTaggedDecls
  -- Filter by conclusion matching
  ...
```

Use lightweight pre-filtering (check conclusion head symbol before full unification) to avoid trying all ~85 lemmas on every subgoal.

### Phase 3: tryLemmaMatch function in searchProof

Add a new strategy to `searchProof` between `tryAxiomMatch` and `tryModusPonens`:

```lean
def tryLemmaMatch (goal : MVarId) (ctx formula : Expr)
    (searchFn : MVarId → Nat → TacticM Bool) (depth : Nat) : TacticM Bool := do
  let lemmas ← queryTMLemmas (← goal.getType)
  for lemmaName in lemmas do
    let success ← observing? do
      let lemmaExpr := mkConst lemmaName
      let newGoals ← goal.apply lemmaExpr
      -- Recursively try to close new subgoals
      for subgoal in newGoals do
        let subSuccess ← searchFn subgoal (depth - 1)
        if !subSuccess then throwError "subgoal failed"
    if success.isSome then return true
  return false
```

### Phase 4: Category-specific handling

Implement category-specific matching:

1. **Closed theorems**: Apply directly, then prove `G ⊆ D` membership for weakening.
2. **Context-specific**: Check if goal context is superset of theorem context (via list subset check), then apply with weakening.
3. **Inference rules**: Apply the rule, creating metavariable subgoals for the premise proofs, then recursively search for those.
4. **Necessitation variants**: Only applicable when goal context is empty `[]`.

### Phase 5: Annotate existing theorems

Add `@[tm_lemma]` to the ~85 derived theorems across the 5 theorem files. Start with the most commonly useful ones and expand.

### Phase 6: Tests

Create test suite verifying the lemma database closes goals that currently require manual proof. Include multi-step chains (e.g., goals requiring `imp_trans` + `double_negation`).

## Key Questions for Research Phase

1. **Attribute vs explicit list**: Should we use a Lean 4 `TagAttribute` / `ScopedEnvExtension`, or maintain an explicit list? Attributes are more modular but add import-order dependencies. Explicit lists are simpler but must be manually maintained.

2. **Pre-filtering strategy**: What's the best heuristic for filtering lemmas before full unification? Options: (a) match head symbol of conclusion, (b) check arity, (c) check modality nesting depth. Mathlib's `DiscrTree` is the gold standard here — should we use it?

3. **Depth budget allocation**: When `tryLemmaMatch` creates subgoals from applying a lemma, how much depth budget should each subgoal receive? Equal split? Remaining budget minus 1? This affects completeness vs performance.

4. **Interaction with modus ponens**: `tryModusPonens` already does backward chaining through context implications. Should `tryLemmaMatch` subsume this, or coexist as a separate strategy? If they coexist, what's the ordering?

5. **Noncomputable theorems**: Many derived theorems are `noncomputable` (using the deduction theorem). Confirm that `mkAppM` with noncomputable constants works in `TacticM` — it should, since we're constructing terms, not evaluating them.

6. **Rule set separation**: Should there be multiple rule sets (propositional, modal, temporal) that can be selectively enabled, similar to aesop's rule set mechanism? This would let users write `modal_search +prop` to search only with propositional lemmas.

7. **Forward vs backward chaining**: The existing `AesopRules.lean` defines forward-chaining rules (`modal_t_forward`, `modal_4_forward`, etc.). Should the lemma database support both forward and backward chaining? Forward chaining is useful for saturation-based search.

## Estimated Scope

- **Phase 1** (attribute infrastructure): 3 hours
- **Phase 2** (query function): 4 hours
- **Phase 3** (tryLemmaMatch): 5 hours
- **Phase 4** (category-specific handling): 6 hours
- **Phase 5** (annotate theorems): 3 hours
- **Phase 6** (tests): 4 hours
- **Total**: ~25 hours (large effort)

## Dependencies

- **Depends on**: Task 185 (complete axiom coverage — the lemma database builds on top of complete axiom matching)
- **Depended on by**: Task 188 (weakening-aware search — uses lemma database for weakening-compatible theorem application), Task 192 (master dispatch — lemma database is a core search component)
- **Related**: Task 186 (unify search — lemma database should work with both tactic and computable search), Task 189 (deduction theorem tactic — uses similar backward-chaining infrastructure)

## References

- `Theories/Bimodal/Automation/Tactics.lean` — `searchProof` (862), `tryAxiomMatch` (507), `tryModusPonens` (655)
- `Theories/Bimodal/Theorems/Combinators.lean` — 12 theorems
- `Theories/Bimodal/Theorems/Propositional.lean` — 30+ theorems
- `Theories/Bimodal/Theorems/ModalS5.lean` — 15 theorems
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — 15 theorems
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` — 6 theorems
- Mathlib `solve_by_elim`: `Mathlib.Tactic.SolveByElim` — attribute-driven backward chaining
- Mathlib `DiscrTree`: `Lean.Meta.DiscrTree` — discrimination tree for efficient lemma indexing
- Lean 4 metaprogramming book: Chapter on custom attributes and environment extensions
