# Implementation Plan: Fix Restricted Seed and Close Forward_F Sorries

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (builds on existing X-K/X-Det axioms and deterministic chain from plan 14)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/16_g-depth-resolution.md
- **Artifacts**: plans/16_restricted-seed-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The restricted chain seed in SuccExistence.lean includes `f_content(u)` which is provably inconsistent: when both `F(A)` and `F(neg A)` are in a consistent MCS `u`, the seed contains `{A, neg A}`. This plan removes `f_content(u)` from the seed, proves the corrected seed consistent, replaces the immediate F-resolution strategy with bounded deferral resolution using deferral disjunctions, and wires the result through to close the `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` sorries that block `completeness_over_Int`.

### Research Integration

Report 16 (g-depth resolution) established:
- The restricted seed is FALSE due to f_content (documented counterexample at SuccChainFMCS.lean:2170)
- Removing f_content and using deferral disjunctions is the correct fix
- The deterministic chain (sorry-free for Until/Since/G/H) is the strongest foundation
- Bounded F-nesting depth within deferralClosure ensures termination
- G-depth truth lemma and non-contrapositive backward_G are confirmed dead ends

## Goals & Non-Goals

**Goals**:
- Remove `f_content(u)` from `constrained_successor_seed_restricted` in SuccExistence.lean
- Remove `boundary_resolution_set` from the seed (also not needed; deferral disjunctions subsume it)
- Prove `constrained_successor_seed_restricted_consistent` (now trivially true: seed subset of u)
- Replace `restricted_forward_chain_F_resolves` (immediate resolution) with bounded deferral resolution
- Close `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` (lines 1258, 1266 in DovetailedChain.lean)
- Close the Until/Since truth lemma sorries (CanonicalConstruction.lean lines 940, 943)
- Ensure `lake build` passes at each phase boundary

**Non-Goals**:
- `dense_completeness_fc` (task 68 scope, needs dense canonical model)
- T-axiom sorries in SuccChainFMCS (lines 1248, 3996, 4263, 4406) -- these are unfixable under strict semantics and on non-critical paths
- Non-restricted seed consistency (SuccExistence.lean line 476, already documented as false under strict semantics)
- UltrafilterChain sorries (lines 3917, 3927) -- non-critical path

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing f_content breaks more downstream theorems than anticipated | H | M | Phase 1 identifies ALL references before editing; phase boundary `lake build` catches regressions |
| Bounded deferral resolution proof is harder than expected (well-foundedness) | H | M | Use existing `deferral_restricted_mcs_F_bounded` and `iter_F` infrastructure; F-nesting depth provides explicit termination measure |
| Wiring from restricted chain to DovetailedFMCS requires structural refactoring | M | M | Alternative: bypass dovetailed chain entirely and wire restricted chain directly to completeness |
| DRM maximality for deferral disjunctions requires new lemmas | M | L | DRM maximality already proven; disjunction property follows from negation completeness |
| boundary_resolution_set removal affects theorems beyond f_content removal | M | L | Audit all references in Phase 1; BRS elements are covered by deferral disjunctions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Audit and Remove f_content + boundary_resolution_set from Seed [NOT STARTED]

**Goal**: Remove the false components from the restricted seed and fix all compilation errors.

**Tasks**:
- [ ] Grep all references to `constrained_successor_seed_restricted` across the codebase
- [ ] Grep all references to `f_content_subset_constrained_successor_seed_restricted` and `boundary_resolution_set_subset_constrained_successor_seed_restricted`
- [ ] Edit `constrained_successor_seed_restricted` in SuccExistence.lean (line 356-357) to remove `boundary_resolution_set phi u` and `f_content u` from the union
- [ ] Update `mem_constrained_successor_seed_restricted_iff` to match the new 3-component seed
- [ ] Delete or comment out `f_content_subset_constrained_successor_seed_restricted` and `boundary_resolution_set_subset_constrained_successor_seed_restricted`
- [ ] Update docstrings on `constrained_successor_seed_restricted` to reflect the fix
- [ ] Fix all downstream compilation errors by replacing references to removed lemmas with `sorry` placeholders
- [ ] Run `lake build` and ensure it passes (with sorries at placeholder sites)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- seed definition, subset lemmas, membership lemma
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- downstream references to removed lemmas

