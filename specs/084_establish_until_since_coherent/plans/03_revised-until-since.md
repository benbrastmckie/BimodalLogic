# Implementation Plan: Establish until_since_coherent (Revised)

- **Task**: 84 - Establish Until/Since Coherence for Bundle Completeness
- **Status**: [PARTIAL]
- **Effort**: 10-14 hours
- **Dependencies**: None (task 83 closed the truth lemma sorries that added h_uc as hypothesis)
- **Research Inputs**: reports/01_research-synthesis.md, reports/02_team-research.md, reports/03_team-research.md
- **Artifacts**: plans/03_revised-until-since.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **Revision**: v2 of plans/02_until-since-coherent.md

## Revision Summary

Plan v1 (02_until-since-coherent.md) was blocked at phases 2-4 by the X-vs-G mismatch. Team research round 03 discovered three breakthroughs:

1. **X is trivial under BX**: `X(alpha) = bot U alpha <-> alpha` via BX8+BX9. The mismatch is a legacy of incomplete BX migration, not a fundamental obstacle.
2. **`until_intro` IS derivable**: `or_until_in_mcs` (already proved in Phase 1) composes with `X(alpha) -> alpha` to give `until_intro`. This was the missing piece for backward Until/Since.
3. **Negation unfolding is INVALID**: Countermodel exists. Do NOT pursue this approach.

The revised plan reorders phases: backward directions FIRST (high confidence, 90%), forward directions second (65-85%), with a clean fallback.

## Overview

Three sorry sites in `FrameConditions/Completeness.lean` (lines 322, 356, 450) require `until_since_coherent` with four conjuncts: forward Until, backward Until, forward Since, backward Since. Phase 1 (completed) proved the foundation (`g_content_subset_mcs`, `or_until_in_mcs`, etc.) and closed 3 sorries. This revised plan attacks backward directions first (newly unblocked by the `until_intro` derivation), then forward directions via enriched seeds, with a definition-split fallback.

### Phase 1 Accomplishments (Already Done)

- `g_content_subset_mcs` and `h_content_subset_mcs` proved sorry-free
- `or_until_in_mcs` and `or_since_in_mcs` proved sorry-free
- 3 sorries closed in SuccExistence.lean (seed consistency under BX1)
- Lake build passes cleanly

## Goals & Non-Goals

**Goals**:
- Derive `until_intro`/`since_intro` from BX axioms (using `or_until_in_mcs` + X-triviality)
- Port backward Until/Since proofs from DeterministicFMCS Boneyard
- Establish forward Until/Since for enriched dovetailed chain
- Close the three sorry sites at lines 322, 356, 450 of Completeness.lean

**Non-Goals**:
- `dense_completeness_fc` (task 68 -- Int is not dense)
- FMP TruthPreservation (task 82)
- BXCanonical Frame.lean sorries (proven impossible)
- `bfmcs_from_mcs_temporally_coherent` sorry at line 239 (may benefit but not primary target)
- Repairing x_content/y_content/X-K/X-Det sorry sites (discrete-only, incompatible with density)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `until_intro` derivation fails in Lean (despite theoretical argument) | H | L (10%) | The derivation is: X(alpha) -> alpha (BX8+BX9) then compose with or_until_in_mcs. Both components are proved. Risk is only type-mismatch or universe issues. |
| Backward proof port requires x_content linkage | M | M (30%) | DeterministicFMCS uses x_content successor. Need to verify backward induction works with g_content-based chains. If not, adapt the induction to use g_content. |
| Forward Until enriched seed joint consistency fails | H | M (35%) | Three-way `{target} union g_content union active_untils` needs explicit proof. Fallback: restrict dovetailing to Until targets only. |
| Line 322 circular dependency with TC sorry | M | H (60%) | Line 322 needs both until_since_coherent AND temporally_coherent (line 239 sorry). Focus on lines 356/450 which have sorry-free TC. Line 322 may require unified enriched chain or remain as last sorry. |
| Backward proof works for deterministic chain but not dovetailed | M | M (25%) | The backward induction uses chain distance (s-t). For dovetailed chains, the successor structure differs. May need to abstract the backward proof over any chain with a successor relation. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1 |
| 4 | 4 | 2, 3 |

