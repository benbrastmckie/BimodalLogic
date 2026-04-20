import Bimodal.Metalogic.BXCanonical.RootScopedChain
import Bimodal.Semantics.Validity

/-!
# BX Completeness

The completeness theorem for bimodal logic TM with BX axioms:
if a formula is valid (true in all models), then it is derivable.

## Statement

```
theorem bx_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

## Proof Sketch (Contrapositive)

1. Assume φ is not derivable: ¬Nonempty (DerivationTree [] φ)
2. Then {¬φ} is consistent (otherwise we could derive φ)
3. By Lindenbaum: extend {¬φ} to MCS w₀ containing ¬φ
4. Build canonical TaskModel with BXPoints as world states
5. By truth lemma: ¬φ holds at w₀ in the canonical model
6. Therefore φ is not valid (countermodel exists)

## Status

The completeness proof is wired through `dd_countermodel` from CanonicalModel.lean.
The sorry at the proof site has been replaced with a proof using the BXCanonical
canonical model construction and parametric algebraic representation theorem.

Remaining leaf sorries are in CanonicalModel.lean and RootScopedChain.lean (chain construction coherence proofs).

## References

- Burgess 1984, Goldblatt 1992 (completeness for tense logics)
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Semantics

/-! ## Consistency of {¬φ} When φ Is Not Derivable -/

/--
If φ is not derivable from the empty context, then {¬φ} is set-consistent.

Proof: Suppose {¬φ} is inconsistent. Then some finite L ⊆ {¬φ} with L ⊢ ⊥.
Either L = [] (then [] ⊢ ⊥, contradicting consistency of TM) or L = [¬φ]
(then [¬φ] ⊢ ⊥, so [] ⊢ ¬¬φ by deduction, so [] ⊢ φ by double negation elimination).
-/
theorem neg_consistent_of_not_derivable (φ : Formula)
    (h_not_deriv : ¬Nonempty (DerivationTree [] φ)) :
    SetConsistent ({Formula.neg φ} : Set Formula) := by
  intro L hL ⟨d⟩
  -- Every element of L is ¬φ
  have h_all_neg : ∀ ψ ∈ L, ψ = Formula.neg φ := by
    intro ψ hψ
    exact Set.mem_singleton_iff.mp (hL ψ hψ)
  -- Case split: is ¬φ in L?
  by_cases h_in : Formula.neg φ ∈ L
  · -- ¬φ ∈ L. Put it first, then deduction theorem.
    let L_filt := L.filter (fun y => decide (y ≠ Formula.neg φ))
    have d_reord : DerivationTree (Formula.neg φ :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (cons_filter_neq_perm h_in x).symm)
    -- L_filt ⊆ {¬φ}, so L_filt is a subset of [¬φ,...,¬φ] with all ≠ ¬φ, hence L_filt = []
    -- Actually L_filt may still contain ¬φ if there are duplicates... no, the filter removes ALL ¬φ.
    -- Wait, the filter keeps elements ≠ ¬φ. So L_filt ⊆ L and all elements ≠ ¬φ.
    -- But L ⊆ {¬φ}, so L_filt must be empty.
    have h_filt_empty : L_filt = [] := by
      by_contra h_ne
      obtain ⟨a, ha⟩ := List.exists_mem_of_ne_nil _ h_ne
      have h_and := List.mem_filter.mp ha
      have h_ne_neg : a ≠ Formula.neg φ := by simpa using h_and.2
      exact h_ne_neg (h_all_neg a h_and.1)
    rw [h_filt_empty] at d_reord
    -- Now d_reord : [¬φ] ⊢ ⊥
    have d_negneg : DerivationTree [] (Formula.neg (Formula.neg φ)) :=
      deduction_theorem [] (Formula.neg φ) Formula.bot d_reord
    -- ¬¬φ → φ by double negation elimination
    have h_dne : DerivationTree [] ((Formula.neg (Formula.neg φ)).imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    have d_phi : DerivationTree [] φ :=
      DerivationTree.modus_ponens [] _ _ h_dne d_negneg
    exact h_not_deriv ⟨d_phi⟩
  · -- ¬φ ∉ L. Then L ⊆ {¬φ} with ¬φ ∉ L means L = [] (since only element is ¬φ).
    have h_L_empty : L = [] := by
      by_contra h_ne
      obtain ⟨a, ha⟩ := List.exists_mem_of_ne_nil _ h_ne
      have := h_all_neg a ha
      exact h_in (this ▸ ha)
    rw [h_L_empty] at d
    -- [] ⊢ ⊥ means ⊥ is a theorem, but the empty context is consistent
    -- (propositional logic is consistent)
    -- Actually we can derive: from [] ⊢ ⊥ we get [] ⊢ φ by ex_falso
    have h_ef : DerivationTree [] (Formula.bot.imp φ) :=
      DerivationTree.axiom [] _ (Axiom.ex_falso φ)
    have d_phi : DerivationTree [] φ :=
      DerivationTree.modus_ponens [] _ _ h_ef d
    exact h_not_deriv ⟨d_phi⟩

/-! ## BX Completeness Theorem -/

/--
BX Completeness Theorem: If a formula is valid, then it is derivable.

The contrapositive: if φ is not derivable, then φ is not valid.

**Proof Strategy**:
1. Assume φ is not derivable
2. By `neg_consistent_of_not_derivable`: {¬φ} is consistent
3. By Lindenbaum: extend to MCS w₀ with ¬φ ∈ w₀
4. Build canonical model via `dd_countermodel` (CanonicalModel.lean)
5. By parametric truth lemma: φ is false at the canonical evaluation point
6. Instantiate `valid φ` at the canonical model to get truth, contradiction

**Status**: Proof completed via `dd_countermodel`. Remaining leaf sorries
are in CanonicalModel.lean and RootScopedChain.lean (chain construction coherence).
-/
theorem bx_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ) := by
  -- Contrapositive: assume not derivable, show not valid
  by_contra h
  push_neg at h
  obtain ⟨h_valid, h_not_deriv⟩ := h
  -- Convert IsEmpty to ¬Nonempty
  have h_not_deriv' : ¬Nonempty (DerivationTree [] φ) := not_nonempty_iff.mpr h_not_deriv
  -- {¬φ} is consistent
  have h_cons := neg_consistent_of_not_derivable φ h_not_deriv'
  -- Extend to MCS
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  -- ¬φ ∈ M
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  -- φ ∉ M (since ¬φ ∈ M and M is MCS)
  have h_not_in : φ ∉ M := SetMaximalConsistent.neg_excludes hM_mcs φ h_neg_in
  -- Build canonical model and derive contradiction
  obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
    dd_countermodel M hM_mcs φ h_neg_in
  -- valid φ gives truth at every point, including the countermodel point
  exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)

/--
BX Completeness (alternate form): valid → derivable.
-/
theorem bx_completeness' (φ : Formula) (h : valid φ) :
    Nonempty (DerivationTree [] φ) :=
  bx_completeness φ h

/-! ## Axiom Audit (Phase 0 Results)

Captured during Phase 0 of task 109 (2026-04-20).

### Current State (as of Phase 0)

```
#print axioms bx_completeness
-- depends on: [propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]

