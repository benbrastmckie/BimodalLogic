# Implementation Plan: Wire Dense Completeness Domain Connection (v8)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [PARTIAL]
- **Effort**: 10-14 hours (5 phases)
- **Dependencies**: None (prior phases 1-3 from v7 completed: SeparatedTaskFrame.lean, SeparatedHistory.lean exist)
- **Research Inputs**:
  - research-011.md (Option C: CanonicalMCS all-MCS approach - **primary**)
  - research-009.md (W vs D semantics architecture)
- **Artifacts**: plans/implementation-008.md (this file), supersedes implementation-001 through 007.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Progress

**Session: 2026-03-17, sess_1773760161_eca24d**
- Completed: Phase 1 (Verify CanonicalMCS BFMCS Infrastructure)
- Verified: `canonicalMCS_forward_F` and `canonicalMCS_backward_P` are sorry-free
- Verified: `temporal_coherent_family_exists_CanonicalMCS` is sorry-free
- Blocked: Phase 3 requires `[LinearOrder D]` but CanonicalMCS is only `Preorder`
- Impact: Phases 2-5 cannot proceed without architectural resolution
- Summary: Plan v8 approach encounters fundamental type constraint mismatch

## Revision History

**v008 (2026-03-17)**: **STRATEGY PIVOT** based on research-011.md. The key insight from the deep analysis:

Option C IS the correct path. The `canonicalMCSBFMCS` (all-MCS approach) already has **PROVEN** (sorry-free) `forward_F` and `backward_P` because ALL MCS are in the domain. The TimelineQuot sorries exist because staged construction witnesses may escape the timeline (m > 2k edge case).

**The Two-Stage Validity Approach**:
1. Use CanonicalMCS BFMCS for truth lemma (forward_F/backward_P already proven)
2. Prove completeness: `bmcs_valid phi -> |- phi`
3. Connect to TaskFrame: `valid_over_TimelineQuot phi -> bmcs_valid phi`
4. Extend to arbitrary dense D via Cantor isomorphism

**v007**: SUPERSEDED. W/D separation was correct architecture but didn't resolve BFMCS coherence (forward_F/backward_P/modal_backward sorries remain in ClosureSaturation.lean).

## Executive Summary

### The Key Insight (research-011)

The completeness proof does NOT need forward_F/backward_P to be proven for TimelineQuot. Instead:

1. **CanonicalMCS has PROVEN forward_F/backward_P** (lines 222-251 of CanonicalFMCS.lean)
2. **Use CanonicalMCS for the truth lemma** - it's a Preorder (not LinearOrder), but the truth lemma doesn't require LinearOrder
3. **Connect to TaskFrame validity via TimelineQuot embedding** - TimelineQuot provides the LinearOrder + AddCommGroup
4. **Completeness follows** from the CanonicalMCS-based countermodel construction

**CORRECTION (sess_1773760161_eca24d)**: Point 2 is INCORRECT. The ParametricTruthLemma (line 49) DOES require `[LinearOrder D]`. This blocks the plan. See Phase 3 status for details.

### Architecture Diagram

```
TaskFrame (D with AddCommGroup + LinearOrder)
    |
    | validity definition
    v
TimelineQuot (Cantor ~= Q, provides density + group structure)
    |
    | embed into CanonicalMCS world states
    v
CanonicalMCS (all MCS, forward_F/backward_P PROVEN)
    |
    | truth lemma (Preorder sufficient)
    v
|- phi (completeness via countermodel)
```

### What's Already Done

From previous implementation efforts:
- `SeparatedTaskFrame.lean` - D = TimelineQuot, W = ParametricCanonicalWorldState (EXISTS)
- `SeparatedHistory.lean` - WorldHistory with shift-closed Omega (EXISTS)
- `CanonicalFMCS.lean` - canonicalMCSBFMCS with sorry-free forward_F/backward_P (EXISTS)
- `ParametricTruthLemma.lean` - D-parametric truth lemma for BFMCS (EXISTS)

### What Needs to Be Done

1. **Instantiate truth lemma for CanonicalMCS** (not TimelineQuot) with BFMCS coherence
2. **Build BFMCS over CanonicalMCS** with modal saturation (modal_backward)
3. **Prove completeness** for CanonicalMCS BFMCS validity
4. **Connect validity definitions** (TaskFrame validity -> BFMCS validity)
5. **Wire final theorem** via Cantor isomorphism

