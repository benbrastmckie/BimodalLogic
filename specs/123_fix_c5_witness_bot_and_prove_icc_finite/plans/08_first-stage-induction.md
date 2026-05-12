# Implementation Plan: First-Stage Induction for IsSuccArchimedean

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 4-7 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/04_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/06_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_verbrugge-deep-study.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_doets-reynolds-deep-study.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_codebase-fit-analysis.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_mathematical-comparison.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/08_c5-midpoint-analysis.md
- **Artifacts**: plans/08_first-stage-induction.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Reports integrated in this plan version:**
- `08_c5-midpoint-analysis.md` (newly integrated in v8)
- `07_verbrugge-deep-study.md` (integrated in v7, preserved)
- `07_doets-reynolds-deep-study.md` (integrated in v7, preserved)
- `07_codebase-fit-analysis.md` (integrated in v7, preserved)
- `07_mathematical-comparison.md` (integrated in v7, preserved)
- `04_team-research.md` through `06_team-research.md` (integrated in v4-v6, preserved)

**Key findings from report 08 that drive this revision:**

1. **Midpoint formula alone is INSUFFICIENT** (Section 3.1 of report 08): The gap-at-L scenario (pred(c).val > L for all above-orbit c) is self-consistent with ceiling values approaching L. The convergence framework cannot derive False from the gap assumption.

2. **Purely order-theoretic proof is IMPOSSIBLE** (Section 5.2): The order type omega + omega* satisfies all hypotheses at the sorry site. Only construction-specific facts can rule it out.

3. **First-stage induction is RECOMMENDED** (Section 3.4, 80% confidence, 200-350 lines): Prove IsSuccArchimedean by well-founded induction on `first_stage(c) = min { n | c.val in dom(n) }`. This avoids the convergence/gap framework entirely.

4. **MCS periodicity DOWNGRADED** (Section 3.2, 50% confidence): The sub-lemma "same restricted MCS label implies same gap" is fragile because the construction depends on the full construction history, not just the restricted MCS label.

**Why this plan replaces the convergence framework:**

Plans v4-v7 attempted to close the sorry at line 1402 within the existing proof body -- extending the convergence framework with additional case analysis (gap-at-L elimination). Report 08 conclusively showed this is a dead end: the convergence to L in R is correct, but it provides no contradiction in the gap scenario. The three helper lemmas (`h_below_L_is_orbit`, `h_pred_below_L_contradiction`, `h_pred_at_L_contradiction`) handle three of four cases but the fourth case (gap-at-L) resists convergence-based arguments.

The first-stage induction approach restructures the proof entirely. Instead of reasoning about limits in R, it uses well-founded induction on the stage at which each domain point was introduced. This is a fundamentally different proof architecture that does not need L, the gap analysis, or any of the three helper lemmas.

### Prior Plan Reference

Plan v7 (`07_mcs-periodicity.md`) had 3 phases:
- **Phase 1** [COMPLETED]: Mathlib imports + `order_succ_eq` / `order_pred_eq` (both `rfl`)
- **Phase 2** [BLOCKED]: MCS periodicity gap-at-L contradiction -- blocked because the approach is now downgraded
- **Phase 3** [NOT STARTED]: Verification and cleanup

### Roadmap Alignment

This plan advances:
- "Discrete completeness: 1 sorry remains (task 122)" -- closing `limitDomSubtype_isSuccArchimedean` makes the discrete countermodel sorry-free
- "Full `bx_completeness`: Blocked by 1 sorry in discrete case" -- unblocking the discrete case moves toward sorry-free `bx_completeness`

## Overview

This plan replaces the convergence-based proof body of `limitDomSubtype_isSuccArchimedean` (lines 1196-1402 in `ChronicleToCountermodel.lean`) with a first-stage induction argument. The existing proof attempts to derive False from the assumption that the succ-orbit never reaches b, using monotone convergence in R. This approach stalls at the gap-at-L case. The replacement proof instead shows directly that every domain point c with a <= c is in the succ-orbit of a, by strong induction on the stage at which c entered the omega-chain domain.

The key idea: for any `c : LimitDomSubtype` with `a <= c`, define `first_stage(c) = Nat.find hc.property` (the first n such that c.val is in dom(n)). By strong induction on first_stage(c):
- **Base case**: If c entered at stage 0, then c.val = 0 (the singleton domain). Since a.val is also in dom(some stage) and a <= c with c.val = 0, we have a.val <= 0. In the discrete case with a <= c and both in limit_dom, this resolves directly.
- **Inductive step**: If c entered at stage N+1, it was the witness of some counterexample elimination. The elimination placed c between existing dom(N) points. The largest dom(N) point below c.val (call it L_pt) has first_stage <= N. By IH, L_pt is reachable from a. Then c is the immediate successor of L_pt in limit_dom (no limit_dom point between them, by the guard property of the C5 witness), so c = succ(L_pt) = succ^[k+1](a) for some k.

