# Perpetuity Principles

Proofs of perpetuity principles P1-P6, establishing fundamental connections between
modal necessity (□) and temporal operators (always △, sometimes ▽).

## Modules

| File | Description |
|------|-------------|
| `Principles.lean` | P1-P5 perpetuity principle proofs |
| `Helpers.lean` | Helper lemmas for perpetuity proofs |
| `Bridge.lean` | Bridge lemmas and P6 proof |

## Key Results

### P1-P5 (`Principles.lean`)

| Principle | Statement |
|-----------|-----------|
| P1 | `□φ → △φ` (necessary implies always) |
| P2 | `▽φ → ◇φ` (sometimes implies possible) |
| P3 | `□φ → □△φ` (necessity of perpetuity) |
| P4 | `◇▽φ → ◇φ` (possibility of occurrence) |
| P5 | `◇▽φ → △◇φ` (persistent possibility) |

### P6 (`Bridge.lean`)

| Principle | Statement |
|-----------|-----------|
| P6 | `▽□φ → □△φ` (occurrent necessity is perpetual) |

### Helper Lemmas (`Helpers.lean`)

- Temporal components: `box_to_future`, `box_to_past`, `box_to_present`
- Propositional reasoning: Re-exports from `Combinators.lean`

### Bridge Lemmas (`Bridge.lean`)

- Modal/temporal duality: `modal_duality_neg`, `temporal_duality_neg`
- Monotonicity: `box_mono`, `diamond_mono`, `future_mono`, `past_mono`, `always_mono`
- Double negation: `dne`, `box_dne`, `double_contrapose`

## Quick Reference

- **P1-P5**: `perpetuity_1` through `perpetuity_5` in [Principles.lean](Principles.lean)
- **P6**: `perpetuity_6` in [Bridge.lean](Bridge.lean)
- **Temporal Components**: `box_to_future`, `box_to_past` in [Helpers.lean](Helpers.lean)

## Building

```bash
lake build Bimodal.Theorems.Perpetuity
```

## Related Documentation

- [Theorems README](../README.md)
- [Parent README](../../README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
