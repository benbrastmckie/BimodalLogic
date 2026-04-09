# Implementation Plan: Close usf_completeness imp Case B via Combined F-Seed Chain

- **Task**: 86 - Close BXCanonical completeness sorries
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: reports/06_usf-completeness-path.md, reports/05_team-research.md, reports/04_restructure-research.md, reports/03_team-research.md
- **Artifacts**: plans/06_usf-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the single remaining sorry in `usf_completeness` (imp Case B, CanonicalEmbedding.lean:418) by constructing dovetailed chain histories using a combined F-seed approach, defining a two-dimensional Omega, proving a bidirectional truth lemma for all USF formulas, and instantiating the validity hypothesis to derive a contradiction. Phase 1 from the prior plan (box preservation + modal equivalence along `bx_le`) is already complete and sorry-free. The combined F-seed approach -- where ALL pending F-obligations are included in each chain extension step -- fixes the forward_F problem that blocked the prior plan's one-at-a-time dovetail scheduling. Definition of done: `lake build` succeeds with zero sorries in CanonicalEmbedding.lean.

### Research Integration

- **Report 06** (usf-completeness-path.md): Definitive analysis of why constant histories fail (backward G truth lemma), the correct combined F-seed architecture, detailed proof sketches for all 6 cases of the bidirectional truth lemma, and the exact sorry-closing argument. Primary basis for this plan.
- **Report 05** (team-research.md): Confirmed enriched-seed and chain-based approaches are blocked under reflexive semantics where x_content(M) = M. Identified Burgess-Xu axiom 4 as semantically invalid.
- **Report 04** (restructure-research.md): Exhaustive analysis of all failed approaches (constant histories, flatten, one-directional lemmas, shifts-only Omega). Proved imp case needs BOTH directions of truth lemma.
- **Report 03** (team-research.md): Confirmed constant histories insufficient for G/H backward direction. Established imp Case B as the single remaining blocker.

### Prior Plan Reference

Prior plan (04_implementation-plan.md) had 5 phases. Phase 1 (box preservation + modal equivalence) was COMPLETED and is sorry-free. Phases 2-5 were BLOCKED because the one-at-a-time dovetail scheduling does not satisfy forward_F -- if F(psi) is in chain(t) but psi is scheduled for resolution at a later dovetail step, forward_F fails at intermediate steps. The combined F-seed approach (report 06, Section 3.2) fixes this by including ALL pending F-obligations in each seed, making forward_F hold trivially by construction. Effort estimates from the prior plan were reasonable (10 hours total); this plan reuses that calibration.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `combined_F_seed_consistent`: multi-target forward seed consistency via compactness + temporal duality
- Define `dovetail_chain : BXPoint -> Int -> BXPoint` using combined F-seed at each step
- Prove chain properties: zero, monotonicity, forward_F, forward_G, G_contrapositive, and mirrors
- Define `dovetail_history` and `dovetail_omega` with shift-closure and self-membership
- Prove bidirectional `chain_truth_iff` for all USF formulas (atom, bot, imp, box, G, H)
- Close the sorry at CanonicalEmbedding.lean:418 using the truth lemma
- Achieve zero sorries in CanonicalEmbedding.lean

