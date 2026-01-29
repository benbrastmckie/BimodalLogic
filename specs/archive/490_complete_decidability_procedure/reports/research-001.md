# Research Report: Task #490

**Task**: 490 - Complete decidability procedure for TM logic
**Started**: 2026-01-19T20:37:36Z
**Completed**: 2026-01-19T21:05:00Z
**Effort**: High (8-12 hours for full implementation)
**Priority**: Low
**Dependencies**: Task 607 (Port Decidability to Metalogic_v2)
**Sources/Inputs**: Codebase analysis, Task 618 research, Metalogic_v2 README, old Metalogic Decidability files
**Artifacts**: This research report
**Standards**: report-format.md

## Executive Summary

- **Metalogic_v2 has strong FMP infrastructure** but NO decidability module - the FMP provides `satisfiability_decidable` and `validity_decidable_via_fmp` but via `Classical.dec`, not constructive tableau
- **Old Metalogic has complete decidability infrastructure** - 8 files totaling ~61KB with tableau, signed formulas, saturation, proof extraction, countermodel extraction, and decision procedure
- **Metalogic_v2 is fully independent of old Metalogic** - no source imports exist (only README documentation mentions)
- **Task 607 (Port Decidability to Metalogic_v2) is the primary path** - this task 490 should focus on completing the ported decidability, not the old one
- **Key gap: Completeness proof** - `tableau_complete` and `decide_complete` theorems have sorries requiring FMP-based termination proof

## Context & Scope

### Research Focus
Given recent work making Metalogic_v2 independent of old Metalogic (Task 618), this research reviews:
1. Current decidability infrastructure in Metalogic_v2/
2. State of old Metalogic/Decidability/ for potential porting
3. Gaps between current state and complete decidability procedure
4. Integration path with FMP infrastructure

### Related Tasks
| Task | Status | Relationship |
|------|--------|--------------|
| 607 | NOT STARTED | Port Decidability to Metalogic_v2 (prerequisite) |
| 618 | RESEARCHED | Move Metalogic to Boneyard (affects source of port) |
| 470 | IMPLEMENTING | Finite model computational optimization |
| 469 | PARENT | Original decidability task (this extends it) |

## Findings

### 1. Metalogic_v2 Decidability Status

**Current State: Noncomputable FMP-based decidability only**

The `FiniteModelProperty.lean` in Metalogic_v2 provides:

```lean
-- Noncomputable decidability via classical logic
noncomputable def satisfiability_decidable (φ : Formula) : Decidable (formula_satisfiable φ) :=
  Classical.dec (formula_satisfiable φ)

noncomputable def validity_decidable_via_fmp (φ : Formula) : Decidable (valid φ) :=
  Classical.dec (valid φ)
```

**What Metalogic_v2 HAS:**
- `finite_model_property`: Proof that satisfiable formulas have finite models
- `finite_model_property_constructive`: Explicit bounds (2^|closure(phi)|)
- `subformulaList` and related closure infrastructure
- `semanticWorldState_card_bound`: Cardinality bounds for finite models
- Strong completeness infrastructure (weak/strong completeness theorems)

**What Metalogic_v2 LACKS:**
- SignedFormula type and operations
- Tableau rules and expansion
- Saturation algorithm
- Proof extraction from closed tableaux
- Countermodel extraction from open branches
- Constructive decision procedure (`decide` function)
- Completeness theorem connecting FMP to tableau termination

### 2. Old Metalogic Decidability Infrastructure

**Complete but needs porting - 8 files:**

| File | Lines | Purpose |
|------|-------|---------|
| SignedFormula.lean | 323 | Sign type, SignedFormula, Branch operations |
| Closure.lean | ~200 | Subformula closure for decidability |
| Tableau.lean | 379 | TableauRule, RuleResult, rule application |
| Saturation.lean | 242 | ExpandedTableau, fuel-based expansion |
| ProofExtraction.lean | 211 | Extract proofs from closed tableaux |
| CountermodelExtraction.lean | ~300 | Extract countermodels from open branches |
| DecisionProcedure.lean | 265 | Main `decide` function |
| Correctness.lean | 199 | Soundness/completeness theorems |

**Key Types and Functions:**

```lean
-- Core decision result type
inductive DecisionResult (φ : Formula) : Type where
  | valid (proof : DerivationTree [] φ)
  | invalid (counter : SimpleCountermodel)
  | timeout

-- Main decision function
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    : DecisionResult φ
```

**Sorries in Old Metalogic Decidability:**

