# Research Report: Task #157 (Round 6)

**Task**: Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-17
**Mode**: Team Research (7 teammates: 4 general + 3 Phase 7 specialists)
**Focus**: Review blockers and handoffs to find the correct mathematical approach

## Summary

Phase 6 (Cases 5-8 axiom elimination) has been blocked through 8 plan versions due to a fundamental category error: the Dedekind formula (GHR94 Section 10.3) is for dense/Dedekind-complete time, not integers. The correct approach is the junction-depth hierarchy with nested `Nat.strongRecOn` on `(JD, count_U)` (~500-700 LOC). However, the 8 axioms do NOT block any downstream goal — `US_expressively_complete_over_Z` already compiles.

Phase 7 (`atom_elim_correct`) has a clear fix path (~170-365 LOC): offset freshAM indices, restore `h_disj` hypothesis, add `hB_atoms` parameter, prove `elimExtFromSep_correct` by direct structural induction.

**Strategic recommendation**: Prioritize Phase 7 (achieves sorry-free `US_expressively_complete_over_Z`) over Phase 6 (eliminates axioms but doesn't unblock anything).

## Key Findings

### Phase 6: The Dedekind Category Error

**All 4 original teammates agree**: The Dedekind formula approach (GHR94 Lemma 10.3.11) is for Dedekind-complete time (the reals), NOT for integer time Z. Using it for Z is a category error that explains why every implementation attempt failed.

**What GHR94 actually says for Z** (Teammate A):
- Cases 5-8 are NOT self-contained terminal rules producing separated output
- They are intermediate steps in an iterative elimination process within the hierarchy: Lemma 10.2.3 → 10.2.4 → 10.2.5 → 10.2.6 → 10.2.7 → 10.2.8
- Case 7 has THREE disjuncts (not two); the first requires further elimination by Cases 8 and 4
- The proof requires a unified well-founded induction, not standalone case lemmas

**The correct approach** (Teammates A + B converge):
- Nested `Nat.strongRecOn` on `(junction_depth, count_U_subformulas)` 
- This pattern was verified to compile in Lean 4 (Report 05 Teammate B)
- The outer IH at lower JD gives ALL values of count_U — breaking the circularity
- Missing infrastructure: `abstract_snce` (~100-120 LOC), `subformula_jd_le` (~60 LOC), `jd_snce_inside_untl_lt` (~50 LOC), main WF proof (~200 LOC)
- Total: ~500-700 LOC

**Critical code-level issues** (Teammate C):
- `no_S_nested_in_U_separable` does NOT exist in the code — the actual target is `multi_U_formula_separable` in Hierarchy.lean line 594
- `is_U_free` has a purity mismatch: our code accepts `all_future phi` as U-free, but GHR94 treats `G(phi) = neg U(neg phi, top)` as never U-free
- Cases 5-8 as standalone lemmas are an architectural artifact of our plan — GHR94 handles these inline

**Strategic assessment** (Teammate D):
- The 8 axioms do NOT block the downstream goal (task 155 Phase 3B)
- `US_expressively_complete_over_Z` already compiles via axiom-based `all_properly_separable`
- No viable alternative proof strategies exist (games, completeness, BAO, automata all rejected)
- The axiom-based formalization is a valid meaningful contribution

### Phase 7: The freshAM Disjointness Fix

**Primary blocker** (freshAM researcher): At recursive depth ≥ 2, both `atomMap` and `freshAM` use base `"e"` with indices starting at 0. The overlap is real.

**Additional blocker** (minimal-fix researcher): The theorem needs an `hB_atoms` parameter — the atom case in structural induction requires knowing that `B_sep`'s atoms lie in `freshAM`'s image.

**The fix** (consensus across 3 Phase 7 researchers):
1. Add `atomMap_card : Nat` parameter tracking index upper bound of atomMap's range
2. Construct `freshAM` with indices starting at `atomMap_card` (not 0)
3. Restore `h_disj : ∀ p ep, atomMap p ≠ freshAM ep` as a parameter (follows from arithmetic after offset fix)
4. Add `hB_atoms : ∀ a ∈ B_sep.atoms, a ∈ Set.range freshAM` parameter (or derive inline at call sites)
5. Prove `elimExtFromSep_correct` by direct structural induction using `to_int_struct_mem_freshAM/atomMap` (not routing through `applySubsts_past_correct`)

**Implementation order** (structural researcher):
1. freshAM offset fix (construction change)
2. `int_truth_foldl_or` helper (~15 LOC)
3. `elimExtFromSep_correct` by direct structural induction (~100 LOC)
4. `quantElimFormula_correct_iff` (~40 LOC)
5. Close `atom_elim_correct` sorry (~15 LOC)

**Alternative** (minimal-fix researcher): Inline the proof at the two call sites where `A_ext`'s structure is known, avoiding the need for a standalone `hB_atoms` parameter.

### Conflict: freshAM_inj Sufficiency

**Disagreement**: The freshAM researcher says `freshAM_inj` is NOT sufficient (need separate range-disjointness). The minimal-fix researcher says disjointness is "already guaranteed by freshAM_inj alone."

**Resolution**: The freshAM researcher is correct. `freshAM_inj` proves `freshAM x ≠ freshAM y` when `x ≠ y` (within freshAM's domain). But the question is whether `atomMap p ≠ freshAM ep` (across different functions). At recursive levels where both use base "e" with overlapping index ranges, these CAN collide. The offset fix is required.

## Synthesis

### Recommendations (Priority Order)

1. **Phase 7 first** (~200-300 LOC): Fix freshAM offset, prove `elimExtFromSep_correct` by direct induction, close sorry. This achieves sorry-free `US_expressively_complete_over_Z`.

2. **Phase 6 later** (~500-700 LOC): Implement junction-depth hierarchy with `(JD, count_U)` WF measure. Required for axiom-free separation but NOT blocking any downstream task.

3. **Fix `is_U_free` definition** if pursuing Phase 6: The purity mismatch with GHR94 (accepting `all_future` as U-free) may cause subtle issues in the hierarchy proof.

### Phase 7 Concrete Fix Steps

```
Step 1: Modify freshAM construction in `expressiveness_inner`
  - Add `offset : Nat` parameter (= number of atomMap indices in scope)
  - freshAM uses `Atom.mk_fresh "e" (offset + equiv.val)` instead of `Atom.mk_fresh "e" equiv.val`
  - At top level: offset = card sig.preds
  - At recursive levels: offset = card (ExtPred sig) from outer level

Step 2: Restore h_disj and add hB_atoms to atom_elim_correct
  - h_disj follows from: atomMap indices < offset ≤ offset + freshAM indices
  - hB_atoms derivable at call sites from known A_ext construction

Step 3: Prove elimExtFromSep_correct (~100 LOC)
  - Structural induction on B_sep
  - atom case: use hB_atoms + to_int_struct_mem_freshAM
  - bot/box: trivial
  - imp: IH
  - temporal (all_past, all_future, snce, untl): direct argument using
    past/future time semantics + to_int_struct membership lemmas

Step 4: Prove quantElimFormula_correct_iff (~40 LOC)
  - Unfold foldl disjunction
  - Find unique σ* via guardFormula_correct + guardFormula_unique
  - Apply elimExtFromSep_correct at σ*

Step 5: Close sorry (~15 LOC)
```

### Phase 6 Concrete Fix Steps (Lower Priority)

```
Step 1: Fix is_U_free to reject all_future/all_past (optional but recommended)

Step 2: Implement abstract_snce (~120 LOC)
  - Dual of existing abstract_untl
  - Replaces S(phi, psi) with S(atom a, atom b) and records substitutions

Step 3: Prove subformula_jd_le and jd_snce_inside_untl_lt (~110 LOC)
  - Structural lemmas showing junction_depth decreases in the right contexts

Step 4: Main theorem via nested Nat.strongRecOn (~200-300 LOC)
  - Outer: strongRecOn on junction_depth
  - Inner: strongRecOn on count_U (or structural for JD=0 case)
  - Uses abstract_snce + abstract_untl to reduce JD
  - Uses case elimination (Cases 1-8 inline) to reduce count_U
```

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary (GHR94 text analysis) | completed | high |
| B | Alternatives (WF measures) | completed | high |
| C | Critic (definition validation) | completed | high |
| D | Horizons (strategic assessment) | completed | high |
| Phase7-freshAM | freshAM construction analysis | completed | high |
| Phase7-structural | elimExtFromSep induction | completed | high |
| Phase7-minimal | Minimal fix path | completed | medium |

## References

- GHR94 Chapter 10.2 (separation theorem for Z)
- GHR94 Section 10.3 (Dedekind-complete time — NOT applicable to Z)
- Report 04 (Phase 6 blocker resolution — junction-depth approach)
- Report 05 (Dedekind discovery — now known to be a category error for Z)
- Phase 6 handoff: `specs/157_.../handoffs/phase-6-handoff-20260517T200000.md`
- Phase 7 handoff: `specs/157_.../handoffs/phase-7-handoff-20260517f.md`
