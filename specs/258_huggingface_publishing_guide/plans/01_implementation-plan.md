# Implementation Plan: HF Publishing Guide in docs/

- **Task**: 258 - Create a Hugging Face publishing guide in docs/
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/258_huggingface_publishing_guide/reports/01_publishing-guide-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Create a user-facing Hugging Face publishing guide at
`docs/training/PUBLISHING_GUIDE.md` that synthesizes existing tooling
documentation from `data/hf-dataset/PUBLISHING.md` for an ML-researcher
audience. The guide covers dataset overview, consumer quick-start,
maintainer publishing workflow, and post-publish verification. Two
supporting updates complete the task: a `docs/training/README.md`
directory index and an updated `docs/README.md` training section listing.

### Research Integration

The research report identified that complete publishing infrastructure
already exists at `data/hf-dataset/` (upload.py, validate.py,
PUBLISHING.md). The guide synthesizes this for the `docs/` audience
rather than duplicating it. Key details integrated: four dataset configs
with record counts, CLI interface for upload/validate scripts, pending
upload status, 100-character line limit, and the record-count
discrepancy note (727 vs 777).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Create `docs/training/PUBLISHING_GUIDE.md` with audience-appropriate
  HF Hub publishing documentation for ML researchers
- Create `docs/training/README.md` as a directory index for the
  training/ subdirectory
- Update `docs/README.md` to list the new guide in the training/ section
- Cross-reference (not duplicate) the detailed operator guide at
  `data/hf-dataset/PUBLISHING.md`

**Non-Goals**:
- Modifying the existing `data/hf-dataset/PUBLISHING.md` or any upload
  tooling
- Publishing the dataset itself (upload is still pending)
- Creating CI/CD automation for dataset publishing

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dataset not yet published; guide may confuse readers | M | M | Add prominent status callout noting pending state; provide canonical URL for when it goes live |
| Record count discrepancy (727 in upload tooling vs 777 in data/README.md) | L | H | Use 727 to match upload tooling; note that future versions may increase the count |
| Guide content drifts from operator guide over time | L | M | Include explicit cross-reference to `data/hf-dataset/PUBLISHING.md` as canonical source |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Create Publishing Guide [NOT STARTED]

**Goal**: Create `docs/training/PUBLISHING_GUIDE.md` with comprehensive
HF Hub publishing documentation for ML researchers.

**Tasks**:
- [ ] Create `docs/training/PUBLISHING_GUIDE.md` with the following
      sections:
  - Title and migration status callout (pending upload)
  - Overview: BMLogic-Bench dataset, 4 configs, canonical URL
  - Quick Start for Consumers: `load_dataset(...)` one-liners and
    CLI download via `huggingface-cli`
  - Publishing Workflow for Maintainers: prerequisites, install
    deps, validate, dry-run, upload (cross-reference
    `data/hf-dataset/PUBLISHING.md` for full detail)
  - Post-Publish Verification: Python snippet and browser URL
  - NeurIPS Submission Extras: Croissant download, RAI fields
  - Dataset Card and Schema Maintenance: synchronization rule for
    JSONL schema changes
  - Troubleshooting: auth errors, upload timeouts, schema inference
  - Related Documentation: cross-references to operator guide,
    data/README.md, and PIPELINE.md
- [ ] Ensure 100-character line limit per docs/ standards
- [ ] Use ATX-style headings and language-annotated code fences

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `docs/training/PUBLISHING_GUIDE.md` - Create new file

**Verification**:
- File exists and follows docs/ formatting standards
- All cross-references point to valid files
- No content duplicated verbatim from operator guide

---

### Phase 2: Create Training Directory Index [NOT STARTED]

**Goal**: Create `docs/training/README.md` as a directory index listing
all files in the training/ subdirectory.

**Tasks**:
- [ ] Create `docs/training/README.md` with:
  - Directory purpose and audience description
  - File listing with descriptions (PIPELINE.md,
    PUBLISHING_GUIDE.md)
  - Cross-reference to related directories (data/,
    data/hf-dataset/)
- [ ] Follow DIRECTORY_README_STANDARD.md conventions

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `docs/training/README.md` - Create new file

**Verification**:
- File lists all documents in docs/training/
- Audience and purpose are clearly stated

---

### Phase 3: Update docs/README.md Training Section [NOT STARTED]

**Goal**: Add `PUBLISHING_GUIDE.md` to the training/ section listing in
`docs/README.md`.

**Tasks**:
- [ ] Add `PUBLISHING_GUIDE.md` entry to the `### training/` section
      in `docs/README.md`, following the existing format used for
      `PIPELINE.md`
- [ ] Add `README.md` entry to the training/ section listing
- [ ] Verify no broken links introduced

**Timing**: 10 minutes

**Depends on**: 1

**Files to modify**:
- `docs/README.md` - Update training/ section listing

**Verification**:
- Training section lists both PIPELINE.md and PUBLISHING_GUIDE.md
- Training section lists README.md as directory overview
- Links are valid relative paths

## Testing & Validation

- [ ] `docs/training/PUBLISHING_GUIDE.md` exists with all 9 sections
- [ ] `docs/training/README.md` exists with directory index
- [ ] `docs/README.md` training/ section lists the new files
- [ ] All cross-references to `data/hf-dataset/PUBLISHING.md`,
      `data/README.md`, and `docs/training/PIPELINE.md` are valid
- [ ] Line width does not exceed 100 characters in new files
- [ ] Status callout accurately reflects pending upload state

## Artifacts & Outputs

- `docs/training/PUBLISHING_GUIDE.md` - User-facing HF publishing guide
- `docs/training/README.md` - Training directory index
- `docs/README.md` - Updated with new file listings
- `specs/258_huggingface_publishing_guide/plans/01_implementation-plan.md` - This plan

## Rollback/Contingency

All changes are additive (two new files and one minor update to an
existing file). Rollback requires deleting the two new files and
reverting the `docs/README.md` edit. No existing functionality is
affected.
