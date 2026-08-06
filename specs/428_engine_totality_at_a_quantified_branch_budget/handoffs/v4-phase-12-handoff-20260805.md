# Continuation handoff (plan v4) — Phases 10 and 11 CLOSED, Phase 12 is the resume point

**Plan**: `plans/04_ordtimesknown-strengthening-totality.md`
**Baseline for this dispatch**: `6ebbbc2dd`. **Head**: `60dc59106`.

This supersedes `handoffs/v4-phase-10-handoff-20260805.md`. Every **other** file in `handoffs/`
belongs to an older plan's numbering and is STALE.

## What this cycle closed

| Phase | Marker | Commit |
|---|---|---|
| 10 (the mint potential, R2 settled) | `[COMPLETED]` | `7708bd676` |
| 11 (guard before / witness after) | sub-step | `e3d7989a8` |
| 11 (the once-only bound closes) | `[COMPLETED]` | `60dc59106` |

**Every milestone landed green on the FIRST build attempt.** No escalation. **14 of 17** phase
headings are now `[COMPLETED]`: 1, 2, 3, 4, 4.1, 4.2, 4.3, 5, 6, 7, 8, 9, 10, 11. Phases 12, 13,
14 are `[NOT STARTED]`.

## Phase 10 — R2 is settled BY PROOF, via the plan's own named alternative

The primary (`σ`-free) measure is **not** available at the identification arm, for the reason R2
names: `rhoSF t₂ t₁` is not injective on `U`. The landed measure therefore carries the
accumulated renaming as an explicit parameter:

```lean
def mintPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (b : Branch) (ord : TimeOrdering) : Nat :=
  ((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 (σ p.2) b ord = false)).card
```

The index set `freshLabelRules ×ˢ U` is then **fixed for the whole run**, so both step shapes are
pointwise *subset* facts and **no injection is needed or built**:

* `mintPotential_le_of_grow` — ordinary steps (`.extended`, `.split`, ordered arms 1-2), from the
  two `witnessPresent` monotonicity lemmas.
* `mintPotential_identifyTime` — **arm 3**, from `arm3_preserves_witness` read contrapositively,
  with `rhoSF t₂ t₁` **post-composed** onto `σ`.

Post-composition is what answers the previous cycle's open question ("how does a step-indexed
measure compose along a run with a *second* identification"): `σ` is a parameter of the measure,
not a choice fixed inside it, so the arm-3 lemma applies unchanged at the second, third and `n`-th
identification. `mints_le_eight_mul` is that composition, machine-checked over an arbitrary
sequence of states, renamings and mint counts, concluding `#mints ≤ 8·|U|` with no mention of the
branch or of branch growth.

Also landed: `freshLabelRules` / `_card` / `mem_freshLabelRules` (the `Finset`/`Bool` agreement is
**proved** over all 36 constructors, not asserted); `mintPotential_le_eight_mul`;
`mintPotential_lt_of_mint`; `mintPotential_expandOnceUnblocked` and
`mintPotential_expandOnceUnblocked_splitOrdered`; `mintBudget_preserved` /
`mintBudget_preserved_mint`; and `BudgetedTotality`.

**Deviations, both annotated on their checklist lines** (plan drift for this cycle: 2 of 6 Phase 10
items, 0 of 4 Phase 11 items):
1. The measure carries `σ`; the plan's displayed shape is the `σ = id` specialization.
2. `BudgetedTotality` is a `Prop`-valued **definition**, not an unproved `theorem` — a theorem
   cannot be landed without a proof and `sorry` is absolutely prohibited. Every element the task
   lists is present in it, and Phase 13 proves `BudgetedTotality …`.

## Phase 11 — the guard before, the witness after

**The Scope Hypothesis reading is CONFIRMED in the strong direction.** At `Tableau.lean:1908` and
`:1931` the witness test sits in the `then` position of `if ruleMintsFreshLabel rule`, with the
output-presence test in the *else* branch: it **replaces** that test, never `&&`-composes with it.
The phase flagged an `&&`-composition as fatal to the once-only argument in advance; it is not one.
`not_selfGuarded_of_fresh` shows the `.branching` arm's `ruleSelfGuarded` pre-test never diverts a
fresh-label rule away from its guard.

Landed in dependency order: `not_selfGuarded_of_fresh`; `findApplicableRule_guard_linear` /
`findApplicableRule_guard_branching` (generalising `findApplicableRule_guard_mint` from the two
world-minting rules to all eight, by taking the result shape as a hypothesis rather than excluding
the unguarded shapes rule by rule); `applyRule_fresh_witness_nonbranching` /
`applyRule_fresh_witness_branching` (both arms of each branching rule proved individually);
`mintPotential_lt_of_pick_linear` / `mintPotential_lt_of_pick_branching`.

## THE ONE RESIDUAL — read this before Phase 12

`mintPotential_lt_of_pick_*` and `mintPotential_lt_of_mint` carry `hσ : σ sf = sf₀` with
`sf ∈ U`: the formula the rule fires on must be **`σ`-hit** by the index set. `σ`'s image omits
exactly the times earlier identifications merged away, so the obligation is that **a minting
formula does not sit at a merged-away time**.

