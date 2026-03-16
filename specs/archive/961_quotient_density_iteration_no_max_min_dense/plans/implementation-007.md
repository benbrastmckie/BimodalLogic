# Implementation Plan: Task #961 (v007)

- **Task**: 961 - quotient_density_iteration_no_max_min_dense
- **Status**: [IN PROGRESS]
- **Effort**: 3.5 hours
- **Dependencies**: Task 956 (D Construction strategy), Task 957 (density_frame_condition), Task 962 (dense_timeline_has_strict_intermediate)
- **Research Inputs**: research-007.md (deep mathematical analysis - formula wellfoundedness vs non-iterative strategies)
- **Artifacts**: plans/implementation-007.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v007 supersedes v006; focuses on proving `density_escapes_source_class` via formula content analysis

## Overview

This plan addresses the fundamental termination gap that has blocked all 6 previous implementation attempts. The core issue: iteration produces intermediates guaranteed NOT equivalent to TARGET, but may still be equivalent to SOURCE. research-007 identifies the key missing lemma: `density_escapes_source_class`.

**Key Insight**: When source `p` is reflexive and we apply `density_frame_condition_reflexive_source`, the intermediate `c` contains `neg delta` where:
- `G(delta) in target`, `delta NOT in source`
- Because source is reflexive: `G(delta) NOT in source` (otherwise `delta in source`)
- Therefore source is Case A: `F(neg delta) in source`
- The intermediate contains `neg delta`

**Why This Might Work Where Others Failed**: Previous approaches tried to track formula consumption across iterations. This approach analyzes formula content of a SINGLE intermediate to show it escapes the source class directly, avoiding iteration entirely.

### Research Integration

- **research-007.md Primary Recommendation**: Prove `density_escapes_source_class` by analyzing Lindenbaum extension formula content
- **Key Mathematical Argument**: The intermediate `V` has `neg delta in V`. For `V ~ source`, need `GContent(V) subset source`. The Lindenbaum construction constraints may prevent this.
- **Secondary Fallback**: `denselyOrdered_iff_forall_not_covBy` contradiction approach

## Goals & Non-Goals

**Goals**:
- Prove `density_escapes_source_class` in DenseTimeline.lean (or mark [BLOCKED] with mathematical analysis)
- If Phase 1 succeeds: resolve all 6 sorries in CantorApplication.lean
- Zero sorries in final implementation
- `lake build` passes

**Non-Goals**:
- Constructive strict intermediate via bounded iteration (proven to fail)
- Modifying `density_frame_condition` core lemma
- Adding axioms without exhausting proof approaches

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula content analysis inconclusive | HIGH | MEDIUM | Document findings, try multiple angles, 1.5h cap then [BLOCKED] |
| Lindenbaum extension doesn't constrain GContent | HIGH | MEDIUM | This is the core uncertainty - if true, approach fails |
| Proof requires formula wellfoundedness | MEDIUM | LOW | Could add as axiom with justification if clearly needed |
| Type synthesis issues in Lean | LOW | LOW | Explicit annotations |

## Sorry Characterization

### Current Sorries (6)

From `CantorApplication.lean`:
- **Line 304**: `strict_intermediate_exists` - iteration termination when source reflexive
- **Line 419**: `strict_intermediate_exists` - nested iteration termination
- **Line 509**: `strict_intermediate_exists` - nested iteration termination
- **Line 573**: `strict_intermediate_exists` - nested iteration termination (non-reflexive source case)
- **Lines 733-734**: `NoMaxOrder` - reflexive loop escape
- **Lines 792-793**: `NoMinOrder` - symmetric iteration termination

### Expected Resolution

- **Phase 1**: Prove `density_escapes_source_class` (or document why impossible)
- **Phase 2**: Apply to simplify `strict_intermediate_exists`
- **Phase 3**: Apply to resolve `NoMaxOrder`/`NoMinOrder`
- **Phase 4**: Final cleanup and verification

### New Sorries

- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - Document mathematical obstruction clearly
  - DO NOT use sorry and mark task complete

## Why This Approach Differs From Previous Failures

| Previous Approach | Why It Failed | How v007 Differs |
|-------------------|---------------|------------------|
| v001-v004: Fuel-based iteration | No guarantee iterations use different formulas | Avoids iteration entirely - proves single-step escape |
| v005: Bounded iteration (5 levels) | Arbitrary depth, same fundamental gap | Single-step escape lemma |
| v006: `denselyOrdered_iff_forall_not_covBy` | Still needs escape from equivalence class | Focuses on proving the escape lemma first |

