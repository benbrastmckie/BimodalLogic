# Post-Task-116 Assessment: Expressive Completeness Status

**Task**: 157 -- Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Session**: sess_1779176810_27c2df
**Purpose**: Assess exact remaining work after tasks 116 and 167

## Executive Summary

Task 116 removed `all_past` (H) and `all_future` (G) as `Formula` constructors, redefining them as `def` abbreviations. This is a **critical architectural change** that resolves the hierarchy circularity blocker identified in prior research (reports 08-10) but also **breaks the entire Separation module** which still pattern-matches on these now-non-existent constructors. The Separation and ExpressiveCompleteness modules currently do not compile.

The work divides into two independent phases:
1. **Repair phase** (mechanical): Fix all pattern-match breakages caused by the 6-constructor Formula type
2. **Axiom elimination phase** (mathematical): Eliminate 9 axioms using the now-unblocked GHR94 hierarchy proof

## 1. Current Build State

### Main Build: CLEAN
- `lake build` completes successfully (1647 jobs)
- No sorry/axiom regressions from tasks 116/167
- The Separation and ExpressiveCompleteness modules are NOT in the main build path (WeakCanonical.lean does not import them)

### Separation Module: BROKEN (does not compile)
- Root cause: `Defs.lean` has pattern matches on `.all_past` and `.all_future` which are now `def` abbreviations, not constructors
- Lean expands them to compound expressions, causing "Redundant alternative" errors
- All downstream files (12 files in Separation/) fail because Defs.lean is the root dependency

### ExpressiveCompleteness Module: BROKEN (cascading from Separation)
- Imports `SeparationThm.lean` which imports `Defs.lean`
- Also has direct `| all_past` / `| all_future` pattern match arms in its own induction proofs

## 2. Impact of Task 116

### What Changed
Formula now has 6 constructors: `atom`, `bot`, `imp`, `box`, `untl`, `snce`.

The abbreviations are:
```lean
def some_future (phi) := Formula.untl phi Formula.top
def some_past (phi) := Formula.snce phi Formula.top
def all_future (phi) := (some_future phi.neg).neg  -- i.e., .imp (.untl (.imp phi .bot) (.imp .bot .bot)) .bot
def all_past (phi) := (some_past phi.neg).neg      -- i.e., .imp (.snce (.imp phi .bot) (.imp .bot .bot)) .bot
```

### What Breaks
Every pattern match on Formula that includes `| .all_past phi =>` or `| .all_future phi =>` fails because:
- These are `def` abbreviations, not constructors
- Lean expands them to their definition before matching
- The expanded form matches earlier alternatives (the `imp`/`snce`/`untl` arms), causing redundant-alternative errors

### Scope of Breakage

| File | Lines | all_past/all_future refs | Pattern match arms |
|------|-------|--------------------------|-------------------|
| Defs.lean | 343 | 45 | ~36 arms to remove/restructure |
| TemporalClosure.lean | 813 | 111 | ~50+ arms |
| Hierarchy.lean | 1706 | 115 | ~60+ arms |
| Duality.lean | 398 | 24 | ~12 arms |
| SeparationThm.lean | 285 | 24 | ~10 arms |
| FormulaOps.lean | 245 | 4 | ~4 arms |
| DedekindZ.lean | 2096 | 24 | ~12 arms |
| ExpressiveCompleteness.lean | 2255 | 36 | ~18 arms |
| Other WeakCanonical files | various | ~80 | ~40 arms |
| **TOTAL** | ~9944 | ~463 | ~242 arms |

### What the Fix Looks Like

For each function definition with 8 match arms (atom, bot, imp, box, all_past, all_future, untl, snce), it becomes 6 arms (atom, bot, imp, box, untl, snce). The `all_past` and `all_future` cases must be absorbed into the remaining 6 cases:

**For `int_truth`**: The most critical change. Currently:
```lean
| .all_past phi => forall s, s < t -> int_truth M s phi
| .all_future phi => forall s, t < s -> int_truth M s phi
```
Since `all_past phi` expands to `.imp (.snce (.imp phi .bot) (.imp .bot .bot)) .bot` which matches the `imp` case, `int_truth` will compute the correct semantics automatically through the `imp`, `snce`, and `bot` cases. The `all_past`/`all_future` arms are now truly redundant.

**For `is_U_free`, `is_S_free`, `is_syntactically_separated`, etc.**: Same pattern. The 8-arm matches become 6-arm matches. The semantic behavior for `all_past phi` is determined by traversing `imp (snce (imp phi bot) (imp bot bot)) bot`.

