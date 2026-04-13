# Handoff: BXCanonical Embedding Analysis

**Session**: sess_1776111737_2e444d
**Date**: 2026-04-13
**Agent**: lean-implementation-agent
**Context usage**: ~80% estimated

## Summary

Exhaustive analysis of the three restricted coherence sorry sites in CanonicalModel.lean.
No code changes made. The blocking issues are fundamental to the scheduling chain
architecture and require either a new chain construction or a novel proof technique.

## Key Findings

### The Three Sorry Sites

1. **`bx_bfmcs_restricted_tc`** (line 603): Restricted forward_F/backward_P. Currently
   delegates to unrestricted `bx_fmcs_forward_F` (line 497, sorry).

2. **`bx_bfmcs_restricted_buc`** (line 621): Restricted backward Until/Since coherence.
   Requires step transfer: `(phi U psi) in chain(r+1) -> phi in chain(r) -> (phi U psi) in chain(r)`.

3. **`bx_bfmcs_restricted_fuc`** (line 627): Restricted forward Until/Since coherence.
   Requires forward_F + backward step transfer for the guard.

### Root Cause: Two Irreducible Blockers

**Blocker 1: Forward_F.** `F(psi) in chain(t) -> exists s > t, psi in chain(s)`.
The scheduling chain's resolving branch seed is `{psi} union g_content(M)`.
F-formulas are NOT in this seed. At resolving steps for other formulas, F(psi)
may be lost to the Lindenbaum extension. f_carry only helps at non-resolving steps.

**Blocker 2: Backward Until step transfer.** `(phi U psi) in chain(r+1) -> phi in chain(r) -> (phi U psi) in chain(r)`.
On Z, this is semantically valid but NOT a BX theorem (fails on dense orders).
The chain construction doesn't build this property in. The formula `phi and F(phi U psi) -> (phi U psi)`
is valid on Z but not derivable from BX1-BX12, so it cannot be shown to hold in arbitrary BX-MCS.

### Approaches Analyzed and Why They Fail

1. **Add f_carry to resolving seed**: FAILS. Counterexample: `F(G(neg psi)) in f_carry`
   and `psi in {psi}` gives `G(neg psi) -> neg psi` at the resolution time, making
   the seed inconsistent. (Confirmed by Report 07 Finding 2.)

2. **Add untilCarry to resolving seed**: POTENTIALLY FAILS. When `G((a U b) -> neg psi) in M`
   and `(a U b) in untilCarry`, the seed `{psi, (a U b) -> neg psi, (a U b)}` derives bot.
   The temporal K argument cannot handle Until elements because `G(a U b) in M` is not
   guaranteed from `(a U b) in M`. (Analyzed exhaustively in this session.)

3. **Add untilCarry to non-resolving seed only**: SUCCEEDS for forward persistence
   of Until formulas through non-resolving steps. But backward step transfer and
   forward_F at resolving steps remain unsolved.

4. **BX12 reduction F(psi) -> (top U psi)**: FAILS for restricted case.
   `(top U psi)` is NOT in `subformulaClosure(root)`, so restricted Until coherence
   doesn't apply to it.

5. **Direct BX axiom argument for step transfer**: FAILS.
   `phi and F(phi U psi) -> (phi U psi)` is not derivable from BX.
   Valid on Z but not on dense orders, and BX axiomatizes all linear orders.

6. **Scheduling chain scheduling argument**: FAILS because F-formulas can be lost
   at any resolving step for a different formula, and once lost (`G(neg psi)` enters),
   the formula can never be resolved.

### Viable Paths Forward (from report and analysis)

**Path A: Prove resolving seed consistency with untilCarry (Plan Phase 2)**
- Seed: `{psi} union g_content(M) union untilCarry(M, root)`.
- Consistency proof: Use temporal K for g_content portion, then show the Until
  elements cannot create new derivations of neg(psi) that aren't already available
  from g_content alone.
