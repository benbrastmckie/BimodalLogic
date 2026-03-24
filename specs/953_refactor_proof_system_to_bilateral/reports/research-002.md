# Research Report: Task #953 (research-002) -- Dependency Analysis and Task Ordering for 953/954/955

**Task**: 953 - Refactor proof system to bilateral system
**Date**: 2026-03-06
**Effort**: Research only (dependency analysis)
**Dependencies**: None identified (see findings below)
**Sources/Inputs**: research-001 (task 953), research-001 (task 954), implementation-001 (task 955), TODO.md, codebase import analysis
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report analyzes the dependency relationships between tasks 953 (bilateral proof system), 954 (general duration type), and 955 (D and task_rel from pure syntax) to determine optimal ordering.

**Principal Findings**:

1. **Tasks 953, 954, and 955 operate on largely disjoint code layers.** Task 953 targets the proof system layer (`ProofSystem/`, `Theorems/`, and downstream metalogic). Tasks 954/955 target the canonical construction layer (`Metalogic/Bundle/`, `Metalogic/Representation.lean`). The two layers interact only through MCS infrastructure (`Metalogic/Core/`), which neither task modifies structurally.

2. **Task 953 has NO blocking dependency on 954 or 955.** The bilateral proof system is designed as a parallel system alongside the existing unilateral system (Option A from research-001). It adds new files (`BilateralContext.lean`, `BilateralDerivation.lean`, `BilateralEquivalence.lean`) and does not require changes to `TaskFrame`, `CanonicalConstruction`, or `Representation`. The canonical construction modules do not import `ProofSystem` directly -- they import through MCS infrastructure, which provides an abstraction barrier.

3. **Tasks 954 and 955 have NO blocking dependency on 953.** The representation theorem refactoring (954) and the non-trivial task_rel construction (955) depend on existing `DerivationTree` and `Axiom` types only through MCS membership properties. A bilateral proof system would be an alternative proof system, not a replacement for the unilateral one. The equivalence bridge (Phase 2 of task 953) ensures bilateral results transfer to unilateral and vice versa.

4. **Task 955 has a soft dependency on 954, but 955's plan already accounts for this.** Task 955's implementation plan recommends `D = Int` with a CanonicalR-based task_rel (Approach 7), explicitly noting that the orderIsoIntOfLinearSuccPredArch approach from task 954 is blocked (SuccOrder coverness unprovable). Task 955 can proceed independently of 954.

5. **Task 953 is the recommended starting point.** It is self-contained, has no prerequisites, and its parallel-system approach means it cannot break existing code. Tasks 954/955 are entangled with the blocked task 951 (completeness) and carry higher technical risk (coverness, compositionality proofs).

**Recommendation**: Begin with task 953 first.

---

## 2. Dependency Graph Analysis

### 2.1 Module-Level Dependencies

The codebase has a clear layered architecture:

```
Layer 1: Syntax (Formula, Context, Subformulas)
    |
Layer 2: ProofSystem (Axioms, Derivation)     Semantics (TaskFrame, Truth, Validity)
    |                                              |
Layer 3: Metalogic/Core (MCS, Deduction, Lindenbaum)
    |
Layer 4: Metalogic/Bundle (FMCS, BFMCS, CanonicalFrame, CanonicalConstruction)
    |
Layer 5: Metalogic/Representation + Completeness
```

**Task 953** operates on Layers 2-3 (adds bilateral proof system, bilateral MCS).
**Task 954** operates on Layers 4-5 (generalizes D in canonical construction).
**Task 955** operates on Layers 4-5 (adds non-trivial task_rel).

### 2.2 Import Analysis

The canonical construction files (`CanonicalConstruction.lean`, `CanonicalCompleteness.lean`) do NOT directly import `ProofSystem`. Their import chains:

- `CanonicalConstruction.lean` imports `BFMCS`, `CanonicalFrame`, `TemporalCoherentConstruction`, `TruthLemma`, `MaximalConsistent`, `MCSProperties`, `TaskFrame`, `TaskModel`, `Truth`, `Formula`
- `CanonicalCompleteness.lean` imports `CanonicalFMCS`, `BFMCS`, `ModalSaturation`, `Construction`, `TemporalCoherentConstruction`, `BidirectionalReachable`
- `Representation.lean` imports `BFMCS`, `BFMCSTruth`, `TruthLemma`, `Construction`, `TemporalCoherentConstruction`, `MaximalConsistent`, `MCSProperties`, `DeductionTheorem`, `Truth`, `Validity`, `Formula`, `Context`, `Propositional`

