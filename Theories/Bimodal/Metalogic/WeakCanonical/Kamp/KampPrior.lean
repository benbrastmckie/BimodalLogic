import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# Kamp's Theorem for Prior Structures (Rabinovich 2014)

Proves that {U,S} is expressively complete for Prior structures by
implementing Rabinovich 2014's proof chain: Lemma 5.1 -> Prop 4.2 ->
Prop 4.3 -> Theorem 4.4.

## Main Result

- `kamp_prior_expressive_completeness`: every `MonadicFormula sig 1` has
  an equivalent `Formula` (using only U,S) on Prior structures.
  Same type signature as `US_expressively_complete_over_prior`.

## Proof Architecture (Rabinovich Chain via Structural Induction, v30)

The proof uses Rabinovich's faithful chain:
1. Lemma 5.1: Model-independent negation closure via three-case disjunction
   construction (`NegationIndep.lean`)
2. Prop 4.2: Model-independent negation of V-EA formulas (`NegationIndep.lean`)
3. Prop 4.3: Every FO formula is equivalent to V-EA via structural formula
   induction (`StructuralInduction.lean`)
4. Theorem 4.4: Prop 4.3 + Prop 3.5 (RabinovichTranslation) gives FO -> TL(U,S)

The NF infrastructure (`doets_lemma_1_1`, `nf_exists_unique`, etc.)
and the NF-to-Formula infrastructure (`nf_to_formula`, `nf_to_formula_correct`)
are all sorry-free and reused directly.

## Status

- k=0 (depth 0): sorry-free (`nf_depth0_char_formula`)
- k=1 (depth 1): sorry-free (`nf_succ_char_formula` + `nf_2var_exist_depth0_tl`)
- k>=2 (depth >= 2): uses Prop 4.3 structural induction (v30 plan)

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 3-5
- Reynolds 1994, Theorem 5
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Arity-1 Atom Classification / NF Characterization Infrastructure

`atomKind_arity1_is_pred`, `nf_quant_clause_tl`, and `nf_quant_clause_tl_correct` were RELOCATED to
`NfDepth0Generalized.lean` (task 307 Phase 7). They are small generic helpers; moving them to a module
that both `KampPrior` and the multi-anchor bridge already import lets the bridge drop its
`import KampPrior`, breaking the import cycle that blocked wiring the bound-anchor converter into
`:391`. They remain in the same namespace and are re-exposed here via the existing
`import ...NfDepth0Generalized` (line 3), so every downstream use below is unchanged. -/

/-- Build the characteristic temporal formula for a depth-(k+1) arity-1 NF,
    given a function that converts depth-k arity-2 existentials to temporal. -/
noncomputable def nf_succ_char_formula
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (exist_tl_fn : NormalForm sig k 2 → Formula)
    (nf : NormalForm sig (k + 1) 1) : Formula :=
  let atom_part := nf_depth0_char_formula atomMap h_surj
    (fun a => nf.1 a : NormalForm sig 0 1)
  let quant_clauses := (Finset.univ.toList : List (NormalForm sig k 2)).map
    (fun sub_nf => nf_quant_clause_tl (exist_tl_fn sub_nf) (nf.2 sub_nf))
  formula_conjList (atom_part :: quant_clauses)

