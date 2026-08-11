/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery

/-!
# Chronicle-to-Countermodel Integration (Gap Elimination and Discrete Pipeline)

This file contains the discrete countermodel pipeline (succ-embedding, BFMCS on Z, etc.)
for the BX completeness theorem.

The gap elimination proof (`chronicle_gap_contradiction`) and everything downstream of it —
including `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective`,
`cantor_bfmcs_discrete_restricted_tc`/`_fuc`, and `dd_countermodel_chronicle_discrete` — has
been archived to `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`. See the
tombstone note below.

The basic definitions (`LimitDomSubtype`, `limitDomSubtypeSuccOrder`, dense case,
etc.) are in `ChronicleToCountermodelBasic.lean`. This file imports both
`ChronicleToCountermodelBasic` and `GoodStructuresModelSurgery` to access the
sorry-free model surgery theorems (`gap_contradicts_prior`,
`gap_contradicts_prior_below`, `no_boundary_at_successor`) needed for gap
elimination.

## Import Architecture

The file split breaks the import cycle that previously prevented accessing
model surgery tools:
```
ChronicleToCountermodel
  -> ChronicleToCountermodelBasic  (basic definitions, no cycle)
  -> GoodStructuresModelSurgery    (sorry-free gap elimination)
     -> NEquivalence -> ChronicleExtraction -> ChronicleToCountermodelBasic
```
This is a DAG, not a cycle, because `ChronicleExtraction` now imports
`ChronicleToCountermodelBasic` instead of `ChronicleToCountermodel`.

## References

- Burgess 1982: "Axioms for tense logic II: Time periods"
- Reynolds 1994: "Axiomatising first-order temporal logic: Until and Since over linear time"
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Metalogic.Algebraic
open FormalSystem.Semantics
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Perpetuity
open FormalSystem.Metalogic.BXCanonical

/-! ## Gap Elimination and IsSuccArchimedean — TOMBSTONE

The whole gap-elimination chain has been ARCHIVED to
`Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`:

```
chronicle_gap_contradiction → succ_cofinal → limitDomSubtype_isSuccArchimedean
  → succ_embed_surjective → cantor_bfmcs_discrete_restricted_tc/_fuc
  → dd_countermodel_chronicle_discrete   (Chronicle)
  → countermodel_discrete_reynolds       (WeakCanonical/Transfer.lean)
```

plus the two adjacent sorry-free private helpers `limit_f_some_future_of_lt` and
`limit_f_not_G_neg_of_mem`, which had no call sites outside the moved section.

This note previously argued for retention: the chain was compile-live and "excising any of them
breaks `lake build` — keep them". That was correct about *piecemeal* excision only. Its stated
consumer, `countermodel_discrete_enriched`, had itself already been archived (to
`Boneyard/DeadChronicleGapElimination/TransferDead.lean`), leaving both surviving heads with
zero consumers, so the entire closure moved as one unit and `lake build` stayed green.

