# Phase 3 Handoff: EliminationResult Adjacent-Pair Guard

## Status: COMPLETED

Phase 3 is complete. The `EliminationResult` structure in `CounterexampleElimination.lean` has been strengthened with adjacent-pair guard conditions.

## Changes Made

### Type Changes (Tasks 3.1-3.2)

**c5_forward_witness** (CE:612-616) now returns:
```lean
∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧
  ∀ a b, Adjacent val.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ val.g a b
```

**c5_backward_witness** (CE:617-621) now returns:
```lean
∃ y ∈ val.dom, y < pc.x ∧ pc.η ∈ val.f y ∧
  ∀ a b, Adjacent val.dom a b → y ≤ a → b ≤ pc.x → pc.ξ ∈ val.g a b
```

### Non-C5 Cases (Task 3.3)

All 16 absurd sites compile unchanged. The `absurd` pattern derives `False` from kind mismatch (`h_kind` says the kind is NOT c5_forward/c5_backward), so the conclusion type is irrelevant.

### Build Status (Task 3.4)

12 compilation errors identified at C5 active case sites:
- **6 forward**: lines 758, 929, 1002, 1181, 1414, 1485
- **6 backward**: lines 1595, 1744, 1812, 1947, 2171, 2242

These are expected and will be fixed in Phases 4 (forward) and 5 (backward).

## Error Classification for Phases 4-5

| Line | Direction | Case | Error Type |
|------|-----------|------|------------|
| 758 | Forward | n=0 (pc.x = max_old) | `exact h_η_C` missing guard conjunct |
| 929 | Forward | Walk A (pc.x < max_old), n=0-like | `h_η_C` missing guard conjunct |
| 1002 | Forward | Walk B eta-shortcut | `h_eta_u_next` missing guard conjunct |
| 1181 | Forward | Walk B splitting | `show` pattern mismatch (missing guard) |
| 1414 | Forward | Not-condition(i) splitting | `show` pattern mismatch (missing guard) |
| 1485 | Forward | Not-actual case | `hy_η` missing guard conjunct |
| 1595 | Backward | n=0 (pc.x = min_old) | `show` pattern mismatch (missing guard) |
| 1744 | Backward | Walk A (pc.x > min_old), n=0-like | `show` pattern mismatch (missing guard) |
| 1812 | Backward | Walk B eta-shortcut | `h_eta_w_prev` missing guard conjunct |
| 1947 | Backward | Walk B splitting | `show` pattern mismatch (missing guard) |
| 2171 | Backward | Not-condition(i) splitting | `show` pattern mismatch (missing guard) |
| 2242 | Backward | Not-actual case | `hy_η` missing guard conjunct |

## Downstream Impact

`ChronicleConstruction.lean` uses `c5_forward_witness` and `c5_backward_witness` at:
- `omega_chain_c5_witness` (CC:392) -- needs return type strengthened (Phase 6)
- `omega_chain_c5'_witness` (CC:418) -- needs return type strengthened (Phase 6)

These downstream changes are Phase 6 scope.

## Next Steps

Phase 4: Fix all 6 forward C5 active cases with walk restructuring.
Phase 5: Fix all 6 backward C5 active cases (Since mirror).
