# Semantics/MinusLanguage — the semantics of the base language L⁻

The semantic modules of the tense-primitive base language **L⁻**, whose `H`/`G` are primitive
rather than derived from `untl`/`snce`. The syntax and the proof system TM⁻ live on the Syntax side
at `FormalSystem/Syntax/MinusLanguage/`; this directory holds what gives L⁻ its meaning: the native
truth recursion `MinusTruthAt` over task frames, a frame notion not bound to `TaskFrame`, and the
validity predicates that mirror `Semantics/Validity.lean` binder for binder.

Namespaces are unchanged by the nesting: every declaration here lives in `FormalSystem.Semantics`
(with sub-namespaces such as `MinusTruth`), so only the module path carries the `MinusLanguage` segment.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/MinusLanguage -->
| File | Lines | Description |
|------|------:|-------------|
| `MinusFrame.lean` | 309 | `MinusFrame` — a native L⁻ frame notion not bound to `TaskFrame` (points with an unbounded, transitive, irreflexive, forward- and backward-linear strict order, no group structure), its truth recursion `MinusFrameTruth` with `□` as the universal modality, `MinusFrameValid`, the `MinusFrameTruth.*` characterization family, and the order-reversal transfer lemma `truth_swap`; the frame class a countermodel to `(Sp)` lives on |
| `MinusSchemaValidity.lean` | 175 | DF/DN semantic lemmas (Lemmas B/C) and DF's `PredOrder` past-dual, consumed by `Metalogic/Conservativity/SpWitness.lean` and `minus_soundness_ztime_succ` |
| `MinusTruth.lean` | 221 | `MinusTruthAt` — the same truth relation for the tense-primitive base language, by native six-clause recursion on `MinusFormula` per `def:BL-semantics` (not `TruthAt ∘ tr`) |
| `MinusValidity.lean` | 284 | `MinusValid`, `MinusSemanticConsequence`, `MinusValidDense`, `MinusValidZTime`, `MinusValidZTimeSucc`, `MinusValidRTime` — binder-for-binder base-language mirrors of Validity.lean |
<!-- END GENERATED -->

The sibling aggregator is `FormalSystem/Semantics/MinusLanguage.lean`, imported by the root
aggregator `FormalSystem/FormalSystem.lean` (not by `FormalSystem/Semantics.lean`), mirroring
`FormalSystem/Syntax/MinusLanguage.lean`.

## Related Documentation

- [Semantics README](../README.md)
- [Syntax/MinusLanguage README](../../Syntax/MinusLanguage/README.md) — the syntax and proof system of the same language

---

*Last verified: 2026-09-16*
