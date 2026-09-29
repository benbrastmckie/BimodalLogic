# Phase 12 Handoff — Documentation, hand-off contract, and the full gate set

- **Task**: 696
- **Phase**: 12 [COMPLETED] — the last phase; the plan is complete
- **Timestamp**: 2026-09-29
- **Session**: sess_1790680388_3d4c26 (dispatch 7)

## What this phase did

Brought every prose account of the substrate into line with what exists, recorded the export
contract's additive extension, and ran the complete gate set.

The two SUPERSEDED banners Phase 8 left are gone, replaced by rewritten sections. The Sharing
README's `(C1')` correction now records the defect and the repair in that order, with the four
theorems that make the repair real rather than cosmetic. The Plus README's section is now "What
this certificate can and cannot refute", with a table naming both gate families, their targets,
their certificates and where their sharing is non-trivial. Both READMEs' follow-up sections
describe what landed rather than what a follow-up needs.

The export contract now documents `transBack`/`transMid`/`transFwd` as three OPTIONAL lists whose
absence means the all-true matrix, which is what makes the extension additive: every certificate
emitted before the redesign remains valid unchanged, and the accepting branch's
`Refutes Γ Del` codomain did not move.

## The full gate set, as run

| Gate | Result |
|---|---|
| `lake build` | green, 2771 jobs |
| sorries in both touched directories | 0 |
| repo-wide sorry census | 0 |
| axiom count | 14, unchanged from pre-refactor |
| `scripts/check-module-invariants.sh` | ALL CHECKS PASSED, C2 at eighteen rows |
| `scripts/check-evidence-probes.sh` | PASS, all 7 wired probes |
| `scripts/readme-lint.sh` | PASS |
| `scripts/check-copyright-headers.sh` | 0 nonconforming, 0 missing, 605 files |
| soundness statements vs pre-refactor commit | byte-identical, all three |

## Named follow-up work

- **Exact closure for `lift`**: `LiftWindow`, `liftable_of_liftWindow`, `Decidable LiftWindow`.
  This is the work task 694 is to be re-scoped to, per the recorded user decision, and it is
  listed as a non-goal of this plan.
- **(C2')'s limitation** survives, re-examined rather than inherited. Both READMEs now state the
  reason: the window reduction's far-left and far-right cases consume exactly the relation a
  thread's step supplies, so the re-quantification transferred verbatim, and the limitation is
  about the position graph's backward region being a path rather than a cycle.
