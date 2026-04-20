# Research Report: Task #106

**Task**: 106 - Rewrite ROADMAP for irreflexive semantics
**Started**: 2026-04-20T00:00:00Z
**Completed**: 2026-04-20T00:30:00Z
**Effort**: Medium
**Dependencies**: None (documentation task)
**Sources/Inputs**:
- `specs/ROADMAP.md` (current version, last updated 2026-04-19)
- `Theories/Bimodal/ProofSystem/Axioms.lean` (actual axiom definitions)
- `Theories/Bimodal/Metalogic/BXCanonical/` (all source files, sorry audit)
- Task 93 summary (artifact 51)
**Artifacts**:
- `specs/106_rewrite_roadmap_irreflexive/reports/01_roadmap-rewrite-audit.md`
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- The ROADMAP overview (lines 5, 11) still describes the semantics as "reflexive" and "fully reflexive" despite the irreflexive switch completed in task 93.
- The sorry inventory is severely undercounted: ROADMAP claims 5 sorries on active path (all in RootScopedChain.lean), but the actual count in non-Boneyard BXCanonical files is 32 sorries across 8 files. Multiple files claimed "sorry-free" have sorries.
- The axiom count is inconsistent (line 8 says 37, axiom table section says 35, actual Lean code has 33 constructors).
- BX8/BX8' are correctly documented as removed but axiom table still lists them at lines 89-90.
- BX2/BX2' reformulation (added current-time conjunct for half-open guard) is reflected in the axiom table but the description text is inconsistent.
- The X/Y Operator Status section (lines 163-192) is entirely stale, describing reflexive semantics behavior.
- The module import graph line counts and sorry-free claims are outdated.

## Context & Scope

Task 106 requires rewriting ROADMAP.md to reflect the irreflexive semantics completed in task 93. This report catalogs every section requiring changes and documents the correct state for each.

## Findings

### 1. Overview Section (Lines 1-38): "Reflexive" Language

