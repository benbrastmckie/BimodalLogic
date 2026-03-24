# Deep Research Report: Task #41

**Task**: Eliminate D=CanonicalMCS pattern systematically
**Date**: 2026-03-23
**Mode**: Deep research (follow-up to team research)
**Focus**: Migration strategy, dependency analysis, and zero-sorry approach

## Executive Summary

The D=CanonicalMCS pattern is a **mathematically valid but architecturally problematic** technique that trivializes F/P witness obligations. This deep research confirms the team research findings and provides:

1. A precise enumeration of the 16 active usages of the pattern
2. A dependency-ordered migration strategy
3. The critical insight that D=CanonicalMCS is **load-bearing for the publication path** and cannot simply be removed
4. A recommended architecture that keeps CanonicalMCS for proof-theoretic purposes while adding proper D=Int for semantic purposes

## Key Finding: The Pattern is Load-Bearing

**Critical**: The `temporal_coherent_family_exists_CanonicalMCS` theorem (CanonicalFMCS.lean:325-343) is the **only sorry-free** existence theorem for temporally coherent families. The SuccChain construction uses `f_nesting_boundary` and `p_nesting_boundary` which are **blocked** (lines 728-735, 963-970) because they require `RestrictedMCS`, not arbitrary `SetMaximalConsistent`.

This means:
- **D=CanonicalMCS is required** for the current sorry-free completeness path
- Simply removing it would reintroduce sorries
- The correct approach is **coexistence**: D=CanonicalMCS for TruthLemma, D=Int for semantic model

## Architectural Analysis

### What D=CanonicalMCS Actually Means

```lean
-- CanonicalFMCS.lean:202
noncomputable def canonicalMCSBFMCS : FMCS CanonicalMCS where
  mcs := canonicalMCS_mcs  -- mcs(w) = w.world (identity!)
  ...
```

| Aspect | Standard FMCS | FMCS CanonicalMCS |
|--------|---------------|-------------------|
| D type | Int, Rat, TimelineQuot | CanonicalMCS (all MCSes) |
| mcs function | Maps time -> world | Identity: mcs(w) = w.world |
| F witness | Must construct s > t | Trivial: Lindenbaum gives MCS |
| P witness | Must construct s < t | Trivial: Lindenbaum gives MCS |
| Semantic meaning | Timeline positions | Degenerate (no time structure) |

### Why It "Works"

From CanonicalFMCS.lean:36-42:
```lean
-- Given a root MCS M₀, we construct a FMCS where:
-- - The domain is `CanonicalMCS` (all maximal consistent sets)
-- - Each element `w` maps directly to `w.world` (the MCS itself)
-- - `forward_F` uses canonical_forward_F - witness MCS IS a domain element
-- - `backward_P` uses canonical_backward_P - witness MCS IS a domain element
```

The Lindenbaum MCS construction produces witness MCSes that are **automatically** in the domain (since CanonicalMCS = all MCSes). No reachability or chain membership proofs needed.

### The Blocking Problem for D=Int

From SuccChainFMCS.lean:718-735:
```lean
-- **BLOCKED (mathematically false)**: F-nesting boundedness for arbitrary MCS.
-- This theorem CANNOT be proven because an arbitrary MCS can consistently contain
-- all F-iterations. Counterexample: the set {F^n(p) | n ∈ Nat} is consistent...
```

The F/P witness existence for D=Int requires showing that F-depth is bounded in chain MCSes. This requires `RestrictedMCS` (finite subformula closure), but the current construction uses arbitrary MCS.

## Dependency Graph

### Files Using D=CanonicalMCS Pattern (Active Code)

| File | Location | Usage Type | Removable? |
|------|----------|------------|------------|
| `CanonicalFMCS.lean` | Lines 202, 325-343 | Primary definition, existence theorem | No (load-bearing) |
| `FMCSDef.lean` | Lines 20-31 | Documentation only | Yes (doc update) |
| `FMCSTransfer.lean` | Lines 82, 379 | Transfer mechanism FROM CanonicalMCS | Keep (enables D=Int) |
| `ModallyCoherentBFMCS.lean` | Lines 54, 95, 144-146 | Modal coherence proofs | Keep (for BFMCS) |
| `SaturatedBFMCSConstruction.lean` | Lines 189, 191 | Saturation proofs | Keep (BFMCS support) |
| `MultiFamilyBFMCS.lean` | Lines 135, 213, 364, etc. | Dead end (documented) | Archive to Boneyard |
| `LogicVariants.lean` | Line 155 | Variant existence | Review needed |

### Dead Code to Archive

From MultiFamilyBFMCS.lean:17-33:
```lean
-- **STATUS**: DEAD END - W=D CONFLATION
-- **DEAD END: singletonCanonicalBFMCS (lines 175-289)**
-- The singleton BFMCS approach using CanonicalMCS as domain is MATHEMATICALLY IMPOSSIBLE
-- **DEAD END: canonical_modal_backward (lines 531-572)**
-- Same issue: attempts to prove φ ∈ t.world → □φ ∈ t.world, which is false.
```

These are already documented as dead ends and should be archived to Boneyard.

## Migration Strategy

### Phase 1: Documentation Update (Immediate)

1. Update FMCSDef.lean docstrings to clarify:
   - D=CanonicalMCS is a **proof-theoretic construction**, not a semantic model
   - It is **intended and correct** for TruthLemma purposes
   - New code should prefer D=Int via FMCSTransfer when building semantic models

2. Add architectural note to CanonicalFMCS.lean explaining the coexistence design.

