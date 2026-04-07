# Implementation Plan: Close Restricted Coherence Sorries via Reflexive Semantics Switch

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [PLANNED]
- **Effort**: 8 hours
- **Dependencies**: None (task 82 FMP TruthPreservation and task 68 dense_completeness_fc are out of scope)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/26_team-research.md, specs/083_close_restricted_coherence_sorries/reports/27_team-research.md
- **Artifacts**: plans/28_completeness-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is plan v28, revised from v26 after a completion audit found that phases marked [COMPLETED] were only partially done. The core semantics switch (reflexive G/H with `≤`, strict U/S with `<`) and T-axiom constructors are in place, but 4 trivial T-axiom sorries in SuccChainFMCS.lean were never closed, Boneyard code was not restored, and the Phase 1 prototype was skipped entirely. This revision corrects phase statuses to reflect reality and restructures remaining work into 3 phases: close the trivial sorries, implement hybrid F-resolution for the 2 main sorries, and clean up.

### What Was Actually Completed (from plan v26)

**Phase 1 (Prototype)**: SKIPPED — no scratch file was ever created. The team went directly into production changes.

**Phase 2 (Core Definitions Switch)**: ~95% complete. All semantics changes, T-axiom constructors, FMCS updates, and call site fixes are done. Two known new sorries: `F_until_equiv_valid` and `P_since_equiv_valid` (semantic gap: F(ψ) now includes present via `≤` but Until requires strict future `>`).

**Phase 3 (T-Axiom Soundness + FMCS Coherence)**: ~60% complete. T-axiom soundness proofs are sorry-free. SuccChainFMCS and DeterministicFMCS use `≤`. But: 4 `was: temp_t_future/past` sorries in SuccChainFMCS.lean remain unclosed (lines 1267, 3804, 4071, 4214), and Boneyard code was not restored.

### Current Sorry Landscape (key files)

| File | Sorries | Notes |
|------|---------|-------|
| SuccChainFMCS.lean | 23 | 4 trivial T-axiom sorries + structural |
| UltrafilterChain.lean | 14 | 2 main targets (`forward_F`, `backward_P`) |
| DeterministicFMCS.lean | 10 | 2 leaf F/P + 4 U/S coherence |
| Soundness.lean | 36 | Frame-class architectural, `F_until_equiv`, `P_since_equiv` |
| RestrictedTruthLemma.lean | 7 | `restricted_chain_G_step`, `restricted_chain_H_step` + structural |

### Research Integration

Report 26 established the hybrid construction approach (deterministic backbone + Lindenbaum detours). Report 27 confirmed mixed semantics is standard (Burgess-Xu BX1). Both remain valid — the approach is correct, the prior implementation was just incomplete.

## Goals & Non-Goals

**Goals**:
- Close 4 trivial `was: temp_t_future/past` sorries in SuccChainFMCS.lean
- Close `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` (UltrafilterChain.lean)
- Resolve `F_until_equiv_valid` / `P_since_equiv_valid` semantic gap
- Close or remove `restricted_chain_G_step` and `restricted_chain_H_step` in RestrictedTruthLemma.lean
- Achieve sorry-free `completeness_over_Int` (transitively)

**Non-Goals**:
- FMP TruthPreservation (task 82)
- Dense completeness `dense_completeness_fc` (task 68)
- Soundness.lean frame-class architectural sorries (separate concern)
- Rewriting DovetailedChain (deprecated)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency argument doesn't typecheck in context | H | M | Phase 2 builds incrementally; fallback: restrict F-resolution scope |
| Until persistence through Lindenbaum detours fails | H | M | Add Until obligations explicitly to Lindenbaum seed |
| F_until_equiv axiom removal causes cascade | M | L | Check all downstream consumers before removing |
| Lindenbaum detour changes chain construction type | M | M | May need alternative chain interleaving x_content steps with detours |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Close Trivial Sorries and Finish Phase 2-3 Leftovers [COMPLETED]

**Goal**: Close the 4 annotated T-axiom sorries in SuccChainFMCS.lean. Resolve the `F_until_equiv` / `P_since_equiv` semantic gap. These are mechanical fixes that don't require new mathematical insight.

**Tasks**:
- [ ] Close sorry at SuccChainFMCS.lean:1267 — replace `sorry /- was: DerivationTree.axiom [] _ (Axiom.temp_t_future chi) -/` with the actual T-axiom invocation. Check the surrounding proof context to determine the exact term needed.
- [ ] Close sorry at SuccChainFMCS.lean:3804 — replace with `Axiom.temp_t_past chi` invocation
- [ ] Close sorry at SuccChainFMCS.lean:4071 — replace with `Axiom.temp_t_future chi` invocation
- [ ] Close sorry at SuccChainFMCS.lean:4214 — replace with `Axiom.temp_t_future neg_neg_bot` invocation
- [ ] Resolve `F_until_equiv_valid` sorry (Soundness.lean:770): Under reflexive semantics, F(ψ) includes `s = t` but `⊤ U ψ` requires `s > t`. Options: (a) remove `F_until_equiv`/`P_since_equiv` axioms entirely if not used in completeness path, (b) reformulate with explicit `s > t` guard, (c) prove using `Order.lt_succ` for discrete frames
- [ ] Resolve `P_since_equiv_valid` sorry (Soundness.lean:786): Mirror of above
- [ ] Verify `lake build` passes after all fixes

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — close 4 sorries
- `Theories/Bimodal/Metalogic/Soundness.lean` — resolve F_until_equiv / P_since_equiv
- `Theories/Bimodal/ProofSystem/Axioms.lean` — possibly remove/reformulate axioms

**Verification**:
- `lake build` succeeds
- The 4 `was: temp_t_future/past` annotations are gone
- `F_until_equiv` / `P_since_equiv` resolved (either sorry-free or axioms removed)

