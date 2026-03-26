# Implementation Plan: Task #58 - Bidirectional Truth Lemma (v7)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None (all building blocks are sorry-free)
- **Research Inputs**: specs/058_wire_completeness_to_frame_conditions/reports/17_team-research.md
- **Artifacts**: plans/07_bidirectional-truth-lemma.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

/research 58 --team --math "Building on the last reports, it is important to maintain strict adherence to the definitions given in the official semantics. Check that this has been maintained. Also, even more important is to take the critical warning in /home/benjamin/Projects/ProofChecker/specs/058_wire_completeness_to_frame_conditions/plans/07_bidirectional-truth-lemma.md to heart. Conduct further researcht to clarify the mathematically correct path forwards, making no compromises."

## CRITICAL WARNING: Forward-Only Truth Lemma Is Insufficient

> **WARNING**: Prior research (report 17) incorrectly concluded that "completeness only needs the
> forward direction of the truth lemma." This is FALSE.
>
> **Why the forward-only approach fails**:
> 1. The completeness proof uses `parametric_shifted_truth_lemma B h_tc φ fam hfam t`.mpr`
>    (the **backward** direction) in `ParametricRepresentation.lean:193, 212, 297`
> 2. Key lemmas like `neg_in_mcs_implies_false_at_model` require: truth_at φ → φ ∈ fam.mcs t
> 3. The induction proof structure requires BOTH directions to be mutually proven
> 4. A sorry in the backward direction makes the forward direction's IH unusable
>
> **The mistake**: Reasoning that completeness is "by contraposition so only forward is needed"
> ignores that the semantic truth definition and MCS membership are shown equivalent via
> bidirectional induction. Without the backward direction, we cannot derive a contradiction.
>
> **Lesson learned**: Document this warning in code comments to prevent future confusion.

## Overview

This plan abandons the "forward-only" approach and returns to the fundamental requirement: proving BOTH directions of the truth lemma. The key challenge is the **F backward case**:

```
F backward: truth_at F(φ) → F(φ) ∈ fam.mcs t
```

Where `truth_at F(φ)` allows witnesses in ANY family (by bundle semantics), but `F(φ) ∈ fam.mcs t` requires knowledge in the ORIGINAL family.

### The F Backward Problem in Detail

1. `truth_at F(φ)` = ∃ σ ∈ Omega, ∃ s > t, truth_at (σ, s) φ
2. By IH backward: φ ∈ (σ's family).mcs s
3. But σ's family might differ from fam
4. To conclude F(φ) ∈ fam.mcs t, we need `temporal_backward_F`:
   - `temporal_backward_F`: (∃ s > t, φ ∈ fam.mcs s) → F(φ) ∈ fam.mcs t
   - This requires the witness in the SAME family
5. **Gap**: We have φ in some family fam', but need F(φ) in family fam

### Available Strategies

| Strategy | Description | Feasibility |
|----------|-------------|-------------|
| A. Bundle-Quantified Semantics | Redefine truth_at F(φ) to only allow witnesses in same family | Changes the logic |
| B. Cross-Family F Transfer | Prove: φ ∈ fam'.mcs s at s > t implies F(φ) ∈ fam.mcs t (across families) | Requires new theorem |
| C. Single-Family Omega | Restrict Omega to histories from a single family | Loses bundle structure |
| D. Modal-Temporal Interaction | Use Box/G interaction to transfer F-facts across families | Depends on axioms |
| E. Algebraic Completeness | Bypass truth lemma via purely algebraic representation | Alternative approach |

This plan investigates Strategy B (Cross-Family F Transfer) as the primary path, with Strategy E (Algebraic Completeness) as fallback.

## Goals & Non-Goals

**Goals**:
- Add code documentation warning against the "forward-only" mistake
- Investigate whether cross-family F transfer is provable
- If provable: Implement full bidirectional truth lemma for bundle semantics
- If not provable: Document the precise mathematical obstruction and explore algebraic alternatives
- Eliminate sorries in completeness theorems OR document irreducible mathematical gap

**Non-Goals**:
- Proving family-level `TemporalCoherentFamily.forward_F` (blocked by sub-case (b))
- Changing the semantics of TM logic
- Adding new axioms to the proof system

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-family F transfer unprovable | H | M | Document gap precisely; explore algebraic alternative |
| Box-G-F interaction insufficient | H | M | Investigate what additional properties would be needed |
| Algebraic completeness also blocked | H | L | This would indicate a fundamental gap in TM over Int |
| Implementation complexity high | M | M | Factor into small lemmas; extensive verification |

## Implementation Phases

### Phase 1: Document the Forward-Only Mistake [NOT STARTED]

**Goal**: Add warnings to prevent future confusion about truth lemma requirements.

**Tasks**:
- [ ] Add documentation block in `UltrafilterChain.lean` near BFMCS_Bundle explaining bidirectional requirement
- [ ] Add comment in `ParametricTruthLemma.lean` explaining why both directions are needed
- [ ] Update `ParametricRepresentation.lean` to highlight the `.mpr` usage
- [ ] Create a "Truth Lemma Requirements" section documenting the interdependence

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`

