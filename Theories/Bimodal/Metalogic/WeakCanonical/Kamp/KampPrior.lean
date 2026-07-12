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

/-! ## Task 309 Phase 15 — site/coverage probe: fragment triage + depth-ladder wiring VERDICT

**VERDICT RECORD (2026-07-11, session sess_1783796165_b5b482_309; house style of 13.0/13.3/13.35:
machine-probe, verdict recorded either way, only green material landed).** Rabinovich Def 3.1
(p.4) fixes the normal-form depth stratification this probe walks: `NormalForm sig (k+1) n` has
quant-layer subs `NormalForm sig k (n+1)` (NormalForm.lean:134-136), and `nf_eval_nf M (k+1) n`
couples each sub through `∃ x, nf_eval_nf M k (n+1) (Fin.cons x env) qnf` (NormalForm.lean:198-207)
— the depth of the per-sub obligation is ONE LESS than the depth of the form being evaluated.

**The probed site** (`KampPrior.lean:361`, the `| 1 =>` arm of `nf_nvar_exist_all_depths`):
`sub_nf : NormalForm sig (k+1) 2`, target `∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔
∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`. The site lemmas below decompose
this RHS, sorry-free, down to the named per-`qnf` obligations:

1. `kampPrior_site_env_bridge` — `∃ env : Fin 1` ⟷ `∃ x` on `Fin.cons x (fun _ => t)`.
2. `kampPrior_site_trichotomy` — the composed past/diagonal/future split
   (`nf_zone_exists_trichotomy_k1`, consumed).
3. `kampPrior_site_perQnf_seam` — the depth-(k+1) unfolding at the site env: atom layer ∧
   per-`qnf` obligations `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` over
   `qnf : NormalForm sig k 3`. **This is the seam every arm lemma (P4/P5 `h_quant`,
   NfMultiAnchorBridge/Base:1238-1241/:1438-1441; `A_diag_correct` hooks, Base:765-773) also
   lands on: the per-qnf population at match-arm `k` is at DEPTH `k`, arity 3.**

**(F-i) Fragment coverage — COVERED at the k=1 arm, vacuously.** At the k=1 arm (the depth-2
instance, `sub_nf : NormalForm sig 2 2`), the per-`qnf` population is `NormalForm sig 1 3`
(depth 1, arity 3). The fragment predicate `kvE2_sepFragment` (OuterGate:210) is typed at
`NormalForm sig 2 3` (depth 2) and does not apply to this population — no fragment condition
arises at the depth-2 instance AT ALL: its per-`qnf` obligations are served by the UNCONDITIONAL
rung `bracketEndChar_kv_correct_one_prior` (PriorInterface:95), machine-certified against the
seam shape by `kampPrior_site_rung1_match` below. The fragment triage question lives one arm up
(k=2, `qnf : NormalForm sig 2 3`), where BOTH dispositions are exhibited by machine:
`kampPrior_site_fragment_qnf_exists` (fragment `qnf` exist — via `kvE2_sepFragment_realizable`,
SW:10265) and `kampPrior_site_nonfragment_qnf_exists` (non-fragment `qnf` exist in the site type
— two-interior-positive witness), so the option-(a) fragment scoping at the k=2 arm is a REAL
restriction with non-empty complement: the non-fragment residue routes to the 321-N2 successor
(335 handoff §4), per the settled ∀k-lift decision — never silently absorbed.

**(F-ii) Depth ladder — rung-index = arm-index; depths ≥ 3 have NO landed rung → GO-k1.**
The landed rungs, each machine-certified below against the seam shape
`∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` (`zoneEnv3 w x t` is definitionally
`Fin.cons w (Fin.cons x (fun _ => t))`, NfZoneDepthK:207 — the certificates hold by `exact`):

