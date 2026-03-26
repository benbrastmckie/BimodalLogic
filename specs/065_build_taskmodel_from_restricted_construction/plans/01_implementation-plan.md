# Implementation Plan: Task 65

- **Task**: 65 - build_taskmodel_from_restricted_construction
- **Status**: [NOT STARTED]
- **Effort**: 3-7 hours (depends on verification result)
- **Dependencies**: Task 58 (parent - wire_completeness_to_frame_conditions)
- **Research Inputs**: specs/065_build_taskmodel_from_restricted_construction/reports/03_team-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task bridges the coherence gap between `BFMCS.temporally_coherent` (family-level, required by `shifted_truth_lemma`) and `BundleTemporallyCoherent` (bundle-level, provided by `construct_bfmcs_bundle`). Phase 1 verifies the exact requirements; subsequent phases implement the appropriate solution path based on that verification.

### Research Integration

Key findings from team research report (03_team-research.md):
- Single-history Omega was correctly rejected (cannot distinguish G from Box)
- Existing bundle infrastructure (`construct_bfmcs_bundle`, `ShiftClosedCanonicalOmega`, `shifted_truth_lemma`) is 95% complete
- The gap is "model-theoretic glue": instantiating `valid_over Int phi` with canonical model
- **Critical uncertainty**: Does the proof path require family-level or bundle-level coherence?

## Goals & Non-Goals

**Goals**:
- Verify exactly what coherence level `shifted_truth_lemma` requires
- Bridge the gap from `valid_over Int phi` to MCS membership for completeness
- Enable semantic completeness proofs via `shifted_truth_lemma`
- Eliminate or work around the coherence mismatch from task 58

**Non-Goals**:
- Building entirely new FMCS/bundle infrastructure from scratch
- Proving family-level coherence from bundle-level (known to be blocked)
- Modifying the core `shifted_truth_lemma` proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Family-level coherence truly required | High | Medium | Fall back to Path B (hybrid approach) |
| Bundle-level truth lemma needs new proof | High | Low | Phase 2B includes proof effort |
| Type/universe level mismatches | Medium | Medium | Careful instantiation in Phase 2 |
| Termination proof issues | Medium | Low | Use existing termination patterns |

## Critical Decision Point

Phase 1 verification determines the implementation path:
- **Path A** (3 hours): If bundle-level coherence suffices, wire existing infrastructure
- **Path B** (5-7 hours): If family-level required, implement hybrid approach

## Implementation Phases

### Phase 1: Verify shifted_truth_lemma Requirements [NOT STARTED]

**Goal**: Determine exact coherence requirements and viable proof path

**Tasks**:
- [ ] Use `lean_hover_info` on `shifted_truth_lemma` to confirm signature (DONE: requires `B.temporally_coherent`)
- [ ] Check if `BFMCS.temporally_coherent` can be weakened for the truth lemma backward G/H cases
- [ ] Trace the proof path: where exactly does same-family witness requirement arise?
- [ ] Document decision: Path A viable or Path B required

**Timing**: 0.5 hours

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean:648-750` - shifted_truth_lemma proof
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean:216-219` - BFMCS.temporally_coherent definition

**Decision Gate**:
- If backward G/H cases only need existential witnesses (any family) -> **Path A**
- If backward G/H cases require same-family witnesses -> **Path B**

---

### Phase 2A: Wire Existing Infrastructure (Path A) [NOT STARTED]

**Goal**: Complete the model-theoretic glue using existing bundle construction

**Condition**: Phase 1 confirms bundle-level coherence sufficient OR workaround exists

**Tasks**:
- [ ] Create `valid_over_instantiation` lemma to specialize `valid_over Int phi` to canonical model
- [ ] Verify `ShiftClosedCanonicalOmega B` satisfies shift-closure requirement
- [ ] Apply `shifted_truth_lemma` backward direction: truth -> MCS membership
- [ ] Connect to `construct_bfmcs_bundle_eval_at_zero`: evaluation family at time 0
- [ ] Wire to target sorries in completeness theorems

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - add instantiation lemmas
- `Theories/Bimodal/Metalogic/Completeness.lean` (if exists) OR create new file

