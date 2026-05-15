# Task 143: Doets Lemma 1.1 Normal Form KType Redesign -- Teammate A Findings

## Literature Analysis

### Source: Doets 1989 Lemma 1.1 (NDJFL, Vol. 30, No. 2, p. 225)

**Exact statement**: "Up to logical equivalence, there are only finitely many first-order formulas of quantifier-rank < n in the free variables x_0, ..., x_{k-1} in each language."

**Proof technique**: Induction on n (quantifier rank / depth).

- **Base case (n = 0)**: There are only finitely many atomic formulas in these variables. Using disjunctive normal forms, every quantifier-free Boolean combination of finitely many atoms can be reduced to one of finitely many canonical forms.

- **Inductive step (n -> n+1)**: Choose a finite set Sigma of formulas of quantifier-rank < n in the free variables x_0, ..., x_k such that every such formula has an equivalent in Sigma (this exists by the inductive hypothesis). Now, consider disjunctive normal forms over "atoms" of the form forall x_k phi and exists x_k phi where phi in Sigma.

**Key observation**: The proof proceeds by showing that at each depth level, the "new atoms" (quantified formulas from the previous level) are finite, so Boolean combinations of these atoms plus the original atoms are also finite up to equivalence.

### Source: Doets 1987 Thesis, Chapter 1, Section 1.6-1.7

**Definition 1.6.1** (n-characteristics): For model A, tuple a in A^k, ordinal alpha:
- `[[a]]^0` = conjunction of all atomic or negated-atomic formulas in v_0,...,v_{k-1} satisfied by a in A
- `[[a]]^{alpha+1}` = bigwedge_{a in A} exists v_k [[a,a]]^alpha  wedge  forall v_k bigvee_{a in A} [[a,a]]^alpha
- `[[a]]^alpha` = bigwedge_{xi < alpha} [[a]]^xi  for limit alpha

**Theorem 1.6.3**: a equiv^alpha b iff B models [[a]]^alpha [b] iff [[b]]^alpha = [[a]]^alpha

**Lemma 1.7.1**: "If the language of A is finite then, for all k, n in N, there are only finitely many n-characteristics belonging to sequences of length k."

This is the thesis version of the 1989 Lemma 1.1. The proof strategy is identical.

### Source: Doets 1987 Thesis, Chapter 6, Section 6.3 (Modal n-characteristics)

**Definition 6.3**: For Kripke model (A,V), a in A, n in N:
- `[[a]]^0` = conjunction of {p in VAR | a in V(p)} union {not p | p in VAR, a not in V(p)}
- `[[a]]^{n+1}` = `[[a]]^0` wedge Box(bigvee_{aRa'} [[a']]^n) wedge bigwedge_{aRa'} Diamond [[a']]^n

**Section 6.12** (Normal Forms): "Let phi be a formula of modal rank n. On Kripke models in K, phi is equivalent with bigvee{[[k]]^n | rho(k) <= n and k forces phi}."

This is the modal/tense version of the same finiteness result, specialized to Kripke semantics.

### How the Literature Maps to Our Monadic FO Setting

Our setting: monadic first-order formulas with signature sig (finite unary predicates), binary order relation <, and De Bruijn variables Fin n.

At depth 0 with n free variables (x_0, ..., x_{n-1}):
- **Predicate atoms**: P_i(x_j) for each predicate i in sig.preds and variable j in Fin n
  - Count: |sig.preds| * n
- **Order atoms**: x_i < x_j for each pair (i, j) in Fin n x Fin n where i != j
  - Count: n * (n - 1) (we exclude i = j since x_i < x_i is always false)
- **Total atoms**: |sig.preds| * n + n * (n - 1)
- **Depth-0 normal forms** (up to equivalence): truth assignments to these atoms
  - Count (upper bound): 2^(|sig.preds| * n + n * (n - 1))
  - Some assignments are inconsistent with order axioms (transitivity, irreflexivity), but this is an upper bound which suffices for finiteness.

