# Continuation handoff (plan v4) — Phase 9 CLOSED, Phase 10 pre-work recorded

**Plan**: `plans/04_ordtimesknown-strengthening-totality.md`
**Baseline for this dispatch**: `c116713d5`. **Head**: `01ebb3cfe`.

This supersedes `handoffs/v4-phase-9-handoff-20260805.md`. Every **other** file in `handoffs/`
belongs to an older plan's numbering and is STALE.

## What this cycle closed

| Phase | Marker | Commit |
|---|---|---|
| 9 (`applyRule`-level preservation) | `[IN PROGRESS]` | `12e7f469d` |
| 9 (engine lift + run induction — phase closed) | `[COMPLETED]` | `01ebb3cfe` |

**Both landed green on the FIRST build attempt.** No escalation, no deviation, no substitution.
**12 of 17** phase headings are now `[COMPLETED]`: 1, 2, 3, 4, 4.1, 4.2, 4.3, 5, 6, 7, 8, 9.

## Phase 9 — R4 is retired by proof

The residual the previous cycle named — `WorldWitness` discharged at the seed branch only — is
**gone**. `chain_le_worldFuel'`'s `hww` is now a theorem for runs out of the engine's own seed.

**The previous handoff's prediction about the route was correct.** `WorldWitness` (`Fuel.lean:1214`)
is not inductive: `wit w` is not required to lie on the branch nor to sit at the world it
witnesses, and the mint argument needs both. `WorldWitnessKnown` adds exactly those two clauses;
`worldWitness_of_known` recovers the weak form (the strengthening witness, mirroring
`ordTimesLeMaxTime_of_ordTimesKnown`). `Fuel.lean` is byte-untouched.

**The sizing figure in the plan's Scope Hypothesis was pessimistic, and this is a real finding.**
Only **two** of `TableauRule`'s 36 constructors mint a world — `boxNeg` and `diamondPos` — and both
emit exclusively at `Branch.nextWorld`. The 34 × 2 split still has to be paid once
(`applyRule_emitted_world_mem`), but the *content* lives in two named cases, not thirty-six.

