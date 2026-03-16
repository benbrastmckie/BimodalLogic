# Implementation Plan: Task #979 (v3)

- **Task**: 979 - remove_discrete_icc_finite_axiom_prove_stage_bounding
- **Status**: [COMPLETED]
- **Effort**: 4-6 hours
- **Dependencies**: Task 974 [COMPLETED], Task 980 [COMPLETED]
- **Research Inputs**:
  - specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-004.md (team math research - h_content duality + phi=neg_bot)
  - specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-003.md (post-980 analysis)
  - specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-005.md (IRR axiom analysis)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, proof-debt-policy.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan takes a time-boxed approach to removing `discrete_Icc_finite_axiom` from `DiscreteTimeline.lean`. Previous attempts (v1, v2) failed at the covering lemma proof. This plan follows research-004.md's recommended paths with a clear fallback: if covering cannot be proven within the time budget, the axiom is accepted as documented technical debt.

**Key insight from research-004**: Two new theoretical tools improve our position:
1. **h_content duality chain**: If K is strictly between M and W, then `h_content(W) ⊆ K ⊆ M`. Any H-formula in W propagates through K into M.
2. **phi = neg bot analysis**: Check if `H(neg bot)` is derivable. If yes, DF forces specific F-obligations that constrain witnesses.
3. **Density proof template**: DensityFrameCondition.lean provides a case-split structure that may be invertible.

**Approach**: Time-boxed proof attempts with clear decision points. No guaranteed success; honest fallback to documented debt.

## Goals & Non-Goals

**Goals**:
- Attempt to prove covering lemma via research-004.md approaches (2-4 hours)
- If successful: remove `discrete_Icc_finite_axiom`, derive LocallyFiniteOrder from covering
- If unsuccessful: document specific gap, retain axiom as disclosed debt

**Non-Goals**:
- Stage-bounding approach (proven mathematically flawed in research-001, research-003)
- Partial proofs with sorries (violates zero-debt gate)
- Unlimited time investment (task 978 needs to proceed)

## Axiom & Sorry Policy

### Pre-existing
- 1 axiom: `discrete_Icc_finite_axiom` (DiscreteTimeline.lean line 332)
- 1 sorry: `mcs_has_immediate_successor` (DiscreteTimeline.lean line 296)

### Target (Success Path)
- 0 axioms in DiscreteTimeline.lean
- 0 sorries

### Target (Fallback Path)
- 1 axiom: `discrete_Icc_finite_axiom` retained with updated documentation
- 0 sorries (remove `mcs_has_immediate_successor` or mark theorem as not needed)

### Constraint
- NEVER introduce NEW axioms or sorries
- If proof cannot be completed within time budget, mark [BLOCKED] and choose fallback

---

## Implementation Phases

### Phase 1: Verify H(neg bot) Derivability [COMPLETED]

- **Dependencies:** None
- **Goal:** Check whether `H(neg bot)` is a theorem, confirming research-004 phi=neg_bot path viability

**Tasks:**
- [x] Search for existing `H(neg bot)` or `all_past (neg bot)` derivability lemma in proof system
- [x] If not found, attempt to prove: `[] derive (Formula.all_past (Formula.neg Formula.bot))`
- [x] If derivable, document path: seriality_past axiom gives `P(neg bot)` in every MCS, but `H(neg bot)` requires different reasoning
- [x] If NOT derivable, document that phi=neg_bot path is blocked

**Timing:** 30 minutes

**Verification:**
- Clear determination of H(neg bot) derivability status
- Documentation of implications for covering proof

**Progress:**

**Session: 2026-03-16, sess_1773784816_4a7c2e**
- Verified: `H(neg bot)` IS derivable via `derive_past_necessitation`
- Path: `neg bot = bot → bot` is derivable via identity combinator (`Bimodal.Theorems.Combinators.identity`)
- Then: `derive_past_necessitation` (CantorPrereqs.lean:314) derives `H(phi)` from `⊢ phi`
- Implication: phi=neg_bot path is VIABLE for covering proof attempt
- Key fact: Every MCS contains `H(neg bot)` since it's a theorem

---

### Phase 2: Attempt Covering Proof via h_content Duality [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Complete proof of `mcs_has_immediate_successor` using h_content duality chain

This is the core time-boxed attempt (2 hours max).

**Proof Strategy (from research-004.md)**:

Given M serial with forward witness W, suppose K is strictly between M and W:
- h_MK: `g_content(M) ⊆ K`
- h_KW: `g_content(K) ⊆ W`
- K distinct from both M and W

By h_content duality chain:
- `g_content(M) ⊆ K` implies `h_content(K) ⊆ M`
- `g_content(K) ⊆ W` implies `h_content(W) ⊆ K`
- Combined: any `H(phi) ∈ W` implies `phi ∈ K` and if `H(phi) ∈ K` then `phi ∈ M`

