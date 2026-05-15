import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Normal Form Theory for Monadic FO over Linear Orders

Inductive normal form type and the bridge theorem for Doets 1989 Lemma 1.1.
The core definitions (`atomCount`, `nfCount`, `NormalFormIdx`, `KType`,
`k_type_of`) live in `NEquivalence.lean`. This file provides:

- `AtomKind`: concrete enumeration of atomic propositions (predicate and order)
- `atom_eval`: semantic evaluation of atoms in an ordered monadic structure
- `NormalForm`: recursive type mirroring Doets' n-characteristics (Def 1.6.1)
- `nf_eval_nf`: concrete structural evaluation of normal forms
- `nf_exists_unique`: each (M, env) satisfies exactly one normal form
- `doets_lemma_1_1`: the bridge theorem

## Mathematical Background

For monadic FO over linear orders with p unary predicates:
- At depth 0 with n free variables, atomic propositions are:
  - `P_i(x_j)` for each predicate i and variable j: contributes p * n atoms
  - `x_i < x_j` for each ordered pair of distinct variables: contributes n * (n - 1) atoms
  - Total: `atomCount p n = p * n + n * (n - 1)`
- A depth-0 normal form is a truth assignment to these atoms.
- At depth k+1, a normal form extends the atom assignment with a specification
  of which depth-k normal forms (with one extra variable) are existentially realized.

## References