**This is a question about time reuse, not about the measure.** `Branch.nextTime` is
`Branch.maxTime + 1` and `Branch.identifyTime` can *lower* `Branch.maxTime` — the configuration
`ordTimes_identifyTime_arm3_false` decides drops it from `5` to `0` — so a fresh time can in
principle re-issue a value an earlier identification removed. The "live times" reformulation of
the potential (filter additionally on the formula's time being a fixed point of `σ`) carries the
**identical** obligation, which is what shows it is intrinsic to the situation rather than an
artifact of the chosen shape. It is a visible hypothesis everywhere it appears; nothing assumes it.

Two routes for a successor, neither tried:
1. Prove that a fresh time is never a merged-away one along an engine run — i.e. that
   `Branch.maxTime` never drops below a time the run has already retired. This is the strong
   route and it would discharge the residual outright.
2. Carry it as an explicit side condition into Phase 13's induction and discharge it at the seed,
   where `σ = id` makes it trivial, for as long as the run takes no ordered split — which is
   *weaker* than what Phase 13 needs and would have to be flagged as a residual on the terminus.

Route 1 first. Route 2 is not a licence to narrow the theorem to unbranching runs.

## Exact resume point: Phase 12, task 1

Nothing is in flight; the tree is clean at `60dc59106`. Phase 12's three inequalities are all
abstract-counter arithmetic over landed cardinality lemmas, in the style of Phase 10's
`mints_le_eight_mul` (which is the shape to copy):

* `#identifications ≤ |knownTimes|₀ + #mints` — from `knownTimes_card_lt_identifyTime`
  (`Fuel.lean:1971`). The clean additive form of "ident + kt − mints is non-increasing" is
  `∀ i < n, ident (i+1) + kt (i+1) + mints i ≤ ident i + kt i + mints (i+1)`, which avoids `Nat`
  subtraction entirely and folds by the same induction `mints_le_eight_mul` uses.
* `total shrinkage ≤ #identifications · |U|` — per identification, shrinkage is bounded by
  `b.toFinset.card ≤ U.card` outright.
* `#extensions ≤ |U| + total shrinkage` — from `expandOnceUnblocked_card_lt` (`Fuel.lean:110`) and
  `expandOnceUnblocked_split_card_lt` (`:1843`).
* Then check the assembled figure against `splitPathBound` / `splitAwareFuel` (`Fuel.lean:2465`,
  `:2485`) rather than writing the plan's figure unchecked.

## Build-time findings (R6 / R8)

| After | wall | user |
|---|---|---|
| Phase 9 (previous cycle) | 143s | 9m01s |
| **Phase 10 (the mint potential)** | **124s** | **7m48s** |
| **Phase 11 guard + witness block** | **161s** | **13m52s** |
| **Phase 11 pick-level block (phase closed)** | **161s** | **13m47s** |

Phase 10's block is `Finset` cardinality reasoning with **no** case split over `TableauRule` and
cost nothing — wall time went *down*. Phase 11's two witness lemmas are the cost:
`applyRule_fresh_witness_nonbranching` elaborates in ~66s standalone,
`applyRule_fresh_witness_branching` in ~121s, each a 36 × 2 split with a `simp_all` inside every
surviving arm. **No `set_option` was raised above the module's standing figure** — those two carry
`maxHeartbeats 4000000` and nothing else in either phase needed any.

**Budget note for the next cycle**: at 161s wall / ~14m user the module is now the dominant build
cost. Prefer `lake env lean` against a scratch file importing `MintBound` for iteration (6s or
less per attempt, and 1.7s once warm) and reserve `lake build` for milestones — that is what kept
this cycle to four module builds.

## Constraint status (verified after every edit)

- `Saturation.lean` `ae47004e06e77f2846cc3e1dfa408382`, `Tableau.lean`
  `cfd82332c8e400ac97ab709ece5dfb4a`, `Fuel.lean` `8a395bd7117a682c1f8302a2ac5f0f1f` — **all three
  still match the plan's recorded baselines exactly.**
- `MintBound.lean` 2879 → 3370 lines, purely additive; no landed declaration deleted, renamed or
  edited.
- 0 `sorry`, 0 `axiom`, 0 `NoSplit`, 0 vacuous placeholders, 0 task-number citations.
- `#print axioms` on every headline result this cycle: exactly
  `[propext, Classical.choice, Quot.sound]` (`freshLabelRules_card`, being decided, reports the
  subset `[propext, Quot.sound]`).

## Gotchas added to the previous handoff's list

- **`grep 'NoSplit' MintBound.lean` is a plan-level gate**, and prose counts. A docstring bullet
  reading "`NoSplit` is gone" tripped it; the fix is to name the restriction without spelling the
  identifier (`expandBranchWithFuel_isSome_of_noSplit` is fine — the gate is case-sensitive).
- **A `simp only … at h` that closes the goal breaks the tactic block that follows it** with "No
  goals to be solved" in exactly those arms where it closed. Wrapping the continuation in
  `all_goals` fixes it and costs nothing where goals remain.
- Nested `first | (…) | (…)` inside a `<;>` chain is very easy to mis-paren; the reported error is
  `unexpected token '|'; expected ')'` at the *previous* token's position, one line above where
  the missing `)` belongs.
- `Finset.ssubset_iff_of_subset` + `Finset.card_lt_card` is the right pair for a strict-decrease
  card argument; `Finset.card_filter_le` plus `Finset.card_product` gives the `8 * U.card` ceiling
  in two lines.
- `List.mem_map_of_mem` and `List.mem_append_right` avoid needing the module-private `sub_append`
  when working in a scratch file.

## Deviations

Two, both in Phase 10 and both annotated inline on their checklist lines (see above). Phase 11
followed its task sequence exactly, 0 deviations across its 4 items.
