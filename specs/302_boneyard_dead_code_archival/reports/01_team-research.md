# Research Report: Task #302

**Task**: boneyard_dead_code_archival
**Date**: 2026-06-16
**Mode**: Team Research (4 teammates)

## Summary

Systematic codebase review identified ~9,900 lines of dead code across 19 standalone files and ~960 lines of in-file dead blocks across 6 files. The largest dead clusters are the Kamp negation closure chain (~4,500 lines, 8 files), the EFGames Stavi discrete path (~3,200 lines, 3 files), and the inline dead sorry chain in ChronicleToCountermodel.lean (~700 lines). Additionally, 5 oversized files (3,500-5,000+ lines each) are strong candidates for splitting, and 8 comment hygiene issues need correction. The BXCanonical directory is NOT entirely dead — several files contain live definitions used by the Chronicle and WeakCanonical paths; only `EnrichedClosure.lean` is a standalone dead file within it.

## Key Findings

### Dead Code Inventory (from Teammate A)

**Standalone dead files — zero live importers (HIGH confidence):**

| Cluster | Files | Lines | Sorries |
|---------|-------|-------|---------|
| Kamp negation closure chain | `NegationClosure.lean`, `NegationClosure5.lean`, `NegationClosureProp42.lean`, `FoToVecEA.lean` | ~3,252 | 2 |
| Kamp Rabinovich chain | `RabinovichNegation.lean`, `RabinovichGeneralized.lean`, `RabinovichWiring.lean`, `RabinovichProp42.lean` | ~1,262 | multiple |
| EFGames Stavi discrete path | `DiscreteStaviCompleteness.lean`, `NFGameBridge.lean`, `DiscreteGameTransfer.lean` | ~3,206 | multiple |
| BXCanonical Quasimodel | `EnrichedClosure.lean` | 158 | 0 |
| **Subtotal** | **12 files** | **~7,878** | |

**In-file dead blocks (HIGH confidence):**

