# GroupModel — the Base-MCS discrete countermodel at `ℚ ×ₗ ℤ`

This directory builds a countermodel to an arbitrary formula from a **Base** maximal consistent
set, on the non-Archimedean discrete carrier `ℚ ×ₗ ℤ`. It is the Base analogue of the Discrete
construction in `IntegerModel/`, which needs a Discrete MCS and lands on `ℤ`.

The files form a single companion-lemma chain, read in the order given below: a countable
discrete unbounded structure is decomposed into coloured `ℤ`-blocks, each block absorbs a copy
of `ℚ ×ₗ ℤ` invisibly at depth `k` by Ramseyan factorization, and the resulting structure is
`goodGroupable` — which is what the countermodel construction consumes.

Sources: Doets 1987, chapters 3 and 7; Reynolds 1992, section 8.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `BlockDecomposition.lean` | 444 | Decomposes a countable discrete unbounded monadic structure as an ordered sum of coloured copies of `ℤ` (Doets 1987, ch. 3 and ch. 7 step 9). First stage of the chain. |
| `CountermodelBase.lean` | 478 | Hosts `countermodel_discrete` (`:142`): from a Base MCS containing `¬φ` and `□(nextTop)`, builds a countermodel to `φ` on `ℚ ×ₗ ℤ`. |
| `GoodGroupable.lean` | 194 | Reynolds section 8's `good` notion transposed to `ℚ ×ₗ ℤ`: the `QZStructure` target vocabulary, `goodGroupable`, its two transfer lemmas, and the two endpoint corollaries. |
| `GroupableCompanion.lean` | 426 | The companion lemma itself: every countable discrete unbounded-both-ways monadic structure is `goodGroupable` at every depth (`companionGeneral`), instantiated at the Base-MCS chronicle structure (`companionChronicle`). |
| `MonoDiscrete.lean` | 892 | Monochromatic discrete completeness at depth `k`: two monochromatic discrete linear orders with the same endpoint profile are `KEquiv` at every depth. The classical completeness of `Th(ℤ,<)`, transposed to monadic structures. |
| `RamseyFactorization.lean` | 923 | The per-block inflation step. Proves infinite Ramsey for pairs from scratch (absent from Mathlib at this pin) and uses it to show every coloured `ℤ`-block absorbs a coloured copy of `ℚ ×ₗ ℤ` invisibly at depth `k`. |

## Key Results

- `countermodel_discrete` (`CountermodelBase.lean:142`) — the deliverable of this directory,
  and a **proved** theorem rather than a deprecated pipeline.
- `companionGeneral` / `companionChronicle` (`GroupableCompanion.lean`) — the companion lemma
  in general and at the chronicle structure.
- `infinite_ramsey_pairs` (`RamseyFactorization.lean`) — infinite Ramsey for pairs, proved from
  scratch because Mathlib does not carry it at this toolchain pin.

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.BXCanonical.Chronicle`,
  `FormalSystem.Metalogic.Core`, Mathlib order and cardinality libraries
- **Imported by**: `FormalSystem.Metalogic.WeakCanonical.Transfer`

## Related Documentation

- [WeakCanonical README](../README.md)
- [IntegerModel README](../IntegerModel/README.md) — the Discrete-MCS analogue at `ℤ`
- [Metalogic README](../../README.md)

---

**Last verified**: 2026-08-25
