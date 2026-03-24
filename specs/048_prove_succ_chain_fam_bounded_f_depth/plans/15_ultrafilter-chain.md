# Implementation Plan: Task #48 - Ultrafilter Chain Construction (v15)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [PARTIAL]
- **Effort**: 4-5 hours
- **Dependencies**: None (STSA infrastructure is sorry-free)
- **Research Inputs**: reports/33_team-research.md
- **Artifacts**: plans/15_ultrafilter-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements `construct_bfmcs` via the Jonsson-Tarski ultrafilter chain construction. Team research (3 teammates) conclusively identified this as the only viable approach after 14 plan versions failed due to the fundamental flaw in the SuccChain/deferralClosure architecture.

The key insight is that ultrafilters have **full negation completeness** by definition, eliminating the boundary problems that plague restricted MCS constructions. The STSA infrastructure (Phases 1-3 of plan v14) is **already sorry-free**, providing the complete algebraic foundation. The single remaining gap is implementing the ultrafilter chain construction (~300-400 LOC).

### Research Integration

Team research report 33 identifies:
1. The finite inconsistency argument proves temporal witness existence (core mathematical insight)
2. `Ultrafilter.exists_le` from Mathlib provides filter extension to ultrafilter
3. The STSA instance (`TenseS5Algebra.lean`) is fully proven with no sorries
4. D = Int is the simplest viable instantiation
5. The construction follows standard modal algebra patterns (Jonsson-Tarski 1951-52)

## Goals & Non-Goals

**Goals**:
- Define temporal accessibility relation R_G on ultrafilters of LindenbaumAlg
- Prove the finite inconsistency argument (temporal witness existence)
- Construct Int-indexed ultrafilter chain using Mathlib's Zorn infrastructure
- Build FMCS from ultrafilter chain via existing `ultrafilter_to_mcs`
- Construct BFMCS by modal saturation (R_Box collection)
- Prove temporal coherence from MF+TF axioms
- Wire `construct_bfmcs` to satisfy `ParametricRepresentation.lean` signature

