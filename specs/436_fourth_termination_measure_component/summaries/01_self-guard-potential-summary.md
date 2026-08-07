# Task 436 Summary: The Fourth Termination Measure Component

- **Task**: 436 — `fourth_termination_measure_component`
- **Task type**: lean4
- **Plan**: `specs/436_fourth_termination_measure_component/plans/01_self-guard-potential.md`
- **Outcome**: **decided negative result** — the recommended design is refuted, machine-checked
- **Phases**: 2 of 10 executed (Phase 1, Phase 10); Phases 2-9 `[BLOCKED]` by Phase 1's verdict
- **Build**: `lake build` green (2333 jobs), sorry-free, no project axioms

---

## The deliverable is a refutation, not a component

This task set out to build the fourth component of the tableau termination measure — the one
`MintPaysForTime`'s register entry says is missing, paying for the three self-guarded time-minting
rules. The plan front-loaded a **refute-first gate** (Phase 1) on the single exposure the research
could not discharge in advance: the σ-hit obligation. The gate ran and returned **FALSE**.

That is the deliverable. Nothing was landed under the component's name that is weaker than the
component; the design is landed and named only because a refutation has to be stated about
something.

## What was asked

Build `selfGuardPotential`: a **second** defect ledger, indexed by `selfGuardRules ×ˢ U`, paying for
`untlNeg` and `snceNeg` by their own self-guard discharge rather than by their `ord.timeCount` cap,
and add it as a third disjunct to `MintPaysForTime` (yielding `MintPaysForTimeAt`). Then prove the
per-rule discharge lemmas, the step lemmas, the four-component measure, and the restated termini.

## What was built

**Phase 1 (landed, sorry-free, axiom-free)** — `MintBound.lean`, subsection
"The fourth measure component: the self-guard discharge potential":

| Declaration | Role |
|---|---|
| `selfGuardRules`, `selfGuardRules_card` | The index set: exactly `{untlNeg, snceNeg}`, decided |
| `selfGuardDischarged` | The discharge test, transcribed from each rule's own guard in inverted polarity, catch-all `true` |
| `selfGuardPotential` | The ledger: uncured columns of `selfGuardRules ×ˢ U` under the accumulated renaming σ |
| `MintPaysForTimeAt` | `MintPaysForTime` verbatim plus a third disjunct, nothing removed |
| `gate_is_reissue_hazard` | All seven preconditions of the gate configuration, decided |
| `selfGuardPotential_lt_at_gate_with_id` | The component **does** drop 4→3 at the gate step under σ = `id` |
| `selfGuardPotential_eq_at_gate_with_sigma` | It does **not** drop under the run-realizable σ = `rhoSF 2 0` |
| `selfGuard_no_column_at_retired_time` | The general reason, quantified over every `U`, trigger, retired time |
| `mintPaysForTimeAt_reuse_false` | **VERDICT: FALSE**, at every frame class and every `Tmax` |

**Phase 10 (landed, documentation)** — the same file:

- C9 **register entry 17**, appended at the end of the register; opening count "Sixteen" → "Seventeen".
- A subsection **"The density residual"** between the verdict and C9.
- An **"Obligation map"** paragraph appended to `MintPaysForTimeAt`'s docstring.
- A reconciliation paragraph closing the stale "The repair, attempted and BLOCKED" narrative.

## The verdict and its evidence

**The refutation in one line.** `rhoSF_time_ne_src` is *already* a statement about times —
`(rhoSF src tgt sf).label.time ≠ src`, for every `sf` whatsoever. The register's existing formula-hit
refutation `mint_not_in_rhoSF_image` is a three-line corollary of it. `selfGuardPotential` inherits
the σ-hit obligation in a weakened **time-hit** form, and a weakening cannot escape the statement its
own refutation was a corollary of.

**The general reason.** `selfGuard_no_column_at_retired_time`: the curing edge that `untlNeg`'s
ACTIVE arm adds is anchored at the trigger's time. When that time is one an earlier identification
retired — which the time-reuse verdict decides the engine re-issues — *no column of
`selfGuardRules ×ˢ U` is indexed there at all*. The arm cures nothing; the count cannot fall.

**The decided instance** (σ = `rhoSF 2 0`), all three disjuncts of `MintPaysForTimeAt` failing:

| Disjunct | Quantity | Before → After | Test | Verdict |
|---|---|---|---|---|
| 1 | `knownTimes.card` | 3 → 4 | `4 ≤ 3` | false |
| 2 | `mintTimeBudget` | 27 → 28 | `28 ≤ 27` | false |
| 2 | `mintPotential` | 24 → 24 | `24 < 24` | false |
| 3 | `selfGuardPotential` | 3 → 3 | `3 < 3` | false |

