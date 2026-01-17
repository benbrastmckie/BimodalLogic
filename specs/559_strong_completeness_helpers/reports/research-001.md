# Research Report: Task #559

**Task**: Strong Completeness Helpers
**Started**: 2026-01-17T22:42:34Z
**Completed**: 2026-01-17T22:55:00Z
**Effort**: 2 hours
**Priority**: Medium
**Dependencies**: 557 (completed)
**Sources/Inputs**: Lean source files, lean-lsp MCP tools
**Artifacts**: specs/559_strong_completeness_helpers/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Four sorries identified across two files: `entails_imp_chain` and `imp_chain_to_context` in StrongCompleteness.lean, and `completeness_corollary` (lines 151, 159) in RepresentationTheorem.lean
- All required helper lemmas (double_negation, deduction_theorem, derives_neg_from_inconsistent_extension, derives_bot_from_phi_neg_phi, mcs_contains_or_neg) already exist and are proven
- The proofs require careful restructuring of quantifiers and inductive arguments, particularly the semantic consequence proof which has a universe quantification mismatch

## Context & Scope

This research examines the sorry placeholders in Task 559's target files:

1. **StrongCompleteness.lean**: Two sorries in helper lemmas for strong completeness
2. **RepresentationTheorem.lean**: Two sorries in the completeness_corollary theorem

The goal is to understand the proof structure and identify strategies to complete these proofs.

## Findings

### 1. StrongCompleteness.lean - `entails_imp_chain` (Line 82)

**Current Goal State**:
```lean
φ ψ : Formula
Γ' : List Formula
ih : Γ' ⊨ φ → ⊨ impChain Γ' φ
h_entails : ψ :: Γ' ⊨ φ
D : Type
inst✝² : AddCommGroup D
inst✝¹ : LinearOrder D
inst✝ : IsOrderedAddMonoid D
F : TaskFrame D
M : TaskModel F
τ : WorldHistory F
t : D
h_psi : truth_at M τ t ψ
D' : Type
inst1' : AddCommGroup D'
inst2' : LinearOrder D'
inst3' : IsOrderedAddMonoid D'
F' : TaskFrame D'
M' : TaskModel F'
τ' : WorldHistory F'
t' : D'
h_all' : ∀ ψ ∈ Γ', truth_at M' τ' t' ψ
⊢ truth_at M' τ' t' φ
```

**Problem Analysis**:
The current proof approach has a fundamental issue: it tries to use the IH with a semantic consequence claim, but the worlds `(D, F, M, τ, t)` and `(D', F', M', τ', t')` are different. The IH gives `Γ' ⊨ φ → ⊨ impChain Γ' φ`, but we need to show `Γ' ⊨ φ` using only information from `h_entails : ψ :: Γ' ⊨ φ`.

**Recommended Approach**:
The proof should NOT construct `h_Γ'_entails : semantic_consequence Γ' φ` because that's not true in general (removing ψ from premises weakens the entailment). Instead:

