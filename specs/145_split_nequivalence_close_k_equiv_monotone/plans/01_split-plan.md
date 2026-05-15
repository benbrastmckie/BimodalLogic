# Implementation Plan: Split NEquivalence.lean, Redesign KType, Close k_equiv_monotone

- **Task**: 145 - Split NEquivalence.lean, redesign KType to NormalForm, close k_equiv_monotone
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: Task 143 (completed), Task 141 (orthogonal -- insertEnv/lift_eval sorries move unchanged)
- **Research Inputs**: reports/01_split-design.md, reports/02_deep-extraction-analysis.md
- **Artifacts**: plans/01_split-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

NEquivalence.lean (610 lines) conflates pure monadic first-order logic definitions with the k-equivalence framework and chronicle integration. This creates a circular import: NormalForm.lean imports NEquivalence.lean for the FO definitions, so NEquivalence.lean cannot import NormalForm.lean back to access the concrete normal form infrastructure. The fix is to extract the pure FO layer (lines 46-366, 320 lines, 24 definitions) into a new MonadicFO.lean, rewire imports so NEquivalence.lean can import NormalForm.lean, then redesign KType to use `NormalForm sig k 0 -> Bool` (concrete) instead of `NormalFormIdx sig k 0 -> Bool` (abstract index), and close the `k_equiv_monotone` sorry via `nf_agreement_monotone`. Net result: -1 sorry.

### Research Integration

Two research reports inform this plan:

- **Report 01** (01_split-design.md): Identified the circular import problem, proposed the MonadicFO.lean extraction, catalogued all definitions that move vs. stay, and sketched the k_equiv_monotone proof strategy.
- **Report 02** (02_deep-extraction-analysis.md): Verified exact line ranges (46-366), confirmed the three Mathlib imports needed by MonadicFO.lean (`Fintype.Card`, `SuccPred.Basic`, `Fin.Tuple.Basic`), verified MonadicFO.lean does NOT need `Bimodal.Syntax` or `Bimodal.ProofSystem`, identified the critical Table.lean issue (needs explicit `Bimodal.Syntax.Formula` import after the split), confirmed `decide_eq_decide` availability for the k_equiv_monotone proof bridge, and verified `finite_types` remains closed with the NormalForm-based KType.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the Reynolds pipeline (discrete completeness branch) by:
- Closing 1 sorry (`k_equiv_monotone`) in the KEquivalenceFramework chain
- Replacing vacuous `nf_rep` (Classical.choice) with concrete `nf_eval_nf` from NormalForm.lean
- Breaking the circular import to enable future NormalForm-dependent work in NEquivalence.lean

## Goals & Non-Goals

**Goals**:
- Extract lines 46-366 of NEquivalence.lean into new MonadicFO.lean
- Break the circular import so NEquivalence.lean can import NormalForm.lean
- Redefine `KType sig k := NormalForm sig k 0 -> Bool`
- Redefine `k_type_of` using `nf_eval_nf` (concrete semantic evaluation)
- Delete `nf_rep` (vacuous Classical.choice, no longer needed)
- Close `k_equiv_monotone` sorry via `decide_eq_decide` + `nf_agreement_monotone`
- Verify `finite_types` remains closed and `lake build` passes

