# Implementation Plan: Task #588

- **Task**: 588 - Complete Truth Lemma in Metalogic_v2
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None (self-contained lemma proof)
- **Research Inputs**: specs/588_complete_truth_lemma_metalogic_v2/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete the single remaining sorry in TruthLemma.lean by proving `necessitation_lemma`. The proof requires establishing that any theorem derivable from an empty context is contained in every maximal consistent set (MCS). Research identified a need for a `theorem_in_mcs` helper lemma (specialized case of `set_mcs_closed_under_derivation` from old Metalogic). The approach is to prove this helper and then use it to complete `necessitation_lemma`.

### Research Integration

Research report (research-001.md) confirmed:
- Only 1 sorry exists in TruthLemma.lean (line 160, `necessitation_lemma`)
- Proof requires: `ContextDerivable [] phi` implies `box phi in w.carrier`
- Key dependency: Need `theorem_in_mcs` to bridge derivation to MCS membership
- Recommended Option B: Prove specialized `theorem_in_mcs` for theorems (faster than full port)

## Goals & Non-Goals

**Goals**:
- Prove `necessitation_lemma` in TruthLemma.lean
- Create helper lemma `theorem_in_mcs` in MaximalConsistent.lean or CanonicalModel.lean
- Achieve zero sorries in TruthLemma.lean
- Maintain compilation of downstream files (RepresentationTheorem.lean)

**Non-Goals**:
- Porting the full `set_mcs_closed_under_derivation` lemma (not needed for this task)
- Modifying other files beyond TruthLemma.lean and MaximalConsistent.lean/CanonicalModel.lean
- Adding new dependencies or imports

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type mismatch between List and Set | Medium | Medium | Use existing bridge lemmas in MaximalConsistent.lean |
| Deduction theorem complexity | Low | Low | Already proven in Metalogic_v2 |
| Circular import | Low | Low | Place helper in MaximalConsistent.lean (already imported) |
| CanonicalWorldState extraction | Low | Medium | Review structure and use appropriate field accessors |

## Implementation Phases

### Phase 1: Add theorem_in_mcs Helper [COMPLETED]

**Goal**: Create the helper lemma that proves theorems are in every MCS

**Tasks**:
- [ ] Review existing MCS infrastructure in MaximalConsistent.lean (lines 90-95, 400-423)
- [ ] Review SetConsistent and SetMaximalConsistent definitions
- [ ] Implement `theorem_in_mcs` lemma with signature:
  ```lean
  theorem theorem_in_mcs {S : Set Formula} {phi : Formula}
      (h_mcs : SetMaximalConsistent S)
      (h_deriv : DerivationTree [] phi) : phi in S
  ```
- [ ] Proof approach: by contradiction using MCS consistency
  - Assume `phi not in S`
  - By maximality, `phi.neg in S` or `S union {phi}` is inconsistent
  - But `[] |- phi` means any finite subset containing `phi` can derive anything
  - This contradicts S being consistent
- [ ] Verify lemma compiles without errors

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - Add `theorem_in_mcs` lemma

**Verification**:
- `lake build Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` succeeds
- No new sorries introduced

---

### Phase 2: Complete necessitation_lemma [COMPLETED]

**Goal**: Use the helper to prove necessitation_lemma

**Tasks**:
- [ ] Review current necessitation_lemma structure (TruthLemma.lean lines 155-160)
- [ ] Unwrap `ContextDerivable [] phi` to get `DerivationTree [] phi`
- [ ] Apply `DerivationTree.necessitation` to get `DerivationTree [] (Formula.box phi)`
- [ ] Extract `w.carrier` and show it satisfies `SetMaximalConsistent`
- [ ] Apply `theorem_in_mcs` with `box phi` and the MCS property
- [ ] Remove sorry and verify proof compiles

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean` - Complete `necessitation_lemma`

**Verification**:
- `lake build Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean` succeeds
- No sorries remain in TruthLemma.lean

---

### Phase 3: Verify Downstream Files [COMPLETED]

**Goal**: Ensure changes don't break downstream dependencies

**Tasks**:
- [ ] Build RepresentationTheorem.lean (imports TruthLemma)
- [ ] Build full Metalogic_v2 directory
- [ ] Check for any sorry count changes in related files
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic_v2/Representation/` to verify

**Timing**: 15 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean`
- All files in `Theories/Bimodal/Metalogic_v2/`

**Verification**:
- `lake build Theories.Bimodal.Metalogic_v2` succeeds
- RepresentationTheorem.lean compiles without errors
- Sorry count in Representation/ directory is zero

---

## Testing & Validation

- [ ] `lake build` succeeds for MaximalConsistent.lean
- [ ] `lake build` succeeds for TruthLemma.lean
- [ ] Zero sorries in TruthLemma.lean (`grep -n "sorry" TruthLemma.lean` returns empty)
- [ ] RepresentationTheorem.lean still compiles
- [ ] No new sorries introduced anywhere in Metalogic_v2/Representation/

## Artifacts & Outputs

- `specs/588_complete_truth_lemma_metalogic_v2/plans/implementation-001.md` (this file)
- Modified: `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` (new lemma)
- Modified: `Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean` (sorry removed)
- `specs/588_complete_truth_lemma_metalogic_v2/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the approach fails:
1. Revert changes to MaximalConsistent.lean and TruthLemma.lean
2. Consider Option A from research: full port of `set_mcs_closed_under_derivation`
3. Consider Option C: Direct inline proof without helper lemma
4. If fundamentally blocked, document the blocker and mark task as blocked
