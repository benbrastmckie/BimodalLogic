# Implementation Plan: Task #559

**Task**: Strong Completeness Helpers
**Version**: 002
**Created**: 2026-01-17
**Language**: lean
**Session ID**: sess_1768691496_55cc1e

## Overview

Complete four sorry placeholders across two files in Metalogic_v2:
1. `entails_imp_chain` and `imp_chain_to_context` in StrongCompleteness.lean
2. `completeness_corollary` (lines 151 and 159) in RepresentationTheorem.lean

**Revision Notes (v002)**:
- The results in `Bimodal/Metalogic/` serve as **inspiration only** - they should NOT be imported or distract from the Metalogic_v2 reorganization
- The **representation theorem** must be the foundation from which completeness and other results are derived
- The `Metalogic/` directory will be deleted once `Metalogic_v2/` is complete
- Self-contained implementation within Metalogic_v2 is mandatory

## Architectural Principle

The Metalogic_v2 structure follows this dependency chain:

```
RepresentationTheorem (Foundation)
         ↓
    TruthLemma + CanonicalModel
         ↓
   WeakCompleteness
         ↓
   StrongCompleteness
```

All proofs must derive from the representation theorem. Do NOT:
- Import from Bimodal/Metalogic/ (legacy, will be deleted)
- Create circular dependencies
- Rely on external completeness results

## Phases

### Phase 1: DNE-based completeness_corollary (Line 151)

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Complete the proof at line 151 using double negation elimination
2. Ensure the proof derives from representation theorem machinery

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` - Line 151

**Steps**:
1. Read current goal state at line 151 using `lean_goal`
2. Apply `double_negation` lemma from Propositional.lean to get `⊢ φ.neg.neg.imp φ`
3. Use modus ponens with `d_neg_neg : ⊢ φ.neg.neg` to derive `⊢ φ`
4. Wrap in ContextDerivable and apply to `h_not_derivable` for False

**Tactic sequence**:
```lean
have d_dne : ⊢ φ.neg.neg.imp φ := double_negation φ
have d_phi : ⊢ φ := DerivationTree.modus_ponens [] _ _ d_dne d_neg_neg
exact h_not_derivable ⟨d_phi⟩
```

**Verification**:
- Run `lean_diagnostic_messages` on RepresentationTheorem.lean
- Verify no errors at or after line 151

---

### Phase 2: Simplify completeness_corollary (Line 159)

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Remove or simplify the redundant canonical model proof branch at line 159
2. The DNE proof at line 151 should suffice - canonical model approach is unnecessary complexity

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` - Line 159 region

**Steps**:
1. Examine proof structure around lines 151-160
2. If the DNE proof at line 151 completes the theorem, remove the canonical model branch entirely
3. If both branches are structurally required (e.g., by-cases), determine minimal fix:
   - Prefer absurdity/contradiction from existing hypotheses
   - Do NOT import results from Metalogic/
4. Clean up any dead code from simplification

**Verification**:
- Run `lean_diagnostic_messages` on RepresentationTheorem.lean
- Verify no errors remain in `completeness_corollary`

---

### Phase 3: Helper lemma for imp_chain_to_context

