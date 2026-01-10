# Perpetuity Principles

Proofs of perpetuity principles P1-P6, establishing fundamental connections between modal necessity (□) and temporal operators (always △, sometimes ▽).

## Submodules

- **Principles.lean**: P1-P5 perpetuity principle proofs
  - P1: `□φ → △φ` (necessary implies always)
  - P2: `▽φ → ◇φ` (sometimes implies possible)
  - P3: `□φ → □△φ` (necessity of perpetuity)
  - P4: `◇▽φ → ◇φ` (possibility of occurrence)
  - P5: `◇▽φ → △◇φ` (persistent possibility)

- **Helpers.lean**: Helper lemmas for perpetuity proofs
  - Temporal components: box_to_future, box_to_past, box_to_present
  - Boilerplate reduction: axiom_in_context, apply_axiom_to, apply_axiom_in_context
  - Propositional reasoning: Re-exports from Combinators.lean

- **Bridge.lean**: Bridge lemmas and P6 proof
  - P6: `▽□φ → □△φ` (occurrent necessity is perpetual)
  - Modal/temporal duality: modal_duality_neg, temporal_duality_neg
  - Monotonicity: box_mono, diamond_mono, future_mono, past_mono, always_mono
  - Double negation: dne, box_dne, double_contrapose

## Quick Reference

**Where to find specific theorems**:

- **P1-P5 Proofs**: See `perpetuity_1` through `perpetuity_5` in [Principles.lean](Principles.lean)
- **P6 Proof**: See `perpetuity_6` in [Bridge.lean](Bridge.lean)
- **Temporal Components**: See `box_to_future`, `box_to_past`, `box_to_present` in [Helpers.lean](Helpers.lean)
- **Duality Lemmas**: See `modal_duality_neg`, `temporal_duality_neg` in [Bridge.lean](Bridge.lean)
- **Monotonicity**: See `box_mono`, `always_mono`, etc. in [Bridge.lean](Bridge.lean)

## Building and Type-Checking

```bash
# Build perpetuity module
lake build Logos.Core.Theorems.Perpetuity

# Type-check specific file
lake env lean Logos/Core/Theorems/Perpetuity/Principles.lean
lake env lean Logos/Core/Theorems/Perpetuity/Helpers.lean
lake env lean Logos/Core/Theorems/Perpetuity/Bridge.lean
```

## API Documentation

For detailed API documentation, see:
- Module overview: [Perpetuity.lean](../../Theorems.lean) (parent module re-exports)
- Generated docs: Run `lake build :docs`
- Architecture guide: [ARCHITECTURE.md](../../../../Documentation/UserGuide/ARCHITECTURE.md)

## Related Documentation

- [LEAN Style Guide](../../../../Documentation/Development/LEAN_STYLE_GUIDE.md)
- [Module Organization](../../../../Documentation/Development/MODULE_ORGANIZATION.md)
- [Implementation Status](../../../../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
