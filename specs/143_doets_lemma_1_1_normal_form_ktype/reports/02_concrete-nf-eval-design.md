# Research Report: Concrete nf_eval and the Mathematically Correct NormalForm Implementation

- **Task**: 143 - Doets Lemma 1.1: normal form KType redesign with finite domain
- **Started**: 2026-05-15T09:30:00Z
- **Completed**: 2026-05-15T10:00:00Z
- **Effort**: Analysis and design
- **Dependencies**: 139 (completed)
- **Sources/Inputs**:
  - Doets 1987 thesis, Chapter 1, Sections 1.6-1.7 (n-characteristics)
  - Doets 1989, Lemma 1.1 (finiteness of formulas up to equivalence)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (current KType, eval, MonadicFormula)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` (current vacuous implementation)
  - `specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_team-research.md`
- **Artifacts**: This file
- **Standards**: report.md, status-markers.md, artifact-management.md, tasks.md

## Executive Summary

- The current `nf_eval` is vacuous: `Classical.choice ⟨True⟩` ignores all inputs and returns an arbitrary `Prop` for every index, structure, and environment. This makes `doets_lemma_1_1` unprovable and `nf_rep` semantically disconnected from formula evaluation.
- The mathematically correct approach replaces `NormalFormIdx := Fin (nfCount ...)` with an **inductive `NormalForm` type** whose constructors mirror Doets' n-characteristics (Definition 1.6.1). This makes `nf_eval` a structural recursion that faithfully maps normal forms to their semantic content.
- With a concrete `nf_eval`, the bridge theorem `doets_lemma_1_1` becomes a natural two-level induction matching the textbook proof exactly.
- The inductive approach also enables a sorry-free `k_equiv_monotone` (currently sorry), since depth embedding becomes a structural operation on normal forms.
- `Fintype (NormalForm sig k n)` requires a proof by induction on `k` rather than `inferInstance`, but each step is straightforward (`Fintype` of a function type from a `Fintype` to `Bool`).

## Context & Scope

### Current Codebase Definitions

**MonadicFormula** (`NEquivalence.lean:75-82`):
```lean
inductive MonadicFormula (sig : MonadicSignature) : Nat → Type where
  | atom {n : Nat} (p : sig.preds) (i : Fin n) : MonadicFormula sig n
  | lt {n : Nat} (i j : Fin n) : MonadicFormula sig n
  | not {n : Nat} (α : MonadicFormula sig n) : MonadicFormula sig n
  | and {n : Nat} (α β : MonadicFormula sig n) : MonadicFormula sig n
  | all {n : Nat} (α : MonadicFormula sig (n + 1)) : MonadicFormula sig n
  | ex {n : Nat} (α : MonadicFormula sig (n + 1)) : MonadicFormula sig n
```

**eval** (`NEquivalence.lean:228-235`):
```lean
def eval {sig : MonadicSignature} {n : Nat} (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) : MonadicFormula sig n → Prop
  | .atom p i => M.interp p (env i)
  | .lt i j => @LT.lt M.carrier carrier_order.toLT (env i) (env j)
  | .not α => ¬ eval M env α
  | .and α β => eval M env α ∧ eval M env β
  | .all α => ∀ (x : M.carrier), eval M (Fin.cons x env) α
  | .ex α => ∃ (x : M.carrier), eval M (Fin.cons x env) α
```

Key convention: quantifier binding uses `Fin.cons x env` (De Bruijn variable 0 = innermost bound). `Fin.cons x env 0 = x` and `Fin.cons x env (i.succ) = env i`.

**quantifier_depth** (`NEquivalence.lean:88-95`):
```lean
def MonadicFormula.quantifier_depth : MonadicFormula sig n → Nat
  | .atom _ _ => 0
  | .lt _ _ => 0
  | .not α => α.quantifier_depth
  | .and α β => max α.quantifier_depth β.quantifier_depth
  | .all α => α.quantifier_depth + 1
  | .ex α => α.quantifier_depth + 1
```

**MonadicSignature** (`NEquivalence.lean:53-59`):
```lean
structure MonadicSignature where
  preds : Type
  [fintypePreds : Fintype preds]
  [decEqPreds : DecidableEq preds]
```

`Fintype.card sig.preds` gives the count `p` of unary predicates.

**OrderedMonadicStructure** (`NEquivalence.lean:104-117`):
```lean
structure MonadicStructure (sig : MonadicSignature) where
  carrier : Type
  interp (p : sig.preds) : carrier → Prop

