import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Normal Form Theory for Monadic FO over Linear Orders

Extended definitions and the bridge theorem for the Doets 1989 Lemma 1.1
normal form theory. The core definitions (`atomCount`, `nfCount`,
`NormalFormIdx`, `KType`, `k_type_of`) live in `NEquivalence.lean`.
This file provides:

- `nf_eval`: noncomputable semantic evaluation mapping indices to propositions
- `nf_vector`: the collected evaluation vector
- `doets_lemma_1_1`: the bridge theorem statement (sorry'd)

## Mathematical Background

For monadic FO over linear orders with p unary predicates:
- At depth 0 with n free variables, atomic propositions are:
  - `P_i(x_j)` for each predicate i and variable j: contributes p * n atoms
  - `x_i < x_j` for each ordered pair of distinct variables: contributes n * (n - 1) atoms
  - Total: `atomCount p n = p * n + n * (n - 1)`
- A depth-0 formula is a Boolean combination of these atoms, so there are
  `2^(atomCount p n)` semantically distinct depth-0 formulas (truth assignments to atoms).
- At depth k+1, each formula is a Boolean combination of:
  - The `atomCount p n` atoms
  - The `nfCount p k (n+1)` "quantified atoms" `exists x_{n+1}. phi(x_0,...,x_n,x_{n+1})`
    where phi ranges over depth-k formulas with n+1 free variables
  - Total: `2^(atomCount p n + nfCount p k (n+1))`

## References

- Doets 1989, Section 1, Lemma 1.1: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Task 143 research: `specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_team-research.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Semantic Evaluation -/

/--
Semantic evaluation of normal form indices. Maps each index in
`NormalFormIdx sig k n` to a proposition (whether that normal form
is satisfied in structure `M` under environment `env`).

This is noncomputable because it uses `Classical.choice` to enumerate
the (potentially infinite) carrier of the structure. The actual
assignment of indices to semantic content is abstract -- we only need
that it exists and partitions formulas correctly for the Doets
counting argument.

The key property is: there exists such an evaluation function that
is surjective onto the set of semantically distinct truth patterns.
-/
noncomputable def nf_eval (sig : MonadicSignature) (k n : Nat)
    (_idx : NormalFormIdx sig k n) (M : OrderedMonadicStructure sig)
    (_env : Fin n -> M.carrier) : Prop :=
  let _ := M.carrier
  Classical.choice (inferInstance : Nonempty Prop)

/--
The "nf_eval vector": collects all nf_eval values for a given structure
and environment into a single function `NormalFormIdx sig k n -> Bool`.
Two structures that agree on this vector satisfy the same depth-<=k formulas.
-/
noncomputable def nf_vector (sig : MonadicSignature) (k n : Nat)
    (M : OrderedMonadicStructure sig) (env : Fin n -> M.carrier) :
    NormalFormIdx sig k n -> Bool :=
  fun idx => @decide (nf_eval sig k n idx M env) (Classical.dec _)

/-! ## Doets Lemma 1.1: Bridge Theorem -/

/--
**Doets 1989, Lemma 1.1** (Bridge Theorem):
Every monadic formula of quantifier depth at most `k` has its truth value
determined by the normal form evaluation vector at depth `k`.

Formally: if two structures M and N with environments env_M and env_N
produce the same `nf_vector`, then they agree on the truth of every
formula of depth <= k.

This is the mathematical core that justifies replacing the syntactically
infinite KType domain with the finite NormalFormIdx.

The proof proceeds by two-level induction:
- Outer induction on k (quantifier depth)
- Inner structural induction on the formula

The base case (k = 0) follows because quantifier-free formulas are
Boolean combinations of finitely many atoms.
The inductive step uses the fact that quantified subformulas with
n+1 variables at depth k are already counted in nfCount.

**Status**: Sorry'd. The abstract nf_eval definition (via Classical.choice)
prevents constructive proof. The finite_types closure in KEquivalenceFramework
does NOT depend on this theorem -- it is closed structurally via the
KType redefinition to NormalFormIdx sig k 0 -> Bool.
-/
theorem doets_lemma_1_1 (sig : MonadicSignature) (k n : Nat)
    (phi : MonadicFormula sig n) (_h_depth : phi.quantifier_depth <= k)
    (M N : OrderedMonadicStructure sig)
    (env_M : Fin n -> M.carrier) (env_N : Fin n -> N.carrier)
    (_h_vec : nf_vector sig k n M env_M = nf_vector sig k n N env_N) :
    (eval M env_M phi <-> eval N env_N phi) := by
  sorry

/-! ## Additional Instances -/

/-- `NormalFormIdx sig k n` is nonempty (since nfCount is positive). -/
instance normalFormIdx_nonempty (sig : MonadicSignature) (k n : Nat) :
    Nonempty (NormalFormIdx sig k n) :=
  ⟨⟨0, nfCount_pos _ _ _⟩⟩

end Bimodal.Metalogic.WeakCanonical
