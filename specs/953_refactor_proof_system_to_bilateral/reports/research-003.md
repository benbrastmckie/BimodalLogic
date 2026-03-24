# Research Report: Task #953 (research-003) -- Cost-Benefit Analysis of Bilateral Refactor

**Task**: 953 - Refactor proof system to bilateral system
**Date**: 2026-03-16
**Effort**: Research only (cost-benefit analysis per focus prompt)
**Dependencies**: None (foundational refactoring)
**Sources/Inputs**: Codebase analysis, research-001.md, research-002.md
**Artifacts**: This report
**Standards**: report-format.md
**Session**: sess_1773878520_a3f2b1

---

## 1. Executive Summary

This report evaluates the costs, benefits, and risks of refactoring the TM proof system from a unilateral system (`Gamma |- phi`) to a bilateral system with dual judgments (`Gamma |-+ phi` and `Gamma |-- phi`), incorporating a fresh codebase analysis.

**Principal Findings**:

1. **Current proof system is mature and complete.** The `DerivationTree` type has 8 inference rules, 21 axiom schemata, and is integrated with a full metalogic stack (deduction theorem, MCS properties, Lindenbaum lemma, soundness theorem). The system is ~330 lines for derivation plus ~580 lines for axioms.

2. **Signed formula infrastructure already exists.** The `Decidability/SignedFormula.lean` module (370 lines) provides `Sign` (`pos`/`neg`) and `SignedFormula` types with bilateral tableau rules. This can serve as the blueprint for bilateral proof rules.

3. **Benefits are primarily theoretical/philosophical, not practical.** The bilateral system makes assertion/denial explicit, aligns proof rules with tableau rules, and converts some axioms (ex_falso, peirce, modal_t, temp_t) into structural rules. However, the existing unilateral system is sound and complete.

4. **Effort is substantial but bounded.** Prior research estimates 55-90 hours. The parallel-system approach (Option A) minimizes risk by keeping `DerivationTree` intact while adding `BilateralDeriv` with an equivalence bridge.

5. **There are no blocking dependencies.** Task 953 is independent of the blocked completeness tasks (951, 954, 955). It can proceed while other infrastructure stabilizes.

6. **Recommended timing: defer until higher-priority tasks complete.** The bilateral refactor has aesthetic and philosophical benefits but does not unblock any other work. Current technical debt tasks (981: axiom removal) and blocked completeness work (951) have more immediate impact.

---

## 2. Current State of the Proof System

### 2.1 DerivationTree (Derivation.lean)

**Location**: `Theories/Bimodal/ProofSystem/Derivation.lean` (~330 lines)

**Structure**: Inductive type with 8 inference rules:

| Rule | Signature | Notes |
|------|-----------|-------|
| `axiom` | `Axiom phi -> Gamma |- phi` | Any of 21 axiom schemata |
| `assumption` | `phi in Gamma -> Gamma |- phi` | Context membership |
| `modus_ponens` | `Gamma |- phi->psi, Gamma |- phi -> Gamma |- psi` | Standard MP |
| `necessitation` | `|- phi -> |- box phi` | Modal necessitation (theorems only) |
| `temporal_necessitation` | `|- phi -> |- G phi` | Temporal necessitation (theorems only) |
| `temporal_duality` | `|- phi -> |- swap(phi)` | Symmetry of F/P operators |
| `irr` | Fresh atom rule for irreflexivity | Gabbay rule |
| `weakening` | `Gamma |- phi, Gamma <= Delta -> Delta |- phi` | Monotonicity |

**Key design choice**: `DerivationTree` is a `Type` (not `Prop`), enabling pattern matching for height computation and well-founded recursion in metalogic proofs.

### 2.2 Axiom System (Axioms.lean)

**Location**: `Theories/Bimodal/ProofSystem/Axioms.lean` (~580 lines)

**21 Axiom Schemata** organized by frame class:

| Category | Count | Examples |
|----------|-------|----------|
| Propositional | 4 | `prop_k`, `prop_s`, `ex_falso`, `peirce` |
| Modal S5 | 5 | `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist` |
| Temporal | 8 | `temp_k_dist`, `temp_4`, `temp_t_future`, `temp_t_past`, `temp_a`, `temp_l`, `temp_linearity`, ... |
| Modal-Temporal | 2 | `modal_future`, `temp_future` |
| Dense/Discrete | 3 | `density`, `discreteness_forward`, `seriality_*` |

### 2.3 Metalogic Infrastructure

