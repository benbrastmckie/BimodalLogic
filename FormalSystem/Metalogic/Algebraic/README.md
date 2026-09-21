# Algebraic Representation Infrastructure

**Status**: Active, on two different footings. `FlowFrame.lean` is infrastructure consumed by
the live completeness proof. The Boolean-algebra/ultrafilter layer (`LindenbaumQuotient.lean`,
`BooleanStructure.lean`, `InteriorOperators.lean`, `UltrafilterMCS.lean`) is standalone
sorry-free infrastructure with **no current consumer**; it is covered by `lake build` because
`Metalogic.lean` imports the sibling aggregator `../Algebraic.lean`. Ultrafilters of the
Lindenbaum algebra are encoded Mathlib-natively as `Order.PrimeFilter LindenbaumAlg`, with the
generic proper/maximal/prime-filter API supplied by `FormalSystem/ForMathlib/Order/PFilter.lean`
(see "Design decisions" below). `BooleanStructure.lean`'s fifteen `*_quot` lemmas total 105
inclusive source lines under the metric `awk '/^theorem [a-zA-Z_]*_quot/ …'` (from 286 before
they were discharged by `propDecide`).

This directory contains:
1. An algebraic approach to the representation theorem using Lindenbaum-Tarski algebra and ultrafilter theory
2. The generic flow-frame countermodel engine (`FlowFrame.lean`) and the re-hosted dense truth lemma
3. Boolean-algebra and ultrafilter foundations shared with `Core/`

The deterministic and dovetailed chain constructions that this directory once hosted are
**archived** to `Boneyard/ChainCompleteness/`; see the Chain Constructions table below.

## Purpose

The algebraic modules provide:
1. An alternative verification path for completeness via Boolean algebra theory
2. Infrastructure for Stone duality and algebraic topology extensions
3. A cleaner mathematical foundation for future algebraic modal logic research

**Note**: `BXCanonical/` is the wired completeness entry point, and **`FlowFrame.lean` is not
optional relative to it** — but that claim is about that one file, not about this directory as a
whole. `Algebraic.FlowFrame` has six live importers, and they are not all under `BXCanonical/`:
`BXCanonical/Completeness.lean`, `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`,
`BXCanonical/Chronicle/ChronicleMonadicBridge.lean` and `BXCanonical/DiscreteCarrierProbe.lean`,
plus `Bundle/LimitMCS.lean` and `WeakCanonical/GroupModel/CountermodelBase.lean`. That one file
is therefore part of the live proof, not merely adjacent to it.

The other four modules do stand beside it: they have no consumer anywhere in the live tree.
They are compiled by `lake build` (via the sibling aggregator, imported from `Metalogic.lean`),
not depended on by any proof. See [Metalogic README](../README.md) for the route diagram.

## Modules

The directory holds **5 `.lean` files, 2,425 lines**: `BooleanStructure.lean` (261),
`FlowFrame.lean` (794), `InteriorOperators.lean` (176), `LindenbaumQuotient.lean` (393), and
`UltrafilterMCS.lean` (801). Rows below that name any other file describe **archived** modules
under `Boneyard/` and are labelled as such.

### Boolean Algebra Foundation
| Module | Purpose | Status |
|--------|---------|--------|
| `../Algebraic.lean` | Re-export module for the Algebraic package. **Sibling aggregator**, at `FormalSystem/Metalogic/Algebraic.lean` — not a file inside this directory | Complete |
| `LindenbaumQuotient.lean` | Quotient by provable equivalence | **Sorry-free** |
| `BooleanStructure.lean` | Boolean algebra instance; the `*_quot` lattice/complement laws are closed by `propDecide` (`Automation/Tactics/PropDecide.lean`), the three hypothesis-driven ones via a `propDecide` tautology + `Combinators.pairing` + modus ponens | **Sorry-free** |
| `InteriorOperators.lean` | Box as interior operator; H monotonicity | **Sorry-free** |
| `TenseS5Algebra.lean` | Tense S5 algebra structure | **Archived** (3 sorries; moved to `Boneyard/UltrafilterFrame/`) |
| `UltrafilterMCS.lean` | MCS ↔ `Order.PrimeFilter LindenbaumAlg` bijection, packaged as `SetMaximalConsistent.ultrafilterEquiv`; consumes `FormalSystem/ForMathlib/Order/PFilter.lean` | **Sorry-free** |