#print axioms dd_countermodel
-- depends on: [propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]
```

### Axiom Classification

- `propext`, `Classical.choice`, `Quot.sound` — target axioms (acceptable, standard Lean 4)
- `sorryAx` — must be eliminated (7 critical-path sorries)
- `Lean.ofReduceBool`, `Lean.trustCompiler` — introduced by `native_decide` in Syntax layer
  (Formula.lean, SignedFormula.lean); these are acceptable, not sorry-related

### Sorry Dependency Tree

The `sorryAx` dependency traces through `dd_countermodel` → `dd_bfmcs` in RootScopedChain.lean.

**Dead code sorries** (CanonicalModel.lean, not on critical path — Phase 1 deletes these):
1. `enriched_seed_consistent` (line ~54) — dead code
2. `fwd_succ_f_carry` (line ~98) — dead code
3. `enriched_past_seed_consistent` (line ~113) — dead code
4. `bwd_pred_p_carry` (line ~164) — dead code

**Reflexive base case sorries** (CanonicalModel.lean — Phase 2 eliminates by switching to strict ordering):
5. `g_content_subset_self` (line ~205) — reflexive base case for `fwd_chain_g_content_trans`
6. `h_content_subset_self` (line ~211) — reflexive base case for `bwd_chain_h_content_trans`

**Chain construction coherence sorries** (RootScopedChain.lean — Phases 3-5):
7. `fwd_chain_forward_F` (line ~1044) — F-obligation resolution in forward chain
8. `dd_bfmcs_restricted_tc` forward t-s<0 case (line ~1092) — backward F-resolution
9. `dd_bfmcs_restricted_tc` backward direction (line ~1099) — P-preservation
10. `dd_bfmcs_restricted_buc` (line ~1107) — backward Until coherence
11. `dd_bfmcs_restricted_fuc` (line ~1114) — forward Until coherence

### Target State

After all phases complete, `#print axioms bx_completeness` should show:
`{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}`

(The `Lean.ofReduceBool` and `Lean.trustCompiler` remain from `native_decide` in the Syntax layer
and are not removable without changing the decidability infrastructure.)
-/

#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness
#print axioms Bimodal.Metalogic.BXCanonical.dd_countermodel

end Bimodal.Metalogic.BXCanonical
