# Phase 1 Results: A3a/A4a Derivability and ParametricTruthLemma Fix

## Status: COMPLETED

## Summary

Phase 1 had two objectives: verify A3a/A4a derivability from BX axioms under strict semantics, and fix the 2 ParametricTruthLemma sorry sites. Both objectives were addressed.

## ParametricTruthLemma Fix (2 sorry sites eliminated)

### Problem

Both `parametric_canonical_truth_lemma` and `parametric_shifted_truth_lemma` in `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` were sorry'd during the irreflexive semantics switch. The commented-out proofs used reflexive quantifiers (`<=` for G/H cases) that no longer matched the strict semantics (`<` in `truth_at`).

### Root Cause

The G/H backward cases constructed a `TemporalCoherentFamily` and called `temporal_backward_G`/`temporal_backward_H`, which require `forall s, t <= s -> phi in fam.mcs s`. But under strict semantics, the truth conditions for G give only `forall s, t < s -> truth ... s psi`, which via IH produces `forall s, t < s -> psi in fam.mcs s` -- a weaker hypothesis.

### Fix

Replaced the `TemporalCoherentFamily` construction with direct use of `temporal_backward_G_with_fwd_F` and `temporal_backward_H_with_bwd_P`, which accept the strict quantifier (`<`) and take an explicit `forward_F`/`backward_P` hypothesis extracted from `h_tc : B.temporally_coherent`.

Key changes in both truth lemmas:
- G backward: `temporal_backward_G_with_fwd_F fam t psi (fun h_F_neg => h_forward_F t (Formula.neg psi) h_F_neg) h_all_mcs`
- H backward: `temporal_backward_H_with_bwd_P fam t psi (fun h_P_neg => h_backward_P t (Formula.neg psi) h_P_neg) h_all_mcs`

The Until/Since cases were already correct -- the coherence definitions (`backward_until_since_coherent`, `forward_until_since_coherent`) already use strict quantifiers matching `truth_at`.

### Verification

- Zero sorries remain in `ParametricTruthLemma.lean`
- `lake build` succeeds with no regressions
- No new axioms introduced

## A3a/A4a Derivability (Not Valid Under Strict Semantics)

### Finding

A3a (`p /\ U(q,r) -> U(q /\ S(p,r), r)`) and A4a (`U(p,q) /\ ~U(p,r) -> U(q /\ ~r, q)`) are NOT valid under irreflexive (strict) temporal semantics.

### Counterexample for A3a

Consider times {0, 1, 2} with p true only at 0, q true at 0 and 1, r true at 2.
- At time 0: `p /\ U(q,r)` holds (p at 0; witness s=2, r(2), q on [0,2)).
- A3a's conclusion `U(q /\ S(p,r), r)` fails at 0: the guard requires `S(p,r)` at u=0, which needs exists v < 0, r(v). No such v exists under strict Since.

### Impact

The Burgess chronicle construction (Phases 2-5) uses A3a in Lemma 2.3 and A4a in Lemma 2.6. Under strict semantics, the algebraic content of these axioms is provided directly by the BX axioms:
- BX4 (connect_future) + BX5 (self_accum_until) subsume A3a's role
- BX5 + BX6 (absorb_until) + BX7 (linear_until) subsume A4a's role

Documentation added to `Theories/Bimodal/Theorems/TemporalDerived.lean` explaining this finding.

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- eliminated 2 sorry sites
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- added A3a/A4a non-derivability documentation

## Build Verification

```
Build completed successfully (949 jobs).
```

No new sorry warnings. Existing sorry warnings are from `RootScopedChain.lean` (3 sorry sites addressed by Phase 5) and pre-existing sorry sites in other modules.
