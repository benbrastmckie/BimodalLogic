# Implementation Plan: Task #398

- **Task**: 398 - Port causal semantics to recursive-semantics.md
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None (builds on existing Dynamical Foundation)
- **Research Inputs**: specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Add causal semantics to recursive-semantics.md using ONLY existing Dynamical Foundation primitives. The approach differs from the research report by avoiding new frame components entirely. Instead, we define evolutions, evolution parthood, and inexact verification/falsification as definitions built from existing primitives (task relation, world-histories, state parthood, bilateral propositions). The causal operator truth conditions use [DETAILS] placeholders for the user to fill in.

### Research Integration

The research report (research-001.md) extracted formal definitions from sn-article.tex, including closeness ordering, expected evolutions, and the three-condition causal semantics. However, the user requires a **revised approach** that:
1. Uses only existing Dynamical Foundation primitives
2. Defines auxiliary concepts rather than extending the frame
3. Uses [DETAILS] placeholders for the specific causal conditions

## Goals & Non-Goals

**Goals**:
- Add causal conditional section to recursive-semantics.md after Store/Recall (line 418)
- Define evolutions as generalizations of world-histories mapping to states (not just world-states)
- Define evolution parthood as pointwise state parthood
- Define inexact verification/falsification in terms of exact verification + state parthood
- Add causal truth condition skeleton with three [DETAILS] placeholder conditions
- Include intuitive reading of the causal operator

**Non-Goals**:
- Adding new frame components (closeness ordering, background assumptions function)
- Defining specific formulations of the three causal conditions (user provides these)
- Defining propositional subtraction/inversion operations (defer unless needed)
- Modifying any other sections of recursive-semantics.md

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Insertion point shifts if file is modified | Low | Low | Verify line numbers before insertion |
| Definitions may conflict with existing notation | Medium | Low | Review existing notation conventions |
| [DETAILS] placeholders may be unclear | Low | Medium | Provide clear descriptions for each condition |

## Implementation Phases

### Phase 1: Verify Target Structure [NOT STARTED]

**Goal**: Confirm insertion point and existing primitives available

**Tasks**:
- [ ] Read recursive-semantics.md and locate insertion point (after Store/Recall, before Bimodal Interaction)
- [ ] Verify existing primitives: task relation (s =>_d t), world-histories, state parthood, bilateral propositions
- [ ] Note line numbers for precise insertion

**Timing**: 10 minutes

**Files to modify**:
- None (read-only verification)

**Verification**:
- Insertion point identified with line numbers
- All required primitives confirmed present

---

### Phase 2: Draft Auxiliary Definitions [NOT STARTED]

**Goal**: Write definitions for evolutions, evolution parthood, inexact verification/falsification

**Tasks**:
- [ ] Define evolutions as tau : X -> S (not just W) with task constraint
- [ ] Define evolution parthood: delta <=_E tau iff pointwise delta(x) <= tau(x)
- [ ] Define inexact verification: state s inexactly verifies A iff some t <= s exactly verifies A
- [ ] Define inexact falsification: state s inexactly falsifies A iff some t <= s exactly falsifies A
- [ ] Format as markdown subsection with proper notation

**Timing**: 20 minutes

**Files to modify**:
- (draft content in memory)

**Verification**:
- Definitions use only existing primitives
- Notation consistent with rest of document

---

### Phase 3: Draft Causal Truth Conditions [NOT STARTED]

**Goal**: Write causal operator skeleton with [DETAILS] placeholders

**Tasks**:
- [ ] Write causal context definition (if needed, or note not required)
- [ ] Write main truth condition structure: M, tau, x, sigma, i-vec |= A o-> B iff three conditions
- [ ] Add Condition 1 with [DETAILS] placeholder for background/inclusion
- [ ] Add Condition 2 with [DETAILS] placeholder for production/substantial contribution
- [ ] Add Condition 3 with [DETAILS] placeholder for difference-making
- [ ] Add brief intuitive reading section

**Timing**: 25 minutes

**Files to modify**:
- (draft content in memory)

**Verification**:
- Three conditions clearly separated with [DETAILS] tags
- Intuitive reading provides plain-language explanation

---

### Phase 4: Insert into Target File [NOT STARTED]

**Goal**: Add causal semantics section to recursive-semantics.md

**Tasks**:
- [ ] Insert complete Causal Conditional section after Store/Recall (line ~418)
- [ ] Ensure section is before Bimodal Interaction Principles
- [ ] Verify markdown formatting renders correctly
- [ ] Check no unintended changes to other sections

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Logos/docs/research/recursive-semantics.md` - Add causal conditional section

**Verification**:
- Section appears at correct location
- No syntax errors in markdown
- Document structure intact

---

## Testing & Validation

- [ ] Read modified file and verify section placement
- [ ] Verify all [DETAILS] placeholders are clearly marked
- [ ] Confirm no changes to other sections
- [ ] Check notation consistency with document conventions

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- Modified: Theories/Logos/docs/research/recursive-semantics.md
- summaries/implementation-summary-YYYYMMDD.md (on completion)

## Rollback/Contingency

If implementation causes issues:
1. Revert recursive-semantics.md using git: `git checkout HEAD -- Theories/Logos/docs/research/recursive-semantics.md`
2. Review and revise the plan
3. Re-implement with corrections
