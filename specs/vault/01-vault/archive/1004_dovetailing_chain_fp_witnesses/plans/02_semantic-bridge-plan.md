# Implementation Plan: Task #1004

- **Task**: 1004 - Semantic Bridge from FlagBFMCS to WorldHistory
- **Version**: 02 (replaces 01_dovetailing-chain-plan.md)
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: Task #1003 (FlagBFMCS implementation)
- **Research Inputs**:
  - specs/1004_dovetailing_chain_fp_witnesses/reports/05_team-research.md
  - specs/1004_dovetailing_chain_fp_witnesses/reports/06_semantic-bridge-evaluation.md
- **Artifacts**: plans/02_semantic-bridge-plan.md (this file)
- **Type**: lean4
- **Lean Intent**: false

## Overview

**Key Insight from Research**: The original plan attempted to resolve `intFMCS_forward_F` and `intFMCS_backward_P` sorries via enriched dovetailing chain construction. Research rounds 2-3 established that **this is mathematically impossible** for linear chain constructions. F-formulas don't persist through Lindenbaum extensions, making Int-indexed F/P witnesses fundamentally unprovable.

**Revised Approach**:
1. Document the IntBFMCS F/P sorries as **fundamental limitations** (not blockers)
2. Build a **semantic bridge** connecting FlagBFMCS (metalogic) to WorldHistory (semantics)
3. The bridge IS the completeness theorem - separation of layers is standard practice

This approach follows the standard proof theory architecture:
- **Metalogic layer**: CanonicalFMCS, FlagBFMCS (MCSes as syntactic objects)
- **Semantic layer**: WorldHistory (world states as arbitrary types)
- **Bridge theorem**: Completeness connects them without merging them

### Previous Plan Status

Plan v01 (01_dovetailing-chain-plan.md) is OBSOLETE:
- Phase 1 [COMPLETED]: Int-indexed obligation enumeration (infrastructure exists)
- Phases 2-5 [BLOCKED]: Cannot be completed due to fundamental limitation

## Goals & Non-Goals

**Goals**:
- Document IntBFMCS F/P sorries with proper limitation comments
- Define `CanonicalTaskFrame : TaskFrame CanonicalMCS`
- Construct semantic embedding from FlagBFMCS worlds to WorldHistory
- Prove truth preservation between metalogic satisfaction and WorldHistory truth
- Verify completeness chain is end-to-end sorry-free using CanonicalMCS domain

**Non-Goals**:
- Fixing IntBFMCS F/P sorries (proven impossible)
- Int/Rat domain transfer (separate future task, optional)
- Modifying existing sorry-free infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TaskFrame type mismatch with CanonicalMCS | Medium | Low | CanonicalMCS has natural Preorder structure |
| WorldHistory requires AddCommGroup but CanonicalMCS has Preorder only | High | Medium | Define restricted CanonicalTaskFrame or use partial domain |
| FlagBFMCS structure differs from WorldHistory | Medium | Low | Both use (history, time) pairs; structure is analogous |
| Truth preservation proof complex | Medium | Medium | Build incrementally; verify each step type-checks |

## Implementation Phases

### Phase 1: Document IntBFMCS Limitation [NOT STARTED]

**Goal**: Mark IntBFMCS F/P sorries as documented fundamental limitations

**Tasks**:
- [ ] Add docstrings to `intFMCS_forward_F` and `intFMCS_backward_P` explaining the limitation
- [ ] Reference task 1004 research reports in comments
- [ ] Add `NOTE:` marker for static analysis tracking
- [ ] Optionally: move IntBFMCS to Boneyard if not needed for any active completeness path

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - Add limitation documentation

**Example docstring**:
```lean
/-- NOTE: FUNDAMENTAL LIMITATION (Task 1004)
    This sorry is mathematically impossible to prove for linear chain constructions.
    F-formulas do not persist through Lindenbaum extensions, so witnesses from
    `canonical_forward_F` cannot be embedded in Int-indexed chains.

    For completeness, use CanonicalFMCS (CanonicalMCS domain) where F/P witnesses
    are trivially available via canonical_forward_F/canonical_backward_P.

    See: specs/1004_dovetailing_chain_fp_witnesses/reports/06_semantic-bridge-evaluation.md -/
theorem intFMCS_forward_F ... : ... := sorry
```

**Verification**:
- [ ] Comments added and accurate
- [ ] File still compiles

---

### Phase 2: Define CanonicalTaskFrame [NOT STARTED]

**Goal**: Create a TaskFrame where world states are CanonicalMCSes

**Tasks**:
- [ ] Define `CanonicalTaskFrame` structure with `WorldState := CanonicalMCS`
- [ ] Define `task_rel : CanonicalMCS -> CanonicalMCS -> Prop` using `CanonicalR`
- [ ] Handle the AddCommGroup requirement for duration type D
  - Option A: Use CanonicalMCS-indexed "duration" via path length
  - Option B: Define partial TaskFrame without full AddCommGroup structure
  - Option C: Parametrize by external duration type D with embedding
- [ ] Prove required TaskFrame properties