**Non-Goals**:
- Do not modify the existing SuccChain infrastructure (deprecated)
- Do not attempt to prove `restricted_single_step_forcing` (proven FALSE)
- Do not generalize to arbitrary D (Int is sufficient for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Filter extension proof complex | Medium | Low | Finite inconsistency argument is standard; follows from G-distribution |
| Int-indexed chain construction subtle | Medium | Medium | Use explicit recursion on Int, not Zorn for chain |
| Modal saturation unbounded | Low | Low | Use Quotient.rec pattern from existing infrastructure |
| Type unification with ParametricRepresentation | Low | Medium | Verify signature match early in Phase 5 |

## Implementation Phases

### Phase 1: Temporal Accessibility Relations [COMPLETED]

**Goal**: Define R_G and R_Box on ultrafilters of LindenbaumAlg with basic properties.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- [ ] Define `R_G (U V : Ultrafilter LindenbaumAlg) : Prop := forall a, G_quot a in U -> a in V`
- [ ] Define `R_Box (U V : Ultrafilter LindenbaumAlg) : Prop := forall a, box_quot a in U -> a in V`
- [ ] Prove `R_G_refl`: R_G is reflexive (from `G_quot a <= a` via temp_t_future)
- [ ] Prove `R_G_trans`: R_G is transitive (from `G_quot (G_quot a) <= G_quot a` via temp_4_future)
- [ ] Prove `R_Box_refl`: R_Box is reflexive (from box deflationary)
- [ ] Prove `R_Box_euclidean`: R_Box is Euclidean (from S5 collapse)

**Timing**: 45 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (~80 lines)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Algebraic.UltrafilterChain` compiles
- All R_G and R_Box properties proven without sorry

---

### Phase 2: Finite Inconsistency Argument [PARTIAL]

**Goal**: Prove the core mathematical insight - if F(a) is in ultrafilter U, then there exists a successor ultrafilter V with a in V.

**Tasks**:
- [ ] Define `G_preimage (U : Ultrafilter) : Set LindenbaumAlg := {a | G_quot a in U}`
- [ ] Prove `G_preimage_filter_basis`: G_preimage U is a filter basis (closed under finite inf)
- [ ] Prove `witness_consistent`: If `(G_quot a^c)^c in U` (i.e., F(a) in U), then `G_preimage U union {a}` is consistent
  - Key argument: If inconsistent, by finite inconsistency `G(b1) ... G(bn) -> not a`
  - By G-distribution: `G(b1 inf ... inf bn) -> G(not a)`
  - Since all G(bi) in U and U closed under inf: `G(not a) in U`
  - But `(G(not a))^c in U` (since F(a) in U), contradiction
- [ ] Prove `temporal_successor_exists`: If F(a) in U, exists V with R_G(U, V) and a in V
  - Use Mathlib's `Ultrafilter.exists_le` on the consistent set

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (~100 lines added)

**Verification**:
- `temporal_successor_exists` proven without sorry
- This is the crux lemma - if it compiles, the rest follows

---

### Phase 3: Int-Indexed Ultrafilter Chain [PARTIAL]

**Goal**: Construct an Int-indexed chain of ultrafilters with R_G connectivity.

**Tasks**:
- [ ] Define `UltrafilterChain := Int -> Ultrafilter LindenbaumAlg`
- [ ] Define `chain_connected (c : UltrafilterChain) : Prop := forall n : Int, R_G (c n) (c (n+1))`
- [ ] Prove `extend_chain_forward`: Given U at index n, construct U' at n+1 with R_G(U, U')
  - Use temporal_successor_exists for formulas F(a) in U
  - If no such formula, use U itself (reflexivity)
- [ ] Prove `extend_chain_backward`: Given U at index n, construct U' at n-1 with R_G(U', U)
  - Use sigma duality: R_H(U, V) iff R_G(sigma(U), sigma(V)) where sigma lifts to ultrafilters
- [ ] Define `build_chain (U0 : Ultrafilter) : UltrafilterChain`
  - c(0) = U0
  - c(n+1) = extend_chain_forward(c(n)) for n >= 0
  - c(n-1) = extend_chain_backward(c(n)) for n <= 0
- [ ] Prove `build_chain_connected`: build_chain produces a connected chain

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (~150 lines added)

**Verification**:
- `build_chain_connected` proven without sorry
- Chain construction uses well-founded recursion on |n|

---

### Phase 4: FMCS and BFMCS Construction [PARTIAL]

**Goal**: Convert ultrafilter chain to FMCS, then build BFMCS by modal saturation.

**Tasks**:
- [ ] Define `chain_to_fmcs (c : UltrafilterChain) : FMCS Int`
  - Use existing `ultrafilterToMCS` from UltrafilterMCS.lean
  - mcs(t) = ultrafilterToMCS(c(t))
- [ ] Prove `chain_to_fmcs_is_mcs`: Each point is an MCS
- [ ] Prove `chain_to_fmcs_forward_G`: Forward G-coherence (from R_G connectivity)
- [ ] Prove `chain_to_fmcs_backward_H`: Backward H-coherence (from chain connectivity)
- [ ] Define `modal_saturation (fam : FMCS Int) : Set (FMCS Int)`
  - Collect all R_Box-related FMCS families
- [ ] Define `build_bfmcs (U0 : Ultrafilter) : BFMCS Int`
  - families = modal_saturation(chain_to_fmcs(build_chain(U0)))
- [ ] Prove `build_bfmcs_nonempty`: families is nonempty

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (~80 lines added)

**Verification**:
- `build_bfmcs` compiles with BFMCS type
- All FMCS properties verified

---

### Phase 5: Temporal Coherence and Wiring [PARTIAL]

**Goal**: Prove temporal coherence from MF+TF and wire to ParametricRepresentation.

**Tasks**:
- [ ] Prove `build_bfmcs_temporally_coherent`: The BFMCS is temporally coherent
  - forward_F: If F(a) in mcs(t), exists t' > t with a in mcs(t') - from chain connectivity
  - backward_P: Symmetric via sigma duality
  - MF/TF ensure box formulas persist along temporal steps
- [ ] Define `construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M -> Sigma' ...`
  - Convert M to ultrafilter via mcsToUltrafilter
  - Apply build_bfmcs
  - Return the required sigma type
- [ ] Verify signature matches ParametricRepresentation requirements:
  ```lean
  construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M ->
    Sigma' (B : BFMCS Int) (h_tc : B.temporally_coherent)
           (fam : FMCS Int) (hfam : fam in B.families) (t : Int),
           M = fam.mcs t
  ```
- [ ] Add import to ParametricRepresentation.lean or create instantiation module
- [ ] Prove `construct_bfmcs_correct`: The returned fam.mcs(t) equals the input M

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (~60 lines added)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` (or new instantiation file)

**Verification**:
- `construct_bfmcs` type-checks against ParametricRepresentation signature
- Temporal coherence proof complete without sorry

---

### Phase 6: Full Build and Verification [NOT STARTED]

**Goal**: Ensure full project builds with no sorries in the completeness path.

**Tasks**:
- [ ] Run `lake build` for full project
- [ ] Verify no new sorries introduced
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/Algebraic/` to confirm
- [ ] Document that SuccChainFMCS.lean sorries are deprecated (not on completeness path)
- [ ] Update module documentation to reflect the algebraic construction

**Timing**: 30 minutes

**Files to verify**:
- All files in `Theories/Bimodal/Metalogic/Algebraic/`
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` import graph

**Verification**:
- `lake build` passes with no errors
- Zero sorries in algebraic completeness path
- Representation theorem fully instantiable with D = Int

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Algebraic.UltrafilterChain` - chain construction
- [ ] `lake build Theories.Bimodal.Metalogic.Algebraic.ParametricRepresentation` - full wiring
- [ ] `lake build` - full project compilation
- [ ] Manual: verify `parametric_algebraic_representation_conditional` instantiates with construct_bfmcs

## Artifacts & Outputs

- `plans/15_ultrafilter-chain.md` (this plan)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (new file, ~470 lines)
- Modified `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` (or instantiation module)
- `summaries/16_ultrafilter-chain-summary.md` (execution summary)

## Rollback/Contingency

**If Phase 2 (finite inconsistency) is harder than expected**:
1. The argument is mathematically sound; difficulty would be in Lean encoding
2. Use explicit witness construction instead of Ultrafilter.exists_le
3. Consider building ultrafilter explicitly via maximal consistent extension

**If Int-indexed chain is complex**:
1. Use Nat-indexed chain (forward only) with symmetry via sigma
2. This suffices for temporal coherence (backward derived from forward via duality)

**Full rollback**:
- `git checkout -- Theories/Bimodal/Metalogic/Algebraic/`
- No changes to existing sorry-free infrastructure

## Historical Context

This is plan version 15. After 14 versions attempting to fix the SuccChain approach:

**Why SuccChain fundamentally fails** (from team research):
- `closureWithNeg` has ONE-LAYER negation only
- When `FF(psi) in deferralClosure \ subformulaClosure`, negation completeness fails
- `restricted_single_step_forcing` is mathematically FALSE for boundary cases
- No hypothesis weakening or restructuring can fix this

**Why ultrafilter chains work**:
- Ultrafilters have FULL negation completeness by definition (exactly one of a or a^c)
- No "boundary" vs "interior" distinction
- MF+TF ensure box-persistence along temporal accessibility
- Standard Jonsson-Tarski pattern applies

## Key Mathematical Lemma

The crux is the finite inconsistency argument (Phase 2):

```
If F(a) in U (ultrafilter), then {b | G(b) in U} union {a} is consistent.

Proof: Suppose inconsistent. Then exists finite b1...bn with G(bi) in U and b1 inf ... inf bn implies not a.
By G-distribution (temp_k_dist): G(b1 inf ... inf bn) implies G(not a)
Since U is ultrafilter and closed under inf: G(b1 inf ... inf bn) in U
Therefore G(not a) in U.
But F(a) = (G(not a))^c in U, and ultrafilters cannot contain both a and a^c.
Contradiction.
```

This is the mathematical insight that makes the algebraic approach work where the relational approach fails.

## Line Count Summary

| Component | New Lines |
|-----------|-----------|
| R_G, R_Box definitions and properties | 80 |
| Finite inconsistency argument | 100 |
| Int-indexed chain construction | 150 |
| FMCS/BFMCS construction | 80 |
| Temporal coherence and wiring | 60 |
| **Total** | **~470** |

This is consistent with the team research estimate of ~300-400 LOC for the core construction.
