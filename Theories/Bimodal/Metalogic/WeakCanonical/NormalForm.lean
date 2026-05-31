import Bimodal.Metalogic.WeakCanonical.MonadicFO

/-!
# Normal Form Theory for Monadic FO over Linear Orders

Inductive normal form type and the bridge theorem for Doets 1989 Lemma 1.1.
The core definitions (`atomCount`, `nfCount`, `NormalFormIdx`,
`MonadicSignature`, `MonadicFormula`, `eval`, etc.) live in `MonadicFO.lean`.
This file provides:

- `AtomKind`: concrete enumeration of atomic propositions (predicate and order)
- `atom_eval`: semantic evaluation of atoms in an ordered monadic structure
- `NormalForm`: recursive type mirroring Doets' n-characteristics (Def 1.6.1)
- `nf_eval_nf`: concrete structural evaluation of normal forms
- `nf_exists_unique`: each (M, env) satisfies exactly one normal form
- `nf_agreement_monotone`: normal form agreement is monotone in quantifier depth
- `doets_lemma_1_1`: the bridge theorem
- `atomKind_card`: `Fintype.card (AtomKind sig n) = atomCount p n`
- `normalForm_card`: `Fintype.card (NormalForm sig k n) = nfCount p k n`
- `normalForm_equiv_fin`: `NormalForm sig k n ≃ NormalFormIdx sig k n`

## Mathematical Background

For monadic FO over linear orders with p unary predicates:
- At depth 0 with n free variables, atomic propositions are:
  - `P_i(x_j)` for each predicate i and variable j: contributes p * n atoms
  - `x_i < x_j` for each ordered pair of distinct variables: contributes n * (n - 1) atoms
  - Total: `atomCount p n = p * n + n * (n - 1)`
- A depth-0 normal form is a truth assignment to these atoms.
- At depth k+1, a normal form extends the atom assignment with a specification
  of which depth-k normal forms (with one extra variable) are existentially realized.

The cardinality theorems establish that `Fintype.card (NormalForm sig k n) = nfCount p k n`,
confirming the counting function in `MonadicFO.lean` correctly enumerates normal forms.
The equivalence `normalForm_equiv_fin` provides the bijection between the inductive
`NormalForm` type and the Fin-based `NormalFormIdx` type.

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

/-! ## Existence and Uniqueness of Characteristic Normal Form -/

