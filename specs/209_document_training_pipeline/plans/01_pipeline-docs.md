# Implementation Plan: Task #209

- **Task**: 209 - Document training pipeline components
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/209_document_training_pipeline/reports/01_pipeline-components.md
- **Artifacts**: plans/01_pipeline-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Create the authoritative reference document for the BimodalLogic training data pipeline at `Theories/Bimodal/Automation/TRAINING_PIPELINE.md`. The document synthesizes research findings from the 01_pipeline-components.md report into a reader-facing guide covering the 6 Lean modules, Python helper, executable targets, dual-signal architecture, pipeline flow, JSON/JSONL schemas, BimodalHarness integration, feasibility gate results, and recommended next steps.

### Research Integration

Research report `01_pipeline-components.md` provides complete API documentation for all 6 Lean modules (DataExport, FormulaEnumerator, DatasetGenerator, EnrichedCountermodel, DatasetExporter, DatasetValidator), the Python tensor converter, executable targets, pipeline flow diagrams, BimodalHarness integration details, JSONL schema, and Tier 1 validation results. All technical content for the document is available in the research report; the implementation task is to organize and present it as a coherent reference document.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Produce a single, self-contained markdown document at `Theories/Bimodal/Automation/TRAINING_PIPELINE.md`
- Document all 6 Lean modules with purpose, key API, and design decisions
- Explain the dual-signal architecture (proof traces + countermodels)
- Diagram the end-to-end pipeline flow from enumeration to BimodalHarness consumption
- Document both JSON and JSONL dataset schemas
- Explain the BimodalHarness integration (artifact-only, schema contract, sync mechanism)
- Include feasibility gate criteria and Tier 1 results
- Provide recommended next steps for improving the pipeline

**Non-Goals**:
- Modifying any Lean source code
- Creating or updating BimodalHarness documentation
- Generating actual dataset files or running the pipeline
- Writing automated tests

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Schema details drift from code | M | L | Cross-reference research report against actual module source if uncertain |
| Document becomes stale after code changes | M | M | Include a "Last Updated" field and reference task 201/203 provenance |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Write TRAINING_PIPELINE.md [NOT STARTED]

**Goal**: Create the complete training pipeline reference document.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/TRAINING_PIPELINE.md`
- [ ] Write header with title, last-updated date, and provenance (tasks 201, 203, 209)
- [ ] Write "Overview" section: 3-4 paragraph summary of the pipeline purpose, dual-signal architecture, and relationship to BimodalHarness
- [ ] Write "Architecture: Dual-Signal Training Data" section explaining proof traces as positive signal (policy network) and countermodels as corrective signal (value network), with EnrichedCountermodel as the richer variant
- [ ] Write "Pipeline Flow" section with ASCII diagram showing FormulaEnumerator -> DatasetGenerator -> DatasetExport/DatasetExporter -> BimodalHarness, noting the two parallel export paths (JSONL streaming vs structured JSON)
- [ ] Write "Module Reference" section with subsections for each of the 6 Lean modules:
  - [ ] `DataExport.lean` -- JSON serialization primitives, Formula JSON schema (atom/bot/imp/box/untl/snce tags), RuleProfile, escaping
  - [ ] `FormulaEnumerator.lean` -- EnumConfig vs EnumParams APIs, bounded enumeration, LCG sampling, diversity metrics, three-constraint filtering
  - [ ] `DatasetGenerator.lean` -- labeling pipeline (decideAuto/decideOptimized), ProofTrace extraction, DifficultyMetrics and tiers, LabeledFormula structure
  - [ ] `EnrichedCountermodel.lean` -- enriched vs simple countermodel, branch formula retention, modal/temporal formula extraction, design rationale
  - [ ] `DatasetExporter.lean` -- structured JSON output, DatasetMetadata, stratified train/eval split, end-to-end generation functions
  - [ ] `DatasetValidator.lean` -- conformance tests (10 valid + 20 invalid), feasibility gate criteria (6 checks), DiversityReport
- [ ] Write "Executable Targets" section documenting `lake exe dataset_generator` (CLI flags, JSONL output, DatasetExport.lean entry point) and `lake exe dataset_validator` (conformance + feasibility gate, DatasetValidator.lean entry point)
- [ ] Write "Python Tensor Converter" section documenting `scripts/generate_dataset.py`: input format (JSON from DatasetExporter), output format (PyTorch .pt tensors), feature vector (5-dim from PatternKey), label encoding, usage examples
- [ ] Write "Dataset Schemas" section with JSONL record schema (from DatasetExport.lean) and structured JSON schema (from DatasetExporter.lean), including field descriptions
- [ ] Write "BimodalHarness Integration" section: artifact-only integration, `make sync-data` rsync, Python dataclass correspondence table, SCHEMA_VERSION contract, downstream tasks (tokenizer, serializer, PyTorch Dataset, MCTS, Z3 countermodel)
- [ ] Write "Feasibility Gate Results (Tier 1)" section: conformance test results (30/30), feasibility gate results table, root causes of gate failure (provability ratio imbalance, proof height uniformity), implications
- [ ] Write "Recommended Next Steps" section: theorem mining or biased enumeration for provability ratio, investigate proof height extraction, EnrichedCountermodel integration into main export path, medium/deep production runs (task 204), multi-representation export (task 207), contrastive pair generation (task 206), BMLogic-Bench curation (task 205)
- [ ] Write "Related Tasks" section linking to tasks 201, 203, 204, 205, 206, 207, 208

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/TRAINING_PIPELINE.md` - create new file (entire document)

**Verification**:
- File exists at `Theories/Bimodal/Automation/TRAINING_PIPELINE.md`
- Document contains all required sections (overview, architecture, pipeline flow, 6 module references, executables, Python converter, schemas, BimodalHarness integration, feasibility results, next steps)
- All 6 Lean modules documented with purpose and key API
- Both dataset schemas (JSONL and JSON) included
- BimodalHarness link present: https://github.com/benbrastmckie/BimodalHarness
- No broken internal references

## Testing & Validation

- [ ] File exists at the specified path
- [ ] All 6 Lean modules have dedicated subsections
- [ ] Both executable targets documented with usage examples
- [ ] Pipeline flow diagram included
- [ ] JSONL and JSON schemas documented
- [ ] BimodalHarness integration section includes sync mechanism and dataclass correspondence
- [ ] Feasibility gate results included with concrete numbers
- [ ] Document reads coherently as a standalone reference

## Artifacts & Outputs

- `Theories/Bimodal/Automation/TRAINING_PIPELINE.md` - The training pipeline reference document
- `specs/209_document_training_pipeline/plans/01_pipeline-docs.md` - This plan file

## Rollback/Contingency

Delete `Theories/Bimodal/Automation/TRAINING_PIPELINE.md` and revert the commit. No other files are modified by this task.
