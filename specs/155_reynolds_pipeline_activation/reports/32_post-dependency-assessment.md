# Post-Dependency Assessment: Tasks 168, 174, 181, 195, 198

**Task**: 155 - reynolds_pipeline_activation
**Date**: 2026-05-26
**Status**: Research assessment of dependency task completions

## Executive Summary

Four dependency tasks (168, 174, 195, 198) and one related task (181) have completed since task 155 was paused. The file splitting (tasks 168 + 174) successfully decomposed ExpressivenessGeneral.lean into focused modules, resolving the compile-time bottleneck. Task 195 delivered EF game automation tactics that survive the split. Task 198 eliminated 2 sorry sites in Completeness.lean (completeness_dense and completeness_discrete frame-class indicator branches). Task 181 added Derivable Prop-wrapper infrastructure. The three original Phase 3 blockers (inaccessible Fin variables in same_order_type_grid dispatch) remain unchanged. The plan v31 Phase 9 sorry sites (Completeness.lean lines 226, 256, 281, 290) no longer exist -- task 198 resolved those.

## Task Impact Analysis

### Task 168: Parameterize DerivationTree over FrameClass [COMPLETED]

**What it accomplished**:
- Added PartialOrder on FrameClass (Base <= Dense, Base <= Discrete)
- Added density axiom constructor to Axiom (41 constructors total)
- Parameterized DerivationTree over `(fc : FrameClass)` with `h_fc : ax.minFrameClass <= fc` gate
- Added `lift` function for fc1 <= fc2
- Removed ad-hoc predicates (isBase, isDenseCompatible, isDiscreteCompatible)
- Eliminated h_dc side-conditions from soundness theorems

**Relevance to task 155**: Prerequisite for task 174. The parameterized DerivationTree is now used throughout the codebase. No direct sorry-site impact on task 155, but the cleaner axiom system makes Phase 9 (final wiring) simpler since `completeness_dense` and `completeness_discrete` now use FrameClass.Dense and FrameClass.Discrete directly.

### Task 174: Split Oversized Files [COMPLETED]

**What it accomplished**:
- Split 12 oversized files (50K+ lines total) into 35 focused modules
- ExpressivenessGeneral.lean (~10K lines) -> 5 files in `Expressiveness/`:
  - `SplitPoint.lean` (4657 lines) -- split point infrastructure, obtain_split_point_props
  - `CaseAnalysis.lean` (2688 lines) -- Cases I, II, III-IV for Theorem 6
  - `Claim1.lean` (1629 lines) -- GHR93 Claim 1 proof
  - `DConsistencyTransport.lean` (742 lines) -- d-consistency transport
  - `Theorem6.lean` (312 lines) -- Theorem 6 (forward-to-backward rank-varying)
- EFGames.lean -> 6 files in `EFGames/`:
  - `Defs.lean`, `CustomGame.lean`, `GapDetection.lean` (5057 lines), `Decomposition.lean`, `TypeFormulas.lean`, `StaviCompleteness.lean` (1652 lines)
- IntegerModel.lean -> 2 files in `IntegerModel/`:
  - `GoodStructures.lean` (909 lines), `ShiftAndGlue.lean` (904 lines)
- All downstream imports updated; lake build passes (1667 jobs)

**Relevance to task 155 -- MAJOR**: This was the primary bottleneck. The sorry sites that were in ExpressivenessGeneral.lean at lines ~8521, ~8644, ~9580, ~9942 are now in smaller, faster-compiling files:

| Old Location (ExpressivenessGeneral.lean) | New Location | Plan Phase |
|-------------------------------------------|-------------|------------|
| ~line 8521 (Case A sorry) | `Expressiveness/CaseAnalysis.lean:1560` | Phase 3 |
| ~line 8644 (Case B sorry, same_order_type) | `Expressiveness/CaseAnalysis.lean:1648` | Phase 3 |
| ~line 8662 (Case B sorry, dead code) | `Expressiveness/CaseAnalysis.lean:1701` | Phase 3 |
| ~line 9580 (S11, Cases III-IV) | `Expressiveness/CaseAnalysis.lean:2619` | Phase 5 |
| ~line 9942 (S12, rank-varying fwd-to-bwd) | `Expressiveness/Theorem6.lean:307` | Phase 5 |
| S13 (NF characterization) | `EFGames/StaviCompleteness.lean:1567` | Phase 6 |
| S14 (no_gaps_discrete) | `IntegerModel/GoodStructures.lean:842` | Phase 7 |

