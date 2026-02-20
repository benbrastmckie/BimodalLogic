# Implementation Plan: Task #915

- **Task**: 915 - Document BFMCS proof architecture and remaining lacunae
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: Task 914 (BFMCS rename) - completed
- **Research Inputs**: specs/915_document_bfmcs_proof_architecture/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan creates comprehensive documentation explaining the BFMCS/BMCS two-level bundling architecture used in the TM logic completeness proof. The documentation will cover the ontology (BFMCS as temporal families, BMCS as modal bundles), propagation mechanics (G-content automatic vs F-obligations explicit), the consistency argument via `temporal_witness_seed_consistent`, and a precise inventory of the 4 remaining sorries in DovetailingChain.lean with resolution paths.

### Research Integration

Integrated findings from research-001.md:
- BFMCS/BMCS structure definitions and semantic roles identified
- GContent seeding mechanism documented with proof references
- 4 sorries located at lines 606, 617, 633, 640 in DovetailingChain.lean
- Cross-sign propagation and witness construction challenges characterized
- Consistency lemma `temporal_witness_seed_consistent` analyzed

## Goals & Non-Goals

**Goals**:
- Create a single comprehensive architecture document in docs/
- Explain the two-level bundling ontology clearly for future developers
- Document why G-content propagates automatically while F-obligations require tracking
- Provide precise location and resolution paths for all 4 sorries
- Include diagrams or structured explanations of data flow

