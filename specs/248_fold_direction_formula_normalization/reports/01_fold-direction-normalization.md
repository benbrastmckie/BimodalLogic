# Research Report: Fold Direction Formula Normalization

**Task**: 248 -- fold_direction_formula_normalization
**Date**: 2026-06-02
**Status**: Research complete

## Executive Summary

The fold direction for formula normalization is **already fully implemented** in `Theories/Bimodal/Automation/Normalization.lean`. Task 190 (modal_norm) was scoped for the unfold direction only, but the implementation delivered all four phases: (1) unfold simp lemmas and tactics, (2) `EnrichedFormula` ADT with greedy fold algorithm, (3) fold-direction simp lemmas with round-trip tests, and (4) JSON/pretty-print/S-expression serialization. The remaining work for task 248 is strictly about **integration**: wiring the existing fold/serialization functions into the export pipeline (DatasetExport, ProofStepExport) and adding a `formula_folded_json` field to exported records.

## 1. Formula Type and Primitive vs Derived Operators

### 1.1 Primitive Constructors (6)

The `Formula` inductive type has exactly 6 constructors:

| Constructor | Syntax | Description |
|-------------|--------|-------------|
| `atom` | `Atom -> Formula` | Propositional variable |
| `bot` | `Formula` | Bottom / falsum |
| `imp` | `Formula -> Formula -> Formula` | Implication |
| `box` | `Formula -> Formula` | Modal necessity |
| `untl` | `Formula -> Formula -> Formula` | Until (temporal, Burgess convention) |
| `snce` | `Formula -> Formula -> Formula` | Since (temporal, Burgess convention) |

### 1.2 Derived Operators (15)

All derived operators are `def` abbreviations (definitional equality), organized by dependency level:

| Level | Operator | Definition (Lean) | Primitive Expansion |
|-------|----------|-------------------|---------------------|
| 1 | `neg phi` | `phi.imp bot` | `imp phi bot` |
| 1 | `top` | `bot.imp bot` | `imp bot bot` |
| 1 | `next phi` | `untl phi bot` | `untl phi bot` |
| 1 | `prev phi` | `snce phi bot` | `snce phi bot` |
| 2 | `and phi psi` | `(phi.imp psi.neg).neg` | `imp (imp phi (imp psi bot)) bot` |
| 2 | `or phi psi` | `phi.neg.imp psi` | `imp (imp phi bot) psi` |
| 2 | `diamond phi` | `phi.neg.box.neg` | `imp (box (imp phi bot)) bot` |
| 2 | `some_future phi` | `untl phi top` | `untl phi (imp bot bot)` |
| 2 | `some_past phi` | `snce phi top` | `snce phi (imp bot bot)` |
| 3 | `all_future phi` | `(some_future phi.neg).neg` | `imp (untl (imp phi bot) (imp bot bot)) bot` |
| 3 | `all_past phi` | `(some_past phi.neg).neg` | `imp (snce (imp phi bot) (imp bot bot)) bot` |
| 4 | `weak_future phi` | `phi.and phi.all_future` | (compound) |
| 4 | `weak_past phi` | `phi.and phi.all_past` | (compound) |
| 5 | `always phi` | `phi.all_past.and (phi.and phi.all_future)` | (compound) |
| 6 | `sometimes phi` | `phi.neg.always.neg` | (compound) |

## 2. Existing Normalization Code Analysis

### 2.1 Location

All normalization code lives in a single file: `Theories/Bimodal/Automation/Normalization.lean` (1031 lines).

### 2.2 Phase 1: Unfold Direction (Lines 58-247)

- 15 `@[simp]` unfold lemmas (all `rfl` -- definitional equality)
- 5 normalization tactics: `modal_norm`, `prop_norm`, `modal_op_norm`, `temporal_norm`, `modal_norm_all`
- Hypothesis-targeting variant: `modal_norm_at`

### 2.3 Phase 2: Fold Algorithm (Lines 249-658)