**Documentation template**:
```lean
/-!
## WARNING: Truth Lemma Bidirectionality Requirement

The completeness proof requires BOTH directions of the truth lemma:
- **Forward**: φ ∈ fam.mcs t → truth_at (fam's history, t) φ
- **Backward**: truth_at (fam's history, t) φ → φ ∈ fam.mcs t

A common mistake is to assume that completeness "by contraposition" only needs the forward
direction. This is FALSE because:
1. `neg_in_mcs_implies_false_at_model` uses `.mpr` (backward direction)
2. The induction structure requires both directions to establish the IH
3. Without backward, we cannot show truth_at(¬φ) from ¬φ ∈ MCS

See Task 58 research reports for detailed analysis of this mistake.
-/
```

**Verification**:
- `lake build` succeeds
- Documentation renders correctly in generated docs

---

### Phase 2: Investigate Cross-Family F Transfer [NOT STARTED]

**Goal**: Determine if the following is provable:

```lean
theorem cross_family_F_transfer (B : BFMCS_Bundle)
    (fam fam' : FMCS Int) (hfam : fam ∈ B.families) (hfam' : fam' ∈ B.families)
    (t s : Int) (h_lt : t < s) (phi : Formula)
    (h_phi : phi ∈ fam'.mcs s) :
    Formula.some_future phi ∈ fam.mcs t
```

**Tasks**:
- [ ] Analyze what properties of BFMCS_Bundle could enable this
- [ ] Check if Box propagation + temporal axioms give cross-family F
- [ ] Investigate the contrapositive: ¬F(φ) ∈ fam → G(¬φ) ∈ fam → ∀s>t, ¬φ ∈ fam.mcs s
- [ ] Determine if G(¬φ) propagates across families via `modal_forward`
- [ ] Document findings with proof attempts or counterexamples

**Timing**: 4 hours

**Analysis approach**:
```
Contrapositive of cross_family_F_transfer:
  F(φ) ∉ fam.mcs t → (∃ fam' ∈ B.families, ∃ s > t, φ ∈ fam'.mcs s → False)

By MCS maximality: F(φ) ∉ fam.mcs t → G(¬φ) ∈ fam.mcs t

Question: Does G(¬φ) ∈ fam.mcs t imply ¬φ ∈ fam'.mcs s for all fam' ∈ bundle, s > t?

This would require: G propagates across families (not just within family).

The TF axiom gives: □(G(ψ) → ψ) - "if G(ψ) then ψ at all accessible worlds"
Combined with S5: □G(ψ) → G(ψ) at all families (via modal_forward)
So: G(¬φ) ∈ fam.mcs t → G(¬φ) ∈ fam'.mcs t (via modal_forward for Boxed-G)

But we need: G(¬φ) ∈ fam'.mcs t → ¬φ ∈ fam'.mcs s for s > t
This uses: fam'.forward_G, which IS available (FMCS field)!

So the chain is:
1. F(φ) ∉ fam.mcs t (assumption for contrapositive)
2. G(¬φ) ∈ fam.mcs t (MCS maximality + F ↔ ¬G¬)
3. □G(¬φ) ∈ fam.mcs t (needs verification - is G(ψ) always boxed?)
4. G(¬φ) ∈ fam'.mcs t (via modal_forward with □G(¬φ))
5. ¬φ ∈ fam'.mcs s for all s > t (via fam'.forward_G)
6. φ ∉ fam'.mcs s (MCS consistency)
7. Contradiction with hypothesis φ ∈ fam'.mcs s
```

**Key question**: Is step 3 provable? Does G(ψ) imply □G(ψ)?