structure OrderedMonadicStructure (sig : MonadicSignature)
    extends MonadicStructure sig where
  carrier_order : LinearOrder carrier
```

### The Vacuous nf_eval Problem

The current `nf_eval` (`NormalForm.lean:107-117`):
```lean
noncomputable def nf_eval (sig : MonadicSignature) (k n : Nat)
    (_idx : NormalFormIdx sig k n) (M : OrderedMonadicStructure sig)
    (_env : Fin n → M.carrier) : Prop :=
  let _ := M.carrier
  Classical.choice ⟨True⟩
```

This ignores `_idx`, `M`, and `_env`. It returns an arbitrary `Prop` (in practice `True`) for every input. The function `nf_vector` built on top of it produces the same `Bool` vector for every structure and environment, making the bridge theorem hypothesis `h_vec` trivially true but the conclusion `eval M env_M φ ↔ eval N env_N φ` unrelated to it. No amount of induction can prove `doets_lemma_1_1` from this definition.

Similarly, `nf_rep` in `NEquivalence.lean:303-307` uses `Classical.choice` to return an arbitrary formula for each index, with no connection to the semantics.

### Current Sorry Status

| Definition | File | Status |
|---|---|---|
| `finite_types` | NEquivalence.lean:421 | Closed (via `Fintype.ofInjective` into `KType`) |
| `doets_lemma_1_1` | NormalForm.lean:152 | sorry (vacuous nf_eval prevents proof) |
| `k_equiv_monotone` | NEquivalence.lean:353 | sorry (needs depth embedding) |
| `sum_preservation` | NEquivalence.lean:439 | sorry (out of scope, needs EF games) |

## Findings

### The Mathematically Correct Approach: Inductive NormalForm

Doets 1987 Definition 1.6.1 defines n-characteristics inductively:

- **Depth 0**: The 0-characteristic of a tuple `a` in model `A` is the conjunction of all atomic/negated-atomic formulas true of `a`. There are finitely many such conjunctions (one per truth assignment to the finite set of atoms).

- **Depth k+1**: The (k+1)-characteristic of `a` in `A` extends the 0-characteristic with information about which depth-k characteristics (with one additional variable) are existentially realized. Formally: for each depth-k normal form `nf` with `n+1` variables, record whether `∃ x, nf_eval nf A (a, x)` holds.

This directly suggests an **inductive type** where:
- A depth-0 normal form IS a truth assignment to atoms
- A depth-(k+1) normal form IS a truth assignment to atoms PLUS a specification of which depth-k normal forms (with one extra variable) are existentially realized

### Definition 1: AtomIdx -- Enumeration of Atomic Propositions

With `p` unary predicates and `n` free variables, the atoms are:
- `P_i(x_j)` for `i : Fin p` and `j : Fin n` (predicate atoms, count: `p * n`)
- `x_i < x_j` for `i j : Fin n` with `i ≠ j` (order atoms, count: `n * (n-1)`)
- Total: `atomCount p n = p * n + n * (n - 1)`

We need a concrete type that enumerates these atoms and a function that evaluates each atom in a structure:

```lean
inductive AtomKind (sig : MonadicSignature) (n : Nat) where
  | pred (p : sig.preds) (i : Fin n) : AtomKind sig n
  | order (i j : Fin n) (h : i ≠ j) : AtomKind sig n
```

This type is `Fintype` (product of finite types, sum of finite types). Its cardinality is `atomCount (Fintype.card sig.preds) n`.

The atom evaluation function connects `AtomKind` to `eval`:

```lean
def atom_eval (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) : AtomKind sig n → Prop
  | .pred p i => M.interp p (env i)
  | .order i j _ => @LT.lt M.carrier M.carrier_order.toLT (env i) (env j)
```

This exactly matches the `atom` and `lt` cases of `eval`.

### Definition 2: NormalForm -- Inductive Type

```lean
inductive NormalForm (sig : MonadicSignature) : Nat → Nat → Type where
  | base (assignment : AtomKind sig n → Bool) : NormalForm sig 0 n
  | step (atom_assignment : AtomKind sig n → Bool)
         (quant_assignment : NormalForm sig k (n + 1) → Bool) :
         NormalForm sig (k + 1) n
