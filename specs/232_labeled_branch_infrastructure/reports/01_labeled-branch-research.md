# Research Report: Labeled Branch Infrastructure (Task 232)

**Session**: sess_1748785200_orch232
**Date**: 2026-06-01
**Status**: Complete

## 1. Executive Summary

The current tableau infrastructure in `Metalogic/Decidability/` uses flat (un-indexed) `SignedFormula` and `Branch` types. Each `SignedFormula` is simply `{sign : Sign, formula : Formula}` and a `Branch` is `List SignedFormula`. This design collapses all possible worlds into a single world and all time points into a single time, making the modal and temporal rules unsound (box/diamond rules just strip the operator, G/H rules do the same).

Task 232 requires extending `SignedFormula` to carry `WorldIndex` and `TimeIndex`, updating `Branch` accordingly, migrating the 8 propositional rules to work with the new infrastructure, updating contradiction detection to match within the same world+time, and updating saturation to thread indices. The build must remain sorry-free.

**Key finding**: The change surface is well-contained. The `SignedFormula` and `Branch` types are defined in one file (376 lines) and consumed by 6 downstream files in Decidability (1606 lines total) plus 1 file in Automation (212 lines). The FMP subsystem does not reference these types at all.

## 2. Current Architecture

### 2.1 SignedFormula (SignedFormula.lean, lines 48-163)

```lean
inductive Sign : Type where
  | pos : Sign  -- Asserted true
  | neg : Sign  -- Asserted false

structure SignedFormula : Type where
  sign : Sign
  formula : Formula
```

The type has `DecidableEq`, `BEq`, `Hashable`, `LawfulBEq` instances. Helper functions: `pos`, `neg`, `flip`, `isPos`, `isNeg`, `complexity`. The `beq_eq`, `beq_refl`, `eq_of_beq` theorems are proved for `LawfulBEq`.

### 2.2 Branch (SignedFormula.lean, lines 176-230)

```lean
abbrev Branch := List SignedFormula
```

Branch operations: `empty`, `contains`, `hasPos`, `hasNeg`, `hasBotPos`, `findContradiction`, `hasContradiction`, `positives`, `negatives`, `extend`, `extendMany`, `totalComplexity`.

### 2.3 Subformula Closure (SignedFormula.lean, lines 236-376)

- `Formula.subformulas` -- collects all subformulas recursively
- `subformulaClosure` -- subformula closure for a branch
- `signedSubformulaClosure` -- all signed versions of subformula closure
- `unexpandedComplexity` / `branchUnexpandedComplexity` -- termination measures
- Several theorems: `self_mem_subformulas`, `imp_left_mem_subformulas`, `imp_right_mem_subformulas`, `subformulas_trans`

## 3. The 8 Propositional Rules (Tableau.lean, lines 217-283)

The `applyRule` function pattern-matches on `(rule, sf.sign, sf.formula)` and returns `RuleResult`:

| Rule | Input | Output | Branching? |
|------|-------|--------|------------|
| `andPos` | T(A and B) | T(A), T(B) | No |
| `andNeg` | F(A and B) | F(A) \| F(B) | Yes |
| `orPos` | T(A or B) | T(A) \| T(B) | Yes |
| `orNeg` | F(A or B) | F(A), F(B) | No |
| `impPos` | T(A -> B) | F(A) \| T(B) | Yes |
| `impNeg` | F(A -> B) | T(A), F(B) | No |
| `negPos` | T(not A) | F(A) | No |
| `negNeg` | F(not A) | T(A) | No |

**Critically**: These rules produce output `SignedFormula`s using `SignedFormula.pos` and `SignedFormula.neg` constructors, which currently take only a `Formula`. After indexing, they will need to also accept and propagate the world and time indices from the input formula. Propositional rules must preserve the same world and time indices.

### 3.1 Modal and Temporal Rules (Currently Unsound)

The current modal rules collapse all worlds:
- `boxPos`: T(box A) -> T(A) -- strips box, same branch
- `boxNeg`: F(box A) -> F(A) -- strips box, same branch
- `diamondPos`/`diamondNeg`: Similarly collapse

The current temporal rules collapse all times:
- `allFuturePos`: T(GA) -> T(A) -- strips G, same branch
- `allFutureNeg`: F(GA) -> F(A) -- strips G, same branch
- `allPastPos`/`allPastNeg`: Similarly collapse

These are placeholders that will be replaced by tasks 233 and 234 respectively. Task 232 provides the world/time indexing infrastructure they need.

## 4. Closure Detection (Closure.lean, 375 lines)

### 4.1 ClosureReason Type (lines 50-57)

```lean
inductive ClosureReason : Type where
  | contradiction (φ : Formula)
  | botPos
  | axiomNeg (φ : Formula) (witness : Axiom φ)
```

