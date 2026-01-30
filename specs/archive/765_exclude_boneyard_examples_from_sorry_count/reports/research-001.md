# Research Report: Task #765

**Task**: 765 - exclude_boneyard_examples_from_sorry_count
**Started**: 2026-01-29T22:00:00Z
**Completed**: 2026-01-29T22:15:00Z
**Effort**: ~30 minutes
**Priority**: High
**Dependencies**: None
**Sources/Inputs**: Codebase analysis (Grep, Read)
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- Found 3 files that compute sorry counts; only 1 requires modification (todo.md line 850)
- Review.md has an outdated reference (Logos/ instead of Theories/) that should be fixed
- State-management.md documentation needs policy update to describe exclusion
- New sorry count after exclusions: **77** (down from 322)

## Context & Scope

Task 765 requests excluding Boneyard/ and Examples/ directories from sorry count metrics to provide a more accurate representation of active technical debt. The current count (314-322) includes 242 sorries in Boneyard/ (deprecated/archived code) and 2 sorries in Examples/ (pedagogical code).

## Findings

### 1. Files That Compute Sorry Counts

| File | Line | Current Command | Status |
|------|------|-----------------|--------|
| `.claude/commands/todo.md` | 850 | `grep -r "sorry" Theories/ --include="*.lean" \| wc -l` | **Must update** |
| `.claude/commands/review.md` | 132 | `grep -r "sorry" Logos/ --include="*.lean" \| wc -l` | Outdated path (Logos/ doesn't exist) |
| `.claude/rules/state-management.md` | 121 | Documentation only | **Must update** description |

### 2. Sorry Count Breakdown

| Directory | Sorry Count | Classification |
|-----------|-------------|----------------|
| Theories/Bimodal/Boneyard/ | 242 | Deprecated/archived |
| Theories/Bimodal/Examples/ | 2 | Pedagogical |
| Theories/ (excluding above) | **77** | Active codebase |
| **Total** | 322 | -- |

Note: There's also a nested `Theories/Bimodal/Boneyard/Examples/` directory which is already excluded as part of Boneyard.

### 3. Recommended Command Changes

**todo.md line 850** - Current:
```bash
sorry_count=$(grep -r "sorry" Theories/ --include="*.lean" | wc -l)
```

**Recommended change:**
```bash
sorry_count=$(grep -r "sorry" Theories/ --include="*.lean" | grep -v "/Boneyard/" | grep -v "/Examples/" | wc -l)
```

**review.md line 132** - Current:
```bash
grep -r "sorry" Logos/ --include="*.lean" | wc -l
```

**Recommended change:**
```bash
grep -r "sorry" Theories/ --include="*.lean" | grep -v "/Boneyard/" | grep -v "/Examples/" | wc -l
```

### 4. Documentation Updates Needed

**state-management.md line 121** - Current description:
```
| `sorry_count` | number | Total `sorry` occurrences in Theories/ (from grep) |
```

**Recommended change:**
```
| `sorry_count` | number | Total `sorry` occurrences in Theories/ excluding Boneyard/ and Examples/ (from grep) |
```

### 5. Current Metric Values

| Location | Field | Current Value | New Value |
|----------|-------|---------------|-----------|
| specs/state.json | repository_health.sorry_count | 314 | 77 |
| specs/TODO.md | technical_debt.sorry_count | 314 | 77 |

### 6. Status Thresholds

The status determination in todo.md (line 877) uses these thresholds:
- `< 100` = "good"
- `< 300` = "manageable"
- `>= 300` = "concerning"

With the new count of 77, the status would change from **"concerning"** to **"good"**.

## Decisions

1. Use `grep -v` pattern to exclude directories (simpler than `--exclude-dir` which requires multiple flags)
2. Exclude by path pattern `/Boneyard/` and `/Examples/` to catch all nested instances
3. Update review.md to use Theories/ (the correct current directory) with same exclusions

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Future directories may need exclusion | Low | Document exclusion policy in state-management.md |
| Exclusion patterns too broad | Low | Using `/Boneyard/` not just `Boneyard` ensures only directory matches |
| Historical metrics incompatible | Medium | Note in commit that this is a policy change, not a bug fix |

## Implementation Checklist

1. **Edit `.claude/commands/todo.md` line 850**
   - Add `| grep -v "/Boneyard/" | grep -v "/Examples/"` to sorry_count command

2. **Edit `.claude/commands/review.md` line 132**
   - Change `Logos/` to `Theories/`
   - Add `| grep -v "/Boneyard/" | grep -v "/Examples/"`

3. **Edit `.claude/rules/state-management.md` line 121**
   - Update description to mention exclusions

4. **Update `specs/state.json`**
   - Change `repository_health.sorry_count` from 314 to 77
   - Change `repository_health.status` from "concerning" to "good"

5. **Update `specs/TODO.md` frontmatter**
   - Change `technical_debt.sorry_count` from 314 to 77
   - Change `technical_debt.status` from "concerning" to "good"

## Appendix

### Search Queries Used

```bash
# Find files with sorry_count references
grep -r "sorry_count\|sorry count\|grep.*sorry" .claude/ --include="*.md"

# Count current sorries
grep -r "sorry" Theories/ --include="*.lean" | wc -l                    # 322
grep -r "sorry" Theories/Bimodal/Boneyard/ --include="*.lean" | wc -l  # 242
grep -r "sorry" Theories/Bimodal/Examples/ --include="*.lean" | wc -l  # 2
grep -r "sorry" Theories/ --include="*.lean" | grep -v "/Boneyard/" | grep -v "/Examples/" | wc -l  # 77
```

### References

- `.claude/commands/todo.md` - Primary command that syncs repository metrics
- `.claude/commands/review.md` - Review command with outdated path reference
- `.claude/rules/state-management.md` - Documentation for repository_health schema

## Next Steps

Run `/plan 765` to create implementation plan with the changes documented above.
