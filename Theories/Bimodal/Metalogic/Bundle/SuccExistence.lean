import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Completeness
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Syntax.SubformulaClosure

/-!
# Succ Successor and Predecessor Existence

This module proves that under discrete axioms (base + DF + seriality), for any MCS u
with F(top) in u, there exists an MCS v with Succ(u,v). Similarly, for any MCS u with
P(top) in u, there exists an MCS v with Succ(v,u) (predecessor existence).

## Key Construction: Deferral Seeds

The **successor deferral seed** is:
```
g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}
```

This seed ensures both Succ conditions are satisfied by construction:
- **G-persistence**: g_content(u) ⊆ v (directly from seed extension)
- **F-step**: For each F(φ) ∈ u, the disjunction φ ∨ F(φ) is in v.
  By MCS disjunction property, either φ ∈ v (resolved) or F(φ) ∈ v (deferred).

The **predecessor deferral seed** is symmetric using h_content and P.

## Main Theorems

- `successor_deferral_seed_consistent`: The successor seed is consistent
- `successor_exists`: For MCS u with F(⊤) ∈ u, there exists MCS v with Succ(u,v)
- `predecessor_exists`: For MCS u with P(⊤) ∈ u, there exists MCS v with Succ(v,u)

## References

- `SuccRelation.lean`: Succ definition and basic properties
- Goldblatt 1992, Logics of Time and Computation
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Phase 1: Successor Deferral Seed Definition

The successor deferral seed combines:
1. `g_content(u)`: All formulas φ where G(φ) ∈ u (G-persistence)
2. `{φ ∨ F(φ) | F(φ) ∈ u}`: Disjunctive deferrals for each F-obligation

The key insight is that each disjunction φ ∨ F(φ) captures the F-step condition:
the MCS extending this seed must either contain φ (resolved) or F(φ) (deferred).
-/

/--
A deferral disjunction for φ: `φ ∨ F(φ)`.

This formula is added to the successor deferral seed when `F(φ) ∈ u`.
In any MCS extending the seed, either φ holds (obligation resolved)
or F(φ) holds (obligation deferred to a further successor).
-/
def deferralDisjunction (φ : Formula) : Formula :=
  Formula.or φ (Formula.some_future φ)

/--
The set of all deferral disjunctions for u.

For each formula φ such that `F(φ) ∈ u`, we add `φ ∨ F(φ)` to ensure
the F-step condition is satisfied.
-/
def deferralDisjunctions (u : Set Formula) : Set Formula :=
  {ψ | ∃ φ : Formula, Formula.some_future φ ∈ u ∧ ψ = deferralDisjunction φ}

/--
The successor deferral seed: `g_content(u) ∪ deferralDisjunctions(u)`.

This seed is designed so that its Lindenbaum extension satisfies Succ u v:
1. G-persistence: g_content(u) ⊆ v (from seed extension)
2. F-step: f_content(u) ⊆ v ∪ f_content(v) (from deferral disjunctions)
-/
def successor_deferral_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u

/-!
### Membership Lemmas for Successor Seed
-/

/-- Membership in deferral disjunctions. -/
lemma mem_deferralDisjunctions_iff (u : Set Formula) (ψ : Formula) :
    ψ ∈ deferralDisjunctions u ↔
    ∃ φ : Formula, Formula.some_future φ ∈ u ∧ ψ = deferralDisjunction φ := by
  rfl

/-- If F(φ) ∈ u, then deferralDisjunction φ ∈ deferralDisjunctions u. -/
lemma deferralDisjunction_mem_of_F_mem (u : Set Formula) (φ : Formula)
    (h : Formula.some_future φ ∈ u) :
    deferralDisjunction φ ∈ deferralDisjunctions u :=
  ⟨φ, h, rfl⟩

/-- g_content is a subset of the successor deferral seed. -/
lemma g_content_subset_successor_deferral_seed (u : Set Formula) :
    g_content u ⊆ successor_deferral_seed u :=
  Set.subset_union_left

/-- Deferral disjunctions are a subset of the successor deferral seed. -/
lemma deferralDisjunctions_subset_successor_deferral_seed (u : Set Formula) :
    deferralDisjunctions u ⊆ successor_deferral_seed u :=
  Set.subset_union_right

/-- Membership in successor deferral seed: either from g_content or deferral disjunctions. -/
lemma mem_successor_deferral_seed_iff (u : Set Formula) (ψ : Formula) :
    ψ ∈ successor_deferral_seed u ↔
    ψ ∈ g_content u ∨ ψ ∈ deferralDisjunctions u := by
  simp only [successor_deferral_seed, Set.mem_union]

/-- Unfolding deferralDisjunction definition. -/
lemma deferralDisjunction_eq (φ : Formula) :
    deferralDisjunction φ = Formula.or φ (Formula.some_future φ) :=
  rfl

/-!
## P-Step Blocking Formulas (for Constrained Successor)

The P-step blocking formulas are needed by the constrained successor seed.
These must be defined before constrained_successor_seed.
-/

/--
The set of P-step blocking formulas for the successor seed.

For each formula φ where both P(φ) ∉ u and φ ∉ u, we add H(¬φ) to the seed.
Since P(φ) = ¬H(¬φ) by definition, having H(¬φ) in the successor prevents
P(φ) from appearing (as that would contradict MCS consistency).

**Key property**: Every blocking formula H(¬φ) is already in u, because
P(φ) ∉ u implies ¬P(φ) ∈ u, i.e., ¬¬H(¬φ) ∈ u, hence H(¬φ) ∈ u by
double negation elimination.
-/
def p_step_blocking_formulas (u : Set Formula) : Set Formula :=
  {ψ | ∃ φ : Formula, Formula.some_past φ ∉ u ∧ φ ∉ u ∧
    ψ = Formula.all_past (Formula.neg φ)}

/-- Membership in P-step blocking formulas. -/
lemma mem_p_step_blocking_formulas_iff (u : Set Formula) (ψ : Formula) :
    ψ ∈ p_step_blocking_formulas u ↔
    ∃ φ : Formula, Formula.some_past φ ∉ u ∧ φ ∉ u ∧ ψ = Formula.all_past (Formula.neg φ) := by
  rfl

/--
Every P-step blocking formula H(¬φ) is already in u.

**Proof**: If P(φ) ∉ u, then by MCS negation completeness, ¬P(φ) ∈ u.
Since P(φ) = ¬H(¬φ) by definition, ¬P(φ) = ¬¬H(¬φ).
By MCS double negation elimination, H(¬φ) ∈ u.
-/
theorem p_step_blocking_formulas_subset_u (u : Set Formula)
    (h_mcs : SetMaximalConsistent u) :
    p_step_blocking_formulas u ⊆ u := by
  intro χ h_block
  obtain ⟨φ, h_P_not, _, rfl⟩ := h_block
  -- P(φ) ∉ u means ¬H(¬φ) ∉ u. By negation completeness, ¬¬H(¬φ) ∈ u.
  -- By double negation elimination: H(¬φ) ∈ u.
  rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_past φ) with h_in | h_neg_in
  · exact absurd h_in h_P_not
  · exact SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_in

/-!
## Restricted P-Step Blocking Formulas

