# Implementation Summary: Task #434

- **Task**: 434 - Discharge `MintPaysForTime fc U Tmax`
- **Plan**: `specs/434_discharge_mintpaysfortime_residual/plans/01_mintpaysfortime-time-analogue.md`
- **Status at close**: Phases 1-7 `[COMPLETED]`, Phase 8 `[PARTIAL]`, Phase 9 `[COMPLETED]`
- **Files modified**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` (additive only)

## What this dispatch did

The dispatch was asked to re-evaluate Phases 7 and 8 against the repair task 436 landed
(`MintPaysForTimeStable`) and either execute them or report a residual.

**Verdict: the blocker was resolved, and the resolution was then found to be incomplete — by a
machine-checked refutation, not by argument.** Task 436's `MintPaysForTimeStable` unblocks Phase 7
in the sense that a repaired predicate with a direction lemma now exists, but that predicate is
**false at every nonempty universe**, so it does not meet Phase 7's stated goal ("land the
*satisfiable* form of the residual"). A second repair was designed, landed, and threaded through the
whole terminus chain.

### 1. The refutation (new, decided)

`mintPaysForTimeStable_signedUniverse_false` — `MintPaysForTimeStable fc (signedUniverse C L) Tmax`
is false at a concrete nonempty `signedUniverse`, at every frame class and every `Tmax`, with no
`densityRule` in the vehicle.

The cause is a coordinate mismatch. `SigmaTimeStable` constrains the renaming's **times**; disjunct
2 needs it to constrain the renaming's **formulas**, because `mintPotential_lt_of_mint` asks for
`σ sf = g` on the nose. `sigma_time_hit_of_sigmaTimeStable`'s own docstring already recorded that it
does not supply that; what was not noticed is that disjunct 2 is the only disjunct paying for the
six rules of `freshLabelRules ∩ freshTimeRules`, and disjunct 3 cannot stand in for it at a trigger
whose reach is already non-empty.

Supporting evidence, all general rather than configuration-specific:
- `witnessPresent_flatSigma` — the image of the label-preserving, formula-destroying renaming
  `flatSigma` is witness-free at all thirty-six rules;
- `mintPotential_flatSigma` — so `mintPotential` is pinned at its own ceiling `8·|U|` at *every*
  state, and disjunct 2's strict inequality is unavailable everywhere before any configuration is
  chosen;
- `selfGuardPotential_flatSigma` — the same renaming leaves the fourth component measuring exactly
  what `id` measures, so the refutation does not work by breaking the self-guard ledger too.

This corrects register entry 19's route 4 ("the density coordinate is the one thing left"), which is
now marked as withdrawn in one line and superseded by entry 20.

### 2. The repair (Phase 7)

`SigmaFixed σ b := ∀ x ∈ b, σ x = x`, and `MintPaysForTimeFixed` — `MintPaysForTimeStable`'s body
verbatim with the hypothesis restated at the formula coordinate and nothing else touched.

- **Direction lemma**: `mintPaysForTimeFixed_of_mintPaysForTimeStable` and the composite
  `mintPaysForTimeFixed_of_mintPaysForTime`. The hypothesis is stronger, so the predicate is
  **weaker**, so every restatement is a strengthening — stated in words on the docstring, per the
  register entry 7 gate.
- **The repair is free at the arm**, and that is a fact about `rhoSF` rather than a coincidence:
  `rhoSF_eq_of_ne_src` strengthens `rhoSF_time_eq_of_ne_src`'s conclusion from "same time" to "same
  formula" by the same one line, so `sigmaFixed_identifyOriented` and
  `sigmaFormulaFixed_identifyOriented` are their time-level originals' proofs verbatim.
- **No leak**: `mintPaysForTimeFixed_no_leak`, five conjuncts — both direction links, the seed
  discharge, the arm's own renaming (with no membership side condition at all), and arm preservation
  under exactly the side condition `universeClosedAt_identify_at_trigger_oriented` already carries.
- **Not inert**: `sigma_formula_hit_of_sigmaFixed` discharges `mintPotential_lt_of_mint`'s
  obligation from confinement alone, and `mintPotential_lt_of_pick_linear_sigmaFixed` /
  `..._branching_sigmaFixed` deliver disjunct 2 at the pick.
- **`flatSigma_not_sigmaFixed`** decides that the refuting vehicle does not reach the new predicate.

### 3. The terminus chain (Phase 8, task 1)

The full chain restated at `MintPaysForTimeFixed`: `BudgetStateFixed`, both step lemmas, the C6
instantiation `stepDecreases_budgetPotentialAt_fixed`, `BudgetedTotalityFixed`, and six terminus
theorems ending at `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed`.

**Cost: no figure at all.** Unlike the fourth measure component, which cost a coefficient in
`mintPathBound` and `derivedTmax`, this repair reuses `budgetPotentialAt`, `mintPathBoundAt`,
`mintAwareFuelAt` and `derivedTmaxAt` byte for byte. No caller's hypothesis list changes.

### 4. What remains open (Phase 8, task 2)

Two independent things, and the distinction matters:

- **(a) The engine-level assembly** — proof engineering, not open mathematics. Every per-rule
  payment now exists: disjunct 2 for the six witness-guarded minting rules, disjunct 3 for the two
  self-guarded ones, disjunct 1 (via `applyRule_emitted_time_dichotomy` and
  `expandOnceUnblocked_ord_mono`) for the twenty-seven that mint no time. What is missing is
  threading the picked rule through `expandOnceUnblocked`'s three stages so the case split is
  available at the successor.
- **(b) The density coordinate** — open mathematics, unchanged since register entry 17 named it.
  `densityRule` mints while lying outside both index sets, so no disjunct moves for any σ. It is
  `denseRules`-gated, so (a) alone would deliver a discharge at frame classes outside `.Dense` /
  `.Dedekind`; every frame class needs `gapPotential`.

The discharge therefore stands at `L = ∅` (`mintPaysForTimeFixed_signedUniverse_empty`), the same
boundary `mintPaysForTime_empty` records.

## Verification

- Full `lake build` green (2458 jobs).
- Zero `sorry`, zero vacuous definitions, zero new axioms. Every delivered declaration reports
  exactly `[propext, Classical.choice, Quot.sound]` under `#print axioms`.