**Sub-task 2a: Identify Distinguishing Formula**
- [ ] Since K ≠ W, exists chi with either: (chi ∈ W and chi ∉ K) or (chi ∈ K and chi ∉ W)
- [ ] Explore constraints on chi from g_content structure

**Sub-task 2b: Apply DF Semantics**
- [ ] DF in M: if `phi ∈ M` and `H(phi) ∈ M`, then `F(H(phi)) ∈ M`
- [ ] The F-obligation `F(H(phi))` must be witnessed by some successor
- [ ] Determine if witness constraints create contradiction with intermediate K

**Sub-task 2c: Case Analysis on phi**
- [ ] Try phi = neg bot (if H(neg bot) derivable from Phase 1)
- [ ] Try phi from g_content(M) structure
- [ ] Try phi from W's Lindenbaum construction

**Sub-task 2d: Proof Completion or Gap Documentation**
- [ ] If contradiction derived: complete `mcs_has_immediate_successor` proof
- [ ] If stuck: document specific gap point and blocking formula analysis

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - covering proof

**Timing:** 2 hours (hard cap)

**Verification:**
- Either: `mcs_has_immediate_successor` proof compiles without sorry
- Or: Detailed documentation of the specific formula/property blocking proof

**Progress:**

**Session: 2026-03-16, sess_1773784816_4a7c2e**
- BLOCKED: No complete proof path found after extensive exploration
- Verified: h_content duality infrastructure available (g_content_subset_implies_h_content_reverse)
- Attempted: Using distinguishing formula delta between K and M
  - delta in K, neg(delta) in M leads to F(delta) in M, P(neg(delta)) in K
  - But G(delta) in K just gives delta in W (no contradiction)
- Attempted: Using DF with phi = neg bot
  - F(H(neg bot)) in M, but this can be witnessed by K or W - no constraint on intermediates
- Gap identified: DF/DP create existence obligations, but cannot force witnesses to be specific MCSes
- This matches the gap documented in research-003.md and research-004.md
- Proceeding to Phase 3 (density template study)

---

### Phase 3: Study Density Template for Covering Inversion [COMPLETED]

- **Dependencies:** Phase 2 (only if Phase 2 blocked)
- **Goal:** Attempt covering proof by inverting density proof structure

**Tasks:**
- [ ] Read DensityFrameCondition.lean `density_frame_condition_caseA` carefully
- [ ] Map density proof structure to covering needs:
  - Density FINDS intermediate via double-density trick
  - Covering must EXCLUDE intermediate
- [ ] Identify case-split variable in density proof
- [ ] Attempt same case-split for covering: show each case forces K=M or K=W

**Specific Analysis:**
- [ ] In density proof, what formula delta distinguishes M' from M?
- [ ] For covering, same delta might force K to collapse
- [ ] Key: density finds V between M and M'; covering shows no V exists

**Timing:** 1.5 hours (only if Phase 2 blocked)

**Verification:**
- Either: New proof approach found, proceed to proof attempt
- Or: Document why density template doesn't invert for covering

**Progress:**

