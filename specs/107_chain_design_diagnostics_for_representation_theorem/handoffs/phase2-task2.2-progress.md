# Handoff: Task OC_107 Phase 2 Task 2.2 Progress

## Context
- **Task**: OC_107 (chain design diagnostics for representation theorem)
- **Phase**: 2 (D0 Seed Consistency - Inconsistent Case)
- **Current Task**: 2.2 (`burgess_D0_finite_subset_consistent_incons`)
- **File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- **Lines**: 1818-1981 (theorem implementation)

## What Was Done

1. **Initial implementation**: Wrote a complete implementation of `burgess_D0_finite_subset_consistent_incons` following the consistent case pattern
2. **Key insight**: When `β.neg ∈ B`, we can prove `F(β.neg) ∈ A` using `right_mono_until_mcs` (since `⊢ γ_hat → ⊤`)
3. **Event construction**: Used BX5 + BX13 + BX10 chain (without BX14 since β.neg is already in B)

## Current Issues

### Issue 1: Proving `⊢ γ_hat → ⊤` (h_γ_to_top)
The proof attempt:
```lean
have h_top : DerivationTree [] Formula.top := by
  rw [Formula.top_eq]; exact (identity Formula.bot)
have h_weak : DerivationTree [] (Formula.top.imp (γ_hat.imp Formula.top)) :=
  DerivationTree.axiom [] _ (Axiom.prop_s Formula.top γ_hat)
have h_γ_to_top : DerivationTree [] (γ_hat.imp Formula.top) :=
  DerivationTree.modius_ponens [] _ _ h_weak h_top
```
Error: `h_top : ⊢ sorry` (proof not complete)

**Root cause**: `Formula.top_eq` might not be the right theorem, or `identity Formula.bot` doesn't prove `⊢ ⊤` correctly.

**Possible fix**: Need to find the correct theorem to prove `⊢ φ → ⊤` (tautology). This should be provable using:
- `⊢ ⊤` (true is true) - identity ⊥, since `⊤ = ¬⊥ = ⊥ → ⊥`
- `⊢ ⊤ → (φ → ⊤)` (weakening axiom `prop_s`)
- `⊢ φ → ⊤` (modus ponens)

### Issue 2: Helper function calls with wrong arguments
Error messages show:
```
collect_guards_mem_of_B h_B_dcs β L hL (β'.snce α') hφ
error: hφ has type φ ∈ L but expected β'.snce α' ∈ L
```

The helper functions expect specific types:
- `collect_guards_mem_of_B`: Takes `φ ∈ L` where `φ ∈ B`
- `collect_guards_mem_of_untl`: Takes `φ = untl(β', γ') ∈ L` where `φ ∉ B`
- `collect_guards_mem_of_snce`: Takes `φ = snce(β', α') ∈ L` where `φ ∉ B` and not an Until formula

**Fix needed**: Use `Classical.choose` to extract `β', γ', α'` from existential quantifiers, then pass correct proofs.

### Issue 3: `F(b) ∈ A` proof
From `untl(b, γ_hat) ∈ A` (burgessR3), BX5 gives `untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A`.
BX10 gives `F(γ_hat) ∈ A`, not `F(b) ∈ A`.

**Attempted fix**: Use right-mono with `⊢ γ_hat → ⊤` to get `F(b) ∈ A`.

But this depends on Issue 1 (proving `⊢ γ_hat → ⊤`).

## Burgess Paper Reference
- **Section 2.6** (p. 370-371): Lemma 2.6 - D0 seed consistency
- **Inconsistent case**: When `β.neg ∈ B`, the event simplifies
- **Key difference**: No BX14 (separation) needed since `β.neg` is already in B

## Next Steps Needed

1. **Fix `⊢ γ_hat → ⊤` proof**: Search for correct theorem in `Bimodal.Theorems.Propositional` or prove it directly
2. **Fix helper function calls**: Use `Classical.choose` correctly to extract witnesses, pass correct proof terms
3. **Verify event construction**: Ensure `F(event) ∈ A` and `event → L` for all finite L ⊆ D₀
4. **Run `lake build`**: Verify no errors remain

## Key Theorems Needed
- `⊢ φ → ⊤` (true intro) - possibly `Bimodal.Theorems.Propositional.true_intro` or identity-based proof
- `collect_guards_mem_of_B` - correct usage with `φ ∈ B` proof
- `collect_guards_mem_of_untl` - correct usage with Until formula proof
- `collect_guards_mem_of_snce` - correct usage with Since formula proof

## Current Build Errors
```
error: Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean:
  h_γ_to_top : ⊢ γ_hat.imp sorry
error: application type mismatch in collect_guards_mem_of_B, collect_guards_mem_of_untl, collect_guards_mem_of_snce
warning: declaration uses 'sorry' (lines 2399, 2410, 2423, 2435)
error: Lean exited with code 1
```

## Files Modified
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (lines 1818-1981)

## Metadata Updated
- Status: `in_progress`
- Partial progress: Implemented `burgess_D0_finite_subset_consistent_incons` but blocked on proof details
- Handoff created for next agent to continue
