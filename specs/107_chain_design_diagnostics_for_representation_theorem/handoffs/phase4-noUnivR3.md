# Handoff: Phase 4 -- NoUnivBurgessR3 Stubs NOT Locally Closable

## Session: sess_1778014444_dca927
## Date: 2026-05-05
## Status: BLOCKED -- Requires Architectural Change

## Summary

The 6 NoUnivBurgessR3 sorry stubs in PointInsertion.lean CANNOT be closed with
local proofs. The property `~burgessR3(A, Set.univ, C)` for arbitrary MCS A, C is
NOT a theorem of J0 (the bimodal axiom system). This was previously confirmed by
team research (report 65) via semantic counterexample on a 2-point discrete order.

This handoff documents the full analysis and recommends the cleanest resolution.

## Sorry Sites

| Line | Function | Goal |
|------|----------|------|
| 178 | `lemma_2_4` | `~burgessR3 A Set.univ C` |
| 2717 | `lemma_2_6_splitting` | `~burgessR3 A Set.univ D` |
| 2719 | `lemma_2_6_splitting` | `~burgessR3 D Set.univ C` |
| 3596 | `lemma_2_7` | `~burgessR3 A Set.univ D` |
| 3598 | `lemma_2_7` | `~burgessR3 D Set.univ C` |
| 3686 | `lemma_2_7` (degenerate) | `~burgessR3 D Set.univ C` |

## Why Local Proofs Fail

### Semantic Counterexample (2-point discrete order)

On the model {0, 1} with strict order 0 < 1:
- A = MCS at point 0, C = MCS at point 1
- Under open-guard Until semantics: `untl(beta, gamma)` at point 0 requires
  gamma(1) and beta(r) for all r with 0 < r < 1. Since there are NO such r,
  beta holds vacuously.
- So `untl(beta, gamma) in A` iff `gamma in C` -- independent of beta.
- Similarly `snce(beta, alpha) in C` iff `alpha in A` -- independent of beta.
- Therefore `burgessR3(A, Set.univ, C)` holds on this model.

Since J0 axioms are sound on ALL linear orders (including discrete), no J0
derivation can refute `burgessR3(A, Set.univ, C)`.

### Available Hypotheses at Each Site

Exhaustive analysis of goal states (via lean_goal) shows:
- **Site 1**: Only `h_mcs : MCS A`, `h_C_mcs : MCS C`, `g_content A subset C`.
  No BurgessR3Maximal or additional structure.
- **Sites 2-5**: Have `BurgessR3Maximal A B C` but need `~burgessR3 A Set.univ D`
  or `~burgessR3 D Set.univ C` where D is a DIFFERENT MCS (Lindenbaum extension).
  Maximality of B w.r.t. C does NOT transfer to D.
- **Site 6**: Degenerate case with `BurgessR3Maximal A Set.univ D`. Same issue.

### Why BurgessR3Maximal Doesn't Help

`BurgessR3Maximal A B C` maximality: for CUD D with B strict-subset D,
`~burgessR3 A D C`. This gives `~burgessR3 A Set.univ C` when B consistent
(B strict-subset Set.univ since B is SDC). But:
- Sites needing `~burgessR3 A Set.univ D` (D != C): maximality is w.r.t. C, not D.
- Sites needing `~burgessR3 D Set.univ C` (D != A): maximality is w.r.t. A, not D.
- Site 1: No BurgessR3Maximal available at all.

### Why the "Bot-Guard Argument" Fails

The task description suggested deriving contradiction from `untl(bot, gamma) in A`.
While `untl(bot, gamma) -> F(gamma)` by BX10, `F(gamma) in A` is consistent.
Even `untl(bot, gamma) in A` for ALL gamma in C doesn't yield contradiction:
BX7 (linearity) can collapse pairs to avoid F(bot), and no finite conjunction
of C-elements produces bot (C is MCS, hence consistent).

## Root Cause

Phase 2 (commit ae5ad1890) changed BurgessR3Maximal from SDC-maximality to
CUD-maximality. This was NECESSARY to close sorry #1 (Case B: B is MCS).
The CUD maximality requires `h_no_univ` in `burgessR3Maximal_extension_exists`
(RRelation.lean line 763). Phase 1 had removed this parameter by using
SDC-maximality, but Phase 2 re-introduced it. The sorry stubs are a
consequence of this re-introduction.

## Why h_no_univ Is Needed

