# Research Report: BX Pipeline Archival to Boneyard

**Task**: 225 -- Archive BX pipeline to Boneyard to prevent implementation agent distraction
**Session**: sess_1748617200_orch225
**Date**: 2026-05-30

## Executive Summary

The "BX pipeline" refers to the sorry chain `no_gaps_faithful` -> `prior_model_is_succ_archimedean` -> `chronicle_gap_contradiction` -> `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `succ_embed_surjective` -> `dd_countermodel_chronicle_discrete`. The root sorry `no_gaps_faithful` in ReynoldsModelSurgery.lean:312 is **known to be unprovable as stated** (documented at line 307). The correct path is the "Reynolds pipeline": prove `no_gaps_discrete` (in GoodStructures.lean:841) and wire through `one_class` -> `chronicle_is_good_direct` -> `countermodel_discrete_reynolds`.

However, the situation is more nuanced than a simple "move to Boneyard" operation. The BX pipeline files serve DUAL roles: the sorry chain (`no_gaps_faithful` -> `succ_cofinal`) is dead, but the Chronicle construction machinery (ChronicleTypes, ChronicleConstruction, PointInsertion, CounterexampleElimination, RRelation) is actively used by BOTH pipelines. The Reynolds pipeline depends on `extract_chronicle_as_prior` (ChronicleExtraction.lean) which imports ChronicleConstruction and ChronicleToCountermodel.

## 1. BX Pipeline -- Dead Sorry Chain

### 1.1 Root Sorry: `no_gaps_faithful`

- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean`
- **Line**: 310-312
- **Status**: `sorry` -- documented as "Known to be unprovable as stated" (line 307)
- **Why false**: Z+Z counterexample with constant predicates satisfies all `PriorModelData` hypotheses but has a Dedekind gap. Missing a predicate accessibility/faithfulness condition.

### 1.2 Sorry Chain (Dead Path)

```
no_gaps_faithful (ReynoldsModelSurgery.lean:312, sorry)
  -> prior_model_is_succ_archimedean (ReynoldsModelSurgery.lean:323)
    -> chronicle_gap_contradiction (ChronicleToCountermodel.lean:1524)
      -> succ_cofinal (ChronicleToCountermodel.lean:1585)
        -> limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:1599)
          -> succ_embed_surjective (ChronicleToCountermodel.lean:2524)
            -> cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean)
            -> cantor_bfmcs_discrete_restricted_fuc (ChronicleToCountermodel.lean)
              -> dd_countermodel_chronicle_discrete (ChronicleToCountermodel.lean:2994)
```

### 1.3 Additional Dead Sorries in ChronicleToCountermodel.lean

- **Line 1287**: sorry in `succ_reaches_dom_N` (above-max boundary case)
- **Line 1443**: sorry in `succ_reaches_dom_N` (below-min boundary case)
- These are in the dead convergence proof path, NOT on the Reynolds pipeline

### 1.4 Files Containing Dead BX Pipeline Code

| File | Dead Definitions | Status |
|------|-----------------|--------|
| `ReynoldsModelSurgery.lean` | `no_gaps_faithful` (L310), `prior_model_is_succ_archimedean` (L323) | sorry, unprovable |
| `ChronicleToCountermodel.lean` | `chronicle_gap_contradiction` (L1524), `succ_cofinal` (L1585), `limitDomSubtype_isSuccArchimedean` (L1599), `succ_reaches_dom_N` (L1200-1450) | sorry chain |
| `ChronicleNoGaps.lean` | Entire file -- architectural skeleton for chronicle-level gap proof | Empty shell, references dead chain |
| `HenkinDiscreteChain.lean` | Entire file -- analysis document | Pure documentation of dead approaches |

## 2. Reynolds Pipeline -- Active/Correct Path

### 2.1 Root Sorry: `no_gaps_discrete`

- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`
- **Line**: 820-841
- **Status**: `sorry` -- active work target (Reynolds Theorem 14, Lemmas 6-13)
- **Signature**: Includes `h_accessible` parameter (predicate accessibility) -- correctly stronger than `no_gaps_faithful`

### 2.2 Reynolds Pipeline Chain (Correct Path)

```
no_gaps_discrete (GoodStructures.lean:841, sorry -- ACTIVE WORK TARGET)
  -> one_class (GoodStructures.lean:882, sorry-free modulo no_gaps_discrete)
    -> chronicle_is_good_direct (Transfer.lean, sorry-free modulo one_class)
      -> countermodel_discrete_reynolds (Transfer.lean:1067)
```

### 2.3 Reynolds Pipeline Support Infrastructure

| File | Key Definitions | Status |
|------|----------------|--------|
| `GoodStructures.lean` | `no_gaps_discrete`, `one_class`, `no_boundary_at_successor`, `contemp_equiv`, `good` | Active, sorry at `no_gaps_discrete` |
| `GoodStructuresModelSurgery.lean` | `no_gaps_discrete_model_surgery`, infrastructure lemmas | Active development (task 202) |
| `ReynoldsNoGaps.lean` | `no_gaps_discrete_archimedean` | Active |
| `Transfer.lean` | `countermodel_discrete_reynolds`, `chronicle_temporal_truth`, `chronicle_is_good_direct` | Active, sorry at `countermodel_discrete_reynolds` (packaging) |
| `ChronicleExtraction.lean` | `extract_chronicle_as_prior`, `ChronicleAsPriorModel` | Active |
| `PriorExpressiveness.lean` | US expressive completeness | Active |
| `ShiftAndGlue.lean` | Z-interval construction | Active |

### 2.4 Current `completeness_discrete` Wiring

```
completeness_discrete (BXCanonical/Completeness.lean:309)
  -> countermodel_discrete_enriched (BXCanonical/Completeness.lean:222)
    -> dd_countermodel_chronicle_discrete (ChronicleToCountermodel.lean:2994)
      -> [DEAD: succ_embed_surjective -> ... -> no_gaps_faithful (sorry)]
```

The completeness theorem currently uses the DEAD path. The rewiring goal is:

```
completeness_discrete
  -> countermodel_discrete_enriched (rewired)
    -> countermodel_discrete_reynolds (Transfer.lean:1067)
      -> [ACTIVE: chronicle_is_good_direct -> one_class -> no_gaps_discrete]
```

## 3. Boneyard Analysis

### 3.1 Existing Boneyard Directories

**Root-level Boneyard** (outside `lake build` scope):
- `Boneyard/DeadConvergenceProof/` -- 2 files, archived 2026-05-29 (task 202)

**In-tree Boneyard** (inside `Theories/Bimodal/Boneyard/`, also outside `lake build` scope):
- 20 subdirectories, 36+ files
- Has comprehensive `README.md` with inventory table
- Convention: each directory has descriptive name, files explain why archived and from where
- **No Boneyard file is imported** by any active module

### 3.2 Naming Convention

Boneyard entries follow this pattern:
- Directory name: `CamelCase` descriptive of the dead approach
- Each directory has files explaining the approach and why it failed
- The Boneyard README has an inventory table with columns: Directory, Files, Lines, Archived From, Why Archived, Task

## 4. Dependency Map

### 4.1 External Imports INTO BXCanonical (from outside)

| Importing File | Imports From BXCanonical | Can Be Cut? |
|---------------|-------------------------|-------------|
| `Metalogic.lean` | `BXCanonical.BXCanonical` | NO -- umbrella import for whole metalogic |
| `Transfer.lean` | `Chronicle.ChronicleToCountermodel` | NO -- Reynolds pipeline uses chronicle defs |
| `ChronicleExtraction.lean` | `Chronicle.ChronicleConstruction`, `Chronicle.ChronicleToCountermodel` | NO -- extracts ChronicleAsPriorModel |
| `ChronicleNoGaps.lean` | `Chronicle.ChronicleToCountermodel` | YES -- dead file, references dead chain |
| `ReflexiveCanonical.lean` | `BXCanonical.OrderedSeedConsistency` | MAYBE -- may reference shared BX infrastructure |
| `ReynoldsModelSurgery.lean` | `BXCanonical.TruthLemma` | NO -- uses TruthLemma for effectiveFormula |

### 4.2 Critical Observation: Shared Infrastructure

The BXCanonical directory contains TWO categories of code:

**Category A -- Shared Chronicle Infrastructure (MUST KEEP)**:
- `ChronicleTypes.lean` (865 lines) -- type definitions used by both pipelines
- `ChronicleConstruction.lean` (1510 lines) -- construction logic used by both
- `PointInsertion.lean` (3527 lines) -- point insertion used by both
- `CounterexampleElimination.lean` (3487 lines) -- CE used by both
- `RRelation.lean` (1686 lines) -- R-relation used by both
- `Frame.lean` (857 lines) -- canonical frame shared
- `TruthLemma.lean` -- truth lemma shared
- `CanonicalModel.lean` -- canonical model shared
- `CanonicalChain.lean` -- chain infrastructure shared
- `OrderedSeedConsistency.lean` -- shared
- `Quasimodel/` -- quasimodel infrastructure shared
- `Filtration/` -- filtration infrastructure shared
- `Completeness.lean` -- completeness theorems (both dense + discrete)
- `BXCanonical.lean` -- umbrella import

**Category B -- Dead BX-Specific Code (CANDIDATES FOR ARCHIVAL)**:
- `ChronicleToCountermodel.lean` lines 1200-1629: `succ_reaches_dom_N`, `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, and related dead path code
- `HenkinDiscreteChain.lean` (121 lines) -- pure documentation of dead approaches
- `ChronicleNoGaps.lean` (165 lines) -- dead architectural skeleton in WeakCanonical

