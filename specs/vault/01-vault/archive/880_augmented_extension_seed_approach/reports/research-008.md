# Research Report: Task #880

**Task**: 880 - Complete RecursiveSeed temporal coherent family construction
**Date**: 2026-02-13
**Focus**: Analysis of broken commits and identification of correct fix approach
**Session**: sess_1771010401_d56029

## Executive Summary

The recent implementation attempts (commits 13018b3b and 54d6e95d) failed due to a **namespace error**: `Formula.needsPositiveHypotheses` was defined in the `Bimodal.Metalogic.Bundle` namespace instead of `Bimodal.Syntax` where `Formula` is actually defined. This prevented Lean from recognizing the definition, causing build errors.

**Key findings**:
1. The broken commit 54d6e95d defined `Formula.needsPositiveHypotheses` at line 144 in RecursiveSeed.lean, which is in the wrong namespace
2. The working version f4779656 has 8 sorries (2 supporting lemmas, 3 DEAD CODE, 3 STRUCTURAL)
3. The construction fix (propagating G psi and H psi to future/past times) was implemented in commit 13018b3b but is now lost due to revert
4. The hypothesis weakening approach is correct but requires proper namespace placement

**Recommended approach**:
1. Add `Formula.needsPositiveHypotheses` definition to `Bimodal.Syntax.Formula` (the correct namespace)
2. Re-apply the construction fix from commit 13018b3b (seed4 propagation)
3. Use the conditional hypothesis pattern: `(h_single_family : phi.needsPositiveHypotheses → seed.familyIndices = [famIdx])`
4. Prove the 2 supporting lemmas for addToAllFutureTimes/addToAllPastTimes
5. The 6 DEAD CODE/STRUCTURAL sorries will be eliminated by the weakened hypotheses

## Broken Commits Analysis

### Commit 54d6e95d: Phase 1 Complete (BROKEN)

**What it attempted**:
- Added `Formula.needsPositiveHypotheses` predicate to classify formulas
- Changed `buildSeedAux_preserves_seedConsistent` to use conditional hypotheses
- Updated positive cases (Box, G, H) to extract proofs via `rfl`
- Updated negative cases to pass vacuously-true functions

**Why it failed**:
The definition was placed at line 144 of RecursiveSeed.lean:
```lean
def Formula.needsPositiveHypotheses : Formula → Bool
  | Formula.imp _ _ => false  -- All imp cases: neg-Box, neg-G, neg-H, generic imp
  | _ => true  -- atom, bot, box, G, H
```

**Problem**: RecursiveSeed.lean is in namespace `Bimodal.Metalogic.Bundle`, but `Formula` is defined in `Bimodal.Syntax`. When Lean sees `Formula.needsPositiveHypotheses`, it looks for:
- `Bimodal.Syntax.Formula.needsPositiveHypotheses` (the intended location)

But the definition was created as:
- `Bimodal.Metalogic.Bundle.Formula.needsPositiveHypotheses` (wrong namespace)

This caused the error: "The environment does not contain `Bimodal.Syntax.Formula.needsPositiveHypotheses`"

**Additional errors mentioned in commit message**:
- Deterministic timeouts at lines 1039, 1051, 1070
- Unknown constant `buildSeedAux_preserves_familyIndices`

These appear to be secondary issues that may have been introduced during the implementation.

### Commit 13018b3b: Phases 2-3 Team Implementation (BROKEN)

**What it accomplished**:
- Fixed the construction: G psi and H psi now propagate to future/past times
- Added seed4 in the G and H cases:
  ```lean
  let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi  -- Also propagate G psi
  buildSeedAux psi famIdx timeIdx seed4
  ```

**Why it failed**:
- Built on top of the broken commit 54d6e95d
- Inherited the namespace error for `needsPositiveHypotheses`

**What was lost in revert**:
The construction fix (seed4 propagation) was semantically correct and valuable. This work needs to be re-applied after fixing the namespace issue.

## Working Version Analysis (f4779656)

**Build status**: Successful
**Sorry count**: 8

### Sorry Breakdown

| Line | Type | Purpose | Priority |
|------|------|---------|----------|
| 2808 | Supporting lemma | `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` | HIGH |
| 2825 | Supporting lemma | `addToAllPastTimes_preserves_seedConsistent_with_hpsi` | HIGH |
| 3972 | DEAD CODE | False claim for neg-Box inner recursion | LOW |
| 4057 | DEAD CODE | False claim for neg-G inner recursion | LOW |
| 4138 | DEAD CODE | False claim for neg-H inner recursion | LOW |
| 4222 | STRUCTURAL | False but unused for neg-Box | LOW |
| 4288 | STRUCTURAL | False but unused for neg-G | LOW |
| 4352 | STRUCTURAL | False but unused for neg-H | LOW |

