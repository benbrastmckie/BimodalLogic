# Implementation Plan: Task #880 (v007)

- **Task**: 880 - Complete RecursiveSeed temporal coherent family construction
- **Status**: [NOT STARTED]
- **Effort**: 12-18 hours
- **Dependencies**: None
- **Research Inputs**: reports/research-008.md
- **Artifacts**: plans/implementation-007.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan fixes the broken namespace issue from commits 54d6e95d and 13018b3b, then completes the RecursiveSeed temporal coherent family construction. The root cause was defining `Formula.needsPositiveHypotheses` in the wrong namespace (`Bimodal.Metalogic.Bundle` instead of `Bimodal.Syntax`). This plan places the definition correctly, re-applies the lost construction fix (seed4 propagation), weakens theorem hypotheses using the conditional pattern, and proves the 2 supporting lemmas.

### Research Integration

From research-008.md:
- Root cause: namespace mismatch causing "environment does not contain" errors
- Construction fix from 13018b3b was semantically correct but built on broken foundation
- 8 sorries: 2 supporting lemmas (critical), 6 DEAD CODE/STRUCTURAL (eliminated by weakened hypotheses)
- Conditional hypothesis pattern: `phi.needsPositiveHypotheses -> P` enables both positive cases (extract proof) and negative cases (vacuous)

## Goals & Non-Goals

**Goals**:
- Add `Formula.needsPositiveHypotheses` to `Bimodal.Syntax.Formula` (correct namespace)
- Re-apply seed4 propagation fix from commit 13018b3b
- Weaken `buildSeedAux_preserves_seedConsistent` hypotheses using conditional pattern
- Prove `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` lemma
- Prove `addToAllPastTimes_preserves_seedConsistent_with_hpsi` lemma
- Achieve 0 sorries in RecursiveSeed.lean

**Non-Goals**:
- Changing the overall construction strategy
- Proving downstream theorems (focus is on this specific file)
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| List filter properties harder than expected | Medium | Medium | Extract helper lemmas, use Mathlib List.filter lemmas |
| Conditional hypothesis pattern breaks existing code | High | Low | Test positive cases (atom, bot, box) first before negative |
| Supporting lemma derivation complex | Medium | High | Broken commit got 90% there - follow same approach |
| Build timeouts at problematic lines | Medium | Low | Run `lake build` frequently, check goal state before committing |

## Sorry Characterization

### Pre-existing Sorries
- 8 sorries in `RecursiveSeed.lean` (working version f4779656):
  - Lines 2808, 2825: Supporting lemmas (critical - need actual proofs)
  - Lines 3972, 4057, 4138: DEAD CODE markers (claim false statements)
  - Lines 4222, 4288, 4352: STRUCTURAL markers (claim false statements)

### Expected Resolution
- Phase 3 eliminates 6 DEAD CODE/STRUCTURAL sorries via weakened hypotheses (no longer need false claims)
- Phase 4 resolves line 2808 sorry via `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` proof
- Phase 4 resolves line 2825 sorry via `addToAllPastTimes_preserves_seedConsistent_with_hpsi` proof

### New Sorries
- None expected. All phases designed to eliminate sorries, not introduce them.

### Remaining Debt
After this implementation:
- 0 sorries expected in `RecursiveSeed.lean`
- `seedConsistent` theorem becomes transitively sorry-free
- Downstream theorems will no longer inherit sorry status

## Implementation Phases

### Phase 1: Add needsPositiveHypotheses to Correct Namespace [NOT STARTED]

- **Dependencies:** None
- **Goal:** Define `Formula.needsPositiveHypotheses` in `Bimodal.Syntax` namespace where `Formula` lives

**Tasks**:
- [ ] Open `Theories/Bimodal/Syntax/Formula.lean`
- [ ] Add `Formula.needsPositiveHypotheses` definition after Formula type definition
- [ ] Add 6 simp lemmas (atom, bot, box, all_future, all_past, imp)
- [ ] Run `lake build` to verify compilation
- [ ] Verify definition is accessible from RecursiveSeed.lean via `#check Formula.needsPositiveHypotheses`

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` - add definition and simp lemmas

**Definition to add**:
```lean
/--
Formula requires the single-family/single-time hypotheses in buildSeedAux.
All non-imp formulas need these for propagation. Imp formulas (including
neg-Box, neg-G, neg-H, and generic imp) don't need them because they only
recurse into other imp formulas which also don't need them.
-/
def Formula.needsPositiveHypotheses : Formula → Bool
  | Formula.imp _ _ => false  -- All imp cases
  | _ => true  -- atom, bot, box, G, H

