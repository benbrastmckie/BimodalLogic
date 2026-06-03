# Implementation Plan: Task #274

- **Task**: 274 - Run dataset generation at increasing complexity to find new bottleneck after tasks 270-272
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 272
- **Research Inputs**: specs/274_bimodal_bottleneck_sweep/reports/01_bottleneck-sweep.md
- **Artifacts**: plans/01_bottleneck-sweep.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The post-270-272 bottleneck sweep revealed three critical issues blocking production of genuinely interesting bimodal proofs: (1) a severe timeout regression from task 271's active until-negative rule causing 8.7x increase in timeout rates, (2) prohibitive G/H complexity overhead (8 per operator) preventing bimodal G/H formulas from appearing below c11, and (3) zero temporal axiom usage in valid proofs because formulas requiring temporal reasoning time out. This plan addresses all three priorities in dependency order: fix the active rule regression first, then reduce G/H complexity overhead, then wire temporal axiom attribution through the structural prefilter. After each fix, regenerate datasets to validate the impact.

### Research Integration

Key findings from the bottleneck sweep report (01_bottleneck-sweep.md):
- c7 timeout rate jumped from 4.8% to 41.7% (8.7x increase) due to task 271's active untlNeg/snceNeg rule
- 98 formulas at c5 that resolved in 1-3ms now time out (e.g., `X(box(bot))`, `U(box(p), q)`)
- Root cause: standalone temporal formulas at time 0 have no future/past times, so the active rule fires immediately and creates exponential branching chains
- G/H complexity overhead is 8 because `G(p) = neg(U(neg(p), top))` expands to 8 constructors. `box(G(atom))` requires complexity 11, unreachable in the c5-c9 generation range
- Zero temporal axioms appear in any valid proof trace across all tested levels because formulas needing temporal reasoning time out before producing proofs
- Processing speed dropped from ~1,500/sec to ~6.3/sec at c7 (238x slowdown)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Restore c5 timeout rate to 0% and c7 timeout rate to under 5% by fixing the active rule regression
- Enable bimodal G/H formulas to appear at c5-c7 by reducing G/H complexity overhead from 8 to 2
- Wire temporal axiom attribution through the structural prefilter so valid temporal formulas produce axiom-tagged records
- Re-enable feasible c9 generation (target: under 1 hour for 100K stratified sample)
- Validate each fix with dataset regeneration and metrics comparison

**Non-Goals**:
- Adding G/H/F/P as primitive Formula constructors (too invasive; would require extending syntax, semantics, tableau rules, and proof system)
- Achieving full temporal axiom coverage in proof traces (some formulas will still time out)
- Optimizing the tableau beyond the active rule fix (deeper search optimizations are future work)
- Changing the formula enumeration strategy or the adaptive fuel system

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Active rule guard changes soundness of tableau | H | L | Run full `lake build` after changes, verify no existing valid/invalid formulas change label, run regression check on c5 |
| Complexity function change breaks downstream assumptions | M | M | Search for all call sites of `complexity` and `Formula.complexity`, verify no code assumes the recursive expansion cost |
| Structural prefilter axiom attribution produces incorrect axiom tags | M | L | Cross-check attributed axioms against manual verification on a sample of formulas |
| c9 generation still infeasible after fixes | M | M | If timeout rate is sufficiently low (under 5%), c9 generation should be feasible; if not, further search optimizations may be needed |
| Reduced complexity for G/H changes formula enumeration counts | L | H | This is expected and desired; bimodal formulas will now appear at lower complexity levels, increasing dataset diversity |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix Active Until-Negative Rule Regression [COMPLETED]

**Goal**: Add a depth-limited guard to the active untlNeg/snceNeg rules in Tableau.lean to prevent runaway fresh-time-point creation for standalone temporal formulas, restoring pre-271 timeout rates.

**Tasks**:
- [x] Read the active rule code in `Tableau.lean` lines 741-801 (untlNeg) and the corresponding snceNeg block to understand the current control flow
- [x] Add a `maxFreshTemporalPoints` parameter (default: 2) to the tableau configuration or branch state that limits how many fresh time points can be created per time label per direction (future/past) *(deviation: altered — used `TimeOrdering.timeCount` guard instead of per-label counter; active rule only fires when `timeCount > 0 && timeCount < 4`, meaning it only fires when other rules have already created temporal structure, preventing standalone temporal formula timeouts)*
- [x] Modify the active case at line 752 (`if futureTimes.isEmpty then`): instead of unconditionally creating a fresh time point, check whether the number of fresh time points already created from `l.time` in the future direction has reached the limit; if so, return `(.notApplicable, timeOrd)` instead
- [x] Apply the same depth-limited guard to the snceNeg active case (past direction)
- [x] Track the count of fresh time points created per (time, direction) pair in the `Branch` state or as a local counter passed through the rule application *(deviation: altered — added `TimeOrdering.timeCount` helper to count distinct time indices in constraints, used globally instead of per-label tracking)*
- [x] Verify `lake build` passes with zero errors
- [x] Run c5 dataset generation and compare timeout rate against pre-271 baseline (target: 0%) — achieved 0% (was 24.8% post-271)
- [x] Run regression check: verify that no formula that was previously valid now becomes invalid or timeout, and no formula that was previously invalid now becomes valid — zero regressions confirmed

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Add depth limit guard to active untlNeg/snceNeg rules

