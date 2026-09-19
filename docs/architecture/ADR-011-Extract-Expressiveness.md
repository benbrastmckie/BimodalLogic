# ADR-011: Extract the Expressiveness Development out of `WeakCanonical/`

## Status

**Proposed** - 2026-09-19

Supersedes [ADR-006](ADR-006-Metalogic-No-Physical-Regroup.md) for the *expressiveness* subset
of `Metalogic/WeakCanonical/` only. ADR-006's declined regroup of the three completeness routes
under a `Completeness/` parent stays declined, and its one directory-level cycle stays accepted.
ADR-006 remains **Accepted** until this record is; the programme's Expressiveness phase
(`docs/development/PUBLICATION_REFACTOR.md`) is what accepts it.

## Context

ADR-006 declined any physical regroup of `Metalogic/` on two grounds: the directory-level cycle
`BXCanonical` <-> `WeakCanonical`, which no nesting can express, and the partial-move risk of
relocating the repository's largest subtree by hand. Both grounds were sound for the question
ADR-006 asked, which was whether the three *completeness* routes should be nested.

This record asks a different question. `Metalogic/WeakCanonical/` holds 179 live modules and
132,559 lines, and most of it is not the weak canonical model at all. Kamp's theorem, the
Ehrenfeucht-Fraïssé games, the split-point game-transfer chain, separation, the monadic
first-order fragment, the normal forms and the Prior-expressiveness results are an
*expressiveness* development. Two of the repository's headline results live there and carry
`WeakCanonical` in their fully-qualified names — the two `#print axioms` lines in
`FormalSystem/MainResults.lean` that name `Kamp.kampPriorExpressiveCompleteness` and
`uSExpressivelyCompleteOverPrior` — although neither is a canonical-model result. A reader
citing them from a published formalization is told the wrong thing by the name.

### The measurement

The import closure of every module under `WeakCanonical/` was computed from the leading
`import` block of each file (`scripts/lib/import_graph.py`), and each module classified by
whether any `BXCanonical` module appears in its transitive imports. Measured on commit
`220e94ea4`:

| Set | Files | Lines | Edges into the other set or into `BXCanonical` |
|---|---:|---:|---:|
| Expressiveness (to move) | 141 | 104,087 | **0** |
| Residual `WeakCanonical` | 38 | 28,472 | n/a (this is where the cycle lives) |

The Expressiveness set is `Kamp/` (116 files), `EFGames/` (8), `Expressiveness/` (5),
`Separation/` (3), and the single modules `NormalForm`, `MonadicFO`, `StaviConnectives`,
`PriorDefs`, `PriorDefsDense`, `PriorExpressiveness`, `PriorExpressivenessDense`, `Table` and
`EFGameTactics`. It is `BXCanonical`-free by closure and imports nothing from the residual set,
so it is closed under its own imports. Of the 179 modules, 150 are `BXCanonical`-free and 29
reach it; every one of the 29 is in the residual set.

The importers of the Expressiveness set from outside it are `BXCanonical/Chronicle/ChronicleMonadicBridge.lean`
(4 lines), seven residual `WeakCanonical` modules plus the `WeakCanonical` aggregator, and one
Automation module. Every one of those edges points *into* the set; none points out. The move
therefore creates only one-way edges, `BXCanonical -> Expressiveness` and
`WeakCanonical -> Expressiveness`, and cannot create a cycle.

Regenerate the table and the edge check with:

```bash
python3 scripts/measure-refactor-partitions.py weakcanonical-partition
python3 scripts/measure-refactor-partitions.py --check     # exit 1 if the set leaks
```

## Decision

1. **Extract the measured set to a new sibling directory `Metalogic/Expressiveness/`**, with the
   namespace `Metalogic.Expressiveness.*` under the library root (the fully-qualified prefix
   changes from `...Metalogic.WeakCanonical` to `...Metalogic.Expressiveness` for every
   declaration in the set). The subtree map is `Kamp/` -> `Expressiveness/Kamp/`, `EFGames/` ->
   `Expressiveness/EFGames/`, the current `WeakCanonical/Expressiveness/` (the split-point
   game-transfer chain) -> `Expressiveness/GameTransfer/`, `Separation/` ->
   `Expressiveness/Separation/`, and the nine single modules to `Expressiveness/` directly. A
   sibling aggregator `Metalogic/Expressiveness.lean` is added beside it (C8).

