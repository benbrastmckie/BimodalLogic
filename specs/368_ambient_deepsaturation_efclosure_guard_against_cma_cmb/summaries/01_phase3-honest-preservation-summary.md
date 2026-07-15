# Task 368 — Phase 3 Execution Summary

**Phase**: 3 of 6 — Honest-preservation crux + readback at probe level
**Status**: COMPLETED (implemented, no skeleton, zero sorries)
**Commit**: `9b8478bc3`
**File touched (probe-only)**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` (+157 lines)

## Deliverables landed

1. **`kvE_ambientDeepAnchorV0_of_realized`** — honest-preservation crux at a GENERAL
   `OrderedMonadicStructure`/env. `match` on the grading index: `k = 0` arm is `rfl`-inert;
   `k + 1` arm routes through `_iff`. Realization supplies fresh points `x1` (τ realized at
   `cons x1 env`) and `x2` (ρ realized at `cons x2 (cons x1 env)`); `nf_eval_unique` gives
   `ρ = char (cons x2 (cons x1 env))`, so `swapNF01 ρ = char (cons x1 (cons x2 env))`
   (`swapNF01_char` + new general env-swap identity `cons2_comp_swap01`). The fresh-rotation
   mate `σ' := char (cons x2 env)` is qnf-marked at `x2` (clause i) and covers `swapNF01 ρ`
   at `x1` (clause ii). Fully general — no countermodel obstructs.
2. **`kvE_ambientDeepAnchorV0_iff`** — deep-arm (`k ≥ 1`) readback: `guard = true ↔`
   ∀-marked-sub / ∀-marked-deep / ∃-marked-mate closure. The ONLY sanctioned
   extraction/witness direction (mirrors `kvE_deepOnFiber_iff`).
3. **Gate 3a `kvE_probe368_real_ambient_anchored`** — the REAL ambient
   `nf_characteristic MB 3 3 mBreal3` (char over anchors `[5, 2, 30]`) passes the guard,
   derived FROM `_of_realized` + `nf_characteristic_satisfies` (one line, not by
   computation). Anti-vacuity guarantee.
4. **Gate 3b `kvE_probe368_ambient_supply_route`** — the discharge shape task 358's re-keyed
   supply consumes: `(_iff qnf).mp (_of_realized M env qnf hqnf)`. Trueness via `_of_realized`
   alone, extraction via `_iff` alone, zero guard unfoldings.

Supporting: `cons2_comp_swap01` (general env-swap identity, proved by `Fin.cases` ×2 using
`Fin.cons_one` / `Fin.succ_zero_eq_one'` / `Equiv.swap_apply_*` — no `fin_cases`, arity `n`
arbitrary).

## Adjudication checkpoint

NOT triggered. `_of_realized` was dischargeable for the Phase-2 candidate shape as-is at a
general model. **Zero redesign loops consumed.**

## Verification

- Scoped `lake build` green (1025 jobs).
- `lean_verify` on all four deliverables: `[propext, Classical.choice, Quot.sound]`, no sorryAx.
- Sorry count 0; vacuous-def count 0; new-axiom count 0.
- Guard-unfold source scan clean: Phase-3 additions unfold nothing. The only `show … from rfl`
  hits are the pre-existing Phase-2 gates 2a/2b inside the module that DEFINES
  `kvE_ambientDeepAnchorV0` (the sanctioned home-module pattern, same as `kvE_deepOnFiber_iff`).
- `git diff --stat -- Theories/` = probe leaf only; PRESERVE clause intact; no production file
  touched.

## Next

Phase 4 (probe-only): adversarial re-plant probes on the ambient side (depth-2 hereditary
doppelganger + copy-plant), churn cap ONE redesign. All Phase-4 certificates consume the guard
through `kvE_ambientDeepAnchorV0_iff`; the guard is never unfolded.
