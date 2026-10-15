# Phase 3 handoff — the `NomicLanguage` component and its syntax

- **Next action**: Phase 4 (`NomicTruth.lean`).
- **State**: `FormalSystem/NomicLanguage/Formula.lean` (`NomicFormula`, twelve derived operators,
  `ofFormula` with injectivity and eleven `rfl` pins), `FormalSystem/NomicLanguage.lean`,
  `FormalSystem/NomicLanguage/README.md`, and the `"NomicLanguage"` `LANGUAGE_FILE_LAYERS` entry
  (`Formula` 0; `NomicFour`/`NomicTenseFree`/`NomicTruth`/`NomicValidity` 1) all landed.
  `lake-build-guard.sh build -- build FormalSystem.NomicLanguage` exit 0, zero warnings.
  `check-metalogic-cycles.sh` assertion C passes: 19 syntax modules, no semantics import from one.
  `measure-refactor-partitions.py` exit 0, no `UnlayeredModuleError`.
- **Decisions**: `NomicFormula.iff` copies `PlusFormula.iff`'s right-hand side (base `Formula` has
  no `iff`), and `next` copies `Formula.next` (`OpenFormula` has none).
- **Deviations**: none.
