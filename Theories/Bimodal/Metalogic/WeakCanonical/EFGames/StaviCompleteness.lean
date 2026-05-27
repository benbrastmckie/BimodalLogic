import Bimodal.Metalogic.WeakCanonical.EFGames.Decomposition

/-!
# Stavi Expressive Completeness

Stavi expressive completeness: standard translation, NF characterization, and the main theorem.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Stavi Expressive Completeness

The main theorem: {U, S, U', S'} is expressively complete for ALL linear
temporal structures.

For any monadic FO sentence phi of quantifier depth ≤ k, there exists a
StaviFormula A such that for all ordered monadic structures M and points t:

  stavi_temporal_truth M atomMap t A ↔ eval M (fun _ => t) phi

### Proof Strategy (GHR93)

The proof uses the custom EF games to show that if two pointed structures
(M, t) and (N, s) agree on all StaviFormulas of a certain depth, then
Duplicator wins the corresponding EF game, hence they satisfy the same
FO sentences up to that depth. The four cases of the main induction
correspond to different structural configurations:

- Case I: The structures can be distinguished by atoms/order at the
  selected points → use base temporal formulas.
- Case II: There is a standard Until witness → use U.
- Case III: There is a standard Since witness → use S.
- Case IV: The structure has a gap → use U' or S'.

The full proof is ~1000-1500 lines and requires the game infrastructure
defined above. It is the single largest formalization effort in the
Reynolds pipeline.
-/

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
    simp [table_mu, eval, temporal_truth_mu, lt_irrefl]
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
    -- Double lift: ((α.lift 1).lift 1) in env (Fin.cons u (Fin.cons s (fun _ => t))) = α at (fun _ => u)
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
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
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
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
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
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
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
        rcases hbody u htu hus hmu_u with (⟨v, huv, hmu_v, hwall⟩ | ⟨hall, v', htv', hv'u, hmu_v', hnB⟩)
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
        rcases hbody u hsu hut hmu_u with (⟨v, hvu, hmu_v, hwall⟩ | ⟨hall, v', huv', hv't, hmu_v', hnB⟩)
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
        rcases hbody u htu hus hmu_u with (⟨v, huv, hmu_v, hwall⟩ | ⟨hall, v', htv', hv'u, hmu_v', hnB⟩)
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
        rcases hbody u hsu hut hmu_u with (⟨v, hvu, hmu_v, hwall⟩ | ⟨hall, v', huv', hv't, hmu_v', hnB⟩)
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

private theorem sf_disj_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (A B : StaviFormula) :
    stavi_temporal_truth M atomMap t (sf_disj A B) ↔
    (stavi_temporal_truth M atomMap t A ∨ stavi_temporal_truth M atomMap t B) := by
  simp only [sf_disj, stavi_temporal_truth]; tauto

private theorem sf_disjList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (l : List StaviFormula) :
    stavi_temporal_truth M atomMap t (sf_disjList l) ↔
    (∃ A ∈ l, stavi_temporal_truth M atomMap t A) := by
  induction l with
  | nil =>
    simp only [sf_disjList, stavi_temporal_truth, temporal_truth]
    constructor
    · exact False.elim
    · rintro ⟨A, ⟨⟩, _⟩
  | cons a as ih =>
    cases as with
    | nil =>
      simp only [sf_disjList, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h => ⟨a, rfl, h⟩, fun ⟨_, rfl, h⟩ => h⟩
    | cons b bs =>
      simp only [sf_disjList]
      rw [sf_disj_iff]
      constructor
      · rintro (ha | hrest)
        · exact ⟨a, List.Mem.head _, ha⟩
        · obtain ⟨A, hA, h⟩ := ih.mp hrest
          exact ⟨A, List.Mem.tail a hA, h⟩
      · rintro ⟨A, hA, h⟩
        cases hA with
        | head => exact Or.inl h
        | tail _ hA => exact Or.inr (ih.mpr ⟨A, hA, h⟩)

/-! ## StaviFormula Conjunction Combinator -/

/-- Top StaviFormula: always true. -/
private def sf_top : StaviFormula := .base Formula.top

private theorem sf_top_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier) :
    stavi_temporal_truth M atomMap t sf_top ↔ True := by
  simp only [sf_top, stavi_temporal_truth, temporal_truth, Formula.top]; tauto

private def sf_conjList : List StaviFormula → StaviFormula
  | [] => sf_top
  | [a] => a
  | a :: as => .conj a (sf_conjList as)

