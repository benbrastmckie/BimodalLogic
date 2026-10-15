# Phase 4 handoff — `NomicModel`, the truth recursion, and the clause layer

- **Next action**: Phase 5 (`NomicTenseFree.lean`).
- **State**: `FormalSystem/NomicLanguage/NomicTruth.lean` landed: `NomicModel`, the seven-clause
  `NomicTruthAt` with `def:nomic-frame`'s Nomic clause, seven primitive and nine derived clause
  lemmas (`always_iff` and `next_iff_succ`/`next_iff_add_one` among them), and
  `nomic_iff_box_of_uniform`. Build exit 0, zero warnings, zero sorry. The three measured linter
  traps are clear: no tactic-position `show`, no `simpa`, no no-op `congr 1`.
- **Decisions**: the module docstring records why `Semantics/TruthClauses.lean` is uninstantiable
  here (its `TaskFrame`/`WorldHistory` binder set) and that generalising it is out of scope.
- **Deviations**: none.
