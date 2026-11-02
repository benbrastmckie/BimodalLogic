# Phase 11.5 Handoff — The Cell-Level Route's CONSTRUCTION REFUTED; the Obligation Stated, Not Refuted

- **Dispatch**: seq 24, session `sess_1793651515_3f23fb`
- **Plan**: specs/761_ladder_realization_theorem/plans/07_cell-level-agreement-route.md
- **Pre-write re-read obligation**: FIRED and found NO fresh revision. `.plan-revised.json` carries
  `revised_at 1793651289`, EARLIER than this dispatch's `dispatch_start_ts 1793654557`, so the
  dispatch file's Phase 11.5 excerpt is current; Phase 11.5's own section was re-read in full
  before the first edit and is unchanged.
- **Phase 11.5**: `[BLOCKED]`, on the refuting branch its own task 3 provides for. Phase counts:
  14 of 25 closed (11 `[COMPLETED]`, 3 `[COMPLETED WITH EXCLUSIONS]`), 1 `[BLOCKED]`, 10
  `[NOT STARTED]`.

## Immediate next action

**Not Phase 11.6.** Phase 11.6 (`Depends on`: 11.5) consumes Phase 11.5's depth-`0` cell agreement
as the base case of a `⊡`-depth induction, and that base case is NOT landed — only STATED, as the
schema `CellLEZeroConstOfKappaEq`. Entering 11.6 would mean inducting from nothing.

Three options, in the order their cost is known:

1. **Phase 11.2** (`The Pin Cascade`) is independently enterable, `[NOT STARTED]`, and waits on
   nothing: its single consumer is Phase 15 and nothing in 11.5-11.7 touches it. It is the only
   unblocked phase on the board.
2. **A successor task for the open construction**: identify a construction that preserves the
   realized TYPE without preserving the valuation pointwise. This is the thing route B lacks, and
   the inputs are now sharp (below). Nothing in the tree states such a construction.
3. **`/revise`** the route itself, with the refutation of route B's construction as the new input.

## What landed this dispatch

Eight declarations in `LadderAgree.lean`, all eight axiom-pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, plus the forty-sixth wired probe.

**The sharpening that did the work.** `cntAt_eq_of_pend_eq`: the countdown is a function of the
PEND PROFILE alone. This is the proof of the already-landed `cntAt_eq_of_obj_eq` at the hypothesis
that proof actually consumes — it reads `hobj` only through `pend` — so it cost one lemma and
`cntAt_eq_of_obj_eq` is byte-identical. The consequence for route B is immediate and was not on the
record: `altWalkPath` relabels the walk at a FIXED pend profile, so by this lemma EVERY alternative
history carries the original countdown at every position, and no amount of relabelling reaches a
ladder state whose counter differs.

**The condition, and why it is not exotic.** `PendFactorsLab pend lab` — two object states with the
same atom row carry the same pending bit. `pendFactorsLab_of_atom`: it holds as soon as the
labelling carries the pending bit as one of its atoms. The realization statement quantifies over
every `lab : Q → Atom → Bool`, so no such labelling is excluded by anything, and no parameter
condition can exclude one (`ParamsOk` constrains the four parameters, not the labelling).

**The incompatibility, in the library.** `cntAt_eq_of_lab_eq_of_pendFactorsLab`: under that
condition two ladder paths with the same atom row at every position carry the same countdown at
every position. So the freedom Phase 11.4's agreement buys over half (i) — which is real,
`altWalkPath_not_vacuous` — is freedom in the OBJECT STATE at a position, never in the counter.

**The construction, and its refutation.** `AtomPreservingCountMove` is the construction task 2
names, landed as a schema so its refutation is a theorem about a named object:
`atomPreservingCountMove_refuted` kills it at every ladder path and every admissible target
countdown differing from the path's own.

**The obligation, stated and not proved.** `CellLEZeroConstOfKappaEq`: under `ParamsOk`, for a
`kappa`-collision between two admissible counter pairs at the same object state and a closure
carrying no `⊡` letter, the two cells are EQUAL. A Prop-valued schema, on the precedent of
`LadderCons`/`certChain` and `SpliceTypeInvariance`; the theorem name
`cellLE_zero_const_of_kappa_eq` is reserved and claimed by nothing. Its docstring records which of
the route's inputs it commits to: (d) and `ParamsOk`, plus (b)'s stab-free fragment; NOT (a) and
NOT (c).

