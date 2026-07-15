# Task 358 v07 Phase 4 handoff — 368 ambient-guard pin + re-probe gate + bridge finding (2026-07-14)

Session: sess_1784078566_52d1da

## Status: PARTIAL / BLOCKED (general-`m` exterior supply)

Pin + re-probe gate GREEN; m = 0 rows-12-13 arms LANDED sorry-free; general-`m` exterior supply
BLOCKED on a Phase-4/Phase-5 wave inversion (see Bridge Finding).

## Re-probe gate: GREEN

Representative certificates `lean_verify` at floor axioms `[propext, Classical.choice, Quot.sound]`,
no sorryAx:
- 368: `kvE_probe368_cmA_ambient_rejected`, `_cmB_ambient_rejected`, `_real_ambient_anchored`,
  `_depth2_ambient_rejected`, `_ambient_copyPlant_collapses`, `_ambient_supply_route` (6/9 sampled;
  uniform family, tree at 368 terminus green).
- 367: `kvE_probe367_tailDG_deep_rejected`, `_copyPlant_collapses`.
Kamp-path sorries: exactly `KampPrior.lean:519` and `:522` (grep-confirmed). Rows 8-9 binders carry
NO `kvE_ambientDeepAnchor` antecedent — Phase-3 landing UNAFFECTED (confirmed against gate_match).

## Pinned interface (v07, post-368) — byte-stable, consume by name

- `kvE_ambientDeepAnchor` (ExteriorAmbientDeepAnchorK.lean:109) + `_zero` (:125, rfl) /
  `_iff` (:131, ∀τ∀ρ∃σ' EF-closure readback) / `_of_realized` (:195, PRODUCE guard=true from a
  realizer at GENERAL `OrderedMonadicStructure`).
- `kvE_deepOnFiber_of_realized` (ExteriorFiberDeepAnchorK.lean:141) — needs BOTH `nf_eval_nf M (k+1) n env qnf`
  AND `nf_eval_nf M k (n+1) (cons x1 env) σ`; deep arm yields σ as its own mate.
- `kvE_deepOnFiber_zero` (:94, `kvE_deepOnFiber qnf σ = decide (nfk_dropFresh σ = qnf.1)`, rfl).
- Six ambient-guarded binders: `EndIntervalCorrectPrior` rows (EndIntervalConsumerK.lean:130/137/172/179/191/198)
  mirrored in `kampPrior_site_rungK_gate_match` (KampPrior.lean:964/971/1003/1010/1017/1024) and
  `bracketEndChar_kvExt_correct_prior`. Each rows-5/6/10-13 binder LEADS with
  `kvE_ambientDeepAnchor qnf = true →`.
- Gate carrier: `kvE_ambientGuardForm` (ExteriorGateAssembleK.lean:127) + `_truth` (:134);
  `bracketEndChar_kvExt` (:154, guard conjoined via second `enrichEndpoints`).
- Atom-render helper: `kvExt_gate_henv` (ExteriorGateAssembleK.lean:61) — from igPtW eval →
  `nf_eval_nf M 0 3 [w,x,t] qnf.1` (ATOM LAYER ONLY).
- Frozen m=0: `kvE_hexclSliceFut_supply_zero` (ExteriorPinnedConverseK.lean:1250) /
  `kvE_futSliceUnique_zero` (:1122); Past `_zero` mirrors (ExteriorPinnedConversePastK.lean:769/:356).

## Target signatures (general-`k`, binder-shape-exact) — for the follow-up

Params common to all four: `{sig} {atomMap} (k) (h_surj) (charF) (M) (qnf : NormalForm sig (k+2) 3) (x t)`
(rows 10-11/12-13 do NOT reference `Pbr`/`kvE_futPos`). Body = the gate_match binder verbatim.

- **Rows 12-13** `kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply` (LANDED, skeleton):
  `kvE_ambientDeepAnchor qnf = true → ∀ w, x<w → w<t → igPtW….eval_at M atomMap w →
   ∀ σ : NF (k+1) 4, kvE_{fut,past}Admissible σ = true → qnf.2 σ = false →
   nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
   ∀ x1, (t<x1 | x1<x) → ¬ nf_eval_nf M (k+1) 4 (cons x1 (cons w (cons x (fun _=>t)))) σ`.
- **Rows 10-11** `kvE_hexclSliceFut_supply` / `kvE_hexclSlicePast_supply` (NOT landed):
  as rows 12-13 but with `qnf.2 σ = false → kvE_{fut,past}SliceMarked qnf σ = true →` in place of
  `nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false`. Route: carried `hreal` + G2-B2 uniqueness.
- **G2-B2** `kvE_futSliceUnique` / `kvE_pastSliceUnique` (NOT landed): general-m over the
  ambient-guarded + deep-anchored population; both σ's pinned over the SAME realized ambient tail.

## Bridge Finding (BLOCKER — Phase-4/Phase-5 wave inversion)

The rows-12-13 (and 10-11, and uniqueness) general-`m` discharge requires the FULL deep ambient
realization `nf_eval_nf M (k+2) 3 [w,x,t] qnf` at the binder site. Machine evidence:
- igPtW renders ONLY the atom layer `qnf.1` (`kvExt_gate_henv`); the deep quant layer
  `qnf.2 : ∀ sub, (∃ x1, nf_eval_nf … sub) ↔ qnf.2 sub = true` is NOT recoverable from
  `hAmb : kvE_ambientDeepAnchor qnf = true` (a syntactic `Bool`, no model `M`) + igPtW.
- The contradiction engine `kvE_deepOnFiber_of_realized` / `hqnf.2 σ` both need that deep layer.
- The deep ambient is exactly what the INTERIOR realizer `kampPrior_hreal_supply` (Phase 5) +
  `kampPrior_hexcl_supply` (Phase 6) reconstruct from `P.correct` + fold bit + `hAmb` EF-closure.

So the plan's Wave DAG (Phase 5 depends on Phase 4) is inverted for the exterior supplies. CM-A/CM-B
exclusion makes the render SOUND but not CONSTRUCTIBLE from the Phase-4-local hypotheses alone.

## Recommended next action

1. `/revise 358`: re-order so the Phase-5 interior ambient render (a shared
   `igPtW + hAmb + P → nf_eval_nf M (k+2) 3 [w,x,t] qnf` render lemma) lands FIRST, then discharge
   the general-`m` arms of rows 12-13 via `kvE_deepOnFiber_of_realized`, then G2-B2 uniqueness, then
   rows 10-11. OR `/spawn 358` an isolated ambient-render-bridge task.
2. The landed skeleton `ExteriorDeepExclSupplyK.lean` already type-checks the exact rows-12-13
   target signatures against the binder shapes and discharges m = 0 sorry-free — the follow-up only
   fills the two general-`m` arms once the render lemma exists.

## sorry_inventory (this dispatch)

- `ExteriorDeepExclSupplyK.lean` `kvE_hexclDeepFut_supply` (j+1 arm) — assumes deep ambient render;
  deferred on Phase-5 interior realizer; follow_up: task 358 Phase 5.
- `ExteriorDeepExclSupplyK.lean` `kvE_hexclDeepPast_supply` (j+1 arm) — Past mirror; same follow-up.
- Pre-existing (untouched): `KampPrior.lean:519` (k≥2 residual), `:522` (arity-lift) — task 358 Phase 7/8.
