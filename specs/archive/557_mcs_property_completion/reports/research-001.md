# Research Report: Task #557

**Task**: MCS Property Completion - Prove mcs_contains_or_neg and mcs_modus_ponens
**Date**: 2026-01-17
**Focus**: Prove mcs_contains_or_neg and mcs_modus_ponens in Representation/CanonicalModel.lean. These MCS properties are the critical blocking dependency for downstream theorems.
**Session**: sess_1768684140_373190
**Sources/Inputs**:
- Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean (target file)
- Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean (MCS infrastructure)
- Theories/Bimodal/Theorems/Propositional.lean (propositional theorems)
- Theories/Bimodal/ProofSystem/Derivation.lean (derivation trees)
- Mathlib.ModelTheory.Satisfiability (FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem)

## Executive Summary

- Two `sorry` placeholders remain in `CanonicalModel.lean`: `mcs_contains_or_neg` (line 192) and `mcs_modus_ponens` (line 209)
- Both proofs require bridging between **set-based** consistency (`SetMaximalConsistent`) and **list-based** derivation infrastructure
- The key proof pattern uses the deduction theorem and derives contradictions from assuming neither formula nor negation is in the MCS
- Existing infrastructure in `MaximalConsistent.lean` provides all necessary lemmas: `derives_neg_from_inconsistent_extension`, `derives_bot_from_phi_neg_phi`

## Context & Scope

### Current State

The file `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` contains:
- Complete definitions for `CanonicalWorldState`, `CanonicalFrame`, `CanonicalModel`
- Two incomplete theorems with `sorry`:
  - `mcs_contains_or_neg` at line 174
  - `mcs_modus_ponens` at line 197

### Why These Matter

These are **critical blocking dependencies** for:
- Task 558 (semantic satisfiability bridge)
- Task 559 (strong completeness helpers)
- The Truth Lemma (TruthLemma.lean)
- The overall completeness proof

## Findings

### Theorem 1: mcs_contains_or_neg

**Goal State** (at line 192):
```lean
case neg.h
S : Set Formula
h_mcs : SetMaximalConsistent S
φ : Formula
hφ : φ ∉ S
hneg h_neg_not : φ.neg ∉ S
h_incons_phi : ¬SetConsistent (insert φ S)
h_incons_neg : ¬SetConsistent (insert φ.neg S)
⊢ False
```

**Proof Strategy**:

1. Since `insert φ S` is inconsistent, there exists a finite list `L` from `insert φ S` such that `L` derives `⊥`
2. By the deduction theorem infrastructure, if `φ :: rest` derives `⊥`, then `rest` derives `¬φ`
3. Apply `derives_neg_from_inconsistent_extension` to get a derivation of `¬φ` from some finite subset of S
4. Similarly, apply to `insert φ.neg S` to get a derivation of `¬¬φ` from S
5. Using `double_negation` (DNE), derive `φ` from `¬¬φ`
6. Now we have both `φ` and `¬φ` derivable from S, contradicting consistency

**Key Lemmas from MaximalConsistent.lean**:
- `derives_neg_from_inconsistent_extension : ¬Consistent (φ :: Γ) → Nonempty (Γ ⊢ φ.neg)`
- `derives_bot_from_phi_neg_phi : (Γ ⊢ φ) → (Γ ⊢ φ.neg) → Γ ⊢ Formula.bot`

**Challenge**: Bridging set-based to list-based consistency
- `SetConsistent S` means all finite subsets are consistent
- We need to extract the specific finite subset and reason about it
- Use `¬SetConsistent (insert φ S)` to get a witness list `L`

### Theorem 2: mcs_modus_ponens

**Goal State** (at line 209):
```lean
case inr
S : Set Formula
h_mcs : SetMaximalConsistent S
φ ψ : Formula
h_imp : φ.imp ψ ∈ S
h_ant : φ ∈ S
hψ : ψ ∉ S
h_neg : ψ.neg ∈ S
⊢ False
```

**Proof Strategy**:

1. We have `φ ∈ S`, `φ → ψ ∈ S`, and `¬ψ ∈ S` (from `mcs_contains_or_neg` applied to `ψ`)
2. Consider the finite list `L = [φ, φ → ψ, ¬ψ]` - all elements are in S
3. From `φ` and `φ → ψ`, derive `ψ` via modus ponens
4. From `ψ` and `¬ψ`, derive `⊥` via `derives_bot_from_phi_neg_phi`
5. This contradicts `SetConsistent S` (which says `Consistent L` for all `L ⊆ S`)

