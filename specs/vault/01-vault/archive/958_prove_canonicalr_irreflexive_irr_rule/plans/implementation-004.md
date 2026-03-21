# Implementation Plan: Task #958 - Path A: Direct F Proof (Substitute-and-Derive)

- **Task**: 958 - prove_canonicalr_irreflexive_irr_rule
- **Status**: [PARTIAL]
- **Effort**: 3-4 hours
- **Dependencies**: None (builds on existing Phases 1-3 infrastructure)
- **Research Inputs**: specs/958_prove_canonicalr_irreflexive_irr_rule/reports/research-007.md
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements **Path A: Substitute-and-Derive (Direct F Proof)** from research-007.md. The approach attempts to derive `bot in M` DIRECTLY from CanonicalR(M, M) by finding a SPECIFIC formula psi such that `derives psi` and `neg(psi) in M`, without constructing the naming MCS M'.

**Critical Research Finding**: Research-007.md analyzed Path A extensively and concluded: "I believe the correct approach is Path B below." The research identifies that while the naming set NS(p) is consistent, showing that a specific derivable formula is not in M (or its negation is in M) has not been achieved. This plan represents a structured implementation attempt to either:
1. Discover a working formula psi that the research analysis missed, OR
2. Formally verify that Path A cannot work, with documented evidence for Path B fallback

### Research Integration

Key findings from research-007.md (Path A analysis):

1. **CanonicalR(M, M) properties**: For all phi, `G(phi) in M -> phi in M`. Equivalently: `GContent(M) subset M`.
2. **temp_a consequence**: If `atom(p) in M`, then `G(P(atom(p))) in M`, so `P(atom(p)) in GContent(M) subset M`.
3. **H(neg(atom(p))) placement**: When `atom(p) in M`, we have `H(neg(atom(p))) not-in M` (since `P(atom(p)) in M`).
4. **Naming set consistency**: NS(p) = atomFreeSubset(M, p) union {atom(p), H(neg(atom(p)))} is consistent (proven).
5. **The gap**: P(atom(p)) is NOT derivable from the naming set alone (that would contradict naming_set_consistent). We need a DIFFERENT formula psi.

## Goals & Non-Goals

**Goals**:
- Systematically search for a formula psi such that `derives psi` and `neg(psi) in M` under CanonicalR(M, M)
- Implement helper lemmas for formula membership properties under CanonicalR closure
- If such psi exists: complete the proof; if not: formally document why Path A fails
- Maintain zero sorries in new code (use [BLOCKED] if proof intractable)
- Produce clear evidence for Path B fallback if Path A fails

**Non-Goals**:
- Do not construct M' (that is Path B/C approach)
- Do not use conservative extension F+ (that is Path B/C approach)
- Do not modify existing Formula, Axiom, or DerivationTree types
- Do not build F+ MCS infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| No suitable psi exists (as research predicts) | HIGH | HIGH | Document failure formally; pivot to Path B with GContent seed |
| Formula search is infinite/undirected | MEDIUM | MEDIUM | Structured search by formula complexity and axiom schemas |
| MCS membership proofs become intractable | MEDIUM | MEDIUM | Use existing MCS infrastructure; limit to temp_a/temp_4 consequences |
| Time spent without resolution | HIGH | HIGH | Strict 2-hour cap on Phase 2 exploration; early pivot if stuck |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `CanonicalIrreflexivity.lean` at lines 1245 and 1328
- These sorries stem from GContent transfer gap and final contradiction step

### Expected Resolution
- If Path A succeeds: prove `canonicalR_irreflexive` via direct F contradiction
- If Path A fails: document failure, recommend Path B, no sorries introduced

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - Document what was tried and why it failed
  - Recommend Path B as fallback

### Remaining Debt
After this implementation:
- If success: 0 sorries, task complete
- If failure: 2 pre-existing sorries remain, clear pivot path to implementation-005.md (Path B)

## Implementation Phases

### Phase 1: CanonicalR Closure Lemmas [COMPLETED]