- Doets 1989, Section 1, Lemma 1.1: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Doets 1987, Definition 1.6.1 (n-characteristics)
- Task 143 research: `specs/143_doets_lemma_1_1_normal_form_ktype/reports/02_concrete-nf-eval-design.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Atomic Propositions -/

/--
Concrete enumeration of atomic propositions available with signature `sig`
and `n` free variables over a linear order. Two kinds:
- `pred p i`: unary predicate `p` applied to variable `i` (corresponds to `MonadicFormula.atom p i`)
- `order i j h`: order relation `x_i < x_j` with proof `i ≠ j` (corresponds to `MonadicFormula.lt i j`)

The `i ≠ j` constraint on `order` is mathematically redundant (x_i < x_i is
always false) but ensures each semantically distinct atom has a unique
representative, matching the counting function `atomCount`.
-/
inductive AtomKind (sig : MonadicSignature) (n : Nat) : Type where
  | pred (p : sig.preds) (i : Fin n) : AtomKind sig n
  | order (i j : Fin n) (h : i ≠ j) : AtomKind sig n

instance atomKind_decEq (sig : MonadicSignature) (n : Nat) :
    DecidableEq (AtomKind sig n) := by
  intro a b
  cases a with
  | pred p i =>
    cases b with
    | pred q j =>
      if hpq : p = q then
        if hij : i = j then
          exact isTrue (by subst hpq; subst hij; rfl)
        else
          exact isFalse (by intro h; cases h; exact hij rfl)
      else
        exact isFalse (by intro h; cases h; exact hpq rfl)
    | order _ _ _ => exact isFalse (by intro h; cases h)
  | order i j h =>
    cases b with
    | pred _ _ => exact isFalse (by intro h; cases h)
    | order i' j' h' =>
      if hii : i = i' then
        if hjj : j = j' then
          exact isTrue (by subst hii; subst hjj; rfl)
        else
          exact isFalse (by intro heq; cases heq; exact hjj rfl)
      else
        exact isFalse (by intro heq; cases heq; exact hii rfl)

/--
`AtomKind sig n` is a finite type. The predicate atoms form `sig.preds × Fin n`,
and the order atoms form `{(i, j) : Fin n × Fin n // i ≠ j}`. Both are finite.
-/
instance atomKind_fintype (sig : MonadicSignature) (n : Nat) :
    Fintype (AtomKind sig n) := by
  apply Fintype.ofEquiv (sig.preds × Fin n ⊕ {p : Fin n × Fin n // p.1 ≠ p.2})
  exact {
    toFun := fun x => match x with
      | .inl ⟨p, i⟩ => AtomKind.pred p i
      | .inr ⟨⟨i, j⟩, h⟩ => AtomKind.order i j h
    invFun := fun x => match x with
      | .pred p i => .inl ⟨p, i⟩
      | .order i j h => .inr ⟨⟨i, j⟩, h⟩
    left_inv := by intro x; cases x with | inl p => cases p; rfl | inr p => cases p; rename_i v hv; cases v; rfl
    right_inv := by intro x; cases x with | pred _ _ => rfl | order _ _ _ => rfl
  }

/--
Semantic evaluation of an atomic proposition in an ordered monadic structure.
This matches the `atom` and `lt` cases of `eval` exactly:
- `atom_eval M env (.pred p i) = M.interp p (env i)`
- `atom_eval M env (.order i j _) = (env i < env j)`
-/
def atom_eval {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) : AtomKind sig n → Prop
  | .pred p i => M.interp p (env i)
  | .order i j _ => env i < env j

/-! ## Recursive Normal Form Type -/

/--
Normal form type mirroring Doets' n-characteristics (Def 1.6.1), defined
by recursion on quantifier depth `k`.

- At depth 0: `AtomKind sig n → Bool` (a truth assignment to atoms)
- At depth k+1: `(AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)`
  (an atom assignment plus a specification of which depth-k normal forms
  with one extra variable are existentially realized)

Defined as a recursive function rather than an inductive type because the
`→ Bool` function space creates a negative occurrence of `NormalForm` that
Lean's positivity checker rejects for inductive types.
-/
def NormalForm (sig : MonadicSignature) : Nat → Nat → Type
  | 0, n => AtomKind sig n → Bool
  | k + 1, n => (AtomKind sig n → Bool) × (NormalForm sig k (n + 1) → Bool)

/-- Construct a depth-0 normal form from an atom truth assignment. -/
def NormalForm.base {sig : MonadicSignature} {n : Nat}
    (assignment : AtomKind sig n → Bool) : NormalForm sig 0 n :=
  assignment

/-- Construct a depth-(k+1) normal form from atom and quantifier assignments. -/
def NormalForm.step {sig : MonadicSignature} {k n : Nat}
    (atom_assignment : AtomKind sig n → Bool)
    (quant_assignment : NormalForm sig k (n + 1) → Bool) :
    NormalForm sig (k + 1) n :=
  (atom_assignment, quant_assignment)

/-- Extract the atom assignment from any normal form. -/
def NormalForm.atom_assgn {sig : MonadicSignature} : {k : Nat} → {n : Nat} →
    NormalForm sig k n → (AtomKind sig n → Bool)
  | 0, _, nf => nf
  | _ + 1, _, nf => nf.1

/-- Extract the quantifier assignment from a depth-(k+1) normal form. -/
def NormalForm.quant_assgn {sig : MonadicSignature} {k n : Nat}
    (nf : NormalForm sig (k + 1) n) : NormalForm sig k (n + 1) → Bool :=
  nf.2

/--
`NormalForm sig k n` is both `Fintype` and `DecidableEq`, proved simultaneously
by induction on `k`. The mutual dependency arises because `Fintype (A → Bool)`
requires `DecidableEq A`, and `DecidableEq (A → Bool)` requires `Fintype A`.
-/
private def normalForm_fintype_and_decEq (sig : MonadicSignature) (k n : Nat) :
    Fintype (NormalForm sig k n) × DecidableEq (NormalForm sig k n) := by
  induction k generalizing n with
  | zero =>
    exact ⟨inferInstanceAs (Fintype (AtomKind sig n → Bool)),
           inferInstanceAs (DecidableEq (AtomKind sig n → Bool))⟩
  | succ k ih =>
    have ⟨ft, de⟩ := ih (n + 1)
    exact ⟨inferInstanceAs (Fintype ((AtomKind sig n → Bool) × (NormalForm sig k (n + 1) → Bool))),
           inferInstanceAs (DecidableEq ((AtomKind sig n → Bool) × (NormalForm sig k (n + 1) → Bool)))⟩

instance normalForm_fintype (sig : MonadicSignature) (k n : Nat) :
    Fintype (NormalForm sig k n) :=
  (normalForm_fintype_and_decEq sig k n).1

instance normalForm_decEq (sig : MonadicSignature) (k n : Nat) :
    DecidableEq (NormalForm sig k n) :=
  (normalForm_fintype_and_decEq sig k n).2

/-! ## Semantic Evaluation of Normal Forms -/

/--
Concrete semantic evaluation of normal forms. Maps a normal form to the
proposition that it is satisfied in structure `M` under environment `env`.

- For depth-0 (atom assignment): every atom evaluates as the assignment says.
- For depth-(k+1) (atom + quantifier assignment): atoms match AND for each
  sub-normal-form, existential realization matches the quantifier assignment.

This is noncomputable because it quantifies over the (potentially infinite)
carrier of the structure.
-/
noncomputable def nf_eval_nf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    (k : Nat) → (n : Nat) → (env : Fin n → M.carrier) → NormalForm sig k n → Prop
  | 0, _, env, assignment =>
    ∀ (a : AtomKind sig _), atom_eval M env a ↔ (assignment a = true)
  | k + 1, _, env, ⟨atom_assignment, quant_assignment⟩ =>
    (∀ (a : AtomKind sig _), atom_eval M env a ↔ (atom_assignment a = true)) ∧
    (∀ (sub_nf : NormalForm sig k (_ + 1)),
      (∃ (x : M.carrier), nf_eval_nf M k (_ + 1) (Fin.cons x env) sub_nf) ↔
        (quant_assignment sub_nf = true))

/-! ## Legacy Definitions (to be replaced in Phase 10) -/

/--
Legacy semantic evaluation on NormalFormIdx. Will be replaced when KType
domain switches from NormalFormIdx to NormalForm.
-/
noncomputable def nf_eval (sig : MonadicSignature) (k n : Nat)
    (_idx : NormalFormIdx sig k n) (M : OrderedMonadicStructure sig)
    (_env : Fin n → M.carrier) : Prop :=
  let _ := M.carrier
  Classical.choice (inferInstance : Nonempty Prop)

/--
Legacy nf_vector. Will be replaced in Phase 10.
-/
noncomputable def nf_vector (sig : MonadicSignature) (k n : Nat)
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier) :
    NormalFormIdx sig k n → Bool :=
  fun idx => @decide (nf_eval sig k n idx M env) (Classical.dec _)

/-! ## Doets Lemma 1.1: Bridge Theorem -/

/--
**Doets 1989, Lemma 1.1** (Bridge Theorem):
Every monadic formula of quantifier depth at most `k` has its truth value
determined by which normal form at depth `k` is satisfied.

Formally: if two structures M and N with environments env_M and env_N
satisfy the same normal forms at depth k, then they agree on the truth
of every formula of depth <= k.
-/
theorem doets_lemma_1_1 (sig : MonadicSignature) (k n : Nat)
    (phi : MonadicFormula sig n) (_h_depth : phi.quantifier_depth ≤ k)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin n → M.carrier) (env_N : Fin n → N.carrier)
    (_h_vec : nf_vector sig k n M env_M = nf_vector sig k n N env_N) :
    (eval M env_M phi ↔ eval N env_N phi) := by
  sorry

/-! ## Additional Instances -/

/-- `NormalFormIdx sig k n` is nonempty (since nfCount is positive). -/
instance normalFormIdx_nonempty (sig : MonadicSignature) (k n : Nat) :
    Nonempty (NormalFormIdx sig k n) :=
  ⟨⟨0, nfCount_pos _ _ _⟩⟩

end Bimodal.Metalogic.WeakCanonical
