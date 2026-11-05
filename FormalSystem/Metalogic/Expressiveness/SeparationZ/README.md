# SeparationZ — Gabbay separation over the integer flow

Gabbay's Separation Theorem for the until/since language over discrete (integer) time, and the
discharge of `FormalSystem.Metalogic.Expressiveness.SeparationOver TaskFrame.IsZTime` that
follows from it.

The development runs over an auxiliary syntax `USForm` whose leaves are abstract natural-number
indices evaluated by a leaf valuation `ℕ → ℤ → Prop`, not over `PlusFormula` directly. The
reason is recorded in `Syntax.lean`'s module docstring: GHR substitute formulas for atoms in
four of their eight lemmas, and uniform substitution does not visibly preserve L⁺ validity over
task frames. Abstracting the leaves makes every such step a reindexing of the leaf valuation.
The seam back to `PlusFormula` is a single interface in `LeafAbstraction.lean`.

**Argument order.** `untl`/`snce` take the guard first and the event second, matching
`PlusFormula.untl`. GHR's `U(A, B)` is this subtree's `untl B A`; every transcription flips.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Syntax.lean` | 394 | `USForm`, `usTruth` over `ℤ`, the derived connectives, the clause lemmas, the time reflection `swap` with `usTruth_swap`, and the `maxLeaf`/`freshLeaf` fresh-index device |
| `LeafAbstraction.lean` | 370 | The one seam to `PlusFormula`: `leaves`, `abstr`, `toPlus`, the roundtrip, truth transfer at `t : ℤ`, `IsUOnly`/`IsSOnly`, purity transfer, and the carrier bridge |
| `Distributivity.lean` | 134 | GHR Lemma 10.2.1: the duality combinator `usTruth_swap_congr` and the four Boolean distributivities (linearity only) |
| `NegationEquiv.lean` | 166 | GHR Lemma 10.2.2: the `ℤ` least-witness device and the four negation equivalences (first discreteness-dependent step) |

## Key Results

- `usTruth_swap` — the time reflection, which halves every `snce` case downstream
- `usTruth_congr_of_update` — the whole content of GHR's "fresh atom" device
- `toPlus_abstr`, `usTruth_toPlus_iff` — the roundtrip and the truth transfer across the seam
- `pointwise_ztime_of_pointwise_int` — the carrier bridge from `ℤ` to every regular ℤ-time frame

## References

* [GHR] D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations
  and Computational Aspects*, vol. 1, Chapter 10 §10.2 — Lemmas 10.2.1-10.2.8 and
  Theorem 10.2.9 over the integer flow

*Last verified: 2026-11-05*
