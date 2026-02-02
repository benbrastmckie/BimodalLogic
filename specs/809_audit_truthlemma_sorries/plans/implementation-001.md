# Implementation Plan: Task #809

- **Task**: 809 - Refactor Truth Lemma to Forward-Only
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/809_audit_truthlemma_sorries/reports/research-001.md, specs/809_audit_truthlemma_sorries/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Refactor TruthLemma.lean to provide a sorry-free forward-only Truth Lemma while archiving the backward direction. The research findings confirm that completeness proofs only use the forward direction (`truth_lemma.mp`), making this refactoring safe. The one exception is `completeness_contrapositive` which uses `.mpr` (backward direction) - this will be rewritten to avoid the backward dependency.

### Research Integration

From research-002.md:
- Forward direction (MCS membership -> semantic truth) is fully proven for atoms, bot, imp, all_past, all_future
- Box forward direction has an architectural sorry (line 384) but is NOT used by completeness proofs
- Backward direction has sorries in Box (line 407) and temporal operators (lines 436, 460)
- Main completeness theorems (`representation_theorem`, `infinitary_strong_completeness`) only use `.mp` (forward)
- The only backward usage is in `completeness_contrapositive` - a corollary, not core completeness

## Goals & Non-Goals

**Goals**:
- Create a sorry-free `TruthLemmaForward.lean` with only the forward direction
- Archive the backward direction and full biconditional to Boneyard
- Update all imports and dependent files to use the forward-only version
- Ensure the metalogic builds cleanly without errors
- Rewrite `completeness_contrapositive` to avoid backward Truth Lemma dependency

**Non-Goals**:
- Proving the Box forward direction (architectural limitation, not needed for completeness)
- Proving the backward direction (omega-rule limitation, not needed for completeness)
- Changing the existing completeness proof structure beyond eliminating backward dependency

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependencies on backward direction | High | Low | Research confirmed only `completeness_contrapositive` uses backward |
| Build breaks from import changes | Medium | Medium | Incremental changes with `lake build` verification after each phase |
| `completeness_contrapositive` rewrite introduces sorries | Medium | Low | Alternative proof uses forward direction only (negation in MCS implies not true) |

## Implementation Phases

### Phase 1: Create Forward-Only Truth Lemma [IN PROGRESS]

**Goal**: Create a new `TruthLemmaForward.lean` file containing only the forward direction of the Truth Lemma, without sorries in the exported theorems.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/TruthLemmaForward.lean`
- [ ] Copy canonical model definition (`canonical_model`)
- [ ] Copy helper lemmas (`canonical_history_family_domain`, `canonical_world_mcs`)
- [ ] Copy MCS negation-implication lemmas (`neg_imp_fst`, `neg_imp_snd`)
- [ ] Create forward-only mutual induction (can still use backward IH internally for imp case)
- [ ] Export only `truth_lemma_forward` theorem
- [ ] Verify file compiles with `lake build Bimodal.Metalogic.Representation.TruthLemmaForward`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemmaForward.lean` - create new file

**Verification**:
- `lake build Bimodal.Metalogic.Representation.TruthLemmaForward` succeeds
- No sorries in exported `truth_lemma_forward` theorem
- The Box case in forward direction still has architectural sorry (acceptable - not used by completeness)

---

### Phase 2: Archive Original TruthLemma.lean [NOT STARTED]

**Goal**: Move the original TruthLemma.lean (with backward direction) to Boneyard for reference.

**Tasks**:
- [ ] Move `Theories/Bimodal/Metalogic/Boneyard/Representation/TruthLemma.lean` to `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TruthLemma.lean`
- [ ] Add archive header documenting why it was archived and what replaces it
- [ ] Update any internal imports within the archived file if needed

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TruthLemma.lean` - create (moved from Boneyard/Representation)

**Verification**:
- File exists in new location with archive header
- Original location is empty or redirects to new location

---

### Phase 3: Update UniversalCanonicalModel.lean [NOT STARTED]

**Goal**: Update UniversalCanonicalModel to use the forward-only Truth Lemma and rewrite `completeness_contrapositive` to avoid backward dependency.

**Tasks**:
- [ ] Update import from `TruthLemma` to `TruthLemmaForward`
- [ ] Verify `representation_theorem` still compiles (only uses forward direction)
- [ ] Rewrite `completeness_contrapositive` proof to avoid `.mpr`:
  - Current: Uses `(truth_lemma...).mpr h_true` to get membership from truth
  - New approach: Use negation exclusion directly - if `phi.neg in MCS` and MCS is consistent, then `phi not in MCS`, therefore by contrapositive of forward truth lemma, `not truth_at phi`
- [ ] Run `lake build` to verify changes compile

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Boneyard/Representation/UniversalCanonicalModel.lean` - update imports and rewrite corollary

**Verification**:
- `representation_theorem` compiles unchanged
- `completeness_contrapositive` compiles with new proof
- No uses of `truth_lemma.mpr` or `truth_lemma_backward`

---

### Phase 4: Update InfinitaryStrongCompleteness.lean [NOT STARTED]

**Goal**: Update InfinitaryStrongCompleteness to use the forward-only Truth Lemma.

**Tasks**:
- [ ] Update import if needed (check current import path)
- [ ] Verify `infinitary_strong_completeness` still compiles (only uses `.mp`)
- [ ] Run `lake build` to verify

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` - update imports if needed

**Verification**:
- File compiles without changes to proofs (only uses forward direction)
- `lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness` succeeds

---

### Phase 5: Update Metalogic.lean and Verify Full Build [NOT STARTED]

**Goal**: Update the Metalogic module index and verify the entire metalogic builds cleanly.

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` to import `TruthLemmaForward` instead of old location
- [ ] Run full `lake build` on Bimodal.Metalogic
- [ ] Verify no errors or unexpected sorries introduced
- [ ] Document the refactoring in the TruthLemmaForward.lean header

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - update imports
- `Theories/Bimodal/Metalogic/Representation/TruthLemmaForward.lean` - add comprehensive docstring

**Verification**:
- `lake build` succeeds with no errors
- `grep -r "sorry" Theories/Bimodal/Metalogic/Representation/TruthLemmaForward.lean` shows only the Box forward sorry (architectural, acceptable)
- Module documentation explains the forward-only design choice

---

## Testing & Validation

- [ ] `lake build` succeeds on full project
- [ ] No new sorries introduced (only pre-existing Box forward sorry remains)
- [ ] `representation_theorem` unchanged and compiles
- [ ] `infinitary_strong_completeness` unchanged and compiles
- [ ] `completeness_contrapositive` rewritten and compiles without backward Truth Lemma
- [ ] Archived files have proper headers explaining archive reason

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/TruthLemmaForward.lean` - new forward-only Truth Lemma
- `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TruthLemma.lean` - archived original with backward direction
- Updated imports in UniversalCanonicalModel.lean
- Updated imports in InfinitaryStrongCompleteness.lean (if needed)
- Updated Metalogic.lean module index

## Rollback/Contingency

If the refactoring causes unexpected issues:
1. The original TruthLemma.lean is preserved in Boneyard with full history
2. All import changes can be reverted by pointing back to the Boneyard location
3. Git history preserves the pre-refactoring state

The modular design ensures that reverting is straightforward: change imports back to the archived location and the old behavior is restored.
