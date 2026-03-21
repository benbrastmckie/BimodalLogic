# Research Report: Task #558

**Task**: Semantic Satisfiability Bridge - Prove consistent_implies_satisfiable and subformulaList_finite
**Date**: 2026-01-17
**Focus**: Prove consistent_implies_satisfiable and subformulaList_finite in Representation/FiniteModelProperty.lean. Focus on: (1) structure of consistent_implies_satisfiable theorem, (2) subformula list finiteness, (3) bridge from canonical world to semantic satisfiability
**Session**: sess_1768686477_68b745
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: Task 557 (completed)
**Sources/Inputs**:
- Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean (target file)
- Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean (representation theorem)
- Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean (canonical world state)
- Theories/Bimodal/Semantics/Validity.lean (formula_satisfiable definition)
- Theories/Bimodal/Semantics/Truth.lean (truth_at definition)
- Theories/Bimodal/Syntax/Formula.lean (Formula.complexity definition)
- Mathlib.Data.List.Sublists (List.length_sublists for exponential bounds)
**Artifacts**: - specs/558_semantic_satisfiability_bridge/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Two `sorry` placeholders remain in `FiniteModelProperty.lean`: `subformulaList_finite` (line 81) and `consistent_implies_satisfiable` (line 162)
- **subformulaList_finite** is a straightforward structural induction proof showing `(subformulaList phi).length < 2 ^ phi.complexity + 1`
- **consistent_implies_satisfiable** requires bridging between the **abstract** `CanonicalWorldState` (membership-based truth) and **concrete** `TaskModel`/`WorldHistory` (semantic truth via `truth_at`)
- The key challenge is that `CanonicalWorldState` is not directly a `TaskModel` - it uses set membership for truth, not the `truth_at` function which requires an actual frame, model, history, and time point
- Recommended approach: Either (1) construct a concrete TaskModel from the canonical world, or (2) use an axiom/sorry as a semantic bridge pending full model construction

## Context & Scope

### Current State

The file `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` contains:
- Complete `subformulaList` definition (recursive list of subformulas)
- Complete `self_mem_subformulaList` theorem
- Incomplete `subformulaList_finite` theorem (line 81) - `sorry`
- Complete `finite_model_property` theorem (trivial, just unpacks satisfiability witness)
- Incomplete `consistent_implies_satisfiable` theorem (line 162) - `sorry`

### Type Gap Analysis

**CanonicalWorldState** (from CanonicalModel.lean):
```lean
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}
def canonicalTruthAt (w : CanonicalWorldState) (phi : Formula) : Prop := phi in w.carrier
```

**formula_satisfiable** (from Validity.lean):
```lean
def formula_satisfiable (phi : Formula) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

The mismatch: `canonicalTruthAt` checks set membership in an MCS, while `formula_satisfiable` requires an actual `TaskModel` and `truth_at` evaluation.

### Why These Matter

- **subformulaList_finite**: Required for proving finite model size bounds
- **consistent_implies_satisfiable**: The critical theorem connecting syntactic consistency to semantic satisfiability - this is the "bridge" between proof theory and model theory

## Findings

### Theorem 1: subformulaList_finite

**Goal State** (at line 81):
```lean
phi : Formula
forall (subformulaList phi).length < 2 ^ phi.complexity + 1
```

**Proof Strategy**:

Structural induction on the formula. The key insight is that `complexity` grows additively while `subformulaList` concatenates lists:

| Formula | complexity | subformulaList length bound |
|---------|------------|---------------------------|
| atom p | 1 | 1 |
| bot | 1 | 1 |
| imp psi chi | 1 + psi.complexity + chi.complexity | 1 + len(psi) + len(chi) |
| box psi | 1 + psi.complexity | 1 + len(psi) |
| all_past psi | 1 + psi.complexity | 1 + len(psi) |
| all_future psi | 1 + psi.complexity | 1 + len(psi) |

**Base cases** (atom, bot):
- complexity = 1
- subformulaList length = 1
- Need: 1 < 2^1 + 1 = 3 (true!)

**Inductive case** (imp psi chi):
- complexity = 1 + psi.complexity + chi.complexity
- length = 1 + length(psi) + length(chi)
- IH: length(psi) < 2^psi.complexity + 1, length(chi) < 2^chi.complexity + 1
- Need: 1 + len(psi) + len(chi) < 2^(1 + c_psi + c_chi) + 1
- Use: 2^(a+b) >= 2^a + 2^b for a,b >= 1

**Key Mathlib Lemmas**:
- `List.length_append`: for `(l1 ++ l2).length = l1.length + l2.length`
- `Nat.pow_add`: for `2^(a+b) = 2^a * 2^b`
- Arithmetic manipulation lemmas

**Estimated Effort**: 30-45 minutes

### Theorem 2: consistent_implies_satisfiable

**Goal State** (at line 162):
```lean
phi : Formula
h_cons : Consistent [phi]
w : CanonicalWorldState
h_sat : forall phi_1 in [phi], canonicalTruthAt w phi_1
forall formula_satisfiable phi
```

**The Core Challenge**:

`representation_theorem` gives us a `CanonicalWorldState w` where `canonicalTruthAt w phi` (i.e., `phi in w.carrier`), but we need to produce:
- A type `D : Type` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`
- A `TaskFrame D`
- A `TaskModel F`
- A `WorldHistory F`
- A time `t : D`
- A proof that `truth_at M tau t phi`

