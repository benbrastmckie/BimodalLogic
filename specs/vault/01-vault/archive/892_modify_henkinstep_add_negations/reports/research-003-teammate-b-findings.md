# Teammate B Findings: Alternative Approaches Analysis

## Summary

Five related tasks (843, 864, 870, 881, 882, 888) have been attacking the same fundamental problem from different angles: constructing a sorry-free, axiom-free BMCS with both modal saturation and temporal coherence. After comprehensive analysis, the RecursiveSeed approach (task 864) is the most viable path forward. All TemporalLindenbaum-based approaches (tasks 882, 888, 892) have hit the same mathematical wall: TCS maximality does not imply MCS. The Zorn approach (task 870) contains mathematically false lemmas. DovetailingChain is architecturally blocked at cross-sign propagation.

## Key Findings

### Task 870 (ZornFamily)

- **Status**: implementing (stalled since 2026-02-13; 8 research reports, 4 plan versions)
- **Sorry count**: 11 in ZornFamily.lean (grep count), with 3 mathematically FALSE lemmas
- **Key blockers**:
  1. `multi_witness_seed_consistent_future` (FALSE): MCS with F(p) and F(neg p) makes seed {p, neg p} inconsistent
  2. `multi_witness_seed_consistent_past` (FALSE): symmetric
  3. `non_total_has_boundary` (FALSE): domain Z \ {0} has no boundary but is not Set.univ
- **What works**: Cross-sign case (seed consistency when domain has times on both sides of t) IS provable
- **Assessment**: After 4 plan versions and 8 research reports, the Zorn approach has been exhaustively explored. The fundamental problem is that Zorn gives existence without construction trace, making F/P witness verification impossible. Research-008 recommends pivoting to DovetailingChain, but DovetailingChain itself is blocked (see below).
- **Salvageable infrastructure**: GHCoherentPartialFamily, GContent/HContent consistency lemmas, cross-sign collection argument pattern

### Task 881 (Modally Saturated BMCS)

- **Status**: blocked
- **Blocked by**: Task 887 completed WITH sorries; temporal coherence of witness families requires temporal-aware Lindenbaum construction
- **Dependency chain**:
  ```
  881 (axiom elimination)
    -> 887 (FinalConstruction) completed with sorries
      -> 888 (temporal saturation preservation) BLOCKED
        -> 891 (split-at tactic) COMPLETED
        -> 892 (henkinStep negations) BLOCKED (mathematical obstruction)
  ```
- **11 research reports, 7 plan versions**: Extensive exploration across multiple strategies
- **Key insight from research-009 (team v5)**: RecursiveSeed recommended as sorry-free path forward; DovetailingChain's two-chain architecture fundamentally cannot prove cross-sign G/H propagation; UnifiedChain shifts blocker to combined seed consistency (7 sorries)
- **What was accomplished**: Modal saturation IS proven sorry-free via `exists_fullySaturated_extension` in SaturatedConstruction.lean. Only temporal coherence of witness families has sorry.

### Task 882 (TemporalLindenbaum Sorries)

- **Status**: blocked (since 2026-02-13, no code changes made)
- **Key learning**: The `temporalLindenbaumMCS` approach is fundamentally flawed for temporal logic because it attempts to build a SINGLE MCS that is "temporally saturated" (F(psi) in M implies psi in M). This conflates temporal witnesses at different time points into a single set.
- **Specific failures**:
  1. Henkin base cases (sorries 1-2): When F(psi) is in the initial base, psi may not be in henkinLimit because the temporal package {F(psi), psi} can be inconsistent with the accumulated set (e.g., base = {F(p), neg(p)})
  2. Maximality cases (sorries 3-4): Circularity -- need insert(phi, M) in TCS to derive contradiction, but TCS membership requires temporal saturation, which is what we're trying to prove
  3. Sorry 5 (temporal_coherent_family_exists): Depends on above; blocked
- **Recommendation from summary**: Abandon single-MCS temporalLindenbaumMCS approach; use indexed family constructions (DovetailingChain, RecursiveSeed)

### Task 888 (Temporal Saturation Preservation)

