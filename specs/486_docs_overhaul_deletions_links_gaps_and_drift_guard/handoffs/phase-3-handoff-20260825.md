# Phase 3 Handoff

**Next action**: Phase 4 (counts, classification, reference layer).

**State**: Five false-status documents corrected. ALL CHECKS PASSED. Every
`FormalSystem/...` slash path in `BFMCS_ARCHITECTURE.md` now resolves on disk.

**Key decisions**:
- `BFMCS_ARCHITECTURE.md` 377 -> 302 lines. Section 4 (Lacunae Inventory) and section 5.2
  (Sorry Propagation) deleted; sections renumbered; the six nonexistent theorems in the 5.1
  chain replaced with the real chain; the appendix's five task-number citations rewritten as
  prose.
- The document's BFMCS/BMCS ontology names were inverted relative to the tree. Corrected to
  `FMCS` (single history, `FMCSDef.lean:103`) and `BFMCS` (bundle, `BFMCS.lean:91`). The
  removed `forward_F`/`backward_P` structure fields are now explained rather than shown.
- `architecture.md`'s 57-line `Logos/` tree replaced with the real `FormalSystem/` tree.
- Metric drift in `implementation-status.md` fixed here rather than Phase 4, per file ownership.

**Carry-forward for Phase 4**: `docs/project-info/README.md:131` still asserts the false
Base-frame residual proof debt -- it is Phase 4's exclusive file.
