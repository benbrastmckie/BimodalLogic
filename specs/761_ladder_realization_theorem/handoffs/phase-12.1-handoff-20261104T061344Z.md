# Phase 12.1 Handoff — `Real` and Its Agreement-Free Conditions

- **Phase**: 12.1 (plans/09_tight-chain-gate-regated-graph.md) — closed `[COMPLETED WITH EXCLUSIONS]`
- **Dispatch**: seq 26, session `sess_1793770123_ca991a`

## Immediate next action

Phase 11.9 (the tight-chain decision gate) is the remaining high-value enterable phase and waits
on Phase 11.5 alone. Phase 11.8 is enterable behind the now-closed Phase 11.2 but its third task
is stated in a shape this dispatch believes is refutable — see the note below before entering it.

## What landed

`FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` (132 -> 363 lines; no new
import was needed, since `CounterQuotient` already pulls in `Certificate` -> `AnchorLayer` and
`LadderModel`):

- `stab_bit_agree_of_certStabK` — verbatim from `handoffs/phase-11-handoff-20261019T015000Z.md`
- `realItem` (noncomputable def) — the item a point of a ladder history realizes
- `Real` (def) — the actually realizable subset, with the world state's `ℤ` coordinate
  EXISTENTIALLY quantified rather than pinned to the time of evaluation
- `mem_real_iff`, `mem_real_realItem` — every point of every admissible ladder history projects in
- `mem_clType_iff_truth` — the bridge from membership in a member's closure type to truth at the
  witnessing point; every condition of `Real` is proved across it
- `real_certLocK` (condition (1)), `real_certBoxK` (condition (6))

Plus axiom pins for all six theorems in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
(whose in-source `longFile` baseline was raised in place 1900 -> 2000) and the regenerated
inventory blocks / `status.typ`.

## The exclusions, and the one lemma they need

`certBiInfK`, `certFwdK` and `certBwdK` of `Real` are EXCLUDED, for one shared reason rather than
three: all three quantify `relK`, whose counter conjunct is `RK Tc Tn P B (pend x.1) (pend y.1)
x.2.2 y.2.2`, and no theorem of this library derives an `RK` edge from an actual `Count`/`Drift`
step at arbitrary counters. `CounterQuotient.lean`'s own `R_K` section docstring says so in terms
and assigns it to the gated counter-lift lemma's obligations. A repository-wide grep for `RK Tc`
returns three lines, all in that module: the `Decidable` instance, `rk_iff`'s statement, and
`relK`'s definition.

The missing lemma, written out in the phase's `#### Reasoned Exclusions` record so a successor
does not re-derive it:

```lean
theorem rk_of_count_drift (Tc Tn P B : ℕ) (px py : Bool) (c n c' n' : ℕ)
    (hc : Count px py c n c') (hd : Drift n n') :
    RK Tc Tn P B px py (kappa Tc Tn P B (c, n)) (kappa Tc Tn P B (c', n'))
```

Three findings about it: (1) it is NOT a per-coordinate reduction, because `kappa`'s gap
coordinate `clipIdx B c n` couples the two counters (at `c = 100`, `n = 101`, `B = 3`,
`Tc = Tn = 1`, `P = 0` the independent reduction moves the gap from `1` to `0`); (2) a COMMON
downward shift by a multiple of `P + 1` does preserve all five coordinates — `kappa_eq_of_shift`
read downward — but is bounded by whichever counter hits its threshold first, so the construction
needs the saturated-gap regime as a second case and `Count`'s `py = false` arm (where `c' = 0` is
forced and cannot be shifted) as a third; (3) whether `repsCnt`'s own bound
`Tc + Tn + P + B + 2` suffices for that construction is itself open, and if it does not then the
lemma is false as stated and the bound is the defect.

The temporal content those two fulfilment conditions need is already landed —
`untl_mem_tpOf_iff` and `snce_mem_tpOf_iff` (`LadderAgree.lean`) give the fulfilling position and
the guard along the intervening stretch of the SAME history, and the discharge path would be the
contiguous stretch of that history, every position of which lies in `Real` by
`mem_real_realItem`. The relation link between consecutive positions is the only gap.

## A warning about Phase 11.8 before it is entered

Phase 11.8's third task asks for `exists_spliced_ladderPath_of_idle_past` "with the same
conclusion shape the landed pending-forever companion has", i.e. concluding about
`spliceObj g a l` / `spliceCnt g a l`. That looks REFUTABLE rather than merely hard, and the
reason is internal to the landed module: `spliceCnt_add_of_mem_region` raises the pin at the start
`s0` of the region containing `a` by exactly `l` while leaving every earlier region start alone,
and `pinCompat_of_ladderPath` proves pairwise pin compatibility NECESSARY for any ladder path
whatsoever. So whenever an earlier start `v` sits close enough that
`cntAt g (s0+1) + l - cntAt g (v+1) > s0 - v`, NO ladder path has that object walk and that
countdown. The phase's own Goal line already says the construction "lengthen[s] the preceding
idle runs along with the spliced region", which changes the walk below `a` and so cannot conclude
about `spliceObj g a l`; the Goal and the third task therefore disagree. This was not entered in
this dispatch and nothing was landed or weakened on it; it is raised so the next round decides
the statement rather than discovering the conflict mid-proof.

## Verification at close

Scoped builds (`LadderRealize`, `KTypeSummaryAxiomTest`): exit 0, 0 errors, 0 warnings each.
Full `lake build`: exit 0, 0 errors, 0 warnings, 2,895 jobs; `.olean` newer than source for both
touched modules. `#print axioms` on all six new theorems: `[propext, Classical.choice,
Quot.sound]`. `sorry_count: 0`. Module-scoped vacuous grep 0; repo-wide 1 (baseline);
`^axiom ` 10 / 2 (baseline). `typst-sync-check.sh`, `readme-lint.sh`,
`check-task-references.sh --quiet` each exit 0; `check-module-invariants.sh` still exits 1 on the
same single pre-existing `C16` finding in `LadderChain.lean`, a module this plan forbids editing,
with `C23`'s shadowing check passing on the new `Real`.