| Location | What | Lines | Sorries |
|----------|------|-------|---------|
| `ChronicleToCountermodel.lean:83-854` | `succ_reaches_dom_N`, `chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean` | ~700 | 6 |
| `ChronicleToCountermodel.lean:399-412` | `z1_formula`, `z1_derivation`, `z1_in_mcs` (private, unused) | ~13 | 0 |
| `BXCanonical/Completeness.lean:223-250` | `countermodel_discrete_enriched` (private, never called) | ~28 | 0 |
| `Transfer.lean:1249-1298` | `countermodel_discrete` (deprecated, sorry'd) | ~50 | 1 |
| `Transfer.lean:1203-1248` | `countermodel_discrete_reynolds` v1 (superseded by v2) | ~45 | 0 |
| `ChronicleExtraction.lean:168-200` | `extract_chronicle_as_prior` (dead, sorry'd) | ~33 | 1 |
| `ShiftAndGlue.lean:885-1000` | `chronicle_is_good`, `chronicle_is_good_direct` (dead path) | ~92 | 0 |
| **Subtotal** | | **~961** | |

**Grand total dead code**: ~8,839 lines in standalone files + ~961 lines in-file = **~9,800 lines**

### File Organization (from Teammate B)

**Oversized files needing splits (>3,000 lines):**

| File | Lines | Split Sections | Importers |
|------|-------|---------------|-----------|
| `EFGames/GapDetection.lean` | 5,057 | 7 natural sections | 2 (best ROI) |
| `Expressiveness/SplitPoint.lean` | 4,693 | 4 sections | TBD |
| `Expressiveness/CaseAnalysis.lean` | 3,749 | 3 sections | TBD |
| `Chronicle/PointInsertion.lean` | 3,527 | 13+ Burgess lemma sections | follows KampBypass pattern |
| `Chronicle/CounterexampleElimination.lean` | 3,487 | 4 sections | TBD |
| `EFGames/StaviCompleteness.lean` | 3,343 | TBD | TBD |

**Boneyard location inconsistency**: Two separate Boneyard locations exist:
- `/Boneyard/DeadConvergenceProof/` (2 files, 446 lines) — NOT under `BoneyardArchive` lean_lib target
- `/Theories/Bimodal/Boneyard/` (42 files, 28,466 lines) — properly under build target

The root-level Boneyard files need to be moved into `Theories/Bimodal/Boneyard/`.

**Other organization issues**:
- `Automation/ProofFirstBenchmark.lean` (167 lines) — orphan: not an exe target, not imported by any library file
- `FormulaEnumerator.lean` (2,212 lines) — clean split boundary at line 1186 between enumeration and axiom instantiation
- Confusing naming: `DataExport.lean` vs `DatasetExport.lean` vs `DatasetExporter.lean` (distinct purposes, similar names)

### Comment Hygiene (from Teammate C)

**HIGH priority:**
- `Bundle/SuccRelation.lean:596-634`: Section heading says theorems are "derivable under reflexive Until semantics" but all 4 theorems are sorry'd TOMBSTONE stubs. Heading contradicts the tombstone comments directly below it.

**MEDIUM priority:**
- `ProofSystem/Axioms.lean:43`: Says "density axiom derivable from BX1 under reflexive G" but BX1 is now `serial_future` (seriality), not reflexive G. Claim is false under current semantics.
- `Transfer.lean:1261,1277`: References abandoned tasks 155 and 268 as providing "the correct/active path"
- `InteriorOperators.lean:83`: Sorry has terse comment (`temp_k_dist derivable from BX`) without explanation of what blocks the proof

**LOW priority:**
- `typst/chapters/06-notes.typ:99`: Stale TODO referencing completed task 83
- `DenseSoundness.lean:27`, `DiscreteSoundness.lean:26`: Orphaned "Research-016" reference (pre-task-system)
- `Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean`: Missing `#exit` guard despite importing live modules
- 10+ `NOTE: constructor removed` comments in SoundnessLemmas (accurate but redundant)

### Strategic Direction (from Teammate D)

**Ordering**: Archive dead code first, then reorganize live code. Reorganizing before archiving risks dragging dead imports into the live tree.

**Critical path protection**: Task 303 (k>0 depth induction) is the SOLE remaining blocker for sorry-free `completeness_discrete`. Nothing in the dead code inventory is on its call path, so archival is safe. However, everything under `WeakCanonical/` and `Chronicle/` must NOT be touched.

**Build performance**: Removing ~9,800 lines of dead code (especially Quasimodel files with heavy Mathlib imports) could yield 10-20% build time improvement.

**Boneyard policy**: Continue existing topic-based subdirectory convention. Each subdirectory represents one dead architectural attempt, not a mirror of the original module tree.

## Synthesis

### Conflicts Resolved

**Conflict 1: Is BXCanonical entirely dead?**
- Teammate D characterized the "entire BXCanonical non-Chronicle subtree" as dead (19 sorries, task 109 abandoned)
- Teammate A traced imports and found that `Frame.lean`, `TruthLemma.lean`, `CanonicalChain.lean`, `OrderedSeedConsistency.lean`, `CanonicalModel.lean`, and most Quasimodel files are LIVE — they export definitions used by `WeakCanonical/Transfer.lean`, `WeakCanonical/ReflexiveCanonical.lean`, and `Chronicle/ChronicleToCountermodelBasic.lean`

**Resolution**: Teammate A's import-tracing evidence is more specific and reliable. The BXCanonical directory contains a MIX of live definitions (used by the active completeness path) and dead sorry'd definitions (invalid under irreflexive semantics). Only `EnrichedClosure.lean` is a standalone dead file within it. The sorry'd definitions within live files (like `bx_le_refl` in Frame.lean) should be marked with tombstone comments but NOT archived, since the files themselves are imported for their live exports.

**Conflict 2: Bundle/SuccRelation and SuccExistence — dead or live?**
- Teammate D identified these as archival targets (ROADMAP item 4)
- Teammate A did not list them as dead files
- Teammate D noted `SuccRelation` is imported by both live and dead files

**Resolution**: These need a dependency trace before any archival decision. The Bundle files may contain both live and dead definitions. Defer to implementation phase (Cluster D in the ordering).

### Gaps Identified

1. **Filtration/SigmaOrdering.lean** (167 lines, 3 sorries): Teammate A listed DefectChain.lean as live but did not assess SigmaOrdering.lean separately. It is imported by DefectChain, so it is transitively live.

2. **RootScopedChain.lean** (1,487 lines, 5 critical-path sorries): Not discussed by any teammate as an archival candidate. This file IS on the BXCanonical completeness path (not the Reynolds/Chronicle path). Needs clarification: is the BXCanonical `Completeness.lean` → `RootScopedChain.lean` path still the official completeness theorem, or has it been fully superseded by the Reynolds pipeline? If superseded, the 5 sorry sites are dead.

3. **Build profiling**: No teammate ran `lake build` timing or `lean_profile_proof`. The 10-20% build improvement estimate from Teammate D is unverified.

4. **Test coverage impact**: No teammate assessed whether removing dead Kamp files or EFGames Stavi discrete files would break any test expectations (though Teammate C confirmed no tests directly import BXCanonical).

### Recommendations

**Phase 1 — Standalone dead file archival (lowest risk, highest volume):**
1. Archive 8 dead Kamp files → `Boneyard/KampNegationClosure/` and `Boneyard/RabinovichPath/`
2. Archive 3 dead EFGames files → `Boneyard/StaviDiscretePath/`
3. Archive `EnrichedClosure.lean` → `Boneyard/BXCanonicalQuasimodel/`
4. Move root `/Boneyard/DeadConvergenceProof/` → `Theories/Bimodal/Boneyard/DeadConvergenceProof/`
5. Update aggregator imports, run `lake build`

**Phase 2 — In-file dead block extraction (surgical, medium risk):**
1. Extract dead sorry chain from `ChronicleToCountermodel.lean` (lines 83-854) → append to `Boneyard/DeadChronicleGapElimination/`
2. Remove `countermodel_discrete_enriched` from `Completeness.lean`
3. Remove deprecated `countermodel_discrete` and dead v1 `countermodel_discrete_reynolds` from `Transfer.lean`
4. Remove `extract_chronicle_as_prior` from `ChronicleExtraction.lean`
5. Remove `chronicle_is_good`/`chronicle_is_good_direct` from `ShiftAndGlue.lean`
6. Run `lake build`

**Phase 3 — Comment cleanup:**
1. Fix `SuccRelation.lean:596` section heading (misleading "derivable")
2. Fix `Axioms.lean:43` density comment (false under current semantics)
3. Update stale task references in `Transfer.lean` (tasks 155, 268 abandoned)
4. Remove stale TODO in typst file
5. Add `#exit` guard to `Boneyard/BXPipelineDeadCode/ReynoldsModelSurgery.lean`
6. Remove orphaned "Research-016" references

**Phase 4 — File splits (large scope, separate task recommended):**
1. Split `GapDetection.lean` (5,057 lines, 7 sections, 2 importers — best ROI)
2. Split `PointInsertion.lean` (3,527 lines, 13+ sections — KampBypass pattern)
3. Split `FormulaEnumerator.lean` at line 1186 (clean boundary)
4. Assess remaining 3,000+ line files

**Phase 5 — Bundle dependency trace (deferred):**
1. Trace `SuccRelation.lean` and `SuccExistence.lean` dependencies
2. Determine which definitions are live vs dead
3. Archive dead definitions if separable

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Dead code identification | completed | high |
| B | File organization and sizing | completed | high |
| C | Comment quality and code hygiene | completed | high |
| D | Strategic horizons and risk | completed | high |

## References

- ROADMAP.md lines 34, 59-63: Dead code documentation (chronicle_gap_contradiction, succ_cofinal)
- ROADMAP.md lines 1419-1421: Explicit archival candidate list
- Task 301: Prior dead code cleanup (VecEADecomposition, KampBypass split, DeadChronicleGapElimination)
- Task 109: BXCanonical path (abandoned)
- Task 113: BX8/BX9 removal (open guard semantics)
- Task 93: Irreflexive semantics switch
