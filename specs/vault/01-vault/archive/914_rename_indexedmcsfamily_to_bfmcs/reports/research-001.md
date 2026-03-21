# Research Report: Task #914

**Task**: Rename IndexedMCSFamily to BFMCS across codebase
**Date**: 2026-02-20
**Focus**: Understand IndexedMCSFamily structure, all usage patterns, import dependencies, and BFMCS naming convention rationale for safe rename across the codebase

## Summary

`IndexedMCSFamily` is a 4-field Lean structure representing a temporally coherent chain of maximal consistent sets indexed by time, constituting a single "world history" in the completeness proof. It has 204 occurrences across 12 active Lean files and 198 occurrences across 20 Boneyard Lean files, plus 17 occurrences in 2 old Boneyard files outside `Theories/`. The rename to `BFMCS` (Bundled Family of Maximal Consistent Sets) is straightforward with no name collisions, but requires careful import path updates and file rename coordination.

## Findings

### 1. IndexedMCSFamily Structure Definition

Defined in `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean`, the structure has 4 fields:

```lean
structure IndexedMCSFamily where
  mcs : D -> Set Formula                    -- MCS assignment per time point
  is_mcs : forall t, SetMaximalConsistent (mcs t)  -- Each is an MCS
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

**Semantic meaning**: Each `IndexedMCSFamily` is a single world history -- one MCS per time point with temporal coherence constraints. The `BMCS` structure then bundles multiple `IndexedMCSFamily` instances together with modal coherence constraints. This is the two-level ontological structure:

```
BMCS  =  { BFMCS_1, BFMCS_2, ... }   -- modal bundle (possible worlds)
BFMCS_i = { MCS_t | t in D }           -- temporal family (one world history)
```

### 2. Namespace Members (IndexedMCSFamily.*)

The following are defined in the `IndexedMCSFamily` namespace (all in `IndexedMCSFamily.lean`):

| Member | Kind | Description |
|--------|------|-------------|
| `.at` | def | Get MCS at specific time |
| `.consistent` | lemma | MCS at any time is consistent |
| `.maximal` | lemma | MCS at any time is maximal |
| `.forward_G_chain` | lemma | G phi propagation (wrapper) |
| `.backward_H_chain` | lemma | H phi propagation (wrapper) |
| `.GG_to_G` | lemma | GG phi implies G phi at future |
| `.HH_to_H` | lemma | HH phi implies H phi at past |
| `.theorem_mem` | lemma | Theorems in every MCS |
| `.G_implies_future_phi` | lemma | Restatement of forward_G |
| `.H_implies_past_phi` | lemma | Restatement of backward_H |

All of these will be renamed to `BFMCS.*`.

### 3. Related Identifiers

Several other identifiers reference `IndexedMCSFamily` directly:

| Identifier | File | Occurrences | Rename To |
|------------|------|-------------|-----------|
| `constantIndexedMCSFamily` | Construction.lean | 13 across 4 files | `constantBFMCS` |
| `constantIndexedMCSFamily_mcs_eq` | Construction.lean | refs in CoherentConstruction | `constantBFMCS_mcs_eq` |
| `constantIndexedMCSFamily_is_constant` | CoherentConstruction.lean | refs in CoherentConstruction | `constantBFMCS_is_constant` |
| `constantWitnessFamily` | ModalSaturation.lean | 6 across 2 files | Keep (no "IndexedMCSFamily" in name) |
| `singleFamilyBMCS` | Construction.lean | 6 across 2 files | Keep (no "IndexedMCSFamily" in name) |
| `IsConstantFamily` | CoherentConstruction.lean | ~30 across 2 files | Keep (no "IndexedMCSFamily" in name) |
| `TemporalCoherentFamily` | TemporalCoherentConstruction.lean | 15 across 3 files | Keep, but update `extends IndexedMCSFamily` to `extends BFMCS` |
| `toIndexedMCSFamily` | TemporalCoherentConstruction.lean | 9 across 3 files | `toBFMCS` |

### 4. Active Source File Inventory (12 files, 204 occurrences)

Files are listed in import dependency order (leaf -> root):

| File | Occurrences | Import of IndexedMCSFamily | Usage Types |
|------|-------------|---------------------------|-------------|
| `Bundle/IndexedMCSFamily.lean` | 14 | Self (definition file) | Structure def, namespace members |
| `Bundle/BMCS.lean` | 11 | Direct import | Type references in BMCS fields |
| `Bundle/Construction.lean` | 13 | Direct import | `constantIndexedMCSFamily` def |
| `Bundle/ModalSaturation.lean` | 9 | Direct import | `constantWitnessFamily` returns it |
| `Bundle/BMCSTruth.lean` | 31 | Direct import | Parameters in truth defs |
| `Bundle/CoherentConstruction.lean` | 80 | Direct import | Heaviest user (CoherentBundle, witnesses) |
| `Bundle/DovetailingChain.lean` | 6 | Direct import | Chain construction |
| `Bundle/TemporalCoherentConstruction.lean` | 14 | Direct import | `TemporalCoherentFamily extends IndexedMCSFamily` |
| `Bundle/TruthLemma.lean` | 11 | Direct import | Parameters in truth lemma |
| `Bundle/Completeness.lean` | 2 | Transitive (via BMCS) | Type references |
| `Metalogic.lean` | 1 | No import | Comment only |
| `Representation.lean` | 12 | Transitive (via BMCS, TruthLemma) | Parameters in representation |

### 5. Boneyard File Inventory (20 files, 198 occurrences)

Two import path patterns exist:

**Pattern A**: `import Bimodal.Metalogic.Bundle.IndexedMCSFamily` (9 files)
- `Boneyard/Bundle/SaturatedConstruction.lean` (43 occurrences)
- `Boneyard/Bundle/WeakCoherentBundle.lean` (34)
- `Boneyard/Bundle/RecursiveSeed/Builder.lean` (10)
- `Boneyard/Bundle/FinalConstruction.lean` (9)
- `Boneyard/Bundle/SeedBMCS.lean` (8)
- `Boneyard/Bundle/ZornFamily.lean` (8)
- `Boneyard/Bundle/UnifiedChain.lean` (5)
- `Boneyard/Bundle/SeedCompletion.lean` (5)
- `Boneyard/Bundle/TemporalChain.lean` (5)
- `Boneyard/Bundle/PreCoherentBundle.lean` (5)
- `Boneyard/Bundle/TemporalLindenbaum.lean` (1)

**Pattern B**: `import Bimodal.Metalogic.Representation.IndexedMCSFamily` (3 active + 2 commented)
- `Boneyard/Metalogic_v5/Representation/CanonicalHistory.lean` (12)
- `Boneyard/Metalogic_v5/Representation/CoherentConstruction.lean` (13)
- `Boneyard/Metalogic_v5/Representation/UniversalCanonicalModel.lean` (8)
- `Boneyard/Metalogic_v5/Representation/TruthLemma.lean` (8) - commented import
- `Boneyard/Metalogic_v5/Representation/TruthLemmaForward.lean` (2)
- `Boneyard/Metalogic_v5/Representation/IndexedMCSFamily.lean` (16) - old definition copy

**Pattern C**: Old `Boneyard/` outside `Theories/` (2 files, commented imports)
- `Boneyard/Metalogic_v4/Representation/TemporalCompleteness.lean` (9)
- `Boneyard/Metalogic_v4/Representation/UniversalCanonicalModel.lean` (8)

### 6. Other Files

| Location | Files | Occurrences | Notes |
|----------|-------|-------------|-------|
| `docs/claude-directory-export.md` | 1 | 3 | Auto-generated, can ignore |
| `specs/**` | ~350+ files | ~hundreds | Research reports, plans, descriptions -- no code |

### 7. Import Dependency Graph (Active Files)

```
IndexedMCSFamily.lean  (definition)
  |
  +-> BMCS.lean
  |     |
  |     +-> BMCSTruth.lean
  |     |     |
  |     |     +-> TruthLemma.lean
  |     |           |
  |     |           +-> Completeness.lean
  |     |           |     |
  |     |           |     +-> Representation.lean
  |     |           |
  |     |           +-> Representation.lean
  |     |
  |     +-> ModalSaturation.lean
  |     |     |
  |     |     +-> Construction.lean
  |     |           |
  |     |           +-> CoherentConstruction.lean
  |     |           |
  |     |           +-> TemporalCoherentConstruction.lean
  |     |
  |     +-> Construction.lean
  |     |
  |     +-> CoherentConstruction.lean
  |     |     |
  |     |     +-> TruthLemma.lean
  |     |     |
  |     |     +-> TemporalCoherentConstruction.lean
  |     |
  |     +-> TemporalCoherentConstruction.lean
  |           |
  |           +-> TruthLemma.lean
  |           |
  |           +-> Representation.lean
  |
  +-> Construction.lean
  |
  +-> ModalSaturation.lean
  |
  +-> CoherentConstruction.lean
  |
  +-> DovetailingChain.lean
  |
  +-> TemporalCoherentConstruction.lean
  |
  +-> BMCSTruth.lean
  |
  +-> TruthLemma.lean
```

All active files import `IndexedMCSFamily.lean` either directly or transitively via `BMCS.lean`.

### 8. Safe Rename Order

The rename must be performed atomically (all files at once) because:
- Every active file directly imports `IndexedMCSFamily.lean`
- Any partial rename will cause build failures

**Recommended execution order:**

1. Rename file: `IndexedMCSFamily.lean` -> `BFMCS.lean`
2. Update all import paths: `Bimodal.Metalogic.Bundle.IndexedMCSFamily` -> `Bimodal.Metalogic.Bundle.BFMCS`
3. Replace all occurrences of `IndexedMCSFamily` -> `BFMCS` (structure name and namespace)
4. Replace `constantIndexedMCSFamily` -> `constantBFMCS`
5. Replace `toIndexedMCSFamily` -> `toBFMCS`
6. Update doc comments and module documentation
7. Build and verify

### 9. BFMCS Naming Rationale

"BFMCS" stands for **Bundled Family of Maximal Consistent Sets**. The rationale:

1. **"Bundled"**: Each BFMCS bundles one MCS per time point into a single coherent entity. The temporal coherence constraints (forward_G, backward_H) are the "bundling" structure.

2. **"Family"**: It is a family of sets -- one per time point.

3. **"of Maximal Consistent Sets"**: Each member is an MCS.

4. **Two-level ontology**: The naming makes the two-level structure explicit:
   - Level 1: `BFMCS` bundles MCSes across time (temporal coherence)
   - Level 2: `BMCS` bundles BFMCSes across possible worlds (modal coherence)

The acronym mirrors the existing `BMCS` naming convention, making the relationship clear: a `BMCS` is a bundle of `BFMCS`es.

### 10. Collision Check

- `lean_local_search` for "BFMCS" returned zero results -- no existing declarations use this name
- Only existing uses of "BFMCS" are in task description files (specs/914, specs/915, specs/916) and TODO.md

### 11. Potential Issues

1. **Boneyard v5 has its own `IndexedMCSFamily.lean`**: The file `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/IndexedMCSFamily.lean` is a separate (older) copy. It could be renamed independently or left as-is. Some Boneyard files import from `Bimodal.Metalogic.Representation.IndexedMCSFamily` (a path that no longer exists as active code). These are commented out or in non-building Boneyard code.

2. **`TemporalCoherentFamily extends IndexedMCSFamily`**: The `extends` clause generates a `toIndexedMCSFamily` coercion field. Renaming will change this to `toBFMCS`. Any code accessing `.toIndexedMCSFamily` must be updated.

3. **String literals in doc comments**: Many doc comments reference "IndexedMCSFamily" by name. These should be updated to "BFMCS" with explanatory text.

4. **Non-building Boneyard files**: The Boneyard files may not build. Updating their source text is fine but cannot be verified via `lake build`.

5. **`constantWitnessFamily` type signature**: This function returns `IndexedMCSFamily D`. The type annotation will auto-change when the structure is renamed, but the function name itself does not contain "IndexedMCSFamily" and should not be renamed.

6. **Specs/docs references**: Hundreds of occurrences in spec files (research reports, plans). These are historical documentation and can be batch-updated or left as-is (they reference the historical name).

## Recommendations

1. **Rename active files first, Boneyard second**: Focus on the 12 active files (204 occurrences) and verify the build passes. Then update the 20 Boneyard files (198 occurrences).

2. **Use atomic rename pattern**: Since all active files directly import `IndexedMCSFamily.lean`, the file rename and all import/name changes must happen in a single commit.

3. **Also rename `constantIndexedMCSFamily`**: This is the most prominent related identifier (13 occurrences across 4 files). Rename to `constantBFMCS` for consistency.

4. **Also rename `toIndexedMCSFamily`**: The auto-generated coercion from `TemporalCoherentFamily extends IndexedMCSFamily` will become `toBFMCS`. Update the 9 explicit references.

5. **Skip specs/ updates**: The hundreds of occurrences in specs/ are historical documentation. Updating them adds no value and creates a massive diff. Leave them as-is.

6. **Skip docs/claude-directory-export.md**: This is auto-generated and will be refreshed on next export.

7. **Update Metalogic.lean comment**: The single comment reference in `Metalogic.lean` should be updated.

8. **Add doc comments explaining BFMCS ontology**: Per task 915 (which depends on 914), add explanatory doc comments. Minimal doc comment updates can happen during the rename itself.

## References

- Task description: `specs/914_rename_indexedmcsfamily_to_bfmcs/description.md`
- Task 915 (documentation): `specs/915_document_bfmcs_proof_architecture/description.md`
- Definition file: `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean`
- BMCS definition: `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`

## Next Steps

1. Create implementation plan with phased rename approach
2. Phase 1: Rename file and structure definition
3. Phase 2: Update all active source files (12 files)
4. Phase 3: Update Boneyard files (20+ files)
5. Phase 4: Verify build
6. Phase 5: Update doc comments
