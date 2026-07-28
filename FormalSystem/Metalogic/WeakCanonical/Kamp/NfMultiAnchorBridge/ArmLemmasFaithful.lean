/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregateOffDiagK1Faithful
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterfaceFaithful

/-!
# The six trichotomy arm lemmas at the faithful eq (5.2) carrier

The `k = 0` and `k = 1` arm closures of `nf_nvar_exist_all_depths`' `| 1 =>` arm, restated with
`SemanticPriorUZ` / `SemanticPriorSZ` replaced by `HasFaithfulDedekindINF` /
`HasFaithfulDedekindSUP` (`Kamp/KPlusFaithful.lean:320` and its `Since`-dual) — Rabinovich 2014's
eq (5.2), PDF p.8, at the source's own `K⁺`.

## What this module is, and what it is not

It is **restatement, not new proof content**. The gate answered in
`AggregateOffDiagK1Faithful.lean` established that the whole spine above the ζ wire touches the
completeness carrier at exactly one substantive step, and that step is discharged there. Every
declaration below re-runs its attained original's proof against a leaf that already exists at the
faithful carrier:

| this module's leaf consumer | landed faithful leaf it consumes |
|---|---|
| `CAggInt_clause_iff_faithful` | `bracketEndChar_kv_correct_one_prior_faithful` (`PriorInterfaceFaithful.lean:196`) |
| `aggPop1_correct_faithful`, `aggPop1F_correct_faithful` | `aggOdPopFold_iff_faithful` (`AggregateOffDiagK1Faithful.lean:89`) |
| the three `k = 0` arms | *nothing* — their attained originals never touch the carrier (see below) |

## The `k = 0` arms bind the carrier but never use it

`kampArm_past_k0_correct`, `kampArm_diag_k0_correct` and `kampArm_future_k0_correct`
(`AggregateHookDischarge.lean:1702`, `:1725`, `:1745`) each open with `intro M _h_UZ _h_SZ t` and
then run a proof that mentions neither hypothesis: the arm formulas are `M`-independent by
construction, so `agg2Past_holdsRight_iff` / `agg2Diag_iff` / `agg2Fut_holdsLeft_iff` carry them
outright. Their faithful siblings below are therefore the same formulas with the same proofs,
re-bound. This is not an inference from the binders' underscore prefixes — it is what the proof
bodies do.

## The population fold is a *different term*, forced

`aggPop1Faithful` / `aggPop1FFaithful` negate their bit-false clauses with
`VVecEA2.negFixFaithful` rather than `VVecEA2.negFix`, exactly as `aggOdPopFold_iff_faithful`
requires and for the same reason recorded there: `negFix`'s correctness biconditional exists only
at the attained carrier, so a fold built from `negFix` cannot be read off at the faithful one. The
two folds carry the same Rabinovich content — Proposition 4.2, closure of `∃⃗∀`-formulas in at most
two free variables under negation, PDF p.6.

## The `SUP` half is again not consumed

As at the ζ wire and at the fold, `HasFaithfulDedekindSUP` is threaded and never used:
`negFixFaithful_iff` needs `HasFaithfulDedekindINF` alone. It is bound so the statements stay
shape-parallel with their attained originals and with the consuming obligation
`KampFaithfulExpressiveCompleteness` (`WeakCanonical/PriorExpressivenessDense.lean:169`). Dropping
it would strengthen these results; that is deliberately not done here, matching
`ZetaUniformExtractFaithful.lean` and `AggregateOffDiagK1Faithful.lean`.

## Nothing is removed and nothing is renamed

Every attained original stands byte-identical. One `private` helper of
`AggregateHookDischarge.lean` — the arity-2 constant-tail env identity `agg2_cons_diag_env`
(`:1447`) — is not visible here and is restated below as `aggDiagEnv2_const_faithful`; that is an
addition, not a promotion, and the original keeps its `private` modifier.

## Source status