@[simp] lemma Formula.needsPositiveHypotheses_atom (s : String) :
    (Formula.atom s).needsPositiveHypotheses = true := rfl

@[simp] lemma Formula.needsPositiveHypotheses_bot :
    Formula.bot.needsPositiveHypotheses = true := rfl

@[simp] lemma Formula.needsPositiveHypotheses_box (psi : Formula) :
    (Formula.box psi).needsPositiveHypotheses = true := rfl

@[simp] lemma Formula.needsPositiveHypotheses_all_future (psi : Formula) :
    (Formula.all_future psi).needsPositiveHypotheses = true := rfl

@[simp] lemma Formula.needsPositiveHypotheses_all_past (psi : Formula) :
    (Formula.all_past psi).needsPositiveHypotheses = true := rfl

@[simp] lemma Formula.needsPositiveHypotheses_imp (p q : Formula) :
    (Formula.imp p q).needsPositiveHypotheses = false := rfl
```

**Verification**:
- [ ] Definition compiles in Formula.lean
- [ ] `lake build` succeeds
- [ ] Definition accessible from other files

---

### Phase 2: Re-apply Construction Fix (seed4 propagation) [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Propagate G psi / H psi (not just psi) to future/past times in buildSeedAux

**Tasks**:
- [ ] In RecursiveSeed.lean, locate the G case (`Formula.all_future psi`)
- [ ] Add seed4 step: `let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi`
- [ ] Update recursive call to use seed4 instead of seed3
- [ ] Make symmetric change to H case (`Formula.all_past psi`)
- [ ] Run `lake build` to verify no new errors

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - modify G and H cases

**G case change**:
```lean
-- BEFORE (broken - psi not derivable at future times)
| Formula.all_future psi, famIdx, timeIdx, seed =>
  let phi := Formula.all_future psi
  let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
  let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
  let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
  buildSeedAux psi famIdx timeIdx seed3

-- AFTER (correct - G psi present enables psi derivation)
| Formula.all_future psi, famIdx, timeIdx, seed =>
  let phi := Formula.all_future psi
  let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
  let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
  let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
  let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi  -- NEW: propagate G psi
  buildSeedAux psi famIdx timeIdx seed4
