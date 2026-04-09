# Implementation Plan: Close BXCanonical Sorries via BX10 + Chain-Specific Eventuality

- **Task**: 86 - Close BXCanonical completeness sorries
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: reports/08_bxle-linearity-research.md
- **Artifacts**: plans/08_chain-eventuality-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close sorry sites in the BXCanonical completeness proof via two distinct strategies: (1) replace the until_induction-based approach in WitnessSeed.lean with a direct BX10/BX10' contradiction argument (2 sorries, low effort), and (2) restructure Frame.lean eventuality resolution to use chain-specific guards instead of universal quantification over all BXPoints (4 sorries, high effort). The Completeness.lean sorry depends on both the Frame.lean sorries (for Until/Since) and the CanonicalEmbedding.lean sorry (for G/H/box), so it is addressed last. Definition of done: `lake build` succeeds with strictly fewer sorries in `Theories/Bimodal/Metalogic/BXCanonical/`.

### Research Integration

- **Report 08** (bxle-linearity-research.md): Proved global bx_le linearity is mathematically impossible from BX axioms. Identified BX10-based shortcut for WitnessSeed.lean sorries. Recommended chain-specific eventuality resolution (Approach A) for Frame.lean sorries. Confirmed CanonicalEmbedding.lean sorry is orthogonal to Frame.lean sorries.

### Prior Plan Reference

Prior plan 07 attempted a proof-theoretic route for CanonicalEmbedding.lean:418 (imp Case B). Phase 1 reached NO-GO after 3 hours: the direct proof-theoretic decomposition does not work because `valid (psi -> chi)` with `not valid psi` and `not valid chi` cannot be reduced to simpler valid formulas without semantic machinery. Effort calibration: the proof-theoretic direction consumed 3 hours with no progress, confirming that semantic/canonical-model approaches are needed. Prior plans 01-06 explored combined F-seed, constant-history, and FMP bridge approaches -- all invalidated.

### Roadmap Alignment

No ROAD_MAP.md found (file does not exist at expected path).

## Goals & Non-Goals

**Goals**:
- Close 2 WitnessSeed.lean sorries (lines 450, 569) using BX10/BX10' contradiction
- Define chain-specific eventuality resolution lemmas for Until/Since
- Close 4 Frame.lean sorries (lines 646, 668, 683, 697) via chain-specific guards
- Reduce total sorry count in `Theories/Bimodal/Metalogic/BXCanonical/`

**Non-Goals**:
- Close the CanonicalEmbedding.lean:418 sorry (imp Case B -- requires separate G/H backward truth bridge, orthogonal to this plan)
- Close the Completeness.lean:153 sorry (depends on both Frame.lean and CanonicalEmbedding.lean being sorry-free)
- Prove global bx_le linearity (mathematically impossible per report 08)
- Re-add temp_linearity axiom (goes against BX refactoring philosophy)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BX10 approach for WitnessSeed requires definitional unfolding that Lean resists | L | L | Existing pattern at lines 126-128 already uses `F(psi) = neg(G(neg psi))` successfully; same pattern applies |
| Chain-specific guard definitions don't compose with existing truth lemma infrastructure | H | M | Phase 2 designs the API before committing to implementation; go/no-go gate at end of Phase 2 |
| Chain-specific Until proof requires constructing the chain explicitly in Frame.lean | H | M | Leverage existing dovetailed chain infrastructure from `Metalogic/Algebraic/DovetailedChain.lean` |
| Frame.lean sorry signatures change, breaking downstream consumers | M | L | Check all imports of Frame.lean lemmas before modifying signatures; preserve backward compatibility where possible |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Close WitnessSeed.lean Sorries via BX10/BX10' [COMPLETED]

**Goal**: Replace the sorry'd until_induction proof with a direct BX10 contradiction argument, closing 2 sorries.

**Tasks**:
- [ ] In `until_witness_seed_consistent` (WitnessSeed.lean:342), replace lines 409-463 (the entire until_induction block from "Apply until_induction" comment through the final `exact`) with a BX10 contradiction:
  - Derive `F(psi) in M` from `h_U : phi.untl psi in M` using `theorem_in_mcs h_mcs (until_imp_F phi psi)` + `SetMaximalConsistent.implication_property`
  - Note `Formula.some_future psi = (psi.neg.all_future).neg` (definitional via `Formula.some_future`)
  - Apply `set_consistent_not_both h_mcs.1 (psi.neg.all_future) h_G_neg_psi <F_proof>` (same pattern as line 128)
