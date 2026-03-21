# Research Report: Task #814

**Task**: Classical Propositional Completeness Infrastructure
**Date**: 2026-02-02
**Focus**: Research the 4 classical propositional sorries in BMCS infrastructure

## Summary

This task resolves 4 classical propositional sorries in the BMCS completeness infrastructure. Two sorries (`neg_imp_implies_antecedent`, `neg_imp_implies_neg_consequent`) require adapting existing Boneyard proofs to produce `DerivationTree` outputs. Two sorries (`not_derivable_implies_neg_consistent`, `context_not_derivable_implies_extended_consistent`) require combining the deduction theorem with double negation elimination.

## Findings

### 1. Sorry Locations and Types

| Location | Name | Type | Current Status |
|----------|------|------|----------------|
| TruthLemma.lean:186 | `neg_imp_implies_antecedent` | `DerivationTree [] ((ψ.imp χ).neg.imp ψ)` | sorry |
| TruthLemma.lean:198 | `neg_imp_implies_neg_consequent` | `DerivationTree [] ((ψ.imp χ).neg.imp χ.neg)` | sorry |
| Completeness.lean:184 | `not_derivable_implies_neg_consistent` | `ContextConsistent [φ.neg]` | sorry |
| Completeness.lean:323 | `context_not_derivable_implies_extended_consistent` | `ContextConsistent (Γ ++ [φ.neg])` | sorry |

### 2. Existing Infrastructure

**Proven in Propositional.lean**:
- `double_negation : ⊢ φ.neg.neg.imp φ` (line 140)
- `ecq : [A, A.neg] ⊢ B` - Ex Contradictione Quodlibet (line 225)
- `raa : ⊢ A.imp (A.neg.imp B)` - Reductio ad Absurdum (line 285)
- `efq_axiom : ⊢ Formula.bot.imp φ` - Ex Falso Quodlibet (line 84)
- `peirce_axiom : ⊢ ((φ.imp ψ).imp φ).imp φ` - Peirce's Law (line 94)

**Proven in DeductionTheorem.lean**:
- `deduction_theorem : (A :: Γ ⊢ B) → Γ ⊢ A.imp B` (line 335)

**Proven in MCSProperties.lean**:
- `set_mcs_closed_under_derivation` - derivable formulas are in MCS (line 72)
- `set_mcs_negation_complete` - either φ or ¬φ in MCS (line 174)
- `set_mcs_implication_property` - modus ponens reflected in membership (line 150)

**Proven in Boneyard/Metalogic_v5/Representation/TruthLemma.lean**:
- `neg_imp_fst` (line 153) - From ¬(φ → ψ) ∈ MCS, derive φ ∈ MCS
- `neg_imp_snd` (line 216) - From ¬(φ → ψ) ∈ MCS, derive ¬ψ ∈ MCS

**Key difference**: The Boneyard `neg_imp_fst`/`neg_imp_snd` operate at the **MCS membership level** (taking an MCS and returning membership), while the Bundle `neg_imp_implies_antecedent`/`neg_imp_implies_neg_consequent` require **DerivationTree** outputs (pure proof system level).

### 3. Analysis of Each Sorry

#### 3.1 `neg_imp_implies_antecedent` (TruthLemma.lean:186)

**Goal**: Prove `⊢ ¬(ψ → χ) → ψ` as a DerivationTree.

**Proof Strategy**:
1. Assume ¬(ψ → χ), assume ¬ψ
2. From ¬ψ, derive ψ → χ vacuously (if ψ false, implication true)
3. Contradiction with ¬(ψ → χ)
4. Therefore ψ by RAA/DNE

**Technical Implementation**:
```
1. Use deduction theorem: Need [¬(ψ → χ)] ⊢ ψ
2. Apply proof by contradiction:
   - Assume ¬ψ alongside ¬(ψ → χ)
   - Show [¬(ψ → χ), ¬ψ] ⊢ ⊥
   - Apply deduction theorem to get [¬(ψ → χ)] ⊢ ¬¬ψ
   - Apply double_negation to get [¬(ψ → χ)] ⊢ ψ
3. Final deduction theorem: ⊢ ¬(ψ → χ) → ψ
```

**Dependencies**: `deduction_theorem`, `double_negation`, `efq_axiom`, `raa`

#### 3.2 `neg_imp_implies_neg_consequent` (TruthLemma.lean:198)

**Goal**: Prove `⊢ ¬(ψ → χ) → ¬χ` as a DerivationTree.

**Proof Strategy**:
1. Assume ¬(ψ → χ), assume χ
2. From χ, derive ψ → χ (prop_s: χ → (ψ → χ))
3. Contradiction with ¬(ψ → χ)
4. Therefore ¬χ by RAA

**Technical Implementation**:
```
1. Use deduction theorem: Need [¬(ψ → χ)] ⊢ ¬χ
2. Apply proof by contradiction:
   - Assume χ alongside ¬(ψ → χ)
   - From χ, derive ψ → χ via prop_s axiom
   - Show [¬(ψ → χ), χ] ⊢ ⊥
   - Apply deduction theorem to get [¬(ψ → χ)] ⊢ ¬χ
3. Final deduction theorem: ⊢ ¬(ψ → χ) → ¬χ
```

**Dependencies**: `deduction_theorem`, `prop_s` axiom (already proven in the system)

#### 3.3 `not_derivable_implies_neg_consistent` (Completeness.lean:184)

**Goal**: If `⊬ φ` (not derivable from empty context), then `[φ.neg]` is consistent.

