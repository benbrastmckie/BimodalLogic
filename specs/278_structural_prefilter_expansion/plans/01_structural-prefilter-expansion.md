# Implementation Plan: Expand Structural Prefilter with Polarity Analysis, 2-SAT Skeleton, and Temporal Loop Detection

- **Task**: 278 - Expand structural prefilter with polarity analysis, 2-SAT skeleton, and temporal loop detection
- **Status**: [NOT STARTED]
- **Effort**: 8.5 hours
- **Dependencies**: Task 274
- **Research Inputs**: specs/278_structural_prefilter_expansion/reports/01_research.md
- **Artifacts**: plans/01_structural-prefilter-expansion.md (this file)
- **Standards**:
  - .opencode/context/formats/plan-format.md
  - .opencode/context/formats/status-markers.md
  - .opencode/context/formats/artifact-management.md
  - .opencode/context/formats/tasks.md
- **Type**: markdown

## Overview

This task expands the structural prefilter in `DatasetGenerator.lean` from six fixed-shape patterns to a richer set of O(n) structural checks, aiming to approximately double prefilter coverage from ~5% to ~10% on the c7 benchmark. The implementation is confined to a single file, adding recursive polarity tracking, top-level conjunct analysis, and an optional 2-SAT propositional skeleton solver, all integrated into the existing `structuralPrefilterWithAxiom` telemetry pipeline.

### Research Integration

The research report (specs/278_structural_prefilter_expansion/reports/01_research.md) analyzed the current six-pattern prefilter (lines 406–485) and assessed feasibility for five new pattern families. Key findings adopted into this plan: (1) `collectTopLevelConjuncts` is a missing prerequisite shared by three patterns; (2) polarity analysis requires careful handling of derived `and`/`or`/`neg` shapes; (3) full 2-SAT is high-risk and should only be pursued if lightweight checks plus quick wins fail to reach the ~10% target; (4) all patterns must reuse existing axiom schemata or theorems for semantic soundness.

### Prior Plan Reference

No prior plan exists for this task.

### Roadmap Alignment

No ROADMAP.md loaded.

## Goals & Non-Goals

**Goals**:
- Implement ~10 modal/temporal subsumption rules, S5 reflexive shortcutting, and temporal loop detection as quick-win patterns.
- Implement recursive polarity analysis to drop tautologies appearing only positively and short-circuit contradictions appearing only negatively.
- Implement lightweight propositional contradiction detection among top-level conjuncts.
- Conditionally implement a full 2-SAT propositional skeleton solver only if coverage remains below ~10% after the above phases.
- Add axiom attribution labels for every new pattern so telemetry tracks per-pattern hit rates.
- Run a before/after c7 benchmark using `labelBatch` / `computeBatchStats` to verify coverage improvement.
- Preserve `lake build` success and existing test suite behavior.

**Non-Goals**:
- Modifying the core decision procedure (`decideAutoAdaptive`) or proof extraction pipeline.
- Adding new axiom constructors to the proof system.
- Changing the `Formula` AST or any modules outside `DatasetGenerator.lean`.
- Achieving a formally verified 2-SAT solver; the prefilter is a conservative soundness-critical heuristic.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Derived-operator pattern mismatches (`and`, `or`, `neg`, `all_future`) cause false negatives or missed patterns | Medium | Medium | Exhaustive `#eval` unit tests for each derived shape; reuse existing derived-operator definitions from `Formula.lean` where possible. |
| Polarity walk misses double-negation or derived-modal flips | Medium | Medium | Unit-test nested `neg`/`imp` shapes and document polarity rules explicitly in comments. |
| Full 2-SAT implementation is complex and yields marginal coverage gain | High | Medium | Defer to conditional Phase 5; implement lightweight propositional contradiction first. |
| New patterns mislabel valid/invalid formulas, causing benchmark regressions | High | Low | Soundness justification required for every pattern (reference existing theorem or axiom); compare before/after labels for mismatches. |
| `lake build` breakage from helper definitions conflicting with existing imports | Medium | Low | Keep all new definitions in `DatasetGenerator.lean` namespace; run `lake build` after each phase. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1, 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Quick Wins — Conjunct Helpers and Local Patterns [NOT STARTED]

