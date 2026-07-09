# Task 337 Implementation Summary (v4 dispatch) — STOP-GUARD: interface mismatch (partial)

- **Task**: 337 — Build the joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct`
  (deliver `kvE2_sepDisjunct_holds_of_honest`).
- **Plan**: `plans/04_joint-disjunct-holds-codesign.md`
- **Outcome**: `partial` — the Phase-1 interface-stability **stop-guard fired**. No Lean written,
  no declaration edited; `SharedWitness.lean` remains post-340 green. This is the sanctioned
  "legitimate partial, not a failure" outcome (task dispatch + plan Rollback bullet 3).
- **Acceptance**: NOT met (blocked at Phase 1, before any proof content).

## What was verified (grounded in the landed declarations)

The dispatch read the engine, the disjunct/bracket/slot machinery, the extract lemma, and every
landed task-340 deliverable, then compared the landed interface against the plan's Preconditions
(2)+(3).

**Task 340 delivered (verified present, treated as verified INPUTS):**
- `kvE2_sepHonestOrder` (SW:2118) + `kvE2_sepHonestOrder_mem_arr'` (SW:2146) — the `wo`/`hmem`
  carrier member (Precondition (1) ✓).
- `kvE2_sepHonestAnchorBundleL/R` (SW:2290/2329) — PER-OWNER realizer data at each owner's anchor.
- `kvE2_sepHonest_cross_region` (SW:2222), `kvE2_sepHonest_same_owner_mono`,
  `kvE2_sepHonest_rank_strictMono`, `kvE2_sepAnchor_injOn` (SW:2042) — tuple-index monotonicity /
  keystone injectivity.
- `kvE2_sepBody_complete_holds` (SW:2267) — the reduction taking the single 337-owned `.holds`
  (`hdisj`) as a delegated hypothesis.

**Task 340 did NOT deliver (required by Preconditions (2)+(3)):**
- (A) the assembled boundary-linked region decomposition `regionsL/R` with
  `hpos/hlink/hnd/hreal` consumable by `k1v_sorted_realizationK` (SubBracket2V:633-646);
- (B) the alignment fact `halignL/R` tying `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)`
  (SW:1034/1040, a `mergeSort`) to the engine's value-sorted `interleaveK ps` order;
- (C) the endpoint boundary alignment `hbdry`.

## Root cause — a carrier-granularity gap (decisive, not speculative)

- `kvE2_sepHonestTuple` (SW:2095-2103) `= (3ρ, 3ρ+1, 3ρ+2)` — exactly **three** global-index
  values per owner (ρ = `kvE2_ordRank`), one per region.
- `kvE2_sepSlotRank` (SW:245-253): every `.lXU σ χ` region-0 base slot has rank 0; every
  `.lUW σ χ` region-2 base slot has rank 2.
- `kvE2_sepSlotGIdx` (SW:1006-1013) reads the tuple at the slot's rank ⇒ **all** of an
  owner-region's base slots share one global index (a **tie**).
- `kvE2_sepSlotsLOf wo` (SW:1034) is `mergeSort` by that tied index ⇒ within any owner-region
  block of ≥2 base types the order is stable-input (enum) order, **unrelated to realizer
  M-values**.
- The bracket `.holds` (mpr direction of `IntervalPattern.holds_eq_succ`, the dual of
  `kvE2_sepDisjunct_extract` SW:2625) needs a **strictly monotone** `ws` realizing each slot's
  `charBase χ` point type at its mergeSort position; `k1v_sorted_realizationK` emits
  `interleaveK ps` with `ps.map fst` a `List.Perm` of the region types sorted **by value**.

Reconciling the value-sorted engine order with the tie-blocked mergeSort order is exactly the
missing `halignL/R`, and it is **unprovable** against the landed per-owner-region index whenever
an owner-region holds ≥2 base types (the tie-block admits no value-faithful order). Constructing
(A)+(B)+(C) inside 337 would require re-deriving the carrier value-faithfulness of the global
index down to individual slots — the exact re-scope the 3-agent synthesis rejected (report 04 Q2)
and the plan's Non-Goals + interface-stability note forbid.

## Phases

| Phase | Status | Note |
|-------|--------|------|
| 1 — consume 340-P5 bundle (step a) | [BLOCKED] | Stop-guard: bundle (2)+(3) not delivered; carrier index has ties |
| 2 — invoke `k1v_sorted_realizationK` (step b) | [NOT STARTED] | Blocked by 1 |
| 3 — bracket point-type match (step c) | [NOT STARTED] | Blocked by 2 |
| 4 — endpoint discharge + builder (step d) | [NOT STARTED] | Blocked by 3 |
| 5 — axiom/faithfulness gate | [NOT STARTED] | Blocked by 4 |

## Verification snapshot

- Sorry count (new): 0. Vacuous defs added: 0. New axioms: 0. Lean file edited: none.
- No `lake build` regression risk introduced — the additive helpers were never written.

## Resolution / next action (→ task 335 is downstream, awaits this builder)

1. **Preferred**: spawn a **task-340 follow-up** to refine `kvE2_sepHonestTuple` /
   `kvE2_sepSlotGIdx` to a genuinely per-INDIVIDUAL-SLOT value-faithful global index (distinct
   value-ranked index per base type), landing `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)` as a
   value-sorted chain plus `halignL/R` + `hbdry` as consumable INPUTS.
2. **Alternative**: task 340 lands the assembled `regionsL/R` + `halignL/R` + `hbdry` directly
   (Preconditions (2)+(3) verbatim).
3. Once the seam is restored, re-dispatch **337 Phases 2-4** (engine invoke → single-`ptW`
   bracket match → endpoint discharge → `kvE2_sepDisjunct_holds_of_honest`). Downstream: task 335
   consumes `kvE2_sepBody_holds_of_honest`.
