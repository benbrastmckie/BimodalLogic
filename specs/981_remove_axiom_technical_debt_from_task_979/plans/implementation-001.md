# Implementation Plan: Task #981

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [IMPLEMENTING]
- **Effort**: 6-8 hours
- **Dependencies**: None (builds on existing codebase)
- **Research Inputs**: specs/981_remove_axiom_technical_debt_from_task_979/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the **constructive method** from tense logic completeness literature (Segerberg/Verbrugge) to eliminate `discrete_Icc_finite_axiom`. The key insight is that standard discrete tense logic proofs construct the immediate successor with a **blocking formula seed** so that covering holds by definition, not by subsequent proof. ProofChecker's current approach uses a plain Lindenbaum seed `{psi} ∪ g_content(M)` without blocking formulas, which makes the covering lemma unprovable.

### Research Integration

The team research (research-002.md) identified:
1. **Root Cause**: Forward witness construction uses plain seed without blocking formulas
2. **Solution**: Define `discreteImmediateSuccSeed` with blocking formulas
3. **Standard Approach**: Segerberg/Verbrugge use `g_content(M) ∪ {neg psi ∨ neg G(psi) | neg G(psi) ∈ M}`
4. **Key Insight**: DF is trivially valid under reflexive semantics - discreteness comes from absence of density insertion, not from DF semantic content

## Goals & Non-Goals

**Goals**:
- Define `discreteImmediateSuccSeed` with blocking formula construction
- Prove consistency of the blocking seed via MCS argument
- Define `discreteImmediateSucc` as Lindenbaum extension of blocking seed
- Prove `CanonicalR M (discreteImmediateSucc M)` (forward witness property)
- Prove covering: no intermediate MCS between M and `discreteImmediateSucc M`
- Instantiate `SuccOrder` from covering (eliminating axiom dependency)
- Delete `discrete_Icc_finite_axiom`
- Build passes with zero sorries in affected files

**Non-Goals**:
- Restructuring StagedExecution.lean beyond minimal integration
- Changing the dense timeline construction
- Proving `LocallyFiniteOrder` directly (derive from `SuccOrder` instead)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Blocking seed consistency proof fails | HIGH | MEDIUM | MCS consistency argument is standard; if stuck, mark [BLOCKED] |
| Covering proof from blocking formulas fails | HIGH | MEDIUM-HIGH | This is the hardest part; document progress, mark [BLOCKED] if stuck |
| Integration with staged construction disrupts other proofs | MEDIUM | LOW | Minimal changes to existing structure; new definitions alongside existing |
| Forward witness property fails | MEDIUM | LOW | Standard Lindenbaum extension argument applies |

## Sorry Characterization

### Pre-existing Sorries
- None in scope. This task addresses axiom debt, not sorry debt.

### Expected Resolution
- N/A (no pre-existing sorries)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in affected files
- `discrete_Icc_finite_axiom` eliminated

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `DiscreteTimeline.lean`: `discrete_Icc_finite_axiom` (interval finiteness)

### Expected Resolution
- Phase 5 eliminates axiom by proving `SuccOrder` from covering
- Phase 6 removes axiom declaration

### New Axioms
- None. NEVER introduce new axioms.

### Remaining Debt
After this implementation:
- 0 axioms expected in `DiscreteTimeline.lean`
- Completeness theorem becomes axiom-free (publication-ready)

## Implementation Phases

### Phase 1: Define Discrete Immediate Successor Seed [COMPLETED]

- **Dependencies:** None
- **Goal:** Define `discreteImmediateSuccSeed` with blocking formulas

**Tasks:**
- [ ] Create new file `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`
- [ ] Import necessary modules (WitnessSeed, CanonicalFrame, TemporalContent, MCSProperties)
- [ ] Define blocking formula set: `{neg psi ∨ neg G(psi) | neg G(psi) ∈ M}`
- [ ] Define `discreteImmediateSuccSeed M := g_content M ∪ blocking_formulas M`
- [ ] Add basic membership lemmas for the seed
- [ ] Verify file compiles with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` - new file

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed` passes
- Definition matches research specification

---

### Phase 2: Prove Blocking Seed Consistency [IN PROGRESS]

- **Dependencies:** Phase 1
- **Goal:** Prove `discreteImmediateSuccSeed M` is consistent for any serial MCS M

**Tasks:**
- [ ] State theorem: `discreteImmediateSuccSeed_consistent`
- [ ] Prove g_content M is consistent (from M being MCS)
- [ ] Prove blocking formulas do not contradict g_content M:
  - Key argument: if `G(delta) ∈ g_content M`, then `G(delta) ∈ M`
  - So `neg G(delta) ∉ M` (by MCS consistency)
  - So the blocking formula for delta is NOT triggered
- [ ] Combine to show full seed is consistent via finite subcollection argument
- [ ] Verify with `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` - add theorem

