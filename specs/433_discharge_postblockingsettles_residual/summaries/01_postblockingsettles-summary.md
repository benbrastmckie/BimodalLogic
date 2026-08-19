# Implementation Summary: Discharge the `PostBlockingSettles` residual

- **Task**: 433
- **Plan**: `specs/433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md`
- **Outcome**: `[PARTIAL]` — outcome (b) in full: refutation, repaired predicate with its direction
  lemma, terminus restated at it, and a non-vacuous instantiation
- **Phases**: 8 of 8 closed (6 `[COMPLETED]`, 2 `[COMPLETED WITH EXCLUSIONS]`)
- **Files modified**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`
  (1166 insertions, 4 deletions; all four deletions are docstring text)

## The verdict

`PostBlockingSettles fc` is **false**, at every frame class, and **fuel does not close it** — which
answers the open question the residual's own docstring posed and which `Saturation.lean` leaves
open. The docstring is corrected in place; the `def` is byte-unchanged.

**Two repairs were tried. The first was rejected by its own gate, on decided evidence.** The plan
pre-declared relocating two conditions onto the pass's *output* branch. That predicate
(`PostBlockingSettlesAt`) was landed with its direction lemma and then refused: the consuming sites
cannot supply its antecedents, the only bridge shape that typechecks carries a refuted hypothesis,
and — sharpest — its second antecedent is, given its first, *equivalent to its conclusion*. So
`PostBlockingSettlesAt` is a theorem, not a repair, and it is recorded as such.

**The repair that is landed is the narrowing**, authorised by explicit orchestrator ruling after
that gate returned FALSE. `PostBlockingSettlesRun fc fuel` is `PostBlockingSettles`'s statement with
the pass's input branch restricted to a branch some `expandBranchWithFuel` call returned open, at
that call's own fuel — the only way `buildTableauAt` reaches it. This is not a new idea but the
batch's own architecture: task 432's `UniverseClosedAt`, task 436's `MintPaysForTimeStable`, task
434's `MintPaysForTimeFixed`, and — closest — `ArmSettlement`, already in this file, whose docstring
is where the "restricted to arms an engine run actually hands the fold" idiom comes from.

The narrowed residual **carries the terminus**: `buildTableauAt_isSome_of_settlesRun` is the bridge
the output-branch design could not build, eight terminus restatements land on it, and
`buildTableauAt_isSome_of_budget_of_run` certifies that each restatement is a *strengthening* by
re-deriving the landed statement from it. It is a **hypothesis, not a discharge** — register entry
24 exists so that is not mistaken — but it is neither refuted nor vacuous.

Also delivered: the **location** of the residual, which is what the rejected repair bought. It is a
fuel-adequacy fact about the post-blocking pass plus a label-minting fact about the branch that pass
reaches, and neither is a settlement question. `LabelFreeUniverseAt` is the one branch-independent
sufficient condition that survives the equivalence, landed with its discharge lemma.

## Phase-by-phase

| Phase | Marker | Verdict |
|-------|--------|---------|
| 1. Gate 1 — fuel-zero | `[COMPLETED]` | TRUE: literal predicate refuted at the `fuel = 0` arm |
| 2. Gate 2 — does fuel close the gap? | `[COMPLETED]` | TRUE: fuel does **not** close it, at every fuel figure |
| 3. Repaired predicate + direction-lemma gate | `[COMPLETED WITH EXCLUSIONS]` | FALSE: the *output-branch* repair is not admissible; both its bridges excluded |
| 4. Settlement lemma | `[COMPLETED]` | Outcome (a): `PostBlockingSettlesAt fc` proved outright |
| 5. Concrete discharge + non-vacuity | `[COMPLETED]` | TRUE on the letter, with the equivalence caveat recorded |
| 6. Restate the termini | `[COMPLETED]` | GATE PASSED: the narrowed residual carries `buildTableauAt_isSome_of_budget` |
| 7. C9 entries, verdict record, repo gate | `[COMPLETED]` | Entries 22, 23 and 24 added; `lake build` green |
| 8. The proof branch | `[COMPLETED WITH EXCLUSIONS]` | Not executed: entry condition (Phase 2 FALSE) not met |

## What landed

All additive, in a new section C12 of `MintBound.lean` placed immediately before the C9 register.
35 new declarations (4 `def`s, 31 theorems, plus 4 predicate `def`s counted among them):

**The refutation** — `saturateBlocked_fuel_zero`, `findUnexpandedUnblockedWith_multBranch_one`,
`postBlockingSettles_fuel_zero_false`, `saturateBlocked_eq_self_of_noFresh_saturated`,
`findClosure_freshWorldBranch`, `expandOnceNoFresh_freshWorldBranch`,
`findUnexpandedUnblockedWith_freshWorldBranch`, `postBlockingSettles_gap_at_every_fuel`,
`postBlockingSettles_fuel_gap_false`.

**The repaired predicate and its gate** — `LabelFreeSaturatedExit`, `NoUnblockedFreshWork`,
`PostBlockingSettlesAt`, `postBlockingSettlesAt_of_postBlockingSettles`,
`expandOnceNoFresh_multBranch_one`, `labelFreeSaturatedExit_not_of_saturateBlocked_inr`,
`PostBlockingExitSettled`, `postBlockingSettles_of_postBlockingExitSettled`,
`postBlockingExitSettled_false`.

**The settlement content** — `findApplicableRule_result_ne_notApplicable`,
`expandOnceNoFresh_saturated_imp`, `findUnexpandedUnblockedWith_eq_none_of_isExpanded`,
`postBlockingSettlesAt_settlement`, `postBlockingSettlesAt_holds`.

**How far the discharge goes** — `noUnblockedFreshWork_of_settled`,
`noUnblockedFreshWork_iff_of_labelFreeSaturatedExit`, `LabelFreeUniverseAt`,
`noUnblockedFreshWork_of_labelFreeUniverseAt`, `multSettledBranch`,
`saturateBlocked_step_extended`, `findClosure_multBranch_one`, `findClosure_multSettledBranch`,
`labelFreeSaturatedExit_multSettledBranch`, `noUnblockedFreshWork_multSettledBranch`,
`saturateBlocked_multBranch_one_run`, `postBlockingSettlesAt_labelFree`.

**The narrowed repair, and the termini at it** — `PostBlockingSettlesRun`,
`postBlockingSettlesRun_of_postBlockingSettles`, `expandBranchWithFuel_eq_none_zero`,
`postBlockingSettlesRun_zero`, `buildTableauAt_isSome_of_settlesRun`,
`buildTableauAt_isSome_of_budget_run`, `buildTableauAt_isSome_of_budget_of_run`,
`buildTableauAt_isSome_at_seed_run`, `buildTableauAt_isSome_of_budget_at_run`,
`buildTableauAt_isSome_at_seed_at_run`, `buildTableauAt_isSome_of_budget_selfGuarded_run`,
`buildTableauAt_isSome_at_seed_selfGuarded_run`, `buildTableauAt_isSome_of_budget_fixed_run`,
`buildTableauAt_isSome_at_seed_fixed_run`, `multBranch_one_length_lt_multSettledBranch`, and the
`postBlockingRunProbe` non-vacuity measurements (seven `#guard_msgs`-checked).

