# Implementation Plan: Port Decidability to Metalogic_v2

- **Task**: 607 - Port Decidability to Metalogic_v2
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Priority**: High
- **Dependencies**: Task 470
- **Research Inputs**: specs/607_port_decidability_to_metalogic_v2/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Port the 8-file Decidability infrastructure (61KB) from `Theories/Bimodal/Metalogic/Decidability/` to `Metalogic_v2/Decidability/`. The key integration point is using Metalogic_v2's constructive FMP (`finite_model_property_constructive`) for termination bounds and completeness proofs, rather than the sorry'd versions in the old module. The architecture follows a representation-first approach where FMP provides explicit cardinality bounds that determine tableau expansion fuel.

### Research Integration

Key findings from research-001.md:
- Old module has 8 well-structured files with clear dependencies
- Metalogic_v2 has `Representation/Closure.lean` with Finset-based closure (preferred over old List-based)
- Metalogic_v2's `finite_model_property_constructive` provides `2^closureSize` bounds
- Rename `Closure.lean` to `BranchClosure.lean` to avoid naming conflict
- Old `tableau_complete` and `decide_complete` have sorries that can now be completed using FMP

## Goals & Non-Goals

**Goals**:
- Create `Metalogic_v2/Decidability/` subdirectory with 8 ported files
- Integrate with Metalogic_v2's closure infrastructure (Finset-based)
- Use FMP bounds for fuel calculation (`2^closureSize`)
- Complete sorry'd theorems using constructive FMP
- Create hub module `Metalogic_v2/Decidability.lean`
- Maintain backward compatibility with existing API where sensible

**Non-Goals**:
- Enhancing countermodel extraction to full semantic models (keep simple version)
- Modifying the tableau expansion rules (logic-specific, unchanged)
- Removing the old Decidability module (will coexist for comparison)
- Adding new decision procedures beyond what exists

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure naming confusion | Medium | High | Rename to BranchClosure.lean; clear documentation |
| FMP fuel bounds too loose | Medium | Medium | Start with 2x multiplier, tune based on testing |
| Import cycles FMP<->Decidability | High | Medium | Ensure one-directional: Decidability imports FMP |
| ProofExtraction incomplete | Low | Low | Keep both axiom-based and search-based extraction |
| Type signature mismatches | Medium | Medium | Careful review of Finset vs List adaptations |
| Large refactor scope | Medium | Low | Phase incrementally; each file separate commit |

## Implementation Phases

### Phase 1: Core Types Foundation [COMPLETED]

**Goal**: Port SignedFormula.lean with Metalogic_v2 closure integration

**Tasks**:
- [ ] Create `Metalogic_v2/Decidability/` directory
- [ ] Port `Sign` and `SignedFormula` types (unchanged)
- [ ] Port `Branch` type (List of SignedFormula)
- [ ] Update `subformulaClosure` to use `Representation.Closure.closure` (Finset)
- [ ] Port complexity measures for termination (`unexpandedComplexity`, `branchUnexpandedComplexity`)
- [ ] Remove duplicate `Formula.subformulas` (use `Bimodal.Syntax.Subformulas` instead)
- [ ] Verify compilation with `lake build`

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/SignedFormula.lean` (create)

**Timing**: 1.5 hours

**Verification**:
- File compiles without errors
- Imports `Representation.Closure` successfully
- Types are equivalent to old module

---

### Phase 2: Tableau Expansion Rules [COMPLETED]

**Goal**: Port Tableau.lean with minimal changes (rules are logic-specific)

**Tasks**:
- [ ] Port `TableauRule` enumeration (14 rules)
- [ ] Port formula decomposition helpers (`asNeg?`, `asAnd?`, `asOr?`, etc.)
- [ ] Port `applyRule` rule application logic
- [ ] Port `expandOnce` single expansion step
- [ ] Port `ExpansionResult` type (saturated/extended/split)
- [ ] Update imports to use new SignedFormula

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Tableau.lean` (create)

**Timing**: 1 hour

**Verification**:
- All 14 tableau rules preserved
- Expansion logic unchanged
- Compiles with new SignedFormula import

---

### Phase 3: Branch Closure Detection [COMPLETED]

**Goal**: Port Closure.lean as BranchClosure.lean to avoid naming conflict

**Tasks**:
- [ ] Create `BranchClosure.lean` (renamed from Closure.lean)
- [ ] Port `ClosureReason` witness type (contradiction, botPos, axiomNeg)
- [ ] Port `findClosure` main detection function
- [ ] Port `ClosedBranch` / `OpenBranch` typed classifications
- [ ] Update imports to use `Bimodal.Automation.ProofSearch` for `matchAxiom`
- [ ] Add namespace/module documentation noting rename reason

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/BranchClosure.lean` (create)

**Timing**: 1 hour

**Verification**:
- Closure detection logic preserved
- Integrates with ProofSearch.matchAxiom
- No naming conflicts with Representation/Closure.lean

---

### Phase 4: Saturation Engine with FMP Integration [IN PROGRESS]

**Goal**: Port Saturation.lean with FMP-based fuel calculation

**Tasks**:
- [ ] Port `ExpandedTableau` result type (allClosed/hasOpen)
- [ ] Port `expandBranchWithFuel` fuel-based expansion
- [ ] Port `buildTableau` main construction
- [ ] **Key change**: Update `recommendedFuel` to use FMP bounds:
  ```lean
  def fmpBasedFuel (phi : Formula) : Nat :=
    2 ^ Representation.closureSize phi * 2  -- Factor of 2 for signed formulas
  ```
- [ ] Import `Representation.FiniteModelProperty` for `closureSize`
- [ ] Add documentation explaining FMP integration

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` (create)

