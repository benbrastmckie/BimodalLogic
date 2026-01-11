# Implementation Plan: Task #179

**Task**: Extend Bimodal benchmarks with derivation, semantics, and CI integration
**Version**: 003
**Created**: 2026-01-11
**Revision of**: implementation-002.md
**Reason**: Add documentation phases for project-level and theory-specific documentation with cross-links to avoid redundancy

## Revision Summary

This revision adds a documentation phase that properly separates project-wide guidance from theory-specific content, using cross-links and brief summaries to avoid redundancy.

### Key Changes from v002

1. **Split Phase 3 into 3a and 3b** - Separate project-wide benchmarking guide from Bimodal-specific performance targets
2. **Added cross-linking strategy** - Bimodal docs reference project-wide methodology; project-wide docs reference Bimodal as exemplar
3. **Updated QUALITY_METRICS.md** - Add benchmarking section to existing project-wide quality documentation
4. **Added summary principle** - Each location has brief summary with link to canonical source

### Previous Plan Status (v002)
- Phase 1: [NOT STARTED] - Derivation benchmarks
- Phase 2: [NOT STARTED] - Semantic benchmarks
- Phase 3: [NOT STARTED] - Performance targets documentation (single file)
- Phase 4: [NOT STARTED] - CI integration

### Documentation Organization Strategy

| Location | Content Type | Audience |
|----------|--------------|----------|
| `Documentation/Development/BENCHMARKING_GUIDE.md` | Project-wide methodology, standards | All contributors |
| `Documentation/Development/QUALITY_METRICS.md` | Add benchmarking section | All contributors |
| `Bimodal/Documentation/ProjectInfo/PERFORMANCE_TARGETS.md` | Theory-specific baselines | Bimodal developers |
| `Bimodal/Documentation/README.md` | Add link to performance targets | Bimodal users |

## Overview

Extend the Bimodal benchmarking suite with derivation tree and semantic evaluation benchmarks, plus comprehensive documentation at both project and theory levels. The goal is 3/3 coverage of major computational operations with well-organized documentation that avoids redundancy through strategic cross-linking.

## Phases

### Phase 1: Derivation Tree Benchmarks

**Status**: [COMPLETED]
**Estimated effort**: 2.5 hours

*(Unchanged from v002)*

**Objectives**:
1. Benchmark derivation tree construction performance
2. Measure modus ponens chains of varying depth
3. Benchmark modal/temporal inference rules
4. Validate correctness alongside timing

**Files to create**:
- `BimodalTest/ProofSystem/DerivationBenchmark.lean` (new)

**Implementation**: See v002 for full code details.

**Verification**:
- All benchmark derivations type-check
- Timing measurements stable (±20% between runs acceptable)
- `lake build BimodalTest.ProofSystem.DerivationBenchmark` succeeds

---

### Phase 2: Semantic Evaluation Benchmarks

**Status**: [COMPLETED]
**Estimated effort**: 2 hours

*(Unchanged from v002)*

**Note**: Can run in parallel with Phase 1 (no dependencies).

**Objectives**:
1. Benchmark `truth_at` evaluation performance
2. Measure formula complexity scaling
3. Validate expected truth values (soundness check)

**Files to create**:
- `BimodalTest/Semantics/SemanticBenchmark.lean` (new)

**Implementation**: See v002 for full code details.

**Verification**:
- All `correct` fields are `true` (expected matches actual)
- `lake build BimodalTest.Semantics.SemanticBenchmark` succeeds

---

### Phase 3a: Project-Wide Benchmarking Documentation

**Status**: [COMPLETED]
**Estimated effort**: 0.75 hours

**NEW in v003**: Creates project-wide benchmarking guidance applicable to all theories.

**Objectives**:
1. Create BENCHMARKING_GUIDE.md with methodology and standards
2. Update QUALITY_METRICS.md to reference benchmarking
3. Establish cross-link pattern for theory-specific docs