- `EnrichedFormula`: Inductive type with 21 constructors (6 primitive + 15 enriched)
- `EnrichedFormula.toPrimitive`: Converts enriched back to primitive `Formula`
- `Formula.foldFormula`: Bottom-up greedy pattern matching, single-pass
- `Formula.foldFormula.foldImp`: Helper that recognizes derived ops at `imp` nodes
- `EnrichedFormula.recognizeComposites`: Post-processing pass for `always`, `sometimes`, `or_`
- `Formula.foldFormulaFull`: Composition of `foldFormula` then `recognizeComposites`

### 2.4 Phase 3: Fold Simp Lemmas and Round-Trip (Lines 660-820)

- 10 fold-direction `@[simp]` lemmas (all `rfl`): `neg_fold`, `top_fold`, `and_fold`, `diamond_fold`, `some_future_fold`, `some_past_fold`, `next_fold`, `prev_fold`, `all_future_fold`, `all_past_fold`
- `modal_fold` tactic macro
- Round-trip tests via `modal_norm` and `modal_fold`
- `#eval` round-trip test covering 21 formulas: **ALL PASS**

### 2.5 Phase 4: Serialization (Lines 822-1031)

- `EnrichedFormula.toJson`: JSON with enriched operator tags
- `EnrichedFormula.prettyPrint`: Human-readable notation
- `EnrichedFormula.toSExpr`: S-expression with enriched tags
- Convenience functions: `Formula.toEnrichedJson`, `Formula.toEnrichedPretty`, `Formula.toEnrichedSExpr`

### 2.6 Build Status

Module builds cleanly with `lake build Bimodal.Automation.Normalization` (657 jobs, no errors). All 21 round-trip tests pass.

## 3. Ambiguity Analysis

### 3.1 The Core Ambiguity: `imp(neg(A), B)`

The pattern `imp(imp(A, bot), B)` at the primitive level matches two interpretations:

1. **`or(A, B)`**: Disjunction is defined as `neg(A).imp B`
2. **`imp(neg(A), B)`**: Plain implication with a negated antecedent

These are definitionally identical in the logic -- `or(A, B)` *is* `imp(neg(A), B)`. The ambiguity is purely at the "intended meaning" level for training data.

### 3.2 Resolution Strategy (Already Implemented)

The fold algorithm uses a **two-pass conservative strategy**:

**Pass 1 (`foldFormula`)**: Does NOT fold `imp(neg(A), B)` to `or_`. This avoids interference with `and_` recognition, which requires seeing `neg(imp(A, neg(B)))` = `and_(A, B)`.

**Pass 2 (`recognizeComposites`)**: After all `and_`, `all_future`, `all_past`, `diamond`, `weak_future`, `weak_past` patterns are locked in, `or_` is recognized from `imp(neg(A), B)`.

This means every `imp(neg(A), B)` that is not part of a higher-level pattern (like `and_` or `always`) gets folded to `or_`.

### 3.3 Complete Pattern Ambiguity Table

| Primitive Pattern | Candidate Match(es) | Resolution |
|-------------------|---------------------|------------|
| `imp A bot` | `neg A` | Unambiguous -- always fold |
| `imp bot bot` | `top` (= `neg bot`) | Unambiguous -- fold to `top` (special case) |
| `imp (imp A (imp B bot)) bot` | `and_ A B` | Unambiguous after neg folding |
| `imp (box (neg A)) bot` | `diamond A` | Unambiguous after neg folding |
| `untl A (imp bot bot)` | `some_future A` | Unambiguous -- guard is `top` |
| `snce A (imp bot bot)` | `some_past A` | Unambiguous -- guard is `top` |
| `untl A bot` | `next A` | Unambiguous -- guard is `bot` |
| `snce A bot` | `prev A` | Unambiguous -- guard is `bot` |
| `imp (some_future (neg A)) bot` | `all_future A` | Unambiguous after neg+some_future folding |
| `imp (some_past (neg A)) bot` | `all_past A` | Unambiguous after neg+some_past folding |
| `imp (neg A) B` | `or_(A, B)` OR `imp(neg(A), B)` | **AMBIGUOUS** -- deferred to pass 2 |
| `and_(all_past A) (and_ A (all_future A))` | `always A` | Unambiguous -- recognized in pass 2 |
| `neg(always(neg A))` | `sometimes A` | Unambiguous -- recognized in pass 2 |
| `and_(A, all_future(A))` | `weak_future A` | Unambiguous -- `BEq` check on `A` |
| `and_(A, all_past(A))` | `weak_past A` | Unambiguous -- `BEq` check on `A` |

