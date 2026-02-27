# Research Findings: Teammate A - Terminology Analysis and Current Patterns

## Task 928: Refactor metalogic terminology (BMCS->BFMCS, FMCS, MCS) and archive to Boneyard

**Date**: 2026-02-25
**Focus**: Terminology usage analysis, task 925 review, naming recommendations

---

## Key Findings

1. **Task 925 Phase 1 was partial**: It created an `FMCS` type alias (`abbrev FMCS := BFMCS`) and updated docstrings, but did NOT rename `BFMCS` to `FMCS` throughout the codebase. The underlying Lean structure is still `BFMCS`. BFMCS appears 264 times across 20 active metalogic files.

2. **Task 925 Phase 2 was SKIPPED entirely**: `CoherentConstruction.lean` remains in active code (`Theories/Bimodal/Metalogic/Bundle/`), NOT moved to Boneyard. It contains `constantBFMCS`, `IsConstantFamily`, `constantWitnessFamily`, and 63+ BFMCS occurrences. The plan explicitly said "Move CoherentConstruction.lean entirely to Boneyard" but this was never done.

3. **The "B" in BFMCS is ambiguous and confusing**: The current BFMCS.lean docstring explains that "B" historically stood for "Bundled" (Lean4 bundling pattern), but the task 928 description wants it to mean "Bundle of FMCSs". This creates a naming collision: BFMCS could mean "Bundled Family of MCS" (current) OR "Bundle of FMCSs" (proposed). The current `BMCS` already serves as the "bundle of families" concept.

4. **README files are outdated**: Both `Bundle/README.md` and `Metalogic/README.md` still reference `IndexedMCSFamily` (the pre-task-914 name). The architecture diagrams show `IndexedMCSFamily.lean` which was renamed to `BFMCS.lean` in task 914. LaTeX and Typst files also reference `IndexedMCSFamily`.

5. **The sorry-free completeness chain is in `ChainBundleBMCS.lean`**: This file uses `BFMCS` 14 times and `BMCS` 26 times. The new chain is self-contained and does not depend on the legacy files with sorries.

---

## Terminology Mapping (Current State)

### Definitions in Lean Code

| Term | File | Lean Definition | Semantic Meaning |
|------|------|----------------|------------------|
| `BFMCS D` | BFMCS.lean:84 | `structure BFMCS where mcs : D -> Set Formula ...` | A SINGLE time-indexed family of MCS with temporal coherence (forward_G, backward_H) |
| `FMCS` | FMCS.lean:36 | `abbrev FMCS := BFMCS` | Type alias for BFMCS, preferred for new code |
| `BMCS D` | BMCS.lean:87 | `structure BMCS where families : Set (BFMCS D) ...` | A BUNDLE (set) of BFMCS families with modal coherence conditions |
| `CanonicalBC` | ChainBundleBMCS.lean:140 | `structure CanonicalBC (BC : Set Formula) where ...` | An MCS with a specific BoxContent |
| `CanonicalMCS` | CanonicalFrame.lean | (defined elsewhere) | All maximal consistent sets with CanonicalR preorder |
| `ChainFMCSDomain` | ChainFMCS.lean | Flag-based domain type | A maximal chain (Flag) in CanonicalMCS |
| `IsConstantFamily` | CoherentConstruction.lean:214 | `def IsConstantFamily (fam : BFMCS D) : Prop` | Family where all time points map to the same MCS |
| `TemporalCoherentFamily` | TemporalCoherentConstruction.lean | extends BFMCS with forward_F/backward_P | BFMCS with additional temporal existential witnesses |

### Intended vs Actual Naming

| Concept | Task 928 Intended Name | Current Name | Status |
|---------|----------------------|--------------|--------|
| Single time-indexed family of MCS | FMCS | `BFMCS` (structure), `FMCS` (alias) | Partially done - alias exists but not used broadly |
| Bundle of families | BMCS | `BMCS` | Correct and consistent |
| Bundle of FMCSs | BFMCS (new meaning) | N/A | NOT IMPLEMENTED - would conflict with current BFMCS |
| Maximal Consistent Set | MCS | `SetMaximalConsistent` (predicate), `CanonicalMCS` (type) | Consistent usage |

### Usage Count by File (Active Metalogic Only)

