# Phase 12 — `regionFrame` deterministic re-host

**Plan**: `plans/03_omega-free-totality-refactor.md`, Phase 12
**Files modified**: `FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean`
**Verification tier**: interface
**Outcome**: complete; `regionOmega` is no longer a strict subset of `H_F`

## What landed

`regionFrame`'s maximally-permissive task relation `TaskRel s d s' := d = 0 → s = s'` is replaced
by the deterministic clock `TaskRel s d s' := s.1 = s'.1 ∧ s'.2 = s.2 + d`, the exact structural
analogue of `multiFamTaskFrameGen` (`Metalogic/Algebraic/FlowFrame.lean`).

| Declaration | Status |
|---|---|
| `regionFrame` | restated: `WorldState := W × D`, clock relation, three `TaskFrame` fields re-proved |
| `regionFrame_taskRel` | restated to the new relation |
| `regionHistory` | restated: `states r := (w, r + Δ)` |
| `regionHistory_states` | restated |
| `regionFrame_total_eq` | **new** — every total history is a `regionHistory f w Δ` |
| `regionOmega_eq_total` | **new** — `regionOmega f = {σ \| ∀ r, σ.domain r}` |
| `not_regionConstant_regionHistory` | **new** — replaces `regionConstant_regionHistory_zero` |
| `regionConstant_regionHistory_zero` | **removed** — now false (see below) |
| the five interface lemmas | statements byte-identical; proof bodies only |

The five preserved statements are `regionHistory_mem_regionOmega`, `mem_regionOmega_iff`,
`shiftClosed_regionOmega`, `regionOmega_total`, and `truthAt_box_iff_base`. Verified by `git diff`:
no `+`/`-` line touches any of them.

## The design finding the plan did not anticipate

The plan asked only for a new `TaskRel`. **The state space had to change with it.** A state
carrying only a region code provably cannot support a deterministic relation: region-mates
`r ≠ r'` share a code but their `d`-shifts need not. With one placed point at `0`, the mates
`-1/2` and `-2` shift by `1` to `1/2` and `-1`, which straddle it — so no shift function on codes
exists, and no relation defined on codes alone can be functional.

Determinism therefore forces the time *into* the state and the region structure *out* of it, into
the valuation. `ι` and the placement `f` are retained as phantom parameters so that every
statement about `regionOmega f` keeps its shape.

The same argument kills `regionConstant_regionHistory_zero` outright: a deterministic relation
propagates a state along the clock, so a region-constant history would repeat a state at two
distinct times and be periodic. It was removed rather than re-proved, and `not_regionConstant_regionHistory`
records the negation for every offset.

## Verification

- `lake build FormalSystem.Metalogic.Decidability.Verified.Bridge.Omega` — green, no diagnostics.
- 0 sorries, 0 vacuous definitions, 0 new axioms in the file.
- `regionFrame_total_eq` and `regionOmega_eq_total` depend only on `propext`, `Quot.sound` — choice-free.

## Scope Hypothesis: confirmed, better than estimated

Exactly **one** downstream site breaks tree-wide: `Bridge/TruthLemma.lean:319`
(`Unknown identifier regionConstant_regionHistory_zero`). Decision C's spawn contingency is not
triggered. The other five consumer files sit transitively behind that site in the import DAG, so
their true status is unobservable until it is repaired — they may need no edit at all, since they
pass `regionOmega` opaquely through the five stable interface lemmas.

Repair shape for the next phase is recorded inline in the plan under Phase 13
("Inherited from Phase 12") and in `.orchestrator-handoff.json`.
