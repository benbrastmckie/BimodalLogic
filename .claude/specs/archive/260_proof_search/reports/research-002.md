# Research Report: Task #260 - Axiom Prop vs Type Blocking Issue

**Task**: Proof Search - Axiom refactor for proof term construction
**Date**: 2026-01-12
**Focus**: Research the blocking issue where `Axiom` is `Prop` but Phase 1 needs `Option (Axiom phi)` which requires `Axiom phi : Type`

## Summary

The current `Axiom` type is defined as `inductive Axiom : Formula -> Prop`, which makes it impossible to return `Option (Axiom phi)` from a proof search function because Lean's singleton elimination rules prevent eliminating from a multi-constructor `Prop` inductive to `Type`. This research evaluates four potential solutions: (1) Refactoring `Axiom` from `Prop` to `Type`, (2) Using `Classical.choice` or decidability, (3) Alternative proof term construction approaches, and (4) Patterns from Mathlib and other Lean projects.

**Recommended Approach**: Create a parallel `AxiomWitness : Formula -> Type` inductive that mirrors `Axiom` constructors. This follows the Mathlib `ITauto.Proof` pattern and provides maximum flexibility for proof search while preserving the original `Prop` semantics.

## Findings

### 1. The Core Problem

The blocking issue stems from Lean 4's elimination rules for inductive types in `Prop`:

```lean
-- Current definition (Axioms.lean line 66)
inductive Axiom : Formula -> Prop where
  | prop_k (phi psi chi : Formula) : Axiom ((phi.imp (psi.imp chi)).imp ...)
  | prop_s (phi psi : Formula) : Axiom (phi.imp (psi.imp phi))
  -- ... 14 total constructors
```

