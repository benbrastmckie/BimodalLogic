# Research Report: Task #41

**Task**: Eliminate D=CanonicalMCS pattern systematically
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)
**Focus**: Math

## Summary

The D=CanonicalMCS pattern is an intentional, sorry-free proof-theoretic technique that trivializes F/P witness obligations by making the temporal domain equal to all maximal consistent sets. Both teammates confirm this is mathematically valid but architecturally problematic when used as the semantic model for completeness. The codebase already contains the infrastructure for proper replacement: DovetailedTimelineQuot provides sorry-free forward_F and backward_P proofs, and FMCSTransfer enables domain transfer. D=Int is fundamentally blocked due to linear chain limitations.

## Key Findings

### Primary Approach (from Teammate A)

**The D=CanonicalMCS Architecture**:
- `CanonicalFMCS.lean` defines `canonicalMCSBFMCS : FMCS CanonicalMCS` with the identity mapping `mcs(w) = w.world`
- `temporal_coherent_family_exists_CanonicalMCS` is sorry-free because every Lindenbaum-produced witness MCS is automatically in the domain
- Pattern appears across 13+ files but is already marked as problematic in `MultiFamilyBFMCS.lean` ("DEAD END - W=D CONFLATION") and `FMCSDef.lean` ("Proof-Theoretic Special Case")

**Proper D Construction Already Exists**:
1. `DovetailedBuild` creates MCS points with Dovetail coverage
2. `DovetailedTimelineQuot` antisymmetrizes to get partial order
3. `dovetailedFMCS` gives FMCS with sorry-free G/H proofs
4. `FMCSTransfer.transferredFMCS` provides F/P for any D via embed/retract bijection

**Task 41 Scope Clarification**: Teammate A identified that the TODO.md description for task 41 may describe a more targeted cleanup (removing 3 axioms, dead code, and fixing docstrings) rather than the full architectural refactor suggested by the title. The axioms to remove are: `discrete_Icc_finite_axiom`, `discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom`.

### Alternative Approaches (from Teammate B)

**DovetailedTimelineQuot is the Correct D Type**:
- `dovetailedTimelineQuotFMCS_forward_F` (DovetailedTimelineQuot.lean:1315) - fully proven, no sorry
- `dovetailedTimelineQuotFMCS_backward_P` (DovetailedTimelineQuot.lean:1471) - fully proven, no sorry
- Staged construction places witnesses at `pair(point_index, encode(phi))`, guaranteeing phi appears at the right stage
- Has LinearOrder (via Cantor quotient construction) and a root element

**D=Int is Fundamentally Blocked**:
- `IntBFMCS.lean` documents the limitation: linear Lindenbaum chains can introduce `G(~phi)` at any step, killing `F(phi) = ~G(~phi)`
- 4 sorries remain in IntBFMCS.lean for F/P witnesses
- No fix is possible for any linear chain approach

**Why D=CanonicalMCS Was Adopted**:
- The `CanonicalReachable` approach (original plan v5) fails for `backward_P`: a backward witness W satisfies `h_content(w) ⊆ W`, but no TM axiom makes W future-reachable from M₀
- The all-MCS domain sidesteps this entirely
- This is the fundamental risk: complete elimination may re-introduce the backward_P blocker

**Dual-Domain Architecture**:
- `TimelineQuotBFMCS.lean` and `DovetailedTimelineQuotBFMCS.lean` already separate temporal domain (DovetailedTimelineQuot) from modal domain (CanonicalMCS)
- `dovetailedTimelineQuotBFMCS` (Phase 5) is built over DovetailedTimelineQuot but has a sorry in `modal_backward`
- Fix path: ClosedFlagBundle pattern (Phases 4.1-4.5)

## Synthesis

### Conflicts Resolved

**Scope of task 41** (Minor conflict):
- Teammate A notes the TODO.md description lists specific cleanup items (3 axioms, dead code, docstrings)
- The task title suggests systematic elimination of the D=CanonicalMCS pattern
- **Resolution**: The title captures the strategic goal; the TODO.md items are the tactical first steps. The implementation plan should address both: immediate cleanup AND the broader refactoring strategy.

**No other conflicts**: Both teammates independently reached the same conclusions about the mathematical approach.

### Gaps Identified

1. **modal_backward sorry**: The singleton BFMCS over DovetailedTimelineQuot has a sorry for `modal_backward`. The ClosedFlagBundle approach (Phases 4.1-4.5) may close it but the wiring is incomplete. (Medium confidence)
2. **Zero instance**: DovetailedTimelineQuot needs a `[Zero D]` instance for `TemporalCoherentFamily`. The root element exists but the instance may need wiring. (Medium confidence)
3. **Exact file impact**: While 13+ files are identified, the exact dependency analysis for which files need changes vs. which are already using proper D types needs detailed enumeration. (Medium confidence)
4. **discrete_representation_unconditional**: The 3 axioms targeted for removal depend on this being sorry-free. Current status needs verification. (Not assessed)

### Recommendations

Both teammates converge on a **staged separation strategy**:

1. **Keep `FMCS CanonicalMCS` for TruthLemma** - it is sorry-free, mathematically valid, and eliminates a genuine backward_P blocker. Do NOT delete `temporal_coherent_family_exists_CanonicalMCS`.

2. **Use `DovetailedTimelineQuot` as the proper D for the semantic model** - sorry-free forward_F and backward_P already proven. This is the correct replacement for completeness arguments.

3. **Bridge via `parametric_to_history`** (ParametricHistory.lean) which converts any `FMCS D` to a `WorldHistory`. Instantiate D=DovetailedTimelineQuot for the semantic completeness argument.

4. **Fix `modal_backward` sorry** in DovetailedTimelineQuotBFMCS using the ClosedFlagBundle pattern.

5. **Do NOT attempt D=Int** - the fundamental linear chain limitation (sorry-backed in IntBFMCS.lean) means this adds sorries rather than removing them.

6. **Remove dead code**: `MultiFamilyBFMCS.singletonCanonicalBFMCS` (marked DEAD END), `singleFamilyBFMCS`, `construct_bfmcs_from_mcs`.

7. **Remove 3 axioms** if `discrete_representation_unconditional` is sorry-free: `discrete_Icc_finite_axiom`, `discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom`.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary implementation approach | completed | high |
| B | Alternative patterns & prior art | completed | high |

## References

### Key Files
- `CanonicalFMCS.lean` - D=CanonicalMCS definition and sorry-free theorem
- `DovetailedFMCS.lean` - Proper FMCS over DovetailedTimelineQuot
- `DovetailedTimelineQuot.lean:1315,1471` - Sorry-free forward_F/backward_P
- `FMCSTransfer.lean:352-358` - Domain transfer mechanism
- `DovetailedTimelineQuotBFMCS.lean` - Dual-domain architecture with modal_backward sorry
- `MultiFamilyBFMCS.lean` - Marked DEAD END (W=D conflation)
- `IntBFMCS.lean` - D=Int fundamental limitation documentation
- `ParametricHistory.lean` - parametric_to_history bridge
- `FMCSDef.lean:20-31` - "Proof-Theoretic Special Case" documentation

### Teammate Reports
- [Teammate A Findings](01_teammate-a-findings.md)
- [Teammate B Findings](01_teammate-b-findings.md)
