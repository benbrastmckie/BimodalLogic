# Phase 2 Finalization: Open-Arm Contract Repair and Time-Linearity Scheduling

Phase 2 (Calculus Completion) is **[COMPLETED]**. Two of eight phases done.

## What was done

### 1. The soundness defect: split-fold open-arm contract

`expandBranchWithFuel`'s split fold short-circuited on the first sub-branch that came back
`.inr` and abandoned the remaining arms. Such a branch is open only in the *unblocked* sense
(`findUnexpanded ≠ none`), so `buildTableau` then ran `saturateBlocked` on it, closed it, and
reported `.allClosed` — counting the abandoned siblings as closed and answering *valid* for an
invalid formula.

The repair settles each arm **where its siblings are still in scope**. `Saturation.resolveOpenArm`
runs the post-blocking pass the caller used to run and reports one of three things:

| Result | Meaning | Fold behaviour |
|---|---|---|
| `some (.inl _)` | arm closes under post-blocking | continue with siblings |
| `some (.inr r)` | arm is open **and** saturated | short-circuit (sound: a real countermodel) |
| `none` | undecided | propagate as fuel exhaustion — **never** a closure |

The third row is what makes this a repair rather than a rearrangement: an arm that cannot be
settled must not be silently counted as closed.

Supporting changes: `saturateBlocked` moved above `expandBranchWithFuel` for definition order;
`saturateBlockedCancellable` moved likewise and `resolveOpenArmCancellable` added so the `IO`
mirror stays a line-for-line transcription. `resolveOpenArm_inr` carries the
`findClosure = none` invariant through the new layer, so `expandBranchWithFuel_sound` and
`blocking_sound` are unchanged in statement; the two `tryBranch` helpers and the two `foldl`
helpers gained one nested layer apiece.

**Gate met**: measured verdict-neutral on its own, with the linearity stage still unwired —
both builds green at 38.6 s (baseline 39 s), zero `#guard_msgs` movement.

### 2. Sub-phase 2.7b: scheduling `timeLinearity`

Wired into `expandOnce` / `expandOnceUnblocked` as the third stage, after seriality. The
third-stage cases in `expandOnceUnblocked_pick_ne_nil` / `_adds_new` are discharged by the two
existing stage lemmas — the stage only ever reports `.branchingOrdered`, so it cannot be the
source of an `.extended` step.

**Gates met**:

- **C4** (`F p → F(F p)` at `.Base`, `target=OPEN`) **stays OPEN**. The countermodel survives.
  This is the row that flipped CLOSED under the broken contract and caused the stage to be
  withheld.
- Seriality and K-rows stay CLOSED; every other conformance row, all four class tables, both
  counterexamples, the BX*/R* families and the CertificateProbe rows are unmoved.
- **All seven W-rows** read `total=true incomparable=[]` — 2.7's done-criterion, met.

### 3. Bounded, measured budget raises

Two pinned budgets had been tuned before the third stage existed and both needed raising.
Neither can change a verdict — only whether one is reached.

- **`linearityFuel = 400`** (per-row, W1–W4). The three-way split divides the budget
  proportionally and these rows order eight to ten times each. Boundary measured: `STALLED` at
  200/250/280; W2 flips at 280, W4 at 350, all four at 400; stable through 800/1200/2000.
  W5/W6 clear at `conformanceFuel = 200` and were left on it. W7 (W1 at 2000) is identical, so
  the flip is the rule firing, not the budget.
- **`labelWallclockTimeoutMs = 3000`**, replacing four scattered `1000` defaults. `□p → □q` now
  takes 1473 ms; every other smoke-corpus row still decides correctly and all but that one
  finish in ≤ 19 ms. Exceeding the budget yields `.timeout`, the conservative label.

## Verification

| Check | Result |
|---|---|
| `lake build` | green (137 s) |
| `lake build BimodalTest` | green (64 s; baseline 39 s) |
| New sorries | 0 |
| New axioms | 0 |
| New vacuous definitions | 0 |
| `#guard_msgs` movement | seven W-rows only, all in the intended direction |

**Cost recorded, not absorbed**: `TableauConformance` 36 s → 59 s, suite 39 s → 61–64 s. That is
the price of a third splitting stage over the times seriality mints at every label. No attempt
was made to buy it back by narrowing `firstIncomparablePair`, which is settled design.

## A forecast that did not survive

The previous dispatch measured that wiring the stage also *repaired* C4 at `.Dense`/`.Dedekind`
(`OPEN [DEFECT]` → `CLOSED`, matching target). Re-measured under the repaired contract, those
rows stay `OPEN [DEFECT]`: the apparent repair was an artifact of the same abandoned-sibling
defect. No regression — they were `OPEN [DEFECT]` before and after — but it was never bankable,
and pinning it would have recorded a wrong expectation.

## Contract change for downstream phases

Recorded as `ENGINE CONTRACT CHANGE` notes under Phase 5 and Phase 7 of the plan, and in the
rewritten "Time linearity" section of `Tableau.lean`:

1. A `.inr` result out of a split arm is now fully saturated, not merely unblocked-saturated.
2. `.allClosed` now means every sub-branch genuinely closed.
3. An unsettleable arm surfaces as `none`/`STALLED` — read it as "decided nothing", never as a
   negative answer.
4. `expandBranchWithFuel_sound` / `blocking_sound` unchanged in statement.

**Outstanding, flagged not fixed**: the `expandBranchWithFuelTracedImpl` mirror does not carry
the repair. It feeds trace certificates only and no corpus row reads a verdict off it, so it is
not a live defect — but any later phase that starts reading verdicts from the traced mirror must
sync it first.

## Commits

- `f52f86ff4` repair split-fold open-arm contract (`resolveOpenArm`)
- `7681d9132` schedule `timeLinearity` as the third expansion stage
- `81edb0e4a` close Phase 2 — resolve blocker, record contract change
