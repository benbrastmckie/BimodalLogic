# Task 368 — Phase 2 handoff (COMPLETED)

## Immediate Next Action
Phase 3 (probe-level, still probe-only): prove `kvE_ambientDeepAnchorV0_of_realized`
(honest-preservation crux at a GENERAL `OrderedMonadicStructure`) and the
`kvE_ambientDeepAnchorV0_iff` readback lemma. Load-bearing lemma already landed:
`swapNF01_char` (via `renameNF_eval_iff` + `nf_eval_unique`) — a realized ambient's marked
subs' deep fibers swap to realized subs, which are marked.

## Current State
- Phase 2 COMPLETE. Scoped build green (1025 jobs). Commit `d25c39df9`.
- New in `ExteriorAmbientDeepAnchorProbe358K.lean` (+246 lines, additive; +1 import
  `NfDepth0Generalized`):
  - `swapNF01` — depth/arity-preserving top-two-slot reindex (`renameNF (Equiv.swap 0 1) ...`).
  - `swapNF01_char` — swap of a characteristic = characteristic of swapped env.
  - `kvE_ambientDeepAnchorV0` — the σ-independent guard; `k=0` arm `true` (rfl-inert),
    `k+1` arm the fresh-rotation EF-closure (membership/mate condition at the marked-sub type).
  - `kvE_ambientDeepAnchorV0_zero` (Gate 2c) — `rfl`.
  - `kvE_probe368_cmA_ambient_rejected` (Gate 2a), `kvE_probe368_cmB_ambient_rejected` (Gate 2b).
- All three gates: axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx.
- Zero sorries / zero vacuous / zero new axioms; guard-unfold scan clean; production untouched.

## Key Decisions
- Both plan clauses (i) fresh-rotation re-appearance and (ii) deep-content-to-row anchoring are
  facets of ONE fresh-rotation EF-closure clause — a single mechanized condition rejects both CMs.
- Depth/arity bookkeeping (367 lesson): expressed as `∃ marked σ', σ'.2 (swapNF01 ρ) = true`
  (membership at the type `qnf.2` marks), NOT the depth-raising slot-drop `nfk_projFresh`
  (F2-DEAD, never built). `swapNF01` is a same-depth same-arity permutation.
- Gate 2a reuses Phase-1 `cA_gap_false`; Gate 2b needed a new `swG_forces` unrealizability
  (`R` forced at slot 1 with slot1<slot2).

## Sorry Inventory
Empty.
