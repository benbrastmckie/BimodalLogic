import Bimodal.Metalogic.WeakCanonical.EFGames.Decomposition
import Bimodal.Metalogic.WeakCanonical.EFGames.GapDetection

/-!
# NF-Game Bridge: Helper Lemmas

Bridge lemmas connecting the NormalForm world (nf_characteristic, nf_eval_nf,
interval_nf_types on M.carrier) with the EF game world (rank_type,
stavi_temporal_truth_mu, decomposition_agreement on ExtendedCarrier).

## Architecture

The Stavi completeness proof needs: 2-var depth-k NFs are determined by
1-var NFs + ordering + interval types. The direct NF induction approach
FAILS at the sub-interval splitting problem (5 sessions confirmed).

The correct path (GHR93) goes THROUGH the EF game:

1. NF hypotheses → decomposition_agreement (Bridge A)
2. decomposition_agreement → ghr93_duplicator_wins (already sorry-free!)
3. ghr93_duplicator_wins → NF agreement (Bridge B)

This file provides helper lemmas for the bridge. The full bridge
implementation requires ~300-400 additional lines connecting NF types
on M.carrier with rank_type/formula_agreement on ExtendedCarrier.

## Why the Direct Approach Fails

The sorries in `nf_2var_existential_transfer` (StaviCompleteness.lean
lines 2347, 2429) need 4-var existential transfer at depth j' for the
3-point configuration (u,x,t)/(u',x',t'). Zone matching finds u' with
matching 1-var NF and orderings. But the 4-var NF requires sub-interval
types for ALL pairs in the 3-point config, including (w,u) and (u,x).
These sub-interval types are NOT determined by the interval types of (x,t):
a type realized in (x,t) might appear only in (u,t) but not in (x,u).

The game solves this because its compositional structure (Composition.lean)
splits intervals while maintaining the game invariant at each sub-interval.

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Lemma 11
- Task 155: literature-interval-splitting report (Section 5)
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## NF Agreement Helpers

Lemmas connecting depth-k 1-var NF agreement to predicate agreement,
StaviFormula agreement, and depth-j agreement (for j ≤ k). -/

/-- If x and x' have the same depth-k 1-var NF, then for every depth-k NF nf_k,
    x satisfies nf_k iff x' satisfies nf_k. -/
theorem nf_agreement_from_nf_char_eq {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k : Nat} {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x'))
    (nf_k : NormalForm sig k 1) :
    nf_eval_nf M k 1 (fun _ => x) nf_k ↔
    nf_eval_nf M' k 1 (fun _ => x') nf_k :=
  nf_agreement_from_shared_nf M (fun _ => x) M' (fun _ => x')
    (nf_characteristic M k 1 (fun _ => x))
    (nf_characteristic_satisfies M k 1 (fun _ => x))
    (h_nf ▸ nf_characteristic_satisfies M' k 1 (fun _ => x'))
    nf_k

/-- NF agreement at char_k level: if x and x' have the same depth-k 1-var NF,
    and char_k correctly characterizes depth-k NFs, then for every nf_k,
    char_k nf_k has the same truth at x and x'. -/
theorem nf_char_eq_implies_stavi_char_agree {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds}
    {k : Nat} {x : M.carrier} {x' : M'.carrier}
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (N : OrderedMonadicStructure sig) (t : N.carrier),
        stavi_temporal_truth N atomMap t (char_k nf_k) ↔
        nf_eval_nf N k 1 (fun _ => t) nf_k)
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x'))
    (nf_k : NormalForm sig k 1) :
    stavi_temporal_truth M atomMap x (char_k nf_k) ↔
    stavi_temporal_truth M' atomMap x' (char_k nf_k) := by
  rw [char_k_correct nf_k M x, char_k_correct nf_k M' x']
  exact nf_agreement_from_nf_char_eq h_nf nf_k

