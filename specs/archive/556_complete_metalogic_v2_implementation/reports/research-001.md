# Research Report: Task #556

**Task**: 556 - Complete Metalogic_v2 Implementation
**Started**: 2026-01-17T20:47:30Z
**Completed**: 2026-01-17T21:05:00Z
**Effort**: 6-10 hours
**Priority**: High
**Dependencies**: 554 (completed)
**Sources/Inputs**:
  - Theories/Bimodal/Metalogic_v2/**/*.lean (15 files)
  - Theories/Bimodal/Metalogic_v2/README.md
  - specs/554_bimodal_metalogic_v2_reorganize/reports/research-001.md
  - Mathlib (lean_local_search, lean_loogle)
**Artifacts**:
  - specs/556_complete_metalogic_v2_implementation/reports/research-001.md (this file)
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- Metalogic_v2 directory contains 15 Lean files organized in a representation-first architecture
- **11 sorry placeholders** identified across 7 files, plus **1 axiom** in ContextProvability.lean
- The architecture establishes layered dependencies: Core -> Representation -> FMP -> Completeness
- Key blocking sorries are in MCS properties (mcs_contains_or_neg, mcs_modus_ponens) which propagate to downstream theorems
- README.md needs updating to accurately reflect current state and completion roadmap

## Context & Scope

### Research Goal
Analyze the current state of Metalogic_v2/ directory, identify all sorries and axioms, understand their dependencies, and determine the target organization for completing this implementation so Metalogic_v2/ can stand alone as a replacement for Metalogic/.

### Constraints
- Task 554 created the directory structure; this task fills remaining gaps
- Must preserve the representation-first architecture where FMP is the central bridge
- Goal is to make Metalogic_v2/ self-sufficient so original Metalogic/ can be deprecated

## Findings

### Directory Structure (15 files)

```
Metalogic_v2/
├── Core/                              # Foundation Layer (4 files)
│   ├── Basic.lean                     # 1 sorry
│   ├── Provability.lean               # 0 sorries
│   ├── DeductionTheorem.lean          # 0 sorries (FULLY PROVEN)
│   └── MaximalConsistent.lean         # 0 sorries (FULLY PROVEN)
├── Soundness/                         # Soundness Layer (2 files)
│   ├── SoundnessLemmas.lean           # 0 sorries
│   └── Soundness.lean                 # 0 sorries (FULLY PROVEN)
├── Representation/                    # Representation Layer (5 files)
│   ├── CanonicalModel.lean            # 2 sorries
│   ├── TruthLemma.lean                # 1 sorry
│   ├── RepresentationTheorem.lean     # 2 sorries
│   ├── ContextProvability.lean        # 1 AXIOM (representation_theorem_backward_empty)
│   └── FiniteModelProperty.lean       # 2 sorries
├── Completeness/                      # Application Layer (2 files)
│   ├── WeakCompleteness.lean          # 0 sorries (uses axiom transitively)
│   └── StrongCompleteness.lean        # 2 sorries
├── Applications/
│   └── Compactness.lean               # 0 sorries (verified)
├── FMP.lean                           # Hub module (0 sorries)
└── README.md                          # Documentation (needs update)
```

### Complete Sorry/Axiom Inventory

#### 1. Core/Basic.lean (Line 56) - 1 sorry

**Location**: `consistent_iff_consistent'` lemma
**Type**: `Consistent Γ ↔ Consistent' Γ`
**Purpose**: Equivalence between "exists unprovable formula" and "cannot prove ⊥"
**Dependency**: Requires ex-falso axiom integration with TM proof system
**Difficulty**: Medium - standard classical logic result
**Impact**: Low - not on critical path, alternative definitions work

#### 2. Representation/CanonicalModel.lean (Lines 192, 209) - 2 sorries

**Sorry 1 (Line 192)**: `mcs_contains_or_neg`
```lean
theorem mcs_contains_or_neg {S : Set Formula} (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ Formula.neg φ ∈ S
```
**Purpose**: MCS negation completeness - every formula or its negation is in an MCS
**Dependency**: Classical logic, deduction theorem
**Difficulty**: Medium - requires careful derivation tree construction
**Impact**: HIGH - used by mcs_modus_ponens, TruthLemma, completeness

**Sorry 2 (Line 209)**: `mcs_modus_ponens`
```lean
theorem mcs_modus_ponens {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    {φ ψ : Formula} (h_imp : Formula.imp φ ψ ∈ S) (h_ant : φ ∈ S) : ψ ∈ S
```
**Purpose**: MCS closure under modus ponens
**Dependency**: mcs_contains_or_neg, derivation tree construction for inconsistency
**Difficulty**: Medium - classical proof combining MP and consistency
**Impact**: HIGH - used by TruthLemma implication case