**Non-Goals**:
- Close the 4 Frame.lean Until/Since sorries (blocked on Until-induction, irrelevant to USF completeness)
- Build a universal canonical model (surjectivity problem)
- Prove completeness for formulas containing Until/Since
- Redefine `bx_le` or pursue FMP bridge
- Optimize for computational efficiency (all definitions are `noncomputable`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `combined_F_seed_consistent` proof has a gap in the multi-target compactness argument | H | L | Single-target version is sorry-free in WitnessSeed.lean; multi-target follows same pattern with MCS disjunction elimination |
| Dovetail chain definition requires complex well-founded recursion in Lean | M | M | Use `Nat.rec` with explicit recursion; all definitions noncomputable; positive/negative halves defined separately |
| Box case of truth lemma needs delicate modal equivalence threading | H | M | `box_preserved_along_bx_le` and `bx_modal_equiv_of_bx_le` are sorry-free (Phase 1 completed); chain_box_preserved follows by transitivity |
| G backward case depends on temporal duality at MCS level | M | L | `some_future phi = phi.neg.all_future.neg` is definitional; MCS negation completeness provides the bridge |
| `respects_task` obligation for dovetail history is non-trivial | L | L | Canonical task_rel is permissive (`d != 0 or states agree`); full domain trivially satisfies convexity |
| Interaction between G/H induction and box case in truth lemma creates circular dependency | M | L | Structural induction on USF formulas is well-founded (no Until/Since); each case depends only on strictly smaller sub-formulas |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Combined F-Seed Consistency + Chain Construction [NOT STARTED]

**Goal**: Prove multi-target forward seed consistency and define the dovetailed chain with all required temporal properties.

**Tasks**:
- [ ] Prove MCS temporal duality at the membership level: `F(psi) in w.formulas <-> neg(G(neg psi)) in w.formulas` (should be near-trivial from `some_future` being definitionally `neg.all_future.neg` + MCS double negation)
- [ ] Prove MCS disjunction elimination: `(a or b) in w -> a in w or b in w` (from MCS completeness properties, may already exist)
- [ ] Prove `combined_F_seed_consistent`: given `w : BXPoint` and `L : List Formula` with `forall psi in L, F(psi) in w.formulas`, then `L.toFinset union g_content(w.formulas)` is consistent
  - Proof: assume inconsistent; extract finite `S_L = S cap L` and `S_g = S cap g_content`; from derivation get `S_g derives neg(psi_1) or ... or neg(psi_k)`; by `generalized_temporal_k` get `G(neg psi_1) or ... or G(neg psi_k) in w`; but each `F(psi_i) in w` gives `neg G(neg psi_i) in w` by temporal duality; contradiction with MCS disjunction
- [ ] Prove mirror `combined_P_seed_consistent` for the past direction using `h_content`
- [ ] Define `dovetail_chain_pos : BXPoint -> Nat -> BXPoint` for positive direction:
  - `dovetail_chain_pos w 0 = w`
  - `dovetail_chain_pos w (n+1)` = Lindenbaum extension of combined seed: all `psi` where `F(psi) in chain(n)` and `psi not-in chain(n)`, union `g_content(chain(n))`, union `box_content(chain(n))`
- [ ] Define `dovetail_chain_neg : BXPoint -> Nat -> BXPoint` for negative direction (mirror using `P`, `h_content`)
- [ ] Define `dovetail_chain : BXPoint -> Int -> BXPoint` combining positive and negative
- [ ] Prove `dovetail_chain_zero`: `dovetail_chain w 0 = w`
- [ ] Prove `chain_monotone`: `0 <= m <= n -> bx_le (chain w m) (chain w n)` via g_content inclusion in seed
- [ ] Prove `chain_forward_F`: `F(psi) in chain(t) -> exists r > t, psi in chain(r)` -- trivial by construction (if psi not-in chain(t), psi is in seed at t+1, so psi in chain(t+1))
- [ ] Prove `chain_forward_G`: `G(alpha) in chain(t) -> forall r >= t, alpha in chain(r)` -- by induction: G(alpha) propagates through g_content subset of seed
- [ ] Prove `chain_G_contrapositive`: `G(alpha) not-in chain(s) -> exists r > s, alpha not-in chain(r)` -- temporal duality gives F(neg alpha) in chain(s), then chain_forward_F gives witness
- [ ] Prove mirror properties for negative direction (H, P, chain_backward_P, chain_backward_H, chain_H_contrapositive)
- [ ] Prove `chain_box_preserved`: `box(phi) in chain(s) <-> box(phi) in chain(r)` -- from `box_preserved_along_bx_le` + chain_monotone
- [ ] Verify `lake build` passes

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- add combined seed lemmas and chain construction

**Verification**:
- `lake build` succeeds with no new sorries
- All chain properties type-check

---

### Phase 2: Dovetail History + Omega Construction [NOT STARTED]

**Goal**: Wrap dovetail chains into `WorldHistory canonical_task_frame` values and define the two-dimensional Omega with shift-closure and membership properties.

**Tasks**:
- [ ] Define `dovetail_history : BXPoint -> WorldHistory canonical_task_frame`
  - `domain := fun _ => True`
  - `states := fun t _ => dovetail_chain w t`
  - Prove `convex` (trivial with full domain)
  - Prove `respects_task` (canonical_task_frame has permissive task_rel: `d != 0 or states agree`; for `d = 0`, chain(t) = chain(t))
- [ ] Define `dovetail_omega : BXPoint -> Set (WorldHistory canonical_task_frame)`
  - `{ sigma | exists v : BXPoint, bx_modal_equiv w v and exists delta : Int, sigma = time_shift (dovetail_history v) delta }`
- [ ] Prove `dovetail_omega_shift_closed`: Omega is shift-closed (shifts of time-shifts are time-shifts)
- [ ] Prove `dovetail_history_mem_omega`: `bx_modal_equiv w v -> dovetail_history v in dovetail_omega w` (take delta = 0)
- [ ] Prove `dovetail_history_self_mem`: `dovetail_history w in dovetail_omega w` (via `bx_modal_equiv_refl`)
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- add history and omega definitions

**Verification**:
- `lake build` succeeds with no new sorries
- `dovetail_omega_shift_closed` has expected type signature

---

### Phase 3: Bidirectional Truth Lemma [NOT STARTED]

**Goal**: Prove the bidirectional truth lemma `chain_truth_iff` for all USF formulas on dovetail histories -- the core technical result enabling the sorry closure.

**Tasks**:
- [ ] State `chain_truth_iff`: for all USF `phi`, all `v` with `bx_modal_equiv w v`, all `s : Int`:
  `phi in (dovetail_chain v s).formulas <-> truth_at canonical_valuation (dovetail_omega w) (dovetail_history v) s phi`
- [ ] Prove atom case: by definition of `canonical_valuation` and full domain
- [ ] Prove bot case: both sides False (`bot_not_in_mcs` / truth_at bot = False)
- [ ] Prove imp case: forward uses `imp_iff_mcs` + IH backward on antecedent + IH forward on consequent; backward mirrors
- [ ] Prove box case:
  - Forward: `box(phi) in chain_v(s)` -> `chain_box_preserved` gives `box(phi) in v` -> modal equiv transitivity gives `box(phi) in u` for all `u ~ w` -> `chain_box_preserved` gives `box(phi) in chain_u(r)` for all r -> modal_t gives `phi in chain_u(r)` -> IH forward gives truth_at
  - Backward: for all `sigma in Omega`, `truth_at phi at (sigma, s)` -> IH backward at each modal-equivalent u with delta = -s -> `phi in u` for all `u ~ chain_v(s)` -> `box_iff_mcs` gives `box(phi) in chain_v(s)`
- [ ] Prove G case:
  - Forward: `G(phi) in chain_v(s)` -> `chain_forward_G` gives `phi in chain_v(r)` for all `r >= s` -> IH forward
  - Backward: `truth_at phi at all r >= s` -> IH backward gives `phi in chain_v(r)` for all `r >= s` -> suppose `G(phi) not-in chain_v(s)` -> by temporal duality `F(neg phi) in chain_v(s)` -> `chain_forward_F` gives `neg phi in chain_v(r')` for some `r' > s` -> contradiction with `phi in chain_v(r')` and MCS consistency
- [ ] Prove H case: mirror of G using negative direction and backward chain properties
- [ ] Verify `lake build` passes

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- add chain_truth_iff

**Verification**:
- `lake build` succeeds with no new sorries in the truth lemma
- `#check @chain_truth_iff` confirms the bidirectional iff

---

### Phase 4: Close Sorry + Verify [NOT STARTED]

**Goal**: Replace the sorry at CanonicalEmbedding.lean:418 with a proof using the truth lemma, achieving zero sorries in CanonicalEmbedding.lean.

**Tasks**:
- [ ] Replace the sorry in `usf_completeness` imp Case B:
  - We have `w : BXPoint` with `psi in w`, `chi not-in w`, `h_valid : valid (psi.imp chi)`, `h_usf : untilSinceFree (psi.imp chi)`
  - Instantiate `h_valid` with `(Int, canonical_task_frame, canonical_valuation, dovetail_omega w, dovetail_omega_shift_closed w, dovetail_history w, dovetail_history_self_mem w, 0)`
  - This yields `truth_at psi -> truth_at chi` at `(dovetail_omega w, dovetail_history w, 0)`
  - By `chain_truth_iff` forward on psi (with `bx_modal_equiv_refl w`): `psi in w = chain(0) -> truth_at psi`
  - Apply validity to get `truth_at chi`
  - By `chain_truth_iff` backward on chi: `truth_at chi -> chi in chain(0) = w`
  - Contradiction with `h_chi_not : chi not-in w`
- [ ] Run `lake build` and verify zero errors
- [ ] Run `grep sorry CanonicalEmbedding.lean` and verify zero sorries remain
- [ ] Run `lean_verify` on `usf_completeness` to confirm no non-standard axioms
- [ ] Update module docstring to reflect completed proof (remove "sorry" references, update scope description)

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- replace sorry with proof, update docstring

**Verification**:
- `lake build` succeeds with zero errors
- `grep -c sorry CanonicalEmbedding.lean` returns 0
- `lean_verify` on `usf_completeness` shows only standard axioms (propext, Quot.sound, Classical.choice)
- The 4 Frame.lean Until/Since sorries remain unchanged (not regressed)

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] Zero sorries in `CanonicalEmbedding.lean` after Phase 4
- [ ] `lean_verify` on `usf_completeness` confirms no non-standard axioms
- [ ] The 4 Frame.lean Until/Since sorries remain unchanged (not regressed)
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` shows only the expected Frame.lean sorries (lines 646, 668, 683, 697)

## Artifacts & Outputs

- `plans/06_usf-completeness-plan.md` (this file)
- `summaries/03_execution-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` (combined seed + chain + history + omega + truth lemma + sorry closure)

## Rollback/Contingency

- All changes are additive (new definitions and lemmas) except the sorry replacement in Phase 4
- If the combined F-seed consistency proof is harder than expected, fall back to using the existing single-target `forward_temporal_witness_seed_consistent` with a finite iteration argument (resolve one F-obligation at a time, maintaining consistency at each step)
- If the bidirectional truth lemma proves intractable for a specific case (especially box), preserve all new lemmas (they are independently valuable) and keep the sorry with updated comments explaining progress
- Git provides full rollback via `git revert` on individual phase commits
- If the chain definition causes Lean definitional issues, split into a separate `ChainConstruction.lean` file to isolate build times
