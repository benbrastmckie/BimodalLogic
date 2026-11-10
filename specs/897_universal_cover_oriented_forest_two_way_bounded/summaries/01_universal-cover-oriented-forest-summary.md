# Implementation Summary: Task #897

- **Task**: 897 - Universal cover of a doubly serial digraph: oriented forest, surjective two-way bounded covering map
- **Status**: [COMPLETED]
- **Started**: 2026-11-09T14:31:42Z
- **Completed**: 2026-11-09T17:05:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_universal-cover-oriented-forest.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Built the universal cover of a one-step relation `E : W → W → Prop` as a dependently-indexed
inductive type of reduced walks, proved its own one-step relation is an oriented forest and doubly
serial, and proved the endpoint projection is surjective and `TwoWayBounded`. Composed with the
already-landed `saturation_of_orientedForest` and `TwoWayBounded.plus_invariance_of_isZTime`, this
makes the cover a regular `FrameOver intOrder` along which L⁺ truth transfers from any regular base
frame — the second half of ROADMAP hypothesis (H5). All seven plan phases are complete, each on its
own commit, with a green full `lake build` at every phase close.

## What Changed

- `FormalSystem/ForMathlib/Combinatorics/SimpleGraphAcyclic.lean` — **new**. Carries
  `SimpleGraph.isAcyclic_of_rank_parent`: a graph is acyclic as soon as it admits a rank
  `rk : V → ℕ` and a parent map `par : V → V` with the rank non-increasing along `par` and every
  adjacency a parent edge across a strict rank drop. Mathlib carries characterisations of
  acyclicity at this pin but no construction-side sufficient condition, so this is written in
  Mathlib's own namespace and staged for upstreaming. Proved through
  `isAcyclic_iff_forall_adj_isBridge` and `isBridge_iff` plus the invariant "some iterate of `par`
  reaches the upper endpoint" carried along walks of the edge-deleted graph — never through
  `Walk.IsCycle`.
