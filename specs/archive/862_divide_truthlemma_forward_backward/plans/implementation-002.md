# Implementation Plan: Task #862 (Revision 002)

- **Task**: 862 - divide_truthlemma_forward_backward
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/862_divide_truthlemma_forward_backward/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Notes

**v001 -> v002**: The original plan incorrectly framed "functional sorry-freedom" as an acceptable publication state. The user directive is unambiguous:

> The sorry is UNACCEPTABLE because the backwards direction of the TruthLemma cannot be archived easily, and so the forward direction cannot be used without including sorries in the repository, and publication requires sorry free.

This revision refocuses on creating **signpost comments** that:
1. Explain WHY the sorry cannot simply be accepted or ignored
2. Document the structural obstacle (imp case cross-dependency)
3. Guide future attempts toward **viable solutions** (mutual recursion, strong induction)
4. Make clear that current state is **unpublishable** and what must change

## Overview

This task creates publication-quality documentation in TruthLemma.lean that serves as **signposts guiding implementation toward sorry-freedom**, not away from it. The comments must make unmistakably clear that:

1. The temporal backward sorries **block publication**
2. The forward direction **cannot be extracted** without the backward (due to imp cross-dependency)
3. There are **specific viable paths** to resolve this (mutual recursion, strong induction)
4. Simply accepting the sorry or documenting "functional separation" is **not a solution**

### Key Insight: The Trap to Avoid

The obvious (but wrong) suggestion is: "Just use the forward direction, the backward sorries don't affect completeness."

This is a trap because:
- The forward direction of `imp` calls `ih_psi.mpr` (backward IH on subformula)
- You cannot compile a forward-only theorem without the backward existing
- The backward includes temporal sorries
- Therefore: **No sorry-free TruthLemma without resolving the cross-dependency**

## Goals & Non-Goals

**Goals**:
- Create signpost comments that guide toward actual sorry-freedom
- Document the cross-dependency as the **blocking obstacle**
- Explain why "functional separation" is insufficient for publication
- Provide concrete guidance on viable approaches (mutual recursion, strong induction)
- Make the path to resolution visible to future implementers

