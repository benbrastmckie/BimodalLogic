# Implementation Plan: Task #48 (v7)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: v6 phases 1-5 complete (2 sorries remaining)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/09_boundary-case.md
- **Previous Plans**:
  - plans/06_bounded-witness.md (5/5 phases complete, 2 sorries at boundary)
- **Artifacts**: plans/07_boundary-resolution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan resolves the 2 remaining sorries in the bounded witness approach. Both arise when `F(psi)` is at the boundary of `deferralClosure` - inside the closure but `FF(psi)` is outside.

### The Problem

Standard proof uses negation completeness: `FF(psi) ∉ M` + `FF(psi) ∈ closure` ⟹ `¬FF(psi) ∈ M`.
But when `FF(psi) ∉ deferralClosure`, negation completeness doesn't apply.

### The Solution (Option C from research)

**Key insight**: When `F(psi)` is at the boundary, the F-step dichotomy (`psi ∈ successor` OR `F(psi) ∈ successor`) cannot defer forever because `FF(psi)` being outside closure means it can never block the resolution.

We prove a helper lemma that at the boundary, `F(psi)` must eventually resolve to `psi`.

## Goals & Non-Goals

**Goals**:
- Remove sorry at line ~3077 in `restricted_single_step_forcing`
- Remove sorry at line ~3236 in `restricted_succ_propagates_F_not`
- Net sorry reduction: from 4 to 2 (removing the 2 new boundary sorries)

**Non-Goals**:
- Changing the bounded_witness structure (it works, just needs the helper lemmas fixed)
- Touching the 2 preexisting deprecated sorries

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Well-founded argument is complex | Medium | Medium | Use existing Nat.lt_wfRel on chain index |
| F-step doesn't directly give resolution | High | Low | The FF-not-in-dc fact blocks the defer option |
| Need new structural lemmas | Medium | Medium | Leverage existing deferralClosure lemmas |

## Implementation Phases

### Phase 1: Analyze the Succ F-step behavior at boundary [NOT STARTED]

**Goal**: Understand exactly what F-step tells us when FF(psi) ∉ deferralClosure.

**Tasks**:
- [ ] Read the Succ definition and f_content property
- [ ] Trace through what happens when F(psi) ∈ chain(k), FF(psi) ∉ dc
- [ ] Identify whether there's a direct path to `psi ∈ chain(k+1)` without needing GG argument
- [ ] Check if f_content behavior already excludes FF(psi) when outside dc

**Key lemma to find or prove**:
```lean
-- If F(psi) in M and FF(psi) not in deferralClosure, then F(psi) not in f_content(M)
-- Because f_content(M) = {chi | F(chi) in M} and F(F(psi)) not in M (not in dc)
lemma boundary_F_not_in_f_content
    (h_F_in : F psi ∈ M) (h_FF_not_dc : F (F psi) ∉ deferralClosure phi)
    (h_M_restricted : M ⊆ deferralClosure phi) :
    F psi ∉ f_content M
```

**Timing**: 0.5 hours

**Files to examine**:
- `Theories/Bimodal/Metalogic/Succ/SuccRelation.lean`

---

### Phase 2: Fix restricted_succ_propagates_F_not boundary case [NOT STARTED]

**Goal**: Remove the sorry when FF(psi) ∉ deferralClosure.

**Context**: We need to prove `F(psi) ∉ chain(k+1)` given `FF(psi) ∉ chain(k)` and `FF(psi) ∉ dc`.

**Proof strategy**:
```lean
-- Given: FF(psi) not in chain(k), FF(psi) not in dc
-- Goal: F(psi) not in chain(k+1)

-- Case 1: F(psi) not in dc
--   Then F(psi) not in chain(k+1) trivially (chain subset of dc)
--   ALREADY HANDLED in current code

-- Case 2: F(psi) in dc but FF(psi) not in dc
--   This is the boundary case (sorry)
--
--   Key: FF(psi) not in dc means FF(psi) not in chain(k+1)
--   So F(psi) not in f_content(chain(k+1))
--
--   By Succ f_content property:
--   f_content(chain(k)) ⊆ chain(k+1) ∪ f_content(chain(k+1))
--
--   If F(psi) in chain(k+1), then psi in f_content(chain(k+1))
--   That means F(psi) in chain(k+1), so psi in ... (circular)
--
--   Alternative: Show F(psi) cannot be added to chain(k+1)
--   The successor construction adds G-content and resolves F-content
--   F(psi) can only persist if it's "deferred" via f_content
--   But to defer F(psi), need F(psi) in f_content(chain(k+1))
--   Which requires FF(psi) in chain(k+1)
--   But FF(psi) not in dc, so not in chain(k+1)
--   Therefore F(psi) cannot be deferred
--   So if psi was in f_content(chain(k)), psi must be in chain(k+1)
--   And F(psi) not in chain(k+1) (resolved, not deferred)
```

