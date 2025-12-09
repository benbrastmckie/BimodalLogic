# Research Report: Mathlib Theorems for Pairing Combinator Derivation

## Executive Summary

This report investigates available Mathlib theorems and resources for deriving the pairing combinator `A → B → A ∧ B` from the K and S propositional axioms in Lean 4. The key finding is that while Mathlib contains extensive category theory and type theory resources, the specific combinator calculus derivation required is not directly available and must be constructed from first principles.

## Research Context

### Problem Statement

The Logos project defines a `pairing` axiom:
```lean
axiom pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))
```

This axiom provides conjunction introduction: from proofs of A and B, construct a proof of A ∧ B. The task is to derive this as a theorem from the existing K and S propositional axioms.

### Existing Axiom System

From `Axioms.lean`, the relevant propositional axioms are:
- **prop_k (S axiom)**: `φ → (ψ → φ)` - weakening/constant combinator
- **prop_s (K axiom)**: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` - distribution

Note: The naming convention in Logos swaps the traditional combinator names. What Logos calls `prop_k` corresponds to the S combinator in traditional notation, and `prop_s` corresponds to the K combinator.

## Finding 1: Mathlib Has No Direct Combinator Calculus Library

### Search Results

LeanSearch and Loogle queries for "pairing combinator", "S combinator K combinator", and related terms returned no relevant results for propositional combinator calculus derivations.

The closest matches were:
- `CategoryTheory.ExactPairing`: Category-theoretic pairing (different domain)
- `Mathlib.Tactic.ITauto.Proof.curry`: Internal ITauto proof representation
- `ZFSet.pair`: Set-theoretic pairing function

### Implication

The derivation must be constructed from scratch using Logos's existing proof infrastructure (imp_trans, modus ponens, axiom applications).

## Finding 2: SKI Combinator Calculus Background

### Standard Combinators

From [SKI combinator calculus - Wikipedia](https://en.wikipedia.org/wiki/SKI_combinator_calculus):
- **I** (Identity): `I x = x` — derivable as `SKK`
- **K** (Constant): `K x y = x` — corresponds to Logos's `prop_s`
- **S** (Substitution): `S x y z = (x z)(y z)` — corresponds to Logos's `prop_k`

### Pairing Combinator (Vireo)

The pairing combinator V is defined as:
```
V = λx y z . z x y
```

This takes two values x and y, and returns a function that applies its argument z to both. In the Curry-Howard correspondence, this has type `A → B → (A → B → C) → C`.

The conjunction version `A → B → A ∧ B` requires the encoding:
```
A ∧ B = (A → B → ⊥) → ⊥
```

So we need: `A → B → ((A → B → ⊥) → ⊥)`

### SKI Expression for V

The standard derivation gives:
```
V = S(S(KS)(S(KK)I))(KI)
```

Where `I = SKK`.

## Finding 3: Bracket Abstraction Algorithm

### Algorithm Overview

From [Combinatory Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-combinatory/):

The bracket abstraction `[x]E` removes variable x from expression E:
1. `[x]x = I` (identity case)
2. `[x]c = Kc` where c doesn't contain x (constant case)
3. `[x](E₁E₂) = S([x]E₁)([x]E₂)` (application case)

### Application to Pairing

For `λa.λb.λf.(f a b)`:
1. Start with innermost: `[f](f a b)`
   - `= S([f](f a))([f]b)`
   - `= S(S([f]f)([f]a))([f]b)`
   - `= S(SI(Ka))(Kb)` where I is [f]f
2. Continue with `[b]...` then `[a]...`

This produces the complex SKI expression mentioned above.

## Finding 4: Existing Infrastructure in Perpetuity.lean

### Available Helper Lemmas

The project already has several relevant lemmas:
- `imp_trans`: `⊢ A → B` and `⊢ B → C` implies `⊢ A → C`
- `mp`: From `⊢ A` and `⊢ A → B`, derive `⊢ B`
- `identity`: `⊢ A → A` (SKK construction already done)
- `b_combinator`: `⊢ (B → C) → ((A → B) → (A → C))`

### Conjunction Definition

From `Formula.lean`:
```lean
def and (φ ψ : Formula) : Formula := (φ.imp ψ.neg).neg
```

Where `neg φ = φ.imp bot`. So:
```lean
A.and B = ((A → (B → ⊥)) → ⊥)
```

## Finding 5: Derivation Strategy

### Target Formula Expanded

We need to prove:
```lean
⊢ A → (B → ((A → (B → ⊥)) → ⊥))
```

### Key Insight

This is equivalent to proving that from assumptions A and B, we can derive `(A → B → ⊥) → ⊥`.

Given:
- We have A
- We have B
- We assume A → B → ⊥
- Apply assumption to A: get B → ⊥
- Apply result to B: get ⊥
- Therefore (A → B → ⊥) → ⊥

### Combinator Translation

The proof structure uses the C (flip) combinator pattern:
- `C x y z = x z y`
- `C = S(BBS)(KK)` where `B = S(KS)K`

But more directly, we can use:
- The S axiom to distribute
- The K axiom to introduce assumptions
- Multiple applications of modus ponens

## Finding 6: Estimated Complexity

### Line Count Estimate

Based on similar derivations in the project:
- `identity` (I combinator): 6 lines
- `b_combinator` (B combinator): 10 lines
- `contraposition` (uses B combinator): 20 lines

The pairing combinator involves deeper nesting and is estimated at 35-50 lines.

### Key Challenge

The challenge is managing the nested structure:
```lean
⊢ A → (B → ((A → (B → ⊥)) → ⊥))
```

This requires building up intermediate terms:
1. First build: `A → B → (A → B → ⊥) → ⊥`
2. Use S combinator to distribute applications
3. Carefully track formula positions

## Recommendations

### Recommendation 1: Step-by-Step Construction

Build helper lemmas incrementally:
1. `app2`: `⊢ (A → B → C) → (A → B) → A → C` (double application)
2. `flip`: `⊢ (A → B → C) → B → A → C` (argument flip)
3. Finally combine for pairing

### Recommendation 2: Consider Proof Complexity vs Value

As noted in the existing plan (Task 18, Phase 5):
> The derivation adds no mathematical insight and the ~40+ line proof would obscure rather than illuminate.

Keeping `pairing` as a semantically justified axiom is acceptable for MVP completion.

### Recommendation 3: Document Alternative Approaches

If deriving pairing:
1. Document the combinator-theoretic background
2. Provide step-by-step proof with comments
3. Add verification tests

## References

### External
- [SKI combinator calculus - Wikipedia](https://en.wikipedia.org/wiki/SKI_combinator_calculus)
- [Combinatory Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-combinatory/)
- [Curry-Howard correspondence](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence)

### Project Files
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` - Existing axiom definition
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean` - K and S axiom definitions
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/047_remove_derivable_axioms_perpetuity/plans/001-remove-derivable-axioms-perpetuity-plan.md` - Previous analysis
