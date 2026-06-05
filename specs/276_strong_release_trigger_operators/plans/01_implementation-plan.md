# Implementation Plan: Strong Release and Strong Trigger Operators

- **Task**: 276 - strong_release_trigger_operators
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: 275
- **Research Inputs**: specs/276_strong_release_trigger_operators/reports/01_research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Add Strong Release `M(φ,ψ) := ψ U (ψ ∧ φ)` and Strong Trigger `ST(φ,ψ) := ψ S (ψ ∧ φ)` as derived temporal operators in the BimodalLogic TM formalization. These complete the classical LTL operator quartets `{U, W, R, M}` (future) and `{S, WS, T, ST}` used in positive normal form. The implementation follows the light integration pattern established by task 275 (syntax, complexity, enumeration), with optional extensions to normalization, semantics, and axiom schemata if time permits.

### Research Integration

The research report (`specs/276_strong_release_trigger_operators/reports/01_research.md`) identified 7 files requiring changes and established that task 275 performed a "light" integration of R/WU/T/WS. Task 276 follows the same baseline: add `def` abbreviations in `Formula.lean`, complexity pattern-matching with overhead 2 (one higher than R/WU/T/WS overhead 1), enumeration expansion from 4 to 6 binary temporal options, and optional normalization/semantic/axiom extensions. Key mathematical definitions: `M(φ,ψ) = untl (and ψ φ) ψ` and `ST(φ,ψ) = snce (and ψ φ) ψ`.

### Prior Plan Reference

No prior plan exists for task 276.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `strong_release` and `strong_trigger` definitions as `def` abbreviations in `Formula.lean`
- Add complexity pattern-matching with overhead 2 and verify with `#eval` tests
- Add `swap_temporal` distribution lemmas for both operators
- Expand `FormulaEnumerator.lean` from 4 to 6 binary temporal options in all sampling functions
- Add unfold lemmas and tactic macro updates in `Normalization.lean`
- Add `@[simp]` characterization theorems in `Truth.lean`
- Add bimodal interaction schemata (theorems or axioms) for M/ST with modal operators
- Verify `lake build` passes and c5 generation includes new bimodal formulas with M/ST

