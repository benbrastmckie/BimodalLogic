# Task 352 Phase 4 Re-close Handoff (Past side) — 2026-07-12

Per-side handoff (H7 Past territory, re-dispatch to clear the Phase-4 BLOCKED record via the
shared reindex bridge). Session `sess_1783887769_cb5be4`. File owned:
`ExteriorNegationPastK.lean` (additive tail only).

## Status: **partial** — `_sound` GREEN, `_complete` newly BLOCKED (narrower obstruction)

The shared reindex bridge (`kvE_fiberPosOnShift`/`kvE_anchorBridge`, `ExteriorFiberK.lean`) FULLY
resolved the previously-blocked content layer for `kvE_extNegPast_sound`. `kvE_extNegPast_complete`
remains BLOCKED — but on a **different, narrower, precisely-isolated** obstruction than before (a
free-env → fixed-env transport in the (⇐) reconstruction), NOT the original "no bridge exists"
blocker (that IS resolved). No sorries, no vacuous defs. All frozen diffs EMPTY (incl.
`ExteriorFiberK.lean`).

## Decls landed this dispatch (green, sorry-free, axiom-clean)

All in `Bimodal.Metalogic.WeakCanonical.Kamp`, appended to `ExteriorNegationPastK.lean`:

**Generic descending `Since` chain device** (side-symmetric with Future
`kvE_futChainG`/`BuildG`/`DestructG`):
1. `kvE_pastChainG` — abstract `D`-guarded `Since` chain (`itemF`/`endF`/`D` parametric).
2. `kvE_pastChainBuildG` — chain construction via `kvE_pastMaxPick` (max-witness sort), generic
   `Q`/`hQF`/`huniq`.
3. `kvE_pastChainDestructG` — chain destruction (endpoint + `D`-uniform gap + per-item occurrences).

**Clause family** (content via the shift bridge — `kvE_fiberPosOnShift P` for disjunctions,
`P.existF 4 (renameNF rot5Fwd rot5Bwd s)` per-item; Rabinovich Cor 5.4(2) re-anchoring):
4. `kvE_pastGapD`, `kvE_pastRayD`, `kvE_pastRayForm`, `kvE_pastEnd`, `kvE_pastChain`,
   `kvE_pastPos`, `kvE_extNegPast`.

**Soundness helpers + `_sound`:**
5. `kvE_pastZoneBelow` (reachable local copy of the frozen private `kvE2_pastZone4_of_below`).
6. `kvE_pastCarry` — the full-fiber workhorse: any point in a zone over σ's anchors carries a
   positive fiber element (its canonical type `nf_characteristic`), pinned on-fiber via
   `nf_eval_nf0_cons_factor` + `nf_eval_unique` and zoned via `zoneHolds_unique`.
7. `kvE_extNegPast_sound` — **GREEN, sorry-free, `#print axioms = [propext, Classical.choice,
   Quot.sound]`**. Routes every interior content obligation through `kvE_fiberPosOnShift_correct`
   / `kvE_anchorBridge`; chain distinctness via `nf_eval_unique` at the FIXED anchor env.

Verification: scoped `lake build …ExteriorNegationPastK` GREEN (1022 jobs). `grep sorry` = 0.
Vacuous defs = 0. `git diff --stat` on `ExteriorFiberK`, the 7 frozen providers, `KampPrior`,
`ExteriorBracketK`, `PriorInterface`, `SharedWitness`, `NfEFold`, `ExteriorNegationPast`: EMPTY.
(The Future sibling's `ExteriorNegationK.lean` shows uncommitted edits — its own territory, left
untouched/unstaged by this dispatch.)

## Why `_sound` closed (the bridge working as designed)

`_sound` builds FROM a real exterior realizer `nf_eval M (k+1) 4 [x1,w,x,t] σ`. Its fold
(`nf_eval_nfk_iff_efold`) gives, for each positive fiber element `s`, a witness `v` with
`nf_eval (Fin.cons v [x1,w,x,t]) s`. At that `v` the shifted content channel holds via
`kvE_fiberPosOnShift_correct`, supplying env `= [x1,w,x,t]` and `p = v` at the fold-fresh index 0
(`kvE_anchorBridge`). The chain occurrence predicate is `Q s r := nf_eval (Fin.cons r [x1,w,x,t]) s`
(FIXED env), so distinctness holds by `nf_eval_unique`. Everything is pinned because the env comes
from the given realizer.

## BLOCKER — `kvE_extNegPast_complete` (⇐ reconstruction), precisely isolated

- **Obligation:** to contradict `hnorel : ∀ x1<x, ¬ nf_eval M (k+1) 4 [x1,w,x,t] σ`, the proof must
  build a σ-realizer at the FIXED env `[x1,w,x,t]` via `nf_eval_nfk_iff_efold.mpr`, whose fiber
  (⇐) half is `σ.2 sub = true → ∃ y, nf_eval M k 5 (Fin.cons y [x1,w,x,t]) sub`.
- **What content supplies:** `kvE_fiberPosOnShift_correct` + `kvE_pastChainDestructG` give a gap
  occurrence `∃ r∈(x1,x), ∃ env' : Fin 4 → M.carrier, nf_eval M k 5 (Fin.cons r env') sub` — the
  interior env `env'` is EXISTENTIALLY FREE (indices 1-4), NOT `[x1,w,x,t]`.