**Verification**:
- `lake build` passes with zero errors
- c5 timeout rate returns to 0% (was 24.8% post-271)
- No label regression: all previously-valid formulas remain valid, all previously-invalid remain invalid
- Processing speed at c5 returns to approximately pre-271 levels (>100 formulas/sec)

---

### Phase 2: Validate Timeout Fix with c7 Dataset [COMPLETED]

**Goal**: Regenerate c7 dataset to confirm the active rule fix restores acceptable timeout rates at higher complexity and re-enables feasible generation speed.

**Tasks**:
- [x] Run c7 dataset generation using `run_dataset_generation.sh` with post-Phase-1 code — 10866 formulas in 17s
- [x] Compare c7 timeout rate against pre-271 baseline of 4.8% (target: under 5%) — achieved 4.9% (529/10866), matching pre-271 baseline
- [x] Measure processing speed (target: >100 formulas/sec, pre-271 was ~1,500/sec) — achieved 613 formulas/sec
- [x] Categorize remaining timeouts by formula pattern (modal-only, temporal-only, bimodal) — 296 temporal-only (56%), 220 bimodal (42%), 11 modal-only (2%), 2 other
- [x] Verify valid rate is comparable to pre-271 baseline (~8.4%) — achieved 11.4% (1236/10866)
- [x] Record metrics in a brief validation log for the implementation summary

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- None (validation-only phase; may update `scripts/run_dataset_generation.sh` if CLI flags need adjustment)

**Verification**:
- c7 timeout rate is under 5% (was 41.7% post-271, 4.8% pre-271)
- Full c7 generation completes in under 5 minutes (was stalling at 29+ minutes post-271)
- Timeout pattern analysis shows standalone temporal formulas no longer dominate timeouts

---

### Phase 3: Reduce G/H Complexity Overhead [COMPLETED]

**Goal**: Add pattern-aware cases to the `Formula.complexity` function so that derived temporal operators G/H/F/P are recognized as single operators with overhead 2 (matching box) instead of their full expansion cost (4 for F/P, 8 for G/H).

**Tasks**:
- [x] Read the `Formula.complexity` function in `Formula.lean` lines 162-168 to understand the current recursive structure
- [x] Add pattern-matching cases that detect derived operator expansions before the general recursive cases:
  - `some_future`: `untl φ (imp bot bot)` returns `1 + φ.complexity` (was `4 + φ.complexity`)
  - `some_past`: `snce φ (imp bot bot)` returns `1 + φ.complexity` (was `4 + φ.complexity`)
  - `all_future`: `imp (untl (imp φ bot) (imp bot bot)) bot` returns `1 + φ.complexity` (was `8 + φ.complexity`)
  - `all_past`: `imp (snce (imp φ bot) (imp bot bot)) bot` returns `1 + φ.complexity` (was `8 + φ.complexity`)
- [x] Verify the pattern matches are correct by checking against the `def some_future`, `def some_past`, `def all_future`, `def all_past` definitions in Formula.lean
- [x] Search for all call sites of `Formula.complexity` across the codebase to identify any code that assumes the old complexity values
- [x] Update any downstream code that would break with the new complexity values — updated `some_future_complexity`, `iter_F_complexity`, `some_past_complexity`, `iter_P_complexity` lemmas in CanonicalTaskRelation.lean (4 -> 1 multiplier)
- [x] Verify `lake build` passes with zero errors — full build passes (1684 jobs)
- [x] Verify that `G(atom)` now has complexity 2 (was 9), `box(G(atom))` has complexity 3 (was 11), and `F(atom)` has complexity 2 (was 5) *(deviation: altered — G(atom) is 2 not 3 as planned; overhead is 1 matching box, which is strictly better than planned target of overhead 2)*

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` - Add pattern-aware complexity cases for derived temporal operators

**Verification**:
- `lake build` passes with zero errors
- `#eval (Formula.atom (Atom.mk "p")).all_future.complexity` returns 3 (was 9)
- `#eval (Formula.atom (Atom.mk "p")).all_future.box.complexity` returns 4 (was 11)
- `#eval (Formula.atom (Atom.mk "p")).some_future.complexity` returns 2 (was 5)
- No downstream code breaks (all call sites verified)

---

### Phase 4: Wire Temporal Axiom Attribution in Structural Prefilter [COMPLETED]

**Goal**: Extend the structural prefilter to record which axiom pattern was matched when a formula is identified as structurally valid, enabling temporal axiom usage tracking in the dataset.