**Timing**: 1.5 hours

**Files to create/modify**:
- Create `Theories/Bimodal/Semantics/CanonicalTaskFrame.lean`
- Import from WorldHistory.lean and CanonicalFrame.lean

**Verification**:
- [ ] New file compiles
- [ ] TaskFrame instance typecheck passes

---

### Phase 3: Construct Flag-to-History Embedding [NOT STARTED]

**Goal**: Map FlagBFMCS worlds (Flag, element) to WorldHistory structures

**Tasks**:
- [ ] Define `flagToHistory : Flag -> WorldHistory CanonicalTaskFrame`
  - Flag provides a total order of MCSes (the timeline)
  - ChainFMCSDomain(flag) is the time domain
  - MCSes in the Flag are the world states
- [ ] Show domain is convex (follows from Flag being a chain)
- [ ] Show states respect task_rel (follows from CanonicalR between chain elements)
- [ ] Define inverse mapping for full correspondence

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/CanonicalTaskFrame.lean` - Add embedding

**Verification**:
- [ ] `flagToHistory` compiles
- [ ] Convexity/respect lemmas are sorry-free

---

### Phase 4: Prove Truth Preservation [NOT STARTED]

**Goal**: Show satisfaction in FlagBFMCS iff truth in corresponding WorldHistory

**Tasks**:
- [ ] Define truth relation for WorldHistory over CanonicalTaskFrame
- [ ] Prove `flagSat_iff_historyTrue`:
  - `FlagBFMCS.sat flag t phi <-> WorldHistory.true (flagToHistory flag) t phi`
- [ ] Handle temporal operators F/P via witnesses
  - In FlagBFMCS: witnesses via canonical_forward_F/P
  - In WorldHistory: witnesses via domain ordering
- [ ] Handle modal operators Box/Diamond
  - In FlagBFMCS: quantify over flags in bundle
  - In WorldHistory: quantify over histories in bundle

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/CanonicalTaskFrame.lean` - Add truth preservation

**Verification**:
- [ ] Truth preservation theorem is sorry-free
- [ ] Full file builds without errors

---

### Phase 5: Integration and Completeness Verification [NOT STARTED]

**Goal**: Verify end-to-end completeness chain using the semantic bridge

**Tasks**:
- [ ] Verify `temporal_coherent_family_exists_CanonicalMCS` is still sorry-free
- [ ] Connect FlagBFMCS.completeness to WorldHistory semantics via bridge
- [ ] State final completeness theorem in WorldHistory terms:
  - "For any satisfiable formula in WorldHistory semantics, there exists a proof"
- [ ] Document the completeness chain in a summary file

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Semantics/CanonicalTaskFrame.lean` - Final theorem
- Create summary: `specs/1004.../summaries/02_semantic-bridge-summary.md`

**Verification**:
- [ ] No new sorries introduced
- [ ] Completeness chain is traceable

---

## Testing & Validation

- [ ] `lake build Bimodal.Semantics.CanonicalTaskFrame` passes without errors
- [ ] Grep for `sorry` in new file returns zero
- [ ] IntBFMCS.lean F/P sorries have limitation documentation
- [ ] Dependent tasks (988, 997) remain unaffected (they use CanonicalFMCS, not IntBFMCS)

## Success Criteria

1. **IntBFMCS F/P sorries documented**: Comments explain why they're fundamental limitations
2. **Semantic bridge defined**: CanonicalTaskFrame with Flag-to-History embedding
3. **Truth preservation proven**: Metalogic satisfaction iff WorldHistory truth
4. **No regression**: Existing sorry-free proofs remain sorry-free

## Artifacts & Outputs

- `specs/1004_dovetailing_chain_fp_witnesses/plans/02_semantic-bridge-plan.md` (this file)
- `Theories/Bimodal/Semantics/CanonicalTaskFrame.lean` (new file)
- Modified `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (documentation only)
- `specs/1004_dovetailing_chain_fp_witnesses/summaries/02_semantic-bridge-summary.md` (on completion)

## Relationship to Other Tasks

| Task | Relationship |
|------|--------------|
| Task 1003 (FlagBFMCS) | Provides FlagBFMCS infrastructure this plan uses |
| Task 997 (base completeness) | Uses CanonicalFMCS; unaffected by this task |
| Task 988 (dense completeness) | Uses CanonicalFMCS; unaffected by this task |
| Task 995 (domain transfer) | Separate concern; Int-indexing is optional |

## Future Work (Out of Scope)

- **Int/Rat Domain Transfer**: If computational Int/Rat models are needed, create a separate task for domain transfer from CanonicalMCS to Int/Rat. This is optional for completeness but may be useful for decidability/FMP applications.

- **Remove IntBFMCS**: If IntBFMCS is confirmed unnecessary for any active path, consider moving to Boneyard to reduce maintenance burden.

## Rollback/Contingency

If the semantic bridge proves more complex than anticipated:
1. Phase 1 (documentation) stands alone and is always useful
2. Phases 2-5 can be deferred without affecting other completeness work
3. CanonicalFMCS completeness works independently of the bridge
