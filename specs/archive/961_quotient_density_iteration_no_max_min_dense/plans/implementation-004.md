# Implementation Plan: Task #961 (v004)

- **Task**: 961 - quotient_density_iteration_no_max_min_dense
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 956 (D Construction strategy), Task 957 (density_frame_condition)
- **Research Inputs**: research-003.md (Classical.choose), research-004.md (quotient collapse strategy)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v004 supersedes v003; incorporates bounded iteration + Classical fallback from research-004

## Overview

**What Changed (v003 -> v004)**:
- research-004.md provided concrete proof strategy for quotient collapse argument
- Discovered that depth-2 iteration SUFFICES (not infinite)
- Identified that `intermediate_not_both_equiv` eliminates branches at each level
- Transitivity via `canonicalR_T4_chain` (already in codebase) handles chained equivalences

**New Approach**: Bounded iteration (depth=2) with Classical existence fallback at depth exhaustion. Instead of pure Classical.choose from the start, we first attempt to find strict intermediates constructively, falling back to existence-by-contradiction only when iteration depth is exhausted.

### Research Integration

- **research-003.md**: Classical.choose existence proof is valid approach
- **research-004.md**: Bounded iteration (depth 2-3) + quotient collapse argument for Classical fallback

## Goals & Non-Goals

**Goals**:
- Fill 7 sorries in CantorApplication.lean (5 in strict_intermediate_aux, 2 in NoMaxOrder/NoMinOrder)
- Zero sorries remaining after implementation
- `lake build` passes

