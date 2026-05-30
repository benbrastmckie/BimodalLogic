# Implementation Plan: Oracle Integration, Conformance, and Lean Soundness

- **Task**: 226 - Build standalone Z3 countermodel generator
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: Phases 1-2 block on ModelChecker task 103 (OracleProvider); Phase 3 independent
- **Research Inputs**: specs/226_build_standalone_z3_countermodel_generator/reports/02_team-research.md
- **Artifacts**: plans/02_oracle-integration-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: z3
- **Lean Intent**: true

## Overview

Task 226 has been revised from "build standalone Z3 infrastructure" to "integrate the refactored ModelChecker oracle, cross-validate against Lean classifications, and prove bounded model soundness in Lean." The ModelChecker at /home/benjamin/Projects/ModelChecker/ is being refactored as a pip-installable bmlogic-oracle (tasks 99-105 in that repo). Research confirmed the Z3 encoding IS sound relative to Lean semantics (all 6 truth constructors match). The definition of done is: (1) Python scripts that batch-enrich 48K+ invalid formulas with StructuredCountermodels, (2) a conformance test suite cross-validating oracle output, and (3) a Lean proof that bounded finite models constitute valid countermodels via the existing FiniteTaskFrame infrastructure.

### Research Integration

Key findings from Round 2 team research (4 teammates):
- ModelChecker Z3 encoding verified sound relative to Lean semantics (Teammate C, line-by-line comparison)
- FiniteTaskFrame already exists at TaskFrame.lean:284-300 with coercion to TaskFrame
- 48,114 invalid formulas with atom-only countermodels available for enrichment
- 1,552 timeout formulas potentially resolvable by Z3
- Core soundness theorem is nearly trivial (FiniteTaskFrame IS a TaskFrame; one falsifying model proves non-validity)
- Substantive Lean work is showing Z3 output constitutes valid WorldHistory objects (~200-400 lines)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task does not directly advance the completeness critical path (tasks 155/202). It provides:
- Negative training signal infrastructure for BimodalHarness MCTS training
- Opportunity to establish Z3 oracle soundness as independent metalogic result
- Enriched datasets for future model-guided proof search

## Goals & Non-Goals

**Goals**:
- Integrate bmlogic-oracle package for batch countermodel generation
- Enrich existing JSONL datasets (bmlogic-c5, bmlogic-c7) with structured countermodels
- Cross-validate oracle soundness against Lean tableau classifications (1,751 valid formulas must return None)
- Prove in Lean that bounded finite models satisfying frame axioms are genuine TaskFrame countermodels
- Establish coverage metrics (what percentage of 48K invalid formulas get structured countermodels)

