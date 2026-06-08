# Research Report: Formula Normalization Before Tableau

**Task**: 287 - Formula normalization pass before tableau expansion
**Session**: sess_1780938205_d0e80f_287
**Date**: 2026-06-08

## Executive Summary

The task asks to add a `normalizeFormula` pass that unfolds derived operators to the 6 primitives before tableau expansion. Research reveals that **no runtime normalization function is needed**: all derived operators are `def` abbreviations that Lean expands definitionally, meaning every formula constructed in Lean code is already in primitive form at the constructor level. The tableau's decomposition helpers (`asAnd?`, `asDiamond?`, `asAllFuture?`, etc.) already work correctly on both `def`-constructed and manually-built primitive formulas -- they are identical at the constructor level. However, a useful contribution remains: wiring an explicit `normalizeFormula : Formula -> Formula` function (a recursive identity on primitives) would serve as (1) documentation/contract enforcement, (2) a guard against future non-`def` operator changes, and (3) a normalization point for formulas arriving from external sources (e.g., parsed input). The `DecisionResult φ` type is parameterized by the original formula, so the proof transport question is trivially solved because normalization is definitional equality.

## Research Question 1: Derived Operator Definitions

### Location
All derived operators are defined in `Theories/Bimodal/Syntax/Formula.lean` within the `Bimodal.Syntax.Formula` namespace (lines 105-501).

### Derived Operators (all `def` abbreviations)
| Operator | Definition | Primitives |
|----------|-----------|------------|
| `top` | `bot.imp bot` | imp, bot |
| `neg φ` | `φ.imp bot` | imp, bot |
| `and φ ψ` | `(φ.imp ψ.neg).neg` = `(φ.imp (ψ.imp bot)).imp bot` | imp, bot |
| `or φ ψ` | `φ.neg.imp ψ` = `(φ.imp bot).imp ψ` | imp, bot |
| `diamond φ` | `φ.neg.box.neg` = `((φ.imp bot).box).imp bot` | imp, box, bot |
| `some_future φ` | `untl φ top` = `untl φ (bot.imp bot)` | untl, imp, bot |
| `some_past φ` | `snce φ top` = `snce φ (bot.imp bot)` | snce, imp, bot |
| `all_future φ` | `(some_future φ.neg).neg` | untl, imp, bot |
| `all_past φ` | `(some_past φ.neg).neg` | snce, imp, bot |
| `next φ` | `untl φ bot` | untl, bot |
| `prev φ` | `snce φ bot` | snce, bot |
| `weak_future φ` | `φ.and φ.all_future` | untl, imp, bot |
| `weak_past φ` | `φ.and φ.all_past` | snce, imp, bot |
| `always φ` | `φ.all_past.and (φ.and φ.all_future)` | untl, snce, imp, bot |
| `sometimes φ` | `φ.neg.always.neg` | untl, snce, imp, bot |
| `release φ ψ` | `(untl φ.neg ψ.neg).neg` | untl, imp, bot |
| `weak_until φ ψ` | `(untl φ ψ).or ψ.all_future` | untl, imp, bot |
| `trigger φ ψ` | `(snce φ.neg ψ.neg).neg` | snce, imp, bot |
| `weak_since φ ψ` | `(snce φ ψ).or ψ.all_past` | snce, imp, bot |
| `strong_release φ ψ` | `untl (and ψ φ) ψ` | untl, imp, bot |
| `strong_trigger φ ψ` | `snce (and ψ φ) ψ` | snce, imp, bot |

**Key insight**: Since all are `def` (not `abbrev` or `opaque`), Lean unfolds them during elaboration. Any formula constructed via these definitions is already stored as a tree of the 6 primitive constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce`).

## Research Question 2: DecisionProcedure.lean Structure

### Location
`Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`

### `decide` function signature (line 121)
```lean
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    (fc : FrameClass := .Base) : DecisionResult φ
```

### Algorithm flow
1. **Fast path**: `tryAxiomProof φ` -- direct axiom pattern match
2. **Compositional proof**: `buildCompositionalProof φ 10` -- recursive proof builder
3. **Proof search**: `bounded_search_with_proof [] φ searchDepth` -- iterative deepening
4. **Tableau fallback**: `buildTableau φ tableauFuel fc` -- full tableau method
   - If all branches close: `extractProof φ tableau fc` -- proof extraction
   - If open branch: `extractCountermodelSimple φ openBranch` -- countermodel

### `expandBranchWithFuel` (Saturation.lean, line 144)
```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (applied : AppliedSet := {})
    : Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet))
