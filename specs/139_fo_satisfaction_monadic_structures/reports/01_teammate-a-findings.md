# Teammate A Findings: FO Satisfaction for Monadic Structures

**Task 139**: Close k-equivalence sorry chain via first-principles FO satisfaction

**Date**: 2026-05-14

---

## Key Findings

### 1. What the Literature Defines as Monadic FO Satisfaction

The primary source is Doets 1989 (Monadic Pi^1_1-Theories) and Doets 1987 (thesis Chapter 1,
Chapter 3, Chapter 7). The monadic language is defined precisely in Reynolds 1994, Section 6.

**Reynolds 1994 (Section 6) canonical definition:**

> A temporal structure (T, <, h) can be made into a first-order structure in the monadic language
> by interpreting < as < and each predicate P as being true of exactly those points in h(p).

The **monadic language** over a finite signature `sig` is:
- Domain: carrier `M.carrier` (a linear order `(T, <)`)
- Unary predicates: one `P_i` per `sig.preds` symbol
- Binary relation: `<` (the order)
- Sentences: first-order sentences using atoms `P_i(x)`, `x < y`, Boolean connectives,
  and quantifiers `∀x`, `∃x` binding individual variables

The **standard translation** (called "table" in Reynolds) maps temporal formulas to monadic FO
sentences in one free variable `t`. For example (Reynolds 1994, p. 122):

```
C_{U(A,B)}(t) = ∃s > t (C_A(s) ∧ ∀u(t < u ∧ u < s → C_B(u)))
```

This translation has ONE free variable. The notion of "sentence" means all variables are bound
(i.e., `C_φ(t)` is a formula with one free variable; `∀t. C_φ(t)` is a sentence).

### 2. How Doets Handles Variable Binding

Doets 1989 (Lemma 1.1, which matches the 1987 thesis Section 1.7.1) states:

> Up to logical equivalence, there are only finitely many first-order formulas of quantifier-rank
> ≤ n in the free variables x_0, ..., x_{k-1} in each language.

The key is: formulas have **explicit free variable lists** `(x_0, ..., x_{k-1})`. The **k-characteristic**
of a tuple `a = (a_0, ..., a_{k-1})` in model `M` (Doets thesis, Definition 1.6.1) is:

```
[[a]]^0  = conjunction of all atomic/negated atomic formulas in v_0,...,v_{k-1} satisfied by a
[[a]]^{n+1} = [[a]]^0 ∧ (∧_{a ∈ A} ∃v_k [[aa]]^n) ∧ (∀v_k ∨_{a ∈ A} [[aa]]^n)
```

For **sentences** (the k-type case, k-1 = -1, i.e., no free variables):

```
[[∅]]^0  = conjunction of all atomic sentences true in M (vacuous in monadic case since atoms need
           free variables -- so this is just the collection of all ground sentences true in M)
[[∅]]^{n+1} = [[∅]]^0 ∧ (∧_{a ∈ M} ∃v_0 [[a]]^n) ∧ (∀v_0 ∨_{a ∈ M} [[a]]^n)
```

