# Implementation Plan: Wire Dense Completeness Domain Connection (v5)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [PARTIAL]
- **Effort**: 6-8 hours (revised from 12-16)
- **Dependencies**: Tasks 956 (D construction), 978 (typeclass architecture), 985 (parametric infrastructure)
- **Research Inputs**:
  - research-006.md (closure-based modal saturation)
  - research-007.md (D-parametric instantiation — **primary**)
- **Artifacts**: plans/implementation-005.md (this file), supersedes implementation-001/002/003/004.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v005 (2026-03-17)**: Complete revision based on research-007 (D-parametric instantiation). Replaces the "build a new truth lemma for TimelineQuot" approach with direct instantiation of the existing `parametric_representation_from_neg_membership` theorem. The key insight: `ParametricTruthLemma.lean` already provides a truth lemma for any D with AddCommGroup + LinearOrder. We only need to build a temporally coherent BFMCS over TimelineQuot with correct modal coherence.

**v004**: SUPERSEDED. Included Phase 5 (Closure-Aware Truth Lemma) which is now unnecessary — `parametric_shifted_truth_lemma` handles this for any D. Effort estimate was also inflated.

## Executive Summary

### The Architectural Insight (research-007)

The blocker was misidentified as "truth lemma infrastructure for TimelineQuot." The actual gap is simpler:

```
parametric_representation_from_neg_membership
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at (ParametricCanonicalTaskModel D) ... t φ
```

This theorem (ParametricRepresentation.lean:167) works for **any** D with AddCommGroup + LinearOrder. TimelineQuot has all required instances via `DurationTransfer`. We just need to supply:
1. A BFMCS over TimelineQuot
2. Proof of temporal coherence
3. A family in the BFMCS containing φ.neg at some time

### What Was Completed (Phases 1-3)

- **Phase 1**: `timelineQuot_lt_implies_canonicalR` — proven in TimelineQuotCanonical.lean
- **Phase 2**: `timelineQuotFMCS` — FMCS over TimelineQuot with forward_G, backward_H
- **Phase 3**: `buildWitnessMCS`, `buildWitnessMCS_contains_psi`, `buildWitnessMCS_contains_boxcontent`, `boxcontent_subset_implies_box_forward` — in WitnessChainFMCS.lean

### Remaining Work (Phases 4-6)

Phase 4 is the main construction work: build a valid BFMCS with modal_forward, modal_backward, and temporal coherence. Phase 5 completes the sorry using the parametric theorem. Phase 6 verifies.

## Goals & Non-Goals

**Goals**:
- Complete `timelineQuot_not_valid_of_neg_consistent` (the single remaining sorry)
- Build closure-saturated BFMCS over TimelineQuot with correct BFMCS fields
- Use `parametric_representation_from_neg_membership` directly
- Zero new sorries, **zero new axioms**

**Non-Goals**:
- Prove a new truth lemma for TimelineQuot (use parametric one)
- Discrete completeness (separate task)
- Removing `canonicalR_irreflexive` axiom (separate task)

## BFMCS Construction Analysis

### Why Modal Backward is Achievable

The `BFMCS.modal_backward` field requires:
```
∀ fam ∈ families, ∀ φ t, (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Box φ ∈ fam.mcs t
```

`saturated_modal_backward` (ModalSaturation.lean:328) proves this FROM `is_modally_saturated`:
- By contradiction: if `Box φ ∉ fam.mcs t`, then `◇¬φ ∈ fam.mcs t` (negation completeness)
- By modal saturation: ∃ fam' ∈ families with `¬φ ∈ fam'.mcs t`
- But `h_all` gives `φ ∈ fam'.mcs t` — contradiction with MCS consistency

The proof of `modal_backward` can be done BEFORE constructing the BFMCS (directly on the families set), then packaged into the BFMCS struct.

### Why Modal Forward is Achievable

The `BFMCS.modal_forward` field requires:
```
∀ fam ∈ families, ∀ φ t, Box φ ∈ fam.mcs t → ∀ fam' ∈ families, φ ∈ fam'.mcs t
```

For each witness family built via `buildWitnessMCS`, `buildWitnessMCS_contains_boxcontent` gives `BoxContent(M) ⊆ witness.mcs`. Since `Box φ ∈ fam.mcs t` means `φ ∈ BoxContent(fam.mcs t)`, and witnesses contain BoxContent, `φ ∈ witness.mcs t`.

