# Implementation Plan: Stage-Walk Proof of IsSuccArchimedean

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
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
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/09_step6-validation.md
- **Artifacts**: plans/09_stage-walk.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Reports integrated in this plan version:**
- `09_step6-validation.md` (newly integrated in v9)
- `08_implementation-handoff.md` (newly integrated in v9, handoff artifact)
- `08_c5-midpoint-analysis.md` (integrated in v8, preserved)
- `07_verbrugge-deep-study.md` (integrated in v7, preserved)
- `07_doets-reynolds-deep-study.md` (integrated in v7, preserved)
- `07_codebase-fit-analysis.md` (integrated in v7, preserved)
- `07_mathematical-comparison.md` (integrated in v7, preserved)
- `04_team-research.md` through `06_team-research.md` (integrated in v4-v6, preserved)

**Key findings from report 09 and handoff 08 that drive this revision:**

1. **Plan v8's first_stage(pred(c)) assumption is WRONG** (handoff Section 1): The plan v8 induction relied on `first_stage(pred(c)) < first_stage(c)`. This fails because pred(c) in limit_dom is the C5'/S(T,bot) backward witness for c, which can be processed at a LATER stage than c. When c is a forward witness entering at stage N+1, its backward witness (pred) may not be processed until stage M+1 >> N+1.

2. **Plan v8's orbit convexity trick works for non-boundary cases but fails at boundaries** (handoff Section 1): When c is between two adjacent dom(N) points (pt, U0), orbit convexity handles it: IH gives succ^[m](pt) = U0, then convexity gives succ^[j](pt) = c. But when c is beyond max(dom(N)) (C5 forward walk base case), there is no upper dom(N) neighbor to anchor the orbit convexity argument.

3. **Step 6 of the convergence proof is INVALID** (report 09): The claim that ceiling predecessors must eventually drop below L is unsupported. The gap-at-L scenario is order-theoretically self-consistent (omega + omega* type). Convergence-based arguments cannot close the sorry.

4. **The stage-walk approach bypasses all these issues** (handoff Section 4, Option C): Instead of reasoning about individual points' first_stage or about gaps/convergence, pick N large enough that ALL C5-bot counterexamples at dom(N) points between a and b are resolved. Then the succ-orbit walks through dom(N) points from a to b via resolved C5-bot witnesses.

### Why Plan v9 Supersedes Plan v8

Plan v8 attempted first_stage induction on individual points: "for each c with a <= c, show c is reachable from a by induction on first_stage(c)." This requires showing pred(c) or succ(c) has smaller first_stage, which fails for backward witnesses.

Plan v9 takes a fundamentally different approach: instead of tracking individual points, it picks a sufficiently large stage N and shows the succ-orbit walks through ALL dom(N) points in [a.val, b.val]. The key structural fact is that when a C5-bot counterexample at a dom(N) point x has been processed by stage N, the witness y = succ(x) in limit_dom is between x and the next dom(N) point above x, and no limit_dom point exists between x and y (by the bot-guard). So succ steps through: x -> y -> next_dom_point -> ... -> b.

### Prior Plan Reference

Plan v8 (`08_first-stage-induction.md`) had 3 phases:
- **Phase 1** [COMPLETED]: Mathlib imports + `order_succ_eq` / `order_pred_eq` (both `rfl`)
- **Phase 2** [NOT STARTED]: First-stage induction proof (blocked by the pred(c) gap)
- **Phase 3** [NOT STARTED]: Verification and cleanup

### Roadmap Alignment

This plan advances:
- "Discrete completeness: 1 sorry remains (task 122)" -- closing `limitDomSubtype_isSuccArchimedean` makes the discrete countermodel sorry-free
- "Full `bx_completeness`: Blocked by 1 sorry in discrete case" -- unblocking the discrete case moves toward sorry-free `bx_completeness`

## Overview

This plan replaces the convergence-based proof body of `limitDomSubtype_isSuccArchimedean` (lines 1196-1402 in `ChronicleToCountermodel.lean`) with a stage-walk argument. The existing proof attempts to derive False from the assumption that the succ-orbit never reaches b, using monotone convergence in R. This approach stalls at the gap-at-L case. The replacement proof instead shows directly that succ^[k](a) = b for some k, by choosing a sufficiently large stage N and walking through resolved C5-bot witnesses at dom(N) points.

The key idea: for any a <= b in LimitDomSubtype, choose N large enough that (1) both a.val and b.val are in dom(N), and (2) for every dom(N) point x in [a.val, b.val] with U(T,bot) in f(x), the C5 forward counterexample at x has been processed by stage N. Such N exists because dom(N) is finite, each point enters at a finite stage, and `counterexample_enum_surjective` ensures each counterexample is eventually processed. At this stage N, every dom(N) point x between a and b has its U(T,bot) forward witness y in dom(N), and the bot-guard ensures no limit_dom point between x and y. So succ(x) = y in limit_dom, and y is between x and the next dom(N) point. The succ-orbit from a thus steps through dom(N) points, reaching b in at most 2 * |dom(N)| steps.

Phase 1 (imports and order equalities) is preserved from plan v7 as [COMPLETED]. Phase 2 is entirely new: the stage-walk proof. Phase 3 is verification.

**Definition of done**: `limitDomSubtype_isSuccArchimedean` at line 1190 is sorry-free. `succ_embed_surjective` is sorry-free. `dd_countermodel_chronicle_discrete` is sorry-free. The only remaining sorry sites in `ChronicleToCountermodel.lean` are `dd_countermodel_chronicle_nondense_sorry` and `dd_countermodel_chronicle_mixed_sorry`.

## Goals & Non-Goals

**Goals:**
- Close the sorry at line 1402 by replacing the convergence proof body with the stage-walk argument
- Prove the core lemma: for adjacent dom(N) points with resolved C5-bot, succ walks between them
- Prove the main theorem by choosing N large enough and applying the core lemma
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Preserving the convergence framework (Steps 1-4, three helper lemmas) -- these are REPLACED
- Defining `first_stage` as a standalone function -- not needed for this approach
- Proving `Set.Finite (Set.Icc a b)` or LocallyFiniteOrder -- not needed
- Implementing MCS periodicity, adequate sets, EF games, or k-equivalence
- Modifying Phase 1 from plan v7 (already [COMPLETED])
- Solving the mixed or nondense cases

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formalizing "all C5-bot counterexamples resolved" is complex | M | M | Use `counterexample_enum_surjective_above` with `Nat.unpair` to find the stage for each specific (x, U(T,bot)) counterexample. Take the max over the finite set dom(N) intersect [a,b]. |
| The C5 forward witness might not be between x and the next dom(N) point above x | H | L | The C5 walk at x either takes the base case (witness beyond max) or the split case (witness = midpoint of x and ceiling). In both cases, the witness is between x and the ceiling at the processing stage. Since later stages only ADD points, the ceiling at the processing stage is >= the next dom(N) point above x. The witness is between x and this ceiling, hence between x and the next dom(N) point or equal to it. If the witness equals the next dom(N) point, succ(x) = that point and we advance. If strictly between, succ(x) = witness and the next step lands on the next dom(N) point. |
| Walking through dom(N) points requires "adjacent pair" iteration, which is complex in Lean | M | M | Use the existing `Finset.sort` infrastructure. dom(N) sorted gives a list; iterate through consecutive pairs. Alternatively, use strong induction on |dom(N) intersect Icc(a,b)|. |
| The base-case C5 witness (beyond max) might place y beyond b.val | M | L | Since b.val is in dom(N) and the C5 witness y for x is between x and the ceiling at processing time, and all dom(N) points in [a,b] have their counterexamples resolved by stage N, the witness y is <= the next dom(N) point above x <= b.val. The beyond-max case only happens when x = max(dom at processing stage), but by choosing N large enough, b.val is already in the domain, so x < b.val means x is not the max of all domain points >= a. |
| The proof grows beyond 300 lines | M | M | The stage-walk is conceptually simpler than first_stage induction: it avoids individual point tracking and uses only finiteness + counterexample resolution. Estimated 150-250 lines total for new material. Fallback: if the stage-walk stalls, use LocallyFiniteOrder (400-600 lines, 85% confidence). |
| Build breaks from removing convergence proof body | L | L | The convergence framework (lines 1196-1402) is entirely inside the proof body. No external theorem references the internal `have` bindings. Replacing the proof body does not affect any external API. |

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

### Phase 2: Stage-Walk Proof [BLOCKED]

**Goal**: Replace the convergence proof body of `limitDomSubtype_isSuccArchimedean` (lines 1196-1402) with a stage-walk proof that chooses N large enough and walks through resolved C5-bot witnesses.

**Context**: The current proof body uses by_contra + convergence. The replacement proof is constructive: it directly produces the witness n such that succ^[n](a) = b, by walking through dom(N) points between a.val and b.val.

