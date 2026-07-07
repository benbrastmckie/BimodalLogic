# Task 309 Phase 12 Summary — Depth-k V-Carrier Definition `bracketEndChar_kv` (R3a)

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Phase**: 12 of plan v5 (`plans/05_offdiag-fi-chain-plan.md`) — single-phase hard-mode dispatch
- **Date**: 2026-07-06
- **Session**: sess_1783391112_643ec1
- **Status**: [COMPLETED]

## What Was Built

All new material is additive at the end of
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (:3438-3776, ~340
lines). Nothing landed was modified (`bracketEndChar_k1v`, NfEFold assets, k0 carrier all
untouched).

| Declaration | Role |
|-------------|------|
| `atomKind_castLE` (private) | Atom reindex along the prefix inclusion `Fin.castLE` |
| `nfk_take` | Depth-k prefix restriction of a NormalForm (recursion on k) |
| `nfk_projFresh` | Depth-k monadic point type of the fresh variable (index 0) |
| `nfk_projFresh_zero` (private) | Agreement with `nf0_projFresh` at depth 0 |
| `kv_body` (private) | Shared successor-case body, parametric in charBase/charK/r/offFiber/b |
| `bracketEndChar_kv` | **Deliverable**: `(k : Nat) → BracketEndCharCarrierV sig k` |
| `bracketEndChar_k1v_eq_kv_body` (private) | `bracketEndChar_k1v = kv_body …` by `rfl` |
| `kv_body_gate_fail` (private) | Gate failure returns the empty disjunction |
| `bracketEndChar_kv_one_eq` | **Documented k=1 bridge**: pointwise equality with `bracketEndChar_k1v` |

## Design Realizations (documented deviations within the settled shape)

1. **charF parameter family** — the depth-k char provider (`char_k1` /
   `nf_characterizable_temporal_prior`) lives in KampPrior.lean, which imports this file, so it
   is passed as `charF : (j : Nat) → NormalForm sig j 1 → Formula` (the
   `nf_succ_char_formula`/`exist_tl_fn` pattern). Phase 14 instantiates at the KampPrior call
   site.
2. **Fiber-existential fold-bit read** — no pointwise depth-k assemble exists at k ≥ 1 (D7);
   `b zs χ = decide (∃ sub, qnf.2 sub = true ∧ zoneSpec = zs ∧ nfk_projFresh sub = χ)`. Agrees
   with `efold_of_nf1`'s pointwise read at k=1 under the gate (split-kit bijection), discharged
   by the bridge lemma (acceptance's simp-bridge branch, strengthened to pointwise equality).

## Final Verification

- Full tree `lake build`: **GREEN** (1705 jobs)
- New sorries: **0** (repo census 163, all pre-existing outside this task's material; live Kamp
  baseline unchanged at KampPrior:351/:354)
- `lean_verify bracketEndChar_kv` = `[propext, Classical.choice, Quot.sound]`
- `lean_verify bracketEndChar_kv_one_eq` = `[propext, Classical.choice, Quot.sound]`
- Codomain `VVecEA2` (witness-growing); anchors `{x,t}` fixed (type invariant of
  `VVecEA2.holds`); no `VecEA2 1` regression
- No vacuous definitions; no new axioms; forbidden assets (`endChar`/`seg`,
  `nf_char3_deeper_split`) not consumed
- Doc-comments carry the N1 split, N4 flag, N5 arrangement-disjunction citation, and the
  G6-amendment reference

## Handoff

- `handoffs/phase-12-handoff-20260706.md` — Phase-13 entry points, key decisions (incl. the
  gate-strength note for the k ≥ 2 soundness direction), sorry inventory
- `.orchestrator-handoff.json` — machine-readable record (status: implemented, 10/12 phases)
