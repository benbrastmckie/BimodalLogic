# Phase 6 handoff — validity and seriality

- **Next action**: Phase 7 (`NomicFour.lean`, the prose repoints, the gate sweep).
- **State**: `FormalSystem/NomicLanguage/NomicValidity.lean` landed: `NomicFrame.NomicValidOn`,
  `nomic_serial` over every nomic frame, and `nomicValidOn_nomic_iff_box_of_uniform`. Build exit 0,
  zero warnings, zero sorry. The file's FIRST namespace is `FormalSystem.NomicLanguage`, so
  `measure-refactor-partitions.py`'s namespace-audit bucket does not gain it (verified: neither
  this module nor `NomicFour` appears among the 24 unrelated rows).
- **Decisions**: validity, not truth, carries `τ ∈ F.HF`.
- **Deviations**: none.