**Goal**: Implement `collectTopLevelConjuncts` and add the highest-impact, lowest-risk patterns: S5 reflexive shortcutting, temporal loop detection, ~10 subsumption rules, and extended tautology detection.

**Tasks**:
- [ ] Implement `collectTopLevelConjuncts` that recursively flattens the derived `and` shape (`(a.imp (b.imp bot)).imp bot`) into a `List Formula`.
- [ ] Add S5 reflexive shortcutting: detect the pair `(box φ, neg φ)` among top-level conjuncts; label as `structural_s5_reflexive_conflict`.
- [ ] Add temporal loop detection: detect `(untl event guard, all_future (neg guard))` and `(snce event guard, all_past (neg guard))` among conjuncts; labels `structural_temporal_loop_until` and `structural_temporal_loop_since`.
- [ ] Add ~10 modal/temporal subsumption implication rules (e.g., `Gφ → φ`, `Hφ → φ`, `Gφ → Fφ`, `Hφ → Pφ`, `Gφ → G(Gφ)`, `Hφ → H(Hφ)`, `F(Fφ) → Fφ`, `P(Pφ) → Pφ`, `□φ → □□φ`, `□φ → ◇φ`) with labels `structural_subsumption_*`.
- [ ] Extend `isStructurallyValid` to recognize `φ → ⊤` and `φ → □⊤` as valid consequents.
- [ ] Add `#eval` unit tests for each new helper and pattern, following the existing style (lines 489–526).
- [ ] Run `lake build` and fix any errors.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — add helper functions and new match arms in `structuralPrefilterWithAxiom`.

**Verification**:
- All new `#eval` tests return expected values.
- `lake build` completes with no errors.

---

### Phase 2: Polarity Analysis [NOT STARTED]

**Goal**: Implement a recursive polarity tracker and integrate it into the prefilter to drop tautologies appearing only positively and short-circuit contradictions appearing only negatively.

**Tasks**:
- [ ] Define `Sign` type (positive / negative) or reuse an existing signed type.
- [ ] Implement `collectPolarities : Formula → List (Formula × Sign)` that recursively walks the AST, flipping sign at the left-hand side of `imp` and through derived `neg`, `and`, and `or` shapes.
- [ ] Implement `appearsOnlyPositively` and `appearsOnlyNegatively` predicates on the collected list.
- [ ] Integrate into `structuralPrefilterWithAxiom`:
  - If a tautology (by `isStructurallyValid`) appears only positively in the consequent, return `some (true, "structural_polarity_drop_tautology")`.
  - If `bot` or a formula satisfying `isUnsatBotTemporal` appears only negatively, return `some (true, "structural_polarity_bot_neg")`.
- [ ] Add `#eval` unit tests covering double-negation, nested `imp`, and derived `and`/`or` polarity behavior.
- [ ] Run `lake build` and fix any errors.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — polarity definitions and prefilter integration.

**Verification**:
- `#eval` tests for polarity collection match expected sign sets.
- `lake build` completes with no errors.

---

### Phase 3: Lightweight Propositional Contradiction [NOT STARTED]

**Goal**: Detect direct propositional contradictions among top-level conjuncts (e.g., `p ∧ ¬p`) using the conjunct helper from Phase 1.

**Tasks**:
- [ ] Implement `hasPropContradiction : List Formula → Bool` that scans conjunct pairs for a formula and its negation (using derived `neg` shape `φ → ⊥`).
- [ ] Add a match arm in `structuralPrefilterWithAxiom` that flattens top-level `and`, runs `hasPropContradiction`, and returns `some (true, "structural_prop_contradiction")` when found.
- [ ] Add `#eval` unit tests for `p ∧ ¬p`, `(p → q) ∧ (p → q → ⊥)`, and non-contradictory cases.
- [ ] Run `lake build` and fix any errors.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — contradiction check and prefilter integration.

**Verification**:
- `#eval` tests correctly identify contradictions and reject non-contradictions.
- `lake build` completes with no errors.

---

### Phase 4: c7 Benchmark and Gap Analysis [NOT STARTED]

