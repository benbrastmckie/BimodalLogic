# ProofChecker Development Roadmap

**Last Updated**: 2026-02-26
**Status**: FMP Completeness Sorry-Free, Bundle Completeness (3 sorries in Int-indexed construction), Boneyard Cleanup Complete

> **Content Boundaries**: ROAD_MAP.md = strategic vision (months-years), TODO.md = task queue (days-weeks), task artifacts = execution details (hours-days).
> Each entry should include *Rationale* (why) and *References* (learn more).

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
- [Representation.lean](Theories/Bimodal/Metalogic/Representation.lean) - Current BFMCS-based entry point
- [Task 654 research](specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-003.md) - Approach analysis
- [Boneyard archive](Theories/Bimodal/Boneyard/Metalogic_v5/Representation/) - Archived original files

*Note*: Sorry-free completeness is now via the FMP approach (`FMP/SemanticCanonicalModel.lean`), not the archived Representation module.

---

### Strategy: Indexed MCS Family Approach

**Status**: ACTIVE
**Started**: 2025-12-15
**Hypothesis**: Using a family of MCSs indexed by time (fmcs : D -> Set Formula) with temporal coherence conditions matches REFLEXIVE G/H semantics with T-axioms (Gφ → φ, Hφ → φ) enabling coherence proofs.

*Rationale*: TM's G/H operators use REFLEXIVE semantics (present + future/past, inclusive). A family-based approach captures this structure, with each time point having its own MCS connected via temporal coherence conditions (using ≤, not <).

**Approach**:
Design uses a family of MCS indexed by time, where coherence conditions (forward_G, backward_H, forward_H, backward_G) connect time points. These conditions use reflexive inequalities (≤); T-axioms are valid and used in coherence proofs.

**Outcomes**:
- Representation theorem proven with T-axiom validity via reflexivity
- Task relation (canonical_history_family_respects) proven
- Truth lemma for temporal operators proven
- Documented gaps in backward truth lemma cases (non-blocking)

**References**:
- [FMCSDef.lean](Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean) - Current FMCS structure (reflexive ≤ coherence)
- [TruthLemma.lean](Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean) - Current truth lemma
- [Boneyard/IndexedMCSFamily.lean](Theories/Bimodal/Boneyard/Metalogic_v5/Representation/IndexedMCSFamily.lean) - Archived original (strict <)

---

### Strategy: CoherentConstruction Two-Chain Design

**Status**: SUPERSEDED
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
- [Boneyard/CoherentConstruction.lean](Theories/Bimodal/Boneyard/Metalogic_v5/Representation/CoherentConstruction.lean) - Archived two-chain implementation
- [DovetailingChain.lean](Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean) - Current replacement (dovetailing approach)
- [Task 808 research](specs/archive/808_audit_coherentconstruction_taskrelation_sorries/) - Analysis

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
- [x] FMP completeness sorry-free
- [x] No blocking sorries on main theorem paths (FMP path is clear)
- [x] Documented sorry debt policy enforced
- [ ] Bundle completeness sorry-free (3 sorries remain in DovetailingChain/TemporalCoherentConstruction)

**Description**:
Systematically reduce sorries in the Metalogic module through proof completion, alternative constructions, or explicit documentation as intentional gaps.

**Related Phases**: Phase 1 (Proof Quality), Phase 5 (Managing Sorries)
**References**:
- [proof-debt-policy.md](.claude/context/project/lean4/standards/proof-debt-policy.md) - Proof debt management (sorries + axioms)
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
- [Boneyard/Metalogic_v2/Decidability/](Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/) - Archived implementation
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
- [Task 825 research](specs/archive/825_fdsm_multi_history_modal_saturation/reports/research-001.md) - Analysis of trivialization
- Archived fdsm_from_closure_mcs attempt

**Lesson**:
Multi-history saturation is required for non-trivial modalities in TM logic. Single-history approaches trivialize modal operators.

**Superseded By**: Indexed MCS Family approach with multiple histories

---

### Dead End: Cross-Origin Coherence Proofs

**Status**: BLOCKED
**Tried**: 2026-01-15 to 2026-01-20
**Related Tasks**: Task 808

*Rationale*: Attempted to prove coherence across different MCS origins (e.g., showing G-persistence from t<0 to t>0) for completeness of the CoherentConstruction approach.