#### 3. Representation/TruthLemma.lean (Line 160) - 1 sorry

**Location**: `necessitation_lemma`
```lean
theorem necessitation_lemma (w : CanonicalWorldState) {φ : Formula}
    (h_derivable : ContextDerivable [] φ) : (Formula.box φ) ∈ w.carrier
```
**Purpose**: If [] ⊢ φ then □φ ∈ every MCS (necessitation in canonical model)
**Dependency**: Deductive closure of MCS, necessitation rule application
**Difficulty**: Medium - requires MCS deductive closure property
**Impact**: Medium - used for modal completeness

#### 4. Representation/RepresentationTheorem.lean (Lines 151, 159) - 2 sorries

**Sorry 1 (Line 151)**: Inside `completeness_corollary`
**Purpose**: Double negation elimination: from Γ ⊢ ¬¬φ to Γ ⊢ φ
**Dependency**: Peirce's law in TM proof system
**Difficulty**: Low-Medium - standard classical logic
**Impact**: Medium - needed for contrapositive completeness argument

**Sorry 2 (Line 159)**: Inside `completeness_corollary`
**Purpose**: Contradiction in canonical world - connecting validity to MCS membership
**Dependency**: Full truth lemma, canonical model evaluation
**Difficulty**: Medium - requires connecting semantic truth to canonical membership
**Impact**: Medium - corollary, not main result

#### 5. Representation/ContextProvability.lean (Line 83) - 1 AXIOM

**Location**: `representation_theorem_backward_empty`
```lean
axiom representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ
```
**Purpose**: Backward direction of representation: validity implies provability
**Dependency**: This IS the completeness theorem
**Difficulty**: HIGH - this is the main result to prove
**Impact**: CRITICAL - all completeness results depend on this axiom

#### 6. Representation/FiniteModelProperty.lean (Lines 81, 162) - 2 sorries

**Sorry 1 (Line 81)**: `subformulaList_finite`
```lean
theorem subformulaList_finite (φ : Formula) :
    (subformulaList φ).length < 2 ^ Formula.complexity φ + 1
```
**Purpose**: Bound on subformula list size
**Dependency**: Structural induction on Formula
**Difficulty**: Low - straightforward induction
**Impact**: Low - FMP statement works without tight bound

**Sorry 2 (Line 162)**: Inside `consistent_implies_satisfiable`
```lean
theorem consistent_implies_satisfiable (φ : Formula) (h_cons : Consistent [φ]) :
    formula_satisfiable φ
```
**Purpose**: Bridge from canonical world to TaskModel satisfiability
**Dependency**: Need to construct concrete TaskModel from canonical world
**Difficulty**: HIGH - requires connecting abstract canonical world to semantic model
**Impact**: HIGH - bridges representation to semantic satisfiability

#### 7. Completeness/StrongCompleteness.lean (Lines 82, 114) - 2 sorries

**Sorry 1 (Line 82)**: Inside `entails_imp_chain`
```lean
have h_Γ'_entails : semantic_consequence Γ' φ := by
    intro D' inst1' inst2' inst3' F' M' τ' t' h_all'
    sorry
```
**Purpose**: Semantic consequence from ψ :: Γ' reduces to Γ' given ψ holds
**Dependency**: Requires showing entailment is preserved when removing satisfied assumption
**Difficulty**: Medium - semantic reasoning about model satisfaction
**Impact**: Medium - helper for strong completeness

**Sorry 2 (Line 114)**: Inside `imp_chain_to_context`
```lean
-- For now, leave as sorry - the structure is established
sorry
```
**Purpose**: Convert implication chain derivation to context derivation
**Dependency**: Nested modus ponens applications
**Difficulty**: Medium - structural recursion on context
**Impact**: Medium - helper for strong completeness

### Dependency Graph for Sorries

```
                    [AXIOM: representation_theorem_backward_empty]
                                    │
                                    ▼
                          [weak_completeness]
                                    │
                                    ▼
          ┌─────────────────────────┴─────────────────────────┐
          │                                                   │
          ▼                                                   ▼
[strong_completeness]                               [provable_iff_valid]
  ├── entails_imp_chain (sorry)
  └── imp_chain_to_context (sorry)

                    [mcs_contains_or_neg] (sorry)
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
          [mcs_modus_ponens]       [canonical_complete]
                (sorry)                    │
                    │                      ▼
                    ▼              [truthLemma cases]
           [TruthLemma helpers]
                    │
                    ▼
        [representation_theorem] (proven!)
                    │
                    ▼
      [consistent_implies_satisfiable] (sorry)
                    │
                    ▼
            [finite_model_property]
```