```

The branch starts with `[SignedFormula.neg φ Label.initial]` and expands using `expandOnceWithApplied`, which calls `findApplicableRuleWithApplied` to try each tableau rule in priority order.

### Additional entry points
- `decideAuto φ` -- uses `soundFuel` from FMP
- `decideAutoAdaptive φ` -- single-tier fuel=500 strategy
- `decideWithTrace φ` -- trace-instrumented version

## Research Question 3: The 6 Primitive Constructors

Confirmed in `Formula.lean` (line 70):
```lean
inductive Formula : Type where
  | atom : Atom → Formula      -- Propositional atom
  | bot : Formula               -- Bottom (⊥)
  | imp : Formula → Formula → Formula  -- Implication (→)
  | box : Formula → Formula     -- Modal necessity (□)
  | untl : Formula → Formula → Formula -- Until U(φ,ψ)
  | snce : Formula → Formula → Formula -- Since S(φ,ψ)
```

These are the only constructors of the `Formula` inductive type. All other operators are derived via `def`.

## Research Question 4: Existing Normalization Infrastructure

### Normalization.lean (`Theories/Bimodal/Automation/Normalization.lean`)

This module already provides comprehensive bidirectional normalization:

**Unfold direction (Phase 1)**:
- 17 `@[simp]` lemmas (`neg_unfold`, `top_unfold`, `and_unfold`, `or_unfold`, `diamond_unfold`, `some_future_unfold`, `some_past_unfold`, `all_future_unfold`, `all_past_unfold`, `weak_future_unfold`, `weak_past_unfold`, `always_unfold`, `sometimes_unfold`, `next_unfold`, `prev_unfold`, `strong_release_unfold`, `strong_trigger_unfold`)
- All are trivially `rfl` since derived operators expand definitionally
- Tactics: `modal_norm` (full), `prop_norm`, `modal_op_norm`, `temporal_norm`
- Hypothesis variants: `modal_norm_at`, `modal_norm_all`

**Fold direction (Phase 2-3)**:
- `EnrichedFormula`: 21-constructor ADT (6 primitive + 15 enriched)
- `Formula.foldFormula`: greedy bottom-up fold (primitive -> enriched)
- `EnrichedFormula.toPrimitive`: inverse direction (enriched -> primitive)
- `Formula.foldFormulaFull`: full fold with composite recognition
- `modal_fold` tactic

**Serialization (Phase 4)**:
- `EnrichedFormula.toJson`, `prettyPrint`, `toSExpr`
- `Formula.toEnrichedJson`, `toEnrichedPretty`, `toEnrichedSExpr`

### What is MISSING
There is no `normalizeFormula : Formula -> Formula` function that operates programmatically at the term level. The existing infrastructure provides:
1. Tactic-level normalization (simp lemmas / macros) -- for proofs
2. Fold/unfold via `EnrichedFormula` -- for serialization

Neither is wired into the `decide` function.

## Research Question 5: DerivationTree Proof Transport

### The type constraint
`DecisionResult φ` carries `⊢ φ` (i.e., `DerivationTree .Base [] φ`), parameterized by the **exact** formula `φ`. If we normalize `φ` to `φ'` and run the decision procedure on `φ'`, we get `DecisionResult φ'` with `⊢ φ'`, not `⊢ φ`.

### Why this is not a problem
Since all derived operators are `def` abbreviations, normalization produces a formula that is **definitionally equal** to the original. In Lean 4, `Formula.neg p` **is** `Formula.imp p Formula.bot` -- they are the same term. Therefore:
- `normalizeFormula φ = φ` (definitional equality, not just propositional)
- Any `normalizeFormula` function that recursively traverses and rebuilds primitives will return the exact same constructor tree
- `⊢ normalizeFormula(φ)` and `⊢ φ` are the same type
- No proof transport, wrapping, or derived operator lemmas are needed

### Verified experimentally
All decomposition functions (`asAnd?`, `asSomeFuture?`, `asAllFuture?`, `asDiamond?`) produce identical results on both `def`-constructed and manually-built primitive formulas because they are the same constructors.

## Research Question 6: Benchmark Infrastructure (c5/c6)

### C5 Smoke Test
`Tests/BimodalTest/Automation/C5SmokeTest.lean`:
- Tests targeted c5 formulas via `labelFormula`
- Previously-problematic formulas (box(bot) patterns)
- Known valid/invalid formulas
- Edge cases at complexity 5
- Uses `DatasetValidator` conformance suite

### Enumeration Benchmark
`Theories/Bimodal/Automation/EnumBenchmark.lean`:
- Feasibility gates for complexity 5-7
- c5: < 5 seconds, ~1,440 distinct formulas
- c6: < 30 seconds
- c7: < 60 seconds
- Valid fraction, timeout rate, operator diversity, ex_falso dominance metrics

### Benchmark Anchors
`Theories/Bimodal/Automation/BenchmarkAnchors.lean`:
- Generates concrete instances of all 42 BX axiom schemata
- Labels via decision procedure
- Exports as JSONL records

### Formula Enumerator
`Theories/Bimodal/Automation/FormulaEnumerator.lean`:
- `enumExactHelper`: memoized exact-complexity enumeration
- Constructs formulas using both primitive constructors (`imp`, `untl`, `snce`) and derived operators (`some_future`, `all_future`, `release`, `weak_until`, etc.)
- Pattern-aware complexity (task 274): G/H/F/P treated as overhead 1

## Analysis: What Does a Normalization Pass Actually Accomplish?

### Current state: normalization is a no-op
Since all derived operators are `def` abbreviations:
1. Every formula in the codebase is already in primitive form at the constructor level
2. The tableau rules already handle primitives correctly via pattern decomposition helpers
3. `normalizeFormula` would be structurally the identity function

### Where normalization COULD help

**1. Future-proofing**: If any derived operator were changed from `def` to `abbrev` or became non-definitionally-reducible, an explicit normalization pass would catch this.

**2. Subformula closure size**: The `soundFuel` function uses `subformulaClosure(φ).card`. For `always(p)`, the primitive expansion produces ~20 subformulas including all intermediate `imp/bot` nodes. A normalization that simplifies redundant `imp bot bot` (top) patterns or collapses `imp (imp φ bot) bot` (double negation) could reduce the closure size and hence the fuel bound. However, this would be formula simplification (NNF conversion, double-negation elimination), NOT just derived operator unfolding.

**3. Tableau efficiency**: The tableau currently processes complex derived operators by peeling off one connective at a time. For example, `always(p)` starts as a deeply nested `imp` formula that requires multiple `andPos`/`negPos`/`negNeg` steps before reaching the temporal operators. A preprocessing pass that directly pattern-matches derived operator shapes and emits optimized initial branches could save expansion steps.

**4. Contract documentation**: Having an explicit `normalizeFormula` function documents the normalization contract and makes it testable.

### Recommended approach

Given the analysis, the implementation should focus on:

1. **Write `normalizeFormula : Formula -> Formula`** as a recursive function that traverses the formula tree and returns it unchanged (since it is already in primitive form). This serves as a documented identity assertion.

2. **Add NNF-like simplifications** (optional optimization):
   - Eliminate double negation: `imp (imp φ bot) bot` -> `φ` (not valid in general for classical logic in this system, so may need careful handling)
   - This is actually different from the task description and should NOT be done without careful semantic analysis.

3. **Wire into `decide`**: Since `normalizeFormula` is the identity (definitionally), wiring it in has zero runtime cost. Place the call before the fast-path axiom check.

4. **Proof transport**: Not needed -- `normalizeFormula φ = φ` definitionally, so `DecisionResult (normalizeFormula φ)` = `DecisionResult φ`.

5. **Benchmark**: Run c5/c6 tests before and after to verify no regression. Since normalization is the identity, performance should be unchanged (or marginally worse due to traversal overhead if implemented naively).

### Important caveat: the task description may intend something different

The task description says "recursively unfold all derived operators to the 6 primitives." If this is meant for formulas that arrive from an external source (e.g., a DSL parser that constructs `Formula` values using a separate representation that does NOT go through the `def` abbreviations), then a normalization pass would be meaningful. However, in the current codebase, no such external construction path exists -- all formula construction goes through the `def` abbreviations.

The most productive interpretation may be: add `normalizeFormula` as a **pattern-matching normalizer** that recognizes derived operator patterns within a formula and ensures the formula is in a canonical form. This would be useful if the enumerator or mutator creates structurally unusual formulas that happen to match derived operator patterns but were built via raw primitive constructors in non-standard ways.

## Implementation Recommendations

### Phase 1: Write `normalizeFormula`
```lean
/-- Recursively normalize a formula to its primitive form.
    Since all derived operators are `def` abbreviations, this is
    structurally the identity function. -/