```

**Verification**:
- [ ] G case updated with seed4
- [ ] H case updated symmetrically
- [ ] `lake build` succeeds (same 8 sorries as before)

---

### Phase 3: Weaken Theorem Hypotheses [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Change hypotheses to conditional form; eliminate 6 DEAD CODE/STRUCTURAL sorries

**Tasks**:
- [ ] Change theorem signature to use conditional hypotheses
- [ ] Update positive cases (atom, bot, box, G, H) to extract proofs via `rfl`
- [ ] Update negative cases (imp, neg-Box, neg-G, neg-H) to pass vacuous functions
- [ ] Delete all 6 DEAD CODE/STRUCTURAL sorries (they become unnecessary)
- [ ] Run `lake build` to verify only 2 sorries remain

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - theorem signature and body

**Signature change**:
```lean
-- BEFORE
theorem buildSeedAux_preserves_seedConsistent (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (h_cons : SeedConsistent seed) (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi)
    (h_single_family : seed.familyIndices = [famIdx])
    (h_single_time : seed.timeIndices famIdx = [timeIdx]) :
    SeedConsistent (buildSeedAux phi famIdx timeIdx seed)

-- AFTER
theorem buildSeedAux_preserves_seedConsistent (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (h_cons : SeedConsistent seed) (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi)
    (h_single_family : phi.needsPositiveHypotheses → seed.familyIndices = [famIdx])
    (h_single_time : phi.needsPositiveHypotheses → seed.timeIndices famIdx = [timeIdx]) :
    SeedConsistent (buildSeedAux phi famIdx timeIdx seed)
```

**Positive case pattern** (Box, G, H, atom, bot):
```lean
-- Extract proof using rfl (needsPositiveHypotheses = true for these)
have h_single_family_proof : seed.familyIndices = [famIdx] := h_single_family rfl
have h_single_time_proof : seed.timeIndices famIdx = [timeIdx] := h_single_time rfl
```

**Negative case pattern** (imp cases including neg-Box, neg-G, neg-H):
```lean
-- Pass functions that are never called (needsPositiveHypotheses = false for imp)
exact ih psi.complexity h_complexity psi famIdx timeIdx seed2
    h_seed2_cons h_seed2_wf h_psi_in_seed2 h_psi_cons
    (fun h => absurd h (by simp [Formula.needsPositiveHypotheses_imp]))
    (fun h => absurd h (by simp [Formula.needsPositiveHypotheses_imp])) rfl
```

**Verification**:
- [ ] Theorem signature updated
- [ ] All positive cases compile
- [ ] All negative cases compile (no false claims needed)
- [ ] 6 DEAD CODE/STRUCTURAL sorries removed
- [ ] `lake build` succeeds with only 2 sorries (lines 2808, 2825)

---

### Phase 4: Prove Supporting Lemmas [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove the 2 remaining sorries for addToAllFutureTimes/addToAllPastTimes

**Tasks**:
- [ ] Prove `addToAllFutureTimes_preserves_seedConsistent_with_gpsi`
- [ ] Prove `addToAllPastTimes_preserves_seedConsistent_with_hpsi`
- [ ] Run `lake build` to verify 0 sorries
- [ ] Verify `seedConsistent` is sorry-free via `#check`

**Timing**: 6-8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - prove the two lemmas

**Proof strategy for addToAllFutureTimes_preserves_seedConsistent_with_gpsi**:

The hypothesis `h_gpsi_at_futures` guarantees that G psi is present at each future entry. We need to show adding psi preserves consistency.

1. Unfold `addToAllFutureTimes` - it's a fold over filtered entries
2. Induction on the list of future times
3. Base case (nil): seed unchanged, trivial
4. Inductive case (cons t ts):
   - Entry has G psi (from h_gpsi_at_futures)
   - Derive psi from G psi using `temp_t_future` axiom
   - Apply `addFormula_preserves_consistent`
   - Use IH for remaining times

**Helper lemma needed**:
```lean
lemma future_times_satisfy_bound (entries : List SeedEntry) (famIdx : Nat) (currentTime : Int) :
    ∀ t ∈ (entries.filter (fun e => e.familyIdx == famIdx && e.timeIdx > currentTime)).map (·.timeIdx),
    t > currentTime := by
  intro t ht
  simp only [List.mem_map, List.mem_filter] at ht
  obtain ⟨e, ⟨_, h_cond⟩, rfl⟩ := ht
  simp only [Bool.and_eq_true, decide_eq_true_eq] at h_cond
  exact h_cond.2
```

**Verification**:
- [ ] `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` proven
- [ ] `addToAllPastTimes_preserves_seedConsistent_with_hpsi` proven
- [ ] `grep -c "sorry" RecursiveSeed.lean` returns 0
- [ ] `lake build` succeeds with clean output
- [ ] `#check seedConsistent` shows no sorry warnings

---

### Phase 5: Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Final verification and cleanup

**Tasks**:
- [ ] Run full `lake build` and verify clean output
- [ ] Verify no new axioms introduced: `grep -c "axiom" RecursiveSeed.lean`
- [ ] Check key theorem signatures with `#check`
- [ ] Remove any debugging comments or dead code
- [ ] Run `lake build` one final time

**Timing**: 1 hour

**Verification**:
- [ ] 0 sorries in RecursiveSeed.lean
- [ ] 0 new axioms
- [ ] Clean build output
- [ ] Key theorems verified

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Sorry count decreases as expected: 8 -> 8 -> 8 -> 2 -> 0 -> 0
- [ ] No new axioms introduced
- [ ] `seedConsistent` theorem is sorry-free
- [ ] `buildSeedAux_preserves_seedConsistent` theorem compiles with new signature

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/Formula.lean` - modified (add needsPositiveHypotheses)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - modified (construction fix, hypothesis weakening, proofs)
- `specs/880_augmented_extension_seed_approach/summaries/implementation-summary-{DATE}.md` - created on completion

## Rollback/Contingency

**Phase 1 failure**: If Formula.lean changes break other files, revert to f4779656 and consider a different placement strategy (e.g., local definition in RecursiveSeed.lean with explicit namespace).

**Phase 3 failure**: If conditional hypothesis pattern doesn't work as expected, fall back to the monotonic hypothesis approach from v006 (`famIdx < seed.nextFamilyIdx`, `seed.findEntry famIdx timeIdx ≠ none`).

**Phase 4 failure**: If supporting lemmas prove intractable, keep them as sorry with clear documentation. The construction would still be structurally complete, just missing two derivation proofs. This is tolerated during development but blocks publication.