- `FormalSystem/Semantics/UniversalCover.lean` — **new**, 519 lines. `RWalk` (reduced walks,
  indexed by origin, endpoint and the last move's direction and pre-vertex), `CoverPt`,
  `RWalk.length`/`parent` and their cover-point projections, `CoverStep` (the one-step relation, as
  an inductive), `coverStep_cases` (the single structural case lemma),
  `coverStep_loopFree`/`oppFree`/`acyclic` and `coverStep_isOrientedForest`, the two one-step lifts
  `exists_coverStep_fwd`/`exists_coverStep_bwd`, double seriality, `endpt_surjective`, the three
  iterated lifts, `coverFrame`, `endpt_twoWayBounded`, and the headline
  `exists_orientedForest_cover`.
- `FormalSystem/Semantics/IntNormalForm.lean` — additive. `FrameOver.ofStepSat` (the
  `Saturation`-parameterised sibling of `ofStep`, for carriers that need not be finite) plus its
  three bridge results; `ofStep` restated as a one-line call to it with its three bridge results
  reduced to citations. No existing signature changed.
- `FormalSystem/ForMathlib.lean`, `FormalSystem/Init.lean`,
  `scripts/CheckInitImportsMain.lean`, `FormalSystem/Semantics.lean`,
  `FormalSystem/Semantics/README.md`, `FormalSystem.lean` — registration of the two new modules.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/ForMathlib/README.md`,
  `FormalSystem/ForMathlib/Combinatorics/README.md`, `typst/generated/status.typ` — regenerated
  surfaces.
- `specs/state.json` — `file_scope` extended with `FormalSystem/Semantics/README.md`, the fifth
  registration surface the plan's file list did not name.

## Decisions

- **The Quiver route was rejected**, as the plan directed: `Mathlib/Combinatorics/Quiver/Covering.lean`
  defines only the covering property and constructs nothing, and would have left the `acyclic`
  field unpaid in full. Its one contribution is kept — its orientation tags confirm the `Bool`
  direction-tag encoding used here is the standard one.
- **Reducedness is structural**, carried by an `Option (Bool × W)` index recording the last move's
  direction and pre-vertex, so the multigraph convention (an opposite-edge pair lifting to two
  distinct edges, a loop lifting to a ray) falls out of the constructors rather than being
  asserted.
- **`RWalk.length` needs explicit equation lemmas.** Defined by structural recursion over a
  three-index inductive, it does *not* reduce by `rfl` at its constructors — the equation compiler
  routes it through `brecOn`. Three `@[simp]` lemmas proved by `simp [length]` restore the
  reductions, and every downstream length equation is discharged by `simp` rather than `rfl`.
  `RWalk.parent`, being non-recursive, does reduce by `rfl`, which is what makes the acyclicity
  criterion's `par y = x` obligations immediate after `cases` on the step relation.
- **The acyclicity invariant runs downward from the upper endpoint.** The natural-looking
  "ancestors of the lower endpoint" predicate is *not* preserved along the edge-deleted graph; the
  descendants of the upper endpoint are. In that invariant's down-branch, the iterate count zero
  names precisely the deleted edge, which is what makes the branch go through.
- **`cases` on `CoverStep` is confined to `coverStep_cases`**, so no `HEq` reaches any later goal.
  Walk destructuring (legitimate, and discriminated by the last-move index) is factored into
  `coverStep_parent_of_last_bwd`/`_fwd`.
- The two order instances in the assembly are passed positionally with `@` and `inferInstanceAs`,
  following the recorded form of `ShiftSet.ofIntAction`, because `SuccOrder ↑intOrder` does not
  synthesise.

## Plan Deviations

- **Testing & Validation, `lake exe lint-style` green** altered: the gate exits 1 on four
  pre-existing "space before a semicolon" findings in
  `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` (lines 383, 390, 413, 420).
  That file is byte-identical to the pre-task baseline commit and is named by nothing this task
  touched, so it is recorded as a baseline delta per Phase 7's own gate instruction rather than
  treated as a blocker.
- No decomposition deviation: every phase's task sequence was executed as written, in order, with
  each specified lemma landed as its own named declaration.

Two plan Scope Hypotheses were **corrected by measurement** rather than deviated from (both are
recorded inline in the plan at their own phases): `FrameOver.ofStep` has four term-level
consumers, not three — `OpenLanguage/OpenOckhamist.lean:145` was not enumerated, and per the
hypothesis's own instruction it was left untouched and verified to still compile; and a fifth
registration surface exists for a new `Semantics/` module, `FormalSystem/Semantics/README.md`'s
hand-maintained inventory row, which was added in Phase 3 rather than deferred.

## Verification

- Build: **Success**. Full `lake build`, 2968 jobs, exit status 0, zero errors and zero warnings
  (CI's `--wfail` would therefore pass). Verdict read at all three tiers: guard exit status, the
  success line with a zero `error:` count over both captured streams, and an
  `.olean`-newer-than-source check for every module this task touched plus the library root.
- Sorry count: **0** (repository-wide census; `grep -rn sorry` returns nothing in either new
  module).
- Vacuous count: **0 attributable**. The repository-wide grep returns exactly one hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, in a file untouched by this task and where
  `trivial` is the honest proof (the total ℤ history's `domain` reduces to `True`).
- Axiom count: **unchanged**, 14 at the pre-task baseline and 14 now. `#print axioms` on each of
  the three pinned identifiers is `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no new
  axiom. `Classical.choice` on `coverFrame` traces to the two cited constructors, which already
  carry it; `endpt_surjective` depends on no axioms at all.
- Tests: **Passed**. `lake test` exit 0.
- Other gates: `check-module-invariants.sh` — C24, C33, C34a, C34b all PASS and
  `--emit-inventory --check` exits 0; `check-metalogic-cycles.sh` exit 0 with assertion B
  unperturbed; `typst-sync-check.sh` PASS on all four checks, `--counts-only` exit 0.
  `verify-deploy.sh --only-gate 4` (task-reference lint) exit 0 — the scoped tier the batch
  deferral directed, with the full gate set deferred to the batch stage rather than independently
  re-run here.
- Plan compliance spot-check: **passed** — all three pinned identifiers resolve in the source
  roots.
- Files verified: Yes.

## Impacts

- `exists_orientedForest_cover` is now available to the two named consumers: the decidability paper
  proof's cover step, and the completeness programme's final-frame step, where the canonical
  quotient digraph is not known to satisfy *Saturation* and can be replaced by its cover.
- `FrameOver.ofStepSat` unblocks any future ℤ-frame construction whose carrier is infinite but
  whose relation satisfies *Saturation* structurally; `FrameOver.ofStep` and all four of its
  consumers are untouched.
- `SimpleGraph.isAcyclic_of_rank_parent` is a reusable, library-independent acyclicity criterion in
  Mathlib's own namespace, staged for upstreaming beside the four existing `ForMathlib` modules.

## Follow-ups

- Countability of the cover is deliberately not claimed; the consumer's countable-model step runs
  inside the cover and is a separate piece of work.
- Unique path lifting and the `Prefunctor.IsCovering` machinery are deliberately not stated, since
  `plus_invariance_of_isZTime` does not consume them. Addable if a consumer needs them.
- The four pre-existing `lint-style` findings in
  `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` are unrelated to this task
  and still open; `lake exe lint-style --fix` would clear them.
- No `Paper:` doc-comment anchor and no `docs/theorem-index.md` row was added, per the plan's own
  decision: C15 resolves paper-anchor citations against a pinned record, and a new anchor for a
  declaration absent from that record would fail the gate for no benefit.

## References

- `specs/897_universal_cover_oriented_forest_two_way_bounded/plans/01_universal-cover-oriented-forest.md`
- `specs/897_universal_cover_oriented_forest_two_way_bounded/reports/01_universal-cover-oriented-forest.md`
- `specs/897_universal_cover_oriented_forest_two_way_bounded/handoffs/`
- `FormalSystem/Semantics/UniversalCover.lean`,
  `FormalSystem/ForMathlib/Combinatorics/SimpleGraphAcyclic.lean`,
  `FormalSystem/Semantics/IntNormalForm.lean`