| File | BFMCS count | FMCS count | BMCS count |
|------|-------------|------------|------------|
| BFMCS.lean | 20 | 4 | 2 |
| BMCS.lean | 13 | 3 | 19 |
| FMCS.lean | 7 | 11 | 2 |
| ChainBundleBMCS.lean | 14 | 1 | 26 |
| ChainFMCS.lean | 2 | 15 | 4 |
| CanonicalBFMCS.lean | 23 | 0 | 0 |
| Construction.lean | 8 | 0 | 17 |
| ModalSaturation.lean | 8 | 0 | 26 |
| TruthLemma.lean | 9 | 0 | 26 |
| Completeness.lean | 2 | 0 | 45 |
| CoherentConstruction.lean | 63 | 0 | 19 |
| TemporalCoherentConstruction.lean | 10 | 0 | 40 |
| DovetailingChain.lean | 11 | 0 | 0 |
| BMCSTruth.lean | 31 | 0 | 37 |
| WitnessGraph.lean | 20 | 0 | 0 |
| CanonicalEmbedding.lean | 5 | 0 | 0 |
| CanonicalReachable.lean | 4 | 0 | 0 |
| CanonicalQuotient.lean | 1 | 0 | 0 |
| Representation.lean | 12 | 0 | 33 |
| Metalogic.lean | 1 | 0 | 12 |

**Totals**: BFMCS: 264, FMCS: 34, BMCS: 360, MCS: 677

---

## Task 925 Implementation Review

### Phase 1: Terminology Refactoring -- COMPLETED (Partially)

**What was done**:
- Created `FMCS.lean` with `abbrev FMCS := BFMCS`
- Updated docstrings in BFMCS.lean and BMCS.lean to explain terminology
- Did NOT rename the actual `BFMCS` structure to `FMCS`
- Did NOT update files to use `FMCS` instead of `BFMCS`

**Why partial**: The implementation notes say "FMCS alias approach avoids `extends`/`toBFMCS` breakage across 20+ files." This was a pragmatic decision to avoid breaking the codebase, but it means the terminology refactoring is incomplete.

### Phase 2: Constant Family Elimination (Boneyard) -- NOT STARTED

**What was NOT done**:
- `CoherentConstruction.lean` was NOT moved to Boneyard
- `constantBFMCS` in Construction.lean was NOT moved
- `constantWitnessFamily`, `constructWitnessFamily` in ModalSaturation.lean were NOT moved
- No `Boneyard/Bundle/ConstantFamilies.lean` was created
- Constant family references remain in active code

**Impact**: Low for completeness (the sorry-free chain in ChainBundleBMCS.lean does not use these), but the active codebase still contains dead/legacy code.

### Phase 6: Timeshift Closure -- N/A

**The plan's Phase 6 goal**: "Establish BFMCS closed under timeshift". However, the Phase 6 progress notes clarify this is NOT applicable to Flag-based families. The task 928 description says to "correct Phase 6 goal to establish BFMCS closed under timeshift (not FMCS)" -- but even the correction is misleading since timeshift closure was found to be inapplicable to any of the constructions.

---

## Recommended Terminology Changes

### Option A: Minimal Rename (Recommended)

Keep the current approach but complete it properly:

1. **FMCS** = Family of MCS (single family). Already aliased. Should become the PRIMARY name.
2. **BMCS** = Bundle of MCS (bundle of families). Already correct.
3. **Do NOT introduce "BFMCS" as a new concept meaning "Bundle of FMCSs"** -- this would be confusing because `BFMCS` already exists as the structure name for a single family. The term `BMCS` already serves this purpose.
4. Rename `BFMCS` structure to `FMCS` across the codebase (true rename, not just alias)
5. Rename `CanonicalBFMCS.lean` to `CanonicalFMCS.lean`

**Rationale**: The task description says "Rename BMCS to BFMCS throughout to clarify it is a Bundle of FMCSs." However, `BMCS` already clearly means "Bundle of MCS" and the `BFMCS` name is already taken by the single-family structure. Renaming BMCS to BFMCS would create confusion rather than clarity.

### Option B: Full Rename Per Task Description

Follow the task description literally:

1. **MCS** = Maximal Consistent Set (single set). Already correct.
2. **FMCS** = Family of MCS (single family). Rename current `BFMCS` structure to `FMCS`.
3. **BFMCS** = Bundle of FMCSs (what is currently `BMCS`). Rename `BMCS` structure to `BFMCS`.
4. Remove old `BMCS` name.

**Risk**: This is a massive rename (624+ occurrences of BFMCS + BMCS), and the resulting naming where "BFMCS" means "bundle" is counter-intuitive because it looks like "B-FMCS" (a modified FMCS) rather than "bundle of FMCSs."

### Recommendation: Option A

Option A is clearer, less risky, and achieves the core goal of making terminology unambiguous. The key insight is:
- `FMCS` = one family (clear)
- `BMCS` = bundle of families (already clear)
- There is no need for a third term.

---

## Files Requiring Updates

### Priority 1: Active Lean Files (Terminology)

If proceeding with Option A (rename BFMCS -> FMCS):