**Why this is a refutation and not a measurement artifact.** Three things are established separately
rather than assumed:

1. `gate_is_reissue_hazard` decides all seven preconditions, so the failure is attributable to the
   arm and not to a violated hypothesis.
2. `selfGuardPotential_lt_at_gate_with_id` decides that the component **does** drop 4→3 at the same
   step under σ = `id`, so it is not inert and the failure is located precisely at σ.
3. `selfGuard_no_column_at_retired_time` gives the general reason, quantified over every `U`, every
   trigger and every retired time, so the concrete gate is an instance rather than a lucky choice.

## What remains open

**The fourth measure component is still missing.** Register entry 14's claim is unchanged and was
deliberately not edited. What entry 17 adds is that one more route to it is now closed, and that the
obstruction is not the component's shape — it is intrinsic to identification-plus-`maxTime`, the same
wall the live-times reformulation hits.

**The density residual.** `gapPotential` is the sound-but-**unattempted** second component and is
recorded, not implemented:

- Indexed by `U ×ˢ U`, not by a rule-product — `densityRule` splits each *maximal unfilled gap* at
  most once, and a gap is a pair. The ledger would transcribe the rule's own `gapTargets` filter
  (`Tableau.lean:1364-1366`).
- Quadratic in `|U|` where `selfGuardPotential` is linear; gated on `denseRules`
  (`Tableau.lean:1593`), so it contributes nothing at `.Base` / `.Discrete`.
- It is a genuinely separate exposure: `densityRule` returns `.persistent` (`Tableau.lean:1385`),
  mapped to `.extended` (`MintBound.lean:1071`), so it is inside `MintPaysForTimeAt`'s scope, yet it
  mints a fresh time while lying outside **both** `freshLabelRules` and `selfGuardRules` — no
  disjunct moves at all. Refuting the self-guard coordinate says nothing about this one either way.
- That density has to be a separate clause is the literature's own structure, not this
  development's invention: it is `(SVDns)`, listed among the *additional vertical saturation
  conditions* apart from the eventuality conditions (Caleiro–Viganò–Volpe 2013, §3.1, verified at
  `sources/caleiro_2013/sec03_31-mosaics.md:80`).

**Phases 2-9** — the per-rule discharge lemmas, the step lemmas, the four-component measure, the
concrete discharge, the terminus restatement — are `[BLOCKED]` and were never attempted. They were
all downstream of a component that does not exist.

## What a future attempt must not re-try

Recorded durably in C9 entry 17 so it survives this summary:

1. **Any fourth component whose decrease is witnessed on the trigger's *label*** — its time or its
   formula, it makes no difference. The time-hit weakening was the strongest available relaxation
   and it escapes nothing, because `rhoSF_time_ne_src` sits at the time level already.
2. **Reshaping `selfGuardPotential`.** The `σ = id` measurement proves the ledger is not inert; the
   failure is at σ, not at the ledger's shape. Fixing the shape fixes the wrong thing.
3. **Re-indexing `mintPotential` on `freshTimeRules`** (already entry 14) and **dropping disjunct 1's
   cardinality conjunct** (already entry 14). Entry 17's design avoided both; avoiding them was not
   enough.

## Verification

| Check | Result |
|---|---|
| `lake build` (full) | green, 2333 jobs |
| `lean_verify` on `mintPaysForTimeAt_reuse_false` | axioms `{propext, Classical.choice, Quot.sound}` — no `sorryAx`, no project axiom |
| `sorry` in diff | none |
| Vacuous definitions in diff | none |
| New axioms | none |
| Source files changed | `MintBound.lean` only; `Saturation.lean`, `Fuel.lean`, `Tableau.lean` untouched |
| Landed declarations altered | none — the whole diff is additive plus four re-wrapped prose lines |
| C9 count vs. entry count | "Seventeen" / 17 entries, matched |

## Reflection

**What worked.** The refute-first gate. Placing it before any plumbing lemma converted a 10-phase
plan into a decided negative result in two phases, at a cost of ~144 lines of Lean. Its value came
from deciding the one exposure the research could not discharge, not from surveying the design space.

**What was hard.** Nothing, once the gate was written — which is itself the finding. The design
survived every objection the register already knew how to raise, and still failed, on an obligation
the register had recorded one entry earlier in a form that looked stronger than it was.

**What was missed, and would have been caught earlier.** That `mint_not_in_rhoSF_image` was a
*corollary* of `rhoSF_time_ne_src` rather than an independent fact. The research treated the
formula-hit refutation as the obstacle and proposed a time-hit weakening to get under it; one
`lean_hover_info` on the refutation's proof would have shown there was nothing to get under. The
general lesson: before assuming a weakening escapes a refutation, check what **level** the
refutation's own supporting lemma lives at.
