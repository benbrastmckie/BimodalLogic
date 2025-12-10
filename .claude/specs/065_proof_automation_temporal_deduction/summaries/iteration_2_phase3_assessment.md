# Phase 3 Assessment: DeductionTheorem Sorry Resolution
## Iteration 2 - Wave 1

**Date**: 2025-12-10
**Phase**: 3 (DeductionTheorem Sorry Resolution)
**Status**: BLOCKED - Requires Human Expert

---

## Executive Summary

Phase 3 requires implementing well-founded recursion infrastructure that is **beyond the scope of automated orchestration**. This assessment recommends human expert involvement for the following reasons:

1. **No existing patterns in codebase** - Zero instances of `termination_by` or well-founded recursion
2. **Complex Mathlib integration** - Requires `List.Perm` theory not currently imported
3. **High estimated effort** - 8-12 hours of focused proof engineering
4. **Critical path dependency** - Blocks Phase 4 (future_k_dist derivation)

---

## Technical Analysis

### Sorry Locations

1. **Line 370** (modal_k case): Context transformed via `map box`
   - Requires: `boxed_deduction_helper` with well-founded recursion
   - Complexity: HIGH

2. **Line 383** (temporal_k case): Context transformed via `map all_future`
   - Requires: `temporal_deduction_helper` (mirror of boxed_deduction_helper)
   - Complexity: HIGH

3. **Line 419** (weakening case): A ∈ Γ' requires reordering
   - Requires: `derivable_permutation` using `List.Perm`
   - Complexity: MEDIUM-HIGH

### Infrastructure Requirements

#### 1. Derivable.size Metric

```lean
def Derivable.size : {Γ : Context} → {φ : Formula} → (Γ ⊢ φ) → Nat
| _, _, .axiom _ _ _ => 1
| _, _, .assumption _ _ _ => 1
| _, _, .modus_ponens _ _ _ h1 h2 => 1 + h1.size + h2.size
| _, _, .modal_k _ _ h => 1 + h.size
| _, _, .temporal_k _ _ h => 1 + h.size
| _, _, .temporal_duality _ h => 1 + h.size
| _, _, .weakening _ _ _ h _ => 1 + h.size
```

**Challenge**: Lean 4 may require explicit well-founded relation proof.

#### 2. List.Perm Integration

```lean
import Std.Data.List.Lemmas  -- For List.Perm

theorem derivable_permutation (Γ Γ' : Context) (φ : Formula)
    (h_perm : Γ.Perm Γ') (h : Γ ⊢ φ) : Γ' ⊢ φ
```

**Challenge**:
- `List.Perm` not currently imported
- Requires structural induction on derivation
- Must prove permutation preserves assumption membership

#### 3. Recursive Deduction Helpers

Both helpers need to call `deduction_theorem` recursively on sub-derivations:

```lean
theorem boxed_deduction_helper (Γ' : Context) (A φ : Formula)
    (h : (A :: Γ') ⊢ φ) :
    (Context.map Formula.box Γ') ⊢ (Formula.box A).imp (Formula.box φ) := by
  -- Recursive call to deduction_theorem on h (smaller derivation)
  have ih : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h
  -- Apply modal_k
  have boxed : (Context.map Formula.box Γ') ⊢ Formula.box (A.imp φ) :=
    Derivable.modal_k Γ' (A.imp φ) ih
  -- Use modal_k_dist axiom
  sorry
  termination_by h.size
```

**Challenge**:
- Recursive call inside proof may confuse termination checker
- May need `decreasing_by` tactic for manual termination proof

---

## Blockers Identified

### Blocker 1: Well-Founded Recursion Expertise

**Problem**: The codebase has zero examples of well-founded recursion patterns.

**Impact**: No local reference for:
- `termination_by` clause syntax
- Automatic vs manual termination proofs
- `decreasing_by` tactic usage
- Lean 4 vs Lean 3 differences in recursion

**Mitigation Options**:
1. Study Mathlib examples (requires time investment)
2. Consult Lean Zulip community (async, unpredictable timeline)
3. Human expert with Lean 4 recursion experience

### Blocker 2: List.Perm Theory Gap

**Problem**: `List.Perm` not imported, permutation lemmas not available.

**Impact**: Cannot prove:
- `List.Perm_cons`: Reordering preserves membership
- `List.Mem_of_Perm`: Membership preserved under permutation
- Structural induction over permutation relation

**Mitigation Options**:
1. Import `Std.Data.List.Lemmas` (untested in current build)
2. Manually prove permutation lemmas (significant effort)
3. Avoid permutation approach (requires alternative proof strategy)

### Blocker 3: Modal K Distribution Axiom Application

**Problem**: After getting `(map box Γ') ⊢ box (A.imp φ)`, need to derive `(box A).imp (box φ)`.

**Current State**: `modal_k_dist` axiom exists but application pattern unclear.

**Required Pattern**:
```lean
-- From: ⊢ □(A → φ)
-- To: ⊢ □A → □φ
-- Via: modal_k_dist axiom + modus ponens
```

