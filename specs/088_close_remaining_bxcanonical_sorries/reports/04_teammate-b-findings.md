# Teammate B Findings: Alternative Approaches for BXCanonical Sorries

## Key Findings

### 1. No FMP Directory at Metalogic/FMP/ — It Is in Decidability/FMP/

The FMP path exists at `Theories/Bimodal/Metalogic/Decidability/FMP/` (not a standalone Metalogic/FMP/). Critically, **this FMP path has zero sorries in the Decidability/ subtree**. The FMP machinery (filtration, closure MCS, FiniteModel, TruthPreservation, FMP.lean) is sorry-free. This is significant: the FMP infrastructure is complete but not yet connected to the full Until/Since truth lemma.

### 2. The 6 Sorry Sites, Precisely Located

**Frame.lean (4 sorries)**:
- `bx_until_eventuality_resolution` (line 653): Forward Until witness with guard condition
- `bx_until_backward` (line 675): Backward Until from witness pattern
- `bx_since_eventuality_resolution` (line 690): Mirror for Since (forward)
- `bx_since_backward` (line 704): Mirror for Since (backward)

**CanonicalEmbedding.lean (1 sorry)**:
- Line 418: `usf_completeness` Case B — backward truth bridge for G/H inside imp when χ contains G or H. The comment explains the gap: "flatten(χ) ∈ w does not imply χ ∈ w when χ contains G or H."

**Completeness.lean (1 sorry)**:
- Line 160: `bx_completeness` — full completeness requires TaskModel embedding + Until/Since eventuality resolution.

### 3. Quasimodel Approach: Not Applicable Here

The codebase has no quasimodel files (no "quasimodel", "filtration" in BXCanonical, no Reynolds-style step construction). More importantly: the existing FMP `Decidability/FMP/` path IS essentially a quasimodel approach (closure MCS = finite pre-model). However:

- `TruthPreservation.lean` has the MCS truth definition and filtration machinery
- It explicitly archives `mcs_all_future_closure` / `mcs_all_past_closure` as requiring the T-axiom
- The comment: "FMP proof strategy needs redesign for strict semantics (task 82)"
- `filtration_all_future_forward` and `filtration_all_past_forward` are also archived

This means the FMP path hit the same underlying problem: **G/H truth preservation under filtration requires strict vs. reflexive semantics resolution**, not the G-content vs. Until-witness mismatch. Under BX's reflexive semantics (G is reflexive), the FMP filtration's archived lemmas likely ARE provable — they were only archived for strict semantics.

**Potential**: Re-examine whether the archived FMP G/H filtration lemmas can be restored under reflexive BX semantics. If so, the FMP path to Until/Since completeness via filtration lemma might be viable.

### 4. Two-Phase Construction: Algebraic Path Is More Mature

The `Algebraic/` directory has a sophisticated two-level structure:
- **ParametricTruthLemma**: D-parametric truth lemma (G/H proved, Until/Since not in scope)
- **UltrafilterChain**: Ultrafilter-based box-class witness construction (18 sorries, mostly `temp_4` derivation gaps — the temp_4 axiom was removed in BX refactoring)
- **DovetailedChain**: Explicitly DEPRECATED — marked as architecturally blocked by the same X-vs-G mismatch

The Algebraic path has its own blocking issue: `succ_chain_restricted_forward_F` and its past mirror are sorry'd in `UltrafilterChain.lean`. These are the family-level temporal coherence sorrries that the comment identifies as "more precise than `bfmcs_from_mcs_temporally_coherent`."

**Key insight**: The Algebraic path's approach is bottom-up (build chain → prove temporal coherence → apply truth lemma). The BXCanonical approach is top-down (build canonical ordering → extract witnesses). Both hit the same problem: Until/Since witnesses don't propagate through G-content-based orderings.

### 5. Defect Elimination / Step-by-Step: The SuccChain Path

The closest analog to Reynolds' defect-elimination approach is `Bundle/SuccChainFMCS.lean` (imported by `UltrafilterChain.lean`). The UltrafilterChain module explicitly mentions:

> "All sorry-free from earlier sections: `temporal_theory_witness_exists`, `past_theory_witness_exists`, `box_theory_witness_exists`"

And separately:
> "`SuccChainFMCS` / `SuccChainTemporalCoherent` - sorry-free FMCS with temporal coherence"

This suggests the SuccChain infrastructure provides sorry-free forward temporal coherence for F/P formulas. The blocker is `succ_chain_restricted_forward_F` for the **restricted** chain (deferralClosure-scoped version). The unrestricted version may be sorry-free.

**Viable path**: Check if the unrestricted SuccChainFMCS provides family-level `forward_F`/`backward_P` for all formulas, not just deferralClosure. If yes, plugging this into the ParametricTruthLemma would close the main completeness gap.

### 6. CanonicalEmbedding Sorry (Case B) Is Independent

