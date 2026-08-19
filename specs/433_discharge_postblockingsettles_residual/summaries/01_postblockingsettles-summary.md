# Implementation Summary: Discharge the `PostBlockingSettles` residual

- **Task**: 433
- **Plan**: `specs/433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md`
- **Outcome**: `[PARTIAL]` — outcome (b), with the repair branch closed by proof rather than by a
  failure to find one
- **Phases**: 8 of 8 closed (5 `[COMPLETED]`, 3 `[COMPLETED WITH EXCLUSIONS]`)
- **Files modified**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`
  (686 insertions, 4 deletions; all four deletions are docstring text)

## The verdict

`PostBlockingSettles fc` is **false**, at every frame class, and **fuel does not close it** — which
answers the open question the residual's own docstring posed and which
`Saturation.lean` leaves open. The docstring is corrected in place; the `def` is byte-unchanged.

The minimal repaired predicate was landed with its direction lemma, and the anti-weakening gate then
rejected it on decided evidence. The sharper closure is that the repair's second antecedent is,
given its first, *equivalent to its conclusion* — so `PostBlockingSettlesAt` is a theorem, not a
repair, and it is recorded as such rather than presented as a discharge. No terminus was restated;
there was nothing admissible to restate against.

What the task does deliver positively is the **location** of the residual: it is a fuel-adequacy
fact about the post-blocking pass plus a label-minting fact about the branch that pass reaches, and
neither is a settlement question. The one branch-independent sufficient condition that survives the
equivalence (`LabelFreeUniverseAt`) is landed with its discharge lemma, and a concrete, pass-produced
non-vacuous instantiation is decided at every frame class.

## Phase-by-phase

| Phase | Marker | Verdict |
|-------|--------|---------|
| 1. Gate 1 — fuel-zero | `[COMPLETED]` | TRUE: literal predicate refuted at the `fuel = 0` arm |
| 2. Gate 2 — does fuel close the gap? | `[COMPLETED]` | TRUE: fuel does **not** close it, at every fuel figure |
| 3. Repaired predicate + direction-lemma gate | `[COMPLETED WITH EXCLUSIONS]` | FALSE: repair not admissible; both bridges excluded |
| 4. Settlement lemma | `[COMPLETED]` | Outcome (a): `PostBlockingSettlesAt fc` proved outright |
| 5. Concrete discharge + non-vacuity | `[COMPLETED]` | TRUE on the letter, with the equivalence caveat recorded |
| 6. Restate the termini | `[COMPLETED WITH EXCLUSIONS]` | Excluded by Phase 3's FALSE verdict |
| 7. C9 entries, verdict record, repo gate | `[COMPLETED]` | Entries 22 and 23 added; `lake build` green |
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

**The record** — C9 register entries 22 and 23; the register header count corrected from
"Twenty-one" to "Twenty-three"; the `PostBlockingSettles` docstring's open-question paragraph
corrected in place.

## Verification

- `lake build` green across the whole repository (2458 jobs, exit 0).
- Zero `sorry` in `MintBound.lean`, before and after. Every repo-wide occurrence is pre-existing and
  in `FormalSystem/Boneyard/`.
- Repo-wide `^axiom ` count unchanged at 7.
- All 29 new theorems checked with `#print axioms`: axioms within
  `{propext, Classical.choice, Quot.sound}`.
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
- **Phase 6, all four restatement items** — *skipped*. Excluded by Phase 3's FALSE verdict; recorded
  in the phase's Reasoned Exclusions.
- **Phase 8** — *skipped*. Entry condition not met (Phase 2 returned TRUE).
- **Testing & Validation, the bridge item** — *not satisfiable*. No predicate was landed for the
  bridges to compile against; the landed bridges are unchanged and still consume
  `PostBlockingSettles`.

## Open follow-on, named and deliberately unattempted

Restrict the residual's quantification from "every `(ob, oOrd, fuel)`" to the pair the terminus's own
run produces — the branch `expandBranchWithFuel` hands to `saturateBlocked` at the seed, at the
terminus's own fuel figure. `freshWorldBranch` does not refute that form. Relocating instead to the
pass's **input** branch does not work and should not be tried: `LabelFreeSaturatedExit` is false
there by construction, since `buildTableauAt` runs the pass precisely when its guard found
outstanding work. Register entry 23 carries this.
