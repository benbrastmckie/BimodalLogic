# Implementation Plan: Fix README.md Broken Links

**Plan ID**: 001-readme-broken-links-fix-plan
**Created**: 2025-12-01
**Complexity**: 3
**Type**: Documentation Fix
**Status**: READY FOR IMPLEMENTATION

---

## Overview

This plan addresses 6 broken links in `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md` identified through comprehensive research analysis. The broken links prevent users from accessing critical documentation and legal information.

### Broken Links Summary

| # | Line | Link Type | Issue | Priority |
|---|------|-----------|-------|----------|
| 1 | 165 | LICENSE file | File does not exist | HIGH |
| 2 | 88 | Developer doc | Wrong path: `src/docs/` → `docs/development/` | HIGH |
| 3 | 89 | Developer doc | Wrong path: `src/docs/` → `docs/development/` | HIGH |
| 4 | 90 | Developer doc | Wrong path: `src/docs/` → `docs/development/` | HIGH |
| 5 | 91 | Developer doc | Wrong path: `src/docs/` → `docs/development/` | HIGH |
| 6 | 85 | API Reference | Wrong path: `doc/` → `.lake/build/doc/` | MEDIUM |

### Root Causes

1. **Documentation reorganization**: Developer standards moved from `src/docs/` to `docs/development/` but README not updated (affects 4 links)
2. **Missing LICENSE file**: README references LICENSE but file never created (affects 1 link)
3. **Lake default behavior**: API docs generate to `.lake/build/doc/` not `doc/` (affects 1 link)

### Success Criteria

- [ ] All 6 broken links are fixed
- [ ] LICENSE file exists with valid MIT License text
- [ ] All internal documentation links resolve correctly
- [ ] README.md passes markdown linting
- [ ] No new broken links introduced
- [ ] Changes verified with manual testing

---

## Phase 1: Create Missing LICENSE File

**Priority**: HIGH
**Estimated Time**: 5 minutes
**Risk Level**: LOW

### Overview
Create MIT License file in project root to satisfy legal requirements and fix broken link on line 165.

### Stage 1.1: Create LICENSE File with MIT License Text

**File to Create**: `/home/benjamin/Documents/Philosophy/Projects/Logos/LICENSE`

**Actions**:
1. Create new file `LICENSE` in project root
2. Add MIT License template text
3. Update copyright year to 2025
4. Update copyright holder name (currently placeholder)

**License Template**:
```
MIT License

Copyright (c) 2025 [Copyright Holder Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Verification**:
```bash
# Verify LICENSE file exists
test -f /home/benjamin/Documents/Philosophy/Projects/Logos/LICENSE && echo "✓ LICENSE exists" || echo "✗ LICENSE missing"

# Verify file is not empty
test -s /home/benjamin/Documents/Philosophy/Projects/Logos/LICENSE && echo "✓ LICENSE has content" || echo "✗ LICENSE is empty"
```

**Expected Outcome**:
- LICENSE file exists in project root
- File contains valid MIT License text
- Link on line 165 resolves correctly
- Legal compliance achieved

---

## Phase 2: Fix Developer Standards Links

**Priority**: HIGH
**Estimated Time**: 5 minutes
**Risk Level**: MINIMAL (path changes only)

### Overview
Update 4 broken links (lines 88-91) that incorrectly point to `src/docs/` directory. The files exist at `docs/development/` but README references wrong path.

### Stage 2.1: Fix LEAN Style Guide Link (Line 88)

**File to Edit**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`

**Change**:
```diff
-- [LEAN Style Guide](src/docs/LEAN_STYLE_GUIDE.md) - Coding conventions
+- [LEAN Style Guide](docs/development/LEAN_STYLE_GUIDE.md) - Coding conventions
```

**Line Number**: 88

**Verification**:
```bash
# Verify target file exists
test -f /home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/LEAN_STYLE_GUIDE.md && echo "✓ File exists" || echo "✗ File missing"
```

### Stage 2.2: Fix Module Organization Link (Line 89)

**File to Edit**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`

**Change**:
```diff
-- [Module Organization](src/docs/MODULE_ORGANIZATION.md) - Project structure
+- [Module Organization](docs/development/MODULE_ORGANIZATION.md) - Project structure
```

**Line Number**: 89

**Verification**:
```bash
# Verify target file exists
test -f /home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/MODULE_ORGANIZATION.md && echo "✓ File exists" || echo "✗ File missing"
```

### Stage 2.3: Fix Testing Standards Link (Line 90)

**File to Edit**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`

