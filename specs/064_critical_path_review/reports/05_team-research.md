# Research Report: Task #64 — Root Cause Analysis of Task 58 Failures

**Task**: Critical path review: algebraic analysis of completeness obstacles
**Date**: 2026-03-25
**Mode**: Team Research (3 teammates)
**Session**: sess_1774461365_0e8fc2

## Summary

Three teammates analyzed why task 58 has failed multiple strategies to eliminate 3 sorries in the completeness theorems. The team converged on a unified diagnosis and a concrete path forward with a critical prerequisite verification step.

**Root cause**: All failed strategies share one fundamental obstacle — transitioning from "existence of a witness MCS" (provable, sorry-free) to "the constructed chain itself provides witnesses" (what temporal coherence requires). This manifests differently in each strategy but has the same mathematical origin: TM logic has unboundedly deep temporal obligations for arbitrary MCSes, and only the restriction to `deferralClosure(phi)` provides the finiteness needed for constructive chain building.

**Recommended approach**: FMCS-first architecture — build a single temporally coherent FMCS directly from restricted chains, then wrap in a singleton BFMCS. Completely abandon `boundary_resolution_set` and `boxClassFamilies_temporally_coherent`.

**Critical prerequisite**: Verify `#print axioms restricted_forward_chain_forward_F` — if sorry-free, the path is mechanical (~750 LOC, 6-10 hours). If it depends on sorries, pivot to Alternative A (fresh direct MCS chain, harder math).

## Key Findings

### 1. The Within-Family Coherence Gap (Teammate A)

All three failed strategies reduce to one mathematical fact: **there is no deterministic, well-founded procedure for constructing a within-chain temporal successor for an arbitrary MCS**.

- `temporal_theory_witness_exists` is sorry-free: F(phi) in M implies some W exists with phi in W and R_G(M,W)
- But this W is existentially quantified over ALL MCSes — it's not in any particular chain
- `boxClassFamilies_temporally_coherent` needs the witness IN the same chain

This gap appears in every strategy:
- **Strategy C**: seed consistency fails (can't prove chain's next element contains needed witnesses)
- **Strategy A**: MCS-level witnesses don't land in the right chain
- **Restricted chain**: construction is correct but termination argument fails locally

### 2. Why `f_nesting_is_bounded` Is False (Teammate A)

Counterexample: {F^n(p) | n in N} is finitely consistent, extends by Lindenbaum to an MCS with unbounded F-nesting. This reveals TM logic can commit worlds to infinitely many simultaneous temporal obligations — no finite local procedure can discharge them all.

**The fix**: `deferralClosure(phi)` IS finite, so within it F-nesting IS bounded (proven sorry-free by `f_nesting_is_bounded_restricted`). This is the correct structural restriction.

### 3. The `boundary_resolution_set` Is a Dead End (Teammates A, C)

`neg_not_in_boundary_resolution_set` is genuinely unprovable: both F(chi) and F(chi.neg) can coexist in a consistent MCS (since G(chi) and G(neg chi) can both be absent). The entire `boundary_resolution_set` / `constrained_successor_seed_restricted` apparatus is fundamentally broken.

### 4. The Sorry-Free Infrastructure Is Nearly Complete (Teammate B)

| Component | Status |
|-----------|--------|
| `parametric_algebraic_representation_conditional` | Sorry-free |
| `parametric_shifted_truth_lemma` | Sorry-free (needs h_tc) |
| `boxClassFamilies_modal_forward/backward` | Sorry-free |
| `temporal_theory_witness_exists` | Sorry-free |
| `past_theory_witness_exists` | Sorry-free |
| `restricted_forward_chain_forward_F` | **Asserted** sorry-free — **MUST VERIFY** |
| `f_nesting_is_bounded_restricted` | Sorry-free |
| `p_nesting_is_bounded_restricted` | Sorry-free |

**The only gap is temporal coherence** — specifically proving `B.temporally_coherent` which requires both `forward_F` and `backward_P` for every family in the bundle.

### 5. Exactly 4 Sorries Block Completeness (Teammate B)

| Sorry | Location | Status |
|-------|----------|--------|
| `neg_not_in_boundary_resolution_set` | SuccChainFMCS.lean:1435 | **Unprovable** — abandon |
| `augmented_seed_consistent` | SuccChainFMCS.lean:1480 | Depends on above — abandon |
| `constrained_successor_seed_restricted_consistent` | SuccChainFMCS.lean:1543 | Depends on above — abandon |
| `restricted_bounded_witness` termination | SuccChainFMCS.lean:2405 | May or may not affect forward chain |

### 6. FMCS-First Architecture (Teammate C)

