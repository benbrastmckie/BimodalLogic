# Phase 7.3 Deadlock: Blocker Research and Resolution Path

- **Task**: 165 — establish_semantic_finite_model_property
- **Type**: lean4 (hard mode, blocker-research escalation 1 of 2)
- **Session**: sess_1785362916_22a871_165
- **Date**: 2026-07-29
- **Focus**: blocker research — the Phase 7 `[BLOCKED]` deadlock and the claimed 165 ↔ 412
  dependency inversion
- **Reference grounding tier**: **Tier 3 (implementation-backed)**. No external literature is
  load-bearing here. Every claim below is grounded in this repository's own Lean source, plan
  banners, probe files, and orchestration scripts, cited by `file:line`. Tier 1 was considered
  and rejected: the question is about the state of a proof tree and a task graph, not about
  transcribing a paper.

---

## Executive Summary

1. **There is no cycle. The claimed dependency inversion is refuted.** Task 412 does not
   *produce* what 165's Phase 7.3 needs — it *consumes* the same two ingredients. Its own
   description names them: "combining `allClosed_derivable` with **Track A's
   `buildTableau_isSome` and `not_valid_of_hasOpen`**". 412 owns the *syntactic* direction
   (`allClosed → Derivable`, via the admissibility lemmas from 410/411); 7.3 needs the
   *semantic* direction plus engine totality. Different theorems, different proofs.

2. **The deadlock is real but its cause is different: an unowned prerequisite.** 7.3 is blocked
   on **four** obstructions (O1–O4 below). **None of them is owned by any task in the graph** —
   not 165, not 410/411/412, not 426. Two of them (O2, O3) were *created* by deliberate,
   authorized soundness fixes landed after the plan was written. This is why no amount of
   dispatching moves the task: there is nothing to dispatch *to*.

3. **412 is itself broken, independently of 165.** Its scope text depends on
   `buildTableau_isSome`, which this task proved **FALSE** and placed on a do-not-re-attempt
   register (plan:1405–1420, :1489–1493). 412's acceptance criterion "zero sorries repo-wide
   outside Boneyard" is currently unreachable for that reason alone. It needs re-scoping whether
   or not 165 ever completes.

4. **Recommended disposition: (c)**, with the mechanical terminus borrowed from (b). 7.3 is
   blocked on genuinely unresolved obstructions; Phase 7 should close as
   `[COMPLETED WITH EXCLUSIONS]` with 7.3 recorded as a reasoned exclusion, and O1–O4 routed to
   new tasks. **I explicitly recommend AGAINST writing a conditional `valid_iff_allClosed`** —
   see §5.2 for why that deliverable would be vacuous, not honest.

5. **Keep every dependency edge; reverse none.** 410's and 411's real dependency on 165 is on
   Phases 1–3 (final rule set + RuleSpec GATE), which are `[COMPLETED]`. Once 165 reaches a
   terminal status, 410, 411, 426 and 193 unfreeze immediately.

---

## 1. Findings: what 7.3 actually needs, and what exists

The repository states its own obligation, and it is the most authoritative source in this report.
`FormalSystem/Metalogic/Decidability/Correctness.lean:98-105`, written by the Phase 8 dispatch:

> **What is still owed, and is deliberately not stated here.** The replacement these names should
> eventually have — `isValid φ fc = true ↔ ⊨ φ`, and the `Decidable (⊨ φ)` instances for the four
> frame classes — requires `valid_iff_allClosed`, which needs the fuel/termination side and the
> truth-lemma gate on top of the rule half above, and it must also account for the two rules
> scheduled outside `allRulesForFC` (`serialityRule` and `timeLinearity`, stages 2 and 3 of
> `expandOnce`). That obligation is open.

Decomposing that into the actual proof obligations, and checking each against the tree:

