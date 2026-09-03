import FormalSystem.Metalogic.Core.RestrictedMCS.Basic

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Archived: RestrictedMCS iterF/iterP Boundedness

The four boundedness lemmas below were removed from
`FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean`. They had **zero references** anywhere in
`FormalSystem/`, `Tests/`, or `docs/` outside their own declaration site.

Their advertised consumer was `succ_chain_fam`'s `f_nesting_is_bounded` / `p_nesting_is_bounded`
obligations, and that consumer is itself archived, at
`FormalSystem/Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` (which still names
`restricted_mcs_F_bounded` and `restricted_mcs_P_bounded` in archived text at its lines 756, 773,
814 and 832). With the consumer archived, keeping 157 lines of live proof for it was carrying
cost with no verification value, so the machinery follows it here rather than being refactored in
place.

## Archived declarations

- `restricted_mcs_iter_F_bound` — some `iterF` iterate escapes any `RestrictedMCS`
- `restricted_mcs_F_bounded` — the `WellFounded.has_min` boundary lemma for `iterF`
- `restricted_mcs_iter_P_bound` — the `iterP` mirror of `restricted_mcs_iter_F_bound`
- `restricted_mcs_P_bounded` — the `iterP` mirror of `restricted_mcs_F_bounded`

## Relationship to active code

Everything these proofs depend on is still live in
`FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean` and
`FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean`:
`RestrictedMCS`, `ClosureRestricted`, `restricted_mcs_is_closure_restricted`, `closureWithNeg`,
`closureFBound`, `closurePBound`, `iterF`, `iterP`, `iter_F_leaves_closure`,
`iter_P_leaves_closure`, `iter_F_one_eq_some_future` and `iter_P_one_eq_some_past`. Resurrecting
this file therefore needs no other recovery — paste the declarations back beside
`restricted_mcs_exists_containing` and delete the `#exit` below.

A validated alternative to resurrection exists: the same four lemmas collapse to one
`Nat.find`-based `exists_boundary_of_one` plus two thin instantiations (139 proof lines to 44).
That rewrite needs a local `classical` — `Nat.find` wants a `DecidablePred`, and `_ ∈ M` for
`M : Set Formula` is not decidable — and deliberately no module-scope `open Classical`.
-/

#exit

namespace FormalSystem.Metalogic.Core

open FormalSystem.Syntax
open FormalSystem.ProofSystem

variable {phi : Formula} {fc : FrameClass}

/-!
## iterF Boundedness in RestrictedMCS

These lemmas establish that iterF iterations must eventually leave any RestrictedMCS,
because RestrictedMCS is bounded by closureWithNeg and iterF eventually leaves
closureWithNeg.
-/

/--
In any RestrictedMCS M over phi, there exists n such that iterF n phi is not in M.

This follows because:
1. M ⊆ closureWithNeg phi (by definition of RestrictedMCS)
2. iterF leaves closureWithNeg for large n (by iter_F_not_mem_closureWithNeg)
3. Therefore iterF leaves M
-/
theorem restricted_mcs_iter_F_bound (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M fc) :
    ∃ n : Nat, iterF n phi ∉ M := by
  use closureFBound phi
  intro h_mem
  have h_closure : ClosureRestricted phi M := restricted_mcs_is_closure_restricted h_mcs
  have h_in_closure : iterF (closureFBound phi) phi ∈ closureWithNeg phi := h_closure h_mem
  exact iter_F_leaves_closure phi h_in_closure

