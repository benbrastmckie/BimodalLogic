# Handoff: SDC-Maximality Revert for BurgessR3Maximal

## Session
- **Session ID**: sess_1778221275_3b41e2
- **Date**: 2026-05-08
- **Agent**: lean-implementation-agent

## Goal
Close the last sorry in the Chronicle module: `BurgessR3Maximal_bot_not_mem` at CounterexampleElimination.lean:254.

## Analysis Summary

The sorry at line 254 says: given `BurgessR3Maximal A B C` with A, C MCS, prove `bot not-in B`. This requires B to be consistent (SetConsistent B).

### Why the sorry exists
The current `BurgessR3Maximal` definition uses `ClosedUnderDerivation` (CUD) in all three positions:
```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  ClosedUnderDerivation B ∧
  burgessR3 A B C ∧
  forall D, ClosedUnderDerivation D -> B subset D -> not burgessR3 A D C
```

CUD includes Set.univ (inconsistent). The Zorn construction uses CUD family, so the maximal B could be Set.univ. We cannot prove B is consistent from the current definition because:
- The BX axiom system is compatible with both dense and discrete orders
- On discrete orders, untl(bot, gamma) can be satisfiable (empty open guard interval)
- So burgessR3(A, Set.univ, C) might hold, making Set.univ a valid CUD-maximal element

### Approach: SDC-Maximality
Change `BurgessR3Maximal` to use `SetDeductivelyClosed` (SDC = consistent + CUD):
```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  forall D, SetDeductivelyClosed D -> B subset D -> not burgessR3 A D C
```

Then `BurgessR3Maximal_bot_not_mem` is trivial: `h_r3m.1.1` gives `SetConsistent B`.

### Cascading Changes Required

#### RRelation.lean (Zorn construction)
1. `burgessR3DCSExtensions`: change family from CUD to SDC
2. `burgessR3Maximal_extension_exists`: change seed from CUD to SDC, prove chain union preserves SDC (consistency by finite character + CUD by union)
3. `BurgessR3Maximal_cud`: change `h.1` to `h.1.2`; add `BurgessR3Maximal_consistent: h.1.1`
4. `burgessR3Maximal_exists_from_seed`: prove DC({eta}) is SDC from eta in A (subset of consistent MCS)
5. `burgessR3Maximal_with_guard`: add `h_eta_cons : SetConsistent ({eta})` parameter

#### PointInsertion.lean (extension_fails + callers)
1. `BurgessR3Maximal_extension_fails`: add `h_cons : SetConsistent (deductiveClosure ({delta} union B))` parameter
2. `BurgessR3Maximal_neg_or_ext_fails`: pass `(deductiveClosure_is_dcs h_cons).1` in consistent branch; use `h_R3M.1.2` for CUD in inconsistent branch
3. ALL callers of `extension_fails` need consistency (6 sites)
4. ALL callers passing `h_r3m.1` as CUD need `h_r3m.1.2` (many sites across CE and PI)
5. Zorn calls in lemma_2_6/2_7/2_8 need SDC seeds

#### CounterexampleElimination.lean
1. `BurgessR3Maximal_g_content_sub`: `h_r3m.1` -> `h_r3m.1.2` for CUD
2. `BurgessR3Maximal_sdc`: becomes trivial (`h_r3m.1`)
3. `BurgessR3Maximal_bot_not_mem`: trivial from `h_r3m.1.1`
4. ALL `h_r3m_adj.1` references in call sites -> `h_r3m_adj.1.2`

### Blockers Identified

#### Blocker 1: extension_fails in burgess_D0_finite_subset_consistent_incons (MCS sub-case)
**Location**: PointInsertion.lean:2049
**Context**: `burgess_D0_finite_subset_consistent_incons` is called when {beta}union B is INCONSISTENT (beta.neg in B). Inside, there's a case split `by_cases h_mcs_B : SetMaximalConsistent B`. In the MCS sub-case:
- B is MCS, beta.neg in B, beta not-in B
- {beta}union B is inconsistent (beta and beta.neg both present)
- `BurgessR3Maximal_extension_fails h_r3m h_beta_not_B` was valid with CUD-maximality
- With SDC-maximality, `DC({beta}union B)` is NOT SDC (inconsistent), so extension_fails is inapplicable