- **Status**: blocked (since 2026-02-17)
- **Key gap**: Regular Lindenbaum extension does NOT preserve temporal saturation. This is a mathematical fact, not an implementation bug.
- **Counterexample**: Lindenbaum enumerates formulas one by one. It can add F(chi) at step k, then later add neg(chi) at step j > k. Result: MCS contains F(chi) and neg(chi) but NOT chi.
- **Truth lemma requirement**: ALL families must be temporally coherent (not just eval_family). The Box case recurses into all families, and temporal formulas in those families need h_tc.
- **TemporalLindenbaum partial solution**: Adds formulas as temporal packages (atomically including witnesses). BUT sorries remain in base case (F(psi) in initial base without psi processed) and in maximal_tcs_is_mcs.
- **Current sorry count in TemporalLindenbaum.lean**: 6 (4 in maximal_tcs_is_mcs, 2 in maximal_tcs_is_mcs_closed)
- **Sub-tasks created**: 890 (measure_wf fix, COMPLETED), 891 (split-at tactic, COMPLETED), 892 (henkinStep negations, BLOCKED)

### Task 892 (This Task - henkinStep Negations)

- **Status**: blocked (confirmed mathematical obstruction across 3 plan versions)
- **What was accomplished**: Fixed henkinStep saturation (uses temporalPackage for negations), proved henkinLimit_forward/backward_saturated
- **Hard blocker**: maximal_tcs_is_mcs is mathematically FALSE as stated. A set can be maximal in TCS (temporally-saturated consistent sets) without being an MCS (maximal consistent set). Specifically, when phi = F(psi) and neg(psi) in M, the set insert(F(psi), M) is consistent but NOT in TCS (fails temporal saturation), so M can be TCS-maximal without being an MCS.
- **WitnessClosedSet approach**: Attempted and rejected. Equivalent to temporal saturation (same property), does not help.

### Task 864 (RecursiveSeed - The Most Viable Path)

- **Status**: implementing (most active, most progress)
- **Sorry count**: 3 in RecursiveSeed.lean proper (lines 5709, 5734, 6005), plus sorries in FinalConstruction.lean (32 grep matches, but many in comments)
- **Key advantage**: Pre-places ALL temporal witnesses BEFORE Lindenbaum extension, bypassing the TCS/MCS tension entirely
- **Research-004 analysis**: 4 sorries remain, with clear resolution via "single-path invariant" -- buildSeedAux follows a single path through the formula tree, so positive-branch operations (Box/G/H) never encounter conflicting families
- **Progress**: After 23+ sessions, reduced from many sorries to 3-4; Box case sorry eliminated via single-path invariant; generic imp case eliminated via full case analysis
- **Remaining work**: G case and H case `addToAll*Times_preserves_consistent`, and `buildSeed_hasPosition_zero`
- **Estimated completion**: 3-5 more sessions

## Alternative Approaches Not Yet Explored

### 1. Hybrid RecursiveSeed + FinalConstruction

The most promising unexplored approach: use RecursiveSeed's pre-placement pattern to build witness families for FinalConstruction.lean. Instead of using regular Lindenbaum (which loses temporal saturation), use RecursiveSeed to build seeds that include temporal witnesses, then apply Lindenbaum to the already-temporally-closed seeds. This would fill the sorry in `fully_saturated_bmcs_exists_int_final` at the temporal coherence point.

### 2. Direct Modal+Temporal Co-construction

Rather than building modal saturation first (SaturatedConstruction) then trying to add temporal coherence, build both simultaneously. This has been mentioned in research but never formally pursued. The challenge is that modal saturation requires iterating over Diamond formulas, while temporal coherence requires witness families -- the interaction between these is complex.

### 3. Weaken the Truth Lemma Requirement

Currently the truth lemma requires ALL families to be temporally coherent. If the truth lemma could be restructured to only require temporal coherence for families reachable from the evaluation family via modal accessibility, the burden would be lighter. However, research-001 of task 888 conclusively showed this cannot work: the Box case recurses into ALL families.

## Recommendations

### Priority 1: Complete Task 864 (RecursiveSeed)

