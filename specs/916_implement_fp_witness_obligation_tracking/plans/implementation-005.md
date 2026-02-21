# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [NOT STARTED]
- **Effort**: 12 hours (investigative + contingent)
- **Dependencies**: None
- **Research Inputs**: specs/916_implement_fp_witness_obligation_tracking/reports/research-007.md (team research - proof technique)
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan supersedes v004, which was BLOCKED because the generalized witness seed consistency lemma is mathematically false. Research-007 identifies derivation surgery as the correct proof path: a purely syntactic argument showing that F-formulas in the extended seed cannot generate G(neg(chi)) contradictions. The plan focuses on proving the F-preserving seed consistency conjecture via structural analysis of derivation trees, then implementing the modified chain construction if successful.

### Research Integration

Key findings from research-007.md integrated into this plan:

1. **v004 blocked**: Generalized witness seed consistency lemma is mathematically false (line 611 of research-004, confirmed by research-007)
2. **Semantic approach circular**: Must be abandoned entirely (research-007 Section 4.2)
3. **G-lifting fails for F-formulas**: Fundamental structural asymmetry, not technical (research-007 Section 4.1)
4. **Derivation surgery is correct path**: Purely syntactic, no circularity (research-007 Section 5)
5. **Routes 1 and 3 blocked**: G(neg(chi)) cannot come from seed hypotheses or theorems (research-007 Section 5.1)
6. **Route 2 requires temp_a analysis**: The only remaining gap (research-007 Section 5.1)
7. **Confidence**: 65% for F-preserving seed conjecture (up from 55%)

## Goals & Non-Goals

**Goals**:
- Prove or refute the F-preserving seed consistency conjecture via derivation surgery
- If proven: implement F-preserving chain seed and close forward_F and backward_P sorries
- If refuted: document specific counterexample and accept sorry debt with full analysis
- Establish reusable derivation-theoretic lemmas for TM logic