**Non-Goals**:
- Actually implementing the sorry resolutions (that's Task 916)
- Updating doc comments in individual Lean files (could be follow-up)
- Creating formal proofs or Lean code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Documentation becomes outdated | Medium | Medium | Include version references to source files with line numbers |
| Explanation too technical for new developers | Medium | Low | Include overview section with intuitive explanations before details |
| Sorries change during documentation | Low | Low | Reference Task 916 for resolution; note documentation date |

## Implementation Phases

### Phase 1: Create Documentation Structure [COMPLETED]

- **Dependencies:** None
- **Goal:** Set up the architecture document with proper sections and outline

**Tasks**:
- [ ] Create `docs/bfmcs-architecture.md` with document header
- [ ] Add table of contents linking to all sections
- [ ] Create section stubs for: Ontology Overview, Propagation Mechanics, Consistency Theory, Lacunae Inventory, Completeness Chain

**Timing**: 30 minutes

**Files to modify**:
- `docs/bfmcs-architecture.md` - create new file with structure

**Verification**:
- Document exists with all section headings
- Table of contents links are in place

**Progress:**

**Session: 2026-02-20, sess_1771617450_e21aa5**
- Added: `docs/bfmcs-architecture.md` with complete structure (all 5 sections with subsections)
- Added: Executive summary capturing key insights
- Added: Table of contents with anchor links
- Completed: Phase 1 documentation structure

---

### Phase 2: Document Two-Level Bundling Ontology [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Explain BFMCS and BMCS structures with semantic roles

**Tasks**:
- [ ] Explain BFMCS as "single world history" - one MCS per time point with temporal coherence
- [ ] Document the four BFMCS coherence conditions: forward_G, backward_H, forward_F, backward_P
- [ ] Explain BMCS as "bundle of world histories" with modal coherence
- [ ] Document modal_forward and modal_backward conditions
- [ ] Explain why two levels are needed: temporal within history, modal across histories
- [ ] Include structure definitions (simplified from BFMCS.lean lines 80-98, BMCS.lean lines 82-113)
- [ ] Add visual explanation: BFMCS as timeline, BMCS as bundle of parallel timelines

**Timing**: 45 minutes

**Files to modify**:
- `docs/bfmcs-architecture.md` - populate Ontology Overview section

**Verification**:
- Both BFMCS and BMCS are clearly explained
- Reader can understand why two levels exist
- Source file references included

---

### Phase 3: Document Propagation Mechanics [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Explain G-content automatic propagation vs F-obligation explicit tracking

**Tasks**:
- [ ] Define GContent(M) = {phi | G(phi) in M} and HContent(M) = {phi | H(phi) in M}
- [ ] Explain GContent seeding: MCS_{t+1} seed includes GContent(MCS_t)
- [ ] Document why G propagates automatically via 4_G axiom: G(phi) -> G(G(phi))
- [ ] Explain why F-obligations cannot auto-propagate: F(psi) -> G(F(psi)) is invalid
- [ ] Document the semantic counter-example for F non-persistence
- [ ] Create propagation type summary table: G/H (automatic) vs F/P (witness tracking required)
- [ ] Reference DovetailingChain.lean lines 484-507 for proven G propagation lemmas

**Timing**: 45 minutes

**Files to modify**:
- `docs/bfmcs-architecture.md` - populate Propagation Mechanics section

**Verification**:
- G-content vs F-obligation asymmetry is clearly explained
- Semantic justification for F non-persistence included
- Table summarizes all four temporal operators

---

### Phase 4: Document Consistency Theory [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Explain the `temporal_witness_seed_consistent` argument

**Tasks**:
- [ ] State the theorem: TemporalWitnessSeed M psi = {psi} union GContent(M) is consistent when F(psi) in M
- [ ] Document the proof sketch (5 steps from research report)
- [ ] Explain why this enables F-witness construction
- [ ] Document `past_temporal_witness_seed_consistent` for P witnesses
- [ ] Explain the critical subtlety: F(psi) must be in the SAME M whose GContent is being extended
- [ ] Document the two resolution options for intermediate persistence
- [ ] Reference TemporalCoherentConstruction.lean lines 461-522

**Timing**: 30 minutes

**Files to modify**:
- `docs/bfmcs-architecture.md` - populate Consistency Theory section

**Verification**:
- Proof sketch is understandable
- Critical subtlety about F-persistence is explained
- Source references included

---

### Phase 5: Document Lacunae Inventory [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Precisely locate all 4 sorries and explain resolution paths

**Tasks**:
- [ ] Document Sorry 1 (line 606): forward_G when t < 0 - cross-sign propagation
- [ ] Document Sorry 2 (line 617): backward_H when t >= 0 - cross-sign propagation
- [ ] Document Sorry 3 (line 633): forward_F - witness construction with dovetailing
- [ ] Document Sorry 4 (line 640): backward_P - witness construction with dovetailing
- [ ] Explain cross-sign propagation challenge: forward/backward chains share MCS_0
- [ ] Explain witness construction challenge: dovetailing enumeration needed
- [ ] Document resolution priority: cross-sign (simpler) before witnesses (complex)
- [ ] Add resolution requirements for each sorry
- [ ] Reference Task 916 for F/P witness obligation tracking

**Timing**: 30 minutes

**Files to modify**:
- `docs/bfmcs-architecture.md` - populate Lacunae Inventory section

**Verification**:
- All 4 sorries documented with line numbers
- Resolution paths are clear
- Complexity assessment (cross-sign vs witness) included

---

### Phase 6: Document Completeness Chain and Finalize [COMPLETED]

- **Dependencies:** Phase 5
- **Goal:** Show how all pieces connect and finalize document

**Tasks**:
- [ ] Document the proof chain from bmcs_strong_completeness down to buildDovetailingChainFamily
- [ ] Show where sorries propagate in the chain (total: 4 in DovetailingChain + 1 in TemporalCoherentConstruction)
- [ ] Add references to key source files with line numbers
- [ ] Write executive summary at top of document
- [ ] Add version information and documentation date
- [ ] Review document for clarity and completeness
- [ ] Verify all cross-references work

**Timing**: 30 minutes

**Files to modify**:
- `docs/bfmcs-architecture.md` - populate Completeness Chain section, add executive summary

**Verification**:
- Proof chain is clear from top-level theorem to sorries
- Executive summary captures key points
- Document is self-contained and readable

## Testing & Validation

- [ ] Document builds without errors (no broken references)
- [ ] All source file references include line numbers and are accurate
- [ ] Table of contents links work
- [ ] Document is readable by someone unfamiliar with the codebase
- [ ] All 4 sorries are accounted for with resolution paths

## Artifacts & Outputs

- `docs/bfmcs-architecture.md` - Main architecture documentation
- `specs/915_document_bfmcs_proof_architecture/summaries/implementation-summary-20260220.md` - Implementation summary

## Rollback/Contingency

- If documentation approach doesn't work well, can restructure into multiple smaller documents
- If source code changes significantly, update line number references
- Document is standalone markdown; no code dependencies to revert
