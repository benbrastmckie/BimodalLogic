# Research Report: Task #782

**Task**: 782 - Revert Bimodal theory to before archival refactor
**Started**: 2026-01-30T12:00:00Z
**Completed**: 2026-01-30T12:30:00Z
**Effort**: Medium
**Priority**: High
**Dependencies**: None
**Sources/Inputs**: Git history analysis, codebase exploration
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The archival refactor began with task 487 (commit `e52e0fc4` on Jan 13, 2026) creating the Boneyard directory
- The shift to `semantic_weak_completeness` occurred in task 608 (commit `56344965` on Jan 19, 2026)
- The major structural change was task 654 (commit `2e46e80f` on Jan 20, 2026) archiving Metalogic_v2 to Boneyard
- Recommended reversion target: commit `08754f0b` (just before Boneyard creation)
- Strategy: Selective path reversion using `git checkout <commit> -- <paths>`

## Context & Scope

### What Went Wrong

The archival refactor was intended to produce a sorry-free proof leading to completeness and compactness. However:

1. **Wrong focus**: Attention shifted to `semantic_weak_completeness` instead of `weak_completeness`
2. **Architectural dead end**: The semantic approach avoided the truth bridge problem but created a different architectural limitation
3. **Documentation drift**: README files and documentation now emphasize the wrong approach

### What Needs to Be Reverted

| Path | Revert? | Reason |
|------|---------|--------|
| `Theories/Bimodal/Metalogic/` | YES | Current structure based on failed archival approach |
| `Theories/Bimodal/Boneyard/` | YES | Remove entirely - was mistake |
| `Theories/Bimodal/Metalogic_v2/` | RESTORE | Need to restore original location |
| `Theories/Bimodal/docs/` | PARTIAL | Some doc changes unrelated to archival |
| `.claude/` | NO | Preserve system changes |
| `specs/` | NO | Preserve task management |

## Findings

### Git History Timeline

| Date | Commit | Task | Description |
|------|--------|------|-------------|
| Jan 13 | `81ee02f1` | 450 | Last commit before archival work began |
| Jan 13 | `e52e0fc4` | 487 | Created Boneyard directory |
| Jan 19 | `56344965` | 608 | Added semantic_weak_completeness |
| Jan 20 | `2e46e80f` | 654 | Moved Metalogic_v2 to Boneyard, created new Metalogic/ |
| Jan 29 | `cae27b1e` | 659 | Added WeakCompleteness.lean to new Metalogic/ |
| Jan 30 | `2c30bf69` | 779 | Most recent Metalogic change |

### Pre-Archival State (commit `08754f0b`)

```
Theories/Bimodal/
├── Automation/
├── Examples/
├── Metalogic/           # Original Metalogic directory
│   ├── Completeness/
│   │   └── FiniteCanonicalModel.lean
│   ├── Decidability/
│   ├── Completeness.lean
│   ├── Decidability.lean
│   ├── DeductionTheorem.lean
│   ├── Soundness.lean
│   └── SoundnessLemmas.lean
├── ProofSystem/
├── Semantics/
├── Syntax/
├── Theorems/
├── docs/
└── latex/
```

**Note**: At this point there was NO Boneyard directory and NO Metalogic_v2 directory at the top level.

### Current State (after archival)

```
Theories/Bimodal/
├── Boneyard/            # Created by archival refactor
│   ├── Metalogic/
│   ├── Metalogic_v2/    # Moved from top level
│   ├── Metalogic_v3/
│   └── Metalogic_v4/
├── Metalogic/           # New structure (problematic)
│   ├── Algebraic/
│   ├── Completeness/
│   │   └── WeakCompleteness.lean  # Uses semantic approach
│   ├── Core/
│   ├── FMP/
│   ├── Representation/
│   ├── Soundness/
│   └── UnderDevelopment/
└── ...
```

### Key Commits to Consider

