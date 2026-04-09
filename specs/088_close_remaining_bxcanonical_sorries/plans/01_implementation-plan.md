# Implementation Plan: Close Remaining BXCanonical Sorries via Axiom Restoration

- **Task**: 88 - Close remaining 6 BXCanonical sorries
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (self-contained axiom restoration)
- **Research Inputs**: specs/088_close_remaining_bxcanonical_sorries/reports/01_team-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The BX axiom system is incomplete for linear time: `temp_linearity` was removed during the BX refactoring based on incorrect reasoning that BX7 subsumes it, but `LinearityDerivedFacts.lean` contains an explicit 3-point counterexample proving it is NOT derivable from BX1-BX10. Re-adding `temp_linearity` (and `F_until_equiv`) as axioms restores the standard Burgess-Xu system. This unblocks all 6 sorries: 4 in Frame.lean (eventuality resolution needing bx_le linearity), 1 in CanonicalEmbedding.lean (imp Case B needing non-constant histories), and 1 in Completeness.lean (downstream of the other 5). The plan is complete when `lake build` produces zero sorries in the BXCanonical module.

### Research Integration

The team research report (4 teammates, all opus) reached 95% consensus that the axiom system is incomplete. Key findings integrated:
- `temp_linearity_valid` is already proved sorry-free in `Soundness.lean:285`
- `LinearityDerivedFacts.lean:78` has `sorry /- temp_l removed in BX -/` marking the removal
- The ConservativeExtension module has 5 sorry markers tagged "temp_linearity removed in BX"
- `DovetailedChain.lean:572` and `FiniteDeferral.lean:48` have sorry markers for "F_until_equiv removed in BX"
- Teammate A identified the cascade: temp_linearity -> bx_le linearity -> 4 Frame.lean sorries -> CanonicalEmbedding -> Completeness

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `temp_linearity` and `F_until_equiv` (with past duals) back to the `Axiom` inductive type
- Prove soundness for the restored axioms (already have `temp_linearity_valid`)
- Derive bx_le linearity (totality) from temp_linearity
- Close 4 Frame.lean sorries (until/since eventuality resolution and backward proofs)
- Close 1 CanonicalEmbedding.lean sorry (imp Case B via non-constant histories)
- Close 1 Completeness.lean sorry (full canonical model embedding)
- Fix downstream sorry markers in ConservativeExtension, DovetailedChain, FiniteDeferral

**Non-Goals**:
- Redesigning the BXCanonical architecture (chain construction approach)
- Proving decidability or other metalogical properties
- Addressing sorries outside the BXCanonical module not related to this axiom gap

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| temp_linearity alone insufficient for bx_le linearity | H | L | Research shows F_until_equiv bridges F/U; add both axioms |
| Axiom addition breaks existing pattern matches | M | H | Systematic grep for `cases h with` on Axiom; add new arms |
| CanonicalEmbedding imp Case B harder than expected | M | M | Two-point history construction is standard; go/no-go at Phase 4 |
| ConservativeExtension sorries require non-trivial proofs | M | M | Many are "Extsorry" stubs; soundness proof pattern already exists |
| lake build time makes iteration slow | L | H | Use `lake build Bimodal.Metalogic.BXCanonical.Frame` for focused builds |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Restore Axioms and Prove Soundness [NOT STARTED]

**Goal**: Add `temp_linearity`, `F_until_equiv`, and their past duals to the `Axiom` inductive type and prove their soundness.

