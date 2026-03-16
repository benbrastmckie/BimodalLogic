# Research Report: Fix ProofSearch Example Sorries

**Task**: 975
**Session**: sess_1742169600_975res
**Date**: 2026-03-16

## Summary

The three sorry placeholders in `ProofSearch.lean` (lines 1348, 1353, 1358) are in example blocks demonstrating hypothetical proof search usage. Since `bounded_search` returns `Bool`, not `DerivationTree`, these examples need direct witnesses using available constructors.

## Analysis of Each Sorry

### Example 1 (Line 1348): `box p -> p` Axiom Instance

**Goal**: `exists (proof : DerivationTree [] ((Formula.atom_s "p").box.imp (Formula.atom_s "p"))), True`

**Formula**: `box p -> p` where `p = Formula.atom_s "p"`

**Solution**: This matches exactly `Axiom.modal_t` which states `box phi -> phi`. Use `DerivationTree.axiom` with `Axiom.modal_t`.

```lean
let p := Formula.atom_s "p"
Intro.mk (DerivationTree.axiom [] (p.box.imp p) (Axiom.modal_t p)) trivial
```

### Example 2 (Line 1353): Modus Ponens Witness

**Goal**: `exists (proof : DerivationTree [] q), True`
**Given**: `h1 : DerivationTree [] p` and `h2 : DerivationTree [] (p.imp q)`

**Solution**: Apply modus ponens using the hypotheses.

```lean
Intro.mk (DerivationTree.modus_ponens [] p q h2 h1) trivial
```

Note: The hypotheses in the example have the wrong order - `h1` should be the implication and `h2` the antecedent based on `modus_ponens` signature. However, the current naming has:
- `h1 : DerivationTree [] p`
- `h2 : DerivationTree [] (p.imp q)`

The `modus_ponens` constructor is:
```lean
| modus_ponens (Gamma : Context) (phi psi : Formula)
    (d1 : DerivationTree Gamma (phi.imp psi))
    (d2 : DerivationTree Gamma phi) : DerivationTree Gamma psi
```

So the correct application is `DerivationTree.modus_ponens [] p q h2 h1`.

### Example 3 (Line 1358): Assumption from Context

**Goal**: `exists (proof : DerivationTree [p.box] p.box), True`
**Given**: `h : DerivationTree [p.box] p` (unused - the hypothesis `h` is not needed)

**Solution**: Use `DerivationTree.assumption` since `p.box` is in the context `[p.box]`.

```lean
Intro.mk (DerivationTree.assumption [p.box] p.box (by simp)) trivial
```

Note: The provided hypothesis `h : DerivationTree [p.box] p` is unused. The example claims to need modal K distribution, but actually `p.box` is directly in the context, so `assumption` suffices. The hypothesis `h` proving `p` from `[p.box]` is irrelevant - what we need is to derive `p.box` from context `[p.box]`, which is trivial.

## DerivationTree Constructors Reference

From `Theories/Bimodal/ProofSystem/Derivation.lean`:

| Constructor | Signature | Use Case |
|-------------|-----------|----------|
| `axiom` | `(Gamma : Context) (phi : Formula) (h : Axiom phi)` | Any axiom instance |
| `assumption` | `(Gamma : Context) (phi : Formula) (h : phi in Gamma)` | Formula in context |
| `modus_ponens` | `(Gamma) (phi psi) (d1 : Gamma vdash phi.imp psi) (d2 : Gamma vdash phi)` | Implication elimination |
| `necessitation` | `(phi) (d : [] vdash phi)` | From theorem, derive `box phi` |
| `weakening` | `(Gamma Delta phi) (d : Gamma vdash phi) (h : Gamma subseteq Delta)` | Add assumptions |

## Recommended Fixes

### Fix 1 (Line 1348)
```lean
/-- Example: Trivial search finds axiom immediately -/
example : exists (proof : DerivationTree [] ((Formula.atom_s "p").box.imp (Formula.atom_s "p"))), True :=
  let p := Formula.atom_s "p"
  Intro.mk (DerivationTree.axiom [] (p.box.imp p) (Axiom.modal_t p)) trivial
```

### Fix 2 (Line 1353)
```lean
/-- Example: Search with depth 2 for modus ponens application -/
example (p q : Formula) (h1 : DerivationTree [] p) (h2 : DerivationTree [] (p.imp q)) :
    exists (proof : DerivationTree [] q), True :=
  Intro.mk (DerivationTree.modus_ponens [] p q h2 h1) trivial
```

### Fix 3 (Line 1358)
```lean
/-- Example: Modal K search requires context transformation -/
example (p : Formula) (h : DerivationTree [p.box] p) :
    exists (proof : DerivationTree [p.box] p.box), True :=
  Intro.mk (DerivationTree.assumption [p.box] p.box (by simp)) trivial
```

## Alternative: Convert to Comments

If the examples are intended to be purely aspirational documentation (showing what proof search "would" do), they could be converted to comments:

```lean
/-!
## Proof Search Examples (Documentation)

These examples illustrate how proof search would work once implemented.

**Example 1**: Trivial search finds axiom immediately
- Goal: `box p -> p`
- Solution: `Axiom.modal_t` provides this directly

**Example 2**: Search with depth 2 for modus ponens application
- Given: `h1 : p` and `h2 : p -> q`
- Goal: `q`
- Solution: Apply modus ponens

**Example 3**: Modal K search requires context transformation
- Context: `[box p]`
- Goal: `box p`
- Solution: Direct assumption from context
-/
```

## Recommendation

**Preferred approach**: Fix with direct witnesses (Option 1 above). The examples become valid Lean code that compiles and demonstrates the proof patterns that automated search would find. This is more valuable than comments because:

1. The code is type-checked and guaranteed correct
2. Demonstrates actual `DerivationTree` construction patterns
3. Serves as documentation AND verification

## Imports

The file already imports `Bimodal.ProofSystem` which provides:
- `DerivationTree` constructors
- `Axiom` constructors (including `modal_t`)

No additional imports needed.

## Potential Issues

1. The `Intro.mk` syntax for existential introduction depends on Lean version - may need `Exists.intro` instead
2. Verify the `by simp` tactic closes the membership proof in Example 3

## Verification Plan

After implementation:
1. Run `lake build Bimodal.Automation.ProofSearch`
2. Confirm no sorry or error on lines 1347-1360
3. Verify examples type-check correctly

---

**Status**: Research complete. Ready for implementation.