The unrestricted `p_step_blocking_formulas` works for arbitrary MCS, but when working
with `DeferralRestrictedMCS` (sets restricted to `deferralClosure phi`), the unrestricted
version is FALSE as stated. See RestrictedMCS.lean lines 1060-1124 for the counterexample:
if `P(psi)` is NOT in `deferralClosure`, then `H(¬psi)` is also NOT in `deferralClosure`,
so the blocking formula cannot be in the restricted MCS.

The fix is to only block formulas where `P(chi)` is in `deferralClosure`. This is sound
because the Lindenbaum extension in the restricted construction only adds formulas from
`deferralClosure` anyway, so `P(chi)` where `P(chi) ∉ deferralClosure` cannot appear
in the successor.

Team research report 06_team-research.md confirms this solution with HIGH confidence.
-/

/--
P-step blocking formulas restricted to the deferral closure.

Only blocks `P(chi)` where `P(chi)` could actually appear in the successor,
i.e., where `P(chi) ∈ deferralClosure phi`.

This is the mathematically correct definition for `DeferralRestrictedMCS`.
The unrestricted version `p_step_blocking_formulas` is false for this case
(see research report 06_team-research.md for counterexample).
-/
def p_step_blocking_formulas_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  {ψ | ∃ χ : Formula, Formula.some_past χ ∈ deferralClosure phi ∧
                       Formula.some_past χ ∉ u ∧
                       χ ∉ u ∧
                       ψ = Formula.all_past (Formula.neg χ)}

/-- Membership in restricted P-step blocking formulas. -/
lemma mem_p_step_blocking_formulas_restricted_iff (phi : Formula) (u : Set Formula) (ψ : Formula) :
    ψ ∈ p_step_blocking_formulas_restricted phi u ↔
    ∃ χ : Formula, Formula.some_past χ ∈ deferralClosure phi ∧
                   Formula.some_past χ ∉ u ∧
                   χ ∉ u ∧
                   ψ = Formula.all_past (Formula.neg χ) := by
  rfl

/--
Restricted P-step blocking formulas are a subset of deferralClosure.

**Proof**: If `P(chi) ∈ deferralClosure phi`, then `H(¬chi) ∈ deferralClosure phi`.

This follows from the structure of deferralClosure: if `P(chi) ∈ closureWithNeg`,
then either `P(chi)` is in `subformulaClosure` (so `H(¬chi)` is a subformula of `P(chi)`),
or `P(chi) = g.neg` for some `g` in `subformulaClosure`. In the second case,
`g = H(¬chi)` (since `P(chi) = ¬H(¬chi)` by definition), so `H(¬chi) ∈ subformulaClosure`.
-/
theorem p_step_blocking_restricted_subset_deferralClosure (phi : Formula) (u : Set Formula) :
    p_step_blocking_formulas_restricted phi u ⊆ (deferralClosure phi : Set Formula) := by
  intro ψ hψ
  rw [mem_p_step_blocking_formulas_restricted_iff] at hψ
  obtain ⟨χ, h_P_in_dc, _, _, rfl⟩ := hψ
  -- P(χ) ∈ deferralClosure implies H(¬χ) ∈ deferralClosure
  -- First, P(χ) ∈ deferralClosure means P(χ) ∈ closureWithNeg (since closureWithNeg ⊆ deferralClosure)
  have h_P_in_cwn := some_past_in_deferralClosure_is_in_closureWithNeg phi χ h_P_in_dc
  -- P(χ) in closureWithNeg means P(χ) in subformulaClosure OR P(χ) = g.neg for g in subformulaClosure
  unfold closureWithNeg at h_P_in_cwn
  simp only [Finset.mem_union, Finset.mem_image] at h_P_in_cwn
  rcases h_P_in_cwn with h_sub | ⟨g, h_g_sub, h_g_neg_eq⟩
  · -- P(χ) in subformulaClosure, so H(¬χ) = subformula of P(χ)
    apply closureWithNeg_subset_deferralClosure
    apply subformulaClosure_subset_closureWithNeg
    exact closure_imp_left phi _ _ h_sub
  · -- P(χ) = g.neg for g in subformulaClosure
    -- g.neg = P(χ) = neg(H(neg χ)) implies g = H(neg χ)
    unfold Formula.some_past Formula.neg at h_g_neg_eq
    have h_eq : g = Formula.all_past (Formula.neg χ) := by cases h_g_neg_eq; rfl
    rw [h_eq] at h_g_sub
    exact closureWithNeg_subset_deferralClosure phi
      (subformulaClosure_subset_closureWithNeg phi h_g_sub)

/-!
## Boundary Resolution Set

When constructing successors for DeferralRestrictedMCS chains, there is a boundary case
where F(chi) is in the chain but FF(chi) is NOT in deferralClosure. In this case, the
standard negation completeness argument fails because we cannot derive neg(FF(chi)) to
get GG(neg chi) into the chain.

The solution is to add chi directly to the seed when this boundary condition holds.
This forces chi into the successor, resolving the F-obligation immediately rather than
trying to prove it cannot be deferred.

**Design Note**: The chi ∈ u condition ensures augmented_seed ⊆ u, making consistency
trivial. When chi ∉ u but F(chi) ∈ u, forcing chi into the successor requires a different
mechanism (the f_step disjunction plus maximality of the Lindenbaum extension will
eventually include chi when it's compatible).
-/

/--
Formulas that must be resolved at the boundary.

When F(chi) ∈ u and FF(chi) ∉ deferralClosure(phi), we add chi to the seed.
This ensures chi ∈ successor, resolving the F-obligation for F(chi).

The conditions are:
- F(chi) ∈ u: There is an F-obligation for chi
- FF(chi) ∉ deferralClosure: We're at the F-depth boundary, can't defer further

When both conditions hold, adding chi to the seed forces chi ∈ successor.

**Key insight (v3)**: The original definition included `chi ∈ u` to make consistency
trivial, but this defeats the purpose of forcing resolution. The correct definition
removes `chi ∈ u`. Consistency is proven differently: if F(chi) ∈ u then G(neg chi) ∉ u
(by MCS consistency since F(chi) = neg(G(neg chi))), so neg(chi) ∉ g_content(u).
-/
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula)}

/-- Membership in boundary_resolution_set. -/
lemma mem_boundary_resolution_set_iff (phi : Formula) (u : Set Formula) (chi : Formula) :
    chi ∈ boundary_resolution_set phi u ↔
    Formula.some_future chi ∈ u ∧
    Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) := by
  rfl

/--
boundary_resolution_set is a subset of deferralClosure.

If chi ∈ boundary_resolution_set, then F(chi) ∈ u ⊆ deferralClosure.
Since F(chi) ∈ deferralClosure, we have F(chi) ∈ closureWithNeg, so chi ∈ subformulaClosure ⊆ deferralClosure.
-/
theorem boundary_resolution_set_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (deferralClosure phi : Set Formula)) :
    boundary_resolution_set phi u ⊆ (deferralClosure phi : Set Formula) := by
  intro chi h_chi
  obtain ⟨h_F_chi_in_u, _⟩ := h_chi
  -- F(chi) ∈ u ⊆ deferralClosure
  have h_F_chi_in_dc : Formula.some_future chi ∈ deferralClosure phi := h_u h_F_chi_in_u
  -- F(chi) ∈ deferralClosure implies F(chi) ∈ closureWithNeg
  have h_F_chi_cwn := Bimodal.Syntax.some_future_in_deferralClosure_is_in_closureWithNeg phi chi h_F_chi_in_dc
  -- F(chi) ∈ closureWithNeg implies chi ∈ subformulaClosure
  have h_chi_sub := Bimodal.Syntax.some_future_in_closureWithNeg_inner_in_subformulaClosure phi chi h_F_chi_cwn
  -- chi ∈ subformulaClosure ⊆ closureWithNeg ⊆ deferralClosure
  exact Bimodal.Syntax.closureWithNeg_subset_deferralClosure phi
    (Bimodal.Syntax.subformulaClosure_subset_closureWithNeg phi h_chi_sub)

