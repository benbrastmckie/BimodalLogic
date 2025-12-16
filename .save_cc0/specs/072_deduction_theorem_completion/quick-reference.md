# Quick Reference: Deduction Theorem Completion

**Status**: Ready for Implementation  
**Estimated Time**: 3.5-4.5 hours  
**Difficulty**: Medium (requires Lean 4 recursion knowledge)

---

## TL;DR

**Problem**: 1 sorry in `DeductionTheorem.lean` line 331 (weakening case)  
**Solution**: Add height measure + use `termination_by`  
**Impact**: Unblocks 2 tasks, removes 5 dependent sorry

---

## Implementation Checklist

### Phase 1: Height Measure (30 min)
- [ ] Add `Derivable.height` definition after imports
- [ ] Test with basic examples
- [ ] Commit and verify build

### Phase 2: Height Properties (60 min)
- [ ] Prove `weakening_height_succ`
- [ ] Prove `subderiv_height_lt`
- [ ] Prove `mp_height_gt_left/right`
- [ ] Test all lemmas
- [ ] Commit and verify build

### Phase 3: Main Theorem (90-120 min)
- [ ] Replace current theorem with pattern matching version
- [ ] Add `termination_by h.height` clause
- [ ] Implement all 7 cases
- [ ] Add `decreasing_by` proofs
- [ ] Verify termination checker accepts proof
- [ ] Commit and verify build

### Phase 4: Testing (30 min)
- [ ] Write basic tests (identity, weakening, modus ponens)
- [ ] Write weakening case tests (A ∉ Γ', A ∈ Γ')
- [ ] Write integration tests
- [ ] Run `lake test`
- [ ] Verify 0 sorry in DeductionTheorem.lean

---

## Code Snippets

### Height Definition
```lean
def Derivable.height : {Γ : Context} → {φ : Formula} → Derivable Γ φ → ℕ
  | _, _, axiom _ => 0
  | _, _, assumption _ => 0
  | _, _, modus_ponens d1 d2 => max d1.height d2.height + 1
  | _, _, necessitation d => d.height + 1
  | _, _, temporal_necessitation d => d.height + 1
  | _, _, temporal_duality d => d.height + 1
  | _, _, weakening d _ => d.height + 1
```

### Key Lemma
```lean
theorem Derivable.subderiv_height_lt {Γ' Δ : Context} {φ : Formula} 
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    d.height < (Derivable.weakening Γ' Δ φ d h).height := by
  rw [weakening_height_succ]
  omega
```

### Termination Clause
```lean
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B := by
  match h with
  | ... => ...
termination_by h.height
decreasing_by
  all_goals simp_wf
  · exact Derivable.mp_height_gt_left h1 h2
  · exact Derivable.mp_height_gt_right h1 h2
  · exact Derivable.subderiv_height_lt h1 h2
  · exact Derivable.subderiv_height_lt h1 h2
```

---

## Critical Case: Weakening with A ∈ Γ'

**Problem**: `Γ' ⊆ A :: Γ`, `A ∈ Γ'`, but `Γ' ≠ A :: Γ`  
**Example**: `Γ' = [B, A, C]`, `Γ = [B, C]`

**Solution**:
```lean
· -- A ∈ Γ' but Γ' ≠ A :: Γ
  have h_perm := cons_removeAll_perm hA
  have h_exch : (A :: removeAll Γ' A) ⊢ φ := exchange h1 h_perm
  have ih : removeAll Γ' A ⊢ A.imp φ := 
    deduction_theorem (removeAll Γ' A) A φ h_exch  -- Recursive call!
  have h_sub := removeAll_subset hA h2
  exact Derivable.weakening (removeAll Γ' A) Γ (A.imp φ) ih h_sub
```

**Why it works**: `h1.height < (weakening ...).height`, so recursion terminates

---

## Testing Strategy

### Must-Pass Tests
1. **Identity**: `[A] ⊢ A` → `⊢ A → A`
2. **Weakening**: `[A] ⊢ A` → `⊢ A → (B → A)`
3. **Key Case**: `[B, A, C] ⊢ A` → `[B, C] ⊢ A → A` ⭐

### Build Commands
```bash
# Build
lake build Logos.Core.Metalogic.DeductionTheorem

# Test
lake test

# Check sorry count
rg "sorry" Logos/Core/Metalogic/DeductionTheorem.lean
# Expected: 0 matches
```

---

## Troubleshooting

### Termination Checker Fails
- Add explicit `decreasing_by` clause
- Use `simp_wf` to simplify goals
- Prove helper lemma if needed

### Context Permutation Fails
- Verify `A ∈ Γ'` hypothesis
- Check `removeAll` definition
- Use `simp` to unfold

### Performance Regression
- Add `@[simp]` to height definition
- Use `rfl` instead of `simp` where possible
- Profile with `lake env lean --profile`

---

## Success Criteria

- [ ] 0 sorry in `DeductionTheorem.lean`
- [ ] `lake build` succeeds
- [ ] All tests pass
- [ ] Build time < 2 minutes
- [ ] Can remove 5 dependent sorry
- [ ] Tasks 45 and 42 unblocked

---

## Resources

- **Full Research Report**: [research-report-well-founded-recursion.md](research-report-well-founded-recursion.md)
- **Current State**: [summary-partial-completion.md](summary-partial-completion.md)
- **Lean 4 Docs**: https://lean-lang.org/theorem_proving_in_lean4/induction_and_recursion.html
- **Mathlib Pattern**: `Mathlib/Data/Tree/Basic.lean` (height measure)

---

## Next Action

**Start with Phase 1**: Add height measure definition (30 minutes)

Open `Logos/Core/Metalogic/DeductionTheorem.lean` and add the height definition after the imports section. Test with basic examples, then commit.

**Full implementation plan**: See [research-report-well-founded-recursion.md](research-report-well-founded-recursion.md) Section 4.