### Critical Path Analysis

**Blocking Chain 1 (Main Completeness)**:
1. `mcs_contains_or_neg` →
2. `mcs_modus_ponens` →
3. MCS closure properties →
4. Truth lemma (implicit, trivial by definition) →
5. Representation theorem (PROVEN!) →
6. `consistent_implies_satisfiable` →
7. AXIOM elimination →
8. Full completeness

**Blocking Chain 2 (Strong Completeness)**:
1. Solve `entails_imp_chain` helper
2. Solve `imp_chain_to_context` helper
3. Strong completeness follows from weak completeness

**Non-Blocking (Cleanup)**:
- `consistent_iff_consistent'` in Basic.lean
- `subformulaList_finite` in FiniteModelProperty.lean
- `necessitation_lemma` in TruthLemma.lean

### Proven Infrastructure Available

**Fully Proven Modules**:
1. **DeductionTheorem.lean** - Complete with termination proof
2. **MaximalConsistent.lean** - Complete including `set_lindenbaum` via Zorn's lemma
3. **Soundness.lean** - All axiom validity proofs, full soundness theorem
4. **representation_theorem** - Main theorem proven (consistency → satisfiable in canonical)

**Key Available Lemmas**:
- `set_lindenbaum`: Every consistent set extends to MCS
- `maximal_consistent_closed`: MCS is deductively closed
- `maximal_negation_complete`: φ ∉ MCS → ¬φ ∈ MCS (proven for list-based MCS!)
- `deduction_theorem`: (A :: Γ) ⊢ B → Γ ⊢ A → B
- `derives_neg_from_inconsistent_extension`: If φ :: Γ inconsistent, then Γ ⊢ ¬φ
- All axiom validity lemmas (prop_k_valid, prop_s_valid, etc.)

**Key Insight**: `maximal_negation_complete` is PROVEN for list-based MaximalConsistent but `mcs_contains_or_neg` has a sorry for set-based SetMaximalConsistent. The proof should be adaptable.

### README.md Assessment

**Current State** (from file):
- Architecture diagram is accurate
- "Proven (no sorry)" section is OUTDATED - claims set_lindenbaum proven but lists MCS properties as sorries
- "With Sorries" section needs comprehensive update
- Missing: Concrete completion roadmap, phase ordering

**Recommended Updates**:
1. Add accurate sorry count per file
2. Add dependency graph showing which sorries block which results
3. Add concrete completion phases with estimated effort
4. Clarify relationship between list-based MCS (proven) and set-based MCS (has sorries)

## Decisions

1. **Priority Order**: Focus on MCS properties first (mcs_contains_or_neg, mcs_modus_ponens) as they are the critical blocking dependency

2. **Adapt Existing Proofs**: The list-based `maximal_negation_complete` proof in MaximalConsistent.lean should guide the set-based `mcs_contains_or_neg` proof

3. **Axiom Elimination Strategy**: The `representation_theorem_backward_empty` axiom can be eliminated once:
   - `consistent_implies_satisfiable` is proven
   - This connects canonical world satisfiability to semantic satisfiability

4. **README Update Approach**: Create comprehensive documentation including:
   - Accurate sorry inventory
   - Dependency-ordered completion roadmap
   - Phase estimates

## Recommendations

### Phase 1: MCS Property Completion (2-3 hours)

**Files**: Representation/CanonicalModel.lean

**Tasks**:
1. Prove `mcs_contains_or_neg` by adapting `maximal_negation_complete` from MaximalConsistent.lean
   - Key insight: If φ ∉ S and ¬φ ∉ S, then both insert φ S and insert ¬φ S are inconsistent
   - This means both φ and ¬φ can be derived from S (via deduction theorem), contradiction

2. Prove `mcs_modus_ponens` using:
   - `mcs_contains_or_neg` for ψ (gives either ψ ∈ S or ¬ψ ∈ S)
   - If ψ ∈ S, done
   - If ¬ψ ∈ S, combine with φ ∈ S and (φ → ψ) ∈ S to derive ⊥, contradicting consistency

**Verification**: After completion, run `lake build Bimodal.Metalogic_v2.Representation.CanonicalModel`

### Phase 2: Bridge to Semantic Satisfiability (2-3 hours)

**Files**: Representation/FiniteModelProperty.lean

**Tasks**:
1. Prove `consistent_implies_satisfiable`:
   - From canonical world w, need to construct a TaskModel satisfying φ
   - Challenge: CanonicalWorldState is abstract (Set Formula), need concrete Duration/TaskFrame
   - Strategy: Use soundness in reverse - if consistent, cannot prove ⊥, so must have model

