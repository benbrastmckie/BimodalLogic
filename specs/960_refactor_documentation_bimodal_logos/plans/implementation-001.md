# Implementation Plan: Task #960

- **Task**: 960 - Refactor documentation for bimodal Logos fragment
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/960_refactor_documentation_bimodal_logos/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Refactor all documentation to reframe this repository as a Bimodal Logic implementation (the bimodal fragment of the Logos) rather than a "Logos project with Bimodal fragment." The primary work involves rewriting the root README.md to focus on the bimodal logic for tense and modality, moving Logos-specific content to the boneyard directory in the Logos repository, and updating subsidiary documentation files to remove broken Logos references.

### Research Integration

Integrated from `reports/research-001.md`:
- Identified 8 documentation files requiring updates
- Verified boneyard destination exists at `/home/benjamin/Projects/Logos/Theory/docs/boneyard/`
- Extracted Logos description from logos-labs.ai for brief inclusion
- Confirmed Theories/Logos/ does NOT exist - only Theories/Bimodal/
- Located paper reference: https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf

## Goals & Non-Goals

**Goals**:
- Reframe repository identity from "Logos with Bimodal" to "Bimodal Logic (fragment of Logos)"
- Feature the "Construction of Possible Worlds" paper prominently
- Include brief Logos explanation (2-3 sentences) with link to logos-labs.ai
- Fix all broken links to non-existent Theories/Logos/ paths
- Move Logos-specific content to boneyard for later integration

**Non-Goals**:
- Rewriting the Bimodal technical documentation (it is already accurate)
- Creating new documentation for features not implemented
- Modifying any Lean code files
- Extensive Logos explanation (keep brief, provide link)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken links after refactor | M | M | Verify all internal links after changes |
| Lost valuable Logos content | H | L | Move to boneyard rather than delete; create clear migration record |
| Confusion about project scope | M | M | Clear "Logos Connection" section explaining relationship |
| Boneyard directory issues | L | L | Verified boneyard exists in research phase |

## Implementation Phases

### Phase 1: Create Boneyard Content [NOT STARTED]

- **Dependencies:** None
- **Goal:** Preserve Logos-specific content from root README.md in the Logos repository boneyard

**Tasks**:
- [ ] Read current README.md to identify content to move
- [ ] Create `/home/benjamin/Projects/Logos/Theory/docs/boneyard/proofchecker-logos-content.md`
- [ ] Move Logos Architecture section (layer diagrams and descriptions)
- [ ] Move Application Domains section (Medical Planning, Legal Reasoning, Multi-Agent Coordination)
- [ ] Move RL Training section (Dual verification training context)
- [ ] Move Motivations section (Logos-specific planning rationale)
- [ ] Add source attribution header indicating content came from ProofChecker README

**Timing**: 30 minutes

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/docs/boneyard/proofchecker-logos-content.md` - create new file

**Verification**:
- Boneyard file exists and contains all relocated content
- Content is properly formatted with source attribution

---

### Phase 2: Rewrite Root README.md [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Transform README.md to focus on Bimodal Logic as the primary subject with Logos as context

**Tasks**:
- [ ] Change title to "Bimodal Logic: Tense and Modality (TM)"
- [ ] Add prominent paper link at top
- [ ] Write new Overview section focused on bimodal logic implementation
- [ ] Add "The Logos Connection" section (2-3 sentences + link to logos-labs.ai)
- [ ] Update Quick Start / Getting Started to point to Bimodal examples
- [ ] Update Project Structure section to reflect actual directories (remove Theories/Logos references)
- [ ] Update all internal links to valid paths
- [ ] Remove or redirect Documentation section links that reference non-existent Logos paths
- [ ] Preserve Development and Contributing sections as-is

**Timing**: 60 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/README.md` - major rewrite

**Verification**:
- README focuses on Bimodal implementation
- Logos mentioned briefly with link
- No references to non-existent Theories/Logos/
- All internal links valid

---

### Phase 3: Update docs/ Directory Files [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Update all documentation files in docs/ to remove broken Logos references

**Tasks**:
- [ ] Update `docs/README.md` - remove Logos references, update as Bimodal docs hub
- [ ] Update `docs/research/bimodal-logic.md` - fix broken Logos links, make standalone
- [ ] Update `docs/research/README.md` - remove Logos research references
- [ ] Update `docs/user-guide/README.md` - remove Logos quick start references
- [ ] Update `docs/reference/README.md` - remove Logos glossary/axiom references
- [ ] Update `docs/project-info/README.md` - remove Logos status references

**Timing**: 45 minutes

**Files to modify**:
- `docs/README.md` - update
- `docs/research/bimodal-logic.md` - minor updates
- `docs/research/README.md` - update
- `docs/user-guide/README.md` - update
- `docs/reference/README.md` - update
- `docs/project-info/README.md` - update

**Verification**:
- No references to Theories/Logos/ in any docs/ file
- All links within docs/ are valid
- Documentation accurately reflects Bimodal focus

---

### Phase 4: Update Theories/README.md [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Remove Logos section from Theories directory README

**Tasks**:
- [ ] Read current Theories/README.md
- [ ] Remove Logos Theory section
- [ ] Ensure Bimodal is presented as the primary (and only) theory
- [ ] Verify internal links are accurate

**Timing**: 15 minutes

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/README.md` - update

**Verification**:
- No Logos section in Theories/README.md
- Bimodal accurately described
- All links valid

---

### Phase 5: Verify and Test [NOT STARTED]

- **Dependencies:** Phase 3, Phase 4
- **Goal:** Comprehensive verification that all documentation is consistent and links work

**Tasks**:
- [ ] Search for any remaining "Theories/Logos" references: `grep -r "Theories/Logos" .`
- [ ] Search for any remaining broken Logos links: `grep -r "Logos/docs" .`
- [ ] Verify all internal markdown links resolve
- [ ] Read through updated README.md for coherence
- [ ] Confirm boneyard content in Logos repo is complete

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Zero results for `grep -r "Theories/Logos" .` (excluding .git)
- Zero results for `grep -r "Logos/docs" .` (excluding .git)
- Manual review confirms documentation coherence

## Testing & Validation

- [ ] `grep -rn "Theories/Logos" . --exclude-dir=.git` returns empty
- [ ] `grep -rn "Logos/docs" . --exclude-dir=.git` returns empty
- [ ] All markdown internal links tested (manual spot check)
- [ ] README.md renders correctly (visual inspection)
- [ ] Boneyard file exists and is properly attributed

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- `/home/benjamin/Projects/Logos/Theory/docs/boneyard/proofchecker-logos-content.md` (new)
- Updated documentation files (README.md, docs/, Theories/README.md)
- summaries/implementation-summary-{DATE}.md (upon completion)

## Rollback/Contingency

If refactoring causes issues:
1. Use git to revert all documentation changes: `git checkout HEAD~N -- README.md docs/ Theories/README.md`
2. Boneyard content in Logos repo can remain (no negative impact)
3. Incremental commits per phase allow selective rollback