### 3.4 Deliberately Omitted Fold Simp Lemmas

These fold lemmas are excluded from the `modal_fold` tactic due to ambiguity or complexity:

- **`or_fold`**: Ambiguous (see above)
- **`always_fold`**: Multi-level pattern too complex for single simp lemma
- **`sometimes_fold`**: Requires composing always expansion + negation
- **`weak_future_fold`, `weak_past_fold`**: Overlap with `and_fold` when second arg is `all_future`/`all_past`

Users can apply these manually via `rw [<- weak_future_unfold]` etc.

## 4. Dependency Level Ordering for Greedy Folding

The fold algorithm operates bottom-up, which naturally respects the dependency hierarchy:

```
Pass 1 (foldFormula -- bottom-up):
  Level 1: neg, top, next, prev (recognized at leaf/simple patterns)
  Level 2: and_, diamond, some_future, some_past (recognized after Level 1 folding)
  Level 3: all_future, all_past (recognized after Level 2 folding)
  Level 4: weak_future, weak_past (recognized after Level 3 folding)

Pass 2 (recognizeComposites -- bottom-up):
  Level 2: or_ (deferred from Pass 1 to avoid and_ interference)
  Level 5: always (recognized from and_(all_past, and_(phi, all_future)))
  Level 6: sometimes (recognized from neg(always(neg phi)))
```

The two-pass design is necessary because `or_` recognition in Pass 1 would consume `imp(neg(A), B)` patterns before `and_` recognition could see the full `neg(imp(A, neg(B)))` pattern.

## 5. Integration with Export Pipeline

### 5.1 Current Export Architecture

The export pipeline has two main outputs:

**Dataset export** (`DatasetExport.lean`):
- `DatasetRecord` structure with fields: `formula_str`, `formula_ast`, `formula_sexpr`, `formula_tokens`
- `formula_ast` uses `Formula.toJson` (primitive-only: 6 tags)
- `formula_str` uses `Formula.prettyPrint` (primitive-only)

**Proof step export** (`ProofStepExport.lean` via `ProofStepExtractor.lean`):
- `ProofStep.toJson` serializes `goal` via `Formula.toJson` (primitive-only)
- Context formulas also use `Formula.toJson`

### 5.2 Integration Points (Work Remaining)

The integration requires adding enriched representation fields alongside existing primitive fields:

**DatasetRecord changes**:
1. Add `formula_folded_json : String` field -- output of `Formula.toEnrichedJson`
2. Add `formula_folded_str : String` field -- output of `Formula.toEnrichedPretty`
3. Add `formula_folded_sexpr : String` field -- output of `Formula.toEnrichedSExpr`
4. Import `Bimodal.Automation.Normalization` in `DatasetExport.lean`
5. Populate new fields in `labeledToRecord` using the existing convenience functions

**ProofStep changes**:
1. Add `goal_folded_json : String` field to `ProofStep` in `ProofStepExtractor.lean`
2. Populate via `step.goal.toEnrichedJson`
3. Add context folded representation (optional, lower priority)

**Metadata changes**:
1. Add `formula_folded_json` etc. to the `representations` array in `datasetMetadataToJson`

### 5.3 No New Lean Functions Needed

All required fold and serialization functions already exist:
- `Formula.foldFormulaFull` -- greedy fold with composite recognition
- `Formula.toEnrichedJson` -- JSON with enriched tags
- `Formula.toEnrichedPretty` -- human-readable enriched notation
- `Formula.toEnrichedSExpr` -- S-expression with enriched tags

