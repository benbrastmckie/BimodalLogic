# Phase 2 Handoff: splitting_seed_consistent Since Condition Blocker

**Task**: OC_107 - Burgess Chronicle Construction  
**Phase**: 2 (Rewrite lemma_2_6_splitting with Burgess D0 Seed)  
**Status**: IN PROGRESS - Blocked on Since condition proof  
**Created**: 2026-05-01  
**Agent Sessions**: ses_219d34e1fffeiisdtbyvyL7fTJ, ses_219bda690ffe77EXq8rKXfzHTD, ses_219aa2e96ffeV9fBZCE14A2eLn

---

## Current State

The `splitting_seed_consistent` theorem in `PointInsertion.lean` (line ~1063) has a detailed proof structure in place, but **4 sorry sites remain**:

1. **Line ~1126**: Since condition for `dc_delta_B_burgessR3` - **PRIMARY BLOCKER**
2. **Line ~1178**: Propositional tautology (event implies β.neg)
3. **Line ~1199**: Seed consistency from F-event  
4. **Line ~1215**: Inconsistent case (β.neg ∈ B)

The file has been reorganized with the theorem moved after helper lemmas, and the BX5+BX14+BX10 proof strategy is fully documented.

---

## The Core Blocker

### Problem Statement

In the proof of `splitting_seed_consistent`, we need to establish the Since condition for `dc_delta_B_burgessR3`:

```lean
∀ (beta : Formula), beta ∈ B → ∀ (alpha : Formula), alpha ∈ A →
    Formula.snce (Formula.and beta β) alpha ∈ C
```

We have available:
- `h_r3.2`: `∀ beta ∈ B, ∀ alpha ∈ A, snce(beta, alpha) ∈ C` (from `burgessRSince`)
- `h_mcs_C`: C is maximal consistent
- `snce_left_mono_thm`: Monotonicity for Since (goes wrong direction)

### Why Standard Monotonicity Fails

The available lemma `snce_left_mono_thm` requires:
```lean
DerivationTree [] (β₁.imp β₂) → snce(β₁, γ) ∈ A → snce(β₂, γ) ∈ A
```

To get `snce(beta ∧ β, alpha)` from `snce(beta, alpha)`, we would need:
```lean
⊢ beta → (beta ∧ β)
```

