# Implementation Plan: Task #735

- **Task**: 735 - Complete task 700 phase 5: Ultrafilter-MCS Correspondence
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: high
- **Dependencies**: Task 700 phases 1-4 (completed)
- **Research Inputs**: specs/735_complete_task700_phase5_ultrafilter_mcs_correspondence/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete the sorry at line 162 of `UltrafilterMCS.lean` which proves that `ultrafilterToSet U` is consistent. The key challenge is showing that if a list L derives bottom and all quotients of L are in U, then the fold of quotients is less than or equal to bottom, which contradicts U.bot_not_mem via upward closure. The proof requires a helper lemma `fold_le_of_derives` that connects list derivations to the Boolean algebra ordering.

### Research Integration

From research report:
- The proof requires showing: `L ⊢ ⊥ => List.foldl (fun acc phi => acc ⊓ toQuot phi) ⊤ L ≤ ⊥`
- The deduction theorem is available at `Bimodal.Metalogic.Core.deduction_theorem`
- The Boolean algebra structure provides `mem_of_le` for upward closure
- Proof strategy: induction on L, using deduction theorem at cons case

## Goals and Non-Goals

**Goals**:
- Fill the sorry at line 162 in `ultrafilterToSet_mcs`
- Implement `fold_le_of_derives` helper lemma connecting list derivation to quotient ordering
- Verify with `lake build`

**Non-Goals**:
- Completing the `mcs_ultrafilter_correspondence` bijection proof (separate task 736)
- Modifying the MCS-to-ultrafilter direction

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fold direction issues | M | L | The fold goes left-to-right from ⊤; existing helpers in BooleanStructure.lean handle ordering |
| Deduction theorem interface | L | L | Already used in BooleanStructure.lean proofs; pattern is established |
| Quotient manipulation | M | M | Use Quotient.ind for induction; existing patterns in LindenbaumQuotient.lean |

## Implementation Phases

### Phase 1: Implement `fold_le_of_derives` Helper [NOT STARTED]

**Goal**: Create a lemma showing that if L ⊢ ψ, then the fold of quotients of L is ≤ [ψ].

**Tasks**:
- [ ] Add `fold_le_of_derives` theorem before `ultrafilterToSet_mcs`
- [ ] Prove by induction on L using the deduction theorem
- [ ] Handle nil case (fold = ⊤, need ⊤ ≤ [ψ] from weakening)
- [ ] Handle cons case: apply deduction theorem to reduce context, then use existing lemmas

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - add helper lemma around line 100

**Lemma signature**:
```lean
/-- If L derives ψ, then the meet of quotients of L is ≤ [ψ]. -/
theorem fold_le_of_derives (L : List Formula) (ψ : Formula)
    (h : DerivationTree L ψ) :
    List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ≤ toQuot ψ
```

**Proof outline**:
- Induction on L
- **Nil case**: fold = ⊤. From `[] ⊢ ψ` we have `⊢ ψ`. Show `⊤ ≤ [ψ]` using `le_top_quot` fact that `⊢ ⊤ → ψ` when `⊢ ψ` (by weakening).
- **Cons case**: From `[φ] ++ L' ⊢ ψ`, apply deduction theorem to get `L' ⊢ φ → ψ`. By IH, `fold(L') ≤ [φ → ψ]`. Need to show `[φ] ⊓ fold(L') ≤ [ψ]`. Use Boolean algebra property: `a ⊓ b ≤ c` when `a ⊓ b ≤ a` and `a ≤ (b → c)` implies `a ⊓ b ≤ c`.

**Verification**:
- Check `lean_goal` at each step to verify proof state
- Run `lake build` to verify no errors

---

### Phase 2: Complete the Sorry [NOT STARTED]

**Goal**: Fill the sorry at line 162 using `fold_le_of_derives`.

**Tasks**:
- [ ] Apply `fold_le_of_derives` with `ψ = Formula.bot` to get `fold(L) ≤ ⊥`
- [ ] Use `U.mem_of_le h_meet (fold_le_of_derives ...)` to show `⊥ ∈ U`
- [ ] Apply `U.bot_not_mem` to derive contradiction

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - replace sorry at line 162

**Code pattern**:
```lean
-- After h_meet : fold ... ∈ U.carrier
have h_le_bot : List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L ≤ ⊥ :=
  fold_le_of_derives L Formula.bot d_bot
have h_bot_in_U : ⊥ ∈ U.carrier := U.mem_of_le h_meet h_le_bot
exact U.bot_not_mem h_bot_in_U
```

**Verification**:
- Run `lake build` to verify the file compiles without errors
- Verify no remaining sorries in the consistency proof

---

### Phase 3: Final Verification and Cleanup [NOT STARTED]

**Goal**: Ensure the implementation is correct and the file builds cleanly.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.Algebraic.UltrafilterMCS`
- [ ] Verify no warnings or errors
- [ ] Check that `mcs_ultrafilter_correspondence` still has its sorry (deferred to task 736)
- [ ] Add docstring to `fold_le_of_derives` explaining its purpose

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - add docstring if missing

**Verification**:
- `lake build` succeeds with no errors
- `grep sorry UltrafilterMCS.lean` shows only `mcs_ultrafilter_correspondence`

## Testing and Validation

- [ ] `lake build` passes without errors
- [ ] The sorry at line 162 is filled
- [ ] Only `mcs_ultrafilter_correspondence` sorry remains (deferred to task 736)
- [ ] New lemma `fold_le_of_derives` has appropriate docstring

## Artifacts and Outputs

- Modified `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean`
- New lemma: `fold_le_of_derives`
- Completed proof: `ultrafilterToSet_mcs` consistency branch

## Rollback/Contingency

If implementation fails:
1. Restore original `UltrafilterMCS.lean` from git
2. Document blocking issue in error report
3. Consider alternative approaches:
   - Define explicit `listConj` function and prove fold = listConj quotient
   - Break into smaller helper lemmas for each induction step