#### Step 2a: Prove `c5_bot_witness_in_dom` -- the C5-bot resolution lemma (~30-50 lines)

**Location**: ChronicleToCountermodel.lean, near line 1190 (before `limitDomSubtype_isSuccArchimedean`).

This lemma says: for any x in limit_dom with U(T,bot) in limit_f(x), there exists a stage M such that the C5 forward witness for U(T,bot) at x is in dom(M), AND the bot-guard ensures no limit_dom point between x and this witness.

This is essentially a specialization of `limit_satisfies_c5_strong` (which already exists and is sorry-free) combined with the fact that the witness is in dom(M) for some M. Actually, `limit_satisfies_c5_strong` already provides everything we need:

```
limit_satisfies_c5_strong : ... ->
  exists y in limit_dom, x < y and top in limit_f(y) and bot in limit_g(x, y)
```

And `limit_dom_has_succ` already converts this to "exists y in limit_dom, x < y, no limit_dom between x and y." And `limitDomSubtype_succ` uses `limit_dom_has_succ` via Classical.choose.

The key question is: can we relate `limitDomSubtype_succ x` to a specific dom(N) point? We need:

```
For x in limit_dom with U(T,bot) in limit_f(x):
  succ(x).val is in limit_dom (trivially true since succ returns a LimitDomSubtype)
  succ(x).val is in dom(M) for some M (trivially true from limit_dom definition)
  No limit_dom point between x.val and succ(x).val (from succ property)
```

Actually, all of this is already encoded in the `limitDomSubtype_succ_le_iff` lemma. The succ function already satisfies: succ(a) <= b iff a < b. This means succ(a) is the least limit_dom point > a, and no limit_dom point exists between a and succ(a).

So what we ACTUALLY need for the stage-walk is not a new lemma about individual points, but rather a lemma about choosing N large enough. Specifically:

**The core lemma we need**: For any finite set S of limit_dom points, there exists N such that all points in S are in dom(N) AND for each x in S, succ(x).val is also in dom(N).

