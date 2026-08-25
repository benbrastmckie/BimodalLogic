# Phase 4 Handoff

**Next action**: Phase 5 (nine missing READMEs). Wave 2 is closed.

**State**: All count and classification tables re-derived from source. ALL CHECKS PASSED.

**Ground truth confirmed at implementation time**:
- 45 axiom constructors, split Base 37 / Dense 2 / Discrete 3 / Dedekind 3, derived from
  `Axiom.minFrameClass` (`Axioms.lean:588`). The plan's hypothesis held exactly.
- `cloc` gives 539 files / 170,898 code / 96,290 comment. Matches ground truth.
- Import numerals re-derived by grep: 9 (`BXCanonical -> WeakCanonical`) and 4
  (`BXCanonical -> Algebraic`). The plan's hypothesis held; `FormalSystem/Metalogic/README.md`
  updated.

**Key decisions**:
- `axiom-reference.md` 253 -> 343 lines. The stale T4/TA/TL/TK temporal section was replaced
  with the real Burgess-Xu until/since axioms; `temp_k_dist`/`temp_4` are now labelled derived
  theorems; a Dedekind layer section was added.
- `operators.md` gained a whole "Primitive Temporal Operators" section (`untl`, `snce`, `next`,
  `kPlus`, `kMinus`) ahead of the derived H/P/G/F section, plus a definition table showing which
  is defined from which. `Derivable` now carries its frame-class parameter.
- Metric tables follow `README.md`'s precedent: the `cloc` command is printed rather than the
  figure being hardcoded in two more places.
- One `.claude/` link in `FEATURE_REGISTRY.md` converted to unlinked prose (Class F), ahead of
  Phase 7.
