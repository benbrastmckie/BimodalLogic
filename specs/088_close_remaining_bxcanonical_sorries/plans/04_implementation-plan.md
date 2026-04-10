# Implementation Plan: Close CanonicalEmbedding:418 Sorry (v4)

- **Task**: 88 - Close remaining BXCanonical sorries (NARROWED SCOPE: CanonicalEmbedding:418 only)
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: reports/04_team-research.md
- **Artifacts**: plans/04_implementation-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the single sorry at CanonicalEmbedding.lean:418, which blocks `usf_completeness` (Until/Since-free fragment completeness for BX logic). The sorry is in `imp` Case B: given MCS `w` with `psi in w` and `chi not in w` where `psi.imp chi` is USF, we need a contradiction with the hypothesis that `psi.imp chi` is valid. The current approach uses `constant_history w` where `truth_at G(alpha)` collapses to `truth_at alpha`, breaking the backward truth bridge for formulas containing G or H. The fix builds a two-point WorldHistory with `history(0) = w` and `history(1) = bx_forward_witness v` that breaks this collapse, enabling a complete truth bridge using sorry-free `G_iff_mcs`/`H_iff_mcs`. Definition of done: `usf_completeness` type-checks without sorry and `lake build` succeeds.

### Research Integration

Round 4 team research (4 teammates) identified the two-point WorldHistory approach as the highest-ROI path, avoiding sorry'd upstream dependencies in SuccChainFMCS.lean. Key finding: `canonical_task_frame` has `task_rel w d u = d != 0 or w = u`, so any two BXPoints can serve as consecutive states in a 2-time history (the `respects_task` obligation is trivially satisfied for distinct times). The truth bridge for USF formulas uses only sorry-free lemmas: `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`, and MCS properties for atom/bot/imp.

### Prior Plan Reference

Plan v3 had 5 phases covering the full 6-sorry scope. Phase 2 (architecture spike for bx_le redefinition) concluded NO-GO. Phases 3-5 (Frame.lean + Completeness.lean) are now split to task 89. Phase 1 (CanonicalEmbedding:418) was [PARTIAL] -- the two-point approach was identified but not implemented. This plan (v4) focuses exclusively on completing that work. Effort calibration from v3: the 4-6h estimate for Phase 1 was reasonable given the proof structure, but the two-point history construction is slightly more complex than initially expected due to the need for a full USF truth bridge (not just temporal-free), increasing to 6h.

### Roadmap Alignment

No ROAD_MAP.md found. Closing this sorry yields `usf_completeness`: the first verified formalization of S5+G/H fragment completeness in Lean 4.

## Goals & Non-Goals

**Goals**:
- Close CanonicalEmbedding.lean:418 sorry for `usf_completeness`
- Build a two-point WorldHistory construction that breaks the constant-history collapse
- Prove a complete truth bridge for all USF formula constructors on the two-point model
- `lake build` succeeds with `usf_completeness` sorry-free

**Non-Goals**:
- Closing Frame.lean sorries (task 89)
- Closing Completeness.lean:160 sorry (task 89)
- Modifying the axiom system (BX1-BX12 are fixed)
- Modifying `bx_le` or any canonical ordering infrastructure
- General-purpose WorldHistory infrastructure beyond what's needed for this proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Two-point truth bridge for box modality requires careful Omega construction | M | M | Use `modal_omega w` (constant histories through modally-equivalent points); box case already proved in `fragment_truth_iff` -- adapt pattern |
| Nested G/H inside imp requires inductive truth bridge, not just top-level | M | L | USF formula structure is well-founded; truth bridge by structural induction on USF formulas covers all nesting patterns |
| `bx_forward_witness` requires `F(psi) in w` for some `psi`; we need a suitable witness | M | L | Use `h_psi_valid : not (valid psi)` to get a model where psi is false; then the MCS `w` with `neg(psi.imp chi) in w` has properties we can exploit. Alternatively, use `bx_le_refl` (w <= w) directly for the truth bridge without needing a second point -- the key is that for the two-point history, `truth_at G(alpha)` at time 0 requires `truth_at alpha` at time 1 (a different state), breaking the collapse. |
| The two-point WorldHistory may not provide the right contradiction because the valid formula psi.imp chi must be true at (tau, 0) for the right tau | L | L | Choose tau as the two-point history itself; psi.imp chi valid means true everywhere, so true at (tau, 0), giving chi true at (tau, 0), then truth bridge gives chi in w, contradicting h_chi_not |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases are sequential: Phase 1 builds infrastructure, Phase 2 closes the sorry.

