# Research Report: Task #695

**Task**: 695 - Review Boneyard completeness attempts and remove misleading material
**Started**: 2026-01-28
**Completed**: 2026-01-28
**Effort**: Medium
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Boneyard directory analysis, README files, Lean source files
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The Boneyard contains **three distinct deprecated completeness approaches**, each with different failure modes
- The existing README documentation is **comprehensive and accurate** - the material is already well-annotated with deprecation notices
- No material needs to be removed; the Boneyard serves as valuable historical documentation
- The current correct approach (IndexedMCSFamily with task-specific semantics) is in active development in `Theories/Bimodal/Metalogic/Representation/`
- Recommendation: Add cross-reference notes between Boneyard and active code rather than removing material

## Context & Scope

### Research Question

Review the Boneyard directory for misleading material related to completeness attempts that:
1. Did not make the representation theorem central
2. Used the wrong definition of canonical model (not matching task semantics)

### Files Analyzed

**Boneyard Root**:
- `Theories/Bimodal/Boneyard/README.md` - Main deprecation documentation
- `Theories/Bimodal/Boneyard/DeprecatedCompleteness.lean` - Documents removed theorems
- `Theories/Bimodal/Boneyard/SyntacticApproach.lean` - Documents deprecated syntactic approach
- `Theories/Bimodal/Boneyard/DurationConstruction.lean` - Documents deprecated Duration-based approach

**Boneyard Metalogic**:
- `Theories/Bimodal/Boneyard/Metalogic/README.md` - Metalogic structure documentation
- `Theories/Bimodal/Boneyard/Metalogic/Representation/*.lean` - Canonical model construction files
- `Theories/Bimodal/Boneyard/Metalogic/Completeness/*.lean` - Completeness theorem files

**Boneyard Metalogic_v2**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/README.md` - v2 reorganization documentation
- `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Semantic canonical model with known limitations
- `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/CanonicalModel.lean` - Standard Kripke canonical model

