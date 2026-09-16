# PlusLanguage — the language L⁺ (L plus the stability modal `⊡`) and its logic TM⁺

This directory defines a **third object language** for the tree, **L⁺**, obtained from the
until/since-primitive language L (`FormalSystem/Syntax/Formula.lean`) by adding one primitive
unary operator, the **stability modal** `⊡` (`def:BLstar-semantics`):

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ
```

`⊡φ` holds at `(τ, x)` iff `φ` holds at `(σ, x)` for every world `σ` sharing `τ`'s world state
at `x`. L⁺ is therefore the **⊡-only fragment** of the manuscript's `\BL^\star`
(`sub:Extension`), not a language the manuscript names: `\BL^\star` additionally carries the
store/recall operators, which are **out of scope** here. Their time-register half is
**L⋆**, which is built at `FormalSystem/Syntax/StarLanguage/` — a separate inductive `StarFormula` with
its own embedding `ofPlus : PlusFormula → StarFormula`, its semantics over the manuscript's
points `(τ, x, v⃗)`, and the paper-label correspondence table for the deterministic-frame
appendix. See `FormalSystem/Syntax/StarLanguage/README.md`.

L⁺ is a **separate inductive** (`PlusFormula`) with a constructor-to-constructor embedding
`ofFormula : Formula → PlusFormula`, following the landed `MinusLanguage/` pattern
(`MinusFormula` and `tr`). Every derived operator has `Formula`'s right-hand side verbatim, so the
embedding commutes with each of them by `rfl` — the contract the proof-system embedding and the
atomization transfer rely on.

## Modules

| File | Description |
|------|-------------|
| `Formula.lean` | `PlusFormula`, the derived operators (with `Formula`'s right-hand sides), the `⊡`-specific `dstab`/`Will`/`will`/`Could`/`could`, `swapTemporal` (`stab ↦ stab`), the purity predicates `IsPureFuture`/`IsPurePast` with their `swapTemporal` exchange lemmas, and the embedding `ofFormula`/`ofCtx` with `ofFormula_injective`, `ofFormula_ne_stab`, `ofFormula_swapTemporal` |
| `Axioms.lean` | `PlusAxiom`, the **closed** inductive of TM⁺ schemata: the 45 TM schemata re-declared with `PlusFormula` parameters, plus eight `⊡` schemata — SK, ST, S4, S5 (S5 for `⊡`), MS `□φ → ⊡φ`, AS `p → ⊡p` for atoms, and the two pasting schemata PS `⟐φ⁺ → (⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻))` and US `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)` with pure-future/pure-past side conditions; `PlusAxiom.minFrameClass` |
| `Derivation.lean` | `PlusDerivationTree` (the seven rules of TM, constructor for constructor), `PlusDerivable`, `⊢⁺[fc]` notation, the derived `⊡`-necessitation rule `stabNecessitation`, and the backward conservativity bridge `PlusAxiom.ofTM` / `PlusDerivationTree.ofTM` / `plusDerivable_of_derivable`: `TM ⊢[fc] φ ⟹ TM⁺ ⊢[fc] ofFormula φ` |

The sibling aggregator is `FormalSystem/Syntax/PlusLanguage.lean`.

## Why the TM schemata are re-declared

An embedding constructor `Axiom φ → PlusAxiom (ofFormula φ)` would yield only `⊡`-free instances;
TM⁺ needs, for instance, MF at `⊡p` (`□⊡p → □G⊡p`). So the 45 schemata range over all of
`PlusFormula`, and `PlusAxiom.ofTM` is a *function* used only for the backward bridge — each
of its arms is `rfl`-shaped, so any drift between the two inductives fails to typecheck there.

## Where the L⁺ semantics and metatheory live

Nothing in this directory defines truth, validity, or a frame. The semantics sits on the far
side of the permitted import edge:

| File | What it carries |
|------|-----------------|
| `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean` | `SameStateAt` (the paper's `⟨τ⟩_x`) and `PlusTruthAt`, the seven-clause truth recursion; the S5 validities of `⊡`; `stab_state_only` |
| `FormalSystem/Semantics/PlusLanguage/PlusValidity.lean` | `PlusValidOnFrames`, `PlusValidIn`, `PlusValid`; `plusTruthAt_ofFormula` and `plusValidIn_ofFormula_iff` (semantic conservativity at every class) |
| `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean` | the history-pasting lemma and the pasting validities PS/US/FS/GS with their past mirrors |
| `FormalSystem/Semantics/PlusLanguage/PlusNonValidities.lean` | the five refutations on `natFrame` over ℤ that bound the axiom set |
| `FormalSystem/Metalogic/Conservativity/Plus.lean` | soundness of TM⁺ at all four classes and conservativity of TM⁺ over TM in both directions |

## Module Invariant

**Nothing under `FormalSystem/Syntax/PlusLanguage/` imports anything from `FormalSystem/Semantics/`.**
Checkable by `grep -rn 'FormalSystem.Semantics' FormalSystem/Syntax/PlusLanguage/`: only prose matches.
The invariant is directional, exactly as for `MinusLanguage/`; the converse edge is permitted and
is how L⁺ acquires its semantics.

## Extension recipe: adding a `PlusAxiom` constructor

`PlusAxiom` is closed, and exactly three declarations pattern-match on its constructors:

1. `PlusAxiom.minFrameClass` (`Axioms.lean`);
2. `plusAxiom_validIn_min` (`FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean`);
3. `plusAxiom_swap_validIn_min` (same file).

Neither dispatch lemma has a wildcard arm. Adding a constructor therefore means one constructor
line, one `minFrameClass` arm, and one arm in each dispatch lemma (a validity proof and a
swap-validity proof, typically a `PlusValid` from `Semantics/`); every other module —
`PlusDerivationTree`, `ofTM`, the soundness recursion, the conservativity theorems — refers to
`PlusAxiom` only through `minFrameClass` and the two lifted forms `plusAxiom_validIn` /
`plusAxiom_swap_validIn`, and recompiles unchanged. A schema valid only over a restricted frame
class no `FrameClass` tag denotes (for instance *Determined* `φ → ⊡φ`, refuted at `.Base`) must
**not** be added here; state its validity through `PlusValidOnFrames` over that predicate
instead.

## Related Documentation

- [FormalSystem README](../../README.md)
- [MinusLanguage README](../MinusLanguage/README.md) — the pattern this component follows
- [Syntax README](../README.md) — the L side being embedded
- [Semantics/PlusLanguage README](../../Semantics/PlusLanguage/README.md) — where the L⁺ semantics modules live
- [Metalogic README](../../Metalogic/README.md) — where `Conservativity/Plus/` lives

---

*Last verified: 2026-09-08*
