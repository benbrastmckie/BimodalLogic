# Implementation Plan: Literature Second Research Wave

- **Task**: 111 - Identify and add literature sources from task 107 research to literature/README.md
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None (task 107 research reports already exist)
- **Research Inputs**: specs/111_literature_second_research_wave/reports/01_team-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Add sources identified during task 107 research (and the subsequent team research in task 111) to `literature/README.md`. The research report identified 15 new sources across three domains (strict-time Since/Until extensions, bimodal combination literature, and machine-checked formalizations) plus 2 sources from the task 107 reports not yet in the README. Three sources have free PDFs available for immediate download. The task also includes minor corrections to existing README entries (Hirsch-Hodkinson 1997 priority downgrade, Hodkinson-Reynolds 2006 truncation confirmation). Done when the README has a "Second Research Wave" section with all identified sources and the free PDFs are saved in `literature/`.

### Research Integration

Key findings from the team research report (01_team-research.md):
- 2 sources from task 107 reports missing from README (Burgess 1982b, Goldblatt 1992)
- 3 free PDFs available: Burgess 1982b (Project Euclid), Venema 1993 (author preprint), Obendrauf et al. 2024 (Dagstuhl DROPS)
- 1 GitHub repository to reference: FormalizedFormalLogic/Foundation
- ~11 paywalled sources to track for future acquisition
- Hirsch-Hodkinson 1997 should be downgraded from MEDIUM to LOW priority
- Hodkinson-Reynolds 2006 truncation confirmed (3 pages of 66)
- Publication-critical reminder: Xu 1988 still not obtained

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances documentation and literature collection. No direct roadmap items are addressed, but the literature collection supports the overall completeness effort (task 109) and eventual publication.

## Goals & Non-Goals

**Goals**:
- Download 3 freely available PDFs into `literature/` directory
- Add a "Second Research Wave" section to `literature/README.md` with all 15+ identified sources
- Organize sources by availability (free PDF obtained vs. paywalled/to acquire)
- Update existing README entries for Hirsch-Hodkinson 1997 and Hodkinson-Reynolds 2006
- Note the publication-critical status of Xu 1988

**Non-Goals**:
- Acquiring paywalled sources (tracked for future purchase/ILL)
- Creating markdown extracts for downloaded PDFs (separate task)
- Modifying any Lean source files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| PDF download URLs have changed or are unavailable | M | L | Research report verified URLs recently; fall back to noting "URL verified on date, re-check if download fails" |
| PDF file sizes too large for repository | L | L | Academic PDFs are typically <5MB; check before committing |
| README format inconsistency | L | L | Follow existing table format exactly |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

### Phase 1: Download Free PDFs [COMPLETED]

**Goal**: Obtain the 3 freely available PDFs and save them to `literature/`

**Tasks**:
- [ ] Download Burgess 1982b from Project Euclid: `https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-II-Time-periods/10.1305/ndjfl/1093870150.pdf`
- [ ] Save as `literature/Burgess_1982b_Axioms_for_tense_logic_II_Time_periods.pdf`
- [ ] Download Venema 1993 preprint from `https://staff.fnwi.uva.nl/y.venema/papers/vene-comp93.pdf`
- [ ] Save as `literature/Venema_1993_Since_and_Until.pdf`
- [ ] Download Obendrauf et al. 2024 from Dagstuhl DROPS: `https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28`
- [ ] Save as `literature/Obendrauf_2024_Lean_Formalization_Coalition_Logic.pdf`
- [ ] Verify all 3 PDFs are valid (non-zero size, actually PDF files)

**Timing**: 0.25 hours

**Depends on**: none

**Files to modify**:
- `literature/Burgess_1982b_Axioms_for_tense_logic_II_Time_periods.pdf` - new file
- `literature/Venema_1993_Since_and_Until.pdf` - new file
- `literature/Obendrauf_2024_Lean_Formalization_Coalition_Logic.pdf` - new file

**Verification**:
- All 3 PDF files exist in `literature/` and are non-empty
- File sizes are reasonable (100KB-5MB range)

