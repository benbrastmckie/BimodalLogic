# Research Report: Task #653 - Improve Metalogic Infrastructure

- **Task**: 653 - improve_metalogic_infrastructure
- **Started**: 2026-01-25T18:20:00Z
- **Completed**: 2026-01-25T18:45:00Z
- **Effort**: 25 minutes
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - Theories/Bimodal/latex/subfiles/04-Metalogic.tex (lines 142, 253)
  - Theories/Bimodal/Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean
  - Theories/Bimodal/Semantics/TaskFrame.lean
  - Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean
  - Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean
  - Theories/Bimodal/Boneyard/Metalogic_v2/Applications/Compactness.lean
  - Theories/Bimodal/Boneyard/README.md
- **Artifacts**: specs/653_improve_metalogic_infrastructure/reports/research-001.md
- **Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- SemanticCanonicalFrame exists only in the deprecated Boneyard (Metalogic_v2), NOT in the active Metalogic codebase
- The current active infrastructure uses IndexedMCSFamily with a universal parametric canonical model approach (no specialized frame structure named "SemanticCanonicalFrame" or "CanonicalTaskFrame")
- Infinite contexts/sets are currently handled trivially because Context = List Formula (finite by definition)
- True compactness for infinite sets would require migrating to Set-based contexts and leveraging Mathlib's FirstOrder.Language.Theory.isSatisfiable_iff_isFinitelySatisfiable
- The LaTeX documentation is out-of-sync with the current Lean implementation and references deprecated architecture

## Context & Scope

This research investigates two TODO comments in the LaTeX metalogic documentation:

1. **Line 142**: Renaming SemanticCanonicalFrame to CanonicalTaskFrame
2. **Line 253**: Addressing infinite contexts/sets via compactness

The investigation examined the current state of both the active Metalogic directory and the deprecated Boneyard code to understand the metalogic infrastructure architecture.

## Findings

### 1. SemanticCanonicalFrame Current Status

**Location**: Only in Boneyard (deprecated code)
- `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean` (line 245)
- This file is part of the deprecated "Metalogic_v2" approach documented in Boneyard/README.md

**Definition**:
```lean
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel phi
  nullity := semantic_task_rel_nullity phi
  compositionality := fun w u v d1 d2 => semantic_task_rel_compositionality phi w u v d1 d2
```

**Key Issues**:
- The `compositionality` field contains a `sorry` (line 230-236) - mathematically impossible to prove without bounding duration sums
- The frame is formula-specific (phi : Formula parameter)
- Uses finite time bounds: `FiniteTime (temporalBound phi)` with domain `[-k, k]`

**Active Infrastructure Uses Different Approach**:
The current active code in `Theories/Bimodal/Metalogic/` does NOT use SemanticCanonicalFrame. Instead:
- Uses `IndexedMCSFamily D` (parametric over duration type D)
- Constructs `canonical_model D family` and `canonical_history_family D family`
- No specialized frame structure with "Canonical" in the name
- The canonical model is built from a maximal consistent set family indexed by time

### 2. Naming Analysis: SemanticCanonicalFrame vs CanonicalTaskFrame

**Semantic Accuracy**:
- "Semantic" refers to the world-states-as-quotients approach (SemanticWorldState)
- "Canonical" refers to construction from maximal consistent sets
- "TaskFrame" is the base structure type from `Theories/Bimodal/Semantics/TaskFrame.lean`

**Current Usage in LaTeX** (line 143):
```latex
\begin{definition}[\texttt{SemanticCanonicalFrame}]
The \textbf{canonical semantic frame} has:
\begin{itemize}
  \item World states: Equivalence classes of history-time pairs over maximal consistent sets
  \item Times: Integers ($\mathbb{Z}$)
  \item Task relation: Defined via history existence (\texttt{SemanticTaskRelV2})
\end{itemize}
```

**Recommendation**:
The name "SemanticCanonicalFrame" is MORE accurate than "CanonicalTaskFrame" because:
1. It distinguishes from other canonical frame constructions (e.g., syntactic approach in Boneyard)
2. The "Semantic" qualifier highlights the quotient-based world state construction
3. The deprecated code uses this name correctly

**However**: This is MOOT because the active codebase doesn't use this structure at all. The LaTeX should be updated to reflect the IndexedMCSFamily approach.

### 3. Infinite Contexts and Compactness

**Current State**:
- Context type: `Context = List Formula` (from Bimodal.Syntax)
- ALL contexts are finite by definition
- Compactness theorems exist but are trivial (Boneyard/Metalogic_v2/Applications/Compactness.lean)

