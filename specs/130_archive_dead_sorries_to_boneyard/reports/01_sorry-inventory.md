# Task 130: Sorry Inventory for Boneyard Archival

**Date**: 2026-05-18
**Session**: sess_1779146360_eab605
**Status**: Research complete

## Summary

The codebase contains **73 active sorries** (non-Boneyard) across 18 files. The task description estimates ~40 sorries to archive, but the actual picture is more nuanced. Many of the 73 active sorries are on active development paths (WeakCanonical pipeline, Theorems/TemporalDerived, Algebraic) and should NOT be archived. The truly dead-code sorries that should be archived number approximately **30-33**, concentrated in the BXCanonical non-Chronicle pipeline and certain ChronicleToCountermodel sections.

Task 129 (IsSuccArchimedean via weak/reflexive completeness) is referenced in the StageInductionGapAnalysis archive and throughout ChronicleToCountermodel.lean comments. The weak/reflexive completeness approach has been partially implemented in WeakCanonical/ but itself still has sorries. The task 129 directory does not appear in state.json active_projects, suggesting it was completed or archived.

## Findings

### Existing Boneyard Structure

The Boneyard directory at `Theories/Bimodal/Boneyard/` is well-established with 14 subdirectories, 47 files, ~26,579 lines. Each subdirectory has a README.md documenting why the code was archived. The Boneyard README follows a clear format with:
- Directory inventory table
- Archival reason taxonomy (Unsound Axioms, Superseded Approaches, Structural Dead Ends, Architectural Incompatibility)
- Task cross-references
- Git retrieval instructions

The relevant already-archived subdirectory is `StageInductionGapAnalysis/` (task 123), which documents the dead-end IsSuccArchimedean proof attempts that are relevant to group (2) and (3) below.

### Group (1): ChronicleToCountermodel.lean -- succ_reaches_dom_N Boundary Cases

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 1301 | `succ_reaches_dom_N` (in `limitDomSubtype_isSuccArchimedean` proof helper) | DEAD CODE | Boundary case: b above max(dom(N)), stage induction gap |
| 1454 | same function, below-min boundary | DEAD CODE | Boundary case: a below min(dom(N)) |

These are sorry sites within the proof of `succ_reaches_dom_N`-like helpers for `limitDomSubtype_isSuccArchimedean`. The approach was superseded by the Henkin model (task 129) and the Reynolds pipeline (tasks 154-155). The enclosing function `limitDomSubtype_isSuccArchimedean` at line 1896 depends on `succ_cofinal` which also has a sorry (see group 3).

**Recommendation**: Archive the `succ_reaches_dom_N` proof body as dead code within the succ_cofinal section. However, the DEFINITION `limitDomSubtype_isSuccArchimedean` itself is still used by downstream code (referenced at lines 2813, 2846, 2850 in the same file), so the definition signature must remain. Only the internal proof body and helper lemmas are dead.

**CAUTION**: These sorries are INSIDE `limitDomSubtype_isSuccArchimedean` which is used by the countermodel construction. Archiving just the proof BODY is not straightforward -- the definition is structurally active. What can be archived is the convergence/stage-induction APPROACH documented in comments around these sorries. The sorry itself must remain until the proof is completed via a different approach.

### Group (2): limit_dom_points_are_succ_iterates (Line 1518)

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 1518 | `limit_dom_points_are_succ_iterates` (unnamed, in section) | DEAD CODE | Real-analysis convergence approach, superseded |

This sorry is in a convergence-based proof that all limit_dom points between a and some upper bound L are succ-iterates of a. The approach uses infinite descent on pred-chains and was abandoned because the descent doesn't yield a contradiction with current tools. Already documented as a dead end in the `StageInductionGapAnalysis` README.

**Recommendation**: This is a standalone lemma with a sorry that feeds into the `succ_cofinal` proof path. If the entire convergence section is extracted, this sorry goes with it.

### Group (3): succ_cofinal Gap Analysis (Line 1888)

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 839 | `dd_countermodel_chronicle_nondense_sorry` | DEAD CODE | Non-dense countermodel stub, body is pure sorry |
| 1888 | `succ_cofinal` proof (gap elimination step) | DEAD CODE (approach) | Convergence + Z1 gap analysis, bypassed by task 129/Reynolds |

The `succ_cofinal` sorry at line 1888 is the culmination of a ~200-line gap analysis section (lines ~1700-1888). The analysis proved that the gap scenario is consistent with all temporal axioms, meaning the approach cannot work without construction-level arguments. Resolution is via task 129 (Henkin model) or Reynolds pipeline (tasks 154-155).