**Gap**: witness MCS is a fixed MCS (same at all times), while `fam.mcs t` varies. Need to handle the family-as-FMCS aspect. This requires either:
(a) Witness FMCS that uses the same MCS everywhere (constant family), OR
(b) A single shared BoxContent across all families at all times

**Resolution**: Use constant witness FMCS (same MCS at every time). Then `BoxContent` is time-independent and modal_forward follows immediately from `buildWitnessMCS_contains_boxcontent`.

### Temporal Coherence for Constant Families

A constant FMCS (same MCS at every time) has temporal coherence iff:
- For all φ, `F(φ) ∈ M` implies ∃ s > t, `φ ∈ M` at s (holds trivially since M is the same at all s)
- For all φ, `P(φ) ∈ M` implies ∃ s < t, `φ ∈ M` at s (holds trivially)

So constant witness FMCS IS temporally coherent as long as the domain has no maximum and no minimum (which TimelineQuot satisfies via NoMaxOrder, NoMinOrder).

**Simplification**: The construction does NOT need WitnessChainFMCS (Phase 3 built this unnecessarily). Constant FMCS families suffice because modal_forward only needs same BoxContent, not temporal variation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| modal_forward across constant families | Medium | Low | BoxContent containment is direct |
| is_modally_saturated proof for closure | Medium | Medium | Construction ensures saturation by design |
| Instance resolution for D=TimelineQuot | Low | Low | Explicit type annotations |
| Circular dependency in BFMCS construction | Medium | Low | Prove properties on families set before packaging |

## Implementation Phases

### Phase 1: Core Linking Lemma [COMPLETED]

**Status**: COMPLETED in v003. `timelineQuot_lt_implies_canonicalR` proven in `TimelineQuotCanonical.lean`.

---

### Phase 2: FMCS over TimelineQuot [COMPLETED]

**Status**: COMPLETED in v003. `timelineQuotFMCS` with `forward_G`, `backward_H` proven in `TimelineQuotCanonical.lean`.

---

### Phase 3: Witness Family Constructor [COMPLETED]

**Status**: COMPLETED (Phase 3 of v004). Primitives in `WitnessChainFMCS.lean`:
- `buildWitnessMCS`, `buildWitnessMCS_contains_psi`
- `buildWitnessMCS_contains_boxcontent`, `boxcontent_subset_implies_box_forward`

Note: The WitnessChainFMCS primitives are reused in Phase 4 for building the BFMCS families.

---

### Phase 4: Closure-Saturated BFMCS Construction [IN PROGRESS]

- **Dependencies**: Phase 3
- **Goal**: Build a full BFMCS over TimelineQuot satisfying all BFMCS fields

**Current state**: `ClosureSaturation.lean` documents architecture but has no actual construction.

**Construction Design**:

```lean
/-- Build a BFMCS over TimelineQuot by:
    1. Taking timelineQuotFMCS as primary family
    2. Adding constant witness FMCS for each Diamond formula in closure(target)
    3. Proving modal_forward, modal_backward, temporal coherence -/
noncomputable def constructTimelineQuotBFMCS
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (target : Formula) : BFMCS (TimelineQuot root_mcs root_mcs_proof)
```

**Step 1: Define Constant FMCS**

```lean
/-- A constant FMCS that uses the same MCS M at every time t. -/
noncomputable def constantFMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    FMCS (TimelineQuot root_mcs root_mcs_proof) :=
  { mcs := fun _ => M
  , is_mcs := fun _ => h_mcs
  , forward_G := by ... -- using NoMaxOrder
  , backward_H := by ... -- using NoMinOrder
  }
```

**Step 2: Define Families Set**

```lean
/-- The families set: primary family + witness families for each Diamond formula in closure. -/
noncomputable def closureFamilies
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (target : Formula) : Set (FMCS (TimelineQuot root_mcs root_mcs_proof)) :=
  {timelineQuotFMCS root_mcs root_mcs_proof} ∪
  { constantFMCS M h_mcs |
    (psi : Formula) (_ : psi ∈ subformulaClosure target)
    (t : TimelineQuot root_mcs root_mcs_proof)
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (_ : psi.diamond ∈ timelineQuotMCS root_mcs root_mcs_proof t)
    (_ : M = buildWitnessMCS (timelineQuotMCS root_mcs root_mcs_proof t)
                             (timelineQuotMCS_is_mcs root_mcs root_mcs_proof t)
                             psi (by assumption)) | M h_mcs }
```

