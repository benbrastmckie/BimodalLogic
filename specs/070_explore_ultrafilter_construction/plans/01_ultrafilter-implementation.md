# Implementation Plan: Task #70 - Ultrafilter-Based Temporal Coherence

- **Task**: 70 - Explore ultrafilter-based construction for temporal coherence
- **Status**: [NOT STARTED]
- **Effort**: 14-18 hours
- **Dependencies**: None (self-contained exploration)
- **Research Inputs**:
  - reports/01_team-research.md
  - reports/02_bundle-semantic-analysis.md
- **Artifacts**: plans/01_ultrafilter-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan implements an ultrafilter-based construction for achieving family-level temporal coherence, which is the remaining blocker for completeness. The key advantage of ultrafilters is automatic negation completeness: for any element a, exactly one of a or a^c is in the ultrafilter. This eliminates the F-persistence problem that blocked the MCS-based SuccChain approach, where Lindenbaum extension could add G(neg phi) when extending a seed containing F(phi).

### Research Integration

From team research (reports/01_team-research.md):
- All three TaskFrame axioms (nullity_identity, forward_comp, converse) are satisfiable via ultrafilter R_G chains over Int
- R_G and R_Box relations already implemented in UltrafilterChain.lean (lines 59-68)
- UltrafilterMCS bijection infrastructure exists but needs verification
- The crux proof obligation: given F(phi) in U, construct ultrafilter V with R_G(U,V) and phi in V (filter extension argument)

From semantic analysis (reports/02_bundle-semantic-analysis.md):
- Bundle-level coherence (already proven) handles modal (Box) operators correctly
- The gap is family-level temporal coherence: F(phi) in fam.mcs(t) must imply exists s >= t with phi in fam.mcs(s) (SAME family)
- Z_chain_forward_F sorries represent this exact gap

## Goals & Non-Goals

**Goals**:
- Define UltrafilterChain structure: Int-indexed chain with R_G connectivity
- Implement R_H backward temporal accessibility relation
- Prove ultrafilter chains satisfy family-level temporal coherence
- Connect ultrafilter-based construction to existing FMCS/BFMCS infrastructure
- Close or reduce sorries in Z_chain_forward_F pathway

**Non-Goals**:
- Modifying the truth lemma to accept bundle-level witnesses (parallel task 71/72 approach)
- Optimizing existing SuccChain infrastructure (may be deprecated if ultrafilter approach succeeds)
- Full completeness proof (this task provides the coherence foundation)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Filter extension argument requires Zorn's Lemma in Lean | H | M | Use Mathlib's Zorn infrastructure; may need Classical.choice |
| UltrafilterMCS bijection has hidden gaps | H | L | Verify no sorries in UltrafilterMCS.lean; grep shows none |
| R_H definition is non-trivial | M | M | Mirror R_G pattern using H operator from STSA |
| Temporal coherence proof is harder than expected | H | M | Phase 4 can be reduced to proving key lemmas without full integration |
| Integration with existing BFMCS is complex | M | M | Use clean interface via ultrafilter_to_mcs bijection |

## Implementation Phases

### Phase 1: Verify and Extend UltrafilterMCS Infrastructure [NOT STARTED]

**Goal**: Confirm ultrafilter-MCS bijection is complete and define missing helper lemmas.