**The hypothesis is never empty.** `kappa_eq_of_shift`: shifting BOTH counters by a common multiple
of `P + 1` leaves all five `kappa` coordinates alone once both are at or above their thresholds —
the two clipped coordinates pinned, the two residues unmoved by a multiple of the modulus, the gap
unmoved by a common shift. So `kappa`-collisions with `c ≠ c'` exist at every parameter tuple
whatsoever.

**The probe** (`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`,
`Probe761C`, forty-sixth wired): two states (one pending, one idle), step complete, the pending bit
carried as the atom `p`; seriality DISCHARGED (`fwdC`, `bwdC`); the walk pending at every PAST
position — the forward-only liveness regime — which leaves the next-deadline register free of every
pin and so isolates the `c` coordinate. `exists_refuting_collision` carries the whole finding in one
statement: `ParamsOk` at the periodicity fixpoint's own outputs, a populated collision at `c ≠ c'`,
a ladder path through EACH of the two ladder states, and the construction refuted. `nxt_free`
compiles that the `n` HALF of the construction CLOSES, so the obstruction is confined to `c` by
construction rather than by silence; `mem_cell_of_gC` puts a realized type carrying the closure's
atom in each of the two cells.

## What this does and does NOT give — said sharply so no later round over-reads it

GIVES: route B's named construction is DEAD, generally, with the mechanism compiled rather than
observed. Any successor construction must either move the pend profile while changing an atom row
(and then Phase 11.4's transport does not apply) or preserve the atom row (and then the countdown
cannot move). That is a genuine fork, and it is now a theorem.

DOES NOT GIVE: a refutation of `CellLEZeroConstOfKappaEq`. This distinction is load-bearing and is
not a hedge. A cell is a set of TYPES over all histories through a state; two ladder paths can
realize the same closure type without agreeing on a single atom row; the probe exhibits a ladder
path through each of the two states and says NOTHING about whether the two cells coincide. The
obligation is therefore open in a specific way: what is missing is a construction that preserves
the realized TYPE without preserving the valuation pointwise, and no such construction is stated
anywhere in the tree. Nothing here settles the filed `cellAt_const_of_kappa_eq`, `ladderSound`,
`ladderLift` or `ladderRealized`; the PRESENTATION is untouched; half (i) and the atom-valuation
agreement are untouched and both still hold at their own hypotheses; half (ii) stays refuted rather
than reopened. No bound; every quantity named is a count.

## Deviations

Two, both annotated inline on Phase 11.5's own checklist items, and both recorded in the plan's
BLOCKER block rather than smuggled past it.

1. **Task 1's deliverable is a SCHEMA, not a theorem.** The task says "State
   `cellLE_zero_const_of_kappa_eq`"; task 4 says "If the construction closes: PROVE
   `cellLE_zero_const_of_kappa_eq`". The two tasks split stating from proving, and a `sorry`-free
   tree admits no stated-but-unproved theorem, so the only way to discharge task 1 without
   discharging task 4 is a Prop-valued definition carrying the statement — the same shape
   `LadderCons`/`certChain` use in `LadderRealize.lean` and `SpliceTypeInvariance` uses in
   `Probe761S`. The theorem name is reserved and claimed by nothing, so a successor that proves it
   lands it under the plan's own name.
2. **Task 4 is NOT APPLICABLE**, its guard being false: the construction does not close. Nothing is
   proved under it and the `hp`-is-used check belongs to the proof this phase does not land.

Two file-scope additions the task list did not anticipate, both continuing the in-repo pattern:
`set_option linter.style.longFile 2400` in `LadderAgree.lean` (2252 lines, past the 2100 the prior
phase set) and `1800` in `KTypeSummaryAxiomTest.lean` (1609 lines, past the 1700 the prior phase
set). `check-module-invariants.sh --emit-inventory` rewrote THREE generated README inventory
blocks, not the one the Files-to-modify list names — the same behaviour the two prior phases
recorded.

## Verification at closure

- Guarded scoped build of `LadderAgree.lean`: exit 0, 1966 jobs, 0 `error:` and 0 `warning:` — on
  the FIRST attempt, no proof-repair round. Guarded scoped build of
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: exit 0, 0 `error:` and 0 `warning:`; all eight
  `#guard_msgs` pins matched on the first attempt.
