# Implementation Plan: Task #71

- **Task**: 71 - document_f_persistence_findings
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/071_document_f_persistence_findings/reports/01_f-persistence-bidirectionality.md
- **Artifacts**: plans/01_f-persistence-documentation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown

## Overview

Consolidate discoveries from tasks 67, 69, 70 into ROADMAP.md and source code comments. Three documentation items: (1) F-persistence counterexample marking dead code in UltrafilterChain.lean, (2) truth lemma bidirectionality constraint correction in ROADMAP.md and code comments, (3) separate-direction witness status documentation. The research phase confirmed specific line numbers and existing comment states.

### Research Integration

- Task 69 report 17: Counterexample proving `f_preserving_seed_consistent` is FALSE
- Task 70 summary: `forward_G`/`backward_H` proven sorry-free; F/P gaps remain
- Task 70 plan v5: Separate-direction witness approach documentation

## Goals & Non-Goals

**Goals**:
- Correct the misleading statement on ROADMAP.md line 195 about "forward-only" truth lemma
- Mark `f_preserving_seed_consistent` and dependent code as dead code with counterexample reference
- Add cross-reference in SuccChainFMCS.lean to the F-persistence counterexample
- Document why the truth lemma is inherently bidirectional

**Non-Goals**:
- Modifying any Lean proof code (documentation only)
- Adding comments to SuccChainTruth.lean or ParametricTruthLemma.lean (research confirmed adequate existing comments)
- Resolving the F/P sorry gaps (out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect line numbers due to codebase drift | Medium | Low | Verify line numbers before editing |
| Missing critical dead code locations | Medium | Low | Research report provided comprehensive list |
| Misleading comment correction causes confusion | Low | Low | Explain both what was wrong and why |

## Implementation Phases

### Phase 1: ROADMAP.md Corrections [NOT STARTED]

**Goal**: Correct misleading "forward-only" statement and add bidirectionality architecture section

**Tasks**:
- [ ] Correct line 195: Change "For completeness, only FORWARD truth lemma direction is needed" to explain bidirectionality constraint
- [ ] Add explanation that forward Imp case uses backward IH (`.mpr` at SuccChainTruth.lean:200)
- [ ] Document that backward G/H cases require `forward_F`/`backward_P`
- [ ] Verify the change fits the existing document structure

**Timing**: 30 minutes

**Files to modify**:
- `ROADMAP.md` (lines 190-196)

**Verification**:
- ROADMAP.md builds as valid markdown
- No remaining claims about "forward-only" truth lemma
- Bidirectionality constraint is clearly explained

---

### Phase 2: UltrafilterChain.lean Dead Code Comments [NOT STARTED]

**Goal**: Mark F-persistence approach as dead code with counterexample reference

**Tasks**:
- [ ] Add header comment before `f_preserving_seed_consistent` (line 2668) explaining the counterexample
- [ ] Add DEAD CODE notice for `temporal_theory_witness_F_preserving` (line 3416)
- [ ] Add DEAD CODE notice for `construct_bfmcs` sorry reference (line 4751)
- [ ] Reference task 69 report 17 for counterexample details

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 2509-2515, 2665-2668, 3405-3422, 4745-4760)

**Verification**:
- `lake build` succeeds (comments only, no code changes)
- Dead code is clearly marked
- Counterexample is referenced with specific task/report path

---

### Phase 3: SuccChainFMCS.lean Cross-Reference [NOT STARTED]

**Goal**: Add reference to F-persistence counterexample in existing documentation

**Tasks**:
- [ ] Add cross-reference note in the "Known Gaps" section (around line 1022-1027)
- [ ] Reference UltrafilterChain.lean counterexample location
- [ ] Clarify that separate-direction approach avoids the F-persistence issue

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 1022-1040)

**Verification**:
- `lake build` succeeds
- Cross-reference is accurate
- Existing documentation structure preserved

---

### Phase 4: Verification and Summary [NOT STARTED]

**Goal**: Verify all documentation changes and create summary

**Tasks**:
- [ ] Run `lake build` to confirm no breaking changes
- [ ] Verify all three documentation items are addressed
- [ ] Create implementation summary

**Timing**: 25 minutes

**Verification**:
- Build passes
- All three research findings documented
- Summary captures key changes

## Testing & Validation

- [ ] `lake build` succeeds after all changes
- [ ] ROADMAP.md renders correctly as markdown
- [ ] No orphaned or misleading comments remain
- [ ] Cross-references between files are accurate

## Artifacts & Outputs

- `ROADMAP.md` - Updated with bidirectionality constraint, corrected line 195
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Dead code comments
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Cross-reference to counterexample
- `specs/071_document_f_persistence_findings/summaries/01_f-persistence-documentation-summary.md` - Implementation summary

## Rollback/Contingency

All changes are documentation-only (comments and markdown). If any change causes issues:
1. Revert individual file changes using `git checkout -- <file>`
2. No Lean proof code is modified, so no proof regressions possible
3. Build verification at Phase 4 catches any syntax errors in comments
