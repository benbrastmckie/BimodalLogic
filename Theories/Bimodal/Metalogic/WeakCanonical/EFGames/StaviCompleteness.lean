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

/-! ## NF Characterization by StaviFormulas -/

/-- Core game-theoretic lemma: each NF is characterizable by a StaviFormula.

The proof proceeds by induction on k. The base case (k=0) constructs a conjunction
of atom literals. The inductive step (k+1) splits into:
- Atom part: same conjunction of literals for predicate agreement at t
- Quantifier part: for each sub_nf : NormalForm sig k 2, an existence/non-existence
  formula using Until (for x > t) or Since (for x < t).

For depth-0 sub_nfs, the existence formula is purely atomic (predicate literals
at the quantified variable). For depth-k sub_nfs with k ≥ 1, the IH provides
characteristic StaviFormulas for 1-variable NFs at depth k, which are used to
characterize the quantified variable's type. -/
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
    -- The inductive step requires the GHR93 game-theoretic argument (Section 8).
    -- The IH gives StaviFormulas for 1-variable NFs at depth k, but the
    -- quantifier part of nf involves 2-variable NFs (NormalForm sig k 2).
    -- Expressing "∃x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf"
    -- as a StaviFormula requires characterizing the joint type of (x, t),
    -- which temporal connectives alone cannot capture for k ≥ 1 sub_nfs.
    --
    -- The GHR93 proof handles this via:
    -- (1) Custom EF games G_{n;r} with forward-to-backward theorem (Thm 6)
    -- (2) Composition lemma (Prop 7) composing strategies on sub-intervals
    -- (3) Four cases for the main induction (atoms, Until, Since, Stavi gaps)
    -- (4) Gap detection formulas (Lemma 9) for Stavi connective cases
    --
    -- The existing game infrastructure in this file (EFPosition, game_depth,
    -- ghr93_duplicator_wins, decomposition_agreement, left_formula, etc.)
    -- provides the foundation but the central induction remains.
    sorry

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