### Ultrafilter Frame Infrastructure (Archived to `Boneyard/UltrafilterFrame/`)
| Module | Purpose | Status |
|--------|---------|--------|
| `UltrafilterFrame.lean` | R_G/R_H/R_Box, UltrafilterChain, F/P resolution | **Archived** (2 sorries for temp_4) |

### Flow-Frame Countermodel Engine
| Module | Purpose | Status |
|--------|---------|--------|
| `FlowFrame.lean` | Generic multi-family flow frame, four-axiom conformance + totality layer, bundle flow frame/model, re-hosted dense truth lemma | **Sorry-free** |

The former parametric canonical stack (`ParametricHistory`/`ParametricTruthLemma`/
`ParametricCanonical`/`ParametricCompleteness`/`RestrictedParametricTruthLemma`) is deleted:
its frame violated the frame definition's *Limit* axiom over dense duration types, and its
truth lemma is re-hosted on `bundleFlowFrame` in `FlowFrame.lean`.

### Chain Constructions (Archived to Boneyard/ChainCompleteness)
| Module | Purpose | Status |
|--------|---------|--------|
| `DeterministicChain.lean` | Deterministic chain construction | **Archived** |
| `DeterministicFMCS.lean` | FMCS/BFMCS bundle + completeness wiring | **Archived** |
| `FiniteDeferral.lean` | Finite deferral infrastructure for forward_F | **Archived** |

## Dependency Flowchart

```
Boolean Algebra Path:

    Automation/Tactics/PropDecide          Mathlib (Order.PrimeIdeal, Order.PrimeSeparator)
                │                                        │
                v                                        v
                LindenbaumQuotient            ForMathlib/Order/PFilter  (Order.PFilter.IsProper /
                         │                              │               IsMaximal, Order.PrimeFilter)
            ┌────────────┼────────────┐                 │
            v            v            v                 │
    BooleanStructure  InteriorOps  TenseS5Algebra       │
            │            │           (archived)         │
            └────────────┤                              │
                         v                              │
              UltrafilterMCS  <─────────────────────────┘
                         │
                         v
           (ultrafilter representation; no completeness theorem is stated here)

    Import direction is strictly Mathlib → ForMathlib → Metalogic/Algebraic/UltrafilterMCS → downstream;
    nothing under FormalSystem/ForMathlib/ imports FormalSystem.*.

Completeness Path (current):

    FlowFrame (generic frame + conformance + totality)
        │
        v
    FlowFrame (bundleFlowFrame/Model/Omega + re-hosted truth lemma)
        │
        v
    BXCanonical countermodels (Completeness.lean, CompletenessDedekind.lean)
```

## Key Definitions

### Lindenbaum Quotient (`LindenbaumQuotient.lean`)

```lean
def ProvEquiv (phi psi : Formula) : Prop := Derives phi psi ∧ Derives psi phi
def LindenbaumAlg : Type := Quotient ProvEquiv.setoid
```

The Lindenbaum-Tarski algebra is the quotient of formulas by provable equivalence.

### Boolean Structure (`BooleanStructure.lean`)

```lean
instance : BooleanAlgebra LindenbaumAlg where
  -- Order: [phi] <= [psi] <-> derives phi psi
  -- Operations: [phi] ⊔ [psi] = [phi ∨ psi], etc.
```

The quotient forms a Boolean algebra with order defined by derivability.

### Interior Operators (`InteriorOperators.lean`)

```lean
structure InteriorOp (alpha : Type*) [PartialOrder alpha] where
  toFun : alpha -> alpha
  le_self : ∀ a, toFun a <= a         -- Deflationary
  monotone : ∀ a b, a <= b -> toFun a <= toFun b
  idempotent : ∀ a, toFun (toFun a) = toFun a
```