2. This may require:
   - Defining canonical TaskFrame from MCS structure
   - Or using completeness contrapositive: ¬provable → ¬valid → satisfiable

**Verification**: `lake build Bimodal.Metalogic_v2.Representation.FiniteModelProperty`

### Phase 3: Strong Completeness Helpers (1-2 hours)

**Files**: Completeness/StrongCompleteness.lean

**Tasks**:
1. Complete `entails_imp_chain` helper
   - Use semantic properties of implication
   - If all of Γ are true and φ → ψ is true, then ψ is true when φ is true

2. Complete `imp_chain_to_context` helper
   - Recursive application of modus ponens
   - If [] ⊢ ψ₁ → ... → ψₙ → φ and ψᵢ ∈ Γ, apply MP n times

**Verification**: `lake build Bimodal.Metalogic_v2.Completeness.StrongCompleteness`

### Phase 4: Axiom Elimination (1-2 hours)

**Files**: Representation/ContextProvability.lean

**Tasks**:
1. Replace `axiom representation_theorem_backward_empty` with theorem
2. Proof strategy:
   - Assume semantic_consequence [] φ (validity)
   - By contrapositive: if not provable, then [¬φ] is consistent
   - By representation_theorem, [¬φ] has canonical world w with ¬φ true
   - Connect to semantic model to show φ not valid, contradiction

**Verification**: `lake build Bimodal.Metalogic_v2` (full module)

### Phase 5: Cleanup and Documentation (1 hour)

**Files**:
- Core/Basic.lean (`consistent_iff_consistent'`)
- Representation/FiniteModelProperty.lean (`subformulaList_finite`)
- Representation/TruthLemma.lean (`necessitation_lemma`)
- README.md

**Tasks**:
1. Prove remaining minor sorries
2. Update README.md with:
   - Accurate "proven" vs "sorry" status
   - Completion confirmation
   - Architecture validation

**Verification**: `lake build Bimodal.Metalogic_v2` with zero sorries

### Effort Summary

| Phase | Effort | Critical Path |
|-------|--------|---------------|
| Phase 1: MCS Properties | 2-3 hours | YES |
| Phase 2: Semantic Bridge | 2-3 hours | YES |
| Phase 3: Strong Completeness | 1-2 hours | NO |
| Phase 4: Axiom Elimination | 1-2 hours | YES |
| Phase 5: Cleanup | 1 hour | NO |
| **Total** | **7-11 hours** | |

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| **MCS properties harder than expected** | Delays entire chain | Proof sketch available in MaximalConsistent.lean for list-based version |
| **Semantic bridge requires model construction** | May need new infrastructure | Can use completeness contrapositive instead |
| **Axiom elimination requires full truth lemma** | Additional work | Truth lemma is trivial by definition (φ true ↔ φ ∈ carrier) |
| **Strong completeness helpers complex** | May need recursion proof | Can leave as lower priority if main completeness works |
| **Import cycles during refactoring** | Build failures | Strict layering enforced by existing architecture |

## Appendix

### Search Queries Used

1. `lean_local_search "mcs_contains"` - Found mcs_contains_or_neg definition
2. `lean_local_search "maximal_negation_complete"` - Found proven version in MaximalConsistent.lean
3. `lean_local_search "representation_theorem"` - Confirmed main theorem is proven
4. `lean_local_search "deduction_theorem"` - Found fully proven in DeductionTheorem.lean

### Mathlib Resources

Relevant Mathlib patterns for MCS proofs:
- `Classical.em` for excluded middle
- `Classical.byContradiction` for indirect proofs
- `Set.mem_insert_iff` for set manipulation

### File Sizes

| File | Lines | Complexity |
|------|-------|------------|
| Core/Basic.lean | 98 | Low |
| Core/Provability.lean | 81 | Low |
| Core/DeductionTheorem.lean | 459 | High (proven) |
| Core/MaximalConsistent.lean | 457 | High (proven) |
| Soundness/Soundness.lean | 308 | Medium (proven) |
| Representation/CanonicalModel.lean | 221 | Medium |
| Representation/TruthLemma.lean | 181 | Medium |
| Representation/RepresentationTheorem.lean | 209 | Medium |
| Representation/ContextProvability.lean | 132 | Low |
| Representation/FiniteModelProperty.lean | 211 | Medium |
| Completeness/WeakCompleteness.lean | 96 | Low |
| Completeness/StrongCompleteness.lean | 158 | Medium |
| FMP.lean | ~50 | Low (hub) |
| Applications/Compactness.lean | ~100 | Low |
| README.md | 165 | Documentation |