- [ ] In `since_witness_seed_consistent` (WitnessSeed.lean:471), replace lines 535-582 (the entire since_induction block) with a BX10' contradiction:
  - Derive `P(psi) in M` from `h_S : phi.snce psi in M` using `since_imp_P`
  - Note `Formula.some_past psi = (psi.neg.all_past).neg` (definitional)
  - Apply `set_consistent_not_both h_mcs.1 (psi.neg.all_past) h_H_neg_psi <P_proof>`
- [ ] Verify `lake build` succeeds with zero new errors
- [ ] Verify `canonical_forward_U` and `canonical_backward_S` in CanonicalFrame.lean are now sorry-free (they depend solely on the seed consistency theorems)
- [ ] Remove stale comments referencing until_induction/since_induction in both proofs

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- replace sorry blocks at lines 450 and 569

**Verification**:
- `lake build` succeeds
- `grep -c sorry Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` decreases by 2
- `grep sorry Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` shows no sorries (transitive closure)

---

### Phase 2: Design Chain-Specific Eventuality Resolution API [COMPLETED]

**Goal**: Define the type signatures and proof obligations for chain-specific Until/Since resolution that avoids universal quantification over all BXPoints.

**Tasks**:
- [x] Study the existing dovetailed chain infrastructure in `Metalogic/Algebraic/DovetailedChain.lean` and `Metalogic/Bundle/UntilSinceCoherence.lean` -- identify reusable components
- [x] Study `backward_until_from_step` in UntilSinceCoherence.lean (line 111) -- this already proves backward Until for FMCS Int chains given a step transfer lemma; determine if Frame.lean can delegate to this
- [x] Design new lemma signatures for Frame.lean that replace universal BXPoint quantification with chain-specific quantification
- [x] Determine which option is compatible with the TruthLemma.lean consumers of Frame.lean lemmas -- check `until_iff_mcs` and `since_iff_mcs` in TruthLemma.lean
- [x] **Go/no-go gate**: NO-GO. Chain-specific API requires rewriting TruthLemma.lean AND constructing new chain infrastructure. See findings below.

**Timing**: 2 hours (actual: ~1.5 hours)

**Depends on**: 1

**Go/No-Go Decision: NO-GO**

Analysis findings:

1. **DovetailedChain.lean is DEPRECATED** and has 6 sorries from the same X-vs-G mismatch (Lindenbaum seeds provide bot-Until-level consistency but Until persistence through chain steps requires g_content-level propagation). Cannot be reused.

2. **`backward_until_from_step` in UntilSinceCoherence.lean** requires a step transfer hypothesis (`φ U ψ ∈ fam.mcs(r+1) ∧ φ ∈ fam.mcs(r) → φ U ψ ∈ fam.mcs(r)`) that is itself blocked by the same X-vs-G mismatch. It operates on FMCS Int chains, not BXPoints.

3. **Option A (chain-parameterized lemmas)** requires: (a) constructing an Int -> BXPoint chain with g_content successor properties, (b) proving Until formula propagation along the chain (blocked by X-vs-G mismatch), (c) rewriting TruthLemma.lean to use chain-specific truth lemma instead of global bx_le.

4. **Option B (weakened guards)** doesn't help: the guard weakening still requires proving that intermediate points on a chain satisfy the guard, which needs Until propagation.

5. **TruthLemma.lean compatibility**: `until_iff_mcs` and `since_iff_mcs` are NOT used by CanonicalEmbedding.lean or Completeness.lean. They exist as standalone results. So rewriting them is safe from a dependency standpoint. However, the rewrite would need new chain infrastructure that doesn't exist.