## Goals & Non-Goals

**Goals**:
- Complete `dense_completeness_theorem` using CanonicalMCS-based approach
- Prove truth lemma for CanonicalMCS BFMCS (not TimelineQuot)
- Build modal-saturated BFMCS over CanonicalMCS
- Connect TaskFrame validity to BFMCS validity
- Zero new sorries, zero new axioms

**Non-Goals**:
- Prove forward_F/backward_P for TimelineQuot (bypass via CanonicalMCS)
- Fix the m > 2k edge case in ClosureSaturation.lean (bypassed)
- Build singleton BFMCS (use multi-family modal saturation instead)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth lemma requires LinearOrder | High | Low | ParametricTruthLemma uses Preorder for temporal; only Box needs BFMCS coherence |
| Modal saturation over CanonicalMCS is complex | Medium | Medium | Use existing ModalSaturation.lean patterns |
| Validity transfer via Cantor is subtle | Medium | Low | Mathlib provides order isomorphism machinery |
| BFMCS temporally_coherent proof blocked | Medium | Medium | Mark [BLOCKED] with requires_user_review if stuck |

## Sorry Characterization

### Pre-existing Sorries (Out of Scope)
- `timelineQuotFMCS_forward_F` (ClosureSaturation.lean:659) - **BYPASSED** (use CanonicalMCS instead)
- `timelineQuotFMCS_backward_P` (ClosureSaturation.lean:679) - **BYPASSED** (use CanonicalMCS instead)
- `timelineQuotSingletonBFMCS.modal_backward` (ClosureSaturation.lean:724) - **BYPASSED** (use CanonicalMCS multi-family)
- `timelineQuot_not_valid_of_neg_consistent` (TimelineQuotCompleteness.lean:127) - **TO BE RESOLVED** in Phase 5
- Various sorries in IntBFMCS.lean, Soundness.lean, DiscreteSuccSeed.lean - **OUT OF SCOPE**

### Expected Resolution
- Phase 3 resolves the need for forward_F/backward_P by using CanonicalMCS instead of TimelineQuot
- Phase 5 resolves `timelineQuot_not_valid_of_neg_consistent` by connecting to CanonicalMCS truth lemma

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - Document blocker in metadata

### Remaining Debt
After this implementation:
- TimelineQuot-based sorries remain but are bypassed (not on critical path)
- IntBFMCS and Soundness sorries remain (separate tasks)

## Axiom Characterization

### Pre-existing Axioms (Out of Scope)
- `canonicalR_irreflexive_axiom` (CanonicalDomain.lean) - Standard assumption for bimodal logic
- `discrete_Icc_finite_axiom` (DiscreteTimeline.lean) - Discrete completeness only

### Expected Resolution
- No axioms will be added or removed by this task

### New Axioms
- None. NEVER introduce new axioms.

### Remaining Debt
After this implementation:
- `canonicalR_irreflexive_axiom` remains (fundamental to semantics, not technical debt)

## Implementation Phases

### Phase 1: Verify CanonicalMCS BFMCS Infrastructure [COMPLETED]

- **Dependencies**: None
- **Goal**: Confirm CanonicalMCS has all infrastructure needed for truth lemma

**Key Verification Points:**

1. **CanonicalMCS FMCS exists**:
   ```lean
   #check @canonicalMCSBFMCS -- FMCS CanonicalMCS
   ```

2. **Forward_F/Backward_P are proven**:
   ```lean
   #check @canonicalMCS_forward_F -- No sorry
   #check @canonicalMCS_backward_P -- No sorry
   ```

3. **TemporalCoherentFamily exists**:
   ```lean
   #check @temporal_coherent_family_exists_CanonicalMCS -- No sorry
   ```

4. **Check if CanonicalMCS can be a BFMCS domain**:
   - BFMCS needs `[Preorder D]` - CanonicalMCS has this
   - modal_forward/modal_backward need proof

**Tasks**:
- [ ] Read CanonicalFMCS.lean to verify forward_F/backward_P are truly sorry-free
- [ ] Read ModalSaturation.lean to understand modal_backward requirements
- [ ] Check ParametricTruthLemma requirements - does it need LinearOrder?
- [ ] Document interface between FMCS, BFMCS, and TemporalCoherentFamily

