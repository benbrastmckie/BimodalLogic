# Implementation Plan: Clean up archival BX14 comments

- **Task**: 136 - Clean up archival BX14 comments in PointInsertion.lean
- **Status**: [NOT STARTED]
- **Effort**: 30 minutes
- **Dependencies**: None
- **Research Inputs**: Task 115 verification audit
- **Artifacts**: plans/01_cleanup-comments.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Clean up archival comments in PointInsertion.lean that describe the old BX14-based D0 seed approach in detail. These could mislead future readers into thinking BX14 is still used. Replace with concise historical notes pointing to Xu 3.2.1+3.2.2 as the current approach.

## Goals & Non-Goals

**Goals**:
- Replace detailed BX14 chain descriptions (lines ~1087-1098, ~2215-2227) with concise historical notes
- Keep historical context (what was replaced and why) but remove step-by-step derivation details
- Verify `lake build` passes (comment-only changes)

**Non-Goals**:
- Removing all mentions of BX14 (historical notes in Xu 3.2.1/3.2.2 doc comments are fine)
- Modifying any code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| None | - | - | Comment-only changes |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

### Phase 1: Update comments [NOT STARTED]

**Goal**: Replace verbose archival BX14 descriptions with concise notes.

**Tasks**:
- [ ] Lines ~1087-1098: Replace detailed BX5+BX14+BX10 chain description with 1-2 line note
- [ ] Lines ~2215-2227: Replace detailed BX14 separation description with concise note
- [ ] Verify `lake build` passes

**Timing**: 30 minutes
**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (comments only)

**Verification**:
- `lake build` passes
- No active-voice BX14 references remain (grep for non-comment BX14 references)

## Testing & Validation

- [ ] `lake build` passes clean

## Artifacts & Outputs

- plans/01_cleanup-comments.md (this file)

## Rollback/Contingency

Comment-only changes. Trivial revert.
