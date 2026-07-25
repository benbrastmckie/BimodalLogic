import Bimodal.Syntax.Formula

/-!
# PropForm - Deep Embedding for Propositional Reflection

This module defines a deep-embedded propositional formula type `PropForm` (variables
indexed by `Nat`, not `Formula.atom`), together with a computable evaluator and a
computable, kernel-`decide`-able tautology checker `isTaut`.

## Reflection Architecture

The propositional decision procedure follows a proof-by-reflection strategy mirroring
`Mathlib.Tactic.Ring`:

1. **Reify**: a (bimodal) `Formula` goal built purely from `Formula.imp`/`Formula.bot`
   skeleton is reified into a `PropForm` term `f`, recording each maximal non-imp/bot
   subterm (an atom, or an opaque `box`/`untl`/`snce` subformula) as a fresh `PropForm.var`,
   together with an environment `env : Nat → Formula` mapping each variable index back to
   the original subformula.
2. **Check**: `f.isTaut` is a `Bool`-valued, structurally recursive computation that the
   Lean *kernel* can evaluate directly via `decide` — no `native_decide`, no new axioms.
3. **Apply**: the Kalmar-style soundness theorem (`Kalmar.lean`) converts
   `f.isTaut = true` into an object-level derivation `⊢ f.denote env`, and since `env` is
   *schematic* (an arbitrary function `Nat → Formula`), this works uniformly whether the
   variables denote atoms or opaque modal/temporal subformulas — this is exactly why
   reflection is required and a bare truth-table + `decide` on `Formula` itself is
   rejected (it cannot close schematic goals like `∀ A B, ⊢ A.imp (B.imp A)`).

## Noncomputability Note

`PropForm`, `PropForm.eval`, `PropForm.vars`, and `PropForm.isTaut` are all fully
computable (structural recursion only, no `Finset.pi`, no well-founded recursion), so
`decide` reduces `isTaut` closed instances via the kernel. The *soundness* proof
(`Kalmar.lean`, `Decidable.lean`) that converts `isTaut f = true` into a `DerivationTree`
uses `Classical.propDecidable` (via `deduction_theorem`) and is therefore `noncomputable`;
this noncomputability does not infect `PropForm.isTaut` itself.

## Main Definitions

- `PropForm`: deep-embedded propositional formula (`var`, `fls`, `imp`)
- `PropForm.eval`: Boolean evaluation under a variable assignment
- `PropForm.vars`: deduplicated list of variables occurring in a formula
- `PropForm.isTaut`: computable tautology checker (kernel `decide`-able)
- `PropForm.denote`: reflects a `PropForm` back into a `Formula` under an environment
- `PropForm.isTaut_iff_forall_eval`: the checker is correct w.r.t. `eval`
-/

namespace Bimodal.Metalogic.Decidability.Propositional

open Bimodal.Syntax

/-- Deep-embedded propositional formula: variables are bare `Nat` indices (not `Atom`),
so that `box`/`untl`/`snce` subformulas can be reified as opaque variables uniformly with
atoms. -/
inductive PropForm : Type where
  /-- A propositional variable, indexed by `Nat`. -/
  | var : Nat → PropForm
  /-- Falsum. -/
  | fls : PropForm
  /-- Implication. -/
  | imp : PropForm → PropForm → PropForm
  deriving DecidableEq, Repr

namespace PropForm

/-- Boolean evaluation of a `PropForm` under a variable assignment `v`. -/
def eval (v : Nat → Bool) : PropForm → Bool
  | var n => v n
  | fls => false
  | imp f g => !f.eval v || g.eval v

@[simp] theorem eval_var (v : Nat → Bool) (n : Nat) : eval v (var n) = v n := rfl

@[simp] theorem eval_fls (v : Nat → Bool) : eval v fls = false := rfl

@[simp] theorem eval_imp (v : Nat → Bool) (f g : PropForm) :
    eval v (imp f g) = (!f.eval v || g.eval v) := rfl

/-- Deduplicated list of variables occurring in a `PropForm`. -/
def vars : PropForm → List Nat
  | var n => [n]
  | fls => []
  | imp f g => (f.vars ++ g.vars).dedup

@[simp] theorem vars_var (n : Nat) : vars (var n) = [n] := rfl

@[simp] theorem vars_fls : vars fls = [] := rfl

theorem mem_vars_imp {f g : PropForm} {n : Nat} :
    n ∈ vars (imp f g) ↔ n ∈ f.vars ∨ n ∈ g.vars := by
  simp [vars]

