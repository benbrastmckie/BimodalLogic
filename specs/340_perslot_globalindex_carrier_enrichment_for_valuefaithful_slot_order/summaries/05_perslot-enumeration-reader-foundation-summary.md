# Task 340 v3 — Implementation Summary (partial: Phase 3 enumeration + Phase 4 reader foundations)

- **Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
- **Status**: PARTIAL — Phases 1+2 complete (prior dispatches); Phase 6 slot-family foundation banked
  (prior dispatch). This dispatch banked two further **additive, green, sorry-0** commits toward the
  coupled 3-4-6 flip and produced a **plan-level crux correction**. The atomic flip itself was NOT
  forced (it is genuinely all-or-nothing and dominated by the model-dependent value binding, which
  exceeds one dispatch's budget; forcing it would leave `SharedWitness.lean` RED — postmortem-forbidden).
- **Session**: sess_1783561356_89aa2d_340
- **Target file**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`

## What this dispatch landed (2 green, sorry-0, axiom-clean commits)

Additive only — no existing declaration was changed, so nothing regressed and the file never left green.

1. **Phase 3 enumeration foundation** (`task 340 phase 3.1`):
   - `kvE2_sepIdxTuplesN (n : ℕ) : ℕ → List (List ℕ)` (SW:~968) — every length-`L` list with entries
     `< n`. The variable-arity per-owner-block enumeration replacing the WRONG fixed `3*n` length-3
     `kvE2_sepIdxTuples` (report 08).
   - `kvE2_sepIdxTupleN_mem_of_forall_lt` (SW:~979) — richness: any list with entries `< n` is a member
     at its own length (induction on the list; `List.mem_flatMap`/`mem_range`/`mem_map`).

2. **Phase 4 reader-coordinate foundation** (`task 340 phase 4.1`):
   - `kvE2_sepBlockPos s := (kvE2_sepSlotBlock (kvE2_sepSlotSub s)).idxOf s` (SW:~506) — the
     per-INDIVIDUAL-slot coordinate the refined `kvE2_sepSlotGIdx` reads the payload at, dropping the
     tie-source `kvE2_sepSlotRank` (337 stop-guard).
   - `kvE2_sepBlockPos_lt` (SW:~512) — block position `< block length` for block members (so the
     reader's `getD` hits a real payload entry).

**Verification**: `lake build …SharedWitness` green (1013 jobs); 0 real sorries (3 grep hits are
docstring prose); 0 vacuous defs; 0 new axioms. Axiom-clean `{propext, Classical.choice, Quot.sound}`.

## Crux correction found this dispatch (load-bearing for the next)

The plan's Phase 3 framing ("generalize `kvE2_sepConsistentTuple` to per-slot region monotonicity")
is under-specified, and a naive strict-chain-over-block predicate is **WRONG**. `kvE2_sepSlotBlock σ`
is NOT globally rank-sorted: for a left-interior owner it is `[lXU(0)…] lX1(1) [lUW(2)…] [lWT(0)…]` —
rank drops from 2 (lUW, LEFT region) back to 0 (lWT, RIGHT region) at the L→R boundary. Also
`kvE2_sepSlotsLOf` sorts ONLY left-region slots and `kvE2_sepSlotsROf` ONLY right-region slots.
Therefore `kvE2_sepConsistentTuple` must be **region-scoped and owner-threaded** (see the plan's
Phase 3 note and `.orchestrator-handoff.json → crux_correction_this_dispatch` for the recommended
decidable shape).

## Why the flip was not forced (not a faked closure)

Changing `kvE2_sepConsistentTuple` to region-scoped immediately breaks the length-3 honest order
(`kvE2_sepHonestTuple`, SW:2271) and its membership (`kvE2_sepHonestOrder_mem_arr'`, SW:2323) — so the
honest order MUST flip in the SAME green step. The honest order's per-slot value-rank requires the
`value_j`→engine-point binding (Classical.choose from the honest bundles, ~250-350 lines,
model-dependent) — that plus the model/coincident re-proofs and the region-scoped consistency machinery
is a single atomic 500-800-line transition that exceeds this dispatch. Per the postmortem constraint
"Do a monolithic RED refactor" prohibition and "STOP at a green sorry-0 milestone and hand off
precisely", this dispatch banked the maximal additive green foundation both coupled phases consume and
handed off with a sharpened decomposition.

## Remaining (Phases 3-remaining … 10)

See `.orchestrator-handoff.json → remaining_map` and `next_action_hint`. The atomic flip now consumes:
`kvE2_sepIdxTuplesN` + `kvE2_sepIdxTupleN_mem_of_forall_lt` (enumeration) and `kvE2_sepBlockPos` +
`kvE2_sepBlockPos_lt` (reader), leaving the region-scoped consistency rewire, the enumeration/reader
wiring + `kvE2_sepOrderTypes_mem_aux` generalization, the model/coincident prefix-sum re-proofs, and
the `value_j` binding + `G`-at-`Fin N` + honest membership as the one remaining green step.

## Artifacts

- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (additive; 4 new declarations)
- `plans/03_perslot-individual-slot-refinement.md` (Phase 3/4 IN PROGRESS + crux correction)
- `.orchestrator-handoff.json` (status partial, sharpened remaining map + crux correction)