**Compile time reduction**: CaseAnalysis.lean is 2688 lines (vs 10K), so compile cycles should be well under 1 minute instead of 3-5 minutes.

### Task 181: Derivable Prop-Valued Wrapper [COMPLETED]

**What it accomplished**:
- Added `Derivable` Prop-valued wrapper with 7 constructor-mirroring lemmas
- Added aesop/simp attributes and `|-!` notation
- Zero sorries, 180 lines

**Relevance to task 155**: Minimal direct impact. The `Derivable` wrapper provides ergonomic proof infrastructure but is not on the critical path for any Phase 3-9 sorry site.

### Task 195: EF Game Automation Tactics [COMPLETED]

**What it accomplished**:
- Created `EFGameTactics.lean` (208 lines) with 4 tactic components:
  - `same_order_type_grid` macro -- 4x4 grid dispatch for same_order_type proofs
  - `simp_game_tuple` / `game_tuple_unfold` -- game_tuple simplification
  - `pivot_chain_order'` / `pivot_chain_order_rev'` -- pair-based convenience wrappers
  - `gap_point_agreement_of_cases` / `formula_agreement_of_cases` -- 4-way agreement dispatch
- Relocated 6 private lemmas from ExpressivenessGeneral to EFGames (game_tuple_*_eq, pivot_chain_order/rev)
- Replaced ~36 call sites in ExpressivenessGeneral

**Relevance to task 155 -- MODERATE**: The `same_order_type_grid` macro is the exact code that creates the inaccessible Fin variables (`i+`, `j+`) in Phase 3. The macro survived the file split (referenced at CaseAnalysis.lean:1418). The Phase 3 blocker is fundamentally about how the grid dispatch interacts with `first | ... | sorry` branches, not about the macro itself. Task 195's tactics are useful infrastructure but do not resolve the Fin variable issue.

### Task 198: Frame-Class Indicator Forcing [COMPLETED]

**What it accomplished**:
- Added `dense_indicator` axiom (`neg(U(T,bot))`) to the Axiom type
- Proved `completeness_dense` non-dense branch: `dense_indicator` is a Dense theorem, so `box(neg(U(T,bot)))` is in every Dense-MCS, contradiction
- Proved `completeness_discrete` dense branch: derived `U(T,bot)` (next_top) from prior_UZ + serial_future + guard weakening via left_mono_until_G
- Eliminated 2 sorry sites in Completeness.lean

**Relevance to task 155 -- SIGNIFICANT**: The plan v31 Phase 9 listed 4 sorry sites in Completeness.lean (lines 226, 256, 281, 290). These no longer exist. The `completeness_dense` and `completeness_discrete` theorems are now sorry-free in their own file. The remaining `sorryAx` dependency for `completeness` traces through `countermodel_discrete` -> `dd_countermodel_chronicle_discrete` -> `succ_cofinal` (the root sorry at ChronicleToCountermodel.lean:1885).

## Current Sorry Inventory

### Critical-Path Sorry Sites (blocking sorry-free `completeness`)

| # | File | Line | Plan Phase | Description | Status |
|---|------|------|------------|-------------|--------|
| S8 | Expressiveness/CaseAnalysis.lean | 1560 | Phase 3 | Case A: 3 goals, inaccessible Fin variables | UNCHANGED |
| S9 | Expressiveness/CaseAnalysis.lean | 1648 | Phase 3 | Case B: same_order_type (tau ordering) | UNCHANGED |
| S10 | Expressiveness/CaseAnalysis.lean | 1701 | Phase 3 | Case B: dead code sorry (in block comment?) | NEEDS VERIFICATION |
| S11 | Expressiveness/CaseAnalysis.lean | 2619 | Phase 5 | Cases III-IV: gap detection | UNCHANGED |
| S12 | Expressiveness/Theorem6.lean | 307 | Phase 5 | Rank-varying fwd-to-bwd (Lemma 10) | UNCHANGED |
| S13 | EFGames/StaviCompleteness.lean | 1567 | Phase 6 | NF characterization inductive step | UNCHANGED |
| S14 | IntegerModel/GoodStructures.lean | 842 | Phase 7 | no_gaps_discrete (Reynolds Thm 5) | UNCHANGED |
| SC | ChronicleToCountermodel.lean | 1885 | Phase 8 | succ_cofinal | UNCHANGED |
| SC-sub1 | ChronicleToCountermodel.lean | 1285 | Phase 8 | succ_cofinal sub-proof (boundary case) | UNCHANGED |
| SC-sub2 | ChronicleToCountermodel.lean | 1441 | Phase 8 | succ_cofinal sub-proof (below-min) | UNCHANGED |
| SC-sub3 | ChronicleToCountermodel.lean | 1508 | Phase 8 | limit_dom_points_are_succ_iterates | UNCHANGED |

