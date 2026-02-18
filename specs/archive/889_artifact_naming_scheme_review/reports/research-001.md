# Research Report: Task #889

**Task**: artifact_naming_scheme_review
**Date**: 2026-02-17
**Focus**: Review and standardize artifact naming across solo and team workflows

## Summary

The current artifact naming scheme has significant inconsistencies between solo execution (`/research N`) and team execution (`/research --team N`). Team workflows create intermediate artifacts (teammate findings) that do not include run/version numbers, making it difficult to correlate them with their synthesized outputs. This report identifies all inconsistencies and proposes a uniform naming scheme.

## Findings

### Current Artifact Naming Patterns

#### 1. Documented Standard Naming (from artifact-formats.md)

| Artifact Type | Path Pattern | Example |
|--------------|--------------|---------|
| Research Report | `specs/{N}_{SLUG}/reports/research-{NNN}.md` | `research-001.md` |
| Implementation Plan | `specs/{N}_{SLUG}/plans/implementation-{NNN}.md` | `implementation-001.md` |
| Implementation Summary | `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md` | `implementation-summary-20260117.md` |
| Error Report | `specs/{N}_{SLUG}/reports/error-report-{DATE}.md` | `error-report-20260117.md` |

#### 2. Team Workflow Artifacts (from team skill definitions)

| Workflow | Teammate Artifact | Synthesis Artifact |
|----------|------------------|-------------------|
| skill-team-research | `teammate-{letter}-findings.md` | `research-001.md` |
| skill-team-plan | `candidate-{letter}.md`, `risk-analysis.md` | `implementation-001.md` |
| skill-team-implement | `phase-{P}-results.md` | `implementation-summary-{DATE}.md` |
| Debug | `debug-{NNN}-hypothesis.md` | N/A |

#### 3. Observed Artifacts in Repository

The Glob search revealed inconsistent actual usage:

**Task 881** (team research, multiple runs):
- `teammate-a-findings.md` (no run number)
- `teammate-a-v2-findings.md` (version suffix)
- `teammate-a-v3-findings.md` (version suffix)
- `teammate-b-v4-findings.md` (version suffix)
- `research-001.md` through `research-011.md` (synthesized reports)

**Task 870** (team research, single run):
- `teammate-a-findings.md`
- `teammate-b-findings.md`
- `teammate-c-findings.md`
- `research-001.md` through `research-008.md`

### Identified Inconsistencies

#### Issue 1: Teammate Artifacts Lack Run Association

**Problem**: When `/research --team N` is run multiple times, teammate findings overwrite each other because they use a fixed name (`teammate-a-findings.md`) without a run/version number.

**Current Behavior**:
```
Run 1: teammate-a-findings.md -> synthesized to research-001.md
Run 2: teammate-a-findings.md (overwrites!) -> synthesized to research-002.md
```

**Impact**: No way to correlate which teammate findings contributed to which synthesized report.

#### Issue 2: Ad-hoc Version Suffixes

**Problem**: Task 881 shows ad-hoc versioning (`teammate-a-v2-findings.md`) was used to work around the overwrite issue, but this is not documented or consistent.

**Evidence**:
- `teammate-a-findings.md` (run 1)
- `teammate-a-v2-findings.md` (run 2)
- `teammate-a-v3-findings.md` (run 3)
- Missing `teammate-a-v4` but have `teammate-b-v4` (inconsistent)

#### Issue 3: Plan Candidate Artifacts

**Problem**: Team planning uses `candidate-{letter}.md` which also lacks run numbers.

**Current Pattern** (from skill-team-plan):
```
specs/{N}_{SLUG}/plans/candidate-a.md
specs/{N}_{SLUG}/plans/candidate-b.md
specs/{N}_{SLUG}/plans/risk-analysis.md
```

**Same Issue**: Multiple `/plan --team N` runs would overwrite candidate files.

#### Issue 4: Debug Artifacts Have Run Numbers But No Clear Association

**Problem**: Debug artifacts use `debug-{NNN}-hypothesis.md` which has a sequence number, but it's not clear which implementation run they belong to.

#### Issue 5: Phase Results Lack Run Association

**Problem**: Implementation phase results use `phase-{P}-results.md` without associating them with a particular implementation run or plan version.

### Analysis of Team vs Solo Workflows

| Aspect | Solo Workflow | Team Workflow | Inconsistency |
|--------|--------------|---------------|---------------|
| Research output | `research-{NNN}.md` | Teammate: `teammate-{letter}-findings.md`, Synthesis: `research-{NNN}.md` | Teammate artifacts lack run number |
| Planning output | `implementation-{NNN}.md` | Candidate: `candidate-{letter}.md`, Synthesis: `implementation-{NNN}.md` | Candidate artifacts lack run number |
| Implementation output | `implementation-summary-{DATE}.md` | `phase-{P}-results.md` + `implementation-summary-{DATE}.md` | Phase results lack run association |
| Debug output | N/A | `debug-{NNN}-hypothesis.md` | Has sequence but no run association |

### Root Cause Analysis

The naming inconsistency stems from the fact that:

