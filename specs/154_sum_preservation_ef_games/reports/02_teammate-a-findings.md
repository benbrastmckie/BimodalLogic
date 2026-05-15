# Teammate A Findings: sum_preservation via Normal Form Induction

**Task**: 154 — sum_preservation and doets_lemma_1_4
**Date**: 2026-05-15
**Role**: Teammate A — Primary approach identification via literature analysis

---

## Key Findings

### 1. The Mathematical Content of the Sorry

`sum_preservation` (NEquivalence.lean:190) asserts:

```
k_equiv sig k
  { carrier := Sigma fun i => (ms i).carrier
    interp := fun p x => (ms x.1).interp p x.2
    carrier_order := sorry }
  { carrier := Sigma fun i => (ms' i).carrier
    interp := fun p x => (ms' x.1).interp p x.2
    carrier_order := sorry }
```

given `h : ∀ i, k_equiv sig k (ms i) (ms' i)`. Since `k_equiv` is defined as
`k_type_of sig k M = k_type_of sig k N`, which unfolds to equality of truth-value
functions on `NormalForm sig k 0`, the statement is: if each component pair
`(ms i, ms' i)` satisfies the same depth-≤k normal form sentences, then the
ordered sums also satisfy the same depth-≤k normal form sentences.

`doets_lemma_1_4` (OrderedSum.lean:45) is the same statement in standalone theorem
form; once `sum_preservation` is proved in the `KEquivalenceFramework` instance,
`doets_lemma_1_4` follows immediately.

### 2. The Literature Statement (Doets 1989, Lemma 1.4)

From `literature/Doets_1989_Monadic_Pi11_Theories.md`, Section 1, Lemma 1.4:

> **1.4 Lemma**: If for all i ∈ I, m(i) =_n m'(i), then Σ_{i∈I} m(i) =_n Σ_{i∈I} m'(i).
>
> **Proof**: It is straightforward to describe a winning strategy for the second
> player in the Ehrenfeucht n-game between these sums under the condition given.

Doets' proof is via EF games. Reynolds 1994 (Lemma 16, Theorem 15) uses
this result as a black-box, writing "We assume familiarity with lexicographic
sums of linear orders and with the fact that =_k is preserved under such sums.
See [Doets 1987, 1989] for details." Neither source provides the detailed
inductive argument we need for the Lean proof.

### 3. The carrier_order Sorry

Both `sum_preservation` and `doets_lemma_1_4` have `carrier_order := sorry`
in the `OrderedMonadicStructure` record literal. This sorry is independent of
the proof-body sorry and must be fixed first.

**Mathlib has exactly what is needed**:
- `Sigma.Lex.linearOrder` in `Mathlib.Data.Sigma.Lex`:
  ```
  Sigma.Lex.linearOrder : {ι : Type u_1} → {α : ι → Type u_2} →
    [LinearOrder ι] → [(i : ι) → LinearOrder (α i)] →
    LinearOrder (Σₗ (i : ι), α i)
  ```
  where `Σₗ` is notation for `Lex (Σ ...)`.

The type `Σₗ i, f i` and `Σ i, f i` are definitionally equal (same underlying
type), so we can write:
```lean
noncomputable def orderedSumLinearOrder {I : Type} [LinearOrder I]
    {sig : MonadicSignature} (ms : I → OrderedMonadicStructure sig) :
    LinearOrder (Sigma fun i => (ms i).carrier) :=
  haveI : ∀ i, LinearOrder ((ms i).carrier) := fun i => (ms i).carrier_order
  (Sigma.Lex.linearOrder (ι := I) (α := fun i => (ms i).carrier) : LinearOrder _)
```

### 4. Prior Research Report (01) Analysis

The existing report `01_sum-preservation-research.md` already covers the basic
landscape. **My contribution here is to do the deeper technical analysis needed
to turn the outline into a concrete proof plan**:

- Verifying the compatibility-environment framework is the right approach
- Identifying the key inductive lemma
- Checking that the base case (k=0) is genuinely simple
- Working through the quantifier case in detail
- Identifying where coercions are needed

---

## Recommended Approach: Normal Form Induction (Approach B)

**Rationale**: The codebase already has a complete normal form theory in
`NormalForm.lean`. The proof of `nf_agreement_monotone` (lines 339-421 of
NormalForm.lean) shows exactly the style of argument needed: it proves that
NF agreement is monotone in depth using the structural properties of normal
forms. The `sum_preservation` proof follows the same structural pattern.