**Current Active Development**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Current approach
- `Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean` - Task-specific canonical worlds
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` - Task relation definition

## Findings

### Finding 1: Three Deprecated Approaches Identified

The Boneyard contains three distinct deprecated completeness approaches:

#### Approach A: Syntactic Approach (Negation-Completeness Issue)

**Location**: `Boneyard/SyntacticApproach.lean`, originally from `Metalogic/Completeness/FiniteCanonicalModel.lean`

**Problem**: Did NOT make the representation theorem central
- Used `IsLocallyConsistent` which captures only soundness (one direction)
- Missing negation-completeness (maximality) needed for truth lemma backward directions
- 6+ sorry gaps in `finite_truth_lemma` backward directions

**Why Misleading**:
- Suggests that local consistency is sufficient for completeness
- Truth lemma requires negation-completeness: for all phi, either phi or ~phi is in the state
- This approach bypasses the representation theorem's role in establishing negation-completeness

**Current Status**: Well-documented in `SyntacticApproach.lean` with clear deprecation notice

#### Approach B: Duration Construction (Wrong Canonical Model)

**Location**: `Boneyard/DurationConstruction.lean`, originally from `Metalogic/Completeness.lean`

**Problem**: Used a complex Duration-based time type that doesn't match task semantics
- Built Grothendieck group completion of temporal chain segments
- 15+ sorry gaps in basic algebraic properties
- Attempted to be "agnostic" about temporal structure when finite model property makes this unnecessary

**Why Misleading**:
- Suggests completeness requires general Duration algebra
- The finite model property shows bounded time domains are sufficient
- Task semantics use `TaskFrame` with specific compositionality requirements that Duration struggles to satisfy

**Current Status**: Well-documented in `DurationConstruction.lean` with clear deprecation notice

#### Approach C: Semantic Canonical Model (Compositionality Issue)

**Location**: `Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean`

**Problem**: Uses standard Kripke semantics that doesn't match task-specific semantics
- `SemanticCanonicalFrame` has a sorry in compositionality (mathematically impossible for unbounded durations)
- The "truth bridge" lemma from general validity to finite model truth is incomplete
- Quantifies over ALL world histories/times which is incompatible with finite model truth

**Why Misleading**:
- Suggests standard Kripke canonical models work for TM bimodal logic
- Task semantics require specific compositionality properties that standard constructions cannot satisfy
- The `semantic_weak_completeness` theorem is actually sorry-free but works around this by avoiding the truth bridge entirely

**Current Status**: `DEPRECATED` header at top of file, detailed documentation of limitations

### Finding 2: Standard Kripke vs Task-Specific Semantics

The key distinction that makes some Boneyard material misleading:

**Standard Kripke Semantics** (in Boneyard):
- Worlds are maximal consistent sets (MCS)
- Accessibility based on modal formula propagation (box phi in w implies phi in v)
- No explicit time or task relation structure
- Works for standard modal logic K, K4, S4, S5

**Task-Specific Semantics** (correct approach):
- `TaskFrame D` with explicit duration type D
- `task_rel : WorldState -> D -> WorldState -> Prop` with nullity and compositionality
- `WorldHistory` paths through the frame
- Time-indexed MCS families (`IndexedMCSFamily`) where each time point has its own MCS

The Boneyard canonical models (especially in `Metalogic_v2/Representation/CanonicalModel.lean`) use standard Kripke accessibility:
```lean
box_accessibility := fun w =>
  { w' : CanonicalWorldState |
    ∀ φ, Formula.box φ ∈ w.carrier → φ ∈ w'.carrier }
```

This is NOT wrong for standard modal logic, but it's NOT what the TM bimodal logic with task semantics requires.

### Finding 3: Current Correct Approach

The current correct approach in `Theories/Bimodal/Metalogic/Representation/` uses:

1. **IndexedMCSFamily**: Family of MCS indexed by time with temporal coherence
   - `forward_G`: G formulas propagate to strictly future times
   - `backward_H`: H formulas propagate to strictly past times
   - Matches irreflexive temporal operators (no T-axiom required)

2. **CanonicalWorld**: Pairs MCS with abstract time point from ordered group D
   - Parametric over any duration type D
   - Task relation defined via time arithmetic + formula propagation

3. **TaskRelation**: Canonical task relation defined to make frame conditions trivial
   - Nullity holds by construction (identity for d=0)
   - Compositionality follows from time arithmetic

### Finding 4: Existing Documentation is Comprehensive

The Boneyard README files already contain:
- Clear `DO NOT USE` warnings
- Detailed explanations of why each approach failed
- References to replacement approaches
- Task history linking to original development

**Key Documentation Locations**:
- `Boneyard/README.md`: Overview of all three approaches with deprecation rationale
- `Boneyard/Metalogic_v2/README.md`: Architecture diagram and theorem status
- `DeprecatedCompleteness.lean`: Documents removed theorems with technical explanations

### Finding 5: Material That Could Cause Confusion

While well-documented, these specific elements could still confuse developers:

1. **`CanonicalWorldState` in Boneyard vs `CanonicalWorld` in active code**
   - Same name concept, different structures
   - Boneyard version is MCS-only (standard Kripke)
   - Active version pairs MCS with time point (task-specific)

2. **`semantic_weak_completeness` in SemanticCanonicalModel.lean**
   - This theorem IS proven and correct
   - But it works by avoiding the problematic truth bridge
   - Could mislead into thinking the full `main_provable_iff_valid_v2` is resolved

3. **`CanonicalModel` vs `IndexedMCSFamily` terminology**
   - Multiple files define "canonical model" with different meanings
   - Standard Kripke canonical model != task-specific canonical model

## Decisions

Based on the analysis, the following decisions are made:

### Decision 1: Do NOT Remove Boneyard Material

**Rationale**:
- The Boneyard serves as valuable historical documentation
- All deprecated code is already well-annotated with warnings
- Removing would lose context for why certain approaches don't work
- The `sorry` gaps serve as permanent documentation of mathematical obstacles

### Decision 2: Add Cross-Reference Notes

The implementation plan should add notes in key locations:

1. **In Boneyard README**: Add explicit pointer to current correct approach
2. **In `SemanticCanonicalModel.lean`**: Clarify that `semantic_weak_completeness` is correct but limited
3. **In active `IndexedMCSFamily.lean`**: Add note distinguishing from Boneyard approaches

### Decision 3: Keep DeprecatedCompleteness.lean

This file documents removed theorems and should be preserved because:
- Explains why certain mathematical approaches are impossible
- Documents the compositionality obstruction for unbounded durations
- Provides reference for anyone attempting similar approaches

## Recommendations

### Recommendation 1: Enhance Boneyard README (Priority: High)

Add a section explicitly contrasting standard Kripke vs task-specific semantics:

```markdown
## Standard Kripke vs Task-Specific Semantics

The code in this Boneyard uses STANDARD KRIPKE semantics which is NOT
appropriate for TM bimodal logic with task semantics. Key differences:

| Aspect | Standard Kripke (Boneyard) | Task-Specific (Current) |
|--------|---------------------------|-------------------------|
| Worlds | MCS only | MCS + time point |
| Accessibility | Formula propagation | TaskRelation with D |
| Time | Implicit | Explicit ordered group D |
| Compositionality | N/A | Required by TaskFrame |

For current correct approach, see:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- `Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean`
```

### Recommendation 2: Add Warning Comment to SemanticCanonicalModel.lean (Priority: Medium)

Enhance the existing DEPRECATED header to clarify the semantic distinction:

```lean
/-!
# CRITICAL: This file uses STANDARD KRIPKE semantics

The canonical model construction here uses standard modal logic
accessibility relations. This is mathematically correct for basic
modal logic but DOES NOT MATCH the task semantics required for
TM bimodal logic completeness.

For task-specific canonical model, see:
`Bimodal.Metalogic.Representation.IndexedMCSFamily`
-/
```

### Recommendation 3: Document the "Representation Theorem Central" Principle (Priority: Medium)

In the active code, add documentation explaining why representation must be central:

```lean
/-!
## Why Representation Theorem Must Be Central

Previous approaches (see Boneyard/) failed because they didn't make
the representation theorem central:

1. **Syntactic Approach**: Started with local consistency, couldn't
   achieve negation-completeness for truth lemma backward directions

2. **Duration Approach**: Started with Duration algebra, couldn't
   satisfy compositionality axiom

The correct approach:
1. Start with MCS properties (negation-completeness by construction)
2. Build IndexedMCSFamily with temporal coherence
3. Derive task relation that satisfies frame conditions by construction
4. Representation theorem then follows naturally

This "MCS-first" design avoids the mathematical obstructions that
blocked previous approaches.
-/
```

## Risks & Mitigations

### Risk 1: Confusion Between Boneyard and Active Code

**Likelihood**: Medium
**Impact**: Medium
**Mitigation**: Cross-reference notes in both locations; distinct naming if possible

### Risk 2: Developer Uses Boneyard as Template

**Likelihood**: Low (README clearly says DO NOT USE)
**Impact**: High (wasted effort)
**Mitigation**: Ensure Boneyard files don't compile cleanly; add compile-time warnings if possible

### Risk 3: Loss of Historical Context if Material Removed

**Likelihood**: High if material removed
**Impact**: Medium (repeated mistakes)
**Mitigation**: Do NOT remove; preserve as documentation

## Appendix

### Search Queries Used

1. Glob patterns:
   - `**/Boneyard/**/*.lean` - All Boneyard Lean files
   - `**/Boneyard/**/README*` - All Boneyard documentation

2. Grep patterns:
   - `completeness|canonical|representation` - Key concept identification
   - Case-insensitive search across all `.lean` files

### Key Files by Approach

**Syntactic Approach Files**:
- `Boneyard/SyntacticApproach.lean`
- `Boneyard/Metalogic/Representation/CanonicalModel.lean`
- `Boneyard/Metalogic/Representation/TruthLemma.lean`
- `Boneyard/Metalogic/Representation/RepresentationTheorem.lean`

**Duration Approach Files**:
- `Boneyard/DurationConstruction.lean`
- `Boneyard/Metalogic/Completeness.lean` (Duration definitions)

**Semantic Canonical Model Files**:
- `Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean`
- `Boneyard/Metalogic_v2/Representation/CanonicalModel.lean`
- `Boneyard/DeprecatedCompleteness.lean`

**Current Correct Approach Files**:
- `Metalogic/Representation/IndexedMCSFamily.lean`
- `Metalogic/Representation/CanonicalWorld.lean`
- `Metalogic/Representation/TaskRelation.lean`

### Sorry Count Summary

| Location | Sorry Count | Category |
|----------|-------------|----------|
| Boneyard/Metalogic/ | 9+ | Deprecated |
| Boneyard/Metalogic_v2/ | 4+ | Deprecated |
| Active Metalogic/Representation/ | 10+ | Work in progress |

The active code sorries are expected as the IndexedMCSFamily approach is under active development (Task 654 series).
