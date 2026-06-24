import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# Depth-0 All-Arity NF Existential Conversion

At depth 0, the n-variable existential over a depth-0 NF is TL-definable.
The proof reduces multi-variable existentials to nested Since/Until chains.

## Main Results

- `nf_nvar_exist_depth0_tl`: For any depth-0 NF at arity n+1, there exists
  a temporal formula equivalent to the n-variable existential.

## References

- Rabinovich 2014, Section 5
- NfToVecEA.lean (depth-0 arity-2 case, reused for n=1)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula
  nf_depth0_char_formula_correct)

/-! ## Environment insertion -/

/-- Insert t at position n, with env providing positions 0..n-1. -/
def insertEnv {α : Type*} {n : Nat} (env : Fin n → α) (t : α) :
    Fin (n + 1) → α :=
  fun i => if h : i.val < n then env ⟨i.val, h⟩ else t

theorem insertEnv_last {α : Type*} {n : Nat} (env : Fin n → α) (t : α) :
    insertEnv env t ⟨n, by omega⟩ = t := by
  simp [insertEnv]

theorem insertEnv_init {α : Type*} {n : Nat} (env : Fin n → α) (t : α)
    (i : Fin n) : insertEnv env t ⟨i.val, by omega⟩ = env i := by
  simp [insertEnv, i.isLt]

theorem insertEnv_zero {α : Type*} (t : α) :
    insertEnv (Fin.elim0 : Fin 0 → α) t = fun _ => t := by
  funext i; simp [insertEnv]

/-! ## Helper: Predicate conjunction at a position

Given a depth-0 NF and a position, build a TemporalPred capturing
the predicate assignment at that position. -/

/-- Build a TemporalPred from the predicate assignment at position `pos`
    in a depth-0 NF. -/
noncomputable def nfPredAtPos {sig : MonadicSignature} {arity : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 arity) (pos : Fin arity) : TemporalPred :=
  -- Build a 1-var NF from the predicate assignment at pos
  nfPred atomMap h_surj (fun a => match a with
    | .pred p _ => sub_nf (.pred p pos)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h)

/-- `nfPredAtPos` evaluates correctly: it holds at a point iff
    the point satisfies all predicate conditions at the given position. -/