**For induction proofs** (`induction phi with | all_past ... | all_future ...`): These branches must be removed. The `all_past`/`all_future` cases are now handled implicitly via the `imp`, `snce`, `untl`, and `bot` branches.

### The Good News: Hierarchy Circularity Is Resolved

This is the key mathematical consequence. Prior research (reports 08-10) identified that the GHR94 hierarchy proof was blocked because:
1. `is_syntactically_separated` accepted `.all_past`/`.all_future` as separated
2. Elimination cases 1-4 produced witnesses containing `.all_past`/`.all_future`
3. Substitution into separated formulas hit `.all_past`/`.all_future` nodes
4. These required expanding to `imp`/`snce`/`untl` forms, which broke the induction measure

Now that `.all_past`/`.all_future` are NOT constructors:
- `is_syntactically_separated` has no cases for them
- Elimination cases cannot produce witnesses with them
- Substitution only encounters `atom`, `bot`, `imp`, `box`, `untl`, `snce`
- The GHR94 hierarchy proof follows directly

## 3. Complete Sorry/Axiom Catalog

### SeparationThm.lean: 9 axioms

| # | Axiom | Type | Status After Fix |
|---|-------|------|------------------|
| 1 | `all_past_separable` | temporal closure | **ELIMINABLE**: `all_past` is now `imp`/`snce`/`bot`, handled by `imp_separable` + `snce_separable` |
| 2 | `all_future_separable` | temporal closure | **ELIMINABLE**: same reasoning |
| 3 | `untl_separable` | temporal closure | **REQUIRES PROOF**: core of GHR94 hierarchy |
| 4 | `snce_separable` | temporal closure | **REQUIRES PROOF**: core of GHR94 hierarchy |
| 5 | `all_past_properly_separable` | proper temporal closure | **ELIMINABLE**: same as #1 |
| 6 | `all_future_properly_separable` | proper temporal closure | **ELIMINABLE**: same as #2 |
| 7 | `untl_properly_separable` | proper temporal closure | **REQUIRES PROOF**: proper version of #3 |
| 8 | `snce_properly_separable` | proper temporal closure | **REQUIRES PROOF**: proper version of #4 |
| 9 | `proper_separation_preserves_atoms` | atom preservation | **REQUIRES PROOF**: follows from constructive hierarchy |

After the fix, axioms 1-2 and 5-6 become trivially provable (the constructions they axiomatize are now compositional). This leaves 5 real axioms (3, 4, 7, 8, 9) requiring the GHR94 hierarchy proof.

### DualEliminations.lean: 8 sorries

All 8 dual elimination cases (elim_case_1_dual through elim_case_8_dual) are sorry'd. These prove `is_S_free psi` (the dual of `is_syntactically_separated`). After the repair:
- Cases 1-4 dual: provable via swap_temporal + primary cases (same approach documented in the file)
- Cases 5-8 dual: provable via `all_separable` (same as NormalForm.lean approach for primary 5-8)

### Transfer.lean: 4 sorries

| Line | Sorry | Type | Relation to task 157 |
|------|-------|------|---------------------|
| 186 | `chronicle_temporal_truth` | inductive truth lemma | Part of Reynolds pipeline (task 155) |
| 286 | `z_interval_to_taskframe_countermodel` | truth-at bridge | Part of Reynolds pipeline (task 155) |
| 332 | `countermodel_discrete` (nonempty) | degenerate case | Part of Reynolds pipeline (task 155) |
| 371 | `countermodel_discrete` (chronicle truth) | chronicle lemma | Part of Reynolds pipeline (task 155) |

These are NOT task 157 work items. They belong to task 155 (Reynolds pipeline).

### TruthLemma.lean: 6 sorries

All in Until/Since backward directions (non-critical-path, documented).

### Other areas: 3 sorries in TenseS5Algebra.lean, 3 in RootScopedChain.lean, etc.

These are outside the Separation/ExpressiveCompleteness scope.

## 4. Recommended Plan Structure

### Phase 1: Repair Defs.lean (Critical Path)

**Scope**: Remove all `.all_past` and `.all_future` match arms from the 15+ definitions in Defs.lean. Each 8-arm match becomes a 6-arm match. Verify that the semantics are preserved.

