# Implementation Summary: Irreflexive Semantics Switch

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: PARTIAL (Phases 1, 2, 5 completed; Phase 3 partial; Phase 4 blocked)
- **Session**: sess_1776649069_d70589

## Phase Status

| Phase | Status | Summary |
|-------|--------|---------|
| 1: Semantic/Axiom Layer | COMPLETED | Truth.lean strict <, axioms replaced, 16+ files updated |
| 2: Frame/Model Repair | COMPLETED | g/h_content_set_consistent via seriality, enriched_seed bypassed |
| 3: Chain Redesign | PARTIAL | defect_step weakened to disjunctive output |
| 4: Close Sorry Sites | BLOCKED | Lindenbaum non-determinism prevents finite descent |
| 5: ROAD_MAP.md | COMPLETED | Axiom table, semantics, sorry inventory updated |

## What Was Accomplished

### Phase 1 (completed)
- Irreflexive semantics switch: G/H use `<`, Until/Since use strict witness with open guard
- Removed BX1/BX1' (reflexive T), refl_intro_until/since; added serial_future/serial_past
- Propagated changes through 16+ files with sorry markers for BX1-dependent code

### Phase 2 (completed)
- Proved `g_content_set_consistent` via seriality: G(bot) in MCS contradicts F(top) from serial_future
- Proved `h_content_set_consistent` via seriality: H(bot) in MCS contradicts P(top) from serial_past
- Fixed `bx_H_backward` using new h_content_set_consistent
- Simplified `fwd_succ`/`bwd_pred` non-resolving branches to use g_content/h_content alone

### Phase 3 (partial)
- `defect_step_early`: weakened to disjunctive output (chi in M' OR F(chi) in M')
- `fwd_chain_defect_one_step`: single-step atomic preservation
- `defect_step_from_earliest` and `defect_fwd_step_choice_spec`: updated to match

### Phase 4 (blocked)
The 5 sorry sites cannot be closed with the current Lindenbaum-based chain construction.
The Lindenbaum extension is non-constructive and can re-introduce F-obligations even when
phi -> F(phi) is not derivable. A constrained Lindenbaum extension or alternative chain
construction is needed. See handoff at `specs/093_complete_bxcanonical_embedding/handoffs/48_sorry-closure-handoff.md`.

### Phase 5 (completed)
- Updated ROAD_MAP.md axiom table (serial_future/past, until_step/since_step)
- Updated semantics section (irreflexive with strict inequalities)
- Updated sorry inventory with irreflexive semantics strategy

## Sorry Count (Critical Path)

| File | Count | Notes |
|------|-------|-------|
| Frame.lean | 1 | bx_le_refl (intentionally invalid) |
| CanonicalModel.lean | 6 | Dead code + genuinely false lemmas |
| RootScopedChain.lean | 8 | 3 intentionally invalid + 5 original sorry sites |
| CanonicalChain.lean | 2 | Reflexive intro (intentionally invalid) |
| TruthLemma.lean | 2 | Reflexive backward (intentionally invalid) |

## Verification
- `lake build`: PASSES (950 jobs, 0 errors)
- No new axiom declarations (0 total)
- All sorry sites are in proofs, not definitions
