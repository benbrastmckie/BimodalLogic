# ForMathlib Tests

Isolated-import smoke checks for the Mathlib-shaped extensions staged for upstreaming.

## Contents

| File | Description |
|------|-------------|
| SmokeTest.lean | A `#check` per public `ForMathlib` declaration plus one instantiating `example` per file, importing only `FormalSystem.ForMathlib` |

## Coverage

- `Order/BallSpace.lean` — `Order.IsNest`, the nest-directedness lemma, and the
  spherical-completeness reduction
- `Order/PFilter.lean` — the proper / maximal / prime filter API, the prime-filter separator, and
  bundled `Order.PrimeFilter`
- `Combinatorics/SimpleGraphAcyclic.lean` — `SimpleGraph.isAcyclic_of_rank_parent`, instantiated
  at the empty graph on `ℕ`
- `Combinatorics/InfiniteRamseyPairs.lean` — `Nat.exists_strictMono_const_pair_colour`,
  instantiated at a two-colouring
- `Topology/Sierpinski.lean` — the locally-constant locus and the countable-range form of
  Sierpiński's theorem, instantiated at a constant `ℝ → Bool`

The single `import FormalSystem.ForMathlib` is the point of the module, not an incidental detail:
everything under `FormalSystem/ForMathlib/` imports nothing from `FormalSystem.*` so that an
upstreamed file can simply be deleted here. Before this module existed those files were exercised
only transitively, through the `FormalSystem` modules that consume them, so nothing checked that
they stand up in isolation — which is the property an upstream PR is judged on. A second
`FormalSystem.*` import would silently retire that check.

## Related

- [Source: ForMathlib/](../../../FormalSystem/ForMathlib/)
- [Parent README](../README.md)

---

*Last Updated: 2026-11-19*
