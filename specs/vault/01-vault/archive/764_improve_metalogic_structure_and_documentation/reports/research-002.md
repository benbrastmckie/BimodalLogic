# Research Report: Task #764 (Follow-up)

**Task**: 764 - improve_metalogic_structure_and_documentation
**Started**: 2026-01-29T14:00:00Z
**Completed**: 2026-01-29T14:30:00Z
**Effort**: Medium
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (Metalogic/, Boneyard/), import analysis
**Artifacts**: specs/764_improve_metalogic_structure_and_documentation/reports/research-002.md
**Standards**: report-format.md

## Executive Summary

- **3 Boneyard imports found** in active Metalogic/ code that need recovery:
  1. `Core/MaximalConsistent.lean` imports `Boneyard/Metalogic_v2/Core/MaximalConsistent`
  2. `Completeness/WeakCompleteness.lean` imports `Boneyard/Metalogic_v2/Soundness/Soundness`
  3. `FMP/Closure.lean` imports `Boneyard/Metalogic_v2/Representation/CanonicalModel`

- **FMP Layer uses UniversalCanonicalModel but NOT UltrafilterMCS directly** - the Algebraic/ path is an independent alternative, not a dependency

- **Archival candidates identified**: The entire Algebraic/ subdirectory (5 files) could potentially be archived as it provides an alternative proof path not used by the main completeness proof

## Context & Scope

This follow-up research addresses specific questions from the task delegation:
1. What Boneyard imports exist and what would it take to eliminate them?
2. Does the FMP Layer actually use both UniversalCanonicalModel and UltrafilterMCS?
3. What elements in Metalogic/ are not needed for main results and could be archived?

## Findings

### 1. Boneyard Import Analysis

Three files in active Metalogic/ import from Boneyard/:

#### Import 1: Core/MaximalConsistent.lean
```lean
import Bimodal.Boneyard.Metalogic_v2.Core.MaximalConsistent
```

**What's being imported** (54 exports):
- Core definitions: `Consistent`, `MaximalConsistent`, `SetConsistent`, `SetMaximalConsistent`
- Lindenbaum lemma: `set_lindenbaum`
- MCS properties: `maximal_negation_complete`, `maximal_consistent_closed`, `theorem_in_mcs`
- Helper lemmas: `inconsistent_derives_bot`, `derives_neg_from_inconsistent_extension`, etc.

**Recovery effort**: HIGH
- This is foundational MCS theory with ~500 lines of proven code
- Deep dependency on `Bimodal.ProofSystem` and `Mathlib.Order.Zorn`
- Would need careful renaming for clarity and consistency

#### Import 2: Completeness/WeakCompleteness.lean
```lean
import Bimodal.Boneyard.Metalogic_v2.Soundness.Soundness
```

**What's being imported**:
- `Bimodal.Metalogic_v2.Soundness.soundness` theorem: `DerivationTree Gamma phi -> semantic_consequence Gamma phi`
- Covers all 15 TM axioms and 7 derivation rules

**Recovery effort**: HIGH
- Complete soundness proof with all axiom validity lemmas
- Imports `SoundnessLemmas.lean` with additional helpers
- Would need migration of ~400 lines of proven code

#### Import 3: FMP/Closure.lean
```lean
import Bimodal.Boneyard.Metalogic_v2.Representation.CanonicalModel
```

**What's being imported**:
- `CanonicalWorldState` definition
- `mcs_contains_or_neg`: MCS negation completeness lemma
- Frame/model definitions (unused, superseded by TaskFrame)

**Recovery effort**: MEDIUM
- Only `mcs_contains_or_neg` is actually used (single lemma)
- Could migrate just that lemma or prove it directly
- The frame/model definitions are legacy (not needed)

### 2. FMP Layer Dependency Analysis

#### Does FMP use UniversalCanonicalModel?

**NO, not directly.** The FMP layer files (`FMP/*.lean`) do NOT import UniversalCanonicalModel.lean:
```
Theories/Bimodal/Metalogic/FMP/*.lean:
- NO import of UniversalCanonicalModel
- NO import from Representation/ (except indirectly via Boneyard)
```

