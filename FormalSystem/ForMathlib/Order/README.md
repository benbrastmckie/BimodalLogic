# ForMathlib/Order

The filter side of Mathlib's `Order/Ideal.lean` and `Order/PrimeIdeal.lean`: proper, maximal and
prime **filters** on a preorder, stated in the shape Mathlib states the ideal case, so that the
development can be upstreamed rather than kept as a local fork.

This directory imports nothing from `FormalSystem.*`. That is a hard constraint, not an
accident: a module intended for Mathlib may not depend on this repository.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/ForMathlib/Order -->
| File | Lines | Description |
|------|------:|-------------|
| `PFilter.lean` | 263 | <!-- TODO: add description --> |
<!-- END GENERATED -->

## Key Definitions

- `Order.PFilter.IsProper` — a proper filter: one that is not the whole preorder
- `Order.PFilter.IsMaximal` — a maximal proper filter
- `Order.PrimeFilter` — the prime condition, dual to `Order.PrimeIdeal`

## Related Documentation

- [FormalSystem README](../../README.md)
- [`FormalSystem/Metalogic/Algebraic/`](../../Metalogic/Algebraic/README.md) — the consumer:
  the Lindenbaum–Tarski quotient and the ultrafilter/MCS correspondence

---

*Last verified: 2026-09-07*
