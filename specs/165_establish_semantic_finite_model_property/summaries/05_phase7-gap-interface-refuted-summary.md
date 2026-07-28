# Phase 7.1, fifth dispatch — the gap interface is refuted, and `sat_imp_pos` lands

**Status**: Phase 7 remains `[PARTIAL]`. `phases_completed` stays at 6 of 8.
- **Task**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
**Builds**: `lake build FormalSystem.Metalogic.Decidability` (1110 jobs, green);
`lake build BimodalTest` (1962 jobs, green, all `#guard_msgs` rows pass).
**Sorry census** over `FormalSystem/Metalogic/Decidability/Verified/`: `0`. Vacuous
definitions: `0`. New axioms: `0`. Every new theorem verifies on
`propext` / `Classical.choice` / `Quot.sound` only.
**Engine files**: untouched.

## What this dispatch was asked to do, and why it did something else

The dispatch order was: write `not_valid_of_hasOpen` consuming O1, O2, O3 — all three
reported discharged by the previous handoff — then 7.2, then 7.3. The first step of writing
that induction is its `box` case, and the `box` case does not close. The reason is not a
missing lemma: **O2's interface is wrong**, and the previous handoff's "O1, O2 and O3 are all
discharged" is false at O2.

Rather than start an induction that cannot be finished, this dispatch machine-checked the
refutation, corrected the two files that assert the false reading, and landed the one piece of
the induction's machinery that survives the correction.

## Correction 9 — `GapAdequate` is necessary but not sufficient

`gapAdequate_insufficient` (`FormalSystem/Metalogic/Decidability/Verified/Bridge/Valuation.lean`)
proves three things of one branch, `refuteBoxBranch p q = [T(□p), T(□(p → q))]` at a single label:

1. `branchGapVal` satisfies `GapAdequate` (this is `branchGapVal_gapAdequate`, unchanged);
2. `T(□(p → q))` is on the branch;
3. the assembled model makes `□(p → q)` **false**.

So no reading of `GapAdequate` closes the truth lemma's `box` case, whatever policy is plugged
into it.

**Mechanism.** `GapAdequate` constrains `gapVal` at *atoms* only, on the stated ground that a
compound formula's value at a gap point is fixed by the induction. `truthAt_box_iff_base`
destroys that ground: `□` is the universal modality over every point of every base history, and
`regionHistory` has total domain, so `T(□χ)` with **compound** `χ` is a demand on the gap points'
*induced* values — and nothing but the atom policy can supply those. With `T(□p)` on the branch
and no `T(□q)`, `T(G q)` or `T(H q)` anywhere, every gap point gets `p` true and `q` false, so
`p → q` is false there.

**The engine produces this configuration.** `Tests/BimodalTest/BoxSpreadProbe.lean` row D:
`(□p ∧ □(p → q)) → r` at `.Base` gives
`OPEN boxP=true boxPQ=true boxQ=false Gq=false Hq=false`. Row E pins that the same shape STALLS
under `.Dense` at fuel 200 and again at 400 — recorded as measured, and a separate question.

**The residual is not a better `gapVal`.** The gap's state must be closed under the propositional
consequences of the forced set `{χ : T(Gχ) below} ∪ {χ : T(Hχ) above} ∪ {χ : T(□χ)}`, and a
saturated branch is not closed under those consequences. The lower ray reproduces the failure
from `T(H(p → q))`, `T(H p)` and `F(q)` at the earliest known time — a satisfiable configuration
that forces `q` on the ray with nothing on the branch naming it. So the whole family of atom-wise
policies read off the branch is ruled out, not just the three refuted by name
(`leftCopyGap`, `rightCopyGap`, `branchGapVal`), and their union dies on the rays too.

O2's replacement is a **realisability condition on the branch**, in the decidable-check family
`timeOrderTotal` and `boxAnchoredCheck` already belong to. Two candidate routes, **neither
probed**: model-side (each gap region takes a chosen known label's atoms, with a `Bool` check that
the label's content contains the region's forced set) and branch-side (the dense rules realise
each gap as a minted label, which is then placed in the carrier). Per this task's repeatedly-paid
process lesson, the next dispatch probes the engine before proving anything about either.

## `sat_imp_pos` — the missing branching-rule saturation fact

`FormalSystem/Metalogic/Decidability/Verified/Bridge/PropSaturation.lean` (new module, registered
in `Decidability.lean`). `CountermodelExtraction.lean`'s `sat_*` family covers every rule the
induction consumes **except** `impPos` — the only *branching* propositional rule. Under
`findUnexpanded = none`, `findApplicableRule`'s `.branching` arm declines a non-self-guarded,
non-fresh-label rule exactly when `bss.any (fun fs => fs.all branch.contains)`, and for `T(ψ → χ)`
the arms are `[F(ψ)]` and `[T(χ)]` — so the guard *is* `F(ψ) ∈ b ∨ T(χ) ∈ b`.

Isolated in its own module for the reason `BoxSaturation.lean` gives for its own contents: the
proof unfolds `applyRule` and carries `maxHeartbeats 1600000`. Nothing in it depends on the gap
policy — the `imp` case needs it at *placed* labels, where the branch dictates the valuation
outright — so it survives Correction 9 intact.

## Files changed

| File | Change |
|---|---|
| `Verified/Bridge/Valuation.lean` | `refuteBoxBranch`, `refuteBoxPlacement`, `refuteBox_gap`, `not_truthLemma_branchGapVal`, `gapAdequate_insufficient`; module docstring corrected |
| `Verified/Bridge/PropSaturation.lean` | New: `sat_imp_pos` |
| `Verified/Bridge/TruthLemma.lean` | "What the truth lemma still needs" corrected — O2 reopened, both routes named, explicit "do not start the induction against `GapAdequate`" |
| `Decidability.lean` | Registers `PropSaturation`; `BoxSaturation` entry updated to `BoxAnchored`/`sat_box_grid_of_check` |
| `Tests/BimodalTest/BoxSpreadProbe.lean` | Rows D and E, `gapProbe` harness |
| `plans/01_tableau-decidability-two-track.md` | PHASE 7 STATUS (2026-07-28i) banner, Correction 9, four new DO-NOT-RE-ATTEMPT entries |

## Process note

The refutation cost a fraction of a dispatch because it was found by *trying to write the `box`
case* and then checking the obstruction against a literal branch and an engine run, rather than
by reasoning about the interface in prose. The same lesson the 2026-07-28h handoff recorded —
grep the tree, probe the engine — applies one level up: **an interface reported "discharged" by a
prior dispatch is a claim to test, not a premise to build on**. Three successive statements of the
O2 obligation have now been refuted (`GapDemands`, the copy policies, `GapAdequate`); each was
refuted by the file that stated it, which is the pattern to keep.
