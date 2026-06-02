# Implementation Plan: Complete Axiom & Derived Theorem Coverage in modal_search

- **Task**: 185 - Complete axiom & derived theorem coverage in modal_search
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_axiom-coverage-seed.md, reports/02_axiom-coverage-research.md
- **Artifacts**: plans/03_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Extend `tryAxiomMatch` in `Tactics/Helpers.lean` to cover all 42 axiom constructors (currently 12), add a `tryDerivedMatch` function registering ~25 derived theorems as additional apply targets in `searchProof`, and add tests for each new pattern. The computable `matchAxiom` in `ProofSearch/Core.lean` already covers all 42 constructors (confirmed by code inspection), so no synchronization work is needed. This is a mechanical extension task requiring no architectural changes.

### Research Integration

The research report (02_axiom-coverage-research.md) provided:
- Complete 42-constructor axiom matrix with coverage status for `tryAxiomMatch` (12/42) and `matchAxiom` (42/42 -- already complete)
- Categorized ~90 derived theorems across 8 source files, identifying ~25 empty-context candidates viable for `tryDerivedMatch`
- Confirmed that `first | trivial | decide` handles non-base frame class goals (density, prior_UZ/SZ, z1)
- Confirmed that noncomputable theorems work in TacticM (meta-level `mkConst`/`apply` does not evaluate definitions)
- Identified insertion point: `tryDerivedMatch` between Strategy 1 (axiom) and Strategy 2 (assumption) in `searchProof`

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals**:
- Register all 42 axiom constructors in `tryAxiomMatch` (currently 12)
- Create `tryDerivedMatch` function with ~25 empty-context derived theorems
- Insert `tryDerivedMatch` into `searchProof` between axiom and assumption strategies
- Fix `h_fc` closing tactic to handle non-base frame classes (`first | trivial | decide`)
- Add test examples validating each new axiom and derived theorem match

**Non-Goals**:
- Modifying `matchAxiom` in ProofSearch/Core.lean (already complete at 42/42)
- Adding context-dependent derived theorems (e.g., `ecq : [A, neg A] |- B`) -- requires weakening infrastructure (future task)
- Performance optimization or pre-filtering by formula head (premature; profile first)
- Adding meta-level theorems (e.g., `imp_trans`, `mp`, `contraposition`) that take two DerivationTree premises

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Performance regression from 42 axiom constructors in loop | L | L | `observing?` saves/restores state efficiently; 42 iterations is small |
| Non-base frame class axioms fail `trivial` on `h_fc` goal | M | M | Change to `first \| trivial \| decide`; `DecidableRel` instance exists on `FrameClass.LE` |
| Derived operator definitions block unification in `apply` | M | L | Lean's unfold-on-demand handles definitions; add `whnf` hints only if needed |
| Noncomputable derived theorems fail in TacticM | L | VL | `mkConst`/`apply` work at meta-level, confirmed by existing `temp_future_derived` |
| Build time increase from ~54 new test examples | L | L | Adds ~30s to build; acceptable |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Complete axiom registration in tryAxiomMatch [COMPLETED]

**Goal**: Extend `axiomCtors` list from 12 to 42 entries and fix `h_fc` closing tactic.

