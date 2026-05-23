# Implementation Summary: ExpressivenessGeneral Sorry Analysis

**Task**: 155 - reynolds_pipeline_activation
**Session**: sess_1779565373_9bf0c5
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
**Outcome**: No sorries closed; deep structural analysis completed

## What Was Accomplished

Performed comprehensive structural analysis of all 14 sorry sites in ExpressivenessGeneral.lean. Classified every sorry into one of 5 categories (A-E) with concrete fix proposals, effort estimates, and dependency analysis.

## Key Findings

### 1. Degenerate Gap Sorries (Lines 2426, 2443) - Category A

**Root cause**: `SplitPointProps` requires carrier-point witnesses in sub-intervals `[x, c]` and `[c, y]`. When `x = c` or `c = y` and `c` is a gap (Sum.inr), no carrier point exists in the zero-width interval. The goals are genuinely unprovable (Sum.inl != Sum.inr).

**Fix**: Change `h_pt_xc` and `h_pt_cy` fields to disjunctive form:
```
h_pt_xc : (exists p, ...) | (x = c /\ IsGap c)
h_pt_cy : (exists p, ...) | (c = y /\ IsGap c)
```

6 consumer sites need updating. Case II consumers are trivial (degenerate gap contradicts IsPoint c, which is always established before the fields are accessed). Case I consumers require more work: when a sub-interval is degenerate-gap, the sub-game yields vacuous data.

### 2. Gap Infimum Sorries (Lines 2013, 2104) - Category B

**Root cause**: Case 3 of infimum construction (no carrier-point GLB) needs `infimum_gap` + `infimum_gap_r_definable`. The precondition `h_above` is derivable (case split on whether S_C contains a carrier point or a gap). The precondition `hx'_bound` is harder when x' is a gap: the carrier-point lower bounds may all be below x'. Proposed sub-case split to handle d = x' directly.

### 3. K-minus Formula Sorries (Lines 2307, 2331, 2949, 3026, 3030) - Category C

All blocked on K-minus(not D) = neg(std_snce(neg(base .bot), D)) construction. Requires pigeonhole formula materialization, depth-r+2 formula construction, and Since(top, D) semantics proof. ~10-20 hours of effort.

### 4. same_order_type Sorries (Lines 4692, 4792, 4845) - Category D

Blocked on h_d_unique (Claim 1). Cannot proceed until K-minus formula construction (Category C) is complete.

### 5. Lemma 9 + Rank Transport (Lines 5775, 6030) - Category E

Line 5775: Requires Lemma 9 (gap detection correctness), sorry'd in EFGames.lean.
Line 6030: Requires rank_embed transport for ghr93_duplicator_wins (not yet built).

## Artifacts

- **Handoff**: `specs/155_reynolds_pipeline_activation/handoffs/phase-3-handoff-20260523T210000.md`
- **This summary**: `specs/155_reynolds_pipeline_activation/summaries/28_expressivenessgeneral-sorries-summary.md`

## Plan Deviations

- The plan's Phase 3 tasks (3A-3E) were analyzed but not implemented due to discovered structural blockers.
- The degenerate gap sorries (2426, 2443) were identified as requiring a SplitPointProps refactor, which was not anticipated in the plan.
- The gap infimum sorries (2013, 2104) require more complex precondition derivation than the plan's "mechanical wiring" description suggested.
- All K-minus dependent sorries (h_d_unique, Claim 1 sub-cases, boundary edge) share the same root blocker: no formula materialization infrastructure.

## Recommended Priority

1. **SplitPointProps refactor** (Category A): closes 2 sorries, ~3-5 hours
2. **Gap infimum wiring** (Category B): closes 2 sorries, ~4-8 hours
3. **K-minus formula construction** (Category C): closes 5 sorries, ~10-20 hours
4. **Lemma 9** (Category E): closes 1 sorry in this file, requires EFGames.lean work
5. **Rank transport** (Category E): closes 1 sorry, requires new infrastructure
