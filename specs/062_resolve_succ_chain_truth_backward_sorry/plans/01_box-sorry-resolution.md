# Implementation Plan: Resolve SuccChainTruth Box Backward Sorry

- **Task**: 62 - Resolve backward Box sorry in succ_chain_truth_lemma (SuccChainTruth.lean:254) and correct misleading documentation
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/062_resolve_succ_chain_truth_backward_sorry/reports/01_sorry-dependency-analysis.md
- **Artifacts**: plans/01_box-sorry-resolution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The `succ_chain_truth_forward` theorem is falsely documented as "sorry-free" when `#print axioms` shows it depends on `sorryAx`. The forward direction structurally requires the backward direction through the Imp case. Additionally, the Box backward case is not provable in the current singleton-Omega architecture because `psi in MCS` does not imply `Box(psi) in MCS` without modal saturation.

The algebraic perspective reveals the solution: the `UltrafilterChain.lean` infrastructure already proves `boxClassFamilies_modal_backward` using modal saturation. The SuccChain approach with singleton Omega cannot prove Box backward, but the BFMCS approach can. Rather than hacking a workaround, we should: (1) correct all misleading documentation, and (2) understand why the two approaches differ and whether the SuccChain construction can be unified with the algebraic BFMCS construction.

### Research Integration

From report 01_sorry-dependency-analysis.md:
- The `lean_verify` MCP tool incorrectly reports sorry-free status (bug)
- Forward Imp case uses `(ih_psi t).mpr` requiring backward IH on sub-formulas
- Box backward is mathematically unprovable for singleton Omega
- Documentation at lines 293-305 is factually incorrect

## Goals & Non-Goals

**Goals**:
- Correct all misleading documentation claiming sorry-free status
- Understand the algebraic perspective on Box backward provability
- Document the structural difference between singleton-Omega and BFMCS approaches
- Either prove Box backward using algebraic insight OR remove it correctly with justification

**Non-Goals**:
- Restrict to Box-free formula fragments (user explicitly rejected this as "cheating")
- Prove forward direction independently without backward IH (user said "probably not what is needed")
- Create hacky workarounds that mask the underlying mathematical issue

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Documentation scattered across many files | M | H | Systematic grep for sorry-free claims |
| Algebraic solution requires major refactoring | H | M | Phase 2 investigates before committing to approach |
| Box backward genuinely unprovable in SuccChain | H | H | Document correctly and use BFMCS path for full completeness |

## Implementation Phases

### Phase 1: Documentation Correction [NOT STARTED]

**Goal**: Fix all misleading comments and documentation about sorry-free status.

**Tasks**:
- [ ] Fix SuccChainTruth.lean lines 293-305 (remove false "sorry-free" claim)
- [ ] Fix SuccChainTruth.lean lines 31-35 (update design documentation)
- [ ] Check and fix ROADMAP.md for any misleading claims
- [ ] Check SuccChainCompleteness.lean lines 33-34 for axiom dependency claims
- [ ] Search for other "sorry-free" claims related to truth lemma
- [ ] Add accurate documentation explaining why Box backward is unprovable in singleton-Omega

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` - Lines 31-35, 293-305
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Lines 33-34
- `ROADMAP.md` - Verify accuracy of sorry claims

**Timing**: 1 hour

**Verification**:
- All modified comments accurately describe sorry status
- `grep -r "sorry-free\|sorryAx" Theories/` shows no misleading claims
- `lake build` succeeds

---

### Phase 2: Algebraic Analysis [NOT STARTED]

**Goal**: Understand why BFMCS modal_backward works but SuccChain Box backward doesn't.

**Tasks**:
- [ ] Study `UltrafilterChain.lean` `boxClassFamilies_modal_backward` proof structure
- [ ] Identify why BFMCS modal saturation enables Box backward
- [ ] Document the key insight: modal saturation provides witnesses for Diamond formulas
- [ ] Analyze whether SuccChain can be viewed as a special case of BFMCS
- [ ] Write analysis section in documentation

**Key insight to investigate**:
The BFMCS construction uses `boxClassFamilies` which includes ALL families agreeing on box-class with M0. When `Diamond(neg phi) in M0`, the `box_theory_witness_exists` lemma provides a witness W' with `neg phi in W'`. This witness family is in the bundle, so modal_backward can derive a contradiction.

The singleton-Omega SuccChain lacks this: there's only ONE family, so no witness families exist.

**Timing**: 1.5 hours

**Verification**:
- Written analysis of BFMCS vs SuccChain modal coherence
- Clear explanation of why singleton Omega is insufficient

---

### Phase 3: Resolution Strategy [NOT STARTED]

**Goal**: Implement the mathematically correct resolution based on Phase 2 analysis.

**Tasks**:
- [ ] If algebraic insight yields proof: implement Box backward using that insight
- [ ] If Box backward is fundamentally unprovable in singleton-Omega:
  - [ ] Document this clearly in SuccChainTruth.lean
  - [ ] Clarify that full completeness uses the BFMCS path (UltrafilterChain)
  - [ ] The sorry remains as a correct placeholder for an unprovable goal
  - [ ] Update ROADMAP.md to reflect the two completeness paths

**Most likely outcome based on research**:
The SuccChain singleton-Omega construction inherently cannot prove Box backward because it lacks modal saturation. The sorry is mathematically correct - the goal IS unprovable in this context. The solution is:
1. Keep the sorry with accurate documentation
2. Ensure the BFMCS path (which IS sorry-free for Box) is properly documented
3. Clarify that SuccChainCompleteness is incomplete for Box formulas, while BFMCS completeness is complete

**Alternative (if algebraic insight yields proof)**:
If the SuccChain families can be extended to include Box-class witnesses (making it a BFMCS), then Box backward becomes provable. This would require:
- Defining `SuccChainBFMCS` as the bundle of all Box-class agreeing SuccChain families
- Using `boxClassFamilies_modal_backward` proof pattern

**Timing**: 1 hour

**Verification**:
- Documentation accurately describes sorry status
- Path to sorry-free completeness is clearly documented
- No misleading claims remain

---

### Phase 4: Verification and Summary [NOT STARTED]

**Goal**: Verify all changes and create implementation summary.

**Tasks**:
- [ ] Run `lake build` to verify no regressions
- [ ] Run `#print axioms succ_chain_truth_forward` to verify honest documentation
- [ ] Search for any remaining misleading documentation
- [ ] Create implementation summary documenting:
  - What was changed
  - Why Box backward is unprovable in singleton-Omega
  - The two paths to completeness (SuccChain partial, BFMCS complete)
- [ ] Git commit with appropriate message

**Timing**: 0.5 hours

**Verification**:
- `lake build` succeeds
- No new sorries introduced
- Documentation is accurate

## Testing & Validation

- [ ] `lake build` succeeds without errors
- [ ] `#print axioms succ_chain_truth_forward` shows `sorryAx` (confirming honest documentation)
- [ ] `grep -r "sorry-free" Theories/Bimodal/Metalogic/` returns no misleading matches
- [ ] ROADMAP.md accurately describes the completeness gap and paths

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` - Corrected documentation
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Updated axiom claims
- `ROADMAP.md` - Verified/corrected
- `specs/062_resolve_succ_chain_truth_backward_sorry/summaries/01_box-sorry-summary.md` - Implementation summary

## Rollback/Contingency

- All changes are documentation corrections; no functional code changes
- If any verification fails, revert to previous state with `git checkout -- path/to/file`
- Backup: The algebraic BFMCS path remains fully functional regardless of SuccChain documentation changes
