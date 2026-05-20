# Task 130: Archive vs Delete Classification

**Date**: 2026-05-20
**Session**: sess_1779292958_9c8d94
**Status**: Research complete
**Prior Report**: [01_sorry-inventory.md](01_sorry-inventory.md)

## Summary

This report classifies each sorry cluster and dead-code file as ARCHIVE (move to Boneyard/) or DELETE (remove entirely), and proposes a concrete Boneyard subdirectory layout with tombstone comment templates.

Of the 19 actionable items from the prior inventory:
- **10 sorries across 5 files** --> ARCHIVE (whole files or surgical extracts)
- **5 sorries across 2 files** --> DELETE (stub-only, trivially reconstructible)
- **4 sorries in 1 file** --> ANNOTATE (dead approach inside active definitions)

## File-Level Dependency Analysis

Before classifying, the import dependency graph determines what can be moved as whole files vs what requires surgical extraction.

### Import Graph (non-Boneyard consumers only)

| File | Imported By | Can Move Whole File? |
|------|-------------|---------------------|
| `Quasimodel/Realization.lean` | BXCanonical.lean (aggregator), LocusControl.lean | NO -- LocusControl uses `until_eventuality_resolution`, `since_eventuality_resolution` (sorry-free) |
| `Quasimodel/Construction.lean` | BXCanonical.lean, Realization.lean, CanonicalChain.lean, DefectChain.lean | NO -- many proved theorems used downstream |
| `BXCanonical/TruthLemma.lean` | BXCanonical.lean, CanonicalModel.lean | NO -- `bot_not_in_mcs`, `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs` are actively used |
| `RootScopedChain.lean` | Completeness.lean ONLY | YES -- Completeness.lean docstring says these are "no longer on the critical path" |
| `Filtration/SigmaOrdering.lean` | DefectChain.lean ONLY | CONDITIONAL -- DefectChain uses SigmaOrdering import but does NOT reference any sigma_le/sigma_strict/sigma_equiv definitions (verified via grep) |

### Key Findings

1. **RootScopedChain.lean** is the only file that can be archived as a whole. Its sole consumer (Completeness.lean) explicitly documents that the 3 sorry sites are dead code bypassed by Chronicle.

2. **SigmaOrdering.lean + DefectChain.lean** form a two-file cluster where SigmaOrdering provides definitions to DefectChain. However, DefectChain does NOT actually use any SigmaOrdering-specific definitions (sigma_le, sigma_strict, sigma_equiv). It only uses the import chain to access Frame.lean and Construction.lean. Both files could be archived together as a pair if DefectChain's useful definitions are moved elsewhere.

3. **Realization.lean, Construction.lean, TruthLemma.lean** contain a mix of live proved theorems and dead sorry-bearing theorems. Only surgical extraction of the sorry-bearing definitions is possible.

## Classification: Per-Item Decisions

### ARCHIVE -- Move to Boneyard/ (significant code, educational value)

#### A1. RootScopedChain.lean (whole file, 222 lines, 3 sorries)

**File**: `Metalogic/BXCanonical/RootScopedChain.lean`
**Sorries**: `bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`, `bx_bfmcs_restricted_fuc`
**Verdict**: ARCHIVE (whole file)
**Rationale**: 222 lines of substantial infrastructure (BFMCS construction, F/P-obligation monotonicity proofs, countermodel wiring). The `fwd_chain_F_not_return` and `bwd_chain_P_not_return` theorems are fully proved and document an important negative result about Lindenbaum step F-obligation preservation. Educational value as documentation of why schedule-based chains fail at F/P resolution.
**Action**:
1. Move entire file to `Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean`
2. Remove `import Bimodal.Metalogic.BXCanonical.RootScopedChain` from Completeness.lean
3. Add tombstone comment in Completeness.lean

#### A2. SigmaOrdering.lean (whole file, 167 lines, 3 sorries)

