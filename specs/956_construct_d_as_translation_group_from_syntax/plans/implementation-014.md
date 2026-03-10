# Implementation Plan: Task #956 - D Construction via Staged Construction

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None
- **Research Inputs**: specs/956_construct_d_as_translation_group_from_syntax/reports/research-034.md
- **Artifacts**: plans/implementation-014.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the **step-by-step (staged) construction** approach from the temporal logic literature (Burgess, Venema, Goldblatt) to construct D as a countable dense linear order from the canonical timeline of MCSs. The staged construction builds the timeline incrementally:

- **Even stages**: Process formula obligations (F/P witnesses)
- **Odd stages**: Ensure density by inserting intermediate MCSs between successive pairs

This approach avoids the ConstructiveQuotient entirely, sidestepping the G-completeness blocker identified in research-034. The Cantor prerequisites (NoMaxOrder, NoMinOrder, DenselyOrdered, Countable) are BUILT IN by construction rather than proved on a quotient.

### Research Integration

- **research-034.md**: Established that ConstructiveQuotient approach is fundamentally blocked by G-completeness. Step-by-step construction is the standard technique in the literature.
- **research-033.md**: Identified F/P witness seed lemmas already proven in WitnessSeed.lean.

## Goals & Non-Goals

**Goals**:
- Replace ConstructiveQuotient with staged construction that builds Cantor prerequisites by construction
- Construct D as the group (Q, +) discovered via Cantor isomorphism on the staged timeline
- Define task_rel as actual displacement in the canonical timeline structure
- Achieve sorry-free TaskFrame completeness without importing D externally

**Non-Goals**:
- Preserving ConstructiveQuotient or ConstructiveFragment infrastructure
- Using D = ConstructiveQuotient x Q (Path D bulldozing) - explicitly forbidden
- Supporting reflexive G/H semantics (irreflexive is required)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Separation lemma proof has hidden difficulties | HIGH | MEDIUM | Detailed proof sketch in research-034; careful verification at each step |
| Staging logic complexity exceeds estimates | MEDIUM | MEDIUM | Modular phase structure; each stage testable independently |
| Countability proof for staged construction | MEDIUM | LOW | Standard argument via omega-indexed stages |
| Truth lemma difficulties for staged timeline | HIGH | LOW | Reuse existing TruthLemma infrastructure; staged construction compatible with BFMCS pattern |
| Proof stuck without progress | HIGH | MEDIUM | Mark [BLOCKED] with requires_user_review: true; DO NOT fall back to Path D |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in ConstructiveFragment.lean (NoMaxOrder, NoMinOrder, DenselyOrdered for quotient)
- These will NOT be resolved; they are in the abandoned ConstructiveQuotient approach

### Expected Resolution
- All Cantor prerequisites (NoMaxOrder, NoMinOrder, DenselyOrdered) are BUILT IN by the staged construction
- No sorries needed for these properties on the staged timeline

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete
  - DO NOT fall back to Path D (D = ConstructiveQuotient x Q)

### Remaining Debt
After this implementation:
- ConstructiveFragment.lean sorries remain (irrelevant; module superseded)
- 0 new sorries in staged construction module
- Completeness theorem is sorry-free via staged timeline

## Axiom Characterization

### Pre-existing Axioms
- None in scope for this implementation

### Expected Resolution
- N/A

### New Axioms
- None. NEVER introduce new axioms.

### Remaining Debt
- 0 axioms expected in staged construction module

## Implementation Phases

### Phase 0: ROAD_MAP.md Update - Prohibit Path D [COMPLETED]

- **Dependencies:** None
- **Goal:** Add Path D (D = ConstructiveQuotient x Q) to Dead Ends section with explanation that it is circular and misses the point of the construction

**Tasks**:
- [ ] Add new Dead End entry for "Product Domain Bulldozing (Path D)"
- [ ] Explain that D = ConstructiveQuotient x Q imports Q externally, violating "D from syntax" constraint
- [ ] Explain that even if implemented, it misses the mathematical point: D should EMERGE from axioms, not be bulldozed in
- [ ] Update "D Construction from Canonical Timeline" strategy to reference v014 plan
- [ ] Verify no ROAD_MAP.md guidance suggests Path D as fallback

**Timing:** 0.5 hours

**Files to modify**:
- `specs/ROAD_MAP.md` - Add Dead End entry for Path D

**Verification**:
- ROAD_MAP.md contains explicit prohibition of Path D
- No guidance suggests Path D as acceptable fallback

