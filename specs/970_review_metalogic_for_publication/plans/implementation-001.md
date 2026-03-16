# Implementation Plan: Task #970 - Review Metalogic for Publication Readiness

- **Task**: 970 - Review Metalogic for Publication Readiness
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: specs/970_review_metalogic_for_publication/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: true

## Overview

Systematically refactor the metalogic codebase to eliminate structural redundancies, thin aliases, dead-code sorries, and duplicate theorem bodies accumulated during the iterative proof development process. The research identified 8 key findings across 6 priority levels, with a blocking issue that must be resolved first (extracting valid content from `TemporalCoherentConstruction.lean` before archival). This plan executes the research recommendations in dependency order, ensuring `lake build` passes after each phase.

### Research Integration

- **Primary source**: research-001.md (team research with 2 teammates, high confidence)
- **Key findings**: `bmcs_truth_at` intermediate layer redundancy, ~15 unused convenience definitions, duplicate theorem bodies, thin aliases, dead-code sorries
- **Current sorry count**: 9 active (SORRY_REGISTRY.md reports 46 - severely outdated)
- **Blocking issue**: Extract `BFMCS.temporally_coherent` and related definitions before archiving deprecated file

## Goals & Non-Goals

**Goals**:
- Eliminate all thin aliases and one-line wrappers with no mathematical value
- Remove all unused convenience definitions (~15 in FMCS/BFMCS)
- Archive dead-code sorry paths to Boneyard, reducing active sorry count from 9 to 7
- Consolidate duplicate theorem bodies into single authoritative locations
- Improve naming conventions for consistency throughout
- Update SORRY_REGISTRY.md with accurate current state
- Ensure main theorems are stated in mathematically standard Kripke form

**Non-Goals**:
- Full elimination of `bmcs_truth_at` layer (deferred to future task - Priority 5)
- Resolution of the 7 remaining sorries (separate tasks)
- Changes to the Decidability module
- Modifications to the Examples directory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports by removing definitions still in use | High | Medium | Run `lake build` after each removal, grep for usages first |
| Incorrect extraction of `temporally_coherent` dependencies | High | Low | Trace import graph carefully, verify `lake build` before archival |
| Namespace conflicts when migrating theorems | Medium | Low | Check for existing definitions in target namespace before migration |
| Time underestimation for complex refactors | Medium | Medium | Phase dependencies allow partial progress; each phase is independently valuable |

## Implementation Phases

### Phase 1: Extract Temporal Coherence Core (BLOCKING) [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create `Bundle/TemporalCoherence.lean` containing the valid mathematical content from `TemporalCoherentConstruction.lean`, unblocking archival of the deprecated file.

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- [ ] Extract `TemporalCoherentFamily` structure definition
- [ ] Extract `temporal_backward_G` lemma
- [ ] Extract `temporal_backward_H` lemma
- [ ] Extract `BFMCS.temporally_coherent` definition
- [ ] Extract any supporting lemmas required by the above
- [ ] Update imports in `TruthLemma.lean` to use new file
- [ ] Update imports in `CanonicalFMCS.lean` to use new file
- [ ] Update imports in `CanonicalConstruction.lean` to use new file
- [ ] Verify: `lake build` passes

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - create (new file)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - update imports
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - update imports
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - update imports

**Verification:**
- `lake build` completes successfully
- `grep -n "TemporalCoherentConstruction" Theories/Bimodal/Metalogic/Bundle/*.lean` returns only `TemporalCoherentConstruction.lean` itself

---

### Phase 2: Archive Deprecated File (Reduces Sorry Count) [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Move `TemporalCoherentConstruction.lean` to Boneyard, eliminating 2 dead-code sorries from active codebase.

**Tasks:**
- [ ] Verify no active imports remain for `TemporalCoherentConstruction.lean` (only Boneyard files should reference it)
- [ ] Move `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` to `Theories/Bimodal/Boneyard/TemporalCoherentConstruction.lean`
- [ ] Update `Theories/Bimodal/Metalogic.lean` import list to remove archived file
- [ ] Update Boneyard import files if needed
- [ ] Verify: `lake build` passes
- [ ] Confirm sorry count reduced by 2 (from 9 to 7)

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - move to Boneyard
- `Theories/Bimodal/Metalogic.lean` - update imports