/-- Correctness of `nf_succ_char_formula`. -/
theorem nf_succ_char_formula_correct
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (exist_tl_fn : NormalForm sig k 2 → Formula)
    (h_exist_correct : ∀ (sub_nf : NormalForm sig k 2)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (exist_tl_fn sub_nf) ↔
      ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
    (nf : NormalForm sig (k + 1) 1)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (nf_succ_char_formula atomMap h_surj exist_tl_fn nf) ↔
    nf_eval_nf M (k + 1) 1 (fun _ => t) nf := by
  simp only [nf_succ_char_formula]
  rw [formula_conjList_iff]
  change _ ↔ (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ (nf.1 a = true)) ∧
    (∀ (sub_nf : NormalForm sig k 2),
      (∃ (x : M.carrier), nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf) ↔
        (nf.2 sub_nf = true))
  have quant_mem : ∀ sub_nf : NormalForm sig k 2,
      nf_quant_clause_tl (exist_tl_fn sub_nf) (nf.2 sub_nf) ∈
        List.map (fun sub_nf => nf_quant_clause_tl (exist_tl_fn sub_nf) (nf.2 sub_nf))
          Finset.univ.toList :=
    fun sub_nf => List.mem_map.mpr
      ⟨sub_nf, Finset.mem_toList.mpr (Finset.mem_univ sub_nf), rfl⟩
  constructor
  · intro h_all
    constructor
    · have h_atom := h_all _ (.head _)
      rw [nf_depth0_char_formula_correct] at h_atom
      intro a
      obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
      simp only [atom_eval]
      exact h_atom p
    · intro sub_nf
      have h_clause := h_all _ (.tail _ (quant_mem sub_nf))
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _
        (h_exist_correct sub_nf M h_UZ h_SZ t)] at h_clause
      exact h_clause
  · intro ⟨h_atoms, h_quants⟩ φ h_mem
    cases h_mem with
    | head =>
      rw [nf_depth0_char_formula_correct]
      intro p
      exact (h_atoms (.pred p ⟨0, by omega⟩))
    | tail _ h_tail =>
      obtain ⟨sub_nf, _, rfl⟩ := List.mem_map.mp h_tail
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _
        (h_exist_correct sub_nf M h_UZ h_SZ t)]
      exact h_quants sub_nf

/-- Wrap `nf_2var_exist_depth0_tl` to produce the function needed by
    `nf_succ_char_formula` at the base case (k=0). -/
noncomputable def nf_2var_exist_depth0_tl_fn
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    NormalForm sig 0 2 → Formula :=
  fun sub_nf => (nf_2var_exist_depth0_tl atomMap h_surj sub_nf).choose