**Non-Goals**:
- Complete constructive proof (Classical fallback is acceptable)
- Preserving current sorry structure (will restructure as needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bounded depth insufficient | LOW | LOW | research-004 showed depth 2 suffices |
| Transitivity chains complex | MEDIUM | MEDIUM | Use canonicalR_T4_chain already available |
| Classical fallback not computable | N/A | N/A | Acceptable - existence suffices |

## Sorry Characterization

### Current Sorries (7) - after v003 implementation attempt
- `CantorApplication.lean`:
  - Line 226: Branch d ~ c ~ a and d NOT ~ b
  - Line 248: Branch e ~ a, e NOT ~ d
  - Line 253: Branch e NOT ~ a, e ~ b
  - Line 274: Branch d ~ a
  - Line 278: Branch d NOT ~ a, d ~ b
  - Line 423: NoMaxOrder reflexive case
  - Line 482: NoMinOrder reflexive case

### Expected Resolution
- Phase 1: Fill 5 sorries in `strict_intermediate_aux` using transitivity + Classical fallback
- Phase 2: Fill NoMaxOrder sorry (line 423) using proven `strict_intermediate_exists`
- Phase 3: Fill NoMinOrder sorry (line 482) symmetrically

### New Sorries
- None. If proof cannot be completed, mark [BLOCKED] with requires_user_review: true.

## Implementation Phases

### Phase 1: Fill strict_intermediate_aux Sorries [BLOCKED]

- **Dependencies:** None
- **Goal:** Complete the 5 sorries in `strict_intermediate_aux` using bounded iteration + Classical fallback

**Key Insight from research-004**: Each sorry branch represents a case where the current intermediate is ~ one endpoint. The pattern is:
1. If intermediate is ~ endpoint: iteration produces a NEW intermediate
2. `intermediate_not_both_equiv` guarantees: new intermediate cannot be ~ BOTH endpoints
3. After 2 iterations: either we found strict intermediate, or quotient would collapse

**Strategy for Each Sorry**:

**Line 226** (d ~ c ~ a, d NOT ~ b):
```lean
-- We have: a -> c -> d -> b, c ~ a, d ~ c
-- By transitivity: d ~ a (via canonicalR_T4_chain)
-- d NOT ~ b (given)
-- So d is: d ~ a AND d NOT ~ b AND d -> b
-- For strict intermediate, need: a -> d AND NOT d -> a
-- But d ~ a means d -> a. NOT strict above a.
-- Apply density to (d, b) since [a] = [d] < [b]
obtain ⟨e, he_mem, he_d, he_b⟩ := dense_timeline_has_intermediate d.1 b.1 hd_b hb_not_d
-- e cannot be ~ BOTH d and b
by_cases he_equiv_d : CanonicalR e.1.mcs d.1.mcs
· -- e ~ d ~ a. Apply Classical existence argument at this depth.
  classical
  by_contra h_none
  -- If no strict intermediate exists, quotient collapses - contradiction
  exact absurd (quotient_density_contradiction ...) h_none
· -- e NOT ~ d, hence e NOT ~ a. e is strictly above a.
  -- Check if e ~ b
  by_cases he_equiv_b : CanonicalR b.1.mcs e.1.mcs
  · -- e NOT ~ a AND e ~ b. e is strictly above a, strictly below b? No, e ~ b means e not strict below b.
    -- e is strictly above a. Use e as witness for NoMaxOrder-like result.
    ...
  · -- e NOT ~ a AND e NOT ~ b. e is STRICT INTERMEDIATE. Done.
    exact ⟨⟨e, he_mem⟩, he_d, he_equiv_d, he_b, he_equiv_b⟩
```

**Lines 248, 253, 274, 278**: Similar pattern with appropriate endpoint swaps.

**Classical Fallback Template**:
```lean
-- At depth exhaustion, use quotient collapse argument:
classical
by_contra h_none_strict
push_neg at h_none_strict
-- h_none_strict : ∀ c, c ~ a ∨ c ~ b
-- But [a] < [b] are distinct, and density produces intermediates
-- If all intermediates are ~ one endpoint, quotient has ≤ 2 classes
-- Dense orders have infinitely many between distinct points - contradiction
exact False.elim (quotient_collapse_absurd h_none_strict ...)
```

**Tasks:**
- [ ] Fill sorry at line 226 using depth-2 iteration + Classical fallback
- [ ] Fill sorry at line 248 using same pattern
- [ ] Fill sorry at line 253 using same pattern
- [ ] Fill sorry at line 274 using same pattern
- [ ] Fill sorry at line 278 using same pattern
- [ ] Add helper `quotient_collapse_absurd` if needed for Classical fallback
- [ ] Verify with `lake build`

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` shows only lines 423, 482

---

### Phase 2: NoMaxOrder Reflexive Case [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Resolve the sorry at line 423 for the NoMaxOrder reflexive case

**Strategy**: Once `strict_intermediate_exists` is proven (via Phase 1), the reflexive case becomes straightforward:

```lean
-- p.mcs is reflexive, need element strictly above [p]
-- Get any q with p -> q (seriality)
obtain ⟨q, hq_mem, hq_R⟩ := dense_timeline_has_future ...
-- If q NOT ~ p: q is strictly above p. Done.
by_cases hq_p : CanonicalR q.1.mcs p.1.mcs
· -- q ~ p. Get r with q -> r (seriality of q)
  obtain ⟨r, hr_mem, hr_R⟩ := dense_timeline_has_future ...
  -- Now we have p -> q -> r with q ~ p
  -- By transitivity, p -> r. If r NOT ~ p, done.
  by_cases hr_p : CanonicalR r.1.mcs p.1.mcs
  · -- r ~ p too. Use strict_intermediate_exists on (p, r) - wait, p ~ r so not applicable
    -- Actually: apply strict_intermediate_exists on ANY pair [p] < [s] where s NOT ~ p
    -- Since timeline is infinite, such s exists (proven elsewhere or by seriality chain)
    ...
  · -- r NOT ~ p. r is strictly above p.
    use toAntisymmetrization (· ≤ ·) ⟨r, hr_mem⟩
    ...
· -- q NOT ~ p. q is strictly above p.
  use toAntisymmetrization (· ≤ ·) ⟨q, hq_mem⟩
  ...
```

**Tasks:**
- [ ] Replace sorry at line 423 with proof using strict_intermediate_exists
- [ ] Handle all sub-cases (q ~ p, q NOT ~ p, seriality chain)
- [ ] Verify with `lean_goal` showing "no goals"
- [ ] Verify with `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` shows only line 482

---

### Phase 3: NoMinOrder Reflexive Case [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Resolve the sorry at line 482 (symmetric to Phase 2)

**Strategy**: Symmetric to NoMaxOrder using past direction.

**Tasks:**
- [ ] Replace sorry at line 482 with symmetric proof using strict_intermediate_exists
- [ ] Use past-direction helpers (dense_timeline_has_past, backward seriality)
- [ ] Verify with `lean_goal` showing "no goals"
- [ ] Verify with `lake build`

**Timing:** 0.25 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- `grep -rn "\bsorry\b" CantorApplication.lean` returns empty

---

### Phase 4: Verification [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Final verification

**Tasks:**
- [ ] Run `lake build` - must pass with no errors
- [ ] Run `grep -rn "\bsorry\b" CantorApplication.lean` - must return empty
- [ ] Verify DenselyOrdered, NoMaxOrder, NoMinOrder instances are complete
- [ ] Verify `cantor_iso` theorem has no sorry dependencies

**Timing:** 0.25 hours

**Verification:**
- All checks pass
- Zero sorries in `CantorApplication.lean`

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" CantorApplication.lean` returns empty (zero-debt gate)
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] `strict_intermediate_aux` compiles without sorry
- [ ] NoMaxOrder instance has no sorries
- [ ] NoMinOrder instance has no sorries
- [ ] DenselyOrdered instance has no sorries

## Artifacts & Outputs

- `plans/implementation-004.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

## Comparison: v003 vs v004

| Aspect | v003 | v004 |
|--------|------|------|
| **Core Strategy** | Pure Classical.choose from start | Bounded iteration + Classical fallback |
| **Iteration Depth** | 0 (immediate existence) | 2 (try constructively first) |
| **Fallback** | None (single approach) | Classical existence at depth exhaustion |
| **Key Insight** | Existence by contradiction | `intermediate_not_both_equiv` eliminates branches |
| **Source** | research-003.md | research-003.md + research-004.md |
