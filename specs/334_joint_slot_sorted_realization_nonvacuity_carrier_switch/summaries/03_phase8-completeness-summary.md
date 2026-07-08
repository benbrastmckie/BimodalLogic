# Task 334 — Phase 8 Summary: Lemma 3.2(1) ⇐ (completeness) + singleton retreat retired

**Status**: COMPLETED (all plan acceptance criteria met). Final proof phase of the faithful
carrier re-grounding.

**File modified**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`

## What was proved

- **`kvE2_sepBody_complete`** (:1531) — the ⇐ (completeness) half of Lemma 3.2(1) (Rabinovich
  md:77), which the carrier previously lacked (grep-0 before this dispatch). For an honest model
  realization (`x < w < t`, `nf_eval_nf M 2 3 [w,x,t] qnf`) whose positive owners are all
  LEFT-interior, the honest **coincidence (tie)** arrangement `kvE2_sepCoincidentOrder` is a VALID,
  PRESENT member of the faithful carrier `kvE2_sepArr'`; hence `kvE2_sepArr' qnf ≠ []`
  unconditionally. This realizes F2 (⇐ direction, non-vacuous) as the multi-owner generalization of
  the retired singleton. Sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`.
- **`kvE2_sepCoincidentOwner_valid_left`** (:1450, Phase 8a) — per-owner honest validity: a
  left-interior owner's CLOSED self-zone bit at its own fresh type is forced true, via the preserved
  axiom-clean `kvE2_sepCoincidentAnchor_discharge`.
- **`kvE2_sepCoincidentAnchor_discharge_R`** (:1493, Phase 8b) — the RIGHT coincidence discharge
  (`kvE2_sepBits σ zAtX1R χ = true` at `w < x1 < t`), the mirror of the left discharge, routed
  through the same generic zone-forward channel `kvE2_sepHonestBundleR` uses. Sorry-free,
  axiom-clean.
- Support: `kvE2_sepCoincidentOrder` (:1425), `kvE2_sepCoincidentOrder_mem_orderTypes` (:1441).

## Singleton retreat REMOVED

`kvE2_sepSingleton`, `kvE2_sepBody_singleton`, `kvE2_sepBody_singleton_eq`,
`kvE2_sepBody_singleton_nonvacuous`, `kvE2_sepSingleton_neg_offFiber`, `kvE2_sepSingleton_neg_zone`,
`kvE2_sepBody_singleton_gate`, `kvE2_sepSingleton_coverage_left`,
`kvE2_sepSingleton_sound_of_parts_at`, `kvE2_sepBody_singleton_sound_left`,
`kvE2_sepBody_singleton_complete_left` — all DELETED, together with the two strategic sorries
(`@2270`/`@2408`). **grep-0** for `kvE2_sepSingleton` and `kvE2_sepBody_singleton`. No external
references existed (self-contained block).

## Key empirical finding (`lean_goal`-grounded)

The strict `kvE2_sepModelOrder` is **NOT honestly valid**: `kvE2_sepDisjValidOwner
.strictBefore/.strictAfter` read σ's OPEN `zXU`/`zUW` bit at σ's OWN fresh type `nf0_projFresh σ.1`.
At the self-coincidence (σ's fresh type is realized AT its own anchor `x1`), that OPEN bit is FALSE
while the CLOSED `zAtX1L` bit is TRUE — exactly the handoff-05 open-vs-closed discrimination
(SW:2360-2363). So the honestly-selected disjunct is the COINCIDENCE (tie) order, and
`kvE2_sepBody_complete` discharges the CORRECTED (coincident) honest-selection obligation. The
conditional `kvE2_sepBody_nonvacuous` (which threads
`hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) = true`) is left intact and unchanged, but
its `hvalid` about the STRICT order is not honestly attainable; unconditional non-vacuity now comes
from `kvE2_sepBody_complete`.

## Deviation (Phase 8b general right-interior)

The genuine mathematical content of the right half (the right coincidence discharge) is landed
sorry-free. But making `kvE2_sepArr'` non-vacuous for RIGHT-interior positive owners (`w<x1<t`)
requires the coincident validity channel `kvE2_sepDisjValidOwner .coincident` /
`kvE2_sepClosedLeafStub` to read the placement-generic self-zone (`zAtX1R` for right owners), which
is currently hardcoded to `zAtX1L` (:737, :2475). Extending that **preserved** Phase-1/2 predicate
is a carrier redefinition — the plan's own out-of-scope item (plan lines 417-419). Therefore
`kvE2_sepBody_complete` is stated over the LEFT-interior positive-owner class (`hL` hypothesis).
This is **not** a weakening to vacuity (F2 preserved); it is a scoped follow-up (a small
predicate-wiring extension consuming the already-proved right discharge — no new mathematics).

## Verification

- Module build `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`: **1013/1013
  green** (warnings only: deprecations + unused-variable linter).
- Real sorries in file: **0**. Vacuous defs: **0**. New axioms: **0**. Singleton grep: **0**.
- `lean_verify`: `kvE2_sepBody_complete`, `kvE2_sepCoincidentAnchor_discharge_R`, and (unchanged)
  `kvE2_sepBody_nonvacuous` all `[propext, Classical.choice, Quot.sound]`, **no `sorryAx`**.

## Faithfulness invariants

F2 (⇐ realized, non-vacuous — the whole point), F1 (QF point types via the preserved brick), F5
(closed vs open key discrimination — the crux), F6, and F3/F4/F7 all preserved. No preserved asset
modified (bundles L/R, `kvE2_sepArr'`, `kvE2_sepArr'_sound`, `kvE2_sepBody_nonvacuous`,
`kvE2_sepArr'_mem_modelOrder`, region lift, compat leaves, coincidence discharge — all intact).

## Follow-ups recorded

1. Placement-generic coincident validity channel (read `zAtX1R` for right-interior owners) + drop
   the `hL` hypothesis from `kvE2_sepBody_complete` — completes general right-interior non-vacuity.
2. (Pre-existing, Phase 9) outer-gate `kvE2_body` / `bracketEndChar_kvE2` assembly engine — separate
   downstream task.
