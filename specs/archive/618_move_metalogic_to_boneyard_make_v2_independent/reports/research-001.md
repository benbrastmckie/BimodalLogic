# Research Report: Task #618

**Task**: 618 - Move Metalogic to Boneyard, make Metalogic_v2 independent
**Started**: 2026-01-19T12:00:00Z
**Completed**: 2026-01-19T12:30:00Z
**Effort**: Low-Medium
**Priority**: Normal
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, grep/glob searches
**Artifacts**: This research report
**Standards**: report-format.md

## Executive Summary

- **Metalogic_v2 is fully independent of Metalogic** - No Lean source files in Metalogic_v2/ import from Metalogic/
- **Metalogic has external consumers** - 4 files outside Metalogic/ import from it (Demo.lean, Propositional.lean, GeneralizedNecessitation.lean, Logos/Metalogic.lean)
- **Migration requires updating 4 external files** to either use Metalogic_v2 equivalents or remove dependencies
- **Boneyard already exists** with documentation pattern (SyntacticApproach.lean) that can be followed

## Context & Scope

### Research Objectives
1. Verify Metalogic_v2 has no imports from Metalogic
2. Identify what imports from Metalogic (what needs to change)
3. Understand what "interesting" content exists in Metalogic
4. Determine migration plan

### File Counts
| Directory | Lean Files |
|-----------|------------|
| Theories/Bimodal/Metalogic/ | 17 files |
| Theories/Bimodal/Metalogic_v2/ | 16 files |
| Tests/BimodalTest/Metalogic/ | 3 files |
| Tests/BimodalTest/Metalogic_v2/ | 12 files |

## Findings

### 1. Metalogic_v2 Independence

**CONFIRMED: Metalogic_v2 is fully independent of Metalogic.**

All Metalogic_v2 source files import only from:
- `Bimodal.Metalogic_v2.*` (internal imports)
- `Bimodal.ProofSystem`, `Bimodal.Semantics`, `Bimodal.Syntax.*` (shared infrastructure)
- `Bimodal.Theorems.*` (Propositional, Combinators)
- `Mathlib.*` (standard library)

The only references to `Bimodal.Metalogic.` (without `_v2`) in Metalogic_v2 are in `README.md` comments, not actual imports.

### 2. External Consumers of Metalogic

Four files outside Metalogic/ import from it:

| File | Imports from Metalogic |
|------|------------------------|
| `Theories/Logos/Metalogic.lean` | Soundness, Completeness |
| `Theories/Bimodal/Examples/Demo.lean` | Soundness, DeductionTheorem, FiniteCanonicalModel, DecisionProcedure |
| `Theories/Bimodal/Theorems/Propositional.lean` | DeductionTheorem |
| `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` | DeductionTheorem |

### 3. Metalogic File Structure

```
Metalogic/
├── Core/
│   ├── Basic.lean
│   └── Provability.lean
├── Soundness/
│   ├── Soundness.lean
│   └── SoundnessLemmas.lean
├── Representation/
│   ├── CanonicalModel.lean
│   ├── ContextProvability.lean
│   ├── FiniteModelProperty.lean
│   ├── RepresentationTheorem.lean
│   └── TruthLemma.lean
├── Completeness/
│   ├── Completeness.lean
│   ├── CompletenessTheorem.lean
│   └── FiniteCanonicalModel.lean
├── Decidability/
│   ├── SignedFormula.lean
│   ├── Tableau.lean
│   ├── Closure.lean
│   ├── Saturation.lean
│   ├── ProofExtraction.lean
│   ├── CountermodelExtraction.lean
│   ├── DecisionProcedure.lean
│   └── Correctness.lean
├── Applications/
│   └── Compactness.lean
├── Decidability.lean (hub)
├── Completeness.lean (hub)
└── DeductionTheorem.lean
```

### 4. "Interesting" Content in Metalogic

Based on analysis, the key proven content includes:

| Module | Status | Description |
|--------|--------|-------------|
| Soundness | COMPLETE | Full soundness theorem with all axioms |
| DeductionTheorem | COMPLETE | Well-founded recursion proof |
| Decidability | COMPLETE | Tableau-based decision procedure |
| Completeness | PARTIAL | Has sorries (see SyntacticApproach.lean in Boneyard) |

**Note**: `FiniteCanonicalModel.lean` contains both deprecated code with sorries AND working semantic approach code. The Boneyard documentation in `SyntacticApproach.lean` already documents which parts are deprecated.

### 5. Metalogic_v2 Coverage

Metalogic_v2 provides equivalent or better coverage:

| Feature | Metalogic | Metalogic_v2 |
|---------|-----------|--------------|
| Soundness | Yes (proven) | Yes (proven) |
| Deduction Theorem | Yes (proven) | Yes (proven) |
| Maximal Consistent Sets | Partial | Yes (proven, Lindenbaum's lemma) |
| Canonical Model | Yes | Yes |
| Truth Lemma | Partial | Yes |
| Representation Theorem | Partial | Yes |
| Finite Model Property | Partial | Yes |
| Weak Completeness | Has sorries | Yes (proven) |
| Strong Completeness | Has sorries | Yes (proven) |
| Decidability | Yes (complete) | NOT YET (planned) |
| Compactness | Has sorries | Yes (derived) |

**Key difference**: Metalogic has a complete decidability module that Metalogic_v2 does not yet have.

### 6. Boneyard Pattern

The existing Boneyard contains:
- `SyntacticApproach.lean` - Documentation-only file explaining deprecated approach
- `DurationConstruction.lean` - Deprecated duration construction
- `TrivialFMP.lean` - Trivial FMP code

The pattern is: Move deprecated code but maintain as documentation with clear "DEPRECATED" markers.

## Decisions

1. **Metalogic can be safely moved to Boneyard** - Metalogic_v2 is confirmed independent
2. **External consumers need migration** - 4 files must be updated
3. **Decidability is unique to Metalogic** - This is the only module not covered by Metalogic_v2
4. **Tests should be updated** - 3 test files in Tests/BimodalTest/Metalogic/ need migration

## Recommendations

### Migration Plan

1. **Phase 1: Update External Consumers**
   - Update `Propositional.lean` and `GeneralizedNecessitation.lean` to import `Bimodal.Metalogic_v2.Core.DeductionTheorem`
   - Update `Logos/Metalogic.lean` to import from Metalogic_v2
   - Decide on `Demo.lean` - either update to Metalogic_v2 or move to Boneyard (it uses decidability heavily)

2. **Phase 2: Handle Decidability**
   - Option A: Keep Decidability in main tree (not in Boneyard) until Metalogic_v2 has equivalent
   - Option B: Copy Decidability to Metalogic_v2 as separate migration
   - Option C: Move all to Boneyard, accept Demo.lean uses Boneyard imports temporarily

3. **Phase 3: Move Metalogic to Boneyard**
   - Move `Theories/Bimodal/Metalogic/` to `Theories/Bimodal/Boneyard/Metalogic/`
   - Update `Theories/Bimodal/Metalogic.lean` hub to either redirect to Boneyard or remove
   - Move `Tests/BimodalTest/Metalogic/` to archive or update to Metalogic_v2

4. **Phase 4: Cleanup**
   - Add deprecation documentation following SyntacticApproach.lean pattern
   - Verify build succeeds

### Recommended Approach

**Option C (Move all, update later)** is cleanest:
- Metalogic_v2 is the future
- Demo.lean can temporarily import from Boneyard until decidability is added to Metalogic_v2
- Clear separation between active code (Metalogic_v2) and deprecated code (Boneyard/Metalogic)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Demo.lean breaks | Allow Boneyard imports temporarily; document plan to migrate |
| Missing decidability in Metalogic_v2 | Create follow-up task for decidability implementation |
| Merge conflicts | Ensure this is done atomically |
| Build failures | Run `lake build` after each phase |

## Appendix

### Search Queries Used

```bash
# Check Metalogic_v2 imports
grep -r "import.*Metalogic[^_]" Theories/Bimodal/Metalogic_v2/

# Find all consumers of Metalogic
grep -r "import.*Bimodal\.Metalogic\." --include="*.lean"

# Count files
find Theories/Bimodal/Metalogic -name "*.lean" | wc -l
find Theories/Bimodal/Metalogic_v2 -name "*.lean" | wc -l
```

### File Listing

**Metalogic_v2 files (16 in Theories)**:
- Core/: Basic, Provability, DeductionTheorem, MaximalConsistent
- Soundness/: SoundnessLemmas, Soundness
- Representation/: CanonicalModel, TruthLemma, RepresentationTheorem, ContextProvability, FiniteModelProperty, FiniteWorldState, SemanticCanonicalModel, Closure
- Completeness/: WeakCompleteness, StrongCompleteness
- Applications/: Compactness
- FMP.lean (hub)

**Tests for Metalogic_v2 (12 files)**: CoreTest, SoundnessTest, SoundnessPropertyTest, CompletenessTest, FMPTest, ContextProvabilityTest, TruthLemmaPropertyTest, CanonicalModelPropertyTest, CorePropertyTest, RepresentationTest
