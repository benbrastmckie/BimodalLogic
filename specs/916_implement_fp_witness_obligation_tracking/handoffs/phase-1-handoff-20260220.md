# Handoff: Task 916 Phase 1

**Date**: 2026-02-20
**Session**: sess_1771630142_572e90
**Status**: BLOCKED - Mathematical obstruction identified

## Immediate Next Action

Revise the implementation plan. The current plan (implementation-002.md) is based on an inner-chain approach that has a fundamental mathematical gap: F-formula persistence through Lindenbaum extensions is not provable for Zorn-based (non-constructive) Lindenbaum. A new plan is needed that uses one of the viable alternative approaches identified below.

## Current State

- **File**: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- **Sorries**: 2 remain at lines 919 and 926 (unchanged)
- **No code changes made**: The obstruction was identified during analysis before coding

## The Mathematical Obstruction

### Problem Statement

To prove `forward_F` (if F(psi) in M_t, then exists s > t with psi in M_s), we need psi to appear in the chain at some future time. The chain builds M_{t+1} from GContent(M_t) via Lindenbaum extension.

### What Works

1. **F-preserving seed**: `GContent(M) union {F(psi) | F(psi) in M}` is a subset of M and hence consistent. Using this as the Lindenbaum seed preserves ALL F-obligations from M_n to M_{n+1}. (Proven in run_code session.)

2. **Single witness seed**: `{psi} union GContent(M)` is consistent when F(psi) in M (this is `temporal_witness_seed_consistent`, already proven in the codebase).

3. **GContent monotonicity**: Through an inner chain of MCSes built via GContent + witness seeds, GContent is monotone (proven in run_code session).

### What Fails

1. **Combined seed**: `{psi} union GContent(M) union {F(chi) | F(chi) in M}` can be INCONSISTENT. Counterexample: if psi = G(neg chi) for some chi with F(chi) in M, then {G(neg chi), F(chi)} = {G(neg chi), neg(G(neg chi))} is trivially inconsistent. This means we CANNOT simultaneously add a witness AND preserve all F-obligations.

2. **F-persistence through plain Lindenbaum**: If the seed for M_{n+1} is GContent(M_n) (without F-preservation), Zorn-based Lindenbaum may freely add G(neg psi), killing F(psi). Once G(neg psi) enters the chain, it propagates forward forever via GContent, permanently preventing psi from appearing.

3. **Inner chain witness accumulation**: The plan's inner chain (MCS_0, MCS_1, ...) where each step adds one witness using GContent + {witness} does NOT accumulate witnesses. Witness psi_k is in MCS_{k+1}, but may NOT be in MCS_{k+2} or later inner-chain MCSes, because each step uses GContent of the PREVIOUS intermediate MCS, not the accumulated set.

4. **Omega-rule gap**: There is no proof-theoretic omega-rule in TM logic that derives G(neg psi) from "neg psi at all future times." So the contradiction argument (assume psi absent everywhere, derive contradiction with F(psi)) does not work.

### Root Cause

The Zorn-based Lindenbaum (`set_lindenbaum`) is an opaque existence proof. It produces SOME MCS extending the seed, but its behavior is uncontrollable. When we need SPECIFIC formulas to be in the MCS (beyond the seed), we cannot guarantee it. The F-formula persistence problem is a manifestation of this: Lindenbaum can consistently choose to include G(neg psi) at any step, killing the F-obligation.

## Viable Alternative Approaches

### A: Constructive Formula-by-Formula Lindenbaum

Build MCSes using a formula-by-formula process where each formula is either added (if consistent) or its negation is added. Control the enumeration order so that for each psi, psi is processed before G(neg psi). This ensures: if F(psi) is in the seed, and psi is processed before G(neg psi), then at the point where psi is considered, {psi} union accumulated_set is consistent (because G(neg psi) hasn't been added yet, and the accumulated set is a subset of GContent + added formulas that don't conflict with psi).

**Challenge**: The research (research-002.md section 4) showed that the boneyard's TemporalLindenbaum.lean attempt at constructive Lindenbaum has 4 sorries. The specific issue is proving that the formula-by-formula limit is an MCS (maximality). However, the maximality proof may be easier than the temporal saturation proof that TemporalLindenbaum.lean attempted.