**Approach Options**:

#### Option A: Construct Concrete Model (Full Solution)

Build a concrete semantic model from the canonical construction:

1. **Temporal Type**: Use `D := Int` (or `D := Unit` for a degenerate time model)

2. **Frame Construction**:
   - `WorldState := CanonicalWorldState` (each MCS is a world state)
   - `TaskRelation` can be constructed from box accessibility in `canonicalFrame`

3. **Model Construction**:
   - `valuation w p := (Formula.atom p) in w.carrier`

4. **History Construction**:
   - For a single formula, we can use a trivial history at a single time point

5. **Truth Correspondence**:
   - Prove by structural induction that `truth_at M tau t phi <-> phi in w.carrier`
   - This is the **deep truth lemma** connecting semantic truth to syntactic membership

**Challenges with Option A**:
- `TaskFrame` requires temporal consistency (`nullity`, `compositionality`)
- `WorldHistory` requires domain predicates
- The box operator semantics (quantify over ALL histories) is hard to match with MCS construction
- Full implementation requires significant infrastructure

#### Option B: Axiom-Based Bridge (Pragmatic Solution)

Use an axiom or `sorry` as a semantic bridge:

```lean
axiom representation_theorem_backward_empty :
    forall {phi : Formula}, Consistent [phi] -> formula_satisfiable phi
```

This declares the completeness theorem direction as an axiom, which is valid since:
1. The soundness direction (satisfiable -> consistent) is proven
2. The completeness theorem is a standard result for modal logics
3. The full proof requires substantial model construction infrastructure

**Current Approach in File**: The file already uses this pattern - it has `sorry` as placeholder.

#### Option C: Simplified Canonical Model

Construct a **simplified** canonical model that doesn't use the full temporal/modal structure:

1. Use `D := Unit` (trivial time)
2. Single world state, single time point
3. Valuation maps atoms to their MCS membership
4. Prove the restricted truth lemma for this simple case

**This is likely the most practical approach**.

### Proof Sketch for Option C

```lean
theorem consistent_implies_satisfiable (phi : Formula) (h_cons : Consistent [phi]) :
    formula_satisfiable phi := by
  -- Get canonical world from representation theorem
  obtain <w, h_sat> := representation_theorem h_cons
  -- Construct trivial temporal model
  use Unit -- D := Unit
  use inferInstance -- AddCommGroup Unit (trivial)
  use inferInstance -- LinearOrder Unit
  use inferInstance -- IsOrderedAddMonoid Unit
  -- Construct frame with w.carrier as single world state
  let F : TaskFrame Unit := ... -- trivial frame
  use F
  -- Construct model with valuation from MCS membership
  let M : TaskModel F := { valuation := fun _ p => (Formula.atom p) in w.carrier }
  use M
  -- Construct trivial history
  let tau : WorldHistory F := ... -- trivial history at ()
  use tau
  use () -- time point
  -- Prove truth correspondence
  -- This requires showing: truth_at M tau () phi <-> phi in w.carrier
  sorry -- Deep truth lemma
```

The **deep truth lemma** showing `truth_at M tau t phi <-> phi in w.carrier` requires:
- Atom case: Direct from valuation definition
- Bot case: Both sides are False
- Imp case: By MCS properties (`mcs_modus_ponens`, `mcs_contains_or_neg`)
- Box case: **Hard** - requires all histories at time t
- Temporal cases: For `D := Unit`, these are trivially true

### Existing Infrastructure Analysis

**From RepresentationTheorem.lean** (proven):

| Lemma | Status | Relevance |
|-------|--------|-----------|
| `representation_theorem` | Complete | Gives CanonicalWorldState for consistent context |
| `strong_representation_theorem` | Complete | Extended version |
| `representation_satisfiability` | Complete | Iff version |

**From CanonicalModel.lean** (proven after Task 557):

