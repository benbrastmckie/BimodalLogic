# Research Report: Task #452

**Task**: 452 - Use 'D' notation for duration group consistently
**Started**: 2026-01-12T14:00:00Z
**Completed**: 2026-01-12T14:30:00Z
**Effort**: medium
**Priority**: low
**Dependencies**: None
**Sources/Inputs**: Source paper (JPL), LaTeX files, Lean code
**Artifacts**: specs/452_use_d_notation_for_duration_group/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The source paper `/home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` uses `D` (rendered as `\mathcal{D}`) for the temporal order / duration group, with elements from set `D`
- The ProofChecker LaTeX files use `T` for the temporal duration type, inconsistent with the paper
- The ProofChecker Lean code also uses `T` as the type parameter for temporal durations
- Changes required: 27 occurrences in LaTeX files, ~100+ occurrences in Lean files

## Context & Scope

The task requires aligning the ProofChecker documentation and code with the notation used in the reference paper "The Construction of Possible Worlds" (JPL submission). The paper establishes `D` as the standard symbol for the totally ordered abelian group of durations.

### Source Paper Convention

From `/home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`:

```latex
\newcommand{\D}{\mathcal{D}}  % Line 132 - Calligraphic D for temporal order

% Line 853: Definition
"I will take a temporal order to be a totally ordered abelian group
\D = \tuple{D, +, \leq}."

% Line 862: Frame definition
"a frame to be any \F = \tuple{W, \D, \Rightarrow}"
```

Key notation in the paper:
- `\D` (mathcal{D}) = the temporal order structure (a totally ordered abelian group)
- `D` = the underlying set of durations/times
- `d, x, y` = individual duration elements

## Findings

### LaTeX Files Analysis

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex`

27 occurrences of `T` used for durations that should become `D`:

| Line | Current Usage | Context |
|------|---------------|---------|
| 19 | `$T$ & Type & Temporal durations` | Table primitive |
| 20 | `$w \taskto{x} u$ & $\worldstate \to T \to \worldstate \to \text{Prop}$` | Task relation type |
| 26 | `task frame over temporal type $T$` | Definition |
| 29 | `$x, y : T$` | Compositionality constraint |
| 43 | `$\domain : T \to \text{Prop}$` | Convex domain |
| 44 | `$a, b, c : T$` | Convexity condition |
| 49 | `$\tau : (x : T) \to \domain(x) \to \worldstate$` | World history |
| 49 | `$x, y : T$` | History constraint |
| 67 | `time $x : T$` | Truth definition |
| 71 | `time $x : T$` | Truth clause |
| 80 | `$y : T$` | Past quantifier |
| 82 | `$y : T$` | Future quantifier |
| 87 | `$x : T$` | Modal operator |
| 88 | `$y : T$` | Temporal operators |
| 102 | `$x, y : T$` | Time-shift definition |
| 102 | `$\bar{a} : T \to T$` | Automorphism |
| 121 | `$T : \text{Type}$` | Logical consequence |
| 121 | `$\text{TaskFrame}(T)$` | Frame type |
| 121 | `$x : T$` | Time parameter |
| 130 | `$T : \text{Type}$` | Satisfiability |
| 130 | `$\text{TaskFrame}(T)$` | Frame type |
| 130 | `$x : T$` | Time parameter |

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/06-Notes.tex`

| Line | Current Usage | Context |
|------|---------------|---------|
| 69 | `$T = \mathbb{Z}$` | Paper uses fixed integers |
| 70 | `any type $T$` | Implementation generalizes |

**Files with no T-duration usage** (use T for other purposes):
- `03-ProofTheory.tex`: Uses `T` only in axiom names (MT, T4, TA, TL, TF) - NOT duration-related
- `04-Metalogic.tex`: Uses `T(φ)` for "formula assumed true" in tableaux - NOT duration-related
- `05-Theorems.tex`: Uses `T-Box` as theorem name prefix - NOT duration-related

### Lean Code Analysis

The Lean code uses `T` as the type parameter for temporal durations throughout. Key files affected:

**Core Semantics** (highest impact):
1. `Theories/Bimodal/Semantics/TaskFrame.lean` - Structure definition
   - `structure TaskFrame (T : Type*)` - core definition
   - All frame examples use `T`

2. `Theories/Bimodal/Semantics/WorldHistory.lean`
   - `structure WorldHistory {T : Type*}`
   - All functions parameterized by `T`

3. `Theories/Bimodal/Semantics/TaskModel.lean`
   - `structure TaskModel {T : Type*}`

