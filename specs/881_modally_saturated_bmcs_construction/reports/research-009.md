# Research Report: Task #881 (Team Research v5)

**Task**: Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
**Date**: 2026-02-14
**Mode**: Team Research (2 teammates)
**Session**: sess_1771028987_1b44a1
**Focus**: Alternative approaches after DovetailingChain's two-chain architecture limitation

## Summary

After discovering that DovetailingChain's two-chain architecture fundamentally cannot prove cross-sign G/H propagation, this team research investigated two alternative approaches: **UnifiedChain** and **RecursiveSeed**.

**Key Conclusion**: **RecursiveSeed is the recommended path forward** - it's already sorry-free, avoids cross-sign by design, and needs extension (not fundamental fixes) for modal saturation. UnifiedChain architecturally supports cross-sign but introduces a new blocker (combined seed consistency) with 7 sorries.

## Key Findings

### Finding 1: DovetailingChain is Fundamentally Blocked (Confirmed)

The two-chain architecture separates GContent (forward chain) and HContent (backward chain) with no cross-chain mechanism. G formulas from backward chain cannot reach forward chain. This is an architecture limitation, not a missing proof.

### Finding 2: UnifiedChain Addresses Cross-Sign But Introduces New Blocker

**Architecture**: UnifiedChain combines GContent and HContent in each seed:
```lean
def unifiedSeed (constructed) (n) : Set Formula :=
  unifiedGContentPart constructed n ∪ unifiedHContentPart constructed n
```

**Problem**: Has 7 sorries (vs DovetailingChain's 4). The critical new blocker is **seed consistency** (line 227) - proving that `GContent(M₋ₖ) ∪ HContent(M_{k'})` is consistent when M₋ₖ and M_{k'} are different MCSs built at different construction steps.

**Assessment**: Shifts the blocker from "cross-sign impossible" to "combined seed consistency unproven" - potentially more tractable but still unsolved.

### Finding 3: RecursiveSeed is Sorry-Free and Avoids Cross-Sign by Design

**Architecture**: Pre-places ALL temporal witnesses BEFORE Lindenbaum extension:
- `buildSeedAux` recursively processes formulas
- G φ propagates to ALL future times at construction time
- H φ propagates to ALL past times at construction time
- F/P witnesses pre-placed as new time entries

**Sorry Status**: 0 sorries, 0 axioms (completed in task 880)

**Key Insight**: By placing witnesses before Lindenbaum, there's no need for cross-sign derivation during MCS extension.

### Finding 4: Gap Between RecursiveSeed and Modal Saturation

**What RecursiveSeed provides**: Single-formula temporal coherence via `ModelSeed`

**What modal saturation requires**:
1. Witness families for ALL `¬□φ` formulas in an MCS
2. Each witness family as `IndexedMCSFamily` with temporal coherence
3. `box_coherence` across all families
4. Saturation closure (witnesses for witnesses)

**The bridge needed**: Extend RecursiveSeed from formula-level to MCS-level construction.

## Conflicts Resolved

### Conflict: Which approach has better tractability?

**Teammate A**: UnifiedChain architecturally supports cross-sign (medium confidence)
**Teammate B**: RecursiveSeed avoids the problem entirely (high confidence)

**Resolution**: RecursiveSeed is more tractable because:
1. Already sorry-free (vs 7 sorries in UnifiedChain)
2. Avoids the problem by design (vs shifting the problem)
3. Has proven infrastructure from task 880
4. Extension to MCS-level is additive work, not fixing blockers

## Gaps Identified

1. **RecursiveSeed → IndexedMCSFamily bridge**: No existing infrastructure to convert `ModelSeed` entries to `IndexedMCSFamily`

2. **Multi-formula seed consistency**: RecursiveSeed handles single formulas; need to prove consistency when building seeds for entire MCS content

3. **F/P witness enumeration**: Still unsolved in both approaches; needs dovetailing over (time, formula) pairs

## Recommendations

### Primary Path: Extend RecursiveSeed for Modal Saturation

**Phase 1**: Build seed for evaluation MCS content
- Process ALL formulas in eval MCS (not just one formula)
- Pre-place witnesses for ALL `¬□φ` formulas
- Prove mutual consistency of seed entries

**Phase 2**: Bridge to IndexedMCSFamily
- Apply Lindenbaum to each (family, time) entry
- Combine into IndexedMCSFamily structure
- Prove temporal coherence properties from seed pre-placement

**Phase 3**: Iterate for saturation closure
- Process Diamond formulas in witness families
- Build additional witness seeds
- Prove box_coherence is maintained

**Rationale**: This builds on sorry-free infrastructure rather than fixing blocked proofs.

### Alternative Path: Fix UnifiedChain Seed Consistency

If RecursiveSeed extension proves too complex:

1. Prove `unified_seed_derives_from_base`: All seed formulas trace to common base
2. Use shared base M_0 to prove GContent + HContent consistency
3. Complete the 7 sorries

**Assessment**: Higher risk - the seed consistency proof is a novel argument.

### Not Recommended: DovetailingChain Cross-Sign Lemmas

Adding cross-sign infrastructure to DovetailingChain is not recommended because:
- Requires fundamental architecture change
- Would essentially recreate UnifiedChain's approach
- Better to use UnifiedChain directly if that path is chosen

## Sorry Debt Analysis

| Approach | Sorries | Axioms | Assessment |
|----------|---------|--------|------------|
| DovetailingChain | 4 | 0 | BLOCKED (architecture) |
| UnifiedChain | 7 | 0 | Shifts blocker |
| RecursiveSeed | 0 | 0 | Extension needed |
| ZornFamily | 0 | 0 | Ready to use |

**Critical path for task 881**:
- RecursiveSeed + ZornFamily are sorry-free
- Need: RecursiveSeed → IndexedMCSFamily bridge
- Need: Multi-formula seed construction
- Need: F/P witness enumeration

## Teammate Contributions

| Teammate | Angle | Key Contribution | Confidence |
|----------|-------|------------------|------------|
| A | UnifiedChain analysis | Detailed sorry inventory, seed consistency blocker analysis, architectural comparison | Medium |
| B | RecursiveSeed analysis | Sorry-free confirmation, cross-sign avoidance mechanism, modal saturation gap identification | High |

## References

### Teammate Reports
- `specs/881_modally_saturated_bmcs_construction/reports/teammate-a-v5-findings.md`
- `specs/881_modally_saturated_bmcs_construction/reports/teammate-b-v5-findings.md`

### Key Code Files
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Sorry-free (task 880)
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - Sorry-free
- `Theories/Bimodal/Metalogic/Bundle/UnifiedChain.lean` - 7 sorries
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - 4 sorries (BLOCKED)

### Prior Research
- research-007.md: Constant families analysis, zero-compromise path
- research-008.md: Semantic alignment confirmation
- Task 880 summary: RecursiveSeed completion

## Conclusion

**RecursiveSeed is the recommended path for task 881**. It provides sorry-free infrastructure that avoids the cross-sign problem by design. The work needed is **extension** (building MCS-level construction on top of formula-level) rather than **fixing blockers** (resolving fundamental architectural issues).

The plan v4 should:
1. Use RecursiveSeed's pre-placement pattern for modal witness construction
2. Build on ZornFamily's sorry-free temporal coherence
3. Create a bridge from `ModelSeed` to `IndexedMCSFamily`
4. Implement F/P witness enumeration via dovetailing

**Expected outcome**: A path to eliminate `fully_saturated_bmcs_exists_int` sorry using proven infrastructure.