At depth k+1 with n free variables:
- By induction, there are finitely many depth-<=k formulas with n+1 free variables (up to equivalence). Call this count nfCount(p, k, n+1).
- The "new atoms" at depth k+1 are: forall x_n. phi for each of the nfCount(p, k, n+1) representatives.
  - (exists x_n. phi = not (forall x_n. not phi), so existential quantification does not add new independent atoms beyond the universal ones, since we have full Boolean combinations.)
- **Total atoms at depth k+1**: |sig.preds| * n + n * (n - 1) + nfCount(p, k, n + 1)
- **Depth-(k+1) normal forms**: 2^(|sig.preds| * n + n * (n - 1) + nfCount(p, k, n + 1))

### The Counting Function

```
def atomCount (p n : Nat) : Nat := p * n + n * (n - 1)

def nfCount (p : Nat) : Nat -> Nat -> Nat
  | 0, n => 2^(atomCount p n)
  | k+1, n => 2^(atomCount p n + nfCount p k (n + 1))
```

Sample values (p = 2 predicates):
- nfCount 2 0 0 = 1 (only one truth assignment to 0 atoms)
- nfCount 2 0 1 = 4 (2 predicate atoms, 0 order atoms)
- nfCount 2 0 2 = 64 (4 predicate + 2 order atoms = 6 atoms, 2^6)
- nfCount 2 1 0 = 16 (0 old atoms + 4 new atoms from nfCount 2 0 1, 2^4)

---

## Lean Architecture Design

### Current Architecture (Problems)

```lean
def KType (sig : MonadicSignature) (k : Nat) : Type :=
  {s : MonadicFormula sig 0 // s.quantifier_depth <= k} -> Bool
```

**Problem**: The domain `{s : MonadicFormula sig 0 // s.quantifier_depth <= k}` is syntactically INFINITE. Even at depth 0, there are infinitely many syntactic formulas: `not (not (not ... (atom p i)))`, `and phi phi`, etc. These are all logically equivalent to simpler formulas, but the subtype is not finite as a type.

This means:
1. `KType sig k` is NOT a `Fintype` in the current definition.
2. `ktype_finite` is correctly sorried -- it cannot be proved for the current definition without a quotient.
3. `KEquivalenceFramework.finite_types` is blocked by this.

### Proposed Architecture: Finite Normal Form Domain

**Core idea**: Replace the syntactically infinite domain with a finite type `Fin (nfCount p k 0)` that indexes the semantically distinct equivalence classes.

#### Step 1: Define the counting function

```lean
def atomCount (p n : Nat) : Nat := p * n + n * (n - 1)

def nfCount (p : Nat) : Nat -> Nat -> Nat
  | 0, n => 2 ^ atomCount p n
  | k+1, n => 2 ^ (atomCount p n + nfCount p k (n + 1))
```

#### Step 2: Define atomic formula enumeration

Each atom at depth 0 with n free variables is either:
- A predicate application: `atom p i` for `p : Fin numPreds` and `i : Fin n`
- An order comparison: `lt i j` for `i j : Fin n` with `i != j`

```lean
def AtomIdx (p n : Nat) := Fin (atomCount p n)

-- Interpretation: what does atom index i mean?
def atom_eval (sig : MonadicSignature) (n : Nat) 
    (M : OrderedMonadicStructure sig) (env : Fin n -> M.carrier)
    (i : AtomIdx (Fintype.card sig.preds) n) : Prop := ...
```

#### Step 3: Define normal form interpretation

A normal form at depth k with n free variables is a truth assignment:
- At depth 0: `Fin (atomCount p n) -> Bool`  (which atoms are true)
- At depth k+1: `Fin (atomCount p n + nfCount p k (n+1)) -> Bool`
  where the first `atomCount p n` bits correspond to predicate/order atoms,
  and the remaining `nfCount p k (n+1)` bits correspond to `forall x_n. nf_j`
  for each normal form j at depth k with n+1 free variables.

The encoding uses `Fin (2^N)` which is isomorphic to `Fin N -> Bool`.

