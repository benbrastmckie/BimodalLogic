# Implementation Plan: Bimodal Logic Opensource Documentation

- **Task**: 947 - bimodal_logic_opensource_documentation
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/947_bimodal_logic_opensource_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan restructures project documentation to present Bimodal logic as the opensource foundational core (GPL-3.0 licensed) while positioning Logos as a private research extension that elaborates with hyperintensional operators. The restructuring addresses the current README which describes unimplemented Logos features prominently, replacing this with accurate documentation of what exists (complete Bimodal implementation) while briefly mentioning Logos as a future private extension.

### Research Integration

The research report (research-001.md) identified:
- Bimodal is fully implemented and production-ready (soundness, completeness, decidability proven)
- Logos currently exists only as a thin wrapper importing Bimodal; extensions are planned but not implemented
- GPL-3.0 license is already appropriate for open-core model
- Key files requiring revision: README.md, CONTRIBUTING.md, IMPLEMENTATION_STATUS.md, docs/README.md

## Goals & Non-Goals

**Goals**:
- Present Bimodal as the primary opensource product with clear value proposition
- Remove or relocate detailed descriptions of unimplemented Logos features
- Update contributor documentation to reflect Bimodal-focused contributions
- Maintain accurate information about Logos as a private research direction
- Ensure documentation accurately reflects what code exists

**Non-Goals**:
- Adding new code or changing the license
- Removing Logos from the codebase (it remains as a private extension namespace)
- Creating marketing materials beyond accurate technical documentation
- Changing GitHub repository name or URLs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Confusion between Bimodal/Logos naming | Medium | Medium | Clear separation in documentation, consistent terminology |
| Loss of vision communication | Medium | Low | Keep Logos roadmap in docs/research/ for reference |
| Breaking external links | Low | Low | Maintain references to key sections, use relative links |
| Contributor confusion | Low | Medium | Clear CONTRIBUTING.md with Bimodal focus |

## Implementation Phases

### Phase 1: README.md Complete Restructure [NOT STARTED]

- **Dependencies:** None
- **Goal:** Transform README.md from Logos-centric to Bimodal-centric presentation

**Tasks:**
- [ ] Change title from "Logos" to "Bimodal" - e.g., "Bimodal: A Complete Logic for Tense and Modality"
- [ ] Rewrite opening paragraph to lead with Bimodal as complete, standalone formal verification framework
- [ ] Move/remove layered architecture diagram (describes unimplemented Logos extensions)
- [ ] Relocate detailed Logos extension descriptions to docs/research/
- [ ] Update Quick Start and Features sections to focus on Bimodal capabilities
- [ ] Update Table of Contents to reflect new structure
- [ ] Revise "RL Training" section to reference Bimodal (dual verification still applies)
- [ ] Update "Motivations" section to focus on bimodal logic value proposition
- [ ] Update "Application Domains" - either remove (describes Logos extensions) or reframe for Bimodal
- [ ] Revise "Bimodal Theory" section - promote from subsection to primary content
- [ ] Update "Implementation Status" section to reflect Bimodal completion
- [ ] Update "Documentation" section to point to Bimodal resources
- [ ] Add brief "Related Projects" section mentioning Logos as private extension
- [ ] Update Citation section for Bimodal
- [ ] Keep License section (GPL-3.0 unchanged)
- [ ] Keep Contributing section (will be updated in Phase 2)

**Timing:** 1.5 hours

**Files to modify**:
- `README.md` - Complete restructure

**Verification**:
- README opens with Bimodal introduction
- No prominent descriptions of unimplemented Logos features
- Links to Bimodal demo and reference work correctly
- Table of contents accurately reflects new content

---

### Phase 2: CONTRIBUTING.md and Development Docs [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update contributor documentation to reflect Bimodal-focused opensource model

**Tasks:**
- [ ] Update docs/development/CONTRIBUTING.md title and introduction
- [ ] Replace "Logos" references with "Bimodal" throughout
- [ ] Update repository clone URLs to reflect project name
- [ ] Update example code references to use Bimodal imports
- [ ] Update PR/commit templates to reference Bimodal
- [ ] Revise "Types of Contributions" to focus on Bimodal-relevant areas
- [ ] Update AI-Assisted Development section references