---

### Phase 1: Build Two-Point WorldHistory and USF Truth Bridge [NOT STARTED]

**Goal**: Construct a two-point WorldHistory and prove the truth bridge lemma for USF formulas on this history.

**Tasks**:
- [ ] Define `two_point_history (w v : BXPoint) (h_le : bx_le w v) : WorldHistory canonical_task_frame` with `domain = fun _ => True`, `states 0 = w`, `states t = v` for `t > 0` (or simpler: `states t = if t <= 0 then w else v`). Prove `respects_task` using `canonical_task_frame`'s permissive `task_rel` (trivial for `s < t` since `t - s != 0`; for `s = t` since states agree)
- [ ] Define `two_point_omega (w : BXPoint) : Set (WorldHistory canonical_task_frame)` as the set of two-point histories through modally-equivalent BXPoints: `{ tau | exists u v, bx_modal_equiv w u /\ bx_le u v /\ tau = two_point_history u v ... }`. Prove shift-closure.
- [ ] Prove `two_point_truth_bridge`: for USF formula `phi` and MCS `w` with `bx_le w v`:
  `phi in w.formulas <-> truth_at canonical_valuation (two_point_omega w) (two_point_history w v h_le) 0 phi`
  By structural induction on USF formulas:
  - `atom p`: By definition of `canonical_valuation` and `states 0 = w`
  - `bot`: Trivial (both sides False)
  - `imp psi chi`: By IH for psi and chi (both USF sub-formulas)
  - `box psi`: Forward: `box psi in w` -> for all modally-equivalent `u`, `box psi in u` -> by IH, truth at all histories in `two_point_omega`. Backward: truth at all histories -> in particular at histories through `w` -> by IH, `psi in w` for all modally-equivalent `u` -> `box psi in w` via `box_iff_mcs`
  - `all_future psi` (G): Forward: `G(psi) in w` -> by `G_iff_mcs`, `psi in u` for all `u >= w`. At time 0, states = w so `psi in w` gives truth. At time t > 0, states = v and `bx_le w v` gives `psi in v` by `G_iff_mcs`. Backward: truth at all times -> truth at time 0 and time 1 -> by IH at both w and v -> `psi in u` for all `u >= w` (need: the two-point model captures all bx_le successors via the quantification over `two_point_omega`). This is the subtle direction -- may need `G_iff_mcs` directly rather than going through semantic truth.
  - `all_past psi` (H): Symmetric using `H_iff_mcs` and backward direction
  - `untl`/`snce`: Cannot appear (USF hypothesis eliminates these cases)
- [ ] Handle the backward direction for G carefully: If `truth_at G(psi)` at time 0 on `two_point_history w v`, then `truth_at psi` at all times >= 0, so `truth_at psi` at time 0 (states=w) and at time 1 (states=v). By IH, `psi in w` and `psi in v`. But `G_iff_mcs` requires `psi in u` for ALL `u >= w`, not just `v`. The key insight: we do NOT need the full backward direction of the truth bridge for G. We only need the FORWARD direction (membership -> truth) to establish the contradiction. See Phase 2 for how the proof uses this.

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- Add two-point history definitions and truth bridge lemma (before `usf_completeness`)

**Verification**:
- All new definitions and lemmas type-check (sorries acceptable for truth bridge backward direction if not needed)
- `lake build` succeeds

---

### Phase 2: Close the Sorry at Line 418 [NOT STARTED]

**Goal**: Use the two-point history construction to derive a contradiction in imp Case B, closing the sorry.

