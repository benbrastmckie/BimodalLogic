# k-Equivalence Definitions and Properties

Research report on the exact definitions and key properties of `k_equiv`, `k_type_of`, and related machinery in the ProofChecker codebase.

## 1. Core Definitions

### MonadicSignature

```lean
-- MonadicFO.lean:41
structure MonadicSignature where
  preds : Type
  [fintypePreds : Fintype preds]
  [decEqPreds : DecidableEq preds]
```

### OrderedMonadicStructure

```lean
-- MonadicFO.lean:103
structure OrderedMonadicStructure (sig : MonadicSignature) extends MonadicStructure sig where
  carrier_order : LinearOrder carrier
```

Where `MonadicStructure` has `carrier : Type` and `interp (p : sig.preds) : carrier -> Prop`.

### AtomKind

```lean
-- NormalForm.lean:58
inductive AtomKind (sig : MonadicSignature) (n : Nat) : Type where
  | pred (p : sig.preds) (i : Fin n) : AtomKind sig n
  | order (i j : Fin n) (h : i != j) : AtomKind sig n
```

The semantic evaluation:
```lean
def atom_eval (M : OrderedMonadicStructure sig) (env : Fin n -> M.carrier) : AtomKind sig n -> Prop
  | .pred p i => M.interp p (env i)
  | .order i j _ => env i < env j
```

### NormalForm

```lean
-- NormalForm.lean:134
def NormalForm (sig : MonadicSignature) : Nat -> Nat -> Type
  | 0, n => AtomKind sig n -> Bool
  | k + 1, n => (AtomKind sig n -> Bool) x (NormalForm sig k (n + 1) -> Bool)
```

- At depth 0 with n free vars: a truth assignment to atomic propositions
- At depth k+1 with n free vars: atom assignment PLUS specification of which depth-k NFs (with n+1 vars) are existentially realized

### nf_eval_nf (Semantic Evaluation of Normal Forms)

```lean
-- NormalForm.lean:198
noncomputable def nf_eval_nf (M : OrderedMonadicStructure sig) :
    (k : Nat) -> (n : Nat) -> (env : Fin n -> M.carrier) -> NormalForm sig k n -> Prop
  | 0, _, env, assignment =>
    forall (a : AtomKind sig _), atom_eval M env a <-> (assignment a = true)
  | k + 1, _, env, (atom_assignment, quant_assignment) =>
    (forall (a : AtomKind sig _), atom_eval M env a <-> (atom_assignment a = true)) /\
    (forall (sub_nf : NormalForm sig k (_ + 1)),
      (exists (x : M.carrier), nf_eval_nf M k (_ + 1) (Fin.cons x env) sub_nf) <->
        (quant_assignment sub_nf = true))
```

### KType

```lean
-- NEquivalence.lean:53
abbrev KType (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 0 -> Bool
```

A k-type is a truth-assignment function on depth-k sentence normal forms.

### k_type_of

```lean
-- NEquivalence.lean:64
noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun nf => @decide (nf_eval_nf M k 0 Fin.elim0 nf) (Classical.dec _)
```

For each sentence-level normal form (0 free vars), records whether M satisfies it.

### k_equiv

```lean
-- NEquivalence.lean:72
def k_equiv (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) : Prop :=
  k_type_of sig k M = k_type_of sig k N
```

**k-equivalence is exactly equality of k-types**: M and N satisfy the same set of sentence-level normal forms at depth k.

## 2. Key Properties (Proved)

### k_equiv_monotone

```lean
-- NEquivalence.lean:91
theorem k_equiv_monotone (sig : MonadicSignature) {k m : Nat}
    {M N : OrderedMonadicStructure sig}
    (hkm : m <= k) (h_equiv : k_equiv sig k M N) : k_equiv sig m M N
```

If M ~k N and m <= k, then M ~m N. Proved via `nf_agreement_monotone`.

### k_equiv is an equivalence relation