**Timing:** 0.5 hours

**Files to modify**:
- `docs/development/CONTRIBUTING.md` - Replace Logos references with Bimodal

**Verification**:
- No "Logos" references except where explicitly noting private extension
- Clone/build instructions work correctly
- Test commands reference correct paths

---

### Phase 3: IMPLEMENTATION_STATUS.md and Project Info [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update project status documentation to reflect Bimodal as the primary implementation

**Tasks:**
- [ ] Rename title from "Implementation Status - Logos MVP" to "Implementation Status - Bimodal"
- [ ] Update overview to describe Bimodal as complete implementation
- [ ] Update module status tables (already Bimodal-focused, minor text updates)
- [ ] Remove or relocate references to "Logos methodology" - use "Bimodal methodology"
- [ ] Update file paths in verification commands if needed
- [ ] Ensure sorry/axiom tracking refers to Bimodal modules correctly

**Timing:** 0.5 hours

**Files to modify**:
- `docs/project-info/IMPLEMENTATION_STATUS.md` - Update naming and framing

**Verification**:
- Title reflects Bimodal focus
- Status accurately describes Bimodal implementation state
- All verification commands work

---

### Phase 4: Documentation Hub and Secondary Docs [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Update docs/README.md and ensure consistent terminology across documentation

**Tasks:**
- [ ] Update docs/README.md introduction to reflect Bimodal focus
- [ ] Update navigation and links to reflect restructured content
- [ ] Review docs/user-guide/ files for Logos references that should be Bimodal
- [ ] Update docs/research/README.md to clearly separate Bimodal (complete) from Logos (research)
- [ ] Ensure docs/research/bimodal-logic.md is referenced as comparison document
- [ ] Update Theories/README.md if it exists to reflect Bimodal as opensource core

**Timing:** 0.75 hours

**Files to modify**:
- `docs/README.md` - Update hub documentation
- `docs/research/README.md` - Clarify Bimodal vs Logos scope
- `Theories/README.md` - Update if exists

**Verification**:
- Documentation hub accurately represents project structure
- Cross-references between docs work correctly
- Research section clearly distinguishes implemented vs planned

---

### Phase 5: Final Review and Consistency Check [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Ensure consistent terminology and accurate links across all documentation

**Tasks:**
- [ ] Run grep for remaining "Logos" references that should be "Bimodal"
- [ ] Verify all internal documentation links work
- [ ] Verify external links (GitHub, papers, etc.) still valid
- [ ] Check that Bimodal demo and reference PDF links work
- [ ] Review docs/installation/ for any Logos-specific references
- [ ] Create summary of changes for commit message

**Timing:** 0.75 hours

**Files to modify**:
- Various - spot fixes for consistency

**Verification**:
- `grep -ri "logos" docs/` shows only intentional references to Logos extension
- All documentation links resolve correctly
- Build instructions in README and docs work

## Testing & Validation

- [ ] All documentation links resolve (no 404s)
- [ ] `lake build Bimodal` succeeds (confirms code references correct)
- [ ] README Quick Start instructions work as documented
- [ ] CONTRIBUTING.md clone/build instructions work
- [ ] No unintentional "Logos" references in user-facing documentation (verified via grep)

## Artifacts & Outputs

- `specs/947_bimodal_logic_opensource_documentation/plans/implementation-001.md` (this file)
- `specs/947_bimodal_logic_opensource_documentation/summaries/implementation-summary-YYYYMMDD.md` (upon completion)
- Modified files:
  - `README.md` - Complete restructure
  - `docs/development/CONTRIBUTING.md` - Terminology updates
  - `docs/project-info/IMPLEMENTATION_STATUS.md` - Title and framing
  - `docs/README.md` - Hub updates
  - `docs/research/README.md` - Scope clarification
  - Various other docs - consistency fixes

## Rollback/Contingency

If changes need to be reverted:
1. Git revert the commit(s) from this task
2. All original documentation preserved in git history
3. No code changes involved, purely documentation
4. If partial rollback needed, individual file reverts are straightforward