**Verification**:
- `lake build` passes
- `lean_goal` shows "no goals" at theorem QED
- `grep -n "\bsorry\b" DiscreteSuccSeed.lean` returns empty

---

### Phase 3: Define Discrete Immediate Successor [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Define `discreteImmediateSucc M` as Lindenbaum extension and prove forward witness property

**Tasks:**
- [ ] Define `discreteImmediateSucc M := lindenbaumMCS_set (discreteImmediateSuccSeed M) h_consistent`
- [ ] Prove `discreteImmediateSucc_mcs`: result is MCS
- [ ] Prove `discreteImmediateSucc_extends_seed`: seed formulas are in result
- [ ] Prove `discreteImmediateSucc_canonicalR`: `CanonicalR M (discreteImmediateSucc M)`
  - Follows from `g_content M ⊆ discreteImmediateSuccSeed M ⊆ discreteImmediateSucc M`
- [ ] Verify with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` - add definitions and theorems

**Verification**:
- `lake build` passes
- All proofs complete (no sorries)

---

### Phase 4: Prove Covering Property [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove no MCS exists strictly between M and `discreteImmediateSucc M`

**Tasks:**
- [ ] State covering theorem: for any MCS K with `CanonicalR M K` and `CanonicalR K (discreteImmediateSucc M)`, either `K = M` (at MCS level) or `K = discreteImmediateSucc M`
- [ ] Prove using blocking formulas:
  - Suppose K strictly between M and discreteImmediateSucc M
  - Since `CanonicalR M K`, we have `g_content M ⊆ K`
  - Since `CanonicalR K (discreteImmediateSucc M)` and the successor contains blocking formulas...
  - The blocking formula `neg psi ∨ neg G(psi)` for some `neg G(psi) ∈ M` forces a contradiction
- [ ] Handle the precise contradiction argument (this is the hardest step)
- [ ] If stuck after 2+ hours, mark [BLOCKED] with detailed progress notes
- [ ] Verify with `lake build`

**Timing**: 2-3 hours (highest uncertainty)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` - add covering theorem

**Verification**:
- `lake build` passes
- `lean_goal` shows "no goals" at theorem QED
- `grep -n "\bsorry\b" DiscreteSuccSeed.lean` returns empty

---

### Phase 5: Derive SuccOrder Without Axiom [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Instantiate `SuccOrder` on `DiscreteTimelineQuot` using covering property

**Tasks:**
- [ ] Define `discreteSuccFn` using `discreteImmediateSucc` (lifted to quotient)
- [ ] Prove `le_succ`: `a ≤ succ a`
- [ ] Prove `max_of_succ_le`: `succ a ≤ a → IsMax a`
- [ ] Prove `succ_le_of_lt`: `a < b → succ a ≤ b` (key: uses covering)
- [ ] Instantiate `SuccOrder (DiscreteTimelineQuot root_mcs root_mcs_proof)` WITHOUT using `discrete_Icc_finite_axiom`
- [ ] Verify `LocallyFiniteOrder` can still be derived (from SuccOrder + PredOrder + unboundedness)
- [ ] Verify with `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - replace axiom-based SuccOrder with covering-based

**Verification**:
- `lake build` passes
- SuccOrder instance compiles without `discrete_Icc_finite_axiom`
- All downstream theorems still work

---

### Phase 6: Remove Axiom and Final Verification [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Delete `discrete_Icc_finite_axiom` and verify clean build

**Tasks:**
- [ ] Delete `discrete_Icc_finite_axiom` declaration from `DiscreteTimeline.lean`
- [ ] Delete `discrete_Icc_finite` theorem that wraps the axiom
- [ ] Update `LocallyFiniteOrder` instance if needed (should derive from SuccOrder now)
- [ ] Run full `lake build` to verify no regressions
- [ ] Run `grep -rn "\baxiom\b" Theories/Bimodal/` to verify no new axioms
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/` to verify zero sorries
- [ ] Create implementation summary

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - remove axiom

**Verification**:
- `lake build` passes with no errors
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- `grep -rn "\bsorry\b" Theories/Bimodal/` returns empty (or only pre-existing unrelated sorries)

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty (no axioms)
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] `discreteCanonicalTaskFrame` still compiles and works
- [ ] Downstream completeness proofs still work
- [ ] No regressions in existing functionality

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (new file)
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (modified)
- `specs/981_remove_axiom_technical_debt_from_task_979/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails:
1. Phase 4 (covering proof) is the highest risk - if blocked, document progress and mark task [BLOCKED]
2. New file `DiscreteSuccSeed.lean` can be deleted if approach fails entirely
3. Original `DiscreteTimeline.lean` preserved in git history
4. Axiom remains in place (documented technical debt)

If partial success:
- If covering proof fails but seed definitions work, document as progress for future attempts
- Alternative approach from research: stage-bounding (proven false in task 979)
- Alternative: accept axiom as permanent (not recommended by research)