**File**: `Metalogic/BXCanonical/Filtration/SigmaOrdering.lean`
**Sorries**: `sigma_le_refl`, `sigma_strict_irrefl`, `not_sigma_equiv_of_sigma_strict`
**Verdict**: ARCHIVE (whole file)
**Rationale**: The sigma-restricted ordering was designed for a filtration-based approach that was superseded by the Chronicle construction. All 3 sorries stem from BX1 removal under irreflexive semantics (documented in the file). The proved theorems (`bx_le_implies_sigma_le`, `sigma_le_of_bx_le_left`, `not_sigma_le_of_sigma_strict`, etc.) show the infrastructure was partially working. DefectChain.lean imports this file but does NOT reference any of its definitions.
**Action**:
1. Move entire file to `Boneyard/FiltrationOrdering/SigmaOrdering.lean`
2. Update DefectChain.lean to import Frame.lean directly (removing SigmaOrdering import)
3. Verify DefectChain.lean still compiles

#### A3. DefectChain.lean (whole file, 118 lines, 0 sorries -- but dead-end infrastructure)

**File**: `Metalogic/BXCanonical/Filtration/DefectChain.lean`
**Sorries**: 0 (all definitions proved)
**Verdict**: ARCHIVE (whole file, optional -- may keep since sorry-free)
**Rationale**: DefectChain is sorry-free but exists solely to serve the filtration/sigma-ordering pipeline that was superseded. Its definitions (`sigma_defect_count`, `defect_step_F_psi`, etc.) duplicate similar infrastructure in `Quasimodel/Construction.lean`. However, since it is sorry-free, keeping it is harmless. The CanonicalChain.lean import of DefectChain means removing it requires updating CanonicalChain.
**Action**: Archive together with SigmaOrdering to keep the Filtration/ cluster self-contained, OR leave in place (low priority). If archiving, update CanonicalChain.lean import.

#### A4. Realization.lean sorry extractions (4 sorries in surgical extraction)

**File**: `Metalogic/BXCanonical/Quasimodel/Realization.lean` (621 lines total)
**Sorries**: `F_of_mem` (line 66), `P_of_mem` (line 72), `enriched_seed_consistent_until` internal sorry (line 196), `enriched_seed_consistent_since` internal sorry (line 248)
**Verdict**: ARCHIVE (extract sorry-bearing definitions only; leave proved code in place)
**Rationale**: The file is 621 lines with 4 sorries. However, the file also contains ~400 lines of fully proved, actively used code: `bigconj_intro`, `bigconj_mem_iff`, `chain_step_seed_consistent_enriched`, `SubformulaClosure_G_closed`, `SubformulaClosure_H_closed`, etc. The sorry-bearing theorems (`F_of_mem`, `P_of_mem`) and the sorry-containing proofs within `enriched_seed_consistent_until/since` are NOT referenced by any active downstream code. They relate to the BX1-based approach that was abandoned when irreflexive semantics removed BX1 (`G(phi) -> phi`).
**Action**:
1. Extract `F_of_mem`, `P_of_mem` definitions + the sorry-bearing branch of `enriched_seed_consistent_until/since` to `Boneyard/BX1DependentCode/RealizationSorries.lean`
2. Replace in-file with tombstone comments
3. The proved code remains in place

### DELETE -- Remove entirely (stubs, trivially reconstructible)

#### D1. Construction.lean: `refl_intro_until_mcs` and `refl_intro_since_mcs` (2 sorries)

**File**: `Metalogic/BXCanonical/Quasimodel/Construction.lean` (lines 147-186)
**Sorries**: `refl_intro_until_mcs` (line 150), `refl_intro_since_mcs` (line 186)
**Verdict**: DELETE
**Rationale**: Each is a 3-line stub (signature + doc comment + `sorry`). The comments explicitly document: "Under irreflexive semantics, refl_intro_until/since is removed. Sorry'd (non-critical path)." No downstream code references either theorem (verified via grep). They are trivially reconstructible from the signature if ever needed. Zero educational value.
**Action**: Delete the two theorem stubs and their doc comments. No tombstone needed -- the irreflexive semantics note in the section header already explains why these are absent.