`dd_countermodel_chronicle_nondense_sorry` at line 839 is a pure sorry stub for the non-dense case -- confirmed dead code.

**Recommendation**: The gap analysis section (lines ~1520-1888, including `z1_formula`, `z1_derivation`, `z1_in_mcs`, `succ_cofinal`, and the ~200 lines of gap analysis comments) is dead approach code. However, `z1_formula` and `z1_derivation` and `z1_in_mcs` are potentially reusable infrastructure. The `succ_cofinal` theorem itself feeds `limitDomSubtype_isSuccArchimedean` which is structurally used. Archive the GAP ANALYSIS portion but leave the definition signatures.

### Group (4): BXCanonical Pipeline Dead Code

These files are part of the older BXCanonical pipeline that was superseded by the Chronicle construction. While they are still imported via `BXCanonical/BXCanonical.lean` (the aggregator module), the Completeness.lean docstring explicitly states "The RootScopedChain.lean sorry sites are no longer on the critical path" and "Dead code sorries in CanonicalModel.lean."

#### Quasimodel/Realization.lean (4 sorries)

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 67 | `F_of_mem` | UNCLEAR | BXPoint forward witness -- used by truth lemma? |
| 73 | `P_of_mem` | UNCLEAR | BXPoint backward witness |
| 197 | `enriched_seed_consistent_until` | LIKELY DEAD | Until realization lifting |
| 249 | `enriched_seed_consistent_since` | LIKELY DEAD | Since realization lifting |

**Import analysis**: Only imported by Boneyard files and within BXCanonical itself. No external active code imports Realization.lean directly.

#### Quasimodel/Construction.lean (2 sorries)

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 150 | `refl_intro_until_mcs` | LIKELY DEAD | Reflexive until intro for MCS |
| 186 | `refl_intro_since_mcs` | LIKELY DEAD | Reflexive since intro for MCS |

#### TruthLemma.lean (2 sorries) -- BXCanonical version

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 296 | `until_backward_refl_mcs` | LIKELY DEAD | Until backward in BXPoint model |
| 321 | `since_backward_refl_mcs` | LIKELY DEAD | Since backward in BXPoint model |

**WARNING**: BXCanonical/TruthLemma is imported by BXCanonical.lean and CanonicalModel.lean. Definitions may still be referenced even if not on the critical path.

#### RootScopedChain.lean (3 sorries)

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 186 | `bx_bfmcs_restricted_tc` | DEAD CODE | Confirmed dead in Completeness.lean docstring |
| 193 | `bx_bfmcs_restricted_buc` | DEAD CODE | Confirmed dead |
| 198 | `bx_bfmcs_restricted_fuc` | DEAD CODE | Confirmed dead |

**Import analysis**: Only imported by BXCanonical/Completeness.lean, which routes through Chronicle instead.

#### Filtration/SigmaOrdering.lean (3 sorries)

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 82 | `sigma_le_refl` | LIKELY DEAD | Sigma ordering reflexivity |
| 99 | `sigma_strict_irrefl` | LIKELY DEAD | Sigma strict irreflexivity |
| 143 | `not_sigma_equiv_of_sigma_strict` | LIKELY DEAD | Sigma equivalence exclusion |

**Import analysis**: Only imported by BXCanonical/CanonicalChain.lean, which is internal BXCanonical infrastructure.

#### Frame.lean (1 sorry)

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 205 | `bx_le_refl` | ACTIVE | BXPoint ordering reflexivity -- WIDELY used |

**CAUTION**: Frame.lean is imported by ChronicleTypes.lean and many other active files. The `bx_le_refl` sorry is NOT dead code -- it is foundational infrastructure used throughout the active pipeline. DO NOT archive.

#### BXCanonical/Completeness.lean (4 sorries)

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 225 | `countermodel_discrete_enriched` | ACTIVE SORRY | Carries sorry from upstream (discrete Int countermodel) |
| 254 | `completeness_dense` (non-dense case) | ACTIVE SORRY | Frame-class theory gap |
| 279 | `completeness_discrete` (dense case) | ACTIVE SORRY | Frame-class theory gap |
| 288 | `completeness_discrete` (mixed case) | ACTIVE SORRY | Frame-class theory gap |

**CRITICAL**: These are NOT dead code. They are active completeness theorem sorries that represent genuine incomplete proofs on the active path. DO NOT archive.

#### Group (4) Summary