**Files to create/modify**:
- `Documentation/Development/BENCHMARKING_GUIDE.md` (new)
- `Documentation/Development/QUALITY_METRICS.md` (update)
- `Documentation/Development/README.md` (update link list)

**BENCHMARKING_GUIDE.md content**:

```markdown
# Performance Benchmarking Guide

Project-wide standards for performance benchmarking in ProofChecker.

## Purpose

Performance benchmarks serve three goals:
1. **Regression detection** - Catch slowdowns before they reach main
2. **Optimization guidance** - Identify bottlenecks worth optimizing
3. **Baseline documentation** - Track performance evolution

## Benchmark Categories

All theories should benchmark these operation types:

| Category | What to Measure | Example |
|----------|-----------------|---------|
| Proof Search | Time, visits, depth | Finding proofs for axiom schemas |
| Derivation | Construction time, tree height | Building proof trees |
| Semantics | Evaluation time, correctness | Truth/validity checking |

## Implementation Standards

### Timing
- Use wall-clock timing (`IO.monoNanosNow`)
- Run **100+ iterations** and take **median** for stability
- Report in appropriate units (ns/μs/ms)

### Correctness Validation
- Semantic benchmarks **MUST** validate expected results
- Compile-time type checking validates derivation benchmarks

### Output Format
- Human-readable output for development
- JSON output for CI integration

### Regression Thresholds
- Time: **>2x slowdown** triggers regression
- Visits (proof search): **>50% increase** triggers regression
- Correctness: **Any failure** triggers regression

## Theory-Specific Targets

Each theory maintains its own baseline measurements:
- **Bimodal**: [PERFORMANCE_TARGETS.md](../../Bimodal/Documentation/ProjectInfo/PERFORMANCE_TARGETS.md)
- **Logos**: [PERFORMANCE_TARGETS.md](../../Logos/Documentation/ProjectInfo/PERFORMANCE_TARGETS.md) (planned)

## CI Integration

See `scripts/run-benchmarks.sh` and `scripts/check-regression.sh` for
automated benchmark execution and regression detection.

## Adding New Benchmarks

1. Create benchmark file in `{Theory}Test/` directory
2. Import timing utilities from existing benchmarks
3. Run and document baselines in theory's PERFORMANCE_TARGETS.md
4. Add to CI runner script
```

**QUALITY_METRICS.md update** (add section):

```markdown
## 4. Performance Benchmarks

Performance benchmarks ensure implementations remain efficient across changes.

### Benchmark Coverage

| Operation | Required | Target |
|-----------|----------|--------|
| Proof search | Yes (if applicable) | All search strategies benchmarked |
| Derivation construction | Yes | All inference rules benchmarked |
| Semantic evaluation | Yes | All formula types benchmarked |

### Regression Policy

- Regressions >2x are blocking for merge
- Theory-specific targets in each theory's PERFORMANCE_TARGETS.md

For complete benchmarking methodology, see [BENCHMARKING_GUIDE.md](BENCHMARKING_GUIDE.md).
```

**Verification**:
- BENCHMARKING_GUIDE.md exists and is valid Markdown
- QUALITY_METRICS.md has new section 4
- README.md lists new file

---

### Phase 3b: Theory-Specific Performance Targets

**Status**: [COMPLETED]
**Estimated effort**: 1 hour

**Prerequisite**: Phase 1 and 2 must be complete (needs actual measurements).

**Objectives**:
1. Run all benchmarks to establish Bimodal baselines
2. Document Bimodal-specific targets
3. Cross-link to project-wide methodology

**Files to create/modify**:
- `Bimodal/Documentation/ProjectInfo/PERFORMANCE_TARGETS.md` (new)
- `Bimodal/Documentation/ProjectInfo/README.md` (update)
- `Bimodal/Documentation/README.md` (add to quick links)

**PERFORMANCE_TARGETS.md content**:

