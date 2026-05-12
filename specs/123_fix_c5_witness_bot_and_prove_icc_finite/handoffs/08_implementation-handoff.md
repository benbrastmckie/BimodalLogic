# Handoff: Task 123, Plan v8 Implementation

## Context

Session `sess_1778568847_2040cd` analyzed the first-stage induction approach for closing
the sorry at `limitDomSubtype_isSuccArchimedean` in `ChronicleToCountermodel.lean` (line 1402).

## Status

Phase 1: [COMPLETED] (from plan v7)
Phase 2: [NOT STARTED] - Deep analysis completed, no code changes made
Phase 3: [NOT STARTED]

No files were modified.

## Key Findings

### 1. The plan v8 first_stage induction has a gap

The plan's induction on N (max of first_stage values) relies on the claim:
"When first_stage(c) = N+1, first_stage(pred(c)) <= N."

This is NOT always true. The reason: pred(c) in limit_dom is the immediate
predecessor of c. The C5'/S(T,bot) witness for c is processed at some stage
M >= N+1. The witness y = pred(c) enters at stage M+1. So first_stage(pred(c))
could be M+1 > N+1 > N.

The plan partially addresses this with the "orbit convexity trick": for a C5
forward witness c between adjacent dom(N) points (pt, U0), use IH on (pt, U0)
to get succ^[M](pt) = U0, then orbit convexity gives succ^[j](pt) = c.

This trick WORKS when c is between two dom(N) points. But it FAILS when c is
placed BEYOND max(dom(N)) (the C5 forward walk base case).

### 2. The adjacent-pair approach also has issues

An alternative approach (induction on omega-chain stage, proving succ reaches
between adjacent dom(N) pairs) was considered. It works for the case where a new
point is inserted BETWEEN two existing points (orbit convexity handles it).
But it fails for boundary insertions (beyond max or below min) for the same reason.

### 3. The gap-at-L scenario analysis

The existing convergence proof handles:
- pred(c).val < L --> False (h_pred_below_L_contradiction, line 1301)
- pred(c).val = L --> False (h_pred_at_L_contradiction, line 1323)

The remaining case is pred(c).val > L for ALL above-orbit c. This is the
"gap-at-L" scenario. Let M = inf{p^[k](b).val : k >= 0}. M >= L.

**Case M > L**: This case IS closable. Two arguments:

(a) Midpoint argument: When the C5 for U(T,bot) at an orbit element s^[n](a)
uses an above-orbit ceiling (value >= M), the midpoint z >= (s^[n](a) + M)/2.
For large n: z >= (L + M)/2 - epsilon. Since z < L (orbit element):
(L + M)/2 - epsilon < L, giving M < L + 2*epsilon. Taking epsilon -> 0: M <= L.
Contradiction with M > L.

(b) C4 counterexample argument: For any orbit element x and above-orbit element y,
there exists a formula psi with neg(U(top, psi)) in f(x). The C4 counterexample
at (x, y, psi, top) creates a point z = (x+y)/2 in (L, M). But no limit_dom
element can be in (L, M) (it would have value < M = inf of above-orbit, while
being above all orbit elements). Contradiction.

**Case M = L**: The harder case. The pred-chain and orbit both converge to L.
The analysis shows this scenario is self-consistent for the CONVERGENCE framework.
New arguments are needed.

### 4. Recommended approach for closing the sorry

**Option A (closable, estimated 200-350 lines)**: Prove the M > L case to
reduce the sorry to M = L. Then prove M = L is impossible using C4
counterexample insertion:

For M = L: pick orbit element x close to L and above-orbit element y close to L.
There exists a formula psi with neg(U(top, psi)) in f(x) and top in f(y).
The C4 at (x, y) creates z = (x+y)/2. But z is between L-epsilon and L+epsilon.
If z > L: z is an above-orbit element. pred(z) must be > L (gap assumption).
But between pred(z) and z there are no limit_dom elements, and z = (x+y)/2
where x < L and y > L. The structure forces z's pred to be some point <= L...
Actually this case needs more detailed analysis.

