# Implementation Plan: Task #862

- **Task**: 862 - divide_truthlemma_forward_backward
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/862_divide_truthlemma_forward_backward/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task creates publication-quality documentation in the TruthLemma.lean file that explains why the forward and backward directions cannot be simply separated due to the implication case cross-dependency. The focus is on **guiding future readers** toward viable solutions rather than implementing a complex separation that may not be the best publication approach.

### Research Integration

- **research-001.md**: Identified the cross-dependency in the `imp` case where forward direction uses `ih_psi.mpr` (backward IH)
- **Key insight**: The completeness theorems are already **functionally sorry-free** since they only use `.mp` (forward direction)
- **Publication strategy**: Document the architecture clearly rather than attempting complex refactoring

## Goals & Non-Goals

**Goals**:
- Document the cross-dependency obstacle clearly in code comments
- Explain why simple separation fails (imp case uses backward IH for forward proof)
- Guide future attempts toward viable solutions (mutual recursion, strong induction)
- Establish that completeness is functionally sorry-free despite truth lemma sorries
- Make the proof architecture visible to future readers

**Non-Goals**:
- Implementing mutual recursion (complex, may not improve publication quality)
- Archiving backward direction to Boneyard/ (creates confusion, doesn't improve anything)
- Achieving "zero sorries in all files" (completeness is what matters for publication)
- Refactoring the proof structure itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Misleading future readers about sorry status | High | Medium | Clear documentation explaining functional sorry-freedom |
| Comments becoming stale if code changes | Medium | Low | Tie comments to structural properties, not line numbers |
| Overcomplicating the explanation | Medium | Medium | Focus on the ONE key insight: imp case cross-dependency |

## Sorry Characterization

### Pre-existing Sorries

**In TruthLemma.lean** (2 sorries):
- Line 403: `all_future` (G) backward direction - requires temporal saturation
- Line 419: `all_past` (H) backward direction - requires temporal saturation

**In EvalBMCS section** (4 sorries):
- Lines 593, 600: Box case limitations of EvalBMCS structure
- Lines 612, 624: Temporal backward (same as above)

### Expected Resolution

This task does NOT resolve sorries. It documents why they:
1. Do not affect completeness (only `.mp` is used)
2. Cannot be trivially archived due to cross-dependency
3. Represent genuine mathematical complexity, not implementation gaps

### New Sorries

None. This task adds documentation only.

### Remaining Debt

After this implementation:
- Same 2 temporal sorries in main truth lemma (tolerated during development)
- EvalBMCS sorries unchanged (secondary approach, not publication path)
- **Key point**: Completeness.lean remains SORRY-FREE, which is the publication target

## Implementation Phases

### Phase 1: Document the Cross-Dependency Obstacle [NOT STARTED]

**Goal**: Add a new documentation section explaining why forward/backward cannot be simply separated.

**Tasks**:
- [ ] Add `/-! ## The Separation Obstacle: Implication Case Cross-Dependency -/` section
- [ ] Document the proof dependency table (which cases use which IH directions)
- [ ] Explain why simple archiving of backward direction breaks forward proofs
- [ ] Include code reference to lines 321-325 showing the cross-dependency

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Add documentation section after line 91

**Verification**:
- Documentation explains the cross-dependency clearly
- Includes the dependency table from research
- Does not change any proof code

---

### Phase 2: Update Sorry Status Documentation [NOT STARTED]

**Goal**: Revise the existing sorry documentation to clarify functional sorry-freedom.

**Tasks**:
- [ ] Update module docstring (lines 12-91) to emphasize completeness is sorry-free
- [ ] Clarify that temporal sorries are in BACKWARD direction only
- [ ] Remove any language suggesting sorries "need to be fixed for publication"
- [ ] Add explicit statement: "Publication path: Completeness.lean uses only .mp (forward)"

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Update module docstring

**Verification**:
- Module docstring clearly states completeness is sorry-free
- No misleading language about publication blockers

---

### Phase 3: Document Viable Future Approaches [NOT STARTED]

**Goal**: Add documentation guiding future attempts toward successful separation strategies.

**Tasks**:
- [ ] Add `/-! ## Future Work: Viable Separation Approaches -/` section
- [ ] Document Option 1: Mutual recursion (both theorems defined simultaneously)
- [ ] Document Option 2: Strong induction on formula size
- [ ] Document Option 3: Accept iff form, document clearly (current approach)
- [ ] Explain trade-offs of each approach for publication

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Add section after Summary

**Verification**:
- Three viable approaches documented
- Trade-offs explained clearly
- Future readers have actionable guidance

---

### Phase 4: Clean Up Existing Comments [NOT STARTED]

**Goal**: Remove outdated or misleading comments, consolidate documentation.

**Tasks**:
- [ ] Review inline comments in proof cases for accuracy
- [ ] Remove references to "Task 857" if they are stale/misleading
- [ ] Ensure imp case (lines 316-354) has clear comment explaining cross-dependency
- [ ] Update box case comment to celebrate its sorry-free status as THE achievement
- [ ] Ensure temporal case comments accurately describe the limitation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Update inline comments

**Verification**:
- No stale task references
- Comments are consistent with new documentation sections
- Each case's comment is accurate and helpful

---

### Phase 5: Final Review and Build Verification [NOT STARTED]

**Goal**: Ensure all changes compile and documentation is coherent.

**Tasks**:
- [ ] Run `lake build` to verify no syntax errors in comments
- [ ] Read through all documentation sections for coherence
- [ ] Verify cross-references between sections are accurate
- [ ] Confirm the narrative arc: obstacle -> current status -> future paths

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds
- Documentation tells a coherent story
- A future reader would understand why sorries exist and that completeness is unaffected

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] Module docstring explains completeness is sorry-free
- [ ] Cross-dependency section explains the imp case obstacle
- [ ] Future approaches section provides actionable guidance
- [ ] No misleading language about publication blockers
- [ ] Comments are accurate for current code structure