**Do not use EF games**: Doets' proof is via EF games, but the formalized
infrastructure translates EF game reasoning into NF induction reasoning
automatically — `nf_characteristic` and `nf_exists_unique` are the Lean
encoding of "describe a winning strategy for the Duplicator". The NF
induction proof is equivalent, uses existing infrastructure, and is
substantially shorter.

### Detailed Proof Sketch

#### Setup

Define a helper structure:
```lean
/-- An 'ordered sum' as an OrderedMonadicStructure. -/
noncomputable def orderedSum {sig : MonadicSignature} {I : Type} [LinearOrder I]
    (ms : I → OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := Σ i, (ms i).carrier
  interp p x := (ms x.1).interp p x.2
  carrier_order := orderedSumLinearOrder ms
```

The lexicographic order on `Σ i, (ms i).carrier` compares by index first:
`⟨i, x⟩ < ⟨j, y⟩ ↔ i < j ∨ (i = j ∧ x < y)`.

#### Core Lemma (the key inductive statement)

```lean
theorem sum_preservation_core {sig : MonadicSignature}
    {I : Type} [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_equiv : ∀ i, k_equiv sig k (ms i) (ms' i)) :
    ∀ (n : Nat)
    (env_S : Fin n → (orderedSum ms).carrier)
    (env_S' : Fin n → (orderedSum ms').carrier)
    (h_same_idx : ∀ j, (env_S j).1 = (env_S' j).1)
    (h_component_equiv : ∀ j,
      k_equiv sig k
        { carrier := (ms (env_S j).1).carrier
          interp := (ms (env_S j).1).interp
          carrier_order := (ms (env_S j).1).carrier_order }
        -- ... with env restricting to within-component
    ),
    ∀ nf : NormalForm sig k n,
    nf_eval_nf (orderedSum ms) k n env_S nf ↔
    nf_eval_nf (orderedSum ms') k n env_S' nf
```

This is too heavy. The real approach is simpler: instead of a compatibility
relation on environments, we use the **characteristic normal form** approach
that already permeates the codebase.

#### The Actual Proof Strategy

**Core insight from nf_agreement_monotone**: The proof of `nf_agreement_monotone`
uses `nf_exists_unique` to show that if we can transfer the characteristic normal
form from one structure to another at depth k, then NF agreement propagates.
The same pattern works for ordered sums.

**The key lemma** to prove is:

```lean
theorem orderedSum_nf_agree {sig : MonadicSignature}
    {I : Type} [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h : ∀ i, k_equiv sig k (ms i) (ms' i))
    (k n : Nat)
    (env_S : Fin n → (orderedSum ms).carrier)
    (env_S' : Fin n → (orderedSum ms').carrier)
    -- Environments are "index-compatible": same component for each position
    (h_idx : ∀ j, (env_S j).1 = (env_S' j).1)
    -- For each position, the within-component element pair is k-equiv
    (h_comp : ∀ j, ... component equivalence at appropriate depth ...) :
    ∀ nf : NormalForm sig k n,
    nf_eval_nf (orderedSum ms) k n env_S nf ↔
    nf_eval_nf (orderedSum ms') k n env_S' nf
```

The proof is by induction on k.

#### Base Case: k = 0

`NormalForm sig 0 n = AtomKind sig n → Bool`. We need:
```
(∀ a, atom_eval (orderedSum ms) env_S a ↔ nf a = true) ↔
(∀ a, atom_eval (orderedSum ms') env_S' a ↔ nf a = true)
```

This reduces to showing `atom_eval (orderedSum ms) env_S a ↔ atom_eval (orderedSum ms') env_S' a`
for each atom `a`:

- **Case `a = pred p j`**: `atom_eval (orderedSum ms) env_S (pred p j)` is
  `(ms (env_S j).1).interp p (env_S j).2`. Since `(env_S j).1 = (env_S' j).1`
  by `h_idx`, and the component pair is k-equiv (hence 0-equiv), and `interp p`
  is a monadic predicate tracked by the NF system at depth 0, the predicate
  values transfer.

  More concretely: since `h_comp j` says the component pair is k-equiv, the
  0-NF (atom assignment) for `(env_S j).2` and `(env_S' j).2` agree. The
  predicate atom is tracked in the 0-NF, so `interp p (env_S j).2 ↔ interp p (env_S' j).2`.