**What We Tried**:
Proved Cases 1 and 4 of coherence conditions (same-side of origin). Attempted Cases 2 and 3 (cross-origin) to complete the full coherence proof.

**Why It Failed**:
Cases 2 and 3 are not on the critical path for completeness. The representation theorem and completeness proofs only require coherence for times on the same side of the origin.

**Evidence**:
- [Boneyard/CoherentConstruction.lean](Theories/Bimodal/Boneyard/Bundle/CoherentConstruction.lean) - Documented sorries for Cases 2,3
- [Task 808 research](specs/archive/808_audit_coherentconstruction_taskrelation_sorries/) - Analysis

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
- [Task 808 research](specs/archive/808_audit_coherentconstruction_taskrelation_sorries/) - Two-chain design benefits

**Lesson**:
When proofs are hard, consider whether the definition can be restructured to make properties hold by construction rather than by proof.

**Superseded By**: CoherentConstruction module with two-chain design

---

### Dead End: CanonicalReachable/CanonicalQuotient Stack

**Status**: SUPERSEDED
**Tried**: 2026-01-15 to 2026-02-26
**Related Tasks**: Task 922, 923, 933

*Rationale*: Attempted to build Int-indexed temporal domain via quotient of future-reachable MCS subset.

**What We Tried**:
Built CanonicalReachable (future-reachable MCS from origin), CanonicalQuotient (Antisymmetrization for LinearOrder), and CanonicalEmbedding (infrastructure for Int embedding).

**Why It Failed**:
backward_P witnesses are not necessarily future-reachable from the origin MCS. Past witnesses exist in CanonicalMCS but may not be in the future-reachable subset, making temporal coherence impossible.

**Evidence**:
- [Boneyard/Bundle/CanonicalQuotientApproach/](Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/) - Archived implementation
- [Task 933 research](specs/933_research_alternative_canonical_construction/reports/research-001.md) - Analysis

**Lesson**:
Future-reachability is insufficient for temporal completeness. Must use all MCS or accept non-Int domain.

**Superseded By**: canonicalMCSBFMCS (all-MCS approach) with sorry-free forward_F/backward_P

---

### Dead End: MCS-Membership Semantics for Box

**Status**: ABANDONED
**Tried**: 2026-02-20 to 2026-02-25
**Related Tasks**: Task 925, 931

*Rationale*: Attempted alternative box semantics where Box phi holds iff phi is in all accessible MCS (membership test rather than recursive truth).

**What We Tried**:
Defined `bmcs_truth_at_mcs` where box case checks MCS membership directly instead of recursive `bmcs_truth_at`. Proved completeness relative to this modified semantics.

**Why It Failed**:
The two semantics (`bmcs_truth_at` vs `bmcs_truth_at_mcs`) are not equivalent. Completeness relative to MCS-membership semantics doesn't imply completeness relative to standard Kripke truth, creating a gap between soundness and completeness.

**Evidence**:
- [Boneyard/Bundle/MCSMembershipCompleteness.lean](Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean) - Archived implementation
- [Task 931 summary](specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/summaries/implementation-summary-20260225.md)

**Lesson**:
Completeness must use the same validity notion as soundness. Non-standard semantics create equivalence gaps.

**Superseded By**: Standard recursive `bmcs_truth_at` definition

---

### Dead End: Constant Witness Family Approach

**Status**: ABANDONED
**Tried**: 2026-01-20 to 2026-02-25
**Related Tasks**: Task 932

*Rationale*: Attempted modal saturation using constant witness families (same MCS at all time points).

**What We Tried**:
For Diamond(psi) obligations, created witness families where `fam.mcs(t) = W` for all t, where W is the witness MCS containing psi.

**Why It Failed**:
Constant families cannot satisfy forward_F or backward_P. An F-obligation F(psi) requires psi to hold at some future time, but a constant family has the same MCS at all times - there's no "future" where psi can be placed without it already being present everywhere.

**Evidence**:
- [Boneyard/Metalogic_v7/Bundle/ConstantWitnessFamily_ModalSaturation.lean](Theories/Bimodal/Boneyard/Metalogic_v7/Bundle/) - Archived
- [Task 932 summary](specs/932_remove_constant_witness_family_metalogic/summaries/implementation-summary-20260225.md)

