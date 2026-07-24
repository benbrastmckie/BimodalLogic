# Phase 4a-4 item 2 summary — ExistsForallLemmas Fin layer

- **Task**: 379 — `rearchitect_kampprior_k2_onto_unary_esigma_encoding`
- **Plan**: `plans/24_restore-offpath-chain-then-bridge.md` (v24), Phase 4a-4..N
- **Session**: sess_1784858642_439084
- **Date**: 2026-07-23
- **Dispatch scope**: Phase 4 only, resuming at 4a-4 item 2 (sized as a full sub-run per H8)

## Sub-steps executed

| Sub-step | Result | Commit |
|---|---|---|
| 4a-4 item 2: `ExistsForallLemmas.lean` Fin-variants of the efSat lemma layer | GREEN, first-pass | `b0cecf3ca` |
| 4a-4 item 3: `ConjInterleave.lean` | scoped only (design crux identified), handed off | — |

## What was proved (item 2)

New §9 in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean`
(+601 lines, sub-namespace `Kamp`), the complete mirror of the total efSat lemma layer on the
production per-formula object `ExistsForallFormulaFin`/`efSatFin`:

- **Conjunctive dual**: `ConjExistsForallFin`, `conjSatFin`, `conjSatFin_{nil,cons,append}`
- **Pairwise projection / Lemma 3.2(2) forward** (Rabinovich PDF p.4): `pairProjectFin`,
  `pairwiseProjectionsFin`, `lemma_32_2_forwardFin`
- **Lemma 3.2(3) + ∨∃∀ existential closure (Lemma 3.4, p.5)**: `dropPinFin`, `lemma_32_3Fin`,
  `VeeExistsForallFin`, `veeSatFin`, `veeSatFin_exists`
- **Backward infrastructure**: `pairwiseProjectionsFin_sat`, `pairProjectFin_pins`,
  `env_lt_of_pin_lt_fin`, `env_eq_of_pin_eq_fin`, `pointType_holds_at_env_fin`,
  `partialHolds_subinterval`
- **Augmented target + Lemma 3.2(2) full biconditional**: `existenceSentenceFin`,
  `AugConjExistsForallFin`, `augConjSatFin`, `augTargetFin`, `augTargetFin_forward`,
  `augTargetFin_backward_zero`, private gluing chain (`pinnedPositionsFin` … `gluedChainFin_*`),
  `augTargetFin_backward`, `augTargetFin_iff`

All proofs are verbatim transcriptions of the total layer (representation-independent
constructions; `partialHolds`/`intervalHoldsFin` substitute `unaryHolds`/`intervalHolds`).
No declaration consumes alphabet finiteness; the only `Finset.univ` is over the free-variable
index type `Fin r`.

## Verification results

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas`: green, first pass
- Full `lake build`: EXIT 0 (1772 jobs)
- `#print axioms Kamp.augTargetFin_iff` = `[propext, Classical.choice, Quot.sound]`
- `completeness_discrete` axiom baseline byte-identical
- Live Kamp sorries: exactly the 3 charter-permitted (`KampPrior.lean:562`,
  `EANegation.lean:1090`, `EANegation.lean:1249`); zero introduced this dispatch
- Vacuous-definition scan: no new hits; new-axiom scan: none

## Plan deviations

None. Item 2 executed as specified. Item 3 not started (H8 sizing — see below), which is the
dispatch-sanctioned stop, not a deviation.

## Why the dispatch stopped after item 2

`ConjInterleave.lean` (997 lines) is not a mechanical mirror: the Fin merged formula needs a
merged atom set `M₁ ∪ M₂`, and at a point pinned by only one chain the merged point type is not
expressible as a single `UnaryTypeFin (M₁ ∪ M₂)` — a genuine design decision (M-relative
per-point completion choices, faithful to Prop 3.5 p.5) plus ~300 lines of real proof transport.
Full scoping notes, candidate resolution, existing building blocks (`restrict`/`weaken`), and
route comparison are recorded in
`handoffs/phase-4a-4-item2-handoff-20260723.md` ("ConjInterleave scoping").

## Artifacts

- Handoff: `handoffs/phase-4a-4-item2-handoff-20260723.md`
- Orchestrator handoff: `.orchestrator-handoff.json` (status `partial`, green_head `b0cecf3ca`)
- Plan checklist updated in place (item 2 marked done with inline annotation)
