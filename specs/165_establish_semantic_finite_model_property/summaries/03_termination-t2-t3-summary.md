# Phase 4 dispatch 3 — statement repair, T2, and T3's progress measure

- **Task**: 165 (establish_semantic_finite_model_property)
- **Phase**: 4 (Termination, WP3), sub-phases 4.2a–4.2c and 4.3a
- **Date**: 2026-07-28
- **Status**: PARTIAL — 4.1 and 4.2 (less the general termination theorem) complete; 4.3 started
- **Plan**: `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`

## What was done

### 4.2a — the `TableauClosed` statement defect, repaired

The prior dispatch established (machine-checked) that no finite `C` satisfied `TableauClosed`.
Two repairs, both landed:

1. **Conjunctive re-keying** of `gapU`, `gapS`, `sep`. Each field now names the rule's whole
   trigger — `U(⊤,g) ∧ F¬g`, `S(⊤,g) ∧ P¬g`, `K⁺ψ ∧ ¬K⁺(ψ ∧ U(ψ,¬ψ))`. `sub` never produces a
   conjunction out of a conclusion, so none of the three re-fires on its own output. The three
   affected rule closers shortened exactly as predicted (`hC.gapU _ hsf`).
2. **Recorded decision — `trich` leaves `TableauClosed`.** Its guard is
   `branch.contains (SignedFormula.neg d l0)`, a statement about the branch. It is now
   `TrichClosed C b`, phrased in the rule's own disjunct order so
   `applyRule_orderTrichotomy_closed` discharges it with no glue; that theorem no longer needs
   `hC` or `hb` at all, and `applyRule_subformula_closed` gains one hypothesis. Alternatives
   weighed and rejected: keeping a `C`-only field (the very thing that admits no finite `C`), and
   strengthening the rule's `ds.any` guard to `ds.all` (an engine edit, forbidden by the wave-3
   territory contract and capable of moving conformance verdicts).

All 36 rule cases and the combined theorem re-elaborated unchanged apart from those edits.

### 4.2b — T2, the counting half (`TimeTypeBound.lean`, new)

`signedStock`/`card_signedStock` (`= 2 * |C|`), `Branch.timeTypeFinset`,
`timeTypeFinset_subset_signedStock` (T1's consequence at type level), `exists_ne_timeType_eq`
(the pigeonhole via `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` against
`(signedStock C).powerset`, whose card is `2 ^ (2 * |C|)`),
`isSubsetBlocked_of_timeTypeFinset_subset`, `isTemporallyBlocked_of_ancestor`,
`blocking_fires_of_card_lt`, `blocking_fires_of_card_lt_empty`.

`blocking_fires_of_card_lt` carries two hypotheses that are deliberately not assumed away:
`hchain` (pigeonhole gives equal types, but blocking needs an *ancestor* relation — two
incomparable times with the same type block nothing) and `hev` (the eventuality guard Phase 1.3
made genuine). The empty-tracker corollary discharges the second.

### 4.2c — T2, the construction half

`conjEmissions`, `emissions`, `closureStep`, `closureIter`, and
`tableauClosed_of_closureStep_subset`: **all seven `TableauClosed` fields reduce to the single
decidable containment `closureStep C ⊆ C`**. Six committed `#guard_msgs in #eval` stabilisation
rows show the operator halting from the subformula closure — round 3 for `p` (|C| = 8), `F p`
(11), `G p` (13), the real `priorUGap` trigger (20), the real `sepRule` trigger (30); round 4 for
`□p` (17). This is what makes the reduction non-vacuous.

### 4.3a — T3's progress measure and fuel figure (`Fuel.lean`, new)

`expandOnceUnblocked_card_lt` — `Branch.toFinset` strictly grows along an extending step. This
consumes `expandOnceUnblocked_adds_new`, not `expandOnceUnblocked_length_lt`, exactly as the
plan's 2026-07-27b note directs. Plus `card_le_of_subset_universe`, uncapped `soundFuel'`, and
`soundFuel_le_soundFuel'` (the capped runtime default never runs past the justified bound, so
keeping it as the `#eval` default is safe — plan constraint 11).

## Outstanding

1. **4.2d** — general termination of `closureStep` (`∃ n, closureStep (closureIter n seed) ⊆
   closureIter n seed`). Carried as an explicit hypothesis, never a `sorry`.
2. **4.3b** — `buildTableau_isSome`. Both dimensions are now separately available (formulas by
   T1, labels by `blocking_fires_of_card_lt`); what remains is composing them and threading
   `TrichClosed C b` through the fuel loop's branch invariant.

## Verification

| Check | Result |
|-------|--------|
| `lake build FormalSystem.Metalogic.Decidability` | green (1054 jobs) |
| `lake build BimodalTest` | green (1949 jobs) |
| Conformance corpus | verdict-neutral (no `#guard_msgs` movement) |
| Sorry census (`Decidability/`) | 0 |
| Vacuous definitions | 0 |
| New axioms | 0 (repo total unchanged at 2) |

**Pre-existing red outside this phase's territory**: full `lake build` fails in
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (unknown identifier
`w`; missing structure fields `guard_interval`, `guard_accum_preserved`). That module belongs to a
different task's tree, is untouched here, and does not import `Decidability/` — so it is neither
caused by nor fixable within Phase 4's territory.

## Files

- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` (modified)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/TimeTypeBound.lean` (new)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` (new)
- `FormalSystem/Metalogic/Decidability.lean` (imports)
