# Research Report: Task #984

**Task**: 984 - review_docs_remove_claude_dir_references
**Started**: 2026-03-16T10:00:00Z
**Completed**: 2026-03-16T10:15:00Z
**Effort**: Small (documentation review)
**Dependencies**: None
**Sources/Inputs**: Codebase analysis via Grep/Read
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- Found 7 documentation files in `docs/` with references to `.claude/` directory
- Identified 18 total references that need to be addressed
- One file (`docs/claude-directory-export.md`) is a special case - entire file should be removed or relocated
- Recommended approach: Remove/update references, preserve "Claude Code" product name mentions

## Context & Scope

The `.claude/` directory has been added to `.gitignore`, meaning it is no longer tracked in version control. All external documentation referencing this directory structure needs to be updated to:
1. Remove direct path references to `.claude/` directories and files
2. Remove instructions about the `.claude/` directory structure
3. Preserve references to "Claude Code" as the tool/product name

**Search Scope**: All markdown files in `docs/` directory and root-level markdown files.

## Findings

### File Inventory

| File | Reference Count | Category | Action Required |
|------|----------------|----------|-----------------|
| `docs/installation/CLAUDE_CODE.md` | 5 | Installation docs | Major revision |
| `docs/tts-stt-integration.md` | 4 | Feature docs | Moderate revision |
| `docs/project-info/MAINTENANCE.md` | 4 | Maintenance scripts | Remove section |
| `docs/development/DIRECTORY_README_STANDARD.md` | 3 | Standards | Remove broken links |
| `docs/README.md` | 1 | Documentation hub | Remove link |
| `docs/development/LEAN_STYLE_GUIDE.md` | 1 | Style guide | Remove broken link |
| `docs/claude-directory-export.md` | Entire file | Export snapshot | Remove file |

### Detailed Analysis by File

#### 1. docs/installation/CLAUDE_CODE.md

**Lines with references**:
- Line 145: `The ProofChecker repository includes an optional '.claude/' agent system...`
- Line 156: `The '.claude/' directory is already included in the ProofChecker repository...`
- Line 160: `ls -la .claude/`
- Line 171: `See [.claude/CLAUDE.md](../../.claude/CLAUDE.md)`
- Line 328: `[Agent System Docs](../../.claude/CLAUDE.md)`

**Analysis**: This file documents the optional agent system installation. Since `.claude/` is now gitignored, users who clone the repo will NOT have this directory. The entire "Set Up the Agent System" section (lines 143-182) needs to be either:
- Removed entirely, OR
- Replaced with instructions for how to optionally obtain/configure Claude Code settings

**Recommended Action**: Remove Section 4 "Set Up the Agent System" (lines 143-182) and the Agent System Docs link at line 328. The commands like `/task`, `/research` etc. are skill commands that work without the `.claude/` directory.

#### 2. docs/tts-stt-integration.md

**Lines with references**:
- Line 92: `The hook is configured in '.claude/settings.json'...`
- Line 265: `| '.claude/hooks/tts-notify.sh' | Claude Code TTS hook |`
- Line 287: `1. Edit '.claude/settings.json', remove TTS hook entry...`
- Line 288: `2. Delete '.claude/hooks/tts-notify.sh'`

**Analysis**: This file documents TTS/STT integration using Claude Code hooks. Since hooks are configured in `.claude/settings.json` which is no longer tracked, these instructions need updating.

**Recommended Action**:
- Update configuration instructions to reference the user's local Claude Code configuration
- Note that `.claude/hooks/` is user-specific and not version controlled
- Consider noting these are example configurations rather than repo-provided files

#### 3. docs/project-info/MAINTENANCE.md

**Lines with references**:
- Line 221: `find .claude/specs -name "*summary*.md" -o -name "*FINAL*.md"`
- Line 227: `find .claude/specs -name "*summary*.md" -exec du -h {} \; | sort -hr`
- Line 230: `find .claude/specs -name "*summary*.md" -mtime -7`
- Line 233: `find .claude/specs -name "*summary*.md" | wc -l`

**Analysis**: These are shell commands for finding spec summary files. The paths reference `.claude/specs` which doesn't exist - specs are actually in `specs/` (project root), not `.claude/specs`.