**Verification:**
- `lake build` completes successfully
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard | wc -l` returns 7 or less

---

### Phase 3: Remove Thin Aliases [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Eliminate one-line wrappers and pure aliases that add no mathematical value.

**Tasks:**
- [ ] Remove `dne_theorem'` from `TemporalCoherentConstruction.lean` (already archived, but verify no references)
- [ ] Remove `diamondFormula` from `ModalSaturation.lean` - replace calls with `phi.diamond`
- [ ] Remove `set_mcs_modal_saturation_forward` from `Completeness.lean` - replace calls with `set_mcs_box_closure`
- [ ] Remove `dne_theorem` from `ModalSaturation.lean` if not widely used - replace with `Propositional.double_negation`
- [ ] Remove `dni_theorem` from `ModalSaturation.lean` if not widely used - replace with `Propositional.dni`
- [ ] Verify: `lake build` passes after each removal

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - remove aliases
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` - remove alias, update calls

**Verification:**
- `lake build` completes successfully
- `grep -n "diamondFormula\|dne_theorem'\|set_mcs_modal_saturation_forward" Theories/Bimodal/Metalogic/**/*.lean` returns empty

---

### Phase 4: Remove Unused FMCS/BFMCS Convenience Definitions [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Remove ~15 unused accessor wrappers and derived lemmas created during proof development but never adopted.

**Tasks:**
- [ ] **FMCSDef.lean removals** (verify zero external usage first):
  - [ ] Remove `FMCS.at` if unused
  - [ ] Remove `FMCS.forward_G_chain` if unused
  - [ ] Remove `FMCS.backward_H_chain` if unused
  - [ ] Remove `FMCS.GG_to_G` if unused
  - [ ] Remove `FMCS.HH_to_H` if unused
  - [ ] Remove `FMCS.G_implies_future_phi` if unused
  - [ ] Remove `FMCS.H_implies_past_phi` if unused
  - [ ] Remove `FMCS.consistent` if unused
  - [ ] Remove `FMCS.maximal` if unused
  - [ ] Remove `FMCS.theorem_mem` if unused
  - [ ] Remove `IsConstantFamily` if unused
- [ ] **BFMCS.lean removals** (verify zero external usage first):
  - [ ] Remove `BFMCS.mcs_at` if unused
  - [ ] Remove `BFMCS.is_mcs` if unused
  - [ ] Remove `BFMCS.consistent` if unused
  - [ ] Remove `BFMCS.phi_from_box` if unused
  - [ ] Remove `BFMCS.box_from_universal` if unused
- [ ] **BFMCSTruth.lean removals** (verify zero external usage first):
  - [ ] Remove `bmcs_valid` if unused
  - [ ] Remove `bmcs_satisfiable_at` if unused
  - [ ] Remove `bmcs_satisfies_context` if unused
- [ ] Verify: `lake build` passes after each batch

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - remove unused definitions
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - remove unused accessors
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - remove unused validity definitions

**Verification:**
- `lake build` completes successfully
- Each removed definition has zero grep hits before removal

---

### Phase 5: Consolidate Duplicate Theorems [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Eliminate duplicate theorem bodies by migrating unique content and removing redundant copies.

**Tasks:**
- [ ] Analyze import graph: which files import `Completeness.lean` vs `Core/MCSProperties.lean`
- [ ] Identify the 3 duplicate theorem bodies:
  - [ ] `set_mcs_all_future_all_future`
  - [ ] `set_mcs_all_past_all_past`
  - [ ] `temp_4_past`
- [ ] Decide canonical location (likely `Core/MCSProperties.lean`)
- [ ] Remove duplicate definitions from `Completeness.lean`
- [ ] Add re-export or alias if downstream compatibility required
- [ ] Migrate unique `Completeness.lean` content to `Core/MCSProperties.lean`:
  - [ ] `set_mcs_disjunction_intro/elim/iff` (3 theorems)
  - [ ] `set_mcs_conjunction_intro/elim/iff` (3 theorems)
  - [ ] `set_mcs_box_closure`, `set_mcs_box_box` (2 theorems)
  - [ ] `set_mcs_neg_box_implies_diamond_neg`, `set_mcs_diamond_neg_implies_neg_box`, `set_mcs_diamond_box_duality` (3 theorems)
- [ ] Update imports in dependent files
- [ ] Verify: `lake build` passes

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` - remove duplicates, migrate content
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - receive migrated content

**Verification:**
- `lake build` completes successfully
- No theorem bodies appear in more than one file

---

### Phase 6: Unify asDiamond Definitions [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Eliminate duplicate `asDiamond` definitions by consolidating to a single location.

**Tasks:**
- [ ] Compare `asDiamond` in `ModalSaturation.lean` vs `asDiamond?` in `Decidability/Tableau.lean`
- [ ] Determine if they are semantically equivalent
- [ ] If equivalent: Choose one canonical location and remove the other
- [ ] If different: Rename to distinguish purposes clearly
- [ ] Update all call sites to use the canonical definition
- [ ] Verify: `lake build` passes

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - potentially remove or rename
- `Theories/Bimodal/Decidability/Tableau.lean` - potentially update

**Verification:**
- `lake build` completes successfully
- Only one `asDiamond` definition exists (or two with clearly distinct names/purposes)

---

### Phase 7: Clean Internal Scaffolding [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Mark or remove internal scaffolding that exists only for proof development, not as published interface.

**Tasks:**
- [ ] Review `needs_modal_witness` in `ModalSaturation.lean`
- [ ] If only used within `is_modally_saturated_iff_no_needs_witness`: make private or move to `where` clause
- [ ] Review other internal scaffolding identified during phases 3-6
- [ ] Apply same treatment: private, where clause, or inline
- [ ] Verify: `lake build` passes

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - privatize scaffolding

**Verification:**
- `lake build` completes successfully
- Public API contains only mathematically meaningful definitions

---

