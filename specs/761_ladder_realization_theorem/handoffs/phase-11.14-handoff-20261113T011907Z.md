# Phase 11.14 Handoff: The `hself` Derivability Decision Probe

- **Task**: 761
- **Phase**: 11.14 — The `hself` Derivability Decision Probe
- **Dispatch**: seq 34, session `sess_1794531400_b511e7`
- **Written**: 2026-11-13T01:19:07Z
- **Plan**: `specs/761_ladder_realization_theorem/plans/12_hself-disposition-gate-settlement.md`

## THE VERDICT: NOT DERIVABLE

Recorded in the form Phase 11.16's first task reads: **the branch taken, the compiled
declaration's name, and what the branch implies for each of the three dispositions.** No
recommendation on the Stage 0 ruling is recorded here or anywhere in this phase's output.

- **Branch taken**: **NOT DERIVABLE**, with a second compiled half the plan did not require —
  `hself` is also not REFUTABLE, so it is a genuine *independent* premise rather than either a
  consequence of the recorded binders or a defect in them.
- **Compiled declarations** (all in
  `specs/evidence/seam-gluing-ray-product/ladder-self-loop-derivability-decision.lean`, namespace
  `Probe761SelfLoop`):

| Declaration | What it compiles |
|-------------|------------------|
| `hself_not_derivable` | THE VERDICT. The universally quantified implication from `exists_ladderPath_at_region_of_idle_past`'s recorded binders (`hg`, `hl`, `hcl`, `hidle`, `hrep`, `hv`, `hvreg`) to `hself` is FALSE — refuted with `Fintype Q` ASSUMED |
| `instance_is_in_regime` | NON-VACUITY. Every binder of that declaration holds at the instance, in the declaration's own order |
| `instance_self_loop_fails` | the failing self-loop: a compiled ladder path, an idle `p = 0 ≤ a = 1`, and `stepD (objAt gW 0) (objAt gW 0) = false` |
| `hself_satisfiable_at_an_instance` | the independence half: the SAME walk over a total `step` satisfies every binder AND `hself` |
| `idle_successor_differs` | the gap the derivation stalls on, isolated at the instance |

- **Axioms**: every headline reports exactly `[propext, Classical.choice, Quot.sound]` —
  a subset of the permitted set. No `sorryAx`, no custom axiom, no `native_decide`, no raised
  `maxRecDepth` or `maxHeartbeats`.

### What the branch implies for each of the three dispositions

- **Disposition (R)** — in-library repair, `hself` discharged, no binder at all — is **CLOSED by
  this probe.** `hself_not_derivable` refutes exactly the implication (R) needs, and refutes it
  even under `Fintype Q`, which is strictly stronger than what the two landed declarations need
  (both sit in `LadderAgree.lean`'s `section Path`, whose variable block carries no finiteness
  instance). Phase 11.16's branch (R) is therefore not available on the mathematics, independently
  of any ruling.
- **The two remaining dispositions are UNTOUCHED by this probe.** Because `hself` is independent
  (not derivable and not refutable), the recorded blocks of Phases 11.12 and 11.13 are not wrong
  about the mathematics — they are silent about one true premise. The choice between the two
  remaining dispositions is consequently a choice between two honest naming conventions, not
  between a correct and an incorrect statement. **This phase states no preference between them.**

## The instance

```
carrier          Qd = Fin 2,  pendD 0 = false (idle),  pendD 1 = true (pending)
object relation  stepD q q' = decide (q = 1 ∨ q' = 1)      -- so stepD 0 0 = false
walk             period 4: objW u = 0 iff u % 4 = 0, else 1   (idle, pending, pending, pending)
countdown        cntW u = 2 at u % 4 = 1, 1 at u % 4 = 2, 0 otherwise
next deadline    constant 2                                   -- Drift 2 2 by Or.inl rfl
splice point     a = 1,  cycle length l = 2,  idle witness p = 0,  comparison position v = 1
```

The countdown is FORCED by `Count`, not chosen: the pending→idle clause pins `c = 0` at a region's
last pending position, the pending→pending clause counts down by exactly one, and the idle→pending
clause hands over the next-deadline register. A pending region of three is therefore the shortest
whose start carries `cntAt = 2`, and `hrep` needs `l = 2` here because the object repeats INSIDE
the region (`objAt gW 1 = objAt gW 3`) and not at distance `1`.

## The DERIVABLE branch, and the bounded attempt that closed it

Attempted first and bounded exactly where the plan said to bound it. `IsLadderPath` yields only
`step (objAt g u) (objAt g (u + 1)) = true` (`isLadderPath_components`, `LadderAgree.lean:636`),
so any derivation of `hself` at an idle `p ≤ a` needs `objAt g (p + 1) = objAt g p`, which no
binder supplies: `hidle` gives one idle position and nothing about its successor, `hrep` is a
repetition at the PENDING position `a`, and `hl`/`hcl`/`hv`/`hvreg` are countdown arithmetic. A
grep of every `RaySummary/` module confirms every diagonal `step q q = true` occurrence in the
tree is a HYPOTHESIS (`LadderAgree.lean:1867`, `:2233`, `:2296`, `:2878`) and never a conclusion —
consistent with the verdict, and not what establishes it. The search was stopped there as
instructed rather than continued.