Phase 1 (imports and order equalities) is preserved from plan v7 as [COMPLETED]. Phase 2 is entirely new: first-stage induction infrastructure and the main proof. Phase 3 is verification.

**Definition of done**: `limitDomSubtype_isSuccArchimedean` at line 1190 is sorry-free. `succ_embed_surjective` is sorry-free. `dd_countermodel_chronicle_discrete` is sorry-free. The only remaining sorry sites in `ChronicleToCountermodel.lean` are `dd_countermodel_chronicle_nondense_sorry` and `dd_countermodel_chronicle_mixed_sorry`.

## Goals & Non-Goals

**Goals:**
- Close the sorry at line 1402 by replacing the convergence proof body with first-stage induction
- Add `first_stage` definition and helper lemmas in ChronicleConstruction.lean
- Prove the main induction lemma: any limit_dom point reachable (by order) from a is reachable by succ iteration
- Derive IsSuccArchimedean from the induction lemma
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Preserving the convergence framework (Steps 1-4, three helper lemmas) -- these are REPLACED, not extended
- Proving `Set.Finite (Set.Icc a b)` or LocallyFiniteOrder -- not needed for this approach
- Implementing MCS periodicity, adequate sets, EF games, or k-equivalence
- Modifying Phase 1 from plan v7 (already [COMPLETED])
- Solving the mixed or nondense cases

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| L_pt does not exist (c is below all dom(N) points) | H | M | Handle this edge case explicitly: if c.val < all dom(N) points, then c was placed as the new minimum. Since dom(0) = {0} and 0 is always in the domain, and c entered at stage N+1 > 0, there must be at least 0 in dom(N). If c.val < 0, handle via the ordering of limit_dom. See Phase 2 Step 2b for details. |
| L_pt satisfies L_pt.val < a.val (below a) | H | M | If the largest dom(N) point below c.val is below a, we still need c reachable from a. Use succ_orbit_convex: since a <= c and L_pt < a, and L_pt is reachable from the global minimum, a must be reachable from L_pt (by IH on a), and then c = succ(L_pt) follows. But actually, we need to show a is also reachable. The IH gives us reachability of L_pt from any starting point, but the theorem statement fixes the starting point as a. Resolution: prove the induction lemma universally -- for ALL pairs (a, c) with a <= c, c is reachable from a -- not just for a fixed a. |
| Uniqueness of immediate successor: other limit_dom points could exist between L_pt and c | H | L | The C5 witness guard ensures bot is in limit_f(w) for all w between L_pt and the witness. Since bot is never in any MCS, no limit_dom point exists between them. This is the same argument used in report 08 Section 1.5 (verified). |
| c was placed BEYOND all dom(N) points (as the new maximum) | M | M | In this case c.val > max(dom(N)). The max of dom(N) is also in limit_dom with first_stage <= N. By IH, max(dom(N)) is reachable from a. Then c = succ(max(dom(N))) because c is the immediate successor (no limit_dom points between). This is actually the simpler case. |
| The proof restructuring grows beyond 350 lines | M | M | The first_stage definition and basic properties are ~30 lines. The lower-bound lemma is ~50-80 lines. The main induction is ~100-150 lines. The wrapper is ~20 lines. Total ~200-280 lines. Fallback: if the induction stalls, use LocallyFiniteOrder (400-600 lines, 85% confidence). |
| Build breaks from removing convergence proof body | L | L | The convergence framework (lines 1196-1402) is entirely inside the proof body of `limitDomSubtype_isSuccArchimedean`. No other theorem references the `have` bindings inside it. Replacing the proof body does not affect any external API. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add the two missing Mathlib imports and prove that `Order.succ` equals `limitDomSubtype_succ` when the `SuccOrder` instance is registered via `letI`.

