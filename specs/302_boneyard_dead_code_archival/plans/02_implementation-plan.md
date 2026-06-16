# Implementation Plan: Task #302

- **Task**: 302 - Comprehensive dead code archival to Boneyard/ with comment cleanup
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: None (task 303 is downstream but not a blocker)
- **Research Inputs**: specs/302_boneyard_dead_code_archival/reports/01_team-research.md
- **Artifacts**: plans/02_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Archive approximately 9,800 lines of dead code from the live source tree into Boneyard/ subdirectories, extract dead blocks from 5 live files, relocate misplaced root-level Boneyard files, and clean up stale/misleading comments throughout the codebase. Each phase is sequenced to maintain a passing `lake build` at every step. The task explicitly avoids touching any file on the active completeness path (WeakCanonical/, Chronicle/, BXCanonical live definitions).

### Research Integration

Team research (4 teammates) identified: 12 standalone dead files (~7,878 lines) with zero live importers across 4 clusters (Kamp negation closure, Rabinovich path, EFGames Stavi discrete, BXCanonical Quasimodel); ~961 lines of in-file dead blocks across 5 files; 2 misplaced root-level Boneyard files; and 8 comment hygiene issues across 6 files. Key finding: BXCanonical is NOT entirely dead — only `EnrichedClosure.lean` is a standalone dead file; most BXCanonical files export live definitions used by the active completeness path.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation requested.

## Goals & Non-Goals

**Goals**:
- Archive all confirmed standalone dead files into topic-based Boneyard/ subdirectories with provenance comments
- Extract dead code blocks from live files into existing or new Boneyard/ subdirectories
- Relocate root-level `/Boneyard/DeadConvergenceProof/` into `Theories/Bimodal/Boneyard/`
- Update all aggregator imports so `lake build` passes after each phase
- Fix misleading comments, stale task references, and orphaned markers throughout the codebase

**Non-Goals**:
- File splitting of oversized files (GapDetection.lean, SplitPoint.lean, etc.) — separate task scope
- Bundle/SuccRelation dependency tracing — deferred per research recommendation
- Build profiling or performance measurement
- Modifying any file on the active completeness path (unless removing a dead block from it)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Moving Kamp files breaks live imports | H | L | Research confirmed zero external importers; grep verification before each move |
| Dead block extraction breaks surrounding code | M | M | Extract conservatively; run `lake build` after each extraction |
| Root Boneyard relocation breaks lean_lib target | M | L | BoneyardArchive target already globs `Bimodal.Boneyard`; confirm lakefile target compatibility |
| Misidentified dead code is actually live | H | L | Only archive HIGH-confidence items from research; verify with import grep before move |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are sequential because each modifies imports/aggregators that later phases depend on.

### Phase 1: Archive standalone dead Kamp files [COMPLETED]

**Goal**: Move the 8 dead Kamp files (negation closure chain + Rabinovich chain) into two new Boneyard subdirectories.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/KampNegationClosure/` directory
- [ ] Move `NegationClosure.lean`, `NegationClosure5.lean`, `NegationClosureProp42.lean`, `FoToVecEA.lean` from `Metalogic/WeakCanonical/Kamp/` to `Boneyard/KampNegationClosure/`
- [ ] Add provenance header comments to each moved file (original location, reason for archival)
- [ ] Add `#exit` guard after provenance comments in each file (prevents build errors from stale imports)
- [ ] Create `Theories/Bimodal/Boneyard/RabinovichPath/` directory
- [ ] Move `RabinovichNegation.lean`, `RabinovichGeneralized.lean`, `RabinovichWiring.lean`, `RabinovichProp42.lean` from `Metalogic/WeakCanonical/Kamp/` to `Boneyard/RabinovichPath/`
- [ ] Add provenance headers and `#exit` guards to each Rabinovich file
- [ ] Remove import lines referencing the moved files from any remaining Kamp files (verify with grep)
- [ ] Run `lake build` to verify clean build

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` — move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` — move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` — move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` — move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean` — move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` — move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichWiring.lean` — move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichProp42.lean` — move to Boneyard
- `Theories/Bimodal/Boneyard/KampNegationClosure/` — new directory with 4 files
- `Theories/Bimodal/Boneyard/RabinovichPath/` — new directory with 4 files

**Verification**:
- `grep -r "NegationClosure\|RabinovichNegation\|RabinovichGeneralized\|RabinovichWiring\|RabinovichProp42\|FoToVecEA" Theories/Bimodal/Metalogic/` returns no import lines
- `lake build` succeeds

---

### Phase 2: Archive dead EFGames files and EnrichedClosure [COMPLETED]