**The Mathematical Hypothesis**: The intermediate `V` constructed in `density_frame_condition_reflexive_source` satisfies `NOT CanonicalR(V, source)` because:
1. `V` contains `neg delta` where `delta NOT in source`
2. The construction ensures `V` is reflexive or has specific formula properties
3. These properties prevent `GContent(V) subset source`

If this hypothesis is FALSE, we document why and the task is blocked pending new mathematical insight or axiom acceptance.

## Implementation Phases

### Phase 1: Investigate density_escapes_source_class [BLOCKED]

- **Dependencies:** None
- **Goal:** Determine if the density intermediate escapes the source equivalence class

**Mathematical Investigation Strategy**:

The intermediate `V` from `density_frame_condition_reflexive_source` is constructed via:
1. Double-density: `F(F(neg delta)) in source` gives `W1` with `F(neg delta) in W1`
2. Forward witness: `V` from `W1` with `neg delta in V`

Key questions to investigate:
- What constraints does the Lindenbaum extension place on `GContent(V)`?
- Does `neg delta in V` prevent some `G(phi) in V` from having `phi in source`?
- Is there a formula `psi` with `G(psi) in V` and `psi NOT in source`?

**Proof Attempt 1**: Direct formula content analysis
```lean
-- If V ~ source, then GContent(V) subset source
-- Show: exists psi, G(psi) in V and psi NOT in source
-- Candidates:
--   - neg delta itself: is G(neg delta) in V? If so and neg delta NOT in source, done.
--   - delta: G(delta) NOT in V (would give delta in V, contradicting neg delta in V)
```

**Proof Attempt 2**: Use reflexivity propagation
```lean
-- If source is reflexive and V ~ source, is V reflexive?
-- If V is reflexive and neg delta in V, then F(delta) in V (MCS completeness)
-- Does this create a constraint that contradicts GContent(V) subset source?
```

**Proof Attempt 3**: Contrapositive via seriality
```lean
-- V has a strict future (by seriality)
-- If V ~ source, then source's futures are reachable from V
-- Does this create additional formula constraints?
```

**Tasks:**
- [ ] Analyze formula content of density intermediate V in detail
- [ ] Check if Lindenbaum construction places constraints on GContent
- [ ] Attempt proof that `neg delta in V` implies `NOT CanonicalR(V, source)`
- [ ] If proof found: add theorem to DenseTimeline.lean
- [ ] If proof NOT found after 1.5h: document obstruction, mark [BLOCKED]
- [ ] Verify with `lean_goal` and `lake build` if theorem added

**Timing:** 1.5 hours (hard cap - escape valve to [BLOCKED])

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` (if proof found)

**Verification:**
- If proof found: `lake build` passes, theorem compiles without sorry
- If blocked: clear mathematical documentation of the gap

**Progress:**

**Session: 2026-03-13, sess_1773452813_2rz88y**
- Added: `density_intermediate_escapes_source_investigation` theorem stub in DenseTimeline.lean
- Attempted: Direct proof that intermediate escapes source equivalence class
- Attempted: Deriving contradiction from c ~ source hypotheses
- Analyzed: Lindenbaum extension non-constructiveness prevents escape guarantee
- Finding: **CANNOT PROVE** - The Lindenbaum extension is non-constructive. No control over which G-formulas end up in the intermediate MCS. The intermediate MAY have GContent(c) ⊆ source, making c ~ source.
- Mathematical obstruction documented in theorem comment in DenseTimeline.lean:570-605
- Status: Phase 1 is BLOCKED - requires user decision on path forward

**Options for Resolution:**
1. Accept termination axiom (adds proof debt)
2. Find alternative proof strategy not based on single-step escape
3. Modify construction to track formula consumption explicitly
4. Re-scope task to accept bounded-depth iteration with explicit depth parameter

---

### Phase 2: Apply to strict_intermediate_exists [NOT STARTED]

- **Dependencies:** Phase 1 (must succeed, not blocked)
- **Goal:** Simplify and complete `strict_intermediate_exists` using the escape lemma

**Strategy**:
With `density_escapes_source_class` proven, the iteration structure simplifies:
1. Given `[p] < [q]`, apply density to get `c`
2. By `intermediate_not_both_equiv`, `c` is NOT equivalent to both
3. If `c ~ q` and `NOT (c ~ p)`: done, `c` is strict intermediate
4. If `c ~ p` and `NOT (c ~ q)`: apply escape lemma to show this case is impossible OR iterate once with guaranteed escape

The escape lemma should show that when source is reflexive, the intermediate is NOT equivalent to source. Since `c ~ p` implies `c` is reflexive (by transitivity), the next iteration escapes.

**Tasks:**
- [ ] Refactor `strict_intermediate_exists` to use escape lemma
- [ ] Handle the `c ~ p` case using the escape property
- [ ] Resolve sorries at lines 304, 419, 509, 573
- [ ] Verify with `lean_goal`
- [ ] Verify with `lake build`

**Timing:** 0.75 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- Lines 304, 419, 509, 573 have no sorries

---

### Phase 3: Apply to NoMaxOrder and NoMinOrder [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Resolve the reflexive loop escape cases

**Strategy**:
The `NoMaxOrder` sorry (line 734) occurs when:
- We have a chain `p ~ q ~ q' ~ ...` all equivalent
- `p` is reflexive