The trichotomy split these arms realize is Rabinovich's Lemma 3.2(2) stratification (PDF p.4)
as consumed by this tree's `kampPrior_site_trichotomy`; the population fold implements Lemma 3.4
(PDF p.5) and Proposition 4.2 (PDF p.6). **The choice of carrier has no source**: Rabinovich draws
no distinction between the attained first-occurrence property and his own eq (5.2) dichotomy
(PDF p.8), so the re-basing is this tree's own work, as recorded in the sibling faithful modules.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

section ArmLemmasFaithful

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
variable (atomMap : Formula → sig.preds)
variable (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)

/-! ## 1. The three `k = 0` arms -/

/-- **k=0 past-arm hook discharge at the faithful carrier** — the faithful sibling of
`kampArm_past_k0_correct` (`AggregateHookDischarge.lean:1702`). Same formula `kampArmPastK0`,
same proof: the original's body uses neither Prior hypothesis. -/
theorem kampArm_past_k0_correct_faithful (sub_nf : NormalForm sig 1 2) :
    ∀ (M : OrderedMonadicStructure sig),
      HasFaithfulDedekindINF M atomMap → HasFaithfulDedekindSUP M atomMap →
      ∀ t : M.carrier,
      TemporalTruth M atomMap t (kampArmPastK0 atomMap h_surj sub_nf) ↔
        ∃ x, x < t ∧ NfEvalNf M 1 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro M _h_INF _h_SUP t
  unfold kampArmPastK0
  rw [VVecEA2.translateRight_correct]
  exact agg2Past_holdsRight_iff atomMap h_surj sub_nf M t

/-- **k=0 diagonal-arm hook discharge at the faithful carrier** — the faithful sibling of
`kampArm_diag_k0_correct` (`AggregateHookDischarge.lean:1725`). -/
theorem kampArm_diag_k0_correct_faithful (sub_nf : NormalForm sig 1 2) :
    ∀ (M : OrderedMonadicStructure sig),
      HasFaithfulDedekindINF M atomMap → HasFaithfulDedekindSUP M atomMap →
      ∀ t : M.carrier,
      TemporalTruth M atomMap t (kampArmDiagK0 atomMap h_surj sub_nf) ↔
        NfEvalNf M 1 2 (Fin.cons t (fun _ => t)) sub_nf := by
  intro M _h_INF _h_SUP t
  exact agg2Diag_iff atomMap h_surj sub_nf M t

/-- **k=0 future-arm hook discharge at the faithful carrier** — the faithful sibling of
`kampArm_future_k0_correct` (`AggregateHookDischarge.lean:1745`). -/
theorem kampArm_future_k0_correct_faithful (sub_nf : NormalForm sig 1 2) :
    ∀ (M : OrderedMonadicStructure sig),
      HasFaithfulDedekindINF M atomMap → HasFaithfulDedekindSUP M atomMap →
      ∀ t : M.carrier,
      TemporalTruth M atomMap t (kampArmFutureK0 atomMap h_surj sub_nf) ↔
        ∃ x, t < x ∧ NfEvalNf M 1 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro M _h_INF _h_SUP t
  unfold kampArmFutureK0
  rw [VVecEA2.translateLeft_correct]
  exact agg2Fut_holdsLeft_iff atomMap h_surj sub_nf M t

/-! ## 2. The `k = 1` diagonal seam

`aggPosDiagK1_correct` (`AggregateHookDischarge.lean:2028`) uses its Prior hypotheses at exactly
three places, all three of them the `k = 0` arm lemmas above; its off-gate branch (the fixpoint
refutation) is carrier-free. So the faithful sibling is the same proof with the three arms
swapped. -/

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Constant-tail env identity at arity 2 — a visible restatement of
`AggregateHookDischarge.lean`'s `private agg2_cons_diag_env` (`:1447`), which is not in scope
here. The original keeps its `private` modifier; this is an addition, not a promotion. -/
theorem aggDiagEnv2_const_faithful {α : Type _} (t : α) :
    (Fin.cons t (fun _ => t) : Fin 2 → α) = (fun _ => t) := by
  funext i
  refine Fin.cases rfl (fun j => ?_) i
  simp [Fin.cons_succ]