**The record** — C9 register entries 22, 23 and 24; the register header count corrected from
"Twenty-one" to "Twenty-four"; the `PostBlockingSettles` docstring's open-question paragraph
corrected in place and its settled repair named.

## Verification

- `lake build` green across the whole repository (2458 jobs, exit 0).
- Zero `sorry` in `MintBound.lean`, before and after. Every repo-wide occurrence is pre-existing and
  in `FormalSystem/Boneyard/`.
- Repo-wide `^axiom ` count unchanged at 7.
- All 42 new theorems checked with `#print axioms`: axioms within
  `{propext, Classical.choice, Quot.sound}`; one depends on no axiom at all.
- Seven `#guard_msgs`-checked non-vacuity probes are build-time obligations and pass.
- `Saturation.lean`, `Tableau.lean` and `Fuel.lean` byte-unchanged.
- No previously-landed declaration's statement or proof altered.

## Plan Deviations

- **Phase 1, witness vehicle** — *altered*. Reused the landed `multBranch 1 = [F(p → q)@⟨0,0⟩]` and
  its proved `∀ fc` reduction rather than introducing a fresh conjunction witness. The plan's
  normative requirement (a one-formula branch whose formula has an applicable label-free rule at the
  initial label) is met.
- **Phases 1 and 2, `decide` facts** — *altered*. Landed as named lemmas proved by definitional
  unfolding rather than by `decide`, which is unavailable on statements universally quantified in
  the frame class. Separability — the plan's actual requirement — is preserved by the lemma split.
