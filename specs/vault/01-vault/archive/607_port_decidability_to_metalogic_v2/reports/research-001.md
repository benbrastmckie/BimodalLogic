# Research Report: Task #607

**Task**: 607 - Port Decidability to Metalogic_v2
**Started**: 2026-01-19T12:00:00Z
**Completed**: 2026-01-19T12:30:00Z
**Effort**: Medium
**Priority**: High
**Dependencies**: Task 470
**Sources/Inputs**: Decidability/ (8 files), Metalogic_v2/ architecture, FMP infrastructure
**Artifacts**: specs/607_port_decidability_to_metalogic_v2/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The old Decidability/ module has 8 well-structured files implementing tableau-based decision procedures for TM bimodal logic (SignedFormula, Tableau, Closure, Saturation, ProofExtraction, CountermodelExtraction, DecisionProcedure, Correctness)
- Metalogic_v2 already has a comprehensive FMP infrastructure in `Representation/FiniteModelProperty.lean` with explicit cardinality bounds and the constructive `finite_model_property_constructive` theorem
- Metalogic_v2 also has a `Representation/Closure.lean` module with closure infrastructure that duplicates some SignedFormula concepts
- **Recommended approach**: Create a new `Metalogic_v2/Decidability/` subdirectory that integrates with FMP.lean as the bridge theorem, reusing Metalogic_v2's closure infrastructure rather than porting the old Closure.lean

## Context & Scope

### Task Objective
Port the 8-file Decidability infrastructure from `Theories/Bimodal/Metalogic/Decidability/` to the `Metalogic_v2/` architecture, integrating with FMP as the bridge theorem.

### Files to Port (61KB total)

| File | Size | Purpose |
|------|------|---------|
| SignedFormula.lean | ~8KB | Signed formulas (T/F assertions), branches, subformula closure |
| Tableau.lean | ~10KB | Tableau expansion rules (propositional, modal, temporal) |
| Closure.lean | ~5KB | Branch closure detection (contradiction, botPos, axiomNeg) |
| Saturation.lean | ~6KB | Tableau saturation and expansion algorithm |
| ProofExtraction.lean | ~5KB | Extract DerivationTree proofs from closed tableaux |
| CountermodelExtraction.lean | ~4KB | Extract SimpleCountermodel from open branches |
| DecisionProcedure.lean | ~7KB | Main decide function combining all components |
| Correctness.lean | ~5KB | Soundness and completeness theorems for the procedure |

### Constraints
- Must integrate with Metalogic_v2's representation-first architecture
- Must use FMP.lean as the bridge theorem for decidability bounds
- Should reuse existing Metalogic_v2 infrastructure where possible

## Findings

### 1. Old Decidability Architecture Analysis

#### SignedFormula.lean
Defines core types:
- `Sign` (pos/neg) - truth value assertion
- `SignedFormula` - formula with sign attachment
- `Branch` - list of signed formulas
- `Formula.subformulas` - subformula collection (Note: This is also defined in `Bimodal.Syntax.Subformulas`)
- `subformulaClosure` / `signedSubformulaClosure` - closure computations
- `unexpandedComplexity` / `branchUnexpandedComplexity` - termination measures

**Dependencies**: `Bimodal.Syntax.Formula`, `Bimodal.ProofSystem`

#### Tableau.lean
Implements tableau expansion:
- `TableauRule` - enumeration of 14 rules (andPos, andNeg, orPos, orNeg, impPos, impNeg, negPos, negNeg, boxPos, boxNeg, diamondPos, diamondNeg, allFuturePos, allFutureNeg, allPastPos, allPastNeg)
- Formula decomposition helpers (`asNeg?`, `asAnd?`, `asOr?`, `asDiamond?`, `asSomePast?`, `asSomeFuture?`)
- `applyRule` - rule application logic
- `expandOnce` - single expansion step
- `ExpansionResult` - result type (saturated/extended/split)

**Key insight**: Rules leverage S5 semantics for modal operators (reflexivity/symmetry/transitivity collapsed to single equivalence class).

#### Closure.lean
Detects branch closure:
- `ClosureReason` - witness type (contradiction, botPos, axiomNeg)
- `findClosure` - main closure detection
- `ClosedBranch` / `OpenBranch` - typed branch classifications
- Integrates with `matchAxiom` from ProofSearch for axiom detection

**Dependencies**: `Bimodal.Automation.ProofSearch` (for axiom matching)