**Change**:
```diff
-- [Testing Standards](src/docs/TESTING_STANDARDS.md) - Test requirements
+- [Testing Standards](docs/development/TESTING_STANDARDS.md) - Test requirements
```

**Line Number**: 90

**Verification**:
```bash
# Verify target file exists
test -f /home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/TESTING_STANDARDS.md && echo "✓ File exists" || echo "✗ File missing"
```

### Stage 2.4: Fix Tactic Development Link (Line 91)

**File to Edit**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`

**Change**:
```diff
-- [Tactic Development](src/docs/TACTIC_DEVELOPMENT.md) - Custom tactics
+- [Tactic Development](docs/development/TACTIC_DEVELOPMENT.md) - Custom tactics
```

**Line Number**: 91

**Verification**:
```bash
# Verify target file exists
test -f /home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/TACTIC_DEVELOPMENT.md && echo "✓ File exists" || echo "✗ File missing"
```

**Expected Outcome**:
- All 4 developer standards links resolve correctly
- Links point to existing files in `docs/development/`
- No broken links in Developer Standards section

---

## Phase 3: Fix API Reference Link

**Priority**: MEDIUM
**Estimated Time**: 3 minutes
**Risk Level**: MINIMAL (documentation clarification)

### Overview
Update API Reference link (line 85) to point to correct Lake documentation output directory and clarify that docs must be generated.

### Stage 3.1: Update API Reference Link and Clarification Text

**File to Edit**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`

**Change**:
```diff
-- [API Reference](doc/) - Generated API documentation (run `lake build :docs`)
+- [API Reference](.lake/build/doc/) - Generated API documentation (run `lake build :docs` to generate)
```

**Line Number**: 85

**Rationale**:
- Lake generates documentation to `.lake/build/doc/` by default
- The `doc/` directory does not exist and is not created by Lake
- Added clarification "to generate" to make it clear docs are not pre-built

**Verification**:
```bash
# Generate documentation
cd /home/benjamin/Documents/Philosophy/Projects/Logos
lake build :docs

# Verify documentation was generated
test -d .lake/build/doc && echo "✓ API docs directory exists" || echo "✗ API docs directory missing"

# Check for index file
test -f .lake/build/doc/index.html && echo "✓ API docs generated" || echo "✗ API docs not generated"
```

**Expected Outcome**:
- Link points to actual Lake documentation output directory
- Users understand docs must be generated first
- Link resolves correctly after running `lake build :docs`

**Note**: The `.lake` directory is typically in `.gitignore`, so this link won't work on GitHub. This is standard for LEAN projects - API docs are generated locally.

---

## Phase 4: Verification and Testing

**Priority**: HIGH
**Estimated Time**: 5 minutes
**Risk Level**: MINIMAL

### Overview
Comprehensive testing to ensure all broken links are fixed and no new issues introduced.

### Stage 4.1: Verify All Fixed Links

**Verification Commands**:
```bash
cd /home/benjamin/Documents/Philosophy/Projects/Logos

# 1. Verify LICENSE exists
test -f LICENSE && echo "✓ LICENSE exists" || echo "✗ LICENSE missing"

# 2. Verify developer docs (all 4 files)
test -f docs/development/LEAN_STYLE_GUIDE.md && echo "✓ LEAN Style Guide" || echo "✗ Missing"
test -f docs/development/MODULE_ORGANIZATION.md && echo "✓ Module Organization" || echo "✗ Missing"
test -f docs/development/TESTING_STANDARDS.md && echo "✓ Testing Standards" || echo "✗ Missing"
test -f docs/development/TACTIC_DEVELOPMENT.md && echo "✓ Tactic Development" || echo "✗ Missing"

# 3. Generate and verify API docs
lake build :docs
test -d .lake/build/doc && echo "✓ API docs directory" || echo "✗ API docs missing"
test -f .lake/build/doc/index.html && echo "✓ API docs index" || echo "✗ Index missing"
```

### Stage 4.2: Verify No Broken Links Remain

**Manual Verification**:
1. Open README.md in markdown preview (VS Code, GitHub, or similar)
2. Click each link in the Documentation section (lines 80-85)
3. Click each link in the Developer Standards section (lines 88-91)
4. Click LICENSE link in License section (line 165)
5. Verify all links resolve correctly

**Automated Link Checking** (if available):
```bash
# Using markdown-link-check (if installed)
npx markdown-link-check README.md

# Or using custom script to extract and verify links
```

### Stage 4.3: Verify Existing Working Links Still Work

