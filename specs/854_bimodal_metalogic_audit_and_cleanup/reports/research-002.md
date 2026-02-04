# Research Report: Task #854 (Supplemental)

**Task**: Bimodal Metalogic Audit and Cleanup
**Date**: 2026-02-04
**Focus**: Theoretical dependency structure for metalogic theorems and architectural recommendations

## Summary

This supplemental research establishes the standard theoretical relationships between metalogic theorems (soundness, completeness, representation, compactness, FMP, decidability) and provides a dependency flowchart for restructuring the bimodal metalogic. Two parallel paths are identified: the Kripke semantics path and the algebraic path, which should be kept architecturally separate but can share foundational infrastructure.

## Standard Metalogic Theorem Dependencies

### The Two Classical Paths to Completeness

Modal logic completeness can be established via two fundamentally different approaches:

#### 1. Kripke Semantics Path (Canonical Models)

```
Lindenbaum's Lemma (consistent set -> MCS)
         |
         v
Canonical Model Construction (set of all MCS)
         |
         v
Truth Lemma (MCS membership <-> truth in canonical model)
         |
         v
COMPLETENESS: valid -> provable (by contrapositive)
         |
         +---> Strong Completeness (Gamma |= phi -> Gamma |- phi)
         |
         +---> Compactness (follows from strong completeness)
```

#### 2. Algebraic Path (Boolean Algebras with Operators)

```
Lindenbaum-Tarski Algebra (Formula / ~)
         |
         v
Boolean Algebra Structure (provable equivalence classes)
         |
         v
Interior/Closure Operators (modal operators as operators on BA)
         |
         v
Ultrafilter-MCS Correspondence (ultrafilters <-> MCS)
         |
         v
REPRESENTATION THEOREM (BA embeds in complex algebra of a frame)
         |
         v
COMPLETENESS (via Jonsson-Tarski duality)
```

### Key Relationships

| Theorem | Depends On | Provides |
|---------|------------|----------|
| **Soundness** | (Independent) | Derivable -> Valid |
| **Lindenbaum's Lemma** | Zorn's Lemma / Choice | Consistent -> extends to MCS |
| **Canonical Model** | Lindenbaum | Model from all MCS |
| **Truth Lemma** | Canonical Model | MCS membership <-> model truth |
| **Weak Completeness** | Truth Lemma | Valid -> Provable |
| **Strong Completeness** | Weak Completeness | Gamma |= phi -> Gamma |- phi |
| **Compactness** | Strong Completeness | Finitely satisfiable -> Satisfiable |
| **FMP** | (Alternative proof path) | Valid iff valid in all finite models |
| **Decidability** | FMP + Effective Bound | Validity is decidable |
| **Representation** | Algebraic structure | BA embeds in powerset algebra |

### The Critical FMP-Decidability Relationship