- **Dependencies:** None
- **Goal:** Formalize the syntactic consequences of CanonicalR(M, M) to support formula search

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean`
- [ ] Import necessary modules (CanonicalFrame, SetMCS, Theorems)
- [ ] Prove `canonicalR_closure_temp_a`: If CanonicalR(M, M) and phi in M, then P(phi) in M
  - From temp_a: phi in M implies G(P(phi)) in M
  - From CanonicalR: G(P(phi)) in M implies P(phi) in M
- [ ] Prove `canonicalR_closure_temp_4`: If CanonicalR(M, M) and G(phi) in M, then G(G(phi)) in M (and hence G(phi) in GContent(M))
- [ ] Prove `canonicalR_G_propagates`: If CanonicalR(M, M) and phi in M, then G(P(phi)) in M (from temp_a directly)
- [ ] Prove `canonicalR_H_neg_exclusion`: If CanonicalR(M, M) and atom(p) in M, then H(neg(atom(p))) not-in M
  - Proof: P(atom(p)) in M (by temp_a + CanonicalR), so neg(H(neg(atom(p)))) in M, hence H(neg(atom(p))) not-in M by MCS consistency
- [ ] Prove `canonicalR_F_presence`: If CanonicalR(M, M) and G(phi) not-in M, then F(neg(phi)) in M
  - Follows from MCS negation completeness

**Timing:** 45 minutes

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` (~100 lines)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` returns empty
- All lemmas have correct signatures

---

### Phase 2: Systematic Formula Search [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Search for formula psi such that `derives psi` and `neg(psi) in M` under CanonicalR(M, M)

This is the core exploratory phase. The research predicts this will fail, but we attempt a systematic search.

**Candidate Formulas to Investigate:**

Based on research-007.md analysis, the following formula classes should be examined:

1. **Seriality-based**: F(neg(bot)) is a theorem. Does this give us neg(something) in M that contradicts?
   - From seriality: G(bot) not-in M (otherwise bot in M by CanonicalR)
   - F(neg(bot)) in M, i.e., neg(G(bot)) in M. This is expected.

2. **temp_a iterations**: phi -> G(P(phi)). Apply repeatedly to atom(p).
   - atom(p) in M -> G(P(atom(p))) in M -> P(atom(p)) in M -> G(P(P(atom(p)))) in M -> ...
   - These are all IN M under CanonicalR. No contradiction.

3. **Negation variants**: From neg(G(phi)) = F(neg(phi)) in M:
   - If neg(G(atom(p))) in M, then G(atom(p)) not-in M, so atom(p) not-in GContent(M). But atom(p) could still be in M directly.

4. **IRR-derived theorems**: The IRR rule derives phi from (atom(p) AND H(neg(atom(p)))) -> phi when p fresh for phi.
   - Standard IRR instances: density theorems like G(phi) -> G(G(phi)) (but this is also temp_4)
   - The key: find IRR-derivable psi such that neg(psi) in M under CanonicalR

5. **Contrapositive of naming set consistency**:
   - naming_set_consistent says: NS(p) = atomFreeSubset(M, p) union {atom(p), H(neg(atom(p)))} is consistent
   - IF we could show NS(p) is INCONSISTENT under CanonicalR(M, M), we would be done
   - But naming_set_consistent's proof USES the assumption that M is consistent, not that CanonicalR(M, M) holds

**Tasks:**
- [ ] Extend `DirectIrreflexivity.lean` with exploration section
- [ ] Investigate candidate 1: seriality-based formulas
  - Document what we get: F(neg(bot)) in M, G(bot) not-in M
  - Check if any contradiction arises
- [ ] Investigate candidate 2: temp_a iteration formulas
  - Document the chain: atom(p) -> P(atom(p)) -> P(P(atom(p))) -> ...
  - All are in M; no contradiction
- [ ] Investigate candidate 3: negation variants
  - For atom(p) in M: explore neg(G(neg(atom(p)))) = F(atom(p)) presence
  - Document findings
- [ ] Investigate candidate 4: IRR-derived theorems
  - List specific IRR instances from the codebase
  - Check if any yield a contradiction under CanonicalR
- [ ] Investigate candidate 5: naming set consistency strengthening
  - Can we show naming_set_consistent's proof breaks under CanonicalR(M, M)?
  - If CanonicalR(M, M), does the naming set become inconsistent?
- [ ] **Decision point**: After investigation, document:
  - If psi found: proceed to Phase 3
  - If no psi found: formally document why, mark phase [BLOCKED], recommend Path B

**Timing:** 2 hours (HARD LIMIT - do not exceed)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` (+100-200 lines of exploration)

