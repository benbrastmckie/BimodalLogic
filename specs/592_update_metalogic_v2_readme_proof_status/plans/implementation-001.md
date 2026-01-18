# Implementation Plan: Task #592

- **Task**: 592 - Update Metalogic_v2 README.md to reflect accurate proof status
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/592_update_metalogic_v2_readme_proof_status/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Update Metalogic_v2/README.md to reflect the current accurate proof status discovered during task 576 completion. The research report identified that several theorems previously listed as having sorries or being axioms are now fully proven: `mcs_contains_or_neg`, `mcs_modus_ponens`, and `representation_theorem_backward_empty`. Additionally, `weak_completeness` and `strong_completeness` no longer depend on unproven axioms. The README currently overstates technical debt (implies 6+ sorries when only 2 actual sorries remain).

### Research Integration

Key findings from research-001.md:
- `mcs_contains_or_neg` is FULLY PROVEN (CanonicalModel.lean:231-266)
- `mcs_modus_ponens` is FULLY PROVEN (CanonicalModel.lean:274-308)
- `representation_theorem_backward_empty` is PROVEN via `main_provable_iff_valid`
- Only 2 actual sorries remain: `necessitation_lemma` and `consistent_iff_consistent'`
- Completeness theorems now fully depend on proven foundations

## Goals & Non-Goals

**Goals**:
- Update "Proven (no sorry)" table with newly proven theorems
- Update "With Sorries" table to reflect actual remaining sorries
- Update "Future Work" section to remove completed items
- Ensure accuracy between README documentation and actual code state

**Non-Goals**:
- Modifying any Lean source files
- Adding new theorems or functionality
- Changing the architecture documentation
- Creating new sections in the README

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| README changes cause confusion | Low | Low | Changes are clarifications based on verified code state |
| Missing a proven theorem | Medium | Low | Research report provides exhaustive analysis |

## Implementation Phases

### Phase 1: Update Proven Theorems Section [NOT STARTED]

**Goal**: Move proven theorems from "With Sorries" to "Proven" section

**Tasks**:
- [ ] Add `mcs_contains_or_neg` to "Proven (no sorry)" table
- [ ] Add `mcs_modus_ponens` to "Proven (no sorry)" table
- [ ] Add `representation_theorem_backward_empty` to "Proven" table (was axiom)
- [ ] Add note that `weak_completeness` and `strong_completeness` are now proven

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - Update Key Theorems section

**Verification**:
- "Proven (no sorry)" table contains all 6 original items plus 5 new items
- No proven theorems remain in "With Sorries" section

---

### Phase 2: Update Sorries and Future Work Sections [NOT STARTED]

**Goal**: Correct the "With Sorries" section and update "Future Work"

**Tasks**:
- [ ] Update "With Sorries" table to only list actual remaining sorries:
  - `necessitation_lemma` (TruthLemma.lean:160)
  - `consistent_iff_consistent'` (Basic.lean:56)
  - `finite_model_property` (trivial witness - unchanged)
- [ ] Remove proven items from "With Sorries" section
- [ ] Update "Future Work" section:
  - Remove "Fill remaining sorries: The MCS property proofs and completeness axiom" (done)
  - Keep decidability and constructive FMP items
  - Update to reflect actual remaining work

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - Update With Sorries and Future Work sections

**Verification**:
- "With Sorries" table contains exactly 3 items
- "Future Work" accurately reflects remaining work
- No references to completed items remain

## Testing & Validation

- [ ] Verify README markdown renders correctly
- [ ] Cross-reference with research report findings
- [ ] Confirm no broken internal links

## Artifacts & Outputs

- `specs/592_update_metalogic_v2_readme_proof_status/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Metalogic_v2/README.md` (modified)
- `specs/592_update_metalogic_v2_readme_proof_status/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If changes cause issues, revert with:
```bash
git checkout HEAD -- Theories/Bimodal/Metalogic_v2/README.md
```
