import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge
import Bimodal.Metalogic.WeakCanonical.Kamp.ZetaUniformExtract
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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    NormalForm sig 0 2 → Formula :=
  fun sub_nf => (nf_2var_exist_depth0_tl atomMap h_surj sub_nf).choose

/-- Correctness of the depth-0 Part B wrapper. -/
theorem nf_2var_exist_depth0_tl_fn_correct
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

/-! ## Hoisted `| 1 =>` arm-closure chain (task 309 Phase 21 hoist, 2026-07-14)

The five lemmas below were MOVED VERBATIM from their original positions later in this file
(statements and proofs unchanged) so that the `| 1 =>` arm of `nf_nvar_exist_all_depths`
can cite the two ambient arm closures without forward references — the plan-v10 Phase-21
sanctioned hoist. Original narratives: the Phase-15 verdict record (site lemmas 1-2), the
Phase-18a skeleton section (site lemma 4 / the assemble engine), the task-358 Phase-5
section (the k=0 closure), and the task-309 Phase-20 section (the k=1 closure); hoist notes
mark each original site. Chain: env bridge → trichotomy → `Formula.or` assembly →
`kampPrior_case1_arm_k0` (task 358) / `kampPrior_case1_arm_k1` (task 309 Phase 20). -/

/-- **Site lemma 1 (task 309 Phase 15): the `Fin 1` env bridge.** The `| 1 =>` site RHS
    existential over `env : Fin 1` equals the single-anchor existential on
    `Fin.cons x (fun _ => t)` — the `h_env_eq` bridge (KampPrior:277-291) extracted as the
    named, reusable site lemma (the shape Phases 18-19 rewrite through). -/
