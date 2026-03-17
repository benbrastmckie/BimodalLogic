# Implementation Plan: BFMCS Construction for Int (v2 - Conditional Approach)

- **Task**: 986 - bfmcs_construction_for_int
- **Status**: [PLANNED]
- **Effort**: 2-3 hours
- **Dependencies**: Task 985 (completed)
- **Research Inputs**: research-001.md through research-004.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revised Approach**: Based on research-004.md (W vs D semantic architecture), the F/P coherence sorries in IntBFMCS.lean are MATHEMATICALLY UNFILLABLE due to the Countability Obstruction Theorem. This revised plan accepts this mathematical reality and provides a CONDITIONAL algebraic representation theorem.

**Key Insight**: The semantics has two components: W (WorldState = MCSes) and D (Duration = Int). A single history `h: D -> W` cannot index all F/P witnesses because D is countable but W is uncountable. This is a fundamental mathematical limitation, not a proof gap.

**Strategy**: Convert the sorries to explicit hypotheses, document the mathematical obstruction clearly, and provide conditional theorems that are usable when the hypotheses hold (e.g., for restricted formula classes or imported countable MCS subsets).

## Goals & Non-Goals

**Goals**:
- Convert sorries to explicit documented hypotheses
- Provide `algebraic_representation_conditional` theorem
- Document why this approach is mathematically necessary
- Ensure the algebraic path is clearly marked as CONDITIONAL

**Non-Goals**:
- Achieving sorry-free F/P coherence (proven impossible)
- Modifying D-from-syntax path (separate task)
- Infrastructure refactoring to D=CanonicalMCS

## Research Summary

### The Countability Obstruction (research-003.md, research-004.md)

**Theorem**: For any function `h: Int -> CanonicalMCS`, there exist formulas phi and times t such that:
- `F(phi) in h(t)`
- For all `s > t`: the witness MCS for F(phi) is NOT in Range(h)

**Proof**: |CanonicalMCS| = continuum; |Range(h)| = countable. By pigeonhole, most witnesses are outside any countable chain.

### The W vs D Architecture (research-004.md)

| Component | Type | Role |
|-----------|------|------|
| W (WorldState) | CanonicalMCS | Semantic domain (uncountable) |
| D (Duration) | Int | Temporal backbone (countable) |
| History | D -> W | Maps times to states |
| F/P operators | Quantify over D | Evaluated at W |

### Why Accept Conditional Completeness

The algebraic path (D = Int) is SECONDARY to the D-from-syntax path. Accepting conditional theorems:
1. Matches standard practice in modal logic (canonical models use ALL MCSes)
2. Provides useful partial results for restricted cases
3. Documents a genuine mathematical limitation
4. Does not block publication (primary path is D-from-syntax)

## Implementation Phases

### Phase 1: Document Countability Obstruction [NOT STARTED]

- **Dependencies**: None
- **Goal**: Add clear documentation to IntBFMCS.lean explaining why the sorries are unfillable

**Tasks**:
- [ ] Add module-level docstring explaining the W vs D architecture
- [ ] Add theorem `countability_obstruction` (statement only, with proof sketch in docstring)
- [ ] Add docstrings to `intFMCS_forward_F` and `intFMCS_backward_P` explaining unfillability

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`

---

### Phase 2: Convert Sorries to Hypotheses [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Replace sorries with explicit hypotheses/axioms for conditional use

**Tasks**:
- [ ] Define `hypothesis intFMCS_forward_F_hyp : ∀ t phi, F(phi) ∈ intChainMCS t → ∃ s > t, phi ∈ intChainMCS s`
- [ ] Define `hypothesis intFMCS_backward_P_hyp : ∀ t phi, P(phi) ∈ intChainMCS t → ∃ s < t, phi ∈ intChainMCS s`
- [ ] Replace sorry with reference to hypothesis
- [ ] Add `IntFMCS_FP_Coherence` structure bundling the two hypotheses

**Alternative**: Use `axiom` instead of `hypothesis` if the hypotheses are meant to be assumed globally.

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`

---

### Phase 3: Wire Conditional Representation [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Connect IntBFMCS to DiscreteInstantiation with explicit hypothesis parameter

**Tasks**:
- [ ] Define `construct_bfmcs_int_conditional : IntFMCS_FP_Coherence → ...` that uses the hypothesis bundle
- [ ] Modify or create `discrete_algebraic_representation_conditional` that takes the FP coherence hypothesis
- [ ] Add import of IntBFMCS to DiscreteInstantiation if not present

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean`

---

### Phase 4: Verification and Summary [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Full build verification and summary creation

**Tasks**:
- [ ] Run `lake build` for full project
- [ ] Verify no new sorries (only documented hypotheses/axioms)
- [ ] Create implementation summary documenting the conditional approach
- [ ] Update ROAD_MAP.md Dead Ends section with Int-indexed F/P coherence limitation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (cleanup)
- `specs/986_bfmcs_construction_for_int/summaries/implementation-summary-{DATE}.md` (new)
- `ROAD_MAP.md` (Dead Ends update)

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] No UNINTENTIONAL sorries (only documented hypotheses/axioms)
- [ ] Hypotheses clearly documented with unfillability explanation
- [ ] Conditional theorem has correct type signature

### Documentation Requirements
- [ ] Module docstring explains countability obstruction
- [ ] Hypothesis docstrings explain why unfillable
- [ ] ROAD_MAP.md Dead Ends updated

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (modified - documented hypotheses)
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` (modified - conditional wiring)
- `specs/986_bfmcs_construction_for_int/summaries/implementation-summary-{DATE}.md` (new)
- `ROAD_MAP.md` (Dead Ends section updated)

## Rollback/Contingency

- If conditional approach is rejected:
  - Option 2: Refactor to D=CanonicalMCS (6-8 hours, changes algebraic infrastructure)
  - Option 3: Abandon algebraic path entirely, focus on D-from-syntax

## Preserved Progress

From implementation-001.md:
- Phase 1 [COMPLETED]: Chain construction core (successorMCS, predecessorMCS, intChainMCS)
- Phase 2 [COMPLETED]: G/H coherence (intChain_forward_G, intChain_backward_H)
- IntBFMCS.lean with 614 lines of working infrastructure

## Superseded Phases

From implementation-001.md:
- Phase 3 [BLOCKED→SUPERSEDED]: F/P via dovetailing (mathematically impossible)
- Phase 4 [NOT STARTED→SUPERSEDED]: BFMCS wiring (replaced by conditional approach)
- Phase 5 [NOT STARTED→SUPERSEDED]: Verification (incorporated into new Phase 4)
