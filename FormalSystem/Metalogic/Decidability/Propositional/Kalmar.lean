/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Propositional.PropForm
import FormalSystem.ProofSystem.Derivable
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Theorems.Propositional.Reasoning
import FormalSystem.Theorems.Combinators

/-!
# Kalmar - Kalmar-Style Tautology Soundness

This module proves the Kalmar-style soundness theorem for `PropForm.isTaut`: every
kernel-checked propositional tautology is object-level derivable, schematically in the
environment `env : Nat → Formula`.

## Weakening Infrastructure (verified reuse)

`DerivationTree.weakening` (`ProofSystem/Derivation.lean`) provides general context
weakening: `Γ ⊢[fc] φ → Γ ⊆ Δ → Δ ⊢[fc] φ`, for arbitrary `Γ Δ : Context = List Formula`.
`Derivable.weaken` (`ProofSystem/Derivable.lean:140`) covers the Prop-valued (`|-!`)
analogue. Both are used freely below (no additional weakening lemma is needed).

## Noncomputability

`deduction_theorem` is `noncomputable` (built on `Classical.propDecidable`), so this
entire module (Kalmar step, variable elimination, `tautology_derivable'`) is
`noncomputable`. `PropForm.isTaut` itself (in `PropForm.lean`) is fully computable —
the noncomputability is confined to the *soundness proof*, not the checker.
-/

namespace FormalSystem.Metalogic.Decidability.Propositional

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.Combinators

noncomputable section

/-! ## The One New Object-Level Lemma -/

/--
The single new Kalmar prerequisite: `⊢ φ.imp (ψ.neg.imp (φ.imp ψ).neg)`.

Proved via `ni` (negation introduction) applied to the context `[ψ.neg, φ]` extended by
`φ.imp ψ` (both `ψ.neg` and the modus-ponens consequence `ψ` are derivable there), then
`deduction_theorem` twice, eliminating the head variable each round (`ψ.neg` first, then
`φ`) so no context-permutation lemma is required.
-/
def negImpIntro (φ ψ : Formula) : ⊢ φ.imp (ψ.neg.imp (φ.imp ψ).neg) := by
  have h1 : ((φ.imp ψ) :: [ψ.neg, φ]) ⊢ ψ.neg := by
    apply DerivationTree.assumption
    simp
  have h2 : ((φ.imp ψ) :: [ψ.neg, φ]) ⊢ ψ := by
    have ha : ((φ.imp ψ) :: [ψ.neg, φ]) ⊢ (φ.imp ψ) := by
      apply DerivationTree.assumption
      simp
    have hb : ((φ.imp ψ) :: [ψ.neg, φ]) ⊢ φ := by
      apply DerivationTree.assumption
      simp
    exact DerivationTree.modus_ponens _ φ ψ ha hb
  have hstep : ([ψ.neg, φ] : Context) ⊢ (φ.imp ψ).neg :=
    FormalSystem.Theorems.Propositional.ni [ψ.neg, φ] (φ.imp ψ) ψ h1 h2
  have hstep2 : ([φ] : Context) ⊢ ψ.neg.imp (φ.imp ψ).neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [φ] ψ.neg ((φ.imp ψ).neg) hstep
  exact FormalSystem.Metalogic.Core.deductionTheorem [] φ (ψ.neg.imp (φ.imp ψ).neg) hstep2

/-! ## Literal Machinery -/

/-- The Kalmar "literal" denoted by a `PropForm` under valuation `v`: the reflected
formula itself if `v` makes it true, its negation otherwise. -/
def litDenote (env : Nat → Formula) (v : Nat → Bool) (f : PropForm) : Formula :=
  if f.eval v then f.denote env else (f.denote env).neg

/-- The Kalmar literal context: for each variable in `vars`, the literal (atom or its
negation) selected by `v`. -/
def litCtx (env : Nat → Formula) (v : Nat → Bool) (vars : List Nat) : Context :=
  vars.map (fun n => if v n then env n else (env n).neg)

@[simp] theorem litCtx_nil (env : Nat → Formula) (v : Nat → Bool) :
    litCtx env v [] = [] := rfl

@[simp] theorem litCtx_cons (env : Nat → Formula) (v : Nat → Bool) (n : Nat) (ns : List Nat) :
    litCtx env v (n :: ns) = (if v n then env n else (env n).neg) :: litCtx env v ns := rfl