---

### Phase 2: Close the Main Sorries (F-Resolution on Critical Path) [BLOCKED]

**Goal**: Close the sorry-ful theorems on the completeness critical path. The critical path is:

```
completeness_over_Int
  → dovetailed_bundle_validity_implies_provability
    → dovetailed_bfmcs_restricted_temporally_coherent
      → DovetailedFMCS_forward_F (SORRY — DovetailedChain.lean:1300)
      → DovetailedFMCS_backward_P (SORRY — DovetailedChain.lean:1308)
```

**IMPORTANT**: Previous plan versions targeted `succ_chain_restricted_forward_F` (UltrafilterChain.lean), but that is NOT on the critical completeness path. The actual blockers are `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` in DovetailedChain.lean. The dovetailed chain is a different construction from the succ_chain.

**Blocker analysis**: `DovetailedFMCS_forward_F` is blocked by `forward_dovetailed_until_persists` (sorry, X-content propagation through Lindenbaum steps). The comment says this is an "architectural limitation" — X-vs-G content mismatch when Until obligations need to persist through Lindenbaum extension steps.

**Approach options**:
1. Fix the dovetailed chain's Until persistence (X-content propagation) — the original blocker
2. Implement seed consistency + Lindenbaum detour approach directly for the dovetailed chain
3. Reroute completeness through a different chain construction (e.g., DeterministicChain)

**Tasks**:
- [ ] Deep-read DovetailedChain.lean to understand `forward_dovetailed_until_persists` blocker and `dovetailed_fam_forward_F`
- [ ] Evaluate which approach is most viable for closing `DovetailedFMCS_forward_F`
- [ ] Implement the chosen approach
- [ ] Close `DovetailedFMCS_forward_F` (DovetailedChain.lean:1300)
- [ ] Close `DovetailedFMCS_backward_P` (DovetailedChain.lean:1308)
- [ ] Optionally also close `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` (UltrafilterChain.lean — not on critical path but reduces sorry count)

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` — close the 2 critical path sorries
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — optionally close 2 non-critical sorries
- Additional files as determined by approach

**Verification**:
- `#print axioms Bimodal.FrameConditions.completeness_over_Int` shows no `sorryAx`
- `DovetailedFMCS_forward_F` compiles with no sorry
- `DovetailedFMCS_backward_P` compiles with no sorry
- `lake build` succeeds

---

### Phase 3: Cleanup, Auxiliary Sorries, and Verification [IN PROGRESS]

**Goal**: Close auxiliary sorries, remove deprecated code, verify full completeness path is sorry-free transitively.

**Tasks**:
- [ ] Close or remove `restricted_chain_G_step` and `restricted_chain_H_step` in RestrictedTruthLemma.lean (may be unnecessary with reflexive coherence)
- [ ] Verify `bfmcs_restricted_temporally_coherent` is sorry-free (delegates to now-closed forward_F/backward_P)
- [ ] Verify `restricted_bundle_validity_implies_provability` is sorry-free
- [ ] Verify `completeness_over_Int` is sorry-free transitively (check all dependencies)
- [ ] Verify `discrete_completeness_fc` is sorry-free transitively
- [ ] Evaluate `CanonicalIrreflexivity.lean` — ExistsTask M M now holds under reflexive semantics; extract utilities if used elsewhere, delete rest
- [ ] Evaluate DovetailedChain.lean deprecated sorries — update or note as out of scope
- [ ] Update `always` operator comment in Formula.lean (middle conjunct now redundant)
- [ ] Update `weak_future`/`weak_past` documentation (now semantically identical to G/H)
- [ ] Add comments to seriality/density axioms noting derivability under reflexive semantics
- [ ] Run `lake build` on full project
- [ ] Count remaining sorries in `Theories/Bimodal/`; document which remain and why

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` — close or remove auxiliary sorries
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` — evaluate for deletion
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` — evaluate deprecated sorries
- Various files — docstring updates

**Verification**:
- `lake build` succeeds with zero errors
- `grep -r "sorry" Theories/Bimodal/` shows only expected remaining sorries (dense_completeness_fc, Soundness.lean frame-class architectural, task 82 items)
- `completeness_over_Int` and `discrete_completeness_fc` are fully sorry-free transitively

## Testing & Validation

- [ ] `lake build` compiles entire project with no errors after each phase
- [ ] The 4 `was: temp_t_future/past` sorries are closed (Phase 1)
- [ ] `F_until_equiv` / `P_since_equiv` resolved without breaking completeness path (Phase 1)
- [ ] `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` are sorry-free (Phase 2)
- [ ] `completeness_over_Int` is sorry-free transitively (Phase 3)
- [ ] `discrete_completeness_fc` is sorry-free transitively (Phase 3)
- [ ] No new sorries introduced (sorry count should decrease)
- [ ] Until/Since semantics still use strict witnesses

## Artifacts & Outputs

- `plans/28_completeness-closure.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (4 trivial sorries closed)
- Modified `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (2 main sorries closed)
- Modified `Theories/Bimodal/Metalogic/Soundness.lean` (F_until_equiv resolved)
- Potentially deleted `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

## Rollback/Contingency

- **Phase 1 failure**: The 4 T-axiom sorries should be mechanical; if they fail, the surrounding proof context has changed and needs investigation. F_until_equiv can be removed if not in completeness path.
- **Phase 2 failure**: If seed consistency argument doesn't typecheck, fall back to restricting F-resolution to formulas not involving Until. If Lindenbaum extension infrastructure is missing, build minimal version.
- **Phase 3 failure**: Auxiliary sorries can remain if they don't block completeness. Documentation updates are non-blocking.
- **General**: Each phase commits independently. Revert to any phase boundary if needed.
