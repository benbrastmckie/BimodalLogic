# Implementation Summary: Discharge the `UniverseClosed` residual

- **Plan**: `specs/432_discharge_universeclosed_residual/plans/01_universeclosed-clause2-verdict-instantiation.md`
- **Phases**: 9 of 9 completed (Phase 7 was `[BLOCKED]` after dispatch 1 and was closed in dispatch 3, once task 434's time-coordinate lemma landed)
- **Files modified**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` (5191 -> 6443 lines in dispatch 1; dispatch 3 added section C11 and register entry 21, +322/-18, every deleted line a stale prose line and zero statement or proof-term lines touched)
- **Build**: full `lake build` green (2458 jobs at dispatch 3)
- **Zero-debt gate**: 0 sorries, 0 `native_decide`, 0 vacuous definitions, 0 new axioms; every new declaration's axiom set is exactly `{propext, Classical.choice, Quot.sound}`
- **Frozen files**: `Fuel.lean`, `Saturation.lean`, `Tableau.lean` md5-identical to this dispatch's baseline commit `88299bfb7` (their md5s differ from dispatch 1's record because tasks 433/434 landed in between; this dispatch changed none of them)

## Headline result

The residual `UniverseClosed fc U` has two conjuncts, and **both were refuted as stated** — the
second fatally, the first in one coordinate. This is the second residual on this terminus to come out
refutable-as-stated (the first was `DifficultyBounded`), and the outcome here is a genuine repair for
one conjunct and an honest reduction for the other.

| Conjunct | Verdict | Repair | Status |
|----------|---------|--------|--------|
| clause 2 (`identifyTime` closure) | **false at every nonempty `U`**; satisfiability set exactly `{∅}` | `UniverseClosedAt` — constrain the merge target `t₁` to `b.knownTimes` | **paid**: dischargeable at `signedUniverse C L` from `TimeMergeClosed L` |
| clause 1, formula coordinate | true | none needed | **paid**: proved outright, both unordered shapes |
| clause 1, label coordinate | **false at a fixed finite `signedUniverse C L`** | branch-side headroom rectangle `FreshLabelHeadroom`; provably *not* expressible as a condition on `L` | **residue, fully analysed**: reduced to the rectangle with both coordinates proved (`unorderedSuccessorLabelClosedOrd_of_headroom`), and the rectangle refuted at every nonempty finite `L` (`freshLabelHeadroom_not_universal`) |

## Landed

### The clause-2 refutation, and why it is fatal

- `universeClosed_identify_retime_false` — clause 2 (standalone) plus `U.Nonempty` gives `False`, at
  **every** `U` and with **no frame-class hypothesis**. The merge target `t₁` is universally
  quantified with nothing tying it to the branch, so instantiating at the singleton branch `[x]`
  forces `U` to contain a distinct retiming of `x` at every one of infinitely many times. Pigeonhole
  over `Finset.range (U.card + 1)`.
- `universeClosed_nonempty_false` — `U.Nonempty -> ¬ UniverseClosed fc U`.
- `universeClosed_identify_empty` — clause 2 *does* hold at `U = ∅`. With the above, this pins the
  satisfiability set to exactly `{∅}`: satisfiable only where the terminus has nothing to say.

### The repair, and the chain stated at it

- `UniverseClosedAt` — clause 1 verbatim; clause 2 with `t₁ ∈ b.knownTimes`. `t₂` deliberately left
  free.
- `universeClosedAt_of_universeClosed` — records the direction: the new hypothesis is *weaker*, so
  every theorem restated against it is a **strengthening**.
- `universeClosedAt_identify_at_trigger` — the freeness bridge. Both consuming sites reach `t₁`
  through `expandOnceUnblocked_splitOrdered_shape`, whose trigger spec `firstIncomparablePair_spec`
  already yields `t₁ ∈ b.knownTimes`, so **the restriction leaks no new hypothesis into the
  terminus**.
- Ten `…_at` siblings carrying the whole chain to four termini:
  `difficultyBounded_of_stepLengthBounded_at`, `difficultyBoundedAt_ceiling_at`,
  `budgetPotential_step_unordered_at`, `budgetPotential_step_splitOrdered_at`,
  `stepDecreases_budgetPotential_at`, `expandBranchWithFuel_isSome_of_budget_at`,
  `buildTableauAt_isSome_of_budget_at`, `buildTableauAt_isSome_at_seed_at`,
  `buildTableauAt_isSome_of_lengthBudget_at`, `buildTableauAt_isSome_at_seed_lengthBudget_at`.

### Clause 2 discharged at the concrete universe

- `TimeMergeClosed L` — one member's world against another's time stays in `L`.
- `timeMergeClosed_product` — every rectangle `Ws ×ˢ Ts` satisfies it (satisfiability witness).
- `timeMergeClosed_iff_product` — the rectangles are the **only** ones (characterization).
- `timeMergeClosed_identifyTime_signedUniverse` — the repaired clause 2 at `signedUniverse C L`. The
  condition is appealed to **exactly once**, at the retimed case.
- `timeMergeClosed_concrete`, `timeMergeClosed_concrete_nonempty` — a concrete nonempty instance, so
  nothing is vacuous.

### Clause 1: proved half, refuted half

- `unorderedSuccessor_formula_mem` — the **formula** coordinate, unconditionally, at both unordered
  shapes. Its missing half was `expandOnceUnblocked_split_mem`, the `.split` analogue of
  `Fuel.lean`'s `expandOnceUnblocked_extended_mem`; it needed no 36-arm case split because
  `RuleResult.emitted` already covers `.branching`.
- `universeClosed_fresh_world_escapes` — the **label** coordinate is false at `C = {□p, p}`,
  `L = {⟨0,0⟩}`, at **every** frame class and every tracker. Cause: `boxNeg` emits only at
  `Branch.nextWorld`, which is fresh.
- `universeClosedAt_fresh_world_escapes` — the clause-2 repair does **not** rescue clause 1.
- `applyRule_emitted_world_dichotomy` — the complete world-coordinate accounting: every emission is
  at a world of `b` or at `Branch.nextWorld`, no third case.
- `FreshWorldHeadroom` / `freshWorldHeadroom_not_universal` — the repair must be branch-side, and this
  is the **proof** (not the assertion) that no nonempty finite `L` supplies it. The asymmetry with
  clause 2 is real: identification moves a label *within* the existing coordinates; `boxNeg` moves it
  *past* them.
- `UnorderedSuccessorLabelClosed` — the label coordinate as a named residual, with a per-coordinate
  obligation map on its docstring.
- `unorderedSuccessor_confined_signedUniverse_of_headroom` — clause 1 at `signedUniverse C L`,
  reduced to the label coordinate **alone**.
- `unorderedSuccessorLabelClosed_not_universal` — the residual is a genuine condition: it **fails**
  at a concrete `L`, so the composite below is genuinely conditional rather than vacuous.

### The composite and the terminus

- `universeClosedAt_signedUniverse_of_headroom` — `UniverseClosedAt fc (signedUniverse C L)` from
  `TableauClosed C`, `TrichStock C`, `TimeMergeClosed L`, and the one named residual.
- `buildTableauAt_isSome_of_lengthBudget_signedUniverse` and
  `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` — the terminus with the closure residual
  paid at `signedUniverse C L`. Stated at the length-budget sibling because that is the live one
  (`DifficultyBounded` is refutable at every `D`).

### Register and infrastructure

- `formula_label_of_mem_signedUniverse` — the missing `mp` direction of `mem_signedUniverse`, landed
  in `MintBound.lean` because `Fuel.lean` is frozen.
- Register entries **10, 11, 12** (preamble updated "Nine" -> "Twelve"): clause 2's refutation and its
  repair; clause 1's label-coordinate refutation plus the impossibility of any `L`-side repair; and
  the tempting-but-wrong repair of clause 2 (constraining `t₂`, or both).
- Docstrings reconciled on `UniverseClosed`, `UniverseClosedAt`, and
  `difficultyBounded_of_stepLengthBounded`. The claim that `UniverseClosed` "is a statement about
  `L`" for `U = signedUniverse C L` is now corrected: true for clause 2's repaired form, **false** for
  clause 1's label coordinate.

## Named but NOT discharged

1. **`UnorderedSuccessorLabelClosed fc L`** — clause 1's label coordinate. This is the task's residue
   and it is carried explicitly, in the same idiom as `MintPaysForTime` and `PostBlockingSettles`.
   Blocked on a **time-coordinate analogue of `applyRule_emitted_world_mem`**: a 36-arm accounting
   bounding the times a rule emits at by `b.knownTimes`, with the time-minting rules separated out.
   That lemma does not exist anywhere in the development (its absence is named on `MintPaysForTime`'s
   own docstring), it belongs to the mint/time story rather than to universe closure, and the plan's
   Non-Goals explicitly assign it elsewhere and forbid authoring it here. The world coordinate is
   fully accounted for (`applyRule_emitted_world_dichotomy`); only the time coordinate is missing.

   A caution for whoever picks it up: the eight-rule `ruleMintsFreshLabel` list is **not** the list of
   time-introducing rules. `densityRule` interpolates a fresh time while being absent from it, and the
   active arms of `untlNeg`/`snceNeg` introduce times while being classified `ruleSelfGuarded`.

2. **The three unrelated residuals** on the terminus — `MintPaysForTime`, `PostBlockingSettles`,
   `β ≥ 3` — are carried across unaltered and are not touched by this task.

## Plan Deviations

1. **Phase 3, mechanism (altered).** The plan wrote the chain generalization as in-place changes to
   the ten `hUcl : UniverseClosed` signatures, with original shapes retained afterwards as
   corollaries. Done **additively** instead: the ten originals are byte-identical (statements *and*
   proof terms), and the chain at the repaired predicate is added under `…_at` names. Forced by the
   dispatch's non-negotiable additivity constraint, and it also serves the plan's own acceptance
   criterion ("every pre-existing theorem statement still resolves by name with the same statement")
   strictly better. Cost: the two ~65-line arithmetic step lemmas are restated rather than shared;
   the `C10` section preamble records this in the file's own "DIVERGENCE, recorded" style and names
   the refactor that would remove it.
2. **Phase 4, naming (cosmetic).** `identifyTime_confined_signedUniverse` landed as
   `timeMergeClosed_identifyTime_signedUniverse`, leading with the condition it consumes to match the
   file's existing convention. Same statement. The optional `timeMergeClosed_iff_product` closed
   inside budget and was **kept**, not dropped.
5. **Phase 5, route (altered, an improvement).** The plan expected a `decide`-based witness. `#eval`
   confirmed the configuration, but the landed proof follows the plan's own named fallback (a general
   argument from `applyRule_boxNeg_emitted_world` plus a pick-level bridge, in the `multWitness`
   template's style). The result is universally quantified in `fc` **and** `tr`, where a `decide`
   witness would have been pinned to one concrete frame class.
4. **Phase 5 refinement made during Phase 7 (strengthening).** `worldHeadroom_fixed_finite_false` was
   restated as `freshWorldHeadroom_not_universal`, quantifying headroom over `t ∈ b.knownTimes` rather
   than all `t : TimeIndex` — a stronger theorem, and it makes the named `FreshWorldHeadroom`
   condition load-bearing rather than decorative.
5. **Phase 7, bullet 4 (altered — delivered in two forms across two dispatches).** Dispatch 1
   delivered the partial form only: clause 1 at `signedUniverse C L` reduced to the label coordinate
   alone (`unorderedSuccessor_confined_signedUniverse_of_headroom`), **not** proved from
   `FreshWorldHeadroom`, because the time-coordinate lemma did not exist; the plan's branch (b)
   instruction was followed literally (stop, record the dependency, mark `[BLOCKED]`, do not author
   the analogue). Dispatch 3 delivered the complete form
   (`unorderedSuccessor_confined_signedUniverse_of_freshLabelHeadroom`) with no residual, once task
   434's `applyRule_emitted_time_dichotomy` landed. Two further alterations inside this bullet: the
   headroom hypothesis is the rectangle `FreshLabelHeadroom`, not `FreshWorldHeadroom` (a label is a
   pair, so the two per-coordinate dichotomies leave four quadrants and `FreshWorldHeadroom` is one
   of them); and both forms are retained side by side, since the landed terminus chain consumes the
   original.
6. **Phase 8, statement shape (altered, pre-declared).** The plan named the composite
   `universeClosedAt_signedUniverse` (unconditional). It landed as
   `universeClosedAt_signedUniverse_of_headroom`, carrying the named residual, because Phase 7 is
   blocked. The plan pre-declared this outcome in its Risks table and in branch (b); the `_of_headroom`
   suffix makes the conditionality visible at the call site rather than buried in a hypothesis list.


---

## Dispatch 3 addendum: Phase 7 closed

Phase 7's blocker named one missing dependency — *a time-coordinate analogue of
`applyRule_emitted_world_mem`: a 36-arm accounting over `applyRule` bounding the times a rule emits
at by `b.knownTimes`, with the time-minting rules separated out* — and assigned it to another task.
Task 434 landed it as `applyRule_emitted_time_dichotomy` (`MintBound.lean` section D1), together with
the engine-level lift `unorderedSuccessor_time_dichotomy` that the blocker had not asked for. It fits
the specification: the proof is a `by_cases` on the two `Bool` census predicates resolving every
emission of every rule to `g.label.time ∈ b.knownTimes ∨ g.label.time = b.nextTime`. The blocker's
own caution — that `ruleMintsFreshLabel` is the wrong census for time-minting — is now decided by
434's `freshTimeRules_incomparable_freshLabelRules`.

### Landed in section C11

| Declaration | Role |
|-------------|------|
| `unorderedSuccessor_world_dichotomy` | the world coordinate's engine-level lift, which did not exist; mirrors 434's construction through `pick_branches_eq` / `pick_stage_source` / `resultBranch_sub`, and carries no auxiliary hypothesis where its time twin carries `OrdTimesKnown b ord` |
| `FreshLabelHeadroom` | the branch-side **rectangle** the two dichotomies actually license: four quadrants, not one |
| `freshWorldHeadroom_of_freshLabelHeadroom` | the rectangle is the strictly stronger of the two headroom conditions |
| `unorderedSuccessor_label_mem_of_headroom` | **clause 1's label dimension, proved** — both coordinates, no residual, from the rectangle alone |
| `unorderedSuccessor_confined_signedUniverse_of_freshLabelHeadroom` | clause 1 at `signedUniverse C L`, both dimensions, nothing residual left standing |
| `UnorderedSuccessorLabelClosedOrd` + `..._of_unorderedSuccessorLabelClosed` | the residual with the ordering hypothesis the time dichotomy needs, and the direction lemma |
| `unorderedSuccessorLabelClosedOrd_of_headroom` | **the reduction**: the residual follows from the rectangle holding at every `L`-confined branch |
| `freshLabelHeadroom_not_universal` | **and the reduction is not a discharge**: the rectangle is refutable at every nonempty finite `L` |
| `unorderedSuccessorLabelClosedOrd_not_universal` | adding `OrdTimesKnown` does not weaken the residual into vacuity |

### The finding

**The reduction is complete and the residual survives it.** The obstruction to clause 1's label
dimension was always the world coordinate's refutation (`universeClosed_fresh_world_escapes`,
`freshWorldHeadroom_not_universal`) and never the absent time lemma. Supplying the time lemma
completed the *accounting*, which is what made the reduction statable; it could not and did not
discharge anything, because `freshLabelHeadroom_not_universal` refutes the reduced antecedent at
every nonempty finite `L` by transporting Phase 5's `maxWorld` argument through the quadrant
implication in one line.