**From Compactness.lean (lines 15-24)**:
```lean
-- Important Note: Trivial for List-Based Contexts
-- These theorems are trivially true for our list-based `Context` type.
-- Since `Context = List Formula`, every context is already finite, so the
-- "finite subset" is simply the context itself. The theorems become:
-- - `compactness_satisfiability`: If Γ is satisfiable, then Γ is satisfiable
-- - `compactness_entailment`: If Γ ⊨ φ, then Γ ⊨ φ
--
-- For meaningful compactness results, one would need set-based infinite contexts.
```

**True Compactness Implementation Would Require**:

1. **Migrate to Set-based contexts**:
   - Change `Context` from `List Formula` to `Set Formula`
   - Update all proof system definitions to handle sets
   - Implement finitary derivability: a derivation can only use finitely many premises

2. **Leverage Mathlib compactness**:
   - `FirstOrder.Language.Theory.isSatisfiable_iff_isFinitelySatisfiable`
   - Maps first-order logic satisfiability to finite satisfiability
   - Located in `Mathlib.ModelTheory.Satisfiability`

3. **Adapt to modal/temporal logic**:
   - The Mathlib theorem is for first-order logic
   - Would need translation between modal formulas and first-order sentences
   - Or adapt the proof technique to TM bimodal logic directly

**Alternative: Document Limitation**:
- Keep list-based contexts (simpler, matches current proofs)
- Document in LaTeX that the logic handles finite contexts only
- Note that this is standard for many modal logic implementations
- Compactness is primarily useful for model-theoretic results, not practical proving

### 4. Architecture Gap: LaTeX vs Lean

**LaTeX References Deprecated Code**:
The LaTeX document references:
- `SemanticCanonicalFrame` (only in Boneyard, deprecated)
- `SemanticWorldState` (only in Boneyard)
- `semantic_truth_lemma_v2` (only in Boneyard)
- `SemanticTaskRelV2` (only in Boneyard)

**Active Code Uses**:
- `IndexedMCSFamily D` (parametric family of MCS)
- `canonical_model D family` (model built from family)
- `canonical_history_family D family` (history construction)
- `representation_theorem D phi h_cons` (in UniversalCanonicalModel.lean)
- `truth_lemma D family t phi` (in TruthLemma.lean)

**The Gap**:
The LaTeX documentation describes the Metalogic_v2 approach that was deprecated and moved to the Boneyard. The current implementation (as of Task 654, per file comments) uses a universal parametric approach with indexed families.

### 5. Related Files and Dependencies

**Active Metalogic Files**:
```
Theories/Bimodal/Metalogic/
├── Metalogic.lean                           # Top-level import
├── Core/
│   ├── Core.lean                            # Core imports
│   └── MaximalConsistent.lean               # Re-exports from Boneyard
└── Representation/
    ├── CanonicalWorld.lean                  # World state construction
    ├── CanonicalHistory.lean                # History construction
    ├── IndexedMCSFamily.lean                # MCS family with coherence
    ├── TaskRelation.lean                    # Task relation definition
    ├── TruthLemma.lean                      # Truth correspondence
    └── UniversalCanonicalModel.lean         # Representation theorem
```

**Boneyard (Deprecated)**:
```
Theories/Bimodal/Boneyard/
├── README.md                                # Deprecation rationale
├── Metalogic_v2/
│   ├── Representation/
│   │   └── SemanticCanonicalModel.lean     # Contains SemanticCanonicalFrame
│   └── Applications/
│       └── Compactness.lean                 # Trivial compactness
└── DeprecatedCompleteness.lean              # Documents deprecated theorems
```

**Key Dependencies**:
- `Theories/Bimodal/Semantics/TaskFrame.lean`: Base TaskFrame structure (parametric over D)
- `Theories/Bimodal/Syntax/Formula.lean`: Formula definition
- `Bimodal.Metalogic_v2.Core`: MaximalConsistent theory (still used from Boneyard)

### 6. TaskFrame Structure

**From TaskFrame.lean**:
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**Key Properties**:
- Generic over duration type D (Int, Rat, Real, etc.)
- Paper-aligned: Matches JPL paper definition exactly
- Nullity: Zero-duration task is identity
- Compositionality: Tasks compose with additive time

**No "Canonical" Variants in Active Code**:
- No specialized `CanonicalTaskFrame` type exists
- Canonical model uses standard `TaskFrame D` structure
- The "canonical" aspect is in the construction, not the type

