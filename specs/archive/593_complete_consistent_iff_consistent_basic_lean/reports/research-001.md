# Research Report: Complete consistent_iff_consistent' in Basic.lean

- **Task**: 593 - Complete consistent_iff_consistent' in Basic.lean
- **Started**: 2026-01-18T23:50:34Z
- **Completed**: 2026-01-18T23:57:00Z
- **Effort**: 1-2 hours
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - Theories/Bimodal/Metalogic_v2/Core/Basic.lean (lines 54-56)
  - Theories/Bimodal/ProofSystem/Axioms.lean
  - Theories/Bimodal/ProofSystem/Derivation.lean
  - Theories/Bimodal/Metalogic/Core/Basic.lean (old version)
- **Artifacts**:
  - specs/593_complete_consistent_iff_consistent_basic_lean/reports/research-001.md
- **Standards**: report-format.md, subagent-return.md

## Executive Summary
- The lemma `consistent_iff_consistent'` proves equivalence between two consistency definitions: `Consistent Γ` (exists underivable formula) and `Consistent' Γ` (does not derive ⊥).
- The TM proof system has the Ex Falso Quodlibet (EFQ) axiom: `⊥ → φ` for any formula φ (Axiom.ex_falso).
- The forward direction (Consistent → Consistent') follows directly from Consistent's definition.
- The backward direction (Consistent' → Consistent) uses EFQ: if Γ ⊬ ⊥, then ⊥ is an underivable formula, satisfying Consistent.
- The proof is straightforward and does not require any additional lemmas beyond the axiom system and basic logic.

## Context & Scope

This task completes the sorry at line 56 in `Theories/Bimodal/Metalogic_v2/Core/Basic.lean`. The lemma establishes that two formulations of consistency are equivalent:

1. **Consistent Γ**: There exists some formula φ such that Γ does not derive φ
2. **Consistent' Γ**: Γ does not derive ⊥ (falsum/bottom)

The comment at line 56 notes: "Proof depends on having ex-falso axiom in TM system." Research confirms this axiom exists.

## Findings

### Two Consistency Definitions

**Definition 1 (Consistent)** - Line 38-39:
```lean
def Consistent (Γ : Context) : Prop :=
  ∃ φ : Formula, ¬Nonempty (DerivationTree Γ φ)
```
"There exists a formula that cannot be derived from Γ"

**Definition 2 (Consistent')** - Line 46-47:
```lean
def Consistent' (Γ : Context) : Prop :=
  ¬Nonempty (DerivationTree Γ .bot)
```
"⊥ cannot be derived from Γ"

### Ex Falso Quodlibet Axiom Available

From `Theories/Bimodal/ProofSystem/Axioms.lean` (lines 151):
```lean
| ex_falso (φ : Formula) : Axiom (Formula.bot.imp φ)
```

This axiom states `⊥ → φ` for any formula φ. The comprehensive documentation (lines 132-150) confirms:
- "From absurdity (⊥), anything can be derived."
- "This axiom directly characterizes what `bot` means."
- Accepted in both classical and intuitionistic logic.
- Semantically: `⊥` is false at all models, so `⊥ → φ` is vacuously true.

### Proof Strategy

**Forward Direction (Consistent Γ → Consistent' Γ)**:
- Assume `Consistent Γ`: there exists some underivable φ
- We need to show `¬Nonempty (DerivationTree Γ .bot)`
- If Γ could derive ⊥, then by EFQ axiom (`⊥ → φ`), Γ could derive any φ via modus ponens
- This contradicts the existence of an underivable φ
- Therefore Γ cannot derive ⊥

**Backward Direction (Consistent' Γ → Consistent Γ)**:
- Assume `Consistent' Γ`: Γ does not derive ⊥
- We need to show `∃ φ, ¬Nonempty (DerivationTree Γ φ)`
- Take φ = ⊥ (the formula bot itself)
- By assumption, `¬Nonempty (DerivationTree Γ .bot)`
- Therefore the existential is satisfied with φ = ⊥

### Related Definitions and Inference Rules

**DerivationTree** (from Derivation.lean):
- Inductive type with 7 inference rules
- Axiom rule allows using any axiom schema instance
- Modus ponens: from `Γ ⊢ φ → ψ` and `Γ ⊢ φ`, derive `Γ ⊢ ψ`

**Context Type**:
- Defined as `List Formula` in Bimodal.Syntax.Context
- Represents assumptions/premises

### Comparison with Old Metalogic

The old `Theories/Bimodal/Metalogic/Core/Basic.lean` has the identical sorry (line 36), confirming this is a longstanding gap that needs to be filled across both versions.

## Decisions

- Use direct proof for both directions (not proof by contradiction)
- For forward direction: use proof by contradiction (assume Γ ⊢ ⊥ and derive contradiction)
- For backward direction: use constructive existence proof (exhibit φ = ⊥)
- No auxiliary lemmas needed; proof relies only on axiom system and basic logic

## Recommendations

1. **Implementation approach**: Use `Iff.intro` to split into two cases
2. **Forward direction tactics**:
   - Introduce hypothesis `h1 : Consistent Γ`
   - Unfold definitions of Consistent and Consistent'
   - Assume `h2 : Nonempty (DerivationTree Γ .bot)` for contradiction
   - Use EFQ axiom to show Γ can derive any formula
   - Apply modus ponens to contradict h1
3. **Backward direction tactics**:
   - Introduce hypothesis `h : Consistent' Γ`
   - Unfold definition of Consistent
   - Use `⟨.bot, h⟩` to provide existential witness
4. **Verification**: After implementation, run `lean_diagnostic_messages` to confirm no errors
5. **Testing**: Ensure proof compiles with `lake build Theories.Bimodal.Metalogic_v2.Core.Basic`

## Risks & Mitigations

**Risk**: Incorrect understanding of Nonempty vs inhabitance
- **Mitigation**: `Nonempty (DerivationTree Γ φ)` means there exists a derivation tree, which is the correct interpretation

**Risk**: Missing helper lemmas for modus ponens application
- **Mitigation**: DerivationTree.modus_ponens is a constructor, can be used directly. If needed, helper lemmas can be proven inline.

**Risk**: EFQ axiom instantiation complexity
- **Mitigation**: `Axiom.ex_falso φ` is simple constructor taking any formula φ

**Risk**: Interaction with weakening rule
- **Mitigation**: Not needed for this proof; EFQ and modus ponens are sufficient

## Appendix

### File Locations
- Target file: `Theories/Bimodal/Metalogic_v2/Core/Basic.lean` (line 54-56)
- Axiom definition: `Theories/Bimodal/ProofSystem/Axioms.lean` (line 151)
- Derivation rules: `Theories/Bimodal/ProofSystem/Derivation.lean`
- Old version: `Theories/Bimodal/Metalogic/Core/Basic.lean` (line 34-36)

### Key Type Signatures
```lean
-- Axiom constructor
Axiom.ex_falso : (φ : Formula) → Axiom (Formula.bot.imp φ)

-- Derivation tree constructors
DerivationTree.axiom : (Γ : Context) → (φ : Formula) → Axiom φ → DerivationTree Γ φ
DerivationTree.modus_ponens : (Γ : Context) → (φ ψ : Formula) →
  DerivationTree Γ (φ.imp ψ) → DerivationTree Γ φ → DerivationTree Γ ψ

-- Consistency definitions
Consistent : Context → Prop
Consistent' : Context → Prop
```

### Proof Outline
```lean
lemma consistent_iff_consistent' {Γ : Context} :
    Consistent Γ ↔ Consistent' Γ := by
  constructor
  -- Forward: Consistent Γ → Consistent' Γ
  · intro ⟨φ, hφ⟩  -- φ is underivable
    intro ⟨d_bot⟩  -- assume Γ ⊢ ⊥ for contradiction
    -- From Γ ⊢ ⊥, derive Γ ⊢ ⊥ → φ (EFQ axiom)
    -- Then Γ ⊢ φ (modus ponens)
    -- Contradiction with hφ

  -- Backward: Consistent' Γ → Consistent Γ
  · intro h  -- Γ ⊬ ⊥
    exact ⟨.bot, h⟩  -- ⊥ is the underivable formula
```

### Related Tasks
- Task 588: Completed (related to Metalogic_v2)
- Task 561: Cleanup and documentation task that mentions proving consistent_iff_consistent'
- Both tasks reference the same sorry that needs to be filled

### Search Results Summary
- `lean_local_search "Consistent"`: Found 13 definitions across Metalogic and Metalogic_v2
- `lean_local_search "ex_falso"`: Found 2 validity theorems (ex_falso_valid in Soundness.lean)
- `lean_leanfinder`: No directly applicable Mathlib lemmas (this is domain-specific)