theorem kampPrior_site_env_bridge {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem kampPrior_site_trichotomy {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (k : Nat)
    (sub_nf : NormalForm sig (k + 1) 2) (t : M.carrier) :
    (∃ env : Fin 1 → M.carrier,
        nf_eval_nf M (k + 1) 2 (insertEnv env t) sub_nf) ↔
      (∃ x, x < t ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) ∨
      (nf_eval_nf M (k + 1) 2 (Fin.cons t (fun _ => t)) sub_nf) ∨
      (∃ x, t < x ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) :=
  (kampPrior_site_env_bridge M k sub_nf t).trans
    (nf_zone_exists_trichotomy_k1 M k sub_nf t)

/-- **Site lemma 4 (task 309 Phase 18): the trichotomy `Formula.or` assembly skeleton.** Given
    arm formulas whose `temporal_truth` at `t` realizes the three disjuncts of
    `kampPrior_site_trichotomy`, their right-nested `Formula.or` composition realizes the full
    `| 1 =>` site RHS `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`. Pure
    `temporal_truth_or` (Translation:64) + `or_congr` against the Phase-15 trichotomy split —
    the reusable citation point Phase 19 rewrites the arm through once the three arm formulas +
    correctness are supplied. -/
theorem kampPrior_case1_trichotomy_assemble {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

/-- **Ambient-k=0 arm closure** (task 358, Phase-5 reduced scope): the `| 1 =>` arm statement
    of `nf_nvar_exist_all_depths` at ambient `k = 0` (`sub_nf : NormalForm sig 1 2`), closed
    end-to-end via the trichotomy `Formula.or` assembly (`kampPrior_case1_trichotomy_assemble`)
    over task 350's three landed k=0 arm lemmas. The first G3 green milestone: no obligations,
    no hooks — the arm formula is M-independent by construction. -/
theorem kampPrior_case1_arm_k0 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (_h_UZ : semantic_prior_UZ M atomMap)
        (_h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔
        ∃ env : Fin 1 → M.carrier, nf_eval_nf M 1 2 (insertEnv env t) sub_nf := by
  refine ⟨Formula.or (kampArm_past_k0 atomMap h_surj sub_nf)
    (Formula.or (kampArm_diag_k0 atomMap h_surj sub_nf)
      (kampArm_future_k0 atomMap h_surj sub_nf)), ?_⟩
  intro M h_UZ h_SZ t
  exact kampPrior_case1_trichotomy_assemble atomMap M 0 sub_nf t
    (kampArm_past_k0 atomMap h_surj sub_nf)
    (kampArm_diag_k0 atomMap h_surj sub_nf)
    (kampArm_future_k0 atomMap h_surj sub_nf)
    (kampArm_past_k0_correct atomMap h_surj sub_nf M h_UZ h_SZ t)
    (kampArm_diag_k0_correct atomMap h_surj sub_nf M h_UZ h_SZ t)
    (kampArm_future_k0_correct atomMap h_surj sub_nf M h_UZ h_SZ t)

/-- **Ambient-k=1 arm closure** (task 309 Phase 20, v10 plan): the `| 1 =>` arm statement
    of `nf_nvar_exist_all_depths` at ambient `k = 1` (`sub_nf : NormalForm sig 2 2`), closed
    end-to-end via the trichotomy `Formula.or` assembly (`kampPrior_case1_trichotomy_assemble`)
    over task 350's three landed k=1 arm lemmas. Mirror of `kampPrior_case1_arm_k0` (task 358)
    at k=1: no gate, no provider obligations (Phase-15 corrected arm indexing — the k=1 arm's
    per-`qnf` population is depth 1, served unconditionally); the arm formula is M-independent
    by construction. -/
theorem kampPrior_case1_arm_k1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 2 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (_h_UZ : semantic_prior_UZ M atomMap)
        (_h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔
        ∃ env : Fin 1 → M.carrier, nf_eval_nf M 2 2 (insertEnv env t) sub_nf := by
  refine ⟨Formula.or (kampArm_past_k1 atomMap h_surj sub_nf)
    (Formula.or (kampArm_diag_k1 atomMap h_surj sub_nf)
      (kampArm_future_k1 atomMap h_surj sub_nf)), ?_⟩
  intro M h_UZ h_SZ t
  exact kampPrior_case1_trichotomy_assemble atomMap M 1 sub_nf t
    (kampArm_past_k1 atomMap h_surj sub_nf)
    (kampArm_diag_k1 atomMap h_surj sub_nf)
    (kampArm_future_k1 atomMap h_surj sub_nf)
    (kampArm_past_k1_correct atomMap h_surj sub_nf M h_UZ h_SZ t)
    (kampArm_diag_k1_correct atomMap h_surj sub_nf M h_UZ h_SZ t)
    (kampArm_future_k1_correct atomMap h_surj sub_nf M h_UZ h_SZ t)

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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → (n : Nat) → (hn : n ≤ 1) → (sub_nf : NormalForm sig k (n + 1)) →
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub_nf
  | 0, n, _hn, sub_nf =>
    -- Depth 0: use nf_nvar_exist_depth0_tl (Phase 2, handles all arities)
    ⟨nf_nvar_exist_depth0_tl_fn atomMap h_surj n sub_nf,
      fun M _ _ t => nf_nvar_exist_depth0_tl_fn_correct atomMap h_surj n sub_nf M t⟩
  | k + 1, n, hn, sub_nf =>
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
        have h := nf_nvar_exist_all_depths atomMap h_surj k 1 (by omega) sub_nf'
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

    -- Case split on n. The domain hypothesis `hn : n ≤ 1` is matched alongside `n` so the
    -- arity-(≥2) arm is discharged by the domain restriction rather than left open.
    match n, hn, sub_nf with
    | 0, _, sub_nf =>
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
    | 1, _, sub_nf =>
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
      --
      -- task 309 v10 (2026-07-14, dated record): the k≤1 arms of this case are DISCHARGED
      -- by task 309 v10 Phases 20-21 via the task 349/350/358 deliverables — the k=0 arm
      -- by `kampPrior_case1_arm_k0` (task 358, over task 350's k=0 arm triple) and the
      -- k=1 arm by `kampPrior_case1_arm_k1` (task 309 Phase 20, over task 350's k=1 arm
      -- triple), both assembled through `kampPrior_case1_trichotomy_assemble` (Phase 18a).
      -- The blanket sorry is NARROWED to the `| _k + 2 =>` residual below; k+2 residual →
      -- task 358.
      match k, sub_nf with
      | 0, sub_nf => kampPrior_case1_arm_k0 atomMap h_surj sub_nf
      | 1, sub_nf => kampPrior_case1_arm_k1 atomMap h_surj sub_nf
      | _k + 2, sub_nf =>
        -- The k≥2 arms, via the ζ wire (`kampArm_zeta`, `ZetaUniformExtract.lean`): the
        -- one-free-variable existential over the depth-(k+3) arity-2 NF is expressed by a
        -- single temporal formula through the faithful unary E[Σ]-atom encoding —
        -- `nf_to_formula` lifted along `mapPreds oldPred`, translated by the uniform
        -- Prop 4.3 translate with the p.6 collapse naming (`zetaNameOf`), instantiated at
        -- the canonical expansion (Def 4.1, p.5), and read back at arity 1 through
        -- `translateVeeProp35Fin` + the conservativity bridge `temporal_truth_canonExpand`.
        -- No arity-4 joint type ever arises (Rabinovich, *A Proof of Kamp's Theorem*, 2014:
        -- Def 3.1 p.4, Lemma 3.2(2) p.4, Def 4.1 p.5, Prop 4.3 / Thm 4.4 p.6). The wire is
        -- general in the depth, so this arm also covers what `kampArm_{past,diag,future}_k*`
        -- covered per-depth; only the k=0/k=1 arms above retain the per-depth route.
        (kampArm_zeta atomMap h_surj sub_nf).imp fun _A hA M h_UZ h_SZ t => by
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
          · rintro ⟨x, hx⟩
            exact ⟨fun _ => x, by rw [h_env_eq]; exact hx⟩
          · rintro ⟨env, h_env⟩
            exact ⟨env ⟨0, by omega⟩, by rw [← h_env_eq]; exact h_env⟩
    | _n + 2, hn2, _sub_nf =>
      -- Arity ≥ 2 is outside this definition's domain: the `hn : n ≤ 1` parameter excludes it.
      -- This arm is discharged by the domain restriction, NOT by a proof of the n ≥ 2 case,
      -- which remains unproved (and unneeded: every call site is n = 0 or n = 1 — the
      -- recursion resets arity to 1 at the `ih_exist_1` self-call, and the live entry from
      -- `nf_characterizable_temporal_prior` is n = 1). The restriction exists for axiom
      -- tracking: `sorryAx` is tracked per-declaration, not per-path, so an unreachable
      -- `sorry` here would still enter this declaration's proof term.
      absurd hn2 (by omega)

/-- Convenience wrapper: extract the formula from `nf_nvar_exist_all_depths`. -/
noncomputable def nf_nvar_exist_all_depths_fn
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k n : Nat) (hn : n ≤ 1) (sub_nf : NormalForm sig k (n + 1)) : Formula :=
  (nf_nvar_exist_all_depths atomMap h_surj k n hn sub_nf).choose

/-- Correctness of the convenience wrapper. -/
theorem nf_nvar_exist_all_depths_fn_correct
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k n : Nat) (hn : n ≤ 1) (sub_nf : NormalForm sig k (n + 1))
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (nf_nvar_exist_all_depths_fn atomMap h_surj k n hn sub_nf) ↔
    ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub_nf :=
  (nf_nvar_exist_all_depths atomMap h_surj k n hn sub_nf).choose_spec M h_UZ h_SZ t

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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    let exist_tl_fn := nf_nvar_exist_all_depths_fn atomMap h_surj k 1 (by omega)
    have exist_tl_fn_correct : ∀ (sub_nf : NormalForm sig k 2)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (exist_tl_fn sub_nf) ↔
        ∃ x : M.carrier, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf := by
      intro sub_nf M h_UZ h_SZ t
      rw [nf_nvar_exist_all_depths_fn_correct atomMap h_surj k 1 (by omega) sub_nf M h_UZ h_SZ t]
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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

/-! **HOIST NOTE (task 309 Phase 21, 2026-07-14)**: Site lemmas 1 and 2
(`kampPrior_site_env_bridge`, `kampPrior_site_trichotomy`) were MOVED VERBATIM above
`nf_nvar_exist_all_depths` (the "Hoisted `| 1 =>` arm-closure chain" section) so the `:361`
k≤1 match narrowing can cite the arm closures without forward references — the sanctioned
Phase-21 hoist (plan v10, forward-reference safety clause). Statements and proofs unchanged;
the Phase-15 verdict record above remains the authoritative narrative for them. -/

/-- **Site lemma 3 (task 309 Phase 15): the per-`qnf` seam.** The depth-(k+1) evaluation at the
    site env unfolds to the atom layer plus, per `qnf : NormalForm sig k 3` (DEPTH `k` — one
    less than `sub_nf`'s, Rabinovich Def 3.1 stratification), the coupled inner existential
    `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf`. Definitional (`Iff.rfl`, structure eta) —
    the same unfolding P4's `hunf` (Base:1266-1271) uses in-proof, here landed as the NAMED
    per-`qnf` obligation the depth-ladder rungs below are matched against. -/
theorem kampPrior_site_perQnf_seam {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem kampPrior_site_rung0_match {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem kampPrior_site_rung1_match {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem kampPrior_site_rung2_gate_match {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

set_option maxHeartbeats 1600000 in
/-- **General-`k` supply-site certificate** `kampPrior_site_rungK_gate_match` (task 357 Phase 5).
    The general-`k` mirror of `kampPrior_site_rung2_gate_match` (`:761`), one fold-family deeper:
    the per-`qnf` seam restatement of the task-356 exterior-composed discharge
    `bracketEndChar_kvExt_correct_prior` (`ExteriorGateAssembleK.lean:106`) at depth `(k+2)`, for
    ALL `k` (uniformly subsuming the k=2 arm as the `k = 0` member). It CARRIES the eleven
    obligations — the seven interior (`P`/`hcharK`/`h_UZ`/`h_SZ`/`hreal`/`hexcl` + the internalized
    `hexclExt`) and the four SLICE-KEYED exterior obligations (`hslice*`/`hexclSlice*`, task 360
    Phase 3b replacements for the eliminated `hbr*`) — exactly as the rung-2 certificate carries
    `hrealI`/`hrealB`/`hexcl`. `hexclExt` is discharged internally by the consumed lemma; it is NOT
    an input binder. This is the general-`k` seam the reshaped consumer
    `endInterval_step_correct` (`EndIntervalConsumerK.lean`) closes task 349 Phase 5 through.

    **Obligation discipline (carry, do NOT discharge).** `hreal`/`hexcl`/`hslice*`/`hexclSlice*`
    are threaded outward — discharging `hreal`/`hexcl` requires the un-landed realization recursion
    (the `:361`/`:364` sorry arms), the fenced-out escalation boundary (task 357 Phase 7 /
    task-309 Phase-14 successor); the slice obligations are discharged at m = 0 by the plan-v2
    Phase-5 supply theorems. No `sorry`, no vacuous def is introduced here. -/
theorem kampPrior_site_rungK_gate_match {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (P : ExistProviders sig atomMap (k + 1))
    (hcharK : charF (k + 1) = fun χ => P.existF 0 χ)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier)
    -- Task-363 interior rows-5-6 antecedent (D7 repair), mirroring
    -- `EndIntervalCorrectPrior`: the supply population is restricted to fiber-CONSISTENT
    -- marked slices (`kvE_fiberConsistent`); the doppelgänger fake ambient fails it, honest
    -- realized ambients discharge it via `kvE_fiberConsistent_of_realized`.
    (hfiberCons : ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
      kvE_fiberConsistent σ = true)
    (hreal : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        kvE_fiberConsistent σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
        kvE_fiberConsistent σ = true →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- SLICE-KEYED exterior interface (task 360 Phase 3b; task 367 DEEP-ANCHORED): binder
    -- types mirrored verbatim from `ExteriorGateAssembleK.lean`. The four eliminated `hbr*`
    -- binders (guarded `hbr*Sat` machine-refuted, `kvE_futPinned_of_end_zero_refuted`) are
    -- replaced by carried obligations: `hslice*` (⇐-side slice honesty, ambient-guarded;
    -- DEEP-anchored per task 367 — `kvE_deepOnFiber qnf σ = true` REPLACES the depth-0 row
    -- `nfk_dropFresh σ = qnf.1` and mirrors the re-keyed bracket range; at m = 0 the guard
    -- IS the row check, `kvE_deepOnFiber_zero`), `hexclSlice*` (⇒-side per-σ exclusion
    -- residue for bit-false-but-slice-marked σ, `igPtW`-guarded, BYTE-STABLE), and the NEW
    -- task-367 rows 12-13 `hexclDeep*` (⇒-side residue for on-row guard-false σ,
    -- m = 0-vacuous). Discharged at m = 0 via `kvE_{fut,past}SliceId_of_end_zero` /
    -- `kvE_{fut,past}SliceUnique_zero` + `hreal` through the `_zero` adapter.
    (hslicePast : ∀ w : M.carrier, x < w → w < t →
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true →
        kvE_deepOnFiber qnf σ = true →
        temporal_truth M atomMap x (kvE_pastPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ' = true ∧
          kvE_pastSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hsliceFut : ∀ w : M.carrier, x < w → w < t →
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true →
        kvE_deepOnFiber qnf σ = true →
        temporal_truth M atomMap t (kvE_futPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvE_futAdmissible σ' = true ∧
          kvE_futSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hexclSlicePast : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
        kvE_pastSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, x1 < x →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclSliceFut : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
        kvE_futSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, t < x1 →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepPast : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
        nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, x1 < x →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepFut : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF (k + 1)) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
        nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, t < x1 →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kvExt atomMap h_surj charF Pbr qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  -- Task 363: reconstruct the unrestricted interior obligations for the (unchanged)
  -- downstream discharge lemma — `hreal` by modus ponens with `hfiberCons`; `hexcl` by
  -- case split (an inconsistent σ has no realization at all).
  bracketEndChar_kvExt_correct_prior atomMap h_surj charF P hcharK Pbr qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t
    (fun hAmb w hxw hwt hg σ hσ => hreal hAmb w hxw hwt hg σ hσ (hfiberCons σ hσ))
    (fun hAmb w hxw hwt hg σ hσf x1 hle1 hle2 hnf => by
      by_cases hcons : kvE_fiberConsistent σ = true
      · exact hexcl hAmb w hxw hwt hg σ hσf hcons x1 hle1 hle2 hnf
      · exact hcons (kvE_fiberConsistent_of_realized M _ σ hnf))
    hslicePast hsliceFut hexclSlicePast hexclSliceFut hexclDeepPast hexclDeepFut

set_option maxHeartbeats 1600000 in
/-- **De-folded general-`k` supply-site certificate** `kampPrior_site_rungKFib_gate_match`
    (task 370 Phase 6 — additive sibling of `kampPrior_site_rungK_gate_match`, `:941`). The
    per-`qnf` seam restatement of the DE-FOLDED exterior-composed discharge
    `bracketEndChar_kvExtFib_correct_prior` (Option B; routed through the SIBLING de-folded interior
    carrier `bracketEndChar_kvFib`). The row-5/6 `hreal`/`hexcl` and the slice/deep exclusion
    binders are re-keyed onto the non-projecting fiber gate
    `igPtWFib … (charFib (k+1)) qnf.1 (igFoldBitFib qnf)`; the folded arity-1 provider bundle
    `P`/`hcharK` is replaced by the render-gated arity-4 char seam `hcharFib` (threaded outward like
    `hreal`/`hexcl`). Obligation discipline (carry, do NOT discharge) is preserved verbatim: `hreal`
    fires by modus ponens with `hfiberCons`; `hexcl` by the inconsistent-σ case split. The frozen
    `kampPrior_site_rungK_gate_match` above is left byte-identical (its out-of-scope consumer
    `EndIntervalConsumerK.lean:248` is unaffected). -/
theorem kampPrior_site_rungKFib_gate_match {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier)
    (hcharFib : ∀ (w : M.carrier),
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig (k + 1) 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib (k + 1) σ) ↔
          nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- Render-free char-soundness seam (by-design, `w`-universal; arity-4 analog of `P`/`hcharK`),
    -- threaded to `correct_prior` → `step_sound` where the de-folded `hreal` is discharged.
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
      temporal_truth M atomMap x1 (charFib (k + 1) τ) →
      nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    -- Task-363 interior rows-5-6 antecedent (D7 repair), mirroring
    -- `EndIntervalCorrectPrior`: the supply population is restricted to fiber-CONSISTENT
    -- marked slices (`kvE_fiberConsistent`); the doppelgänger fake ambient fails it, honest
    -- realized ambients discharge it via `kvE_fiberConsistent_of_realized`.
    (hfiberCons : ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
      kvE_fiberConsistent σ = true)
    (hreal : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1 (igFoldBitFib qnf)).eval_at
        M atomMap w →
      (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1 (igFoldBitFib qnf)).eval_at
        M atomMap x →
      (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1 (igFoldBitFib qnf)).eval_at
        M atomMap t →
      (∀ (τ : NormalForm sig (k + 1) 4) (x1 : M.carrier),
        temporal_truth M atomMap x1 (charFib (k + 1) τ) →
        nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig (k + 1) 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZPastX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZXW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZWT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZFutT) →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = true →
        kvE_fiberConsistent σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1 (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, qnf.2 σ = false →
        kvE_fiberConsistent σ = true →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- SLICE-KEYED exterior interface (task 360 Phase 3b; task 367 DEEP-ANCHORED): binder
    -- types mirrored verbatim from `ExteriorGateAssembleK.lean`, `igPtW`→`igPtWFib`.
    (hslicePast : ∀ w : M.carrier, x < w → w < t →
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true →
        kvE_deepOnFiber qnf σ = true →
        temporal_truth M atomMap x (kvE_pastPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ' = true ∧
          kvE_pastSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hsliceFut : ∀ w : M.carrier, x < w → w < t →
      nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true →
        kvE_deepOnFiber qnf σ = true →
        temporal_truth M atomMap t (kvE_futPos Pbr σ) →
        ∃ σ' : NormalForm sig (k + 1) 4, kvE_futAdmissible σ' = true ∧
          kvE_futSliceEq σ' σ = true ∧ qnf.2 σ' = true)
    (hexclSlicePast : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1 (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
        kvE_pastSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, x1 < x →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclSliceFut : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1 (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
        kvE_futSliceMarked qnf σ = true →
        ∀ x1 : M.carrier, t < x1 →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepPast : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1 (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_pastAdmissible σ = true → qnf.2 σ = false →
        nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, x1 < x →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclDeepFut : kvE_ambientDeepAnchor qnf = true → ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib (k + 1)) qnf.1 (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig (k + 1) 4, kvE_futAdmissible σ = true → qnf.2 σ = false →
        nfk_dropFresh σ = qnf.1 → kvE_deepOnFiber qnf σ = false →
        ∀ x1 : M.carrier, t < x1 →
          ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kvExtFib atomMap h_surj charFib Pbr qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  -- Task 363: reconstruct the unrestricted interior obligations for the de-folded discharge
  -- lemma — `hreal` by modus ponens with `hfiberCons`; `hexcl` by
  -- case split (an inconsistent σ has no realization at all).
  bracketEndChar_kvExtFib_correct_prior atomMap h_surj charFib Pbr qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t hcharFib hcharFibSoundP
    (fun hAmb w hxw hwt hg hepL hepR hcs hIL hIR hzc σ hσ =>
      hreal hAmb w hxw hwt hg hepL hepR hcs hIL hIR hzc σ hσ (hfiberCons σ hσ))
    (fun hAmb w hxw hwt hg σ hσf x1 hle1 hle2 hnf => by
      by_cases hcons : kvE_fiberConsistent σ = true
      · exact hexcl hAmb w hxw hwt hg σ hσf hcons x1 hle1 hle2 hnf
      · exact hcons (kvE_fiberConsistent_of_realized M _ σ hnf))
    hslicePast hsliceFut hexclSlicePast hexclSliceFut hexclDeepPast hexclDeepFut

/-- **F-i positive exhibit (task 309 Phase 15): fragment `qnf` exist at the k=2-arm site
    type.** Direct re-export of `kvE2_sepFragment_realizable` (SW:10265, task 346 Phase 2)
    through the `rfl` defeq bridge `kvE2_sepFragment_frag` = `kvE2_sepFragment`
    (byte-identical bodies, OuterGate:210 / SW:10219). The option-(a) fragment scope at the
    k=2 arm is non-empty. -/
theorem kampPrior_site_fragment_qnf_exists {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
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
theorem kampPrior_site_nonfragment_qnf_exists {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
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
noncomputable def kampPrior_existProviders_of_ih {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem kampPrior_existProviders_of_ih_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem kampPrior_existProviders_of_ih_existF0_char {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem kampPrior_existProviders_of_ih_exist1 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
noncomputable def kampPrior_existProviders_one_of_ih {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
noncomputable def kampPrior_existProviders_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    ExistProviders sig atomMap 0 where
  existF := fun n sub => nf_nvar_exist_depth0_tl_fn atomMap h_surj n sub
  correct := fun n sub M _h_UZ _h_SZ t =>
    nf_nvar_exist_depth0_tl_fn_correct atomMap h_surj n sub M t

/-! **HOIST NOTE (task 309 Phase 21, 2026-07-14)**: the Phase-18a trichotomy `Formula.or`
assembly skeleton (`kampPrior_case1_trichotomy_assemble`, site lemma 4) was MOVED VERBATIM
above `nf_nvar_exist_all_depths` (the "Hoisted `| 1 =>` arm-closure chain" section) together
with its section narrative — the sanctioned Phase-21 hoist enabling the `:361` k≤1 match
narrowing. Statement and proof unchanged. -/

/-! ## Task 358 Phase 2 — the Cor 5.4(1) ⇐ within-bracket realizer (Rabinovich 2014)

The realizer direction of Rabinovich's pivotal observation (Cor 5.4(1), §5, chunk 0015
lines 9–41): from the F-chain firing at an increasing sequence of BOUND points
`x 0 < … < x n` (each `Fi(x i)`), an actual within-bracket witness family is produced
by induction on the chain length, with the two-way `min`/case-split
(`if y2 ≤ x_{i+1} then z := y2 else z := x_{i+1}`) at every Until-link — NOT an
`inf`/`sup` global selection (report 02 §2.3). This is the bounded form that resolves the
documented model-independent impossibility at EANegation.lean:1249 (the F-chain
Until-unboundedness): the bound points `x i` cap every Until-witness, keeping the whole
construction inside the bracket. The k=1 landed template is the base
(`BracketFormula.fChainFrom_base`); each inductive step is exactly one Until-driven
chain-link (`fChainFrom_step` + extraction + case-split), mirrored explicitly.

The σ-level fold assembly (`kampPrior_futRealizer_assemble` / `kampPrior_pastRealizer_assemble`)
then mirrors the converter body (ExteriorConverterK.lean:158–188) POSITIVELY: at the anchor
`x1` the chain destructor reconstructs, the atom layer + per-fiber biconditional + off-fiber
falsity fold into the genuine realizer `hσ` via `nf_eval_nfk_iff_efold`. The drivers
(`kampPrior_futRealizer_of_pos` / `kampPrior_pastRealizer_of_pos`) run the landed destructor
(`kvE_{fut,past}ChainDestructG`) on the positive local-existence form and emit the SELECTED
exterior anchor together with `hσ` — the positive-existence reading of
`kvE_extNeg{Fut,Past}_complete` (the same body, producing the realizer instead of the
contradiction). Arity-generic: the chain realizer is stated for every `BracketFormula (n+1)`
(Fin.cons prepend at each link), so the Phase-4 arity lift reuses it verbatim. -/

/-- **Chain-link prepend** (the shared assembly step of both case-split branches). Given a
    witness family `w'` for the chain suffix `i+1, …, n` and a head anchor `v` at index `i`
    (below the suffix, carrying `α_i`, with `β_{i+1}` on the gap `(v, w' 0)`), the prepended
    family `Fin.cons v w'` witnesses the suffix `i, …, n`. Pure `Fin.cons` transfer — all
    chain content enters through the hypotheses. -/
theorem kampPrior_fChain_realize_cons {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (x : Fin (n + 1) → M.carrier)
    (i : Fin (n + 1)) {d' : Nat} (hd : i.val + (d' + 1) = n)
    (v : M.carrier) (w' : Fin (d' + 1) → M.carrier)
    (hv0 : v < w' ⟨0, by omega⟩)
    (hw'mono : ∀ a b : Fin (d' + 1), a < b → w' a < w' b)
    (hw'le : ∀ a : Fin (d' + 1), w' a ≤ x ⟨i.val + 1 + a.val, by omega⟩)
    (hw'pt : ∀ a : Fin (d' + 1),
      (bf.pointTypes ⟨i.val + 1 + a.val, by omega⟩).eval_at M atomMap (w' a))
    (hseg0 : ∀ r : M.carrier, v < r → r < w' ⟨0, by omega⟩ →
      (bf.segmentTypes ⟨i.val + 1, by omega⟩).eval_at M atomMap r)
    (hw'seg : ∀ a : Fin d', ∀ r : M.carrier,
      w' ⟨a.val, by omega⟩ < r → r < w' ⟨a.val + 1, by omega⟩ →
      (bf.segmentTypes ⟨i.val + 1 + a.val + 1, by omega⟩).eval_at M atomMap r)
    (hw'fin : ∃ s : M.carrier, w' ⟨d', by omega⟩ < s ∧
      ∀ r : M.carrier, w' ⟨d', by omega⟩ < r → r < s →
      (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap r)
    (hvx : v ≤ x i)
    (halpha : (bf.pointTypes i).eval_at M atomMap v) :
    ∃ w : Fin (d' + 1 + 1) → M.carrier,
      w ⟨0, by omega⟩ = v ∧
      (∀ a b : Fin (d' + 1 + 1), a < b → w a < w b) ∧
      (∀ a : Fin (d' + 1 + 1), w a ≤ x ⟨i.val + a.val, by omega⟩) ∧
      (∀ a : Fin (d' + 1 + 1),
        (bf.pointTypes ⟨i.val + a.val, by omega⟩).eval_at M atomMap (w a)) ∧
      (∀ a : Fin (d' + 1), ∀ r : M.carrier,
        w ⟨a.val, by omega⟩ < r → r < w ⟨a.val + 1, by omega⟩ →
        (bf.segmentTypes ⟨i.val + a.val + 1, by omega⟩).eval_at M atomMap r) ∧
      (∃ s : M.carrier, w ⟨d' + 1, by omega⟩ < s ∧
        ∀ r : M.carrier, w ⟨d' + 1, by omega⟩ < r → r < s →
        (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap r) := by
  refine ⟨Fin.cons v w', rfl, ?_, ?_, ?_, ?_, hw'fin⟩
  · -- strict monotonicity of the prepended family
    intro a b hab
    rcases Fin.eq_zero_or_eq_succ a with rfl | ⟨a', rfl⟩
    · rcases Fin.eq_zero_or_eq_succ b with rfl | ⟨b', rfl⟩
      · exact absurd hab (lt_irrefl _)
      · rw [Fin.cons_zero, Fin.cons_succ]
        rcases eq_or_lt_of_le (Fin.zero_le b') with hb0 | hb0
        · rw [← hb0]; exact hv0
        · exact hv0.trans (hw'mono _ b' hb0)
    · rcases Fin.eq_zero_or_eq_succ b with rfl | ⟨b', rfl⟩
      · simp only [Fin.lt_def, Fin.val_succ, Fin.val_zero] at hab
        omega
      · rw [Fin.cons_succ, Fin.cons_succ]
        exact hw'mono a' b' (by
          rw [Fin.lt_def] at hab ⊢
          simpa [Fin.val_succ] using hab)
  · -- bound-domination `w a ≤ x (i + a)`
    intro a
    rcases Fin.eq_zero_or_eq_succ a with rfl | ⟨a', rfl⟩
    · rw [Fin.cons_zero]
      have hidx : (⟨i.val + (0 : Fin (d' + 1 + 1)).val, by omega⟩ : Fin (n + 1)) = i := by
        ext; simp
      rw [hidx]; exact hvx
    · rw [Fin.cons_succ]
      have hidx : (⟨i.val + (Fin.succ a').val, by omega⟩ : Fin (n + 1))
          = ⟨i.val + 1 + a'.val, by omega⟩ := by
        ext; simp only [Fin.val_succ]; omega
      rw [hidx]; exact hw'le a'
  · -- point types
    intro a
    rcases Fin.eq_zero_or_eq_succ a with rfl | ⟨a', rfl⟩
    · rw [Fin.cons_zero]
      have hidx : (⟨i.val + (0 : Fin (d' + 1 + 1)).val, by omega⟩ : Fin (n + 1)) = i := by
        ext; simp
      rw [hidx]; exact halpha
    · rw [Fin.cons_succ]
      have hidx : (⟨i.val + (Fin.succ a').val, by omega⟩ : Fin (n + 1))
          = ⟨i.val + 1 + a'.val, by omega⟩ := by
        ext; simp only [Fin.val_succ]; omega
      rw [hidx]; exact hw'pt a'
  · -- interior segments (head gap from `hseg0`, suffix gaps shifted)
    intro a r hr1 hr2
    obtain ⟨av, hav⟩ := a
    cases av with
    | zero =>
      exact hseg0 r hr1 hr2
    | succ j =>
      have hres := hw'seg ⟨j, by omega⟩ r hr1 hr2
      have hidx : (⟨i.val + 1 + (⟨j, by omega⟩ : Fin d').val + 1, by omega⟩ : Fin (n + 1 + 1))
          = ⟨i.val + (j + 1) + 1, by omega⟩ := by
        ext; show i.val + 1 + j + 1 = i.val + (j + 1) + 1; omega
      rw [hidx] at hres
      exact hres

/-- **Cor 5.4(1) ⇐, suffix form** (the inductive engine). Given the F-chain bound points
    `x : Fin (n+1) → M.carrier` (increasing, each satisfying its `fChainFrom`), any point
    `v ≤ x i` satisfying `fChainFrom i` extends to a full witness family `w` for the chain
    suffix `i, i+1, …, n`: strictly increasing, dominated by the bounds (`w a ≤ x (i+a)`),
    carrying the point types, the interior segment types on consecutive gaps, and the final
    Until residue (`∃ s` beyond the last witness with `β_{n+1}` on the gap).

    Induction on the suffix length `d`; each step extracts the Until-witness `y` of the next
    link (`fChainFrom_step`) and performs Rabinovich's two-way case-split against the next
    bound point `x (i+1)`: if `y ≤ x (i+1)` the witness itself is the next anchor, otherwise
    `x (i+1) ∈ (v, y)` and the segment type transfers by restriction — both branches keep the
    invariant `w a ≤ x (i+a)` (chunk 0015: "If y2 ≤ xn+1 then z = y2 … otherwise
    xn+1 ∈ (y1, y2) … z = xn+1"). No `simp`/`omega` bypass of the case-split. -/
theorem kampPrior_fChain_realize_from {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1))
    (x : Fin (n + 1) → M.carrier)
    (hmono : ∀ i j : Fin (n + 1), i < j → x i < x j)
    (hF : ∀ i : Fin (n + 1), (bf.fChainFrom i).eval_at M atomMap (x i)) :
    ∀ (d : Nat) (i : Fin (n + 1)) (_hd : i.val + d = n),
      ∀ v : M.carrier, v ≤ x i →
        (bf.fChainFrom i).eval_at M atomMap v →
        ∃ w : Fin (d + 1) → M.carrier,
          w ⟨0, by omega⟩ = v ∧
          (∀ a b : Fin (d + 1), a < b → w a < w b) ∧
          (∀ a : Fin (d + 1), w a ≤ x ⟨i.val + a.val, by omega⟩) ∧
          (∀ a : Fin (d + 1),
            (bf.pointTypes ⟨i.val + a.val, by omega⟩).eval_at M atomMap (w a)) ∧
          (∀ a : Fin d, ∀ r : M.carrier,
            w ⟨a.val, by omega⟩ < r → r < w ⟨a.val + 1, by omega⟩ →
            (bf.segmentTypes ⟨i.val + a.val + 1, by omega⟩).eval_at M atomMap r) ∧
          (∃ s : M.carrier, w ⟨d, by omega⟩ < s ∧
            ∀ r : M.carrier, w ⟨d, by omega⟩ < r → r < s →
            (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap r) := by
  intro d
  induction d with
  | zero =>
    -- Base: the last link — the landed k=1 template shape (`fChainFrom_base`).
    intro i hd v hvx hFv
    have hin : i.val = n := by omega
    have hfi : bf.fChainFrom i = bf.fChainFrom ⟨n, by omega⟩ := by
      congr 1; ext; exact hin
    rw [hfi, BracketFormula.fChainFrom_base M atomMap bf v] at hFv
    obtain ⟨halpha, s, hvs, hseg⟩ := hFv
    refine ⟨fun _ => v, rfl, ?_, ?_, ?_, ?_, ⟨s, hvs, hseg⟩⟩
    · intro a b hab
      exact absurd (Fin.lt_def.mp hab) (by omega)
    · intro a
      have hidx : (⟨i.val + a.val, by omega⟩ : Fin (n + 1)) = i := by
        ext; show i.val + a.val = i.val; omega
      rw [hidx]; exact hvx
    · intro a
      have hidx : (⟨i.val + a.val, by omega⟩ : Fin (n + 1)) = ⟨n, by omega⟩ := by
        ext; show i.val + a.val = n; omega
      rw [hidx]; exact halpha
    · intro a; exact a.elim0
  | succ d' ih =>
    -- Step: one Until-driven chain-link (`fChainFrom_step`) + the two-way case-split.
    intro i hd v hvx hFv
    have hin : i.val < n := by omega
    rw [BracketFormula.fChainFrom_step M atomMap bf i hin v] at hFv
    obtain ⟨halpha, y, hvy, hFy, hseg⟩ := hFv
    have hii1 : i < (⟨i.val + 1, by omega⟩ : Fin (n + 1)) := by
      rw [Fin.lt_def]; show i.val < i.val + 1; omega
    have hxi1 : x i < x ⟨i.val + 1, by omega⟩ := hmono i ⟨i.val + 1, by omega⟩ hii1
    have hd1 : (⟨i.val + 1, by omega⟩ : Fin (n + 1)).val + d' = n := by
      show i.val + 1 + d' = n; omega
    -- Rabinovich's two-way `min`/case-split against the next bound point `x (i+1)`.
    rcases le_or_gt y (x ⟨i.val + 1, by omega⟩) with hle | hgt
    · -- Branch 1: `y ≤ x_{i+1}` — the required next anchor is the Until-witness `y` itself.
      obtain ⟨w', hw'0, hw'mono, hw'le, hw'pt, hw'seg, hw'fin⟩ :=
        ih ⟨i.val + 1, by omega⟩ hd1 y hle hFy
      have hv0 : v < w' ⟨0, by omega⟩ := by rw [hw'0]; exact hvy
      have hseg0 : ∀ r : M.carrier, v < r → r < w' ⟨0, by omega⟩ →
          (bf.segmentTypes ⟨i.val + 1, by omega⟩).eval_at M atomMap r := by
        intro r hr1 hr2
        rw [hw'0] at hr2
        exact hseg r hr1 hr2
      exact kampPrior_fChain_realize_cons M atomMap bf x i hd v w'
        hv0 hw'mono hw'le hw'pt hseg0 hw'seg hw'fin hvx halpha
    · -- Branch 2: `x_{i+1} < y` — the bound point itself is the next anchor; the segment
      -- type transfers to `(v, x_{i+1})` by restriction (`x_{i+1} ∈ (v, y)`).
      obtain ⟨w', hw'0, hw'mono, hw'le, hw'pt, hw'seg, hw'fin⟩ :=
        ih ⟨i.val + 1, by omega⟩ hd1 (x ⟨i.val + 1, by omega⟩) le_rfl
          (hF ⟨i.val + 1, by omega⟩)
      have hv0 : v < w' ⟨0, by omega⟩ := by
        rw [hw'0]; exact lt_of_le_of_lt hvx hxi1
      have hseg0 : ∀ r : M.carrier, v < r → r < w' ⟨0, by omega⟩ →
          (bf.segmentTypes ⟨i.val + 1, by omega⟩).eval_at M atomMap r := by
        intro r hr1 hr2
        rw [hw'0] at hr2
        exact hseg r hr1 (hr2.trans hgt)
      exact kampPrior_fChain_realize_cons M atomMap bf x i hd v w'
        hv0 hw'mono hw'le hw'pt hseg0 hw'seg hw'fin hvx halpha

/-- **Cor 5.4(1) ⇐, the within-bracket chain realizer** (Rabinovich 2014, §5, the pivotal
    observation's hard direction). From the F-chain firing at an increasing family of bound
    points `x 0 < … < x n` (each satisfying its `fChainFrom`), an actual witness family `w`
    is produced with `w 0 = x 0`, every `w i` dominated by its bound (`w i ≤ x i`), the point
    types at the witnesses, the interior segment types on consecutive gaps, and the final
    Until residue beyond `w n`. Instantiates the suffix engine at `i = 0`, `d = n`. -/
theorem kampPrior_fChain_realize {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1))
    (x : Fin (n + 1) → M.carrier)
    (hmono : ∀ i j : Fin (n + 1), i < j → x i < x j)
    (hF : ∀ i : Fin (n + 1), (bf.fChainFrom i).eval_at M atomMap (x i)) :
    ∃ w : Fin (n + 1) → M.carrier,
      w ⟨0, by omega⟩ = x ⟨0, by omega⟩ ∧
      (∀ i j : Fin (n + 1), i < j → w i < w j) ∧
      (∀ i : Fin (n + 1), w i ≤ x i) ∧
      (∀ i : Fin (n + 1), (bf.pointTypes i).eval_at M atomMap (w i)) ∧
      (∀ i : Fin n, ∀ r : M.carrier,
        w ⟨i.val, by omega⟩ < r → r < w ⟨i.val + 1, by omega⟩ →
        (bf.segmentTypes ⟨i.val + 1, by omega⟩).eval_at M atomMap r) ∧
      (∃ s : M.carrier, w ⟨n, by omega⟩ < s ∧
        ∀ r : M.carrier, w ⟨n, by omega⟩ < r → r < s →
        (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap r) := by
  obtain ⟨w, hw0, hmonoW, hle, hpt, hseg, hfin⟩ :=
    kampPrior_fChain_realize_from M atomMap bf x hmono hF n ⟨0, by omega⟩
      (by show 0 + n = n; omega) (x ⟨0, by omega⟩) le_rfl (hF ⟨0, by omega⟩)
  refine ⟨w, hw0, hmonoW, ?_, ?_, ?_, hfin⟩
  · intro i
    have hidx : (⟨(⟨0, by omega⟩ : Fin (n + 1)).val + i.val,
        by show 0 + i.val < n + 1; omega⟩ : Fin (n + 1)) = i := by
      ext; simp
    have := hle i
    rwa [hidx] at this
  · intro i
    have hidx : (⟨(⟨0, by omega⟩ : Fin (n + 1)).val + i.val,
        by show 0 + i.val < n + 1; omega⟩ : Fin (n + 1)) = i := by
      ext; simp
    have := hpt i
    rwa [hidx] at this
  · intro i r hr1 hr2
    have hidx : (⟨(⟨0, by omega⟩ : Fin (n + 1)).val + i.val + 1,
        by show 0 + i.val + 1 < n + 1 + 1; omega⟩ : Fin (n + 1 + 1))
        = ⟨i.val + 1, by omega⟩ := by
      ext; simp
    have := hseg i r hr1 hr2
    rwa [hidx] at this

/-- **Cor 5.4(1) ⇐, partial-bracket form**: the chain realizer plus the second two-way
    `min`/case-split at the right end (`z := s` if the final Until-witness `s ≤ z1`, else
    `z := z1` by segment restriction) produces an actual within-bracket witness
    `z ∈ (z0, z1]` with `bf.holds z0 z` — the bounded resolution of the F-chain
    Until-unboundedness obstruction recorded at EANegation.lean:1249. -/
theorem kampPrior_fChain_realize_bracket {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z1 : M.carrier)
    (x : Fin (n + 1) → M.carrier)
    (hmono : ∀ i j : Fin (n + 1), i < j → x i < x j)
    (hlow : ∀ i : Fin (n + 1), z0 < x i)
    (hhigh : ∀ i : Fin (n + 1), x i < z1)
    (hF : ∀ i : Fin (n + 1), (bf.fChainFrom i).eval_at M atomMap (x i))
    (hseg0 : ∀ r : M.carrier, z0 < r → r < x ⟨0, by omega⟩ →
      (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap r) :
    ∃ z : M.carrier, z0 < z ∧ z ≤ z1 ∧ bf.holds M atomMap z0 z := by
  obtain ⟨w, hw0, hmonoW, hle, hpt, hseg, s, hws, hsegfin⟩ :=
    kampPrior_fChain_realize M atomMap bf x hmono hF
  -- shared facts about the witness family
  have hz0w : ∀ i : Fin (n + 1), z0 < w i := by
    intro i
    have h0 : z0 < w ⟨0, by omega⟩ := by rw [hw0]; exact hlow ⟨0, by omega⟩
    rcases Nat.eq_zero_or_pos i.val with hi | hi
    · have : i = ⟨0, by omega⟩ := by ext; omega
      rw [this]; exact h0
    · exact h0.trans (hmonoW ⟨0, by omega⟩ i (by rw [Fin.lt_def]; simpa using hi))
  have hwn : ∀ i : Fin (n + 1), w i ≤ w ⟨n, by omega⟩ := by
    intro i
    rcases Nat.lt_or_ge i.val n with hi | hi
    · exact le_of_lt (hmonoW i ⟨n, by omega⟩ (by rw [Fin.lt_def]; simpa using hi))
    · have : i = ⟨n, by omega⟩ := by ext; simp; omega
      rw [this]
  have hseg0w : ∀ r : M.carrier, z0 < r → r < w ⟨0, by omega⟩ →
      (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap r := by
    intro r hr1 hr2
    rw [hw0] at hr2
    exact hseg0 r hr1 hr2
  -- the second two-way `min`/case-split: `z := s` vs `z := z1`
  rcases le_or_gt s z1 with hsle | hsgt
  · -- Branch 1: the final Until-witness `s` is inside the bracket — `z := s`.
    refine ⟨s, (hz0w ⟨n, by omega⟩).trans hws, hsle, ?_⟩
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
    exact ⟨w, hmonoW, fun i => ⟨hz0w i, lt_of_le_of_lt (hwn i) hws⟩, hpt, hseg0w, hseg,
      hsegfin⟩
  · -- Branch 2: `z1 < s` — `z := z1`; the final segment restricts from `(w n, s)`.
    refine ⟨z1, (hlow ⟨0, by omega⟩).trans (hhigh ⟨0, by omega⟩), le_rfl, ?_⟩
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
    exact ⟨w, hmonoW, fun i => ⟨hz0w i, lt_of_le_of_lt (hle i) (hhigh i)⟩, hpt, hseg0w, hseg,
      fun r hr1 hr2 => hsegfin r hr1 (hr2.trans hsgt)⟩

/-! ### The σ-level fold assembly at the exterior anchor (mirror of the converter body) -/

/-- **Genuine realizer assembly** (Future): at an anchor `x1` where every bit-true fiber of
    `σ` is realized (`hfwd`) and every on-fiber realization is saturated back to a true bit
    (`hbwd`), the arity-4 realizer `hσ` folds up via `nf_eval_nfk_iff_efold` — atom layer from
    a designated bit-true fiber sub (`kvE_futAtom_of_bundle`), off-fiber falsity from
    admissibility. POSITIVE mirror of the `kvE_extNegFut_complete` body
    (ExteriorConverterK.lean:158–188); exact inverse of `kvE_futBundle_of_realizer`. -/
theorem kampPrior_futRealizer_assemble {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig (k + 1) 4) (x1 w x t : M.carrier)
    (hadm : kvE_futAdmissible σ = true)
    (s0 : NormalForm sig k 5) (hbit0 : σ.2 s0 = true) (hd0 : nfk_dropFresh s0 = σ.1)
    (hfwd : ∀ s : NormalForm sig k 5, σ.2 s = true →
      ∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hbwd : ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
      (∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
      σ.2 s = true) :
    nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨v0, hv0⟩ := hfwd s0 hbit0
  have hA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
    kvE_futAtom_of_bundle M σ v0 x1 w x t s0 hd0 hv0
  have hfib : ∀ sub : NormalForm sig k 5, nfk_dropFresh sub = σ.1 →
      ((∃ y : M.carrier, nf_eval_nf M k 5
        (Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) sub) ↔
        σ.2 sub = true) :=
    fun sub hd => ⟨fun hex => hbwd sub hd hex, fun hbit => hfwd sub hbit⟩
  exact (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mpr
    ⟨⟨hA, hfib⟩, fun sub hne => kvE_futAdmissible_offFiber σ hadm sub hne⟩

/-- **Genuine realizer assembly** (Past): the mirror of `kampPrior_futRealizer_assemble` at a
    left exterior anchor `x1 < x`, via `kvE_pastAtom_of_bundle`/`kvE_pastAdmissible_offFiber`.
    Exact inverse of `kvE_pastBundle_of_realizer`. -/
theorem kampPrior_pastRealizer_assemble {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig (k + 1) 4) (x1 w x t : M.carrier)
    (hadm : kvE_pastAdmissible σ = true)
    (s0 : NormalForm sig k 5) (hbit0 : σ.2 s0 = true) (hd0 : nfk_dropFresh s0 = σ.1)
    (hfwd : ∀ s : NormalForm sig k 5, σ.2 s = true →
      ∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hbwd : ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
      (∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
      σ.2 s = true) :
    nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨v0, hv0⟩ := hfwd s0 hbit0
  have hA : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
    kvE_pastAtom_of_bundle M σ v0 x1 w x t s0 hd0 hv0
  have hfib : ∀ sub : NormalForm sig k 5, nfk_dropFresh sub = σ.1 →
      ((∃ y : M.carrier, nf_eval_nf M k 5
        (Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) sub) ↔
        σ.2 sub = true) :=
    fun sub hd => ⟨fun hex => hbwd sub hd hex, fun hbit => hfwd sub hbit⟩
  exact (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mpr
    ⟨⟨hA, hfib⟩, fun sub hne => kvE_pastAdmissible_offFiber σ hadm sub hne⟩

/-! ### The realizer drivers: destructor-selected anchor + `hσ` from the positive form -/

/-- **The Future realizer driver** (task 358 Phase 2): the POSITIVE-existence reading of the
    `kvE_extNegFut_complete` body. From the positive local-existence form `kvE_futPos P σ`
    firing at `t`, the landed Cor 5.4 chain destructor (`kvE_futChainDestructG`) reconstructs
    the SELECTED exterior anchor `x1 > t` with the endpoint description, and the genuine
    realizer `hσ` folds up at that anchor via `kampPrior_futRealizer_assemble` (the at-anchor
    transfer entering through `hreal`/`hsat`, the shapes `kvE_futBundle_of_realizer` proves
    sound). Emits admissibility, the anchor, the endpoint description, and `hσ`. -/
theorem kampPrior_futRealizer_of_pos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t : M.carrier)
    (hreal : ∀ x1 : M.carrier, t < x1 → ∀ s : NormalForm sig k 5, σ.2 s = true →
      ∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hsat : ∀ x1 : M.carrier, t < x1 →
      temporal_truth M atomMap x1 (kvE_futEnd P σ) →
      ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
        (∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
        σ.2 s = true)
    (hpos : temporal_truth M atomMap t (kvE_futPos P σ)) :
    ∃ x1 : M.carrier, t < x1 ∧
      temporal_truth M atomMap x1 (kvE_futEnd P σ) ∧
      nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  by_cases hadm : kvE_futAdmissible σ = true
  · -- admissible: extract a chain and reconstruct the realizer at the selected anchor
    rw [kvE_futPos, if_pos hadm, formula_disjList_iff] at hpos
    obtain ⟨φ, hφmem, hφ⟩ := hpos
    obtain ⟨l, hlmem, rfl⟩ := List.mem_map.mp hφmem
    have hlperm : l.Perm (kvE_fiberZoneList σ kvE_futGapZone) :=
      List.mem_permutations.mp hlmem
    -- item ⇒ gap guard: each chain item is a gap fiber sub, so it enters the gap disjunction
    have himp : ∀ a ∈ l, ∀ r : M.carrier,
        temporal_truth M atomMap r (kvE_futItemShift P a) →
        temporal_truth M atomMap r (kvE_futGapD P σ) := by
      intro a ha r hr
      have hamem : a ∈ kvE_fiberZoneList σ kvE_futGapZone := hlperm.subset ha
      rw [kvE_futGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
      rw [kvE_futItemShift_correct P a M h_UZ h_SZ r] at hr
      obtain ⟨env, hev⟩ := hr
      exact ⟨a, hamem, env, hev⟩
    -- destruct the Cor 5.4 chain: the SELECTED exterior anchor
    obtain ⟨x1, htx1, hend, _hgap, _hocc⟩ :=
      kvE_futChainDestructG M atomMap (kvE_futItemShift P) (kvE_futEnd P σ)
        (kvE_futGapD P σ) l t himp hφ
    -- a reached endpoint forces the self-zone content nonempty ⇒ a bit-true sub exists
    have hend0 := hend
    rw [kvE_futEnd, formula_conjList_iff] at hend0
    have hself := hend0 (kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_futSelfZone)) (by simp)
    rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1] at hself
    obtain ⟨s0, hs0mem, _env0, _hs0ev⟩ := hself
    have hbit0 : σ.2 s0 = true := ((kvE_fiberZoneList_mem σ kvE_futSelfZone s0).mp hs0mem).1
    have hd0 : nfk_dropFresh s0 = σ.1 := kvE_futAdmissible_onFiber σ hadm s0 hbit0
    exact ⟨x1, htx1, hend,
      kampPrior_futRealizer_assemble M σ x1 w x t hadm s0 hbit0 hd0
        (fun s hs => hreal x1 htx1 s hs)
        (fun s hd hex => hsat x1 htx1 hend s hd hex)⟩
  · rw [kvE_futPos, if_neg hadm] at hpos
    exact hpos.elim

/-- **The Past realizer driver** (task 358 Phase 2): mirror of `kampPrior_futRealizer_of_pos`
    at the left anchor — `kvE_pastPos P σ` firing at `x` yields the destructor-selected
    exterior anchor `x1 < x`, the endpoint description, and the genuine realizer `hσ`. -/
theorem kampPrior_pastRealizer_of_pos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t : M.carrier)
    (hreal : ∀ x1 : M.carrier, x1 < x → ∀ s : NormalForm sig k 5, σ.2 s = true →
      ∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hsat : ∀ x1 : M.carrier, x1 < x →
      temporal_truth M atomMap x1 (kvE_pastEnd P σ) →
      ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
        (∃ v : M.carrier, nf_eval_nf M k 5
          (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
        σ.2 s = true)
    (hpos : temporal_truth M atomMap x (kvE_pastPos P σ)) :
    ∃ x1 : M.carrier, x1 < x ∧
      temporal_truth M atomMap x1 (kvE_pastEnd P σ) ∧
      nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  by_cases hadm : kvE_pastAdmissible σ = true
  · rw [kvE_pastPos, if_pos hadm, formula_disjList_iff] at hpos
    obtain ⟨φ, hφmem, hφ⟩ := hpos
    obtain ⟨l, hlmem, rfl⟩ := List.mem_map.mp hφmem
    have hlperm : l.Perm (kvE_fiberZoneList σ kvE_pastGapZone) :=
      List.mem_permutations.mp hlmem
    have himp : ∀ a ∈ l, ∀ r : M.carrier,
        temporal_truth M atomMap r (P.existF 4 (renameNF rot5Fwd rot5Bwd a)) →
        temporal_truth M atomMap r (kvE_pastGapD P σ) := by
      intro a ha r hr
      have hamem : a ∈ kvE_fiberZoneList σ kvE_pastGapZone := hlperm.subset ha
      rw [kvE_pastGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
      rw [P.correct 4 (renameNF rot5Fwd rot5Bwd a) M h_UZ h_SZ r] at hr
      obtain ⟨env, hev⟩ := hr
      exact ⟨a, hamem, env, (kvE_anchorBridge M env r a).mp hev⟩
    obtain ⟨x1, hx1x, hend, _hgap, _hocc⟩ :=
      kvE_pastChainDestructG M atomMap (fun s => P.existF 4 (renameNF rot5Fwd rot5Bwd s))
        (kvE_pastEnd P σ) (kvE_pastGapD P σ) l x himp hφ
    have hend0 := hend
    rw [kvE_pastEnd, formula_conjList_iff] at hend0
    have hself := hend0 (kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_pastSelfZone)) (by simp)
    rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1] at hself
    obtain ⟨s0, hs0mem, _env0, _hs0ev⟩ := hself
    have hbit0 : σ.2 s0 = true := ((kvE_fiberZoneList_mem σ kvE_pastSelfZone s0).mp hs0mem).1
    have hd0 : nfk_dropFresh s0 = σ.1 := kvE_pastAdmissible_onFiber σ hadm s0 hbit0
    exact ⟨x1, hx1x, hend,
      kampPrior_pastRealizer_assemble M σ x1 w x t hadm s0 hbit0 hd0
        (fun s hs => hreal x1 hx1x s hs)
        (fun s hd hex => hsat x1 hx1x hend s hd hex)⟩
  · rw [kvE_pastPos, if_neg hadm] at hpos
    exact hpos.elim

/-! **HOIST NOTE (task 309 Phase 21, 2026-07-14)**: the two ambient arm closures
(`kampPrior_case1_arm_k0`, task 358 Phase-5 reduced scope, landed commit 8a7d504ec; and
`kampPrior_case1_arm_k1`, task 309 Phase 20) were MOVED VERBATIM — statements, proofs, and
section narratives unchanged — above `nf_nvar_exist_all_depths` (the "Hoisted `| 1 =>`
arm-closure chain" section), so the `:361` k≤1 match narrowing can cite them without forward
references. This is the plan-v10 sanctioned hoist (Phase 21 forward-reference safety clause);
the 358 lemma moved verbatim, no proof edit. -/

end Bimodal.Metalogic.WeakCanonical.Kamp