### 4.2 Closure Checks

- `checkBotPos`: Looks for `T(bot)` in the branch -- uses `b.hasBotPos` which calls `b.contains (SignedFormula.pos .bot)`
- `checkContradiction`: Finds `sf` where `sf.isPos` and `b.hasNeg sf.formula` -- compares by **formula only**, ignoring world/time
- `checkAxiomNeg`: Finds `sf` where `sf.isNeg` and `matchAxiom sf.formula` succeeds

**Impact of indexing**: After adding world+time indices, `checkContradiction` must compare formulas at the **same** world and time. Currently `hasNeg` looks for `SignedFormula.neg phi` matching on formula equality. With indexing, it must also match on world and time indices. Similarly, `checkBotPos` should only fire for `T(bot)` at a specific world+time.

### 4.3 Monotonicity Lemmas (lines 174-316)

Six theorems proving that closure is preserved under branch extension:
- `hasNeg_mono`, `hasPos_mono`, `hasBotPos_mono`
- `checkBotPos_mono`, `checkContradiction_mono`, `checkAxiomNeg_mono`
- `closed_extend_closed`, `add_neg_causes_closure`

These will need re-proving with the new types. The proofs are structural and should translate cleanly -- the core argument (monotonicity under list extension) doesn't change with indexing.

## 5. Saturation (Saturation.lean, 233 lines)

### 5.1 Key Types

- `ExpandedTableau` -- `allClosed` or `hasOpen`
- `BranchListResult` -- `allClosed`, `foundOpen`, or `pending`
- `ExpansionResult` (from Tableau.lean) -- `saturated`, `extended`, or `split`

### 5.2 Expansion Loop

`expandBranchWithFuel` (lines 92-117) is the core expansion loop:
1. Check if branch is closed (via `findClosure`)
2. Try `expandOnce` on the branch
3. On `extended`: recurse with new branch
4. On `split`: fold over sub-branches, check if ALL close

`expandOnce` (Tableau.lean, lines 348-364):
1. `findUnexpanded b` -- finds first un-expanded signed formula
2. `findApplicableRule sf` -- finds first applicable rule
3. Applies rule, returns `extended` or `split`

**Impact of indexing**: `expandOnce` filters the expanded formula out of the branch using `b.filter (· != sf)`. This uses `BEq` on `SignedFormula`, which must now account for world+time indices. The `findUnexpanded` function uses `isExpanded` which checks if any rule applies -- this is sign+formula-level logic that should work the same with indices added.

### 5.3 buildTableau (line 156)

```lean
def buildTableau (φ : Formula) (fuel : Nat := 1000) : Option ExpandedTableau :=
  let initialBranch : Branch := [SignedFormula.neg φ]
  ...
```

**Impact**: The initial branch will need to create `SignedFormula.neg φ` at a designated initial world and time (e.g., world 0, time 0).

## 6. Downstream Consumers

### 6.1 ProofExtraction.lean (221 lines)

Uses `ClosedBranch`, `ClosureReason`, `buildTableau`, `ExpandedTableau`. Does not directly manipulate `SignedFormula` fields or `Branch` contents beyond pattern matching on `ClosureReason`. **Minimal impact** -- just needs to compile with the new types.

### 6.2 CountermodelExtraction.lean (181 lines)

Directly pattern-matches on `sf.sign` and `sf.formula` in `extractTrueAtoms` and `extractFalseAtoms`. The `extractCountermodelSimple` function takes `(φ : Formula) (b : Branch)`. The `branchTruthLemma` is a placeholder (proves `True`).

**Impact**: `extractTrueAtoms`/`extractFalseAtoms` will need to also extract world+time index information. The `SimpleCountermodel` type may need to be extended to carry world/time structure, or the extraction can ignore indices for now (since the countermodel is simplified).

### 6.3 DecisionProcedure.lean (268 lines)

Uses `buildTableau`, `DecisionResult`, `ExpandedTableau`, but does not directly manipulate `SignedFormula` or `Branch` internals. **Minimal impact**.

### 6.4 Correctness.lean (124 lines)

Uses `decide` function and FMP results. Does not reference `SignedFormula` or `Branch` at all. **No impact**.

### 6.5 Automation/EnrichedCountermodel.lean (212 lines)

Directly references `SignedFormula` and `Branch`. Pattern-matches on `sf.formula` in `isModalFormula`/`isTemporalFormula`. The `SignedFormula.toJson` serialization accesses `sf.sign` and `sf.formula`. The `extractEnrichedCountermodel` function takes `(φ : Formula) (branch : Branch)`.

**Impact**: JSON serialization will need to include world+time indices. Modal/temporal classification should work unchanged (only looks at formula structure).