```markdown
# Bimodal Performance Targets

Theory-specific performance baselines and regression thresholds for Bimodal TM logic.

> **Methodology**: See [BENCHMARKING_GUIDE.md](../../../Documentation/Development/BENCHMARKING_GUIDE.md)
> for project-wide benchmarking standards.

*Last updated: 2026-01-11*
*Baseline system: [describe hardware/Lean version]*

## Proof Search Benchmarks

Benchmarks for `Bimodal.Automation.ProofSearch`:

| Benchmark | Baseline Time | Max Visits | Regression Threshold |
|-----------|---------------|------------|----------------------|
| Modal T axiom | {measured} | {measured} | 2x time OR 50% visits |
| Modal 4 axiom | {measured} | {measured} | 2x time OR 50% visits |
| Modal 5 axiom | {measured} | {measured} | 2x time OR 50% visits |
| Temporal 4 axiom | {measured} | {measured} | 2x time OR 50% visits |
| Mixed modal-temporal | {measured} | {measured} | 2x time OR 50% visits |

**Benchmark file**: `BimodalTest/Automation/ProofSearchBenchmark.lean`

## Derivation Construction

Benchmarks for `Bimodal.ProofSystem.Derivation`:

| Benchmark | Baseline Time | Tree Height | Regression Threshold |
|-----------|---------------|-------------|----------------------|
| Axiom application | {measured} | 0 | 2x time |
| Assumption lookup | {measured} | 0 | 2x time |
| MP chain (depth 3) | {measured} | {measured} | 2x time |
| MP chain (depth 5) | {measured} | {measured} | 2x time |
| MP chain (depth 10) | {measured} | {measured} | 2x time |
| Necessitation (modal) | {measured} | {measured} | 2x time |
| Necessitation (temporal) | {measured} | {measured} | 2x time |

**Benchmark file**: `BimodalTest/ProofSystem/DerivationBenchmark.lean`

## Semantic Evaluation

Benchmarks for `Bimodal.Semantics.Truth`:

| Benchmark | Baseline Time | Correctness | Regression Threshold |
|-----------|---------------|-------------|----------------------|
| Atomic (true) | {measured} | PASS | 2x time |
| Atomic (false) | {measured} | PASS | 2x time |
| Box depth 1 | {measured} | PASS | 2x time |
| Box depth 3 | {measured} | PASS | 2x time |
| Box depth 5 | {measured} | PASS | 2x time |
| Temporal G | {measured} | PASS | 2x time |
| Implication chain | {measured} | PASS | 2x time |

**Benchmark file**: `BimodalTest/Semantics/SemanticBenchmark.lean`

## Optimization Recommendations

Based on Bimodal-specific benchmark analysis:

1. **Modal-heavy proofs**: Configure `HeuristicWeights.modalBase=3`
2. **Temporal-heavy proofs**: Configure `HeuristicWeights.temporalBase=3`
3. **Deep proofs**: Use IDDFS with `maxDepth≥20`
4. **Complex contexts**: Use BestFirst strategy

## Running Benchmarks

```bash
# Run all Bimodal benchmarks
./scripts/run-benchmarks.sh

# Run individual suites
lake env lean --run BimodalTest/Automation/ProofSearchBenchmark.lean
lake env lean --run BimodalTest/ProofSystem/DerivationBenchmark.lean
lake env lean --run BimodalTest/Semantics/SemanticBenchmark.lean
```

## History

| Date | Change | Impact |
|------|--------|--------|
| 2026-01-11 | Initial baseline | First measurements |
```

**Updates to existing files**:

1. `Bimodal/Documentation/ProjectInfo/README.md` - Add:
   ```markdown
   - [PERFORMANCE_TARGETS.md](PERFORMANCE_TARGETS.md) - Performance baselines and thresholds
   ```

2. `Bimodal/Documentation/README.md` - Add to Quick Links:
   ```markdown
   - [Performance Targets](ProjectInfo/PERFORMANCE_TARGETS.md) - Benchmark baselines
   ```

