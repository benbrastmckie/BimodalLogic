# Phase 3 handoff — task 663

**Next action**: Phase 4 — the three downstream declarations in `Constraint.lean`
(`nonempty_of_mem_Constraints`, `exists_mem_subset_inter`, `constraint`).

**State**: Phases 1, 2, 3 [COMPLETED]. `Constraint.lean` builds green (1178 jobs, 0 errors,
0 warnings). Four matched pairs landed:
`fib_zero_subset_of_compositional_limit`/`fib_zero_subset`,
`fib_zero_subset_mem_of_compositional_limit`/`fib_zero_subset_of_mem_Constraints`,
`nonempty_fib_of_serial_limit`/`nonempty_fib_of_serial`,
`nonempty_seg_of_compositional_limit`/`nonempty_seg_of_interpolates`.

**Projections that carry the whole set** (verified in `Semantics/TaskFrame.lean`):
`TaskFrame.forward_of_comp` (905), `TaskFrame.interpolates_of_comp` (911),
`TaskFrame.nullity_of_serial_limit` (939), `FrameOver.reflection_of_limit` (1336, applied as
`F.toFibre.reflection_of_limit hlim`). `F.serial`/`F.comp`/`F.limit` are the instance projections
the corollaries feed back in.

**Open item for Phase 6**: C34a as the plan words it would fail on every corollary this phase
created (marker omits *Saturation*, binder present). Resolution recorded on the Phase 3 heading:
C34a gains a DELEGATION discharge — a marked, binder-carrying declaration passes iff its code
names another marked declaration with the identical list and no binder.