**Verification**:
- `lake build` compiles without new sorries
- `#print axioms` on new lemmas shows no sorryAx

---

### Phase 2B: Hybrid Approach - Bundle-Level Truth Lemma (Path B) [NOT STARTED]

**Goal**: Prove truth lemma variant that works with bundle-level coherence

**Condition**: Phase 1 shows family-level coherence required but unavailable

**Tasks**:
- [ ] Analyze backward G case in `shifted_truth_lemma`: where does same-family arise?
- [ ] Define `bundle_shifted_truth_lemma` with `BundleTemporallyCoherent` hypothesis
- [ ] Handle backward G: `G(phi) not in fam.mcs t` -> `F(neg phi) in fam.mcs t` -> witness in SOME family
- [ ] Key insight: For completeness, we only need evaluation at the original MCS, not arbitrary families
- [ ] Prove restricted version: works for `eval_family` (the family containing original MCS)
- [ ] Wire to completeness via evaluation-point specialization

**Timing**: 4-6 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/BundleTruthLemma.lean` - new file for bundle-level variant
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - add helper lemmas

**Substeps for backward G**:
1. `G(phi) not in fam.mcs t` -> by MCS maximality, `neg(G(phi)) = F(neg(phi)) in fam.mcs t`
2. By `BundleTemporallyCoherent`: exists `fam' in families, s > t, neg(phi) in fam'.mcs s`
3. For completeness proof: only need this for `eval_family`, where `phi in M0` implies something about truth
4. Use: truth at `eval_family` with shift-closed Omega includes histories from ALL families
5. Contradiction via Box/Diamond interaction (if phi fails somewhere, Diamond(neg(phi)) holds)

**Verification**:
- Proof compiles without sorry
- Works with `construct_bfmcs_bundle` output directly

---

### Phase 3: Final Verification and Cleanup [NOT STARTED]

**Goal**: Ensure completeness proofs connect properly

**Tasks**:
- [ ] Run `lake build` - no new sorries or errors
- [ ] Run `#print axioms` on key theorems to verify no sorryAx dependency
- [ ] Document which path was taken and why
- [ ] Update relevant README files with new theorem locations
- [ ] If any sorries remain, document them with clear explanations

**Timing**: 0.5 hours

**Files to verify**:
- All modified files from Phase 2A or 2B
- `Theories/Bimodal/Metalogic/Bundle/README.md` - update theorem inventory

**Verification**:
- `lake build` succeeds
- No increase in sorry count from baseline
- Key completeness lemmas available for use

## Testing & Validation

- [ ] `lake build` compiles all files without errors
- [ ] `#print axioms shifted_truth_lemma` shows no sorryAx (baseline)
- [ ] `#print axioms <new_lemmas>` shows no sorryAx
- [ ] Key theorem signature matches expected: `valid_over Int phi -> ... -> provable phi`

## Artifacts & Outputs

- `plans/01_implementation-plan.md` (this file)
- New/modified Lean files (depends on path taken):
  - Path A: `CanonicalConstruction.lean`, possibly new Completeness file
  - Path B: `BundleTruthLemma.lean` (new), `UltrafilterChain.lean`
- `summaries/01_implementation-summary.md` (after completion)

## Rollback/Contingency

If implementation fails:
1. Revert to pre-implementation state (git checkout)
2. Document the specific blocking issue encountered
3. Consider spawning subtask for the specific blocker
4. Preserve any partial progress in notes for future attempt

**Known blockers from task 58 spawn analysis**:
- Bundle vs family coherence mismatch is fundamental
- Cannot prove family-level from bundle-level without new construction approach
- Omega-enumeration approach (`construct_bfmcs_omega`) is designed but not yet implemented