**Tasks**:
- [ ] Complete the proof for case when F(psi) ∈ dc but FF(psi) ∉ dc
- [ ] Use the fact that FF(psi) ∉ dc ⟹ F(psi) ∉ f_content(chain(k+1))
- [ ] Show this blocks the "defer" option, forcing resolution

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (line ~3236)

---

### Phase 3: Fix restricted_single_step_forcing boundary case [NOT STARTED]

**Goal**: Remove the sorry when FF(psi) ∉ deferralClosure.

**Context**: We need to prove `psi ∈ chain(k+1)` given `F(psi) ∈ chain(k)`, `FF(psi) ∉ chain(k)`, and `FF(psi) ∉ dc`.

**Proof strategy**:
```lean
-- Given: F(psi) in chain(k), FF(psi) not in chain(k), FF(psi) not in dc
-- Goal: psi in chain(k+1)

-- By F-step property (Succ.f_step):
-- psi in f_content(chain(k)) => psi in chain(k+1) OR psi in f_content(chain(k+1))

-- Since F(psi) in chain(k), psi in f_content(chain(k))

-- Case A: psi in chain(k+1) -- DONE

-- Case B: psi in f_content(chain(k+1))
--   This means F(psi) in chain(k+1)
--   But by Phase 2, we showed F(psi) not in chain(k+1) when FF(psi) not in dc
--   (Using restricted_succ_propagates_F_not with d=1)
--   Contradiction! So Case B is impossible.

-- Therefore psi in chain(k+1)
```

**Tasks**:
- [ ] Use the F-step dichotomy
- [ ] Apply `restricted_succ_propagates_F_not` (now fixed from Phase 2) to rule out Case B
- [ ] Conclude `psi ∈ chain(k+1)`

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (line ~3077)

---

### Phase 4: Verify and cleanup [NOT STARTED]

**Goal**: Verify no sorries remain in the new theorems and clean up.

**Tasks**:
- [ ] Run `lake build` to verify compilation
- [ ] Count sorries: should be 2 (the preexisting deprecated ones)
- [ ] Update documentation
- [ ] Remove any debug comments

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] `grep -c "sorry" SuccChainFMCS.lean` returns 2 (only deprecated sorries)
- [ ] `restricted_single_step_forcing` has no sorries
- [ ] `restricted_succ_propagates_F_not` has no sorries
- [ ] `restricted_bounded_witness` still compiles
- [ ] `restricted_forward_chain_iter_F_witness` still compiles

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Boundary sorries removed
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/07_boundary-resolution-summary.md` - Summary

## Rollback/Contingency

If the direct proof doesn't work:

1. **Alternative: Track boundary depth explicitly**
   Add a parameter tracking "steps remaining at boundary" and prove it decreases

2. **Alternative: Use finiteness of deferralClosure**
   The chain is eventually constant (only finitely many formulas), so deferral must stop

3. **Alternative: Inline in bounded_witness**
   Handle boundary case specially in the main induction, avoiding the helper lemmas

## Key Insight

The critical realization is that **F(psi) cannot be deferred at the boundary**:

- To defer `F(psi)` from `chain(k)` to `chain(k+1)`, we need `F(psi) ∈ f_content(chain(k+1))`
- That requires `FF(psi) ∈ chain(k+1)`
- But `FF(psi) ∉ deferralClosure`, so `FF(psi) ∉ chain(k+1)`
- Therefore deferral is impossible, and `psi` must be resolved into `chain(k+1)`

This is why the boundary case is actually EASIER than the general case - there's no deferral option!
