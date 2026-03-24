# Task 949 Research Report: Update Demo.lean for Bimodal Logic

**Task**: update_demo_lean_bimodal_logic
**Session**: sess_1773627748_1dbc71
**Date**: 2026-03-15

## Executive Summary

The current `Theories/Bimodal/Examples/Demo.lean` file compiles successfully (with warnings only) but requires significant updates to reflect the current API state. Key findings:

1. **Build Status**: Demo.lean compiles with the current API
2. **Obsolete Content**: References to archived completeness theorems (`standard_weak_completeness`) need removal
3. **New Features**: Task 956/967/968 completions add significant new capabilities to showcase
4. **Sorry Status**: `main_provable_iff_valid` contains 1 sorry (completeness direction)

## Current Demo.lean Analysis

### File Location
`Theories/Bimodal/Examples/Demo.lean` (492 lines)

### Compilation Status
- **Builds successfully** via `lake build Bimodal.Examples.Demo`
- Only warnings (unused simp args, deprecated functions in dependencies)
- No errors in Demo.lean itself

### Current Structure
1. **Section 1: Quick Tour** - Perpetuity principles P1-P6, metalogical results
2. **Section 2: Interactive Exploration** - Step-by-step proof construction
3. **Section 3: Decision Procedure** - Validity checking demonstrations
4. **Section 4: Applications** - Philosophical examples (laws of nature, math truths)

### Issues Identified

1. **Commented-out imports** (lines 6, 49-51):
   ```lean
   -- import Bimodal.Metalogic.Representation  -- ARCHIVED
   -- open Bimodal.Metalogic.Representation (standard_weak_completeness ...)
   ```
   These reference archived Int-indexed completeness (now in Boneyard).

2. **Sorry in main theorem** (line 70):
   ```lean
   theorem main_provable_iff_valid (φ : Formula) : Nonempty (⊢ φ) ↔ valid φ := by
     -- completeness direction has sorry
   ```

3. **Outdated documentation** (lines 54-70):
   The docstring references "pending rebuild on D-from-syntax pipeline (Task 960)" but Task 956 completed this work differently.

4. **Missing new features**: Does not showcase:
   - `cantor_iso` (D construction via Cantor isomorphism)
   - `bmcs_truth_lemma` (sorry-free BFMCS truth lemma)
   - `denseCanonicalTaskFrame` (pure-syntax TaskFrame)
   - Shift-closure infrastructure (Task 968)

## Available API Survey

### Core Modules (Working, Compilable)

| Module | Purpose | Key Exports |
|--------|---------|-------------|
| `Bimodal.Syntax.Formula` | Formula type | `Formula`, `atom`, `box`, `all_future`, etc. |
| `Bimodal.ProofSystem.Derivation` | Proof system | `DerivationTree`, `⊢` notation, 7 rules |
| `Bimodal.Semantics.Validity` | Validity | `truth_at`, `valid`, `valid_dense` |
| `Bimodal.Metalogic.Soundness` | Soundness | `soundness`, `axiom_base_valid` |
| `Bimodal.Metalogic.Decidability` | Decision procedure | `decide`, `isValid`, `isSatisfiable` |
| `Bimodal.Theorems.Perpetuity` | P1-P6 principles | `perpetuity_1` through `perpetuity_6` |
| `Bimodal.Metalogic.Core.DeductionTheorem` | Deduction theorem | `deduction_theorem` |

### New Completeness Infrastructure (Task 956/967/968)

| Module | Purpose | Status |
|--------|---------|--------|
| `Bimodal.Metalogic.Bundle.TruthLemma` | BFMCS truth lemma | Sorry-free |
| `Bimodal.Metalogic.StagedConstruction.CantorApplication` | Cantor iso | Has axiom dep |
| `Bimodal.Metalogic.Domain.CanonicalDomain` | D construction | Has axiom dep |
| `Bimodal.Metalogic.Bundle.CanonicalFMCS` | Canonical FMCS | Working |
| `Bimodal.Metalogic.Bundle.TemporalCoherentConstruction` | Temporal coherence | Working |

### Axiom Dependencies

The completeness pipeline depends on one axiom with high mathematical confidence:

- **`canonicalR_irreflexive`** (in `Canonical/CanonicalIrreflexivityAxiom.lean`):
  `forall M, neg CanonicalR M M` - Standard in the literature, blocked only by String atom freshness.

## Recommended Demo Content (Prioritized)

### Priority 1: Fix Existing Content (Critical)

