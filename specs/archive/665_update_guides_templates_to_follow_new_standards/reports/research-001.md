# Research Report: Task #665

**Task**: 665 - update_guides_templates_to_follow_new_standards
**Date**: 2026-01-21
**Focus**: Documentation standards compliance in docs/guides/ and docs/templates/

## Summary

Analyzed 8 files in `.claude/docs/guides/` and 3 files in `.claude/docs/templates/` against the documentation standards established in Task 661. Found 12 distinct violations requiring updates across 6 files.

## Findings

### Documentation Standards Reference

The standards from `.claude/context/core/standards/documentation-standards.md` (Task 661) require:

1. **No "Quick Start" sections** - These encourage users to skip context and understanding
2. **Present tense only** - No historical references, version history, or "what changed" content
3. **No version numbers/history** - Document current state only; history belongs in git
4. **kebab-case naming** - All files except README.md must use lowercase-kebab-case
5. **No emojis** - Unicode technical characters permitted, but no decorative emojis
6. **Valid path references** - All links must point to existing files

### Files Requiring Updates

#### 1. `.claude/docs/guides/user-installation.md` (431 lines)

**Violations Found**:

| Line | Issue | Type |
|------|-------|------|
| 5 | "A quick-start guide for installing Claude Code" | Quick Start reference |
| 25 | "### Quick Installation" | Quick Start section header |

**Required Changes**:
- Line 5: Change "A quick-start guide" to "Instructions for installing Claude Code"
- Line 25: Rename "### Quick Installation" to "### Installation" or "### Installing Claude Code"

#### 2. `.claude/docs/guides/copy-claude-directory.md` (326 lines)

**Violations Found**:

| Line | Issue | Type |
|------|-------|------|
| 313 | "### Quick Start with Commands" | Quick Start section header |

**Required Changes**:
- Line 313: Rename "### Quick Start with Commands" to "### Using the Commands" or "### Example Commands"

#### 3. `.claude/docs/templates/README.md` (361 lines)

**Violations Found**:

| Line | Issue | Type |
|------|-------|------|
| 339-344 | "### Migration History" section with version references | Historical content |
| 358 | "**Document Version**: 1.0" | Version number |
| 359 | "**Last Updated**: 2025-12-29" | Date/version tracking |
| 360 | "**Maintained By**: ProofChecker Development Team" | Metadata footer |

**Required Changes**:
- Remove lines 339-344 (Migration History section entirely)
- Remove lines 358-360 (version metadata footer)

#### 4. `.claude/docs/templates/agent-template.md` (392 lines)

**Violations Found**:

| Line | Issue | Type |
|------|-------|------|
| 389 | "**Template Version**: 1.0" | Version number |
| 390 | "**Last Updated**: 2025-12-29" | Date/version tracking |
| 391 | "**Maintained By**: ProofChecker Development Team" | Metadata footer |

**Required Changes**:
- Remove lines 389-391 (version metadata footer)

#### 5. `.claude/docs/templates/command-template.md` (124 lines)

**Violations Found**:

| Line | Issue | Type |
|------|-------|------|
| 121 | "**Template Version**: 1.0" | Version number |
| 122 | "**Last Updated**: 2025-12-29" | Date/version tracking |
| 123 | "**Maintained By**: ProofChecker Development Team" | Metadata footer |

**Required Changes**:
- Remove lines 121-123 (version metadata footer)

#### 6. `.claude/docs/guides/permission-configuration.md` (779 lines)

**Violations Found**:

| Line | Issue | Type |
|------|-------|------|
| 1-6 | Version/date header block | Version metadata |
| 752-758 | Related Documentation with broken path references | Invalid paths |
| 761-765 | "## Revision History" with version table | Historical content |

**Invalid Path References** (lines 752-758):
- `.claude/docs/guides/git-safety.md` - File does NOT exist
- `.claude/context/core/system/state-management.md` - Path incorrect (actual: `.claude/context/core/orchestration/state-management.md`)

**Required Changes**:
- Remove lines 1-6 (version header)
- Fix path `.claude/context/core/system/state-management.md` to `.claude/context/core/orchestration/state-management.md`
- Either remove reference to `git-safety.md` or fix if file exists elsewhere
- Remove lines 761-765 (Revision History section)

### Files Without Violations

The following files were analyzed and found compliant:

1. `.claude/docs/guides/creating-agents.md` - Present tense, no quick start, version footer exists (needs removal)
2. `.claude/docs/guides/creating-commands.md` - Present tense, no quick start, no version footer
3. `.claude/docs/guides/creating-skills.md` - Present tense, no quick start, version footer exists (needs removal)
4. `.claude/docs/guides/component-selection.md` - Present tense, no quick start, version footer exists (needs removal)
5. `.claude/docs/guides/context-loading-best-practices.md` - Has version header (needs removal)

**Additional Files with Version Footers** (minor violations):

| File | Lines |
|------|-------|
| creating-agents.md | 687-690 |
| creating-skills.md | 535-537 |
| component-selection.md | 401-403 |
| context-loading-best-practices.md | 1-6 (header) |

### Path Reference Issues

**References to Non-Existent Paths**:

| File | Line | Invalid Path | Status |
|------|------|--------------|--------|
| permission-configuration.md | 755 | `.claude/docs/guides/git-safety.md` | Does not exist |
| permission-configuration.md | 757 | `.claude/context/core/system/state-management.md` | Wrong path |
| copy-claude-directory.md | 182 | `.claude/specs/` | specs/ is at project root, not .claude/ |
| user-installation.md | 166-167 | `../commands/README.md` | commands/ directory does not exist |
| user-installation.md | 179 | `../commands/README.md` | commands/ directory does not exist |
| templates/README.md | 14 | `../guides/creating-commands.md` | Valid |
| templates/README.md | 339-343 | Migration documentation paths | Should be removed |

## Recommendations

### Priority 1: Quick Start Sections (Explicit Task Requirement)

1. **user-installation.md**: Remove "quick-start" language from line 5, rename "Quick Installation" header
2. **copy-claude-directory.md**: Rename "Quick Start with Commands" section header

### Priority 2: Version Numbers and History (Explicit Task Requirement)

1. **templates/README.md**: Remove version footer (lines 358-360) and Migration History section (339-344)
2. **agent-template.md**: Remove version footer (lines 389-391)
3. **command-template.md**: Remove version footer (lines 121-123)
4. **permission-configuration.md**: Remove version header (lines 1-6) and Revision History (761-765)
5. **context-loading-best-practices.md**: Remove version header (lines 1-6)
6. **creating-agents.md**: Remove version footer (lines 687-690)
7. **creating-skills.md**: Remove version footer (lines 535-537)
8. **component-selection.md**: Remove version footer (lines 401-403)

### Priority 3: Invalid Path References

1. **permission-configuration.md**: Fix state-management.md path, remove or fix git-safety.md reference
2. **user-installation.md**: References to `../commands/README.md` need to be fixed (commands/ directory doesn't exist)
3. **copy-claude-directory.md**: Reference to `.claude/specs/` is incorrect (specs is at project root)

### Priority 4: Present Tense Review

All files reviewed use present tense appropriately. No violations found in the main content.

## Dependencies

- **Task 661 (COMPLETED)**: Created documentation-standards.md
- **Task 662 (COMPLETED)**: Consolidated docs/README.md, removed duplicated content

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken links after path updates | Users can't navigate | Verify all new paths before committing |
| Removing version info loses traceability | Difficult to track changes | Git history provides traceability |
| Quick Start removal may confuse users | Longer onboarding | Structure remaining content progressively |

## Success Criteria

- [ ] No "Quick Start" or "quick-start" text in any guide/template file
- [ ] No version numbers or "Last Updated" dates in any file
- [ ] No "Revision History" or "Migration History" sections
- [ ] All path references point to existing files
- [ ] Present tense used throughout (already compliant)

## Appendix

### Search Queries Used

- `grep -r "Quick Start\|quick start\|quick-start" .claude/docs/guides/`
- `grep -r "Version\|Last Updated\|Maintained By" .claude/docs/templates/`
- `grep -r "Revision History\|Migration History" .claude/docs/`
- Path existence checks via `ls` commands

### Files Analyzed

**guides/** (8 files):
- user-installation.md (431 lines)
- copy-claude-directory.md (326 lines)
- creating-agents.md (690 lines)
- creating-commands.md (330 lines)
- creating-skills.md (538 lines)
- component-selection.md (404 lines)
- context-loading-best-practices.md (897 lines)
- permission-configuration.md (779 lines)

**templates/** (3 files):
- README.md (361 lines)
- agent-template.md (392 lines)
- command-template.md (124 lines)

## Next Steps

Run `/plan 665` to create an implementation plan addressing:
1. Quick Start section renaming/removal
2. Version footer/header removal
3. Path reference fixes
