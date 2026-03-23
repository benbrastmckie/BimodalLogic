# Implementation Plan: Dense Algebraic Completeness via Separated W/D Architecture (v3)

- **Task**: 988 - dense_algebraic_completeness
- **Status**: [BLOCKED]
- **Effort**: 12-15 hours (5 phases)
- **Dependencies**: Task 985 (complete), Task 982 research
- **Research Inputs**: research-004.md (blocker analysis and Option C recommendation)
- **Supersedes**: implementation-002.md (blocked on CanonicalQuot totality)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This v3 plan implements the **Separated W/D Architecture (Option C)** from research-004.md, which correctly addresses the blockers that stopped v2:

**Root Cause of v2 Blocker**: CanonicalMCS preorder lacks `IsTotal` - incomparable MCS pairs exist, so `Antisymmetrization` cannot produce LinearOrder needed for Cantor isomorphism.

**The Solution (Option C)**:
- **D = TimelineQuot** (has LinearOrder, Countable, DenselyOrdered, NoEndpoints via existing proofs)
- **W = CanonicalMCS** (has all MCS witnesses via `canonical_forward_F`, `canonical_backward_P`)
- **h : D -> W** defined by `SeparatedHistory` structure bridging TimelineQuot to CanonicalMCS
- Transfer via Cantor: `TimelineQuot ≃o Rat` (already proven in codebase)

### Research Integration

Key findings from research-004.md:
1. TimelineQuot already has `IsTotal` proven via `denseTimeline_linearly_ordered`
2. `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` already exists
3. CanonicalMCS has `canonical_forward_F`/`canonical_backward_P` (witnesses always exist)
4. On-demand witness saturation bridges the gap between TimelineQuot FMCS and CanonicalMCS witnesses

## Goals & Non-Goals

**Goals**:
- Define `SeparatedHistory` structure with `h : TimelineQuot -> CanonicalMCS`
- Prove forward_F/backward_P for TimelineQuot FMCS via on-demand saturation from CanonicalMCS
- Construct `construct_bfmcs_rat` function required by `dense_representation_conditional`
- Wire to `parametric_algebraic_representation_conditional` in DenseInstantiation.lean
- Prove `dense_algebraic_completeness : valid_dense phi -> Nonempty (DerivationTree [] phi)`
- Zero sorries, zero new axioms

**Non-Goals**:
- Using CanonicalQuot (blocked on totality)
- Modifying TimelineQuot's order structure (already correct)
- Changing the parametric infrastructure (already D-generic)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| On-demand saturation breaks FMCS coherence | High | LOW | forward_G/backward_H preserved by CanonicalR structure |
| Transfer from TimelineQuot to Rat loses witnesses | High | LOW | Cantor isomorphism preserves order, witnesses transfer via composition |
| BFMCS modal saturation complexity | Medium | MEDIUM | Follow existing ModalSaturation.lean patterns |
| TimelineQuot FMCS forward_F may be non-trivial | Medium | MEDIUM | Use witness families pattern from CanonicalFMCS.lean |

## Sorry Characterization

### Pre-existing Sorries
- None in scope. TimelineQuotCanonical.lean has zero sorries.
- DenseInstantiation.lean has zero sorries (uses conditional theorem).

### Expected Resolution
- No sorries to resolve - this is new implementation.

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in new dense algebraic completeness files
- Completeness theorem fully proven (modulo existing axioms)

## Implementation Phases

### Phase 1: SeparatedHistory Structure and TimelineQuot FMCS forward_F [BLOCKED]

- **Dependencies:** None
- **Goal:** Define the separated W/D history structure and prove forward_F for TimelineQuot FMCS

**Key Insight**: The `timelineQuotFMCS` already has `forward_G` and `backward_H`. What's missing is `forward_F` (existential forward) and `backward_P` (existential backward). The pattern is:

