# Semantics/Ultraproduct

The dependent ultraproduct of shift sets, and Łoś's theorem for it.

This is the construction that makes **compactness** available at `FrameClass.Base` and
`FrameClass.Dense`: `Metalogic/Compactness.lean`'s `modelExistenceBase` and
`modelExistenceDense` build a model of a finitely satisfiable premise set as an ultraproduct
over the set's finite sublists, and `compactBase` / `compactDense` follow through the
class-generic bridge `compact_of_modelExistence`.

Łoś is deliberately proved at the **shift-set** level rather than at `TruthAt` directly: a shift
set quantifies over its own carrier, where `TruthAt` quantifies over possible worlds, and
`ShiftSet.forward_repr` reconciles the two on both sides. `los_truthAt` is the conjugated form.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/Ultraproduct -->
| File | Lines | Description |
|------|------:|-------------|
| `Carrier.lean` | 304 | <!-- TODO: add description --> |
| `IndexFilter.lean` | 97 | <!-- TODO: add description --> |
| `Los.lean` | 160 | <!-- TODO: add description --> |
| `ShiftSetProduct.lean` | 134 | <!-- TODO: add description --> |
<!-- END GENERATED -->

## Key Results

- `los` — Łoś's theorem at the shift-set level
- `los_truthAt` — the same statement at `TruthAt`, by conjugating `los` with
  `ShiftSet.forward_repr` on both sides

## Related Documentation

- [Semantics README](../README.md)
- [`ShiftSet.lean`](../ShiftSet.lean) — the shift-set representation theorem
- [`FormalSystem/Metalogic/Compactness.lean`](../../Metalogic/Compactness.lean) — the consumer
- [`docs/theorem-index.md`](../../../docs/theorem-index.md) — status of the compactness results

---

*Last verified: 2026-09-07*