**Category C -- Dead Code in WeakCanonical (CANDIDATES FOR ARCHIVAL)**:
- `ReynoldsModelSurgery.lean` lines 295-387: `no_gaps_faithful`, `prior_model_is_succ_archimedean`
- `Transfer.lean` lines 1200-1215: `countermodel_discrete` (uses dead chain)

## 5. Recommended Archival Strategy

### 5.1 CANNOT Move Entire BXCanonical Directory

Moving the entire `BXCanonical/` directory would break the build catastrophically -- it contains shared infrastructure used by the active Reynolds pipeline. The dead code is INTERLEAVED with live code in `ChronicleToCountermodel.lean`.

### 5.2 Recommended Approach: Deprecation Annotations + Targeted Moves

**Phase 1: Mark Dead Code with Deprecation Comments**

In `ChronicleToCountermodel.lean` (lines 1200-1629), add clear deprecation blocks:
```lean
/-! ## DEPRECATED: BX Pipeline Dead Code
WARNING: The following definitions are part of the dead BX pipeline.
`no_gaps_faithful` is known to be unprovable as stated.
The correct path is the Reynolds pipeline via `no_gaps_discrete`.
DO NOT attempt to prove or use these definitions.
See task 225 for archival documentation.
-/
```

Mark each definition: `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, `succ_reaches_dom_N`.

**Phase 2: Mark Dead Code in ReynoldsModelSurgery.lean**

Add deprecation to `no_gaps_faithful` (lines 295-312) and `prior_model_is_succ_archimedean` (lines 323-387):
```lean
@[deprecated "BX pipeline dead code -- no_gaps_faithful is unprovable as stated. Use no_gaps_discrete instead. See task 225."]
```

**Phase 3: Move Pure Dead Files to Boneyard**

- Move `HenkinDiscreteChain.lean` -> `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean`
- Move `ChronicleNoGaps.lean` -> `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/ChronicleNoGaps.lean`

**Phase 4: Update Boneyard README**

Add entry to `Theories/Bimodal/Boneyard/README.md`:
```
| BXPipelineGapAnalysis | 2 | ~286 | Chronicle/, WeakCanonical/ | BX pipeline gap analysis (no_gaps_faithful unprovable, succ_cofinal dead) | 225 |
```

**Phase 5: Update `countermodel_discrete` in Transfer.lean**

Add clear warning to `countermodel_discrete` (Transfer.lean:1200) marking it as using the dead BX path.

### 5.3 What NOT to Archive

- Do NOT move any file from `BXCanonical/Chronicle/` except `HenkinDiscreteChain.lean`
- Do NOT move `ChronicleToCountermodel.lean` -- it contains live code interleaved with dead code
- Do NOT move `ReynoldsModelSurgery.lean` -- it contains live `PriorModelData` infrastructure used by `chronicle_gap_contradiction` (which is dead, but removing it would break compilation of live downstream code)
- Do NOT touch `Completeness.lean`, `BXCanonical.lean`, or any Quasimodel/Filtration files

## 6. Risks and Concerns

### 6.1 Import Chain Risk

`ChronicleNoGaps.lean` imports `ChronicleToCountermodel` and is imported by `WeakCanonical.lean`. Moving it to Boneyard will require updating `WeakCanonical.lean` to remove the import. This should be safe since `ChronicleNoGaps` contains only dead architectural skeleton definitions.

### 6.2 Compilation Risk

After removing `ChronicleNoGaps.lean` from the import chain, verify `lake build` succeeds. The file exports `gap_of_not_succ_archimedean_local`, `gap_cut_lt_complement`, and `gap_succ_cut_lt_complement`. Need to verify these are not used elsewhere.

### 6.3 `countermodel_discrete` Still Uses Dead Path

`completeness_discrete` (Completeness.lean:309) still calls `countermodel_discrete_enriched` which uses `dd_countermodel_chronicle_discrete` (dead path). The rewiring to use `countermodel_discrete_reynolds` is a SEPARATE task (part of task 202 or a successor). This archival task should NOT rewire completeness -- only mark and archive dead code.

### 6.4 `prior_model_is_succ_archimedean` Is Called By Live Code

`chronicle_gap_contradiction` (ChronicleToCountermodel.lean:1566) calls `prior_model_is_succ_archimedean`, which calls `no_gaps_faithful`. Since `chronicle_gap_contradiction` is itself dead code, this is not a problem for correctness -- but removing `prior_model_is_succ_archimedean` would break compilation of `chronicle_gap_contradiction`. Keep both in place with deprecation annotations.

## 7. Complete File Inventory

### BX Pipeline Files (Dead)

| File | Path | Lines | Contains | Action |
|------|------|-------|----------|--------|
| ReynoldsModelSurgery.lean | WeakCanonical/IntegerModel/ | 387 | `no_gaps_faithful` (sorry, unprovable), `prior_model_is_succ_archimedean` | Deprecation annotations (keep file -- has live PriorModelData code) |
| ChronicleToCountermodel.lean | BXCanonical/Chronicle/ | 3084 | `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, `succ_reaches_dom_N` (sorries at L1287, L1443) | Deprecation blocks on dead sections (keep file -- has live code) |
| ChronicleNoGaps.lean | WeakCanonical/ | 165 | Gap analysis skeleton, `gap_of_not_succ_archimedean_local` | Move to Boneyard |
| HenkinDiscreteChain.lean | BXCanonical/Chronicle/ | 121 | Dead approach documentation | Move to Boneyard |

