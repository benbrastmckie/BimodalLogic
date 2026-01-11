# Research Report: Task #389

**Task**: Standardize {NNN} number format across documentation
**Date**: 2026-01-11
**Focus**: Identify all inconsistent placeholder usages and define standardization rules

## Summary

Research reveals widespread inconsistency in placeholder naming conventions across the .claude/ documentation. Two distinct numbering contexts exist: (1) task numbers in paths/references using unpadded format like `389` and (2) artifact version numbers using 3-digit padded format like `001`. The documentation uses `{N}` ambiguously for both contexts, while `{NNN}` is correctly used for artifact versioning but inconsistently applied.

## Findings

### 1. Two Distinct Numbering Contexts

The codebase has two different numbering conventions that should use different placeholders:

| Context | Actual Format | Current Placeholder | Recommended |
|---------|---------------|---------------------|-------------|
| Task numbers (dirs, commits, refs) | Unpadded (e.g., `389`) | `{N}` | Keep `{N}` |
| Artifact versions (reports, plans) | 3-digit padded (e.g., `001`) | `{NNN}` or `{N}` | Standardize to `{NNN}` |

### 2. Files Using `{N}` Correctly (Task Numbers)

These 20+ files correctly use `{N}` for task number references:
- `.claude/rules/git-workflow.md` - commit message templates (`task {N}: ...`)
- `.claude/commands/*.md` - all command files use `{N}` for task references
- `.claude/CLAUDE.md` - commit conventions, task paths
- `.claude/skills/skill-git-workflow/SKILL.md` - commit templates

### 3. Files Using `{NNN}` Correctly (Artifact Versions)

These files correctly use `{NNN}` for artifact versioning:
- `.claude/rules/artifact-formats.md` (partial) - `research-{NNN}.md`, `implementation-{NNN}.md`
- `.claude/skills/skill-status-sync/SKILL.md` - artifact link templates
- `.claude/commands/meta.md` - task counts and output formatting

### 4. Inconsistent Usage Patterns

**Problem A: artifact-formats.md mixes both**
```markdown
# Line 9 - directory uses {N}
**Location**: `.claude/specs/{N}_{SLUG}/reports/research-{NNN}.md`

# Line 43 - same pattern
**Location**: `.claude/specs/{N}_{SLUG}/plans/implementation-{NNN}.md`
```
This is actually **correct** - task numbers are unpadded, artifact versions are padded.

**Problem B: {NNN} used for non-version counts**
In `.claude/commands/meta.md`:
```markdown
Commands: {NNN}
Skills: {NNN}
Tasks to Create ({NNN} total)
```
These are counts, not padded version numbers. Should use `{N}` or a different placeholder.

**Problem C: Task 388 description uses {N} for directory paths**
```markdown
.claude/specs/{N}_{SLUG}/
```
This is correct for unpadded task numbers, but was flagged as inconsistent with `{NNN}`.

### 5. Actual Directory and File Naming Analysis

Examined actual artifacts:
- **Directories**: `389_standardize_nnn_number_format/` - unpadded task number
- **Report files**: `research-001.md` - 3-digit padded version
- **Plan files**: `implementation-002.md` - 3-digit padded version
- **Summaries**: `implementation-summary-20260111.md` - date-based, no version padding

### 6. Count of Occurrences

| Pattern | Occurrences | Files |
|---------|-------------|-------|
| `{N}` for task numbers | 180+ | 35+ |
| `{N}` for counts/generic | 60+ | 15+ |
| `{NNN}` for artifact versions | 70+ | 20+ |
| `{NNN}` for counts | 40+ | 5+ |

### 7. The Real Issue

The user's concern about "failing to use consistent padding has caused issues" likely refers to:
1. Confusion between when to use padded vs unpadded formats
2. Template placeholders not clearly indicating which format to use
3. New contributors misunderstanding the conventions

## Recommendations

### 1. Establish Clear Placeholder Convention

Define three distinct placeholders:
- `{N}` - Unpadded numbers (task numbers, counts, generic)
- `{NNN}` - 3-digit padded numbers (artifact version numbers only)
- `{P}` - Phase numbers (already in use)

### 2. Update Documentation to Clarify Usage

Add a section to `artifact-formats.md` explaining:
```markdown
## Placeholder Conventions

| Placeholder | Format | Usage |
|-------------|--------|-------|
| `{N}` | Unpadded (e.g., `389`) | Task numbers, counts |
| `{NNN}` | Padded (e.g., `001`) | Artifact versions |
| `{P}` | Unpadded (e.g., `1`) | Phase numbers |
```

### 3. Audit and Fix Misuses

Files needing updates:
1. `.claude/commands/meta.md` - change `{NNN}` to `{N}` for counts
2. Add clarifying comments where context is ambiguous

### 4. Implementation Priority

**High Priority** (affects command behavior):
- `artifact-formats.md` - add placeholder documentation section

**Medium Priority** (documentation clarity):
- `meta.md` - fix count placeholders
- Add comments to command files clarifying placeholder meaning

**Low Priority** (reference documentation):
- Context files and templates
- Historical research/plan artifacts (leave as-is)

## References

- `.claude/rules/artifact-formats.md` - current artifact format rules
- `.claude/specs/385_refactor_meta_command_task_creation/plans/implementation-002.md` - recognized this issue
- Actual directory/file naming in `.claude/specs/`

## Next Steps

1. Create implementation plan with phased approach
2. Start with high-priority files (artifact-formats.md)
3. Add explicit placeholder convention documentation
4. Update meta.md count placeholders
5. Leave historical artifacts unchanged
