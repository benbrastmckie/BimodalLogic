# Handoff: Task 107 Partial Progress - Type Mismatch Resolution Needed

**Date**: 2026-05-02  
**Session ID**: sess_1777696621_abe53e  
**Status**: PARTIAL - syntax errors fixed, type mismatches remain  
**Resume Phase**: 2 (after fixing type errors)

---

## Summary of Progress

### Completed Fixes
1. **Syntax errors resolved** (from broken-implementation-analysis.md):
   - Lines 1161-1177: Removed duplicate/misplaced docstrings
   - Lines 1332-1339: Fixed docstring formatting issues
   - PointInsertion.lean now parses without syntax errors

2. **Structural fix - EnrichedEvent**:
   - Defined `EnrichedEvent` structure to resolve `And` (Prop) type mismatch with Type-valued `DerivationTree` fields in `iterated_enrichment`
   - This fixes the core type system issue in the BX chain construction

3. **Sigma type conversion**:
   - Updated `burgess_zeta_consistent` return type from `∃` (Prop-only) to `Σ` (Sigma type)
   - Enables proper handling of Type-valued fields in dependent proofs

### Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Removed ~1188 lines of broken code
  - Added ~472 lines of fixed structure
  - Commit: `5a87cbd0d` ("task 107: partial implementation progress")

---

## Remaining Blockers

### 1. list_conj_implies_elem Type Error
**Location**: PointInsertion.lean (helper lemma section)  
**Issue**: `Or.casesOn` fails with Prop/Type elimination - pattern matching on Prop in Type context  
**Fix Needed**: Restructure to avoid pattern matching on Prop in Type context. May need to:
- Use classical reasoning to extract witnesses
- Replace inductive List elimination with `Finset` or `Multiset` operations
- Or restructure as a DerivationTree proof directly

### 2. burgess_zeta_consistent Call Sites
**Issue**: Call sites still use old `∃` (existential) return type, not updated for new `Σ` (Sigma) type  
**Fix Needed**: Update all call sites to use Sigma type structure:
- Extract `(witness, proof)` pairs instead of `Exists.elim`
- Update pattern matching/let bindings accordingly

### 3. Missing Maximality Witness Arguments
**Location**: Line ~1925 and similar call sites  
**Function**: `burgess_D0_finite_subset_consistent`  
**Issue**: Function signature requires β₀, γ₀, h_neg_until₀ witnesses (from BurgessR3Maximal), but call sites don't provide them  
**Signature**:
```lean
private theorem burgess_D0_finite_subset_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (_h_gc : g_content A ⊆ C)
    (β : Formula)
    (_h_β_not_B : β ∉ B)
    (_h_neg_cons : SetConsistent ({β.neg} ∪ B))
    (h_F_beta_neg : Formula.some_future β.neg ∈ A)
    (β₀ : Formula) (hβ₀ : β₀ ∈ B)           -- MISSING
    (γ₀ : Formula) (hγ₀ : γ₀ ∈ C)           -- MISSING
    (h_neg_until₀ : (Formula.untl (Formula.and β₀ β) γ₀).neg ∈ A) :=  -- MISSING
```

**Fix**: Extract witnesses from `BurgessR3Maximal_extension_fails` or use maximality to obtain β₀∈B, γ₀∈C with the required properties.

### 4. Three Sorry Sites (Phases 2-3)
| Line | Function | Description |
|------|----------|-------------|
| ~1126 | `burgess_D0_finite_subset_consistent` | φ ∈ B case: need `event → φ` via `b → φ` |
| ~1150 | `burgess_D0_finite_subset_consistent_incons` | Inconsistent case: simpler variant |
| ~1586 | `lemma_2_7_seed_consistent` | Lemma 2.7 seed consistency with 5th component |

**Strategy** (from plan v52 AGENT INSTRUCTIONS):
- Use Burgess compression proof: BX5 → BX14 → BX13 → BX10 chain
- Helper lemmas needed: `list_conj`, `list_conj_implies_elem`, `list_conj_mem_dcs`, `list_conj_mem_mcs`, `consistent_of_F_mem`
- For lemma_2_7: handle 5th seed component `{snce(β∧eta, α)}` with modified BX chain starting from `untl(xi, eta)`

---

## Next Steps (In Order)

### Step 1: Fix list_conj_implies_elem (1-2 hours)
- Rewrite to avoid Prop/Type elimination conflict
- Consider using `Classical.choice` or restructuring as a derivation proof
- Test with `lake build`

### Step 2: Update burgess_zeta_consistent Call Sites (30 minutes)
- Find all call sites with grep
- Update from `∃` pattern to `Σ` pattern
- Test with `lake build`

### Step 3: Add Missing Witness Arguments (1 hour)
- Extract β₀, γ₀ from `BurgessR3Maximal` at call sites
- Use `h_r3m` (BurgessR3Maximal A B C) to derive witnesses
- May need helper: `BurgessR3Maximal.extension_witnesses`

### Step 4: Close Sorry Sites (3-4 hours)
- Complete Phase 2: `burgess_D0_finite_subset_consistent` and `burgess_D0_finite_subset_consistent_incons`
- Complete Phase 3: `lemma_2_7_seed_consistent`
- Follow Burgess compression proof from plan v52
- Verify with `lake build`

### Step 5: Proceed to Phases 4-8
- Phase 4: Extend g during point insertion + thread c2' through omega_chain
- Phase 5: Close C4/C4' via Burgess Lemma 2.9
- Phase 6: Implement full Lemma 2.10 + prove limit_satisfies_c5_full
- Phase 7: Close FUC/FSC via Claim 2.11
- Phase 8: Final audit + ROADMAP update

---

## Verification Checklist

After each fix:
- [ ] `lake build` succeeds
- [ ] No new sorry sites introduced
- [ ] PointInsertion.lean sorry count decreases

After Phase 3 complete:
- [ ] All 3 sorry sites closed
- [ ] PointInsertion.lean compiles sorry-free (except intentional lemmas)
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` shows only comments

After all phases complete:
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] Full `lake build` clean
- [ ] ROADMAP.md updated

---

## Reference Documents

- **Implementation Plan**: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/52_implementation-plan.md`
- **Broken Analysis**: `specs/107_chain_design_diagnostics_for_representation_theorem/reports/broken-implementation-analysis.md`
- **Burgess 1982**: `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`
- **Agent Instructions**: See "AGENT INSTRUCTIONS: Closing the 3 Remaining Sorry Sites" in plan v52

---

## Resume Command

```
/implement 107
```

This will resume from the current partial state and continue fixing type mismatches before completing Phases 2-3.
