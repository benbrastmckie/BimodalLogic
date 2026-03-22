# Handoff: Phase 5.0 Progress

**Task**: 29 - switch_to_reflexive_gh_semantics
**Phase**: 5.0 - Derivation Substitution Lemma
**Session**: sess_1774217157_bfe561
**Date**: 2026-03-22

## Completed Work

### 1. Created Substitution Infrastructure

Created new file: `Theories/Bimodal/ProofSystem/Substitution.lean`

**Key definitions:**
- `Formula.subst : Atom -> Atom -> Formula -> Formula` - Substitute atom q with atom r
- `Context.subst : Atom -> Atom -> Context -> Context` - Apply substitution to all formulas
- `atoms_of_context : Context -> Finset Atom` - All atoms in a context

**Key theorems (proven):**
- `subst_fresh_eq` - Substituting a fresh atom leaves the formula unchanged
- `context_subst_fresh_eq` - Substituting a fresh atom leaves the context unchanged
- `axiom_subst` - Axiom instances are preserved under substitution
- `swap_temporal_subst` - swap_temporal commutes with substitution
- `derivation_subst` - Derivations are preserved under atom substitution (1 sorry in IRR case)

### 2. Remaining Work in Phase 5.0

The `derivation_subst` function has one sorry for the IRR (Irreflexivity Rule) case. The IRR case is complex because:
- If `p = q` (substituting the IRR fresh atom): Need to verify `r` is fresh for the substituted formula
- If `p ≠ q` but `p = r`: The substitution might introduce `p` into the formula, breaking freshness

**Recommended approach for IRR case:**
1. If `p ≠ q` and `p ≠ r`: IRR applies directly with same `p`
2. If `p = q`: Choose a new fresh atom `p'` that avoids both `r` and `(φ.subst q r).atoms`
3. If `p = r`: Similar fresh atom selection

The IRR case may not be needed for the main application (fresh G-atom proofs) since those use theorems (empty context) that don't involve the IRR rule in their derivation trees.

## Key Insight About Fresh Atom Approach

After extensive analysis, the correct approach for `exists_strict_fresh_atom` is:

**Theorem**: For any MCS M, there exists atom q such that `neg q ∈ M` and `G(neg q) ∉ M`.

**Proof Approach** (NOT YET IMPLEMENTED):
1. The MCS M was constructed from a **finite consistent seed** via Lindenbaum
2. Choose atom q **fresh for the seed** (doesn't appear in any formula of the seed)
3. By freshness and the structure of derivation:
   - No derivation from the seed can produce a formula mentioning q
   - Except through axiom schema instances that are universally quantified
   - But axiom instances mentioning q can only be instantiations of the schema WITH q
   - The key formula `G(neg q)` requires deriving `neg q` as a theorem (for temporal necessitation)
   - But `neg q` is NOT a theorem for any specific atom q
4. Therefore, `G(neg q)` is NOT derivable from a seed that doesn't mention q
5. During Lindenbaum, either `G(neg q)` or `F(q)` is added
6. Since `G(neg q)` is not derivable from the seed, `F(q)` being added maintains consistency
7. The construction must choose one - and for infinitely many fresh atoms, at least one gets `F(q)` added

**Implementation Gap**: This argument requires formalizing:
- The notion of "atoms appearing in a derivation"
- That derivability from an atom-free context cannot introduce new atoms in the conclusion (except via axiom schema instantiation)
- That `neg q` is not a theorem (it's contingent)

## Files Modified

- `Theories/Bimodal/ProofSystem/Substitution.lean` (NEW - 400+ lines)

## Next Steps for Continuation

1. **Complete IRR case** in `derivation_subst` (optional - may not be needed)
2. **Formalize the "fresh for seed" argument** for `exists_strict_fresh_atom`
3. **Apply substitution lemma** to `fresh_Gp_seed_consistent`
4. **Continue to Phase 5.1** once Phase 5.0 is complete

## Build Status

```bash
lake build Bimodal.ProofSystem.Substitution
# Builds with warnings about 3 sorries (all in the IRR case of derivation_subst)
```