| Module | Lines | Purpose |
|--------|-------|---------|
| `Core/DeductionTheorem.lean` | 460 | `(A::Gamma) |- B -> Gamma |- A->B` |
| `Core/MaximalConsistent.lean` | 530 | MCS definitions, Lindenbaum lemma |
| `Core/MCSProperties.lean` | ~400 | Deductive closure, negation completeness |
| `Soundness.lean` | 580 | `Gamma |- phi -> Gamma |= phi` |
| `Completeness.lean` | 530 | MCS modal/temporal closure properties |

**Total metalogic code depending on proof system**: ~2,500+ lines

### 2.4 Signed Formula Infrastructure

**Location**: `Metalogic/Decidability/SignedFormula.lean` (370 lines)

Already implements bilateral concepts:
- `Sign` inductive: `pos` | `neg`
- `SignedFormula` structure: `{sign, formula}`
- `Branch` = `List SignedFormula`
- Sign flip, contradiction detection, closure operations

**Location**: `Metalogic/Decidability/Tableau.lean` (380 lines)

Implements bilateral tableau expansion rules:
- `TableauRule` enum with 14 rules (andPos, andNeg, impPos, impNeg, boxPos, boxNeg, etc.)
- `RuleResult` for linear vs. branching expansion
- `applyRule` applies rule to signed formula
- Full bilateral reasoning already implemented for decision procedure

---

## 3. Benefits of Bilateral Refactor

### 3.1 Theoretical/Philosophical Benefits

1. **Explicit assertion/denial duality.** The bilateral system makes the two fundamental speech acts (assertion and denial) primitive rather than encoding denial through implication-to-bottom.

2. **Alignment with tableau procedure.** The existing tableau rules already operate bilaterally. A bilateral proof system would unify proof-theoretic and decision-theoretic presentations.

3. **Axiom simplification.** Several axioms become structural rules:
   - `ex_falso` (bot -> phi) -> `reject_bot` rule
   - `peirce` -> `reductio` rule (if rejecting phi leads to accepting phi, accept phi)
   - `modal_t` (box phi -> phi) -> `accept_box_elim` rule
   - `temp_t_future/past` -> `accept_future/past_elim` rules

4. **Natural treatment of negation.** In bilateral systems, negation flips the judgment (`|-+ neg phi` iff `|-- phi`), making the double-negation laws structural rather than axiomatic.

### 3.2 Practical Benefits

1. **Proof extraction.** Bilateral derivation trees may simplify proof extraction from closed tableau branches since the tableau already produces signed formulas.

2. **Countermodel extraction.** Open branches in tableau correspond to bilateral rejection; extracting countermodels becomes more direct.

3. **Foundation for future extensions.** Some non-classical logics (intuitionistic bilateral, relevance logic) have natural bilateral formulations.

### 3.3 Benefits Assessment

| Benefit | Impact | Immediacy |
|---------|--------|-----------|
| Philosophical elegance | Low | None |
| Tableau alignment | Medium | Future proof extraction |
| Axiom simplification | Low | Aesthetic only |
| Countermodel extraction | Medium | Future decidability work |

**Overall benefit assessment**: The benefits are primarily theoretical. The existing unilateral system works correctly and is complete for TM logic.

---

## 4. Costs of Bilateral Refactor

### 4.1 Development Effort

**Prior estimate** (research-001): 55-90 hours across 4 phases

| Phase | Effort | Scope |
|-------|--------|-------|
| 1: Bilateral infrastructure | 15-25 hrs | BilateralContext, BilateralDeriv types |
| 2: Equivalence bridge | 10-15 hrs | BilateralDeriv <-> DerivationTree |
| 3: Bilateral metalogic | 20-35 hrs | Bilateral MCS, Lindenbaum, soundness |
| 4: Bilateral decidability | 10-15 hrs | Proof extraction adaptation |

### 4.2 Codebase Impact

**Files affected** (from research-001 Appendix A):

New files (Phase 1-2):
- `ProofSystem/BilateralContext.lean`
- `ProofSystem/BilateralDerivation.lean`
- `ProofSystem/BilateralEquivalence.lean`
- `Theorems/BilateralPropositional.lean`

Migration candidates (Phase 3-4):
- `Metalogic/Core/MaximalConsistent.lean` - bilateral MCS
- `Metalogic/Core/MCSProperties.lean` - bilateral closure
- `Metalogic/Bundle/*` - bilateral FMCS/BFMCS
- `Metalogic/Soundness.lean` - bilateral soundness
- `Metalogic/Decidability/ProofExtraction.lean` - bilateral extraction

**Unchanged files** (Option A parallel system):
- `Syntax/Formula.lean` - no changes
- `Syntax/Context.lean` - unilateral context preserved
- `Semantics/*` - unchanged (bilateral is proof-theoretic, not semantic)

### 4.3 Maintenance Burden