**Verification**:
- `lake build` passes
- `constrained_successor_seed_restricted` no longer contains `f_content` or `boundary_resolution_set`

---

### Phase 2: Prove Seed Consistency and Rebuild Successor Properties [NOT STARTED]

**Goal**: Prove the corrected seed is consistent and establish the new successor properties (deferral-based F-step instead of immediate resolution).

**Tasks**:
- [ ] Prove `constrained_successor_seed_restricted_consistent`: the seed `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u)` is a subset of `u` (since `g_content ⊆ u` via DRM, `deferralDisjunctions ⊆ u` via F_unfold, and `p_step_blocking_restricted ⊆ u` already proven), hence consistent
- [ ] Replace `constrained_successor_restricted_f_content_persistence` with a new `constrained_successor_restricted_deferral_step`: if `F(psi) ∈ u`, then `psi ∈ v ∨ F(psi) ∈ v` where `v` is the successor (follows from deferral disjunction `psi ∨ F(psi)` in seed, hence in `v`, and DRM maximality)
- [ ] Prove `constrained_successor_restricted_F_deferral`: for `F(psi) ∈ chain(n)`, either `psi ∈ chain(n+1)` or `F(psi) ∈ chain(n+1)`
- [ ] Remove the sorry from `constrained_successor_seed_restricted_consistent` (line 2484 in SuccChainFMCS.lean)
- [ ] Run `lake build` and ensure it passes

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- seed consistency proof, new deferral step lemmas
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- possibly new lemmas about the simplified seed

**Verification**:
- `constrained_successor_seed_restricted_consistent` is sorry-free
- `lake build` passes
- New deferral step lemma is stated and proven

---

### Phase 3: Bounded Deferral Resolution for Forward_F [NOT STARTED]

**Goal**: Prove that F-obligations resolve within bounded steps using deferral disjunctions and bounded F-nesting depth.

**Tasks**:
- [ ] Define `restricted_forward_chain_F_deferral_or_resolve`: for `F(psi) ∈ chain(n)` with `psi ∈ deferralClosure(phi)`, either `psi ∈ chain(n+1)` (resolved) or `F(psi) ∈ chain(n+1)` (deferred)
- [ ] Prove bounded deferral termination: by induction on the "F-depth budget" `B - current_F_nesting_level(psi)` where `B = max_F_depth_in_closure(phi)`. Each deferral step either resolves `psi` directly or replaces `F(psi)` with `F(psi)` at the next position. After at most `B+1` steps, `iter_F(B+1)(psi)` exits `deferralClosure`, so the DRM cannot contain it, forcing resolution.
- [ ] Replace `restricted_forward_chain_F_resolves` with `restricted_forward_chain_forward_F_bounded`: given `F(psi) ∈ chain(n)` and `F(psi) ∈ deferralClosure(phi)`, there exists `m > n` with `psi ∈ chain(m)` and `m - n ≤ B + 1`
- [ ] Update `restricted_forward_chain_forward_F` to use the new bounded resolution
- [ ] Mirror for backward chain: `restricted_backward_chain_backward_P_bounded`
- [ ] Run `lake build` and ensure it passes

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- new bounded resolution theorems, updated forward_F/backward_P

**Verification**:
- `restricted_forward_chain_forward_F` is sorry-free
- `restricted_backward_chain_backward_P` is sorry-free (or analogous backward theorem)
- `build_restricted_tc_family` compiles (may still have sorries from fuel-bounded witnesses)
- `lake build` passes

---

### Phase 4: Wire Restricted Chain to Completeness [NOT STARTED]

**Goal**: Connect the sorry-free restricted chain forward_F/backward_P to close the `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` sorries in the completeness path.