**Verification:**
- Document all attempted formulas and outcomes
- If successful: have a concrete psi with proof sketch
- If unsuccessful: have a clear explanation of why each candidate fails

**Escape Valve:** If after 2 hours no suitable psi is found, mark [BLOCKED] with:
- List of all attempted formulas
- Why each fails
- Formal recommendation for Path B (GContent seed approach)
- Set `requires_user_review: true`

---

### Phase 3: Direct Contradiction Proof (if psi found) [BLOCKED]

- **Dependencies:** Phase 2 (successful)
- **Goal:** Complete the irreflexivity proof using the discovered formula psi

**Precondition:** Phase 2 must have found a specific formula psi such that:
- `derives psi` (psi is a theorem of F)
- `neg(psi) in M` under the assumption CanonicalR(M, M)

**Tasks:**
- [ ] Formalize the derivation of psi in Lean (or use existing theorem)
- [ ] Prove `psi_negation_in_M`: CanonicalR M M -> neg(psi) in M
  - Use Phase 1 closure lemmas
- [ ] Prove `canonicalR_irreflexive_direct`:
  ```lean
  theorem canonicalR_irreflexive_direct (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
      ¬CanonicalR M M := by
    intro h_R
    -- psi is a theorem, so psi in M
    have h_psi_in_M : psi in M := theorem_in_mcs h_mcs derives_psi
    -- Under CanonicalR, neg(psi) in M
    have h_neg_psi_in_M : neg(psi) in M := psi_negation_in_M h_R
    -- Contradiction: both psi and neg(psi) in M
    exact mcs_no_contradiction h_mcs h_psi_in_M h_neg_psi_in_M
  ```
- [ ] Verify proof compiles without sorry

**Timing:** 30-45 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` (+50 lines)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" DirectIrreflexivity.lean` returns empty
- `canonicalR_irreflexive_direct` compiles without sorry

**Note:** This phase only executes if Phase 2 succeeds. If Phase 2 is [BLOCKED], skip to Phase 4.

---

### Phase 4: Integration or Pivot [COMPLETED]

- **Dependencies:** Phase 2 or Phase 3
- **Goal:** Either integrate the successful proof OR document failure and recommend Path B

**Branch A: Phase 3 Succeeded**

- [ ] Update `CanonicalIrreflexivity.lean` to import `DirectIrreflexivity`
- [ ] Replace sorries at lines 1245 and 1328 with call to `canonicalR_irreflexive_direct`
- [ ] Run full `lake build` to verify
- [ ] Create implementation summary documenting the successful formula psi

**Branch B: Phase 2 Failed (BLOCKED)**

- [ ] Create detailed failure documentation in DirectIrreflexivity.lean:
  ```lean
  /-!
  ## Path A Analysis: Direct F Proof

  This module documents the systematic search for a formula psi such that:
  - `derives psi` (psi is a theorem)
  - `neg(psi) in M` under CanonicalR(M, M)

  ### Attempted Candidates

  1. **Seriality-based**: [documented outcome]
  2. **temp_a iterations**: [documented outcome]
  3. **Negation variants**: [documented outcome]
  4. **IRR-derived theorems**: [documented outcome]
  5. **Naming set strengthening**: [documented outcome]

  ### Conclusion

  No suitable formula psi was found. The fundamental issue is:
  [detailed mathematical explanation]

  ### Recommendation

  Implement Path B (GContent seed + conservative extension) as described in
  implementation-003.md, modified to use the GContent seed instead of atomFreeSubset seed.
  -/
  ```
