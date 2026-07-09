# Task 340 — Atomic 3-4-5-7 Swap Landing (Summary)

**Status**: implemented · **Session**: sess_1783578954_3bce55_340 · **Date**: 2026-07-09

## What was delivered

The final coupled RED→GREEN structural swap for the per-slot global-index carrier
enrichment landed green. This was the last step; all supporting mathematics had been
banked additively in prior dispatches (10 green commits: region-scoped consistency,
both consistency proofs, both global-Nodup lemmas, parametric enumeration, payload
flatten).

### Steps executed this dispatch

1. **Applied** `swap-attempt-cycle2.patch` (328 lines) — the def-body and membership
   rewrites that rewire `kvE2_sepOrderTypes`, `kvE2_sepModelOrder`,
   `kvE2_sepCoincidentOrder`, `kvE2_sepHonestOrder`, `kvE2_sepDisjValid`, and
   `kvE2_sepSlotGIdx` onto the block-position reader.
2. **Topological reorder** (verified line-range splice, delta 0) of 3 self-contained
   clusters so consumers follow definitions:
   - `kvE2_sepOrderTypes_mem_aux'` / `_owners_aux'` → before
     `kvE2_sepModelOrder_mem_orderTypes`.
   - `kvE2_sepAllSlots_map_slotIndexOf_nodup` + `kvE2_sepZip_flatMap_aux` +
     `kvE2_sepZipPayload_flatMap` → before `kvE2_sepCoincidentOrder`.
   - honest order cluster (`kvE2_sepHonestOrder`, `_mem_orderTypes`, `_mem_arr'`,
     `kvE2_sepHonest_rank_strictMono`, `kvE2_sepBody_complete_holds`) → after the
     honest engines (`kvE2_sepSlotHonestGIdx`, `_injOn`, `kvE2_sepConsistentBlock_honest`,
     `kvE2_sepAllSlots_map_honestGIdx_nodup`).
3. **Fixed the three `_mem_orderTypes` proofs**: the patch used an invalid reversed
   two-argument `List.length_map (block) (f)` call. In this Mathlib
   `List.length_map` takes `f` with `l` implicit. Replaced with: bind
   `kvE2_sepIdxTupleN_mem_of_forall_lt (allSlots).length (block.map f) …`, then
   `rwa [List.length_map] at h`.
4. **noncomputable**: `kvE2_sepSlotMergeLe` and `instance kvE2_sepArr'_decidable`
   (blockPos reader is noncomputable).
5. **Tail conclusion**: `kvE2_sepArr'_sound` → `(wo.flatMap (fun p => p.2.2)).Nodup`.

### Deviation from the continuation recipe

Item 5 of the continuation predicted a genuine re-proof of the mergeSort-sortedness
consumer layer (`kvE2_sepSlotMergeLe` facts SW:1614-1627,
`kvE2_sepSlotsLFor/RFor_rankPairwise` SW:1798-1860) against the new reader. In fact
that layer typechecks **unchanged** — those lemmas reason at the type level of
`kvE2_sepSlotGIdx` / the merge comparator and never unfold the reader body, so the
reader swap did not disturb them. No re-proof was required.

## Verification

- SharedWitness scoped build: green (1013 jobs).
- Full `lake build`: green (1720 jobs) — OuterGate.lean included.
- Sorry census: `sorry_count: 0`.
- Vacuous defs introduced: 0 (sole repo match is pre-existing, unrelated
  `Examples/TemporalStructures.lean:269`).
- New axioms: 0.
- Axiom check `{propext, Classical.choice, Quot.sound}` (no `sorryAx`) on:
  `kvE2_sepHonestOrder_mem_arr'`, `kvE2_sepBody_complete_holds`,
  `kvE2_sepCoincidentOrder_mem_arr'` (task 337 Phase-1 preserved), `kvE2_sepArr'_sound`.

## Acceptance (task 340 terminal)

All met: sorry-free · axiom-clean · full build green · F1–F7 preserved · task 337
Phase-1 `kvE2_sepCoincidentOrder_mem_arr'` preserved · no 334/336/338/339 regression.
This unblocks task 337 (`kvE2_sepHonestOrder_mem_arr'` and
`kvE2_sepBody_complete_holds` are the consumed objects).

## Downstream (not in this dispatch's acceptance)

Plan phases 8 (`halignL/R`), 9 (per-slot meet coincidence fold, gated by the Phase-1
design gate), and 10 (regionsL/R assembly + `hbdry` + 337 export audit) remain
`[NOT STARTED]` as separate follow-on work.

## Commit

`17fa60c5f task 340 phase 6: land atomic 3-4-5-7 swap (blockPos reader, green)`
