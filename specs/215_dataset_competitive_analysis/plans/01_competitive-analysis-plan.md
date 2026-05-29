# Implementation Plan: Task #215

- **Task**: 215 - Competitive analysis and enhancement roadmap for BMLogic datasets
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: 214 (completed), 208 (completed)
- **Research Inputs**: specs/215_dataset_competitive_analysis/reports/01_competitive-analysis.md
- **Artifacts**: plans/01_competitive-analysis-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Produce a publication-ready competitive landscape report for the BMLogic datasets (bmlogic-bench, bmlogic-c5, bmlogic-c7, proof_steps) by synthesizing the research findings from the competitive analysis into final deliverables. The report will include a feature comparison matrix covering 11+ competitor benchmarks, a novelty assessment, gap analysis, and a prioritized enhancement roadmap with actionable specifications for each recommendation (R1-R7). The implementation also creates cross-logic transfer split metadata and a Croissant metadata skeleton, both of which are low-effort / high-impact enhancements identified by research.

### Research Integration

The research report (01_competitive-analysis.md) provides:
- Complete survey of 11 competitor benchmarks (FOLIO, ProofWriter, LogicNLI, PrOntoQA, FLUTE, ReClor, AR-LSAT, NaturalProofs, LeanDojo, miniF2F, INT) plus LTLBench as the closest temporal-logic competitor.
- Feature comparison matrix across 13 dimensions (domain, task format, verified labels, proof traces, countermodels, multi-representation, NL integration, scale, complexity tiers, difficulty calibration, Croissant, leaderboard, license).
- Novelty assessment identifying 4 high-novelty and 2 moderate-novelty dimensions.
- 7 prioritized enhancement recommendations (R1-R7) with effort and impact estimates.
- Risk/mitigation table covering NL quality, scale limits, LLM saturation, leaderboard maintenance, and ID uniqueness.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances dataset packaging and publication readiness. The ROADMAP.md does not have explicit dataset-related items, but the work supports the broader publication-quality goal referenced in Phase 5 of the roadmap.

## Goals & Non-Goals

**Goals**:
- Produce a final competitive landscape report suitable for inclusion in a NeurIPS Datasets track submission
- Create a feature comparison matrix (publication-quality table)
- Produce a prioritized enhancement roadmap with specifications for each recommendation
- Generate cross-logic transfer split definitions as a concrete, immediately actionable output
- Create a Croissant metadata skeleton (croissant.json) for HuggingFace discoverability

**Non-Goals**:
- Actually implementing NL paraphrase augmentation (R1) -- that is a separate, larger task
- Extending complexity tiers to c9/c11 (R2) -- requires significant computation
- Running LLM baseline calibration experiments (R4) -- requires API access and compute budget
- Building a HuggingFace leaderboard Space (R3 partial) -- requires Gradio app development
- Expanding proof_steps dataset to 200+ theorems (R7) -- requires Lean proof generation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Feature matrix becomes stale as competitors update | M | M | Include "as of 2026-05" date stamp; design for easy updates |
| Croissant schema changes before publication | L | L | Follow MLCommons 1.0 spec (stable); validate with tooling |
| Cross-logic splits have too few records in some categories | M | M | Validate split sizes against bmlogic-bench before finalizing |
| Enhancement priorities shift based on reviewer feedback | L | H | Present as ordered recommendations, not rigid commitments |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Competitive Landscape Report [COMPLETED]

**Goal**: Produce the final competitive landscape report as a standalone document suitable for submission appendix or supplementary material.

**Tasks**:
- [x] Create `data/competitive-landscape.md` with executive summary, methodology, and scope *(completed)*
- [x] Build the publication-quality feature comparison matrix (extending the research matrix with cleaner formatting, footnotes, and source citations) *(completed)*
- [x] Write the novelty assessment section with evidence for each claimed dimension of uniqueness *(completed)*
- [x] Write the gap analysis section identifying where BMLogic is weaker than competitors *(completed)*
- [x] Write the enhancement roadmap section with R1-R7 specifications (priority, effort, impact, dependencies, acceptance criteria) *(completed)*
- [x] Add a "Positioning Statement" section (2-3 paragraphs) suitable for dataset card or paper introduction *(completed)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `data/competitive-landscape.md` - New file: final competitive landscape report

**Verification**:
- Report contains all 11+ competitor benchmarks with accurate metrics
- Feature comparison matrix has no empty cells (all dimensions assessed for all benchmarks)
- Enhancement roadmap has priority, effort, impact for each of R1-R7
- Report is self-contained and readable without reference to the research report

---

### Phase 2: Cross-Logic Transfer Split Definitions [COMPLETED]

**Goal**: Define and validate cross-logic transfer splits (R5) as concrete metadata that can be used immediately for evaluation.

