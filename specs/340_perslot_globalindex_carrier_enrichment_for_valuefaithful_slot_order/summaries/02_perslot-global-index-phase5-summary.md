# Task 340 Phase 5 — Implementation Summary (partial)

- **Task**: 340 - Per-slot global-index carrier enrichment for value-faithful slot order
- **Phase**: 5 (model-dependent selection/aggregation lemma over the existing carrier)
- **Status**: [IN PROGRESS] — partial (5.1 objective 1 delivered; honest-order construction remains)
- **Session**: sess_1783561356_89aa2d_340
- **Date**: 2026-07-08
- **File**: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean

## Delivered

`kvE2_sepIdxTuple_mem_of_lt` (SW:749-763) — the Phase-5.1 enumeration-richness lemma:

```
theorem kvE2_sepIdxTuple_mem_of_lt (n a b c : ℕ)
    (ha : a < 3 * n) (hb : b < 3 * n) (hc : c < 3 * n) :
    (a, b, c) ∈ kvE2_sepIdxTuples n
```

Strict generalization of `kvE2_sepPlaceholderTuple_mem` (SW:740) from the region-primary
placeholder shape `(k, n+k, 2n+k)` to an arbitrary in-range tuple, proven by the same three
`List.mem_flatMap`/`List.mem_range` steps. This is the membership fact the model-value-faithful
honest order needs: an owner's three slots' actual global positions in M's value order are each
`< 3n`, so the honest tuple is enumerated.

## Verification

- Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`: green (1013 jobs).
- `lean_verify` on `kvE2_sepIdxTuple_mem_of_lt`: axioms `{propext, Quot.sound}` (subset of allowed
  `{propext, Classical.choice, Quot.sound}`; no `sorryAx`).
- Sorry count: 0. Vacuous defs: 0. New axioms: 0.
- No preserved asset regressed (`kvE2_sepCoincidentOrder`, `kvE2_sepCoincidentOrder_mem_arr'`,
  `mergeSort_perm` membership route, Phases 1-4/6 all intact).

## Not Delivered (remaining Phase-5 work)

The honest-order selection def `kvE2_sepHonestOrder` + membership `_mem_arr'` + monotonicity
`_monotone` + the exported `hpos/hlink/hnd/hreal` engine-precondition bundle. This is one
indivisible model-dependent construction (per-slot M-value collection → sort by M's `LinearOrder`
→ per-(owner,region-rank) global-position tuple), larger than a single agent run. The precise
6-step construction map is recorded in `handoffs/phase-5-partial-handoff.md` and
`.orchestrator-handoff.json` (`blockers[0].concrete_remaining_construction`).

## Why Not "Blocked-Pending-Carrier-Change"

The `ℕ×ℕ×ℕ` carrier, the `kvE2_sepIdxTuples` enumeration (ranging over all of `[0,3n)³`), and the
`kvE2_sepConsistentTuple` validity conjunct are all correct and already admit the honest tuple.
Membership is unlockable precisely via the just-delivered `kvE2_sepIdxTuple_mem_of_lt`. The
obstruction is construction size/effort, not a carrier defect. The v2 postmortem Do-NOT
(no re-frame as carrier-change; no vacuous placeholder) is respected: nothing faked, file green.

## Plan Deviations

- 5.1 objective 1 (`kvE2_sepIdxTuple_mem_of_lt`): DONE (checked in plan with note).
- 5.1 objectives 2-4 + all of 5.2: deferred to Phase-5 continuation dispatch (annotated in plan).

## Next

Re-dispatch task 340 Phase 5 continuation (steps 1-6). Task 337 stays BLOCKED until 340 Phase 5
lands the bundle.
