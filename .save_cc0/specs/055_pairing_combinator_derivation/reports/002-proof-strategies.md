# Research Report: Proof Strategies for Pairing Combinator Derivation

## Executive Summary

This report analyzes proof strategies for deriving the pairing combinator `A → B → A ∧ B` from K and S axioms in the TM proof system. The derivation requires constructing a proof term that witnesses conjunction introduction using only implication-based axioms and modus ponens.

## Research Context

### The Pairing Problem

We need to derive:
```lean
theorem pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))
```

Expanding the conjunction definition `A.and B = (A.imp (B.imp bot)).imp bot`:
```lean
⊢ A.imp (B.imp ((A.imp (B.imp bot)).imp bot))
```

### Available Tools

From Logos's proof system:
1. **Axioms**:
   - `prop_s (K)`: `⊢ φ.imp (ψ.imp φ)` - weakening
   - `prop_k (S)`: `⊢ (φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))` - distribution

2. **Existing Lemmas** (from Perpetuity.lean):
   - `imp_trans`: transitivity of implication
   - `mp`: modus ponens as theorem
   - `identity`: `⊢ A.imp A`
   - `b_combinator`: `⊢ (B.imp C).imp ((A.imp B).imp (A.imp C))`

## Finding 1: The S-Combinator Distribution Strategy

### Core Insight

The S axiom `(A → (B → C)) → ((A → B) → (A → C))` allows us to "split" an application through an implication.

### Application Pattern

If we have:
- `⊢ A → (B → C → D)` (a 3-ary function)
- We want: `⊢ A → C → D` given some relationship with B

The S axiom helps redistribute arguments.

### Strategy for Pairing

The pairing function `λa.λb.λf.(f a b)` has the evaluation:
1. Take a, store it
2. Take b, store it
3. Take f, apply f to a, then apply result to b

In combinator terms, this requires:
- S to distribute f to both a and b
- K to capture constants at the right moments

## Finding 2: Detailed Derivation Approach

### Step 1: Understand the Goal Structure

Goal: `⊢ A → B → ((A → B → ⊥) → ⊥)`

Let's name the subformulas:
- Let `F = A → B → ⊥` (the "falsifier" function)
- Goal becomes: `⊢ A → B → (F → ⊥)`

### Step 2: Build Inner Application Lemma

We need a lemma showing that given A and B, we can apply any F : A → B → ⊥ to get ⊥.

**Key observation**: `F A : B → ⊥` and then `(F A) B : ⊥`

This is the double application pattern:
```lean
-- Given: A, B, F : A → B → C
-- Result: C
lemma double_apply {A B C : Formula} : ⊢ A.imp (B.imp ((A.imp (B.imp C)).imp C))
```

### Step 3: Derive Double Apply Lemma

**Approach using S combinator**:

```lean
-- S : (X → Y → Z) → (X → Y) → X → Z
-- Instantiate with X = F, Y = B, Z = ⊥
-- S : (F → B → ⊥) → (F → B) → F → ⊥
-- But we need F = A → B → ⊥
```

Actually, let's approach differently:

**Direct construction**:
We need: `⊢ A → B → (A → B → ⊥) → ⊥`

1. By S axiom on `(A → B → ⊥)`:
   `⊢ (A → (B → ⊥) → ⊥) → ((A → B → ⊥) → (A → ⊥))`

2. We need `⊢ A → (B → ⊥) → ⊥` which is similar structure...

### Step 4: Recursive Pattern Recognition

The derivation has a recursive pattern. Let's define:
```lean
-- app1: Apply one argument to a function
lemma app1_pattern {A B : Formula} : ⊢ A.imp ((A.imp B).imp B)
```

This can be proven using:
1. S axiom: `(A → (A → B) → B) → ((A → A → B) → (A → B))`
2. Identity: `⊢ A → A`
3. Some manipulation...

Actually simpler: Consider the B combinator we already have.

## Finding 3: Using the B Combinator

### B Combinator Lemma

Already proven in Perpetuity.lean:
```lean
theorem b_combinator {A B C : Formula} :
  ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C))
```

This is composition: given `B → C` and `A → B`, get `A → C`.

### Application Strategy

For pairing, we can use B combinator to chain applications:

1. Build `⊢ (A → B → ⊥) → A → B → ⊥` (identity)
2. Build `⊢ (B → ⊥) → B → ⊥` (identity)
3. Compose appropriately

