/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.EFGames.Decomposition

/-!
# Stavi Expressive Completeness Infrastructure

Standard translation for Stavi formulas over muSig, StaviFormula combinators,
NF characterization helpers, and the GHR93 interval-data bridge
infrastructure.

The dead expressive-completeness tail — `stavi_expressive_completeness`
(GHR93 Theorem 9.3.1: {U,S,U',S'} is expressively complete for ALL linear
orders) together with its exclusively-consumed helpers, carrying this file's
3 former statement-position sorries — was archived to
`Boneyard/StaviDiscretePath/StaviExpressiveCompletenessTail.lean`. The
completeness chain bypasses that result via
`kamp_prior_expressive_completeness` (Kamp/Rabinovich 2014); the chain top
had zero code consumers, and the general Stavi result remains a documented
open formalization target.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Standard Translation for Stavi Formulas over muSig (GHR93 p.111)

The standard translation `stavi_table_mu` maps each `StaviFormula` to a
monadic FO formula `MonadicFormula (muSig sig) 1` whose quantifiers are
relativized to the mu predicate (`Sum.inr ()` in `muSig sig`). This is
the key bridge between `stavi_temporal_truth_mu` (semantic evaluation on
the extended structure) and the NormalForm finiteness theory.

### Design

- `liftSigFormula`: lifts `MonadicFormula sig n` to `MonadicFormula (muSig sig) n`
  by mapping predicates via `Sum.inl`.
- `muPred`: the mu predicate atom `atom (Sum.inr ()) i` in `muSig sig`.
- `stavi_table_mu`: the main translation.
- `stavi_table_mu_correct`: evaluating `stavi_table_mu` on `extendedStructureWithMu`
  is equivalent to `stavi_temporal_truth_mu`.
- `nf_determines_stavi_truth_via_mu`: the NF bridge used by `pigeonhole_definable_formula`.
-/

/-- Lift a monadic FO formula from signature `sig` to `muSig sig` by
    mapping each predicate `p` to `Sum.inl p`. -/
def liftSigFormula {sig : MonadicSignature} {n : Nat} :
    MonadicFormula sig n → MonadicFormula (muSig sig) n
  | .atom p i => .atom (.inl p) i
  | .lt i j => .lt i j
  | .not α => .not (liftSigFormula α)
  | .and α β => .and (liftSigFormula α) (liftSigFormula β)
  | .all α => .all (liftSigFormula α)
  | .ex α => .ex (liftSigFormula α)

/-- Lifting preserves quantifier depth. -/
theorem liftSigFormula_depth {sig : MonadicSignature} {n : Nat}
    (α : MonadicFormula sig n) :
    (liftSigFormula α).quantifier_depth = α.quantifier_depth := by
  induction α with
  | atom _ _ => rfl
  | lt _ _ => rfl
  | not _ ih => simp [liftSigFormula, MonadicFormula.quantifier_depth, ih]
  | and _ _ ihα ihβ => simp [liftSigFormula, MonadicFormula.quantifier_depth, ihα, ihβ]
  | all _ ih => simp [liftSigFormula, MonadicFormula.quantifier_depth, ih]
  | ex _ ih => simp [liftSigFormula, MonadicFormula.quantifier_depth, ih]

/-- Lifting preserves evaluation: evaluating a lifted formula on
    `extendedStructureWithMu` equals evaluating the original on
    `extendedStructure` (since `Sum.inl` predicates agree). -/
theorem liftSigFormula_eval {sig : MonadicSignature} {n : Nat}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (env : Fin n → (extendedStructureWithMu M atomMap r).carrier)
    (α : MonadicFormula sig n) :
    eval (extendedStructureWithMu M atomMap r) env (liftSigFormula α) ↔
    eval (extendedStructure M atomMap r) env α := by
  induction α with
  | atom p i => simp [liftSigFormula, eval, extendedStructureWithMu]
  | lt i j => simp [liftSigFormula, eval]
  | not α ih => simp only [liftSigFormula, eval]; exact (ih env).not
  | and α β ihα ihβ => simp only [liftSigFormula, eval]; exact (ihα env).and (ihβ env)
  | all α ih =>
    simp only [liftSigFormula, eval]
    exact forall_congr' fun x => ih (Fin.cons x env)
  | ex α ih =>
    simp only [liftSigFormula, eval]
    exact exists_congr fun x => ih (Fin.cons x env)

/-- Lifting preserves the lift (De Bruijn shift) operation. -/
theorem liftSigFormula_lift_comm {sig : MonadicSignature} {n : Nat}
    (α : MonadicFormula sig n) (c : Nat) :
    liftSigFormula (α.lift c) = (liftSigFormula α).lift c := by
  induction α generalizing c with
  | atom p i => simp [liftSigFormula, MonadicFormula.lift]
  | lt i j => simp [liftSigFormula, MonadicFormula.lift]
  | not α ih => simp [liftSigFormula, MonadicFormula.lift, ih]
  | and α β ihα ihβ => simp [liftSigFormula, MonadicFormula.lift, ihα, ihβ]
  | all α ih => simp [liftSigFormula, MonadicFormula.lift, ih]
  | ex α ih => simp [liftSigFormula, MonadicFormula.lift, ih]

/-- The mu predicate as a monadic formula: `atom (Sum.inr ()) i`.
    Applied to variable `i` in a formula with `n` free variables. -/
def muPred {sig : MonadicSignature} {n : Nat} (i : Fin n) :
    MonadicFormula (muSig sig) n :=
  .atom (.inr ()) i

/-- Mu-relativized existential: ∃x. mu(x) ∧ φ(x).
    Variable 0 is the bound variable, others shift up. -/
def muEx {sig : MonadicSignature} {n : Nat}
    (φ : MonadicFormula (muSig sig) (n + 1)) : MonadicFormula (muSig sig) n :=
  .ex (.and (muPred ⟨0, by omega⟩) φ)

/-- Mu-relativized universal: ∀x. mu(x) → φ(x).
    Encoded as ∀x. ¬(mu(x) ∧ ¬φ(x)). -/
def muAll {sig : MonadicSignature} {n : Nat}
    (φ : MonadicFormula (muSig sig) (n + 1)) : MonadicFormula (muSig sig) n :=
  .all (.not (.and (muPred ⟨0, by omega⟩) (.not φ)))

/-- GHR93 FO table for U'(A,B), mu-relativized, taking pre-lifted arguments.
    Arguments are the sub-formula translations at various De Bruijn depths.
    ∃s. t < s ∧ [body] ∧ [fail] ∧ [init] -/
private def stavi_untl_fo {sig : MonadicSignature}
    (cA4 : MonadicFormula (muSig sig) 4)
    (cB3 : MonadicFormula (muSig sig) 3)
    (cB4 : MonadicFormula (muSig sig) 4)
    (cB5 : MonadicFormula (muSig sig) 5) : MonadicFormula (muSig sig) 1 :=
  -- After ex: var 0 = s, var 1 = t
  MonadicFormula.ex (MonadicFormula.and
    (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- t < s
    (MonadicFormula.and
      -- (1) Body: ∀ u, ¬(guard(u) ∧ ¬D1(u) ∧ ¬D2(u))
      --    = ∀ u, guard(u) → D1(u) ∨ D2(u)
      (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
        (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨2, by omega⟩ ⟨0, by omega⟩)
                (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))
        (MonadicFormula.and
          (MonadicFormula.not (MonadicFormula.ex (MonadicFormula.and
            (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
              (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
                (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                  (MonadicFormula.and (MonadicFormula.lt ⟨4, by omega⟩ ⟨0, by omega⟩)
                        (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))
                (MonadicFormula.not cB5))))))))
          (MonadicFormula.not (MonadicFormula.and
            (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
              (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                      (MonadicFormula.lt ⟨0, by omega⟩ ⟨2, by omega⟩)))
              (MonadicFormula.not cA4))))
            (MonadicFormula.ex (MonadicFormula.and
              (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
              (MonadicFormula.and (MonadicFormula.lt ⟨3, by omega⟩ ⟨0, by omega⟩)
                (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
                  (MonadicFormula.not cB4)))))))))))
      (MonadicFormula.and
        -- (2) Fail
        (MonadicFormula.ex (MonadicFormula.and
          (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨2, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
              (MonadicFormula.not cB3)))))
        -- (3) Init
        (MonadicFormula.ex (MonadicFormula.and
          (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨2, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
              (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
                (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                  (MonadicFormula.and (MonadicFormula.lt ⟨3, by omega⟩ ⟨0, by omega⟩)
                        (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))
                (MonadicFormula.not cB4)))))))))))

/-- Past dual of stavi_untl_fo: S'(A,B), mu-relativized. -/
private def stavi_snce_fo {sig : MonadicSignature}
    (cA4 : MonadicFormula (muSig sig) 4)
    (cB3 : MonadicFormula (muSig sig) 3)
    (cB4 : MonadicFormula (muSig sig) 4)
    (cB5 : MonadicFormula (muSig sig) 5) : MonadicFormula (muSig sig) 1 :=
  MonadicFormula.ex (MonadicFormula.and
    (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)  -- s < t
    (MonadicFormula.and
      -- (1) Body: ∀ u, ¬(guard(u) ∧ ¬D1(u) ∧ ¬D2(u))
      --    = ∀ u, guard(u) → D1(u) ∨ D2(u) (past dual)
      (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
        (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                (MonadicFormula.lt ⟨0, by omega⟩ ⟨2, by omega⟩)))
        (MonadicFormula.and
          (MonadicFormula.not (MonadicFormula.ex (MonadicFormula.and
            (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
              (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
                (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                  (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                        (MonadicFormula.lt ⟨0, by omega⟩ ⟨4, by omega⟩)))
                (MonadicFormula.not cB5))))))))
          (MonadicFormula.not (MonadicFormula.and
            (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
              (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                (MonadicFormula.and (MonadicFormula.lt ⟨2, by omega⟩ ⟨0, by omega⟩)
                      (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))
              (MonadicFormula.not cA4))))
            (MonadicFormula.ex (MonadicFormula.and
              (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
              (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨3, by omega⟩)
                  (MonadicFormula.not cB4)))))))))))
      (MonadicFormula.and
        -- (2) Fail
        (MonadicFormula.ex (MonadicFormula.and
          (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨2, by omega⟩)
              (MonadicFormula.not cB3)))))
        -- (3) Init
        (MonadicFormula.ex (MonadicFormula.and
          (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨2, by omega⟩)
              (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
                (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                  (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                        (MonadicFormula.lt ⟨0, by omega⟩ ⟨3, by omega⟩)))
                (MonadicFormula.not cB4)))))))))))

