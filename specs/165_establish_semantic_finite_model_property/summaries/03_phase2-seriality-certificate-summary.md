# Implementation Summary: Phase 2 — Seriality, Progress Lemmas, and the R5 Certificate

- **Task**: 165 — establish_semantic_finite_model_property (tableau decidability)
- **Type**: lean4
- **Mode**: `--hard`
- **Session**: sess_1785198629_c14175
- **Phase**: 2 (Calculus Completion) — now `[PARTIAL]`, one sub-phase remaining
- **Plan**: `plans/01_tableau-decidability-two-track.md`
- **Authoritative input**: `reports/05_seriality-performance-and-length-lemma.md`

---

## Outcome

Phase 2 went from four open sub-phases to one. Sub-phases **2.6**, the **2.5 residual**, and
**2.4** all landed, each verified green and committed separately. **2.7** is the sole remaining
sub-phase and was deliberately not begun.

| Sub-phase | Before | After |
|---|---|---|
| 2.8 | complete | complete |
| 2.5 | complete except `expandOnce_length_lt` | **complete** |
| 2.6 | attempted, backed out on performance | **complete** |
| 2.7 | not started | not started (sized and scoped) |
| 2.4 | not started | **complete** |

Verification: `lake build` and `lake build BimodalTest` both exit 0. Zero sorries in the
Decidability tree, zero new sorries anywhere, zero axioms, zero new vacuous definitions. Build
times are at or below baseline: `…Decidability.Saturation` 6.8 s (34 `PASS`, zero `FAIL`),
`BimodalTest.TableauConformance` 35 s, `lake build` 25 s.

---

## 0. Plan deltas transcribed

Report 05's three deltas were written into the plan in place, as a dated second revision note,
before any of them was implemented:

1. **2.4's certificate stays a single conjunct.** The previously-planned
   `∨ (findBlockedTime …).isSome` disjunct was deleted before it was written.
2. **Phase 7.1 gains a documentation obligation, not a hypothesis change.** This supersedes
   revision item 5 of the first revision note, which is struck through in place rather than
   deleted.
3. **2.7's done-criterion baseline moves** to "all seven W-rows read `total=true`".

Also transcribed: the `expandOnce_length_lt` → `expandOnceUnblocked_length_lt` renaming with its
call-graph justification, the `expandOnceUnblocked_adds_new` addition and the Phase 4.3
redirection, and the replacement of 2.6's `BLOCKER` block with a resolution note carrying the
root cause and the before/after table.

## 1. Sub-phase 2.6 — `serialityRule` with globally-last scheduling

The preserved WIP patch applied unchanged. The whole additional fix is `blockCandidates`:

```lean
def blockCandidates (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  ancestorTimes ord t ++ (ord.futureOf t).filter (fun t' => t' < t)
```

swapped into `isTemporallyBlockedSaturated`. `ancestorTimes` is `ord.pastOf`, so a time minted by
`somePastPos` — a new global minimum — had empty `pastOf` and could never be blocked, and the
past-directed serial chain ran to fuel exhaustion. The `t' < t` filter keeps the added arm
well-founded, because fresh times are `maxTime + 1` and numeric order is therefore creation order.

**Corpus movement, exactly as report 05 predicted**: `S1`-`S5` and `K2`-`K6` flip
`OPEN [DEFECT]` → `CLOSED` in all four frame classes; the `.Discrete` `K2`/`K3` residual **closes**
rather than needing documentation. The seven `TimeOrderProbe` rows were re-pinned, with W5/W6
regressing `total=true → false` — expected, and 2.7's to repair. Every control, both
counterexamples, and the `BX*`/`R*` families are unmoved. Fuel stays 200.

### The finding neither report predicted

`lake build BimodalTest` failed on `Automation/C5SmokeTest.lean`, which was green at baseline:
27 assertions, every one an invalid formula reporting `timeout`. The cause was a stale mirror.
`saturateBlockedCancellable` called `expandOnce` where the pure `saturateBlocked` calls
`expandOnceNoFresh`. `expandOnce` picks over *all* times and carries the new seriality stage, so
on an open branch it never reports `.saturated`; `buildTableauCancellable`'s closing check then
returned `none`, surfacing as `.fuelExhausted`. Measured: the cancellable path answered `NONE` at
every fuel from 7 to 500 on `p` and `⊥` while the pure engine answered `OPEN` at all of them.