From [Finite Model Property - Wikipedia](https://en.wikipedia.org/wiki/Finite_model_property):

> A logic L has the finite model property (FMP) if any non-theorem of L is falsified by some finite model of L. If L is finitely axiomatizable (and has a recursive set of inference rules) and has the FMP, then it is decidable.

However, FMP alone does NOT guarantee decidability:
- Need an **effective bound** on model size (effective FMP)
- Some product logics (K x K x K) have FMP but are undecidable
- The bound must be computable from the formula

**Key insight for ProofChecker**: The FMP approach in `FMP/SemanticCanonicalModel.lean` provides exactly this - a bound on world states in terms of closure size (`semanticWorldState_card_bound : card worlds <= 2^closureSize`).

### Compactness Theorem's Role

From [Modal Logic Compactness](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf):

> Canonical models witness strong completeness and hence compactness.

The relationship is:
```
Strong Completeness <==> Compactness (given soundness)
```

Proof sketch:
- (Strong Completeness -> Compactness): If every finite subset of Gamma is satisfiable, it's consistent. So Gamma is consistent (derivations are finite). By strong completeness, Gamma is satisfiable.
- (Compactness -> Strong Completeness): By contrapositive using compactness.

**Current status**: The ProofChecker has `bmcs_strong_completeness`, which implicitly provides compactness. This could be made explicit.

## Dependency Flowchart

### Mermaid Diagram

```mermaid
graph TB
    subgraph "Foundation (Core/)"
        LinLemma[Lindenbaum's Lemma]
        DedThm[Deduction Theorem]
        MCS[MCS Properties]
    end

    subgraph "Soundness (Top-level)"
        Sound[soundness: |- phi -> |= phi]
    end

    subgraph "Kripke Path (Bundle/, FMP/)"
        BMCS[BMCS Structure]
        BMCSTruth[BMCS Truth Definition]
        TruthLemma[Truth Lemma]
        BMCSCompl[bmcs_weak_completeness]
        BMCSStrong[bmcs_strong_completeness]

        FMPClosure[Closure Construction]
        FMPWorld[Finite World States]
        FMPCompl[fmp_weak_completeness]
    end

    subgraph "Decidability (Decidability/)"
        Tableau[Tableau Construction]
        DecProc[Decision Procedure]
        Decide[decide/isValid/isSatisfiable]
    end

    subgraph "Algebraic Path (Algebraic/)"
        LindAlg[Lindenbaum Quotient]
        BoolStr[Boolean Structure]
        Interior[Interior Operators]
        UltMCS[Ultrafilter-MCS Bijection]
        AlgRep[Algebraic Representation]
    end

    subgraph "Derived Results (potential)"
        Compact[Compactness]
        FMP[Finite Model Property]
    end

    %% Foundation flows
    LinLemma --> MCS
    DedThm --> MCS

    %% Kripke path
    MCS --> BMCS
    BMCS --> BMCSTruth
    BMCSTruth --> TruthLemma
    TruthLemma --> BMCSCompl
    BMCSCompl --> BMCSStrong

    %% FMP path
    MCS --> FMPClosure
    FMPClosure --> FMPWorld
    FMPWorld --> FMPCompl

    %% Decidability
    FMPCompl --> FMP
    FMPWorld --> Tableau
    Tableau --> DecProc
    DecProc --> Decide

    %% Algebraic path
    LinLemma --> LindAlg
    LindAlg --> BoolStr
    BoolStr --> Interior
    Interior --> UltMCS
    MCS --> UltMCS
    UltMCS --> AlgRep

    %% Derived
    BMCSStrong --> Compact
    FMP --> Decide

    %% Styling
    classDef proven fill:#90EE90,stroke:#228B22
    classDef axiom fill:#FFD700,stroke:#DAA520
    classDef potential fill:#ADD8E6,stroke:#4682B4
    classDef sorry fill:#FFB6C1,stroke:#DC143C

    class Sound,BMCSCompl,BMCSStrong,FMPCompl,Decide proven
    class LinLemma,DedThm,MCS,BMCS,BMCSTruth,TruthLemma,FMPClosure,FMPWorld,Tableau,DecProc proven
    class LindAlg,BoolStr,Interior,UltMCS,AlgRep proven
    class Compact,FMP potential
```

### ASCII Dependency Diagram

```
                          ┌─────────────────────────────────────────────────────────────────────┐
                          │                        FOUNDATION                                    │
                          │  ┌─────────────────┐   ┌──────────────────┐   ┌──────────────────┐  │
                          │  │ Lindenbaum's    │   │ Deduction        │   │ MCS Properties   │  │
                          │  │ Lemma           │──▶│ Theorem          │──▶│                  │  │
                          │  │ [Core/]         │   │ [Core/]          │   │ [Core/]          │  │
                          │  └────────┬────────┘   └──────────────────┘   └────────┬─────────┘  │
                          └───────────┼───────────────────────────────────────────┼────────────┘
                                      │                                           │
               ┌──────────────────────┴─────────────┬─────────────────────────────┴──────────────────┐
               │                                    │                                                 │
               ▼                                    ▼                                                 ▼
    ┌──────────────────────┐            ┌──────────────────────┐                      ┌──────────────────────┐
    │   KRIPKE PATH        │            │    FMP PATH          │                      │   ALGEBRAIC PATH     │
    │   (Bundle/)          │            │    (FMP/)            │                      │   (Algebraic/)       │
    │                      │            │                      │                      │                      │
    │  BMCS Structure      │            │  Closure             │                      │  Lindenbaum Quotient │
    │        │             │            │  Construction        │                      │        │             │
    │        ▼             │            │        │             │                      │        ▼             │
    │  BMCS Truth Defn     │            │        ▼             │                      │  Boolean Structure   │
    │        │             │            │  Finite World        │                      │        │             │
    │        ▼             │            │  States              │                      │        ▼             │
    │  Truth Lemma         │            │        │             │                      │  Interior Operators  │
    │        │             │            │        ▼             │                      │  (G, H as closures)  │
    │        ▼             │            │ ┌──────────────┐     │                      │        │             │
    │ ┌──────────────┐     │            │ │fmp_weak_     │     │                      │        ▼             │
    │ │bmcs_weak_    │     │            │ │completeness  │     │                      │  Ultrafilter-MCS     │
    │ │completeness  │     │            │ │[SORRY-FREE]  │     │                      │  Bijection           │
    │ │[SORRY-FREE]  │     │            │ └──────┬───────┘     │                      │        │             │
    │ └──────┬───────┘     │            │        │             │                      │        ▼             │
    │        │             │            │        │             │                      │  Algebraic           │
    │        ▼             │            │        │             │                      │  Representation      │
    │ ┌──────────────┐     │            └────────┼─────────────┘                      │                      │
    │ │bmcs_strong_  │     │                     │                                    │  [Future: Duality    │
    │ │completeness  │     │                     │                                    │   to Kripke frames]  │
    │ │[SORRY-FREE]  │     │                     │                                    └──────────────────────┘
    │ └──────┬───────┘     │                     │
    └────────┼─────────────┘                     │
             │                                   │
             ▼                                   ▼
    ┌──────────────────────┐        ┌──────────────────────────────────────┐
    │   DERIVED RESULTS    │        │         DECIDABILITY                  │
    │   (potential)        │        │         (Decidability/)               │
    │                      │        │                                       │
    │  Compactness ◄───────┤        │  Tableau Construction                 │
    │  (implicit in        │        │         │                             │
    │  strong completeness)│        │         ▼                             │
    │                      │        │  Decision Procedure                   │
    └──────────────────────┘        │         │                             │
                                    │         ▼                             │
                                    │  ┌───────────────┐                    │
                                    │  │ decide        │                    │
                                    │  │ isValid       │                    │
                                    │  │ isSatisfiable │                    │
                                    │  │ [SORRY-FREE]  │                    │
                                    │  └───────────────┘                    │
                                    └──────────────────────────────────────┘

    ┌──────────────────────┐
    │       SOUNDNESS      │  (Independent - does not depend on completeness)
    │      (Top-level)     │
    │                      │
    │  soundness:          │
    │  |- phi -> |= phi    │
    │  [SORRY-FREE]        │
    └──────────────────────┘

LEGEND:
  [SORRY-FREE] = Fully proven theorem
  ────────────▶ = Dependency (A ──▶ B means B depends on A)
  ◄──────────── = Derives from (opposite direction)
```

### Current Status Overlay

| Component | Status | Notes |
|-----------|--------|-------|
| **Core/MCS** | PROVEN | Foundation for all paths |
| **Core/DeductionTheorem** | PROVEN | Hilbert-style |
| **Core/Lindenbaum** | PROVEN | Uses Zorn's lemma via Mathlib |
| **Soundness** | SORRY-FREE | Independent, top-level |
| **Bundle/BMCS** | PROVEN | Bundle structure |
| **Bundle/TruthLemma** | FORWARD PROVEN | Backward has 2 sorries (unused) |
| **Bundle/Completeness** | SORRY-FREE | Uses 1 axiom (documented) |
| **FMP/SemanticCanonicalModel** | SORRY-FREE | Completely proven |
| **Decidability** | SORRY-FREE | Tableau-based |
| **Algebraic/*** | PROVEN | Ready for duality extension |

## Architectural Recommendations

### 1. Ideal Module Structure

```
Theories/Bimodal/Metalogic/
│
├── README.md                    # Updated documentation
├── Metalogic.lean               # Entry point (re-exports)
│
├── Foundation/                  # Rename from Core/
│   ├── MCS.lean                 # MaximalConsistent + MCSProperties merged
│   ├── Lindenbaum.lean          # Lindenbaum's lemma
│   └── Deduction.lean           # Deduction theorem
│
├── Kripke/                      # Rename from Bundle/
│   ├── BMCS.lean                # Bundle structure
│   ├── Truth.lean               # BMCSTruth + TruthLemma merged
│   ├── Construction.lean        # BMCS construction
│   ├── Completeness.lean        # Main completeness theorems
│   └── Compactness.lean         # NEW: explicit compactness theorem
│
├── FMP/                         # Keep as-is
│   ├── Closure.lean
│   ├── WorldState.lean          # Rename from FiniteWorldState
│   ├── BoundedTime.lean
│   └── Completeness.lean        # Rename from SemanticCanonicalModel
│
├── Decidability/                # Keep as-is
│   ├── Tableau.lean
│   ├── Closure.lean             # Move/merge with FMP/Closure if similar
│   ├── Saturation.lean
│   ├── Correctness.lean
│   ├── ProofExtraction.lean
│   ├── CountermodelExtraction.lean
│   └── DecisionProcedure.lean
│
├── Algebraic/                   # Keep separate, expand
│   ├── Lindenbaum.lean          # Quotient construction
│   ├── Boolean.lean             # Boolean algebra instance
│   ├── Operators.lean           # Interior operators (G, H)
│   ├── Ultrafilter.lean         # Ultrafilter-MCS correspondence
│   ├── Representation.lean      # Current representation theorem
│   └── Duality.lean             # FUTURE: Jonsson-Tarski duality
│
├── Soundness.lean               # Keep at top level
└── SoundnessLemmas.lean         # Keep at top level
```

### 2. Key Interface Points

The three paths (Kripke, FMP, Algebraic) should share these interfaces:

```lean
-- Foundation interface (all paths use this)
class HasMCS where
  MCS : Type
  is_mcs : Set Formula → MCS → Prop
  lindenbaum : Consistent Γ → ∃ m : MCS, Γ ⊆ m.formulas

-- Completeness interface (Kripke and FMP provide this)
class HasWeakCompleteness where
  valid : Formula → Prop
  weak_completeness : valid φ → ⊢ φ

-- Algebraic interface (for duality)
class HasLindenbaumAlgebra where
  Alg : Type
  quotient : Formula → Alg
  is_boolean_algebra : BooleanAlgebra Alg
  ultrafilter_mcs_bij : Ultrafilter Alg ≃ MCS
```

### 3. Algebraic Path Separation Strategy

The algebraic approach should remain architecturally independent but share foundational components:

**Shared with Kripke path**:
- `Foundation/MCS.lean` - MCS definition and basic properties
- `Foundation/Lindenbaum.lean` - Extension lemma

**Unique to Algebraic path**:
- Lindenbaum quotient construction (different from MCS construction)
- Boolean algebra structure on quotient
- Interior operator characterization
- Ultrafilter correspondence
- Future: Jonsson-Tarski duality theorem

**Future algebraic completeness route**:
```
Lindenbaum Quotient → Boolean Algebra → Interior Operators
                                              ↓
                                     Ultrafilter-MCS Bijection
                                              ↓
                                     Stone Representation
                                              ↓
                                     Jonsson-Tarski Duality
                                              ↓
                                     Algebraic Completeness
```

### 4. Files Safe to Archive

Based on research-001.md and this analysis:

| File | Archive To | Reason |
|------|------------|--------|
| `Bundle/PreCoherentBundle.lean` | `Boneyard/Metalogic_v6_WIP/` | WIP, not imported |
| `Bundle/WeakCoherentBundle.lean` | `Boneyard/Metalogic_v6_WIP/` | WIP, not imported |
| `Bundle/SaturatedConstruction.lean` | `Boneyard/Metalogic_v6_WIP/` | WIP, not imported |
| `Bundle/CoherentConstruction.lean` | `Boneyard/Metalogic_v6_WIP/` | Only imported by WIP files |
| `Core/RestrictedMCS.lean` | Review needed | Check if imported |

### 5. Explicit Theorems to Add

For completeness of the metalogic, these theorems could be made explicit:

```lean
-- In Kripke/Compactness.lean (NEW)
theorem compactness :
    (∀ Γ₀ ⊆ Γ, Γ₀.Finite → Satisfiable Γ₀) → Satisfiable Γ

-- In FMP/Completeness.lean
theorem fmp_theorem :
    ¬(⊢ φ) → ∃ M : FiniteModel, M ⊭ φ

-- In Decidability/DecisionProcedure.lean (enhance)
theorem decidability :
    Decidable (⊢ φ)  -- Currently implicit in `decide`
```

## Mathlib Patterns Reference

Based on [FormalizedFormalLogic/Foundation](https://github.com/iehality/lean4-logic) and related projects:

### Completeness Proofs in Lean

The FormalizedFormalLogic project provides patterns for:
- Tait-style calculus completeness
- Kripke semantics completeness
- Modal companions (Godel-McKinsey-Tarski)

### Key Architectural Patterns

1. **Separation of syntax and semantics**: Syntax in one module, semantics in another
2. **Typeclass-based satisfaction**: `instance : Satisfiable M φ`
3. **Proof by contrapositive**: Standard pattern for completeness
4. **Quotient-based Lindenbaum**: Use Lean 4 quotients for clean construction

## References

### Web Sources

- [Completeness and Canonical Models (Open Logic Project)](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf)
- [Finite Model Property (Wikipedia)](https://en.wikipedia.org/wiki/Finite_model_property)
- [Algebraic Model for Modal Logics (nLab)](https://ncatlab.org/nlab/show/algebraic+model+for+modal+logics)
- [Model Theory of Modal Logic (Goranko & Otto)](https://www2.mathematik.tu-darmstadt.de/~otto/papers/mlhb.pdf)
- [FormalizedFormalLogic/Foundation (GitHub)](https://github.com/iehality/lean4-logic)
- [Henkin-style Completeness for S5 in Lean](https://link.springer.com/chapter/10.1007/978-3-030-89391-0_25)

### Previous Research

- `specs/854_bimodal_metalogic_audit_and_cleanup/reports/research-001.md` - Code audit
- `specs/812_canonical_model_completeness/reports/research-007.md` - Original completeness research

## Next Steps

1. **Immediate**: Archive the 4 WIP files identified in research-001.md
2. **Short-term**: Rename directories per architectural recommendations
3. **Medium-term**: Extract explicit compactness and FMP theorems
4. **Long-term**: Complete algebraic path with Jonsson-Tarski duality