**Tasks**:
- [x] Add `import Mathlib.Topology.Instances.Real.Lemmas` (already present, line 11)
- [x] Add `import Mathlib.Data.Rat.Cast.Order` (already present, line 12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: 0.5-1 hour (completed)

**Depends on**: none

**Completed**: 2026-05-11

---

### Phase 2: First-Stage Induction Proof [NOT STARTED]

**Goal**: Define `first_stage`, prove helper lemmas about construction-stage relationships, prove the main induction lemma, and replace the convergence proof body with a first-stage induction proof.

**Context**: The current proof body (lines 1196-1402) uses convergence in R to derive False from the assumption that the orbit never reaches b. This approach fails at the gap-at-L case. The replacement proof does not use a by-contradiction argument at all; instead, it directly constructs the witness n such that succ^[n](a) = b, using strong induction on first_stage.

#### Step 2a: Add `first_stage` definition and basic properties (ChronicleConstruction.lean)

Add these definitions/lemmas near the end of ChronicleConstruction.lean (after the limit_chronicle section, around line 1190):

```lean
/-- The first stage at which a rational enters the omega-chain domain. -/
noncomputable def first_stage (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) : Nat :=
  Nat.find hx

theorem first_stage_spec (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    x ∈ (omega_chain_val A h_mcs (first_stage A h_mcs x hx)).dom :=
  Nat.find_spec hx

theorem first_stage_min (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (n : Nat)
    (hn : x ∈ (omega_chain_val A h_mcs n).dom) :
    first_stage A h_mcs x hx ≤ n :=
  Nat.find_min' hx hn

theorem first_stage_not_mem (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (n : Nat)
    (hn : n < first_stage A h_mcs x hx) :
    x ∉ (omega_chain_val A h_mcs n).dom :=
  Nat.find_min hx hn
```

Expected: ~25 lines.

#### Step 2b: Prove lower-bound lemma (ChronicleConstruction.lean)

When c enters the domain at stage N+1 (first_stage = N+1), there must exist a dom(N) point below c that was used as the "start point" of the counterexample walk. This is the L_pt (lower bound point).

```lean
/-- When a point c enters at stage N+1, there exists a dom(N) point
    at or below c with strictly smaller first_stage. -/
theorem first_stage_has_lower_neighbor (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (c : Rat) (hc : c ∈ limit_dom A h_mcs)
    (h_pos : first_stage A h_mcs c hc > 0) :
    ∃ x, x ∈ (omega_chain_val A h_mcs (first_stage A h_mcs c hc - 1)).dom ∧
      x < c ∧
      (∀ w ∈ limit_dom A h_mcs, x < w → w < c → False) :=
```

The key facts needed:
- c is in dom(N+1) but not dom(N) (from first_stage properties)
- c was inserted by `eliminate_potential_counterexample` at stage N
- The elimination produces a witness between two adjacent dom(N) points (or beyond max), in either case with no limit_dom points between the lower bound and c (by the guard property)
- The guard for xi = bot ensures no MCS between the lower bound and c

**Critical edge cases to handle:**
1. **c is a C5 forward witness**: c = (pt + x') / 2 where pt is the counterexample point and x' is the ceiling. The lower bound is pt (or the largest dom(N) point <= pt). The guard prevents limit_dom points between pt and c.
2. **c is a C5 backward witness**: c = (pt + x') / 2 where x' is the floor below pt. The lower bound is c itself... no, c is below pt. Actually for C5 backward, the witness y is placed below x (the reference point). The lower bound below c would be x' (floor). Guard prevents limit_dom between x' and c.
3. **c is placed beyond all dom(N) points (new max)**: This can happen for C5 forward when pt = max(dom(N)). Then c > max(dom(N)). The lower bound is max(dom(N)). Guard prevents limit_dom between max(dom(N)) and c.
4. **c is placed below all dom(N) points (new min)**: For C5 backward when pt = min(dom(N)). Lower bound does not exist below c. But 0 is always in dom(0) subset dom(N), and 0 is the minimum of dom(0), so if c < 0 this case can arise. However, the construction starts at {0} and only inserts rationals between existing points or beyond endpoints, so c < 0 is possible for C5 backward.

For case 4, the lemma statement should allow for the possibility that there is no dom(N) point below c. In that case, we need a different lemma: c is the immediate predecessor of some dom(N) point, and the guard prevents limit_dom between c and that upper neighbor.

**Revised approach**: Instead of requiring a lower neighbor, prove two separate lemmas:
- `first_stage_adj_above`: when c enters at stage N+1, there exists a dom(N) point x' above c such that no limit_dom point exists between c and x'.
- `first_stage_adj_below`: when c enters at stage N+1 AND there exists a dom(N) point below c, the largest such point L_pt satisfies: no limit_dom point between L_pt and c.

Actually, the cleanest approach for the main induction is:

**For the C5 forward case** (which is the relevant one for U(T,bot) in the discrete case): The witness c is placed above the reference point pt. The reference point pt is in dom(N). The guard ensures no limit_dom point between pt and c. So succ(pt) = c in limit_dom.

**For the main IsSuccArchimedean lemma**: We do not need to handle C5 backward separately because the theorem is about a specific pair (a, b) with a <= b. The key structural fact is:

For any c in limit_dom with first_stage(c) = N+1 > 0:
- c was inserted at stage N+1 as a witness
- There is an "adjacent" dom(N) point that c is immediately next to in limit_dom
- Specifically, c has an immediate predecessor or immediate successor in limit_dom that was already in dom(N)

**Simplified lemma for the induction**: We need:
```
For c in limit_dom with first_stage(c) = N+1:
  pred(c) in limit_dom has first_stage(pred(c)) <= N
```

This is because pred(c) (the immediate predecessor in limit_dom) must have been in dom at some stage, and since c was the newly inserted point at stage N+1, pred(c) was already in the domain at stage N or earlier.

But actually, this is not automatically true. The predecessor in limit_dom might have been inserted at a LATER stage than c. Example: c enters at stage 5, and later at stage 10 a point d is inserted between some point e and c (with e < d < c). Then pred(c) = d which has first_stage = 10 > 5.

**Resolution**: The key insight is that c was inserted at stage N+1 as a new point between two ADJACENT dom(N) points (L_pt and U_pt). The guard at insertion ensures no further limit_dom points can be inserted between L_pt and c, because the guard sets g(L_pt, c) such that bot (or the guard formula xi) is in the guard. For U(T,bot), xi = bot, so no MCS can exist between L_pt and c. This means pred(c) = L_pt in limit_dom, and first_stage(L_pt) <= N.

This is the critical construction-specific fact. The guard prevents future insertions between L_pt and c, guaranteeing that the dom(N) neighbor remains the immediate predecessor in the LIMIT domain.

Expected: ~50-80 lines.

#### Step 2c: Prove main induction lemma (ChronicleToCountermodel.lean)

Replace the proof body of `limitDomSubtype_isSuccArchimedean` (lines 1196-1402). The new proof uses strong induction on `first_stage(b)` (not by_contra):

```lean
-- Direct proof by strong induction on first_stage(b)
-- For any a <= b, b is reachable from a by finitely many succ applications.
```

**Proof outline:**

1. Suffice: `exists n, b <= succ^[n](a)` (then succ_orbit_convex gives equality).
2. Strong induction on `first_stage(b.val, b.property)`:
   - **Base case**: first_stage(b) = 0. Then b.val is in dom(0) = {0}. So b.val = 0. Since a <= b and a.val >= some dom minimum... Actually, the base case analysis: dom(0) = the singleton {0} (from `singleton_chronicle`). So first_stage(b) = 0 implies b.val = 0. Since a <= b, a.val <= 0. Since a is in limit_dom, a.val >= 0 (because... actually a.val could be negative). In the discrete case, all domain points have next_top in their MCS, so the construction also processes C5 backward counterexamples. The initial domain is {0}, and backward witnesses are placed below 0.
   
   So b.val = 0 and a.val <= 0 is the base case. If a.val = 0 then a = b and n = 0 works. If a.val < 0, then a < b, and we need succ^[n](a) >= b for some n. Since first_stage(a) > 0 (a.val < 0 but dom(0) = {0}), the induction doesn't give us this directly. We need a different approach for the base case.

   **Better base case handling**: Use induction on first_stage(b) - first_stage(a) or on first_stage(b) alone. The base case first_stage(b) <= first_stage(a) means b entered the domain no later than a. But this doesn't help directly.

   **Best approach**: Generalize. Prove:
   ```
   For all c in limit_dom, for all a in limit_dom with a <= c,
     exists n, succ^[n](a) = c
   ```
   by strong induction on first_stage(c):
   - If a = c: n = 0.
   - If a < c: Consider pred(c) in limit_dom. We have a <= pred(c) < c. And first_stage(pred(c)) < first_stage(c) (by the lower-bound lemma). By IH, exists m, succ^[m](a) = pred(c). Then succ^[m+1](a) = succ(pred(c)) = c.

   Wait -- this requires first_stage(pred(c)) < first_stage(c). Is this always true?

   The lower-bound lemma from Step 2b gives: when c enters at stage N+1, pred(c) in limit_dom has first_stage <= N < N+1 = first_stage(c). This uses the guard property.

   When first_stage(c) = 0, c is in dom(0) = {0}, so c.val = 0. And a <= c means a.val <= 0. If a.val = 0 then a = c. If a.val < 0, then first_stage(a) >= 1 > 0 = first_stage(c). So a entered the domain AFTER c. Now pred(c) = pred of the point 0 in limit_dom. pred(0 in limit_dom) is some point with value < 0. Does pred(c) have first_stage < first_stage(c) = 0? No, impossible since first_stage >= 0. So the base case where a < c and first_stage(c) = 0 means first_stage(a) > 0, and pred(c) has first_stage >= 1 > 0 = first_stage(c). The IH doesn't apply to pred(c) since first_stage(pred(c)) >= first_stage(c).

   **This is a real problem.** The induction on first_stage(c) alone does not work when a < c and first_stage(a) > first_stage(c).

   **Resolution**: Induct on BOTH first_stage(a) + first_stage(c), or use a different well-founded relation.

   **Better resolution**: Induct on first_stage(c) but handle the base differently.

   Actually, rethink: we need `first_stage(pred(c)) < first_stage(c)` for the induction to work. This is guaranteed when first_stage(c) > 0 by the lower-bound lemma. When first_stage(c) = 0, c.val = 0 and pred(c) has first_stage >= 1. So the IH doesn't apply to pred(c).

   But in the case first_stage(c) = 0 with a < c: a.val < 0 = c.val. We need succ^[n](a) = c. Consider succ(a). Since a < c, succ(a) <= c. If succ(a) = c, done. If succ(a) < c, recurse. But first_stage(succ(a)) could be anything.

   **Alternative approach**: Don't induct on first_stage(c). Instead, induct on first_stage(c) but make the inductive hypothesis stronger -- prove reachability for ALL starting points a <= c, not just a fixed a. Then:

   IH: for all d with first_stage(d) < first_stage(c), for all a <= d, exists n, succ^[n](a) = d.

   Goal: for all a <= c, exists n, succ^[n](a) = c.

   If a = c: n = 0.
   If a < c and first_stage(c) > 0: pred(c) has first_stage < first_stage(c) by the lower-bound lemma. Two sub-cases:
     - a <= pred(c): by IH, exists m, succ^[m](a) = pred(c). Then succ^[m+1](a) = c.
     - pred(c) < a: impossible since a < c and pred(c) is the immediate predecessor of c in limit_dom. a < c and a is in limit_dom, so either a <= pred(c) or a = c (no limit_dom between pred(c) and c). Since a < c, we must have a <= pred(c).

   Wait, is it true that if a < c in LimitDomSubtype and pred(c) is the immediate predecessor, then a <= pred(c)? Yes: pred(c) is the greatest limit_dom point strictly less than c. If a < c and a is in limit_dom, then a <= pred(c) (since pred(c) >= all limit_dom points < c).

   If a < c and first_stage(c) = 0: c.val = 0. a.val < 0. pred(c) has first_stage >= 1.
   But wait -- we cannot apply IH to pred(c) because first_stage(pred(c)) >= 1 > 0 = first_stage(c). The IH requires first_stage < first_stage(c) = 0, which is impossible.

   **This means first_stage(c) = 0 with a < c is a real problem case.**

   **Key resolution**: In this case, a.val < 0 and first_stage(a) >= 1. So first_stage(a) > first_stage(c) = 0. Consider succ(a). succ(a) > a (strict). Since first_stage(a) >= 1, at stage first_stage(a) the point a was inserted. The point a was inserted between two existing points in dom(first_stage(a) - 1). The upper neighbor of a at that stage has first_stage <= first_stage(a) - 1 < first_stage(a).

   Hmm, but that's the upper neighbor, not a itself. We need to track how far "up" we can go.

   **Alternative clean approach**: Instead of inducting on first_stage(c), induct on the number of limit_dom points in the interval [a, c]. This is the LocallyFiniteOrder approach (option 2 from report 08). But we wanted to avoid that.

   **Best clean approach for first_stage induction**: Change the induction variable.

   Prove: for all N, for all a c in limit_dom with a <= c and first_stage(a) <= N and first_stage(c) <= N, exists n, succ^[n](a) = c.

   Induction on N.
   - Base N = 0: a and c both in dom(0) = {0}. So a = c. n = 0.
   - Step N -> N+1: Given a <= c with first_stage(a) <= N+1 and first_stage(c) <= N+1.
     - If both first_stage(a) <= N and first_stage(c) <= N: by IH, done.
     - If first_stage(c) = N+1 (and first_stage(a) <= N+1):
       - If a = c: n = 0.
       - If a < c: pred(c) has first_stage <= N (by lower-bound lemma). And a <= pred(c) (since pred(c) is the greatest limit_dom point < c). Also first_stage(a) <= N+1. Sub-cases:
         - first_stage(a) <= N: by IH (both a and pred(c) have first_stage <= N), exists m, succ^[m](a) = pred(c). Then succ^[m+1](a) = c.
         - first_stage(a) = N+1: then a also entered at stage N+1. Since omega_chain_dom_new_unique says at most one new point per stage, and first_stage(a) = N+1 = first_stage(c) with a < c, we need a.val and c.val both new at stage N+1. But uniqueness says at most one new point. So a and c cannot both be new at the same stage unless a = c. Contradiction with a < c. So this sub-case is impossible.
     - If first_stage(a) = N+1 and first_stage(c) <= N:
       - a entered at stage N+1. succ(a) has first_stage <= N (by the upper-neighbor argument -- succ(a) is the upper neighbor of a at insertion, which was in dom(N)). And succ(a) <= c (since a < c, succ(a) <= c). Since first_stage(succ(a)) <= N and first_stage(c) <= N, by IH: exists m, succ^[m](succ(a)) = c. Then succ^[m+1](a) = c.

   Wait -- I need `first_stage(succ(a)) <= N` when first_stage(a) = N+1. Is this true?

   When a enters at stage N+1, it is placed as a new point. In limit_dom, succ(a) is the immediate successor. The immediate successor of a in limit_dom could be:
   - The upper neighbor at stage N+1 (which was in dom(N), so first_stage <= N). The guard prevents insertion between a and this upper neighbor, so succ(a) = upper neighbor. First_stage(succ(a)) <= N. YES.
   - A point inserted at a later stage between a and the upper neighbor. But the guard prevents this (for the specific guard formula). For C5 forward with xi = bot, the guard puts bot in limit_f(w) for all w between a and the upper neighbor, so no MCS can exist there, and no limit_dom point is between them. So succ(a) = upper neighbor and first_stage(succ(a)) <= N. YES.
   - BUT: what about C5 backward witnesses? If a was a C5 backward witness, the guard is between the lower neighbor and a, not between a and the upper neighbor. So the upper neighbor relationship is not protected by a guard. Points COULD be inserted between a and the upper neighbor at later stages.

   **Critical realization**: The guard direction matters. For C5 forward witnesses, the guard protects (start, witness). For C5 backward witnesses, the guard protects (witness, start). So:
   - C5 forward witness c: no limit_dom between start and c. So pred(c) = start. first_stage(pred(c)) <= N.
   - C5 backward witness c: no limit_dom between c and start. So succ(c) = start. first_stage(succ(c)) <= N.

   So regardless of direction, either pred(c) or succ(c) has first_stage <= N when first_stage(c) = N+1. For the forward case, pred(c) has smaller first_stage. For the backward case, succ(c) has smaller first_stage.

   The induction on N therefore works:
   - When first_stage(a) = N+1 and first_stage(c) <= N with a < c: a was a witness. If a was a forward witness, pred(a) has first_stage <= N, but pred(a) < a < c doesn't directly help. If a was a backward witness, succ(a) has first_stage <= N, succ(a) <= c, and by IH (both succ(a) and c have first_stage <= N), succ^[m](succ(a)) = c for some m. Done with m+1.
   
   But what if a was a FORWARD witness? Then pred(a) has first_stage <= N, but succ(a) might not. succ(a) could be a point inserted later with first_stage > N.

   **Wait**: For a forward witness a at stage N+1: the witness a is placed between the start point pt and the ceiling x'. The guard protects (pt, a): no limit_dom between pt and a. So pred(a) = pt and first_stage(pt) <= N. But what about points between a and x'? The guard does NOT protect (a, x'). So a point d could be inserted between a and x' at a later stage, making succ(a) = d with first_stage(d) > N+1.

   However, a could also be a C5 backward witness. In that case: the witness a is placed below the start point. The guard protects (a, pt): no limit_dom between a and pt. So succ(a) = pt and first_stage(pt) <= N.

   So in the case first_stage(a) = N+1 and first_stage(c) <= N:
   - If a is a C5 backward witness: succ(a) = pt (the start point) with first_stage(pt) <= N. succ(a) <= c (since a < c and succ(a) is the next point). By IH, succ^[m](succ(a)) = c for some m. Done.
   - If a is a C5 forward witness: pred(a) = pt with first_stage(pt) <= N. succ(a) might have large first_stage. We need an alternative argument.

   For the forward case: consider all limit_dom points between a and c. Since first_stage(c) <= N, c was in dom(N). Was c in dom(N+1)? Yes (domain is monotone). Was c already present when a was inserted? Yes, if first_stage(c) <= N <= N+1. So c was in dom(N+1 - 1) = dom(N). Now, when a was inserted at stage N+1 as a forward witness, a was placed between pt and x' (the ceiling above pt). Since c is in dom(N) and c > a, we have c >= x' (because x' is the immediate successor of pt in dom(N), and a = (pt + x') / 2, so a < x' <= c). Actually c could equal x' or c > x'.

   If c = x': then succ(a) might not be x' if something was inserted between a and x' later. But the guard between (pt, a) only protects below a. Above a, the region (a, x') has g(a, x') = some set from the witness walk. For C5 forward with xi = bot, does the guard extend to (a, x')?

   Looking at the C5 forward walk more carefully: the walk for U(eta, xi) at pt inserts witness z between pt and x'. The guard ensures xi is in g(pt, z) and g(z, x') values. But for xi = bot, it ensures bot is in these g-values. The g-values g(pt, z) are set, and g(z, x') is also set. The adj_g_mem_limit_f lemma then ensures bot is in limit_f(w) for all w between pt and z AND between z and x'. Wait -- does the guard cover the (z, x') interval too?

   From report 08 Section 1.2: For xi = bot, the guard at (pt, z) puts bot in g(pt, z), and adj_g_mem_limit_f gives bot in limit_f(w) for w between pt and z. What about (z, x')? The walk ALSO sets g(z, x') values. Looking at the walk structure in CounterexampleElimination.lean: the split case creates a new point z with g(pt, z) = B' (a maximal consistent set with xi in it) and inherits g(z, x') from the old g(pt, x'). So g(z, x') = old g(pt, x'). The old g(pt, x') may or may not contain bot.

   Actually, for the walk of U(T, bot) at pt, the ONLY guarantee from the walk is:
   - z is placed at (pt + x') / 2
   - g(pt, z) = B' with bot in B' (well, with xi = bot in B')
   - The guard between pt and z prevents intermediate limit_dom points

   But between z and x', the old g-values are preserved. There is NO guard preventing points between z and x'. So points CAN be inserted between a (= z) and x' at later stages.

   This means succ(a) might NOT be x'. It could be a point inserted between a and x' at a later stage.

   **Impact on the induction**: When first_stage(a) = N+1 and a is a C5 forward witness with start pt:
   - pred(a) = pt in limit_dom, first_stage(pt) <= N. Good.
   - succ(a) is unknown -- could have any first_stage.

   So for the induction step where first_stage(a) = N+1 and first_stage(c) <= N with a < c: if a is a forward witness, we cannot get succ(a) with first_stage <= N. We need a different argument.

   **Alternative for this case**: Since pred(a) = pt with first_stage(pt) <= N, and pt < a < c, and first_stage(pt) <= N and first_stage(c) <= N, by IH: exists m, succ^[m](pt) = c. But pt < a <= succ^[m](pt) = c, so by succ_orbit_convex there exists k <= m with succ^[k](pt) = a. Then succ^[m-k](a) = succ^[m-k](succ^[k](pt)) = succ^[m](pt) = c. Done!

   Wait -- this uses succ_orbit_convex applied to pt, a, m. We need pt <= a (yes) and a <= succ^[m](pt) = c (yes, since a < c implies a <= c). So succ_orbit_convex gives k <= m with succ^[k](pt) = a. Then succ^[m](pt) = succ^[m-k](succ^[k](pt)) = succ^[m-k](a). And succ^[m](pt) = c. So succ^[m-k](a) = c. Done.

   This works. The key trick: when a is a forward witness with pred(a) = pt having first_stage <= N, use the IH to reach c from pt, then factor through a using orbit convexity.

   **Complete induction step for first_stage(a) = N+1 case:**
   - pred(a) = pt (if forward) or succ(a) = pt (if backward), with first_stage(pt) <= N.
   - Case forward (pred(a) = pt, pt < a):
     - Need succ^[n](a) = c with a < c and first_stage(c) <= N.
     - By IH applied to (pt, c): exists m, succ^[m](pt) = c. (Both have first_stage <= N.)
     - pt <= a <= c = succ^[m](pt). By succ_orbit_convex: exists k <= m, succ^[k](pt) = a.
     - Then succ^[m-k](a) = c.
   - Case backward (succ(a) = pt, a < pt):
     - succ(a) = pt with first_stage(pt) <= N. succ(a) <= c. 
     - By IH applied to (pt, c): exists m, succ^[m](pt) = c. (Both have first_stage <= N, and pt <= c since a < pt <= c... wait, we need pt <= c. We have a < c. succ(a) = pt. Is pt <= c? Since succ(a) = pt and a < c, we have pt = succ(a) <= c (succ is monotone and succ(a) is the least element > a; since a < c, succ(a) <= c). Yes.
     - succ^[m+1](a) = succ^[m](pt) = c.

   This works for both directions.

**Now the full induction on N:**

Prove: for all N, for all a c : LimitDomSubtype with a <= c and first_stage(a) <= N and first_stage(c) <= N, exists n, succ^[n](a) = c.

By strong induction on N:
- **N = 0**: first_stage(a) = 0 and first_stage(c) = 0. Both in dom(0) = {0}. So a = c. n = 0.
- **N+1, assuming IH for all M <= N**: Given a <= c with first_stage(a) <= N+1, first_stage(c) <= N+1.
  - If first_stage(a) <= N and first_stage(c) <= N: by IH(N), done.
  - If first_stage(c) = N+1 and a < c:
    - pred(c) has first_stage <= N (lower-bound lemma).
    - a <= pred(c) (since pred(c) is the greatest limit_dom point < c, and a < c means a <= pred(c)).
    - Sub-case first_stage(a) <= N: by IH(N) on (a, pred(c)), get m with succ^[m](a) = pred(c). Then succ^[m+1](a) = c.
    - Sub-case first_stage(a) = N+1: omega_chain_dom_new_unique says at most one new point per stage. So a.val = c.val (both new at stage N+1). But a < c gives a.val < c.val. Contradiction. Impossible.
  - If first_stage(a) = N+1 and first_stage(c) <= N and a < c:
    - a was inserted at stage N+1 as a witness. Has a neighbor pt with first_stage(pt) <= N.
    - Case forward (pred(a) = pt): by IH(N) on (pt, c), get m with succ^[m](pt) = c. By orbit convexity (pt <= a <= c = succ^[m](pt)), get k with succ^[k](pt) = a. Then succ^[m-k](a) = c.
    - Case backward (succ(a) = pt): succ(a) = pt <= c with first_stage(pt) <= N. By IH(N) on (pt, c), get m. Then succ^[m+1](a) = c.

**This induction is clean and handles all cases.** The only lemmas needed are:
1. `first_stage` definition and basic properties (Step 2a)
2. Lower-bound lemma: first_stage(pred(c)) < first_stage(c) when first_stage(c) > 0 (Step 2b)
3. Upper-bound lemma for the a = N+1 case: a has a neighbor with first_stage <= N (Step 2b extended)
4. `omega_chain_dom_new_unique`: at most one new point per stage (exists)
5. `succ_orbit_convex` (exists)

**Implementation plan for the proof body:**

The proof body of `limitDomSubtype_isSuccArchimedean` will be:
```lean
@IsSuccArchimedean.mk _ _ (limitDomSubtype_succOrder A h_mcs h_discrete) <| by
  intro a b hab
  change ∃ n, (limitDomSubtype_succ A h_mcs h_discrete)^[n] a = b
  exact first_stage_succ_archimedean A h_mcs h_discrete a b hab
```

Where `first_stage_succ_archimedean` is the main induction lemma proved separately (either in ChronicleConstruction.lean or ChronicleToCountermodel.lean).

**Tasks for Step 2c:**
- [ ] Prove `first_stage_pred_lt`: when first_stage(c) > 0, first_stage(pred(c)) < first_stage(c) in the DISCRETE case (using the guard property for xi = bot)
- [ ] Prove `first_stage_neighbor_lt`: when first_stage(a) > 0, a has a neighbor (pred or succ depending on witness direction) with first_stage < first_stage(a)
- [ ] Prove `first_stage_succ_archimedean`: the main induction lemma, by strong induction on N = max(first_stage(a), first_stage(b))

**Timing**: 2-4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add `first_stage` definition, basic properties, lower-bound lemma (~80-120 lines total)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace proof body of `limitDomSubtype_isSuccArchimedean` (lines 1196-1402) with call to the induction lemma; add the induction lemma itself nearby (~100-150 lines)

#### Step 2d: Wire up the main theorem (ChronicleToCountermodel.lean)

Replace lines 1196-1402 (the entire `by` block of `limitDomSubtype_isSuccArchimedean`) with the new proof that calls the induction lemma from Step 2c. The theorem statement (lines 1190-1195) is UNCHANGED.

**Tasks:**
- [ ] Delete lines 1196-1402 (the old convergence proof body including all `have` bindings, helper lemmas, and the final sorry)
- [ ] Insert new proof body calling `first_stage_succ_archimedean`
- [ ] Verify with `lean_goal` and `lean_verify` that the new proof compiles

**Timing**: 0.5 hour

**Depends on**: Step 2c

---

### Phase 3: Verification and Cleanup [NOT STARTED]

**Goal**: Verify the proof compiles, confirm sorry elimination downstream, and clean up any temporary scaffolding.

**Tasks**:
- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` confirms no sorry
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` confirms only nondense and mixed stubs remain
- [ ] Full `lake build` passes
- [ ] Remove any temporary `#check` or `#eval` scaffolding

**Timing**: 0.5-1 hour

**Depends on**: 2

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after Phase 2
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` confirms no sorry
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` shows only `dd_countermodel_chronicle_nondense_sorry` and `dd_countermodel_chronicle_mixed_sorry`
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/08_first-stage-induction.md` (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (new `first_stage` definition and helper lemmas, ~80-120 lines added)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (proof body of `limitDomSubtype_isSuccArchimedean` replaced, net change ~100-150 lines replacing ~200 lines)
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/08_first-stage-induction-summary.md` (after implementation)

## Rollback/Contingency

The convergence proof body (lines 1196-1402) is entirely replaced. The theorem statement is unchanged. Rollback: `git checkout` the two modified files.

If the first-stage induction approach fails:

1. **Primary fallback: LocallyFiniteOrder** (85% confidence, 400-600 lines): Prove `Set.Finite (Set.Icc a b)` for all a, b : LimitDomSubtype. This is more heavyweight but uses a well-trodden Mathlib path. The key challenge is the same (bounding the number of limit_dom points between a and b using construction stage analysis), but the payoff is a reusable LocallyFiniteOrder instance.

2. **Secondary fallback: Restore convergence + attempt MCS periodicity** (50% confidence): Restore the convergence proof body and attempt the MCS periodicity argument from plan v7 at line 1402. Downside: the "same label same gap" sub-lemma is fragile.

3. **Last resort: Leave sorry with detailed documentation**: Write a comprehensive comment explaining the first-stage induction argument, the construction-specific facts needed, and why it stalled. Keep the sorry well-localized.