**Key insight**: Since `all_past phi` = `(some_past (phi.neg)).neg` = `imp (snce (imp phi bot) top) bot`, the `int_truth` computation through the 6-constructor arms will produce:
```
int_truth M t (all_past phi)
  = int_truth M t (imp (snce (imp phi bot) top) bot)
  = (int_truth M t (snce (imp phi bot) top) -> False)
  = (exists s < t, (int_truth M s phi -> False) /\ forall r, s < r -> r < t -> True) -> False
  = (exists s < t, not (int_truth M s phi)) -> False
  = forall s < t, int_truth M s phi  (by classical reasoning)
```
This matches the original semantics. However, the representation is more complex (nested imp/snce/bot instead of direct quantification), so proofs will need additional unfolding steps.

**Effort**: 2-4 hours. Mechanical but requires care.

### Phase 2: Repair Downstream Separation Files

**Scope**: Fix all files that depend on Defs.lean:
- FormulaOps.lean (4 arms)
- Duality.lean (12 arms)
- NegationEquiv.lean (2 refs)
- TemporalClosure.lean (50+ arms -- THIS IS THE LARGEST)
- Hierarchy.lean (60+ arms -- ALSO VERY LARGE)
- DedekindZ.lean (12 arms)
- SeparationThm.lean (10 arms)
- NormalForm.lean (2 refs)

**Key challenge**: TemporalClosure.lean (813 lines, 111 refs) and Hierarchy.lean (1706 lines, 115 refs) are massive files with pervasive `all_past`/`all_future` references. Much of TemporalClosure.lean may become UNNECESSARY since its purpose was to handle `all_past`/`all_future` in the separation proof -- which is no longer needed.

**Likely deletable files**:
- TemporalClosure.lean: ~70% can be deleted (the `replace_box_with_top` normalization, `expand_temporal`, `no_U_nested_in_S` predicates were all workarounds for the all_past/all_future problem)
- Hierarchy.lean: Needs complete rewrite to follow GHR94 directly without all_past/all_future cases

**Effort**: 6-10 hours. Mix of deletion, mechanical fixes, and careful restructuring.

### Phase 3: Repair ExpressiveCompleteness.lean

**Scope**: Fix 18+ pattern match arms in ExpressiveCompleteness.lean. The induction proofs on Formula need to handle 6 constructors instead of 8.

**Key items**:
- `past_only_is_pure_past`: Remove `| all_past`/`| all_future` branches
- `future_only_is_pure_future`: Same
- The main `US_expressively_complete_over_Z` proof chain

**Effort**: 2-3 hours.

### Phase 4: Eliminate Trivial Axioms (1, 2, 5, 6)

**Scope**: Prove the 4 axioms that become trivial after the repair:
- `all_past_separable`: Since `all_past phi` is now `imp (snce ...) bot`, its separability follows from `imp_separable` and `snce_separable` (axiom 4).
- `all_future_separable`: Similarly from `imp_separable` and `untl_separable` (axiom 3).
- `all_past_properly_separable` and `all_future_properly_separable`: Same reasoning.

**Dependency**: Requires axioms 3 and 4 to still be in place (or proved).

**Effort**: 1-2 hours.

### Phase 5: Prove Core Axioms (3, 4) via GHR94 Hierarchy

**Scope**: Prove `untl_separable` and `snce_separable` -- the core of the GHR94 hierarchy (Lemmas 10.2.4-10.2.8). This is the mathematical heart of the task.