**Core insight**: Don't build BFMCS first and hope temporal coherence falls out. Instead build a single temporally coherent FMCS directly, then wrap in a singleton BFMCS.

The singleton BFMCS is trivially modally coherent (one family, no inter-family relations to check) and temporally coherent by construction (restricted chain forward_F + backward_P).

## Synthesis

### Conflicts Resolved

**Conflict 1: Is `restricted_forward_chain_forward_F` sorry-free?**
- Teammate A: implies it may have sorry through termination
- Teammate B: notes the call chain through `restricted_bounded_witness` (which has sorry)
- Teammate C: proposes verifying with `#print axioms`
- **Resolution**: This is the CRITICAL PREREQUISITE. All three agree it must be verified before proceeding. The answer determines which path to take.

**Conflict 2: Fix restricted chain termination vs. build backward chain?**
- Teammate A: recommends fixing `restricted_bounded_witness` termination with global fuel measure
- Teammate C: recommends using the existing forward chain as-is and building a symmetric backward chain
- **Resolution**: These are complementary, not conflicting. If `restricted_forward_chain_forward_F` is sorry-free, build the backward chain (Teammate C). If it depends on the termination sorry, fix the termination first (Teammate A), THEN build the backward chain.

### Gaps Identified

1. **Backward chain construction missing entirely**: No `restricted_backward_chain` or `restricted_backward_chain_backward_P` exists. Must be built (~200 LOC each).
2. **Dovetailing infrastructure missing**: No Int-indexed join of forward and backward chains.
3. **Singleton BFMCS wrapper missing**: Trivial but must be implemented.
4. **DeferralRestrictedMCS → full MCS conversion**: May need care when wrapping restricted chain elements into FMCS structure.

### Recommendations

**Phase 0 (IMMEDIATE — 15 minutes)**:
Verify `#print axioms restricted_forward_chain_forward_F`. This determines the entire path.

**If sorry-free → Path A (6-10 hours, ~750 LOC)**:
1. Build `restricted_backward_chain` symmetric to forward chain (~200 LOC)
2. Prove `restricted_backward_chain_backward_P` (~200 LOC)
3. Dovetail forward + backward into Int-indexed FMCS (~100 LOC)
4. Build singleton BFMCS + prove temporal coherence (~150 LOC)
5. Wire to `parametric_algebraic_representation_conditional` (~100 LOC)

**If has sorries → Path B (10-15 hours)**:
1. Fix `restricted_bounded_witness` termination with global fuel/lexicographic measure (3-5 hours)
2. Then proceed with Path A steps 1-5

**If both blocked → Path C (15-20 hours, higher risk)**:
1. Build fresh direct MCS Int-chain from `temporal_theory_witness_exists` + `past_theory_witness_exists`
2. Prove union seed consistency (new mathematical work)
3. Build temporally coherent FMCS by construction
4. Wire to completeness

**In ALL paths**: Completely abandon `boundary_resolution_set`, `constrained_successor_seed_restricted`, `neg_not_in_boundary_resolution_set`, and `boxClassFamilies_temporally_coherent`. These are confirmed dead ends.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical root cause analysis | completed | HIGH on diagnosis, MEDIUM on fix |
| B | Sorry-free infrastructure survey | completed | HIGH |
| C | New approach design | completed | MEDIUM-HIGH |

## Key Architectural Shift

**Old approach (all failed strategies)**:
```
MCS → boxClassFamilies → SuccChainFMCS → BFMCS → temporal coherence (BLOCKED)
```

**New approach (FMCS-first)**:
```
MCS → DeferralRestrictedMCS → restricted_forward_chain + restricted_backward_chain
    → Int-indexed FMCS → singleton BFMCS → temporal coherence (BY CONSTRUCTION)
    → parametric_algebraic_representation_conditional → completeness
```

## References

### Teammate Reports
- `specs/064_critical_path_review/reports/05_teammate-a-findings.md` — Root cause analysis
- `specs/064_critical_path_review/reports/05_teammate-b-findings.md` — Infrastructure survey
- `specs/064_critical_path_review/reports/05_teammate-c-findings.md` — New approach design

### Prior Research
- `specs/058_wire_completeness_to_frame_conditions/reports/01-06` — Task 58 research reports
- `specs/058_wire_completeness_to_frame_conditions/handoffs/01_phase1-analysis-handoff.md` — Phase 1 block analysis
- `specs/064_critical_path_review/reports/01-02` — Prior task 64 research

### Key Source Files
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — Restricted chain infrastructure + 4 sorries
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — F/P witnesses, boxClassFamilies
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` — Completeness conditional
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` — Truth lemma (needs h_tc)
