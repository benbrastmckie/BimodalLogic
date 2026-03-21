# Research Report: Task #623

**Task**: 623 - Build FMP-tableau connection infrastructure
**Started**: 2026-01-19T14:30:00Z
**Completed**: 2026-01-19T15:30:00Z
**Effort**: medium
**Priority**: high
**Dependencies**: Task 490 (parent task)
**Sources/Inputs**: Codebase exploration (Metalogic_v2), lean-lsp local search
**Artifacts**: This research report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The FMP infrastructure is mature with `finite_model_property_constructive` providing explicit bounds (2^closureSize)
- The tableau system has 3 key sorries to address: `tableau_complete`, `decide_complete`, and `expansion_decreases_measure`
- The required lemmas map directly to existing code patterns with clear proof strategies
- The `branchTruthLemma` in CountermodelExtraction.lean is trivial and needs substantive implementation

## Context & Scope

This task builds infrastructure connecting the Finite Model Property (FMP) bounds to tableau semantics. Required lemmas:
1. `open_saturated_implies_satisfiable` - saturated open branch yields finite countermodel
2. `valid_implies_no_open_branch` - contrapositive from FMP
3. `fmpFuel_sufficient_termination` - buildTableau doesn't return none with FMP fuel

## Findings

### 1. FMP Infrastructure (Fully Developed)

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`

Key theorems already proven:
```lean
-- Main FMP theorem (lines 378-482)
theorem finite_model_property_constructive (phi : Formula) (h_sat : formula_satisfiable phi) :
    exists (F : TaskFrame Int) (M : TaskModel F) (tau : WorldHistory F) (t : Int)
      (_h_finite : Finite F.WorldState)
      (_h_fintype : Fintype F.WorldState),
      truth_at M tau t phi /\
      Fintype.card F.WorldState <= 2 ^ (closureSize phi)

-- Cardinality bound (lines 314-354)
theorem semanticWorldState_card_bound (phi : Formula) :
    @Fintype.card (SemanticWorldState phi) (Fintype.ofFinite _) <= 2 ^ closureSize phi
```

**Closure infrastructure** (`Representation/Closure.lean`):
- `closure phi : Finset Formula` - subformula closure
- `closureSize phi : Nat` - closure cardinality
- `closureWithNeg phi : Finset Formula` - closure extended with negations
- `ClosureMaximalConsistent phi S` - closure-restricted MCS
- `mcs_projection_is_closure_mcs` - projection preserves maximality

### 2. Tableau Implementation

**Location**: `Theories/Bimodal/Metalogic_v2/Decidability/`

**Core structures** (SignedFormula.lean):
```lean
-- Fuel calculation (lines 282-304)
def fmpBasedFuel (phi : Formula) : Nat := 2 ^ closureSizeOf phi * 2

def closureSizeOf (phi : Formula) : Nat := Representation.closureSize phi

def recommendedFuel (phi : Formula) : Nat :=
  let closureSize := closureSizeOf phi
  if closureSize <= 20 then fmpBasedFuel phi else conservativeFuel phi
```

**Tableau expansion** (Saturation.lean):
```lean
-- Main tableau builder (lines 165-173)
def buildTableau (phi : Formula) (fuel : Nat := 1000) : Option ExpandedTableau :=
  let initialBranch : Branch := [SignedFormula.neg phi]
  match expandBranchWithFuel initialBranch fuel with
  | none => none  -- Out of fuel
  | some (.inl closedBr) => some (.allClosed [closedBr])
  | some (.inr openBr) =>
      match h : findUnexpanded openBr with
      | none => some (.hasOpen openBr h)
      | some _ => none  -- Should be saturated but isn't
```

**Key sorries identified** (Saturation.lean lines 696-819):
```lean
-- SORRY 1: expansion_decreases_measure (lines 696-819)
theorem expansion_decreases_measure (b : Branch) (h : not isSaturated b) :
    forall b', (expandOnce b = .extended b' \/
           exists bs, expandOnce b = .split bs /\ b' in bs) ->
    expansionMeasure b' < expansionMeasure b := by
  -- Two cases with sorry: linear rule application (line 773), branching rule (line 813)
  sorry