**Session: 2026-03-16, sess_1773784816_4a7c2e**
- Studied DensityFrameCondition.lean (lines 107-240)
- Density proof structure understood:
  1. NOT CanonicalR(M', M) gives distinguishing formula delta
  2. DN axiom provides F(F(neg delta)) from F(neg delta)
  3. Construct intermediate W1, then V via forward witness
  4. Temporal linearity places V between M and M'
- Key insight: Density proof uses NEGATIVE constraint to get delta, then DN to CONSTRUCT intermediate
- Covering proof has POSITIVE constraints (CanonicalR M K, CanonicalR K W), needs to EXCLUDE intermediate
- Structural asymmetry: existence vs exclusion proofs are fundamentally different
- No direct inversion found - density template does not provide covering path
- Proceeding to Phase 4 (Decision Point - Fallback)

---

### Phase 4: Decision Point and Fallback [COMPLETED]

- **Dependencies:** Phase 2, Phase 3 (if attempted)
- **Goal:** Make final decision on axiom handling based on proof attempt outcomes

**Decision Tree:**

```
Phase 2 success?
├── YES: Proceed to Phase 5 (success path)
└── NO: Phase 3 attempted?
    ├── NO: Attempt Phase 3
    └── YES: Phase 3 success?
        ├── YES: Proceed to Phase 5 (success path)
        └── NO: Execute fallback (documented debt)
```

**Fallback Tasks (if both Phase 2 and Phase 3 fail):**
- [ ] Update axiom docstring with research-004 insights
- [ ] Remove `mcs_has_immediate_successor` theorem and sorry (dead code)
- [ ] Document that covering lemma remains open subproblem
- [ ] Update state.json: task 979 status to `[PARTIAL]` with documented gap
- [ ] Verify `lake build` passes with retained axiom
- [ ] Create summary documenting proof attempts and specific gaps

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - axiom docstring, dead code removal

**Timing:** 30 minutes

**Verification:**
- Clear documentation of gap or clear path forward
- `lake build` passes
- state.json updated appropriately

**Progress:**

**Session: 2026-03-16, sess_1773784816_4a7c2e**
- Executed fallback path (Phase 2 and 3 both blocked)
- Updated axiom docstring with research-004 insights (h_content duality, attempted approaches)
- Removed mcs_has_immediate_successor theorem with sorry (dead code)
- Replaced covering lemma section with comprehensive "Open Subproblem" documentation
- Verified `lake build` passes: Build completed successfully (930 jobs)
- Verified no sorries in DiscreteTimeline.lean
- Verified 1 axiom remains: discrete_Icc_finite_axiom (line 316)
- Axiom retained as documented technical debt per proof-debt-policy.md

---

### Phase 5: Complete Success Path (Conditional) [SKIPPED]

- **Dependencies:** Phase 4 (success path chosen)
- **Goal:** If covering proven, complete axiom removal

**Tasks (only if Phase 2 or 3 succeeded):**
- [ ] Verify `mcs_has_immediate_successor` compiles without sorry
- [ ] Define `discreteSuccFn_direct` from covering lemma
- [ ] Prove SuccOrder axioms from covering
- [ ] Prove `discrete_Icc_finite_from_covering` via induction
- [ ] Remove `discrete_Icc_finite_axiom`
- [ ] Update `LocallyFiniteOrder` instance to use structural proof
- [ ] Verify all instances work (SuccOrder, PredOrder, IsSuccArchimedean)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Timing:** 2 hours

**Verification:**
- `grep -n "^axiom " DiscreteTimeline.lean` returns empty
- `grep -n "\bsorry\b" DiscreteTimeline.lean` returns empty
- `lake build` passes

---

### Phase 6: Final Verification [COMPLETED]

- **Dependencies:** Phase 5 (success) or Phase 4 (fallback)
- **Goal:** Complete verification and documentation

**Tasks:**
- [ ] Run `lake build` for full project verification
- [ ] Verify dependent files compile
- [ ] Create implementation summary documenting outcome
- [ ] Update TODO.md with final status

**Files:**
- Summary at `specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/summaries/implementation-summary-YYYYMMDD.md`

**Timing:** 30 minutes

**Verification:**
- `lake build` passes
- Summary created
- TODO.md updated

**Progress:**

**Session: 2026-03-16, sess_1773784816_4a7c2e**
- Full `lake build` verified: 975 jobs completed successfully
- Implementation summary created: summaries/implementation-summary-20260316.md
- Task status: PARTIAL (axiom retained as documented debt)

---

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `mcs_has_immediate_successor` (line 296) - placeholder for covering lemma proof

### Expected Resolution

**Success Path:**
- Phase 2 or 3 resolves the sorry via h_content duality + DF semantics

**Fallback Path:**
- Remove `mcs_has_immediate_successor` theorem entirely (dead code if axiom retained)

### New Sorries
- None. NEVER introduce new sorries.
- If proof cannot be completed: mark phase [BLOCKED], trigger fallback path

### Remaining Debt
**Success path:** 0 sorries, 0 axioms
**Fallback path:** 0 sorries, 1 axiom (retained with disclosure)

---

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom: `discrete_Icc_finite_axiom` (DiscreteTimeline.lean line 332)

### Expected Resolution

**Success Path:**
- Phase 5 eliminates axiom via covering + SuccOrder + interval induction

**Fallback Path:**
- Axiom retained with enhanced documentation per proof-debt-policy.md
- Disclosure: "Interval finiteness assumed; structural proof via covering lemma blocked at [specific gap]"

### New Axioms
- None. NEVER introduce new axioms.

### Remaining Debt

**Success:** 0 axioms
**Fallback:** 1 axiom retained, downstream theorems inherit dependency, publication requires disclosure

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty (or only dead code removed)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` shows expected count (0 or 1)
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Implementation summary created
- [ ] TODO.md and state.json synchronized

---

## Artifacts & Outputs

- `specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/plans/implementation-003.md` (this file)
- `specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

---

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Covering lemma proof gap persists | Medium | High | Clear fallback path with documented debt |
| Time exceeds budget | Low | Medium | Hard time caps on each phase |
| Density template doesn't invert | Low | Medium | Secondary approach, not primary |
| Task 978 blocked on 979 | Low | Low | Fallback allows 978 to proceed |

---

## Rollback/Contingency

**Fallback is built in**: If covering proof fails, axiom is retained with documentation. This is not a failure but an acceptable outcome per research-004 recommendations.

**Git rollback**: If any phase introduces build failures, revert to pre-phase commit.

---

## Revision History

- **v1** (implementation-001.md): Initial plan, Phase 2 blocked on covering lemma
- **v2** (implementation-002.md): Detailed sub-phases for covering proof, still blocked
- **v3** (implementation-003.md): Time-boxed approach with research-004 insights, explicit fallback to documented debt
