# Implementation Summary: Close Task 116 Sorries

- **Task**: 167 - Close 7 sorries from task 116 (SubformulaClosure gap + ConservativeExtension dead code)
- **Status**: [COMPLETED]
- **Plan**: plans/01_close-sorries-plan.md

## Changes

### Phase 1+2: temporalBlockingSet and cascading proof fixes (SubformulaClosure.lean)

**Problem**: Under the new G/H/F/P definitions via Until/Since (Task 116), `P(chi) = S(chi, top)` but `H(neg chi)` is structurally unrelated. The deferralClosure did not contain `H(neg chi)` when `P(chi)` was present, breaking the completeness proof's temporal duality reasoning.

**Solution**: Added `temporalBlockingSet` to `baseDeferralClosure`:
- Defined `toFutureBlocking`/`toPastBlocking` helper functions
- `temporalBlockingSet(phi) = {G(neg chi) | F(chi) in closureWithNeg(phi)} ∪ {H(neg chi) | P(chi) in closureWithNeg(phi)}`
- Key membership lemmas: `all_future_neg_mem_deferralClosure_of_some_future`, `all_past_neg_mem_deferralClosure_of_some_past`
- Fixed ~20 cascading proofs that pattern-match on `baseDeferralClosure` union structure
- Extended `all_future/all_past_in_deferralClosure_cases` to 3-way disjunction (closureWithNeg | G/H_neg_neg_bot | temporal blocking)

### Phase 3: Category A sorry closure (SuccExistence.lean, RestrictedMCS.lean)

**Closed**:
- `p_step_blocking_restricted_subset_deferralClosure` (SuccExistence.lean): replaced sorry with `all_past_neg_mem_deferralClosure_of_some_past`
- `p_step_blocking_restricted_subset` (RestrictedMCS.lean): same approach

**Removed**:
- `neg_FF_implies_GG_neg_in_drm` (RestrictedMCS.lean): dead code with no callers; the MCS version is used on the critical path

### Phase 4: ConservativeExtension rewrite (4 files)

**Problem**: `ExtFormula` used `String` atoms and `all_past`/`all_future` primitives, but `Formula` now uses `Atom` atoms and `untl`/`snce` primitives. Additionally, `ExtAxiom` had 8 dead constructors producing ~30 sorry/Extsorry across all ConservativeExtension files.

**Solution**: Complete rewrite of all 4 ConservativeExtension files:
- `ExtFormula.lean`: Changed `ExtAtom` from `String ⊕ Unit` to `Atom ⊕ Unit`, replaced `all_past`/`all_future` primitives with `untl`/`snce` to mirror `Formula`
- `ExtDerivation.lean`: Rewrote `ExtAxiom` to mirror all 40 base `Axiom` constructors exactly; `embedAxiom` is now a trivial 1-1 map
- `Substitution.lean`: Updated `substFormula` for `untl`/`snce`; `substAxiom` handles all 40 constructors
- `Lifting.lean`: Updated `unembedFormula`/`substFreshWith`/`collectInl` for `untl`/`snce`; `unembedAxiom`/`substAxiomFresh`/`liftAxiom` handle all 40 constructors

Result: 0 sorry, 0 Extsorry across all ConservativeExtension files.

### Phase 5: Full build validation

- `lake build` succeeds (1647 jobs, exit 0)
- No new warnings or errors introduced
- No new axioms introduced

## Sorry Accounting

| File | Before | After | Change |
|------|--------|-------|--------|
| SuccExistence.lean | 4 | 3 | -1 (closed 1, BX1 remain) |
| RestrictedMCS.lean | 2 | 0 | -2 (closed 1, removed 1 dead) |
| ConservativeExtension/*.lean | ~30 | 0 | -30 (complete rewrite) |
| **Total in-scope** | **33** | **3** | **-30** |

Note: The plan anticipated 7 in-scope sorries. The actual count was higher because the ConservativeExtension files had extensive sorry/Extsorry usage beyond the 4 originally identified -- the entire ExtFormula/ExtAxiom infrastructure was broken by the Atom type change and needed a complete rewrite.

## Plan Deviations

- **Phase 3, Task neg_FF_implies_GG_neg_in_drm**: Skipped -- removed as dead code with no callers. The MCS version `neg_FF_implies_GG_neg_in_mcs` is used on the critical path.
- **Phase 4, ExtAxiom rewrite**: Altered -- instead of just removing 8 dead constructors, rewrote ExtAxiom to mirror all 40 base Axiom constructors exactly. This was necessary because ExtFormula also needed updating from `String ⊕ Unit` to `Atom ⊕ Unit` and from `all_past`/`all_future` to `untl`/`snce` primitives.
- **Phase 4, temp_a fix**: Altered -- `temp_a` was replaced by `connect_future` in the new ExtAxiom mirroring.

## Files Modified

- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - temporalBlockingSet + cascading fixes
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Closed 1 sorry
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Closed 1 sorry, removed 1 dead theorem
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean` - Complete rewrite
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` - Complete rewrite
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` - Complete rewrite
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` - Complete rewrite