**Context in file**:
```lean
lemma not_derivable_implies_neg_consistent (φ : Formula)
    (h_not_deriv : ¬Nonempty (DerivationTree [] φ)) :
    ContextConsistent [φ.neg]
```

**Proof Strategy**:
1. Suppose [φ.neg] is inconsistent (derive ⊥)
2. By deduction theorem: `⊢ φ.neg → ⊥` = `⊢ ¬¬φ`
3. By `double_negation`: from `⊢ ¬¬φ` derive `⊢ φ`
4. Contradiction with `⊬ φ`

**Technical Implementation**:
```lean
intro ⟨d_bot⟩  -- Assume [φ.neg] ⊢ ⊥
-- Apply deduction theorem: get ⊢ φ.neg → ⊥ = ⊢ ¬¬φ
have d_neg_neg : DerivationTree [] (φ.neg.neg) := deduction_theorem [] φ.neg Formula.bot d_bot
-- Apply double_negation: ⊢ ¬¬φ → φ
have d_dne : DerivationTree [] (φ.neg.neg.imp φ) := double_negation φ
-- Modus ponens: ⊢ φ
have d_phi : DerivationTree [] φ := DerivationTree.modus_ponens [] _ _ d_dne d_neg_neg
-- Contradiction with h_not_deriv
exact h_not_deriv ⟨d_phi⟩
```

**Dependencies**: `deduction_theorem`, `double_negation`, modus ponens

#### 3.4 `context_not_derivable_implies_extended_consistent` (Completeness.lean:323)

**Goal**: If `Γ ⊬ φ`, then `Γ ++ [φ.neg]` is consistent.

**Context in file**:
```lean
lemma context_not_derivable_implies_extended_consistent (Γ : List Formula) (φ : Formula)
    (h_not_deriv : ¬ContextDerivable Γ φ) :
    ContextConsistent (Γ ++ [φ.neg])
```

**Proof Strategy**:
1. Suppose `Γ ++ [φ.neg]` is inconsistent (derive ⊥)
2. By deduction theorem: `Γ ⊢ φ.neg → ⊥` = `Γ ⊢ ¬¬φ`
3. By `double_negation`: from `Γ ⊢ ¬¬φ` derive `Γ ⊢ φ`
4. Contradiction with `Γ ⊬ φ`

**Technical Implementation**:
```lean
intro ⟨d_bot⟩  -- Assume (Γ ++ [φ.neg]) ⊢ ⊥
-- Need to extract φ.neg from the context to apply deduction theorem
-- First, exchange to put φ.neg last: (φ.neg :: Γ) has same elements as (Γ ++ [φ.neg])
-- Apply deduction theorem: Γ ⊢ φ.neg → ⊥ = Γ ⊢ ¬¬φ
-- Apply double_negation and modus ponens to get Γ ⊢ φ
-- Contradiction with h_not_deriv
```

**Note**: This is slightly more complex due to context ordering. The derivation from `Γ ++ [φ.neg]` needs to be reordered to apply the deduction theorem for the last element.

**Dependencies**: `deduction_theorem`, `double_negation`, context exchange lemmas from MCSProperties

### 4. Import Analysis

**Current imports in TruthLemma.lean**:
```lean
import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BMCSTruth
import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
```

**Needed import**: `Bimodal.Theorems.Propositional` (for `double_negation`)

**Current imports in Completeness.lean**:
```lean
import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BMCSTruth
import Bimodal.Metalogic.Bundle.TruthLemma
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
```

**Needed imports**:
- `Bimodal.Theorems.Propositional` (for `double_negation`)
- `Bimodal.Metalogic.Core.DeductionTheorem` (for `deduction_theorem`)

### 5. Mathlib Reference

Mathlib has equivalent propositions at the `Prop` level:
- `of_not_imp : ¬(a → b) → a` in `Mathlib.Logic.Basic`
- `not_imp : ¬(a → b) ↔ a ∧ ¬b` in `Mathlib.Logic.Basic`

However, these operate on Lean `Prop`, not on our `DerivationTree` proof system. The proofs must be done in the object-level Hilbert system.

## Recommendations

1. **Start with sorries 3.1 and 3.2** (`neg_imp_implies_antecedent`, `neg_imp_implies_neg_consequent`) as they are standalone classical tautologies requiring only proof combinators.

2. **Then resolve sorries 3.3 and 3.4** (`not_derivable_implies_neg_consistent`, `context_not_derivable_implies_extended_consistent`) as they depend on the structure but are straightforward applications of deduction theorem + DNE.

3. **Import `Bimodal.Theorems.Propositional`** in TruthLemma.lean for access to `double_negation`.

4. **Import `Bimodal.Metalogic.Core.DeductionTheorem`** in Completeness.lean for `deduction_theorem`.

5. **Consider adapting Boneyard proofs**: The Boneyard `neg_imp_fst`/`neg_imp_snd` contain the logical structure, but work at MCS level. The Bundle versions need to work at `DerivationTree` level.

## References

- `Theories/Bimodal/Theorems/Propositional.lean` - `double_negation` (line 140)
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - `deduction_theorem` (line 335)
- `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TruthLemma.lean` - `neg_imp_fst` (line 153), `neg_imp_snd` (line 216)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - sorry locations at lines 186, 198
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - sorry locations at lines 184, 323

## Next Steps

1. Create implementation plan with 4 phases (one per sorry)
2. Implement `neg_imp_implies_antecedent` and `neg_imp_implies_neg_consequent` first
3. Implement `not_derivable_implies_neg_consistent` and `context_not_derivable_implies_extended_consistent`
4. Verify all sorries resolved with `lake build`