### 7. Compactness Research (Mathlib)

**Mathlib Provides** (FirstOrder.Language.Theory):
1. `isSatisfiable_iff_isFinitelySatisfiable`: Classic compactness theorem
2. `models_iff_finset_models`: Consequence relation compactness
3. Proofs use ultraproduct/ultrafilter constructions

**Adaptation Challenge**:
- Mathlib compactness is for first-order logic
- Modal logic is not first-order (no uniform translation)
- Standard modal logic textbooks prove compactness via:
  1. Completeness theorem (syntactic ⟷ semantic)
  2. Finitary derivability (derivations use finite premises)
  3. Therefore: If Γ ⊨ φ, then finite Δ ⊆ Γ with Δ ⊢ φ, so Δ ⊨ φ

**TM Bimodal Specifics**:
- Temporal operators add complexity (G, H over time)
- Task relation with durations is non-standard
- Would need custom compactness proof, not direct Mathlib reuse

## Decisions

1. **Do NOT rename SemanticCanonicalFrame**: It only exists in deprecated Boneyard code. Removing the reference from LaTeX is more appropriate.

2. **Update LaTeX to match current implementation**: Document the IndexedMCSFamily approach, not the deprecated Metalogic_v2 approach.

3. **Do NOT implement true compactness for infinite sets**: The current list-based contexts are simpler and sufficient for the project's needs. Full compactness would require major refactoring with unclear benefit.

4. **Preserve trivial compactness theorems**: Keep them for API completeness and documentation, but clearly document the limitation.

## Recommendations

### Priority 1: Update LaTeX Documentation (High Impact, Low Effort)

**File**: `Theories/Bimodal/latex/subfiles/04-Metalogic.tex`

**Changes Needed**:

1. **Line 141-151**: Replace SemanticCanonicalFrame references
   ```latex
   % CURRENT (references deprecated code):
   \begin{definition}[\texttt{SemanticCanonicalFrame}]
   The \textbf{canonical semantic frame} has:
   ...

   % REPLACE WITH:
   \begin{definition}[Universal Canonical Model]
   The \textbf{canonical model} is built from an indexed MCS family:
   \begin{itemize}
     \item Indexed family: \texttt{IndexedMCSFamily D} assigns an MCS to each time $t : D$
     \item Temporal coherence: G/H formulas propagate between time-indexed MCS
     \item Canonical frame: \texttt{canonical\_model D family} with task relation via histories
     \item Duration type: Parametric over totally ordered abelian group $D$
   \end{itemize}
   The construction is formula-independent and universally parametric.
   \end{definition}
   ```

2. **Line 157-159**: Update Truth Lemma reference
   ```latex
   % CURRENT:
   \footnote{This is proven as \texttt{semantic\_truth\_lemma\_v2}.}

   % REPLACE WITH:
   \footnote{This is proven as \texttt{truth\_lemma} in UniversalCanonicalModel.lean.}
   ```

3. **Line 169-170**: Update Representation Theorem reference
   ```latex
   % CURRENT:
   \begin{theorem}[Representation Theorem (\texttt{representation\_theorem})]

   % UPDATE to be more specific:
   \begin{theorem}[Representation Theorem]
   Every consistent context is satisfiable in the canonical model.\footnote{%
   This is proven as \texttt{representation\_theorem} in %
   \texttt{Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean}.}
   \end{theorem}
   ```

4. **Line 252-253**: Address compactness TODO
   ```latex
   % CURRENT:
   % TODO: This still leaves infinite contexts/sets remaining to be addressed,
   % where this should be addressed by compactness

   % REPLACE WITH:
   \subsubsection{Note on Infinite Contexts}

   The current implementation uses list-based finite contexts (\texttt{Context = List Formula}).
   This makes the compactness theorem trivial: if every finite subset of $\Gamma$ is satisfiable,
   then $\Gamma$ is satisfiable (since $\Gamma$ is already finite).

   A true compactness result for infinite sets would require:
   \begin{enumerate}
     \item Migrating from \texttt{List Formula} to \texttt{Set Formula} contexts
     \item Ensuring derivability is finitary (derivations use finitely many premises)
     \item Proving: if $\Gamma \satisfies \varphi$, then finite $\Delta \subseteq \Gamma$
           with $\Delta \satisfies \varphi$
   \end{enumerate}

   This is a standard result in modal logic but is not required for the current
   completeness proof. See \texttt{Boneyard/Metalogic\_v2/Applications/Compactness.lean}
   for the trivial version with list-based contexts.
   ```