`boxInterior` (`InteriorOperators.lean`) is the only `InteriorOp` built here. It is
assembled from `box_le_self`, `box_monotone` and `box_idempotent`,
which hold because the modal T-axiom `Box phi -> phi` is valid under S5 accessibility.

G and H are **not** interior operators under strict temporal semantics: `G phi -> phi` and
`H phi -> phi` fail when G and H quantify over strictly future/past times. `H_monotone`
is the only surviving G/H-family result, and there is **no G operator on the quotient at all** —
the quotient carries `boxQuot` (`LindenbaumQuotient.lean`), `hQuot` and `negQuot`, with no G counterpart anywhere in the tree. The module's own docstring
(`InteriorOperators.lean`) states this and is the model this section follows.

### Ultrafilter-MCS Correspondence (`UltrafilterMCS.lean`)

```lean
def mcsToPFilter    : {S // SetMaximalConsistent S} -> Order.PFilter LindenbaumAlg
def mcsToUltrafilter : {S // SetMaximalConsistent S} -> Order.PrimeFilter LindenbaumAlg
def ultrafilterToSet : Order.PrimeFilter LindenbaumAlg -> Set Formula
noncomputable def SetMaximalConsistent.ultrafilterEquiv :
    {Γ : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) Γ} ≃ Order.PrimeFilter LindenbaumAlg
theorem SetMaximalConsistent.ultrafilter_correspondence : -- existential corollary of the Equiv
```

Establishes the bijection between prime filters (= ultrafilters) of the Lindenbaum algebra and
maximal consistent sets. `mcsToPFilter Γ` is `mcsToSet Γ` bundled via `Order.IsPFilter.toPFilter`,
with `IsProper`/`IsPrime` instances from `mcsToSet_bot_not_mem` and `mcsToSet_compl_or`; the
`Equiv`'s `left_inv` is the three-line `toQuot_mem_mcsToSet_iff`, and `ultrafilter_correspondence`
is `⟨e, e.symm, e.left_inv, e.right_inv⟩`. The fold lemma `fold_le_of_derives` is stated over
`Multiset.inf` of the mapped list.

## Design decisions

**Ultrafilters are Mathlib-native prime filters.** The layer once carried a bespoke seven-field
`structure Ultrafilter` that shadowed Mathlib's. Mathlib's own `Ultrafilter α` is a filter on
`Set α` (it `extends Filter α`), not an ultrafilter of an arbitrary Boolean algebra, so it was
never the right target; `Order.PFilter.IsPrime` (`Mathlib/Order/PrimeIdeal.lean`) is. The chosen
encoding is `Order.PrimeFilter P := {F : Order.PFilter P // F.IsPrime}`, an `abbrev` supplied by
`FormalSystem/ForMathlib/Order/PFilter.lean` together with the `IsProper`/`IsMaximal` API and
Boolean-algebra section that Mathlib has on the ideal side but not on the filter side. The
reasons, in order of weight:

- *Two dualities, one of them free.* The order dual costs nothing: `Order.PFilter.mem_dual_iff`,
  `le_iff_dual_le`, `lt_iff_dual_lt`, `coe_eq_univ_iff` are all `Iff.rfl`, so every filter-side
  statement is a definitional repackaging of its `Order.Ideal` dual. The alternative encoding —
  `{I : Order.Ideal α // I.IsMaximal}` with the Boolean *complement* as the bridge — inverts every
  downstream membership statement (`a ∈ U` becomes `aᶜ ∈ I`), an ergonomic tax on exactly the
  consumers this layer exists for.
- *`IsPrime` suffices.* `IsPrime`'s single field `compl_ideal : IsIdeal (F : Set P)ᶜ` bundles
  `IsIdeal.Nonempty`, so `Order.PFilter.IsPrime.toIsProper` is a three-line instance and
  `IsProper` is a consequence, not a prerequisite. On a Boolean algebra prime filters are exactly
  the ultrafilters (`Order.PFilter.IsPrime.isMaximal`, `IsMaximal.isPrime`).