```

### 3. Completeness Infrastructure (Partially Complete)

**Location**: `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean`

**Key sorries to address**:
```lean
-- SORRY 2: tableau_complete (lines 114-135)
theorem tableau_complete (phi : Formula) :
    (valid phi) -> exists (fuel : Nat), (buildTableau phi fuel).isSome /\
             forall t, buildTableau phi fuel = some t -> t.isValid := by
  use fmpBasedFuel phi
  sorry  -- Requires FMP-tableau connection lemmas

-- SORRY 3: decide_complete (lines 163-174)
theorem decide_complete (phi : Formula) (hvalid : valid phi) :
    exists (fuel : Nat), exists proof, decide phi 10 fuel = .valid proof := by
  have h := tableau_complete phi hvalid
  sorry  -- Requires proof extraction from closed tableau
```

### 4. Countermodel Extraction

**Location**: `Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean`

**Current state** (lines 154-159):
```lean
-- Trivial placeholder that needs substantive implementation
theorem branchTruthLemma (b : Branch) (_hSat : findUnexpanded b = none)
    (_hOpen : findClosure b = none) :
    forall sf in b, True := by
  intro _ _
  trivial
```

This should become the key lemma for `open_saturated_implies_satisfiable`.

### 5. Semantic Canonical Model (Mostly Complete)

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean`

Key proven theorems:
```lean
-- World state construction (lines 345-395)
theorem semantic_world_state_has_world_history (phi : Formula) (w : SemanticWorldState phi) :
    exists (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0),
    tau.states 0 ht = w

-- Weak completeness - FULLY PROVEN (lines 619-683)
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w ... phi) ->
    Derivable phi
```

Known sorry (line 523):
```lean
-- Truth bridge - connects finite model truth to general truth_at
theorem semantic_truth_implies_truth_at (phi : Formula) ... := by
  sorry  -- Requires formula induction
```

## Proof Strategies for Required Lemmas

### Lemma 1: open_saturated_implies_satisfiable

**Strategy**: Extend `branchTruthLemma` to construct a finite model from saturated open branch.

**Approach**:
1. Extract atoms true/false from branch (existing: `extractTrueAtoms`, `extractFalseAtoms`)
2. Build `FiniteWorldState` from the valuation
3. Prove by structural induction that if `T(psi) in b` then `models psi`, and if `F(psi) in b` then `not models psi`
4. Since branch is open (no closure), the valuation is consistent
5. Since branch is saturated, the evaluation matches tableau assertions
6. Return the `SemanticWorldState` as the finite countermodel witness

**Key insight**: The branch closure check already handles contradictions (both `T(phi)` and `F(phi)`), negated axioms, and `T(bot)`. An open saturated branch is exactly a consistent truth assignment.

### Lemma 2: valid_implies_no_open_branch

**Strategy**: Contrapositive argument using FMP.

**Approach**:
1. Assume `exists openBranch` in tableau for `F(phi)`
2. By Lemma 1, this open branch yields a finite model where `phi` is false
3. This contradicts validity of `phi`
4. Therefore, valid formulas have no open saturated branches

**Key dependencies**: Lemma 1 (`open_saturated_implies_satisfiable`)

### Lemma 3: fmpFuel_sufficient_termination

**Strategy**: Show termination via decreasing measure bounded by FMP.

**Approach**:
1. `expansion_decreases_measure` (sorry at lines 773, 813) shows each rule application decreases total complexity
2. The total complexity is bounded by `sum of complexities of formulas in closure`
3. The closure has at most `closureSize phi` formulas, each with complexity at most `phi.complexity`
4. Therefore, total steps bounded by `closureSize phi * phi.complexity`
5. `fmpBasedFuel phi = 2^closureSize phi * 2` exceeds this bound
6. Conclude `buildTableau phi (fmpBasedFuel phi) != none`

**Prerequisites**:
- Complete the `expansion_decreases_measure` proof (fill 2 sorries)
- Connect measure decrease to fuel consumption

## Decisions

1. **Approach for branchTruthLemma**: Use structural induction on formula, leveraging saturation to handle each case. The existing `applyRule_decreases_complexity` theorem (lines 363-624) provides the induction pattern.

2. **Handling the truth bridge**: The `semantic_truth_implies_truth_at` sorry can be avoided by using `semantic_weak_completeness` which is fully proven. Route completeness through the semantic model rather than general validity.

