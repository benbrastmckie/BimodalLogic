# Implementation Plan: Task #819

- **Task**: 819 - create_sorry_debt_policy_context_file
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/819_create_sorry_debt_policy_context_file/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a comprehensive sorry debt policy context file at `.claude/context/project/lean4/standards/sorry-debt-policy.md` that formalizes the project's approach to handling `sorry` statements in Lean 4 proofs. The policy will establish sorries as mathematical debt, define remediation paths, document the discovery protocol for agents encountering sorries, and reference the project's Boneyard locations.

### Research Integration

The research report (research-001.md) identified:
- Two Boneyard locations with documented deprecation patterns
- Existing sorry tracking via SORRY_REGISTRY.md and repository_health metrics
- Four sorry categories: construction assumptions, development placeholders, documentation examples, fundamental obstacles
- Current minimal policy in proof-conventions-lean.md (lines 32-35) to be expanded

## Goals & Non-Goals

**Goals**:
- Establish clear philosophy: sorries are mathematical debt requiring remediation
- Define three remediation paths with concrete guidance for each
- Document discovery protocol for agents encountering existing sorries
- Reference Boneyard locations with archival requirements
- Integrate with existing metrics (sorry_count thresholds, exclusion patterns)
- Follow existing context file patterns (similar structure to proof-conventions-lean.md)

**Non-Goals**:
- Modifying SORRY_REGISTRY.md (reference only)
- Changing proof-conventions-lean.md (this supplements, not replaces)
- Implementing automated sorry detection tools
- Tracking individual sorries (that's SORRY_REGISTRY.md's role)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Policy conflicts with existing conventions | Medium | Low | Cross-reference and align with proof-conventions-lean.md |
| Over-documentation making policy hard to follow | Medium | Medium | Keep under 150 lines; use clear sections |
| Boneyard paths becoming stale | Low | Low | Document pattern not specific subdirectories |

## Implementation Phases

### Phase 1: Create Policy File Structure [NOT STARTED]

**Goal**: Create the sorry-debt-policy.md file with header and cross-references

**Tasks**:
- [ ] Create file at `.claude/context/project/lean4/standards/sorry-debt-policy.md`
- [ ] Add header with overview explaining purpose
- [ ] Add cross-references section linking to:
  - `proof-conventions-lean.md` (minimal sorry policy)
  - `SORRY_REGISTRY.md` (tracking mechanism)
  - Boneyard README documentation

**Timing**: 15 minutes

**Files to create**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- File exists at correct path
- Header follows existing context file patterns

---

### Phase 2: Write Philosophy and Categories Sections [NOT STARTED]

**Goal**: Document the core philosophy and sorry categorization

**Tasks**:
- [ ] Write "Philosophy" section:
  - Sorries as mathematical debt (not technical debt)
  - Never acceptable in publication-ready proofs
  - Each sorry represents an unverified mathematical claim
- [ ] Write "Sorry Categories" section with four categories:
  - Construction assumptions (accepted, documented)
  - Development placeholders (temporary, must resolve)
  - Documentation examples (intentional, excluded from counts)
  - Fundamental obstacles (Boneyard candidates)
- [ ] Add concrete examples from codebase for each category

**Timing**: 25 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- All four categories documented with examples
- Philosophy section distinguishes mathematical from technical debt

---

### Phase 3: Write Remediation Paths Section [NOT STARTED]

**Goal**: Document the three remediation paths with decision criteria

**Tasks**:
- [ ] Write "Remediation Paths" section with three subsections:
  - Path A: Proof Completion - filling the gap with valid proof
  - Path B: Architectural Refactoring - changing approach to avoid the gap
  - Path C: Boneyard Archival - archiving fundamentally flawed code
- [ ] Include decision criteria for choosing each path
- [ ] Add guidance for partial progress (when to accept sorry temporarily)

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- Each path has clear criteria and steps
- Decision tree is actionable

---

### Phase 4: Write Discovery Protocol and Boneyard References [NOT STARTED]

**Goal**: Document what agents should do when encountering sorries

**Tasks**:
- [ ] Write "Discovery Protocol" section with step-by-step guidance:
  1. Check SORRY_REGISTRY.md for context
  2. Assess category (construction assumption vs fixable gap)
  3. Decision tree for action based on category
  4. Flagging process for fundamental obstacles
- [ ] Write "Boneyard References" section:
  - Primary: `Theories/Bimodal/Boneyard/`
  - Overflow: `Boneyard/`
  - README requirements for archived code
  - Link to existing Boneyard README as exemplar
- [ ] Write "Metrics Integration" section:
  - sorry_count computation (exclusions for Boneyard, Examples)
  - Status thresholds (good <100, manageable <300, concerning >=300)
  - Escalation triggers

**Timing**: 25 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- Discovery protocol is step-by-step actionable
- Boneyard references include README requirements
- Metrics match existing /todo command patterns

---

### Phase 5: Finalize and Verify [NOT STARTED]

**Goal**: Review, refine, and verify the complete policy file

**Tasks**:
- [ ] Review entire file for consistency and completeness
- [ ] Ensure file is under 150 lines for readability
- [ ] Verify all cross-references are valid paths
- [ ] Check alignment with proof-conventions-lean.md (no conflicts)
- [ ] Add usage checklist at end (following proof-conventions-lean.md pattern)

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- File builds valid markdown
- All referenced files exist
- Checklist provides actionable items

## Testing & Validation

- [ ] File exists at `.claude/context/project/lean4/standards/sorry-debt-policy.md`
- [ ] File length is under 150 lines
- [ ] All four sorry categories are documented with examples
- [ ] Three remediation paths are defined with decision criteria
- [ ] Discovery protocol has clear step-by-step guidance
- [ ] Boneyard references include both locations and README requirements
- [ ] Metrics section matches existing /todo patterns
- [ ] Cross-references point to valid files
- [ ] No conflicts with existing proof-conventions-lean.md

## Artifacts & Outputs

- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - Main policy file
- `specs/819_create_sorry_debt_policy_context_file/summaries/implementation-summary-YYYYMMDD.md` - Summary on completion

## Rollback/Contingency

If the policy introduces conflicts with existing conventions:
1. Remove the file: `rm .claude/context/project/lean4/standards/sorry-debt-policy.md`
2. Revert any cross-reference additions to other files
3. Task state remains valid (only artifact removed)
