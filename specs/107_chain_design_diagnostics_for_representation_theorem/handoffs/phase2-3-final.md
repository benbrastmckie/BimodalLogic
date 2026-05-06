# Handoff: Sorry #2 Closed, Sorry #3 Analyzed

## Summary

- **Sorry #2 (PI:3242, was PI:2941)**: CLOSED. The finite-subset consistency plumbing for `lemma_2_7_seed_consistent` is complete.
- **Sorry #3 (PI:3619, was PI:3156)**: NOT YET CLOSED. Requires changing `BurgessR3Maximal` definition from `SetDeductivelyClosed B` to `ClosedUnderDerivation B`. Full cascade analysis below.

## Sorry #2: Implementation Details

### What Was Done

1. **Defined 5 new extractors** following the working `collect_guards` / `d0_c_event_list` / `d0_a_event_list` pattern:
   - `l27_guard` - extract B-guard from single element (handles 5 seed cases)
   - `l27_collect_guards` - recursively collect B-guards from L
   - `l27_c_event_list` - extract C-events from Until formulas in L
   - `l27_a_event_list` - extract A-events from both Since cases (case 4 and 5)
   - `formula_and_left_cancel` - helper for `Formula.and` injectivity (since `and` is a `def`, not a constructor)

2. **Proved 10 membership lemmas**:
   - `l27_c_event_list_mem`, `l27_a_event_list_mem` - elements in C/A
   - `l27_collect_guards_mem_of_B` - B-elements preserved
   - `l27_guard_untl_val`, `l27_guard_snce_val`, `l27_guard_snce_xi_val` - guard values
   - `l27_collect_guards_mem_of_untl`, `l27_collect_guards_mem_of_snce`, `l27_collect_guards_mem_of_snce_xi` - guard membership
   - `l27_c_event_list_gamma_mem`, `l27_a_event_list_alpha_mem`, `l27_a_event_list_alpha_mem_xi` - event membership

3. **Wrote the plumbing proof** at the sorry site:
   - Extract b_list, c_list, a_list from L using the new extractors
   - Form b = list_conj(beta0 :: b_list), gamma_hat = list_conj(gamma0 :: c_list)
   - Apply h_key to get event with all required properties
   - 5-way case split on seed membership (B, eta, untl, snce, snce_xi)
   - Derive contradiction via derivation_from_implied + consistent_of_F_mem

### Key Insight: Case 5 (snce(beta'∧xi, alpha'))

The 5th seed component uses `Formula.and`, which is a `def` (not a constructor). This required `formula_and_left_cancel` to extract beta' from `snce(beta'∧xi, alpha')`. The proof uses `Formula.imp.injEq` twice (since `Formula.and a b = (a.imp (b.imp bot)).imp bot`).

For the snce left_mono step: `event → snce(b∧chi_gen, alpha')` from h_key, then `snce(b∧chi_gen, alpha') → snce(beta'∧xi, alpha')` via left_mono with derivation `b∧chi_gen → beta'∧xi` (where chi_gen = xi∧untl(xi,eta)).

---

## Sorry #3: Analysis and Recommended Approach

### The Problem

In `lemma_2_7`, when xi is inconsistent (¬SetConsistent {xi}):
- `DC({xi}) = Set.univ`
- `Set.univ` is NOT `SetDeductivelyClosed` (it's inconsistent)
- So we can't pass it as seed to `burgessR3Maximal_extension_exists`
- But we need `B'` with `xi ∈ B'` and `BurgessR3Maximal A B' D`
- Any set containing xi is inconsistent (since `{xi} ⊢ ⊥`)
- So B' must be inconsistent
- But `BurgessR3Maximal` requires `SetDeductivelyClosed B'` (= consistent + CUD)
- CONTRADICTION

### Why the Case Is Reachable

- BX10 only gives `F(eta) ← untl(xi, eta)`, NOT `F(xi)`
- No axiom connects xi's consistency to `untl(xi, eta) ∈ A`
- On discrete orders, `untl(inconsistent_xi, eta)` is satisfiable (eta at immediate successor)

### The Fix: Change BurgessR3Maximal Definition

```lean
-- BEFORE:
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧ burgessR3 A B C ∧ ∀ D, CUD D → B ⊂ D → ¬burgessR3 A D C

-- AFTER:
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  ClosedUnderDerivation B ∧ burgessR3 A B C ∧ ∀ D, CUD D → B ⊂ D → ¬burgessR3 A D C
```

This matches Burgess's original definition where "deductively closed" does NOT imply consistent.

### Solution for xi-inconsistent case (after definition change)

When xi is inconsistent:
1. `DC({xi}) = Set.univ`
2. `ClosedUnderDerivation Set.univ` - trivially true
3. `burgessR3 A Set.univ D` - holds because: for any phi, `⊢ xi → phi` (ex falso), so by left_mono on `untl(xi, delta) ∈ A`: `untl(phi, delta) ∈ A` for ALL phi, giving `burgessRSet A Set.univ D`. Similarly for Since direction.
4. Maximality: `∀ E, CUD E → Set.univ ⊂ E → ...` is vacuously true (nothing is ⊂ Set.univ)
5. So `B' = Set.univ` satisfies `BurgessR3Maximal A Set.univ D`
6. `xi ∈ Set.univ` - trivially true

### Cascade from Definition Change

**Files affected**: ChronicleTypes.lean, RRelation.lean, PointInsertion.lean

**8 caller sites in PointInsertion.lean** that do `h_r3m.1` and expect `SetDeductivelyClosed B`:
1. Line 1694: `burgess_D0_finite_subset_consistent`
2. Line 1905: `burgess_D0_finite_subset_consistent_incons`
3. Line 2336: (in BurgessR3Maximal_extension_fails context)
4. Lines 2720, 2722: seed to `burgessR3Maximal_extension_exists`
5. Line 3086: `lemma_2_7_seed_consistent`
6. Line 3545: `dcs_contains_theorems h_r3m.1`
7. Line 3601: seed to `burgessR3Maximal_extension_exists`

**Recommended cascade strategy**:
1. Change definition in ChronicleTypes.lean
2. Add CUD variants of helpers: `cud_contains_theorems`, `cud_modus_ponens`, `cud_conj_closed` (ALREADY DONE in this session)
3. Change `d0_guard`, `l27_guard`, `collect_guards`, `l27_collect_guards`, `list_conj_mem_dcs` to take `ClosedUnderDerivation` instead of `SetDeductivelyClosed` (they only use `.2`)
4. At caller sites that pass seed to `burgessR3Maximal_extension_exists`, construct `SetDeductivelyClosed` from context (NoUnivBurgessR3 sorry stubs are nearby)
5. Close sorry #3 with `B' = Set.univ`

### Pre-existing preparations

The CUD helper variants (`cud_contains_theorems`, `cud_modus_ponens`, `cud_conj_closed`) have been added to ChronicleTypes.lean and are ready for use.
