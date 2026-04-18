# Research Report: Task #93 - Round 42

**Task**: Complete BXCanonical embedding
**Date**: 2026-04-18
**Mode**: Team Research (4 teammates)
**Session**: sess_1776550087_66daf7
**Focus**: Investigate whether pivoting from oracle-based qm_bfmcs to dd_bfmcs scheduling chain is correct

## Summary

All four teammates independently confirmed that the pivot from qm_bfmcs to dd_bfmcs is **operationally correct**: the three live sorry sites are on `dd_bfmcs`, not `qm_bfmcs`, and closing them is the shortest path to a sorry-free `bx_completeness`. However, the Critic (Teammate C) raised an important nuance: the oracle infrastructure is better characterized as **"unfinished replacement code"** than "dead code" — it was built today as Plan v40's deliverable and abandoned when it hit an irresolvable mathematical barrier (semantically invalid backward step transfer). This distinction matters for archival labeling and for understanding which mathematical insights remain usable.

The team converged on a clear three-fix strategy for the dd_bfmcs path, with high confidence (75-90%) on each fix.

## Key Findings

### 1. Live Proof Path Confirmation (Teammate A, DEFINITIVE confidence)

The live proof path, traced directly from code:

```
bx_completeness (Completeness.lean:123)
  → dd_countermodel (RootScopedChain.lean:967)
    → dd_bfmcs (line 977) using fwd_chain_of_sigma / bwd_chain_of_sigma
      → dd_bfmcs_restricted_tc  (line 953)  ← SORRY
      → dd_bfmcs_restricted_buc (line 958)  ← SORRY
      → dd_bfmcs_restricted_fuc (line 963)  ← SORRY
```

`qm_bfmcs` appears only at lines 1746-1961, never referenced from `dd_countermodel`. Grep of entire BXCanonical/ directory confirms zero external callers. The Boneyard note about "sorry targets will be proved via the quasimodel bridge" means the *proofs* of dd_bfmcs_restricted_* may use quasimodel infrastructure, NOT that qm_bfmcs replaces dd_bfmcs in dd_countermodel.

### 2. "Dead Code" vs "Unfinished Replacement" (Teammate C, HIGH confidence)

Report 41 was **misleading** in calling the oracle infrastructure "dead code." Git history shows:

- Commit `8d9222423` (today): Created OracleStep.lean as Plan v40 wave 2
- Commit `1a890352a` (today): Added qm_bfmcs as Plan v40 wave 3 — mathematical obstruction discovered here
- The dd_countermodel wiring was intentionally not changed because the coherence proofs were incomplete

The oracle infrastructure is an **unfinished replacement that hit a mathematical wall** at `qm_bfmcs_restricted_buc` (backward step transfer is semantically invalid). This is fundamentally different from legacy dead code.

**Practical implication**: Archive with accurate label. Do NOT delete `qm_oracle_step`, `qm_oracle_step_bwd`, or `hintikka_step_for_sigma_sig` — these are reusable building blocks, especially if the enriched backward seed approach is needed for `dd_bfmcs_restricted_buc`.

### 3. Oracle Approach Cannot Replace dd_bfmcs (Teammate B, HIGH confidence)

Even if completed, qm_bfmcs has more obstacles than dd_bfmcs:

| Criterion | qm_bfmcs (oracle) | dd_bfmcs (scheduling) |
|-----------|-------------------|----------------------|
| On active proof path | NO | YES |
| Sorry count | 9+ | 3 |
| Fundamental blockers | 2 (defect decrease + bwd Until) | 1-2 (tc + buc) |
| Rewiring needed | YES | NO |
| Lindenbaum non-determinism impact | HIGH (blocks restricted_tc) | LOW (F-persistence avoids it) |

The defect-count decrease sorry (OracleStep.lean:452) is NOT directly closeable due to Lindenbaum non-determinism. The enhanced seed achieves defect monotonicity but not strict decrease for the target defect.

### 4. Literature Alignment (Teammate D, HIGH confidence)

Both approaches have literature precedents:
- **dd_bfmcs scheduling** maps to Reynolds (2003) constructive completeness via explicit defect scheduling
- **qm_bfmcs oracle** maps to Goldblatt (1992) quasimodel construction

The standard literature avoids Lindenbaum non-determinism by working with finite Hintikka points (subsets of Sigma), not full MCS. The BXCanonical codebase's use of full MCS projected to Sigma via `sigma_signature` is the non-standard move creating the defect-count problem.

### 5. F-Persistence is Confirmed (All teammates, VERY HIGH confidence)

`defect_fwd_step_choice_spec` at lines 1472-1481 explicitly guarantees:
```
∀ χ, χ ∈ defects → F(χ) ∈ M'
```
This is genuine F-persistence for the full defects list. Combined with schedule surjectivity, this gives eventual F-resolution — the basis for closing restricted_tc.

### 6. Three-Fix Strategy for dd_bfmcs (All teammates converge)

**Fix 1: restricted_tc** via Reynolds' induction on `defects.length`
- Base case (`defect_fwd_step_choice_singleton`) already proved
- Inductive case: use F-persistence to show F(χ) persists until χ is scheduled
- ~150-200 LOC, 75% confidence

**Fix 2: restricted_buc** via enriched backward oracle seed
- Modify backward seed: `h_content(w) ∪ {Since-defects} ∪ {φ U ψ | φ U ψ ∈ w, φ U ψ ∈ Sigma}`
- Consistency: trivial (subset of w.formulas)
- Backward Until step transfer holds BY CONSTRUCTION
- ~80-100 LOC, 85% confidence

