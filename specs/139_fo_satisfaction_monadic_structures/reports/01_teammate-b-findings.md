# Teammate B Findings: Alternative Approaches for Task 139

**Researcher**: Teammate B (Alternative Patterns & Prior Art)
**Task**: 139 — FO satisfaction for monadic structures — close k-equivalence sorry chain
**Date**: 2026-05-14

---

## Key Findings

### 1. Downstream Dependency Analysis: What Must Actually Be Proved

Reading `Transfer.lean`, `Table.lean`, and `IntegerModel.lean` carefully reveals what the downstream pipeline actually requires:

- **`Transfer.lean`** (`doets_countermodel_discrete`): Currently falls back to the chronicle construction because "truth transfer" (Step 5) requires table correctness. The Reynolds pipeline is structurally wired but commented out. The specific gap: `table sig φ` and `table_depth_bound` must be correct, and there must be a proof that k-equivalence preserves truth of the table translation.
- **`Table.lean`**: Two sorries — `table` (the definition itself) and `table_depth_bound`. These are the entry point.
- **`IntegerModel.lean`**: All major theorems (`finite_structures_good`, `no_gaps_discrete`, `very_good_implies_good`, `chronicle_is_good`) already "work" in the sense that they type-check via the sorry chain through `k_type_of`. The k_equiv-based structure is mathematically correct but semantically hollow.
- **`NEquivalence.lean`**: The critical sorries are `k_type_of`, `ktype_finite`, `k_equiv_monotone`, and the `KEquivalenceFramework` instance fields (`equiv_at`, `equiv_is_equiv`, `equiv_monotone`, `finite_types`, `sum_preservation`).

**Critical insight**: `k_equiv_monotone` currently has a trivial "proof" (`simp only [k_equiv, k_type_of]; intro _ _; trivial`) because both sides reduce through `k_type_of`'s sorry to the same thing. The sorry chain means these proofs are currently vacuous. Closing the sorries in `k_type_of` will break these trivial proofs unless replaced with real semantic arguments.

### 2. Mathlib FirstOrder.Language Infrastructure Exists and Is Substantial

Mathlib's `ModelTheory/` directory contains:
- `Syntax.lean`: `FirstOrder.Language.BoundedFormula α n` — a locally nameless representation with **de Bruijn levels** (not indices). The type parameter `n` is the number of additional bound-variable slots, NOT quantifier depth. Sentences are `L.Formula Empty` = `L.BoundedFormula Empty 0`.
- `Semantics.lean`: Full Tarski satisfaction (`BoundedFormula.Realize`, `Sentence.Realize`, denoted `M ⊨ φ`), `Theory.Model`.
- `Encoding.lean`: `BoundedFormula.instCountableSigmaNat` — countability for `(n : ℕ) × L.BoundedFormula α n` when `α` is countable and `L.Symbols` is countable. **No `Fintype` instances exist** for bounded formulas — the type is countably infinite even over a finite signature.
- `Types.lean`: `Theory.CompleteType` — maximal consistent theories, the usual type space machinery.
- `Equivalence.lean`: Formula semantic equivalence (`⇔[T]`), not n-equivalence between structures.

**Critical gap**: Mathlib has **no quantifier-rank concept** and **no n-equivalence between structures**. It has Ehrenfeucht-Fraïssé in `Fraisse.lean` but for the specific purpose of proving Fraïssé's theorem on countable homogeneous structures — not for the quantifier-rank / n-equivalence theory needed here.

### 3. The Monadic Case Is Genuinely Simpler — and the Simplification Can Be Exploited

The `MonadicSentence` type defined in `NEquivalence.lean` uses **named/free variables with implicit single-variable quantifiers** (a prenex monadic form). The quantifier `.forall (α : MonadicSentence sig)` adds one bound variable, which is the only variable. This is correct for the monadic case where the standard translation of temporal formulas produces sentences with a single free variable pattern: `∃y (y > x ∧ P(y) ∧ ∀z(x < z < y → Q(z)))`.

**Key simplification**: In the monadic case, the Doets/Reynolds sentences have a fixed variable `x` (the current time point), and all quantifiers are bounded by the order. The `MonadicSentence` type with its single implicit variable captures this. Unlike the full FO case, we do NOT need:
- Multi-sorted terms
- Function symbols
- n-tuples of variables
- Substitution machinery for multiple variables

