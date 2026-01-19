# Research Report: Task #470

**Task**: 470 - Finite Model Computational Optimization
**Started**: 2026-01-18T12:00:00Z
**Completed**: 2026-01-18T12:45:00Z
**Effort**: Medium
**Priority**: Normal
**Dependencies**: None
**Sources/Inputs**: FiniteCanonicalModel.lean analysis, Mathlib Fintype/Finset documentation, lean-lsp search tools
**Artifacts**: specs/470_finite_model_computational_optimization/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The `FiniteCanonicalModel.lean` file (2700+ lines) implements finite canonical models for modal logic decidability with two parallel approaches: syntactic (deprecated with 6+ sorries) and semantic (preferred, fewer gaps)
- Key computational bottlenecks identified: noncomputable world state construction via Classical.choose, O(2^n) truth assignment enumeration, expensive Finset operations on closure sets
- Optimization opportunities exist in: Decidable instance implementations, closure computation caching, history/sequence data structure choices, and proof term construction
- Recommended approach: Focus on the semantic approach (SemanticWorldState) which has cleaner architecture, add computable decidable instances, and implement memoization for subformula closure

## Context & Scope

This research analyzes `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` to identify computational inefficiencies and recommend optimizations. The file implements:

1. **Finite Time Domain** (`FiniteTime k`) - integers from -k to +k using `Fin (2*k+1)`
2. **Subformula Closure** - `closure phi : Finset Formula` via `List.toFinset`
3. **Finite World States** - truth assignments on closure satisfying local consistency
4. **Finite Task Relation** - canonical accessibility relation for modal logic
5. **Semantic World States** - quotient type over history-time pairs (preferred approach)
6. **Finite Histories** - sequences of world states over finite time domain

The implementation prioritizes correctness over performance, with many constructions marked `noncomputable`.

## Findings

### 1. Noncomputable Definitions

Multiple critical definitions are marked `noncomputable`:

```lean
-- Line 1209
noncomputable instance finiteWorldState_decidableEq (phi : Formula) :
    DecidableEq (FiniteWorldState phi) := by
  intros w1 w2
  by_cases h : w1.assignment = w2.assignment
  ...

-- Line 1230
noncomputable def assignmentFromSet (phi : Formula) (S : Set Formula) :
    FiniteTruthAssignment phi :=
  fun ⟨psi, _⟩ => if psi ∈ S then true else false

-- Line 1274
noncomputable def assignmentFromClosureMCS (phi : Formula) (S : Set Formula)
    (_h_mcs : ClosureMaximalConsistent phi S) : FiniteTruthAssignment phi :=
  fun ⟨psi, _⟩ => if Classical.propDecidable (psi ∈ S) |>.decide then true else false
```

**Impact**: These prevent efficient kernel-level computation and require using `Classical.decide` instead of direct decidability.

**Mathlib Relevant Theorems**:
- `Fintype.decidableExistsFintype` - Decidable `Exists` for Fintype
- `Fintype.decidableForallFintype` - Decidable `Forall` for Fintype
- `Finset.decidableMem` - Direct decidable membership for Finset
- `Set.decidableMemOfFintype` - Decidable set membership when element type has Fintype

### 2. Closure Computation

The closure is computed via list conversion:

```lean
-- Line 335
def closure (phi : Formula) : Finset Formula :=
  (Formula.subformulas phi).toFinset
```

**Issues**:
1. `Formula.subformulas` returns a `List` requiring deduplication via `toFinset`
2. No caching - closure recomputed on each access
3. `closureWithNeg` (line 481) doubles the set by adding negations

**Mathlib Optimization Patterns**:
- `Finset.map` with embedding for efficient transformation
- Precompute closures once and pass as parameters
- Use `Finset.filter` with decidable predicates

### 3. Truth Assignment Enumeration

```lean
-- Line 1190
instance truthAssignmentFintype (phi : Formula) : Fintype (FiniteTruthAssignment phi) :=
  Pi.instFintype
```

**Issue**: `Pi.instFintype` creates 2^|closure| assignments. For a formula with 20 subformulas, this is over 1 million assignments to enumerate.

**Optimization**: Use lazy enumeration or constraint-based generation that respects `IsLocallyConsistent` from the start, rather than filtering all possible assignments.

### 4. History Construction