**Non-Goals**:
- Adding new inductive constructors to the `Formula` type (M/ST remain derived operators)
- Adding dedicated `Axiom` inductive constructors for M/ST (derive from existing axioms)
- Full `EnrichedFormula` fold recognition if it proves intractable within time budget
- Changes to `InterestingnessMetrics.lean` (M/ST are covered by existing `hasUntil`/`hasSince`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Complexity pattern ambiguity with repeated ψ in guard position | Medium | Low | Use `ψ2` naming convention (consistent with WU/WS patterns); verify with `#eval` |
| Normalization fold recognition interference with existing `and_` patterns | Medium | Medium | Add M/ST recognition in `recognizeComposites` after `and_` recognition; test round-trip |
| Enumeration blowup from 4 to 6 binary operators | Low | Low | Acceptable increase (~50% at each temporal level); complexity budget still governs total output |
| Missing file updates due to scattered occurrences | Medium | Medium | Grep for `release\|weak_until\|trigger\|weak_since` before and after to find all parallel update sites |
| Axiom schemata derivation exceeds time budget | Medium | Medium | Defer to Theorems/ proofs using existing axioms + definitions; mark as optional in plan |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 4 |
| 4 | 6 | 2, 3, 4, 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Core Syntax and Complexity [COMPLETED]

**Goal**: Add `strong_release` and `strong_trigger` definitions, complexity patterns, `swap_temporal` lemmas, and `#eval` verification tests in `Formula.lean`.

**Tasks**:
- [ ] Add `def strong_release (φ ψ : Formula) : Formula := Formula.untl (Formula.and ψ φ) ψ` after `weak_since` definition
- [ ] Add `def strong_trigger (φ ψ : Formula) : Formula := Formula.snce (Formula.and ψ φ) ψ` after `strong_release`
- [ ] Add complexity pattern-matching for `strong_release` primitive expansion with overhead 2
- [ ] Add complexity pattern-matching for `strong_trigger` primitive expansion with overhead 2
- [ ] Add `#eval` tests verifying `M(atom, atom)` and `ST(atom, atom)` evaluate to complexity 4
- [ ] Add `swap_temporal_strong_release` and `swap_temporal_strong_trigger` theorems
- [ ] Run `lake build` to verify syntax layer compiles

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` — operator defs, complexity patterns, eval tests, swap lemmas

**Verification**:
- `lake build` succeeds with no errors in `Formula.lean`
- `#eval (Formula.strong_release p_cmplx2 q_cmplx2).complexity` returns 4
- `#eval (Formula.strong_trigger p_cmplx2 q_cmplx2).complexity` returns 4

---

### Phase 2: Formula Enumeration [COMPLETED]

**Goal**: Expand exact enumeration and all random sampling functions from 4 to 6 binary temporal operator options to include M/ST.

**Tasks**:
- [ ] Update `enumExactHelper` to add `strongReleases` and `strongTriggers` arrays alongside existing `releases`/`weakUntils`/`triggers`/`weakSinces`
- [ ] Update `sampleOne` (LCG sampling) `rtwsChoice` from `IO.rand 0 3` to `IO.rand 0 5` with cases for M and ST
- [ ] Update `sampleOneRandom` branch at lines ~873 to include M/ST options
- [ ] Update `sampleOneRandom` branch at lines ~896 to include M/ST options
- [ ] Update `sampleOneRandom` branch at lines ~914 to include M/ST options
- [ ] Update `randomSubFormula` at line ~1100 to expand from 4 to 6 options
- [ ] Run `lake build` to verify enumeration layer compiles

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — exact enumeration and 4+ random sampling locations

**Verification**:
- `lake build` succeeds
- Grep confirms all `release`/`weak_until`/`trigger`/`weak_since` sampling sites updated to 6 options

---

### Phase 3: Normalization [COMPLETED]

**Goal**: Add unfold lemmas, update tactic macros, and optionally add EnrichedFormula constructors and serialization for M/ST.

**Tasks**:
- [ ] Add `@[simp] theorem strong_release_unfold` and `strong_trigger_unfold` in `UnfoldLemmas` section
- [ ] Update `modal_norm`, `modal_norm_at`, `modal_norm_all`, `modal_fold` tactic macros to include new unfold lemmas
- [ ] (Optional) Add `strong_release` and `strong_trigger` constructors to `EnrichedFormula`
- [ ] (Optional) Update `toPrimitive` cases for new constructors
- [ ] (Optional) Update `foldFormula`/`recognizeComposites` to recognize M/ST primitive patterns
- [ ] (Optional) Update serialization (`toJson`, `prettyPrint`, `toSExpr`) for new constructors
- [ ] Run `lake build` to verify normalization layer compiles

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/Normalization.lean` — unfold lemmas, tactic macros, EnrichedFormula (optional)

**Verification**:
- `lake build` succeeds
- `simp [strong_release_unfold]` and `simp [strong_trigger_unfold]` work correctly

---

### Phase 4: Semantic Characterization [COMPLETED]

**Goal**: Add `@[simp]` characterization theorems for truth conditions of M and ST in `Truth.lean`.

**Tasks**:
- [ ] Add `@[simp] theorem strong_release_iff` characterizing `truth_at M Omega τ t (Formula.strong_release φ ψ)` as existence of future point where `ψ ∧ φ` holds with intermediate `ψ`
- [ ] Add `@[simp] theorem strong_trigger_iff` characterizing past-directed existence with intermediate `ψ`
- [ ] Run `lake build` to verify semantics layer compiles

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` — truth characterization theorems

**Verification**:
- `lake build` succeeds
- Theorems are provable via `simp [Formula.strong_release, Formula.and, truth_at]` or similar

---

### Phase 5: Axiom Schemata and Derived Theorems [COMPLETED]

**Goal**: Add bimodal interaction theorems for M/ST with modal operators (box, diamond, G, F, H, P), derived from existing axioms rather than new axiom constructors.

**Tasks**:
- [ ] Identify which existing temporal axioms (BX1-BX12) imply M/ST interaction properties
- [ ] Derive theorems such as `□φ → G(M(φ,ψ))` equivalents or duality properties using existing axioms + definitions
- [ ] Add theorems to an appropriate file in `Theories/Bimodal/Theorems/` or inline in `ProofSystem/Axioms.lean` as derived lemmas
- [ ] If direct derivation is too complex, document the intended theorems as comments and defer to future task
- [ ] Run `lake build` to verify proof layer compiles

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` or `Theories/Bimodal/Theorems/` — derived interaction theorems

**Verification**:
- `lake build` succeeds
- All new theorems are proven (no `sorry` placeholders)

---

### Phase 6: Testing and Final Verification [COMPLETED]

**Goal**: Add unit tests, run c5 generation, and perform final build verification.

**Tasks**:
- [ ] Add complexity unit tests in `Tests/BimodalTest/` for M/ST (complexity = 4 for atom, atom)
- [ ] Add normalization round-trip tests if EnrichedFormula constructors were added in Phase 3
- [ ] Run `generateBimodalSlice` at complexity 5 and confirm M/ST operators appear in output
- [ ] Run full `lake build` and confirm zero errors/warnings
- [ ] Grep codebase for any remaining `release`/`weak_until`/`trigger`/`weak_since` sites that may need parallel M/ST updates
- [ ] Verify `hasBimodalInteraction` predicates or similar coverage includes M/ST patterns

**Timing**: 1 hour

**Depends on**: 2, 3, 4, 5

**Files to modify**:
- `Tests/BimodalTest/` — unit tests for complexity, normalization, enumeration

**Verification**:
- `lake build` succeeds with zero errors
- c5 generation output contains formulas with `strong_release` or `strong_trigger`
- All `#eval` tests evaluate correctly
- Grep audit shows no orphaned update sites

## Testing & Validation

- [ ] `#eval (Formula.strong_release p_cmplx2 q_cmplx2).complexity` returns 4
- [ ] `#eval (Formula.strong_trigger p_cmplx2 q_cmplx2).complexity` returns 4
- [ ] `lake build` passes after each phase boundary
- [ ] `generateBimodalSlice` at complexity 5 produces formulas containing M/ST operators
- [ ] `swap_temporal_strong_release` and `swap_temporal_strong_trigger` lemmas are proven
- [ ] `strong_release_iff` and `strong_trigger_iff` `@[simp]` lemmas compile and apply correctly
- [ ] All random sampling functions in `FormulaEnumerator.lean` include M/ST (grep verification)
- [ ] No `sorry` placeholders remain in any modified file

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/Formula.lean` — `strong_release`/`strong_trigger` definitions, complexity, swap lemmas
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — expanded enumeration with 6 binary temporal operators
- `Theories/Bimodal/Automation/Normalization.lean` — unfold lemmas, tactic macro updates, optional EnrichedFormula support
- `Theories/Bimodal/Semantics/Truth.lean` — `@[simp]` truth characterization theorems
- `Theories/Bimodal/ProofSystem/Axioms.lean` or `Theories/Bimodal/Theorems/` — bimodal interaction theorems
- `Tests/BimodalTest/` — unit tests for new operators
- `specs/276_strong_release_trigger_operators/plans/01_implementation-plan.md` — this plan file

## Rollback/Contingency

If implementation fails or must be reverted:
1. Revert all modified source files using git (`git checkout -- Theories/Bimodal/Syntax/Formula.lean ...`)
2. If partial progress exists, revert to last known good commit before task 276 work began
3. If task 275 baseline was also modified, verify it remains intact independently
4. Document which phases were completed before rollback in the task summary
