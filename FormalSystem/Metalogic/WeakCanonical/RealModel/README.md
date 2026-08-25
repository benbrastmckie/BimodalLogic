# RealModel — Doets' theorem and the real flow

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
section 8 (*Doets' Theorem*, printed pp.185-188), attributed there to Doets 1987, 3.3.9.

This is the `ℝ`-side of the Dedekind completeness argument. Given the two hypotheses **D1** and
**D2** that `../DenseModelSurgery/` supplies, Doets' theorem produces a model on the real line.
The route is: countable + very good implies good at `ℝ`-intervals (Lemma 11); `ε(x,y)` defines
the equivalence and the `γ`-set is finite (Lemma 12); the `ℚ`-shuffle (Lemma 13) and its
`ℝ`-extension; and the order-theoretic characterization of `ℝ` that lets the result be stated
about the real line rather than about an abstract carrier.

`ChronicleRealFlow.lean` instantiates the whole of it at the chronicle structure this
repository actually constructs, which is what `completeness_dedekind` consumes.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `ChronicleRealFlow.lean` | 170 | Doets' theorem instantiated at `chronicleMonadicStructure`, the countable dense endpointless Prior structure satisfying `Sep` that this repository constructs. |
| `DoetsTheorem.lean` | 2198 | Doets' theorem itself, section 8 Theorem 6 (printed pp.185-188). |
| `EpsilonDense.lean` | 1109 | Lemma 12 — `ε(x,y)` defines the equivalence, and the finite `γ`-set (printed pp.186-187). |
| `GoodDense.lean` | 1650 | Lemma 11 — countable + very good implies good, at `ℝ`-intervals (printed pp.185-186). Opens the `ℝ`-side. |
| `OrderIsoReal.lean` | 335 | `IsRealLike` — the order-theoretic hypotheses that characterize `ℝ`: non-empty, densely ordered, without endpoints, Dedekind complete, separable (printed p.188). |
| `Shuffle.lean` | 497 | Lemma 13 and the `ℚ`-shuffle `Σ_{q∈ℚ} σ(q)` (printed pp.186-187). |
| `ShuffleReal.lean` | 684 | The `ℝ`-extension of the shuffle (printed p.188). |

## Key Results

- `doets_theorem_dense` (`DoetsTheorem.lean`) — section 8 Theorem 6.
- `IsRealLike` and the order isomorphism to `ℝ` (`OrderIsoReal.lean`).
- `ChronicleRealFlow.lean` — the instantiation that `completeness_dedekind`
  (`FormalSystem/Metalogic/StrongCompleteness.lean:469`) ultimately rests on.

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery` (D1 and D2),
  `FormalSystem.Metalogic.BXCanonical.Chronicle`, Mathlib's real and order libraries
- **Imported by**: `FormalSystem.Metalogic.StrongCompleteness`

## Related Documentation

- [WeakCanonical README](../README.md)
- [DenseModelSurgery README](../DenseModelSurgery/README.md) — the supplier of D1 and D2
- [Metalogic README](../../README.md)

---

**Last verified**: 2026-08-25