#### D2. TruthLemma.lean: `until_backward_refl_mcs` and `since_backward_refl_mcs` (2 sorries)

**File**: `Metalogic/BXCanonical/TruthLemma.lean` (lines 292-320)
**Sorries**: `until_backward_refl_mcs` (line 295), `since_backward_refl_mcs` (line 320)
**Verdict**: DELETE
**Rationale**: Each is a 4-line stub (signature + doc comment + `sorry`). Comments explicitly say: "Under irreflexive semantics, ... is NOT axiomatically valid (no reflexive witness). This lemma is sorry'd pending redesign." No downstream code references either theorem. Trivially reconstructible from signature. The file module header already documents the backward direction removal.
**Action**: Delete the two theorem stubs and their doc comments.

#### D3. ChronicleToCountermodel.lean: `dd_countermodel_chronicle_nondense_sorry` (1 sorry)

**File**: `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (line 831-839)
**Sorries**: `dd_countermodel_chronicle_nondense_sorry` (line 839)
**Verdict**: DELETE
**Rationale**: Pure sorry stub (9 lines: signature + doc comment + `sorry`). The doc comment describes what it should do but the body is `sorry`. The non-dense case is now handled by `WeakCanonical.countermodel_discrete` in Completeness.lean (via the Reynolds pipeline). No downstream code calls this stub.
**Action**: Delete the theorem stub. The nearby doc comment about the discrete case pipeline (lines 841+) is active documentation that should remain.

### ANNOTATE -- Leave in place with dead-approach markers (4 sorries)

#### N1. ChronicleToCountermodel.lean convergence section (4 sorries)

**File**: `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
**Sorries**:
- `succ_reaches_dom_N` boundary case above max(dom(N)) (line 1301)
- `succ_reaches_dom_N` boundary case below min(dom(N)) (line 1454)
- `limit_dom_points_are_succ_iterates` (line 1518)
- `succ_cofinal` gap elimination (line 1892)

**Verdict**: ANNOTATE (not move)
**Rationale**: These sorries are inside definitions that are structurally referenced by downstream code (`limitDomSubtype_isSuccArchimedean` at line 1900, used at lines 2813, 2846, 2850). The APPROACH (convergence + gap analysis) is dead, but the DEFINITIONS are active. Moving them to Boneyard would break the file's compilation. The prior report's option (b) -- annotate rather than move -- is correct.
**Action**: Add `-- DEAD APPROACH` annotations to each sorry site referencing task 129/Reynolds as resolution path. The existing ~200-line gap analysis comment block (lines 1830-1892) already documents why the approach failed.

## Proposed Boneyard Subdirectory Organization

### New Subdirectory: `Boneyard/ScheduleBasedBFMCS/`

**Contents**:
- `RootScopedChain.lean` (from `BXCanonical/RootScopedChain.lean`)
- `README.md`

**README Content**:
```
# ScheduleBasedBFMCS -- Archived Dead Code

Archived: Task 130 (2026-05-20)
Source: BXCanonical/RootScopedChain.lean

## Why Archived

Schedule-based BFMCS construction using `shifted_bx_fmcs` from CanonicalModel.lean.
3 sorries in restricted temporal/until/since coherence. The Lindenbaum-based
chain step cannot preserve F-obligations across steps: F(phi) may be permanently
lost without phi ever appearing.

Superseded by Burgess 1982 chronicle construction (Chronicle/) which builds
the FMCS directly via point insertion, avoiding the F-obligation loss problem.

## Sorry Summary

| Definition | Sorry Reason |
|-----------|-------------|
| bx_bfmcs_restricted_tc | F/P-resolution: Lindenbaum step loses F-obligations |
| bx_bfmcs_restricted_buc | Until coherence: same root cause |
| bx_bfmcs_restricted_fuc | Since coherence: same root cause |

## Proved Content (may have reuse value)

- bx_bfmcs: BFMCS construction (proved, no sorry)
- fwd_chain_F_not_return: F-obligation monotonicity (proved)
- bwd_chain_P_not_return: P-obligation monotonicity (proved)
- dd_countermodel: Countermodel wiring (carries sorry from upstream)

## Task Cross-References

- Task 107: Defect-directed chain archived to Boneyard/DefectDirectedChain/
- Task 130: This archival (schedule-based pipeline)
- Completeness.lean: Routes through Chronicle/ instead
```

