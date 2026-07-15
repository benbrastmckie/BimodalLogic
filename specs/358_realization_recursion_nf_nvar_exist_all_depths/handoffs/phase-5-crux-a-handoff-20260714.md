# Task 358 Phase 5 (Crux A) handoff — `kampPrior_hreal_supply` statement landed, body strategic-sorried (2026-07-14)

Session: sess_1784078566_52d1da

## Status: PARTIAL (statement green, body = 1 tracked strategic sorry). Clean, well-diagnosed.

Unlike the prior v08 render-adjudication dispatch (which left the tree byte-identical to Phase 4),
this dispatch LANDS a concrete, correctly-typed, reusable lemma and pins the exact residual with a
machine-confirmed circularity witness.

## Immediate Next Action

Build a non-circular firing transducer `igFoldBit qnf zs χ = true → temporal_truth M atomMap
{t|x} (kvE_{fut,past}Pos P σ)` that routes through the depth-`k` recursion IH bundled in `P`
WITHOUT `igFoldBit_realize_iff`. If no such route exists, re-sequence (per the v08
render-adjudication) to produce Crux A `hreal` + Crux B `hexcl` + the render JOINTLY at the pinned
exterior tuple `[w,x,t]`. `/spawn 358` or `/revise 358` before the next Phase-5 attempt.

## Current State

- NEW leaf `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorHrealSupplyK.lean`
  (downstream of `KampPrior`; deliberately NOT added to the `NfMultiAnchorBridge` aggregator to
  avoid an import cycle — it is still built by the default `lake build`).
- `kampPrior_hreal_supply` conclusion matches the row-5 `hreal` binder (`KampPrior.lean:964-970`)
  verbatim. Ambient premises: `k, atomMap, h_surj, charF, P : ExistProviders sig atomMap k, M,
  h_UZ, h_SZ, qnf : NormalForm sig (k+2) 3, x t` — the engine seam the drivers consume; `P`
  bundles the depth-`k` recursion IH via `kampPrior_existProviders_of_ih`.
- Full `lake build` green (1761 jobs). `lean_verify` = `[propext, sorryAx, Classical.choice,
  Quot.sound]`. Frozen boundary clean (only the new leaf touches `Theories/`; zero vacuous defs,
  zero new axioms).
- Phases 1-4 preserved; all frozen m=0 supplies, guard/probe modules, Phase-3
  (`ExteriorDeepSliceSupplyK`) and Phase-4 (`ExteriorDeepExclSupplyK`) leaves UNTOUCHED.

## Key Decision / Root-Cause Diagnosis (machine-confirmed)

The v09 plan's firing route ("fold bit fires `kvE_{fut,past}Pos (Pbr) σ`; drivers select `x1`")
is **CIRCULAR**:

1. The row-5 binder exposes only `(igPtW … (igFoldBit qnf)).eval_at M atomMap w` — pinning `w`'s
   y-type and the `igZAtW`-zone content only (`igPtW` def `InteriorGateGeneralK.lean:243`). The
   fut-T / past-X endpoint firings the exterior drivers `kampPrior_{fut,past}Realizer_of_pos`
   (`KampPrior.lean:1662/1721`) consume live in `igEpR`@t / `igEpL`@x — ABSENT from this binder.
2. The global `igFoldBit qnf` carries all zones syntactically, but the ONLY landed bridge from a
   fold bit to a model realizer, `igFoldBit_realize_iff` (`InteriorGateGeneralK.lean:563`),
   REQUIRES `h : nf_eval_nf M (k+1) 3 [w,x,t] qnf` as a hypothesis. For `qnf : NormalForm sig
   (k+2) 3` that is `nf_eval_nf M (k+2) 3 [w,x,t] qnf` — EXACTLY the deep ambient render that
   `hreal` (this lemma, with `hexcl`) PRODUCES downstream (`bracketEndChar_kv_step_sound …
   (hreal hGuard) (hexcl hGuard)`, `ExteriorGateAssembleK.lean:337-338`). Hence firing via this
   bridge consumes the render `hreal` is upstream of — circular.
3. `kvE_ambientDeepAnchor_iff` (`ExteriorAmbientDeepAnchorK.lean:131`) unfolds the guard to a
   purely SYNTACTIC EF-closure `∀τ marked ∀ρ deep ∃σ' marked, σ'.2(swapNF01 ρ)` — no `M`, no
   carrier, no `temporal_truth`; it cannot produce the model-carrier witness (confirms the prior
   BLOCKED finding at the specific binder).

The task-363 antecedent `kvE_fiberConsistent σ = true` (in the row-5 binder) is what makes a TRUE
supply possible — it excludes the projection-invisible doppelgänger fakes that
`ExteriorPinnedProbeM1K.lean:628-669` proved refute a naive supply. It is threaded and available
for the eventual (non-circular) discharge.

## Why this is upstream of the Phase-4 sorries

`ExteriorDeepExclSupplyK.lean:105/133` (`kvE_hexclDeep{Fut,Past}_supply` general-`m` arms) each
depend on the Phase-5 render; those remain UNTOUCHED. They can now cite `kampPrior_hreal_supply`
by name once its body lands.

## sorry_inventory

See `.orchestrator-handoff.json`. New: `InteriorHrealSupplyK.lean:116` (strategic, this dispatch).
Unchanged: `ExteriorDeepExclSupplyK.lean:105/133`, `KampPrior.lean:519`.

## Frozen-boundary audit

`git status --short -- Theories/` shows ONLY `?? …/InteriorHrealSupplyK.lean`. No frozen file
modified. `lean_verify` floor axioms + localized `sorryAx`.
