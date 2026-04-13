# Research Report: Archive Strict-Semantics Legacy Code

**Task**: 94 - archive_strict_semantics_legacy
**Session**: sess_1776062319_e1ad7b
**Date**: 2026-04-12

## 1. Target Files: Existence and Sorry Counts

All four target files exist. Actual sorry counts differ from the task description estimates:

| File | Lines | Actual Sorries | Estimated |
|------|-------|---------------|-----------|
| `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` | 3,978 | 18 | ~67 |
| `Theories/Bimodal/FrameConditions/Completeness.lean` | 633 | 54 | ~54 |
| `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` | 1,455 | 9 | ~29 |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | 6,139 | 18 | ~61 |
| **Total** | **12,205** | **99** | **~211** |

The actual sorry reduction is 99, not ~210. The estimates were likely from an earlier codebase snapshot.

## 2. Import Dependency Analysis

### Direct Non-Boneyard Importers of Target Files

**UltrafilterChain.lean** imported by:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` (target -- co-archived)
- `Theories/Bimodal/FrameConditions/Completeness.lean` (target -- co-archived)

**DovetailedChain.lean** imported by:
- `Theories/Bimodal/FrameConditions/Completeness.lean` (target -- co-archived)

**SuccChainFMCS.lean** imported by (NON-Boneyard, NON-target):
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (target -- co-archived)
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` (1 sorry) **<-- COMPLICATION**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (3 sorries) **<-- COMPLICATION**

**FrameConditions/Completeness.lean** imported by:
- `Theories/Bimodal/FrameConditions.lean` (root module)

### Critical Complication: CanonicalConstruction and RestrictedTruthLemma

These two files are NOT listed in the task description but heavily depend on SuccChainFMCS:

- **RestrictedTruthLemma.lean** (1 sorry): Imports SuccChainFMCS, uses `RestrictedTemporallyCoherentFamily` extensively
- **CanonicalConstruction.lean** (3 sorries): Imports both SuccChainFMCS and RestrictedTruthLemma

**CanonicalConstruction.lean** is itself imported by:
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` (0 sorries)
- `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean` (3 sorries)
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` (1 sorry)
- `Theories/Bimodal/Metalogic.lean` (root module)

**This means**: Moving SuccChainFMCS to Boneyard without also moving or refactoring CanonicalConstruction and RestrictedTruthLemma will cause build failures.

### Existing Boneyard Importers of Target Files

Multiple Boneyard files already import these targets. These imports will break but that is acceptable since Boneyard files are not on the build path (or should not be):
- `Boneyard/ChainCompleteness/Bundle/SimplifiedChain.lean` imports SuccChainFMCS
- `Boneyard/ChainCompleteness/Bundle/MCSWitnessChain.lean` imports UltrafilterChain
- `Boneyard/ChainCompleteness/Bundle/ResolvingChain.lean` imports UltrafilterChain
- `Boneyard/ChainCompleteness/Bundle/TargetedChain.lean` imports both
- `Boneyard/ChainCompleteness/Bundle/MCSWitnessSuccessor.lean` imports both
- `Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` imports UltrafilterChain
- Several Boneyard/ChainCompleteness/Bundle files import SuccChainFMCS

## 3. Existing Boneyard Structure

Boneyard already exists at `Theories/Bimodal/Boneyard/` with these subdirectories:

```
Boneyard/
├── BundleTemporalCoherence/   (1 .lean, 1 README.md)
├── ChainCompleteness/         (13 .lean files in Algebraic/ and Bundle/)
├── DiscreteXY/                (1 .lean)
├── TAxiomDependentCode/       (3 .lean, 1 README.md)
└── UltrafilterDeadCode/       (4 .lean, 1 README.md)
```

Pattern: Each Boneyard subdirectory has a descriptive name. Some include README.md files explaining the archival reason.

## 4. Metalogic.lean Current Imports

```lean
import Bimodal.Metalogic.SoundnessLemmas
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Decidability
import Bimodal.Metalogic.Bundle.CanonicalConstruction  -- <-- depends on SuccChainFMCS
```

