# Research Report: Task #81 — Team Research Round 18

**Task**: 81 - F/P Witness Representation Theorem
**Date**: 2026-04-02
**Mode**: Team Research (4 teammates)
**Session**: sess_1775148250_e0d26d

## Summary

Four teammates investigated three approaches to closing the `bfmcs_from_mcs_temporally_coherent` sorry (Completeness.lean:237). All three proposed approaches (modified backward chain, restricted chain families for boxClassFamilies, RestrictedTruthLemma bypass) have fatal or near-fatal flaws. The FMP-based path, not originally one of the three, emerges as the most viable option.

**Critical discovery** (Teammate A): The backward chain P-resolution is **already sorry-free**. The concern about `f_step_blocking` permanently preventing P-resolution was based on a partial misunderstanding. The `G(neg chi)` does force deferral via the T-axiom, but deferral is bounded by deferralClosure finiteness, so P-obligations eventually resolve. The `restricted_backward_chain_backward_P` (SuccChainFMCS.lean:5909) is proven without sorry.

**Critical insight** (Teammate D): All approaches hit the same **Imp-case circularity** in the truth lemma — the forward direction for implications structurally requires the backward direction for sub-formulas, creating a mutual dependency that no modular approach can avoid. The current architecture of composing separate sorry-free components is fundamentally mismatched with completeness proofs, which are inherently monolithic constructions.

## Key Findings

### 1. Approach A: Modified Backward Chain — UNNECESSARY (from Teammate A)

The backward chain construction **does not need modification**. Key discoveries:

- `constrained_predecessor_restricted` (SuccChainFMCS.lean:4484) is sorry-free
- `constrained_predecessor_restricted_p_step` (line 4533) proves the P-step property
- `restricted_backward_chain_backward_P` (line 5909) proves family-level backward_P
- `build_restricted_tc_family` (line 6313) packages both forward_F and backward_P sorry-free
- The fuel=0 sorries (lines 5833, 5991, 6187) are in semantically unreachable branches

**The actual blocker** is NOT in the chain construction but in connecting `RestrictedTemporallyCoherentFamily` to the BFMCS temporal coherence requirement. The restricted chain produces DeferralRestrictedMCS (not full MCS), and the bridge to the completeness theorem is missing.

**Confidence**: HIGH

### 2. Approach B: Replace boxClassFamilies with Restricted Chains — NOT VIABLE (from Teammate B)

Direct replacement fails for three reasons:

1. **DRM ≠ MCS**: Restricted chains produce DeferralRestrictedMCS, not full SetMaximalConsistent. Independent Lindenbaum extensions to full MCS destroy temporal coherence across time positions.

2. **G-propagation breaks**: `restricted_chain_G_propagates` (RestrictedTruthLemma.lean:116) has a sorry because G(G(psi)) may exceed deferralClosure bounds. The Lindenbaum extension at position n and n+1 are independent, so G(psi) ∈ ext(n) does not imply psi ∈ ext(n+1) for formulas outside deferralClosure.

3. **Box modality requires multi-family structure**: boxClassFamilies is the mechanism for S5 modal saturation. Removing it removes the ability to model the Box modality. A single restricted chain cannot model Box semantics.

**Alternative suggested**: Fair-scheduling chain (standard textbook technique) that would replace SuccChainFMCS with a family-level temporally coherent construction working directly with full MCS.

**Confidence**: LOW

### 3. Approach C: RestrictedTruthLemma Bypass — CANNOT WORK (from Teammate C)

The RestrictedTruthLemma **cannot bypass** `bfmcs_from_mcs_temporally_coherent`:

1. The `shifted_truth_lemma` (CanonicalConstruction.lean:652) requires `B.temporally_coherent` as a hypothesis — this is exactly what the sorry provides.

2. The RestrictedTruthLemma proves DRM membership ↔ extended MCS membership (not MCS membership ↔ `truth_at`). Converting requires `restricted_tc_family_to_fmcs` which has 2 additional sorries (CanonicalConstruction.lean:889, 893).

3. All paths converge on the same bottleneck: connecting syntactic membership to semantic truth for temporal operators requires family-level F/P coherence.