#### Saturation.lean
Manages tableau expansion to completion:
- `ExpandedTableau` - result type (allClosed/hasOpen)
- `expandBranchWithFuel` - fuel-based expansion for termination
- `buildTableau` - main tableau construction
- `recommendedFuel` - heuristic fuel calculation based on complexity

**Note**: Uses fuel-based termination rather than well-founded recursion.

#### ProofExtraction.lean
Extracts proofs from closed tableaux:
- `extractFromClosureReason` - proof fragment from closure witness
- `tryAxiomProof` - direct axiom proof via `matchAxiom`
- `extractProof` - main extraction logic
- `findProofCombined` - combines tableau + proof search

**Limitations**: Full proof extraction from tableau structure is incomplete; relies heavily on direct axiom matching.

#### CountermodelExtraction.lean
Extracts countermodels from open branches:
- `SimpleCountermodel` - lightweight countermodel (just true/false atoms)
- `extractTrueAtoms` / `extractFalseAtoms` - valuation extraction
- `findCountermodel` - main extraction function

**Note**: Simplified version that doesn't construct full semantic models.

#### DecisionProcedure.lean
Main decision interface:
- `DecisionResult` - sum type (valid proof / invalid countermodel / timeout)
- `decide` - main decision function with three-phase algorithm:
  1. Fast path: direct axiom proof
  2. Medium path: bounded proof search
  3. Slow path: full tableau construction
- `decideAuto` / `decideOptimized` - convenience wrappers
- `isTautology` / `isContradiction` / `isContingent` - classification functions

#### Correctness.lean
Metatheorems about the procedure:
- `decide_sound` - if returns valid proof, formula is valid (via soundness)
- `decide_complete` - if formula is valid, returns valid proof (sorry - requires FMP)
- `validity_decidable` - validity is decidable (Classical.em fallback)
- `tableau_complete` - tableau terminates and is complete (sorry - requires FMP)

**Key connection**: The `tableau_complete` theorem references FMP but doesn't use Metalogic_v2's constructive FMP.

### 2. Metalogic_v2 Architecture Analysis

#### Layer Structure
```
Metalogic_v2/
├── Core/
│   ├── Basic.lean         - Consistency, validity definitions
│   ├── Provability.lean   - Context derivability
│   ├── DeductionTheorem.lean
│   └── MaximalConsistent.lean - Lindenbaum's lemma, MCS properties
├── Soundness/
│   ├── Soundness.lean
│   └── SoundnessLemmas.lean
├── Representation/
│   ├── CanonicalModel.lean      - Canonical world states and model
│   ├── ContextProvability.lean
│   ├── TruthLemma.lean
│   ├── RepresentationTheorem.lean
│   ├── Closure.lean             - Subformula closure, ClosureMaximalConsistent
│   ├── FiniteWorldState.lean    - Finite world state types
│   ├── SemanticCanonicalModel.lean - Semantic world states, completeness
│   └── FiniteModelProperty.lean - FMP with explicit bounds
├── Completeness/
│   ├── WeakCompleteness.lean
│   └── StrongCompleteness.lean
├── Applications/
│   └── Compactness.lean
└── FMP.lean                     - Hub module re-exporting FMP
```

#### Key FMP Infrastructure (FiniteModelProperty.lean)

**Subformula Closure** (lines 64-156):
- `subformulaList : Formula -> List Formula` - subformulas as list
- `self_mem_subformulaList` - formula is in its own closure
- `subformulaList_finite` - size bounded by `2^complexity + 1`

**Main FMP Theorems**:
- `finite_model_property` (line 178) - satisfiable implies satisfiable in finite model
- `satisfiability_decidable` (line 197) - noncomputable decidability
- `finite_model_size_bound` (line 209) - explicit size bound
- `consistent_implies_satisfiable` (line 228) - consistency to satisfiability
- `validity_decidable_via_fmp` (line 262) - validity is decidable

**Constructive FMP** (lines 314-482):
- `semanticWorldState_card_bound` - |SemanticWorldState| <= 2^closureSize
- `finite_model_property_constructive` - FMP with explicit Fintype witness and bound

#### Closure Infrastructure (Closure.lean)

**Closure Definitions**:
- `closure : Formula -> Finset Formula` - subformula closure as Finset
- `closureWithNeg : Formula -> Finset Formula` - closure extended with negations
- `closureSize : Formula -> Nat` - cardinality

