# Handoff: Phase 5 Gate Complete, Phase 6 Blocked on A4a

## Session
- **Session ID**: sess_1777437685_2c16e8
- **Date**: 2026-04-28
- **Phase**: 5 completed, 6 started (analysis only)

## What Was Accomplished

### Phase 5 (GATE): Lemma 2.7 Validity Verification -- COMPLETED

**Gate verdict: VALID. Proceed with Strategy 1.**

Lemma 2.7 (Until-formula splitting) IS valid under strict/open-guard semantics.
The earlier "FALSE" annotation in PointInsertion.lean was for a "D2 branch" proof
approach that predated BX13 (enrichment_until, Burgess A3a). With BX13 now available
(added in Phase 2), Burgess's ORIGINAL proof works:

1. BX5 (self_accum_until) enriches the Until guard
2. BX7 (linear_until) provides the three-way disjunction
3. BX13 (enrichment_until) simplifies the surviving disjunct
4. BX1/BX2 (monotonicity) rule out two disjuncts

None of these axioms depend on BX9 (removed) or the T-axiom.

### Documentation Updates
- Updated PointInsertion.lean module docstring: Lemma 2.7 re-assessed as VALID
- Updated withdrawn lemmas section with re-assessment details
- Updated sorry comments in CounterexampleElimination.lean to reference correct phases

### Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- documentation
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- sorry comments

## Phase 6 Analysis: Critical Blocker Discovered

### The A4a Problem

Burgess's Lemma 2.6 proof uses axiom A4a:
`U(p,q) AND NOT U(p,r) -> U(q AND NOT r, q)`

This axiom is **NOT in our axiom system** and **NOT valid under strict/open-guard
semantics**. It was never added (line 219 of Axioms.lean notes BX8 was removed for
similar reasons).

The PointInsertion.lean docstring (line 21) claims:
"A4a's role (Lemma 2.6 point insertion): BX5 + BX6 (absorb_until)
+ BX7 (linear_until) provide the needed structural properties."

### What A4a Does in Lemma 2.6's Proof

Burgess constructs seed D0 = {S(alpha, beta) : alpha in A, beta in B} union B union
{neg delta} union {U(gamma, beta) : gamma in C, beta in B}. The consistency proof
shows each finite conjunction zeta = S(alpha, beta) AND beta AND neg_delta AND
U(gamma, beta) is consistent. The key step uses:

1. U(gamma, beta) in A (from r(A,B,C))
2. BX5: U(gamma, beta AND U(gamma,beta)) in A
3. NOT U(gamma, beta AND delta) in A (from delta not in B -- this needs the
   maximality condition + a careful argument)
4. **A4a**: combines (2) and (3) to get U(beta AND U(gamma,beta) AND neg_delta, beta) in A

Without A4a, step 4 requires an alternative derivation. The claim is BX5+BX6+BX7
suffice, but this has NOT been verified in the formalization.

### Proposed Alternative for A4a

The role of A4a is to produce `U(guard AND extra, guard)` from `U(event, guard)` and
`NOT U(event, guard AND more)`. Potential alternatives:

1. **BX7 approach**: Use BX7 linearity on two Until formulas to get a three-way
   disjunction. Rule out two disjuncts using the negation hypothesis. This is
   similar to how Lemma 2.7 works.

2. **Direct seed construction**: Instead of Burgess's full D0 seed, construct D
   from a smaller seed that only requires g_content(A) and then separately
   establish the Until/Since connections.

3. **Derivability of A4a from existing axioms**: A4a might be derivable from
   BX5+BX6+BX7 as a meta-theorem. This needs investigation.

### Recommendation

Before proceeding with Phase 6, investigate whether A4a is derivable from
BX5+BX6+BX7 under strict semantics. If yes, formalize this as a derived theorem
and then follow Burgess's proof. If no, find an alternative proof of Lemma 2.6
splitting that avoids A4a.

This investigation is best done as a research task (/research 107 with focus on
A4a derivability).

## Sorry Site Status

All 8 sorry sites remain (7 in CounterexampleElimination.lean, 1 density self-pair).
The sorry comments have been updated to reference the correct plan phases.

### Sorry Count by Type:
- C5 forward (line ~830): 1 sorry (Phase 9)
- C5 backward (line ~897): 1 sorry (Phase 9)
- C4 forward (line ~937): 1 sorry (Phase 11)
- C4 backward (line ~975): 1 sorry (Phase 11)
- g_prop forward (line ~1011): 1 sorry (Phase 11)
- h_prop backward (line ~1043): 1 sorry (Phase 11)
- density self-pair (line ~1159): 1 sorry (Phase 10)
- ChronicleToCountermodel FUC (line ~615): 1 sorry (Phase 12)
- ChronicleToCountermodel FSC (line ~619): 1 sorry (Phase 12)

## Build Status

`lake build` succeeds. No regressions.
