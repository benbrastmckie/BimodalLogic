# Implementation Plan: Wire Dense Completeness Domain Connection (v6)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [PARTIAL]
- **Effort**: 8-10 hours (refined from research-008)
- **Dependencies**: Task 985 (parametric infrastructure), Task 986 (BFMCS for Int/Rat)
- **Research Inputs**:
  - research-008.md (domain transfer approach - **primary**)
  - research-007.md (D-parametric instantiation - context)
- **Artifacts**: plans/implementation-006.md (this file), supersedes implementation-001/002/003/004/005.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v006 (2026-03-17)**: **MAJOR REVISION**. Abandons the "fix staged construction edge cases" approach in favor of domain transfer via isomorphism. Key insight from research-008: the staged construction optimizes for dense linear order (time domain), but modal completeness needs ALL MCSs (modal domain). These are separate requirements that should use separate infrastructure.

**v005**: SUPERSEDED. Attempted to complete staged construction proofs (forward_F edge cases). Found that F-content does NOT transfer along CanonicalR chains, making the approach architecturally complex. 4 sorries introduced, 0 resolved.

## Executive Summary

### The Architectural Pivot (research-008)

The v005 approach tried to prove temporal coherence (forward_F, backward_P) directly over TimelineQuot. This hit fundamental blockers:

1. **Staged construction processes formulas in encoding order** - points added AFTER a formula is processed lack direct witnesses
2. **F-content does NOT transfer along CanonicalR chains** - only g_content does
3. **Singleton BFMCS cannot satisfy modal_backward** - need multi-family saturation

### The Domain Transfer Solution

Instead of fighting the staged construction, we use:

1. **Existing sorry-free canonicalMCSBFMCS** - proven forward_F, backward_P, modal saturation
2. **Domain transfer via Cantor isomorphism** - TimelineQuot ≃o Rat
3. **Parametric infrastructure with D = Rat** - ParametricRepresentation.lean already works

The key insight: validity over one order-isomorphic domain equals validity over the other. If we prove ¬valid over Rat, that's equivalent to ¬valid over TimelineQuot.

### Reusable Work from v005

- Phase 1-3 primitives (TimelineQuotCanonical.lean, WitnessChainFMCS.lean) are still valid
- CantorPrereqs.lean `forward_witness_at_stage_with_phi` lemmas are reusable
- ClosureSaturation.lean partial work can be preserved as documentation

## Goals & Non-Goals

**Goals**:
- Complete `dense_completeness_theorem` via domain transfer
- Build BFMCS over Rat using existing infrastructure
- Prove validity transfer theorem between isomorphic domains
- Zero new sorries, **zero new axioms**

**Non-Goals**:
- Prove forward_F edge cases for TimelineQuot (abandoned - too complex for marginal benefit)
- Build direct BFMCS over TimelineQuot (unnecessary with domain transfer)
- Modify staged construction (out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Rat BFMCS construction gaps | High | Medium | Use canonicalMCSBFMCS directly, avoid custom construction |
| Validity transfer theorem complexity | Medium | Low | Standard order theory, proven patterns |
| Instance resolution issues | Low | Medium | Explicit type annotations |
| Integration complexity | Low | Low | Parametric infrastructure is clean |

## Implementation Phases

### Phase 1: Cleanup and Preparation [PARTIAL]

- **Dependencies**: None
- **Goal**: Clean up v005 sorries and prepare for domain transfer approach

**Tasks**:
- [x] Document why staged construction approach was abandoned (comments in ClosureSaturation.lean)
- [x] Mark ClosureSaturation.lean sorries as intentionally deferred (not blocking this task)
- [x] Identify exact interface needed between canonical BFMCS and parametric infrastructure
- [x] Verify DenseInstantiation.lean provides all instances for Rat

**Progress:**

**Session: 2026-03-17, sess_1773776521_d8f4a2**
- Analyzed: Full architecture of completeness infrastructure
- Identified: Core blocker is `timelineQuot_not_valid_of_neg_consistent` (TimelineQuotCompleteness.lean:127)
- Found: CanonicalMCSBFMCS over CanonicalMCS is sorry-free for forward_F/backward_P
- Gap identified: CanonicalMCS has Preorder (not LinearOrder), but valid_over requires LinearOrder
- Existing sorries: 5 in CanonicalEmbedding.lean, 2 in IntBFMCS.lean, 1 in TimelineQuotCompleteness.lean
- Key insight: Domain transfer approach needs forward_F/backward_P proofs for FMCS over Rat, which inherits TimelineQuot gaps

**Key verification**:
```lean
-- Need these for D = Rat:
#check (inferInstance : AddCommGroup Rat)
#check (inferInstance : LinearOrder Rat)
#check (inferInstance : DenselyOrdered Rat)
#check (inferInstance : NoMinOrder Rat)
#check (inferInstance : NoMaxOrder Rat)
```

**Timing**: 1 hour

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - MODIFIED (add comments)
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` - READ (verify instances)

**Verification**:
- `lake build` passes

---

### Phase 2: Rat BFMCS Construction [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Build a BFMCS over Rat with temporal coherence and modal saturation

**Construction approach**:

The simplest path: use `canonicalMCSBFMCS` but project through a Rat-indexed family.

```lean
/-- Build BFMCS over Rat by using canonical infrastructure.
    Each Rat value t maps to an MCS via a canonical timeline projection. -/
noncomputable def ratBFMCS (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs) :
    BFMCS Rat := sorry

/-- The Rat BFMCS is temporally coherent because the canonical BFMCS is. -/
theorem ratBFMCS_temporally_coherent
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs) :
    (ratBFMCS root_mcs root_mcs_proof).temporally_coherent := sorry