**Closure-Restricted Consistency**:
- `ClosureConsistent` - subset of closureWithNeg and set-consistent
- `ClosureMaximalConsistent` - maximal within closureWithNeg
- `mcs_projection` - project full MCS to closure
- `mcs_projection_is_closure_mcs` - projection preserves closure-MCS

**Closure Properties**:
- `closure_mcs_neg_complete` - either psi or psi.neg in closure MCS
- `closure_mcs_imp_iff` - implication matches material implication

### 3. Dependency Mapping (Old -> New)

| Old Decidability | Metalogic_v2 Equivalent | Notes |
|-----------------|-------------------------|-------|
| `Formula.subformulas` | `Representation.Closure.closure` | Use Finset version |
| `subformulaClosure` | `closure` + `closureWithNeg` | Finset-based |
| `SignedFormula` | (None - must port) | Core type, no equivalent |
| `Branch` | (None - must port) | Core type, no equivalent |
| `unexpandedComplexity` | (None - must port) | Termination measure |
| `ClosureReason` | (None - must port) | Closure witness |
| `matchAxiom` | Same (from ProofSearch) | Keep dependency |
| `DecisionResult` | (None - must port) | Result type |
| `buildTableau` | (None - must port) | Core algorithm |
| `finite_model_property` | `Representation.FiniteModelProperty.finite_model_property` | Use v2 version |
| `finite_model_size_bound` | `semanticWorldState_card_bound` | Use v2 constructive |
| `satisfiability_decidable` | `satisfiability_decidable` | Same, use v2 |
| `validity_decidable_via_fmp` | `validity_decidable_via_fmp` | Same, use v2 |

### 4. FMP Integration Points

The old `Decidability/Correctness.lean` has two sorry'd theorems that depend on FMP:

```lean
theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid := by
  sorry  -- Requires FMP-based termination proof

theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
    ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof := by
  sorry  -- Requires tableau completeness
```

Metalogic_v2's `finite_model_property_constructive` provides:
1. `Fintype.card F.WorldState <= 2^closureSize phi` - explicit bound
2. `Finite F.WorldState` - finiteness witness
3. `truth_at M tau 0 phi` - satisfaction witness

This can be used to compute fuel bounds:
```lean
def fmpBasedFuel (phi : Formula) : Nat :=
  2 ^ closureSize phi * 2  -- Factor of 2 for signed formulas
```

### 5. Recommended Porting Approach

#### Phase 1: Core Types (New Files)
Create `Metalogic_v2/Decidability/` with:

1. **SignedFormula.lean** (Port with modifications)
   - Import `Representation.Closure` for closure infrastructure
   - Remove duplicate `Formula.subformulas` (use `Bimodal.Syntax.Subformulas`)
   - Keep `Sign`, `SignedFormula`, `Branch` types
   - Update `subformulaClosure` to use `closure` Finset
   - Keep complexity measures for termination

2. **Tableau.lean** (Port mostly unchanged)
   - Import new SignedFormula
   - Keep all rules and application logic
   - Rules are logic-specific, not architecture-specific

3. **Closure.lean** (Port with renamed types to avoid confusion)
   - Rename to `BranchClosure.lean` to avoid confusion with `Representation.Closure`
   - Keep `ClosureReason`, `findClosure`, `ClosedBranch`, `OpenBranch`
   - Update imports

#### Phase 2: Expansion Engine
4. **Saturation.lean** (Port with FMP integration)
   - Use `closureSize` from Representation.Closure for fuel calculation
   - Update `recommendedFuel` to use FMP bounds:
     ```lean
     def fmpBasedFuel (phi : Formula) : Nat :=
       2 ^ Representation.closureSize phi
     ```

#### Phase 3: Extraction Modules
5. **ProofExtraction.lean** (Port mostly unchanged)
   - Update imports
   - Keep axiom-based extraction logic

6. **CountermodelExtraction.lean** (Port with potential enhancement)
   - Consider integrating with `SemanticCanonicalModel` for richer countermodels
   - Keep `SimpleCountermodel` as lightweight option

#### Phase 4: Integration
7. **DecisionProcedure.lean** (Port with FMP integration)
   - Update to use Metalogic_v2 soundness/completeness
   - Use FMP-based fuel calculation
   - Keep three-phase decision algorithm

8. **Correctness.lean** (Port with proofs completed)
   - Use `finite_model_property_constructive` to prove `tableau_complete`
   - Use `semanticWorldState_card_bound` for termination bounds
   - Complete the sorry'd theorems

