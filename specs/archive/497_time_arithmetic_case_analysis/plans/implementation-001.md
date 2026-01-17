# Implementation Plan: Time Arithmetic Case Analysis for Finite History Bridges

## METADATA

**Task**: 497  
**Description**: Complete time arithmetic case analysis for finite history bridges  
**Language**: lean  
**Proof Strategy**: Structured case analysis with omega tactics for boundary conditions  
**Complexity**: medium  
**Total Estimated Effort**: 2 hours  
**Research Integrated**: true  
**Session**: sess_488_bridge_003  
**Mathlib Dependencies**: 
- Mathlib.Data.Int.Basic
- Mathlib.Tactic.Omega
- Mathlib.Data.Int.Order

## OVERVIEW

### Problem Statement
Complete the time arithmetic completion for bridge lemmas in FiniteCanonicalModel.lean (lines ~3337, ~3394). This involves detailed case analysis for clamping arithmetic on time domains using omega tactics to handle boundary conditions. The goal is to finish the time_shift mechanisms and clamped domain arithmetic that enables proper connection between finite and semantic world histories.

### Scope
- Complete time relation proof in `finiteHistoryToWorldHistory` function (lines 3383-3393)
- Fix `time_shift` function sorry gaps (lines 1834-1836)
- Strengthen clamping arithmetic with comprehensive case analysis
- Ensure all boundary conditions are properly handled using omega tactics

### Lean-Specific Constraints
- Must use omega tactic for linear integer arithmetic proofs
- Must preserve existing FiniteTime structure and toInt operations
- Must maintain compatibility with existing semantic_task_rel_v2 definition
- All proofs must compile without sorry or admit

### Definition of Done
- All time arithmetic proofs complete with no sorry markers
- Complete case analysis covering all boundary conditions
- Time shift mechanisms fully functional
- Lake build succeeds with no errors in FiniteCanonicalModel.lean

## PROOF STRATEGY

### High-Level Approach
1. **Structured Case Analysis**: Systematically analyze all possible relationships between original times (s, t) and their clamped versions
2. **Omega Tactics**: Use omega for all linear integer arithmetic involving bounds and relationships
3. **Boundary Condition Handling**: Explicitly handle lower bound, upper bound, and in-range cases for both time parameters
4. **Time Shift Completion**: Complete forward_rel and backward_rel proofs using existing task relation properties

### Key Tactics to Use
- `omega`: Primary tactic for linear integer arithmetic proofs
- `cases`: For exhaustive case analysis on time bounds
- `simp only [FiniteTime.toInt]`: For normalization of time expressions
- `have`: For establishing intermediate lemmas about bounds
- `exact`: For direct application of existing lemmas

### Mathlib Theorems to Leverage
- `Int.le_min_left`, `Int.le_min_right`: For clamping bounds
- `Int.max_le_left`, `Int.max_le_right`: For clamping bounds
- `Int.le_or_lt`, `Int.lt_or_ge`: For case analysis
- `Int.add_sub_cancel`, `Int.sub_add_cancel`: For arithmetic simplification

### Potential Pitfalls and Mitigation
- **Incomplete Case Analysis**: Ensure all 9 combinations (3×3) of boundary conditions are covered
- **Omega Timeout**: Break complex proofs into smaller, focused goals
- **Type Conversion Issues**: Carefully manage Int ↔ FiniteTime conversions with proper bounds

## IMPLEMENTATION PHASES

### Phase 1: Complete Time Relation Proof in finiteHistoryToWorldHistory
**Status**: [COMPLETED]  
**Objective**: Fix the incomplete case analysis in lines 3386-3393  
**Estimated Hours**: 0.75  

**Lean-Specific Tasks**:
1. Replace current incomplete case analysis with exhaustive 3×3 case analysis
2. Handle all combinations of s and t boundary conditions:
   - s < -k, -k ≤ s ≤ k, s > k
   - t < -k, -k ≤ t ≤ k, t > k
3. Use omega tactics for each arithmetic subproof
4. Ensure `h_time_rel` lemma holds in all cases

**Acceptance Criteria**:
- All 9 cases explicitly handled with proper omega proofs
- `h_time_rel` proof compiles without sorry
- Time relation equality holds for all boundary combinations

