# Task 690 — Progressive Handoff after Stage A and Phase 6

- **Session**: sess_1790617342_e2d44f, dispatch_seq 9
- **Plan**: `specs/690_stability_condition_over_branching_frame/plans/01_stability-condition-branching-frame.md`
- **Written at**: end of Phase 6 (22 phases total)

## Immediate next action

Phase 7 (`PlusWitnessFamily/Closure.lean`) is written and building; if its build is
green, commit it and start **Phase 8** (`PlusWitnessFamily/Basic.lean` —
`PlusLabelledLasso` and `PlusWitnessFamily`, transcribed from
`WitnessFamily/Basic.lean`'s 201 lines). Watch the `deriving DecidableEq` on
`PlusLabelledLasso`; if it does not derive, hand-write the instance rather than
dropping it.

## Phases closed

| Phase | State | Commit |
|---|---|---|
| 1 Substrate measurement | COMPLETED | `71cc381d7` |
| 2 `Skeleton.lean` — `rep`, `share` | COMPLETED | `7eb4897a3` |
| 3 Skeleton — `Thread`, `Step`, `ReachN` | COMPLETED | `6cdc7bf16` |
| 4–5 Skeleton — frame, histories, Stage A closeout | COMPLETED (one atomic batch) | `2328f2c0e` |
| 6 L⁺ subformulas and `plusSubformulaClosure` | COMPLETED | `e0bf6ffbb` |

Stage A is complete and green. `SharingSkeleton` (944 lines) carries the whole
label-free substrate; `Sharing/{Basic,Thread,Frame,Histories}.lean` are re-export
shells (208/179/258/105 lines) and every name they exported resolves at its
original statement. `Predicates.lean`, `Decide.lean`, `Fulfil.lean`,
`Agreement.lean`, `Specialize.lean` are unmodified.

## Three shell mechanisms a successor must not undo

1. `SharingWitnessFamily.skeleton` is `@[reducible]`. Without it `Fin S.skeleton.n`
   and `Fin S.lassos.length` do not unify at the transparency `rw`'s keyed matching
   uses, and `Fulfil.lean:1177` fails.
2. `SharingWitnessFamily.Thread.step` is restated at the family's own `share`
   beside the `abbrev Thread`. Dot notation resolves the family name first; the
   skeleton's field is stated at `S.skeleton.share`, which breaks
   `Fulfil.lean:1137`'s `rw [S.share_def]`.
3. `SharingWitnessFamily.Conn` is restated *definitionally* (the `if`), not
   delegated, because `Specialize.lean:282` does
   `unfold SharingWitnessFamily.Conn` and then `split`s. `conn_eq_skeleton`
   records that it is the same proposition.

The `conn_*` delegating lemmas in `Sharing/Frame.lean` pass `(K := S.skeleton)`
explicitly; without it the skeleton lemma's implicit `K` cannot be inferred from a
goal whose head is the family-level `Conn`.

## Phase 1 findings that gate later phases

Recorded in full at
`specs/690_stability_condition_over_branching_frame/.measurements/01_substrate-measurement.md`
(gitignored — regenerate it from the commands quoted there if it is lost).

- **F-M1**: `Fulfil.lean`'s measured label-dependent span is **723 lines**, not the
  ≈400 research estimated. The plan's own Phase 16 trigger is ≈700, so this **trips
  the gate**. Phases 16–17 must not start on the plan's current budget without
  resolving it.
- **F-M3**: the position graph does **not** factor onto the bare `SharingSkeleton`.
  `perBack`/`perFwd`/`perMid` join the skeleton's `rep*` lengths with the lassos'
  *label* segment lengths, so `cohWindowLo`/`cohWindowHi` — and therefore `verts`,
  `nextTime`, `prevTime`, `succF`, `predF` — are not functions of the skeleton
  alone. Recommended resolution: a `SharingWindow` structure extending
  `SharingSkeleton` with the combined-period triple `(NB, NF, NM)` and its three
  positivity facts, added in Phase 13 (~60 lines). This is additive to Stage A, not
  a revision of it.
- **F-M2 / Phase 13**: `Decide.lean`'s measured label-dependent span is 215 lines,
  confirming Phase 13's ≈250 estimate with margin.

## Territory: concurrent siblings

Tasks 623 and 684 are implementing on this same tree.

- **684** owns `WitnessFamily/{Agreement,Basic,README.md}.lean`,
  `WitnessFamily.lean`, and has added `Sharing/Stability.lean` (174 lines). It
  consumes `total_eq_thread`, `share_of_cls_eq`, `cls_eq`, `Thread.const`, and
  re-verified green against this task's Stage A in `24943b3a0`.
- **623** owns `BiLasso/**`, `Decidability.lean`, `FormalSystem.lean`,
  `docs/theorem-index.md`, `scripts/check-module-invariants.sh`, and has added
  `WitnessFamily/Compression/**`.

**Open foreign breakage, not this task's**: at `09681b812` the full `lake build`
fails with

```
FormalSystem.lean:1:0: import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly
failed, environment already contains 'FormalSystem.Metalogic.Decidability.decidableValidZTime'
from FormalSystem.Metalogic.Decidability.BiLasso.Assembly
```

Do not fix it. `FormalSystem.MainResults`, `...WitnessFamily` and
`...Sharing.Specialize` all build green, which is the evidence this task's own work
rests on.

## Deferred to Phase 22 (registration), per plan R1

- `Sharing/Skeleton.lean` is not listed in `WitnessFamily.lean` (it is reachable
  via `Sharing/Basic.lean`'s import, so the build is fine). C33 reports it as one
  of 11 modules missing from `FormalSystem.lean`; 10 of those predate this task.
- `FormalSystem/PlusLanguage/Subformulas.lean` is not yet in `PlusLanguage.lean`.
- `PlusWitnessFamily/` has no sibling aggregator yet (invariant C8).
- The `INV` stale-inventory failure: regenerating it (`--emit-inventory`) would
  sweep siblings' new files into this task's commit, so it is deferred.

## Verification state

- `lean-sorry-census.sh`: `sorry_count: 0`
- `#print axioms` over the twelve baselined Sharing declarations: byte-identical to
  the Phase 1 record, all `[propext, Classical.choice, Quot.sound]`
- `WitnessFamily/Examples.lean`'s six `#guard`s fire
- `check-module-invariants.sh --no-build`: every failure compared against the same
  run at `71cc381d7`; the only new row attributable to this task is C33's
  `Sharing.Skeleton`
