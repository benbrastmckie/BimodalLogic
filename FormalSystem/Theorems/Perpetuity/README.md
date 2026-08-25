# Perpetuity Principles

Proofs of perpetuity principles P1-P6, establishing fundamental connections between
modal necessity (□) and temporal operators (always △, sometimes ▽).

## Modules

| File | Description |
|------|-------------|
| `Principles.lean` | P1-P5 perpetuity principle proofs (814 lines) |
| `Helpers.lean` | Helper lemmas for perpetuity proofs (171 lines) |
| `MonotonicityDuality.lean` | Monotonicity and duality lemmas, and the P6 proof (658 lines) |

## Key Results

### P1-P5 (`Principles.lean`)

| Principle | Statement |
|-----------|-----------|
| P1 | `□φ → △φ` (necessary implies always) |
| P2 | `▽φ → ◇φ` (sometimes implies possible) |
| P3 | `□φ → □△φ` (necessity of perpetuity) |
| P4 | `◇▽φ → ◇φ` (possibility of occurrence) |
| P5 | `◇▽φ → △◇φ` (persistent possibility) |

### P6 (`MonotonicityDuality.lean`)

| Principle | Statement |
|-----------|-----------|
| P6 | `▽□φ → □△φ` (occurrent necessity is perpetual) |

### Helper Lemmas (`Helpers.lean`)

- Temporal components: `boxToFuture`, `boxToPast`, `boxToPresent`
- Context plumbing: `axiomInContext`, `applyAxiomTo`, `applyAxiomInContext`

### Monotonicity and Duality Lemmas (`MonotonicityDuality.lean`)

- Modal/temporal duality: `modalDualityNeg`, `modalDualityNegRev`, `temporalDualityNeg`,
  `temporalDualityNegRev`
- Monotonicity: `boxMono`, `diamondMono`, `futureMono`, `pastMono`, `alwaysMono`
- Double negation: `alwaysDni`, `alwaysDne`, `doubleContrapose`
- Bridges into P6: `bridge1`, `bridge2`

## Quick Reference

The six principles do **not** share a single naming pattern — the underscore appears only on P1
and P2, and P6 lives in a different file. The exact names are:

| Principle | Declaration | Site |
|-----------|-------------|------|
| P1 | `perpetuity_1` | [Principles.lean](Principles.lean):77 |
| P2 | `perpetuity_2` | [Principles.lean](Principles.lean):308 |
| P3 | `perpetuity3` | [Principles.lean](Principles.lean):443 |
| P4 | `perpetuity4` | [Principles.lean](Principles.lean):512 |
| P5 | `perpetuity5` | [Principles.lean](Principles.lean):811 |
| P6 | `perpetuity6` | [MonotonicityDuality.lean](MonotonicityDuality.lean):560 |

- **Temporal Components**: `boxToFuture`, `boxToPast` in [Helpers.lean](Helpers.lean)

## Building

```bash
lake build FormalSystem.Theorems.Perpetuity
```

## Related Documentation

- [Theorems README](../README.md)
- [Parent README](../../README.md)

---

*Last verified: 2026-05-29*
