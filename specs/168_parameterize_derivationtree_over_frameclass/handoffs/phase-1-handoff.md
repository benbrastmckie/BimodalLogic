# Phase 1 Handoff: Core Type Definitions

**Task**: 168 - Parameterize DerivationTree over FrameClass
**Phase**: 1 of 7
**Status**: COMPLETED
**Session**: sess_1779755827_2a0c74
**Date**: 2026-05-25

## Summary

Phase 1 is complete. Both `Axioms.lean` and `Derivation.lean` compile cleanly. All 10 sub-tasks are done. Zero sorries, zero vacuous definitions, zero new axioms.

## Exact Changes Made

### Theories/Bimodal/ProofSystem/Axioms.lean

1. **Added density axiom constructor** (line 385): `| density (φ : Formula) : Axiom (φ.all_future.all_future.imp φ.all_future)` -- placed after z1 as Layer 8. Constructor count is now 41.

2. **Added LE instance on FrameClass** (line 416): Base ≤ anything is True, Dense ≤ Dense is True, Discrete ≤ Discrete is True, all others False.

3. **Added DecidableRel instance** (line 423): For `LE.le` on FrameClass, enabling `decide` when the frame class values are known.

4. **Added PartialOrder instance** (line 426): Proves le_refl, le_trans, le_antisymm by case splitting.

5. **Defined Axiom.minFrameClass** (line 444): Replaced old `Axiom.frameClass` and `Axiom.minimalFrameClass` abbreviation. Maps density to .Dense, prior_UZ/prior_SZ/z1 to .Discrete, all 37 others to .Base.

6. **Removed all ad-hoc predicates**: `Axiom.isBase`, `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible`, and supporting theorems `frameClass_eq_base_iff_isBase`, `isDiscreteCompatible_iff_frameClass`, `isBase_implies_both_compatible`, `discreteness_forward_not_dense_compatible`.

7. **Updated module docstrings**: Constructor count 40 -> 41, added Layer 8 (Density) documentation, added FrameClass partial order diagram and design-intent docstring.

### Theories/Bimodal/ProofSystem/Derivation.lean

1. **Parameterized DerivationTree** (line 80): `inductive DerivationTree (fc : FrameClass) : Context -> Formula -> Type` with `axiom` constructor taking `(h_fc : h.minFrameClass <= fc)`.

2. **Added DerivationTree.lift** (line 190): `lift {fc1 fc2 : FrameClass} (h_le : fc1 <= fc2) {G : Context} {f : Formula} : DerivationTree fc1 G f -> DerivationTree fc2 G f`. Uses le_trans at the axiom case, structural recursion elsewhere.

3. **Updated height function** (line 223): Added `{fc : FrameClass}` implicit and `_` for the h_fc field in the axiom pattern.

4. **Updated all height theorems** (lines 236-290): Added `{fc : FrameClass}` implicit to all 7 height property theorems.

5. **Removed DerivationTree.isDenseCompatible and isDiscreteCompatible** (previously lines 266-290).

6. **Added notation** (lines 335-357): Four notations -- `G |-[fc] f`, `|-[fc] f`, `G |- f` (defaults to .Base), `|- f` (defaults to .Base).

7. **Updated examples** (lines 365-383): Examples use `trivial` for h_fc proofs since `Base <= Base` is definitionally `True`. Added density axiom example and lift example.

8. **Updated module docstrings**: Documented frame class parameterization, lift semantics, notation conventions.

## New Type Signatures

```lean
-- Core type (parameterized)
inductive DerivationTree (fc : FrameClass) : Context -> Formula -> Type

-- Axiom constructor (gated)
| axiom (G : Context) (f : Formula) (h : Axiom f) (h_fc : h.minFrameClass <= fc)
    : DerivationTree fc G f

-- Lift function (monotonicity)
def DerivationTree.lift {fc1 fc2 : FrameClass} (h_le : fc1 <= fc2)
    {G : Context} {f : Formula} : DerivationTree fc1 G f -> DerivationTree fc2 G f

-- Minimum frame class (single source of truth)
def Axiom.minFrameClass {f : Formula} : Axiom f -> FrameClass

-- Height (unchanged semantics, new fc parameter)
def DerivationTree.height {fc : FrameClass} {G : Context} {f : Formula}
    : DerivationTree fc G f -> Nat
```

## Design Decisions

1. **h_fc proof style**: For base axioms where `minFrameClass` returns `.Base`, the proof obligation `Base <= fc` reduces to `True` for any fc, so `trivial` works universally. This is the most ergonomic choice -- no need for `by decide` (which fails on universally quantified variables) or `le_refl` (which only works when fc = Base).

2. **Notation order**: `|-[fc]` notations are defined BEFORE the defaulting `|-` notations. This matters because Lean resolves notation by trying later definitions first, so `|-` (which defaults to Base) takes priority over `|-[fc]` when no frame class is explicitly given. Both forms are available.

3. **lift argument order**: `h_le` is the first explicit argument (after the two implicit frame classes) rather than the last, making it natural to write `d.lift h_le` or `DerivationTree.lift h_le d`.

4. **No Decidable instance for minFrameClass <= fc**: The `decide` tactic cannot handle `h.minFrameClass <= fc` when h contains free variables (e.g., `Axiom.modal_t p` where p is universally quantified). Instead, `trivial` works for all base axioms (since `Base <= _` is `True`), and specific frame-class proofs can be given for dense/discrete axioms.

## Known Downstream Breakage (Expected)

All downstream files that use DerivationTree will fail because:
- DerivationTree now takes `fc` as a first parameter
- The axiom constructor requires `h_fc` proof
- Old notation `G |- f` now means `DerivationTree .Base G f` (was `DerivationTree G f`)
- `isDenseCompatible` and `isDiscreteCompatible` are gone (referenced in soundness files)
- `isBase`, `isDenseCompatible`, `isDiscreteCompatible` on Axiom are gone (referenced in soundness lemma files)
- `frameClass` is renamed to `minFrameClass`

Expected impacted files (from research report): 71 live files reference DerivationTree.

## Build Status

- `lake build Bimodal.ProofSystem.Axioms`: PASSES (657 jobs, 2.5s)
- `lake build Bimodal.ProofSystem.Derivation`: PASSES (659 jobs, 3.2s)

## Next Action

Phase 2: Update ProofSystem layer -- Derivable.lean, Substitution.lean, LinearityDerivedFacts.lean. Thread `fc` parameter through all definitions and lemmas. The `|-` notation defaulting to Base should minimize changes in files that only use base axioms.
