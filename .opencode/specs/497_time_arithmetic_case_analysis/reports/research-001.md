# Research Report: Time Arithmetic Case Analysis for Finite History Bridges

**Task**: 497 - Complete time arithmetic case analysis for finite history bridges  
**Research Topic**: Time arithmetic case analysis for clamped domain arithmetic in finite history bridges  
**Research Focus**: Inspired by def:time-shift-histories from possible worlds paper (line 1877)  
**Session ID**: sess_488_bridge_003  
**Started**: 2026-01-14T23:27:00Z  
**Completed**: 2026-01-15T00:00:00Z  
**Effort**: 2 hours  
**Priority**: Medium  
**Dependencies**: None  
**Sources**: 
- /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex (def:time-shift-histories, line 1877)
- /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean  
**Artifacts**: research-001.md  
**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

This research analyzes the time arithmetic case analysis required to complete finite history bridge lemmas in the Bimodal logic completeness proof. The key insight is that the possible worlds paper's time-shift automorphism (def:time-shift-histories) provides the theoretical foundation for clamped domain arithmetic in Lean's FiniteCanonicalModel implementation. The incomplete proof around line 3385-3393 in FiniteCanonicalModel.lean requires systematic case analysis of time boundary conditions using omega tactics.

## Context & Scope

### Research Problem
Task 497 requires completing time arithmetic case analysis for bridge lemmas, specifically around lines 3337 and 3394 in FiniteCanonicalModel.lean. The current implementation has an incomplete proof in the `finiteHistoryToWorldHistory` function where clamped time arithmetic needs case analysis.

### Key Components
1. **FiniteTime domain**: `Fin (2 * k + 1)` representing integers from `-k` to `+k`
2. **Time clamping mechanism**: Converts arbitrary `Int` times to bounded `FiniteTime` domain
3. **Bridge construction**: `finiteHistoryToWorldHistory` lifts finite histories to semantic world histories
4. **Temporal arithmetic**: Case analysis for boundary conditions when shifting between time domains

## Key Findings

### 1. Time-Shift Automorphism Foundation

From the possible worlds paper (def:time-shift-histories, line 1877):

```latex
Given a frame $\F = \tuple{W, \D, \Rightarrow}$, world histories $\tau, \sigma \in H_{\F}$ are time-shifted from $y$ to $x$---written $\tau \approx_y^x \sigma$---if and only if there exists an order automorphism $\bar{a} : D \to D$ where $y = \bar{a}(x)$, $\dom{\sigma} = \bar{a}^{-1}(\dom{\tau})$, and $\sigma(z) = \tau(\bar{a}(z))$ for all $z \in \dom{\sigma}$.
```

The automorphism witnessing this is $\bar{a}(z) = z - x + y$ (from Lemma app:auto_existence, line 1885).

**Key Insight**: This provides the mathematical foundation for time clamping. The Lean implementation needs to handle the case where the automorphism maps outside the bounded domain, requiring clamping to boundary values.

### 2. FiniteTime Implementation Analysis

The Lean implementation defines:
```lean
abbrev FiniteTime (k : Nat) := Fin (2 * k + 1)

def toInt (k : Nat) (t : FiniteTime k) : Int :=
  (t.val : Int) - (k : Int)

def minTime (k : Nat) : FiniteTime k := ⟨0, by omega⟩  -- maps to -k
def maxTime (k : Nat) : FiniteTime k := ⟨2 * k, by omega⟩  -- maps to +k
```

This creates a centered integer domain from `-k` to `+k`.

### 3. Incomplete Case Analysis

The incomplete proof is in the `respects_task` field of `finiteHistoryToWorldHistory` (lines 3385-3393):

```lean
have h_time_rel : FiniteTime.toInt (temporalBound phi) t_clamped = 
               FiniteTime.toInt (temporalBound phi) s_clamped + (t - s) := by
  -- Direct computation with case analysis on whether s,t are in bounds
  cases s <== s_clamped <== t_clamped <== t
  all_goals {simp only [FiniteTime.toInt]; omega}
  · simp only [h1, h2]
    omega
  · simp only [h1, h2]
    omega
  · simp only [h1, h2]
    omega
```

The issue is that this case analysis is incomplete - it doesn't handle all possible boundary condition combinations for clamped arithmetic.

## Detailed Analysis

### Time Clamping Behavior

The clamping mechanism in `finiteHistoryToWorldHistory` (lines 3353-3360):
```lean
let t_clamped : FiniteTime k :=
  if ht_low : t < -(k : Int) then FiniteTime.minTime k
  else if ht_high : t > (k : Int) then FiniteTime.maxTime k
  else
    -- t is in range [-k, k], find the corresponding FiniteTime
    have h_lower : -(k : Int) ≤ t := Int.not_lt.mp ht_low
    have h_upper : t ≤ (k : Int) := Int.not_lt.mp (Int.not_lt.mpr (le_of_not_gt ht_high))
    (FiniteTime.toInt_surj_on_range k t h_lower h_upper).choose
```

### Required Case Analysis

For the time relation `t_clamped = s_clamped + (t - s)`, we need to analyze 9 cases based on the clamping of `s` and `t`:

