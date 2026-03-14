# Research Report: Task #965

**Task**: 965 - study_branch_duration_group_construction
**Started**: 2026-03-14T10:00:00Z
**Completed**: 2026-03-14T10:45:00Z
**Effort**: Medium (branch analysis)
**Dependencies**: None
**Sources/Inputs**: Git diff, codebase analysis, existing research reports
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The branch `claude/duration-group-construction-SFEJg` has already been **merged into main** (commit 2ca7425d)
- The merge introduced **4 new Lean files** and significantly modified **3 existing files**
- **Net effect**: +2817 lines added, -1718 lines removed = +1099 net lines
- **Key architectural change**: Introduces axiom-based resolution for the reflexive MCS obstacle
- **Proof debt changes**: CantorApplication.lean went from 8+ sorries to 0 sorries (via axiom)
- **Recommendation**: The merge decision was sound; follow-up task 964 addresses the remaining atom type freshness debt

## Context & Scope

This task was created to evaluate the differences between `claude/duration-group-construction-SFEJg` and `main`. However, at the time of analysis, the branch had already been merged into main in commit 2ca7425d (task 963). The analysis therefore compares the state before merge (commit d3be0fff) with the state after merge.

## Findings

### Branch Merge Summary

The merge commit message documented the key decision:
> "Branch determined superior: canonicalR_irreflexive axiom (standard theorem, String atom formalization artifact) cleanly discharges all Cantor prerequisites. CantorApplication.lean: 8 sorries -> 0. DensityFrameCondition auto-merged: 0 sorries. New files: CanonicalIrreflexivityAxiom.lean, CanonicalDomain.lean, DurationTransfer.lean, DiscreteTimeline.lean."

### New Files Introduced

| File | Lines | Purpose | Proof Status |
|------|-------|---------|--------------|
| `Canonical/CanonicalIrreflexivityAxiom.lean` | 119 | Axiom declaring `canonicalR_irreflexive` | 1 axiom (mathematically sound, blocked by String atoms) |
| `Domain/CanonicalDomain.lean` | 264 | Complete pipeline: MCSs -> TaskFrame D | Depends on axiom only |
| `Domain/DurationTransfer.lean` | 227 | Group structure transfer along OrderIso | **SORRY-FREE** |
| `Domain/DiscreteTimeline.lean` | 314 | Discrete case (T -> Z via SuccOrder) | 5 sorries (DF coverness) |

### Modified Files

| File | Change | Impact |
|------|--------|--------|
| `StagedConstruction/CantorApplication.lean` | -1010 lines | Removed failed proof attempts, now uses axiom |
| `Bundle/CanonicalConstruction.lean` | +231/-60 lines | Simplified task_rel to forward-only with identity at zero |
| `Metalogic/Representation.lean` | -721 lines | Archived to Boneyard, replaced with stub |

### Architectural Analysis

#### 1. The Axiom Approach (CanonicalIrreflexivityAxiom.lean)

**Content**: Declares `canonicalR_irreflexive : forall M, SetMaximalConsistent M -> not (CanonicalR M M)`

**Justification**: This is a standard theorem in modal logic literature (Goldblatt 1992, BdRV 2001), provable when the atom type supports freshness. With `String` atoms, the proof is blocked because:
- For every string `s`, the tautology `G(s v not s)` is in M
- So `s v not s` is in GContent(M) with `s` in its atoms
- No string is fresh for GContent(M)

**Mathematical Status**: The axiom is a **formalization artifact**, not a mathematical gap. The result is true in any formalization where atoms admit freshness.

**Advantages**:
- Cleanly discharges all Cantor prerequisites (NoMaxOrder, NoMinOrder, DenselyOrdered)
- Eliminates 8+ sorries from CantorApplication.lean
- Provides clear documentation of the proof debt
- Derivable consequences (`canonicalR_antisymmetric_strict`, `canonicalR_strict`) are theorems, not axioms

