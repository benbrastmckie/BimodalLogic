# Implementation Plan: Task #561

- **Task**: 561 - Cleanup and Documentation
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: 560
- **Research Inputs**: specs/561_cleanup_and_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

Update Metalogic_v2/ documentation to accurately reflect current implementation state. Research identified that the README incorrectly claims 2 sorries remain when actual count is zero (all theorems are fully proven). Additionally, 3 instances of historical markers need removal from Lean file comments. This is a documentation cleanup task with no code changes required.

### Research Integration

Research report `specs/561_cleanup_and_documentation/reports/research-001.md` (2026-01-18) found:
- Zero sorries in codebase (verified via grep and manual inspection)
- README "With Sorries" section lists 2 theorems with sorries, both actually proven
- 10 temporal language instances found (7 acceptable proof state comments, 3 requiring cleanup)
- README "Future Work" section references non-existent sorries
- README "Proven" section missing recently completed theorems

## Goals & Non-Goals

**Goals**:
- Remove inaccurate "With Sorries" section from README.md
- Add 4 proven theorems to "Proven" section in README.md
- Update "Future Work" section to remove sorry-related items
- Clean 3 historical markers from Lean file comments
- Ensure all documentation matches implementation state

**Non-Goals**:
- Changing any Lean code or proofs
- Removing acceptable proof state comments (7 instances of "now" in proof contexts)
- Changing semantic descriptions of modal logic operators
- Modifying code structure or imports

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrectly claiming sorries are removed when they exist | High | Low | Triple-verified with grep, manual file inspection, and research report validation |
| Breaking downstream references to README sections | Low | Medium | README is documentation only, no code dependencies |
| Over-cleaning removes useful proof comments | Medium | Low | Only remove historical markers, preserve all proof state language per research recommendations |
| Removing temporal language that is standard mathematical convention | Low | Low | Research categorized "now" in proof contexts as acceptable practice |

## Implementation Phases

### Phase 1: Update README.md Accuracy [COMPLETED]

**Goal**: Correct README.md to reflect zero sorries and add proven theorems

**Tasks**:
- [ ] Remove "With Sorries" section entirely (lines 89-95)
- [ ] Add note after "Proven" section: "All theorems in Metalogic_v2 are fully proven with no sorry statements"
- [ ] Add 4 proven theorems to "Proven" section:
  - `necessitation_lemma` (Representation/TruthLemma.lean) - Box operator preservation in MCS
  - `finite_model_property` (Representation/FiniteModelProperty.lean) - FMP via satisfiability witness
  - `satisfiability_decidable` (Representation/FiniteModelProperty.lean) - Decidability of satisfiability
  - `validity_decidable_via_fmp` (Representation/FiniteModelProperty.lean) - Decidability of validity
- [ ] Update "Future Work" section to remove "Complete remaining sorries" item
- [ ] Change "currently" to "trivial witness implementation" in line 159

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - Documentation corrections

**Verification**:
- Grep for "sorry" in README returns no results claiming sorries exist
- "Proven" section includes all 4 newly identified theorems
- "Future Work" section has no sorry-related items
- No temporal language ("currently", "will be") in README

---

### Phase 2: Clean Historical Markers in Lean Comments [IN PROGRESS]

**Goal**: Remove 3 historical/temporal markers from Lean file comments

**Tasks**:
- [ ] Update WeakCompleteness.lean line 66:
  - Remove: "which will be proven once the full canonical model machinery is in place"
  - Replace with: "Uses representation_theorem_backward_empty from ContextProvability (proven)"
- [ ] Update FiniteModelProperty.lean line 185:
  - Remove: "For now, just use the satisfiability witness directly"
  - Replace with: "Use the satisfiability witness directly (identity proof)"
- [ ] Update ContextProvability.lean line 123:
  - Remove: "With Strategy C, we now use"
  - Replace with: "Strategy C uses"

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` - Comment cleanup
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - Comment cleanup
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Comment cleanup

**Verification**:
- Grep for "will be proven" returns no results
- Grep for "For now, just" returns no results
- Grep for "With Strategy C, we now" returns no results
- All proof state comments (7 instances of "now") remain unchanged

---

### Phase 3: Verification and Build Check [NOT STARTED]

**Goal**: Verify no regressions and documentation is accurate

**Tasks**:
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic_v2 --include="*.lean"` to confirm zero sorries
- [ ] Verify Lean files still compile: `cd Theories/Bimodal/Metalogic_v2 && lake build`
- [ ] Check README lists correct sorry count (should be 0, not 2)
- [ ] Verify all 3 historical markers removed from comments
- [ ] Confirm 7 proof state "now" comments remain unchanged

**Timing**: 15 minutes

**Files to verify**:
- All Lean files in `Theories/Bimodal/Metalogic_v2/` - No compilation errors
- `Theories/Bimodal/Metalogic_v2/README.md` - Accurate documentation

**Verification**:
- Build succeeds with no errors
- Sorry count verified as zero via grep
- README "With Sorries" section removed
- README "Proven" section includes 4 new theorems
- 3 historical markers removed, 7 proof state comments preserved

## Testing & Validation

- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic_v2 --include="*.lean" -n` returns only comment in ContextProvability.lean:208
- [ ] `lake build` in Theories/Bimodal/Metalogic_v2 succeeds with no errors
- [ ] README.md no longer contains "With Sorries" section
- [ ] README.md "Proven" section includes `necessitation_lemma`, `finite_model_property`, `satisfiability_decidable`, `validity_decidable_via_fmp`
- [ ] README.md "Future Work" section has no sorry-related items
- [ ] Grep for temporal markers "will be proven", "For now, just", "With Strategy C, we now" returns zero results
- [ ] Proof state comments preserved (7 instances of "now" in proof contexts remain)

## Artifacts & Outputs

- Updated README.md with accurate sorry count and proven theorems list
- Cleaned Lean file comments (3 historical markers removed)
- Implementation summary documenting changes
- specs/561_cleanup_and_documentation/plans/implementation-001.md (this file)
- specs/561_cleanup_and_documentation/summaries/implementation-summary-{DATE}.md

## Rollback/Contingency

If documentation changes cause issues:
1. Revert README.md changes via git: `git checkout HEAD -- Theories/Bimodal/Metalogic_v2/README.md`
2. Revert Lean comment changes via git: `git checkout HEAD -- Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` (and other files)
3. All changes are documentation/comments only - no code logic affected, low risk of breaking changes
