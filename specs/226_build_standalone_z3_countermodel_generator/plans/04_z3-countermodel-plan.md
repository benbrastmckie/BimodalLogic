# Implementation Plan: Standalone Z3 Countermodel Generator

- **Task**: 226 - Build standalone Z3 countermodel generator for negative training signal
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None (standalone implementation within BimodalLogic)
- **Research Inputs**:
  - specs/226_build_standalone_z3_countermodel_generator/reports/01_team-research.md
  - specs/226_build_standalone_z3_countermodel_generator/reports/02_team-research.md
  - specs/226_build_standalone_z3_countermodel_generator/reports/03_team-research.md
- **Artifacts**: plans/04_z3-countermodel-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: z3
- **Lean Intent**: false

## Overview

Build a standalone Python package (`z3_oracle/`) within BimodalLogic that uses Z3 to generate structured countermodels as negative training signal. The package uses quantifier-free finite instantiation encoding (identified in Round 1 as 100-1000x faster than quantified Z3) to produce full task-frame countermodels with world histories, task relations, and temporal structure. Research confirmed the Z3 encoding approach is sound relative to Lean semantics: every countermodel found IS a valid countermodel. The package will be self-contained (no dependency on ModelChecker), pip-installable, and cross-validated against the existing bmlogic-bench dataset (387 formulas with known labels). Lean metalogic soundness formalization is deferred to a separate follow-up task per unanimous research recommendation.

### Research Integration

Key findings integrated from three rounds of team research (12 teammates total):

- **Quantifier-free encoding** (Round 1, Teammate B): Replace ForAll/Exists with finite conjunction/disjunction over bounded domain. Eliminates the performance bottleneck of ModelChecker's quantified encoding (2-30s per formula down to 1-50ms).
- **Box quantification is manageable** (Round 1, Teammate C): Box quantifies over N^M histories. At N=2, M=2 this is 4 histories (trivial for Z3). Progressive deepening handles larger bounds.
- **Z3 encoding is sound** (Round 2, Teammate C): Line-by-line comparison of ModelChecker Z3 constraints against Lean semantics shows all 6 truth constructors match. The one divergence (forward_comp without non-negative guard) is actually a theorem of the Lean axioms. Soundness guarantee is achievable.
- **3-tier hybrid architecture** (Round 1, Teammate B): Random sampling (Tier 0) -> QF Z3 at small bounds (Tier 1) -> iterative deepening (Tier 2). Expected to find countermodels for 95%+ of invalid formulas in under 50ms.
- **FiniteTaskFrame exists** (Round 2, Teammate D): Lean already has FiniteTaskFrame at TaskFrame.lean:284-300 with coercion to TaskFrame, enabling future soundness formalization.
- **Lean soundness deferred** (all rounds): Unanimous recommendation to defer the ~200-400 line Lean formalization to a separate task. Cross-validation against known labels provides empirical soundness.
- **StructuredCountermodel format** (Round 1): Must include world states, accessibility relation (task_rel), temporal structure (histories with domains), and atom valuation -- enabling GNN-based encodings for richer training signal vs existing atom-only countermodels.
- **EnrichedCountermodel already exists in Lean** (codebase): `Theories/Bimodal/Automation/EnrichedCountermodel.lean` provides enriched countermodels with modal/temporal formula annotations from tableau saturation. The Z3 oracle provides a complementary and independent countermodel source.

### Prior Plan Reference

The existing plan at `plans/02_oracle-integration-plan.md` followed Round 2's framing of "integrate external ModelChecker oracle." It had 5 phases totaling 20 hours, with Phases 1-2 blocked on ModelChecker task 103 and Phases 3-4 focused on Lean soundness formalization. Key lessons: (1) external dependency on ModelChecker creates a hard block -- the standalone approach from the original task description avoids this; (2) Lean soundness was estimated at 12 hours and unanimously recommended as a separate task; (3) the conformance testing approach (cross-validate against 1,751 valid formulas) is sound and reusable regardless of oracle implementation strategy.

### Roadmap Alignment

No ROADMAP.md items directly advanced by this task. The task provides negative training signal infrastructure for BimodalHarness MCTS training and dataset enrichment for bmlogic-bench.

## Goals & Non-Goals

**Goals**:
- Create a self-contained `z3_oracle/` Python package with pyproject.toml and z3-solver dependency
- Implement quantifier-free finite instantiation encoding of bimodal TM frame axioms and truth conditions
- Support progressive deepening: N=2,M=2 (fast) through N=4,M=4 (thorough)
- Extract StructuredCountermodels with world states, task_rel, histories, and atom valuation
- Cross-validate against bmlogic-bench.jsonl (387 formulas with known labels)
- Produce enriched JSONL datasets with structured_countermodel field
- Register as pip-installable package for BimodalHarness OracleProvider integration