**Rationale**: RecursiveSeed is the only approach that avoids the fundamental TCS/MCS tension. It has:
- Sorry-free core infrastructure (task 880)
- Clear resolution path for remaining sorries (single-path invariant)
- 3-5 sessions estimated to completion
- No mathematically false lemmas
- No architectural blockers

### Priority 2: Bridge RecursiveSeed to FinalConstruction

Once task 864 is complete, the bridge to eliminating the FinalConstruction sorry is:
1. Use RecursiveSeed to build temporally-coherent witness families
2. These replace the regular-Lindenbaum witness families that lose temporal saturation
3. FinalConstruction.lean's temporal coherence sorry becomes provable

### Priority 3: Archive TemporalLindenbaum-Based Approaches

Tasks 882, 888, and 892 have conclusively demonstrated that the TemporalLindenbaum approach (building a single MCS that is also temporally saturated, then proving TCS-maximality implies MCS) has a fundamental mathematical obstruction. These tasks should be marked [BLOCKED] or [ABANDONED] with clear documentation of WHY, to prevent future re-exploration.

### Priority 4: Decide on ZornFamily (Task 870)

ZornFamily has been extensively explored (8 research reports, 4 plan versions) with diminishing returns. The 3 mathematically false lemmas should be deleted with counterexample documentation. The cross-sign argument should be factored out as shared infrastructure. The task should be marked [PARTIAL] or archived.

## Evidence

### Task Statuses (from state.json)
| Task | Status | Sorries in Primary File |
|------|--------|------------------------|
| 843 (axiom removal) | partial | N/A (superseded) |
| 864 (RecursiveSeed) | implementing | 3 in RecursiveSeed.lean |
| 870 (ZornFamily) | implementing (stalled) | 11 in ZornFamily.lean (3 FALSE) |
| 881 (modally saturated BMCS) | blocked | N/A (orchestration task) |
| 882 (TemporalLindenbaum sorries) | blocked | 6 in TemporalLindenbaum.lean |
| 888 (temporal saturation preservation) | blocked | 32 grep hits in FinalConstruction.lean (many in comments) |
| 892 (henkinStep negations) | blocked | 6 in TemporalLindenbaum.lean |

### File-Level Sorry Inventory
| File | Sorry Count (grep) | Assessment |
|------|-------------------|------------|
| RecursiveSeed.lean | 11 (many in comments) | 3 actual sorries, clear resolution path |
| ZornFamily.lean | 11 | 3 mathematically FALSE, others blocked |
| DovetailingChain.lean | 9 (many in comments) | 4 actual sorries, architecturally blocked |
| TemporalLindenbaum.lean | 9 (many in comments) | 6 actual sorries, mathematically obstructed |
| FinalConstruction.lean | 32 (many in comments/docs) | ~4 actual sorries, main gap = temporal coherence |
| UnifiedChain.lean | 9 (many in comments) | 7 actual sorries, shifts blocker |

### Lemma Names Verified
- `temporal_witness_seed_consistent`: EXISTS in RecursiveSeed.lean infrastructure (single-witness, proven)
- `multi_witness_seed_consistent_future`: EXISTS in ZornFamily.lean (FALSE)
- `maximal_tcs_is_mcs`: EXISTS in TemporalLindenbaum.lean (obstructed)
- `fully_saturated_bmcs_exists_int_final`: EXISTS in FinalConstruction.lean (main sorry)
- `exists_fullySaturated_extension`: EXISTS in SaturatedConstruction.lean (sorry-free)

## Confidence Level

**High** with the following reasoning:

1. The mathematical obstruction in maximal_tcs_is_mcs has been confirmed across 4 implementation sessions (task 892) and multiple research reports (tasks 882, 888). The semantic argument is clear: TCS-maximality is strictly weaker than MCS because TCS membership requires temporal saturation, which constrains what sets qualify.

2. The RecursiveSeed recommendation is supported by: (a) task 881 research-009 (team consensus), (b) task 870 research-008 (recommends pivot), (c) task 864 research-004 (concrete resolution path for remaining sorries).

3. The sorry counts and file-level assessments are based on direct grep verification of the source files, not just research report claims.

4. The dependency chain is well-documented across multiple task artifacts and state.json entries.