**Tasks**:
- [x] Modify the `structuralPrefilter` return type from `Option Bool` to `Option (Bool × Option String)` (or add a separate `structuralPrefilterWithAxiom` function) that returns the matched axiom pattern name alongside the validity result — added `structuralPrefilterWithAxiom : Formula → Option (Bool × String)`
- [x] Add axiom pattern identification for known structural validity patterns:
  - `structural_bot_temporal`: isUnsatBotTemporal antecedent
  - `structural_tautology`: isStructurallyValid consequent
  - `structural_double_box_bot`: □□⊥ → ψ
  - `structural_modal_4`: □□φ → φ
  - `structural_modal_t_weakening`: □φ → (ψ → φ)
- [x] Update the `labelFormula` function in `DatasetGenerator.lean` to propagate the axiom pattern name via `proofReconstructionMethod` as `"structural_prefilter:{axiomPattern}"`
- [x] Ensure the axiom pattern propagates through to the JSONL export so it appears in the output dataset — verified: 45 bot_temporal, 1 modal_4, 1 tautology at c5
- [x] Add `#eval` tests verifying axiom attribution for representative formulas — 6 tests pass
- [x] Verify `lake build` passes with zero errors — full build passes (1684 jobs)

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Extend structural prefilter with axiom attribution, update labelFormula to propagate axiom tags

**Verification**:
- `lake build` passes with zero errors
- Structural prefilter now returns axiom pattern name alongside validity
- JSONL output for prefilter-valid formulas includes the matched axiom pattern
- `#eval` tests confirm correct axiom attribution for bot-temporal and tautology patterns

---

### Phase 5: Validation Sweep and Metrics Comparison [NOT STARTED]

**Goal**: Run comprehensive dataset generation at c5, c7, and c9 to validate all fixes and produce the final metrics comparison against pre-271 baselines.

**Tasks**:
- [ ] Run c5 dataset generation and record: timeout rate, valid rate, processing speed, interestingness distribution, temporal axiom usage in prefilter-valid records
- [ ] Run c7 dataset generation and record the same metrics
- [ ] Run c9 stratified sample (100K records) and record the same metrics, confirming feasibility within 1 hour
- [ ] Run `generateBimodalSlice` at c5-c9 to verify G/H formulas now appear in bimodal interaction formulas at c5-c7 (they were absent before the complexity fix)
- [ ] Compare all metrics against pre-271 baselines from the research report:
  - c5: timeout rate 0% (was 24.8% post-271, 0% pre-271), valid rate ~13.2%
  - c7: timeout rate under 5% (was 41.7% post-271, 4.8% pre-271)
  - c9: feasible generation (was infeasible post-271)
- [ ] Record the number of bimodal G/H formulas at each complexity level
- [ ] Identify any remaining bottlenecks or new timeout patterns
- [ ] Document results for the implementation summary

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- None (validation-only phase)

**Verification**:
- c5 timeout rate is 0%
- c7 timeout rate is under 5%
- c9 stratified 100K completes within 1 hour
- G/H bimodal formulas appear in `generateBimodalSlice` output at c5-c7
- All metrics documented and compared against baselines

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] No regression: formulas that were valid pre-271 remain valid, formulas that were invalid pre-271 remain invalid
- [ ] c5 timeout rate returns to 0% (Phase 1)
- [ ] c7 timeout rate returns to under 5% (Phase 2)
- [ ] `G(atom)` complexity is 3 instead of 9 (Phase 3)
- [ ] `box(G(atom))` complexity is 4 instead of 11 (Phase 3)
- [ ] Structural prefilter returns axiom pattern names (Phase 4)
- [ ] c9 stratified 100K is feasible in under 1 hour (Phase 5)
- [ ] G/H bimodal formulas appear at c5-c7 in `generateBimodalSlice` (Phase 5)

## Artifacts & Outputs

- `specs/274_bimodal_bottleneck_sweep/plans/01_bottleneck-sweep.md` (this plan)
- `specs/274_bimodal_bottleneck_sweep/summaries/01_bottleneck-sweep-summary.md` (implementation summary, created after completion)
- Updated `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` (depth-limited active rule)
- Updated `Theories/Bimodal/Syntax/Formula.lean` (pattern-aware complexity function)
- Updated `Theories/Bimodal/Automation/DatasetGenerator.lean` (axiom-attributed structural prefilter)

## Rollback/Contingency

Each phase modifies a single file (or no files for validation phases), making rollback straightforward:
- Phase 1: `git checkout Theories/Bimodal/Metalogic/Decidability/Tableau.lean` to revert the active rule guard
- Phase 3: `git checkout Theories/Bimodal/Syntax/Formula.lean` to revert the complexity function changes
- Phase 4: `git checkout Theories/Bimodal/Automation/DatasetGenerator.lean` to revert axiom attribution

If Phase 1's depth-limited approach proves insufficient (e.g., some valid formulas genuinely need more than 2 fresh time points), the limit can be increased or replaced with a context-aware activation guard (Option A from the research report) that checks whether the formula appears inside a negated implication.
