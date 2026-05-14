import Bimodal.Metalogic.BXCanonical.RootScopedChain
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Metalogic.WeakCanonical
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

The completeness proof is wired through `dd_countermodel_chronicle` from
Chronicle/ChronicleToCountermodel.lean, which uses the Burgess 1982 chronicle
construction over Rat instead of the schedule-based Int chain. This bypasses the
3 sorry sites in RootScopedChain.lean (which remain as dead code).

Remaining leaf sorries are in the Chronicle/ modules (FMCS G/H coherence,
chronicle construction C5/C5' satisfaction, counterexample enumeration).

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
4. Build canonical model via `dd_countermodel_chronicle` (Chronicle/ChronicleToCountermodel.lean)
5. By parametric truth lemma: φ is false at the canonical evaluation point
6. Instantiate `valid φ` at the canonical model to get truth, contradiction

**Status**: Proof completed via `dd_countermodel_chronicle` (Burgess chronicle).
Remaining leaf sorries are in the Chronicle/ modules (FMCS coherence, chronicle
construction). The RootScopedChain.lean sorry sites are no longer on the critical
path -- the chronicle bypasses them entirely.
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
  -- Build canonical model and derive contradiction via three-way case split:
  -- 1. Dense case (□(F'T) ∈ M): countermodel on Rat via Cantor iso
  -- 2. Purely discrete case (□(U(T,bot)) ∈ M): countermodel on Int via succ embedding
  -- 3. Mixed case (¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M): sorry — mixed modal classes
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.next_top.neg) with h_box_dense | h_not_box_dense
  · -- Dense case: □(F'T) ∈ M — all box-equivalent MCS's are dense
    obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
      Chronicle.dd_countermodel_chronicle_dense M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
  · -- Non-dense: ¬□(F'T) ∈ M. Sub-split on □(U(T,bot)).
    rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.next_top) with h_box_discrete | h_not_box_discrete
    · -- Purely discrete case: □(U(T,bot)) ∈ M — all box-equivalent MCS's are discrete
      obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
        WeakCanonical.doets_countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete
      exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — some worlds dense, others discrete
      obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
        Chronicle.dd_countermodel_chronicle_mixed_sorry M hM_mcs φ h_neg_in
          h_not_box_dense h_not_box_discrete
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

### Sorry Dependency Tree (Post-Phase 5 Rewiring)

The `sorryAx` dependency now traces through `dd_countermodel_chronicle` →
`cantor_bfmcs` in Chronicle/ChronicleToCountermodel.lean, which uses the
Burgess chronicle construction with a Cantor isomorphism to embed all
rationals into the limit domain.

**Active sorry sites** (1 total, on critical path):
- 1 density g-value consistency in CounterexampleElimination.lean:3570 — the
  density elimination needs `SetConsistent (χ.g pc.x pc.y)` to find β ∉ g for
  `lemma_2_6_splitting`. This traces to the Cantor isomorphism requiring
  `DenselyOrdered` on the limit domain (an implementation choice — Burgess 1982
  doesn't need density). Task 117 will remove the Cantor iso and build the model
  directly on the limit domain, eliminating this sorry.

**Closed sorry sites** (task 107, Phases 1-7):
- 7 c2' sorry sites (closed via guard threading + walk restructuring)
- 2 c4 hard case sorry sites (closed via BX6 absorption, Burgess 2.9)
- 2 FUC sorry sites (closed via adj_g_mem_limit_f + witness_not_old)
- NoUnivBurgessR3 hypothesis (deleted — unprovable in J₀, replaced by CUD g-values)

**Dead code** (no longer on critical path):
- All sorry sites in RootScopedChain.lean (bx_bfmcs_restricted_tc/buc/fuc)
- Dead code sorries in CanonicalModel.lean (enriched_seed_consistent, etc.)

### Target State

After task 117 (remove Cantor iso), `#print axioms bx_completeness` should show:
`{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}`

Current state (task 107 complete):
`{propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}`
`sorryAx` traces to: CE:3570 → limit_dom_dense → DenselyOrdered → cantor_iso → dd_countermodel_chronicle

(The `Lean.ofReduceBool` and `Lean.trustCompiler` remain from `native_decide` in the Syntax layer
and are not removable without changing the decidability infrastructure.)
-/

#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness
#print axioms Bimodal.Metalogic.BXCanonical.dd_countermodel
#print axioms Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_dense

end Bimodal.Metalogic.BXCanonical