This follows from: (1) each point in S is in dom(m_x) for some m_x (from limit_dom), (2) succ(x).val is in dom(m'_x) for some m'_x (from limit_dom), (3) take N = max over all m_x and m'_x.

**Tasks:**
- [ ] Prove `succ_val_in_dom` (or verify it follows trivially): for x : LimitDomSubtype, succ(x).val is in dom(M) for some M. (This is trivial: succ(x).property gives M.)
- [ ] Prove `exists_stage_covering_finset`: given a Finset of rationals all in limit_dom, there exists N such that all are in dom(N). (By induction on the Finset, taking max of stages. Use `omega_chain_dom_mono_le` for monotonicity.)

**Timing**: 0.5-1 hour

**Depends on**: 1

#### Step 2b: Prove `succ_walks_through_dom_N` -- the finite walk lemma (~80-120 lines)

**Location**: ChronicleToCountermodel.lean, before `limitDomSubtype_isSuccArchimedean`.

This is the heart of the proof. It says: if a.val and b.val are both in dom(N), and a <= b, and for every dom(N) point x in [a.val, b.val] the succ(x).val is also in dom(N), then succ^[k](a) = b for some k.

**Proof strategy**: By strong induction on the number of dom(N) points in the open interval (a.val, b.val).

- **Base case**: No dom(N) points strictly between a.val and b.val. Since a.val and b.val are both in dom(N), they are adjacent in dom(N) (or equal).
  - If a = b: k = 0.
  - If a < b: succ(a) <= b (since a < b). Also succ(a).val is in dom(N) (by hypothesis). And succ(a).val > a.val. Is succ(a).val <= b.val? Yes, since succ(a) <= b (from succ_le_iff). So succ(a).val is a dom(N) point in [a.val, b.val]. Since there are no dom(N) points strictly between a.val and b.val, and succ(a).val > a.val and succ(a).val <= b.val, we must have succ(a).val = b.val. So succ(a) = b and k = 1.

- **Inductive step**: There are m+1 dom(N) points strictly between a.val and b.val. Let x be the smallest such point (the next dom(N) point above a.val). Then x is in dom(N) and a.val < x < b.val. Since x is in dom(N) and in [a.val, b.val], by hypothesis succ(x-as-LimitDomSubtype).val is also in dom(N). Now succ(a) <= x-as-LimitDomSubtype (since a < x, so succ(a) <= x). Also succ(a).val > a.val. And succ(a).val is in dom(N) (by hypothesis on a). So succ(a).val is in [a.val, x]. Since there are no dom(N) points strictly between a.val and x (by choice of x as the smallest), succ(a).val must equal a.val (impossible since succ(a) > a) or x. So succ(a).val = x, meaning succ(a) = x-as-LimitDomSubtype.

  Wait -- succ(a).val might NOT be in dom(N). The hypothesis says: for every dom(N) point z in [a.val, b.val], succ(z-as-LimitDomSubtype).val is in dom(N). Since a.val is in dom(N) and in [a.val, b.val], succ(a).val is in dom(N). Good.

  Now: succ(a).val > a.val and succ(a).val <= x (since a.val < x means succ(a) <= x). succ(a).val is in dom(N). Since x is the smallest dom(N) point > a.val, and succ(a).val is a dom(N) point > a.val with succ(a).val <= x, we get succ(a).val = x.

  But wait -- is succ(a).val necessarily in dom(N)? succ(a).val is in limit_dom, so it is in dom(M) for some M. If M <= N, then succ(a).val is in dom(N) (by monotonicity). But our hypothesis only says succ(a).val is in dom(N) when a.val is a dom(N) point in [a.val, b.val], which it is. So yes, by hypothesis, succ(a).val is in dom(N).

  So succ(a) corresponds to x. Now apply the IH to (x-as-LimitDomSubtype, b): there are m dom(N) points strictly between x and b.val (one fewer). By IH, succ^[j](x) = b for some j. Then succ^[j+1](a) = b.

**Key technical challenge**: converting between dom(N) membership (a Finset property) and LimitDomSubtype values. Need to show that if x is in dom(N).val and in limit_dom, we can form a LimitDomSubtype, and that the succ hypothesis applies to it.

**Alternative cleaner formulation**: Instead of inducting on the number of dom(N) points, induct directly on the Finset cardinality of `(dom(N).filter (fun z => a.val < z && z <= b.val))`. This avoids reasoning about "smallest dom(N) point above a."

**Revised approach**: Prove by well-founded induction on `(dom(N).filter (fun z => a.val < z /\ z <= b.val)).card`:

```
theorem succ_walks_through_dom_N (N : Nat) (a b : LimitDomSubtype)
    (hab : a <= b)
    (ha_dom : a.val in dom(N))
    (hb_dom : b.val in dom(N))
    (h_succ_dom : forall x : LimitDomSubtype, x.val in dom(N) ->
      a <= x -> x <= b -> (succ x).val in dom(N)) :
    exists k, succ^[k] a = b
```

Base: when the filter is empty, a.val and b.val are the only dom(N) points in [a.val, b.val] with a.val < z <= b.val. If a = b, k = 0. If a < b, the empty filter means no dom(N) point z with a.val < z <= b.val... but b.val is such a point. So the filter is nonempty if a < b. Contradiction with empty. So a = b.

Wait, let me reconsider the filter. Let F = dom(N).filter (fun z => a.val < z /\ z <= b.val). If a < b, then b.val is in F (since b.val is in dom(N) and a.val < b.val <= b.val). So F is nonempty when a < b.

Better base: F.card = 0 implies F is empty, which implies a.val >= b.val (since b.val would be in F if a < b). Combined with a <= b, gives a = b. k = 0.

Step: F.card = m + 1. succ(a).val is in dom(N) (by h_succ_dom applied to a). succ(a) > a. succ(a) <= b (since a < b implies succ(a) <= b). So succ(a).val is in F. Let F' = dom(N).filter (fun z => succ(a).val < z /\ z <= b.val). F' is a strict subset of F (it excludes succ(a).val and possibly others). Actually: F' subset F \ {succ(a).val}, so F'.card <= F.card - 1 = m. Apply IH to (succ(a), b) with F'.

This is cleaner.

**Tasks:**
- [ ] Define the Finset filter `dom_N_between` for dom(N) points strictly between a and b
- [ ] Prove auxiliary: succ(a).val is in dom(N) when a.val is in dom(N) and a.val in [a_orig.val, b.val] (from h_succ_dom)
- [ ] Prove auxiliary: succ(a).val is the smallest dom(N) point > a.val (from the no-limit-dom-between property of succ combined with dom(N) points being limit_dom points)
- [ ] Prove `succ_walks_through_dom_N` by well-founded induction on the filter cardinality

**Timing**: 2-3 hours

**Depends on**: Step 2a

#### Step 2c: Wire up `limitDomSubtype_isSuccArchimedean` (~30-50 lines)

**Location**: ChronicleToCountermodel.lean, replacing lines 1196-1402.

This step combines the pieces:

1. Given a <= b in LimitDomSubtype.
2. Let S = {a.val, b.val} union {succ(x).val : x in limit_dom, x.val in some dom(M), a <= x <= b}.

Actually, this infinite union is problematic. The cleaner approach:

1. Given a <= b.
2. a.val is in dom(M_a) for some M_a (from a.property).
3. b.val is in dom(M_b) for some M_b (from b.property).
4. Let N_0 = max(M_a, M_b). Both a.val and b.val are in dom(N_0).
5. dom(N_0) is a Finset. Let P = dom(N_0).filter (fun z => a.val <= z /\ z <= b.val). P is finite.
6. For each x in P, x is in limit_dom (since x in dom(N_0) implies x in limit_dom). Form the LimitDomSubtype for x. The succ of this LimitDomSubtype has value in dom(M_x) for some M_x.
7. Let N = max(N_0, max over x in P of M_x). Now all points in P are in dom(N), AND for each x in P, succ(x).val is in dom(N).

Wait, step 6-7 is still not enough: succ(x).val is in dom(N), but succ(x).val might not be in [a.val, b.val] (it could be > b.val if x is the last point). Actually, succ(x) <= b when x < b (from succ_le_iff), so succ(x).val <= b.val. And succ(x).val > x.val >= a.val. So succ(x).val is in [a.val, b.val] when x < b. Good.

But the h_succ_dom hypothesis in Step 2b requires that for all LimitDomSubtype x with x.val in dom(N) and a <= x <= b, succ(x).val is in dom(N). The N we chose ensures this for all x with x.val in dom(N_0) (since their succ values are in dom(N)). But dom(N) contains MORE points than dom(N_0) (it is monotone). Some of these new points might have succ values not in dom(N).

**Resolution**: We need a different formulation. Instead of requiring succ(x).val in dom(N) for ALL dom(N) points in [a,b], we can iterate: choose N large enough for all dom(N) points in [a,b]. But this is circular.

**Better approach**: Use the existing `succ_orbit_convex` lemma. The stage-walk does NOT need to walk through ALL dom(N) points -- it only needs to walk through a chain that reaches b. The key is:

1. Choose N large enough that a.val and b.val are in dom(N).
2. Choose N large enough that for the specific dom(N_0) points in [a.val, b.val], their succ values are in dom(N).
3. Apply `succ_walks_through_dom_N` NOT with N but with a carefully chosen Finset that includes a.val, b.val, and all their succ values.

Actually, let me reconsider. The simplest correct approach:

**Correct approach**: The Finset we walk through is dom(N_0) intersected with [a.val, b.val]. Call its elements x_0 = a.val < x_1 < ... < x_m = b.val. For each x_i with i < m, we need succ(x_i as LimitDomSubtype) to be between x_i and x_{i+1} (inclusive). By the succ_le_iff property, succ(x_i) <= x_{i+1} (since x_i < x_{i+1}). And succ(x_i).val > x_i. So succ(x_i).val is in (x_i, x_{i+1}]. If succ(x_i).val = x_{i+1}, then succ steps from x_i to x_{i+1}. If succ(x_i).val < x_{i+1}, then succ(x_i) is a limit_dom point strictly between x_i and x_{i+1} that is NOT in dom(N_0).

In the second case, we need to continue applying succ from succ(x_i) until we reach x_{i+1}. But this is the original problem again -- we do not know how many succ steps it takes.

**The fix**: Choose N large enough that for each consecutive pair (x_i, x_{i+1}) in the sorted dom(N_0) points, succ(x_i as LimitDomSubtype).val = x_{i+1}. This means succ(x_i) IS x_{i+1} in limit_dom.

When is succ(x_i) = x_{i+1}? Recall succ(x_i) = the C5 forward witness for U(T,bot) at x_i, which is the y such that x_i < y, no limit_dom between x_i and y. For succ(x_i) = x_{i+1}, we need no limit_dom point between x_i and x_{i+1}. This is exactly what the bot-guard gives us IF the C5 forward witness for U(T,bot) at x_i was placed between x_i and x_{i+1} at some earlier stage.

But actually, succ(x_i) might be a point BETWEEN x_i and x_{i+1} that was inserted by a LATER counterexample processing. The succ function uses `limit_dom_has_succ` which calls `limit_satisfies_c5_strong`, which finds the C5 forward witness at SOME stage. This witness y is between x_i and SOME ceiling. The ceiling might not be x_{i+1}.

**Critical realization**: succ(x_i) in limit_dom is determined by the LIMIT structure, not by any particular stage. succ(x_i) is the LEAST limit_dom point > x_i. Whether succ(x_i) = x_{i+1} depends on whether there are limit_dom points between x_i and x_{i+1}.

So the question becomes: for consecutive dom(N_0) points (x_i, x_{i+1}), how many limit_dom points are between them? This could be zero (in which case succ(x_i) = x_{i+1}) or infinitely many.

**Revised stage-walk strategy**: We do NOT need succ to jump directly between dom(N) points. Instead, we use the fact that for any x in limit_dom with a <= x < b, succ(x) is strictly greater than x. So succ^[k](a) is a strictly increasing sequence bounded above by b. If this sequence reaches b, we are done. If not, it is an infinite strictly increasing sequence bounded above, which exists in Q. The question is whether it reaches b.

This is the ORIGINAL problem. So the "choose N large enough" approach does not obviously help unless we can guarantee that succ steps align with dom(N) points.

**Key insight (from the delegation context)**: The delegation context suggests proving that for adjacent (a, b) in dom(N) where the C5 for U(T,bot) at a has been processed by stage N, there are no limit_dom points between a and b. This is the crucial structural fact.

Let me trace this more carefully. Consider adjacent dom(N) points x_i < x_{i+1} (no dom(N) point between them). Suppose the C5 forward counterexample for U(T,bot) at x_i was processed at stage M (where M <= N, since we choose N large enough). At stage M, the walk finds a ceiling (the next dom(M) point above x_i). Call this ceiling c_M. The witness y = (x_i + c_M) / 2 (split case, since bot is never in any MCS) or y > max(dom(M)) (base case). In the split case, the bot-guard ensures no limit_dom point between x_i and y. And y < c_M.

Now, c_M might not be x_{i+1}. c_M is the next dom(M) point above x_i. Since dom(M) is a subset of dom(N) (M <= N), x_{i+1} (which is the next dom(N) point above x_i) satisfies x_{i+1} <= c_M (because dom(M) contains at least as many... wait, dom(M) SUBSET dom(N), so dom(N) has MORE points. The next dom(N) point above x_i is x_{i+1}. The next dom(M) point above x_i is c_M, which is >= x_{i+1} because dom(M) has FEWER points than dom(N), so the gap is potentially larger).

Wait, that is backwards. dom(M) SUBSET dom(N) means dom(N) has more points. The next dom(M) point above x_i could be at or beyond x_{i+1}, because dom(M) has fewer points, so gaps are larger. So c_M >= x_{i+1}.

The witness y = (x_i + c_M) / 2. Since c_M >= x_{i+1} and x_i < x_{i+1}, we have y = (x_i + c_M) / 2. If c_M = x_{i+1}, then y = (x_i + x_{i+1}) / 2, which is between x_i and x_{i+1}. If c_M > x_{i+1}, then y = (x_i + c_M) / 2 could be less than, equal to, or greater than x_{i+1}.

Specifically: y < x_{i+1} iff (x_i + c_M) / 2 < x_{i+1} iff c_M < 2 * x_{i+1} - x_i. And y > x_{i+1} iff c_M > 2 * x_{i+1} - x_i.

So the witness y might be above x_{i+1}. In that case, there could be limit_dom points between x_i and x_{i+1} that are NOT the witness y.

**This means the "no limit_dom between x_i and y" property from the bot-guard does NOT immediately give "no limit_dom between x_i and x_{i+1}."**

Hmm, but it gives "no limit_dom between x_i and y," and y > x_i. So succ(x_i) = y in limit_dom. And y is in limit_dom with y > x_i. If y <= x_{i+1}, then succ(x_i) = y is a limit_dom point between x_i and x_{i+1} (or equal to x_{i+1}). If y > x_{i+1}, then y is above x_{i+1}, and succ(x_i) = y > x_{i+1}. But succ(x_i) <= x_{i+1} (since x_i < x_{i+1} implies succ(x_i) <= x_{i+1} by succ_le_iff). Contradiction!

Wait -- succ(x_i) <= x_{i+1} requires x_i < x_{i+1} as LimitDomSubtype elements, which means x_i < x_{i+1} as rationals where both are in limit_dom. And succ_le_iff says succ(a) <= b iff a < b (for LimitDomSubtype). So succ(x_i) <= x_{i+1} when x_i < x_{i+1}. So succ(x_i).val <= x_{i+1}.

And from the bot-guard: no limit_dom point between x_i and succ(x_i).val. And succ(x_i).val <= x_{i+1}. And succ(x_i).val > x_i.

So succ(x_i) is a limit_dom point in (x_i, x_{i+1}]. Good.

Now, is succ(x_i).val in dom(N)? Not necessarily -- it could be a point that entered at a stage > N. But that does not matter for the walk! We do not need succ(x_i) to be in dom(N). We just need to keep applying succ until we reach x_{i+1}.

The question is: starting from x_i, how many succ applications reach x_{i+1}?

**New insight**: succ(x_i) is in (x_i, x_{i+1}]. If succ(x_i) = x_{i+1}, done (1 step). If succ(x_i) < x_{i+1}, then succ(x_i) is a limit_dom point in (x_i, x_{i+1}) that is NOT in dom(N) (since x_i and x_{i+1} are adjacent in dom(N)). Apply succ again: succ(succ(x_i)) is in (succ(x_i), x_{i+1}] (same argument). We get a strictly increasing sequence in (x_i, x_{i+1}).

If this sequence reaches x_{i+1}, great. If not, it is bounded and strictly increasing, hence converges to some limit L <= x_{i+1}. But this is exactly the gap-at-L problem from the convergence approach!

**So the stage-walk approach, as naively formulated, reduces to the same gap problem.**

Let me reconsider the delegation context's approach more carefully. The delegation context says:

> The most promising approach (Option C): prove a standalone lemma about adjacent dom(N) pairs, then iterate.
> Core lemma: For adjacent (a, b) in dom(N), if the C5 counterexample for U(T,bot) at a has been processed by stage N (i.e., a has its immediate successor witness in dom(N)), then succ(a) = (a+b)/2 midpoint is in dom(N), and there are no limit_dom points between a and succ(a). So the succ-orbit from a reaches b by stepping through dom(N) points.

The critical claim here is: "then succ(a) = (a+b)/2 midpoint is in dom(N)." This presupposes that the C5 witness for U(T,bot) at a was processed when the ceiling was b (or something that reduces to the midpoint (a+b)/2 being in dom(N)).

But wait -- the C5 for U(T,bot) at a was processed at some stage M. At that stage, the ceiling c_M was the next dom(M) point above a. Since a is in dom(N) and M <= N (we chose N large enough that the counterexample was processed), and dom(M) is a subset of dom(N), the ceiling c_M is >= the next dom(N) point above a, which is b. So c_M >= b.

The witness y at stage M is: y = (a + c_M) / 2 (split case). y is in dom(M+1) and hence in dom(N) (since M+1 <= N). The bot-guard ensures no limit_dom point between a and y. So succ(a) = y in limit_dom. And succ(a).val = y = (a + c_M) / 2.

Now, succ(a) <= b (since a < b, succ_le_iff gives succ(a) <= b). So y <= b. Combined with y = (a + c_M) / 2, we get (a + c_M) / 2 <= b, so c_M <= 2b - a. And c_M >= b (from above). So b <= c_M <= 2b - a.

The witness y = (a + c_M) / 2 is in [a, b] (since y > a and y <= b). And y is in dom(N) (since y entered at stage M+1 <= N).

Now, the interval (a, b) in dom(N): we had no dom(N) points strictly between a and b (they are adjacent in dom(N)). But y = (a + c_M)/2 is in dom(M+1) which is a subset of dom(N). And a < y <= b. If y < b, then y is a dom(N) point strictly between a and b. But we assumed a and b are adjacent in dom(N). Contradiction! Unless y = b.

Wait, but y entered at stage M+1, which is <= N. So y IS in dom(N). And a < y <= b. If y < b, then y is in dom(N) with a < y < b, contradicting adjacency of a and b in dom(N). So y = b. Therefore succ(a) = b for adjacent dom(N) points!

**THIS IS THE KEY ARGUMENT.** When a and b are adjacent in dom(N) and the C5-bot at a was processed at stage M <= N:
- The witness y enters at stage M+1 <= N, so y is in dom(N)
- a < y <= b (from bot-guard + succ_le_iff)
- y in dom(N) with a < y contradicts adjacency unless y = b
- Therefore succ(a) = b

This means: for adjacent dom(N) points, if the C5-bot counterexample at the lower point was processed by stage N, then succ maps the lower point directly to the upper point. And walking through all adjacent pairs from a to b gives succ^[m](a) = b where m = number of dom(N) points in (a.val, b.val] intersected with [a.val, b.val].

**Revised formulation of the core lemma:**

```
-- For adjacent dom(N) points a_val < b_val, if the C5 forward counterexample
-- for U(T,bot) at a_val was processed at some stage M < N, then succ(a) = b
-- in LimitDomSubtype, where a and b are the corresponding LimitDomSubtype elements.
theorem adj_dom_N_succ_eq (N : Nat) (a_val b_val : Rat)
    (ha : a_val in dom(N)) (hb : b_val in dom(N))
    (h_adj : Adjacent dom(N) a_val b_val)  -- no dom(N) point between a_val and b_val
    (h_resolved : exists M < N, counterexample_enum(M).2 = (a_val, 0, bot, top, c5_forward)
                   and a_val in dom(M)) :
    succ(a_as_LimitDomSubtype) = b_as_LimitDomSubtype
```

Wait, the condition h_resolved needs more care. What we need is: the C5 counterexample for U(T,bot) at a_val was the counterexample processed at some step M, and M was < N (so the witness enters at M+1 <= N, hence in dom(N)).

Actually, looking at the construction more carefully: `counterexample_enum (Nat.unpair n).2` is the counterexample processed at omega-chain step n. The processing happens at step n, producing dom(n+1) from dom(n). The witness enters dom(n+1).

So what we need is: there exists n such that `counterexample_enum (Nat.unpair n).2 = {x := a_val, i := 0, xi := bot, eta := top, kind := c5_forward}` and a_val is in dom(n), and n+1 <= N. This ensures the witness y from stage n+1 is in dom(n+1) subset dom(N).

From `counterexample_enum_surjective_above`, for any PotentialCounterexample pc and any k, there exists n >= k with counterexample_enum (Nat.unpair n).2 = pc. So for pc = {a_val, 0, bot, top, c5_forward}, there exists n >= max(stages of all a_val entries) such that the counterexample is processed.

For the "choose N" step: we need N large enough that for every dom(N_0) point x in [a.val, b.val], the C5-bot counterexample at x has been processed by stage N-1 (so the witness is in dom(N)). Specifically: for each x in dom(N_0) intersect [a, b], let n_x be the stage at which the C5-bot counterexample at x is processed (from `counterexample_enum_surjective`). Let N = 1 + max(n_x : x in dom(N_0) intersect [a,b]). Then for each x, the witness enters at n_x + 1 <= N, hence in dom(N).

But dom(N) might have MORE points in [a, b] than dom(N_0), since we increased N. These new points also need their C5-bot counterexamples resolved. This is circular.

**Resolution**: Process in rounds. Or better: use `counterexample_enum_surjective_above` with a sufficiently large starting index.

Actually, the correct fix is simpler. We do not need to resolve C5-bot at ALL dom(N) points -- only at the dom(N_0) points, because the key lemma only uses adjacency in dom(N) for the ORIGINAL dom(N_0) points. Let me re-examine.

The walk goes: a = x_0 -> x_1 -> x_2 -> ... -> x_m = b, where x_0 < x_1 < ... < x_m are ALL the dom(N_0) points in [a, b]. We need succ(x_i) = x_{i+1} for each i. The key lemma requires x_i and x_{i+1} to be ADJACENT in dom(N) (the LARGER stage). But dom(N) might have points between x_i and x_{i+1} that were not in dom(N_0).

However, the key argument above shows: the C5-bot witness y at x_i (processed at stage n_i) enters at n_i + 1 and is in dom(n_i + 1) subset dom(N). This y satisfies a < y, succ_le gives y <= x_{i+1}, and y > x_i. If y were strictly between x_i and x_{i+1} in dom(N), it would violate adjacency of x_i and x_{i+1} in dom(N). But x_i and x_{i+1} might NOT be adjacent in dom(N)! They were adjacent in dom(N_0), but dom(N) could have more points between them.

So we need a different argument. The correct argument is:

1. The C5-bot witness y for U(T,bot) at x_i enters at stage n_i + 1. The bot-guard ensures NO limit_dom point between x_i and y. So succ(x_i) = y in limit_dom.
2. y is in dom(n_i + 1). So y is in limit_dom with y > x_i and no limit_dom between x_i and y.
3. succ(x_i) = y. And succ(x_i) <= x_{i+1} (since x_i < x_{i+1}).
4. So y <= x_{i+1}. And y > x_i. y is in dom(n_i + 1).
5. Now consider succ(y). succ(y) <= x_{i+1} iff y < x_{i+1} (from succ_le_iff). If y = x_{i+1}, we reached x_{i+1} in 1 step. If y < x_{i+1}, succ(y) <= x_{i+1} and succ(y) > y.

But what is succ(y)? We need the C5-bot counterexample at y to be resolved. y is in dom(n_i + 1). The C5-bot at y might not have been processed yet at any stage <= N.

**The fundamental issue**: to walk from x_i to x_{i+1} via succ, we need every intermediate limit_dom point to have its C5-bot resolved, which requires resolving an a priori unknown number of counterexamples.

**The correct approach (from the delegation context)**: Choose N large enough that ALL C5-bot counterexamples at ALL dom(N_0) points in [a, b] are resolved by stage N. Then:
- The C5-bot witness y_i for x_i enters at some stage <= N. Bot-guard: no limit_dom between x_i and y_i. succ(x_i) = y_i.
- y_i is in dom(N). y_i in (x_i, x_{i+1}].
- If y_i = x_{i+1}, done for this pair.
- If y_i < x_{i+1}: y_i is in dom(N) intersect (x_i, x_{i+1}). But x_i, x_{i+1} are adjacent in dom(N_0), and y_i is in dom(N) but not dom(N_0).
  - Now y_i is a dom(N) point between x_i and x_{i+1}. Was the C5-bot at y_i resolved by stage N? Not necessarily -- we only resolved C5-bot for dom(N_0) points.
  - To resolve for y_i too, we need to choose N even larger. But then dom(N) gets more points, potentially creating more intermediate points...

**Breaking the circularity**: The key observation is that dom(N) is a FINSET. Its cardinality is at most N + 1 (since at most one new point per stage). So dom(N) intersect [a, b] is finite, say of cardinality K. If we resolve C5-bot for all K points, we get at most K new witnesses, each between consecutive dom(N) pairs. These witnesses are in dom(N + K) or so. Then dom(N + K) has at most K more points in [a, b]...

This doesn't converge in finitely many steps unless we can show the process terminates.

**Correct approach (truly)**: We need a SINGLE N that resolves everything simultaneously. Use the following argument:

For a, b in limit_dom with a <= b, define the set S = limit_dom intersect [a.val, b.val]. We want to show S is finite (this would give LocallyFiniteOrder, which gives IsSuccArchimedean). But this is the approach the plan says is non-goal.

Actually, let me re-read the delegation context more carefully. It says:

> Pick N large enough that both a.val and b.val are in dom(N), AND all C5 counterexamples for U(T,bot) at every dom(N) point between a and b have been processed.

So the requirement is that for every point x in dom(N) intersect [a, b], the C5-bot at x is resolved by stage N. This is a fixed-point condition on N.

Can we find such N? Yes, by a simple iterative argument:
- Let N_0 be such that a, b are in dom(N_0).
- dom(N_0) intersect [a, b] is a finite set, say {x_0, ..., x_k}.
- For each x_i, the C5-bot counterexample at x_i is processed at some stage n_i (from counterexample_enum_surjective). Let N_1 = max(n_i + 1) over all i.
- Now all x_0, ..., x_k have their C5-bot resolved by stage N_1. But dom(N_1) might have new points in [a, b].
- dom(N_1) intersect [a, b] has at most k + (N_1 - N_0) more points (at most one new point per stage).
- For each new point y_j, find its C5-bot resolution stage m_j. Let N_2 = max(m_j + 1).
- Repeat.
- This process terminates because: at each round, we resolve C5-bot for all current dom points in [a,b]. The C5-bot witness for x enters at the resolution stage. The GUARD ensures no new limit_dom points between x and its witness. So the witness does not create new limit_dom points between consecutive dom points of the PREVIOUS round; it only creates new dom points that are between x and its WITNESS.

Actually, this might NOT terminate. Each new witness creates a new dom point, which needs its own C5-bot resolution, which creates another witness...

**The termination argument**: At each stage, at most one new point is added. The number of C5-bot counterexamples is countable, and each is eventually processed. But we need a SINGLE N that resolves all at once.

**Key insight I missed**: The C5-bot witness y for U(T,bot) at x is the value succ(x) in limit_dom. And the bot-guard ensures no limit_dom between x and y. So once y enters the domain, no future stage can insert a point between x and y. This means the succ function is "stable" -- succ(x) is determined once the C5-bot at x is processed, and no future processing changes it.

So: choose N large enough. For x_i in dom(N) intersect [a, b], succ(x_i) = y_i where y_i entered at some earlier stage. y_i is in dom(N) (if the C5-bot at x_i was processed before stage N). y_i is between x_i and x_{i+1} (or equal to x_{i+1}).

If y_i < x_{i+1}, then y_i is a dom(N) point between x_i and x_{i+1} that we ALSO need resolved. We need succ(y_i) determined, i.e., C5-bot at y_i processed.

The process: take dom(N) intersect [a,b] sorted as z_0 < z_1 < ... < z_p. For each z_j, if C5-bot at z_j is resolved by stage N, then succ(z_j) is the C5-bot witness, which is between z_j and z_{j+1}. And succ(z_j) is in dom(N). But wait -- succ(z_j) must be some z_k with k > j (since succ(z_j) is in limit_dom with z_j < succ(z_j), and z_0 < ... < z_p are ALL dom(N) points in [a,b], and succ(z_j) is in dom(N) and in [a,b]). So succ(z_j) = z_{j'} for some j' > j.

And since succ is the LEAST limit_dom point > z_j (no limit_dom between z_j and succ(z_j)), and z_{j+1} is a dom(N) point > z_j that is in limit_dom, we get succ(z_j) <= z_{j+1}. So j' = j + 1 and succ(z_j) = z_{j+1}.

Wait, that's exactly what we need! Let me verify: succ(z_j) is the least limit_dom point > z_j. z_{j+1} is a limit_dom point > z_j (since z_{j+1} is in dom(N) subset limit_dom). So succ(z_j) <= z_{j+1}. And succ(z_j) is in limit_dom, hence succ(z_j) = z_k for some k (succ(z_j) is in limit_dom, but it might not be in dom(N)). No wait -- succ(z_j) is in limit_dom but might not be in dom(N). So succ(z_j) could be a limit_dom point between z_j and z_{j+1} that is NOT in dom(N).

But we proved: when C5-bot at z_j is resolved by stage N (witness enters at stage M+1 <= N), the witness y is in dom(M+1) subset dom(N), and no limit_dom between z_j and y. So succ(z_j) = y, and y is in dom(N). So succ(z_j) is in dom(N). And succ(z_j) > z_j and succ(z_j) <= z_{j+1}. Since z_j and z_{j+1} are consecutive in dom(N) intersect [a,b], and succ(z_j) is in dom(N) intersect [z_j, z_{j+1}], succ(z_j) must be either z_j (impossible, succ > z_j) or z_{j+1}. So succ(z_j) = z_{j+1}!

**THIS IS THE COMPLETE ARGUMENT.** The circularity is broken because:
1. We choose N large enough that for every z in dom(N) intersect [a,b], the C5-bot at z was processed by stage N-1 (so the witness is in dom(N)).
2. For such N, every consecutive pair in dom(N) intersect [a,b] satisfies succ(z_j) = z_{j+1}.
3. Iterating succ p times gives succ^[p](a) = b.

The remaining question: does such N exist? We need: for every z in dom(N) intersect [a,b], the C5-bot at z was processed by some stage < N.

**Potential circularity**: N determines dom(N), which determines which points need C5-bot resolution, which determines the required N. But this IS solvable:

Consider the function h(N) = "set of dom(N) points in [a,b] whose C5-bot has NOT been processed by stage N-1." We need h(N) = empty.

At any stage N, dom(N) has finitely many points in [a,b]. As N grows, each point's C5-bot is eventually processed (counterexample_enum_surjective). So h(N) eventually becomes empty? Not obviously -- new points enter dom(N) as N grows, and their C5-bot might not be processed yet.

However, each stage adds at most one new point to the domain. And processing a C5-bot counterexample at some point adds the witness to the domain (1 new point). The processing itself happens at the stage when counterexample_enum selects that counterexample.

**Termination by finiteness**: Consider the process:
- At stage N, there are at most N+1 points in dom(N) (at most 1 new per stage, starting from dom(0) = {0}).
- Each point z in dom(N) has a C5-bot counterexample that is processed at some stage m_z (exists by counterexample_enum_surjective).
- The witness enters at stage m_z + 1.
- We need m_z + 1 <= N for all z in dom(N) intersect [a,b].
- As N grows, new points enter, but they eventually get resolved too.

This is a well-ordering argument: the set of stages at which C5-bot counterexamples are processed is cofinal in N, and each unresolved point in dom(N) eventually gets resolved. By induction, there exists N where all are resolved simultaneously.

**Formal argument**: Let N_0 be such that a, b are in dom(N_0). dom(N_0) intersect [a,b] is finite, say cardinality k_0. For each point z in this finite set, counterexample_enum_surjective gives a stage n_z for the C5-bot at z. But we need n_z to be at least N_0 (so z is in dom(n_z)). Use counterexample_enum_surjective_above with lower bound N_0: there exists n_z >= N_0 with the right counterexample. And z is in dom(n_z) since dom is monotone and z is in dom(N_0) subset dom(n_z).

Wait -- the issue is that `counterexample_enum_surjective_above` gives a stage n_z where the counterexample (z, 0, bot, top, c5_forward) is the counterexample processed at step n_z. But it also requires z to be in dom(n_z), which follows from monotonicity since z is in dom(N_0) and n_z >= N_0.

Let N_1 = 1 + max(n_z : z in dom(N_0) intersect [a,b]). Then for each z in dom(N_0) intersect [a,b], the C5-bot witness enters at n_z + 1 <= N_1, hence in dom(N_1).

Now dom(N_1) might have new points in [a,b]. Let S_1 = dom(N_1) intersect [a,b] \ dom(N_0) intersect [a,b]. S_1 has at most N_1 - N_0 elements.

For each z in S_1, z entered at some stage between N_0+1 and N_1. The C5-bot at z is processed at some stage n_z (using counterexample_enum_surjective_above with lower bound >= stage where z entered).

Let N_2 = 1 + max(n_z : z in S_1). Then for each z in S_1, the C5-bot witness enters at n_z + 1 <= N_2.

Now dom(N_2) might have STILL more points. But each round adds finitely many points, and each round resolves all previous points. Does this terminate?

Each round i adds at most N_i - N_{i-1} new points. And N_i is determined by the max of the counterexample processing stages for these points. The processing stages come from counterexample_enum, which is a bijection N -> PotentialCounterexample. The stages n_z could be arbitrarily large.

So the iterated process might not terminate in finitely many rounds. We need a different approach.

**Correct approach using well-ordering**: Since the natural numbers are well-ordered and each C5-bot counterexample is eventually processed, we can use the following:

Define: N_good(a, b) = the smallest N such that for all z in dom(N) intersect [a.val, b.val], the C5-bot at z was processed at some stage < N.

Claim: N_good exists. Proof: Consider any N. The set of "unresolved" dom(N) points in [a,b] is finite (subset of dom(N) which is a Finset). If it is empty, N works. If nonempty, each unresolved point z will be processed at some future stage n_z. After all these stages, the new points introduced might also need resolution. But the KEY POINT is: the C5-bot witness for z enters at stage n_z + 1, and the bot-guard ensures no NEW limit_dom points between z and its witness. The witness is a single new point. So resolving the C5-bot at z adds at most 1 new point to the domain.

But this new point might need C5-bot resolution too, adding another point, etc. In the worst case, we have an infinite chain of resolutions. Does the process terminate?

YES, because each resolution stage n_z is paired with a unique counterexample (z, 0, bot, top, c5_forward). The set of points z in limit_dom intersect [a, b] with U(T, bot) in limit_f(z) is NOT necessarily finite. So the process of resolving all of them might require infinitely many stages.

However, we do not need ALL limit_dom points resolved -- only all dom(N) points. And the N we choose determines which points need resolution.

**THE CORRECT ARGUMENT (simplest version)**:

Avoid the iteration entirely. Instead, use the following direct approach:

For a <= b in LimitDomSubtype, consider the set

  T = { z in Q : z in limit_dom, a.val <= z, z <= b.val }

We want to show succ^[k](a) = b for some k. By succ_orbit_convex, it suffices to show succ^[k](a) >= b for some k.

**Direct induction on the number of dom(N) points in (a.val, b.val] for a FIXED well-chosen N:**

Choose N as follows:
1. Let M_a, M_b be stages where a.val, b.val enter the domain.
2. For each PotentialCounterexample of the form (x, 0, bot, top, c5_forward) where x is rational, counterexample_enum_surjective gives a unique stage. But we only need the ones where x is in dom(N) intersect [a, b].
3. Since we want a non-circular choice: USE ANY N >= max(M_a, M_b). Then a.val, b.val are in dom(N). The walk argument works AS FOLLOWS:

The walk from a to b goes through dom(N) points: a.val = z_0 < z_1 < ... < z_p = b.val (the dom(N) intersect [a,b] sorted). For each consecutive pair (z_j, z_{j+1}), we show succ^[k_j](z_j-sub) = z_{j+1}-sub. Then succ^[sum k_j](a) = b.

For the pair (z_j, z_{j+1}): they are adjacent in dom(N). We need to show succ reaches from z_j to z_{j+1} in finitely many steps.

succ(z_j-sub) in limit_dom. No limit_dom between z_j and succ(z_j) (by definition of succ as least limit_dom > z_j). succ(z_j-sub) <= z_{j+1}-sub (since z_j < z_{j+1} and succ_le_iff).

So succ(z_j-sub) is in (z_j, z_{j+1}]. If = z_{j+1}, done in 1 step. If < z_{j+1}, apply succ again. This creates a strictly increasing sequence in (z_j, z_{j+1}] which must reach z_{j+1} eventually... but we cannot prove this without additional argument.

**THIS IS THE ORIGINAL PROBLEM. The "choose N" approach alone does not solve it.**

Let me reconsider. The correct version of the stage-walk, as outlined in the delegation context, DOES require that the C5-bot at z_j was processed by stage N, so that the witness is in dom(N) and hence succ(z_j) = z_{j+1} by the adjacency argument.

The non-circularity argument:

**Claim**: There exists N such that for all z in dom(N) intersect [a.val, b.val], the C5-bot counterexample at z was processed at some stage < N.

**Proof by contradiction**: Suppose no such N exists. Then for each N, there is some z_N in dom(N) intersect [a,b] whose C5-bot was not processed by stage N-1.

Since dom(N) intersect [a,b] is finite for each N, and the sequence of z_N values lives in the bounded interval [a,b], by Ramsey/pigeonhole, some z appears as z_N for infinitely many N. But this is impossible: z is in dom(N) for all large enough N, and the C5-bot at z is processed at some fixed stage m_z (from counterexample_enum_surjective). For N > m_z + 1, z's C5-bot is resolved. Contradiction.

Wait, this argument has a gap: z_N might be a DIFFERENT point for each N. As N grows, new points enter dom(N). So z_N could be a fresh point each time.

But: z_N is in dom(N) intersect [a,b]. And z_N's C5-bot is not processed by stage N-1. By counterexample_enum_surjective, z_N's C5-bot IS processed at some stage m_{z_N}. Since z_N is in dom(N), z_N entered at some stage <= N. The C5-bot at z_N is processed at stage m_{z_N} > N-1, so m_{z_N} >= N.

Now: z_N entered at stage s_N <= N. And its C5-bot is processed at stage m_{z_N} >= N. For each N, we get a point z_N in [a,b] that entered at stage <= N and whose C5-bot is processed at stage >= N.

As N -> infinity, s_N <= N and m_{z_N} >= N. The point z_N could be different each time. This does not immediately give a contradiction.

**But**: the number of points in dom(N) intersect [a,b] is at most N+1 (since |dom(N)| <= N+1). And the stages m_{z_N} are all distinct (each counterexample_enum output is used at most once). Actually, different z_N values give different counterexamples (z_N, 0, bot, top, c5_forward), and these are processed at different stages.

Hmm, this is getting complicated. Let me try a DIFFERENT approach to showing N exists.

**Correct simple proof that N exists**:

Define f : N -> N by f(n) = n + 1 if there exists z in dom(n+1) intersect [a,b] \ dom(n) whose C5-bot counterexample has not been processed by stage n, and f(n) = n otherwise.

No, this is too ad hoc.

**Simplest correct approach**: Directly construct N.

1. a.val in dom(M_a), b.val in dom(M_b). Let N_0 = max(M_a, M_b).
2. dom(N_0) intersect [a,b] is a finite set S_0 of cardinality <= N_0 + 1.
3. For each z in S_0, by counterexample_enum_surjective_above with k = N_0, there exists n_z >= N_0 with counterexample_enum (Nat.unpair n_z).2 = (z, 0, bot, top, c5_forward). The C5-bot witness for z enters at n_z + 1.
4. Let N_1 = max(n_z + 1 : z in S_0). All z in S_0 have their C5-bot processed by stage N_1 - 1, witness in dom(N_1).
5. dom(N_1) might have new points in [a,b]. Let S_1 = dom(N_1) intersect [a,b] \ S_0. |S_1| <= N_1 - N_0.
6. For each z in S_1, similarly find n_z and let N_2 = max(n_z + 1 : z in S_1).
7. Continue. At round i, |S_i| <= N_i - N_{i-1}. The total number of points in dom(N_i) intersect [a,b] is sum |S_j| for j=0..i.

DOES THIS TERMINATE? At each round, the new points S_i might require C5-bot processing at stages much later than N_i, causing N_{i+1} >> N_i, which adds many more new points. In the worst case, each round doubles the number of new points.

**Key fact**: Each new point added to the domain is the C5-bot witness for some EARLIER point. The C5-bot witness for z is a SPECIFIC point y (determined by the construction at the processing stage). This y is in dom(n_z + 1). The witness y satisfies: no limit_dom between z and y (bot-guard). So y is the immediate successor of z in limit_dom. This means y does not "interfere" with other pairs -- y is between z and the ceiling at stage n_z.

But y might be a NEW point in [a, b] that needs its own C5-bot resolution. When is y's C5-bot resolved? At some stage m_y. The witness for y's C5-bot is some y' between y and y's ceiling. And so on.

In the absolute worst case, this creates an infinite chain: z -> y -> y' -> ... within [a, b]. Each step adds one point. But [a, b] intersect limit_dom could be infinite.

HOWEVER: at each step, the new witness is BETWEEN the current point and its ceiling. The ceiling is some domain point above the current point. And the witness = (current + ceiling) / 2. So the values form a sequence z < y < y' < ... approaching the ceiling from below. This is a convergent sequence, and its limit is in [a, b] intersect R. But limit_dom is a subset of Q, and the sequence is rational.

The convergence of this sequence is exactly the "gap-at-L" scenario from the convergence approach! So the iterative resolution DOES NOT terminate in general (at the level of this abstract argument).

**CONCLUSION**: The naive "choose N" approach has a genuine circularity/non-termination issue. The stage-walk as described in the delegation context is NOT trivially correct.

**HOWEVER**: The delegation context's approach CAN be fixed. The fix is to avoid iterating to resolve ALL dom(N) points, and instead use the orbit convexity trick from plan v8.

**REVISED CORRECT APPROACH**:

Combine the stage-walk with orbit convexity. Here is the argument:

For a <= b in LimitDomSubtype:
1. Choose N such that a.val and b.val are in dom(N).
2. dom(N) intersect [a.val, b.val] = {z_0 < z_1 < ... < z_p} with z_0 = a.val and z_p = b.val.
3. For each j, succ(z_j) <= z_{j+1} (from succ_le_iff, since z_j < z_{j+1}).
4. succ(z_j) > z_j. So succ(z_j) is in (z_j, z_{j+1}].
5. If succ(z_j) = z_{j+1} for all j, then succ^[p](a) = b. Done.
6. If succ(z_j) < z_{j+1} for some j: succ(z_j) is a limit_dom point in (z_j, z_{j+1}), not in dom(N). Choose N' >= N such that succ(z_j).val is in dom(N'). dom(N') intersect [z_j, z_{j+1}] now has more points. This refines the walk.

But we still need to show the refinement terminates.

**THE ACTUAL CORRECT APPROACH (plan v8's idea, fixed):**

Use well-founded induction on N (not first_stage of individual points, but the stage parameter). The statement:

For all N, for all a b : LimitDomSubtype with a.val in dom(N) and b.val in dom(N) and a <= b, there exists k such that succ^[k](a) = b.

Induction on N:

Base N = 0: dom(0) = {0}. So a.val = b.val = 0. a = b. k = 0.

Step N -> N+1: Given a <= b with a.val in dom(N+1) and b.val in dom(N+1).

Case 1: a.val in dom(N) and b.val in dom(N). By IH, done.

Case 2: a.val in dom(N+1) \ dom(N) (a is the new point at stage N+1). b.val in dom(N+1).
- a.val entered at stage N+1. By omega_chain_dom_new_unique, a.val is the UNIQUE new point.
- The new point a.val was inserted by some counterexample elimination at stage N.
- Case 2a: a.val was a C5 forward witness. Then there exists pt in dom(N) with pt < a.val and no limit_dom between pt and a.val (bot-guard for U(T,bot)). So pred(a) in limit_dom has value pt (if pt is the point protected by the guard).
  - Actually, the guard protects (pt, a.val) interval: no limit_dom between pt and a.val. So succ(pt-sub) = a. Since pt is in dom(N), and b is in dom(N+1):
  - If b.val in dom(N): by IH, succ^[m](pt-sub) = b. By orbit convexity (pt <= a <= b), succ^[j](pt-sub) = a for some j. Then succ^[m-j](a) = b.
  - If b.val not in dom(N): b.val = a.val (unique new point). a = b. k = 0.
- Case 2b: a.val was a C5 backward witness. Then there exists pt in dom(N) with a.val < pt and no limit_dom between a.val and pt. So succ(a) = pt-sub. pt is in dom(N).
  - If b.val in dom(N): succ(a) = pt-sub. pt <= b (since a < pt and succ(a) <= b when a < b... wait, pt = succ(a), and a < b, so succ(a) <= b, so pt <= b). By IH on (pt-sub, b) with both in dom(N): succ^[m](pt-sub) = b. Then succ^[m+1](a) = b.
  - If b.val not in dom(N): b.val = a.val (unique new point). a = b. k = 0.
- Case 2c: a.val was a C4 witness. Then a.val was inserted between two dom(N) points w, w_next. C4 witnesses do NOT have the bot-guard. So succ(a) might not be w_next. This case needs separate handling.
  - However, C4 witnesses are for density counterexamples, and the guard formula is not bot. But in the DISCRETE case (h_discrete), every point has U(T,bot) in limit_f. So the C5-bot at a will be eventually processed, giving a forward witness y > a with bot-guard. But this processing happens at a later stage, not stage N+1.
  - Alternative: we don't need to know HOW a entered. We just need succ(a) or pred(a) to be in dom(N).
  - In the discrete case, succ(a) exists and is the C5 forward witness for U(T,bot) at a. This witness entered at the stage when C5-bot at a was processed. If that stage is > N+1, succ(a) is not in dom(N+1).
  - For C4 witnesses: a.val was placed at (w + w_next) / 2. The guard for C4 is not bot, so there might be limit_dom points between w and a (or between a and w_next) in the limit. succ(a) is the C5-bot witness for a, entered at some future stage.
  - Since succ(a) might not be in dom(N+1) or dom(N), the IH does not directly apply.

**Case 2c is problematic.** However:

For C4 witnesses: a is placed between w and w_next in dom(N). w and w_next are in dom(N). By IH, succ^[m](w-sub) = w_next-sub. By orbit convexity (w <= a <= w_next), succ^[j](w-sub) = a for some j <= m. Then succ^[m-j](a) = w_next.

Wait -- orbit convexity requires w <= a <= succ^[m](w-sub) = w_next. And a is in limit_dom with w <= a <= w_next. So by orbit convexity, succ^[j](w-sub) = a for some j. Then succ^[m-j](a) = w_next.

Now, from a: succ^[m-j](a) = w_next. And if b.val in dom(N), succ^[r](w_next-sub) = b by IH. So succ^[m-j+r](a) = b.

If b.val not in dom(N), then b = a (unique new point), k = 0.

So Case 2c IS handled by orbit convexity! The key: we don't need to know what succ(a) is. We just need to know that a is between two dom(N) points w and w_next, and apply IH on (w, w_next) plus orbit convexity to factor through a.

But wait: for C4 witnesses, IS a between two dom(N) points? Yes: C4 witness a is placed at (w + w_next) / 2 where w, w_next are adjacent in dom(N).

For C5 forward witnesses: a is placed at (pt + ceiling) / 2 where pt, ceiling are in dom(N). So a is between pt and ceiling, both in dom(N).

For C5 backward witnesses: a is placed at (pt + floor) / 2 where floor, pt are in dom(N). So a is between floor and pt, both in dom(N).

For C5 base case (beyond-max): a is placed beyond max(dom(N)). In this case, there is NO dom(N) point above a. We need separate handling.

**Case 2d: a was placed beyond max(dom(N))**:
- a.val > max(dom(N)).val.
- If b.val in dom(N): b.val <= max(dom(N)).val < a.val. But a <= b means a.val <= b.val. Contradiction. So this case is impossible when b is in dom(N) and a.val is the new beyond-max point.
- If b.val not in dom(N): b = a (unique new point). k = 0.

Actually wait -- if a was placed beyond max(dom(N)), then a.val > all dom(N) points. Since b.val is in dom(N+1), either b.val is in dom(N) (in which case b.val <= max(dom(N)) < a.val, contradicting a <= b) or b.val = a.val (unique new point, a = b). So this case forces a = b.

Similarly for C5 backward base case (below min): a.val < min(dom(N)). If b.val in dom(N), then b.val >= min(dom(N)) > a.val, so a < b. Then we need to reach b from a. But a is below all dom(N) points. The point min(dom(N)) is in dom(N) with min(dom(N)) > a. For C5 backward, the guard protects (a, pt) where pt is the point whose S(T,bot) counterexample was processed. So succ(a) = pt in limit_dom (no limit_dom between a and pt). pt is in dom(N). Now apply IH: succ^[m](pt-sub) = b (both in dom(N)). Then succ^[m+1](a) = b.

Wait -- actually for C5 backward, the witness a is placed BELOW pt. The guard is between a and pt. So the backward processing protects interval (a, pt): no limit_dom between. succ(a) = pt. And pt is in dom(N). Good.

For C5 backward base case (below min of dom(N)): similar argument. The point a is below all dom(N) points, but succ(a) is in dom(N) (the point pt from the backward walk). Then use IH.

**Case 3: b.val in dom(N+1) \ dom(N) (b is the new point at stage N+1). a.val in dom(N+1).**

By omega_chain_dom_new_unique, b.val is the unique new point at stage N+1. So either a.val = b.val (a = b, k = 0) or a.val in dom(N).

If a.val in dom(N): a.val < b.val (since a < b). b was inserted between two dom(N) points or beyond max.

- b between w and w_next in dom(N): By IH, succ^[m](a-sub) = w_next-sub (both in dom(N)). But we need succ^[k](a) = b, not w_next. By orbit convexity: w <= b <= w_next, and succ^[m'](w-sub) = w_next. Then succ^[j](w-sub) = b for some j. But we need to connect a to b, not w to b.

Hmm, orbit convexity gives: if a <= b <= succ^[m](a) for some m, then succ^[j](a) = b for some j <= m. So we need succ^[m](a) >= b for some m. Since b < w_next (b is between w and w_next, b < w_next since b is a midpoint), and succ^[m](a) = w_next > b, we get succ^[m](a) >= b. By orbit convexity, succ^[j](a) = b.

Wait: succ^[m](a-sub) = w_next-sub. And a <= b (given). And b <= w_next (since b is between w and w_next). So a <= b <= succ^[m](a) = w_next. By orbit convexity, succ^[j](a) = b for some j <= m.

This works! The key: b is between two dom(N) points, and the IH gives us the ability to reach the upper dom(N) point from a. Orbit convexity factors through b.

- b beyond max(dom(N)): b.val > max(dom(N)). a.val in dom(N) so a.val <= max(dom(N)). a <= b means a.val <= b.val. Need succ^[k](a) = b. The IH gives succ^[m](a) = max(dom(N))-sub (if a < max(dom(N))) or a = max(dom(N))-sub (if a.val = max(dom(N))). From max(dom(N))-sub, succ(max(dom(N))-sub) could be b (if no limit_dom between max(dom(N)) and b). This happens when b's guard protects (max(dom(N)), b): for C5 forward base case, the walk protects the interval, so succ(max-sub) = b. Then succ^[m+1](a) = b. For C5 backward base case at max(dom(N)): b is placed below max, not above. So this is C5 forward or C5/C4 at max(dom(N)).

Actually, if b is placed beyond max by a C5 forward walk at max(dom(N)):
  - The walk found max as the largest dom(N) point. Used base case: y = fresh rational > max. Guard protects (max, y): no limit_dom between. succ(max-sub) = y = b. From a: IH gives succ^[m](a) = max. Then succ^[m+1](a) = b.

What if b is placed beyond max by a C5 forward walk at some OTHER point? The C5 forward walk starts at the counterexample point pt, walks up to the ceiling, and if pt is the max, uses base case. If pt is not the max, the walk splits and the witness is between pt and ceiling (not beyond max). So the beyond-max case only happens when pt = max(dom(N)).

What about C5 backward placing b beyond max? C5 backward places the witness BELOW pt, not above. So beyond-max from C5 backward is impossible.

C4 forward: places witness between two existing points, not beyond max.

So beyond-max only happens for C5 forward at max(dom(N)). And succ(max) = b in that case.

What about b placed BELOW min(dom(N)) (C5 backward base case)?
  - b < min(dom(N)). Since a is in dom(N), a >= min(dom(N)) > b. But a <= b, contradiction. Impossible.

**Summary of the induction on N:**

The induction on N with statement "for all a, b in LimitDomSubtype with a.val, b.val in dom(N) and a <= b, succ^[k](a) = b" works by case analysis on whether a and b are in dom(N) or are the unique new point at stage N+1. In all cases:

- If both in dom(N): IH.
- If one is new (entered at N+1):
  - New point is between two dom(N) points (w, w_next): IH gives succ reaches w_next from a (or from succ(a) = pt). Orbit convexity gives the exact hitting time for the new point.
  - New point is beyond max or below min: special cases handled by guard properties and the fact that a <= b constrains the geometry.
- If both are new: a = b (unique new point).

This is the approach from plan v8's Step 2c (lines 297-397 in plan v8), but with the critical fix: use orbit convexity for ALL cases (not just the forward/backward case), and avoid the problematic claim about first_stage(pred(c)).

**Timing**: 2-3 hours

**Depends on**: Step 2a

**Tasks:**
- [ ] Prove `succ_reaches_dom_N` by induction on N: for all a b with a.val, b.val in dom(N) and a <= b, exists k, succ^[k](a) = b
- [ ] Handle base case N = 0: dom(0) = {0}, a = b, k = 0
- [ ] Handle inductive step: case split on whether a.val, b.val are in dom(N) or dom(N+1) \ dom(N)
- [ ] For "a new" case: identify the dom(N) points that bracket a, apply IH + orbit convexity
- [ ] For "b new" case: identify the dom(N) points that bracket b, apply IH + orbit convexity
- [ ] For "both new" case: omega_chain_dom_new_unique gives a = b

#### Step 2c: Wire up `limitDomSubtype_isSuccArchimedean` (~20-30 lines)

**Location**: ChronicleToCountermodel.lean, replacing lines 1196-1402.

Replace the entire `by` block with:

```lean
@IsSuccArchimedean.mk _ _ (limitDomSubtype_succOrder A h_mcs h_discrete) <| by
  intro a b hab
  change exists n, (limitDomSubtype_succ A h_mcs h_discrete)^[n] a = b
  -- a.val in limit_dom, b.val in limit_dom
  obtain ⟨M_a, hM_a⟩ := a.property
  obtain ⟨M_b, hM_b⟩ := b.property
  -- Both in dom(max(M_a, M_b))
  have ha_N := omega_chain_dom_mono_le A h_mcs (le_max_left M_a M_b) hM_a
  have hb_N := omega_chain_dom_mono_le A h_mcs (le_max_right M_a M_b) hM_b
  exact succ_reaches_dom_N A h_mcs h_discrete (max M_a M_b) a b ha_N hb_N hab
```

**Tasks:**
- [ ] Delete lines 1196-1402 (the old convergence proof body)
- [ ] Insert new proof body calling `succ_reaches_dom_N`
- [ ] Verify with `lean_goal` and `lean_verify` that the new proof compiles

**Timing**: 0.5 hour

**Depends on**: Step 2b

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

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/09_stage-walk.md` (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace proof body of `limitDomSubtype_isSuccArchimedean` with `succ_reaches_dom_N` call; add `succ_reaches_dom_N` induction lemma (~150-200 lines replacing ~200 lines)
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/09_stage-walk-summary.md` (after implementation)

## Rollback/Contingency

The convergence proof body (lines 1196-1402) is entirely replaced. The theorem statement is unchanged. Rollback: `git checkout` the modified file.

If the stage-walk induction approach fails:

1. **Primary fallback: LocallyFiniteOrder** (85% confidence, 400-600 lines): Prove `Set.Finite (Set.Icc a b)` for all a, b : LimitDomSubtype. This gives LocallyFiniteOrder, which implies IsSuccArchimedean. The key advantage: LocallyFiniteOrder is a well-trodden Mathlib path and does not need the stage-walk induction.

2. **Secondary fallback: first_stage induction (plan v8 revised)**: Fix plan v8 by avoiding the pred(c) assumption. Use the orbit-convexity resolution from plan v8 Step 2c (lines 360-397) which handles both forward and backward witnesses. The fix is: never claim first_stage(pred(c)) < first_stage(c); instead always use the orbit convexity trick when the adjacent dom(N) point is available.

3. **Last resort: Leave sorry with detailed documentation**: Write a comprehensive comment explaining the stage-walk argument, the construction-specific facts needed, and why it stalled. Keep the sorry well-localized.
