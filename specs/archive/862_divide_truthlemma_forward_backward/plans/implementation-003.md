# Implementation Plan: Task #862 (Revision 003)

- **Task**: 862 - divide_truthlemma_forward_backward
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/862_divide_truthlemma_forward_backward/reports/research-001.md
  - specs/862_divide_truthlemma_forward_backward/reports/research-002.md
  - specs/843_remove_singleFamily_modal_backward_axiom/reports/research-005.md
  - specs/857_add_temporal_backward_properties/reports/research-007.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Notes

**v002 -> v003**: Research-002 (Task 862), research-005 (Task 843), and research-007 (Task 857) have definitively established:

1. **Separation strategies (mutual recursion, strong induction) do NOT work** - they reorganize code but cannot eliminate sorries
2. **The ONLY path to sorry-free publication is completing the temporal saturation proofs** via modified Lindenbaum construction
3. **Comments about "completeness only uses forward" are misleading and must be removed** - the backward direction cannot be archived, so this is irrelevant

This revision creates documentation that:
- Removes all misleading claims about functional separation being sufficient
- Removes suggestions for mutual recursion or strong induction (proven ineffective)
- Guides future work toward the ACTUAL solution: modified Lindenbaum for temporal saturation
- Documents the mathematical path clearly

## Overview

This task creates publication-quality documentation in TruthLemma.lean that serves as **signposts guiding implementation toward completing the TruthLemma in full** (both directions, all cases). The comments must:

1. **Remove distracting claims** that "completeness only uses forward" - this is irrelevant because backward cannot be archived
2. **Remove ineffective suggestions** like mutual recursion and strong induction - research proves these don't help
3. **Document the actual path**: Modified Lindenbaum construction for temporal saturation
4. **Explain the mathematical gap**: Multi-witness consistency in the saturation construction

### Key Insight from Research

From research-007.md (Task 857):

> The sorries are in CONSTRUCTION, not in the theorems themselves. The temporal backward theorems `temporal_backward_G` and `temporal_backward_H` in TemporalCoherentConstruction.lean ARE proven for `TemporalCoherentFamily`. The sorries are in the CONSTRUCTION of such families.

The mathematical gap is **modified Lindenbaum that preserves temporal saturation**:

```
Given: MCS M where F(psi_i) ∈ M for i ∈ I
Want: SetConsistent (M ∪ {psi_i | i ∈ I})
```

The existing `temporal_witness_seed_consistent` proves consistency for SINGLE witnesses, but not MULTI-witness consistency.

## Goals & Non-Goals

**Goals**:
- Remove misleading comments about "functional separation" or "completeness only uses forward"
- Remove ineffective guidance toward mutual recursion or strong induction
- Document the actual mathematical path: modified Lindenbaum for temporal saturation
- Explain WHY separation strategies fail (research-002 findings)
- Guide future implementers toward the correct construction approach