theorem litDenote_of_true {env : Nat → Formula} {v : Nat → Bool} {f : PropForm}
    (h : f.eval v = true) : litDenote env v f = f.denote env := by
  unfold litDenote; simp [h]

theorem litDenote_of_false {env : Nat → Formula} {v : Nat → Bool} {f : PropForm}
    (h : f.eval v = false) : litDenote env v f = (f.denote env).neg := by
  unfold litDenote; simp [h]

@[simp] theorem litDenote_var (env : Nat → Formula) (v : Nat → Bool) (n : Nat) :
    litDenote env v (PropForm.var n) = if v n then env n else (env n).neg := by
  unfold litDenote
  by_cases hv : v n = true <;> simp [hv]

/-- Literal-membership lemma: if `n` occurs in `vars`, the literal for `.var n` is in the
literal context built from `vars`. -/
theorem litDenote_var_mem {env : Nat → Formula} {v : Nat → Bool} {vars : List Nat} {n : Nat}
    (h : n ∈ vars) : litDenote env v (PropForm.var n) ∈ litCtx env v vars := by
  have hval : litDenote env v (PropForm.var n)
      = (fun m => if v m then env m else (env m).neg) n := by
    simp [litDenote_var]
  rw [hval]
  exact List.mem_map_of_mem h

/-- Context-agreement lemma: `litCtx` is unchanged under a valuation update at a variable
not occurring in `vars`. Needed for head-variable elimination in the variable-elimination
argument (Phase 4). -/
theorem litCtx_update_not_mem {env : Nat → Formula} {v : Nat → Bool} {n : Nat} {b : Bool}
    {vars : List Nat} (h : n ∉ vars) :
    litCtx env (Function.update v n b) vars = litCtx env v vars := by
  unfold litCtx
  apply List.map_congr_left
  intro m hm
  have hmn : m ≠ n := by
    rintro rfl
    exact h hm
  simp [Function.update, hmn]

/-! ## Kalmar Step: The Main Induction -/

/--
The Kalmar step lemma: for any `PropForm` `f` whose variables are all covered by `vars`,
the literal context `litCtx env v vars` derives the literal `litDenote env v f`.

This is the hard core of the Kalmar argument, by structural induction on `f`:
- `var n`: the literal is an assumption (`litDenote_var_mem`).
- `fls`: `eval v fls = false` always, so the literal is `⊥.imp ⊥`, i.e. weakened `identity`.
- `imp f g`, `g.eval v = true`: from `IH_g : Γ ⊢ g.denote env`, `prop_s` + `mp` gives
  `Γ ⊢ (f.denote env).imp (g.denote env)`.
- `imp f g`, `f.eval v = false`: from `IH_f : Γ ⊢ (f.denote env).neg`, `efq_neg` + `mp`
  gives `Γ ⊢ (f.denote env).imp (g.denote env)`.
- `imp f g`, `f.eval v = true, g.eval v = false`: from `IH_f : Γ ⊢ f.denote env` and
  `IH_g : Γ ⊢ (g.denote env).neg`, `neg_imp_intro` + two `mp`s gives
  `Γ ⊢ ((f.denote env).imp (g.denote env)).neg`.
