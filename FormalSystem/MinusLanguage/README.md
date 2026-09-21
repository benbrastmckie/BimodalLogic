# MinusLanguage — the tense-primitive object language L⁻

This directory is a self-contained component at the library root, holding **all** of the
tense-primitive object language L⁻: its syntax, its proof system TM⁻, and its semantics. It was
assembled by the language-extension merge, which collapsed the two directories the syntax and
semantics halves used to occupy under `Syntax/` and `Semantics/` into this single one.

Where the primary language (`FormalSystem/Syntax/Formula.lean`) takes `untl` and `snce` as
primitive and derives `H`/`G`, the base language `L⁻` takes `H` (`allPast`) and `G`
(`allFuture`) as *primitive*:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | Hφ | Gφ
```

The two languages are related by the translation `tr` (`Translation.lean`), which is what the
conservativity result in `FormalSystem/Metalogic/Conservativity/Backward.lean` transports along.
`L⁻` and `TM⁻` are this repository's own: the manuscript withdrew its H/G fragment, so neither
answers to a paper name. The primary language `L` — the paper's own 𝓛 — is the one this
repository's metalogic is proved in.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/MinusLanguage -->
| File | Lines | Description |
|------|------:|-------------|
| `AxiomDischarge.lean` | 379 | `dischargeAxiom` — for each `MinusLanguage.Axiom` constructor, a primary-language derivation of that axiom's translation. Seven rows are exact; the rest go through the `F`/`P` bridge |
| `Axioms.lean` | 268 | `MinusLanguage.Axiom` — TM⁻'s axiom schemata over L⁻ (MK, MT, M5, MF, TK, T4, TB, TA, TL), plus the three extension axioms routed to their frame classes by `Axiom.minFrameClass`. A second `inductive Axiom`, distinct from the primary language's |
| `Derivation.lean` | 195 | `MinusLanguage.DerivationTree` — a constructor-for-constructor mirror of the primary `DerivationTree`, with the same 7 inference rules, over `MinusFormula` |
| `Formula.lean` | 215 | `MinusFormula`, the tense-primitive base language, with `allPast`/`allFuture` as constructors rather than abbreviations |
| `MinusFrame.lean` | 316 | `MinusFrame` — a native L⁻ frame notion not bound to `TaskFrame` (points with an unbounded, transitive, irreflexive, forward- and backward-linear strict order, no group structure), its truth recursion `MinusFrameTruth` with `□` as the universal modality, `MinusFrameValid`, the `MinusFrameTruth.*` characterization family, and the time-reflection transfer lemma `truth_reflectTime`; the frame class a countermodel to `(Sp)` lives on |
| `MinusSchemaValidity.lean` | 176 | DF/DN semantic lemmas (Lemmas B/C) and DF's `PredOrder` past-dual, consumed by `Metalogic/Conservativity/SpWitness.lean` and `minus_soundness_ztime_succ` |
| `MinusTruth.lean` | 224 | `MinusTruthAt` — the same truth relation for the tense-primitive base language, by native six-clause recursion on `MinusFormula` per `def:BL-semantics` (not `TruthAt ∘ tr`) |
| `MinusValidity.lean` | 308 | `MinusValid`, `MinusSemanticConsequence`, `MinusValidDense`, `MinusValidZTime`, `MinusValidZTimeSucc`, `MinusValidRTime` — binder-for-binder base-language mirrors of Validity.lean |
| `Soundness.lean` | 616 | The truth-transfer bridge `truthAt_tr`, and L⁻ soundness at `FrameClass.Base` and its three extensions, by composition through `Conservativity.translate` |
| `Translation.lean` | 268 | `tr : MinusFormula → Formula` and `trCtx` — the translation into the primary language, sending each L⁻ primitive to the primary operator of the same name |
<!-- END GENERATED -->

The sibling aggregator is `FormalSystem/MinusLanguage.lean`, imported by the root aggregator
`FormalSystem/FormalSystem.lean`.

## Syntax before semantics

The two halves of this directory are ordered, even though they now share it. `Formula.lean`,
`Axioms.lean`, `Derivation.lean`, `Translation.lean` and `AxiomDischarge.lean` define no truth
relation, no validity predicate and no frame, and import nothing from `FormalSystem/Semantics/`.
The semantic modules beside them do, and that edge is what gives L⁻ its meaning:

| File | What it carries |
|------|-----------------|
| `MinusTruth.lean` | `MinusTruthAt`, a native six-clause recursion on `MinusFormula` per `def:BL-semantics` — **not** `TruthAt ∘ tr` |
| `MinusFrame.lean` | a native L⁻ frame notion not bound to `TaskFrame`, with `MinusFrameTruth`, `MinusFrameValid` and the time-reflection transfer lemma |
| `MinusValidity.lean` | `MinusValid`, `MinusSemanticConsequence`, and the Dense / Discrete / Dedekind-dense validity predicates |
| `MinusSchemaValidity.lean` | the DF and DN semantic lemmas and DF's `PredOrder` past-dual |
| `Soundness.lean` | the truth-transfer bridge `truthAt_tr`, and L⁻ soundness at `FrameClass.Base` and its three extensions, by composition through `Conservativity.translate` |

`MinusTruth.lean` imports `Formula.lean` only — a leaf whose own sole import is
`FormalSystem.Syntax.Atom` — so the edge introduces no cycle.

This ordering is prose, recorded in `FormalSystem/MinusLanguage.lean`'s module docstring as the
component's standing invariant. No mechanical check enforces it; before the merge, the
directory boundary did.

## Key Results

- `tr` (`Translation.lean`) — the translation of L⁻ into the primary language.
- `dischargeAxiom` (`AxiomDischarge.lean`) — the axiom-discharge table that makes the `axiom`
  case of `Conservativity.translate` a one-line match.
- `MinusLanguage.DerivationTree` (`Derivation.lean`) — the mirror proof system, which is what
  makes `Conservativity.translate` a seven-case structural recursion with one case per rule.

## Dependencies

- **Imports from**: `FormalSystem.Syntax`, `FormalSystem.ProofSystem`, `FormalSystem.Theorems`,
  and — from the semantic half only — `FormalSystem.Semantics`
- **Imported by**: `FormalSystem.Metalogic.Conservativity` (whole directory)

## Related Documentation

- [FormalSystem README](../README.md)
- [Syntax README](../Syntax/README.md) — the primary, until/since-primitive language
- [ProofSystem README](../ProofSystem/README.md)
- [Semantics README](../Semantics/README.md) — the base-language semantics this one mirrors
- [Metalogic README](../Metalogic/README.md) — where `Conservativity/` lives

---

*Last verified: 2026-09-21*
