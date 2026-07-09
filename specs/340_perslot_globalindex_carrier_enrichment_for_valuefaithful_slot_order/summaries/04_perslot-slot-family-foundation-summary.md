# Task 340 v3 — Implementation Summary (partial: Phase 6 slot-family foundation)

- **Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
- **Status**: PARTIAL — Phases 1 (design gate PASS) + 2 (payload type migration) complete from
  prior dispatches; this dispatch landed the additive, model-independent **Phase 6 slot-family
  foundation** (handoff step (1)). Phases 3-10 remain [NOT STARTED].
- **Session**: sess_1783561356_89aa2d_340
- **Target file**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`

## What this dispatch landed (3 green, sorry-0, axiom-clean commits)

Additive only — no existing declaration was changed, so nothing regressed and the file never left
green. This is exactly handoff step (1) of the critical-coupling sequencing ("define the canonical
owner-block slot ordering + slotIndexOf/positionOf, model-independent").

1. **Slot-family definitions** (`task 340 phase 6.1`):
   - `kvE2_sepSlotBlock σ := kvE2_sepSlotsLFor σ ++ kvE2_sepSlotsRFor σ` — σ's canonical
     per-individual-slot block (variable arity — the per-slot granularity replacing the fixed
     3-arity owner-region tuple).
   - `kvE2_sepAllSlots qnf := (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock` — the full cross-owner
     slot family (length `N`), the `Fin N` domain of Phase 6's value family `G`.
   - `kvE2_sepSlotIndexOf qnf s := (kvE2_sepAllSlots qnf).idxOf s` — the global per-slot position.
   - `kvE2_sepMem_allSlots`, `kvE2_sepMem_slotBlock` — membership plumbing.

2. **`kvE2_sepAllSlots_nodup`** (`task 340 phase 6.2`, load-bearing): the full slot family is
   duplicate-free. Route: `kvE2_sepSlotBlock_nodup` (per-block Nodup — constructor injectivity in χ
   via `kvE2_sepS_nodup`/`kvE2_sepS_map_nodup`, cross-constructor `a ≠ b` by `reduceCtorEq`) plus
   `kvE2_sep_blocks_disjoint` (cross-owner disjointness via `kvE2_sepSlotSub_of_mem_block`), combined
   through `List.nodup_flatMap`. This makes `kvE2_sepSlotIndexOf` a genuine embedding into `[0, N)`.

3. **`kvE2_sepSlotIndexOf_lt` + `kvE2_sepSlotIndexOf_injOn`** (`task 340 phase 6.3`): the `Fin N`
   domain bound (`List.idxOf_lt_length_of_mem`) and structural injectivity on family members (via
   `List.idxOf_get` — no Nodup even required). These give `G j = (value_j, j)` a globally injective
   index coordinate (feeds `kvE2_ordRank_injective` in Phase 6).

**Verification**: `lake build …SharedWitness` green (1013 jobs); downstream `…NfMultiAnchorBridge`
aggregator (incl. OuterGate importer) green (1016 jobs); `SharedWitness` sorry-count 0 (the only
`sorry` tokens are docstring prose; the 2 real sorries reported by a full build are pre-existing in
the unrelated `EANegation.lean`). Axiom-clean `{propext, Classical.choice, Quot.sound}` verified on
`kvE2_sepAllSlots_nodup` and `kvE2_sepSlotIndexOf_injOn`.

## Why the dispatch stopped here (not a faked closure)

The coupled wave **Phases 3-4-6 (+5, +7)** is an all-or-nothing green transition: a length-3
rank-indexed payload is not a member of an `N`-bound variable-length enumeration, and a per-slot
reader cannot index a length-3 rank-payload without a tie — so the payload type, the reader, and the
enumeration must flip together in ONE green step, and a partial attempt leaves `SharedWitness.lean`
RED across the dispatch (postmortem-forbidden). The value_j→engine-point binding + honest-order
redefinition + the 3 membership re-proofs on top of that flip exceed one dispatch's budget. Per the
dispatch instruction ("STOP at a green sorry-0 milestone and hand off precisely — do NOT fake
closure"), this dispatch banked the maximal ADDITIVE green foundation the wave needs and handed off.

The escalation trip-wire did NOT fire: `kvE2_sepSlotsLFor` (SW:292) and `kvE2_sepArr'` membership
remain untouched and model-independent; the new index machinery is structural (idxOf over a
syntactic family), consistent with gate report 09.

## Remaining (Phases 3-10)

See `.orchestrator-handoff.json` → `remaining_map`. The next dispatch consumes the foundation above:
build the per-slot payload (length = block length) + per-slot reader (`kvE2_sepSlotGIdx` reading
`kvE2_sepSlotIndexOf`-position, dropping `kvE2_sepSlotRank`) + `N`-bound enumeration together (3-4-6),
re-prove the 3 membership theorems (5,7), then `halignL/R` (8), the coincidence fold (9, gated —
approach fixed by report 09), and `regionsL/R` + `hbdry` + the 337 export (10).

## Artifacts

- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (additive; ~150 new lines of definitions + lemmas)
- `plans/03_perslot-individual-slot-refinement.md` (Phase 6 foundation-landed note)
- `.orchestrator-handoff.json` (status partial, updated remaining map + dispatch progress)
