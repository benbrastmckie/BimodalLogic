# Research Report: Task #916 (Team Research v3)

**Task**: Implement F/P witness obligation tracking to close DovetailingChain sorries
**Date**: 2026-02-20
**Mode**: Team Research (3 teammates)
**Session**: sess_1771632343_b3dd65

## Executive Summary

After exhaustive analysis by three specialized research agents examining approaches A-D plus novel alternatives, this report identifies a **consensus recommendation**:

**Approach D (Augmented Dovetailing Chain)** with an **omega-squared inner construction** at each time step is the most mathematically elegant and viable path forward. This aligns with the standard textbook technique for temporal logic completeness (Goldblatt 1992, Blackburn et al. 2001).

**Critical Discovery**: The fundamental obstacle across ALL approaches is that `F(psi) -> G(F(psi))` is NOT derivable in TM logic, meaning F-formulas do not self-persist through the chain. This explains why the plan v002 inner-chain approach failed.

**Estimated Effort**: 33-58 hours (medium-high complexity)

---

## Key Findings Summary

### Approaches Ruled Out

| Approach | Status | Fatal Blocker |
|----------|--------|---------------|
| **A**: Constructive Lindenbaum | NOT VIABLE | Boneyard already has 4-5 sorries from TCS/MCS incompatibility |
| **B**: Canonical Model + Unraveling | NOT VIABLE | 20-30h of work that duplicates existing infrastructure; unraveling IS the enriched chain |
| **C**: Dependent Choice + Priority Queue | NOT VIABLE | F-formula death at witness steps is unsolvable by priority queue alone |
| **G**: Indirect/Contradiction Argument | NOT VIABLE | No omega-rule in TM logic prevents the backward derivation |

### The Viable Path: Augmented Dovetailing (D + Omega^2)

**Core Architecture**:
1. At each time `t`, build an inner chain of MCSes: M_t^(0), M_t^(1), M_t^(2), ...
2. Each inner step adds ONE F-witness using `{psi_k} ∪ GContent(M_t^(k))` as seed
3. Consistency follows from `temporal_witness_seed_consistent`
4. Final M_t is the limit (via Zorn on the directed system)

**Why This Works**:
- Places witnesses in the seed (the ONLY way to control what enters an MCS)
- Uses the IMMEDIATE predecessor's F-formulas (satisfies `temporal_witness_seed_consistent` precondition)
- Processes ALL F-formulas via enumeration dovetailing
- Reuses 600+ lines of proven cross-sign G/H propagation

---

## Synthesis of Teammate Findings

### Teammate A: Approaches A and D Analysis

**Approach A (Constructive Lindenbaum)**:
- Boneyard file `TemporalLindenbaum.lean` (1147 lines) has 4 sorries in `maximal_tcs_is_mcs`
- Root cause: "Temporal Saturation / Maximality Incompatibility" - for temporal formulas, Zorn-maximal in TCS does NOT imply MCS
- Formula ordering does NOT help - it addresses single-MCS properties, not cross-time chain requirements
- **Verdict**: NOT VIABLE. The obstruction is mathematical, not engineering.

