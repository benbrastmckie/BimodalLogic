# Continuation handoff (plan v4) — Phases 10, 11, 12 CLOSED; Phase 13 is the resume point

**Plan**: `plans/04_ordtimesknown-strengthening-totality.md`
**Baseline for this dispatch**: `6ebbbc2dd`. **Head**: `42eb247dd`.

This is the **only current handoff**. It supersedes `handoffs/v4-phase-12-handoff-20260805.md`
(written mid-cycle, before Phase 12 closed) and `handoffs/v4-phase-10-handoff-20260805.md`. Every
other file in `handoffs/` belongs to an older plan's numbering and is STALE.

## What this cycle closed

| Phase | Marker | Commit |
|---|---|---|
| 10 (the mint potential, R2 settled) | `[COMPLETED]` | `7708bd676` |
| 11 (guard before / witness after) | sub-step | `e3d7989a8` |
| 11 (the once-only bound closes) | `[COMPLETED]` | `60dc59106` |
| 12 (the counting chain) | `[COMPLETED]` | `42eb247dd` |

**Every milestone landed green on the FIRST build attempt.** No escalation, no `[BLOCKED]`.
**15 of 17** phase headings are now `[COMPLETED]`: 1, 2, 3, 4, 4.1, 4.2, 4.3, 5, 6, 7, 8, 9, 10,
11, 12. **Phases 13 and 14 are `[NOT STARTED]`** and are all that remain.

## Phase 10 — R2 is settled BY PROOF, via the plan's own named alternative

The primary (`σ`-free) measure is **not** available at the identification arm, for the reason R2
names: `rhoSF t₂ t₁` is not injective on `U`. The landed measure carries the accumulated renaming
as an explicit parameter:

```lean
def mintPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  ((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 (σ p.2) b ord = false)).card
```

The index set `freshLabelRules ×ˢ U` is then **fixed for the whole run**, so both step shapes are
pointwise *subset* facts and **no injection is needed or built**:

* `mintPotential_le_of_grow` — ordinary steps (`.extended`, `.split`, ordered arms 1-2).
* `mintPotential_identifyTime` — **arm 3**, the contrapositive of `arm3_preserves_witness`, with
  `rhoSF t₂ t₁` **post-composed** onto `σ`.

Post-composition answers the previous cycle's open question ("how does a step-indexed measure
compose along a run with a *second* identification"): `σ` is a parameter of the measure, not a
choice fixed inside it, so the arm-3 lemma applies unchanged at the `n`-th identification.
`mints_le_eight_mul` is that composition, machine-checked over an arbitrary sequence of states,
renamings and mint counts, concluding `#mints ≤ 8·|U|` with no mention of branch or branch growth.

Also landed: `freshLabelRules` / `_card` / `mem_freshLabelRules` (the `Finset`/`Bool` agreement is
**proved** over all 36 constructors); `mintPotential_le_eight_mul`; `mintPotential_lt_of_mint`;
`mintPotential_expandOnceUnblocked` and `mintPotential_expandOnceUnblocked_splitOrdered`;
`mintBudget_preserved` / `mintBudget_preserved_mint`; `BudgetedTotality`.

## Phase 11 — the guard before a mint, the witness after one

**The Scope Hypothesis reading is CONFIRMED in the strong direction.** At `Tableau.lean:1908` and
`:1931` the witness test sits in the `then` position of `if ruleMintsFreshLabel rule`, with the
output-presence test in the *else* branch: it **replaces** that test, never `&&`-composes with it.
The phase flagged an `&&`-composition as fatal in advance; it is not one.
`not_selfGuarded_of_fresh` shows the `.branching` arm's `ruleSelfGuarded` pre-test never diverts a
fresh-label rule away from its guard.

Landed: `not_selfGuarded_of_fresh`; `findApplicableRule_guard_linear` /
`findApplicableRule_guard_branching`; `applyRule_fresh_witness_nonbranching` /
`applyRule_fresh_witness_branching` (all eight rules, **both** arms of each branching rule proved
individually); `mintPotential_lt_of_pick_linear` / `mintPotential_lt_of_pick_branching`.

## Phase 12 — the counting chain, and the fuel figure fits