Both research reports stopped their measurements at `…Decidability.Saturation` and
`BimodalTest.TableauConformance`; neither ever built this consumer. The lesson is recorded as a
memory candidate.

## 2. Sub-phase 2.5 residual — the progress lemmas

Restated for `expandOnceUnblocked`, since `expandBranchWithFuel` reaches it through
`expandOnceUnblockedWithApplied` and nothing on the proof path calls the bare `expandOnce`.

The previous dispatch's diagnosis was wrong in the way report 05 said: `split at h` cannot see
through the `Prod.fst` projection, so the seven `isEmpty` guards inside `applyRule` were never
opened and the surviving goal only *looked* like a `filterMap` obligation. Interleaving
`simp only [apply_ite Prod.fst] at h` opens them all; no helper lemma of any shape is needed.
Both traps are recorded in-file, including that `first | simp_all | <fallback>` never reaches
its fallback.

Landed sorry-free: the five report-verbatim lemmas, plus `findApplicableSerialRule_not_linear`,
`pick_extended` (the result tail factored over an abstract pick, which is what lets the two-stage
seriality pick be destructured afterwards), `expandOnceUnblocked_pick_ne_nil` and
`expandOnceUnblocked_length_lt`.

Then the companion the fuel bound can actually consume:

```lean
theorem expandOnceUnblocked_adds_new … : b ⊆ nb ∧ ∃ g ∈ nb, g ∉ b
```

Strict length increase does not bound the step count, because `nb = fs ++ b` may re-add formulas
already present. Set growth does. Supporting it required two things the `ne_nil` chain did not:
freshness (`le_maxTime` / `le_maxWorld` and their `nextTime`/`nextWorld` corollaries, which are
what make `densityRule`'s interpolant and every fresh-label witness off-branch) and a bridge from
`Branch.contains` — which is `b.any (· == ·)`, not `List.contains`, so the standard membership
simp set does not reach it — to membership.

## 3. Sub-phase 2.4 — R5 certificate strengthening

```lean
| hasOpen (openBranch : Branch) (timeOrdering : TimeOrdering) (fc : FrameClass)
    (saturated : findUnexpanded openBranch (timeOrd := timeOrdering) (fc := fc) = none)
```

The applied set is gone from the certificate; the `FrameClass` arrives in its place, so arity is
unchanged and the ~50 `.hasOpen _ _ _ _` wildcards in the inline eval suites needed no edit. Both
`buildTableau` sites and their `buildTableauCancellable` mirrors now pass the tableau's own class,
repairing the latent defect in which the check's `fc` defaulted to `.Base` for all four classes.
`extractCountermodelSimple` takes the stronger hypothesis — the same one the `sat_*` family
already wanted.

**No verdict moved anywhere.** The only `#guard_msgs` blocks that changed are the two
`CertificateProbe` rows, rewritten because there is no applied set left to count. They now pin
reachability of the stronger predicate, the certified class, and the branch shape. The
genuinely-open `G p → p` certifies, which is the measurement that refuted the disjunction.

`AppliedRedundant` and `appliedEntryRedundant` are retained as history with zero dependents.

---

## Plan deviations

Two, both raised in `.orchestrator-handoff.json` rather than only annotated, per
`.claude/rules/plan-compliance.md`:

1. **`saturateBlockedCancellable` resynced to `expandOnceNoFresh`** — unplanned, forced, and
   described above. Without it `lake build BimodalTest` does not pass.
2. **2.4 executed before 2.7**, reversing the plan's `2.6 → 2.7 → 2.4`. 2.4's declared dependency
   is on 2.5 and 2.6, both of which landed in this dispatch, and nothing in 2.4 reads 2.7's
   output. The reason is budget: 2.7 is a 57-site refactor of `RuleResult`/`ExpansionResult`
   across six files, and starting it without finishing would have left the tree red and delivered
   neither sub-phase.

## What remains in Phase 2

Sub-phase 2.7 only, scoped in the plan and the handoff. One decision should be raised before code
is written: the plan calls the change "Additive" but writes
`ExpansionResult.split (branches : List (Branch × TimeOrdering))`, which is a breaking payload
change at all 57 sites, whereas an additive `splitOrdered` / `branchingOrdered` pair leaves every
existing consumer's behaviour verbatim. The done-criterion baseline is already pinned and current:
all seven `TimeOrderProbe` rows read `total=false` today and must all read `total=true`.
