# Task 358 Phase 8 Summary — G1 Independence Probe (NO-GO, Shared Root Cause)

- **Task**: 358 — Realization recursion `nf_nvar_exist_all_depths`
- **Phase**: 8 ONLY (hard-mode per-phase dispatch, `phase_number=8`)
- **Session**: sess_1783988294_843145
- **Date**: 2026-07-13
- **Result**: Phase 8 **[BLOCKED]** — machine-checked NO-GO; G1 shares the Phase-6 root cause

## What Was Dispatched

Determine — with a cheap probe, NOT a full build-out — whether the Phase-6 NO-GO root cause
(depth-1 fiber marking not pinned by free-env rendering) also defeats the G1 interior
`hreal`/`hexcl` supply (ledger rows 5-6) at general depth. If shared: no churn, blocker
naming the shared root cause; never a new sorry.

## Verdict: NO-GO — shared root cause (g1_independent = false)

The rows 5-6 binders (KampPrior.lean:835-846) read the qnf only through `qnf.1` and
`igFoldBit qnf`, and `igFoldBit` (InteriorGateGeneralK.lean:318) reads each marked
depth-(k+1) arity-4 fiber only through its `(zone, nfk_projFresh)` arity-1 projection — the
documented F1 information-loss channel. The Phase-6 doppelgänger cast transports one level
up: the fake fiber `σ = τ ⊕ s*` is **projection-invisible** (`nfk_projFresh (τ ⊕ s*) =
nfk_projFresh τ`, because `s*`'s arity-2 prefix take equals the honest inner element's — the
doppelgänger difference lives entirely in the discarded tail slots, deviation D7). Hence the
fake ambient `qnfG1 = m1qnf ⊕ σ` has an igPtW guard LITERALLY IDENTICAL to the honest
ambient's under every rendering, while the row-5 conclusion (pinned realization
`∃ x1, nf_eval_nf … [x1,w,x,t] σ`) is false at every anchor.

## Theorems Landed (ExteriorPinnedProbeM1K.lean, purely additive, ~185 lines)

Public (both verify at exactly `[propext, Classical.choice, Quot.sound]`, no sorryAx):
- `kvE_probeM1_interiorHreal_NOGO` — qnfG1 with same atom row, IDENTICAL `igFoldBit`, a
  marked fiber the honest ambient does not mark, and no pinned realization at any `x1`
- `kvE_probeM1_interiorGuard_identical` — `igPtW` identity for every (`charBase`, `charK`)

Private supporting lemmas: `m1tupH`, `m1shonest`, `m1_shonest_marked`, `m1_take2_eq`,
`m1_take_exists_iff`, `m1_projFresh_eq`, `m1_tau_marked`, `m1qnfG1`,
`m1_qnfG1_foldBit_eq`, `m1_sigma_not_pinned4`, `m1_qnf_sigma_false`.

## Final Verification

- Full-tree `lake build`: GREEN (1739 jobs)
- New sorries introduced: 0 (file sorries remain exactly the inherited KampPrior :361/:364)
- Vacuous definitions introduced: 0; new axioms introduced: 0
- lean_verify on both head theorems: floor axioms only

## Sorry Inventory (unchanged)

- KampPrior.lean:361 (`| 1 =>` arm) — strategic; gated on interface restatement + Phases 7-9
- KampPrior.lean:364 (`| n+2 =>` arm) — strategic; Phase 10, serialized after :361

## Consequence for the Plan

Phases 4, 7, 8 are now all blocked on the same repair class. The interface-restatement spawn
recommended by Phase 6 must cover BOTH legs (interior rows 5-6 and exterior rows 8-11):
anchored/pinned item rendering or a depth-graded fiber guard at the rungK binder /
`igFoldBit` consumer seam, then re-probe. `k = 0` layers (rung0/rung1, m=0 supply,
`kampPrior_case1_arm_k0`) are untouched and unrefuted. Do not dispatch Phase 9.

## Deviations

- Phase 8's four build tasks were NOT attempted (dispatch anti-churn mandate on shared root
  cause); an "Independence probe" task was added to the phase checklist and completed.
