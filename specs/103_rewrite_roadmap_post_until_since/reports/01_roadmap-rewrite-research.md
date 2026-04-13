# Research Report: Task #103

**Task**: 103 - Comprehensive ROAD_MAP.md rewrite for post-Until/Since state
**Started**: 2026-04-13T06:30:00Z
**Completed**: 2026-04-13T07:00:00Z
**Effort**: 3-5 hours (for the rewrite itself; this research: ~30 min)
**Dependencies**: None
**Sources/Inputs**:
- Codebase grep/search of all `sorry` instances in `Theories/Bimodal/`
- Current `specs/ROAD_MAP.md` (written task 91, 2026-04-10, patched 2026-04-12)
- `specs/state.json` and `specs/TODO.md` for task status cross-reference
- All 13 files under `Theories/Bimodal/Metalogic/BXCanonical/`
**Artifacts**:
- `specs/103_rewrite_roadmap_post_until_since/reports/01_roadmap-rewrite-research.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- The ROAD_MAP.md has a correct task cross-reference table (patched 2026-04-12 review) but the body text is stale: the "Active-Path Sorry Inventory" section still says 6 sorries and documents 5 that are now closed.
- There is exactly **1 sorry on the active completeness path**: `BXCanonical/Completeness.lean:154` (TaskModel embedding).
- Frame.lean is **completely sorry-free** (673 lines). All 5 formerly sorry'd functions (`bx_modal_witness`, `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`) are either proved or removed.
- 7 new files were added under BXCanonical/ for the quasimodel/filtration infrastructure (2,067 lines total). These are undocumented in the current roadmap.
- The FMP TruthPreservation sorries (task 82) were archived to Boneyard, not closed. Task 82's description is stale.
- Soundness and Decidability modules are **entirely sorry-free**.

## Context & Scope

Task 103 requires a comprehensive rewrite of `specs/ROAD_MAP.md` to reflect the post-Until/Since closure state. This research gathers every fact needed for that rewrite: sorry inventory, task status cross-reference, new infrastructure documentation, and identification of every stale section.

## Findings

### 1. Sorry Inventory (Active, Non-Boneyard, Non-Example Files)

#### Active Completeness Path (BXCanonical/)

| # | File | Line | Definition | Status |
|---|------|------|------------|--------|
| 1 | `BXCanonical/Completeness.lean` | 154 | `bx_completeness` final step (TaskModel embedding) | **OPEN** (task 93) |

**Total active-path sorries: 1**

Frame.lean: 0 sorries (all 5 previously documented sorries closed by tasks 98+102).

#### Legacy Files (Not on Active Path, Candidates for Archival by Task 94)

| File | Sorry count | Category |
|------|-------------|----------|
| `Metalogic/Algebraic/UltrafilterChain.lean` | 4 | Legacy strict-semantics |
| `Metalogic/Algebraic/DovetailedChain.lean` | 6 | Deprecated (X-vs-G mismatch) |
| `Metalogic/Algebraic/LindenbaumQuotient.lean` | 2 | temp_k_dist derivable from BX |
| `Metalogic/Algebraic/InteriorOperators.lean` | 1 | temp_k_dist derivable from BX |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 3 | Legacy strict-semantics |
| `Metalogic/Bundle/SuccRelation.lean` | 1 | Legacy |
| `Metalogic/Bundle/CanonicalFrame.lean` | 1 | BX derivability |
| `FrameConditions/Completeness.lean` | 2 | Wiring (temporal coherence + dense) |

**Total legacy sorries (non-Boneyard, non-Example): ~20**

#### Boneyard Files

~14 sorries across Boneyard/ subdirectories (archived dead code, expected).

#### Example Files

~57 sorries across Examples/ (pedagogical exercises, expected and intentional).

#### Sorry-Free Modules (Confirmed)

- `Metalogic/Soundness.lean` -- 0 sorries
- `Metalogic/DenseSoundness.lean` -- 0 sorries
- `Metalogic/DiscreteSoundness.lean` -- 0 sorries
- `Metalogic/Decidability/**` -- 0 sorries (entire subtree)
- `Metalogic/BXCanonical/Frame.lean` -- 0 sorries
- `Metalogic/BXCanonical/TruthLemma.lean` -- 0 sorries
- `Metalogic/BXCanonical/CanonicalChain.lean` -- 0 sorries
- `Metalogic/BXCanonical/Quasimodel/*` -- 0 sorries
- `Metalogic/BXCanonical/Filtration/*` -- 0 sorries

### 2. Task Cross-Reference Errors in ROAD_MAP.md

The 2026-04-12 review patch already corrected the cross-reference table at the bottom (lines 597-612). However, the following body sections remain stale:

| Section | Line Range | Error |
|---------|------------|-------|
| "Active-path sorry summary" | 17-29 | Says 6 sorries, shows a table with "STALE" warning but body still describes 6 |
| "Active-Path Sorry Inventory" | 296-329 | Full table lists 6 sorries with detailed descriptions of 5 that are now closed |
| "Current Gap Summary" | 312-328 | Describes X-vs-G mismatch as an open gap; this was resolved |
| "Recommended Priority Order" | 569-589 | Lists tasks 91, 90, 92 as items 1-4; these are completed |
| "Other Open Items / FMP Truth Preservation" | 517-524 | Says 2 sorries; they are archived (0 remain) |
| "Burgess-Xu Until-Induction Technique / Option A vs B" | 418-432 | Describes Option A and B as open; Option A was implemented |
| Module Import Graph | 192-209 | Missing new Quasimodel/ and Filtration/ subdirectories |
| "Active Metalogic Path: BXCanonical" | 183-216 | Missing CanonicalChain.lean and submodules |

### 3. New BXCanonical Infrastructure (Undocumented)

Seven new files added for the quasimodel/filtration approach that closed Until/Since:

#### Quasimodel/ (Hintikka-set quasimodel construction)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SubformulaClosure.lean` | 114 | Finite subformula closure (Sigma-closure) | `subformulas`, `SubformulaClosure`, `ghEnrichment` |
| `HintikkaPoint.lean` | 166 | Hintikka point definition and sigma-signature | `HintikkaPoint`, `sigma_signature`, `sigma_signature_consistent`, `sigma_signature_maximal` |
| `EnrichedClosure.lean` | 158 | Fisher-Ladner enriched closure with G/H negation formulas | `enrichedGNegBigconj`, `enrichedHNegBigconj`, `enrichedClosure` |
| `Construction.lean` | 887 | BX axiom lemmas at MCS level with defect-discharge | `hintikka_step`, `UntilDefect`, `defect_count`, `QuasimodelChain` |
| `Realization.lean` | 444 | Realization lifting from Hintikka chains to BXPoint chains | `until_forward_seed`, `since_backward_seed`, `until_eventuality_resolution`, `since_eventuality_resolution` |
| `LocusControl.lean` | 47 | Delegation layer (primed variants) | `bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'` |

#### Filtration/ (Sigma-restricted ordering)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SigmaOrdering.lean` | 179 | Sigma-restricted ordering on BXPoints | `sigma_le`, `sigma_strict`, `sigma_equiv`, `bx_le_implies_sigma_le` |
| `DefectChain.lean` | 137 | Defect-discharge chain via well-founded recursion | `sigma_defect_count`, `until_defect`, `defect_step_phi` |

#### CanonicalChain.lean (top-level)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `CanonicalChain.lean` | 157 | MCS-level BX axiom lemmas and delegation bridges | `psi_imp_until_mcs`, `psi_imp_since_mcs`, `F_imp_top_until_mcs`, `left_mono_until_mcs` |

**Total new infrastructure: 2,289 lines across 9 files (all sorry-free).**

### 4. Updated Module Import Graph

The current BXCanonical module structure:

```
Metalogic/BXCanonical/BXCanonical.lean (aggregator)
  ├── Frame.lean (673 lines, sorry-free)
  │     ├── Core/MaximalConsistent
  │     ├── Core/MCSProperties
  │     ├── Bundle/TemporalContent
  │     ├── Bundle/WitnessSeed
  │     ├── Bundle/CanonicalFrame
  │     ├── Syntax/Formula
  │     └── Theorems/GeneralizedNecessitation
  │
  ├── TruthLemma.lean (320 lines, sorry-free)
  │     ├── Frame
  │     ├── Semantics/Truth
  │     └── Semantics/Validity
  │
  ├── Completeness.lean (163 lines, 1 sorry)
  │     ├── TruthLemma
  │     └── Semantics/Validity
  │
  ├── CanonicalChain.lean (157 lines, sorry-free)
  │     ├── Frame
  │     ├── Quasimodel/Construction
  │     └── Filtration/DefectChain
  │
  ├── Quasimodel/
  │     ├── SubformulaClosure.lean (114 lines)
  │     │     └── Syntax/Formula
  │     ├── HintikkaPoint.lean (166 lines)
  │     │     ├── SubformulaClosure
  │     │     └── Frame
  │     ├── EnrichedClosure.lean (158 lines)
  │     │     ├── Syntax/BigConj
  │     │     ├── SubformulaClosure
  │     │     └── Mathlib.Data.Finset.Powerset
  │     ├── Construction.lean (887 lines)
  │     │     ├── HintikkaPoint
  │     │     └── Mathlib.Data.List.Chain
  │     ├── Realization.lean (444 lines)
  │     │     ├── Construction
  │     │     ├── Syntax/BigConj
  │     │     ├── Theorems/Combinators
  │     │     └── Theorems/Propositional
  │     └── LocusControl.lean (47 lines)
  │           └── Realization
  │
  └── Filtration/
        ├── SigmaOrdering.lean (179 lines)
        │     ├── Frame
        │     └── Quasimodel/EnrichedClosure
        └── DefectChain.lean (137 lines)
              ├── SigmaOrdering
              └── Quasimodel/Construction
```

**Total BXCanonical module: 3,473 lines across 13 files, 1 sorry.**

### 5. Remaining Work Before Publication

#### Critical Path (sequential)

1. **Task 93** -- Close `Completeness.lean:154` (TaskModel embedding). This is the sole remaining active-path sorry. Requires constructing a `TaskModel` from the BXPoint canonical frame using non-constant histories. Dependencies: none (tasks 90, 92, 98, 102 all completed).

2. **Task 95** -- Verification audit: `#print axioms` on `bx_completeness` confirming output is exactly `{propext, Classical.choice, Quot.sound}`. Depends on task 93.

#### Documentation/Cleanup (parallelizable with critical path)

3. **Task 103** (this task) -- ROAD_MAP.md rewrite.
4. **Task 94** -- Archive legacy strict-semantics files to Boneyard (~20 sorry drop from active tree).
5. **Task 104** -- Clean up superseded tasks in state.json (abandon 89, update 60/87/998).
6. **Task 105** -- Update stale sorry-blocker comments in BXCanonical code.

#### Independent Tracks

7. **Task 82** -- FMP Truth Preservation. Note: the 2 sorries described in the task (mcs_all_future_closure, mcs_all_past_closure) were archived to Boneyard, not closed. The FMP module is currently sorry-free. Task 82's description needs updating -- it may already be done or may need redesign.
8. **Task 68** -- Dense completeness via Rat canonical model (independent).
9. **Task 60** -- Remove discrete_Icc_finite_axiom (may already be gone per TODO.md note).

### 6. Sections of ROAD_MAP.md Needing Update

| Section | Action Required |
|---------|----------------|
| "Overview" (lines 1-33) | Rewrite stale sorry summary; remove "STALE" warning banner; update count from 6 to 1 |
| "BX Axiom System" (lines 36-113) | Mostly accurate. Minor: verify line numbers still match code |
| "Reflexive Truth Semantics" (lines 116-147) | Accurate; no changes needed |
| "X/Y Operator Status" (lines 150-179) | Accurate; no changes needed |
| "Active Metalogic Path: BXCanonical" (lines 183-216) | Major rewrite: add new modules, update import graph |
| "Canonical Model Construction" (lines 220-293) | Update: remove references to sorry at Frame.lean:440, remove Until/Since as "sorry" cases in truth lemma |
| "Active-Path Sorry Inventory" (lines 296-329) | Major rewrite: reduce from 6-entry table to 1-entry table |
| "Legacy Code Inventory" (lines 332-363) | Update sorry counts; they have decreased from ~210 to ~20 in active tree |
| "Burgess-Xu Until-Induction Technique" (lines 367-432) | Rewrite as historical context: Option A was chosen and implemented successfully |
| "Dead Ends" (lines 436-504) | Accurate historical record; no changes needed |
| "Other Open Items" (lines 508-535) | Update FMP status (sorries archived); update Soundness (confirmed sorry-free) |
| "Investigated Dead Ends: Logic Weakening" (lines 539-543) | No changes needed |
| "Representation Theorem Goal" (lines 547-565) | No changes needed |
| "Recommended Priority Order" (lines 569-589) | Major rewrite: remove completed tasks, reorder |
| "Task Cross-Reference" (lines 593-612) | Already patched; verify against state.json |
| NEW: "Quasimodel/Filtration Infrastructure" | Add new section documenting the 9 new files and their role in closing Until/Since |
| NEW: "How Until/Since Were Closed" | Add narrative section documenting the successful approach (tasks 90+92+98+102) |

## Decisions

- The sorry count categorization uses "active path" (BXCanonical/ only) vs "legacy" (other Metalogic/ files not imported by BXCanonical) vs "Boneyard" vs "Examples" as the four categories.
- Task 82 (FMP TruthPreservation) needs reassessment: the sorries it described are gone (archived), so the task may be complete or may need a new description.
- The "Dead Ends" section should be preserved as-is -- it is accurate historical documentation.

## Risks & Mitigations

- **Risk**: Line numbers in ROAD_MAP.md references to code may shift as tasks 105 (stale comments) modifies code. **Mitigation**: Use function/definition names as primary identifiers, line numbers as secondary.
- **Risk**: Task 93 description in state.json still references Frame.lean:440 sorry (now closed). **Mitigation**: Task 104 will clean this up.

## Appendix

### Search Queries Used
- `grep -rn "^\s*sorry" Theories/Bimodal/ --include="*.lean"` -- full sorry inventory
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/ --include="*.lean"` -- BXCanonical sorry check
- `find Theories/Bimodal/Metalogic/BXCanonical -name "*.lean"` -- new file listing
- `wc -l` on all BXCanonical files -- line counts
- Read of `specs/ROAD_MAP.md`, `specs/state.json`, `specs/TODO.md` -- cross-reference
- Read of all 13 BXCanonical file headers -- purpose and key definitions

### References
- Burgess 1984: "Basic tense logic"
- Xu 1988: "On some U, S-tense logics"
- Reynolds 1996: "An axiomatization of full computation tree logic"
- Fisher-Ladner 1979: "Propositional modal logic of programs"
- Goldblatt 1992 (completeness for tense logics)