| File | Theorem | Issue |
|------|---------|-------|
| Saturation.lean:221 | `expansion_decreases_measure` | Technical proof of rule decomposition |
| Correctness.lean:82 | `tableau_complete` | FMP-based termination proof |
| Correctness.lean:97 | `decide_complete` | Requires tableau completeness |
| Correctness.lean:181 | `decide_axiom_valid` | matchAxiom behavior verification |

### 3. FMP Infrastructure Integration

The key connection between FMP and decidability is the **termination bound**:

```
Theorem (FMP Termination Bound):
  For formula φ, the tableau explores at most 2^|closure(φ)| distinct states.
  Since each state is characterized by a subset of closureWithNeg(φ),
  and closureWithNeg(φ) is finite, the tableau must terminate.
```

**Metalogic_v2 provides these supporting theorems:**

```lean
-- From Closure.lean
def closure (phi : Formula) : Finset Formula
def closureWithNeg (phi : Formula) : Finset Formula
def closureSize (phi : Formula) : Nat := (closure phi).card

-- From FiniteModelProperty.lean
theorem subformulaList_finite (φ : Formula) :
    (subformulaList φ).length < 2 ^ Formula.complexity φ + 1

theorem semanticWorldState_card_bound (φ : Formula) :
    Fintype.card (SemanticWorldState φ) ≤ 2 ^ closureSize φ
```

**Gap: Need to connect:**
1. Closure infrastructure in old Decidability/Closure.lean overlaps with Metalogic_v2/Representation/Closure.lean
2. Must use Metalogic_v2's `closure`/`closureWithNeg` definitions in ported decidability
3. FMP provides the *existence* of a bound but not the *constructive enumeration* needed for tableau termination

### 4. Import Analysis

**Old Metalogic/Decidability/ imports:**
```lean
import Bimodal.Metalogic.Decidability.SignedFormula     -- needs Bimodal.Syntax.Formula, Bimodal.ProofSystem
import Bimodal.Metalogic.Decidability.Closure          -- needs Bimodal.Metalogic.Decidability.Tableau
import Bimodal.Metalogic.Decidability.Tableau          -- needs Bimodal.Metalogic.Decidability.SignedFormula
import Bimodal.Metalogic.Decidability.Saturation       -- needs Bimodal.Metalogic.Decidability.Closure
import Bimodal.Metalogic.Decidability.ProofExtraction  -- needs Bimodal.Metalogic.Decidability.Saturation
import Bimodal.Metalogic.Decidability.CountermodelExtraction  -- needs Bimodal.Metalogic.Decidability.Saturation
import Bimodal.Metalogic.Decidability.DecisionProcedure      -- needs ProofExtraction, CountermodelExtraction
import Bimodal.Metalogic.Decidability.Correctness            -- needs DecisionProcedure, Bimodal.Metalogic.Soundness.Soundness
```

**Metalogic_v2 dependencies that ported code can use:**
```lean
import Bimodal.Metalogic_v2.Core.Basic                 -- Consistent, SetConsistent
import Bimodal.Metalogic_v2.Core.Provability           -- Context-based ⊢
import Bimodal.Metalogic_v2.Soundness.Soundness        -- soundness theorem
import Bimodal.Metalogic_v2.Representation.Closure     -- closure, closureWithNeg
import Bimodal.Metalogic_v2.FMP                        -- Re-exports FMP theorems
```

### 5. What "Complete Decidability Procedure" Means

Per the task description, the goal is:
1. **Proof extraction from closed tableaux** - Already implemented in old Metalogic (with limitations)
2. **Completeness proof connecting to FMP** - Missing (sorries in `tableau_complete`, `decide_complete`)
3. **Full decide function verification** - Soundness proven, completeness has sorries

The key missing piece is the **completeness proof**:

```lean
-- Currently has sorry
theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid

-- Currently has sorry
theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
    ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof
```

**Proof Strategy for Completeness:**

1. Valid formula φ implies ¬φ is unsatisfiable
2. By FMP contrapositive: unsatisfiable means no finite model
3. Tableau starting with F(φ) explores finite state space (bounded by 2^|closure|)
4. Therefore all branches must eventually close
5. Closed tableau yields proof via extraction

### 6. Closure Infrastructure Comparison

**Old Metalogic/Decidability/Closure.lean:**
```lean
-- Definition in old Decidability
def closureSet (φ : Formula) : List Formula := ...
def ClosureReason : Type := ...  -- For why branch closed
```

**Metalogic_v2/Representation/Closure.lean:**
```lean
-- Better definition in Metalogic_v2
def closure (phi : Formula) : Finset Formula := ...
def closureWithNeg (phi : Formula) : Finset Formula := ...
def ClosureMaximalConsistent (phi : Formula) (S : Set Formula) : Prop := ...
```