**Approach (now unblocked by task 116)**:
1. **10.2.3 (8 elimination cases)**: Cases 1-4 already proved. Cases 5-8 proved via `all_separable` (which depends on axioms 3-4 -- but this circularity is acceptable since we're building the hierarchy inductively).
2. **10.2.4 (single S with top-level U)**: Event-split + guard-split into 8 cases.
3. **10.2.5 (single U-type)**: S-nesting induction. 10.2.4 handles the base.
4. **10.2.6 (multi U-type)**: Induction on count of U-types.
5. **10.2.7 (no S nested in U)**: Reduces to 10.2.5-10.2.6.
6. **10.2.8 (all formulas)**: Junction-depth induction.

The key simplification: with no `.all_past`/`.all_future` constructors, the hierarchy proof follows GHR94 exactly. No circularity, no workarounds.

**Effort**: 8-12 hours. This is genuine mathematical formalization work.

### Phase 6: Prove Remaining Axioms (7, 8, 9)

**Scope**: The "proper" versions and atom preservation.
- Axioms 7, 8 (`untl_properly_separable`, `snce_properly_separable`): Follow from Phase 5 + purity analysis.
- Axiom 9 (`proper_separation_preserves_atoms`): Follows from the constructive hierarchy (no new atoms introduced).

**Effort**: 3-4 hours.

### Phase 7: Prove Dual Eliminations

**Scope**: Close the 8 sorry sites in DualEliminations.lean using the now-available hierarchy.

**Effort**: 2-3 hours.

### Phase 8: Verify and Clean

**Scope**: Run `lake build` on the Separation and ExpressiveCompleteness modules. Check for axiom-free build. Clean dead code.

**Effort**: 1-2 hours.

## 5. Total Effort Estimate

| Phase | Work | Hours | Risk |
|-------|------|-------|------|
| 1. Repair Defs.lean | Mechanical | 2-4 | Low |
| 2. Repair Downstream | Mechanical + deletion | 6-10 | Medium |
| 3. Repair ExpressiveCompleteness | Mechanical | 2-3 | Low |
| 4. Trivial axiom elimination | Proof | 1-2 | Low |
| 5. GHR94 hierarchy | Mathematical proof | 8-12 | Medium-High |
| 6. Proper + atom axioms | Proof | 3-4 | Medium |
| 7. Dual eliminations | Proof | 2-3 | Low |
| 8. Verify and clean | Verification | 1-2 | Low |
| **TOTAL** | | **25-40** | |

## 6. Critical Design Decision

### Should Defs.lean work with 6 constructors or introduce a local 8-constructor type?

**Option A (recommended)**: Work with 6 constructors throughout. Remove all `all_past`/`all_future` pattern matches. Accept that `int_truth` computes `all_past phi` via the expanded imp/snce/bot representation.

**Pros**: Matches GHR94 language exactly. Eliminates hierarchy circularity. Simpler final result.
**Cons**: Proofs about `int_truth (all_past phi)` require more unfolding. Some existing proofs need substantial rework.

**Option B**: Introduce a local `SepFormula` inductive in the Separation module with 8 constructors, plus a function `toSepFormula : Formula -> SepFormula` that pattern-matches `imp (snce (imp phi bot) top) bot` to reconstruct `all_past phi`, etc.

**Pros**: Preserves existing proof structure. Separation-specific semantics.
**Cons**: Translation overhead. Risk of mismatches. Adds complexity.

**Recommendation**: Option A. The primary benefit of task 116 is that the GHR94 proof follows directly with 6 constructors. Introducing a local 8-constructor type would reintroduce the complexity that task 116 was designed to remove. The proofs about `int_truth (all_past phi)` can use helper lemmas:

```lean
theorem int_truth_all_past (M : IntStructure) (t : Z) (phi : Formula) :
    int_truth M t (Formula.all_past phi) <-> forall s, s < t -> int_truth M s phi := by
  -- Unfold all_past, some_past, neg and compute through int_truth
  sorry -- mechanical unfolding
```

These helper lemmas, once proved, make downstream proofs almost identical to the existing ones.

## 7. Dependencies and Prerequisites

- Task 116: COMPLETED (prerequisite met)
- Task 167: COMPLETED (no sorry regressions)
- Task 155: NOT a dependency (Transfer.lean sorries are separate)
- Mathlib: No new Mathlib lemmas needed (the proofs are purely about the custom integer semantics)

## 8. Files Requiring Changes (Complete List)

### Must Fix (build-blocking)
1. `Separation/Defs.lean` -- 15+ definitions need 8->6 arm reduction
2. `Separation/FormulaOps.lean` -- `subst_formula`, `subst_correctness`
3. `Separation/Duality.lean` -- `swap_temporal`-related proofs
4. `Separation/NegationEquiv.lean` -- 2 references
5. `Separation/TemporalClosure.lean` -- major rewrite/deletion needed
6. `Separation/Hierarchy.lean` -- major rewrite needed
7. `Separation/DedekindZ.lean` -- 12 references
8. `Separation/SeparationThm.lean` -- axiom declarations + `all_separable`
9. `Separation/NormalForm.lean` -- 2 references
10. `ExpressiveCompleteness.lean` -- 18+ pattern match arms

### Should Fix (sorry/axiom elimination)
11. `Separation/DualEliminations.lean` -- 8 sorry sites
12. `Separation/SeparationThm.lean` -- 9 axiom declarations

### Not Task 157 Scope
- `Transfer.lean` (4 sorries) -- task 155
- `TruthLemma.lean` (6 sorries) -- task 155
- `OrderedSum.lean` (1 sorry) -- task 155
- `TenseS5Algebra.lean` (3 sorries) -- task 107/other