This means we can implement Tarski semantics for `MonadicSentence` directly with a simple recursive function on `M.carrier → Prop`, without importing Mathlib's general `FirstOrder.Language` machinery.

### 4. Concrete Implementation Path for Tarski Semantics

The simplest approach that avoids both De Bruijn complexity and the full Mathlib FirstOrder.Language overhead is:

```lean
-- Satisfaction with a single named variable (the "current point")
def MonadicSatisfies (sig : MonadicSignature) (M : MonadicStructure sig) 
    (v : M.carrier) : MonadicSentence sig → Prop
  | .atom p => M.interp p v
  | .not α => ¬ MonadicSatisfies sig M v α
  | .and α β => MonadicSatisfies sig M v α ∧ MonadicSatisfies sig M v β
  | .forall α => ∀ (w : M.carrier), MonadicSatisfies sig M w α
  | .lt => False  -- needs two variables: handled by a separate 2-variable version
```

The issue with `.lt` is that it requires TWO variables (x < y), but `MonadicSentence.lt` is a sentence, not a formula. In the Reynolds/Doets framework, the order relation is handled by having `lt` be interpreted relative to the quantifier context. This requires a 2-variable semantics for `lt` specifically.

The correct approach (following Reynolds Section 6 closely) is:

```lean
-- Satisfaction for sentences (no free variables)
def MonadicSatisfies (sig : MonadicSignature) [LinearOrder (M.carrier)]
    (M : MonadicStructure sig) : MonadicSentence sig → Prop
  | .atom p => False  -- atom is a formula, not a sentence by itself
  | .not α => ¬ MonadicSatisfies sig M α
  | .and α β => MonadicSatisfies sig M α ∧ MonadicSatisfies sig M β  
  | .forall α => ∀ (w : M.carrier), MonadicSatisfiesAt sig M w α
  | .lt => False  -- lt is a formula with 2 free vars, not a sentence
```

But `.lt` currently appears as a constructor of `MonadicSentence` at depth 0, suggesting it is treated as an atomic formula (with implicit free variables). The standard treatment in Reynolds is that `.lt` appears only **inside** `.forall` — i.e., `∀x. ∀y. x < y → ...` — which means the semantics needs a **two-place formula** representation for lt, or lt must be restricted to subformula contexts with two bound variables available.

**This is the key design choice that must be resolved.**

### 5. Variable Binding: Tradeoffs