/-- **Per-`qnf` diagonal-seam positive clause, correct at the faithful carrier** — the faithful
sibling of `aggPosDiagK1_correct` (`AggregateHookDischarge.lean:2028`). Same formula
`aggPosDiagK1`; the on-gate branch routes through the three faithful `k = 0` arms above, the
off-gate branch is unchanged because it never mentions the carrier. -/
theorem aggPosDiagK1_correct_faithful (qnf : NormalForm sig 1 3)
    (M : OrderedMonadicStructure sig)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (aggPosDiagK1 atomMap h_surj qnf) ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons t (fun _ => t))) qnf := by
  unfold aggPosDiagK1
  by_cases hg : aggDiagGateK1 qnf
  · rw [dif_pos hg]
    have harm : TemporalTruth M atomMap t
        (Formula.or (kampArmPastK0 atomMap h_surj (aggCollapseK1 qnf))
          (Formula.or (kampArmDiagK0 atomMap h_surj (aggCollapseK1 qnf))
            (kampArmFutureK0 atomMap h_surj (aggCollapseK1 qnf)))) ↔
        ((∃ x, x < t ∧ NfEvalNf M 1 2 (Fin.cons x (fun _ => t)) (aggCollapseK1 qnf)) ∨
          NfEvalNf M 1 2 (Fin.cons t (fun _ => t)) (aggCollapseK1 qnf) ∨
          (∃ x, t < x ∧ NfEvalNf M 1 2 (Fin.cons x (fun _ => t)) (aggCollapseK1 qnf))) := by
      rw [temporal_truth_or, temporal_truth_or,
        kampArm_past_k0_correct_faithful atomMap h_surj (aggCollapseK1 qnf) M h_INF h_SUP t,
        kampArm_diag_k0_correct_faithful atomMap h_surj (aggCollapseK1 qnf) M h_INF h_SUP t,
        kampArm_future_k0_correct_faithful atomMap h_surj (aggCollapseK1 qnf) M h_INF h_SUP t]
    exact harm.trans ((exists_trichotomy_split
      (fun x => NfEvalNf M 1 2 (Fin.cons x (fun _ => t)) (aggCollapseK1 qnf)) t).symm.trans
      (exists_congr fun w => (agg_diag_collapse_k1 M qnf w t hg.1 hg.2).symm))
  · rw [dif_neg hg]
    constructor
    · intro h
      exact h.elim
    · rintro ⟨w, hw⟩
      exfalso
      apply hg
      have hwhole : NfEvalNf M 1 3 (Fin.cons w (Fin.cons t (fun _ => t))) qnf ↔
          (NfEvalNf M 0 3 (Fin.cons w (Fin.cons t (fun _ => t)))
              (qnf.1 : NormalForm sig 0 3) ∧
            (∀ σ : NormalForm sig 0 4,
              (∃ v : M.carrier, NfEvalNf M 0 4
                (Fin.cons v (Fin.cons w (Fin.cons t (fun _ => t)))) σ) ↔
                qnf.2 σ = true)) := Iff.rfl
      rw [hwhole] at hw
      obtain ⟨hatom, hq⟩ := hw
      have hE3 : ∀ i : Fin 3,
          (Fin.cons w (Fin.cons t (fun _ => t)) : Fin 3 → M.carrier)
            (aggExpand23 (aggMerge32 i)) =
          (Fin.cons w (Fin.cons t (fun _ => t)) : Fin 3 → M.carrier) i := by
        intro i
        match i with
        | ⟨0, _⟩ => rfl
        | ⟨1, _⟩ => rfl
        | ⟨2, _⟩ => rfl
      refine ⟨?_, ?_⟩
      · exact agg_rename_fixpoint_of_eval M aggExpand23 aggMerge32 aggMerge32_expand23
          (Fin.cons w (Fin.cons t (fun _ => t))) hE3
          (qnf.1 : NormalForm sig 0 3) hatom
      · intro σ hfix
        cases hb : qnf.2 σ with
        | false => rfl
        | true =>
          obtain ⟨v, hv⟩ := (hq σ).mpr hb
          refine absurd ?_ hfix
          show aggDupSub (aggCollapseSub σ) = σ
          refine agg_rename_fixpoint_of_eval M (liftIdx aggExpand23)
            (liftIdx aggMerge32) agg_liftMerge_liftExpand
            (Fin.cons v (Fin.cons w (Fin.cons t (fun _ => t)))) ?_ σ hv
          intro i
          refine Fin.cases ?_ ?_ i
          · rw [liftIdx_zero, liftIdx_zero]
          · intro j
            rw [liftIdx_succ, liftIdx_succ]
            simp only [Fin.cons_succ]
            exact hE3 j

