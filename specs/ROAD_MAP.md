# ProofChecker Development Roadmap

**Last Updated**: 2026-02-03
**Status**: Completeness Hierarchy Complete (Weak/Finite Strong/Infinitary Strong), Compactness Sorry-Free, Active Refinement Phase

> **Content Boundaries**: ROADMAP = strategic vision (months-years), TODO.md = task queue (days-weeks), task artifacts = execution details (hours-days).
> Each entry should include *Rationale* (why) and *References* (learn more).

---

## Changelog

<!-- Schema: Dated entries of completed work
### YYYY-MM-DD
- **Task {N}**: {summary}
  - *Rationale*: {Why this work was needed/pursued}
  - *References*: [summary](path/to/summary.md), [plan](path/to/plan.md)

Updated by /todo command during task archival.
-->

### 2026-02-03

- **Task 827**: Eliminated modal_backward sorry in Construction.lean via singleFamily_modal_backward_axiom
  - *Rationale*: The single-family BMCS simplification required accepting modal_backward as sorry; axiom approach provides mathematically justified foundation while preserving infrastructure for future axiom-free implementation
  - *References*: [summary](specs/archive/827_complete_multi_family_bmcs_construction/summaries/implementation-summary-20260203.md)

- **Task 833**: Restructured ROAD_MAP.md with Changelog, Strategies, Ambitions, and Dead Ends sections
  - *Rationale*: Enable programmatic updates by /todo and /review commands with machine-parseable schemas
  - *References*: [summary](specs/archive/833_enhance_roadmap_structure_changelog_strategies_ambitions/summaries/implementation-summary-20260203.md)

- **Task 835**: Extended /review command with bidirectional ROADMAP.md integration
  - *Rationale*: Enable /review to load strategic context (Strategies/Ambitions) and propose roadmap updates based on findings
  - *References*: [summary](specs/archive/835_enhance_review_command_roadmap_integration_revision/summaries/implementation-summary-20260203.md)

- **Task 836**: Improved Metalogic README documentation with flowcharts and subdirectory summaries
  - *Rationale*: Following incomplete task 830 work; needed accurate sorry counts and comprehensive cross-links
  - *References*: [summary](specs/archive/836_improve_metalogic_readme_documentation/summaries/implementation-summary-20260203.md)

---

## Strategies