**Non-Goals**:
- Implementing the temporal saturation construction (that's Task 857)
- Documenting "workarounds" that don't actually work
- Preserving any language suggesting sorries are acceptable for publication

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Future readers trying separation strategies | High | Medium | Explicit section explaining WHY they fail |
| Mathematical path being too abstract | Medium | Medium | Include concrete lemma statements from research-007 |
| Comments becoming stale | Medium | Low | Tie to structural properties, reference research reports |

## Sorry Characterization

### Pre-existing Sorries

**In TruthLemma.lean** (2 sorries):
- `all_future` (G) backward direction - requires temporal saturation
- `all_past` (H) backward direction - requires temporal saturation

### The Actual Blocker

From research-005.md:

> The sorries are in `temporal_eval_saturated_bundle_exists` (TemporalCoherentConstruction.lean lines 541-749):
> - Line 724: Forward saturation (F(psi) ∈ M → psi ∈ M)
> - Line 727: Backward saturation (P(psi) ∈ M → psi ∈ M)

The sorries exist because **standard Lindenbaum extension does NOT preserve temporal saturation**.

### Resolution Path

From research-007.md:

1. **Implement `temporalLindenbaumMCS`** with witness insertion during enumeration
2. **Prove consistency preservation** at each step using `temporal_witness_seed_consistent`
3. **Show the result is temporally saturated** by construction

Estimated effort: 8-12 hours of careful proof development (Task 857 scope).

## Implementation Phases

### Phase 1: Remove Misleading Comments About Functional Separation [COMPLETED]

**Goal**: Remove all language suggesting that "completeness only uses forward" is a reason to accept sorries.

**Tasks**:
- [ ] Search for comments containing "completeness only uses" or similar
- [ ] Search for comments containing "forward direction is sufficient"
- [ ] Remove or replace with accurate statements about why sorries block publication
- [ ] Remove any language suggesting temporal sorries are "acceptable" or "tolerated"

**Location**: Throughout TruthLemma.lean, especially module docstring

**Content to REMOVE** (examples):
- "The completeness theorems only use `.mp` (forward direction)"
- "The temporal backward sorries don't affect completeness"
- "Functionally sorry-free for completeness purposes"

**Content to ADD instead**:
```lean
/-!
# Publication Status: BLOCKED

This file contains `sorry` in temporal backward cases (G, H). These sorries
**block publication** because:

1. The forward direction requires backward direction on subformulas (imp case)
2. The backward direction cannot be archived (forward depends on it)
3. Therefore the entire file carries sorry debt

The sorries represent genuine incomplete proofs in the **temporal saturation
construction**, not architectural issues that can be worked around.

See "Path to Resolution" section below.
-/
```

**Timing**: 30 minutes

**Verification**:
- No comments suggest sorries are acceptable
- No language about "functional separation" remains
- Publication-blocking status is clear

---

### Phase 2: Remove Ineffective Solution Suggestions [COMPLETED]

**Goal**: Remove guidance toward mutual recursion or strong induction (proven ineffective by research-002).

**Tasks**:
- [ ] Remove any code sketches for mutual recursion approach
- [ ] Remove any code sketches for strong induction approach
- [ ] Remove "Future Work" sections suggesting these strategies
- [ ] Add section explaining WHY these don't work (brief summary from research)

**Content to REMOVE**:
- Code sketches showing `mutual` blocks
- Code sketches showing `Formula.strongInduction`
- Suggestions that these could "separate" forward from backward

**Content to ADD instead**:
```lean
/-!
## Why Separation Strategies Fail

Research (Task 862 research-002) definitively established:

### Mutual Recursion Does NOT Help
Forward calls backward (imp case uses `ih_psi.mpr`). If forward and backward
are mutually recursive, backward must exist in active code. Backward has temporal
sorries. Therefore sorries remain in active code. Reorganization ≠ elimination.

### Strong Induction Does NOT Help
Strong induction where IH provides both directions for smaller formulas still
requires proving BOTH directions. The temporal backward cases still need temporal
saturation properties that don't exist. Strong induction changes WHEN we can
assume something, not WHAT we must prove.

### The Fundamental Issue
The imp forward case MUST convert `bmcs_truth ψ` to `ψ ∈ MCS` (backward on ψ).
This is inherent in bridging syntactic (MCS) and semantic (truth) worlds.
No reformulation avoids this.
-/
```

**Timing**: 25 minutes

**Verification**:
- No mutual recursion or strong induction code sketches remain
- Clear explanation of why these fail
- No false hope given to future readers

---

### Phase 3: Document the Actual Mathematical Path [COMPLETED]

**Goal**: Add clear documentation of the CORRECT path to sorry-freedom: modified Lindenbaum construction.

**Tasks**:
- [ ] Add section explaining where the actual sorries live (construction, not theorems)
- [ ] Document the mathematical gap: multi-witness consistency
- [ ] Provide concrete lemma statements needed (from research-007)
- [ ] Reference Task 857 as the implementation task

**Content to ADD**:
```lean
/-!
## Path to Resolution: Modified Lindenbaum Construction

The sorries in temporal backward are in the **construction** of temporally
saturated families, not in the theorems themselves. The theorems
`temporal_backward_G` and `temporal_backward_H` ARE proven in
TemporalCoherentConstruction.lean for `TemporalCoherentFamily` structures.

### The Mathematical Gap

Standard Lindenbaum extension (`lindenbaumMCS`) does NOT preserve temporal
saturation. Given `F(ψ) ∈ M`:
- `F(ψ) = ¬G(¬ψ)` says "not always ¬ψ" (eventually ψ at SOME future time)
- M can consistently contain `F(ψ)` AND `¬ψ` (at THIS time)
- The witness ψ must be at a DIFFERENT time, but we only have one MCS M

### Required Construction: `temporalLindenbaumMCS`

```
temporalLindenbaumMCS(Gamma, h_cons):
  M := contextAsSet Gamma
  for phi in enumFormulas:
    if consistent(M ∪ {phi}):
      M := M ∪ {phi}
      -- Temporal witness step
      if phi = F(psi) for some psi:
        if consistent(M ∪ {psi}):
          M := M ∪ {psi}
      if phi = P(psi) for some psi:
        if consistent(M ∪ {psi}):
          M := M ∪ {psi}
  return M
```

### Key Lemma Required

```lean
theorem temporal_witness_addable (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent (M ∪ {psi})
```

This uses `temporal_witness_seed_consistent` (already exists) and requires
showing M contains its own GContent via T-axiom iteration.

### Implementation Task

Task 857 addresses this construction. Estimated effort: 8-12 hours.
-/
```

**Timing**: 40 minutes

**Verification**:
- Mathematical gap is clearly explained
- Concrete algorithm sketch provided
- Key lemma statement included
- Task 857 referenced

---

### Phase 4: Update Inline Comments in Proof Cases [COMPLETED]

**Goal**: Update inline comments to reflect accurate understanding.

**Tasks**:
- [ ] Update imp case comment to note this is the cross-dependency source
- [ ] Update temporal backward case comments to reference construction gap (not "future work")
- [ ] Update box case to note it's fully proven (modal saturation complete)
- [ ] Remove any language suggesting sorries are "tolerated"

**Locations**:
- Imp case: Note this uses `.mpr` on subformula (cross-dependency source)
- G/H backward: Reference `temporal_eval_saturated_bundle_exists` as the actual gap
- Box case: Celebrate as fully proven via completed modal saturation

**Timing**: 20 minutes

**Verification**:
- Each sorry has comment explaining WHERE the real gap is
- No language suggesting "acceptable" or "tolerated"
- Cross-references to construction files are accurate

---

### Phase 5: Final Review and Build Verification [COMPLETED]

**Goal**: Ensure documentation is coherent and accurate.

**Tasks**:
- [ ] Run `lake build` to verify no syntax errors
- [ ] Read through all documentation for consistency
- [ ] Verify no remaining references to mutual recursion or strong induction as solutions
- [ ] Verify no remaining "completeness only uses forward" language
- [ ] Ensure narrative: sorries → actual gap location → correct path

**Timing**: 25 minutes

**Verification**:
- `lake build` succeeds
- Documentation tells single coherent story
- Future implementer knows EXACTLY what to do (Task 857)
- No false paths suggested

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] No "completeness only uses forward" language remains
- [ ] No mutual recursion or strong induction suggestions remain
- [ ] Mathematical path (modified Lindenbaum) is documented with concrete lemmas
- [ ] All sorries have comments pointing to actual gap location
- [ ] Task 857 is referenced as the resolution path

## Artifacts & Outputs

- `specs/862_divide_truthlemma_forward_backward/plans/implementation-003.md` (this file)
- `specs/862_divide_truthlemma_forward_backward/summaries/implementation-summary-YYYYMMDD.md` (after completion)

## Rollback/Contingency

Changes are documentation-only. Rollback via `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` if needed.

---

## Appendix: User Directive (Preserved)

> Draw on research-005.md and research-007.md to improve the plan to clean up the comments to guide future work towards completing the TruthLemma in full (not merely the forwards direction, or an eval-only version which doesn't work) by identifying the correct way to construct the seed and saturate the construction. The comments don't have to provide the answer, but the need to remove distracting and inaccurate comments that claim the completeness only depends on the forward direction (this is irrelevant because the backwards direction cannot be eliminated) and to include comments that support a high quality solution that is mathematically correct and elegant.

## Appendix: Key Research Findings Summary

### From research-002.md (Task 862):
- Mutual recursion does NOT achieve sorry-freedom - just reorganizes code
- Strong induction does NOT help - IH still requires full IFF
- Alternative proof reformulations don't exist - imp forward inherently needs backward
- Only path: complete temporal saturation proofs

### From research-005.md (Task 843):
- Eval-Only (EvalBMCS) does NOT work for sorry-free truth lemma
- Full BMCS approach remains cleanest
- Temporal backward follows same pattern as modal backward

### From research-007.md (Task 857):
- Sorries are in CONSTRUCTION, not theorems
- Mathematical gap: multi-witness consistency in modified Lindenbaum
- Automatic saturation disproved by semantic analysis
- Required approach: Modified Lindenbaum with formula enumeration and witness addition
