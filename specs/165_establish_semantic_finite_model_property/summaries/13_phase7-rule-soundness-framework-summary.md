# Phase 7, thirteenth dispatch — sub-phase 7.2 opened: satisfiability preservation, eleven rules

**Status**: 7.2 STARTED, not closed. Phase 7 remains `[PARTIAL]`.
**Plan**: `plans/01_tableau-decidability-two-track.md`, banner `PHASE 7 STATUS (2026-07-28r)`.

## What this dispatch was for

7.1a–7.1e were closed by the twelfth dispatch: the signed truth lemma and all four headline
results are sorry-free at `ℤ`, `ℚ` and `ℝ`. What Phase 7 still owed was 7.2 then 7.3, in that
order, because `valid_iff_allClosed` is an iff whose `allClosed → valid` direction *is* 7.2.

7.2 was greenfield, and measurement in the prior dispatch had confirmed it: no
`Verified/Decidable.lean`, and no satisfiability-preservation notion anywhere in
`FormalSystem/Metalogic/Decidability/`.

## What landed

Two green commits, each content-verified with `git show --stat`.

**Commit 1 — the framework and the truth-functional family** (+496 new, +7 registry).
`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`, registered in
`FormalSystem/Metalogic/Decidability.lean`:

- `SatAt` / `SatState` — satisfaction of a signed formula and of a branch. A model, a
  shift-closed `Ω`, an interpretation of world labels landing **inside `Ω`**, and an
  interpretation of time labels **respecting the abstract `TimeOrdering`**.
- `SatResult` — satisfiability preservation stated against `applyRule`'s own return type,
  `RuleResult × TimeOrdering`, so the ordering a fresh-time rule returns is part of the
  obligation. `.branching` is the only constructor carrying a disjunction.
- `RuleSound C r`, indexed by a `CarrierProp`, plus `RuleSound.mono`.
- The eight truth-functional rules, sorry-free.

**Commit 2 — the label-preserving modal family and a measurement** (+195/-8, plus a 96-line
probe). `ruleSound_boxPos` and `ruleSound_diamondNeg` from `histMem` alone;
`ruleSound_boxTemporal` from shift-closure via the two new point-form lemmas
`truthAt_allFuture_of_box` and `truthAt_allPast_of_box`. `SatState` gained a `shiftClosed` field
in this commit — not designed in, but forced: `boxTemporal` is unsound without it.

## Three findings worth carrying

**1. Probe before proving refuted the dispatch's own suspicion.** `boxNeg` and `diamondPos` copy
`G`/`H`/`F`-neg/`P`-neg/`U`-neg/`S`-neg formulas from *any* world to the freshly minted world.
That step has no evident semantic justification, and the natural next move was to write it up as
an engine soundness defect. It was measured first
(`Tests/BimodalTest/CrossWorldPropagationProbe.lean`): three invalid shapes chosen to expose an
unsound copy as a **wrong verdict** all report the correct `false`, beside a `true` and a `false`
control. No defect is claimed — there is no counterexample. The *proof* obligation stays open and
is stated in the module rather than papered over with a sorry. "No wrong verdict on three shapes"
and "the step preserves satisfiability" are independent, and the write-up says so.

**2. Grepping the tree first was right, and reusing was still the wrong call.**
`Metalogic.Soundness.modal_future_valid` states exactly the future half `boxTemporal` needs.
Importing it would pull the whole soundness tree into the decidability tree's build for half of
one rule, and the past dual does not exist there at all. Both halves were derived from the
primitive `modal_future_valid` itself uses, `TimeShift.time_shift_preserves_truth`, in eight
lines. Grep first; then decide on the *edge*, not only on the lemma.

**3. The fork that stopped the dispatch, named rather than guessed.** The four temporal universal
rules propagate along `futureOf`/`pastOf`, the transitive closure, which `ordResp` (stated on raw
constraints) does not reach directly. Either route the BFS path facts through
`TimeOrdering.bfsClosure_sound`/`PathN` in `Verified/Termination/Fuel.lean`, or strengthen
`ordResp` to `strictBefore` and push the same reasoning into the fresh-time rules that must
re-establish it. Producers and consumers pull in opposite directions, so it is a measurable
question, and it was not settled by guess at the end of a dispatch. Nothing speculative was
written into the definition.

## Verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.Decidability` | green, 1117 jobs |
| `lake build` (full) | **green, 1941 jobs** (1939 baseline + the new module and probe) |
| `lake build BimodalTest` | green, 1987 jobs; all 5 new `#guard_msgs` rows pinned |
| `lake env lean` on `Verified/Decidable.lean` | green |
| sorry census over `Verified/` | `0` |
| vacuous definitions over `Decidability/` | `0` |
| `^axiom ` over `Decidability/` | `0` |

## What Phase 7 still owes

7.2: `boxNeg`/`diamondPos` (obligation stated, measurement recorded), the eight temporal
quantifier rules, the four `untl`/`snce` rules, `orderTrichotomy`, the eight frame-class-gated
rules, and the assembly `∀ r ∈ allRulesForFC fc, RuleSound _ r` via `mem_allRulesForFC_iff`.
Then 7.3.

## Environment

Concurrent sessions (tasks 408/414/415) were quiet. Nothing under
`WeakCanonical/DenseModelSurgery/**` or `specs/408_*`, `specs/414_*`, `specs/415_*` was touched,
staged, committed or reverted; a task-408 untracked scratch file appeared mid-dispatch and was
correctly left unstaged. Staging was by explicit path throughout.
