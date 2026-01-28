# Implementation Plan: Task #693

- **Task**: 693 - Implement generalized_past_k theorem
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Priority**: High (blocks Task 657)
- **Dependencies**: None (all prerequisites exist)
- **Research Inputs**: specs/693_implement_generalized_past_k_theorem/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement the `generalized_past_k` theorem in `GeneralizedNecessitation.lean`, which states that if `Gamma |- phi` then `(H Gamma) |- H phi` (where H is the "all_past" temporal operator). This follows the direct implementation strategy identified in research, mirroring the structure of the existing `generalized_temporal_k` theorem. The implementation requires adding a helper `past_necessitation` theorem derived via temporal duality, then implementing `generalized_past_k` using the same inductive pattern as `generalized_temporal_k`.

### Research Integration

The research report (research-001.md) identified:
- Direct implementation (Strategy A) as the recommended approach
- All required components exist: `deduction_theorem`, `reverse_deduction`, `past_k_dist`
- `past_necessitation` must be derived via temporal duality (not primitive)
- Import for `Bimodal.Theorems.Perpetuity.Principles` needed for `past_k_dist`

## Goals & Non-Goals

**Goals**:
- Implement `past_necessitation` helper theorem via temporal duality
- Implement `generalized_past_k` following `generalized_temporal_k` structure
- Add appropriate documentation matching existing codebase style
- Update module docstring to include new theorem

**Non-Goals**:
- Implementing generic parameterized version (Strategy C from research)
- Deriving via temporal duality at context level (Strategy B)
- Modifying any other theorems or proof systems

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `simp` automation differs for past vs future | Low | Medium | Copy exact simp calls from `past_k_dist` proof |
| `swap_temporal` naming vs `swap_past_future` | Low | Low | Use `swap_temporal` (canonical) with `swap_temporal_involution` |
| Build fails due to import order | Medium | Low | Add import after existing imports, run `lake build` to verify |

## Implementation Phases

### Phase 1: Add Import and past_necessitation Helper [NOT STARTED]

**Goal**: Add the required import and implement the `past_necessitation` derived theorem

**Tasks**:
- [ ] Add import for `Bimodal.Theorems.Perpetuity.Principles` to access `past_k_dist`
- [ ] Implement `past_necessitation` theorem with temporal duality pattern:
  - Take derivation `d : [] |- phi`
  - Apply `temporal_duality` to get `|- swap_temporal phi`
  - Apply `temporal_necessitation` to get `|- all_future (swap_temporal phi)`
  - Apply `temporal_duality` again
  - Use `simp` with `swap_temporal_involution` to simplify to `|- all_past phi`
- [ ] Add documentation following existing codebase docstring style
- [ ] Run `lean_diagnostic_messages` to verify no errors

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - Add import (line 5), add `past_necessitation` (after `reverse_deduction`, around line 48)

**Verification**:
- `lake build Bimodal.Theorems.GeneralizedNecessitation` succeeds
- No errors from `lean_diagnostic_messages`

---

### Phase 2: Implement generalized_past_k [NOT STARTED]

**Goal**: Implement the main `generalized_past_k` theorem following the `generalized_temporal_k` pattern

**Tasks**:
- [ ] Implement `generalized_past_k` with signature:
  ```lean
  noncomputable def generalized_past_k : (Gamma : Context) -> (phi : Formula) ->
      (h : Gamma |- phi) -> ((Context.map Formula.all_past Gamma) |- Formula.all_past phi)
  ```
- [ ] Base case: Use `past_necessitation phi h` for empty context
- [ ] Inductive case: Follow exact structure of `generalized_temporal_k`:
  - Apply `deduction_theorem`
  - Recursive call for implication
  - Use `past_k_dist` (from Principles.lean) instead of `temp_k_dist` axiom
  - Apply weakening and modus ponens
  - Use `reverse_deduction`
- [ ] Add comprehensive documentation matching `generalized_temporal_k` style
- [ ] Run `lean_diagnostic_messages` to verify no errors

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - Add `generalized_past_k` after `generalized_temporal_k` (after line 122)

**Verification**:
- `lake build Bimodal.Theorems.GeneralizedNecessitation` succeeds
- No errors from `lean_diagnostic_messages`
- Type signature matches research report expectation

---

### Phase 3: Update Documentation and Verify [NOT STARTED]

**Goal**: Update module docstring and perform final verification

**Tasks**:
- [ ] Update module docstring Main Theorems section to include `generalized_past_k`
- [ ] Verify the theorem works by checking `lean_hover_info` on the definition
- [ ] Run full module build to ensure no regressions
- [ ] Check that Task 657 usage site (IndexedMCSFamily.lean line 450) can now use `generalized_past_k`

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - Update docstring (lines 19-22)

**Verification**:
- Module docstring includes `generalized_past_k` with correct signature description
- `lean_hover_info` shows expected type signature
- Build succeeds with no warnings

## Testing & Validation

- [ ] `lake build Bimodal.Theorems.GeneralizedNecessitation` succeeds without errors
- [ ] `lean_diagnostic_messages` reports no errors for the file
- [ ] `lean_hover_info` on `generalized_past_k` shows correct type signature
- [ ] `lean_hover_info` on `past_necessitation` shows correct type signature
- [ ] Module docstring updated to list new theorem

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`
  - Added import for `Perpetuity.Principles`
  - Added `past_necessitation` helper theorem
  - Added `generalized_past_k` main theorem
  - Updated module docstring
- Created: `specs/693_implement_generalized_past_k_theorem/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails:
1. Revert changes to `GeneralizedNecessitation.lean` using git
2. Document blocking issue in errors.json
3. Consider alternative Strategy B (derivation via temporal duality at context level) if Strategy A has unforeseen complications
4. Escalate to user if fundamental issues with temporal duality infrastructure discovered