3. **Termination measure**: Use `expansionMeasure` (existing definition at line 222) with the `foldl_conditional_mono` lemma (line 337) to complete the arithmetic.

## Recommendations

### Priority 1: Complete expansion_decreases_measure

Fill the two sorries at lines 773 and 813 of Saturation.lean. The proof structure is:
- Extract `sf in b` from `findUnexpanded` returning `some sf`
- Show `sf.formula.complexity > 0` (existing: `unexpanded_contributes` line 642)
- Show result formulas have total complexity < `sf.formula.complexity` (existing: `applyRule_decreases_complexity` line 363)
- Use `foldl_filter_le` (line 312) for the list arithmetic

### Priority 2: Implement substantive branchTruthLemma

Replace the trivial implementation with:
```lean
theorem branchTruthLemma (b : Branch) (hSat : findUnexpanded b = none)
    (hOpen : findClosure b = none) :
    forall sf in b,
      match sf.sign with
      | .pos => (extractedModel b).models sf.formula
      | .neg => not (extractedModel b).models sf.formula
```

Where `extractedModel` builds a `FiniteWorldState` from the branch's atomic assignments.

### Priority 3: Prove tableau_complete using FMP bounds

With the above in place:
1. Use `fmpBasedFuel phi` as the fuel witness
2. Show termination via `expansion_decreases_measure` + fuel bound
3. Case on result: `allClosed` means valid, `hasOpen` contradicts validity (by Lemma 2)

## Risks & Mitigations

### Risk 1: Complexity of branchTruthLemma induction

The proof requires handling all formula constructors (atom, bot, imp, box, all_future, all_past) with appropriate saturation conditions.

**Mitigation**: The existing `applyRule_decreases_complexity` proof (147 lines of case analysis) provides a template. Follow the same structure.

### Risk 2: Fuel bound tightness

The `2^closureSize * 2` bound may be loose, causing performance issues for large formulas.

**Mitigation**: The `recommendedFuel` function already handles this by falling back to `conservativeFuel` for `closureSize > 20`. The theoretical bound is correct for completeness; practical efficiency is a separate concern.

### Risk 3: Truth bridge dependency

Some proofs may implicitly depend on `semantic_truth_implies_truth_at`.

**Mitigation**: Audit the dependency chain. The `semantic_weak_completeness` theorem is fully proven and provides an alternative completeness path that avoids the truth bridge.

## Appendix

### Search Queries Used
- `lean_local_search "satisfiable"` - Found `formula_satisfiable`, `satisfiable_implies_not_refutable`
- `lean_local_search "expansion_decreases"` - Found `expansion_decreases_measure` with location
- `lean_local_search "branchTruth"` - Found trivial placeholder
- `lean_local_search "SemanticWorldState"` - Found finite model construction

### Key File Locations
| File | Purpose |
|------|---------|
| `Representation/FiniteModelProperty.lean` | FMP theorems and bounds |
| `Representation/Closure.lean` | Closure construction |
| `Representation/SemanticCanonicalModel.lean` | Finite model building |
| `Decidability/Saturation.lean` | Tableau expansion |
| `Decidability/Correctness.lean` | Completeness proofs |
| `Decidability/CountermodelExtraction.lean` | Open branch to model |
| `Decidability/BranchClosure.lean` | Branch closure detection |
| `Decidability/SignedFormula.lean` | Fuel calculation |

### Existing Lemmas to Leverage

| Lemma | Location | Use |
|-------|----------|-----|
| `applyRule_decreases_complexity` | Saturation.lean:363 | Complexity decrease per rule |
| `unexpanded_contributes` | Saturation.lean:642 | Unexpanded formulas contribute to measure |
| `foldl_conditional_mono` | Saturation.lean:337 | Monotonicity for measure calculations |
| `foldl_filter_le` | Saturation.lean:312 | Filter preserves bound |
| `semanticWorldState_card_bound` | FiniteModelProperty.lean:314 | FMP cardinality bound |
| `mcs_projection_is_closure_mcs` | Closure.lean:401 | MCS projection |
| `semantic_world_state_has_world_history` | SemanticCanonicalModel.lean:345 | World state reachability |