`burgessR3Maximal_extension_exists` (RRelation.lean:760) proves CUD-maximality
by Zorn over SDC family, then upgrading:
- Consistent CUD extension D: D is SDC, Zorn-maximal handles it.
- Inconsistent CUD extension D: D = Set.univ. Need `~burgessR3 A Set.univ C`.
  This is where h_no_univ is used (line 808).

The downstream user `BurgessR3Maximal_extension_fails` (PI:631) needs CUD
maximality because `DC({delta} union B)` may be Set.univ (inconsistent) when
B is MCS. SDC-maximality can't handle this case.

## Resolution Options

### Option A: Thread h_no_univ from chronicle construction (RECOMMENDED)

Add `h_no_univ : ~burgessR3 A Set.univ C` parameters to:
1. `lemma_2_4` (currently no such param)
2. `lemma_2_6_splitting` (needs two: A-D and D-C)
3. `lemma_2_7` (needs two: A-D and D-C, plus degenerate case)
4. `burgessR3Maximal_from_g_content_sub` (already has it)
5. Callers in CounterexampleElimination.lean
6. Callers in ChronicleConstruction.lean (omega chain functions)
7. Entry point in Completeness.lean

At the chronicle level (ChronicleConstruction.lean), h_no_univ can be proved
from Q-density: on dense orders, `untl(bot, gamma)` is unsatisfiable because
the guard interval always has intermediate points where bot must hold.

This is a parametric version of the cascade done in commit 6a8dd1976 (~40 functions).
It was previously implemented and then removed. Re-implementing it is the cleanest
fix because:
- No definition changes
- No proof restructuring
- The dense-order argument is semantically correct
- The cascade pattern is already known from the prior implementation

Estimated effort: 4-6 hours (threading + dense-order proof).

### Option B: Revert to SDC-maximality + restructure Case B

Change BurgessR3Maximal back to SDC-maximality (reverting Phase 2). Then
restructure the Case B proof (B is MCS) to avoid needing neg-until witness
from CUD extension failure. This is difficult because:
- The pos sub-case contradiction (untl(b /\ beta, gamma_hat) in A with
  contradictory guard) requires a specific target to contradict
- Without a neg-until witness, there's no contradiction target
- Burgess doesn't case-split on MCS B, suggesting his argument works
  differently, but translating his argument without case splits may
  require rethinking the seed consistency proof structure

Estimated effort: 8-12 hours, high risk.

### Option C: Add SetConsistent to burgessR3 definition

Modify `burgessR3 A B C` to include `SetConsistent B`. Then
`burgessR3 A Set.univ C` is trivially false. Cascades to ~136 references.

Estimated effort: 6-8 hours (mostly mechanical cascade).

### Option D: Universal h_no_univ (NoUnivBurgessR3 as parameter)

Add `h_no_univ : NoUnivBurgessR3` (forall A C, MCS A -> MCS C -> ~burgessR3 A Set.univ C)
as a top-level parameter. Simpler threading (single parameter instead of specific
instances). Proved at the completeness theorem level from Q-density.

This is a variant of Option A using the universal quantifier.

Estimated effort: 3-5 hours.

## Recommendation

Option D (universal NoUnivBurgessR3 parameter) is simplest:
1. Add `(h_nu : NoUnivBurgessR3)` to lemma_2_4, lemma_2_6_splitting, lemma_2_7
2. Each sorry becomes `h_nu _ _ h_mcs h_mcs_C` (or similar)
3. Thread through CounterexampleElimination and ChronicleConstruction
4. Prove `NoUnivBurgessR3` at Completeness.lean from dense-order argument

## Files to Modify (for Option D)

- `PointInsertion.lean`: Add h_nu param to 3 functions, close 6 sorries
- `CounterexampleElimination.lean`: Thread h_nu through eliminate_C5 etc.
- `ChronicleConstruction.lean`: Thread h_nu through omega chain functions
- `ChronicleToCountermodel.lean`: Thread h_nu to countermodel entry
- `Completeness.lean`: Prove NoUnivBurgessR3 from dense-order semantics
- `RRelation.lean`: Already has h_no_univ in burgessR3Maximal_extension_exists

## Context for Next Agent

- CWD: /home/benjamin/Projects/ProofChecker
- Branch: irr_until
- Prior cascade commit: 6a8dd1976 (shows which functions need h_no_univ)
- Phase 2 commit: ae5ad1890 (shows CUD reversion)
- lake build passes with current sorries
