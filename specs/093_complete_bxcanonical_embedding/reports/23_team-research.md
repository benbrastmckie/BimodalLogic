# Research Report: Task #93 — Team Research Round 23

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1776363308_87b794

## Summary

Round 23 synthesizes findings from 4 teammates after a partial implementation attempt (Round 22) that proved `target_resolving_fwd_exists_strong` sorry-free but left all 6 sorry sites open. The team converges on a precise diagnosis and a concrete path forward: the `extended_defect_seed_consistent` lemma (existential version) is provable from existing infrastructure, and a demand-driven chain construction replaces the round-robin to make forward_F hold by construction. The Critic identifies a potential 3-defect counterexample but then shows it does NOT defeat the existential form. The Horizons researcher confirms BXCanonical is the only viable path and should not be abandoned.

## Key Findings

### Primary Approach (from Teammate A)

**Finding 1 — Textbook Technique**: Published proofs (Burgess 1984, Goldblatt 1992) use a *demand-driven* construction, not a round-robin. Each F-demand is processed exactly once by appending a new world that directly places the demanded formula. Forward_F holds by construction, not by proof. The round-robin is architecturally incompatible with this technique.

**Finding 2 — `extended_defect_seed_consistent` Is Provable**: The key n-defect lemma follows directly from `resolving_enriched_fwd_exists` + `phi_in_mcs_imp_F_phi` (both already proved sorry-free). The proof: the fold gives M' with direct witness w and disjunctive membership for all others. By `phi_in_mcs_imp_F_phi`, the disjunctive case upgrades to F(χ) ∈ M' in all cases. The seed `{w} ∪ {F(χ) | χ ≠ w} ∪ g_content(M) ⊆ M'`, hence consistent. Estimated ~30 LOC.

**Finding 3 — Core Obstruction Confirmed**: Even with `extended_defect_seed_consistent`, the existing round-robin chain cannot prove forward_F because `Classical.choice` in `set_lindenbaum` can perpetually defer any specific formula. A different chain construction is required.

**Finding 4 — Demand-Driven Chain**: Replace the round-robin with a construction where each step addresses one F-demand directly using `extended_defect_seed_consistent` for seed enrichment. Forward_F holds by construction (each demand is at its dedicated chain step). F-preservation across steps is guaranteed by the enriched seed. Estimated 15-25 hours.

### Alternative Approaches (from Teammate B)

**Finding 5 — Quasimodel Infrastructure Is Complete but Insufficient**: The Quasimodel/ subsystem is sorry-free and integrated at the BXPoint level, but faces the same BXPoint-to-integer bridge problem as the chain construction.

**Finding 6 — FMP Is NOT an Alternative Path**: The Decidability directory has `fmp_contrapositive` but the ROAD_MAP explicitly excludes FMP-based completeness ("provides no canonical model construction, no truth lemma, no structural correspondence").

**Finding 7 — Identity Tail Architecture (Report 13) Is the Right Framework**: The finite-discharge + identity-tail construction has not been implemented despite being identified as mathematically correct in multiple prior rounds. This is essentially the demand-driven construction from Teammate A with an identity tail for t > N. Forward_F in the tail is trivial (defect-free by construction).

**Finding 8 — buc/fuc Are NOT Independent of forward_F**: The u_carry seed enrichment for step transfer fails because G-lifting doesn't preserve Until formulas. The guard condition for fuc requires φ at intermediate steps, not just F(φ). Both reduce to forward_F.

### Gaps and Shortcomings (from Critic)

**Finding 9 — Fold-Order Trick Requires Infrastructure Restructuring**: Processing target last requires changing the fold interface in `enriched_fwd_fold_with_witness` (not a 2-hour test). The function signature hardcodes target as the initial β.

**Finding 10 — 3-Defect Counterexample for extended_defect_seed_consistent**: A concrete scenario where `G((F(ψ₁)∧F(ψ₂))→¬ψ₃) ∈ M` makes the seed `{ψ₃, F(ψ₁), F(ψ₂)} ∪ g_content(M)` inconsistent. **However**, the Critic then shows this does NOT defeat the EXISTENTIAL version: choosing j=1 or j=2 avoids having both F(ψ₁) and F(ψ₂) in the seed simultaneously. The existential version remains provable.

**Finding 11 — restricted_fuc Guard Condition Unanalyzed**: Beyond forward_F for ψ, the Until formula requires φ ∈ fam.mcs(r) for all r between t and s. This guard does not follow from g_content propagation alone and needs additional analysis.

**Finding 12 — t < 0 Case Is Harder**: The backward chain uses h_content (past preservation), not g_content. F-formulas are NOT preserved through backward steps. The t < 0 sorry may require a completely separate argument.

### Strategic Horizons (from Horizons)