- [ ] Create `plans/implementation-005.md` skeleton for Path B with GContent seed
- [ ] Update task status to reflect blocked state

**Timing:** 30-45 minutes

**Files to modify/create:**
- `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` (documentation)
- `CanonicalIrreflexivity.lean` (if Branch A) OR
- `plans/implementation-005.md` (if Branch B)

**Verification:**
- Branch A: `lake build` passes, zero sorries in DirectIrreflexivity.lean
- Branch B: Clear documentation of failure, Path B plan skeleton created

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Path A Specific
- [ ] If successful: `canonicalR_irreflexive_direct` has signature `(M : Set Formula) -> SetMaximalConsistent M -> Not (CanonicalR M M)`
- [ ] If blocked: Detailed documentation of all attempted formulas and why each fails

### Integration Verification (if successful)
- [ ] `CanonicalIrreflexivity.lean` compiles with no sorries related to irreflexivity
- [ ] Task 956 Phase 6 can proceed (dependency unblocked)

## Artifacts & Outputs

**Success Path:**
- `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` (~200-300 lines)
- Updated `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (sorries removed)
- `specs/958_prove_canonicalr_irreflexive_irr_rule/summaries/implementation-summary-YYYYMMDD.md`

**Failure Path:**
- `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean` (~150-200 lines, documentation + helper lemmas)
- `specs/958_prove_canonicalr_irreflexive_irr_rule/plans/implementation-005.md` (Path B with GContent seed)
- No changes to `CanonicalIrreflexivity.lean`

Plan artifact:
- `specs/958_prove_canonicalr_irreflexive_irr_rule/plans/implementation-004.md` (this file)

## Rollback/Contingency

1. **If Phase 2 fails (expected based on research):**
   - All new code is in separate `DirectIrreflexivity.lean` file
   - No existing files modified until Phase 4 Branch A
   - Pivot to implementation-005.md (Path B with GContent seed)

2. **If implementation partially completes:**
   - Phase 1 lemmas are independently useful for any approach
   - Phase 2 documentation provides evidence for why Path A fails
   - Both are valuable even if full proof not achieved

3. **If time runs out:**
   - Mark current phase [PARTIAL]
   - Commit progress
   - Next /implement resumes from partial state

4. **Path B Fallback (from research-007.md):**
   - Use GContent seed: `S_ext = embed '' GContent(M) union {atom_ext(q), H_ext(neg_ext(atom_ext(q)))}`
   - This resolves GContent transfer gap completely
   - Requires F+-MCS infrastructure OR the M'_F restriction technique
   - Estimated: 3-4 additional hours

**Progress:**

**Session: 2026-03-11, sess_1773270655_5d33ca**
- Added: `canonicalR_closure_temp_a` - phi in M implies P(phi) in M under CanonicalR(M,M)
- Added: `canonicalR_closure_temp_4` - G(phi) in M implies G(G(phi)) in M
- Added: `canonicalR_G_propagates` - phi in M implies G(P(phi)) in M (from temp_a)
- Added: `canonicalR_H_neg_exclusion` - atom(p) in M implies H(neg(atom(p))) not-in M
- Added: `canonicalR_neg_G_from_not_mem` - G(phi) not-in M implies neg(G(phi)) in M
- Completed: Phase 1 (5 closure lemmas, sorry-free, build passes)
- Completed: Phase 2 analysis (no formula psi exists -- proved impossible)
- Completed: Phase 4 Branch B (failure documented, Path B plan created)
- Sorries: 2 -> 2 (pre-existing, not addressed by Path A)
- Created: `DirectIrreflexivity.lean` (~300 lines, sorry-free)
- Created: `implementation-005.md` (Path B plan skeleton)
