# Post-Task-157 Analysis: Separation Axiom Elimination

**Task**: 171 - Eliminate remaining separation axioms and clean up post-157 artifacts
**Date**: 2026-05-20
**Session**: sess_1779261283_7c358c
**Context**: Task 157 eliminated 4 temporal closure axioms from SeparationThm.lean by building the full oracle-free GHR94 hierarchy for `is_separable`. This report re-examines the codebase post-157 and finds a major simplification.

## Major Discovery: Predicate Equivalence

**`is_syntactically_separated` and `is_properly_separated` are provably equal for all formulas.**

This was verified with `lean_run_code`:

```lean
theorem syn_sep_eq_proper_sep (φ : Formula) :
    is_syntactically_separated φ = is_properly_separated φ
```

The reason: with the 6-constructor `Formula` type (where `all_past`/`all_future` are definitional abbreviations, not constructors), these equivalences hold:

- `is_S_free φ = is_future_only φ` (both return `false` exactly at `.snce`, recurse identically elsewhere)
- `is_U_free φ = is_past_only φ` (both return `false` exactly at `.untl`, recurse identically elsewhere)

Since `is_syntactically_separated` checks `is_S_free` at `.untl` and `is_U_free` at `.snce`, while `is_properly_separated` checks `is_future_only` at `.untl` and `is_past_only` at `.snce` -- they are identical.

**Consequence**: `is_separable φ ↔ is_properly_separable φ`, and the existing `all_formulas_separable` trivially proves `all_formulas_properly_separable`:

```lean
theorem all_formulas_properly_separable (φ : Formula) : is_properly_separable φ :=
  let ⟨ψ, hsep, hequiv⟩ := all_formulas_separable φ
  ⟨ψ, (syn_sep_eq_proper_sep ψ) ▸ hsep, hequiv⟩
```

This was tested and compiles successfully.

## Current State of Each Axiom

### Axiom 1: `all_past_properly_separable` (SeparationThm.lean:212)

```lean
axiom all_past_properly_separable (φ : Formula) (h : is_properly_separable φ) :
    is_properly_separable (.all_past φ)
```

- **Status**: DEAD CODE. Never used anywhere in the codebase.
- **Why**: `all_past` is not a `Formula` constructor, so structural induction on `Formula` never produces an `all_past` case. The `all_properly_separable` proof only uses `untl_properly_separable` and `snce_properly_separable`.
- **Verified**: `grep -rn "all_past_properly_separable"` returns only the declaration at line 212.
- **Action**: Delete.

### Axiom 2: `all_future_properly_separable` (SeparationThm.lean:217)

```lean
axiom all_future_properly_separable (φ : Formula) (h : is_properly_separable φ) :
    is_properly_separable (.all_future φ)
```

- **Status**: DEAD CODE. Never used anywhere in the codebase. Same reasoning as Axiom 1.
- **Verified**: `grep -rn "all_future_properly_separable"` returns only the declaration at line 217.
- **Action**: Delete.

### Axiom 3: `untl_properly_separable` (SeparationThm.lean:222-224)

```lean
axiom untl_properly_separable (φ ψ : Formula)
    (h1 : is_properly_separable φ) (h2 : is_properly_separable ψ) :
    is_properly_separable (.untl φ ψ)
```

- **Status**: USED by `all_properly_separable` at line 250.
- **Axiom dependency**: `#print axioms all_properly_separable` lists this.
- **Replacement**: `all_formulas_properly_separable _` (one-liner using predicate equivalence).
- **Action**: Replace `axiom` with `theorem` proved via `all_formulas_properly_separable`.

### Axiom 4: `snce_properly_separable` (SeparationThm.lean:228-230)

```lean
axiom snce_properly_separable (φ ψ : Formula)
    (h1 : is_properly_separable φ) (h2 : is_properly_separable ψ) :
    is_properly_separable (.snce φ ψ)
```

- **Status**: USED by `all_properly_separable` at line 251.
- **Axiom dependency**: `#print axioms all_properly_separable` lists this.
- **Replacement**: `all_formulas_properly_separable _` (one-liner).
- **Action**: Replace `axiom` with `theorem` proved via `all_formulas_properly_separable`.

### Axiom 5: `proper_separation_preserves_atoms` (SeparationThm.lean:268-270)