- Novel argument needed: Perhaps via BX11 linearity to show F-formula compatibility
  with Until formulas, or via until_induction to derive contradictions.
- Risk: 40% chance of failure per report.
- If this succeeds: Until formulas persist through ALL steps. Forward_F follows from
  BX10 (`(phi U psi) -> F(psi)`) + scheduling. Backward step transfer follows from
  forward persistence (if `(phi U psi) in chain(r+1)` came from untilCarry, then
  `(phi U psi) in chain(r)` by definition).
- NOTE: Even if seed is consistent, Lindenbaum-introduced Until formulas in chain(r+1)
  don't guarantee presence in chain(r). Only untilCarry-sourced formulas do.

**Path B: Replace chain construction entirely**
- Build a quasimodel-style chain that satisfies all coherence by construction.
- Estimated 500-800 lines of new code.
- Uses existing `bx_until_eventuality_resolution` from Frame.lean as building blocks.
- The finite quasimodel chain discharges Until defects; extension to Z preserves coherence.

**Path C: Prove forward_F via a novel argument about Lindenbaum extensions**
- Show that the specific Lindenbaum extension used in set_lindenbaum preserves F-formulas
  when they are not contradicted by the seed.
- This requires analyzing the Lindenbaum construction (Zorn's lemma based) at a deeper level.
- The key: at the resolving step, `{psi} union g_content(M)` is consistent.
  If `F(chi) in M` and `F(chi)` is consistent with `{psi} union g_content(M)`,
  then the Lindenbaum extension COULD include `F(chi)`. But "could" is not "must".
- HOWEVER: by MCS maximality, `F(chi)` is in the extension iff `neg F(chi) = G(neg chi)`
  is NOT derivable from the seed. And `g_content(M) not derives G(neg chi)` iff
  `G(G(neg chi)) not in M` iff `F(F(chi)) in M` (by temp_4). Since `F(chi) in M`,
  by `F(F(chi)) <- F(chi)` ... actually `F(chi) -> F(F(chi))` by BX1/temp_4 duality:
  `F(F(chi)) = neg G(neg F(chi)) = neg G(G(neg chi))`. And `G(neg chi) -> G(G(neg chi))`
  (temp_4). Contrapositive: `neg G(G(neg chi)) -> neg G(neg chi)`, i.e., `F(F(chi)) -> F(chi)`.
  So `F(F(chi)) in M` implies `F(chi) in M` (which we have), but not the reverse.
  We need: `G(neg chi)` is not derivable from `{psi} union g_content(M)`.
  The temporal K argument shows: `g_content(M) derives G(neg chi)` iff `G(G(neg chi)) in M`,
  which is equivalent to `G(neg chi) in M` (temp_4 + BX1). And `G(neg chi) in M` iff
  `F(chi) not in M`. Since `F(chi) in M`, we have `G(neg chi) not in M`, so
  `g_content(M) not derives G(neg chi)`.
  But `{psi} union g_content(M)` MIGHT derive `G(neg chi)` if `psi -> G(neg chi)` is
  derivable from g_content. Hmm, `psi -> G(neg chi)` from g_content elements...
  this seems unlikely but possible in pathological cases.

## Recommendation for Next Session

**Start with Path A**: Attempt the resolving seed consistency proof with untilCarry.
Focus on proving that `{psi} union g_content(M) union untilCarry(M, root)` is consistent
when `F(psi) in M`. The key insight to explore: the `until_induction` argument applied
to each Until formula in the seed may provide the needed contradiction when combined
with the temporal K argument for g_content.

If Path A fails within 4 hours: Switch to Path B (new chain construction).

## Files to Modify

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- all changes here
- Potentially new file `RestrictedSeed.lean` for restricted carry definitions

## Current State

- No code changes made
- All 6 sorry sites remain (lines 497, 503, 586, 591, 621, 627)
- Plan Phase 1 marked [IN PROGRESS] but no code written