**Estimated effort**: 2-3 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Create helper lemma for extracting φ from implication chains (self-contained in Metalogic_v2)
2. Complete `imp_chain_to_context` proof using the helper
3. Do NOT look at or import from Metalogic/ - use representation theorem as foundation

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/StrongCompleteness.lean` - Lines 100-120

**Steps**:
1. Define helper lemma signature within Metalogic_v2:
   ```lean
   lemma context_derives_from_impChain (Γ Δ : Context) (φ : Formula) :
       Δ ⊢ impChain Γ φ → (Γ ++ Δ) ⊢ φ
   ```
2. Prove by induction on Γ:
   - Base case (Γ = []): `impChain [] φ = φ`, so `Δ ⊢ φ` directly gives `([] ++ Δ) ⊢ φ`
   - Inductive case (Γ = ψ :: Γ'):
     - Have `Δ ⊢ ψ.imp (impChain Γ' φ)`
     - Get `(ψ :: Γ') ++ Δ ⊢ ψ` by assumption
     - Get `(ψ :: Γ') ++ Δ ⊢ impChain Γ' φ` by modus ponens with weakening
     - Apply IH to get `(Γ' ++ ((ψ :: Γ') ++ Δ)) ⊢ φ`
     - Use context reordering/weakening
3. Apply helper in `imp_chain_to_context`:
   ```lean
   exact ⟨context_derives_from_impChain Γ' [ψ] φ d_chain, ...⟩
   ```

**Note**: Inspiration from Metalogic/ patterns is acceptable, but all code must be written fresh in Metalogic_v2 without imports.

**Verification**:
- Run `lean_goal` at each step to track progress
- Run `lean_diagnostic_messages` to verify no errors

---

### Phase 4: Restructure entails_imp_chain

**Estimated effort**: 3-4 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Fix the universe quantifier mismatch in `entails_imp_chain`
2. Maintain proof correctness for `strong_completeness` which depends on this
3. Ensure the proof aligns with representation theorem as foundation

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/StrongCompleteness.lean` - Lines 65-90

**Steps**:
1. Understand current proof structure using `lean_goal` at line 82
2. The issue: proof introduces new model variables (D', F', M', τ', t') but needs to work with original model
3. Restructure approach:
   - The goal is `⊨ impChain (ψ :: Γ') φ`, i.e., for ALL models, `impChain (ψ :: Γ') φ` holds
   - This expands to: for all models, `ψ → impChain Γ' φ` holds
   - So for any model and time where ψ holds, we need impChain Γ' φ to hold
4. Key insight: After `intro` for the new model, we can show `Γ' ⊨ φ` by:
   - Taking any model where all of Γ' holds (the new model)
   - Adding that ψ holds at some reference (we need to construct this)
   - Using `h_entails : ψ :: Γ' ⊨ φ`
5. The proof should work within Metalogic_v2's semantic framework only

**Architectural alignment**:
- This lemma connects semantic consequence to syntactic derivability
- It supports strong_completeness which ultimately derives from the representation theorem
- Ensure the semantic definitions used are those from Metalogic_v2, not Metalogic/

**Verification**:
- Run `lake build` to verify `strong_completeness` still compiles
- Check no dependent theorems break
- Ensure no imports from `Bimodal.Metalogic` namespace

---

## Dependencies

- Phase 1 and Phase 2: Independent of each other (both in RepresentationTheorem)
- Phase 3: Independent of Phases 1-2
- Phase 4: Independent of Phases 1-3
- All phases can be done in any order, but Phase 1 is recommended first (easiest, establishes pattern)

## Architectural Constraints

1. **No Metalogic/ imports**: Do NOT import anything from `Theories/Bimodal/Metalogic/`
2. **Inspiration only**: If examining Metalogic/ code for patterns, reimplement fresh in Metalogic_v2
3. **Representation theorem foundation**: All completeness results must trace back to the representation theorem
4. **Self-contained**: Metalogic_v2 must be fully self-contained and independent

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| entails_imp_chain restructure breaks strong_completeness | High | Verify with `lake build` after changes; may need to adjust strong_completeness proof |
| Helper lemma for imp_chain_to_context more complex than expected | Medium | Use `lean_multi_attempt` to test approaches; write fresh code, don't copy |
| Context reordering lemmas missing in Metalogic_v2 | Medium | Add them fresh if needed; do NOT import from Metalogic/ |
| Line 159 has hidden dependencies | Low | Read full proof structure before removing |
| Accidental Metalogic/ import | Medium | Check imports after each phase; grep for `Bimodal.Metalogic` |

## Success Criteria

- [ ] No sorry in `entails_imp_chain` (StrongCompleteness.lean)
- [ ] No sorry in `imp_chain_to_context` (StrongCompleteness.lean)
- [ ] No sorry in `completeness_corollary` line 151 (RepresentationTheorem.lean)
- [ ] Line 159 either proven or removed (RepresentationTheorem.lean)
- [ ] `lake build` succeeds with no errors in Metalogic_v2
- [ ] `strong_completeness` theorem still compiles and is proven
- [ ] **No imports from `Theories/Bimodal/Metalogic/`** (critical)
- [ ] All completeness results derive from representation theorem

## Estimated Total Effort

6-8 hours across all phases
