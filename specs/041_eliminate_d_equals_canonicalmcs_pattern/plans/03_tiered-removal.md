# Implementation Plan: Task #41 - Tiered Removal Strategy (v3)

- **Task**: 41 - eliminate_d_equals_canonicalmcs_pattern
- **Status**: [COMPLETED]
- **Effort**: 5-6 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/03_removal-analysis.md
- **Artifacts**: plans/03_tiered-removal.md (this file)
- **Supersedes**: plans/01_coexistence-strategy.md, plans/02_removal-strategy.md
- **Type**: lean4
- **Lean Intent**: true (zero-sorry policy compliance)

## Overview

**User Guidance**: Three-tier disposal based on value vs confusion:
1. **DELETE**: Confused/wrong patterns (D=CanonicalMCS is fundamentally confused)
2. **BONEYARD**: Valuable but unneeded infrastructure (preserve for future reference)
3. **ROAD_MAP.md**: Document D=CanonicalMCS as a Dead End

### The Core Confusion

D=CanonicalMCS conflates:
- **D (duration domain)**: Should be a timeline type (Int, Rat, TimelineQuot) with AddCommGroup + LinearOrder
- **CanonicalMCS**: The space of ALL maximal consistent sets (should be W, world states)

This creates an identity mapping `mcs(w) = w.world` that **trivializes F/P witness obligations** instead of proving them. The pattern is mathematically valid but **semantically confused** - it doesn't prove completeness, it sidesteps it.

## File Classification

### Tier 1: DELETE (Confused/Wrong)

Files embodying the D=CanonicalMCS confusion. No preservation value - git history suffices.

| File | Why Confused |
|------|--------------|
| `Bundle/CanonicalFMCS.lean` | Core D=CanonicalMCS pattern - conflates D with space of all MCS |
| `Bundle/FMCSTransfer.lean` | Dead infrastructure attempting to transfer confused construction |
| `Algebraic/CanonicalQuot.lean` | Antisymmetrization of confused type (never instantiated) |

### Tier 2: BONEYARD (Valuable but Unused)

Legitimate techniques that aren't currently needed. Preserve for potential future use.

| File | Why Valuable | Why Unused |
|------|--------------|------------|
| `Bundle/ChainFMCS.lean` | Chain FMCS construction technique | Only for CanonicalMCS flags |
| `Bundle/ClosedFlagBundle.lean` | Closed flag set construction | Superseded by DirectMultiFamilyBFMCS |
| `Bundle/ClosedFlagIntBFMCS.lean` | Int BFMCS from closed flags | Superseded, depends on closed flags |
| `Bundle/WitnessFamilyBundle.lean` | Witness family technique | Only for CanonicalMCS diamonds |
| `Bundle/SaturatedBFMCSConstruction.lean` | Modal saturation technique | Uses CanonicalMCS as base |
| `Bundle/ModalWitnessData.lean` | Modal witness data structure | Uses CanonicalMCS |
| `Algebraic/MultiFamilyBFMCS.lean` | Multi-family BFMCS approach | Built on confused foundation |

### Tier 3: CLEAN (Active Files with Dead References)

Remove imports/comments referencing deleted infrastructure.

| File | Change Needed |
|------|---------------|
| `BaseCompleteness.lean` | Remove CanonicalFMCS import, clean comments |
| `DenseCompleteness.lean` | Remove CanonicalFMCS import, clean comments |
| `DiscreteCompleteness.lean` | Remove CanonicalFMCS import, clean comments |
| `Completeness.lean` | Remove CanonicalMCS comments |
| `LogicVariants.lean` | Remove import, fix broken `dense_components_proven` reference |
| `FMCSDef.lean` | Clean D=CanonicalMCS anti-pattern comments |

## Implementation Phases

### Phase 1: DELETE Confused Files [COMPLETED]

**Goal**: Remove files embodying the D=CanonicalMCS confusion. No Boneyard - these represent architectural errors.

**Files to delete**:
1. `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`
2. `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`
3. `Theories/Bimodal/Metalogic/Algebraic/CanonicalQuot.lean`