**Non-Goals**:
- Closing the 4 task-141 sorries (insertEnv/lift_eval) -- they move to MonadicFO unchanged
- Closing the `sum_preservation` sorry (Doets Lemma 1.4, separate future task)
- Removing legacy `nf_eval`/`nf_vector` definitions from NormalForm.lean (optional cleanup)
- Modifying OrderedSum.lean, IntegerModel.lean, or Transfer.lean (no changes needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MonadicFO.lean Mathlib imports insufficient | M | Low | Imports verified via lean_run_code in research. If a rare import is missing, add it -- MonadicFO is a leaf node, so no cycle risk. |
| Table.lean breaks after import change (missing Formula) | H | High | Research confirmed Table.lean needs `import Bimodal.Syntax.Formula` after losing transitive NEquivalence -> Syntax chain. Plan includes this fix. |
| finite_types proof breaks after KType domain change | H | Very Low | Proof structure is identical: NormalForm sig k 0 is Fintype by normalForm_fintype. If inferInstance fails, provide explicit haveI. |
| k_equiv_monotone proof doesn't typecheck | M | Low | Bridge via decide_eq_decide verified available in Init.PropLemmas. nf_agreement_monotone has exactly the right signature. Fallback: use simp only to reduce definitions. |
| Downstream files (OrderedSum, IntegerModel, Transfer) break | M | Very Low | These import NEquivalence directly and use k_equiv/KEquivalenceFramework which stay in NEquivalence. No changes needed -- verified by grep. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Create MonadicFO.lean [NOT STARTED]

**Goal**: Extract the pure monadic FO definitions (lines 46-366) from NEquivalence.lean into a new file that compiles independently with only Mathlib imports.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean`
- [ ] Add imports: `Mathlib.Data.Fintype.Card`, `Mathlib.Order.SuccPred.Basic`, `Mathlib.Data.Fin.Tuple.Basic`
- [ ] Add module docstring describing monadic FO logic definitions
- [ ] Copy lines 46-366 from NEquivalence.lean: `namespace` through `NormalFormIdx` (MonadicSignature, MonadicFormula, MonadicSentence, quantifier_depth, MonadicStructure, OrderedMonadicStructure, subinterval theorems, ZStructure, eval, finLift, lift, weaken, insertEnv + all insertEnv lemmas, weaken_eval, atomCount, nfCount, nfCount_pos, NormalFormIdx)
- [ ] Do NOT copy `open Bimodal.Syntax` or `open Bimodal.ProofSystem` (not needed by the FO layer)
- [ ] Close with `end Bimodal.Metalogic.WeakCanonical`
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.MonadicFO` to verify compilation

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` - NEW file (~330 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.MonadicFO` succeeds
- File contains exactly the 24 definitions from lines 46-366 of NEquivalence.lean
- File has 3 Mathlib imports and no Bimodal.Syntax/ProofSystem imports
- The 4 task-141 sorries (insertEnv_zero_eq_cons, insertEnv_succ_cons, insertEnv_finLift, lift_eval) are present and unchanged

---

### Phase 2: Rewire NormalForm.lean and Table.lean Imports [NOT STARTED]

**Goal**: Change NormalForm.lean and Table.lean to import MonadicFO instead of NEquivalence, adding the explicit Formula import that Table.lean needs.

**Tasks**:
- [ ] In NormalForm.lean: change `import Bimodal.Metalogic.WeakCanonical.NEquivalence` to `import Bimodal.Metalogic.WeakCanonical.MonadicFO`
- [ ] In NormalForm.lean: update module docstring to remove "core definitions live in NEquivalence" reference, replace with reference to MonadicFO
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.NormalForm` to verify
- [ ] In Table.lean: change `import Bimodal.Metalogic.WeakCanonical.NEquivalence` to `import Bimodal.Metalogic.WeakCanonical.MonadicFO`
- [ ] In Table.lean: add `import Bimodal.Syntax.Formula` (provides `Formula` type used by `operator_depth` and `table` functions, previously available transitively via NEquivalence -> ReflexiveCanonical -> ... -> Syntax)
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Table` to verify

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` - change import line 1, update docstring
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` - change import line 1, add Syntax.Formula import

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.NormalForm` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Table` succeeds
- NormalForm.lean references MonadicFO, not NEquivalence
- Table.lean references MonadicFO + Bimodal.Syntax.Formula, not NEquivalence

---

### Phase 3: Rewrite NEquivalence.lean (Reduce, Redesign KType, Close Sorry) [NOT STARTED]

**Goal**: Remove the extracted FO definitions from NEquivalence.lean, add NormalForm import to break the cycle, redesign KType to use NormalForm, delete nf_rep, and close k_equiv_monotone.

**Tasks**:
- [ ] Replace NEquivalence.lean imports: remove `Mathlib.Data.Finset.Basic`, add `import Bimodal.Metalogic.WeakCanonical.MonadicFO` and `import Bimodal.Metalogic.WeakCanonical.NormalForm`, keep `ReflexiveCanonical` and `ChronicleExtraction`
- [ ] Remove lines 46-366 (all definitions now in MonadicFO.lean) -- everything from `namespace` to `NormalFormIdx`
- [ ] Update module docstring to describe NEquivalence.lean as the k-equivalence framework file
- [ ] Keep `open Bimodal.Syntax` and `open Bimodal.ProofSystem` (needed by chronicle section)
- [ ] Rewrite `KType`: change `NormalFormIdx sig k 0 -> Bool` to `NormalForm sig k 0 -> Bool`
- [ ] Delete `nf_rep` definition and its docstring (lines 386-404)
- [ ] Rewrite `k_type_of`: change from `fun i => @decide (eval M Fin.elim0 (nf_rep sig k i)) (Classical.dec _)` to `fun nf => @decide (nf_eval_nf M k 0 Fin.elim0 nf) (Classical.dec _)`
- [ ] Update `KType` docstring to reference `NormalForm` instead of `NormalFormIdx`
- [ ] Update `k_type_of` docstring to reference `nf_eval_nf` instead of `nf_rep`
- [ ] Close `k_equiv_monotone` sorry with proof using `decide_eq_decide` + `nf_agreement_monotone`:
  1. `unfold k_equiv k_type_of at h_equiv` and goal
  2. `funext nf_m` to get pointwise equality
  3. Extract `h_agree_k` via `congr_fun h_equiv nf` + `decide_eq_decide`
  4. Apply `nf_agreement_monotone` to get `h_agree_m`
  5. Convert back via `decide_eq_decide`
- [ ] Verify `k_equiv` and `k_equiv_iff_same_type` still compile (unchanged API)
- [ ] Verify `finite_types` proof in KEquivalenceFramework instance still compiles
- [ ] Verify all chronicle instances (chronicleAsMonadicStructure and related) still compile
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.NEquivalence` to verify

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - major rewrite (from ~610 lines to ~180 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.NEquivalence` succeeds
- `k_equiv_monotone` has no sorry
- `nf_rep` is deleted (grep confirms no occurrence)
- `KType` uses `NormalForm sig k 0 -> Bool`
- `k_type_of` uses `nf_eval_nf`
- `finite_types` remains sorry-free
- Chronicle instances compile unchanged

---

### Phase 4: Update WeakCanonical.lean and Full Build Verification [NOT STARTED]

**Goal**: Add MonadicFO import to the aggregator module and verify the entire project builds with no regressions.

**Tasks**:
- [ ] In WeakCanonical.lean: add `import Bimodal.Metalogic.WeakCanonical.MonadicFO` (for completeness; NEquivalence already imports it transitively but explicit import aids clarity)
- [ ] Run `lake build` (full project build)
- [ ] Verify no new sorries introduced: grep for `sorry` in MonadicFO.lean (expect 4 task-141 sorries), NEquivalence.lean (expect 3: 2 carrier_order + 1 sum_preservation), NormalForm.lean (expect 0)
- [ ] Verify `k_equiv_monotone` sorry is removed (net -1 sorry)
- [ ] Verify downstream files compile: OrderedSum.lean, IntegerModel.lean, Transfer.lean (no changes needed, confirmed by grep in research)

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` - add MonadicFO import line

**Verification**:
- `lake build` succeeds (full project)
- `grep -c sorry MonadicFO.lean` = 4 (all task-141)
- `grep -c sorry NEquivalence.lean` = 3 (2 carrier_order + 1 sum_preservation body)
- `grep -c sorry NormalForm.lean` = 0
- No sorry in `k_equiv_monotone`
- All files in WeakCanonical/ directory compile

## Testing & Validation

- [ ] `lake build` passes with zero new errors
- [ ] `k_equiv_monotone` is sorry-free (verify via `lean_goal` or grep)
- [ ] `finite_types` in KEquivalenceFramework instance is sorry-free
- [ ] MonadicFO.lean compiles independently with only Mathlib imports
- [ ] NormalForm.lean imports MonadicFO (not NEquivalence) and has 0 sorries
- [ ] Table.lean imports MonadicFO + Bimodal.Syntax.Formula and compiles
- [ ] NEquivalence.lean imports MonadicFO + NormalForm (cycle broken)
- [ ] No downstream regressions in OrderedSum, IntegerModel, Transfer
- [ ] Net sorry change: -1 (k_equiv_monotone closed, no new sorries)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` - NEW file (~330 lines, 24 FO definitions)
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` - MODIFIED (import change, docstring update)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` - MODIFIED (import change, add Syntax.Formula)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - MAJOR REWRITE (~180 lines, KType redesigned, k_equiv_monotone closed)
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` - MODIFIED (add MonadicFO import)

## Rollback/Contingency

All changes are to tracked files in a git repository. If the implementation fails:
1. `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/` restores all modified files
2. `git rm Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` removes the new file
3. The original NEquivalence.lean (610 lines) is recoverable from the current commit

If a specific phase fails:
- Phase 1 failure: Delete MonadicFO.lean, no other files touched yet
- Phase 2 failure: Revert NormalForm.lean and Table.lean imports to NEquivalence
- Phase 3 failure: This is the most complex phase. If KType redesign compiles but k_equiv_monotone proof fails, keep the sorry and mark the task as partial. The structural improvements (split + KType redesign) are independently valuable.
- Phase 4 failure: Revert WeakCanonical.lean import addition
