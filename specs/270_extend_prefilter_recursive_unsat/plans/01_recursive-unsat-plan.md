# Implementation Plan: Task #270

- **Task**: 270 - Extend structural pre-filter with recursive unsatisfiability and consequent validity
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None (task 269 already completed)
- **Research Inputs**: specs/270_extend_prefilter_recursive_unsat/reports/01_recursive-unsat-research.md
- **Artifacts**: plans/01_recursive-unsat-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Extend the structural pre-filter in `DatasetGenerator.lean` with two improvements: (1) make `isUnsatBotTemporal` recursive so it catches nested unsatisfiable events like `U(box(bot), X)` and `U(U(bot, Y), X)`, and (2) add an `isStructurallyValid` function that detects tautological consequents like `p -> p` and `X -> box(p -> p)`, integrating it into `structuralPrefilter`. Both changes are localized to approximately 30 lines in a single file, preserve the conservative invariant (pre-filter only returns `some true` or `none`), and have no impact on tableau rules, soundness proofs, or countermodel extraction. The goal is to reduce dataset timeout rates by catching more valid formulas before the decision procedure runs.

### Research Integration

The research report (01_recursive-unsat-research.md) identified two specific bugs/gaps:
1. `isUnsatBotTemporal` matches only literal `.bot` as the Until/Since event argument instead of recursing into the event, despite already recursing through `.box`.
2. `structuralPrefilter` only checks antecedent unsatisfiability, missing the dual case where the consequent is itself a tautology.

Both fixes have airtight soundness arguments documented in the research report sections 2.1 and 2.2.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly address dataset generation or the structural pre-filter. These changes are automation infrastructure improvements that support the broader completeness effort by improving dataset quality for training and evaluation.

## Goals & Non-Goals

**Goals**:
- Make `isUnsatBotTemporal` recursive so it catches `U(box(bot), X)`, `U(U(bot, Y), X)`, and similar nested patterns
- Add `isStructurallyValid` function to detect tautological consequents
- Integrate `isStructurallyValid` into `structuralPrefilter`
- Add `#eval` tests for both extensions
- Verify clean `lake build` with no new sorries or axiom regressions

**Non-Goals**:
- Modifying tableau rules (Tableau.lean)
- Changing countermodel extraction logic
- Modifying soundness or completeness proofs
- Dataset regeneration (deferred to task 271/272 or manual follow-up)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `isUnsatBotTemporal` returns true for a satisfiable formula | High (false positive validity) | Very Low | Semantic argument is airtight: Until/Since with unsatisfiable event are always false; recursion only follows already-established unsatisfiability paths |
| `isStructurallyValid` returns true for a non-tautology | High (false positive validity) | Very Low | Only checks structural equality `a == b` and recurses into consequent/box; both are sound |
| Lean type-checker rejects the recursive definition | Low (build failure) | Very Low | The recursion is structurally decreasing on formula constructors; Lean's termination checker should accept it |
| Performance regression from deeper recursion | Low | Very Low | Recursion depth bounded by formula constructor nesting; pre-filter is O(n) in formula size |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Implement recursive unsatisfiability and consequent validity [COMPLETED]

**Goal**: Modify `isUnsatBotTemporal` to recurse into Until/Since event arguments, add `isStructurallyValid`, and integrate both into `structuralPrefilter`.

**Tasks**:
- [x] Modify `isUnsatBotTemporal` (lines 401-405): add `.bot => true` base case, change `.untl .bot _ => true` to `.untl event _ => isUnsatBotTemporal event`, change `.snce .bot _ => true` to `.snce event _ => isUnsatBotTemporal event`
- [x] Add `isStructurallyValid` function after `isUnsatBotTemporal` (around line 406): handle `.imp a b => a == b || isStructurallyValid b`, `.box inner => isStructurallyValid inner`, `_ => false`
- [x] Update the docstring for `isUnsatBotTemporal` to document the recursive behavior
- [x] Add docstring for `isStructurallyValid` explaining soundness
- [x] Modify `structuralPrefilter` (line 422): add `else if isStructurallyValid consequent then some true` after the `isUnsatBotTemporal antecedent` check
- [x] Update the docstring for `structuralPrefilter` to document the new consequent validity pattern
- [x] Add `#eval` tests for `isUnsatBotTemporal` recursive cases: `U(box(bot), p)`, `S(U(bot, q), p)`, `U(p, q)` (negative), `box(U(bot, p))`
- [x] Add `#eval` tests for `isStructurallyValid`: `imp p p`, `imp q (imp p p)`, `box (imp p p)`, `p` (negative), `imp p q` (negative)
- [x] Add `#eval` tests for `structuralPrefilter` integration: `imp (untl (box bot) p) q` (recursive unsat), `imp p (imp q q)` (consequent validity)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - All changes: modify `isUnsatBotTemporal` (~lines 401-405), add `isStructurallyValid` (~line 406), modify `structuralPrefilter` (~line 422), add `#eval` tests

**Verification**:
- All `#eval` tests produce expected results
- No compilation errors in `DatasetGenerator.lean`

---

### Phase 2: Build verification and regression check [COMPLETED]

**Goal**: Verify the changes compile cleanly with `lake build`, confirm no new sorries or axiom regressions, and verify the pre-filter correctly handles the new patterns.

**Tasks**:
- [x] Run `lake build Theories.Bimodal.Automation.DatasetGenerator` to verify the module compiles *(deviation: altered -- used `lake build Bimodal.Automation.DatasetGenerator` per lakefile module naming)*
- [x] Run `lake build` to verify the full project compiles cleanly
- [x] Verify no new `sorry` appears in `DatasetGenerator.lean` (grep check)
- [x] Verify no new `axiom` usage (grep check or `#print axioms` on key definitions)

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds with no errors
- No new sorry or axiom occurrences in the modified file
- All `#eval` tests pass (confirmed by successful compilation)

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Automation.DatasetGenerator` compiles without errors
- [ ] `lake build` full project compiles without errors
- [ ] `#eval isUnsatBotTemporal (Formula.untl (Formula.box .bot) p)` evaluates to `true`
- [ ] `#eval isUnsatBotTemporal (Formula.snce (Formula.untl .bot q) p)` evaluates to `true`
- [ ] `#eval isUnsatBotTemporal (Formula.untl p q)` evaluates to `false`
- [ ] `#eval isStructurallyValid (Formula.imp p p)` evaluates to `true`
- [ ] `#eval isStructurallyValid (Formula.imp q (Formula.imp p p))` evaluates to `true`
- [ ] `#eval isStructurallyValid (Formula.imp p q)` evaluates to `false` (when p and q are distinct atoms)
- [ ] `#eval structuralPrefilter (Formula.imp p (Formula.imp q q))` evaluates to `some true`
- [ ] No new sorries in DatasetGenerator.lean (grep confirmation)

## Artifacts & Outputs

- `specs/270_extend_prefilter_recursive_unsat/plans/01_recursive-unsat-plan.md` (this file)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` (modified, ~30 lines changed)

## Rollback/Contingency

All changes are in a single file (`DatasetGenerator.lean`). If any issue arises:
1. Revert the file with `git checkout -- Theories/Bimodal/Automation/DatasetGenerator.lean`
2. The pre-filter is purely additive (only marks formulas as "known valid", never "known invalid"), so reverting has no impact on existing valid/invalid classifications
3. If only one of the two extensions causes issues, they can be applied independently -- the recursive `isUnsatBotTemporal` fix and the `isStructurallyValid` addition are orthogonal changes