**Approach D (Two-Step Splice)**:
- Pure splice fails due to "single fixed function" constraint in BFMCS structure
- Enriched seed approach partially viable but has F-persistence gap
- **Recommended variant**: Omega-squared inner chain (Approach E')

### Teammate B: Approaches B, C, and Alternatives

**Approach B (Canonical Model + Unraveling)**:
- Unraveling the canonical model into a linear chain faces the SAME challenge as direct construction
- Would require 1500-2500 lines of new code with massive architectural disruption
- **Verdict**: NOT RECOMMENDED. Effort is essentially a complete rewrite.

**Approach C (Dependent Choice + Priority Queue)**:
- Three specific failure modes identified:
  1. F-formula persistence not guaranteed through non-augmented steps
  2. Witnessing from non-immediate predecessors lacks consistency proof
  3. Once `G(neg chi)` enters, it propagates forever - cannot "re-establish" killed F-formulas
- **Verdict**: FAILS as stated. Core idea can be salvaged by restricting to immediate predecessors.

**Novel Alternatives**:
- Approach E (Enriched Recursive Chain): Viable but requires omega^2 inner construction
- Approach G (Indirect argument): FAILS - no omega-rule in TM logic

### Teammate C: Risk Analysis and Recommendation

**Risk Assessment Table**:

| Approach | Overall Risk | Key Vulnerability |
|----------|-------------|-------------------|
| A | VERY HIGH | Boneyard has failed 1000+ line attempt |
| B | VERY HIGH | Complete architecture rewrite |
| C | HIGH | F-formula death unsolvable by priority queue |
| D | MEDIUM | Coverage argument is main challenge |

**Mathematical Elegance Ranking**: D > A > C > B

**Critical Insight**: `F(psi) -> G(F(psi))` is NOT derivable in TM/S4_t logic. This means F-formulas do NOT self-persist. This explains why all approaches face the persistence problem.

**Textbook Alignment**: Approach D matches the standard technique in:
- Goldblatt, "Logics of Time and Computation" (1992)
- Blackburn, de Rijke, Venema, "Modal Logic" (2001)

---

## Conflicts Resolved

### Conflict 1: Approach Naming
- Teammate A calls it "Approach E' (omega-squared enriched chain)"
- Teammate C calls it "Approach D with omega^2 construction"
- **Resolution**: These are the same approach. Standardized as "Augmented Dovetailing with Omega^2 Inner Construction"

### Conflict 2: Effort Estimates
- Teammate A: 25-35 hours
- Teammate C: 33-58 hours
- **Resolution**: Adopt conservative estimate of 33-58 hours. The coverage argument complexity justifies the higher bound.

### Conflict 3: Approach D Pure vs. Augmented
- Pure Approach D (simple splice) is NOT viable
- Approach D with omega^2 inner construction IS viable
- **Resolution**: Recommend the augmented variant explicitly

---

## The Fundamental Obstacle (Unanimous)

All three teammates independently identified the same core issue:

> **Zorn-based Lindenbaum (`set_lindenbaum`) is an opaque existence proof.** Given a consistent seed, it produces SOME MCS extending it. There is NO control over which formulas beyond the seed enter the MCS.

The ONLY way to guarantee a formula enters an MCS is to place it in the seed. The ONLY proven consistency result for temporal seeds is `temporal_witness_seed_consistent`:
- Requires: `F(psi) ∈ M` (immediate predecessor)
- Provides: `{psi} ∪ GContent(M)` is consistent

This lemma is the mathematical foundation for any viable approach.

---

## Recommended Implementation Architecture

### Phase 1: Define Omega^2 Chain Structure (10-15h)

```lean
-- Inner chain at each time point
noncomputable def innerChainMCS (base : Set Formula) (h_cons : SetConsistent base)
    (t : Int) (k : Nat) : { M : Set Formula // SetMaximalConsistent M }
  | 0 => Lindenbaum(GContent(outerChain (t-1)))
  | k+1 =>
    let prev := innerChainMCS base h_cons t k
    let psi_k := Encodable.decode k
    if F(psi_k) ∈ prev.val
    then Lindenbaum({psi_k} ∪ GContent(prev.val))
    else prev

-- Outer chain takes limit at each time
noncomputable def outerChain (base : Set Formula) (h_cons : SetConsistent base)
    (t : Int) : { M : Set Formula // SetMaximalConsistent M } :=
  LimitMCS(innerChainMCS base h_cons t)
```

### Phase 2: Prove Inner Chain Properties (8-12h)
- `innerChain_consistent`: Each inner MCS is consistent
- `innerChain_witness_in`: Witnessed formula enters the MCS
- `innerChain_F_persists`: F(psi) persists when psi is witnessed (key lemma)

### Phase 3: Prove Coverage Argument (10-18h)
- For any `F(psi) ∈ M_t`, show psi eventually enters some M_s with s > t
- Uses: enumeration surjectivity + immediate predecessor witnessing

### Phase 4: Integrate with BFMCS (5-8h)
- Adapt `buildDovetailingChainFamily` to use new construction
- Verify downstream theorems still compile

### Phase 5: Backward_P (Symmetric) (3-5h)
- Mirror all forward constructions for past direction
- Uses `past_temporal_witness_seed_consistent`

---

## Evidence (Verified Across Teammates)

### Proven Lemmas (Reusable)
| Lemma | File | Status |
|-------|------|--------|
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | PROVEN |
| `past_temporal_witness_seed_consistent` | DovetailingChain.lean | PROVEN |
| `dovetail_GContent_consistent` | DovetailingChain.lean | PROVEN |
| `GContent_subset_implies_HContent_reverse` | DovetailingChain.lean | PROVEN |
| `HContent_subset_implies_GContent_reverse` | DovetailingChain.lean | PROVEN |
| Cross-sign G/H propagation (600+ lines) | DovetailingChain.lean | PROVEN |

### Blocked Approaches (Boneyard Evidence)
| File | Sorries | Reason |
|------|---------|--------|
| `TemporalLindenbaum.lean` | 4-5 | TCS/MCS incompatibility |
| `CanonicalModel.lean` (v1 & v2) | Multiple | Truth lemma gaps |

### Mathlib Infrastructure Available
- `Nat.pairEquiv`: Bijection N ↔ N × N (for omega^2 indexing)
- `Encodable.ofCountable`: Formula enumeration
- `zorn_subset_nonempty`: Lindenbaum basis

---

## Risk Assessment (Consensus)

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Inner chain witness accumulation | MEDIUM | HIGH | F-persistence through GContent-based seeds is proven |
| Limit MCS construction | MEDIUM | MEDIUM | Use Zorn on directed system of inner MCSes |
| Coverage argument complexity | HIGH | HIGH | Use Encodable surjectivity + immediate predecessor check |
| Downstream theorem breakage | LOW | MEDIUM | Cross-sign proofs depend only on GContent extension |
| Context exhaustion during implementation | MEDIUM | LOW | Handoff-based continuation |

---

## Recommendations

### Primary Recommendation
**Implement Augmented Dovetailing with Omega^2 Inner Construction**

This approach is recommended because:
1. **Mathematically sound**: Directly uses `temporal_witness_seed_consistent`
2. **Textbook-aligned**: Matches Goldblatt and Blackburn et al.
3. **Maximum reuse**: 600+ lines of cross-sign proofs remain valid
4. **Minimal architecture disruption**: BFMCS interface unchanged
5. **Clear proof obligations**: Coverage via enumeration, not persistence

### Implementation Strategy
1. **Do NOT attempt** Approaches A, B, or C - all have fatal blockers
2. **Start with Phase 1** (inner chain definition) as a proof of concept
3. **Key milestone**: Prove `innerChain_F_persists` before proceeding
4. **Fallback**: If inner chain fails, consider reformulating the chain over ordinal indices

### Estimated Effort
- **Optimistic**: 33 hours
- **Realistic**: 45 hours
- **Pessimistic**: 58 hours

---

## Teammate Contributions

| Teammate | Focus | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | Approaches A & D | Completed | Identified TCS/MCS incompatibility in boneyard |
| B | Approaches B, C & alternatives | Completed | Ruled out canonical model, identified omega^2 necessity |
| C | Risk analysis & elegance | Completed | Proved F -> GF non-derivable, textbook alignment |

---

## Next Steps

1. Create implementation plan v003 using Augmented Dovetailing architecture
2. Phases should target the inner chain construction first (proof of concept)
3. Consider splitting into sub-tasks if effort exceeds 40 hours

---

## References

- Goldblatt, R. "Logics of Time and Computation" (1992) - Standard temporal completeness technique
- Blackburn, P., de Rijke, M., Venema, Y. "Modal Logic" (2001) - Canonical model and Henkin constructions
- `specs/916_implement_fp_witness_obligation_tracking/handoffs/phase-1-handoff-20260220.md` - Initial obstruction analysis
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-002.md` - Option A analysis
- Teammate findings:
  - `research-003-teammate-a-findings.md`
  - `research-003-teammate-b-findings.md`
  - `research-003-teammate-c-findings.md`