**Goal**: Measure coverage improvement after Phases 1–3 and decide whether the conditional full 2-SAT skeleton (Phase 5) is required.

**Tasks**:
- [ ] Run `lake exe enum_benchmark` or a manual `labelBatch` / `computeBatchStats` pipeline on the c7 corpus (max complexity 7, exhaustive or sampled).
- [ ] Record metrics: valid fraction, prefilter hit rate (`decisionMethod == "structural_prefilter"`), timeout rate, average decision time.
- [ ] Verify decision method distribution shows new `structural_prefilter:*` patterns without regressions in existing categories.
- [ ] Check that no formula previously labeled `valid` or `invalid` is now labeled `timeout` or the opposite.
- [ ] Compare against the ~10% coverage target. If the gap is >1 percentage point and the missing cases are propositional 2-CNF conflicts, proceed to Phase 5; otherwise skip it.

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3

**Files to modify**:
- None (read-only benchmark evaluation).

**Verification**:
- Benchmark completes without runtime errors.
- Metrics report is generated and reviewed.
- Go/no-go decision for Phase 5 is documented.

---

### Phase 5: Full 2-SAT Propositional Skeleton (Conditional) [NOT STARTED]

**Goal**: If the c7 benchmark shows a coverage gap after Phases 1–4, implement a complete 2-SAT solver on the stripped propositional skeleton to catch remaining unsatisfiable propositional cores.

**Tasks**:
- [ ] Implement `propSkeleton2CNF : Formula → List (Formula × Formula)` that strips modal/temporal operators and extracts binary clauses from `imp`/`or`/`neg` shapes.
- [ ] Build an implication graph from the 2-CNF clauses (`a ∨ b` becomes `¬a → b` and `¬b → a`).
- [ ] Implement an SCC check (using `Quiver.StronglyConnectedComponent` or a custom Tarjan algorithm) to detect `x` and `¬x` in the same component.
- [ ] Integrate into `structuralPrefilterWithAxiom` with label `structural_2sat_unsat`.
- [ ] Add `#eval` unit tests for small 2-CNF unsatisfiable formulas (e.g., `(a ∨ b) ∧ (¬a ∨ b) ∧ (¬b ∨ a) ∧ (¬a ∨ ¬b)` equivalent).
- [ ] Run `lake build` and re-run the c7 benchmark to verify the final coverage.

**Timing**: 2–3 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — 2-CNF extraction, graph, SCC check, and prefilter integration.

**Verification**:
- `#eval` tests confirm unsatisfiable 2-CNF skeletons are detected.
- `lake build` completes with no errors.
- Re-benchmark shows coverage at or above the ~10% target.

## Testing & Validation

- [ ] All new patterns have `#eval` unit tests in `DatasetGenerator.lean` following the existing style.
- [ ] `lake build` passes with no errors, warnings, or sorries after every phase.
- [ ] `lake exe enum_benchmark` (or equivalent `labelBatch` harness) runs successfully and produces metrics.
- [ ] Decision method distribution includes new `structural_prefilter:*` entries.
- [ ] No valid/invalid formulas are reclassified as timeout or mislabeled.
- [ ] Before/after valid fraction improves from ~3–4% baseline toward the ~10% target.
- [ ] Each new pattern is semantically justified by an existing axiom schema or theorem (soundness check).

## Artifacts & Outputs

- `Theories/Bimodal/Automation/DatasetGenerator.lean` — updated structural prefilter with new helpers, patterns, and unit tests.
- `specs/278_structural_prefilter_expansion/plans/01_structural-prefilter-expansion.md` — this implementation plan.
- Benchmark metrics report (captured during Phase 4 and optionally Phase 5).

## Rollback/Contingency

- If any phase introduces build failures or benchmark regressions, revert `DatasetGenerator.lean` to the last known good state using git and re-apply changes phase by phase.
- If a specific new pattern causes mislabeling, it can be temporarily disabled by removing or commenting out its match arm in `structuralPrefilterWithAxiom` without affecting the rest of the prefilter.
- If Phase 5 (full 2-SAT) proves too complex or yields negligible improvement, abandon it and document the coverage achieved by Phases 1–4 as sufficient.