**Timing**: 1.5 hours

**Verification**:
- Fuel calculation uses `closureSize` from Metalogic_v2
- Expansion terminates within FMP bounds
- Compiles with FMP import

---

### Phase 5: Proof Extraction [NOT STARTED]

**Goal**: Port ProofExtraction.lean maintaining axiom-based strategy

**Tasks**:
- [ ] Port `extractFromClosureReason` proof fragment extraction
- [ ] Port `tryAxiomProof` direct axiom proof via matchAxiom
- [ ] Port `extractProof` main extraction logic
- [ ] Port `findProofCombined` tableau + proof search combination
- [ ] Update imports to use new Saturation module

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/ProofExtraction.lean` (create)

**Timing**: 1 hour

**Verification**:
- Proof extraction logic preserved
- Integrates with Saturation module
- Axiom matching functional

---

### Phase 6: Countermodel Extraction [NOT STARTED]

**Goal**: Port CountermodelExtraction.lean (simple version)

**Tasks**:
- [ ] Port `SimpleCountermodel` lightweight type
- [ ] Port `extractTrueAtoms` / `extractFalseAtoms` valuation extraction
- [ ] Port `findCountermodel` main extraction function
- [ ] Document potential future enhancement with SemanticCanonicalModel

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` (create)

**Timing**: 0.5 hours

**Verification**:
- Countermodel extraction functional
- Simple valuation-based approach preserved

---

### Phase 7: Decision Procedure Interface [NOT STARTED]

**Goal**: Port DecisionProcedure.lean with FMP integration

**Tasks**:
- [ ] Port `DecisionResult` sum type (valid/invalid/timeout)
- [ ] Port `decide` main function with three-phase algorithm:
  1. Fast path: direct axiom proof
  2. Medium path: bounded proof search
  3. Slow path: full tableau construction
- [ ] Port `decideAuto` / `decideOptimized` convenience wrappers
- [ ] Port `isTautology` / `isContradiction` / `isContingent` classifiers
- [ ] Update to use FMP-based fuel from Saturation

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/DecisionProcedure.lean` (create)

**Timing**: 1 hour

**Verification**:
- Decision interface functional
- Three-phase algorithm preserved
- Uses FMP-based fuel

---

### Phase 8: Correctness Proofs with FMP [NOT STARTED]

**Goal**: Port Correctness.lean and complete sorry'd theorems using constructive FMP

**Tasks**:
- [ ] Port `decide_sound` soundness theorem
- [ ] **Complete `tableau_complete`** using `finite_model_property_constructive`:
  - Use `semanticWorldState_card_bound` for termination bound
  - Connect FMP witness to tableau saturation
- [ ] **Complete `decide_complete`** using completed tableau_complete
- [ ] Port `validity_decidable` (may simplify using v2's version)
- [ ] Add documentation explaining FMP connection

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` (create)

**Timing**: 2 hours

**Verification**:
- `sorry` count reduced (ideally to zero)
- Theorems connect to FMP infrastructure
- Soundness and completeness established

---

### Phase 9: Hub Module and Integration [NOT STARTED]

**Goal**: Create hub module and verify full integration

**Tasks**:
- [ ] Create `Metalogic_v2/Decidability.lean` hub module
- [ ] Re-export key types: `SignedFormula`, `Branch`, `DecisionResult`
- [ ] Re-export key functions: `decide`, `buildTableau`, `findProof`
- [ ] Re-export key theorems: `decide_sound`, `decide_complete`, `validity_decidable`
- [ ] Update FMP.lean docstrings to mention Decidability integration
- [ ] Verify import graph is acyclic (Decidability -> FMP, not reverse)
- [ ] Run full `lake build` to verify no errors

**Files to modify**:
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability.lean` (create)
- `Logos/Theories/Bimodal/Metalogic_v2/FMP.lean` (update docstrings)

**Timing**: 0.5 hours

**Verification**:
- Hub module compiles
- All exports accessible
- No import cycles
- Full project builds

## Testing & Validation

- [ ] All 9 new files compile without errors
- [ ] `lake build` succeeds for full project
- [ ] No import cycles between Decidability and FMP
- [ ] `decide` function works on test formulas from old test suite
- [ ] Soundness theorem (`decide_sound`) has no sorries
- [ ] Completeness theorem (`decide_complete`) uses FMP constructively
- [ ] Performance: FMP-based fuel bounds are tight enough for practical use

## Artifacts & Outputs

- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/SignedFormula.lean`
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Tableau.lean`
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/BranchClosure.lean`
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/ProofExtraction.lean`
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean`
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/DecisionProcedure.lean`
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean`
- `Logos/Theories/Bimodal/Metalogic_v2/Decidability.lean` (hub)
- `specs/607_port_decidability_to_metalogic_v2/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation encounters blocking issues:
1. **Import cycles**: Restructure to ensure Decidability only imports from FMP direction
2. **FMP bounds inadequate**: Fall back to old heuristic fuel with TODO for optimization
3. **Proof incompleteness**: Keep sorries with clear documentation of what FMP theorem is needed
4. **Type mismatches**: Create adapter functions between old/new closure types

The old `Metalogic/Decidability/` module remains unchanged, allowing comparison and fallback during validation.