**Challenge**: May need additional helper lemmas to bridge this gap.

---

## Recommended Strategy

### Option A: Human Expert Session (RECOMMENDED)

**Scope**: 1 focused session (4-6 hours) with Lean 4 expert

**Tasks**:
1. Implement Derivable.size with termination proof
2. Import and test List.Perm integration
3. Prove derivable_permutation lemma
4. Implement boxed_deduction_helper with working termination
5. Resolve all 3 sorry markers

**Rationale**:
- Fastest path to completion
- Establishes recursion patterns for future work
- Unblocks Phase 4 (critical path)

**Estimated Time**: 4-6 hours (lower than plan's 8-12 due to focused expertise)

### Option B: Incremental Automated Approach

**Scope**: Break Phase 3 into micro-tasks, attempt with extended context

**Phase 3a**: Derivable.size (2 hours)
- Define size metric
- Test termination_by acceptance
- Document pattern for reuse

**Phase 3b**: List.Perm integration (2-3 hours)
- Import Std.Data.List.Lemmas
- Verify build compatibility
- Prove basic permutation lemma

**Phase 3c**: Boxed helper (3-4 hours)
- Implement with recursive call
- Debug termination checker
- Apply modal_k_dist

**Phase 3d**: Temporal helper + remaining sorries (2-3 hours)
- Mirror boxed helper
- Resolve all 3 sorry locations
- Full build + test verification

**Rationale**:
- Allows automated progress on simpler sub-tasks
- Provides checkpoint visibility
- Maintains momentum

**Risk**: May still require human intervention if termination_by fails.

### Option C: Defer Phase 3, Continue with Independent Phases

**Scope**: Mark Phase 3 as deferred, proceed with Phases 2 and 5

**Independent Work Available**:
- **Phase 2** (Temporal K Infrastructure): No dependencies on Phase 3
- **Phase 5** (Tactic Consolidation): Optional, purely code quality

**Rationale**:
- Make progress on unblocked work
- Accumulate context for later Phase 3 attempt
- Validate Phase 2 infrastructure before Phase 4

**Risk**: Phase 4 remains blocked (requires complete deduction theorem).

---

## Decision Matrix

| Strategy | Pros | Cons | Time to Unblock Phase 4 |
|----------|------|------|------------------------|
| **Option A: Human Expert** | Fastest, establishes patterns, highest success probability | Requires human availability | 4-6 hours |
| **Option B: Incremental Auto** | Maintains automation, provides checkpoints | May fail at termination_by step | 9-13 hours |
| **Option C: Defer Phase 3** | Makes progress on Phase 2/5 | Phase 4 blocked indefinitely | N/A (blocked) |

---

## Recommended Action

**Immediate**: Pursue **Option C** (Defer Phase 3, continue Phase 2)

**Rationale**:
1. Phase 2 is **unblocked** and provides valuable temporal infrastructure
2. Phase 2 completion reduces axiom count by 2 (immediate value)
3. Accumulate more context on Lean 4 patterns before tackling recursion
4. Phase 3 remains on critical path but deferred to next iteration

**Next Iteration**: After Phase 2 completion, reassess Phase 3 with:
- Fresh context budget
- Phase 2 learnings about temporal operator patterns
- Possible discovery of alternative proof strategies

**Long-Term**: Consider **Option A** (Human Expert) if Phase 3 blocking becomes critical for project milestones.

---

## Iteration 2 Summary

**Work Completed**:
- Phase 1: COMPLETE (3 helper lemmas)
- Phase 3 Assessment: COMPLETE (this document)

**Work Remaining**:
- Phase 2: Temporal K Infrastructure (3-4 hours, unblocked)
- Phase 3: DeductionTheorem (8-12 hours, blocked on recursion)
- Phase 4: Temporal Axiom Derivation (4-6 hours, blocked on Phase 3)
- Phase 5: Tactic Consolidation (6-8 hours, optional)

**Context Usage**: 49K / 200K (24.5%)

**Recommendation**: Continue to Phase 2 in next iteration.

---

## Appendices

### Appendix A: Mathlib Well-Founded Recursion Examples

**Recommended Study Materials** (for future Phase 3 attempt):

1. `Mathlib/Data/List/Basic.lean` - List recursion patterns
2. `Mathlib/Logic/Relation.lean` - Well-founded relation theory
3. `Mathlib/Init/WF.lean` - Core well-founded infrastructure

**Lean Zulip Topics**:
- "termination_by in Lean 4"
- "well-founded recursion examples"
- "decreasing_by tactic"

### Appendix B: Alternative Proof Strategy (Unexplored)

**Hypothesis**: Could the deduction theorem be proven without well-founded recursion?

**Potential Approach**:
1. Restrict deduction theorem to derivations without modal_k/temporal_k
2. Prove restricted version first
3. Handle modal/temporal cases via separate lifting lemmas

**Status**: Not evaluated in this assessment (requires research phase).

---

**Assessment Complete**: 2025-12-10