## 6. Implementation Approach Assessment

### 6.1 Meta-Level vs Regular Function

The task description asked about meta-level vs regular function. The **already-implemented approach uses regular (computable) functions**, which is the correct choice:

- `Formula.foldFormula` is a regular function `Formula -> EnrichedFormula`
- `EnrichedFormula.toPrimitive` is a regular function `EnrichedFormula -> Formula`
- Both are computable and can be used in `#eval`, `IO` pipelines, and at runtime
- The fold simp lemmas (`neg_fold` etc.) work at the tactic/proof level
- The `modal_fold` macro provides tactic-level access

A meta-level approach (operating in `MetaM`) would have been:
- More complex to implement
- Useful only in tactic mode, not for runtime export
- Unnecessary since all operators are `def` abbreviations (not opaque)

The regular function approach is superior for the export pipeline use case.

### 6.2 Round-Trip Property

The property `toPrimitive(foldFormulaFull(f)) = f` holds for all formulas because:
- `foldFormula` only recognizes patterns that match definitional equalities
- `toPrimitive` expands each enriched constructor to its definition
- The `#eval` test verifies this for 21 representative formulas

A formal proof of this property could be added but would require induction over the formula structure with case analysis on each pattern. The current `#eval` tests provide strong empirical evidence.

### 6.3 Formal Round-Trip Theorem (Optional Enhancement)

A formal `theorem foldFormulaFull_roundTrip (f : Formula) : (f.foldFormulaFull).toPrimitive = f` would require:
- Induction on `Formula`
- Case splits on `imp` patterns (matching `foldImp` logic)
- Careful handling of `BEq` comparisons in `weak_future`/`weak_past` recognition
- Handling of the two-pass architecture

This is feasible but non-trivial (estimated 100-200 lines). The `#eval` tests plus the fact that all patterns are definitional equalities provide adequate assurance for the export pipeline.

## 7. Task Status Assessment

### 7.1 What Is Already Done

1. **EnrichedFormula ADT**: 21-constructor type with full Repr, BEq, Inhabited
2. **Greedy fold algorithm**: Two-pass bottom-up with conservative ambiguity resolution
3. **toPrimitive inverse**: Enriched -> Primitive conversion
4. **Fold simp lemmas**: 10 unambiguous fold lemmas + `modal_fold` tactic
5. **Serialization**: JSON, pretty-print, S-expression for enriched formulas
6. **Round-trip tests**: 21 formulas tested, ALL PASS
7. **Ambiguity documentation**: Inline in Normalization.lean

### 7.2 What Remains

The remaining work is **pipeline integration** (connecting existing functions to export):

1. Add `import Bimodal.Automation.Normalization` to `DatasetExport.lean` and `ProofStepExtractor.lean`
2. Add `formula_folded_json`, `formula_folded_str`, `formula_folded_sexpr` fields to `DatasetRecord`
3. Populate fields in `labeledToRecord` using `Formula.toEnrichedJson` etc.
4. Add `goal_folded_json` field to `ProofStep`
5. Update metadata representations array
6. Update JSONL serialization functions
7. Run `lake build` to verify no regressions
8. Optionally: add formal `foldFormulaFull_roundTrip` theorem

### 7.3 Estimated Effort

The integration work is mechanical: adding fields, imports, and populating them with existing function calls. Estimated at 1-2 implementation phases, primarily editing `DatasetExport.lean`, `ProofStepExtractor.lean`, and `DatasetExporter.lean`.

## 8. Blockers

None. All prerequisite code exists and builds successfully.

## 9. Recommendations

1. **Do not reimplement** the fold algorithm -- it already works correctly
2. **Focus implementation on pipeline integration** (adding fields to records, populating with existing functions)
3. **Consider adding a formal round-trip theorem** as an optional enhancement
4. **Maintain the two-pass architecture** -- it correctly handles the `or_`/`and_` ambiguity
5. **Add the enriched fields alongside primitives** (not replacing them) for backward compatibility
