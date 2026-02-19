# Implementation Plan: Recursive Seed Henkin Model - Closure.lean Error Remediation (v8)

- **Task**: 864 - Recursive seed construction for Henkin model completeness
- **Status**: [PLANNED]
- **Effort**: 12 hours (focused on Closure.lean errors + remaining pipeline)
- **Dependencies**: None (supersedes implementation-007.md)
- **Research Inputs**:
  - specs/864_recursive_seed_henkin_model/reports/research-009.md (Closure.lean error analysis)
  - specs/864_recursive_seed_henkin_model/reports/research-008.md (meta-analysis and Option B recommendation)
- **Artifacts**: plans/implementation-008.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary (v007 -> v008)

v007 completed Phases 1-3 (file split) and made partial progress on Phase 4 (build errors). Research-009 analyzed the remaining 77 build errors in Closure.lean, categorizing them into 7 types with a clear dependency-ordered remediation path. This plan focuses Phase 4 on Closure.lean specifically, preserving completed work.

| Aspect | v007 | v008 Changes |
|--------|------|--------------|
| Phase 4 scope | Generic "fix ~100 errors" | **Closure.lean-specific** 6-stage remediation |
| Error understanding | Categorized by type | **77 errors in 7 categories** with line numbers |
| Dependency order | Fix by file | **Fix by logical dependency** (duplicates → foundational lemma → mechanical fixes) |
| Effort estimate | 6 hours generic | **4 hours Closure.lean** (research-informed) |
| Completed work | Phases 1-3 | **Preserved** - no changes to completed phases |

## Overview

Closure.lean has 77 build errors (research-009) falling into 7 distinct categories. Most are syntactic/API issues, not mathematical gaps. The single sorry (Dershowitz-Manna termination, line 3518) is the only genuine proof obligation.

Error breakdown:
1. **10 duplicate declarations** - Delete from Closure.lean (already in Worklist.lean)
2. **22 Prod.mk.injEq.mp errors** - Mechanical replacement
3. **5 List.find?_append failures** - Struct projection issue
4. **3 API renames** - findIdx?_eq_some_iff, mem_eraseDups, find?_eq_getElem?
5. **4 invalid ▸ notation** - Replace with explicit subst
6. **15 mem_getFormulas_after_addFormula failures** - Foundational lemma rewrite
7. **15 processWorklistAux errors** - Tactic syntax updates

## Goals & Non-Goals

**Goals**:
- Fix all 77 build errors in Closure.lean so it compiles
- Maintain 0 new sorries, 0 axioms
- Preserve the 1 existing sorry (DM termination) with documentation
- Complete barrel file and build graph integration (v007 Phase 5)
- Proceed to consistency/closure proofs (v007 Phases 6-7)

**Non-Goals**:
- Fixing the DM termination sorry in this iteration (documented as technical debt)
- Modifying the completed split structure (Phases 1-3 preserved)
- Changing the mathematical approach

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `mem_getFormulas_after_addFormula` rewrite complex | High | Medium | Use Builder.lean's `addFormula_preserves_mem_getFormulas` as alternative proof base |
| Worklist.lean versions have different signatures | Medium | Low | Verify before deleting; rename if incompatible |
| processWorklistAux proof structure unsound | High | Low | Mathematical structure is correct; only tactics need updating |

## Sorry Characterization

### Pre-existing Sorries

**Closure.lean** (1 sorry):
| Line | Theorem | Difficulty | Critical Path? |
|------|---------|------------|----------------|
| 3518 | `processWorklistAux_preserves_closure` (termination) | High | No (algorithm terminates; formalization blocked) |

### Expected Resolution

- **Phase 1 (Closure.lean)**: 0 sorry changes (build error fixes only)
- **Phase 2 (Integration)**: 0 sorry changes
- **Phase 3 (Consistency)**: Resolve 6 sorries via post-condition architecture
- **Phase 4 (SeedCompletion/BMCS)**: Resolve 10 sorries

### Remaining Debt

After full implementation:
- 1 sorry in Closure.lean (DM termination - technical debt, not mathematical)
- 5 sorries in Builder.lean (legacy buildSeedAux path - non-critical)
- 0 sorries in SeedCompletion.lean
- 0 sorries in SeedBMCS.lean

## Axiom Characterization

- **Pre-existing**: None in seed pipeline
- **New**: NEVER
- **Remaining**: 0

## Implementation Phases

### Phase 1: Fix Closure.lean Build Errors [NOT STARTED]

- **Dependencies**: Phases 1-3 from v007 completed
- **Goal**: Fix all 77 build errors so Closure.lean compiles

This phase follows the 6-stage remediation path from research-009:

#### Stage 1A: Delete Duplicate Declarations (10 errors, ~15 min)

**Root Cause**: Lemmas duplicated between Worklist.lean and Closure.lean. The Worklist.lean versions are public; Closure.lean versions are private but still clash.

**Delete these lemma blocks from Closure.lean** (use Worklist.lean versions instead):

