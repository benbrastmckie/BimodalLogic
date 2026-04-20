# Phase 0 Results: Axiom Audit

- **Task**: 109 - Close chain construction sorries
- **Phase**: 0 - Axiom Audit
- **Status**: COMPLETED
- **Date**: 2026-04-20

## Axiom Audit Results

### `#print axioms bx_completeness`

```
'Bimodal.Metalogic.BXCanonical.bx_completeness' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Lean.ofReduceBool,
 Lean.trustCompiler,
 Quot.sound]
```

### `#print axioms dd_countermodel`

```
'Bimodal.Metalogic.BXCanonical.dd_countermodel' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Lean.ofReduceBool,
 Lean.trustCompiler,
 Quot.sound]
```

## Axiom Classification

| Axiom | Status | Notes |
|-------|--------|-------|
| `propext` | Target | Standard Lean 4, acceptable |
| `Classical.choice` | Target | Standard Lean 4, acceptable |
| `Quot.sound` | Target | Standard Lean 4, acceptable |
| `sorryAx` | **Must eliminate** | 7 critical-path sorries (see below) |
| `Lean.ofReduceBool` | Acceptable | From `native_decide` in Syntax layer (Formula.lean) |
| `Lean.trustCompiler` | Acceptable | From `native_decide` in Syntax layer (Formula.lean) |

Note: `Lean.ofReduceBool` and `Lean.trustCompiler` come from `native_decide` in
`Theories/Bimodal/Syntax/Formula.lean` and `Theories/Bimodal/Syntax/SubformulaClosure.lean`.
These are not removable without changing the decidability infrastructure and are out of scope.

The revised target is: `{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}`
(same as original goal minus `sorryAx`).

## Sorry Dependency Tree

All 7 critical-path sorries (plus 4 dead-code sorries) were confirmed. No additional sorries
beyond the 11 identified in research were found.

### Dead code sorries (CanonicalModel.lean) — Phase 1 deletes

1. `enriched_seed_consistent` (~line 54) — enriched forward seed consistency; dead code
2. `fwd_succ_f_carry` (~line 98) — f_carry preservation at non-resolving steps; dead code
3. `enriched_past_seed_consistent` (~line 113) — enriched backward seed consistency; dead code
4. `bwd_pred_p_carry` (~line 164) — p_carry preservation at non-resolving steps; dead code

### Reflexive base case sorries (CanonicalModel.lean) — Phase 2 eliminates via strict FMCS

5. `g_content_subset_self` (~line 205) — used as base case `m=n` in `fwd_chain_g_content_trans`
6. `h_content_subset_self` (~line 211) — used as base case `m=n` in `bwd_chain_h_content_trans`

### Chain construction coherence sorries (RootScopedChain.lean) — Phases 3-5

7. `fwd_chain_forward_F` (~line 1044) — F-obligation resolution in forward chain; Phase 3
8. `dd_bfmcs_restricted_tc` forward t-s<0 case (~line 1092) — backward F-resolution; Phase 4
9. `dd_bfmcs_restricted_tc` backward direction (~line 1099) — P-preservation; Phase 4
10. `dd_bfmcs_restricted_buc` (~line 1107) — backward Until coherence; Phase 5
11. `dd_bfmcs_restricted_fuc` (~line 1114) — forward Until coherence; Phase 5

## Scope Assessment

**No additional sorries found beyond the 11 identified in research.** Scope is as planned.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — Added `#print axioms` checks and documentation comment
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — Cleaned up misleading "Phase 2 redesign" / "backward compatibility" comments in 6 locations

## Build Status

`lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeded with no errors.
