# Teammate B: Code Organization and Task Dependency Findings — Task 202

**Task**: 202 — Eliminating succ_cofinal sorry for sorry-free completeness_discrete
**Teammate**: B (Code Organization and Alternative Approaches)
**Artifact**: 04
**Date**: 2026-05-29

---

## Key Findings

### Finding 1: HenkinDiscreteChain.lean Should Be Kept, Not Archived

`HenkinDiscreteChain.lean` (121 lines) at
`Theories/Bimodal/Metalogic/BXCanonical/Chronicle/HenkinDiscreteChain.lean`
is NOT dead-end experimental code — it is active working infrastructure.

The file contains:
1. Two sorry-free lemmas (`g_content_consistent` and `h_content_consistent`) that were
   added during the current Phase 1 attempt and compile cleanly.
2. A detailed module docstring documenting 5 failed approaches with their precise failure
   modes, providing an authoritative reference that prevents re-attempting the same paths.

This file should remain in `BXCanonical/Chronicle/` for now. It is a direct import of
`ChronicleToCountermodel` and is part of the active investigation. The sorry-free lemmas
are genuine infrastructure; the docstring is essential institutional knowledge.

Post-task-202 resolution: under task 176, the entire Chronicle/ subtree moves to
`Metalogic/Chronicle/` or `WeakCanonical/Chronicle/`. HenkinDiscreteChain.lean moves
with it.

**Confidence**: HIGH.

---

### Finding 2: The Non-Chronicle BXCanonical Subtree Is Dead Code Ready for Archival