/--
If F(phi) is in a RestrictedMCS M, then there exists d >= 1 such that:
- iterF d phi is in M (the last F-iteration that's still in M)
- iterF (d + 1) phi is not in M (the first F-iteration that left M)

This is the key lemma for proving f_nesting_is_bounded in the succ_chain_fam construction.

The proof uses WellFounded.has_min to find the boundary point where iterF transitions
from being in M to not being in M.
-/
theorem restricted_mcs_F_bounded (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M fc)
    (h_F_in : Formula.someFuture phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iterF d phi ∈ M ∧ iterF (d + 1) phi ∉ M := by
  -- First, show iterF 1 phi = F(phi) ∈ M
  have h_one_in : iterF 1 phi ∈ M := by
    simp only [iter_F_one_eq_some_future]
    exact h_F_in
  -- The set of n >= 2 where iterF n phi ∉ M is nonempty (contains closureFBound phi)
  -- We use the explicit bound from restricted_mcs_iter_F_bound
  let exit_bound := closureFBound phi
  have h_exit_bound_not : iterF exit_bound phi ∉ M := by
    intro h_mem
    have h_closure : ClosureRestricted phi M := restricted_mcs_is_closure_restricted h_mcs
    have h_in_closure : iterF exit_bound phi ∈ closureWithNeg phi := h_closure h_mem
    exact iter_F_leaves_closure phi h_in_closure

  -- exit_bound >= 1 since closureFBound = max_F_depth + 1
  have h_exit_ge1 : exit_bound ≥ 1 := by
    unfold exit_bound closureFBound
    omega

  -- If exit_bound = 1, then iterF 1 phi ∉ M contradicts h_one_in
  -- So exit_bound >= 2
  have h_exit_ge2 : exit_bound ≥ 2 := by
    by_contra h
    push Not at h
    have h_eq : exit_bound = 1 := by omega
    rw [h_eq] at h_exit_bound_not
    exact h_exit_bound_not h_one_in

  -- Define the set S = { n : Nat | n >= 2 ∧ iterF n phi ∉ M }
  let S : Set Nat := { n | n ≥ 2 ∧ iterF n phi ∉ M }
  have h_S_nonempty : S.Nonempty := ⟨exit_bound, h_exit_ge2, h_exit_bound_not⟩

  -- Use well-foundedness of < on Nat to get a minimum element
  have h_wf : WellFounded (· < · : Nat → Nat → Prop) := Nat.lt_wfRel.wf
  obtain ⟨min_n, h_min_mem, h_min_least⟩ := WellFounded.has_min h_wf S h_S_nonempty

  -- Extract properties from h_min_mem : min_n ∈ S
  obtain ⟨h_min_ge2, h_min_not⟩ := h_min_mem

  -- d = min_n - 1 works
  use min_n - 1
  constructor
  · omega
  constructor
  · -- Show iterF (min_n - 1) phi ∈ M
    -- By minimality of min_n: if min_n - 1 ∈ S, then ¬(min_n - 1 < min_n), contradiction
    -- So min_n - 1 ∉ S, meaning either min_n - 1 < 2 or iterF (min_n - 1) phi ∈ M
    by_contra h_not_in
    -- If iterF (min_n - 1) phi ∉ M and min_n - 1 >= 2, then min_n - 1 ∈ S
    have h_pred_lt : min_n - 1 < min_n := by omega
    -- Case split on whether min_n - 1 >= 2
    by_cases h_pred_ge2 : min_n - 1 ≥ 2
    · -- min_n - 1 ∈ S since min_n - 1 >= 2 and iterF (min_n - 1) phi ∉ M
      have h_pred_in_S : min_n - 1 ∈ S := ⟨h_pred_ge2, h_not_in⟩
      -- But by minimality, ¬(min_n - 1 < min_n), contradiction
      exact h_min_least (min_n - 1) h_pred_in_S h_pred_lt
    · -- min_n - 1 < 2, so min_n - 1 = 0 or 1
      -- Since min_n >= 2, we have min_n - 1 >= 1, so min_n - 1 = 1
      have h_pred_eq1 : min_n - 1 = 1 := by omega
      rw [h_pred_eq1] at h_not_in
      exact h_not_in h_one_in
  · -- Show iterF min_n phi ∉ M
    have h_eq : min_n - 1 + 1 = min_n := by omega
    rw [h_eq]
    exact h_min_not

/-!
## iterP Boundedness in RestrictedMCS

These lemmas establish that iterP iterations must eventually leave any RestrictedMCS,
because RestrictedMCS is bounded by closureWithNeg and iterP eventually leaves
closureWithNeg. Symmetric to the iterF boundedness lemmas.
-/

/--
In any RestrictedMCS M over phi, there exists n such that iterP n phi is not in M.

This follows because:
1. M ⊆ closureWithNeg phi (by definition of RestrictedMCS)
2. iterP leaves closureWithNeg for large n (by iter_P_not_mem_closureWithNeg)
3. Therefore iterP leaves M
-/
theorem restricted_mcs_iter_P_bound (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M fc) :
    ∃ n : Nat, iterP n phi ∉ M := by
  use closurePBound phi
  intro h_mem
  have h_closure : ClosureRestricted phi M := restricted_mcs_is_closure_restricted h_mcs
  have h_in_closure : iterP (closurePBound phi) phi ∈ closureWithNeg phi := h_closure h_mem
  exact iter_P_leaves_closure phi h_in_closure

/--
If P(phi) is in a RestrictedMCS M, then there exists d >= 1 such that:
- iterP d phi is in M (the last P-iteration that's still in M)
- iterP (d + 1) phi is not in M (the first P-iteration that left M)

This is the key lemma for proving p_nesting_is_bounded in the succ_chain_fam construction.
Symmetric to restricted_mcs_F_bounded.

The proof uses WellFounded.has_min to find the boundary point where iterP transitions
from being in M to not being in M.
-/
theorem restricted_mcs_P_bounded (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M fc)
    (h_P_in : Formula.somePast phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iterP d phi ∈ M ∧ iterP (d + 1) phi ∉ M := by
  -- First, show iterP 1 phi = P(phi) ∈ M
  have h_one_in : iterP 1 phi ∈ M := by
    simp only [iter_P_one_eq_some_past]
    exact h_P_in
  -- The set of n >= 2 where iterP n phi ∉ M is nonempty (contains closurePBound phi)
  -- We use the explicit bound from restricted_mcs_iter_P_bound
  let exit_bound := closurePBound phi
  have h_exit_bound_not : iterP exit_bound phi ∉ M := by
    intro h_mem
    have h_closure : ClosureRestricted phi M := restricted_mcs_is_closure_restricted h_mcs
    have h_in_closure : iterP exit_bound phi ∈ closureWithNeg phi := h_closure h_mem
    exact iter_P_leaves_closure phi h_in_closure

  -- exit_bound >= 1 since closurePBound = max_P_depth + 1
  have h_exit_ge1 : exit_bound ≥ 1 := by
    unfold exit_bound closurePBound
    omega

  -- If exit_bound = 1, then iterP 1 phi ∉ M contradicts h_one_in
  -- So exit_bound >= 2
  have h_exit_ge2 : exit_bound ≥ 2 := by
    by_contra h
    push Not at h
    have h_eq : exit_bound = 1 := by omega
    rw [h_eq] at h_exit_bound_not
    exact h_exit_bound_not h_one_in

  -- Define the set S = { n : Nat | n >= 2 ∧ iterP n phi ∉ M }
  let S : Set Nat := { n | n ≥ 2 ∧ iterP n phi ∉ M }
  have h_S_nonempty : S.Nonempty := ⟨exit_bound, h_exit_ge2, h_exit_bound_not⟩

  -- Use well-foundedness of < on Nat to get a minimum element
  have h_wf : WellFounded (· < · : Nat → Nat → Prop) := Nat.lt_wfRel.wf
  obtain ⟨min_n, h_min_mem, h_min_least⟩ := WellFounded.has_min h_wf S h_S_nonempty

  -- Extract properties from h_min_mem : min_n ∈ S
  obtain ⟨h_min_ge2, h_min_not⟩ := h_min_mem

  -- d = min_n - 1 works
  use min_n - 1
  constructor
  · omega
  constructor
  · -- Show iterP (min_n - 1) phi ∈ M
    -- By minimality of min_n: if min_n - 1 ∈ S, then ¬(min_n - 1 < min_n), contradiction
    -- So min_n - 1 ∉ S, meaning either min_n - 1 < 2 or iterP (min_n - 1) phi ∈ M
    by_contra h_not_in
    -- If iterP (min_n - 1) phi ∉ M and min_n - 1 >= 2, then min_n - 1 ∈ S
    have h_pred_lt : min_n - 1 < min_n := by omega
    -- Case split on whether min_n - 1 >= 2
    by_cases h_pred_ge2 : min_n - 1 ≥ 2
    · -- min_n - 1 ∈ S since min_n - 1 >= 2 and iterP (min_n - 1) phi ∉ M
      have h_pred_in_S : min_n - 1 ∈ S := ⟨h_pred_ge2, h_not_in⟩
      -- But by minimality, ¬(min_n - 1 < min_n), contradiction
      exact h_min_least (min_n - 1) h_pred_in_S h_pred_lt
    · -- min_n - 1 < 2, so min_n - 1 = 0 or 1
      -- Since min_n >= 2, we have min_n - 1 >= 1, so min_n - 1 = 1
      have h_pred_eq1 : min_n - 1 = 1 := by omega
      rw [h_pred_eq1] at h_not_in
      exact h_not_in h_one_in
  · -- Show iterP min_n phi ∉ M
    have h_eq : min_n - 1 + 1 = min_n := by omega
    rw [h_eq]
    exact h_min_not

end FormalSystem.Metalogic.Core
