# Research Report: Reorganize Bimodal/Metalogic to Use Representation Theorem as Foundation

- **Task**: 554 - Reorganize Bimodal/Metalogic to Use Representation Theorem as Foundation
- **Started**: 2026-01-17T19:17:03Z
- **Completed**: 2026-01-17T19:18:59Z
- **Effort**: 4-6 hours
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - Theories/Bimodal/Metalogic/README.md
  - Theories/Bimodal/Metalogic/Completeness.lean
  - Theories/Bimodal/Metalogic/Representation/*.lean (5 files)
  - Theories/Bimodal/Metalogic/Completeness/*.lean (2 files)
  - Mathlib FirstOrder.Language.Theory (maximal theory patterns)
- **Artifacts**:
  - specs/554_bimodal_metalogic_v2_reorganize/reports/research-001.md (this file)
- **Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- Current Bimodal/Metalogic has dual architecture: working completeness proof (Completeness.lean) and partial representation layer (9 sorries)
- Representation theorem infrastructure exists but is not central to dependency graph
- Intended FMP-centric structure documented in README places Representation → FMP → {Completeness, Decidability, Compactness}
- Key duplication: set_lindenbaum and SetMaximalConsistent defined in both Completeness.lean and Representation/CanonicalModel.lean
- Reorganization requires creating new Metalogic_v2/ directory with representation-first architecture while preserving working proofs

## Context & Scope

### Research Goal
Analyze current Bimodal/Metalogic structure to determine how to reorganize theorems so the representation theorem becomes the foundational layer upon which completeness, decidability, and compactness are built via the Finite Model Property (FMP) bridge.

### Constraints
- Must preserve working completeness proof (provable_iff_valid in Completeness.lean)
- Cannot break existing functionality while reorganizing
- Should eliminate duplication between Completeness.lean and Representation/ modules
- Target is new Metalogic_v2/ directory (not modifying existing Metalogic/)

## Findings

### Current Architecture

The existing Metalogic/ directory has the following dependency structure:

```
ProofSystem, Semantics
         │
         ▼
    Soundness/
    (PROVEN)
         │
    ┌────┴─────┐
    ▼          ▼
DeductionThm  Core/Basic
  (PROVEN)    (WORKING)
         │
         ▼
  Completeness.lean
    (PROVEN - infinite canonical model)
         │
    ┌────┴───────────────┐
    ▼                    ▼
Completeness/      Applications/
FiniteCanonical    Compactness
  (PROVEN)         (WORKING)

(Separate branch, not connected)
    Representation/
    CanonicalModel.lean (2 sorries)
    TruthLemma.lean (2 sorries)
    RepresentationTheorem.lean (4 sorries)
    FiniteModelProperty.lean (1 sorry)
```

**Key Observations**:
1. Completeness.lean is self-contained and proven
2. Representation/ modules compile but have 9 sorries total
3. FMP is not connected to Decidability module
4. DeductionTheorem.lean is at top level (should be in Core/)

### Intended Architecture (from README)

The documented FMP-centric structure:

```
        Soundness/
             │
             ▼
          Core/
   (Basic, Provability, DeductionTheorem)
             │
             ▼
      Representation/
   (CanonicalModel, TruthLemma, RepresentationTheorem)
             │
             ▼
  FiniteModelProperty (FMP)
      [CENTRAL BRIDGE]
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
Completeness Decidability Compactness
```

**Principle**: FMP is the linchpin enabling all three downstream results:
- Completeness: FMP ensures canonical model is finite
- Decidability: FMP bounds search space for termination
- Compactness: FMP enables reduction to finite satisfiability

### Code Duplication Analysis

**Duplicate Definitions** (found in both files):

1. **SetConsistent** and **SetMaximalConsistent**:
   - Defined in: Completeness.lean (lines 110-120)
   - Duplicated in: Representation/CanonicalModel.lean (lines 61-69)
   - Identical semantics, same implementation

2. **set_lindenbaum** theorem:
   - Proven in: Completeness.lean (uses Zorn's lemma)
   - Re-stated in: Representation/CanonicalModel.lean
   - Status: Completeness.lean version is PROVEN, Representation version references it

3. **ConsistentSupersets** and chain lemmas:
   - Defined in both modules
   - Support Zorn's lemma application

**Implication**: The Representation/ modules were created as scaffolding based on Completeness.lean patterns but don't yet form independent foundation.

### File Inventory

**Current Metalogic/ Contents** (22 files):

Core:
- Core/Basic.lean - Consistency, validity, MCS definitions
- Core/Provability.lean - Context-based provability

Soundness (PROVEN):
- Soundness/Soundness.lean
- Soundness/SoundnessLemmas.lean

Completeness:
- Completeness.lean - Main self-contained proof (PROVEN)
- DeductionTheorem.lean - Top-level (should move to Core/)
- Completeness/FiniteCanonicalModel.lean (PROVEN)
- Completeness/CompletenessTheorem.lean (re-exports)

Representation (PARTIAL - 9 sorries):
- Representation/CanonicalModel.lean (2 sorries)
- Representation/TruthLemma.lean (2 sorries)
- Representation/RepresentationTheorem.lean (4 sorries)
- Representation/FiniteModelProperty.lean (1 sorry)
- Representation/ContextProvability.lean (working)

Decidability (PARTIAL):
- Decidability.lean - Hub module
- Decidability/SignedFormula.lean
- Decidability/Tableau.lean
- Decidability/Closure.lean
- Decidability/Saturation.lean
- Decidability/ProofExtraction.lean
- Decidability/CountermodelExtraction.lean
- Decidability/DecisionProcedure.lean
- Decidability/Correctness.lean (soundness proven, completeness needs FMP)

Applications:
- Applications/Compactness.lean (working)

### Representation Module Status

**CanonicalModel.lean**:
- Defines SetConsistent, SetMaximalConsistent, CanonicalWorldState
- Has set_lindenbaum theorem (imports from Completeness.lean)
- 2 sorries in chain consistency proofs

**TruthLemma.lean**:
- Defines canonicalTruthAt
- Truth lemma statement: φ ∈ w.carrier ↔ truth at canonical world
- 2 sorries in proof

**RepresentationTheorem.lean**:
- Main theorem: Consistent Γ → ∃ w, ∀ φ ∈ Γ, canonicalTruthAt w φ
- Strong version and completeness corollary
- 4 sorries (3 in helper lemmas, 1 in completeness_corollary)

**FiniteModelProperty.lean**:
- Defines subformulaList for bounding model size
- FMP statement: satisfiable → finite-satisfiable
- 1 sorry in subformulaList_finite bound proof
- Currently just re-uses satisfiability witness (not constructive)

### Mathlib Patterns

Searched Mathlib for canonical model patterns via lean_leanfinder:

**FirstOrder.Language.Theory.IsMaximal**:
- Pattern: Maximal theory T is satisfiable and complete (φ ∈ T ∨ ¬φ ∈ T)
- Theorem: `mem_iff_models` - φ ∈ T ↔ T ⊨ φ (analogous to truth lemma)
- Relevant for: Understanding how Mathlib structures maximal theory properties

**Key Insight**: Mathlib's first-order logic uses similar maximal consistent set patterns for completeness, validating the architectural approach.

### Import Dependencies

**Representation/ modules import**:
- Bimodal.Metalogic.Completeness (for set_lindenbaum)
- Bimodal.Metalogic.Core.* (Basic, Provability)
- Bimodal.Metalogic.DeductionTheorem
- Mathlib.Order.Zorn

**Implication**: Representation/ currently depends on Completeness.lean, which is backwards from intended architecture where Representation is foundational.

### Migration Challenges

1. **Circular dependency risk**: If Representation/ is made foundational, Completeness.lean currently imports are incompatible
2. **Proof preservation**: Completeness.lean has working infinite canonical model proof that can't be broken
3. **Sorry resolution**: 9 sorries in Representation/ need filling or architectural workaround
4. **DeductionTheorem location**: Currently top-level, should move to Core/

## Decisions

1. **Create new Metalogic_v2/ directory** rather than modifying existing Metalogic/ in-place
   - Rationale: Preserves working proofs, allows comparison, enables gradual migration

2. **Use Completeness.lean definitions as single source of truth**
   - Rationale: set_lindenbaum is proven there, avoid duplication
   - Action: Representation_v2 should import from shared foundation

3. **Establish layered architecture**:
   - Layer 1: Core/ (Basic, Provability, DeductionTheorem)
   - Layer 2: Representation/ (foundation on Core/)
   - Layer 3: FMP (uses Representation)
   - Layer 4: Applications (Completeness, Decidability, Compactness use FMP)

4. **Fill FMP sorry as minimal viable proof**
   - Current FMP just reuses witness (not constructive)
   - For reorganization, can keep this pattern initially
   - Future work: Make FMP constructive with finite model bound

## Recommendations

### Phase 1: Create Foundation Layer (2-3 hours)

**Objective**: Establish Core_v2/ with consolidated definitions

**Actions**:
1. Create `Theories/Bimodal/Metalogic_v2/Core/` directory structure
2. Move DeductionTheorem.lean → Core_v2/DeductionTheorem.lean
3. Consolidate set-based definitions:
   - Extract SetConsistent, SetMaximalConsistent from Completeness.lean
   - Create Core_v2/MaximalConsistent.lean with canonical definitions
   - Include set_lindenbaum theorem (proven via Zorn)
4. Update imports in Core_v2/Basic.lean to reference shared definitions

**Files to create**:
- Metalogic_v2/Core/Basic.lean
- Metalogic_v2/Core/Provability.lean
- Metalogic_v2/Core/DeductionTheorem.lean
- Metalogic_v2/Core/MaximalConsistent.lean (NEW - consolidates duplicates)

### Phase 2: Build Representation Layer (1-2 hours)

**Objective**: Create Representation_v2/ that depends only on Core_v2/

**Actions**:
1. Copy Representation/*.lean to Metalogic_v2/Representation/
2. Update imports:
   - Remove `import Bimodal.Metalogic.Completeness`
   - Add `import Bimodal.Metalogic_v2.Core.MaximalConsistent`
3. Remove duplicate definitions (SetConsistent, set_lindenbaum)
4. Keep 9 sorries as-is (can be filled later, they compile)

**Files to create**:
- Metalogic_v2/Representation/CanonicalModel.lean (updated imports)
- Metalogic_v2/Representation/TruthLemma.lean
- Metalogic_v2/Representation/RepresentationTheorem.lean
- Metalogic_v2/Representation/FiniteModelProperty.lean

### Phase 3: Create FMP Bridge (30 min - 1 hour)

**Objective**: Make FiniteModelProperty.lean the central hub

**Actions**:
1. Ensure FMP imports only Representation layer
2. Add exports for downstream use:
   - Export finite_model_property theorem
   - Export satisfiability_decidable
   - Export soundness_completeness_triangle
3. Create FMP.lean hub file that re-exports

**Files to create**:
- Metalogic_v2/FMP.lean (hub module re-exporting FiniteModelProperty)

### Phase 4: Build Applications Layer (1-2 hours)

**Objective**: Create Completeness_v2, Decidability_v2, Compactness_v2 that import FMP

**Actions**:
1. Create Metalogic_v2/Completeness/
   - WeakCompleteness.lean (import FMP, prove ⊨ φ → ⊢ φ)
   - StrongCompleteness.lean (import FMP, prove Γ ⊨ φ → Γ ⊢ φ)
2. Update Decidability_v2/Correctness.lean:
   - Import FMP.lean
   - Use finite_model_property for tableau_complete bound
3. Create Applications_v2/Compactness.lean:
   - Import FMP
   - Use FMP for finite satisfiability reduction

**Files to create**:
- Metalogic_v2/Completeness/WeakCompleteness.lean
- Metalogic_v2/Completeness/StrongCompleteness.lean
- Metalogic_v2/Decidability/ (copy from Metalogic/Decidability/, update imports)
- Metalogic_v2/Applications/Compactness.lean

### Phase 5: Create Top-Level Module and README (30 min)

**Actions**:
1. Create Metalogic_v2.lean hub file importing all layers
2. Write Metalogic_v2/README.md documenting new structure
3. Add migration notes comparing to Metalogic/

**Files to create**:
- Theories/Bimodal/Metalogic_v2.lean
- Theories/Bimodal/Metalogic_v2/README.md

### Verification Steps

After each phase:
1. Run `lake build Bimodal.Metalogic_v2` to verify compilation
2. Check for import cycles using `lake build --verbose`
3. Verify sorries are isolated to expected locations (Representation layer only)
4. Confirm no breakage in original Metalogic/ modules

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Import cycles** | Build failure, architecture unusable | Strict layering: Core → Representation → FMP → Applications. Never import upwards. |
| **Broken working proofs** | Loss of proven completeness | Use new Metalogic_v2/ directory, preserve original Metalogic/ unchanged |
| **Sorries propagate** | Representation layer sorries infect downstream | Accept sorries in Representation/, document as proof obligations. Applications can use axioms. |
| **DeductionTheorem move breaks imports** | Compilation errors | Update all import paths simultaneously. Use `lake build` for verification. |
| **FMP not truly foundational** | Circular reasoning | Ensure FMP proof only uses Representation layer, not downstream theorems |
| **Time overrun** | 6+ hours instead of 4-6 | Phases are independent. Can pause after Phase 2 with partial structure. |

## Appendix

### References

**Internal Documentation**:
- Theories/Bimodal/Metalogic/README.md - Current structure and intended architecture
- specs/523_bimodal_cleanup/reports/ - Historical architecture analysis (mentioned in README)

**Lean Files Analyzed**:
- Theories/Bimodal/Metalogic/Completeness.lean - set_lindenbaum proof (lines 110-400)
- Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean - Duplicate definitions
- Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean - Central theorem
- Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean - FMP bridge

**Mathlib References**:
- FirstOrder.Language.Theory.IsMaximal - Maximal theory pattern
- Mathlib.Order.Zorn - Zorn's lemma for Lindenbaum extension

**External References**:
- Modal Logic, Blackburn et al., Chapter 4 - Canonical models and FMP
- Wu, M., Verified Decision Procedures for Modal Logics - FMP for decidability

### Dependency Graph (Intended Metalogic_v2/)

```
Bimodal.ProofSystem
Bimodal.Semantics
      │
      ▼
Metalogic_v2.Core.Basic
Metalogic_v2.Core.Provability
Metalogic_v2.Core.DeductionTheorem
      │
      ▼
Metalogic_v2.Core.MaximalConsistent
  (SetConsistent, set_lindenbaum)
      │
      ▼
Metalogic_v2.Soundness.Soundness
      │
      ▼
Metalogic_v2.Representation.CanonicalModel
      │
      ▼
Metalogic_v2.Representation.TruthLemma
      │
      ▼
Metalogic_v2.Representation.RepresentationTheorem
      │
      ▼
Metalogic_v2.Representation.FiniteModelProperty
  (= Metalogic_v2.FMP)
      │
      ├─────────────────┬─────────────────┐
      ▼                 ▼                 ▼
Completeness/    Decidability/    Applications/
WeakCompleteness  Correctness      Compactness
StrongCompleteness
```

### File Count Estimate

**New files to create**: ~20 files
- Core_v2/: 4 files (Basic, Provability, DeductionTheorem, MaximalConsistent)
- Soundness_v2/: 2 files (copied from Metalogic/Soundness)
- Representation_v2/: 5 files (updated imports from Representation/)
- Completeness_v2/: 2 files (WeakCompleteness, StrongCompleteness)
- Decidability_v2/: ~8 files (copied from Metalogic/Decidability/)
- Applications_v2/: 1 file (Compactness)
- Hub files: 2 files (Metalogic_v2.lean, README.md)

**Effort distribution**:
- Phase 1 (Foundation): 2-3 hours
- Phase 2 (Representation): 1-2 hours
- Phase 3 (FMP): 0.5-1 hour
- Phase 4 (Applications): 1-2 hours
- Phase 5 (Documentation): 0.5 hour
- **Total**: 5-8.5 hours (aligns with 4-6 hour estimate if phases overlap)

### Search Queries Used

1. `lean_local_search "lindenbaum"` - Found no results (wrong spelling)
2. `lean_local_search "set_lindenbaum"` - Found in Completeness.lean and CanonicalModel.lean
3. `lean_local_search "SetMaximalConsistent"` - Found duplicates
4. `lean_leanfinder "canonical model maximal consistent set representation theorem modal logic"` - Found Mathlib FirstOrder.Language.Theory patterns

### Next Steps

After this research report:
1. Run `/plan 554` to create phased implementation plan based on these recommendations
2. Implementation should follow 5 phases outlined in Recommendations section
3. Each phase should have verification step (lake build) before proceeding