**Step 3: Prove modal_forward**

For primary family: `Box φ ∈ timelineQuotMCS t` → `φ ∈ timelineQuotMCS t` (T-axiom, already proven) and `φ ∈ witnessM` (witness contains BoxContent).

For constant witness: `Box φ ∈ M` → `φ ∈ M` (T-axiom) and `φ ∈ all other families` (BoxContent containment).

**Step 4: Prove is_modally_saturated**

For any family `fam` and time `t`:
- If `◇ψ ∈ fam.mcs t` and `ψ ∈ subformulaClosure target`:
  - The witness family for `ψ` at `t` is in `closureFamilies`
  - That family has `ψ` in its MCS (by `buildWitnessMCS_contains_psi`)

**Step 5: Prove modal_backward**

Use `saturated_modal_backward` proof pattern directly (inline, without calling the theorem to avoid the circularity of needing an already-built BFMCS):

```lean
-- Prove modal_backward for closureFamilies:
-- Given: ∀ fam' ∈ closureFamilies, φ ∈ fam'.mcs t
-- Goal: Box φ ∈ fam.mcs t
-- Proof: By contradiction, same as saturated_modal_backward
--   ¬Box φ ∈ fam.mcs t → neg(Box φ) ∈ fam.mcs t → ◇¬φ ∈ fam.mcs t
--   → ∃ fam' ∈ closureFamilies with ¬φ ∈ fam'.mcs t (by saturation)
--   → contradiction with h_all
```

**Step 6: Prove temporally_coherent**

For primary `timelineQuotFMCS`: Use existing forward_G, backward_H proofs (already in TimelineQuotCanonical.lean). Need to check they match `temporally_coherent` definition (F(φ) → ∃ s > t, φ at s).

For constant witness FMCS: Trivial, since NoMaxOrder, NoMinOrder give ∃ s > t and ∃ s < t, and the MCS is the same at all times.

**Step 7: Package into BFMCS**

```lean
{ families := closureFamilies root_mcs root_mcs_proof target
, nonempty := ⟨timelineQuotFMCS ..., Set.mem_union_left _ rfl⟩
, modal_forward := h_modal_forward
, modal_backward := h_modal_backward
, eval_family := timelineQuotFMCS root_mcs root_mcs_proof
, eval_family_mem := Set.mem_union_left _ rfl
}
```

**Tasks**:
- [ ] Define `constantFMCS` in ClosureSaturation.lean
- [ ] Prove `constantFMCS_forward_G` and `constantFMCS_backward_H`
- [ ] Define `closureFamilies` set
- [ ] Prove `closureFamilies_nonempty`
- [ ] Prove `closureFamilies_modal_forward`
- [ ] Prove `closureFamilies_is_saturated` (is_modally_saturated)
- [ ] Prove `closureFamilies_modal_backward` (inline proof, no circularity)
- [ ] Prove `closureFamilies_temporally_coherent`
- [ ] Define `constructTimelineQuotBFMCS` packaging all the above
- [ ] Prove `constructTimelineQuotBFMCS_eval_family_root`: `φ.neg ∈ (constructTimelineQuotBFMCS root_mcs root_mcs_proof φ).eval_family.mcs 0`

**Timing**: 4-5 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - MODIFIED (actual construction)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" ClosureSaturation.lean` returns empty

---

### Phase 5: Complete the Sorry [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Use `constructTimelineQuotBFMCS` + `parametric_representation_from_neg_membership` to close the sorry

**Imports to add**:
```lean
import Bimodal.Metalogic.StagedConstruction.ClosureSaturation
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
```

**Proof Structure**:
```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (φ : Formula) (h_cons : ContextConsistent [φ.neg]) :
    let M₀ := lindenbaumMCS [φ.neg] h_cons
    let h_M₀_mcs := lindenbaumMCS_is_mcs [φ.neg] h_cons
    let D := TimelineQuot M₀ h_M₀_mcs
    ...
    ¬@valid_over D ... φ := by
  intro M₀ h_M₀_mcs D acg oam

  -- Step 1: Build closure-saturated BFMCS over TimelineQuot
  let B := constructTimelineQuotBFMCS M₀ h_M₀_mcs φ
  have h_tc : B.temporally_coherent := constructTimelineQuotBFMCS_tc M₀ h_M₀_mcs φ

  -- Step 2: Get root time and family containing φ.neg
  let fam := B.eval_family
  let hfam := B.eval_family_mem
  let t₀ : TimelineQuot M₀ h_M₀_mcs := timelineQuotZero M₀ h_M₀_mcs
  have h_neg_in : φ.neg ∈ fam.mcs t₀ :=
    constructTimelineQuotBFMCS_eval_family_root M₀ h_M₀_mcs φ

  -- Step 3: Apply parametric representation from neg membership
  have h_false : ¬truth_at (ParametricCanonicalTaskModel D) ... t₀ φ :=
    parametric_representation_from_neg_membership B h_tc φ fam hfam t₀ h_neg_in

  -- Step 4: Exhibit countermodel
  intro ⟨F, M, Omega, h_sc, τ, h_mem, t, h_true⟩
  ... -- connect valid_over to the parametric canonical model
```