```

**Alternative approach**: Use the existing `canonicalMCSBFMCS` and embed via TimelineQuot -> Rat:

```lean
/-- Embed TimelineQuot families into Rat-indexed families via Cantor isomorphism -/
noncomputable def timelineQuotToRatFamily
    (fam : FMCS (TimelineQuot root_mcs root_mcs_proof))
    (iso : TimelineQuot root_mcs root_mcs_proof ≃o Rat) :
    FMCS Rat := sorry
```

**Tasks**:
- [ ] Choose between direct Rat BFMCS vs. transfer via isomorphism
- [ ] If transfer: Prove `timelineQuotToRatFamily` preserves forward_F/backward_P
- [ ] If direct: Build Rat BFMCS using canonical infrastructure
- [ ] Prove `ratBFMCS_temporally_coherent`
- [ ] Prove `ratBFMCS_is_modally_saturated`

**Timing**: 3-4 hours

**Files**:
- `Theories/Bimodal/Metalogic/Algebraic/RatBFMCS.lean` - NEW
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - READ (interface)

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.RatBFMCS` passes
- `grep -n "\bsorry\b" RatBFMCS.lean` returns empty

---

### Phase 3: Validity Transfer Theorem [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Prove that validity transfers between order-isomorphic domains

**Theorem**:
```lean
/-- Order isomorphism preserves validity of formulas.
    If D ≃o E and φ is valid over D, then φ is valid over E. -/
theorem validity_transfer_iso
    {D E : Type*}
    [AddCommGroup D] [LinearOrder D] [DenselyOrdered D] [NoMinOrder D] [NoMaxOrder D]
    [AddCommGroup E] [LinearOrder E] [DenselyOrdered E] [NoMinOrder E] [NoMaxOrder E]
    (iso : D ≃o E)
    (φ : Formula) :
    valid_over D φ ↔ valid_over E φ := sorry
```

**Proof sketch**:
- Frame structures transfer via pushforward/pullback
- Valuations transfer via composition with iso
- Truth is preserved because order relations are preserved
- Validity = universally quantified truth, so ↔ follows

**Tasks**:
- [ ] Define frame pushforward via order isomorphism
- [ ] Define model transfer via isomorphism
- [ ] Prove `truth_at_transfer_iso`: truth transfers under iso
- [ ] Prove `validity_transfer_iso`
- [ ] Apply to TimelineQuot ≃o Rat

**Timing**: 2 hours