**Finding 13 — No Alternative Completeness Path Exists**: Comprehensive codebase analysis confirms the 6 sorries in RootScopedChain.lean are the ONLY active-path blockers. No FMP shortcut, no hidden completeness proof, no alternative route.

**Finding 14 — BXCanonical Must Not Be Abandoned**: 6,400+ lines of sorry-free infrastructure, the only path to the project's stated scientific contribution (representation theorem via canonical model).

**Finding 15 — 2 Dead-Code Sorries in CanonicalModel.lean**: `bx_fmcs_forward_F` and `bx_fmcs_backward_P` are confirmed dead code (not on active completeness path). Deleting them reduces apparent sorry count to 6.

**Finding 16 — Semantic Hybrid Approach**: If ψ is perpetually deferred, then ¬ψ ∈ chain(s) for all s. The restricted G/H truth lemma (sorry-free) would give G(¬ψ) ∈ M, contradicting F(ψ) ∈ M. This semantic argument could bypass the syntactic obstacle. Confidence: medium-low (30%) — requires the restricted truth lemma to apply in the correct direction.

## Synthesis

### Conflicts Resolved

1. **Teammate A claims `extended_defect_seed_consistent` follows in ~10 lines; Critic finds potential counterexample.** Resolution: The Critic's own analysis (Finding 10) shows the counterexample defeats specific j values but NOT the existential form. The existential version IS provable because BX11 fold always produces some j that avoids the cross-contamination. **Teammate A's claim is upheld** with the refinement that the proof must choose j carefully based on the fold's direct witness.

2. **Teammate A proposes demand-driven chain; Teammate B proposes identity-tail architecture.** Resolution: These are the SAME construction described from different angles. The demand-driven chain (Teammate A) IS the finite-discharge + identity-tail approach (Teammate B / Report 13). The finite prefix resolves all demands; the identity tail (constant w_N) handles t > N. **Convergent recommendation.**

3. **Teammate B suggests checking FMP; Horizons confirms FMP is excluded by ROAD_MAP.** Resolution: FMP is explicitly not an alternative for this project's goals (needs canonical model, not bare completeness fact). **FMP path is closed.**

### Gaps Identified

1. **restricted_fuc guard condition**: The Until guard φ ∈ fam.mcs(r) for intermediate r is not analyzed. This may require additional chain properties beyond forward_F.

2. **t < 0 backward case**: The backward chain F-preservation is genuinely different from forward. Needs its own argument (possibly showing F(ψ) propagates to M₀ via h_content properties).

3. **restricted_buc step transfer**: Until step transfer `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)` is NOT derivable from bare FMCS structure. Requires new chain infrastructure (independent of forward_F).

### Recommendations

**The consensus path** (all 4 teammates converge):

1. **Prove `extended_defect_seed_consistent`** (2-4 hours, HIGH confidence)
   - From `resolving_enriched_fwd_exists` + `phi_in_mcs_imp_F_phi`
   - Existential form: ∃ j such that seed is consistent
   - ~30 LOC in OrderedSeedConsistency.lean

2. **Build demand-driven / finite-discharge chain** (15-25 hours, MEDIUM confidence)
   - Replace round-robin with demand-driven construction
   - Each step resolves one demand using enriched seed
   - Identity tail after all demands resolved
   - Forward_F holds by construction

3. **Close all 6 sorry sites** (5-10 hours, conditional on step 2)
   - forward_F: by construction
   - backward_P: symmetric argument or bridge through M₀
   - restricted_tc: follows from forward_F
   - restricted_buc: step transfer via enriched chain properties
   - restricted_fuc: forward_F + guard condition analysis

**Pre-step (independent, 1 hour)**: Delete/mark 2 dead-code sorries in CanonicalModel.lean.

**If extended_defect_seed_consistent fails**: Explore the semantic hybrid approach (Finding 16) — use the restricted G/H truth lemma to derive a contradiction from perpetual deferral.

**Total estimated effort**: 25-40 hours. **Overall confidence**: 55-65%.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach | completed | high |
| B | Alternative approaches | completed (hit context limit) | medium |
| C | Critic | completed | high |
| D | Horizons | completed | high |

## References

- Burgess, J.P. (1984). "Basic tense logic" — demand-driven canonical model construction
- Goldblatt, R. (1992). "Logics of Time and Computation" Ch. 4 — eventuality resolution
- Report 13 (long-term solution) — ordered defect-discharge chain architecture
- Report 17 (round-robin history) — catalog of 19 failed approaches
- Summary 22 — latest implementation attempt results
- OrderedSeedConsistency.lean — `enriched_resolving_seed_consistent`, `ordered_two_defect_seed_consistent`
- RootScopedChain.lean — `resolving_enriched_fwd_exists`, `target_resolving_fwd_exists_strong`, `phi_in_mcs_imp_F_phi`