**Tasks**:
- [ ] Determine wiring strategy: either (A) prove `DovetailedFMCS_forward_F` using the restricted chain machinery, or (B) replace the dovetailed chain in the completeness proof with the restricted chain
- [ ] Strategy A approach: For a dovetailed chain MCS `M` at position `t`, construct a DeferralRestrictedMCS from `M ∩ deferralClosure(root)`, build the restricted successor chain, show the restricted chain's forward_F implies the dovetailed chain's forward_F for formulas in deferralClosure
- [ ] Strategy B approach: Build a `construct_restricted_bfmcs_bundle` that uses `build_restricted_tc_family` instead of the dovetailed chain, wire to `restricted_bundle_validity_implies_provability`
- [ ] Close `DovetailedFMCS_forward_F` (DovetailedChain.lean line 1258)
- [ ] Close `DovetailedFMCS_backward_P` (DovetailedChain.lean line 1266)
- [ ] Run `lake build` and ensure it passes

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- close forward_F/backward_P sorries
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- possibly rewire completeness proof
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- possibly close Until/Since truth lemma sorries (lines 940, 943)

**Verification**:
- `DovetailedFMCS_forward_F` is sorry-free (or bypassed)
- `DovetailedFMCS_backward_P` is sorry-free (or bypassed)
- `completeness_over_Int` compiles with reduced sorry count
- `lake build` passes

---

### Phase 5: Close Remaining Truth Lemma Sorries and Cleanup [NOT STARTED]

**Goal**: Close the Until/Since truth lemma sorries in CanonicalConstruction.lean and clean up residual sorries from earlier phases.

**Tasks**:
- [ ] Close Until truth lemma sorry (CanonicalConstruction.lean line 940): requires forward_F (now available) + x_content propagation (available from X-K/X-Det deterministic chain)
- [ ] Close Since truth lemma sorry (CanonicalConstruction.lean line 943): mirror of Until
- [ ] Close or document RestrictedTruthLemma.lean sorries (lines 121, 168) if they are on the critical path
- [ ] Remove or update the fuel-bounded witness sorries (SuccChainFMCS.lean lines 5790, 5948, 6144) if they are still referenced
- [ ] Run full sorry audit: `grep -rn 'sorry' Theories/Bimodal/` and verify all remaining sorries are documented non-critical
- [ ] Run `lake build` and ensure clean build
- [ ] Update docstrings throughout to reflect the corrected approach

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- Until/Since truth lemma
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` -- restricted coherence sorries
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- cleanup fuel-bounded witness sorries

**Verification**:
- `completeness_over_Int` is sorry-free (or sorry count reduced to documented non-critical items)
- `lake build` passes cleanly
- All remaining sorries are on non-critical paths (T-axiom, dense completeness)

## Testing & Validation

- [ ] `lake build` passes at each phase boundary
- [ ] `constrained_successor_seed_restricted_consistent` is sorry-free after Phase 2
- [ ] `restricted_forward_chain_forward_F` is sorry-free after Phase 3
- [ ] `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` are sorry-free after Phase 4
- [ ] `completeness_over_Int` sorry-free status verified after Phase 5
- [ ] `grep -c sorry Theories/Bimodal/` shows reduced sorry count vs baseline

## Artifacts & Outputs

- plans/16_restricted-seed-fix.md (this file)
- Modified source files in Theories/Bimodal/Metalogic/Bundle/ and Theories/Bimodal/Metalogic/Algebraic/
- summaries/16_restricted-seed-fix-summary.md (after implementation)

## Rollback/Contingency

- All changes are in Lean source files tracked by git; `git stash` or `git checkout` reverts to the current state
- If the bounded deferral resolution proof (Phase 3) encounters unforeseen difficulties, the intermediate state after Phase 2 (correct seed, sorry-free consistency) is still a strict improvement over the current false theorem
- If wiring to completeness (Phase 4) requires more structural changes than anticipated, document the gap and create a follow-up task
