# Implementation Plan: Task #910

- **Task**: 910 - Phase 4: Canonical Model Reconstruction
- **Status**: [COMPLETED]
- **Effort**: 4.5 hours
- **Dependencies**: Tasks 907, 908 (completed), Task 909 (in progress but independent)
- **Research Inputs**: specs/910_phase4_canonical_model_reconstruction/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan reconstructs `Theories/Bimodal/Metalogic/Representation.lean` to implement Choice B from the parent task 906: non-constant families with time-indexed truth lemma (`fam.mcs t` at time `t`). The reconstruction removes constant-family infrastructure, generalizes CanonicalWorldState, defines canonicalOmega (without shift-closure), and reproves the truth lemma with the Box forward case properly handled. This eliminates 2 sorries directly (constant_family_bmcs_exists_int and Box forward) while addressing the Omega-mismatch issue discovered in research.

### Research Integration

Key findings from research-001.md:
1. Task 910 can proceed independently of task 909 (no shared file dependencies)
2. `canonicalOmega` does NOT need shift-closure - only needed for soundness
3. Box forward case is fixed by restricting quantification to sigma in canonicalOmega
4. Omega-mismatch between `valid` (Set.univ) and `satisfiable` (canonicalOmega) requires careful handling in completeness theorems
5. Time-varying states use `fam.mcs t` directly at time `t`, simplifying the atom case

## Goals & Non-Goals

**Goals**:
- Remove all constant-family infrastructure (IsConstantFamilyBMCS, getConstantBMCS, h_const parameters)
- Generalize CanonicalWorldState to allow any MCS at any time
- Redefine canonicalHistory with time-varying states (`fam.mcs t` at time `t`)
- Define canonicalOmega as the set of canonical histories (unshifted)
- Reprove truth lemma with `fam.mcs t` anchor and canonicalOmega quantification
- Fix Box forward case sorry (line 229)
- Update completeness theorems with new API

**Non-Goals**:
- Adding shift-closure to canonicalOmega (not needed)
- Modifying Truth.lean or Validity.lean (handled by other tasks)
- Resolving the Omega-mismatch in weak/strong completeness (may require follow-up task)
- Eliminating sorries inherited from TemporalCoherentConstruction.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Omega-mismatch breaks weak/strong completeness | High | High | Document with sorry and clear TODO; create follow-up task for Validity.lean changes |
| Temporal cases need h_const-like reasoning | Medium | Low | Research confirms temporal coherence (forward_F, backward_P) suffices without h_const |
| Type errors cascade during reconstruction | Medium | Medium | Implement phases incrementally; build after each phase |
| Box backward case needs modal saturation | Low | Low | BMCS structure provides modal_backward as a field; no explicit h_ms needed |

## Sorry Characterization

### Pre-existing Sorries (in Representation.lean)
- Line 94-95: `constant_family_bmcs_exists_int` - sorry-backed existence theorem
- Line 229: Box forward case of `canonical_truth_lemma_all` - technical gap in quantification

### Expected Resolution
- `constant_family_bmcs_exists_int`: **ELIMINATED** - entire constant-family infrastructure removed
- Box forward case (line 229): **FIXED** - canonicalOmega restricts quantification to canonical histories where IH applies

### New Sorries
- Omega-mismatch in weak/strong completeness: tolerated during development with clear documentation. Remediation requires coordinated change to Validity.lean `valid` definition (follow-up task).

### Remaining Debt
After this implementation:
- 0 new sorries from Box case or constant-family infrastructure
- Inherited sorries from `fully_saturated_bmcs_exists_int` in TemporalCoherentConstruction.lean (replaces constant_family_bmcs_exists_int - same debt, different location)
- Potential sorry for Omega-mismatch in completeness theorems (requires Validity.lean coordination)

## Implementation Phases

### Phase 1: Remove Constant-Family Infrastructure [COMPLETED]

- **Dependencies:** None
- **Goal:** Remove all constant-family definitions and accessors (lines 78-115)