```

A depth-0 normal form is a function `AtomKind sig n → Bool`: a truth assignment to atoms. A depth-(k+1) normal form is a pair: a truth assignment to atoms, plus a function `NormalForm sig k (n+1) → Bool` recording which depth-k normal forms with one extra variable are existentially realized.

This mirrors Doets' Definition 1.6.1 exactly:
- `[[a]]^0` = conjunction of all atomic/negated-atomic formulas true of `a` → corresponds to `base assignment` where `assignment` records which atoms hold
- `[[a]]^{k+1}` = `[[a]]^0 ∧ ⋀_{a'∈A} ∃v_{n+1}[[a,a']]^k ∧ ∀v_{n+1} ⋁_{a'∈A} [[a,a']]^k` → corresponds to `step atom_assignment quant_assignment` where `quant_assignment nf = true` iff `∃ x, nf_eval nf M (Fin.cons x env)`

### Definition 3: Fintype for NormalForm

`Fintype (NormalForm sig k n)` is proved by induction on `k`:

**Base case (k = 0)**:
```lean
NormalForm sig 0 n = { base assignment | assignment : AtomKind sig n → Bool }
```
This is isomorphic to `AtomKind sig n → Bool`, which is `Fintype` since `AtomKind sig n` is `Fintype`.

**Inductive step (k → k+1)**:
```lean
NormalForm sig (k+1) n ≅ (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)
```
By the IH, `NormalForm sig k (n+1)` is `Fintype`. Therefore `NormalForm sig k (n+1) → Bool` is `Fintype`. The product with `AtomKind sig n → Bool` (also `Fintype`) is `Fintype`.

Concretely:
```lean
instance : Fintype (NormalForm sig k n) := by
  induction k generalizing n with
  | zero =>
    -- NormalForm sig 0 n ≅ (AtomKind sig n → Bool)
    exact Fintype.ofEquiv (AtomKind sig n → Bool) baseEquiv.symm
  | succ k ih =>
    -- NormalForm sig (k+1) n ≅ (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)
    have : Fintype (NormalForm sig k (n + 1)) := ih (n + 1)
    exact Fintype.ofEquiv _ stepEquiv.symm
```

where `baseEquiv` and `stepEquiv` are the obvious `Equiv`s between the inductive constructors and the corresponding function/product types.

**Cardinality**: The cardinality of `NormalForm sig k n` equals `nfCount (Fintype.card sig.preds) k n`. This can be proved by induction:
- Base: `|AtomKind sig n → Bool| = 2^|AtomKind sig n| = 2^(atomCount p n) = nfCount p 0 n`
- Step: `|(AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)| = 2^(atomCount p n) * 2^(nfCount p k (n+1)) = 2^(atomCount p n + nfCount p k (n+1)) = nfCount p (k+1) n`

This proof is optional for closing `finite_types` (we only need `Fintype`, not the exact cardinality), but it confirms the counting function is correct.

### Definition 4: nf_eval -- Concrete Semantic Evaluation

```lean
noncomputable def nf_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) : NormalForm sig k n → Prop
  | .base assignment =>
    -- A depth-0 normal form holds iff each atom matches the assignment
    ∀ (a : AtomKind sig n),
      atom_eval M env a ↔ (assignment a = true)
  | .step atom_assignment quant_assignment =>
    -- A depth-(k+1) normal form holds iff:
    -- (1) Each atom matches the atom assignment, AND
    -- (2) Each depth-k normal form (with n+1 vars) is existentially realized
    --     iff the quant_assignment says so
    (∀ (a : AtomKind sig n),
      atom_eval M env a ↔ (atom_assignment a = true)) ∧
    (∀ (nf : NormalForm sig k (n + 1)),
      (∃ (x : M.carrier), nf_eval M (Fin.cons x env) nf) ↔
        (quant_assignment nf = true))