- Guarded FULL-project build, detached as a shell-level background job with the bounded
  single-call waiter (captured `pid`, `kill -0` liveness loop, outer `timeout`, un-piped `wait`):
  guard exit 0, 2892 jobs, 0 `error:` and 0 `warning:`; `.olean` newer than source for both touched
  modules. All three verdict tiers green.
- The probe compiles under `lake env lean` with 0 `error:` and 0 `warning:`.
  `check-evidence-probes.sh`: PASS, all 46 wired probes compile (45 before this phase).
- `#print axioms` on all eight new library declarations: `PendFactorsLab`,
  `pendFactorsLab_of_atom` and `AtomPreservingCountMove` on NO axioms; `cntAt_eq_of_pend_eq`,
  `cntAt_eq_of_lab_eq_of_pendFactorsLab`, `atomPreservingCountMove_refuted` and
  `kappa_eq_of_shift` on `[propext, Quot.sound]`; `CellLEZeroConstOfKappaEq` on
  `[propext, Classical.choice, Quot.sound]`. On the probe's seventeen printed theorems:
  `[propext]`, `[propext, Quot.sound]` or the standard profile. No `sorryAx`, no custom axiom, no
  `native_decide` anywhere.
- The landed obligation is an equality of CELLS, not of two paths' types — checked by reading
  `CellLEZeroConstOfKappaEq`'s signature: both sides are `cellAt (ladderModel …) φ (z, ⟨(q, _, _), _⟩) z`.
- Certificate-freedom grep on `LadderAgree.lean` (`certAdmK|certStabK|certBoxK|certBiInfK|certLocK|
  certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|
  satThreshold|satPeriod`): ZERO occurrences. Import list UNCHANGED (`git diff` shows no `import`
  line added or removed), and the only certificate module imported is `CounterQuotient`.
- `git diff --stat` on `CounterQuotient.lean`: EMPTY. No parameter added, no parameter source
  strengthened, `ParamsOk` untouched. `git diff` on `LadderAgree.lean` shows no `-` line on ANY
  declaration: `exists_spliced_ladderPath`, `pinCompat_of_ladderPath`, `cntAt_eq_of_obj_eq` and
  half (i)'s three statements are all byte-identical. `ladder-splice-type-refutation.lean` and
  `ladder-unconstrained-parameter-refutation.lean` are unmodified (`git diff --stat` EMPTY) and
  still PASS.
- No declaration anywhere in the resolved source roots matches `tpOf_[A-Za-z_]*_of_splice`, and no
  positionwise narrowing, raised `Tc`, trace-level `Presented`, finite-fibre or finite-width
  hypothesis appears in anything landed.
- `lean-sorry-census.sh` over the resolved source roots: `sorry_count: 0`, empty inventory.
  Module-scoped vacuous grep 0 (library module and probe). Repository-wide vacuous grep 1 and
  `grep -rn '^axiom '` 14, both IDENTICAL to the Phase 11.4 close.
- `check-module-invariants.sh`: ALL CHECKS PASSED, exit 0. `readme-lint.sh`: PASS, exit 0.
  `typst-sync-check.sh`: PASS, all 4 checks green after `typst-status-counts.sh` resynced the
  counts. `check-task-references.sh`: PASS, 0 unexempted occurrences, exit 0.

## Landed count against the Scope Hypothesis

The Scope Hypothesis declined to predict a count, "because the construction itself is not yet
identified", and asked for a measurement at close. The measurement: EIGHT library declarations
(four for the rigidity, two for the construction and its refutation, two for the obligation and its
non-empty hypothesis), one probe of seventeen printed theorems, and the refuting branch's two extra
wiring targets. The module grew by 257 lines, the axiom ledger by 66. The predicted file set held
exactly — one module plus three wiring files on the closing branch, plus the probe and the
`check-evidence-probes.sh` row on the refuting branch — with the caveat that the invariants script
rewrites three README files rather than one.