**Non-Goals**:
- Lean metalogic soundness formalization (separate follow-up task)
- 100% countermodel coverage (bounded incompleteness is acceptable and expected)
- Modifying ModelChecker codebase
- Implementing dense/complete frame classes (Base frame only for now)
- Random model sampling pre-filter (Tier 0) -- nice-to-have optimization, not core deliverable
- VerifierProvider implementation (separate concern, identified in Round 3)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| QF encoding produces too many clauses at N=3+ M=3+ | M | M | Start at N=2,M=2 (4 histories); progressive deepening; benchmark scaling |
| Z3 Python bindings unavailable in project env | H | L | z3-solver is a standard pip package; test early in Phase 1 |
| Formula JSON parsing diverges from Lean DataExport format | M | L | Use exact 6-tag format from DataExport.lean; validate against bmlogic-bench.jsonl |
| Frame constraint encoding error (box/until/since) | H | M | Cross-validate: 387 known labels must match; 0 false countermodels for valid formulas |
| N^M history explosion at larger bounds | M | M | N=4,M=4 is 256 histories -- large but SAT-solvable; cap at N=4,M=4 |
| StructuredCountermodel schema incompatible with BimodalHarness | L | M | Design schema first; align with BimodalHarness OracleProvider protocol |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are sequential: each phase builds on the prior phase's output.

---

### Phase 1: Package Scaffold and Formula Parser [NOT STARTED]

**Goal**: Create the `z3_oracle/` package structure with pyproject.toml, Z3 dependency, and a JSON formula parser that handles the 6-tag bimodal TM formula format used by bmlogic-bench.

**Tasks**:
- [ ] Create `z3_oracle/` directory at project root with `pyproject.toml` (package name `bmlogic-z3-oracle`, dependency `z3-solver>=4.12.0`)
- [ ] Create `z3_oracle/src/bmlogic_oracle/__init__.py` with version and public API stubs
- [ ] Create `z3_oracle/src/bmlogic_oracle/formula.py` with `parse_formula_json()` that handles 6 constructors: `atom`, `neg`, `and`, `or`, `box`, `untl`, `snce` (and derived: `imp`, `iff`, `dia`, `top`, `bot`)
- [ ] Define `Formula` dataclass hierarchy matching Lean `Bimodal.Syntax.Formula` constructors
- [ ] Create `z3_oracle/tests/test_formula_parser.py` with test cases from bmlogic-bench.jsonl (parse first 50 formulas, verify round-trip)
- [ ] Verify `pip install -e z3_oracle/` succeeds and `import bmlogic_oracle` works
- [ ] Verify `from z3 import *` works after installation

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `z3_oracle/pyproject.toml` - New file: package configuration
- `z3_oracle/src/bmlogic_oracle/__init__.py` - New file: package init
- `z3_oracle/src/bmlogic_oracle/formula.py` - New file: formula parser and AST
- `z3_oracle/tests/test_formula_parser.py` - New file: parser tests

**Verification**:
- `pip install -e z3_oracle/` succeeds
- Parser correctly handles all 6 constructors from bmlogic-bench.jsonl
- Test suite passes: `cd z3_oracle && python -m pytest tests/test_formula_parser.py`

---

### Phase 2: Quantifier-Free Frame and Truth Encoding [NOT STARTED]

**Goal**: Implement the core Z3 encoding: frame constraints (nullity_identity, forward_comp, converse) and truth conditions (6 constructors) using quantifier-free finite instantiation over bounded N worlds and M time steps.

**Tasks**:
- [ ] Create `z3_oracle/src/bmlogic_oracle/encoding.py` with `FrameEncoder` class
- [ ] Implement Z3 variable creation: `atom_val[w][t][a]` (Bool), `task_rel[w][d][u]` (Bool), `history[sigma][t]` (Int/enum for world index) for bounded N,M
- [ ] Implement frame axiom constraints:
  - `nullity_identity`: task_rel(w,0,u) iff w=u
  - `forward_comp`: task_rel(w,d1+d2,u) iff exists v. task_rel(w,d1,v) and task_rel(v,d2,u)
  - `converse`: task_rel(w,-d,u) iff task_rel(u,d,w)
- [ ] Implement finite instantiation: replace ForAll with And, Exists with Or over bounded domain
- [ ] Implement history constraints:
  - `respects_task`: for all consecutive time pairs in history, task_rel(h(t), t2-t1, h(t2))
  - History domain: each history maps {0,...,M-1} -> {0,...,N-1}
  - Omega = all N^M possible histories (shift-closed by construction)
