# Task 352 Phase 4.2/4.3 Handoff (Past side) — 2026-07-12

Per-side handoff (Wave 4/5, H7 Past territory). NOT the shared `.orchestrator-handoff.json`.
Session `sess_1783887769_cb5be4`. File owned: `ExteriorNegationPastK.lean` (additive tail only).

## Status

**partial / BLOCKED** — the chain-assembly NAVIGATION prep landed green (commit `79edf5320`);
the CONTENT-bearing clause layer (`kvE_pastGapD/RayD/RayForm/End/Chain/Pos/extNegPast` +
`_sound`/`_complete`) is **BLOCKED** on an unresolved semantic-design question (the full-fiber
env-pin shape). Marked `[BLOCKED]` in the plan with a full BLOCKER block. No sorries, no vacuous
defs landed. Frozen diffs EMPTY (incl. `ExteriorFiberK.lean`).

## Decls landed this dispatch (green, sorry-free, axiom-clean)

All in `Bimodal.Metalogic.WeakCanonical.Kamp`, appended to `ExteriorNegationPastK.lean`:

1. `kvE_pastGapZone : ZoneSpec 4 := Fin.cons (false, true) kvE2_sep_zPastX3` — gap `(x1, x)`.
2. `kvE_pastRayZone : ZoneSpec 4 := Fin.cons (true, false) kvE2_sep_zPastX3` — ray `(−∞, x1)`.
3. `kvE_pastSelfZone : ZoneSpec 4 := Fin.cons (false, false) kvE2_sep_zPastX3` — self point `x1`.
4. `kvE_pastGapZone_mem` / `kvE_pastSelfZone_mem` / `kvE_pastRayZone_mem` — each zone is one of
   the nine `kvE_pastPossibleZones` (indices 6/7/8).
5. `kvE_pastMaxPick` — `{α : Type}`-generic descending maximal-witness pick (past-side
   counterpart of the shared ascending `kvE_minPick`, `ExteriorFiberK.lean:263`; the shared
   file deliberately exposed only `kvE_minPick`). Byte-identical template of the frozen private
   `kvE2_pastMaxPick` (`ExteriorNegationPast.lean:484`). Consumed by any past chain-build design
   (past walks the gap top-down → maximal extraction).

Verification: scoped `lake build …ExteriorNegationPastK` GREEN (1021 jobs). `grep sorry` = 0.
Vacuous defs = 0. `#print axioms`: `kvE_pastMaxPick` = `[propext, Classical.choice, Quot.sound]`;
the three `_mem` = `[propext]` (subset). `git diff --stat` on all 7 frozen providers + KampPrior
+ ExteriorNegation(Past) + ExteriorBracketK + ExteriorFiberK + PriorInterface: EMPTY.

## BLOCKER — content-bearing clause layer (Phase 4.2/4.3)

**Root cause (source-grounded, from two landed lemma statements — not speculation):**

The depth-`k` full-fiber content channel and the fixed-environment realizer use INCOMPATIBLE
anchor conventions, with no landed bridge:

- `kvE_fiberPos_correct` / `kvE_fiberPosOn_correct` (`ExteriorFiberK.lean:91-130`): the only
  G6-permitted content rendering `kvE_fiberPosOn P l` at a point `p` is
  `∃ env : Fin 4 → M.carrier, nf_eval_nf M k 5 (insertEnv env p) s` — the four non-anchor points
  are EXISTENTIALLY FREE, `p` sits at the LAST anchor (index 4, `insertEnv`,
  `NfDepth0Generalized.lean:42`).
- `nf_eval_nfk_iff_efold` (`NfEFold.lean:627`, `nf_eval_efold_k` :608): σ's realizer pins each
  positive fiber element over the FIXED env `Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x
  (fun _ => t))))` — fresh witness `v` at index 0.
- Reconciliation: `insertEnv [v,x1,w,x] t = Fin.cons v [x1,w,x,t]` holds definitionally, so
  content anchors at `t` with `env[0]=v`. BUT `env` is existentially free, so `P.existF 4 s` at
  `t` asserts only "s realizable at `t` with SOME 4 points", NOT "with the actual `[x1,w,x]`".
- Consequence: the frozen Since-chain's evaluate-content-AT-the-walked-gap-point mechanism
  (`nf_depth0_char_formula χ` pinning that point's marginal profile,
  `ExteriorNegationPast.lean:454`) does NOT transfer. Depth-`k` (F2 obstruction, G6) forbids
  marginal content; the only full-fiber channel (`P.existF`) cannot say "this gap point realizes
  sub `s`". A different clause architecture (content-at-`t` + zone-navigated env pin) is required.