**Tasks**:
- [x] Write a Python script `data/scripts/generate_splits.py` that reads `bmlogic-bench.jsonl` and classifies each record into one of four sub-slices based on `pattern_key` fields: propositional-only (`modalDepth == 0 && temporalDepth == 0`), modal-only (`temporalDepth == 0 && modalDepth > 0`), temporal-only (`modalDepth == 0 && temporalDepth > 0`), bimodal (`modalDepth > 0 && temporalDepth > 0`) *(completed)*
- [x] Run the script and validate that all 727 benchmark records are classified into exactly one slice *(completed: 97+144+247+239=727 verified)*
- [x] Report split sizes and valid-rate distribution per slice *(completed: prop-only 97, modal-only 144, temporal-only 247, bimodal 239)*
- [x] Output a `data/bmlogic-bench-splits.json` metadata file documenting the split definitions, record counts, and valid rates *(completed)*

**Timing**: 1 hour

**Depends on**: 1 (needs the report structure to know where split results are referenced)

**Files to modify**:
- `data/scripts/generate_splits.py` - New file: split generation and validation script
- `data/bmlogic-bench-splits.json` - New file: split metadata output

**Verification**:
- Script runs without errors on current `data/bmlogic-bench.jsonl`
- All 727 records assigned to exactly one slice (sum of slices == 727)
- Each slice has at least 10 records (otherwise the slice is too small to be useful)
- Split metadata file has counts and valid rates per slice

---

### Phase 3: Croissant Metadata Skeleton [COMPLETED]

**Goal**: Create a Croissant (MLCommons 1.0) metadata skeleton for the BMLogic dataset, enabling HuggingFace auto-discovery and machine-readable dataset description.

**Tasks**:
- [x] Create `data/croissant.json` following the MLCommons Croissant 1.0 specification *(completed)*
- [x] Include dataset-level metadata: name, description, URL, license (MIT), citation, creators *(completed)*
- [x] Define distribution entries for each JSONL file (bmlogic-bench, bmlogic-c5, bmlogic-c7, proof_steps) *(completed: 5 distributions including splits JSON)*
- [x] Define record-level field descriptions with semantic types for all 14 fields in the multi-representation schema *(completed: 3 recordSets covering training v2, benchmark v1, proof steps)*
- [x] Add task description (formal-provability-classification) with evaluation metrics (accuracy, F1) *(completed: 2 tasks)*
- [x] Validate JSON structure is well-formed *(completed: python3 json.load succeeded)*

**Timing**: 1 hour

**Depends on**: 1 (needs the competitive landscape report to accurately describe the dataset's positioning)

**Files to modify**:
- `data/croissant.json` - New file: Croissant metadata following MLCommons 1.0 spec

**Verification**:
- JSON is valid and parseable
- All four JSONL datasets are listed as distributions
- Field descriptions match actual schema in the JSONL files
- License, citation, and creator information is accurate

---

### Phase 4: Integration and Documentation Update [COMPLETED]

**Goal**: Integrate all outputs, update data/README.md with competitive analysis references, and verify consistency across all deliverables.

**Tasks**:
- [x] Update `data/README.md` to reference the competitive landscape report and link to the enhancement roadmap *(completed)*
- [x] Add a "Competitive Position" subsection to data/README.md summarizing the key findings (3-5 bullet points) *(completed: 5 bullet points + enhancement roadmap summary)*
- [x] Add a "Cross-Logic Splits" subsection to data/README.md documenting the transfer split definitions *(completed: table with 4 slices, counts, and valid rates)*
- [x] Add a "Croissant Metadata" subsection to data/README.md explaining the croissant.json file *(completed)*
- [x] Cross-check all numbers in the competitive landscape report against actual dataset files (record counts, field counts, valid rates) *(completed: all numbers verified against JSONL files)*
- [x] Verify all file paths and cross-references are correct *(completed: all 4 new files confirmed to exist)*

**Timing**: 1 hour

**Depends on**: 2, 3

**Files to modify**:
- `data/README.md` - Update: add competitive position, splits, and Croissant sections

**Verification**:
- data/README.md has no broken internal references
- Record counts in the report match actual JSONL file line counts
- All new files (competitive-landscape.md, generate_splits.py, bmlogic-bench-splits.json, croissant.json) are referenced from README.md
- Enhancement roadmap items R1-R7 are cross-referenced with data/README.md "Future Work" or equivalent section

## Testing & Validation

- [ ] All new Python scripts run without errors
- [ ] All new JSON files are valid JSON
- [ ] Record counts in the competitive landscape report match actual dataset sizes
- [ ] Cross-logic split sizes sum to 727 (total bmlogic-bench records)
- [ ] Croissant metadata field names match actual JSONL field names
- [ ] No broken file references in data/README.md or competitive-landscape.md

## Artifacts & Outputs

- `data/competitive-landscape.md` - Final competitive landscape report with feature matrix and enhancement roadmap
- `data/scripts/generate_splits.py` - Cross-logic transfer split generation script
- `data/bmlogic-bench-splits.json` - Split metadata with counts and valid rates
- `data/croissant.json` - Croissant metadata skeleton for HuggingFace
- `data/README.md` - Updated with competitive position, splits, and Croissant references

## Rollback/Contingency

All changes are additive (new files plus README updates). Rollback is straightforward: delete new files and revert README.md changes via git. No existing functionality is modified or removed.