**Non-Goals**:
- Implementing Z3 constraints from scratch (ModelChecker handles this)
- Achieving 100% countermodel coverage (incompleteness acceptable per task description)
- Performance optimization of the oracle (that is ModelChecker's concern)
- Modifying the ModelChecker codebase
- Resolving the GPL license issue (ModelChecker responsibility)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ModelChecker task 103 delayed | H | M | Phase 3 (Lean) starts immediately; Phases 1-2 wait |
| bmlogic-oracle API changes | M | L | Pin version in requirements; abstract behind thin wrapper |
| StructuredCountermodel format mismatch with Lean types | M | M | Define explicit JSON schema; validate before Lean parsing |
| WorldHistory construction fails for edge cases | M | L | Start with small model bounds (M=2,3); expand incrementally |
| Performance bottleneck at 48K formulas | L | M | Parallelize batch processing; accept partial coverage |
| GPL license not resolved before integration | H | M | Mark Phases 1-2 as BLOCKED; Phase 3 independent |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 3, 4 | -- |
| 2 | 1 | External: ModelChecker task 103 |
| 3 | 2 | 1 |
| 4 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Oracle Integration Scripts [NOT STARTED]

**Goal**: Create Python infrastructure to consume bmlogic-oracle and batch-enrich JSONL datasets with structured countermodels.

**Tasks**:
- [ ] Create `requirements-oracle.txt` with `bmlogic-oracle>=0.1.0` dependency
- [ ] Create `scripts/enrich_countermodels.py` that reads JSONL, calls oracle for invalid formulas, writes enriched JSONL
- [ ] Define StructuredCountermodel JSON schema (world states, accessibility, valuation, domain bounds)
- [ ] Add `structured_countermodel` field to JSONL output (backward-compatible: None for valid/timeout)
- [ ] Handle oracle timeout/failure gracefully (log, skip, continue)
- [ ] Add progress reporting and batch statistics output
- [ ] Test with small subset (100 formulas) before full batch

**Timing**: 4 hours

**Depends on**: External (ModelChecker task 103 OracleProvider implementation)

**Files to modify**:
- `requirements-oracle.txt` - New file: pip dependency specification
- `scripts/enrich_countermodels.py` - New file: batch enrichment pipeline
- `data/schemas/structured_countermodel.json` - New file: JSON schema for countermodel format

**Verification**:
- `pip install -r requirements-oracle.txt` succeeds
- Script processes 100-formula subset without errors
- Output JSONL contains valid `structured_countermodel` entries for invalid formulas
- Valid formulas have `null` countermodel field (oracle returns None)

---

### Phase 2: Conformance Test Suite [NOT STARTED]

**Goal**: Cross-validate oracle output against Lean tableau classifications to verify soundness empirically.

**Tasks**:
- [ ] Create `scripts/validate_oracle_conformance.py` with three test categories
- [ ] Soundness test: 1,751 valid formulas must ALL return None from oracle (zero false countermodels)
- [ ] Completeness metric: measure what % of 48,114 invalid formulas get countermodels
- [ ] Timeout resolution: check if oracle resolves any of 1,552 timeout formulas
- [ ] Cross-check countermodel structure: verify domain bounds, accessibility relation, valuation consistency
- [ ] Generate conformance report with pass/fail counts, failure analysis, coverage statistics
- [ ] Add CI-friendly exit codes (non-zero on soundness failure)

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `scripts/validate_oracle_conformance.py` - New file: conformance validation
- `scripts/conformance_report.py` - New file: report generation utilities

**Verification**:
- Soundness test passes (0 false countermodels for valid formulas)
- Coverage report generated with breakdown by dataset (c5/c7)
- Exit code 0 when soundness holds, non-zero otherwise
- Report includes timeout resolution count

---

### Phase 3: Lean Bounded Model Soundness - Core Theorem [NOT STARTED]

**Goal**: Prove in Lean that a bounded finite model (as produced by Z3) constitutes a valid countermodel, establishing that FiniteTaskFrame + valuation + falsifying assignment implies non-validity.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/OracleSoundness.lean` module
- [ ] State `bounded_model_sound`: given a FiniteTaskFrame, TaskModel, WorldHistory, and proof of falsification, derive non-validity
- [ ] Prove via `not_valid_of_countermodel` pattern (exists frame+model+history where formula is false implies not valid)
- [ ] Define `BoundedCountermodel` structure bundling FiniteTaskFrame + TaskModel + WorldHistory + falsification proof
- [ ] Prove `countermodel_implies_not_valid` as the main user-facing theorem
- [ ] Register in Metalogic module imports

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/OracleSoundness.lean` - New file: oracle soundness theorems
- `Theories/Bimodal/Metalogic.lean` - Add import for OracleSoundness

**Verification**:
- `lake build Bimodal.Metalogic.OracleSoundness` succeeds without sorry
- `#print axioms bounded_model_sound` shows only standard axioms (propext, Quot.sound, Classical.choice)
- Core theorem proven sorry-free

---

### Phase 4: Lean WorldHistory Construction Lemmas [NOT STARTED]

**Goal**: Prove that Z3 model output (finite domain, accessibility, valuation) can be assembled into valid WorldHistory objects satisfying the TaskFrame constraints.

**Tasks**:
- [ ] Define `FiniteWorldHistory` structure for bounded-domain histories
- [ ] Prove `finite_domain_convex`: bounded integer domains [−M, M] are convex
- [ ] Prove `finite_respects_task`: histories with finite state sets respect task frame constraints
- [ ] Prove `shift_closed_finite`: the set of finite histories is shift-closed when all worlds share the same state space
- [ ] Prove `finite_omega_valid`: the Omega set of finite histories satisfies the box semantics requirements
- [ ] Connect to existing `FiniteTaskFrame` coercion (TaskFrame.lean:284-300)

**Timing**: 8 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/OracleSoundness.lean` - Extend with WorldHistory construction lemmas
- `Theories/Bimodal/Semantics/WorldHistory.lean` - Potentially add finite-domain helper lemmas (if needed)

**Verification**:
- All lemmas compile without sorry
- `lake build Bimodal.Metalogic.OracleSoundness` succeeds
- WorldHistory construction is compatible with truth_at evaluation
- `lean_verify` on main theorems shows no sorryAx

---

### Phase 5: Integration Validation and Documentation [NOT STARTED]

**Goal**: End-to-end validation connecting Python oracle output to Lean soundness guarantees, with documentation of the certified oracle architecture.

**Tasks**:
- [ ] Create `scripts/generate_lean_test_cases.py`: convert sample oracle countermodels to Lean term format
- [ ] Add 3-5 concrete test theorems in OracleSoundness.lean using specific countermodel instances
- [ ] Document the certified oracle pipeline in a README section
- [ ] Verify full `lake build` passes with new module
- [ ] Write dataset enrichment instructions for future use

**Timing**: 2 hours (reduced: primarily documentation and wiring)

**Depends on**: 2, 3, 4

**Files to modify**:
- `scripts/generate_lean_test_cases.py` - New file: oracle-to-Lean converter
- `Theories/Bimodal/Metalogic/OracleSoundness.lean` - Add concrete test instances
- `data/README.md` - Update with enrichment pipeline documentation

**Verification**:
- Concrete countermodel instances type-check in Lean
- Full `lake build` passes
- Pipeline documentation is complete and accurate

## Testing & Validation

- [ ] Soundness: 1,751 valid formulas produce None from oracle (zero false positives)
- [ ] Coverage: measure % of 48,114 invalid formulas receiving structured countermodels
- [ ] Lean compilation: `lake build Bimodal.Metalogic.OracleSoundness` passes sorry-free
- [ ] Axiom audit: `#print axioms bounded_model_sound` shows only standard axioms
- [ ] Integration: sample countermodels from Python pass Lean type-checking as BoundedCountermodel instances
- [ ] Backward compatibility: enriched JSONL files readable by existing scripts (null countermodel field for valid/timeout)

## Artifacts & Outputs

- `specs/226_build_standalone_z3_countermodel_generator/plans/02_oracle-integration-plan.md` (this file)
- `requirements-oracle.txt` - Oracle dependency specification
- `scripts/enrich_countermodels.py` - Batch enrichment pipeline
- `scripts/validate_oracle_conformance.py` - Conformance test suite
- `scripts/generate_lean_test_cases.py` - Oracle-to-Lean converter
- `Theories/Bimodal/Metalogic/OracleSoundness.lean` - Bounded model soundness proofs
- `data/bmlogic-c5-enriched.jsonl` - Enriched dataset (when oracle available)
- `data/bmlogic-c7-enriched.jsonl` - Enriched dataset (when oracle available)

## Rollback/Contingency

- Phase 3-4 (Lean) are self-contained: if they fail, remove `OracleSoundness.lean` and its import line
- Phases 1-2 (Python) are new files only: remove scripts and requirements file to revert
- No existing files are modified destructively (only additions to `Metalogic.lean` import list and `data/README.md`)
- If ModelChecker task 103 is indefinitely delayed, Phases 1-2 remain BLOCKED; Phases 3-4 are still independently valuable as metalogic results
- If WorldHistory construction proves harder than estimated (Phase 4), scope down to the core theorem (Phase 3) which is nearly trivial