/-- `eval` depends only on the values of `v` at `f.vars`: if two assignments agree on
`f.vars`, they agree on `f.eval`. -/
theorem eval_congr {f : PropForm} {v v' : Nat → Bool}
    (h : ∀ n, n ∈ f.vars → v n = v' n) : f.eval v = f.eval v' := by
  induction f with
  | var n => exact h n (by simp)
  | fls => rfl
  | imp f g ihf ihg =>
      have hf : f.eval v = f.eval v' := ihf (fun n hn => h n (mem_vars_imp.mpr (Or.inl hn)))
      have hg : g.eval v = g.eval v' := ihg (fun n hn => h n (mem_vars_imp.mpr (Or.inr hn)))
      simp [eval, hf, hg]

/-- Auxiliary tautology checker: branches on each variable in `vars`, checking both
Boolean assignments, structurally recursive on `vars`. -/
def tautoAux (f : PropForm) : List Nat → (Nat → Bool) → Bool
  | [], v => f.eval v
  | n :: ns, v =>
    tautoAux f ns (Function.update v n true) && tautoAux f ns (Function.update v n false)

/-- `tautoAux f vars v = true` iff `f` evaluates to `true` under every assignment agreeing
with `v` outside `vars` (the standard branching-quantifier-elimination correctness
statement for a Kalmar-style tautology checker). -/
theorem tautoAux_iff (f : PropForm) :
    ∀ (vars : List Nat) (v : Nat → Bool),
      tautoAux f vars v = true ↔ ∀ v', (∀ n, n ∉ vars → v' n = v n) → f.eval v' = true := by
  intro vars
  induction vars with
  | nil =>
      intro v
      show f.eval v = true ↔ ∀ v', (∀ n, n ∉ ([] : List Nat) → v' n = v n) → f.eval v' = true
      constructor
      · intro h v' hv'
        have hveq : v' = v := funext fun n => hv' n (by simp)
        rw [hveq]; exact h
      · intro h
        exact h v (fun n _ => rfl)
  | cons n ns ih =>
      intro v
      simp only [tautoAux, Bool.and_eq_true]
      constructor
      · rintro ⟨h1, h2⟩ v' hv'
        rcases hb : v' n with _ | _
        · -- v' n = false
          have hagree : ∀ m, m ∉ ns → v' m = Function.update v n false m := by
            intro m hm
            by_cases hmn : m = n
            · subst hmn; simp [Function.update, hb]
            · have hnm : m ∉ (n :: ns) := by simp [hmn, hm]
              have hveq := hv' m hnm
              simp [Function.update, hmn, hveq]
          exact (ih (Function.update v n false)).mp h2 v' hagree
        · -- v' n = true
          have hagree : ∀ m, m ∉ ns → v' m = Function.update v n true m := by
            intro m hm
            by_cases hmn : m = n
            · subst hmn; simp [Function.update, hb]
            · have hnm : m ∉ (n :: ns) := by simp [hmn, hm]
              have hveq := hv' m hnm
              simp [Function.update, hmn, hveq]
          exact (ih (Function.update v n true)).mp h1 v' hagree
      · intro h
        constructor
        · apply (ih (Function.update v n true)).mpr
          intro v' hv'
          apply h
          intro m hm
          simp only [List.mem_cons, not_or] at hm
          obtain ⟨hmn, hmns⟩ := hm
          have := hv' m hmns
          simp [Function.update, hmn, this]
        · apply (ih (Function.update v n false)).mpr
          intro v' hv'
          apply h
          intro m hm
          simp only [List.mem_cons, not_or] at hm
          obtain ⟨hmn, hmns⟩ := hm
          have := hv' m hmns
          simp [Function.update, hmn, this]

/-- Computable tautology checker: `f.isTaut = true` iff `f` evaluates to `true` under
every Boolean assignment. Fully structural, kernel-`decide`-able. -/
def isTaut (f : PropForm) : Bool := tautoAux f f.vars (fun _ => false)

/-- Correctness of `isTaut`: it agrees with universally-quantified `eval`. -/
theorem isTaut_iff_forall_eval (f : PropForm) : f.isTaut = true ↔ ∀ v, f.eval v = true := by
  unfold isTaut
  rw [tautoAux_iff]
  constructor
  · intro h v
    have hagree : ∀ n, n ∉ f.vars → (fun n => if n ∈ f.vars then v n else false) n = false := by
      intro n hn
      simp [hn]
    have heval : f.eval (fun n => if n ∈ f.vars then v n else false) = true := h _ hagree
    have hcong : f.eval v = f.eval (fun n => if n ∈ f.vars then v n else false) :=
      eval_congr (fun n hn => by simp [hn])
    rw [hcong]; exact heval
  · intro h v' _
    exact h v'

/-- Reflects a `PropForm` back into a bimodal `Formula`, under an environment mapping
variable indices to (arbitrary, possibly opaque) formulas. -/
def denote (env : Nat → Formula) : PropForm → Formula
  | var n => env n
  | fls => Formula.bot
  | imp f g => (f.denote env).imp (g.denote env)

@[simp] theorem denote_var (env : Nat → Formula) (n : Nat) : denote env (var n) = env n := rfl

@[simp] theorem denote_fls (env : Nat → Formula) : denote env fls = Formula.bot := rfl

@[simp] theorem denote_imp (env : Nat → Formula) (f g : PropForm) :
    denote env (imp f g) = (f.denote env).imp (g.denote env) := rfl

/-! ## Smoke Tests

Kernel-`decide` reducibility on closed `PropForm` terms — no `native_decide`. -/

/-- Peirce's law: `((p → q) → p) → p`. -/
private def peirceForm : PropForm := imp (imp (imp (var 0) (var 1)) (var 0)) (var 0)

example : peirceForm.isTaut = true := by decide

/-- K axiom skeleton: `p → (q → p)`. -/
private def kForm : PropForm := imp (var 0) (imp (var 1) (var 0))

example : kForm.isTaut = true := by decide

/-- A 5-variable tautology (32 assignments): `p0 → (p1 → (p2 → (p3 → (p4 → p0))))`. -/
private def fiveVarForm : PropForm :=
  imp (var 0) (imp (var 1) (imp (var 2) (imp (var 3) (imp (var 4) (var 0)))))

example : fiveVarForm.isTaut = true := by decide

end PropForm

end Bimodal.Metalogic.Decidability.Propositional