`fold_le_of_step` is one fold instantiated three times, in the additive form
`f (i+1) + g i ≤ f i + g (i+1)` so that **no `Nat` subtraction ever appears** and `omega` closes
every link. Landed: `identStep_le` / `mintStep_le` / `plainStep_le`; `knownTimes_card_lt_at_arm3`;
`idents_le_knownTimes_add_mints` (link 1); `derivedTmax` / `derivedTmax_spec`;
`shrinkage_le_card`; `shrinkage_total_le` (link 2); `extensions_le` (link 3); `path_le_of_links`,
`orderedRunBound_ge`, `path_le_splitPathBound`.

**Task 4's check came out clean**: the assembled figure `|U| + Tmax·|U| + Tmax` sits below
`splitPathBound |U| Tmax`, so **Phase 13 consumes `splitAwareFuel` unchanged** and no divergence
had to be recorded.

**`Tmax` is derived, not assumed**: `derivedTmax kt0 |U| = kt0 + 8·|U|`, and
`BudgetedTotality`'s time hypothesis holds at it definitionally (`derivedTmax_spec`).

## THE ONE RESIDUAL — read this before Phase 13

`mintPotential_lt_of_mint` and both `mintPotential_lt_of_pick_*` carry `hσ : σ sf = sf₀` with
`sf ∈ U`: the formula the rule fires on must be **`σ`-hit** by the index set. `σ`'s image omits
exactly the times earlier identifications merged away, so the obligation is that **a minting
formula does not sit at a merged-away time**.