```lean
axiom proper_separation_preserves_atoms (φ : Formula) :
    ∃ ψ : Formula, is_properly_separated ψ = true ∧ int_equiv φ ψ ∧
    formula_atoms ψ ⊆ formula_atoms φ
```

- **Status**: Used by `ExpressiveCompleteness.lean` at lines 1925 and 1998.
- **Note**: `ExpressiveCompleteness.lean` is not part of the `lake build` target (not imported by any built module), but it is the key downstream consumer.
- **Complexity**: This requires proving that the separation procedure preserves atoms. See Group B analysis below.
- **Action**: Prove as theorem (medium effort).

## Group A Strategy: Proper Separation Temporal Closure (Axioms 1-4)

### Approach: Trivial via Predicate Equivalence

Thanks to the discovery that `is_syntactically_separated = is_properly_separated`, all 4 axioms become trivial consequences of the existing `all_formulas_separable`. No mirroring of the hierarchy is needed.

### Proof Architecture

1. Add three foundational lemmas to `Defs.lean` or `Duality.lean`:
   ```lean
   theorem s_free_eq_future_only (φ : Formula) : is_S_free φ = is_future_only φ
   theorem u_free_eq_past_only (φ : Formula) : is_U_free φ = is_past_only φ
   theorem syn_sep_eq_proper_sep (φ : Formula) :
       is_syntactically_separated φ = is_properly_separated φ
   ```
   All proved by simple structural induction (already verified to compile).

2. Add `all_formulas_properly_separable` to `Hierarchy.lean` (or `SeparationThm.lean`):
   ```lean
   theorem all_formulas_properly_separable (φ : Formula) : is_properly_separable φ :=
     let ⟨ψ, hsep, hequiv⟩ := all_formulas_separable φ
     ⟨ψ, (syn_sep_eq_proper_sep ψ) ▸ hsep, hequiv⟩
   ```

3. Replace all 4 axioms with theorems:
   ```lean
   theorem untl_properly_separable (φ ψ : Formula)
       (_h1 : is_properly_separable φ) (_h2 : is_properly_separable ψ) :
       is_properly_separable (.untl φ ψ) :=
     all_formulas_properly_separable _

   theorem snce_properly_separable (φ ψ : Formula)
       (_h1 : is_properly_separable φ) (_h2 : is_properly_separable ψ) :
       is_properly_separable (.snce φ ψ) :=
     all_formulas_properly_separable _
   ```

4. Delete the dead `all_past_properly_separable` and `all_future_properly_separable` axioms.

5. Simplify `all_properly_separable` itself:
   ```lean
   theorem all_properly_separable (phi : Formula) : is_properly_separable phi :=
     all_formulas_properly_separable phi
   ```

### Effort Estimate: 1-2 hours (down from 6-10 hours in Report 01)

### Risk: Very low

All proofs have been verified to compile in `lean_run_code` test snippets.

## Group B Strategy: Atom Preservation (Axiom 5)

### The Challenge

Prove that the separation procedure produces a separated equivalent using only atoms from the original formula. This requires tracking `formula_atoms` through every step of the hierarchy:

1. **`expand_temporal`**: Identity function on 6-constructor Formula, so `formula_atoms (expand_temporal φ) = formula_atoms φ`. Trivial.

2. **`replace_box_with_top`**: Replaces `.box φ` with `.imp .bot .bot`. This can only remove atoms (from inside boxes). So `formula_atoms (replace_box_with_top φ) ⊆ formula_atoms φ`. Straightforward structural induction.

3. **Case outputs** (`case1_psi`, `case2_psi`, etc.): Construct formulas from `a, q, A, B` which are sub-formulas extracted from the input. Their atoms are subsets of the input's atoms. Need per-case verification (8 cases times 2 for duals, but duals are trivial since `all_separable` is used).

4. **`abstract_untl φ A B p`**: Introduces fresh atom `p`. The result has `formula_atoms ⊆ formula_atoms φ ∪ {p}` where `p` is fresh (not in the original).

5. **Separation of abstracted formula**: The separated equivalent `ψ` of `φ'` (the abstracted formula) has `formula_atoms ψ ⊆ formula_atoms φ'`.

