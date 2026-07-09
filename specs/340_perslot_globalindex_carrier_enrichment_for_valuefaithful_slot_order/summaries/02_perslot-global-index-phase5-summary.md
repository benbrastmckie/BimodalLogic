# Task 340 Phase 5 — Implementation Summary (COMPLETED)

- **Task**: 340 - Per-slot global-index carrier enrichment for value-faithful slot order
- **Phase**: 5 (model-dependent selection/aggregation lemma over the existing carrier)
- **Status**: [COMPLETED] — 5A-5D built against the settled design-gate layout, sorry-0, axiom-clean
- **Session**: sess_1783561356_89aa2d_340 (dispatches 1-2 + this completing dispatch)
- **Date**: 2026-07-08
- **File**: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean

## COMPLETED — 5A-5D honest value-rank construction (settled layout, report 06)

The design gate (report 06, PASS) dissolved the coinciding-anchor "fork": two DISTINCT positive
owners provably cannot share a fresh anchor (`kvE2_sepPos` is `Nodup`; `nf_eval_unique` forces
equal-anchor ⟹ equal-owner). There is a SINGLE honest order — value-rank owner blocks with
`.coincident` tags. Four green, sorry-0, axiom-clean (`{propext, Classical.choice, Quot.sound}`)
milestones, each committed:

- **5A keystone** — `kvE2_sepAnchorVal` (+ `_spec`), `kvE2_sepAnchor_injOn` (the keystone: distinct
  owners ⟹ distinct anchors via `nf_eval_unique`), `kvE2_sepAnchorFam` + `kvE2_sepAnchorFam_injective`
  (`List.get` on the `Nodup` spine + keystone → injective anchor family).
- **5B honest order + membership** — `kvE2_sepHonestTuple` `(3r,3r+1,3r+2)` (+ `_consistent`),
  `kvE2_sepHonestOrder` (all `.coincident`), `kvE2_sepHonestOrder_mem_orderTypes`, and
  `kvE2_sepHonestOrder_mem_arr'` — the carrier member task 337 consumes. Membership is
  tuple-agnostic: tag validators (`kvE2_sepCoincidentOwner_valid_left/right`) reused VERBATIM;
  consistency by `omega`; `i₀`-Nodup via `kvE2_ordRank_injective` on the keystone-injective family.
- **5C value-faithful monotonicity** — `kvE2_sepHonest_rank_strictMono`, `kvE2_sepHonest_cross_region`
  (`i₂(σ)=3r_σ+2 < 3r_τ+1=i₁(τ)` from `x1_σ<x1_τ` via `kvE2_ordRank_strictMono` — the `a<u'<b`
  cross-region disjunct task 339 dropped, now expressible under value-ranked indices),
  `kvE2_sepHonest_same_owner_mono` (`i₀<i₁<i₂`).
- **5D engine hand-off** — `kvE2_sepBody_complete_holds` wires the 5B carrier member into
  `kvE2_sepBody_holds_iff.mpr`, taking the single 337-owned `.holds` (`kvE_subBracket2V_sound_of_parts`
  over the regions bundle fed to `k1v_sorted_realizationK`) as the delegated hypothesis. Plus public
  `kvE2_sepHonestAnchorBundleL/R` exposing per-owner `hnd`/`hreal` realizer data at the value-ranked
  `kvE2_sepAnchorVal` anchors (the `k1v_sorted_realizationK` inputs).

**Verification**: full project `lake build` green (1720 jobs); `sorry_count = 0`, `vacuous = 0`,
new axioms `= 0`; axiom set `{propext, Classical.choice, Quot.sound}` on all 5A-5D key theorems.
Remaining repo sorries are all in `Theories/Bimodal/Boneyard/` (archived, not built by default,
out of scope). `kvE2_sepCoincidentOrder` and all Phase 1-4/6 assets untouched.

**Delegated boundary (task 337)**: the honest disjunct's `.holds` — the regions realization incl.
any meet-type folding of a foreign witness onto an anchor (report 06 R3) — is a realization-layer
step, NOT a carrier change. Per the dispatch instruction, delivering the complete axiom-clean bundle
up to this single delegated `.holds` is a valid Phase-5 completion.

## Historical — dispatches 1-2 (superseded by the completion above)

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