**Difficulty ranking** (sorries to close):
- FMP (2 easy sorries) < BFMCS (1 hard sorry) < RestrictedTruthLemma (4 hard sorries)

**Confidence**: HIGH

### 4. Critical Analysis (from Teammate D)

**Pattern across 17+ rounds**: Every approach solves one or two of three simultaneous requirements but introduces gaps in the remaining one:
- **Family-level temporal coherence** (forward_F, backward_P) — restricted chain provides this
- **Multi-family modal saturation** (Box backward) — boxClassFamilies provides this
- **Bidirectional truth lemma** (Imp case) — requires both of the above simultaneously

The mathematical theorem IS true (established in the literature). The difficulty is architectural: the Lean formalization decomposes the construction into modules that cannot be independently proven and then composed.

**Ranking**: C (RestrictedTruthLemma) > FMP > A (Modified backward chain) > B (Replace boxClassFamilies)

**Confidence**: HIGH

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| "f_step_blocking prevents P-resolution" (summary 17) vs "backward chain is sorry-free" (Teammate A) | **Teammate A is correct.** The T-axiom does force deferral, but bounded deferralClosure ensures eventual resolution. The `restricted_backward_chain_backward_P` is proven without sorry. |
| "Restricted chain families can replace boxClassFamilies" (Option B original) vs "NOT viable" (Teammate B) | **Teammate B is correct.** Independent Lindenbaum extensions destroy temporal coherence, and removing boxClassFamilies removes modal saturation. |
| "RestrictedTruthLemma can bypass BFMCS" (Option C original) vs "CANNOT bypass" (Teammate C) | **Teammate C is correct.** The shifted_truth_lemma explicitly requires B.temporally_coherent as input. All paths converge on the same bottleneck. |

### Gaps Identified