**Timing**: 1.5 hours

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - READ
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - READ
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - READ

**Verification**:
- Document findings showing CanonicalMCS is suitable for truth lemma
- If not suitable: identify specific blockers

---

### Phase 2: Build Modal-Saturated BFMCS over CanonicalMCS [BLOCKED]

**BLOCKER (Session sess_1773760161_eca24d)**: Phase 3 (Truth Lemma) is blocked because ParametricTruthLemma requires `[LinearOrder D]` but CanonicalMCS is only `Preorder`. Without a working truth lemma, subsequent phases cannot proceed.

**Status**: Phase 2 implementation is possible (ModalSaturation.lean infrastructure exists), but completing it would not unblock Phase 3. Recommend resolving the LinearOrder requirement before proceeding.

**Original Plan (preserved for reference)**:

- **Dependencies**: Phase 1
- **Goal**: Construct BFMCS over CanonicalMCS with proven modal_forward and modal_backward

**The Modal Saturation Strategy**:

A singleton BFMCS cannot prove modal_backward (psi in all families -> Box psi in family). Multi-family BFMCS resolves this via:
1. For each (t, phi), if Diamond(phi) is consistent at t, add a witness family
2. modal_forward: psi in family at t for all families -> Diamond(psi) valid
3. modal_backward: Box(psi) at t follows from psi everywhere

**Construction (from ModalSaturation.lean pattern)**:

```lean
/-- Multi-family BFMCS over CanonicalMCS with modal saturation. -/
noncomputable def canonicalMCSModalSaturatedBFMCS
    (root_mcs : Set Formula) (h_mcs : SetMaximalConsistent root_mcs) :
    BFMCS CanonicalMCS where
  families := -- Set of FMCS indexed by modal witness requirements
  nonempty := ⟨canonicalMCSBFMCS, ...⟩
  modal_forward := by ...
  modal_backward := by ...
  eval_family := canonicalMCSBFMCS
  eval_family_mem := ...
```