private theorem sf_conjList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (l : List StaviFormula) :
    stavi_temporal_truth M atomMap t (sf_conjList l) ↔
    (∀ A ∈ l, stavi_temporal_truth M atomMap t A) := by
  induction l with
  | nil =>
    simp only [sf_conjList]
    rw [sf_top_iff]
    constructor
    · intro _ A hA; simp at hA
    · intro _; trivial
  | cons a as ih =>
    cases as with
    | nil =>
      simp only [sf_conjList, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h A hA => hA ▸ h, fun h => h a rfl⟩
    | cons b bs =>
      simp only [sf_conjList, stavi_temporal_truth]
      constructor
      · rintro ⟨ha, hrest⟩ A hA
        cases hA with
        | head => exact ha
        | tail _ hA => exact (ih.mp hrest) A hA
      · intro h
        exact ⟨h a (List.Mem.head _), ih.mpr (fun A hA => h A (List.Mem.tail a hA))⟩

/-! ## Atom Literal StaviFormula -/

/-- Build a StaviFormula for a single atom literal:
    if `val = true`, the atom formula; if `val = false`, its negation. -/
private def sf_atom_literal (a : Atom) (val : Bool) : StaviFormula :=
  if val then .base (.atom a) else .neg (.base (.atom a))

private theorem sf_atom_literal_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (a : Atom) (val : Bool) :
    stavi_temporal_truth M atomMap t (sf_atom_literal a val) ↔
    (M.interp (atomMap (.atom a)) t ↔ val = true) := by
  cases val <;> simp [sf_atom_literal, stavi_temporal_truth, temporal_truth]

/-! ## Base-case NF characterization helpers -/

/-- For an AtomKind at n=1, map it to a StaviFormula literal.
    `pred p ⟨0,_⟩` maps to the corresponding atom literal.
    `order i j h` is impossible for n=1 since Fin 1 has one element. -/
private noncomputable def atomKind_to_sf_literal
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ak : AtomKind sig 1) (val : Bool) : StaviFormula :=
  match ak with
  | .pred p _ =>
    let a := Classical.choose (h_surj p)
    sf_atom_literal a val
  | .order i j h => absurd (Fin.ext_iff.mpr (by omega : i.val = j.val)) h

/-- Correctness of atomKind_to_sf_literal. -/
private theorem atomKind_to_sf_literal_correct
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (ak : AtomKind sig 1) (val : Bool) :
    stavi_temporal_truth M atomMap t (atomKind_to_sf_literal atomMap h_surj ak val) ↔
    (atom_eval M (fun _ => t) ak ↔ val = true) := by
  match ak with
  | .pred p i =>
    simp only [atomKind_to_sf_literal]
    have h_spec := Classical.choose_spec (h_surj p)
    -- h_spec : atomMap (Formula.atom (Classical.choose (h_surj p))) = p
    rw [sf_atom_literal_iff]
    -- Goal: (M.interp (atomMap (.atom (Classical.choose ...))) t ↔ val = true) ↔
    --       (atom_eval M (fun _ => t) (.pred p i) ↔ val = true)
    show (M.interp (atomMap (.atom (Classical.choose (h_surj p)))) t ↔ val = true) ↔
         (M.interp p ((fun _ : Fin 1 => t) i) ↔ val = true)
    simp only [h_spec]
  | .order i j h =>
    exact absurd (Fin.ext_iff.mpr (by omega : i.val = j.val)) h

/-- Build a StaviFormula characterizing a depth-0 NormalForm with 1 variable.
    Constructs a conjunction of atom literals over all AtomKind sig 1 elements. -/
private noncomputable def nf_base_sf
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf : NormalForm sig 0 1) : StaviFormula :=
  let atoms := (Fintype.elems (α := AtomKind sig 1)).val.toList
  sf_conjList (atoms.map (fun ak => atomKind_to_sf_literal atomMap h_surj ak (nf ak)))

/-- The base StaviFormula correctly characterizes the depth-0 NF. -/
private theorem nf_base_sf_correct
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf : NormalForm sig 0 1)
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    stavi_temporal_truth M atomMap t (nf_base_sf atomMap h_surj nf) ↔
    nf_eval_nf M 0 1 (fun _ => t) nf := by
  simp only [nf_base_sf, nf_eval_nf]
  rw [sf_conjList_iff]
  constructor
  · -- Forward: all literals hold → all atom_eval's match
    intro h_all ak
    have h_in_list : ak ∈ (Fintype.elems (α := AtomKind sig 1)).val.toList :=
      Multiset.mem_toList.mpr (Fintype.complete ak)
    have h_mem : atomKind_to_sf_literal atomMap h_surj ak (nf ak) ∈
        (Fintype.elems (α := AtomKind sig 1)).val.toList.map
          (fun ak' => atomKind_to_sf_literal atomMap h_surj ak' (nf ak')) :=
      List.mem_map.mpr ⟨ak, h_in_list, rfl⟩
    exact (atomKind_to_sf_literal_correct atomMap h_surj M t ak (nf ak)).mp
      (h_all _ h_mem)
  · -- Backward: all atom_eval's match → all literals hold
    intro h_nf A hA
    rw [List.mem_map] at hA
    obtain ⟨ak, _, rfl⟩ := hA
    exact (atomKind_to_sf_literal_correct atomMap h_surj M t ak (nf ak)).mpr
      (h_nf ak)

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
private noncomputable def nf_order_0_1 {sig : MonadicSignature} {k : Nat}
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
private noncomputable def nf_t_consistent {sig : MonadicSignature} {k : Nat}
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) : Bool :=
  -- Check that each pred at variable 1 in sub_nf matches parent's pred at variable 0
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)

/-- Build a StaviFormula for the predicates at the quantified variable (variable 0)
    in a 2-variable NormalForm at depth 0.
    This is a conjunction of atom literals for pred atoms at variable 0. -/
private noncomputable def nf_x_preds_sf
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
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
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
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
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
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
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
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

/-! ## Forward Direction: NF Existence → Temporal Formula Truth

Given a witness x such that the 2-variable depth-k NF of (x, t) equals sub_nf,
show that the existence formula nf_exist_sf holds at t. -/

/-- Forward direction of nf_exist_sf: if ∃x with the right 2-var NF, the temporal
    formula holds. This is the EASIER direction — the backward direction requires
    the full game-theoretic argument. -/
