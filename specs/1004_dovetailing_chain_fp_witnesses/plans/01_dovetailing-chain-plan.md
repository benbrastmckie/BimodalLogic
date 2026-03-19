# Implementation Plan: Task #1004

- **Task**: 1004 - Dovetailing Chain F/P Witnesses
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: specs/1004_dovetailing_chain_fp_witnesses/reports/01_dovetailing-chain-research.md
- **Artifacts**: plans/01_dovetailing-chain-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The two sorries `intFMCS_forward_F` (line 563) and `intFMCS_backward_P` (line 574) in IntBFMCS.lean cannot be proven with the current basic chain construction. The basic `intChainMCS` uses generic Lindenbaum extensions at each step, which do not guarantee that witnesses from `canonical_forward_F`/`canonical_backward_P` appear in the chain.

The solution is to implement an enriched dovetailing chain construction that enumerates (position, formula) obligation pairs and places witness MCSes at designated positions, ensuring every `F(phi)` at position `t` has a witness `s > t`, and every `P(phi)` at position `t` has a witness `s < t`.

### Research Integration

Key findings from the research report:
- Existing `Dovetailing.lean` provides Cantor pairing infrastructure with `obligationAtStep` and `forall_obligation_eventually_processed`
- Existing `DovetailedBuild.lean` provides patterns for processing obligations with `DovetailedBuildState` and witness placement
- The fix requires replacing the simple `successorMCS`/`predecessorMCS` pattern with specific witness MCSes from `canonical_forward_F`/`canonical_backward_P`

## Goals & Non-Goals

**Goals**:
- Resolve `intFMCS_forward_F` sorry (line 563)
- Resolve `intFMCS_backward_P` sorry (line 574)
- Maintain compatibility with existing chain properties (CanonicalR between adjacent elements)
- Ensure builds without introducing new sorries

**Non-Goals**:
- Modifying the SaturatedChain approach (separate file)
- Changing the FMCSTransfer infrastructure
- Modifying canonical_forward_F/canonical_backward_P (already sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Int-indexed chain position assignment more complex than Nat-indexed | Medium | Medium | Handle positive/negative separately, use absolute position encoding |
| Witness MCS from canonical lemmas may not integrate smoothly with chain | High | Low | Use existing DovetailedBuild patterns; canonical lemmas are already proven |
| Chain properties (G/H propagation) may require re-proving | Medium | Medium | Build incrementally, verify each lemma still type-checks |
| Dovetailing coverage proof for Int may be more complex | Medium | Medium | Factor position into (sign, Nat) pairs for enumeration |

## Implementation Phases

### Phase 1: Define Int-Indexed Obligation Enumeration [NOT STARTED]

**Goal**: Create infrastructure for enumerating (Int position, formula) obligation pairs

**Tasks**:
- [ ] Define `IntObligation` structure with `position : Int` and `formula_encoding : Nat`
- [ ] Define encoding from `Int` to `Nat` (e.g., `Int.toNat` with sign bit)
- [ ] Define `intObligationAtStep : Nat -> IntObligation` using Cantor pairing
- [ ] Prove coverage: for all `(t : Int, k : Nat)`, exists step n with that obligation

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - Add obligation enumeration section

**Verification**:
- [ ] New definitions compile without errors
- [ ] Coverage theorem has no sorry

---

### Phase 2: Define Enriched Chain State [NOT STARTED]

**Goal**: Create state type tracking MCS assignments and pending obligations

**Tasks**:
- [ ] Define `EnrichedChainState` structure:
  - `mcs_at : Int -> Set Formula` (partial function via Option or explicit domain)
  - `is_mcs : forall t in domain, SetMaximalConsistent (mcs_at t)`
  - `next_future_pos : Nat` (next available position for F witnesses, > 0)
  - `next_past_pos : Nat` (next available position for P witnesses, converted to negative)
- [ ] Define initial state with root MCS at position 0
- [ ] Define accessors for MCS at given position

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - Add state definition section

**Verification**:
- [ ] State type compiles
- [ ] Initial state is well-formed

---

### Phase 3: Define Step Function [NOT STARTED]

**Goal**: Implement single-step obligation processing using canonical witnesses

**Tasks**:
- [ ] Define `processForwardObligation` function:
  - Check if F(phi) at position t (decode from obligation)
  - If present and unwitnessed, get witness W from `canonical_forward_F`
  - Assign W to `next_future_pos`, increment counter
- [ ] Define `processBackwardObligation` function (symmetric for P)
- [ ] Define combined `processObligation` that dispatches based on formula type
- [ ] Ensure CanonicalR/CanonicalR_past holds between witness and source

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - Add step function section

**Verification**:
- [ ] Step functions compile
- [ ] No new sorries introduced

---

### Phase 4: Define Enriched Chain Construction [NOT STARTED]

**Goal**: Build the full enriched chain via iteration

**Tasks**:
- [ ] Define `enrichedChainState : Nat -> EnrichedChainState` via iteration
- [ ] Define `enrichedIntChainMCS : Int -> Set Formula` as limit/union
- [ ] Prove each `enrichedIntChainMCS t` is an MCS
- [ ] Prove CanonicalR holds between adjacent positions (reuse existing lemmas)

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - Add chain construction section

**Verification**:
- [ ] Chain construction compiles
- [ ] MCS proof is sorry-free
- [ ] CanonicalR lemma is sorry-free

---

### Phase 5: Prove Forward F and Backward P [NOT STARTED]

**Goal**: Prove the main theorems using enriched chain construction

**Tasks**:
- [ ] Prove `enrichedIntChainMCS_forward_F`:
  - Given F(phi) at position t, obligation (t, encode(phi)) is processed at some step
  - When processed, witness MCS W with phi is assigned at some s > t
  - Therefore phi is in the chain at position s
- [ ] Prove `enrichedIntChainMCS_backward_P` (symmetric argument)
- [ ] Update `intFMCS_forward_F` to use enriched chain
- [ ] Update `intFMCS_backward_P` to use enriched chain

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - Complete the sorry proofs

**Verification**:
- [ ] `intFMCS_forward_F` is sorry-free
- [ ] `intFMCS_backward_P` is sorry-free
- [ ] Full file builds without errors

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Algebraic.IntBFMCS` passes without errors
- [ ] Grep for `sorry` in IntBFMCS.lean returns only expected non-critical sorries (if any)
- [ ] Dependent tasks 997 (algebraic base completeness) and 988 (dense algebraic completeness) can import IntBFMCS without issues

## Artifacts & Outputs

- `specs/1004_dovetailing_chain_fp_witnesses/plans/01_dovetailing-chain-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` with enriched chain construction
- `specs/1004_dovetailing_chain_fp_witnesses/summaries/01_dovetailing-chain-summary.md` (on completion)

## Rollback/Contingency

If the enriched chain approach proves too complex:
1. Preserve original `intChainMCS` (already working for G/H)
2. Consider SaturatedChain.lean alternative (Zorn-based approach)
3. Consider FMCSTransfer pattern with explicit embedding/retraction

The original code remains intact with sorries; implementation adds new definitions without modifying working code until final integration.