With the escape lemma: apply density from `p` to any future. The intermediate escapes `p`'s equivalence class, giving a strict upper bound.

Similarly for `NoMinOrder` (line 793).

**Tasks:**
- [ ] Resolve `NoMaxOrder` sorry using escape lemma
- [ ] Resolve `NoMinOrder` sorry symmetrically
- [ ] Verify with `lean_goal`
- [ ] Verify with `lake build`

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification:**
- `lake build` passes
- Lines 733-734, 792-793 have no sorries

---

### Phase 4: Cleanup and Final Verification [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Remove obsolete code, verify zero sorries, ensure build passes

**Tasks:**
- [ ] Remove or simplify obsolete iteration code in `strict_intermediate_exists`
- [ ] Remove dead branches from v005/v006 approaches
- [ ] Run `lake build` - must pass
- [ ] Run `grep -rn "\bsorry\b" CantorApplication.lean` - must return empty
- [ ] Run `grep -rn "\bsorry\b" DenseTimeline.lean` - must return empty
- [ ] Verify `cantor_iso` theorem still compiles
- [ ] Run `grep -n "^axiom " CantorApplication.lean DenseTimeline.lean` - no new axioms

**Timing:** 0.25 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" CantorApplication.lean DenseTimeline.lean` returns empty (zero-debt gate)
- All instances compile without sorry
- No new axioms introduced

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" CantorApplication.lean` returns empty (zero-debt gate)
- [ ] `grep -rn "\bsorry\b" DenseTimeline.lean` returns empty
- [ ] `grep -n "^axiom " CantorApplication.lean DenseTimeline.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] `density_escapes_source_class` compiles without sorry (or phase marked [BLOCKED])
- [ ] `strict_intermediate_exists` has no sorries
- [ ] `DenselyOrdered` instance has no sorries
- [ ] `NoMaxOrder` instance has no sorries
- [ ] `NoMinOrder` instance has no sorries
- [ ] `cantor_iso` theorem compiles

## Artifacts & Outputs

- `plans/implementation-007.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`

## Escape Valve: If Phase 1 Fails

If Phase 1 investigation shows that `density_escapes_source_class` CANNOT be proven:

1. **Document the mathematical obstruction clearly**:
   - What formula configurations allow `V ~ source` despite `neg delta in V`?
   - Is there a counterexample structure?

2. **Mark task [BLOCKED] with `requires_user_review: true`**:
   - `review_reason`: "Mathematical analysis shows density intermediate may not escape source class. See Phase 1 progress notes for details. Options: (a) accept axiom for termination, (b) find alternative proof strategy, (c) revise task scope."

3. **DO NOT**:
   - Add sorries and mark task complete
   - Add axioms without user approval
   - Proceed to Phase 2

## Rollback/Contingency

If implementation fails:
1. Phase 1 blocked: Document findings, mark task [BLOCKED], await user decision
2. Phase 2-4 blocked: Revert changes, investigate specific failure
3. Git: `git checkout -- Theories/Bimodal/Metalogic/StagedConstruction/*.lean`
4. Alternative: Accept termination axiom (research-007 tertiary recommendation) pending user approval