```lean
noncomputable def nf_eval (sig : MonadicSignature) :
    (k : Nat) -> (n : Nat) -> Fin (nfCount (Fintype.card sig.preds) k n) ->
    (M : OrderedMonadicStructure sig) -> (Fin n -> M.carrier) -> Prop
  | 0, n, idx, M, env => -- conjunction of atoms/negated atoms per truth assignment
      ... 
  | k+1, n, idx, M, env => -- conjunction including forall-quantified sub-normal-forms
      ...
```

#### Step 4: Redefine KType

```lean
def KType (sig : MonadicSignature) (k : Nat) : Type :=
  Fin (nfCount (Fintype.card sig.preds) k 0)

-- Fintype is AUTOMATIC:
instance : Fintype (KType sig k) := Fin.fintype _
```

#### Step 5: Redefine k_type_of

```lean
noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  -- The unique normal form index i such that M satisfies nf_eval sig k 0 i M Fin.elim0
  -- This requires showing exactly one normal form is satisfied (completeness of DNF)
  ...
```

**Alternative (simpler)**: Keep KType as `Fin N -> Bool` instead of `Fin N`:

```lean
def KType (sig : MonadicSignature) (k : Nat) : Type :=
  Fin (nfCount (Fintype.card sig.preds) k 0) -> Bool

noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun i => @decide (nf_eval sig k 0 i M Fin.elim0) (Classical.dec _)
```

This approach is simpler because we do not need to prove that exactly one normal form is satisfied -- we just record which ones are.

**Key advantage**: `Fin N -> Bool` is automatically `Fintype` when `N` is a `Nat` (via `Fintype.Pi`). No work needed.

#### Step 6: Prove finite_types

```lean
-- The quotient map:
noncomputable def quotient_to_ktype (sig : MonadicSignature) (k : Nat) :
    Quotient (@Setoid.mk _ (equiv_at k) (equiv_is_equiv k)) -> KType sig k :=
  Quotient.lift (k_type_of sig k) (fun M N h => h)

-- Injectivity: follows from the equivalence theorem
-- (if k_type_of M = k_type_of N then M ≡_k N)
theorem quotient_to_ktype_injective : Function.Injective (quotient_to_ktype sig k) := ...

-- Fintype via injection:
instance : Fintype (Quotient ...) := Fintype.ofInjective _ quotient_to_ktype_injective
```

#### Step 7: Prove Doets Lemma 1.1 (the equivalence theorem)

```lean
theorem doets_lemma_1_1 (sig : MonadicSignature) (k : Nat) (n : Nat)
    (phi : MonadicFormula sig n) (hphi : phi.quantifier_depth <= k) :
    forall (M : OrderedMonadicStructure sig) (env : Fin n -> M.carrier),
      eval M env phi <->
        exists (i : Fin (nfCount (Fintype.card sig.preds) k n)),
          nf_eval sig k n i M env /\ nf_implies i phi := ...
```

Or more precisely: every depth-<=k formula is a Boolean combination of normal forms. This is proved by induction on k, matching Doets' proof exactly.

### Compatibility with Downstream Code

The downstream consumers of `KType` and `k_type_of` are:
1. **NEquivalence.lean**: `k_equiv`, `k_equiv_monotone`, `KEquivalenceFramework`
2. **OrderedSum.lean**: `doets_lemma_1_4`, `doets_lemma_1_5`
3. **IntegerModel.lean**: `good`, `very_good`, `contemp_equiv`, `one_class`, `chronicle_is_good`
4. **Transfer.lean**: `doets_countermodel_discrete`

All of these use `k_equiv` which is defined as `k_type_of M = k_type_of N`. The redesign preserves this interface as long as:
- `k_type_of` returns the same type (now `Fin N -> Bool` or just `Fin N`)
- `k_equiv` is still extensional equality of k-types
- The new `k_type_of` satisfies the same properties: `k_type_of M = k_type_of N <-> M and N satisfy the same depth-<=k sentences`

This last property is exactly Doets Lemma 1.1.

---

## Implementation Steps

### Phase 1: Define nfCount and AtomIdx (low risk)

1. Define `atomCount (p n : Nat) : Nat`
2. Define `nfCount (p : Nat) : Nat -> Nat -> Nat`
3. Define `AtomIdx (p n : Nat) := Fin (atomCount p n)`
4. Define atom enumeration: map `AtomIdx` to the concrete atom (predicate app or order comparison)

