
## Residual old final components: 0

A re-run of the sweep over `docs/`, `typst/`, `latex/`, `README.md` reports zero remaining
whole-word occurrences of any old final component. There are no deliberately-retained hits in
this territory (unlike Phase 7.1, which retains one paper-label reference).

## `bx_completeness`: already absent from this territory

The research counted one doc-only mention. It is gone — repaired by the Phase 3 non-Lean sweep.
The only surviving live occurrence was a prose comment in a Lean file,
`FormalSystem/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean:16`, corrected here to
`` `completeness_discrete` `` (the real theorem, `Metalogic/BXCanonical/Completeness.lean:295`).
Two further occurrences remain under `FormalSystem/Boneyard/`, out of scope by Non-Goals.

## Task-number citations: 0 introduced, 178 pre-existing NOT purged

| Measure | Value |
|---|---|
| citations on lines this phase rewrote | 159 before, **159 after** |
| citations introduced | **0** |
| citations present across `docs/`, `typst/`, `latex/`, `README.md` | **178 across 18 files** |

The plan's done-when test is "no task-number citations *introduced*", which is met exactly. The
stronger reading — purge all of them — was deliberately not executed:

1. **Several documents are changelog-shaped.** `docs/project-info/IMPLEMENTATION_STATUS.md`,
   `docs/project-info/SORRY_REGISTRY.md`, and `docs/research/README.md` consist substantially of
   dated task-history entries ("**P3 RESOLVED** (2025-12-08 Task 16)"). "Cite a durable anchor
   instead" has no mechanical answer when the citation *is* the record.
2. **`docs/training/PIPELINE.md` uses "Task N" for a different referent.** Its rows
   "Task 4: Tokenizer", "Task 5: Text serializer", "Task 7: PyTorch Dataset", "Task 10: MCTS",
   "Task 19: Z3 countermodel" name **ML-pipeline work items**, not agent-system task numbers. A
   blanket purge would corrupt them.
3. **It is not a rename.** 178 sites needing per-site editorial judgement is a separate piece of
   work; folding it into a naming migration would make this phase's diff unreviewable.

**Follow-up recommended**, covering both this finding and the equivalent one from Phase 7.1:

| Territory | Citations | Files | Note |
|---|---|---|---|
| `docs/`, `typst/`, `latex/`, `README.md` | 178 | 18 | includes the PIPELINE.md false-positive class |
| `Tests/` | 112 | 14 | mostly `NOTE (Task 365): quarantined — …` |

Neither was introduced by this migration. `scripts/check-module-invariants.sh` check C9 scopes
its task-citation check to `FormalSystem/` only, which is why both trees escaped it.