1. **Both in bounds**: `s, t ∈ [-k, k]` - straightforward arithmetic
2. **s clamped low, t in bounds**: `s < -k, t ∈ [-k, k]` - boundary case
3. **s in bounds, t clamped high**: `s ∈ [-k, k], t > k` - boundary case  
4. **Both clamped low**: `s, t < -k` - both at minimum boundary
5. **Both clamped high**: `s, t > k` - both at maximum boundary
6. **s clamped high, t in bounds**: `s > k, t ∈ [-k, k]` - boundary case
7. **s in bounds, t clamped low**: `s ∈ [-k, k], t < -k` - boundary case
8. **s clamped low, t clamped high**: `s < -k, t > k` - opposite boundaries
9. **s clamped high, t clamped low**: `s > k, t < -k` - opposite boundaries

### Application of Time-Shift Theory

The time-shift automorphism $\bar{a}(z) = z - x + y$ from the possible worlds paper provides the theoretical foundation:

- When both times are in bounds: `toInt(t_clamped) = t = s + (t - s) = toInt(s_clamped) + (t - s)`
- When clamping occurs: The automorphism is composed with clamping functions
- Boundary cases: Need to verify that clamping preserves the temporal relation structure

## Recommendations

### 1. Complete Case Analysis Implementation

Replace the incomplete case analysis with systematic boundary handling:

```lean
have h_time_rel : FiniteTime.toInt (temporalBound phi) t_clamped = 
               FiniteTime.toInt (temporalBound phi) s_clamped + (t - s) := by
  cases s <== -(k : Int) <==> s
  <;> cases t <== -(k : Int) <==> t
  <;> cases s <== (k : Int) <==> s
  <;> cases t <== (k : Int) <==> t
  all_goals {
    unfold t_clamped s_clamped
    split_ifs
    <;> simp only [FiniteTime.toInt, FiniteTime.minTime_toInt, FiniteTime.maxTime_toInt]
    <;> try omega
    <;> (try linarith)
  }
```

### 2. Apply Time-Shift Automorphism Insight

Use the theoretical foundation from the possible worlds paper to structure the proof:
- Primary case: Both times in domain bounds (standard time-shift)
- Secondary cases: One or both times outside bounds (clamped time-shift)
- Verify that clamping preserves the essential temporal structure

### 3. Omega Tactics Strategy

For arithmetic with linear constraints, use:
- `omega` for integer linear arithmetic
- `linarith` for more general linear inequalities  
- `simp` with `FiniteTime.toInt` lemmas for boundary values

### 4. Proof Structure

```lean
-- Main theorem structure
by
  -- Case 1: Both s,t in bounds [-k, k]
  case in_bounds in_bounds => 
    -- Standard time-shift: toInt(t_clamped) = t = s + (t - s) = toInt(s_clamped) + (t - s)
    
  -- Case 2: s clamped low, t any position  
  case s_clamped_low => 
    -- s_clamped = -k, analyze t position
    
  -- Case 3: s in bounds, t clamped high
  case t_clamped_high =>
    -- t_clamped = k, analyze s position
    
  -- ... handle remaining cases systematically
```

## Decisions

### Key Design Choice
The time arithmetic should respect the order automorphism structure from the possible worlds paper while handling domain boundary conditions through clamping. This preserves the mathematical foundations while working within Lean's type system constraints.

### Implementation Approach
- Prioritize systematic case analysis over clever tricks
- Use omega tactics for the arithmetic reasoning
- Ensure each case explicitly references the time-shift theory

## Risks & Mitigations

### Risk 1: Complex Case Explosion
9 boundary cases could make the proof unwieldy.

**Mitigation**: Group cases by symmetry and reuse lemmas for similar boundary patterns.

### Risk 2: Omega Tactic Limitations
Complex boundary conditions might exceed `omega`'s capabilities.

**Mitigation**: Fall back to `linarith` or manual arithmetic manipulation for difficult cases.

### Risk 3: Performance Impact
Extensive case analysis could slow compilation.

**Mitigation**: Use `by_cases` strategically and share subgoals where possible.

## Implementation Guidance

### 1. Boundary Lemma Library

Create helper lemmas for boundary arithmetic:
```lean
theorem clamped_add_preserves_relation {k s t : Int} (h_bounds : ...) :
  clamped k (s + (t - s)) = clamped k t := ...
```

### 2. Time-Shift Bridge Lemma

Formalize the connection to the possible worlds paper:
```lean
theorem time_shift_with_clamping (phi : Formula) (s t : Int) :
  let k := temporalBound phi
  let s_clamped := clamped_to_finite_time k s
  let t_clamped := clamped_to_finite_time k t
  FiniteTime.toInt k t_clamped = FiniteTime.toInt k s_clamped + (t - s) := ...
```

### 3. Testing Strategy

- Verify boundary cases with concrete examples (k = 2,3,4)
- Test both positive and negative duration values
- Ensure consistency with semantic task relation definitions

## Appendix: Sources and Citations

1. **Possible Worlds Paper** - def:time-shift-histories (line 1877) and Lemma app:auto_existence (line 1885)
   - Provides theoretical foundation for time-shift automorphisms
   - Automorphism: $\bar{a}(z) = z - x + y$

2. **FiniteCanonicalModel.lean** - Current implementation
   - Lines 3337-3394: Incomplete time arithmetic case analysis
   - Lines 121-180: FiniteTime definitions and clamping mechanisms

3. **Lean 4 Documentation** - Omega tactics and integer arithmetic
   - Used for solving linear arithmetic constraints in case analysis

## Next Steps

1. Implement the complete 9-case analysis following the recommended structure
2. Create boundary lemma library for reusable arithmetic facts  
3. Verify the implementation against concrete test cases
4. Ensure integration with the broader bridge lemma infrastructure

This research provides the mathematical foundation and implementation strategy needed to complete the time arithmetic case analysis for finite history bridges in Task 497.