### Phase 2: Define nf_eval (medium risk)

1. Define the encoding from `Fin (2^N)` to `Fin N -> Bool` (bit extraction)
2. Define `nf_atom_eval`: semantics of individual atoms
3. Define `nf_eval` recursively:
   - Depth 0: conjunction over atoms matching the truth assignment
   - Depth k+1: conjunction over atoms AND universally quantified sub-normal-forms

**Risk**: The encoding between `Fin (2^N)` and `Fin N -> Bool` needs to be handled carefully. Mathlib has `Finset.equivFin` and `Equiv.boolArrowEquivFin` but we need to check exact availability.

### Phase 3: Redefine KType and k_type_of (medium risk)

1. Replace `KType` definition
2. Replace `k_type_of` definition
3. Prove `Fintype (KType sig k)` (now trivial)
4. Update `k_equiv` (should be unchanged: equality of k-types)
5. Verify `k_equiv_monotone` still holds (requires showing the new k-type is a refinement)

**Risk**: Downstream breakage. Must ensure all existing `k_equiv` reasoning still works.

### Phase 4: Prove Doets Lemma 1.1 (high risk, core difficulty)

1. **Base case (k = 0)**: Every quantifier-free formula is equivalent to a DNF over atoms. This is a standard result but requires careful formalization in Lean.
2. **Inductive step**: Every depth-(k+1) formula with n free vars is equivalent to a Boolean combination of:
   - Atomic formulas (from AtomIdx)
   - `forall x_n. nf_j` for some j : Fin (nfCount p k (n+1))
   
   This requires showing that `forall x_n. phi` where `phi` has depth <= k is equivalent to `forall x_n. nf_j` where nf_j is the normal form equivalent of phi (by induction).

**This is the hardest part.** The proof requires:
- A normalization function: `normalize : MonadicFormula sig n -> (phi.qd <= k) -> Fin (nfCount p k n)`
- A correctness theorem: `eval M env phi <-> nf_eval sig k n (normalize phi hphi) M env`

### Phase 5: Close finite_types (medium risk)

1. Prove `Fintype (KType sig k)` -- trivial with new definition
2. Prove `quotient_to_ktype_injective` -- requires Doets Lemma 1.1
3. Assemble `KEquivalenceFramework.finite_types` via `Fintype.ofInjective`

### Phase 6: Update downstream (low risk)

1. Verify `k_equiv_monotone` still works
2. Verify `doets_lemma_1_4` statement is compatible
3. Verify `IntegerModel.lean` definitions compile
4. Run `lake build` to check for breakage

---

## Proof Sketch for Doets Lemma 1.1

### Statement (Lean-aligned)

For all sig, k, n, and phi : MonadicFormula sig n with phi.quantifier_depth <= k:
For all M : OrderedMonadicStructure sig and env : Fin n -> M.carrier:

eval M env phi is determined by the values of nf_eval sig k n i M env for i ranging over Fin (nfCount p k n).

Equivalently: if two (M, env) pairs agree on all normal form evaluations, they agree on phi.

### Proof by induction on k

**Base case (k = 0, phi has depth 0)**:
- phi is built from atoms, not, and using atom, lt, not, and constructors.
- Every depth-0 formula is a Boolean combination of the finitely many atoms.
- The truth of phi at (M, env) depends only on which atoms are true at (M, env).
- The normal form at depth 0 records exactly which atoms are true.
- Therefore phi is determined by the normal form.

Formally: by structural induction on the depth-0 formula:
- atom p i: directly one of the atoms in AtomIdx
- lt i j: directly one of the atoms in AtomIdx
- not alpha: negation of the sub-result (handled by Boolean combinations)
- and alpha beta: conjunction (handled by Boolean combinations)
- all/ex: cannot appear (depth would be >= 1)