- *No bridge lemma was written.* Where the deleted structure would have needed a hand-written
  `Equiv` to Mathlib's ideals, the ideal is already `U.2.toPrimePair.I` — the complement ideal
  packaged by `Order.PFilter.IsPrime.toPrimePair`.
- *One seen-and-accepted trade-off.* `Order.PrimeFilter` is an `abbrev` subtype rather than a
  `SetLike` `structure` following Mathlib's bundled-subobject template (`Mathlib/Data/SetLike/Basic.lean`;
  compare `PrimeSpectrum`, a `structure` with `equivSubtype` as a bridge *to* the subtype). This is
  the one place a Mathlib reviewer would predictably push back on upstreaming; the generic
  `Order.PFilter` half of the file is unaffected either way.

*Textbook statement.* The prime-filter vocabulary is the textbook one: Chagrov and
Zakharyaschev, *Modal Logic* (1997), Part III §8.2 "The Stone and Jónsson–Tarski theorems",
Theorem 8.14 (pp. 241–243), states Stone's representation with the Stone space defined as the set
of all prime filters of the algebra and the representing map sending an element to the set of
prime filters containing it, via the prime-filter separation of Corollary 7.42.

*Mathlib coverage at the pin* (`v4.33.0-rc1`, `79d0395a`). Mathlib has no Stone representation
theorem for Boolean algebras and no Priestley duality: `Mathlib/Order/Birkhoff.lean` scopes itself
to *finite* Stone duality ("TODO: extend to morphisms"), `Mathlib/Topology/Order/Priestley.lean`
defines only the `PriestleySpace` mixin and three clopen-separation lemmas, and
`Mathlib/Order/Category/BoolAlg.lean` is the bare category. `Mathlib/Order/PrimeSeparator.lean`
(van Gool, 2024) names Stone's duality for bounded distributive lattices as its purpose and leaves
the prime-*filter* separator as a commented-out TODO for want of a prime-filter vocabulary.
`ForMathlib/Order/PFilter.lean` is therefore the next brick in a direction a Mathlib author has
already begun — which is why it is kept PR-shaped (Mathlib's namespace, lemma names one-for-one
with their ideal duals, `*_iff_dual` transports, no `FormalSystem.*` import) and why it states the
separator's filter-side corollary, `DistribLattice.prime_filter_of_disjoint_filter_ideal`, with
exactly the TODO's name and shape.

**`propDecide` in `BooleanStructure.lean`.** The lattice and complement laws of the Boolean
algebra are closed propositional tautologies over the representatives, so `BooleanStructure.lean`
imports `FormalSystem.Metalogic.Decidability.Propositional.Tactic` and discharges them by
`induction … using Quotient.ind with | _ φ =>` / `change Derives …` / `unfold Derives` /
`propDecide`. The three hypothesis-driven laws (`le_inf_quot`, `sup_le_quot`; `le_trans_quot` was
already minimal) state their conditional form as a closed tautology, close it with `propDecide`,
and combine with the hypotheses through `Combinators.pairing` and modus ponens. There is no
cycle: nothing under `Metalogic/Decidability/`, `Metalogic/Core/`, `Theorems/` or `Automation/`
imports an `Algebraic.*` module, so `Automation/Tactics/PropDecide.lean` sits strictly below this
directory.

**What the layer now offers downstream** (durable anchors): Lindenbaum's lemma on the filter side,
`Order.PFilter.IsProper.exists_le_maximal` and, on a Boolean algebra,
`Order.PFilter.IsProper.exists_le_prime`; the Zorn-free separator
`DistribLattice.prime_filter_of_disjoint_filter_ideal`; the complement ideal of a prime filter as
`U.2.toPrimePair`; and the Boolean characterisation `Order.PFilter.isPrime_iff_mem_or_compl_mem`
with its `mem_iff_compl_notMem` / `compl_mem_iff_notMem` corollaries.

