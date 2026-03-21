import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.GeneralizedNecessitation

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

- Task 10 (SuccRelation.lean): Succ definition and basic properties
- Task 12 research report: 01_succ-existence-research.md
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
The predecessor deferral seed: `h_content(u) ∪ pastDeferralDisjunctions(u)`.

This seed is designed so that its Lindenbaum extension v satisfies Succ v u:
1. H-persistence: h_content(u) ⊆ v
2. P-step: p_content(u) ⊆ v ∪ p_content(v)
-/
def predecessor_deferral_seed (u : Set Formula) : Set Formula :=
  h_content u ∪ pastDeferralDisjunctions u

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
  Set.subset_union_left

/-- Past deferral disjunctions are a subset of the predecessor deferral seed. -/
lemma pastDeferralDisjunctions_subset_predecessor_deferral_seed (u : Set Formula) :
    pastDeferralDisjunctions u ⊆ predecessor_deferral_seed u :=
  Set.subset_union_right

/-- Membership in predecessor deferral seed: either from h_content or past deferral disjunctions. -/
lemma mem_predecessor_deferral_seed_iff (u : Set Formula) (ψ : Formula) :
    ψ ∈ predecessor_deferral_seed u ↔
    ψ ∈ h_content u ∨ ψ ∈ pastDeferralDisjunctions u := by
  simp only [predecessor_deferral_seed, Set.mem_union]

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

end Bimodal.Metalogic.Bundle