**However**, the FMP layer DOES use:
- `set_lindenbaum` from Core/MaximalConsistent (re-exported from Boneyard)
- `mcs_contains_or_neg` from Boneyard/Representation/CanonicalModel
- `SetMaximalConsistent`, `ClosureMaximalConsistent` definitions

The FMP layer constructs its OWN finite model via:
- `SemanticCanonicalModel.lean` - builds finite model from closure MCS
- `FiniteWorldState.lean` - finite world states from subformula closure
- Does NOT use the infinite canonical model from UniversalCanonicalModel

#### Does FMP use UltrafilterMCS?

**NO.** There is no import chain from FMP/ to UltrafilterMCS:
```
grep "import.*Ultrafilter" FMP/ -> No matches
grep "import.*Algebraic" FMP/ -> No matches
```

The Algebraic/ subdirectory is an **independent alternative path** to the representation theorem, not a dependency of the main completeness proof.

### 3. Dependency Flowchart (Corrected from research-001)

```
                        MAIN COMPLETENESS PATH
                              (sorry-free)
                                  |
                                  v
                         Completeness/
                    WeakCompleteness.lean
                              |
          ____________________+____________________
         |                    |                    |
         v                    v                    v
  Soundness theorem   representation_theorem  Deduction theorem
  (from Boneyard)      (representation)       (Core)
         |                    |
         v                    v
   Axiom validity    IndexedMCSFamily.lean
   lemmas (15)              |
                     CanonicalHistory.lean
                     TruthLemma.lean
                            |
                            v
                   Core/MaximalConsistent
                   (from Boneyard)
```

```
                     FINITE MODEL PROPERTY PATH
                      (has architectural sorry)
                                  |
                                  v
                     FMP/FiniteModelProperty.lean
                                  |
          ________________________+________________________
         |                        |                        |
         v                        v                        v
 SemanticCanonicalModel   FiniteWorldState.lean   Closure.lean
         |                        |                (from Boneyard)
         v                        v
 WorldHistory for          Boolean assignments
 finite time domain        on subformula closure
```

```
                      ALGEBRAIC PATH
                     (INDEPENDENT ALTERNATIVE)
                              |
                              v
               Algebraic/AlgebraicRepresentation.lean
                              |
              ________________+________________
             |                |                |
             v                v                v
      UltrafilterMCS   InteriorOperators  BooleanStructure
             |                |                |
             +----------------+----------------+
                              |
                              v
                   LindenbaumQuotient.lean
```

### 4. Archival Candidates

#### Candidates for Boneyard Archival

**A. Entire Algebraic/ subdirectory (5 files)**

| File | Status | Reason |
|------|--------|--------|
| LindenbaumQuotient.lean | Could archive | Not used by main proof path |
| BooleanStructure.lean | Could archive | Alternative approach |
| InteriorOperators.lean | Could archive | Alternative approach |
| UltrafilterMCS.lean | Could archive | Not used by FMP or Completeness |
| AlgebraicRepresentation.lean | Could archive | Provides same result via different path |

**Recommendation**: Archive the entire Algebraic/ directory to Boneyard. It provides an independent, mathematically interesting approach but:
- Is NOT required for the sorry-free completeness proof
- Is NOT used by FMP layer
- Would reduce Metalogic/ complexity significantly

**B. UniversalCanonicalModel.lean**

| Usage | Status |
|-------|--------|
| InfinitaryStrongCompleteness.lean | Uses representation_theorem |
| WeakCompleteness.lean | Uses representation_theorem |

**Recommendation**: Keep - it IS used by the completeness theorems. The confusion arose because FMP uses a different finite model construction, but the main completeness proof uses the infinite canonical model.

#### What to Recover from Boneyard

