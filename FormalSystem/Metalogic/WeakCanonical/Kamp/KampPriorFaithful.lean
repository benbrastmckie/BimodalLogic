/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.KampPrior
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ArmLemmasFaithful
import FormalSystem.Metalogic.WeakCanonical.Kamp.ZetaUniformExtractFaithful

/-!
# The `kampPriorExpressiveCompleteness` spine at the faithful eq (5.2) carrier

The top of the expressive-completeness spine, restated with `SemanticPriorUZ` / `SemanticPriorSZ`
replaced by `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP` (`Kamp/KPlusFaithful.lean:320` and
its `Since`-dual) — Rabinovich 2014's eq (5.2), PDF p.8, at the source's own `K⁺` rather than at
this tree's `kplus`.

## The live carrier-consuming chain, in full

`kampPriorExpressiveCompleteness` (`KampPrior.lean:672`) reaches the completeness carrier through
exactly seven declarations, and this module restates all seven:

```
kampPriorExpressiveCompleteness            (KampPrior.lean:672)
  └─ nfCharacterizableTemporalPrior        (:589)
       ├─ nf_depth0_char_formula_correct_arity1  (:182)  — carrier-free
       ├─ nf_succ_char_formula_correct           (:91)
       └─ nfNvarExistAllDepthsFn / _correct      (:549, :557)
            └─ nf_nvar_exist_all_depths          (:363)
                 ├─ nf_nvar_exist_depth0_tl_fn_correct   — carrier-free
                 ├─ kampPrior_case1_arm_k0     (:288)  →  the three k = 0 arms
                 ├─ kampPrior_case1_arm_k1     (:318)  →  the three k = 1 arms
                 └─ kampArm_zeta               (ZetaUniformExtract.lean:769)   [k ≥ 2]
```

The three leaves are all landed at the faithful carrier already: the six arm lemmas in
`NfMultiAnchorBridge/ArmLemmasFaithful.lean`, and `kampArm_zeta_faithful`
(`ZetaUniformExtractFaithful.lean:522`). Nothing below is a new proof — each declaration re-runs
its attained original's body with faithful leaves substituted.

`kampPrior_case1_trichotomy_assemble` (`KampPrior.lean:266`) needs no sibling: it takes the three
disjunct biconditionals as plain hypotheses and mentions no carrier, so it is reused verbatim at
both `k = 0` and `k = 1`.

## The site/coverage probe lemmas are not on this path

`KampPrior.lean` carries 43 carrier binder lines, but the ones below `:672` —
`kampPrior_site_*`, `kampPriorExistProviders*`, `kampPrior_fChain_*` — sit *after*
`kampPriorExpressiveCompleteness` in the file and are consumed by nothing on this chain. They are
the Phase-15 verdict record. They are deliberately **not** re-based here: doing so would add
binder lines to the tree without moving the obligation, and they are not part of the spine.

## The two `k = 1` off-diagonal arm formulas are different terms

`kampPrior_case1_arm_k1_faithful` below assembles `kampArmPastK1Faithful` /
`kampArmFutureK1Faithful` rather than `kampArmPastK1` / `kampArmFutureK1`, because their population
folds negate with `VVecEA2.negFixFaithful` — see `ArmLemmasFaithful.lean`'s header for why that is
forced rather than chosen. The diagonal arm formula `kampArmDiagK1` is literally the same term.
Consequently the witness formula produced by `kampPriorExpressiveCompletenessFaithful` is *not* in
general syntactically equal to the one produced by `kampPriorExpressiveCompleteness`; only the
statements correspond.

## The `SUP` half

`HasFaithfulDedekindSUP` is threaded throughout and, as at the ζ wire and the population fold,
never consumed: `VVecEA2.negFixFaithful_iff` needs `HasFaithfulDedekindINF` alone. It is bound so
these statements stay shape-parallel with their attained originals and with the consuming
obligation `KampFaithfulExpressiveCompleteness`
(`WeakCanonical/PriorExpressivenessDense.lean:169`).