-/
def kalmarStep (f : PropForm) (env : Nat → Formula) (v : Nat → Bool) (vars : List Nat)
    (hsub : ∀ n, n ∈ f.vars → n ∈ vars) : (litCtx env v vars) ⊢ (litDenote env v f) := by
  induction f with
  | var n =>
      apply DerivationTree.assumption
      apply litDenote_var_mem
      exact hsub n (by simp)
  | fls =>
      have heval : PropForm.eval v PropForm.fls = false := rfl
      rw [litDenote_of_false heval]
      exact DerivationTree.weakening [] (litCtx env v vars) _
        (@identity FrameClass.Base Formula.bot) (List.nil_subset _)
  | imp f g ihf ihg =>
      have hsubf : ∀ n, n ∈ f.vars → n ∈ vars :=
        fun n hn => hsub n (PropForm.mem_vars_imp.mpr (Or.inl hn))
      have hsubg : ∀ n, n ∈ g.vars → n ∈ vars :=
        fun n hn => hsub n (PropForm.mem_vars_imp.mpr (Or.inr hn))
      have IHf := ihf hsubf
      have IHg := ihg hsubg
      rcases hgv : g.eval v with _ | _
      · -- g.eval v = false
        rcases hfv : f.eval v with _ | _
        · -- f.eval v = false: subcase 2
          rw [litDenote_of_true (show (PropForm.imp f g).eval v = true by simp [hfv])]
          rw [litDenote_of_false hfv] at IHf
          have hefq : (⊢ (f.denote env).neg.imp ((f.denote env).imp (g.denote env))) :=
            impOfNeg (f.denote env) (g.denote env)
          have hefq' := DerivationTree.weakening [] (litCtx env v vars) _ hefq (List.nil_subset _)
          exact DerivationTree.modus_ponens _ _ _ hefq' IHf
        · -- f.eval v = true, g.eval v = false: subcase 3
          rw [litDenote_of_false (show (PropForm.imp f g).eval v = false by simp [hfv, hgv])]
          rw [litDenote_of_true hfv] at IHf
          rw [litDenote_of_false hgv] at IHg
          have hni : (⊢ (f.denote env).imp
              ((g.denote env).neg.imp ((f.denote env).imp (g.denote env)).neg)) :=
            negImpIntro (f.denote env) (g.denote env)
          have hni' := DerivationTree.weakening [] (litCtx env v vars) _ hni (List.nil_subset _)
          have step1 := DerivationTree.modus_ponens _ _ _ hni' IHf
          exact DerivationTree.modus_ponens _ _ _ step1 IHg
      · -- g.eval v = true: subcase 1
        rw [litDenote_of_true (show (PropForm.imp f g).eval v = true by simp [hgv])]
        rw [litDenote_of_true hgv] at IHg
        have hs : (⊢ (g.denote env).imp ((f.denote env).imp (g.denote env))) :=
          DerivationTree.axiom [] _ (Axiom.prop_s (g.denote env) (f.denote env)) trivial
        have hs' := DerivationTree.weakening [] (litCtx env v vars) _ hs (List.nil_subset _)
        exact DerivationTree.modus_ponens _ _ _ hs' IHg

/-! ## Variable Elimination -/

/-- `PropForm.vars` is always duplicate-free (needed so the head-elimination step below
never re-eliminates the same variable). -/
theorem PropForm.vars_nodup (f : PropForm) : f.vars.Nodup := by
  cases f with
  | var n => simp [PropForm.vars]
  | fls => simp [PropForm.vars]
  | imp f g => simp [PropForm.vars, List.nodup_dedup]

/--
Eliminate every variable in `vars` from the literal context, given a derivation of `φ` from
every possible literal context over `vars`. Proceeds by head-elimination: for `n :: ns`,
instantiate the hypothesis at `v[n] := true` and `v[n] := false`, apply `deduction_theorem`
to each (turning the head literal into an implication — no context-permutation lemma
needed since `n` is always the head), then combine via `classical_merge`.
-/
def elimVars (env : Nat → Formula) (φ : Formula) :
    (vars : List Nat) → vars.Nodup →
      (∀ v : Nat → Bool, (litCtx env v vars) ⊢ φ) → (⊢ φ)
  | [], _, H => H (fun _ => false)
  | (n :: ns), hnd, H => by
      have hnmem : n ∉ ns := (List.nodup_cons.mp hnd).1
      have hnd' : ns.Nodup := (List.nodup_cons.mp hnd).2
      have Hns : ∀ v : Nat → Bool, (litCtx env v ns) ⊢ φ := by
        intro v
        have h_true := H (Function.update v n true)
        have h_false := H (Function.update v n false)
        have hcast_true : litCtx env (Function.update v n true) (n :: ns)
            = (env n) :: litCtx env v ns := by
          rw [litCtx_cons, litCtx_update_not_mem hnmem]
          simp [Function.update]
        have hcast_false : litCtx env (Function.update v n false) (n :: ns)
            = (env n).neg :: litCtx env v ns := by
          rw [litCtx_cons, litCtx_update_not_mem hnmem]
          simp [Function.update]
        rw [hcast_true] at h_true
        rw [hcast_false] at h_false
        have d_true : (litCtx env v ns) ⊢ (env n).imp φ :=
          FormalSystem.Metalogic.Core.deductionTheorem (litCtx env v ns) (env n) φ h_true
        have d_false : (litCtx env v ns) ⊢ (env n).neg.imp φ :=
          FormalSystem.Metalogic.Core.deductionTheorem (litCtx env v ns) (env n).neg φ h_false
        have hcm : (⊢ ((env n).imp φ).imp (((env n).neg.imp φ).imp φ)) :=
          classicalMerge (env n) φ
        have hcm' := DerivationTree.weakening [] (litCtx env v ns) _ hcm (List.nil_subset _)
        have step1 := DerivationTree.modus_ponens _ _ _ hcm' d_true
        exact DerivationTree.modus_ponens _ _ _ step1 d_false
      exact elimVars env φ ns hnd' Hns

