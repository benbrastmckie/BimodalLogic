# Implementation Plan: Succ-Chain FMCS and TaskFrame Int

- **Task**: 14 - succ_chain_fmcs_and_taskframe_int
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: Task 10 (Succ relation), Task 11 (CanonicalTask), Task 12 (Succ existence)
- **Research Inputs**: reports/01_succ-fmcs-research.md
- **Artifacts**: plans/01_succ-fmcs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Construct a time-indexed FMCS family over Int from Succ-chains by building split forward/backward Nat-indexed chains using `Classical.choose` with the `successor_exists` and `predecessor_exists` theorems from Task 12. The combined Int-indexed family satisfies FMCS coherence (forward_G, backward_H, forward_F, backward_P). Instantiate `DiscreteCanonicalTaskFrame` using `CanonicalTask` as the task relation, leveraging the nullity_identity, forward_comp, and converse properties proven in Task 11. Finally, construct a WorldHistory that respects the task relation via Succ-chain propagation.

### Research Integration

Key findings from research report:
- **Chain construction**: Use split forward/backward Nat chains to avoid Int recursion issues
- **Coherence**: forward_G/backward_H from Succ g_content propagation; forward_F/backward_P from bounded_witness theorem
- **TaskFrame**: All three axioms (nullity_identity, forward_comp, converse) already proven in Task 11
- **WorldHistory**: Chain structure directly gives CanonicalTask relationship for s <= t

## Goals & Non-Goals

**Goals**:
- Define `forward_chain` and `backward_chain` for Nat-indexed chain construction
- Combine into `succ_chain_fam : Int -> Set Formula`
- Prove all four FMCS coherence properties
- Instantiate `CanonicalTaskTaskFrame : TaskFrame Int` using CanonicalTask
- Construct `succ_chain_history : WorldHistory` with respects_task proven
- All proofs sorry-free with `lake build` passing

**Non-Goals**:
- Replacing existing `DiscreteCanonicalTaskFrame` (this provides a stronger alternative)
- Computational evaluation of chains (noncomputable by design)
- Finite/decidable chain enumeration

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Int recursion issues | H | L | Use split Nat-indexed chains as recommended |
| forward_comp Int adaptation | M | M | Convert via Int.toNat with non-negativity constraints |
| forward_F complexity | M | M | Use bounded_witness theorem from CanonicalTaskRelation |
| MCS propagation proofs | M | L | Follow induction pattern from research report |

## Implementation Phases

### Phase 1: Forward/Backward Chain Construction [COMPLETED]

**Goal**: Define the Nat-indexed forward and backward chains with MCS and Succ/Pred properties.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- [ ] Import dependencies: SuccExistence, CanonicalTaskRelation, CanonicalTimeline
- [ ] Define `forward_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : Nat -> Set Formula`
- [ ] Define `backward_chain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : Nat -> Set Formula`
- [ ] Prove `forward_chain_mcs : SetMaximalConsistent (forward_chain M0 h_mcs0 n)`
- [ ] Prove `backward_chain_mcs : SetMaximalConsistent (backward_chain M0 h_mcs0 n)`
- [ ] Prove `forward_chain_succ : Succ (forward_chain M0 h_mcs0 n) (forward_chain M0 h_mcs0 (n + 1))`
- [ ] Prove `backward_chain_pred : Succ (backward_chain M0 h_mcs0 (n + 1)) (backward_chain M0 h_mcs0 n)`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Create new file

**Verification**:
- `lake build` passes with no errors
- All four theorems (mcs and succ/pred) proven without sorry

---

### Phase 2: Combined FMCS Family [COMPLETED]

**Goal**: Combine forward/backward chains into Int-indexed FMCS and prove basic properties.

**Tasks**:
- [ ] Define `succ_chain_fam (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Int) : Set Formula`
- [ ] Prove `succ_chain_fam_mcs : SetMaximalConsistent (succ_chain_fam M0 h_mcs0 n)` for all Int n
- [ ] Prove `succ_chain_fam_succ : Succ (succ_chain_fam M0 h_mcs0 n) (succ_chain_fam M0 h_mcs0 (n + 1))` for all n
- [ ] Define `SuccChainFMCS : FMCS Int` structure wrapping succ_chain_fam

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add definitions

