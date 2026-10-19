# Phase 11.1 Handoff — Half (i) of the Truth-Transport Layer Landed, Half (ii) Open

- **Dispatch**: seq 17, session `sess_1792395030_22ac66`
- **Plan**: specs/761_ladder_realization_theorem/plans/05_ladder-truth-transport-layer.md
  (the live plan; it landed MID-DISPATCH — `.plan-revised.json` carries `revised_at 1792402682`,
  later than this dispatch's `dispatch_start_ts 1792401662`, so the pre-write re-read obligation
  fired and this phase's work was re-derived from the fresh text)
- **Phase 11**: `[COMPLETED WITH EXCLUSIONS]` (set by the revision). **Phase 11.1**: `[PARTIAL]`.
  Phases 11.2, 11.3, 11.4 and 12-18 `[NOT STARTED]`.

## Immediate next action

**Half (ii), splice invariance** — `tpOf_stabFree_eq_of_splice`. Everything else Phase 11.1 asks
for is landed and verified. Half (ii) is the semantic heart of the pumping route and the plan
already declares it not costable.

What the next round should NOT do, and what it might do, both recorded below rather than left to
be rediscovered.

## What landed this dispatch

28 new compiled declarations in `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`
(74 in the module), no `sorry`, no axiom, no vacuous definition. The certificate-freedom grep,
extended with the five certificate-side periodicity identifiers the live plan adds, returns
NOTHING at all — not even a docstring occurrence — and the import list is unchanged.

**The bridge.** `isSlicedStepPath_iff_isLadderPath` (`Rlad` ignores its time argument, so an
offset step path at one offset is one at every offset), `exists_hist_of_isLadderPath` and
`exists_isLadderPath_of_hist` — both existential, because a world history carries an OFFSET a walk
does not: the second returns `(k, g)` with `σ.state t = (t + k, g t)`. `mem_cellAt_ladder_iff` is
the pair's payoff and is the agreement's own object in the replacement layer's language: the cell
of a ladder state is exactly what the ladder paths through it realize, with the offset forced to
`0` because a history through a world state whose time coordinate is `z` can carry no other.

**Half (i), object-trace locality.** `truthAt_iff_of_objAt_eq_of_stabPinned`: two ladder paths with
the SAME object walk satisfy the same closure formulas at every position, for every formula whose
`⊡` letters are pinned by the parameter `L`. One case per clause — `atom` reads the object walk,
`⊥`/`→` structural, `□` is `Iff.rfl` because both sides are literally the same proposition,
`U`/`S` are the induction hypothesis at the other positions, `⊡` is the pinned hypothesis. On types:
`tpOf_eq_of_objAt_eq_of_pinned`; stab-free instance: `tpOf_stabFree_eq_of_objAt_eq`. NON-VACUITY:
`exists_ladderPath_pair_nxtAt_ne` — at an idle object state with a self-loop the constant walk lifts
for EVERY register value, so two ladder paths share their whole object walk (hence by
`cntAt_eq_of_obj_eq` their whole countdown) and differ in `n` at every position.

**The measure and the pinned-letter shape.** `stabDepth` (`0` on `□`, whose clause is
path-independent), `StabPinned`, `stabDepth_stab`, `stabDepth_arg_le_of_le_succ`,
`stabDepth_le_sup` (bounded on a closure by a `φ`-determined quantity, so Phase 11.3's induction
terminates), `stabPinned_of_stabDepth_le` (the bridge Phase 11.3's step consumes),
`stabPinned_false_of_mem_closure` (the stab-free instance).

**The clause audit.** `box_mem_tpOf_transfer` (the `□` letters transfer under EVERY replacement
whatsoever; their bit names no path), `atom_mem_tpOf_ladder_iff` (the atomic letters read the
object walk at the position and nothing else — the ladder model's valuation ignores the time
coordinate and both counters), `atom_mem_tpOf_transfer_of_objAt_eq` (so they transfer whenever the
object at the position is unmoved, which `spliceObj_eq_of_le` supplies for the splice). Plus the
two temporal fixpoint readings on types the anchor layer does not land — `untl_mem_tpOf_iff`,
`snce_mem_tpOf_iff`.

**The index maps and the compiled obstruction.** `spliceIdx` with its two readings and
`spliceObj_eq_objAt_spliceIdx` (the spliced walk IS the original read along the retraction),
`spliceEmb` with `spliceEmb_monotone` and `spliceIdx_spliceEmb` (the retraction retracts a
monotone embedding, so a temporal witness of the ORIGINAL transports forward), and
`spliceIdx_seam_lt`.

Wiring: 28 axiom-profile pins in two new blocks of `KTypeSummaryAxiomTest.lean` (all matched), the
module docstring extended with a "truth-transport layer, half (i)" section and a "NO SPLICE
INVARIANCE" bullet, the three generated README inventory blocks and the two
`typst/generated/status.typ` line counts resynced. No C14 heredoc entry and no
`docs/theorem-index.md` row: the phase lands no Goal.

## Why half (ii) did not close — compiled, not asserted

A structural induction carrying ONE uniform claim at every position — "the spliced path's type at
`v` is the original's at `spliceIdx v`" — FAILS, and `spliceIdx_seam_lt` is the reason. The
retraction drops back by the block length at the seam, so at a position inside or adjacent to the
pumped block the claim IS the pumping claim, and the phase's `Tc ≤ |a - z|` hypothesis protects `z`
ALONE. The `untl` case is where it bites: a witness found in the second copy of the block retracts
to a position that need not be later than the position being evaluated, so
`untl_mem_tpOf_iff`'s right-hand side is not transported.

Worked through concretely: for `v < a` both directions of the `untl` transfer DO go through (the
retraction is surjective onto the relevant future in the right way, and the embedding is monotone).
For `v` in the first copy, `[a, a + l)`, the second copy lies in `v`'s future in the spliced path
and not in the original's, so the claim at `v` is the pumping claim itself.

What is needed instead is a **model-level periodicity of the TYPE sequence along a periodic object
segment** — the model-side analogue of the certificate graph's own periodicity, which this phase
may not cite (`prodPre_periodic`, `satThreshold`, `satPeriod`, `prodPreStep`, `cohIdle` are all
prohibited and all caught by the extended grep).

## Intelligence for the next round (observations, not claims — none of this is landed)

1. **A distance budget per nesting depth is available.** `untl ⊥ ψ` pins the immediate successor,
   so "next" is definable and a formula of `U`/`S`-nesting depth `d` distinguishes positions only
   up to distance `d` from a region's end. Positions far from both ends of a pumped region should
   therefore carry types determined by the local object pattern, which the splice makes periodic
   with the cycle length.
2. **The splice is monotone on future object-positions.** It only ADDS positions carrying objects
   already present, so a pure eventuality (`⊤ U p`) transports in both directions by monotonicity
   with no budget at all. A proof of half (ii) would combine (1) with (2): the bounded-reach part
   by the budget, the unbounded-reach part by monotonicity.

## Routes NOT to spend a dispatch on

- **Type equality at the seam by pigeonhole.** Inside a certificate-free module the only available
  source of `l ∣ P + 1` is `(K1)`'s `objCycleLens` conjunct, whose members satisfy
  `l ≤ Fintype.card Q`. A pigeonhole on (object, type) pairs needs a block up to
  `Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card` long, and `(K1)`'s other two divisors
  (`prodCycleLens`, `satPeriod`) are certificate-side objects — `ProdState Q φ` is `Q × ClType φ`
  and the relation is `cohIdle` — so citing them here is obstruction 2's own cycle.
- **A conditional half (ii) whose hypothesis is the hard part.** This repository's own standard
  (`paramsOk_params`' docstring) is that a hypothesis no one can discharge is indistinguishable
  from an unproved statement; a splice-invariance lemma taking type-preservation at the block
  interior as a hypothesis would be exactly that.

## A correction worth carrying

One splice raises the countdown by the cycle length `l`, and `kappa`'s residue coordinate is
`c % (P + 1)`. A single repetition therefore does NOT leave that coordinate fixed — `(P + 1) / l`
repetitions do. The earlier record's phrasing ("repeating that segment ... leaves the residue
coordinate of `kappa` unmoved") reads correctly only of the iterated surgery. The iteration
Phase 11.2's cascade sizes is needed for the RESIDUE as well as for the pins.

## Verification at closure

- Full guarded `lake build`: exit 0, 2892 jobs, 0 `error:` and 0 `warning:` across both captured
  streams; `.olean` newer than source for both touched modules. Test target
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: exit 0, 2361 jobs.
- `check-module-invariants.sh`: ALL CHECKS PASSED (exit 0), after `--emit-inventory` resynced three
  generated blocks. `typst-sync-check.sh`: PASS (all 4 checks), after the two line counts were
  resynced. `check-evidence-probes.sh`: exit 0, 44 of 44 wired probes PASS, no probe modified.
  `readme-lint.sh`: PASS. `check-task-references.sh`: 0 unexempted occurrences outside `specs/`.
- `lean-sorry-census.sh`: 0. Vacuous grep 1 and `^axiom ` 14, both verified unchanged against the
  dispatch's starting commit `ac90e6e90`.
- `#print axioms` on all 28 new declarations: `[propext, Classical.choice, Quot.sound]` or a strict
  subset; no `sorryAx`, no custom axiom, no `native_decide`.
- `git diff --stat` on `CounterQuotient.lean`: EMPTY. No parameter added, no parameter source
  strengthened, `ParamsOk` untouched.
- No positionwise clause, no finite-fibre and no finite-width hypothesis in the module; no
  trace-level `Presented` hypothesis; `Tc` not raised.

## Deviations

Four, all annotated inline on Phase 11.1's checklist items: half (ii) blocked, its
pending-forever instantiation not reached, the pinned-letter requirement satisfied for half (i)
only, and the bridge landed under existential names for the offset reason above. Two process
deviations beyond the checklist: the summary is numbered `05` rather than the dispatch's pinned
`04` (which is the preceding round's record, and the live plan names `05` itself), and
`LadderAgree.lean` is committed separately as a declared file_scope excursion — it is in the live
plan's Files-to-modify set for this phase but outside the task's declared `file_scope`, so
`git-commit-scoped.sh --task 761` drops it, exactly as it did in the preceding round.
