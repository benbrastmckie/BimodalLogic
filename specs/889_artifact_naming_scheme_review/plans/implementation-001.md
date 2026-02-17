# Implementation Plan: Task #889

- **Task**: 889 - artifact_naming_scheme_review
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/889_artifact_naming_scheme_review/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Implement a uniform artifact naming scheme for team workflows that includes run numbers in all intermediate artifacts. The primary change is prefixing teammate artifacts with the run number they belong to (e.g., `research-001-teammate-a-findings.md` instead of `teammate-a-findings.md`). This enables correlation between teammate findings and their synthesized outputs across multiple runs while preserving backward compatibility with existing synthesis artifacts.

### Research Integration

Key findings from research-001.md:
- Teammate artifacts (findings, candidates, phase results) lack run association
- Ad-hoc versioning (teammate-a-v2-findings.md) was used as workaround
- Synthesis artifacts (research-NNN.md, implementation-NNN.md) already have proper numbering
- Proposed scheme: `{artifact-type}-{RRR}-{teammate-component}.md`

## Goals & Non-Goals

**Goals**:
- Uniform naming for all team artifacts with run number association
- Full traceability from teammate findings to synthesized reports
- No overwrites when running same command multiple times
- Clear documentation of the naming convention

**Non-Goals**:
- Renaming existing artifacts (backward compatibility - new scheme only applies to future runs)
- Changing synthesis artifact names (research-NNN.md stays as-is)
- Implementing automatic cleanup of old artifacts

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Skills referencing old paths | Medium | Low | Update all skills atomically in single commit |
| Documentation lag | Low | Medium | Update artifact-formats.md in same commit as skills |
| Teammates not receiving run number | High | Low | Lead passes run number explicitly in prompt |

## Implementation Phases

### Phase 1: Update artifact-formats.md with Team Naming Conventions [NOT STARTED]

- **Dependencies:** None
- **Goal**: Document the uniform naming scheme in the canonical artifact formats reference

**Tasks**:
- [ ] Add new "Team Artifacts" section to artifact-formats.md
- [ ] Document run-scoped naming patterns for each artifact type
- [ ] Add examples showing correlation between teammate and synthesis artifacts
- [ ] Document run number determination method (count existing synthesis files)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/rules/artifact-formats.md` - Add Team Artifacts section

**Verification**:
- artifact-formats.md contains complete team naming scheme documentation
- Examples show research-001-teammate-a-findings.md -> research-001.md correlation

---

### Phase 2: Update skill-team-research Naming [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal**: Update research skill to use run-scoped teammate artifact names

**Tasks**:
- [ ] Add run number calculation (count existing research-*.md files + 1)
- [ ] Update teammate prompts to use `research-{RRR}-teammate-{letter}-findings.md`
- [ ] Update Stage 7 (collect results) to use new paths
- [ ] Update Stage 12 (git commit) to stage new paths

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-team-research/SKILL.md` - Update artifact paths in stages 5, 7, 12

**Verification**:
- Skill references run-scoped paths in all teammate prompts
- Collection logic uses matching paths
- Git staging includes correct directory paths

---

### Phase 3: Update skill-team-plan Naming [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal**: Update planning skill to use run-scoped candidate artifact names

**Tasks**:
- [ ] Add run number calculation (count existing implementation-*.md files + 1)
- [ ] Update teammate prompts to use `plan-{RRR}-candidate-{letter}.md`
- [ ] Update risk analysis path to `plan-{RRR}-risk-analysis.md`
- [ ] Update Stage 8 (collect candidates) to use new paths

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-team-plan/SKILL.md` - Update artifact paths in stages 6, 8

**Verification**:
- Skill references run-scoped paths for all candidate plans
- Risk analysis uses matching run number
- Collection logic uses matching paths

---

### Phase 4: Update skill-team-implement Naming [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal**: Update implementation skill to use run-scoped phase result and debug artifact names

**Tasks**:
- [ ] Determine implementation run number (from plan version or session)
- [ ] Update phase result paths to `impl-{RRR}-phase-{P}-results.md`
- [ ] Update debug artifact paths to `impl-{RRR}-debug-{DDD}-{type}.md`
- [ ] Update debug directory organization

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Update artifact paths in stages 6, 8, and debug sections

**Verification**:
- Phase results include implementation run number
- Debug artifacts correlate with implementation run
- Directory structure follows new pattern

---

### Phase 5: Update team-wave-helpers.md Templates [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3, Phase 4
- **Goal**: Update reusable prompt templates to reflect new naming scheme

**Tasks**:
- [ ] Update Wave Spawning Pattern section with run-scoped paths
- [ ] Update Collect Teammate Results pattern
- [ ] Update Lean Teammate Prompt Templates
- [ ] Update Successor Teammate patterns (if applicable)
- [ ] Add run number passing pattern documentation

**Timing**: 30 minutes

**Files to modify**:
- `.claude/utils/team-wave-helpers.md` - Update all output path references

**Verification**:
- All template examples use run-scoped naming
- Collect patterns match new paths
- Documentation explains run number determination

---

### Phase 6: Verification and Testing [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal**: Verify consistency across all modified files and document the change

**Tasks**:
- [ ] Cross-check all artifact paths between skills and helpers
- [ ] Verify artifact-formats.md examples match skill implementations
- [ ] Ensure backward compatibility note is clear
- [ ] Verify git staging patterns in skills are correct

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- All path patterns are consistent across files
- Documentation is complete and accurate
- No references to old naming scheme remain in active code

---

## Testing & Validation

- [ ] Grep for old artifact patterns (`teammate-{letter}-findings.md` without run prefix) in skills
- [ ] Verify each skill has run number calculation before spawning teammates
- [ ] Confirm artifact-formats.md examples are syntactically correct
- [ ] Review commit diff for completeness

## Artifacts & Outputs

- `.claude/rules/artifact-formats.md` - Updated with Team Artifacts section
- `.claude/skills/skill-team-research/SKILL.md` - Updated teammate paths
- `.claude/skills/skill-team-plan/SKILL.md` - Updated candidate paths
- `.claude/skills/skill-team-implement/SKILL.md` - Updated phase/debug paths
- `.claude/utils/team-wave-helpers.md` - Updated templates
- `specs/889_artifact_naming_scheme_review/summaries/implementation-summary-{DATE}.md` - Final summary

## Rollback/Contingency

If implementation causes issues:
1. Revert the commit (all changes are in .claude/ directory)
2. Team commands will continue to work with old naming
3. Old artifacts remain accessible
4. No data migration needed since this is documentation/code change only