6. **`subst_formula ψ p (untl A B)`**: Substitutes `.untl A B` for `.atom p`. Result has `formula_atoms ⊆ (formula_atoms ψ \ {p}) ∪ formula_atoms A ∪ formula_atoms B`. Since `A, B` are sub-formulas of the original and `p` is fresh, the atoms are all from the original.

### Approach Options

**Option A: Strengthen the hierarchy IH** (most thorough, highest effort)

Modify `all_formulas_separable_aux` (or create a parallel version) to return a stronger result:
```lean
∃ ψ, is_syntactically_separated ψ ∧ int_equiv φ ψ ∧ formula_atoms ψ ⊆ formula_atoms φ
```

This requires strengthening the IH throughout the hierarchy:
- `no_S_nested_sep` must return atom-preserving witnesses
- `subst_in_separated_separable` must track atoms through substitution
- `lemma_10_2_6_no_oracle` must preserve atoms through abstraction

**Effort**: 8-12 hours. The proof architecture mirrors the existing one but adds atom tracking at every step.

**Option B: Prove from the existing witnesses** (potentially simpler)

The existing `all_formulas_separable` already constructs a specific separated equivalent ψ for each φ. We could prove that this particular ψ satisfies `formula_atoms ψ ⊆ formula_atoms φ` by analyzing the construction.

However, the construction is spread across multiple levels of induction and uses `Classical.choice` (for `fresh_atom`), making it harder to reason about the specific witness.

**Effort**: Similar to Option A, possibly harder because we'd need to "open up" existentials.

**Option C: Direct proof via model theory** (different approach entirely)

If two formulas are int_equiv and one uses atom `a` that the other doesn't, then the first formula's truth value can't depend on `a` (since any change to `a`'s valuation can be compensated by using the equivalent formula). This means the formula is semantically independent of `a`, and we could simplify it to remove `a`.

This approach works in principle but requires significant model-theoretic infrastructure that may not exist in the codebase.

**Effort**: Hard to estimate, likely 10+ hours.

### Recommended Approach: Option A

Strengthen the hierarchy to track atoms. This is the most natural approach and follows the existing proof architecture closely. The key sub-tasks are:

1. Prove `formula_atoms (replace_box_with_top φ) ⊆ formula_atoms φ` (~30 min)
2. Prove `formula_atoms (abstract_untl φ A B p) ⊆ formula_atoms φ ∪ {p}` (~30 min)
3. Prove `formula_atoms (subst_formula ψ p r) ⊆ (formula_atoms ψ \ {p}) ∪ formula_atoms r` (~45 min)
4. Prove case output atom containment for case1_psi through case8_psi (~2 hours)
5. Strengthen `subst_in_separated_separable` to track atoms (~2 hours)
6. Strengthen `no_S_nested_sep` to return atom-preserving witnesses (~2 hours)
7. Strengthen `all_formulas_separable_aux` with atom tracking (~2 hours)
8. Derive `proper_separation_preserves_atoms` as theorem (~30 min)

**Total effort**: 8-10 hours

**Risk**: Medium. Each step is straightforward but there are many steps. The main risk is that `Set`-based atom tracking (vs `Finset`) may create proof obligations involving `Set.mem_union`, `Set.subset_union_left`, etc. that require careful manipulation.

## Group C: Cleanup Inventory

### C1: Stale Comments Referencing Phase 6 / Axiom Status