**Lesson**:
Temporal saturation requires time-varying families. Witnesses must be placed at specific times, not everywhere.

**Superseded By**: DovetailingChain (time-varying family construction)

---

### Dead End: Single-Family BFMCS modal_backward

**Status**: BLOCKED
**Tried**: 2026-01-25 to 2026-02-25
**Related Tasks**: Task 905, 928

*Rationale*: Attempted to prove modal_backward for single-family BFMCS (bundles containing only one temporal family).

**What We Tried**:
For a single-family bundle, modal_backward reduces to: "if phi holds in the single family's MCS, then Box(phi) holds". This is `phi ∈ MCS → Box(phi) ∈ MCS`.

**Why It Failed**:
This requires `phi → Box(phi)` (the converse of the T-axiom `Box(phi) → phi`), which TM logic does not have. Without this principle, we cannot derive Box(phi) from phi alone. The modal_backward condition requires MULTIPLE families to witness the universal quantification.

**Evidence**:
- [Task 905 research](specs/archive/) - Proof of impossibility
- [Boneyard/Metalogic_v7/Bundle/](Theories/Bimodal/Boneyard/Metalogic_v7/Bundle/) - Single-family attempts

**Lesson**:
Multi-family bundles are essential for modal completeness without T-axiom. Single-family simplification is a dead end.

**Superseded By**: Multi-family BFMCS with modal saturation

---

## Overview

This roadmap outlines the current state of the ProofChecker project and charts the path forward for:
1. **Proof Quality**: Improving economy, flow, and organization
2. **Generalization**: From weak to strong results, finite to infinite
3. **Extension**: Adding natural corollaries and applications
4. **Architecture**: Optimal structure for efficiency and reusability

---

## Current State: What's Been Accomplished

*Last audited: 2026-02-26*

### Current Architecture: BFMCS + FMP Completeness

The active metalogic is in `Theories/Bimodal/Metalogic/`. Two **sorry-free** completeness approaches are available:

#### 1. BFMCS Completeness (Bundle/Completeness.lean)

**Status**: SORRY-FREE for main theorems. 3 sorries in Int-indexed construction infrastructure.

The **Bundle of Families of Maximal Consistent Sets (BFMCS)** approach is a Henkin-style completeness proof that resolves the modal completeness obstruction present in traditional canonical model approaches.

| Theorem | Status | Location |
|---------|--------|----------|
| `bmcs_truth_lemma` | **SORRY-FREE** | Bundle/TruthLemma.lean |
| `bmcs_representation` | **SORRY-FREE** | Bundle/Completeness.lean |
| `bmcs_weak_completeness` | **SORRY-FREE** | Bundle/Completeness.lean |
| `bmcs_strong_completeness` | **SORRY-FREE** | Bundle/Completeness.lean |

**Key Achievement**: The **box case** of the truth lemma is sorry-free. This was the fundamental obstruction that blocked traditional completeness proofs. BFMCS works by restricting box quantification to bundled families with modal coherence conditions.

**Import for use**:
```lean
import Bimodal.Metalogic.Bundle.Completeness
-- bmcs_weak_completeness, bmcs_strong_completeness
```

See [Bundle/README.md](Theories/Bimodal/Metalogic/Bundle/README.md) for full documentation.

#### 2. FMP Completeness (FMP/SemanticCanonicalModel.lean)

**Status**: SORRY-FREE and AXIOM-FREE (publication ready)

The **Finite Model Property** approach establishes that satisfiable formulas have finite models with bounded size (`2^closureSize`).

| Theorem | Status | Location |
|---------|--------|----------|
| `fmp_weak_completeness` | **SORRY-FREE** | FMP/SemanticCanonicalModel.lean |
| `semanticWorldState_card_bound` | **SORRY-FREE** | FMP/SemanticCanonicalModel.lean |

**Import for use**:
```lean
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
-- fmp_weak_completeness
```

See [FMP/README.md](Theories/Bimodal/Metalogic/FMP/README.md) for full documentation.

#### Soundness (Metalogic/Soundness.lean)

| Theorem | Status | Location |
|---------|--------|----------|
| `soundness` | **SORRY-FREE** | Metalogic/Soundness.lean |

