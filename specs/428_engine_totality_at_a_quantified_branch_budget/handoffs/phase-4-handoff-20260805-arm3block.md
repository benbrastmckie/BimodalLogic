# Handoff — plan 03, Phase 4 BLOCKED (supersedes `phase-4-handoff-20260805-mintbound.md`)

**Plan**: `specs/428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md`
**Repo state**: green. Full `lake build` succeeds (2333 jobs, exit 0). `MintBound.lean` is 1186
lines, zero `sorry`, zero `axiom`, zero `NoSplit`, zero vacuous placeholders.

**This is the CURRENT handoff.** Every other file in this directory is stale — the `phase-5-`
through `phase-10-` ones belong to plan `02` and its different phase numbering, and
`phase-4-handoff-20260805-mintbound.md` is this file's predecessor.

## Immediate next action

**Do not open Phase 8.** Phase 4 is `[BLOCKED]` and the blocker is a *planning* decision, not an
implementation one. Read the `**BLOCKER** (Phase 4)` block at the top of Phase 4 in the plan
file, then decide the invariant question described under "What is needed to unblock". Phases 8,
10, and 13 all rest on `IrreflOrd` being a run invariant, which is exactly what the blocker
denies at present.

## Phase status after this dispatch

| Phase | Status | Note |
|---|---|---|
| 1, 2, 3, 5, 6, 7 | COMPLETED | unchanged from the previous dispatch |
| 4 | **BLOCKED** | all four task bullets green; the phase **Goal** is not met — see below |
| 8-14 | NOT STARTED | not opened; 8, 10, 13 depend on the blocked claim |

## What landed this dispatch (three commits, each green and sorry-free)

- `77cb0930b` **phase 4.2** — `pickOrd`, `pick_ord_eq`, `pickOrd_irreflOrd`,
  **`expandOnceUnblocked_irreflOrd`** (all four `ExpansionResult` shapes),
  **`expandOnceUnblocked_splitOrdered_irreflOrd`** (the three per-arm orderings).
- `cc1ae9a5f` **phase 4.3** — `branchingResultBranches`, **`applyRule_ordTimes_branching`**,
  `pick_stage_source`, `pickBranches`, `pick_branches_eq`, `pickBranches_ordTimes`,
  `unorderedSuccessorBranches`, **`expandOnceUnblocked_ordTimes`** (`.extended` + every `.split`
  arm).
- `e7df2e255` **phase 4 block** — `ordTimes_identifyTime_arm3_false` plus the plan's blocker
  record.

All top-level results `lean_verify` to `[propext, Classical.choice, Quot.sound]`;
`ordTimes_identifyTime_arm3_false` is `[propext]` only (it is decided).

## The headline finding, and the one that blocks

**Discharged (a plan UNVERIFIED note now confirmed by proof).** R1's mirrored half is *not* a
problem. All four branching mint sites — `untlPos`, `sncePos`, and the ACTIVE arms of `untlNeg`
and `snceNeg` — build **both** arms headed at `freshLabel`, so every arm of a `.branching` step
dominates the time that step minted. `applyRule_ordTimes_branching` closes all four with the same
`rfl` for the head-time obligation.

**Refuted (the blocker).** `OrdTimesLeMaxTime` is **not preserved at `timeLinearity`'s arm 3**,
the identification arm of an ordered split. Machine-checked as
`ordTimes_identifyTime_arm3_false`:

- `b = [T p @(0,0), T q @(0,5)]`, `ord = ⟨[(3, 4)]⟩`.
- Decided true: `IrreflOrd ord`; `OrdTimesLeMaxTime b ord`; and
  `firstIncomparablePair b ord = some (0, 5)` — so this is a *genuine* trigger with both standing
  hypotheses satisfied, not a hypothetical.
- After arm 3: `Branch.identifyTime 5 0` collapses the branch's largest time, dropping
  `Branch.maxTime` from `5` to `0`; `TimeOrdering.identifyTime 5 0` leaves `(3, 4)` untouched,
  because neither component is `t₂ = 5` so nothing collapses and nothing is dropped. `3 ≤ 0`
  is false.

**Why this blocks the phase even though all four task bullets are green.** The phase's Goal is
"so `IrreflOrd` is a run invariant the fuel induction can carry".
`expandOnceUnblocked_irreflOrd` takes `haux : OrdTimesLeMaxTime b ord` as a hypothesis — it must,
because `applyRule_irreflOrd` needs it for the `densityRule` second edge. A run through an
ordered split's arm 3 loses `haux`, so `IrreflOrd` is not yet carryable across ordered splits.

