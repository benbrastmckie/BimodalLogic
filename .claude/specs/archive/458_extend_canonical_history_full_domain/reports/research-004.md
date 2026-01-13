# Research Report: Task #458 - Finite Canonical Model via Subformula Closure

**Task**: 458 - Extend canonical_history from singleton domain to full domain
**Date**: 2026-01-13
**Session ID**: sess_1768315395_a50b60
**Started**: 2026-01-13T14:43:28Z
**Completed**: 2026-01-13T15:30:00Z
**Effort**: 10-15 hours (significant architectural shift)
**Priority**: High
**Parent**: Task 257 (Completeness Proofs)
**Dependencies**: Task 448 (completed)
**Language**: lean
**Sources/Inputs**:
  - Completeness.lean (current implementation with Duration construction)
  - SignedFormula.lean (subformula closure already implemented)
  - Formula.lean (modalDepth, temporalDepth functions)
  - research-002.md, research-003.md (compositionality gap analysis)
  - Modal Logic, Blackburn et al. (finite model property)
  - Goldblatt, Logics of Time and Computation (temporal completeness)
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- **Key Insight**: Since sentences are finite, the canonical countermodel for completeness only needs a finite number of world histories with a finite domain
- **Finite Bound**: The modal depth bounds the number of distinct world histories needed; the temporal depth bounds the domain size
- **Subformula Property**: Tableau expansion produces only subformulas, already proven in SignedFormula.lean
- **New Direction**: Build a **finite filtered canonical model** rather than extending the abstract Duration construction
- **Mathematical Virtue**: This approach is more elegant, constructive, and sidesteps the compositionality gaps entirely

## Context & Scope

### The Fundamental Observation

The focus prompt provides a crucial insight:

> Since completeness aims to build a canonical countermodel given some conclusion that is assumed underivable from some premises, and **all sentences are finite**, at most we will need a **finite number of world histories** (given a finite number of modals in the sentences) with a **finite domain** (since a finite number of tense operators in the sentences).

This is the **finite model property** approach to completeness, which is more elegant than the infinite canonical model approach previously attempted.

### Why Finiteness Suffices

For any finite formula phi:

1. **Temporal Bound**: The temporal depth `temporalDepth phi` bounds how many times we quantify into the future or past
2. **Modal Bound**: The modal depth `modalDepth phi` bounds how many times we quantify over world histories
3. **Subformula Bound**: The subformula closure `subformulas phi` is finite

When proving `not (derivable phi)` implies `not (valid phi)`:
- We need ONE countermodel M, ONE history tau, ONE time t where phi is false
- The history tau need only have domain covering `2 * temporalDepth phi + 1` points (from -k to +k)
- We only need to consider `2^(|subformulas phi|)` possible world states (truth assignments to subformulas)
- The box quantifier only needs to range over histories respecting the finite task relation

### Comparison with Previous Approaches

| Approach | Duration Type | World History Domain | Compositionality |
|----------|---------------|---------------------|------------------|
| research-001/002/003 | Abstract Grothendieck group | Full Z-indexed | Mixed-sign gaps |
| research-003 (relativized) | Parameter T | Full T | Still needs chain coherence |
| **New Approach** | Finite integer range | `[-k, +k]` for k = temporalDepth | Trivially satisfied |

## Findings

### 1. Existing Infrastructure for Finiteness

The codebase already has key components:

**In Formula.lean** (lines 128-155):
```lean
def modalDepth : Formula -> Nat
  | atom _ => 0
  | bot => 0
  | imp phi psi => max phi.modalDepth psi.modalDepth
  | box phi => 1 + phi.modalDepth
  | all_past phi => phi.modalDepth
  | all_future phi => phi.modalDepth

def temporalDepth : Formula -> Nat
  | atom _ => 0
  | bot => 0
  | imp phi psi => max phi.temporalDepth psi.temporalDepth
  | box phi => phi.temporalDepth
  | all_past phi => 1 + phi.temporalDepth
  | all_future phi => 1 + phi.temporalDepth
```

**In SignedFormula.lean** (lines 198-207):
```lean
def subformulas : Formula -> List Formula
  | phi@(.atom _) => [phi]
  | phi@.bot => [phi]
  | phi@(.imp psi chi) => phi :: (subformulas psi ++ subformulas chi)
  | phi@(.box psi) => phi :: subformulas psi
  | phi@(.all_past psi) => phi :: subformulas psi
  | phi@(.all_future psi) => phi :: subformulas psi

def subformulaCount (phi : Formula) : Nat := (subformulas phi).eraseDups.length
```

### 2. Finite Canonical Model Construction

Given a formula phi to be falsified:

**Step 1: Compute Bounds**
```lean
-- Maximum temporal distance from origin needed
def temporal_bound (phi : Formula) : Nat := temporalDepth phi

-- Set of subformulas to track
def closure (phi : Formula) : Finset Formula :=
  (subformulas phi).toFinset
```

