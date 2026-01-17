# Research Report: Task #558 (Supplemental)

**Task**: 558 - Semantic Satisfiability Bridge
**Date**: 2026-01-17
**Focus**: Detailed analysis for proving consistent_implies_satisfiable and subformulaList_finite
**Session**: sess_1768687894_ef69cd
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: Task 557 (completed)
**Sources/Inputs**:
- Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean (target file)
- Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean
- Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean
- Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean
- Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean
- Theories/Bimodal/Semantics/Validity.lean
- Theories/Bimodal/Semantics/Truth.lean
- Theories/Bimodal/Syntax/Formula.lean
- Mathlib lemmas for arithmetic bounds
**Artifacts**: - specs/558_semantic_satisfiability_bridge/reports/research-002.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **subformulaList_finite**: Straightforward induction proof showing `(subformulaList phi).length < 2 ^ phi.complexity + 1`. Key lemmas identified.
- **consistent_implies_satisfiable**: The cleanest approach is to use the existing axiom `representation_theorem_backward_empty` from ContextProvability.lean combined with soundness/representation infrastructure.
- Critical insight: The CanonicalWorldState uses abstract set membership for truth, while `formula_satisfiable` requires a concrete `TaskModel` with `truth_at` evaluation. A bridge is needed.
- Recommended approach: Use a proof that connects `Consistent [phi]` to `semantic_consequence [] phi` negation to avoid explicit model construction.

## Context & Scope

### Goal States

**subformulaList_finite** (line 81):
```lean
phi : Formula
|- (subformulaList phi).length < 2 ^ phi.complexity + 1
```

**consistent_implies_satisfiable** (line 162):
```lean
phi : Formula
h_cons : Consistent [phi]
w : CanonicalWorldState
h_sat : forall phi_1 in [phi], canonicalTruthAt w phi_1
|- formula_satisfiable phi
```

### Type Definitions

**formula_satisfiable** (from Validity.lean):
```lean
def formula_satisfiable (phi : Formula) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

**CanonicalWorldState** (from CanonicalModel.lean):
```lean
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}
def canonicalTruthAt (w : CanonicalWorldState) (phi : Formula) : Prop := phi in w.carrier
```

**complexity** (from Formula.lean):
```lean
def complexity : Formula -> Nat
  | atom _ => 1
  | bot => 1
  | imp phi psi => 1 + phi.complexity + psi.complexity
  | box phi => 1 + phi.complexity
  | all_past phi => 1 + phi.complexity
  | all_future phi => 1 + phi.complexity
```

**subformulaList** (from FiniteModelProperty.lean):
```lean
def subformulaList (phi : Formula) : List Formula :=
  match phi with
  | Formula.atom p => [Formula.atom p]
  | Formula.bot => [Formula.bot]
  | Formula.imp psi chi => (Formula.imp psi chi) :: (subformulaList psi ++ subformulaList chi)
  | Formula.box psi => (Formula.box psi) :: subformulaList psi
  | Formula.all_future psi => (Formula.all_future psi) :: subformulaList psi
  | Formula.all_past psi => (Formula.all_past psi) :: subformulaList psi