All 15 TM axioms and 7 derivation rules proven to preserve validity.

---

### Sorry Debt Status

**Current State** (as of 2026-02-26): **3 sorries** in active Metalogic/ (excluding Boneyard)

| File | Count | Description |
|------|-------|-------------|
| Bundle/TemporalCoherentConstruction.lean:600 | 1 | Combines temporal + modal saturation for Int-indexed families |
| Bundle/DovetailingChain.lean:1869 | 1 | Cross-sign propagation (forward_H) |
| Bundle/DovetailingChain.lean:1881 | 1 | Cross-sign propagation (backward_G) |

**Why these don't block completeness**: These sorries are in the Int-indexed family construction infrastructure. The main completeness theorems (`bmcs_weak_completeness`, `fmp_weak_completeness`) are **fully sorry-free** and do not depend on this Int-specific code.

**Verification command**:
```bash
grep -rn "^\s*sorry$" Theories/Bimodal/Metalogic --include="*.lean" | grep -v Boneyard
```

---

### Module Architecture

```
Metalogic/
├── Soundness.lean            # soundness theorem (sorry-free)
├── SoundnessLemmas.lean      # supporting lemmas
├── Representation.lean       # top-level representation exports
│
├── Core/                     # Foundational MCS theory (sorry-free)
│   ├── MaximalConsistent.lean
│   ├── DeductionTheorem.lean
│   └── MCSProperties.lean
│
├── Bundle/                   # BFMCS completeness (primary approach)
│   ├── FMCS.lean             # Temporal MCS families
│   ├── BFMCS.lean            # Bundle with modal coherence
│   ├── TruthLemma.lean       # MCS <-> truth (sorry-free)
│   └── Completeness.lean     # Main theorems (sorry-free)
│
├── FMP/                      # Finite Model Property (sorry-free)
│   ├── Closure.lean          # Subformula closure
│   ├── BoundedTime.lean      # Finite time domain
│   └── SemanticCanonicalModel.lean  # fmp_weak_completeness
│
├── Decidability/             # Tableau decision procedure (sorry-free)
│   └── DecisionProcedure.lean
│
├── Algebraic/                # Alternative algebraic approach
│   └── AlgebraicRepresentation.lean
│
├── Representation/           # [ARCHIVED] README only
└── Compactness/              # [ARCHIVED] README only
```

---

### Syntax and Semantics

| Component | Status | Location |
|-----------|--------|----------|
| **Bimodal Syntax** | COMPLETE | Theories/Bimodal/Basic.lean |
| **TM Semantics** | COMPLETE | Theories/Bimodal/Semantics.lean |
| **Proof System** | COMPLETE | Theories/Bimodal/Proof.lean |

---

### Historical: Archived Approaches

The following approaches have been archived to `Theories/Bimodal/Boneyard/`. They are preserved for historical reference but are not part of the active codebase.

#### Metalogic_v5: IndexedMCSFamily Approach (SUPERSEDED)

**Status**: ARCHIVED to `Theories/Bimodal/Boneyard/Metalogic_v5/` (Task 809, 2026-02-02)

The IndexedMCSFamily approach used a family of MCS indexed by time with coherence conditions (forward_G, backward_H, etc.). This approach contained 30 sorries across auxiliary lemmas and has been superseded by BFMCS.

**Archive location**: `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/`

Files archived:
- IndexedMCSFamily.lean, CanonicalHistory.lean, TaskRelation.lean
- TruthLemma.lean, UniversalCanonicalModel.lean
- WeakCompleteness.lean, InfinitaryStrongCompleteness.lean

#### Compactness (ARCHIVED)

**Status**: ARCHIVED to `Theories/Bimodal/Boneyard/Metalogic_v5/Compactness/` (Task 809, 2026-02-02)

The compactness theorem depended on `InfinitaryStrongCompleteness` which used the Representation approach with 30+ sorries. The archived version provides:
- `compactness`: Main compactness theorem
- `compactness_iff`: Bidirectional equivalence
- `compactness_entailment`: Semantic consequence has finite witness

**Alternative**: For sorry-free completeness, use `fmp_weak_completeness` or `bmcs_weak_completeness`. Note that FMP does not provide infinitary completeness or compactness.

#### Decidability (Boneyard)