2. **The residual 38 modules keep the name `WeakCanonical`**, which now describes them: the
   reflexive weak canonical model, its truth lemma and frame properties, chronicle extraction
   and transfer, and the integer, real, group and dense-surgery model constructions that feed
   completeness.

3. **The residual cycle is accepted, and its count is still asserted.** `BXCanonical` <->
   `WeakCanonical` survives the move unchanged over the residual set, for the reason ADR-006
   gave: only the module graph must be acyclic, and it is. `bash scripts/check-metalogic-cycles.sh`
   must still report exactly **1** cycle after the move; a count of 0 or 2 is a finding.

4. **The move is gated by the measurement, not by the plan.** Immediately before the relocation,
   `python3 scripts/measure-refactor-partitions.py --check` must exit 0 against the tree being
   moved. If it does not, the edges it prints are relocated first, dependency-first as ADR-006's
   `Bundle` <-> `Core` precedent did, and the check is re-run. The check is never weakened to
   make a move go through.

5. **The move is scripted and lands in two commits**, each green under `lake build`,
   `lake build BimodalTest` and the full invariant harness: the path-plus-namespace move in one
   commit (imports, `namespace`/`open` lines, docstring paths, markdown, typst, the C2/C14 axiom
   baselines and `MainResults.lean` all rewritten by the programme's module-move tool), and the
   content renames of the paper-numbered files with deletion of declaration-free compatibility
   stubs in a second. This is the answer to ADR-006's partial-move risk.

6. **ADR-006's other decision stands.** No `Completeness/` parent is introduced; the three
   completeness routes stay siblings. Expressiveness was never a completeness route, which is
   why extracting it does not reopen that question.

### The two names that change

| Today | After |
|---|---|
| `FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness` | `Metalogic.Expressiveness.Kamp.kampPriorExpressiveCompleteness` (under the library root) |
| `FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior` | `Metalogic.Expressiveness.uSExpressivelyCompleteOverPrior` (under the library root) |

Both are on the main-results page, both are pinned by C14's axiom baseline, and both would be
cited by an external reader. That is the pre-publication argument: a fully-qualified name is a
citation, and a citation that says "weak canonical" about Kamp's theorem misleads. The move must
land before the first release tag, together with every other **[CITE]** phase of the programme.

## Consequences

- `Metalogic/` gains one directory and `WeakCanonical/` shrinks from 179 modules to 38; the
  directory name and its contents agree again.
- Two headline fully-qualified names change, once, before publication; the typst manual,
  `docs/theorem-index.md`, the C2/C14 baselines and `MainResults.lean` are regenerated or
  rewritten in the same commit as the move.
- The single directory-level cycle in `Metalogic/` is unchanged in identity and in count.
- `scripts/measure-refactor-partitions.py --check` becomes a standing pre-move gate, and ADR-006's
  "a future proposal to regroup must first show the cycle is gone" is refined: a proposal must
  show that the *moved set* is closed and cycle-free, which is what the check asserts, while the
  cycle over what stays behind may remain.
- ADR-006's edge enumeration stays valid for the residual set; the four
  `ChronicleMonadicBridge` lines that point into the moved set become
  `BXCanonical -> Expressiveness` edges and leave that enumeration.

## Related

- [ADR-006](ADR-006-Metalogic-No-Physical-Regroup.md) — the cycle, the declined `Completeness/`
  regroup, and the partial-move risk this record answers with a scripted move
- [`FormalSystem/Metalogic/WeakCanonical/README.md`](../../FormalSystem/Metalogic/WeakCanonical/README.md) —
  the directory's current map
- `scripts/measure-refactor-partitions.py` — the partition measurement and the `--check` gate
- `scripts/check-metalogic-cycles.sh` — the cycle-count assertion that must still read 1
- `docs/development/PUBLICATION_REFACTOR.md` — the programme phase that performs the extraction
  and accepts this record