**Key Lemmas**:
- Standard modus ponens: `(Γ ⊢ φ) → (Γ ⊢ φ.imp ψ) → Γ ⊢ ψ` via `DerivationTree.modus_ponens`
- `derives_bot_from_phi_neg_phi` for the contradiction
- List membership reasoning for showing `L ⊆ S`

### Relevant Mathlib Patterns

Found in `Mathlib.ModelTheory.Satisfiability`:
```lean
FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem :
  T.IsMaximal → ∀ (φ : L.Sentence), φ ∈ T ∨ φ.not ∈ T
```

This confirms our proof pattern is standard: maximal consistent theories always contain a formula or its negation.

### Existing Infrastructure Analysis

**From MaximalConsistent.lean** (already proven):

| Lemma | Type | Status |
|-------|------|--------|
| `SetConsistent` | Definition | Complete |
| `SetMaximalConsistent` | Definition | Complete |
| `Consistent` | Definition | Complete |
| `set_lindenbaum` | Theorem | Complete |
| `derives_neg_from_inconsistent_extension` | Lemma | Complete |
| `derives_bot_from_phi_neg_phi` | Definition | Complete |
| `maximal_consistent_closed` | Theorem | Complete (list-based) |
| `maximal_negation_complete` | Theorem | Complete (list-based) |

**From Propositional.lean**:

| Lemma | Type | Status |
|-------|------|--------|
| `lem` | Definition | Complete (`⊢ A ∨ ¬A`) |
| `ecq` | Definition | Complete (`[A, ¬A] ⊢ B`) |
| `double_negation` | Definition | Complete (`⊢ ¬¬A → A`) |
| `dni` | Definition | Complete (`⊢ A → ¬¬A`) |
| `efq_neg` | Definition | Complete (`⊢ ¬A → (A → B)`) |

## Decisions

1. **Proof approach for mcs_contains_or_neg**: Use constructive extraction from `¬SetConsistent` to get witness list, then apply deduction theorem lemmas
2. **Proof approach for mcs_modus_ponens**: Direct construction showing `[φ, φ.imp ψ, ψ.neg]` is inconsistent
3. **Bridge pattern**: The proofs need helper lemmas to extract witnesses from `¬SetConsistent` - consider whether to add intermediate lemmas or inline the logic

## Recommendations

### Implementation Plan

**Phase 1: Add Helper Lemma** (recommended)
Add a lemma to extract the witness from `¬SetConsistent`:
```lean
lemma not_set_consistent_witness {S : Set Formula} (h : ¬SetConsistent S) :
    ∃ L : List Formula, (∀ φ ∈ L, φ ∈ S) ∧ ¬Consistent L
```

**Phase 2: Prove mcs_contains_or_neg**
1. Unfold `¬SetConsistent (insert φ S)` to get witness list L1
2. If φ ∈ L1, use deduction theorem to get derivation of ¬φ from L1 \ {φ}
3. Similarly for ¬SetConsistent (insert φ.neg S) to get derivation of ¬¬φ
4. Apply DNE to get φ, combine with ¬φ for contradiction

**Phase 3: Prove mcs_modus_ponens**
1. Construct explicit list `[φ, φ.imp ψ, ψ.neg]`
2. Build derivation: assumption → MP → contradiction
3. This violates SetConsistent since all elements are in S

### Priority

- **High**: These proofs should be tackled first as they block significant downstream work
- **Estimated Effort**: 2-3 hours for both proofs

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Witness extraction complexity | Medium | Add explicit helper lemma with classical logic |
| Derivation tree construction | Medium | Use existing `DerivationTree` constructors systematically |
| Missing propositional lemmas | Low | All needed lemmas exist in Propositional.lean |

## Appendix

### Search Queries Used

1. `lean_local_search "SetConsistent"` - Found definitions in 3 files
2. `lean_local_search "derives_neg_from_inconsistent"` - Found key lemma
3. `lean_leansearch "maximal consistent set contains formula or negation"` - Found Mathlib pattern
4. `lean_local_search "ecq"`, `lean_local_search "lem"` - Found propositional infrastructure

### File Dependencies

```
CanonicalModel.lean
├── imports Bimodal.ProofSystem
├── imports Bimodal.Semantics
├── imports Bimodal.Metalogic_v2.Core.MaximalConsistent
│   ├── imports Bimodal.ProofSystem
│   ├── imports Bimodal.Metalogic_v2.Core.DeductionTheorem
│   ├── imports Bimodal.Theorems.Propositional
│   └── imports Mathlib.Order.Zorn
└── imports Mathlib.Data.Set.Basic
```

## Next Steps

Run `/plan 557` to create implementation plan with detailed proof construction steps.
