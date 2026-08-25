# Phase 5 handoff (README B4 + B3)

**Next action**: Phase 6 — the B5 inventory sweep over `FormalSystem/Metalogic/README.md`
(`:6-7`, Three Completeness Routes, aggregator table, loose-file counts, Directory Inventory,
`BXCanonical/`, `WeakCanonical/`, `Kamp/`, plus a "Last verified" line). Commit Mode:
atomic-batch. Locate targets by content — line numbers have drifted from the plan's.

**State**: B4 done — the Lake root paragraph now names the pair `FormalSystem.lean` +
`FormalSystem/FormalSystem.lean` with `srcDir := "."` and ``roots := #[`FormalSystem]``, citing
`lakefile.lean:15-19`. B3 done — `BXCanonical/README.md` row 13 now reads `../BXCanonical.lean`,
43 lines, explicitly marked a sibling aggregator.

**Verified at implementation time**: `wc -l` gives `FormalSystem.lean` 50,
`FormalSystem/FormalSystem.lean` 107, `FormalSystem/Metalogic/BXCanonical.lean` 43;
`FormalSystem/Bimodal.lean` does not exist; `FormalSystem.lean:8` is
`import FormalSystem.FormalSystem`. C8 comment is at `check-module-invariants.sh:402-407`.

**Gates**: `check-module-invariants.sh --no-build` ALL CHECKS PASSED (C5, C8, C9 PASS);
`readme-lint.sh` still 9 missing / 5 broken. No `Bimodal.lean` reference survives in the README.
