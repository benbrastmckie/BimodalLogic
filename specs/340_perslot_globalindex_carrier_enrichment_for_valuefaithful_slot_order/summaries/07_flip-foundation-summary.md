# Task 340 — Dispatch summary: atomic-flip foundation banked (cycle 2)

**Status**: partial (foundation complete + green; atomic swap logically complete but reverted for reordering)
**Session**: sess_1783578954_3bce55_340
**Green checkpoint**: fc85a7de (SharedWitness, 1013 jobs, axiom-clean `{propext, Classical.choice, Quot.sound}`)

## What landed (10 additive, green, committed milestones)

The **entire mathematical + structural foundation** of the coupled 3-4-5-7 flip, each committed at a
green `lake build`, SharedWitness never RED across the dispatch:

| Commit | Lemmas | Role in the flip |
|--------|--------|------------------|
| phase 3.2 | `kvE2_sepSlotRegionLeft`, `kvE2_sepSlotsLFor_regionLeft`, `_RFor_regionRight` | region tag for region-scoped consistency |
| phase 3.3 | `kvE2_sepSlotsLFor/RFor_rank_sorted`, `kvE2_sepSlotBlock_region_rank_sorted`, `kvE2_sepBlock_pos_lt_of_rank_lt` | within-region rank sortedness + block-position alignment |
| phase 3.4 | `kvE2_sepSlotIndexOf_block_mono` | global slot index = offset+position (Nodup infix) |
| phase 3.5 | `kvE2_sepConsistentBlock` (predicate), `kvE2_sepBlockMap_getD`, `kvE2_sepConsistentBlock_slotIndexOf` | region-scoped consistency predicate + prefix-sum (model/coincident) proof |
| phase 7.1 | `kvE2_sepSlotValue_region_rank_mono` | **honest-consistency crux**: within-region value ordering (8-constructor case analysis over the interval specs, ~150 lines) |
| phase 7.2 | `kvE2_sepConsistentBlock_honest` | honest value-rank consistency (crux + `kvE2_sepSlotHonestGIdx_mono`) |
| phase 5.1 | `kvE2_sepAllSlots_map_slotIndexOf_nodup`, `_honestGIdx_nodup` | the (iii) global-Nodup building blocks (via `injOn`) |
| phase 3.6 | `kvE2_sepOrderTypes_mem_aux'`, `_owners_aux'` | enumeration-parametric aux for the σ-dependent N-bound enumeration |
| phase 5.2 | `kvE2_sepZip_flatMap_aux`, `kvE2_sepZipPayload_flatMap` | flatten per-owner payloads → `allSlots.map f` for the (iii) conjunct |

**Crux correction honored**: consistency is REGION-SCOPED (compares ranks only within one region);
block rank is non-monotone across the L→R boundary. This is baked into `kvE2_sepConsistentBlock`.

## The atomic swap (attempted, correct, reverted)

The swap — rewiring `kvE2_sepOrderTypes` (σ-dependent N-bound enum), `kvE2_sepModelOrder` /
`kvE2_sepCoincidentOrder` / `kvE2_sepHonestOrder` (payload = `block.map` of the index families),
`kvE2_sepDisjValid` (region-scoped consistency + flatMap global Nodup), `kvE2_sepSlotGIdx`
(`kvE2_sepBlockPos` reader), and the three membership re-proofs — was written and is **logically
complete and correct**: every banked lemma assembles exactly as designed. Saved verbatim as
`swap-attempt-cycle2.patch` (328 lines).

It did **not** land green this dispatch, failing on TWO mechanical (non-mathematical) issues:

1. **Declaration ordering** (forward references): the honest engines and the flatMap/Nodup/parametric-
   aux lemmas are defined *after* the orders that now consume them. Fix = relocate 3 self-contained
   clusters (detailed in `.orchestrator-handoff.json` `continuation_context`).
2. **A newly-surfaced consumer layer**: the mergeSort-sortedness lemmas (`kvE2_sepSlotMergeLe` facts
   SW:1614-1627, `kvE2_sepSlotsLFor/RFor_rankPairwise` SW:1798-1860) reason about the *old* rank-based
   reader and must be re-proved against the new `kvE2_sepBlockPos` reader. Plus `noncomputable` marks
   (`kvE2_sepSlotMergeLe`, `kvE2_sepArr'_decidable`) and one tail conclusion fix (`kvE2_sepArr'_sound`).

Per the all-or-nothing constraint (the honest order breaks the moment the consistency predicate
changes), the swap was reverted cleanly to `fc85a7de`. No load-bearing 334/336/337-P1/338/339 result
was touched.

## Next dispatch (materially mechanical)

Apply `swap-attempt-cycle2.patch`, do the 3-cluster topological reorder, mark 2 defs noncomputable,
fix 1 tail conclusion, and re-prove the mergeSort-sortedness consumer layer against the blockPos
reader. No new mathematics remains — every consistency/Nodup/enumeration/reshaping lemma is banked.