- **Phase 2, witness shape** — *altered*. Used the landed `freshWorldBranch = [F(□p)@⟨0,0⟩]`, whose
  `.boxNeg` rule trips `expandOnceNoFresh`'s **first** rejection test, rather than a temporal
  existential tripping the second. Register entry 13 records that the two tests exist precisely
  because neither rule list subsumes the other. Recorded in the theorem's own docstring.
- **Phase 3, `LabelFreeSaturatedExit`'s shape** — *altered*. Landed as
  `(expandOnceNoFresh b ord fc).1 = .saturated`, not the pre-declared pair equation. Forced by the
  frozen definition (`expandOnceNoFresh`'s `.notApplicable` arm returns the picked ordering); Phase
  4's task list pre-sanctions the narrowing.
- **Phase 3, both bridges** — *skipped*. Gate returned FALSE on decided evidence. Recorded in the
  phase's Reasoned Exclusions and in register entry 23.
- **Phase 4, sequencing** — *altered*. Executed on a FALSE Phase 3 verdict, which the plan's
  dependency graph does not contemplate. Phase 4's content is independent of the bridge verdict and
  is the evidence that makes that verdict decidable rather than merely observed. Raised to the
  dispatching agent before proceeding; Phases 5-6 were held until the equivalence result settled the
  question independently.
- **Phase 4, a fourth fact** — the Scope Hypothesis's three-lemma estimate was short by one:
  `findApplicableRule_result_ne_notApplicable`, needed to kill `expandOnceNoFresh`'s second route to
  `.saturated`.
- **Phase 5, fragment predicate** — *altered*. Landed as `LabelFreeUniverseAt fc U ord`,
  parameterised by the ordering as well as the universe, because `orderTrichotomy` is applicable to
  every signed formula and lengthens the ordering exactly when it carries an incomparable pair.
- **Phase 5, non-vacuity witness** — *altered*. The witness is the post-blocking pass's own run
  rather than a seed run through `buildTableauAt`; it is the stronger statement for this purpose.
- **Phase 6, predicate shape** — *altered*, by explicit orchestrator ruling recorded on Phase 3.
  The restated termini take `PostBlockingSettlesRun fc <fuel>` plus `ArmSettlement fc`, not the
  `PostBlockingSettlesAt` the plan pre-declared, which Phase 3's gate proved inadmissible. Suffix
  `_run`. Phase 3's FALSE verdict is not retro-edited.
- **Phase 6, restatement count** — *altered*. Eight of the twenty-two termini restated (the four
  family roots and their four caller-facing seed forms); the remaining fourteen are `_lengthBudget`
  / `signedUniverse` substitutions with the mechanical one-line recipe recorded in the phase's
  Reasoned Exclusions.
- **Phase 8** — *skipped*. Entry condition not met (Phase 2 returned TRUE).
- **Testing & Validation, the bridge item** — *altered*. One of the two bridges is landed:
  `buildTableauAt_isSome_of_settlesRun`. There is deliberately no
  `armSettlement_of_postBlockingSettlesRun` — the narrowed residual is about `buildTableauAt`'s own
  arm, and `ArmSettlement` (itself already narrowed the same way) is carried explicitly in the
  restated termini rather than manufactured from a refuted predicate.

## Open follow-ons

1. **Discharge `PostBlockingSettlesRun fc fuel` at the terminus's fuel figure.** It is carried as a
   hypothesis, exactly as `ArmSettlement` is; nothing here decides it in either direction. Register
   entry 24 states what is established (not refuted, not vacuous) and what is only measured.
2. **A kernel proof of the seed-run half of the non-vacuity witness.** Currently a
   `#guard_msgs`-checked measurement, because `expandBranchWithFuel` is compiled by well-founded
   recursion and does not reduce definitionally. A proof would mean transcribing an eleven-formula
   open exit and unfolding the equation lemma once per engine step.
3. **The fourteen remaining terminus restatements** (`_lengthBudget` / `signedUniverse`), each a
   one-line application of its family root with `hD` exchanged for `hL`.
4. **A run that exercises `buildTableauAt`'s post-blocking arm.** Across fourteen formula shapes,
   four frame classes and three fuel figures, the threaded tracker and the recomputed `armTracker`
   agreed everywhere, so the entry point never consulted the arm. That is a fact about the probe's
   reach, not about the residual.

Relocating to the pass's **input** branch remains closed and should not be tried:
`LabelFreeSaturatedExit` is false at `ob` by construction, since `buildTableauAt` runs the pass
precisely when its guard found outstanding work. Register entry 23 carries this.
