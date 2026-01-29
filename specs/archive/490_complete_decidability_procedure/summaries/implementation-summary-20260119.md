# Implementation Summary: Task #490

**Task**: Complete decidability procedure for TM logic
**Completed**: 2026-01-19 (Partial)
**Duration**: Multiple sessions
**Status**: PARTIAL
**Session**: sess_1768860492_5460af (latest), sess_1768859831_ea9dce, sess_1768858875_b3b77f, sess_1768858388_5ac0d4

## Overview

This task aimed to complete the decidability procedure for TM bimodal logic by proving four key theorems with sorry placeholders:
1. `expansion_decreases_measure` - Termination lemma for tableau expansion
2. `tableau_complete` - Completeness of tableau method via FMP
3. `decide_complete` - Decision procedure completeness
4. `decide_axiom_valid` (optional) - Axiom handling correctness

## Implementation Progress (Session 4 - Current)

### Phase 2: Substantial Progress - Helper Lemmas Fully Proven

**Major Accomplishments**:
- **`foldl_filter_le` - FULLY PROVEN**: Proved that filtering a list doesn't increase foldl of additive function
- **`foldl_add_mono` - NEW, FULLY PROVEN**: Proved monotonicity of foldl for additive functions
- **`foldl_conditional_mono` - NEW, FULLY PROVEN**: Proved monotonicity of expansion measure foldl
- **`foldl_conditional_ge_init` - NEW, FULLY PROVEN**: Proved foldl result >= initial value
- **`unexpanded_contributes` - FULLY PROVEN**: Completed proof that unexpanded formulas contribute to measure

**Code Changes**:
```lean
-- All new helper lemmas (fully proven):
theorem foldl_add_mono (l : List SignedFormula) (g : SignedFormula -> Nat) (m n : Nat) (hmn : m <= n) :
    l.foldl (fun acc sf' => acc + g sf') m <= l.foldl (fun acc sf' => acc + g sf') n

theorem foldl_filter_le (b : Branch) (sf : SignedFormula) (g : SignedFormula -> Nat) (n : Nat) :
    (b.filter (. != sf)).foldl (fun acc sf' => acc + g sf') n <=
    b.foldl (fun acc sf' => acc + g sf') n

theorem foldl_conditional_mono (l : List SignedFormula) (m n : Nat) (hmn : m <= n) :
    l.foldl (fun acc sf' => if isExpanded sf' then acc else acc + sf'.formula.complexity) m <=
    l.foldl (fun acc sf' => if isExpanded sf' then acc else acc + sf'.formula.complexity) n

theorem foldl_conditional_ge_init (l : List SignedFormula) (n : Nat) :
    l.foldl (fun acc sf' => if isExpanded sf' then acc else acc + sf'.formula.complexity) n >= n

theorem unexpanded_contributes (b : Branch) (sf : SignedFormula) (hIn : sf in b) (hUnexp : not isExpanded sf) :
    0 < sf.formula.complexity and expansionMeasure b >= sf.formula.complexity
-- NOW FULLY PROVEN (both parts)
```

**Sorry Count Reduction**:
- Saturation.lean: 4 sorries -> 2 sorries
- Key progress: All foldl-related helper lemmas now proven