| match arm k | per-qnf depth | rung | conditionality | certificate |
|---|---|---|---|---|
| 0 | 0 | `bracketEndChar_kv_correct_zero_prior` | unconditional | `kampPrior_site_rung0_match` |
| 1 | 1 | `bracketEndChar_kv_correct_one_prior` | unconditional (`h0` only) | `kampPrior_site_rung1_match` |
| 2 | 2 | `bracketEndChar_kvE2Ext_correct_two_prior_frag` (348, enriched; `hexclExt` internal) | `hfrag` + `hrealI`/`hrealB`/`hexcl` + order bits | `kampPrior_site_rung2_gate_match` |
| ≥3 | ≥3 | **NONE** | — | — (absence: no `BracketCarrierCorrectVPrior`-shaped correctness exists at index ≥ 3; `bracketEndChar_kvE'_correct*` is RETIRED, V9-3) |

**CORRECTED ARM INDEXING (machine finding, supersedes the v9 plan's informal labeling).** The
plan's Phase-18 text placed the kvE2Ext gate consumption at the k=1 arm ("depth-2 instance …
by consuming `bracketEndChar_kvE2Ext_correct_two_prior_frag`"). The gate's `qnf` is typed
`NormalForm sig 2 3` and its RHS is `∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t)))
qnf` — by the seam lemma this is the per-`qnf` obligation of the k=2 arm (`sub_nf :
NormalForm sig 3 2`), not the k=1 arm. Consequences (binding on Phases 16-19):
- **Phase 18 (depth-2 instance)** closes via the UNCONDITIONAL rung-1 + the trichotomy/arm
  assets — cheaper than planned; no fragment certification, no provider obligations needed for
  the k=1 arm itself.
- **The gate + Phases 16-17 provider work pay at the k=2 arm** (depth-3 obligations), fragment-
  scoped per option (a); non-fragment residue → 321-N2 successor.
- **Phase 19's residual** is arms k ≥ 3 (per-qnf depth ≥ 3): the pre-committed GO-k1 routing —
  NARROWED, documented strategic sorry + `follow_up_task` (spawned symbolic-k kvE2Ext-template
  successor), escalated BEFORE landing.

**ROUTING CONSEQUENCE: GO-k1** (pre-committed Phase-15 routing, as refined above). Phases 16-18
proceed; Phase 19 executes the option-(a) case split with the k≥3 arms as the escalated residual.
NOT NO-GO: F-i is covered at the k=1 arm (vacuously — no fragment condition arises there). -/

/-- **Site lemma 1 (task 309 Phase 15): the `Fin 1` env bridge.** The `| 1 =>` site RHS
    existential over `env : Fin 1` equals the single-anchor existential on
    `Fin.cons x (fun _ => t)` — the `h_env_eq` bridge (KampPrior:277-291) extracted as the
    named, reusable site lemma (the shape Phases 18-19 rewrite through). -/
theorem kampPrior_site_env_bridge {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (sub_nf : NormalForm sig (k + 1) 2) (t : M.carrier) :
    (∃ env : Fin 1 → M.carrier,
        nf_eval_nf M (k + 1) 2 (insertEnv env t) sub_nf) ↔
      ∃ x : M.carrier, nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf := by
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
  · rintro ⟨x, hx⟩
    exact ⟨fun _ => x, by rw [h_env_eq]; exact hx⟩

/-- **Site lemma 2 (task 309 Phase 15): the trichotomy decomposition of the `| 1 =>` RHS.**
    The site existential splits into the past / diagonal / future arms — the env bridge
    composed with `nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable:188, consumed, not
    rebuilt). The three disjuncts are exactly the shapes `nf_char2_past_formula_correct` (P4),
    `A_diag_correct`, and `nf_char2_future_formula_correct` (P5) characterize. -/
theorem kampPrior_site_trichotomy {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (sub_nf : NormalForm sig (k + 1) 2) (t : M.carrier) :
    (∃ env : Fin 1 → M.carrier,
        nf_eval_nf M (k + 1) 2 (insertEnv env t) sub_nf) ↔
      (∃ x, x < t ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) ∨
      (nf_eval_nf M (k + 1) 2 (Fin.cons t (fun _ => t)) sub_nf) ∨
      (∃ x, t < x ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) :=
  (kampPrior_site_env_bridge M k sub_nf t).trans
    (nf_zone_exists_trichotomy_k1 M k sub_nf t)

/-- **Site lemma 3 (task 309 Phase 15): the per-`qnf` seam.** The depth-(k+1) evaluation at the
    site env unfolds to the atom layer plus, per `qnf : NormalForm sig k 3` (DEPTH `k` — one
    less than `sub_nf`'s, Rabinovich Def 3.1 stratification), the coupled inner existential
    `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf`. Definitional (`Iff.rfl`, structure eta) —
    the same unfolding P4's `hunf` (Base:1266-1271) uses in-proof, here landed as the NAMED
    per-`qnf` obligation the depth-ladder rungs below are matched against. -/
theorem kampPrior_site_perQnf_seam {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (sub_nf : NormalForm sig (k + 1) 2) (x t : M.carrier) :
    nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf ↔
      (nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2)) ∧
      (∀ qnf : NormalForm sig k 3,
        (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ (sub_nf.2 qnf = true)) :=
  Iff.rfl

/-- **Depth-ladder certificate, arm k=0 (task 309 Phase 15).** The unconditional rung-0
    (`bracketEndChar_kv_correct_zero_prior`, 13.1 lift) types VERBATIM against the per-`qnf`
    seam at match-arm 0 (`qnf : NormalForm sig 0 3`, env `zoneEnv3 w x t`) — holds by `exact`
    (the env is definitionally `Fin.cons w (Fin.cons x (fun _ => t))`, NfZoneDepthK:207). -/
theorem kampPrior_site_rung0_match {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig 0 3)
    (h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier) :
    (bracketEndChar_kv atomMap h_surj charF 0 qnf).holds M atomMap x t ↔
      ∃ w, nf_eval_nf M 0 3 (zoneEnv3 w x t) qnf :=
  bracketEndChar_kv_correct_zero_prior atomMap h_surj charF qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t

/-- **Depth-ladder certificate, arm k=1 (task 309 Phase 15) — THE F-i certificate for the
    depth-2 instance.** The unconditional rung-1 (`bracketEndChar_kv_correct_one_prior`,
    PriorInterface:95; only the depth-0 provider agreement `h0`) types VERBATIM against the
    per-`qnf` seam at match-arm 1 (`qnf : NormalForm sig 1 3`). The depth-2 instance
    (`sub_nf : NormalForm sig 2 2`, Phase 18) therefore closes WITHOUT any fragment condition:
    `kvE2_sepFragment` (typed at `NormalForm sig 2 3`) does not apply to this population —
    F-i coverage at the k=1 arm holds vacuously/unconditionally. -/
theorem kampPrior_site_rung1_match {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nf_depth0_char_formula atomMap h_surj)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier) :
    (bracketEndChar_kv atomMap h_surj charF 1 qnf).holds M atomMap x t ↔
      ∃ w, nf_eval_nf M 1 3 (zoneEnv3 w x t) qnf :=
  bracketEndChar_kv_correct_one_prior atomMap h_surj charF h0 qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t

/-- **Depth-ladder certificate, arm k=2 (task 309 Phase 15).** The task-348 ENRICHED composed
    gate `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean; `hexclExt`
    discharged INTERNALLY, V9-2) types VERBATIM against the per-`qnf` seam at match-arm 2
    (`qnf : NormalForm sig 2 3`) — i.e. the gate's consumption point is the k=2 arm
    (`sub_nf : NormalForm sig 3 2`, depth-3 obligations), NOT the k=1 arm. Hypotheses restated
    exactly (no strengthening/weakening): the six order bits + `h_UZ`/`h_SZ` + `hfrag` +
    the three 309-owned provider obligations (`hrealI` OuterGate:374-shape, `hrealB` :380,
    `hexcl` :387). Fragment-scoped per the settled option-(a) lift decision. -/
theorem kampPrior_site_rung2_gate_match {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier)
    (hfrag : kvE2_sepFragment qnf)
    (hrealI : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).eval_at
        M atomMap w →
      ∀ σ ∈ kvE2_sepPosI qnf,
        ∃ x1 : M.carrier, (x < x1 ∧ x1 < t) ∧
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hrealB : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).eval_at
        M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf,
        ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kvE2Ext atomMap h_surj P qnf).holds M atomMap x t ↔
      ∃ w, nf_eval_nf M 2 3 (zoneEnv3 w x t) qnf :=
  bracketEndChar_kvE2Ext_correct_two_prior_frag atomMap h_surj P qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t hfrag hrealI hrealB hexcl

