# Implementation Plan: Task #945 (v2)

- **Task**: 945 - Design canonical model construction for TruthLemma
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (supersedes implementation-001.md)
- **Research Inputs**: research-005.md (step-by-step construction, D=Z), research-006.md (direct TruthLemma, bmcs_truth_at redundancy)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the direct canonical model construction for the TruthLemma, based on research-005 and research-006 findings. The key insight from research-006 is that `bmcs_truth_at` is structurally redundant -- it duplicates `truth_at` exactly when canonical definitions are chosen correctly. Therefore, we prove the TruthLemma directly at the `truth_at` level without the intermediate, producing a cleaner architecture.

The construction uses D = Z (integers) as the canonical duration group, with WorldState = MCS (maximal consistent sets), and proves truth preservation by induction on formula structure.

### Research Integration

**From research-005**:
- D = Z is correct for completeness (the existential witness)
- Step-by-step construction produces Z-indexed timelines
- Canonical TaskFrame: WorldState = MCS, task_rel from CanonicalR
- Bridge theorem connects BFMCS truth to TaskFrame truth

**From research-006** (CRITICAL):
- `bmcs_truth_at` is structurally redundant -- definitionally identical to `truth_at`
- The bridge theorem is trivial; therefore eliminate the intermediate entirely
- `task_rel` does NOT appear in `truth_at` -- compositionality is a separate concern
- ShiftClosed is NOT needed for the TruthLemma (only for standard validity connection)
- Direct approach: prove TruthLemma at `truth_at` level directly

## Goals & Non-Goals

**Goals**:
- Define CanonicalTaskFrame with WorldState = MCS
- Define CanonicalTaskModel with valuation = MCS membership
- Define to_history conversion from FMCS to WorldHistory
- Define CanonicalOmega as the set of world-histories from bundle families
- Prove canonical_truth_lemma directly at the truth_at level
- Achieve zero sorries in all new code

**Non-Goals**:
- Proving compositionality of task_rel (can be done separately; not needed for TruthLemma)
- Proving ShiftClosed for CanonicalOmega (not needed for TruthLemma; needed later for validity)
- Removing or deprecating existing BFMCSTruth.lean (keep as reference)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Domain existential overhead in atom case | Low | High | Use helper lemma `truth_at_atom_of_full_domain` with trivial True.intro |
| Compositionality cross-sign cases complex | Medium | Medium | task_rel not used in truth_at; defer to separate task |
| Modal backward requires BFMCS modal_backward | Medium | Low | Already implemented in existing BFMCS infrastructure |
| Temporal backward requires forward_F from h_tc | Medium | Low | Already implemented in TemporalCoherentConstruction.lean |

## Sorry Characterization

### Pre-existing Sorries
- None in scope for this task (new file creation)

### Expected Resolution
- No sorries will be introduced
- All cases of the inductive proof will be completed

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in CanonicalConstruction.lean
- Compositionality of CanonicalTaskFrame may be deferred (separate concern)

## Implementation Phases

### Phase 1: Define Canonical Structures [NOT STARTED]

- **Dependencies:** None
- **Goal:** Define CanonicalTaskFrame, CanonicalTaskModel, to_history, and CanonicalOmega

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- [ ] Define `CanonicalWorldState := { M : Set Formula // SetMaximalConsistent M }`
- [ ] Define `CanonicalTaskFrame : TaskFrame Int` with:
  - WorldState := CanonicalWorldState
  - task_rel using GContent/HContent coherence conditions
  - nullity via T-axiom reflexivity (canonicalR_reflexive)
  - compositionality: use sorry if needed (separate concern per research-006)
- [ ] Define `CanonicalTaskModel : TaskModel CanonicalTaskFrame` with valuation = MCS membership
- [ ] Define `to_history (fam : FMCS Int) : WorldHistory CanonicalTaskFrame`
  - domain := fun _ => True (full domain)
  - states := fun t _ => (fam.mcs t, fam.is_mcs t)
  - respects_task via fam.forward_G
- [ ] Define `CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame)`
  - `{ tau | exists fam in B.families, tau = to_history fam }`

**Timing:** 1.5-2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (new file)

**Verification:**
- `lake build` passes
- All definitions type-check
- `grep -n "\bsorry\b" CanonicalConstruction.lean` returns only compositionality (if deferred)

---

### Phase 2: Prove TruthLemma Base Cases [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove atom and bot cases of canonical_truth_lemma

**Tasks:**
- [ ] State the main theorem:
  ```lean
  theorem canonical_truth_lemma
      (B : BFMCS Int) (h_tc : B.temporally_coherent)
      (fam : FMCS Int) (hfam : fam in B.families)
      (t : Int) (phi : Formula) :
      phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
  ```