### Non-Critical-Path Sorry Sites

The plan v31 Phase 9 sorry sites in Completeness.lean (formerly lines 226, 256, 281, 290) have been **resolved by task 198**. Completeness.lean now has zero active sorry statements.

## Updated Blocker Status

### Blocker 1: Inaccessible Fin variables in same_order_type_grid (Phase 3 Case A)

**Status**: UNCHANGED

The `same_order_type_grid` macro (now in EFGameTactics.lean) introduces inaccessible Fin variables `i+`, `j+` via `intro i j; simp only [game_tuple]; split_ifs`. Inside `first | ... | sorry` branches, these variables cannot be referenced by name.

3 goals remain:
- Goal A: `(y' < a_bwd {j+ - 1, ...} <-> y < resp_tau {j+ - 1, ...})` -- y vs sel(k<n)
- Goal B: `(a_bwd {i+ - 1, ...} < a_bwd {j+ - 1, ...} <-> resp_tau {i+ - 1, ...} < e_n)` -- sel vs p_n
- Goal C: `(extendPoint p_n < a_bwd {j+ - 1, ...} <-> e_n < resp_tau {j+ - 1, ...})` -- p_n vs sel

**Recommended fix** (unchanged from handoff): Refactor dispatch to use explicit `intro i j` before `same_order_type_grid`, or add helper lemma `a_bwd_p_n_eq`.

### Blocker 2: Phase 3 Case B sigma extraction

**Status**: UNCHANGED

Case B sorry (CaseAnalysis.lean:1648) needs sigma extraction for `(x' < d <-> x < c)` plus cross-boundary pivots. Same Fin variable issue applies. Must fix Case A first.

### Blocker 3: ExpressivenessGeneral.lean compile time (3-5 min cycles)

**Status**: RESOLVED by task 174

ExpressivenessGeneral.lean has been split into 5 focused files. CaseAnalysis.lean (2688 lines) contains all Phase 3 sorry sites. Compile time should be well under 1 minute.

## Plan v31 Phase Update Assessment

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1 | COMPLETED | S3, S5 closed |
| Phase 2 | COMPLETED | S1, S2, S4, S7-right closed via K-(negD) |
| Phase 3 | PARTIAL | 3 goals in Case A (S8), Case B (S9, S10) not attempted. File paths updated. |
| Phase 4 | COMPLETED | S6, S7 closed via rank_down_proj |
| Phase 5 | NOT STARTED | S11 (CaseAnalysis.lean:2619), S12 (Theorem6.lean:307). File paths updated. |
| Phase 6 | NOT STARTED | S13 (StaviCompleteness.lean:1567). File path updated. |
| Phase 7 | NOT STARTED | S14 (GoodStructures.lean:842). File path updated. |
| Phase 8 | NOT STARTED | succ_cofinal (ChronicleToCountermodel.lean:1885). Unchanged. |
| Phase 9 | PARTIALLY RESOLVED | 4 sorry sites eliminated by task 198. Remaining work: verify `#print axioms completeness` after Phases 3-8 complete. |

## Build Status

`lake build` passes cleanly with 1667 jobs. Only lint warnings (unused variables).

## Recommended Next Steps

1. **Revise plan v31** to update file paths from ExpressivenessGeneral.lean to the new split files (Expressiveness/CaseAnalysis.lean, Expressiveness/Theorem6.lean, EFGames/StaviCompleteness.lean, IntegerModel/GoodStructures.lean). Update Phase 9 to reflect that Completeness.lean sorry sites are resolved.

2. **Resume Phase 3** with the Fin variable fix. The recommended approach from the handoff remains valid:
   - Option A: Refactor dispatch structure to use explicit `intro i j` before `same_order_type_grid`
   - Option B: Add helper lemma `a_bwd_p_n_eq : forall i, neg(i - 1 < n) -> a_bwd {i - 1, _} = extendPoint p_n`

3. **Phase 3 timing estimate**: 2-4 hours (reduced from 3-5 hour estimate thanks to faster compile cycles from file splitting).

4. **Critical path remains**: Phases 3 -> 5 -> 6 -> 7 -> 8 -> 9 (verification only). Total estimated: 15-25 hours.