### New Subdirectory: `Boneyard/FiltrationOrdering/`

**Contents**:
- `SigmaOrdering.lean` (from `BXCanonical/Filtration/SigmaOrdering.lean`)
- `DefectChain.lean` (from `BXCanonical/Filtration/DefectChain.lean`, optional)
- `README.md`

**README Content**:
```
# FiltrationOrdering -- Archived Dead Code

Archived: Task 130 (2026-05-20)
Source: BXCanonical/Filtration/SigmaOrdering.lean, DefectChain.lean

## Why Archived

Sigma-restricted ordering on BXPoints for filtration-based completeness.
3 sorries in SigmaOrdering stem from BX1 removal under irreflexive semantics:
sigma_le reflexivity, sigma_strict irreflexivity, and sigma_equiv exclusion
all require G(phi)->phi which is not valid in strict temporal semantics.

Superseded by Chronicle construction which avoids filtration entirely.

## Sorry Summary

| Definition | Sorry Reason |
|-----------|-------------|
| sigma_le_refl | BX1 (G(phi)->phi) removed |
| sigma_strict_irrefl | BX1 removed |
| not_sigma_equiv_of_sigma_strict | BX1 removed |

## Task Cross-References

- Task 101: Original design of sigma ordering
- Task 113: BX1 removal (open guard refactor)
- Task 130: This archival
```

### New Subdirectory: `Boneyard/BX1DependentCode/`

**Contents**:
- `RealizationSorries.lean` (extracted from `Quasimodel/Realization.lean`)
- `README.md`

**README Content**:
```
# BX1DependentCode -- Archived Dead Code

Archived: Task 130 (2026-05-20)
Source: Extracted from BXCanonical/Quasimodel/Realization.lean

## Why Archived

Helper theorems that require BX1 (G(phi)->phi), which was removed when the
project moved to irreflexive (strict) temporal semantics under task 113.

F_of_mem and P_of_mem prove F(psi) in w / P(psi) in w from psi in w,
which requires G(neg psi) not in w, which in turn requires BX1 to push
G-content into the current world. Without BX1, this reasoning breaks.

The enriched seed consistency sorries (inside enriched_seed_consistent_until
and enriched_seed_consistent_since) similarly depend on g_content(w) subset
w.formulas, which requires BX1.

## Sorry Summary

| Definition | Sorry Reason |
|-----------|-------------|
| F_of_mem | BX1 (G(phi)->phi) removed |
| P_of_mem | BX1 (H(phi)->phi) removed |
| enriched_seed_consistent_until (inner) | g_content subset via BX1 |
| enriched_seed_consistent_since (inner) | h_content subset via BX1 |

## Task Cross-References

- Task 113: BX1/BX1' removal (open guard refactor)
- Task 130: This archival
```

## Tombstone Comment Templates

### For removed imports (Completeness.lean)

```lean
-- Archived to Boneyard/ScheduleBasedBFMCS/ (task 130): schedule-based BFMCS
-- construction. 3 sorry sites (restricted_tc/buc/fuc) bypassed by Chronicle
-- approach. See Boneyard/ScheduleBasedBFMCS/README.md.
```

### For deleted stubs (Construction.lean, TruthLemma.lean)

No tombstone needed -- the existing section-level documentation already explains the irreflexive semantics redesign. Adding a tombstone for a deleted 3-line stub would be noise.