| Obligation | What exists | Status | Anchor |
|---|---|---|---|
| `hasOpen → ¬valid`, four classes | `not_valid_of_hasOpen_int`, `not_validDiscrete_of_hasOpen_int`, `not_validDense_of_hasOpen`, `not_validDedekindDense_of_hasOpen` | **LANDED**, sorry-free, but **conditional on 7 hypotheses** | `Bridge/IntTruth.lean:1027,1056`; `Bridge/DenseTruth.lean:651,674` |
| per-rule semantic soundness | `ruleSound_of_mem_allRulesForFC` | **LANDED**, 34/34, sorry-free | `Verified/Decidable.lean:3089` |
| lift per-rule soundness to the whole `expandOnce`/`expandBranchWithFuel` recursion | nothing | **OPEN (O5, folded into O4 below)** | `Verified/Decidable.lean:3062-3067` |
| `serialityRule` + `timeLinearity` soundness | nothing | **OPEN (O4)** | `Verified/Decidable.lean:3065-3067` |
| engine totality (`buildTableau … .isSome`) | `expandBranchWithFuel_isSome_at_worldFuel'` — but see O1 | **REFUTED as stated; partial substitute is severely restricted** | `Verified/Termination/Fuel.lean:1587-1598` |
| dischargeability of `hBA` on real branches | nothing | **OPEN (O2)** | `Bridge/BoxSaturation.lean:430-435,574-580` |
| dischargeability of `hTW` on real branches | six hand-built probe rows only | **OPEN (O3)** | `Tests/BimodalTest/TemporalWitnessProbe.lean:59-88` |

The hypothesis bundle of the landed truth-lemma results, verbatim from
`Bridge/IntTruth.lean:1027-1033`:

```lean
theorem not_valid_of_hasOpen_int (hV : branchOrderValid b ord = true)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    {χ : Formula} {l₀ : Label} (hw₀ : l₀.world ∈ b.knownWorlds)
    (hroot : (⟨.neg, χ, l₀⟩ : SignedFormula) ∈ b) : ¬ valid χ
```

Seven hypotheses. Five (`hV`, `hSat`, `hOpen`, `hTot`, `hCheck`) are dischargeable from engine
output or are the open-branch certificate itself. **Two are not** — and that is O2 and O3.

### The four obstructions, stated as goals

**O1 — engine totality. `buildTableau_isSome` is FALSE, and the landed substitute excludes every
branching rule.**

The refutation is a property of the engine's *signature*, not a proof difficulty (plan:1405–1420):
`buildTableau` (`Saturation.lean:928-951`) calls `expandBranchWithFuel` at the default
`maxBranches := 50000` (`Saturation.lean:590`), whose first line is
`if branchesUsed >= maxBranches then none` (`:594`). A formula exploring more than 50000 branches
returns `none` **at any fuel whatsoever**. Independently, `buildTableau`'s last arm returns `none`
on a still-unsaturated branch (`:950`). Neither is fuel exhaustion, so no fuel figure rules them
out. Plan:1489–1493 records: "**Do not re-attempt the unconditional form.**"

What landed instead (`Verified/Termination/Fuel.lean:1587-1598`) carries two hypotheses that make
it unusable as-is for 7.3:

```
(hP : NoSplit P fc)                       -- no branching rule ever fires
(hbud : branchesUsed + fuel ≤ maxBranches) -- fuel is worldFuel' φ s, which is exponential
```

`NoSplit` excludes `impPos`, `orPos`, `untlPos`, `untlNeg`, `sncePos`, `snceNeg`,
`orderTrichotomy` and every frame-class-gated splitting rule. Plan:1467–1468 is explicit:
"**Residual 2 (branching arms) — isolated, not discharged.**" A third dimension is also open:
plan:1484–1488, "T1 bounds formulas and T2 bounds times; **neither bounds worlds** … as defined,
`soundFuel' = 2·n·2^(2n)` has no world factor at all."

Goal shape owed:
```lean
theorem buildTableau_isSome_of_budget (φ : Formula) (fc : FrameClass)
    (maxBranches : Nat) (hmb : ⟨bound in φ⟩ ≤ maxBranches) :
    (buildTableauAt φ (soundFuel' φ) fc maxBranches).isSome = true
```
This cannot be written against the current `buildTableau` signature without an engine edit, which
the wave-3 territory contract forbids (plan:1423–1425).

**O2 — `hBA` (`boxAnchoredCheck`) is no longer dischargeable on multi-world branches.**

`BoxSaturation.lean:430-435`:

> **Those two blocks have since been removed as unsound** … They were the *only* route by which
> `T(Gφ)`/`T(Hφ)` could reach a freshly minted world … `boxAnchoredCheck` is therefore expected
> to compute `false` on multi-world branches now, and the anchor half of the argument above no
> longer holds on real engine output.