### Phase 8: Improve Naming Conventions [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Establish and apply consistent naming conventions throughout the metalogic.

**Tasks:**
- [ ] Document naming conventions:
  - [ ] Structures: `PascalCase` (e.g., `TemporalCoherentFamily`)
  - [ ] Definitions/theorems: `snake_case` (e.g., `truth_at`, `bmcs_truth_lemma`)
  - [ ] Predicates: `is_` prefix (e.g., `is_mcs`, `is_modally_saturated`)
  - [ ] Conversion: `to_` or `of_` (e.g., `canonical_of_mcs`)
- [ ] Identify inconsistently named definitions
- [ ] Rename with deprecation aliases if heavily used externally
- [ ] Update call sites
- [ ] Verify: `lake build` passes

**Timing:** 1.5 hours

**Files to modify:**
- Various files across `Theories/Bimodal/Metalogic/` - naming improvements
- Potentially create `Theories/Bimodal/Metalogic/Deprecated.lean` for backward-compat aliases

**Verification:**
- `lake build` completes successfully
- Naming conventions document created or updated

---

### Phase 9: Update Documentation [NOT STARTED]

- **Dependencies:** Phase 8
- **Goal:** Update SORRY_REGISTRY.md and add legacy path markers to deprecated modules.

**Tasks:**
- [ ] Update `docs/project-info/SORRY_REGISTRY.md`:
  - [ ] Change total from 46 to 7 (after Phase 2 archival)
  - [ ] Remove references to monolithic `Completeness.lean` sorry counts
  - [ ] Document current sorry locations:
    - [ ] `Domain/DiscreteTimeline.lean` - 5 sorries (SuccOrder/PredOrder/IsSuccArchimedean)
    - [ ] `Canonical/ConstructiveFragment.lean` - 2 sorries (forward/backward reachability)
  - [ ] Update "Last Updated" date
- [ ] Add legacy path markers to `BFMCSTruth.lean` header:
  - [ ] Comment: "Legacy path - prefer `canonical_truth_lemma` from CanonicalConstruction.lean for new proofs"
- [ ] Add legacy path markers to `TruthLemma.lean` header (same comment)
- [ ] Update `IMPLEMENTATION_STATUS.md` if affected
- [ ] Verify: All documentation reflects current state

**Timing:** 1 hour

**Files to modify:**
- `docs/project-info/SORRY_REGISTRY.md` - comprehensive update
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - add legacy marker
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - add legacy marker
- `docs/project-info/IMPLEMENTATION_STATUS.md` - update if needed

**Verification:**
- SORRY_REGISTRY.md counts match actual `grep` results
- Legacy markers clearly visible in affected files

---

### Phase 10: Final Verification and Summary [NOT STARTED]

- **Dependencies:** Phase 9
- **Goal:** Comprehensive verification that all refactoring goals are met.

**Tasks:**
- [ ] Run full `lake build` - must pass with no errors
- [ ] Run sorry count verification:
  - [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard`
  - [ ] Confirm count is 7 or less
- [ ] Verify no thin aliases remain:
  - [ ] `grep -n "diamondFormula\|dne_theorem'\|dni_theorem\|set_mcs_modal_saturation_forward" Theories/Bimodal/Metalogic/**/*.lean`
- [ ] Verify no duplicate theorem bodies:
  - [ ] Spot-check `set_mcs_all_future_all_future` appears in only one file
- [ ] Verify unused definitions removed:
  - [ ] Spot-check `IsConstantFamily`, `bmcs_valid`, etc. no longer exist
- [ ] Create implementation summary at `specs/970_review_metalogic_for_publication/summaries/implementation-summary-20260315.md`

**Timing:** 30 minutes

**Files to modify:**
- `specs/970_review_metalogic_for_publication/summaries/implementation-summary-20260315.md` - create

**Verification:**
- All verification commands pass
- Summary document captures all changes

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors after each phase
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard | wc -l` returns 7 or less
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/**/*.lean | grep -v Boneyard` shows no new axioms

### General
- [ ] All removed definitions verified to have zero external usage before removal
- [ ] Import graph remains valid (no circular dependencies introduced)
- [ ] Documentation accurately reflects codebase state

## Artifacts & Outputs

- `specs/970_review_metalogic_for_publication/plans/implementation-001.md` (this file)
- `specs/970_review_metalogic_for_publication/summaries/implementation-summary-20260315.md` (Phase 10)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (Phase 1 - new file)
- Updated `docs/project-info/SORRY_REGISTRY.md` (Phase 9)

## Rollback/Contingency

If any phase introduces breaking changes that cannot be resolved:
1. Use `git stash` or `git checkout` to revert phase changes
2. Mark phase as `[BLOCKED]` with specific blocker description
3. Continue with subsequent phases if they do not depend on blocked phase
4. Report blocked phases in implementation summary for user review

For the blocking Phase 1 (extraction), if dependencies prove more complex than anticipated:
- Create minimal extraction (only absolutely required definitions)
- Defer remaining extraction to follow-up task
- Mark `TemporalCoherentConstruction.lean` as "deprecated but retained" rather than archived
