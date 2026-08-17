# Implementation Summary: Task #417 — the bi-lasso decision layer (partial, Phase 3 blocked)

- **Task**: 417 - Semantic FMP, finite WorldState over ℤ
- **Plan**: `specs/417_semantic_fmp_finite_worldstate_over_z/plans/04_bi-lasso-decision-layer.md`
- **Status**: PARTIAL — 2 of 9 phases completed, Phase 3 `[BLOCKED]`, Phases 4–9 not started
- **Type**: lean4
- **Date**: 2026-08-17

## Outcome

Phases 1 and 2 landed green and sorry-free. Phase 3 was attacked, and its central deliverable was
**refuted** — machine-checked, sorry-free. Because Phases 4, 5, 7, 8 and 9 all transitively consume
that deliverable, the dispatch stopped there, per the plan's own Rollback/Contingency instruction.

## What Landed

### Phase 1 — spike evidence repaired to guard-first order `[COMPLETED]`

`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`
compiles clean again against the migrated tree. All nine `#print axioms` audits report
`[propext, Classical.choice, Quot.sound]` — no `sorryAx`.

The phase's Scope Hypothesis was **confirmed**: every error in the file was an argument-order
transposition and nothing else drifted. The `FrameClass.base_le` mismatches at `:204`, `:277`,
`:298` looked like independent drift in the pre-edit error list but were metavariable cascades from
the transposition errors upstream, and vanished with them. Three axiom applications
(`self_accum_until`, `absorb_until`, `linear_until`, `until_F`) needed **no** argument change at
all — the guard-first migration left their parameter order intact and only the `Formula.untl` terms
around them moved.

The file's convention paragraph now states guard-first and records the event-first text it replaces
as retired, and names the three coexisting renderings (constructor guard-first, `prettyPrint`
prefix `U(e,g)` event-first, paper infix guard-first).

### Phase 2 — `BiLasso`, `unroll`, `unroll_isStepPath` `[COMPLETED]`

`FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` (316 lines) and its README.

The duplication check for task 441's prefix-plus-cycle datatype was re-run first, as the plan
required, and came back empty: no `Lasso`/`extend_periodic`/periodic-presentation structure exists
anywhere in the live tree, so nothing was reused and nothing collides.

Delivered: `cyc` (`Int.emod`-based cyclic list lookup, total at negative indices), `unrollOf`, the
`BiLasso` structure with `back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`coherent`, `unroll`,
`unroll_sub_back_length` and `unroll_add_fwd_length` (the two periodicities, with explicit
thresholds), `step_of_mem_window`, `unroll_isStepPath`, and `toHF`.

`coherent` is decidable and demonstrably non-vacuous: `flipBiLasso` discharges it by `decide`
against `flipPresentation`'s real adjacency matrix, and the module also exhibits a *failing*
candidate (the constant path, which `flipPresentation` refuses) so the field cannot be silently
`True`.

### Phase 3 — refuted `[BLOCKED]`

The periodicity half of the phase is done (it was needed by, and landed with, Phase 2). The
scan-bound half is false. See the Blocker section below.

## The Blocker

**Phase 3's third task cannot be stated in the form Phases 4 and 5 consume.** The plan asks for:

> any property of `L.unroll` that holds at some `s > t` holds at some `s` with
> `t < s ≤ t + |mid| + |fwd|`

`eval`'s `untl` case searches for a time at which a **formula** holds, not a time at which a
**state predicate** holds, and the truth of a formula along `L.unroll` at `s` is not a function of
`L.unroll s`. Two theorems in
`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean`, both
sorry-free, settle it:

1. `plan_scan_bound_fails` — on a two-state presentation and the bi-lasso `back=[0]`, `mid=[]`,
   `fwd=[1]` (constant `0` left of the origin, constant `1` from the origin rightward), at
   `t = -5` the formula `untl ⊤ p` is true with witness `s = 0`, while `p` is false at every `s` in
   the literal scan range `(-5, -4]`.

2. `no_formula_independent_scan_bound` — for **every** integer `N` there is a formula witnessed
   strictly after `t = -1` but at no time in `(-1, N]`, on that same fixed bi-lasso. The family is
   `prevⁿ p`, whose truth set along the path is exactly `[n, ∞)`. Since `N` ranges over every
   quantity computable from `|back|`, `|mid|`, `|fwd|` and `t`, **no** scan bound that is a
   function of the lasso alone can be correct.

Root cause: `L.unroll (t + |fwd|) = L.unroll t` for `t ≥ |mid|` (proved, and landed), but the
*shifted path* `λ u. L.unroll (u + |fwd|)` is not `L.unroll` — the leftward tail moves. So `TruthAt`
along a bi-lasso is **not** periodic in `t`, and the failure appears already at temporal-nesting
depth 1.

### What a re-plan has to choose between

1. **Formula-dependent threshold.** Prove that the truth set of `ψ` along a bi-lasso is eventually
   periodic beyond an explicit `ψ`-dependent threshold, then restate the scan bounds against it and
   carry the threshold through `eval`. Substantially larger than Phase 3 is sized for, and it
   rewrites Phases 4 and 5.

2. **Annotated bi-lassos.** Enumerate bi-lassos carrying per-position *type* labels with local
   consistency conditions — a Hintikka structure over the lasso — and replace `eval` by a label
   read-off, making the truth lemma a Hintikka-structure argument. This *dissolves* the periodicity
   problem instead of solving it: repeated positions carry equal types by construction. It is also
   the shape Phase 7's `(state, type, pending)` pigeonhole already anticipates, so it merges Phases
   3–5 into the small-model construction rather than layering them before it.

Route 2 looks like the better fit with Phase 7 as already written.

## Verification

| Gate | Result |
|------|--------|
| `lake build` | exits 0 |
| Live sorry count | exactly 1 (`countermodel_discrete`, `WeakCanonical/Transfer.lean`) — C3 PASS |
| Flagship axiom sets | C2 PASS, match baseline |
| Vacuous definitions in new code | 0 |
| New `axiom` declarations | 0 |
| `check-module-invariants.sh` | 3 groups fail — C1 (`BimodalTest` `#guard_msgs` drift), C6, C9 — **identical to the Phase 1 baseline**, no regression |
| `readme-lint.sh` | no new warnings attributable to this work |
| `.claude/scripts/check-task-references.sh` | PASS |
| `lake env lean` on the repaired spike | exits 0, nine `#print axioms`, no `sorryAx` |
| `lake env lean` on the Phase 3 refutation | exits 0, three `#print axioms`, no `sorryAx` |

