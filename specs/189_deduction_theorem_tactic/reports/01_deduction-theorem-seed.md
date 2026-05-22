# Seed Research Report: Deduction Theorem Tactic

**Task**: #189 — Deduction theorem tactic
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The deduction theorem is the most important metatheorem in Hilbert-style proof systems. It converts `A :: Γ ⊢ B` to `Γ ⊢ A → B`, bridging the gap between natural-deduction-style reasoning (with assumptions in the context) and Hilbert-style reasoning (where everything is expressed through implication). The TM codebase has a fully-proven `deduction_theorem` (`DeductionTheorem.lean:336`), and it is used extensively — at least 20 call sites across `Metalogic/`, particularly in `RestrictedMCS.lean` (10 uses), `MCSProperties.lean` (2 uses), `MaximalConsistent.lean` (2 uses), and `AlgebraicCompleteness.lean` (1 use).

Currently, every use of the deduction theorem is an explicit term-level call: `deduction_theorem Γ φ Formula.bot d_bot`. There is no tactic that wraps it. This means proofs that want to "introduce a hypothesis" must manually construct the derivation in the extended context and then call the deduction theorem, rather than using a natural-deduction-style `intro`-like step.

A `deduction` tactic would give Hilbert-system proofs the ergonomics of natural deduction. Given a goal `Γ ⊢ A → B`, it would produce the subgoal `A :: Γ ⊢ B`, letting the user work with `A` as an assumption. The reverse direction (`undischarge`) would convert `A :: Γ ⊢ B` back to `Γ ⊢ A → B` by applying the deduction theorem. Together these make Hilbert-system proofs feel like natural deduction while remaining formally grounded in the Hilbert calculus.

## Current State

### Deduction Theorem (DeductionTheorem.lean:336)

```lean
noncomputable def deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B
```

Key implementation details:
- **Noncomputable**: Uses `Classical.propDecidable` for case analysis on `A ∈ Γ`, making the entire function noncomputable. This means tactics using it will produce `noncomputable` proof terms.
- **Well-founded recursion on height**: The proof recurses on `h.height`, with cases for axiom, assumption (same/other), modus ponens, weakening (three subcases), and the modal/temporal rules (impossible with non-empty context).
- **Helper `deduction_with_mem`** (line 209): Handles the general case where `A` appears anywhere in `Γ'` (not just at the head), using `removeAll` to strip `A` from the context.

### Usage Pattern in Metalogic/

The dominant usage pattern is to derive negation via contradiction:

```lean
-- Typical pattern (RestrictedMCS.lean:189, MaximalConsistent.lean:369):
have d_neg : DerivationTree Γ psi.neg := deduction_theorem Γ psi Formula.bot d_bot'
```

This constructs `¬ψ` (= `ψ → ⊥`) by:
1. Assuming `ψ` is in context (giving `ψ :: Γ ⊢ ⊥`)
2. Applying deduction theorem to get `Γ ⊢ ψ → ⊥`

### Existing Combinator Infrastructure (Combinators.lean)

The deduction theorem is the "discharge" direction. The "introduction" direction is handled by combinators:
- `identity : ⊢ A → A` (SKK construction)
- `imp_trans : ⊢ (A → B) → (B → C) → (A → C)` (hypothetical syllogism)
- `b_combinator : ⊢ (B → C) → (A → B) → (A → C)` (composition)
- `theorem_flip : ⊢ (A → B → C) → (B → A → C)` (argument flip)

These are used extensively in `Theorems/` for building Hilbert-style proofs. A `deduction` tactic would provide an alternative to chaining these combinators manually.

### Generalized Necessitation (GeneralizedNecessitation.lean)

The generalized K rules (modal and temporal) are derived using the deduction theorem:
```lean
-- generalized_modal_k uses deduction_theorem internally
noncomputable def generalized_modal_k (Γ : Context) (φ : Formula)
    (h : Γ ⊢ φ) : (Context.map Formula.box Γ) ⊢ (Formula.box φ)
```

A deduction tactic would also enable more ergonomic proofs of derived K-rule results.

## Proposed Approach

### Phase 1: `deduction` Tactic (Implication Introduction)

Given goal `Γ ⊢ A → B`, produce subgoal `A :: Γ ⊢ B`:

```lean
elab "deduction" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType
  match goalType with
  | -- Match DerivationTree Γ (Formula.imp A B)
    .app (.app (.const ``DerivationTree _) ctx) (.app (.app (.const ``Formula.imp _) a) b) =>
    -- Build new goal: DerivationTree (A :: Γ) B
    let newCtx ← mkAppM ``List.cons #[a, ctx]
    let newGoalType ← mkAppM ``DerivationTree #[newCtx, b]
    let newGoalMVar ← mkFreshExprMVar newGoalType
    -- Apply deduction_theorem to connect
    let proof ← mkAppM ``deduction_theorem #[ctx, a, b, newGoalMVar]
    goal.assign proof
    replaceMainGoal [newGoalMVar.mvarId!]
  | _ => throwError "deduction: goal must be Γ ⊢ A → B"
```

### Phase 2: `undischarge` Tactic (Deduction Theorem Application)

Given goal `Γ ⊢ A → B` and hypothesis `h : A :: Γ ⊢ B`, close the goal:

```lean
elab "undischarge" h:ident : tactic => do
  -- Apply deduction_theorem with the hypothesis
  evalTactic (← `(tactic| exact deduction_theorem _ _ _ $h))
```

### Phase 3: Iterated Deduction

Support introducing multiple hypotheses at once:

```lean
-- deduction n: introduce n hypotheses from nested implications
-- Goal: Γ ⊢ A → B → C → D
-- After `deduction 3`: C :: B :: A :: Γ ⊢ D
```

### Phase 4: Noncomputability Handling

Since `deduction_theorem` is `noncomputable`, any proof using the tactic will also be noncomputable. Options:
- Accept `noncomputable` — this is fine for most Metalogic/ proofs which are already noncomputable
- Document clearly that `deduction` produces noncomputable terms
- Investigate whether a computable variant is possible (likely not without removing Classical logic)

## Key Questions for Research Phase

1. **Noncomputability propagation**: How much of the codebase is already `noncomputable`? If most Metalogic/ proofs are noncomputable anyway, this is a non-issue. Quantify the overlap.
2. **Interaction with `modal_search`**: Should `modal_search` automatically try `deduction` when the goal is an implication? This would give it the power to reason about implications by reducing to context-based search.
3. **Proof term size**: The deduction theorem proof is recursive on tree height and can produce large terms. Is this a practical concern for elaboration performance?
4. **Exchange/permutation**: The deduction theorem puts `A` at the head of the context. If `A` is already in `Γ` (not at the head), should `deduction` handle this transparently via the `deduction_with_mem` variant?
5. **Naming conventions**: Should the tactic be called `deduction`, `discharge`, `hilbert_intro`, or something else? What naming convention best communicates its role?
6. **Reverse direction ergonomics**: The `undischarge` tactic applies the deduction theorem to an existing hypothesis. Is there a cleaner API — perhaps a `have` variant that combines building the contextual proof and discharging?

## Estimated Scope

- **Phase 1**: Basic `deduction` tactic — 4 hours
- **Phase 2**: `undischarge` tactic — 2 hours
- **Phase 3**: Iterated deduction — 2 hours
- **Phase 4**: Testing, edge cases, noncomputability docs — 4 hours
- **Total**: ~12 hours (medium effort)

## Dependencies

- **Depends on**: Task 185 (complete axiom coverage) — the deduction theorem tactic benefits from full axiom integration in `modal_search`
- **Independent of**: Task 187 (lemma database) — the tactic works standalone
- **Depended on by**: Task 192 (master tactic dispatch) — `deduction` is one of the tactics the master dispatcher should know about
- **Depended on by**: Task 193 (codebase-wide refactor) — many explicit `deduction_theorem` calls could become tactic invocations

## References

- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean:336` — `deduction_theorem` definition
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean:209` — `deduction_with_mem` (general context case)
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean:186` — `deduction_mp` (K axiom distribution helper)
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean:369` — typical usage (negation via contradiction)
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` — 10 usage sites
- `Theories/Bimodal/Theorems/Combinators.lean` — combinator infrastructure (alternative to deduction)
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` — uses deduction_theorem internally
- Lean 4 metaprogramming: `mkAppM`, `mkFreshExprMVar`, `goal.assign`
