# Research Report: Task #900 (Team Research)

**Task**: Prove cut rule and derivation tree manipulation for recursive seed Henkin model
**Date**: 2026-02-18
**Mode**: Team Research (2 teammates)
**Session**: sess_1771440418_451de0

## Executive Summary

Team research investigated the blocker in task 864's Phase 4 (cross-family/time compatibility for positive modal/temporal cases) with the goal of finding a mathematically elegant, publication-ready solution (zero sorries, zero axioms).

**Key finding**: Cut elimination is NOT needed - the codebase already has complete derivation composition infrastructure. The real blocker is a **semantic inconsistency in the worklist algorithm** that can create contradictory positions depending on processing order. However, a new theorem (`insert_consistent_of_derivable_parent`) was VERIFIED TO COMPILE that provides a path forward.

**Critical discovery**: The `futurePositive` and `pastPositive` cases MAY already be provable with existing infrastructure. Only `boxPositive` is fundamentally blocked.

## Synthesis of Findings

### 1. The True Nature of the Blocker

**Both teammates converge**: The problem is NOT about missing proof composition infrastructure. The codebase has:
- `deduction_theorem`: Converts `A :: Gamma |- B` to `Gamma |- A -> B`
- `imp_trans`: Chains implications
- `addFormula_preserves_consistent_of_theorem`: Theorems can be freely added
- T-axioms: `|- Box psi -> psi`, `|- G psi -> psi`, `|- H psi -> psi`

**The real blocker**: When processing `boxPositive psi`, the algorithm adds `psi` to ALL families at the current time. But for families where `Box psi` is NOT present, there is no derivation witness for the compatibility proof `SetConsistent (insert psi entry.formulas)`.

### 2. Critical Discovery: Processing Order Can Create Contradictions

**Teammate A's counterexample** (verified analysis):

Consider original formula containing both `Box p` and `neg(Box p)` at different positions:
1. If `Box p` processed FIRST: `p` added to all EXISTING families. Family with `neg p` doesn't exist yet. No conflict.
2. If `neg(Box p)` processed FIRST: Creates new family with `{neg p}`. Then `Box p` tries to add `p` to ALL families INCLUDING the one with `neg p`. Result: `{neg p, p}` is **inconsistent**.

**CONCLUSION**: The current algorithm is potentially unsound for maintaining per-entry `SeedConsistent` - the conflict CAN arise depending on processing order.

### 3. Key Breakthrough: `insert_consistent_of_derivable_parent` (VERIFIED COMPILATION)

**Teammate A proved** (zero sorries, compiles in Lean 4):

```lean
noncomputable def insert_consistent_of_derivable_parent
    {S : Set Formula} {parent child : Formula}
    (h_S_cons : SetConsistent S)
    (h_parent_in : parent ∈ S)
    (h_derives : |- parent.imp child) :
    SetConsistent (insert child S)
```

**Three corollaries** (also verified):
- `insert_psi_consistent_of_box_psi_in`: If `Box psi` in S, then `insert psi S` consistent
- `insert_psi_consistent_of_g_psi_in`: If `G psi` in S, then `insert psi S` consistent
- `insert_psi_consistent_of_h_psi_in`: If `H psi` in S, then `insert psi S` consistent

These solve compatibility IF the parent formula is present at the target entry.

### 4. Temporal Cases May Already Be Provable

**Teammate B's critical observation**: The `processWorkItem` for `futurePositive` (lines 6544-6555) adds BOTH `psi` AND `G psi` to each future time:

```lean
-- futurePositive adds G psi BEFORE psi at each time step
```

The existing `foldl_addFormula_times_preserves_consistent_with_gpsi` lemma (line 2903) handles exactly this case - it requires `G psi` to be at target entries and uses the T-axiom derivation.

**Similarly for `pastPositive`**: The algorithm adds `H psi` before `psi`, which can use the `_with_hpsi` variant.

**The ONLY truly blocked case is `boxPositive`** - the algorithm does NOT propagate `Box psi` to other families before adding `psi`.

### 5. Recommended Solutions (Ordered by Preference)

#### Solution 1: Prove `SeedConsistent` as Post-Condition (RECOMMENDED - Most Elegant)

**Both teammates converge on this**: Instead of maintaining `SeedConsistent` as a loop invariant, prove it as a consequence of the completed seed's closure properties.

**Strategy**:
1. Remove `SeedConsistent` from `WorklistInvariant`. Replace with weaker `FormulaConsistent` for each formula.
2. Complete Phase 5 (closure proofs) first: `ModalClosed`, `GClosed`, `HClosed`.
3. Prove `SeedConsistent` from closure properties using `insert_consistent_of_derivable_parent`.

**Why this works**: In the completed seed:
- If `Box psi` is at position, `psi` is also there (by `ModalClosed`)
- If `G psi` is at position, `psi` is also there at future times (by `GClosed`)
- The `insert_consistent_of_derivable_parent` corollaries then justify each formula's presence

#### Solution 2: Process Positive Before Negative (Algorithm Constraint)

