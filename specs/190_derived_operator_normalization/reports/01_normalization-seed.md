# Seed Research Report: Derived Operator Normalization Tactic

**Task**: #190 — Derived operator normalization tactic
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The TM logic `Formula` type has 6 primitive constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) but 15+ derived operators built from them. These derived operators (`neg`, `and`, `or`, `diamond`, `all_future`, `all_past`, `some_future`, `some_past`, `always`, `sometimes`, `top`, `next`, `prev`, `weak_future`, `weak_past`) introduce significant branching in proof search because the search must recognize each derived form separately.

For example, `diamond φ` is defined as `(φ.neg.box).neg`, which is `((φ.imp bot).box).imp bot`. A search tactic seeing `◇p` must recognize this as a specific pattern, but the same formula could also appear in its expanded form. The search currently handles this inconsistently: `AesopRules.lean` defines `@[aesop norm unfold]` rules for 4 operators (`diamond`, `always`, `sometimes`, `some_past`), but these only work with aesop and don't help `modal_search`.

A `modal_norm` tactic that normalizes all derived operators to primitive form before search would:
1. Reduce the pattern space the search must handle (from 15+ operators to 6 primitives)
2. Eliminate mismatches between derived and expanded forms
3. Make axiom matching more reliable (axiom patterns use specific derived forms)
4. Enable simpler heuristic scoring (only primitive operators to classify)

## Current State

### Derived Operator Inventory (Formula.lean)

| Operator | Definition | Expansion to Primitives |
|----------|-----------|------------------------|
| `neg φ` | `φ.imp bot` | `imp φ bot` |
| `top` | `bot.imp bot` | `imp bot bot` |
| `and φ ψ` | `(φ.imp ψ.neg).neg` | `imp (imp φ (imp ψ bot)) bot` |
| `or φ ψ` | `φ.neg.imp ψ` | `imp (imp φ bot) ψ` |
| `diamond φ` | `φ.neg.box.neg` | `imp (box (imp φ bot)) bot` |
| `some_future φ` | `untl φ top` | `untl φ (imp bot bot)` |
| `some_past φ` | `snce φ top` | `snce φ (imp bot bot)` |
| `all_future φ` | `(some_future φ.neg).neg` | `imp (untl (imp φ bot) (imp bot bot)) bot` |
| `all_past φ` | `(some_past φ.neg).neg` | `imp (snce (imp φ bot) (imp bot bot)) bot` |
| `always φ` | `φ.all_past.and (φ.and φ.all_future)` | (deeply nested) |
| `sometimes φ` | `φ.neg.always.neg` | (deeply nested) |
| `next φ` | `untl φ bot` | `untl φ bot` |
| `prev φ` | `snce φ bot` | `snce φ bot` |
| `weak_future φ` | `φ.and φ.all_future` | (nested) |
| `weak_past φ` | `φ.and φ.all_past` | (nested) |

### Existing Normalization (AesopRules.lean:253-278)

Four operators have `@[aesop norm unfold]` annotations:

```lean
@[aesop norm unfold] def normalize_diamond := @Formula.diamond      -- line 254
@[aesop norm unfold] def normalize_always := @Formula.always         -- line 261
@[aesop norm unfold] def normalize_sometimes := @Formula.sometimes   -- line 269
@[aesop norm unfold] def normalize_some_past := @Formula.some_past   -- line 277
```

Missing from normalization: `neg`, `and`, `or`, `top`, `some_future`, `all_future`, `all_past`, `next`, `prev`, `weak_future`, `weak_past`.

### Impact on Proof Search (Tactics.lean)

The `matches_axiom` function in `ProofSearch.lean` (line 302) pattern-matches against axiom schemata using the derived operator forms. For example, the `modal_b` check (line 337-339) matches `φ → □◇φ` where `◇φ = φ.diamond`. If the goal arrives in expanded form (`φ → ((φ.neg.box).neg).box`), the pattern won't match.

The `tryAxiomMatch` function in `Tactics.lean` (line 507) uses `mkAppM` to apply axiom constructors, letting Lean's unifier handle matching. This is more robust but still depends on the goal being in a recognizable form.

The `matchAxiom` function in `ProofSearch.lean` (line 396) explicitly pattern-matches the expanded forms of derived operators (e.g., lines 428-432 match `modal_5_collapse` as `.imp (.box (.imp phi .bot)) .bot` for diamond). This duplicates knowledge of the operator definitions.

### Formula `complexity` and Heuristics

The `complexity` function (Formula.lean:162) only counts primitive constructors. Derived operators like `all_future` expand to 7 primitives (`imp (untl (imp φ bot) (imp bot bot)) bot`), giving a complexity of 7 + φ.complexity. This inflates heuristic scores for temporal goals, potentially deprioritizing them unfairly.

## Proposed Approach

### Phase 1: `modal_norm` Simp Lemmas

Create a set of `@[simp]` lemmas that unfold derived operators:

```lean
-- In a new file: Theories/Bimodal/Automation/Normalization.lean

@[simp] theorem neg_def (φ : Formula) : φ.neg = φ.imp .bot := rfl
@[simp] theorem top_def : Formula.top = Formula.bot.imp .bot := rfl
@[simp] theorem and_def (φ ψ : Formula) : φ.and ψ = (φ.imp ψ.neg).neg := rfl
@[simp] theorem or_def (φ ψ : Formula) : φ.or ψ = φ.neg.imp ψ := rfl
@[simp] theorem diamond_def (φ : Formula) : φ.diamond = φ.neg.box.neg := rfl
-- ... etc for all derived operators
```