**Effort**: ~15-25 hours

### B: Canonical Model (Tree) + Unraveling

Instead of building a chain directly, use the canonical model (worlds = all MCSes, R(M,N) iff GContent(M) subset N) which trivially satisfies forward_F via the existence lemma. Then unravel the canonical model into a linear chain using a path-based construction.

**Challenge**: Unraveling requires showing that the canonical model has a path from M_0 through all required witness worlds. This is essentially the same difficulty.

**Effort**: ~20-30 hours

### C: Dependent Choice with Priority Queue

Use dependent choice (a consequence of AC) to build the chain. At each step n+1, use Classical.choice to select an MCS that:
1. Extends GContent(M_n)
2. Witnesses the highest-priority unwitnessed F-formula from the chain history

The priority queue processes F-formulas in order of their introduction time. When F(psi) enters at time t, it gets priority based on (t, encode(psi)). At step n+1, find the highest-priority unwitnessed F(psi) where F(psi) is STILL in M_n, and witness it.

**Key insight**: With the F-preserving seed, F(psi) persists forever. So F(psi) is always available for witnessing. The issue was combining witness + F-preservation. Solution: at the witnessing step, DON'T preserve other F-formulas. At subsequent steps, use F-preserving seed to re-establish them.

Wait -- once killed, an F-formula can't be re-established (G(neg chi) propagates forever).

Actually, with the F-preserving seed at every step EXCEPT the witness step: F-formulas persist until the witness step, may die at the witness step, then... they're dead. The F-preserving seed at step n+2 would include F-formulas from M_{n+1}, which no longer has the dead ones.

**This doesn't work as stated.** Need more careful design.

**Effort**: ~20-30 hours

### D: Admit the Two-Step Structure (Most Pragmatic)

Prove forward_F and backward_P using a DIFFERENT chain (not the current dovetailForwardChainMCS/dovetailBackwardChainMCS). The different chain uses the F-preserving seed, guaranteeing F-persistence. Then prove forward_F by constructing the witness via AC at each step:

For F(psi) in M_t: define N = Lindenbaum({psi} union GContent(M_t)). psi in N and GContent(M_t) subset N. Now REPLACE M_{t+1} with N in the chain, and rebuild the remainder using F-preserving seed from N onwards.

The BFMCS family is defined as: for t <= t_0, use original chain. For t > t_0, use the spliced chain.

But the family must be a single fixed function, not a per-F-formula splice.

**Alternatively**: Define the chain using recursion where at each step, the MCS is chosen (via Classical.choice) to extend GContent of the predecessor AND to satisfy forward_F for one specific F-formula using a dovetailing priority scheme.

**Effort**: ~15-20 hours

## What NOT to Try

1. **Joint F-witness consistency**: Adding multiple witnesses ({psi_1, ..., psi_k} union GContent(M)) can be inconsistent. Do not attempt to add all witnesses at once.

2. **Inner chain with GContent stepping**: Witnesses don't accumulate through GContent-based inner chain steps. Each intermediate MCS may lose previous witnesses.

3. **F-persistence through plain GContent seed**: Zorn-based Lindenbaum can freely add G(neg psi), killing F-obligations. Don't assume F-formulas persist without an F-preserving seed.

4. **Omega-rule contradiction**: The proof system has no omega rule. "neg psi at all future times" does NOT imply G(neg psi).

## Critical Context

1. `temporal_witness_seed_consistent` is the ONLY proven consistency lemma for witness seeds
2. `FPreservingSeed M = GContent M union {phi in M | exists psi, phi = Formula.some_future psi}` is a subset of M, hence consistent (proven in analysis session)
3. The existing chain (dovetailForwardChainMCS) uses plain GContent as seed
4. The cross-sign propagation (forward_G and backward_H) are fully proven and work correctly
5. Only 2 sorries remain: forward_F (line 919) and backward_P (line 926)

## References

- Plan: `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-002.md`
- Research: `specs/916_implement_fp_witness_obligation_tracking/reports/research-002.md`
- Source: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Witness consistency: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (temporal_witness_seed_consistent, line ~461)