**Important Note on Task Frame Connection**:

The theorem `timelineQuot_not_valid_of_neg_consistent` has conclusion `¬valid_over D φ` which quantifies over ALL TaskFrames. The `parametric_representation_from_neg_membership` gives falsity in `ParametricCanonicalTaskModel D`. To connect these:
- By soundness of the proof system, any provable formula is valid in all frames
- Contrapositive: if there's a countermodel in ONE frame (parametric), then not provable
- But `¬valid_over D φ` needs: ∃ frame F over D, ¬ valid in F

Need to check: does `ParametricCanonicalTaskModel D` count as a valid `TaskFrame` for `valid_over`? If `valid_over D φ` means "valid in all TaskFrames over D", we need the parametric model to be one of them.

**Alternative**: The conclusion `¬@valid_over D acg inferInstance oam φ` might already be stated in terms of the parametric model's frame. Check `valid_over` definition.

**Tasks**:
- [ ] Add imports to TimelineQuotCompleteness.lean
- [ ] Check `valid_over` definition and how to exhibit countermodel
- [ ] Prove `constructTimelineQuotBFMCS_eval_family_root`
- [ ] Complete `timelineQuot_not_valid_of_neg_consistent` proof
- [ ] Verify `dense_completeness_theorem` compiles without sorry

**Timing**: 1.5-2 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED (sorry resolved)

**Verification**:
- `grep -n "\bsorry\b" TimelineQuotCompleteness.lean` returns empty
- `lake build Bimodal.FrameConditions.Completeness` passes

---

### Phase 6: Final Verification [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Verify zero-sorry, zero-axiom status

**Tasks**:
- [ ] Run `lake build` full project
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/*.lean`
- [ ] Run `grep -rn "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/*.lean` — verify EMPTY
- [ ] Run `grep -rn "^axiom " Theories/Bimodal/` — verify only `canonicalR_irreflexive`
- [ ] Update implementation summary

**Timing**: 30 minutes

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms (zero-axiom gate)
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Correctness Checklist
- [ ] BFMCS.modal_forward proven without T-axiom dependence on new structures
- [ ] BFMCS.modal_backward proven via inline `saturated_modal_backward` argument
- [ ] BFMCS.temporally_coherent: primary family from existing proofs, constant families trivial
- [ ] Constant FMCS families: NoMaxOrder, NoMinOrder ensure witness times exist
- [ ] `parametric_representation_from_neg_membership` applied with correct D=TimelineQuot
- [ ] Countermodel connects to `valid_over` correctly

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - MODIFIED (actual construction)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED (sorry resolved)
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-{DATE}.md` - UPDATED

## Why This Approach is Correct

### Avoiding the Truth Lemma Re-Proof

`parametric_representation_from_neg_membership` uses `parametric_shifted_truth_lemma` internally. That lemma is proven for any D with the required typeclasses. TimelineQuot satisfies all of them. We get the full truth lemma for free.

### Why Constant Families Work for Modal Coherence

Modal coherence is about families AT THE SAME TIME (not across time). A constant family (same MCS at all t) satisfies modal coherence with other families as long as BoxContent is preserved. `buildWitnessMCS_contains_boxcontent` ensures this.

### The Saturation Argument (Closure Suffices)

We only saturate for Diamond formulas in `subformulaClosure(target)`. The truth lemma evaluation only recurses on subformulas, so we only need saturation for those. Closure saturation suffices.

### Zero Axiom Property

`modal_backward` is proven by the inline saturation argument — no axioms required. The construction property "we added witness families for every Diamond in closure" gives saturation, from which `modal_backward` follows by pure logic.