**Step 2: Define Finite Time Domain**
```lean
-- Time domain is just integers in range [-k, k]
def FiniteTime (k : Nat) := Fin (2 * k + 1)

-- Convert to centered integer: Fin n -> Int
def toInt (k : Nat) (t : FiniteTime k) : Int := t.val - k
```

**Step 3: Define Finite World States**
```lean
-- A world state is a truth assignment to subformulas
-- Restricted to be "locally consistent" with propositional logic
structure FiniteWorldState (phi : Formula) where
  assignment : closure phi -> Bool
  consistent : IsLocallyConsistent assignment

-- There are at most 2^|closure phi| such states
```

**Step 4: Define Task Relation on Finite Model**
```lean
-- Task relation only needs to satisfy modal/temporal transfer for subformulas
def finite_task_rel (phi : Formula)
    (S : FiniteWorldState phi) (d : Int) (T : FiniteWorldState phi) : Prop :=
  -- Modal transfer: box psi in closure -> (S(box psi) -> T(psi))
  (forall psi, Formula.box psi in closure phi -> S.assignment (box psi) -> T.assignment psi) and
  -- Future transfer: G psi in closure and d > 0 -> (S(G psi) -> T(psi))
  (d > 0 -> forall psi, Formula.all_future psi in closure phi ->
            S.assignment (all_future psi) -> T.assignment psi) and
  -- Past transfer: H psi in closure and d < 0 -> (S(H psi) -> T(psi))
  (d < 0 -> forall psi, Formula.all_past psi in closure phi ->
            S.assignment (all_past psi) -> T.assignment psi)
```

**Step 5: Build Finite Canonical Frame**
```lean
def finite_canonical_frame (phi : Formula) : TaskFrame Int where
  WorldState := FiniteWorldState phi
  task_rel := finite_task_rel phi
  nullity := ... -- Trivial: S at 0 maps to S
  compositionality := ... -- Follow from transfer properties
```

### 3. Why Compositionality Is Now Easy

The previous compositionality gaps arose from:
- Mixed-sign cases (x > 0, y <= 0, x+y > 0)
- Need to transfer Gf through intermediate state T even when going backward

With the finite model approach:
- **No intermediate states needed**: The task relation is defined directly on the finite set
- **Transfer is pointwise**: Just check the formula assignments
- **Compositionality reduces to transitivity of implication**

For compositionality proof:
- Given: `finite_task_rel S x T` and `finite_task_rel T y U`
- Goal: `finite_task_rel S (x+y) U`

For any subformula of the target:
- If box psi: S(box psi) -> T(psi) and T(box psi) -> U(psi)
  - But we also need S(box psi) -> U(psi)
  - This follows if we require: S(box psi) -> T(box psi) (box-formula persistence)

The key is that **in the finite model, we can explicitly require this persistence**.

### 4. Building the Countermodel

**Theorem** (Finite Canonical Model Completeness):
```lean
theorem finite_weak_completeness (phi : Formula) :
    (not DerivationTree [] phi) ->
    exists (M : FiniteCanonicalModel phi) (tau : FiniteHistory M) (t : FiniteTime),
      not (truth_at M tau t phi)
```

**Proof Sketch**:

1. **Given**: phi is not derivable
2. **By Lindenbaum**: Extend {neg phi} to a maximal consistent set S0 (still finite subsets suffice for consistency)
3. **Construct origin state**: S0 restricted to closure(phi) gives a FiniteWorldState
4. **Extend to history**:
   - For each time t in [-k, k], extend from origin using finite existence lemmas
   - The extension only needs to respect transfer for formulas in closure(phi)
5. **Truth lemma (restricted)**:
   - For psi in closure(phi): psi in S_t iff truth_at M tau t psi
   - Proof by induction on formula structure
   - Terminates because closure is finite
6. **Falsify phi**: Since neg phi in S0 and phi in closure(phi), we get truth_at M tau 0 (neg phi)

### 5. Key Advantages of Finite Approach

| Aspect | Infinite Canonical | Finite Canonical |
|--------|-------------------|------------------|
| Duration type | Abstract Grothendieck group | Fin (2k+1) for k = temporalDepth |
| World states | All MCS (infinite) | 2^|closure| (finite) |
| Task relation | Complex 3-part condition | Simple subformula transfer |
| Compositionality | Mixed-sign gaps | Trivially follows |
| History domain | Full Z or Duration | Finite [-k, k] |
| Proof complexity | High (many sorries) | Lower (finite induction) |
| Decidability | Separate theorem | Follows immediately |

### 6. Connection to Decidability

The finite model property directly gives decidability:

```lean
theorem decidability (phi : Formula) : Decidable (valid phi) :=
  -- valid phi iff phi true in all finite models of bounded size
  -- There are only finitely many such models
  -- Check each one computably
```

This connects to the existing `Decidability.lean` infrastructure which uses tableau with subformula property (already implemented).

### 7. Implementation Strategy

**Phase 1: Finite Time Domain** (2 hours)
- Define `FiniteTime k := Fin (2 * k + 1)`
- Define conversion to centered integers
- Prove basic arithmetic properties