## Immediate next action

Phase 11.14 is closed. **Phase 11.15 (the `hself` disposition ruling) remains `[BLOCKED]` and no
agent may transition it** — this phase deliberately does not. Phase 11.16 is open behind the
ruling, and this handoff's disposition table is its first task's input: branch (R) is closed on the
mathematics, so only the two remaining dispositions are live when the ruling lands.

## Verification run

- The probe compiles standalone: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-self-loop-derivability-decision.lean`, exit 0, **0 warnings**.
- `#print axioms` on all five headlines plus `gW_isLadderPath`/`gW_isLadderPath_total`: `[propext, Classical.choice, Quot.sound]` on each.
- `bash scripts/check-evidence-probes.sh`: **exit 1**, `FAIL 1 of 58 wired probe(s) failed`. The
  wired total is 58 = 56 `WIRED` + 2 `WIRED_REPO`, exactly one above the 57 re-measured at phase
  start (55 + 2), and the delta is this probe alone. **This phase's probe PASSES** (gate log line
  52). The single failure is PRE-EXISTING and outside this phase — see
  `#### The one unmeetable verification bullet` below.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests`: exit 0, `sorry_count: 0`.
- `^axiom ` counts: `FormalSystem` 12, `Tests` 2 — **unchanged** from the figures re-derived at plan-v12 authoring, as expected since this phase edits neither tree.
- `bash .claude/scripts/check-task-references.sh --quiet`: exit 0, `PASS: 0 unexempted task-reference occurrences`.
- `git diff HEAD --stat`: no file under `FormalSystem/` or `Tests/`; the only library-adjacent paths are this phase's two declared ones.

#### The one unmeetable verification bullet

Phase 11.14's verification asks for `bash scripts/check-evidence-probes.sh` to exit 0. It exits 1,
for a cause this phase neither created nor may repair, so the phase closes
`[COMPLETED WITH EXCLUSIONS]` rather than `[COMPLETED]`.

- **The failure**: `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`
  — a `WIRED_REPO` entry — reports `FAIL (missing)`.
- **Why**: the task that owns it was archived (commit `cf3e481fb`, "todo: archive 36 tasks, move 28
  task directories"), which moved the file to
  `specs/archive/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`,
  where it still is on disk, while the `WIRED_REPO` entry still names the pre-archival path.
  `.gitignore:94` excludes `specs/archive/`, so merely repointing the entry would turn
  `FAIL (missing)` into `FAIL (untracked)`.
- **It is pre-existing**: `git show HEAD:scripts/check-evidence-probes.sh` already carries the
  entry at line 2450. The gate was already red before this phase ran.
- **The owed remedy, which the script itself declares owed**: the comment block immediately above
  `WIRED_REPO` predicted this exact failure and said the move was "OWED BEFORE THAT TASK IS
  ARCHIVED, NOT MERELY DESIRABLE" — promote the file into
  `specs/evidence/seam-gluing-ray-product/` and update its three citations. The content is also
  recoverable from history at `d56ca7066`.
- **Why this phase does not do it**: Phase 11.14's `Files to modify` names two paths, and its own
  verification requires `git diff --stat` to show no file outside them. Promoting a file adds a
  third path. This is task 918's owed archival work, surfaced here rather than absorbed.

## Carried-figure check (dispatch premise re-validation)

Three `## Description` lines were flagged for re-validation. All three are confirmed unchanged by
this dispatch, and none of them is moved by it:

- The `w-soundness-shape-refuted.lean` WIDTH/COLLAPSE facts (`Probe747.modelOf_incomplete`,
  `Probe747.stab_iff_of_presented_nowUnique`): that probe is still wired and still compiles —
  `PASS` in this phase's own gate run. Not touched.
- The CONTINGENCY line's prohibitions (never `sorry`, `axiom`, vacuous definition, trace-level
  hypothesis, finite-fibre/finite-width assumption): honoured. `sorry_count: 0`, axiom counts
  unchanged at 12/2, and the probe's refutation is strengthened by `Fintype Q` rather than
  weakened by a finiteness assumption — the finiteness appears on the side of the claim being
  REFUTED, not on the side of what this phase asserts.
- The NOT COSTABLE line: unchanged. This phase carried a 1.5-hour `Timing` figure of its own and
  does not re-cost anything else.

The plan's own re-measurement instruction was also discharged: the asserted 55 `WIRED` + 2
`WIRED_REPO` was re-counted at phase start from the two array blocks and found **exactly correct**
— no sibling task had moved it.
