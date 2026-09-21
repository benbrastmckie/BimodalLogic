# Boneyard / Kamp / KampWeakCanonical / DocumentedSingles

Five **unrelated one-file retirements**, each with its own narrative. This is a shelf, not an
approach: the files are grouped because each was archived alone, not because they belong together.

## The five, individually

- **`Arity4CharStackK.lean`** (1,862 lines) -- the losing arity-4 characteristic-formula branch,
  excised verbatim from four contiguous source blocks in live files. **Its own header carries a
  per-block provenance table with the exact line ranges, and that table is authoritative**; this
  README does not restate it. Adjudicated landed, unwired, circular and fiber-refuted. The
  competing zeta route won and keeps `charF` at arity 1. Do not wire it, do not build an arity-4
  realization engine from it, and note its header's warning that `igOffFiber` and the `kvEFiber*`
  families share the `Fib` suffix but are **live** and were deliberately not archived.
- **`EANegationVBracketBackward.lean`** (613 lines) -- the retired backward direction of the
  EA-negation V-bracket closure. The forward direction survives on the live path; the backward
  one was retired rather than completed.
- **`NavigatedEndCharSinglePoint.lean`** (312 lines) -- a refuted single-point navigated
  end-characterization scaffold. Its import of the retired multi-anchor bridge was rewritten to
  point at `../NfMultiAnchorBridgeRetired/` when that directory was created.
- **`Prop43.lean`** (196 lines) -- Rabinovich 2014 Proposition 4.3, off the live path.
- **`Prop43DepthCharInfra.lean`** (200 lines) -- depth-(k+1) NF characterization infrastructure.
  **Unrelated to `Prop43.lean` above** despite the shared stem: it held the `Prop43.lean` filename
  first and was renamed on archival to free that path for the Rabinovich file. The two are
  independent developments that happened to collide on a name.

## What revival would require

Different answers per file, which is why they are documented individually rather than as a group.
`Arity4CharStackK.lean` should not be revived at all -- its header says so, at length, and lists
the specific efforts already tried and abandoned. The other four are ordinary retirements: each
would need re-typechecking against the current live signatures before its mathematics is even the
question.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `Arity4CharStackK.lean` | 1,862 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Arity4CharStackK.lean` | created in the archive (`9de9f8a04`) by verbatim excision from four live files — see the per-block provenance table in the file's own header, which is authoritative |
| `EANegationVBracketBackward.lean` | 613 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/EANegationVBracketBackward.lean` | created in the archive (`b901a8be1`) |
| `NavigatedEndCharSinglePoint.lean` | 312 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/NavigatedEndCharSinglePoint.lean` | created in the archive (`6ccfe4c92`) |
| `Prop43.lean` | 196 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Prop43.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop43.lean` |
| `Prop43DepthCharInfra.lean` | 200 | `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Prop43DepthCharInfra.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop43.lean` — renamed on archival to free the `Prop43.lean` name for the unrelated Rabinovich file beside it |

Every file here sat flat at the `KampWeakCanonical/` root until this directory was created;
the "path before consolidation" column gives where each one lived before the archives were
merged, which is also where it sat before the regroup.

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