But this implication is **false** (beta doesn't imply beta ∧ β in general).

We only have the reverse: `⊢ (beta ∧ β) → beta` (from `and_left` or `rce_imp`).

### Attempted Approaches

1. **Direct Monotonicity**: Using `snce_left_mono_thm` - **FAILED** (wrong direction)
2. **H-Necessitated Monotonicity**: Using `snce_left_mono_H` - **FAILED** (still requires same implication)
3. **Proof by Contradiction**: Using maximality of C - **FAILED** (no contradiction available)
4. **g_content Approach**: Using `h_gc : g_content A ⊆ C` - **INCOMPLETE** (connection unclear)

---

## Alternative Strategies to Explore

### Strategy 1: Avoid the Since Condition Entirely

The `dc_delta_B_burgessR3` lemma requires:
```lean
burgessR3 A (deductiveClosure ({β} ∪ B)) C
```

Which expands to:
1. Until condition for DC({β} ∪ B)
2. Since condition for DC({β} ∪ B)

But `h_not_r3` (from `BurgessR3Maximal_extension_fails`) gives us:
```lean
¬burgessR3 A (deductiveClosure ({β} ∪ B)) C
```

Which means: **Until condition fails OR Since condition fails**

We extract the Until failure to get our witness. The Since condition is only needed to *prove* the extension satisfies `burgessR3` (which we know it doesn't).

**Key Insight**: We might be able to extract the witness directly from `h_not_r3` without proving the Since condition, by analyzing the negation structure more carefully.

### Strategy 2: New Helper Lemma

Create a specialized lemma for this specific temporal property:

```lean
lemma snce_strengthen_with_conjunction {A C : Set Formula}
    (h_mcs_C : SetMaximalConsistent C)
    (h_gc : g_content A ⊆ C)
    (beta : Formula) (h_beta : beta ∈ B)
    (alpha : Formula) (h_alpha : alpha ∈ A)
    (h_snce : snce(beta, alpha) ∈ C)
    (β : Formula) :
    snce(beta ∧ β, alpha) ∈ C
```

**Challenge**: This may require additional BX axioms or properties not currently in the system.

### Strategy 3: Use Different burgessR3 Decomposition

Instead of `dc_delta_B_burgessR3`, use a different characterization of the `burgessR3` negation that exposes the failing condition directly.

The negation of:
```lean
burgessR3 A B C = burgessRSet A B C ∧ burgessRSince C B A
```

Is:
```lean
¬burgessRSet A B C ∨ ¬burgessRSince C B A
```

Currently we're trying to prove both conditions hold (to derive a contradiction), but we only need to analyze what the failure gives us.

### Strategy 4: BX Axiom Investigation

The BX axioms may have a gap. Specifically:
- We have `left_mono_since_H` (BX2H variant)
- We have `left_mono_since` (pointwise)
- But we may need a different strengthening principle

This could require:
1. Reviewing Burgess 1982 for the exact axiom requirements
2. Checking if BX system is complete for this property
3. Potentially adding an axiom if necessary

---

## Related Code Locations

- **Primary file**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- **Line ~1063**: `splitting_seed_consistent` theorem
- **Line ~1126**: Since condition sorry (primary blocker)
- **Helper lemmas**: `snce_left_mono_thm` (RRelation.lean:1037), `snce_left_mono_H` (RRelation.lean:1071)
- **dc_delta_B_burgessR3**: Defined in RRelation.lean

---

## Remaining Work in Phase 2

Once the Since condition is resolved:

1. **Complete splitting_seed_consistent**:
   - Close Since condition sorry
   - Close propositional tautology sorry (event implies β.neg)
   - Close seed consistency sorry (F-event to consistency)
   - Close inconsistent case sorry (β.neg ∈ B)

2. **Verify lemma_2_6_splitting**:
   - Should work automatically once splitting_seed_consistent is proven
   - Currently has correct structure, depends on seed consistency

3. **Build verification**:
   - `lake build Bimodal.Metalogic.BXCanonical.Chronicle.PointInsertion` succeeds
   - PointInsertion.lean sorry count: TBD (lemma_2_7 work remains)

---

## Recommendations

### Immediate Next Steps

1. **Try Strategy 1** (avoid Since condition): Analyze `h_not_r3` more carefully to see if we can extract the witness without proving both conditions hold.

2. **If Strategy 1 fails**: Spawn a focused research task to investigate:
   - Whether the Since condition is actually needed
   - If there's a different proof of `splitting_seed_consistent` that avoids this
   - Whether additional BX axioms are required

### Success Criteria

Phase 2 is complete when:
- [ ] `splitting_seed_consistent` is sorry-free
- [ ] `splitting_seed_consistent` compiles without errors
- [ ] `lemma_2_6_splitting` is sorry-free
- [ ] `lake build` succeeds
- [ ] No regressions in other proofs

---

## Session History

**Session ses_219d34e1fffeiisdtbyvyL7fTJ**:
- Reorganized file structure
- Moved theorems after helper lemmas
- Added comprehensive proof documentation

**Session ses_219bda690ffe77EXq8rKXfzHTD**:
- Implemented proof structure with 6-step strategy
- Identified Since condition as blocker
- Added case analysis framework

**Session ses_219aa2e96ffeV9fBZCE14A2eLn**:
- Attempted alternative approaches
- Documented monotonicity failure
- Added detailed comments explaining the blocker

---

## Artifacts

- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- Metadata: `.return-meta.json` (partial status)
- This handoff: `handoffs/52_phase2-since-condition-blocker.md`