**Resolution options**:
a) Show this sub-case is dead code (when B is MCS, every {delta}union B with delta not-in B is inconsistent, so the consistent branch at `burgess_D0_seed_consistent:2455` never reaches this code path for an MCS B)
b) Restructure the _incons function to not need extension_fails in the MCS case
c) Prove seed consistency directly when B is MCS using MCS properties

**Recommended**: Option (a). The `_incons` function is ONLY called from the inconsistent branch of `burgess_D0_seed_consistent`. The consistent branch calls `burgess_D0_finite_subset_consistent` instead. So the MCS sub-case within _incons IS reachable (B can be MCS and {beta}union B inconsistent). However, the neg-until witness can be obtained differently: when B is MCS and SDC-maximal, B has no SDC proper extensions at all, so the maximality clause is vacuous. The seed consistency proof needs a different route.

#### Blocker 2: extension_fails in lemma_2_7_seed_consistent
**Location**: PointInsertion.lean:3195
**Context**: `h_not_r3_xi := BurgessR3Maximal_extension_fails h_r3m h_xi_not_B`
Need `SetConsistent (DC({xi}union B))`. Not always available.

**Resolution**: Case-split on `SetConsistent ({xi}union B)`:
- Consistent: pass consistency to extension_fails
- Inconsistent: xi.neg in B, need alternative route for neg-until witness

#### Blocker 3: Same as Blocker 2 for Since mirror
**Location**: PointInsertion.lean:4193

#### Blocker 4: Zorn seeds need SDC
**Location**: PointInsertion.lean:3688,3690,4063,4065,4618,4620,5021,5023
**Context**: `burgessR3Maximal_extension_exists` now needs SDC seed. Seeds are either `h_B_dcs` (CUD from parameter) or `h_DC_cud` (DC of some set).
**Resolution**: Use `h_r3m.1` (now SDC) for the B-seeds. For DC seeds, prove the underlying set is consistent.

#### Blocker 5: burgessR3Maximal_with_guard callers
**Location**: PointInsertion.lean:5187,5338
**Context**: Need `SetConsistent ({gamma})` where gamma is the guard from `untl gamma beta in A`.
**Resolution**: Show {gamma} consistent. If gamma in some MCS, trivial. Otherwise, may need BX-chain argument. Check whether gamma can be shown to be in A or C.

### Mechanical Changes (Easy)
- `h_r3m.1` -> `h_r3m.1.2` for CUD access: ~40 sites in CounterexampleElimination.lean
- `h_r3m_adj.1` -> `h_r3m_adj.1.2`: ~30 sites in CounterexampleElimination.lean
- `cud_contains_theorems h_r3m.1` -> `cud_contains_theorems h_r3m.1.2`: 4 sites in PointInsertion.lean
- `neg_mem_of_inconsistent_union h_R3M.1` -> `neg_mem_of_inconsistent_union h_R3M.1.2`: 1 site

### Estimated Work
- Mechanical `.1` -> `.1.2` changes: ~1 hour
- Extension_fails consistency arguments (consistent cases): ~2 hours
- Blocker 1 (MCS sub-case in _incons): ~4-6 hours (major restructuring)
- Blockers 2-3 (lemma_2_7 seed consistency): ~3-4 hours each
- Blocker 4 (Zorn seeds): ~2 hours
- Blocker 5 (with_guard callers): ~2 hours
- Total: ~16-22 hours

### Files Modified (None - all changes reverted)
All changes were reverted to preserve a clean state for the next agent.

### Recommendation
The plan's approach (SDC-maximality) is mathematically correct but requires substantial refactoring. The key challenge is Blocker 1: when B is MCS within the _incons function. This case needs the neg-until witness which cannot be extracted via extension_fails under SDC-maximality.

**Suggested approach for Blocker 1**: When B is MCS and beta.neg in B, restructure the proof to avoid the neg-until witness entirely. Since B is MCS:
1. Any SDC D superset B: impossible (B already maximally consistent, D would need to add delta with delta.neg in B, making D inconsistent)
2. So the SDC-maximality clause is vacuous for MCS B
3. The seed consistency proof should use B's MCS properties directly instead of the BX5+BX7+BX13 chain

Alternatively, consider whether `burgess_D0_finite_subset_consistent_incons` can be split into separate lemmas for the MCS and non-MCS sub-cases, with the MCS sub-case using a completely different proof strategy.