**Tasks**:
- [ ] At the sorry site (line 418), we have: `w : BXPoint`, `h_psi_in : psi in w.formulas`, `h_chi_not : chi not in w.formulas`, `h_valid : valid (psi.imp chi)`, `h_usf : untilSinceFree (psi.imp chi)`
- [ ] Strategy A (direct, preferred): The proof should derive `chi in w.formulas` from validity, contradicting `h_chi_not`. Use `h_valid` to get truth of `psi.imp chi` at any model/history/time. Construct a two-point history where `truth_at psi` at time 0 (via truth bridge forward from `h_psi_in`) implies `truth_at chi` at time 0 (by validity of `psi.imp chi`), then use truth bridge backward for chi to get `chi in w.formulas`. This requires the full bidirectional truth bridge for chi.
- [ ] Strategy B (fallback): If the backward truth bridge for G is problematic, use a different proof structure. Since `psi.imp chi` is valid and USF, and psi is not valid (by hypothesis), consider whether the Case B proof can be restructured to avoid the backward truth bridge entirely -- e.g., by finding a derivation of `psi.imp chi` proof-theoretically rather than semantically. Note: Case B's existing approach is inherently semantic (contrapositive via canonical model), so the backward bridge is likely unavoidable.
- [ ] Strategy C (alternative model): Instead of two-point history, consider using the FULL canonical model where `Omega` contains histories through ALL MCS points. The truth bridge `G_iff_mcs`/`H_iff_mcs` already characterizes G/H semantically in terms of the bx_le ordering. If we can build an appropriate TaskModel where `truth_at phi at (tau, 0) <-> phi in w.formulas` for ALL USF phi simultaneously, the backward direction follows from `G_iff_mcs` backward direction directly. This may be simpler than the two-point construction.
- [ ] Close the sorry by implementing whichever strategy works. The contradiction is: `truth_at (psi.imp chi)` at (tau, 0) by validity, `truth_at psi` at (tau, 0) by truth bridge forward from `h_psi_in`, therefore `truth_at chi` at (tau, 0), therefore `chi in w.formulas` by truth bridge backward, contradicting `h_chi_not`.
- [ ] Run `lake build` to verify `usf_completeness` compiles sorry-free
- [ ] Run `grep -rn sorry CanonicalEmbedding.lean` to confirm no remaining sorries in the file

**Timing**: 2 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- Replace sorry at line 418 with the contradiction proof

**Verification**:
- `usf_completeness` type-checks without sorry
- `lake build` succeeds
- No `sorry` in CanonicalEmbedding.lean (grep check)
- Existing sorry-free results unaffected (soundness, fragment_completeness, etc.)

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` returns zero Lean sorry instances
- [ ] `usf_completeness` type-checks without sorry
- [ ] No new axioms added beyond BX1-BX12
- [ ] Existing sorry-free results in TruthLemma.lean (`G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`) remain unmodified
- [ ] `fragment_completeness` still works (no regressions)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- 1 sorry closed, two-point history construction added
- `specs/088_close_remaining_bxcanonical_sorries/plans/04_implementation-plan.md` -- This plan

## Rollback/Contingency

**Phase-level rollback**: All modifications are in `CanonicalEmbedding.lean`. Revert with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean`.

**If two-point truth bridge backward direction for G fails**: The core difficulty is that `truth_at G(psi) at time 0` on a two-point history only gives `psi in w` and `psi in v`, not `psi in u` for all `u >= w`. Three fallback options:
1. Use a richer Omega that includes two-point histories for ALL BXPoints v >= w, so the box/G quantification captures the full bx_le ordering
2. Build the truth bridge using `G_iff_mcs` directly (abstracting over the semantic model) rather than through `truth_at`
3. Restructure the proof to only use the forward direction of the truth bridge (membership -> truth), which suffices for the contradiction argument if `h_valid` provides truth and we only need to extract membership for chi

**Partial completion**: Phase 1 alone (infrastructure) has no value without Phase 2. If Phase 2 is blocked, the infrastructure can be removed and the sorry remains.