/-- **k=1 diagonal-arm hook discharge at the faithful carrier** — the faithful sibling of
`kampArm_diag_k1_correct` (`AggregateHookDischarge.lean:2116`). Same formula `kampArmDiagK1`;
the per-`qnf` population literals route through `aggPosDiagK1_correct_faithful`. -/
theorem kampArm_diag_k1_correct_faithful (sub_nf : NormalForm sig 2 2) :
    ∀ (M : OrderedMonadicStructure sig),
      HasFaithfulDedekindINF M atomMap → HasFaithfulDedekindSUP M atomMap →
      ∀ t : M.carrier,
      TemporalTruth M atomMap t (kampArmDiagK1 atomMap h_surj sub_nf) ↔
        NfEvalNf M 2 2 (Fin.cons t (fun _ => t)) sub_nf := by
  intro M h_INF h_SUP t
  have hwhole : NfEvalNf M 2 2 (Fin.cons t (fun _ => t)) sub_nf ↔
      (NfEvalNf M 0 2 (Fin.cons t (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2) ∧
        (∀ qnf : NormalForm sig 1 3,
          (∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons t (fun _ => t))) qnf) ↔
            sub_nf.2 qnf = true)) := Iff.rfl
  rw [hwhole]
  unfold kampArmDiagK1
  rw [formula_conjList_iff]
  constructor
  · intro h
    constructor
    · have hatom := h _ List.mem_cons_self
      change NfEvalNf M 0 2 (Fin.cons t (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2)
      rw [aggDiagEnv2_const_faithful]
      exact (nf_char2_atom_part_correct M atomMap h_surj
        (sub_nf.1 : NormalForm sig 0 2) t).mp hatom
    · intro qnf
      have hcl := h _ (List.mem_cons_of_mem _ (List.mem_map_of_mem (show qnf ∈ _ by simp)))
      simp only [agg2Lit] at hcl
      cases hb : sub_nf.2 qnf with
      | true =>
        rw [if_pos hb] at hcl
        exact iff_of_true
          ((aggPosDiagK1_correct_faithful atomMap h_surj qnf M h_INF h_SUP t).mp hcl) rfl
      | false =>
        rw [if_neg (by simp [hb])] at hcl
        exact iff_of_false
          (fun hex => hcl
            ((aggPosDiagK1_correct_faithful atomMap h_surj qnf M h_INF h_SUP t).mpr hex))
          (by simp)
  · rintro ⟨hatom, hpop⟩
    intro f hf
    rcases List.mem_cons.mp hf with rfl | hf
    · rw [aggDiagEnv2_const_faithful] at hatom
      exact (nf_char2_atom_part_correct M atomMap h_surj
        (sub_nf.1 : NormalForm sig 0 2) t).mpr hatom
    · obtain ⟨qnf, -, rfl⟩ := List.mem_map.mp hf
      simp only [agg2Lit]
      cases hb : sub_nf.2 qnf with
      | true =>
        rw [if_pos rfl]
        exact (aggPosDiagK1_correct_faithful atomMap h_surj qnf M h_INF h_SUP t).mpr
          ((hpop qnf).mpr hb)
      | false =>
        rw [if_neg (by simp)]
        intro hpos
        have hbit := (hpop qnf).mp
          ((aggPosDiagK1_correct_faithful atomMap h_surj qnf M h_INF h_SUP t).mp hpos)
        rw [hb] at hbit
        exact Bool.noConfusion hbit

/-! ## 3. The dispatcher clause iffs

`CAggOd_clause_iff` (`AggregateOffDiagK1.lean:1164`) touches the carrier in exactly one of its six
branches — the interior channel, which delegates to `bracketEndChar_kv_correct_one_prior`. The
other five (`CExtPast`, `CAggPtX`, `CAggPtT`, `CExtFut`, and the 3-bot channel) are carrier-free
in their originals. -/

/-- **Interior clause iff at the faithful carrier** — the faithful sibling of
`CAggInt_clause_iff` (`AggregateOffDiagK1.lean:1097`), delegating to the landed
`bracketEndChar_kv_correct_one_prior_faithful` (`PriorInterfaceFaithful.lean:196`). -/
theorem CAggInt_clause_iff_faithful (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (hrow : aggOdRowInt qnf)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (x t : M.carrier) :
    (CAggInt atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  bracketEndChar_kv_correct_one_prior_faithful atomMap h_surj (aggOdCharF atomMap h_surj) rfl
    qnf hrow.1 hrow.2.1 hrow.2.2.1 hrow.2.2.2.1 hrow.2.2.2.2.1 hrow.2.2.2.2.2
    M h_INF h_SUP x t

/-- **The master clause iff at the faithful carrier** — the faithful sibling of
`CAggOd_clause_iff` (`AggregateOffDiagK1.lean:1164`). Only the interior branch changes. -/
theorem CAggOd_clause_iff_faithful (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (x t : M.carrier) (hxt : x < t) :
    (CAggOd atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  unfold CAggOd
  split_ifs with h1 h2 h3 h4 h5
  · exact CExtPast_clause_iff atomMap h_surj M qnf h1 x t hxt
  · exact CAggPtX_clause_iff atomMap h_surj M qnf h2 x t hxt
  · exact CAggInt_clause_iff_faithful atomMap h_surj M qnf h3 h_INF h_SUP x t
  · exact CAggPtT_clause_iff atomMap h_surj M qnf h4 x t hxt
  · exact CExtFut_clause_iff atomMap h_surj M qnf h5 x t hxt
  · constructor
    · rintro ⟨vea, hmem, -⟩
      exact (List.not_mem_nil hmem).elim
    · rintro ⟨w, hw⟩
      exact (aggOdZone3_bot_eval_false M qnf h1 h2 h3 h4 h5 x t hxt w hw).elim

/-- **The swapped master clause iff at the faithful carrier** — the faithful sibling of
`CAggOdSwap_clause_iff` (`AggregateOffDiagK1.lean:1342`). The swap transport
`aggOdSwap12_eval_iff` is carrier-free and is reused verbatim. -/
theorem CAggOdSwap_clause_iff_faithful (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (x t : M.carrier) (htx : t < x) :
    (CAggOd atomMap h_surj (renameNF aggOdSwap12 aggOdSwap12 qnf)).holds
        M atomMap t x ↔
      ∃ w : M.carrier,
        NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  (CAggOd_clause_iff_faithful atomMap h_surj M (renameNF aggOdSwap12 aggOdSwap12 qnf)
      h_INF h_SUP t x htx).trans
    (exists_congr fun w => aggOdSwap12_eval_iff M qnf w x t)

/-! ## 4. The `k = 1` population folds

These are new `VVecEA2` terms, not the attained ones: the bit-false clauses negate with
`VVecEA2.negFixFaithful` because `aggOdPopFold_iff_faithful` reads exactly that fold. See the
module header. -/

/-- **The k=1 aggregate population carrier at the faithful carrier** — `aggPop1`
(`AggregateOffDiagK1.lean:1264`) with `VVecEA2.negFix` replaced by
`VVecEA2.negFixFaithful`. Rabinovich Proposition 4.2, PDF p.6. -/
noncomputable def aggPop1Faithful (sub_nf : NormalForm sig 2 2) : VVecEA2 :=
  ((Finset.univ : Finset (NormalForm sig 1 3)).toList.map fun qnf =>
      if sub_nf.2 qnf then CAggOd atomMap h_surj qnf
      else (CAggOd atomMap h_surj qnf).negFixFaithful).foldr
    VVecEA2.conjFull VVecEA2.trivialTrue

/-- **Correctness of `aggPop1Faithful`** — the faithful sibling of `aggPop1_correct`
(`AggregateOffDiagK1.lean:1277`). Fold induction by `aggOdPopFold_iff_faithful`; per-`qnf` clause
by `CAggOd_clause_iff_faithful`. -/
theorem aggPop1_correct_faithful (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 2 2)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (x t : M.carrier) (h_lt : x < t) :
    (aggPop1Faithful atomMap h_surj sub_nf).holds M atomMap x t ↔
      ∀ qnf : NormalForm sig 1 3,
        ((∃ w : M.carrier,
            NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) ↔
          sub_nf.2 qnf = true) := by
  unfold aggPop1Faithful
  rw [aggOdPopFold_iff_faithful M h_INF h_SUP
      (CAggOd atomMap h_surj) sub_nf.2 x t h_lt]
  constructor
  · intro h qnf
    exact (CAggOd_clause_iff_faithful atomMap h_surj M qnf h_INF h_SUP x t h_lt).symm.trans
      (h qnf (Finset.mem_toList.mpr (Finset.mem_univ qnf)))
  · intro h qnf _
    exact (CAggOd_clause_iff_faithful atomMap h_surj M qnf h_INF h_SUP x t h_lt).trans (h qnf)

/-- **The future-arm k=1 population carrier at the faithful carrier** — `aggPop1F`
(`AggregateOffDiagK1.lean:1359`) with `negFix` replaced by `negFixFaithful`. -/
noncomputable def aggPop1FFaithful (sub_nf : NormalForm sig 2 2) : VVecEA2 :=
  ((Finset.univ : Finset (NormalForm sig 1 3)).toList.map fun qnf =>
      if sub_nf.2 qnf then
        CAggOd atomMap h_surj (renameNF aggOdSwap12 aggOdSwap12 qnf)
      else (CAggOd atomMap h_surj (renameNF aggOdSwap12 aggOdSwap12 qnf)).negFixFaithful).foldr
    VVecEA2.conjFull VVecEA2.trivialTrue

/-- **Correctness of `aggPop1FFaithful`** — the faithful sibling of `aggPop1F_correct`
(`AggregateOffDiagK1.lean:1370`). -/
theorem aggPop1F_correct_faithful (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 2 2)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (x t : M.carrier) (h_lt : t < x) :
    (aggPop1FFaithful atomMap h_surj sub_nf).holds M atomMap t x ↔
      ∀ qnf : NormalForm sig 1 3,
        ((∃ w : M.carrier,
            NfEvalNf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) ↔
          sub_nf.2 qnf = true) := by
  unfold aggPop1FFaithful
  rw [aggOdPopFold_iff_faithful M h_INF h_SUP
      (fun qnf => CAggOd atomMap h_surj (renameNF aggOdSwap12 aggOdSwap12 qnf))
      sub_nf.2 t x h_lt]
  constructor
  · intro h qnf
    exact (CAggOdSwap_clause_iff_faithful atomMap h_surj M qnf h_INF h_SUP x t h_lt).symm.trans
      (h qnf (Finset.mem_toList.mpr (Finset.mem_univ qnf)))
  · intro h qnf _
    exact (CAggOdSwap_clause_iff_faithful atomMap h_surj M qnf h_INF h_SUP x t h_lt).trans
      (h qnf)

/-! ## 5. The two off-diagonal `k = 1` arms -/

/-- **k=1 past arm formula at the faithful carrier** — `kampArmPastK1`
(`AggregateOffDiagK1.lean:1476`) over the faithful population fold. -/
noncomputable def kampArmPastK1Faithful (sub_nf : NormalForm sig 2 2) : Formula :=
  ((aggAtomK1Past atomMap h_surj sub_nf).conjFull
    (aggPop1Faithful atomMap h_surj sub_nf)).translateRight

/-- **k=1 past-arm hook discharge at the faithful carrier** — the faithful sibling of
`kampArm_past_k1_correct` (`AggregateOffDiagK1.lean:1488`). -/
theorem kampArm_past_k1_correct_faithful (sub_nf : NormalForm sig 2 2) :
    ∀ (M : OrderedMonadicStructure sig),
      HasFaithfulDedekindINF M atomMap → HasFaithfulDedekindSUP M atomMap →
      ∀ t : M.carrier,
      TemporalTruth M atomMap t (kampArmPastK1Faithful atomMap h_surj sub_nf) ↔
        ∃ x, x < t ∧ NfEvalNf M 2 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro M h_INF h_SUP t
  unfold kampArmPastK1Faithful
  rw [VVecEA2.translateRight_correct, aggOd_holdsRight_iff_holds]
  refine exists_congr fun x => and_congr_right fun hxt => ?_
  rw [VVecEA2.conjFull_iff,
      aggAtomK1Past_holds_iff atomMap h_surj M sub_nf x t hxt,
      aggPop1_correct_faithful atomMap h_surj M sub_nf h_INF h_SUP x t hxt]
  exact (aggOd_eval2_iff M sub_nf (Fin.cons x (fun _ => t))).symm

/-- **k=1 future arm formula at the faithful carrier** — `kampArmFutureK1`
(`AggregateOffDiagK1.lean:1506`) over the faithful population fold. -/
noncomputable def kampArmFutureK1Faithful (sub_nf : NormalForm sig 2 2) : Formula :=
  ((aggAtomK1Fut atomMap h_surj sub_nf).conjFull
    (aggPop1FFaithful atomMap h_surj sub_nf)).translateLeft

/-- **k=1 future-arm hook discharge at the faithful carrier** — the faithful sibling of
`kampArm_future_k1_correct` (`AggregateOffDiagK1.lean:1516`). -/
theorem kampArm_future_k1_correct_faithful (sub_nf : NormalForm sig 2 2) :
    ∀ (M : OrderedMonadicStructure sig),
      HasFaithfulDedekindINF M atomMap → HasFaithfulDedekindSUP M atomMap →
      ∀ t : M.carrier,
      TemporalTruth M atomMap t (kampArmFutureK1Faithful atomMap h_surj sub_nf) ↔
        ∃ x, t < x ∧ NfEvalNf M 2 2 (Fin.cons x (fun _ => t)) sub_nf := by
  intro M h_INF h_SUP t
  unfold kampArmFutureK1Faithful
  rw [VVecEA2.translateLeft_correct, aggOd_holdsLeft_iff_holds]
  refine exists_congr fun x => and_congr_right fun htx => ?_
  rw [VVecEA2.conjFull_iff,
      aggAtomK1Fut_holds_iff atomMap h_surj M sub_nf x t htx,
      aggPop1F_correct_faithful atomMap h_surj M sub_nf h_INF h_SUP x t htx]
  exact (aggOd_eval2_iff M sub_nf (Fin.cons x (fun _ => t))).symm

end ArmLemmasFaithful

end FormalSystem.Metalogic.WeakCanonical.Kamp
