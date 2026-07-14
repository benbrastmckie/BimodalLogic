# Phase 14c Handoff — (E4) past carrier `CExtPast(_correct)` + ∃w pin glue + 3-bot falsity (task 350)

**Status**: Phase 14c COMPLETED. Single-phase dispatch (phase_number=14c); stopped at phase
boundary per contract. Session `sess_1784009176_e5245f`.

## Immediate Next Action (Phase 15 — E5 + optional E6 future-exterior mirror `CExtFut(_correct)`)

The `t < w` channel: Until-navigated mirror of E2-E4 in NEW module
`Kamp/NfMultiAnchorBridge/ExteriorNavFutK1.lean` (+ one import line in the aggregator).
Rabinovich anchor: Lemma 7.8(2) TL(Until,K⁻) duality (chunk_0022). Mirror inventory:
- `navPackRight` (Until-navigated w-package at the pin `t`, `endpointRight` side) — mirror
  of `navPackLeft` with `Formula.untl` in place of `Formula.snce`, zones `extZAboveW`-side:
  the w-dependent groups are atoms-at-w, `v = w`, `v > w` (`extZAboveW`... check Phase-13 kit
  zone names for the `x < t < w` channel), `t < v < w` interior.
- `navDistribRight` — mirror distribution under ambient `x < t` for `∃ w, t < w ∧ nf_eval [x,t,w] σ`
  (NOTE: env order/zone names change — the witness is position 2, pins at positions 0,1).
- `CExtFut` + `CExtFut_correct` + 3-bot falsity, gated exactly like `CExtPast` (this phase's
  `navDGate` pattern: `@dite _ gate (Classical.dec _)`, empty disjunction off-gate).
- E6 `extDuality` is OPTIONAL and probe-gated (H4 flag: chunk_0022 says only "proved
  similarly"); if no clean `M`-reversal, duplicate the E1-E4 shapes and record the decision.

## Current State

- Phases 1-13 + 14a + 14b + 14c COMPLETED (18 phase headings done of the plan's 22-heading
  inventory; remaining: 15, 16a, 16b, 17). Dispatch DoD counter: phases_completed=18,
  phases_total=18 SATURATED with note — completion is driven by plan headings, and 15/16a/16b/17
  remain [NOT STARTED].
- Full `lake build` green: 1749 jobs. Scoped module 1035.
- Sorry census over `NfMultiAnchorBridge/`: 0. Sorry inventory: EMPTY. (Compiler cross-check:
  30 project-wide sorry warnings, ALL pre-existing outside territory — KampPrior task-358 debt +
  long-standing Bundle/TruthLemma/EFGames/BXCanonical debt; unchanged from 14b baseline.)
- `lean_verify` on `CExtPast_correct`, `navD_inconsistent_eval_false`,
  `CExtPast_inconsistent_false`: exactly `[propext, Classical.choice, Quot.sound]`, no warnings.
- No frozen-file / KampPrior / task-358 edits (diff = ExteriorNavPastK1.lean +118 lines and the
  plan file only). `nf_char3_deeper_split` not referenced.

## Phase-14c delivered names (BINDING — consume, never rebuild)

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`
(module now 1083 lines; NO new imports), namespace `Bimodal.Metalogic.WeakCanonical.Kamp`,
section variables `(atomMap) (h_surj)`:

| Asset | Content |
|---|---|
| `navDGate σ : Prop` | the three pure σ-side conjuncts of `navDistribLeft`: `navDOrderRow` ∧ inconsistent-zone falsity ∧ off-fiber honesty |
| **`CExtPast σ : VVecEA2`** | on-gate: one VecEA2 per `L ∈ (navDXTBitTrueList σ).permutations`, `endpointLeft = ⟨(navPackLeft σ).formula.and (navDAtXPack σ)⟩`, `endpointRight = ⟨navDAtTPack σ⟩`, `bracket = navDXTBracket σ L`; off-gate `⟨[]⟩` (public) |
| **`CExtPast_correct M σ x t (hxt : x < t)`** | `(CExtPast σ).holds M atomMap x t ↔ ∃ w, w < x ∧ nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ` (public) |
| `navD_inconsistent_eval_false` | ¬`navDOrderRow σ` → ∀ w<x<t, ¬nf_eval (eval-side 3-bot falsity) |
| `CExtPast_offGate_false` | ¬`navDGate σ` → carrier holds is False at every pin pair (no ambient) |
| `CExtPast_inconsistent_false` | ¬`navDOrderRow σ` → carrier holds is False (order-row specialization) |

## Key Decisions

1. **Gate via `@dite _ (navDGate σ) (Classical.dec _)`** — verbatim the `agg2Past` pattern
   (AggregateHookDischarge.lean:495), NOT a Decidable-instance derivation: the gate quantifies
   over `ZoneSpec 3` and `NormalForm sig 0 4`, and Classical.choice is already in the axiom set.
2. **`CExtPast_correct` is a single `rw [navDistribLeft]` + dite `split`** — no re-peeling.
   Decision 4 of the 14b handoff paid off exactly as designed: on-gate, the carrier's
   `∃ vea ∈ map …` collapses to `epL@x ∧ epR@t ∧ (∃ L ∈ perms, bracket L)` because the endpoints
   are SHARED across disjuncts (the ∃L needs no nonemptiness argument — conjunct 3 of the RHS
   carries the same ∃L on both sides). Off-gate both sides are False (RHS contains the three
   gate conjuncts verbatim).
3. **`temporal_truth_and` (Translation.lean:55) is the only endpoint splitter needed** —
   `endpointLeft = ⟨Formula.and pack.formula atX⟩` splits by one rw; `endpointRight` needs
   nothing (defeq through `TemporalPred.eval_at`).
4. **Lean 4.27 gotcha**: `List.not_mem_nil` now takes the membership proof directly
   (`hmem → False`), not the element — `(List.not_mem_nil hmem).elim`, NOT
   `absurd hmem (List.not_mem_nil _)`.
5. **Off-gate falsity stated WITHOUT ambient `x < t`** (`CExtPast_offGate_false`) — stronger
   than the correctness specialization and what 16a's dispatcher will want when routing
   inconsistent σ.

## Sorry Inventory

[] (empty — module and all consumed assets sorry-free)

## References

- Plan: `specs/350_.../plans/03_negfix-refactor-exterior-carriers.md` Phase 14c (line ~723,
  now [COMPLETED]) and Phase 15 (line ~757).
- Consumed: Phase-14a `navPackLeft`/`navPackLeft_correct`; Phase-14b `navDistribLeft`/
  `navDXTBracket_arrangements_iff`/`navDAtXPack`/`navDAtTPack`/`navDXTBitTrueList`/
  `navDXTBracket`/`navDOrderRow` (same file); Phase-13 `extZoneFiber_k1` +
  `navD_atomLayer_iff`; `agg2Past` gate pattern (AggregateHookDischarge.lean).
- Rabinovich 2014: Lemma 7.6 `(∃z1)_{z0}^{z2}` closure (chunk_0021); Lemma 7.8(1) (chunk_0022).
