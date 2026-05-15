# Implementation Plan: NormalForm Legacy Cleanup and Cardinality Correspondence Proof

- **Task**: 146 - NormalForm legacy cleanup and cardinality correspondence proof
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: Task 145 (completed)
- **Research Inputs**: specs/146_normalform_cleanup_cardinality/reports/01_cleanup-design.md, specs/146_normalform_cleanup_cardinality/reports/02_post-split-audit.md
- **Artifacts**: plans/02_cleanup-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Remove three dead legacy definitions (`nf_eval`, `nf_vector`, `normalFormIdx_nonempty`) and their section headers from NormalForm.lean, then add three new theorems proving cardinality correspondences between the inductive `NormalForm`/`AtomKind` types and their counting functions `nfCount`/`atomCount` in MonadicFO.lean. All proof scripts have been validated via `lean_run_code` in the post-split audit (report 02). No new imports are required. The result is a publication-quality NormalForm module with the mathematical correspondence between the inductive and Fin-based approaches made explicit.

### Research Integration

Two research reports inform this plan:
- **01_cleanup-design.md**: Identified the dead code inventory, outlined cardinality proof strategies, and catalogued docstring improvements.
- **02_post-split-audit.md**: Confirmed task 145 completion, validated all three proof scripts via `lean_run_code` (zero sorries, zero new imports), confirmed zero downstream references to dead code.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances publication quality (ROADMAP Phase 5) by eliminating dead code and adding mathematical correspondence theorems. It also cleans up artifacts from the task 143 NormalForm/KType redesign chain (tasks 143 -> 145 -> 146).

## Goals & Non-Goals

**Goals**:
- Remove all legacy dead code from NormalForm.lean (3 definitions + 2 section headers)
- Prove `atomKind_card`: `Fintype.card (AtomKind sig n) = atomCount (Fintype.card sig.preds) n`
- Prove `normalForm_card`: `Fintype.card (NormalForm sig k n) = nfCount (Fintype.card sig.preds) k n`
- Prove `normalForm_equiv_fin`: `NormalForm sig k n ≃ NormalFormIdx sig k n`
- Update module docstring to reflect current state (list new theorems, remove legacy references)
- Verify clean build with `lake build`

**Non-Goals**:
- Modifying MonadicFO.lean (counting definitions stay as-is)
- Modifying NEquivalence.lean (KType redesign already complete)
- Adding new Mathlib imports (all lemmas are transitively available)
- Proving any additional normal form properties beyond the cardinality correspondence

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dead code removal breaks downstream | H | Very Low | Grep confirmed zero external references; build verification after deletion |
| Validated proof scripts fail in-file context | M | Low | Proofs verified against current NormalForm.lean imports; fallback to `lean_multi_attempt` |
| Off-diagonal cardinality fragile to Mathlib | L | Low | Uses stable `Finset.offDiag_card` API, not internal implementation details |
| `simp only [NormalForm, nfCount]` unfolding breaks | M | Low | `NormalForm` is a `def` (not `@[reducible]`), so `simp only` unfolds exactly one level |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Delete Dead Code and Update Docstrings [COMPLETED]

**Goal**: Remove all legacy definitions and update the module docstring to reflect the current state of NormalForm.lean.

**Tasks**:
- [x] Delete legacy section header at line 413: `/-! ## Legacy Definitions (to be replaced in Phase 10) -/`
- [x] Delete `nf_eval` definition (lines 419-423)
- [x] Delete `nf_vector` definition (lines 428-431)
- [x] Delete "Additional Instances" section header at line 566: `/-! ## Additional Instances -/`
- [x] Delete `normalFormIdx_nonempty` instance (lines 569-571)
- [x] Update module docstring (lines 1-34) to remove references to legacy `nf_eval`/`nf_vector` and list the new cardinality theorems that will be added in Phase 2
- [x] Run `lake build` to confirm no breakage

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` - Delete dead code, update module docstring

**Verification**:
- `lake build` passes with zero errors
- `grep -rn "nf_eval " Theories/` returns zero matches (excluding `nf_eval_nf` and `nf_eval_unique`)
- `grep -rn "nf_vector" Theories/` returns zero matches
- `grep -rn "normalFormIdx_nonempty" Theories/` returns zero matches

---

### Phase 2: Add Cardinality Theorems and Equivalence [COMPLETED]

**Goal**: Add `atomKind_card`, `normalForm_card`, and `normalForm_equiv_fin` at the end of NormalForm.lean, establishing the cardinality correspondence between the inductive types and the counting functions.

**Tasks**:
- [x] Add new section header: `/-! ## Cardinality Correspondences -/`
- [x] Add `atomKind_card` theorem (23 lines, uses `Fintype.card_congr`, `card_sum`, `card_prod`, `card_fin`, `card_subtype`, `offDiag_card`)
- [x] Add `normalForm_card` theorem (12 lines, induction on `k` generalizing `n`, uses `card_fun`, `card_bool`, `card_prod`, `atomKind_card`, `Nat.pow_add`)
- [x] Add `normalForm_equiv_fin` definition (3 lines, uses `Fintype.equivFinOfCardEq`)
- [x] Run `lake build` to confirm all new theorems compile
- [x] Run `lean_verify` on `atomKind_card`, `normalForm_card`, and `normalForm_equiv_fin` to confirm no `sorryAx`

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` - Add cardinality section before closing `end` namespace

**Verification**:
- `lake build` passes with zero errors
- `lean_verify` on all three new definitions shows no `sorryAx` dependency
- The theorems state the exact cardinality equalities from the research reports

## Testing & Validation

- [ ] `lake build` passes with zero errors after Phase 1 (deletion only)
- [ ] `lake build` passes with zero errors after Phase 2 (additions)
- [ ] `lean_verify` confirms `atomKind_card` is sorry-free
- [ ] `lean_verify` confirms `normalForm_card` is sorry-free
- [ ] `lean_verify` confirms `normalForm_equiv_fin` is sorry-free
- [ ] No grep matches for deleted definitions across the codebase

## Artifacts & Outputs

- `specs/146_normalform_cleanup_cardinality/plans/02_cleanup-plan.md` (this plan)
- `specs/146_normalform_cleanup_cardinality/summaries/02_cleanup-summary.md` (post-implementation)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean`

## Rollback/Contingency

If dead code deletion breaks something unexpected:
1. `git stash` or `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` to revert
2. Investigate the reference that was missed by the grep audit
3. Add a compatibility shim or update the referencing code before retrying deletion

If cardinality proofs fail in-file context:
1. Use `lean_multi_attempt` to test alternative tactic sequences
2. Check whether `simp only [NormalForm, nfCount]` unfolds correctly in the file context
3. Fall back to `unfold NormalForm` or `delta NormalForm` if `simp only` misbehaves
