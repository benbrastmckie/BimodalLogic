# Teammate D Findings: Strategic Horizons

**Task**: 302 — Boneyard Dead Code Archival
**Focus**: Strategic direction and long-term alignment

---

## Key Findings

### 1. Critical Path Risk: Task 303 Must Be Protected

The ROADMAP is unambiguous: there is ONE sorry blocking `completeness_discrete`, and it lives at `KampBypass.lean` (k>0 case). The entire live proof chain runs through the Reynolds pipeline (`countermodel_discrete_reynolds_v2`), which bypasses BXCanonical entirely.

**Dead code that is safe to archive NOW (pre-task-303)**:

- `chronicle_gap_contradiction` and `succ_cofinal` in `ChronicleToCountermodel.lean` (~10 sorries): ROADMAP explicitly identifies these as dead code, not on any live call path.
- The entire BXCanonical non-Chronicle subtree (`Frame.lean`, `TruthLemma.lean`, `CanonicalModel.lean`, `OrderedSeedConsistency.lean`, `Quasimodel/Construction.lean`, `Quasimodel/Realization.lean`, `Filtration/DefectChain.lean`, ~19 sorries): task 109 is abandoned and these files contain mathematically false sorries under irreflexive semantics. The `Completeness.lean` now imports only `Chronicle/` and `WeakCanonical/` — the BXCanonical aggregator (`BXCanonical.lean`) still pulls in the quasimodel files, but none of them contribute to the live completeness proof.
- `Bundle/SuccRelation.lean` (~7 sorries) and `Bundle/SuccExistence.lean` (~3 sorries): ROADMAP recommendation item 4 explicitly names these as targets. `SuccRelation` is only imported by `UntilSinceCoherence`, `CanonicalTaskRelation`, and `CanonicalIrreflexivity` — all of which feed the dead BXCanonical path, not the Reynolds pipeline.

**Code that must NOT be archived before task 303 completes**:

- Anything under `WeakCanonical/`, including `Transfer.lean` (18 sorries, ON the critical path through `countermodel_discrete_reynolds_v2`)
- `Bundle/UntilSinceCoherence.lean` — imported by `ChronicleToCountermodelBasic.lean` which is on the live path
- `Bundle/SuccExistence.lean` — imported by `Core/RestrictedMCS/Basic.lean` and `Core/RestrictedMCS/Deferral.lean`; unclear if these are live
- All `Chronicle/` files — active completeness path

**Confidence**: High. The ROADMAP sorry chain section and `lean_verify` output cited there directly confirm which paths are live.

---

### 2. Boneyard Policy Recommendation: Mirror Original Module Structure

The existing Boneyard already uses subdirectories that mirror original module paths (e.g., `Boneyard/StrictSemanticsLegacy/Algebraic/`, `Boneyard/DenseChronicle/`, `Boneyard/QuasimodelOracle/`). This pattern should be continued for consistency.

Recommended policy:

- **Subdirectory per dead architectural attempt**, not per original file location. Example: all dead BXCanonical non-Chronicle files go to `Boneyard/BXCanonicalPipeline/` rather than mirroring `BXCanonical/Quasimodel/` inside Boneyard.
- **Top-of-file provenance comment** with: original location, date archived, task number, reason ("mathematically false under irreflexive semantics", "superseded by Reynolds bypass", etc.).
- **Flat within each subdirectory** when the original files are a coherent cluster (e.g., the BXCanonical quasimodel group).

**Rationale**: The Boneyard is a historical archive, not a parallel codebase. Readers should be able to identify what dead end each subdirectory represents without navigating a mirrored tree.

**Confidence**: Medium (aesthetic/convention choice).

---

### 3. Build Performance Estimate

Current sorry-laden dead code that compiles but is provably worthless:

| Cluster | Files | Lines (approx) | Sorry Count |
|---------|-------|-----------------|-------------|
| BXCanonical Quasimodel+Filtration | 7 | ~2,500 | 13 |
| BXCanonical Frame/TruthLemma/CanonicalModel | 3 | ~1,550 | 5 |
| ChronicleToCountermodel dead chain | 1 (partial) | ~400 (dead section) | 5 |
| Bundle/SuccRelation + SuccExistence | 2 | ~1,827 | 10 |
| Bundle/UntilSinceCoherence | 1 | 211 | 2 |
| **Total** | **~14** | **~6,500** | **~35** |

Removing 6,500 lines of dead code with many Mathlib imports (the Quasimodel files import `Mathlib.Data.Finset.Powerset`, `Mathlib.Data.List.Chain`, etc.) could meaningfully reduce build times. The BXCanonical Quasimodel is particularly heavy — `Construction.lean` (841 lines) and `Realization.lean` (493 lines) both import significant Mathlib machinery. Conservative estimate: 10–20% build time reduction.

**Confidence**: Medium. Build time profiling would be needed for a precise estimate.

---

### 4. Cleanup Ordering: Archive Dead Code First, Then Reorganize

The correct ordering is:

1. **Archive dead code first** — removes the noisy sorry-laden files that obscure the codebase structure
2. **Confirm build passes** after each archival cluster
3. **Reorganize remaining live code** (e.g., task 176: move Chronicle/ out of BXCanonical/) only after dead code is removed

**Rationale**: Reorganizing before archiving risks accidentally breaking the archived/live boundary. If you move a file while it still imports dead code, you may drag dead imports into the live tree. Archive → verify build → reorganize is the safe order.