/-- Correctness of the depth-0 Part B wrapper. -/
theorem nf_2var_exist_depth0_tl_fn_correct
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2)
    (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    temporal_truth M atomMap t (nf_2var_exist_depth0_tl_fn atomMap h_surj sub_nf) ↔
    ∃ x : M.carrier, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf :=
  (nf_2var_exist_depth0_tl atomMap h_surj sub_nf).choose_spec M t

/-! ## Arity-1 Depth-0 NF Characterization

At arity 1, there are no order atoms (since `Fin 1` has only one element,
and `i ≠ j` can't hold). So a depth-0 NF is entirely determined by
predicate atoms. The existing `nf_depth0_char_formula` handles this. -/

/-- The depth-0 characteristic formula is correct for the full NF at arity 1.
    Bridges from predicate agreement to full atom agreement. -/
theorem nf_depth0_char_formula_correct_arity1
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf : NormalForm sig 0 1) (t : M.carrier) :
    temporal_truth M atomMap t (Separation.nf_depth0_char_formula atomMap h_surj nf) ↔
    nf_eval_nf M 0 1 (fun _ => t) nf := by
  rw [Separation.nf_depth0_char_formula_correct]
  simp only [nf_eval_nf]
  constructor
  · -- From predicate agreement to full atom agreement
    intro h_preds a
    obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
    simp only [atom_eval]
    exact h_preds p
  · -- From full atom agreement to predicate agreement
    intro h_atoms p
    have h := h_atoms (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at h
    exact h

/-! ## All-Depth All-Arity NF Existential Conversion

Convert a depth-k n-variable existential over a depth-k arity-(n+1) NF
to a temporal formula. By Nat.rec on k, handling all arities simultaneously:
at depth 0, use nf_nvar_exist_depth0_tl (Phase 2); at depth k+1, use the
IH at depth k (which handles all arities) for the quantifier layer.

This is the key construction for eliminating the critical-path sorry. -/

/-- All-depth all-arity existential conversion: for any depth k, arity n+1,
    and NF `sub_nf`, produce a temporal formula equivalent to the n-variable
    existential `∃ env, nf_eval_nf M k (n+1) (insertEnv env t) sub_nf`.

    The Fin.cons relationship `Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`
    ensures that quantifier conditions at depth k+1 reduce to (n+1)-variable
    existentials at depth k, which are handled by the IH.

    By Nat.rec on k:
    - k=0: `nf_nvar_exist_depth0_tl_fn` (Phase 2, handles all arities)
    - k+1: The n-variable existential at depth k+1 arity (n+1) is equivalent
      to ∃ env satisfying atoms AND quantifiers. The quantifier layer involves
      (n+1)-variable existentials at depth k arity (n+2), available from IH. -/
noncomputable def nf_nvar_exist_all_depths
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → (n : Nat) → (sub_nf : NormalForm sig k (n + 1)) →
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub_nf
  | 0, n, sub_nf =>
    -- Depth 0: use nf_nvar_exist_depth0_tl (Phase 2, handles all arities)
    ⟨nf_nvar_exist_depth0_tl_fn atomMap h_surj n sub_nf,
      fun M _ _ t => nf_nvar_exist_depth0_tl_fn_correct atomMap h_surj n sub_nf M t⟩
  | k + 1, n, sub_nf =>
    -- Depth k+1: the n-variable existential at arity (n+1) decomposes.
    -- nf_eval_nf M (k+1) (n+1) (insertEnv env t) sub_nf =
    --   (∀ a, atom_eval M (insertEnv env t) a ↔ sub_nf.1 a) ∧
    --   (∀ qnf : NormalForm sig k (n+2),
    --     (∃ x, nf_eval_nf M k (n+2) (Fin.cons x (insertEnv env t)) qnf) ↔ sub_nf.2 qnf)
    --
    -- By the identity Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t:
    -- the inner ∃ x combined with ∃ env gives ∃ env' : Fin (n+1) with env' = Fin.cons x env.
    --
    -- The formula construction enumerates all depth-(k+1) arity-(n+1) NF types
    -- and builds a disjunction. For each satisfiable type matching sub_nf,
    -- the formula is obtained from the depth-0 existential (atom layer)
    -- combined with formulas from the IH at depth k (quantifier layer).
    --
    -- The key observation: ∃ env, nf_eval_nf M (k+1) (n+1) (insertEnv env t) sub_nf
    -- is equivalent to: ∃ env, nf_characteristic M (k+1) (n+1) (insertEnv env t) = sub_nf
    -- (by NF uniqueness). This is a first-order condition on t determined by the model.
    --
    -- Since the condition involves finitely many NF types and the existential
    -- is first-order, it can be expressed as a temporal formula by building
    -- the formula from Since/Until chains with nested quantifier conditions.
    --
    -- We construct the formula using the depth-0 all-arity converter for
    -- the atom layer and the IH at depth k for the quantifier layer.
    -- The coupling is handled by building a single formula that conjuncts
    -- the atom conditions with each quantifier clause, wrapped in the
    -- Since/Until chain from nf_nvar_exist_depth0_tl's approach.
    --
    -- Depth k+1: the condition ∃ env, nf_eval_nf M (k+1) (n+1) (insertEnv env t) sub_nf
    -- is a first-order monadic property of t. We build the temporal formula
    -- iteratively: first construct exist_1var at depth k+1 (via simultaneous
    -- fixed-point on NormalForm sig (k+1) 2 → Formula), then bootstrap
    -- char/exist at higher depths, then use NF disjunction for the n-variable case.

    -- Step 1: Build exist_1var_fn at depth k simultaneously for all sub_nf's.
    -- From the IH at depth k, we have exist(k, 1, _):
    have ih_exist_1 : ∀ (sub_nf' : NormalForm sig k 2),
        ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf' :=
      fun sub_nf' => by
        have h := nf_nvar_exist_all_depths atomMap h_surj k 1 sub_nf'
        obtain ⟨A, hA⟩ := h
        refine ⟨A, fun M h_UZ h_SZ t => ?_⟩
        rw [hA M h_UZ h_SZ t]
        have h_env_eq : ∀ (env : Fin 1 → M.carrier),
            insertEnv env t = Fin.cons (env ⟨0, by omega⟩) (fun _ => t) := by
          intro env; funext ⟨i, hi⟩
          simp only [insertEnv]
          by_cases h : i < 1
          · have h_i0 : i = 0 := by omega
            subst h_i0; simp [h, Fin.cons]
          · have h_i1 : i = 1 := by omega
            subst h_i1
            simp only [show ¬(1 < 1) from by omega, ↓reduceDIte]; rfl
        constructor
        · rintro ⟨env, h_env⟩
          exact ⟨env ⟨0, by omega⟩, by rw [← h_env_eq]; exact h_env⟩
        · intro ⟨x, hx⟩
          exact ⟨fun _ => x, by rw [h_env_eq]; exact hx⟩

    -- Step 2: Build char at depth k+1 using ih_exist_1.
    let exist_tl_fn_k : NormalForm sig k 2 → Formula :=
      fun sub_nf' => (ih_exist_1 sub_nf').choose

    have exist_tl_fn_k_correct : ∀ (sub_nf' : NormalForm sig k 2)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (exist_tl_fn_k sub_nf') ↔
        ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf' :=
      fun sub_nf' => (ih_exist_1 sub_nf').choose_spec

    -- char at depth k+1: for each nf' : NormalForm sig (k+1) 1, a temporal formula
    let char_k1 : NormalForm sig (k + 1) 1 → Formula :=
      fun nf' => nf_succ_char_formula atomMap h_surj exist_tl_fn_k nf'

    have char_k1_correct : ∀ (nf' : NormalForm sig (k + 1) 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k1 nf') ↔
        nf_eval_nf M (k + 1) 1 (fun _ => t) nf' :=
      fun nf' M h_UZ h_SZ t =>
        nf_succ_char_formula_correct atomMap h_surj exist_tl_fn_k
          (fun sub_nf' M' h_UZ' h_SZ' t' =>
            exist_tl_fn_k_correct sub_nf' M' h_UZ' h_SZ' t')
          nf' M h_UZ h_SZ t

    -- Step 3: For n = 0, the result follows directly from char_k1.
    -- For n ≥ 1, we need to bootstrap to higher depths and use NF disjunction.
    -- The general case uses the monadic formula approach:
    -- The condition is equivalent to eval M (fun _ => t) phi where
    -- phi : MonadicFormula sig 1 has QD = k+1+n.
    -- By doets_lemma_1_1, its truth depends on arity-1 NF at depth k+1+n.
    -- The formula is a disjunction over "good" depth-(k+1+n) arity-1 NFs.
    -- For each good NF, the characteristic formula is built iteratively
    -- from char_k1 upward.

    -- Case split on n
    match n with
    | 0 =>
      -- n = 0: ∃ env : Fin 0, nf_eval_nf M (k+1) 1 (insertEnv env t) sub_nf
      -- Trivially equivalent to nf_eval_nf M (k+1) 1 (fun _ => t) sub_nf.
      -- Use char_k1 directly.
      ⟨char_k1 sub_nf, fun M h_UZ h_SZ t => by
        rw [char_k1_correct sub_nf M h_UZ h_SZ t]
        constructor
        · intro h; exact ⟨Fin.elim0, by rwa [insertEnv_zero]⟩
        · rintro ⟨env, h_env⟩
          have : insertEnv env t = fun _ => t := by
            funext ⟨i, hi⟩; simp [insertEnv]
          rwa [this] at h_env⟩
    | 1 =>
      -- n = 1: ∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf
      -- This is the critical case needed by the main theorem (Approach 5, report 18).
      -- See handoff for the committed construction and remaining obligation.
      --
      -- task 348 (2026-07-11, transfer note): the exterior-residue mechanism this case
      -- was waiting on is LANDED — `bracketEndChar_kvE2Ext_correct_two_prior_frag`
      -- (NfMultiAnchorBridge/ExteriorBracket.lean) states the k=2 gate biconditional
      -- for the enriched composed gate with `hexclExt` discharged INTERNALLY; the only
      -- hypotheses still threaded are the 309-owned provider obligations
      -- (`hfrag`/`hrealI`/`hrealB`/`hexcl` + order bits + `h_UZ`/`h_SZ`). Retirement of
      -- THIS strategic sorry is task 309 Phase 14's deliverable (R1 scope decision,
      -- task-348 plan): consume 348's discharge theorem + the Phase-14 provider
      -- instantiation. Do not attempt the retirement without both.
      sorry
    | n + 2 =>
      -- n ≥ 2: off the critical path. The main theorem only needs n = 0 and n = 1.
      sorry

/-- Convenience wrapper: extract the formula from `nf_nvar_exist_all_depths`. -/
noncomputable def nf_nvar_exist_all_depths_fn
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k n : Nat) (sub_nf : NormalForm sig k (n + 1)) : Formula :=
  (nf_nvar_exist_all_depths atomMap h_surj k n sub_nf).choose