And `:574-580`: "a caller can no longer expect to discharge that hypothesis from a real run."
`TruthLemma.lean:399-404` says the same and names the repair as **"an open design decision with
its own soundness obligations"** with three candidate routes (propagate `T(□φ)` itself; copy
`T(Gφ)`/`T(Hφ)` only when box-derived; restructure the `box` case to need no anchor).

This was caused by task 418 (`completed`) removing a genuine unsoundness. It is a cost of a
correct fix, not a regression to revert — `TruthLemma.lean:404` says "Do **not** reinstate the
removed copies."

**O3 — `hTW` (`temporalWitnessCheck`) is no longer dischargeable on any branch carrying a
negative until with a known future time.**

`TemporalWitnessProbe.lean:66-73`: `untlNegFuture` demands `F(event)` at every known future time
of every negative until; the PASSIVE arm's branch 1 was the only producer of `¬event` at an
*existing* time; the arm was retired as unsound, so the producer is gone. Fourteen rows moved
`check=true → check=false`; the accepted set went from eight rows to **six** (rows A, B, C, D, E,
F — I and K left). `:86-88`: "it was already `false` on the branches the engine actually builds.
What it removes is the last set of hand-built branches on which the hypothesis was discharged."

**O4 — the semantic lift, plus `serialityRule` and `timeLinearity`.**

`Verified/Decidable.lean:3062-3067` states this against its own assembly:

> It is not yet `valid_iff_allClosed` (7.3), which additionally needs the fuel/termination side
> and the truth-lemma gate, and it says nothing about the two rules scheduled outside
> `allRulesForFC` — `serialityRule` and `timeLinearity` run as stages 2 and 3 of `expandOnce` and
> need their own obligations at the point where `expandOnce`, rather than `applyRule`, is the
> object.

Two distinct pieces here: (a) two more `RuleSound`-analogues at the `expandOnce` level, and (b)
the induction lifting single-step satisfiability preservation to the whole recursion so that
`.allClosed` yields a contradiction. Neither exists. (b) is the larger of the two and is
comparable in weight to a landed sub-phase, not to a wrapper.

---

## 2. Resolving the inversion: the dependency direction is NOT wrong

**Stated plainly: there is no cycle, and the 165 → {410, 411, 412} edges point the right way.**

The escalation's hypothesis was that 412's scope — "refutation core and decidability of
provability with completeness corollaries" — *is* 7.3's remaining work. Reading 412's own
description settles it in the other direction:

> Verified/Provable.lean: `Decidable (Derivable fc [] phi)` **combining `allClosed_derivable`
> with Track A's `buildTableau_isSome` and `not_valid_of_hasOpen`**

412 consumes the two Track A artifacts. It does not produce either. What 412 *produces* is
`allClosed_derivable` — the **syntactic** refutation core, "ONE induction over `allRulesForFC fc`,
discharging each rule by its admissibility lemma". That is a completely different theorem from
7.3's semantic obligations:

| | 7.3 (165, Track A) | 412 (Track B) |
|---|---|---|
| Direction proved | `allClosed → valid` (semantic) | `allClosed → Derivable` (syntactic) |
| Instrument | `RuleSound` / satisfiability preservation | Hilbert-system admissibility lemmas |
| Decidable target | `Decidable (⊨ φ)` | `Decidable (Derivable fc [] φ)` |
| Needs O1 | yes | **yes — same refuted theorem** |
| Needs O2/O3 | yes (via `not_valid_of_hasOpen`) | **yes — same conditional theorem** |
| Needs O4 | yes | no (its induction is syntactic) |

So 412 does not unblock 7.3; it **inherits O1, O2 and O3 from it**. That is the actual structural
finding, and it is worse news than a cycle would have been: a cycle can be cut by reversing an
edge, whereas an unowned prerequisite has to be given an owner.

**Neither does 426.** Its description explicitly disclaims the gate problem: "the
decidable-branch-gate family (boxAnchoredCheck, boxGridCheck, regionGate, regionLabelCheck,
rayUpOk/rayDnOk) now computes false on every multi-world branch; **that is the truth-lemma
side-condition problem and is not this task.**"