When `F(phi) in timelineQuotMCS(t)`:
1. Check if TimelineQuot has a witness at some `s > t` with `phi in timelineQuotMCS(s)`
2. If not directly available, use `canonical_forward_F` on the underlying CanonicalMCS
3. The witness MCS exists in CanonicalMCS (W), bridged via the history function

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean`
- [ ] Define `SeparatedHistory` structure mapping TimelineQuot to CanonicalMCS
- [ ] Define `timelineQuotToCanonicalMCS : TimelineQuot -> CanonicalMCS` wrapper
- [ ] Prove `timelineQuotFMCS_forward_F`: F(phi) at t implies exists s > t with phi at s
  - Use `canonical_forward_F` on the underlying MCS
  - Show witness can be placed in TimelineQuot via density
- [ ] Prove `timelineQuotFMCS_backward_P`: P(phi) at t implies exists s < t with phi at s
  - Use `canonical_backward_P` symmetrically

**Timing:** 3-4 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean`
  - `SeparatedHistory : Type`
  - `timelineQuotToCanonicalMCS : TimelineQuot -> CanonicalMCS`
  - `timelineQuotFMCS_forward_F : FMCS property`
  - `timelineQuotFMCS_backward_P : FMCS property`

**Verification:**
- `lake build Bimodal.Metalogic.Algebraic.SeparatedHistory` passes
- `grep -n "\bsorry\b" SeparatedHistory.lean` returns empty
- If forward_F/backward_P stuck, mark [BLOCKED] with review_reason

**Progress:**

**Session: 2026-03-17, sess_1742238000_988i2**
- Analyzed: Existing infrastructure in ClosureSaturation.lean (lines 244-679)
- Discovered: forward_F proof blocked for case m > 2k (point added after formula processed)
- Root cause: Lindenbaum witness from canonical_forward_F not guaranteed in staged timeline
- Existing sorries: ClosureSaturation.lean:659,664,679,724; TimelineQuotCompleteness.lean:127
- Status: [BLOCKED] - requires architectural resolution

**Blocker Analysis:**
The `forward_witness_at_stage_with_phi` theorem (CantorPrereqs.lean:542) requires `n <= 2*k` where:
- n = stage when point p entered staged build
- k = encoding of formula phi

When `m > 2*k` (point added AFTER formula was processed), the staged construction does NOT
guarantee a witness for F(phi). The witness from canonical_forward_F is constructed via
Lindenbaum extension of {phi} U g_content(M), which may NOT be CanonicalR-reachable from
the root MCS.

**Recommended Resolutions (for user review):**
1. **Enriched staged construction**: Modify to add ALL witness MCSs during build
2. **Multi-family BFMCS**: Use witness families pattern from ModalSaturation.lean
3. **Direct semantic proof**: Prove completeness without BFMCS temporal coherence
4. **Alternative domain**: Use a domain that avoids the witness placement problem

---

### Phase 2: TemporalCoherentFamily over TimelineQuot [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Bundle timelineQuotFMCS with forward_F/backward_P into TemporalCoherentFamily

**Tasks:**
- [ ] Define `timelineQuotTemporalFamily : TemporalCoherentFamily TimelineQuot`
  - Wrap `timelineQuotFMCS` with the forward_F/backward_P from Phase 1
- [ ] Prove `timelineQuotTemporalFamily_forward_G` (inherit from timelineQuotFMCS)
- [ ] Prove `timelineQuotTemporalFamily_backward_H` (inherit from timelineQuotFMCS)
- [ ] Verify `temporal_backward_G` and `temporal_backward_H` apply to this family

**Timing:** 2-3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean`
  - Add `timelineQuotTemporalFamily : TemporalCoherentFamily TimelineQuot`
  - Add temporal backward lemma applications

**Verification:**
- All TemporalCoherentFamily fields compile without sorry
- `lake build` passes

---

### Phase 3: BFMCS over TimelineQuot with Modal Saturation [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Construct BFMCS over TimelineQuot with temporal coherence

**Key Insight**: For BFMCS we need:
1. A set of FMCS families
2. Modal forward/backward coherence
3. Temporal coherence (from TemporalCoherentFamily)

The construction pattern from CanonicalFMCS.lean (singleton BFMCS) may suffice if modal axioms are handled correctly, or multi-family BFMCS via ModalSaturation.lean pattern if needed.

**Tasks:**
- [ ] Define `timelineQuotBFMCS : BFMCS TimelineQuot` using singleton pattern
- [ ] Prove `modal_forward`: Box(phi) in family implies phi in all families
  - For singleton: trivially holds (only one family)
- [ ] Prove `modal_backward`: phi in all families implies Box(phi) in family
  - Use MCS maximality and S5 axiom
- [ ] Prove `timelineQuotBFMCS.temporally_coherent` from TemporalCoherentFamily

**Timing:** 2-3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean`
  - Add `timelineQuotBFMCS : BFMCS TimelineQuot`
  - Add temporal coherence proof