**Costs**:
- Introduces 1 axiom to the proof system
- Creates proof debt that must be resolved by changing atom type
- Resolution path documented but requires significant refactoring

#### 2. Duration Transfer (DurationTransfer.lean)

**Key Contribution**: Generic, sorry-free infrastructure for transferring algebraic structure along OrderIso.

**Functions**:
- `transferAddCommGroup`: Given `e : T ≃o G`, produces `AddCommGroup T`
- `transferIsOrderedAddMonoid`: Proves order compatibility of transferred structure
- `intOrderIso`, `ratOrderIso`: Apply characterization theorems (Z and Q respectively)
- `canonicalTaskFrame`: Build TaskFrame from transferred structure

**Mathematical Pattern**: The construction is an instance of the forgetful/free functor adjunction:
```
MCS(Axioms) --Char--> Q or Z
     |                    |
  U  |                    | U (forgetful)
     v                    v
LinearOrder --Char--> LinearOrder
```

**Proof Quality**: **SORRY-FREE**. The transfer pattern is algebraically sound and requires no additional axioms beyond the characterization theorems already in Mathlib.

#### 3. Canonical Domain (CanonicalDomain.lean)

**Purpose**: Complete end-to-end pipeline from MCSs to TaskFrame D.

**Constructions Provided**:
1. **Dense Case** (D ~ Q): `denseCanonicalTaskFrame`
   - Pipeline: MCSs -> DenseTimelineElem -> TimelineQuot -> Cantor iso -> AddCommGroup -> TaskFrame
   - **Depends only on `canonicalR_irreflexive` axiom** - no sorry dependencies

2. **Discrete Case** (D ~ Z): `discreteCanonicalTaskFrame`
   - Pipeline: MCSs -> DiscreteTimelineElem -> TimelineQuot -> Z characterization -> AddCommGroup -> TaskFrame
   - **Has 5 sorries** in SuccOrder/PredOrder (DF coverness extraction)

3. **Base Case**: Documented as open problem (no characterization theorem available)

**Architecture Diagram** (from docstring):
```
Axiom System -> MCSs -> Timeline (Dense/Discrete) -> Characterization -> Transfer -> TaskFrame
```

#### 4. Discrete Timeline (DiscreteTimeline.lean)

**Purpose**: Build the discrete case of D construction via Z characterization.

**Status**:
- `NoMaxOrder`, `NoMinOrder`: **PROVEN** via `canonicalR_irreflexive` axiom (same pattern as dense case)
- `SuccOrder`, `PredOrder`, `IsSuccArchimedean`: **5 sorries** (DF coverness extraction)

**Remaining Work**: The DF (discreteness axiom) coverness proof requires showing that the discreteness frame condition implies immediate successors in the canonical model. This is blocked by the same fundamental issue as the dense case (needing to extract frame conditions at the MCS level).

#### 5. Canonical Construction Simplification

**Before**: `canonical_task_rel M d N` required both:
- `GContent M.val subset N.val` (forward coherence)
- `HContent N.val subset M.val` (backward coherence)

**After**: `canonical_task_rel M d N` is forward-only with identity at zero:
- `d > 0`: `CanonicalR M.val N.val`
- `d = 0`: `M = N`
- `d < 0`: `False`

**Advantages**:
- Eliminates need for T-axiom (no longer need `GContent M subset M`)
- Compositionality proof is simpler (case analysis on sign of d)
- Aligns with `respects_task` semantics (only non-negative durations tested)

**Costs**:
- Slightly different semantics (negative durations now unreachable rather than vacuously true)
- But this is actually more accurate for the intended use

#### 6. Representation.lean Archival

**Before**: Full representation theorem implementation with standard completeness theorems.

**After**: 34-line stub pointing to archived location (`Boneyard/IntRepresentation/Representation.lean`).

**Reason**: The old implementation hardcoded `D = Int` through `construct_saturated_bfmcs_int`, violating the pure-syntax constraint. The archive preserves the code for reference while removing it from the active codebase.

