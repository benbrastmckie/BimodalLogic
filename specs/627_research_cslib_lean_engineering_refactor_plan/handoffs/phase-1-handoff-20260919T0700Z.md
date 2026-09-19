# Phase 1 Handoff: Committed measurement tooling

- **Task**: 627
- **Phase closed**: 1 of 4 (`[COMPLETED]`)
- **Session**: sess_1789799001_60286d
- **Next action**: open Phase 2 (programme document `docs/development/PUBLICATION_REFACTOR.md`),
  then Phase 3 (ADR-010, ADR-011), then Phase 4 (full gate + summary).

## State

- `scripts/lib/import_graph.py` and `scripts/measure-refactor-partitions.py` exist and run;
  `--check` exits 0; `all --json` round-trips.
- `docs/development/MODULE_INVARIANTS.md` catalogues the script under "Sibling scripts". It
  names `PUBLICATION_REFACTOR.md` in backticks, not as a link, because the file does not exist
  until Phase 2 closes (C13 would fail). Phase 2 turns that mention into a link.
- `bash scripts/check-module-invariants.sh --no-build` exit 0 after Phase 1.
- `FormalSystem/Semantics/Ultraproduct/README.md` and `FormalSystem/Syntax/README.md` were
  already modified in the working tree when this dispatch started (2 one-line diffs, not this
  task's). Do not stage them; report them in the summary.

## Measured numbers (script is the source of truth)

| Measurement | Value |
|---|---|
| Expressiveness set | 141 files / 104,087 lines; 0 edges into residual or BXCanonical |
| Residual WeakCanonical | 38 files / 28,472 lines |
| BXCanonical-free by closure | 150 of 179 |
| Upward lines into Automation from the five lower layers | 16 (11 attribute-only); report said 17 / 12 |
| Theorems -> Metalogic | 4 files (all `Metalogic.Core.DeductionTheorem`) |
| Metalogic -> Theorems | 29 files / 47 lines |
| Automation: library-needed / user-facing tactics / tooling | 9 (3,419) / 4 (1,238) / 25 incl. TraceExport (14,747) |
| Namespaces: equal-or-descendant / ancestor / unrelated / none | 279 / 187 / 24 / 43; 15 of the 24 are language-extension files (report said 17) |
| C6 manifest entries | 15 (report said 26 unreachable modules) |
| Loose files at `Tests/BimodalTest/` root | 12 (8 `*Probe.lean`, `TableauConformance.lean`, 3 `Trace*`); report said 9 probes |

## Conventions the remaining phases must keep

- Hypothetical paths relative to the library root (`Metalogic/Expressiveness/`), never
  `FormalSystem/...` (C12) or `FormalSystem.Metalogic.Expressiveness` (C5); never `Tests/...`
  for a future test path (C12 matches `Tests/`).
- No `task N` / `specs/NNN_` strings in `docs/` or `scripts/` (C9, C9D); cite commit
  `220e94ea4` and the script.
- No literal paper anchors (C15), no `File.lean:NNN` (C20), no "NN axiom(s)" counts with the
  stale figures (C14).