/-! ## Main Theorem -/

/--
Kalmar soundness (tree-valued): every kernel-checked `PropForm` tautology is derivable at
`FrameClass.Base`, schematically in the environment `env`.
-/
def tautologyDerivable' (f : PropForm) (h : f.isTaut = true) (env : Nat → Formula) :
    ⊢ f.denote env := by
  have heval : ∀ v, f.eval v = true := (PropForm.isTaut_iff_forall_eval f).mp h
  have hnd : f.vars.Nodup := PropForm.vars_nodup f
  have H : ∀ v : Nat → Bool, (litCtx env v f.vars) ⊢ f.denote env := by
    intro v
    have hstep := kalmarStep f env v f.vars (fun n hn => hn)
    rwa [litDenote_of_true (heval v)] at hstep
  exact elimVars env (f.denote env) f.vars hnd H

/-- Kalmar soundness (Prop interface): every kernel-checked `PropForm` tautology is
`|-!`-derivable, schematically in the environment `env`. -/
theorem tautology_derivable (f : PropForm) (h : f.isTaut = true) (env : Nat → Formula) :
    |-! f.denote env :=
  Nonempty.intro (tautologyDerivable' f h env)

/-- Generalization to an arbitrary frame class `fc`: since `FrameClass.Base ≤ fc` always
(`FrameClass.base_le`), the `Base`-level derivation lifts freely — no re-proof needed. -/
def tautologyDerivableFc' (f : PropForm) (h : f.isTaut = true) (env : Nat → Formula)
    (fc : FrameClass) : ⊢[fc] f.denote env :=
  (tautologyDerivable' f h env).lift (FrameClass.base_le fc)

/-- Prop interface of `tautology_derivable_fc'`. -/
theorem tautology_derivable_fc (f : PropForm) (h : f.isTaut = true) (env : Nat → Formula)
    (fc : FrameClass) : |-![fc] f.denote env :=
  Nonempty.intro (tautologyDerivableFc' f h env fc)

/-! ## Sanity Examples (manual reification, no tactic yet) -/

/-- `⊢ A.imp (B.imp A)` for free formula variables `A B`, derived via `tautology_derivable'`
on the reified skeleton `var 0 → (var 1 → var 0)` with `env 0 := A`, `env 1 := B`. -/
example (A B : Formula) : ⊢ A.imp (B.imp A) := by
  have h :
    (⊢ (PropForm.imp (PropForm.var 0) (PropForm.imp (PropForm.var 1) (PropForm.var 0))).denote
      (fun n => if n = 0 then A else B)) :=
    tautologyDerivable'
      (PropForm.imp (PropForm.var 0) (PropForm.imp (PropForm.var 1) (PropForm.var 0)))
      (by decide) (fun n => if n = 0 then A else B)
  simpa using h

/-- `⊢ (□A).imp (□A)` for a free formula variable `A`, derived via `tautology_derivable'` on
the reified skeleton `var 0 → var 0` with `env 0 := □A` — the opaque modal subformula is
handled uniformly as a schematic variable, exactly why reflection (not truth-table `decide`
on `Formula` itself) is required. -/
example (A : Formula) : ⊢ A.box.imp A.box := by
  have h : (⊢ (PropForm.imp (PropForm.var 0) (PropForm.var 0)).denote (fun _ => A.box)) :=
    tautologyDerivable' (PropForm.imp (PropForm.var 0) (PropForm.var 0)) (by decide)
      (fun _ => A.box)
  simpa using h

end -- noncomputable section

end FormalSystem.Metalogic.Decidability.Propositional