## Nothing is removed and nothing is renamed

`KampPrior.lean` is not edited. Every declaration here is an addition.

## Source status

The construction is Rabinovich, *A Proof of Kamp's Theorem* (2014): the normal-form depth
stratification is Def 3.1 (PDF p.4), the depth-`(k+1)` characteristic assembly and the
`nf_nvar_exist_all_depths` recursion implement Lemma 3.2(2) and Lemma 3.4 (pp.4-5), and the `k ≥ 2`
arm rides Def 4.1 / Prop 4.3 / Thm 4.4 (pp.5-6) through the ζ wire. `doets_lemma_1_1`, which
`kampPriorExpressiveCompleteness` uses for the backward direction, is Doets' lemma as this tree
records it. **The choice of carrier has no source**: Rabinovich draws no distinction between the
attained first-occurrence property and his own eq (5.2) dichotomy (PDF p.8), so the re-basing is
this tree's own work.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

/-! ## 1. The depth-`(k+1)` characteristic assembly -/

/-- **Correctness of `nfSuccCharFormula` at the faithful carrier** — the faithful sibling of
`nf_succ_char_formula_correct` (`KampPrior.lean:91`). Same formula, same proof; only the carrier
binders on `h_exist_correct` and on the conclusion move. -/
theorem nf_succ_char_formula_correct_faithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (exist_tl_fn : NormalForm sig k 2 → Formula)
    (h_exist_correct : ∀ (sub_nf : NormalForm sig k 2)
      (M : OrderedMonadicStructure sig)
      (_h_INF : HasFaithfulDedekindINF M atomMap)
      (_h_SUP : HasFaithfulDedekindSUP M atomMap)
      (t : M.carrier),
      TemporalTruth M atomMap t (exist_tl_fn sub_nf) ↔
      ∃ x : M.carrier, NfEvalNf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
    (nf : NormalForm sig (k + 1) 1)
    (M : OrderedMonadicStructure sig)
    (h_INF : HasFaithfulDedekindINF M atomMap)
    (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (nfSuccCharFormula atomMap h_surj exist_tl_fn nf) ↔
    NfEvalNf M (k + 1) 1 (fun _ => t) nf := by
  simp only [nfSuccCharFormula]
  rw [formula_conjList_iff]
  change _ ↔ (∀ (a : AtomKind sig 1), AtomEval M (fun _ => t) a ↔ (nf.1 a = true)) ∧
    (∀ (sub_nf : NormalForm sig k 2),
      (∃ (x : M.carrier), NfEvalNf M k 2 (Fin.cons x (fun _ => t)) sub_nf) ↔
        (nf.2 sub_nf = true))
  have quant_mem : ∀ sub_nf : NormalForm sig k 2,
      nfQuantClauseTl (exist_tl_fn sub_nf) (nf.2 sub_nf) ∈
        List.map (fun sub_nf => nfQuantClauseTl (exist_tl_fn sub_nf) (nf.2 sub_nf))
          Finset.univ.toList :=
    fun sub_nf => List.mem_map.mpr
      ⟨sub_nf, Finset.mem_toList.mpr (Finset.mem_univ sub_nf), rfl⟩
  constructor
  · intro h_all
    constructor
    · have h_atom := (nf_depth0_char_formula_correct M atomMap h_surj _ t).mp
        (h_all _ (.head _))
      intro a
      obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
      simp only [AtomEval]
      exact h_atom p
    · intro sub_nf
      have h_clause := h_all _ (.tail _ (quant_mem sub_nf))
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _
        (h_exist_correct sub_nf M h_INF h_SUP t)] at h_clause
      exact h_clause
  · intro ⟨h_atoms, h_quants⟩ φ h_mem
    cases h_mem with
    | head =>
      refine (nf_depth0_char_formula_correct M atomMap h_surj _ t).mpr ?_
      intro p
      exact (h_atoms (.pred p ⟨0, by omega⟩))
    | tail _ h_tail =>
      obtain ⟨sub_nf, _, rfl⟩ := List.mem_map.mp h_tail
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _
        (h_exist_correct sub_nf M h_INF h_SUP t)]
      exact h_quants sub_nf