| From Boneyard | To Active | Recovery Notes |
|---------------|-----------|----------------|
| Metalogic_v2/Core/MaximalConsistent.lean | Core/MaximalConsistent.lean | Full content with renames |
| Metalogic_v2/Soundness/Soundness.lean | New: Soundness/Soundness.lean | Full soundness proof |
| Metalogic_v2/Representation/CanonicalModel.lean | Core/MCSProperties.lean | Only `mcs_contains_or_neg` needed |

### 5. Summary of Boneyard Dependencies

| Active File | Boneyard Import | What's Used | Recovery Complexity |
|-------------|-----------------|-------------|---------------------|
| Core/MaximalConsistent.lean | Core/MaximalConsistent | 54 exports (all MCS theory) | High (~500 lines) |
| Completeness/WeakCompleteness.lean | Soundness/Soundness | soundness theorem + lemmas | High (~400 lines) |
| FMP/Closure.lean | Representation/CanonicalModel | `mcs_contains_or_neg` only | Low (1 lemma) |

## Recommendations

### 1. Immediate Action: Fix FMP/Closure.lean Boneyard Import

The simplest fix with highest value - only one lemma (`mcs_contains_or_neg`) is actually used:

```lean
-- Option A: Move lemma to Core/MCSProperties.lean
-- Option B: Prove directly in Closure.lean using MCS definition
```

**Estimated effort**: 1-2 hours

### 2. Archive Algebraic/ to Boneyard

Move the entire Algebraic/ subdirectory to `Boneyard/Metalogic_v3/AlgebraicApproach/`:
- Remove 5 files from active codebase
- Preserve the mathematically interesting alternative approach
- Update Metalogic.lean to not import Algebraic/

**Estimated effort**: 1 hour

### 3. Plan Major Recovery: MCS Theory and Soundness

Create tasks for recovering:
1. MCS theory from Boneyard/Metalogic_v2/Core/
2. Soundness proof from Boneyard/Metalogic_v2/Soundness/

These are larger efforts that should be separate tasks with proper planning.

**Estimated effort**: 8-16 hours total

### 4. Documentation Update

Update Metalogic/README.md to:
- Clarify that Algebraic/ is an alternative path (if kept)
- Document Boneyard dependencies with recovery roadmap
- Show correct dependency flowchart distinguishing infinite model from FMP finite model

## Decisions

1. **FMP does NOT need UltrafilterMCS** - confirmed by import analysis
2. **FMP does NOT directly use UniversalCanonicalModel** - it builds its own finite model
3. **The infinite canonical model IS needed** - for WeakCompleteness and InfinitaryStrongCompleteness
4. **Algebraic/ is archivable** - provides alternative proof, not required for main results

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Archiving Algebraic/ loses mathematically interesting work | Archive to Boneyard with clear documentation, not delete |
| Recovering Boneyard content introduces new bugs | Careful migration with comprehensive testing |
| Breaking import chains during refactor | Use `lake build` after each change |

## Next Steps

1. **Quick win**: Fix Closure.lean to not import Boneyard (migrate one lemma)
2. **Optional**: Archive Algebraic/ to Boneyard
3. **Future tasks**: Plan full MCS theory and Soundness recovery from Boneyard

## Appendix

### Files Examined

- Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean
- Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean
- Theories/Bimodal/Metalogic/FMP/Closure.lean
- Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
- Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean
- Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean
- Theories/Bimodal/Boneyard/Metalogic_v2/Core/MaximalConsistent.lean
- Theories/Bimodal/Boneyard/Metalogic_v2/Soundness/Soundness.lean
- Theories/Bimodal/Boneyard/Metalogic_v2/Representation/CanonicalModel.lean

### Search Commands Used

```bash
grep "import.*Boneyard" Theories/Bimodal/Metalogic/
grep "import.*Algebraic" Theories/Bimodal/Metalogic/FMP/
grep "import.*Universal" Theories/Bimodal/Metalogic/FMP/
grep "import.*Ultrafilter" Theories/Bimodal/Metalogic/
grep "set_lindenbaum|SetMaximalConsistent" Theories/Bimodal/Metalogic/FMP/
```