**Non-Goals**:
- Omega^2 directed limit construction (blocked by v004 Phase 1 failure)
- Semantic model construction (circular per research-007)
- G-lifting of F-formulas (fundamentally impossible)
- Constructive Lindenbaum alternatives (boneyard approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| temp_a generates problematic G-formulas | HIGH | MEDIUM | Phase 2 analyzes temp_a structure explicitly |
| Step 12 gap in derivation surgery not closable | HIGH | MEDIUM | Phase 3 uses structural induction; if blocked, document precisely |
| 65% conjecture confidence means 35% failure chance | MEDIUM | MEDIUM | Accept sorry debt with full documentation if investigation fails |
| Complex derivation tree analysis exhausts context | MEDIUM | MEDIUM | Phases sized at 2-4h; progress tracked in plan |

## Sorry Characterization

### Pre-existing Sorries
- `buildDovetailingChainFamily_forward_F` at line ~919 (forward_F sorry)
- `buildDovetailingChainFamily_backward_P` at line ~926 (backward_P sorry)

### Expected Resolution
- Phases 1-3 investigate the mathematical conjecture
- Phase 4-5 implement the proof if conjecture holds
- Phase 6 closes the sorries using the proven consistency lemma

### New Sorries
- None expected if investigation succeeds
- If investigation fails: existing sorries remain with documentation

### Remaining Debt
After this implementation:
- If conjecture proven: 0 sorries in forward_F and backward_P
- If conjecture false: sorries remain, documented with counterexample

## Axiom Characterization

### Pre-existing Axioms
- No axioms in DovetailingChain.lean scope

### Expected Resolution
- No axioms needed for derivation surgery approach
- All proofs use structural arguments on Hilbert derivations

### New Axioms
- None. NEVER introduce axioms. If proof requires gap, use sorry with remediation timeline.

### Remaining Debt
- No axiom debt from this task

## Implementation Phases

### Phase 1: Prove Base Structural Facts [NOT STARTED]

- **Dependencies**: None
- **Goal**: Establish the foundational derivation-theoretic lemmas that block Routes 1 and 3

**Tasks**:
- [ ] Prove `GContent_derives_neg_implies_G_neg_mem`:
  - Statement: If `GContent(M) derives neg(alpha)`, then `G(neg(alpha)) in M`
  - Proof approach: Use G-lifting (`generalized_temporal_k`). Hypotheses are G(chi) for chi in GContent. G-lift derivation to get derivation from {G(chi)}. By MCS closure, G(neg(alpha)) in M.
  - This is valid because G-lifting works for GContent (all hypotheses have G-wrapper by definition)
- [ ] Prove `FContent_blocks_GContent_derives_neg`:
  - Statement: If `F(alpha) in M`, then `GContent(M) does not derive neg(alpha)`
  - Proof: Contrapositive. If GContent(M) derives neg(alpha), then G(neg(alpha)) in M by previous lemma. But F(alpha) = neg(G(neg(alpha))) in M contradicts MCS consistency.
- [ ] Prove `G_neg_theorem_implies_F_unsatisfiable`:
  - Statement: If `G(neg(alpha))` is a theorem (derives from empty context), then `F(alpha)` is unsatisfiable
  - Proof: By soundness, G(neg(alpha)) holds at all times in all models. So neg(alpha) holds at all future times. So F(alpha) = exists future time with alpha is false everywhere.
- [ ] Prove `F_in_MCS_implies_G_neg_not_theorem`:
  - Statement: If `F(alpha) in M` for some MCS M, then `G(neg(alpha))` is not a theorem
  - Proof: M is consistent (MCS). By soundness, M is satisfiable. So F(alpha) is satisfiable. By previous lemma contrapositive, G(neg(alpha)) is not a theorem.
- [ ] Verify existing lemma `forward_temporal_witness_seed_consistent` still holds

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add derivation-theoretic lemmas

**Verification**:
- `lake build` succeeds
- All lemmas type-check without sorry
- `#print axioms` shows only standard axioms for each lemma

---

### Phase 2: Prove FContent Independence (temp_a Analysis) [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Prove that F-formulas in FContent(M) cannot combine with GContent(M) to derive G(neg(alpha)) for any F(alpha) in M

**Tasks**:
- [ ] Analyze temp_a axiom structure:
  - temp_a: `phi -> G(P(phi))`
  - When phi = F(alpha) = neg(G(neg(alpha))), we get: `neg(G(neg(alpha))) -> G(P(neg(G(neg(alpha)))))`
  - The produced G-formula is `G(P(neg(G(neg(alpha)))))` - very specific nested structure
- [ ] Prove `temp_a_G_output_structure`:
  - Statement: Any G-formula derivable from {F(alpha_1), ..., F(alpha_n)} alone via temp_a has the form G(P(...)) where the argument contains an F-subformula
  - This prevents these G-formulas from being G(neg(chi)) for arbitrary chi
- [ ] Prove `GContent_FContent_no_new_G_neg`:
  - Statement: For any F(alpha) in FContent(M), the set GContent(M) union FContent(M) does not derive G(neg(alpha))
  - Key insight: G(neg(alpha)) must come from either:
    - (a) Hypotheses: blocked - neither GContent nor FContent contains G(neg(alpha)) when F(alpha) in M
    - (b) Theorems: blocked - F(alpha) in MCS means G(neg(alpha)) not a theorem (Phase 1)
    - (c) temp_a + derivation: produces G(P(...)) not G(neg(alpha))
    - (d) temp_k_dist: requires G-hypotheses as inputs, cycles back to (a)
- [ ] Prove `FContent_adds_no_G_derivation_power`:
  - Statement: If GContent(M) union FContent(M) derives G(psi), then GContent(M) alone derives G(psi)
  - Proof: Structural induction on derivation. F-formulas are negative (neg(G(...))), cannot produce new G-formulas except via temp_a which produces G(P(...))

**Timing**: 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add FContent independence lemmas

**Verification**:
- `lake build` succeeds
- All lemmas type-check without sorry
- Key lemma `FContent_adds_no_G_derivation_power` proven

---

### Phase 3: Assemble F-Preserving Seed Consistency Proof [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Prove the conjecture: {psi} union GContent(M) union FContent(M) is consistent when F(psi) in M

**Tasks**:
- [ ] Prove `FPreservingSeed_consistent`:
  - Statement: If M is MCS and F(psi) in M, then `{psi} union GContent(M) union FContent(M)` is SetConsistent
  - Proof approach (derivation surgery):
    1. Assume inconsistent: some finite L subset derives bot
    2. Partition L into L_G subset GContent(M), L_F subset FContent(M), and possibly {psi}
    3. Apply deduction theorem to extract F-formulas: L_G derives F(alpha_1) -> ... -> F(alpha_m) -> neg(psi)
    4. By Phase 1: GContent(M) does not derive neg(psi) when F(psi) in M
    5. So the derivation must use F-formulas substantively
    6. By Phase 2: F-formulas add no G-derivation power
    7. The only way F-formulas contribute is modus ponens with deducted implications
    8. But implications F(alpha_i) -> ... must be derivable from GContent alone
    9. G-lift the implication derivation
    10. Derive contradiction with F(psi) in M
- [ ] Handle the step 12 gap (research-007 Section 5.2):
  - If derivation uses F(alpha_i) via modus ponens, trace back derivation tree
  - Show any path to bot through F-formulas collapses to GContent-only derivation
  - Alternatively: show F-formulas only contribute via trivial tautologies
- [ ] If proof succeeds: document the complete derivation surgery argument
- [ ] If proof blocked: document precisely where and why, identify counterexample if exists

**Timing**: 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - prove consistency lemma

**Verification**:
- `lake build` succeeds
- `FPreservingSeed_consistent` type-checks without sorry (or documents exact blocker)
- Proof uses only structural derivation arguments (no semantic appeal)

---

### Phase 4: Implement F-Preserving Chain Seed [NOT STARTED]

- **Dependencies**: Phase 3 (conjecture must be proven)
- **Goal**: Define the F-preserving seed and prove basic properties

**Precondition**: Phase 3 must have succeeded. If conjecture was blocked/refuted, skip to Phase 6 (documentation).

**Tasks**:
- [ ] Define `FPreservingSeed`:
  ```lean
  def FPreservingSeed (M : {S // SetMaximalConsistent S}) (psi : Formula) : Set Formula :=
    {psi} ∪ GContent(M.val) ∪ FContent(M.val)
  ```
- [ ] Define `FContent`:
  ```lean
  def FContent (S : Set Formula) : Set Formula :=
    {phi | ∃ chi, phi = ¬(G(¬chi)) ∧ phi ∈ S}
  ```
- [ ] Prove `FPreservingSeed_extends_GContent`:
  - Statement: GContent(M) subset FPreservingSeed M psi
- [ ] Prove `FPreservingSeed_extends_FContent`:
  - Statement: FContent(M) subset FPreservingSeed M psi
- [ ] Prove `FPreservingSeed_contains_witness`:
  - Statement: psi in FPreservingSeed M psi
- [ ] Modify `dovetailForwardChainMCS` to use `FPreservingSeed`:
  - At witness step: use FPreservingSeed instead of {psi} union GContent
  - Apply FPreservingSeed_consistent from Phase 3
  - Lindenbaum extension remains unchanged

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - add FContent definition
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add FPreservingSeed, modify chain

**Verification**:
- `lake build` succeeds
- FPreservingSeed definitions type-check
- Chain construction uses new seed

---

### Phase 5: Prove forward_F and backward_P [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Close the two remaining sorries using F-preserving seed construction

**Precondition**: Phase 4 must have succeeded.

**Tasks**:
- [ ] Prove `FPreservingSeed_F_persists`:
  - Statement: If F(chi) in M, then F(chi) in Lindenbaum(FPreservingSeed M psi)
  - Proof: F(chi) in FContent(M) subset FPreservingSeed. Lindenbaum preserves seed formulas.
- [ ] Prove chain F-persistence across steps:
  - Statement: If F(chi) in chain(n), then F(chi) in chain(n+1) for all n < witnessing step
  - Proof: FContent propagates through seeds. Lindenbaum cannot add G(neg(chi)) because it would contradict FPreservingSeed consistency.
- [ ] Prove `forward_F`:
  - Statement: If F(psi) in chain(0), then exists n, psi in chain(n)
  - Proof: F(psi) persists until step encodeFormula(psi). At that step, witness fires, psi in seed, psi in chain.
- [ ] Symmetric construction for backward direction:
  - Define HPreservingSeed using HContent and PContent
  - Prove HPreservingSeed_consistent
  - Modify backward chain construction
- [ ] Prove `backward_P`:
  - Statement: If P(psi) in chain(0), then exists n, psi in chain(n)
  - Proof: Symmetric to forward_F using HContent/PContent
- [ ] Replace sorries in `buildDovetailingChainFamily_forward_F` and `buildDovetailingChainFamily_backward_P`

**Timing**: 5-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - prove forward_F, backward_P

**Verification**:
- `lake build` succeeds
- forward_F and backward_P sorries eliminated
- `#print axioms buildDovetailingChainFamily_forward_F` shows only standard axioms
- `#print axioms buildDovetailingChainFamily_backward_P` shows only standard axioms

---

### Phase 6: Integration and Documentation [NOT STARTED]

- **Dependencies**: Phase 5 (success) OR Phase 3 (failure)
- **Goal**: Verify integration or document sorry debt

**If Phases 3-5 succeeded**:
- [ ] Verify cross-sign propagation lemmas unchanged
- [ ] Verify `dovetailFamily_theorem` compiles
- [ ] Run full `lake build` for regression check
- [ ] Create implementation summary documenting:
  - Derivation surgery approach
  - Why G-lifting fails but derivation surgery works
  - The structural lemmas added
  - How F-preserving seed resolves persistence

**If Phase 3 failed**:
- [ ] Document exact failure point in derivation surgery
- [ ] If counterexample found: document it precisely
- [ ] If blocked without counterexample: document gap
- [ ] Update task status to [BLOCKED] or accept sorry debt
- [ ] Create implementation summary documenting:
  - What was attempted and why it failed
  - Mathematical obstruction details
  - Confidence assessment for future resolution

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - verification
- `specs/916_implement_fp_witness_obligation_tracking/summaries/implementation-summary-{DATE}.md` - create summary

**Verification**:
- Full `lake build` succeeds
- Summary document created
- Task status updated appropriately

---

## Testing & Validation

- [ ] `lake build` succeeds with zero new sorries (if conjecture proven)
- [ ] `#print axioms buildDovetailingChainFamily_forward_F` shows only standard axioms
- [ ] `#print axioms buildDovetailingChainFamily_backward_P` shows only standard axioms
- [ ] `#print axioms FPreservingSeed_consistent` shows only standard axioms
- [ ] Cross-sign propagation lemmas unchanged (forward_G, backward_H)
- [ ] `dovetailFamily_theorem` compiles without modification
- [ ] Repository sorry count: Theories/ sorries should decrease by 2 (if successful)

## Artifacts & Outputs

- `plans/implementation-005.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` (FContent definition)
- Final: `summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If derivation surgery approach fails:
1. Preserve all work in git
2. Document the specific failure point in summary
3. Accept sorry debt with full mathematical analysis
4. sorries in forward_F and backward_P remain as technical debt
5. Do not delete Phase 1-2 lemmas - they are useful structural facts about TM derivations

If conjecture proven but implementation fails:
1. Keep consistency proof
2. Mark task [PARTIAL] with note on implementation gap
3. Simpler chain modification may be possible with proven conjecture

If context exhaustion occurs mid-phase:
1. Write handoff per standard protocol
2. Successor reads handoff and continues from checkpoint
3. Progress tracked in phase Progress subsection

## Reuse of Existing Lemmas

The following lemmas from v003 Phases 1-2 and v004 remain valid:

| Existing Lemma | Status | Reuse |
|----------------|--------|-------|
| `forward_temporal_witness_seed_consistent` | Valid | Weaker version of our target |
| `past_temporal_witness_seed_consistent` | Valid | Weaker version for backward |
| `formulaEncodable` | Valid | Used for witness enumeration |
| `decodeFormula_encodeFormula` | Valid | Used for coverage argument |
| `generalized_temporal_k` | Valid | G-lifting for GContent hypotheses |
| All cross-sign G/H proofs | Valid | Unchanged |

## Comparison with Prior Plans

| Plan | Approach | Status | Reason |
|------|----------|--------|--------|
| v001 | Initial | BLOCKED | Underspecified |
| v002 | Direct proof | BLOCKED | F-persistence not derivable |
| v003 | Flat chain with witness | BLOCKED | F(psi) killed before processing step |
| v004 | Omega^2 directed limit | BLOCKED | Generalized consistency lemma is FALSE |
| v005 | Derivation surgery | Current | Routes 1,3 blocked; Route 2 requires temp_a analysis |

The key insight of v005: instead of trying to make F-formulas persist via construction (v002-v004), prove they cannot cause inconsistency via derivation structure analysis. This is purely syntactic and avoids the circular semantic approach.