**Fix 3: restricted_fuc** given restricted_tc + BX9 + qm_fwd_chain_until_persists
- Guard argument at intermediate points from Until-persistence + BX9
- ~50-80 LOC, 90% confidence

## Synthesis

### Conflicts Resolved

**Conflict 1**: Teammate A says "dead code" definitively. Teammate C says "unfinished replacement, misleading framing."

**Resolution**: Both agree on the facts (qm_bfmcs not on live path). The disagreement is about labeling. Teammate C's nuance is analytically important: archive with label "unfinished oracle replacement, abandoned at backward coherence obstruction" — not simply "dead code." The practical target (dd_bfmcs) is unchanged.

**Conflict 2**: Whether restricted_buc for dd_bfmcs requires modifying the backward chain or can be proved directly.

**Resolution**: Teammate D identifies that the current dd_bfmcs backward chain does NOT carry Until-formulas in its seed, so the backward step transfer is not automatic. The enriched backward seed fix requires modifying `bwd_pred` or `qm_oracle_seed_bwd` to include Until-formulas. This is essentially adopting the oracle approach's backward seed within the scheduling chain framework — confirming the oracle infrastructure has value as mathematical inspiration even if not wired in directly.

**Conflict 3**: Whether the defect-count decrease sorry could be closed to complete the oracle approach.

**Resolution**: Teammate B shows enhanced seed achieves defect monotonicity but NOT strict decrease. Teammate D confirms: with SubformulaClosure-based Sigma, the ψ ∈ Sigma branch fires (line 448) when ψ ∈ oracle_step, but the sorry at line 452 is genuinely needed when ψ ∉ oracle_step. Lindenbaum non-determinism prevents forcing ψ into the extension. Verdict: defect-count decrease is a genuine obstacle for the oracle approach.

### Gaps Remaining

1. **How exactly does restricted_buc connect to the dd_bfmcs backward chain?** The backward chain uses `bwd_chain_of_sigma` → `bwd_pred`. Does `bwd_pred` use the same oracle seed as `qm_oracle_step_bwd`? Or is it a different construction? The enriched backward seed fix needs to be applied to the ACTUAL backward chain used by dd_bfmcs, not just the qm_bfmcs backward chain.

2. **Reynolds' induction proof for multi-defect scheduling**: The base case exists (`defect_fwd_step_choice_singleton`), but the inductive step at `defect_fwd_chain_forward_F` (line 2196) is sorry'd. The proof strategy is clear (use F-persistence + IH) but the formal execution hasn't been attempted.

3. **Does the enriched backward seed affect G-content properties?** Adding Until-formulas to the backward seed should not break h_content duality, but this needs verification.

### Recommendations

**1. Proceed with Plan v41's target (dd_bfmcs)** — all four teammates agree this is correct.

**2. Revise Plan v41 Phase 1 archival language**: Change "dead code" to "unfinished oracle replacement, abandoned at backward coherence obstruction." Preserve `qm_oracle_step`, `qm_oracle_step_bwd`, and `hintikka_step_for_sigma_sig` as reusable infrastructure.

**3. Clarify the restricted_buc fix path**: Plan v41 needs to specify exactly how the enriched backward seed connects to `bwd_pred` in the dd_bfmcs backward chain. This may require reading `bwd_pred` carefully to determine whether it already uses `qm_oracle_seed_bwd` or a different seed.

**4. Key decision for Plan v41**: Whether to modify the existing `bwd_pred`/`bwd_chain_of_sigma` to use the enriched seed (minimal change, risk of breaking existing proofs) or to build a separate enriched backward chain and wire it into dd_bfmcs (more work but cleaner separation).

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Discovery |
|----------|-------|--------|------------|---------------|
| A | Live path tracing | completed | definitive (>99%) | dd_bfmcs is live, qm_bfmcs confirmed dead; Boneyard note clarification |
| B | Oracle viability | completed | high (85%) | Oracle has 9+ sorries vs 3; defect-count decrease not closeable; enriched seed transfers to dd_bfmcs |
| C | Critic | completed | high (90%) | "Unfinished replacement" not "dead code"; enriched backward seed could theoretically complete oracle; accurate archival label needed |
| D | Literature alignment | completed | high (85%) | Reynolds' induction for restricted_tc; F-persistence confirmed; Lindenbaum non-determinism is red herring for active path |

## Dead Ends Confirmed (Cumulative from Round 41)

- All 21+ approaches from Report 17: CONFIRMED DEAD
- Direct backward step transfer `φ ∧ F(φ U ψ) → φ U ψ`: SEMANTICALLY INVALID (all teammates)
- Defect-count decrease for general oracle: BLOCKED BY LINDENBAUM NON-DETERMINISM (Teammates B, D)
- Rewiring dd_countermodel to use qm_bfmcs: NOT RECOMMENDED (more sorries, more risk)

## References

- Teammate A: `specs/093_complete_bxcanonical_embedding/reports/42_teammate-a-findings.md`
- Teammate B: `specs/093_complete_bxcanonical_embedding/reports/42_teammate-b-findings.md`
- Teammate C: `specs/093_complete_bxcanonical_embedding/reports/42_teammate-c-findings.md`
- Teammate D: `specs/093_complete_bxcanonical_embedding/reports/42_teammate-d-findings.md`
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes No. 7.
- Burgess, J.P. (1984). Basic tense logic. *Handbook of Philosophical Logic*, Vol. II.
- Reynolds, M. (2003). Until and Since over Linear Orders. *Journal of Logic and Computation*, 13(4).
