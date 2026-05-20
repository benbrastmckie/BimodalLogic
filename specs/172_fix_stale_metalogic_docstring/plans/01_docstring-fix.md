# Implementation Plan: Fix Stale Metalogic.lean Docstrings

- **Task**: 172 - Fix stale Metalogic.lean docstring
- **Status**: [IMPLEMENTING]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_docstring-audit.md
- **Artifacts**: plans/01_docstring-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace two severely stale docstrings in the Metalogic module files. The top-level aggregator (`Theories/Bimodal/Metalogic.lean`, lines 6-65) and the inner re-export module (`Theories/Bimodal/Metalogic/Metalogic.lean`, lines 7-88) both reference dead architecture (SuccChain), nonexistent files (11 phantom paths), incorrect semantics ("Reflexive G/H" when the project uses irreflexive), and a nonexistent theorem (`bmcs_truth_lemma`). The research report provides exact replacement text for both files. No code changes are needed.

### Research Integration

The research report (`reports/01_docstring-audit.md`) provides:
- Complete inventory of all stale references in both files (4 issues in file 1, 15+ in file 2)
- Ground truth of the current architecture (Chronicle/WeakCanonical/Algebraic paths)
- Exact replacement docstring text for both files, ready to paste
- Sorry status summary table for accurate status reporting
- Actual module structure tree reflecting the live codebase

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted.

## Goals & Non-Goals

**Goals**:
- Replace the stale docstring in `Theories/Bimodal/Metalogic.lean` with accurate content reflecting current architecture
- Replace the stale docstring in `Theories/Bimodal/Metalogic/Metalogic.lean` with accurate content reflecting irreflexive semantics, Chronicle/WeakCanonical/Algebraic completeness paths, and actual module structure
- Verify the project builds cleanly after docstring changes

**Non-Goals**:
- Modifying any Lean code or proof terms (docstring-only task)
- Archiving dead code files (separate task scope, noted in research report)
- Updating docstrings in any other files beyond the two Metalogic modules

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Docstring syntax error breaks build | M | L | Verify with `lake build` after changes |
| Replacement text references nonexistent theorems | H | L | Research report cross-checked against live codebase; verify theorem names with grep |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1    | 1      | --         |
| 2    | 2      | 1          |

Phases within the same wave can execute in parallel.

### Phase 1: Replace Both Docstrings [COMPLETED]

**Goal**: Replace stale docstrings in both Metalogic files with the research-provided replacement text.

**Tasks**:
- [x] Replace docstring in `Theories/Bimodal/Metalogic.lean` (lines 6-65) with the proposed replacement from the research report
- [x] Replace docstring in `Theories/Bimodal/Metalogic/Metalogic.lean` (lines 7-88) with the proposed replacement from the research report
- [x] Spot-check that no import statements were accidentally modified

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - Replace doc comment block (lines 6-65)
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Replace doc comment block (lines 7-88)

**Verification**:
- Both files contain the new docstrings
- Import statements at the top of each file are unchanged
- No references to SuccChain, "Reflexive G/H", `bmcs_truth_lemma`, or `Bundle/TruthLemma.lean` remain

---

### Phase 2: Build Verification [COMPLETED]

**Goal**: Confirm the project builds cleanly with no regressions from docstring changes.

**Tasks**:
- [x] Run `lake build` and confirm zero errors
- [x] If build fails, check whether failure is pre-existing or caused by docstring changes *(deviation: skipped -- build succeeded with zero errors)*

**Timing**: 10 minutes (build time)

**Depends on**: 1

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` exits with code 0 (or any errors are pre-existing and unrelated to docstring changes)

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] `grep -r "SuccChain" Theories/Bimodal/Metalogic.lean Theories/Bimodal/Metalogic/Metalogic.lean` returns no matches
- [ ] `grep -r "bmcs_truth_lemma" Theories/Bimodal/Metalogic.lean Theories/Bimodal/Metalogic/Metalogic.lean` returns no matches
- [ ] `grep -r "Reflexive G/H" Theories/Bimodal/Metalogic/Metalogic.lean` returns no matches

## Artifacts & Outputs

- `plans/01_docstring-fix.md` (this plan)
- `Theories/Bimodal/Metalogic.lean` (modified docstring)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (modified docstring)

## Rollback/Contingency

Revert with `git checkout -- Theories/Bimodal/Metalogic.lean Theories/Bimodal/Metalogic/Metalogic.lean` to restore original docstrings. Since changes are docstring-only, rollback carries zero risk to code correctness.