**This is a question about time reuse, not about the measure.** `Branch.nextTime` is
`Branch.maxTime + 1` and `Branch.identifyTime` can *lower* `Branch.maxTime` — the configuration
`ordTimes_identifyTime_arm3_false` decides drops it from `5` to `0` — so a fresh time can in
principle re-issue a value an earlier identification removed. The "live times" reformulation of
the potential (filter additionally on the formula's time being a fixed point of `σ`) carries the
**identical** obligation, which shows it is intrinsic to the situation rather than an artifact of
the chosen shape. It is a visible hypothesis everywhere it appears; nothing assumes it.

Two routes, neither tried:
1. **Prove a fresh time is never a merged-away one along an engine run** — i.e. that the engine
   never re-issues a time an earlier arm-3 retired. This is the strong route and discharges the
   residual outright. Try it first.
2. Carry it as an explicit side condition into Phase 13's induction. If Phase 14 then has to name
   it on the terminus, that is a residual and the plan's rules for one apply: named in-source,
   named in the summary, harmlessness **proved** rather than asserted.

Route 2 is **not** a licence to narrow the theorem to unbranching runs, and neither route may be
replaced by an `axiom`, a `sorry`, or a re-introduction of the unbranching restriction.

## Exact resume point: Phase 13, task 1

Nothing is in flight; the tree is clean at `42eb247dd`; the module is green and sorry-free.

Phase 13 proves `BudgetedTotality` (`MintBound.lean`, end of section C3) by induction on fuel.
Everything it names is landed:

* `saturated` / `extended` arms carry over from `expandBranchWithFuel_isSome_of_noSplit`
  (`Fuel.lean:1462`); re-establish the invariant at each successor with
  `expandOnceUnblocked_runInvariant`.
* `.split` arm: `expand_split_fold_isSome` (`Fuel.lean:2237`), with
  `expandOnceUnblocked_split_card_lt`, `allocateFuelProportionally_ge`, `splitBudget_preserved`.
* `.splitOrdered` arm: `expand_splitOrdered_fold_isSome` (`Fuel.lean:2289`), with
  `mintPotential_expandOnceUnblocked_splitOrdered` (which reports *which* renaming each arm
  carries) and `expandOnceUnblocked_splitOrdered_ordTimesKnown`.
* The mint dimension: `mints_le_eight_mul` plus `mintBudget_preserved` /
  `mintBudget_preserved_mint` for the per-step arithmetic, and the two
  `mintPotential_lt_of_pick_*` for the strict decrease — subject to the residual above.
* Do not forget the phase's **branching non-vacuity witness**; a terminus that only applied to
  unbranching runs would have removed the restriction in name only.

## Build-time findings (R6 / R8)

| After | wall | user |
|---|---|---|
| Phase 9 (previous cycle) | 143s | 9m01s |
| **Phase 10 (the mint potential)** | **124s** | **7m48s** |
| **Phase 11 guard + witness block** | **161s** | **13m52s** |
| **Phase 11 pick-level block (phase closed)** | **161s** | **13m47s** |
| **Phase 12 (the counting chain)** | **161s** | **13m30s** |

Phases 10 and 12 are `Finset`/`Nat` reasoning with **no** case split over `TableauRule` and cost
nothing — Phase 10's block took wall time *down*. Phase 11's two witness lemmas are the entire
increase: `applyRule_fresh_witness_nonbranching` elaborates in ~66s standalone,
`applyRule_fresh_witness_branching` in ~121s, each a 36 × 2 split with a `simp_all` in every
surviving arm. **No `set_option` was raised above the module's standing figure** — those two carry
`maxHeartbeats 4000000`; nothing else added in three phases needed any.

**Budget note for the next cycle**: at 161s wall / ~13.5m user the module is the dominant build
cost. Iterate with `lake env lean` against a scratch file importing `MintBound` (1.7-7s per
attempt) and reserve `lake build` for milestones — that is what held this cycle to five module
builds across three phases.

## Constraint status (verified after every edit)

- `Saturation.lean` `ae47004e06e77f2846cc3e1dfa408382`, `Tableau.lean`
  `cfd82332c8e400ac97ab709ece5dfb4a`, `Fuel.lean` `8a395bd7117a682c1f8302a2ac5f0f1f` — **all three
  still match the plan's recorded baselines exactly.**
- `MintBound.lean` 2879 → 3524 lines, purely additive; **no landed declaration deleted, renamed or
  edited** anywhere in this cycle.
- 0 `sorry`, 0 `axiom`, 0 `NoSplit`, 0 vacuous placeholders, 0 task-number citations.
- `#print axioms` on every headline result: exactly `[propext, Classical.choice, Quot.sound]`
  (`freshLabelRules_card`, being decided, reports the subset `[propext, Quot.sound]`).

## Gotchas added to the previous handoff's list

- **`grep 'NoSplit' MintBound.lean` is a plan-level gate, and prose counts.** A docstring bullet
  reading "`NoSplit` is gone" tripped it; name the restriction without spelling the identifier
  (`expandBranchWithFuel_isSome_of_noSplit` is fine — the gate is case-sensitive).
- **A `simp only … at h` that closes the goal breaks the tactic block after it** with "No goals to
  be solved", in exactly those arms where it closed. Wrapping the continuation in `all_goals` fixes
  it and costs nothing where goals remain.
- Nested `first | (…) | (…)` inside a `<;>` chain is easy to mis-paren; the reported error is
  `unexpected token '|'; expected ')'` at the *previous* token, one line above the missing `)`.
- `Finset.ssubset_iff_of_subset` + `Finset.card_lt_card` is the pair for a strict-decrease card
  argument; `Finset.card_filter_le` with `Finset.card_product` gives the `8 * U.card` ceiling in
  two lines.
- Write counter folds additively (`f (i+1) + g i ≤ f i + g (i+1)`). `Nat` subtraction in the
  statement puts `omega` out of reach for no gain.
- `List.mem_map_of_mem` and `List.mem_append_right` avoid needing the module-private `sub_append`
  when working in a scratch file.
- A bare `simp only at h` with no lemmas fails with "made no progress" when the beta-reduction it
  was meant to do has already happened; drop it and let `omega` see the `have` directly.

## Deviations

Two across the whole cycle, both in Phase 10, both annotated inline on their checklist lines:
1. `mintPotential` carries `σ`; the plan's displayed shape is the `σ = id` specialization, which
   is not preserved at arm 3.
2. `BudgetedTotality` is a `Prop`-valued **definition**, not an unproved `theorem` — a theorem
   cannot be landed without a proof and `sorry` is absolutely prohibited. Every element the task
   lists is present in it, and Phase 13 proves `BudgetedTotality …`.

Phases 11 and 12 followed their task sequences exactly: **0 deviations across their 8 items.**