**Non-Goals**:
- Implementing the separation (that's a future task)
- Accepting/justifying the sorries
- Documenting "workarounds" that avoid the real problem

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Comments being read as "sorries are acceptable" | High | Low | Explicit language that sorries block publication |
| Future readers not finding the cross-dependency | High | Medium | Prominent placement at module docstring level |
| Guidance becoming stale | Medium | Low | Tie to structural properties, not specific line numbers |

## Sorry Characterization

### Pre-existing Sorries

**In TruthLemma.lean** (2 sorries):
- `all_future` (G) backward direction - requires temporal saturation
- `all_past` (H) backward direction - requires temporal saturation

### Impact on Publication

These sorries **block publication** because:
1. The forward direction requires backward IH for imp case
2. Therefore forward cannot be compiled without backward
3. Therefore the entire TruthLemma carries sorry debt
4. Completeness depends on TruthLemma
5. **The repository cannot be published sorry-free in current form**

### Resolution Path

The comments will document that resolution requires:
- **Mutual recursion**: Prove forward and backward together, then extract forward
- **Strong induction**: Use IH that provides both directions for smaller formulas
- **NOT**: Archiving backward, accepting "functional" separation, or ignoring the dependency

## Implementation Phases

### Phase 1: Create WARNING Section at Module Top [NOT STARTED]

**Goal**: Add an unmissable warning about publication status and the cross-dependency obstacle.

**Tasks**:
- [ ] Add prominent warning section after imports
- [ ] State clearly: "This file contains sorries that block publication"
- [ ] State the cross-dependency: "Forward cannot be extracted without backward"
- [ ] Point to the resolution path: mutual recursion or strong induction

**Location**: After line ~10 (after imports), before existing docstring

**Content structure**:
```lean
/-!
# WARNING: Publication Blocked

This file contains `sorry` in the temporal backward direction (G, H cases).
These sorries **block publication** despite completeness only using `.mp`:

## Why "Functional Separation" Is Insufficient

The forward direction of `imp` case uses `ih_psi.mpr` (backward IH on subformula).
Therefore, a forward-only theorem cannot be compiled without the backward existing.
The backward includes temporal sorries → **no sorry-free forward without resolution**.

## Path to Resolution

See "Future Work: Achieving Sorry-Freedom" section below for:
1. Mutual recursion approach
2. Strong induction approach

DO NOT accept the sorries or treat "functional separation" as a publication path.
-/
```

**Timing**: 30 minutes

**Verification**:
- Warning is unmissable at file top
- Cross-dependency is stated explicitly
- "Functional separation" trap is called out
- Resolution path is referenced

---

### Phase 2: Document the Cross-Dependency in Detail [NOT STARTED]

**Goal**: Create detailed section explaining exactly why forward needs backward.

**Tasks**:
- [ ] Add `/-! ## The Cross-Dependency Obstacle -/` section
- [ ] Show the exact code from imp case that creates the dependency
- [ ] Provide the full dependency table
- [ ] Explain why this means archiving backward doesn't work

**Location**: After the theorem statement documentation, before the proof

**Content structure**:
```lean
/-!
## The Cross-Dependency Obstacle

### Why Forward Needs Backward (imp case)

```
-- Forward: (psi -> chi) in MCS -> (bmcs_truth psi -> bmcs_truth chi)
intro h_imp h_psi_true
have h_psi_mcs : psi in fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true  -- Uses .mpr!
```

To apply modus ponens, we need `psi in MCS`. We have `bmcs_truth psi`.
Converting truth → membership requires `.mpr` (backward) on subformula psi.

### Dependency Table

| Case | Forward uses | Backward uses |
|------|--------------|---------------|
| atom | nothing | nothing |
| bot | nothing | nothing |
| **imp** | **ih_psi.mpr** | ih_psi.mp, ih_chi.mpr |
| box | ih.mp only | ih.mpr only |
| G/H | ih.mp only | ih.mpr only |

The `imp` case is the ONLY cross-dependency. But it is sufficient to block separation.

### Why Archiving Backward Fails

If backward is archived to Boneyard/:
- Forward proof cannot compile (ih_psi.mpr doesn't exist)
- Lean 4 requires the full IFF for the inductive argument
- The proof structure fundamentally requires both directions

This is NOT a documentation problem. It's a structural obstacle requiring code changes.
-/
```

**Timing**: 40 minutes

**Verification**:
- Code showing ih_psi.mpr is included
- Dependency table is accurate
- Archiving failure is explained
- Structural nature of obstacle is clear

---

### Phase 3: Add "Future Work: Achieving Sorry-Freedom" Section [NOT STARTED]

**Goal**: Provide actionable guidance for future implementers to actually solve this.

**Tasks**:
- [ ] Add section documenting mutual recursion approach with sketch
- [ ] Add section documenting strong induction approach with sketch
- [ ] Explain trade-offs of each
- [ ] Make clear these are the ONLY paths to sorry-free publication

**Location**: After the theorem, before EvalBMCS section

**Content structure**:
```lean
/-!
## Future Work: Achieving Sorry-Freedom

### Option 1: Mutual Recursion (Recommended)

Define forward and backward as separate but mutually-recursive theorems:

```
mutual
  theorem bmcs_truth_lemma_forward ... :=
    phi in fam.mcs t -> bmcs_truth_at B fam t phi := by
    induction phi with
    | imp psi chi ih_fwd_psi ih_fwd_chi =>
        intro h_imp h_truth_psi
        have h_psi_mcs := bmcs_truth_lemma_backward ... psi h_truth_psi  -- Call backward
        ...

  theorem bmcs_truth_lemma_backward ... :=
    bmcs_truth_at B fam t phi -> phi in fam.mcs t := by
    -- Temporal cases can have sorry here, isolated from forward
end
```

**Advantage**: Clear separation, temporal sorries isolated in backward only.
**Challenge**: Lean 4 termination checking for mutual theorem recursion.

### Option 2: Strong Induction

Use induction on formula size, where IH gives BOTH directions for smaller formulas:

```
theorem bmcs_truth_lemma_forward ... := by
  induction phi using Formula.strongInduction with
  | _ phi ih =>  -- ih: forall psi < phi, psi in MCS <-> bmcs_truth psi
    match phi with
    | imp psi chi =>
        have h_psi_iff := ih psi (subformula_imp_left ...)
        have h_psi_mcs := h_psi_iff.mpr h_truth_psi  -- Full IFF available
        ...
```

**Advantage**: Proves forward independently once infrastructure exists.
**Challenge**: Requires defining subformula ordering and strongInduction.

### What Does NOT Work

- "Functional separation": Forward can't compile without backward
- Archiving backward: Same problem
- Accepting sorries: Blocks publication
- Documenting the workaround: This is not a workaround, it's an obstacle
-/
```

**Timing**: 45 minutes

**Verification**:
- Both approaches have code sketches
- Trade-offs explained
- "What does not work" section explicitly listed
- Future implementer has actionable starting point

---

### Phase 4: Update Inline Comments in Proof [NOT STARTED]

**Goal**: Add signpost comments at critical points in the actual proof.

**Tasks**:
- [ ] Add comment at imp case forward marking the cross-dependency
- [ ] Add comment at temporal backward cases marking the publication blocker
- [ ] Add comment at box case celebrating it as fully proven
- [ ] Remove any language suggesting sorries are acceptable

**Locations**:
- Imp case (around line 321-325): Mark the .mpr usage
- Temporal backward cases (lines 403, 419): Mark as publication blockers
- Box case: Note it's the modal completeness achievement

**Timing**: 25 minutes

**Verification**:
- Each critical point has a signpost
- No language suggesting sorries are acceptable
- Reader following the proof understands the obstacle

---

### Phase 5: Final Review and Build Verification [NOT STARTED]

**Goal**: Ensure documentation is coherent and builds succeed.

**Tasks**:
- [ ] Run `lake build` to verify no syntax errors
- [ ] Read through all new documentation for consistency
- [ ] Verify narrative: obstacle -> what doesn't work -> what will work
- [ ] Ensure no mixed messages about acceptability of sorries

**Timing**: 30 minutes

**Verification**:
- `lake build` succeeds
- Documentation tells single coherent story
- No reader could mistake this as "sorries are fine"
- Future implementer knows exactly what to do

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] WARNING section is first thing reader sees
- [ ] Cross-dependency is documented with code evidence
- [ ] Future Work section provides actionable paths
- [ ] No language anywhere suggesting sorries are acceptable
- [ ] Inline comments mark critical points

## Artifacts & Outputs

- `specs/862_divide_truthlemma_forward_backward/plans/implementation-002.md` (this file)
- `specs/862_divide_truthlemma_forward_backward/summaries/implementation-summary-YYYYMMDD.md` (after completion)

## Rollback/Contingency

Changes are documentation-only. Rollback via `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` if needed.

---

## Appendix: User Directive (Preserved)

> The comments should aim to be sign posts to help guide implementation away from the bad suggestion to accept the sorry. The sorry is UNACCEPTABLE because the backwards direction of the TruthLemma cannot be archived easily, and so the forward direction cannot be used without including sorries in the repository, and publication requires sorry free.