**Verification**:
- All baseline values filled from actual measurements
- Cross-link to BENCHMARKING_GUIDE.md works
- README files updated with new links

---

### Phase 4: CI Integration (Minimal)

**Status**: [COMPLETED]
**Estimated effort**: 1.5 hours

*(Unchanged from v002)*

**Objectives**:
1. Create benchmark runner script
2. Add JSON output to all benchmarks
3. Create simple regression checker script

**Files to create/modify**:
- `scripts/run-benchmarks.sh` (new)
- `scripts/check-regression.sh` (new)
- `benchmarks/baseline.json` (new)

**Implementation**: See v002 for full details.

**Verification**:
- `./scripts/run-benchmarks.sh` executes without error
- `benchmarks/current.json` is valid JSON
- `./scripts/check-regression.sh` exits 0 on first run

---

## Dependencies

```
Phase 1 ──┬──► Phase 3a ──► Phase 3b ──► Phase 4
Phase 2 ──┘        │              ▲
                   │              │
                   └──────────────┘ (3a can start before 1&2 complete,
                                     but 3b needs measurements)
```

- Phase 1 and Phase 2: **No dependencies** (run in parallel)
- Phase 3a: **No dependencies** (can start immediately)
- Phase 3b: Depends on Phase 1 and 2 (needs measurements)
- Phase 4: Depends on Phase 3b (needs baseline document)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Timing variability | Medium | Multiple iterations with median |
| Import from ProofSearchBenchmark fails | Low | Copy `timed`/`formatNanos` if needed |
| Semantic Decidable instance missing | Medium | Use explicit evaluation |
| Documentation duplication | Low | Cross-link strategy implemented |
| Broken cross-links | Low | Verify all links before committing |

## Success Criteria

- [ ] `lake build BimodalTest.ProofSystem.DerivationBenchmark` succeeds
- [ ] `lake build BimodalTest.Semantics.SemanticBenchmark` succeeds
- [ ] All semantic benchmarks report `correct = true`
- [ ] `Documentation/Development/BENCHMARKING_GUIDE.md` exists
- [ ] `Documentation/Development/QUALITY_METRICS.md` has benchmarking section
- [ ] `Bimodal/Documentation/ProjectInfo/PERFORMANCE_TARGETS.md` contains measured baselines
- [ ] All cross-links between project and theory docs work
- [ ] `./scripts/run-benchmarks.sh` produces valid JSON
- [ ] `./scripts/check-regression.sh` exits 0 on matching baseline
- [ ] Project builds without errors after all phases

## Effort Summary

| Phase | v002 Estimate | v003 Estimate | Change |
|-------|---------------|---------------|--------|
| Phase 1 | 2.5 hours | 2.5 hours | — |
| Phase 2 | 2 hours | 2 hours | — |
| Phase 3a | — | 0.75 hours | +0.75h (new: project docs) |
| Phase 3b | 1 hour | 1 hour | — (was Phase 3) |
| Phase 4 | 1.5 hours | 1.5 hours | — |
| **Total** | **7 hours** | **7.75 hours** | **+0.75h** |

## Cross-Link Summary

| From | To | Purpose |
|------|----|---------|
| QUALITY_METRICS.md | BENCHMARKING_GUIDE.md | "Full methodology here" |
| BENCHMARKING_GUIDE.md | Bimodal PERFORMANCE_TARGETS.md | "Theory-specific targets here" |
| BENCHMARKING_GUIDE.md | Logos PERFORMANCE_TARGETS.md | "Planned" placeholder |
| Bimodal PERFORMANCE_TARGETS.md | BENCHMARKING_GUIDE.md | "Standards defined here" |
| Bimodal README.md | PERFORMANCE_TARGETS.md | Quick access |
| Bimodal ProjectInfo README.md | PERFORMANCE_TARGETS.md | Directory listing |