/-- **F-i positive exhibit (task 309 Phase 15): fragment `qnf` exist at the k=2-arm site
    type.** Direct re-export of `kvE2_sepFragment_realizable` (SW:10265, task 346 Phase 2)
    through the `rfl` defeq bridge `kvE2_sepFragment_frag` = `kvE2_sepFragment`
    (byte-identical bodies, OuterGate:210 / SW:10219). The option-(a) fragment scope at the
    k=2 arm is non-empty. -/
theorem kampPrior_site_fragment_qnf_exists {sig : MonadicSignature} :
    ∃ qnf : NormalForm sig 2 3, kvE2_sepFragment qnf :=
  kvE2_sepFragment_realizable

/-- **F-i negative exhibit (task 309 Phase 15): NON-fragment `qnf` exist at the k=2-arm site
    type.** A `qnf : NormalForm sig 2 3` with TWO interior positives (`σ0` LEFT-interior
    `zXW3`, `σ1` RIGHT-interior `zWT3` — the 346 realizability-witness template with a second
    interior positive), so `kvE2_sepPosI qnf` contains two distinct members and can be no
    singleton: `kvE2_sepFragment qnf` FAILS. Machine-establishes that the option-(a) fragment
    scoping at the k=2 arm is a REAL restriction (non-empty complement); the non-fragment
    residue is the 321-N2 successor's population (335 handoff §4) — recorded, never silently
    absorbed. -/
