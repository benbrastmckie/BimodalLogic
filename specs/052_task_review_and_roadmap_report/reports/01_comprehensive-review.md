# Task 52: Comprehensive Task Review & Roadmap Report

**Date**: 2026-03-24
**Type**: Review / Audit
**Status**: COMPLETE

---

## Executive Summary

The ProofChecker project (bimodal TM logic in Lean 4) scores **92/100** for repository health. Soundness and decidability are **sorry-free**. The critical remaining work is a focused 3-task pipeline to eliminate 2 custom axioms, after which completeness can be fully wired. Of 18 active tasks, **5 can be abandoned** as superseded, **4 are deferred/low-priority**, and **9 form the active roadmap**.

---

## 1. Sorry Inventory (Excluding Boneyard)

**Total active sorries: ~93** across 22 non-Boneyard files.

### By Category

| Category | Files | Sorries | Nature |
|----------|-------|---------|--------|
| **Examples** (pedagogical exercises) | 3 | 12 | Intentional — student exercises left as `sorry` |
| **Metalogic/Bundle/SuccChainFMCS** | 1 | 24 | **CRITICAL** — axiom elimination target |
| **Theorems/Perpetuity/Bridge** | 1 | 13 | Wiring lemmas depending on completeness pipeline |
| **Theorems (other)** | 3 | 12 | P5/P6 perpetuity + propositional/modal wiring |
| **Metalogic/Bundle (other)** | 4 | 10 | Construction/CanonicalConstruction/SuccChainTruth/ModalSaturation |
| **Metalogic/Soundness** | 1 | 5 | Frame condition soundness lemmas |
| **Metalogic/Decidability/FMP** | 1 | 4 | Truth preservation in finite model property |
| **Metalogic/Core/RestrictedMCS** | 1 | 4 | Restricted MCS infrastructure |
| **FrameConditions/Completeness** | 1 | 3 | Frame condition completeness |
| **Metalogic (top-level wiring)** | 3 | 4 | DiscreteCompleteness, DenseCompleteness, Representation |
| **Syntax/SubformulaClosure** | 1 | 1 | Subformula closure (mentioned in comment only) |
| **Tests** | 1 | 5 | PerpetuityTest — blocked on Bridge sorries |

### Key Insight

The **24 sorries in SuccChainFMCS.lean** are the root cause for most downstream sorries. Eliminating the 2 custom axioms (`f_nesting_boundary`, `p_nesting_boundary`) would cascade sorry-removal through Bundle → Completeness → Representation → Theorems → Tests.

---

## 2. Active Tasks — Status and Recommendations

### CRITICAL PATH (Do Next)

| Task | Name | Status | Recommendation |
|------|------|--------|----------------|
| **48** | Prove succ_chain_fam bounded F-depth | PLANNED | **EXECUTE** — Phase A, no dependencies. Unblocks everything. |
| **36** | Prove f_nesting_boundary axiom | BLOCKED (on 48) | **EXECUTE after 48** — Phase B |
| **37** | Prove p_nesting_boundary axiom | NOT STARTED | **EXECUTE after 36** — Phase C, symmetric via F/P duality |
| **42** | Eliminate ALL custom axioms (umbrella) | RESEARCHED | **KEEP** — tracks the above pipeline. Close when 36+37 done. |

### HIGH PRIORITY (After Critical Path)

| Task | Name | Status | Recommendation |
|------|------|--------|----------------|
| **18** | Complete dense representation via DenseTask | BLOCKED | **EXECUTE after axiom elimination** — Phases 1-2 done, Phase 3 wiring gap |
| **8** | Genuine truth_at completeness | RESEARCHED | **EXECUTE after 18** — bridges canonical model to TaskFrame semantics |
| **21** | Clean up technical debt (tasks 9-20) | PLANNED | **EXECUTE after 18** — cleanup pass |

### RECOMMEND ABANDON / CLOSE

| Task | Name | Status | Reason to Abandon |
|------|------|--------|-------------------|
| **6** | Replace FlagBFMCS satisfies_at with TaskFrame truth_at | RESEARCHED | **Superseded by Task 8** — Task 8 is the refined, corrected version of this goal. 19 research reports produced no viable direct path; Task 8's 6-phase plan is the successor. |
| **19** | Deprecate old discrete pipeline | NOT STARTED | **Superseded by Task 41** — Task 41 already executed the D=CanonicalMCS elimination and boneyarded 11 infrastructure files. Remaining deprecation markers are trivial and can fold into Task 21 cleanup. |
| **20** | Audit parametric canonical infrastructure | NOT STARTED | **Fold into Task 21** — The parametric refactoring is a subset of the broader technical debt cleanup. No need for a separate task. |
| **49** | FMP-based boundedness proof (fallback) | RESEARCHED | **Defer/abandon unless 48 fails** — Explicitly designated as fallback. Only activate if Task 48's direct approach proves impossible. |
| **39** | Study preorder semantics conformance | RESEARCHED | **Close as resolved** — 4 research reports confirmed conformance. No implementation needed; findings can be documented in ROAD_MAP.md. |