A second, structural finding the blocker did not anticipate: **a label is a pair, and confinement of
`b` is not a rectangle**. `∀ x ∈ b, x.label ∈ L` constrains the pairs `b` carries, not their cross
product, so `⟨w, t⟩` for a `w` and a `t` that `b` carries on *different* formulas need not be in `L`.
The two per-coordinate dichotomies therefore leave four quadrants and confinement covers none of
them. `FreshWorldHeadroom` — the condition the blocker named — is one quadrant of the four, so the
blocker's phrasing "prove clause 1's label dimension from `FreshWorldHeadroom`" was in that one
respect asking for something false. This is the same rectangle shape `timeMergeClosed_iff_product`
found on the clause-2 side, reached from the opposite direction.

### Prose corrections (no statement or proof term altered)

Four places in `MintBound.lean` said the label coordinate was waiting on a lemma, which stopped being
true when 434's section D1 landed. All four were corrected: the C10 section heading and note,
`UnorderedSuccessorLabelClosed`'s obligation map, `universeClosedAt_signedUniverse_of_headroom`'s
docstring, and the terminus corollary's residual list. Register entry 11 gained a pointer to the new
material and **entry 21** was added as the verdict; the register preamble now reads twenty-one.

### Phases 8 and 9 checked, and correctly left as they are

`universeClosedAt_signedUniverse_of_headroom` and
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` still carry
`UnorderedSuccessorLabelClosed fc L`, and that is correct rather than stale: the residual is not
discharged, so removing it would be unsound. What was stale was only their prose account of *why*,
and that is what the corrections above fix.

### One item left for task 434

`MintBound.lean` section D1's own heading note (at `applyRule_emitted_time_mem`) opens *"Three
docstrings in this file say the same thing … there is no `applyRule_emitted_time_mem`"*. One of those
three — `UnorderedSuccessorLabelClosed`'s obligation map — no longer says it, having been corrected
here. That sentence is inside 434's territory and was deliberately not edited from this dispatch.
