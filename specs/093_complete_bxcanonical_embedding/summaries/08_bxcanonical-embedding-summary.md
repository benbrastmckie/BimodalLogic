# Implementation Summary: Close TaskModel Embedding Sorry (v8)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [BLOCKED]
- **Session**: sess_1776111737_2e444d
- **Date**: 2026-04-13
- **Plan**: plans/08_bxcanonical-embedding.md
- **Agent**: lean-implementation-agent

## Outcome

No code changes. All 6 sorry sites remain. Phase 1 of the plan is BLOCKED due to
fundamental issues with the scheduling chain architecture that prevent proving the
three restricted coherence conditions.

## Analysis Performed

Exhaustive analysis of the three restricted coherence sorry sites:

1. `bx_bfmcs_restricted_tc` (restricted forward_F/backward_P) -- line 603
2. `bx_bfmcs_restricted_buc` (restricted backward Until/Since) -- line 621
3. `bx_bfmcs_restricted_fuc` (restricted forward Until/Since) -- line 627

All three reduce to two irreducible blockers:

### Blocker 1: Forward_F

`F(psi) in chain(t) -> exists s > t, psi in chain(s)`.

The scheduling chain's resolving branch seed (`{target} union g_content(M)`) does NOT
include F-formulas. At resolving steps for other formulas, F(psi) may be lost because
the Lindenbaum extension is non-deterministic. The f_carry mechanism only works at
non-resolving steps.

Adding f_carry to the resolving seed creates genuine inconsistencies (counterexample:
`F(G(neg psi))` in f_carry conflicts with `psi` in the resolving target).

### Blocker 2: Backward Until Step Transfer

`(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)`.

On Z (integers), this is semantically valid. But it is NOT derivable from the BX axiom
system because BX axiomatizes ALL linear orders, including dense ones where the step
transfer is invalid. The chain construction over Z doesn't build this property in.

## Approaches Analyzed

| Approach | Result | Reason |
|----------|--------|--------|
| Add f_carry to resolving seed | FAILS | Inconsistency counterexample |
| Add untilCarry to resolving seed | UNCERTAIN | Temporal K doesn't extend to Until elements |
| Add untilCarry to non-resolving only | PARTIAL | Forward persistence works, backward doesn't |
| BX12 reduction to forward Until | FAILS | (top U psi) not in subformulaClosure |
| Direct BX axiom step transfer | FAILS | Not a BX theorem |
| Scheduling argument alone | FAILS | F lost at resolving steps |
| Connect_past + backward_H argument | INCONCLUSIVE | Gets F(phi U psi) but can't derive (phi U psi) |

## Recommended Next Steps

1. **Attempt resolving seed consistency with untilCarry** (Plan Phase 2): This is the
   highest-probability path. The consistency of `{psi} union g_content(M) union untilCarry(M, root)`
   when `F(psi) in M` may be provable via a novel argument combining temporal K with
   the until_induction axiom. Estimated 4 hours, 60% success probability.

2. **If Phase 2 fails**: Replace the chain construction entirely with a quasimodel-based
   approach that resolves Until defects by construction. Estimated 15-20 hours.

## Artifacts

- `specs/093_complete_bxcanonical_embedding/handoffs/08_analysis-handoff.md` -- Detailed
  handoff with analysis of all approaches and their failure points
- No code changes to any Lean files

## Remaining Sorries

All 6 original sorry sites remain unchanged:
- Line 497: `bx_fmcs_forward_F` (unrestricted, dead code)
- Line 503: `bx_fmcs_backward_P` (unrestricted, dead code)
- Line 586: `bx_bfmcs_buc` (unrestricted, dead code)
- Line 591: `bx_bfmcs_fuc` (unrestricted, dead code)
- Line 621: `bx_bfmcs_restricted_buc` (active path, MUST close)
- Line 627: `bx_bfmcs_restricted_fuc` (active path, MUST close)
- Lines 603-615: `bx_bfmcs_restricted_tc` delegates to sorry lines 497, 503
