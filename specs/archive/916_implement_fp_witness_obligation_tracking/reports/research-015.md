# Research Report: Task #916

**Task**: Implement F/P witness obligation tracking to close DovetailingChain sorries
**Date**: 2026-02-24
**Mode**: Team Research (3 teammates)
**Focus**: Implementation blocker analysis, witness-graph-guided chain resolution, documentation cleanup

## Summary

This team research investigated why implementations keep being diverted to linear chain constructions despite 14 prior research reports establishing this approach is mathematically impossible. The investigation identified: (1) the ONLY viable construction approach (omega-squared with immediate processing), (2) comprehensive documentation cleanup requirements that explain why agents are misled, and (3) a complete checklist of 24 improvements needed for proof-debt-free completion. The fundamental insight is that **F-formulas must be processed IMMEDIATELY when they appear**, not via enumeration-based scheduling, because any Lindenbaum extension can introduce G(neg(psi)) which kills F(psi) permanently.

## Key Finding: Why Linear Chains Always Fail

**Teammate A** performed an exhaustive analysis of 6+ design iterations, each failing for the same fundamental reason:

> For any chain-based construction where `chain(n+1)` is a Lindenbaum extension of a seed derived from `chain(n)`, forward_F is unprovable.

The mechanism:
1. F(psi) can be killed at any step by non-constructive Lindenbaum introducing G(neg psi)
2. F(psi) does not appear in GContent seeds (GContent = {phi : G(phi) in M})
3. Once G(neg psi) enters, it persists forever via the 4-axiom (G(phi) -> G(G(phi)))
4. The seed `{psi} union GContent(chain(n))` is only consistent when F(psi) is alive at step n

This rules out: enriched chain, constant family oracle, direct witness graph embedding, witness-graph-guided chain with gap fill, omega-squared directed limit.

## The ONLY Viable Construction: Omega-Squared with Immediate Processing

**Teammate A** identified the correct construction pattern:

**At each outer step n when F(psi) appears**:
1. Process F(psi) as the VERY FIRST inner operation, BEFORE any Lindenbaum extension
2. Use seed `{psi} union GContent(outer_MCS)` which IS consistent because F(psi) is still alive
3. This places psi in the first inner MCS immediately
4. forward_G follows from GContent monotonicity (4-axiom: G(phi) -> G(G(phi)))

**Why this works**: The FPreservingSeed counterexample (v005) used INFINITELY many formulas. Processing ONE F-obligation at a time with `{psi} union GContent(M)` is PROVEN consistent by `witnessSeed_consistent` (WitnessGraph.lean:544).

**Key missing infrastructure**:
| Lemma | Exists? | Effort |
|-------|---------|--------|
| GContent monotonicity | No | 2-4h (from 4-axiom) |
| GContent path propagation | No | 4-8h (induction) |
| Omega-squared construction | No | 12-20h |
| Omega-squared forward_F | No | 8-12h |

**Estimated total**: 24-48 hours for P0 items

## Why Agents Keep Trying Linear Chains

**Teammate B** identified **three reinforcing factors**:

### Factor 1: The Code Tells a Compelling But Incomplete Story

DovetailingChain.lean has ~500 lines of sorry-free infrastructure (lines 1380-1555) that builds logically:
1. `witnessForwardChain_F_dichotomy` -- at each step, F or G(neg) holds (correct)
2. `witnessForwardChain_F_persists_if_not_killed` -- if G(neg) absent, F survives (correct)
3. `witnessForwardChain_coverage_of_le` -- if F survives to step k, witness fires (correct)

An agent reads these and concludes: "The proof is 90% done." But **showing F isn't killed is PRECISELY what's impossible**.

### Factor 2: Module Doc Claims forward_F Is Part of the Design

Lines 38-46 of DovetailingChain.lean describe "F-witness formulas via dovetailing enumeration" as integral. Line 520 says this mechanism "enables the forward_F coverage argument." This implies the sorry is just a proof engineering gap.

### Factor 3: Stale References Create False Hope

TemporalCoherentConstruction.lean (lines 559-564) claims the construction satisfies forward_F "by dovetailing enumeration." RecursiveSeed references (lines 577-624) describe an approach moved to Boneyard. Agents believe multiple viable paths exist.

## Misleading Content Requiring Cleanup