| File | Changes Needed | Occurrence Count |
|------|---------------|-----------------|
| `BFMCS.lean` | Rename structure `BFMCS` to `FMCS`, keep file as canonical definition | 20 |
| `FMCS.lean` | Remove (becomes unnecessary once BFMCS is renamed) | N/A |
| `BMCS.lean` | Change `Set (BFMCS D)` to `Set (FMCS D)` in families field | 13 |
| `BMCSTruth.lean` | Replace BFMCS references | 31 |
| `TruthLemma.lean` | Replace BFMCS references | 9 |
| `Construction.lean` | Replace BFMCS references | 8 |
| `ModalSaturation.lean` | Replace BFMCS references | 8 |
| `Completeness.lean` | Replace BFMCS references | 2 |
| `ChainBundleBMCS.lean` | Replace BFMCS references | 14 |
| `ChainFMCS.lean` | Replace BFMCS references (mostly already FMCS) | 2 |
| `CanonicalBFMCS.lean` | Rename file to CanonicalFMCS.lean, rename references | 23 |
| `CoherentConstruction.lean` | Move to Boneyard OR rename references | 63 |
| `TemporalCoherentConstruction.lean` | Replace BFMCS references | 10 |
| `DovetailingChain.lean` | Replace BFMCS references | 11 |
| `WitnessGraph.lean` | Replace BFMCS references | 20 |
| `CanonicalEmbedding.lean` | Replace BFMCS references | 5 |
| `CanonicalReachable.lean` | Replace BFMCS references | 4 |
| `CanonicalQuotient.lean` | Replace BFMCS references | 1 |
| `Representation.lean` | Replace BFMCS references | 12 |
| `Metalogic.lean` | Replace BFMCS references | 1 |

**Total**: ~264 BFMCS occurrences across 20 files.

### Priority 2: Boneyard Cleanup (Phase 2 of Task 925)

Files to move from `Metalogic/Bundle/` to `Boneyard/Bundle/`:

| File | Reason | Notes |
|------|--------|-------|
| `CoherentConstruction.lean` | Contains dead constant-family code, 63 BFMCS refs | Move entirely; only imported by TemporalCoherentConstruction.lean |
| `WitnessGraph.lean` | Legacy witness graph approach | Check if still imported |

Definitions to move to Boneyard:
| Definition | Current File | Reason |
|-----------|-------------|--------|
| `constantBFMCS` | Construction.lean:91 | Constant families eliminated by task 925 |
| `constantWitnessFamily` | ModalSaturation.lean:250 | Dead code |
| `constructWitnessFamily` | ModalSaturation.lean:277 | Dead code |

### Priority 3: Documentation Updates

| File | Issues |
|------|--------|
| `Bundle/README.md` | References `IndexedMCSFamily.lean` (renamed to BFMCS.lean in task 914); architecture diagram outdated; sorry counts outdated |
| `Metalogic/README.md` | References `IndexedMCSFamily` (line 66, 156); architecture diagrams outdated; sorry counts outdated |
| `typst/chapters/04-metalogic.typ` | References `IndexedMCSFamily D` (lines 148-149, 419, 555) |
| `latex/subfiles/04-Metalogic.tex` | References `IndexedMCSFamily D` (lines 142-144, 393, 486) |

---

## Confidence Level

- **Terminology analysis**: HIGH -- All files were scanned and counted systematically
- **Task 925 review**: HIGH -- Plan, progress notes, and summary all reviewed against actual code state
- **Naming recommendation**: MEDIUM -- Option A vs B is a design decision; recommending A based on clarity and risk analysis
- **File change estimates**: HIGH -- Based on exact grep counts
- **Boneyard status**: HIGH -- CoherentConstruction.lean confirmed still in active code

---

## Appendix: Relationship Between Concepts

```
MCS (Maximal Consistent Set)
  = A single set of formulas that is consistent and maximal
  = Lean: SetMaximalConsistent (predicate), CanonicalMCS (bundled type)

BFMCS/FMCS (Family of MCS)
  = A function mcs : D -> Set Formula assigning an MCS to each time point
  = With temporal coherence: forward_G, backward_H
  = Lean: structure BFMCS, alias FMCS

BMCS (Bundle of MCS families)
  = A set of BFMCS/FMCS families with modal coherence (forward/backward)
  = Lean: structure BMCS (families : Set (BFMCS D))

CanonicalBC (MCS with fixed BoxContent)
  = Used as domain in sorry-free completeness chain
  = Each element has the same BoxContent = BC
```

```
Completeness Architecture:

LEGACY CHAIN (has sorries):
  Construction.lean -> TemporalCoherentConstruction.lean -> TruthLemma.lean -> Completeness.lean
  (singleFamilyBMCS   (fully_saturated_bmcs_exists_int   (bmcs_truth_lemma)  (bmcs_weak/strong
   has sorry)           has sorry)                                             _completeness)

SORRY-FREE CHAIN:
  ChainBundleBMCS.lean
  (chainBundleBMCS -> bmcs_truth_lemma_mcs -> fully_saturated_bmcs_exists_CanonicalBC
   -> bmcs_representation_mcs -> bmcs_weak_completeness_mcs -> bmcs_strong_completeness_mcs)
```