/--
The characteristic normal form of a structure M under environment env at depth k.
This is the unique normal form that M,env satisfies.
-/
noncomputable def nf_characteristic {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    (k : Nat) → (n : Nat) → (env : Fin n → M.carrier) → NormalForm sig k n
  | 0, _, env => fun a => @decide (atom_eval M env a) (Classical.dec _)
  | k + 1, _, env =>
    (fun a => @decide (atom_eval M env a) (Classical.dec _),
     fun nf => @decide (∃ x, nf_eval_nf M k (_ + 1) (Fin.cons x env) nf) (Classical.dec _))

/-- The characteristic normal form satisfies nf_eval_nf. -/
theorem nf_characteristic_satisfies {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k n : Nat)
    (env : Fin n → M.carrier) :
    nf_eval_nf M k n env (nf_characteristic M k n env) := by
  induction k generalizing n env with
  | zero =>
    -- Goal: ∀ a, atom_eval M env a ↔ (nf_characteristic M 0 n env a = true)
    simp only [nf_characteristic, nf_eval_nf]
    intro a
    simp [decide_eq_true_eq]
  | succ k ih =>
    -- Goal: atoms match AND quantifier assignment matches
    simp only [nf_characteristic, nf_eval_nf]
    constructor
    · -- Atom assignment matches
      intro a; simp [decide_eq_true_eq]
    · -- Quantifier assignment matches
      intro sub_nf
      simp [decide_eq_true_eq]

/-- If two normal forms are both satisfied, they are equal. -/
theorem nf_eval_unique {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k n : Nat)
    (env : Fin n → M.carrier)
    (nf1 nf2 : NormalForm sig k n)
    (h1 : nf_eval_nf M k n env nf1)
    (h2 : nf_eval_nf M k n env nf2) : nf1 = nf2 := by
  induction k generalizing n env with
  | zero =>
    have h1' : ∀ a, atom_eval M env a ↔ (nf1 a = true) := h1
    have h2' : ∀ a, atom_eval M env a ↔ (nf2 a = true) := h2
    funext a
    have := (h1' a).symm.trans (h2' a)
    cases ha : nf1 a <;> cases hb : nf2 a <;> simp_all
  | succ k ih =>
    obtain ⟨h1a, h1q⟩ := h1; obtain ⟨h2a, h2q⟩ := h2
    have ha : nf1.1 = nf2.1 := by
      funext a
      have := (h1a a).symm.trans (h2a a)
      cases ha : nf1.1 a <;> cases hb : nf2.1 a <;> simp_all
    have hq : nf1.2 = nf2.2 := by
      funext sub_nf
      have := (h1q sub_nf).symm.trans (h2q sub_nf)
      cases ha : nf1.2 sub_nf <;> cases hb : nf2.2 sub_nf <;> simp_all
    exact Prod.ext ha hq

/--
**nf_exists_unique**: For every structure M, environment env, and depth k,
there exists exactly one normal form that M,env satisfies.

This is the key lemma needed by the quantifier cases of the bridge theorem
(doets_lemma_1_1).
-/
theorem nf_exists_unique {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k n : Nat)
    (env : Fin n → M.carrier) :
    ∃! (nf : NormalForm sig k n), nf_eval_nf M k n env nf :=
  ⟨nf_characteristic M k n env,
   nf_characteristic_satisfies M k n env,
   fun nf h => nf_eval_unique M k n env nf (nf_characteristic M k n env) h
     (nf_characteristic_satisfies M k n env)⟩

/--
If two (M, env) and (N, env') pairs satisfy the same normal form nf,
then they agree on all normal forms at that depth.
Corollary of nf_exists_unique: each pair satisfies exactly one NF.
-/
theorem nf_agreement_from_shared_nf {sig : MonadicSignature}
    {k n : Nat}
    (M : OrderedMonadicStructure sig) (env_M : Fin n → M.carrier)
    (N : OrderedMonadicStructure sig) (env_N : Fin n → N.carrier)
    (nf : NormalForm sig k n)
    (hM : nf_eval_nf M k n env_M nf)
    (hN : nf_eval_nf N k n env_N nf)
    (nf' : NormalForm sig k n) :
    nf_eval_nf M k n env_M nf' ↔ nf_eval_nf N k n env_N nf' := by
  constructor
  · intro hM'
    have : nf' = nf := nf_eval_unique M k n env_M nf' nf hM' hM
    subst this; exact hN
  · intro hN'
    have : nf' = nf := nf_eval_unique N k n env_N nf' nf hN' hN
    subst this; exact hM

/-! ## Doets Lemma 1.1: Bridge Theorem -/

/--
Helper: extract atom agreement from depth-k normal form agreement.
If M,env_M and N,env_N agree on all depth-k normal forms, they agree
on all atomic propositions.
-/
theorem atom_agreement_from_nf {sig : MonadicSignature} {k n : Nat}
    (M : OrderedMonadicStructure sig) (env_M : Fin n → M.carrier)
    (N : OrderedMonadicStructure sig) (env_N : Fin n → N.carrier)
    (h_same_nf : ∀ nf : NormalForm sig k n,
      nf_eval_nf M k n env_M nf ↔ nf_eval_nf N k n env_N nf)
    (a : AtomKind sig n) :
    atom_eval M env_M a ↔ atom_eval N env_N a := by
  obtain ⟨nf_M, hM, _⟩ := nf_exists_unique M k n env_M
  have hN := (h_same_nf nf_M).mp hM
  match k with
  | 0 => exact (hM a).trans (hN a).symm
  | k + 1 => exact (hM.1 a).trans (hN.1 a).symm

/-! ## Normal Form Agreement Monotonicity -/

/--
If M and N agree on all depth-k normal forms (k ≥ m), they agree on all
depth-m normal forms. Proved by induction on m.

Key insight for the quantifier step: if ∃x with nf_eval_nf M m (n+1)
(Fin.cons x env_M) sub_nf, then x has a unique depth-(k-1) NF by
nf_exists_unique. The depth-k agreement transfers this to N. The IH
then shows the depth-m agreement for the Fin.cons environments.
-/
theorem nf_agreement_monotone {sig : MonadicSignature} :
    ∀ (m k n : Nat) (hkm : m ≤ k)
    (M : OrderedMonadicStructure sig) (env_M : Fin n → M.carrier)
    (N : OrderedMonadicStructure sig) (env_N : Fin n → N.carrier)
    (h_agree_k : ∀ nf : NormalForm sig k n,
      nf_eval_nf M k n env_M nf ↔ nf_eval_nf N k n env_N nf)
    (nf_m : NormalForm sig m n),
    nf_eval_nf M m n env_M nf_m ↔ nf_eval_nf N m n env_N nf_m := by
  intro m
  induction m with
  | zero =>
    intro k n hkm M env_M N env_N h_agree_k nf_m
    -- nf_m : AtomKind sig n → Bool
    -- Need: (∀ a, atom_eval M env_M a ↔ nf_m a = true) ↔ (∀ a, atom_eval N env_N a ↔ nf_m a = true)
    constructor
    · intro hM a
      exact (atom_agreement_from_nf M env_M N env_N h_agree_k a).symm.trans (hM a)
    · intro hN a
      exact (atom_agreement_from_nf M env_M N env_N h_agree_k a).trans (hN a)
  | succ m ih =>
    intro k n hkm M env_M N env_N h_agree_k nf_m
    -- Need depth-(k) NF agreement to imply depth-(m+1) NF agreement.
    -- We have k ≥ m + 1, so k = (m + 1) + d for some d.
    -- Strategy: show the characteristic depth-(m+1) NFs for M and N are the same.
    obtain ⟨char_M, hcM, _⟩ := nf_exists_unique M (m + 1) n env_M
    obtain ⟨char_N, hcN, _⟩ := nf_exists_unique N (m + 1) n env_N
    -- Show char_M = char_N by proving N satisfies char_M
    suffices h_transfer : nf_eval_nf N (m + 1) n env_N char_M by
      have heq : char_M = char_N := nf_eval_unique N (m + 1) n env_N char_M char_N h_transfer hcN
      constructor
      · intro hM
        have := nf_eval_unique M (m + 1) n env_M nf_m char_M hM hcM
        subst this; exact h_transfer
      · intro hN
        have := nf_eval_unique N (m + 1) n env_N nf_m char_N hN hcN
        rw [← heq] at this; subst this; exact hcM
    -- Prove nf_eval_nf N (m+1) n env_N char_M
    obtain ⟨hcM_atoms, hcM_quant⟩ := hcM
    constructor
    · -- Atoms agree
      intro a
      exact (atom_agreement_from_nf M env_M N env_N h_agree_k a).symm.trans (hcM_atoms a)
    · -- Quantifier assignments agree
      intro sub_nf
      rw [← hcM_quant sub_nf]
      -- Need: (∃ y, nf_eval_nf N m (n+1) ... sub_nf) ↔ (∃ x, nf_eval_nf M m (n+1) ... sub_nf)
      -- Use depth-k NF agreement: k ≥ m + 1, so k - 1 ≥ m.
      -- Get depth-k NF agreement, extract quant part to get depth-(k-1) transfer.
      obtain ⟨nf_M_k, hM_k_sat, _⟩ := nf_exists_unique M k n env_M
      have hN_k_sat := (h_agree_k nf_M_k).mp hM_k_sat
      -- At depth k ≥ 1, extract quantifier transfer
      match k, hkm with
      | k' + 1, hkm' =>
        obtain ⟨_, hM_k_quant⟩ := hM_k_sat
        obtain ⟨_, hN_k_quant⟩ := hN_k_sat
        -- hM_k_quant: ∀ nf_k, (∃ x, nf_eval_nf M k' (n+1) ... nf_k) ↔ (nf_M_k.2 nf_k = true)
        -- hN_k_quant: ∀ nf_k, (∃ y, nf_eval_nf N k' (n+1) ... nf_k) ↔ (nf_M_k.2 nf_k = true)
        have hex_transfer_k : ∀ nf_k : NormalForm sig k' (n + 1),
            (∃ x, nf_eval_nf M k' (n + 1) (Fin.cons x env_M) nf_k) ↔
            (∃ y, nf_eval_nf N k' (n + 1) (Fin.cons y env_N) nf_k) :=
          fun nf_k => (hM_k_quant nf_k).trans (hN_k_quant nf_k).symm
        -- Now transfer at depth m using IH + depth-k' transfer
        -- After rw: goal is (∃ y, nf_eval_nf N ...) ↔ (∃ x, nf_eval_nf M ...)
        constructor
        · -- N → M: given y : N.carrier with depth-m, find x : M.carrier
          rintro ⟨y, hNy_m⟩
          obtain ⟨nf_y_k, hNy_k, _⟩ := nf_exists_unique N k' (n + 1) (Fin.cons y env_N)
          obtain ⟨x, hMx_k⟩ := (hex_transfer_k nf_y_k).mpr ⟨y, hNy_k⟩
          have h_agree_k' := nf_agreement_from_shared_nf M (Fin.cons x env_M)
            N (Fin.cons y env_N) nf_y_k hMx_k hNy_k
          have h_agree_m := ih k' (n + 1) (by omega) M (Fin.cons x env_M)
            N (Fin.cons y env_N) h_agree_k'
          exact ⟨x, (h_agree_m sub_nf).mpr hNy_m⟩
        · -- M → N: given x : M.carrier with depth-m, find y : N.carrier
          rintro ⟨x, hMx_m⟩
          obtain ⟨nf_x_k, hMx_k, _⟩ := nf_exists_unique M k' (n + 1) (Fin.cons x env_M)
          obtain ⟨y, hNy_k⟩ := (hex_transfer_k nf_x_k).mp ⟨x, hMx_k⟩
          have h_agree_k' := nf_agreement_from_shared_nf M (Fin.cons x env_M)
            N (Fin.cons y env_N) nf_x_k hMx_k hNy_k
          have h_agree_m := ih k' (n + 1) (by omega) M (Fin.cons x env_M)
            N (Fin.cons y env_N) h_agree_k'
          exact ⟨y, (h_agree_m sub_nf).mp hMx_m⟩

/--
**Doets 1989, Lemma 1.1** (Bridge Theorem):
Every monadic formula of quantifier depth at most `k` has its truth value
determined by which normal form at depth `k` is satisfied.

Formally: if two structures M and N with environments env_M and env_N
satisfy the same `NormalForm sig k n` at depth k, then they agree on
the truth of every formula of depth <= k.

Proof by two-level induction: outer on k, inner structural on phi.
-/
theorem doets_lemma_1_1 {sig : MonadicSignature} (k : Nat) :
    ∀ (n : Nat) (phi : MonadicFormula sig n) (_h_depth : phi.quantifier_depth ≤ k)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin n → M.carrier) (env_N : Fin n → N.carrier)
    (h_same_nf : ∀ nf : NormalForm sig k n,
      nf_eval_nf M k n env_M nf ↔ nf_eval_nf N k n env_N nf),
    (eval M env_M phi ↔ eval N env_N phi) := by
  induction k with
  | zero =>
    -- Base case: k = 0, phi has depth 0 (quantifier-free)
    intro n phi h_depth M N env_M env_N h_same_nf
    induction phi with
    | atom p i =>
      -- eval M env_M (.atom p i) = M.interp p (env_M i)
      -- This is atom_eval M env_M (AtomKind.pred p i)
      exact atom_agreement_from_nf M env_M N env_N h_same_nf (.pred p i)
    | lt i j =>
      -- eval M env_M (.lt i j) = (env_M i < env_M j)
      -- This is atom_eval M env_M (AtomKind.order i j h) when i ≠ j
      -- When i = j, both sides are false (irreflexivity of <)
      simp only [eval]
      by_cases hij : i = j
      · subst hij; simp [lt_irrefl]
      · exact atom_agreement_from_nf M env_M N env_N h_same_nf (.order i j hij)
    | not α ih =>
      simp only [eval]
      have h_depth_alpha : α.quantifier_depth ≤ 0 := by
        simp [MonadicFormula.quantifier_depth] at h_depth; omega
      exact (ih h_depth_alpha env_M env_N h_same_nf).not
    | and α β ihα ihβ =>
      simp only [eval]
      have h_depth_alpha : α.quantifier_depth ≤ 0 := by
        simp [MonadicFormula.quantifier_depth] at h_depth; omega
      have h_depth_beta : β.quantifier_depth ≤ 0 := by
        simp [MonadicFormula.quantifier_depth] at h_depth; omega
      exact (ihα h_depth_alpha env_M env_N h_same_nf).and
        (ihβ h_depth_beta env_M env_N h_same_nf)
    | all α ih =>
      -- Impossible: depth(.all α) = α.depth + 1 ≥ 1 > 0
      simp [MonadicFormula.quantifier_depth] at h_depth
    | ex α ih =>
      simp [MonadicFormula.quantifier_depth] at h_depth
  | succ k outer_ih =>
    -- Inductive step: k+1
    intro n phi h_depth M N env_M env_N h_same_nf
    induction phi with
    | atom p i =>
      exact atom_agreement_from_nf M env_M N env_N h_same_nf (.pred p i)
    | lt i j =>
      simp only [eval]
      by_cases hij : i = j
      · subst hij; simp [lt_irrefl]
      · exact atom_agreement_from_nf M env_M N env_N h_same_nf (.order i j hij)
    | not α ih =>
      simp only [eval]
      have h_alpha : α.quantifier_depth ≤ k + 1 := by
        simp [MonadicFormula.quantifier_depth] at h_depth; exact h_depth
      exact (ih h_alpha env_M env_N h_same_nf).not
    | and α β ihα ihβ =>
      simp only [eval]
      have h_alpha : α.quantifier_depth ≤ k + 1 := by
        simp [MonadicFormula.quantifier_depth] at h_depth; omega
      have h_beta : β.quantifier_depth ≤ k + 1 := by
        simp [MonadicFormula.quantifier_depth] at h_depth; omega
      exact (ihα h_alpha env_M env_N h_same_nf).and
        (ihβ h_beta env_M env_N h_same_nf)
    | @all n' α ih =>
      simp only [eval]
      have h_alpha : α.quantifier_depth ≤ k := by
        simp [MonadicFormula.quantifier_depth] at h_depth; omega
      obtain ⟨nf_M, hM_sat, _⟩ := nf_exists_unique M (k + 1) n' env_M
      obtain ⟨hM_atoms, hM_quant⟩ := hM_sat
      have hN_sat := (h_same_nf nf_M).mp ⟨hM_atoms, hM_quant⟩
      obtain ⟨hN_atoms, hN_quant⟩ := hN_sat
      -- Key: existential realization is shared between M and N
      have hex_transfer : ∀ sub_nf : NormalForm sig k (n' + 1),
          (∃ x, nf_eval_nf M k (n' + 1) (Fin.cons x env_M) sub_nf) ↔
          (∃ y, nf_eval_nf N k (n' + 1) (Fin.cons y env_N) sub_nf) :=
        fun sub_nf => (hM_quant sub_nf).trans (hN_quant sub_nf).symm
      constructor
      · intro hM_all y
        obtain ⟨nf_y, hNy, _⟩ := nf_exists_unique N k (n' + 1) (Fin.cons y env_N)
        obtain ⟨x, hMx⟩ := (hex_transfer nf_y).mpr ⟨y, hNy⟩
        have h_agree := nf_agreement_from_shared_nf M (Fin.cons x env_M)
          N (Fin.cons y env_N) nf_y hMx hNy
        exact (outer_ih (n' + 1) α h_alpha M N
          (Fin.cons x env_M) (Fin.cons y env_N) h_agree).mp (hM_all x)
      · intro hN_all x
        obtain ⟨nf_x, hMx, _⟩ := nf_exists_unique M k (n' + 1) (Fin.cons x env_M)
        obtain ⟨y, hNy⟩ := (hex_transfer nf_x).mp ⟨x, hMx⟩
        have h_agree := nf_agreement_from_shared_nf M (Fin.cons x env_M)
          N (Fin.cons y env_N) nf_x hMx hNy
        exact (outer_ih (n' + 1) α h_alpha M N
          (Fin.cons x env_M) (Fin.cons y env_N) h_agree).mpr (hN_all y)
    | @ex n' α ih =>
      simp only [eval]
      have h_alpha : α.quantifier_depth ≤ k := by
        simp [MonadicFormula.quantifier_depth] at h_depth; omega
      obtain ⟨nf_M, hM_sat, _⟩ := nf_exists_unique M (k + 1) n' env_M
      obtain ⟨hM_atoms, hM_quant⟩ := hM_sat
      have hN_sat := (h_same_nf nf_M).mp ⟨hM_atoms, hM_quant⟩
      obtain ⟨hN_atoms, hN_quant⟩ := hN_sat
      have hex_transfer : ∀ sub_nf : NormalForm sig k (n' + 1),
          (∃ x, nf_eval_nf M k (n' + 1) (Fin.cons x env_M) sub_nf) ↔
          (∃ y, nf_eval_nf N k (n' + 1) (Fin.cons y env_N) sub_nf) :=
        fun sub_nf => (hM_quant sub_nf).trans (hN_quant sub_nf).symm
      constructor
      · rintro ⟨x, hMx_eval⟩
        obtain ⟨nf_x, hMx, _⟩ := nf_exists_unique M k (n' + 1) (Fin.cons x env_M)
        obtain ⟨y, hNy⟩ := (hex_transfer nf_x).mp ⟨x, hMx⟩
        have h_agree := nf_agreement_from_shared_nf M (Fin.cons x env_M)
          N (Fin.cons y env_N) nf_x hMx hNy
        exact ⟨y, (outer_ih (n' + 1) α h_alpha M N
          (Fin.cons x env_M) (Fin.cons y env_N) h_agree).mp hMx_eval⟩
      · rintro ⟨y, hNy_eval⟩
        obtain ⟨nf_y, hNy, _⟩ := nf_exists_unique N k (n' + 1) (Fin.cons y env_N)
        obtain ⟨x, hMx⟩ := (hex_transfer nf_y).mpr ⟨y, hNy⟩
        have h_agree := nf_agreement_from_shared_nf M (Fin.cons x env_M)
          N (Fin.cons y env_N) nf_y hMx hNy
        exact ⟨x, (outer_ih (n' + 1) α h_alpha M N
          (Fin.cons x env_M) (Fin.cons y env_N) h_agree).mpr hNy_eval⟩

/-! ## Cardinality Correspondences -/

/--
The number of `AtomKind sig n` values equals `atomCount (Fintype.card sig.preds) n`.
This confirms the counting function in `MonadicFO.lean` correctly enumerates the
atomic propositions available with `n` free variables.
-/
theorem atomKind_card (sig : MonadicSignature) (n : Nat) :
    Fintype.card (AtomKind sig n) = atomCount (Fintype.card sig.preds) n := by
  rw [show Fintype.card (AtomKind sig n) =
    Fintype.card (sig.preds × Fin n ⊕ {p : Fin n × Fin n // p.1 ≠ p.2}) from by
    exact Fintype.card_congr {
      toFun := fun x => match x with
        | .pred p i => .inl ⟨p, i⟩
        | .order i j h => .inr ⟨⟨i, j⟩, h⟩
      invFun := fun x => match x with
        | .inl ⟨p, i⟩ => AtomKind.pred p i
        | .inr ⟨⟨i, j⟩, h⟩ => AtomKind.order i j h
      left_inv := by intro x; cases x with | pred _ _ => rfl | order _ _ _ => rfl
      right_inv := by intro x; cases x with
        | inl p => cases p; rfl
        | inr p => cases p; rename_i v hv; cases v; rfl
    }]
  rw [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
  rw [Fintype.card_subtype]
  have h1 : (Finset.univ.filter (fun x : Fin n × Fin n => x.1 ≠ x.2)) =
    (Finset.univ : Finset (Fin n)).offDiag := by
    ext ⟨a, b⟩; simp [Finset.mem_offDiag, Finset.mem_filter]
  rw [h1, Finset.offDiag_card, Finset.card_univ, Fintype.card_fin]
  simp [atomCount]
  cases n with
  | zero => simp
  | succ m => simp [Nat.succ_mul, Nat.mul_succ]

/--
The number of `NormalForm sig k n` values equals `nfCount (Fintype.card sig.preds) k n`.
This confirms the counting function in `MonadicFO.lean` correctly enumerates
the Doets normal forms at each quantifier depth.
-/
theorem normalForm_card (sig : MonadicSignature) (k n : Nat) :
    Fintype.card (NormalForm sig k n) = nfCount (Fintype.card sig.preds) k n := by
  induction k generalizing n with
  | zero =>
    simp only [NormalForm, nfCount]
    rw [Fintype.card_fun, Fintype.card_bool, atomKind_card]
  | succ k ih =>
    simp only [NormalForm, nfCount]
    rw [Fintype.card_prod, Fintype.card_fun, Fintype.card_bool,
        Fintype.card_fun, Fintype.card_bool, atomKind_card, ih]
    rw [Nat.pow_add]

/--
The inductive `NormalForm sig k n` type is equivalent to the Fin-based
`NormalFormIdx sig k n` (i.e., `Fin (nfCount p k n)`), establishing the
bijection between the two representations.
-/
noncomputable def normalForm_equiv_fin (sig : MonadicSignature) (k n : Nat) :
    NormalForm sig k n ≃ NormalFormIdx sig k n :=
  Fintype.equivFinOfCardEq (normalForm_card sig k n)

/-! ## Normal Form to MonadicFormula Conversion

Convert a `NormalForm sig k n` into a `MonadicFormula sig n` whose evaluation
under `eval` matches `nf_eval_nf`. This bridges the normal form world (used
in `contemp_equiv`, `good`, `very_good`) to the syntactic formula world
(used in `US_expressively_complete_over_prior`).
-/

/-- Convert an `AtomKind` to the corresponding `MonadicFormula`. -/
def atom_to_formula {sig : MonadicSignature} {n : Nat} :
    AtomKind sig n → MonadicFormula sig n
  | .pred p i => .atom p i
  | .order i j _ => .lt i j

/-- `atom_to_formula` correctly captures `atom_eval`. -/
theorem eval_atom_to_formula {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (a : AtomKind sig n) :
    eval M env (atom_to_formula a) ↔ atom_eval M env a := by
  cases a with
  | pred p i => simp [atom_to_formula, eval, atom_eval]
  | order i j h => simp [atom_to_formula, eval, atom_eval]

/-- Formula that is always true (for any number of free variables).
    Defined as ∀ x, ¬(x < x), which holds in any linear order. -/
def MonadicFormula.trueFormula {sig : MonadicSignature} {n : Nat} :
    MonadicFormula sig n :=
  .all (.not (.lt ⟨0, by omega⟩ ⟨0, by omega⟩))

@[simp]
theorem eval_trueFormula {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier) :
    eval M env MonadicFormula.trueFormula ↔ True := by
  simp only [MonadicFormula.trueFormula, eval, lt_irrefl, not_false_eq_true,
    implies_true, iff_true]

/-- Finite conjunction of a list of formulas. -/
def MonadicFormula.listConj {sig : MonadicSignature} {n : Nat} :
    List (MonadicFormula sig n) → MonadicFormula sig n
  | [] => MonadicFormula.trueFormula
  | [φ] => φ
  | φ :: rest => .and φ (listConj rest)

theorem eval_listConj {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (fs : List (MonadicFormula sig n)) :
    eval M env (MonadicFormula.listConj fs) ↔ ∀ φ ∈ fs, eval M env φ := by
  induction fs with
  | nil => simp [MonadicFormula.listConj, eval_trueFormula]
  | cons φ rest ih =>
    cases rest with
    | nil =>
      simp only [MonadicFormula.listConj, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h _ heq => heq ▸ h, fun h => h φ rfl⟩
    | cons ψ rest' =>
      simp only [MonadicFormula.listConj, eval]
      constructor
      · intro ⟨hφ, hrest⟩ θ hθ
        rw [List.mem_cons] at hθ
        rcases hθ with rfl | hθ'
        · exact hφ
        · exact (ih.mp hrest) θ hθ'
      · intro h
        exact ⟨h φ (List.mem_cons.mpr (Or.inl rfl)),
               ih.mpr (fun θ hθ => h θ (List.mem_cons.mpr (Or.inr hθ)))⟩

/-- Check a single atom condition for a Bool assignment. -/
def atom_cond_formula {sig : MonadicSignature} {n : Nat}
    (assignment : AtomKind sig n → Bool) (a : AtomKind sig n) :
    MonadicFormula sig n :=
  if assignment a then atom_to_formula a else .not (atom_to_formula a)

theorem eval_atom_cond {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (assignment : AtomKind sig n → Bool) (a : AtomKind sig n) :
    eval M env (atom_cond_formula assignment a) ↔
    (atom_eval M env a ↔ (assignment a = true)) := by
  unfold atom_cond_formula
  cases h : assignment a <;> simp [eval, eval_atom_to_formula]

/-- Check a single quantifier condition. -/
noncomputable def quant_cond_formula {sig : MonadicSignature} {k n : Nat}
    (nf_to_formula_fn : NormalForm sig k (n + 1) → MonadicFormula sig (n + 1))
    (quant_assgn : NormalForm sig k (n + 1) → Bool)
    (sub_nf : NormalForm sig k (n + 1)) : MonadicFormula sig n :=
  if quant_assgn sub_nf then .ex (nf_to_formula_fn sub_nf)
  else .not (.ex (nf_to_formula_fn sub_nf))

/-- Convert a `NormalForm sig k n` to a `MonadicFormula sig n`.
    The resulting formula has quantifier depth at most `k`. -/
noncomputable def nf_to_formula {sig : MonadicSignature} :
    {k : Nat} → {n : Nat} → NormalForm sig k n → MonadicFormula sig n
  | 0, _, assignment =>
    -- Depth 0: conjunction of atom checks
    MonadicFormula.listConj
      (Finset.univ.toList.map (atom_cond_formula assignment))
  | _ + 1, _, ⟨atom_assgn, quant_assgn⟩ =>
    -- Depth k+1: atom checks AND quantifier checks
    MonadicFormula.listConj
      (Finset.univ.toList.map (atom_cond_formula atom_assgn) ++
       Finset.univ.toList.map (quant_cond_formula nf_to_formula quant_assgn))

/-- `nf_to_formula` correctly captures `nf_eval_nf`:
    evaluating the formula matches the normal form evaluation. -/
theorem nf_to_formula_correct {sig : MonadicSignature} {k n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (nf : NormalForm sig k n) :
    eval M env (nf_to_formula nf) ↔ nf_eval_nf M k n env nf := by
  induction k generalizing n env with
  | zero =>
    -- nf : AtomKind sig n → Bool
    -- nf_eval_nf = ∀ a, atom_eval M env a ↔ (nf a = true)
    simp only [nf_to_formula, nf_eval_nf]
    rw [eval_listConj]
    constructor
    · intro h_all a
      have h_in_list : atom_cond_formula nf a ∈
          Finset.univ.toList.map (atom_cond_formula nf) :=
        List.mem_map_of_mem (Finset.mem_toList.mpr (Finset.mem_univ a))
      exact (eval_atom_cond M env nf a).mp (h_all _ h_in_list)
    · intro h_all φ hφ
      simp only [List.mem_map] at hφ
      obtain ⟨a, _, rfl⟩ := hφ
      exact (eval_atom_cond M env nf a).mpr (h_all a)
  | succ k ih =>
    -- nf : (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)
    show eval M env (MonadicFormula.listConj
      (Finset.univ.toList.map (atom_cond_formula nf.1) ++
       Finset.univ.toList.map (quant_cond_formula nf_to_formula nf.2))) ↔ _
    rw [eval_listConj]
    have atom_mem : ∀ a : AtomKind sig n,
        atom_cond_formula nf.1 a ∈
        (Finset.univ.toList.map (atom_cond_formula nf.1) ++
         Finset.univ.toList.map (quant_cond_formula nf_to_formula nf.2)) :=
      fun a => List.mem_append_left _
        (List.mem_map_of_mem (Finset.mem_toList.mpr (Finset.mem_univ a)))
    have quant_mem : ∀ sub_nf : NormalForm sig k (n + 1),
        quant_cond_formula nf_to_formula nf.2 sub_nf ∈
        (Finset.univ.toList.map (atom_cond_formula nf.1) ++
         Finset.univ.toList.map (quant_cond_formula nf_to_formula nf.2)) :=
      fun sub_nf => List.mem_append_right _
        (List.mem_map_of_mem (Finset.mem_toList.mpr (Finset.mem_univ sub_nf)))
    constructor
    · intro h_all
      refine ⟨fun a => ?_, fun sub_nf => ?_⟩
      · -- Atom part
        exact (eval_atom_cond M env nf.1 a).mp (h_all _ (atom_mem a))
      · -- Quantifier part
        have h := h_all _ (quant_mem sub_nf)
        unfold quant_cond_formula at h
        split at h
        · rename_i h_eq
          simp only [eval] at h
          obtain ⟨x, hx⟩ := h
          constructor
          · intro _; exact h_eq
          · intro _; exact ⟨x, (ih (Fin.cons x env) sub_nf).mp hx⟩
        · rename_i h_ne
          simp only [eval, not_exists] at h
          constructor
          · intro ⟨x, hx⟩
            exact absurd ((ih (Fin.cons x env) sub_nf).mpr hx) (h x)
          · intro h_eq; exact absurd h_eq h_ne
    · intro ⟨h_atoms, h_quant⟩ φ hφ
      simp only [List.mem_append, List.mem_map] at hφ
      rcases hφ with ⟨a, _, rfl⟩ | ⟨sub_nf, _, rfl⟩
      · exact (eval_atom_cond M env nf.1 a).mpr (h_atoms a)
      · unfold quant_cond_formula
        have hq := h_quant sub_nf
        split
        · rename_i h_eq
          simp only [eval]
          obtain ⟨x, hx⟩ := hq.mpr h_eq
          exact ⟨x, (ih (Fin.cons x env) sub_nf).mpr hx⟩
        · rename_i h_ne
          simp only [eval, not_exists]
          intro x hx
          exact absurd (hq.mp ⟨x, (ih (Fin.cons x env) sub_nf).mp hx⟩) h_ne

/-- Finite disjunction of a list of formulas. -/
def MonadicFormula.listDisj {sig : MonadicSignature} {n : Nat} :
    List (MonadicFormula sig n) → MonadicFormula sig n
  | [] => .not MonadicFormula.trueFormula  -- False
  | [φ] => φ
  | φ :: rest => MonadicFormula.or φ (listDisj rest)

theorem eval_listDisj {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (fs : List (MonadicFormula sig n)) :
    eval M env (MonadicFormula.listDisj fs) ↔ ∃ φ ∈ fs, eval M env φ := by
  induction fs with
  | nil =>
    simp only [MonadicFormula.listDisj, eval, eval_trueFormula, not_true, List.not_mem_nil,
      false_and, exists_false]
  | cons φ rest ih =>
    cases rest with
    | nil =>
      simp only [MonadicFormula.listDisj, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h => ⟨φ, rfl, h⟩, fun ⟨_, heq, h⟩ => heq ▸ h⟩
    | cons ψ rest' =>
      simp only [MonadicFormula.listDisj]
      rw [eval_or]
      constructor
      · intro h
        rcases h with hφ | hrest
        · exact ⟨φ, List.mem_cons.mpr (Or.inl rfl), hφ⟩
        · obtain ⟨θ, hθ_mem, hθ_eval⟩ := ih.mp hrest
          exact ⟨θ, List.mem_cons.mpr (Or.inr hθ_mem), hθ_eval⟩
      · intro ⟨θ, hθ_mem, hθ_eval⟩
        rw [List.mem_cons] at hθ_mem
        rcases hθ_mem with rfl | hθ_rest
        · exact Or.inl hθ_eval
        · exact Or.inr (ih.mpr ⟨θ, hθ_rest, hθ_eval⟩)

/-- Specialization: for sentences (n=0), nf_to_formula produces a MonadicSentence. -/
noncomputable def nf_to_sentence {sig : MonadicSignature} {k : Nat}
    (nf : NormalForm sig k 0) : MonadicSentence sig :=
  nf_to_formula nf

theorem nf_to_sentence_correct {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    (nf : NormalForm sig k 0) :
    eval M Fin.elim0 (nf_to_sentence nf) ↔ nf_eval_nf M k 0 Fin.elim0 nf :=
  nf_to_formula_correct M Fin.elim0 nf

end Bimodal.Metalogic.WeakCanonical
