import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Metalogic.Bundle.WitnessSeed

#exit  -- Boneyard: archived by task 225 (BX pipeline dead code)

/-!
# Henkin Discrete Chain: Analysis and Infrastructure

This module documents the analysis of approaches to sorry-free `completeness_discrete`
and provides infrastructure lemmas for future Henkin chain constructions.

## Problem Statement

`completeness_discrete` depends on `countermodel_discrete_enriched` which uses:
- `cantor_bfmcs_discrete_restricted_tc` (sorry via `succ_embed_surjective`)
- `cantor_bfmcs_discrete_restricted_fuc` (sorry via `succ_embed_surjective`)
- `cantor_bfmcs_discrete_restricted_buc` (sorry-free, uses `succ_embed_squeeze`)

The sorry chain: `restricted_tc/fuc` → `succ_embed_surjective` →
`limitDomSubtype_isSuccArchimedean` → `succ_cofinal` (sorry).

## Analysis of Approaches (Plans v1-v3)

### Failed Approaches

1. **Direct restricted_tc without surjectivity** (v1): F(phi) guarantees witness y in
   limit_dom, but y might be above the entire succ-orbit. Cannot reach y without succ_cofinal.

2. **Henkin chain with all F-witnesses** (v2): `f_content(M) ∪ g_content(M)` is NOT
   consistent. F(phi) ∧ F(psi) ≠> F(phi ∧ psi).

3. **Successor deferral seed** (v2): `g_content(M) ⊆ M` fails under irreflexive semantics.

4. **One-at-a-time dovetailing** (v2): F(phi) does NOT persist through g_content.
   G(F(phi)) is not derivable from F(phi).

5. **Direct succ_cofinal** (v2): Circular — inductive step requires IsPredArchimedean.

6. **Stage-based induction** (v2): constant-MCS gap scenario is consistent.

### Plan v3 Analysis (One-at-a-Time F-Resolution)

Plan v3 proposed resolving F-formulas one at a time using `forward_temporal_witness_seed_consistent`.
The key obstacle: **F-formula persistence through Lindenbaum extensions is not guaranteed**.

When building `mcs(n+1)` as Lindenbaum({witness} ∪ g_content(mcs(n))):
- F(ψ) ∈ mcs(n) means G(¬ψ) ∉ mcs(n), hence ¬ψ ∉ g_content(mcs(n))
- But the Lindenbaum extension (via Classical.choice) may arbitrarily include G(¬ψ)
- Once G(¬ψ) enters, it propagates forward forever (via G(G(¬ψ)) = temp_4)
- F(ψ) is permanently lost from the chain

Augmented seed approach also fails: `{ψ} ∪ g_content(M) ∪ {F(χ)}` may be inconsistent
(e.g., ψ = ¬χ ∧ G(¬χ) makes {ψ, F(χ)} inconsistent).

## Viable Resolution Paths

1. **Task 129**: Reflexive completeness + conservative extension. Under reflexive semantics,
   G(φ) → φ holds, making g_content(M) ⊆ M. Then F-persistence follows from the full MCS
   containing the seed. Transfer to irreflexive via conservative extension.

2. **Augmented seed consistency proof**: Show `{ψ} ∪ g_content(M) ∪ {F(χ) | F(χ) ∈ M}`
   is consistent for the specific case where ψ is a deferralClosure formula. May require
   temporal-logic-specific reasoning about F-formula interactions.

3. **Restricted MCS truth lemma**: Build restricted FMCS/BFMCS/truth-lemma infrastructure
   for restricted Lindenbaum extensions. Negation completeness within deferralClosure
   guarantees F-persistence.

4. **Construction-level gap analysis**: Show the omega-chain construction cannot produce
   gaps in the succ-orbit (direct proof of succ_cofinal).

## Infrastructure Lemmas

The following lemmas are sorry-free building blocks for any future approach.
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