**Tasks**:
- [ ] Delete `IsConstantFamilyBMCS` definition (line 78-79)
- [ ] Delete `constant_family_bmcs_exists_int` sorry-backed theorem (lines 89-95)
- [ ] Delete `getConstantBMCS` noncomputable def (lines 97-99)
- [ ] Delete `getConstantBMCS_contains_context` theorem (lines 101-103)
- [ ] Delete `getConstantBMCS_temporally_coherent` theorem (lines 105-107)
- [ ] Delete `getConstantBMCS_modally_saturated` theorem (lines 109-111)
- [ ] Delete `getConstantBMCS_is_constant` theorem (lines 113-115)
- [ ] Update module docstring to remove references to constant families

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean` (delete lines 78-115, update docstring)

**Verification**:
- Code deletion complete (approximately 38 lines removed)
- Module docstring accurately reflects new approach

**Progress:**

**Session: 2026-02-19, sess_1771543349_9bd3bd**
- Removed: `IsConstantFamilyBMCS`, `constant_family_bmcs_exists_int`, `getConstantBMCS` and 4 accessor theorems
- Removed: All constant-family infrastructure (38 lines)
- Completed: All Phase 1 objectives
- Sorries: 3 -> 2 (eliminated `constant_family_bmcs_exists_int`)

---

### Phase 2: Generalize Canonical Definitions [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update CanonicalWorldState, mkCanonicalWorldState, and canonicalHistory for time-varying states

**Tasks**:
- [ ] Redefine `CanonicalWorldState` as `{ S : Set Formula // SetMaximalConsistent S }`
- [ ] Update `mkCanonicalWorldState` to accept time parameter `t`:
  ```lean
  def mkCanonicalWorldState (B : BMCS Int) (fam : IndexedMCSFamily Int) (t : Int) :
      CanonicalWorldState B :=
    ⟨fam.mcs t, fam.is_mcs t⟩
  ```
- [ ] Update `canonicalHistory` to use time-varying states:
  ```lean
  def canonicalHistory (B : BMCS Int) (fam : IndexedMCSFamily Int) (hfam : fam ∈ B.families) :
      WorldHistory (canonicalFrame B) where
    domain := fun _ => True
    convex := ...
    states := fun t _ => mkCanonicalWorldState B fam t
    respects_task := ...
  ```
- [ ] Update `canonicalHistory_states_val` to show `.val = fam.mcs t` (proof remains `rfl`)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean` (lines 117-148)

**Verification**:
- `canonicalHistory_states_val` compiles with `rfl` proof
- `mkCanonicalWorldState` accepts time parameter
- `canonicalHistory.states t ht` has type `CanonicalWorldState B` with `.val = fam.mcs t`

---

### Phase 3: Define canonicalOmega [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Define the set of admissible histories and membership lemma

**Tasks**:
- [ ] Define `canonicalOmega`:
  ```lean
  def canonicalOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
    { sigma | ∃ fam (hfam : fam ∈ B.families), sigma = canonicalHistory B fam hfam }
  ```
- [ ] Prove membership helper:
  ```lean
  theorem canonicalHistory_mem_canonicalOmega (B : BMCS Int) (fam : IndexedMCSFamily Int)
      (hfam : fam ∈ B.families) :
      canonicalHistory B fam hfam ∈ canonicalOmega B :=
    ⟨fam, hfam, rfl⟩
  ```
- [ ] Add brief documentation explaining canonicalOmega is NOT shift-closed (by design)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean` (insert after canonicalHistory_states_val)

**Verification**:
- `canonicalOmega` definition compiles
- `canonicalHistory_mem_canonicalOmega` proof compiles
- Build succeeds

---

### Phase 4: Rewrite Truth Lemma [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Reprove canonical_truth_lemma_all with time-indexed anchor and canonicalOmega

**Tasks**:
- [ ] Update signature of `canonical_truth_lemma_all`:
  - Remove `h_const : IsConstantFamilyBMCS B` parameter
  - Change LHS from `fam.mcs 0` to `fam.mcs t`
  - Add `canonicalOmega B` as Omega parameter in `truth_at`
- [ ] Reprove atom case:
  - Forward: `⟨trivial, h_mem⟩` (states returns `fam.mcs t`, membership direct)
  - Backward: Extract from valuation (`.val = fam.mcs t`)
- [ ] Reprove bot case (unchanged structure)
- [ ] Reprove imp case:
  - Use `fam.is_mcs t` instead of `fam.is_mcs 0`
  - IH at `fam.mcs t` gives truth at any time
- [ ] Fix Box forward case (critical):
  - Take `sigma ∈ canonicalOmega B`
  - Extract `sigma = canonicalHistory B fam' hfam'` from membership
  - Apply `B.modal_forward` to get `psi ∈ fam'.mcs t`
  - Apply IH at (fam', t) to get `truth_at ... (canonicalHistory B fam' hfam') t psi`
  - Substitute `sigma = canonicalHistory B fam' hfam'`
- [ ] Verify Box backward case (should work unchanged):
  - For each fam' ∈ B.families, canonicalHistory is in canonicalOmega
  - truth_at gives IH, giving psi ∈ fam'.mcs t
  - Apply B.modal_backward
- [ ] Reprove all_future case:
  - Forward: T-axiom + IH at any time s (fam.mcs s reachable via temporal coherence)
  - Backward: Contraposition using forward_F from temporal coherence
  - Remove h_const usage; use direct MCS membership at fam.mcs s
- [ ] Reprove all_past case (symmetric to all_future)
- [ ] Update `canonical_truth_lemma` wrapper to match new signature

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean` (lines 163-315)

**Verification**:
- `canonical_truth_lemma_all` compiles without sorry in Box forward case
- All cases (atom, bot, imp, box, all_future, all_past) proven
- `lake build` succeeds on file

---

### Phase 5: Update Completeness Theorems [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Update standard_representation and related theorems to use new API

**Tasks**:
- [ ] Update `standard_representation`:
  - Replace `getConstantBMCS` with `construct_saturated_bmcs_int`
  - Remove `h_const` usage
  - Add `canonicalOmega B` and `canonicalHistory_mem_canonicalOmega` to satisfiable witness
  - Note: Import `construct_saturated_bmcs_int` from TemporalCoherentConstruction.lean
- [ ] Update `standard_context_representation` (same changes as above)
- [ ] Update `standard_weak_completeness`:
  - Handle Omega-mismatch: `satisfiable` uses canonicalOmega, `valid` uses Set.univ
  - Options: (a) Use sorry with TODO for Validity.lean coordination, or (b) Prove monotonicity lemma if feasible
  - Document decision clearly in code comments
- [ ] Update `standard_strong_completeness` (same handling as weak_completeness)
- [ ] Update module docstring to reflect new approach

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean` (lines 317-427)

**Verification**:
- All completeness theorems compile
- Omega-mismatch handling documented
- Module docstring accurate

---

### Phase 6: Final Verification [COMPLETED]

- **Dependencies:** Phase 5
- **Goal:** Verify full build and sorry count

**Tasks**:
- [ ] Run `lake build` on entire project
- [ ] Verify Representation.lean compiles without errors
- [ ] Count sorries in Representation.lean (target: 0 or 1 for Omega-mismatch)
- [ ] Verify no regressions in downstream modules
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)
- `specs/910_phase4_canonical_model_reconstruction/summaries/implementation-summary-{DATE}.md` (create)

**Verification**:
- `lake build` succeeds
- Sorry count reduced from 2 to 0 or 1
- No build errors in downstream modules

---

## Testing & Validation

- [ ] `lake build` succeeds for Representation.lean
- [ ] Box forward case compiles without sorry
- [ ] `constant_family_bmcs_exists_int` sorry eliminated (infrastructure removed)
- [ ] Truth lemma statement uses `fam.mcs t` and `canonicalOmega B`
- [ ] All completeness theorems compile
- [ ] No regressions in downstream files (if any)

## Artifacts & Outputs

- `specs/910_phase4_canonical_model_reconstruction/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Metalogic/Representation.lean` (modified)
- `specs/910_phase4_canonical_model_reconstruction/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation reveals fundamental issues:
1. Git revert to pre-implementation state
2. Re-examine whether the Omega-mismatch requires immediate Validity.lean changes
3. Consider alternative: prove weak/strong completeness with existential Omega in valid definition
4. Consult research-001.md Section "Resolution approach" for alternative proof strategies

## Omega-Mismatch Resolution Strategy

The research identified a genuine mismatch:
- `valid phi` uses `truth_at M Set.univ tau t phi`
- `satisfiable [phi.neg]` produces `truth_at M canonicalOmega tau t phi.neg`
- The contradiction in weak_completeness requires matching Omega values

**Recommended approach for Phase 5**:
1. Attempt to prove a monotonicity lemma: `truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi` (research suggests this fails for imp due to contravariance)
2. If monotonicity fails, use sorry with clear documentation:
   ```lean
   -- TODO: Omega-mismatch requires valid to quantify over Omega or monotonicity lemma
   -- See research-001.md Section "Resolution approach" for analysis
   -- Follow-up task needed to coordinate with Validity.lean changes
   sorry
   ```
3. Create follow-up task for Validity.lean `valid` definition change

This approach prioritizes the core wins (eliminating Box forward and constant-family sorries) while documenting the remaining issue clearly.
