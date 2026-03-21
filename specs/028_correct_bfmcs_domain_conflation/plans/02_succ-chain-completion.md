# Implementation Plan: Task #28 (Revision 2)

- **Task**: 28 - Correct W=D conflation in BFMCS domain architecture
- **Status**: [NOT STARTED]
- **Effort**: 3 hours (reduced from original 12, focused on remaining work)
- **Dependencies**: None (infrastructure complete)
- **Research Inputs**:
  - specs/028_correct_bfmcs_domain_conflation/reports/02_blocker-analysis.md
  - specs/006_canonical_taskframe_completeness/reports/17-20
- **Artifacts**: plans/02_succ-chain-completion.md (this file)
- **Type**: lean4
- **Previous Plan**: 01_bfmcs-domain-correction.md (original 8-phase plan)

## Revision Summary

The original plan (v1) attempted to fix `DirectMultiFamilyBFMCS.lean` sorries. Analysis confirms these sorries require the S5 axiom (Euclidean property) which TM logic does not have.

**Critical insight from reports 17-20**: The correct architecture bypasses BFMCS entirely using a single-family Succ-chain approach. This infrastructure is already 90% implemented.

**Remaining work**: Prove 4 axioms in `SuccChainFMCS.lean` that are provable using existing theorems.

## Goals & Non-Goals

**Goals**:
- Prove 4 remaining axioms in SuccChainFMCS.lean
- Complete the discrete completeness path via Succ-chain bypass
- Wire truth lemma to SuccChainFMCS single family

**Non-Goals**:
- Fixing DirectMultiFamilyBFMCS.lean (architecturally impossible without S5)
- Dense completeness (separate from this task, depends on task 27)
- Removing S5-blocked sorries (document as architectural limitation)

## Existing Infrastructure (Already Complete)

| Component | File | Status |
|-----------|------|--------|
| f_content, p_content | SuccRelation.lean | Complete (0 sorries) |
| Succ relation | SuccRelation.lean | Complete (0 sorries) |
| CanonicalTask relation | CanonicalTaskRelation.lean | Complete (0 sorries) |
| bounded_witness theorem | CanonicalTaskRelation.lean | Complete |
| CanonicalTaskTaskFrame | SuccChainTaskFrame.lean | Complete (0 sorries) |
| succ_chain_history | SuccChainWorldHistory.lean | Complete (0 sorries) |
| SuccExistence | SuccExistence.lean | 3 axioms (seed consistency, documented) |
| SuccChainFMCS | SuccChainFMCS.lean | **4 axioms to prove** |

## Implementation Phases

### Phase 1: Prove F_top/P_top Propagation Axioms [NOT STARTED]

**Goal**: Prove that F(top) and P(top) propagate through Succ chains

**Tasks**:
- [ ] Prove `F_top_propagates`: `F_top in M AND Succ M M' -> F_top in M'`
- [ ] Prove `P_top_propagates`: `P_top in M AND Pred M M' -> P_top in M'`

**Approach**:
- F(top) is a theorem in TM logic (seriality: `G(top) -> F(top)`)
- Any MCS extending g_content + f_step must contain F(top) since f_step includes `{phi | F phi in M}` (which includes F(top))
- Use `mcs_contains_theorem` if available, or derive from axioms

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - replace axioms with proofs

**Verification**:
- Both axioms replaced with theorems
- `lake build` passes
- 2 fewer axioms in file

---

### Phase 2: Prove Forward F Coherence [NOT STARTED]

**Goal**: Prove that F obligations are witnessed along the Succ chain

**Tasks**:
- [ ] Prove `succ_chain_forward_F_axiom`:
  ```lean
  F phi in succ_chain_fam M0 n -> exists m > n, phi in succ_chain_fam M0 m
  ```

**Approach** (from blocker-analysis.md):
1. If `F phi` is in `succ_chain_fam M0 n`, either:
   - `FF phi` is also in (by TM axiom 4: F phi -> FF phi)
   - Or `FF phi` is not in, so by `bounded_witness` theorem, `phi` appears at `n+1`
2. Use induction on F-nesting depth
3. The `single_step_forcing` theorem provides: `F phi in u AND FF phi not in u AND Succ u v -> phi in v`

**Key theorem to use**: `bounded_witness` from CanonicalTaskRelation.lean

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- Axiom replaced with theorem
- `lake build` passes
- 1 fewer axiom

---

### Phase 3: Prove Backward P Coherence [NOT STARTED]

**Goal**: Prove that P obligations are witnessed along the Succ chain

**Tasks**:
- [ ] Prove `succ_chain_backward_P_axiom`:
  ```lean
  P phi in succ_chain_fam M0 n -> exists m < n, phi in succ_chain_fam M0 m
  ```

**Approach**:
- Symmetric to Phase 2 using backward direction
- Use `bounded_witness` analog for past direction
- Key: if `P phi` is in chain at n, either `PP phi` is in (defer), or `phi` appears at `n-1`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- Axiom replaced with theorem
- `lake build` passes
- All 4 axioms now theorems

---

### Phase 4: Verification and Summary Update [NOT STARTED]

**Goal**: Final verification and documentation update

**Tasks**:
- [ ] Run `lake build` on full codebase
- [ ] Count axioms in SuccChainFMCS.lean (should be 0)
- [ ] Update implementation summary (01_bfmcs-domain-correction-summary.md)
- [ ] Document that discrete completeness path is now axiom-free (except seed consistency)

**Timing**: 0.5 hours

**Files to modify**:
- `specs/028_correct_bfmcs_domain_conflation/summaries/01_bfmcs-domain-correction-summary.md`

**Verification**:
- `lake build` passes
- SuccChainFMCS.lean has 0 axioms (down from 4)
- Summary accurately reflects completion

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| bounded_witness doesn't apply directly | Adapt proof using single_step_forcing instead |
| F-nesting depth argument complex | Use well-founded recursion on formula depth |
| P direction lacks symmetric theorems | Derive from F direction via temporal duality |

## Expected Outcome

After completion:
- **SuccChainFMCS.lean**: 0 axioms (was 4)
- **SuccExistence.lean**: 3 axioms (unchanged, seed consistency)
- **DirectMultiFamilyBFMCS.lean**: 3 sorries (unchanged, S5-blocked, documented)

Discrete completeness path: MCS -> Succ -> CanonicalTask -> TaskFrame Z -> SuccChainFMCS (single family) -> truth lemma -> discrete completeness theorem

Total remaining axioms for discrete path: 3 (seed consistency only, clearly documented)