Landed, in dependency order: `applyRule_emitted_world_mem`; `applyRule_boxNeg_emitted_world` /
`applyRule_diamondPos_emitted_world`; the four shape/result/eq/witness lemmas per minting rule;
`boxNeg_guard_sig` / `diamondPos_guard_sig` (the guard read as "no branch formula shares the minted
witness's signature" — the injectivity clause); `worldWitnessKnown_of_no_new_world` /
`worldWitnessKnown_mint`; `applyRule_worldWitnessKnown`; `findApplicableRule_guard_mint`,
`findApplicableSerialRule_rule`, `findApplicableLinearityRule_rule`, `pick_stage_source_guarded`;
`expandOnceUnblocked_worldWitnessKnown`; `worldWitnessKnown_seedBranch`, `worldWitnessKnown_chain`;
and the payoff triple `worldWitness_chain_of_seed`, `labelFinset_card_le_of_seed_run`,
`chain_le_worldFuel'_of_seed` (the last at `S.card = 1` via `seedWorlds_card`).

**Neither named fallback was taken. The escalation clause's sanctioned degraded outcome was not
invoked.**

### One limitation, recorded rather than glossed

`WorldWitnessKnown` is **not** transported across the ordered split's identification arm: `rho`
merges two times, so two non-seed worlds whose witnesses differ only in carrying the merged pair
have distinct signatures before arm 3 and the same signature after. That is a property of the arm —
the same shape of failure `ordTimes_identifyTime_arm3_false` records for the ordering-times
invariant — not a gap in the proof.

It costs nothing, and structurally rather than luckily: **`ExtendStep` (`Fuel.lean:423`) is
`.extended`-only**, so every run `chain_le_worlds_bounded` / `chain_le_worldFuel'` quantify over
takes no split of either kind. `expandOnceUnblocked_worldWitnessKnown` covers every step such a run
can take. A consumer needing the discipline *across* an ordered split would need an
`OrdTimesKnown`-shaped repair and does not have one. The note is in-source next to
`expandOnceUnblocked_worldWitnessKnown`.

## Exact resume point: Phase 10, task 2 (R2)

Phase 10 is `[IN PROGRESS]` with **task 3 discharged** and **no Lean written** — deliberately, since
the phase's own task order forbids committing to the measure before arm 3 is settled.

- **Task 3 (R3) is done and must not be re-derived**: `timeFinset_card_le_of_mem_stock` is landed,
  and its four hypotheses mention no world, no mint and no `|U|`.
- **Task 2 (R2) is the resume point.** The findings are written into the plan under Phase 10's
  "Completion notes so far" and are summarised here:
  - `witnessPresent_no_flip` gives only the **two-premise** form at an ordered split; counting needs
    one premise per pair, so it does not apply directly.
  - The complement injection fails for the reason R2 names: `rhoSF` merges `t₂` into `t₁`.
  - Concrete shape worth knowing: after the arm, `b'` carries **nothing** at `t₂`, so every pair
    whose formula sits at `t₂` reports no witness at `b'`; a pair whose witness was also at `t₂` was
    `true` before and is `false` after — a local *increase*. Whether the decreases at `t₁` always
    dominate is undecided in **both** directions. Nothing refutes the measure.
  - **Try the plan's named alternative first.** Indexing the filter over the pre-renaming pair set
    turns the obligation into `witnessPresent r (rhoSF t₂ t₁ sf) b' ord' = false →
    witnessPresent r sf b ord = false`, which is the **contrapositive of the landed
    `arm3_preserves_witness`** — available pointwise, no injection needed. The open piece is how a
    step-indexed measure composes along a run with a *second* identification. Settle that first.

## Build-time findings (R6 / R8)

| After | wall | user |
|---|---|---|
| Phase 8 tasks 3-4 / Phase 9 tasks 1-4 (previous cycle) | 130s | 6m03s |
| **Phase 9 `applyRule`-level block** | **150s** | **8m23s** |
| **Phase 9 engine lift (phase closed)** | **143s** | **9m01s** |

The 34 × 2 split (`applyRule_emitted_world_mem`) cost about **20s wall**. Wall time has flattened;
user time keeps climbing, which is parallel elaboration, not a per-declaration blow-up. **No
`set_option` was raised above the module's standing figure**: `applyRule_emitted_world_mem` uses
`maxHeartbeats 4000000`, the per-rule shape lemmas `1000000`, and nothing higher was needed.

## Constraint status (verified after every edit)

- `Saturation.lean` `ae47004e06e77f2846cc3e1dfa408382`, `Tableau.lean`
  `cfd82332c8e400ac97ab709ece5dfb4a`, `Fuel.lean` `8a395bd7117a682c1f8302a2ac5f0f1f` — **all three
  still match the plan's recorded baselines exactly.**
- `MintBound.lean` 2086 → 2879 lines, purely additive; no landed declaration deleted or renamed.
  The one edit to an existing declaration is to `applyRule_worldWitnessKnown`, added earlier **in
  this same cycle**: its `hguard` was weakened to the conditional
  `rule = .boxNeg ∨ rule = .diamondPos → …`, which is what the pick stage can actually supply.
- 0 `sorry`, 0 `axiom`, 0 `NoSplit`, 0 vacuous placeholders, 0 task-number citations.
- `#print axioms` on every headline result this cycle: exactly
  `[propext, Classical.choice, Quot.sound]`.

## Gotchas added to the previous handoff's list

- **`repeat' rcases hg with hg | hg` will case-split a `List.Mem` proof** when the list is a literal
  cons, renaming the hypothesis to `a✝` and losing it. Put the membership-normalising `simp only`
  **before** the `rcases` alternative in a `repeat' first | …` chain, never after.
- `subst_vars` also renames hypotheses to inaccessible names. Use it **inside** a `first`
  alternative (`(subst_vars; exact hw)`), never as a standalone `<;> (try subst_vars)` step.
- `casesm* _ ∨ _, ∃ _, _` breaks the whole `<;>` chain with "no match" when nothing applies, and
  renames when it does. A `repeat' first | <closers> | <destructors>` loop keeps names stable and is
  strictly better here.
- `exact Option.noConfusion hy` fails to elaborate on `none = some y` when the motive is a
  metavariable; `simp only [reduceCtorEq] at hy` closes the same goal.
- `boxDiamondPersistence` is `private` to `Tableau.lean` and cannot be named. Its three public
  companions can: `mem_boxDiamondPersistence_label` supplies `g.label = { world := w, time := ft }`,
  which is exactly the world fact the six fresh-time rules need.
- The plan's retained learning about `by`-blocks not backtracking inside `first` bit repeatedly this
  cycle. `exact absurd hg (by simp)` must be the **last** alternative, and any alternative that
  `clear`s a hypothesis before an inner `by` will leak "unknown identifier" errors.

## Still ahead — risk posture

- **Phase 10 (R2) is now the plan's only genuinely new bet left**, and it is the immediate resume
  point. Its task 3 is discharged; its task 2 has the analysis above and the named alternative
  untried in Lean.
- Phases 11-14 are `[NOT STARTED]` and unchanged.
- Phase 13's `.splitOrdered` arm remains unblocked in principle by
  `expandOnceUnblocked_splitOrdered_ordTimesKnown`.

## Deviations

None. Phase 9 followed the plan's task sequence exactly; the two named fallbacks were not taken
because the primary route closed, and both are annotated as such on their checklist lines. Phase 10
was entered in its own task order (task 3 before task 2) and stopped before writing any statement,
as that phase's own text requires.