**Verification**:
- `succ_chain_fam` definition compiles
- MCS property proven for both positive and negative indices
- Succ property connects adjacent indices across Int.ofNat/Int.negSucc boundary

---

### Phase 3: FMCS Coherence Properties [COMPLETED]

**Goal**: Prove the four FMCS coherence properties (forward_G, backward_H, forward_F, backward_P).

**Tasks**:
- [ ] Prove `succ_chain_forward_G`: G(phi) at n implies phi at all m > n
- [ ] Prove `succ_chain_backward_H`: H(phi) at n implies phi at all m < n
- [ ] Prove `succ_chain_forward_F`: F(phi) at n implies exists m > n with phi at m
- [ ] Prove `succ_chain_backward_P`: P(phi) at n implies exists m < n with phi at m
- [ ] Package as `SuccChainTemporalCoherent : TemporalCoherentFamily Int` if structure exists

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add coherence proofs

**Verification**:
- All four coherence theorems proven
- Proofs use Succ.g_persistence, Succ_implies_h_content_reverse, and bounded_witness
- No sorry placeholders remain

---

### Phase 4: TaskFrame Instantiation [COMPLETED]

**Goal**: Create TaskFrame using CanonicalTask as the task relation.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean`
- [ ] Import SuccChainFMCS, TaskFrame, CanonicalTaskRelation
- [ ] Prove `CanonicalTask_forward_comp_int_full` for Int with non-negativity constraints if needed
- [ ] Define `CanonicalTaskTaskFrame : TaskFrame Int` with:
  - `WorldState := Set Formula`
  - `task_rel := CanonicalTask`
  - `nullity_identity := CanonicalTask_nullity_identity`
  - `forward_comp := (adapted proof)`
  - `converse := CanonicalTask_converse`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean` - Create new file

**Verification**:
- `CanonicalTaskTaskFrame` type-checks
- All three TaskFrame axioms satisfied
- `lake build` passes

---

### Phase 5: WorldHistory Construction [COMPLETED]

**Goal**: Construct WorldHistory from Succ-chain with respects_task proven.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/SuccChainWorldHistory.lean`
- [ ] Import SuccChainFMCS, SuccChainTaskFrame, WorldHistory
- [ ] Prove `succ_chain_canonical_task`: chain structure gives CanonicalTask for s <= t
- [ ] Define `succ_chain_history : WorldHistory CanonicalTaskTaskFrame` with:
  - `domain := fun _ => True` (full Int domain)
  - `convex` trivially satisfied
  - `states t _ := succ_chain_fam M0 h_mcs0 t`
  - `respects_task` via succ_chain_canonical_task
- [ ] Add documentation comments

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainWorldHistory.lean` - Create new file

**Verification**:
- `succ_chain_history` type-checks
- `respects_task` proof shows CanonicalTask relationship for all s <= t
- All three files `lake build` without errors or sorries

---

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] No `sorry` placeholders in any of the three new files
- [ ] `forward_chain` and `backward_chain` definitions compile
- [ ] `succ_chain_fam_mcs` proven for all Int indices
- [ ] All four coherence properties (forward_G, backward_H, forward_F, backward_P) proven
- [ ] `CanonicalTaskTaskFrame` satisfies all three TaskFrame axioms
- [ ] `succ_chain_history` satisfies `respects_task`
- [ ] Documentation comments present on main definitions

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Chain construction and FMCS coherence
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean` - TaskFrame instantiation
- `Theories/Bimodal/Metalogic/Bundle/SuccChainWorldHistory.lean` - WorldHistory construction
- `specs/014_succ_chain_fmcs_and_taskframe_int/summaries/01_succ-fmcs-summary.md` - Implementation summary

## Rollback/Contingency

If implementation encounters blocking issues:
1. The three new files are independent of existing codebase (additive only)
2. Delete the new files to restore previous state
3. Log blocking issues to errors.json with specific proof obligations that failed
4. Consider using sorry for specific hard proofs with documented justification (as done in Task 12)