**Files**:
- `Theories/Bimodal/Metalogic/Algebraic/ValidityTransfer.lean` - NEW

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.ValidityTransfer` passes
- `grep -n "\bsorry\b" ValidityTransfer.lean` returns empty

---

### Phase 4: Wire Dense Completeness [NOT STARTED]

- **Dependencies**: Phases 2, 3
- **Goal**: Complete the dense_completeness_theorem using domain transfer

**Theorem structure**:
```lean
theorem dense_completeness_theorem :
    (∀ (D : Type*) [inst : AddCommGroup D] [inst : LinearOrder D] [inst : DenselyOrdered D]
       [inst : NoMinOrder D] [inst : NoMaxOrder D], @valid_over D _ _ _ _ _ φ) →
    Nonempty ([] ⊢ φ) := by
  intro h_valid
  -- Step 1: Contrapositive: assume not provable
  by_contra h_not_prov
  -- Step 2: φ.neg is consistent
  have h_cons := not_provable_implies_neg_consistent φ h_not_prov
  -- Step 3: Extend to MCS M₀
  obtain ⟨M₀, h_mcs, h_neg_in⟩ := set_lindenbaum {φ.neg} h_cons
  -- Step 4: Build BFMCS over Rat containing M₀
  let B := ratBFMCS M₀ h_mcs
  -- Step 5: By parametric truth lemma, φ.neg is true at root
  have h_neg_true := parametric_representation_from_neg_membership B (ratBFMCS_tc ...) φ B.eval_family ...
  -- Step 6: Hence φ is not valid over Rat
  have h_not_valid_rat : ¬valid_over Rat φ := by
    intro h_all
    exact h_neg_true (h_all ...)
  -- Step 7: Apply validity transfer: TimelineQuot ≃o Rat
  -- This gives: ¬valid_over TimelineQuot φ (but we don't need this explicitly)
  -- Step 8: Rat is a dense linear order, contradicts h_valid
  exact h_not_valid_rat (h_valid Rat)
```

**Tasks**:
- [ ] Add imports for RatBFMCS, ValidityTransfer, ParametricRepresentation
- [ ] Implement the proof structure above
- [ ] Resolve any universe level issues
- [ ] Verify the countermodel construction is type-correct

**Timing**: 2-3 hours

**Files**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - MODIFIED (or new DenseCompleteness.lean)

**Verification**:
- `lake build Bimodal.FrameConditions.Completeness` passes
- `grep -n "\bsorry\b" Completeness.lean` returns empty for dense_completeness_theorem

---

### Phase 5: Cleanup the Original Sorry [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Remove or resolve `timelineQuot_not_valid_of_neg_consistent` sorry

**Options**:
1. **Delete the sorry**: If `dense_completeness_theorem` doesn't need it (likely)
2. **Prove via transfer**: Use validity_transfer_iso + Rat completeness
3. **Mark as deprecated**: If the TimelineQuot-specific theorem is no longer needed

**Tasks**:
- [ ] Determine if `timelineQuot_not_valid_of_neg_consistent` is needed
- [ ] If needed: prove via validity transfer from Rat
- [ ] If not needed: remove or deprecate
- [ ] Update TimelineQuotCompleteness.lean accordingly

**Timing**: 1 hour

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED

**Verification**:
- `grep -n "\bsorry\b" TimelineQuotCompleteness.lean` returns empty (or only documented sorries)

---

### Phase 6: Final Verification [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Verify zero-sorry, zero-axiom status for completeness

**Tasks**:
- [ ] Run `lake build` full project
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/*.lean`
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/FrameConditions/Completeness.lean`
- [ ] Run `grep -rn "^axiom " Theories/Bimodal/` — verify only `canonicalR_irreflexive`
- [ ] Update implementation summary
- [ ] Mark ClosureSaturation.lean sorries as "intentionally deferred" (not part of this task's scope)

**Timing**: 30 minutes

**Verification**:
- `lake build` passes
- Dense completeness theorem is sorry-free
- No new axioms introduced

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty for completeness-critical files
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Correctness Checklist
- [ ] Validity transfer theorem follows standard order theory
- [ ] Rat BFMCS uses proven infrastructure (not custom proofs)
- [ ] Completeness theorem structure matches mathematical proof sketch
- [ ] Domain transfer preserves frame structure (verified in proof)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/RatBFMCS.lean` - NEW (BFMCS over Rat)
- `Theories/Bimodal/Metalogic/Algebraic/ValidityTransfer.lean` - NEW (iso preserves validity)
- `Theories/Bimodal/FrameConditions/Completeness.lean` - MODIFIED (dense completeness theorem)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED (sorry resolution)
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-{DATE}.md` - UPDATED

## Why This Approach is Correct

### Separating Time and Modal Domains

The key architectural insight:
- **TimelineQuot** optimizes for dense linear order (time domain) from syntax
- **CanonicalMCS** provides all MCSs for modal witnesses (modal domain)

These are different requirements. The original approach conflated them by trying to make TimelineQuot serve both purposes. The domain transfer approach separates them cleanly.

### Mathematical Soundness of Domain Transfer

Validity transfer via order isomorphism is standard mathematics:
- Frame structures over D and E are in bijection via the isomorphism
- Valuations and truth definitions are compositionally transferred
- Quantified validity is preserved under bijection

### Why Rat (not TimelineQuot) for Completeness

The completeness theorem quantifies over ALL dense linear orders:
```
∀ D [DenselyOrdered D], valid_over D φ → provable φ
```

To prove the contrapositive, we need ONE countermodel in SOME dense D. Rat is simpler than TimelineQuot because:
- No staged construction complexity
- Standard Mathlib instances
- Clean integration with parametric infrastructure

The isomorphism TimelineQuot ≃o Rat means validity in one equals validity in the other, so using Rat is equivalent.