def normalizeFormula : Formula -> Formula
  | .atom a => .atom a
  | .bot => .bot
  | .imp φ ψ => .imp (normalizeFormula φ) (normalizeFormula ψ)
  | .box φ => .box (normalizeFormula φ)
  | .untl φ ψ => .untl (normalizeFormula φ) (normalizeFormula ψ)
  | .snce φ ψ => .snce (normalizeFormula φ) (normalizeFormula ψ)
```

### Phase 2: Prove `normalizeFormula_id`
```lean
theorem normalizeFormula_id (φ : Formula) : normalizeFormula φ = φ
```
This is provable by structural induction and `rfl`.

### Phase 3: Wire into `decide`
```lean
def decide (φ : Formula) ... : DecisionResult φ :=
  let φ' := normalizeFormula φ
  -- φ' = φ definitionally, so DecisionResult φ' = DecisionResult φ
  ...
```

### Phase 4: Benchmark
Run the C5SmokeTest and EnumBenchmark to verify no regression.

## Blockers

None. The implementation is straightforward.

## Risk Assessment

- **Risk**: Adding a traversal adds O(n) overhead per formula. For formulas at c5-c6 (complexity 5-6), this is negligible.
- **Risk**: If `normalizeFormula` is not the identity (bug), it would change formula structure and break proofs. Mitigated by the `normalizeFormula_id` theorem.
- **Risk**: The task description may expect something more complex (e.g., NNF conversion or structural simplification). The implementation plan should clarify this with the user if needed.