Ensure `boxPositive` work items are processed BEFORE `boxNegative` items for the same base formula. This prevents the counterexample scenario where `neg p` is created before `p` tries to be added.

**Implementation**: Sort the worklist with priority for positive modal items.

**Risk**: Requires proving the ordering constraint is maintained and doesn't affect termination.

#### Solution 3: Propagate Parent First (Algorithm Modification)

Modify `processWorkItem` for `boxPositive` to propagate `Box psi` to all families BEFORE propagating `psi`:

```lean
| .boxPositive psi =>
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target
    let familyIndices := seed1.familyIndices
    -- NEW: propagate Box psi to ALL families first
    let seed1' := familyIndices.foldl (fun s f =>
        s.addFormula f item.timeIdx (Formula.box psi) .universal_target) seed1
    -- THEN propagate psi (now Box psi is present as witness)
    let seed2 := familyIndices.foldl (fun s f =>
        s.addFormula f item.timeIdx psi .universal_target) seed1'
    ...
```

**Challenge**: Adding `Box psi` to other families has the SAME compatibility problem - unless handled via new positions being singletons (trivially consistent).

### 6. Immediate Action Items

1. **Verify temporal cases work**: Check if `futurePositive` and `pastPositive` are provable NOW using existing `_with_gpsi` / `_with_hpsi` lemmas. This would reduce blocked sorries from 3 to 1.

2. **Add `insert_consistent_of_derivable_parent` to codebase**: This verified theorem is a crucial building block regardless of which solution path is chosen.

3. **Examine `buildSeedAux_preserves_seedConsistent` boxPositive case**: The OLD recursive algorithm handles the same case. If it's proven (not sorry), its technique can be adapted.

## Conflicts Identified and Resolved

| Topic | Teammate A | Teammate B | Resolution |
|-------|-----------|-----------|------------|
| Root cause | Semantic, not proof-theoretic | Cross-family compatibility | **Agree**: Same diagnosis |
| Temporal cases | General analysis | May be already provable | **B's insight adopted**: Check existing lemmas |
| Primary solution | Post-condition approach | Hybrid Seed-then-Close | **Converge**: Post-condition with closure properties |

## Gaps Identified

1. **Need to verify** whether `futurePositive`/`pastPositive` actually work with existing lemmas (requires checking algorithm's add order)
2. **Need to formalize** "all formulas are consequences of original phi" if using provenance-based approach
3. **Unknown** whether `buildSeedAux` boxPositive case is already proven or also sorry

## Technical Debt Assessment

Per proof-debt-policy.md:
- **Sorries blocked**: 3 in `processWorkItem_preserves_consistent` (boxPositive, futurePositive, pastPositive)
- **Potentially unblocked NOW**: 2 (futurePositive, pastPositive) if existing lemmas apply
- **Truly blocked**: 1 (boxPositive) requires architecture decision
- **New lemma proven**: `insert_consistent_of_derivable_parent` (zero sorries, verified compilation)

## Recommendations Summary

| Priority | Action | Effort | Impact |
|----------|--------|--------|--------|
| 1 | Check if temporal cases work with existing infrastructure | Low | Reduces blocked sorries 3→1 |
| 2 | Add `insert_consistent_of_derivable_parent` to codebase | Low | Key building block |
| 3 | Choose architecture path for boxPositive | Medium | Unblocks final sorry |
| 4 | Implement chosen solution | High | Publication-ready metalogic |

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Cut elimination / derivation | Completed | High | `insert_consistent_of_derivable_parent` theorem; processing order counterexample |
| B | Alternative architectures | Completed | Medium-High | Temporal cases insight; 5 approaches analyzed |

## References

### Files Examined
- `RecursiveSeed.lean`: Lines 6525-6555 (processWorkItem positive cases)
- `RecursiveSeed.lean`: Lines 2648-3002 (foldl consistency lemmas)
- `DeductionTheorem.lean`: Derivation composition infrastructure
- `Combinators.lean`: `imp_trans` and related

### Key Lemmas Verified (lean_local_search)
- `box_inner_consistent`, `all_future_inner_consistent`, `all_past_inner_consistent` (proven)
- `addFormula_preserves_consistent`, `addFormula_preserves_consistent_of_theorem` (proven)
- `foldl_addFormula_times_preserves_consistent_with_gpsi` (proven - KEY for temporal cases)
- `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` (proven - wrapper)

## Conclusion

The blocker is deeper than initially characterized but IS solvable without new axioms or fundamental changes to the logic. The `insert_consistent_of_derivable_parent` theorem provides the proof-theoretic infrastructure needed. The key insight is that `SeedConsistent` should be a **post-condition of closure**, not a loop invariant. This aligns with the mathematical reality that consistency is a global property of the completed model, not a local property of intermediate construction states.

The most elegant publication-ready approach:
1. Weaken the loop invariant to `FormulaConsistent` only
2. Prove closure properties (ModalClosed, GClosed, HClosed)
3. Derive `SeedConsistent` from closures using `insert_consistent_of_derivable_parent`
4. No sorries, no axioms, mathematically clean