**Tasks**:
- [ ] Define modal witness requirements for CanonicalMCS
- [ ] Construct family set covering all modal witness needs
- [ ] Prove modal_forward (Box phi in fam.mcs t -> phi in fam'.mcs t)
- [ ] Prove modal_backward (phi in all fam.mcs t -> Box phi in fam.mcs t)
- [ ] If proof blocks: mark [BLOCKED] with review_reason

**Timing**: 3-4 hours

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalMCSBFMCS.lean` - CREATE

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalMCSBFMCS` passes
- `grep -n "\bsorry\b" CanonicalMCSBFMCS.lean` returns empty

---

### Phase 3: Truth Lemma for CanonicalMCS BFMCS [BLOCKED]

**BLOCKER (Session sess_1773760161_eca24d)**: ParametricTruthLemma.lean line 49 requires:
```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

CanonicalMCS is only `Preorder` (not LinearOrder, not AddCommGroup). The parametric truth lemma cannot be instantiated for CanonicalMCS.

**Options to Unblock**:
1. Create CanonicalMCS-specific truth lemma using only Preorder (major effort)
2. Prove CanonicalMCS is actually total (unlikely - counterexamples exist)
3. Use Int-based completeness and document dense completeness as future work
4. Find alternative proof path that doesn't require BFMCS over CanonicalMCS

**Original Plan (preserved for reference)**:

- **Dependencies**: Phase 2
- **Goal**: Prove truth lemma: phi in fam.mcs t <-> truth_at model Omega history t phi

**The Truth Lemma for CanonicalMCS**:

The ParametricTruthLemma is parameterized by D. We need to verify it works for D = CanonicalMCS:

```lean
-- Need to check: Does ParametricTruthLemma require [LinearOrder D]?
-- Looking at line 49: variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
-- YES - it requires LinearOrder and AddCommGroup!

-- BUT: CanonicalMCS is only Preorder, not LinearOrder or AddCommGroup
-- RESOLUTION: Build a new truth lemma specifically for CanonicalMCS
-- that uses Preorder for temporal quantification
```

**Alternative Approach**:

If ParametricTruthLemma requires LinearOrder, we create a specialized truth lemma for CanonicalMCS that only uses Preorder:

```lean
/-- Truth lemma for CanonicalMCS BFMCS (Preorder-based).
    phi in fam.mcs t <-> truth_canonical_at model t phi

    Key difference from ParametricTruthLemma:
    - Uses Preorder for temporal quantification (not LinearOrder)
    - No AddCommGroup required
    - No shift-closed Omega (histories are just FMCS mappings) -/
theorem canonicalMCS_truth_lemma
    (B : BFMCS CanonicalMCS) (h_tc : B.temporally_coherent)
    (fam : FMCS CanonicalMCS) (hfam : fam ∈ B.families)
    (t : CanonicalMCS) (phi : Formula) :
    phi ∈ fam.mcs t ↔ truth_canonical_at ... := by
  induction phi generalizing fam t with
  | atom p => ...
  | bot => ...
  | imp psi chi ih_psi ih_chi => ...
  | box psi ih => -- Uses modal_forward/modal_backward from B
  | all_future psi ih => -- Uses forward_G and forward_F from h_tc
  | all_past psi ih => -- Uses backward_H and backward_P from h_tc
```

**Tasks**:
- [ ] Verify ParametricTruthLemma requirements (LineraOrder? AddCommGroup?)
- [ ] If needed: Create CanonicalMCS-specific truth lemma definition
- [ ] If needed: Create CanonicalMCS-specific Omega (set of histories)
- [ ] Prove truth lemma by induction on phi
- [ ] Handle Box case using modal saturation from Phase 2
- [ ] Handle G/H cases using forward_F/backward_P from canonicalMCSBFMCS

**Timing**: 3-4 hours

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalMCSTruthLemma.lean` - CREATE

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalMCSTruthLemma` passes
- `grep -n "\bsorry\b" CanonicalMCSTruthLemma.lean` returns empty

---

### Phase 4: Completeness via CanonicalMCS Countermodel [BLOCKED]

**BLOCKER**: Depends on Phase 3 (Truth Lemma). Cannot proceed until Phase 3 is unblocked.

**Original Plan (preserved for reference)**:

- **Dependencies**: Phase 3
- **Goal**: Prove completeness: not provable -> satisfiable countermodel in CanonicalMCS

**The Completeness Argument**:

```lean
/-- Completeness for CanonicalMCS BFMCS:
    If phi is not provable, there exists a countermodel. -/
theorem canonicalMCS_completeness (phi : Formula) :
    ¬(Nonempty ([] ⊢ phi)) →
    ∃ (B : BFMCS CanonicalMCS) (fam : FMCS CanonicalMCS) (hfam : fam ∈ B.families)
      (t : CanonicalMCS),
      phi.neg ∈ fam.mcs t ∧ B.temporally_coherent := by
  intro h_not_prov
  -- Step 1: neg(phi) is consistent
  have h_cons := not_provable_implies_neg_consistent phi h_not_prov
  -- Step 2: Extend to MCS M₀ via Lindenbaum
  obtain ⟨M₀, h_mcs, h_neg_in⟩ := set_lindenbaum {phi.neg} h_cons
  -- Step 3: Build modal-saturated BFMCS with M₀ as root
  let B := canonicalMCSModalSaturatedBFMCS M₀ h_mcs
  -- Step 4: canonicalMCSBFMCS rooted at M₀ is the eval_family
  -- phi.neg in M₀ = fam.mcs(root)
  exact ⟨B, B.eval_family, B.eval_family_mem, ⟨M₀, h_mcs⟩, h_neg_in, ...⟩
```

**Tasks**:
- [ ] Prove `not_provable_implies_neg_consistent`
- [ ] Connect Lindenbaum extension to CanonicalMCS
- [ ] Wire modal-saturated BFMCS construction from Phase 2
- [ ] Prove temporal coherence of the constructed BFMCS
- [ ] State and prove `canonicalMCS_completeness`

**Timing**: 2-3 hours

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalMCSCompleteness.lean` - CREATE

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalMCSCompleteness` passes
- `grep -n "\bsorry\b" CanonicalMCSCompleteness.lean` returns empty

---

### Phase 5: Wire Dense Completeness Theorem [BLOCKED]

**BLOCKER**: Depends on Phase 4 (Completeness). Cannot proceed until Phase 4 is unblocked.

**Original Plan (preserved for reference)**:

- **Dependencies**: Phase 4
- **Goal**: Connect CanonicalMCS completeness to dense validity over TimelineQuot

**The Connection Strategy**:

The gap: CanonicalMCS completeness gives us `not_provable -> countermodel`, but we need `valid_over_dense_D -> provable`.

**Approach A: Direct contraposition**:
```lean
theorem dense_completeness_theorem :
    (∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [DenselyOrdered D]
       [NoMinOrder D] [NoMaxOrder D], valid_over D φ) →
    Nonempty ([] ⊢ φ) := by
  intro h_valid
  by_contra h_not_prov
  -- Get countermodel in CanonicalMCS
  obtain ⟨B, fam, hfam, t, h_neg, h_tc⟩ := canonicalMCS_completeness φ h_not_prov
  -- By truth lemma: neg(phi) is TRUE in CanonicalMCS model
  have h_neg_true := (canonicalMCS_truth_lemma B h_tc fam hfam t φ.neg).mp h_neg
  -- Need to show: valid_over TimelineQuot contradicts h_neg_true
  -- This requires connecting CanonicalMCS truth to TimelineQuot validity
  ...
```

**Approach B: Two-stage via BFMCS validity**:
1. Define `bmcs_valid phi` := forall BFMCS, phi is true everywhere
2. Prove `canonicalMCS_completeness`: not bmcs_valid -> not provable (contrapositive of completeness)
3. Prove `valid_over_TimelineQuot -> bmcs_valid` (embed TimelineQuot into BFMCS)
4. Combine: `valid_over_TimelineQuot -> provable`

**Tasks**:
- [ ] Choose connection approach (A or B)
- [ ] If B: Define `bmcs_valid` and prove soundness direction
- [ ] Connect TimelineQuot validity to CanonicalMCS/BFMCS validity
- [ ] Wire final `dense_completeness_theorem`
- [ ] Resolve `timelineQuot_not_valid_of_neg_consistent` in TimelineQuotCompleteness.lean
- [ ] Run full `lake build` verification

**Timing**: 2-3 hours

**Files**:
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - MODIFY
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFY

**Verification**:
- `lake build` full project passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalMCS*.lean` returns empty
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/DenseCompleteness.lean` returns empty
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalMCS*.lean` shows no new axioms

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <new files>` returns empty
- [ ] `grep -n "^axiom " <new files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Correctness Checklist
- [ ] CanonicalMCS BFMCS has modal saturation (modal_backward proven)
- [ ] Truth lemma handles all formula constructors without sorry
- [ ] Temporal coherence uses proven forward_F/backward_P
- [ ] Completeness connects to standard validity via TimelineQuot
- [ ] No circular dependencies between theorems

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalMCSBFMCS.lean` - NEW
- `Theories/Bimodal/Metalogic/Bundle/CanonicalMCSTruthLemma.lean` - NEW
- `Theories/Bimodal/Metalogic/Bundle/CanonicalMCSCompleteness.lean` - NEW
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - MODIFIED
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-{DATE}.md` - UPDATED

## Rollback/Contingency

If implementation fails:
1. New files can be deleted without affecting existing codebase
2. Modifications to DenseCompleteness.lean and TimelineQuotCompleteness.lean can be reverted via git
3. The existing TimelineQuot-based approach remains available (with sorries) as fallback

## Why This Approach is Correct

### CanonicalMCS Has What We Need

The insight from research-011: `canonicalMCSBFMCS` already has proven `forward_F` and `backward_P` (CanonicalFMCS.lean lines 222-251). The TimelineQuot approach was attempting to build these properties from scratch, running into the m > 2k edge case.

### Preorder Suffices for Truth Lemma

The truth lemma only needs:
- Temporal quantification over `s >= t` and `s <= t` - Preorder suffices
- Modal quantification over histories - BFMCS provides this
- Forward_F/backward_P witnesses - CanonicalMCS has these proven

It does NOT need:
- LinearOrder (only needed for TaskFrame validity definition)
- AddCommGroup (only needed for duration arithmetic in TaskFrame)
- DenselyOrdered (only needed for external validity claims)

### Connection via Embedding

TimelineQuot embeds into CanonicalMCS:
- Each TimelineQuot point corresponds to an MCS
- TimelineQuot provides LinearOrder + density for validity definition
- CanonicalMCS provides the actual countermodel structure

The dense completeness theorem transfers validity claims from TimelineQuot to CanonicalMCS-based truth.
