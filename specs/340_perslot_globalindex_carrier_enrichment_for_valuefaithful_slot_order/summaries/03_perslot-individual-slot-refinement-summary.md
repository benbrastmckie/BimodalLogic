# Task 340 v3 — Implementation Summary (partial: Phase 2 complete)

- **Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
- **Status**: PARTIAL — Phase 1 (design gate, PASS) + Phase 2 (payload type migration) complete;
  Phases 3-10 remaining.
- **Session**: sess_1783561356_89aa2d_340
- **Target file**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`

## Phases Executed

### Phase 1 — Design gate (pre-dispatch)
PASS (resolution a), per `reports/09_phase1-coincidence-fold-gate.md`. The coincidence-fold approach
is fixed: model-dependent value-keyed dedup on the joint `kvE2_sepSlotsLOf`, folded base slots
discharged at the anchor via `kvE2_sepCoincidentAnchor_discharge`; `kvE2_sepSlotsLFor` and
`kvE2_sepArr'` membership stay model-independent (the load-bearing invariant).

### Phase 2 — Carrier payload type migration (this dispatch) — COMPLETED
Migrated the `KvE2SepWeakOrder` payload `(ℕ × ℕ × ℕ) → List ℕ` across ~18 sites, behavior-preserving:

- **Type**: `abbrev KvE2SepWeakOrder := List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × List ℕ)`.
- **Payloads**: `kvE2_sepPlaceholderTuple`/`kvE2_sepHonestTuple` now emit length-3 lists
  (`[k, n+k, 2n+k]`, `[3r, 3r+1, 3r+2]`) reproducing the exact old owner-block indices.
- **Reader**: `kvE2_sepSlotGIdx` reads `t.getD (kvE2_sepSlotRank s) 0` — still rank-indexed, so the
  owner-region tie is intentionally retained (its removal is Phase 4 per the plan).
- **Enumeration**: `kvE2_sepIdxTuples` keeps the `3*n` bound (behavior-preserving); the `N`-bound
  genuinely-per-slot rebuild is Phase 3.
- **Consistency/Nodup/mergeSort keys**: rewritten from tuple projections (`.2.2.1`, `.1/.2.1/.2.2`)
  to `List.getD` forms; consistency proofs re-close via `List.getD_cons_zero`/`List.getD_cons_succ`
  plus the original `omega`.

**Verification**: `lake build Bimodal.…SharedWitness` green (1013 jobs); full `…NfMultiAnchorBridge`
aggregator incl. downstream `OuterGate` green (1016 jobs); `sorry_count = 0`; axiom-clean
`{propext, Classical.choice, Quot.sound}` (verified on `kvE2_sepHonestOrder_mem_arr'`).

**Deviation**: The migration keeps length-3 rank-indexed lists (not yet genuinely per-individual-slot)
and the `3*n` enumeration bound — the minimal behavior-preserving type change that stays green, per
the postmortem constraint forbidding a monolithic RED refactor in Phase 2. Genuine per-slot
faithfulness (variable length = owner block length, per-slot-position reads, N bound) is grown in
Phases 3-6.

## Key Finding — Phase coupling (for the next dispatch)

Phases 3, 4, 6 are a **coupled wave**, not independent. The N-bound per-slot enumeration (3), the
per-slot direct reader (4), and the variable-length per-slot payloads (6) must change together —
a length-3 payload is not a member of an N-bound variable-length enumeration, and a per-slot reader
cannot index a length-3 rank-payload without a tie. A partial Phase 3 would leave the file RED, which
the postmortem constraints forbid. This is why the dispatch stopped at the Phase 2 green milestone.
Recommended sequencing is in `.orchestrator-handoff.json` → `remaining_map.critical_coupling_finding`.

## Remaining Phases (3-10)

See `.orchestrator-handoff.json` → `remaining_map` for the full per-phase map. Summary:
3 (validity + N-bound enumeration richness), 4 (per-slot reader — removes the tie), 5 (soundness-side
membership re-proofs), 6 (value_j→engine-point binding + honest order over `Fin N`), 7
(`kvE2_sepHonestOrder_mem_arr'` re-proof), 8 (`halignL/R` coincidence-free), 9 (coincidence fold —
gated, approach fixed, trip-wire armed), 10 (`regionsL/R` + `hbdry` + 337 export + final audit).

## Preserved Assets (intact)

`kvE2_ordRank` kernel + lt/strictMono/injective (SW:783-832); anchor keystone
`kvE2_sepAnchor_injOn`; `kvE2_sepCoincidentAnchor_discharge`; `kvE2_sepFreshAnchor_ne_baseChiPoint`;
337-P1 `kvE2_sepCoincidentOrder_mem_arr'` (re-proved green under the new payload); honest bundles;
slot-enumeration finiteness `kvE2_sepSlotsLFor/RFor`.

## Artifacts

- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
- `plans/03_perslot-individual-slot-refinement.md` (Phase 2 → [COMPLETED] with deviation note)
- `.orchestrator-handoff.json` (status partial, full remaining map)
