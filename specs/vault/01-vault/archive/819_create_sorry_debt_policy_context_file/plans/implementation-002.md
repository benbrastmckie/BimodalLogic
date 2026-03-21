# Implementation Plan: Task #819

- **Task**: 819 - create_sorry_debt_policy_context_file
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/819_create_sorry_debt_policy_context_file/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Previous Version**: plans/implementation-001.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Notes

**v002 (from v001)**: Added critical concept of transitive sorry inheritance. Sorries propagate through dependency chains, meaning a theorem is only truly sorry-free if none of its dependencies contain sorries. Publication-ready proofs require transitive sorry-freedom. This changes the philosophy section and adds a new "Transitive Inheritance" section.

## Overview

Create a comprehensive sorry debt policy context file at `.claude/context/project/lean4/standards/sorry-debt-policy.md` that formalizes the project's approach to handling `sorry` statements in Lean 4 proofs. The policy will establish sorries as mathematical debt with transitive inheritance, define remediation paths, document the discovery protocol for agents encountering sorries, and reference the project's Boneyard locations.

### Research Integration

The research report (research-001.md) identified:
- Two Boneyard locations with documented deprecation patterns
- Existing sorry tracking via SORRY_REGISTRY.md and repository_health metrics
- Four sorry categories: construction assumptions, development placeholders, documentation examples, fundamental obstacles
- Current minimal policy in proof-conventions-lean.md (lines 32-35) to be expanded

### Key Clarification (v002)

**Transitive Sorry Inheritance**: A theorem that depends on another theorem containing a sorry also inherits that sorry. This means:
- Direct sorries: The theorem itself contains `sorry`
- Inherited sorries: The theorem depends on a proof that contains (or inherits) `sorry`
- Truly sorry-free: A theorem with no direct or inherited sorries
- Publication requirement: Only truly sorry-free theorems are acceptable for publication

## Goals & Non-Goals

**Goals**:
- Establish clear philosophy: sorries are mathematical debt requiring remediation
- **NEW (v002)**: Document transitive sorry inheritance and its implications
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
| Over-documentation making policy hard to follow | Medium | Medium | Keep under 180 lines; use clear sections |
| Boneyard paths becoming stale | Low | Low | Document pattern not specific subdirectories |
| Transitive concept not understood | Medium | Low | Include clear examples and Lean 4 #check commands |

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

### Phase 2: Write Philosophy and Transitive Inheritance Sections [NOT STARTED]

**Goal**: Document the core philosophy including transitive sorry inheritance

**Tasks**:
- [ ] Write "Philosophy" section:
  - Sorries as mathematical debt (not technical debt)
  - Never acceptable in publication-ready proofs
  - Each sorry represents an unverified mathematical claim
- [ ] Write "Transitive Inheritance" section (NEW in v002):
  - Sorries propagate through dependency chains
  - Definition: direct sorry vs inherited sorry
  - Definition: truly sorry-free (no direct or inherited sorries)
  - Publication requirement: only truly sorry-free theorems
  - Example: if `theorem A` uses `lemma B` which has `sorry`, then `A` inherits `B`'s sorry
  - Note: Lean 4 tracks this via `#check @A` showing axioms in info view

**Timing**: 25 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- Transitive inheritance clearly explained with examples
- Philosophy section distinguishes mathematical from technical debt
- Publication requirement explicitly stated

---

### Phase 3: Write Sorry Categories Section [NOT STARTED]

**Goal**: Document the four sorry categories with examples

**Tasks**:
- [ ] Write "Sorry Categories" section with four categories:
  - Construction assumptions (accepted, documented) - note these still inherit transitively
  - Development placeholders (temporary, must resolve)
  - Documentation examples (intentional, excluded from counts)
  - Fundamental obstacles (Boneyard candidates)
- [ ] Add concrete examples from codebase for each category
- [ ] Note which categories are acceptable for development vs publication

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- All four categories documented with examples
- Category-to-publication relationship is clear

---

### Phase 4: Write Remediation Paths Section [NOT STARTED]

**Goal**: Document the three remediation paths with decision criteria

**Tasks**:
- [ ] Write "Remediation Paths" section with three subsections:
  - Path A: Proof Completion - filling the gap with valid proof
  - Path B: Architectural Refactoring - changing approach to avoid the gap
  - Path C: Boneyard Archival - archiving fundamentally flawed code
- [ ] Include decision criteria for choosing each path
- [ ] Add guidance for partial progress (when to accept sorry temporarily)
- [ ] Note that resolving a sorry may unblock downstream dependents from publication

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- Each path has clear criteria and steps
- Decision tree is actionable
- Downstream impact noted

---

### Phase 5: Write Discovery Protocol, Boneyard, and Metrics [NOT STARTED]

**Goal**: Document what agents should do when encountering sorries

**Tasks**:
- [ ] Write "Discovery Protocol" section with step-by-step guidance:
  1. Check SORRY_REGISTRY.md for context
  2. Assess category (construction assumption vs fixable gap)
  3. **NEW**: Check if current work will inherit this sorry (transitive impact)
  4. Decision tree for action based on category
  5. Flagging process for fundamental obstacles
- [ ] Write "Boneyard References" section:
  - Primary: `Theories/Bimodal/Boneyard/`
  - Overflow: `Boneyard/`
  - README requirements for archived code
  - Link to existing Boneyard README as exemplar
- [ ] Write "Metrics Integration" section:
  - sorry_count computation (exclusions for Boneyard, Examples)
  - Note: metrics count direct sorries only, not transitive
  - Status thresholds (good <100, manageable <300, concerning >=300)
  - Escalation triggers

**Timing**: 25 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- Discovery protocol is step-by-step actionable
- Transitive impact check included
- Boneyard references include README requirements
- Metrics match existing /todo command patterns

---

### Phase 6: Finalize and Verify [NOT STARTED]

**Goal**: Review, refine, and verify the complete policy file

**Tasks**:
- [ ] Review entire file for consistency and completeness
- [ ] Ensure file is under 180 lines for readability (increased from 150 due to new section)
- [ ] Verify all cross-references are valid paths
- [ ] Check alignment with proof-conventions-lean.md (no conflicts)
- [ ] Add usage checklist at end including transitive check item

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Verification**:
- File builds valid markdown
- All referenced files exist
- Checklist includes transitive inheritance check

## Testing & Validation

- [ ] File exists at `.claude/context/project/lean4/standards/sorry-debt-policy.md`
- [ ] File length is under 180 lines
- [ ] Transitive sorry inheritance is clearly explained with examples
- [ ] All four sorry categories are documented with examples
- [ ] Three remediation paths are defined with decision criteria
- [ ] Discovery protocol includes transitive impact assessment
- [ ] Boneyard references include both locations and README requirements
- [ ] Metrics section notes direct vs transitive counting
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
