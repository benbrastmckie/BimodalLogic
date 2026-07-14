# Task 350 Phase 13 Summary — (E1) exterior fiber kit + single-fiber R3 probe

**Session**: sess_1784009176_e5245f (hard-mode single-phase dispatch, phase_number=13)
**Plan**: plans/03_negfix-refactor-exterior-carriers.md (v3), Phase 13
**Status**: COMPLETED — stopped at phase boundary (14a not started, per contract)

## Phases Executed

Phase 13 only. New module
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberKitK1.lean`
(631 lines) + one import line (with cycle-audit NOTE) in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`.

## R3 Adjudication Probe (first task — PASSED, risk R3 retired)

Probe qnf `extProbeQnf` with the w<x channel: order row `extProbeRow` (order atom `(i,j)`
true iff `i<j` positionally — encodes `w<x`, `w<t`, `x<t`), quant layer `extProbeQuant`
with exactly ONE true bit at the fiber (zone `v<w`, point type `extProbeChi`).

- **Bit-TRUE inner fiber** (zone `v<w`): realized — `extProbe_bitTrue_realized`.
- **Bit-FALSE inner fiber** (interior zone `x<v<t`, same point type): excluded —
  `extProbe_bitFalse_excluded`.
- **Clause iff** `extProbe_clause_iff`: end-to-end through the intended device —
  `nf_eval_depth1_fold_iff` at n=3, env `[w,x,t]`, the depth-0 split-kit round-trips
  (`nf0_zoneSpec_assemble`/`nf0_projFresh_assemble`/`nf0_dropFresh_assemble`), and the
  per-zone zone readings. Unconditional iff (12a probe precedent).
- Probe was the FIRST proved item, committed green (8b4cafcc0) before the general kit.

## Theorems/Lemmas Proved (all sorry-free)

| Name | Content |
|---|---|
| `ext3Mk`, 7 zone constants | `extZBelowW, extZAtW, extZIntWX, extZAtX, extZIntXT, extZAtT, extZAboveT` |
| `ext3_zoneHolds_cons_iff`, `ext3_zs_ext` | arity-3 zoneHolds pointwise reading / builder |
| `extZ_*_holds_iff` (7) | per-zone monadic readings under ambient `w<x<t` |
| `extZone_consistent_lt` | routing: any realized `ZoneSpec 3` is one of the 7 consistent zones (arity-3 `agg2_zone_consistent_lt` technique) |
| `extZone_inconsistent_false` | fold bit of every order-channel-inconsistent fiber forced false under any realizer |
| `extZoneFiber_k1` | the E1 partition: depth-1 fold at n=3 ↔ atom layer ∧ 7 monadic per-zone fiber clauses ∧ inconsistent-zone falsity ∧ off-fiber honesty |
| probe artifacts | `extProbeRow/Chi/Target/Quant/Qnf`, `extProbe_bit_true`, `extProbe_bit_false_of_ne`, `extProbe_quant_off`, `extProbe_clause_iff`, `extProbe_bitTrue_realized`, `extProbe_bitFalse_excluded` |

## Final Verification

- Scoped build: 1033 jobs green. Aggregator: 1045 jobs green. Full `lake build`: 1748 jobs green.
- `lean_verify` on `extProbe_clause_iff`, `extZoneFiber_k1`, `extZone_consistent_lt`,
  `extZone_inconsistent_false` = exactly `[propext, Classical.choice, Quot.sound]`, no warnings.
- Sorry census (`lean-sorry-census.sh` over `NfMultiAnchorBridge/`): sorry_count 0.
- Vacuous-definition grep over Theories/: 1 hit, pre-existing baseline
  (`TemporalStructures.lean:269`), not in this phase's files.
- `^axiom` grep: 2 hits, both prose lines inside Boneyard doc-comments (not declarations);
  no new axioms.
- `nf_char3_deeper_split` in new module: docstring prohibition note only.
- Guard audit: diff since 12b touches ONLY the new module, the aggregator import block, the
  plan file, and task-350 spec artifacts. No frozen-file, `KampPrior.lean`, or (G6)
  `ExteriorPinnedConverse{K,PastK}.lean` edits. KampPrior sorry count still exactly 2.

## Sorry Inventory

Empty.

## Plan Deviations

None. Probe-first ordering honored; consumed (never rebuilt) `nf_eval_depth1_fold_iff` and
the `agg2_zone_consistent_*` technique; module is an acyclic leaf importing only
`AggregateHookDischarge`.

## Consumption Notes for Phase 14a (E2)

See `handoffs/phase-13-handoff-20260714.md` for the binding delivered-name table and two
recorded Lean gotchas (defeq transport through pair-literal projections; zone-constant
distinctness via `congrFun … (by decide)`).
