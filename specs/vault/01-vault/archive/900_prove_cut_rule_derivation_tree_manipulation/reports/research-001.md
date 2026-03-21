# Research Report: Cut Rule and Derivation Tree Manipulation for Recursive Seed Henkin Model

**Task Number**: 900
**Session ID**: sess_1771435804_70ed56
**Date**: 2026-02-18
**Focus**: Cut rule formulation and derivation tree manipulation for Phase 4 of task 864

## Executive Summary

This research investigates what "cut rule" means in the context of the recursive seed Henkin model construction and identifies the proof infrastructure needed to complete Phase 4 of task 864. The key finding is that the codebase already contains the necessary infrastructure (the **deduction theorem**), but the consistency preservation lemmas need to be proven using a combination of deduction theorem and derivation tree manipulation.

## Background Context

Phase 4 of task 864 (RecursiveSeed.lean) has 22 sorries related to consistency preservation in the worklist algorithm. The implementation plan notes:

> **Key blocker: Cut rule / derivation tree manipulation not directly available**

### Affected Sorries

1. **Subformula consistency lemmas** (6 sorries):
   - `box_inner_consistent`: Box psi consistent implies psi consistent
   - `all_future_inner_consistent`: G psi consistent implies psi consistent
   - `all_past_inner_consistent`: H psi consistent implies psi consistent
   - `neg_box_neg_inner_consistent`: neg(Box psi) consistent implies neg psi consistent
   - `neg_future_neg_inner_consistent`: neg(G psi) consistent implies neg psi consistent
   - `neg_past_neg_inner_consistent`: neg(H psi) consistent implies neg psi consistent

2. **Work item processing** (10+ sorries in `processWorkItem_preserves_consistent`)

3. **New work item consistency** (6 sorries in `processWorkItem_newWork_consistent`)

## Research Findings

### 1. What is "Cut Rule" in This Context?

The "cut rule" mentioned in the implementation plan refers to the ability to compose derivations. In sequent calculus, cut is:

```
Gamma |- A      A, Delta |- B
-----------------------------
      Gamma, Delta |- B
```

In this Hilbert-style proof system, the equivalent capability is achieved through:

1. **The deduction theorem**: If `A :: Gamma |- B` then `Gamma |- A -> B`
2. **Modus ponens composition**: Chain derivations via implication

The codebase already has the deduction theorem in `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean`:

```lean
noncomputable def deduction_theorem (Gamma : Context) (A B : Formula)
    (h : (A :: Gamma) |- B) : Gamma |- A.imp B
```

### 2. Existing Derivation Infrastructure

The codebase has the following relevant infrastructure:

**In `DeductionTheorem.lean`**:
- `deduction_theorem`: Main metatheorem for converting derivations to implications
- `deduction_mp`: Modus ponens under implication
- `deduction_with_mem`: Helper for deduction with formula in middle of context

**In `Derivation.lean`**:
- `DerivationTree`: Inductive type for proof trees
- `DerivationTree.modus_ponens`: Implication elimination
- `DerivationTree.weakening`: Adding unused assumptions
- `DerivationTree.necessitation`: Box introduction (empty context only)
- `DerivationTree.temporal_necessitation`: G introduction (empty context only)

**In `MCSProperties.lean`**:
- `derives_bot_from_phi_neg_phi`: From `Gamma |- phi` and `Gamma |- neg phi`, derive `Gamma |- bot`
- `set_mcs_closed_under_derivation`: Derivable formulas are in MCS

### 3. Proof Strategies for Consistency Lemmas

#### Strategy for `box_inner_consistent`

**Statement**: If `Box psi` is consistent, then `psi` is consistent.

**Proof sketch**:
1. Assume `psi` is inconsistent (i.e., `[psi] |- bot`)
2. By deduction theorem: `[] |- psi -> bot`
3. By T-axiom: `[] |- Box psi -> psi`
4. By propositional logic: `[] |- Box psi -> bot` (chain implications)
5. So `[Box psi] |- bot`, contradicting `Box psi` consistent

**Implementation**:
```lean
theorem box_inner_consistent (psi : Formula)
    (h : FormulaConsistent (Formula.box psi)) :
    FormulaConsistent psi := by
  intro h_incons  -- Assume [psi] |- bot
  -- Get psi -> bot from deduction theorem
  have h_psi_neg : [] |- psi.neg := by
    have := h_incons.choose
    exact deduction_theorem [] psi Formula.bot this
  -- T-axiom: Box psi -> psi
  have h_t : [] |- (Formula.box psi).imp psi :=
    DerivationTree.axiom [] _ (Axiom.modal_t psi)
  -- Chain: Box psi -> psi -> bot gives Box psi -> bot
  have h_chain : [] |- (Formula.box psi).imp Formula.bot := by
    have h_to_bot : [] |- psi.imp Formula.bot := h_psi_neg
    -- Use prop_k to compose implications
    sorry -- Propositional chaining
  -- [Box psi] |- bot
  apply h
  constructor
  exact DerivationTree.modus_ponens [Formula.box psi] _ _
    (DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
    (DerivationTree.assumption _ _ (by simp))
```

#### Strategy for `neg_box_neg_inner_consistent`

**Statement**: If `neg(Box psi)` is consistent, then `neg psi` is consistent.