/-! ## 2. The two per-depth arm closures -/

/-- **Ambient-`k = 0` arm closure at the faithful carrier** — the faithful sibling of
`kampPrior_case1_arm_k0` (`KampPrior.lean:288`). The arm formula is literally the same
`Formula.or` of the three `k = 0` arm formulas: those are `M`-independent by construction and
unchanged by the re-base. -/
theorem kampPrior_case1_arm_k0_faithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (_h_INF : HasFaithfulDedekindINF M atomMap)
        (_h_SUP : HasFaithfulDedekindSUP M atomMap)
        (t : M.carrier),
        TemporalTruth M atomMap t A ↔
        ∃ env : Fin 1 → M.carrier, NfEvalNf M 1 2 (insertEnv env t) sub_nf := by
  refine ⟨Formula.or (kampArmPastK0 atomMap h_surj sub_nf)
    (Formula.or (kampArmDiagK0 atomMap h_surj sub_nf)
      (kampArmFutureK0 atomMap h_surj sub_nf)), ?_⟩
  intro M h_INF h_SUP t
  exact kampPrior_case1_trichotomy_assemble atomMap M 0 sub_nf t
    (kampArmPastK0 atomMap h_surj sub_nf)
    (kampArmDiagK0 atomMap h_surj sub_nf)
    (kampArmFutureK0 atomMap h_surj sub_nf)
    (kampArm_past_k0_correct_faithful atomMap h_surj sub_nf M h_INF h_SUP t)
    (kampArm_diag_k0_correct_faithful atomMap h_surj sub_nf M h_INF h_SUP t)
    (kampArm_future_k0_correct_faithful atomMap h_surj sub_nf M h_INF h_SUP t)

/-- **Ambient-`k = 1` arm closure at the faithful carrier** — the faithful sibling of
`kampPrior_case1_arm_k1` (`KampPrior.lean:318`). Unlike the `k = 0` case the arm formula is a
**different term**: the two off-diagonal arms carry the `negFixFaithful` population fold. The
diagonal arm formula `kampArmDiagK1` is unchanged. -/
theorem kampPrior_case1_arm_k1_faithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 2 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (_h_INF : HasFaithfulDedekindINF M atomMap)
        (_h_SUP : HasFaithfulDedekindSUP M atomMap)
        (t : M.carrier),
        TemporalTruth M atomMap t A ↔
        ∃ env : Fin 1 → M.carrier, NfEvalNf M 2 2 (insertEnv env t) sub_nf := by
  refine ⟨Formula.or (kampArmPastK1Faithful atomMap h_surj sub_nf)
    (Formula.or (kampArmDiagK1 atomMap h_surj sub_nf)
      (kampArmFutureK1Faithful atomMap h_surj sub_nf)), ?_⟩
  intro M h_INF h_SUP t
  exact kampPrior_case1_trichotomy_assemble atomMap M 1 sub_nf t
    (kampArmPastK1Faithful atomMap h_surj sub_nf)
    (kampArmDiagK1 atomMap h_surj sub_nf)
    (kampArmFutureK1Faithful atomMap h_surj sub_nf)
    (kampArm_past_k1_correct_faithful atomMap h_surj sub_nf M h_INF h_SUP t)
    (kampArm_diag_k1_correct_faithful atomMap h_surj sub_nf M h_INF h_SUP t)
    (kampArm_future_k1_correct_faithful atomMap h_surj sub_nf M h_INF h_SUP t)

/-! ## 3. The all-depth all-arity existential conversion -/