**Lines requiring change**:
- Line 5: `"reflexive linear temporal logic"` -- should be `"irreflexive linear temporal logic"`
- Line 11: `"**fully reflexive**: G/H quantify over t <= s / s <= t"` -- WRONG. Must say `"**irreflexive**: G/H quantify over t < s / s < t, and Until/Since require strict witnesses"`
- Line 8: `"37 BX axioms"` -- should be `"33 BX axioms"` (was 35 before BX8/BX8' removal)
- Line 37: `"reflexive semantics, canonical"` -- should be `"irreflexive semantics, canonical"`

### 2. Axiom System Section (Lines 40-124): Count and Table Errors

**Axiom count**: Line 40 says `"35 axiom constructors"`. Actual count is **33** (4 prop + 5 modal + 22 temporal + 2 interaction). BX8/BX8' were removed, dropping from 35 to 33. The Axioms.lean header comment also says 35 (stale).

**Axiom table at lines 89-90**: BX8 and BX8' are still listed in the table:
```
| BX8 `until_step` | Axioms.lean:205 | `phi AND F(phi U psi) -> (phi U psi)` | Step introduction |
| BX8' `since_step` | Axioms.lean:210 | `phi AND P(phi S psi) -> (phi S psi)` | Mirror |
```
These must be removed from the table. The Lean file has a comment `-- NOTE: BX8/BX8' (until_step/since_step) removed` at line 202.

**BX2 reformulation**: The table at line 77 shows `G(phi->chi) -> ((phi U psi) -> (chi U psi))` but actual Lean code is `(phi->chi) AND G(phi->chi) -> ((phi U psi) -> (chi U psi))`. The conjunct `(phi->chi)` at current time was added for the half-open guard `[t,s)`. The table entry is CORRECT (it shows the new form), but the ROADMAP description text at line 109 says the old form. The table line numbers in column 2 are also stale (e.g., `Axioms.lean:205` for BX8 which no longer exists).

**Line numbers**: Many `Axioms.lean:NNN` references are stale. Current correct line numbers from the Lean source need updating across the entire axiom table.

### 3. Irreflexive Semantics Section (Lines 107-124): Mostly Correct but Stale BX8 Reference

Line 116: `"BX8 is now the step axiom phi AND F(phi U psi) -> (phi U psi) instead of reflexive intro"` -- this is WRONG. BX8 was **removed entirely**, not replaced with a step axiom. The comment at Axioms.lean:202 confirms removal.

### 4. X/Y Operator Status Section (Lines 163-192): Entirely Stale

This section analyzes X/Y behavior under reflexive semantics and concludes `next phi equiv phi`. Under irreflexive semantics:
- `bot U phi` at `t` requires `exists s > t, phi(s) AND forall r, t < r < s -> False`
- In discrete orders, this gives `phi` at the immediate successor (genuine next-step)
- In dense orders, the empty interval condition forces `s` to be immediate, which may be vacuous
- The conclusion that `"X/Y are definitional dead code"` needs reassessment
- The unfolding calculation at lines 180-184 uses reflexive `t <= s` which is wrong

### 5. Active-Path Sorry Inventory (Lines 452-511): Severely Undercounted

**ROADMAP claims**: 5 sorries, all in RootScopedChain.lean.

**Actual sorry counts in non-Boneyard BXCanonical files**:

| File | ROADMAP Claim | Actual Sorries |
|------|---------------|----------------|
| Frame.lean | 1 (bx_le_refl, noted) | **1** (correct) |
| TruthLemma.lean | sorry-free | **2** (until_backward_refl_mcs, since_backward_refl_mcs) |
| Completeness.lean | sorry-free | **0** (correct) |
| CanonicalChain.lean | sorry-free | **0** (correct) |
| OrderedSeedConsistency.lean | sorry-free | **0** (correct) |
| CanonicalModel.lean | sorry-free | **6** (enriched_seed_consistent, fwd_succ_f_carry, enriched_past_seed_consistent, bwd_pred_p_carry, g_content_subset_self, h_content_subset_self) |
| RootScopedChain.lean | 5 sorries | **5** (correct) |
| Quasimodel/Construction.lean | sorry-free (implied) | **2** |
| Quasimodel/Realization.lean | sorry-free (implied) | **4** |
| Quasimodel/OracleStep.lean | (not on active path) | **9** |
| Filtration/SigmaOrdering.lean | (not mentioned) | **3** |
| Filtration/DefectChain.lean | (not mentioned) | **0** |

**Active-path sorry total**: At minimum **14 sorries** in non-Boneyard, non-OracleStep files that the ROADMAP claims are on the active path (Frame 1, TruthLemma 2, CanonicalModel 6, RootScopedChain 5). If including Quasimodel infrastructure: **23**. With OracleStep: **32**.

**Key distinction**: Many of these sorries are consequences of the irreflexive semantics switch:
- `g_content_subset_self` / `h_content_subset_self`: unprovable without BX1/BX1'
- `until_backward_refl_mcs` / `since_backward_refl_mcs`: `psi -> (phi U psi)` not valid
- `enriched_seed_consistent` / `enriched_past_seed_consistent`: f_carry/p_carry enrichment blocked
- `fwd_succ_f_carry` / `bwd_pred_p_carry`: carry properties no longer hold

Some of these may be dead code (not actually on the critical path to `bx_completeness`), but the ROADMAP's claim that these files are "sorry-free" is factually incorrect.

### 6. Module Import Graph (Lines 203-276): Stale Line Counts and Sorry Claims

Current actual state vs ROADMAP claims:

| File | ROADMAP Lines | Actual Lines | ROADMAP Sorries | Actual Sorries |
|------|---------------|--------------|-----------------|----------------|
| Frame.lean | 673 | 726 | sorry-free | 1 |
| TruthLemma.lean | 320 | 318 | sorry-free | 2 |
| Completeness.lean | 152 | 152 | sorry-free | 0 |
| CanonicalChain.lean | 157 | 160 | sorry-free | 0 |
| OrderedSeedConsistency.lean | 255 | 255 | sorry-free | 0 |
| CanonicalModel.lean | 498 | 474 | sorry-free | 6 |
| RootScopedChain.lean | 1,681 | 1,487 | 5 sorries | 5 |
| HintikkaPoint.lean | 166 | 144 | (implied sorry-free) | 0 |
| Construction.lean | 887 | 885 | (implied sorry-free) | 2 |
| Realization.lean | 444 | 576 | (implied sorry-free) | 4 |
| SigmaOrdering.lean | 179 | 167 | (not mentioned) | 3 |

The total BXCanonical line count claim of 5,791 is stale.

### 7. Sorry Inventory Table (Lines 457-463): Stale Line Numbers

The line numbers for the 5 RootScopedChain.lean sorries are wrong:
- ROADMAP says `~1093, ~1120, ~1127, ~1135, ~1142`
- Actual locations: `1065, 1092, 1099, 1107, 1114`

The definition names are also partially wrong:
- ROADMAP row 1 says `dd_bfmcs_restricted_fuc` but actual row 1 is `fwd_chain_forward_F`
- ROADMAP row 5 duplicates `dd_bfmcs_restricted_fuc` (listed twice)

Correct sorry table for RootScopedChain.lean:

| # | File:Line | Definition | Goal Summary |
|---|-----------|------------|--------------|
| 1 | RootScopedChain.lean:1065 | `fwd_chain_forward_F` | F-resolution for chain |
| 2 | RootScopedChain.lean:1092 | `dd_bfmcs_restricted_tc` (fwd, backward chain) | Forward TC, backward chain case |
| 3 | RootScopedChain.lean:1099 | `dd_bfmcs_restricted_tc` (backward P) | Backward temporal coherence |
| 4 | RootScopedChain.lean:1107 | `dd_bfmcs_restricted_buc` | Backward Until/Since coherence |
| 5 | RootScopedChain.lean:1114 | `dd_bfmcs_restricted_fuc` | Forward Until/Since coherence |

### 8. Overview Sorry Summary (Lines 16-33): Stale Counts and Line Numbers

- Line 17: `"5 sorries"` -- only counts RootScopedChain. Should document broader sorry landscape.
- Line 18: `"RootScopedChain.lean:1111"` -- wrong line number (should be ~1065)
- Lines 27-30: Individual sorry line numbers all wrong
- Line 275: `"5,791 lines across 16 files, 5 sorries"` -- lines and sorries both wrong

### 9. Canonical Model Construction Section (Lines 283-357): Partially Stale

- Line 304: Correctly notes bx_le_refl is NOT valid. Good.
- Line 306: References `g_content_set_consistent (Frame.lean:122-133)` using BX1 -- but the ROADMAP's own irreflexive section says this uses seriality now. The Frame.lean line numbers may also be stale.
- Lines 337-357: `bx_completeness` section references `sorry at Completeness.lean:154` which was resolved. The text at line 353 says this is the sorry, but Completeness.lean is now sorry-free (the sorry moved to RootScopedChain.lean).

### 10. Quasimodel/Filtration Section (Lines 362-441): Stale Line Counts

Line counts need updating per findings in section 6 above. The "all sorry-free" claim for the Quasimodel infrastructure (line 362: "2,289 lines, all sorry-free") is incorrect -- Construction.lean has 2 sorries, Realization.lean has 4 sorries, and SigmaOrdering.lean has 3 sorries.

### 11. Legacy Code Section (Lines 514-550): Partially Stale

Line 518: `"reverted to the all-reflexive BX system"` -- backwards. The system was reverted FROM reflexive TO irreflexive. This sentence should say the legacy files were written under a different architecture.

Line 533: References task 94 as future ("will archive") but task 94 is marked COMPLETED in the cross-reference table (line 1098).

### 12. Burgess-Xu Section (Lines 554-621): Minor Issues

- Line 576: `"all reflexive linear orderings"` -- Burgess/Xu completeness is indeed for reflexive orderings, so this is historically correct, but the ROADMAP should clarify that the BX system in this project uses irreflexive semantics (a departure from the original).
- Line 598-599: BX9 role says "handles the s = t (current-time) case under reflexive semantics" -- under irreflexive semantics, BX9's role is different (the guard covers t, so phi(t) follows from the guard, not from s = t).

### 13. Dead Ends Section (Lines 624-984): Largely Preserved

Most dead ends are correctly preserved. A few references to "reflexive semantics" in dead ends #28 and #36(b) line 884 are contextually correct (describing what was tried under reflexive semantics).

### 14. Task Cross-Reference Table (Lines 1086-1103): Needs Update

- Task 93 status: `[IMPLEMENTING]` -- should be updated if completed
- Task 106 itself should be added
- Task 109 (chain construction sorries) should be added per recent commit `3ba7baa12`

### 15. BX9 Docstring (Axioms.lean Lines 204-208): Guard Convention

Under irreflexive Until with A2 guard `[t,s)`, `phi U psi` at `t` has strict witness `s > t`, guard phi on `[t,s)`. Since `t` is in `[t,s)`, `phi(t)` holds, giving `phi OR psi`. This is correct and the axiom table captures it accurately. The docstring in Axioms.lean correctly explains this.

## Decisions

1. The sorry inventory must be restructured to distinguish between:
   - **Critical path sorries**: The 5 in RootScopedChain.lean that directly block `bx_completeness`
   - **Irreflexive-consequence sorries**: Lemmas that became unprovable due to the semantics switch (g_content_subset_self, until_backward_refl_mcs, etc.)
   - **Infrastructure sorries**: Quasimodel/OracleStep sorries that are on deprecated sub-paths

2. The axiom count should be corrected to 33 throughout.

3. BX8/BX8' entries must be removed from the axiom table, not just annotated.

4. The X/Y section needs complete rewrite or removal (semantics changed fundamentally).

## Recommendations

### Required Changes (Ordered by Section)

1. **Overview (lines 1-38)**: Replace "reflexive" with "irreflexive", fix axiom count to 33, update sorry summary to reflect broader landscape.

2. **Axiom System (lines 40-124)**: Fix count to 33. Remove BX8/BX8' from table. Fix BX2 description consistency. Update all `Axioms.lean:NNN` line numbers. Fix line 116 (BX8 was removed, not changed to step axiom).

3. **X/Y Operator Status (lines 163-192)**: Complete rewrite. Under irreflexive semantics, `bot U phi` genuinely represents a next-step operator (in discrete orders). Remove stale reflexive unfolding.

4. **Module Import Graph (lines 203-276)**: Update all line counts. Fix sorry-free claims for TruthLemma.lean, CanonicalModel.lean, Construction.lean, Realization.lean, SigmaOrdering.lean.

5. **Canonical Model Construction (lines 283-357)**: Update Frame.lean line references. Fix g_content_set_consistent description (uses seriality, not BX1). Fix Completeness.lean sorry description (no longer at line 154).

6. **Quasimodel/Filtration (lines 362-441)**: Update line counts. Remove "all sorry-free" claim.

7. **Sorry Inventory (lines 452-511)**: Restructure into critical-path vs consequence sorries. Fix all line numbers for RootScopedChain.lean. Fix the duplicate dd_bfmcs_restricted_fuc entry.

8. **Legacy Code (lines 514-550)**: Fix "reverted to all-reflexive" language. Update task 94 status.

9. **Task Cross-Reference (lines 1086-1103)**: Update task 93 status. Add task 106, 109.

10. **Last Updated line**: Update date and description.

## Risks & Mitigations

- **Risk**: Incorrect sorry classification could mislead future development. Many "irreflexive-consequence" sorries may actually be dead code not on the critical path.
  - **Mitigation**: The implementation should trace the actual dependency chain from `bx_completeness` to identify which sorries are truly blocking vs dead code.

- **Risk**: The axiom line numbers will drift again as the code evolves.
  - **Mitigation**: Consider using definition names instead of line numbers, or accept that line numbers are approximate.

## Appendix

### Files Examined

- `specs/ROADMAP.md` (1107 lines)
- `Theories/Bimodal/ProofSystem/Axioms.lean` (300 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/*.lean` (all files)
- `specs/093_complete_bxcanonical_embedding/summaries/51_bxcanonical-embedding-summary.md`

### Grep Queries Used

- `sorry` in all BXCanonical `.lean` files (excluding Boneyard, comments)
- `reflexive|reflexiv` in ROADMAP.md (25 matches)
- Axiom constructor enumeration in Axioms.lean

### Actual BXCanonical Sorry Summary (Non-Boneyard)

| File | Sorry Count | Definitions |
|------|-------------|-------------|
| Frame.lean | 1 | bx_le_refl |
| TruthLemma.lean | 2 | until_backward_refl_mcs, since_backward_refl_mcs |
| CanonicalModel.lean | 6 | enriched_seed_consistent, fwd_succ_f_carry, enriched_past_seed_consistent, bwd_pred_p_carry, g_content_subset_self, h_content_subset_self |
| RootScopedChain.lean | 5 | fwd_chain_forward_F, dd_bfmcs_restricted_tc (x2), dd_bfmcs_restricted_buc, dd_bfmcs_restricted_fuc |
| Quasimodel/Construction.lean | 2 | (unchecked names) |
| Quasimodel/Realization.lean | 4 | (unchecked names) |
| Quasimodel/OracleStep.lean | 9 | (deprecated oracle path) |
| Filtration/SigmaOrdering.lean | 3 | (unchecked names) |
| **Total (non-Boneyard)** | **32** | |
