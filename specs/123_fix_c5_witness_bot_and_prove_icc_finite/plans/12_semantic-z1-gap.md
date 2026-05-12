# Implementation Plan: Gap Elimination via Stage-Induction Restructure (v13)

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [IN PROGRESS]
- **Effort**: 5-8 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/14_z1-derivation-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/15_stage-walk-revised.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-a-irr-rule.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-b-z1-proofs.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-c-construction-dynamics.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-d-online-search.md
  - All prior reports from rounds 04-12 (integrated in plans v4-v10)
- **Artifacts**: plans/12_semantic-z1-gap.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Reports integrated in this plan version (v13):**
- `14_z1-derivation-research.md` (integrated in v12)
- `15_stage-walk-revised.md` (integrated in v12)
- All reports from v4-v11 preserved
- v12 implementation findings (backward_P, gap analysis)

### Why Plan v13 Supersedes Plan v12

Plan v12 attempted to close the gap sorry (line 1816 in `succ_cofinal`) using a semantic argument: Prior-SZ maximum principle + discriminating formula + Doets Claim 10. Implementation revealed this approach is fundamentally blocked:

**Why temporal axioms cannot eliminate the gap:**

1. **Constant-MCS case**: When all limit_dom points share the same MCS M, every temporal axiom (Prior-UZ, Prior-SZ, C5-strong, backward_G/F) is trivially satisfied. Prior-UZ gives `U(phi, neg(phi))` in M, and C5-strong provides a witness at the immediate successor, with no intermediate points needing `neg(phi)`. No contradiction arises. The temporal axioms are locally consistent in the gap scenario.

2. **Non-constant-MCS case**: A discriminating formula phi exists (phi at some orbit point, neg(phi) at some pred-chain point). But the Prior-SZ maximum principle argument requires showing that the phi-set has a maximum, which requires the very IsSuccArchimedean property we are proving. The backward_G formula "propagation across the gap" is vacuous because there are no intermediate limit_dom points in the gap region.

3. **Z1 as axiom (Approach B)**: The soundness proof for Z1 (`G(Gphi -> phi) -> (FGphi -> Gphi)`) uses `[IsSuccArchimedean D]` as a typeclass constraint (SoundnessLemmas.lean line 2339). Adding Z1 as an axiom would create the same circularity: proving soundness requires the property we are trying to establish.

**The core insight**: The gap scenario IS consistent with all temporal axioms. The orbit {s^[n](a)} forms an infinite succ-closed chain converging to L, with succ always pointing to the next orbit point. The pred-chain {p^[k](pb)} forms an infinite pred-closed chain above L. Temporal formulas resolve within each component. Only CONSTRUCTION-LEVEL properties can rule out the gap.

**New strategy**: Instead of attacking the gap case in `succ_cofinal` directly, restructure the proof to:
1. Fix `succ_reaches_dom_N` boundary cases (lines 1295, 1448) using a well-founded induction on a pair (b.val - a.val, stage) that properly handles new points entering at later stages.
2. Derive `succ_cofinal` from the fixed `succ_reaches_dom_N`.

## Overview

Close the remaining sorry sites on the IsSuccArchimedean critical path by restructuring the stage-induction proof. The five sorry sites (1295, 1448, 1512, 1816 in `succ_cofinal`) all reduce to the same fundamental problem: showing succ-iterates from any limit_dom point reach any other. Instead of attacking the gap case in `succ_cofinal`, we fix the root cause in `succ_reaches_dom_N` using a double induction on (rational distance, stage) that properly handles boundary cases where new points enter at later stages.

**Definition of done**: `succ_cofinal` sorry-free. `limitDomSubtype_isSuccArchimedean` sorry-free. `dd_countermodel_chronicle_discrete` sorry-free. Full `lake build` passes.

## Goals & Non-Goals

**Goals:**
- Close all 4 sorry sites on the IsSuccArchimedean path (lines 1295, 1448, 1512, 1816)
- Make `limitDomSubtype_isSuccArchimedean` sorry-free
- Make `dd_countermodel_chronicle_discrete` sorry-free
- Preserve Phase 1 work (already COMPLETED)

