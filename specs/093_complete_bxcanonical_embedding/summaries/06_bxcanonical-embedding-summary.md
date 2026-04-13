# Implementation Summary: Task 93 - BXCanonical Embedding (Plan 06)

- **Task**: 93 - Complete BXCanonical embedding
- **Plan**: plans/06_bxcanonical-embedding.md
- **Status**: BLOCKED
- **Session**: sess_1776107176_04850a
- **Date**: 2026-04-13

## Result

Plan 06 could not be implemented because its core mechanism is mathematically flawed. No source code changes were made.

## Analysis Performed

Detailed analysis of the `until_neg_carry` approach proposed in Plan 06, discovering three independent flaws:

### Flaw 1: Forward Stability is Semantically Invalid
`neg(phi U psi) in chain(t)` does NOT imply `neg(phi U psi) in chain(t+1)` over linear temporal orders. Concrete counterexample constructed showing the implication fails when phi changes from false to true between times 0 and 1.

### Flaw 2: Resolving Seed Inconsistency
The enriched resolving seed `{psi} union g_content(M) union until_neg_carry(M)` can be inconsistent. BX8 (refl_intro_until) gives `neg(phi U psi) -> neg psi`, so `{psi, neg(phi U psi)}` derives bot. This occurs when resolving F(psi) while neg(phi U psi) is in the seed.

### Flaw 3: Step Transfer Failure at Resolving Steps
Even the guarded step transfer `(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)` fails when the resolving step at r puts (phi U psi) directly into chain(r+1) while neg(phi U psi) in chain(r).

## Phases

| Phase | Status | Notes |
|-------|--------|-------|
| 1 | BLOCKED | Core mechanism (until_neg_carry) is invalid |
| 2 | BLOCKED | Depends on Phase 1 |
| 3 | NOT STARTED | Deferral seeds -- independent, may still be viable |
| 4 | BLOCKED | Depends on Phases 2 and 3 |
| 5 | NOT STARTED | Cleanup |

## Prior Research Error

The team research (Report 06, 4 teammates) endorsed the until_neg_carry approach with 90-95% confidence. The error was:
- Teammate D assumed `{psi} union g_content(M) union until_neg_carry(M) subset M`, which fails because `{psi} not subset M`
- No teammate identified the semantic invalidity of forward stability for negated Until

## Alternative Approaches Identified

1. **Deterministic Chain (Option A)**: Port from Boneyard. Has backward Until sorry-free. Forward_F remains open.
2. **Hybrid Chain (Option B)**: Combine scheduling + X-operator. Blocked by `G(alpha) -> (bot U alpha)` not being derivable in BX.
3. **Direct Proof (Option C)**: New proof technique without step transfer. No candidate identified.
4. **Strengthened Chain (Option D)**: Add x_content to seeds. Consistency unclear.

## Recommendation

The task needs plan revision. The most promising path is Option A: port the deterministic chain's backward Until proof and combine it with a separate approach for restricted forward_F.

## Artifacts
- Handoff: `specs/093_complete_bxcanonical_embedding/handoffs/01_until-neg-carry-flaw.md`
- Plan update: Phase 1 marked [BLOCKED]
