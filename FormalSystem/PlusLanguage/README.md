# PlusLanguage — the language L⁺ (L plus the stability modal `⊡`) and its logic TM⁺

This directory is a self-contained component at the library root, holding **all** of the
language L⁺: its syntax, its proof system TM⁺, and its semantics. It was assembled by the
language-extension merge, which collapsed the two directories the syntax and semantics halves
used to occupy under `Syntax/` and `Semantics/` into this single one.

It defines a **third object language** for the tree, **L⁺**, obtained from the
until/since-primitive language L (`FormalSystem/Syntax/Formula.lean`) by adding one primitive
unary operator, the **stability modal** `⊡` (`def:BLstar-semantics`):

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ
```

`⊡φ` holds at `(τ, x)` iff `φ` holds at `(σ, x)` for every world `σ` sharing `τ`'s world state
at `x`. L⁺ is therefore the **⊡-only fragment** of the manuscript's `\BL^\star`
(`sub:Extension`), not a language the manuscript names: `\BL^\star` additionally carries the
store/recall operators, which are **out of scope** here. Their time-register half is
**L⋆**, which is built at `FormalSystem/StarLanguage/` — a separate inductive `StarFormula` with
its own embedding `ofPlus : PlusFormula → StarFormula`, its semantics over the manuscript's
points `(τ, x, v⃗)`, and the paper-label correspondence table for the deterministic-frame
appendix. See `FormalSystem/StarLanguage/README.md`.

L⁺ is a **separate inductive** (`PlusFormula`) with a constructor-to-constructor embedding
`ofFormula : Formula → PlusFormula`, following the landed `MinusLanguage/` pattern
(`MinusFormula` and `tr`). Every derived operator has `Formula`'s right-hand side verbatim, so the
embedding commutes with each of them by `rfl` — the contract the proof-system embedding and the
atomization transfer rely on.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/PlusLanguage -->
| File | Lines | Description |
|------|------:|-------------|
| `Axioms.lean` | 338 | `PlusAxiom`, the **closed** inductive of TM⁺ schemata: the 45 TM schemata re-declared with `PlusFormula` parameters, plus eight `⊡` schemata — SK, ST, S4, S5 (S5 for `⊡`), MS `□φ → ⊡φ`, AS `p → ⊡p` for atoms, and the two pasting schemata PS and US with pure-future/pure-past side conditions; `PlusAxiom.minFrameClass` |
| `Derivation.lean` | 288 | `PlusDerivationTree` (the seven rules of TM, constructor for constructor), `PlusDerivable`, `⊢⁺[fc]` notation, the derived `⊡`-necessitation rule `stabNecessitation`, and the backward conservativity bridge `PlusAxiom.ofTM` / `PlusDerivationTree.ofTM` / `plusDerivable_of_derivable` |
| `Formula.lean` | 466 | `PlusFormula`, the derived operators (with `Formula`'s right-hand sides), the `⊡`-specific `dstab`/`Will`/`will`/`Could`/`could`, `reflectTime` (`stab ↦ stab`), the purity predicates `IsPureFuture`/`IsPurePast` with their `reflectTime` exchange lemmas, and the embedding `ofFormula`/`ofCtx` |
| `PlusDeterminism.lean` | 154 | `app:deterministic`'s positive half: `states_eq_of_deterministic` (the singleton bridge), `stab_iff_of_deterministic`, `determined_of_deterministic`, `stab_biconditional_plusValidOn_of_deterministic` — the collapse `⊡φ ↔ φ` over every `TaskFrame.Deterministic` frame, choice-free (`[propext]` only) |
| `PlusLimitClosure.lean` | 287 | The limit-closure formula `blc p` and `blc_plusValid`, its validity at `.Base`: the general lemma `PartialHistory.exists_maximal_of_chainClosed` (Zorn plus the Extension Theorem), instantiated at `LCProp` to give `limit_history`, with one `paste` closing the argument |
| `PlusNonValidities.lean` | 205 | The five refutations on `natFrame` over ℤ that bound the `⊡` axiom set from above (`⊡p → □⊡p`, `G⊡p → ⊡Gp`, `⊡GPp → G⊡Pp`, *Determined*, `P⊡p → ⊡Pp`) |
| `PlusPasting.lean` | 339 | `paste` — two total histories sharing a state paste into a total history — the purity congruences, and the pasting validities PS/US/FS/GS with their past mirrors |
| `PlusStateLocal.lean` | 411 | The **state-locality** fragment of L⁺: `PlusFormula.StateLocal` (syntactic) and `IsPlusStateLocal` (semantic); the soundness induction `isPlusStateLocal_of_stateLocal`, the two non-preservation witnesses on `NF`, the headline `φ ↔ ⊡φ`, and `stab_of_stateLocal` — the AS witness, strictly generalizing the atom-level `p → ⊡p` |
| `PlusTruth.lean` | 340 | `PlusTruthAt` (the stab clause renders the paper's `⟨τ⟩_x` as `τ.state x = σ.state x`) — the truth recursion for L⁺, the `PlusTruth.*` clause lemmas, the S5 validities of `⊡`, and `stab_state_only` |
| `PlusValidity.lean` | 212 | `PlusValidOnFrames`, `PlusValidIn`, `PlusValid` and per-class abbreviations — L⁺ mirrors of Validity.lean; `plusTruthAt_ofFormula` and `plusValidIn_ofFormula_iff`, semantic conservativity of L⁺ over L at every frame class |
| `Substitution.lean` | 242 | `substPlus`, the interpretation of L in L⁺ at an arbitrary atom assignment, and the substitution transfer `plusDerivable_substPlus`, which makes every TM *schema* available at L⁺ arguments containing `⊡` |
<!-- END GENERATED -->

The sibling aggregator is `FormalSystem/PlusLanguage.lean`, imported by the root aggregator
`FormalSystem/FormalSystem.lean`.

## Why the TM schemata are re-declared

An embedding constructor `Axiom φ → PlusAxiom (ofFormula φ)` would yield only `⊡`-free instances;
TM⁺ needs, for instance, MF at `⊡p` (`□⊡p → □G⊡p`). So the 45 TM-shaped schemata (29 TM axioms, 16 TM-derivable) range over all of
`PlusFormula`, and `PlusAxiom.ofTM` is a *function* used only for the backward bridge — each
of its arms is `rfl`-shaped, so any drift between the two inductives fails to typecheck there.

## Syntax before semantics

The two halves of this directory are ordered, even though they now share it. `Formula.lean`,
`Axioms.lean`, `Derivation.lean` and `Substitution.lean` define no truth relation, no validity
predicate and no frame, and import nothing from `FormalSystem/Semantics/`. The semantic modules
beside them do, and that edge is what gives L⁺ its meaning:

| File | What it carries |
|------|-----------------|
| `PlusTruth.lean` | `PlusTruthAt`, the seven-clause truth recursion (the paper's `⟨τ⟩_x` as a state equation); the S5 validities of `⊡`; `stab_state_only` |
| `PlusValidity.lean` | `PlusValidOnFrames`, `PlusValidIn`, `PlusValid`; `plusTruthAt_ofFormula` and `plusValidIn_ofFormula_iff` (semantic conservativity at every class) |
| `PlusPasting.lean` | the history-pasting lemma and the pasting validities PS/US/FS/GS with their past mirrors |
| `PlusNonValidities.lean` | the five refutations on `natFrame` over ℤ that bound the axiom set |
| `PlusDeterminism.lean` | `app:deterministic`'s positive half: the deterministic collapse `⊡φ ↔ φ`, choice-free |
| `PlusStateLocal.lean` | the state-locality fragment of L⁺ and its headline `φ ↔ ⊡φ` |
| `PlusLimitClosure.lean` | the limit-closure formula `blc` and its validity at `.Base` |

The two cross-language bridges stay at the `Semantics/` root, because each spans two families:
`Semantics/DeterministicBridge.lean` (`lem:deterministic-singleton` as a biconditional) and
`Semantics/StateLocalTransfer.lean` (the L⁺ and L⋆ state-locality fragments agree along
`ofPlus`). `FormalSystem/Metalogic/Conservativity/Plus.lean` carries soundness of TM⁺ at all
four classes and conservativity of TM⁺ over TM in both directions.

This ordering is prose, recorded in `FormalSystem/PlusLanguage.lean`'s module docstring as the
component's standing invariant. No mechanical check enforces it; before the merge, the directory
boundary did.

## Extension recipe: adding a `PlusAxiom` constructor

`PlusAxiom` is closed, and exactly three declarations pattern-match on its constructors:

1. `PlusAxiom.minFrameClass` (`Axioms.lean`);
2. `plusAxiom_validIn_min` (`FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean`);
3. `plusAxiom_reflect_time_validIn_min` (same file).

Neither dispatch lemma has a wildcard arm. Adding a constructor therefore means one constructor
line, one `minFrameClass` arm, and one arm in each dispatch lemma (a validity proof and a
reflection-validity proof, typically a `PlusValid` from this directory's semantic half); every
other module —
`PlusDerivationTree`, `ofTM`, the soundness recursion, the conservativity theorems — refers to
`PlusAxiom` only through `minFrameClass` and the two lifted forms `plusAxiom_validIn` /
`plusAxiom_reflect_time_validIn`, and recompiles unchanged. A schema valid only over a restricted
frame class no `FrameClass` tag denotes (for instance *Determined* `φ → ⊡φ`, refuted at `.Base`)
must **not** be added here; state its validity through `PlusValidOnFrames` over that predicate
instead.

## Related Documentation

- [FormalSystem README](../README.md)
- [MinusLanguage README](../MinusLanguage/README.md) — the pattern this component follows
- [StarLanguage README](../StarLanguage/README.md) — the language extending this one
- [Syntax README](../Syntax/README.md) — the L side being embedded
- [Semantics README](../Semantics/README.md) — the L semantics this one mirrors
- [Metalogic README](../Metalogic/README.md) — where `Conservativity/Plus/` lives

---

*Last verified: 2026-09-21*