The sorry at CanonicalEmbedding.lean:418 is logically independent from the Frame.lean sorries. It concerns `usf_completeness` (Until/Since-free fragment), where Case B needs a non-constant history to distinguish `χ` from `flatten(χ)` when χ contains G or H. A two-point history (constant × one-step) would solve this. This is not blocked by the Until/Since eventuality gap.

### 7. UntilSinceCoherence.lean Has Key Infrastructure

`Bundle/UntilSinceCoherence.lean` explicitly provides `backward_until_from_step` and `backward_since_from_step` parameterized by a step-transfer hypothesis. The module docstring says:

> "Any chain construction that can prove the step property (e.g., via enriched seeds or modified successor construction) can use these to derive full backward Until/Since coherence."

The step property needed: `(φ U ψ) ∈ fam.mcs (r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`.

This is SPECIFICALLY what BX5 (self-accumulation) and BX6 (absorption) are designed to provide axiomatically — the question is whether they can be leveraged in the MCS context.

## Recommended Approach

### Primary Recommendation: Enrich Lindenbaum Seeds with Until-Persistence

**Core idea**: Rather than trying to close Frame.lean sorries directly (which requires bx_le totality or Until-induction — both blocked), build a modified successor chain construction where Until persistence is baked in.

Specifically, when creating the Lindenbaum extension at each chain step, include Until-seed material: for each `φ U ψ ∈ chain(n)`, ensure that either ψ ∈ chain(n+1) OR `φ U ψ ∈ chain(n+1)` (one-step unfolding). This is exactly what BX5 says: if `φ U ψ` holds, then `(φ ∧ φ U ψ) U ψ` holds, which means at intermediate points BOTH φ AND `φ U ψ` hold.

The `backward_until_from_step` infrastructure in `UntilSinceCoherence.lean` is already positioned to use this.

**Why this avoids the G-content mismatch**: We don't need bx_le totality. Instead, we're building a new chain (not the BXCanonical ordering) specifically designed to resolve eventualities. Then we use this chain to construct the countermodel, not the canonical ordering directly.

**Relationship to existing code**: This is essentially what the DovetailedChain.lean attempted but failed at due to the X-vs-G mismatch. The difference is using BX5/BX6/BX7 directly in the seed construction rather than relying on g_content propagation.

### Secondary Recommendation: Restore FMP Filtration G/H Lemmas under Reflexive Semantics

The archived `mcs_all_future_closure`/`mcs_all_past_closure` in TruthPreservation.lean were removed because they required the T-axiom. Under BX's reflexive semantics, `G(φ) → φ` IS an axiom (BX1: `temp_t_future`). So these lemmas should be provable again.

If restored, the FMP filtration approach could handle G/H cases without the canonical ordering altogether, sidestepping the Frame.lean sorries for the completeness proof via FMP.

**However**: The FMP filtration approach still has the Until/Since filtration problem — how truth of `φ U ψ` is preserved under the quotient. Filtration of Until is notoriously difficult (it's not a modality in the standard sense).

### Tertiary Recommendation: Two-Point History for CanonicalEmbedding Case B

The `usf_completeness` sorry at CanonicalEmbedding.lean:418 can be fixed independently by constructing a two-point TaskModel: world 0 = the MCS w, world 1 = some extension, with history `t ↦ w` for t ≤ 0 and `t ↦ w'` for t > 0. This makes G(χ) at time 0 equivalent to χ ∈ w', breaking the flatten collapse. This is a self-contained fix.

## Evidence

- **Frame.lean:585-620**: Confirms the mathematical analysis of the blockage — all three approaches (A, B, C) are shown to fail for bx_le-based orderings
- **UntilSinceCoherence.lean:25-28**: Explicitly states the step-transfer pattern needed and that it's NOT available from bare FMCS
- **BX5 (self_accum_until)**: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` — provides persistence of Until formula through guard
- **BX6 (absorb_until)**: `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)` — prevents infinite deferral
- **Decidability/FMP/**: 0 sorries — complete infrastructure available for finite model reasoning
- **UltrafilterChain.lean:3040**: "sorry-free from earlier sections: temporal_theory_witness_exists, past_theory_witness_exists" — F/P witnesses exist without sorries at bundle level
- **UltrafilterChain.lean:3905-3936**: `succ_chain_restricted_forward_F` sorry — the precise remaining gap for family-level coherence

## Confidence Level: Medium-High

The primary recommendation (enriched seeds) has strong theoretical backing from the BX axiom system (BX5/BX6/BX7 are specifically designed for Until eventuality reasoning) and the existing parameterized infrastructure in UntilSinceCoherence.lean. The main uncertainty is whether enriching the seeds prevents contradictions during Lindenbaum extension — this needs careful proof engineering.

The secondary recommendation (restore FMP filtration) has medium confidence — the T-axiom issue is genuine and BX1 provides it, but Until/Since filtration remains hard.

The tertiary recommendation (two-point history for Case B) has high confidence as a self-contained fix for a logically independent sorry.