The new module is deliberately unwired (nothing imports it until its re-export lands), so it was
added to `scripts/module-invariants-manifest.txt` — the repository's own mechanism for known
unreachable live modules — which keeps it compile-checked in isolation and keeps C6's absent-count
at the baseline 7. That line is to be **deleted** when the re-export lands.

## Plan Deviations

- **Phase 2, `coherent` field shape** — *altered*. The plan asked for "adjacency within each
  segment, the three seams, and the two wrap-arounds". Indexing both cyclic segments left-to-right
  in time through an `Int.emod`-based `cyc` collapses all of those into a single contiguous window
  `[-|back|-1, |mid|+|fwd|)`; every other time reduces into it modulo the relevant cycle length.
  Same content, fewer clauses, same decidability. The window is quantified as
  `∀ i : Fin (|back|+1+|mid|+|fwd|)` rather than over a `Finset.Ico` on ℤ, because `Finset.Ico` at ℤ
  is not in this module's transitive imports while `Fin` needs none.
- **Phase 3, the two periodicity lemmas** — *altered*. Landed in `BiLasso/Basic.lean` rather than a
  new `Unroll.lean`, in the stronger explicit-threshold form (`t < 0` / `|mid| ≤ t`) rather than the
  plan's existential form, because `unroll_isStepPath` in Phase 2 already needed them. No
  `Unroll.lean` was created.
- **Phase 3, the scan bounds** — *blocked*, not deviated. Refuted; see above.
- **Phases 4, 5, 7, 8, 9** — not started; all transitively consume the blocked result.
- **Phase 6** — not started. It depends only on Phase 2 and remains independently executable, but
  the plan's Rollback/Contingency directs the dispatch to stop on a blocked phase.

## Artifacts

- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` (new)
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (new)
- `FormalSystem/Metalogic/Decidability/README.md` (module-table row + related-docs link)
- `scripts/module-invariants-manifest.txt` (one entry, to be deleted at re-export)
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean` (repaired)
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean` (new)
- `specs/417_semantic_fmp_finite_worldstate_over_z/plans/04_bi-lasso-decision-layer.md` (status markers + blocker record)

## Next Action

**Not** `/implement 417` again. Re-plan Phases 3–5 around one of the two routes above, with route 2
as the recommended starting point. Task B (the filtered step relation) and Task C (the semantic FMP
assembly) remain deferred and unchanged: B is still blocked on task 450, C on both A and B.