**Phase 2: Finite World States** (3 hours)
- Define `FiniteWorldState phi` as assignment on `closure phi`
- Define local consistency predicate
- Prove finiteness: `Fintype (FiniteWorldState phi)`

**Phase 3: Finite Task Relation** (2 hours)
- Define `finite_task_rel` with subformula-restricted transfer
- Prove nullity (trivial)
- Prove compositionality (key lemma, but now tractable)

**Phase 4: Finite Canonical Model** (2 hours)
- Assemble frame, model, valuation
- Define history construction

**Phase 5: Finite Truth Lemma** (4 hours)
- Prove restricted truth lemma for subformulas
- Induction on formula structure
- Handle each case for finite domain

**Phase 6: Completeness** (2 hours)
- Combine pieces into weak_completeness
- Prove strong_completeness as corollary

**Total Estimated Effort**: 15-17 hours

## Decisions

1. **Abandon the abstract Duration approach**: The Grothendieck group construction, while mathematically interesting, adds unnecessary complexity for completeness
2. **Use finite model construction**: This is the standard approach in modal logic literature for decidable logics
3. **Leverage existing subformula infrastructure**: The SignedFormula.lean code provides the core building blocks
4. **Integrate with decidability**: The finite model property naturally connects completeness and decidability

## Recommendations

### Primary Recommendation: Implement Finite Canonical Model

Refactor the completeness proof to use a finite canonical model:

1. **New file**: `Completeness/FiniteCanonicalModel.lean`
2. **Preserve existing code**: The Duration and chain constructions can remain for potential future use
3. **Focus on subformula closure**: Use the existing `subformulas` function as the foundation
4. **Simple time domain**: Use `Fin (2 * temporalDepth phi + 1)` centered at origin

### Suggested File Structure

```
Bimodal/Metalogic/Completeness/
  FiniteTime.lean           -- FiniteTime type and properties
  FiniteWorldState.lean     -- Finite world state as subformula assignment
  FiniteTaskRelation.lean   -- Task relation restricted to subformulas
  FiniteCanonicalFrame.lean -- Frame construction and properties
  FiniteCanonicalModel.lean -- Model with valuation
  FiniteTruthLemma.lean     -- Truth lemma for finite model
  WeakCompleteness.lean     -- Main theorem
  StrongCompleteness.lean   -- Extension to consequences
```

### Alternative: Minimal Refactor

If the full rewrite is too ambitious:

1. Keep the current canonical_frame definition
2. Restrict the history domain to `{t : Duration | exists n : Fin (2k+1), t = n • chain_step}`
3. Prove the restricted version first, then generalize if needed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Local consistency definition complex | Medium | Medium | Start with propositional fragment |
| Finite existence lemma technical | High | Low | Similar to current forward_extension but simpler |
| Box case requires all histories | Medium | Medium | Quantify over finite set of histories |
| Integration with existing code | Low | High | Keep as separate module, connect later |

## Appendix

### A. Modal Depth vs Temporal Depth

For formula phi:
- **modalDepth(phi)**: Maximum nesting of box operators
- **temporalDepth(phi)**: Maximum nesting of G/H operators

Examples:
- `modalDepth(box (box p))` = 2
- `temporalDepth(G (H p))` = 2
- `modalDepth(box (G p))` = 1
- `temporalDepth(box (G p))` = 1

The number of world histories needed is bounded by the number of "modal worlds" reachable in modalDepth steps. Since S5 is transitive, this reduces the bound further.

### B. Subformula Closure Size

For formula phi with complexity c = complexity(phi):
- `|subformulas phi| <= c`
- This is because each connective/operator contributes exactly 1 to complexity

So the number of possible FiniteWorldStates is at most `2^c`.

### C. Literature Reference

The finite model property for temporal logics is well-established:
- Prior, Arthur N. "Past, Present and Future" (1967)
- Goldblatt, Robert. "Logics of Time and Computation" (1992) - Chapter 10
- Blackburn, de Rijke, Venema. "Modal Logic" (2001) - Chapter 4.5

The standard proof uses filtration: quotient the infinite canonical model by the equivalence relation "agree on all subformulas".

### D. Key Lemma: Finite Existence

```lean
-- For any consistent set Gamma containing subformulas of target phi,
-- and any direction d (positive or negative within bounds),
-- there exists a consistent extension Delta such that finite_task_rel Gamma d Delta
lemma finite_forward_existence (phi : Formula) (k : Nat) (hk : k <= temporalDepth phi)
    (S : FiniteWorldState phi) :
    exists T : FiniteWorldState phi, finite_task_rel phi S 1 T
```

This is simpler than the infinite case because:
1. We only need to satisfy transfer for finitely many formulas
2. Consistency is checked on finite subsets
3. Lindenbaum applies to extend any consistent finite set

## Next Steps

1. Review this approach with stakeholders
2. Create new task for finite canonical model implementation
3. Begin with Phase 1: Finite Time Domain
4. Integrate with existing decidability infrastructure in parallel