### Priority 2: Document Current Architecture (Medium Impact, Medium Effort)

Create a new documentation file explaining the current metalogic infrastructure:

**File**: `Theories/Bimodal/Metalogic/README.md`

**Contents**:
```markdown
# Bimodal Metalogic Infrastructure

## Overview

This directory contains the universal parametric canonical model construction for
proving completeness of TM bimodal logic.

## Architecture

### IndexedMCSFamily Approach

The key insight: Build a family of maximal consistent sets (MCS) indexed by time,
where each time point has its own MCS connected via temporal coherence conditions.

**Why not the same MCS at all times?**
- TM logic has IRREFLEXIVE temporal operators (G/H exclude the present)
- T-axiom (`G φ → φ`) is NOT valid in TM
- Same-MCS approach would require T-axiom for truth lemma

**Solution**:
- `IndexedMCSFamily D`: Maps each time `t : D` to an MCS
- Coherence conditions: `G φ ∈ mcs(t)` implies `φ ∈ mcs(t')` for `t' > t` (strictly future)
- Matches irreflexive semantics perfectly

### Main Components

1. **IndexedMCSFamily.lean**: Family structure with temporal coherence
2. **CanonicalWorld.lean**: World state construction from MCS
3. **CanonicalHistory.lean**: History construction from family
4. **TaskRelation.lean**: Task relation definition
5. **TruthLemma.lean**: Truth correspondence (MCS membership ⟷ semantic truth)
6. **UniversalCanonicalModel.lean**: Representation theorem (consistent → satisfiable)

### Duration Parametricity

All constructions are parametric over the duration type `D`:
- `D` must be a totally ordered abelian group (AddCommGroup, LinearOrder, IsOrderedAddMonoid)
- Examples: Int, Rat, Real, custom bounded groups
- Matches JPL paper specification exactly

## Relation to Boneyard Code

The `Boneyard/Metalogic_v2/` directory contains deprecated code using:
- `SemanticCanonicalFrame`: Formula-specific finite canonical frame
- `SemanticWorldState`: Quotient-based world states
- Fixed time bounds: FiniteTime with domain [-k, k]

This approach was deprecated due to:
1. Compositionality sorry (mathematically impossible for unbounded durations)
2. Formula-dependence (not universally parametric)
3. Truth bridge complexity

The current IndexedMCSFamily approach avoids these issues.

## Related Files

- **Boneyard/README.md**: Explains why previous approaches were deprecated
- **Semantics/TaskFrame.lean**: Base TaskFrame structure
- **latex/subfiles/04-Metalogic.tex**: LaTeX documentation (needs update)
```

### Priority 3: Code Cleanup (Low Impact, Low Effort)

**Remove TODO comments from LaTeX**:
- Line 142: Remove after updating to IndexedMCSFamily approach
- Line 253: Remove after adding the infinite contexts note

**Consider**: Add deprecation notice in SemanticCanonicalModel.lean header:
```lean
/-!
# DEPRECATED: Semantic Canonical Model (Metalogic_v2)

**Status**: This file is in the Boneyard and should not be used for active development.

**Deprecated**: 2026-01-19
**Replacement**: Use `IndexedMCSFamily` approach in `Theories/Bimodal/Metalogic/`

See `Boneyard/README.md` for deprecation rationale.
-/
```

### Priority 4: Future Enhancement (Optional, High Effort)

**If true compactness for infinite sets becomes needed**:

1. **Phase 1: Set-based contexts**
   - Define `SetContext = Set Formula`
   - Implement finitary derivability predicate
   - Migrate proof system to handle sets

2. **Phase 2: Compactness proof**
   - Prove: Γ ⊨ φ → ∃ finite Δ ⊆ Γ, Δ ⊨ φ
   - Use completeness + finitary derivability
   - Technique: Γ ⊨ φ → Γ ⊢ φ (completeness) → finite Δ ⊢ φ (finitary) → Δ ⊨ φ (soundness)

3. **Phase 3: Model-theoretic applications**
   - Löwenheim-Skolem style results
   - Interpolation theorems
   - Decidability applications

**Effort estimate**: 40-60 hours (major refactoring)

**Benefit**: Mainly theoretical interest, unlikely to impact practical theorem proving

## Risks & Mitigations

### Risk 1: LaTeX-Lean Divergence

**Risk**: LaTeX documentation continues to reference deprecated code
**Impact**: User confusion, incorrect understanding of implementation
**Likelihood**: High (already occurring)

**Mitigation**:
1. Update LaTeX immediately (Priority 1 recommendation)
2. Add comments in Boneyard code warning against use
3. Create Metalogic/README.md documenting current approach

### Risk 2: Compactness Expectation Mismatch

**Risk**: Users expect true compactness for infinite sets
**Impact**: Limitation discovered late in a proof attempt
**Likelihood**: Low (most modal logic uses finite contexts)

**Mitigation**:
1. Document limitation clearly in LaTeX
2. Add note to compactness theorems explaining triviality
3. If needed, implement Priority 4 (set-based contexts)

### Risk 3: Boneyard Code Bit Rot

**Risk**: SemanticCanonicalModel.lean fails to build in future
**Impact**: Unable to compare approaches or extract ideas
**Likelihood**: Medium (unmaintained code degrades)

**Mitigation**:
1. Document deprecation reason thoroughly (already done in README.md)
2. Extract any reusable lemmas to active codebase
3. Accept that Boneyard code may become unbuildable (standard for deprecated code)

## Appendix

### A. Search Query Results

**lean_local_search queries**:
- `SemanticCanonicalFrame`: No results in active code (only in Boneyard)
- `CanonicalTaskFrame`: No results anywhere
- `representation_theorem`: 11 results (active: UniversalCanonicalModel.lean, deprecated: Boneyard files)
- `compactness`: 5 results (all in Boneyard/Metalogic_v2/Applications)

**File structure**:
```
Theories/Bimodal/
├── Semantics/TaskFrame.lean          # Base TaskFrame structure
├── Metalogic/                         # Active canonical model
│   ├── Core/MaximalConsistent.lean   # Re-exports from Boneyard
│   └── Representation/
│       ├── IndexedMCSFamily.lean     # New approach
│       ├── UniversalCanonicalModel.lean
│       └── TruthLemma.lean
├── Boneyard/                          # Deprecated code
│   ├── README.md                      # Deprecation docs
│   ├── Metalogic_v2/
│   │   ├── Representation/SemanticCanonicalModel.lean  # Old approach
│   │   └── Applications/Compactness.lean
│   └── DeprecatedCompleteness.lean
└── latex/subfiles/04-Metalogic.tex   # Out-of-sync docs
```

### B. Mathlib Compactness Theorems

**FirstOrder.Language.Theory.isSatisfiable_iff_isFinitelySatisfiable**:
- Type: `∀ {L : FirstOrder.Language} {T : L.Theory}, Iff T.IsSatisfiable T.IsFinitelySatisfiable`
- Module: `Mathlib.ModelTheory.Satisfiability`
- Proof technique: Ultraproduct construction

**Adaptation to modal logic**:
- Modal logic is not first-order (no uniform translation)
- Would need custom proof following standard modal logic textbooks
- Or: Translate to first-order via standard translation (complex)

### C. Coherence Conditions Rationale

**IndexedMCSFamily temporal coherence**:

```lean
forward_G : ∀ t t' phi, t < t' → Formula.all_future phi ∈ mcs t → phi ∈ mcs t'
backward_H : ∀ t t' phi, t' < t → Formula.all_past phi ∈ mcs t → phi ∈ mcs t'
forward_H : ∀ t t' phi, t < t' → Formula.all_past phi ∈ mcs t' → phi ∈ mcs t
backward_G : ∀ t t' phi, t' < t → Formula.all_future phi ∈ mcs t' → phi ∈ mcs t
```

**Why four conditions**:
1. `forward_G`: G propagates formulas to strictly future (matches G semantics)
2. `backward_H`: H propagates formulas to strictly past (matches H semantics)
3. `forward_H`: Looking back from future ensures past consistency
4. `backward_G`: Looking forward from past ensures future consistency

All use STRICT inequality (< not ≤) matching TM's irreflexive operators.

### D. References

**Key Papers**:
- JPL Paper "The Perpetuity Calculus of Agency" (task frame definition)
- Blackburn et al. "Modal Logic" Chapter 4 (canonical models, compactness)

**Implementation Files**:
- Active: `Theories/Bimodal/Metalogic/Representation/*.lean`
- Deprecated: `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/*.lean`
- Documentation: `Theories/Bimodal/Boneyard/README.md`

**Related Tasks** (mentioned in Boneyard/README.md):
- Task 446: Original Duration construction
- Task 458: Completeness research identifying gaps
- Task 473: SemanticWorldState architecture
- Task 626: Review and remove unnecessary sorries
- Task 654: Universal parametric canonical model (current approach)
