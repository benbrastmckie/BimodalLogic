# Implementation Plan: Task #57 - Clean up UltrafilterChain.lean

- **Task**: 57 - clean_up_ultrafilter_chain_lean
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: Task 80 (completed - removed 4,423 lines)
- **Research Inputs**: specs/057_clean_up_ultrafilter_chain_lean/reports/02_post-80-review.md
- **Artifacts**: plans/01_comment-cleanup.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Streamline verbose exploratory comments in UltrafilterChain.lean, focusing on the `box_class_witness_consistent` proof (lines 1672-2050). Task 80's major cleanup (53% file reduction) already removed dead code; this task addresses the remaining readability issues from exploratory comments. The proof currently contains ~35-40% exploratory comments ("Actually...", "Let me...", "Hmm", etc.) that harm readability.

### Research Integration

Research report 02_post-80-review.md identified:
- Original scope partially obsolete: Phase 1 relations (R_G, R_Box) are NOT dead code
- File renaming not recommended: UltrafilterChain structure is still central
- Remaining scope: Verbose comment cleanup (~100-150 lines) and module docstring update

## Goals & Non-Goals

**Goals**:
- Remove exploratory comments ("Actually...", "Let me...", "Hmm", "Wait,", "Going back...")
- Retain strategy overview comments, external theorem references, and non-obvious reasoning
- Update module docstring to reflect post-task-80 reality
- Maintain all functional code unchanged (no proof modifications)

**Non-Goals**:
- Remove Phase 1 relations (R_G, R_Box, etc.) - they are actively used by UltrafilterChain
- Rename file to BoxClassBFMCS.lean - not recommended per research
- Refactor proof structure or change proof tactics
- Add new comments or documentation beyond docstring update

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidentally remove meaningful comments | M | L | Read each comment carefully, retain mathematical reasoning |
| Break build by removing too much | H | L | Verify `lake build` after each section cleanup |
| Incomplete cleanup | L | M | Use systematic scan for comment patterns |

## Implementation Phases

### Phase 1: Comment Streamlining in box_class_witness_consistent [NOT STARTED]

**Goal**: Remove exploratory comments while preserving mathematical documentation

**Tasks**:
- [ ] Read box_class_witness_consistent proof (lines 1672-2050)
- [ ] Identify and categorize comments into: exploratory (remove) vs. documentation (keep)
- [ ] Remove comments matching patterns: "Actually...", "Let me...", "Hmm", "Wait,", "Going back...", "I think...", "Maybe...", "Perhaps...", "Note to self"
- [ ] Retain comments that: explain proof strategy, reference external theorems, document non-obvious mathematical reasoning
- [ ] Verify `lake build` passes after changes

**Comment Removal Criteria**:
- REMOVE: Stream-of-consciousness exploration, abandoned reasoning paths, debug thoughts
- KEEP: "We use X theorem because...", "Strategy: ...", "This works because...", references to lemma names

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - lines 1672-2050

**Verification**:
- `lake build` passes
- Proof still compiles without modification
- Retained comments are meaningful and non-exploratory

---

### Phase 2: Module Docstring Update [NOT STARTED]

**Goal**: Update module documentation to reflect current file purpose after task 80

**Tasks**:
- [ ] Read current module docstring (lines 10-33)
- [ ] Update to reflect:
  - Current file purpose (box-class BFMCS construction via UltrafilterChain)
  - Remove any references to removed code sections
  - Keep UltrafilterChain in Main Definitions (it is still used)
- [ ] Verify docstring accurately describes file contents

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - lines 10-33

**Verification**:
- Docstring accurately describes current file structure
- No references to code sections that were removed in task 80

---

### Phase 3: Final Verification [NOT STARTED]

**Goal**: Ensure all changes maintain build integrity and meet quality standards

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Count lines removed (target: ~100-150 lines)
- [ ] Review changes for consistency
- [ ] Commit changes with message "task 57: streamline verbose proof comments"

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` passes completely
- Line count reduced by ~100-150 lines
- No functional changes to proofs

## Testing & Validation

- [ ] `lake build` passes after Phase 1
- [ ] `lake build` passes after Phase 2
- [ ] Full `lake build` passes after Phase 3
- [ ] Retained comments are meaningful documentation, not exploration
- [ ] Module docstring accurately reflects file contents

## Artifacts & Outputs

- `specs/057_clean_up_ultrafilter_chain_lean/plans/01_comment-cleanup.md` (this file)
- `specs/057_clean_up_ultrafilter_chain_lean/summaries/01_cleanup-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

## Rollback/Contingency

If changes cause build failures:
1. Use `git diff HEAD~1 -- Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` to review changes
2. `git checkout HEAD~1 -- Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` to restore
3. Re-attempt with more conservative comment removal