**Status**: DEPRECATED. Complete tableau-based decision procedure in `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/`. Active decidability infrastructure is in `Metalogic/Decidability/`.

See [Theories/Bimodal/Boneyard/README.md](Theories/Bimodal/Boneyard/README.md) for full Boneyard documentation.

---

## Phase 0: Complete Core Proofs (High Priority)

**Goal**: Finish the main proof by eliminating sorries and porting proven elements from the Boneyard.

### 0.1 Audit Current Sorries

**Tasks**:
- [x] Audit `Theories/Bimodal/Metalogic/` for sorries *(3 sorries as of 2026-02-26, see Current State section)*
- [x] Categorize by difficulty and dependency *(all in Int-indexed construction, not on critical path)*
- [x] Prioritize which sorries block main theorem path *(0 on critical path - main completeness theorems are sorry-free)*

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

**Current State** (as of 2026-02-26): **3 sorries** in Metalogic/ (excluding Boneyard)

### 5.1 Sorry Distribution

| File | Count | Description | Impact |
|------|-------|-------------|--------|
| Bundle/TemporalCoherentConstruction.lean:600 | 1 | Combines temporal + modal saturation | Non-blocking |
| Bundle/DovetailingChain.lean:1869 | 1 | Cross-sign propagation (forward_H) | Non-blocking |
| Bundle/DovetailingChain.lean:1881 | 1 | Cross-sign propagation (backward_G) | Non-blocking |

**Note**: All sorry-containing files (Representation/, Completeness/, Compactness/, etc.) have been archived to Boneyard/Metalogic_v5/.

### 5.2 Criticality Assessment

| Category | Count | Impact | Recommendation |
|----------|-------|--------|----------------|
| **Blocking main theorem** | 0 | Critical | N/A - `bmcs_weak_completeness` and `fmp_weak_completeness` are sorry-free |
| **Int-indexed construction** | 3 | Low | These support Int-specific family construction, not needed for main completeness |

### 5.3 Recommended Actions

#### DovetailingChain Cross-Sign Cases (2 sorries)
**Recommendation**: Document as future work.
**Reason**: Cross-sign propagation (forward_H at line 1869, backward_G at 1881) requires proving coherence across chain boundaries. Non-blocking for completeness.

#### TemporalCoherentConstruction (1 sorry)
**Recommendation**: Document as combining two proven properties.
**Reason**: The sorry at line 600 combines temporal coherence (proven separately) with modal saturation (proven separately). Future work could prove the combination formally.

**Verification**: Main completeness theorems (`bmcs_weak_completeness`, `bmcs_strong_completeness`, `fmp_weak_completeness`) are fully sorry-free and do not depend on these 3 sorries.

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

The ProofChecker project has achieved its primary goal: a clean, proven metalogic for TM bimodal logic. The current Metalogic architecture provides:

**Major Achievements**:
- **Soundness**: Fully proven, sorry-free (`Metalogic/Soundness.lean`)
- **BFMCS Completeness**: Sorry-free weak and strong completeness via Bundle approach (`Bundle/Completeness.lean`)
- **FMP Completeness**: Sorry-free, axiom-free completeness via finite model property (`FMP/SemanticCanonicalModel.lean`)
- **Decidability**: Tableau-based decision procedure (`Decidability/DecisionProcedure.lean`)
- **Minimal sorry debt**: Only 3 sorries in Int-indexed construction infrastructure, none on critical path

**Archived Approaches** (see Boneyard/):
- IndexedMCSFamily approach (Metalogic_v5) - superseded by BFMCS
- Infinitary strong completeness and compactness - depended on 30-sorry approach

**The path forward** focuses on three pillars:
1. **Quality**: Improving proof economy and organization (Phase 1, 4)
2. **Generalization**: Extending to new domains (Phase 2 partially complete, Phase 3)
3. **Accessibility**: Better documentation and tooling (Phase 6 substantially complete)

The recommended approach is to **consolidate before extending**: complete Phases 1 and 4 (organization and architecture) before embarking on major extensions. This ensures a solid foundation that makes future work easier and more maintainable.

**Key Insight**: Two independent sorry-free completeness paths (BFMCS and FMP) provide confidence in the metalogic. The BFMCS approach resolves the modal completeness obstruction via bundled semantics, while FMP provides a finite model construction.