---

### Phase 2: Add Second Research Wave Section [COMPLETED]

**Goal**: Add a comprehensive new section to `literature/README.md` documenting all sources identified in the second research wave

**Tasks**:
- [ ] Add `## Second Research Wave` section after the existing `## Citation Corrections` section
- [ ] Add introductory paragraph explaining the provenance (task 107 chain construction research, task 111 gap analysis)
- [ ] Add `### Obtained (PDF in literature/)` subsection with table for the 3 downloaded PDFs plus FormalizedFormalLogic/Foundation GitHub link
- [ ] Add `### Strict-Time Since/Until Extensions` subsection for Reynolds 1992, Gabbay-Hodkinson 1990, Reynolds 1994, Reynolds 1996, Venema 1993 (cross-ref to obtained)
- [ ] Add `### Bimodal Combination Literature` subsection for Thomason 1984, Caleiro et al. 2013, Finger-Gabbay 1992
- [ ] Add `### Machine-Checked Formalizations` subsection for Obendrauf et al. 2024 (cross-ref), FormalizedFormalLogic, LeanLTL 2025
- [ ] Add `### General References (Not Yet Obtained)` subsection for Goldblatt 1992, Segerberg 1970, Blackburn-de Rijke-Venema 2001
- [ ] Include DOIs, URLs, and access notes for each entry following the existing table format
- [ ] Note Xu 1988 publication-critical status with a callout

**Timing**: 0.75 hours

**Depends on**: 1

**Files to modify**:
- `literature/README.md` - add Second Research Wave section with all subsections

**Verification**:
- All 15 sources from the research report are represented
- Each entry has citation, relevance, and access information
- Table formatting is consistent with existing README tables

---

### Phase 3: Update Existing README Entries [COMPLETED]

**Goal**: Apply corrections and priority changes to existing entries based on research findings

**Tasks**:
- [ ] In "Not Yet Obtained" table, change Hirsch-Hodkinson 1997 relevance from `MEDIUM` to `LOW` with note: "Verbrugge 2004 provides the directly applicable step-by-step technique; cylindric algebra content is too distant from BX chain construction"
- [ ] In "Available (PDF + Markdown)" table, update Hodkinson-Reynolds 2006 Quality column to explicitly confirm truncation: "**Truncated**: only ToC + Introduction (3 of 66 pages, 51,937 bytes). Confirmed byte-identical to editor's hosted version. Full chapter requires Elsevier subscription or ILL."
- [ ] Add note to Hirsch-Hodkinson 1997 Access column mentioning the PostScript file is still accessible at `doc.ic.ac.uk/~imh/papers/cylindric5.ps.gz`

**Timing**: 0.25 hours

**Depends on**: 2

**Files to modify**:
- `literature/README.md` - update existing table entries

**Verification**:
- Hirsch-Hodkinson 1997 shows LOW priority
- Hodkinson-Reynolds 2006 has expanded truncation confirmation
- No other existing entries are inadvertently modified

## Testing & Validation

- [ ] All 3 new PDF files exist in `literature/` and are valid PDFs
- [ ] `literature/README.md` parses as valid Markdown (no broken tables)
- [ ] All 15+ sources from the research report appear in the README
- [ ] Existing entries are preserved (diff shows only additions and the 2 targeted modifications)
- [ ] No broken links in the README (URLs are syntactically valid)

## Artifacts & Outputs

- `literature/Burgess_1982b_Axioms_for_tense_logic_II_Time_periods.pdf` - Downloaded PDF
- `literature/Venema_1993_Since_and_Until.pdf` - Downloaded PDF
- `literature/Obendrauf_2024_Lean_Formalization_Coalition_Logic.pdf` - Downloaded PDF
- `literature/README.md` - Updated with Second Research Wave section and existing entry corrections

## Rollback/Contingency

If PDF downloads fail, the README section can still be written with "download pending" notes. If the README edit introduces formatting issues, revert with `git checkout literature/README.md` and retry with corrected formatting. All changes are additive (new section + minor edits to 2 existing rows), so rollback is straightforward.