**Tasks**:
- [ ] Verify no sorries in UltrafilterMCS.lean (grep confirms none currently)
- [ ] Add `ultrafilter_compl_or` helper: for any ultrafilter U and element a, exactly one of a or a^c is in U
- [ ] Add `ultrafilter_neg_iff`: [phi] in U iff [neg phi] not in U
- [ ] Define `mcs_to_ultrafilter` explicitly if not already done
- [ ] Prove round-trip properties: ultrafilter_to_mcs(mcs_to_ultrafilter(M)) = M

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean`

**Verification**:
- `lake build` compiles without errors
- No new sorries introduced
- Round-trip theorems have proofs

---

### Phase 2: Define R_H and Complete Accessibility Properties [NOT STARTED]

**Goal**: Define backward temporal accessibility R_H and prove it is the converse of R_G.

**Tasks**:
- [ ] Define `R_H (U V : Ultrafilter LindenbaumAlg)`: H(a) in U implies a in V
- [ ] Prove `R_H_refl`: every ultrafilter is R_H-related to itself (from temp_t_past)
- [ ] Prove `R_H_trans`: R_H is transitive (from temp_4_past: H(a) <= H(H(a)))
- [ ] Prove `R_G_H_converse`: R_G(U, V) iff R_H(V, U) (key for TaskFrame converse axiom)
- [ ] Add `R_G_serial`: forall U, exists V, R_G(U, V) (serial relation)
- [ ] Add `R_H_serial`: forall U, exists V, R_H(U, V)

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (new section after R_Box properties)

**Verification**:
- All new theorems compile without sorry
- R_G_H_converse establishes the converse relation needed for TaskFrame

---

### Phase 3: Define UltrafilterChain Structure [NOT STARTED]

**Goal**: Define the Int-indexed ultrafilter chain structure with R_G connectivity.

**Tasks**:
- [ ] Define `UltrafilterChain` structure:
  ```lean
  structure UltrafilterChain where
    chain : Int -> Ultrafilter LindenbaumAlg
    R_G_connected : forall t, R_G (chain t) (chain (t + 1))
    R_H_connected : forall t, R_H (chain t) (chain (t - 1))
  ```
- [ ] Prove `UltrafilterChain_R_G_transitive`: chain t to chain (t + n) for any n >= 0
- [ ] Prove `UltrafilterChain_R_H_transitive`: chain t to chain (t - n) for any n >= 0
- [ ] Define `UltrafilterChain_at` accessor with time offset
- [ ] Prove shifted chain properties (paralleling shifted_fmcs)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (new section)

**Verification**:
- Structure compiles
- Transitivity proofs complete without sorry

---

### Phase 4: Ultrafilter Temporal Coherence (Core) [NOT STARTED]

**Goal**: Prove the crux theorem - ultrafilters resolve F-obligations via filter extension.

**Tasks**:
- [ ] Define `temporal_filter_extension`: given F(phi) in U, construct filter containing phi and consistent with U
- [ ] Prove filter extends to ultrafilter (using Zorn's Lemma via Mathlib)
- [ ] Prove `ultrafilter_F_resolution`:
  ```lean
  theorem ultrafilter_F_resolution (U : Ultrafilter LindenbaumAlg)
      (phi : Formula) (h_F : STSA.F (toQuot phi) in U) :
      exists V, R_G U V and (toQuot phi) in V
  ```
- [ ] Prove symmetric `ultrafilter_P_resolution` for past operator
- [ ] These are the key lemmas that eliminate the F-persistence problem

**Timing**: 4-5 hours (most complex phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (new section)
- Possibly import from `Mathlib.Order.Zorn`

**Verification**:
- `ultrafilter_F_resolution` compiles without sorry
- This is the core contribution that MCS-based approach could not achieve

---

### Phase 5: Convert UltrafilterChain to FMCS [NOT STARTED]

**Goal**: Use ultrafilter-MCS bijection to produce FMCS from ultrafilter chains.

**Tasks**:
- [ ] Define `UltrafilterChain_to_FMCS`: convert chain to FMCS via ultrafilter_to_mcs
  ```lean
  noncomputable def UltrafilterChain_to_FMCS (uc : UltrafilterChain) : FMCS Int where
    mcs := fun t => ultrafilter_to_mcs (uc.chain t)
    is_mcs := ...
    forward_G := ...
    backward_H := ...
  ```
- [ ] Prove `UltrafilterChain_FMCS_forward_G`: G-formulas propagate forward
- [ ] Prove `UltrafilterChain_FMCS_backward_H`: H-formulas propagate backward
- [ ] Verify resulting FMCS satisfies temporal coherence

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- FMCS structure compiles
- forward_G and backward_H proofs complete

---

### Phase 6: Family-Level Temporal Coherence [NOT STARTED]

**Goal**: Prove UltrafilterChain-derived FMCS satisfies TemporalCoherentFamily requirements.

**Tasks**:
- [ ] Prove `ultrafilter_FMCS_forward_F`:
  ```lean
  theorem ultrafilter_FMCS_forward_F (uc : UltrafilterChain) (t : Int) (phi : Formula)
      (h_F : Formula.some_future phi in (UltrafilterChain_to_FMCS uc).mcs t) :
      exists s >= t, phi in (UltrafilterChain_to_FMCS uc).mcs s
  ```
- [ ] Prove symmetric `ultrafilter_FMCS_backward_P`
- [ ] Wrap as `TemporalCoherentFamily` structure
- [ ] Connect to ParametricTruthLemma requirements

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- Family-level coherence proofs compile without sorry
- Can be used with existing truth lemma infrastructure

---

### Phase 7: Integration and Verification [NOT STARTED]

**Goal**: Connect ultrafilter construction to existing completeness infrastructure.

**Tasks**:
- [ ] Define `construct_ultrafilter_bfmcs`: build BFMCS from ultrafilter chains
- [ ] Verify box-class families can be built from ultrafilter chains
- [ ] Prove modal coherence properties (should follow from existing R_Box proofs)
- [ ] Identify remaining gaps for full completeness integration
- [ ] Document the ultrafilter approach vs MCS approach trade-offs

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- BFMCS construction compiles
- Document clearly identifies remaining work for completeness

## Testing & Validation

- [ ] `lake build` succeeds on all modified files
- [ ] No new sorries introduced except explicitly documented exploration gaps
- [ ] `ultrafilter_F_resolution` theorem is sorry-free (Phase 4 core deliverable)
- [ ] Family-level temporal coherence theorems compile (Phase 6)
- [ ] Integration with existing truth lemma infrastructure verified

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Extended with:
  - R_H relation and properties
  - UltrafilterChain structure
  - Temporal coherence proofs
  - FMCS conversion
- `specs/070_explore_ultrafilter_construction/summaries/01_ultrafilter-summary.md` - Completion summary

## Rollback/Contingency

If the ultrafilter approach proves infeasible:
1. All changes are additive to UltrafilterChain.lean - no existing code modified
2. The R_H relation and properties are useful regardless
3. Filter extension lemmas can be marked with sorry for future work
4. The exploration documents which parts of ultrafilter theory work and which need more research
5. Tasks 71/72 (truth lemma modification) provide the parallel lower-risk path

## Dependencies

```
Phase 1: Verify UltrafilterMCS Infrastructure
    |
    v
Phase 2: Define R_H and Accessibility Properties
    |
    v
Phase 3: Define UltrafilterChain Structure
    |
    v
Phase 4: Ultrafilter Temporal Coherence (CORE - highest risk)
    |
    v
Phase 5: Convert to FMCS
    |
    v
Phase 6: Family-Level Coherence Proofs
    |
    v
Phase 7: Integration and Verification
```

All phases are sequential. Phase 4 is the critical path - if filter extension argument proves too difficult, mark with sorry and proceed to gather integration insights.

## Success Criteria

1. **Minimum viable**: R_H defined, UltrafilterChain structure compiles, filter extension approach documented
2. **Partial success**: Phase 4 theorem `ultrafilter_F_resolution` proven or clearly identified gap documented
3. **Full success**: Family-level temporal coherence achieved via ultrafilter chains, connecting to completeness infrastructure