**Documented gap.** Mathlib gives `Order.PFilter P` no lattice structure (`Order.Ideal P` has one
under `[SemilatticeSup P] [IsCodirectedOrder P]`, `Mathlib/Order/Ideal.lean`; `PFilter` has no
`Max` instance at all). A representation construction that needs `F ⊔ Order.PFilter.principal x`
must first transport that lattice through the order dual — a five-line `⟨F.dual ⊔ G.dual⟩` job —
which this layer deliberately does not write. Meet it as a documented five-line task, not as a
surprise.

## Mathematical Overview

The algebraic approach proceeds as follows:

1. **Lindenbaum-Tarski Algebra**: Define provable equivalence `phi ~ psi <-> derives phi <-> psi`
   and form the quotient `LindenbaumAlg := Formula / ~`

2. **Boolean Structure**: Show `LindenbaumAlg` is a `BooleanAlgebra` where:
   - Order: `[phi] <= [psi] <-> derives phi -> psi`
   - Operations: `[phi] ⊔ [psi] = [phi ∨ psi]`, `[phi] ⊓ [psi] = [phi ∧ psi]`, etc.

3. **Interior Operators**: Show Box is an interior operator on the quotient (`boxInterior`):
   - Deflationary: `Box[phi] <= [phi]` (from the modal T-axiom `Box phi -> phi`)
   - Monotone: `[phi] <= [psi] -> Box[phi] <= Box[psi]` (from K-distribution)
   - Idempotent: `Box(Box[phi]) = Box[phi]` (from the modal 4-axiom `Box phi -> Box Box phi`)

   G and H are not interior operators here: under strict temporal semantics their T-axioms
   fail, so only `H_monotone` survives and no G operator is defined on the quotient.

4. **Ultrafilter-MCS Correspondence**: Establish bijection between:
   - Ultrafilters of `LindenbaumAlg`
   - Maximal consistent sets

5. **Representation Theorem**: Prove satisfiability via ultrafilters

## Relationship to Main Proof Path

The wired completeness entry point is `BXCanonical/`, which consumes this directory's
`FlowFrame.lean` directly. The supporting layers are:
- `Core/` - MCS foundations (shared)
- `Bundle/` - BFMCS canonical-frame construction via bundled MCS families
- `Algebraic/` - Boolean-algebra and ultrafilter foundations, plus the flow-frame countermodel
  engine that `BXCanonical` imports

This directory additionally provides:
- Independent verification that MCS theory is sound
- An alternative route from consistency to satisfiability
- Foundation for future Stone duality extensions

## Future Extension Opportunities

1. **Stone Duality**: Connect ultrafilters to points of Stone space
2. **Algebraic Topology**: Extend interior operators to topological semantics
3. **Coalgebraic Methods**: Duality with canonical coalgebra structures
4. **Alternative Completeness**: Finish algebraic completeness path if desired

## Dependencies

- **Mathlib**: `BooleanAlgebra`, `Quotient`, `Multiset.inf`, `Order.PFilter` / `Order.PFilter.IsPrime`
  (`Mathlib/Order/PrimeIdeal.lean`), `Mathlib/Order/PrimeSeparator.lean`
- **ProofChecker**: `FormalSystem.ProofSystem`, `FormalSystem.Metalogic.Core`,
  `FormalSystem.ForMathlib.Order.PFilter`, `FormalSystem.Metalogic.Decidability.Propositional.Tactic`

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Core README](../Core/README.md) - MCS foundations shared by both approaches
- [Bundle README](../Bundle/README.md) - BFMCS canonical-frame construction
- [Decidability README](../Decidability/README.md) - Decision procedure

## References

- Modal Logic, Blackburn et al., Chapter 5 (Algebraic Semantics)
- Chagrov and Zakharyaschev, *Modal Logic* (1997), Part III §8.2, Theorem 8.14 (Stone
  representation in prime-filter vocabulary)
- Stone Duality: Boolean Algebras and Topological Spaces

---

*Last verified: 2026-09-07*

*Last updated: 2026-09-03*
