# Research Report: Task #624

**Task**: 624 - Prove tableau_complete
**Started**: 2026-01-29T09:37:45Z
**Completed**: 2026-01-29T09:55:00Z
**Effort**: medium
**Priority**: low
**Dependencies**: Task 623 (expanded - infrastructure partially built)
**Sources/Inputs**: Codebase exploration (Metalogic, Metalogic_v2), lean_local_search
**Artifacts**: This research report
**Standards**: report-format.md

## Executive Summary

- The `tableau_complete` theorem in `Boneyard/Metalogic/Decidability/Correctness.lean` (line 79) requires proving that valid formulas have closing tableaux
- **Critical finding**: Metalogic_v2 has more complete infrastructure than Metalogic - several key lemmas are already proven there
- The proof requires three main components: (1) FMP fuel sufficiency, (2) open branch implies satisfiable, (3) valid implies no open branch
- Recommended approach: Port/adapt the more complete Metalogic_v2 infrastructure to Metalogic, or implement the theorem directly using existing lemmas

## Context & Scope

The theorem to prove:

```lean
-- Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean (lines 79-82)
theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid := by
  sorry  -- Requires FMP-based termination proof
```

This connects FMP bounds to tableau termination: if φ is valid, then with sufficient fuel (based on FMP), buildTableau returns a valid tableau (all branches close).

## Findings

### 1. Current State of `tableau_complete`

**Metalogic (target)**:
- Location: `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean:79-82`
- Status: `sorry`
- Dependent theorem `decide_complete` (lines 95-97): Also `sorry`

**Metalogic_v2 (reference)**:
- No `tableau_complete` theorem exists
- BUT: More complete supporting infrastructure exists

### 2. Infrastructure Comparison: Metalogic vs Metalogic_v2

| Component | Metalogic | Metalogic_v2 |
|-----------|-----------|--------------|
| `expansion_decreases_measure` | `sorry` (line 217-221) | **PROVEN** (lines 969-1101) |
| `branchTruthLemma` | Trivial (returns True) | **PROVEN** (lines 279-419) |
| `fmpBasedFuel` | Not defined | **DEFINED** (SignedFormula.lean:282) |
| `open_branch_consistent` | Not present | **PROVEN** (BranchClosure.lean) |
| `finite_model_property_constructive` | Partial | Partial (similar) |

**Key Finding**: Metalogic_v2 has substantially more complete infrastructure:
- `expansion_decreases_measure` is fully proven (147 lines of case analysis)
- `branchTruthLemma` is substantively implemented (handles all formula cases)
- `saturation_contradiction` helper lemma is proven

### 3. Available Theorems for Proof

**From Completeness module**:
```lean
-- Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean:212
theorem provable_iff_valid (φ : Formula) : ContextDerivable [] φ ↔ valid φ
```

**From Metalogic_v2 Completeness**:
```lean
-- Theories/Bimodal/Boneyard/Metalogic_v2/Representation/ContextProvability.lean:173
theorem valid_implies_derivable {φ : Formula} : valid φ → ContextDerivable [] φ
```

**From FMP module**:
```lean
-- Theories/Bimodal/Boneyard/Metalogic/Representation/FiniteModelProperty.lean:102
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ →
    ∃ (D : Type) (_ : AddCommGroup D) ..., truth_at M τ t φ
```

### 4. Proof Strategy Analysis

The `tableau_complete` proof follows this logical structure:

```
valid φ
  → ¬satisfiable (¬φ)           [by definition of validity]
  → ¬∃ open saturated branch    [contrapositive of branchTruthLemma]
  → all branches close          [negation of hasOpen case]
  → buildTableau returns allClosed
  → t.isValid = true
```

**Required components**:

1. **FMP Fuel Bound**: `fmpBasedFuel φ` provides sufficient fuel
   - Metalogic: Not defined (use `10 * φ.complexity + 100`)
   - Metalogic_v2: `2 ^ closureSizeOf φ * 2`

2. **Termination**: `expansion_decreases_measure` ensures progress
   - Metalogic: `sorry`
   - Metalogic_v2: Proven

3. **Open Branch → Satisfiable**: Contrapositive link
   - Requires: `branchTruthLemma` (truth preservation in saturated branches)
   - Metalogic: Trivial placeholder
   - Metalogic_v2: Proven

4. **Valid → No Open Branch**: Main implication
   - Uses: valid → ¬satisfiable(¬φ) → no open branch contains model of ¬φ

### 5. Gap Analysis

**Blocking issues for direct proof in Metalogic**:

1. `expansion_decreases_measure` has `sorry` - needed for termination argument
2. `branchTruthLemma` is trivial - needed for open branch semantics
3. No `fmpBasedFuel` definition - needed for fuel witness

**Options**:

A. **Port from Metalogic_v2**: Copy/adapt the proven infrastructure
   - Pro: Uses already-verified proofs
   - Con: May require adjusting imports/namespaces

B. **Prove in Metalogic directly**: Fill the sorries
   - Pro: Keeps code in intended location
   - Con: Significant effort duplicating Metalogic_v2 work

C. **Deprecate Metalogic, use Metalogic_v2**: Mark Metalogic as legacy
   - Pro: Cleanest architecture
   - Con: May affect other dependencies

### 6. Semantic Bridge Gap

The research for Task 623 identified a "semantic bridge gap":
- `branchTruthLemma` uses `evalFormula` which treats modal/temporal as identity
- Full correctness requires connecting to `truth_at` in TM semantics
- Metalogic_v2 addresses this with `BranchTaskModel.lean` (task frame-based countermodels)