**Inductive step (k -> k+1, phi has depth <= k+1)**:
- By structural induction on phi:
  - atom/lt/not/and: same as base case (these don't increase depth)
  - all alpha (where alpha has depth <= k, n+1 free vars):
    By inductive hypothesis on k, alpha is determined by its normal form evaluation at depth k with n+1 free vars.
    Therefore `forall x. alpha` is determined by `forall x. (nf_eval sig k (n+1) i M (Fin.cons x env))` for each i.
    But `forall x. nf_eval sig k (n+1) i M (Fin.cons x env)` is exactly one of the "quantified atoms" at depth k+1.
    So `all alpha` is determined by the depth-(k+1) normal form.
  - ex alpha: similar (exists = not forall not, and negation is in Boolean combinations).

QED.

### Key Lemma Needed

**Boolean Combination Lemma**: If phi is a Boolean combination of propositions P_1, ..., P_m, then the truth of phi is determined by the truth values of P_1, ..., P_m.

This is trivially true semantically but needs careful formalization in Lean. It can be proved by structural induction on the Boolean combination (not, and).

---

## Confidence Level

**Overall confidence: HIGH (85%)**

- **Architecture soundness**: 95% -- The Fin-based KType redesign is mathematically correct and Lean-friendly. The `Fintype.ofInjective` path for `finite_types` is verified to work.

- **nfCount definition**: 95% -- The recursive counting function is standard and well-understood. The upper bound approach (counting all truth assignments, not just consistent ones) is sufficient for finiteness.

- **nf_eval definition**: 80% -- The recursive semantic interpretation is well-defined, but the encoding between `Fin (2^N)` and `Fin N -> Bool` requires careful Lean work. Need to verify Mathlib has the right equivalences.

- **Doets Lemma 1.1 proof**: 70% -- The mathematical argument is clear and standard, but formalizing it in Lean requires:
  - A clean structural induction on formulas
  - Careful handling of the Boolean combination lemma
  - The universal quantifier step (going from "phi is equivalent to nf_j" to "forall x. phi is equivalent to forall x. nf_j")
  - These are all doable but may encounter Lean-specific friction (universe issues, dependent type gymnastics).

- **finite_types closure**: 90% -- Once Doets Lemma 1.1 is proved, `finite_types` follows by the `Fintype.ofInjective` pattern, which is verified to work.

- **Downstream compatibility**: 85% -- The interface change is minimal (KType type changes but k_equiv semantics are preserved). However, some downstream proofs may need adjustment.

### Key Risks

1. **Encoding friction**: The `Fin (2^N) <-> (Fin N -> Bool)` equivalence may not be readily available in Mathlib in the exact form needed.

2. **Recursion well-foundedness**: The `nf_eval` function recurses on (k, n) where k decreases but n increases. Lean's termination checker should handle this via the lexicographic order on (k, n) (k strictly decreasing), but explicit termination proofs may be needed.

3. **Boolean combination formalization**: Proving that every depth-0 formula is a Boolean combination of finitely many atoms requires a clean structural induction. The tricky part is handling nested `not` and `and` without `all`/`ex`.

4. **Alternative simpler approach**: Instead of the full nf_eval machinery, we could define KType as `(Fin N -> Bool) -> Bool` (functions from truth assignments to Bool) which is also finite. But this is less clean and harder to reason about.

### Recommended Approach

Use the **Fin N -> Bool** definition for KType (Option 2 from Phase 3 above). This avoids the need to prove that exactly one normal form is satisfied and keeps the `k_type_of` definition straightforward. The `finite_types` proof then follows from `Fintype.ofInjective`.

---

## Summary of Sorries to Close

| Location | Sorry | Dependency |
|----------|-------|------------|
| NEquivalence.lean:355 | `ktype_finite` | Needs Fintype (KType sig k) -- trivial with new def |
| NEquivalence.lean:379 | `finite_types k` | Needs Fintype on Quotient -- via Fintype.ofInjective + Doets 1.1 |
| NEquivalence.lean:382 | `sum_preservation` | Independent (EF game formalization) -- NOT addressed by this task |
| NEquivalence.lean:331,334 | `carrier_order` in sum_preservation | Independent -- NOT addressed by this task |

This task addresses the first two sorries. The `sum_preservation` sorry is a separate concern requiring EF-game formalization.
