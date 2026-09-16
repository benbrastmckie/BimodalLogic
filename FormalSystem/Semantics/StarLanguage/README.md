# Semantics/StarLanguage — the semantics of L⋆

The semantic modules of the language **L⋆**, L⁺ plus the time registers `↑ⁱ`/`↓ⁱ`. The syntax
lives on the Syntax side at `FormalSystem/Syntax/StarLanguage/`, whose README carries the
paper-label correspondence table; this directory holds the truth recursion `StarTruthAt` over the
manuscript's points `(τ, x, v⃗)`, L⋆ validity with `sent:det`, both halves of
`app:deterministic-future`, the `Det-pm` definability theorem, and the state-locality fragment.

Namespaces are unchanged by the nesting: every declaration here lives in `FormalSystem.Semantics`
(with sub-namespaces such as `StarTruth`), so only the module path carries the `StarLanguage` segment.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/StarLanguage -->
| File | Lines | Description |
|------|------:|-------------|
| `StarDeterminism.lean` | 320 | `app:deterministic-future`'s positive half (`sentDet_of_deterministic`) and Theorem C's `Det-pm` half: `star_congr_of_deterministic`, `detPM` (schematic in `φ : StarFormula`), `detPM_unfold`, `detPM_of_deterministic` (schematic), `deterministic_of_detPM` (hypothesis at atoms), `deterministic_starDefinable` (the three-way equivalence: the atomic fragment forces determinism, determinism delivers the full schema) — the last two theorems of ZFC |
| `StarNonValidities.lean` | 200 | `app:deterministic-future`'s negative half: `refute_sentDet` over `NF`, the same countermodel `refute_determined` uses, and `not_starValid_sentDet` |
| `StarStateLocal.lean` | 383 | The **state-locality** fragment of L⋆: `StarFormula.StateLocal` (syntactic, by structural recursion — `box` and `stab` admitted for an *arbitrary* argument, `untl`/`snce`/`timeRecall` excluded) and `IsStateLocal` (semantic); `isStateLocal_box`, `isStateLocal_stab`, the soundness induction `isStateLocal_of_stateLocal`, the three non-preservation witnesses `not_isStateLocal_someFuture` / `not_isStateLocal_somePast` / `not_isStateLocal_timeRecall` on `NF`, and the headline `φ ↔ ⊡φ` (`stateLocal_stab_iff`, `stateLocal_starValid_iff_stab`) |
| `StarTruth.lean` | 424 | `StarTruthAt` — the truth recursion for L⋆ (L⁺ plus the time registers, `StarLanguage/Formula.lean`) over the manuscript's points `(τ, x, v⃗)`; the `StarTruth.*` clause lemmas; `starTruthAt_ofPlus`; and the transport layer `star_truth_congr_ext`, `update_shift_comm`, `starTruthAt_timeShift` (the vector **shifted**, never dropped) |
| `StarValidity.lean` | 287 | `TaskFrame.StarValidOn`, `StarValidOnFrames`, `StarValidIn`, `StarValid` — L⋆ mirrors of Validity.lean with the stored-time vector as an extra binder; `starValidOn_ofPlus`; `settledDisj`, `sentDet` (`sent:det`), `sentDet_unfold` (the paper's `(∗)` chain), and `not_starValidOn_sentDet` |
<!-- END GENERATED -->

The sibling aggregator is `FormalSystem/Semantics/StarLanguage.lean`, imported by the root
aggregator `FormalSystem/FormalSystem.lean` (not by `FormalSystem/Semantics.lean`), mirroring
`FormalSystem/Syntax/StarLanguage.lean`.

## Related Documentation

- [Semantics README](../README.md)
- [Syntax/StarLanguage README](../../Syntax/StarLanguage/README.md) — the syntax and proof system of the same language
- [`Metalogic/Conservativity/Star/`](../../Metalogic/Conservativity/Star/README.md) — L⋆ soundness and the conservativity analysis

---

*Last verified: 2026-09-16*