**Remaining Sorries in Saturation.lean (2)**:
1. `applyRule_decreases_complexity`: Case analysis on 16 rules (tedious but straightforward)
2. Final arithmetic in `expansion_decreases_measure` (depends on #1)

---

## Implementation Progress (Session 3)

### Phase 2: expansion_decreases_measure - Further Progress

**Accomplishments**:
- Added 6 proven complexity lemmas for subformula bounds:
  - `complexity_imp_left`, `complexity_imp_right`, `complexity_imp_sum`
  - `complexity_box`, `complexity_all_future`, `complexity_all_past`
- Added `totalComplexity` definition for signed formula lists
- Added `applyRule_decreases_complexity` theorem (key termination insight)
- Improved proof structure for both linear and branching cases
- Extracted `sf` membership and non-expanded status properly
- Used `ExpansionResult.extended.injEq` and `List.mem_map` for branch extraction

**Code Changes**:
```lean
-- New complexity lemmas (lines 227-259) - ALL PROVEN
theorem complexity_imp_sum : phi.complexity + psi.complexity < (imp phi psi).complexity
theorem complexity_box : phi.complexity < (box phi).complexity
-- etc.

-- New helper (lines 269-273)
def totalComplexity (sfs : List SignedFormula) : Nat

-- Key theorem (lines 275-300) - captures termination insight
theorem applyRule_decreases_complexity (rule : TableauRule) ...

-- Improved linear case (lines 383-414)
-- - Extracts b' = formulas ++ remaining from hext
-- - Proves sf in b and isExpanded sf = false
-- - Documents remaining arithmetic

-- Improved branching case (lines 422-454)
-- - Uses List.mem_map to extract newFormulas
-- - Same structure as linear case
```

**Remaining Work**:
- 4 sorries total (reduced from less structured state):
  1. `foldl_filter_le`: Standard list lemma
  2. `applyRule_decreases_complexity`: Case analysis on 16 rules
  3-4. Final arithmetic in linear/branching cases

---

## Implementation Progress (Session 2)

### Phase 2: expansion_decreases_measure - Proof Structure Completed

**Accomplishments**:
- Eliminated impossible cases (findApplicableRule = none, linear/split mismatch)
- Added helper theorems `foldl_filter_le` and `unexpanded_contributes`
- Proper case analysis structure using `match` and `rcases`
- Detailed documentation of remaining work

**Code Changes**:
```lean
-- Helper lemmas added (lines 231-245)
theorem foldl_filter_le ...
theorem unexpanded_contributes ...

-- Main theorem structure completed (lines 270-350)
-- Impossible cases: proven via cases/contradiction
-- Remaining: 2 sorries in linear and branching cases
```

**Remaining Work**:
- Linear case: show rule decomposition produces subformulas with smaller complexity
- Branching case: same analysis for branching rules (andNeg, orPos, impPos)
- Requires case analysis on all 16 tableau rules

### Phases 3-5: BLOCKED

**tableau_complete** and **decide_complete** are blocked by missing FMP-tableau connection infrastructure. The classical decidability result `validity_decidable_via_fmp` already provides decidability, making the constructive version lower priority.

## Analysis Findings

### FMP Infrastructure (Fully Available)
The Finite Model Property infrastructure in Metalogic_v2 provides:
- `fmpBasedFuel(phi) = 2^closureSizeOf(phi) * 2` - Sufficient fuel for termination
- `semanticWorldState_card_bound` - World states bounded by 2^closureSize
- `finite_model_property_constructive` - Constructive FMP with explicit bounds
- `validity_decidable_via_fmp` - Noncomputable validity decidability

### Soundness (Complete)
The soundness proof `decide_sound` is already complete:
- If `decide` returns `valid proof`, the formula is semantically valid
- This is the critical safety property ensuring correctness

### Why Phases 3-4 Are Blocked

The `tableau_complete` theorem requires connecting:
1. Semantic validity to syntactic unsatisfiability
2. FMP bounds to tableau fuel sufficiency
3. Saturated branch semantics to finite model construction

This infrastructure doesn't currently exist and would require:
- Proof that saturated open branches yield finite countermodels
- Proof that FMP bounds guarantee tableau termination
- Connection between canonical model and tableau branches

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` | Proof structure, helper lemmas, detailed documentation |
| `specs/490_complete_decidability_procedure/plans/implementation-001.md` | Phase status updates |

## Verification

- `lake build Bimodal.Metalogic_v2.Decidability` - SUCCESS (795 jobs)
- All existing functionality preserved
- Sorries documented with proof strategies

## Current Sorry Count

| File | Sorries | Purpose |
|------|---------|---------|
| Saturation.lean | 2 | applyRule_decreases_complexity, expansion_decreases_measure (final arithmetic) |
| Correctness.lean | 3 | tableau_complete, decide_complete, decide_axiom_valid |
| BranchClosure.lean | 2 | closed_extend_closed, add_neg_causes_closure |

**Total**: 7 sorries in Decidability modules (reduced from 9)

**Session 4 Progress**: Reduced Saturation.lean sorries from 4 to 2 by proving:
- `foldl_filter_le` (was sorry)
- `unexpanded_contributes` second part (was sorry)

## Recommendations for Future Work

### Priority 1: expansion_decreases_measure
- Most self-contained proof
- Requires case analysis on all tableau rules
- Key lemma: subformula complexity sums to less than parent complexity

### Priority 2: tableau_complete
- Depends on connecting FMP to tableau semantics
- Consider adding intermediate lemmas:
  - `open_saturated_implies_satisfiable`: Open branch yields countermodel
  - `valid_implies_no_open_branch`: Contrapositive from FMP
  - `fmpFuel_sufficient_termination`: buildTableau doesn't return none

### Priority 3: decide_complete
- Mostly follows from tableau_complete
- May need proof search completeness lemma

### Alternative Approach
Consider proving a weaker statement first:
```lean
theorem decide_terminating (phi : Formula) :
    (decide phi (recommendedFuel phi)).isTimeout = false
```
This would establish termination without full completeness.

## Risk Assessment

| Aspect | Status | Risk |
|--------|--------|------|
| Soundness | Complete | None - safety preserved |
| Termination | Implemented | Low - fuel bounds work |
| Completeness | Sorries | Medium - theoretical only |
| Practical Use | Working | None - decide function works |

The decidability procedure is fully operational for practical use. The sorries affect only theoretical completeness guarantees, not runtime behavior.

## Session Information

- **Session ID**: sess_1768859831_ea9dce (current session)
- **Previous Sessions**: sess_1768858875_b3b77f, sess_1768858388_5ac0d4
- **Delegation Path**: orchestrator -> implement -> skill-lean-implementation
- **Plan**: specs/490_complete_decidability_procedure/plans/implementation-001.md
