# Phase 11.2 Handoff — The Pin Cascade, Front Half

- **Phase**: 11.2 (plans/09_tight-chain-gate-regated-graph.md) — closed `[COMPLETED]`
- **Dispatch**: seq 26, session `sess_1793770123_ca991a`

## Immediate next action

Enter Phase 11.8 (the cascade construction, `exists_spliced_ladderPath_of_idle_past`), whose
`Depends on` is this phase alone and which now has its three facts available by name. The other
two enterable phases are 11.9 (the tight-chain decision gate) and 12.1 (`Real` and its
agreement-free conditions).

## What landed

`FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`, new `section Cascade` between
the splice section and the alternative-history section (module now 2,476 lines, in-source
`longFile` baseline raised in place 2400 -> 2600, the pre-authorized PRIMARY remedy; the
contingency module `LadderCascade.lean` was not created and no import edge moved):

- `pinnedRegions` (def) — region starts whose span meets a window `[p, a]`
- `pend_of_mem_region` — every position of a region's span is pending
- `pinnedRegions_subset_Ico` — **the load-bearing fact**: an idle `p` admits no region start
  below it whose span reaches it, so the pinned regions a window meets lie inside the window
- `pinnedRegions_finite`, `pinnedRegions_ncard_le` — its corollaries; the second is the
  iteration count, as a COUNT
- `pin_deficit_le_of_lengthen` — the per-step increment, over `pinCompat_of_ladderPath`
- `cascadeDemand` (def), `cascadeDemand_add_succ`, `cascadeDemand_le_cascadeBound` — the
  recurrence `a (k+1) = 2 * a k + J + 1`, its closed form, and the sizing against `cascadeBound`
- `regime_exhaustive_of_clipIdx_eq` — regime exhaustiveness as a lemma: a gap-coordinate
  collision at a fixed next deadline never straddles the two regimes

Plus axiom pins for all nine theorems in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
and the regenerated inventory blocks / `status.typ`.

## Key decisions

- **Where `p` idle is consumed.** Finiteness alone is weaker than what the cascade needs, and the
  idleness is consumed in the CONTAINMENT (`pinnedRegions_subset_Ico`), not in the finiteness
  statement read on its own. `lean_minimal_hypotheses` reports every explicit binder of that
  lemma, `hp` included, load-bearing. The containment is also where the count comes from.
- **The sizing cites `cascadeBound` and nothing else as a proof term.** The five probe-level
  anchors (`forward_window`, `backward_constraint`, `region_doubling`, `doubling_attained`,
  `iter_doubling`) are cited by PATH in the section docstring, per finding 8;
  `two_pow_card_prodState_le_Tc` is named only as unavailable, per finding 9.
- **Nothing was relaxed.** `git diff --numstat` on the module is 178 added / 1 removed, the one
  removal being the `longFile` line.

## Deviations

- The inventory regeneration rewrote `FormalSystem/Metalogic/README.md` and the root `README.md`
  in addition to the RaySummary README. Both are generated line-count cascades of the one library
  edit; neither is listed under the phase's `Files to modify`; both are committed with this phase
  as a declared `file_scope` excursion, because omitting them leaves the `INV` inventory group
  stale. Annotated inline on the wiring checklist item.

## Inherited / pre-existing problem

`check-module-invariants.sh` exits 1 on `FAIL C16`: an `unusedArguments` finding on
`mem_cellAt_of_shift_of_hasForwardSlack` (`LadderChain.lean:2136`, the `hslk` binder), absent
from `scripts/nolints.json`. `LadderChain.lean` is clean at this dispatch's starting commit and
Phases 11.2/11.8 are forbidden to edit it, so the phase's absolute "exits 0" criterion is
unmeetable for a reason outside this phase's territory. Every other group of that script passes.
Phase 11.8 inherits the same unmeetable criterion and should record it the same way.

## Verification at close

Scoped builds (`LadderAgree`, `KTypeSummaryAxiomTest`): exit 0, 0 errors, 0 warnings each.
Full `lake build`: exit 0, 0 errors, 0 warnings, 2,895 jobs; `.olean` newer than source for both
touched modules. `sorry_count: 0`. Module-scoped vacuous grep 0; repo-wide 1 (baseline).
`^axiom ` 10 / 2 (baseline). `typst-sync-check.sh`, `readme-lint.sh`,
`check-evidence-probes.sh` (47 wired), `check-task-references.sh --quiet` each exit 0.
