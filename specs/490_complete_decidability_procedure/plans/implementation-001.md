# Implementation Plan: Task #490

- **Task**: 490 - Complete decidability procedure for TM logic
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: Low
- **Dependencies**: Task 607 (completed)
- **Research Inputs**: specs/490_complete_decidability_procedure/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete the decidability procedure for TM bimodal logic in Metalogic_v2. Task 607 has ported the decidability infrastructure from old Metalogic, leaving 4 sorry statements that need proofs. The main work involves proving the completeness theorems (`tableau_complete`, `decide_complete`) by connecting the tableau procedure to the FMP infrastructure, plus proving the technical `expansion_decreases_measure` lemma for termination.

### Research Integration

From research-001.md:
- FMP provides termination bounds via `semanticWorldState_card_bound` (2^closureSize)
- Key sorries: `expansion_decreases_measure`, `tableau_complete`, `decide_complete`, `decide_axiom_valid`
- Completeness proof strategy: FMP contrapositive shows tableau must close for valid formulas
- `fmpBasedFuel` function already defined with correct bound

## Goals & Non-Goals

**Goals**:
- Prove `expansion_decreases_measure` theorem in Saturation.lean
- Prove `tableau_complete` theorem connecting FMP to tableau termination
- Prove `decide_complete` deriving from tableau completeness
- Optionally prove `decide_axiom_valid` for matchAxiom behavior

**Non-Goals**:
- Optimizing proof extraction (current simplified version is acceptable)
- Adding new decidability features beyond the existing infrastructure
- Modifying the tableau expansion algorithm itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Completeness proof complexity | High | Medium | Break into lemmas; accept sorry if truly intractable |
| FMP-tableau connection gap | Medium | Medium | May need intermediate lemmas connecting state space |
| expansion_decreases_measure technical difficulty | Medium | Medium | Use well-known decomposition lemma patterns |
| Proof term extraction limitations | Low | Low | Already handled with incomplete result fallback |

## Implementation Phases

### Phase 1: Analyze Current State and FMP Connection [NOT STARTED]

**Goal**: Understand the exact gaps and what FMP provides that can close them.

**Tasks**:
- [ ] Review the `fmpBasedFuel` and `recommendedFuel` functions in SignedFormula.lean
- [ ] Trace how `closureSize` flows through to tableau bounds
- [ ] Identify what lemmas connect `ExpandedTableau.isValid` to semantic validity
- [ ] Document the proof outline for `tableau_complete`

**Timing**: 1 hour

**Files to examine**:
- `Metalogic_v2/Decidability/SignedFormula.lean` - FMP fuel definitions
- `Metalogic_v2/Decidability/BranchClosure.lean` - Closure reason handling
- `Metalogic_v2/Representation/FiniteModelProperty.lean` - FMP theorems

**Verification**:
- Clear written outline of proof strategy for each sorry

---

### Phase 2: Prove expansion_decreases_measure [NOT STARTED]

**Goal**: Prove the termination measure lemma for tableau expansion.

**Tasks**:
- [ ] Define or locate formula decomposition lemmas
- [ ] Show that expandOnce reduces complexity of unexpanded formulas
- [ ] Handle both `.extended` and `.split` cases in the theorem
- [ ] Complete the proof of `expansion_decreases_measure`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` - Line 231

**Verification**:
- `lake build Bimodal.Metalogic_v2.Decidability.Saturation` compiles without sorry warnings
- `lean_diagnostic_messages` shows no errors on Saturation.lean

---

### Phase 3: Prove tableau_complete [NOT STARTED]

**Goal**: Prove the main completeness theorem for tableau method.

**Tasks**:
- [ ] Establish connection between semantic validity and tableau closure
- [ ] Show that FMP-based fuel is sufficient for termination
- [ ] Prove that valid formulas cause all tableau branches to close
- [ ] Connect `buildTableau` result to validity via FMP bounds

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - Line 93

**Key insight from research**:
```
Valid formula phi means neg phi is unsatisfiable
By FMP contrapositive: unsatisfiable means no finite model
Tableau starting with F(phi) explores finite state space (bounded by 2^|closure|)
Therefore all branches must eventually close
```

**Verification**:
- `lean_goal` at line 108 shows proof is complete
- No sorry warnings for `tableau_complete`

---

### Phase 4: Prove decide_complete [NOT STARTED]

**Goal**: Derive decision procedure completeness from tableau completeness.

**Tasks**:
- [ ] Use `tableau_complete` to establish fuel existence
- [ ] Connect closed tableau to proof extraction
- [ ] Handle the case where proof extraction succeeds vs falls back
- [ ] Complete the `decide_complete` proof

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - Line 118

**Verification**:
- `lean_diagnostic_messages` shows no errors for `decide_complete`
- Proof compiles successfully

---

### Phase 5: Address decide_axiom_valid (Optional) [NOT STARTED]

**Goal**: Prove that axiom instances are correctly decided.

**Tasks**:
- [ ] Review `matchAxiom` behavior in ProofSearch.lean
- [ ] Verify that `tryAxiomProof` returns proofs for axiom instances
- [ ] Connect to `decide` function's fast path handling
- [ ] Complete `decide_axiom_valid` proof or document why it remains sorry

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - Line 227

**Verification**:
- Either proof complete or documented rationale for leaving sorry

---

### Phase 6: Final Verification and Cleanup [NOT STARTED]

**Goal**: Ensure all proofs compile and documentation is complete.

**Tasks**:
- [ ] Run full `lake build` on Decidability module
- [ ] Verify no sorry warnings in Correctness.lean and Saturation.lean
- [ ] Update module documentation if proof strategies changed
- [ ] Run any existing tests for decidability

**Timing**: 0.5 hours

**Files to verify**:
- `Theories/Bimodal/Metalogic_v2/Decidability.lean` - Module hub
- All files in `Theories/Bimodal/Metalogic_v2/Decidability/`

**Verification**:
- `lake build Bimodal.Metalogic_v2.Decidability` succeeds
- `lean_diagnostic_messages` on Correctness.lean shows at most the optional `decide_axiom_valid` sorry

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic_v2.Decidability` compiles without errors
- [ ] All mandatory sorries removed (expansion_decreases_measure, tableau_complete, decide_complete)
- [ ] `lean_diagnostic_messages` confirms no unexpected warnings
- [ ] Optional: Create test file with example formula decisions

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` - completed expansion_decreases_measure
- `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - completed completeness theorems
- `specs/490_complete_decidability_procedure/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If completeness proofs prove intractable:
1. Document the gap clearly in module comments
2. Consider weaker alternative formulations (e.g., assuming FMP fuel is sufficient)
3. Mark sorries with detailed explanations of what remains
4. Keep soundness proofs intact (these are already complete)
5. File follow-up task for completeness proof refinement if needed