/-- Predicate agreement at a single point follows from 1-var NF agreement. -/
theorem pred_agree_from_nf_char {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k : Nat} {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x'))
    (p : sig.preds) :
    M.interp p x ↔ M'.interp p x' :=
  atom_agreement_from_nf M (fun _ => x) M' (fun _ => x')
    (nf_agreement_from_nf_char_eq h_nf) (.pred p 0)

/-- Depth-k 1-var NF agreement implies depth-j 1-var NF agreement for j ≤ k. -/
theorem nf_char_depth_le {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k j : Nat} (hj : j ≤ k)
    {a : M.carrier} {a' : M'.carrier}
    (h : nf_characteristic M k 1 (fun _ => a) =
         nf_characteristic M' k 1 (fun _ => a')) :
    nf_characteristic M j 1 (fun _ => a) =
    nf_characteristic M' j 1 (fun _ => a') := by
  have h_agree_j : ∀ nf_j : NormalForm sig j 1,
      nf_eval_nf M j 1 (fun _ => a) nf_j ↔
      nf_eval_nf M' j 1 (fun _ => a') nf_j :=
    nf_agreement_monotone j k 1 hj M (fun _ => a) M' (fun _ => a')
      (nf_agreement_from_nf_char_eq h)
  apply nf_eval_unique M' j 1 (fun _ => a')
  · exact (h_agree_j _).mp (nf_characteristic_satisfies M j 1 (fun _ => a))
  · exact nf_characteristic_satisfies M' j 1 (fun _ => a')

/-! ## Depth-0 NF Transfer

At depth 0, NFs are purely atomic (predicate + ordering assignments).
The n-variable version is provable from pointwise NF agreement + orderings. -/

/-- At depth 0, n-variable NF equality follows from atom agreement alone. -/
theorem nvar_nf_eq_depth_zero {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    (n : Nat)
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_atoms : ∀ a : AtomKind sig n, atom_eval M env_M a ↔ atom_eval M' env_M' a) :
    nf_characteristic M 0 n env_M = nf_characteristic M' 0 n env_M' := by
  apply nf_eval_unique M' 0 n env_M'
  · intro a
    exact ⟨fun ha => ((nf_characteristic_satisfies M 0 n env_M) a).mp ((h_atoms a).mpr ha),
           fun ha => (h_atoms a).mp (((nf_characteristic_satisfies M 0 n env_M) a).mpr ha)⟩
  · exact nf_characteristic_satisfies M' 0 n env_M'

/-- Atom agreement at n variables from pointwise 1-var NF agreement and orderings. -/
theorem atom_agree_from_pointwise_nf {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k n : Nat}
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf_points : ∀ i : Fin n,
      nf_characteristic M k 1 (fun _ => env_M i) =
      nf_characteristic M' k 1 (fun _ => env_M' i))
    (h_order : ∀ i j : Fin n,
      (env_M i < env_M j ↔ env_M' i < env_M' j))
    (a : AtomKind sig n) :
    atom_eval M env_M a ↔ atom_eval M' env_M' a := by
  cases a with
  | pred p i =>
    simp only [atom_eval]
    exact pred_agree_from_nf_char (h_nf_points i) p
  | order i j _ =>
    simp only [atom_eval]
    exact h_order i j

/-- Corollary: depth-0 n-var NF equality from pointwise data. -/
theorem nvar_nf_eq_depth_zero_from_pointwise {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k n : Nat}
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf_points : ∀ i : Fin n,
      nf_characteristic M k 1 (fun _ => env_M i) =
      nf_characteristic M' k 1 (fun _ => env_M' i))
    (h_order : ∀ i j : Fin n,
      (env_M i < env_M j ↔ env_M' i < env_M' j)) :
    nf_characteristic M 0 n env_M = nf_characteristic M' 0 n env_M' :=
  nvar_nf_eq_depth_zero n env_M env_M'
    (atom_agree_from_pointwise_nf env_M env_M' h_nf_points h_order)


end Bimodal.Metalogic.WeakCanonical