The **n-characteristic of the whole model** (i.e., the "k-type" in Reynolds' terminology) is
exactly `[[∅]]^n`.

For the **monadic language specifically**: quantifier-rank-n sentences over a finite signature
(with unary predicates P_1,...,P_k and the order <) are the right syntactic objects. Reynolds
1994 Theorem 15 uses "monadic sentences of quantifier depth at most k."

### 3. Standard Definition of k-Type and k-Equivalence in the Literature

**Doets 1989, Introduction (p. 225 of Notre Dame J. Formal Logic):**

> Models are called n-equivalent (denoted ≡^n) iff they satisfy the same first-order sentences
> of quantifier-rank ≤ n.

**Reynolds 1994, Theorem 15 definition (p. 129):**

> If M and N are structures we write M ≡_k N if and only if M and N agree on the truth of
> monadic sentences of quantifier depth at most k.

The **k-type** of a structure is the set of all quantifier-depth-≤k sentences true in it.
Doets 1989 calls this the "n-characteristic" (conjunction of all depth-≤n true sentences).

**Key finiteness fact (Doets 1989, Lemma 1.1 / thesis 1.7.1):**

For a finite language with k unary predicates and the order relation <:
- Sentences of quantifier depth 0: atoms and negations of atoms (P_i(x), x<y, etc.) with all
  variables bound. For sentences with NO free variables, the depth-0 sentences are just
  propositional combinations of ground atoms -- but in monadic FO, there are no ground atoms
  (all atoms require at least one variable). So the depth-0 sentences are just propositional
  tautologies: `⊤` and `⊥`.
- Sentences of quantifier depth 1: involve one quantifier. E.g., `∃x P_1(x)`.
- The total count grows but is finite for any fixed n.

The finiteness proof is by induction on n, using disjunctive normal forms (Doets 1989, Lemma 1.1
proof). For n=0: finitely many atomic formulas. For n+1: build from n-step formulas by ∃/∀ combinations.

### 4. What Variable Binding Scheme the Literature Uses

The literature uses **standard FO variable binding** with individual (element) variables. NOT
De Bruijn indices per se -- but De Bruijn is the natural Lean encoding.

From Doets 1987, Chapter 1 (the framework used in Chapter 3 and 7):
- Variables are `v_0, v_1, v_2, ...` (countably many, indexed by natural numbers)
- A formula's **free variables** are those not bound by a quantifier
- Quantifier `∃v_k φ` (or `∀v_k φ`) adds `v_k` to the bound variables of `φ`
- The k-characteristic formula `[[a_0,...,a_{k-1}]]^n` has exactly free variables `{v_0,...,v_{k-1}}`

For Lean formalization, **De Bruijn indices** are the standard choice. The monadic sentence
type in NEquivalence.lean currently lacks:
1. A variable argument to `.atom` (atom `P_i` should be `P_i(x)` where `x` is a variable)
2. Variable positions in `.lt` (order atom `x < y` needs two variable positions)
3. Proper binding in `.forall` (the quantifier binds one variable, shifting indices)

### 5. The Two-Sorted vs. De Bruijn Choice

The literature uses **one-sorted** FO (all individuals are elements of the carrier). So both
variables `x` in `P(x)` and in `x < y` range over the carrier. A natural De Bruijn encoding:

```lean
-- De Bruijn-indexed monadic sentence (n = quantifier depth, free vars = De Bruijn level)
inductive MonadicSentence (sig : MonadicSignature) : Type where
  | atom (p : sig.preds) (i : Nat) : MonadicSentence sig  -- P_i(v_i) where i is De Bruijn index
  | lt (i j : Nat) : MonadicSentence sig                  -- v_i < v_j
  | not (α : MonadicSentence sig) : MonadicSentence sig
  | and (α β : MonadicSentence sig) : MonadicSentence sig
  | forall (α : MonadicSentence sig) : MonadicSentence sig  -- ∀v_k α, where k = current depth
  | exists (α : MonadicSentence sig) : MonadicSentence sig  -- ∃v_k α
```

In De Bruijn convention for sentences: a sentence has no free variables. A formula under `n`
universal/existential quantifiers can reference variables `v_0, ..., v_{n-1}` (those introduced
by the enclosing quantifiers).

The **eval** (also called "satisfies" in the literature) function takes:
- A `MonadicStructure sig` with a `LinearOrder` on the carrier
- An **environment** (assignment of De Bruijn indices to carrier elements)
- A `MonadicSentence sig`
- Returns `Prop`

For sentences (no free variables), the empty environment `[]` suffices.

### 6. The Eval/Satisfies Function Structure

Following the literature exactly (Reynolds 1994 Section 6 / Doets 1989):

```lean
-- Environment: finite list of carrier elements assigning De Bruijn indices
def Env (M : MonadicStructure sig) := List M.carrier

-- Evaluation (recursive, follows sentence structure)
def eval {sig} (M : MonadicStructure sig) [LinearOrder M.carrier]
    (env : Env M) : MonadicSentence sig → Prop
  | .atom p i => env.get? i |>.map (M.interp p) |>.getD False  -- P(v_i) 
  | .lt i j   => match env.get? i, env.get? j with
                  | some a, some b => a < b
                  | _, _ => False
  | .not α    => ¬ eval M env α
  | .and α β  => eval M env α ∧ eval M env β
  | .forall α => ∀ (x : M.carrier), eval M (x :: env) α  -- quantify and prepend
  | .exists α => ∃ (x : M.carrier), eval M (x :: env) α
```

For decidability on **finite** carriers: if `M.carrier` is `Fintype` and the predicates
`M.interp p` are decidable, then `eval M env s` is decidable by structural induction.

### 7. Quantifier Depth Calculation

The existing `quantifier_depth` function is essentially correct but needs updating for
the new constructors:

```lean
def MonadicSentence.quantifier_depth : MonadicSentence sig → Nat
  | .atom _ _ => 0
  | .lt _ _   => 0
  | .not α    => α.quantifier_depth
  | .and α β  => max α.quantifier_depth β.quantifier_depth
  | .forall α => α.quantifier_depth + 1
  | .exists α => α.quantifier_depth + 1
```

### 8. k-Type Definition via Satisfies

With `eval` defined, `k_type_of` becomes:

```lean
-- Sentences of quantifier depth ≤ k over signature sig form a decidable (finite) set
-- The k-type of M is the set of depth-≤k sentences true in M
def k_type_of (sig : MonadicSignature) (k : Nat) (M : MonadicStructure sig)
    [LinearOrder M.carrier] : KType sig k :=
  -- Filter all depth-≤k sentences to those true in M (empty environment = sentence)
  (sentences_of_depth sig k).filter (fun s => eval M [] s)
```

where `sentences_of_depth sig k` enumerates all syntactically distinct sentences of depth ≤ k
over `sig`. This set is finite by Doets 1989 Lemma 1.1.

### 9. ktype_finite Proof Strategy

```
ktype_finite : ∃ (types : Finset (KType sig k)), ∀ (t : KType sig k), t ∈ types
```

The proof: `KType sig k = Finset (MonadicSentence sig)`. We need finitely many k-types.
Since every k-type `t` is a subset of `sentences_of_depth sig k` (a finite set), there are
at most `2^|sentences_of_depth sig k|` k-types. But we need to show this Finset is bounded.

Actually, the existing definition `KType sig k = Finset (MonadicSentence sig)` is slightly
off from optimal. The correct type should be `KType sig k = Finset {s : MonadicSentence sig // s.quantifier_depth ≤ k}`. Then `ktype_finite` follows because `{s : MonadicSentence sig // s.quantifier_depth ≤ k}` is a Fintype (by the finiteness of depth-bounded formulas), and the power set of a Fintype is a Fintype.

The finiteness of `{s : MonadicSentence sig // s.quantifier_depth ≤ k}` follows by induction
on k: for fixed k and finite signature, there are finitely many formulas of depth ≤ k modulo
logical equivalence (Doets 1989, Lemma 1.1). In Lean, the enumeration can be done concretely
by structural recursion on sentence shape and depth bound.

### 10. k_equiv_monotone Proof Strategy

```
k_equiv_monotone : m ≤ k → k_equiv sig k M N → k_equiv sig m M N
```

This is trivial from the definition: if M and N agree on all depth-≤k sentences, they agree on
all depth-≤m sentences (since m ≤ k implies depth-≤m ⊆ depth-≤k). With `k_type_of` properly
defined as a filter on depth-≤k sentences, this becomes: if two filters agree on depth-≤k they
agree on depth-≤m. Formally: `k_type_of sig k M ∩ sentences_of_depth sig m = k_type_of sig m M`.

### 11. KEquivalenceFramework Instance Fields

With proper eval/satisfies:

1. `equiv_is_equiv`: reflexivity (same model satisfies the same sentences), symmetry, transitivity -- all trivial from propositional equality of Finsets.

2. `equiv_monotone`: follows from `k_equiv_monotone` above.

3. `finite_types`: since each k-type is a subset of `sentences_of_depth sig k` (finite), the
   quotient `Quotient (Setoid.mk (k_equiv sig k) ...)` embeds into the powerset of a finite set.
   Thus `Fintype` on the quotient follows from `Fintype` on the powerset.

4. `sum_preservation`: This is Doets 1989 Lemma 1.4. Proof by Ehrenfeucht game (see Doets thesis
   Lemma 1.7, 1.4 / Doets 1989 paper). In Lean: induction on k, using the game characterization.
   For k=0: atomic sentences only -- truth at a point in an ordered sum depends only on the
   component. For k+1: use the back-and-forth condition from Definition 1.2.1.

---

## Recommended Approach

### Primary Approach: Standard FO Satisfaction with De Bruijn Indices

**Follow Reynolds 1994 Section 6 and Doets 1987 Chapter 1 exactly.**

The literature is unambiguous about the variable binding: standard one-sorted FO with individual
variables ranging over the carrier. The natural Lean encoding is De Bruijn indices. There is no
reason to deviate.

#### Step 1: Redesign MonadicSentence

Replace the current `MonadicSentence` with De Bruijn-indexed version:

```lean
inductive MonadicSentence (sig : MonadicSignature) : Type where
  | atom (p : sig.preds) (i : Nat) : MonadicSentence sig
  | lt (i j : Nat) : MonadicSentence sig
  | not (α : MonadicSentence sig) : MonadicSentence sig
  | and (α β : MonadicSentence sig) : MonadicSentence sig
  | or (α β : MonadicSentence sig) : MonadicSentence sig  -- optional but convenient
  | forall (α : MonadicSentence sig) : MonadicSentence sig
  | exists (α : MonadicSentence sig) : MonadicSentence sig
```

- `.atom p i`: predicate `p` applied to variable with De Bruijn index `i`
- `.lt i j`: order relation `v_i < v_j` (uses two variable indices)
- `.forall α`: `∀v. α`, where within `α`, index 0 refers to the quantified variable, and
  existing indices are shifted up by 1. (Standard De Bruijn for lambda-style quantifiers)
- `.exists α`: similarly

**Important**: The De Bruijn convention here follows the standard where quantifier binding
introduces a fresh variable at index 0, and outer variables are at higher indices. Under `n`
quantifiers, variable `v_k` (0 ≤ k < n) is accessible.

#### Step 2: Define Free Variables and Sentence Predicate

```lean
-- Number of free variables needed to evaluate a sentence (determines if it's a sentence)
def MonadicSentence.max_var : MonadicSentence sig → Nat
  | .atom _ i  => i + 1
  | .lt i j    => max i j + 1
  | .not α     => α.max_var
  | .and α β   => max α.max_var β.max_var
  | .or α β    => max α.max_var β.max_var
  | .forall α  => α.max_var - 1  -- or more precisely: (α.max_var - 1).toNat
  | .exists α  => α.max_var - 1

-- A sentence has no free variables
def MonadicSentence.is_sentence : MonadicSentence sig → Prop
  | s => s.max_var = 0
```

For the k-type construction, we only need sentences (closed formulas). The `max_var`
definition requires care for the quantifier cases (De Bruijn shifting).

**Alternative approach for sentence-hood**: Track the "arity" (number of free variables) as
a type index. Use `MonadicFormula sig n` where `n` is the number of free variables:

```lean
inductive MonadicFormula (sig : MonadicSignature) : Nat → Type where
  | atom (p : sig.preds) (i : Fin n) : MonadicFormula sig n
  | lt (i j : Fin n) : MonadicFormula sig n
  | not : MonadicFormula sig n → MonadicFormula sig n
  | and : MonadicFormula sig n → MonadicFormula sig n → MonadicFormula sig n
  | forall : MonadicFormula sig (n+1) → MonadicFormula sig n
  | exists : MonadicFormula sig (n+1) → MonadicFormula sig n

-- Sentences = formulas with 0 free variables
abbrev MonadicSentence (sig : MonadicSignature) := MonadicFormula sig 0
```

This **strongly-typed approach** (Option A in the literature analogy) is cleaner and avoids
partial functions. Variable references use `Fin n` which guarantees they are in-scope. This
is closer to the Lean idiom and avoids the need for the `max_var - 1` hack.

**Recommendation**: Use the strongly-typed `MonadicFormula sig n` approach. It aligns exactly
with Doets' Definition 1.6.1 where `[[a_0,...,a_{k-1}]]^n` has exactly k free variables.

#### Step 3: Define Eval for MonadicFormula

```lean
-- Environment of n carrier elements
def Env (M : MonadicStructure sig) (n : Nat) := Fin n → M.carrier

-- Eval: MonadicFormula sig n → Env M n → Prop
def eval {sig} {n : Nat} (M : MonadicStructure sig) [LinearOrder M.carrier]
    (env : Env M n) : MonadicFormula sig n → Prop
  | .atom p i => M.interp p (env i)
  | .lt i j   => env i < env j
  | .not α    => ¬ eval M env α
  | .and α β  => eval M env α ∧ eval M env β
  | .forall α => ∀ (x : M.carrier), eval M (Fin.cons x env) α
  | .exists α => ∃ (x : M.carrier), eval M (Fin.cons x env) α
```

where `Fin.cons x env : Fin (n+1) → M.carrier` maps 0 to x and i+1 to env i.

This is clean, computable (for decidable predicates on Fintype carriers), and follows Doets
exactly.

#### Step 4: Decidable Eval for Finite Carriers

```lean
instance decEval {sig} {n : Nat} (M : MonadicStructure sig)
    [Fintype M.carrier] [DecidableEq M.carrier] [LinearOrder M.carrier]
    (h_interp_dec : ∀ p x, Decidable (M.interp p x))
    (env : Env M n) (s : MonadicFormula sig n) :
    Decidable (eval M env s) := by
  induction s with
  | atom p i => exact h_interp_dec p (env i)
  | lt i j   => exact inferInstance  -- LinearOrder gives DecidableLt
  | not α ih => exact instDecidableNot
  | and α β ihα ihβ => exact And.decidable
  | forall α ih => exact Fintype.decidableForallFintype
  | exists α ih => exact Fintype.decidableExistsFintype
```

#### Step 5: Define sentences_of_depth for Finiteness

The key mathematical fact (Doets 1989, Lemma 1.1 / thesis 1.7.1): for a finite language and
fixed k, there are finitely many sentences of quantifier depth ≤ k up to logical equivalence.
In Lean we can state this more concretely:

```lean
-- All sentences of depth ≤ k form a Fintype (before quotienting by equivalence)
-- This requires enumerating syntactic sentences, which is not directly finite --
-- but we can work with equivalence classes.
```

In practice, for the purposes of Lean formalization, we use the following observation:

**Finiteness of depth-bounded formulas in k free variables**: by induction on k (depth), the
number of formulas of depth ≤ k in ≤ n free variables over a signature with m predicates is
bounded by a computable function. This gives a `Fintype` on the type of formulas modulo logical
equivalence.

However, the most direct route is to define `k_type_of` without going through an explicit
enumeration:

```lean
-- k_type_of: the set of all sentences of depth ≤ k true in M
-- Represented as a Finset of (representatives of) logical equivalence classes
-- OR: represented directly as the characteristic function on sentences_of_depth sig k
```

For the Lean proof, the cleanest approach is to represent k-types as **the truth vector**:

```lean
-- sentences_bounded_depth sig k : Fintype on MonadicFormula sig 0 of depth ≤ k
-- (This requires showing the type is finite; one way: map into a large enough Fintype)

-- Alternative: just define KType as a function from sentences to Bool
def KType (sig : MonadicSignature) (k : Nat) := 
  {s : MonadicFormula sig 0 // s.quantifier_depth ≤ k} → Bool
```

Then `k_type_of sig k M := fun ⟨s, _⟩ => decide (eval M (Fin.elim0) s)`.

And `ktype_finite` follows from `Fintype.Pi.fintype` (product of finite types).

But we need `Fintype {s : MonadicFormula sig 0 // s.quantifier_depth ≤ k}`. This requires
showing sentences of bounded depth form a finite type. The cleanest Lean proof:

By induction on k:
- k=0: sentences of depth 0 = propositional combinations of quantifier-free atoms. But monadic
  FO has no ground atoms (atoms need variables), so depth-0 sentences are just `⊤` and `⊥`.
  More precisely, depth-0 sentences are exactly those NOT containing any quantifier; since all
  atoms require variables, the only depth-0 sentences are propositional tautologies. Actually,
  depth-0 means quantifier depth = 0, which means no quantifiers. But since all atomic formulas
  (`.atom p i` and `.lt i j`) need free variables i,j, the depth-0 SENTENCES (0 free variables)
  are exactly {`⊤`, `⊥`} (or equivalently, ∅ and the full set). So `Fintype` holds for k=0.
- k+1: `∀x φ` and `∃x φ` where `φ` has depth ≤ k in one more free variable. By IH,
  there are finitely many depth-≤k formulas in 1 free variable. So depth-≤(k+1) sentences
  are generated from finitely many options.

This inductive argument can be done in Lean though it requires some work.

#### Step 6: Prove ktype_finite

With the above representation, `ktype_finite` is:

```lean
theorem ktype_finite (sig : MonadicSignature) (k : Nat) :
    ∃ (types : Finset (KType sig k)), ∀ (t : KType sig k), t ∈ types := by
  -- KType sig k = ({s : MonadicFormula sig 0 // s.quantifier_depth ≤ k} → Bool)
  -- This is a function type between two Fintypes, hence Fintype
  -- Fintype.ofFinset (Finset.univ) (fun _ => Finset.mem_univ _)
  exact ⟨Finset.univ, fun _ => Finset.mem_univ _⟩
```

This works provided `KType sig k` has a `Fintype` instance, which follows from the finiteness
of the domain (sentences of bounded depth = Fintype) and the finiteness of Bool.

#### Step 7: Prove k_equiv_monotone

```lean
theorem k_equiv_monotone (sig : MonadicSignature) {k m : Nat} {M N : MonadicStructure sig}
    [LinearOrder M.carrier] [LinearOrder N.carrier]
    (hkm : m ≤ k) (h_equiv : k_equiv sig k M N) : k_equiv sig m M N := by
  -- k_equiv sig k M N means: for all depth-≤k sentences s, eval M [] s ↔ eval N [] s
  -- k_equiv sig m M N means: for all depth-≤m sentences s, eval M [] s ↔ eval N [] s
  -- Since m ≤ k, depth-≤m ⊆ depth-≤k, so the conclusion follows from h_equiv
  intro s hs
  exact h_equiv s (Nat.le_trans hs hkm)
```

#### Step 8: Prove sum_preservation (Doets Lemma 1.4)

This is the most substantial proof. The key is Doets 1989 Lemma 1.4 / thesis Lemma 1.7:

> If for all i ∈ I, m(i) ≡^n m'(i), then Σ_{i∈I} m(i) ≡^n Σ_{i∈I} m'(i).

**Proof strategy** (Ehrenfeucht game, as in Doets thesis 1.3):

By induction on k. 

Base case (k=0): Depth-0 sentences over the monadic language in the ordered sum reduce to
truth of atomic sentences at particular positions. An atomic sentence `∃x P(x)` (depth 1,
not 0) cannot be present. Depth-0 sentences have no quantifiers. In the ordered sum, truth
of a depth-0 closed formula only involves the overall structure's propositional structure,
which is determined component-wise.

Actually, for the monadic language, depth-0 sentences (no quantifiers) over the monadic
signature are just `⊤` and `⊥` since all atomic formulas require free variables. So the base
case is trivial (both ⊤ and ⊥ are agreed upon by both sums).

Inductive step (k+1): A depth-(k+1) sentence is of the form `∀x φ` or `∃x φ` where `φ` has
depth ≤ k in one free variable. Truth of `∃x φ` in the ordered sum means: some component
m(i) contains an element x satisfying `φ`. If m(i) ≡^k m'(i), then m'(i) also contains
an element x' satisfying `φ`. So `∃x φ` holds in the primed sum as well.

This is the core of the Ehrenfeucht game proof. In Lean, this can be done by induction
on the sentence structure with an explicit lemma:

```lean
-- Core lemma: truth of depth-≤k formulas in ordered sum reduces to component-wise truth
lemma ordered_sum_eval_iff (sig : MonadicSignature) (I : Type) (m : I → MonadicStructure sig)
    [∀ i, LinearOrder (m i).carrier]
    (s : MonadicFormula sig 0) (k : Nat) (hs : s.quantifier_depth ≤ k)
    (i : I) (env : Fin 0 → (OrderedSum sig I m).carrier) :
    eval (OrderedSum sig I m) env s ↔ 
      ∃ i, eval (m i) (fun j => (env j).2) s := ...
```

This is a non-trivial structural induction. It requires handling the environment carefully
across components.

**Simpler approach**: Lean's `decide` tactic is not available for infinite carriers. But for
the proof of `sum_preservation`, we can appeal to the EF game theorem directly (as Doets does)
or use the semantic definition.

**Most pragmatic approach for Lean formalization**: For `sum_preservation`, if the carrier
type is `Fintype`, the proof proceeds by `decide` or `Fintype.decidableForallFintype`. For
the infinite case (full ℤ), we need the Ehrenfeucht game argument or a direct structural
induction. This is substantial but follows a known blueprint.

For the initial implementation, we can give a careful induction-based proof for finite index
sets `I = Fin n` (which is all that's needed for Reynolds Theorem 15). The full generalization
to arbitrary `I` can come later.

---

## Literature Proof Structure

**Source**: Reynolds 1994 (Axiomatizing U and S over Integer Time), Theorem 15
**Strategy**: Show chronicle ≡_k Z-interval by:
1. Define contemporaneous equivalence ~_M
2. Show ~_M has one equivalence class (via discrete gap elimination)
3. Conclude the whole structure is very good
4. Apply Lemma 16 (very good countable → good)

**The sorry chain** runs:
- `k_type_of` (needs `eval M [] s` to be defined) -- closes with FO satisfaction
- `ktype_finite` (needs finitely many k-types) -- closes with Fintype on bounded-depth sentences
- `k_equiv_monotone` (depth monotonicity) -- closes trivially once `k_type_of` is semantic
- `KEquivalenceFramework.finite_types` -- closes from `ktype_finite`
- `KEquivalenceFramework.sum_preservation` -- closes from Doets Lemma 1.4
- `finite_structures_good` -- closes from `k_equiv` being semantic

The non-trivial closed sorries are:
1. `eval` definition (straightforward)
2. `sentences_of_depth` being `Fintype` (structural induction, moderate effort)
3. `sum_preservation` / Doets Lemma 1.4 (Ehrenfeucht game, substantial but follows literature)

**Downstream consumers** that will be unblocked:
- `finite_structures_good` in IntegerModel.lean (currently uses `trivial` vacuously)
- `very_good_implies_good` in IntegerModel.lean (currently uses `trivial` vacuously)
- `contemp_equiv_is_equiv.trans` in IntegerModel.lean (currently uses `trivial` vacuously)
- `no_gaps_discrete` (currently uses `exfalso` + `trivial`)
- `doets_lemma_1_4` in OrderedSum.lean (currently uses `simp [k_equiv, k_type_of]` vacuously)
- `table` and `table_depth_bound` in Table.lean (needs eval to define standard translation)

---

## Evidence/Examples

### Evidence that De Bruijn + Fin n is correct

From Doets 1987 thesis, Definition 1.6.1 (Scott-sentences):

> For A = (A, ...), a = (a_0, ..., a_{k-1}) ∈ A^k and α an ordinal, define [[a]]^α
> (the α-characteristic of a in A) as follows:
> 1. [[a]]^0 is the conjunction of all atomic or negated atomic formulas in v_0,...,v_{k-1}
>    satisfied by a in A
> 2. [[a]]^{α+1} = ∧_{a ∈ A} ∃v_k [[aa]]^α ∧ ∀v_k ∨_{a ∈ A} [[aa]]^α

This confirms: variables are explicitly indexed (v_0, ..., v_{k-1}), and quantification
introduces the next index v_k. The natural Lean representation is `MonadicFormula sig n`
where `n` = number of free variables, and `∀` (or `∃`) reduces n by 1 (binds v_{n-1}).

Using `Fin n` for variable indices exactly captures "variables v_0,...,v_{n-1}" with
static type-checking that all references are in scope.

### Evidence from Reynolds 1994 for the table structure

Reynolds 1994, p. 122, gives the explicit table for U:

```
C_{U(A,B)}(t) = ∃s > t (C_A(s) ∧ ∀u(t < u ∧ u < s → C_B(u)))
```

This is a formula in one free variable `t`. The `∃s` binds s (De Bruijn 0 inside), and the
outer `t` is De Bruijn 0 at the top level (or 1 inside the `∃s`). This confirms the one-free-
variable structure and validates the `MonadicFormula sig 1` type for tables.

For `table` in Table.lean:

```lean
def table (sig : MonadicSignature) (φ : Formula) : MonadicFormula sig 1 := ...
```

(Note: 1 free variable `t`, not 0, since the table is a formula to be evaluated at a point.)

Then `satisfies` becomes: `eval M (fun _ => t) (table sig φ)` where `t : M.carrier`.

---

## Confidence Level: HIGH

The literature (Doets 1987, Doets 1989, Reynolds 1994) is completely explicit about:
1. The syntax of monadic FO sentences (standard FO with unary predicates + order)
2. The semantics (Tarski-style eval with environments)
3. The finiteness of k-types (Lemma 1.1 in Doets)
4. The sum preservation property (Lemma 1.4 in Doets)
5. The k-equivalence definition (same depth-≤k sentences)

The De Bruijn / `Fin n` encoding is the standard Lean idiom for exactly this kind of variable-
binding setup. The strongly-typed `MonadicFormula sig n` approach avoids partial functions and
matches the mathematical definition precisely.

The main technical challenge is the proof of `sum_preservation` (Doets Lemma 1.4), which
requires either:
(a) A direct structural induction on the sentence (following the Ehrenfeucht game proof), or
(b) An appeal to a more abstract characterization.

Both are feasible. Option (a) is more work but is fully elementary. Option (b) may require
encoding the game in Lean which is additional infrastructure.

**Recommendation**: Start with option (a) for `sum_preservation`, using structural induction
on the depth k. The base case (k=0) is trivial (depth-0 sentences are just ⊤/⊥). The inductive
step for ∃ and ∀ follows from the component-wise property. This avoids any game-theoretic
encoding.

---

## Downstream Impact Assessment

The following files need refactoring if `MonadicSentence` is redesigned:

1. `NEquivalence.lean`: Replace current `MonadicSentence` with `MonadicFormula sig n`. Update
   `k_type_of`, `k_equiv`, `KEquivalenceFramework` instance. Add `eval`, `satisfies` definitions.

2. `Table.lean`: Update `table` signature from `MonadicSentence sig` to `MonadicFormula sig 1`
   (one free variable). Implement the actual recursive translation.

3. `OrderedSum.lean`: Update `doets_lemma_1_4` proof to use semantic `k_equiv`. The definition
   is already structurally correct; only the proof body changes.

4. `IntegerModel.lean`: Update `finite_structures_good`, `very_good_implies_good`,
   `contemp_equiv_is_equiv.trans` to use semantic proofs. These currently use `trivial` vacuously.

5. `Transfer.lean`: The pipeline is currently bypassed. Once steps 1-4 are done, the
   `doets_countermodel_discrete` theorem can be completed.

The impact is **significant but contained**: all changes are in the WeakCanonical directory.
The ReynoldsCompleteness pipeline (Transfer.lean → Completeness.lean) can be completed once
these are closed.

---

*Report by Teammate A (Primary Approach)*
*Focus: Literature-guided FO satisfaction implementation*
