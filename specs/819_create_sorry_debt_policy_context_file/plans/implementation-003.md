# Implementation Plan: Task #819

- **Task**: 819 - create_sorry_debt_policy_context_file
- **Version**: 003
- **Status**: [NOT STARTED]
- **Dependencies**: None
- **Research Inputs**: specs/819_create_sorry_debt_policy_context_file/reports/research-001.md
- **Type**: meta
- **Lean Intent**: false

## Revision Notes

**v003 (from v002)**: Consolidated 6 phases into 3 for cleaner execution. Removed redundant transitive inheritance explanations (now single canonical location in Phase 1). Removed time estimates. Preserved all substantive content.

## Overview

Create `.claude/context/project/lean4/standards/sorry-debt-policy.md` formalizing the project's approach to `sorry` statements in Lean 4 proofs. Target: under 150 lines, well-structured, with clear examples.

## Key Concepts (Reference)

**Transitive Sorry Inheritance**: Sorries propagate through dependency chains. A theorem using a lemma with `sorry` inherits that sorry. Publication-ready proofs require transitive sorry-freedom.

**Four Sorry Categories**:
1. Construction assumptions - accepted, documented
2. Development placeholders - temporary, must resolve
3. Documentation examples - intentional, excluded from counts
4. Fundamental obstacles - Boneyard candidates

**Three Remediation Paths**:
- A: Proof completion
- B: Architectural refactoring
- C: Boneyard archival

## Implementation Phases

### Phase 1: Create File with Core Content [NOT STARTED]

**Goal**: Create policy file with header, philosophy, and transitive inheritance sections

**Files to create**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Content to include**:
1. Header with purpose and cross-references to:
   - `proof-conventions-lean.md`
   - `SORRY_REGISTRY.md`
   - Boneyard README
2. Philosophy section:
   - Sorries as mathematical debt (not technical debt)
   - Never acceptable in publication-ready proofs
   - Each sorry = unverified mathematical claim
3. Transitive Inheritance section (canonical definition):
   - Direct vs inherited sorries
   - Truly sorry-free definition
   - Publication requirement
   - Example with Lean 4 `#check` usage

**Verification**:
- File created at correct path
- Transitive inheritance defined once, clearly

---

### Phase 2: Add Categories, Remediation, and Protocol [NOT STARTED]

**Goal**: Complete the operational sections of the policy

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Content to include**:
1. Sorry Categories section:
   - Four categories with concrete codebase examples
   - Which are acceptable for development vs publication
2. Remediation Paths section:
   - Three paths with decision criteria
   - Note downstream impact of remediation
3. Discovery Protocol section:
   - Step-by-step agent guidance
   - Include transitive impact check
   - Decision tree based on category
4. Boneyard References section:
   - Primary: `Theories/Bimodal/Boneyard/`
   - Overflow: `Boneyard/`
   - README requirements
5. Metrics Integration section:
   - sorry_count computation with exclusion patterns
   - Note: metrics count direct sorries only
   - Status thresholds

**Verification**:
- All four categories documented
- Three remediation paths with criteria
- Discovery protocol is actionable

---

### Phase 3: Finalize and Verify [NOT STARTED]

**Goal**: Review for quality and consistency

**Files to modify**:
- `.claude/context/project/lean4/standards/sorry-debt-policy.md`

**Tasks**:
1. Review entire file for:
   - Consistency (no conflicting statements)
   - Completeness (all topics from research covered)
   - Conciseness (under 150 lines)
2. Verify cross-references are valid paths
3. Check alignment with proof-conventions-lean.md
4. Add usage checklist at end

**Verification**:
- File under 150 lines
- All referenced files exist
- No conflicts with existing conventions

## Testing & Validation

- [ ] File exists at `.claude/context/project/lean4/standards/sorry-debt-policy.md`
- [ ] Under 150 lines
- [ ] Transitive inheritance explained once, clearly
- [ ] Four categories with examples
- [ ] Three remediation paths with decision criteria
- [ ] Discovery protocol includes transitive check
- [ ] Boneyard references complete
- [ ] Metrics section documents exclusion pattern
- [ ] Cross-references valid

## Artifacts & Outputs

- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - Main policy file
- `specs/819_create_sorry_debt_policy_context_file/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback

Remove the file: `rm .claude/context/project/lean4/standards/sorry-debt-policy.md`