- [ ] Implement truth encoding for 6 constructors:
  - `atom(a)`: atom_val[w][t][a] where w = history(sigma, t)
  - `neg(phi)`: Not(truth(phi))
  - `and(phi, psi)`: And(truth(phi), truth(psi))
  - `box(phi)`: And over all histories sigma in Omega of truth(phi, sigma)
  - `untl(phi, psi)`: Or over future t' of (truth(psi, t') and And over (t,t') of truth(phi))
  - `snce(phi, psi)`: Or over past t' of (truth(psi, t') and And over (t',t) of truth(phi))
- [ ] Add `encode_formula(formula, N, M)` that builds full Z3 assertion set
- [ ] Create `z3_oracle/tests/test_encoding.py` with unit tests for each frame axiom and truth constructor at N=2, M=2

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `z3_oracle/src/bmlogic_oracle/encoding.py` - New file: frame constraints and truth encoding
- `z3_oracle/tests/test_encoding.py` - New file: encoding unit tests

**Verification**:
- Frame constraints are satisfiable for trivial cases (N=2, M=2)
- Known-valid formula `box(imp(a, a))` has no countermodel at N=2, M=2
- Known-invalid formula (from bmlogic-bench) produces SAT result
- Unit tests pass for each frame axiom in isolation

---

### Phase 3: Countermodel Extraction and Oracle API [NOT STARTED]

**Goal**: Extract StructuredCountermodels from Z3 satisfying assignments and build the public oracle API with progressive deepening (N=2,M=2 through N=4,M=4).

**Tasks**:
- [ ] Create `z3_oracle/src/bmlogic_oracle/countermodel.py` with `StructuredCountermodel` dataclass:
  - `n_worlds: int` -- number of world states
  - `m_steps: int` -- number of time steps
  - `worlds: list[int]` -- world state indices
  - `task_rel: dict[tuple[int,int,int], bool]` -- task_rel(w,d,u) truth table
  - `histories: list[list[int]]` -- list of histories (each is sequence of world indices)
  - `valuation: dict[tuple[int,int,str], bool]` -- atom_val(w,t,atom_name)
  - `falsifying_history: int` -- index of the history that falsifies the formula
  - `falsifying_time: int` -- time step where formula is false
- [ ] Implement `extract_countermodel(z3_model, N, M, formula)` that reads Z3 model values and constructs StructuredCountermodel
- [ ] Implement `StructuredCountermodel.to_json()` and `StructuredCountermodel.from_json()` for serialization
- [ ] Create `z3_oracle/src/bmlogic_oracle/oracle.py` with public API:
  - `find_countermodel(formula_json, max_N=4, max_M=4, timeout_ms=5000) -> StructuredCountermodel | None`
  - Progressive deepening: try (2,2) -> (2,3) -> (3,3) -> (3,4) -> (4,4)
  - Return first countermodel found, or None if all bounds exhausted/timeout
- [ ] Add batch API: `find_countermodels_batch(formulas_json, ...) -> list[StructuredCountermodel | None]`
- [ ] Create `z3_oracle/tests/test_oracle.py` with integration tests:
  - 10 known-valid formulas -> all return None
  - 10 known-invalid formulas -> all return StructuredCountermodel
  - Timeout handling works correctly

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `z3_oracle/src/bmlogic_oracle/countermodel.py` - New file: countermodel data structure and extraction
- `z3_oracle/src/bmlogic_oracle/oracle.py` - New file: public API with progressive deepening
- `z3_oracle/tests/test_oracle.py` - New file: integration tests

**Verification**:
- `find_countermodel` returns None for `box(imp(a, a))` and similar tautologies
- `find_countermodel` returns valid StructuredCountermodel for known-invalid formulas
- StructuredCountermodel JSON round-trips correctly
- Progressive deepening escalates bounds correctly
- Timeout produces None (not an error)

---

### Phase 4: Cross-Validation Against bmlogic-bench [NOT STARTED]

**Goal**: Run the oracle against all 387 bmlogic-bench formulas to empirically validate soundness (no false countermodels for valid formulas) and measure coverage (what percentage of invalid formulas get countermodels).

**Tasks**:
- [ ] Create `z3_oracle/tests/test_conformance.py` that loads `data/bmlogic-bench.jsonl`
- [ ] Soundness test: all formulas labeled "valid" (count varies by dataset) must return None -- zero tolerance for false countermodels
- [ ] Completeness metric: measure percentage of "invalid" formulas that receive countermodels
- [ ] Verify extracted countermodels are structurally valid:
  - task_rel satisfies nullity_identity, forward_comp, converse
  - Histories respect task relation
  - Falsifying assignment actually makes the formula false
- [ ] Generate conformance report: pass/fail counts, coverage percentage, timing statistics per formula
- [ ] Create `scripts/run_conformance.py` convenience script that runs the full conformance suite and outputs a summary

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `z3_oracle/tests/test_conformance.py` - New file: conformance test suite
- `scripts/run_conformance.py` - New file: conformance runner script

**Verification**:
- Soundness: 0 false countermodels for valid formulas (mandatory pass criterion)
- Coverage: report shows percentage of invalid formulas with countermodels (target: >90%)
- Conformance report generated with timing breakdown
- All extracted countermodels pass structural validation

---

### Phase 5: Dataset Enrichment Pipeline and Entry Point Registration [NOT STARTED]

**Goal**: Create the batch enrichment pipeline that adds structured_countermodel fields to existing JSONL datasets, and register the package as a BimodalHarness OracleProvider entry point.

**Tasks**:
- [ ] Create `scripts/enrich_countermodels.py` that:
  - Reads input JSONL (bmlogic-c5.jsonl or bmlogic-c7.jsonl)
  - Filters for invalid formulas (label = "invalid" or "timeout")
  - Calls oracle for each formula with progress bar
  - Writes enriched JSONL with `structured_countermodel` field (null for valid/unresolved)
  - Reports statistics: enriched count, skipped count, timeout resolution count, total time
- [ ] Add `[project.entry-points."bimodal_harness.oracle_providers"]` section to pyproject.toml for BimodalHarness discovery
- [ ] Create `z3_oracle/src/bmlogic_oracle/provider.py` implementing the OracleProvider protocol (thin wrapper around oracle.py)
- [ ] Test enrichment on bmlogic-c5.jsonl (1,513 formulas -- small enough for full batch)
- [ ] Document usage in `z3_oracle/README.md`: installation, CLI usage, API usage, conformance testing

**Timing**: 4 hours

**Depends on**: 4

**Files to modify**:
- `scripts/enrich_countermodels.py` - New file: batch enrichment pipeline
- `z3_oracle/src/bmlogic_oracle/provider.py` - New file: OracleProvider protocol implementation
- `z3_oracle/pyproject.toml` - Add entry points section
- `z3_oracle/README.md` - New file: package documentation

**Verification**:
- Enrichment of bmlogic-c5.jsonl completes successfully
- Output JSONL is valid JSON lines with backward-compatible schema
- `pip install -e z3_oracle/ && python -c "from bmlogic_oracle.provider import Z3OracleProvider"` works
- README documents all usage modes
- Entry point is discoverable: `python -c "from importlib.metadata import entry_points; print([e for e in entry_points().get('bimodal_harness.oracle_providers', [])])"`

## Testing & Validation

- [ ] Unit tests: formula parser handles all 6 constructors correctly
- [ ] Unit tests: frame constraints are satisfiable at N=2, M=2
- [ ] Unit tests: truth encoding matches expected results for simple formulas
- [ ] Integration test: progressive deepening finds countermodels for known-invalid formulas
- [ ] Soundness: 0 false countermodels for valid formulas in bmlogic-bench
- [ ] Coverage: >90% of invalid formulas in bmlogic-bench receive countermodels
- [ ] Structural validation: extracted countermodels satisfy frame axioms
- [ ] Performance: median solve time <100ms at N=2, M=2
- [ ] Batch test: enrichment of bmlogic-c5.jsonl completes within reasonable time
- [ ] Package: `pip install -e z3_oracle/` succeeds; imports work

## Artifacts & Outputs

- `specs/226_build_standalone_z3_countermodel_generator/plans/04_z3-countermodel-plan.md` (this file)
- `z3_oracle/` - Self-contained Python package at project root
- `z3_oracle/pyproject.toml` - Package configuration with z3-solver dependency
- `z3_oracle/src/bmlogic_oracle/` - Source package (formula.py, encoding.py, countermodel.py, oracle.py, provider.py)
- `z3_oracle/tests/` - Test suite (test_formula_parser.py, test_encoding.py, test_oracle.py, test_conformance.py)
- `z3_oracle/README.md` - Package documentation
- `scripts/enrich_countermodels.py` - Batch enrichment pipeline
- `scripts/run_conformance.py` - Conformance test runner

## Rollback/Contingency

- All new code is in `z3_oracle/` (new directory) and `scripts/` (new files only). Removal is clean: `rm -rf z3_oracle/ scripts/enrich_countermodels.py scripts/run_conformance.py`.
- No existing Lean files are modified. No existing Python scripts are modified.
- If quantifier-free encoding proves too slow at N=2,M=2: fall back to quantified encoding as reference (ModelChecker approach), accept lower performance.
- If box quantification over N^M histories explodes: cap at N=2,M=3 (8 histories) and accept reduced coverage for hard formulas.
- If Z3 Python bindings are unavailable: use Z3 via subprocess with SMT-LIB2 format (slower but portable).
- Lean soundness formalization is explicitly deferred to a separate task and does not block this plan.