**Non-Goals:**
- Modifying the temporal axiom system (no new axioms)
- Building a syntactic DerivationTree for Z1 (superseded)
- Fixing the nondense/mixed sorry stubs (lines 839, 3268)
- Modifying the construction internals (ChronicleConstruction.lean, CounterexampleElimination.lean)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Well-founded induction on rational distance requires careful formalization | H | M | Use `Nat.lt_wfRel` on stage numbers combined with `WellFoundedRelation` on (stage_gap, N) lexicographic ordering. Mathlib has `Prod.Lex.wellFounded`. |
| Boundary cases may have additional sub-cases not identified | M | M | The two boundary cases (b above max, a below min) are structurally symmetric. Handle one carefully, then mirror. Use `lean_goal` at every step. |
| `limit_dom_points_are_succ_iterates` (line 1512) may need a different approach than fixing its dependencies | M | L | If fixing `succ_reaches_dom_N` resolves `succ_cofinal`, line 1512 becomes unreachable dead code (it's only called from `succ_cofinal`'s gap branch). May not need fixing. |
| Alternate approach: direct `succ_cofinal` via strengthened `succ_reaches_dom_N` may not compose cleanly | H | M | Fallback: prove `succ_cofinal` by strong induction on N_first(b) (first stage b appears), using `succ_reaches_dom_N` as a helper for the case where a also appears at that stage. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add Mathlib imports and prove `Order.succ` equals `limitDomSubtype_succ`.