The only transitive path from canonical construction to `ProofSystem` goes through `MaximalConsistent.lean` and `DeductionTheorem.lean`. These MCS modules use `DerivationTree` internally but expose an abstract interface (consistency, maximality, membership properties). A bilateral proof system adds a parallel derivation type; it does not change the MCS interface.

### 2.3 Explicit Dependencies from TODO.md

| Task | Listed Dependencies |
|------|-------------------|
| 953 | None |
| 954 | Task 951 (completeness infrastructure), Task 922 (strategy study) |
| 955 | Task 951 (BFMCS infrastructure), Task 954 (general duration refactor) |

Task 953 has zero listed dependencies. Tasks 954 and 955 both depend on 951, which is currently **BLOCKED** (v7 plan failed: F-preserving seed conjecture proven false).

---

## 3. Risk Comparison

### 3.1 Task 953 Risk Profile

| Risk Factor | Assessment |
|-------------|-----------|
| Technical risk | **Low-Medium**: Well-understood bilateral logic theory; existing signed formula infrastructure provides blueprint |
| Blast radius | **Low**: Parallel system with equivalence bridge; existing code unchanged |
| Blocking dependency | **None**: Independent of 951, 954, 955 |
| Effort estimate | 55-90 hours (from research-001) |
| Primary challenge | Bilateral deduction theorem, bilateral MCS (mitigated by equivalence bridge) |

### 3.2 Task 954 Risk Profile

| Risk Factor | Assessment |
|-------------|-----------|
| Technical risk | **High**: Coverness (SuccOrder on BidirectionalQuotient) identified as primary blocker; 955's plan confirms this is "mathematically impossible" |
| Blast radius | **Medium**: Changes canonical construction pipeline |
| Blocking dependency | **Task 951** (BLOCKED) |
| Effort estimate | 45-75 hours (from research-001) |
| Primary challenge | Coverness proof is a known hard problem; may require fallback strategy |

### 3.3 Task 955 Risk Profile

| Risk Factor | Assessment |
|-------------|-----------|
| Technical risk | **Medium**: Approach 7 (CanonicalR-based task_rel) is viable but requires `fmcs_canonicalR_monotone` proof |
| Blast radius | **Medium**: Changes `canonicalFrame` and all downstream consumers |
| Blocking dependency | **Task 951** (BLOCKED), Task 954 (listed but plan accounts for it) |
| Effort estimate | 25-40 hours (from plan) |
| Primary challenge | WorldHistory `respects_task` with non-trivial task_rel; box-case truth lemma compatibility |

---

## 4. Interaction Analysis

### 4.1 Would 953 Make 954/955 Easier or Harder?

**Neither.** Task 953 adds a parallel bilateral proof system. It does not change `Formula`, `Axiom`, `DerivationTree`, or any MCS property. Tasks 954/955 would proceed identically whether or not 953 has been completed.

The one potential interaction is in Phase 3 of 953 (bilateral MCS/FMCS): if 954 has already generalized D, the bilateral FMCS would inherit the general D. But since 953 Phase 3 is recommended to use the equivalence bridge (derive bilateral metalogic from unilateral), this interaction is minimal -- the bilateral FMCS would be derived from whichever unilateral FMCS exists (Int-based or general-D-based).

### 4.2 Would 954/955 Make 953 Easier or Harder?

**Neither, in practice.** Task 953's bilateral system is a proof-system-level refactoring. The canonical construction and representation theorem are downstream consumers. Whether those downstream consumers use `D = Int` or a syntactic D, or trivial or non-trivial task_rel, does not affect how the bilateral proof rules or bilateral MCS are defined.

### 4.3 Does 951's Blocked Status Matter?

**Yes, for 954/955. No, for 953.**

- Tasks 954 and 955 both list 951 as a dependency. Task 951 is BLOCKED because the F-preserving seed conjecture was proven false (v7 plan). This means the BFMCS infrastructure that 954/955 depend on may need architectural revision before those tasks can proceed.
- Task 953 has no dependency on 951. The bilateral proof system can be built and verified independently of completeness results.

---

## 5. Ordering Recommendation

### 5.1 Recommended Order: 953 First