## The identified repair — NOT applied, deliberately

Strengthen the invariant from "every ordering time is `≤ b.maxTime`" to **"every ordering time is
a known branch time"**:

```
def OrdTimesKnown (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes
```

- It **is** preserved at arm 3: `rho t₂ t₁` maps `b.knownTimes` onto
  `(b.identifyTime t₂ t₁).knownTimes` by construction, so the renamed constraint times land in
  the new branch's known times.
- It still **implies** `OrdTimesLeMaxTime` (every known time is `≤ maxTime` via `le_maxTime`), so
  the `densityRule` second edge keeps exactly the fact it consumes. This is a strengthening, not
  the forbidden weakening.
- The counterexample dies immediately under it: `3 ∉ [0, 5]`, so its hypotheses are unsatisfiable.

**Why it was not applied.** `OrdTimesLeMaxTime` is consumed by `[COMPLETED]` Phase 3:
`applyRule_irreflOrd`, `ordTimes_addFuture_cons`, `ordTimes_addPast_cons`,
`ordTimes_density_cons`, `applyRule_ordTimes_nonbranching`. Changing the definition reopens a
completed phase and rewrites Phase 4's own two new results. Per `plan-compliance.md` that is a
plan revision, not an implementation deviation, so it is raised rather than taken.

Note the two candidate shapes if the repair is authorised: (a) replace `OrdTimesLeMaxTime`
outright and re-prove Phase 3's five results against `OrdTimesKnown`; or (b) add `OrdTimesKnown`
alongside, derive `OrdTimesLeMaxTime` from it once, and carry the stronger one as the run
invariant while leaving every Phase 3 statement untouched. **(b) touches no completed proof** and
looks materially cheaper, but that is a judgement for the planner.

## Hard constraints — all holding, re-verified this dispatch

- `Saturation.lean` md5 `ae47004e06e77f2846cc3e1dfa408382`,
  `Fuel.lean` md5 `8a395bd7117a682c1f8302a2ac5f0f1f`,
  `Tableau.lean` md5 `cfd82332c8e400ac97ab709ece5dfb4a` — all identical to task start.
- `git diff --stat b2c5b3d98..HEAD -- FormalSystem/` is exactly `Decidability.lean` (+1 import)
  and the new `MintBound.lean`. Nothing else.
- No `sorry`, no `axiom`, no `NoSplit`, no vacuous definition, no task-number citation in any
  `.lean` file.

## Reusable findings added this dispatch

1. **`rcases h : e with …` substitutes in the goal already** — a following `rw [h]` on the goal
   then fails with "did not find an occurrence". The inner stages of a *nested* match are still
   unreduced, so their `rw`s do remain necessary. This asymmetry cost two build cycles.
2. **Prefer putting the pick equation in a hypothesis.** `pick_stage_source` packages all three
   pick stages as `∀ r res o, PICK = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule … = (res, o)`.
   Case-splitting the same nested match *in the goal* leaves outer `match none with …` layers
   that block unification at the application site — the error surfaces as a bogus-looking
   "application type mismatch" on a term that is in fact defeq. This is the same lesson as the
   previous handoff's finding 1, in a new guise, and `pick_stage_source` is now the reusable
   shape for any further engine-level lift.
3. **`unfold expandOnceUnblocked` leaves the `let blocked := …` binder in place**, so `rw` has no
   syntactic match. State the equation instead: `have key : (expandOnceUnblocked b ord fc tr).2
   = pickOrd ord ⟨the three-stage match, written out⟩ := pick_ord_eq` typechecks by defeq, and
   `rw [key]` then works. Same trick for the branch component (`keyB`).
4. **`decide` needs the `Prop`-valued defs unfolded first.** `IrreflOrd` / `OrdTimesLeMaxTime` are
   plain `def`s, so instance search will not see through them; `unfold IrreflOrd; decide` works
   where bare `decide` fails to synthesize `Decidable`.
5. **`all_goals first | …` after a goal-closing `simp only … at h`.** When the `simp only`
   discharges some branches outright (here: `branchingResultBranches` is `[]` at every
   non-branching result, so `hnb` becomes `False`), a following bare `first` raises "no goals to
   be solved" in exactly those branches. `all_goals` succeeds on zero goals and is the fix.
6. Arm-3 shape confirmations, read off the source and now relied on:
   `firstIncomparablePair` draws **both** times from `b.knownTimes` (so both are branch times),
   and `firstIncomparablePair_spec` reports `t₂ ≠ t₁` — note the direction, arm 1
   (`ord.addFuture t₁ t₂`) needs `Ne.symm` of it.