1. **Direct semantic argument**: In the current model `(D, F, M, τ, t)` where `h_psi : truth_at M τ t ψ` holds, use `h_entails` directly to get `truth_at M τ t φ`
2. **Apply IH correctly**: The goal structure shows we're proving `⊨ impChain (ψ :: Γ') φ = ⊨ (ψ → impChain Γ' φ)`. For any model/time where `ψ` holds, we need `impChain Γ' φ` to hold.
3. **Restructure**: The induction should be on the implication chain, not on semantic consequence transfer

**Key Insight**: The current proof structure is flawed. It should use:
```lean
-- After intro h_psi, we have truth_at M τ t ψ
-- Need: truth_at M τ t (impChain Γ' φ)
-- Use h_entails: ψ :: Γ' ⊨ φ with the CURRENT model
-- Build: (∀ χ ∈ Γ', truth_at M τ t χ) → truth_at M τ t φ by instantiating h_entails
```

### 2. StrongCompleteness.lean - `imp_chain_to_context` (Line 114)

**Current Goal State**:
```lean
case cons
φ ψ : Formula
Γ' : List Formula
ih : ∀ (d : ⊢ impChain Γ' φ), ContextDerivable Γ' φ
d : ⊢ impChain (ψ :: Γ') φ
d_weak : ψ :: Γ' ⊢ ψ.imp (impChain Γ' φ)
d_assump : ψ :: Γ' ⊢ ψ
d_chain : ψ :: Γ' ⊢ impChain Γ' φ
⊢ ContextDerivable (ψ :: Γ') φ
```

**Problem Analysis**:
We have `d_chain : ψ :: Γ' ⊢ impChain Γ' φ` but need `ContextDerivable (ψ :: Γ') φ`. The proof needs to recursively extract φ from the implication chain using the remaining assumptions in Γ'.

**Recommended Approach**:
Use a nested induction or helper lemma that "pops" implications one at a time:

```lean
lemma extract_from_impChain (Γ : Context) (φ : Formula) :
    ∀ Δ : Context, Δ ⊢ impChain Γ φ → (Γ ++ Δ) ⊢ φ
```

The key insight is that if `Δ ⊢ impChain [ψ₁,...,ψₙ] φ` (i.e., `Δ ⊢ ψ₁ → ... → ψₙ → φ`), then by n applications of modus ponens with assumptions ψᵢ, we get `[ψ₁,...,ψₙ] ++ Δ ⊢ φ`.

**Available Lemmas**:
- `DerivationTree.assumption` - Get assumption from context
- `DerivationTree.modus_ponens` - Apply modus ponens
- `DerivationTree.weakening` - Weaken context

### 3. RepresentationTheorem.lean - `completeness_corollary` (Lines 151, 159)

**Current Goal States**:

**Line 151** (Double Negation Elimination):
```lean
φ : Formula
h_valid : ⊨ φ
h_not_derivable : ¬ContextDerivable [] φ
d_bot : [φ.neg] ⊢ Formula.bot
d_neg_neg : ⊢ φ.neg.neg
⊢ False
```

**Line 159** (Canonical World Contradiction):
```lean
φ : Formula
h_valid : ⊨ φ
h_not_derivable : ¬ContextDerivable [] φ
h_neg_cons : Consistent [φ.neg]
w : CanonicalWorldState
h_truth : ∀ φ_1 ∈ [φ.neg], canonicalTruthAt w φ_1
h_neg_in : φ.neg ∈ w.carrier
⊢ False
```

**Problem Analysis**:

For **Line 151**: We have `d_neg_neg : ⊢ φ.neg.neg` (derived from [¬φ] ⊢ ⊥ via deduction theorem). Need to derive `⊢ φ` using DNE, then contradict `h_not_derivable`.

For **Line 159**: We have `h_neg_in : φ.neg ∈ w.carrier` (¬φ is in the MCS) and `h_valid : ⊨ φ`. Need to show contradiction by connecting canonical model truth to validity.

**Recommended Approach for Line 151**:
```lean
-- Apply double negation elimination
have d_dne : ⊢ φ.neg.neg.imp φ := double_negation φ
have d_phi : ⊢ φ := DerivationTree.modus_ponens [] _ _ d_dne d_neg_neg
exact h_not_derivable ⟨d_phi⟩
```

**Recommended Approach for Line 159**:
The key insight is that this proof is essentially redundant with the Line 151 approach. The canonical model approach works, but we need to connect:
1. `h_valid : ⊨ φ` means φ is true in ALL models
2. If the canonical model were a proper semantic model, φ would be true there
3. But ¬φ ∈ w.carrier means canonicalTruthAt w (φ.neg)
4. By MCS properties, either φ or ¬φ is in carrier, not both
5. Since ¬φ ∈ w.carrier, φ ∉ w.carrier, contradicting validity

However, `canonicalTruthAt` is not the same as `truth_at` from Validity.lean - it's just set membership. The connection requires showing the canonical model IS a valid semantic model, which is complex.

**Better Alternative**: Complete Line 151's double negation approach, then remove the canonical model argument entirely since it's not needed.

### Available Proven Lemmas

| Lemma | Location | Signature |
|-------|----------|-----------|
| `double_negation` | Propositional.lean | `(φ : Formula) → ⊢ φ.neg.neg.imp φ` |
| `deduction_theorem` | DeductionTheorem.lean | `(φ :: Γ) ⊢ ψ → Γ ⊢ φ.imp ψ` |
| `derives_neg_from_inconsistent_extension` | MaximalConsistent.lean | `¬Consistent (φ :: Γ) → Nonempty (Γ ⊢ φ.neg)` |
| `derives_bot_from_phi_neg_phi` | MaximalConsistent.lean | `Γ ⊢ φ → Γ ⊢ φ.neg → Γ ⊢ ⊥` |
| `mcs_contains_or_neg` | CanonicalModel.lean | `SetMaximalConsistent S → φ ∈ S ∨ φ.neg ∈ S` |
| `mcs_modus_ponens` | CanonicalModel.lean | `SetMaximalConsistent S → (φ.imp ψ) ∈ S → φ ∈ S → ψ ∈ S` |
| `truthLemma_bot` | TruthLemma.lean | `¬canonicalTruthAt w Formula.bot` |

### Core.Basic.lean - `consistent_iff_consistent'` (Line 56)

This is NOT in Task 559 scope but is referenced in Task 561. However, it's worth noting:
- `Consistent Γ` = `∃ φ, ¬Nonempty (Γ ⊢ φ)`
- `Consistent' Γ` = `¬Nonempty (Γ ⊢ ⊥)`
- Equivalence requires ex-falso: from `⊢ ⊥` derive any `⊢ φ`

This is available via `efq_axiom : ⊢ Formula.bot.imp φ` in Propositional.lean.

## Decisions

1. **entails_imp_chain**: Requires proof restructuring - the inductive structure needs to use the same model throughout, not introduce new quantified models
2. **imp_chain_to_context**: Requires a helper lemma for extracting φ from implication chains via repeated modus ponens
3. **completeness_corollary (line 151)**: Can be completed immediately using `double_negation`
4. **completeness_corollary (line 159)**: Should be removed - the canonical model approach is more complex than needed; the DNE approach at line 151 suffices

## Recommendations

1. **Priority Order**:
   - First: Fix `completeness_corollary` line 151 (straightforward DNE application)
   - Second: Complete `imp_chain_to_context` (helper lemma needed)
   - Third: Fix `entails_imp_chain` (proof restructuring needed)
   - Fourth: Simplify `completeness_corollary` to avoid line 159 (remove redundant canonical model argument)

2. **Implementation Strategy**:
   - Create helper lemma `extract_from_impChain` for imp_chain_to_context
   - Rewrite entails_imp_chain induction to maintain model identity throughout
   - Simplify completeness_corollary proof structure

3. **Testing**: Run `lake build` after each proof completion to verify no regressions

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| entails_imp_chain restructure may break dependent proofs | Medium | strong_completeness uses this directly; verify after fixing |
| Helper lemma complexity | Low | Pattern is standard (repeated modus ponens) |
| Canonical model connection complexity | High | Avoid by using DNE approach instead |

## Appendix

### Search Queries Used

- `lean_local_search("double_negation")` - Found in Propositional.lean
- `lean_local_search("deduction")` - Found DeductionTheorem modules
- `lean_local_search("derives_neg")` - Found derives_neg_from_inconsistent_extension
- `lean_local_search("derives_bot")` - Found derives_bot_from_phi_neg_phi
- `lean_local_search("inconsistent")` - Found inconsistent_derives_bot
- `lean_local_search("semantic")` - Found semantic_consequence definition
- `lean_local_search("truth_at")` - Found truth_at definitions

### Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Completeness/StrongCompleteness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Core/Basic.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/Propositional.lean` (outline)

### Goal States at Sorry Locations

1. **StrongCompleteness.lean:82** - entails_imp_chain inductive case with universe quantifier mismatch
2. **StrongCompleteness.lean:114** - imp_chain_to_context needs recursive implication extraction
3. **RepresentationTheorem.lean:151** - DNE application needed
4. **RepresentationTheorem.lean:159** - Canonical model to validity connection (recommend removing)

## Next Steps

Run `/plan 559` to create implementation plan with phased approach for completing these proofs.