- **Empirically confirmed non-transport (lean type mismatch):** `nf_eval (Fin.cons r env') sub`
  does NOT close `nf_eval (Fin.cons r [x1,w,x,t]) sub` — `sub : NormalForm sig k 5` is arity-5 and
  env-dependent; `env'` need only realize σ.1 (the shared depth-0 char), and many distinct tuples
  realize the same depth-0 char in a general model, so `env'` is not pinned.
- **Why k=2 avoided it:** frozen `kvE2_extNegPast_complete` (⇐)
  (`ExteriorNegationPast.lean:1063-1104`) uses `nf_eval (fun _ => r) χ` with `χ : NormalForm sig 0 1`
  — ARITY-1, ENV-FREE (only the fresh point matters; `x1,w,x,t` unreferenced). Its above-`x` zones
  are outsourced to the gate hypotheses `habove`/`hbits`/`qnf` referencing only the FIXED `[w,x,t]`.
  At depth `k`, gap/ray/self subs reference the EXISTENTIAL endpoint `x1`, so neither internal
  env-free handling nor a fixed-anchor gate applies.
- **What is needed to unblock (concrete):** a free-env → fixed-env transport / anchor-coherence
  lemma proving the chain's gap occurrences (and the endpoint's self/ray content) share ONE anchor
  tuple that IS `[x1,w,x,t]` — a shared-witness argument pinning every occurrence's `env'` to the
  reconstructed endpoint anchors. Candidate home: a `SharedWitness`-style anchor-coherence lemma
  across the `Since` chain. This is a substantial NEW development, NOT the bridge and NOT a k=2
  mirror. Research report 02 rated exactly this "Medium confidence — reconstruction proof-work";
  Deliverable 3.3's "existential env is faithful" addresses the (⇒) index-0-free witness, not the
  (⇐) fixed-env obligation, which is the open item.
- **Symmetry note:** the Future sibling (`ExteriorNegationK.lean`) faces the IDENTICAL obstruction
  (its `_complete` is likewise unwritten). The transport/anchor-coherence lemma should be built
  SHARED (side-agnostic, like the bridge) so both `_complete`s consume it. Recommend the
  orchestrator spawn a focused research/implementation task on the shared anchor-coherence lemma
  BEFORE re-dispatching either side's `_complete`.
- **Prohibited (honored):** no `sorry`; no bare-assumption gate hypothesis merely positing
  `∃ y, nf_eval (Fin.cons y [x1,w,x,t]) sub` (a disguised stub — unlike k=2's `habove`
  biconditional it ties to no syntactic invariant); no vacuous placeholder.

## What the Past clause layer now EXPOSES (for Phase 5/6 + task 349 Phase 2)

CURRENTLY AVAILABLE (green, consumer-ready):
- Zone/admissibility (Phase 4.1): `kvE_pastPossibleZones`, `kvE_pastZoneClass`,
  `kvE_zoneHolds_of_atom`, `kvE_pastFreshProfile`, `kvE_pastAdmissible`,
  `kvE_pastRealizer_admissible`.
- Nav prep: `kvE_pastGapZone`/`RayZone`/`SelfZone` (+ `_mem`), `kvE_pastMaxPick`.
- Generic chain: `kvE_pastChainG`, `kvE_pastChainBuildG`, `kvE_pastChainDestructG`.
- Clause defs: `kvE_pastGapD`, `kvE_pastRayD`, `kvE_pastRayForm`, `kvE_pastEnd`, `kvE_pastChain`,
  `kvE_pastPos`, `kvE_extNegPast` (all `noncomputable def`, `{sig}{atomMap}{k}`, `P : ExistProviders
  sig atomMap k`, `σ : NormalForm sig (k+1) 4`).
- Helpers: `kvE_pastZoneBelow`, `kvE_pastCarry` (private).
- **`kvE_extNegPast_sound`** — signature:
  `(P : ExistProviders sig atomMap k) (M) (h_UZ : semantic_prior_UZ M atomMap)
   (h_SZ : semantic_prior_SZ M atomMap) (σ : NormalForm sig (k+1) 4) (w x t : M.carrier)
   (hxw : x < w) (hwt : w < t) (hcl : temporal_truth M atomMap x (kvE_extNegPast P σ)) :
   ∀ x1, x1 < x → ¬ nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`.

STILL OWED (blocked): `kvE_extNegPast_complete` — signature TBD once the anchor-coherence lemma
lands (expected to mirror `kvE_extNegPast_sound`'s `P`/`M`/`h_UZ`/`h_SZ`/`σ`/`w`/`x`/`t`/order-bit
header, with `hnorel : ∀ x1<x, ¬ nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` and possibly a shared
anchor-coherence input, concluding `temporal_truth M atomMap x (kvE_extNegPast P σ)`).
Task 349 Phase 2's Past re-dispatch (`kvE_extNegPast` + `_sound` + `_complete` + `kvE_pastPos`)
can consume `_sound` + `kvE_pastPos`/`kvE_extNegPast` now; `_complete` must wait.

## Sorry Inventory

`[]` (empty — no sorries, no vacuous defs; the `_complete` obstruction was escalated, not stubbed).