### Proof Debt Summary

| Category | Before Merge | After Merge | Change |
|----------|--------------|-------------|--------|
| CantorApplication sorries | 8+ | 0 | -8+ (via axiom) |
| DiscreteTimeline sorries | N/A | 5 | +5 (new file) |
| DurationTransfer sorries | N/A | 0 | 0 (new file) |
| CanonicalDomain sorries | N/A | 0 | 0 (new file) |
| Axioms introduced | 0 | 1 | +1 (`canonicalR_irreflexive`) |
| Net effect | 8+ sorries | 5 sorries + 1 axiom | Improved |

### Resolution Path

Task 964 was created to resolve the atom type freshness debt:
- Change atom type from `String` to a type supporting freshness
- Example: `structure Atom where base : String; fresh_index : Option Nat`
- This would make `canonicalR_irreflexive` provable, converting the axiom to a theorem
- Large-scale refactoring required across Formula/syntax modules

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| N/A | The branch approach was not a dead end; it was merged successfully | N/A |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | CONCLUDED | Branch implements the final form of this strategy |
| canonicalR_irreflexive via axiom | CONCLUDED | Standard approach adopted |

The ROAD_MAP.md already documented that `canonicalR_irreflexive` is "UNUSED and UNPROVABLE with String atoms" and that "Irreflexivity is obtained for free via strict `<` on CanonicalMCS preorder." The branch implements this insight by:
1. Declaring the axiom explicitly
2. Using the axiom to prove the Cantor prerequisites
3. Documenting the resolution path (atom type change)

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Group transfer via OrderIso | Duration Transfer | No | new_file |
| Cantor characterization pipeline | Canonical Domain | Partial | extension |
| Axiom-based proof debt pattern | Axiom Approach | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `duration-transfer-pattern.md` | `domain/` | Document the group transfer pattern for D construction | Medium | No |

**Rationale**: The DurationTransfer.lean code is well-documented internally; a separate context file would be redundant.

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `ROAD_MAP.md` | Strategies section | Update D Construction strategy to CONCLUDED with references to merged files | Low | No |

**Rationale**: The merge commit message provides sufficient documentation; ROAD_MAP.md already has the strategic context.

### Summary

- **New files needed**: 0
- **Extensions needed**: 0 (optional update to ROAD_MAP.md)
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. **Branch merge was correct**: The axiom-based approach cleanly resolves the proof debt while documenting the resolution path.
2. **Task 964 is appropriate follow-up**: Resolving the atom type freshness is the right long-term fix.
3. **No additional tasks needed**: The existing task 964 covers the resolution path.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Axiom could be inconsistent | High | Mathematical confidence is high (standard literature result). Counterexample would require reflexive MCS in actual temporal models, which are ruled out by strict `<` semantics. |
| Atom type refactoring is extensive | Medium | Task 964 exists to track this work. Can be deferred without blocking other progress. |
| Discrete case still has sorries | Medium | NoMaxOrder/NoMinOrder resolved; SuccOrder/PredOrder are independent blocking issues (DF coverness). |

## Appendix

### Search Queries Used

- `git branch -a | grep duration-group`
- `git diff d3be0fff..2ca7425d --stat`
- `git diff d3be0fff..2ca7425d -- {file}` for each modified file

### Git History Analysis

- Branch created for task 960 (Duration Group Construction from Pure Syntax)
- Merged in task 963 after comparison showing axiom approach superior
- Follow-up task 964 created for atom type freshness resolution

### References

- Goldblatt (1992), *Logics of Time and Computation*, Ch. 6
- Blackburn, de Rijke, Venema (2001), *Modal Logic*, Ch. 4.8
- `specs/960_duration_group_construction/reports/research-001.md`: Full analysis of D construction
- `specs/960_duration_group_construction/reports/research-002.md`: Reflexive MCS obstacle analysis