With the parallel-system approach (Option A):
- **Two proof systems to maintain** during transition
- Equivalence bridge must be kept in sync with any rule changes
- Downstream consumers must choose which system to use

### 4.4 Opportunity Cost

Time spent on bilateral refactor is time not spent on:
- Task 981: Remove axiom technical debt (high priority)
- Task 951: Completeness infrastructure (blocked but high priority)
- Bug fixes and incremental improvements

---

## 5. Risks

### 5.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Bilateral deduction theorem harder | Medium | Medium | Use equivalence bridge to derive from unilateral |
| MCS construction differs | Low | Medium | Classical bilateral MCS = standard MCS with complement |
| Proof extraction complexity | Medium | Low | Tableau already bilateral; alignment should help |
| Performance regression | Low | Low | Derivation trees are rarely evaluated at runtime |

### 5.2 Project Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Scope creep into migration | Medium | High | Keep parallel system; no mandatory migration |
| Incomplete equivalence proof | Low | High | Test extensively; equivalence is mathematically straightforward |
| Distraction from higher priorities | High | Medium | Defer until critical path clear |

### 5.3 Risk Assessment Summary

The parallel-system approach (Option A) effectively mitigates technical risks by not touching existing code. The main risk is opportunity cost (displacing higher-priority work).

---

## 6. Dependencies and Timing

### 6.1 Dependencies

Task 953 has **no blocking dependencies**:
- Does not depend on task 951 (completeness) which is blocked
- Does not depend on task 954 (general duration) or 955 (task_rel)
- Operates on proof system layer, which is stable

### 6.2 Impact on Other Tasks

Task 953 **does not block** any other task:
- Tasks 954/955 use proof system through MCS interface, not directly
- Bilateral system would be parallel, not replacement
- Equivalence bridge ensures results transfer both ways

### 6.3 Recommended Timing

**Recommendation: Defer to medium priority**

Rationale:
1. Task 981 (remove axiom technical debt) is high priority and directly improves codebase quality
2. Task 951 (completeness) is blocked but more impactful when unblocked
3. Bilateral refactor is additive, not corrective; no urgency

The bilateral refactor can be executed at any time without affecting other work. It is a good candidate for "background" work when higher-priority tasks are blocked.

---

## 7. Summary: Cost-Benefit Analysis

| Factor | Assessment |
|--------|------------|
| **Effort** | 55-90 hours (substantial but bounded) |
| **Risk** | Low (parallel system approach) |
| **Practical benefit** | Low-Medium (proof extraction, countermodels) |
| **Theoretical benefit** | Medium (alignment, elegance, simplification) |
| **Urgency** | Low (no dependencies, no blocking) |
| **Opportunity cost** | High (displaces priority work) |

### 7.1 Recommendation

**Defer the bilateral refactor** until:
1. Task 981 (axiom debt) is complete
2. Task 951 (completeness) blockers are resolved
3. A clear use case emerges (e.g., proof extraction for verified decidability)

The bilateral system is a nice-to-have architectural improvement, not a necessary fix. The existing unilateral proof system is sound, complete, and well-integrated with metalogic infrastructure.

### 7.2 If Proceeding

If the decision is made to proceed despite the timing recommendation:
1. Use **Option A** (parallel system with equivalence bridge)
2. Start with **Phase 1-2** only (bilateral types + equivalence)
3. **Do not migrate** downstream modules until equivalence is proven
4. Consider **team mode** for parallel exploration of bilateral rules

---

## 8. Key Files for Reference

| File | Lines | Role |
|------|-------|------|
| `ProofSystem/Derivation.lean` | 330 | Current unilateral derivation |
| `ProofSystem/Axioms.lean` | 580 | 21 axiom schemata |
| `Decidability/SignedFormula.lean` | 370 | Existing signed formula types |
| `Decidability/Tableau.lean` | 380 | Bilateral tableau rules (blueprint) |
| `Core/DeductionTheorem.lean` | 460 | Deduction theorem (would need bilateral version) |
| `Core/MaximalConsistent.lean` | 530 | MCS definitions (would need bilateral version) |
| `Soundness.lean` | 580 | Soundness theorem |
| `Completeness.lean` | 530 | Completeness properties |

---

## 9. Decisions

1. **The bilateral refactor is technically feasible** with the parallel-system approach.
2. **Benefits are primarily theoretical/aesthetic**, not blocking any other work.
3. **Costs are substantial but bounded** at 55-90 hours.
4. **Timing recommendation: defer** until higher-priority tasks (981, 951) progress.
5. **No blockers exist** for this task; it can be started at any time.
6. **The existing unilateral system is adequate** for current and near-term needs.