/-!
## Restricted Constrained Successor Seed

The restricted constrained successor seed uses `p_step_blocking_formulas_restricted`
instead of `p_step_blocking_formulas`. This ensures all seed formulas stay within
`deferralClosure phi`, which is necessary for the `DeferralRestrictedMCS` construction.
-/

/--
The restricted constrained successor seed:
`g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u) ∪ boundary_resolution_set(phi, u)`.

This is the correct seed for constructing successors of `DeferralRestrictedMCS`.
Unlike the unrestricted `constrained_successor_seed`, this seed stays within
`deferralClosure phi`, ensuring the Lindenbaum extension can be restricted.

**Key Change (v2)**: The seed now includes `boundary_resolution_set`. This forces
resolution of F-obligations at the boundary (where FF(psi) ∉ deferralClosure).
Without this, the deferral disjunction allows infinite deferral, making the
termination proof in `restricted_bounded_witness` unprovable.
-/
def constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u ∪ boundary_resolution_set phi u

/-- Membership in restricted constrained successor seed. -/
lemma mem_constrained_successor_seed_restricted_iff (phi : Formula) (u : Set Formula) (ψ : Formula) :
    ψ ∈ constrained_successor_seed_restricted phi u ↔
    ψ ∈ g_content u ∨ ψ ∈ deferralDisjunctions u ∨ ψ ∈ p_step_blocking_formulas_restricted phi u ∨
    ψ ∈ boundary_resolution_set phi u := by
  simp only [constrained_successor_seed_restricted, Set.mem_union, or_assoc]

/-- g_content is a subset of the restricted constrained successor seed. -/
lemma g_content_subset_constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) :
    g_content u ⊆ constrained_successor_seed_restricted phi u :=
  Set.subset_union_left.trans (Set.subset_union_left.trans Set.subset_union_left)

/-- Deferral disjunctions are a subset of the restricted constrained successor seed. -/
lemma deferralDisjunctions_subset_constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) :
    deferralDisjunctions u ⊆ constrained_successor_seed_restricted phi u :=
  Set.subset_union_right.trans (Set.subset_union_left.trans Set.subset_union_left)

/-- Restricted P-step blocking formulas are a subset of the restricted seed. -/
lemma p_step_blocking_restricted_subset_constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) :
    p_step_blocking_formulas_restricted phi u ⊆ constrained_successor_seed_restricted phi u :=
  Set.subset_union_right.trans Set.subset_union_left

/-- Boundary resolution set is a subset of the restricted constrained successor seed. -/
lemma boundary_resolution_set_subset_constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) :
    boundary_resolution_set phi u ⊆ constrained_successor_seed_restricted phi u :=
  Set.subset_union_right

/-!
## Constrained Successor Seed (with P-Step Blocking)

The constrained successor seed extends the basic successor deferral seed with
P-step blocking formulas. This construction guarantees the P-step property:
p_content(successor) ⊆ u ∪ p_content(u).

This is symmetric to the constrained predecessor seed (which adds F-step blocking).
-/

/--
The constrained successor seed: `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u)`.

This seed is designed so that its Lindenbaum extension satisfies:
1. Succ u v (G-persistence + F-step from the basic deferral seed)
2. P-step: p_content(v) ⊆ u ∪ p_content(u) (from P-step blocking formulas)

The P-step blocking prevents "bad" P-formulas from appearing in the successor:
if P(φ) ∉ u and φ ∉ u, then H(¬φ) is in the seed, which prevents P(φ) in the successor.
-/
def constrained_successor_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u

/-- Membership in constrained successor seed. -/
lemma mem_constrained_successor_seed_iff (u : Set Formula) (ψ : Formula) :
    ψ ∈ constrained_successor_seed u ↔
    ψ ∈ g_content u ∨ ψ ∈ deferralDisjunctions u ∨ ψ ∈ p_step_blocking_formulas u := by
  simp only [constrained_successor_seed, Set.mem_union, or_assoc]

/-- g_content is a subset of the constrained successor seed. -/
lemma g_content_subset_constrained_successor_seed (u : Set Formula) :
    g_content u ⊆ constrained_successor_seed u :=
  Set.subset_union_left.trans Set.subset_union_left

/-- Deferral disjunctions are a subset of the constrained successor seed. -/
lemma deferralDisjunctions_subset_constrained_successor_seed (u : Set Formula) :
    deferralDisjunctions u ⊆ constrained_successor_seed u :=
  Set.subset_union_right.trans Set.subset_union_left

/-- P-step blocking formulas are a subset of the constrained successor seed. -/
lemma p_step_blocking_formulas_subset_constrained_successor_seed (u : Set Formula) :
    p_step_blocking_formulas u ⊆ constrained_successor_seed u :=
  Set.subset_union_right

/--
A deferral disjunction φ ∨ F(φ) is derivable from F(φ).

This is trivial: F(φ) → (φ ∨ F(φ)) by disjunction introduction (right).
-/
def deferral_disjunction_from_F (φ : Formula) :
    [Formula.some_future φ] ⊢ deferralDisjunction φ := by
  unfold deferralDisjunction
  exact Bimodal.Theorems.Propositional.rdi φ (Formula.some_future φ)

/--
The constrained successor seed is consistent.

**Proof Strategy**:
The seed is `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u)`.

We show each component is a subset of u:
1. g_content(u) ⊆ u: By T-axiom G(φ) → φ and MCS closure
2. deferralDisjunctions(u) ⊆ u: Each φ ∨ F(φ) where F(φ) ∈ u is derivable from F(φ)
3. p_step_blocking_formulas(u) ⊆ u: By `p_step_blocking_formulas_subset_u`

Therefore constrained_successor_seed(u) ⊆ u. Since u is consistent (MCS),
any subset of u is consistent, so the seed is consistent.

