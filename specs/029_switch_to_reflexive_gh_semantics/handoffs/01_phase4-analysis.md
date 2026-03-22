# Handoff: Phase 4 Analysis - Per-Witness Strictness

## Session: sess_1774222222_bf2c0e
## Date: 2026-03-22
## Phase: 4 (Complete Per-Witness Strictness)

## Summary

Extensive analysis of the per-witness strictness approach for Phase 4. Key breakthrough: the proof requires **atom freshness**, not just the stated conditions.

## Key Findings

### 1. exists_strict_fresh_atom Requires Freshness

The theorem as stated:
```lean
theorem exists_strict_fresh_atom (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ q : Atom, Formula.neg (Formula.atom q) ∈ M ∧
               Formula.all_future (Formula.neg (Formula.atom q)) ∉ M
```

**Finding**: The conditions `neg(q) ∈ M` and `G(neg(q)) ∉ M` are NOT sufficient for the downstream proof. We need q to be **fresh for g_content(M)**.

**Why freshness is needed**: The proof of `fresh_Gp_seed_consistent` (Case 1) requires a substitution argument that only works when q doesn't appear in any formula of g_content(M).

**Good news**: Freshness IMPLIES both conditions:
- Fresh for g_content(M) → q ∉ atoms(g_content(M))
- q ∉ atoms(g_content(M)) → Formula.atom q ∉ M → neg(q) ∈ M (by MCS maximality)
- q ∉ atoms(g_content(M)) → neg(q) ∉ g_content(M) → G(neg(q)) ∉ M (by definition of g_content)

### 2. Fresh Atoms Exist for Any MCS

**Claim**: For any MCS M, there exist infinitely many atoms fresh for g_content(M).

**Proof sketch**:
- g_content(M) = {φ : G(φ) ∈ M} ⊆ M (by T-axiom)
- M is at most countable (MCS built from countable language)
- Each formula has finitely many atoms
- So atoms(g_content(M)) is at most countable
- Since atoms are countably infinite, infinitely many atoms are fresh

### 3. fresh_Gp_seed_consistent Case 1 Proof

The key case is when `G(q) ∈ L` where `L ⊆ g_content(M) ∪ {G(q)}` and `L ⊢ ⊥`.

**Correct argument** (using freshness of q for g_content(M)):

1. L' = L \ {G(q)} ⊆ g_content(M)
2. By deduction theorem: L' ⊢ G(q) → ⊥ = F(neg(q))
3. Since q is fresh for g_content(M), q is fresh for L' ⊆ g_content(M)
4. By substitution (`derivation_subst`): L' ⊢ F(neg(r)) for any atom r fresh for L'
5. Since L' is finite, infinitely many atoms are fresh for L'
6. Taking r fresh for L': L' ⊢ F(neg(r)) where r ∉ atoms_of_context(L')
7. **Key lemma needed**: If L' ⊢ φ and r ∉ atoms_of_context(L') ∪ atoms(φ), then [] ⊢ φ
   - Proof: By substitution, L'[s/r] ⊢ φ[s/r] for any s. If r ∉ L' and r ∉ φ, then L' = L'[s/r] and φ = φ[s/r]. So for ANY s, L' ⊢ φ. In particular, the derivation is "independent of r".
   - But F(neg(r)) contains r! So if L' ⊢ F(neg(r)) where r ∉ L', the derivation produces a formula containing r without using r.
   - This is only possible if [] ⊢ F(neg(r)).
8. But F(neg(r)) = neg(G(r)) is NOT a theorem (G(r) is satisfiable)
9. Contradiction!

### 4. Required Infrastructure

The substitution infrastructure already exists in `Theories/Bimodal/ProofSystem/Substitution.lean`:
- `Formula.subst`: Substitute atom q with atom r in a formula
- `Context.subst`: Apply substitution to all formulas in a context
- `subst_fresh_eq`: If q ∉ φ.atoms, then φ.subst q r = φ
- `context_subst_fresh_eq`: If q ∉ atoms_of_context Γ, then Context.subst q r Γ = Γ
- `derivation_subst`: If Γ ⊢ φ, then Γ.subst q r ⊢ φ.subst q r

### 5. Missing Lemma

Need to prove: If `L ⊢ φ` where `r ∉ atoms_of_context(L)` but `r ∈ atoms(φ)`, then `[] ⊢ φ`.

**Proof idea**:
- If r ∉ L but r ∈ φ, consider substituting r with a DIFFERENT atom s not in L ∪ atoms(φ).
- By derivation_subst: L ⊢ φ implies L.subst r s ⊢ φ.subst r s
- L.subst r s = L (since r ∉ L)
- φ.subst r s ≠ φ (since r ∈ φ, it gets replaced by s)
- So L ⊢ φ.subst r s
- But also L ⊢ φ (given)
- Now φ and φ.subst r s differ only in occurrences of r vs s
- Taking s to be another fresh atom, we can derive "L ⊢ φ' for infinitely many variants φ'"
- This seems to require a more sophisticated argument...

**Alternative approach**:
If L ⊢ F(neg(r)) where r ∉ L, then by contrapositive reasoning:
- Consider the set of formulas derivable from L that mention r
- This set should be empty (since L doesn't mention r)
- But F(neg(r)) mentions r, contradiction!

This needs formalization as a "atoms(derived formula) ⊆ atoms(context)" lemma.

## Recommended Next Steps

1. **Define** `atoms_of_set (S : Set Formula) : Set Atom` as the union of atoms over all formulas in S
2. **Prove** the key lemma: atoms appearing in a derived formula are contained in atoms of the context
3. **Refactor** `exists_strict_fresh_atom` to find a fresh atom for g_content(M)
4. **Complete** `fresh_Gp_seed_consistent` using the substitution argument
5. **Verify** `existsTask_strict_fresh_atom` follows from the above

## Files to Modify

- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - main proofs
- `Theories/Bimodal/ProofSystem/Substitution.lean` - add the key lemma about atoms

## Estimated Remaining Effort

- Key lemma formalization: 2-3 hours
- exists_strict_fresh_atom: 1 hour (straightforward once freshness is formalized)
- fresh_Gp_seed_consistent: 1-2 hours (using substitution argument)
- existsTask_strict_fresh_atom: already mostly done, just needs the above

Total: 4-6 hours for Phase 4 completion.

## Context Preservation

Key theorem statements that are CORRECT as written (just need proofs):
```lean
theorem canonicalR_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR M M  -- PROVEN

theorem existsTask_strict_fresh_atom (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ ¬CanonicalR W M
```

The per-witness strictness theorem is the CORRECT replacement for universal irreflexivity.