### 6.6 FMP Subsystem (7 files, ~600 lines)

Does NOT reference `SignedFormula` or `Branch` at all. It uses its own types (`ClosureMCSBundle`, `FilteredWorld`, etc.). **No impact**.

## 7. Proposed WorldIndex and TimeIndex Types

### 7.1 Design Options

**Option A: Natural number indices**
```lean
abbrev WorldIndex := Nat
abbrev TimeIndex := Nat
```
Simple, decidable equality for free, supports fresh index generation via `max + 1`.

**Option B: Distinguished initial + generative indices**
```lean
inductive WorldIndex : Type where
  | initial : WorldIndex
  | fresh : Nat -> WorldIndex

inductive TimeIndex : Type where
  | initial : TimeIndex
  | fresh : Nat -> TimeIndex
```
More structured, distinguishes the root world/time from generated witnesses.

**Recommendation**: Option A (Nat indices). Simpler, composes better with the rest of the infrastructure, and the "initial" concept can be represented as `0`. Tasks 233 and 234 will need to track a "next fresh index" counter anyway, so Nat is the natural choice.

### 7.2 New SignedFormula Structure

```lean
structure SignedFormula : Type where
  sign : Sign
  formula : Formula
  world : WorldIndex    -- which possible world
  time : TimeIndex      -- which time point
  deriving Repr, DecidableEq, BEq, Hashable
```

Alternatively, a `Label` structure:
```lean
structure Label : Type where
  world : WorldIndex
  time : TimeIndex
  deriving Repr, DecidableEq, BEq, Hashable

structure SignedFormula : Type where
  sign : Sign
  formula : Formula
  label : Label
  deriving Repr, DecidableEq, BEq, Hashable
```

**Recommendation**: Use the `Label` approach. It groups the indexing information, makes it easy to pass around, and clearly separates "what formula at what sign" from "where in the model". Helper functions like `SignedFormula.pos` and `SignedFormula.neg` can take an optional label parameter defaulting to `Label.initial` (world 0, time 0).

### 7.3 New Branch Type

The `Branch` type should remain `List SignedFormula` (no structural change needed). However, the `Branch` namespace will need new operations:

```lean
-- Find formulas at a specific label
def atLabel (b : Branch) (l : Label) : List SignedFormula
-- Find formulas at a specific world (any time)
def atWorld (b : Branch) (w : WorldIndex) : List SignedFormula
-- Find formulas at a specific time (any world)
def atTime (b : Branch) (t : TimeIndex) : List SignedFormula
-- Get all world indices present
def worlds (b : Branch) : List WorldIndex
-- Get all time indices present
def times (b : Branch) : List TimeIndex
-- Next fresh world/time index
def nextWorld (b : Branch) : WorldIndex
def nextTime (b : Branch) : TimeIndex
```

## 8. Migration Plan for Propositional Rules

The 8 propositional rules preserve the world and time indices of the input formula. The migration is mechanical:

**Current pattern** (e.g., `impNeg`):
```lean
| .impNeg, .neg, .imp ψ χ =>
    .linear [SignedFormula.pos ψ, SignedFormula.neg χ]
```

**New pattern**:
```lean
| .impNeg, .neg, .imp ψ χ =>
    .linear [SignedFormula.pos ψ sf.label, SignedFormula.neg χ sf.label]
```

The `applyRule` function signature changes from `(rule : TableauRule) (sf : SignedFormula) : RuleResult` to the same but with the new `SignedFormula` carrying label information. The `RuleResult` type does not change structurally -- it still holds `List SignedFormula`.

**Key change**: The `RuleResult.linear` and `RuleResult.branching` constructors already hold `List SignedFormula` and `List (List SignedFormula)`, so no structural change is needed. The formulas inside just carry labels now.

## 9. Closure Detection Migration

### 9.1 Contradiction within Same Label

Current:
```lean
def checkContradiction (b : Branch) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isPos ∧ b.hasNeg sf.formula then
      some (.contradiction sf.formula)
    else none
```

Needed:
```lean
def checkContradiction (b : Branch) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isPos ∧ b.hasNegAt sf.formula sf.label then
      some (.contradiction sf.formula sf.label)
    else none
```

Where `hasNegAt` checks for `F(phi)` at the same world and time index.

### 9.2 ClosureReason Update

```lean
inductive ClosureReason : Type where
  | contradiction (φ : Formula) (label : Label)
  | botPos (label : Label)
  | axiomNeg (φ : Formula) (witness : Axiom φ) (label : Label)
```

### 9.3 Monotonicity Lemmas

The 6 monotonicity theorems will need re-proving. The proofs are structural (about list membership under cons) and should translate with only minor changes to account for label matching.

## 10. Saturation Migration

### 10.1 expandOnce