1. **Task 487** (`e52e0fc4`): Created Boneyard with documentation-only files
2. **Task 608** (`56344965`): Added `semantic_weak_completeness` to Metalogic_v2
3. **Task 654** (`2e46e80f`): Major restructure - moved Metalogic_v2 to Boneyard, created new Metalogic/
4. **Tasks 659-780**: Progressive build-out of new Metalogic structure

## Recommendations

### Option A: Full Path Reversion (RECOMMENDED)

Revert `Theories/Bimodal/` to commit `08754f0b` state, then manually forward-port any unrelated improvements.

```bash
# Step 1: Create backup branch
git checkout -b backup/pre-revert-782

# Step 2: Checkout pre-archival state for Bimodal
git checkout 08754f0b -- Theories/Bimodal/

# Step 3: Rebuild
lake build
```

**Pros**:
- Clean reversion to known-good state
- Removes all archival artifacts
- Restores original Metalogic structure

**Cons**:
- Loses any valid improvements made during archival period
- May need to re-apply some fixes manually

### Option B: Selective Reversion

Keep parts of current structure but revert specific files.

```bash
# Revert specific subdirectories
git checkout 08754f0b -- Theories/Bimodal/Metalogic/
rm -rf Theories/Bimodal/Boneyard/

# Restore Metalogic_v2 if needed from Boneyard
git checkout HEAD -- Theories/Bimodal/Boneyard/Metalogic_v2/
mv Theories/Bimodal/Boneyard/Metalogic_v2/ Theories/Bimodal/
```

**Pros**:
- More surgical approach
- Preserves recent Boneyard improvements

**Cons**:
- Complex import path fixes
- Risk of incomplete reversion

### Option C: Cherry-pick Reversion

Identify specific commits to revert in reverse chronological order.

```bash
# Revert in order (newest to oldest)
git revert 2c30bf69  # task 779
git revert 8eb0c64b  # task 780
# ... continue for all archival-related commits
```

**Pros**:
- Explicit history of reversion
- Each revert is atomic

**Cons**:
- Many commits to revert (~30+)
- Merge conflicts likely
- Tedious and error-prone

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Build failures after reversion | High | Run `lake build` immediately, fix imports |
| Lost valid improvements | Medium | Review commits 08754f0b..HEAD for non-archival changes |
| Import path breakage | Medium | Update affected files after reversion |
| Documentation inconsistency | Low | Update docs after code reversion |

### Files That May Need Manual Updates

1. `Theories/Bimodal/Bimodal.lean` - Main module imports
2. `Theories/Bimodal/Examples/Demo.lean` - May reference Boneyard paths
3. `Theories/Bimodal/Theorems/*.lean` - May have updated imports

## Decisions

1. **Reversion target**: Use commit `08754f0b` as the pre-archival baseline
2. **Strategy**: Option A (full path reversion) is recommended for cleanest result
3. **Preserve**: `.claude/` and `specs/` directories should NOT be reverted
4. **Documentation**: `Theories/Bimodal/docs/` should also be reverted to match code state

## Appendix

### Search Queries Used

```bash
git log --oneline --all --grep="archive" -20
git log --oneline --all --grep="Boneyard" -20
git log --oneline --all --grep="semantic_weak_completeness" -20
git log --oneline --all --grep="weak_completeness" -30
git log --oneline --all -- "Theories/Bimodal/Metalogic/" | head -60
git log --oneline --all -- "Theories/Bimodal/Boneyard/" | head -60
```

### Key Commit Hashes

| Commit | Description |
|--------|-------------|
| `08754f0b` | **TARGET**: Last commit before Boneyard creation |
| `e52e0fc4` | Task 487: Created Boneyard |
| `56344965` | Task 608: semantic_weak_completeness |
| `2e46e80f` | Task 654: Major restructure |
| `cae27b1e` | Task 659: WeakCompleteness.lean |

### Files to Restore

From `08754f0b`:
- `Theories/Bimodal/Metalogic/`
- `Theories/Bimodal/docs/`

### Files to Delete

- `Theories/Bimodal/Boneyard/` (entire directory)

---

*Generated by general-research-agent*
*Session: sess_1769794931_62b2ad*