```lean
-- Line 2171
noncomputable def time_shift (h : FiniteHistory phi) (Delta : Int)
    (h_shift_valid : ∀ t : FiniteTime (temporalBound phi),
      ∃ t' : FiniteTime (temporalBound phi),
        FiniteTime.toInt (temporalBound phi) t' =
          FiniteTime.toInt (temporalBound phi) t + Delta) :
    FiniteHistory phi where
  states := fun t =>
    let t' := Classical.choose (h_shift_valid t)
    h.states t'
```

**Issue**: Each time shift uses `Classical.choose`, which is not computable.

**Alternative**: Use explicit time arithmetic on `Fin` with bounds checking.

### 5. Semantic World State Quotient

```lean
-- Line 2501
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)
```

The semantic approach uses quotient types which have good computational properties when properly implemented with `Quotient.lift`.

**Strength**: The `toFiniteWorldState` function (line 2524) uses `Quotient.lift` correctly:
```lean
def toFiniteWorldState (w : SemanticWorldState phi) : FiniteWorldState phi :=
  Quotient.lift (fun p => p.1.states p.2) (fun _ _ h => h) w
```

### 6. Task Relation Checking

```lean
-- Line 1466
def finite_task_rel (phi : Formula) (w : FiniteWorldState phi) (d : Int)
    (u : FiniteWorldState phi) : Prop :=
  -- Box transfer: box(psi) at w implies psi at u (for psi in closure)
  (∀ psi : Formula,
    ∀ h_box : Formula.box psi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    w.models (Formula.box psi) h_box → u.models psi h_psi) ∧
  -- [5 more conditions...]
```

**Issue**: Six universal quantifiers over closure, each requiring proof of membership.

**Optimization**: Precompute relevant box/temporal formulas in closure:
```lean
def boxFormulasInClosure (phi : Formula) : Finset Formula :=
  (closure phi).filter (fun psi =>
    match psi with | Formula.box _ => true | _ => false)
```

## Relevant Mathlib Theorems

| Theorem | Module | Use Case |
|---------|--------|----------|
| `Fintype.decidableExistsFintype` | Mathlib.Data.Fintype.Defs | Decidable existence over finite types |
| `Fintype.decidableForallFintype` | Mathlib.Data.Fintype.Defs | Decidable universal quantification |
| `Finset.decidableMem` | Mathlib.Data.Finset.Basic | O(n) membership check |
| `Finset.decidableDforallFinset` | Mathlib.Data.Finset.Basic | Decidable quantification over Finset with membership proof |
| `Fintype.elems` | Mathlib.Data.Fintype.Defs | Explicit enumeration of finite type |
| `Pi.instFintype` | Mathlib.Data.Fintype.Pi | Fintype instance for function spaces |
| `Finset.filter` | Mathlib.Data.Finset.Basic | Efficient subset selection |
| `Finset.map` | Mathlib.Data.Finset.Image | Embedding-based transformation |

## Decisions

1. **Focus on Semantic Approach**: The `SemanticWorldState` quotient approach (Phase 5-7) has fewer sorries and cleaner architecture. Optimization efforts should prioritize this path.

2. **Replace Classical.choose with Explicit Construction**: Where possible, replace `Classical.choose` with explicit finite-domain arithmetic using `Fin` operations.

3. **Precompute and Cache**: Closure computations and structural decompositions (box formulas, temporal formulas) should be computed once and passed as parameters.

## Recommendations

### Priority 1: Computable Decidable Instances

Replace noncomputable decidable instances with computable versions:

```lean
-- Replace
noncomputable instance finiteWorldState_decidableEq (phi : Formula) :
    DecidableEq (FiniteWorldState phi) := ...

-- With
instance finiteWorldState_decidableEq (phi : Formula) :
    DecidableEq (FiniteWorldState phi) :=
  fun w1 w2 => decidable_of_iff (w1.assignment = w2.assignment)
    (by simp [FiniteWorldState.ext_iff])
```

This requires ensuring `FiniteTruthAssignment` has a computable `DecidableEq`:
```lean
instance (phi : Formula) : DecidableEq (FiniteTruthAssignment phi) :=
  inferInstance  -- from Pi.instDecidableEq via Fintype
```

### Priority 2: Precomputed Closure Decomposition

Create a structure that precomputes all closure-related data:

