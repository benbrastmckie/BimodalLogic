# Action Plan: Fix README.md Broken Links

**Generated**: 2025-12-01
**Based on**: broken-links-analysis.md
**Priority**: HIGH - User-facing documentation contains broken links

---

## Quick Fix Summary

**6 broken links identified** requiring the following changes:

1. Create 1 new file (LICENSE)
2. Update 5 existing link paths in README.md

**Estimated Time**: 15 minutes
**Complexity**: Low
**Risk**: Minimal (documentation only)

---

## Detailed Action Items

### Action 1: Create LICENSE File
**Priority**: HIGH
**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/LICENSE`
**Issue**: README.md line 165 references LICENSE file that doesn't exist
**Action**: Create MIT License file in project root

**Implementation**:
```bash
# Create LICENSE file with MIT License text
# Template available at: https://opensource.org/licenses/MIT
```

**Testing**: Verify link works in GitHub/GitLab after creation

---

### Action 2: Fix Developer Standards Links (4 Links)
**Priority**: HIGH
**Files**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`
**Issue**: Lines 88-91 point to non-existent `src/docs/` directory
**Action**: Update all 4 links to correct `docs/development/` path

**Changes Required**:

#### Line 88
```diff
-- [LEAN Style Guide](src/docs/LEAN_STYLE_GUIDE.md) - Coding conventions
+- [LEAN Style Guide](docs/development/LEAN_STYLE_GUIDE.md) - Coding conventions
```

#### Line 89
```diff
-- [Module Organization](src/docs/MODULE_ORGANIZATION.md) - Project structure
+- [Module Organization](docs/development/MODULE_ORGANIZATION.md) - Project structure
```

#### Line 90
```diff
-- [Testing Standards](src/docs/TESTING_STANDARDS.md) - Test requirements
+- [Testing Standards](docs/development/TESTING_STANDARDS.md) - Test requirements
```

#### Line 91
```diff
-- [Tactic Development](src/docs/TACTIC_DEVELOPMENT.md) - Custom tactics
+- [Tactic Development](docs/development/TACTIC_DEVELOPMENT.md) - Custom tactics
```

**Testing**: Click each link to verify they resolve correctly

---

### Action 3: Fix API Reference Link
**Priority**: MEDIUM
**Files**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`
**Issue**: Line 85 points to non-existent `doc/` directory
**Action**: Update link and add clarification about documentation generation

**Current (Line 85)**:
```markdown
- [API Reference](doc/) - Generated API documentation (run `lake build :docs`)
```

**Recommended Change**:
```markdown
- [API Reference](.lake/build/doc/) - Generated API documentation (run `lake build :docs` to generate)
```

**Alternative Options**:
1. Create a `doc/` symlink to `.lake/build/doc/` (requires Git configuration)
2. Configure Lake to output docs to `doc/` instead of `.lake/build/doc/`
3. Add note that docs are generated on-demand and not committed to repo

**Recommended**: Option from "Recommended Change" above - point to actual output location

**Testing**:
1. Run `lake build :docs`
2. Verify documentation generates to `.lake/build/doc/`
3. Verify link resolves (note: won't work on GitHub as .lake is gitignored)

---

## Secondary Recommendations

### Update Placeholder URLs (Optional - before publication)
**Priority**: LOW (can be deferred until publication)
**Files**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`
**Lines**: 46, 176, 191
**Issue**: Contains placeholder `yourusername` in GitHub URLs
**Action**: Replace with actual repository URL when ready to publish

**Example**:
```diff
-git clone https://github.com/yourusername/Logos.git
+git clone https://github.com/actualusername/Logos.git
```

---

### Add Implementation Status Indicators (Optional - enhancement)
**Priority**: LOW (enhancement)
**Files**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`
**Section**: Project Structure (lines 93-155)
**Issue**: Structure lists many unimplemented files without status indicators
**Action**: Add visual indicators for implementation status

**Example Enhancement**:
```markdown
Logos/
├── Logos.lean           # Library root ✓
├── Logos/               # Main source directory
│   ├── Syntax/                 # Formula types, parsing, DSL
│   │   ├── Formula.lean        # Core formula inductive type ✓
│   │   ├── Context.lean        # Proof context ✓
│   │   └── DSL.lean            # Domain-specific syntax ⏳ PLANNED
│   ├── ProofSystem/            # Axioms and inference rules
│   │   ├── Axioms.lean         # TM axiom schemata ✓
│   │   ├── Rules.lean          # Inference rules ⏳ PLANNED
│   │   └── Derivation.lean     # Derivability relation ✓
```

**Legend**:
- ✓ Implemented
- 🚧 In Progress
- ⏳ Planned

---

## Testing Checklist

After implementing fixes, verify:

- [ ] LICENSE file exists and is valid MIT License
- [ ] All 4 developer standards links resolve correctly
- [ ] API Reference link points to correct location
- [ ] All links tested in local Markdown viewer
- [ ] All links tested in GitHub/GitLab preview (if applicable)
- [ ] No new broken links introduced
- [ ] Documentation builds successfully (`lake build :docs`)

---

## Implementation Order

**Recommended sequence**:

1. **Fix developer standards links** (Lines 88-91) - Quickest wins, most visible
2. **Create LICENSE file** - Required for legal compliance
3. **Fix API Reference link** (Line 85) - Requires understanding of Lake documentation output
4. **Update placeholder URLs** - Only when ready to publish
5. **Add status indicators** - Optional enhancement

---

## Rollback Plan

If issues occur:
- All changes are to documentation only (no code changes)
- Git revert available for all changes
- No breaking changes to functionality
- Safe to implement incrementally

---

## Success Criteria

✓ Zero broken internal links in README.md
✓ LICENSE file present and valid
✓ All developer documentation accessible
✓ Clear indication of where to find API docs
✓ Professional appearance for new users/contributors

---

## Notes

- This is documentation-only work (no code changes)
- Changes can be made incrementally
- No impact on build, test, or runtime
- Improves first impression for new users
- Facilitates contributor onboarding

---

## Related Files

- Analysis: `broken-links-analysis.md`
- Source: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`
- Target files verified in analysis report

---

## End of Action Plan