But this doesn't directly give us pairing. We need a different approach.

## Finding 4: The Flip Combinator Approach

### C Combinator (Flip)

The C combinator swaps arguments:
```
C : (A → B → C) → B → A → C
C f x y = f y x
```

### Relevance to Pairing

Notice that:
- Pairing: `A → B → (A → B → ⊥) → ⊥`
- Can be rewritten: `A → B → C × C' → D` where we apply in specific order

The flip pattern helps because we're essentially:
1. Taking A (first)
2. Taking B (second)
3. Taking F and applying F to (A, B) in that order

### C Combinator Derivation

From SK:
```
C = S(BBS)(KK)
```
Where `B = S(KS)K`

In our notation:
```lean
-- B combinator: already have
-- C combinator: derive as next step
lemma c_combinator {A B C : Formula} :
  ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))
```

## Finding 5: Complete Derivation Path

### Recommended Lemma Sequence

1. **`lemma flip`** (C combinator):
   ```lean
   ⊢ (A → B → C) → (B → A → C)
   ```
   Derivation: Use S and K to swap argument order.

2. **`lemma app1`** (single application):
   ```lean
   ⊢ A → (A → B) → B
   ```
   This is flip applied to identity: `C I` where `I : (A → B) → A → B`

3. **`lemma app2`** (double application):
   ```lean
   ⊢ A → B → (A → B → C) → C
   ```
   Derivation: Combine app1 with composition.

4. **`theorem pairing`**:
   ```lean
   ⊢ A → B → A ∧ B
   ```
   Where `A ∧ B = (A → B → ⊥) → ⊥`.
   This is exactly `app2` with `C = ⊥`!

### Key Insight

**Pairing is app2 specialized to ⊥!**

The conjunction `A ∧ B` defined as `(A → B → ⊥) → ⊥` means that pairing is exactly the double application lemma with the result type being ⊥.

## Finding 6: Concrete Proof Outline

### Deriving Flip (C Combinator)

```lean
-- Goal: ⊢ (A → B → C) → (B → A → C)

-- Step 1: Use K axiom to weaken
-- K : φ → ψ → φ
-- Instantiate: ⊢ (A → B → C) → (B → (A → B → C))
have step1 : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp (B.imp C))) :=
  Derivable.axiom [] _ (Axiom.prop_s (A.imp (B.imp C)) B)

-- Step 2: Use S axiom to distribute
-- S : (X → Y → Z) → (X → Y) → X → Z
-- With X = B, Y = A → B → C, Z = A → C? No...

-- Alternative: Direct S application
-- We need: B → (A → B → C) → (A → C)
-- This is: flip of (A → (B → C) → C) but with extra layer

-- Actually use nested S:
-- S gives: (B → (A → B → C) → (A → C)) → (B → (A → B → C)) → (B → A → C)
```

The derivation is intricate but follows mechanical bracket abstraction rules.

### Estimated Line Count

- Flip lemma: 15-20 lines
- App1 lemma: 10-15 lines
- App2 lemma: 10-15 lines
- Pairing theorem: 5 lines (using app2)

Total: 40-55 lines

## Recommendations

### Recommendation 1: Incremental Development

Build lemmas in order:
1. First prove flip (C combinator)
2. Then app1 using flip
3. Then app2 combining app1
4. Finally pairing as special case of app2

### Recommendation 2: Test Each Step

After each lemma, add example usages:
```lean
example (p q : Formula) : ⊢ p.imp (q.imp (p.and q)) := pairing p q
```

### Recommendation 3: Document Combinator Correspondence

Add comments showing:
- Which SKI combinator each lemma corresponds to
- The bracket abstraction derivation
- The type-theoretic interpretation

### Recommendation 4: Consider Alternatives

If the derivation becomes too complex:
1. Keep `pairing` as axiom with extensive documentation
2. Note that semantic justification is sound
3. Mark as optional future work with clear specification

## References

### Combinator Calculus
- [SKI combinator calculus - Wikipedia](https://en.wikipedia.org/wiki/SKI_combinator_calculus)
- [Combinatory Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-combinatory/)

### Curry-Howard Correspondence
- [Curry-Howard correspondence - Wikipedia](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence)
- [Lectures on the Curry-Howard Isomorphism](https://disi.unitn.it/~bernardi/RSISE11/Papers/curry-howard.pdf)

### Project Context
- Perpetuity.lean existing proofs for patterns
- Task 18 plan for historical context