/-- Mu-relativized table translation: translates a standard Formula to
    MonadicFormula (muSig sig) 1 with mu-relativized quantifiers in Until/Since.
    Atoms and box are translated via atomMap (lifted to muSig via Sum.inl).
    The temporal quantifiers (Until, Since) only range over mu-points. -/
def table_mu {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) : Formula → MonadicFormula (muSig sig) 1
  | .atom a => .atom (.inl (atomMap (.atom a))) ⟨0, by omega⟩
  | .bot => .lt ⟨0, by omega⟩ ⟨0, by omega⟩
  | .imp ψ₁ ψ₂ =>
    .not (.and (table_mu atomMap ψ₁) (.not (table_mu atomMap ψ₂)))
  | .box ψ => .atom (.inl (atomMap (.box ψ))) ⟨0, by omega⟩
  | .untl ψ₁ ψ₂ =>
    -- ∃s. mu(s) ∧ t < s ∧ C_ψ₁(s) ∧ ∀u. (mu(u) ∧ t < u ∧ u < s) → C_ψ₂(u)
    let c1 := table_mu atomMap ψ₁  -- 1 var
    let c2 := table_mu atomMap ψ₂
    let c1_2 := c1.lift 1          -- 2 vars: var 0 = s, var 1 = t
    let c2_3 := (c2.lift 1).lift 1 -- 3 vars: var 0 = u, var 1 = s, var 2 = t
    .ex (.and (.atom (.inr ()) ⟨0, by omega⟩)       -- mu(s)
      (.and (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)       -- t < s
        (.and c1_2                                    -- C_ψ₁(s)
          (.all (.not (.and
            (.and (.atom (.inr ()) ⟨0, by omega⟩)    -- mu(u)
              (.and (.lt ⟨2, by omega⟩ ⟨0, by omega⟩)  -- t < u
                    (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))  -- u < s
            (.not c2_3)))))))                          -- C_ψ₂(u)
  | .snce ψ₁ ψ₂ =>
    -- ∃s. mu(s) ∧ s < t ∧ C_ψ₁(s) ∧ ∀u. (mu(u) ∧ s < u ∧ u < t) → C_ψ₂(u)
    let c1 := table_mu atomMap ψ₁
    let c2 := table_mu atomMap ψ₂
    let c1_2 := c1.lift 1
    let c2_3 := (c2.lift 1).lift 1
    .ex (.and (.atom (.inr ()) ⟨0, by omega⟩)       -- mu(s)
      (.and (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)       -- s < t
        (.and c1_2                                    -- C_ψ₁(s)
          (.all (.not (.and
            (.and (.atom (.inr ()) ⟨0, by omega⟩)    -- mu(u)
              (.and (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- s < u
                    (.lt ⟨0, by omega⟩ ⟨2, by omega⟩)))  -- u < t
            (.not c2_3)))))))                          -- C_ψ₂(u)

/-- Standard translation of StaviFormula to monadic FO formula over muSig.
    Mu-relativized quantifiers use the mu predicate from muSig.

    Variable conventions (De Bruijn):
    - In MonadicFormula (muSig sig) 1: variable 0 = t (current time)
    - After ex: variable 0 = bound, variable 1 = t
    - After ex then all: variable 0 = inner, variable 1 = outer, variable 2 = t -/
noncomputable def stavi_table_mu {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) : StaviFormula → MonadicFormula (muSig sig) 1
  | .base φ => table_mu atomMap φ
  | .neg A => .not (stavi_table_mu atomMap A)
  | .conj A B => .and (stavi_table_mu atomMap A) (stavi_table_mu atomMap B)
  | .std_untl A B =>
    -- ∃s. mu(s) ∧ t < s ∧ C_A(s) ∧ ∀u. (mu(u) ∧ t < u ∧ u < s) → C_B(u)
    let cA := stavi_table_mu atomMap A  -- MonadicFormula (muSig sig) 1
    let cB := stavi_table_mu atomMap B
    let cA2 := cA.lift 1                -- lifted to 2 vars: var 0 = s, var 1 = t
    let cB3 := (cB.lift 1).lift 1       -- lifted to 3 vars: var 0 = u, var 1 = s, var 2 = t
    .ex (.and (muPred ⟨0, by omega⟩)
      (.and (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- t < s
        (.and cA2                                -- C_A(s)
          (.all (.not (.and
            (.and (muPred ⟨0, by omega⟩)         -- mu(u)
              (.and (.lt ⟨2, by omega⟩ ⟨0, by omega⟩)  -- t < u
                    (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))  -- u < s
            (.not cB3)))))))                     -- C_B(u)
  | .std_snce A B =>
    -- ∃s. mu(s) ∧ s < t ∧ C_A(s) ∧ ∀u. (mu(u) ∧ s < u ∧ u < t) → C_B(u)
    let cA := stavi_table_mu atomMap A
    let cB := stavi_table_mu atomMap B
    let cA2 := cA.lift 1
    let cB3 := (cB.lift 1).lift 1
    .ex (.and (muPred ⟨0, by omega⟩)
      (.and (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)  -- s < t
        (.and cA2
          (.all (.not (.and
            (.and (muPred ⟨0, by omega⟩)
              (.and (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- s < u
                    (.lt ⟨0, by omega⟩ ⟨2, by omega⟩)))  -- u < t
            (.not cB3)))))))
  | .stavi_untl A B =>
    let cA := stavi_table_mu atomMap A
    let cB := stavi_table_mu atomMap B
    stavi_untl_fo (((cA.lift 1).lift 1).lift 1) ((cB.lift 1).lift 1)
      (((cB.lift 1).lift 1).lift 1) ((((cB.lift 1).lift 1).lift 1).lift 1)
  | .stavi_snce A B =>
    let cA := stavi_table_mu atomMap A
    let cB := stavi_table_mu atomMap B
    stavi_snce_fo (((cA.lift 1).lift 1).lift 1) ((cB.lift 1).lift 1)
      (((cB.lift 1).lift 1).lift 1) ((((cB.lift 1).lift 1).lift 1).lift 1)

/-- Correctness of table_mu: evaluating the mu-relativized table translation
    on extendedStructureWithMu gives temporal_truth_mu. -/
theorem table_mu_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (t : ExtendedCarrier M atomMap r) (φ : Formula) :
    eval (extendedStructureWithMu M atomMap r) (fun _ => t)
      (table_mu atomMap φ) ↔
    temporal_truth_mu M atomMap r t φ := by
  induction φ generalizing t with
  | atom a =>
    simp [table_mu, eval, extendedStructureWithMu, temporal_truth_mu, extendedStructure]
  | bot =>
    simp [table_mu, eval, temporal_truth_mu]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [table_mu, eval, temporal_truth_mu]
    constructor
    · intro h hψ₁; push_neg at h; exact (ih₂ t).mp (h ((ih₁ t).mpr hψ₁))
    · intro h ⟨hψ₁, hψ₂⟩; exact hψ₂ ((ih₂ t).mpr (h ((ih₁ t).mp hψ₁)))
  | box ψ =>
    simp [table_mu, eval, extendedStructureWithMu, temporal_truth_mu, extendedStructure]
  | untl ψ₁ ψ₂ ih₁ ih₂ =>
    -- table_mu (.untl ψ₁ ψ₂) = .ex (.and mu(s) (.and (t < s) (.and C_ψ₁(s) (∀u...))))
    -- temporal_truth_mu (.untl ψ₁ ψ₂) = ∃ s, t < s ∧ mu(s) ∧ T_ψ₁(s) ∧ ∀ u, t<u→u<s→mu(u)→T_ψ₂(u)
    -- The key lift lemma: evaluating a lifted formula under Fin.cons
    -- Key lift lemma: (α.lift 1) in env (Fin.cons s (fun _ => t)) = α in env (fun _ => s)
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Double lift: ((α.lift 1).lift 1) in env (Fin.cons u (Fin.cons s (fun _ => t))) = α at (fun _
    -- => u)
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;>
            (try simp only [Nat.reduceAdd, Fin.isValue, Fin.cons_zero, insertEnv,
            Fin.coe_ofNat_eq_mod, Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta,
            Fin.cons_succ, Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero,
            and_false, Fin.mk_one, add_tsub_cancel_right, Fin.eta, dite_eq_ite])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    have lift1_iff : ∀ (s : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) ((table_mu atomMap ψ₁).lift 1) ↔
        temporal_truth_mu M atomMap r s ψ₁ := by
      intro s; rw [lift1_eq]; exact ih₁ s
    have lift2_iff : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((table_mu atomMap ψ₂).lift 1).lift 1) ↔
        temporal_truth_mu M atomMap r u ψ₂ := by
      intro s u; rw [lift2_eq]; exact ih₂ u
    simp only [table_mu, eval, temporal_truth_mu, extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · rintro ⟨s, hmu, hts, hA, hB⟩
      exact ⟨s, hts, hmu, (lift1_iff s).mp hA, fun u htu hus hmu_u => by
        have := hB u
        simp only [not_and, Classical.not_not] at this
        exact (lift2_iff s u).mp (this ⟨hmu_u, htu, hus⟩)⟩
    · rintro ⟨s, hts, hmu, hA, hB⟩
      refine ⟨s, hmu, hts, (lift1_iff s).mpr hA, fun u => ?_⟩
      intro ⟨⟨hmu_u, htu, hus⟩, heval⟩
      exact heval ((lift2_iff s u).mpr (hB u htu hus hmu_u))
  | snce ψ₁ ψ₂ ih₁ ih₂ =>
    -- Symmetric to untl case, with s < t instead of t < s
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;>
            (try simp only [Nat.reduceAdd, Fin.isValue, Fin.cons_zero, insertEnv,
            Fin.coe_ofNat_eq_mod, Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta,
            Fin.cons_succ, Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero,
            and_false, Fin.mk_one, add_tsub_cancel_right, Fin.eta, dite_eq_ite])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    have lift1_iff : ∀ (s : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) ((table_mu atomMap ψ₁).lift 1) ↔
        temporal_truth_mu M atomMap r s ψ₁ := by
      intro s; rw [lift1_eq]; exact ih₁ s
    have lift2_iff : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((table_mu atomMap ψ₂).lift 1).lift 1) ↔
        temporal_truth_mu M atomMap r u ψ₂ := by
      intro s u; rw [lift2_eq]; exact ih₂ u
    simp only [table_mu, eval, temporal_truth_mu, extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · rintro ⟨s, hmu, hst, hA, hB⟩
      exact ⟨s, hst, hmu, (lift1_iff s).mp hA, fun u hsu hut hmu_u => by
        have := hB u
        simp only [not_and, Classical.not_not] at this
        exact (lift2_iff s u).mp (this ⟨hmu_u, hsu, hut⟩)⟩
    · rintro ⟨s, hst, hmu, hA, hB⟩
      refine ⟨s, hmu, hst, (lift1_iff s).mpr hA, fun u => ?_⟩
      intro ⟨⟨hmu_u, hsu, hut⟩, heval⟩
      exact heval ((lift2_iff s u).mpr (hB u hsu hut hmu_u))

/-- The FO quantifier depth of the stavi_table_mu translation.
    This bounds `(stavi_table_mu atomMap A).quantifier_depth` and accounts
    for the fact that stavi_untl/snce FO encodings use more quantifiers
    than the temporal operator depth (stavi_depth). -/
def stavi_fo_depth : StaviFormula → Nat
  | .base φ => operator_depth φ
  | .neg A => stavi_fo_depth A
  | .conj A B => max (stavi_fo_depth A) (stavi_fo_depth B)
  | .std_untl A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 2
  | .std_snce A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 2
  | .stavi_untl A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 4
  | .stavi_snce A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 4

/-- stavi_fo_depth is always at least stavi_depth. -/
theorem stavi_depth_le_fo_depth (A : StaviFormula) :
    stavi_depth A ≤ stavi_fo_depth A := by
  induction A with
  | base φ => simp [stavi_depth, stavi_fo_depth]
  | neg A ih => simp [stavi_depth, stavi_fo_depth, ih]
  | conj A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | std_untl A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | std_snce A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | stavi_untl A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | stavi_snce A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega

/-- stavi_fo_depth is at most twice stavi_depth. This is because the only
    connectives where they differ are stavi_untl/stavi_snce, which add +4 to
    fo_depth vs +2 to depth. By induction, the gap is at most a factor of 2. -/
theorem stavi_fo_depth_le_twice_depth (A : StaviFormula) :
    stavi_fo_depth A ≤ 2 * stavi_depth A := by
  induction A with
  | base φ => simp [stavi_depth, stavi_fo_depth]; omega
  | neg A ih => simp [stavi_depth, stavi_fo_depth]; omega
  | conj A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | std_untl A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | std_snce A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | stavi_untl A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | stavi_snce A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega

/-- The quantifier depth of stavi_table_mu is bounded by stavi_fo_depth. -/
theorem stavi_table_mu_depth {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} (A : StaviFormula) :
    (stavi_table_mu atomMap A).quantifier_depth ≤ stavi_fo_depth A := by
  induction A with
  | base φ =>
    simp only [stavi_table_mu, stavi_fo_depth]
    induction φ with
    | atom a => simp [table_mu, MonadicFormula.quantifier_depth, operator_depth]
    | bot => simp [table_mu, MonadicFormula.quantifier_depth, operator_depth]
    | imp ψ1 ψ2 ih₁ ih₂ =>
      simp only [table_mu, MonadicFormula.quantifier_depth, operator_depth]
      exact Nat.max_le.mpr ⟨le_trans ih₁ (le_max_left _ _), le_trans ih₂ (le_max_right _ _)⟩
    | box ψ => simp [table_mu, MonadicFormula.quantifier_depth, operator_depth]
    | untl ψ1 ψ2 ih₁ ih₂ =>
      simp only [table_mu, MonadicFormula.quantifier_depth, operator_depth, lift_quantifier_depth]
      omega
    | snce ψ1 ψ2 ih₁ ih₂ =>
      simp only [table_mu, MonadicFormula.quantifier_depth, operator_depth, lift_quantifier_depth]
      omega
  | neg A ih =>
    simp only [stavi_table_mu, MonadicFormula.quantifier_depth, stavi_fo_depth]
    exact ih
  | conj A B ihA ihB =>
    simp only [stavi_table_mu, MonadicFormula.quantifier_depth, stavi_fo_depth]
    exact Nat.max_le.mpr ⟨le_trans ihA (le_max_left _ _), le_trans ihB (le_max_right _ _)⟩
  | std_untl A B ihA ihB =>
    simp only [stavi_table_mu, MonadicFormula.quantifier_depth, stavi_fo_depth,
      lift_quantifier_depth, muPred]
    omega
  | std_snce A B ihA ihB =>
    simp only [stavi_table_mu, MonadicFormula.quantifier_depth, stavi_fo_depth,
      lift_quantifier_depth, muPred]
    omega
  | stavi_untl A B ihA ihB =>
    simp only [stavi_table_mu, stavi_untl_fo, MonadicFormula.quantifier_depth,
      stavi_fo_depth, lift_quantifier_depth]
    omega
  | stavi_snce A B ihA ihB =>
    simp only [stavi_table_mu, stavi_snce_fo, MonadicFormula.quantifier_depth,
      stavi_fo_depth, lift_quantifier_depth]
    omega

/-- **Table Correctness for Stavi Formulas**: evaluating `stavi_table_mu A`
    on `extendedStructureWithMu` at a point t is equivalent to
    `stavi_temporal_truth_mu` at t.

    This is the key bridge: the FO translation faithfully represents the
    mu-relativized temporal semantics. -/
theorem stavi_table_mu_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (t : ExtendedCarrier M atomMap r) (A : StaviFormula) :
    eval (extendedStructureWithMu M atomMap r) (fun _ => t)
      (stavi_table_mu atomMap A) ↔
    stavi_temporal_truth_mu M atomMap r t A := by
  induction A generalizing t with
  | base φ =>
    simp only [stavi_table_mu, stavi_temporal_truth_mu]
    exact table_mu_correct t φ
  | neg A ih =>
    simp only [stavi_table_mu, eval, stavi_temporal_truth_mu]
    exact (ih t).not
  | conj A B ihA ihB =>
    simp only [stavi_table_mu, eval, stavi_temporal_truth_mu]
    exact (ihA t).and (ihB t)
  | std_untl A B ihA ihB =>
    -- Same structure as table_mu_correct untl case
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;>
            (try simp only [Nat.reduceAdd, Fin.isValue, Fin.cons_zero, insertEnv,
            Fin.coe_ofNat_eq_mod, Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta,
            Fin.cons_succ, Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero,
            and_false, Fin.mk_one, add_tsub_cancel_right, Fin.eta, dite_eq_ite])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    have lift1_iff : ∀ (s : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) ((stavi_table_mu atomMap A).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r s A := by
      intro s; rw [lift1_eq]; exact ihA s
    have lift2_iff : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    simp only [stavi_table_mu, eval, stavi_temporal_truth_mu, extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · rintro ⟨s, hmu, hts, hA, hB⟩
      exact ⟨s, hts, hmu, (lift1_iff s).mp hA, fun u htu hus hmu_u => by
        have := hB u
        simp only [not_and, Classical.not_not] at this
        exact (lift2_iff s u).mp (this ⟨hmu_u, htu, hus⟩)⟩
    · rintro ⟨s, hts, hmu, hA, hB⟩
      refine ⟨s, hmu, hts, (lift1_iff s).mpr hA, fun u => ?_⟩
      intro ⟨⟨hmu_u, htu, hus⟩, heval⟩
      exact heval ((lift2_iff s u).mpr (hB u htu hus hmu_u))
  | std_snce A B ihA ihB =>
    -- Same structure as table_mu_correct snce case
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;>
            (try simp only [Nat.reduceAdd, Fin.isValue, Fin.cons_zero, insertEnv,
            Fin.coe_ofNat_eq_mod, Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta,
            Fin.cons_succ, Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero,
            and_false, Fin.mk_one, add_tsub_cancel_right, Fin.eta, dite_eq_ite])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    have lift1_iff : ∀ (s : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) ((stavi_table_mu atomMap A).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r s A := by
      intro s; rw [lift1_eq]; exact ihA s
    have lift2_iff : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    simp only [stavi_table_mu, eval, stavi_temporal_truth_mu, extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · rintro ⟨s, hmu, hst, hA, hB⟩
      exact ⟨s, hst, hmu, (lift1_iff s).mp hA, fun u hsu hut hmu_u => by
        have := hB u
        simp only [not_and, Classical.not_not] at this
        exact (lift2_iff s u).mp (this ⟨hmu_u, hsu, hut⟩)⟩
    · rintro ⟨s, hst, hmu, hA, hB⟩
      refine ⟨s, hmu, hst, (lift1_iff s).mpr hA, fun u => ?_⟩
      intro ⟨⟨hmu_u, hsu, hut⟩, heval⟩
      exact heval ((lift2_iff s u).mpr (hB u hsu hut hmu_u))
  | stavi_untl A B ihA ihB =>
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Lift lemma level 2: strip two binders
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;>
            (try simp only [Nat.reduceAdd, Fin.isValue, Fin.cons_zero, insertEnv,
            Fin.coe_ofNat_eq_mod, Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta,
            Fin.cons_succ, Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero,
            and_false, Fin.mk_one, add_tsub_cancel_right, Fin.eta, dite_eq_ite])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    -- Lift lemma level 3: strip three binders via composition
    have lift3_eq : ∀ (s u v : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))) (((α.lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => v) α := by
      intro s u v α
      -- Use insertEnv to peel off the second variable (u)
      have h1 : Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))) =
          insertEnv ⟨1, by omega⟩ u (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp only
            [Fin.cons, Nat.reduceAdd, Fin.isValue, Fin.cases_zero, insertEnv, Fin.coe_ofNat_eq_mod,
            Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta, Fin.cases_succ,
            Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero, and_false,
            Fin.mk_one, Nat.add_one_sub_one, Fin.eta, dite_eq_ite]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) ⟨1, by omega⟩ u ((α.lift 1).lift 1)]
      exact lift2_eq s v α
    -- Lift lemma level 4: strip four binders via composition
    have lift4_eq : ∀ (s u v w : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          ((((α.lift 1).lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => w) α := by
      intro s u v w α
      have h1 : Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) =
          insertEnv ⟨1, by omega⟩ v
            (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp only
            [Fin.cons, Nat.reduceAdd, Fin.isValue, Fin.cases_zero, insertEnv, Fin.coe_ofNat_eq_mod,
            Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta, Fin.cases_succ,
            Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero, and_false,
            Fin.mk_one, Nat.add_one_sub_one, Fin.eta, dite_eq_ite]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))))
        ⟨1, by omega⟩ v (((α.lift 1).lift 1).lift 1)]
      exact lift3_eq s u w α
    -- IH-based iff lemmas for A and B at each level
    have lift2_iffB : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    have lift3_iffA : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap A).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v A := by
      intro s u v; rw [lift3_eq]; exact ihA v
    have lift3_iffB : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v B := by
      intro s u v; rw [lift3_eq]; exact ihB v
    have lift4_iffB : ∀ (s u v w : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          (((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r w B := by
      intro s u v w; rw [lift4_eq]; exact ihB w
    -- Unfold FO encoding and semantic definition, then match structure
    simp only [stavi_table_mu, stavi_untl_fo, eval, stavi_temporal_truth_mu,
      extendedStructureWithMu, mu_holds]
    constructor
    · -- Forward: FO → semantic
      -- Fin.cons ⟨k, _⟩ reduces definitionally: ⟨0⟩=head, ⟨1⟩=next, etc.
      rintro ⟨s, hts, hbody, ⟨ufail, hmu_ufail, htuf, hufs, hnB_ufail⟩,
              ⟨uinit, hmu_uinit, htui, huis, hinit⟩⟩
      refine ⟨s, hts, ?_, ?_, ?_⟩
      · -- Main body: hbody u : ¬(guard ∧ ¬D1_fo ∧ ¬D2_fo)
        -- After FO fix: this is guard → D1_fo ∨ D2_fo (by De Morgan)
        intro u htu hus hmu_u
        -- Extract ¬(¬D1_fo ∧ ¬D2_fo) via contradiction
        have hbody' : ¬((¬_) ∧ ¬_) := fun ⟨hnd1, hnd2⟩ =>
          hbody u ⟨⟨hmu_u, htu, hus⟩, hnd1, hnd2⟩
        -- Convert to D1_fo ∨ D2_fo
        rcases not_and_or.mp hbody' with hd1 | hd2
        · -- Case: ¬¬D1_fo, so D1_fo holds (cofinal B-segment)
          left
          obtain ⟨v, hmu_v, huv, hwall⟩ := Classical.not_not.mp hd1
          exact ⟨v, huv, hmu_v, fun w htw hwv hmu_w => by
            have hw : ¬_ := fun hn => hwall w ⟨⟨hmu_w, htw, hwv⟩, hn⟩
            exact (lift4_iffB s u v w).mp (Classical.not_not.mp hw)⟩
        · -- Case: ¬¬D2_fo, so D2_fo holds (A on interval + B failure)
          right
          obtain ⟨hall, hexv⟩ := Classical.not_not.mp hd2
          constructor
          · intro v huv hvs hmu_v
            have hv : ¬_ := fun hn => hall v ⟨⟨hmu_v, huv, hvs⟩, hn⟩
            exact (lift3_iffA s u v).mp (Classical.not_not.mp hv)
          · obtain ⟨v', hmu_v', htv', hv'u, hnB⟩ := hexv
            exact ⟨v', htv', hv'u, hmu_v', fun hB => hnB ((lift3_iffB s u v').mpr hB)⟩
      · -- Fail: B fails somewhere
        exact ⟨ufail, htuf, hufs, hmu_ufail, fun hB => hnB_ufail ((lift2_iffB s ufail).mpr hB)⟩
      · -- Init: B holds initially
        refine ⟨uinit, htui, huis, hmu_uinit, fun v htv hvu hmu_v => ?_⟩
        have hv := fun hn => hinit v ⟨⟨hmu_v, htv, hvu⟩, hn⟩
        exact (lift3_iffB s uinit v).mp (Classical.not_not.mp hv)
    · -- Backward: semantic → FO
      rintro ⟨s, hts, hbody, ⟨ufail, htuf, hufs, hmu_ufail, hnB_ufail⟩,
              ⟨uinit, htui, huis, hmu_uinit, hinit⟩⟩
      refine ⟨s, hts, ?_, ?_, ?_⟩
      · -- Main body: encode as ∀ u, ¬(guard ∧ ¬(¬D1 ∧ ¬D2))
        intro u
        intro ⟨⟨hmu_u, htu, hus⟩, hn_disj⟩
        -- hn_disj : ¬(¬D1 ∧ ¬D2), but we need ¬body i.e. (¬D1 ∧ ¬D2) to derive False
        -- Actually hn_disj : ¬D1 ∧ ¬D2 (the double-negation is consumed by the outer ¬(guard ∧ _))
        obtain ⟨hn_d1, hn_d2⟩ := hn_disj
        rcases hbody u htu hus hmu_u with (⟨v, huv, hmu_v, hwall⟩ |
            ⟨hall, v', htv', hv'u, hmu_v', hnB⟩)
        · -- Disjunct 1 holds semantically, but hn_d1 says FO-D1 fails
          exact hn_d1 ⟨v, hmu_v, huv, fun w =>
            fun ⟨⟨hmu_w, htw, hwv⟩, hn_eval⟩ =>
              hn_eval ((lift4_iffB s u v w).mpr (hwall w htw hwv hmu_w))⟩
        · -- Disjunct 2 holds semantically, but hn_d2 says FO-D2 fails
          exact hn_d2 ⟨fun v =>
            fun ⟨⟨hmu_v, huv, hvs⟩, hn_eval⟩ =>
              hn_eval ((lift3_iffA s u v).mpr (hall v huv hvs hmu_v)),
            v', hmu_v', htv', hv'u, fun heval => hnB ((lift3_iffB s u v').mp heval)⟩
      · -- Fail
        exact ⟨ufail, hmu_ufail, htuf, hufs, fun heval => hnB_ufail ((lift2_iffB s ufail).mp heval)⟩
      · -- Init
        refine ⟨uinit, hmu_uinit, htui, huis, fun v => ?_⟩
        intro ⟨⟨hmu_v, htv, hvu⟩, hn_eval⟩
        exact hn_eval ((lift3_iffB s uinit v).mpr (hinit v htv hvu hmu_v))
  | stavi_snce A B ihA ihB =>
    -- Lift lemma level 1: strip one binder
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Lift lemma level 2
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;>
            (try simp only [Nat.reduceAdd, Fin.isValue, Fin.cons_zero, insertEnv,
            Fin.coe_ofNat_eq_mod, Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta,
            Fin.cons_succ, Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero,
            and_false, Fin.mk_one, add_tsub_cancel_right, Fin.eta, dite_eq_ite])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    -- Lift lemma level 3
    have lift3_eq : ∀ (s u v : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))) (((α.lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => v) α := by
      intro s u v α
      have h1 : Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))) =
          insertEnv ⟨1, by omega⟩ u (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp only
            [Fin.cons, Nat.reduceAdd, Fin.isValue, Fin.cases_zero, insertEnv, Fin.coe_ofNat_eq_mod,
            Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta, Fin.cases_succ,
            Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero, and_false,
            Fin.mk_one, Nat.add_one_sub_one, Fin.eta, dite_eq_ite]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) ⟨1, by omega⟩ u ((α.lift 1).lift 1)]
      exact lift2_eq s v α
    -- Lift lemma level 4
    have lift4_eq : ∀ (s u v w : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          ((((α.lift 1).lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => w) α := by
      intro s u v w α
      have h1 : Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) =
          insertEnv ⟨1, by omega⟩ v
            (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp only
            [Fin.cons, Nat.reduceAdd, Fin.isValue, Fin.cases_zero, insertEnv, Fin.coe_ofNat_eq_mod,
            Nat.zero_mod, Order.lt_one_iff, ↓reduceDIte, Fin.zero_eta, Fin.cases_succ,
            Fin.val_succ, Nat.add_eq_zero_iff, Fin.val_eq_zero_iff, one_ne_zero, and_false,
            Fin.mk_one, Nat.add_one_sub_one, Fin.eta, dite_eq_ite]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))))
        ⟨1, by omega⟩ v (((α.lift 1).lift 1).lift 1)]
      exact lift3_eq s u w α
    -- IH-based iff lemmas
    have lift2_iffB : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    have lift3_iffA : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap A).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v A := by
      intro s u v; rw [lift3_eq]; exact ihA v
    have lift3_iffB : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v B := by
      intro s u v; rw [lift3_eq]; exact ihB v
    have lift4_iffB : ∀ (s u v w : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          (((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r w B := by
      intro s u v w; rw [lift4_eq]; exact ihB w
    -- Unfold FO encoding and semantic definition
    simp only [stavi_table_mu, stavi_snce_fo, eval, stavi_temporal_truth_mu,
      extendedStructureWithMu, mu_holds]
    constructor
    · -- Forward: FO → semantic (past dual of stavi_untl)
      rintro ⟨s, hst, hbody, ⟨ufail, hmu_ufail, husf, huft, hnB_ufail⟩,
              ⟨uinit, hmu_uinit, husi, huit, hinit⟩⟩
      refine ⟨s, hst, ?_, ?_, ?_⟩
      · -- Main body
        intro u hsu hut hmu_u
        have hbody' : ¬(¬(∃ v, _ ∧ _ ∧ _) ∧ ¬(_ ∧ ∃ _, _)) :=
          fun hn => hbody u ⟨⟨hmu_u, hsu, hut⟩, hn⟩
        rcases not_and_or.mp hbody' with hd1 | hd2
        · -- Case: ¬¬D1, cofinal B-segment
          left
          obtain ⟨v, hmu_v, hvu, hwall⟩ := Classical.not_not.mp hd1
          exact ⟨v, hvu, hmu_v, fun w hvw hwt hmu_w => by
            have hw := fun hn => hwall w ⟨⟨hmu_w, hvw, hwt⟩, hn⟩
            exact (lift4_iffB s u v w).mp (Classical.not_not.mp hw)⟩
        · -- Case: ¬¬D2, A on interval + B failure
          right
          obtain ⟨hall, hexv⟩ := Classical.not_not.mp hd2
          constructor
          · intro v hsv hvu hmu_v
            have hv := fun hn => hall v ⟨⟨hmu_v, hsv, hvu⟩, hn⟩
            exact (lift3_iffA s u v).mp (Classical.not_not.mp hv)
          · obtain ⟨v', hmu_v', huv', hv't, hnB⟩ := hexv
            exact ⟨v', huv', hv't, hmu_v', fun hB => hnB ((lift3_iffB s u v').mpr hB)⟩
      · -- Fail
        exact ⟨ufail, husf, huft, hmu_ufail, fun hB => hnB_ufail ((lift2_iffB s ufail).mpr hB)⟩
      · -- Init
        refine ⟨uinit, husi, huit, hmu_uinit, fun v huv hvt hmu_v => ?_⟩
        have hv := fun hn => hinit v ⟨⟨hmu_v, huv, hvt⟩, hn⟩
        exact (lift3_iffB s uinit v).mp (Classical.not_not.mp hv)
    · -- Backward: semantic → FO
      rintro ⟨s, hst, hbody, ⟨ufail, husf, huft, hmu_ufail, hnB_ufail⟩,
              ⟨uinit, husi, huit, hmu_uinit, hinit⟩⟩
      refine ⟨s, hst, ?_, ?_, ?_⟩
      · -- Main body
        intro u
        intro ⟨⟨hmu_u, hsu, hut⟩, hn_disj⟩
        obtain ⟨hn_d1, hn_d2⟩ := hn_disj
        rcases hbody u hsu hut hmu_u with (⟨v, hvu, hmu_v, hwall⟩ |
            ⟨hall, v', huv', hv't, hmu_v', hnB⟩)
        · exact hn_d1 ⟨v, hmu_v, hvu, fun w =>
            fun ⟨⟨hmu_w, hvw, hwt⟩, hn_eval⟩ =>
              hn_eval ((lift4_iffB s u v w).mpr (hwall w hvw hwt hmu_w))⟩
        · exact hn_d2 ⟨fun v =>
            fun ⟨⟨hmu_v, hsv, hvu⟩, hn_eval⟩ =>
              hn_eval ((lift3_iffA s u v).mpr (hall v hsv hvu hmu_v)),
            v', hmu_v', huv', hv't, fun heval => hnB ((lift3_iffB s u v').mp heval)⟩
      · -- Fail
        exact ⟨ufail, hmu_ufail, husf, huft, fun heval => hnB_ufail ((lift2_iffB s ufail).mp heval)⟩
      · -- Init
        refine ⟨uinit, hmu_uinit, husi, huit, fun v => ?_⟩
        intro ⟨⟨hmu_v, huv, hvt⟩, hn_eval⟩
        exact hn_eval ((lift3_iffB s uinit v).mpr (hinit v huv hvt hmu_v))
/-! Stavi_untl/snce lift infrastructure preserved below for future reference.
    The lift lemmas (1-4) are correct; the propositional matching needs a
    tactic that handles Fin.cons reduction at depth 3+.

  | stavi_untl A B ihA ihB_PRESERVED =>
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Lift lemma level 2: strip two binders
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    -- Lift lemma level 3: strip three binders via composition
    have lift3_eq : ∀ (s u v : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))) (((α.lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => v) α := by
      intro s u v α
      -- Use insertEnv to peel off the second variable (u)
      have h1 : Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))) =
          insertEnv ⟨1, by omega⟩ u (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) ⟨1, by omega⟩ u ((α.lift 1).lift 1)]
      exact lift2_eq s v α
    -- Lift lemma level 4: strip four binders via composition
    have lift4_eq : ∀ (s u v w : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          ((((α.lift 1).lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => w) α := by
      intro s u v w α
      have h1 : Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) =
          insertEnv ⟨1, by omega⟩ v
            (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))))
        ⟨1, by omega⟩ v (((α.lift 1).lift 1).lift 1)]
      exact lift3_eq s u w α
    -- IH-based iff lemmas for A and B at each level
    have lift2_iffB : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    have lift3_iffA : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap A).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v A := by
      intro s u v; rw [lift3_eq]; exact ihA v
    have lift3_iffB : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v B := by
      intro s u v; rw [lift3_eq]; exact ihB v
    have lift4_iffB : ∀ (s u v w : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          (((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r w B := by
      intro s u v w; rw [lift4_eq]; exact ihB w
    -- Now unfold. Do NOT reduce Fin.cons (causes Fin.induction terms).
    -- Instead, unfold eval+stavi_untl_fo to get Fin.cons-based goals, then
    -- match the structure using the lift iff lemmas. Fin.cons ⟨0,_⟩ = x,
    -- Fin.cons ⟨1,_⟩ = s, etc. are definitionally equal so Lean matches them.
    simp only [stavi_table_mu, stavi_untl_fo, eval, stavi_temporal_truth_mu,
      extendedStructureWithMu, mu_holds]
    constructor
    · -- Forward: FO → semantic
      rintro ⟨s, hts, hbody, ⟨ufail, hmu_ufail, htuf, hufs, hnB_ufail⟩,
              ⟨uinit, hmu_uinit, htui, huis, hinit⟩⟩
      refine ⟨s, hts, ?_, ?_, ?_⟩
      · -- Main body
        intro u htu hus hmu_u
        have hbody_u := hbody u
        simp only [not_and, Classical.not_not] at hbody_u
        have hguard : IsPoint u ∧ t < u ∧ u < s := ⟨hmu_u, htu, hus⟩
        rcases hbody_u hguard with ⟨disj1, disj2⟩ | ⟨hall, hexv⟩
        · -- Disjunct 1: ∃ v with B-cofinal
          left
          obtain ⟨v, hmu_v, huv, hwall⟩ := disj1
          exact ⟨v, huv, hmu_v, fun w htw hwv hmu_w => by
            have := hwall w
            simp only [not_and, Classical.not_not] at this
            exact (lift4_iffB s u v w).mp (this ⟨hmu_w, htw, hwv⟩)⟩
        · -- Disjunct 2: A on (u,s) ∧ B failed before u
          right
          constructor
          · intro v huv hvs hmu_v
            have := hall v
            simp only [not_and, Classical.not_not] at this
            exact (lift3_iffA s u v).mp (this ⟨hmu_v, huv, hvs⟩)
          · obtain ⟨v', hmu_v', htv', hv'u, hnB⟩ := hexv
            exact ⟨v', htv', hv'u, hmu_v', fun hB => hnB ((lift3_iffB s u v').mpr hB)⟩
      · -- Fail: B fails somewhere
        exact ⟨ufail, htuf, hufs, hmu_ufail, fun hB => hnB_ufail ((lift2_iffB s ufail).mpr hB)⟩
      · -- Init: B holds initially
        refine ⟨uinit, htui, huis, hmu_uinit, fun v htv hvu hmu_v => ?_⟩
        have := hinit v
        simp only [not_and, Classical.not_not] at this
        exact (lift3_iffB s uinit v).mp (this ⟨hmu_v, htv, hvu⟩)
    · -- Backward: semantic → FO
      rintro ⟨s, hts, hbody, ⟨ufail, htuf, hufs, hmu_ufail, hnB_ufail⟩,
              ⟨uinit, htui, huis, hmu_uinit, hinit⟩⟩
      refine ⟨s, hts, ?_, ?_, ?_⟩
      · -- Main body: encode as ∀ u, ¬(guard ∧ ¬(disj1 ∨ disj2))
        intro u
        simp only [not_and, Classical.not_not]
        rintro ⟨hmu_u, htu, hus⟩
        rcases hbody u htu hus hmu_u with (⟨v, huv, hmu_v, hwall⟩ | ⟨hall, v', htv', hv'u, hmu_v',
        hnB⟩)
        · -- Disjunct 1
          left
          exact ⟨v, hmu_v, huv, fun w => by
            simp only [not_and, Classical.not_not]
            rintro ⟨hmu_w, htw, hwv⟩
            exact (lift4_iffB s u v w).mpr (hwall w htw hwv hmu_w)⟩
        · -- Disjunct 2
          right
          constructor
          · intro v
            simp only [not_and, Classical.not_not]
            rintro ⟨hmu_v, huv, hvs⟩
            exact (lift3_iffA s u v).mpr (hall v huv hvs hmu_v)
          · exact ⟨v', hmu_v', htv', hv'u, fun heval => hnB ((lift3_iffB s u v').mp heval)⟩
      · -- Fail
        exact ⟨ufail, hmu_ufail, htuf, hufs, fun heval => hnB_ufail ((lift2_iffB s ufail).mp heval)⟩
      · -- Init
        refine ⟨uinit, hmu_uinit, htui, huis, fun v => ?_⟩
        simp only [not_and, Classical.not_not]
        rintro ⟨hmu_v, htv, hvu⟩
        exact (lift3_iffB s uinit v).mpr (hinit v htv hvu hmu_v)
  | stavi_snce A B ihA ihB =>
    -- Lift lemma level 1: strip one binder
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Lift lemma level 2
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    -- Lift lemma level 3
    have lift3_eq : ∀ (s u v : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))) (((α.lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => v) α := by
      intro s u v α
      have h1 : Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))) =
          insertEnv ⟨1, by omega⟩ u (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) ⟨1, by omega⟩ u ((α.lift 1).lift 1)]
      exact lift2_eq s v α
    -- Lift lemma level 4
    have lift4_eq : ∀ (s u v w : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          ((((α.lift 1).lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => w) α := by
      intro s u v w α
      have h1 : Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) =
          insertEnv ⟨1, by omega⟩ v
            (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))))
        ⟨1, by omega⟩ v (((α.lift 1).lift 1).lift 1)]
      exact lift3_eq s u w α
    -- IH-based iff lemmas
    have lift2_iffB : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    have lift3_iffA : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap A).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v A := by
      intro s u v; rw [lift3_eq]; exact ihA v
    have lift3_iffB : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v B := by
      intro s u v; rw [lift3_eq]; exact ihB v
    have lift4_iffB : ∀ (s u v w : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          (((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r w B := by
      intro s u v w; rw [lift4_eq]; exact ihB w
    -- Now unfold and reduce
    simp only [stavi_table_mu, stavi_snce_fo, eval, stavi_temporal_truth_mu,
      extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · -- Forward: FO → semantic
      rintro ⟨s, hst, hbody, ⟨ufail, hmu_ufail, husf, huft, hnB_ufail⟩,
              ⟨uinit, hmu_uinit, husi, huit, hinit⟩⟩
      refine ⟨s, hst, ?_, ?_, ?_⟩
      · -- Main body
        intro u hsu hut hmu_u
        have hbody_u := hbody u
        simp only [not_and, Classical.not_not] at hbody_u
        have hguard : IsPoint u ∧ s < u ∧ u < t := ⟨hmu_u, hsu, hut⟩
        rcases hbody_u hguard with ⟨disj1, disj2⟩ | ⟨hall, hexv⟩
        · -- Disjunct 1
          left
          obtain ⟨v, hmu_v, hvu, hwall⟩ := disj1
          exact ⟨v, hvu, hmu_v, fun w hvw hwt hmu_w => by
            have := hwall w
            simp only [not_and, Classical.not_not] at this
            exact (lift4_iffB s u v w).mp (this ⟨hmu_w, hvw, hwt⟩)⟩
        · -- Disjunct 2
          right
          constructor
          · intro v hsv hvu hmu_v
            have := hall v
            simp only [not_and, Classical.not_not] at this
            exact (lift3_iffA s u v).mp (this ⟨hmu_v, hsv, hvu⟩)
          · obtain ⟨v', hmu_v', huv', hv't, hnB⟩ := hexv
            exact ⟨v', huv', hv't, hmu_v', fun hB => hnB ((lift3_iffB s u v').mpr hB)⟩
      · -- Fail
        exact ⟨ufail, husf, huft, hmu_ufail, fun hB => hnB_ufail ((lift2_iffB s ufail).mpr hB)⟩
      · -- Init
        refine ⟨uinit, husi, huit, hmu_uinit, fun v huv hvt hmu_v => ?_⟩
        have := hinit v
        simp only [not_and, Classical.not_not] at this
        exact (lift3_iffB s uinit v).mp (this ⟨hmu_v, huv, hvt⟩)
    · -- Backward: semantic → FO
      rintro ⟨s, hst, hbody, ⟨ufail, husf, huft, hmu_ufail, hnB_ufail⟩,
              ⟨uinit, husi, huit, hmu_uinit, hinit⟩⟩
      refine ⟨s, hst, ?_, ?_, ?_⟩
      · -- Main body
        intro u
        simp only [not_and, Classical.not_not]
        rintro ⟨hmu_u, hsu, hut⟩
        rcases hbody u hsu hut hmu_u with (⟨v, hvu, hmu_v, hwall⟩ | ⟨hall, v', huv', hv't, hmu_v',
        hnB⟩)
        · -- Disjunct 1
          left
          exact ⟨v, hmu_v, hvu, fun w => by
            simp only [not_and, Classical.not_not]
            rintro ⟨hmu_w, hvw, hwt⟩
            exact (lift4_iffB s u v w).mpr (hwall w hvw hwt hmu_w)⟩
        · -- Disjunct 2
          right
          constructor
          · intro v
            simp only [not_and, Classical.not_not]
            rintro ⟨hmu_v, hsv, hvu⟩
            exact (lift3_iffA s u v).mpr (hall v hsv hvu hmu_v)
          · exact ⟨v', hmu_v', huv', hv't, fun heval => hnB ((lift3_iffB s u v').mp heval)⟩
      · -- Fail
        exact ⟨ufail, hmu_ufail, husf, huft, fun heval => hnB_ufail ((lift2_iffB s ufail).mp heval)⟩
      · -- Init
        refine ⟨uinit, hmu_uinit, husi, huit, fun v => ?_⟩
        simp only [not_and, Classical.not_not]
        rintro ⟨hmu_v, huv, hvt⟩
        exact (lift3_iffB s uinit v).mpr (hinit v huv hvt hmu_v)
-/

/-! ## StaviFormula Disjunction Combinator -/

private def sf_disj (A B : StaviFormula) : StaviFormula :=
  .neg (.conj (.neg A) (.neg B))

private def sf_disjList : List StaviFormula → StaviFormula
  | [] => .base .bot
  | [a] => a
  | a :: as => sf_disj a (sf_disjList as)

/-! ## StaviFormula Conjunction Combinator -/

/-- Top StaviFormula: always true. -/
private def sf_top : StaviFormula := .base Formula.top

private def sf_conjList : List StaviFormula → StaviFormula
  | [] => sf_top
  | [a] => a
  | a :: as => .conj a (sf_conjList as)

/-! ## Atom Literal StaviFormula -/

/-- Build a StaviFormula for a single atom literal:
    if `val = true`, the atom formula; if `val = false`, its negation. -/
private def sf_atom_literal (a : Atom) (val : Bool) : StaviFormula :=
  if val then .base (.atom a) else .neg (.base (.atom a))

/-! ## Base-case NF characterization helpers -/

/-- For an AtomKind at n=1, map it to a StaviFormula literal.
    `pred p ⟨0,_⟩` maps to the corresponding atom literal.
    `order i j h` is impossible for n=1 since Fin 1 has one element. -/
noncomputable def atomKind_to_sf_literal
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ak : AtomKind sig 1) (val : Bool) : StaviFormula :=
  match ak with
  | .pred p _ =>
    let a := Classical.choose (h_surj p)
    sf_atom_literal a val
  | .order i j h => absurd (Fin.ext_iff.mpr (by omega : i.val = j.val)) h

/-! ## Existence Formulas for Quantifier Part

For the inductive step of NF characterization, we need to express the existential
"∃x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf" as a StaviFormula.
When sub_nf is at depth 0, the 2-variable NF is purely atomic:
predicates at x, predicates at t, and order between x and t.
-/

/-- Extract the order direction between variable 0 (x) and variable 1 (t)
    from a NormalForm with n ≥ 2 variables. Returns:
    - some true if t < x (i.e., x is above t)
    - some false if x < t (i.e., x is below t)
    - none if x = t (both order atoms false) or impossible (both true). -/
noncomputable def nf_order_0_1 {sig : MonadicSignature} {k : Nat}
    (sub_nf : NormalForm sig k 2) : Option Bool :=
  let atom_assgn := sub_nf.atom_assgn
  let x_lt_t := atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  let t_lt_x := atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  match t_lt_x, x_lt_t with
  | true, false => some true    -- t < x: use Until
  | false, true => some false   -- x < t: use Since
  | false, false => none        -- x = t: check at t
  | true, true => none          -- impossible (caught by consistency check)

/-- Check whether a sub_nf's constraints on variable 1 (= t) are consistent
    with the parent NF's atom assignment.
    For each predicate p, sub_nf(pred p 1) must equal parent_atoms(pred p 0). -/
noncomputable def nf_t_consistent {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) : Bool :=
  -- Check that each pred at variable 1 in sub_nf matches parent's pred at variable 0
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)

/-- Build a StaviFormula for the predicates at the quantified variable (variable 0)
    in a 2-variable NormalForm at depth 0.
    This is a conjunction of atom literals for pred atoms at variable 0. -/
private noncomputable def nf_x_preds_sf
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 2) : StaviFormula :=
  let preds := (Fintype.elems (α := sig.preds)).val.toList
  sf_conjList (preds.map fun p =>
    let a := Classical.choose (h_surj p)
    let val := sub_nf (.pred p ⟨0, by omega⟩)
    sf_atom_literal a val)

/-- Build the existence StaviFormula for "∃x, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf".
    Uses Until for x > t, Since for x < t, direct check for x = t. -/
private noncomputable def nf_exist_sf_depth0
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 0 2) : StaviFormula :=
  -- If t-constraints are inconsistent, the existential is false
  if ¬ nf_t_consistent parent_atoms sub_nf = true then
    .base .bot
  else
    -- Also check that both order atoms aren't true (asymmetry)
    let x_lt_t := sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    let t_lt_x := sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    if x_lt_t && t_lt_x then
      .base .bot  -- impossible: x < t ∧ t < x
    else
      let x_preds := nf_x_preds_sf atomMap h_surj sub_nf
      match nf_order_0_1 sub_nf with
      | some true =>  -- t < x: use Until
        .std_untl x_preds sf_top
      | some false =>  -- x < t: use Since
        .std_snce x_preds sf_top
      | none =>
        if x_lt_t == false && t_lt_x == false then
          -- x = t: predicates at x must match predicates at t (which is just the parent)
          -- The existential is true iff x's predicates match when x = t
          x_preds
        else
          .base .bot  -- impossible case (both true, caught above)

/-! ## Inductive Step: Formula Construction for Depth-(k+1) NFs

The depth-(k+1) NF `(atoms, quant)` at 1 variable is characterized by:
- atoms: predicates at t (conjunction of atom literals)
- quant: for each sub_nf : NormalForm sig k 2, whether ∃x, the 2-variable
  depth-k NF of (x, t) equals sub_nf

The formula construction proceeds in two stages:

**Stage 1: Existence formulas for 2-variable sub_nfs.**
For each sub_nf at depth k with 2 variables, build a StaviFormula
`nf_exist_sf` expressing "∃x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf".
- Depth 0: nf_exist_sf_depth0 (purely atomic, using Until/Since)
- Depth k ≥ 1: use IH characteristic formulas + Until/Since

**Stage 2: Assemble the full formula.**
Conjunction of:
- Atom literals for predicates at t
- For each sub_nf with quant = true: exist_sf sub_nf
- For each sub_nf with quant = false: ¬ exist_sf sub_nf
-/

/-- Build the existence formula for "∃x, nf_eval_nf M k 2 (Fin.cons x ...) sub_nf"
    at arbitrary depth k, using IH characteristic formulas for 1-variable depth-k NFs.

    The formula is built by:
    1. Checking t-consistency (predicates at variable 1 match parent atoms)
    2. Checking order consistency (not both x < t and t < x)
    3. Choosing the appropriate temporal connective (Until/Since/identity)
    4. For the witness type at the quantified variable: take the disjunction
       over all 1-variable depth-k NFs nf_x. For each nf_x, include
       `char_k nf_x` wrapped in the appropriate connective. This captures
       "there exists x in the right direction with SOME 1-variable type nf_x".
    5. Filter by atom compatibility: only include nf_x whose atom part at
       variable 0 matches what sub_nf prescribes for variable 0.

    NOTE: This formula is correct in the forward direction (nf_eval_nf → truth).
    The backward direction (truth → nf_eval_nf) requires the game-theoretic
    argument showing that the 1-variable type + temporal position determines
    the 2-variable type. -/
private noncomputable def nf_exist_sf
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (_h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) : StaviFormula :=
  -- Step 1: t-consistency check
  if ¬ nf_t_consistent parent_atoms sub_nf = true then
    .base .bot
  -- Step 2: order consistency check (both x<t and t<x is impossible)
  else if sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
          sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) then
    .base .bot
  else
    -- Step 3: Determine order direction
    -- Step 4: Build witness type formula from IH
    -- For each 1-variable NF nf_x, check if its atom part is consistent
    -- with what sub_nf prescribes for variable 0.
    let all_nfs_k1 := (Fintype.elems (α := NormalForm sig k 1)).val.toList
    -- Atom-compatible filter: nf_x's atom assignment for predicates must match
    -- sub_nf's atom assignment for variable 0.
    let atom_compat (nf_x : NormalForm sig k 1) : Bool :=
      (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
        nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
        sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)
    let compat_formulas := all_nfs_k1.filterMap fun nf_x =>
      if atom_compat nf_x then some (char_k nf_x) else none
    let witness_type := sf_disjList compat_formulas
    match nf_order_0_1 sub_nf with
    | some true =>  -- t < x: use Until (exists x above t with type)
      .std_untl witness_type sf_top
    | some false =>  -- x < t: use Since (exists x below t with type)
      .std_snce witness_type sf_top
    | none =>
      -- x = t case: the existential is about x = t itself
      -- The 2-var NF is satisfied at (t, t), so we just check the witness type
      if sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) == false &&
         sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) == false then
        witness_type
      else
        .base .bot

/-- Build the full StaviFormula for a depth-(k+1) 1-variable NormalForm.

    Conjunction of:
    1. Atom literals for predicates at t (matching nf.1)
    2. For each sub_nf with nf.2 sub_nf = true: nf_exist_sf sub_nf
    3. For each sub_nf with nf.2 sub_nf = false: ¬ nf_exist_sf sub_nf -/
private noncomputable def nf_succ_sf
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (nf : NormalForm sig (k + 1) 1) : StaviFormula :=
  let atoms := nf.1
  let quant := nf.2
  -- Part 1: atom literals for predicates at t
  let atom_lits := (Fintype.elems (α := AtomKind sig 1)).val.toList.map fun ak =>
    atomKind_to_sf_literal atomMap h_surj ak (atoms ak)
  let atom_part := sf_conjList atom_lits
  -- Part 2: quantifier constraints
  let all_sub_nfs := (Fintype.elems (α := NormalForm sig k 2)).val.toList
  let quant_formulas := all_sub_nfs.map fun sub_nf =>
    let ef := nf_exist_sf atomMap h_surj k char_k atoms sub_nf
    if quant sub_nf then ef else .neg ef
  let quant_part := sf_conjList quant_formulas
  -- Full formula: atom part AND quantifier part
  .conj atom_part quant_part

/-! ## GHR93 Bridge: 2-Var NF Determined by Interval Data

The core bridge lemma for the backward direction of the existence characterization.
GHR93 Proposition 12.8.18 / Corollary 12.8.19: in a linear order, the 2-variable
depth-k NF of (x,t) is determined by:
1. The depth-k 1-var NF of x
2. The atom assignment at t (part of the depth-k 1-var NF of t)
3. The ordering of x relative to t
4. The set of depth-k 1-var NFs realized in the interval between x and t

This is the game-theoretic composition argument: Duplicator can win the EF game
between any two structures that agree on this data, hence they satisfy the same
FO sentences at depth k, hence they have the same 2-var NF.

The proof is by induction on k. At k=0 the NF is purely atomic (no quant part),
so the atom + ordering data alone determines it. At k+1, the quant part involves
depth-k 3-var NFs, which are in turn determined by the depth-k 1-var NFs of all
three points + their orderings + interval data between them. The IH at depth k
gives characterization of these sub-intervals.
-/

/-- The set of depth-k 1-var NF types realized in the open interval (lo, hi). -/
noncomputable def interval_nf_types {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (k : Nat) (lo hi : M.carrier) :
    Finset (NormalForm sig k 1) :=
  @Finset.filter _ (fun nf_u =>
    ∃ u : M.carrier, lo < u ∧ u < hi ∧ nf_eval_nf M k 1 (fun _ => u) nf_u)
    (fun _ => Classical.dec _) Finset.univ

/-- The set of depth-k 2-var NF types (u, hi) realized by points u in the open interval (lo, hi).
    This is a RICHER invariant than interval_nf_types: the 2-var NF encodes both
    u's 1-var NF AND u's relationship to hi (ordering + quantifier structure).
    This additional information captures the spatial arrangement within the interval,
    enabling the bridge lemma's sub-interval matching. -/
noncomputable def interval_2var_nf_types {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (k : Nat) (lo hi : M.carrier) :
    Finset (NormalForm sig k 2) :=
  @Finset.filter _ (fun nf2 =>
    ∃ u : M.carrier, lo < u ∧ u < hi ∧ nf_eval_nf M k 2 (Fin.cons u (fun _ => hi)) nf2)
    (fun _ => Classical.dec _) Finset.univ

/-- Depth-(k+1) 1-var NF equality implies depth-k 1-var NF equality.
    From shared depth-(k+1) NFs, nf_agreement_monotone gives depth-k agreement,
    which implies the depth-k characteristic NFs are equal. -/
theorem nf_char_depth_decrease {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {M' : OrderedMonadicStructure sig}
    {k : Nat} {a : M.carrier} {a' : M'.carrier}
    (h : nf_characteristic M (k + 1) 1 (fun _ => a) =
         nf_characteristic M' (k + 1) 1 (fun _ => a')) :
    nf_characteristic M k 1 (fun _ => a) =
    nf_characteristic M' k 1 (fun _ => a') := by
  -- Both satisfy the same depth-(k+1) NF, so they agree on all depth-(k+1) NFs
  have hM := nf_characteristic_satisfies M (k + 1) 1 (fun _ => a)
  have hM' := nf_characteristic_satisfies M' (k + 1) 1 (fun _ => a')
  have h_agree_k1 := nf_agreement_from_shared_nf M (fun _ => a) M' (fun _ => a')
    (nf_characteristic M (k + 1) 1 (fun _ => a)) hM (h ▸ hM')
  -- By monotonicity, they agree on all depth-k NFs
  have h_agree_k : ∀ nf_k : NormalForm sig k 1,
      nf_eval_nf M k 1 (fun _ => a) nf_k ↔
      nf_eval_nf M' k 1 (fun _ => a') nf_k :=
    nf_agreement_monotone k (k + 1) 1 (Nat.le_succ k) M (fun _ => a) M' (fun _ => a')
      h_agree_k1
  -- In particular, the characteristic depth-k NF of M,a is satisfied by M',a'
  have hM_k := nf_characteristic_satisfies M k 1 (fun _ => a)
  have hM'_k := nf_characteristic_satisfies M' k 1 (fun _ => a')
  exact nf_eval_unique M' k 1 (fun _ => a')
    (nf_characteristic M k 1 (fun _ => a))
    (nf_characteristic M' k 1 (fun _ => a'))
    ((h_agree_k _).mp hM_k) hM'_k

/-- Transfer of a depth-k 1-var NF witness across models via depth-(k+1) NF agreement.
    If u in M has depth-(k+1) 1-var NF tau, and u' in M' also has tau, then u and u'
    have the same depth-k 1-var NF. -/
theorem nf_depth_k_from_shared_succ {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {M' : OrderedMonadicStructure sig}
    {k : Nat} {u : M.carrier} {u' : M'.carrier}
    (tau : NormalForm sig (k + 1) 1)
    (hM : nf_eval_nf M (k + 1) 1 (fun _ => u) tau)
    (hM' : nf_eval_nf M' (k + 1) 1 (fun _ => u') tau)
    (nf_k : NormalForm sig k 1) :
    nf_eval_nf M k 1 (fun _ => u) nf_k ↔
    nf_eval_nf M' k 1 (fun _ => u') nf_k :=
  nf_agreement_monotone k (k + 1) 1 (Nat.le_succ k) M (fun _ => u) M' (fun _ => u')
    (nf_agreement_from_shared_nf M (fun _ => u) M' (fun _ => u') tau hM hM') nf_k

/-- Interval NF types at depth k are determined by interval NF types at depth k+1.
    If the sets of depth-(k+1) 1-var NFs realized in two intervals are equal,
    then the sets of depth-k 1-var NFs are also equal.

    Key insight: each depth-k witness u has a unique depth-(k+1) NF. Transfer the
    depth-(k+1) NF to get u', then nf_agreement_monotone gives depth-k agreement. -/
theorem interval_nf_types_depth_decrease {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {M' : OrderedMonadicStructure sig}
    {k : Nat} {lo hi : M.carrier} {lo' hi' : M'.carrier}
    (h : interval_nf_types M (k + 1) lo hi = interval_nf_types M' (k + 1) lo' hi') :
    interval_nf_types M k lo hi = interval_nf_types M' k lo' hi' := by
  ext nf_k
  simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · -- Forward: depth-k witness in M → depth-k witness in M'
    rintro ⟨u, hlo, hhi, hu_k⟩
    -- u has a unique depth-(k+1) NF
    set tau := nf_characteristic M (k + 1) 1 (fun _ => u)
    have h_tau_sat := nf_characteristic_satisfies M (k + 1) 1 (fun _ => u)
    -- tau is in the depth-(k+1) interval types of M
    have h_tau_mem : tau ∈ interval_nf_types M (k + 1) lo hi := by
      simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨u, hlo, hhi, h_tau_sat⟩
    -- By hypothesis, tau is also realized in M'
    rw [h] at h_tau_mem
    simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and] at h_tau_mem
    obtain ⟨u', hlo', hhi', hu'_tau⟩ := h_tau_mem
    -- u' has the same depth-k 1-var NF as u
    exact ⟨u', hlo', hhi', (nf_depth_k_from_shared_succ tau h_tau_sat hu'_tau nf_k).mp hu_k⟩
  · -- Backward: symmetric
    rintro ⟨u', hlo', hhi', hu'_k⟩
    set tau' := nf_characteristic M' (k + 1) 1 (fun _ => u')
    have h_tau'_sat := nf_characteristic_satisfies M' (k + 1) 1 (fun _ => u')
    have h_tau'_mem : tau' ∈ interval_nf_types M' (k + 1) lo' hi' := by
      simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨u', hlo', hhi', h_tau'_sat⟩
    rw [← h] at h_tau'_mem
    simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and] at h_tau'_mem
    obtain ⟨u, hlo, hhi, hu_tau'⟩ := h_tau'_mem
    exact ⟨u, hlo, hhi, (nf_depth_k_from_shared_succ tau' hu_tau' h_tau'_sat nf_k).mpr hu'_k⟩

/-- Above-max types at depth k are determined by above-max types at depth k+1.
    If the sets of depth-(k+1) 1-var NFs realized above max(x,t) agree,
    then the depth-k sets also agree. -/
theorem above_max_depth_decrease {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {M' : OrderedMonadicStructure sig}
    {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
    (h : (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M (k + 1) 1 (fun _ => u) nf_u) =
         (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' (k + 1) 1 (fun _ => u) nf_u)) :
    (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
    (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u) := by
  funext nf_k
  apply propext
  constructor
  · rintro ⟨u, hmax, hu_k⟩
    set tau := nf_characteristic M (k + 1) 1 (fun _ => u)
    have h_tau_sat := nf_characteristic_satisfies M (k + 1) 1 (fun _ => u)
    have h_tau_ex : ∃ u, max x t < u ∧ nf_eval_nf M (k + 1) 1 (fun _ => u) tau :=
      ⟨u, hmax, h_tau_sat⟩
    have h_transfer := Iff.of_eq (congr_fun h tau)
    obtain ⟨u', hmax', hu'_tau⟩ := h_transfer.mp h_tau_ex
    exact ⟨u', hmax', (nf_depth_k_from_shared_succ tau h_tau_sat hu'_tau nf_k).mp hu_k⟩
  · rintro ⟨u', hmax', hu'_k⟩
    set tau' := nf_characteristic M' (k + 1) 1 (fun _ => u')
    have h_tau'_sat := nf_characteristic_satisfies M' (k + 1) 1 (fun _ => u')
    have h_tau'_ex : ∃ u, max x' t' < u ∧ nf_eval_nf M' (k + 1) 1 (fun _ => u) tau' :=
      ⟨u', hmax', h_tau'_sat⟩
    have h_transfer := (Iff.of_eq (congr_fun h tau')).symm
    obtain ⟨u, hmax, hu_tau'⟩ := h_transfer.mp h_tau'_ex
    exact ⟨u, hmax, (nf_depth_k_from_shared_succ tau' hu_tau' h_tau'_sat nf_k).mpr hu'_k⟩

/-- Below-min types at depth k are determined by below-min types at depth k+1.
    Same principle as above_max_depth_decrease. -/
theorem below_min_depth_decrease {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {M' : OrderedMonadicStructure sig}
    {k : Nat} {x t : M.carrier} {x' t' : M'.carrier}
    (h : (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M (k + 1) 1 (fun _ => u) nf_u) =
         (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' (k + 1) 1 (fun _ => u) nf_u)) :
    (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
    (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u) := by
  funext nf_k
  apply propext
  constructor
  · rintro ⟨u, hmin, hu_k⟩
    set tau := nf_characteristic M (k + 1) 1 (fun _ => u)
    have h_tau_sat := nf_characteristic_satisfies M (k + 1) 1 (fun _ => u)
    have h_tau_ex : ∃ u, u < min x t ∧ nf_eval_nf M (k + 1) 1 (fun _ => u) tau :=
      ⟨u, hmin, h_tau_sat⟩
    have h_transfer := Iff.of_eq (congr_fun h tau)
    obtain ⟨u', hmin', hu'_tau⟩ := h_transfer.mp h_tau_ex
    exact ⟨u', hmin', (nf_depth_k_from_shared_succ tau h_tau_sat hu'_tau nf_k).mp hu_k⟩
  · rintro ⟨u', hmin', hu'_k⟩
    set tau' := nf_characteristic M' (k + 1) 1 (fun _ => u')
    have h_tau'_sat := nf_characteristic_satisfies M' (k + 1) 1 (fun _ => u')
    have h_tau'_ex : ∃ u, u < min x' t' ∧ nf_eval_nf M' (k + 1) 1 (fun _ => u) tau' :=
      ⟨u', hmin', h_tau'_sat⟩
    have h_transfer := (Iff.of_eq (congr_fun h tau')).symm
    obtain ⟨u, hmin, hu_tau'⟩ := h_transfer.mp h_tau'_ex
    exact ⟨u, hmin, (nf_depth_k_from_shared_succ tau' hu_tau' h_tau'_sat nf_k).mpr hu'_k⟩

/-! ## Discrete Stavi Expressive Completeness

Discrete versions were archived to Boneyard/StaviDiscretePath/. -/

end Bimodal.Metalogic.WeakCanonical
