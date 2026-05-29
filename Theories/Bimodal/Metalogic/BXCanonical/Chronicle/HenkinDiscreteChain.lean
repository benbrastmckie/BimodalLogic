import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Metalogic.Bundle.WitnessSeed

/-!
# Henkin Discrete Chain: Analysis and Infrastructure

This module documents the analysis of approaches to sorry-free `completeness_discrete`.

## Problem Statement

`completeness_discrete` depends on `countermodel_discrete_enriched` which uses:
- `cantor_bfmcs_discrete_restricted_tc` (sorry via `succ_embed_surjective`)
- `cantor_bfmcs_discrete_restricted_fuc` (sorry via `succ_embed_surjective`)
- `cantor_bfmcs_discrete_restricted_buc` (sorry-free, uses `succ_embed_squeeze`)

The sorry chain: `restricted_tc/fuc` → `succ_embed_surjective` →
`limitDomSubtype_isSuccArchimedean` → `succ_cofinal` (sorry).

## Analysis of Approaches

### Approach 1: Direct restricted_tc without surjectivity

**Idea**: Show F(phi) at succ_embed(n) implies phi at succ_embed(n+1).

**Result**: FAILS. F(phi) guarantees a witness y in limit_dom (from
`limit_F_resolution`), but y might be above the entire succ-orbit.
The backward_G contrapositive shows F(phi) persists at all orbit points,
but cannot show the orbit REACHES y without `succ_cofinal`.

### Approach 2: Henkin chain with all F-witnesses

**Idea**: Define FMCS on Z with mcs(n+1) = Lindenbaum of
`f_content(mcs(n)) ∪ g_content(mcs(n))`.

**Result**: FAILS. `f_content(M) ∪ g_content(M)` is NOT necessarily consistent.
F does not distribute over conjunction: F(phi) ∧ F(psi) does NOT imply
F(phi ∧ psi). Countermodel: Z with phi only at 1, psi only at 2.

### Approach 3: Successor deferral seed

**Idea**: Use `successor_deferral_seed = g_content(M) ∪ {phi ∨ F(phi) | F(phi) ∈ M}`.

**Result**: BLOCKED. Existing consistency proof at `SuccExistence.lean:742-789`
has a sorry (g_content(M) ⊆ M fails under irreflexive semantics).
The direct consistency proof requires showing the seed is consistent without
assuming g_content ⊆ M.

### Approach 4: One-at-a-time dovetailing

**Idea**: Resolve F-formulas one per step, cycling through `deferralClosure(root)`.

**Result**: FAILS. F(phi) at step n does NOT persist to step n+1 through
g_content alone. G(F(phi)) is not derivable from F(phi), so F(phi) drops
out when building the successor MCS.

### Approach 5: Direct succ_cofinal proof

**Idea**: Prove succ_cofinal by induction on pred(b):
if succ^K(a) ≥ pred(b), then succ^{K+1}(a) ≥ succ(pred(b)) = b.

**Result**: CIRCULAR. The inductive step replaces b with pred(b), which
requires IsPredArchimedean ↔ IsSuccArchimedean.

## Viable Paths Forward

1. **Construction-level gap elimination**: Show the omega-chain construction
   cannot produce gaps. When succ^n(a) converges to L < b, the C5
   counterexamples at orbit points are eventually processed, adding
   witnesses that the orbit must pass through. This requires deep
   interaction with `omega_chain_elim_result` internals.

2. **Prove successor_deferral_seed consistency for general fc**: The seed
   {g_content(M) ∪ deferral disjunctions} might be consistently provable
   using the generalized temporal K axiom (as in `forward_temporal_witness_seed`
   but generalized to multiple disjunctions).

3. **Task 129**: Weak/reflexive completeness + conservative extension.
   Under reflexive semantics, G(phi) → phi holds, making g_content(M) ⊆ M.
   Then the seed consistency is trivial. Conservative extension transfers
   the result to irreflexive semantics.

## Key Lemma: g_content(M) is consistent

This IS provable (shown below) and is a building block for any Henkin chain approach.
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Classical

/--
g_content(M) is consistent for any MCS M.

Proof: F(⊤) ∈ M (from seriality). By `forward_temporal_witness_seed_consistent`,
{⊤} ∪ g_content(M) is consistent. Since g_content(M) ⊆ {⊤} ∪ g_content(M),
g_content(M) is consistent.
-/
theorem g_content_consistent {fc : FrameClass} (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M) :
    SetConsistent (fc := fc) (g_content M) := by
  have h_top : (Formula.bot.imp Formula.bot) ∈ M :=
    theorem_in_mcs h_mcs (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_F_top : Formula.some_future (Formula.bot.imp Formula.bot) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.serial_future trivial)) h_top
  have h_seed := forward_temporal_witness_seed_consistent M h_mcs _ h_F_top
  have h_sub : g_content M ⊆ forward_temporal_witness_seed M (Formula.bot.imp Formula.bot) :=
    g_content_subset_forward_temporal_witness_seed M _
  intro L hL ⟨d⟩
  exact h_seed L (fun x hx => h_sub (hL x hx)) ⟨d⟩

/--
h_content(M) is consistent for any MCS M (past dual of g_content_consistent).
-/
theorem h_content_consistent {fc : FrameClass} (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M) :
    SetConsistent (fc := fc) (h_content M) := by
  have h_top : (Formula.bot.imp Formula.bot) ∈ M :=
    theorem_in_mcs h_mcs (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_P_top : Formula.some_past (Formula.bot.imp Formula.bot) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.serial_past trivial)) h_top
  have h_seed := past_temporal_witness_seed_consistent M h_mcs _ h_P_top
  have h_sub : h_content M ⊆ past_temporal_witness_seed M (Formula.bot.imp Formula.bot) :=
    h_content_subset_past_temporal_witness_seed M _
  intro L hL ⟨d⟩
  exact h_seed L (fun x hx => h_sub (hL x hx)) ⟨d⟩

end Bimodal.Metalogic.BXCanonical.Chronicle