According to [Lean 4's Inductive Type documentation](https://lean-lang.org/doc/reference/latest/The-Type-System/Inductive-Types/):

> "What characterizes inductive types in Prop is that one can only eliminate to other types in Prop. This is consistent with the understanding that if `p : Prop`, an element `hp : p` carries no data."

There is a **singleton elimination exception**: "We are allowed to eliminate from an inductively defined Prop to an arbitrary Sort when there is only one constructor and each constructor argument is either in Prop or an index." Since `Axiom` has 14 constructors, this exception does not apply.

**Consequence**: We cannot write a function `matchAxiom : Formula -> Option (Axiom phi)` because `Option` lives in `Type`, but elimination from `Axiom` can only produce `Prop`.

### 2. Approach Analysis

#### Approach 1: Refactor Axiom from Prop to Type

**Changes Required**:
```lean
-- NEW: Type-valued axiom witness
inductive Axiom : Formula -> Type where
  | prop_k (phi psi chi : Formula) : Axiom ((phi.imp (psi.imp chi)).imp ...)
  -- ... same constructors
```

**Implications**:
- **Breaking Change**: All existing code using `Axiom` would need updates
- **Proof Irrelevance Lost**: Proofs of `Axiom phi` are no longer computationally irrelevant
- **DerivationTree Impact**: Line 75 in Derivation.lean: `| axiom (Gamma : Context) (phi : Formula) (h : Axiom phi)` would store data
- **Soundness**: No impact on soundness - the axiom matching logic is unchanged

**Files Requiring Changes**:
1. `Theories/Bimodal/ProofSystem/Axioms.lean` - Core definition
2. `Theories/Bimodal/ProofSystem/Derivation.lean` - Uses `Axiom` in constructor
3. `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` - Tests axiom matching
4. Any file importing `Bimodal.ProofSystem.Axioms`

**Estimated Scope**: ~10-20 files, 2-4 hours of refactoring

**Risk Assessment**: LOW - The change is mechanical (search-and-replace patterns), and since `Axiom` is primarily used as a witness type, the semantic difference is minimal.

#### Approach 2: Classical.choice or Decidability

**Using Classical.choice**:
```lean
-- Requires proving Axiom is decidable
noncomputable def matchAxiom (phi : Formula) : Option (Axiom phi) :=
  if h : Nonempty (Axiom phi) then
    some (Classical.choice h)
  else
    none
```

**Problems**:
1. **Decidability Burden**: We'd need `instance : Decidable (Axiom phi)` for all formulas
2. **Nonempty vs Instance**: `Classical.choice` extracts from `Nonempty`, but we need to prove nonemptiness first
3. **Noncomputable**: The function would be `noncomputable`, defeating the purpose of automated search

**Using Decidable**:
```lean
-- With a Decidable instance
def matchAxiom (phi : Formula) [h : Decidable (Axiom phi)] : Option (Axiom phi) :=
  match h with
  | .isTrue pf => some pf
  | .isFalse _ => none
```

**Problem**: `Decidable.isTrue` still requires extracting the proof term, which is blocked by the same Prop elimination rules.

**Verdict**: Classical.choice and Decidable approaches are **not viable** for computational proof search.

#### Approach 3: Alternative Proof Term Construction

**Option A: Reflection Pattern**

Instead of returning `Option (Axiom phi)`, return metadata identifying which axiom matched:

```lean
inductive AxiomTag
  | prop_k | prop_s | ex_falso | peirce | modal_t | modal_4 | modal_b
  | modal_5_collapse | modal_k_dist | temp_k_dist | temp_4 | temp_a | temp_l
  | modal_future | temp_future

def matchAxiomTag (phi : Formula) : Option AxiomTag := ...

-- Reconstruct proof from tag
def axiomFromTag (tag : AxiomTag) (phi : Formula) : Option (Axiom phi) := sorry -- Still blocked!
```

**Problem**: We still can't reconstruct `Axiom phi` from the tag due to elimination restrictions.

**Option B: Direct DerivationTree Construction**

Skip `Option (Axiom phi)` entirely; construct `DerivationTree` directly:

```lean
def matchAxiomDerivation (Gamma : Context) (phi : Formula) : Option (DerivationTree Gamma phi) :=
  if matches_axiom phi then
    -- BLOCKED: Can't construct DerivationTree.axiom without Axiom proof term
    none
  else
    none
```

**Problem**: `DerivationTree.axiom` requires `(h : Axiom phi)`, so we're back to the same issue.

#### Approach 4: Mathlib ITauto Pattern - Parallel Type Witness

Mathlib's `ITauto` tactic solves this exact problem using a **parallel proof term inductive type** in `Type`:

```lean
-- From Mathlib.Tactic.ITauto
inductive Proof : Type where
  | sorry : Proof
  | hyp (n : Name) : Proof
  | triv : Proof
  | exfalso' (p : Proof) : Proof
  | intro (x : Name) (p : Proof) : Proof
  | andLeft (ak : AndKind) (p : Proof) : Proof
  -- ... more constructors
```

**Key insight from [Mathlib ITauto documentation](https://math.iisc.ac.in/~gadgil/PfsProgs25doc/Mathlib/Tactic/ITauto.html)**:

> "A reified inductive proof type for intuitionistic propositional logic"

The proof search builds `ITauto.Proof` (which lives in `Type`), then converts to actual Lean proofs using elaboration.

**Applied to ProofChecker**:

```lean
-- Parallel Type-valued witness
inductive AxiomWitness : Formula -> Type where
  | prop_k (phi psi chi : Formula) : AxiomWitness ((phi.imp (psi.imp chi)).imp ...)
  | prop_s (phi psi : Formula) : AxiomWitness (phi.imp (psi.imp phi))
  -- ... mirror all 14 constructors from Axiom

-- Conversion: AxiomWitness -> Axiom (for soundness proofs)
def AxiomWitness.toAxiom : AxiomWitness phi -> Axiom phi
  | .prop_k phi psi chi => Axiom.prop_k phi psi chi
  | .prop_s phi psi => Axiom.prop_s phi psi
  -- ...

-- Now we can pattern match!
def matchAxiomWitness (phi : Formula) : Option (AxiomWitness phi) := ...
```

**Benefits**:
1. **Preserves Prop semantics**: Original `Axiom` unchanged for metalogic proofs
2. **Enables computation**: `AxiomWitness` can be pattern-matched and returned
3. **Soundness bridge**: `toAxiom` proves witness corresponds to valid axiom
4. **Mathlib precedent**: Well-established pattern in Lean ecosystem

### 3. Wu and Gore's Verified Decision Procedure Pattern

From [Wu and Gore's ITP 2019 paper](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2019.31) on verified modal logic decision procedures:

> "Each decision procedure is implemented as a computable function in Lean, and is proved to be sound, complete and terminating."

Their approach uses **sum types** for dual return modes:

```lean
-- Pseudocode based on their slides
inductive TableauResult where
  | valid : ProofTerm -> TableauResult
  | sat : CounterModel -> TableauResult
```

**Key technique**: Separate the **computation** (Bool/computable) from **justification** (proof term). The proof search runs in computation mode for efficiency, and proof terms are constructed only when needed.

### 4. Mathlib Decidable Instances Pattern

For `Decidable (Axiom phi)`, Mathlib typically uses [Classical.dec](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Logic/Basic.html):

```lean
-- From Mathlib.Logic.Basic
instance Classical.dec (p : Prop) : Decidable p := by infer_instance
```

However, this still doesn't help with witness extraction - it only tells us *whether* an axiom exists, not *which one*.

### 5. Singleton Elimination Cases in Current Code

Reviewing `DerivationTree`:

```lean
inductive DerivationTree : Context -> Formula -> Type where
  | axiom (Gamma : Context) (phi : Formula) (h : Axiom phi) : DerivationTree Gamma phi
  | assumption (Gamma : Context) (phi : Formula) (h : phi in Gamma) : DerivationTree Gamma phi
  -- ...
```

`DerivationTree` is already in `Type`, so it can store data. The issue is that `h : Axiom phi` is a `Prop`, which means:
- We can *have* an `h` (proof exists)
- We cannot *inspect* which constructor produced `h` (computationally irrelevant)

This explains why the current `bounded_search` returns `Bool` - there's no way to construct the `DerivationTree` without the ability to pattern-match on `Axiom`.

## Recommendations

### Primary Recommendation: Parallel AxiomWitness Type

Create a parallel `AxiomWitness : Formula -> Type` that mirrors `Axiom`, following the Mathlib ITauto pattern.

**Implementation Plan**:

1. **Create AxiomWitness** (new file or in Axioms.lean):
```lean
inductive AxiomWitness : Formula -> Type where
  | prop_k (phi psi chi : Formula) :
      AxiomWitness ((phi.imp (psi.imp chi)).imp ((phi.imp psi).imp (phi.imp chi)))
  | prop_s (phi psi : Formula) : AxiomWitness (phi.imp (psi.imp phi))
  | ex_falso (phi : Formula) : AxiomWitness (Formula.bot.imp phi)
  | peirce (phi psi : Formula) : AxiomWitness (((phi.imp psi).imp phi).imp phi)
  | modal_t (phi : Formula) : AxiomWitness (Formula.box phi |>.imp phi)
  | modal_4 (phi : Formula) : AxiomWitness ((Formula.box phi).imp (Formula.box (Formula.box phi)))
  | modal_b (phi : Formula) : AxiomWitness (phi.imp (Formula.box phi.diamond))
  | modal_5_collapse (phi : Formula) : AxiomWitness (phi.box.diamond.imp phi.box)
  | modal_k_dist (phi psi : Formula) : AxiomWitness ((phi.imp psi).box.imp (phi.box.imp psi.box))
  | temp_k_dist (phi psi : Formula) :
      AxiomWitness ((phi.imp psi).all_future.imp (phi.all_future.imp psi.all_future))
  | temp_4 (phi : Formula) :
      AxiomWitness ((Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)))
  | temp_a (phi : Formula) : AxiomWitness (phi.imp (Formula.all_future phi.sometime_past))
  | temp_l (phi : Formula) : AxiomWitness (phi.always.imp (Formula.all_future (Formula.all_past phi)))
  | modal_future (phi : Formula) :
      AxiomWitness ((Formula.box phi).imp (Formula.box (Formula.all_future phi)))
  | temp_future (phi : Formula) :
      AxiomWitness ((Formula.box phi).imp (Formula.all_future (Formula.box phi)))
  deriving Repr, DecidableEq
```

2. **Create conversion function**:
```lean
def AxiomWitness.toAxiom : {phi : Formula} -> AxiomWitness phi -> Axiom phi
  | _, .prop_k phi psi chi => Axiom.prop_k phi psi chi
  | _, .prop_s phi psi => Axiom.prop_s phi psi
  -- ... all 14 cases
```

3. **Create matching function** (replace `matches_axiom : Formula -> Bool`):
```lean
def matchAxiomWitness (phi : Formula) : Option (Sigma AxiomWitness) := ...
-- Or more precisely:
def matchAxiomWitness' (phi : Formula) : Option (AxiomWitness phi) := ...
```

4. **Update ProofSearch to construct DerivationTree**:
```lean
def bounded_search_with_proof (Gamma : Context) (phi : Formula) (depth : Nat)
    : Option (DerivationTree Gamma phi) :=
  -- When axiom matches:
  match matchAxiomWitness' phi with
  | some witness => some (DerivationTree.axiom Gamma phi witness.toAxiom)
  | none => ...
```

### Alternative: Direct Axiom to Type Refactor

If the parallel type adds too much complexity, refactoring `Axiom` directly to `Type` is viable:

```lean
-- Simple change
inductive Axiom : Formula -> Type where  -- Changed from Prop
  -- ... same constructors
```

**Trade-offs**:
- **Pro**: Simpler, single source of truth
- **Pro**: Less code duplication
- **Con**: Loses proof irrelevance (minor impact for this use case)
- **Con**: Breaking change requires updating all usages

**Estimated scope**: 2-4 hours of refactoring across ~10-20 files.

### Not Recommended

1. **Classical.choice approach**: Noncomputable, defeats purpose
2. **Pure reflection with tags**: Still blocked on reconstruction
3. **Keeping current Bool-only search**: Blocks Phase 1 of implementation plan

## Long-Term Bimodal Development Considerations

For the long-term Bimodal theory development:

1. **Parallel Witness Pattern** is more maintainable because:
   - `Axiom : Prop` remains available for metalogic proofs (completeness, soundness)
   - `AxiomWitness : Type` serves computational needs (proof search, automation)
   - Clear separation of concerns

2. **DerivationTree stays Type**: This is correct and should not change

3. **SearchResult evolution**:
```lean
-- Current
abbrev SearchResult (_ : Context) (_ : Formula) := Bool

-- With parallel witness
structure SearchResult (Gamma : Context) (phi : Formula) where
  found : Bool
  proof : Option (DerivationTree Gamma phi)
```

4. **Tactic integration** (Phase 2) will benefit from having actual proof terms, not just Bool

## References

### Lean 4 Documentation
- [Inductive Types - Type Checking](https://ammkrn.github.io/type_checking_in_lean4/declarations/inductive.html) - Singleton elimination rules
- [Theorem Proving in Lean 4 - Inductive Types](https://lean-lang.org/theorem_proving_in_lean4/inductive_types.html) - Prop vs Type
- [Reference Manual - Inductive Types](https://lean-lang.org/doc/reference/latest/The-Type-System/Inductive-Types/) - Elimination restrictions

### Mathlib
- [ITauto Tactic](https://math.iisc.ac.in/~gadgil/PfsProgs25doc/Mathlib/Tactic/ITauto.html) - Parallel proof term pattern
- [Nonempty.some](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Logic/Nonempty.html) - Classical witness extraction
- [Classical.choose](https://leanprover-community.github.io/mathlib4_docs/Init/Classical.html) - Existential witness extraction

### Academic
- [Wu & Gore, "Verified Decision Procedures for Modal Logics", ITP 2019](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2019.31) - Verified modal tableaux in Lean

### Project Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` - Current Axiom definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Derivation.lean` - DerivationTree using Axiom
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Automation/ProofSearch.lean` - Current Bool-based search

## Next Steps

1. **Decide on approach**: Parallel AxiomWitness (recommended) vs direct refactor
2. **Implement AxiomWitness** in Axioms.lean or new file
3. **Update ProofSearch** to return `Option (DerivationTree Gamma phi)`
4. **Revise implementation plan** for Phase 1 based on chosen approach
5. **Update blocking status** in TODO.md once approach is approved
