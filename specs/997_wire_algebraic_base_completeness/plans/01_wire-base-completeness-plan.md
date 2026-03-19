# Implementation Plan: Task #997

- **Task**: 997 - Wire Algebraic Base Completeness
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: Task 995 (FMCS domain transfer - completed)
- **Research Inputs**: specs/997_wire_algebraic_base_completeness/reports/01_wire-base-completeness.md
- **Artifacts**: plans/01_wire-base-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task completes the algebraic base completeness theorem by wiring the FMCSTransfer infrastructure (from task 995) to fill the 2 sorries in AlgebraicBaseCompleteness.lean. The core challenge is constructing the `FMCSTransfer Int` instance, which requires a dovetailing chain that enumerates all MCSes with proper F/P witness coverage. Once this instance exists, `construct_bfmcs_from_mcs` (line 155) can use `transferredTemporalCoherentFamily` to create a sorry-free BFMCS Int.

### Research Integration

The research report identified:
- Line 104 (`singleFamilyBFMCS`): Blocked and can be deprecated (not needed for completeness)
- Line 155 (`construct_bfmcs_from_mcs`): Critical sorry blocking main theorem at line 247
- Path A recommended: Implement FMCSTransfer Int via dovetailing chain construction
- Task 995 provides sorry-free `transfer_forward_F` and `transfer_backward_P`

## Goals & Non-Goals

**Goals**:
- Create `IntFMCSTransfer.lean` with dovetailing chain enumeration of CanonicalMCS
- Define `FMCSTransfer Int` instance with embed/retract pair
- Fill the sorry at line 155 (`construct_bfmcs_from_mcs`)
- Ensure `algebraic_base_completeness` compiles without sorry
- Achieve clean `lake build` with no new sorries

**Non-Goals**:
- Fill line 104 sorry (singleFamilyBFMCS) - deprecated, not needed
- Implement dense/discrete completeness variants (separate tasks)
- Optimize for computational efficiency (proof construction is primary)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dovetailing chain complexity | High | Medium | Start with bijective enumeration, prove properties incrementally |
| Type class constraints mismatch | Medium | Low | Verify CanonicalMCS vs Int instances early in Phase 1 |
| Surjectivity proof difficulty | Medium | Medium | Use embed_retract_eq formulation from FMCSTransfer structure |
| BFMCS construction from FMCS | Low | Low | Single-family has trivial modal coherence |

## Implementation Phases

### Phase 1: Dovetailing Chain Core [NOT STARTED]

**Goal**: Create the enumeration infrastructure for mapping CanonicalMCS to Int.

**Tasks**:
- [ ] Create file `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean`
- [ ] Import FMCSTransfer.lean, CanonicalFMCS.lean, and necessary Mathlib
- [ ] Define dovetailing chain structure using standard enumeration technique
- [ ] Create `enum_pos : Nat -> CanonicalMCS` for positive integers (0, 1, 2, ...)
- [ ] Create `enum_neg : Nat -> CanonicalMCS` for negative integers (-1, -2, ...)
- [ ] Define combined `int_to_mcs : Int -> CanonicalMCS` mapping
- [ ] Prove `int_to_mcs` is well-defined (every Int maps to valid MCS)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` (create)

**Verification**:
- File compiles without errors
- `int_to_mcs` type-checks as `Int -> CanonicalMCS`

---

### Phase 2: FMCSTransfer Int Instance [NOT STARTED]

**Goal**: Construct the `FMCSTransfer Int` instance satisfying all six conditions.

**Tasks**:
- [ ] Define `intEmbed : CanonicalMCS ->o Int` (monotone embedding)
- [ ] Define `intRetract : Int -> CanonicalMCS` (using int_to_mcs from Phase 1)
- [ ] Prove `intRetract_left_inverse`: retract (embed w) = w
- [ ] Prove `intEmbed_retract_eq`: embed (retract d) = d (surjectivity)
- [ ] Prove `intRetract_lt`: d1 < d2 implies retract d1 < retract d2
- [ ] Prove `intEmbed_lt`: w1 < w2 implies embed w1 < embed w2
- [ ] Bundle into `intFMCSTransfer : FMCSTransfer Int`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` (extend)

**Verification**:
- `intFMCSTransfer` definition compiles
- `transferredTemporalCoherentFamily intFMCSTransfer` type-checks
- No sorries in IntFMCSTransfer.lean

---

### Phase 3: Wire construct_bfmcs_from_mcs [NOT STARTED]

**Goal**: Fill the sorry at line 155 using FMCSTransfer infrastructure.

**Tasks**:
- [ ] Add import for IntFMCSTransfer in AlgebraicBaseCompleteness.lean
- [ ] Use `transferredTemporalCoherentFamily intFMCSTransfer` to get FMCS Int
- [ ] Construct single-family BFMCS Int from the transferred FMCS
- [ ] Prove temporal coherence inherits from FMCSTransfer
- [ ] Identify the time `t : Int` where M appears (via embedding)
- [ ] Complete the return tuple with all required proofs
- [ ] Mark line 104 sorry as deprecated with comment

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`

**Verification**:
- `construct_bfmcs_from_mcs` compiles without sorry
- `algebraic_base_completeness` compiles without sorry
- Running `lake build` shows no errors in AlgebraicBaseCompleteness.lean

---

### Phase 4: Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification and documentation updates.

**Tasks**:
- [ ] Run full `lake build` and verify no new sorries introduced
- [ ] Run `#check algebraic_base_completeness` to confirm theorem exists
- [ ] Update module docstring in AlgebraicBaseCompleteness.lean
- [ ] Add references to IntFMCSTransfer.lean in relevant documentation
- [ ] Verify axiom status with `#print axioms algebraic_base_completeness`
- [ ] Clean up any temporary comments or debug code

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` (docstring)
- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` (documentation)

**Verification**:
- `lake build` succeeds with exit code 0
- No new axioms beyond standard Lean axioms
- Docstrings accurately describe the completeness proof structure

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] `#check algebraic_base_completeness` shows correct type
- [ ] `#print axioms algebraic_base_completeness` shows only standard axioms
- [ ] No `sorry` appears in AlgebraicBaseCompleteness.lean output
- [ ] IntFMCSTransfer.lean has no sorries

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` (new file)
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` (modified)
- `specs/997_wire_algebraic_base_completeness/summaries/01_wire-base-completeness-summary.md` (on completion)

## Rollback/Contingency

If the dovetailing chain proves too complex:
1. Leave `construct_bfmcs_from_mcs` with a single well-documented sorry
2. Add comment explaining the mathematical content is correct
3. Create follow-up task for the chain construction specifically
4. The completeness theorem structure remains valid modulo this sorry

Alternative approach if FMCSTransfer Int cannot be satisfied:
1. Use a weaker validity predicate that only requires Preorder D
2. Prove completeness for this weaker validity
3. Show `valid phi -> valid_preorder phi` separately