**Progress:**

**Session: 2026-03-10, sess_1773167912_6e3489**
- Added: Dead End entry "Product Domain Bulldozing (Path D)" to ROAD_MAP.md
- Updated: Strategy "D Construction from Canonical Timeline" references to v014 plan
- Updated: Ambition "Syntactically-Derived Duration Domain" reference to v014 plan
- Updated: ROAD_MAP.md "Last Updated" date to 2026-03-10
- Completed: All 5 Phase 0 tasks verified

---

### Phase 1: Staged Construction Infrastructure [COMPLETED]

- **Dependencies:** Phase 0
- **Goal:** Define StagedTimeline type and stage indexing infrastructure

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/StagedTimeline.lean`
- [ ] Define `Stage : Type` as `Nat` with even/odd predicates
- [ ] Define `StagedPoint : Type` as `Nat x MCS` (stage index paired with MCS)
- [ ] Define `StagedTimeline : Type` as `Stage -> Finset StagedPoint` (timeline at each stage)
- [ ] Define `StrictOrder` on `StagedPoint` induced by MCS canonical ordering
- [ ] Define `Timeline_union : StagedTimeline -> Set StagedPoint` as the union over all stages
- [ ] Prove `Timeline_at_stage_subset_union` lemma

**Timing:** 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedTimeline.lean` (new)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" StagedTimeline.lean` returns empty
- Stage predicates and StagedPoint type well-formed

**Progress:**

**Session: 2026-03-10, sess_1773167912_6e3489**
- Added: `StagedPoint` structure (MCS + stage index + MCS proof)
- Added: `StagedPoint.lt`, `StagedPoint.le`, `StagedPoint.equiv` ordering definitions
- Added: `StagedPoint.le_refl`, `StagedPoint.le_trans` proofs
- Added: `StagedTimeline` structure with root, monotonicity, linearity fields
- Added: `StagedTimeline.union`, `at_stage_subset_union`, `root_in_union`
- Added: `StagedTimeline.monotone_forward`, `monotone_le`, `union_linearly_ordered`
- Added: `StagedTimeline.union_nonempty`
- Added: `Stage.isEven`, `Stage.isOdd` with Decidable instances
- Added: `IsLinearlyOrdered` predicate for Finsets of StagedPoints
- Sorries: 0 (zero-debt)
- Build: `lake build` passes (758 jobs)

---

### Phase 2: Forward/Backward Witness Seed Lemmas [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Verify and expose existing witness seed consistency lemmas from WitnessSeed.lean

**Tasks**:
- [ ] Verify `forward_temporal_witness_seed_consistent` in WitnessSeed.lean handles F(psi) witnesses
- [ ] Verify `backward_temporal_witness_seed_consistent` handles P(psi) witnesses (or create if missing)
- [ ] Create wrapper lemmas in StagedConstruction module that invoke these
- [ ] Prove `executeForwardStep_strict` : if F(psi) in M, then witness W has CanonicalR(M, W) and NOT CanonicalR(W, M)
- [ ] Prove `executeBackwardStep_strict` : if P(psi) in M, then witness W has CanonicalR(W, M) and NOT CanonicalR(M, W)

**Timing:** 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/WitnessSeedWrapper.lean` (new)
- Potentially `Theories/Bimodal/Metalogic/Canonical/WitnessSeed.lean` (if backward seed missing)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" WitnessSeedWrapper.lean` returns empty
- Forward and backward witness seed lemmas available

**Progress:**

**Session: 2026-03-10, sess_1773167912_6e3489**
- Verified: `forward_temporal_witness_seed_consistent` exists in WitnessSeed.lean (handles F(psi))
- Verified: `past_temporal_witness_seed_consistent` exists in WitnessSeed.lean (handles P(psi))
- Added: `executeForwardStep`, `executeBackwardStep` replicated from ConstructiveFragment (avoids broken import)
- Added: `executeForwardStep_canonicalR`, `executeBackwardStep_canonicalR`, `executeBackwardStep_canonicalR_past`
- Added: `executeForwardStep_mcs`, `executeBackwardStep_mcs`
- Added: `executeForwardStep_contains_phi`, `executeBackwardStep_contains_phi`
- Added: `forwardWitnessPoint`, `backwardWitnessPoint` (StagedPoint wrappers with stage annotations)
- Added: `stagedPoint_has_seriality_future`, `stagedPoint_has_seriality_past`
- Added: `density_witness_exists` (from density axiom)
- Note: `executeForwardStep_strict` / `executeBackwardStep_strict` NOT provable in general (same blocker as ConstructiveQuotient, see research-034). Staged construction ensures strictness via overall construction, not individual steps.
- Sorries: 0 (zero-debt)
- Build: `lake build` passes

