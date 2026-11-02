# Phase 11.4 Handoff — The Atom-Valuation Closure Agreement LANDED, with the Box Arm WIDENED

- **Dispatch**: seq 23, session `sess_1793651515_3f23fb`
- **Plan**: specs/761_ladder_realization_theorem/plans/07_cell-level-agreement-route.md
- **Pre-write re-read obligation**: FIRED and found NO fresh revision. `.plan-revised.json` carries
  `revised_at 1793651289`, EARLIER than this dispatch's `dispatch_start_ts 1793653071`, so the
  dispatch file's Phase 11.4 excerpt is current; Phase 11.4's own section was re-read in full
  before the first edit and is unchanged.
- **Phase 11.4**: `[COMPLETED]`. Phase 11.2 remains `[NOT STARTED]` (off the critical path by this
  plan's own re-sequencing — its single consumer is Phase 15); Phases 11.5-11.7 and 12-18 remain
  `[NOT STARTED]`.

## Immediate next action

**Phase 11.5, the stab-free cell agreement on `kappa`-classes** (`Depends on`: 11.4, now
discharged). Read the widening result below BEFORE re-deriving Phase 11.5's fragment: the fragment
it consumes is STAB-FREE with `□` INCLUDED, not stab-free-and-box-free. The consumable statements
are `tpOf_stabFree_eq_of_lab_eq` (type level, box included) and
`truthAt_iff_of_lab_eq_of_stabPinned` (truth level, at the pinned-letter parameter, which is what
Phase 11.6's `⊡`-depth induction steps by), both in
`FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`.

Phase 11.2 is independently enterable at any time and nothing in 11.5-11.7 waits on it.

## What landed this dispatch

Seven declarations in `LadderAgree.lean`, all seven axiom-pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`.

**The hypothesis, and why it is not half (i) under a new name.** Half (i) transports a realized
type between two ladder paths with the SAME OBJECT WALK. What the ladder model's valuation actually
reads at a position is `lab` of the object component there and nothing else
(`atom_mem_tpOf_ladder_iff`), so every new declaration takes

  `hlab : ∀ (v : ℤ) (p : Atom), lab (objAt g v) p = lab (objAt g' v) p`

and is weaker than half (i) by exactly the non-injectivity of `lab`. No new signature anywhere
carries `objAt g v = objAt g' v` (checked by grep over the new layer). Half (i)'s three statements
are byte-identical — `git diff` touches none of
`truthAt_iff_of_objAt_eq_of_stabPinned`, `tpOf_eq_of_objAt_eq_of_pinned`,
`tpOf_stabFree_eq_of_objAt_eq`; the only `+` line naming any of them is a docstring citation.

**The fragment: the NEW-PREDICATE option, and why.** `StabBoxFree` — `False` on `⊡` and on `□`,
structural elsewhere, with NO pinned-letter parameter. The recorded reason: the narrow fragment
asks nothing of the letter inside a `□`, it excludes the letter outright, so a parameter over `□`
letters would carry no information; tightening `StabPinned`'s `box` arm would have meant
re-threading a parameter that the narrow reading never consults.
`stabBoxFree_of_mem_closure` restricts it to `plusSubformulaClosure φ` through the landed
`plusClosure_{imp,untl,snce}_{left,right}` projections. No new closure lemma was authored.

**The narrow transport**: `truthAt_iff_of_lab_eq_of_stabBoxFree` by induction on the formula, one
case per clause — `atom` the hypothesis read through the ladder model's valuation, `⊥` and `→`
structural, `U`/`S` the induction hypothesis at the other positions of the same history, `□` and
`⊡` excluded by the fragment. `tpOf_stabBoxFree_eq_of_lab_eq` is its reading on closure types.

**THE BOX ARM WIDENS — the open question of the phase, answered AFFIRMATIVELY and compiled.**
`box_mem_tpOf_transfer`'s only hypothesis beyond closure membership is that both points lie in the
SAME model; the two compared histories here are both histories of
`ladderModel step pend fwd bwd lab`, so no hypothesis of it fails. The `box` case of the widened
induction is literally `Iff.rfl`. Landed: `truthAt_iff_of_lab_eq_of_stabPinned` (the widened truth
level, stated at the pinned-letter parameter so that an induction on `⊡`-nesting depth can consume
it — the stab-free statement is the one shape such an induction cannot use) and
`tpOf_stabFree_eq_of_lab_eq` (the widened type-level corollary, `L := fun _ => False`).
**Consequence for the route**: Phase 11.5's fragment is STAB-FREE, strictly wider than the route
decision assumed, and the box-free restriction can be dropped from every downstream statement.

**The instance over the alternative-history construction.**
`tpOf_eq_of_altWalkPath_of_lab_eq`: a pend-profile-preserving relabelling that leaves every ATOM
ROW alone realizes the SAME stab-free closure type as the original at every position. The
prototype's compiled `alt_atoms_eq_spliced_atoms` — one atom, one fixture — becomes an instance of
this statement's HYPOTHESIS rather than a statement of its own.

## What this does and does NOT give — said sharply so no later round over-reads it

GIVES: a type transport across a change of the object WALK, which half (i) cannot do, in the one
case where the change is invisible to the valuation. The relabelling may move the object state at a
position (`altWalkPath_not_vacuous`); the transport holds whenever it does not move that state's
atom row.

DOES NOT GIVE: any transport across a change of the realized valuation, and nothing about `⊡`
letters beyond carrying them as a hypothesis. It is NOT a repair of half (ii), which stays refuted
rather than open: the refuted statement is about the SPLICE, which lengthens a pending region and
changes which positions exist, and no hypothesis here constrains such a surgery. It is not a
conditional, positionwise-narrowed or raised-`Tc` restatement of it. No statement here mentions
`kappa`, a counter class, or a cell's constancy on one, so it proves nothing about
`cellAt_const_of_kappa_eq`, `ladderSound`, `ladderLift` or `ladderRealized`. No bound; every
quantity named is a count.

## Deviations

One, annotated inline on Phase 11.4's own checklist item.

1. **`untl`/`snce` routing ALTERED.** Task 3 names two directives in tension: route the temporal
   cases "through the landed fixpoint readings `untl_mem_tpOf_iff` and `snce_mem_tpOf_iff`" AND
   "cite `truthAt_iff_of_objAt_eq_of_stabPinned` as the model for the induction's shape". The
   theorem is a statement about `PlusTruthAt`, so a `tpOf`-level `iff` is not applicable inside its
   induction; and the named model's own proof uses the TRUTH-level clause lemmas
   `PlusTruth.untl_iff`/`PlusTruth.snce_iff`, which is what `untl_mem_tpOf_iff` is itself built
   from (`rw [mem_tpOf_iff, PlusTruth.untl_iff]`). Routed through the truth-level pair. No named
   declaration is skipped, no signature is weakened, and half (i) is neither re-proved nor altered.
   Recorded in `issues.jsonl` as a `plan-fidelity` issue at severity `minor` so it is re-openable.

Two file-scope additions the task list did not anticipate, both with explanatory comments and both
following the in-repo pattern the module already used: `set_option linter.style.longFile 2100` in
`LadderAgree.lean` (1995 lines, past the 1800 the prior phase set) and `set_option
linter.style.longFile 1700` in `KTypeSummaryAxiomTest.lean` (1539 lines, past the package-wide
1500). `check-module-invariants.sh --emit-inventory` rewrote THREE generated README inventory
blocks, not the one the Files-to-modify list names — the same behaviour the prior phase recorded.

## Verification at closure

- Guarded scoped build of `LadderAgree.lean`: exit 0, 1966 jobs, 0 `error:` and 0 `warning:` — on
  the FIRST attempt, no proof-repair round. Guarded scoped build of
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: exit 0, 2361 jobs, 0 `error:` and 0 `warning:`.
- Guarded FULL-project build, detached as a shell-level background job with the bounded
  single-call waiter (captured `pid`, `kill -0` liveness loop, outer `timeout`, un-piped
  `wait`): guard exit 0, 2892 jobs, 0 `error:` and 0 `warning:`; `.olean` newer than source for
  both touched modules. All three verdict tiers green.
- `#print axioms` on all seven new declarations: `StabBoxFree` on NO axioms; the other six on
  `[propext, Classical.choice, Quot.sound]`. No `sorryAx`, no custom axiom, no `native_decide`.
- Certificate-freedom grep on `LadderAgree.lean` (`certAdmK|certStabK|certBoxK|certBiInfK|
  certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|
  cohIdle|satThreshold|satPeriod`): ZERO occurrences. Import list UNCHANGED (`git diff` shows no
  `import` line added or removed).
- `git diff --stat` on `CounterQuotient.lean`: EMPTY. No parameter added, no parameter source
  strengthened, `ParamsOk` untouched.
- No declaration named `tpOf_stabFree_eq_of_splice` and no `tpOf_*_of_splice` declaration anywhere
  in the resolved source roots; the three `tpOf`/`splice` co-occurrences are docstring sentences
  recording the refutation.
- `lean-sorry-census.sh` over the resolved source roots: `sorry_count: 0`, empty inventory.
  Module-scoped vacuous grep 0. Repository-wide vacuous grep 1 and `grep -rn '^axiom '` 14, both
  IDENTICAL to the dispatch's starting commit `86116550c` (compared against a `git archive` of it).
- `check-module-invariants.sh`: exit 0. `readme-lint.sh`: exit 0. `typst-sync-check.sh`: PASS, all
  4 checks green after `typst-status-counts.sh` resynced the counts. `check-evidence-probes.sh`:
  exit 0. `check-task-references.sh`: exit 0.
- No `sorry`, axiom, vacuous definition, trace-level `Presented` hypothesis, finite-fibre or
  finite-width retreat, positionwise narrowing, raised `Tc`, or conditional restatement of the
  refuted half (ii) anywhere in the tree.

## Landed count against the Scope Hypothesis

The Scope Hypothesis predicted "roughly one fragment predicate, one transport theorem, one
type-level corollary, one instance and at most one widened corollary — five declarations, to be
confirmed by the landed count at phase close rather than trusted from here." The landed count is
SEVEN: the five predicted, plus `stabBoxFree_of_mem_closure` (the closure restriction task 2 asks
for in the same breath as the predicate) and `truthAt_iff_of_lab_eq_of_stabPinned` (the widened
corollary's truth-level companion — the type-level widened corollary cannot be stated without it,
and the pinned-letter parameter is what Phase 11.6 steps by). The module grew by 295 lines. The
prediction of "one module plus three wiring files" held, with the caveat that the invariants script
rewrites three README files rather than one.