**Recommendation:** Use Metalogic_v2's closure definitions but add SignedFormula-specific operations.

## Decisions

1. **Task 607 is the prerequisite** - Cannot complete decidability in Metalogic_v2 without first porting the infrastructure
2. **Completeness proof is the main work** - The decidability code structure is mostly in place; the theoretical completeness proof is missing
3. **Use Metalogic_v2's closure infrastructure** - Don't port old Closure.lean; adapt tableau code to use existing definitions
4. **Keep proof extraction limitations** - Current proof extraction has workarounds; these are acceptable

## Recommendations

### Recommended Path Forward

**Phase 1: Task 607 - Port Infrastructure (8-12 hours)**
1. Create `Bimodal.Metalogic_v2.Decidability/` directory structure
2. Port SignedFormula.lean (no changes needed, no Metalogic dependencies)
3. Port Tableau.lean (no changes needed)
4. Adapt Saturation.lean to use Metalogic_v2 imports
5. Port ProofExtraction.lean with Metalogic_v2 imports
6. Port CountermodelExtraction.lean
7. Port DecisionProcedure.lean

**Phase 2: Task 490 - Complete Decidability (6-10 hours)**
1. Prove `expansion_decreases_measure` (technical but doable)
2. Prove `tableau_complete` using FMP infrastructure:
   - Connect `closureSize` to tableau state space
   - Show termination bound is 2^closureSize
   - Use well-founded recursion or fuel with proof
3. Prove `decide_complete` from tableau completeness
4. Optionally prove `decide_axiom_valid` (low priority)

### Integration Pattern

The ported Decidability module should follow this import structure:

```lean
-- New file: Bimodal/Metalogic_v2/Decidability/SignedFormula.lean
import Bimodal.Syntax.Formula
import Bimodal.ProofSystem
-- (no other Metalogic_v2 imports needed)

-- New file: Bimodal/Metalogic_v2/Decidability/Correctness.lean
import Bimodal.Metalogic_v2.Decidability.DecisionProcedure
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Metalogic_v2.FMP  -- For FMP-based completeness proof
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FMP.lean (hub)                           │
│         finite_model_property, closureSize bounds           │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Completeness   │ │  Decidability   │ │   Compactness   │
│   (existing)    │ │   (to port)     │ │    (existing)   │
└─────────────────┘ └────────┬────────┘ └─────────────────┘
                             │
            ┌────────────────┼────────────────┐
            ▼                ▼                ▼
    ┌──────────────┐ ┌──────────────┐ ┌───────────────┐
    │DecisionProc. │ │ProofExtract. │ │CounterExtract.│
    └──────────────┘ └──────────────┘ └───────────────┘
            ▲                ▲                ▲
            └────────────────┼────────────────┘
                             │
                    ┌────────┴────────┐
                    │   Saturation    │
                    │  (fuel-based)   │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │    Tableau      │
                    │   (rules)       │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │ SignedFormula   │
                    │   (types)       │
                    └─────────────────┘
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Completeness proof may be difficult | High | Accept sorry if needed; soundness is proven |
| Old code may have subtle bugs | Medium | Port incrementally with tests |
| Closure definition mismatch | Medium | Carefully adapt; don't duplicate |
| Performance concerns | Low | Existing code is functional; optimize later |

## Appendix

### Key Sorries to Address

1. **`expansion_decreases_measure`** - Prove that each tableau step reduces unexpanded complexity
2. **`tableau_complete`** - Main completeness theorem using FMP bound
3. **`decide_complete`** - Derives from tableau completeness

### File Size Summary

| Component | Old Metalogic | Metalogic_v2 Equivalent |
|-----------|---------------|-------------------------|
| SignedFormula | 323 lines | To port |
| Closure | ~200 lines | Use existing 795 lines |
| Tableau | 379 lines | To port |
| Saturation | 242 lines | To port |
| ProofExtraction | 211 lines | To port |
| CountermodelExtraction | ~300 lines | To port |
| DecisionProcedure | 265 lines | To port |
| Correctness | 199 lines | To port + complete |
| **Total** | ~2119 lines | ~1324 lines (excluding reused closure) |

### Search Queries Used

```bash
# Check for imports from old Metalogic
grep -r "^import.*Metalogic[^_]" Theories/Bimodal/Metalogic_v2/

# Find all Decidability files
find Theories/Bimodal/Metalogic/Decidability -name "*.lean"

# Check FMP exports
lean_file_outline Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean
```