**Proof sketch** (contrapositive):
1. Assume `neg psi` is inconsistent (i.e., `[neg psi] |- bot`)
2. By deduction theorem: `[] |- neg psi -> bot`, i.e., `[] |- neg(neg psi)`
3. By double negation elimination: `[] |- psi`
4. By necessitation rule: `[] |- Box psi`
5. Since `Box psi` is a theorem, `[neg(Box psi), Box psi] |- bot`
6. So `neg(Box psi)` is inconsistent

**Key insight**: The necessitation rule `|- phi` implies `|- Box phi` is crucial for the negative modal cases.

#### Strategy for Temporal Cases

The temporal cases (`all_future_inner_consistent`, `all_past_inner_consistent`, `neg_future_neg_inner_consistent`, `neg_past_neg_inner_consistent`) follow identical patterns using:
- `Axiom.temp_t_future`: `G phi -> phi` (temporal T for future)
- `Axiom.temp_t_past`: `H phi -> phi` (temporal T for past)
- `DerivationTree.temporal_necessitation`: `|- phi` implies `|- G phi`
- `DerivationTree.temporal_duality`: `|- phi` implies `|- swap_past_future phi`

### 4. Missing Infrastructure

The proofs require the following helper lemmas that need to be built:

1. **Implication chaining**: `(A -> B) -> (B -> C) -> (A -> C)`
   - This is derivable from prop_k but needs explicit construction

2. **Double negation elimination**: `neg(neg phi) -> phi`
   - Already referenced as derivable in `Propositional.lean` docstrings

3. **Theorem-to-inconsistency bridge**: If `|- phi` and `|- neg phi`, then inconsistent
   - Follows from modus ponens on weakened derivations

### 5. Implementation Recommendations

#### Phase 4A: Build Helper Lemmas

Create a new file or extend `Combinators.lean`:

```lean
-- Implication chaining
def imp_trans {A B C : Formula} (h1 : |- A.imp B) (h2 : |- B.imp C) : |- A.imp C

-- Double negation elimination (context version)
def dne {Gamma : Context} {phi : Formula}
    (h : Gamma |- phi.neg.neg) : Gamma |- phi

-- Theorem implies consistency
def theorem_consistent {phi : Formula} (h : |- phi) : FormulaConsistent phi
```

#### Phase 4B: Prove Subformula Consistency Lemmas

Use the strategies outlined above to prove all 6 subformula consistency theorems.

#### Phase 4C: Complete `processWorkItem_preserves_consistent`

With subformula consistency proven, the 10 cases in `processWorkItem_preserves_consistent` become straightforward applications of:
- `addFormula_seed_preserves_consistent`
- `createNewFamily_preserves_seedConsistent`
- `createNewTime_preserves_seedConsistent`

### 6. Mathlib Search Results

Searching Mathlib for "cut rule" and related concepts yielded no directly applicable results. This is expected because:
- Mathlib focuses on mathematical structures, not proof theory
- Cut elimination is a meta-theorem about specific proof systems

The infrastructure needs to be built within this codebase using the existing proof system definitions.

## Technical Debt Assessment

Per the proof debt policy (`.claude/context/project/lean4/standards/proof-debt-policy.md`):

- **Sorries introduced**: 0 (research phase)
- **Sorries resolved**: Target 22 sorries in Phase 4
- **Remediation strategy**: The sorries require proof theory infrastructure (deduction theorem composition), not mathematical lemmas

## Recommendations

### Immediate Actions

1. **Create helper lemmas** for implication chaining and double negation elimination
2. **Prove `box_inner_consistent`** as the template for all subformula consistency lemmas
3. **Verify propositional infrastructure** in `Combinators.lean` or create new helpers

### Implementation Order

1. `box_inner_consistent` (uses T-axiom, deduction theorem)
2. `all_future_inner_consistent`, `all_past_inner_consistent` (identical pattern with temporal axioms)
3. `neg_box_neg_inner_consistent` (uses necessitation, double negation)
4. `neg_future_neg_inner_consistent`, `neg_past_neg_inner_consistent` (temporal variants)
5. `processWorkItem_preserves_consistent` (case analysis using above)
6. `processWorkItem_newWork_consistent` (same infrastructure)

### Dependencies

The implementation depends on:
- `DeductionTheorem.lean` (already complete)
- `Derivation.lean` (already complete)
- Propositional helpers in `Combinators.lean` (may need extension)

## File References

| File | Purpose | Status |
|------|---------|--------|
| `RecursiveSeed.lean` (lines 7000-7250) | Contains the 22 sorries | Main target |
| `DeductionTheorem.lean` | Core metatheorem | Complete |
| `MCSProperties.lean` | MCS closure lemmas | Complete |
| `Derivation.lean` | Proof tree definitions | Complete |
| `Axioms.lean` | T-axiom, 4-axiom definitions | Complete |
| `Combinators.lean` | Propositional helpers | May need extension |

## Conclusion

The "cut rule" problem is solvable using existing infrastructure. The deduction theorem provides the composition capability needed, and the axiom system includes the T-axioms and necessitation rules required for the consistency proofs. The main work is:

1. Building propositional helper lemmas for implication chaining
2. Applying the proof pattern consistently across all 6 subformula consistency lemmas
3. Using these lemmas to complete the worklist algorithm preservation proofs

The estimated effort is moderate (1-2 implementation sessions) once the helper infrastructure is in place.