**A confirmed defect in 412 to fix regardless.** 412's scope references `buildTableau_isSome` as
though Track A will deliver it. Track A proved it false and forbade re-attempting it. 412's
acceptance criterion "zero sorries repo-wide outside Boneyard" therefore cannot be met as scoped.
This is independent of the 165 deadlock and should be corrected in 412's description whatever
disposition is chosen.

---

## 3. What 410 and 411 actually need from 165

Checked against their own descriptions:

- **410** needs the final rule set (Phase 2, `[COMPLETED]`) and "RuleSpec GATE lemmas still
  green" (Phase 3, `[COMPLETED]`). It builds `Internalize.lean` and ~21 routine admissibility
  lemmas from `Combinators.lean`, `ModalS5.lean`, `TemporalDerived.lean`,
  `GeneralizedNecessitation.lean`, `DeductionTheorem.lean`. **Nothing in 410 touches Phase 7.**
- **411** needs 410 plus the same final rule set; it also wants a `/literature` acquisition pass
  for Reynolds 1992/2003. **Nothing in 411 touches Phase 7.**
- **193** is a soundness-layer macro application pass. Its 165 edge is bureaucratic.
- **426** is the fuel/non-termination question for one anchor row; its content sits against
  Phase 4 (`[COMPLETED]`).
- **95** is an audit pass and genuinely wants 412.

**Consequence**: 410, 411, 426 and 193 are frozen purely on 165's *status marker*, not on any
substantive missing artifact. Getting 165 to a terminal status is worth four immediately-unblocked
tasks.

---

## 4. Recommended disposition: **(c)**, with (b)'s mechanical terminus

7.3 is blocked on things genuinely unresolved. It is not one goal but four (O1–O4), and none has
an owner. Below is the decidable path.

### 4.1 Close Phase 7 as `[COMPLETED WITH EXCLUSIONS]`

Change `plans/01_tableau-decidability-two-track.md:1719` from:

```
### Phase 7: Truth Lemma and Track A Decidability — MILESTONE [BLOCKED]
```

to:

```
### Phase 7: Truth Lemma and Track A Decidability — MILESTONE [COMPLETED WITH EXCLUSIONS]
```

and add a `#### Reasoned Exclusions` subsection to the phase body with the required
`Item | Reason | Evidence` columns, one row per obstruction (O1–O4), citing the anchors in §1.

**This marker is the right one, and it is mechanically sufficient.** Verified:

- `[COMPLETED WITH EXCLUSIONS]` is in the phase-heading vocabulary
  (`.claude/context/standards/status-markers.md:160-198`).
- The status-sync completion gate's DONE regex explicitly matches it —
  `.claude/scripts/update-task-status.sh:307`:
  `\[\(COMPLETED\|COMPLETED WITH EXCLUSIONS\)\]`. So `count_plan_phases` will report **8/8**, and
  the postflight `implement → completed` flip is admitted.
- The marker text satisfies the `[A-Z][A-Z ]*` TOTAL bracket class
  (`update-task-status.sh:305`), so it does not silently fall out of the denominator.
- The per-phase selector (`.claude/skills/skill-orchestrate-hard/SKILL.md:517`) schedules only
  `[NOT STARTED|PARTIAL|IN PROGRESS]`, so this marker correctly stops further dispatch instead of
  re-opening the phase.
- The current heading line conforms to both regexes (ends with `[BLOCKED]$`, no trailing
  whitespace — verified with `cat -A`).

