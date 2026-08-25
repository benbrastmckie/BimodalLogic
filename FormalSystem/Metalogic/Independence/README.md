# Independence — underivability results

Underivability results, established by exhibiting a model of the assumptions in which the
target formula fails.

The result carried here is that the paper's `CO` principle does **not** derive Reynolds's
`Axiom.prior_U_gap` over the dense base. The converse direction — Reynolds's triple *does*
derive `CO` — is `FormalSystem.Theorems.DedekindDerived.co_derived`, so the two together settle
the relationship in both directions.

Every result here follows the same four steps: build a concrete frame satisfying every
structural axiom of the semantics; prove a truth-invariance lemma for it (a symmetry or
periodicity constraining *every* formula uniformly, by induction on `Formula` with the history
universally quantified **inside** the induction, so the `□` case can apply the inductive
hypothesis); derive validity of the assumptions; and exhibit a valuation refuting the target.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `ClockFrame.lean` | 240 | The periodic clock frame: temporal order `D = ℚ`, world-state carrier the rational circle `W = ℚ ⧸ ℤ`, task relation the deterministic translation flow. All `TaskFrame` obligations discharged, with a reference total history. |
| `CoNotPriorU.lean` | 584 | The symmetric irrational arc valuation on the clock frame, the refutation of `Axiom.prior_U_gap` in that model, and the two independence statements. |
| `LoopingDuration.lean` | 273 | The reusable content. A frame carrying a *looping duration* (a nonzero `π` whose task relation is the identity) has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every instance of `CO`. Proved for an arbitrary such frame. |

## Key Results

- `co_not_derives_prior_U` and its companion (`CoNotPriorU.lean`) — the independence
  statements.
- `states_add_of_looping` and `truthAt_add_period` (`LoopingDuration.lean`) — history
  periodicity and truth periodicity from a looping duration alone.
- `clockFrame` (`ClockFrame.lean`) — the witness frame, with every structural axiom discharged.

## Dependencies

- **Imports from**: `FormalSystem.Semantics`, `FormalSystem.ProofSystem`, Mathlib's `ℚ ⧸ ℤ`
- **Imported by**: `FormalSystem.Metalogic.Independence` (the sibling aggregator)

## Related Documentation

- [Metalogic README](../README.md)
- [Theorems README](../../Theorems/README.md) — `DedekindDerived.co_derived`, the converse
  direction

---

**Last verified**: 2026-08-25