Note: `Metalogic.lean` does NOT import BXCanonical. The task description says "Metalogic.lean already points to BXCanonical" but this is incorrect -- it still points to the old CanonicalConstruction path.

## 5. BXCanonical: Active Completeness Path

BXCanonical lives at `Theories/Bimodal/Metalogic/BXCanonical/` with 13 files:

```
BXCanonical/
├── BXCanonical.lean          (2 sorries - root module)
├── CanonicalChain.lean       (1 sorry)
├── Completeness.lean         (4 sorries)
├── Frame.lean                (1 sorry)
├── TruthLemma.lean           (1 sorry)
├── Filtration/
│   ├── DefectChain.lean      (0 sorries)
│   └── SigmaOrdering.lean    (1 sorry)
└── Quasimodel/
    ├── Construction.lean     (1 sorry)
    ├── EnrichedClosure.lean  (0 sorries)
    ├── HintikkaPoint.lean    (0 sorries)
    ├── LocusControl.lean     (0 sorries)
    ├── Realization.lean      (1 sorry)
    └── SubformulaClosure.lean(0 sorries)
```

**Total BXCanonical sorries: 12**

BXCanonical is completely independent -- it imports NONE of the legacy files (UltrafilterChain, DovetailedChain, SuccChainFMCS, CanonicalConstruction, RestrictedTruthLemma).

## 6. state.json Technical Debt

state.json has NO `technical_debt` field. The `repository_health` field contains:

```json
{
  "last_assessed": "2026-04-13T06:09:29Z",
  "status": "healthy",
  "build_errors": 0
}
```

The implementation will need to either add a `technical_debt` field or update `repository_health` with sorry counts.

## 7. Task 91 Dependency

Task 91 (roadmap update) is **completed and archived**. The TODO.md header notes: "tasks 90-92, 98-102 completed (all Frame.lean sorries closed). Pruned 91 (completed)."

However, task 103 (ROAD_MAP.md rewrite) is a successor that notes the ROAD_MAP.md from task 91 already has factual errors. The Boneyard README can reference the current ROAD_MAP.md with the understanding that task 103 will update it.

## 8. Strict vs Reflexive Semantics

Evidence from UltrafilterChain.lean comments:
- Lines 83, 238: "R_G/R_H is NOT reflexive under strict semantics (G quantifies over s > t / s < t)"
- Line 113: "R_Box is reflexive: every ultrafilter is R_Box-related to itself"
- Lines 484-485: "Under reflexive semantics, the T-axiom G(a) -> a gives the t = t' case"
- Line 2766: "G(a) -> a is NOT valid under strict semantics"
- Multiple comments reference "temp_4 removed in BX" as sorry justifications
- The `sorry` annotations like "BX: derive temp_4 from BX1" indicate these are architectural incompatibilities

The key distinction: Under strict semantics, G and H quantify over strictly future/past moments (s > t, s < t). Under reflexive BX semantics, they use non-strict ordering (s >= t, s <= t), which makes the T-axiom (G(a) -> a) valid. The strict semantics code was written before BX was adopted and cannot simply be ported -- the proof architecture is fundamentally different.

## 9. Recommendations for Implementation

### Option A: Archive Only the 4 Listed Files (Minimal)

Move the 4 target files + update their importers:
1. Move UltrafilterChain.lean, DovetailedChain.lean, FrameConditions/Completeness.lean, SuccChainFMCS.lean to `Boneyard/StrictSemanticsLegacy/`
2. Remove import of SuccChainFMCS from CanonicalConstruction.lean and RestrictedTruthLemma.lean
3. Remove import of FrameConditions.Completeness from FrameConditions.lean

**Problem**: CanonicalConstruction.lean and RestrictedTruthLemma.lean use types defined in SuccChainFMCS (`RestrictedTemporallyCoherentFamily`, `restricted_succ_chain_fam`, etc.). Simply removing the import will cause massive compilation failures in those files.