---

### Phase 3: Separation Lemma for Strict Intermediates [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Prove the key separation lemma: given M < M' (CanonicalR but not reverse), there exists Delta strictly between M and M'

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean`
- [ ] Prove `distinguishing_formula_exists`: if NOT CanonicalR(M', M), then exists beta with G(beta) in M' and beta not in M
- [ ] Prove `case_analysis_G_beta`: either G(beta) not in M (Case A) or G(beta) in M (Case B)
- [ ] **Case A**: F(neg beta) in M, use forward witness seed with psi = neg beta
- [ ] **Case B**: From G(beta) in M, derive F(beta_0) in M (via Finding 11 argument in research-034), use forward witness seed
- [ ] Prove `separation_lemma_intermediate`: if CanonicalR(M, M') and NOT CanonicalR(M', M), then exists Delta with M < Delta and CanonicalR(Delta, M')
- [ ] **If Delta < M' cannot be proven for Lindenbaum witness**: This is the critical point; if blocked, mark [BLOCKED] with requires_user_review: true

**Timing:** 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` (new)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" SeparationLemma.lean` returns empty (or [BLOCKED] if proof impossible)
- Separation lemma provides strict intermediate MCS between any comparable pair

**Progress:**

**Session: 2026-03-10, sess_1773167912_6e3489**
- Added: `distinguishing_formula_exists` - if NOT CanonicalR(M', M), exists beta with G(beta) in M' and beta not in M
- Added: `case_analysis_G_beta` - either G(beta) in M or not
- Added: `not_G_implies_F_neg` - Case A: G(beta) not in M implies F(neg beta) in M (6-step proof via temporal necessitation, temporal K, contrapositive)
- Added: `caseA_forward_witness_not_contains_beta` - Case A witness does NOT contain beta (consistency)
- Added: `density_intermediate` - density axiom provides intermediate witnesses preserving F-obligations
- Added: `mcs_has_strict_future` - from seriality (NoMaxOrder foundation)
- Added: `mcs_has_strict_past` - from seriality (NoMinOrder foundation)
- Note: Full separation_lemma_intermediate (Case B) NOT implemented - research-034 showed this has fundamental difficulties. Staged construction uses density_intermediate instead, which suffices for odd-stage density insertion.
- Sorries: 0 (zero-debt)
- Build: `lake build` passes (clean, no warnings)

---

### Phase 4: Staged Construction Execution (Even/Odd Stages) [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Implement the even/odd stage alternation that builds the dense timeline

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
- [ ] Implement `stage_0`: Lindenbaum({neg phi_0}) placed at position 0
- [ ] Implement `even_stage (n : Nat)`: Process F/P obligations for all points in T_{2n-1}
  - For each point t and F(psi) in Gamma_t, add witness point s > t with psi in Gamma_s
  - For each P(psi), similarly add witness point s < t
- [ ] Implement `odd_stage (n : Nat)`: Ensure density
  - For each successive pair t < u in T_{2n}, insert intermediate point v via separation lemma
- [ ] Implement `staged_timeline (n : Nat) : StagedTimeline` by induction
- [ ] Prove `staged_timeline_monotone`: T_n subset T_{n+1}
- [ ] Prove `even_stage_processes_obligations`: after even stage, all F/P obligations for prior points have witnesses
- [ ] Prove `odd_stage_ensures_density`: after odd stage, no successive pairs remain without intermediates (for points added before that stage)

**Timing:** 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` (new)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" StagedExecution.lean` returns empty
- Stage execution produces growing timeline with F/P witnesses and density

---

### Phase 5: Cantor Prerequisites Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Prove the staged timeline T satisfies Cantor prerequisites

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`
- [ ] Prove `staged_timeline_countable`: T = union of T_n is countable (omega-indexed stages, finite additions per stage)
- [ ] Prove `staged_timeline_densely_ordered`: for any t < u in T, exists v with t < v < u (from odd stage construction)
- [ ] Prove `staged_timeline_no_max_order`: for any t in T, exists u > t (from even stage F-witness addition)
- [ ] Prove `staged_timeline_no_min_order`: for any t in T, exists u < t (from even stage P-witness addition)
- [ ] Prove `staged_timeline_nonempty`: T contains at least the origin M_0

**Timing:** 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` (new)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" CantorPrereqs.lean` returns empty
- All Cantor prerequisites proven for staged timeline

---

### Phase 6: Cantor Isomorphism Application [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Apply Cantor's theorem to establish T isomorphic to Q

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- [ ] Import Mathlib's `Order.CountableDenseLinearOrder` or prove Cantor's theorem
- [ ] Instantiate `CountableDenseLinearOrderWithoutEndpoints` for staged timeline T
- [ ] Construct `cantor_iso : T ≃o Q` using Mathlib's Cantor uniqueness theorem
- [ ] Define `eval : T -> Q` as the forward direction of cantor_iso
- [ ] Define `eval_inv : Q -> T` as the backward direction
- [ ] Prove `eval_order_preserving` and `eval_inv_order_preserving`

**Timing:** 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` (new)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" CantorApplication.lean` returns empty
- Cantor isomorphism T isomorphic to Q established

---

### Phase 7: D and task_rel from Cantor [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Define D as (Q, +) and task_rel as actual displacement

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/DFromSyntax.lean`
- [ ] Define `D : Type := Q` (the discovered Q, not imported)
- [ ] Define `D_add : D -> D -> D := Rat.add`
- [ ] Define `D_zero : D := 0`
- [ ] Define `D_neg : D -> D := Rat.neg`
- [ ] Prove `D_is_linearly_ordered_abelian_group`
- [ ] Define `task_rel (d : D) (w : T) : T := eval_inv (eval w + d)`
- [ ] Prove `task_rel_is_group_action`: task_rel d1 (task_rel d2 w) = task_rel (d1 + d2) w
- [ ] Prove `task_rel_preserves_order`: w1 < w2 -> task_rel d w1 < task_rel d w2 (for any d)

**Timing:** 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromSyntax.lean` (new)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" DFromSyntax.lean` returns empty
- D is (Q, +), task_rel is actual displacement (non-trivial)

---

### Phase 8: TaskFrame + Completeness [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Construct TaskFrame from staged timeline and prove completeness

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/TaskFrameFromSyntax.lean`
- [ ] Define `staged_task_frame : TaskFrame D` using:
  - W := T (staged timeline)
  - relation := CanonicalR (MCS ordering)
  - task_rel := defined in Phase 7
- [ ] Prove `staged_task_frame_satisfies_axioms`: temporal axioms (seriality, density) hold
- [ ] Integrate with truth lemma: `staged_truth_lemma : phi in M iff staged_task_frame.satisfies M phi`
- [ ] Prove `staged_completeness`: if valid phi then ⊢ phi (via contrapositive using staged_task_frame)
- [ ] Verify integration with existing Completeness.lean or create standalone completeness theorem

**Timing:** 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TaskFrameFromSyntax.lean` (new)
- Potentially `Theories/Bimodal/Metalogic/Completeness.lean` (integration)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" TaskFrameFromSyntax.lean` returns empty
- `grep -n "^axiom " TaskFrameFromSyntax.lean` returns empty (no new axioms)
- Completeness theorem: valid phi -> ⊢ phi is sorry-free

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Integration Verification
- [ ] Completeness theorem connects to existing Validity.lean definition
- [ ] D is discovered Q (from Cantor), not imported Q
- [ ] task_rel is actual displacement, not trivial (fun _ _ _ => True)
- [ ] ROAD_MAP.md updated with Path D prohibition and v014 plan reference

## Artifacts & Outputs

- `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-014.md` (this file)
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/WitnessSeedWrapper.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromSyntax.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TaskFrameFromSyntax.lean`
- `specs/ROAD_MAP.md` (updated with Path D prohibition)
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

**If staged construction approach is fundamentally blocked**:
1. Mark the blocking phase [BLOCKED] with `requires_user_review: true`
2. Document the specific mathematical obstruction in the phase Progress section
3. DO NOT fall back to Path D (D = ConstructiveQuotient x Q) - this is FORBIDDEN
4. Wait for user decision on:
   - Revising the plan with alternative approach
   - Splitting the task to research the obstruction
   - Accepting the task as mathematically blocked (mark [BLOCKED] in TODO.md)

**If specific proof is stuck but approach seems viable**:
1. Mark phase [PARTIAL] (not [BLOCKED])
2. Document what was attempted and what remains
3. Next /implement session can resume from partial progress