### Phase 2: Complete time_shift Function Proofs  
**Status**: [COMPLETED]  
**Objective**: Fix sorry gaps in forward_rel and backward_rel (lines 1834-1836)  
**Estimated Hours**: 0.75  

**Lean-Specific Tasks**:
1. Complete `forward_rel` proof:
   - Use h_shift_valid existence to find shifted times
   - Apply existing h.forward_rel with proper time arithmetic
   - Use omega to verify time relationships
2. Complete `backward_rel` proof:
   - Similar structure to forward_rel but for predecessor relation
   - Handle boundary conditions in backward direction
   - Ensure arithmetic correctness with omega

**Acceptance Criteria**:
- Both forward_rel and backward_rel proofs complete
- No sorry markers remain in time_shift definition
- Lake build succeeds for time_shift function

### Phase 3: Strengthen Clamping Arithmetic Utilities
**Status**: [COMPLETED]  
**Objective**: Add helper lemmas for clamped time arithmetic  
**Estimated Hours**: 0.5  

**Lean-Specific Tasks**:
1. Create helper lemmas for clamping properties:
   - `clamp_preserves_order`: If a ≤ b then clamp a ≤ clamp b
   - `clamp_add_property`: clamp(a + Δ) relationship to clamp a + Δ
   - `clamp_boundary_lemmas`: Lemmas for when clamping hits boundaries
2. Prove these lemmas using omega tactics
3. Integrate helper lemmas into main proofs for cleaner reasoning

**Acceptance Criteria**:
- Helper lemmas proven and accessible
- Main proofs simplified using helper lemmas
- All arithmetic boundary cases systematically covered

## MATHLIB INTEGRATION

### Required Imports
```lean
import Mathlib.Data.Int.Basic
import Mathlib.Tactic.Omega  
import Mathlib.Data.Int.Order
import Mathlib.Data.Int.Lemmas
```

### Relevant Namespaces
- `Int`: For integer operations and ordering
- `Omega`: For linear arithmetic tactics
- Local `FiniteTime` namespace for bounded time operations

### API Usage Patterns
- `FiniteTime.toInt`: Convert bounded time to integer for arithmetic
- `FiniteTime.minTime`, `FiniteTime.maxTime`: Boundary values
- Omega pattern: `simp only [...] ; omega` for combined simplification and arithmetic

### Version Compatibility Notes
- Uses standard Lean 4 mathlib integer operations
- Omega tactic available in core mathlib
- No experimental or unstable features required

## TESTING AND VALIDATION

### Type Checking
- `lake build` to verify entire FiniteCanonicalModel.lean compiles
- Focus on time_shift and finiteHistoryToWorldHistory functions
- Ensure no remaining sorry markers in time arithmetic sections

### Property Verification  
- Test time relation equality with sample boundary cases
- Verify time_shift preserves task relations
- Check clamping arithmetic with edge cases (exact boundaries)

### Example Usage Verification
- Test `finiteHistoryToWorldHistory` with histories near boundaries
- Verify `time_shift` with various Δ values including boundary-crossing cases
- Ensure semantic task relation preserved after all operations

### Documentation Review
- Add docstrings explaining case analysis structure
- Document boundary condition handling strategy
- Include examples of omega tactic usage patterns

## ARTIFACTS

### Lean Source Files
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` (modifications only)

### Specific Modifications
1. Lines 3383-3393: Complete case analysis for `h_time_rel`
2. Lines 1834-1836: Complete time_shift proofs  
3. New helper lemmas for clamping arithmetic (if needed)

## ROLLBACK

### Git Commit Strategy
- Commit each phase separately for incremental progress
- Use descriptive commit messages indicating completed cases
- Tag commits with phase numbers for easy tracking

### Revert Procedure if Proof Blocked
- If boundary case analysis proves intractable:
  1. Revert to simpler clamping approach
  2. Use mathlib `Int.clamp` function if available
  3. Simplify time_shift to identity-only case initially

### Alternative Approaches if Primary Strategy Fails
- Use `Int.clamp` from mathlib if custom clamping too complex
- Implement time_shift with only valid shifts (Δ = 0) as fallback
- Use `Fin` type instead of custom FiniteTime for built-in bounds checking