#### Phase 5: Hub Module
9. **Create `Metalogic_v2/Decidability.lean`** (New hub file)
   - Re-export key types and theorems
   - Document integration with FMP.lean

### 6. File Structure After Porting

```
Metalogic_v2/
├── ... (existing)
├── Decidability/
│   ├── SignedFormula.lean     - Signs, signed formulas, branches
│   ├── Tableau.lean           - Expansion rules
│   ├── BranchClosure.lean     - Branch closure detection
│   ├── Saturation.lean        - Expansion engine (FMP-integrated)
│   ├── ProofExtraction.lean   - Proof term extraction
│   ├── CountermodelExtraction.lean - Countermodel extraction
│   ├── DecisionProcedure.lean - Main interface
│   └── Correctness.lean       - Metatheorems (FMP-completed)
├── Decidability.lean          - Hub module
└── FMP.lean                   - (Existing, imports Decidability for bidirectional)
```

### 7. Import Graph After Porting

```
FMP.lean (hub)
    │
    ├── imports Representation.FiniteModelProperty
    │
    └── imports Decidability.lean (new hub)
            │
            ├── SignedFormula ← Representation.Closure
            ├── Tableau ← SignedFormula
            ├── BranchClosure ← Tableau, ProofSearch
            ├── Saturation ← BranchClosure, Representation.FiniteModelProperty
            ├── ProofExtraction ← Saturation
            ├── CountermodelExtraction ← Saturation
            ├── DecisionProcedure ← ProofExtraction, CountermodelExtraction
            └── Correctness ← DecisionProcedure, Soundness.Soundness, FMP
```

## Decisions

1. **Rename Closure.lean to BranchClosure.lean** to avoid naming conflict with Representation/Closure.lean
2. **Use Metalogic_v2's closure Finset** rather than porting old List-based closure
3. **Keep fuel-based termination** but compute fuel from FMP bounds
4. **Port in phases** starting with core types, then expansion, then extraction, then integration
5. **Complete sorry'd theorems** using Metalogic_v2's constructive FMP

## Recommendations

1. **High Priority**: Start with SignedFormula.lean and Tableau.lean as they have minimal dependencies on Metalogic_v2 specifics

2. **Medium Priority**: Port Saturation.lean with FMP integration - this is where the main benefit of Metalogic_v2 integration appears

3. **Lower Priority**: CountermodelExtraction could be enhanced to use SemanticCanonicalModel but the simple version works

4. **Testing**: Create `Tests/BimodalTest/Metalogic_v2/DecidabilityTest.lean` with examples from the old test suite

5. **Documentation**: Update FMP.lean docstrings to mention Decidability integration

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Closure naming confusion | Rename to BranchClosure.lean; document in CLAUDE.md |
| FMP fuel bounds too loose | Start with 2x multiplier, tune based on benchmarks |
| ProofExtraction incomplete | Keep both axiom-based and search-based extraction |
| Import cycles | Ensure Decidability -> FMP direction only, not reverse |
| Large refactor scope | Phase the work; each file can be a separate commit |

## Appendix

### Search Queries Used
- `lean_file_outline` on all Decidability/ and Metalogic_v2/ files
- Direct file reads for detailed analysis

### Key Type Signatures

```lean
-- SignedFormula (to port)
inductive Sign : Type where | pos | neg
structure SignedFormula : Type where sign : Sign; formula : Formula
abbrev Branch := List SignedFormula

-- Metalogic_v2 Closure (to use)
def closure (phi : Formula) : Finset Formula
def closureSize (phi : Formula) : Nat := (closure phi).card
def ClosureMaximalConsistent (phi : Formula) (S : Set Formula) : Prop

-- FMP (to use for completeness)
theorem finite_model_property_constructive (phi : Formula) (h_sat : formula_satisfiable phi) :
    exists F M tau t (h_finite : Finite F.WorldState) (h_fintype : Fintype F.WorldState),
      truth_at M tau t phi /\ Fintype.card F.WorldState <= 2^closureSize phi
```

### References
- Metalogic_v2/FMP.lean - Hub module with architecture diagram
- Metalogic_v2/Representation/FiniteModelProperty.lean - Constructive FMP
- Metalogic_v2/Representation/Closure.lean - Closure infrastructure
- Old Metalogic/Decidability/* - Source files to port