**Tasks**:
- [ ] Add `temp_linearity` constructor to `Axiom` in `Axioms.lean`: `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)`
- [ ] Add `temp_linearity_past` constructor (past dual): `P(phi) and P(psi) -> P(phi and psi) or P(phi and P(psi)) or P(P(phi) and psi)`
- [ ] Add `F_until_equiv` constructor: `F(phi) -> top U phi`
- [ ] Add `P_since_equiv` constructor: `P(phi) -> top S phi`
- [ ] Update docstring axiom count (33 -> 37) and add BX11/BX11'/BX12/BX12' descriptions
- [ ] Add soundness case arms in `axiom_base_valid` (`Soundness.lean:732`): route to `temp_linearity_valid` (already proved at line 285)
- [ ] Add soundness case arms in `axiom_valid_dense` and `axiom_valid_discrete`
- [ ] Write `F_until_equiv_valid` and `P_since_equiv_valid` soundness proofs in `SoundnessLemmas.lean`
- [ ] Add case arms in `FrameConditions/Soundness.lean` if it pattern-matches on Axiom
- [ ] Update `LinearityDerivedFacts.lean:78`: replace `sorry /- temp_l removed in BX -/` with actual derivation using the restored axiom constructor
- [ ] Fix ConservativeExtension sorries: `Substitution.lean:205`, `Lifting.lean:208,236,476`, `ExtDerivation.lean:63,124` -- replace `Extsorry`/`sorry` markers with actual constructor invocations
- [ ] Run `lake build` and fix any remaining pattern-match exhaustiveness errors across all files that case-split on `Axiom`

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- add 4 new constructors
- `Theories/Bimodal/Metalogic/Soundness.lean` -- add case arms in 3 theorems
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- add F_until_equiv/P_since_equiv validity
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- close sorry
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` -- fix sorry
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` -- fix 3 sorries
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` -- fix sorry + add constructor
- Any other files that pattern-match on `Axiom` (detected by build errors)

**Verification**:
- `lake build` compiles with no new errors (existing sorry count may remain same or decrease)
- `grep -r "sorry.*temp_linearity removed" Theories/` returns zero matches
- `grep -r "sorry.*F_until_equiv removed" Theories/` returns zero matches

**Go/No-Go**: If adding temp_linearity creates more than 10 unexpected build errors in unrelated modules, pause and assess scope.

---

### Phase 2: Derive bx_le Linearity [NOT STARTED]

**Goal**: Prove that `bx_le` is a total order on BXPoints using `temp_linearity` and `F_until_equiv`.

**Tasks**:
- [ ] In `Frame.lean`, prove a key lemma: `temp_linearity` in an MCS implies that for any two BXPoints w, v reachable from a common predecessor, either `bx_le w v` or `bx_le v w`
- [ ] The proof strategy: Given BXPoints w, v, suppose `F(phi) in u` for some phi witnessing w (via bx_forward_witness) and `F(psi) in u` witnessing v. Apply temp_linearity to get three cases, each yielding a bx_le relationship
- [ ] Alternatively, prove the stronger result: for any MCS containing `F(phi)`, apply `F_until_equiv` to get `top U phi`, then use BX7 (linearity of Until) to order the witnesses
- [ ] Prove `bx_le_total : forall (w v : BXPoint), bx_le w v or bx_le v w` -- the central theorem
- [ ] Prove auxiliary: `bx_le_antisymm` (if not already present) for use in strict ordering arguments

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- add linearity/totality theorems

**Verification**:
- `lean_goal` at `bx_le_total` shows no remaining goals
- `lake build Bimodal.Metalogic.BXCanonical.Frame` succeeds

**Go/No-Go**: If bx_le totality proof is blocked (F_until_equiv insufficient to bridge F-formulas to Until-formulas in MCS context), escalate: may need additional lemma connecting g_content ordering to Until-witness ordering. Document the gap and assess whether a different proof strategy is needed.

---

### Phase 3: Close 4 Frame.lean Sorries [NOT STARTED]

**Goal**: Use bx_le linearity to close the 4 eventuality resolution sorries.

**Tasks**:
- [ ] Close `bx_until_eventuality_resolution` (line 632): Given `phi U psi in w` and `psi not in w`, use BX10 to get `F(psi)` witness v, apply bx_le_total to order intermediate points, use BX5 self-accumulation to propagate guard phi along the interval
- [ ] Close `bx_until_backward` (line 664): Given v >= w with `psi in v` and guard phi on [w,v), use contradiction + BX4 connectedness. bx_le_total ensures the backward witness u from `P(neg(phi U psi)) in v` is comparable with w
- [ ] Close `bx_since_eventuality_resolution` (line 683): Mirror of forward Until using h_content, BX5', BX9', BX10', and bx_le_total
- [ ] Close `bx_since_backward` (line 697): Mirror of backward Until using BX8', BX4', and bx_le_total

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- close 4 sorries

**Verification**:
- `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` returns zero matches
- `lake build Bimodal.Metalogic.BXCanonical.Frame` succeeds

---

### Phase 4: Close CanonicalEmbedding.lean Sorry [NOT STARTED]

**Goal**: Close the imp Case B sorry at `CanonicalEmbedding.lean:418` using non-constant histories enabled by bx_le linearity.

**Tasks**:
- [ ] Analyze the sorry at line 418: the gap is that on constant histories, `truth_at G(alpha)` collapses to `truth_at alpha`, so the backward truth bridge gives `flatten(chi) in w` rather than `chi in w`
- [ ] Construct a two-point history: given MCS w with `psi in w` and `chi not in w`, build a non-constant history that visits a second BXPoint v with `chi not in v` and appropriate temporal structure
- [ ] The key insight: with bx_le linearity, we can construct a WorldHistory through two distinct bx_le-ordered BXPoints, where G(alpha) at w evaluates to truth at both w and v (not collapsing)
- [ ] Alternatively, use a proof-theoretic approach: if chi = G(alpha), then `not G(alpha) in w` means `F(neg alpha) in w` by MCS properties, and F_until_equiv gives `top U neg(alpha) in w`, providing the needed non-trivial temporal witness
- [ ] Close the sorry

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- close sorry at line 418

**Verification**:
- `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` returns zero matches
- `lake build Bimodal.Metalogic.BXCanonical.CanonicalEmbedding` succeeds

**Go/No-Go**: If two-point history construction requires infrastructure not yet in the codebase (e.g., non-trivial WorldHistory construction lemmas), assess whether to build that infrastructure or use the proof-theoretic alternative. If both approaches need >4 additional hours, mark as [PARTIAL] and document.

---

### Phase 5: Close Completeness.lean Sorry [NOT STARTED]

**Goal**: Close the final sorry in `bx_completeness` at `Completeness.lean:160` using the now-complete truth lemma.

**Tasks**:
- [ ] With Frame.lean sorries closed, verify that TruthLemma.lean compiles without sorries (it likely depends on Frame.lean's eventuality resolution)
- [ ] In `Completeness.lean:160`, construct the canonical TaskModel embedding: build a WorldHistory through BXPoints using the now-linear bx_le ordering, connect to a shift-closed Omega set
- [ ] Apply the full truth lemma to show `phi not in w₀` implies `phi false at w₀ in canonical model`
- [ ] Close the sorry

**Timing**: 1.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- close sorry at line 160

**Verification**:
- `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` returns zero matches
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds

---

### Phase 6: Fix Downstream Sorries and Final Validation [NOT STARTED]

**Goal**: Close remaining sorry markers in Boneyard and validate the full build is clean.

**Tasks**:
- [ ] Close `DovetailedChain.lean:572` sorry: `F_until_equiv` is now an axiom, so `F(psi) in MCS -> (top U psi) in MCS` follows directly
- [ ] Close `FiniteDeferral.lean:48` sorry: same `F_until_equiv` pattern
- [ ] Run full `lake build` and verify no new sorries or errors in the BXCanonical module
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/` to confirm zero sorry count
- [ ] Run `grep -rn "sorry.*removed in BX" Theories/` to confirm zero remaining removal markers
- [ ] Verify `lean_verify` on `bx_completeness` shows no axiom usage beyond the standard axioms

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- close sorry at line 572
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` -- close sorry at line 48

**Verification**:
- `lake build` succeeds with zero sorry count in BXCanonical module
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns zero results
- `grep -rn "sorry.*removed in BX" Theories/` returns zero results

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] Zero sorries in `Theories/Bimodal/Metalogic/BXCanonical/` directory
- [ ] Zero sorry markers tagged "removed in BX" in entire codebase
- [ ] `lean_verify` on `bx_completeness` confirms it depends only on standard Lean axioms (propext, Quot.sound, Classical.choice)
- [ ] `lean_verify` on `usf_completeness` confirms sorry-free
- [ ] `lean_verify` on `fragment_completeness` confirms sorry-free (should already be)

## Artifacts & Outputs

- `specs/088_close_remaining_bxcanonical_sorries/plans/01_implementation-plan.md` (this file)
- `specs/088_close_remaining_bxcanonical_sorries/summaries/01_implementation-summary.md` (post-implementation)
- Modified Lean source files as listed per phase

## Rollback/Contingency

- All changes are additive (new axiom constructors, new proofs closing sorries). Rollback is straightforward: revert the commits.
- If Phase 2 (bx_le linearity) is blocked, the axiom additions from Phase 1 are still independently valuable and close the ConservativeExtension/LinearityDerivedFacts sorries.
- If Phase 4 (CanonicalEmbedding) is blocked, Phases 1-3 still close 4 of 6 sorries plus multiple downstream sorries, which is substantial progress.
- If the full plan cannot be completed, mark [PARTIAL] with completed phases and document remaining gaps.