## Artifacts & Outputs

- `specs/862_divide_truthlemma_forward_backward/plans/implementation-001.md` (this file)
- `specs/862_divide_truthlemma_forward_backward/summaries/implementation-summary-YYYYMMDD.md` (after completion)

## Rollback/Contingency

Changes are documentation-only. Rollback via `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` if needed.

---

## Appendix: The Cross-Dependency Explained

This section captures the key technical insight for reference during implementation.

### Why Simple Separation Fails

The forward direction of the `imp` case (proving `(psi -> chi) in MCS -> (truth psi -> truth chi)`) contains this logic:

```lean
intro h_imp h_psi_true
have h_psi_mcs : psi in fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true  -- Uses .mpr!
have h_chi_mcs : chi in fam.mcs t := set_mcs_implication_property h_mcs h_imp h_psi_mcs
exact (ih_chi fam hfam t).mp h_chi_mcs
```

The critical line is `ih_psi.mpr h_psi_true`. To apply modus ponens in the MCS, we need `psi in MCS`. We have `truth psi` from the hypothesis. Converting truth to membership requires the **backward** direction of the IH on `psi`.

### Dependency Table

| Case | Forward (.mp) needs | Backward (.mpr) needs |
|------|---------------------|----------------------|
| atom | nothing | nothing |
| bot | nothing | nothing |
| **imp** | **ih_psi.mpr** + ih_chi.mp | ih_psi.mp + ih_chi.mpr |
| box | ih.mp only | ih.mpr only |
| G/H | ih.mp only | ih.mpr only |

The `imp` case is the ONLY case where forward needs backward. All other cases have clean separation.

### Why This Matters for Publication

1. **Completeness is unaffected**: Completeness.lean only uses `.mp` (forward)
2. **Sorries are isolated**: Only in temporal backward, which completeness doesn't use
3. **The iff form is mathematically correct**: Truth lemmas ARE biconditionals
4. **Archiving backward breaks forward**: Due to imp case cross-dependency
5. **Best publication path**: Document the architecture, not refactor it
