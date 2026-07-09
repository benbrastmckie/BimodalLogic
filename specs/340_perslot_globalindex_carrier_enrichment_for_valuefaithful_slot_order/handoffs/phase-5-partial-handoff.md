# Task 340 Phase 5 — Partial Handoff (sess_1783561356_89aa2d_340)

## Immediate Next Action

Re-dispatch task 340 Phase 5 (continuation). Build the honest-order M-value sort construction
(steps 1-6 below). Run A = steps 1-5 (selection + membership + monotonicity, green); Run B =
step 6 (bundle export, green). Only after both are green, dispatch task 337.

## Current State

- Phases 1-4 + Phase-6 verification: COMPLETE (green, sorry-0, axiom-clean), unchanged.
- Phase 5.1 objective 1: `kvE2_sepIdxTuple_mem_of_lt` DELIVERED (SW:749-763), green, sorry-0,
  axiom-clean `{propext, Quot.sound}`, committed (`task 340 phase 5.1: ...`).
- Scoped build `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`: green (1013 jobs).
- Sorry count: 0. Vacuous defs: 0. New axioms: 0.
- Remaining Phase-5 work: honest-order selection def + membership + monotonicity + bundle export.

## What Was Delivered

`kvE2_sepIdxTuple_mem_of_lt (n a b c : ℕ) (ha : a < 3*n) (hb : b < 3*n) (hc : c < 3*n) :
(a, b, c) ∈ kvE2_sepIdxTuples n` — the enumeration-richness lemma (5.1 first bullet). Strict
generalization of `kvE2_sepPlaceholderTuple_mem` (SW:740) from the region-primary placeholder
`(k, n+k, 2n+k)` to an arbitrary in-range tuple. This is precisely the membership fact the
honest-order tuple needs: every one of an owner's three slots' global positions is `< 3n`.

## Key Decision

The honest-order construction is ONE INDIVISIBLE model-dependent build, not a set of small
independent lemmas. Both membership conjuncts (`i0<i1<i2` per owner; `i0`-Nodup cross-owner) and
monotonicity all reduce to the sortedness/injectivity spec of a single sort of the 3n slot
M-values by M's `LinearOrder`. A non-faithful shortcut tuple (e.g. `(3j,3j+1,3j+2)`) was
REJECTED: it re-introduces exactly the 339 region-primary defect and makes the `a<u'<b`
monotonicity case unprovable. No `sorry`/vacuous placeholder was inserted; the file is left green.

## Concrete Remaining Construction (steps 1-6)

1. `kvE2_sepHonestSlotVals qnf M w x t : List (KvE2SepSlot sig × M.carrier)` — per owner
   σ ∈ `kvE2_sepPos qnf`, per region rank r∈{0,1,2}, a witness M-value: anchor `x1_σ` for r=1
   (via `(h_quant σ).mpr hb`); an `(x,x1_σ)`/`(x1_σ,w)` point for r=0/2 from
   `kvE2_sepHonestBundleL`/`kvE2_sepHonestBundleR` (SW:1471 / SW:1523). Uses `Classical.choose`
   over the honest-bundle existentials.
2. `kvE2_sepHonestGIdx` = argsort of the 3n values by M's `LinearOrder`; global index = rank.
   `M.carrier` has `LinearOrder` → `List.mergeSort` + rank read.
3. `kvE2_sepHonestOrder` tuple for σ = `(gidx(σ,0), gidx(σ,1), gidx(σ,2))`; all tags `.coincident`
   (reuse `kvE2_sepCoincidentOwner_valid_left`/`_right`, SW:1703 / SW:1777, for validity (i)).
4. Membership `kvE2_sepHonestOrder_mem_arr'` (B): (i) coincidence validity reused verbatim from
   `kvE2_sepCoincidentOrder_mem_arr'` (SW:1881); (ii) `i0<i1<i2` from
   `x<val(σ,0)<x1_σ<val(σ,2)<w` ⟹ ranks ordered (sort monotone); (iii) `i0`-Nodup from distinct
   anchors ⟹ distinct r=0 vals ⟹ distinct ranks (sort injective on distinct values).
   Enumeration membership via `kvE2_sepIdxTuple_mem_of_lt` (all ranks `< 3n`).
5. Monotonicity `kvE2_sepHonestOrder_monotone` (C): `kvE2_sepSlotsLOf/ROf` (mergeSort by
   `kvE2_sepSlotGIdx`, SW:940) reproduces M-value order; `a<u'<b` falls out because
   `val(σ,r=2) < x1_τ ⟹ gidx(σ,2) < gidx(τ,1)`.
6. Bundle (5.2): `regions` = consecutive-anchor intervals over the sorted values;
   `hpos/hlink/hnd/hreal` for `k1v_sorted_realizationK` (SubBracket2V.lean:633-646), `hreal`
   from the honest bundles. Bracket-independent hand-off object to 337.

## Sorry Inventory

Empty (`[]`). No sorries introduced or outstanding in delivered scope.

## Interface to 337

Task 337 remains BLOCKED on 340 Phase 5. The engine-precondition bundle (step 6) is NOT yet
delivered. Once delivered, 337 consumes it → `k1v_sorted_realizationK` → `.holds` via
`kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1025) → closes `kvE2_sepBody_holds_iff.mpr`.