1. **No approach addresses all three requirements simultaneously** (temporal coherence + modal saturation + bidirectional truth lemma)
2. **The Imp-case circularity** (forward for Imp needs backward for sub-formulas) is an architectural problem, not a missing lemma
3. **The fair-scheduling chain** (Teammate B's recommendation) has not been analyzed for feasibility within the existing Lean infrastructure
4. **The FMP TruthPreservation sorries** (lines 263, 281) need analysis of whether TM uses reflexive vs strict temporal semantics

### Complete Sorry Map

| Sorry | File:Line | Severity | Closable? |
|-------|-----------|----------|-----------|
| `bfmcs_from_mcs_temporally_coherent` | Completeness.lean:237 | CRITICAL | Hard — requires monolithic construction |
| `restricted_backward_bounded_witness_fueled` fuel=0 | SuccChainFMCS.lean:5833 | LOW | Yes — semantically unreachable |
| `restricted_combined_bounded_witness_fueled` fuel=0 | SuccChainFMCS.lean:5991 | LOW | Yes — semantically unreachable |
| `restricted_combined_bounded_witness_P_fueled` fuel=0 | SuccChainFMCS.lean:6187 | LOW | Yes — semantically unreachable |
| `g_content_union_brs_consistent` | SuccChainFMCS.lean:2190 | DEAD CODE | N/A — depends on false theorem |
| `augmented_seed_consistent` | SuccChainFMCS.lean:2212 | DEAD CODE | N/A — reduces to false theorem |
| `constrained_successor_seed_restricted_consistent` | SuccChainFMCS.lean:2529 | **FALSE** | No — documented counterexample |
| `restricted_chain_G_propagates` | RestrictedTruthLemma.lean:116 | MEDIUM | Maybe — depends on deferralClosure bound |
| `restricted_chain_H_step` | RestrictedTruthLemma.lean:158 | MEDIUM | Maybe — needs full MCS properties |
| `succ_chain_truth_lemma` Box backward | SuccChainTruth.lean:311 | HIGH | No — mathematically false for singleton-Omega |
| `mcs_all_future_closure` | TruthPreservation.lean:263 | LOW | Yes — if TM uses reflexive G semantics (T-axiom) |
| `mcs_all_past_closure` | TruthPreservation.lean:281 | LOW | Yes — if TM uses reflexive H semantics (T-axiom) |

## Recommendations

### Priority 1: FMP Path (2 easy sorries)

Close the 2 TruthPreservation sorries using the T-axiom:
- `mcs_all_future_closure`: G(psi) → psi via `temp_t_future` (already an axiom)
- `mcs_all_past_closure`: H(psi) → psi via `temp_t_past` (already an axiom)

Then `fmp_contrapositive` gives weak completeness. **Estimated effort: 2-4 hours.**

**Caveat**: FMP gives completeness relative to closure MCS membership, not semantic validity over task frames. A bridge lemma from `valid_over D phi` to `phi in every ClosureMCSBundle` is still needed. The FMP path was designed for this bridge but the filtered task model construction may not exist yet.

### Priority 2: Clean Up Fuel=0 Sorries (3 cosmetic sorries)

The fuel=0 branches in SuccChainFMCS.lean (lines 5833, 5991, 6187) are semantically unreachable. Close them by:
- Proving fuel > 0 invariant (initial fuel = B*B+1 > 0)
- Or restructuring to use well-founded recursion instead of fuel

**Estimated effort: 2-3 hours.**

### Priority 3: Remove Dead Code and False Theorem

The `constrained_successor_seed_restricted_consistent` (line 2529) is proven FALSE with a documented counterexample. Remove it and its dependent code (`g_content_union_brs_consistent` line 2190, `augmented_seed_consistent` line 2212).

**Estimated effort: 1 hour.**

### Priority 4: Explore Fair-Scheduling Chain (for full canonical completeness)

If full canonical completeness (not just FMP weak completeness) is needed, the fair-scheduling approach is the standard textbook technique:
1. Enumerate all F-obligations in the starting MCS
2. Build a chain that forces each F-obligation in round-robin order
3. Each successor is a full MCS (not DRM) containing the targeted formula
4. Use `temporal_theory_witness_exists` (sorry-free) for each step

This would replace the SuccChainFMCS construction with a family-level temporally coherent one that works with full MCS, plugging directly into the existing boxClassFamilies/BFMCS architecture.

**Estimated effort: 15-25 hours** (substantial new mathematical development).

**Key risk**: The fair-scheduling approach was previously analyzed (reports 08, 11) and found to have the F-persistence failure — Lindenbaum can kill non-targeted F-obligations. The mitigation is that fair scheduling ensures every obligation is targeted infinitely often, so killed obligations are re-introduced. The challenge is formalizing this argument in Lean.

### Priority 5: Architectural Restructuring (nuclear option)

If all targeted approaches fail, restructure the completeness proof as a single monolithic construction à la Henkin, simultaneously building temporal coherence, modal saturation, and truth equivalence. This is the most mathematically sound approach but requires significant refactoring.

**Estimated effort: 30-50 hours.**

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Modified backward chain | completed | HIGH | Backward chain already sorry-free; blocker is BFMCS bridge |
| B | Restricted chain families | completed | LOW | Direct replacement not viable; recommends fair-scheduling |
| C | RestrictedTruthLemma bypass | completed | HIGH | Cannot bypass; all paths converge on same bottleneck |
| D | Critical analysis | completed | HIGH | Imp-case circularity is the minimal common obstacle |

## References

- Teammate A: `specs/081_fp_witness_representation_theorem/reports/18_teammate-a-findings.md`
- Teammate B: `specs/081_fp_witness_representation_theorem/reports/18_teammate-b-findings.md`
- Teammate C: `specs/081_fp_witness_representation_theorem/reports/18_teammate-c-findings.md`
- Teammate D: `specs/081_fp_witness_representation_theorem/reports/18_teammate-d-findings.md`
- Report 17: `specs/081_fp_witness_representation_theorem/reports/17_standard-completeness-approach.md`
- Report 18 (input): `specs/081_fp_witness_representation_theorem/reports/18_canonical-task-relation-analysis.md`
- Report 19 (input): `specs/081_fp_witness_representation_theorem/reports/19_direction-a-analysis-and-alternatives.md`
- Summary 17: `specs/081_fp_witness_representation_theorem/summaries/17_execution-summary.md`