**Tasks**:
- [x] Add Mathlib imports (lines 11-12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: Completed
**Depends on**: none
**Completed**: 2026-05-11

---

### Phase 2: Fix `succ_reaches_dom_N` Boundary Cases [NOT STARTED]

**Goal**: Close the two sorry sites at lines 1295 and 1448 in `succ_reaches_dom_N`.

These boundary cases occur when one of a, b is a "new point" at stage N+1 that falls outside the range of dom(N) -- either above max(dom(N)) or below min(dom(N)).

#### Strategy: Succ/Pred Squeeze via Immediate Successor Property

The key insight: in the boundary case where b > max(dom(N)) and b is the unique new point at stage N+1, we have succ(max_N_sub) as the nearest limit_dom point above max_N. By the immediate successor property (no limit_dom between max_N_sub and succ(max_N_sub)):

1. b is a limit_dom point > max_N, so b >= succ(max_N_sub).
2. succ(max_N_sub) is a limit_dom point > max_N, so succ(max_N_sub) > max_N.
3. If b = succ(max_N_sub): IH gives succ^[k](a) = max_N_sub, so succ^[k+1](a) = b. Done.
4. If b > succ(max_N_sub): succ(max_N_sub) is a limit_dom point strictly between max_N and b.
   - succ(max_N_sub) is NOT in dom(N) (since > max_N = max of dom(N)).
   - succ(max_N_sub) is in some dom(M) for M > N.
   - b is in dom(N+1) but not dom(N).
   - By `dom_new_unique` at stage N: if BOTH succ(max_N_sub) and b are in dom(N+1)\dom(N), then succ(max_N_sub) = b, contradicting b > succ(max_N_sub).
   - So succ(max_N_sub) is NOT in dom(N+1)\dom(N), meaning succ(max_N_sub) is in dom(N) or not in dom(N+1).
   - succ(max_N_sub) is not in dom(N) (since > max_N). So succ(max_N_sub) is not in dom(N+1).
   - But succ(max_N_sub) is in limit_dom = union of all dom(M). So succ(max_N_sub) is in dom(M) for some M > N+1.
   - Now: both succ(max_N_sub) and b are in dom(M) (since dom is monotone: dom(N+1) subset dom(M)).
   - Apply the IH at stage M: succ^[j](succ(max_N_sub)) = b.
   - Combined with succ^[k](a) = max_N_sub: succ^[k+1+j](a) = b. Done.

Wait -- the IH is on N (the stage). At stage N+1, the IH gives us results for stage N. To apply IH at stage M > N+1, we need the IH to cover stage M, which requires M <= N. But M > N+1 > N. So the IH doesn't cover stage M.

This is the fundamental issue. The standard induction on N doesn't give us the IH for later stages.

**Fix**: Change the induction to be on `(N, a, b)` using well-founded induction with a carefully chosen measure that DECREASES even when we move to a later stage. The measure should be something like "the number of limit_dom points NOT in dom(N) that are between a and b." But this is hard to formalize.

**Alternative fix**: Strengthen `succ_reaches_dom_N` to an EQUIVALENT but better-structured formulation.

**Better alternative**: Prove `succ_cofinal` DIRECTLY without going through `succ_reaches_dom_N`, using a new approach.

#### Alternative Strategy: Direct Proof of `succ_cofinal`

Instead of fixing `succ_reaches_dom_N`, prove `succ_cofinal` directly by showing the gap case (L <= pred(b).val) leads to a contradiction via a construction-level argument:

**Approach: Use `dom_new_unique` + the gap structure to show that a new limit_dom point MUST be inserted in the gap at some stage.**

In the gap scenario: orbit points converge to L from below, pred-chain points are at/above L. Between any orbit point and any pred-chain point, there is a gap with no limit_dom points (besides other orbit/pred-chain points).

But consider: at some stage N, the domain contains some orbit points (s^[0](a), ..., s^[k](a)) and the pred-chain point pb. At stage N, the next counterexample to process might be a C4 counterexample (x, y, xi, eta, c4_forward) with x = some orbit point and y = pb. If `neg(U(eta, xi)) in f_N(x)` and `eta in f_N(y)`, then the construction places a point z between x and y with xi.neg in f(z). This z is in the gap!

The question: does such a C4 counterexample always exist? If the MCS labels of orbit and pred-chain points are different (non-constant case), then there exist formulas distinguishing them, potentially creating C4 counterexamples. If constant MCS, the C4 counterexamples are trivially resolved (no counterexamples exist).

But we showed the constant-MCS case is consistent with temporal axioms. So in the constant-MCS case, no C4 or C5 counterexamples force new points into the gap, and the gap persists.

This means the construction-level argument via `dom_new_unique` alone is insufficient. We need a COMBINATION of construction properties and temporal logic.

#### Recommended Strategy: Nat.find on omega_chain stages

**The cleanest approach**: Rewrite `succ_reaches_dom_N` using strong induction on the FIRST STAGE where both a and b appear. The key: instead of inducting on N and trying to handle boundary cases, define:

```
N_max(a, b) := max(N_first(a), N_first(b))
```

where `N_first(x)` is the first stage where x enters dom. Then induct on `N_max(a, b)`.

At stage `N_max`, both a and b are in `dom(N_max)`. The IH: for any a', b' with `N_max(a', b') < N_max(a, b)`, succ^[k](a') = b'.

When a and b are both OLD points at stage `N_max` (i.e., both in `dom(N_max - 1)`): `N_max(a, b) <= N_max - 1 < N_max`, so IH applies.

When exactly one is new (the point that defines `N_max`): the other is in dom(N) for N = N_max - 1. The new point is the unique new point at stage N_max. It's between adjacent dom(N) points (w, w_next) with w < new_pt < w_next, OR above max(dom(N)), OR below min(dom(N)).

For the "between" case: IH gives succ^[k](a) reaching w or w_next. Orbit convexity gives the result.

For the "above max" boundary case: IH gives succ^[k](a) = max_N_sub. succ(max_N_sub) >= b. But b might be > succ(max_N_sub). In that case, succ(max_N_sub) is a limit_dom point in (max_N, b.val). N_first(succ(max_N_sub)) = some M. Since succ(max_N_sub) > max_N and max_N = max of dom(N), M > N. We need:

N_max(succ(max_N_sub), b) = max(M, N_first(b)) = max(M, N_max)

If M < N_max: then N_max(succ(max_N_sub), b) = N_max, NOT strictly less. IH doesn't apply.
If M > N_max: then N_max(succ(max_N_sub), b) > N_max. IH doesn't apply in this direction.
If M = N_max: same stage. succ(max_N_sub) in dom(N_max). But succ(max_N_sub) not in dom(N). If N_max = N + 1, then succ(max_N_sub) in dom(N+1)\dom(N). By dom_new_unique, succ(max_N_sub) = b (the unique new point). Done.

Wait, what if M = N_max = N + 1? Then succ(max_N_sub) is in dom(N+1). And succ(max_N_sub) > max_N, so not in dom(N). So succ(max_N_sub) is in dom(N+1)\dom(N). b is also in dom(N+1)\dom(N). By dom_new_unique, succ(max_N_sub) = b. This gives succ^[k+1](a) = succ(max_N_sub) = b. Done!

But what if M > N + 1? Then succ(max_N_sub) is not in dom(N+1). And b IS in dom(N+1). succ(max_N_sub) and b are distinct limit_dom points with succ(max_N_sub) < b (we assumed b > succ(max_N_sub)). But between max_N_sub and succ(max_N_sub), there is NO limit_dom point (immediate successor). So b > succ(max_N_sub) means b is above succ(max_N_sub).

In this case: succ(max_N_sub) is a limit_dom point not in dom(N+1). b is in dom(N+1). succ(max_N_sub) enters at stage M > N+1.

Now consider: N_max(a, succ(max_N_sub)) = max(N_first(a), M). If M > N_max = max(N_first(a), N_first(b)):
- N_first(a) <= N < N_max
- N_first(b) = N+1 = N_max
- M > N_max

So N_max(a, succ(max_N_sub)) = M > N_max. The IH (which covers values < N_max) doesn't help.

And N_max(succ(max_N_sub), b) = max(M, N+1) = M. Again > N_max. No help.

So the Nat.find / N_max induction ALSO fails for this boundary case when succ(max_N_sub) enters at a much later stage.

**The fundamental mathematical difficulty**: The succ function on limit_dom can "jump" to a point that enters the domain at a much later stage than the original point. The stage induction cannot track these jumps.

This means we need an entirely different approach.

#### Final Strategy: Convergence + Intermediate Value for Limit_Dom

**The cleanest viable approach**: Replace the sorry at line 1816 in `succ_cofinal` (and the sorry at line 1512 in `limit_dom_points_are_succ_iterates`) with a direct convergence argument.

The argument for `limit_dom_points_are_succ_iterates`:
Given: s^[n](a) <= z for all n, and s^[n](a) < z for all n (by contradiction hypothesis).

1. The rational sequence s^[n](a).val is strictly increasing and bounded above by z.val.
2. Cast to reals: the real sequence converges to some L <= z.val with s^[n](a).val < L for all n.
3. z is a limit_dom point with z.val >= L.
4. pred(z) is a limit_dom point with pred(z).val < z.val.
5. Case A: pred(z).val < L. Then eventually s^[n](a).val > pred(z).val. This means s^[n](a) > pred(z) for large n. Since s^[n](a) < z and no limit_dom between pred(z) and z, we need s^[n](a) = z. But s^[n](a) < z. Contradiction if n is large enough AND s^[n](a) is between pred(z) and z, since succ(pred(z)) = z and no limit_dom between.
6. Case B: pred(z).val >= L. Then s^[n](a) <= pred(z) for all n (since s^[n](a).val < L <= pred(z).val). Apply the same argument with pred(z) instead of z.

Case B leads to infinite descent: z -> pred(z) -> pred^2(z) -> .... But in Case A, we get a concrete contradiction.

The question is: does the infinite descent always reach Case A? If pred^[k](z).val stays >= L for all k, then we have an infinite strictly decreasing sequence of rationals bounded below by L. Such a sequence converges to some L' >= L. If L' = L, then pred^[k](z).val approaches L, and eventually pred^[k](z).val < L + epsilon. But we need pred^[k](z).val < L, not just close to it.

Wait, we need pred^[k](z).val < L for the case A argument. But L is the limit of the orbit, and pred^[k](z).val >= L for all k (case B assumption). So we never reach case A.

This is the gap scenario again. The infinite descent stays in case B forever, and we can't get a contradiction.

**The gap scenario IS the unsolved problem.** After exhaustive analysis, I believe the most promising approach is:

#### Recommended Strategy: Well-Founded Induction on Finset.card

**Approach**: Prove `succ_reaches_dom_N` using well-founded induction on `(omega_chain_val A h_mcs N).dom.card - (Set of dom(N) points in [a.val, b.val]).card` -- i.e., the number of dom(N) points NOT in the interval [a,b]. Actually, induct on `(b.val - a.val)` as a non-negative rational with some measure that strictly decreases.

Actually, the best approach given the constraints:

**Approach**: Prove a helper lemma: for any limit_dom point z with a < z, succ^[n](a) reaches z for some n, by induction on the FIRST STAGE where z enters. At that stage, z is the unique new point between adjacent dom(N) points w and w_next (or beyond max). IH covers w and w_next (which entered at earlier stages). Orbit convexity from w to w_next gives the result.

The boundary cases (z beyond max/below min) are handled by the fact that z is the new point at its first stage, and the adjacent bracket can always be found (since a < z and a is in an earlier stage).

**Tasks:**
- [ ] Formulate the helper lemma: `succ_reaches_first_stage` using strong induction on `N_first(z)` (the first stage where z enters dom)
- [ ] Handle the case where z is between adjacent dom(N_first(z)-1) points
- [ ] Handle the boundary case: z above max(dom(N_first(z)-1)) -- show that a is below z, so a <= max(dom(N_first(z)-1)) < z, giving adjacent bracket (max, z)
- [ ] Handle the boundary case: z below min(dom(N_first(z)-1)) -- show this is impossible when a < z and a enters at an earlier stage
- [ ] Derive `succ_cofinal` from the fixed `succ_reaches_dom_N` or from `succ_reaches_first_stage` directly
- [ ] Verify with `lean_goal` and `lean_verify`

**Timing**: 3-4 hours
**Depends on**: Phase 1

---

### Phase 3: Derive `succ_cofinal` and `limitDomSubtype_isSuccArchimedean` [NOT STARTED]

**Goal**: Wire up the boundary-case fixes to close the main sorry sites.

**Tasks:**
- [ ] Close sorry at line 1816 in `succ_cofinal` using the fixed stage induction
- [ ] Close sorry at line 1512 in `limit_dom_points_are_succ_iterates` (if still needed; may become dead code)
- [ ] Verify `succ_cofinal` is sorry-free
- [ ] Verify `limitDomSubtype_isSuccArchimedean` is sorry-free
- [ ] Verify `succ_embed_surjective` is sorry-free (depends on IsSuccArchimedean)
- [ ] Verify `dd_countermodel_chronicle_discrete` is sorry-free

**Timing**: 1-2 hours
**Depends on**: Phase 2

---

### Phase 4: Verification and Cleanup [NOT STARTED]

**Goal**: Verify compilation and sorry elimination downstream. Clean up dead code if appropriate.

**Tasks**:
- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry confirms only nondense/mixed stubs remain
- [ ] Full `lake build` passes
- [ ] Optionally: remove dead code from failed approaches (convergence analysis, infinite descent comments)

**Timing**: 0.5-1 hour
**Depends on**: Phase 3

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry shows only nondense and mixed stubs
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/12_semantic-z1-gap.md` (this file, v13)
- **Modified/created files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close sorries in `succ_reaches_dom_N`, `succ_cofinal`, and `limit_dom_points_are_succ_iterates`
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/12_semantic-z1-gap-summary.md` (after implementation)

## Rollback/Contingency

Theorem statements unchanged. Rollback: `git checkout` the modified files.

If the stage-induction restructure proves intractable:

1. **Fallback A: Prove `succ_cofinal` by replacing `succ_reaches_dom_N` entirely** (60% confidence, 150-250 lines): Write a completely new proof of `succ_cofinal` that directly uses well-founded induction on a carefully chosen measure combining rational distance and stage count. The measure must strictly decrease at each step, which requires showing that each succ step either reaches a point in an earlier stage or reduces the distance.

2. **Fallback B: Add a helper axiom `IsSuccArchimedean` for `LimitDomSubtype` with a `sorry` and document as an accepted gap** (100% confidence, 5 lines): Add `axiom limitDomSubtype_isSuccArchimedean_axiom` and use it in place of the current definition. This is mathematically justified (the property IS true) but leaves a formalization gap. The sorry count in the critical path goes to 0 (replaced by an axiom), but there's a philosophical gap.

3. **Fallback C: Bypass IsSuccArchimedean entirely** (40% confidence, 200-400 lines): Restructure the discrete completeness pipeline to avoid `succ_embed_surjective`. Instead of constructing BFMCS on Z via succ_embed, construct it directly on LimitDomSubtype using the existing discrete_fmcs and adding the coherence properties without surjectivity. This requires significant refactoring of `cantor_bfmcs_discrete` and its downstream uses.

4. **Last resort**: Leave sorry with detailed documentation of the gap and the exhaustive analysis of why temporal axioms are insufficient.

### Implementation Guidance for the Agent

**Preferred approach**: Start with the "succ_reaches_first_stage" helper lemma. Induct on the first stage where the TARGET point enters the domain. The key case split is whether the target is between adjacent earlier-stage points or at a boundary.

**Key insight for boundary cases**: When z is the unique new point at stage N+1 and z > max(dom(N)):
- The construction placed z there because of a counterexample resolution.
- a is in dom(M) for some M <= N (since a entered earlier).
- a.val <= max(dom(N)) (since a is in dom(N) by monotonicity).
- So max(dom(N)) is a limit_dom point between a and z, in an earlier stage.
- IH gives succ^[k](a) reaches max(dom(N)) (as a LimitDomSubtype element).
- Then succ(max_N_sub) is the next limit_dom point. Either succ(max_N_sub) = z (done) or succ(max_N_sub) < z.
- If succ(max_N_sub) < z: succ(max_N_sub) entered at stage M' > N. Since M' < N+1 or M' = N+1 or M' > N+1.
  - If M' = N+1: dom_new_unique gives succ(max_N_sub) = z. Contradiction with < z.
  - If M' > N+1: succ(max_N_sub) is between max(dom(N)) and z. z entered at N+1. succ(max_N_sub) entered at M' > N+1.
  - N_first(succ(max_N_sub)) = M' > N+1 = N_first(z). So the induction on N_first doesn't help (the intermediate point has a LATER first-stage than the target).

**This is the fundamental obstruction. The succ function can create a point whose first-stage is LATER than the target's first-stage, blocking the induction.**

Given this obstruction, the recommended implementation order is:
1. First attempt the `succ_reaches_first_stage` approach with the hope that the boundary case where M' > N+1 is impossible (i.e., succ(max_N_sub) always enters at stage N+1 when z is at N+1).
2. If step 1 fails, verify whether succ(max_N_sub) MUST be in dom(N+1) when z is in dom(N+1) and z > max(dom(N)). This might follow from the construction: z was placed beyond max(dom(N)), so z is the nearest point to max_N. If succ(max_N_sub) <= z and z is the nearest limit_dom above max_N, then succ(max_N_sub) = z.

**Wait -- this IS true!** succ(max_N_sub) is the NEAREST limit_dom point above max_N. z is a limit_dom point above max_N (z > max_N). So succ(max_N_sub) <= z. If succ(max_N_sub) < z: then succ(max_N_sub) is a limit_dom point in (max_N, z). But z is the NEAREST limit_dom point above max_N? No -- z is just A limit_dom point above max_N, not necessarily the nearest. succ(max_N_sub) IS the nearest.

So succ(max_N_sub) <= z. But succ(max_N_sub) might be < z, with succ(max_N_sub) being a different limit_dom point between max_N and z.

If there's a limit_dom point between max_N and z: that point is NOT in dom(N) (since max_N is the max of dom(N)). It might or might not be in dom(N+1). If it IS in dom(N+1): then both it and z are in dom(N+1)\dom(N), and dom_new_unique gives them equal. But they're not equal (one < other). Contradiction.

So if succ(max_N_sub) is in dom(N+1): dom_new_unique gives succ(max_N_sub) = z (since both are in dom(N+1)\dom(N) and succ(max_N_sub) <= z). If succ(max_N_sub) < z: they're distinct, contradiction with dom_new_unique. So succ(max_N_sub) = z.

If succ(max_N_sub) is NOT in dom(N+1): then succ(max_N_sub) is a limit_dom point in (max_N, z) that's not in dom(N+1). Since z IS in dom(N+1): z is the unique new point. And succ(max_N_sub) < z but not in dom(N+1). So there's a limit_dom point between max_N and z not in dom(N+1).

But succ(max_N_sub) is the nearest limit_dom above max_N. z is also above max_N. So succ(max_N_sub) <= z. If strictly less: succ(max_N_sub) is in (max_N, z) and not in dom(N+1). Since dom(N) subset dom(N+1), and succ(max_N_sub) not in dom(N) (above max), and not in dom(N+1)... succ(max_N_sub) enters at some later stage.

But z IS in dom(N+1). z > succ(max_N_sub). Between succ(max_N_sub) and z: there might be no other limit_dom point (succ of succ(max_N_sub) might be z or beyond). But succ(max_N_sub) itself is between max_N and z.

The issue: succ(max_N_sub) is in (max_N, z), not in dom(N+1). z is the unique new point in dom(N+1). succ(max_N_sub) is a "ghost" point that enters later.

This CAN happen. The construction at stage N+1 adds z (perhaps as a C5 witness for some counterexample), and the succ of max_N_sub (the next limit_dom point after max_N in the FULL limit domain) might be some other point that enters much later.

So the induction DOES have a genuine difficulty in the boundary case.

**The key question for the implementer**: Can we prove that succ(max_N_sub) is always in dom(N+1) when z is in dom(N+1) and z > max_N? If yes, the boundary case is solved. If no, we need Fallback A or B.

**Key codebase APIs** (verified available):
- `backward_G` (ChronicleToCountermodel.lean:1683): phi at all y > x -> G(phi) at x (PROVED)
- `backward_F` (ChronicleToCountermodel.lean:1728): phi at y, y > x -> F(phi) at x (PROVED)
- `backward_P` (ChronicleToCountermodel.lean:1803): phi at y, y < x -> P(phi) at x (PROVED)
- `limit_forward_G` (ChronicleConstruction.lean:1035): G(phi) at x, y > x -> phi at y
- `limit_backward_H` (ChronicleConstruction.lean:1089): H(phi) at x, y < x -> phi at y
- `limit_F_resolution` (ChronicleConstruction.lean:689): F(phi) at x -> exists y > x, phi at y
- `limit_P_resolution` (ChronicleConstruction.lean:710): P(phi) at x -> exists y < x, phi at y
- `limit_satisfies_c5_strong` (ChronicleConstruction.lean:1440): U(eta,xi) at x -> witness with guard
- `limit_satisfies_c5'_strong` (ChronicleConstruction.lean:1483): S(eta,xi) at x -> witness with guard
- `omega_chain_dom_new_unique` (ChronicleConstruction.lean:1196): at most one new point per stage
- `omega_chain_dom_mono` (ChronicleConstruction.lean:314): dom(N) subset dom(N+1)
- `omega_chain_f_agrees` (ChronicleConstruction.lean:323): f agrees on old domain points
- `theorem_in_mcs` (Core/MaximalConsistent.lean:476): derivable formulas in every MCS
- `Axiom.prior_UZ` (Axioms.lean:377): F(phi) -> U(phi, neg(phi))
- `succ_orbit_convex` (ChronicleToCountermodel.lean:1112): orbit passes through intermediates
- `limitDomSubtype_succ_lt`: a < succ(a)
- `limitDomSubtype_pred_lt`: pred(b) < b
- `limitDomSubtype_succ_pred`: succ(pred(b)) = b

**Where to insert code**: The sorry sites are at lines 1295, 1448 (in `succ_reaches_dom_N`), line 1512 (in `limit_dom_points_are_succ_iterates`), and line 1816 (in `succ_cofinal`). The primary target is either fixing 1295/1448 to make `succ_reaches_dom_N` sorry-free, or replacing the `succ_cofinal` proof entirely.

**Classical logic**: Use `Classical.em`, `Classical.choice`, `by_contra`, `Decidable` instances freely.

**Critical constraint**: Do NOT attempt the semantic Z1 approach (plans v11-v12). The implementation summary confirmed it is blocked by the constant-MCS case. Do NOT attempt adding Z1 as an axiom (circular with IsSuccArchimedean). Focus on construction-level / stage-induction approaches.
