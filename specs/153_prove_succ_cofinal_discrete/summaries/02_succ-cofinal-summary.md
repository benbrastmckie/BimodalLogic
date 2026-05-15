# Implementation Summary: Task #153

- **Task**: 153 - prove_succ_cofinal_discrete
- **Status**: PARTIAL (sorry not resolved)
- **Session**: sess_1778881209_c53644_t153
- **Plan**: specs/153_prove_succ_cofinal_discrete/plans/02_succ-cofinal-plan.md

## Outcome

The sorry at `succ_cofinal` (ChronicleToCountermodel.lean, line 1888) was NOT resolved. After thorough investigation of three distinct proof strategies (Prior-UZ + c5_strong, Z1 Doets maximum principle, gap point predecessor chain analysis), all were found to be blocked by the same fundamental issue: the Z+Z gap scenario is consistent with all available temporal axioms under strict (irreflexive) semantics. No source files were modified.

## Phase Results

| Phase | Status | Outcome |
|-------|--------|---------|
| 1: Infrastructure Inventory | COMPLETED | Full goal state and infrastructure catalogued |
| 2: Constant-MCS Exclusion | BLOCKED | Research finding is flawed; c5_strong guard is vacuously satisfied |
| 3: Non-Constant Gap Elimination | BLOCKED | Z1 blocked under strict semantics |
| 4: Verification and Documentation | COMPLETED | Build passes, comments updated |

## Key Finding: Research Report Flaw

The team research report (Teammate C, HIGH confidence) claimed the constant-MCS case could be excluded via Prior-UZ + c5_strong. This is incorrect:

- `limit_satisfies_c5_strong` for `U(phi, neg phi)` = `Formula.untl phi phi.neg` gives a witness `y` with `phi` at `y` (event) and `phi.neg` at intermediates (guard).
- The research confused event and guard: it claimed `neg phi in limit_f(y)`, but actually `phi in limit_f(y)` (the event is the first argument of untl, which is phi).
- In the discrete case, `y = succ(x)` is the immediate successor with NO intermediates. The guard `neg phi` at intermediates is vacuously satisfied.
- Therefore: no contradiction in the constant-MCS case via Prior-UZ + c5_strong, regardless of formula choice.

## Detailed Analysis of Three Approaches

### Approach 1: Prior-UZ + c5_strong (FAILS)

For any orbit point x and any formula phi in limit_f(x):
1. `F(phi) in limit_f(x)` (by backward_F, since phi at succ(x) > x) -- compiles
2. Prior-UZ: `F(phi) -> U(phi, neg phi)` in every MCS -- compiles
3. `U(phi, neg phi) in limit_f(x)` by implication_property -- compiles
4. c5_strong: witness y with phi in limit_f(y) and neg phi at intermediates
5. **Failure**: y can be succ(x) with empty intermediates. phi in limit_f(y) is trivially true. No contradiction.

This fails for ANY choice of phi, including top_formula, specific discriminating formulas, etc. The issue is structural: adjacent points have no intermediates for the guard to be non-vacuous.

### Approach 2: Z1 Doets Maximum Principle (FAILS)

Z1 = `G(Gphi->phi) -> (FGphi -> Gphi)`:
- **Constant-MCS case**: If all limit_dom points have the same MCS A, then for phi in A: G(phi) in A (backward_G), so (Gphi->phi) = (A-member -> A-member) is trivially true. G(Gphi->phi) in A. FGphi in A. Z1 gives Gphi in A, which we already knew. No information gained.
- **Non-constant case**: Need G(Gphi->phi) at an orbit point. Under **strict** (irreflexive) semantics, G(psi) at x means psi at all y > x, NOT at x. So Gphi->phi at y (where y > x) means: if phi holds at all z > y then phi holds at y. This is NOT the same as reflexive induction. Establishing Gphi->phi at all future points requires knowing phi's truth at every limit_dom point in the gap, which is the unsolved difficulty.

### Approach 3: Gap Point Predecessor Chain (FAILS)

If a limit_dom point c exists with value >= L and below all pred-chain points:
- pred(c) has value < c.val. If pred(c).val < L and a <= pred(c), then orbit_below_L gives pred(c) as orbit point, so c = succ(orbit) is next orbit point. But orbit values < L while c.val >= L. Contradiction.
- If pred(c).val >= L, then pred(c) is ALSO a gap point. Continuing: pred^[k](c) gives a strictly decreasing sequence of gap rationals >= L.
- This converges to some M' >= L but yields no contradiction: the sequence can approach L from above without any element having value < L.

### Also Examined: succ_reaches_dom_N

The alternative stage-induction approach at lines 1162-1456 has its own two sorries (boundary cases at lines 1301 and 1454). These boundary cases reduce to showing that succ(max_dom_N) enters the domain at stage N+1, which is not guaranteed by the construction. The approach is essentially circular.

## Why the Sorry is Genuine

The Z+Z gap scenario (orbit from below, pred-chain from above, gap at L) is consistent with ALL formalized temporal axioms under strict semantics:
1. All truth lemmas (c5, c5', forward_G, backward_H, limit_F_resolution) are satisfied: witnesses exist at adjacent points with vacuous guards
2. Z1 is trivially satisfied in the constant-MCS case
3. Prior-UZ is satisfied: U(phi, neg phi) resolves to the immediate successor with vacuous guard
4. The code comments at lines 1139-1156 already document this

## Changes Made

No source files modified. The comments at the sorry site (lines 1846-1887) and the section docstring (lines 1134-1156) already contained accurate documentation of the gap scenario. The analysis in this summary confirms and elaborates on that documentation.

## Resolution Paths

1. **Reynolds pipeline (tasks 154-155)**: Primary recommended path. Bypasses succ_cofinal entirely with a different approach to discrete completeness.
2. **Construction-level argument**: Deep interaction with omega_chain_elim_result and BurgessR3Maximal to show the omega-chain cannot produce a Z+Z gap. Estimated 200-400 lines of new infrastructure.
3. **Task 129 approach**: Weak/reflexive completeness + conservative extension provides IsSuccArchimedean via Henkin model.

## Plan Deviations

- **Phase 2**: All tasks except documentation skipped -- constant-MCS exclusion argument is fundamentally flawed (c5_strong event/guard confusion in research report)
- **Phase 3**: All tasks skipped; stopping rule invoked -- Z1 blocked under strict semantics, confirmed by existing code documentation
- **Phase 4**: sorry-free tasks skipped; partial documentation completed

## Verification

- `lake build`: Passes (1649 jobs, no new errors)
- Sorry count: Unchanged (sorry at line 1888 is the same pre-existing sorry)
- No new axioms introduced
- No vacuous definitions created
