# Phase 7 — `OrdWithin` lands, and the four fresh-time producers with it

- **Dispatch**: seventeenth on Phase 7; single-phase, hard mode
- **Session**: `sess_1785337808_19a89c_165`
- **Outcome**: PARTIAL. 7.2 goes **18 → 23**, denominator corrected **28 → 34**. Zero sorries.
- **Commits**: seven, each verified green before landing and by `git show --stat` after

---

## What landed

### 1. The authorized statement change, in its corrected form

`RuleSound` now reads:

```lean
      sf ∈ b → SatState M Om hist tv b ord → OrdWithin b ord →
      SatResult M Om b (applyRule r sf b ord).1 (applyRule r sf b ord).2
```

with

```lean
def OrdWithin (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes
```

The **membership** form, not the numeric `< b.nextTime` form the prior dispatch proposed. The
adversarial verification report refuted the numeric bound as an inductive invariant on
`timeLinearity`'s identification arm — the engine's one non-additive step, which can *lower*
`nextTime` while a constraint endpoint survives the rewrite. Membership is stable under exactly
that operation, and implies the numeric bound (`OrdWithin.bound`), so nothing downstream is lost.

Both pricing corrections from the report held up under the compiler:

- **19 sites, not 18.** `RuleSound.mono` needed an extra `intro` name *and* an extra argument in
  its `exact` term.
- **Position is load-bearing.** The hypothesis sits last, after `SatState`. All 18 rule proofs
  take one appended anonymous `intro` and none of them consumes it — every one returns the
  ordering unchanged.

Supporting lemmas: `lt_nextTime_of_mem_knownTimes`, `mem_knownTimes_append`,
`mem_knownTimes_of_mem_branch`, `OrdWithin.bound`, `OrdWithin.nextTime_not_mem`,
`OrdWithin.empty`, `OrdWithin.append`.

### 2. All four fresh-time existentials, sorry-free

`ruleSound_allFutureNeg`, `ruleSound_allPastNeg`, `ruleSound_someFuturePos`,
`ruleSound_somePastPos`. The last three went green on the **first attempt** against the
infrastructure the first one established.

The obligation has three parts, each discharged by a different piece of state:

| Part | Discharged by |
|---|---|
| the minted edge | the choice of `d`, supplied by the source formula's existential reading |
| the previously recorded edges | `OrdWithin.bound` — the **only** place any rule consumes the hypothesis |
| the branch and the propagations | `not_mem_of_time_nextTime`, the four `truthAt_of_*` lemmas, and `satAt_of_boxForm_time` |

Nine new helpers, sized so each is used by exactly two rules:
`forall_truthAt_time_invariant`, `satAt_of_boxForm_time`, `satAt_update_nextTime_of_mem`,
`ordResp_addFuture_update` / `ordResp_addPast_update`, `satAt_of_mem_gProps` / `fNegProps` /
`hProps` / `pNegProps`, plus four existential-extraction lemmas for the `G`/`H`/`F`/`P` wrappers.

`forall_truthAt_time_invariant` is worth naming separately: *an `Ω`-universal claim is
time-invariant under shift-closure*. It was previously buried inside `truthAt_allFuture_of_box`,
which wraps it in `G` and discards the generality. It is the one fact that makes **any**
cross-time formula copy sound, and isolating it is what let the modal propagations go through.

### 3. `ruleSound_denseIndicatorClosure`

Emits `.linear []`, so the handed-in state discharges it outright. Proved at `carrierBase` and
reusable at `.Dense` through `RuleSound.mono` — no carrier property declared, consistent with the
standing rule that a frame-class property is declared only in the step that consumes it.

### 4. One additive engine lemma

`mem_boxDiamondPersistence_shape` in `Tableau.lean`. Its two existing companions give the emitted
formula and its label; neither gives its **shape**, and shape is what the time-copy's soundness
turns on. `Prop`-valued, additive, changes nothing `applyRule` computes.

---

## What blocked, and why it is escalated rather than fixed

`untlPos`, `sncePos`, and the ACTIVE arms of `untlNeg`/`snceNeg` are **false as stated**, for a
reason independent of the ordering gap this dispatch closed. They copy `F(U(e', g'))`
unconditionally from the trigger's time to the minted time. `Until`'s truth is interval-relative,
so — unlike the `□`/`◇` copies, which are `Ω`-universal and hence time-invariant — no transfer
argument exists.

**Counterexample** (recorded in full in the module): let `e'` be true exactly on `{1/n}` and `g'`
false exactly on `{1/n}`. Then `¬U(e', g')` at `0`, but `U(e', g')` at **every** `d ∈ (0,1)`. With
`event` true exactly at `1/2` and `guard` true everywhere, `T(U(event, guard))` holds at `0`, and
the fresh-time interpretations satisfying either emitted branch are exactly `(0, 1/2]` — all
inside the range where the copied `F(U(e', g'))` is false. Both successors are unsatisfiable
although the source branch was satisfiable.

This is an engine change of exactly the shape task 418 already performed for the six group-3
blocks, and it needs the same conformance-corpus acceptance gate. `plan-compliance.md` requires
escalation rather than a silent mid-proof repair, so it is escalated.

The PASSIVE arm of `untlNeg`/`snceNeg` is sound and provable today — but cannot land alone,
because `RuleSound` is stated per rule and `untlNeg` owns both arms.

---

## Verification

| Check | Result |
|---|---|
| `lake build` (FULL) | **GREEN, 1983 jobs** — the baseline owed for several dispatches, now taken |
| `lake build …Verified.Decidable` | GREEN, 1350 jobs, after every landed edit |
| `lake build …Decidability.Tableau` | GREEN, 689 jobs |
| sorry census over `Verified/` | **0** |
| vacuous definitions introduced | **0** |
| new axioms | **0** |
| `ruleSound_*` theorem count | 23, matching the reported ledger |
| out-of-territory changes | none |

The one repo-wide vacuous-pattern match, `Examples/TemporalStructures.lean:279`, is pre-existing,
belongs to another task, and is legitimate (the `Int` history is total, so its domain predicate
really is `True`).

`TableauConformance.lean` was not re-run: every edit here is additive at the Lean level — a
`Prop`-valued engine lemma plus new theorems plus one hypothesis on a predicate no engine code
consumes — so nothing landed can move a `#guard_msgs` row.

---

## The denominator

7.2's target is **34** rules for the literal statement (`allRules` 26 + dense 2 + discrete 3 +
dedekind 3) and **36** for an engine-faithful assembly (`+ serialityRule + timeLinearity`).
`TableauRule` has 36 constructors. The plan warned against the "28" figure at its own line 177
and the warning had gone unread for several dispatches; older status banners retain "of 28" as
historical record.

---

## Next

The **frame-class-gated rules** are the natural next target and are *not* blocked by the untl/snce
defect. `densityRule` first: it is a fresh-time producer and the infrastructure is now in place,
but it mints **two** constraints in one step and its `gProps` guard carries an extra conjunct, so
both `ordResp_addFuture_update` and `satAt_of_mem_gProps` need variants.

For the assembly, one lemma named in the verification report is not yet landed:
`OrdWithin.identifyTime`. The assembly runs over the *engine's* steps, and the engine fires
`timeLinearity` — which is precisely the step the membership formulation was chosen to survive.