### Phase 2: `modal_norm` Tactic

A tactic that applies these simp lemmas to the goal:

```lean
macro "modal_norm" : tactic =>
  `(tactic| simp only [neg_def, top_def, and_def, or_def, diamond_def,
    some_future_def, some_past_def, all_future_def, all_past_def,
    always_def, sometimes_def, next_def, prev_def, weak_future_def, weak_past_def])
```

This tactic reduces any goal to use only the 6 primitive constructors.

### Phase 3: Selective Normalization

Not all normalizations are equally useful. Sometimes keeping `all_future` is better than expanding to `imp (untl (imp φ bot) (imp bot bot)) bot`. Provide selective variants:

```lean
-- Only normalize propositional derived operators
macro "prop_norm" : tactic =>
  `(tactic| simp only [neg_def, top_def, and_def, or_def])

-- Only normalize modal derived operators  
macro "modal_op_norm" : tactic =>
  `(tactic| simp only [diamond_def])

-- Only normalize temporal derived operators
macro "temporal_norm" : tactic =>
  `(tactic| simp only [some_future_def, some_past_def, all_future_def, 
    all_past_def, always_def, sometimes_def])
```

### Phase 4: Integration with `modal_search`

Add an optional normalization pass at the start of `modal_search`:

```lean
-- In searchProof, before trying any strategy:
-- Optionally normalize the goal formula
if config.normalize then
  evalTactic (← `(tactic| modal_norm))
```

Also normalize the formula in the computable `matches_axiom` (ProofSearch.lean) so axiom matching works on both derived and expanded forms.

### Phase 5: Canonical Form Theory

Define and prove properties of a canonical form function:

```lean
def Formula.normalize : Formula → Formula
  | atom a => atom a
  | bot => bot
  | imp φ ψ => imp φ.normalize ψ.normalize
  | box φ => box φ.normalize
  | untl φ ψ => untl φ.normalize ψ.normalize
  | snce φ ψ => snce φ.normalize ψ.normalize

-- All derived operators reduce to canonical form automatically
-- since they are definitional equalities
```

This is trivial because the derived operators are already `def` abbreviations (not constructors), so `normalize` just recursively visits the expanded form.

## Key Questions for Research Phase

1. **Full vs. selective normalization**: Should `modal_norm` always expand everything, or should it preserve "natural" forms like `all_future` that appear directly in axiom schemata? The axiom `modal_future : □φ → □(Gφ)` uses `all_future` — if we expand `Gφ` to its primitive form, does the axiom still match?
2. **Performance**: Does normalization produce significantly larger terms? `always φ` expands to a very deep nesting. Measure the term size blow-up.
3. **Bidirectional normalization**: Should there be a "fold" direction too (`fold_derived`) that recognizes primitive patterns and introduces derived operators? This would help readability of proof states.
4. **Interaction with `simp`**: Some Lean `simp` lemmas may already partially normalize or interfere. Map out existing simp lemmas on Formula.
5. **`whnf` vs `simp`**: Since derived operators are `def`, Lean's `whnf` (weak head normal form) will unfold them. Should the tactic use `whnf` instead of `simp` for efficiency?
6. **Axiom matching after normalization**: If `matches_axiom` is updated to work on normalized forms, does the `matchAxiom` function (ProofSearch.lean:396) simplify significantly? Currently it has ~120 lines of explicit pattern matching for derived operator forms.

## Estimated Scope

- **Phase 1**: Simp lemmas for all derived operators — 2 hours
- **Phase 2**: `modal_norm` macro tactic — 1 hour
- **Phase 3**: Selective normalization variants — 2 hours
- **Phase 4**: Integration with `modal_search` — 3 hours
- **Phase 5**: Canonical form theory + testing — 4 hours
- **Total**: ~12 hours (medium effort)

## Dependencies

- **Independent**: No prerequisites — this can be developed standalone
- **Depended on by**: Task 192 (master tactic dispatch) — normalization is a preprocessing step for the unified tactic
- **Synergizes with**: Task 185 (axiom coverage) — normalization makes axiom matching more uniform
- **Synergizes with**: Task 187 (lemma database) — normalized forms enable better lemma lookup

## References

- `Theories/Bimodal/Syntax/Formula.lean:70` — primitive Formula constructors
- `Theories/Bimodal/Syntax/Formula.lean:112-383` — all derived operator definitions
- `Theories/Bimodal/Automation/AesopRules.lean:253-278` — existing `@[aesop norm unfold]` rules
- `Theories/Bimodal/Automation/ProofSearch.lean:302-377` — `matches_axiom` with explicit derived patterns
- `Theories/Bimodal/Automation/ProofSearch.lean:396-517` — `matchAxiom` with explicit derived patterns
- `Theories/Bimodal/Automation/Tactics.lean:507` — `tryAxiomMatch` (uses mkAppM)
- Lean 4 `simp` documentation — lemma registration and simp sets
- Mathlib `norm_num` — precedent for normalization tactics in Lean 4