- **Case `a = order i j h_ij`**: `atom_eval (orderedSum ms) env_S (order i j h_ij)`
  is `env_S i < env_S j` in the lexicographic order on `Σ`. This is:
  `(env_S i).1 < (env_S j).1 ∨ ((env_S i).1 = (env_S j).1 ∧ (env_S i).2 < (env_S j).2)`.
  
  The `(env_S' -)` version uses the same index values (by `h_idx`), so the
  cross-component case is identical. For the same-component case, the order
  comparison within-component transfers by the component k-equiv (which implies
  that the order atom's truth value is the same).

#### Inductive Step: k = m + 1

Given depth-(m+1) NFs for `n` free variables with compatible environments, need:
- **Atom part**: Same as base case (depth-0 atom agreement).
- **Quantifier part**: For each `sub_nf : NormalForm sig m (n+1)`, show:
  `(∃ x : Σ, nf_eval_nf (orderedSum ms) m (n+1) (Fin.cons x env_S) sub_nf) ↔
   (∃ x' : Σ', nf_eval_nf (orderedSum ms') m (n+1) (Fin.cons x' env_S') sub_nf)`

  **Forward** (given `x = ⟨i, y⟩` in orderedSum ms):
  - `h i : k_equiv sig k (ms i) (ms' i)` (component k-equiv)
  - Since `k_equiv` means same k-type, and `y` has some depth-k characteristic `char_y`
    in `ms i`, there exists `y' ∈ (ms' i).carrier` with the same depth-(m+1) characteristic
    (note k = m+1 ≥ m+1, so we use the full k-equiv).
  - Actually: we need depth-m NF agreement for the extended environment
    `Fin.cons ⟨i, y⟩ env_S` and `Fin.cons ⟨i, y'⟩ env_S'`.
  - The extended environment is index-compatible: position 0 has index i in both,
    positions 1..n have indices from env_S/env_S' which are compatible by IH hypotheses.
  - The within-component equivalence for position 0: `y` and `y'` have the same
    depth-(m) characteristic in `ms i` and `ms' i` respectively (from k_equiv).
  - By the inductive hypothesis (at depth m), the sub_nf evaluation agrees.

  **Reverse**: Symmetric (find y from y' using component k-equiv in reverse).

#### The Within-Component Transfer Mechanism

The key mechanism for finding `y'` from `y` is:
```lean
-- From h_equiv i : k_equiv sig k (ms i) (ms' i)
-- which means: k_type_of sig k (ms i) = k_type_of sig k (ms' i)
-- which means: for all NF φ : NormalForm sig k 0, 
--   nf_eval_nf (ms i) k 0 Fin.elim0 φ ↔ nf_eval_nf (ms' i) k 0 Fin.elim0 φ
```

But we need transfer with 1 free variable, not 0. This requires strengthening
the hypothesis from `k_equiv` (sentence-level equality) to NF agreement with
free variables.

**Critical insight**: `nf_agreement_monotone` already gives us exactly this!
If `k_equiv sig k (ms i) (ms' i)`, then by definition the k-types are equal,
which means they satisfy the same k-NF sentences. By `doets_lemma_1_1` and
`nf_agreement_monotone`, this implies they satisfy the same depth-m NF formulas
with n free variables, for any n and m ≤ k.

Formally: from `k_equiv sig (m+1) (ms i) (ms' i)`, we need to transfer
`nf_eval_nf (ms i) m (n+1) (Fin.cons y env_i) sub_nf` to `ms' i`.

This requires the **generalized NF transfer** within components. The component
k-equiv gives us transfer of k-NF sentences (0 free variables). We need transfer
for m < k with n+1 free variables.

**The recursion bridge**: The component k-equiv `h i` at the sentence level
is sufficient because:
1. `nf_exists_unique (ms i) (m+1) (n+1) (Fin.cons y env_i)` gives us
   the characteristic `char_i : NormalForm sig (m+1) (n+1)`.
2. We need to find a `y'` in `ms' i` such that
   `nf_eval_nf (ms' i) m (n+1) (Fin.cons y' env_i') sub_nf`.
3. But `nf_eval_nf` at depth m with n+1 free vars is NOT directly given by
   the sentence-level k_equiv.

**Resolution**: We need to strengthen the inductive hypothesis to handle
environments (not just sentences). The correct inductive statement is:

```
IH(m): For all structures M, M' with k_equiv sig m M M',
  for all n, for all envs env_M : Fin n → M.carrier, env_M' : Fin n → M'.carrier
  such that the envs "correspond" (same characteristic NF for each position),
  for all nf : NormalForm sig m n,
  nf_eval_nf M m n env_M nf ↔ nf_eval_nf M' m n env_M' nf
```

But this is essentially `nf_agreement_monotone` applied to a pair of structures!
Looking at `nf_agreement_monotone` in NormalForm.lean (lines 339-421): it proves
exactly this, but for a pair of (M, env_M) and (N, env_N) where we have k-NF
agreement (at depth k ≥ m) with **the same environment type** (same Fin n → T.carrier
type). It does NOT handle the case where M and N have different carriers.

**This is the key gap to bridge**: `nf_agreement_monotone` handles agreement
for a fixed structure with two different environments (or rather: two structure-environment
pairs where the NF evaluations happen to agree at depth k). For the ordered sum
proof, M and N have different carriers (the sum carriers), and we need to bridge
across the component carriers.

#### The Revised Strategy: Element-by-Element Transfer

The correct approach avoids the cross-carrier issue by working directly with
the characteristic NF witness:

**Lemma A** (atom evaluation in sum localizes to component):
```lean
lemma atom_eval_sum {sig} {I} [LinearOrder I] (ms : I → OrderedMonadicStructure sig)
    (n : Nat) (env_S : Fin n → Σ i, (ms i).carrier)
    (a : AtomKind sig n) :
    atom_eval (orderedSum ms) env_S a ↔
    match a with
    | .pred p j => (ms (env_S j).1).interp p (env_S j).2
    | .order i j h =>
        let ci := (env_S i).1; let cj := (env_S j).1
        if h_same : ci = cj
        then (env_S i).2 < h_same ▸ (env_S j).2  -- compare within component
        else ci < cj  -- compare by index
```

**Lemma B** (characteristic NF of sum element, sentence-level):
The k-type of the sum M_Σ (as a structure, with empty environment) is NOT
a simple function of the component k-types unless I is finite. For infinite I,
the k-type of the sum depends on the order type of I and the k-type distribution.

Wait — this is crucial. Let me reconsider.

#### Reconsidering the Scope

For `sum_preservation`, the input is:
- `∀ i, k_equiv sig k (ms i) (ms' i)` — component-wise equivalence
- Both sums have the **same index type I** with the **same order on I**
- We want to show the whole sums are k-equivalent

This is much simpler than the general EF-game argument because:
1. The index type I is the **same** in both sums
2. The component k-equivalences are **pointwise** (same index i, equivalent components)

**The simple proof structure**:

For any NF sentence `φ : NormalForm sig k 0`:
- `nf_eval_nf (orderedSum ms) k 0 Fin.elim0 φ`
  means: the ordered sum satisfies φ
- `nf_eval_nf (orderedSum ms') k 0 Fin.elim0 φ`
  means: the primed ordered sum satisfies φ

We need to show these have the same truth value.

By `nf_exists_unique`, the ordered sum satisfies exactly one k-NF sentence.
Let `char_Σ = nf_characteristic (orderedSum ms) k 0 Fin.elim0`.

We need: `nf_eval_nf (orderedSum ms') k 0 Fin.elim0 char_Σ`.

Then `nf_eval_unique` gives us `k_type_of (orderedSum ms) = k_type_of (orderedSum ms')`.

#### Induction on k for Sentence-Level NF

**Lemma (Sum NF, sentence level, induction on k)**:
For all `k`, if `∀ i, k_equiv sig k (ms i) (ms' i)`, then:
```
nf_eval_nf (orderedSum ms) k 0 Fin.elim0 char_Σ →
nf_eval_nf (orderedSum ms') k 0 Fin.elim0 char_Σ
```

where `char_Σ = nf_characteristic (orderedSum ms) k 0 Fin.elim0`.

**Base case k = 0**: `char_Σ : AtomKind sig 0 → Bool`. With 0 free variables,
`AtomKind sig 0` has no predicates (pred p j requires Fin 0, which is empty)
and no order atoms (order i j h requires i, j : Fin 0, empty). So
`AtomKind sig 0 = Empty` (or at least has no elements), and the unique depth-0
NF sentence is the empty truth assignment. Both sums trivially satisfy it.
**Base case is vacuous — both NF sentences are the same (the empty truth assignment).**

**Inductive step k → k+1**: `char_Σ : (AtomKind sig 0 → Bool) × (NormalForm sig k 1 → Bool)`.
- Atom part: `AtomKind sig 0 → Bool`. As above, this is the empty function, so trivial.
- Quantifier part: `∀ sub_nf : NormalForm sig k 1,`
  `(∃ x : Σ i, (ms i).carrier, nf_eval_nf (orderedSum ms) k 1 (Fin.cons x Fin.elim0) sub_nf)`
  `↔ (char_Σ.2 sub_nf = true)`.
  
  We need to show (orderedSum ms') satisfies this same quantifier assignment.
  
  **Forward direction** (showing orderedSum ms' satisfies sub_nf iff char_Σ.2 sub_nf):
  
  For each sub_nf with `char_Σ.2 sub_nf = true`:
  - There exists `x = ⟨i, y⟩` in orderedSum ms with the sub_nf satisfied
  - `nf_eval_nf (ms i).toOrdered k 1 (Fin.cons y Fin.elim0) sub_nf`
    (localized to component i — this needs the atom evaluation localization lemma)
  - By `h_equiv i : k_equiv sig k (ms i) (ms' i)`, and sub_nf is a depth-k NF
    with 1 free variable
  - **Gap**: k_equiv is sentence-level (0 free variables), but sub_nf needs 1 free variable

This brings us back to the same issue. The sentence-level k_equiv does not
directly give us transfer of NF formulas with free variables.

#### The Complete Resolution

The missing piece is a lemma that bridges sentence-level k_equiv to
formula-level (with free variables). This is essentially the content of
`doets_lemma_1_1` (the bridge theorem) plus `nf_agreement_monotone`.

**Here is the bridge**: 

```lean
theorem k_equiv_nf_transfer {sig : MonadicSignature} {k : Nat}
    {M N : OrderedMonadicStructure sig}
    (h : k_equiv sig k M N)
    (m : Nat) (hm : m ≤ k) (n : Nat)
    (env_M : Fin n → M.carrier) (env_N : Fin n → N.carrier)
    (h_env : ∀ j, k_equiv sig k
        { carrier := M.carrier, interp := M.interp, carrier_order := M.carrier_order }
        -- restricted to the j-th element... this doesn't quite typecheck
    ) :
    ∀ nf : NormalForm sig m n,
    nf_eval_nf M m n env_M nf ↔ nf_eval_nf N m n env_N nf
```

This requires relating the environments element-by-element. The right formulation
is that `env_M j` and `env_N j` have the same **depth-k characteristic in their
respective structures**. But that doesn't make sense since they're in different
structures.

**The actual correct formulation**: We need to work with **partial isomorphisms**
at depth k. The n-characteristic of `(M, env_M)` is the NF in `NormalForm sig k n`,
and the n-characteristic of `(N, env_N)` is also in `NormalForm sig k n`. Two
environments are "k-n-equivalent" if they satisfy the same NF in `NormalForm sig k n`.

```lean
theorem nf_eval_nf_iff_same_char {sig} {M N : OrderedMonadicStructure sig}
    (k n : Nat)
    (env_M : Fin n → M.carrier) (env_N : Fin n → N.carrier)
    (h_char : nf_characteristic M k n env_M = nf_characteristic N k n env_N) :
    ∀ nf : NormalForm sig k n,
    nf_eval_nf M k n env_M nf ↔ nf_eval_nf N k n env_N nf
```

This follows from `nf_agreement_from_shared_nf` in NormalForm.lean (lines 291-307).
If M,env_M and N,env_N share the same characteristic NF, they agree on all NFs.

So the proof strategy is:
1. Show that for compatible environments (same component indices, with
   elements having matching characteristics within components), the
   ordered sums have matching characteristics.
2. Use `nf_agreement_from_shared_nf` to conclude NF agreement.

#### Final Proof Structure

**Main lemma**:
```lean
theorem orderedSum_char_eq {sig : MonadicSignature} {I : Type} [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h : ∀ i, k_equiv sig k (ms i) (ms' i))
    (n : Nat)
    (env_S : Fin n → Σ i, (ms i).carrier)
    (env_S' : Fin n → Σ i, (ms' i).carrier)
    -- Same indices
    (h_idx : ∀ j, (env_S j).1 = (env_S' j).1)
    -- Elements have matching characteristics in their respective components
    (h_char : ∀ j,
      nf_characteristic (ms ((env_S j).1)) k 1 (fun _ => (env_S j).2) =
      nf_characteristic (ms' ((env_S' j).1)) k 1 (fun _ => (env_S' j).2)) :
    -- Conclusion: the ordered sums have the same characteristic NF
    nf_characteristic (orderedSum ms) k n env_S =
    nf_characteristic (orderedSum ms') k n env_S'
```

Wait — but this formulation uses `k 1` for the element characteristics but the
main induction is on `k`. This would be circular.

**The actual correct induction**: We prove by induction on k that if the
component k-types are equal AND the environments have matching index projections,
then the ordered sum NF evaluations agree. The "matching characteristics" of
individual elements emerge from the IH.

Let me write the proof structure cleanly:

```lean
-- The induction goes on k.
-- P(k) := ∀ sig, ∀ I : Type, [LinearOrder I], ∀ ms ms' : I → OMS sig,
--   (∀ i, k_equiv sig k (ms i) (ms' i)) →
--   ∀ n, ∀ env_S : Fin n → Σ i, (ms i).carrier,
--          ∀ env_S' : Fin n → Σ i, (ms' i).carrier,
--   (∀ j, (env_S j).1 = (env_S' j).1) →
--   (∀ j, nf_characteristic (ms ((env_S j).1)) k 1 ![env_S j].2 =
--          nf_characteristic (ms' ((env_S' j).1)) k 1 ![env_S' j].2) →
--   ∀ nf : NormalForm sig k n,
--   nf_eval_nf (orderedSum ms) k n env_S nf ↔
--   nf_eval_nf (orderedSum ms') k n env_S' nf

-- Actually the right statement:
-- The characteristic NF of env_S in (orderedSum ms) equals
-- the characteristic NF of env_S' in (orderedSum ms')
-- given that they have the same index and the same depth-k type in their components.
```

This is getting circular because "same depth-k type in components" is itself
stated using k-NFs.

**The resolution**: The induction is on n (the number of free variables), not k.

For fixed k, prove by induction on n that:
- If the component k-types match pointwise, AND
- The environments have matching index projections, AND
- The element-level characteristics match (at depth k with 1 free variable)
- Then the ordered sum n-variable NF evaluations agree.

But n=0 is the sentence case, and n=1 introduces 1 free variable, etc. The
induction goes DOWNWARD as quantifiers are stripped.

**The clean proof structure** (following the pattern of `nf_agreement_monotone`):

```lean
-- The key lemma, proved by induction on k
theorem sum_nf_agree (k : Nat) : 
    ∀ {sig : MonadicSignature} {I : Type} [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h : ∀ i, k_equiv sig k (ms i) (ms' i))
    (n : Nat)
    (env_S : Fin n → (orderedSum ms).carrier)
    (env_S' : Fin n → (orderedSum ms').carrier)
    (h_idx : ∀ j, (env_S j).1 = (env_S' j).1)
    (h_char : ∀ j,
      nf_characteristic (ms ((env_S j).1)) k 1
        (fun _ => (env_S j).2) =
      nf_characteristic (ms' ((env_S' j).1)) k 1
        (fun _ => (env_S' j).2))
    (nf : NormalForm sig k n),
    nf_eval_nf (orderedSum ms) k n env_S nf ↔
    nf_eval_nf (orderedSum ms') k n env_S' nf
```

Hmm but the "h_char" condition is using k with 1 free variable, which is at
the same depth k as the conclusion. This works for the induction because the
induction goes on the *number of free variables*.

Actually the cleanest approach, following the structure already in the codebase,
is:

**Prove: if two (OMS, env) pairs have the same k-NF characteristic, they agree on all NFs.**

This is already `nf_agreement_from_shared_nf`! Then the goal becomes:
**showing that (orderedSum ms, env_S) and (orderedSum ms', env_S') have the same
k-NF characteristic when the environments are index-compatible and the
component elements are k-equiv.**

The k-NF characteristic of `(orderedSum ms, env_S)` is determined by:
1. The truth values of atoms `atom_eval (orderedSum ms) env_S a` for all a
2. The set of depth-(k-1) NFs with n+1 free variables that are realized

For (1): atoms with 0 free vars don't exist. Atoms with 1+ free vars decompose
into predicate atoms (handled per-component) and order atoms (handled by index
comparison for cross-component, per-component for same-component).

For (2): this is the quantifier case. The depth-(k-1) NFs realized with env_S
extended by some x are exactly the depth-(k-1) NFs φ such that there exists
⟨i, y⟩ in the sum with φ realized at (orderedSum ms, Fin.cons ⟨i, y⟩ env_S).
By the component k-equiv, the set of realized depth-(k-1) NFs within component i
is the same in ms i and ms' i (since the component elements realizing them
are k-equiv pairs, and by the IH at depth k-1).

So the quantifier assignment of the k-NF characteristic of (orderedSum ms, env_S)
equals that of (orderedSum ms', env_S') — both record which depth-(k-1) NFs
with n+1 free variables are realized, and this set is the same because:
- Cross-component realization: same (same index I, same ordering of I)  
- Within-component realization at each i: same (because ms i ≡_k ms' i)

#### Summary of the Full Proof

The proof has this structure:

```
sum_preservation
  ← orderedSum_char_eq (show k-NF chars match for both sums)
      ← atom_eval_sum_compat (atom part: use h_idx and component equiv)
      ← quant_assignment_sum_compat (quantifier part: induction)
          ← for each realized sub_nf in orderedSum ms:
              find witness in orderedSum ms' using component k_equiv
              use nf_exists_unique + nf_agreement_from_shared_nf
  → nf_agreement_from_shared_nf
```

---

## Confidence Assessment

### High Confidence
- **carrier_order**: `Sigma.Lex.linearOrder` from Mathlib directly solves this.
  No complications. Just add `import Mathlib.Data.Sigma.Order` and use
  `inferInstanceAs (LinearOrder (Σₗ i, f i))`.

- **doets_lemma_1_4**: Once `sum_preservation` in the `KEquivalenceFramework`
  instance is proved, `doets_lemma_1_4` follows by applying the instance field.

- **Base case (k = 0, n = 0)**: With 0 free variables, `AtomKind sig 0` is
  uninhabited (no predicate atoms without variables, no order atoms without
  variables). The unique NF is the empty assignment. Both sums satisfy it trivially.
  This case needs to be verified that `AtomKind sig 0` is indeed `Fin.elim0`-range,
  which follows from the `Fintype (AtomKind sig 0)` instance being empty.

- **Literature alignment**: Doets 1989 Lemma 1.4 is exactly the theorem being
  proved. The NF-induction proof is equivalent to (and avoids formalizing) the
  EF game proof Doets uses.

### Moderate Confidence
- **Inductive step**: The structure is sound but requires careful bookkeeping
  of `Fin.cons`, `h_idx` invariants, and component-carrier coercions. The
  within-component element transfer (using `nf_exists_unique` for `ms i` to
  find a corresponding element in `ms' i`) needs careful handling since
  `ms i` and `ms' i` have different carrier types.

- **Coercions**: When we write `(env_S j).2 : (ms ((env_S j).1)).carrier` and
  need to compare with `(env_S' j).2 : (ms' ((env_S' j).1)).carrier`, the
  index compatibility `h_idx j : (env_S j).1 = (env_S' j).1` lets us `subst`
  or `rw` to align types. This is doable but adds bureaucratic proof steps.

### Lower Confidence (but still feasible)
- **Quantifier assignment localization**: The claim that "the set of realized
  depth-(k-1) NFs with n+1 free variables is the same for both sums" needs
  careful treatment because the realized NFs depend on all n+1 environment
  variables together (not just the newly introduced one). The IH must track
  the full environment compatibility, not just element-by-element characteristics.
  
  This is the hardest part of the proof. The right approach is to maintain the
  invariant that `h_idx` and `h_char` hold for the extended environments after
  each quantifier step.

---

## Recommended Implementation Plan

### Phase 1: Infrastructure (5-15 lines)
- Add `import Mathlib.Data.Sigma.Order` to MonadicFO.lean or NEquivalence.lean
- Define `orderedSumLinearOrder` using `Sigma.Lex.linearOrder`
- Define `orderedSum` as an `OrderedMonadicStructure`
- Refactor `KEquivalenceFramework.sum_preservation` field to use `orderedSum`
  (removing the inline `carrier_order := sorry`)
- Refactor `doets_lemma_1_4` and `doets_lemma_1_5` in OrderedSum.lean similarly

### Phase 2: Atom Agreement Lemma (20-40 lines)
- Prove `atom_eval_orderedSum`: unfold `atom_eval` on `orderedSum` to show
  predicate atoms evaluate per-component and order atoms evaluate lexicographically
- Prove `atom_eval_sum_compat`: from `h_idx` and component k-equiv, atom evaluations agree

### Phase 3: Main Induction Proof (100-200 lines)
- Prove the core induction: `sum_nf_char_eq` or equivalent
- Handle base case (trivial, since n=0 → AtomKind sig 0 is empty)
- Handle inductive step using:
  - Atom part: via atom agreement lemma
  - Quantifier part: for each realized sub_nf, find corresponding witness
    in the other sum using `nf_exists_unique` for the component pair

### Phase 4: Close sorries (10-20 lines)
- Replace `sorry` in `KEquivalenceFramework` instance (line 190) with the proof
- Replace `sorry` in `doets_lemma_1_4` using the instance
- Replace all `carrier_order := sorry` with `orderedSumLinearOrder`

### Estimated total: 135-275 lines of new Lean code

---

## Key Lemmas to Look For or Prove

### Already in Codebase
- `nf_exists_unique`: Every (M, env) satisfies exactly one NF — **CENTRAL**
- `nf_agreement_from_shared_nf`: If two pairs share the same NF, they agree on all NFs
- `nf_characteristic_satisfies`: The char NF is always satisfied
- `nf_eval_unique`: If two NFs are both satisfied, they're equal
- `nf_agreement_monotone`: NF agreement is monotone in depth

### Need to Prove
- `atom_eval_orderedSum`: Unfolds atom evaluation on ordered sums
- `orderedSumLinearOrder`: Lex order on Sigma carrier types (trivial via Mathlib)
- Core `sum_nf_agree` lemma: The main induction

### In Mathlib (Verified by Loogle)
- `Sigma.Lex.linearOrder`: Exists in `Mathlib.Data.Sigma.Order`
- `PSigma.Lex.linearOrder`: Also exists for PSigma variant

---

## Literature Proof Structure

**Source**: Doets 1989, Lemma 1.4 (p. 227)
**Strategy in Source**: EF game (Duplicator's winning strategy)
**Formalization Strategy**: Normal form induction (equivalent, avoids game formalization)

### Step Map

1. **Fix the lexicographic order** — not explicit in Doets (he works informally with
   ordered sums), but the lex order is implicit in his definition of the sum
   (Section 1, p. 226)

2. **Assume ∀i, m(i) =_n m'(i)** — Lemma 1.4 hypothesis

3. **For each depth-k NF sentence φ, show: orderedSum ms ⊨ φ ↔ orderedSum ms' ⊨ φ**
   - Doets: describe Duplicator's strategy
   - Our proof: show the k-NF characteristic is the same

4. **Atom part (depth-0 agreement)**: Follows from component-wise equivalence
   and the fact that order comparison is determined by the index (for
   cross-component) or component order (for same-component)

5. **Quantifier part (depth-k → depth-(k-1) transfer)**:
   - Witness in orderedSum ms at component i → find witness in orderedSum ms' at component i
   - Transfer uses component k-equivalence: ms i ≡_k ms' i means same (k-1)-NF realization

6. **Conclude k_equiv** — k_type_of equality from NF sentence agreement

### Dependencies
- Step 3 uses Steps 4 and 5
- Step 5 uses component k-equiv (Step 2) and IH at depth k-1
- Step 6 uses Step 3

### Formalization Challenges
- **Step 4**: Cross-component order atoms evaluate by index in I (no challenge);
  same-component order atoms need the element-level k-equiv not directly given
  by sentence-level `k_equiv`. Requires using characteristic NF witnesses.
- **Step 5**: Finding the witness in ms' i from a witness in ms i requires
  using `nf_exists_unique (ms' i) k 1 [...]` plus `nf_agreement_from_shared_nf`
  applied to the component pair. The "1 free variable" context complicates this
  compared to the sentence-level case.
- **Coercions**: Moving between `(ms ((env_S j).1)).carrier` and
  `(ms' ((env_S' j).1)).carrier` when `(env_S j).1 = (env_S' j).1`.

---

## Confidence Level

**Overall**: HIGH — the proof approach is sound and uses existing infrastructure.
The main risk is bureaucratic proof complexity in the quantifier step, not
mathematical correctness.

**Estimated lines**: 135–275 for the full proof, excluding the carrier_order fix
which is 5–10 lines.

**Recommendation**: Proceed with this approach. No EF games needed. The proof
is a straightforward generalization of the pattern already used in
`nf_agreement_monotone` (NormalForm.lean lines 339-421).