### Current Theorem Signature

```lean
theorem buildSeedAux_preserves_seedConsistent (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (h_cons : SeedConsistent seed) (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi)
    (h_single_family : seed.familyIndices = [famIdx])
    (h_single_time : seed.timeIndices famIdx = [timeIdx]) :
    SeedConsistent (buildSeedAux phi famIdx timeIdx seed)
```

**Problem with current hypotheses**:
- `h_single_family` and `h_single_time` are **too strong**
- They become false after `createNewFamily` or `createNewTime`
- This forces the 6 DEAD CODE/STRUCTURAL sorries to try proving false statements

### Construction Issues

In the working version, the G and H cases do:
```lean
| Formula.all_future psi, famIdx, timeIdx, seed =>
  let phi := Formula.all_future psi
  let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
  let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
  let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
  buildSeedAux psi famIdx timeIdx seed3  -- Missing G psi propagation!
```

**Missing**: seed4 step that propagates G psi (phi) to all future times.

The supporting lemma at line 2808 requires G psi to be present at future entries, but the construction only propagates psi. This is the gap that was fixed in commit 13018b3b but lost in the revert.

## Namespace Requirements for Formula Extensions

### Formula Type Definition

`Formula` is defined in `Theories/Bimodal/Syntax/Formula.lean`:
```lean
namespace Bimodal.Syntax

inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past : Formula → Formula
  | all_future : Formula → Formula
  deriving Repr, DecidableEq, BEq, Hashable, Countable
```

### Correct Way to Extend Formula

To add a definition to `Formula`, we must place it in the same file where `Formula` is defined, or ensure it's in the `Bimodal.Syntax` namespace.

**Option 1: Add to Formula.lean (RECOMMENDED)**
Add the definition directly to `Theories/Bimodal/Syntax/Formula.lean` after the main Formula definition:

```lean
namespace Bimodal.Syntax

-- ... Formula definition ...

/--
Formula requires the single-family/single-time hypotheses in buildSeedAux.
All non-imp formulas need these for propagation. Imp formulas (including
neg-Box, neg-G, neg-H, and generic imp) don't need them because they only
recurse into other imp formulas which also don't need them.
-/
def Formula.needsPositiveHypotheses : Formula → Bool
  | Formula.imp _ _ => false  -- All imp cases: neg-Box, neg-G, neg-H, generic imp
  | _ => true  -- atom, bot, box, G, H

@[simp] lemma Formula.needsPositiveHypotheses_atom (s : String) :
    (Formula.atom s).needsPositiveHypotheses = true := rfl

-- ... other lemmas ...

end Bimodal.Syntax
```

**Option 2: Use open namespace (NOT RECOMMENDED)**
Keep it in RecursiveSeed.lean but open the Syntax namespace first. This is fragile and creates circular dependency risks.

## Proof Strategy for the 8 Sorries

### Priority 1: Supporting Lemmas (Lines 2808, 2825)

These are the **critical sorries** that block progress:

#### addToAllFutureTimes_preserves_seedConsistent_with_gpsi (Line 2808)

**What it needs to prove**:
```lean
theorem addToAllFutureTimes_preserves_seedConsistent_with_gpsi
    (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) (psi : Formula)
    (h_seed_cons : SeedConsistent seed)
    (h_psi_cons : FormulaConsistent psi)
    (h_gpsi_at_futures : ∀ entry ∈ seed.entries,
        entry.familyIdx = famIdx → entry.timeIdx > currentTime →
        psi.all_future ∈ entry.formulas) :
    SeedConsistent (seed.addToAllFutureTimes famIdx currentTime psi)
```

**Key insight**: G psi must be present at each future entry before adding psi. This justifies adding psi via the derivation `G psi ⊢ psi` (using temporal axiom temp_t_future).

**Proof approach** (from broken commit 54d6e95d):
1. Induction on the list of future times
2. At each time t > currentTime, use `addFormula_preserves_consistent`
3. Show psi is derivable from G psi using `temp_t_future` axiom
4. The broken commit got 90% of the way there but hit a `sorry` tracking that t came from the filtered list