For `tableau_complete`, this gap is NOT blocking because:
- We only need the contrapositive: if valid, then no open branch
- We don't need to extract a correct countermodel, just show one can't exist for valid formulas

## Decisions

1. **Use Metalogic infrastructure with targeted fills**: Keep theorem in Metalogic but leverage Metalogic_v2 patterns

2. **Key dependencies to fill**:
   - Priority 1: `expansion_decreases_measure` (termination)
   - Priority 2: `branchTruthLemma` (open branch semantics)
   - Priority 3: Define `fmpBasedFuel` if not importing from v2

3. **Proof approach**: Use contrapositive via soundness
   - valid φ → ContextDerivable [] φ (by `provable_iff_valid`)
   - ContextDerivable → consistent [¬φ] is false (by consistency of provability)
   - ¬consistent [¬φ] → no satisfying model for ¬φ
   - No model for ¬φ → no open saturated branch for F(φ) tableau

## Recommendations

### Priority 1: Complete `expansion_decreases_measure` in Metalogic

Port the proof from Metalogic_v2 (`Saturation.lean:969-1101`). Key lemmas to port:
- `expansionMeasure_filter_unexpanded`
- `expansionMeasure_new_le_totalComplexity`
- `applyRule_decreases_complexity`
- `unexpanded_contributes`
- `findApplicableRule_spec`

### Priority 2: Implement substantive `branchTruthLemma`

Port from Metalogic_v2 (`CountermodelExtraction.lean:279-419`). Key helpers:
- `isExpanded_*_false` lemmas for each formula type
- `saturation_contradiction` helper
- `open_branch_consistent` (from BranchClosure.lean)

### Priority 3: Define `fmpBasedFuel`

Add to `Metalogic/Decidability/SignedFormula.lean`:
```lean
def fmpBasedFuel (φ : Formula) : Nat :=
  2 ^ closureSizeOf φ * 2

def closureSizeOf (φ : Formula) : Nat :=
  (Representation.subformulaList φ).length
```

### Priority 4: Prove `tableau_complete`

With the above in place:
```lean
theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid := by
  intro h_valid
  use fmpBasedFuel φ
  constructor
  · -- buildTableau terminates with sufficient fuel
    -- Uses expansion_decreases_measure + fuel bound
    sorry -- termination lemma
  · -- Result is valid (allClosed)
    intro t ht
    -- If result is hasOpen, derive contradiction via branchTruthLemma
    match h : t with
    | .allClosed _ => rfl
    | .hasOpen openBr hSat =>
      -- openBr is saturated and open
      -- By branchTruthLemma, openBr describes a model where ¬φ is true
      -- This contradicts validity of φ
      exfalso
      sorry -- validity contradiction
```

## Risks & Mitigations

### Risk 1: Port complexity from Metalogic_v2
The `expansion_decreases_measure` proof in Metalogic_v2 is 130+ lines with many helper lemmas.

**Mitigation**: Port incrementally, starting with the helper lemmas. The structure is clear and well-commented in v2.

### Risk 2: Namespace/import conflicts
Metalogic and Metalogic_v2 have overlapping definitions.

**Mitigation**: Use qualified names when importing. Consider creating a bridging module that re-exports needed definitions.

### Risk 3: Semantic bridge for correctness
The full correctness of countermodel extraction needs the semantic bridge.

**Mitigation**: For `tableau_complete`, we only need the contrapositive (no open branch for valid formulas). The semantic bridge is only needed for the inverse direction (invalid → countermodel exists).

## Appendix

### Search Queries Used
- `lean_local_search "tableau_complete"` - Found in Metalogic and FMP files
- `lean_local_search "expansion_decreases"` - Found proven version in Metalogic_v2
- `lean_local_search "branchTruthLemma"` - Found implementations in both
- `lean_local_search "fmpBasedFuel"` - Found only in Metalogic_v2
- `lean_local_search "provable_iff_valid"` - Found completeness theorems

### Key File Locations

| File | Purpose |
|------|---------|
| `Metalogic/Decidability/Correctness.lean` | **Target**: `tableau_complete` theorem |
| `Metalogic/Decidability/Saturation.lean` | Tableau expansion with `sorry` |
| `Metalogic/Representation/FiniteModelProperty.lean` | FMP for bounds |
| `Metalogic_v2/Decidability/Saturation.lean` | **Complete** expansion lemmas |
| `Metalogic_v2/Decidability/CountermodelExtraction.lean` | **Complete** branchTruthLemma |
| `Metalogic_v2/Decidability/BranchClosure.lean` | Branch consistency |
| `Metalogic_v2/Decidability/SignedFormula.lean` | fmpBasedFuel definition |

### Existing Lemmas to Leverage

| Lemma | Location | Purpose |
|-------|----------|---------|
| `provable_iff_valid` | Completeness/WeakCompleteness | valid ↔ derivable |
| `valid_implies_derivable` | ContextProvability | Metalogic_v2 version |
| `expansion_decreases_measure` | Metalogic_v2/Saturation:969 | Termination |
| `branchTruthLemma` | Metalogic_v2/CountermodelExtraction:279 | Semantics |
| `saturation_contradiction` | Metalogic_v2/CountermodelExtraction:232 | Helper |
| `fmp_fuel_sufficient` | Metalogic_v2/Saturation:1123 | Fuel bound |