**Begin with task 953** for the following reasons:

1. **Zero dependencies**: 953 depends on nothing. 954/955 depend on the blocked task 951.

2. **Lower risk**: 953 has well-understood bilateral logic theory and a clear implementation path (parallel system + equivalence bridge). 954 has a known mathematical impossibility (coverness) that may force fallback strategies. 955's Approach 7 is viable but untested against the full compilation pipeline.

3. **No negative interaction**: Starting 953 cannot make 954/955 harder. The bilateral system is additive, not destructive.

4. **Productive use of blocked time**: While 951 remains blocked, task 953 is the only one of the three that can make full progress. Working on 954/955 risks hitting the same blockers that stopped 951.

5. **Potential synergy**: The bilateral proof system's signed formula approach may provide fresh insights for the completeness infrastructure that 951/954/955 require. The bilateral MCS construction (Phase 3 of 953) naturally produces `(S+, S-)` pairs that encode both acceptance and rejection, which may simplify the truth lemma for the box case.

### 5.2 What About 955's "High Priority"?

Tasks 954 and 955 are marked high priority while 953 is medium. However, priority should be weighed against feasibility:

- 955 is **planned** but depends on infrastructure (BFMCS, `canonicalR_reflexive`, `canonicalR_transitive`) that may need updating once 951's blocker is resolved.
- 954 is **researched** but its core approach (orderIsoIntOfLinearSuccPredArch) was subsequently found to be blocked by the coverness problem, as documented in 955's plan.
- 953 is **researched** and its approach (parallel system + equivalence bridge) has no known blockers.

Executing a feasible medium-priority task before blocked high-priority tasks is standard project management.

### 5.3 Suggested Sequence

```
Phase A: Task 953 (bilateral proof system)
  - Independent, no blockers
  - ~55-90 hours
  - While working: monitor 951 for unblocking

Phase B: Task 955 (non-trivial task_rel)
  - After 951 blocker resolves (or if viable without it)
  - ~25-40 hours
  - Lower risk than 954 (Approach 7 is viable)

Phase C: Task 954 (general duration D)
  - After 955 (listed as dependency in TODO.md)
  - ~45-75 hours
  - Highest risk (coverness); may need 955's insights
  - Or: Re-evaluate after 955 determines if coverness is truly needed
```

---

## 6. Decisions

1. **Task 953 should be started first.** It is independent, lower risk, and feasible while 951 remains blocked.

2. **Tasks 954/955 should wait for 951 resolution.** Both depend on BFMCS infrastructure that may need architectural revision.

3. **The bilateral system does not affect canonical construction ordering.** No changes to the recommended sequence are needed based on bilateral system interactions.

4. **Priority labels (high vs. medium) do not override feasibility.** A feasible medium-priority task should proceed before blocked high-priority tasks.

---

## Appendix A: Files Affected by Each Task (No Overlap)

### Task 953 (New Files Only -- Parallel System)
- `ProofSystem/BilateralContext.lean` (NEW)
- `ProofSystem/BilateralDerivation.lean` (NEW)
- `ProofSystem/BilateralEquivalence.lean` (NEW)
- `Theorems/BilateralPropositional.lean` (NEW)

### Task 954 (Modifications)
- `Metalogic/Bundle/BidirectionalReachable.lean` (SuccOrder/PredOrder)
- `Metalogic/Bundle/CanonicalConstruction.lean` (parameterize over D)
- `Metalogic/Bundle/CanonicalCompleteness.lean` (parameterize over D)
- `Metalogic/Representation.lean` (syntactic D)
- NEW: `CanonicalDomain.lean`, `SuccessorAlgebra.lean`, `DomainTransfer.lean`

### Task 955 (Modifications)
- `Metalogic/Bundle/CanonicalConstruction.lean` (non-trivial task_rel)
- `Metalogic/Representation.lean` (use canonical_task_rel)
- `Metalogic/Bundle/CanonicalCompleteness.lean` (WorldHistory update)

**Overlap between 954 and 955**: Both modify `CanonicalConstruction.lean`, `CanonicalCompleteness.lean`, and `Representation.lean`. This confirms that 954 and 955 should be sequenced carefully (955 before 954, per TODO.md dependency listing).

**Overlap between 953 and 954/955**: Zero file overlap. Task 953 creates new files; tasks 954/955 modify existing metalogic files.
