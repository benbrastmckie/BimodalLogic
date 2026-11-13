# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-13T00:57:05Z
- **Completed**: 2026-11-13T01:23:47Z
- **Effort**: ~0.5 hours (against the plan's 1.5-hour **Timing** figure for Phase 11.14)
- **Dependencies**: 760, 775, 805, 806, 819, 820 — all six discharged; no open gating task. Phase 11.14's own `Depends on` is Phase 11.11, which is `[COMPLETED]`
- **Artifacts**: plans/12_hself-disposition-gate-settlement.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This round executed **Phase 11.14, the one phase of plan v12 an implementation dispatch could
enter** — the `hself` derivability decision probe. It settles the single question underneath the
unchecked Stage 0 `hself` user ruling that is a matter of FACT rather than of judgement: whether
the path-local self-loop `hself` is derivable from the binders the two landed cascade declarations
already carry. **The verdict is NOT DERIVABLE**, compiled on an explicit finite object, and the
probe additionally compiles the converse half — `hself` is not refutable either — so the premise is
genuinely *independent*. No disposition was taken and no recommendation on the ruling was formed:
Phase 11.15 remains `[BLOCKED]`, exactly as the plan requires.

The task's five unlanded Goals (`ladderSound`, `ladderCons_localRun`, `ladderLift`,
`ladderRealized`, `cellAt_const_of_kappa_eq`) are untouched and remain behind Phase 11.9's
INCONCLUSIVE depth-`0` verdict. This round lands no library declaration and claims none.

## What Changed

- `specs/evidence/seam-gluing-ray-product/ladder-self-loop-derivability-decision.lean` — **NEW**, 295 lines, namespace `Probe761SelfLoop`. Five headline declarations:
  - `hself_not_derivable` — **THE VERDICT**. The universally quantified implication from `exists_ladderPath_at_region_of_idle_past`'s recorded binders (`hg`, `hl`, `hcl`, `hidle`, `hrep`, `hv`, `hvreg`) to `hself : ∀ p ≤ a, pend (objAt g p) = false → step (objAt g p) (objAt g p) = true` is FALSE — and false with `Fintype Q` ASSUMED, which is strictly stronger than refuting it without finiteness and stronger than either landed declaration needs, since both sit in `LadderAgree.lean`'s `section Path` whose variable block carries no finiteness instance
  - `instance_is_in_regime` — **NON-VACUITY**: every binder of that declaration holds at the counterexample, in the declaration's own order, so the object refutes the DERIVATION and not the regime
  - `instance_self_loop_fails` — the failing self-loop: a compiled ladder path, an idle `p = 0 ≤ a = 1`, and `stepD (objAt gW 0) (objAt gW 0) = false`
  - `hself_satisfiable_at_an_instance` — the independence half the phase did not require: the SAME walk over a total `step` satisfies every binder AND `hself`
  - `idle_successor_differs` — the gap the derivation stalls on, isolated: at the idle position the walk MOVES, so `isLadderPath_components` supplies only `step (objAt gW 0) (objAt gW 1) = true` and never touches the diagonal
- `scripts/check-evidence-probes.sh` — the probe's 81-line table block and its one `WIRED` array entry. Wired total **55 + 2 → 56 + 2**
- `specs/761_ladder_realization_theorem/plans/12_hself-disposition-gate-settlement.md` — Phase 11.14 marked `[COMPLETED WITH EXCLUSIONS]`, its six checklist items ticked, and a `#### Recorded Outcome` plus `#### Reasoned Exclusions` record added
- `specs/761_ladder_realization_theorem/handoffs/phase-11.14-handoff-20261113T011907Z.md` — **NEW**, the verdict in the form Phase 11.16's first task reads

### The compiled instance

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
the region (`objAt gW 1 = objAt gW 3`) rather than at distance `1`.

## Decisions

- **The plan's UN-COMPILED plan-time sketch was replaced rather than weakened**, which is what the
  plan instructed for exactly this case. The sketch proposed an all-idle alternating walk over
  `Bool`; that object cannot satisfy `hcl : l ≤ cntAt g a` with `hl : 0 < l`, because `Count`'s
  idle clause pins the countdown to `0` at every position of an all-idle walk, making `cntAt g a`
  identically `0`. The replacement object keeps the sketch's idea — one idle state with no
  self-loop — and adds the shortest pending region that makes every binder satisfiable.