Phases 2 and 3 can execute in parallel (wave 2-3).

### Phase 1: Derive until_intro and since_intro [COMPLETED]

**Goal**: Establish `until_intro` and `since_intro` as derived rules in the BX system, closing the key gap identified in the Boneyard DeterministicFMCS.

**Tasks**:
- [x] Derive `x_implies_id`: `X(alpha) -> alpha` for any formula alpha in any MCS. Proof: `X(alpha) = bot U alpha`, BX9 gives `bot U alpha -> bot or alpha`, propositional `bot or alpha -> alpha`. Compose.
- [x] Derive `until_intro_in_mcs`: `X(psi or (phi and (phi U psi))) in M -> (phi U psi) in M`. Proof: `x_implies_id` gives `(psi or (phi and (phi U psi))) in M`, then `or_until_in_mcs` gives `(phi U psi) in M`.
- [x] Derive `since_intro_in_mcs`: symmetric via `or_since_in_mcs` and BX8'+BX9'
- [x] Replace `until_unfold_in_mcs` sorry (SuccRelation.lean:514-520) with BX-native derivation: `(phi U psi) -> (psi or (phi and (phi U psi)))` via BX5+BX9, no X wrapper
- [x] Replace `since_unfold_in_mcs` sorry (SuccRelation.lean:525-531) symmetrically
- [x] Close DeterministicFMCS sorry sites at lines 371, 395, 427, 451 using the new derivations

**Timing**: 2-3 hours