| Lines | Lemma Name | Action |
|-------|------------|--------|
| 288-315 | `foldl_addFormula_fam_puts_phi_in_all` | Delete |
| 317-323 | `foldl_addFormula_fam_self_hasPosition` | Delete |
| 546-563 | `foldl_compound_future_preserves_mem` | Delete |
| 565-584 | `foldl_compound_past_preserves_mem` | Delete |
| 673-695 | `foldl_compound_future_puts_psi_in_all` | Delete |
| 725-768 | `foldl_compound_past_puts_psi_in_all` | Delete |
| 776-790 | `foldl_compound_future_preserves_hasPosition` | Delete |
| 793-810 | `foldl_compound_past_preserves_hasPosition` | Delete |
| 883-891 | `foldl_compound_future_self_hasPosition` | Delete |
| 893-901 | `foldl_compound_past_self_hasPosition` | Delete |

**PRESERVE** these unique lemmas in Closure.lean:
- `foldl_compound_future_puts_gpsi_in_all` (line 700)
- `foldl_compound_past_puts_hpsi_in_all` (line 751)

**Verification**:
- [ ] 10 duplicate lemma blocks deleted (~600 lines)
- [ ] Unique lemmas preserved
- [ ] No new errors introduced

#### Stage 1B: Fix `Prod.mk.injEq.mp` Errors (22 errors, ~20 min)

**Root Cause**: `Prod.mk.injEq` is now `Eq` not `Iff`, so `.mp` doesn't work.

**Pattern to replace at 11 locations**:
```lean
-- OLD (fails):
obtain ⟨h_newWork, h_state'⟩ := Prod.mk.injEq.mp h_proc

-- NEW:
simp only [Prod.mk.injEq] at h_proc
obtain ⟨h_newWork, h_state'⟩ := h_proc
```

**Locations**: Lines 973, 1088, 1190, 1292, 1403, 1661, 1820, 2346, 2551, 3002

**Verification**:
- [ ] All 11 occurrences replaced
- [ ] Each replacement compiles locally

#### Stage 1C: Fix `mem_getFormulas_after_addFormula` (15+ errors, ~2 hours)

**Root Cause**: This foundational lemma (lines 161-282) uses outdated List APIs:
- `List.find?_append` blocked by struct projection
- `List.find?_eq_getElem?_find` doesn't exist
- `List.findIdx?_eq_some_iff` renamed to `List.findIdx?_eq_some_iff_getElem`
- Multiple downstream cascading failures

**Fix strategy** (lines 161-282):

1. **Fix `none` branch (lines 170-179)**:
   ```lean
   -- Before List.find?_append rewrite, add:
   simp only [ModelSeed.entries] at *
   -- or use dsimp only
   ```

2. **Rewrite `some idx` branch (lines 180-224)**:
   - Replace nonexistent `List.find?_eq_getElem?_find` with element-by-element reasoning
   - Use `List.getElem_modify` for modify-related goals
   - Use `List.find?_eq_some_iff_append` if available

3. **Fix `h_pos = false` branch (lines 225-282)**:
   - Line 275: Remove `List.find?_eq_getElem?_find` usage
   - Prove via induction or `List.find?_ext` pattern

4. **Alternative approach**: Consider proving via `addFormula_preserves_mem_getFormulas` from Builder.lean (line 6018) if direct fix is too complex.

**Verification**:
- [ ] `mem_getFormulas_after_addFormula` compiles
- [ ] Downstream lemmas using it compile

#### Stage 1D: Fix API Renames (3 errors, ~15 min)

| Line | Old Name | New Name |
|------|----------|----------|
| 449 | `List.findIdx?_eq_some_iff` | `List.findIdx?_eq_some_iff_getElem` |
| 538 | `List.mem_eraseDups` | `List.mem_dedup` |
| 275 | `List.find?_eq_getElem?_find` | (addressed in Stage 1C) |

**Verification**:
- [ ] API names updated
- [ ] Usages compile

#### Stage 1E: Fix `▸` Notation Errors (4 errors, ~15 min)

**Root Cause**: The triangle notation `▸` has become stricter in recent Lean 4 versions.

**Locations**: Lines 612, 615, 657, 660

**Fix pattern**:
```lean
-- OLD (fails):
exact Or.inr (Or.inl ⟨h_eq, ht ▸ hf ▸ List.mem_cons_self t rest, hf⟩)

-- NEW:
subst ht hf
exact Or.inr (Or.inl ⟨h_eq, List.mem_cons_self f rest, rfl⟩)
```

**Verification**:
- [ ] All 4 occurrences fixed
- [ ] Each compiles

#### Stage 1F: Fix `processWorklistAux_preserves_closure` (15 errors, ~2 hours)

**Root Cause**: Mix of API changes, `decide` wrapping, and case naming in lines 3214-3537.

**Key fixes**:

| Line | Issue | Fix |
|------|-------|-----|
| 3214 | `rfl` expected `True` | Replace with `exact ⟨trivial, trivial⟩` |
| 3307 | `rfl` vs filter | Add `simp` to normalize filter before contradiction |
| 3322 | `decide` wrapping | Add `simp only [decide_eq_true_eq]` |
| 3376/3387/3397 | Unknown `h` | Use `rename_i` or explicit match |
| 3410 | `simp` no progress | Use `simp only [WorklistState.worklist]` |
| 3423 | `List.mem_cons_self` args | Remove explicit arguments |
| 3444/3478 | Rewrite failures | Fix struct projection with `dsimp` |
| 3537 | `unfold` failed | Remove (already unfolded) |

**Verification**:
- [ ] `processWorklistAux_preserves_closure` compiles (with 1 sorry at line 3518)
- [ ] `buildSeedComplete_closed` compiles

**Timing**: 4 hours total

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean`

**Verification**:
- [ ] `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Closure` succeeds
- [ ] `grep -c "sorry"` returns 1 (the DM termination only)
- [ ] No new sorries introduced

---

### Phase 2: Complete Build Graph Integration [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Create barrel file, integrate into main build, verify full pipeline

**Tasks**:
- [ ] Verify barrel file `RecursiveSeed.lean` exists and imports all 5 submodules
- [ ] Verify SeedCompletion.lean compiles with barrel import
- [ ] Verify SeedBMCS.lean compiles
- [ ] Add import to `Metalogic.lean`: `import Bimodal.Metalogic.Bundle.SeedBMCS`
- [ ] Run `lake build Bimodal` for full verification

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (verify/create barrel)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (add import)

**Verification**:
- [ ] `lake build Bimodal` succeeds
- [ ] Seed pipeline visible in build graph

---

### Phase 3: Complete Consistency Proofs [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Derive consistency from closure via post-condition architecture

**Tasks**:

**3a: Post-Condition Consistency (Consistency.lean)**:
- [ ] Define `FormulaConsistent_Weak` (weaker invariant)
- [ ] Prove `closed_seed_implies_consistent`
- [ ] Prove `buildSeedComplete_consistent`
- [ ] Remove/deprecate old `processWorkItem_preserves_consistent` sorries (6 eliminated)
- [ ] Resolve `processWorklistAux_preserves_invariant` sorries (3 eliminated)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Consistency.lean`

**Verification**:
- [ ] `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Consistency` succeeds
- [ ] 0 sorries on critical path

---

### Phase 4: SeedCompletion and SeedBMCS Integration [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Resolve 5 sorries in SeedCompletion.lean and 5 sorries in SeedBMCS.lean

**Tasks**:

**4a: SeedCompletion.lean (5 sorries)**:
- [ ] Resolve `modal_witness_includes_boxcontent` (line 161) via ModalClosed
- [ ] Resolve `forward_G` cross-sign (line 246) via GClosed
- [ ] Resolve `backward_H` cross-sign (line 256) via HClosed
- [ ] Resolve `buildFamilyFromSeed_cross_sign_seed` (line 328)
- [ ] Resolve `buildFamilyFromSeed_contains_seed` t!=0 (line 372) - evaluate Strategy A (seed propagation) vs B (redesign)

**4b: SeedBMCS.lean (5 sorries)**:
- [ ] Resolve `modal_forward` (line 89)
- [ ] Resolve `modal_backward` (line 94)
- [ ] Resolve `construct_seed_bmcs` (line 180)
- [ ] Resolve `construct_seed_bmcs_contains_context` (line 188)
- [ ] Resolve `construct_seed_bmcs_temporally_coherent` (line 199)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`

**Verification**:
- [ ] `grep -c "sorry" SeedCompletion.lean` returns 0
- [ ] `grep -c "sorry" SeedBMCS.lean` returns 0
- [ ] `lake build Bimodal` succeeds

---

### Phase 5: Final Verification [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Verify publication-ready status

**Tasks**:
- [ ] Run `lake build Bimodal`
- [ ] Count sorries: should be 1 in Closure.lean (DM) + 5 in Builder.lean (legacy)
- [ ] Verify no axioms in seed pipeline
- [ ] Run `lean_verify` on key theorems
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to create**:
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- [ ] 6 total sorries (1 DM termination + 5 legacy Builder)
- [ ] 0 axioms
- [ ] Full build succeeds

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.RecursiveSeed.Closure` succeeds
- [ ] `lake build Bimodal` succeeds
- [ ] Each submodule builds independently
- [ ] SeedCompletion.lean: 0 sorries
- [ ] SeedBMCS.lean: 0 sorries
- [ ] No axioms in seed pipeline
- [ ] `lean_verify` passes on `buildSeedComplete_closed` and `buildSeedComplete_consistent`

## Artifacts & Outputs

- `specs/864_recursive_seed_henkin_model/plans/implementation-008.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Consistency.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

1. **If Closure.lean fixes break downstream**: Restore from git; retry with more conservative changes.

2. **If `mem_getFormulas_after_addFormula` rewrite fails**: Use Builder.lean's higher-level lemmas as an alternative proof base.

3. **If consistency post-condition approach fails**: Fall back to loop invariant approach with documented technical debt.

4. **DM termination sorry**: Accepted as technical debt. The algorithm provably terminates; only Lean 4 formalization is blocked.