- **The refutation was stated with `Fintype Q` assumed**, although neither landed declaration takes
  a finiteness instance. Refuting the finiteness-assuming universal is strictly stronger, and it
  machine-checks the half of the primitive-decision note (`LadderAgree.lean:1758-1790`) that says
  `[Fintype Q]` does not supply what a self-loop-avoiding construction would need.
- **The independence half was added beyond the phase's requirement.** `hself_not_derivable` alone
  leaves open whether `hself` is *consistent* with the other binders; `hself_satisfiable_at_an_instance`
  closes that, and the pair is what licenses the summary's claim that the recorded blocks are
  silent about a true premise rather than wrong about the mathematics.
- **No recommendation on the Stage 0 ruling was formed or recorded**, in the probe header, the plan,
  the handoff, or here. The probe does close disposition (R) on the mathematics, which is a compiled
  consequence rather than a preference.

## Plan Deviations

- None (implementation followed plan). The DERIVABLE branch was attempted first and bounded at
  exactly the gap the plan told it to bound at, and the plan-time sketch's replacement is the
  plan's own instruction for a sketch whose clauses fail, not a deviation from it.

## Verification

- Build: **Success** — full `lake build` through the guard: `exit_status=0`, `Build completed successfully (2975 jobs)`, **0** `error:` occurrences over both captured streams, and `.olean` newer than source for `LadderAgree`, `LadderModel` and `RunLayer` (the modules the probe compiles against). This phase edits no file under `FormalSystem/` or `Tests/`, so the module-level tier is vacuous for its own edit set.
- Probe standalone compile: `lake env lean` on the probe, exit 0, **0 warnings**.
- `#print axioms` on all five headlines plus `gW_isLadderPath`/`gW_isLadderPath_total`: exactly `[propext, Classical.choice, Quot.sound]` on each. No `sorryAx`, no custom axiom, no `native_decide`, no raised `maxRecDepth` or `maxHeartbeats`.
- Sorry count: **0** (`lean-sorry-census.sh FormalSystem Tests`, exit 0)
- Vacuous count: **0**
- Axiom count: `^axiom ` **12** under `FormalSystem`, **2** under `Tests` — unchanged from the figures re-derived at plan-v12 authoring, as expected since this phase edits neither tree
- `check-task-references.sh --quiet`: exit 0, `PASS: 0 unexempted task-reference occurrences`
- `git diff --stat`: no file under `FormalSystem/` or `Tests/`
- Tests: N/A (no library or test code changed)
- Files verified: Yes

### The one unmeetable verification bullet

`bash scripts/check-evidence-probes.sh` exits **1**, not 0 — for a **pre-existing** cause outside
this phase, which is why Phase 11.14 closes `[COMPLETED WITH EXCLUSIONS]`. The wired total is 58
(56 `WIRED` + 2 `WIRED_REPO`), exactly one above the 57 re-measured at phase start, and **this
phase's probe PASSES**. The sole failure is the `WIRED_REPO` entry
`specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`, which
reports `FAIL (missing)`: the task that owns it was archived (commit `cf3e481fb`), moving the file
to `specs/archive/918_.../evidence/lowering-anchor-deficit.lean` — where it still is on disk —
while the entry still names the pre-archival path, and `.gitignore:94` excludes `specs/archive/`,
so repointing the entry alone would turn `FAIL (missing)` into `FAIL (untracked)`. The script's own
comment block above `WIRED_REPO` predicted this failure and declared the remedy owed before
archival. `git show HEAD:scripts/check-evidence-probes.sh` carries the entry at line 2450, so the
gate was red before this phase ran; Phase 11.14's declared `Files to modify` names two paths and
its own verification requires no file outside them, so the repair is surfaced rather than absorbed.

## Carried-Figure Discipline

The dispatch flagged three `## Description` lines for re-validation. Each was checked against live
state, and the result is stated even where it only confirms the description unchanged:

- **The `w-soundness-shape-refuted.lean` WIDTH/COLLAPSE facts** (`Probe747.modelOf_incomplete`,
  `Probe747.stab_iff_of_presented_nowUnique`): **confirmed unchanged.** The probe is still wired and
  still compiles — `PASS` in this round's own gate run. Not touched by this phase.
- **The CONTINGENCY line's prohibitions** (never `sorry`, `axiom`, vacuous definition, trace-level
  hypothesis, finite-fibre/finite-width assumption): **honoured.** `sorry_count: 0`; axiom counts
  unchanged at 12/2; and the finiteness this round mentions sits on the side of the claim being
  REFUTED (`hself_not_derivable` assumes `Fintype Q` in order to refute an implication *under* it),
  never on the side of anything this round asserts.
- **The NOT COSTABLE line**: **confirmed unchanged.** Phase 11.14 carried its own 1.5-hour
  `Timing` figure and this round re-costs nothing else.
- **The plan's own re-measurement instruction** was additionally discharged: the asserted
  55 `WIRED` + 2 `WIRED_REPO` was re-counted from the two array blocks at phase start and found
  **exactly correct** — no sibling task had moved it.

## Impacts

- **Disposition (R) of the `hself` ruling is closed on the mathematics.** Phase 11.16's branch (R)
  — an in-library repair discharging `hself` with no binder added — asks for exactly the
  implication `hself_not_derivable` refutes, so it is unavailable independently of any ruling.
- **The ruling itself is narrowed, not taken.** Because `hself` is independent (neither derivable
  nor refutable), the recorded blocks of Phases 11.12 and 11.13 are not wrong about the
  mathematics — they are silent about one true premise. The choice between the two remaining
  dispositions is consequently between two honest naming conventions, not between a correct and an
  incorrect statement. **Phase 11.15 stays `[BLOCKED]`** and no agent may transition it.
- The primitive-decision note at `LadderAgree.lean:1758-1790` now has a machine-checked backing
  for its central claim, which previously rested on the in-source argument alone.
- The evidence gate carries one more wired probe (58 total).

## Follow-ups

- **The `hself` disposition ruling (Phase 11.15) is still owed by the user**, now with one branch
  closed and the other two characterised. It remains a Stage 0 item of `specs/ROADMAP.md` under
  "User rulings (no agent may transition these)".
- **The archived task 918's owed probe promotion blocks the evidence gate's exit status.** Promote
  `specs/archive/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`
  into `specs/evidence/seam-gluing-ray-product/` and update its three citations in
  `scripts/check-evidence-probes.sh`, per that script's own instruction. Until then every
  `check-evidence-probes.sh` run in this repository exits 1 regardless of the probe set's health.
  This is not this task's territory and was deliberately not absorbed here.
- Phases 11.6, 11.7, 12.2, 13, 14, 15.1, 15.2 and 16-18 remain behind Phase 11.9's INCONCLUSIVE
  verdict on the open depth-`0` core; nothing in this round lifts it, and nothing in this round
  claims to.

## References

- `specs/761_ladder_realization_theorem/plans/12_hself-disposition-gate-settlement.md` — the live plan; Phase 11.14 and its `#### Recorded Outcome`
- `specs/761_ladder_realization_theorem/handoffs/phase-11.14-handoff-20261113T011907Z.md` — the verdict in Phase 11.16's reading form
- `specs/evidence/seam-gluing-ray-product/ladder-self-loop-derivability-decision.lean` — the probe
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — `:1758-1790` the primitive decision, `:2214-2226` the `hself` premise note, `:2227` and `:2291` the two landed signatures, `:2878` the landed self-loop precedent, `:636`/`:647` `isLadderPath_components`
- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` — `:254` `Drift`, `:261` `Count`, `:268` `Rlad`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` — `:159` `Adm`, `:163` `LadderState`, `:174` `RladAdm`
- `scripts/check-evidence-probes.sh` — the gate, its table and its two wired arrays
- `specs/761_ladder_realization_theorem/issues.jsonl` — this round's three recorded entries (one win, two issues)
