# Task 340 Phase 5 — Implementation Summary (partial)

- **Task**: 340 - Per-slot global-index carrier enrichment for value-faithful slot order
- **Phase**: 5 (model-dependent selection/aggregation lemma over the existing carrier)
- **Status**: [IN PROGRESS] — partial (5.1 richness lemma + lex-rank kernel delivered; honest-order construction remains)
- **Session**: sess_1783561356_89aa2d_340 (dispatch 1); sess_1783561356_89aa2d_340_cont (dispatch 2)
- **Date**: 2026-07-08
- **File**: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean

## Delivered — dispatch 2 (continuation): lex-rank kernel (SW:783-832)

The model-agnostic SORT SPEC that every remaining Phase-5 obligation reduces to (per handoff #1):

```
def kvE2_ordRank {β} [LinearOrder β] {n} (g : Fin n → β) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j => g j < g i)).card
theorem kvE2_ordRank_lt         : kvE2_ordRank g i < n
theorem kvE2_ordRank_strictMono : g a < g b → kvE2_ordRank g a < kvE2_ordRank g b
theorem kvE2_ordRank_injective  : Function.Injective g → Function.Injective (kvE2_ordRank g)
```

Range `_lt` → the `<3n` bound feeding `kvE2_sepIdxTuple_mem_of_lt`; `_strictMono` → per-owner
`i₀<i₁<i₂` AND the `a<u'<b` cross-region step; `_injective` → the cross-owner `Nodup`. Taking
`g = (model value, slot index)` in the LEX order breaks value ties by the always-distinct slot
index, sidestepping the SW:1585 value-distinctness crux with NO distinctness hypothesis. Green,
sorry-0, axiom-clean `{propext, Classical.choice, Quot.sound}` (verified on `_injective`), committed
(`task 340 phase 5.1: lex-rank kernel …`). Design-agnostic (works for the `n`-anchor or `3n`-slot
family) → reused by whichever honest-order layout the next dispatch settles, hence not churn.

Also surfaced two decisive structural facts (see handoff #2): the carrier tuple is per-(owner,
REGION-RANK) COARSE (all `lXU σ χ` slots share `i₀`), and step-6 realizability collides with
coinciding anchors (a strict region-rank order forces separation the model may not admit, routing
coinciding-anchor owners to `kvE2_sepCoincidentOrder`) — an unsettled layout design point the def
must resolve first.

## Delivered — dispatch 1: `kvE2_sepIdxTuple_mem_of_lt` (SW:757-765) — enumeration-richness lemma:

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
