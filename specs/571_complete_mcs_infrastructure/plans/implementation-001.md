# Implementation Plan: Task #571

- **Task**: 571 - Complete MCS Infrastructure
- **Status**: [NOT STARTED]
- **Effort**: 10-12 hours
- **Priority**: High
- **Dependencies**: None (blocking tasks 572, 573)
- **Research Inputs**: specs/571_complete_mcs_infrastructure/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete three MCS (Maximal Consistent Set) infrastructure lemmas in FiniteCanonicalModel.lean that block the semantic embedding work in task 566. The research report identified that these lemmas are part of the **deprecated syntactic approach**, while a proven semantic approach exists. This plan provides a structured path to complete the syntactic approach lemmas, starting with foundational MCS properties in CanonicalModel.lean that the closure-specific lemmas depend on.

### Research Integration

Key findings from research-001.md:
- The semantic approach (`semantic_truth_lemma_v2`, `semantic_weak_completeness`) is already proven
- The syntactic approach has 6+ sorry gaps, with our three targets among them
- Foundation lemmas `mcs_contains_or_neg` and `mcs_modus_ponens` in CanonicalModel.lean are also sorried
- Mathlib's `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem` provides the proof pattern
- Recommended proof order: full MCS properties -> projection -> closure MCS properties

## Goals & Non-Goals

**Goals**:
- Prove `closure_mcs_negation_complete` (line 669)
- Prove `closure_mcs_implies_locally_consistent` (line 1048)
- Prove `worldStateFromClosureMCS_models_iff` (line 1067)
- Prove foundational MCS lemmas as needed (`mcs_contains_or_neg`, `mcs_modus_ponens`)
- Unblock downstream tasks 572 and 573

**Non-Goals**:
- Refactoring to use the semantic approach exclusively (separate task scope)
- Completing all 6+ sorries in the syntactic approach
- Proving `closure_mcs_imp_closed` unless strictly required for our three targets
- Modifying the semantic approach proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deep proof complexity for MCS negation completeness | H | H | Follow Mathlib pattern from `IsMaximal.mem_or_not_mem`, build incrementally |
| Circular dependencies between sorried lemmas | M | M | Map dependency graph, prove in topological order |
| Deduction theorem bridge not straightforward | M | M | Use existing `deduction_theorem` infrastructure, add helper lemmas |
| Time estimate significantly exceeded | H | M | Phase 0 validation can reveal if approach viable, pivot to scoping down |
| Syntactic approach fundamentally harder than semantic | H | L | Research confirmed semantic approach works; worst case, recommend architectural shift |

## Implementation Phases

### Phase 0: Validation and Architecture Review [NOT STARTED]

**Goal**: Confirm the implementation path is viable before committing significant effort.

**Tasks**:
- [ ] Review FiniteCanonicalModel.lean lines 669, 1048, 1067 for exact sorry context
- [ ] Review CanonicalModel.lean lines 294-317 for `mcs_contains_or_neg` and `mcs_modus_ponens`
- [ ] Confirm `deduction_theorem` is available and usable
- [ ] Check if `mcs_projection_is_closure_mcs` (line 3232) can transfer MCS properties
- [ ] Map the exact dependency chain for our three targets
- [ ] Decision point: proceed with full plan or recommend alternative

**Timing**: 1 hour

**Files to examine**:
- `Theories/Bimodal/Metalogic_v2/Completeness/FiniteCanonicalModel.lean` - Target sorries
- `Theories/Bimodal/Metalogic_v2/Completeness/CanonicalModel.lean` - Foundation sorries
- `Theories/Bimodal/Metalogic/DeductionTheorem.lean` - Deduction infrastructure

**Verification**:
- Dependency graph documented
- Go/no-go decision made
- If blocking issues found, report back with alternatives

---

### Phase 1: Foundation - Full MCS Properties [NOT STARTED]

**Goal**: Prove `mcs_contains_or_neg` for full `SetMaximalConsistent`.

**Tasks**:
- [ ] Study Mathlib's `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem` proof
- [ ] Create helper lemma: if `insert phi S` inconsistent, then `S` derives `neg phi`
- [ ] Bridge from `not SetConsistent (insert phi S)` to derivability
- [ ] Connect derivability to membership via maximal consistency
- [ ] Complete `mcs_contains_or_neg` proof
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/CanonicalModel.lean` - lines 294-307

**Verification**:
- `mcs_contains_or_neg` compiles without sorry
- `lean_goal` shows no remaining goals

---

### Phase 2: Foundation - Modus Ponens [NOT STARTED]

**Goal**: Prove `mcs_modus_ponens` for full `SetMaximalConsistent`.

**Tasks**:
- [ ] Use `mcs_contains_or_neg` from Phase 1
- [ ] Prove: if `phi -> psi in S` and `phi in S` but `psi not in S`, then `neg psi in S`
- [ ] Derive contradiction: S contains both derivable `psi` and `neg psi`
- [ ] Complete `mcs_modus_ponens` proof
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/CanonicalModel.lean` - lines 312-317