<!-- Schema: Active experiments with status
### Strategy: {Name}
**Status**: ACTIVE|PAUSED|CONCLUDED|ABANDONED
**Started**: YYYY-MM-DD
**Hypothesis**: {What we're testing}

*Rationale*: {Why we chose this approach over alternatives}

**Approach**:
{Description}

**Outcomes**:
- {Outcome}

**References**:
- [Research Report](path) - {what it covers}
- [Task N](specs/N_.../plans/...) - Initial implementation

---
-->

### Strategy: Representation-First Architecture

**Status**: CONCLUDED
**Started**: 2025-12-01
**Hypothesis**: Placing canonical model construction as the foundation (with completeness as a corollary) provides cleaner proof structure than treating completeness as primary.

*Rationale*: Core completeness depends on the representation theorem as foundation. By proving representation first, soundness and completeness become natural corollaries rather than primary goals requiring separate proof machinery.

**Approach**:
The architecture places canonical model construction as the foundation, with FMP as the central bridge. Completeness derives from representation rather than being treated as primary. This inverts the traditional presentation order (soundness -> completeness) to (representation -> completeness corollaries).

**Outcomes**:
- Representation theorem proven sorry-free (Task 654)
- Weak, finite strong, and infinitary strong completeness all derive from representation
- Compactness proven via finitary strong completeness
- Clear dependency hierarchy: Core < Representation < Completeness < Compactness

**References**:
- [Bimodal/Metalogic/Representation/](Theories/Bimodal/Metalogic/Representation/) - Core implementation
- [Task 654 research](specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-003.md) - Approach analysis
- [Bundle/Representation.lean](Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean) - Main theorem

---

### Strategy: Indexed MCS Family Approach

**Status**: ACTIVE
**Started**: 2025-12-15
**Hypothesis**: Using a family of MCS indexed by time (mcs : D -> Set Formula) with temporal coherence conditions matches irreflexive G/H semantics without requiring T-axioms.

*Rationale*: TM's G/H operators are irreflexive (strictly future/past, excluding present). A family-based approach naturally captures this structure, with each time point having its own MCS connected via temporal coherence conditions.

**Approach**:
Design uses a family of MCS indexed by time, where coherence conditions (forward_G, backward_H, forward_H, backward_G) connect time points. These conditions match the irreflexive semantics without requiring T-axioms.

**Outcomes**:
- Representation theorem proven without T-axiom dependency
- Task relation (canonical_history_family_respects) proven
- Truth lemma for temporal operators proven
- Documented gaps in backward truth lemma cases (non-blocking)

**References**:
- [IndexedMCSFamily.lean](Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean) - Core structure
- [CanonicalHistory.lean](Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean) - Task relation proof
- [TruthLemma.lean](Theories/Bimodal/Metalogic/Representation/TruthLemma.lean) - Truth lemma

---

### Strategy: CoherentConstruction Two-Chain Design

**Status**: ACTIVE
**Started**: 2026-01-10
**Hypothesis**: A two-chain design (forward chain for times > 0, backward chain for times < 0) from a central origin simplifies coherence proofs by making coherence conditions definitional.

*Rationale*: The original construct_indexed_family approach required proving coherence conditions after the fact. CoherentConstruction provides cleaner architecture where coherence holds by construction.

**Approach**:
1. Origin MCS: Lindenbaum extension of seed formula
2. Forward chain: G-persistence definitional for times > 0
3. Backward chain: H-persistence definitional for times < 0
4. Cross-origin coherence: Cases 2,3 have documented gaps, but only Cases 1,4 needed for completeness

**Outcomes**:
- Origin, forward, and backward chains proven
- Completeness integration proven using only Cases 1,4
- Cross-origin gaps documented as non-blocking

**References**:
- [CoherentConstruction.lean](Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean) - Implementation
- [Task 814 research](specs/archive/814_sorry_reduction_coherentconstruction_cases_2_3/reports/) - Analysis
- [Phase 4 overview](specs/ROAD_MAP.md#phase-4-architecture-optimization-high-priority) - Architecture context

---

### Strategy: Algebraic Verification Path

**Status**: PAUSED
**Started**: 2026-01-05
**Hypothesis**: Boolean algebra with modal operators provides an alternative verification path via Stone duality, potentially simplifying some arguments.

*Rationale*: Algebraic methods (Lindenbaum-Tarski quotient, ultrafilter correspondence) provide independent verification of Kripke semantics results and may offer elegant alternative proofs.

**Approach**:
1. Define Lindenbaum-Tarski quotient algebra
2. Prove Boolean algebra structure
3. Define interior operators for G/H
4. Establish ultrafilter-MCS correspondence
5. Verify completeness via algebraic methods

**Outcomes**:
- Quotient algebra defined
- Boolean structure proven
- Interior operators and ultrafilter correspondence partially implemented

**References**:
- [Algebraic/ module](Theories/Bimodal/Metalogic/Algebraic/) - Implementation
- [Phase 5 description](specs/ROAD_MAP.md#phase-5-managing-remaining-sorries-low-priority) - Context
- [research-003.md Approach 4](specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-003.md) - Original analysis

---

## Ambitions

<!-- Schema: Big picture goals
### Ambition: {Name}
**Priority**: HIGH|MEDIUM|LOW
**Timeframe**: SHORT-TERM|MEDIUM-TERM|LONG-TERM|ONGOING

*Rationale*: {Why this goal matters to the project}

**Success Criteria**:
- [ ] {Criterion}

**Description**:
{What we aspire to achieve}

**Related Phases**: Phase {N}
**References**:
- [Phase N description](ROAD_MAP.md#phase-n) - Context
- [Task M research](path) - Supporting analysis

---
-->

### Ambition: Publication-Ready Metalogic

**Priority**: HIGH
**Timeframe**: MEDIUM-TERM

*Rationale*: Core use case for the codebase - verified modal logic proofs that can be cited in academic work and used as a reference implementation.

**Success Criteria**:
- [x] Representation theorem sorry-free
- [x] Completeness hierarchy (weak/finite strong/infinitary) proven
- [x] Compactness sorry-free
- [ ] Soundness proven (currently axiomatized)
- [ ] Full documentation with tutorials
- [ ] Paper draft or technical report

**Description**:
A publication-ready package of verified metalogical results for TM bimodal logic, suitable for academic citation and practical verification use.

**Related Phases**: Phase 6 (Polish and Publication)
**References**:
- [Metalogic README](Theories/Bimodal/Metalogic/README.md) - Current architecture
- [API Reference](docs/reference/API_REFERENCE.md) - Documentation status
- [Phase 6 description](specs/ROAD_MAP.md#phase-6-polish-and-publication-low-priority-now-high-later) - Publication tasks

---

### Ambition: Full LTL Extension

**Priority**: MEDIUM
**Timeframe**: LONG-TERM

*Rationale*: Until/Since operators complete the temporal expressiveness. Full LTL is important for verification applications and aligns the formalization with standard temporal logic literature.

**Success Criteria**:
- [ ] Until (U) operator added to syntax
- [ ] Since (S) operator added to syntax
- [ ] Expansion axioms proven
- [ ] Completeness for full LTL proven

**Description**:
Extend the current TM (G/H only) logic to full LTL with Until and Since operators, including soundness and completeness proofs.

**Related Phases**: Phase 3.3.A (Temporal Logic Extensions)
**References**:
- [Phase 3.3 description](specs/ROAD_MAP.md#33-temporal-logic-extensions) - Extension tasks
- [LTL.lean](Theories/Bimodal/Basic.lean) - Current syntax

---

### Ambition: Modular Frame Classes

**Priority**: MEDIUM
**Timeframe**: MEDIUM-TERM

*Rationale*: Enables theory reuse across different modal systems (K, T, S4, S5, etc.). A generic framework parameterized by frame properties makes it easy to prove results for new logics.

**Success Criteria**:
- [ ] FrameClass typeclass defined
- [ ] Canonical model parameterized by frame class
- [ ] Completeness relative to frame classes proven
- [ ] At least 2 modal logics instantiated (K, S5)

**Description**:
Parameterize the completeness framework by frame class, enabling reuse across different modal logics with different accessibility relation properties.

**Related Phases**: Phase 2.3 (Modular Frame Properties)
**References**:
- [Phase 2.3 description](specs/ROAD_MAP.md#23-modular-frame-properties) - Frame class tasks
- [FrameClasses concept](Theories/Bimodal/Semantics.lean) - Current semantics

---

### Ambition: Algebraic Verification Path

**Priority**: LOW
**Timeframe**: LONG-TERM

*Rationale*: Alternative proof method that may simplify some arguments. Algebraic methods (Stone duality, Boolean algebras with operators) provide dual verification and elegant characterizations.

**Success Criteria**:
- [ ] Interior operators (G/H) fully proven
- [ ] Ultrafilter-MCS correspondence complete
- [ ] Completeness via algebraic methods proven
- [ ] Documentation comparing algebraic and Kripke approaches

**Description**:
Complete the algebraic approach using Boolean algebra with modal operators, providing independent verification of Kripke semantics results via Stone duality.

**Related Phases**: Phase 5 (Managing Remaining Sorries)
**References**:
- [Algebraic/ module](Theories/Bimodal/Metalogic/Algebraic/) - Current implementation
- [research-003.md](specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-003.md) - Approach analysis

---

### Ambition: Proof Economy

**Priority**: HIGH
**Timeframe**: ONGOING

*Rationale*: Reduce sorry count to achieve production-quality proofs. A low sorry count indicates a mature, trustworthy formalization and enables confident use in verification.

**Success Criteria**:
- [x] Critical path sorry-free (representation theorem)
- [x] Compactness sorry-free
- [ ] Sorry count below 200 (currently ~295)
- [ ] No blocking sorries on main theorem paths
- [ ] Documented sorry debt policy enforced

**Description**:
Systematically reduce sorries in the Metalogic module through proof completion, alternative constructions, or explicit documentation as intentional gaps.

**Related Phases**: Phase 1 (Proof Quality), Phase 5 (Managing Sorries)
**References**:
- [sorry-debt-policy.md](docs/policies/sorry-debt-policy.md) - Debt management
- [Task 758](specs/TODO.md) - Sorry audit task
- [Phase 1 goals](specs/ROAD_MAP.md#phase-1-proof-quality-and-organization-high-priority) - Economy tasks

---

## Dead Ends

<!-- Schema: Approaches that were tried and abandoned
### Dead End: {Name}
**Status**: ABANDONED|SUPERSEDED|BLOCKED
**Tried**: YYYY-MM-DD to YYYY-MM-DD
**Related Tasks**: Task {N}, Task {M}

*Rationale*: {Why we originally tried this approach}

**What We Tried**:
{Description}

**Why It Failed**:
{Specific reasons}

**Evidence**:
- [Boneyard/File.lean](path) - Archived implementation
- [Task N summary](path) - Post-mortem analysis

**Lesson**:
{1-sentence actionable takeaway}

**Superseded By**: {Alternative approach if applicable}

---
-->

### Dead End: Boneyard Decidability Infrastructure

**Status**: SUPERSEDED
**Tried**: 2025-10-01 to 2025-12-15
**Related Tasks**: Task 755

*Rationale*: Attempted decidability via explicit frame enumeration using tableau-based decision procedure.

**What We Tried**:
Built comprehensive decidability infrastructure in Boneyard/Metalogic_v2/Decidability/ including tableau system, saturation algorithm, branch closure detection, and decision procedure with soundness proof.

**Why It Failed**:
The parametric FMP approach (semantic_weak_completeness) provides a cleaner path to practical completeness without the full decidability machinery. The Boneyard approach required maintaining complex tableau state and rule application tracking.

**Evidence**:
- [Boneyard/Metalogic_v2/Decidability/](Theories/Boneyard/Metalogic_v2/Decidability/) - Archived implementation
- [Decidability tables in roadmap](specs/ROAD_MAP.md#decidability-infrastructure-boneyard) - Status documentation

**Lesson**:
When multiple paths exist, evaluate which provides value faster. Full decidability is nice-to-have; sorry-free completeness was the actual blocking need.

**Superseded By**: semantic_weak_completeness via parametric FMP approach

---

### Dead End: Single-History FDSM Construction

**Status**: ABANDONED
**Tried**: 2026-01-05 to 2026-01-10
**Related Tasks**: Task 825

*Rationale*: Attempted simpler single-history model construction, hoping to avoid the complexity of multi-history indexed MCS families.

**What We Tried**:
Constructed FDSM (Finite Deterministic State Machine) models from closure of a formula, using a single history that evolves over time.

**Why It Failed**:
Modal trivialization: with a single history, Box psi becomes equivalent to psi because there's only one "future" path to evaluate. The irreflexive G/H semantics requires multiple possible futures/pasts.

**Evidence**:
- [Task 825 research-002.md](specs/archive/825_fdsm_construction/reports/research-002.md) - Analysis of trivialization
- Archived fdsm_from_closure_mcs attempt

**Lesson**:
Multi-history saturation is required for non-trivial modalities in TM logic. Single-history approaches trivialize modal operators.

**Superseded By**: Indexed MCS Family approach with multiple histories

---

### Dead End: Cross-Origin Coherence Proofs

**Status**: BLOCKED
**Tried**: 2026-01-15 to 2026-01-20
**Related Tasks**: Task 814

*Rationale*: Attempted to prove coherence across different MCS origins (e.g., showing G-persistence from t<0 to t>0) for completeness of the CoherentConstruction approach.

**What We Tried**:
Proved Cases 1 and 4 of coherence conditions (same-side of origin). Attempted Cases 2 and 3 (cross-origin) to complete the full coherence proof.

**Why It Failed**:
Cases 2 and 3 are not on the critical path for completeness. The representation theorem and completeness proofs only require coherence for times on the same side of the origin.

**Evidence**:
- [CoherentConstruction.lean](Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean) - Documented sorries for Cases 2,3
- [Task 814 research](specs/archive/814_sorry_reduction_coherentconstruction_cases_2_3/reports/) - Analysis

**Lesson**:
Focus effort on what's actually blocking main results. Not all mathematical completeness is necessary for practical theorem proving.

**Superseded By**: N/A (accepted as non-blocking gap)

---

### Dead End: Original IndexedMCSFamily.construct_indexed_family

**Status**: SUPERSEDED
**Tried**: 2025-12-15 to 2026-01-10
**Related Tasks**: Task 753

*Rationale*: Initial attempt at indexed family construction, proving coherence conditions after constructing the family.

**What We Tried**:
Built construct_indexed_family that creates an IndexedMCSFamily and then proves coherence conditions (forward_G, backward_H, etc.) as separate theorems.

**Why It Failed**:
Proof complexity: proving coherence after construction required complex reasoning about the construction process. The two-chain design of CoherentConstruction makes coherence definitional, eliminating these proof obligations.

**Evidence**:
- Git history of IndexedMCSFamily.lean
- [Task 753 research](specs/archive/753_prove_coherentconstruction_sorries/reports/) - Sigma-type refactoring analysis
- [Task 814 research](specs/archive/814_sorry_reduction_coherentconstruction_cases_2_3/reports/) - Two-chain design benefits

**Lesson**:
When proofs are hard, consider whether the definition can be restructured to make properties hold by construction rather than by proof.

**Superseded By**: CoherentConstruction module with two-chain design

---

## Overview

This roadmap outlines the current state of the ProofChecker project and charts the path forward for:
1. **Proof Quality**: Improving economy, flow, and organization
2. **Generalization**: From weak to strong results, finite to infinite
3. **Extension**: Adding natural corollaries and applications
4. **Architecture**: Optimal structure for efficiency and reusability

---

## Current State: What's Been Accomplished

### Metalogic_v2: Representation-First Architecture (Boneyard)

**Status**: DEPRECATED. Code preserved in `Boneyard/Metalogic_v2/` as historical reference.

The Boneyard contains a complete metalogic implementation including soundness, completeness, FMP, decidability, and compactness. This was the foundation for the current parametric approach but has been superseded by the `Bimodal/Metalogic/` architecture. Key proven results include representation theorem, truth lemma, and canonical model construction.

*Full Boneyard documentation available in [Boneyard/README.md](Theories/Boneyard/README.md). For active development status, see the Bimodal/Metalogic section below.*

### Bimodal/Metalogic: Universal Parametric Representation Theorem (Task 654)

**Status**: Representation theorem proven, indexed MCS family approach successful

**Completed**: 2026-01-20 (Task 654)

#### Indexed MCS Family Approach

TM's G/H operators are **irreflexive** (strictly future/past, excluding present), so the design uses a **family of MCS indexed by time** `mcs : D -> Set Formula`, where each time point has its own MCS connected via temporal coherence conditions:
- `forward_G`: G phi ∈ mcs(t) → phi ∈ mcs(t') for all t' > t (strictly future)
- `backward_H`: H phi ∈ mcs(t) → phi ∈ mcs(t') for all t' < t (strictly past)
- `forward_H`: H phi ∈ mcs(t') → phi ∈ mcs(t) for t < t' (looking back from future)
- `backward_G`: G phi ∈ mcs(t') → phi ∈ mcs(t) for t' < t (looking forward from past)

These conditions match the irreflexive semantics **without requiring T-axioms**.

#### Core Infrastructure (Theories/Bimodal/Metalogic/Representation/)

| Component | Status | Location |
|-----------|--------|----------|
| **IndexedMCSFamily** | ✅ DEFINED | IndexedMCSFamily.lean |
| **Indexed family construction** | 🟡 PARTIAL (sorries) | IndexedMCSFamily.lean |
| **Canonical history (family-based)** | ✅ PROVEN | CanonicalHistory.lean:226-288 |
| **canonical_history_family_respects** | ✅ PROVEN (no T-axiom!) | CanonicalHistory.lean |
| **Truth lemma (forward, temporal)** | ✅ PROVEN | TruthLemma.lean |
| **Truth lemma (backward, temporal)** | 🟡 PARTIAL (sorries) | TruthLemma.lean |
| **Representation theorem** | ✅ PROVEN | UniversalCanonicalModel.lean:70-89 |

#### Main Results

| Result | Status | Location |
|--------|--------|----------|
| **representation_theorem** | ✅ PROVEN (no sorry) | UniversalCanonicalModel.lean:70 |
| Consistent formulas satisfiable | ✅ | Via indexed family + truth lemma |
| **Task relation without T-axiom** | ✅ PROVEN | CanonicalHistory.lean:226 |
| Truth lemma atoms/bot/temporal | ✅ PROVEN | TruthLemma.lean:102-177 |

#### Documented Gaps (Sorries for Future Work)

**Phase 4 - Family Construction** (4 sorries):
- Seed consistency proofs require temporal K distribution axiom
- Coherence condition proofs in `construct_indexed_family`

**Phase 6 - Truth Lemma Gaps** (6 sorries):
- Truth lemma forward: imp case (requires MCS modus ponens closure)
- Truth lemma forward: box case (requires witness construction)
- Truth lemma backward: imp/box/temporal cases (require negation completeness)

**Impact**: The main representation theorem is **fully proven** because it only needs:
1. The indexed family structure (coherence conditions in structure provide necessary properties)
2. Truth lemma forward direction for temporal operators (fully proven)
3. Lindenbaum extension (already proven)

#### Main Result

**Representation Theorem**:
```lean
theorem representation_theorem (phi : Formula) (h_cons : SetConsistent {phi}) :
    ∃ (family : IndexedMCSFamily D) (t : D),
      phi ∈ family.mcs t ∧
      truth_at (canonical_model D family) (canonical_history_family D family) t phi
```

This establishes the foundation for completeness: **consistent formulas are satisfiable in a parametric canonical model**.

#### Completeness Hierarchy (Theories/Bimodal/Metalogic/Completeness/)

**Status**: All completeness variants proven. Soundness axiomatized pending Boneyard port.

| Result | Status | Location |
|--------|--------|----------|
| **weak_completeness** | ✅ PROVEN | WeakCompleteness.lean |
| **finite_strong_completeness** | ✅ PROVEN | FiniteStrongCompleteness.lean |
| **infinitary_strong_completeness** | ✅ PROVEN | InfinitaryStrongCompleteness.lean |
| **provable_iff_valid** | ✅ PROVEN (soundness axiom) | WeakCompleteness.lean |
| **semantic_weak_completeness** | ✅ PROVEN (sorry-free) | WeakCompleteness.lean |

**Note**: `semantic_weak_completeness` provides sorry-free completeness via direct construction without relying on the soundness axiom. Use this for maximum proof integrity.

#### Compactness (Theories/Bimodal/Metalogic/Compactness/)

**Status**: Fully proven, sorry-free.

| Result | Status | Location |
|--------|--------|----------|
| **compactness** | ✅ PROVEN | Compactness.lean |
| **compactness_iff** | ✅ PROVEN | Compactness.lean |
| **compactness_entailment** | ✅ PROVEN | Compactness.lean |
| **compactness_unsatisfiability** | ✅ PROVEN | Compactness.lean |

**Architecture**: Compactness derives from finitary strong completeness. Since any derivation uses only finitely many premises, semantic entailment by an infinite set implies derivability from a finite subset.

#### CoherentConstruction Approach (Theories/Bimodal/Metalogic/Representation/)

**Status**: Core proven, coherence cases have documented gaps.

The CoherentConstruction module replaces the original `construct_indexed_family` approach with a cleaner architecture:

1. **Two-chain design**: Forward chain (times > 0) and backward chain (times < 0) constructed from origin (time 0)
2. **Definitional coherence**: Coherence conditions (G/H persistence) hold by construction, not proved after the fact
3. **Minimal requirements**: Only Cases 1 and 4 needed for completeness theorem

| Component | Status | Notes |
|-----------|--------|-------|
| Origin MCS | ✅ PROVEN | Lindenbaum extension of seed |
| Forward chain | ✅ PROVEN | G-persistence definitional |
| Backward chain | ✅ PROVEN | H-persistence definitional |
| Cross-origin coherence | 🟡 PARTIAL | Cases 2,3 have documented gaps |
| Completeness integration | ✅ PROVEN | Uses only Cases 1,4 |

**Why cross-origin gaps don't matter**: The representation theorem and completeness proofs only require coherence for times on the same side of the origin. Cross-origin cases (e.g., showing G-persistence from t<0 to t>0) are not on the critical path.

#### Algebraic Approach (Theories/Bimodal/Metalogic/Algebraic/)

**Status**: Partial, provides independent verification path.

An alternative approach using Boolean algebra with modal operators:

| Component | Status | Location |
|-----------|--------|----------|
| Lindenbaum-Tarski quotient | ✅ DEFINED | QuotientAlgebra.lean |
| Boolean algebra structure | ✅ PROVEN | BooleanStructure.lean |
| Interior operators (G/H) | 🟡 PARTIAL | ModalOperators.lean |
| Ultrafilter correspondence | 🟡 PARTIAL | UltrafilterMCS.lean |

**Purpose**: Provides algebraic characterization of the logic, enabling different proof techniques. Can be used to verify Kripke semantics results via Stone duality.

---

### Syntax and Semantics

| Component | Status | Location |
|-----------|--------|----------|
| **Bimodal Syntax** | COMPLETE | Theories/Bimodal/Basic.lean |
| **TM Semantics** | COMPLETE | Theories/Bimodal/Semantics.lean |
| **Proof System** | COMPLETE | Theories/Bimodal/Proof.lean |

### Decidability Infrastructure (Boneyard)

**Status**: DEPRECATED. Complete tableau-based decision procedure in `Boneyard/Metalogic_v2/Decidability/` (tableau, saturation, branch closure, soundness). Superseded by `semantic_weak_completeness` which provides sorry-free completeness via parametric FMP approach. See Dead Ends section for rationale.

---

## Phase 0: Complete Core Proofs (High Priority)

**Goal**: Finish the main proof by eliminating sorries and porting proven elements from the Boneyard.

### 0.1 Audit Current Sorries

**Tasks**:
- [x] Audit `Theories/Bimodal/Metalogic/` for sorries *(~29 sorries identified, see Task 758)*
- [x] Categorize by difficulty and dependency *(blocking/biconditional/exploratory categories)*
- [x] Prioritize which sorries block main theorem path *(0 on critical path - representation_theorem is sorry-free)*

### 0.2 Port from Boneyard

**Tasks**:
- [ ] Review `Boneyard/Metalogic_v2/Core/` for reusable elements
- [ ] Evaluate DeductionTheorem.lean compatibility
- [ ] Evaluate MaximalConsistent.lean compatibility
- [ ] Port applicable proofs to active Metalogic directory

### 0.3 Decidability Decision

**Status**: Decision made - Boneyard decidability DEPRECATED, new FMP approach in progress.

**Tasks**:
- [x] Decide: deprecate or resurrect `Decidability/` infrastructure *(DEPRECATED)*
- [x] If deprecating: update roadmap to reflect this *(this revision)*

**Resolution**:
- **Boneyard/Metalogic_v2/Decidability/**: DEPRECATED. Code preserved for historical reference.
- **New approach**: Parametric FMP infrastructure in `Metalogic/FMP/` provides finite model construction.
- **Practical impact**: `semantic_weak_completeness` provides sorry-free completeness without full decidability proof.
- **Future option**: Full decidability via FMP path (Task 755) remains available if needed.

### 0.4 Document Inventory

**Tasks**:
- [x] Create sorry-free theorem inventory *(README hierarchy created in Task 747)*
- [x] Update ROAD_MAP tables with verified status *(this revision, Task 748)*
- [x] Document proof dependencies clearly *(each subdirectory README documents module dependencies)*

---

## Phase 1: Proof Quality and Organization (High Priority)

**Goal**: Improve proof economy, flow, and readability. Make it easy to understand the "story" of the development.

### 1.1 Proof Economy Improvements

#### Issue: Redundant Proofs
Several results are proven multiple ways or with unnecessary complexity.

**Tasks**:
- [ ] **Audit proof dependencies**: Map which lemmas are actually used vs. proven for completeness
- [ ] **Identify redundant paths**: E.g., do we need both `representation_theorem` and `semantic_weak_completeness`?
- [ ] **Consolidate**: Keep the most direct proof, move alternatives to a "Alternative Proofs" section or remove
- [ ] **Measure proof size**: Track total proof lines, aim for 20% reduction

**Expected Impact**:
- Faster builds
- Easier maintenance
- Clearer dependency structure

#### Issue: Verbose Tactics
Many proofs use explicit sequences where automation could apply.

**Tasks**:
- [ ] **Identify automation opportunities**: Look for `intro; apply; exact` sequences
- [ ] **Create domain-specific tactics**: E.g., `mcs_tac` for MCS reasoning
- [ ] **Add helpful `simp` lemmas**: Reduce manual rewriting
- [ ] **Document tactic patterns**: When to use `aesop` vs `omega` vs manual

**Example Improvement**:
```lean
-- Before (15 lines)
theorem mcs_contains_or_neg (M : Set Formula) (h : SetMaximalConsistent M) (φ : Formula) :
    φ ∈ M ∨ φ.neg ∈ M := by
  by_cases h_in : φ ∈ M
  · left; exact h_in
  · right
    have h_cons := h.2.1
    have h_max := h.2.2
    ... [10 more lines]

-- After (5 lines)
theorem mcs_contains_or_neg (M : Set Formula) (h : SetMaximalConsistent M) (φ : Formula) :
    φ ∈ M ∨ φ.neg ∈ M := by
  by_cases h_in : φ ∈ M <;> [left; exact h_in, right; mcs_tac]
```

### 1.2 Proof Flow Optimization

#### Issue: Non-linear Dependencies
Some modules import from multiple layers, creating cognitive overhead.

**Tasks**:
- [x] **Visualize import graph**: Generate dependency diagram *(Metalogic/README.md contains architecture diagram)*
- [x] **Identify cross-cutting imports**: Layer discipline enforced: Core < Representation < Completeness < Compactness
- [ ] **Refactor into utilities**: Extract common patterns into a `Metalogic.Util` module
- [x] **Enforce layer discipline**: Each layer only imports from layers below *(strict layering documented in subdirectory READMEs)*

**Target Structure**:
```
Util/ (cross-cutting utilities, no layer violations)
├── MCS.lean          # MCS reasoning tactics
├── Closure.lean      # Closure manipulation
└── Derivation.lean   # Derivation tree helpers

Core/ → Util/
Soundness/ → Core/, Util/
Representation/ → Soundness/, Core/, Util/
Completeness/ → Representation/, Util/
Applications/ → Completeness/, Util/
```

#### Issue: Proof Order Within Files
Some files prove lemmas after they're used, requiring forward declarations.

**Tasks**:
- [ ] **Reorder definitions**: Place helpers before main theorems
- [ ] **Create sections**: Group related lemmas with section headers
- [ ] **Add roadmap comments**: Start each file with "This file proves: X, Y, Z in that order"

### 1.3 Documentation and Storytelling

#### Issue: Hard to See the Big Picture
Individual proofs are documented, but the overall narrative is unclear.

**Tasks**:
- [ ] **Create proof architecture guide**: `docs/architecture/proof-structure.md`
- [x] **Add module overviews**: Each subdirectory has README.md with module-by-module overview *(Task 747)*
- [ ] **Cross-reference theorems**: Link related results with `See also: theorem_name`
- [ ] **Write tutorial**: `docs/tutorials/metalogic-walkthrough.md` explaining the proof strategy

**Tutorial Outline**:
1. The Goal: Soundness and Completeness
2. The Strategy: Canonical Models
3. The Foundation: MCS and Lindenbaum
4. The Construction: Building the Canonical Model
5. The Proof: Truth Lemma and Representation
6. The Applications: Decidability and Compactness

---

<!-- TODO: Draw on the algebraic methods (approach 4 in /home/benjamin/Projects/ProofChecker/specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-003.md) to set out the ambition to establish the representation theorem purely algebraically, providing a more elegant proof -->

## Phase 2: Generalization (Medium Priority)

**Goal**: Strengthen results from specific to general, finite to infinite.

### 2.1 Strong Completeness Enhancements

**Current**: `Γ ⊨ φ → Γ ⊢ φ` is proven for list-based contexts (Context = List Formula)

**Generalization Opportunities**:

#### A. Set-Based Strong Completeness ✅ COMPLETED

**Status**: Implemented as `infinitary_strong_completeness` in Completeness/InfinitaryStrongCompleteness.lean

```lean
theorem infinitary_strong_completeness (Γ : Set Formula) (φ : Formula) :
    (∀ D F M τ t, (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ) →
    ∃ Δ : Finset Formula, (↑Δ ⊆ Γ) ∧ ListDerivable Δ.toList φ
```

**Tasks**:
- [x] Define set-based derivability
- [x] Prove infinitary strong completeness via compactness
- [x] Show finite subset suffices (compactness argument)

**Impact**: Complete generalization to infinite premise sets achieved

#### B. Constructive Completeness
Make completeness constructive where possible:
```lean
def complete_decision (φ : Formula) :
    (⊢ φ) ⊕ (∃ M τ t, ¬truth_at M τ t φ) :=
  ...
```

**Tasks**:
- [ ] Identify which parts of completeness proof are constructive
- [ ] Replace `Classical.choice` with explicit constructions where possible
- [ ] Document remaining uses of classical reasoning

**Impact**: Stronger results, potential for proof extraction

### 2.2 Infinite Model Results

**Current**: FMP establishes finite models suffice. But what about infinite models?

**Extension Opportunities**:

#### A. Infinite Compactness
Prove compactness for infinite sets:
```lean
theorem infinite_compactness (Γ : Set Formula) :
    (∀ Δ : Finset Formula, ↑Δ ⊆ Γ → context_satisfiable Δ.toList) →
    ∃ D F M τ t, ∀ φ ∈ Γ, truth_at M τ t φ
```

**Tasks**:
- [ ] Define ultrafilter construction or limit construction
- [ ] Prove transfer lemmas for truth preservation
- [ ] Connect to finite compactness via FMP

**Impact**: Handles countably infinite theories, aligns with standard model theory

#### B. Löwenheim-Skolem for TM
Prove downward Löwenheim-Skolem:
```lean
theorem lowenheim_skolem (Γ : Set Formula) :
    (∃ M, ∀ φ ∈ Γ, truth_at M φ) →
    (∃ M_countable, ∀ φ ∈ Γ, truth_at M_countable φ)
```

**Tasks**:
- [ ] Identify the cardinality bounds from FMP
- [ ] Show countable language → countable models
- [ ] Connect to Henkin construction

**Impact**: Classic model theory result for TM logic

### 2.3 Modular Frame Properties

**Current**: Results are for TM logic specifically (time domain = ordered additive monoid)

**Generalization Opportunity**:
Parameterize by frame class:
```lean
class FrameClass (F : Type → Type) where
  validates : Formula → F → Prop
  soundness : ∀ φ F, validates φ F → F ⊨ φ

theorem completeness_for_frame_class [FC : FrameClass F] :
    (∀ F, FC.validates φ F → F ⊨ φ) → ⊢_FC φ
```

**Tasks**:
- [ ] Define frame property interface
- [ ] Parameterize canonical model by frame properties
- [ ] Prove completeness relative to frame classes (K, T, S4, S5)

**Impact**:
- Reusable for other modal logics
- Clear separation of logic vs frame properties
- Easier to add new logics

---

## Phase 3: Extensions (Medium Priority)

**Goal**: Add natural corollaries and related results to make a comprehensive package.

### 3.1 Metalogical Extensions

#### A. Craig Interpolation
If `⊢ φ → ψ`, then `∃ θ` such that `Var(θ) ⊆ Var(φ) ∩ Var(ψ)` and `⊢ φ → θ` and `⊢ θ → ψ`.

**Status**: Not started
**Difficulty**: Medium (requires proof analysis)
**Value**: High (classic logic result)

**Tasks**:
- [ ] Define propositional variables for formulas
- [ ] Implement interpolant extraction from derivation
- [ ] Prove correctness

#### B. Beth Definability
If `φ` implicitly defines `p`, then it explicitly defines `p`.

**Status**: Not started
**Difficulty**: Medium-High
**Value**: Medium (completes the "big three" of modal model theory)

**Tasks**:
- [ ] Define implicit vs explicit definability
- [ ] Prove via ultraproduct or amalgamation
- [ ] Document relationship to interpolation

#### C. Separation Properties
Modal separation: if `φ` and `ψ` are not provably equivalent, they're distinguishable by a model.

**Status**: Follows from completeness
**Difficulty**: Low
**Value**: Low (corollary)

**Tasks**:
- [ ] State formally
- [ ] Prove from completeness in 5 lines
- [ ] Add as application

### 3.2 Decidability Extensions

#### A. Complexity Bounds
Establish complexity class for TM satisfiability.

**Status**: Partial (decidability proven, complexity not analyzed)
**Difficulty**: Medium
**Value**: High (for practical applications)

**Tasks**:
- [ ] Analyze FMP bound: `2^|closure(φ)|`
- [ ] Count model enumeration complexity
- [ ] Establish PSPACE upper bound (likely)
- [ ] Compare to other modal logics (K is PSPACE-complete)

**Expected Result**: TM satisfiability is in PSPACE

#### B. Proof Search Strategy
Optimize the decision procedure for practical use.

**Status**: Basic tableau exists, not optimized
**Difficulty**: Medium
**Value**: Medium-High (for verification)

**Tasks**:
- [ ] Implement heuristics (clause learning, backjumping)
- [ ] Add caching for repeated subproblems
- [ ] Benchmark against standard modal logic solvers
- [ ] Document performance characteristics

#### C. Countermodel Minimization
Find smallest countermodel when formula is invalid.

**Status**: Basic extraction exists
**Difficulty**: Low-Medium
**Value**: Medium (for user feedback)

**Tasks**:
- [ ] Implement state minimization
- [ ] Prove minimality
- [ ] Add user-friendly countermodel display

### 3.3 Temporal Logic Extensions

#### A. Until/Since Operators
Extend to full LTL with U and S.

**Status**: Not started
**Difficulty**: High (new operators require new axioms)
**Value**: High (full LTL is important)

**Tasks**:
- [ ] Add `until` and `since` to syntax
- [ ] Define semantics
- [ ] Add axioms (expansion laws)
- [ ] Prove completeness (will require extending canonical model)

**Note**: This is a significant extension requiring Phase 1 work first

#### B. Branching Time (CTL)
Add path quantifiers A and E.

**Status**: Not started
**Difficulty**: Very High (requires new semantic framework)
**Value**: Very High (important for verification)

**Tasks**:
- [ ] Design tree semantics
- [ ] Add path quantifiers
- [ ] Prove completeness (challenging!)
- [ ] Integrate with TM fragment

**Note**: This is a research-level extension

### 3.4 Epistemic Extensions

#### A. S5 Epistemic Logic
Instantiate the framework for knowledge (S5 modality).

**Status**: Framework supports it, not instantiated
**Difficulty**: Low-Medium
**Value**: Medium (common in verification)

**Tasks**:
- [ ] Define S5 frame class (equivalence relation)
- [ ] Instantiate canonical model for S5
- [ ] Prove S5-completeness as instance of general theorem
- [ ] Add common knowledge operator

#### B. Distributed Knowledge
Add D operator for distributed knowledge.

**Status**: Not started
**Difficulty**: Medium
**Value**: Medium (for multi-agent systems)

**Tasks**:
- [ ] Define intersection semantics
- [ ] Add axioms
- [ ] Prove completeness

---

## Phase 4: Architecture Optimization (High Priority)

**Goal**: Restructure to maximize efficiency, economy, and reusability.

### 4.1 The Optimal Layering

#### Current Structure Issues
1. **Representation depends on Soundness**: Unnecessary coupling
2. **FMP is a separate layer**: Could be integrated
3. **Decidability is parallel**: Could be better integrated

#### Proposed Optimal Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATIONS                             │
│  Interpolation, Separation, Complexity Bounds               │
└─────────────────────────────────────────────────────────────┘
                            ▲
┌─────────────────────────────────────────────────────────────┐
│                META-THEOREMS (Top Layer)                    │
│  Compactness, Decidability, FMP (as corollaries)            │
└─────────────────────────────────────────────────────────────┘
                            ▲
┌─────────────────────────────────────────────────────────────┐
│              SOUNDNESS-COMPLETENESS                         │
│  ┌──────────────┐              ┌──────────────┐            │
│  │  Soundness   │              │ Completeness │            │
│  │  (Γ ⊢ φ → Γ ⊨ φ) ◄────────► │ (Γ ⊨ φ → Γ ⊢ φ)            │
│  └──────────────┘              └──────────────┘            │
│         │                              ▲                    │
│         │                              │                    │
│         └──────────┬───────────────────┘                    │
│                    ▼                                        │
│         ┌─────────────────────┐                            │
│         │  Representation     │                            │
│         │  (Canonical Model)  │                            │
│         └─────────────────────┘                            │
└─────────────────────────────────────────────────────────────┘
                            ▲
┌─────────────────────────────────────────────────────────────┐
│                      CORE                                   │
│  Deduction Theorem, Lindenbaum, MCS Properties             │
└─────────────────────────────────────────────────────────────┘
                            ▲
┌─────────────────────────────────────────────────────────────┐
│                   FOUNDATIONS                               │
│  Syntax, Semantics, Proof System                           │
└─────────────────────────────────────────────────────────────┘
```

#### Key Changes
1. **Merge Soundness into Soundness-Completeness layer**: They're dual results
2. **Make FMP a corollary**: Derive from completeness + finiteness of formulas
3. **Decidability as application**: Not fundamental, but derived
4. **Representation as bridge**: The key technical component

### 4.2 The Minimal Kernel

**Goal**: Identify the smallest set of results needed for all others.

#### Kernel Candidates

**Option A: Deduction + MCS + Canonical Model**
```
Kernel = {
  deduction_theorem,
  set_lindenbaum,
  mcs_properties,
  canonical_model_construction,
  truth_lemma
}

Derivable = {
  soundness (by induction),
  completeness (via contrapositive + canonical),
  FMP (finiteness of closure),
  decidability (FMP + enumeration),
  compactness (finiteness of derivations)
}
```

**Option B: Representation Theorem Alone**
```
Kernel = {
  representation_theorem : Consistent Γ ↔ CanonicalSatisfiable Γ
}

Derivable = {
  soundness (trivial from semantics),
  completeness (contrapositive of representation),
  everything else from completeness
}
```

#### Recommendation
**Use Option B**: The representation theorem is the true core. Everything else is a corollary.

**Implementation Tasks**:
- [x] Refactor to make `representation_theorem` the primary export *(Metalogic architecture: Representation/ provides foundation, Completeness/ derives from it)*
- [x] Recast soundness/completeness as corollaries *(Completeness/ directory derives weak/finite/infinitary from Representation)*
- [x] Document the one-line derivations *(README hierarchy documents theorem dependencies)*
- [ ] Measure proof economy improvement

**Expected Impact**:
- 30-40% reduction in "fundamental" proofs
- Clearer story: "We build canonical models, everything follows"
- Easier to extend to other logics

### 4.3 Proof Reuse Infrastructure

#### Current Issue
Many similar proofs (e.g., each modal operator needs similar treatment in truth lemma).

#### Solution: Generic Proof Framework

**Create operator classes**:
```lean
class ModalOperator (op : Formula → Formula) where
  axiom_scheme : Formula
  frame_property : Frame → Prop
  truth_condition : ∀ M w φ, M ⊨ op φ at w ↔ ...

-- Then prove once:
theorem truth_lemma_for_operator [ModalOperator op] : ...

-- Instantiate:
instance : ModalOperator box where ...
instance : ModalOperator diamond where ...
instance : ModalOperator all_future where ...
```

**Tasks**:
- [ ] Design operator typeclass hierarchy
- [ ] Prove generic truth lemma
- [ ] Instantiate for each operator
- [ ] Measure proof reuse (expect 3-4x code reduction)

**Expected Impact**:
- DRY principle for modal operators
- Easy to add new operators
- Proofs become operator-generic

---

## Phase 5: Managing Remaining Sorries (Low Priority)

**Goal**: Document and selectively eliminate sorries based on criticality.

**Current State** (as of 2026-01-29): ~29 sorries in Metalogic/ (excluding Boneyard)

### 5.1 Sorry Distribution by Directory

| Directory | Count | Category | Notes |
|-----------|-------|----------|-------|
| Representation/ | ~17 | Mixed | CoherentConstruction (~10), TaskRelation (~5), IndexedMCSFamily (~2 SUPERSEDED) |
| FMP/ | ~3 | Non-blocking | Truth bridge gaps, documented workaround |
| Completeness/ | 1 | Axiom | Soundness axiomatized, pending Boneyard fix |
| Algebraic/ | ~8 | Independent | Alternative path, not on critical path |
| Compactness/ | 0 | **Sorry-free** | Fully proven |
| Core/ | 0 | **Sorry-free** | Re-exports proven code |

### 5.2 Criticality Assessment

| Category | Count | Impact | Recommendation |
|----------|-------|--------|----------------|
| **Blocking main theorem** | 0 | Critical | N/A - `representation_theorem` is sorry-free |
| **Biconditional completion** | ~5 | Medium | Optional - `semantic_weak_completeness` provides sorry-free path |
| **Exploratory/Independent** | ~24 | Low | Document, address opportunistically |

### 5.3 Recommended Actions

#### CoherentConstruction Sorries (Task 753)
**Status**: In progress
**Recommendation**: Focus on infrastructure sorries (sigma-type refactoring). Cross-origin coherence gaps are non-critical.

#### TaskRelation Compositionality
**Recommendation**: Document as architectural limitation.
**Reason**: Fundamental issue with task relation semantics. Completeness doesn't require it.

#### FMP Truth Bridge
**Recommendation**: Use `semantic_weak_completeness` instead.
**Reason**: Sorry-free completeness available via algebraic path.

#### Soundness Axiom (Completeness/WeakCompleteness.lean)
**Recommendation**: Port soundness proof from Boneyard.
**Reason**: Low-hanging fruit once Boneyard infrastructure is adapted to current semantics.

#### Algebraic Sorries
**Recommendation**: Complete independently as algebraic alternative.
**Reason**: Provides dual verification path, not blocking main results.

---

## Phase 6: Polish and Publication (Low Priority Now, High Later)

**Goal**: Prepare for external consumption (paper, library, tools).

### 6.1 Documentation for Publication

**Tasks**:
- [x] Write comprehensive README *(Metalogic/README.md + 6 subdirectory READMEs - Task 747)*
- [x] Create API documentation *(docs/reference/API_REFERENCE.md - 720 lines)*
- [x] Add usage examples *(API_REFERENCE.md includes usage examples)*
- [ ] Write paper draft (if academic publication desired)

### 6.2 Performance Optimization

**Tasks**:
- [ ] Profile build times
- [ ] Optimize slow proofs
- [ ] Parallelize independent proofs
- [ ] Cache expensive computations

### 6.3 Testing and Validation

**Tasks**:
- [x] Create test suite for each major theorem *(Tests/ directory with test files for Core, Completeness, FMP, Representation)*
- [ ] Add property-based tests
- [ ] Benchmark against standard examples
- [ ] Validate against known results from literature

---

## Recommended Execution Order

### Near Term (Next 2-4 weeks)
1. **Phase 1.2**: Proof flow optimization - clean up the architecture
2. **Phase 1.3**: Documentation - add overviews and tutorials
3. **Phase 4.1**: Optimal layering - restructure for efficiency

**Why**: These improve understandability and maintainability, making all future work easier.

### Medium Term (1-3 months)
1. **Phase 1.1**: Proof economy - reduce redundancy
2. **Phase 2.1.A**: Set-based strong completeness
3. **Phase 3.1.A**: Craig interpolation
4. **Phase 4.2**: Minimal kernel - refactor around representation theorem

**Why**: Strengthens the core results and makes the package publication-ready.

### Long Term (3-6 months)
1. **Phase 2.3**: Modular frame properties - generalize the framework
2. **Phase 3.2**: Decidability extensions - make it practical
3. **Phase 3.3.A**: Until/Since operators - extend to full LTL
4. **Phase 6**: Polish and publication

**Why**: These are significant extensions that build on a solid foundation.

---

## Success Metrics

### Proof Quality Metrics
- **Lines of proof code**: Target 20% reduction through economy improvements
- **Average proof depth**: Target <10 for major theorems
- **Redundancy ratio**: <5% of proofs should be redundant
- **Build time**: <2 minutes for full build

### Coverage Metrics
- **Core results**: 100% (already achieved)
- **Standard metatheorems**: 80% (need interpolation, Beth, complexity)
- **Extensions**: 50% (temporal operators, epistemic logic)

### Architecture Metrics
- **Layer violations**: 0 (enforce strict layering)
- **Import cycles**: 0 (already achieved)
- **Proof reuse**: 60% of operator-specific proofs should be instances of generic framework

### Documentation Metrics
- **API coverage**: 100% of public theorems documented
- **Tutorial coverage**: All major proof strategies explained
- **Example coverage**: 10+ worked examples

---

## Open Questions

### Theoretical
1. **Is TM logic PSPACE-complete?** (decidability complexity)
2. **Does interpolation hold for TM?** (likely yes, but needs proof)
3. **What's the best frame class abstraction?** (for modular completeness)

### Implementation
1. **Should we use typeclasses or instances for modal operators?**
2. **How fine-grained should proof modules be?**
3. **Should decidability be computable or just decidable?**

### Strategic
1. **Target audience**: Research tool or verification platform?
2. **Publication venue**: Conference (LICS, CADE) or journal (JSL)?
3. **Interoperability**: Should we support import/export to other provers?

---

## Conclusion

The ProofChecker project has achieved its primary goal: a clean, proven metalogic for TM bimodal logic. The current Metalogic architecture is solid with:

**Major Achievements**:
- **Representation theorem**: Sorry-free, establishes that consistent formulas are satisfiable
- **Completeness hierarchy**: Weak, finite strong, and infinitary strong completeness all proven
- **Compactness**: Fully proven, sorry-free
- **Sorry-free completeness path**: `semantic_weak_completeness` provides completeness without relying on axiomatized soundness

**The path forward** focuses on three pillars:
1. **Quality**: Improving proof economy and organization (Phase 1, 4)
2. **Generalization**: Extending to new domains (Phase 2 partially complete, Phase 3)
3. **Accessibility**: Better documentation and tooling (Phase 6 substantially complete)

The recommended approach is to **consolidate before extending**: complete Phases 1 and 4 (organization and architecture) before embarking on major extensions. This ensures a solid foundation that makes future work easier and more maintainable.

**Key Insight**: The representation theorem is the core. Everything else—soundness, completeness, FMP, decidability, compactness—flows naturally from it. The Completeness Hierarchy and Compactness achievements demonstrate this principle in action.