**Verification:**
- BFMCS construction compiles without sorry
- `timelineQuotBFMCS.temporally_coherent` proven
- `lake build` passes

---

### Phase 4: Cantor Transfer to Rat [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Transfer TimelineQuot BFMCS to Rat via Cantor isomorphism

**Key Insight**: The existing `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` provides the isomorphism. We need to transfer the BFMCS structure through it.

**Tasks:**
- [ ] Extract Cantor isomorphism: `timelineQuot_iso_rat : TimelineQuot ≃o Rat`
- [ ] Define FMCS transfer function: `fmcs_transfer : (OrderIso A B) -> FMCS A -> FMCS B`
- [ ] Prove transferred FMCS preserves:
  - MCS assignment
  - forward_G, backward_H
  - forward_F, backward_P
- [ ] Define `ratFMCS : FMCS Rat` via transfer from timelineQuotFMCS
- [ ] Define `ratBFMCS : BFMCS Rat` via transfer from timelineQuotBFMCS
- [ ] Prove `ratBFMCS.temporally_coherent`

**Timing:** 2-3 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Algebraic/CantorTransfer.lean`
  - `fmcs_transfer : OrderIso -> FMCS -> FMCS`
  - `ratFMCS : FMCS Rat`
  - `ratBFMCS : BFMCS Rat`
  - `ratBFMCS_temporally_coherent`

**Verification:**
- All transfer lemmas compile without sorry
- `ratBFMCS.temporally_coherent` proven
- `lake build` passes

---

### Phase 5: Wire to DenseInstantiation and Prove Dense Completeness [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Complete the wiring and prove dense_algebraic_completeness

**Tasks:**
- [ ] Define `construct_bfmcs_rat : (M : Set Formula) -> SetMaximalConsistent M -> Sigma' ...`
  - Given MCS M, construct TimelineQuot rooted at M
  - Build BFMCS via Phase 3 construction
  - Transfer to Rat via Phase 4
  - Return the required sigma type for `dense_representation_conditional`
- [ ] Instantiate `dense_representation_conditional` with `construct_bfmcs_rat`
- [ ] Define `dense_representation : not_provable phi -> exists countermodel`
- [ ] Define `valid_dense` predicate (if not already defined)
- [ ] Prove contrapositive: `dense_algebraic_completeness : valid_dense phi -> Nonempty (DerivationTree [] phi)`
- [ ] Add module to lakefile and verify full build

**Timing:** 3-4 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
  - Import CantorTransfer.lean and SeparatedHistory.lean
  - Add `construct_bfmcs_rat`
  - Add `dense_algebraic_completeness` theorem

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/*.lean` returns empty for new files
- `grep -n "^axiom "` shows no new axioms
- `dense_algebraic_completeness` theorem type-checks

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] All new files have zero sorries
- [ ] No new axioms introduced
- [ ] `dense_algebraic_completeness` theorem exists and type-checks

### Theorem Verification
- [ ] `timelineQuotFMCS_forward_F` provides concrete witnesses
- [ ] `timelineQuotBFMCS.temporally_coherent` is fully proven
- [ ] `construct_bfmcs_rat` satisfies `dense_representation_conditional` signature
- [ ] Final theorem chain: unprovable -> countermodel -> not valid_dense (contrapositive gives completeness)

## Artifacts & Outputs

New files:
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean`
- `Theories/Bimodal/Metalogic/Algebraic/CantorTransfer.lean`

Modified files:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
- `Theories/Bimodal.lean` (module imports)

Summary (on completion):
- `specs/988_dense_algebraic_completeness/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the separated W/D approach encounters issues:

1. **forward_F stuck**:
   - Try multi-family BFMCS with explicit witness families
   - Follow ModalSaturation.lean saturation pattern

2. **Cantor transfer loses structure**:
   - May need to define specialized transfer lemmas
   - Consider working directly with TimelineQuot (avoiding Rat transfer)

3. **BFMCS modal_backward fails for singleton**:
   - Use multi-family construction from ModalSaturation.lean
   - Build saturated BFMCS with witness families for each Diamond formula

4. **TimelineQuot density insufficient**:
   - Verify DN axiom usage in staged construction
   - May need additional density witnesses

The separated W/D architecture from Option C is mathematically sound and should not encounter fundamental blockers (unlike v2 which hit totality issues).