**Verification**:
- `mcs_modus_ponens` compiles without sorry
- Consistency check: full MCS foundation now available

---

### Phase 3: Closure MCS Negation Complete [NOT STARTED]

**Goal**: Prove `closure_mcs_negation_complete` using projection from full MCS.

**Tasks**:
- [ ] Use `mcs_projection_is_closure_mcs` to obtain closure MCS from full MCS
- [ ] Show that full MCS negation completeness transfers through projection
- [ ] Key insight: if `psi in closure(phi)` and `psi.neg in closure(phi)`, full MCS has one
- [ ] Projection preserves membership for formulas in closure
- [ ] Complete `closure_mcs_negation_complete` proof
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/FiniteCanonicalModel.lean` - line 669

**Verification**:
- `closure_mcs_negation_complete` compiles without sorry
- First of three target lemmas done

---

### Phase 4: Local Consistency [NOT STARTED]

**Goal**: Prove `closure_mcs_implies_locally_consistent`.

**Tasks**:
- [ ] Review `IsLocallyConsistent` definition (lines 759-787)
- [ ] Prove condition 1: Bot is false (bot not in consistent sets)
- [ ] Prove condition 2: Implications respected (uses modus ponens property)
- [ ] Prove condition 3: Box axiom T reflexivity
- [ ] Prove condition 4: All_past reflexivity
- [ ] Prove condition 5: All_future reflexivity
- [ ] May need `closure_mcs_imp_closed` helper (line 696)
- [ ] Complete `closure_mcs_implies_locally_consistent` proof
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/FiniteCanonicalModel.lean` - line 1048

**Verification**:
- `closure_mcs_implies_locally_consistent` compiles without sorry
- Second of three target lemmas done

---

### Phase 5: Models Iff [NOT STARTED]

**Goal**: Prove `worldStateFromClosureMCS_models_iff`.

**Tasks**:
- [ ] Unfold `assignmentFromClosureMCS` definition (lines 1036-1038)
- [ ] Unfold `models` definition (lines 852-853)
- [ ] Simplify `Classical.propDecidable` / `decide` usage
- [ ] Establish equivalence between membership and truth assignment
- [ ] Complete `worldStateFromClosureMCS_models_iff` proof
- [ ] Verify with `lean_diagnostic_messages`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/FiniteCanonicalModel.lean` - line 1067

**Verification**:
- `worldStateFromClosureMCS_models_iff` compiles without sorry
- Third of three target lemmas done

---

### Phase 6: Integration Verification [NOT STARTED]

**Goal**: Verify all changes integrate correctly and document completion.

**Tasks**:
- [ ] Run `lake build` to verify full project compiles
- [ ] Check that downstream dependencies recognize the new proofs
- [ ] Document any helper lemmas created
- [ ] Update task 566 blocked status if appropriate
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to verify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/FiniteCanonicalModel.lean` - full file
- `Theories/Bimodal/Metalogic_v2/Completeness/CanonicalModel.lean` - full file

**Verification**:
- `lake build` succeeds
- No new errors introduced
- Summary document created

## Testing & Validation

- [ ] Each lemma compiles without `sorry` after completion
- [ ] `lean_diagnostic_messages` shows no errors on modified files
- [ ] `lake build` succeeds for full project
- [ ] Downstream sorries (in semantic embedding) recognize the proofs
- [ ] No regressions in existing proven theorems

## Artifacts & Outputs

- `specs/571_complete_mcs_infrastructure/plans/implementation-001.md` (this file)
- `specs/571_complete_mcs_infrastructure/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified files:
  - `Theories/Bimodal/Metalogic_v2/Completeness/CanonicalModel.lean`
  - `Theories/Bimodal/Metalogic_v2/Completeness/FiniteCanonicalModel.lean`

## Rollback/Contingency

If Phase 0 reveals blocking issues:
- Document specific obstacles
- Recommend alternative: verify if semantic approach can replace syntactic approach entirely
- Task 566 may need architectural revision to bypass these lemmas

If implementation stalls mid-phase:
- Git commit completed work
- Mark phase [PARTIAL]
- Next `/implement` resumes from partial point

If time estimate significantly exceeded:
- Complete current phase
- Re-estimate remaining phases
- Consider splitting into sub-tasks if >16 hours total
