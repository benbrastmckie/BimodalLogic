# Implementation Summary: Task 29 - IRR Removal (Partial)

## Session: sess_1774220955_ffc30f
## Date: 2026-03-22
## Plan: v5 (IRR Removal Approach)

## Completed Phases

### Phase 1: Remove IRR from Proof System [COMPLETED]

Successfully removed the `irr` constructor from `DerivationTree` and all associated pattern match arms.

**Files Modified:**
- `Theories/Bimodal/ProofSystem/Derivation.lean` - Removed `irr` constructor, height case, isDenseCompatible case, isDiscreteCompatible case
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Removed IRR case from `derivation_subst` (eliminated 1 sorry)
- `Theories/Bimodal/Metalogic/Soundness.lean` - Removed IRR cases from soundness theorems, removed IRRSoundness import
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Removed IRR case from `derivable_valid_and_swap_valid` (eliminated 1 sorry)
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - Removed IRR case
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - Removed IRR cases from `usedFormulas`

### Phase 2: Remove IRR from Conservative Extension [COMPLETED]

Removed IRR from the extended proof system used for conservative extension proofs.

**Files Modified:**
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` - Removed `irr` constructor from ExtDerivationTree, embedding
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` - Removed IRR cases from substDerivation, collectDerivInl, liftDerivationWith

### Phase 3: Delete Obsolete Files [PARTIAL]

**Files Deleted:**
- `Theories/Bimodal/Metalogic/IRRSoundness.lean`
- `Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean`

**Files NOT Deleted (still needed):**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - Widely imported, provides `canonicalR_irreflexive`. Must be kept until Phase 5/6 refactoring.

**Additional Changes:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Replaced `naming_set_consistent` proof body (~900 lines) with `sorry` since it required IRR rule. Added explanatory comments.

## Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Sorry count | 466 | 461 | -5 |
| Axiom count | 19 | 19 | 0 |
| Build status | Pass | Pass | - |

## Remaining Phases

### Phase 4: Complete Per-Witness Strictness [NOT STARTED]
- `exists_strict_fresh_atom` (has 2 sorries)
- `fresh_Gp_seed_consistent` (has sorries)
- `canonicalR_strict_successor` (not yet implemented)
- `canonicalR_strict_predecessor` (not yet implemented)

### Phase 5: Refactor Call Sites [NOT STARTED]
- ~28 call sites using `canonicalR_irreflexive` across 9+ files
- StagedConstruction (~18 sites), Algebraic (~8 sites), Bundle (~4 sites), etc.

### Phase 6: Delete Axiom [NOT STARTED]
- Delete `canonicalR_irreflexive_axiom` from CanonicalIrreflexivity.lean
- Optionally rename file to reflect new semantics

### Phase 7: Update Documentation [NOT STARTED]
- ~20 files with outdated irreflexive-semantics comments

### Phase 8: DiscreteSuccSeed T-Axiom Proofs [NOT STARTED]
- `discreteImmediateSuccSeed_consistent_axiom` etc.

## Key Technical Notes

1. **IRR is now completely removed from the proof system.** The `DerivationTree` and `ExtDerivationTree` types no longer have an `irr` constructor.

2. **The axiom `canonicalR_irreflexive_axiom` still exists** but is deprecated and will be removed in Phase 6 after call sites are refactored.

3. **Under reflexive semantics, `canonicalR_reflexive` is TRUE** (proven via T-axiom). This is the correct behavior - CanonicalR M M holds because G(phi) -> phi.

4. **Per-witness strictness** is the replacement strategy: instead of universal `forall M, ~CanonicalR M M`, we prove `exists W, CanonicalR M W /\ ~CanonicalR W M`.

## Verification

```bash
# No IRR constructor references remain
grep -rn "DerivationTree\.irr\|ExtDerivationTree\.irr" Theories/Bimodal/
# Returns empty

# Build passes
lake build
# Build completed successfully (1043 jobs)
```

## Next Steps for Continuation

1. Complete Phase 4 proofs (mathematical, requires careful T-axiom reasoning)
2. Systematic refactoring of call sites in Phase 5
3. Final cleanup in Phases 6-8