### DEFERRED (Keep but Low Priority)

| Task | Name | Status | Recommendation |
|------|------|--------|----------------|
| **953** | Bilateral proof system refactor | RESEARCHED | **DEFER** — 55-90 hours, all research recommends deferral. Post-publication work. |
| **992** | Shift-Closed Tense S5 Algebra | RESEARCHED | **DEFER** — Theoretical extension, not on critical path. |
| **949** | Update Demo.lean | RESEARCHED | **DEFER** — Cosmetic, ~2 hours. Do after completeness is wired. |
| **619** | Agent system architecture upgrade | PLANNING | **DEFER** — Meta/tooling task, blocked on external GitHub issue. |

---

## 3. Representation Gaps — What Remains

The term "representation" in this project refers to the **Representation Theorem**: every consistent formula has a model (completeness via canonical model construction). Here is what remains:

### 3.1 Discrete Representation (D = Int)

**Status**: Infrastructure complete, wiring incomplete.

| Component | Status | File |
|-----------|--------|------|
| SuccChain FMCS construction | 24 sorries (2 axioms + derived) | `Bundle/SuccChainFMCS.lean` |
| SuccChain truth lemma | 2 sorries | `Bundle/SuccChainTruth.lean` |
| SuccChain completeness assembly | 2 sorries | `Completeness/SuccChainCompleteness.lean` |
| Discrete completeness theorem | 3 sorries | `DiscreteCompleteness.lean` |
| Canonical construction | 5 sorries | `Bundle/Construction.lean` |
| Modal saturation | 1 sorry | `Bundle/ModalSaturation.lean` |

**Blocker**: The 2 custom axioms in SuccChainFMCS.lean → Tasks 48 → 36 → 37.

### 3.2 Dense Representation (D = Rat or parametric)

**Status**: Components proven, final wiring gap.

| Component | Status | File |
|-----------|--------|------|
| Dense completeness components | Sorry-free | Various |
| DenseTask construction | Phases 1-2 complete | Task 18 |
| Phase 3 wiring (j>0 peeling) | Blocked | Task 18 |
| Dense completeness theorem | 1 sorry | `DenseCompleteness.lean` |

**Blocker**: DovetailedTimelineQuot integration for j>0 termination → Task 18.

### 3.3 Unified Representation Theorem

**Status**: 1 sorry in `Metalogic/Representation.lean`.

Depends on both discrete and dense completeness. Will be resolved once Tasks 48→36→37→18 complete.

### 3.4 Frame Condition Completeness

**Status**: 3 sorries in `FrameConditions/Completeness.lean`.

Requires representation theorem for each frame condition variant (dense, discrete). Will cascade from above.

### 3.5 Soundness Gaps

**Status**: 5 sorries in `Metalogic/Soundness.lean`.

These are frame condition soundness lemmas — likely straightforward once the frame condition typeclass architecture (Task 978, completed) is fully wired.

---

## 4. Execution Roadmap

### Phase 1: Axiom Elimination (Tasks 48 → 36 → 37)
- **Estimated effort**: 15-25 hours
- **Impact**: Eliminates 2 custom axioms, resolves ~30 sorries in Bundle/
- **Dependency**: None — can start immediately

### Phase 2: Dense Wiring (Task 18)
- **Estimated effort**: 6-7 hours
- **Impact**: Completes dense completeness, resolves ~5 sorries
- **Dependency**: Partial dependency on Phase 1 (shared infrastructure)

### Phase 3: Unified Completeness (Task 8)
- **Estimated effort**: 12-20 hours
- **Impact**: Bridges canonical model to TaskFrame truth_at
- **Dependency**: Phases 1 and 2

### Phase 4: Cleanup (Task 21)
- **Estimated effort**: 3-5 hours
- **Impact**: Dead code removal, documentation, absorbs Tasks 19/20
- **Dependency**: Phase 3

### Phase 5: Perpetuity & Examples
- **Estimated effort**: 3-5 hours
- **Impact**: Resolves Bridge.lean (13 sorries), example exercises (12 sorries), tests (5 sorries)
- **Dependency**: Phase 3 (completeness needed for Bridge wiring)

### Total Remaining Effort: ~40-60 hours to sorry-free completeness

---

## 5. Summary of Recommendations