### Phase 2: Archive Dead Code (Low Risk)

Move to Boneyard:
- `MultiFamilyBFMCS.singletonCanonicalBFMCS` (lines 213-289)
- `MultiFamilyBFMCS.canonical_modal_backward` (lines 531-572)
- `MultiFamilyBFMCS.flagFMCS_over_CanonicalMCS` if unused

### Phase 3: Build D=Int Path (Requires Task 48 Completion)

The D=Int path requires:

1. **Task 48** (in progress): Prove succ_chain_fam MCS have bounded F-depth
   - Key: Establish `RestrictedMCS` evidence for chain MCSes
   - This unblocks `f_nesting_boundary` proof

2. **Task 36** (depends on 48): Prove f_nesting_boundary without sorry

3. **Task 37** (depends on 36): Prove p_nesting_boundary without sorry

4. **FMCSTransfer instantiation**: Create `FMCSTransfer Int` that:
   - `embed`: Maps CanonicalMCS elements to their position in the chain
   - `retract`: Maps Int positions back to chain MCSes
   - Requires chain completeness (every MCS appears at some index)

### Phase 4: Enable D=Int for Completeness (Goal)

Once Phase 3 completes:
1. `transferredFMCS` (FMCSTransfer.lean:194) gives `FMCS Int` with sorry-free F/P
2. Use this for semantic completeness arguments
3. Keep `FMCS CanonicalMCS` for TruthLemma (unchanged)

## Critical Constraints

### Zero-Debt Policy Compliance

**MUST NOT**:
- Remove CanonicalFMCS.lean (sorry-free infrastructure needed)
- Add sorries to replace current sorry-free proofs
- Use D=Int with blocked f_nesting_boundary (would add sorries)

**MUST**:
- Wait for Task 48 completion before D=Int migration
- Keep CanonicalMCS path operational during transition
- Archive only confirmed-dead code to Boneyard

### What Task 41 Should Actually Do

Given the analysis, Task 41 scope should be:

1. **Immediate (no dependencies)**:
   - Archive dead code from MultiFamilyBFMCS.lean to Boneyard
   - Update documentation to clarify architectural intent
   - Review LogicVariants.lean usage

2. **Deferred (depends on 48, 36, 37)**:
   - Implement FMCSTransfer for D=Int
   - Create D=Int completeness path
   - Add architectural guards preventing W=D conflation in new code

## Comparison with Team Research

| Aspect | Team Research | Deep Research |
|--------|---------------|---------------|
| D=CanonicalMCS validity | Valid but problematic | Confirmed: load-bearing |
| DovetailedTimelineQuot | Recommended alternative | In Boneyard; not active |
| D=Int feasibility | Blocked | Blocked on Task 48 |
| Migration approach | Staged separation | Confirmed: coexistence model |
| Immediate actions | Remove 3 axioms, dead code | Archive dead code, update docs |

The team research correctly identified the issues. This deep research adds:
1. Precise enumeration of usages
2. Dependency ordering on Task 48
3. Confirmation that removal would add sorries

## Recommendations

### Recommended Implementation Plan

1. **Archive Dead Code** (1-2 hours, no dependencies)
   - Move MultiFamilyBFMCS dead-end code to Boneyard
   - Update file header documentation

2. **Documentation Clarification** (1 hour, no dependencies)
   - Add "Architectural Intent" sections to CanonicalFMCS.lean and FMCSDef.lean
   - Clarify that D=CanonicalMCS is proof-theoretic, not semantic

3. **Defer D=Int Migration** (blocks on Tasks 48, 36, 37)
   - FMCSTransfer instantiation for Int requires sorry-free f_nesting_boundary
   - Task 48 must complete first

### Success Criteria

Task 41 is complete when:
- [ ] Dead code archived to Boneyard
- [ ] Documentation updated with architectural intent
- [ ] No new sorries introduced
- [ ] Build passes with zero axiom changes

## Appendix: File-by-File Analysis

### CanonicalFMCS.lean (346 lines) - KEEP

Core infrastructure. Provides:
- `CanonicalMCS` type definition (lines 96-100)
- `canonicalMCSBFMCS` FMCS instance (line 202)
- `temporal_coherent_family_exists_CanonicalMCS` (lines 325-343)

Status: Sorry-free, load-bearing. Do not modify except for documentation.

### FMCSDef.lean (137 lines) - UPDATE DOCS

Core FMCS definition. Contains:
- Documentation about D=CanonicalMCS at lines 20-31
- Warning about W=D conflation at lines 33-37

Action: Strengthen documentation to clarify architectural intent.

### FMCSTransfer.lean (~400 lines) - KEEP

Domain transfer mechanism. Key theorems:
- `fmcs_domain_transfer` (line 352)
- `transfer_forward_F` (line 254)
- `transfer_backward_P` (line 305)

Status: Sorry-free. Enables future D=Int path.

### MultiFamilyBFMCS.lean (~610 lines) - PARTIAL ARCHIVE

Contains both dead and active code:
- Dead: `singletonCanonicalBFMCS`, `canonical_modal_backward`
- Active: `AllCanonicalMCS_FMCS`, modal coherence lemmas

Action: Archive dead code, keep active code.

### ModallyCoherentBFMCS.lean (~285 lines) - KEEP

Modal coherence infrastructure:
- `identity_mcs_modal_forward` (line 95)
- `modal_backward_from_saturation` (line 144)

Status: Sorry-free. Required for BFMCS modal coherence.
