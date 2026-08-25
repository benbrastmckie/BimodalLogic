# Phase 6 Handoff

**Next action**: Phase 7 (dead-link repair). The gap content is in place, so the sweep will
validate it too -- which is why Phase 6 was sequenced before Phase 7.

**State**: All 15 gap-coverage terms from report section 7 now hit at least one `docs/` file
(research measured 0 for all but `set_lindenbaum`). ALL CHECKS PASSED; readme-lint PASS.

**Key decisions**:
- G8 (the four-frame-class model) went into `user-guide/architecture.md` as new subsections
  4.2b and 4.2c, lifting the partial-order diagram, the Dedekind-above-Dense argument, the
  TM+_c gap, the soundness caveat, and the `minFrameClass <= fc` invariant from
  `Axioms.lean:461-517`.
- G7 corrected the `set_lindenbaum` placement (it is `Core/MaximalConsistent.lean:303`, not an
  archived `Completeness.lean`) and added subsection 4.2a listing the whole set-based layer.
- G1, G3, G4, G5, G6 went into `API_REFERENCE.md` as six new declaration-level sections, each
  with a line-anchored table.
- G4 and G5's *negative* halves became Limitations 8 and 9 in `known-limitations.md`, framed as
  settled results rather than outstanding work.
- `MODULE_ORGANIZATION.md` gained all five absent subtrees, and its section 1 directory tree
  was replaced -- it described a nested `FormalSystem/Bimodal/` layout that does not exist.

**Note for Phase 7**: the new content adds several relative links. The resolver count should be
re-measured before the sweep rather than assumed to still be 71.