| File | Line(s) | Content | Action |
|------|---------|---------|--------|
| Hierarchy.lean | 19-20 | "temporal closure axioms will be eliminated in Phase 6" | Update: temporal closure is now fully proved |
| Hierarchy.lean | 102-104 | "`snce_separable` (temporal closure axiom)...eliminated in Phase 6" | Update: `snce_separable` is now a theorem |
| Hierarchy.lean | 160-161 | "These used the `snce_separable` axiom" | Update: `snce_separable` is a theorem |
| Hierarchy.lean | 177-179 | "temporal closure axioms (via `all_separable`). In Phase 6..." | Update: Phase 6 is done |
| Hierarchy.lean | 673 | "These used all_separable/snce_separable. Replaced by no_S_nested_sep" | Simplify: clarify current state |
| Hierarchy.lean | 803 | "Key theorem for Phase 6B" | Remove Phase 6B reference |
| Hierarchy.lean | 2946-2951 | "`no_S_nested_in_U_separable_noax` -- Oracle-free version" | Dead wrapper, see C2 |
| SeparationThm.lean | 15-16 | "consolidated in `Eliminations.lean` as `all_separable`" | Update: now in Hierarchy.lean as `all_formulas_separable` |
| SeparationThm.lean | 64-83 | Entire comment block about temporal closure axioms | Rewrite: these are now theorems |
| SeparationThm.lean | 109-122 | Comment about temporal closure axioms being sound | Remove: no longer axioms |
| SeparationThm.lean | 197-208 | Comment about proper separation axioms being eliminated later | Rewrite after axiom elimination |
| SeparationThm.lean | 260-267 | Comment about `proper_separation_preserves_atoms` being eliminated in Phase 6 | Update after proving |
| TemporalClosure.lean | 23-27 | "temporal closure axioms state that..." | Update: these are now theorems |
| TemporalClosure.lean | 34-35 | "Phase 6 blocker" | Remove: Phase 6 is done |
| TemporalClosure.lean | 276 | "Phase 6 goal" | Remove: done |
| Eliminations.lean | 786-795 | Comments about Cases 5-8 using `all_separable` from SeparationThm.lean | Clarify current architecture |
| Eliminations.lean | 893-900 | "proved via all_separable" | Update reference |

### C2: Dead Backward-Compat Wrappers

| Wrapper | Location | Usage | Action |
|---------|----------|-------|--------|
| `no_S_nested_in_U_separable_noax` | Hierarchy.lean:2947-2951 | ZERO usages (only definition exists) | Delete |
| `no_S_nested_in_U_separable_direct` | Hierarchy.lean:3624-3627 | ZERO usages (only mentioned in comment at 3424) | Delete |
| `all_past_properly_separable` | SeparationThm.lean:212-213 | ZERO usages | Delete (axiom) |
| `all_future_properly_separable` | SeparationThm.lean:217-218 | ZERO usages | Delete (axiom) |

### C3: DualEliminations.lean Header Comment

- Line 9: "separability theorem `all_separable` combined with the duality principle"
- `all_separable` is defined in SeparationThm.lean; the underlying proof is `all_formulas_separable` from Hierarchy.lean
- Comment is not incorrect but could be more precise
- **Low priority**: the references are not misleading

### C4: Plan File Cleanup

- `specs/157_*/plans/26_case2-fix-plan.md` may contain stale blocker text
- **Low priority**: task 157 is completed, this is archive material

## Dependency Analysis and Ordering

```
Group A (axioms 1-4) ← no dependencies, can proceed immediately
    |
    v
Group B (axiom 5) ← independent of Group A, but benefits from Group A being done first
    |               (cleaner code to modify when axioms are already removed)
    v
Group C (cleanup) ← should be done last, after axiom elimination is complete
                     (comments need to reflect the final state)
```

**Recommended execution order**:
1. **Group A first** (1-2 hours): Add equivalence lemmas, replace 4 axioms with theorems, delete dead code
2. **Group C partially** (30 min): Update comments that reference the 4 eliminated axioms
3. **Group B** (8-10 hours): Prove atom preservation
4. **Group C remainder** (30 min): Update comments about the atom preservation axiom

## Risk Assessment

| Group | Risk | Mitigation |
|-------|------|------------|
| A | Very low | Proofs already verified in test snippets |
| B | Medium | Each step is independently verifiable; can be done incrementally |
| C | Very low | Comment changes only, no proof risk |

## Summary of Key Findings

1. **The previous estimate of 6-10 hours for Group A is reduced to 1-2 hours** thanks to the discovery that `is_syntactically_separated = is_properly_separated`. No hierarchy mirroring is needed.

2. **2 of the 5 axioms are dead code** (`all_past_properly_separable` and `all_future_properly_separable`) and can be deleted immediately.

3. **The remaining 3 axioms** (2 used proper-separability axioms + 1 atom preservation axiom) require:
   - Axioms 3-4: Trivial one-line proofs via predicate equivalence
   - Axiom 5: Substantive work (8-10 hours) tracking atoms through the hierarchy

4. **`ExpressiveCompleteness.lean` is the sole downstream consumer** of axioms 3-5 but is not part of the build target.

5. **22+ stale comments** across 5 files reference "Phase 6", axiom status, or outdated architecture.

6. **2 dead wrapper functions** in Hierarchy.lean can be deleted.