### Option B: Archive the Full Legacy Chain (Recommended)

Archive ALL files in the old SuccChain completeness path:
1. **Primary targets** (4 files, 99 sorries):
   - `Metalogic/Algebraic/UltrafilterChain.lean` (18)
   - `Metalogic/Algebraic/DovetailedChain.lean` (9)
   - `FrameConditions/Completeness.lean` (54)
   - `Metalogic/Bundle/SuccChainFMCS.lean` (18)

2. **Dependent files that also need archiving** (2 files, 4 sorries):
   - `Metalogic/Algebraic/RestrictedTruthLemma.lean` (1)
   - `Metalogic/Bundle/CanonicalConstruction.lean` (3)

3. **Update importers**:
   - `Metalogic.lean`: Remove `import Bimodal.Metalogic.Bundle.CanonicalConstruction`, optionally add `import Bimodal.Metalogic.BXCanonical.BXCanonical`
   - `FrameConditions.lean`: Remove `import Bimodal.FrameConditions.Completeness`
   - `BaseCompleteness.lean`: Remove `import Bimodal.Metalogic.Bundle.CanonicalConstruction`
   - `DiscreteCompleteness.lean`: Remove `import Bimodal.Metalogic.Bundle.CanonicalConstruction`
   - `DenseCompleteness.lean`: Remove `import Bimodal.Metalogic.Bundle.CanonicalConstruction`

4. **BaseCompleteness/DiscreteCompleteness/DenseCompleteness**: These files (0+3+1 = 4 sorries) import CanonicalConstruction. If CanonicalConstruction is archived, these files need to either:
   - Also be archived (if they are entirely legacy SuccChain path)
   - Be refactored to use BXCanonical instead

**Total sorry reduction with Option B**: 99 (primary) + 4 (dependent) = 103, plus potentially more from Base/Discrete/DenseCompleteness.

### Additional Consideration: BaseCompleteness/DiscreteCompleteness/DenseCompleteness

These 3 files import CanonicalConstruction and would break. Their sorry counts (0+3+1 = 4) and content suggest they are wiring files that connect the old SuccChain path to completeness results. They would need to be either:
- Archived along with the rest (clean break)
- Refactored to wire through BXCanonical instead (functional replacement)

The decision depends on whether the project wants to maintain separate Base/Discrete/Dense completeness interfaces or consolidate everything through BXCanonical.

### Implementation Steps (Option B)

1. Create `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/` directory structure
2. Move 6 files (4 primary + 2 dependent) preserving subdirectory structure
3. Write `Boneyard/StrictSemanticsLegacy/README.md`
4. Update FrameConditions.lean to remove Completeness import
5. Update Metalogic.lean to remove CanonicalConstruction import
6. Handle BaseCompleteness/DiscreteCompleteness/DenseCompleteness (archive or refactor)
7. Update existing Boneyard files that import the moved files (update import paths)
8. Update state.json with sorry count changes
9. Verify build succeeds with `lake build`

### Sorry Count Summary (Current)

| Category | Sorries |
|----------|---------|
| Non-Boneyard total | 273 |
| Boneyard total | 88 |
| Target files (4) | 99 |
| Dependent files (2) | 4 |
| After archiving (Option B, 6 files) | 273 - 103 = ~170 non-Boneyard |

### Boneyard README Content Points

1. These files implemented completeness via the SuccChain/UltrafilterChain architecture
2. Written under strict temporal semantics where G/H use strict ordering (s > t, s < t)
3. The codebase reverted to reflexive BX semantics where G/H use non-strict ordering (s >= t, s <= t)
4. Under strict semantics, the T-axiom (G(a) -> a) is not valid, requiring different proof architecture
5. Sorry counts reflect architectural incompatibility with BX semantics, not genuine mathematical gaps
6. The active completeness path is `BXCanonical/` which is fully independent
7. Reference ROAD_MAP.md for the current project trajectory
8. Related Boneyard directories: `ChainCompleteness/` contains earlier abandoned attempts from the same path