```lean
structure ClosureData (phi : Formula) where
  closure : Finset Formula
  boxFormulas : Finset { psi // Formula.box psi ∈ closure }
  pastFormulas : Finset { psi // Formula.all_past psi ∈ closure }
  futureFormulas : Finset { psi // Formula.all_future psi ∈ closure }
  impFormulas : Finset (Formula × Formula)  -- (antecedent, consequent)

def mkClosureData (phi : Formula) : ClosureData phi := ...
```

### Priority 3: Explicit Time Arithmetic

Replace `Classical.choose` in time operations with direct `Fin` arithmetic:

```lean
def shift_time (k : Nat) (t : FiniteTime k) (delta : Int) : Option (FiniteTime k) :=
  let new_val := t.val.toInt + delta + k
  if h : 0 ≤ new_val ∧ new_val < 2 * k + 1 then
    some ⟨new_val.toNat, by omega⟩
  else
    none
```

### Priority 4: Lazy Consistent Assignment Generation

Instead of enumerating all 2^n assignments and filtering:

```lean
-- Current (exponential)
instance finiteWorldState_finite (phi : Formula) : Finite (FiniteWorldState phi) := ...

-- Better: Generate only consistent assignments
def consistentAssignments (phi : Formula) : List (FiniteTruthAssignment phi) :=
  -- Use backtracking with early pruning based on IsLocallyConsistent constraints
  ...
```

### Priority 5: Specialized Data Structures

For the v2 implementation in `Metalogic_v2/Representation/`:

1. Use `Array` instead of `List` for `subformulas` computation
2. Consider `HashMap Formula Bool` for truth assignments (Formula already derives Hashable)
3. Use `RBTree` for ordered operations if needed

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Changing decidability instances may break existing proofs | Run full test suite after each change; preserve old instances as `noncomputable` alternatives |
| Precomputed structures increase memory usage | Benchmarking needed; structures are bounded by formula complexity |
| Explicit time arithmetic may have edge case bugs | Comprehensive test coverage for boundary conditions (-k, 0, +k) |
| Array/HashMap structures are harder to reason about | Keep pure Finset versions for proofs, use efficient versions for computation |

## Appendix

### Search Queries Used

1. `lean_leansearch`: "decidable Fintype efficient computation finite model"
2. `lean_loogle`: `Fintype.elems`, `Finset.map _ _`, `Decidable ∀ Finset`
3. `lean_leanfinder`: "efficient decidable instance for finite set membership and enumeration", "cache memoization finite computation decidable"
4. `lean_local_search`: `FiniteWorldState`, `closure`, `temporalDepth`

### File Structure Summary

```
FiniteCanonicalModel.lean (2700+ lines):
  Lines 1-110:     Module header, imports, overview
  Lines 111-320:   FiniteTime operations
  Lines 321-500:   Closure as Finset
  Lines 501-700:   ClosureConsistent, Lindenbaum
  Lines 701-1000:  IsLocallyConsistent, closure MCS
  Lines 1001-1200: FiniteWorldState structure
  Lines 1201-1500: Task relation (finite_task_rel)
  Lines 1501-1700: Compositionality proofs (7 sorries)
  Lines 1701-2000: Semantic task relation alternative
  Lines 2001-2400: FiniteHistory, time-shift
  Lines 2401-2600: SemanticWorldState quotient
  Lines 2601-2800: History gluing
  Lines 2801-3100: semantic_task_rel_v2, compositionality
  Lines 3101+:     Truth lemmas, completeness
```

### Sorry Count by Section

| Section | Sorry Count | Notes |
|---------|-------------|-------|
| Lindenbaum projection | 1 | Line 700 |
| Local consistency from MCS | 1 | Line 1302 |
| MCS implication properties | 2 | Lines 1420, 1432 |
| Compositionality (pointwise) | 7 | Lines 1569-1637 |
| Semantic compositionality | 2 | Lines 1915, 1943 |
| History gluing | 5 | Lines 2696-2762 |
| Semantic relation v2 | 3 | Lines 2991-3027 |
| Truth lemmas | 6+ | Lines 4189-4529 |

### References

- Modal Logic, Blackburn et al. - Finite model property
- Goldblatt, Logics of Time and Computation - Temporal completeness
- Mathlib.Data.Fintype.Defs - Fintype decidability instances
- Mathlib.Data.Finset.Basic - Finset operations
