# ForMathlib/Topology

Topological results Mathlib does not carry, stated in Mathlib's own shape so that the
development can be upstreamed rather than kept as a local fork. At present this is Sierpiński's
theorem on countable closed partitions of the line: a map `ℝ → V` with countable range and
closed level sets is constant. Mathlib's four `Sierpinski*` declarations are all about the
Sierpiński *space*; the partition theorem is absent.

This directory imports nothing from `FormalSystem.*`. That is a hard constraint, not an
accident: a module intended for Mathlib may not depend on this repository.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/ForMathlib/Topology -->
| File | Lines | Description |
|------|------:|-------------|
| `Sierpinski.lean` | 245 | Sierpiński's theorem on the real line: a map `ℝ → V` with countable range and closed level sets is constant. Carries the helper layer `levelSet` / `locallyConstantLocus` / `const_of_isPreconnected` at an arbitrary topological space, and the two Baire-powered main theorems at `ℝ` |
<!-- END GENERATED -->

## Key Definitions

- `Sierpinski.levelSet` — the level set `{t | h t = a}`, at an arbitrary topological space
- `Sierpinski.locallyConstantLocus` — the union of the interiors of the level sets: the points
  at which the map is locally constant. Open, and its complement is where the Baire argument
  lives
- `Sierpinski.const_of_isClosed_levelSet` — Sierpiński's theorem at a countable codomain
- `Sierpinski.const_of_countable_range` — the sharp form: only the *range* has to be countable

## Related Documentation

- [FormalSystem README](../../README.md)
- [`ForMathlib/`](../README.md) — the parent, which states the dependency rule
- [`FormalSystem/Semantics/Correspondence/`](../../Semantics/Correspondence/README.md) — the
  consumer: `RigidityReal.lean` spends this theorem to show that over `ℝ` every task frame with
  countably many world states is static

---

*Last verified: 2026-09-22*