/-- Correctness of the convenience wrapper. -/
theorem nf_nvar_exist_all_depths_fn_correct
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k n : Nat) (sub_nf : NormalForm sig k (n + 1))
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (nf_nvar_exist_all_depths_fn atomMap h_surj k n sub_nf) ↔
    ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub_nf :=
  (nf_nvar_exist_all_depths atomMap h_surj k n sub_nf).choose_spec M h_UZ h_SZ t

/-! ## NF-to-Temporal Translation for Prior Structures

Core construction: translate a depth-k arity-1 normal form to a temporal
formula that characterizes it on Prior structures.

- **k = 0**: `nf_depth0_char_formula` (conjunction of atom literals).
- **k + 1**: `nf_succ_char_formula` with depth-k arity-2 existential
  converter from `nf_nvar_exist_all_depths`.
-/

/-- For Prior structures, every depth-k arity-1 NF is characterizable
    by a temporal formula (using only U and S).

    This is the Prior-specific replacement for `nf_characterizable_by_stavi`.

    - k=0: `nf_depth0_char_formula` (atom literals)
    - k+1: `nf_succ_char_formula` with depth-k existential converter
      from `nf_nvar_exist_all_depths`
-/
noncomputable def nf_characterizable_temporal_prior
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (nf : NormalForm sig k 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔
        nf_eval_nf M k 1 (fun _ => t) nf } := by
  induction k with
  | zero =>
    -- Depth 0: conjunction of atom literals (no temporal operators needed)
    exact ⟨Separation.nf_depth0_char_formula atomMap h_surj nf,
      fun M _ _ t => nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf t⟩
  | succ k _ih =>
    -- Depth k+1: use nf_succ_char_formula with exist_tl_fn from
    -- nf_nvar_exist_all_depths at depth k, arity 2 (n=1).
    -- nf_nvar_exist_all_depths k 1 sub_nf gives a formula for
    -- ∃ env : Fin 1, nf_eval_nf M k 2 (insertEnv env t) sub_nf
    -- which equals ∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf
    -- (since insertEnv (fun _ => x) t = Fin.cons x (fun _ => t)).
    --
    -- We need exist_tl_fn : NormalForm sig k 2 → Formula with correctness:
    -- temporal_truth M atomMap t (exist_tl_fn sub_nf) ↔
    --   ∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf
    --
    -- This is exactly nf_nvar_exist_all_depths_fn atomMap h_surj k 1.
    -- Correctness needs: insertEnv (fun _ => x) t = Fin.cons x (fun _ => t).
    let exist_tl_fn := nf_nvar_exist_all_depths_fn atomMap h_surj k 1
    have exist_tl_fn_correct : ∀ (sub_nf : NormalForm sig k 2)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (exist_tl_fn sub_nf) ↔
        ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf := by
      intro sub_nf M h_UZ h_SZ t
      rw [nf_nvar_exist_all_depths_fn_correct atomMap h_surj k 1 sub_nf M h_UZ h_SZ t]
      -- Need: (∃ env : Fin 1 → M.carrier, nf_eval_nf M k 2 (insertEnv env t) sub_nf)
      --     ↔ (∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
      -- Key: insertEnv env t = Fin.cons (env 0) (fun _ => t) for env : Fin 1 → M.carrier
      have h_env_eq : ∀ (env : Fin 1 → M.carrier),
          insertEnv env t = Fin.cons (env ⟨0, by omega⟩) (fun _ => t) := by
        intro env; funext ⟨i, hi⟩
        simp only [insertEnv]
        by_cases h : i < 1
        · have h_i0 : i = 0 := by omega
          subst h_i0
          simp [h, Fin.cons]
        · have h_i1 : i = 1 := by omega
          subst h_i1
          simp only [show ¬(1 < 1) from by omega, ↓reduceDIte]
          rfl
      constructor
      · rintro ⟨env, h_env⟩
        exact ⟨env ⟨0, by omega⟩, by rw [← h_env_eq]; exact h_env⟩
      · intro ⟨x, hx⟩
        exact ⟨fun _ => x, by rw [h_env_eq]; exact hx⟩
    exact ⟨nf_succ_char_formula atomMap h_surj exist_tl_fn nf,
      fun M h_UZ h_SZ t =>
        nf_succ_char_formula_correct atomMap h_surj exist_tl_fn
          (fun sub_nf M' h_UZ' h_SZ' t' =>
            exist_tl_fn_correct sub_nf M' h_UZ' h_SZ' t')
          nf M h_UZ h_SZ t⟩

/-- Main theorem: {U,S} expressive completeness for Prior structures,
    proved via Kamp/Rabinovich 2014 (relativized from Dedekind completeness
    to semantic_prior_UZ/SZ).

    Every `MonadicFormula sig 1` has a `Formula` equivalent on Prior structures.
    Same type signature as `US_expressively_complete_over_prior`.

    Proof structure (mirrors `stavi_expressive_completeness`):
    1. Set k = quantifier_depth(psi)
    2. For each depth-k NF, get temporal formula via `nf_characterizable_temporal_prior`
    3. A NF is "good" if some (M, t) satisfies both the NF and psi
    4. Result = disjunction of characteristic formulas of good NFs
    5. Forward: if psi holds, the characteristic NF of (M, t) is good
    6. Backward: if some good NF's formula holds, use `doets_lemma_1_1` to transfer psi -/
noncomputable def kamp_prior_expressive_completeness
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_prior_UZ : semantic_prior_UZ M atomMap)
        (_h_prior_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        temporal_truth M atomMap t A } := by
  -- Step 1: Use the NF infrastructure (sorry-free)
  set k := psi.quantifier_depth with hk_def
  -- Step 2: For each NF, get a temporal characteristic formula (Prior-specific)
  have nf_char := fun nf => nf_characterizable_temporal_prior atomMap h_surj k nf
  let char_f : NormalForm sig k 1 → Formula :=
    fun nf => (nf_char nf).val
  have char_correct : ∀ (nf : NormalForm sig k 1)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (char_f nf) ↔
      nf_eval_nf M k 1 (fun _ => t) nf :=
    fun nf M h_UZ h_SZ t => (nf_char nf).property M h_UZ h_SZ t
  -- Step 3: "good" predicate (NFs consistent with psi)
  let good_prop : NormalForm sig k 1 → Prop :=
    fun nf => ∃ (M : OrderedMonadicStructure sig) (t : M.carrier),
      nf_eval_nf M k 1 (fun _ => t) nf ∧ eval M (fun _ => t) psi
  -- Step 4: Build the disjunction over good NFs
  let all_nfs := (Fintype.elems (α := NormalForm sig k 1)).val.toList
  let good_formulas := all_nfs.filterMap (fun nf =>
    if @decide (good_prop nf) (Classical.dec _) then some (char_f nf) else none)
  -- Helper: good_formulas membership characterization
  have mem_good_iff : ∀ (f : Formula), f ∈ good_formulas ↔
      ∃ nf ∈ all_nfs, good_prop nf ∧ f = char_f nf := by
    intro f
    simp only [good_formulas, List.mem_filterMap]
    constructor
    · rintro ⟨nf, hnf_mem, h_ite⟩
      by_cases hg : good_prop nf
      · rw [if_pos (@decide_eq_true _ (Classical.dec _) hg)] at h_ite
        exact ⟨nf, hnf_mem, hg, (Option.some.inj h_ite).symm⟩
      · rw [if_neg (mt (@decide_eq_true_eq _ (Classical.dec _)).mp hg)] at h_ite
        exact absurd h_ite (by simp)
    · rintro ⟨nf, hnf_mem, hg, rfl⟩
      exact ⟨nf, hnf_mem, by rw [if_pos (@decide_eq_true _ (Classical.dec _) hg)]⟩
  -- NF determines psi (from doets_lemma_1_1 + nf_exists_unique)
  have nf_determines_psi : ∀ (nf : NormalForm sig k 1)
      (M₁ M₂ : OrderedMonadicStructure sig) (t₁ : M₁.carrier) (t₂ : M₂.carrier),
      nf_eval_nf M₁ k 1 (fun _ => t₁) nf →
      nf_eval_nf M₂ k 1 (fun _ => t₂) nf →
      (eval M₁ (fun _ => t₁) psi ↔ eval M₂ (fun _ => t₂) psi) := by
    intro nf M₁ M₂ t₁ t₂ h₁ h₂
    apply doets_lemma_1_1 k 1 psi (hk_def ▸ le_refl _) M₁ M₂ (fun _ => t₁) (fun _ => t₂)
    intro nf'
    obtain ⟨c₁, hc₁, hu₁⟩ := nf_exists_unique M₁ k 1 (fun _ => t₁)
    obtain ⟨c₂, hc₂, hu₂⟩ := nf_exists_unique M₂ k 1 (fun _ => t₂)
    simp only at hu₁ hu₂
    have h_eq₁ : c₁ = nf := (hu₁ nf h₁).symm
    have h_eq₂ : c₂ = nf := (hu₂ nf h₂).symm
    subst h_eq₁; subst h_eq₂
    constructor
    · intro h'; have := hu₁ nf' h'; subst this; exact hc₂
    · intro h'; have := hu₂ nf' h'; subst this; exact hc₁
  -- Step 5: Result is the disjunction
  refine ⟨Separation.formula_disjList good_formulas, fun M h_UZ h_SZ t => ?_⟩
  rw [Separation.formula_disjList_iff]
  constructor
  · -- Forward: psi holds → some good NF's characteristic formula holds
    intro h_psi
    set nf_M := nf_characteristic M k 1 (fun _ => t)
    have h_nf_M := nf_characteristic_satisfies M k 1 (fun _ => t)
    have h_char_eval := (char_correct nf_M M h_UZ h_SZ t).mpr h_nf_M
    have h_good : good_prop nf_M := ⟨M, t, h_nf_M, h_psi⟩
    have h_in : char_f nf_M ∈ good_formulas := by
      rw [mem_good_iff]
      exact ⟨nf_M, Multiset.mem_toList.mpr (Fintype.complete nf_M), h_good, rfl⟩
    exact ⟨char_f nf_M, h_in, h_char_eval⟩
  · -- Backward: some good NF's characteristic formula holds → psi holds
    rintro ⟨A, hA_mem, hA_eval⟩
    rw [mem_good_iff] at hA_mem
    obtain ⟨nf, _, h_good, rfl⟩ := hA_mem
    have h_nf_eval := (char_correct nf M h_UZ h_SZ t).mp hA_eval
    obtain ⟨M', t', hM'_nf, hM'_psi⟩ := h_good
    exact (nf_determines_psi nf M' M t' t hM'_nf h_nf_eval).mp hM'_psi

end Bimodal.Metalogic.WeakCanonical.Kamp