**Tasks**:
- [ ] Verify these files are not imported by SuccChain completeness (they aren't)
- [ ] `git rm` each file
- [ ] Run `lake build` to verify no breakage (may need Phase 2 first for import chains)

**Timing**: 0.5 hours

---

### Phase 2: BONEYARD Valuable Infrastructure [COMPLETED]

**Goal**: Archive legitimate techniques that depend on the confused pattern.

**Tasks**:
- [ ] Create `Boneyard/CanonicalMCS_Infrastructure/` directory
- [ ] Move files with archival headers explaining why archived:

```lean
/-!
# Archived: ChainFMCS.lean
**Archived**: 2026-03-23
**Reason**: Built on D=CanonicalMCS pattern which conflates duration domain with MCS space
**Technique Value**: Chain FMCS construction is legitimate; pattern could be reimplemented with proper D/W separation
**Original Purpose**: Chain FMCS over CanonicalMCS flags for temporal coherence
**See Also**: SuccChainFMCS.lean for the correct D=Int approach
-/
```

**Files to archive**:
1. `Bundle/ChainFMCS.lean`
2. `Bundle/ClosedFlagBundle.lean`
3. `Bundle/ClosedFlagIntBFMCS.lean`
4. `Bundle/WitnessFamilyBundle.lean`
5. `Bundle/SaturatedBFMCSConstruction.lean`
6. `Bundle/ModalWitnessData.lean`
7. `Algebraic/MultiFamilyBFMCS.lean`

**Timing**: 1.5 hours

---

### Phase 3: Clean Active File Imports [COMPLETED]

**Goal**: Remove dead imports and references from active completeness files.

**Tasks**:
- [ ] Remove `import Bimodal.Metalogic.Bundle.CanonicalFMCS` from:
  - BaseCompleteness.lean
  - DenseCompleteness.lean
  - DiscreteCompleteness.lean
  - Completeness.lean
  - LogicVariants.lean
- [ ] Remove/update comments referencing deleted files
- [ ] Fix LogicVariants.lean broken `dense_components_proven` reference
- [ ] Run `lake build` after each file

**Timing**: 1 hour

---

### Phase 4: Update ROAD_MAP.md Dead Ends [COMPLETED]

**Goal**: Document D=CanonicalMCS as a Dead End to prevent future repetition.

**Location**: Insert after "Dead End: W = D Canonical Construction" (related confusion)

**Content**:
```markdown
### Dead End: D = CanonicalMCS Pattern

**Status**: ABANDONED
**Tried**: 2025-12-01 to 2026-03-23
**Related Tasks**: Task 41, Task 956

*Rationale*: The D=CanonicalMCS pattern instantiates the FMCS type parameter D (timeline/duration type) with CanonicalMCS (the type of ALL maximal consistent sets). This creates an identity mapping `mcs(w) = w.world` that trivializes F/P witness obligations instead of proving them.

**What We Tried**:
The pattern appears in `CanonicalFMCS.lean` and propagates to FMCSTransfer, ChainFMCS, and 10+ dependent files. The crown jewel `temporal_coherent_family_exists_CanonicalMCS` is sorry-free but only because every MCS is trivially in the domain.

**Why It's Confused**:
1. **D should be a timeline type**: Int, Rat, or TimelineQuot with AddCommGroup + LinearOrder
2. **CanonicalMCS is the space of world states**: It should be W, not D
3. **Conflates temporal position with possible world**: D indexes time; W indexes worlds
4. **Trivializes rather than proves**: F/P witnesses exist by construction, not proof
5. **Never consumed**: The sorry-free theorem is never actually used by any completeness proof

**Evidence**:
- [03_removal-analysis.md](specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/03_removal-analysis.md) - Full analysis
- SuccChainCompleteness.lean - Correct D=Int approach (never references CanonicalMCS)

**Lesson**:
D and W must be distinct: D indexes temporal positions; W indexes possible worlds (MCSs). Collapsing them creates elegant proofs of nothing.

**Related**: See "Dead End: W = D Canonical Construction" for the dual confusion.

**Superseded By**: SuccChain completeness path (D=Int, W=MCS, properly separated)
```

**Timing**: 0.5 hours

---

### Phase 5: Clean FMCSDef.lean Documentation [COMPLETED]

**Goal**: Update FMCS definition comments to reflect correct architecture.

**Tasks**:
- [ ] Remove D=CanonicalMCS anti-pattern warnings (pattern no longer exists)
- [ ] Add note pointing to SuccChainFMCS as canonical D=Int implementation
- [ ] Document that D must be a proper timeline type (AddCommGroup + LinearOrder)

**Timing**: 0.5 hours

---

### Phase 6: Algebraic Path Decision [COMPLETED]

**Goal**: Decide on DirectMultiFamilyBFMCS and ModallyCoherentBFMCS retention.

**Background**: These files use CanonicalMCS but have 4 blocking sorries. Their own documentation recommends SuccChain.

**Decision Required**:
- **Option A (RECOMMENDED)**: Delete (already blocked, recommend SuccChain)
- **Option B**: Refactor to use MCS wrapper instead of CanonicalMCS

**Tasks**:
- [ ] Analyze if any sorry-free code depends on these
- [ ] Make decision with user input
- [ ] Execute deletion or deferral

**Timing**: 1 hour (including decision discussion)

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] SuccChainCompleteness still compiles (should be unaffected)
- [ ] No new sorries introduced
- [ ] No imports of deleted/archived files remain
- [ ] ROAD_MAP.md properly documents the dead end

## Artifacts & Outputs

- **Deleted**: 3 confused files (CanonicalFMCS, FMCSTransfer, CanonicalQuot)
- **Archived**: `Boneyard/CanonicalMCS_Infrastructure/` (7 files)
- **Updated**: ROAD_MAP.md with new Dead End entry
- **Cleaned**: 6+ active files with removed imports/comments

## Success Criteria

Task 41 is complete when:
- [ ] Confused D=CanonicalMCS files deleted (Phase 1)
- [ ] Valuable infrastructure archived to Boneyard (Phase 2)
- [ ] Active file imports cleaned (Phase 3)
- [ ] ROAD_MAP.md documents Dead End (Phase 4)
- [ ] FMCSDef.lean documentation updated (Phase 5)
- [ ] Algebraic path decision made (Phase 6)
- [ ] `lake build` succeeds with zero new sorries

## Comparison with Previous Plans

| Aspect | v1 (Coexistence) | v2 (Removal) | v3 (Tiered) |
|--------|------------------|--------------|-------------|
| Premise | Load-bearing | Dead infrastructure | Confused pattern |
| DELETE | None | All to Boneyard | 3 confused files |
| BONEYARD | Dead code only | All 10 files | 7 valuable files |
| ROAD_MAP | No update | No update | Dead End entry |
| Philosophy | Preserve | Remove | Triage by value |