4. `Theories/Bimodal/Semantics/Truth.lean`
   - All truth functions parameterized by `T`

5. `Theories/Bimodal/Semantics/Validity.lean`
   - Universal quantification over `T : Type`

**Metalogic**:
6. `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
   - `is_valid` definition uses `T`

7. `Theories/Bimodal/Metalogic/Completeness.lean`
   - References to duration type

**Examples/Tests**:
8. `Theories/Bimodal/Examples/TemporalStructures.lean`
   - `genericTimeFrame`, `genericNatFrame` definitions

**Logos SubTheories**:
9. `Theories/Logos/SubTheories/Explanatory/Frame.lean`
   - `CoreFrame (T : Type*)`

10. `Theories/Logos/SubTheories/Explanatory/Truth.lean`
    - `TemporalIndex (T : Type*)`

### Notation Package

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/assets/bimodal-notation.sty`

Currently has no macro for `\D`. Should add:
```latex
\newcommand{\D}{\mathcal{D}}  % Duration/temporal order structure
```

This matches the paper's convention at line 132.

## Decisions

1. **Scope**: Change `T` to `D` for duration/time type parameters only
2. **Exclusions**: Do NOT change:
   - Axiom names (MT, T4, TA, TL, TF) - these are logic naming conventions
   - Tableau signed formulas `T(φ)` - means "true"
   - Theorem name prefixes (T-Box, etc.)
3. **LaTeX macro**: Add `\D` to `bimodal-notation.sty` for consistency
4. **Lean convention**: Use `D` as type parameter, `d` for elements

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing code | Medium | High | Run `lake build` after each file change |
| Missing occurrences | Medium | Low | Use systematic Grep/search-replace |
| Confusion with other `D` uses | Low | Medium | Document convention clearly |
| Merge conflicts with other branches | Low | Medium | Complete in single session |

## Implementation Recommendations

### Phase 1: LaTeX Files (Estimated: 30 min)

1. Add `\D` macro to `bimodal-notation.sty`
2. Update `02-Semantics.tex` - 27 changes
3. Update `06-Notes.tex` - 2 changes
4. Rebuild PDF to verify

### Phase 2: Lean Code (Estimated: 2-3 hours)

Recommended order (dependency-safe):
1. `TaskFrame.lean` - core structure
2. `TaskModel.lean` - depends on TaskFrame
3. `WorldHistory.lean` - depends on TaskFrame
4. `Truth.lean` - depends on TaskModel, WorldHistory
5. `Validity.lean` - depends on all above
6. `SoundnessLemmas.lean`
7. `Completeness.lean`
8. `TemporalStructures.lean` (examples)
9. Logos SubTheories (Frame.lean, Truth.lean)

For each file:
- Replace `(T : Type*)` with `(D : Type*)`
- Replace `[AddCommGroup T]` with `[AddCommGroup D]`
- Replace `[LinearOrder T]` with `[LinearOrder D]`
- Replace `[IsOrderedAddMonoid T]` with `[IsOrderedAddMonoid D]`
- Replace `TaskFrame T` with `TaskFrame D`
- Replace variable names `t : T` with `d : D` where appropriate
- Run `lake build` to verify

### Phase 3: Tests (Estimated: 1 hour)

Update test files in `Tests/BimodalTest/` that reference `T` for durations.

## Appendix

### Search Queries Used

```bash
# LaTeX T occurrences for durations
grep -n '\bT\b' /home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/**/*.tex

# Lean T type parameter for durations
grep -rn '(T : Type\*\?)' /home/benjamin/Projects/ProofChecker/Theories/
grep -rn 'TaskFrame T' /home/benjamin/Projects/ProofChecker/Theories/
grep -rn 'AddCommGroup T' /home/benjamin/Projects/ProofChecker/Theories/
```

### Source Paper References

- Line 132: `\newcommand{\D}{\mathcal{D}}`
- Line 851-858: Definition of temporal order as totally ordered abelian group
- Line 862: Frame definition using `\D`
- Line 1844: Appendix formal definition

### Files to Modify

**LaTeX** (3 files):
1. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/assets/bimodal-notation.sty`
2. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex`
3. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/06-Notes.tex`

**Lean** (11+ files):
1. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean`
2. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskModel.lean`
3. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean`
4. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`
5. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`
6. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
7. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`
8. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Examples/TemporalStructures.lean`
9. `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Explanatory/Frame.lean`
10. `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Explanatory/Truth.lean`
11. `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Explanatory.lean`