Proved in the `KEquivalenceFramework` instance:
- `refl`: `rfl` (k-type equality is reflexive)
- `symm`: `.symm`
- `trans`: `.trans`

### Finite k-types

```lean
-- NEquivalence.lean:1127
finite_types k : Fintype (Quotient (Setoid from k_equiv))
```

There are finitely many k-equivalence classes. Proved via injection into `KType sig k` which is `NormalForm sig k 0 -> Bool`, a Fintype.

### Sum preservation (doets_lemma_1_4)

```lean
-- OrderedSum.lean:34 / NEquivalence.lean:1052
theorem doets_lemma_1_4 (sig : MonadicSignature) (k : Nat) (I : Type) [LinearOrder I]
    (m m' : I -> OrderedMonadicStructure sig)
    (h_equiv : forall i, k_equiv sig k (m i) (m' i)) :
    k_equiv sig k (orderedSum sig I m) (orderedSum sig I m')
```

**SORRY-FREE**. If components are pairwise k-equivalent, ordered sums are k-equivalent. The proof is complete and delegates through `sum_preservation_proof -> sum_nf_agree_sentence`.

### k_equiv_of_iso

```lean
-- IntegerModel.lean:98
theorem k_equiv_of_iso (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) (f : M.carrier ≃o N.carrier)
    (h_pred : forall (p : sig.preds) (x : M.carrier), M.interp p x <-> N.interp p (f x)) :
    k_equiv sig k M N
```

Order-isomorphic, predicate-preserving structures are k-equivalent at all depths.

### doets_lemma_1_1 (Bridge Theorem)

```lean
-- NormalForm.lean:433
theorem doets_lemma_1_1 {sig : MonadicSignature} (k : Nat) :
    forall (n : Nat) (phi : MonadicFormula sig n) (_h_depth : phi.quantifier_depth <= k)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin n -> M.carrier) (env_N : Fin n -> N.carrier)
    (h_same_nf : forall nf : NormalForm sig k n,
      nf_eval_nf M k n env_M nf <-> nf_eval_nf N k n env_N nf),
    (eval M env_M phi <-> eval N env_N phi)
```

**SORRY-FREE**. If two structures agree on all depth-k normal forms, they agree on every formula of quantifier depth <= k.

## 3. k-equiv and Expressibility

### Does k_equiv preserve all sentences of depth <= k?

**YES**, via the chain:

1. `k_equiv sig k M N` means `k_type_of sig k M = k_type_of sig k N`
2. This means for ALL `nf : NormalForm sig k 0`, `nf_eval_nf M k 0 Fin.elim0 nf <-> nf_eval_nf N k 0 Fin.elim0 nf`
3. By `doets_lemma_1_1`: for any sentence `phi` with `phi.quantifier_depth <= k`, `eval M Fin.elim0 phi <-> eval N Fin.elim0 phi`

There is no explicit single lemma "k_equiv_preserves_sentence" in the codebase, but the composition is trivial:

```lean
-- Derivable (not explicitly stated):
theorem k_equiv_preserves_sentence (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) (phi : MonadicSentence sig)
    (h_depth : phi.quantifier_depth <= k) (h_equiv : k_equiv sig k M N) :
    eval M Fin.elim0 phi <-> eval N Fin.elim0 phi := by
  apply doets_lemma_1_1 k 0 phi h_depth
  intro nf
  have h_pt := congr_fun h_equiv nf  -- h_equiv : k_type_of sig k M = k_type_of sig k N
  simp only [k_type_of, decide_eq_decide] at h_pt
  exact h_pt
```

### Key implication for "good"

`good sig k M` means `exists Z, k_equiv sig k M (Z.toOrdered sig)`. This means M agrees with some Z-interval structure on all monadic FO sentences of quantifier depth <= k.

## 4. ZIntervalStructure

```lean
-- IntegerModel.lean:43
structure ZIntervalStructure (sig : MonadicSignature) where
  lo : Option Z       -- none = unbounded below
  hi : Option Z       -- none = unbounded above
  interp (p : sig.preds) : Z -> Prop
```