This extends `successor_deferral_seed_consistent` with the P-step blocking guarantee.
-/
theorem constrained_successor_seed_consistent (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (constrained_successor_seed u) := by
  -- Show that constrained_successor_seed u ⊆ u
  -- Then any subset L ⊆ seed ⊆ u is consistent since u is MCS

  -- Step 1: g_content(u) ⊆ u via T-axiom (Gφ → φ)
  have h_g_content_in_u : g_content u ⊆ u := by
    intro χ h_gc
    have h_T : [] ⊢ (Formula.all_future χ).imp χ :=
      DerivationTree.axiom [] _ (Axiom.temp_t_future χ)
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_gc

  -- Step 2: deferralDisjunctions(u) ⊆ u
  have h_deferrals_in_u : deferralDisjunctions u ⊆ u := by
    intro χ h_dd
    rw [mem_deferralDisjunctions_iff] at h_dd
    obtain ⟨ψ, h_F_ψ, h_χ_eq⟩ := h_dd
    rw [h_χ_eq]
    have h_imp : [Formula.some_future ψ] ⊢ deferralDisjunction ψ :=
      deferral_disjunction_from_F ψ
    have h_imp' : [] ⊢ (Formula.some_future ψ).imp (deferralDisjunction ψ) :=
      deduction_theorem [] (Formula.some_future ψ) (deferralDisjunction ψ) h_imp
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_imp') h_F_ψ

  -- Step 3: p_step_blocking_formulas(u) ⊆ u (already proven)
  have h_blocking_in_u : p_step_blocking_formulas u ⊆ u :=
    p_step_blocking_formulas_subset_u u h_mcs

  -- Step 4: Combine to show constrained_successor_seed u ⊆ u
  have h_seed_subset_u : constrained_successor_seed u ⊆ u := by
    intro χ h_χ_in_seed
    rw [mem_constrained_successor_seed_iff] at h_χ_in_seed
    rcases h_χ_in_seed with h_gc | h_dd | h_block
    · exact h_g_content_in_u h_gc
    · exact h_deferrals_in_u h_dd
    · exact h_blocking_in_u h_block

  -- Step 5: Conclude consistency
  intro L hL_sub ⟨d⟩
  have h_L_subset_u : ∀ χ ∈ L, χ ∈ u := fun χ h => h_seed_subset_u (hL_sub χ h)
  exact h_mcs.1 L h_L_subset_u ⟨d⟩

/-!
## Constrained Successor Construction

The constrained successor is the Lindenbaum extension of the constrained successor seed.
It satisfies both Succ u v and the P-step property: p_content(v) ⊆ u ∪ p_content(u).
-/

/--
The constrained successor of u: Lindenbaum extension of `constrained_successor_seed u`.

This is the MCS that satisfies:
1. Succ u v (G-persistence + F-step)
2. p_content(v) ⊆ u ∪ p_content(u) (P-step guarantee from blocking formulas)
-/
noncomputable def constrained_successor_from_seed
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Set Formula :=
  lindenbaumMCS_set (constrained_successor_seed u)
    (constrained_successor_seed_consistent u h_mcs h_F_top)

/--
The constrained successor is an MCS.
-/
theorem constrained_successor_from_seed_mcs
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetMaximalConsistent (constrained_successor_from_seed u h_mcs h_F_top) :=
  lindenbaumMCS_set_is_mcs _ _

/--
The constrained successor extends the seed.
-/
theorem constrained_successor_from_seed_extends
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    constrained_successor_seed u ⊆ constrained_successor_from_seed u h_mcs h_F_top :=
  lindenbaumMCS_set_extends _ _

/--
G-persistence for constrained successor: g_content(u) ⊆ constrained_successor.
-/
theorem constrained_successor_satisfies_g_persistence
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    g_content u ⊆ constrained_successor_from_seed u h_mcs h_F_top :=
  Set.Subset.trans (g_content_subset_constrained_successor_seed u)
    (constrained_successor_from_seed_extends u h_mcs h_F_top)

/--
F-step for constrained successor: f_content(u) ⊆ successor ∪ f_content(successor).
-/
theorem constrained_successor_satisfies_f_step
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    f_content u ⊆ (constrained_successor_from_seed u h_mcs h_F_top) ∪
                   f_content (constrained_successor_from_seed u h_mcs h_F_top) := by
  intro φ h_φ_in_f_content
  have h_F_φ : Formula.some_future φ ∈ u := h_φ_in_f_content
  have h_disj_in_seed : deferralDisjunction φ ∈ constrained_successor_seed u :=
    deferralDisjunctions_subset_constrained_successor_seed u
      (deferralDisjunction_mem_of_F_mem u φ h_F_φ)
  have h_disj_in_succ : deferralDisjunction φ ∈ constrained_successor_from_seed u h_mcs h_F_top :=
    constrained_successor_from_seed_extends u h_mcs h_F_top h_disj_in_seed
  rw [deferralDisjunction_eq] at h_disj_in_succ
  have h_mcs_succ := constrained_successor_from_seed_mcs u h_mcs h_F_top
  rcases SetMaximalConsistent.disjunction_elim h_mcs_succ h_disj_in_succ with h_φ | h_F_φ_succ
  · exact Set.mem_union_left _ h_φ
  · exact Set.mem_union_right _ h_F_φ_succ

/--
The constrained successor satisfies the Succ relation.
-/
theorem constrained_successor_succ
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Succ u (constrained_successor_from_seed u h_mcs h_F_top) :=
  ⟨constrained_successor_satisfies_g_persistence u h_mcs h_F_top,
   constrained_successor_satisfies_f_step u h_mcs h_F_top⟩

/--
The constrained successor P-step property:
`p_content(constrained_successor) ⊆ u ∪ p_content(u)`.

**Proof Strategy** (symmetric to `predecessor_f_step`):
For each φ with P(φ) ∈ constrained_successor and φ ∉ u and P(φ) ∉ u:
1. By construction, H(¬φ) ∈ p_step_blocking_formulas(u)
2. Since the seed ⊆ constrained_successor, H(¬φ) ∈ constrained_successor
3. But P(φ) = ¬H(¬φ) by definition (some_past φ = neg (all_past (neg φ)))
4. So both H(¬φ) and ¬H(¬φ) are in constrained_successor, contradicting MCS consistency

This is the key theorem that makes the forward chain satisfy P-step coherence.
-/
theorem successor_p_step
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    p_content (constrained_successor_from_seed u h_mcs h_F_top) ⊆ u ∪ p_content u := by
  intro φ h_φ_in_p_content
  -- h_φ_in_p_content : P(φ) ∈ constrained_successor, i.e., φ ∈ p_content(constrained_successor)
  -- We need: φ ∈ u ∨ P(φ) ∈ u
  by_cases h_φ_in_u : φ ∈ u
  · -- Case 1: φ ∈ u
    exact Set.mem_union_left _ h_φ_in_u
  · by_cases h_P_φ_in_u : Formula.some_past φ ∈ u
    · -- Case 2: P(φ) ∈ u, so φ ∈ p_content(u)
      exact Set.mem_union_right _ h_P_φ_in_u
    · -- Case 3: φ ∉ u and P(φ) ∉ u — derive contradiction
      -- By construction, H(¬φ) ∈ p_step_blocking_formulas(u)
      have h_block : Formula.all_past (Formula.neg φ) ∈ p_step_blocking_formulas u :=
        ⟨φ, h_P_φ_in_u, h_φ_in_u, rfl⟩
      -- p_step_blocking_formulas(u) ⊆ constrained_successor_seed(u)
      have h_in_seed : Formula.all_past (Formula.neg φ) ∈ constrained_successor_seed u :=
        p_step_blocking_formulas_subset_constrained_successor_seed u h_block
      -- constrained_successor extends the seed
      have h_in_succ : Formula.all_past (Formula.neg φ) ∈
          constrained_successor_from_seed u h_mcs h_F_top :=
        constrained_successor_from_seed_extends u h_mcs h_F_top h_in_seed
      -- P(φ) ∈ constrained_successor (from h_φ_in_p_content, unfolding p_content)
      have h_P_in_succ : Formula.some_past φ ∈
          constrained_successor_from_seed u h_mcs h_F_top := h_φ_in_p_content
      -- P(φ) = ¬H(¬φ) by definition (some_past φ = neg (all_past (neg φ)))
      -- So we have both H(¬φ) and ¬H(¬φ) in constrained_successor, contradicting MCS consistency
      have h_mcs_succ := constrained_successor_from_seed_mcs u h_mcs h_F_top
      exact False.elim (set_consistent_not_both h_mcs_succ.1
        (Formula.all_past (Formula.neg φ)) h_in_succ h_P_in_succ)

/-!
## Phase 1: Predecessor Deferral Seed Definition

The predecessor deferral seed is symmetric to the successor seed:
1. `h_content(u)`: All formulas φ where H(φ) ∈ u (H-persistence)
2. `{φ ∨ P(φ) | P(φ) ∈ u}`: Disjunctive deferrals for each P-obligation
-/

/--
A past deferral disjunction for φ: `φ ∨ P(φ)`.

Symmetric to deferralDisjunction, used for predecessor construction.
-/
def pastDeferralDisjunction (φ : Formula) : Formula :=
  Formula.or φ (Formula.some_past φ)

/--
The set of all past deferral disjunctions for u.

For each formula φ such that `P(φ) ∈ u`, we add `φ ∨ P(φ)`.
-/
def pastDeferralDisjunctions (u : Set Formula) : Set Formula :=
  {ψ | ∃ φ : Formula, Formula.some_past φ ∈ u ∧ ψ = pastDeferralDisjunction φ}

/--
The set of F-step blocking formulas for the predecessor seed.

For each formula φ where both F(φ) ∉ u and φ ∉ u, we add G(¬φ) to the seed.
Since F(φ) = ¬G(¬φ) by definition, having G(¬φ) in the predecessor prevents
F(φ) from appearing (as that would contradict MCS consistency).

**Key property**: Every blocking formula G(¬φ) is already in u, because
F(φ) ∉ u implies ¬F(φ) ∈ u, i.e., ¬¬G(¬φ) ∈ u, hence G(¬φ) ∈ u by
double negation elimination.
-/
def f_step_blocking_formulas (u : Set Formula) : Set Formula :=
  {ψ | ∃ φ : Formula, Formula.some_future φ ∉ u ∧ φ ∉ u ∧
    ψ = Formula.all_future (Formula.neg φ)}

/--
The predecessor deferral seed with F-step blocking formulas:
`h_content(u) ∪ pastDeferralDisjunctions(u) ∪ f_step_blocking_formulas(u)`.

This seed is designed so that its Lindenbaum extension v satisfies Succ v u:
1. H-persistence: h_content(u) ⊆ v
2. P-step: p_content(u) ⊆ v ∪ p_content(v) (from past deferral disjunctions)
3. F-step: f_content(v) ⊆ u ∪ f_content(u) (from blocking formulas)
-/
def predecessor_deferral_seed (u : Set Formula) : Set Formula :=
  h_content u ∪ pastDeferralDisjunctions u ∪ f_step_blocking_formulas u

/-!
### Membership Lemmas for Predecessor Seed
-/

/-- Membership in past deferral disjunctions. -/
lemma mem_pastDeferralDisjunctions_iff (u : Set Formula) (ψ : Formula) :
    ψ ∈ pastDeferralDisjunctions u ↔
    ∃ φ : Formula, Formula.some_past φ ∈ u ∧ ψ = pastDeferralDisjunction φ := by
  rfl

/-- If P(φ) ∈ u, then pastDeferralDisjunction φ ∈ pastDeferralDisjunctions u. -/
lemma pastDeferralDisjunction_mem_of_P_mem (u : Set Formula) (φ : Formula)
    (h : Formula.some_past φ ∈ u) :
    pastDeferralDisjunction φ ∈ pastDeferralDisjunctions u :=
  ⟨φ, h, rfl⟩

/-- h_content is a subset of the predecessor deferral seed. -/
lemma h_content_subset_predecessor_deferral_seed (u : Set Formula) :
    h_content u ⊆ predecessor_deferral_seed u :=
  Set.subset_union_left.trans Set.subset_union_left

/-- Past deferral disjunctions are a subset of the predecessor deferral seed. -/
lemma pastDeferralDisjunctions_subset_predecessor_deferral_seed (u : Set Formula) :
    pastDeferralDisjunctions u ⊆ predecessor_deferral_seed u :=
  Set.subset_union_right.trans Set.subset_union_left

/-- F-step blocking formulas are a subset of the predecessor deferral seed. -/
lemma f_step_blocking_formulas_subset_predecessor_deferral_seed (u : Set Formula) :
    f_step_blocking_formulas u ⊆ predecessor_deferral_seed u :=
  Set.subset_union_right

/-- Membership in predecessor deferral seed: from h_content, past deferrals, or blocking formulas. -/
lemma mem_predecessor_deferral_seed_iff (u : Set Formula) (ψ : Formula) :
    ψ ∈ predecessor_deferral_seed u ↔
    ψ ∈ h_content u ∨ ψ ∈ pastDeferralDisjunctions u ∨ ψ ∈ f_step_blocking_formulas u := by
  simp only [predecessor_deferral_seed, Set.mem_union, or_assoc]

/-- Unfolding pastDeferralDisjunction definition. -/
lemma pastDeferralDisjunction_eq (φ : Formula) :
    pastDeferralDisjunction φ = Formula.or φ (Formula.some_past φ) :=
  rfl

/-!
## Pred Relation (Convenience Alias)

The Pred relation is the converse of Succ: Pred u v means Succ v u.
-/

/--
Predecessor relation: v is a predecessor of u in the discrete timeline.

`Pred u v` means `Succ v u` - v sees u as its immediate successor.
-/
def Pred (u v : Set Formula) : Prop := Succ v u

/-- Pred is just Succ with arguments reversed. -/
lemma Pred_iff_Succ_reverse (u v : Set Formula) : Pred u v ↔ Succ v u := Iff.rfl

/-!
## Phase 2: Successor Seed Consistency

The key theorem: `successor_deferral_seed u` is consistent when u is an MCS with F(⊤) ∈ u.

### Consistency Argument

The deferral seed is consistent because:
1. `g_content(u)` is consistent by `g_content_consistent` (proven in DiscreteSuccSeed.lean)
2. Each deferral disjunction `φ ∨ F(φ)` where `F(φ) ∈ u` is "harmless":
   - The disjunction is derivable from F(φ) alone (via disjunction intro on F(φ))
   - Adding such disjunctions cannot create inconsistency with g_content
3. Seriality (`F(⊤) ∈ u`) ensures the MCS has futures where these formulas can be satisfied

### Implementation Note

The direct proof is structurally similar to the axiomatized `discreteImmediateSuccSeed_consistent`
in DiscreteSuccSeed.lean. Under strict temporal semantics, the proof requires showing that
g_content plus deferral disjunctions are jointly satisfiable at some successor state.

We use an axiom with documented semantic justification, consistent with existing patterns.
-/

/--
The successor deferral seed is consistent.

**Proof Strategy** (using T-axiom under reflexive semantics):
The seed is `g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}`.

Under reflexive semantics, the T-axiom `Gφ → φ` is valid. This gives us:
1. g_content(u) ⊆ u: If G(χ) ∈ u, then χ ∈ u by T-axiom and MCS closure
2. Each deferral disjunction φ ∨ F(φ) where F(φ) ∈ u is IN u, because:
   - F(φ) → (φ ∨ F(φ)) is derivable (by right disjunction introduction)
   - By MCS implication property, F(φ) ∈ u implies φ ∨ F(φ) ∈ u

Therefore successor_deferral_seed u ⊆ u. Since u is consistent (MCS),
any subset of u is consistent, so the seed is consistent.
-/
theorem successor_deferral_seed_consistent_axiom (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (successor_deferral_seed u) := by
  -- Show that successor_deferral_seed u ⊆ u
  -- Then any subset L ⊆ seed ⊆ u is consistent since u is MCS

  -- Step 1: g_content(u) ⊆ u via T-axiom (Gφ → φ)
  have h_g_content_in_u : g_content u ⊆ u := by
    intro χ h_gc
    -- χ ∈ g_content(u) means G(χ) ∈ u
    -- By T-axiom: G(χ) → χ is derivable
    -- By MCS closure: χ ∈ u
    have h_T : [] ⊢ (Formula.all_future χ).imp χ :=
      DerivationTree.axiom [] _ (Axiom.temp_t_future χ)
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_gc

  -- Step 2: deferralDisjunctions(u) ⊆ u
  -- Each ψ ∨ F(ψ) where F(ψ) ∈ u is in u by MCS implication property
  have h_deferrals_in_u : deferralDisjunctions u ⊆ u := by
    intro χ h_dd
    rw [mem_deferralDisjunctions_iff] at h_dd
    obtain ⟨ψ, h_F_ψ, h_χ_eq⟩ := h_dd
    rw [h_χ_eq]
    -- F(ψ) ∈ u, and F(ψ) → (ψ ∨ F(ψ)) is derivable
    have h_imp : [Formula.some_future ψ] ⊢ deferralDisjunction ψ :=
      deferral_disjunction_from_F ψ
    have h_imp' : [] ⊢ (Formula.some_future ψ).imp (deferralDisjunction ψ) :=
      deduction_theorem [] (Formula.some_future ψ) (deferralDisjunction ψ) h_imp
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_imp') h_F_ψ

  -- Step 3: Combine to show successor_deferral_seed u ⊆ u
  have h_seed_subset_u : successor_deferral_seed u ⊆ u := by
    intro χ h_χ_in_seed
    rw [mem_successor_deferral_seed_iff] at h_χ_in_seed
    rcases h_χ_in_seed with h_gc | h_dd
    · exact h_g_content_in_u h_gc
    · exact h_deferrals_in_u h_dd

  -- Step 4: Conclude consistency
  -- Any L ⊆ seed ⊆ u with L ⊢ ⊥ contradicts MCS consistency of u
  intro L hL_sub ⟨d⟩
  have h_L_subset_u : ∀ χ ∈ L, χ ∈ u := fun χ h => h_seed_subset_u (hL_sub χ h)
  exact h_mcs.1 L h_L_subset_u ⟨d⟩


/--
The successor deferral seed is consistent.

If u is an MCS with F(⊤) ∈ u, then `successor_deferral_seed u` is consistent.
-/
theorem successor_deferral_seed_consistent (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (successor_deferral_seed u) :=
  successor_deferral_seed_consistent_axiom u h_mcs h_F_top

/-!
## Phase 2: Predecessor Seed Consistency

Symmetric to successor seed consistency, using h_content and P.
-/

/--
A past deferral disjunction φ ∨ P(φ) is derivable from P(φ).

Symmetric to `deferral_disjunction_from_F`.
-/
def past_deferral_disjunction_from_P (φ : Formula) :
    [Formula.some_past φ] ⊢ pastDeferralDisjunction φ := by
  unfold pastDeferralDisjunction
  exact Bimodal.Theorems.Propositional.rdi φ (Formula.some_past φ)

/--
The predecessor deferral seed is consistent.

**Proof Strategy** (using T-axiom under reflexive semantics):
The seed is `h_content(u) ∪ {φ ∨ P(φ) | P(φ) ∈ u}`.

Under reflexive semantics, the T-axiom `Hφ → φ` (temp_t_past) is valid. This gives us:
1. h_content(u) ⊆ u: If H(χ) ∈ u, then χ ∈ u by T-axiom and MCS closure
2. Each past deferral disjunction φ ∨ P(φ) where P(φ) ∈ u is IN u, because:
   - P(φ) → (φ ∨ P(φ)) is derivable (by right disjunction introduction)
   - By MCS implication property, P(φ) ∈ u implies φ ∨ P(φ) ∈ u

Therefore predecessor_deferral_seed u ⊆ u. Since u is consistent (MCS),
any subset of u is consistent, so the seed is consistent.

This is the temporal dual of `successor_deferral_seed_consistent_axiom`.
-/
theorem predecessor_deferral_seed_consistent_axiom (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (predecessor_deferral_seed u) := by
  -- Show that predecessor_deferral_seed u ⊆ u
  -- Then any subset L ⊆ seed ⊆ u is consistent since u is MCS

  -- Step 1: h_content(u) ⊆ u via T-axiom (Hφ → φ)
  have h_h_content_in_u : h_content u ⊆ u := by
    intro χ h_hc
    -- χ ∈ h_content(u) means H(χ) ∈ u
    -- By T-axiom: H(χ) → χ is derivable
    -- By MCS closure: χ ∈ u
    have h_T : [] ⊢ (Formula.all_past χ).imp χ :=
      DerivationTree.axiom [] _ (Axiom.temp_t_past χ)
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_hc

  -- Step 2: pastDeferralDisjunctions(u) ⊆ u
  -- Each ψ ∨ P(ψ) where P(ψ) ∈ u is in u by MCS implication property
  have h_deferrals_in_u : pastDeferralDisjunctions u ⊆ u := by
    intro χ h_dd
    rw [mem_pastDeferralDisjunctions_iff] at h_dd
    obtain ⟨ψ, h_P_ψ, h_χ_eq⟩ := h_dd
    rw [h_χ_eq]
    -- P(ψ) ∈ u, and P(ψ) → (ψ ∨ P(ψ)) is derivable
    have h_imp : [Formula.some_past ψ] ⊢ pastDeferralDisjunction ψ :=
      past_deferral_disjunction_from_P ψ
    have h_imp' : [] ⊢ (Formula.some_past ψ).imp (pastDeferralDisjunction ψ) :=
      deduction_theorem [] (Formula.some_past ψ) (pastDeferralDisjunction ψ) h_imp
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_imp') h_P_ψ

  -- Step 2b: f_step_blocking_formulas(u) ⊆ u
  have h_blocking_in_u : f_step_blocking_formulas u ⊆ u := by
    intro χ h_block
    obtain ⟨φ, h_F_not, _, rfl⟩ := h_block
    -- F(φ) ∉ u means ¬G(¬φ) ∉ u. By negation completeness, ¬¬G(¬φ) ∈ u.
    -- By double negation elimination: G(¬φ) ∈ u.
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_future φ) with h_in | h_neg_in
    · exact absurd h_in h_F_not
    · exact SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_in

  -- Step 3: Combine to show predecessor_deferral_seed u ⊆ u
  have h_seed_subset_u : predecessor_deferral_seed u ⊆ u := by
    intro χ h_χ_in_seed
    rw [mem_predecessor_deferral_seed_iff] at h_χ_in_seed
    rcases h_χ_in_seed with h_hc | h_dd | h_block
    · exact h_h_content_in_u h_hc
    · exact h_deferrals_in_u h_dd
    · exact h_blocking_in_u h_block

  -- Step 4: Conclude consistency
  -- Any L ⊆ seed ⊆ u with L ⊢ ⊥ contradicts MCS consistency of u
  intro L hL_sub ⟨d⟩
  have h_L_subset_u : ∀ χ ∈ L, χ ∈ u := fun χ h => h_seed_subset_u (hL_sub χ h)
  exact h_mcs.1 L h_L_subset_u ⟨d⟩

/--
The predecessor deferral seed is consistent.

If u is an MCS with P(⊤) ∈ u, then `predecessor_deferral_seed u` is consistent.
-/
theorem predecessor_deferral_seed_consistent (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (predecessor_deferral_seed u) :=
  predecessor_deferral_seed_consistent_axiom u h_mcs h_P_top

/-!
## Phase 3: Successor Existence Theorem

Define the successor as the Lindenbaum extension of the deferral seed,
then prove it satisfies both Succ conditions.
-/

/--
The successor of u via deferral seed: Lindenbaum extension of `successor_deferral_seed u`.

This is the MCS that will be u's successor in the discrete timeline.
-/
noncomputable def successor_from_deferral_seed
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Set Formula :=
  lindenbaumMCS_set (successor_deferral_seed u)
    (successor_deferral_seed_consistent u h_mcs h_F_top)

/--
The successor from deferral seed is an MCS.
-/
theorem successor_from_deferral_seed_mcs
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetMaximalConsistent (successor_from_deferral_seed u h_mcs h_F_top) :=
  lindenbaumMCS_set_is_mcs _ _

/--
The successor extends the deferral seed.
-/
theorem successor_from_deferral_seed_extends
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    successor_deferral_seed u ⊆ successor_from_deferral_seed u h_mcs h_F_top :=
  lindenbaumMCS_set_extends _ _

/--
G-persistence: g_content u ⊆ successor.

This is Succ condition (1).
-/
theorem successor_satisfies_g_persistence
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    g_content u ⊆ successor_from_deferral_seed u h_mcs h_F_top :=
  Set.Subset.trans (g_content_subset_successor_deferral_seed u)
    (successor_from_deferral_seed_extends u h_mcs h_F_top)

/--
F-step: f_content u ⊆ successor ∪ f_content(successor).

This is Succ condition (2). For each φ with F(φ) ∈ u:
- The deferral disjunction φ ∨ F(φ) is in the seed, hence in the successor
- By MCS disjunction property, either φ ∈ successor (resolved) or F(φ) ∈ successor (deferred)
- In either case, φ ∈ successor ∪ f_content(successor)
-/
theorem successor_satisfies_f_step
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    f_content u ⊆ (successor_from_deferral_seed u h_mcs h_F_top) ∪
                   f_content (successor_from_deferral_seed u h_mcs h_F_top) := by
  intro φ h_φ_in_f_content
  -- φ ∈ f_content(u) means F(φ) ∈ u
  have h_F_φ : Formula.some_future φ ∈ u := h_φ_in_f_content
  -- The deferral disjunction φ ∨ F(φ) is in the seed
  have h_disj_in_seed : deferralDisjunction φ ∈ successor_deferral_seed u :=
    deferralDisjunctions_subset_successor_deferral_seed u
      (deferralDisjunction_mem_of_F_mem u φ h_F_φ)
  -- Hence in the successor
  have h_disj_in_succ : deferralDisjunction φ ∈ successor_from_deferral_seed u h_mcs h_F_top :=
    successor_from_deferral_seed_extends u h_mcs h_F_top h_disj_in_seed
  -- Unfold: deferralDisjunction φ = φ ∨ F(φ)
  rw [deferralDisjunction_eq] at h_disj_in_succ
  -- By MCS disjunction property: either φ in successor or F(φ) in successor
  have h_mcs_succ := successor_from_deferral_seed_mcs u h_mcs h_F_top
  rcases SetMaximalConsistent.disjunction_elim h_mcs_succ h_disj_in_succ with h_φ | h_F_φ_succ
  · -- Case: φ ∈ successor (resolved)
    exact Set.mem_union_left _ h_φ
  · -- Case: F(φ) ∈ successor (deferred)
    -- This means φ ∈ f_content(successor)
    exact Set.mem_union_right _ h_F_φ_succ

/--
The successor satisfies the Succ relation: Succ u (successor_from_deferral_seed u).
-/
theorem successor_succ
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Succ u (successor_from_deferral_seed u h_mcs h_F_top) :=
  ⟨successor_satisfies_g_persistence u h_mcs h_F_top,
   successor_satisfies_f_step u h_mcs h_F_top⟩

/--
Successor existence theorem.

For any MCS u with F(⊤) ∈ u, there exists an MCS v with Succ(u,v).

This is the key theorem that bypasses the covering lemma and replaces
discrete_Icc_finite_axiom for the discrete track.
-/
theorem successor_exists (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    ∃ v, SetMaximalConsistent v ∧ Succ u v :=
  ⟨successor_from_deferral_seed u h_mcs h_F_top,
   successor_from_deferral_seed_mcs u h_mcs h_F_top,
   successor_succ u h_mcs h_F_top⟩

/-!
## Phase 4: Predecessor Existence Theorem

Define the predecessor as the Lindenbaum extension of the predecessor deferral seed,
then prove it satisfies Pred u v (i.e., Succ v u).

The key insight is the g/h duality:
- h_content(u) ⊆ v implies g_content(v) ⊆ u (by `h_content_subset_implies_g_content_reverse`)
- This gives Succ condition (1) for Succ v u
-/

/--
The predecessor of u via deferral seed: Lindenbaum extension of `predecessor_deferral_seed u`.

This is the MCS that will be u's predecessor in the discrete timeline.
-/
noncomputable def predecessor_from_deferral_seed
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    Set Formula :=
  lindenbaumMCS_set (predecessor_deferral_seed u)
    (predecessor_deferral_seed_consistent u h_mcs h_P_top)

/--
The predecessor from deferral seed is an MCS.
-/
theorem predecessor_from_deferral_seed_mcs
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    SetMaximalConsistent (predecessor_from_deferral_seed u h_mcs h_P_top) :=
  lindenbaumMCS_set_is_mcs _ _

/--
The predecessor extends the deferral seed.
-/
theorem predecessor_from_deferral_seed_extends
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    predecessor_deferral_seed u ⊆ predecessor_from_deferral_seed u h_mcs h_P_top :=
  lindenbaumMCS_set_extends _ _

/--
H-persistence: h_content u ⊆ predecessor.

This is an intermediate step. Combined with g/h duality, this gives Succ condition (1).
-/
theorem predecessor_satisfies_h_persistence
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    h_content u ⊆ predecessor_from_deferral_seed u h_mcs h_P_top :=
  Set.Subset.trans (h_content_subset_predecessor_deferral_seed u)
    (predecessor_from_deferral_seed_extends u h_mcs h_P_top)

/--
G-persistence for Succ v u: g_content(predecessor) ⊆ u.

This is Succ condition (1) for Succ v u. It follows from h_content(u) ⊆ v
via the duality theorem `h_content_subset_implies_g_content_reverse`.
-/
theorem predecessor_satisfies_g_persistence_reverse
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    g_content (predecessor_from_deferral_seed u h_mcs h_P_top) ⊆ u :=
  h_content_subset_implies_g_content_reverse u
    (predecessor_from_deferral_seed u h_mcs h_P_top)
    h_mcs
    (predecessor_from_deferral_seed_mcs u h_mcs h_P_top)
    (predecessor_satisfies_h_persistence u h_mcs h_P_top)

/--
The predecessor F-step condition: f_content(predecessor) ⊆ u ∪ f_content(u).

**Proof Strategy** (via constrained predecessor seed with F-step blocking formulas):
For each φ with F(φ) ∈ predecessor and φ ∉ u and F(φ) ∉ u, the blocking formula
G(¬φ) is in the predecessor seed (by construction). Since the predecessor extends
the seed, G(¬φ) ∈ predecessor. But F(φ) = ¬G(¬φ) by definition, so both G(¬φ)
and ¬G(¬φ) are in the predecessor, contradicting its consistency as an MCS.

This was previously an axiom (`predecessor_f_step_axiom`), now proven directly
via the constrained predecessor seed construction.
-/
theorem predecessor_f_step
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    f_content (predecessor_from_deferral_seed u h_mcs h_P_top) ⊆ u ∪ f_content u := by
  intro φ h_φ_in_f_content
  -- h_φ_in_f_content : F(φ) ∈ predecessor, i.e., φ ∈ f_content(predecessor)
  -- We need: φ ∈ u ∨ F(φ) ∈ u
  by_cases h_φ_in_u : φ ∈ u
  · -- Case 1: φ ∈ u
    exact Set.mem_union_left _ h_φ_in_u
  · by_cases h_F_φ_in_u : Formula.some_future φ ∈ u
    · -- Case 2: F(φ) ∈ u, so φ ∈ f_content(u)
      exact Set.mem_union_right _ h_F_φ_in_u
    · -- Case 3: φ ∉ u and F(φ) ∉ u — derive contradiction
      -- By construction, G(¬φ) ∈ f_step_blocking_formulas(u)
      have h_block : Formula.all_future (Formula.neg φ) ∈ f_step_blocking_formulas u :=
        ⟨φ, h_F_φ_in_u, h_φ_in_u, rfl⟩
      -- f_step_blocking_formulas(u) ⊆ predecessor_deferral_seed(u)
      have h_in_seed : Formula.all_future (Formula.neg φ) ∈ predecessor_deferral_seed u :=
        f_step_blocking_formulas_subset_predecessor_deferral_seed u h_block
      -- predecessor extends the seed
      have h_in_pred : Formula.all_future (Formula.neg φ) ∈
          predecessor_from_deferral_seed u h_mcs h_P_top :=
        predecessor_from_deferral_seed_extends u h_mcs h_P_top h_in_seed
      -- F(φ) ∈ predecessor (from h_φ_in_f_content, unfolding f_content)
      have h_F_in_pred : Formula.some_future φ ∈
          predecessor_from_deferral_seed u h_mcs h_P_top := h_φ_in_f_content
      -- F(φ) = ¬G(¬φ) by definition (some_future φ = neg (all_future (neg φ)))
      -- So we have both G(¬φ) and ¬G(¬φ) in predecessor, contradicting MCS consistency
      have h_mcs_pred := predecessor_from_deferral_seed_mcs u h_mcs h_P_top
      exact False.elim (set_consistent_not_both h_mcs_pred.1
        (Formula.all_future (Formula.neg φ)) h_in_pred h_F_in_pred)

/--
The predecessor satisfies the Succ relation: Succ (predecessor) u.
-/
theorem predecessor_succ
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    Succ (predecessor_from_deferral_seed u h_mcs h_P_top) u :=
  ⟨predecessor_satisfies_g_persistence_reverse u h_mcs h_P_top,
   predecessor_f_step u h_mcs h_P_top⟩

/--
The predecessor satisfies the Pred relation: Pred u (predecessor).
-/
theorem predecessor_pred
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    Pred u (predecessor_from_deferral_seed u h_mcs h_P_top) :=
  predecessor_succ u h_mcs h_P_top

/--
Predecessor existence theorem.

For any MCS u with P(⊤) ∈ u, there exists an MCS v with Pred(u,v), i.e., Succ(v,u).

This is the symmetric dual of `successor_exists`.
-/
theorem predecessor_exists (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    ∃ v, SetMaximalConsistent v ∧ Pred u v :=
  ⟨predecessor_from_deferral_seed u h_mcs h_P_top,
   predecessor_from_deferral_seed_mcs u h_mcs h_P_top,
   predecessor_pred u h_mcs h_P_top⟩

/-!
## P-step Property for Predecessor Construction

The P-step property captures how P-obligations propagate backward through predecessors.
If Succ v u (so v is the predecessor of u), then p_content(u) ⊆ v ∪ p_content(v).
This means each P(φ) ∈ u is either satisfied at v (φ ∈ v) or deferred (P(φ) ∈ v).

This is the backward dual of the F-step property, and follows from the
pastDeferralDisjunctions in the predecessor seed construction.
-/

/--
P-step for predecessors: p_content(u) ⊆ predecessor ∪ p_content(predecessor).

For each formula φ with P(φ) ∈ u:
- The past deferral disjunction φ ∨ P(φ) is in the seed, hence in the predecessor
- By MCS disjunction property, either φ ∈ predecessor (resolved) or P(φ) ∈ predecessor (deferred)
- In either case, φ ∈ predecessor ∪ p_content(predecessor)
-/
theorem predecessor_satisfies_p_step
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    p_content u ⊆ (predecessor_from_deferral_seed u h_mcs h_P_top) ∪
                   p_content (predecessor_from_deferral_seed u h_mcs h_P_top) := by
  intro φ h_φ_in_p_content
  -- φ ∈ p_content(u) means P(φ) ∈ u
  have h_P_φ : Formula.some_past φ ∈ u := h_φ_in_p_content
  -- The past deferral disjunction φ ∨ P(φ) is in the seed
  have h_disj_in_seed : pastDeferralDisjunction φ ∈ predecessor_deferral_seed u :=
    pastDeferralDisjunctions_subset_predecessor_deferral_seed u
      (pastDeferralDisjunction_mem_of_P_mem u φ h_P_φ)
  -- Hence in the predecessor
  have h_disj_in_pred : pastDeferralDisjunction φ ∈ predecessor_from_deferral_seed u h_mcs h_P_top :=
    predecessor_from_deferral_seed_extends u h_mcs h_P_top h_disj_in_seed
  -- Unfold: pastDeferralDisjunction φ = φ ∨ P(φ)
  rw [pastDeferralDisjunction_eq] at h_disj_in_pred
  -- By MCS disjunction property: either φ in predecessor or P(φ) in predecessor
  have h_mcs_pred := predecessor_from_deferral_seed_mcs u h_mcs h_P_top
  rcases SetMaximalConsistent.disjunction_elim h_mcs_pred h_disj_in_pred with h_φ | h_P_φ_pred
  · -- Case: φ ∈ predecessor (resolved)
    exact Set.mem_union_left _ h_φ
  · -- Case: P(φ) ∈ predecessor (deferred)
    -- This means φ ∈ p_content(predecessor)
    exact Set.mem_union_right _ h_P_φ_pred

end Bimodal.Metalogic.Bundle