**Risk mitigation**: Archive one cluster at a time. The clusters are:
1. Inline dead sorries in `ChronicleToCountermodel.lean` (chronicle_gap_contradiction, succ_cofinal sections) — can be extracted without breaking the file's live exports
2. BXCanonical Quasimodel+Filtration group (7 files) — remove from `BXCanonical.lean` aggregator, verify build
3. BXCanonical Frame/TruthLemma/CanonicalModel group — verify these are not imported by live Chronicle files first
4. Bundle dead files — verify RestrictedMCS dependency chain

**Confidence**: High.

---

### 5. Adjacent Opportunities: Phase 2 Axiom Cleanup NOT Entangled

The ROADMAP Phase 2 items (task 126 frame hierarchy, task 124 TF removal, task 115 A4a removal, task 116 G/H redefinition) depend on sorry-free completeness being established first. None of them depend on the dead BXCanonical infrastructure. Archiving dead code now does not advance or risk Phase 2 — they are orthogonal operations.

One genuine adjacent opportunity: **the Boneyard archival naturally forces clarification of which Bundle files are live**. `Bundle/SuccRelation.lean` is imported by both live files (`CanonicalIrreflexivity.lean`, `CanonicalTaskRelation.lean`) and dead files (`UntilSinceCoherence.lean`, `ChainCompleteness/DeterministicChain.lean`). Before archiving `SuccRelation`, the implementer must trace whether the live importers actually use any sorry-free content from it, or whether those importers are themselves dead. This trace would produce a cleaner dependency map that benefits future Phase 2 refactoring.

**Confidence**: High.

---

### 6. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Archiving a file that task 303 needs | Low | High | Verify using `lean_verify` on `completeness_discrete`; sorry chain is fully documented in ROADMAP |
| Import breakage from removing BXCanonical aggregator content | Medium | Low | Remove imports from `BXCanonical.lean` one file at a time; `lake build` after each |
| Accidentally breaking ChronicleToCountermodel.lean live exports when excising dead sections | Medium | High | Extract dead sections (`chronicle_gap_contradiction`, `succ_cofinal` and their private helpers) into a new Boneyard file rather than editing the existing file in place; redirect any callers |
| Build cache invalidation causing long rebuilds | Certainty | Low | Expected, not a risk — clean build after major file moves is normal |
| Phase 2 code "dead" today becoming live later | Low | Medium | DenseChronicle in Boneyard is already tagged for reuse; document other archived files similarly |

---

## Recommended Approach

**Archive in four independent clusters, sequentially, with build verification between each:**

**Cluster A — Inline dead sorries in ChronicleToCountermodel.lean** (smallest scope, highest signal):
Extract `chronicle_gap_contradiction`, `succ_cofinal`, `succ_embed_surjective` (if only used by the dead chain), and related private helpers into `Boneyard/DeadChronicleGapElimination/` (or similar). Add a tombstone comment in `ChronicleToCountermodel.lean` at the extraction point. This removes ~5 sorries from the active tree with minimal file disruption.

**Cluster B — BXCanonical Quasimodel+Filtration group** (~13 sorries):
Move `Quasimodel/{Construction, Realization, LocusControl}.lean` and `Filtration/DefectChain.lean` to `Boneyard/BXCanonicalPipeline/Quasimodel/` and `Boneyard/BXCanonicalPipeline/Filtration/`. Remove corresponding imports from `BXCanonical.lean`. `HintikkaPoint`, `SubformulaClosure`, and `EnrichedClosure` have no sorries and may be useful for Phase 2 FMP work — keep them or move them separately with a "potentially reusable" note.

**Cluster C — BXCanonical Frame/TruthLemma/CanonicalModel** (~5 sorries):
First verify that `ChronicleTypes.lean` and `PointInsertion.lean` (which import only `BXCanonical.Frame`) do not break. If `Frame.lean` exports are still needed by live Chronicle files, keep Frame.lean but mark the sorry'd `bx_le_refl` with a tombstone comment.

**Cluster D — Bundle dead files**:
After establishing which Bundle files are truly unused by the live Reynolds pipeline (requires dependency trace), move unused files to `Boneyard/BundleSuccRelation/`.

**This ordering keeps task 303 safe at every step.** After each cluster, `#check completeness_discrete` (or `lake build` scoped to the completeness module) confirms the critical path is intact.

---

## Evidence / Examples

- ROADMAP.md lines 34, 59-63: "The old sorry chain through chronicle_gap_contradiction → succ_cofinal → succ_embed_surjective is DEAD CODE — not on any live call path"
- ROADMAP.md lines 1419-1421: Explicit list of archival candidates including "succ_cofinal, Bundle/SuccRelation, Bundle/SuccExistence, Bundle/UntilSinceCoherence, BXCanonical/Frame, BXCanonical/Chronicle dead sorries"
- `Completeness.lean` imports only `Chronicle/ChronicleToCountermodel`, `Chronicle/MCSMixedCase`, `WeakCanonical`, and `Semantics/Validity` — the BXCanonical quasimodel infrastructure is NOT in the live completeness import chain
- `BXCanonical.lean` aggregator imports the Quasimodel group, but `BXCanonical.lean` is only imported by `Metalogic.lean` as an aggregator; removing quasimodel files from `BXCanonical.lean` and from `Metalogic.lean` would cleanly remove them from the build

---

## Confidence Level

- Archive ordering recommendation: **High**
- Cluster A (chronicle_gap_contradiction dead sorries): **High**
- Cluster B (Quasimodel+Filtration): **High** — no live imports to these from Completeness.lean
- Cluster C (Frame/TruthLemma/CanonicalModel): **Medium** — need to verify ChronicleTypes dependency on Frame
- Cluster D (Bundle/SuccRelation etc.): **Medium** — dependency trace required first
- Build performance estimate: **Medium** (empirical measurement needed)
- Boneyard naming policy: **Medium** (convention choice, already partially established)