```lean
-- IntegerModel.lean:52
def ZIntervalStructure.intervalCarrier (Z : ZIntervalStructure sig) : Type :=
  {z : Z // Z.lo.elim True (. <= z) /\ Z.hi.elim True (z <= .)}
```

```lean
-- IntegerModel.lean:69
def ZIntervalStructure.toOrdered (sig : MonadicSignature) (Z : ZIntervalStructure sig) :
    OrderedMonadicStructure sig where
  carrier := Z.intervalCarrier
  interp p x := Z.interp p x.val
  carrier_order := inferInstance  -- Subtype.instLinearOrder
```

## 5. orderedSum

```lean
-- NEquivalence.lean:122
noncomputable def orderedSum (sig : MonadicSignature) (I : Type) [LinearOrder I]
    (ms : I -> OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := Sigma fun i => (ms i).carrier
  interp := fun p x => (ms x.1).interp p x.2
  carrier_order := Sigma.Lex.linearOrder  -- lexicographic order
```

The carrier of `orderedSum sig I ms` is `Sigma (fun i => (ms i).carrier)` with lexicographic order: elements from different components ordered by index; same component ordered internally.

## 6. Nonempty and k_equiv

**k_equiv does NOT guarantee Nonempty**. Looking at the definitions:

- `k_equiv sig k M N` is purely about equality of k-types (functions `NormalForm sig k 0 -> Bool`).
- An empty structure and a nonempty structure CAN have different k-types at depth k >= 1, because at depth 1, the quantifier assignment records whether `exists x, ...` -- which is always `false` for empty structures but may be `true` for nonempty ones.
- However, at depth 0, `AtomKind sig 0` is empty (no variables available), so ALL structures (including empty ones) trivially have the same 0-type. Thus `k_equiv sig 0 M N` for ALL M, N.

**Conclusion**: Nonemptiness is preserved by k_equiv at k >= 1 (because "exists x, True" is expressible at depth 1), but nonemptiness is a separate concern at k = 0.

## 7. Remaining Sorries

### OrderedSum.lean:56 -- `doets_lemma_1_5`

The "type-matching" variant: if two ordered sums over DIFFERENT index sets have matching k-type distributions, they are k-equivalent. **Not on critical path** -- bypassed by one_class argument in discrete case.

### IntegerModel.lean:470 -- `good_of_split_at_succ` for k >= 1

The case: given two Z-intervals Z1, Z2 that are k-equivalent to M|[t,b] and M|[succ b, u] respectively, prove their ordered sum is k-equivalent to a SINGLE Z-interval (i.e., the ordered sum of two Z-intervals is "good").

**Strategy outlined in comments**: At k >= 1, k-equiv preserves "has max" and "has min" (expressible at depth 1). Since M|[t,b] has a maximum element (b), Z1 must be bounded above. Since M|[succ b, u] has a minimum element (succ b), Z2 must be bounded below. With both bounded on the touching side, shift-and-glue produces a single Z-interval that is order-isomorphic to their ordered sum.

**What's needed**: A helper lemma showing that k-equiv at k >= 1 with a structure that has a max element implies the Z-interval also has a max element (i.e., Z1.hi = some _). This is the "expressibility preservation" lemma mentioned in the comment.

## 8. Summary for Task 155

For proving that an ordered sum of two Z-interval structures is "good" at depth k >= 1:

1. `doets_lemma_1_4` (sum preservation) is **complete** -- no sorry.
2. `k_equiv_of_iso` gives k-equiv from order isomorphisms.
3. The missing piece is: proving that bounded Z-intervals' ordered sum is itself isomorphic to a single Z-interval. This requires showing that k-equiv at k >= 1 preserves the "has maximum" / "has minimum" properties, which is expressible as a sentence of quantifier depth 1.
4. A concrete lemma like `orderedSum_of_bounded_Zintervals_is_Zinterval` (purely order-theoretic: concatenation of two bounded Z-intervals is a Z-interval) would close the sorry.