**Tasks**:
- [x] Add 30 missing axiom constructor names to `axiomCtors` list in `Tactics/Helpers.lean` (line 556-569)
- [x] Order: keep existing 12 first (most common), then BX temporal (20), uniformity (5), discrete (3: prior_UZ, prior_SZ, z1), dense (2: density, dense_indicator) *(deviation: altered -- reordered to group by axiom layer rather than keeping original 12 first, for clearer organization)*
- [x] Change `h_fc` closing tactic at line 580 from `evalTactic (← \`(tactic| trivial))` to `evalTactic (← \`(tactic| first | trivial | decide))`
- [x] Add ~30 axiom test examples in `Tactics/Commands.lean` (after existing tests), grouped by layer
- [x] Verify with `lake build Bimodal.Automation.Tactics.Commands`

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` - Add 30 axioms to `axiomCtors` list (lines 556-569), fix `h_fc` tactic (line 580)
- `Theories/Bimodal/Automation/Tactics/Commands.lean` - Add ~30 axiom test examples

**Verification**:
- `lake build Bimodal.Automation.Tactics.Commands` passes
- Each new axiom test proves its schema instance via `by modal_search`
- Non-base axioms (prior_UZ, prior_SZ, z1, density, dense_indicator) use `FrameClass.Discrete` or `FrameClass.Dense` annotation

---

### Phase 2: Add tryDerivedMatch function [COMPLETED]

**Goal**: Create `tryDerivedMatch` function registering ~25 empty-context derived theorems and integrate into `searchProof`.

**Tasks**:
- [x] Create `tryDerivedMatch` function in `Tactics/Helpers.lean`, modeled on the existing derived theorem section (lines 513-529)
- [x] Register Tier 1 derived theorems (12 entries): `identity`, `double_negation`, `raa`, `efq`, `lce_imp`, `rce_imp`, `contrapose_imp`, `pairing`, `dni`, `b_combinator`, `theorem_flip`, `theorem_app1`
- [x] Register Tier 2 derived theorems (13 entries): `temp_k_dist_derived`, `temp_4_derived`, `H_distribution`, `H_transitivity`, `t_box_to_diamond`, `k_dist_diamond`, `diamond_4`, `modal_5`, `box_to_future`, `box_to_past`, `formula_or_comm`, `bi_imp`, `classical_merge`
- [x] Move existing `temp_future_derived` from inline `tryAxiomMatch` section to the new `tryDerivedMatch` function
- [x] Insert `tryDerivedMatch` call in `searchProof` (line 897) between Strategy 1 (axiom) and Strategy 2 (assumption)
- [x] Add ~25 derived theorem test examples in `Tactics/Commands.lean`
- [x] Verify with `lake build Bimodal.Automation.Tactics.Commands`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` - New `tryDerivedMatch` function (~40 lines), update `searchProof` strategy order, remove `temp_future_derived` from `tryAxiomMatch`
- `Theories/Bimodal/Automation/Tactics/Commands.lean` - Add ~25 derived theorem test examples

**Verification**:
- `lake build Bimodal.Automation.Tactics.Commands` passes
- Each derived theorem test proves its pattern via `by modal_search`
- `temp_future_derived` still works (moved, not removed)
- Existing tests still pass (no regression)

---

### Phase 3: Integration tests and full build verification [NOT STARTED]

**Goal**: Add comprehensive integration tests and verify the full project builds cleanly.

**Tasks**:
- [ ] Add integration tests in `Tests/BimodalTest/Automation/EdgeCaseTest.lean` covering: (a) non-base frame class axioms, (b) derived theorems in deeper search contexts, (c) combined axiom+derived+modus ponens proofs
- [ ] Run `lake build` for full project verification
- [ ] Verify no regression in existing test suite
- [ ] Update module docstring in `Tactics/Helpers.lean` to document new coverage (42 axioms, ~25 derived theorems)

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Tests/BimodalTest/Automation/EdgeCaseTest.lean` - Add ~10 integration tests
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` - Update module docstring

**Verification**:
- `lake build` passes with zero errors
- All new tests compile and pass
- `#print axioms` on test examples shows no `sorryAx`

## Testing & Validation

- [ ] All 42 axiom constructors proven via `by modal_search` (30 new + 12 existing)
- [ ] All ~25 derived theorems proven via `by modal_search`
- [ ] Non-base frame class axioms (prior_UZ, prior_SZ, z1, density, dense_indicator) work with appropriate FrameClass annotation
- [ ] `temp_future_derived` still works after migration to `tryDerivedMatch`
- [ ] Existing test suite passes without regression
- [ ] Full `lake build` passes

## Artifacts & Outputs

- `Theories/Bimodal/Automation/Tactics/Helpers.lean` - Extended `tryAxiomMatch` (42 axioms), new `tryDerivedMatch` (~25 theorems), updated `searchProof`
- `Theories/Bimodal/Automation/Tactics/Commands.lean` - ~55 new test examples
- `Tests/BimodalTest/Automation/EdgeCaseTest.lean` - ~10 new integration tests
- `specs/185_complete_axiom_derived_coverage/plans/03_implementation-plan.md` - This plan

## Rollback/Contingency

All changes are additive (extending a list, adding a new function, adding tests). Rollback is straightforward: revert to the pre-change state of `Helpers.lean`, `Commands.lean`, and `EdgeCaseTest.lean`. No existing code is deleted or restructured. If specific axioms or derived theorems cause issues, they can be individually commented out from the lists without affecting the rest.