This is related to the MF axiom: □φ → G(□φ). We need the converse direction or a related property.

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/CrossFamilyTransfer.lean` (exploratory)

**Verification**:
- Document all proof attempts
- If blocked, identify exact missing lemma

---

### Phase 3: Implement G-Box Interaction Lemmas [NOT STARTED]

**Goal**: If Phase 2 identifies G-Box interaction as the key, prove the necessary lemmas.

**Tasks**:
- [ ] Prove `G_implies_boxG` if true: G(φ) → □G(φ) (or document counterexample)
- [ ] Prove `boxG_propagates`: □G(φ) ∈ fam.mcs t → G(φ) ∈ fam'.mcs t for all fam' in bundle
- [ ] Prove `G_forward_across_families`: G(φ) ∈ fam.mcs t → φ ∈ fam'.mcs s for fam' in bundle, s > t
- [ ] If the above fail, investigate weaker conditions

**Timing**: 4 hours

**G-Box interaction analysis**:

The TM axioms include:
- MF: □φ → G(□φ) - modal implies temporal-modal
- TF: □(G(φ) → φ) - G is reflexive under Box

We need to investigate:
- Does TF + MF give □G(φ) from G(φ)?
- Is there a derived rule G(φ) ⊢ □G(φ)?

If not derivable, this represents a fundamental gap in the TM axiom system for cross-family reasoning.

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add G-Box lemmas
- Or create new file if exploration is extensive

**Verification**:
- `#print axioms` for each new lemma
- `lake build` succeeds

---

### Phase 4: Implement Bidirectional Bundle Truth Lemma [NOT STARTED]

**Goal**: If Phases 2-3 succeed, implement the full bidirectional truth lemma.

**Tasks**:
- [ ] Define `bundle_shifted_truth_lemma` with BOTH directions
- [ ] Forward cases: Copy from existing `parametric_shifted_truth_lemma`
- [ ] Backward cases: Use cross-family F transfer from Phase 2-3
- [ ] Prove F backward: truth_at F(φ) → F(φ) ∈ fam.mcs t
- [ ] Prove G backward: truth_at G(φ) → G(φ) ∈ fam.mcs t (should be straightforward)
- [ ] Verify all cases compile without sorry

**Timing**: 5 hours

**Conditional**: This phase only proceeds if Phases 2-3 provide the necessary lemmas.

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Bundle truth lemma

**Verification**:
- `#print axioms bundle_shifted_truth_lemma` shows no `sorryAx`
- Both directions work: test `.mp` and `.mpr`

---

### Phase 5: Wire to Completeness or Document Gap [NOT STARTED]

**Goal**: Either wire the truth lemma to completeness theorems, or document the precise mathematical gap.

**Tasks if Phases 2-4 succeed**:
- [ ] Update `dense_completeness_fc` to use bundle truth lemma
- [ ] Update `discrete_completeness_fc` to use bundle truth lemma
- [ ] Update `completeness_over_Int` to use bundle truth lemma
- [ ] Verify all sorries eliminated

**Tasks if Phases 2-4 fail**:
- [ ] Document the exact mathematical obstruction
- [ ] Identify what additional axioms would be needed
- [ ] Create a `Completeness.Gap.lean` file explaining the state
- [ ] Consider whether TM over Int is complete at all, or needs restriction

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`
- Possibly new `Theories/Bimodal/Metalogic/Algebraic/CompletenessGap.lean`

**Verification**:
- If success: `#print axioms completeness_over_Int` shows no `sorryAx`
- If gap: Clear documentation of what's missing

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] All new lemmas verified with `#print axioms`
- [ ] Documentation warnings are clear and accurate
- [ ] If gap found: Mathematical obstruction precisely characterized
- [ ] If success: All three target sorries eliminated

## Artifacts & Outputs

**Success case**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Bundle bidirectional truth lemma
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Sorry-free completeness

**Gap case**:
- `Theories/Bimodal/Metalogic/Algebraic/CompletenessGap.lean` - Gap documentation
- Documentation of what additional structure/axioms would be needed

## Rollback/Contingency

If cross-family F transfer is not provable:

1. **Algebraic alternative**: Investigate purely algebraic completeness that bypasses the truth lemma
2. **Restricted completeness**: Prove completeness for a fragment of TM where the gap doesn't apply
3. **Additional axiom**: Identify and document what axiom would close the gap
4. **Accept gap**: Document as a known open problem in TM over Int completeness

## Mathematical Justification

The key insight is that bundle semantics naturally leads to a gap in the F backward case because:

1. **Standard semantics**: F(φ) is true at w iff ∃ w', w R_F w' ∧ φ true at w'
2. **Bundle construction**: w' might be in a different family than w
3. **MCS requirement**: F(φ) ∈ fam.mcs t requires the family fam to "know" about the witness
4. **The gap**: How does fam know about witnesses in other families?

The answer may lie in the modal-temporal interaction axioms (MF, TF) which relate □ and G/F. If □G propagates information across families (via modal_forward), then G-facts become bundle-global, potentially closing the gap.

If this fails, it suggests that TM over Int may not be complete with the standard construction, or that a different semantic formulation is needed.