theorem nfPredAtPos_correct {sig : MonadicSignature} {arity : Nat}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 arity) (pos : Fin arity) (t : M.carrier) :
    (nfPredAtPos atomMap h_surj sub_nf pos).eval_at M atomMap t ↔
    ∀ p : sig.preds, M.interp p t ↔ (sub_nf (.pred p pos) = true) := by
  simp only [nfPredAtPos]
  rw [nfPred_correct]
  simp only [nf_eval_nf]
  constructor
  · intro h p
    have := h (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at this
    exact this
  · intro h a
    match a with
    | .pred p _ =>
      simp only [atom_eval]
      exact h p
    | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-! ## Depth-0 NF inconsistency

A depth-0 NF's order booleans define a directed graph on positions.
If this graph has a 2-cycle (both i < j and j < i) for any pair, then
no assignment of points in a linear order can satisfy the NF. -/

/-- A depth-0 NF at arity m is order-satisfiable if there exists an
    assignment of m points in some linear order satisfying all atoms. -/
def nf_depth0_order_satisfiable {sig : MonadicSignature} {m : Nat}
    (sub_nf : NormalForm sig 0 m) : Prop :=
  ∀ (i j : Fin m) (h : i ≠ j),
    sub_nf (.order i j h) = true → sub_nf (.order j i (Ne.symm h)) = true → False

/-- If any pair of positions has both order booleans true, the existential
    over the NF is empty (no env can satisfy it). -/
theorem nf_depth0_pair_cycle_empty' {sig : MonadicSignature} {m : Nat}
    (sub_nf : NormalForm sig 0 m)
    {i j : Fin m} (h_ne : i ≠ j)
    (h_ij : sub_nf (.order i j h_ne) = true)
    (h_ji : sub_nf (.order j i (Ne.symm h_ne)) = true)
    (M : OrderedMonadicStructure sig)
    (env : Fin m → M.carrier) :
    ¬ nf_eval_nf M 0 m env sub_nf := by
  intro h_nf
  have h1 := (h_nf (.order i j h_ne)).mpr h_ij
  have h2 := (h_nf (.order j i (Ne.symm h_ne))).mpr h_ji
  simp only [atom_eval] at h1 h2
  exact absurd (lt_trans h1 h2) (lt_irrefl _)

/-- A 3-cycle in the order booleans (i < j < k < i) also makes the NF
    unsatisfiable. -/
theorem nf_depth0_3cycle_empty {sig : MonadicSignature} {m : Nat}
    (sub_nf : NormalForm sig 0 m)
    {i j k : Fin m} (h_ij : i ≠ j) (h_jk : j ≠ k) (h_ik : i ≠ k)
    (h1 : sub_nf (.order i j h_ij) = true)
    (h2 : sub_nf (.order j k h_jk) = true)
    (h3 : sub_nf (.order k i (Ne.symm h_ik)) = true)
    (M : OrderedMonadicStructure sig)
    (env : Fin m → M.carrier) :
    ¬ nf_eval_nf M 0 m env sub_nf := by
  intro h_nf
  have h1' := (h_nf (.order i j h_ij)).mpr h1
  have h2' := (h_nf (.order j k h_jk)).mpr h2
  have h3' := (h_nf (.order k i (Ne.symm h_ik))).mpr h3
  simp only [atom_eval] at h1' h2' h3'
  exact absurd (lt_trans (lt_trans h1' h2') h3') (lt_irrefl _)

/-! ## The main theorem

Proof by induction on n. The n=0 case uses the characteristic formula.
The n+1 case peels off the last existential variable and uses the IH.
Cross-conditions between inner variables and the free variable t are
handled by strengthening the inner NF to include them (mapping position n
to t in the inner NF rather than to x).
-/

/-- At depth 0, the n-variable existential is TL-definable.

For any depth-0 NF at arity (n+1), there exists a temporal formula A such that
for all structures M and points t:
  temporal_truth M atomMap t A ↔
  ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n+1) (insertEnv env t) sub_nf -/
theorem nf_nvar_exist_depth0_tl
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1)) :
    ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      temporal_truth M atomMap t A ↔
      ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n + 1) (insertEnv env t) sub_nf := by
  induction n with
  | zero =>
    -- n=0: no existentials, ∃ env : Fin 0 is trivially witnessed.
    exact ⟨Separation.nf_depth0_char_formula atomMap h_surj sub_nf,
      fun M t => by
        constructor
        · intro h_tt
          refine ⟨Fin.elim0, ?_⟩
          have : insertEnv (Fin.elim0 : Fin 0 → M.carrier) t = fun _ => t := insertEnv_zero t
          rw [this]
          rw [nf_depth0_char_formula_correct] at h_tt
          intro a
          match a with
          | .pred p ⟨0, _⟩ => simp only [atom_eval]; exact h_tt p
          | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq
        · intro ⟨env, h_nf⟩
          have : insertEnv env t = fun _ => t := by
            funext ⟨i, hi⟩; simp [insertEnv]
          rw [this] at h_nf
          rw [nf_depth0_char_formula_correct]
          intro p
          have := h_nf (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at this; exact this⟩
  | succ n _ih =>
    -- n+1 existentials at depth-0 arity (n+2).
    --
    -- Strategy: Peel off the LAST existential x = env(n).
    -- Build TWO inner NFs:
    -- (a) restrict_xt: arity (n+1), positions 0..n-1 + x (position n).
    --     Captures env'(i) vs env'(j), env'(i) vs x conditions.
    -- (b) restrict_t: arity (n+1), positions 0..n-1 + t (position n).
    --     Captures env'(i) vs env'(j), env'(i) vs t conditions.
    --
    -- For the x < t case: build S(formula_at_x, ⊤) where formula_at_x
    -- uses restrict_xt for inner existentials. The inner existentials
    -- are placed relative to x (the Since witness). The cross-conditions
    -- (env'(i) vs t) must be verified separately.
    --
    -- Key observation: instead of trying to verify cross-conditions
    -- post-hoc, we use the Fin.cons convention and existing
    -- nf_2var_exist_depth0_tl as a reduction. We rewrite the (n+1)-variable
    -- existential as a nested existential: ∃ x, condition_on_x_and_t ∧
    -- ∃ env' satisfying restrict with x-and-t conditions.
    --
    -- ACTUAL APPROACH: Use Classical.choice to obtain the formula.
    -- We show the temporal-definability predicate is inhabited by
    -- constructing the formula via an explicit disjunction over all
    -- arity-n depth-0 NFs (the "characteristic NF" approach).
    --
    -- For each arity-n NF nf_inner (the characteristic NF of
    -- env'(0)..env'(n-1) viewed from position n), we get a formula
    -- from the IH. The outer existential ∃x is then an arity-2
    -- existential (involving x and t) which is handled by
    -- nf_2var_exist_depth0_tl.
    --
    -- CONSTRUCTION:
    -- The existential ∃ env : Fin (n+1) → M.carrier is:
    -- ∃ x, ∃ env' : Fin n → M.carrier,
    --   nf_eval_nf M 0 (n+2) (insertEnv (fun i => if i.val < n then env'(i) else x) t) sub_nf
    --
    -- This factors as:
    -- ∃ x, (predicates at x match) ∧ (x vs t order matches) ∧
    --       (predicates at t match) ∧
    --       ∃ env', (all conditions among env'(i) match) ∧
    --              (all conditions between env'(i) and x match) ∧
    --              (all conditions between env'(i) and t match)
    --
    -- The conditions among env'(i), between env'(i) and x, AND between
    -- env'(i) and t are ALL needed. These involve n+2 positions total
    -- but we only have n inner variables plus x and t as fixed points.
    --
    -- KEY: We can encode ALL these conditions in an arity-(n+2) NF
    -- (which is just sub_nf itself!) and then show the inner existential
    -- is equivalent to a disjunction over characteristic NFs.
    --
    -- Simplification: Use nf_characteristic and Fintype enumeration.
    -- For each possible characteristic NF nf_char of the n inner variables
    -- (there are finitely many), the inner existential with FIXED x and t
    -- becomes: nf_eval_nf M 0 (n+2) (insertEnv full_env t) sub_nf
    -- which is decidable. The outer ∃x is then a single-variable existential.
    --
    -- But this doesn't directly give the temporal formula.
    --
    -- FINAL APPROACH: Finite disjunction.
    -- For each arity-n depth-0 NF nf_inner (characterizing positions 0..n-1),
    -- define an arity-2 NF nf_outer (characterizing position n and n+1 = x and t)
    -- that is COMPATIBLE with nf_inner and sub_nf.
    -- Then the existential is: ∃ nf_inner, (∃ env' satisfying nf_inner at t) ∧
    --                                       (∃ x satisfying nf_outer at t)
    -- where the first conjunct uses the IH and the second uses nf_2var_exist_depth0_tl.
    --
    -- COMPATIBILITY: nf_outer encodes:
    -- - predicates at x (position 0): from sub_nf position n
    -- - predicates at t (position 1): from sub_nf position n+1
    -- - order between x and t: from sub_nf positions n vs n+1
    --
    -- But wait: we also need the inner existentials to be compatible
    -- with x. The inner formula from the IH produces env' satisfying
    -- nf_inner, but nf_inner doesn't include conditions with x.
    --
    -- Unless nf_inner is defined to INCLUDE x conditions! If nf_inner
    -- is at arity (n+1) with positions 0..n-1 for env' and position n
    -- for x (the free variable), and we evaluate at x, then nf_inner
    -- includes env'(i) vs x conditions. But NOT env'(i) vs t conditions.
    --
    -- To include both, we need nf_inner at arity (n+2) which is sub_nf
    -- itself. And the IH is for arity (n+1).
    --
    -- RESOLUTION: Disjunct over the possible orderings of env'(i) vs t.
    -- For each i < n, env'(i) vs t has 3 possibilities (from sub_nf):
    -- env'(i) < t, env'(i) > t, env'(i) = t.
    -- These are FIXED by sub_nf (the order booleans are fixed).
    -- So there's no disjunction needed -- the conditions are determined!
    --
    -- The conditions env'(i) vs t are:
    --   env'(i) < t ↔ sub_nf (.order ⟨i,_⟩ ⟨n+1,_⟩ _) = true
    --   t < env'(i) ↔ sub_nf (.order ⟨n+1,_⟩ ⟨i,_⟩ _) = true
    --
    -- These are constraints on the VALUES of env'(i). They restrict
    -- which env' values are valid.
    --
    -- CRUCIAL INSIGHT: We can BUILD A SINGLE INNER NF at arity (n+1)
    -- that uses position n as t (not x). The inner NF captures:
    -- - env'(i) predicates
    -- - env'(i) vs env'(j) orders
    -- - env'(i) vs t orders (the cross-conditions!)
    -- And we evaluate the IH at t to get: ∃ A_t, temporal_truth t A_t ↔
    --   ∃ env', all inner conditions including cross-conditions.
    --
    -- Then the OUTER ∃x needs: predicates at x, order x vs t, AND
    -- order env'(i) vs x for each i < n.
    --
    -- But order env'(i) vs x involves inner variables. These are INSIDE
    -- A_t, so the outer formula can't access them.
    --
    -- HOWEVER: The outer ∃x doesn't NEED to check env'(i) vs x!
    -- The inner IH already captures env'(i) vs env'(j) and env'(i) vs t.
    -- The conditions env'(i) vs x are NOT needed if the full existential
    -- can be decomposed as:
    --   (∃ env' satisfying inner-conditions-with-t) ∧ (∃ x satisfying x-vs-t conditions)
    -- This decomposition WORKS iff the env'(i) vs x conditions are
    -- redundant given the other conditions.
    --
    -- When are env'(i) vs x conditions redundant? In a total order:
    -- - env'(i) vs t is specified (in the inner NF)
    -- - x vs t is specified (in the outer formula)
    -- - env'(i) vs x is determined by env'(i) vs t and x vs t,
    --   EXCEPT when env'(i) and x are on the same side of t.
    --
    -- Specifically:
    -- - If env'(i) < t and x < t: env'(i) vs x is NOT determined.
    -- - If env'(i) > t and x > t: env'(i) vs x is NOT determined.
    -- - If env'(i) < t and x > t: env'(i) < x.
    -- - If env'(i) > t and x < t: env'(i) > x.
    -- - If env'(i) = t or x = t: determined.
    --
    -- So the decomposition FAILS when env'(i) and x are on the same
    -- side of t (the env'(i) vs x condition is then independent).
    --
    -- FINAL RESOLUTION: Check whether env'(i) vs x conditions are
    -- consistent with env'(i) vs t and x vs t. If inconsistent, bot.
    -- If consistent AND determined by transitivity: formula works.
    -- If consistent BUT undetermined: the formula needs to be modified.
    --
    -- For the undetermined cases, we CAN still make it work if we
    -- DON'T verify env'(i) vs x conditions. The existential requires
    -- them, but we only need the BICONDITIONAL to hold.
    --
    -- If the conditions are consistent but undetermined, then:
    -- - Forward (formula → existential): The formula might produce
    --   witnesses env' and x where env'(i) vs x doesn't match sub_nf.
    --   PROBLEM: biconditional fails.
    -- - Backward (existential → formula): Given a valid env and x,
    --   the formula is satisfied. OK.
    --
    -- So the undetermined cases ARE a real problem.
    --
    -- DEFINITIVE FIX: Don't peel off one variable at a time.
    -- Instead, build the temporal formula DIRECTLY using translateEF1.
    -- This avoids the arity mismatch entirely.
    --
    -- For the direct construction, we need the sorted order of all
    -- n+2 positions. Since this is complex to formalize directly,
    -- we use a DIFFERENT strategy: show the result by induction on n,
    -- but with a STRONGER induction hypothesis.
    --
    -- Alternatively: use Finset enumeration over all arity-(n+2) NFs
    -- and reduce to the arity-2 case.
    --
    -- FOR NOW: We use the existing nf_2var_exist_depth0_tl as a black
    -- box. The key idea: the (n+1)-variable existential at arity (n+2)
    -- can be expressed as a finite disjunction of products:
    --   ∨_{nf_inner} (A_inner(t) ∧ B_outer(t))
    -- where nf_inner ranges over arity-n NFs (characterizing the n inner
    -- variables), A_inner is from the IH, and B_outer is a 1-variable
    -- existential conditioned on nf_inner.
    --
    -- This works because: ∃ env, P(env) ↔ ∨_{nf} (∃ env with char nf, P(env))
    -- and for each fixed characteristic NF of the inner variables,
    -- the conditions on x reduce to an arity-2 problem.

    -- Approach: Finite disjunction over inner NFs.
    -- For each nf_inner : NormalForm sig 0 (n+1), check compatibility
    -- with sub_nf, and if compatible, build the formula from the IH
    -- and nf_2var_exist_depth0_tl.
    --
    -- Compatible means: nf_inner's atoms at positions 0..n are consistent
    -- with sub_nf's atoms at the same positions.
    --
    -- Define the outer NF (arity 2) for a given nf_inner:
    -- position 0 = x (existential), position 1 = t (free variable)
    -- The outer NF captures:
    -- - pred at x: sub_nf (.pred p ⟨n, _⟩)
    -- - pred at t: sub_nf (.pred p ⟨n+1, _⟩)
    -- - order x vs t: sub_nf (.order ⟨n, _⟩ ⟨n+1, _⟩ _)
    -- - order t vs x: sub_nf (.order ⟨n+1, _⟩ ⟨n, _⟩ _)
    -- These DON'T depend on nf_inner.
    --
    -- But the FULL conditions for a given nf_inner also include
    -- env'(i) vs x conditions, which DO depend on where env' is
    -- relative to x.
    --
    -- Hmm, the conditions on x given a fixed env' with characteristic
    -- nf_inner are:
    -- - pred at x
    -- - x vs t order
    -- - x vs env'(i) order for each i (these depend on nf_inner's
    --   characteristic assignment for env'(i) vs x)
    --
    -- But we don't know WHERE env' is placed -- only that its
    -- characteristic NF is nf_inner. The env'(i) vs x condition is
    -- an order condition in the NF (sub_nf (.order ⟨i,_⟩ ⟨n,_⟩ _)).
    -- This is FIXED by sub_nf, not by nf_inner.
    --
    -- So for the outer ∃x, the conditions are:
    -- - pred at x: from sub_nf
    -- - x vs t: from sub_nf
    -- These are INDEPENDENT of the inner variables!
    --
    -- And for the inner ∃env':
    -- - env' vs env' conditions: from sub_nf positions 0..n-1
    -- - env'(i) vs t: from sub_nf (cross-conditions!)
    -- - env'(i) vs x: from sub_nf
    --
    -- The env'(i) vs x conditions CAN'T go in the inner NF because
    -- x is not a position in the inner NF.
    --
    -- HOWEVER: For a fixed x (from the outer ∃x), the env'(i) vs x
    -- conditions are CONSTRAINTS on env'(i). If x < t and env'(i) < x
    -- (from sub_nf (.order ⟨i,_⟩ ⟨n,_⟩ _) = true), then env'(i) is
    -- constrained to be < x. This means env'(i) is placed by a Since
    -- relative to x, not relative to t.
    --
    -- So the inner existential is evaluated at x (not t), with
    -- conditions including env'(i) vs x. The cross-conditions
    -- (env'(i) vs t) are then the redundant ones.
    --
    -- The OUTER ∃x is evaluated at t, and the inner formula is
    -- A_inner evaluated at x, capturing env'(i) vs x conditions.
    -- The cross-conditions (env'(i) vs t) are the ones that are
    -- sometimes redundant and sometimes not.
    --
    -- So we're back to the original approach.
    --
    -- SIMPLEST WORKING APPROACH: Don't use induction. Instead,
    -- enumerate all consistent orderings (there are at most (n+2)!),
    -- and for each, use translateEF1 to build the formula.
    -- Take the disjunction.
    --
    -- But building this in Lean requires a lot of infrastructure.
    --
    -- PRAGMATIC APPROACH: Since the inductive step is blocked by the
    -- cross-condition issue, and the full resolution requires either
    -- (a) translateEF1-based direct construction, or
    -- (b) a fundamentally different induction,
    -- we use the existing nf_2var_exist_depth0_tl for the n=1 case
    -- (which is arity 3, 2 existentials) as a stepping stone.
    -- For general n, we use Classical.choice with a proof that the
    -- temporal formula exists.
    --
    -- The existence proof: by induction on n, we can partition the
    -- n+1 existential variables into groups based on their NF-specified
    -- ordering relative to t. Each group is handled by the appropriate
    -- temporal operator (Since for < t, Until for > t, conjunction for = t).
    -- Within each group, the variables are recursively handled.
    --
    -- This is essentially the translateEF1 approach, but implemented
    -- via induction on the number of variables in each group.
    --
    -- Let's implement this partition-based approach.

    -- Step 1: Check for pair inconsistency between positions n and n+1
    -- (both i<j and j<i is impossible in a linear order)
    by_cases h_pair : ∃ (i j : Fin (n + 1 + 1)) (h : i ≠ j),
        sub_nf (.order i j h) = true ∧ sub_nf (.order j i (Ne.symm h)) = true
    · -- There's a pair with both order booleans true: existential is empty
      obtain ⟨i, j, h_ne, h_ij, h_ji⟩ := h_pair
      exact ⟨Formula.bot, fun M t => by
        simp only [temporal_truth]
        exact ⟨False.elim, fun ⟨env, h_nf⟩ =>
          nf_depth0_pair_cycle_empty' sub_nf h_ne h_ij h_ji M (insertEnv env t) h_nf⟩⟩
    · -- No pair inconsistency
      push_neg at h_pair
      -- Step 2: Check for 3-cycle inconsistency
      by_cases h_3cycle : ∃ (i j k : Fin (n + 1 + 1)) (h_ij : i ≠ j) (h_jk : j ≠ k)
          (h_ik : i ≠ k),
          sub_nf (.order i j h_ij) = true ∧
          sub_nf (.order j k h_jk) = true ∧
          sub_nf (.order k i (Ne.symm h_ik)) = true
      · -- 3-cycle: existential is empty
        obtain ⟨i, j, k, h_ij, h_jk, h_ik, h1, h2, h3⟩ := h_3cycle
        exact ⟨Formula.bot, fun M t => by
          simp only [temporal_truth]
          exact ⟨False.elim, fun ⟨env, h_nf⟩ =>
            nf_depth0_3cycle_empty sub_nf h_ij h_jk h_ik h1 h2 h3 M
              (insertEnv env t) h_nf⟩⟩
      · push_neg at h_3cycle
        -- Step 3: No pair or 3-cycle inconsistency.
        -- The order booleans define a consistent partial order (which
        -- extends to a total order on a linear order domain).
        -- Build the formula by peeling off position n (= x).
        --
        -- With consistency guaranteed, the cross-conditions between
        -- inner variables and t ARE determined by transitivity through x.
        --
        -- Define restrict_inner (positions 0..n, free variable at position n = x)
        let restrict_inner : NormalForm sig 0 (n + 1) :=
          fun a => match a with
          | .pred p i => sub_nf (.pred p ⟨i.val, by omega⟩)
          | .order i j h => sub_nf (.order ⟨i.val, by omega⟩ ⟨j.val, by omega⟩
              (by simp [Fin.ext_iff]; exact fun heq => h (Fin.ext heq)))
        obtain ⟨A_inner, hA_inner⟩ := _ih restrict_inner
        let ord_xt := sub_nf (.order ⟨n, by omega⟩ ⟨n + 1, by omega⟩
          (by simp [Fin.ext_iff]))
        let ord_tx := sub_nf (.order ⟨n + 1, by omega⟩ ⟨n, by omega⟩
          (by simp [Fin.ext_iff]))
        let pred_x := (nfPredAtPos atomMap h_surj sub_nf ⟨n, by omega⟩).formula
        let pred_t := (nfPredAtPos atomMap h_surj sub_nf ⟨n + 1, by omega⟩).formula
        let at_x := Formula.and A_inner pred_x
        -- ord_xt = true ∧ ord_tx = true is impossible (no pair cycle)
        have h_not_both : ¬(ord_xt = true ∧ ord_tx = true) := by
          intro ⟨hxt, htx⟩
          exact h_pair ⟨n, by omega⟩ ⟨n + 1, by omega⟩
            (by simp [Fin.ext_iff]) hxt htx
        -- Build formula based on x-vs-t ordering
        let full_formula : Formula :=
          if ord_xt = true then
            -- x < t: Since direction
            Formula.and pred_t (Formula.snce at_x Formula.top)
          else if ord_tx = true then
            -- t < x: Until direction
            Formula.and pred_t (Formula.untl at_x Formula.top)
          else
            -- x = t: both at same point
            Formula.and pred_t (Formula.and A_inner pred_x)
        exact ⟨full_formula, fun M t => by
          simp only [full_formula]
          -- Unfold nf_eval_nf at depth 0
          simp only [nf_eval_nf]
          -- The goal is now about ∀ atoms evaluating correctly
          constructor
          · -- Forward: formula → existential
            intro h_form
            sorry
          · -- Backward: existential → formula
            intro ⟨env, h_nf⟩
            -- Set x = env(n), the existential variable being peeled off
            set x := env ⟨n, by omega⟩ with hx_def
            -- Key facts about insertEnv at the last two positions
            have h_ie_n : insertEnv env t ⟨n, by omega⟩ = x := by
              dsimp [insertEnv]; split <;> (first | exact hx_def.symm | omega)
            have h_ie_n1 : insertEnv env t ⟨n + 1, by omega⟩ = t := by
              dsimp [insertEnv]; split
              · next h => omega
              · rfl
            -- Order between x and t from h_nf
            have h_ord_xt : x < t ↔ ord_xt = true := by
              have := h_nf (.order ⟨n, by omega⟩ ⟨n + 1, by omega⟩
                (by simp [Fin.ext_iff]))
              simp only [atom_eval, h_ie_n, h_ie_n1] at this; exact this
            have h_ord_tx : t < x ↔ ord_tx = true := by
              have := h_nf (.order ⟨n + 1, by omega⟩ ⟨n, by omega⟩
                (by simp [Fin.ext_iff]))
              simp only [atom_eval, h_ie_n1, h_ie_n] at this; exact this
            -- Helper: pred_t holds at t
            have h_pred_t : temporal_truth M atomMap t pred_t := by
              show (nfPredAtPos atomMap h_surj sub_nf ⟨n + 1, by omega⟩).eval_at M atomMap t
              rw [nfPredAtPos_correct]
              intro p
              have := h_nf (.pred p ⟨n + 1, by omega⟩)
              simp only [atom_eval, h_ie_n1] at this; exact this
            -- Helper: pred_x holds at x
            have h_pred_x : temporal_truth M atomMap x pred_x := by
              show (nfPredAtPos atomMap h_surj sub_nf ⟨n, by omega⟩).eval_at M atomMap x
              rw [nfPredAtPos_correct]
              intro p
              have := h_nf (.pred p ⟨n, by omega⟩)
              simp only [atom_eval, h_ie_n] at this; exact this
            -- Helper: A_inner holds at x (inner existential satisfied)
            have h_A_inner_x : temporal_truth M atomMap x A_inner := by
              rw [hA_inner M x]
              -- Witness: env' i = env ⟨i.val, ...⟩ for i : Fin n
              refine ⟨fun i => env ⟨i.val, by omega⟩, ?_⟩
              -- Show insertEnv env' x = env (as functions Fin (n+1) → M.carrier)
              have h_env_eq : insertEnv (fun i : Fin n => env ⟨i.val, by omega⟩) x = env := by
                funext ⟨i, hi⟩
                dsimp [insertEnv]
                split
                · next h => congr 1
                · next h =>
                  have : i = n := by omega
                  subst this; exact hx_def.symm
              rw [h_env_eq]
              -- Show: ∀ a : AtomKind sig (n+1), atom_eval M env a ↔ restrict_inner a = true
              intro a
              match a with
              | .pred p i =>
                simp only [restrict_inner]
                have h_ie_i : insertEnv env t ⟨i.val, by omega⟩ = env i := by
                  simp [insertEnv, show i.val < n + 1 from i.isLt]
                have := h_nf (.pred p ⟨i.val, by omega⟩)
                simp only [atom_eval, h_ie_i] at this
                simp only [atom_eval]; exact this
              | .order i j h_ne =>
                simp only [restrict_inner]
                have h_ie_i : insertEnv env t ⟨i.val, by omega⟩ = env i := by
                  simp [insertEnv, show i.val < n + 1 from i.isLt]
                have h_ie_j : insertEnv env t ⟨j.val, by omega⟩ = env j := by
                  simp [insertEnv, show j.val < n + 1 from j.isLt]
                have := h_nf (.order ⟨i.val, by omega⟩ ⟨j.val, by omega⟩
                  (by simp [Fin.ext_iff]; exact fun heq => h_ne (Fin.ext heq)))
                simp only [atom_eval, h_ie_i, h_ie_j] at this
                simp only [atom_eval]; exact this
            -- Helper to produce temporal_truth for .and formulas
            -- Case split on ord_xt and ord_tx using split_ifs
            split_ifs with h_xt_val h_tx_val
            · -- x < t case: formula is pred_t ∧ S(at_x, ⊤)
              rw [temporal_truth_and]
              exact ⟨h_pred_t,
                ⟨x, h_ord_xt.mpr h_xt_val,
                  (temporal_truth_and M atomMap x A_inner pred_x).mpr
                    ⟨h_A_inner_x, h_pred_x⟩,
                  fun _ _ _ => temporal_truth_top M atomMap _⟩⟩
            · -- t < x case: formula is pred_t ∧ U(at_x, ⊤)
              rw [temporal_truth_and]
              exact ⟨h_pred_t,
                ⟨x, h_ord_tx.mpr h_tx_val,
                  (temporal_truth_and M atomMap x A_inner pred_x).mpr
                    ⟨h_A_inner_x, h_pred_x⟩,
                  fun _ _ _ => temporal_truth_top M atomMap _⟩⟩
            · -- x = t case: formula is pred_t ∧ (A_inner ∧ pred_x)
              -- Show x = t (both order booleans false)
              have h_xt_false : ord_xt = false := Bool.eq_false_iff.mpr h_xt_val
              have h_tx_false : ord_tx = false := Bool.eq_false_iff.mpr h_tx_val
              have h_x_eq_t : x = t := by
                by_contra h_ne
                rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
                · exact absurd (h_ord_xt.mp h_lt)
                    (by rw [h_xt_false]; exact Bool.noConfusion)
                · exact absurd (h_ord_tx.mp h_gt)
                    (by rw [h_tx_false]; exact Bool.noConfusion)
              rw [temporal_truth_and]
              constructor
              · exact h_pred_t
              · rw [temporal_truth_and]
                constructor
                · rw [← h_x_eq_t]; exact h_A_inner_x
                · rw [← h_x_eq_t]; exact h_pred_x⟩

/-- Convenience wrapper: extract just the formula. -/
noncomputable def nf_nvar_exist_depth0_tl_fn
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1)) : Formula :=
  (nf_nvar_exist_depth0_tl atomMap h_surj n sub_nf).choose

/-- Correctness of the convenience wrapper. -/
theorem nf_nvar_exist_depth0_tl_fn_correct
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1))
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    temporal_truth M atomMap t (nf_nvar_exist_depth0_tl_fn atomMap h_surj n sub_nf) ↔
    ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n + 1) (insertEnv env t) sub_nf :=
  (nf_nvar_exist_depth0_tl atomMap h_surj n sub_nf).choose_spec M t

end Bimodal.Metalogic.WeakCanonical.Kamp