| Approach | Pros | Cons | Mathlib Support |
|----------|------|------|-----------------|
| **Named single variable** (current `MonadicSentence.forall`) | Simple for monadic case, direct semantics | `.lt` needs 2 variables — design gap | None needed |
| **De Bruijn indices** (Mathlib's approach) | Full generality, substitution clean | More complex, 2-variable `.lt` handled naturally | `BoundedFormula` already exists |
| **Two-sorted scheme** (explicit current/witness variables) | Matches Reynolds table translation exactly | More types, boilerplate | None |
| **Relational extension** (add separate `lt_formula` with 2 free vars) | Minimal change to current code | `.lt` in `MonadicSentence` must become a meta-atom | None |

**Recommendation**: The cleanest fix consistent with the existing `MonadicSentence` type is to give `.lt` a two-variable semantics through a "two-point evaluation":

```lean
-- Two-point Tarski semantics for the monadic case
-- φ: the formula; v: the "main" variable; vs: the available bound variables as a stack
def MonadicSatisfiesAt (sig : MonadicSignature) [lo : LinearOrder M.carrier]
    (M : MonadicStructure sig) : MonadicSentence sig → M.carrier → Prop
  | .atom p, v => M.interp p v
  | .not α, v => ¬ MonadicSatisfiesAt sig M α v
  | .and α β, v => MonadicSatisfiesAt sig M α v ∧ MonadicSatisfiesAt sig M β v
  | .forall α, v => ∀ (w : M.carrier), MonadicSatisfiesAt sig M α w
  | .lt, _ => False  -- lt cannot be evaluated with a single variable; never use at top level

-- Then sentences (MonadicSentence with quantifier_depth 0) are evaluated via
def MonadicSatisfies ... := MonadicSatisfiesAt ...
```

The `lt` issue is actually not a blocker: in the Reynolds/Doets framework, the `lt` formula only appears **under two quantifiers** as `∀x. ∀y. (x < y → ...)`. The `MonadicSentence.lt` constructor represents the atomic formula `x < y` which is used inside `∀x. ∀y. ...` contexts. A two-variable semantics is needed only for `lt` specifically.

### 6. Alternative: k-Equivalence via Hintikka Formulas (No Tarski Semantics)

A classical alternative avoids building full Tarski semantics altogether by using **Hintikka sentences** (characteristic formulas / n-characteristics). The approach:

1. Define `Hintikka sig k M` as the **conjunction** of all depth-≤k sentences true in M (the n-characteristic σ of Doets).
2. Define `k_equiv M N` as: `Hintikka sig k M ↔ Hintikka sig k N` (they satisfy the same characteristic).
3. The finiteness of k-types follows from: there are finitely many Hintikka formulas at depth k (by Doets Lemma 1.1 induction).

This approach **characterizes k-equivalence purely syntactically** without defining a full satisfaction relation. It is essentially what the current code already attempts via `KType sig k = Finset (MonadicSentence sig)`, but it requires:
- Defining the **enumeration** of all sentences at depth ≤ k (requires `DecidableEq` on `MonadicSentence`)
- Showing this enumeration is finite (requires bounding sentence size by depth + signature)

**For `ktype_finite`**: The finiteness proof needs:
1. `DecidableEq (MonadicSentence sig)` (requires `DecidableEq sig.preds`, which is already present)
2. The set `{ s : MonadicSentence sig | s.quantifier_depth ≤ k }` is finite

Step 2 follows by structural induction: at depth 0, there are `|sig.preds| + 1` atomic sentences (one per predicate plus `.lt`). At depth k+1, there are finitely many from depth k plus `|{.forall s | s has depth ≤ k}|` which is again finite. This is a direct induction on k without requiring Tarski semantics.

### 7. The Obendrauf 2024 Pattern for Reusability

The Obendrauf paper's key insight is using **typeclasses** to generalize over syntaxes. They define `Pformula_ax (form : Type)` as a class carrying a provability predicate, allowing the same lemmas to apply to CL, CLC, etc. The `KEquivalenceFramework` typeclass in this codebase already follows this pattern. However, Obendrauf does NOT deal with first-order satisfaction or quantifier rank — their completeness proof is for a modal logic with a canonical model construction, not a monadic FO argument.

**Lesson from Obendrauf**: The typeclass approach for the framework is sound (they validate it works for non-trivial completeness proofs). The `KEquivalenceFramework` instance design is good. The gap is that the instance's fields are all sorried.

### 8. The `k_equiv_monotone` Sorry: Not as Trivial as It Looks

The current "proof" of `k_equiv_monotone` is:
```lean
simp only [k_equiv, k_type_of] at h_equiv ⊢; intro _ _; trivial
```
This works because `k_type_of` is sorry, so both sides are opaque sorry values. Once `k_type_of` is given a real definition, this proof becomes:

> If M and N satisfy the same sentences of depth ≤ k, then they satisfy the same sentences of depth ≤ m for any m ≤ k.

This is trivially true from the definition (any sentence of depth ≤ m ≤ k also has depth ≤ k), but requires:
- `k_type_of sig k M` is defined as `{ s | s.quantifier_depth ≤ k ∧ M ⊨ s }`
- Monotonicity: `s.quantifier_depth ≤ m → s.quantifier_depth ≤ k` (from transitivity of ≤ and `hkm : m ≤ k`)

After implementing Tarski semantics, `k_equiv_monotone` reduces to: `Finset.filter (fun s => s.quantifier_depth ≤ m) (k_type_of sig k M) = Finset.filter (fun s => s.quantifier_depth ≤ m) (k_type_of sig k N)`, which follows from the k-equivalence hypothesis by `Finset.filter_congr`.

---

## Alternative Approaches

### Option A: Minimal Tarski Semantics (Recommended)

Implement the simplest possible Tarski satisfaction relation directly on `MonadicSentence`:

1. Add `MonadicSatisfiesAt` as a function `MonadicSentence sig → M.carrier → Prop` for the "current variable" context. Handle `.lt` by threading a **second variable** through the `forall` case — specifically, track the most recently introduced variable alongside the current one, using a pair `(v, w : M.carrier)`.

2. Define `MonadicSatisfies` for sentences as `MonadicSatisfiesAt s` with a canonical starting point (no free variables).

3. Define `k_type_of sig k M = (Finset.univ.filter (fun s : MonadicSentence sig => s.quantifier_depth ≤ k ∧ M ⊨ s))` — but this requires `Fintype (MonadicSentence sig)`.

**Problem**: `MonadicSentence sig` is NOT finite — it has infinitely many sentences (arbitrary nesting depth). `KType sig k = Finset (MonadicSentence sig)` is therefore always an infinite type. The current definition of `KType` as `Finset (MonadicSentence sig)` is WRONG for k-types as specific finite objects.

**Correct definition**: `KType sig k` should be the type of logical equivalence classes of sentences of depth ≤ k. This is NOT naturally `Finset (MonadicSentence sig)`.

### Option B: Change KType to a Quotient (More Correct)

Define `KType sig k` as:
```lean
def KType (sig : MonadicSignature) (k : Nat) : Type :=
  Quotient (semanticEquivalenceSetoid sig k)
```
where `semanticEquivalenceSetoid` identifies sentences true in exactly the same structures.

Then `ktype_finite` becomes: the quotient of depth-≤-k sentences by semantic equivalence is finite. This is the correct mathematical statement (Doets Lemma 1.1).

This approach is **more mathematically correct** but requires building the full semantics machinery first.

### Option C: Change KType to Bool-Valued Assignments (Lightweight)

Define k-types not as sets of sentences but as **Boolean assignment functions** over a fixed finite basis:

```lean
-- The basis: finitely many sentences up to logical equivalence at depth k
-- Represented by a canonical form enumeration
def KTypeBasis (sig : MonadicSignature) (k : Nat) : Finset (MonadicSentence sig) := ...

-- A k-type is a truth-value assignment to the basis
def KType (sig : MonadicSignature) (k : Nat) : Type :=
  KTypeBasis sig k → Bool
```

This makes `KType` a `Fintype` immediately (Bool-valued functions over a `Finset`). The `k_type_of` function extracts the truth assignment via Tarski semantics. `ktype_finite` is immediate from `Fintype` of `KType`.

---

## Trade-off Analysis

| Concern | Minimal Tarski (A) | Quotient KType (B) | Bool KType (C) |
|---------|-------------------|-------------------|----------------|
| Correctness | Medium (KType issue) | High | Medium |
| Implementation effort | Low-medium | High | Medium |
| Integration with existing code | Needs KType refactor | Major refactor | Moderate refactor |
| Closes all sorries | Yes (with refactor) | Yes | Yes |
| Mathlib reuse | Minimal | Some (Quotient) | Some (Finset) |
| `k_equiv_monotone` proof | Straightforward | Requires quotient lift | Straightforward |
| `sum_preservation` | Semantic argument | Quotient argument | Semantic argument |
| Risk of new vacuities | Low | Low | Medium |

**Key tension**: The current definition `KType sig k := Finset (MonadicSentence sig)` creates a type universe mismatch — it says k-types ARE finite sets of sentences, but mathematically k-types are EQUIVALENCE CLASSES. Option A requires either (1) accepting that `KType` is a concrete (infinite) Finset and that `k_type_of` returns the actual set of true depth-≤-k sentences, or (2) refactoring `KType`.

**If we keep the current `KType` definition**: `k_type_of sig k M` should return `(all sentences s with s.quantifier_depth ≤ k that M satisfies)`. This IS a finite set IF sentences of depth ≤ k form a finite set. But `MonadicSentence sig` at depth ≤ k is NOT finite — there are infinitely many sentences of depth ≤ 0 (arbitrarily long conjunctions of atoms). The current `KType` definition is therefore semantically problematic for capturing the finiteness claim.

**Resolution**: The finiteness of k-types holds up to LOGICAL EQUIVALENCE, not up to syntactic identity. Any depth-≤-k sentence is logically equivalent to one of finitely many "canonical forms" (by Doets Lemma 1.1's disjunctive normal form argument). The current code elides this by making `KType` a `Finset` of syntactic sentences, which suggests the intent is to use NORMAL FORMS — but the normal forms are never defined.

---

## Evidence / Examples

### From Doets 1989, Lemma 1.1

The key result is:
> Up to logical equivalence, there are only finitely many first-order formulas of quantifier-rank ≤ n in the free variables x₀,...,x_{k-1} in each language.

Proof: By induction on n. For n=0, only atomic formulas matter; use disjunctive normal forms. For n+1, take a finite set Σ of formulas of rank ≤ n, then consider DNF over atoms `∀x_k φ` and `∃x_k φ` for φ ∈ Σ.

In the MONADIC case (one free variable, only unary predicates and `<`), the count at depth 0 is: atoms are `P₁(x), ..., P_m(x)` (m predicates), plus `x < y` (but this has two free variables). In the SENTENCE case (zero free variables), depth-0 sentences are empty (there are no closed atomic formulas over the order without function symbols — `P_i` needs a variable). This means depth-0 sentences are just `⊤` and `⊥`.

For depth 1: sentences of the form `∀x. φ(x)` where `φ(x)` ranges over depth-0 formulas with one free variable `x`, i.e., Boolean combinations of `P_i(x)`. There are `2^(2^m)` such sentences up to logical equivalence (one per truth function on m atoms). So k-types at depth 1 have `2^(2^m)` many canonical forms.

### From Reynolds 1994, Section 6

Reynolds introduces the monadic language: "Each atom p in the temporal language corresponds to a predicate symbol P. We can make a temporal structure (T, <, h) into a first-order structure in the monadic language, by interpreting < as < and each P as being true of exactly those points in h(p)."

The TABLE translation is: `C_{U(A,B)}(t) = ∃s > t(CA(s) ∧ ∀u(t < u < s → CB(u)))`. This requires ONE FREE VARIABLE `t` in the resulting sentence. The `MonadicSentence.forall` adds one bound variable — this matches Reynolds Section 6 exactly.

**The `.lt` design**: Reynolds writes `x < y` as a formula with two free variables. In the `MonadicSentence` encoding, `.lt` appears only inside `∀y. (lt ∧ ...)` where the outer universal introduces `y` and the implicit current point is `x`. The correct semantics: when evaluating `.lt` under a `forall`, the evaluation context must carry TWO variables — the current point (the outer forall's bound variable) and the inner point. This confirms that `.lt` semantics requires threading a "second variable" through the recursive evaluation.

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| `KType sig k := Finset (MonadicSentence sig)` is semantically wrong as a representation of k-types | **High** |
| Mathlib has no quantifier-rank or n-equivalence infrastructure | **High** |
| `k_equiv_monotone`'s current proof becomes vacuous once `k_type_of` is real | **High** |
| The `.lt` constructor requires two-variable evaluation context | **High** |
| Monadic case is simpler than full FO (no multi-variable terms needed) | **High** |
| Option A (minimal Tarski) is the lowest-effort path to closing all sorries | **Medium** (KType refactor required) |
| Option B (Quotient KType) gives the most correct formalization | **High** (but high effort) |
| Direct induction proof of `ktype_finite` without Tarski semantics is possible | **High** |

---

## Summary Recommendations

1. **Fix `KType` definition first.** The current `KType sig k := Finset (MonadicSentence sig)` is not the right type for k-types as equivalence classes. The easiest fix that requires minimal downstream changes: redefine `KType sig k` as a **function type** `MonadicSentence sig → Bool` (or `Prop`), representing a truth assignment, and change `k_type_of` to map each sentence to its truth value. Then `ktype_finite` becomes the claim that there are finitely many distinct truth assignments realized by structures — which follows from the DNF argument.

2. **Implement `MonadicSatisfiesAt` with a two-variable context for `.lt`.** The simplest signature: `MonadicSatisfiesAt sig M : MonadicSentence sig → M.carrier → Option M.carrier → Prop` where the `Option M.carrier` carries the "second variable" introduced by an enclosing forall, used only for `.lt`. Alternatively, add a `lt_x_y : MonadicSentence sig` constructor that explicitly takes two carrier values — but this requires changing the type.

3. **`ktype_finite` can be proved without full Tarski semantics** using a canonical-form enumeration argument. Define the finite set of Hintikka sentences at depth k by induction, then show every structure's k-type is one of these. This does require the satisfaction relation to state "M satisfies Hintikka sentence σ iff M is in k-equivalence class [σ]", so Tarski semantics is ultimately needed.

4. **`sum_preservation`** requires the Ehrenfeucht game argument (Doets Lemma 1.4). This is the hardest sorry to close by pure calculation. The game-theoretic proof is: if all component structures are k-equivalent, construct a winning strategy for player II in the k-game between the sums. This requires either (a) directly encoding the game strategy in Lean or (b) proving it by structural induction on k using Doets Lemma 1.1's finite equivalence classes. Approach (b) is more tractable: if the sum reduces to finitely many k-equivalence classes (by finiteness of k-types), and each class has a representative Z-interval structure, then the sum of Z-interval structures is itself a Z-interval structure.