```

This is well-founded: the recursive call in `step` is on `NormalForm sig k (n+1)` where `k` strictly decreases (from `k+1` to `k`), and `n` increases from `n` to `n+1` but this is irrelevant since the recursion is structural on the `NormalForm` inductive (the `nf` argument in the recursive call is a direct sub-component of the `step` pattern via `quant_assignment`).

Wait -- there is a subtlety. The recursive call `nf_eval M (Fin.cons x env) nf` has `nf : NormalForm sig k (n+1)`, which is structurally smaller in `k` but `nf` is not a sub-term of the input `.step atom_assignment quant_assignment`. The recursion is on `k` (the first index), not on the `NormalForm` value. Lean's equation compiler should handle this as well-founded recursion on `k`, but it may need an explicit `termination_by` annotation:

```lean
termination_by k
```

Or alternatively, define `nf_eval` as a two-argument function with explicit recursion on `k`:

```lean
noncomputable def nf_eval (sig : MonadicSignature) :
    (k : Nat) → (n : Nat) → NormalForm sig k n →
    OrderedMonadicStructure sig → (Fin n → carrier) → Prop
  | 0, n, .base assignment, M, env => ...
  | k + 1, n, .step atom_assgn quant_assgn, M, env => ...
```

The `noncomputable` is needed because `nf_eval` quantifies over all `x : M.carrier` (which may be infinite) and uses the `LinearOrder` instance which may not be decidable. This matches the existing `eval` convention.

### Definition 5: nf_characterizes -- Every Structure has a Unique Normal Form

For the bridge theorem, we need to show that for every structure `M`, environment `env`, and depth `k`, there exists exactly one normal form that `M, env` satisfies:

```lean
theorem nf_exists_unique (sig : MonadicSignature) (k n : Nat)
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier) :
    ∃! (nf : NormalForm sig k n), nf_eval M env nf
```

**Proof by induction on k**:

**Base case (k = 0)**: The unique normal form is `base (fun a => decide (atom_eval M env a))`. This follows because each atom either holds or doesn't, and the normal form that records exactly the truth values of all atoms is the unique one satisfied.

**Inductive step (k → k+1)**: By the IH applied at depth `k` with `n+1` variables, for each `x : M.carrier`, there is a unique `nf_x : NormalForm sig k (n+1)` such that `nf_eval M (Fin.cons x env) nf_x`. Define:
- `atom_assgn := fun a => decide (atom_eval M env a)`
- `quant_assgn := fun nf => decide (∃ x, nf_eval M (Fin.cons x env) nf)`

The normal form `step atom_assgn quant_assgn` is the unique one satisfied.

The existence part is straightforward. Uniqueness follows because two normal forms agreeing on all atom evaluations and all existential queries must have the same assignments (by function extensionality and decidability).

### Definition 6: Doets Lemma 1.1 -- The Bridge Theorem

**Statement**: For every formula `φ : MonadicFormula sig n` with `φ.quantifier_depth ≤ k`, the truth of `φ` in any structure `M` under any environment `env` is determined by which `NormalForm sig k n` is satisfied:

```lean
theorem doets_lemma_1_1 (sig : MonadicSignature) (k n : Nat)
    (φ : MonadicFormula sig n) (h_depth : φ.quantifier_depth ≤ k)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin n → M.carrier) (env_N : Fin n → N.carrier)
    (h_same_nf : ∀ (nf : NormalForm sig k n),
      nf_eval M env_M nf ↔ nf_eval N env_N nf) :
    (eval M env_M φ ↔ eval N env_N φ)