6. **Backward direction analysis**: Even `bx_until_backward` (proving φ U ψ ∈ w from a semantic witness) is blocked. The contradiction approach requires linearity of bx_le on intervals (to show that a backward witness u from P(¬(φ U ψ)) ∈ v lies in [w,v)). The direct approach yields only F(φ U ψ) ∈ w (from h_content duality + BX4'), not φ U ψ ∈ w.

7. **Effort estimate for chain-specific approach**: 20+ hours minimum (construct chain builder, prove chain properties, prove Until propagation on chains, restructure TruthLemma.lean). Far exceeds the 12-hour budget.

**Conclusion**: Phases 3-4 are BLOCKED. The Frame.lean sorries require fundamentally new infrastructure (chain construction with Until propagation) that is blocked by the same X-vs-G mismatch that blocks DovetailedChain.lean. No known approach can close these sorries within the effort budget.

**Files to modify**:
- None (design phase -- produces API specification documented in this plan)

**Verification**:
- [x] Clear API design analysis documented
- [x] Compatibility analysis with TruthLemma.lean consumers documented
- [x] Go/no-go decision recorded: NO-GO

---

### Phase 3: Implement Chain-Specific Eventuality Resolution [BLOCKED]

**Goal**: Implement the chain-specific Until/Since resolution lemmas and close the 4 Frame.lean sorries.

**Tasks**:
- [ ] Implement forward Until chain resolution: given `phi U psi in (chain n)` with `psi not-in (chain n)`, construct witness `m > n` with `psi in (chain m)` and guard `phi in (chain k)` for `n <= k < m`
  - Use BX10 to get `F(psi) in (chain n)`, then `bx_forward_witness` to get a BXPoint v with `psi in v`
  - Use BX5 (self-accumulation: `phi U psi -> (phi and (phi U psi)) U psi`) to propagate the Until formula along the chain
  - At each chain step, BX9 gives `phi or psi in (chain k)` -- if `psi in (chain k)` we found our witness; otherwise `phi in (chain k)` and the Until propagates
- [ ] Implement backward Until chain resolution: given chain with `psi in (chain m)` and guard on `[n, m)`, derive `phi U psi in (chain n)`
  - Leverage `backward_until_from_step` from UntilSinceCoherence.lean if chain structure is compatible
  - Otherwise prove directly using BX8 (reflexive Until introduction) + backward induction on chain steps
- [ ] Implement forward Since chain resolution (mirror of forward Until using h_content, BX5', BX9', BX10')
- [ ] Implement backward Since chain resolution (mirror of backward Until)
- [ ] Connect chain-specific lemmas to Frame.lean sorry sites:
  - Either replace the current sorry'd lemmas with chain-parameterized versions
  - Or prove the current signatures by instantiating the chain-specific lemmas with a suitable chain
- [ ] Verify `lake build` succeeds after each lemma

**Timing**: 6 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- close 4 sorries (lines 646, 668, 683, 697)
- Possibly new file `Theories/Bimodal/Metalogic/BXCanonical/ChainEventuality.lean` if chain-specific lemmas need their own module

**Verification**:
- `lake build` succeeds
- `grep -c sorry Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` decreases by 4
- Downstream consumers (TruthLemma.lean) continue to compile

---

### Phase 4: Integration and Sorry Audit [PARTIAL]

**Goal**: Verify all changes compose correctly, update documentation, and audit remaining sorry count.

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Run `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` and document remaining sorries
- [ ] Update module docstrings in Frame.lean to reflect sorry-free status of eventuality resolution
- [ ] Update module docstrings in WitnessSeed.lean to reflect BX10-based proof strategy
- [ ] Update comments in Completeness.lean:149 to reflect which sorries are now closed and what remains
- [ ] If Frame.lean sorries are closed: update TruthLemma.lean comments that reference Frame.lean sorry status
- [ ] Verify no regressions in other BXCanonical modules (BXCanonical.lean, CanonicalEmbedding.lean)

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- docstring updates
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- docstring updates
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- comment updates
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- comment updates

**Verification**:
- `lake build` succeeds with zero errors
- Sorry audit shows expected remaining count (Completeness.lean:153 + CanonicalEmbedding.lean:418 if Frame.lean is closed; or document partial progress)
- All docstrings accurately reflect current proof status

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` returns 0 after Phase 1
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` returns 0 after Phase 3 (or documents remaining if partial)
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` shows reduced count compared to current 6 sorries
- [ ] No regression in existing sorry-free proofs (fragment_completeness, G_iff_mcs, H_iff_mcs, box_iff_mcs)

## Artifacts & Outputs

- `plans/08_chain-eventuality-plan.md` (this file)
- `summaries/08_chain-eventuality-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (2 sorries closed)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (4 sorries closed, or partial)
- Possibly new: `Theories/Bimodal/Metalogic/BXCanonical/ChainEventuality.lean`

## Rollback/Contingency

- Phase 1 is independent and low-risk. If it succeeds but Phase 3 fails, the 2 WitnessSeed.lean sorry closures are preserved as net progress.
- Phase 2 has a go/no-go gate. If the chain-specific API cannot integrate with TruthLemma.lean without major rewrites, the plan is marked [PARTIAL] after Phase 1 with a description of the API design obstacle.
- Phase 3 can be split: forward Until/Since are likely easier than backward Until/Since. If only forward cases close, mark [PARTIAL] with 2 of 4 Frame.lean sorries closed.
- All changes are additive except the sorry replacements. Git provides full rollback via `git revert` on phase commits.
