# Metalogic/Conservativity/Plus

The stability extension L⁺ = L plus the paper's stability modal `⊡`, and its logic TM⁺.

This is the mirror image of L⁻ ⊂ L with the **hard direction available**. Forward conservativity
fails for L⁻ ⊂ L because TM⁻ is incomplete; for L ⊂ L⁺ the same composition succeeds, because
TM *is* complete at every class carrying a `WeakCompleteness` engine: forward is TM⁺ soundness
plus the truth-transfer bridge `plusValidIn_ofFormula_iff` plus that engine.

TM⁺'s axioms are the 45 TM schemata re-declared over `PlusFormula` (so `□⊡p → □G⊡p` is an MF
instance), plus S5 for `⊡`, `□φ → ⊡φ`, `p → ⊡p` for atoms, and two pasting schemata with
pure-future / pure-past side conditions (`Semantics/PlusLanguage/PlusPasting.lean`). The five refutations in
`Semantics/PlusLanguage/PlusNonValidities.lean` bound that set from above.

**General TM⁺ completeness and TM⁺ decidability are open** and are not asserted anywhere. One
durable fact bears on any attempt: the countermodels of all four completeness engines are
*deterministic*, so on them `⊡` is the identity and none of the engines transfers to L⁺ as it
stands. The nearest results in the literature are Reynolds (2003) on until/since completeness over
the reals and Zanardo (1991) on branching-time logics with an Ockhamist reading; neither settles
the all-histories semantics used here.

What that same fact **does** yield is the deterministic row, which is landed: TM⁺ together with
the *Determined* schema `φ → ⊡φ` is sound over the frames validating that schema and complete
over the deterministic frames, at every class, so the two classes have the same logic
(`Metalogic/Deterministic/`). That is an axiomatization, **not** a characterization: *Determined*
does not define the deterministic frames, and no L⁺ formula set does
(`Metalogic/Independence/DeterminismUndefinable.lean`).

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Conservativity/Plus -->
| File | Lines | Description |
|------|------:|-------------|
| `Atomization.lean` | 241 | The `⊡`-as-fresh-atom transfer: `Encoding`, `atomize`, `TaskModel.atomModel`, `plusTruthAt_iff_atomize`, and the two helpers that carry the 45 TM schemata over L⁺. |
| `AxiomValidity.lean` | 280 | The two dispatch lemmas, one arm per `PlusAxiom` constructor and no wildcard: every schema and every temporal dual is valid at its own minimum frame class. |
| `Corollaries.lean` | 195 | The composed fragment rows named per class and the derived logic of the defined modals `Will`/`will`/`could`. |
| `Forward.lean` | 171 | Forward conservativity of TM⁺ over TM at every class with a completeness engine, the biconditional `plusDerivable_ofFormula_iff`, and the composed L⁻ ⊂ L⁺ rows. |
| `PlusSoundness.lean` | 193 | Soundness of TM⁺ at every frame class, by the companion recursion carrying validity and swap-validity, plus the per-class rows and consistency at `.Base`. |
<!-- END GENERATED -->

## Key Results

- `plus_soundness_validIn` — soundness of TM⁺ at every frame class, with TD discharged
  semantically by the companion recursion and the TM schemata over L⁺ handled by atomization
- `plusDerivable_ofFormula_iff` — proof-theoretic conservativity of TM⁺ over TM in **both**
  directions, at all four classes
- `Corollaries.lean`: the composed fragment rows `tmFragIffPlus{Base,Dense,ZTime,RTime}`; the
  derived logic of the defined modals (`willImpAllFuture`, `boxAllFutureImpWill`, `willImpWill`,
  `someFutureCouldImpCouldSomeFuture`). The conservativity of TM⁺ + *Determined* over TM,
  `detDerivable_ofFormula_iff`, lives in `Metalogic/Deterministic/Completeness.lean` so that this
  directory does not import the deterministic subtree

## Metatheory rows

| Row | Status | Where |
|-----|--------|-------|
| TM⁺ soundness, all four classes | **landed** | `PlusSoundness.lean` |
| TM⁺ conservative over TM, both directions, all four classes | **landed** | `Forward.lean` |
| TM⁺ + *Determined* complete over the deterministic frames, all four classes | **landed** | `Metalogic/Deterministic/Completeness.lean` |
| the logic of the deterministic frames = the logic of the *Determined*-valid frames | **landed** | `Metalogic/Deterministic/Completeness.lean`, `logicDeterministicEqDeterminedValid` |
| TM⁺ + *Determined* conservative over TM | **landed** | `Corollaries.lean` |
| `⊡` is not L-definable | **landed** | `Metalogic/Independence/StabUndefinable.lean` |
| the two pasting schemata are not derivable from the naive `⊡`-set | **landed** | `Metalogic/Independence/PastingIndependence.lean` |
| **general (nondeterministic) TM⁺ completeness, any class** | **OPEN** — never stated, never sorried | — (Reynolds 2003, Zanardo 1991 are the nearest) |
| **TM⁺ decidability** | **OPEN** | — |
| TM⋆ soundness, all four classes | **landed** | `../Star/StarSoundness.lean` |
| TM⋆ conservative over TM, both directions, all four classes | **landed** | `../Star/Forward.lean` |
| TM⋆ conservative over TM⁺ | **CONDITIONAL on general TM⁺ completeness** — `starConservative_of_plusComplete`, with the unconditional contrapositive `plusIncomplete_of_starNonconservative`: any separating witness *is* a witness of TM⁺ incompleteness | `../Star/Forward.lean` |
| **TM⋆ completeness, any class** | **OPEN** — two obstructions named, never stated, never sorried | `../Star/README.md` |

## The L⋆ rows sit on top of this open problem

The register extension L⋆ = L⁺ + `↑ⁱ`/`↓ⁱ` and its logic TM⋆ (`../Star/`) inherit this
directory's status exactly, and the inheritance is precise rather than approximate. TM⋆ over the
**base** language is unconditional, because that composition ends in a *TM* completeness engine
and TM has four. TM⋆ over **L⁺** ends in a TM⁺ engine, and there is none; given TM⋆ soundness the
two questions coincide, so the row is stated as a conditional pair. Settling general TM⁺
completeness settles it; nothing else will.

## Related Documentation

- [Conservativity README](../README.md)
- [`FormalSystem/Syntax/PlusLanguage/`](../../../Syntax/PlusLanguage/README.md) — `PlusFormula`, `PlusAxiom`,
  `PlusDerivationTree`, `ofFormula`
- [`Semantics/PlusLanguage/PlusTruth.lean`](../../../Semantics/PlusLanguage/PlusTruth.lean) — the L⁺ truth recursion
- [`Metalogic/Deterministic/`](../../Deterministic.lean) — the deterministic metatheory: the
  narrowed engines, the `⊡`-erasure, TM⁺ + *Determined*, and its completeness
- [`docs/theorem-index.md`](../../../../docs/theorem-index.md) — per-theorem status

---

*Last verified: 2026-09-08*