```

## Findings

### Theorem 1: subformulaList_finite

#### Proof Strategy

Induction on formula structure. The key insight:
- `complexity` adds 1 for each constructor
- `subformulaList` concatenates sublists
- Powers of 2 grow exponentially, allowing the bound to hold

#### Base Cases

| Formula | complexity | subformulaList length | Bound = 2^c + 1 | Check |
|---------|------------|----------------------|-----------------|-------|
| atom p | 1 | 1 | 2^1 + 1 = 3 | 1 < 3 |
| bot | 1 | 1 | 3 | 1 < 3 |

#### Inductive Cases

For compound formulas like `imp psi chi`:
- complexity = 1 + psi.complexity + chi.complexity
- length = 1 + length(psi) + length(chi)
- IH: length(psi) < 2^c_psi + 1, length(chi) < 2^c_chi + 1
- Need: 1 + len(psi) + len(chi) < 2^(1 + c_psi + c_chi) + 1

The key arithmetic lemma needed:
```
n < 2^a + 1 /\ m < 2^b + 1 ==> 1 + n + m < 2^(1 + a + b) + 1
```

This follows from:
- n + m < 2^a + 2^b + 2
- 2^a + 2^b <= 2 * 2^(max a b) <= 2^(1 + max a b)
- For a + b >= 1: 2^(1 + a + b) >= 2^a + 2^b (provable by induction)

#### Key Mathlib Lemmas

1. `List.length_append`: `(l1 ++ l2).length = l1.length + l2.length`
2. `List.length_cons`: `(a :: l).length = l.length + 1`
3. `Nat.pow_add`: `m ^ (a + b) = m ^ a * m ^ b`
4. `Nat.two_pow_succ`: `2 ^ (n + 1) = 2 ^ n + 2 ^ n`
5. `add_lt_add`: `a < b -> c < d -> a + c < b + d`
6. `Nat.add_lt_add_of_lt_of_lt`: Variant for natural numbers

#### Proof Sketch

```lean
theorem subformulaList_finite (phi : Formula) :
    (subformulaList phi).length < 2 ^ phi.complexity + 1 := by
  induction phi with
  | atom p =>
    simp [subformulaList, Formula.complexity]
    -- 1 < 3
    omega
  | bot =>
    simp [subformulaList, Formula.complexity]
    omega
  | imp psi chi ih_psi ih_chi =>
    simp only [subformulaList, Formula.complexity, List.length_cons, List.length_append]
    -- Need: 1 + len(psi) + len(chi) < 2^(1 + c_psi + c_chi) + 1
    -- Use arithmetic manipulation with IH
    have h1 : (subformulaList psi).length + (subformulaList chi).length <
              2 ^ psi.complexity + 2 ^ chi.complexity + 2 := by
      omega  -- from ih_psi and ih_chi
    -- Key: 2^a + 2^b + 2 <= 2^(1 + a + b) for a,b >= 1
    -- Since complexity >= 1 for all formulas
    calc 1 + (subformulaList psi).length + (subformulaList chi).length
        < 1 + (2 ^ psi.complexity + 2 ^ chi.complexity + 2) := by omega
      _ = 2 ^ psi.complexity + 2 ^ chi.complexity + 3 := by ring
      _ <= 2 ^ (1 + psi.complexity + chi.complexity) + 1 := by
        -- This needs the key arithmetic lemma
        sorry
  | box psi ih =>
    simp only [subformulaList, Formula.complexity, List.length_cons]
    -- 1 + len(psi) < 2^(1 + c_psi) + 1
    have h : (subformulaList psi).length < 2 ^ psi.complexity + 1 := ih
    calc 1 + (subformulaList psi).length
        < 1 + (2 ^ psi.complexity + 1) := by omega
      _ = 2 ^ psi.complexity + 2 := by ring
      _ <= 2 ^ (1 + psi.complexity) + 1 := by
        -- 2^n + 2 <= 2^(n+1) + 1 = 2*2^n + 1
        -- Equiv: 2 <= 2^n + 1, true for n >= 1
        have h_comp : 1 <= psi.complexity := complexity_pos psi
        omega
  | all_future psi ih => -- Similar to box
    sorry
  | all_past psi ih => -- Similar to box
    sorry
```

**Note**: Need a helper lemma `complexity_pos : forall phi, 1 <= phi.complexity`

### Theorem 2: consistent_implies_satisfiable

#### Challenge Analysis

The theorem goal after `representation_theorem` gives us:
- `w : CanonicalWorldState` with `phi in w.carrier`

But `formula_satisfiable phi` requires:
- A concrete `TaskModel F` with valuation function
- A `WorldHistory F`
- A time `t : D`
- Proof that `truth_at M tau t phi`

The gap: `canonicalTruthAt` (set membership) vs `truth_at` (semantic evaluation).

#### Approach 1: Via Soundness/Completeness Infrastructure

The existing axiom in ContextProvability.lean:
```lean
axiom representation_theorem_backward_empty {phi : Formula} :
    semantic_consequence [] phi -> ContextDerivable [] phi
```

And the soundness theorem:
```lean
theorem context_soundness (Gamma : Context) (phi : Formula) :
    ContextDerivable Gamma phi -> semantic_consequence Gamma phi
```

**Key Insight**: If `Consistent [phi]`, then `[phi] |-/- bot`.

By contrapositive of completeness: if `phi` were unsatisfiable, then `neg phi` would be valid, hence provable, contradicting consistency.

**Proposed Proof**:
```lean
theorem consistent_implies_satisfiable (phi : Formula) (h_cons : Consistent [phi]) :
    formula_satisfiable phi := by
  -- Assume phi is not satisfiable
  by_contra h_not_sat
  -- Then neg phi is valid (true everywhere)
  have h_neg_valid : valid (Formula.neg phi) := by
    intro D _ _ _ F M tau t
    -- If phi is not satisfiable, then neg phi is true everywhere
    simp only [truth_at]
    intro h_phi
    -- h_phi : truth_at M tau t phi
    -- But this contradicts h_not_sat
    apply h_not_sat
    exact ⟨D, _, _, _, F, M, tau, t, h_phi⟩
  -- By representation_theorem_backward_empty (axiom), [] |- neg phi
  have h_neg_derivable := valid_implies_derivable h_neg_valid
  -- But this contradicts Consistent [phi]
  -- Because [phi] |- bot via:
  --   1. [] |- neg phi
  --   2. [phi] |- phi (assumption)
  --   3. [phi] |- neg phi (weakening)
  --   4. [phi] |- bot (modus ponens on phi, neg phi)
  apply h_cons
  obtain ⟨d_neg⟩ := h_neg_derivable
  have d_neg' := DerivationTree.weakening [] [phi] (Formula.neg phi) d_neg (by simp)
  have d_phi := DerivationTree.assumption [phi] phi (List.mem_singleton.mpr rfl)
  exact ⟨derives_bot_from_phi_neg_phi d_phi d_neg'⟩
