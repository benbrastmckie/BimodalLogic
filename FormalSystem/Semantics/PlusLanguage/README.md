# Semantics/PlusLanguage — the semantics of L⁺

The semantic modules of the language **L⁺**, L plus the stability modal `⊡`. The syntax and the
proof system TM⁺ live on the Syntax side at `FormalSystem/Syntax/PlusLanguage/`; this directory holds
the truth recursion `PlusTruthAt`, the L⁺ validity predicates with semantic conservativity over L,
history pasting, the refutations that bound the axiom set, the deterministic collapse `⊡φ ↔ φ`, and
the state-locality fragment.

The two cross-language bridges stay at the `Semantics/` root: `DeterministicBridge.lean`
(`lem:deterministic-singleton` as a biconditional, imported by `StarLanguage/StarDeterminism.lean`)
and `StateLocalTransfer.lean` (the L⁺ and L⋆ state-locality fragments agree along `ofPlus`).

Namespaces are unchanged by the nesting: every declaration here lives in `FormalSystem.Semantics`
(with sub-namespaces such as `PlusTruth`), so only the module path carries the `PlusLanguage` segment.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/PlusLanguage -->
| File | Lines | Description |
|------|------:|-------------|
| `PlusDeterminism.lean` | 153 | `app:deterministic`'s positive half: `states_eq_of_deterministic` (the singleton bridge), `stab_iff_of_deterministic`, `determined_of_deterministic`, `stab_biconditional_plusValidOn_of_deterministic` — the collapse `⊡φ ↔ φ` over every `TaskFrame.Deterministic` frame, choice-free (`[propext]` only) |
| `PlusNonValidities.lean` | 209 | The five refutations on `natFrame` over ℤ that bound the `⊡` axiom set from above (`⊡p → □⊡p`, `G⊡p → ⊡Gp`, `⊡GPp → G⊡Pp`, *Determined*, `P⊡p → ⊡Pp`) |
| `PlusPasting.lean` | 365 | `paste` — two total histories sharing a state paste into a total history — the purity congruences, and the pasting validities PS/US/FS/GS with their past mirrors |
| `PlusStateLocal.lean` | 429 | The **state-locality** fragment of L⁺: `PlusFormula.StateLocal` (syntactic, by structural recursion over all seven constructors — `box` and `stab` admitted for an *arbitrary* argument, `untl`/`snce` excluded) and `IsPlusStateLocal` (semantic); `isPlusStateLocal_box`, `isPlusStateLocal_stab`, the soundness induction `isPlusStateLocal_of_stateLocal`, the two non-preservation witnesses `not_isPlusStateLocal_someFuture` / `not_isPlusStateLocal_somePast` on `NF`, the headline `φ ↔ ⊡φ` (`plusStateLocal_stab_iff`, `plusStateLocal_plusValid_iff_stab`), and `stab_of_stateLocal` — the AS witness, strictly generalizing the atom-level `p → ⊡p` |
| `PlusTruth.lean` | 421 | `SameStateAt` (the paper's `⟨τ⟩_x`) and `PlusTruthAt` — the truth recursion for L⁺ (L plus the stability modal `⊡`, `PlusLanguage/Formula.lean`), the `PlusTruth.*` clause lemmas, the S5 validities of `⊡`, and `stab_state_only` |
| `PlusValidity.lean` | 225 | `PlusValidOnFrames`, `PlusValidIn`, `PlusValid` and per-class abbreviations — L⁺ mirrors of Validity.lean; `plusTruthAt_ofFormula` and `plusValidIn_ofFormula_iff`, semantic conservativity of L⁺ over L at every frame class |
<!-- END GENERATED -->

The sibling aggregator is `FormalSystem/Semantics/PlusLanguage.lean`, imported by the root
aggregator `FormalSystem/FormalSystem.lean` (not by `FormalSystem/Semantics.lean`), mirroring
`FormalSystem/Syntax/PlusLanguage.lean`.

## Related Documentation

- [Semantics README](../README.md)
- [Syntax/PlusLanguage README](../../Syntax/PlusLanguage/README.md) — the syntax and proof system of the same language
- [`Metalogic/Conservativity/Plus/`](../../Metalogic/Conservativity/Plus/README.md) — TM⁺ soundness and conservativity over TM

---

*Last verified: 2026-09-16*