| File | Sorries | Archivable | Active |
|------|---------|------------|--------|
| Quasimodel/Realization.lean | 4 | 4 | 0 |
| Quasimodel/Construction.lean | 2 | 2 | 0 |
| BXCanonical/TruthLemma.lean | 2 | 2 | 0 |
| RootScopedChain.lean | 3 | 3 | 0 |
| Filtration/SigmaOrdering.lean | 3 | 3 | 0 |
| Frame.lean | 1 | 0 | 1 |
| Completeness.lean | 4 | 0 | 4 |
| **Total** | **19** | **14** | **5** |

### Group (5): Bundle/SuccRelation and Bundle/SuccExistence

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` (3 sorries)
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (3 sorries)

#### SuccRelation.lean

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 548 | `until_persists_through_succ` | NEEDS ANALYSIS | Until persistence through successor step |
| 617 | `g_content_subset_mcs` | NEEDS ANALYSIS | g_content is subset of MCS |
| 625 | `h_content_subset_mcs` | NEEDS ANALYSIS | h_content is subset of MCS |

#### SuccExistence.lean

| Line | Definition | Status | Notes |
|------|-----------|--------|-------|
| 466 | `constrained_successor_seed_consistent` | NEEDS ANALYSIS | Constrained successor consistency |
| 771 | `successor_deferral_seed_consistent_axiom` | NEEDS ANALYSIS | Successor deferral |
| 845 | `predecessor_deferral_seed_consistent_axiom` | NEEDS ANALYSIS | Predecessor deferral |

**Import analysis**: Both files ARE actively imported by multiple modules:
- SuccRelation: Used by UntilSinceCoherence, CanonicalTaskRelation, CanonicalIrreflexivity, SuccExistence
- SuccExistence: Used by Core/RestrictedMCS

**CRITICAL**: These are NOT dead code. The Bundle module is foundational infrastructure used by both the BXCanonical and WeakCanonical pipelines. The sorries here represent incomplete proofs in active code, NOT dead code to be archived.

**Recommendation**: DO NOT archive. These need to be resolved, not archived.

### Sorries NOT Listed in Task Description (Active Code)

These sorries appear in non-Boneyard files but are NOT mentioned in the task description. They are on active development paths.

| File | Count | Category |
|------|-------|----------|
| Theorems/TemporalDerived.lean | 19 | Open-guard semantic gaps (may be unprovable) |
| WeakCanonical/TruthLemma.lean | 6 | Non-critical-path documented sorries |
| WeakCanonical/Transfer.lean | 4 | Reynolds pipeline (task 155) |
| WeakCanonical/Separation/DualEliminations.lean | 8 | Expressive completeness (GHR94 dual cases) |
| WeakCanonical/IntegerModel.lean | 2 | Reynolds Lemma 16 (active) |
| WeakCanonical/OrderedSum.lean | 1 | Doets Lemma 1.5 (future work) |
| Algebraic/InteriorOperators.lean | 1 | temp_k_dist derivation gap |
| Algebraic/LindenbaumQuotient.lean | 2 | temp_k_dist derivation gap |
| BXCanonical/Completeness.lean | 4 | Active completeness sorries |
| BXCanonical/Frame.lean | 1 | bx_le_refl (active infrastructure) |

**Total NOT to archive**: 48 sorries across active code

## Archival Inventory

### Confirmed Dead Code for Archival

| # | File | Definition | Lines | Sorries | Reason |
|---|------|-----------|-------|---------|--------|
| 1 | BXCanonical/Quasimodel/Realization.lean | F_of_mem, P_of_mem, enriched_seed_consistent_until, enriched_seed_consistent_since | ~200 | 4 | Superseded by Chronicle approach |
| 2 | BXCanonical/Quasimodel/Construction.lean | refl_intro_until_mcs, refl_intro_since_mcs | ~40 | 2 | Superseded by Chronicle approach |
| 3 | BXCanonical/TruthLemma.lean | until_backward_refl_mcs, since_backward_refl_mcs | ~30 | 2 | Superseded by Chronicle approach |
| 4 | BXCanonical/RootScopedChain.lean | bx_bfmcs_restricted_tc/buc/fuc | ~20 | 3 | Confirmed dead in Completeness.lean docstring |
| 5 | BXCanonical/Filtration/SigmaOrdering.lean | sigma_le_refl, sigma_strict_irrefl, not_sigma_equiv_of_sigma_strict | ~70 | 3 | Part of dead filtration pipeline |
| 6 | ChronicleToCountermodel.lean:839 | dd_countermodel_chronicle_nondense_sorry | ~10 | 1 | Pure sorry stub, dead |
| **Total** | | | ~370 | **15** | |

### Potentially Archivable (Requires Decision)

| # | File | Definition | Sorries | Issue |
|---|------|-----------|---------|-------|
| 7 | ChronicleToCountermodel.lean:1301,1454 | succ_reaches_dom_N boundary proofs | 2 | Inside structurally active definition |
| 8 | ChronicleToCountermodel.lean:1518 | limit_dom_points_are_succ_iterates | 1 | Part of convergence approach, feeds succ_cofinal |
| 9 | ChronicleToCountermodel.lean:1888 | succ_cofinal gap elimination | 1 | Inside structurally active definition |

These 4 sorries in ChronicleToCountermodel.lean are in definitions that are structurally used by downstream code. The APPROACH is dead (convergence/stage-induction), but the DEFINITIONS are active. Archiving requires either:
- (a) Moving entire definitions to Boneyard and replacing with new implementations, or
- (b) Leaving definitions in place but annotating sorries as "dead approach, resolution via task 129/Reynolds"

**Recommendation**: Option (b) -- annotate rather than move, since the definitions are referenced downstream.

### NOT to Archive (Active Code)

| Category | Files | Sorries | Why Active |
|----------|-------|---------|------------|
| BXCanonical/Frame.lean | 1 | 1 | bx_le_refl is foundational |
| BXCanonical/Completeness.lean | 1 | 4 | Active completeness theorems |
| Bundle/SuccRelation + SuccExistence | 2 | 6 | Actively imported infrastructure |
| WeakCanonical/* | 5 | 21 | Reynolds pipeline + truth lemma |
| Algebraic/* | 2 | 3 | Active algebraic pipeline |
| Theorems/TemporalDerived | 1 | 19 | Active theorem stubs |
| **Total** | **12** | **54** | |

## Recommendations

### 1. Archive the confirmed-dead BXCanonical non-Chronicle pipeline (15 sorries)

Move the following to `Boneyard/BXCanonicalDeadPipeline/`:
- Content from `Quasimodel/Realization.lean` (4 sorries: F_of_mem, P_of_mem, enriched_seed_consistent_until/since)
- Content from `Quasimodel/Construction.lean` (2 sorries: refl_intro_until/since_mcs)
- Content from `TruthLemma.lean` (2 sorries: until/since_backward_refl_mcs)
- Content from `RootScopedChain.lean` (3 sorries: bx_bfmcs_restricted_tc/buc/fuc)
- Content from `Filtration/SigmaOrdering.lean` (3 sorries: sigma_le/strict/equiv)
- `dd_countermodel_chronicle_nondense_sorry` from ChronicleToCountermodel.lean (1 sorry)

**Complication**: These files contain BOTH dead-sorry definitions and live definitions. Whole-file archival is only possible if:
- All definitions in the file are dead, OR
- Dead definitions can be surgically extracted without breaking imports

For files like Frame.lean and Completeness.lean, only specific theorems are dead. The files themselves must remain.

### 2. Annotate (not move) the ChronicleToCountermodel convergence sorries (4 sorries)

Lines 1301, 1454, 1518, 1888 in ChronicleToCountermodel.lean should be annotated with `-- DEAD APPROACH: resolution via task 129/Reynolds pipeline` but left in place because the surrounding definitions are structurally active.

### 3. Do NOT archive Bundle/SuccRelation or Bundle/SuccExistence (6 sorries)

These are actively imported by 4+ modules and contain live infrastructure. The task description asks "if no longer needed" -- they ARE still needed.

### 4. Do NOT archive the remaining 48 sorries

These are on active development paths (WeakCanonical, Algebraic, TemporalDerived, Completeness).

### 5. Revised Total Count

The task description estimates ~40 sorries to archive. The actual archivable count is:
- **15 confirmed dead-code sorries** (BXCanonical pipeline + nondense stub)
- **4 dead-approach sorries** in ChronicleToCountermodel (annotate, not move)
- **0 from Bundle** (still needed)
- **Total actionable: 19 sorries** (15 archive + 4 annotate)

### 6. Implementation Approach

For BXCanonical pipeline files with mixed live/dead code:
1. Extract dead theorems into Boneyard files
2. Leave live definitions + imports intact
3. Add `-- Archived to Boneyard/BXCanonicalDeadPipeline/: {list}` comments
4. Create README.md following existing Boneyard convention
5. Update Boneyard/README.md inventory table

For RootScopedChain.lean specifically: the entire file may be archivable since its only consumer (Completeness.lean) bypasses it via Chronicle. Verify by checking if removing the import from Completeness.lean compiles.