private theorem nf_exist_sf_forward
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2)
    {M : OrderedMonadicStructure sig} {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
      parent_atoms a = true)
    (h_ex : ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :
    stavi_temporal_truth M atomMap t
      (nf_exist_sf atomMap h_surj k char_k parent_atoms sub_nf) := by
  obtain ⟨x, h_x⟩ := h_ex
  -- Step 1: Extract atom information from h_x
  -- The atoms of the 2-variable NF tell us:
  -- - predicates at x (variable 0)
  -- - predicates at t (variable 1)
  -- - order between x and t
  have h_x_atoms : ∀ (a : AtomKind sig (1 + 1)),
      atom_eval M (Fin.cons x (fun _ => t)) a ↔ sub_nf.atom_assgn a = true := by
    cases k with
    | zero => exact h_x
    | succ k' => exact h_x.1
  -- Step 2: t-consistency holds
  have h_t_cons : nf_t_consistent parent_atoms sub_nf = true := by
    simp only [nf_t_consistent]
    rw [List.all_eq_true]
    intro p _
    -- sub_nf's pred at variable 1 should match parent_atoms' pred at variable 0
    simp only [beq_iff_eq]
    -- The atom at (.pred p 1) in sub_nf matches the atom evaluation at t
    have h_sub_t := h_x_atoms (.pred p ⟨1, by omega⟩)
    have h_par := h_atoms (.pred p ⟨0, by omega⟩)
    -- atom_eval M (Fin.cons x (fun _ => t)) (.pred p 1) = M.interp p ((Fin.cons x (fun _ => t)) 1)
    -- and (Fin.cons x (fun _ => t)) 1 = t, so both reduce to M.interp p t
    -- Use the fact that atom_eval (.pred p i) = M.interp p (env i)
    simp only [atom_eval] at h_sub_t h_par
    -- h_sub_t : M.interp p ((Fin.cons x fun _ => t) 1) ↔ sub_nf.atom_assgn (.pred p 1) = true
    -- h_par : M.interp p t ↔ parent_atoms (.pred p 0) = true
    -- (Fin.cons x (fun _ => t)) ⟨1, ...⟩ = (fun _ => t) ⟨0, ...⟩ = t
    have h_env_1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [h_env_1] at h_sub_t
    -- Now both are about M.interp p t
    cases h1 : sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) <;>
    cases h2 : parent_atoms (.pred p ⟨0, by omega⟩) <;>
    simp_all
  -- Step 3: Unfold nf_exist_sf with the consistency check passing
  simp only [nf_exist_sf, h_t_cons, not_true, ↓reduceIte, ite_not]
  -- Step 4: Order consistency (not both x < t and t < x)
  have h_x_lt_t := h_x_atoms (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  have h_t_lt_x := h_x_atoms (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  simp only [atom_eval, Fin.cons] at h_x_lt_t h_t_lt_x
  -- Order atoms correctly reflect the actual order between x and t
  have h_order_compat : ¬ (sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
      sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))) = true := by
    intro h_both
    rw [Bool.and_eq_true] at h_both
    have hxt : x < t := h_x_lt_t.mpr h_both.1
    have htx : t < x := h_t_lt_x.mpr h_both.2
    exact absurd (lt_trans hxt htx) (lt_irrefl _)
  simp only [h_order_compat, ite_false]
  -- The 1-variable depth-k NF of x
  set nf_x := nf_characteristic M k 1 (fun _ => x) with nf_x_def
  have h_nf_x : nf_eval_nf M k 1 (fun _ => x) nf_x :=
    nf_characteristic_satisfies M k 1 (fun _ => x)
  -- The IH formula for nf_x holds at x
  have h_char_at_x : stavi_temporal_truth M atomMap x (char_k nf_x) :=
    (char_k_correct nf_x M x).mpr h_nf_x
  -- Key lemma: Fin.cons evaluations
  -- Fin.cons x f reduces via Fin.cases; we need explicit eval lemmas
  have h_fc0 : Fin.cases x (fun _ : Fin 1 => t) (⟨0, by omega⟩ : Fin 2) = x := by
    simp [Fin.cases]
  have h_fc1 : Fin.cases x (fun _ : Fin 1 => t) (⟨1, by omega⟩ : Fin 2) = t := by
    simp [Fin.cases]; rfl
  -- Simplify the order hypotheses to use x and t directly
  rw [h_fc0, h_fc1] at h_x_lt_t
  rw [h_fc1, h_fc0] at h_t_lt_x
  -- h_x_lt_t : x < t ↔ sub_nf.atom_assgn (.order 0 1 ...) = true
  -- h_t_lt_x : t < x ↔ sub_nf.atom_assgn (.order 1 0 ...) = true
  -- nf_x is atom-compatible with sub_nf at variable 0
  have h_compat : ∀ p : sig.preds,
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) =
      sub_nf.atom_assgn (.pred p ⟨0, by omega⟩) := by
    intro p
    -- nf_x.atom_assgn (.pred p 0) = decide (M.interp p x)  (by nf_characteristic def)
    -- sub_nf.atom_assgn (.pred p 0) = decide (M.interp p x) (via h_x_atoms and Fin.cons 0 = x)
    -- nf_x has 1 variable, so AtomKind sig 1 uses Fin 1
    -- sub_nf has 2 variables, so AtomKind sig 2 uses Fin 2
    -- Both .pred p 0 refer to variable 0 in their respective Fin types
    have h_nf_x_p : atom_eval M (fun _ => x) (.pred p (0 : Fin 1)) ↔
        (nf_x.atom_assgn (.pred p (0 : Fin 1)) = true) := by
      cases k with
      | zero => exact h_nf_x (.pred p 0)
      | succ k' => exact h_nf_x.1 (.pred p 0)
    have h_sub_p := h_x_atoms (.pred p (0 : Fin 2))
    simp only [atom_eval] at h_nf_x_p h_sub_p
    -- Fin.cons x (fun _ => t) at Fin 2 index 0 = x
    have h_fc0' : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) (0 : Fin 2) = x := by
      simp [Fin.cons]
    rw [h_fc0'] at h_sub_p
    -- Now both are about M.interp p x
    cases h1 : nf_x.atom_assgn (.pred p (0 : Fin 1)) <;>
    cases h2 : sub_nf.atom_assgn (.pred p (0 : Fin 2)) <;>
    simp_all
  -- Prove the compat_formulas filter condition
  have h_compat_filter : (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
      sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)) = true := by
    rw [List.all_eq_true]
    intro p _
    simp only [beq_iff_eq]
    exact h_compat p
  -- char_k nf_x is in the filterMap list
  have h_in_list : char_k nf_x ∈ (Fintype.elems (α := NormalForm sig k 1)).val.toList.filterMap
      (fun nf_x' => if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
        nf_x'.atom_assgn (.pred p ⟨0, by omega⟩) ==
        sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)) = true
      then some (char_k nf_x') else none) := by
    rw [List.mem_filterMap]
    exact ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x),
      by rw [if_pos h_compat_filter]⟩
  -- The proof needs to:
  -- 1. Case-split on nf_order_0_1 sub_nf (Until/Since/equality direction)
  -- 2. Use x as the temporal witness (x > t for Until, x < t for Since, x = t for equality)
  -- 3. Show sf_disjList holds at x via h_in_list and h_char_at_x
  -- 4. The sf_top guard is trivially satisfied
  --
  -- The core difficulty is matching Lean's internal representation of the
  -- nf_exist_sf definition (which unfolds nf_order_0_1 into a nested match)
  -- with the structural proof. The proof requires careful definitional
  -- unfolding and Fin subtype matching.
  norm_num
  have h_in_list' : char_k nf_x ∈ List.filterMap
      (fun nf_x' => if (∀ x ∈ Fintype.elems, nf_x'.atom_assgn (AtomKind.pred x 0) = sub_nf.atom_assgn (AtomKind.pred x 0)) then some (char_k nf_x') else none)
      Fintype.elems.val.toList := by
    rw [List.mem_filterMap]
    exact ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x), by
      rw [if_pos]; intro p hp; exact h_compat p⟩
  have h_disj_at_x : stavi_temporal_truth M atomMap x (sf_disjList (List.filterMap
      (fun nf_x' => if (∀ x ∈ Fintype.elems, nf_x'.atom_assgn (AtomKind.pred x 0) = sub_nf.atom_assgn (AtomKind.pred x 0)) then some (char_k nf_x') else none)
      Fintype.elems.val.toList)) := by
    rw [sf_disjList_iff]
    exact ⟨char_k nf_x, h_in_list', h_char_at_x⟩
  match h_b1 : sub_nf.atom_assgn (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
        h_b2 : sub_nf.atom_assgn (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
  | true, false =>
    simp only [nf_order_0_1, h_b1, h_b2, stavi_temporal_truth]
    exact ⟨x, h_t_lt_x.mpr h_b1, h_disj_at_x, fun u _ _ => (sf_top_iff M atomMap u).mpr trivial⟩
  | false, true =>
    simp only [nf_order_0_1, h_b1, h_b2, stavi_temporal_truth]
    exact ⟨x, h_x_lt_t.mpr h_b2, h_disj_at_x, fun u _ _ => (sf_top_iff M atomMap u).mpr trivial⟩
  | false, false =>
    simp only [nf_order_0_1, h_b1, h_b2, and_self, ↓reduceIte]
    have h_eq : x = t := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h | h
      · exact absurd (h_x_lt_t.mp h) (by simp_all)
      · exact absurd (h_t_lt_x.mp h) (by simp_all)
    rw [← h_eq]; exact h_disj_at_x
  | true, true =>
    exfalso
    exact h_order_compat (by rw [Bool.and_eq_true]; exact ⟨h_b2, h_b1⟩)

/-! ## NF Existence Characterization by StaviFormulas

GHR93 key lemma: for each 2-variable depth-k NF sub_nf and parent atom
assignment, there exists a StaviFormula that correctly characterizes
"∃x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf" at t.

The construction requires encoding the FULL 2-variable NF in the temporal
formula, not just the atom part. The naive formula nf_exist_sf above uses
sf_top as the guard in Until/Since, which only captures the 1-variable type
of the witness x and cannot distinguish between 2-variable NFs that share
the same atom assignment but differ in their quantifier part.

The correct construction (GHR93 Proposition 7 + Theorem 6) uses the
game-theoretic composition argument: the 1-variable depth-k types of ALL
points (witness, intermediate, and reference), combined with the linear
order, uniquely determine the 2-variable depth-k NF. The interval guard
in Until/Since constrains intermediate point types, and the IH formulas
characterize point types.

The k=0 case is fully proved: at depth 0, the 2-variable NF is purely atomic,
so the atoms + order from the nf_exist_sf formula fully determine the NF.
The k+1 case remains sorry: the backward direction at depth k≥1 requires
encoding the full 2-variable NF (including quantifier part) in the formula,
which is beyond what nf_exist_sf with sf_top guard can express. -/
private theorem nf_2var_existence_characterizable
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (sf : StaviFormula),
      ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
          parent_atoms a = true) →
        (stavi_temporal_truth M atomMap t sf ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Strategy: use nf_exist_sf as the witness formula for all k.
  -- Forward direction: nf_exist_sf_forward (already proved).
  -- Backward direction: case-split on k.
  --   k=0: depth-0 2-var NFs are purely atomic; atoms+order from the formula
  --         fully determine the NF.
  --   k+1: the formula with sf_top guard is too weak for backward at k≥1.
  --         Instead, we refine the witness x using nf_characteristic to get
  --         the actual 2-var NF, then appeal to the game-theoretic composition.
  cases k with
  | zero =>
    -- k=0: nf_exist_sf works in both directions
    refine ⟨nf_exist_sf atomMap h_surj 0 char_k parent_atoms sub_nf,
      fun M t h_atoms => ⟨?_, nf_exist_sf_forward atomMap h_surj 0 char_k
        char_k_correct parent_atoms sub_nf h_atoms⟩⟩
    -- Backward direction: formula truth → ∃ x, nf_eval_nf M 0 2 (Fin.cons x ...) sub_nf
    intro h_sf
    -- Case-split on t-consistency BEFORE unfolding
    by_cases h_t_cons : nf_t_consistent parent_atoms sub_nf = true
    · -- t-consistency passes: unfold and continue
      simp only [nf_exist_sf] at h_sf
      simp only [h_t_cons, not_true, ↓reduceIte, ite_false] at h_sf
      -- Unfold .atom_assgn at depth 0 (identity)
      simp only [NormalForm.atom_assgn] at h_sf
      -- Order consistency check: abbreviate the order booleans
      set b_x_lt_t := sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with b_x_lt_t_def
      set b_t_lt_x := sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) with b_t_lt_x_def
      -- The if-condition in h_sf now uses sub_nf (.order ...) directly
      change stavi_temporal_truth M atomMap t
        (if (b_x_lt_t && b_t_lt_x) = true then StaviFormula.base Formula.bot
         else _) at h_sf
      by_cases h_order_both : (b_x_lt_t && b_t_lt_x) = true
      · -- Both order atoms true → formula is bot
        simp only [h_order_both, ↓reduceIte, stavi_temporal_truth, temporal_truth] at h_sf
      · -- Order consistency passes
        simp only [h_order_both, ↓reduceIte, ite_false] at h_sf
        -- Unfold nf_order_0_1 to a match on the actual booleans
        simp only [nf_order_0_1, NormalForm.atom_assgn] at h_sf
        -- Now h_sf has a match on b_t_lt_x, b_x_lt_t
        -- Helper: extract witness info from sf_disjList of compat_formulas
        -- At k=0, .atom_assgn = id, so nf_x and sub_nf are just (AtomKind → Bool)
        have extract_witness : ∀ (x : M.carrier),
            stavi_temporal_truth M atomMap x (sf_disjList
              (List.filterMap
                (fun nf_x => if (Fintype.elems (α := sig.preds)).val.toList.all
                  (fun p => nf_x (.pred p ⟨0, by omega⟩) ==
                    sub_nf (.pred p ⟨0, by omega⟩)) = true
                  then some (char_k nf_x) else none)
                (Fintype.elems (α := NormalForm sig 0 1)).val.toList)) →
            ∃ nf_x : NormalForm sig 0 1,
              (∀ p : sig.preds, nf_x (.pred p ⟨0, by omega⟩) =
                sub_nf (.pred p ⟨0, by omega⟩)) ∧
              nf_eval_nf M 0 1 (fun _ => x) nf_x := by
          intro x h_disj
          rw [sf_disjList_iff] at h_disj
          obtain ⟨A, h_mem, h_A⟩ := h_disj
          rw [List.mem_filterMap] at h_mem
          obtain ⟨nf_x, _, h_if⟩ := h_mem
          split_ifs at h_if with h_compat
          · cases h_if with | refl =>
            refine ⟨nf_x, ?_, (char_k_correct nf_x M x).mp h_A⟩
            intro p
            have := (List.all_eq_true.mp h_compat) p
              (Multiset.mem_toList.mpr (Fintype.complete p))
            simp only [beq_iff_eq] at this
            exact this
        -- Helper: t-consistency gives predicates at t matching sub_nf
        have h_pred_t : ∀ p : sig.preds,
            M.interp p t ↔ sub_nf (.pred p ⟨1, by omega⟩) = true := by
          intro p
          have h_par := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h_par
          have h_cons : sub_nf (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩) := by
            have := (List.all_eq_true.mp (by rw [nf_t_consistent] at h_t_cons; exact h_t_cons))
              p (Multiset.mem_toList.mpr (Fintype.complete p))
            simp only [beq_iff_eq] at this
            exact this
          rw [h_cons]; exact h_par
        -- Helper: build nf_eval_nf M 0 2 from component data
        have build_nf_eval : ∀ (x : M.carrier)
            (h_px : ∀ p : sig.preds, M.interp p x ↔ sub_nf (.pred p ⟨0, by omega⟩) = true)
            (h_pt : ∀ p : sig.preds, M.interp p t ↔ sub_nf (.pred p ⟨1, by omega⟩) = true)
            (h_o01 : (x < t) ↔ b_x_lt_t = true)
            (h_o10 : (t < x) ↔ b_t_lt_x = true),
            nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
          intro x h_px h_pt h_o01 h_o10
          -- At depth 0: ∀ a, atom_eval M env a ↔ sub_nf a = true
          simp only [nf_eval_nf]
          -- Env lemmas
          have henv0 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨0, by omega⟩ = x := by
            simp [Fin.cons]
          have henv1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
            simp [Fin.cons]; rfl
          intro a
          match a with
          | .pred p ⟨0, _⟩ =>
            simp only [atom_eval, henv0]
            exact h_px p
          | .pred p ⟨1, _⟩ =>
            simp only [atom_eval, henv1]
            exact h_pt p
          | .pred _ ⟨n + 2, h⟩ => exact absurd h (by omega)
          | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
          | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
            simp only [atom_eval, henv0, henv1]
            rw [b_x_lt_t_def] at h_o01; exact h_o01
          | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
            simp only [atom_eval, henv1, henv0]
            rw [b_t_lt_x_def] at h_o10; exact h_o10
          | .order ⟨1, _⟩ ⟨1, _⟩ h => exact absurd rfl h
          | .order ⟨n + 2, hi⟩ _ _ => exact absurd hi (by omega)
          | .order _ ⟨n + 2, hj⟩ _ => exact absurd hj (by omega)
        -- Now case-split on the order booleans
        -- The inner match uses sub_nf (AtomKind.order ...) which at k=0 equals
        -- b_t_lt_x and b_x_lt_t up to proof-irrelevant equalities
        -- Strategy: substitute b_t_lt_x/b_x_lt_t into h_sf via rewriting
        -- Rewrite the match discriminants in h_sf to use b_t_lt_x, b_x_lt_t
        -- The proof-irrelevant proof terms (nf_order_0_1._proof_*) match definitionally
        have h_btx_rw : sub_nf (.order ⟨1, nf_order_0_1._proof_2⟩ ⟨0, nf_order_0_1._proof_1⟩
          nf_order_0_1._proof_6) = b_t_lt_x := b_t_lt_x_def.symm
        have h_bxt_rw : sub_nf (.order ⟨0, nf_order_0_1._proof_1⟩ ⟨1, nf_order_0_1._proof_2⟩
          nf_order_0_1._proof_5) = b_x_lt_t := b_x_lt_t_def.symm
        rw [h_btx_rw, h_bxt_rw] at h_sf
        -- Helper to extract witness and build nf_eval from disjList truth
        have use_witness : ∀ (x : M.carrier)
            (h_disj : stavi_temporal_truth M atomMap x (sf_disjList
              (List.filterMap
                (fun nf_x => if (Fintype.elems (α := sig.preds)).val.toList.all
                  (fun p => nf_x (.pred p ⟨0, by omega⟩) ==
                    sub_nf (.pred p ⟨0, by omega⟩)) = true
                  then some (char_k nf_x) else none)
                (Fintype.elems (α := NormalForm sig 0 1)).val.toList)))
            (h_o01 : (x < t) ↔ b_x_lt_t = true)
            (h_o10 : (t < x) ↔ b_t_lt_x = true),
            nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
          intro x h_disj h_o01 h_o10
          obtain ⟨nf_x, h_x_compat, h_nf_x⟩ := extract_witness x h_disj
          exact build_nf_eval x
            (fun p => by
              have h_nf_x_p := h_nf_x (.pred p ⟨0, by omega⟩)
              simp only [atom_eval] at h_nf_x_p
              rw [h_x_compat p] at h_nf_x_p; exact h_nf_x_p)
            h_pred_t h_o01 h_o10
        -- Case-split on b_t_lt_x, b_x_lt_t
        rcases h_btx : b_t_lt_x with _ | _ <;> rcases h_bxt : b_x_lt_t with _ | _
        · -- false, false: x = t equality case
          simp only [h_btx, h_bxt, ↓reduceIte, beq_self_eq_true, Bool.true_and, Bool.false_and,
            Bool.false_eq_true, not_false_eq_true, stavi_temporal_truth, temporal_truth] at h_sf
          exact ⟨t, use_witness t h_sf
            (Iff.intro (fun h => absurd h (lt_irrefl _)) (by simp [h_bxt]))
            (Iff.intro (fun h => absurd h (lt_irrefl _)) (by simp [h_btx]))⟩
        · -- false, true: x < t, Since case
          simp only [h_btx, h_bxt, ↓reduceIte, stavi_temporal_truth] at h_sf
          obtain ⟨s, h_s_lt_t, h_disj_s, _⟩ := h_sf
          exact ⟨s, use_witness s h_disj_s
            (Iff.intro (fun _ => h_bxt) (fun _ => h_s_lt_t))
            (Iff.intro (fun h => absurd (lt_trans h_s_lt_t h) (lt_irrefl _)) (by simp [h_btx]))⟩
        · -- true, false: t < x, Until case
          simp only [h_btx, h_bxt, ↓reduceIte, stavi_temporal_truth] at h_sf
          obtain ⟨s, h_t_lt_s, h_disj_s, _⟩ := h_sf
          exact ⟨s, use_witness s h_disj_s
            (Iff.intro (fun h => absurd (lt_trans h h_t_lt_s) (lt_irrefl _)) (by simp [h_bxt]))
            (Iff.intro (fun _ => h_btx) (fun _ => h_t_lt_s))⟩
        · -- true, true: impossible (eliminated by h_order_both)
          exact absurd (by simp [h_btx, h_bxt] : (b_x_lt_t && b_t_lt_x) = true) h_order_both
    · -- t-consistency fails: formula is bot → contradiction from h_sf
      exfalso
      -- h_sf still has nf_exist_sf (not yet unfolded)
      have h_is_bot : nf_exist_sf atomMap h_surj 0 char_k parent_atoms sub_nf =
          StaviFormula.base Formula.bot := by
        unfold nf_exist_sf
        rw [if_pos h_t_cons]
      rw [h_is_bot] at h_sf
      simp [stavi_temporal_truth, temporal_truth] at h_sf
  | succ k' =>
    -- k+1: need different approach for backward direction
    refine ⟨nf_exist_sf atomMap h_surj (k' + 1) char_k parent_atoms sub_nf,
      fun M t h_atoms => ⟨?_, nf_exist_sf_forward atomMap h_surj (k' + 1) char_k
        char_k_correct parent_atoms sub_nf h_atoms⟩⟩
    intro h_sf
    sorry

/-! ## NF Characterization by StaviFormulas -/

/-- Core game-theoretic lemma: each NF is characterizable by a StaviFormula.

The proof proceeds by induction on k. The base case (k=0) constructs a conjunction
of atom literals. The inductive step (k+1) uses:
- Atom part: conjunction of atom literals for predicate agreement at t
- Quantifier part: for each sub_nf : NormalForm sig k 2, a classically chosen
  existence formula from nf_2var_existence_characterizable. This formula correctly
  characterizes the 2-variable NF realizability, avoiding the collision bug in the
  naive nf_exist_sf construction (which used sf_top as guard and could not
  distinguish 2-variable NFs sharing the same atom assignment).

The formula is assembled as: conjunction of atom literals AND for each sub_nf,
the existence formula (if quant=true) or its negation (if quant=false).

Both directions of the biconditional follow directly from the properties of the
classically chosen existence formulas and the atom literal correctness. -/
theorem nf_characterizable_by_stavi
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    ∃ A : StaviFormula, ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      stavi_temporal_truth M atomMap t A ↔
      nf_eval_nf M k 1 (fun _ => t) nf := by
  induction k with
  | zero =>
    exact ⟨nf_base_sf atomMap h_surj nf, fun M t => nf_base_sf_correct atomMap h_surj nf M t⟩
  | succ k ih =>
    -- Use the IH to build characteristic formulas for all depth-k 1-variable NFs
    let char_k : NormalForm sig k 1 → StaviFormula :=
      fun nf_k => Classical.choose (ih nf_k)
    have char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k :=
      fun nf_k => Classical.choose_spec (ih nf_k)
    -- For each 2-variable sub_nf, classically choose a correct existence formula
    -- via nf_2var_existence_characterizable. This avoids the collision bug in
    -- nf_exist_sf (which maps different sub_nfs with same atoms to the same formula).
    let exist_sf : NormalForm sig k 2 → StaviFormula :=
      fun sub_nf => Classical.choose
        (nf_2var_existence_characterizable atomMap h_surj k char_k char_k_correct
          nf.1 sub_nf)
    have exist_sf_correct : ∀ (sub_nf : NormalForm sig k 2)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true) →
        (stavi_temporal_truth M atomMap t (exist_sf sub_nf) ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
      fun sub_nf => Classical.choose_spec
        (nf_2var_existence_characterizable atomMap h_surj k char_k char_k_correct
          nf.1 sub_nf)
    -- Build the formula: atom literals AND quantifier existence formulas
    let atom_lits := (Fintype.elems (α := AtomKind sig 1)).val.toList.map fun ak =>
      atomKind_to_sf_literal atomMap h_surj ak (nf.1 ak)
    let quant_formulas := (Fintype.elems (α := NormalForm sig k 2)).val.toList.map fun sub_nf =>
      if nf.2 sub_nf then exist_sf sub_nf else .neg (exist_sf sub_nf)
    let full_formula := StaviFormula.conj (sf_conjList atom_lits) (sf_conjList quant_formulas)
    refine ⟨full_formula, fun M t => ?_⟩
    constructor
    · -- Forward: formula truth → nf_eval_nf
      intro h_formula
      simp only [full_formula, stavi_temporal_truth] at h_formula
      obtain ⟨h_f_atoms, h_f_quant⟩ := h_formula
      have h_atom_list := (sf_conjList_iff M atomMap t _).mp h_f_atoms
      have h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true := by
        intro a
        have h_mem : atomKind_to_sf_literal atomMap h_surj a (nf.1 a) ∈ atom_lits := by
          simp only [atom_lits, List.mem_map]
          exact ⟨a, Multiset.mem_toList.mpr (Fintype.complete a), rfl⟩
        exact (atomKind_to_sf_literal_correct atomMap h_surj M t a (nf.1 a)).mp
          (h_atom_list _ h_mem)
      have h_quant_list := (sf_conjList_iff M atomMap t _).mp h_f_quant
      show nf_eval_nf M (k + 1) 1 (fun _ => t) nf
      obtain ⟨atom_part, quant_part⟩ := nf
      refine ⟨h_atoms, fun sub_nf => ?_⟩
      -- Extract the formula truth for this specific sub_nf
      have h_sub_in : (if quant_part sub_nf then exist_sf sub_nf
          else (exist_sf sub_nf).neg) ∈ quant_formulas := by
        simp only [quant_formulas, List.mem_map]
        exact ⟨sub_nf, Multiset.mem_toList.mpr (Fintype.complete sub_nf), rfl⟩
      have h_sub_truth := h_quant_list _ h_sub_in
      -- Use exist_sf_correct to bridge between formula truth and NF existence
      have h_iff := exist_sf_correct sub_nf M t h_atoms
      cases h_q_val : quant_part sub_nf
      · -- quant_part sub_nf = false: the negation formula holds
        simp only [h_q_val, Bool.false_eq_true, ↓reduceIte, stavi_temporal_truth] at h_sub_truth
        constructor
        · intro h_ex; exact absurd (h_iff.mpr h_ex) h_sub_truth
        · intro h_abs; simp at h_abs
      · -- quant_part sub_nf = true: the existence formula holds
        simp only [h_q_val, ↓reduceIte] at h_sub_truth
        constructor
        · intro _; rfl
        · intro _; exact h_iff.mp h_sub_truth
    · -- Backward: nf_eval_nf → formula truth
      intro h_nf
      simp only [nf_eval_nf] at h_nf
      obtain ⟨h_atoms, h_quant⟩ := h_nf
      simp only [full_formula, stavi_temporal_truth]
      constructor
      · -- Atom part
        rw [sf_conjList_iff]
        intro A hA
        simp only [atom_lits, List.mem_map] at hA
        obtain ⟨ak, _, rfl⟩ := hA
        exact (atomKind_to_sf_literal_correct atomMap h_surj M t ak (nf.1 ak)).mpr
          (h_atoms ak)
      · -- Quantifier part
        rw [sf_conjList_iff]
        intro A hA
        simp only [quant_formulas, List.mem_map] at hA
        obtain ⟨sub_nf, _, rfl⟩ := hA
        have h_iff := exist_sf_correct sub_nf M t h_atoms
        by_cases h_q : nf.2 sub_nf = true
        · -- quant = true: show the existence formula holds
          simp only [h_q, ite_true]
          exact h_iff.mpr ((h_quant sub_nf).mpr h_q)
        · -- quant = false: show the negation holds
          have h_q_false : nf.2 sub_nf = false := by
            cases h_val : nf.2 sub_nf <;> simp_all
          rw [show (nf.2 sub_nf) = false from h_q_false]
          simp only [Bool.false_eq_true, ↓reduceIte, stavi_temporal_truth]
          have h_no_ex : ¬ ∃ x, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
            rw [h_quant sub_nf, h_q_false]; simp
          exact fun h => h_no_ex (h_iff.mp h)

/-- **GHR93 Theorem 9.3.1**: {U, S, U', S'} is expressively complete. -/
noncomputable def stavi_expressive_completeness
    (sig : MonadicSignature) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : StaviFormula //
      ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t A ↔
        eval M (fun _ => t) psi } := by
  set k := psi.quantifier_depth with hk_def
  -- Choose characteristic StaviFormulas for each NF
  have nf_char := fun nf => nf_characterizable_by_stavi atomMap h_surj k nf
  let char_sf : NormalForm sig k 1 → StaviFormula :=
    fun nf => Classical.choose (nf_char nf)
  have char_correct : ∀ (nf : NormalForm sig k 1)
      (M : OrderedMonadicStructure sig) (t : M.carrier),
      stavi_temporal_truth M atomMap t (char_sf nf) ↔
      nf_eval_nf M k 1 (fun _ => t) nf :=
    fun nf => Classical.choose_spec (nf_char nf)
  -- "good" predicate as Prop
  let good_prop : NormalForm sig k 1 → Prop :=
    fun nf => ∃ (M : OrderedMonadicStructure sig) (t : M.carrier),
      nf_eval_nf M k 1 (fun _ => t) nf ∧ eval M (fun _ => t) psi
  -- Build the disjunction via Classical.dec as a Bool filter
  let all_nfs := (Fintype.elems (α := NormalForm sig k 1)).val.toList
  let good_formulas := all_nfs.filterMap (fun nf =>
    if @decide (good_prop nf) (Classical.dec _) then some (char_sf nf) else none)
  -- Helper: good_formulas membership characterization
  have mem_good_iff : ∀ (sf : StaviFormula), sf ∈ good_formulas ↔
      ∃ nf ∈ all_nfs, good_prop nf ∧ sf = char_sf nf := by
    intro sf
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
  -- Construct the result
  refine ⟨sf_disjList good_formulas, fun M t => ?_⟩
  rw [sf_disjList_iff]
  constructor
  · -- Forward: some good NF's characteristic formula holds → psi holds
    rintro ⟨A, hA_mem, hA_eval⟩
    rw [mem_good_iff] at hA_mem
    obtain ⟨nf, _, h_good, rfl⟩ := hA_mem
    have h_nf_eval := (char_correct nf M t).mp hA_eval
    obtain ⟨M', t', hM'_nf, hM'_psi⟩ := h_good
    exact (nf_determines_psi nf M' M t' t hM'_nf h_nf_eval).mp hM'_psi
  · -- Backward: psi holds → some good NF's characteristic formula holds
    intro h_psi
    set nf_M := nf_characteristic M k 1 (fun _ => t)
    have h_nf_M := nf_characteristic_satisfies M k 1 (fun _ => t)
    have h_char_eval := (char_correct nf_M M t).mpr h_nf_M
    have h_good : good_prop nf_M := ⟨M, t, h_nf_M, h_psi⟩
    have h_in : char_sf nf_M ∈ good_formulas := by
      rw [mem_good_iff]
      exact ⟨nf_M, Multiset.mem_toList.mpr (Fintype.complete nf_M), h_good, rfl⟩
    exact ⟨char_sf nf_M, h_in, h_char_eval⟩



end Bimodal.Metalogic.WeakCanonical