The `expandOnce` function uses `b.filter (· != sf)` to remove the expanded formula. With labels, `BEq` on `SignedFormula` naturally includes label comparison, so this works correctly without modification.

### 10.2 buildTableau

The initial branch changes:
```lean
let initialBranch : Branch := [SignedFormula.neg φ Label.initial]
```

### 10.3 isExpanded / findUnexpanded

These check whether any rule applies to a formula. With labels, the check is still formula-level (propositional structure determines expandability, not the label). No change needed in the logic, just the types.

## 11. Change Surface Summary

| File | Lines | Impact | Change Type |
|------|-------|--------|-------------|
| `SignedFormula.lean` | 376 | **High** | Add `Label`/`WorldIndex`/`TimeIndex` types, update `SignedFormula` structure, update `Branch` helpers, re-prove `LawfulBEq` |
| `Tableau.lean` | 379 | **Medium** | Thread labels through `applyRule`, update `isApplicable`, update `expandOnce` |
| `Closure.lean` | 375 | **Medium** | Update `ClosureReason`, update checks to match on label, re-prove monotonicity lemmas |
| `Saturation.lean` | 233 | **Low** | Update `buildTableau` initial branch, compile-through changes |
| `ProofExtraction.lean` | 221 | **Low** | Compile-through changes (ClosureReason pattern matches) |
| `CountermodelExtraction.lean` | 181 | **Low** | Update extraction to handle labels, optionally extend SimpleCountermodel |
| `DecisionProcedure.lean` | 268 | **Low** | Compile-through changes |
| `Correctness.lean` | 124 | **None** | No SignedFormula/Branch usage |
| `Automation/EnrichedCountermodel.lean` | 212 | **Low** | Update JSON serialization, compile-through |
| **Total** | **2369** | | |

## 12. Risk Assessment

### 12.1 Low Risk
- Propositional rule migration is purely mechanical (add label threading)
- Branch type stays as `List SignedFormula` -- no structural change
- FMP subsystem is completely isolated
- The build currently compiles sorry-free

### 12.2 Medium Risk
- `LawfulBEq` re-derivation: adding fields to `SignedFormula` requires re-proving `beq_eq`, `beq_refl`, `eq_of_beq`. These are straightforward but tedious.
- Monotonicity lemmas in Closure.lean: 6 theorems need re-proving. The structure is similar but label matching adds complexity.
- `DecidableEq` derivation: should be automatic with `deriving` if all component types have `DecidableEq`.

### 12.3 Design Decision: Label in ClosureReason

The `ClosureReason` type currently stores just the formula. After indexing, it should also store the label to provide a complete contradiction witness. This affects `extractFromClosureReason` in ProofExtraction.lean, but that function only pattern-matches on the reason kind and ignores the formula for most cases.

### 12.4 Backward Compatibility

The change is fundamentally breaking at the type level. All downstream files must be updated simultaneously. However, the change is contained within `Metalogic/Decidability/` plus one file in `Automation/`. No other part of the codebase references these types.

## 13. Compilation Dependencies (Import DAG)

```
SignedFormula.lean
  └── Tableau.lean
       └── Closure.lean
            └── Saturation.lean
                 ├── ProofExtraction.lean
                 │    └── DecisionProcedure.lean
                 │         └── Correctness.lean
                 └── CountermodelExtraction.lean
                      └── DecisionProcedure.lean (also imports)

External consumers:
  Automation/EnrichedCountermodel.lean (imports CountermodelExtraction + SignedFormula)
  Automation/DatasetGenerator.lean (imports DecisionProcedure only)
```

The dependency is strictly linear through the core chain, with two branches at Saturation.lean. Changes propagate forward: modifying SignedFormula.lean requires recompilation of everything downstream.

## 14. Recommended Implementation Order

1. **Phase 1**: Define `WorldIndex`, `TimeIndex`, `Label` types in SignedFormula.lean. Update `SignedFormula` structure. Update `Branch` helpers. Re-derive instances.
2. **Phase 2**: Update `Tableau.lean` -- thread labels through `applyRule` and `isApplicable` for propositional rules. Leave modal/temporal rules as identity-collapse (tasks 233/234).
3. **Phase 3**: Update `Closure.lean` -- update `ClosureReason`, `checkContradiction`, `checkBotPos`. Re-prove monotonicity lemmas.
4. **Phase 4**: Update `Saturation.lean` -- initial branch label, compile-through.
5. **Phase 5**: Update downstream files (ProofExtraction, CountermodelExtraction, DecisionProcedure, EnrichedCountermodel) -- mostly compile-through.
6. **Phase 6**: Full `lake build` verification.

Estimated effort: 4-6 hours. The changes are systematic and mechanical, with the main challenge being the monotonicity lemma re-proofs in Closure.lean.