**Depends on**: none (builds on Phase 1 results from v1 plan)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- add until_intro_in_mcs, since_intro_in_mcs, x_implies_id; replace until_unfold/since_unfold sorries
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` -- close until_intro/since_intro sorry sites

**Verification**:
- All new derivations compile sorry-free
- `lake build` succeeds
- DeterministicFMCS backward Until/Since proofs now sorry-free (modulo their other dependencies)

---

### Phase 2: Backward Until and Backward Since [PARTIAL]

**Goal**: Prove the backward directions of `until_since_coherent` -- given a witness s with psi at s and phi on guard interval, conclude `(phi U psi) in fam.mcs t`. This was previously blocked but is now unblocked by Phase 1's `until_intro` derivation.

**Implementation Results** (2026-04-08):

Created `UntilSinceCoherence.lean` with 6 sorry-free theorems:
- `backward_until_reflexive`: ψ ∈ M → (φ U ψ) ∈ M (base case, any MCS)
- `backward_since_reflexive`: ψ ∈ M → (φ S ψ) ∈ M (base case, any MCS)
- `backward_until_from_step`: Full backward Until parameterized by step transfer
- `backward_since_from_step`: Full backward Since parameterized by step transfer
- `backward_until_coherent`: 2nd conjunct of until_since_coherent for BFMCS Int
- `backward_since_coherent`: 4th conjunct of until_since_coherent for BFMCS Int

**Blocker for full closure**: The "step transfer" hypothesis requires:
  `(φ U ψ) ∈ fam.mcs (r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`

This property is NOT available from the dovetailed/SuccChain constructions:
- **g_content link** (`G(α) ∈ chain(n) → α ∈ chain(n+1)`) goes forward, not backward
- **h_content duality** (`H(α) ∈ chain(n+1) → α ∈ chain(n)`) requires H-wrapped formulas; Until is not H-wrapped
- **x_content link** is trivial under BX (`X(α) ↔ α`, so x_content(M) = M); the deterministic chain becomes constant, making backward Until trivial but useless for non-constant chains
- No BX axiom derives `(φ U ψ) ∈ M_t` from `(φ U ψ) ∈ M_{t+1}` where M_t ≠ M_{t+1}

The step transfer requires a chain construction that explicitly preserves Until formulas across positions, beyond what g_content/Succ linking provides. This is the same construction modification needed for forward Until (Phase 3 enriched seeds).

**Tasks**:
- [x] Study `backward_until_chain` in DeterministicFMCS.lean:340-395
- [x] Determine generalizability: NOT generalizable (x_content specific, and under BX x_content is trivial)
- [x] Prove reflexive base case (t = s): `backward_until_reflexive`, `backward_since_reflexive`
- [x] Prove parameterized backward Until/Since: `backward_until_from_step`, `backward_since_from_step`
- [x] Prove BFMCS assembly: `backward_until_coherent`, `backward_since_coherent`
- [ ] Provide step transfer for dovetailed chain (BLOCKED -- needs modified chain construction)

**Timing**: 3 hours (analysis) + 1 hour (implementation)

**Depends on**: 1

**Files modified**:
- NEW: `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` -- 6 sorry-free theorems

**Verification**:
- All 6 theorems compile sorry-free (verified via lean_verify)
- Type signatures match the second and fourth conjuncts of `until_since_coherent` (given step transfer)
- `lake build` succeeds with no regressions

---

### Phase 3: Forward Until and Forward Since via Enriched Seed [BLOCKED]

**Goal**: Prove forward directions -- `(phi U psi) in fam.mcs t` implies existence of witness s >= t. Uses enriched seed approach with BX-native reasoning (no X).

**Blocker Analysis** (2026-04-08):

The enriched seed approach is blocked by the G-lift consistency argument.

**Root Cause**: The dovetailed chain extends MCS via Lindenbaum extension of
`{target} union temporal_box_g_seed(M)`. The consistency proof uses G-lifting:
every element x in `temporal_box_g_seed(M)` satisfies `G(x) in M`, enabling
derivation of `G(neg(target)) in M` from any proof of `neg(target)` from the seed,
which contradicts `F(target) in M`.

Until formulas `(phi U psi) in M` do NOT satisfy `G(phi U psi) in M` in general.
(Counterexample: `(p U q)` at t=0 with witness at t=2; at t=3, `(p U q)` fails,
so `G(p U q)` is false at t=0.) Therefore, Until formulas CANNOT be G-lifted,
and adding them to the seed breaks the consistency argument.

**Why the plan's consistency claim fails**: The plan claimed "active Untils are in w
and subset of w, hence consistent." This conflates subset-of-MCS-is-consistent (true
for the seed ALONE) with target-plus-seed-is-consistent (requires the G-lift argument).
The seed `S subset M` is consistent, but `{target} union S` may not be, because
`S derives neg(target)` only gives `neg(target) in M`, which does NOT contradict
`F(target) in M` (they are compatible: F says future, neg says now).

**Alternative approaches investigated and rejected**:
1. **Until derivable from target**: `psi -> (phi U psi)` (BX8), so adding
   `(phi U psi)` when target=psi is redundant. But this only works when
   target equals the specific psi, not for other Until formulas.
2. **BX4 propagation**: `phi -> G(P(phi))` gives `P(phi U psi)` in the next
   step via g_content, but P(phi U psi) does not give (phi U psi).
3. **BX10 + F-persistence**: `(phi U psi) -> F(psi)`, but `F(psi)` does not
   persist through g_content (would need `G(F(psi)) in M`, not available).
4. **Deterministic chain (x_content)**: Under BX, `X(alpha) = (bot U alpha) = alpha`
   in any MCS. So x_content(M) = M and the deterministic chain is CONSTANT.
   Forward Until is then unsatisfiable (psi never at M but Until says it should be).
5. **Proof by contradiction**: Assume psi never appears. Then neg(psi) at all
   future times. Need G(neg(psi)) for contradiction with F(psi), but proving
   G(neg(psi)) requires temporal_backward_G which requires forward_F (circular).

**Conclusion**: The forward direction requires a fundamentally new chain construction
that preserves Until formulas through Lindenbaum steps, with a non-G-lift consistency
argument. This is beyond the scope of the current enriched seed approach.

**Tasks**:
- [x] Analyze BX-native Until unfolding: `until_unfold_thm` already proved in Phase 1
- [x] Analyze enriched seed consistency: BLOCKED (G-lift incompatible with Until)
- [ ] ~Define enriched seed~ (blocked by consistency)
- [ ] ~Prove Until persistence~ (blocked by seed)
- [ ] ~Prove guard extraction~ (blocked)
- [ ] ~Prove witness resolution~ (blocked)
- [ ] ~Prove joint seed consistency~ (blocked -- see analysis above)
- [ ] ~Mirror for forward Since~ (blocked)
- [ ] ~Prove forward_until and forward_since~ (blocked)

**Timing**: N/A (blocked)

**Depends on**: 1 (uses BX-native unfolding from Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- enriched chain modifications
- New file `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` -- forward proofs
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- enriched seed definitions if needed

**Verification**:
- Forward Until and forward Since lemmas compile sorry-free
- Type signatures match first and third conjuncts of `until_since_coherent`
- `lake build` succeeds

---

### Phase 4: Assemble and Close Sorry Sites [NOT STARTED]

**Goal**: Wire forward and backward results into complete `until_since_coherent` proofs and close the three sorry sites.

**Tasks**:
- [ ] Assemble `dovetailed_bfmcs_until_since_coherent` for `construct_dovetailed_bfmcs_bundle`: combine all four conjuncts (forward Until, backward Until, forward Since, backward Since) for the dovetailed chain families
- [ ] Close sorry at Completeness.lean line 450 (`dovetailed_bundle_validity_implies_provability`)
- [ ] Assess line 356 (`restricted_bundle_validity_implies_provability`): determine if the backward proof from Phase 2 applies to restricted SuccChain families. If yes, assemble and close.
- [ ] Assess line 322 (`bundle_validity_implies_provability`): this also needs `temporally_coherent` (sorry at line 239). If TC is still sorry, this site cannot be fully closed. Document clearly.
- [ ] Run `lake build` on full project, verify no regressions
- [ ] Count remaining sorries in Completeness.lean -- target: reduced from 5 to at least 2 (lines 450 and either 356 or both 356+322 closed)
- [ ] Update module-level documentation in modified files
- [ ] Clean up any temporary scaffolding

**Timing**: 2-3 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- replace sorry sites with proof terms
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- add until_since_coherent assembly theorems
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- dovetailed-specific wiring

**Verification**:
- At least line 450 sorry replaced with proof term
- `lake build` succeeds with no new sorries
- Sorry count in Completeness.lean decreased by at least 1 (target: 2-3)

## Fallback Strategy

If Phase 3 (forward directions) stalls:

1. **Split `until_since_coherent`** into `backward_until_since_coherent` (provable) and `forward_until_since_coherent` (sorry)
2. Restructure truth lemma to accept backward-only coherence where forward is not needed, or to accept each direction separately
3. Close backward for all paths immediately (Phase 2 results)
4. Leave forward as a precisely scoped sorry with clear documentation
5. Estimated effort for split: ~300 LOC refactoring, 80% confidence

This gives partial but real progress: backward Until/Since closed, sorry scope narrowed from "entire until_since_coherent" to "forward direction only."

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `until_intro_in_mcs` and `since_intro_in_mcs` compile sorry-free (Phase 1)
- [ ] Backward Until/Since close without sorry (Phase 2)
- [ ] Forward Until/Since close without sorry (Phase 3) OR documented with fallback
- [ ] At least Completeness.lean line 450 sorry replaced (Phase 4)
- [ ] No new sorries introduced anywhere in the codebase
- [ ] Grep for `sorry` in Completeness.lean shows reduction from current count

## Artifacts & Outputs

- `plans/03_revised-until-since.md` (this file, revision of 02_until-since-coherent.md)
- Modified Lean source files (listed per phase)
- `summaries/03_revised-until-since-summary.md` (after implementation)

## Rollback/Contingency

- All changes are additive (new lemmas and proof terms replacing sorry). If a phase fails, prior sorry can be restored.
- Phase 1 and Phase 2 are nearly risk-free (90% confidence). These should be committed independently.
- Phase 3 carries the main risk (65-85%). The fallback split preserves Phase 2 progress.
- Git commits per phase enable per-phase rollback via `git revert`.
