# Plan Summary: Context Directory Reorganization

**Version**: 001
**Complexity**: MODERATE
**Estimated Effort**: 3.5 hours

## Key Steps

1. **Preparation and Backup** (15 min)
   - Create backup of `.opencode/context/` directory
   - Document current state and file inventory

2. **Logic Domain Integration** (45 min)
   - Replace brief `metalogic-concepts.md` (85 lines) with comprehensive `soundness-completeness.md` (314 lines)
   - Replace brief `proof-theory-concepts.md` (47 lines) with comprehensive version (281 lines)
   - Move `task-semantics.md` (418 lines) to `logic/domain/`
   - Rename `semantics-concepts.md` to `kripke-semantics-overview.md` for clarity
   - Add cross-references between Kripke and task semantics files

3. **Type Theory Migration** (15 min)
   - Move `dependent-types.md` (369 lines) from `logic/type-theory/` to `lean4/domain/`

4. **Project Context Integration** (20 min)
   - Move `project-context.md` to `core/system/project-overview.md`
   - Move `project-structure.md` to `core/system/artifact-management.md`

5. **Reference Updates** (60 min)
   - Update 40 references across 14 files
   - Fix path inconsistencies in 6 command files
   - Remove duplicate entries in `logic/README.md`
   - Update index and documentation files

6. **Cleanup Empty Directories** (10 min)
   - Remove empty source directories

7. **Validation and Testing** (30 min)
   - Verify file integrity and line counts
   - Check for broken links
   - Test agent context loading
   - Verify content quality

## Dependencies

**Files to Update** (40 total references):
- Index/README files: 18 references
- Command files: 4 references
- Documentation files: 1 reference
- Specs files: 16 references

**Critical Dependencies**:
- `.opencode/context/logic/README.md` has duplicate entries to remove
- Multiple command files use old path format (need standardization)
- Cross-domain move of `dependent-types.md` requires careful path updates

## Success Criteria

1. All logic domain files consolidated in `logic/domain/`
2. Type theory file in `lean4/domain/`
3. Project context files in `core/system/`
4. All 40 references updated correctly
5. No broken links or path errors
6. Agent context loading works correctly
7. No information lost, clear organization

## Full Plan

See: `.opencode/specs/081_context_reorganization/plans/implementation-001.md`
