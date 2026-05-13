# Implementation Summary: Merge Root Boneyard into Canonical Location

- **Task**: 132 - Merge root Boneyard into Theories/Bimodal/Boneyard and populate README
- **Status**: Implemented
- **Session**: sess_1778707221_475559
- **Completed**: 2026-05-13

## Changes Made

### Phase 1: Move Root Boneyard Files to Canonical Location
- Created `Theories/Bimodal/Boneyard/XuLemma321Legacy/` subdirectory
- `git mv Boneyard/XuLemma321.lean` to `Theories/Bimodal/Boneyard/XuLemma321Legacy/XuLemma321.lean`
- `git mv Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` to `Theories/Bimodal/Boneyard/NonBurgessSeed/PointInsertionLegacy.lean`
- Removed empty root `Boneyard/` directory
- Git correctly shows renames (not deletions + additions), preserving history

### Phase 2: Write README Documentation
- Created `Theories/Bimodal/Boneyard/XuLemma321Legacy/README.md` (44 lines)
  - Explains the blocked proof-by-contradiction approach for Xu 3.2.1(i)/(ii)
  - Documents BX9 unsoundness blocker under open guard semantics
  - Notes that task 115 proved Xu 3.2.1 via `dcs_neg_union_consistent`
  - Lists recovery options if the approach is ever revisited

- Populated `Theories/Bimodal/Boneyard/README.md` (220 lines)
  - Purpose section explaining the three roles of the Boneyard
  - Complete directory inventory table: all 15 subdirectories with file counts, line counts, origin, archival reason, and task reference
  - Archival reason taxonomy: unsound axioms, superseded approaches, structural dead ends, architectural incompatibility
  - Detailed descriptions of each subdirectory
  - Consultation guidance (when to consult vs ignore)
  - Task cross-reference table (12 tasks that created Boneyard content)
  - Git retrieval instructions

### Phase 3: Build Verification and Cleanup
- Confirmed no dangling import references to old Boneyard paths
- Confirmed root `Boneyard/` directory is fully removed
- Confirmed existing subdirectory READMEs are unmodified
- Build errors in `RRelation.lean` are pre-existing (from concurrent task 133 work), not from our changes. Our changes only affect files outside the build tree (Boneyard `.lean` files not imported by any module, `.md` files, and `specs/` files)

## Files Changed

| File | Action |
|------|--------|
| `Theories/Bimodal/Boneyard/XuLemma321Legacy/XuLemma321.lean` | Moved from `Boneyard/XuLemma321.lean` |
| `Theories/Bimodal/Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` | Moved from `Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` |
| `Theories/Bimodal/Boneyard/XuLemma321Legacy/README.md` | Created |
| `Theories/Bimodal/Boneyard/README.md` | Rewritten (was empty) |
| `Boneyard/` (root) | Removed |

## Post-Merge Statistics

| Metric | Before | After |
|--------|--------|-------|
| Root Boneyard files | 2 | 0 |
| Canonical Boneyard subdirectories | 13 | 15 |
| Canonical Boneyard .lean files | 45 | 47 |
| Canonical Boneyard lines | ~26,363 | ~26,579 |
| Boneyard READMEs | 7 (1 empty) | 8 (0 empty) |