**Goal**: Move the 3 dead EFGames Stavi discrete files and the dead BXCanonical Quasimodel file, plus relocate root-level Boneyard.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/StaviDiscretePath/` directory
- [ ] Move `DiscreteStaviCompleteness.lean`, `NFGameBridge.lean`, `DiscreteGameTransfer.lean` from `Metalogic/WeakCanonical/EFGames/` to `Boneyard/StaviDiscretePath/`
- [ ] Add provenance headers and `#exit` guards to each moved file
- [ ] Remove import references to the moved files from `StaviCompleteness.lean` or other EFGames files (verify with grep)
- [ ] Create `Theories/Bimodal/Boneyard/BXCanonicalQuasimodel/` directory
- [ ] Move `EnrichedClosure.lean` from `Metalogic/BXCanonical/Quasimodel/` to `Boneyard/BXCanonicalQuasimodel/`
- [ ] Add provenance header and `#exit` guard
- [ ] Move `/Boneyard/DeadConvergenceProof/` contents into `Theories/Bimodal/Boneyard/DeadConvergenceProof/`
- [ ] Add provenance headers and `#exit` guards to the relocated DeadConvergenceProof files
- [ ] Remove the now-empty root `/Boneyard/` directory
- [ ] Run `lake build` to verify clean build

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteStaviCompleteness.lean` — move
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` — move
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` — move
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` — remove dead imports
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` — move
- `Boneyard/DeadConvergenceProof/*.lean` — relocate to `Theories/Bimodal/Boneyard/DeadConvergenceProof/`
- `Theories/Bimodal/Boneyard/StaviDiscretePath/` — new directory
- `Theories/Bimodal/Boneyard/BXCanonicalQuasimodel/` — new directory
- `Theories/Bimodal/Boneyard/DeadConvergenceProof/` — new directory

**Verification**:
- Root `/Boneyard/` directory no longer exists
- `lake build` succeeds
- `grep -r "DiscreteStaviCompleteness\|NFGameBridge\|DiscreteGameTransfer\|EnrichedClosure" Theories/Bimodal/Metalogic/` returns no import lines

---

### Phase 3: Extract in-file dead blocks from ChronicleToCountermodel [COMPLETED]

**Goal**: Remove the ~700-line dead sorry chain from `ChronicleToCountermodel.lean` and the smaller dead blocks, appending to existing Boneyard file.

**Tasks**:
- [ ] **Task 3.1**: Read `BXCanonical/Chronicle/ChronicleToCountermodel.lean` and identify dead block boundaries: `succ_reaches_dom_N`, `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean` (~lines 83-854 per research) *(deviation: skipped — these are NOT dead; limitDomSubtype_isSuccArchimedean is used by succ_embed_surjective at line 1721, which is on the live call path)*
- [x] **Task 3.2**: Identify the smaller dead block: `z1_formula`, `z1_derivation`, `z1_in_mcs` (~lines 399-412) *(completed)*
- [x] **Task 3.3**: Append extracted declarations to `Boneyard/DeadChronicleGapElimination/` (file already exists from task 301) with provenance comments noting exact source lines *(completed — z1 block only)*
- [x] **Task 3.4**: Remove the dead blocks from `ChronicleToCountermodel.lean` *(deviation: altered — only z1 block removed; large block retained since it is live)*
- [x] **Task 3.5**: Run `lake build` to verify remaining code still compiles

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — remove dead blocks
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/` — append extracted code

**Verification**:
- `lake build` succeeds
- `ChronicleToCountermodel.lean` no longer contains `succ_reaches_dom_N`, `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, `z1_formula`, `z1_derivation`, `z1_in_mcs`

---

### Phase 4: Extract in-file dead blocks from Transfer, ChronicleExtraction, ShiftAndGlue, Completeness [COMPLETED]

**Goal**: Remove remaining in-file dead blocks from 4 live files.

**Tasks**:
- [ ] **Task 4.1**: Remove `countermodel_discrete` (~lines 1249-1298, sorry'd, deprecated) from `WeakCanonical/Transfer.lean` *(deviation: skipped — countermodel_discrete is called by BXCanonical/Completeness.lean:166; not removable)*
- [ ] **Task 4.2**: Remove `countermodel_discrete_reynolds` v1 (~lines 1203-1248, superseded by v2) from `WeakCanonical/Transfer.lean` *(deviation: skipped — there is no v1/v2 distinction; the sole countermodel_discrete_reynolds is live)*
- [x] **Task 4.3**: Add extracted Transfer declarations to a new Boneyard file `Boneyard/DeadChronicleGapElimination/TransferDead.lean` with provenance *(completed — contains extract_chronicle_as_prior, chronicle_is_good, chronicle_is_good_direct, countermodel_discrete_enriched)*
- [x] **Task 4.4**: Remove `extract_chronicle_as_prior` (~lines 168-200, sorry'd) from `WeakCanonical/ChronicleExtraction.lean` *(completed)*
- [x] **Task 4.5**: Remove `chronicle_is_good` and `chronicle_is_good_direct` (~lines 885-1000, dead path) from `WeakCanonical/IntegerModel/ShiftAndGlue.lean` *(completed)*
- [x] **Task 4.6**: Remove `countermodel_discrete_enriched` (~lines 223-250, private, never called) from `BXCanonical/Completeness.lean` *(completed)*
- [x] **Task 4.7**: Run `lake build` to verify clean build

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — remove 2 dead definitions
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` — remove 1 dead definition
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` — remove 2 dead definitions
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — remove 1 dead definition
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/TransferDead.lean` — new file with provenance

**Verification**:
- `lake build` succeeds
- None of the removed definitions appear in the source files

---

### Phase 5: Comment cleanup and Boneyard hygiene [NOT STARTED]

**Goal**: Fix all identified misleading/stale comments and add missing `#exit` guards.

**Tasks**:
- [ ] Fix `Bundle/SuccRelation.lean:596-634`: Correct section heading that says theorems are "derivable under reflexive Until semantics" — all 4 are sorry'd tombstone stubs. Update heading to reflect actual status.
- [ ] Fix `ProofSystem/Axioms.lean:43`: Correct comment that says "density axiom derivable from BX1 under reflexive G" — BX1 is now `serial_future` (seriality), not reflexive G. Update to reflect current semantics.
- [ ] Update `Transfer.lean:1261,1277` (line numbers will shift after Phase 4): Remove references to abandoned tasks 155 and 268 or replace with accurate status
- [ ] Fix `Metalogic/Algebraic/InteriorOperators.lean:83`: Expand terse sorry comment (`temp_k_dist derivable from BX`) with explanation of what blocks the proof
- [ ] Remove stale TODO in `typst/chapters/06-notes.typ:99` referencing completed task 83
- [ ] Remove orphaned "Research-016" references in `DenseSoundness.lean:27` and `DiscreteSoundness.lean:26`
- [ ] Add `#exit` guard to `Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean` (imports live modules without guard)
- [ ] Remove redundant `NOTE: constructor removed` comments in SoundnessLemmas (10+ occurrences, accurate but adding noise)
- [ ] Update Boneyard `README.md` with new subdirectories added in Phases 1-2
- [ ] Run `lake build` to verify final clean build

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — fix misleading heading
- `Theories/Bimodal/ProofSystem/Axioms.lean` — fix false comment
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — update stale task refs
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` — expand sorry comment
- `typst/chapters/06-notes.typ` — remove stale TODO
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` — remove orphaned ref
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` — remove orphaned ref
- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean` — add `#exit` guard
- `Theories/Bimodal/Boneyard/README.md` — update subdirectory listing

**Verification**:
- `lake build` succeeds
- `grep -r "Research-016" Theories/Bimodal/Metalogic/` returns nothing
- `grep -r "task 155\|task 268" Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` returns nothing

## Testing & Validation

- [ ] `lake build` passes after each phase (5 total build checks)
- [ ] No remaining imports reference moved files (grep verification)
- [ ] All new Boneyard files have provenance headers and `#exit` guards
- [ ] Boneyard README updated with new subdirectories
- [ ] Root `/Boneyard/` directory eliminated
- [ ] No misleading comments remain for identified items

## Artifacts & Outputs

- `specs/302_boneyard_dead_code_archival/plans/02_implementation-plan.md` (this file)
- `Theories/Bimodal/Boneyard/KampNegationClosure/` — 4 archived files
- `Theories/Bimodal/Boneyard/RabinovichPath/` — 4 archived files
- `Theories/Bimodal/Boneyard/StaviDiscretePath/` — 3 archived files
- `Theories/Bimodal/Boneyard/BXCanonicalQuasimodel/` — 1 archived file
- `Theories/Bimodal/Boneyard/DeadConvergenceProof/` — 2 relocated files
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/` — appended dead blocks + new TransferDead.lean

## Rollback/Contingency

All changes are file moves and edits within a git repository. If any phase fails:
1. `git checkout -- .` reverts all uncommitted changes
2. Each phase is committed independently, so partial progress is preserved
3. If a moved file turns out to be live (unexpected), `git revert` the relevant phase commit and re-import the file