theorem kampPrior_site_nonfragment_qnf_exists {sig : MonadicSignature} :
    ∃ qnf : NormalForm sig 2 3, ¬ kvE2_sepFragment qnf := by
  classical
  let σ0 : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zXW3 (fun _ => false) (fun _ => false), fun _ => false)
  let σ1 : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zWT3 (fun _ => false) (fun _ => false), fun _ => false)
  have hz0 : nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 :=
    nf0_zoneSpec_assemble kvE2_sep_zXW3 (fun _ => false) (fun _ => false)
  have hz1 : nf0_zoneSpec σ1.1 = kvE2_sep_zWT3 :=
    nf0_zoneSpec_assemble kvE2_sep_zWT3 (fun _ => false) (fun _ => false)
  have hne : σ0 ≠ σ1 := by
    intro h
    have hz : kvE2_sep_zXW3 = kvE2_sep_zWT3 := by rw [← hz0, ← hz1, h]
    exact absurd hz (by decide)
  refine ⟨(fun _ => false, fun σ => decide (σ = σ0 ∨ σ = σ1)), ?_⟩
  rintro ⟨τ, hsing, -⟩
  have hmem : ∀ σ : NormalForm sig 1 4,
      (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
      decide (σ = σ0 ∨ σ = σ1) = true →
      σ ∈ kvE2_sepPosI
        ((fun _ => false, fun σ => decide (σ = σ0 ∨ σ = σ1)) : NormalForm sig 2 3) := by
    intro σ hint hpos
    refine (kvE2_sepPosI_mem _ σ).mpr ⟨?_, hint⟩
    rw [kvE2_sepPos]
    exact List.mem_filter.mpr
      ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hpos⟩
  have h0 := hmem σ0 (Or.inl hz0) (decide_eq_true (Or.inl rfl))
  have h1 := hmem σ1 (Or.inr hz1) (decide_eq_true (Or.inr rfl))
  rw [hsing] at h0 h1
  exact hne ((List.mem_singleton.mp h0).trans (List.mem_singleton.mp h1).symm)

/-! ## Task 309 Phase 16 — provider instantiation shim: `ExistProviders` from the recursion

The `ExistProviders sig atomMap j` bundle (PriorInterface:38, task 309 Phase 13.1 — consumed,
never edited) packages exactly the data the `nf_nvar_exist_all_depths` recursion supplies at
its `| k+1 =>` body for every structurally available depth `j ≤ k`: an all-arity existential
converter `existF` plus its UZ/SZ-conditional correctness — the KampPrior:265 `ih_exist_1`
pattern generalized across arities (per-round provider threading, Cor 5.4, PDF p.7/p.9).

**Shim form — converters threaded as hypotheses (the sanctioned 13.1 surgery pattern; recorded
plan deviation, Phase 16).** The shim takes the recursion's IH family as an explicit hypothesis
`ih` (the exact `∃`-statement shape of `nf_nvar_exist_all_depths atomMap h_surj j`) instead of
calling `nf_nvar_exist_all_depths` by name, for two machine-checked reasons:
1. **Axiom cleanliness**: any top-level reference to `nf_nvar_exist_all_depths` inherits
   `sorryAx` from the open `:361`/`:364` arms — the Phase-16 acceptance bar
   (`lean_verify` = exactly `[propext, Classical.choice, Quot.sound]`) forbids that. The
   of-`ih` form is sorry-free and axiom-clean NOW; the instantiation
   `kampPrior_existProviders_of_ih atomMap j (fun n sub =>
   nf_nvar_exist_all_depths atomMap h_surj j n sub)` type-checks at the `| k+1 =>` site for
   every structurally available `j` (F-A: the ∀k quantifier lives in KampPrior's `Nat.rec`)
   and is Phase 18's arm-rewrite move — the edit that retires the sorry itself.
2. **Line-citation stability**: editing the `| 1 =>` arm body now would shift the `:361`/`:364`
   citations the Phase-15 verdict record and the provider handoffs are keyed to; the site
   instantiation therefore lands WITH the Phase-18 arm rewrite, not before.

Consumption seams delivered below (the shapes Phases 17-18 rewrite through, keyed to the
Phase-15 corrected arm indexing — the gate's `P : ExistProviders sig atomMap 1` is consumed at
the k=2 arm):
- `kampPrior_existProviders_of_ih_correct` — the bundle's raw `insertEnv` correctness, named.
- `kampPrior_existProviders_of_ih_existF0_char` — the `existF 0` arity-1 characteristic bridge
  (`Fin 0` env eliminated): the shape the gate's `kvE2_sepPtW … (fun χ => P.existF 0 χ)`
  positions (`hrealI`/`hrealB`/`hexcl`, OuterGate:374/:380/:387) evaluate.
- `kampPrior_existProviders_of_ih_exist1` — the `existF 1` arity-2 `Fin.cons` bridge: the
  `ih_exist_1` seam (KampPrior:265-291) as a named lemma on the bundle.
- `kampPrior_existProviders_one_of_ih` — the depth-1 bundle, THE gate parameter `P`
  (`kampPrior_site_rung2_gate_match` above).
- `kampPrior_existProviders_zero` — concrete GREEN depth-0 instantiation from the landed
  sorry-free Phase-2 converter (`nf_nvar_exist_depth0_tl_fn`), machine-certifying that the
  bundle instantiates from landed converters with `P.correct` available (h_UZ/h_SZ dropped —
  the depth-0 converter is unconditional). -/

/-- **Phase-16 shim (task 309): `ExistProviders` from the recursion's IH shape.** Given the
    all-arity IH family at depth `j` — the exact statement `nf_nvar_exist_all_depths atomMap
    h_surj j n sub` proves (KampPrior:216-223), structurally available at the `| k+1 =>` site
    for all `j ≤ k` (F-A) — package it as the 13.1 provider bundle. `existF` is the chosen
    formula, `correct` the chosen specification: the `ih_exist_1`/`exist_tl_fn_k` pattern
    (KampPrior:265-304) generalized across arities. -/
noncomputable def kampPrior_existProviders_of_ih {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (j : Nat)
    (ih : ∀ (n : Nat) (sub : NormalForm sig j (n + 1)),
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (_h_UZ : semantic_prior_UZ M atomMap)
          (_h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M j (n + 1) (insertEnv env t) sub) :
    ExistProviders sig atomMap j where
  existF := fun n sub => (ih n sub).choose
  correct := fun n sub M h_UZ h_SZ t => (ih n sub).choose_spec M h_UZ h_SZ t

/-- **Named correctness of the Phase-16 shim** — `P.correct` availability as a standalone
    lemma (grep-anchor for Phases 17-18): the bundle built from `ih` converts the `n`-variable
    depth-`j` existential at the raw `insertEnv` shape. -/
theorem kampPrior_existProviders_of_ih_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (j : Nat)
    (ih : ∀ (n : Nat) (sub : NormalForm sig j (n + 1)),
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (_h_UZ : semantic_prior_UZ M atomMap)
          (_h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M j (n + 1) (insertEnv env t) sub)
    (n : Nat) (sub : NormalForm sig j (n + 1))
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t
        ((kampPrior_existProviders_of_ih atomMap j ih).existF n sub) ↔
      ∃ env : Fin n → M.carrier, nf_eval_nf M j (n + 1) (insertEnv env t) sub :=
  (kampPrior_existProviders_of_ih atomMap j ih).correct n sub M h_UZ h_SZ t

/-- **`existF 0` characteristic bridge (task 309 Phase 16).** At arity 1 (`n = 0`) the bundle's
    converter is a depth-`j` characteristic formula: the `Fin 0` environment is eliminated
    (`insertEnv_zero`), leaving `nf_eval_nf M j 1 (fun _ => t) χ` — the evaluation shape the
    gate's `kvE2_sepPtW … (fun χ => P.existF 0 χ)` provider positions
    (OuterGate:374/:380/:387) consume at the pivot `w`. -/
theorem kampPrior_existProviders_of_ih_existF0_char {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (j : Nat)
    (ih : ∀ (n : Nat) (sub : NormalForm sig j (n + 1)),
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (_h_UZ : semantic_prior_UZ M atomMap)
          (_h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M j (n + 1) (insertEnv env t) sub)
    (χ : NormalForm sig j 1)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t
        ((kampPrior_existProviders_of_ih atomMap j ih).existF 0 χ) ↔
      nf_eval_nf M j 1 (fun _ => t) χ := by
  rw [kampPrior_existProviders_of_ih_correct atomMap j ih 0 χ M h_UZ h_SZ t]
  constructor
  · rintro ⟨env, h⟩
    have hins : insertEnv env t = fun _ => t := by
      funext ⟨i, hi⟩; simp [insertEnv]
    rwa [hins] at h
  · intro h
    exact ⟨Fin.elim0, by rwa [insertEnv_zero]⟩

/-- **`existF 1` `Fin.cons` bridge (task 309 Phase 16).** At arity 2 (`n = 1`) the bundle's
    converter is the single-anchor existential in `Fin.cons` form — the `ih_exist_1` seam
    (KampPrior:265-291) landed as a named lemma on the bundle (the same env bridge as
    `kampPrior_site_env_bridge`, here at arbitrary depth `j`). -/
theorem kampPrior_existProviders_of_ih_exist1 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (j : Nat)
    (ih : ∀ (n : Nat) (sub : NormalForm sig j (n + 1)),
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (_h_UZ : semantic_prior_UZ M atomMap)
          (_h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M j (n + 1) (insertEnv env t) sub)
    (sub : NormalForm sig j 2)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t
        ((kampPrior_existProviders_of_ih atomMap j ih).existF 1 sub) ↔
      ∃ x : M.carrier, nf_eval_nf M j 2 (Fin.cons x (fun _ => t)) sub := by
  rw [kampPrior_existProviders_of_ih_correct atomMap j ih 1 sub M h_UZ h_SZ t]
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
  · rintro ⟨x, hx⟩
    exact ⟨fun _ => x, by rw [h_env_eq]; exact hx⟩

/-- **The depth-1 provider bundle (task 309 Phase 16) — THE gate parameter.** The `j = 1`
    instance of the shim: exactly the `P : ExistProviders sig atomMap 1` that
    `bracketEndChar_kvE2Ext_correct_two_prior_frag` (348) and its site certificate
    `kampPrior_site_rung2_gate_match` take — consumed at the k=2 arm (depth-3 obligations),
    per the Phase-15 corrected arm indexing. At the `| k+1 =>` site the depth-1 IH family is
    structurally available whenever `1 ≤ k` (nested-pattern access, F-A), which holds at every
    arm the gate serves (k ≥ 2). -/
noncomputable def kampPrior_existProviders_one_of_ih {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (ih : ∀ (n : Nat) (sub : NormalForm sig 1 (n + 1)),
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (_h_UZ : semantic_prior_UZ M atomMap)
          (_h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M 1 (n + 1) (insertEnv env t) sub) :
    ExistProviders sig atomMap 1 :=
  kampPrior_existProviders_of_ih atomMap 1 ih

/-- **Concrete GREEN depth-0 instantiation (task 309 Phase 16).** The depth-0 bundle from the
    landed sorry-free Phase-2 all-arity converter `nf_nvar_exist_depth0_tl_fn`
    (NfDepth0Generalized:1615) — no IH hypothesis needed, `h_UZ`/`h_SZ` dropped (the depth-0
    converter is unconditional). Machine-certifies that the 13.1 bundle instantiates from
    landed converters with `P.correct` available: the shim's instantiation pattern, compiled
    green outside the recursion. -/
noncomputable def kampPrior_existProviders_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    ExistProviders sig atomMap 0 where
  existF := fun n sub => nf_nvar_exist_depth0_tl_fn atomMap h_surj n sub
  correct := fun n sub M _h_UZ _h_SZ t =>
    nf_nvar_exist_depth0_tl_fn_correct atomMap h_surj n sub M t

/-! ## Task 309 Phase 18 — trichotomy assembly skeleton for the `| 1 =>` arm

The `| 1 =>` arm goal (`sub_nf : NormalForm sig (k+1) 2`) is
`∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ ∃ env : Fin 1, nf_eval_nf M (k+1) 2
(insertEnv env t) sub_nf`. Phase 15's `kampPrior_site_trichotomy` splits the RHS (at fixed
`M`/`t`) into the past / diagonal / future disjuncts. This section lands the DUAL move on the
LHS: given three arm formulas `A_past`/`A_diag`/`A_future` whose `temporal_truth` at `t` matches
the three disjuncts, their `Formula.or` composition matches the whole site RHS. This is the
`or_congr` skeleton of the plan's Phase 18 (H8 split "18a"): it reduces the `:361` retirement,
at each `(M, t)`, to supplying the three arm correctness facts — the past arm from
`nf_char2_past_formula_correct` (Base:1230, P4), the diagonal from `A_diag_correct` (Base:758),
the future from `nf_char2_future_formula_correct` (Base:1430, P5), each under its depth-`k`
quant-endpoint hook. No hook is discharged here (that is the remaining frontier of Phase 18/19);
no `:361` edit is made; the skeleton is additive and sorry-free. -/

/-- **Site lemma 4 (task 309 Phase 18): the trichotomy `Formula.or` assembly skeleton.** Given
    arm formulas whose `temporal_truth` at `t` realizes the three disjuncts of
    `kampPrior_site_trichotomy`, their right-nested `Formula.or` composition realizes the full
    `| 1 =>` site RHS `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`. Pure
    `temporal_truth_or` (Translation:64) + `or_congr` against the Phase-15 trichotomy split —
    the reusable citation point Phase 19 rewrites the arm through once the three arm formulas +
    correctness are supplied. -/
theorem kampPrior_case1_trichotomy_assemble {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (M : OrderedMonadicStructure sig) (k : Nat)
    (sub_nf : NormalForm sig (k + 1) 2) (t : M.carrier)
    (A_past A_diag A_future : Formula)
    (h_past : temporal_truth M atomMap t A_past ↔
      ∃ x, x < t ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf)
    (h_diag : temporal_truth M atomMap t A_diag ↔
      nf_eval_nf M (k + 1) 2 (Fin.cons t (fun _ => t)) sub_nf)
    (h_future : temporal_truth M atomMap t A_future ↔
      ∃ x, t < x ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) :
    temporal_truth M atomMap t (Formula.or A_past (Formula.or A_diag A_future)) ↔
      ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k + 1) 2 (insertEnv env t) sub_nf := by
  rw [temporal_truth_or, temporal_truth_or, h_past, h_diag, h_future]
  exact (kampPrior_site_trichotomy M k sub_nf t).symm

end Bimodal.Metalogic.WeakCanonical.Kamp
