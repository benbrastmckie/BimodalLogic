# Research Report: sum_preservation via Normal Form Induction (Doets Lemma 1.4)

**Task**: 154
**Date**: 2026-05-15
**Session**: sess_1747338900_d4e5f6

## Executive Summary

The `sum_preservation` sorry in `NEquivalence.lean:190` is the single root cause
blocking the Reynolds pipeline for discrete completeness. It asserts that
k-equivalence of ordered monadic structures is preserved under ordered sums
(Doets 1989 Lemma 1.4). This report analyzes three proof approaches, recommends
the **normal form induction approach** (avoiding EF game formalization), and
provides a detailed implementation plan.

The carrier_order sorry (lexicographic order on Sigma types) is straightforward
to close using Mathlib's `Sigma.Lex.linearOrder` instance. The main proof
requires approximately 200-350 lines of new Lean code.

## 1. Sorry Inventory

### 1.1 Primary Sorry: sum_preservation

**Location**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`, line 190

**Type signature** (from KEquivalenceFramework instance):
```lean
sum_preservation k I _ ms ms' h := by
  sorry
```

Where the field declaration is:
```lean
sum_preservation (k : Nat) (I : Type) [inst_lo : LinearOrder I]
    (ms ms' : I -> OrderedMonadicStructure sig)
    (h : forall i, equiv_at k (ms i) (ms' i)) :
    equiv_at k
      { carrier := Sigma fun i => (ms i).carrier
        interp := fun p x => (ms x.1).interp p x.2
        carrier_order := sorry }
      { carrier := Sigma fun i => (ms' i).carrier
        interp := fun p x => (ms' x.1).interp p x.2
        carrier_order := sorry }
```

**Semantic meaning**: `equiv_at` is instantiated as `k_equiv sig k`, which means
`k_type_of sig k S = k_type_of sig k S'`, which unfolds to: for every
`NormalForm sig k 0`, the normal form evaluates to the same truth value on
both ordered sums.

### 1.2 Carrier Order Sorry

**Location**: Same as above, lines 141 and 144 (also OrderedSum.lean lines 41, 44, 66, 69)

**What's needed**: A `LinearOrder` on `Sigma fun i => (ms i).carrier` where
`I` has `LinearOrder` and each `(ms i).carrier` has `LinearOrder`.

**Resolution**: Use the lexicographic order. Mathlib provides:
```lean
-- In Mathlib.Data.Sigma.Lex
instance : LinearOrder (Lex (Sigma alpha)) := ...
```
Since `Lex` is a type alias (`def Lex := alpha`), this can be cast directly:
```lean
noncomputable def orderedSumOrder (I : Type) [LinearOrder I]
    (alpha : I -> Type) [forall i, LinearOrder (alpha i)] :
    LinearOrder (Sigma alpha) :=
  inferInstanceAs (LinearOrder (Lex (Sigma alpha)))
```

This is verified to compile. The carrier_order sorry is trivially closable.

### 1.3 Standalone doets_lemma_1_4

**Location**: `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean`, line 45

**Type signature**: Identical to sum_preservation but using `k_equiv` directly
instead of `equiv_at`. Once sum_preservation is proved in the instance, this
theorem follows by applying the instance.

### 1.4 Downstream Sorries (Dependent on sum_preservation)

| Sorry | File:Line | Dependency Chain |
|-------|-----------|------------------|
| `finite_structures_good` | IntegerModel.lean:90 | Doets Theorem 1.1 (k-type realizability by Z-interval) |
| `contemp_equiv_is_equiv` (transitivity) | IntegerModel.lean:128 | Uses `very_good` which depends on `sum_preservation` |
| `no_gaps_discrete` | IntegerModel.lean:145 | Properties of good structures |
| `very_good_implies_good` | IntegerModel.lean:202 | Reynolds Lemma 16, uses sum_preservation |
| `chronicle_is_good` | IntegerModel.lean:214 | Depends on very_good_implies_good |
| `doets_lemma_1_5` | OrderedSum.lean:70 | Not on discrete critical path |

**Note**: `finite_structures_good` does NOT directly depend on `sum_preservation`.
It depends on Doets Theorem 1.1 (every k-type is realized by some Z-interval),
which is a separate result. However, `very_good_implies_good` uses
sum_preservation to decompose a structure into its condensation components and
reassemble via an ordered sum that is k-equivalent to a Z-structure.

## 2. Existing Infrastructure Analysis

### 2.1 NormalForm Infrastructure (NormalForm.lean)

The codebase has a complete normal form theory:

- `NormalForm sig k n`: Recursive type at depth k with n free variables
  - Depth 0: `AtomKind sig n -> Bool` (truth assignment to atoms)
  - Depth k+1: `(AtomKind sig n -> Bool) x (NormalForm sig k (n+1) -> Bool)`
- `AtomKind sig n`: Atomic propositions
  - `pred p i`: Predicate p applied to variable i (p * n atoms)
  - `order i j h`: Order relation x_i < x_j where i != j (n*(n-1) atoms)
- `nf_eval_nf M k n env nf`: Concrete evaluation
- `nf_characteristic M k n env`: The unique NF satisfied by (M, env)
- `nf_exists_unique`: Each (M, env) satisfies exactly one NF
- `nf_eval_unique`: If two NFs are both satisfied, they are equal
- `nf_agreement_monotone`: NF agreement is monotone in depth
- `doets_lemma_1_1`: Bridge theorem (NF agreement implies formula agreement)

### 2.2 k-Equivalence (NEquivalence.lean)

- `KType sig k = NormalForm sig k 0 -> Bool`
- `k_type_of sig k M`: Maps each sentence-level NF to its truth value in M
- `k_equiv sig k M N`: `k_type_of sig k M = k_type_of sig k N`
- `k_equiv_monotone`: Proved via `nf_agreement_monotone`
- `KEquivalenceFramework`: Typeclass with `equiv_at`, `equiv_is_equiv`,
  `equiv_monotone`, `finite_types` (all closed), `sum_preservation` (sorry)

### 2.3 Monadic FO (MonadicFO.lean)

- `MonadicFormula sig n`: De Bruijn indexed formulas
- `eval M env phi`: Tarski satisfaction
- `OrderedMonadicStructure sig`: carrier + interp + carrier_order
- `MonadicFormula.quantifier_depth`: Quantifier depth

## 3. Proof Approach Comparison

### 3.1 Approach A: EF Game Formalization

**Description**: Define Ehrenfeucht-Fraisse games in Lean, prove the fundamental
theorem (EF equivalence <-> k-equivalence), then prove the composition lemma
for ordered sums.

**Required new infrastructure**:
1. `EFGame sig k M N`: Game definition (positions, moves, strategies)
2. `EFPosition sig M N`: Partial isomorphisms (finite lists of pairs)
3. `WinningStrategy`: Duplicator's response function
4. Fundamental Theorem: `k_equiv <-> WinningStrategy`
   - Forward: from k_type equality, construct strategy
   - Backward: from strategy, show all NFs agree
5. Composition Lemma: from component strategies, build sum strategy

**Estimated effort**: 400-600 lines for the EF game infrastructure, plus 100-200
for the composition lemma. Total: 500-800 lines.

**Risks**:
- Large new infrastructure with no other current use case
- EF game strategies involve complex inductive arguments about partial isomorphisms
- The "fundamental theorem" connecting EF games to k-types is itself non-trivial
- Potential diamond instance issues with partial isomorphism types

**Verdict**: HIGH EFFORT, HIGH RISK. Avoidable since the codebase already has
the normal form machinery that EF games would ultimately connect to.

### 3.2 Approach B: Normal Form Induction (RECOMMENDED)

**Description**: Prove `sum_preservation` directly by showing that the
characteristic normal form of the ordered sum is determined by the characteristic
normal forms of the components. This uses the existing NormalForm infrastructure
without introducing EF games.

**Key insight**: We need to show that for every `NormalForm sig k 0` (sentence),
its truth value on the ordered sum depends only on the k-types of the components.
This can be proved by strong induction on k, using a generalized statement about
normal forms with free variables.

**Core lemma needed** (the "Localization Lemma"):
```lean
-- For elements all from the same component i, the NF evaluation
-- on the sum agrees with the NF evaluation on the component.
theorem nf_eval_sum_localize {sig : MonadicSignature}
    {I : Type} [LinearOrder I]
    (ms : I -> OrderedMonadicStructure sig)
    (k n : Nat) (i : I)
    (env_component : Fin n -> (ms i).carrier)
    (env_sum : Fin n -> (orderedSum ms).carrier)
    (h_same_component : forall j, (env_sum j).1 = i)
    (h_same_values : forall j, (env_sum j).2 = ...) -- cast needed
    (nf : NormalForm sig k n) :
    nf_eval_nf (orderedSum ms) k n env_sum nf <->
    nf_eval_nf (ms i) k n env_component nf
```

**Why this works**: At the sentence level (n=0), the only interesting structure
is the quantifier assignment. When we existentially quantify over the sum
`exists x : Sigma, P(x)`, this decomposes as `exists i, exists y : (ms i).carrier, P(sigma.mk i y)`.
The depth-k sub-normal-form's truth at `(sigma.mk i y)` involves evaluating with
1 free variable. With 1 free variable, there are no order atoms (AtomKind sig 1
has only predicate atoms), so the depth-0 evaluation localizes to component i.
At higher depths, the quantifier introduces a second variable, and order atoms
appear -- but the proof proceeds by induction, handling the cross-component
order via case analysis on whether the new element is in the same component
or a different one.

**Detailed proof strategy**:

The proof proceeds by strong induction on k. We prove a stronger statement:

**Generalized Statement**: For all n, for any two environments `env_S` into the
sum `S = Sigma M_i` and `env_S'` into the sum `S' = Sigma M'_i`, if the
environments are "compatible" (same component indices, with corresponding
elements related by the component k-equivalences), then the same NormalForm is
satisfied.

More precisely, define "compatible environments" as: there exist component
indices `c : Fin n -> I` such that:
- `(env_S j).1 = c j` and `(env_S' j).1 = c j` for all j
- The induced component-level environments have the same k-type at each position
- Order relations between variables in the same component are preserved
- Order relations between variables in different components are preserved
  (since they share the same index structure via `c`)

For depth 0 (base case): We need all atom evaluations to agree.
- Predicate atoms `P_p(x_j)`: `S.interp p (env_S j) = (ms (c j)).interp p (env_S j).2`,
  and similarly for S'. Since the components are k-equivalent and the corresponding
  component-level variables satisfy the same NF, predicates agree.
- Order atoms `x_i < x_j`: On the sum, `env_S i < env_S j` in the lex order.
  If `c i != c j`, this is `c i < c j` in I (independent of component internals).
  If `c i = c j`, this is `(env_S i).2 < (env_S j).2` in `ms (c i)`.
  In both cases, the compatible environments ensure agreement.

For depth k+1 (inductive step):
- Atom part: Same as depth 0 argument.
- Quantifier part: For each `sub_nf : NormalForm sig k (n+1)`, need:
  `(exists x : S.carrier, nf_eval_nf S k (n+1) (Fin.cons x env_S) sub_nf) <->
   (exists x' : S'.carrier, nf_eval_nf S' k (n+1) (Fin.cons x' env_S') sub_nf)`

  Given `x = sigma.mk i y` in S, by the component k-equivalence hypothesis
  `h : ms i ≡_k ms' i`, there exists `y'` in `(ms' i).carrier` with the same
  depth-(k-1) characteristic. We set `x' = sigma.mk i y'`. The extended
  environments `Fin.cons x env_S` and `Fin.cons x' env_S'` are compatible
  (with component index `Fin.cons i c`). By the inductive hypothesis (at depth k
  with n+1 free variables), the NF evaluation agrees.

  The reverse direction is symmetric.

**Required new definitions**:
1. `orderedSum`: Construct `OrderedMonadicStructure` from indexed family
2. `orderedSumOrder`: Lexicographic `LinearOrder` on `Sigma`
3. The localization / compatibility framework (can be implicit in the proof)

**Estimated effort**: 200-350 lines total.

**Risks**:
- The compatibility relation for environments is complex (need to track component
  indices and within-component relationships)
- The inductive step requires careful handling of the cast between component
  carrier types when `c i = c j`
- De Bruijn indexing with `Fin.cons` adds some bureaucratic overhead

**Verdict**: MODERATE EFFORT, LOW RISK. Uses existing infrastructure, no new
type-theoretic abstractions needed.

### 3.3 Approach C: Direct k-type Computation

**Description**: Show `k_type_of (Sigma M_i)` is a function of the k-types of
the M_i and the order type of I, without going through normal form evaluation.

**Problem**: This would require defining the function that computes the sum's
k-type from component k-types, which is essentially reproving the composition
lemma at the k-type level. This is no simpler than Approach B.

**Verdict**: NOT RECOMMENDED. Equivalent complexity to Approach B but less
principled.

## 4. Recommended Approach: Normal Form Induction

### 4.1 Implementation Plan Overview

**Phase 1**: Close the carrier_order sorry (lexicographic order helper)
**Phase 2**: Prove the main sum_preservation lemma
**Phase 3**: Close doets_lemma_1_4 and verify downstream

### 4.2 Phase 1: Lexicographic Order (10-20 lines)

Add to `MonadicFO.lean` or `OrderedSum.lean`:

```lean
import Mathlib.Data.Sigma.Lex

/-- Lexicographic linear order on the ordered sum carrier. -/
noncomputable def orderedSumLinearOrder {I : Type} [LinearOrder I]
    (ms : I -> OrderedMonadicStructure sig) :
    LinearOrder (Sigma fun i => (ms i).carrier) :=
  inferInstanceAs (LinearOrder (Lex (Sigma fun i => (ms i).carrier)))

/-- Construct the ordered sum as an OrderedMonadicStructure. -/
noncomputable def orderedSum {sig : MonadicSignature} {I : Type} [LinearOrder I]
    (ms : I -> OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := Sigma fun i => (ms i).carrier
  interp p x := (ms x.1).interp p x.2
  carrier_order := orderedSumLinearOrder ms
```

### 4.3 Phase 2: Sum Preservation Proof (150-250 lines)

The proof is by strong induction on k. The statement to prove:

```
k_type_of sig k (orderedSum ms) = k_type_of sig k (orderedSum ms')
```

which unfolds to: for all `nf : NormalForm sig k 0`,
```
nf_eval_nf (orderedSum ms) k 0 Fin.elim0 nf <->
nf_eval_nf (orderedSum ms') k 0 Fin.elim0 nf
```

**Strengthened inductive hypothesis**: For all n, for all compatible environment
pairs into the two sums, all depth-k normal forms with n free variables agree.

The "compatible" relation means: the two environments assign elements to the
same component indices, and within each component, the corresponding elements
have the same depth-k characteristic.

**Key sub-lemmas**:

1. **Atom agreement from compatibility** (~20 lines):
   If environments are compatible, all atom evaluations agree.

2. **Compatibility of extended environments** (~40 lines):
   If environments are compatible and we extend with `Fin.cons x env_S` and
   `Fin.cons x' env_S'` where x, x' are in corresponding components with
   same depth-(k-1) characteristic, then the extended environments are compatible
   at depth (k-1).

3. **Existential transfer** (~40 lines):
   Given the component-wise k-equivalence, for each element `x = (i, y)` in
   one sum, find a corresponding `x' = (i, y')` in the other sum such that
   the extended environments are compatible.

4. **Main induction** (~80 lines):
   Combine sub-lemmas to prove the generalized statement.

### 4.4 Phase 3: Close Downstream (20-30 lines)

Once `sum_preservation` is proved in the instance:
- `doets_lemma_1_4` in OrderedSum.lean becomes a direct corollary
- The `carrier_order := sorry` in OrderedSum.lean uses `orderedSumLinearOrder`

### 4.5 Critical Consideration: carrier_order Definitional Equality

There is a subtle but important issue: the `sum_preservation` field in
`KEquivalenceFramework` has `carrier_order := sorry` literally in its type.
This means the `OrderedMonadicStructure` in the conclusion has `sorry` as
its carrier order. When we fill in the proof body, we need either:

(a) The proof to work with `sorry` as the carrier order (which it won't, since
    `nf_eval_nf` uses the order for `AtomKind.order` evaluation), or
(b) Change the field signature to use a proper order definition.

**Resolution**: The field signature in `KEquivalenceFramework` must be changed
so that `carrier_order` uses the actual lexicographic order, not `sorry`. This
is a refactoring step that changes the interface:

```lean
-- In KEquivalenceFramework, change sum_preservation to:
sum_preservation (k : Nat) (I : Type) [inst_lo : LinearOrder I]
    (ms ms' : I -> OrderedMonadicStructure sig)
    (h : forall i, equiv_at k (ms i) (ms' i)) :
    equiv_at k (orderedSum ms) (orderedSum ms')
```

This is cleaner and eliminates the inline sorry. The `doets_lemma_1_4` theorem
in OrderedSum.lean should be updated similarly.

## 5. Literature Proof Structure

**Source**: Doets 1987, Lemma 3.1.7 / Doets 1989, Lemma 1.4
**Strategy**: Ehrenfeucht-Fraisse game (in the literature); Normal form induction
(our formalization approach, equivalent by Doets 1.7.2 / 1.6.3)

### Step Map

1. **Define ordered sum structure** -- Doets 1989 Section 1 (formal definition)
   - Carrier: disjoint union of component carriers, ordered lexicographically
   - Predicates: inherited from components

2. **Assume component k-equivalence** -- Doets 1989 Lemma 1.4 hypothesis
   - For all i in I, m(i) equiv_n m'(i)

3. **Show sentence-level NF agreement** -- Core of proof
   - For each NormalForm sig k 0 (sentence), show same truth value on both sums
   - Doets' proof: describe winning strategy for Duplicator
   - Our proof: induction on k using nf_characteristic uniqueness

4. **Handle cross-component order** -- Implicit in Doets ("straightforward")
   - When quantified variables land in different components, order is determined
     by the index order in I (same for both sums)
   - When in the same component, order is within-component (transferred by
     component k-equivalence)

5. **Conclude k_equiv** -- Direct from NF agreement and k_equiv definition

### Dependencies
- Step 3 depends on Steps 1 and 2
- Step 4 is a sub-argument within Step 3
- Step 5 depends on Step 3

### Potential Formalization Challenges

- **Step 1**: The lexicographic order on Sigma types is available in Mathlib
  (`Sigma.Lex.linearOrder`), but converting between `Lex (Sigma alpha)` and
  `Sigma alpha` requires care since they are definitionally equal but not
  syntactically identical.

- **Step 3**: The inductive argument needs a generalization from sentences (n=0)
  to formulas with n free variables. The "compatible environments" relation
  adds complexity but is necessary for the induction to go through.

- **Step 4**: Cross-component order comparisons in the sum use the lexicographic
  order. The key property is: if `(env_S j).1 = (env_S' j).1` for all j
  (same component indices), then order comparisons between environment
  variables yield the same result in both sums. This is straightforward for
  different-component pairs (determined by I-order) but requires the
  component k-equivalence for same-component pairs.

## 6. Risk Assessment

### Low Risk
- **Carrier order**: Trivially closable via Mathlib's lexicographic order
- **doets_lemma_1_4**: Direct corollary of sum_preservation
- **Base case (k=0)**: Vacuous for sentences (no atoms with 0 free variables)

### Moderate Risk
- **Inductive step environment management**: The compatible environments
  framework requires careful Fin.cons bookkeeping with De Bruijn indices
- **Type coercion**: Moving between sum and component carriers involves
  Sigma projections and type casts that can create proof bureaucracy
- **carrier_order refactoring**: Changing the KEquivalenceFramework field
  signature requires updating all references

### Low Risk (but worth noting)
- **Downstream sorries**: `finite_structures_good`, `very_good_implies_good`,
  `chronicle_is_good` are NOT automatically closed by proving sum_preservation.
  They have their own proof obligations (Doets Theorem 1.1, Reynolds Lemma 16).
  Sum_preservation is a prerequisite but not sufficient.

## 7. Estimated Effort

| Component | Lines | Difficulty |
|-----------|-------|------------|
| Lexicographic order helper | 10-20 | Trivial |
| KEquivalenceFramework refactoring | 20-30 | Low |
| Main proof (generalized induction) | 150-250 | Moderate |
| doets_lemma_1_4 corollary | 10-20 | Low |
| Tests and verification | 20-30 | Low |
| **Total** | **210-350** | **Moderate** |

**Estimated implementation time**: 2-3 phases, each 1-2 hours of agent work.

## 8. Recommendations

1. **Use Approach B (Normal Form Induction)** -- avoids EF game infrastructure,
   leverages existing NormalForm/nf_eval_nf machinery.

2. **Refactor carrier_order first** -- change the KEquivalenceFramework field
   to use `orderedSum` with proper lexicographic order before attempting the
   proof body.

3. **Prove generalized statement** -- the induction requires working with
   n free variables, not just sentences. Define the "compatible environments"
   relation and prove the generalized lemma.

4. **Do not attempt downstream sorries in this task** -- `finite_structures_good`,
   `very_good_implies_good`, and `chronicle_is_good` are separate proof
   obligations that should be tracked as follow-up tasks.

5. **Consider simplification**: For the special case where the codebase only
   needs sum_preservation at the *sentence* level (n=0), a simpler proof may
   suffice. Check whether `KEquivalenceFramework.sum_preservation` is always
   called with sentence-level k-equiv. If so, the compatible-environments
   machinery can be simplified.