**Links to Verify** (should still work after changes):
- Line 80: `[Architecture Guide](docs/ARCHITECTURE.md)`
- Line 81: `[Logical Operators Glossary](docs/glossary/logical-operators.md)`
- Line 82: `[Tutorial](docs/TUTORIAL.md)`
- Line 83: `[Examples](docs/EXAMPLES.md)`
- Line 84: `[Contributing](docs/CONTRIBUTING.md)`
- Line 182: `[CONTRIBUTING.md](docs/CONTRIBUTING.md)`

**Verification**:
```bash
# Verify all existing working links still resolve
test -f docs/ARCHITECTURE.md && echo "✓ Architecture Guide" || echo "✗ Missing"
test -f docs/glossary/logical-operators.md && echo "✓ Operators Glossary" || echo "✗ Missing"
test -f docs/TUTORIAL.md && echo "✓ Tutorial" || echo "✗ Missing"
test -f docs/EXAMPLES.md && echo "✓ Examples" || echo "✗ Missing"
test -f docs/CONTRIBUTING.md && echo "✓ Contributing" || echo "✗ Missing"
```

### Stage 4.4: Final Quality Checks

**Quality Checks**:
```bash
# 1. Verify README renders correctly
# (Open in markdown viewer)

# 2. Check for markdown syntax errors
# (Use linter if available)

# 3. Verify no trailing whitespace added
git diff README.md

# 4. Verify changes are minimal and targeted
git diff --stat
```

**Expected Outcome**:
- All 6 previously broken links now work
- All 10 previously working links still work
- No new issues introduced
- README.md renders correctly
- Changes are clean and minimal

---

## Implementation Notes

### Prerequisites
- Git repository access
- Write permissions to Logos directory
- Lake build tools installed (for API docs verification)
- Markdown editor/viewer for testing

### Implementation Order
Execute phases in sequential order:
1. Phase 1: Create LICENSE (establishes legal foundation)
2. Phase 2: Fix developer docs links (highest visibility, quickest wins)
3. Phase 3: Fix API reference link (requires Lake understanding)
4. Phase 4: Comprehensive verification (ensures quality)

### Rollback Plan
All changes are documentation-only and easily reversible:
```bash
# If issues occur, revert changes
cd /home/benjamin/Documents/Philosophy/Projects/Logos
git checkout README.md
git clean -f LICENSE  # If LICENSE creation was problematic
```

### Risk Assessment

**Risk Level**: MINIMAL
- No code changes
- No build system modifications
- No test changes
- Documentation only
- Easy to revert
- No breaking changes

**Testing Impact**: NONE
- Changes do not affect any tests
- Build process unchanged
- No functional changes

---

## Success Metrics

### Quantitative Metrics
- [ ] 6 broken links fixed (100% of identified issues)
- [ ] 0 new broken links introduced
- [ ] 10 existing working links still functional
- [ ] 1 new file created (LICENSE)
- [ ] 5 lines modified in README.md

### Qualitative Metrics
- [ ] Professional appearance for new users
- [ ] All documentation accessible to developers
- [ ] Legal compliance achieved (LICENSE file)
- [ ] Clear path to API documentation
- [ ] Improved contributor onboarding experience

---

## Post-Implementation Tasks

### Optional Enhancements (Not in This Plan)

**Future Consideration - Not Required**:
1. Update placeholder GitHub URLs (lines 46, 176, 191) when repository is published
2. Add implementation status indicators to Project Structure section
3. Configure automated link checking in CI/CD pipeline
4. Consider creating `doc/` symlink to `.lake/build/doc/` for convenience

**Note**: These are suggestions from research but not included in this plan's scope.

---

## Research Reports Reference

This plan is based on comprehensive research documented in:
- `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/012_readme_broken_links_fix/reports/broken-links-analysis.md` - Detailed analysis of all 16 links
- `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/012_readme_broken_links_fix/reports/action-plan.md` - Implementation strategy
- `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/012_readme_broken_links_fix/reports/quick-fix-reference.md` - Quick reference for fixes

---

## Plan Statistics

- **Total Phases**: 4
- **Total Stages**: 11
- **Files to Create**: 1 (LICENSE)
- **Files to Edit**: 1 (README.md)
- **Lines to Change**: 5 (lines 85, 88, 89, 90, 91)
- **Estimated Total Time**: 18 minutes
- **Complexity**: 3 (Medium - requires understanding of path changes)
- **Risk**: Minimal (documentation only)

---

## Approval Status

**Ready for Implementation**: YES
**Requires Review**: NO (documentation-only changes)
**Breaking Changes**: NO
**Backwards Compatible**: YES

---

## End of Implementation Plan