**Option B (alternative, 400-600 lines)**: LocallyFiniteOrder approach.
Prove Set.Finite (Set.Icc a b) for all a, b : LimitDomSubtype. This gives
LocallyFiniteOrder, which implies IsSuccArchimedean. The key challenge is the
same: bounding the number of limit_dom points between a and b.

**Option C (most promising, 150-250 lines)**: Direct omega-chain stage
induction with the orbit convexity trick, handling boundary cases separately.

For the case first_stage(c) = N+1 and c between adjacent (pt, U0) in dom(N):
By IH on (a, pt) and (pt, U0): succ^[m1](a) = pt and succ^[m2](pt) = U0.
By orbit convexity: succ^[j](pt) = c for some j. Done.

For the boundary case (c beyond max(dom(N))): Need to show that this case
reduces to a non-boundary case at a larger stage.

Key insight for boundary case: c was placed by C5 forward walk base case.
The walk ref pt = max(dom(N)). c > max(dom(N)). At a LATER stage M, the
C5 for U(T,bot) at pt is processed. The walk splits between pt and c
(since c is now in the domain). The witness z = (pt + c)/2 is a new point.
z < c. z enters between pt and c. Now (pt, z) and (z, c) are adjacent
in dom(M+1). And z has first_stage M+1. Both pt (first_stage <= N)
and c (first_stage = N+1) are in dom(M+1).

Wait, but the C5 for U(T,bot) at pt may have been processed BEFORE stage N+1.
In that case, the witness was placed before c entered. Let me re-examine.

Actually: U(T,bot) at pt is processed at some stage M. If M < N: the witness
was placed at stage M+1 <= N. The witness w is between pt and the ceiling at
stage M. If the ceiling was the max of dom(M): w was placed beyond max(dom(M)).
w is in dom(M+1) subset dom(N). w is an orbit element (by construction).
And w > pt. c > max(dom(N)) >= w. So w < c. And (w, c) might be adjacent
in some stage.

This is getting very involved. The handoff is: the approach works for
non-boundary cases, and the boundary case needs the specific C5-for-U(T,bot)
resolution argument.

### 5. Key codebase references for implementation

**Existing infrastructure (all sorry-free)**:
- `limit_satisfies_c5_strong` (ChronicleConstruction.lean:1440): bot-guard for U(T,bot)
- `adj_g_mem_limit_f` (ChronicleConstruction.lean:1367): g-value propagation
- `omega_chain_dom_new_unique` (ChronicleConstruction.lean:1196): at most one new point
- `succ_orbit_convex` (ChronicleToCountermodel.lean:1112): orbit convexity
- `limitDomSubtype_succ_le_iff` (ChronicleToCountermodel.lean:912): succ(a) <= b iff a < b
- `exists_containing_adjacent` (ChronicleConstruction.lean:1389): adjacent pair finder
- `omega_chain_g_sub_f_insert` (ChronicleConstruction.lean:1262): g flows to f
- `omega_chain_g_sub_g_new` (ChronicleConstruction.lean:1276): g propagation

**The sorry site**:
- `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:1190-1402)
- The sorry is at line 1402, inside the by_contra proof body

**Downstream dependencies** (all depend on IsSuccArchimedean being sorry-free):
- `succ_embed_surjective` (line 2310)
- `dd_countermodel_chronicle_discrete` (line 2778)

### 6. Recommended next steps

1. Run `/revise 123` to create plan v9 incorporating these findings
2. The revised plan should use the orbit-convexity-with-dom(N)-ceiling approach
3. Specifically handle the boundary case using C5-for-U(T,bot) resolution
4. Consider proving a standalone lemma:
   "For adjacent (a, b) in dom(N) where the C5 for U(T,bot) at a has been
   processed by stage N: succ(a) = b in LimitDomSubtype"
5. This lemma + iteration over dom(N) points + choice of N gives the result

## Files

No files were modified. The plan file phase marker was updated to [IN PROGRESS]
but should be reverted to [NOT STARTED] since no code was written.