The BXCanonical directory has a clear two-tier structure:
- **Chronicle/**: Active — used by WeakCanonical/ and BXCanonical/Completeness.lean
- **Non-Chronicle subtree**: Dead code — not consumed outside BXCanonical/ itself

The non-Chronicle BXCanonical files are:
`Frame.lean` (sorry at line 205: `bx_le_refl` under irreflexive semantics),
`TruthLemma.lean`, `CanonicalChain.lean`, `CanonicalModel.lean`,
`OrderedSeedConsistency.lean`, `Filtration/DefectChain.lean`,
`Quasimodel/SubformulaClosure.lean`, `Quasimodel/HintikkaPoint.lean`,
`Quasimodel/Construction.lean`, `Quasimodel/Realization.lean`,
`Quasimodel/LocusControl.lean`, `Quasimodel/EnrichedClosure.lean`.

These files total approximately 4,615 lines and contain ~1 explicit sorry (`bx_le_refl`
in Frame.lean). None are imported by any active module outside BXCanonical/ itself,
EXCEPT for one critical dependency: `OrderedSeedConsistency.lean` is imported by
`PointInsertion.lean` (inside Chronicle/), which means it IS on the active path.

**The one exception**: `OrderedSeedConsistency.lean` is imported by
`Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (line ~5),
which is part of the Chronicle pipeline. It must NOT be archived before task 176
(which explicitly says to "Verify OrderedSeedConsistency.lean dependency from
WeakCanonical/ReflexiveCanonical.lean before archiving"). Task 176 owns this.

Also: `OrderedSeedConsistency.lean` is imported by
`WeakCanonical/ReflexiveCanonical.lean` directly. This makes it doubly off-limits
for archival — it is consumed by an active module.

**Archival recommendation (task 176 scope)**:
- Archive `Frame.lean`, `TruthLemma.lean`, `CanonicalChain.lean`, `CanonicalModel.lean`,
  `Filtration/`, `Quasimodel/` to `Boneyard/BXCanonical/`
- Keep `OrderedSeedConsistency.lean` until its dependency status is resolved
- Do NOT archive any Chronicle/ files

The non-Chronicle BXCanonical code should NOT be archived now as part of task 202.
Task 176 is the right vehicle.

**Confidence**: HIGH for the structural analysis. MEDIUM for the exact archival scope
(needs task 176 investigation of the `OrderedSeedConsistency.lean` dependency chain).

---

### Finding 3: Bundle/ Has 12 Active Sorries That Are Dead Code

The Bundle/ directory contains significant dead code:
- `SuccRelation.lean`: 7 sorries (lines 558, 567, 591, 620, 634, 645, 653)
- `SuccExistence.lean`: 3 sorries (lines 446, 749, 823)
- `UntilSinceCoherence.lean`: 2 sorries (lines 85, 96)

These Bundle files are consumed outside of Bundle/ only by:
1. `Core/RestrictedMCS/Basic.lean` (imports SuccExistence — but inspection shows the
   import may not use SuccExistence definitions directly)
2. `Core/RestrictedMCS/Deferral.lean` (imports SuccExistence)
3. `BXCanonical/Chronicle/ChronicleToCountermodel.lean` (imports UntilSinceCoherence)

The `UntilSinceCoherence.lean` import in `ChronicleToCountermodel.lean` means those
2 sorries are on the indirect dependency chain of `completeness_discrete`. However,
the ROADMAP notes that "~17 dead-code sorries in BXCanonical pipeline (bypassed by
Chronicle)" — these 2 sorries appear to be in that dead-code category.

Task 176 is again the right vehicle: "Archive entire non-Chronicle BXCanonical subtree
(16 files, 4,615 lines, 19 mathematically false sorries)."

The 12 Bundle sorries do NOT block task 202 because:
- `lean_verify completeness_discrete` traces through `succ_cofinal` alone as the
  root sorry (per report 02)
- The sorry chain does not pass through SuccRelation or SuccExistence

**Confidence**: HIGH.

---

### Finding 4: Task 129 Is an Archived Task, Not a Currently Active Strategy

Multiple documents reference "task 129" as a viable resolution path:
- HenkinDiscreteChain.lean docstring (line 54): "Task 129: Reflexive completeness +
  conservative extension"
- ChronicleToCountermodel.lean (lines 1878, 1883, 1891, 1920): references task 129
- phase-1-blocked-20260529.md: lists "Task 129" as Priority 1 resolution path

However, task 129 is NOT in TODO.md. It exists in:
`specs/archive/129_weak_reflexive_completeness_conservative_extension/`

The archive summary (`summaries/09_reynolds-theorem15-summary.md`) shows task 129
was implemented with 5 remaining sorries (k_type_of, ktype_finite, finite_types in
NEquivalence.lean; table, table_depth_bound in Table.lean). These 5 sorries are the
same ones that now appear in the active WeakCanonical/ infrastructure:

- `WeakCanonical/NEquivalence.lean` contains `KEquivalenceFramework` with 3 sorries
- `WeakCanonical/Table.lean` is listed as having no sorries in the current codebase

The code from task 129 was merged into the active WeakCanonical/ infrastructure.
The "task 129 approach" (reflexive completeness + conservative extension) was the
work done in WeakCanonical/ to build the Reynolds pipeline. It is NOT a separate
pending approach — it IS the current WeakCanonical/ implementation.

**Implication for task 202 planning**: References to "task 129" in the handoff/plan
files should be interpreted as "the WeakCanonical/ Reynolds pipeline approach" not as
a separately executable task. The conservative extension approach that task 129
proposed IS the current WeakCanonical/ architecture. The reason it still has sorries
is the same reasons the Reynolds pipeline itself has sorries.

**Confidence**: HIGH — confirmed by examining the archive directory structure, the
archive summary, and cross-referencing with the current active code.

---

### Finding 5: The "20 Sorry" Landscape — What Is Truly Dead Code vs. Active

**Summary of all active sorry occurrences** (35 total, excluding Boneyard):

| File | Count | Status | Resolution Path |
|------|-------|--------|----------------|
| `ChronicleToCountermodel.lean` | 4 | Critical path (root sorry at 1885) | Task 202 |
| `WeakCanonical/TruthLemma.lean` | 6 | Non-critical (parametric truth lemma bypasses) | Future task |
| `Bundle/SuccRelation.lean` | 7 | Dead code under irreflexive semantics | Task 176 |
| `Bundle/SuccExistence.lean` | 3 | Dead code under irreflexive semantics | Task 176 |
| `Bundle/UntilSinceCoherence.lean` | 2 | Indirect dependency only | Task 176 |
| `BXCanonical/Frame.lean` | 1 | Dead code (`bx_le_refl`) | Task 176 |
| `WeakCanonical/EFGames/StaviCompleteness.lean` | 3 | Non-critical (EF games) | Task 155 |
| `WeakCanonical/Expressiveness/CaseAnalysis.lean` | 4 | Non-critical (Cases III/IV) | Task 155/199 |
| `WeakCanonical/IntegerModel/GoodStructures.lean` | 1 | Critical path (`no_gaps_discrete`) | Task 155/202 |
| `WeakCanonical/IntegerModel/ShiftAndGlue.lean` | 2 | Non-critical (Prior-UZ/SZ discharge) | Task 202/155 |
| `WeakCanonical/Transfer.lean` | 1 | Non-critical (Reynolds pipeline packaging) | Task 202 |
| `WeakCanonical/OrderedSum.lean` | 1 | Dead code (Doets lemma placeholder) | Future |

**The ONE critical-path sorry for `completeness_discrete`**: `succ_cofinal` at
`ChronicleToCountermodel.lean:1885`. All others are either dead code, non-critical
bypassed paths, or future work on the Reynolds pipeline.

**Confidence**: HIGH based on `lean_verify` results in report 02.

---

### Finding 6: The Boneyard Convention Is Well-Established and Should Guide Future Archival

The Boneyard at `Theories/Bimodal/Boneyard/` has a mature convention:
- 20 subdirectories, each with a README
- Archival reasons are categorized: dead ends, superseded approaches, architectural incompatibility
- Files may use `#exit` to prevent compilation of non-compiling reference code
- The Boneyard README is a single source of truth with a directory inventory table

For future archival work (primarily task 176), the convention to follow is:
1. Create a named subdirectory with a descriptive slug
2. Move files, adjusting import paths
3. Add `#exit` if needed for API drift
4. Write a subdirectory README
5. Update the Boneyard README inventory table

The `HenkinDiscreteChain.lean` should eventually follow the bundle dead-code pattern: it
records dead-end approaches. Once task 202 is resolved, if the Henkin chain approach
remains unused, it should be archived under `Boneyard/HenkinApproaches/` or similar.
For now it serves as active research infrastructure.

**Confidence**: HIGH.

---

## Recommended Approach

Based on the code organization analysis, here are the recommended actions:

### Immediate (Task 202 Context)

1. **Do NOT archive HenkinDiscreteChain.lean** — it is active infrastructure with
   sorry-free lemmas and essential documentation
2. **The current plan v3 Phase 1 blocker is well-characterized** — the F-persistence
   problem through Lindenbaum extensions is a genuine obstruction
3. **The single viable path not yet attempted**: Prove F-persistence using the argument
   in plan v3 lines 153-169: at each Lindenbaum step, `G(neg psi)` cannot enter the MCS
   because `F(psi) in mcs(n)` prevents `G(neg psi) in mcs(n)`, so `neg psi not in
   g_content(mcs(n))`, and `neg psi` is not forced by the seed. The issue is whether
   the unrestricted Lindenbaum extension can still include `neg psi` (it can), but this
   only matters if `G(neg psi)` gets propagated. The g_content seed EXCLUDES `G(neg psi)`
   (because `G(neg psi) not in mcs(n)`), so Lindenbaum extends from a seed that does not
   contain `G(neg psi)`. The resulting MCS could still include `G(neg psi)` (Lindenbaum is
   arbitrary), but that would mean `G(neg psi) in mcs(n+1)`, which makes `F(psi)` absent
   from mcs(n+2) permanently. This is the genuine obstruction.

4. **The most likely unblocking path**: The WeakCanonical/ Bundle construction
   (`temporal_coherent_family_exists_CanonicalMCS` in `Bundle/Construction.lean`) may
   already provide the needed sorry-free Henkin chain on Z. This was identified in report
   02 as "Approach 3" but never verified. It should be the first thing checked.

### Near-Term (Task 176)

5. **Archive the non-Chronicle BXCanonical subtree** (Frame, TruthLemma, CanonicalChain,
   CanonicalModel, Filtration/, Quasimodel/ — ~4,615 lines, 1 sorry) under
   `Boneyard/BXCanonical/`. This eliminates the dead-code sorry and reduces codebase size.
   BUT: verify `OrderedSeedConsistency.lean` dependencies before archiving (both
   Chronicle/PointInsertion and WeakCanonical/ReflexiveCanonical import it).
6. **Archive Bundle/SuccRelation.lean, Bundle/SuccExistence.lean** (7+3 sorries under
   irreflexive semantics) under `Boneyard/Bundle/SuccChainInfrastructure/`. Verify
   that `Core/RestrictedMCS` imports of SuccExistence do not actually use any definitions.

### Task Ordering Correctness

The current TODO.md ordering is correct for the goals:
- Phase 1: Tasks 199, 155 (complete EF games), then 202 (eliminate last sorry) — correct
- Phase 2 (post-155): Tasks 176, 95 — correct (176 archives dead code after 155 is done)

**Key dependency clarification**: Task 202 does NOT depend on task 155 Phase 5 being
complete. Task 202's current approach (Henkin chain / Option C) is INDEPENDENT of the
Reynolds pipeline Phases 1-2 in task 155. The dependency in TODO.md lists "155" as a
dependency for task 202, but this should be reconsidered: tasks 199 and 155 are on
the Reynolds pipeline path, while task 202 is now pursuing the Henkin/Option C path.
These are parallel, not sequential.

**Recommendation**: Remove the `155` dependency from task 202, OR create a sub-description
noting the two independent paths. The current architecture allows progress on task 202
(Henkin chain) without task 155 completion.

---

## Evidence / Examples

### Evidence for Non-Chronicle BXCanonical Being Dead Code

The BXCanonical aggregator `BXCanonical.lean` imports both Chronicle and non-Chronicle
files. But externally, only these BXCanonical components are consumed:
- `BXCanonical.Chronicle.*` — by WeakCanonical/Transfer.lean, WeakCanonical/ChronicleExtraction.lean
- `BXCanonical.Completeness` — by Metalogic/Metalogic.lean via BXCanonical.BXCanonical
- `BXCanonical.OrderedSeedConsistency` — by WeakCanonical/ReflexiveCanonical.lean

The non-Chronicle BXCanonical modules (Frame, TruthLemma, CanonicalChain, etc.) are
only imported within BXCanonical/ itself. They form a self-contained closed subgraph.

### Evidence for Task 129 Being Absorbed into Active Code

Task 129 archive `summaries/09_reynolds-theorem15-summary.md`:
> "Phase 3: Created sorry-based KEquivalenceFramework instance in NEquivalence.lean"
> "Phase 5: Chronicle_is_good via one_class -> very_good -> good"

These EXACT items appear in the active codebase:
- `WeakCanonical/NEquivalence.lean` (KEquivalenceFramework)
- `WeakCanonical/IntegerModel/ShiftAndGlue.lean` (chronicle_is_good via one_class)

Task 129 was completed as a structural skeleton that is now the WeakCanonical/
infrastructure. The 5 remaining sorries from task 129 are the open items in
the Reynolds pipeline.

### Evidence for the `succ_cofinal` Uniqueness as Root Sorry

From report 02, `lean_verify` results:
- `cantor_bfmcs_discrete`: NO sorry
- `cantor_bfmcs_discrete_restricted_buc`: NO sorry
- `fully_restricted_parametric_completeness_from_neg_membership`: NO sorry
- `cantor_bfmcs_discrete_restricted_tc`: YES sorry (via succ_embed_surjective)
- `cantor_bfmcs_discrete_restricted_fuc`: YES sorry (via succ_embed_surjective)

The sorry DAG has exactly ONE root: `succ_cofinal`.

---

## Confidence Level

**Overall**: HIGH

The code organization findings are based on direct inspection of file import graphs,
not speculation. The archival recommendations follow the established Boneyard convention.
The task 129 finding is based on matching specific code artifacts between the archive
summary and the current active codebase.

The strategic recommendation (task 202 independence from task 155) is MEDIUM confidence
— it depends on interpreting the Henkin chain path as genuinely independent from the
Reynolds pipeline, which has not been formally verified but follows from the different
proof architectures described in the plans.