```

The hypothesis `h_same_nf` says: M and N satisfy exactly the same normal forms at depth k. The conclusion: they agree on every depth-≤k formula.

**Proof by two-level induction**: Outer induction on `k`, inner structural induction on `φ`.

#### Base case (k = 0, φ has depth 0)

By structural induction on φ (which must be quantifier-free since depth = 0):

- **`φ = .atom p i`**: We need `M.interp p (env_M i) ↔ N.interp p (env_N i)`. The atom `AtomKind.pred p i` is one of the atoms. By `h_same_nf`, every depth-0 normal form satisfied by `(M, env_M)` is also satisfied by `(N, env_N)`. In particular, the unique normal form for `(M, env_M)` (from `nf_exists_unique`) has `assignment (AtomKind.pred p i) = decide (M.interp p (env_M i))`. Since `(N, env_N)` satisfies this same normal form, `N.interp p (env_N i)` agrees.

  More concretely: let `nf_M` be the unique depth-0 normal form for `(M, env_M)`. Then `nf_eval M env_M nf_M` holds. By `h_same_nf`, `nf_eval N env_N nf_M` holds. Unfolding the depth-0 `nf_eval`: `atom_eval N env_N (AtomKind.pred p i) ↔ (nf_M.assignment (AtomKind.pred p i) = true)`. And `nf_M.assignment (AtomKind.pred p i) = true ↔ atom_eval M env_M (AtomKind.pred p i)`. Chaining gives `atom_eval M env_M (AtomKind.pred p i) ↔ atom_eval N env_N (AtomKind.pred p i)`, which is exactly `M.interp p (env_M i) ↔ N.interp p (env_N i)`.

- **`φ = .lt i j`**: Identical argument using `AtomKind.order i j h`.

- **`φ = .not α`**: By inner IH, `eval M env_M α ↔ eval N env_N α`. Negate both sides.

- **`φ = .and α β`**: By inner IH on both subformulas. Conjoin.

- **`φ = .all α` or `.ex α`**: Impossible since `quantifier_depth (.all α) = α.quantifier_depth + 1 ≥ 1 > 0 = k`.

#### Inductive step (k → k+1, φ has depth ≤ k+1)

We have the outer IH: the theorem holds for all depth-≤k formulas with any number of free variables. By structural induction on φ:

- **`φ = .atom p i`**, **`φ = .lt i j`**, **`φ = .not α`**, **`φ = .and α β`**: Same as base case. For `.not` and `.and`, the sub-formulas have depth ≤ k+1, so the inner IH applies.

- **`φ = .all α`** where `α : MonadicFormula sig (n+1)` and `α.quantifier_depth ≤ k`:

  We need: `(∀ x, eval M (Fin.cons x env_M) α) ↔ (∀ y, eval N (Fin.cons y env_N) α)`.

  **Forward direction**: Assume `∀ x, eval M (Fin.cons x env_M) α`. Let `y : N.carrier`. We need `eval N (Fin.cons y env_N) α`.

  By `nf_exists_unique` at depth k with n+1 variables, there is a unique `nf_y : NormalForm sig k (n+1)` with `nf_eval N (Fin.cons y env_N) nf_y`.

  From `h_same_nf` at depth k+1 with n variables: `M` and `N` satisfy the same depth-(k+1) normal forms. In particular, for the unique depth-(k+1) normal form `nf_M` satisfied by `(M, env_M)`, the quantifier assignment `quant_assgn` records `quant_assgn nf_y = true` iff `∃ x, nf_eval M (Fin.cons x env_M) nf_y`. Since `(N, env_N)` also satisfies `nf_M`, we have: `(∃ y', nf_eval N (Fin.cons y' env_N) nf_y) ↔ (quant_assgn nf_y = true) ↔ (∃ x, nf_eval M (Fin.cons x env_M) nf_y)`.

  But we actually need a stronger fact: not just that some `x` realizes `nf_y`, but that `eval M (Fin.cons x env_M) α` holds for such an `x`. This is where the **outer IH** applies: since `α.quantifier_depth ≤ k` and `nf_eval M (Fin.cons x env_M) nf_y` holds (meaning `(M, Fin.cons x env_M)` and `(N, Fin.cons y env_N)` satisfy the same depth-k normal forms via `nf_y`), the outer IH gives `eval M (Fin.cons x env_M) α ↔ eval N (Fin.cons y env_N) α`.

  Since `∀ x, eval M (Fin.cons x env_M) α` holds, in particular for any `x` that realizes `nf_y` we get `eval M (Fin.cons x env_M) α`, hence by the IH, `eval N (Fin.cons y env_N) α`.

  Actually, this argument needs refinement. The issue is that to apply the outer IH, we need `(M, Fin.cons x env_M)` and `(N, Fin.cons y env_N)` to agree on all depth-k normal forms, not just that they both satisfy `nf_y`. But `nf_exists_unique` gives uniqueness: if both `(M, Fin.cons x env_M)` and `(N, Fin.cons y env_N)` satisfy `nf_y`, then for any other normal form `nf'`, `nf_eval M (Fin.cons x env_M) nf'` holds iff `nf' = nf_y` iff `nf_eval N (Fin.cons y env_N) nf'`. So they agree on ALL depth-k normal forms, and the outer IH applies.

  The full argument for the forward direction of `.all`:
  1. Let `y : N.carrier`. Let `nf_y` be the unique depth-k normal form for `(N, Fin.cons y env_N)`.
  2. Since `(N, env_N)` satisfies the same depth-(k+1) normal forms as `(M, env_M)`, and the depth-(k+1) normal form for `(N, env_N)` records `quant_assgn nf_y = true` (since `y` witnesses `∃ y', nf_eval N (Fin.cons y' env_N) nf_y`), the same holds for `(M, env_M)`: `∃ x, nf_eval M (Fin.cons x env_M) nf_y`.
  3. Pick such an `x`. Now `(M, Fin.cons x env_M)` satisfies `nf_y`, and by uniqueness, `(M, Fin.cons x env_M)` and `(N, Fin.cons y env_N)` satisfy the same depth-k normal forms.
  4. By outer IH: `eval M (Fin.cons x env_M) α ↔ eval N (Fin.cons y env_N) α`.
  5. By hypothesis: `eval M (Fin.cons x env_M) α` holds.
  6. Therefore: `eval N (Fin.cons y env_N) α`.

  The backward direction is symmetric.

- **`φ = .ex α`** where `α.quantifier_depth ≤ k`: Dual of `.all`. Forward: given `∃ x, eval M (Fin.cons x env_M) α`, pick such `x`. Let `nf_x` be its depth-k normal form. The depth-(k+1) normal form for `(M, env_M)` records `quant_assgn nf_x = true`. Since `(N, env_N)` satisfies the same depth-(k+1) normal form, `∃ y, nf_eval N (Fin.cons y env_N) nf_x`. Pick such `y`. By uniqueness + outer IH: `eval M (Fin.cons x env_M) α ↔ eval N (Fin.cons y env_N) α`. Since the left side holds, the right side holds, so `∃ y, eval N (Fin.cons y env_N) α`.

### Definition 7: k_equiv_monotone via Normal Form Projection

With the inductive `NormalForm`, monotonicity of k-equivalence (`k_equiv_monotone`: if `m ≤ k` and `k_equiv sig k M N` then `k_equiv sig m M N`) becomes provable by constructing a **projection** from depth-k normal forms to depth-m normal forms.

Define a function `project : NormalForm sig k n → NormalForm sig m n` for `m ≤ k` that "forgets" quantifier information beyond depth m:

```lean
def NormalForm.project (h : m ≤ k) : NormalForm sig k n → NormalForm sig m n
```

By induction on `m` and `k`:
- If `m = 0`: return `base (atom_assignment_of nf)` -- extract just the atom assignment from any depth-k normal form
- If `m = m'+1` and `k = k'+1`: return `step (atom_assgn) (fun nf_sub => quant_assgn (nf_sub.embed h'))` where `embed` lifts depth-m' normal forms to depth-k' normal forms

Then prove: if `nf_eval M env nf` holds, then `nf_eval M env (nf.project h)` holds. This gives: if M and N agree on all depth-k normal forms, they agree on all depth-m normal forms (since every depth-m normal form is a projection of some depth-k normal form).

### Comparison: Current vs. Correct Approach

| Aspect | Current (Fin-based) | Correct (Inductive) |
|---|---|---|
| `NormalFormIdx` | `Fin (nfCount p k n)` | `NormalForm sig k n` (inductive) |
| `Fintype` | `inferInstance` (trivial) | Proved by induction on k (straightforward) |
| `nf_eval` | Vacuous (`Classical.choice ⟨True⟩`) | Structural recursion, semantically faithful |
| `doets_lemma_1_1` | `sorry` (unprovable) | Provable by two-level induction |
| `k_equiv_monotone` | `sorry` | Provable via normal form projection |
| `nf_rep` | Abstract (`Classical.choice`) | Not needed (NormalForm IS the representation) |
| `KType` | `NormalFormIdx sig k 0 → Bool` | `NormalForm sig k 0 → Bool` |
| `k_type_of` | Uses vacuous `nf_rep` | `fun nf => decide (nf_eval M Fin.elim0 nf)` |
| `finite_types` | Closed (via `Fintype.ofInjective`) | Closed (same technique, but now with semantic backing) |

### Implementation Effort Estimate

| Component | Lines (est.) | Difficulty |
|---|---|---|
| `AtomKind` inductive + `atom_eval` | 20-30 | LOW |
| `Fintype AtomKind` + cardinality | 20-30 | LOW |
| `NormalForm` inductive | 10-15 | LOW |
| `Fintype NormalForm` by induction | 40-60 | MEDIUM (need `Equiv` constructions) |
| `nf_eval` (structural recursion) | 20-30 | LOW-MEDIUM |
| `nf_exists_unique` | 40-60 | MEDIUM |
| `doets_lemma_1_1` (bridge theorem) | 80-120 | HIGH (two-level induction, quantifier cases) |
| `k_equiv_monotone` (projection) | 30-50 | MEDIUM |
| KType/k_type_of redesign | 20-30 | LOW (mostly mechanical) |
| Downstream fixes | 20-40 | LOW |
| **Total** | **300-465** | 10-15 hours |

## Decisions

1. Replace `NormalFormIdx := Fin (nfCount ...)` with inductive `NormalForm sig k n`
2. Replace vacuous `nf_eval` with structural recursion on `NormalForm`
3. Introduce `AtomKind sig n` for explicit atom enumeration
4. Prove `Fintype (NormalForm sig k n)` by induction on `k`
5. Prove `doets_lemma_1_1` by two-level induction (outer on k, inner structural on φ)
6. Close `k_equiv_monotone` via normal form projection
7. `nf_rep` becomes unnecessary (remove it)
8. `KType sig k := NormalForm sig k 0 → Bool` (preserves existing API)

## Recommendations

1. **Implement in NormalForm.lean** -- replace the current file contents entirely. The file is new (created by the current task 143 implementation) so there is no legacy to preserve.
2. **Start with AtomKind + atom_eval** -- this is the simplest component and provides the foundation for everything else.
3. **Prove nf_exists_unique before doets_lemma_1_1** -- uniqueness is needed in the quantifier cases of the bridge theorem.
4. **Use `termination_by k`** for nf_eval if Lean's equation compiler doesn't automatically see the recursion is well-founded.
5. **Keep nfCount as a separate computable function** -- useful for documentation and potential future cardinality proofs, even though it's not needed for `Fintype`.
6. **Test with `lean_goal` at each step** -- the dependent types in NormalForm will require careful handling.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| `Fintype (NormalForm sig k n)` Equiv construction is fiddly | Each step is `Fintype.ofEquiv` with a simple bijection; can use `Fintype.ofSurjective` as fallback |
| nf_eval well-founded recursion rejected by Lean | Use explicit `termination_by k` or define as a two-argument function with `Nat.rec` |
| Quantifier case in doets_lemma_1_1 proof is complex | The `nf_exists_unique` lemma encapsulates the hard part; the bridge theorem then uses it cleanly |
| AtomKind enumeration needs DecidableEq for Fintype | `AtomKind` derives DecidableEq since sig.preds has DecidableEq and Fin has DecidableEq |
| Downstream breakage from NormalForm replacing NormalFormIdx | API surface (KType, k_type_of, k_equiv) is preserved; only internal types change |

## Appendix

### Doets 1987 Definition 1.6.1 (paraphrased)

For model A, tuple `a ∈ A^n`, depth α:
- `[[a]]^0` = conjunction of all atomic or negated-atomic formulas in `v_0,...,v_{n-1}` satisfied by `a` in `A`
- `[[a]]^{α+1}` = `[[a]]^0 ∧ (⋀_{a'∈A} ∃v_n [[a,a']]^α) ∧ (∀v_n ⋁_{a'∈A} [[a,a']]^α)`

Our `NormalForm` captures this: `base assignment` corresponds to `[[a]]^0` (recording which atoms hold), and `step atom_assgn quant_assgn` corresponds to `[[a]]^{k+1}` (recording atoms plus which depth-k characteristics are realized existentially).

The universal quantifier part `∀v_n ⋁_{a'∈A} [[a,a']]^α` is captured implicitly: since the existential assignment records EXACTLY which depth-k normal forms are realized, the universal quantifier is the complement (any depth-k normal form NOT in the existential assignment is universally denied). This is because for each `x : M.carrier`, exactly one normal form is satisfied (by uniqueness), so `∀x, ⋁_{nf} nf_eval M (Fin.cons x env) nf` is always true, and the universal quantifier's content reduces to "for every `x`, the normal form realized by `x` is in the specified set."

### Variable Binding Convention

The codebase uses `Fin.cons x env` for quantifier binding:
- `Fin.cons x env : Fin (n+1) → M.carrier`
- `Fin.cons x env 0 = x` (newly bound variable)
- `Fin.cons x env (Fin.succ i) = env i` (existing variables)

The `NormalForm` definition must match: at depth k+1 with n variables, the quantifier assignment ranges over `NormalForm sig k (n+1)`, and evaluation at these normal forms uses `Fin.cons x env` as the extended environment.