1. **Remove obsolete references**:
   - Delete commented-out imports referencing `Representation.lean`
   - Update docstrings mentioning Task 960 (now obsolete)

2. **Update main_provable_iff_valid documentation**:
   - Clarify the sorry is in completeness direction
   - Reference the sorry-free `bmcs_truth_lemma` for those needing it

### Priority 2: Add New Feature Showcase (High Value)

1. **BFMCS Truth Lemma** (Task 862, sorry-free):
   ```lean
   #check @bmcs_truth_lemma  -- THE KEY THEOREM: MCS membership ↔ BFMCS truth
   ```
   This is the crown jewel - demonstrate it with a short example.

2. **D Construction via Cantor** (Task 956):
   ```lean
   #check @denseCanonicalTaskFrame  -- TaskFrame from pure syntax
   #check @cantor_iso              -- TimelineQuot ≃o ℚ
   ```
   Show that D can be constructed from axioms alone.

3. **Shift-Closure Infrastructure** (Task 968):
   ```lean
   #check @ShiftClosedCanonicalOmega  -- Canonical Omega is shift-closed
   #check @shifted_truth_lemma        -- Truth preserved under time-shift
   ```

### Priority 3: Improve Existing Demonstrations (Medium)

1. **Expand decision procedure examples**:
   - Add `#eval` examples with actual output
   - Show countermodel extraction for invalid formulas

2. **Add proof strategy examples**:
   - Demonstrate `lean_multi_attempt` style tactic exploration
   - Show simp lemma usage for formula manipulation

### Priority 4: Documentation Refresh (Low)

1. **Update Summary Table** (line 464-470):
   - Change "Completeness | Proven" to clarify sorry status
   - Add row for BFMCS Truth Lemma (sorry-free)

2. **Update Further Reading section**:
   - Reference `CanonicalDomain.lean` for D construction
   - Reference `TruthLemma.lean` for BFMCS approach

## Implementation Plan Outline

### Phase 1: Cleanup (15 min)
1. Remove commented-out imports (lines 6, 49-51)
2. Update docstrings mentioning obsolete tasks
3. Fix any compile warnings in Demo.lean itself

### Phase 2: Add New Features (30 min)
1. Add import for `Bimodal.Metalogic.Bundle.TruthLemma`
2. Add import for `Bimodal.Metalogic.Domain.CanonicalDomain` (if compiles cleanly)
3. Add new section showcasing:
   - BFMCS truth lemma
   - D construction (with axiom dependency note)
   - Shift-closure theorem

### Phase 3: Enhance Examples (20 min)
1. Add `#eval` examples for decision procedure
2. Add interactive proof examples showing derivation construction
3. Update summary table with accurate status

### Phase 4: Verification (10 min)
1. Ensure `lake build Bimodal.Examples.Demo` succeeds
2. Check all `#check` and `#eval` commands work
3. Review documentation for accuracy

## Technical Notes

### Formula Syntax
```lean
inductive Formula : Type where
  | atom : Atom → Formula      -- Propositional atoms
  | bot : Formula              -- Bottom (falsum)
  | imp : Formula → Formula → Formula  -- Implication
  | box : Formula → Formula    -- Modal necessity
  | all_past : Formula → Formula   -- H (always past)
  | all_future : Formula → Formula -- G (always future)
```

### Proof System
7 inference rules:
1. `axiom` - Axiom schema instances
2. `assumption` - Context membership
3. `modus_ponens` - Implication elimination
4. `necessitation` - Modal necessitation (theorems only)
5. `temporal_necessitation` - Temporal necessitation
6. `temporal_duality` - Past/future swapping
7. `irr` - Gabbay irreflexivity rule (fresh atom)

### Key Theorems to Reference
- `soundness`: All axioms valid, rules preserve validity
- `deduction_theorem`: Context assumption = implication
- `bmcs_truth_lemma`: MCS membership ↔ BFMCS truth (sorry-free)
- `perpetuity_1` through `perpetuity_6`: Modal-temporal principles

## Files to Modify

| File | Change |
|------|--------|
| `Theories/Bimodal/Examples/Demo.lean` | Primary target |

## Dependencies

The Demo.lean update has no blocking dependencies. All referenced modules compile successfully.

## Risk Assessment

**Low risk**: This is documentation/showcase work. The only risk is referencing theorems with sorry dependencies, which should be clearly documented.

## Estimated Effort

- Implementation: 1-2 hours
- Testing: 15 minutes
- Documentation review: 15 minutes

Total: ~2 hours