```

#### Approach 2: Simplified Canonical Model Construction

Use `D := Unit` as a degenerate temporal type:
- Only one time point `() : Unit`
- No past or future times (vacuously satisfied)
- Simplified frame construction

**Challenges**:
- `Unit` may not have required `AddCommGroup`/`LinearOrder`/`IsOrderedAddMonoid` instances
- Need to construct `TaskFrame Unit` and `TaskModel` appropriately
- The box operator semantics require quantifying over all histories

#### Recommended Approach

**Use Approach 1** - the contrapositive proof via soundness/completeness is cleaner and doesn't require constructing explicit models. It leverages existing infrastructure (`valid_implies_derivable`, `derives_bot_from_phi_neg_phi`).

### Available Infrastructure

| Lemma | Location | Status | Use |
|-------|----------|--------|-----|
| `representation_theorem` | RepresentationTheorem.lean | Complete | Get CanonicalWorldState |
| `representation_theorem_backward_empty` | ContextProvability.lean | Axiom | valid -> derivable |
| `valid_implies_derivable` | ContextProvability.lean | Complete | Wrapper for axiom |
| `context_soundness` | ContextProvability.lean | Complete | derivable -> semantic |
| `mcs_contains_or_neg` | CanonicalModel.lean | Complete | MCS property |
| `mcs_modus_ponens` | CanonicalModel.lean | Complete | MCS closure |
| `derives_bot_from_phi_neg_phi` | Theorems.Propositional | Complete | Contradiction |
| `DerivationTree.weakening` | ProofSystem | Complete | Context weakening |

## Decisions

1. **subformulaList_finite**: Use structural induction with omega/linarith for arithmetic. May need a helper for `complexity_pos`.

2. **consistent_implies_satisfiable**: Use the contrapositive proof via `valid_implies_derivable` axiom rather than explicit model construction.

## Recommendations

### Implementation Priority

1. **Phase 1**: Prove `subformulaList_finite` (30-45 min)
   - Simple structural induction
   - Arithmetic manipulation with omega
   - May need `complexity_pos` helper

2. **Phase 2**: Prove `consistent_implies_satisfiable` (30-60 min)
   - Contrapositive argument
   - Use existing `valid_implies_derivable`
   - Build contradiction from negation derivability

### Key Helper Lemmas Needed

For `subformulaList_finite`:
```lean
lemma complexity_pos (phi : Formula) : 1 <= phi.complexity := by
  cases phi <;> simp [Formula.complexity] <;> omega
```

For `consistent_implies_satisfiable`:
- `valid_implies_derivable` (already exists)
- `derives_bot_from_phi_neg_phi` (already exists in Theorems.Propositional)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Arithmetic bound complexity | Medium | Use omega with careful setup, may need helper lemmas |
| Missing instances for Unit temporal type | High (if using Approach 2) | Use Approach 1 instead |
| Axiom dependency | Low | `representation_theorem_backward_empty` is standard completeness direction |

## Appendix

### Search Queries Used

1. `lean_local_search "formula_satisfiable"` - Found definition
2. `lean_local_search "Consistent"` - Found multiple definitions
3. `lean_local_search "representation_theorem"` - Found theorem and axiom
4. `lean_loogle "List.length (_ ++ _)"` - Found `List.length_append`
5. `lean_loogle "_ < 2 ^ _"` - Found power of 2 lemmas
6. `lean_leansearch "power of 2 addition exponent"` - Found `pow_add`
7. `lean_leanfinder "sum bounded by power of 2"` - Found related bounds

### Mathlib Lemmas Summary

| Lemma | Type | Use |
|-------|------|-----|
| `List.length_append` | `(as ++ bs).length = as.length + bs.length` | subformulaList recursion |
| `Nat.two_pow_succ` | `2 ^ (n + 1) = 2 ^ n + 2 ^ n` | Power doubling |
| `Nat.pow_add` | `m ^ (a + b) = m ^ a * m ^ b` | Power split |
| `add_lt_add` | `a < b -> c < d -> a + c < b + d` | Bound combination |

### File Hierarchy

```
FiniteModelProperty.lean
|-- imports RepresentationTheorem.lean
|   |-- imports CanonicalModel.lean
|   |   |-- imports Core/MaximalConsistent.lean
|   |-- imports TruthLemma.lean
|-- imports Soundness/Soundness.lean
|-- imports Semantics/Validity.lean
    |-- imports Semantics/Truth.lean
```

## Next Steps

Run `/plan 558` to create detailed implementation plan with step-by-step proof construction.
