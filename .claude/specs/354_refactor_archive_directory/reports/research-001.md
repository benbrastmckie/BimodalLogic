# Research Report: Task #354

**Task**: Research and refactor Archive/ directory
**Date**: 2026-01-11
**Focus**: Understand Archive/ structure and determine refactoring needs post-Bimodal migration

## Summary

The Archive/ directory serves as a **pedagogical examples library** containing well-documented proof demonstrations and strategies for TM (Tense and Modality) bimodal logic. The recent Logos/Core → Bimodal migration (task 352) has already updated the Lean imports, but documentation references still point to outdated paths. Additionally, there's a layered re-export architecture with Logos/Examples/ that needs clarification.

## Findings

### 1. Current Archive/ Structure

```
Archive/
├── Archive.lean              # Root module re-exporting all examples
├── ModalProofs.lean          # S5 modal logic theorem proofs (295 lines)
├── ModalProofStrategies.lean # Modal proof strategies (511 lines, 20 examples)
├── TemporalProofs.lean       # Linear temporal logic proofs (413 lines)
├── TemporalProofStrategies.lean # Temporal strategies (647 lines, 26 examples)
├── BimodalProofs.lean        # Perpetuity principles P1-P3 (244 lines)
├── BimodalProofStrategies.lean # Bimodal strategies (737 lines, 29 examples)
├── TemporalStructures.lean   # Polymorphic temporal types (211 lines)
├── README.md                 # Comprehensive documentation
└── logos-original/           # Historical documentation archive
    ├── README.md             # Original Logos docs overview
    ├── README-ARCHIVE.md     # Archive integration notes
    ├── LOGOS_LAYERS.md       # Layer extensibility design
    ├── PROOF_LIBRARY.md      # Theorem caching design
    └── RL_TRAINING.md        # RL training architecture
```

**Statistics**:
- Total lines: ~3,058 lines of Lean 4 code
- Total examples: 75+ pedagogical examples
- Average comment density: 68.6% (exceeds 50% standard)
- All modules build successfully

### 2. Import Path Migration Status

**Completed (Task 352)**:
- All `.lean` file imports updated from `Logos.Core.*` to `Bimodal.*`
- Example: `import Bimodal.ProofSystem.Derivation` (correct)

**Remaining Issues**:
- Documentation references still use old `Logos/Core/` paths:
  - `Archive/README.md` lines 86-88: Reference `Logos/Core/Theorems/Perpetuity.lean`
  - `Archive/*.lean` docstrings: 3 files reference `../Logos/Core/Theorems/Perpetuity.lean`

### 3. Re-Export Architecture

There's a two-layer architecture:

**Layer 1 - Archive/** (Source of Truth):
- Contains actual proof implementations
- Provides `Archive.*` namespace imports
- Registered in lakefile as `lean_lib Archive`

**Layer 2 - Logos/Examples/** (Re-export Shims):
- Contains thin wrapper files that re-export Archive modules
- Provides `Logos.Examples.*` namespace imports
- Example: `import Archive.ModalProofs` → `export Archive.ModalProofs`
- Documentation claims this is the "canonical import path"

**Evaluation**: This layered approach is confusing. The README says to use `Logos/Examples/` as "canonical" but Archive/ contains the actual code. This creates maintenance overhead without clear benefit.

### 4. The logos-original/ Subdirectory

**Purpose**: Historical preservation of original Logos documentation integrated into `/docs/` ecosystem.

**Contents**:
- 5 markdown files (research vision documents)
- Archived December 2025 as part of Spec 029
- Content integrated into:
  - `/docs/UserGuide/METHODOLOGY.md`
  - `/docs/Research/DUAL_VERIFICATION.md`
  - `/docs/Research/PROOF_LIBRARY_DESIGN.md`
  - `/docs/Research/LAYER_EXTENSIONS.md`

**Assessment**: This subdirectory is purely historical archive. Could be removed or moved to a more explicit archive location, but provides useful reference for documentation evolution.

### 5. Relationship to Task 353 (BimodalTest/)

Task 353 plans to move `LogosTest/Core/` to `BimodalTest/`. Archive/ is **independent** of this migration:
- Archive imports Bimodal (library), not BimodalTest (tests)
- No changes needed for Archive when task 353 completes

### 6. Documentation Path Issues

Multiple files reference outdated paths:

| File | Line | Outdated Reference | Should Be |
|------|------|-------------------|-----------|
| Archive/README.md | 86 | `Logos/Core/Theorems/Perpetuity.lean` | `Bimodal/Theorems/Perpetuity.lean` |
| Archive/README.md | 87 | `Logos/Core/Metalogic/Soundness.lean` | `Bimodal/Metalogic/Soundness.lean` |
| Archive/README.md | 88 | `Logos/Core/Automation/Tactics.lean` | `Bimodal/Automation/Tactics.lean` |
| BimodalProofStrategies.lean | 48 | `../Logos/Core/Theorems/Perpetuity.lean` | `../Bimodal/Theorems/Perpetuity.lean` |
| ModalProofStrategies.lean | 45 | `../Logos/Core/Theorems/Perpetuity.lean` | `../Bimodal/Theorems/Perpetuity.lean` |
| TemporalProofStrategies.lean | 50 | `../Logos/Core/Theorems/Perpetuity.lean` | `../Bimodal/Theorems/Perpetuity.lean` |

External Documentation (lower priority):
- `docs/Development/NONCOMPUTABLE_GUIDE.md`: Multiple `Logos.Core` references
- `docs/Development/MODULE_ORGANIZATION.md`: Multiple `Logos/Core` references

## Recommendations

### 1. Update Documentation Paths (High Priority)
Fix all `Logos/Core/` → `Bimodal/` path references in Archive/ files.

### 2. Clarify Re-Export Architecture (Medium Priority)
Options:
- **Option A (Recommended)**: Remove Logos/Examples/ shims entirely, make Archive/ the single canonical location. Simpler architecture.
- **Option B**: Keep Logos/Examples/ but update README to clarify the relationship clearly.

### 3. Consider Archive/ Rename (Low Priority)
Options:
- Keep as `Archive/` - established pattern from Mathlib
- Rename to `Examples/` - more descriptive but requires lakefile update
- Rename to `BimodalExamples/` - consistent with Bimodal naming

### 4. logos-original/ Handling (Low Priority)
Options:
- Keep in place (current state is acceptable)
- Move to `.claude/archive/logos-original/` for cleaner separation
- No action needed for task 354

## References

- Task 352 Summary: `.claude/specs/352_rename_logos_core_to_bimodal/summaries/implementation-summary-20260110.md`
- Archive README: `Archive/README.md`
- lakefile: `lakefile.lean` (line 29: `lean_lib Archive`)

## Next Steps

1. Update `Archive/README.md` learning path references (3 paths)
2. Update `Archive/*ProofStrategies.lean` docstring references (3 files)
3. Decide on Logos/Examples/ shim architecture
4. Optionally update docs/ files for consistency