**Named caveat, not papered over.** The orchestrate-hard *recovery corroboration* counter at
`skill-orchestrate-hard/SKILL.md:846` and `:928` uses an exact `\[COMPLETED\]` match and will
**not** count a `[COMPLETED WITH EXCLUSIONS]` heading. That path fires only when a handoff reports
`phases_total == 0`, so it is not on the normal route (the primary gate at `skill-base.sh:728`
reads the handoff's own numbers). But if a dispatch ever hands off with 0/0 accounting, the
corroboration will read 7/8 and refuse. The next dispatch should therefore report
`phases_completed: 8, phases_total: 8` explicitly.

**Admission test check** (`status-markers.md:184-197`), all five conditions:

1. *Decision, not abandonment* — **holds.** O2 and O3 exist because two unsound engine blocks were
   deliberately removed and authorized; restoring them is on the do-not-reopen register. O1 is a
   refuted theorem with an explicit "do not re-attempt". These are decisions already taken.
2. *Tightly scoped* — **holds.** The exclusion is item 7.3 and only 7.3; 7.1a–7.1e and 7.2 are
   `[x]` and landed sorry-free.
3. *Documented reason* — **holds** via the O1–O4 rows.
4. *Evidenced* — **holds.** Every reason carries a `file:line` anchor into Lean source, a probe
   measurement, or a plan blocker note.
5. *No residual work* — **holds only after the new tasks in §4.2 exist.** This is the one
   condition that is not automatic: it requires that nothing is left *for this task*. Creating the
   successor tasks first is what makes it true. Do them in that order.

### 4.2 Route O1–O4 to new tasks

Three tasks, in dependency order. Suggested via `/spawn 165` or `/task`:

- **T-A — engine totality at a quantified branch budget** (owns **O1**). Add a
  `maxBranches`-parameterised entry point alongside `buildTableau` (an *addition*, not an edit to
  the existing default — `maxBranches = 50000` is a deliberate runtime guard), discharge the
  branching-arm residual that `NoSplit` currently hypothesises
  (`Fuel.lean:1587`, `Saturation.lean:661-664,686-689`), and supply the missing world-count
  dimension `W` (plan:1484–1488). Predecessor: none beyond 165. Overlaps 426's hypothesis (b), so
  sequence them or merge.
- **T-B — repair the truth-lemma side conditions** (owns **O2** and **O3**). Choose among the
  three documented `BoxAnchored` repair routes (`TruthLemma.lean:402-403`) and re-establish a
  producer for `¬event` at existing future times without reinstating the retired PASSIVE arm. Read
  `specs/418_*/artifacts/boxanchored-finding.md` first — it carries the measurement, the full
  carrier list, and the repair options. **This is the task with genuine open mathematics in it and
  should be budgeted accordingly.** Predecessor: 165.
- **T-C — the semantic lift and the Track A assembly** (owns **O4**, then delivers what 7.3 was
  for). `RuleSound`-analogues for `serialityRule` and `timeLinearity` at the `expandOnce` level;
  the induction lifting single-step preservation to the recursion; then `valid_iff_allClosed` and
  the four `Decidable` instances. Predecessors: T-A, T-B.

**Also re-scope 412** to drop its dependence on `buildTableau_isSome` and point at T-A's
budget-parameterised replacement instead.

### 4.3 Dependency edges: keep all, reverse none

| Edge | Verdict |
|---|---|
| 165 → 410 | **Keep.** Satisfied today by Phases 1–3. Unfreezes the moment 165 terminates. |
| 165 → 411 | **Keep.** Same. |
| 165 → 412 | **Keep**, but re-scope 412 (§2) and add T-A as a predecessor. |
| 165 → 426 | **Keep.** Satisfied today by Phase 4. Coordinate with T-A. |
| 165 → 193, 165 → 95 | **Keep.** Bureaucratic / audit respectively. |

Reversing any edge would be wrong: 410/411 genuinely build on 165's completed rule set and GATE
lemmas, and 412 genuinely consumes Track A's conditional truth-lemma results.

---

## 5. What I recommend against, and why

### 5.1 Do not re-attempt `buildTableau_isSome` in unconditional form
Already on the do-not-re-attempt register (plan:1489–1493), and the reason is a signature fact,
not a proof gap.

### 5.2 Do NOT write a conditional `valid_iff_allClosed` carrying `hTW` as a hypothesis

The continuation floated this as the possibly-honest terminus. **It is not honest, and I recommend
against it**, for a specific reason that this task has already litigated once.

A conditional iff carrying only `hTW` would still owe O1, O2 and O4. To make it provable today,
the hypothesis bundle would have to include:

- `hTW` and `hBA` (fine — these are substantive, falsifiable, decidable branch properties), **and**
- a totality certificate for `buildTableau` (O1), **and**
- the `expandOnce`-level soundness of `serialityRule`/`timeLinearity` (O4a), **and**
- the lift from per-rule to whole-recursion satisfiability preservation (O4b).

The last of those is *the `allClosed → valid` direction itself*. Hypothesising it and then
concluding the iff is a restatement, not a theorem — the exact "true-looking name over a proof
that cannot reach it" defect that Phase 8 spent a whole dispatch removing, and that
`Correctness.lean:103-105` explicitly refuses:

> Stating an `isValid`-shaped `iff` before it is discharged would reproduce exactly the defect
> this retirement removes … No such statement is written here until it can be proved.

Writing it would contradict the repository's own freshly-landed hygiene note. A reasoned-exclusion
record carries the same information at zero risk of a false claim.

**What *would* be legitimate**, if a future dispatch wants a conditional assembly: bundle only the
*engine facts* (a totality certificate and the two gate properties) into a named `Prop` and
**prove** the semantic lift. That is T-C's job, and its content is O4b — real work, ~400+ lines,
not a wrapper.

### 5.3 Do not reinstate the retired arms or copy blocks
`TruthLemma.lean:404` ("Do **not** reinstate the removed copies") and the standing do-not-reopen
register. O2 and O3 are the price of two correct soundness fixes.

---

## 6. Adversarial Self-Verification

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| 412 consumes rather than produces Track A's artifacts, so there is no cycle | 412's own `description` in `specs/state.json`: "combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen" | Direct `jq` read of state.json | **High** |
| `buildTableau_isSome` is false, not merely unproved | plan:1412–1420 derives it from `Saturation.lean:590,594,624,646,675,950`; plan:1489 restates it after the residuals were discharged | Plan blocker note + engine line anchors it cites | **High** |
| The landed totality substitute excludes all branching rules | `Fuel.lean:1587-1598` signature read directly: `(hP : NoSplit P fc)` and `(hbud : branchesUsed + fuel ≤ maxBranches)` | Source read; `lean_local_search` confirmed the three `expandBranchWithFuel_isSome*` names and no fourth | **High** |
| `hBA` is not dischargeable on multi-world engine output | `BoxSaturation.lean:434` ("expected to compute `false` on multi-world branches now"), `:577`, `TruthLemma.lean:399` | Three independent in-source statements, all authored post-418 | **High** |
| `hTW` is not dischargeable on branches with a negative until + known future time | `TemporalWitnessProbe.lean:66-73,86-88`; accepted set 8 → 6 | Probe banner, which records a *measured* 14-row move | **High** |
| O4 (serialityRule/timeLinearity + the semantic lift) is open | `Verified/Decidable.lean:3062-3067`; `Correctness.lean:98-105` | Two in-source statements by the dispatches that landed the adjacent work | **High** |
| No existing task owns O1–O4 | `jq` scan of all `description` fields for `boxAnchored|temporalWitnessCheck|regionLabelCheck|buildTableau_isSome` returned only 412 (which consumes) and 426 (which explicitly disclaims) | Full state.json scan, not a sample | **Medium-High** — a task could own an obstruction without naming these identifiers. I scanned by identifier, not by concept. |
| `[COMPLETED WITH EXCLUSIONS]` passes the completion gate at 8/8 | `update-task-status.sh:307` DONE regex includes it verbatim; `:305` TOTAL class `[A-Z][A-Z ]*` admits it; Phase 7 heading conforms (`cat -A` shows `[BLOCKED]$`) | Script source read + heading byte check | **High** |
| The orchestrate-hard corroboration counter will NOT count it | `skill-orchestrate-hard/SKILL.md:846,928` use exact `\[COMPLETED\]` | Grep of both call sites | **High** (that it won't count); **Medium** on impact — that path fires only at `phases_total == 0`, which I inferred from `skill-base.sh:728-748` rather than by executing the state machine |
| 410/411 need only Phases 1–3 from 165 | Their descriptions name "RuleSpec GATE lemmas still green" and the final rule set; neither mentions a Phase 7 artifact | Description read; **not** verified by attempting a build of 410's targets (they do not exist yet) | **Medium** — inferred from scope text. A hidden import-level need would not show up this way. |
| A conditional `valid_iff_allClosed` would be vacuous | `Correctness.lean:103-105` refuses exactly this; the O4b hypothesis would *be* the conclusion's forward direction | Argument from the obligation decomposition in §1, plus the in-source refusal | **Medium-High** — this is a judgment about what counts as vacuous, and it is a judgment I am making, not one the tree measures. It is however the same judgment Phase 8 already made and the user already accepted. |
| 412's acceptance criterion is currently unreachable | It requires zero sorries repo-wide, which needs `countermodel_discrete` discharged, which its own text routes through `buildTableau_isSome` | Description read + the O1 refutation | **Medium** — 412 might reach its goal by a route its description does not name. Flagged rather than asserted. |

### Contradiction Log

**C1 — resolved.** The escalation asserts a probable cycle (165 blocked on 412's scope, 412
blocked on 165). 412's own description asserts consumption of Track A's artifacts. **Resolution by
precedence**: state.json's `description` field is the authoritative scope record for a task and
outranks a hypothesis stated in a dispatch prompt. No cycle. The escalation's *symptom* diagnosis
(the task cannot advance by dispatching) is nonetheless correct — the cause is an unowned
prerequisite, not a cycle.

**C2 — resolved.** The dispatch instruction offers disposition (b) with a conditional
`valid_iff_allClosed` as "the possibly-honest deliverable"; `Correctness.lean:103-105` forbids
stating an `isValid`-shaped iff before it is discharged. **Resolution**: the in-source hygiene note
is the later and more specific record, was landed by the immediately-preceding dispatch, and
encodes a decision the user already authorized. It wins. I therefore recommend (c) and decline
(b)'s deliverable while adopting (b)'s marker change.

**C3 — no contradiction, worth recording.** `Verified/Decidable.lean:3064` lists 7.3's residue as
"the fuel/termination side and the truth-lemma gate" plus the two outside rules — three items,
where I count four (O1, O2+O3 together are "the truth-lemma gate", O4 is the two outside rules
*plus* the lift). The difference is decomposition granularity, not disagreement. I split O2 from
O3 because they have different causes (task 418's fix vs. the PASSIVE-arm retirement) and could in
principle be repaired independently; I split the lift out of O4 because it is the largest single
piece and naming it inside "the two outside rules" understates it.

### Recommendations modified after verification

- **Initially** I was going to recommend disposition (b) as written, since it is the one that
  terminates the task. Verification of `Correctness.lean:98-105` and the O4b decomposition changed
  it to (c), retaining only (b)'s marker change. The conditional iff would have been a fifth
  vacuous theorem landing one dispatch after four were deleted.
- **Initially** I was going to recommend dropping the 165 → 412 edge as inverted. Reading 412's
  description refuted the inversion; the edge stays and 412 gains a predecessor instead.
- I added the corroboration-regex caveat (§4.1) only after grepping the orchestrate-hard script;
  my first draft asserted the marker change was mechanically sufficient without qualification,
  which was over-confident.

---

## 7. Artifacts and anchors

Sources read in full or in the cited region:

- `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`
  — Phase 7 (:1719–1780), the 7.1/7.2/7.3 task list in force (:2254–2356), the 2026-07-29f banner
  (:2358–2411), the 4.3 sub-phase and its restated Done-when (:1007–1036), the 4.3b blocker and
  its resolution (:1405–1493), the 2026-07-28q additions (:3390–3429)
- `specs/165_establish_semantic_finite_model_property/.orchestrator-handoff.json` — full
- `FormalSystem/Metalogic/Decidability/Correctness.lean:40-106` — `decide_sound` and the
  retirement note that states the open obligation
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean:3060-3131` — `carrierForFC`,
  `ruleSound_base_mono`, `ruleSound_of_mem_allRulesForFC`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean:990-1083` — the two ℤ
  headline results and their hypothesis bundle
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/BoxSaturation.lean:420-464,565-594`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean:385-414`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean:1587-1609`
- `Tests/BimodalTest/TemporalWitnessProbe.lean:1-110`
- `specs/state.json` — descriptions for 95, 165, 193, 410, 411, 412, 418, 426
- `.claude/scripts/update-task-status.sh:287-325`, `.claude/scripts/skill-base.sh:716-749`,
  `.claude/skills/skill-orchestrate-hard/SKILL.md:501-601,846,928`,
  `.claude/context/standards/status-markers.md:148-198`

No file was edited. No proof was attempted.