**Recommended Action**: This appears to be stale/incorrect documentation. Either:
- Update paths to `specs/` (the actual location), OR
- Remove the "Spec Summary Queries" section if outdated

#### 4. docs/development/DIRECTORY_README_STANDARD.md

**Lines with references**:
- Line 4: `**Applies To**: LEAN 4 project directories (not .claude/ system)`
- Line 183: `- [Code Standards](../../.claude/docs/reference/standards/code-standards.md)`
- Line 345: `(see [documentation-standards.md](../../.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard))`

**Analysis**: Contains both scoping mentions and broken links to `.claude/` documentation that no longer exists in the tracked repo.

**Recommended Action**:
- Line 4: Simplify to `**Applies To**: LEAN 4 project directories`
- Lines 183, 345: Remove these broken links or replace with alternative references

#### 5. docs/README.md

**Line with reference**:
- Line 5: `> **For AI-Assisted Development**: See [.claude/README.md](../.claude/README.md) for the Claude Code configuration and task management system.`

**Analysis**: This callout box directs users to `.claude/README.md` which is no longer tracked.

**Recommended Action**: Remove this callout box entirely, or replace with a note that Claude Code can be used with the project without referencing internal directories.

#### 6. docs/development/LEAN_STYLE_GUIDE.md

**Line with reference**:
- Line 188: `(see '.claude/docs/reference/standards/documentation-standards.md')`

**Analysis**: Broken link to documentation standards file that no longer exists in tracked repo.

**Recommended Action**: Remove the parenthetical reference or replace with an alternative reference if such standards exist elsewhere.

#### 7. docs/claude-directory-export.md

**Special Case**: This 75,519-line file is an export/snapshot of the entire `.claude/` directory contents. It was generated on 2026-02-09 and contains the full text of 239 files from `.claude/`.

**Analysis**: This file exists to provide a reference copy of the `.claude/` directory contents. With `.claude/` now gitignored, this file:
- May be intentionally preserved as documentation of the system architecture
- May be obsolete and should be removed
- Contains potentially sensitive configuration details

**Recommended Action**: Discuss with project owner. Options:
1. Remove file entirely (it's a 2MB+ file documenting internal tooling)
2. Keep as historical reference but add disclaimer about it being outdated
3. Move to a non-tracked location

### References to Preserve

The following references to "Claude Code" (the product) should NOT be removed:
- `docs/installation/CLAUDE_CODE.md` - The file name and product references
- Any mention of "Claude Code" as a tool (e.g., "Use Claude Code for automated installation")
- References to Claude Code documentation URLs (e.g., `https://docs.claude.com/claude-code`)

## Recommendations

### Priority 1: Critical Updates

1. **docs/README.md** - Remove the callout box (line 5-6)
2. **docs/installation/CLAUDE_CODE.md** - Remove Section 4 and the Agent System Docs link

### Priority 2: Moderate Updates

3. **docs/tts-stt-integration.md** - Update hook configuration instructions
4. **docs/development/DIRECTORY_README_STANDARD.md** - Remove broken links and simplify scoping

### Priority 3: Minor Updates

5. **docs/development/LEAN_STYLE_GUIDE.md** - Remove broken link
6. **docs/project-info/MAINTENANCE.md** - Fix or remove spec query section

### Priority 4: Decision Required

7. **docs/claude-directory-export.md** - Decide whether to remove, archive, or keep with disclaimer

## Decisions

1. All direct path references to `.claude/` directories should be removed
2. "Claude Code" product name mentions should be preserved
3. Broken links to `.claude/docs/` or similar should be removed entirely
4. The `claude-directory-export.md` file requires owner decision

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Users may expect agent system files | Add note that Claude Code works without repo-provided config |
| Documentation may become incomplete | Ensure Claude Code usage is still documented without internal paths |
| TTS/STT docs may be confusing | Clarify these are user-local configurations |

## Appendix

### Search Queries Used

```bash
# Find all docs with .claude/ references
grep -rn '\.claude/' docs/

# List affected files
grep -l '\.claude/' docs/**/*.md
```

### Summary Statistics

- **Total files affected**: 7
- **Total line references**: 18 (excluding claude-directory-export.md)
- **Estimated changes**: ~25 lines to remove/update
- **Special files**: 1 (claude-directory-export.md - 75K lines)
