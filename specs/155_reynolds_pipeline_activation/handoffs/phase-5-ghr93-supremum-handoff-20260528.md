# Phase 5 Handoff: GHR93 Supremum Approach Infrastructure

**Date**: 2026-05-28
**Session**: sess_1780001766_2e723d
**Phase**: 5 — GHR93-Faithful Case II Rewrite (Path C)
**Status**: IN PROGRESS (Tasks 5.0 and 5.1 completed, Tasks 5.1b-5.8 remain)

## What Was Accomplished

### Task 5.0: untl_witness_bounded (COMPLETED)
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (line 621)
- **Theorem**: `untl_witness_bounded` — resolves the Until witness containment problem
- **Key insight**: If U(B,A)(t) holds AND a B-satisfying mu-point exists in (t, bound], then a valid Until witness exists in (t, bound]. Proof by case split on z_b vs z_canon.
- **Axiom status**: Clean (propext, Classical.choice, Quot.sound)
- **Lines added**: ~30

### Task 5.1: CharacteristicFormula import + ghr93_untl_transfer (COMPLETED)
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` (line 1172)
- **Import**: `import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` added
- **Theorem**: `ghr93_untl_transfer` — proves U(B,A)(c) in M from U(B,A)(d) in N via tau at rank r+delta
- **Mechanism**: Plays props.tau at rank r+delta with rank-embedded selections. Extracts formula agreement at position 0 (d/c) at depth r+delta >= r+2 >= depth(U(B,A)). Uses formula_transfer_rank_embed to bridge ranks.
- **Axiom status**: Clean
- **Lines added**: ~70

## Immediate Next Action

Complete Tasks 5.1b-5.5: integrate `ghr93_untl_transfer` + `untl_witness_bounded` into the ghr93_case_II proof body.

### Critical Obstacle: B-Point Existence in (c, y]

`untl_witness_bounded` requires a B-satisfying mu-point in (c, y]. Two approaches identified:

1. **Forward game approach** (proven viable): Use `h_d_compat_left` to get e_n_pt in [x, y] with formula agreement at depth r. Then B(e_n_pt) follows from x_t_self + formula agreement. And c < e_n_pt follows from the d-compatible game's ordering (c corresponds to d, d < p_n). This gives e_n_pt as the B-point in (c, y].

2. **Pure GHR93 approach** (harder): Derive B-point existence without forward game. Requires showing tau maps B-satisfying points from [d, y'] to [c, y] via Round 2 challenge mechanism. This involves playing tau's Round 2 in the reverse direction which the game structure doesn't directly support.

### Critical Obstacle: Biconditional Orderings for Round 2

The Round 2 dispatch (same_order_type_of_cases) requires biconditional orderings like:
- `a_init(k) < p_n iff resp(k) < e_n` for all k < n

With the current tau_left approach, these come from tau_left's game on [d, p_n] -> [c, e_n]. Without tau_left (pure GHR93), the sel_pn_ord trivial chain gives resp_tau(k) < e_n (one-directional only). The biconditional requires handling the equality case which does NOT hold in general with resp_tau from [c, y].

**Recommendation**: Either (a) use hybrid approach (forward game for orderings, U(B,A) for formula agreement) as intermediate step, or (b) rewrite Round 2 entirely using GHR93's 5-way case split which structures the proof differently and avoids some biconditionals.

## Key Decisions Made

1. Chose `untl_witness_bounded` over full `definable_sup` per plan rollback section
2. Used `formula_transfer_rank_embed` to bridge rank levels for U(B,A) transfer
3. Used d (not a_bwd(n-1)) as ref_N — works because all selections >= d

## Current State

- ghr93_case_II: still uses forward game for e_n (unchanged, sorry-free)
- ghr93_untl_transfer: proved, ready to use
- untl_witness_bounded: proved, ready to use
- Full project build: passes
- Sorries in CaseAnalysis.lean: 1 (Cases III/IV, unchanged)

## Files Modified

1. `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` — added untl_witness_bounded
2. `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` — added import + ghr93_untl_transfer
3. `specs/155_reynolds_pipeline_activation/plans/46_path-c-supremum-plan.md` — updated task status markers
