# Boneyard / Kamp — archived Kamp-pipeline work

Region index for every abandoned approach belonging to the Kamp separation /
expressive-completeness pipeline, across five subdirectories. Nothing here is compiled, imported
by live code, or named in `lakefile.lean`.

Archive counts live in exactly one place: [`../README.md`](../README.md), which cites
`scripts/check-module-invariants.sh` B0/C7 as the live source. This page deliberately does not
restate them. The per-directory file counts in the table below are inventory, not totals.

## Why this directory exists

The Kamp work used to be archived in **two** places: `FormalSystem/Boneyard/`, holding four
Kamp-facing approach directories, and a second archive nested inside the live tree at
`FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/`. Two archives meant two inventories, two
sets of counts, and a standing trap: any tool filtering on the top-level path alone swept ~29k
archived lines into the live totals. They are now one tree, and `check-module-invariants.sh`'s B0
asserts that the count of `Boneyard` directories is exactly **1**, so a second one reappearing
fails the gate instead of silently splitting the numbers again.

## Subdirectories

| Directory | Files | What it was | Why it died |
|-----------|------:|-------------|-------------|
| [`KampWeakCanonical/`](KampWeakCanonical/README.md) | 63 | The former nested archive in its entirety: probe iterations, V-EA infrastructure, the translation era, the GHR separation cluster, and five individually-retired singles | Superseded, in stages, by the landed zeta route |
| [`KampBypassArchive/`](KampBypassArchive/README.md) | 13 | The enriched bypass formula — a direct characteristic-formula construction skipping separation | The zeta route landed first and keeps `charF` at arity 1 |
| [`KampNegationClosure/`](KampNegationClosure/README.md) | 4 | Closure of the VecEA2 fragment under negation | Dead code: no live downstream consumers |
| [`RabinovichPath/`](RabinovichPath/README.md) | 4 | Rabinovich 2014's route to expressive completeness | Dead code, and entangled with two other abandoned approaches |
| [`VecEADecomposition/`](VecEADecomposition/README.md) | 1 | Syntactic VBracketFormula negation and Prop 4.3 support | Bypassed by the NF-specific Prop 4.3 approach |

### Which is authoritative for what

- **`KampWeakCanonical/`** is authoritative for anything that was ever on the live
  `Metalogic/WeakCanonical/Kamp/` path and has since been retired. Its own README carries the
  event-first convention warning and the archival criterion for that material.
- **`KampBypassArchive/`** is authoritative for the bypass-formula route. `RabinovichPath/` and
  `KampNegationClosure/` both import from it; it does not import from them.
- **`KampWeakCanonical/TranslationEra/`** is the shared dependency floor beneath
  `KampBypassArchive/` and `RabinovichPath/`. Neither of those can be revived without it.
- **`VecEADecomposition/`** stands alone.

Every subdirectory holding a `.lean` file carries a README recording what the approach was, why
it died, what revival would require, and the pre-consolidation path of every file in it.

## What was deliberately left out

**`../MergedBracketQuarantine/` stays outside this umbrella.** It has two borderline Kamp edges,
but its subject is bracket quarantine rather than the Kamp pipeline, and folding it in would make
the region boundary a judgement call rather than a fact. It remains a sibling of `Kamp/` under
the top-level archive. This is a decision, not an oversight.

**Seven comment-only mentions of the old `Kamp/Boneyard/` path survive in three live `.lean`
files** — `Metalogic/WeakCanonical/Kamp/DedekindINF.lean` (1),
`Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (5), and
`Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (1). They are prose
in comments, not imports, and the consolidation was carried out under a do-not-modify-live-modules
constraint. The correct path is now `FormalSystem/Boneyard/Kamp/KampWeakCanonical/`; updating
those comments is separate work.

Last verified: 2026-08-24