| Lemma | Status | Relevance |
|-------|--------|-----------|
| `mcs_contains_or_neg` | Complete | Negation completeness |
| `mcs_modus_ponens` | Complete | MP closure |
| `CanonicalWorldState.is_consistent` | Complete | Consistency |
| `CanonicalWorldState.is_maximal` | Complete | Maximality |

**From TruthLemma.lean**:

| Lemma | Status | Relevance |
|-------|--------|-----------|
| `canonicalTruthAt` | Complete | Membership-based truth |
| `truthLemma_detailed` | Complete | Trivial equivalence |
| `canonical_modus_ponens` | Complete | MP for canonical truth |
| `canonical_complete` | Complete | Negation completeness for canonical truth |

## Decisions

1. **subformulaList_finite**: Implement via structural induction with arithmetic bound manipulation
2. **consistent_implies_satisfiable**: Recommend Option C (simplified canonical model) for a working implementation, with TODO comment noting full model construction is future work

## Recommendations

### Implementation Plan

**Phase 1: Prove subformulaList_finite** (30-45 min)
1. Induction on formula structure
2. Handle base cases (atom, bot) directly
3. For compound cases, use IH and arithmetic lemmas
4. Key lemma needed: `n + m < 2^a * 2^b` when `n < 2^a` and `m < 2^b`

**Phase 2: Prove consistent_implies_satisfiable** (1-2 hours)
1. Use `Unit` as trivial temporal type
2. Construct trivial TaskFrame over Unit
3. Construct TaskModel with MCS-based valuation
4. Construct trivial WorldHistory
5. Prove truth correspondence (may need helper lemmas)
6. Alternative: Use axiom/sorry if time constraints

### Key Lemmas to Prove/Find

For `subformulaList_finite`:
- `List.length_cons` (exists)
- `List.length_append` (exists)
- `Nat.pow_add` (exists)
- May need: `2^(1+a+b) > 1 + 2^a + 2^b` for a,b >= 1

For `consistent_implies_satisfiable`:
- Trivial TaskFrame construction over Unit
- Trivial WorldHistory over trivial frame
- Atomic truth correspondence lemma

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Exponential bound arithmetic complexity | Medium | Use omega/linarith tactics with clear setup |
| Modal box case in truth correspondence | High | For Unit time, histories are degenerate - simplifies proof |
| Temporal operators at Unit time | Low | all_past/all_future over empty sets are vacuously true |
| TaskFrame/WorldHistory construction | Medium | Use simplest possible construction (Unit-based) |

## Appendix

### Search Queries Used

1. `lean_local_search "formula_satisfiable"` - Found definition in Validity.lean
2. `lean_local_search "Formula.complexity"` - Found empty (defined inline)
3. `lean_leansearch "list length exponential bound recursive function"` - Found relevant Mathlib patterns
4. `lean_leanfinder "maximal consistent set to semantic model construction"` - Found general patterns

### File Dependencies

```
FiniteModelProperty.lean
+-- imports Bimodal.Metalogic_v2.Representation.RepresentationTheorem
|   +-- imports Bimodal.Metalogic_v2.Representation.CanonicalModel
|   +-- imports Bimodal.Metalogic_v2.Representation.TruthLemma
+-- imports Bimodal.Metalogic_v2.Soundness.Soundness
+-- imports Bimodal.Semantics.Validity
    +-- imports Bimodal.Semantics.Truth
    +-- imports Bimodal.Syntax.Context
```

### Goal States Summary

**subformulaList_finite** (line 81):
```lean
phi : Formula
forall (subformulaList phi).length < 2 ^ phi.complexity + 1
```

**consistent_implies_satisfiable** (line 162):
```lean
phi : Formula
h_cons : Consistent [phi]
w : CanonicalWorldState
h_sat : forall phi_1 in [phi], canonicalTruthAt w phi_1
forall formula_satisfiable phi
```

### Type Alignment Requirements

To prove `consistent_implies_satisfiable`, need to show these types align:

1. **Truth at canonical world**: `phi in w.carrier` (membership)
2. **Semantic truth**: `truth_at M tau t phi` (recursive evaluation)

Key cases:
- Atom: `truth_at M tau t (atom p)` needs domain check + valuation
- Imp: `truth_at M tau t (phi.imp psi)` = material conditional
- Box: `truth_at M tau t (box phi)` = forall histories at t
- Temporal: `truth_at M tau t (all_past phi)` = forall s < t, truth_at M tau s phi

For `D := Unit`, temporal cases become trivial (no s < () or () < s).

## Next Steps

Run `/plan 558` to create implementation plan with detailed proof construction steps.