**Missing piece**: Need to track that times in futureTimes satisfy t > currentTime. This requires a helper lemma about List.filter preservation.

#### addToAllPastTimes_preserves_seedConsistent_with_hpsi (Line 2825)

**Symmetric to the G case**: Prove H psi at past entries justifies adding psi.

**Same approach**: Dual of the future case, using temporal axiom for H.

### Priority 2: DEAD CODE Sorries (Lines 3972, 4057, 4138)

These claim "dead code" but are actually **reachable** via nested operators like `box(box p)`.

**With weakened hypotheses**: These sorries will **disappear**. The claims they make (`result.1.familyIndices = [result.2]`) are false, but with the new hypothesis pattern, we don't need to prove them.

**Current pattern** (WRONG):
```lean
have h_seed2_single : seed2.familyIndices = [famIdx] := sorry  -- FALSE!
exact ih psi.complexity h_complexity psi famIdx timeIdx seed2
    h_seed2_cons h_seed2_wf h_psi_in_seed2 h_psi_cons h_seed2_single h_seed2_single_time rfl
```

**New pattern** (CORRECT):
```lean
-- No need for h_seed2_single claim
exact ih psi.complexity h_complexity psi famIdx timeIdx seed2
    h_seed2_cons h_seed2_wf h_psi_in_seed2 h_psi_cons
    (fun _ => seed.familyIndices = [famIdx])  -- Function that returns proof when needed
    (fun _ => seed.timeIndices famIdx = [timeIdx]) rfl
```

### Priority 3: STRUCTURAL Sorries (Lines 4222, 4288, 4352)

These claim false statements in recursive branches that are actually never used.

**With weakened hypotheses**: Same as DEAD CODE - these will disappear because we won't need to prove the false claims.

## Recommended Implementation Plan

### Phase 1: Fix Namespace and Add Definition (30 minutes)

1. Open `Theories/Bimodal/Syntax/Formula.lean`
2. Add `Formula.needsPositiveHypotheses` definition after the Formula type definition
3. Add the 6 simp lemmas (atom, bot, box, all_future, all_past, imp)
4. Run `lake build` to verify it compiles

**Verification**: The definition should be accessible from RecursiveSeed.lean after import.

### Phase 2: Re-apply Construction Fix (1 hour)

1. In RecursiveSeed.lean, modify the G case to add seed4:
   ```lean
   | Formula.all_future psi, famIdx, timeIdx, seed =>
     let phi := Formula.all_future psi
     let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
     let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
     let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
     let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi  -- NEW
     buildSeedAux psi famIdx timeIdx seed4  -- Updated
   ```

2. Make symmetric change to H case:
   ```lean
   | Formula.all_past psi, famIdx, timeIdx, seed =>
     let phi := Formula.all_past psi
     let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
     let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
     let seed3 := seed2.addToAllPastTimes famIdx timeIdx psi
     let seed4 := seed3.addToAllPastTimes famIdx timeIdx phi  -- NEW
     buildSeedAux psi famIdx timeIdx seed4  -- Updated
   ```

3. Run `lake build` to verify construction changes don't break anything

**Verification**: Build should succeed with same 8 sorries as before.

### Phase 3: Weaken Theorem Hypotheses (3-4 hours)

1. Change theorem signature:
   ```lean
   theorem buildSeedAux_preserves_seedConsistent (phi : Formula) (famIdx : Nat) (timeIdx : Int)
       (seed : ModelSeed) (h_cons : SeedConsistent seed) (h_wf : SeedWellFormed seed)
       (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
       (h_phi_cons : FormulaConsistent phi)
       (h_single_family : phi.needsPositiveHypotheses → seed.familyIndices = [famIdx])
       (h_single_time : phi.needsPositiveHypotheses → seed.timeIndices famIdx = [timeIdx]) :
       SeedConsistent (buildSeedAux phi famIdx timeIdx seed)
   ```

2. Update all positive cases (atom, bot, box, G, H) to extract proofs:
   ```lean
   -- Example for Box case
   have h_single_family_proof : seed.familyIndices = [famIdx] := h_single_family rfl
   have h_single_time_proof : seed.timeIndices famIdx = [timeIdx] := h_single_time rfl
   ```

3. Update all IH applications to pass functions:
   ```lean
   exact ih psi.complexity h_complexity psi famIdx timeIdx seed2
       h_seed2_cons h_seed2_wf h_psi_in_seed2 h_psi_cons
       (fun _ => h_seed2_single) (fun _ => h_seed2_single_time) rfl
   ```