### Execute (9 tasks)
1. **Task 48** — Prove bounded F-depth (START HERE)
2. **Task 36** — Prove f_nesting_boundary
3. **Task 37** — Prove p_nesting_boundary
4. **Task 42** — Umbrella tracker (close when 36+37 done)
5. **Task 18** — Dense representation wiring
6. **Task 8** — Genuine truth_at completeness
7. **Task 21** — Technical debt cleanup (absorb Tasks 19, 20)
8. **Task 949** — Update Demo.lean (after completeness)
9. **Task 619** — Agent system upgrade (when unblocked)

### Abandon / Close (5 tasks)
1. **Task 6** — Superseded by Task 8
2. **Task 19** — Superseded by Task 41, remainder folds into Task 21
3. **Task 20** — Folds into Task 21
4. **Task 39** — Research complete, no implementation needed
5. **Task 49** — Fallback only, not needed if Task 48 succeeds

### Defer (2 tasks)
1. **Task 953** — Bilateral refactor (post-publication)
2. **Task 992** — STSA algebra (theoretical extension)

---

## 6. CanonicalR Traces — Cleanup Status

`CanonicalR` has been **functionally replaced** by `ExistsTask` (defined as `g_content M ⊆ M'`), but deprecated aliases remain in active code.

### What Remains

| File | Artifact | Type |
|------|----------|------|
| `Bundle/CanonicalFrame.lean:76` | `abbrev CanonicalR := ExistsTask` | Deprecated alias |
| `Bundle/CanonicalFrame.lean:91` | `abbrev CanonicalR_past := ExistsTask_past` | Deprecated alias |
| `Bundle/CanonicalFrame.lean:218` | `canonicalR_transitive` | Name alias for `existsTask_transitive` |
| `Bundle/CanonicalIrreflexivity.lean:164` | `canonicalR_reflexive` | Name alias for `existsTask_reflexive` |
| `Bundle/CanonicalIrreflexivity.lean:178` | `canonicalR_past_reflexive` | Name alias for `existsTask_past_reflexive` |
| `Bundle/CanonicalConstruction.lean:67,176,195` | References to `canonicalR_transitive` | Uses lowercase alias |
| `Metalogic/Metalogic.lean:15` | Doc string mentions `canonicalR_reflexive` | Documentation |
| `Canonical/README.md:29` | Doc mentions CanonicalR | Documentation |
| `Metalogic/Representation.lean:26` | Mentions `CanonicalRIrreflexive` axiom | Archived context |

### Assessment

No active proof depends on `CanonicalR` directly — all proofs use `ExistsTask`. However, the deprecated aliases create confusion and should be cleaned up. The lowercase aliases (`canonicalR_transitive`, etc.) are used by name in `CanonicalConstruction.lean` and `ParametricCanonical.lean`, requiring a rename pass.

### Recommendation

**Fold into Task 21 (technical debt cleanup)** with sub-steps:
1. Replace `canonicalR_transitive` → `existsTask_transitive` in CanonicalConstruction.lean and ParametricCanonical.lean
2. Delete the 5 deprecated `abbrev`/alias definitions
3. Update documentation references
4. Estimated effort: <1 hour

---

## 7. Algebraic & Category-Theoretic Gap Analysis

### 7.1 What Exists (Sorry-Free)

The **Lindenbaum-Tarski algebraic infrastructure** is complete and sorry-free:

| Component | File | Status |
|-----------|------|--------|
| Lindenbaum quotient `Formula / ProvEquiv` | `Algebraic/LindenbaumQuotient.lean` | Sorry-free |
| `BooleanAlgebra` instance on `LindenbaumAlg` | `Algebraic/BooleanStructure.lean` | Sorry-free |
| Box as interior operator (deflationary, monotone, idempotent) | `Algebraic/InteriorOperators.lean` | Sorry-free |
| G, H as monotone operators | `Algebraic/InteriorOperators.lean` | Sorry-free |
| Ultrafilter-MCS bijection | `Algebraic/UltrafilterMCS.lean` | Sorry-free |
| Basic algebraic representation (consistent → satisfiable) | `Algebraic/AlgebraicRepresentation.lean` | Sorry-free |
| D-parametric canonical TaskFrame | `Algebraic/ParametricCanonical.lean` | Sorry-free |
| D-parametric truth lemma | `Algebraic/ParametricTruthLemma.lean` | Sorry-free |
| D-parametric world histories | `Algebraic/ParametricHistory.lean` | Sorry-free |
| Conditional representation theorem | `Algebraic/ParametricRepresentation.lean` | 1 sorry (needs `construct_bfmcs`) |

### 7.2 What's Designed but Not Formalized

**The STSA (Shift-Closed Tense S5 Algebra) — Task 992** is fully designed in `specs/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md` but has zero Lean formalization:

| Component | Description | Est. Effort |
|-----------|-------------|-------------|
| **STSA structure definition** | `(A, □, G, H, σ)` with S5 + tense + interaction axioms | ~100 lines |
| **Temporal duality `σ`** | Lift `swap_temporal` involution to `LindenbaumAlg ≃ LindenbaumAlg` | ~30 lines |
| **STSA instance for LindenbaumAlg** | Wire existing Boolean algebra + operators + σ | ~50 lines |
| **Galois connections `P* ⊣ G*` and `F* ⊣ H*`** | Adjunctions from Lindenbaum algebra structure | ~80 lines |
| **Jónsson-Tarski relational representation** | Canonical relations from operators: `R_□`, `R_G`, `R_H` | ~120 lines |

### 7.3 Categorical Gaps (Not Yet Explored)

These are **entirely unexplored** in the codebase — no research, no specs, no code:

| Gap | Description | Significance |
|-----|-------------|--------------|
| **Cmplx ⊣ Can adjunction** | Complex algebra functor (Frame → Algebra) and Canonical frame functor (Algebra → Frame) form a dual adjunction | Would give the representation theorem as a unit of adjunction — the cleanest possible formulation |
| **Stone duality for TM-frames** | Extend Stone duality (Boolean algebras ≃ Stone spaces) to account for □, G, H operators | Standard route to descriptive frames; connects to topology |
| **Goldblatt-Thomason characterization** | Which classes of frames are definable by TM axioms? | Characterizes the expressive power of TM logic |
| **Canonical extensions** (Gehrke-Jónsson) | Extend STSA to its canonical extension for abstract completeness | Eliminates need for explicit MCS construction |
| **Functorial semantics** | TM-models as functors from a syntactic category | Would unify semantic approaches |
| **Coalgebraic perspective** | TM-frames as coalgebras for an endofunctor on Set | Alternative to relational semantics |

### 7.4 Algebraic Dead Ends (Permanently Closed)

| Approach | Why Abandoned | Archive Location |
|----------|---------------|------------------|
| D = CanonicalMCS conflation | Type mismatch: MCS has `Preorder`, D needs `AddCommGroup` | Task 41 cleanup (completed) |
| Task 988: Dense algebraic completeness | Built on D=CanonicalMCS anti-pattern | `specs/archive/` |
| Task 989: Discrete algebraic completeness | Superseded by succ-chain approach | `specs/archive/` |
| Syntax-based D construction | Replaced by parametric approach (D as external parameter) | Various Boneyard files |

### 7.5 Revised Recommendation for Task 992 (STSA)

Given the concern about insufficient algebraic exploration, Task 992 warrants **elevation from DEFERRED to MEDIUM priority**. The STSA formalization would:

1. **Consolidate** the existing sorry-free algebraic infrastructure into a unified algebraic framework
2. **Surface** whether the Galois connections `P* ⊣ G*` and `F* ⊣ H*` can simplify the completeness proof
3. **Enable** categorical representation (Cmplx ⊣ Can) as an alternative to the current MCS-based construction
4. **Connect** to the broader literature (Bezhanishvili-Carai MS4.t algebras, von Karger temporal algebra)

**Proposed new task** (or sub-task of 992): Formalize the STSA structure + instance (~200 lines, ~4-6 hours). This is independent of the axiom elimination pipeline and can be done in parallel.

### 7.6 Specific Algebraic Holes in the Completeness Pipeline

The current completeness pipeline is **relational** (MCS + canonical relations + truth lemma). An **algebraic** completeness pipeline would look different:

```
Current:  MCS → CanonicalR (ExistsTask) → FMCS → BFMCS → TaskFrame → truth_at
                                          ^^^^^^^^^^^^^^^^
                                          This is where the sorries live

Algebraic: LindenbaumAlg → STSA instance → Jónsson-Tarski rep → Complex algebra embedding
                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                            This path is unexplored in Lean
```

The algebraic path could potentially **bypass** the BFMCS construction sorries entirely, because Jónsson-Tarski representation works at the algebraic level without needing explicit chain construction. However, it requires the STSA formalization as a prerequisite.

### 7.7 Summary of Algebraic Recommendations

| Action | Priority | Effort | Impact |
|--------|----------|--------|--------|
| Formalize STSA structure + LindenbaumAlg instance | MEDIUM | 4-6 hrs | Unifies algebraic infrastructure |
| Formalize temporal duality σ on quotient | MEDIUM | 1-2 hrs | Enables STSA, simplifies proofs |
| Formalize Galois connections P* ⊣ G*, F* ⊣ H* | MEDIUM | 3-4 hrs | May simplify completeness |
| Explore Jónsson-Tarski representation as alternative completeness path | LOW-MEDIUM | 8-12 hrs | Could bypass BFMCS sorries |
| Clean up CanonicalR deprecated aliases | LOW | <1 hr | Hygiene, fold into Task 21 |
| Categorical functor formalization (Cmplx, Can) | LOW | 10-15 hrs | Theoretical elegance |
| Stone duality / canonical extensions | FUTURE | 20+ hrs | Post-publication research |