- [ ] Prove atom case:
  - Forward: atom p in fam.mcs t -> exists ht, M.valuation (tau.states t ht) p
  - Use True.intro for domain proof, definition of valuation
  - Backward: symmetric
- [ ] Prove bot case:
  - Forward: bot in fam.mcs t -> False (MCS consistency)
  - Backward: False -> anything

**Timing:** 0.5-1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

**Verification:**
- atom_case and bot_case complete without sorry
- `lean_goal` shows no goals at end of each case

---

### Phase 3: Prove TruthLemma Imp Case [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove implication case of canonical_truth_lemma

**Tasks:**
- [ ] Prove imp case by IH:
  - Forward: (phi -> psi) in MCS and truth_at phi -> truth_at psi
    - By IH backward: phi in MCS
    - By MCS modus ponens: psi in MCS
    - By IH forward: truth_at psi
  - Backward: truth_at phi -> truth_at psi implies (phi -> psi) in MCS
    - By contraposition: assume neg(phi -> psi) in MCS
    - Derive phi in MCS and neg(psi) in MCS
    - By IH forward: truth_at phi
    - By hypothesis: truth_at psi
    - By IH backward: psi in MCS
    - Contradiction with neg(psi) in MCS

**Timing:** 0.5-1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

**Verification:**
- imp_case complete without sorry
- Uses existing MCS lemmas (modus_ponens_mcs, maximality)

---

### Phase 4: Prove TruthLemma Box Case [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove modal box case of canonical_truth_lemma

**Tasks:**
- [ ] Prove box case:
  - Forward: box phi in fam.mcs t -> forall sigma in Omega, truth_at sigma t phi
    - Let sigma in CanonicalOmega, so sigma = to_history fam' for some fam' in B.families
    - By B.modal_forward: phi in fam'.mcs t
    - By IH: truth_at (to_history fam') t phi
  - Backward: forall sigma in Omega, truth_at sigma t phi -> box phi in MCS
    - For each fam' in B.families, truth_at (to_history fam') t phi
    - By IH backward: phi in fam'.mcs t
    - By B.modal_backward: box phi in fam.mcs t
- [ ] Verify BFMCS modal_forward and modal_backward are correctly used

**Timing:** 1-1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

**Verification:**
- box_case complete without sorry
- Uses B.modal_forward, B.modal_backward from BFMCS.lean

---

### Phase 5: Prove TruthLemma Temporal Cases [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Prove all_future (G) and all_past (H) cases of canonical_truth_lemma

**Tasks:**
- [ ] Prove all_future case (G phi):
  - Forward: G phi in fam.mcs t -> forall s >= t, truth_at tau s phi
    - By fam.forward_G: phi in fam.mcs s for all s >= t
    - By IH: truth_at tau s phi
  - Backward: forall s >= t, truth_at tau s phi -> G phi in fam.mcs t
    - By IH backward: phi in fam.mcs s for all s >= t
    - By contraposition: assume neg(G phi) = F(neg phi) in MCS
    - By h_tc.forward_F: exists s >= t with neg(phi) in fam.mcs s
    - Contradiction with phi in fam.mcs s
- [ ] Prove all_past case (H phi):
  - Symmetric to all_future using backward_H and backward_P
- [ ] Verify temporal coherence conditions from h_tc are correctly used

**Timing:** 1.5-2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

**Verification:**
- all_future_case and all_past_case complete without sorry
- Uses fam.forward_G, h_tc.forward_F, etc.

---

### Phase 6: Integration and Verification [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Assemble complete theorem, verify zero-debt, add completeness corollary

**Tasks:**
- [ ] Combine all cases into single proof by induction on phi
- [ ] Add corollary: canonical_completeness connecting to semantic_consequence
  ```lean
  theorem canonical_completeness (phi : Formula) :
      not provable phi -> not valid phi
  ```
- [ ] Update imports in Completeness.lean if needed
- [ ] Verify `lake build` passes
- [ ] Verify `grep -n "\bsorry\b" CanonicalConstruction.lean` returns empty (or only compositionality)
- [ ] Document compositionality as separate task if deferred

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (optional import update)

**Verification:**
- `lake build` passes with no errors
- `grep -n "\bsorry\b" CanonicalConstruction.lean` returns empty (zero-debt gate)
- `grep -n "^axiom " CanonicalConstruction.lean` shows no new axioms
- All proofs verified with `lean_goal` showing "no goals"

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] canonical_truth_lemma correctly stated with all hypotheses
- [ ] Uses standard truth_at from Truth.lean (not bmcs_truth_at)
- [ ] CanonicalOmega defined correctly as image of bundle families

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (new file)
- `specs/945_canonical_model_construction_design/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails:
- New file CanonicalConstruction.lean can be deleted without affecting existing code
- Existing bmcs_truth_lemma and BFMCSTruth.lean remain functional
- If specific case is stuck, mark [BLOCKED] for user review before using sorry