### For annotated sorries (ChronicleToCountermodel.lean)

```lean
-- DEAD APPROACH: convergence/stage-induction method for succ_reaches_dom_N.
-- Resolution: task 129 (Henkin model) or Reynolds pipeline (tasks 154-155).
-- See Boneyard/StageInductionGapAnalysis/ for related archived analysis.
```

### For surgical extractions (Realization.lean)

```lean
-- F_of_mem, P_of_mem: archived to Boneyard/BX1DependentCode/ (task 130).
-- These required BX1 (G(phi)->phi), removed under irreflexive semantics (task 113).
```

## Implementation Action Summary

| # | Action | File | What | Sorries Removed |
|---|--------|------|------|-----------------|
| 1 | ARCHIVE whole file | RootScopedChain.lean | Move to Boneyard/ScheduleBasedBFMCS/ | 3 |
| 2 | ARCHIVE whole file | SigmaOrdering.lean | Move to Boneyard/FiltrationOrdering/ | 3 |
| 3 | ARCHIVE whole file (optional) | DefectChain.lean | Move to Boneyard/FiltrationOrdering/ | 0 |
| 4 | ARCHIVE extract | Realization.lean | Extract F_of_mem, P_of_mem, enriched inner sorries | 4 |
| 5 | DELETE stub | Construction.lean | Remove refl_intro_until/since_mcs | 2 |
| 6 | DELETE stub | TruthLemma.lean | Remove until/since_backward_refl_mcs | 2 |
| 7 | DELETE stub | ChronicleToCountermodel.lean | Remove dd_countermodel_chronicle_nondense_sorry | 1 |
| 8 | ANNOTATE | ChronicleToCountermodel.lean | Add dead-approach markers to 4 convergence sorries | 0 (remain) |
| 9 | UPDATE | Completeness.lean | Remove RootScopedChain import, add tombstone | -- |
| 10 | UPDATE | DefectChain.lean or CanonicalChain.lean | Fix imports after SigmaOrdering move | -- |
| 11 | CREATE | Boneyard/ScheduleBasedBFMCS/README.md | Boneyard README | -- |
| 12 | CREATE | Boneyard/FiltrationOrdering/README.md | Boneyard README | -- |
| 13 | CREATE | Boneyard/BX1DependentCode/README.md | Boneyard README | -- |
| 14 | UPDATE | Boneyard/README.md | Add 3 new rows to inventory table | -- |

**Net effect**: 15 sorries removed from active codebase (10 archived + 5 deleted), 4 annotated.

## Risk Assessment

### Low Risk
- Actions 1, 5, 6, 7: Clean operations on isolated dead code with zero downstream references.
- Actions 8, 11-14: Documentation-only changes.

### Medium Risk
- Action 2 (SigmaOrdering archive): Requires verifying DefectChain compiles without SigmaOrdering import. Grep confirms no SigmaOrdering-specific references in DefectChain, but Lean's import resolution may pull transitive dependencies.
- Action 9 (Completeness.lean import removal): RootScopedChain.lean transitively brings in CanonicalModel.lean and Bundle.UntilSinceCoherence. Completeness.lean may depend on definitions from these transitive imports. Verify with `lake build` after removal.
- Action 10 (import fix): CanonicalChain.lean imports DefectChain. If DefectChain moves, CanonicalChain needs a direct import of Construction.lean (which it may already have transitively).

### Mitigation
All medium-risk actions should be followed by `lake build` to verify compilation. If transitive import issues arise, add explicit imports for the transitively-needed modules.

## Build Verification Plan

Execute in this order:
1. Delete stubs (D1, D2, D3) --> `lake build`
2. Archive RootScopedChain (A1) --> update Completeness.lean imports --> `lake build`
3. Archive SigmaOrdering (A2) --> update DefectChain imports --> `lake build`
4. Extract Realization sorries (A4) --> `lake build`
5. Add annotations (N1)
6. Create Boneyard READMEs and update inventory