### Reynolds Pipeline Files (Active)

| File | Path | Lines | Key Definitions |
|------|------|-------|----------------|
| GoodStructures.lean | WeakCanonical/IntegerModel/ | ~910 | `no_gaps_discrete` (sorry -- active target), `one_class`, `good` |
| GoodStructuresModelSurgery.lean | WeakCanonical/IntegerModel/ | ~340 | `no_gaps_discrete_model_surgery` (sorry -- active development) |
| ReynoldsNoGaps.lean | WeakCanonical/IntegerModel/ | ~120 | `no_gaps_discrete_archimedean` |
| Transfer.lean | WeakCanonical/ | ~1217 | `countermodel_discrete_reynolds`, `chronicle_temporal_truth` |
| ChronicleExtraction.lean | WeakCanonical/ | ~190 | `extract_chronicle_as_prior`, `ChronicleAsPriorModel` |
| PriorExpressiveness.lean | WeakCanonical/ | varies | US expressive completeness |
| ShiftAndGlue.lean | WeakCanonical/IntegerModel/ | ~940 | Z-interval construction |

### Already Archived

| File | Path | Lines | Archived From |
|------|------|-------|---------------|
| succ_cofinal_convergence.lean | Boneyard/DeadConvergenceProof/ | 367 | ChronicleToCountermodel.lean |
| limit_dom_succ_iterates.lean | Boneyard/DeadConvergenceProof/ | varies | ChronicleToCountermodel.lean |
