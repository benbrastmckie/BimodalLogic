# SupersededCompleteness — Archived from `Metalogic/`

| File | Lines | Archived from | Compiles at archival |
|------|------:|---------------|----------------------|
| `Completeness.lean` | 534 | `Metalogic/Completeness.lean` | Yes |

## Why Archived

The file had **zero live importers**. The only `import Bimodal.Metalogic.Completeness`
line anywhere in the repository came from another Boneyard file, so the module sat
outside every Lake target's import closure and `lake build` never compiled it — while
both `Metalogic/README.md` and the `Metalogic.lean` module docstring continued to
document it as live. That combination (unreachable code documented as live) is the
specific defect this archival resolves.

It did in fact still compile when archived — verified with `lake build
Bimodal.Metalogic.Completeness` immediately before the move. That fact is recorded
here because it is the only place it survives: the file is now inert, so nothing
re-checks it, and a future reader deciding whether to revive it should know it was
archived for being unreferenced, not for being broken.

## What Replaced It

The live completeness results are elsewhere and are not derived from this file:

- `Metalogic/BXCanonical/` — the chronicle construction route, carrying
  `completeness`, `completeness_dense`, and `completeness_discrete`.
- `Metalogic/WeakCanonical/` — the Kamp/Reynolds route.
- `Metalogic/Algebraic/` — the parametric/algebraic route.

The MCS machinery this file was refactored around had already been extracted to
`Metalogic/Core/MaximalConsistent.lean` and `Metalogic/Core/MCSProperties.lean`,
which are live; what remained here was the residue of that extraction.

## Reviving It

Reviving means re-adding an import from a live module and deleting its line from
`scripts/module-invariants-manifest.txt`. Note that it was never a dependency of any
current completeness proof, so reviving it adds a parallel development rather than
restoring a missing piece. Check the `#print axioms` results for the flagship theorems
before and after; they must not change.