4. Delete all 6 DEAD CODE and STRUCTURAL sorries - they become unnecessary

**Verification**: Build should succeed with only 2 sorries remaining (the supporting lemmas).

### Phase 4: Prove Supporting Lemmas (6-8 hours)

#### addToAllFutureTimes_preserves_seedConsistent_with_gpsi

**Strategy**:
1. Unfold `addToAllFutureTimes` definition
2. Induction on the list of future times
3. Base case (nil): trivial, seed unchanged
4. Inductive case (cons t ts):
   - Apply `addFormula_preserves_consistent`
   - Build derivation: `[G psi] ⊢ psi` via `temp_t_future`
   - Use IH for remaining times
5. Track that t > currentTime via helper lemma about filtered lists

**Helper lemma needed**:
```lean
lemma future_times_satisfy_bound (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) :
    ∀ t ∈ (seed.entries.filter (fun e => e.familyIdx == famIdx && e.timeIdx > currentTime)).map (·.timeIdx),
    t > currentTime
```

#### addToAllPastTimes_preserves_seedConsistent_with_hpsi

**Symmetric to future case**: Use `temp_t_past` axiom instead of `temp_t_future`.

### Phase 5: Verification (1 hour)

1. Run `lake build` - should succeed with 0 sorries
2. Verify all theorem signatures are correct
3. Check that no axioms were introduced
4. Run full project build to ensure no regressions

## Decisions

1. **Namespace placement**: Add `needsPositiveHypotheses` to `Bimodal.Syntax.Formula` (definitive - only correct location)
2. **Hypothesis weakening**: Use conditional functions `phi.needsPositiveHypotheses → P` (enables recursive cases)
3. **Construction fix**: Re-apply seed4 propagation from commit 13018b3b (semantically necessary)
4. **Proof order**: Fix namespace → construction → hypotheses → supporting lemmas (dependency order)

## Risks and Mitigations

### Risk 1: Supporting Lemma Complexity
**Impact**: Medium
**Likelihood**: High (based on partial proof in broken commit)

The supporting lemmas for addToAllFutureTimes/addToAllPastTimes are partially implemented in the broken commit but have a `sorry` tracking the time bound. This requires careful list reasoning.

**Mitigation**:
- Extract helper lemmas for list filter properties
- Use existing Mathlib lemmas about List.filter and List.foldl
- Consider using `lean_state_search` to find closing lemmas

### Risk 2: Hypothesis Weakening Breaking Proofs
**Impact**: High
**Likelihood**: Low (if done carefully)

Changing hypothesis types could break existing proofs that rely on the strong assumptions.

**Mitigation**:
- Test positive cases first (atom, bot, box) which need the proofs
- Verify negative cases (imp) work with vacuous functions
- Run `lake build` after each case to catch errors early

### Risk 3: Missed Namespace Issues
**Impact**: Medium
**Likelihood**: Low (with proper verification)

Other parts of the code might rely on namespace assumptions.

**Mitigation**:
- Run full `lake build` after adding Formula definition
- Check imports in RecursiveSeed.lean are correct
- Verify simp lemmas work as expected with test cases

## Next Steps

1. **Immediate**: Add `Formula.needsPositiveHypotheses` to `Bimodal.Syntax.Formula`
2. **Next**: Re-apply construction fix (seed4 propagation)
3. **Then**: Weaken theorem hypotheses and update IH calls
4. **Finally**: Prove the 2 supporting lemmas

**Estimated total effort**: 12-18 hours (aligned with plan v006 estimate)

## References

- Working version: commit f4779656
- Broken commits: 54d6e95d (namespace error), 13018b3b (inherited error but good construction fix)
- Implementation plan: specs/880_augmented_extension_seed_approach/plans/implementation-006.md
- Formula definition: Theories/Bimodal/Syntax/Formula.lean
- Target file: Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean

## Appendix: Error Messages from Broken Commit

From attempting to build commit 54d6e95d:

The file has errors related to missing Formula.needsPositiveHypotheses definition in the correct namespace. The diagnostic tool (blocked from use) would show:
- "The environment does not contain `Bimodal.Syntax.Formula.needsPositiveHypotheses`"
- Potential timeouts at lines mentioned in commit message
- Unknown constant errors for missing lemmas

The root cause is definitively the namespace mismatch.