**Teammate B** identified 12+ specific items (see teammate-b-findings.md for full table):

### Critical Misleaders
| File | Line | Problem |
|------|------|---------|
| DovetailingChain.lean | 518-520 | "This enables the forward_F coverage argument" -- FALSE |
| TemporalCoherentConstruction.lean | 559-564 | Claims construction satisfies forward_F -- NOT PROVEN |
| WitnessGraph.lean | 2534-2538 | "enabling Phase 5 to prove forward_F" -- PHASE 5 FAILED |

### Missing Warnings
1. **No "DO NOT TRY" list** at BFMCS definition site
2. **GContent stripping not documented** at GContent definition
3. **No warning at Lindenbaum extension** about opacity
4. **No consolidated "Blocked Approaches" document**

## Proof-Debt-Free Completion Requirements

**Teammate C** inventoried all proof debt and requirements:

### Current State
| Metric | Count |
|--------|-------|
| Direct sorries (DovetailingChain) | 2 |
| Transitive sorries | 3 |
| Axioms (non-Boneyard) | 2 (neither in Int completeness path) |
| WitnessGraph.lean sorries | 0 |

### Complete Improvement Checklist

**P0 - Core (24-48 hours)**:
- 1.1: Design omega-squared construction (8-12h)
- 1.2: Prove GContent monotonicity (2-4h)
- 1.3: Prove forward_F for omega-squared (8-12h)
- 1.4: Prove backward_P (symmetric, 4-6h)
- 1.5: Integrate into DovetailingChain (4-8h)

**P1 - Documentation (2-4 hours)**:
- Update DovetailingChain module docstring
- Add warnings at GContent definition
- Add "DO NOT TRY" list at BFMCS definition
- Create BLOCKED_APPROACHES.md

**P2 - Transitive Debt (optional, 20-40 additional hours)**:
- Eliminate `fully_saturated_bmcs_exists_int` sorry
- Eliminate `saturated_extension_exists` axiom

## Synthesis: Conflicts Resolved

### Conflict 1: Omega-squared vs Witness-graph-guided
- Teammate A explored both approaches extensively
- **Resolution**: Omega-squared with immediate processing is correct. The "witness-graph-guided" name is misleading because it suggests embedding witness graph nodes into Int, which fails forward_G. The correct approach builds a LINEAR chain but processes each F-obligation IMMEDIATELY.

### Conflict 2: Effort Estimates
- Teammate A: 25-40 hours
- Teammate C: 24-48 hours
- **Resolution**: 24-40 hours for P0 items (conservative middle ground)

## Recommendations for Implementation Plan v012

### Phase Structure
1. **Documentation Cleanup Phase** (2-4h): Fix misleading comments FIRST to prevent future confusion
2. **GContent Infrastructure Phase** (4-8h): Prove GContent monotonicity and path propagation
3. **Omega-Squared Construction Phase** (12-20h): Define and prove the new construction
4. **Integration Phase** (4-8h): Wire into DovetailingChain, remove old linear chain

### Critical Changes from v011
1. **Remove Phase 5B/5C as written** -- they describe linear chain approaches that don't work
2. **Replace Phase 6 wiring** -- cannot "wire" proofs that don't exist; must define new construction
3. **Add explicit "immediate processing" requirement** -- F-obligations processed BEFORE any Lindenbaum extension at that step

### Key Success Criteria
- [ ] DovetailingChain forward_F/backward_P: 0 sorries
- [ ] No new axioms introduced
- [ ] Misleading comments updated or removed
- [ ] "DO NOT TRY" list added to BFMCS.lean

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Witness-graph-guided chain design | completed | medium (60-70%) | Immediate processing avoids persistence problem |
| B | Documentation/comments cleanup | completed | high (>90%) | Code tells compelling but incomplete story |
| C | Proof-debt-free requirements | completed | medium (60-75%) | 24-48h P0, 52-104h full |

## References

- `specs/916_implement_fp_witness_obligation_tracking/reports/research-015-teammate-a-findings.md`
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-015-teammate-b-findings.md`
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-015-teammate-c-findings.md`
- `specs/916_implement_fp_witness_obligation_tracking/handoffs/phase-5B-handoff-20260224.md`
- `specs/916_implement_fp_witness_obligation_tracking/summaries/implementation-summary-20260224.md`