1. **Solo workflows** were designed first with proper versioning (`{NNN}`)
2. **Team workflows** were added later and created new artifact types (teammate findings, candidates) without extending the versioning scheme
3. **No mechanism exists** to correlate teammate artifacts with their synthesized outputs

## Recommendations

### Proposed Uniform Naming Scheme

#### Pattern: Include Run Number in All Team Artifacts

**Research Team Artifacts**:
```
specs/{N}_{SLUG}/reports/
  research-{RRR}-teammate-{letter}-findings.md  # Run-scoped teammate output
  research-{RRR}.md                             # Synthesized report (unchanged)
```

**Planning Team Artifacts**:
```
specs/{N}_{SLUG}/plans/
  plan-{RRR}-candidate-{letter}.md              # Run-scoped candidate plans
  plan-{RRR}-risk-analysis.md                   # Run-scoped risk analysis
  implementation-{RRR}.md                        # Synthesized plan (unchanged)
```

**Implementation Team Artifacts**:
```
specs/{N}_{SLUG}/phases/
  impl-{RRR}-phase-{P}-results.md               # Run-scoped phase results
```

**Debug Artifacts**:
```
specs/{N}_{SLUG}/debug/
  impl-{RRR}-debug-{DDD}-hypothesis.md          # Run-scoped debug artifacts
  impl-{RRR}-debug-{DDD}-resolution.md
```

Where:
- `{RRR}` = 3-digit padded run number (001, 002, ...)
- `{letter}` = teammate identifier (a, b, c, d)
- `{P}` = phase number (unpadded)
- `{DDD}` = 3-digit debug cycle number

#### Benefits of Proposed Scheme

1. **Full Traceability**: Every teammate artifact is associated with its synthesis run
2. **No Overwrites**: Multiple runs create distinct artifact sets
3. **Backward Compatible**: Synthesis artifacts (`research-{NNN}.md`, `implementation-{NNN}.md`) keep existing names
4. **Consistent with Existing**: Uses same `{NNN}` padding convention already in use
5. **Sortable**: Files sort naturally by run number then by teammate/phase

### Alternative Approaches Considered

#### Alternative 1: Subdirectory per Run

```
specs/{N}_{SLUG}/reports/run-{RRR}/
  teammate-a-findings.md
  teammate-b-findings.md
specs/{N}_{SLUG}/reports/research-{RRR}.md  # (synthesis)
```

**Pros**: Cleaner grouping
**Cons**: More directory overhead, breaks existing flat structure expectation

#### Alternative 2: Timestamp Suffix

```
teammate-a-findings-20260217T143000Z.md
```

**Pros**: No collision possible
**Cons**: Not sortable by run, hard to correlate with synthesis (which uses run numbers)

**Recommendation**: Use the primary proposal (run number prefix) as it aligns best with existing conventions.

### Implementation Considerations

#### Files to Modify

1. **`.claude/rules/artifact-formats.md`**: Add team artifact naming conventions
2. **`.claude/skills/skill-team-research/SKILL.md`**: Update teammate prompts with run-scoped paths
3. **`.claude/skills/skill-team-plan/SKILL.md`**: Update candidate prompts with run-scoped paths
4. **`.claude/skills/skill-team-implement/SKILL.md`**: Update phase result paths
5. **`.claude/utils/team-wave-helpers.md`**: Update example prompts

#### Run Number Determination

Skills must track run numbers. Options:

1. **Count existing files**: `ls specs/{N}_{SLUG}/reports/research-*.md | wc -l` to determine next run number
2. **Store in state.json**: Add `research_run_count`, `plan_run_count` to project entry
3. **Use timestamp-based**: Generate from timestamp (less clean but simpler)

**Recommendation**: Count existing files (option 1) - most straightforward and self-maintaining.

#### Migration

Existing artifacts do not need renaming. The new scheme applies to future runs only. This ensures backward compatibility.

## Dependencies

- None external. This is a documentation and skill update task.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing patterns | Scripts/tools may assume old naming | Old synthesis artifacts keep same names; only new intermediate artifacts change |
| Complexity for teammates | Teammates must calculate run number | Lead provides run number in prompt; teammates just use it |
| Git history fragmentation | Many small changes to skill files | Bundle all changes in single implementation task |

## Appendix

### Search Queries Used

1. `Glob: specs/*/reports/*.md` - Found all report artifacts
2. `Glob: specs/*/plans/*.md` - Found all plan artifacts
3. `ls` on specific task directories - Examined actual file patterns
4. Read operations on all team skill files and artifact-formats.md

### References

- `.claude/rules/artifact-formats.md` - Current standard
- `.claude/skills/skill-team-research/SKILL.md` - Research team skill
- `.claude/skills/skill-team-plan/SKILL.md` - Planning team skill
- `.claude/skills/skill-team-implement/SKILL.md` - Implementation team skill
- `.claude/utils/team-wave-helpers.md` - Team coordination patterns
- `.claude/context/core/formats/return-metadata-file.md` - Metadata schema

## Next Steps

Run `/plan 889` to create an implementation plan for updating the naming scheme across all affected files.