- No re-anchoring / anchor-permutation NormalForm operation exists (grep empty).

**Why this is the deferred research ruling, not an implementation miss:** The frozen k=2 layer
pins the free env via `qnf`/`hbase`/`hbits`/`habove` (`ExteriorNegationPast.lean:855-872`). The
depth-`k` analog is the "full-fiber pin" the plan (Phase 3.3/4.3) and 4.1 handoff (lines 108-111)
explicitly flagged as an open ruling: `kvE_futAnyBit_correct` is "necessary-but-not-sufficient
scaffolding, not the hypothesis itself". 3.1 and 4.1 both DEFERRED the clause-form defs for
exactly this reason (see 3.1 handoff "Deferred" section; 4.1 handoff §"What 4.2/4.3 consumes").

**What is needed to unblock:** Resolve the full-fiber env-pin shape — a bundle/lemma tying
`P.existF`'s free anchor env to the fixed `[x1,w,x,t]` via zone navigation. The navigation half
exists (`kvE_fiberBucket_nonempty_iff`, `ExteriorFiberK.lean:203`, ties a bucket element to a
point `v` in a given zone with a given fresh profile); the MISSING half is the content-env pin.
This MUST be symmetrized with the Future side (Phase 3.2/3.3, concurrently built, H7-locked) so
both expose the same pin contract for Phase 5 / task 349 — a unilateral Past-only pin would
re-introduce the cross-side divergence the 4.1 handoff already flagged.

**Recommended orchestrator action:** Before re-dispatching 4.2/4.3, coordinate the pin design
across BOTH sides (or spawn a short research task on the pin shape). If the Future side (3.2/3.3)
has already settled a pin contract, re-dispatch Past 4.2/4.3 to mirror it byte-for-byte; the
navigation prep landed here (`kvE_pastGapZone/RayZone/SelfZone`, `_mem`, `kvE_pastMaxPick`) is
ready to consume it.

## What Phase 5/6 (final assembly) consumes from the Past clause layer

- CURRENTLY AVAILABLE: the full Phase-4.1 zone/admissibility layer (`kvE_pastPossibleZones`,
  `kvE_pastZoneClass`, `kvE_zoneHolds_of_atom`, `kvE_pastFreshProfile`, `kvE_pastAdmissible`,
  `kvE_pastRealizer_admissible`) + this dispatch's chain-assembly nav constants
  (`kvE_pastGapZone/RayZone/SelfZone` + `_mem`) + `kvE_pastMaxPick`.
- STILL OWED (blocked): `kvE_pastPos`/`kvE_extNegPast` + `_sound`/`_complete`, in consumer-ready
  form, once the pin shape is settled. Phase 5's interface bundle and task 349's re-dispatch
  cannot be built for the Past side until these land.

## Sorry Inventory

`[]` (empty — no sorries, no vacuous defs; the blocked work was escalated, not stubbed).

## Cross-side note (unchanged from 4.1, still open)

Past 4.1 landed 3-conjunct order-admissibility; Future 3.1 kept a 4th self-zone-uniqueness
conjunct. Orchestrator to reconcile before Phase 5 (independent of the pin blocker above, but
both are cross-side contract items to settle together).

## References

- Plan: `specs/352_.../plans/01_depthk-clause-layer.md` (Phase 4 section — now `[BLOCKED]` with
  full BLOCKER block).
- Content channel: `ExteriorFiberK.lean:70-130` (`kvE_fiberPosOn`/`_correct`, `kvE_fiberPos`/
  `_correct`), :203 (`kvE_fiberBucket_nonempty_iff`), :237 (`kvE_fiberZoneList`), :263
  (`kvE_minPick`). Fold bridge: `NfEFold.lean:627` (`nf_eval_nfk_iff_efold`), :608
  (`nf_eval_efold_k`). Anchor convention: `NfDepth0Generalized.lean:42` (`insertEnv`).
- Frozen template (read-only, content-swap NOT byte-identical): `ExteriorNegationPast.lean`
  :410-477 (clause defs), :518/:806 (chain build/destruct), :581 (`_sound`), :855 (`_complete`),
  :855-872 (the k=2 env-pin hypotheses the depth-`k` pin must generalize).