The live discrete path is unaffected: `completeness_discrete` goes through
`countermodel_discrete_reynolds_v2` (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`), which
bypasses `succ_embed_surjective` and the `IsSuccArchimedean` requirement entirely. Do not
confuse it with the archived, `sorryAx`-tainted `countermodel_discrete_reynolds`.

Several sorry-free declarations (notably `cantor_bfmcs_discrete_restricted_buc`,
`succ_embed_squeeze`, `succ_embed_squeeze_strict`) were orphaned by the excision and
deliberately left live.

`succ_reaches_dom_N` (dead BX pipeline stage induction, zero code consumers) was
archived to `Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean`.

`mcs_mixed_case_absurd` and `countermodelChronicleMixed` moved to
MCSMixedCase.lean.
-/

-- ARCHIVED: limit_dom_points_are_succ_iterates moved to
-- Boneyard/DeadConvergenceProof/limit_dom_succ_iterates.lean
-- This helper was only used by the dead convergence proof inside succ_cofinal.
-- It is not needed by the plan v9 approach (derive succ_cofinal from one_class).

-- z1_formula, z1_derivation, z1_in_mcs archived to
-- Boneyard/DeadChronicleGapElimination/GapElimination.lean

/-! ## Collapse-Based Discrete Pipeline

When U(T,bot) is present in all domain MCS's, the limit domain has an immediate
successor for each point. `IsSuccArchimedean` (via `limitDomSubtype_isSuccArchimedean`)
asserted that finitely many succ steps reach any larger element, and `succ_embed_surjective`
followed from it via `succ_orbit_convex`. Both are archived — see
`Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`.

The collapse equivalence below (succ-reachability) is used in auxiliary proofs.
-/

/--
Succ-reachability relation: `a` and `b` are collapse-equivalent iff one is
reachable from the other by finitely many applications of `limitDomSubtypeSucc`.
Each equivalence class is one succ-orbit (omega-chain).
-/
def CollapseEquiv (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) : Prop :=
  ∃ n : ℕ, (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a = b ∨
            (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] b = a

/--
Succ-reachability is reflexive: `succ^[0] a = a`.
-/
theorem collapse_equiv_refl (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a : LimitDomSubtype fc A h_mcs) :
    CollapseEquiv fc A h_mcs h_discrete a a :=
  ⟨0, Or.inl rfl⟩

/--
Succ-reachability is symmetric: by swapping the disjunction.
-/
theorem collapse_equiv_symm (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs)
    (h : CollapseEquiv fc A h_mcs h_discrete a b) :
    CollapseEquiv fc A h_mcs h_discrete b a := by
  obtain ⟨n, h_or⟩ := h
  exact ⟨n, h_or.symm⟩

/--
The succ function is strictly monotone: `a < limitDomSubtypeSucc a`.
-/
private theorem limitDomSubtype_succ_lt (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a : LimitDomSubtype fc A h_mcs) :
    a < limitDomSubtypeSucc fc A h_mcs h_discrete a :=
  (limitDomSubtype_succ_le_iff fc A h_mcs h_discrete a
    (limitDomSubtypeSucc fc A h_mcs h_discrete a)).mp le_rfl

/--
Succ iterates are strictly increasing: `succ^[n] a < succ^[n+1] a`.
-/
private theorem limitDomSubtype_succ_iter_lt (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a : LimitDomSubtype fc A h_mcs) (n : ℕ) :
    (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a <
      (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n + 1] a := by
  rw [Function.iterate_succ', Function.comp_apply]
  exact limitDomSubtype_succ_lt fc A h_mcs h_discrete _

/--
Succ iterates are monotone: `n ≤ m → succ^[n] a ≤ succ^[m] a`.
-/
private theorem limitDomSubtype_succ_iter_mono (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a : LimitDomSubtype fc A h_mcs) {n m : ℕ} (h : n ≤ m) :
    (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a ≤
      (limitDomSubtypeSucc fc A h_mcs h_discrete)^[m] a := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  clear h
  induction k with
  | zero => simp
  | succ k ih =>
    rw [show n + (k + 1) = n + k + 1 from by omega]
    exact le_of_lt (lt_of_le_of_lt ih
      (limitDomSubtype_succ_iter_lt fc A h_mcs h_discrete a _))

/--
Succ iterates are strictly monotone: `n < m → succ^[n] a < succ^[m] a`.
-/
private theorem limitDomSubtype_succ_iter_strictMono (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a : LimitDomSubtype fc A h_mcs) {n m : ℕ} (h : n < m) :
    (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a <
      (limitDomSubtypeSucc fc A h_mcs h_discrete)^[m] a := by
  exact lt_of_lt_of_le
    (limitDomSubtype_succ_iter_lt fc A h_mcs h_discrete a n)
    (limitDomSubtype_succ_iter_mono fc A h_mcs h_discrete a (by omega))

/--
Succ iterates are injective: `succ^[n] a = succ^[m] a → n = m`.
-/
private theorem limitDomSubtype_succ_iter_injective (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a : LimitDomSubtype fc A h_mcs) {n m : ℕ}
    (h : (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a =
         (limitDomSubtypeSucc fc A h_mcs h_discrete)^[m] a) :
    n = m := by
  rcases lt_trichotomy n m with h_lt | rfl | h_gt
  · exact absurd h (ne_of_lt (limitDomSubtype_succ_iter_strictMono fc A h_mcs h_discrete a h_lt))
  · rfl
  · exact absurd h.symm (ne_of_lt (limitDomSubtype_succ_iter_strictMono fc A h_mcs h_discrete a
      h_gt))

/--
Succ-reachability is transitive. The key argument uses injectivity of succ
iterates to reduce the composite reachability to a single direction.

If `succ^[n] a = b` and `succ^[m] b = c`, then `succ^[n+m] a = c`.
If `succ^[n] a = b` and `succ^[m] c = b`, then either `a` reaches `c` or
`c` reaches `a` (by comparing n and m, using injectivity).
-/
theorem collapse_equiv_trans (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b c : LimitDomSubtype fc A h_mcs)
    (hab : CollapseEquiv fc A h_mcs h_discrete a b)
    (hbc : CollapseEquiv fc A h_mcs h_discrete b c) :
    CollapseEquiv fc A h_mcs h_discrete a c := by
  obtain ⟨n, hn⟩ := hab
  obtain ⟨m, hm⟩ := hbc
  -- Abbreviate the succ function
  set s := limitDomSubtypeSucc fc A h_mcs h_discrete with hs_def
  -- Succ is injective
  have h_s_inj : Function.Injective s := by
    intro x y hxy
    by_contra h_ne
    rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
    · have h1 : s x ≤ y := (limitDomSubtype_succ_le_iff fc A h_mcs h_discrete x y).mpr h_lt
      have h2 : y < s y := limitDomSubtype_succ_lt fc A h_mcs h_discrete y
      have h3 : s x < s y := lt_of_le_of_lt h1 h2
      exact absurd hxy (ne_of_lt h3)
    · have h1 : s y ≤ x := (limitDomSubtype_succ_le_iff fc A h_mcs h_discrete y x).mpr h_gt
      have h2 : x < s x := limitDomSubtype_succ_lt fc A h_mcs h_discrete x
      have h3 : s y < s x := lt_of_le_of_lt h1 h2
      exact absurd hxy.symm (ne_of_lt h3)
  -- Helper: iteration composition
  have iter_add : ∀ (p q : ℕ) (x : LimitDomSubtype fc A h_mcs),
      s^[p + q] x = s^[p] (s^[q] x) := fun p q x =>
    Function.iterate_add_apply s p q x
  -- Helper: subtraction cancellation with iteration
  have iter_sub_left (p q : ℕ) (x y : LimitDomSubtype fc A h_mcs) (h : q ≤ p)
      (h_eq : s^[p] x = s^[q] y) : s^[p - q] x = y := by
    have h1 : s^[q] (s^[p - q] x) = s^[q] y := by
      rw [← iter_add]
      have : q + (p - q) = p := by omega
      rw [this]; exact h_eq
    exact (h_s_inj.iterate q) h1
  rcases hn with hn_ab | hn_ba <;> rcases hm with hm_bc | hm_cb
  · -- s^[n] a = b, s^[m] b = c => s^[m+n] a = c
    exact ⟨m + n, Or.inl (show s^[m + n] a = c by rw [iter_add, hn_ab, hm_bc])⟩
  · -- s^[n] a = b, s^[m] c = b => s^[n] a = s^[m] c
    have h_eq : s^[n] a = s^[m] c := by rw [hn_ab, hm_cb]
    rcases le_or_gt m n with h | h
    · exact ⟨n - m, Or.inl (iter_sub_left n m a c h h_eq)⟩
    · exact ⟨m - n, Or.inr (iter_sub_left m n c a h.le h_eq.symm)⟩
  · -- s^[n] b = a, s^[m] b = c
    -- s^[n] b = a and s^[m] b = c. Both are iterates from b.
    rcases le_or_gt n m with h | h
    · -- n ≤ m: s^[m] b = s^[n + (m-n)] b = s^[n](s^[m-n] b), and s^[n] b = a
      -- So s^[m-n] a = ... wait, we need to be careful with directions.
      -- s^[n](s^[m-n] b) = s^[m] b = c, and s^[n] b = a
      -- By injectivity: we want to relate a and c. Actually:
      -- s^[m-n](s^[n] b) = s^[m] b = c, so s^[m-n] a = c
      have h_eq : m - n + n = m := by omega
      have : s^[m - n] (s^[n] b) = c := by
        rw [← iter_add, h_eq]; exact hm_bc
      exact ⟨m - n, Or.inl (by rwa [hn_ba] at this)⟩
    · -- n > m: similarly s^[n-m] c = a
      have h_eq : n - m + m = n := by omega
      have : s^[n - m] (s^[m] b) = a := by
        rw [← iter_add, h_eq]; exact hn_ba
      exact ⟨n - m, Or.inr (by rwa [hm_bc] at this)⟩
  · -- s^[n] b = a, s^[m] c = b => s^[m+n] c = a
    refine ⟨m + n, Or.inr ?_⟩
    change s^[m + n] c = a
    have : s^[n + m] c = a := by rw [iter_add, hm_cb, hn_ba]
    rwa [show n + m = m + n from by omega] at this

/--
The succ-reachability relation as a `Setoid`.
-/
noncomputable def collapseSetoid (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    Setoid (LimitDomSubtype fc A h_mcs) where
  r := CollapseEquiv fc A h_mcs h_discrete
  iseqv := {
    refl := collapse_equiv_refl fc A h_mcs h_discrete
    symm := collapse_equiv_symm fc A h_mcs h_discrete _ _
    trans := collapse_equiv_trans fc A h_mcs h_discrete _ _ _
  }

/--
The quotient type of `LimitDomSubtype` under succ-reachability.
Each element represents one succ-orbit (omega-chain or singleton).
-/
noncomputable def CollapseClass (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :=
  Quotient (collapseSetoid fc A h_mcs h_discrete)

/--
Helper: the succ function maps equivalent elements to equivalent elements.
If `succ^[n] a = b`, then `succ^[n+1] a = succ(b)`, so `a ~ succ(b)` via `n+1`.
Similarly for the other direction.
-/
private theorem collapse_equiv_succ_congr (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs)
    (h : CollapseEquiv fc A h_mcs h_discrete a b) :
    CollapseEquiv fc A h_mcs h_discrete
      (limitDomSubtypeSucc fc A h_mcs h_discrete a)
      (limitDomSubtypeSucc fc A h_mcs h_discrete b) := by
  obtain ⟨n, hn⟩ := h
  set s := limitDomSubtypeSucc fc A h_mcs h_discrete
  rcases hn with hn_ab | hn_ba
  · -- succ^[n] a = b, so succ^[n](succ a) = succ(succ^[n] a) = succ b
    refine ⟨n, Or.inl ?_⟩
    change s^[n] (s a) = s b
    rw [(Function.Commute.iterate_self s n).eq a, hn_ab]
  · -- succ^[n] b = a, so succ^[n](succ b) = succ(succ^[n] b) = succ a
    refine ⟨n, Or.inr ?_⟩
    change s^[n] (s b) = s a
    rw [(Function.Commute.iterate_self s n).eq b, hn_ba]

/--
Orbit convexity: if `a ≤ b ≤ succ^[n] a`, then `b` is in the orbit of `a`.
Specifically, `b = succ^[k] a` for some `k ≤ n`.

Proof by strong induction on `n`. Base case `n = 0`: `a ≤ b ≤ a` forces `b = a`.
Step: if `a ≤ b ≤ succ^[n+1] a`, either `b ≤ succ^[n] a` (use IH) or
`succ^[n] a < b ≤ succ(succ^[n] a)`. In the latter case,
`succ(succ^[n] a) ≤ b` (from `succ_le_iff` and `succ^[n] a < b`), so
`b = succ^[n+1] a`.
-/
private theorem collapse_orbit_convex (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (n : ℕ)
    (h_le : a ≤ b)
    (h_ub : b ≤ (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a) :
    ∃ k ≤ n, (limitDomSubtypeSucc fc A h_mcs h_discrete)^[k] a = b := by
  set s := limitDomSubtypeSucc fc A h_mcs h_discrete
  induction n with
  | zero =>
    simp only [Function.iterate_zero, id_eq] at h_ub
    exact ⟨0, le_rfl, le_antisymm h_le h_ub⟩
  | succ n ih =>
    rcases le_or_gt b (s^[n] a) with h_le_n | h_gt_n
    · obtain ⟨k, hkn, hk⟩ := ih h_le_n
      exact ⟨k, Nat.le_succ_of_le hkn, hk⟩
    · -- succ^[n] a < b ≤ succ^[n+1] a
      -- succ(succ^[n] a) ≤ b (from succ_le_iff and succ^[n] a < b)
      have h_succ_le : s (s^[n] a) ≤ b :=
        (limitDomSubtype_succ_le_iff fc A h_mcs h_discrete (s^[n] a) b).mpr h_gt_n
      -- Also b ≤ succ^[n+1] a = s(succ^[n] a)
      have h_iter_succ : s^[n + 1] a = s (s^[n] a) :=
        Function.iterate_succ_apply' s n a
      rw [h_iter_succ] at h_ub
      exact ⟨n + 1, le_rfl, by rw [h_iter_succ]; exact (le_antisymm h_ub h_succ_le).symm⟩

/--
If `a < b` and `a ≁ b`, then every succ-iterate of `a` is strictly less than `b`.
This follows from orbit convexity: if `succ^[n] a ≥ b`, then `b` would be in
the orbit of `a` (since `a ≤ b ≤ succ^[n] a`), contradicting `a ≁ b`.
-/
private theorem collapse_orbit_bounded (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs)
    (h_lt : a < b) (h_ne : ¬ CollapseEquiv fc A h_mcs h_discrete a b)
    (n : ℕ) :
    (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a < b := by
  by_contra h_not_lt
  push Not at h_not_lt
  obtain ⟨k, _, hk⟩ := collapse_orbit_convex fc A h_mcs h_discrete a b n h_lt.le h_not_lt
  exact h_ne ⟨k, Or.inl hk⟩

/--
If `a ≁ b`, then for the canonical representatives: if `succ^[p] x = a`,
all iterates of x are also not equivalent to b. Contrapositively: if any
iterate of x were equivalent to b, then x ~ b, hence a ~ b.
-/
private theorem collapse_not_equiv_of_orbit (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs)
    (h_ne : ¬ CollapseEquiv fc A h_mcs h_discrete a b)
    (n : ℕ) :
    ¬ CollapseEquiv fc A h_mcs h_discrete
      ((limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a) b := by
  intro ⟨m, hm⟩
  exact h_ne (collapse_equiv_trans fc A h_mcs h_discrete a
    ((limitDomSubtypeSucc fc A h_mcs h_discrete)^[n] a) b
    ⟨n, Or.inl rfl⟩ ⟨m, hm⟩)

/--
The collapse equivalence classes are totally separated:
if `a ≁ b` and `a < b`, then `a' < b'` for any `a' ~ a` and `b' ~ b`.
-/
private theorem collapse_class_sep (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (a' b' : LimitDomSubtype fc A h_mcs)
    (ha : CollapseEquiv fc A h_mcs h_discrete a a')
    (hb : CollapseEquiv fc A h_mcs h_discrete b b')
    (h_ne : ¬ CollapseEquiv fc A h_mcs h_discrete a b)
    (h_lt : a < b) : a' < b' := by
  set s := limitDomSubtypeSucc fc A h_mcs h_discrete
  -- Step 1: a' < b (all elements of [a] are < b)
  have ha'_lt_b : a' < b := by
    obtain ⟨p, hp⟩ := ha
    rcases hp with hp_eq | hp_eq
    · -- s^[p] a = a', so a' is a succ-iterate of a. Show all iterates < b.
      exact hp_eq ▸ collapse_orbit_bounded fc A h_mcs h_discrete a b h_lt h_ne p
    · -- s^[p] a' = a, so a' ≤ s^[p] a' = a < b
      calc a' ≤ s^[p] a' :=
            limitDomSubtype_succ_iter_mono fc A h_mcs h_discrete a' (Nat.zero_le p)
        _ = a := hp_eq
        _ < b := h_lt
  -- Step 2: a' < b' using ha'_lt_b and the separation argument
  -- If b' ≤ a', then b' < a' (since a' ≁ b'). Then b is a succ-iterate of b'
  -- (or b' is a succ-iterate of b). If succ^q b = b', then b ≤ b' < a' -- but a' < b,
  -- contradiction.
  -- If succ^q b' = b, then by collapse_orbit_bounded (b' < a', b' ≁ a'),
  -- succ^q b' < a', so b < a'. But a' < b, contradiction.
  have h_ne' : ¬ CollapseEquiv fc A h_mcs h_discrete a' b' := by
    intro h
    exact h_ne (collapse_equiv_trans fc A h_mcs h_discrete a a' b
      ha (collapse_equiv_trans fc A h_mcs h_discrete a' b' b h
        (collapse_equiv_symm fc A h_mcs h_discrete b b' hb)))
  by_contra h_not_lt'
  push Not at h_not_lt'
  have h_b'_ne_a' : b' ≠ a' := fun h_eq => h_ne'
      (h_eq ▸ collapse_equiv_refl fc A h_mcs h_discrete _)
  have h_b'_lt_a' : b' < a' := lt_of_le_of_ne h_not_lt' h_b'_ne_a'
  obtain ⟨q, hq⟩ := hb
  rcases hq with hq_bb' | hq_b'b
  · -- s^[q] b = b'. So b ≤ b' (succ iterates are monotone).
    have h_b_le_b' : b ≤ b' := hq_bb' ▸
      limitDomSubtype_succ_iter_mono fc A h_mcs h_discrete b (Nat.zero_le q)
    exact absurd ha'_lt_b (not_lt.mpr (le_trans h_b_le_b' h_not_lt'))
  · -- s^[q] b' = b. b' < a' and b' ≁ a'.
    have h_ne_b'a' : ¬ CollapseEquiv fc A h_mcs h_discrete b' a' :=
      fun h => h_ne' (collapse_equiv_symm fc A h_mcs h_discrete b' a' h)
    have h_iter_lt : s^[q] b' < a' :=
      collapse_orbit_bounded fc A h_mcs h_discrete b' a' h_b'_lt_a' h_ne_b'a' q
    have h_b_lt_a' : b < a' := hq_b'b ▸ h_iter_lt
    exact absurd ha'_lt_b (not_lt.mpr h_b_lt_a'.le)

/--
Auxiliary: strict order on `CollapseClass` representatives is transitive.
If `a < b`, `a ≁ b`, `b < c`, and `b ≁ c`, then `a < c` and `a ≁ c`.
-/
private theorem collapse_lt_trans (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    {a b c : LimitDomSubtype fc A h_mcs}
    (hab : a < b) (hnab : ¬ CollapseEquiv fc A h_mcs h_discrete a b)
    (hbc : b < c) (_hnbc : ¬ CollapseEquiv fc A h_mcs h_discrete b c) :
    a < c ∧ ¬ CollapseEquiv fc A h_mcs h_discrete a c := by
  refine ⟨lt_trans hab hbc, fun hac => ?_⟩
  -- a ~ c. By sep: since a ≁ b and a < b, for a' ~ a, b' ~ b, a' < b'.
  -- In particular, taking a' = c (since c ~ a), b' = b: c < b. But b < c. Contradiction.
  have : c < b := collapse_class_sep fc A h_mcs h_discrete a b c b
    hac (collapse_equiv_refl fc A h_mcs h_discrete b) hnab hab
  exact absurd (lt_trans hbc this) (lt_irrefl b)

/--
`LinearOrder` instance on `CollapseClass`. The quotient of a linear order
by a convex equivalence relation is linearly ordered.

The strict order `[a] < [b]` is defined as `a < b ∧ a ≁ b` (well-defined by
`collapse_class_sep`). The `≤` relation is `= ∨ <`, and totality follows
from the trichotomy on the underlying `LimitDomSubtype`.
-/
noncomputable instance collapseClassLinearOrder (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    LinearOrder (CollapseClass fc A h_mcs h_discrete) := by
  letI setoid := collapseSetoid fc A h_mcs h_discrete
  -- The strict order: [a] < [b] iff a < b and a ≁ b (well-defined by collapse_class_sep)
  let lt_fn : CollapseClass fc A h_mcs h_discrete → CollapseClass fc A h_mcs h_discrete → Prop :=
    @Quotient.lift₂ _ _ Prop setoid setoid
      (fun a b => a < b ∧ ¬ CollapseEquiv fc A h_mcs h_discrete a b)
      (by
        intro a₁ b₁ a₂ b₂ ha hb; ext; constructor
        · rintro ⟨h_lt, h_ne⟩
          exact ⟨collapse_class_sep fc A h_mcs h_discrete a₁ b₁ a₂ b₂ ha hb h_ne h_lt,
                 fun h => h_ne (collapse_equiv_trans fc A h_mcs h_discrete a₁ a₂ b₁
                   ha (collapse_equiv_trans fc A h_mcs h_discrete a₂ b₂ b₁ h
                     (collapse_equiv_symm fc A h_mcs h_discrete b₁ b₂ hb)))⟩
        · rintro ⟨h_lt, h_ne⟩
          exact ⟨collapse_class_sep fc A h_mcs h_discrete a₂ b₂ a₁ b₁
                   (collapse_equiv_symm fc A h_mcs h_discrete a₁ a₂ ha)
                   (collapse_equiv_symm fc A h_mcs h_discrete b₁ b₂ hb) h_ne h_lt,
                 fun h => h_ne (collapse_equiv_trans fc A h_mcs h_discrete a₂ a₁ b₂
                   (collapse_equiv_symm fc A h_mcs h_discrete a₁ a₂ ha)
                   (collapse_equiv_trans fc A h_mcs h_discrete a₁ b₁ b₂ h hb))⟩)
  -- Trichotomy on the quotient
  have h_tri : ∀ (a b : CollapseClass fc A h_mcs h_discrete),
      lt_fn a b ∨ a = b ∨ lt_fn b a :=
    Quotient.ind₂ (fun a b => by
      rcases lt_trichotomy a b with h | h | h
      · rcases Classical.em (CollapseEquiv fc A h_mcs h_discrete a b) with hab | hab
        · exact Or.inr (Or.inl (Quotient.sound hab))
        · exact Or.inl ⟨h, hab⟩
      · exact Or.inr (Or.inl (by subst h; rfl))
      · rcases Classical.em (CollapseEquiv fc A h_mcs h_discrete b a) with hba | hba
        · exact Or.inr (Or.inl (Quotient.sound hba).symm)
        · exact Or.inr (Or.inr ⟨h, hba⟩))
  -- Irreflexivity
  have h_irrefl : ∀ (a : CollapseClass fc A h_mcs h_discrete), ¬ lt_fn a a :=
    Quotient.ind (fun a ⟨h, _⟩ => lt_irrefl a h)
  -- Transitivity
  have h_trans : ∀ (a b c : CollapseClass fc A h_mcs h_discrete),
      lt_fn a b → lt_fn b c → lt_fn a c := by
    intro a b c
    exact Quotient.inductionOn₃ a b c (fun _ _ _ hab hbc =>
      collapse_lt_trans fc A h_mcs h_discrete hab.1 hab.2 hbc.1 hbc.2)
  -- Build Preorder → PartialOrder → LinearOrder
  letI : LT (CollapseClass fc A h_mcs h_discrete) := ⟨lt_fn⟩
  letI : LE (CollapseClass fc A h_mcs h_discrete) := ⟨fun a b => a = b ∨ lt_fn a b⟩
  letI : Preorder (CollapseClass fc A h_mcs h_discrete) :=
  { le_refl := fun _ => Or.inl rfl
    le_trans := by
      intro a b c hab hbc
      rcases hab with rfl | hab
      · exact hbc
      rcases hbc with rfl | hbc
      · exact Or.inr hab
      exact Or.inr (h_trans a b c hab hbc)
    lt_iff_le_not_ge := by
      intro a b; constructor
      · intro hab
        refine ⟨Or.inr hab, ?_⟩
        intro hba
        rcases hba with rfl | hba
        · exact h_irrefl _ hab
        · exact h_irrefl _ (h_trans _ _ _ hab hba)
      · intro ⟨hab, hba⟩
        rcases hab with rfl | hab
        · exact absurd (Or.inl rfl) hba
        · exact hab }
  letI : PartialOrder (CollapseClass fc A h_mcs h_discrete) :=
  { le_antisymm := by
      intro a b hab hba
      rcases hab with rfl | hab
      · rfl
      rcases hba with rfl | hba
      · rfl
      exact absurd (h_trans a b a hab hba) (h_irrefl a) }
  exact
  { le_total := by
      intro a b
      rcases h_tri a b with h | h | h
      · exact Or.inl (Or.inr h)
      · exact Or.inl (Or.inl h)
      · exact Or.inr (Or.inr h)
    toDecidableLE := fun a b => Classical.dec (a ≤ b) }

/-! ### Direct Embedding: ℤ ↪ LimitDomSubtype

Rather than proving the full quotient order infrastructure on `CollapseClass`
(which requires establishing that succ-orbits are bounded — a property deep in
the omega-chain construction), we take a simpler approach: embed ℤ directly into
`LimitDomSubtype` using `NoMaxOrder` / `NoMinOrder` to pick witnesses.

The key observation: `forward_G` / `backward_H` hold for ANY ordered pair of
domain points (`limit_forward_G` / `limit_backward_H`), regardless of equivalence
class. So we only need a strictly increasing map `ℤ → LimitDomSubtype`, which
the existing `NoMaxOrder` / `NoMinOrder` instances provide via iterated choice.

The collapse equivalence infrastructure (above) is preserved for potential future
use in proving finer structural properties (e.g., Until/Since coherence on ℤ).
-/

/--
Forward embedding: a strictly increasing sequence of `LimitDomSubtype` elements
starting from `⟨0, zero_mem⟩` and going upward. Defined by iterated choice using
`NoMaxOrder`.
-/
noncomputable def embedForward (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    ℕ → LimitDomSubtype fc A h_mcs
  | 0 => ⟨0, zero_mem_limit_dom fc A h_mcs⟩
  | n + 1 => (exists_gt (embedForward fc A h_mcs n)).choose

private theorem embed_forward_zero (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    embedForward fc A h_mcs 0 = ⟨0, zero_mem_limit_dom fc A h_mcs⟩ := rfl

private theorem embed_forward_lt_succ (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (n : ℕ) : embedForward fc A h_mcs n < embedForward fc A h_mcs (n + 1) :=
  (exists_gt (embedForward fc A h_mcs n)).choose_spec

private theorem embed_forward_strictMono (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    StrictMono (embedForward fc A h_mcs) :=
  strictMono_nat_of_lt_succ (embed_forward_lt_succ fc A h_mcs)

/--
Backward embedding: a strictly decreasing sequence starting from `⟨0, zero_mem⟩`
and going downward. Defined by iterated choice using `NoMinOrder`.
-/
noncomputable def embedBackward (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    ℕ → LimitDomSubtype fc A h_mcs
  | 0 => ⟨0, zero_mem_limit_dom fc A h_mcs⟩
  | n + 1 => (exists_lt (embedBackward fc A h_mcs n)).choose

private theorem embed_backward_zero (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    embedBackward fc A h_mcs 0 = ⟨0, zero_mem_limit_dom fc A h_mcs⟩ := rfl

private theorem embed_backward_succ_lt (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (n : ℕ) : embedBackward fc A h_mcs (n + 1) < embedBackward fc A h_mcs n :=
  (exists_lt (embedBackward fc A h_mcs n)).choose_spec

private theorem embed_backward_strictAnti (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    StrictAnti (embedBackward fc A h_mcs) := by
  intro m n hmn
  induction hmn with
  | refl => exact embed_backward_succ_lt fc A h_mcs m
  | step h ih => exact lt_trans (embed_backward_succ_lt fc A h_mcs _) ih

/--
Combined embedding `ℤ → LimitDomSubtype`:
- Non-negative integers use `embedForward`
- Negative integers use `embedBackward` (on the absolute value)
-/
noncomputable def discreteEmbed (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    ℤ → LimitDomSubtype fc A h_mcs :=
  fun n =>
    if 0 ≤ n then
      embedForward fc A h_mcs n.toNat
    else
      embedBackward fc A h_mcs ((-n).toNat)

private theorem discrete_embed_zero (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    discreteEmbed fc A h_mcs 0 = ⟨0, zero_mem_limit_dom fc A h_mcs⟩ := by
  simp [discreteEmbed, embedForward]

/--
Helper: `embedBackward` at positive indices is strictly below `⟨0, zero_mem⟩`.
-/
private theorem embed_backward_pos_lt_zero (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (n : ℕ) (hn : 0 < n) :
    embedBackward fc A h_mcs n < ⟨0, zero_mem_limit_dom fc A h_mcs⟩ := by
  have := embed_backward_strictAnti fc A h_mcs hn
  rwa [embed_backward_zero] at this

/--
The combined embedding is strictly increasing.
-/
private theorem discrete_embed_strictMono (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    StrictMono (discreteEmbed fc A h_mcs) := by
  intro a b hab
  simp only [discreteEmbed]
  by_cases ha : 0 ≤ a <;> by_cases hb : 0 ≤ b
  · -- Both non-negative: use embed_forward_strictMono
    simp only [ha, hb, ite_true]
    exact embed_forward_strictMono fc A h_mcs (by omega)
  · -- a ≥ 0, b < 0: impossible since a < b
    omega
  · -- a < 0, b ≥ 0: backward(|a|) < 0 ≤ forward(|b|)
    simp only [ha, hb, ite_true, ite_false]
    push Not at ha
    have h_back_lt : embedBackward fc A h_mcs ((-a).toNat) <
        ⟨(0 : Rat), zero_mem_limit_dom fc A h_mcs⟩ :=
      embed_backward_pos_lt_zero fc A h_mcs _ (by omega)
    have h_fwd_ge : ⟨(0 : Rat), zero_mem_limit_dom fc A h_mcs⟩ ≤
        embedForward fc A h_mcs b.toNat := by
      rw [← embed_forward_zero]
      exact embed_forward_strictMono fc A h_mcs |>.monotone (by omega)
    exact lt_of_lt_of_le h_back_lt h_fwd_ge
  · -- Both negative: use embed_backward_strictAnti
    simp only [ha, hb, ite_false]
    push Not at ha hb
    exact embed_backward_strictAnti fc A h_mcs (by omega)

/--
MCS assignment via the direct embedding (discrete case). For each integer `n`,
evaluate `LimitF` at the embedded domain point.
-/
noncomputable def DiscreteF (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (_h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    ℤ → Set Formula :=
  fun n => LimitF fc A h_mcs (discreteEmbed fc A h_mcs n).val

/-- The origin integer in the discrete case is simply `0 : ℤ`. -/
noncomputable def discreteZero (fc : FrameClass) (_A : Set Formula)
    (_h_mcs : SetMaximalConsistent (fc := fc) _A)
    (_h_discrete : ∀ x ∈ LimitDom fc _A _h_mcs, nextTop ∈ LimitF fc _A _h_mcs x) :
    ℤ := 0

/-- `DiscreteF` at `discreteZero` equals A (the root MCS). -/
theorem discrete_f_at_zero (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    DiscreteF fc A h_mcs h_discrete (discreteZero fc A h_mcs h_discrete) = A := by
  simp only [DiscreteF, discreteZero, discrete_embed_zero]
  exact limit_f_zero fc A h_mcs

/-- Every integer maps to an MCS via `DiscreteF`. -/
theorem discrete_f_is_mcs (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (n : ℤ) : SetMaximalConsistent (fc := fc) (DiscreteF fc A h_mcs h_discrete n) := by
  exact limit_c0 fc A h_mcs _ (discreteEmbed fc A h_mcs n).property

/--
FMCS on ℤ (discrete case): chronicle coherence properties transported through
the direct embedding from `LimitDomSubtype` to ℤ.

`forward_G` follows from `limit_forward_G` since the embedding is strictly
increasing: `t < t'` implies `embed(t) < embed(t')`, so `G(φ) ∈ f(embed(t))`
and `embed(t) < embed(t')` give `φ ∈ f(embed(t'))`.

`backward_H` follows similarly from `limit_backward_H`.
-/
noncomputable def discreteFmcs (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    FMCS (fc := fc) ℤ where
  mcs := DiscreteF fc A h_mcs h_discrete
  is_mcs := discrete_f_is_mcs fc A h_mcs h_discrete
  forward_G := by
    intro t t' φ h_lt h_G
    have h_embed_lt := discrete_embed_strictMono fc A h_mcs h_lt
    exact limit_forward_G fc A h_mcs
      (discreteEmbed fc A h_mcs t).val (discreteEmbed fc A h_mcs t').val
      (discreteEmbed fc A h_mcs t).property (discreteEmbed fc A h_mcs t').property
      h_embed_lt φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_embed_lt := discrete_embed_strictMono fc A h_mcs h_lt
    exact limit_backward_H fc A h_mcs
      (discreteEmbed fc A h_mcs t).val (discreteEmbed fc A h_mcs t').val
      (discreteEmbed fc A h_mcs t).property (discreteEmbed fc A h_mcs t').property
      h_embed_lt φ h_H

/-! ## Discrete Case: Succ-Based Embedding and BFMCS on Z

When `□(U(⊤,⊥)) ∈ A` (box discreteness), every box-equivalent MCS N has
`U(⊤,⊥)` in all its chronicle domain points. This enables a succ-based
embedding `ℤ → LimitDomSubtype` that follows the deterministic successor
structure, and a BFMCS construction on ℤ mirroring the dense case.

The key property: when `U(⊤,⊥)` holds everywhere, between consecutive
embedded points (i.e., between `succEmbed(n)` and `succEmbed(n+1)`)
there are no limit domain points (the "no-gap" property). This makes
coherence proofs work: witnesses from `limit_F_resolution`, `limit_satisfies_c5_strong`,
etc. must land on embedded points.
-/

/--
Succ-based embedding `ℤ → LimitDomSubtype` for the discrete case.
Maps 0 to ⟨0, zero_mem⟩, positive n to succ^n(root), negative n to pred^|n|(root).
This follows the deterministic successor structure when `U(⊤,⊥)` holds everywhere.
-/
noncomputable def succEmbed (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    ℤ → LimitDomSubtype fc A h_mcs :=
  fun n =>
    if _h : 0 ≤ n then
      (limitDomSubtypeSucc fc A h_mcs h_discrete)^[n.toNat] ⟨0, zero_mem_limit_dom fc A h_mcs⟩
    else
      (limitDomSubtypePred fc A h_mcs h_discrete)^[(-n).toNat] ⟨0, zero_mem_limit_dom fc A h_mcs⟩

theorem succ_embed_zero (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    succEmbed fc A h_mcs h_discrete 0 = ⟨0, zero_mem_limit_dom fc A h_mcs⟩ := by
  simp [succEmbed]

theorem succ_embed_succ (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (n : ℤ) (hn : 0 ≤ n) :
    succEmbed fc A h_mcs h_discrete (n + 1) =
      limitDomSubtypeSucc fc A h_mcs h_discrete (succEmbed fc A h_mcs h_discrete n) := by
  simp only [succEmbed]
  have h1 : 0 ≤ n + 1 := by omega
  simp only [h1, hn, dite_true]
  rw [show (n + 1).toNat = n.toNat + 1 from by omega]
  rw [Function.iterate_succ', Function.comp_apply]

theorem succ_embed_pred (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (n : ℤ) (hn : n ≤ 0) :
    succEmbed fc A h_mcs h_discrete (n - 1) =
      limitDomSubtypePred fc A h_mcs h_discrete (succEmbed fc A h_mcs h_discrete n) := by
  set s := limitDomSubtypeSucc fc A h_mcs h_discrete
  set p := limitDomSubtypePred fc A h_mcs h_discrete
  set root : LimitDomSubtype fc A h_mcs := ⟨0, zero_mem_limit_dom fc A h_mcs⟩
  -- LHS: succEmbed(n-1). Since n ≤ 0, n-1 < 0, so succEmbed(n-1) = pred^[|n-1|](root)
  have h_n_sub_1_neg : ¬(0 ≤ n - 1) := by omega
  -- RHS: pred(succEmbed(n)).
  change (if _ : 0 ≤ n - 1 then _ else p^[(-(n-1)).toNat] root) =
    p (if _ : 0 ≤ n then _ else _)
  simp only [h_n_sub_1_neg, dite_false]
  by_cases hn0 : n = 0
  · subst hn0
    simp only [le_refl, dite_true]
    change p^[(1 : ℕ)] root = p (s^[(0 : ℕ)] root)
    simp [Function.iterate_zero]
  · have h_neg : ¬(0 ≤ n) := by omega
    simp only [h_neg, dite_false]
    rw [show (-(n - 1)).toNat = (-n).toNat + 1 from by omega]
    rw [Function.iterate_succ', Function.comp_apply]

/--
The succ-based embedding is strictly monotone.
-/
private theorem succ_embed_step (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (n : ℤ) : succEmbed fc A h_mcs h_discrete n <
      succEmbed fc A h_mcs h_discrete (n + 1) := by
  by_cases hn : 0 ≤ n
  · rw [succ_embed_succ fc A h_mcs h_discrete n hn]
    exact limitDomSubtype_succ_lt fc A h_mcs h_discrete _
  · push Not at hn
    have hn1 : n + 1 ≤ 0 := by omega
    have h_eq : n = (n + 1) - 1 := by ring
    rw [h_eq, succ_embed_pred fc A h_mcs h_discrete (n + 1) hn1]
    have h_eq2 : (n + 1) - 1 + 1 = n + 1 := by ring
    rw [h_eq2]
    exact limitDomSubtype_pred_lt fc A h_mcs h_discrete _

theorem succ_embed_strictMono (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    StrictMono (succEmbed fc A h_mcs h_discrete) := by
  intro a b hab
  have h_step := succ_embed_step fc A h_mcs h_discrete
  -- Induction on the gap b - a
  obtain ⟨k, hk⟩ : ∃ k : ℕ, b = a + (↑k + 1) := ⟨(b - a - 1).toNat, by omega⟩
  subst hk
  induction k with
  | zero =>
    simp only [Nat.cast_zero, zero_add]
    exact h_step a
  | succ k ih =>
    calc succEmbed fc A h_mcs h_discrete a
      < succEmbed fc A h_mcs h_discrete (a + (↑k + 1)) := ih (by omega)
      _ < succEmbed fc A h_mcs h_discrete (a + (↑k + 1) + 1) := h_step _
      _ = succEmbed fc A h_mcs h_discrete (a + (↑(k + 1) + 1)) := by
            congr 1; omega

/--
No-gap property: between `succEmbed(n)` and `succEmbed(n+1)`, there are no
limit domain points. This is the KEY property of the discrete case.

When `U(⊤,⊥)` holds everywhere, `limitDomSubtypeSucc` gives an IMMEDIATE successor
(no intermediate domain points). Since `succEmbed(n+1) = succ(succEmbed(n))` for
non-negative n (and symmetrically via pred for negative), the gap-free property follows.
-/
theorem succ_embed_no_gap (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (n : ℤ) (w : LimitDomSubtype fc A h_mcs)
    (h1 : succEmbed fc A h_mcs h_discrete n < w)
    (h2 : w < succEmbed fc A h_mcs h_discrete (n + 1)) : False := by
  by_cases hn : 0 ≤ n
  · -- n ≥ 0: succEmbed(n+1) = succ(succEmbed(n))
    rw [succ_embed_succ fc A h_mcs h_discrete n hn] at h2
    -- succ(succEmbed(n)) is the immediate successor: no points between
    -- succEmbed(n) and succ(succEmbed(n)). From succ_le_iff:
    -- succ(x) ≤ y ↔ x < y. Taking y = w: succ(succEmbed(n)) ≤ w ↔ succEmbed(n) < w.
    -- Since succEmbed(n) < w, we get succ(succEmbed(n)) ≤ w.
    -- But w < succ(succEmbed(n)). Contradiction.
    have h3 : limitDomSubtypeSucc fc A h_mcs h_discrete (succEmbed fc A h_mcs h_discrete n) ≤ w :=
      (limitDomSubtype_succ_le_iff fc A h_mcs h_discrete _ w).mpr h1
    exact absurd h2 (not_lt.mpr h3)
  · -- n < 0: succEmbed(n) = pred(succEmbed(n+1))
    push Not at hn
    have hn1 : n + 1 ≤ 0 := by omega
    rw [show n = (n + 1) - 1 from by ring,
        succ_embed_pred fc A h_mcs h_discrete (n + 1) hn1] at h1
    -- pred(succEmbed(n+1)) is the immediate predecessor: no points between
    -- pred(x) and x. From le_pred_iff: a ≤ pred(b) ↔ a < b.
    -- w < succEmbed(n+1), so w ≤ pred(succEmbed(n+1)).
    -- But pred(succEmbed(n+1)) < w. Contradiction.
    have h3 : w ≤ limitDomSubtypePred fc A h_mcs h_discrete
        (succEmbed fc A h_mcs h_discrete (n + 1)) :=
      (limitDomSubtype_le_pred_iff fc A h_mcs h_discrete w _).mpr h2
    exact absurd h1 (not_lt.mpr h3)

/--
Squeeze lemma: any domain point between `succEmbed(a)` and `succEmbed(b)`
(inclusive on both ends) is itself an embedded point `succEmbed(k)` for some `a ≤ k ≤ b`.

This is the key lemma that makes coherence proofs work without full surjectivity.
The proof is by induction on `b - a`: the no-gap property eliminates domain points
between consecutive embedded points, squeezing w to the next embedded point.
-/
theorem succ_embed_squeeze (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : ℤ) (hab : a ≤ b)
    (w : LimitDomSubtype fc A h_mcs)
    (hw_lo : succEmbed fc A h_mcs h_discrete a ≤ w)
    (hw_hi : w ≤ succEmbed fc A h_mcs h_discrete b) :
    ∃ k : ℤ, a ≤ k ∧ k ≤ b ∧ succEmbed fc A h_mcs h_discrete k = w := by
  -- Induction on the gap b - a as a natural number
  suffices h : ∀ (d : ℕ) (a' b' : ℤ), b' - a' = ↑d → a' ≤ b' →
      ∀ (w' : LimitDomSubtype fc A h_mcs),
      succEmbed fc A h_mcs h_discrete a' ≤ w' →
      w' ≤ succEmbed fc A h_mcs h_discrete b' →
      ∃ k : ℤ, a' ≤ k ∧ k ≤ b' ∧ succEmbed fc A h_mcs h_discrete k = w' by
    exact h (b - a).toNat a b (by omega) hab w hw_lo hw_hi
  intro d
  induction d with
  | zero =>
    intro a' b' hd hab' w' hw_lo' hw_hi'
    have h_eq : a' = b' := by omega
    subst h_eq
    exact ⟨a', le_rfl, le_rfl, (le_antisymm hw_hi' hw_lo').symm⟩
  | succ d ih =>
    intro a' b' hd hab' w' hw_lo' hw_hi'
    rcases eq_or_lt_of_le hw_lo' with hw_eq | hw_gt
    · exact ⟨a', le_rfl, hab', hw_eq⟩
    · -- succEmbed(a') < w'. By no-gap, succEmbed(a'+1) ≤ w'.
      have h_a1_le : succEmbed fc A h_mcs h_discrete (a' + 1) ≤ w' := by
        by_contra h_not_le
        push Not at h_not_le
        exact succ_embed_no_gap fc A h_mcs h_discrete a' w' hw_gt h_not_le
      exact (ih (a' + 1) b' (by omega) (by omega) w' h_a1_le hw_hi').imp
        fun k ⟨hk1, hk2, hk3⟩ => ⟨by omega, hk2, hk3⟩

/--
Strict version of squeeze: any domain point STRICTLY between `succEmbed(a)` and
`succEmbed(b)` is an embedded point `succEmbed(k)` for some `a < k < b`.
-/
theorem succ_embed_squeeze_strict (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (a b : ℤ) (hab : a < b)
    (w : LimitDomSubtype fc A h_mcs)
    (hw_lo : succEmbed fc A h_mcs h_discrete a < w)
    (hw_hi : w < succEmbed fc A h_mcs h_discrete b) :
    ∃ k : ℤ, a < k ∧ k < b ∧ succEmbed fc A h_mcs h_discrete k = w := by
  -- succEmbed(a) < w, so by no-gap, succEmbed(a+1) ≤ w
  have h_a1_le : succEmbed fc A h_mcs h_discrete (a + 1) ≤ w := by
    by_contra h_not_le
    push Not at h_not_le
    exact succ_embed_no_gap fc A h_mcs h_discrete a w hw_lo h_not_le
  -- w < succEmbed(b), so w ≤ succEmbed(b-1) by no-gap
  have h_b1_ge : w ≤ succEmbed fc A h_mcs h_discrete (b - 1) := by
    by_contra h_not_le
    push Not at h_not_le
    have hstep := succ_embed_step fc A h_mcs h_discrete (b - 1)
    rw [show b - 1 + 1 = b from by omega] at hstep
    exact succ_embed_no_gap fc A h_mcs h_discrete (b - 1) w h_not_le
      (by rwa [show b - 1 + 1 = b from by omega])
  -- Now a+1 ≤ b-1 follows from h_a1_le and h_b1_ge
  have hab' : a + 1 ≤ b - 1 := by
    by_contra h_not
    push Not at h_not
    -- a + 1 > b - 1, so b ≤ a + 1. Combined with a < b: b = a + 1.
    -- Then a + 1 ≤ w ≤ embed(b-1) = embed(a), contradicting embed(a) < w.
    have hba : b = a + 1 := by omega
    subst hba
    rw [show a + 1 - 1 = a from by omega] at h_b1_ge
    exact absurd (lt_of_lt_of_le hw_lo h_b1_ge) (lt_irrefl _)
  obtain ⟨k, hk_lo, hk_hi, hk_eq⟩ := succ_embed_squeeze fc A h_mcs h_discrete
    (a + 1) (b - 1) hab' w h_a1_le h_b1_ge
  exact ⟨k, by omega, by omega, hk_eq⟩

/--
MCS assignment via the succ-based embedding.
-/
noncomputable def SuccDiscreteF (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    ℤ → Set Formula :=
  fun n => LimitF fc A h_mcs (succEmbed fc A h_mcs h_discrete n).val

/-- Every integer maps to an MCS via `SuccDiscreteF`. -/
theorem succ_discrete_f_is_mcs (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (n : ℤ) : SetMaximalConsistent (fc := fc) (SuccDiscreteF fc A h_mcs h_discrete n) :=
  limit_c0 fc A h_mcs _ (succEmbed fc A h_mcs h_discrete n).property

/-- `SuccDiscreteF` at 0 equals A. -/
theorem succ_discrete_f_at_zero (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    SuccDiscreteF fc A h_mcs h_discrete 0 = A := by
  simp only [SuccDiscreteF, succ_embed_zero]
  exact limit_f_zero fc A h_mcs

/-- Box stability for `SuccDiscreteF`. -/
theorem box_stable_in_succ_discrete_f (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (φ : Formula) (n : ℤ) :
    Formula.box φ ∈ SuccDiscreteF fc A h_mcs h_discrete n ↔ Formula.box φ ∈ A := by
  exact box_stable_in_limit_f fc A h_mcs φ _ (succEmbed fc A h_mcs h_discrete n).property

/--
FMCS on ℤ via the succ-based embedding. Uses `limit_forward_G` and
`limit_backward_H` through the strictly monotone embedding.
-/
noncomputable def succDiscreteFmcs (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x) :
    FMCS (fc := fc) ℤ where
  mcs := SuccDiscreteF fc A h_mcs h_discrete
  is_mcs := succ_discrete_f_is_mcs fc A h_mcs h_discrete
  forward_G := by
    intro t t' φ h_lt h_G
    have h_embed_lt := succ_embed_strictMono fc A h_mcs h_discrete h_lt
    exact limit_forward_G fc A h_mcs
      (succEmbed fc A h_mcs h_discrete t).val (succEmbed fc A h_mcs h_discrete t').val
      (succEmbed fc A h_mcs h_discrete t).property (succEmbed fc A h_mcs h_discrete t').property
      h_embed_lt φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_embed_lt := succ_embed_strictMono fc A h_mcs h_discrete h_lt
    exact limit_backward_H fc A h_mcs
      (succEmbed fc A h_mcs h_discrete t).val (succEmbed fc A h_mcs h_discrete t').val
      (succEmbed fc A h_mcs h_discrete t).property (succEmbed fc A h_mcs h_discrete t').property
      h_embed_lt φ h_H

/--
Shifted FMCS on ℤ: `mcs t := SuccDiscreteF(t + offset)`.
-/
noncomputable def shiftedSuccDiscreteFmcs (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x)
    (offset : ℤ) : FMCS (fc := fc) ℤ where
  mcs t := SuccDiscreteF fc A h_mcs h_discrete (t + offset)
  is_mcs t := succ_discrete_f_is_mcs fc A h_mcs h_discrete (t + offset)
  forward_G := by
    intro t t' φ h_lt h_G
    have h_lt' : t + offset < t' + offset := by omega
    exact (succDiscreteFmcs fc A h_mcs h_discrete).forward_G (t + offset) (t' + offset) φ h_lt'
        h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_lt' : t' + offset < t + offset := by omega
    exact (succDiscreteFmcs fc A h_mcs h_discrete).backward_H (t + offset) (t' + offset) φ h_lt'
        h_H

/--
Rooted FMCS on ℤ (discrete case): builds a chronicle for MCS N (with `□(U(⊤,⊥)) ∈ N`
ensuring discreteness), applies the succ embedding, and shifts to place N at time `s`.
-/
noncomputable def rootedSuccDiscreteFmcs (fc : FrameClass) (N : Set Formula)
    (h_N : SetMaximalConsistent (fc := fc) N)
    (h_box_discrete_N : Formula.box nextTop ∈ N) (s : ℤ) : FMCS (fc := fc) ℤ :=
  let h_discrete_N := box_discrete_gives_discreteness fc N h_N h_box_discrete_N
  -- Offset = -s, so mcs(s) = SuccDiscreteF(s + (-s)) = SuccDiscreteF(0) = N
  shiftedSuccDiscreteFmcs fc N h_N h_discrete_N (-s)

/--
The rooted FMCS at `s` has `mcs s = N`.
-/
theorem rooted_succ_discrete_fmcs_at_s (fc : FrameClass) (N : Set Formula)
    (h_N : SetMaximalConsistent (fc := fc) N)
    (h_box_discrete_N : Formula.box nextTop ∈ N) (s : ℤ) :
    (rootedSuccDiscreteFmcs fc N h_N h_box_discrete_N s).mcs s = N := by
  simp only [rootedSuccDiscreteFmcs, shiftedSuccDiscreteFmcs]
  rw [show s + -s = 0 from by omega]
  exact succ_discrete_f_at_zero fc N h_N (box_discrete_gives_discreteness fc N h_N h_box_discrete_N)

/--
Box stability for `rootedSuccDiscreteFmcs`:
`Box φ ∈ (rootedSuccDiscreteFmcs fc N h_N h_box s).mcs t ↔ Box φ ∈ N`.
-/
theorem box_stable_in_rooted_succ_discrete_fmcs (fc : FrameClass) (N : Set Formula)
    (h_N : SetMaximalConsistent (fc := fc) N) (h_box_discrete_N : Formula.box nextTop ∈ N)
    (φ : Formula) (s t : ℤ) :
    Formula.box φ ∈ (rootedSuccDiscreteFmcs fc N h_N h_box_discrete_N s).mcs t ↔
      Formula.box φ ∈ N := by
  simp only [rootedSuccDiscreteFmcs, shiftedSuccDiscreteFmcs]
  exact box_stable_in_succ_discrete_f fc N h_N
    (box_discrete_gives_discreteness fc N h_N h_box_discrete_N) φ (t + -s)

/--
Bundle of FMCS families on ℤ (discrete case).

Requires `□(U(⊤,⊥)) ∈ A` (box discreteness). Each family is a
`rootedSuccDiscreteFmcs fc N h_N h_box_N s` where N is box-equivalent to A
(hence `□(U(⊤,⊥)) ∈ N` by box-equiv). Each N gets its own chronicle, which
is discrete by `box_discrete_gives_discreteness`.
-/
noncomputable def cantorBfmcsDiscrete (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_discrete : Formula.box nextTop ∈ A) :
    BFMCS (fc := fc) ℤ where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent (fc := fc) N)
    (h_box_N : Formula.box nextTop ∈ N) (s : ℤ),
    (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N) ∧
    fam = rootedSuccDiscreteFmcs fc N h_N h_box_N s }
  nonempty := ⟨rootedSuccDiscreteFmcs fc A h_mcs h_box_discrete 0,
    A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', h_box_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_in_N : Formula.box φ ∈ N :=
      (box_stable_in_rooted_succ_discrete_fmcs fc N h_N h_box_N φ s t).mp h_box
    have h_box_A : Formula.box φ ∈ A := (h_eqN φ).mpr h_box_in_N
    have h_box_in_N' : Formula.box φ ∈ N' := (h_eqN' φ).mp h_box_A
    have h_box_t' : Formula.box φ ∈ (rootedSuccDiscreteFmcs fc N' h_N' h_box_N' s').mcs t :=
      (box_stable_in_rooted_succ_discrete_fmcs fc N' h_N' h_box_N' φ s' t).mpr h_box_in_N'
    exact SetMaximalConsistent.implication_property
      ((rootedSuccDiscreteFmcs fc N' h_N' h_box_N' s').is_mcs t)
      (theorem_in_mcs ((rootedSuccDiscreteFmcs fc N' h_N' h_box_N' s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ) trivial)) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_in_N : Formula.box φ ∈ N from
      (box_stable_in_rooted_succ_discrete_fmcs fc N h_N h_box_N φ s t).mpr h_box_in_N
    suffices h_box_A : Formula.box φ ∈ A from (h_eqN φ).mp h_box_A
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ A := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ A :=
      FormalSystem.Metalogic.Bundle.SetMaximalConsistent.contrapositive h_mcs
        (liftBase fc (FormalSystem.Metalogic.Bundle.boxDneTheorem φ)) h_neg_box
    obtain ⟨v, h_v_mcs, h_equiv, h_neg_phi_v⟩ := bx_modal_witness_fc h_mcs (Formula.neg φ)
        h_diamond_neg
    have h_box_discrete_v : Formula.box nextTop ∈ v :=
      (h_equiv nextTop).mp h_box_discrete
    have h_fam_v_mem : rootedSuccDiscreteFmcs fc v h_v_mcs h_box_discrete_v t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent (fc := fc) N)
          (h_box_N : Formula.box nextTop ∈ N) (s : ℤ),
          (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N) ∧
          fam = rootedSuccDiscreteFmcs fc N h_N h_box_N s } :=
      ⟨v, h_v_mcs, h_box_discrete_v, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v := h_all (rootedSuccDiscreteFmcs fc v h_v_mcs h_box_discrete_v t)
      h_fam_v_mem
    rw [rooted_succ_discrete_fmcs_at_s] at h_phi_v
    exact set_consistent_not_both h_v_mcs.1 φ h_phi_v h_neg_phi_v
  evalFamily := rootedSuccDiscreteFmcs fc A h_mcs h_box_discrete 0
  eval_family_mem := ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩

/-! ## Discrete Restricted Coherence

Restricted temporal and Until/Since coherence for `cantorBfmcsDiscrete`.
These are the three conditions needed by the flow-frame completeness engine (`bundleFlow_completeness_from_neg_membership`).

The key technique: for backward coherence (BUC), the squeeze lemma maps C4
counterexample witnesses back to integers. For forward coherence (TC, FUC),
the step decomposition via BX5 self-accumulation advances the Until formula
one step at a time using the no-gap property.
-/

/--
Restricted backward Until/Since coherence for `cantorBfmcsDiscrete`.
Uses `limit_satisfies_c4`/`c4'` (counterexample elimination) combined with
the squeeze lemma to map C4 witnesses back to integers.
-/
theorem cantor_bfmcs_discrete_restricted_buc (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_discrete : Formula.box nextTop ∈ A) (root : Formula) :
    (cantorBfmcsDiscrete fc A h_mcs h_box_discrete).RestrictedBackwardUntilSinceCoherent
        root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_discrete_N := box_discrete_gives_discreteness fc N h_N h_box_N
  set offset := (-s : ℤ)
  -- Helper to unfold the fam.mcs definition
  have h_mcs_eq : ∀ t : ℤ, (rootedSuccDiscreteFmcs fc N h_N h_box_N s).mcs t =
      LimitF fc N h_N (succEmbed fc N h_N h_discrete_N (t + offset)).val := by
    intro t; rfl
  constructor
  · -- Until backward: contrapositive via C4
    intro t φ ψ _ ⟨u, htu, hφu, h_guard⟩
    by_contra h_not_until
    rw [h_mcs_eq] at h_not_until hφu
    have h_neg_until : (Formula.untl φ ψ).neg ∈
        LimitF fc N h_N (succEmbed fc N h_N h_discrete_N (t + offset)).val := by
      rcases SetMaximalConsistent.negation_complete
        (limit_c0 fc N h_N _ (succEmbed fc N h_N h_discrete_N (t + offset)).property)
        (Formula.untl φ ψ) with h | h
      · exact absurd h h_not_until
      · exact h
    obtain ⟨z, hz, htz, hzu, hψneg⟩ := limit_satisfies_c4 fc N h_N
      (succEmbed fc N h_N h_discrete_N (t + offset)).val
      (succEmbed fc N h_N h_discrete_N (u + offset)).val
      (succEmbed fc N h_N h_discrete_N (t + offset)).property
      (succEmbed fc N h_N h_discrete_N (u + offset)).property
      (succ_embed_strictMono fc N h_N h_discrete_N (show t + offset < u + offset by omega))
      ψ φ h_neg_until hφu
    obtain ⟨k, hk_lo, hk_hi, hk_eq⟩ := succ_embed_squeeze_strict fc N h_N h_discrete_N
      (t + offset) (u + offset) (by omega)
      ⟨z, hz⟩ htz hzu
    have hψneg' : ψ.neg ∈ LimitF fc N h_N (succEmbed fc N h_N h_discrete_N k).val := by
      have := congrArg Subtype.val hk_eq; simp only at this; rwa [this]
    have hψ_guard := h_guard (k - offset) (by omega) (by omega)
    rw [h_mcs_eq, show k - offset + offset = k from by omega] at hψ_guard
    exact set_consistent_not_both (limit_c0 fc N h_N _
        (succEmbed fc N h_N h_discrete_N k).property).1
      ψ hψ_guard hψneg'
  · -- Since backward: contrapositive via C4'
    intro t φ ψ _ ⟨u, hut, hφu, h_guard⟩
    by_contra h_not_since
    rw [h_mcs_eq] at h_not_since hφu
    have h_neg_since : (Formula.snce φ ψ).neg ∈
        LimitF fc N h_N (succEmbed fc N h_N h_discrete_N (t + offset)).val := by
      rcases SetMaximalConsistent.negation_complete
        (limit_c0 fc N h_N _ (succEmbed fc N h_N h_discrete_N (t + offset)).property)
        (Formula.snce φ ψ) with h | h
      · exact absurd h h_not_since
      · exact h
    obtain ⟨z, hz, huz, hzt, hψneg⟩ := limit_satisfies_c4' fc N h_N
      (succEmbed fc N h_N h_discrete_N (t + offset)).val
      (succEmbed fc N h_N h_discrete_N (u + offset)).val
      (succEmbed fc N h_N h_discrete_N (t + offset)).property
      (succEmbed fc N h_N h_discrete_N (u + offset)).property
      (succ_embed_strictMono fc N h_N h_discrete_N (show u + offset < t + offset by omega))
      ψ φ h_neg_since hφu
    obtain ⟨k, hk_lo, hk_hi, hk_eq⟩ := succ_embed_squeeze_strict fc N h_N h_discrete_N
      (u + offset) (t + offset) (by omega)
      ⟨z, hz⟩ huz hzt
    have hψneg' : ψ.neg ∈ LimitF fc N h_N (succEmbed fc N h_N h_discrete_N k).val := by
      have := congrArg Subtype.val hk_eq; simp only at this; rwa [this]
    have hψ_guard := h_guard (k - offset) (by omega) (by omega)
    rw [h_mcs_eq, show k - offset + offset = k from by omega] at hψ_guard
    exact set_consistent_not_both (limit_c0 fc N h_N _
        (succEmbed fc N h_N h_discrete_N k).property).1
      ψ hψ_guard hψneg'

-- mcs_mixed_case_absurd and countermodelChronicleMixed moved to MCSMixedCase.lean
-- to decouple from dead-code sorry chain (chronicle_gap_contradiction)

end FormalSystem.Metalogic.BXCanonical.Chronicle
