# Implementation Summary: Close BXCanonical Embedding (v11)

- **Task**: 93 - Complete BXCanonical embedding
- **Plan**: plans/11_bxcanonical-embedding.md
- **Status**: BLOCKED
- **Phases Completed**: 0 / 4

## Outcome

All 4 active-path sorry sites remain open. The implementation is blocked by a fundamental mathematical obstacle in the scheduling chain construction that prevents proving `bx_fmcs_forward_F` (F-formula eventuality resolution).

## Root Cause Analysis

The scheduling chain in `CanonicalModel.lean` uses `fwd_succ(M, hM, schedule(n))` at each step. At resolving steps (where F(schedule(n)) is in the current MCS), the Lindenbaum seed is `{schedule(n)} union g_content(M)`, which does NOT include other F-formulas (f_carry). These F-formulas can be lost at resolving steps.

Once F(psi) is lost (replaced by G(not psi) in the MCS), the loss is permanent: G(not psi) propagates forward via g_content (using BX4: G(alpha) -> G(G(alpha))), so psi never appears in any later chain position.

### Why Enriching the Seed Fails

Adding f_carry to the resolving seed is INVALID. The enriched seed `{chi} union g_content(M) union f_carry(M)` can be inconsistent:

**Counterexample**: When G(F(alpha) -> not psi) in M, F(alpha) in M, and F(psi) in M:
- (F(alpha) -> not psi) in g_content(M) (from G-version)
- F(alpha) in f_carry(M)
- psi in the resolving target
- Together: F(alpha) and (F(alpha) -> not psi) gives not psi, contradicting psi

This scenario IS realizable in BX temporal logic (the ψ-witness occurs before the α-witness on the time line).

### Why Choosing a Specific Extension Fails

Trying to pick a Lindenbaum extension that preserves F(psi): `{chi} union g_content(M) union {F(psi)}` can also be inconsistent when G(chi -> G(not psi)) in M, because chi -> G(not psi) would be in g_content, making G(not psi) derivable from the seed.

## Impact on Sorry Sites

| Line | Theorem | Status | Dependency |
|------|---------|--------|-----------|
| ~518 | bx_fmcs_forward_F | BLOCKED | Direct: unprovable for scheduling chain |
| ~525 | bx_fmcs_backward_P | BLOCKED | Symmetric to forward_F |
| ~649 | bx_bfmcs_restricted_buc | BLOCKED | Needs step transfer (depends on chain properties) |
| ~655 | bx_bfmcs_restricted_fuc | BLOCKED | Needs forward_F for Until witness |
| ~637 | bx_bfmcs_restricted_tc | BLOCKED | Delegates to forward_F/backward_P |

All 4 sorry sites are interconnected through forward_F.

## Recommended Resolution Path

### Option A: Quasimodel-Based FMCS (Recommended)

Replace the scheduling chain with a quasimodel construction:
1. Build finite Hintikka chains within deferralClosure(root)
2. Each chain step discharges one defect while preserving others within the closure
3. Forward_F holds BY CONSTRUCTION (defects discharged in finite steps)
4. Requires ~300-500 new lines, replacing `bx_bfmcs` with a new construction
5. Existing quasimodel infrastructure (~2132 lines in Quasimodel/ and Filtration/) provides building blocks

### Option B: Non-Constructive Existence

Prove existence of the required chain using Zorn's lemma / compactness rather than constructing it step by step.

## Changes Made

1. Added detailed obstacle analysis documentation to `CanonicalModel.lean` (lines 491-509)
2. Marked unrestricted coherence theorems as DEAD CODE (not on active completeness path)
3. Created obstacle handoff document at `handoffs/11_forward-f-obstacle.md`
4. Updated plan status markers

## Build Status

`lake build` passes with the same sorry count as before (no regression).