- No new compiler warnings in the added region.
- `Saturation.lean`, `Fuel.lean`, `Tableau.lean` untouched; no previously-landed declaration in
  `MintBound.lean` altered — the only edits outside the appended block are three doc-comment
  reconciliations (the boundary preamble's incomplete claim, the residual roster note, and one
  withdrawn line inside register entry 19).
- C9 register grown from nineteen entries to twenty; header count updated.

## Plan Deviations

- **Phase 7, task 1** *(altered)*: the rule-coordinate narrowing the task specifies is refuted
  (register entry 14) and was not attempted. The narrowing that landed is on the **renaming**
  coordinate, in two steps.
- **Phase 7, task 4** *(altered)*: the obligation map is on `MintPaysForTimeFixed` rather than
  `MintPaysForTimeAt`.
- **Phase 8, task 1** *(altered)*: naming follows the file's `_fixed` suffix; the two seed-level
  termini are the pair identified by classification, not the pair the plan's Scope Hypothesis named;
  their four intermediate ancestors are restated too.
- **Phase 8, task 2** *(partial)*: discharged at `L = ∅` only. "At an arbitrary frame class" is
  refuted for any such discharge by the density coordinate.
- **Phase 8, task 3** *(altered)*: no closure condition on `L` is what the discharge needs, and none
  was invented; the conditions are on the renaming (discharged) and the frame class (a restriction).
- **Phase 8, task 4** *(altered)*: axiom-freedom verified with `#print axioms` under
  `lake env lean` rather than `lean_verify`.