/-- **All-depth all-arity existential conversion at the faithful carrier** — the faithful sibling
of `nf_nvar_exist_all_depths` (`KampPrior.lean:363`). Structure identical to the original: `Nat`
recursion on the depth, the `n ≤ 1` domain restriction matched alongside `n` so the arity-`≥ 2` arm
is discharged by the restriction rather than left open (`sorryAx` is tracked per-declaration, not
per-path), and the `| 1 =>` arm split three ways — `k = 0`, `k = 1`, and the ζ wire for `k ≥ 2`. -/
theorem nf_nvar_exist_all_depths_faithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → (n : Nat) → (hn : n ≤ 1) → (sub_nf : NormalForm sig k (n + 1)) →
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (_h_INF : HasFaithfulDedekindINF M atomMap)
          (_h_SUP : HasFaithfulDedekindSUP M atomMap)
          (t : M.carrier),
          TemporalTruth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, NfEvalNf M k (n + 1) (insertEnv env t) sub_nf
  | 0, n, _hn, sub_nf =>
    ⟨nfNvarExistDepth0TlFn atomMap h_surj n sub_nf,
      fun M _ _ t => nf_nvar_exist_depth0_tl_fn_correct atomMap h_surj n sub_nf M t⟩
  | k + 1, n, hn, sub_nf =>
    have ih_exist_1 : ∀ (sub_nf' : NormalForm sig k 2),
        ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig)
          (h_INF : HasFaithfulDedekindINF M atomMap)
          (h_SUP : HasFaithfulDedekindSUP M atomMap)
          (t : M.carrier),
          TemporalTruth M atomMap t A ↔
          ∃ x : M.carrier, NfEvalNf M k 2 (Fin.cons x (fun _ => t)) sub_nf' :=
      fun sub_nf' => by
        have h := nf_nvar_exist_all_depths_faithful atomMap h_surj k 1 (by omega) sub_nf'
        obtain ⟨A, hA⟩ := h
        refine ⟨A, fun M h_INF h_SUP t => ?_⟩
        rw [hA M h_INF h_SUP t]
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

    let exist_tl_fn_k : NormalForm sig k 2 → Formula :=
      fun sub_nf' => (ih_exist_1 sub_nf').choose

    have exist_tl_fn_k_correct : ∀ (sub_nf' : NormalForm sig k 2)
        (M : OrderedMonadicStructure sig)
        (h_INF : HasFaithfulDedekindINF M atomMap)
        (h_SUP : HasFaithfulDedekindSUP M atomMap)
        (t : M.carrier),
        TemporalTruth M atomMap t (exist_tl_fn_k sub_nf') ↔
        ∃ x : M.carrier, NfEvalNf M k 2 (Fin.cons x (fun _ => t)) sub_nf' :=
      fun sub_nf' => (ih_exist_1 sub_nf').choose_spec

    let char_k1 : NormalForm sig (k + 1) 1 → Formula :=
      fun nf' => nfSuccCharFormula atomMap h_surj exist_tl_fn_k nf'

    have char_k1_correct : ∀ (nf' : NormalForm sig (k + 1) 1)
        (M : OrderedMonadicStructure sig)
        (h_INF : HasFaithfulDedekindINF M atomMap)
        (h_SUP : HasFaithfulDedekindSUP M atomMap)
        (t : M.carrier),
        TemporalTruth M atomMap t (char_k1 nf') ↔
        NfEvalNf M (k + 1) 1 (fun _ => t) nf' :=
      fun nf' M h_INF h_SUP t =>
        nf_succ_char_formula_correct_faithful atomMap h_surj exist_tl_fn_k
          (fun sub_nf' M' h_INF' h_SUP' t' =>
            exist_tl_fn_k_correct sub_nf' M' h_INF' h_SUP' t')
          nf' M h_INF h_SUP t

    match n, hn, sub_nf with
    | 0, _, sub_nf =>
      ⟨char_k1 sub_nf, fun M h_INF h_SUP t => by
        rw [char_k1_correct sub_nf M h_INF h_SUP t]
        constructor
        · intro h; exact ⟨Fin.elim0, by rwa [insertEnv_zero]⟩
        · rintro ⟨env, h_env⟩
          have : insertEnv env t = fun _ => t := by
            funext ⟨i, hi⟩; simp [insertEnv]
          rwa [this] at h_env⟩
    | 1, _, sub_nf =>
      match k, sub_nf with
      | 0, sub_nf => kampPrior_case1_arm_k0_faithful atomMap h_surj sub_nf
      | 1, sub_nf => kampPrior_case1_arm_k1_faithful atomMap h_surj sub_nf
      | _k + 2, sub_nf =>
        (kampArm_zeta_faithful atomMap h_surj sub_nf).imp fun _A hA M h_INF h_SUP t => by
          rw [hA M h_INF h_SUP t]
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
      absurd hn2 (by omega)

/-- Convenience wrapper at the faithful carrier — the faithful sibling of
`nfNvarExistAllDepthsFn` (`KampPrior.lean:549`). -/
noncomputable def nfNvarExistAllDepthsFnFaithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k n : Nat) (hn : n ≤ 1) (sub_nf : NormalForm sig k (n + 1)) : Formula :=
  (nf_nvar_exist_all_depths_faithful atomMap h_surj k n hn sub_nf).choose

/-- Correctness of the convenience wrapper at the faithful carrier — the faithful sibling of
`nf_nvar_exist_all_depths_fn_correct` (`KampPrior.lean:557`). -/
theorem nf_nvar_exist_all_depths_fn_correct_faithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k n : Nat) (hn : n ≤ 1) (sub_nf : NormalForm sig k (n + 1))
    (M : OrderedMonadicStructure sig)
    (h_INF : HasFaithfulDedekindINF M atomMap)
    (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (nfNvarExistAllDepthsFnFaithful atomMap h_surj k n hn sub_nf) ↔
    ∃ env : Fin n → M.carrier, NfEvalNf M k (n + 1) (insertEnv env t) sub_nf :=
  (nf_nvar_exist_all_depths_faithful atomMap h_surj k n hn sub_nf).choose_spec M h_INF h_SUP t

/-! ## 4. NF-to-temporal translation and the main theorem -/

/-- **Depth-`k` arity-1 NF characterizability at the faithful carrier** — the faithful sibling of
`nfCharacterizableTemporalPrior` (`KampPrior.lean:589`). -/
noncomputable def nfCharacterizableTemporalPriorFaithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (nf : NormalForm sig k 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_INF : HasFaithfulDedekindINF M atomMap)
        (_h_SUP : HasFaithfulDedekindSUP M atomMap)
        (t : M.carrier),
        TemporalTruth M atomMap t A ↔
        NfEvalNf M k 1 (fun _ => t) nf } := by
  induction k with
  | zero =>
    exact ⟨Separation.nfDepth0CharFormula atomMap h_surj nf,
      fun M _ _ t => nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf t⟩
  | succ k _ih =>
    let exist_tl_fn := nfNvarExistAllDepthsFnFaithful atomMap h_surj k 1 (by omega)
    have exist_tl_fn_correct : ∀ (sub_nf : NormalForm sig k 2)
        (M : OrderedMonadicStructure sig)
        (h_INF : HasFaithfulDedekindINF M atomMap)
        (h_SUP : HasFaithfulDedekindSUP M atomMap)
        (t : M.carrier),
        TemporalTruth M atomMap t (exist_tl_fn sub_nf) ↔
        ∃ x : M.carrier, NfEvalNf M k 2 (Fin.cons x (fun _ => t)) sub_nf := by
      intro sub_nf M h_INF h_SUP t
      rw [nf_nvar_exist_all_depths_fn_correct_faithful atomMap h_surj k 1 (by omega)
        sub_nf M h_INF h_SUP t]
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
    exact ⟨nfSuccCharFormula atomMap h_surj exist_tl_fn nf,
      fun M h_INF h_SUP t =>
        nf_succ_char_formula_correct_faithful atomMap h_surj exist_tl_fn
          (fun sub_nf M' h_INF' h_SUP' t' =>
            exist_tl_fn_correct sub_nf M' h_INF' h_SUP' t')
          nf M h_INF h_SUP t⟩

/-- **`{U,S}` expressive completeness at the faithful eq (5.2) carrier** — the faithful sibling of
`kampPriorExpressiveCompleteness` (`KampPrior.lean:672`), and the witness that discharges
`KampFaithfulExpressiveCompleteness` (`WeakCanonical/PriorExpressivenessDense.lean:169`).

Proof structure identical to the original — set `k = quantifierDepth psi`, characterize each
depth-`k` NF, take the disjunction over the NFs consistent with `psi`, and transfer along
`doets_lemma_1_1` in the backward direction. Only the carrier hypotheses and the characteristic
formulas beneath them change. -/
noncomputable def kampPriorExpressiveCompletenessFaithful
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_INF : HasFaithfulDedekindINF M atomMap)
        (_h_SUP : HasFaithfulDedekindSUP M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        TemporalTruth M atomMap t A } := by
  set k := psi.quantifierDepth with hk_def
  have nf_char := fun nf => nfCharacterizableTemporalPriorFaithful atomMap h_surj k nf
  let char_f : NormalForm sig k 1 → Formula :=
    fun nf => (nf_char nf).val
  have char_correct : ∀ (nf : NormalForm sig k 1)
      (M : OrderedMonadicStructure sig)
      (h_INF : HasFaithfulDedekindINF M atomMap)
      (h_SUP : HasFaithfulDedekindSUP M atomMap)
      (t : M.carrier),
      TemporalTruth M atomMap t (char_f nf) ↔
      NfEvalNf M k 1 (fun _ => t) nf :=
    fun nf M h_INF h_SUP t => (nf_char nf).property M h_INF h_SUP t
  let good_prop : NormalForm sig k 1 → Prop :=
    fun nf => ∃ (M : OrderedMonadicStructure sig) (t : M.carrier),
      NfEvalNf M k 1 (fun _ => t) nf ∧ eval M (fun _ => t) psi
  let all_nfs := (Fintype.elems (α := NormalForm sig k 1)).val.toList
  let good_formulas := all_nfs.filterMap (fun nf =>
    if @decide (good_prop nf) (Classical.dec _) then some (char_f nf) else none)
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
  have nf_determines_psi : ∀ (nf : NormalForm sig k 1)
      (M₁ M₂ : OrderedMonadicStructure sig) (t₁ : M₁.carrier) (t₂ : M₂.carrier),
      NfEvalNf M₁ k 1 (fun _ => t₁) nf →
      NfEvalNf M₂ k 1 (fun _ => t₂) nf →
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
  refine ⟨Separation.formulaDisjList good_formulas, fun M h_INF h_SUP t => ?_⟩
  rw [Separation.formula_disjList_iff]
  constructor
  · intro h_psi
    set nf_M := nfCharacteristic M k 1 (fun _ => t)
    have h_nf_M := nf_characteristic_satisfies M k 1 (fun _ => t)
    have h_char_eval := (char_correct nf_M M h_INF h_SUP t).mpr h_nf_M
    have h_good : good_prop nf_M := ⟨M, t, h_nf_M, h_psi⟩
    have h_in : char_f nf_M ∈ good_formulas := by
      rw [mem_good_iff]
      exact ⟨nf_M, Multiset.mem_toList.mpr (Fintype.complete nf_M), h_good, rfl⟩
    exact ⟨char_f nf_M, h_in, h_char_eval⟩
  · rintro ⟨A, hA_mem, hA_eval⟩
    rw [mem_good_iff] at hA_mem
    obtain ⟨nf, _, h_good, rfl⟩ := hA_mem
    have h_nf_eval := (char_correct nf M h_INF h_SUP t).mp hA_eval
    obtain ⟨M', t', hM'_nf, hM'_psi⟩ := h_good
    exact (nf_determines_psi nf M' M t' t hM'_nf h_nf_eval).mp hM'_psi

end FormalSystem.Metalogic.WeakCanonical.Kamp
