# Seed Research Report: Master Tactic Dispatch (tm_prove)

**Task**: #192 — Master tactic dispatch (tm_prove)
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The current automation landscape in the ProofChecker codebase is fragmented across multiple systems that operate in isolation:

1. **`modal_search`** (Tactics.lean:862-1042) — TacticM-based depth-first search over `DerivationTree : Type` goals. Works by constructing proof terms directly via `mkAppM`. Handles axioms, assumptions, modus ponens, modal K, and temporal K. No access to derived theorems beyond `temp_future_derived`.

2. **`ProofSearch.lean`** (1400 lines) — Computable search with IDDFS, best-first, and pattern learning. Returns `Bool` or `Option (DerivationTree G p)`. Cannot be invoked from tactic mode.

3. **`AesopRules.lean`** — Deprecated aesop rules on `DerivationTree`. Aesop fails on Type-valued goals due to proof reconstruction errors.

4. **Task 181's `Derivable`** — Will enable aesop for Prop-valued derivability goals.

5. **Task 191's `decide_prop`** — Will enable `decide` for propositional derivability goals.

A user writing proofs currently must know which tool to reach for in each situation. A master `tm_prove` tactic that analyzes the goal and dispatches to the right sub-tactic would provide a single entry point, like Mathlib's `aesop` or `simp` — one tactic to try first, with specialized fallbacks.

The transfer principle between `Derivable` (Prop) and `DerivationTree` (Type) is the key architectural insight: for goals where the specific tree doesn't matter (most theorem statements), prove at the Prop level using powerful Prop-level tools (aesop, decide), then lift to Type level via `Classical.choice` when needed. For goals where the tree matters (height computation, pattern matching in Metalogic), stay at the Type level and use `modal_search`.

## Current State

### Goal Type Landscape

Goals in the codebase come in several forms:

| Goal Type | Example | Current Tool | Proposed Tool |
|-----------|---------|-------------|--------------|
| `DerivationTree [] p` (theorem) | `⊢ □p → p` | `modal_search` or manual | `tm_prove` → `modal_search` |
| `DerivationTree G p` (contextual) | `[p, p→q] ⊢ q` | `modal_search` or manual | `tm_prove` → `modal_search` |
| `Derivable [] p` (existence) | `Derivable [] (□p → p)` | (not yet available) | `tm_prove` → aesop/decide |
| `Derivable G p` (contextual existence) | `Derivable [p] p` | (not yet available) | `tm_prove` → aesop |
| `¬Derivable G ⊥` (consistency) | `Consistent G` | manual | `tm_prove` → specialized |
| `Nonempty (DerivationTree G p)` (legacy) | completeness | manual | rewrite to `Derivable`, then dispatch |

### Formula Classification

The `Formula` type (Formula.lean:70-85) has 6 constructors. A formula can be classified by which operators it uses:

| Category | Constructors Used | Best Tactic |
|----------|-------------------|-------------|
| Propositional | `atom`, `bot`, `imp` only | `decide_prop` (task 191) |
| Modal | adds `box` | `modal_search` with modal K |
| Temporal | adds `untl`, `snce` (hence `all_future`, `all_past`, etc.) | `temporal_search` |
| Bimodal | `box` + `untl`/`snce` | `modal_search` (full) |

Existing infrastructure for classification:
- `Formula.modalDepth` (Formula.lean:262) — 0 means no modal operators
- `Formula.temporalDepth` (Formula.lean:283) — 0 means no temporal operators
- `GoalCategory` (SuccessPatterns.lean:59-68) — top-level operator classification

### Transfer Principle

The bridge between `DerivationTree : Type` and `Derivable : Prop`:

```lean
-- Type → Prop (always works)
theorem Derivable.ofTree (d : DerivationTree G p) : Derivable G p := ⟨d⟩

-- Prop → Type (requires Classical.choice, noncomputable)
noncomputable def Derivable.toTree (h : Derivable G p) : DerivationTree G p := h.some
```

The transfer is noncomputable in the Prop→Type direction, which means:
- If the caller needs a computable tree (height computation, pattern matching), stay at Type level
- If the caller only needs existence (theorem statements, consistency proofs), the Prop level is fine
- `tm_prove` should detect which level the goal is at and choose accordingly

## Proposed Approach

### Phase 1: Goal Analysis Infrastructure

Define meta-level goal analysis in TacticM:

```lean
inductive GoalLevel where
  | typeLevel   -- DerivationTree G p : Type
  | propLevel   -- Derivable G p : Prop
  | nonemptyLevel -- Nonempty (DerivationTree G p)
  | other       -- not a derivability goal

inductive FormulaCategory where
  | propositional  -- only atom, bot, imp
  | modal          -- adds box
  | temporal       -- adds untl/snce
  | bimodal        -- both modal and temporal

def classifyGoal (goalType : Expr) : MetaM GoalLevel := ...
def classifyFormula (formula : Expr) : MetaM FormulaCategory := ...
```

### Phase 2: Dispatch Logic

```
tm_prove:
  1. Classify goal → (level, context, formula, category)
  2. If level = propLevel:
     a. If category = propositional and context = []: try decide_prop
     b. Try aesop (TMDerivable rule set)
     c. Fallback: lift to typeLevel via Derivable.toTree, try modal_search
  3. If level = typeLevel:
     a. If category = propositional: try propositional_search
     b. Try modal_search (with appropriate depth/config)
     c. If failed: try lifting to propLevel, prove there, transfer back
  4. If level = nonemptyLevel:
     a. Rewrite to Derivable, dispatch as propLevel
  5. If level = other: fail with helpful error
```

### Phase 3: Aesop Rule Set for Derivable

Create a `TMDerivable` rule set (requires separate file from rule declarations):

```lean
declare_aesop_rule_sets [TMDerivable]

-- In Derivable.lean:
@[aesop safe apply (rule_sets := [TMDerivable])]
theorem Derivable.ax ...

@[aesop unsafe 50% apply (rule_sets := [TMDerivable])]
theorem Derivable.mp ...
```

### Phase 4: Configuration and Extensibility

```lean
structure TMProveConfig where
  maxDepth : Nat := 15
  tryDecide : Bool := true
  tryAesop : Bool := true
  tryTransfer : Bool := true
  verbose : Bool := false
```

## Key Questions for Research Phase

1. What is the performance of `Classical.choice` (via `Nonempty.some`) in practice? Does it cause kernel slowdowns for the Prop→Type transfer?
2. How does Lean 4 handle `noncomputable` in tactic-generated terms? If `tm_prove` produces a noncomputable proof via transfer, does this propagate to the enclosing definition?
3. Can we detect at the meta level whether the enclosing definition is `noncomputable` or not, to decide whether transfer is allowed?
4. Should `tm_prove` use a custom aesop rule set (`TMDerivable`) or the default rule set? Custom rule sets require the declaration to be in a separate file from the rules (Lean 4 aesop constraint).
5. How should `tm_prove` interact with the lemma database (task 187)? Should it pass registered lemmas to `modal_search` as additional apply targets?
6. What is the precedent in Mathlib for master dispatch tactics? Look at `norm_num`, `positivity`, `polyrith` for dispatch patterns.

## Estimated Scope

- **Phase 1** (8h): Goal analysis infrastructure — `classifyGoal`, `classifyFormula`, formula traversal at meta level
- **Phase 2** (8h): Dispatch logic, `tm_prove` tactic definition, integration with existing tactics
- **Phase 3** (5h): Aesop `TMDerivable` rule set, transfer lemmas
- **Phase 4** (4h): Configuration, tests, documentation
- **Total**: ~25 hours

## Dependencies

- **Depends on**: Task 181 (Derivable wrapper — needed for Prop-level dispatch and aesop rules)
- **Depends on**: Task 185 (complete axiom coverage — `modal_search` needs full axiom matching)
- **Depends on**: Task 187 (lemma database — `tm_prove` should leverage registered lemmas)
- **Depends on**: Task 190 (normalization — normalize derived operators before dispatch)
- **Depends on**: Task 191 (decision procedure — `decide_prop` for propositional fragment)
- **Depended on by**: Task 193 (codebase refactor — uses `tm_prove` as primary proof tool)

## References

- `Theories/Bimodal/Automation/Tactics.lean:486-489` — `extractDerivationGoal` (existing goal analysis)
- `Theories/Bimodal/Automation/Tactics.lean:862-893` — `searchProof` (existing search algorithm)
- `Theories/Bimodal/Automation/Tactics.lean:1019-1042` — `runModalSearch` (existing tactic runner)
- `Theories/Bimodal/Automation/AesopRules.lean:56-280` — existing (deprecated) aesop rule set
- `Theories/Bimodal/Automation/SuccessPatterns.lean:59-68` — `GoalCategory` classification
- `Theories/Bimodal/Automation/ProofSearch.lean:1192-1196` — `SearchStrategy` enum
- Mathlib `Aesop` — rule set patterns, `declare_aesop_rule_sets`
- Mathlib `norm_num` — master dispatch tactic architecture
