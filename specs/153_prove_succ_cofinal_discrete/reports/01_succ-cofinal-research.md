# Research Report: succ_cofinal for Discrete Limit Domains

**Task**: 153
**Session**: sess_1747338900_a1b2c3
**Date**: 2026-05-15

## 1. Problem Statement

### The Sorry

`succ_cofinal` at line 1885 of `ChronicleToCountermodel.lean` is the **sole root sorry** on the critical path of `bx_completeness`. The dependency chain is:

```
bx_completeness
  -> doets_countermodel_discrete (WeakCanonical/Transfer.lean, falls back to chronicle)
    -> dd_countermodel_chronicle_discrete
      -> cantor_bfmcs_discrete_restricted_tc / _fuc
        -> succ_embed_surjective
          -> limitDomSubtype_isSuccArchimedean
            -> succ_cofinal (line 1885) <-- ROOT SORRY
```

### Type Signature

```lean
private theorem succ_cofinal (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : forall x in limit_dom A h_mcs, next_top in limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) (hab : a < b) :
    exists n, b <= (limitDomSubtype_succ A h_mcs h_discrete)^[n] a
```

### Goal State at Sorry

The proof by contradiction has built extensive infrastructure. At the sorry, the context is:

```
case neg  (goal: False)

Key hypotheses:
  s := limitDomSubtype_succ A h_mcs h_discrete       -- succ function
  p := limitDomSubtype_pred A h_mcs h_discrete       -- pred function
  pb := p b                                           -- pred(b)
  h_not_cofinal : forall n, s^[n] a < b              -- contradiction hypothesis
  h_lt_pb : forall n, s^[n] a < pb                   -- orbit strictly below pred(b)

  -- Real analysis setup
  f : N -> R := fun n => (s^[n] a).val                -- orbit sequence in R
  L : R                                               -- limit of orbit sequence
  hL_tendsto : Filter.Tendsto f atTop (nhds L)        -- convergence
  hL_ub : forall n, f n <= L                          -- orbit values <= L
  hL_le_b : L <= b.val                                -- L <= b
  h_case : L <= pb.val                                -- L <= pred(b) [second branch]

  -- Gap structure
  orbit_below_L : forall c, a <= c -> c.val < L -> exists m, s^[m] a = c
  h_lt_pred_chain : forall k n, s^[n] a < p^[k] pb   -- orbit < pred-chain
  h_pred_chain_strict : forall k, (p^[k+1] pb).val < (p^[k] pb).val
  h_pred_chain_ge_L : forall k, L <= (p^[k] pb).val

  -- Truth propagation (proved within the proof, not circular)
  backward_G : forall psi x, (forall y > x, psi in limit_f y) -> G(psi) in limit_f(x)
  backward_F : forall phi x y, x < y -> phi in limit_f(y) -> F(phi) in limit_f(x)
  _backward_P : forall phi x y, y < x -> phi in limit_f(y) -> P(phi) in limit_f(x)
```

The first branch (`L > pb.val`) is already handled: eventually f(n) > pb, contradicting h_le_pb. The sorry is in the second branch where `L <= pb.val`.

## 2. Limit Domain Structure

### Construction Overview

The limit domain `limit_dom A h_mcs : Set Rat` is built as the countable union:
```
limit_dom = { x : Q | exists n, x in omega_chain_val(n).dom }
```

Each `omega_chain_val(n).dom` is a `Finset Rat`. Stage 0 has `dom = {0}`. Each step n+1 either:
- Inserts exactly one new rational point (resolving a C5/C5' counterexample), or
- Leaves the domain unchanged (counterexample already resolved).

### Discrete Case Properties

When `h_discrete : forall x in limit_dom, next_top in limit_f x` (where `next_top = U(T, bot)`):

| Property | Definition | Location |
|----------|-----------|----------|
| `limitDomSubtype_succ` | Immediate successor via C5 witness | line 901 |
| `limitDomSubtype_pred` | Immediate predecessor via C5' witness | line 952 |
| `limitDomSubtype_succOrder` | `SuccOrder` instance | line 941 |
| `limitDomSubtype_predOrder` | `PredOrder` instance | line 994 |
| `succ_orbit_convex` | a <= b <= s^[n](a) implies b = s^[k](a) | line 1112 |
| `limitDomSubtype_succ_pred` | succ(pred(b)) = b | line 1029 |
| `limitDomSubtype_pred_succ` | pred(succ(a)) = a | line 1060 |

### Key Auxiliary Lemmas (Already Proved)

| Lemma | Signature |
|-------|-----------|
| `limit_F_resolution` | F(phi) in limit_f(x) -> exists y > x in limit_dom with phi in limit_f(y) |
| `limit_P_resolution` | P(phi) in limit_f(x) -> exists y < x in limit_dom with phi in limit_f(y) |
| `limit_forward_G` | G(phi) in limit_f(x) and x < y -> phi in limit_f(y) |
| `limit_backward_H` | H(phi) in limit_f(x) and y < x -> phi in limit_f(y) |
| `limit_satisfies_c5_strong` | U(eta,xi) in limit_f(x) -> witness with strong guard |
| `limit_satisfies_c5'_strong` | S(eta,xi) in limit_f(x) -> witness with strong guard |
| `z1_in_mcs` | Z1 schema in every MCS |
| `backward_G` | (proved locally) forall y > x, psi in limit_f(y) -> G(psi) in limit_f(x) |
| `backward_F` | (proved locally) phi at y > x -> F(phi) in limit_f(x) |

### Z1 Axiom

Z1 is `G(G(phi) -> phi) -> (F(G(phi)) -> G(phi))`, derivable in BX as `Axiom.z1`. It is in every MCS via `z1_in_mcs`. Its frame-level semantics: the order is `IsSuccArchimedean` (no Z+Z gaps).

## 3. Analysis of the Gap Scenario

### The Z+Z Structure

In the gap scenario at the sorry:
- **Orbit**: `a, s(a), s^2(a), ...` with rational values converging (in R) to L from below
- **Pred-chain**: `pb, p(pb), p^2(pb), ...` with rational values converging (in R) to M >= L from above
- All orbit points are strictly below all pred-chain points
- `orbit_below_L`: any limit_dom point c with a <= c and c.val < L is an orbit point
- The gap region `[L, M]` (in R) may contain limit_dom points that are neither orbit nor pred-chain

This is exactly a Z+Z-like structure embedded in the rationals. The IsSuccArchimedean frame condition (encoded by Z1) should exclude this.

### Why Z1 Alone Is Insufficient

Z1 says: `G(Gphi->phi) -> (FGphi->Gphi)`.

**Non-constant MCS case**: If some formula phi distinguishes orbit from non-orbit points (phi in limit_f(x) for orbit x, phi not in limit_f(y) for non-orbit y above the gap):
- `FG(phi)` could hold at orbit points (since G(phi) might hold at sufficiently late orbit points)
- `G(Gphi->phi)` would need to hold (Gphi->phi at all future points)
- Z1 gives G(phi) at orbit points, providing a contradiction

**Constant MCS case** (all limit_f(x) = A): Every formula is uniformly present or absent at all limit_dom points. Z1 is trivially satisfied: G(phi) in A iff phi in A; FG(phi) in A iff G(phi) in A iff phi in A. The Z1 antecedent `G(Gphi->phi)` is always satisfied since `Gphi->phi` is `phi->phi` (tautology in constant case for formulas in A, and contrapositive for formulas not in A). Z1 conclusion `FGphi->Gphi` reduces to `Gphi->Gphi`, trivially true.

So: **Z1 produces no contradiction in the constant MCS case**. A different argument is needed.

### Why Stage Induction Is Incomplete

The `succ_reaches_dom_N` theorem (line 1162) attempts: for a, b both in dom(N), prove succ^[k](a) = b. This has two boundary-case sorries:

1. **Line 1297**: a in dom(N), b is new at stage N+1, b > max(dom(N)). The IH gives succ^[k](a) = max_N_sub. Then succ(max_N_sub) should be b, but succ(max_N_sub) is defined in the FULL limit_dom and might not appear until a stage M >> N+1. So `omega_chain_dom_new_unique` cannot be applied.

2. **Line 1450**: a is new at stage N+1, a < min(dom(N)). Similar boundary issue -- the predecessor of min(dom(N)) in the full limit_dom might not be in dom(N+1).

These boundary cases are fundamental: the succ function operates on the full limit_dom, but the stage induction only knows about finite prefixes. There is no guarantee that succ(x) appears at the same or next stage as x.

## 4. Candidate Approaches

### Approach A: Z1 Gap Elimination with Discriminating Formula

**Idea**: Find a formula phi that holds at all orbit points but fails at some point above the gap (or vice versa). Use Z1 to derive a contradiction.

**Difficulty**: In the constant MCS case, no such formula exists. All MCS are identical, so all formulas are uniformly present or absent. Z1 is trivially satisfied.

**Assessment**: BLOCKED unless combined with a construction-level argument showing the constant MCS case is impossible.

### Approach B: Constant MCS Impossibility from Construction Internals

**Idea**: Show that the omega-chain construction cannot produce a limit domain where all limit_f values are identical. If every point has the same MCS, then every C5 counterexample is trivially resolved (the existing witness already has the right formula), so the construction would stop adding points quickly. But seriality forces F(top) and P(top), which require witnesses above and below each point.

**Difficulty**: The construction resolves counterexamples in enumeration order, not by need. Even in the constant MCS case, F(top) at point 0 requires a point > 0, P(top) at 0 requires a point < 0, etc. These are genuinely resolved. The question is whether, after resolving all F/P counterexamples, the resulting domain is IsSuccArchimedean.

**Analysis**: In the constant MCS case with A containing U(T,bot):
- U(T,bot) at each x requires an immediate successor in the domain
- S(T,bot) at each x requires an immediate predecessor in the domain
- F(phi) at each x requires a witness y > x with phi in limit_f(y) = A (resolved by the successor itself, since phi in A)
- Every Until formula U(eta,xi) in A requires a witness, and since eta, xi are uniformly in/out of A, the existing successor resolves it (if eta in A) or the formula shouldn't be in A (if eta not in A)

So the C5 resolution for U(T,bot) inserts immediate successors. The construction builds a discrete chain: 0, succ(0), succ(succ(0)), ..., and similarly pred(0), pred(pred(0)), ... The question is whether this chain can have a gap (fail to be cofinal).

**Key question**: When U(T,bot) counterexample at point x is resolved, the new point y is placed adjacent to x. Is y always the global successor of x in limit_dom? Not necessarily -- other C5 counterexamples might later insert points between x and y.

**Assessment**: Deep construction analysis needed. Not obviously viable without significant new infrastructure.

### Approach C: Fix the Stage Induction Boundary Cases

**Idea**: Complete `succ_reaches_dom_N` by handling the boundary cases (lines 1297, 1450). Then derive `succ_cofinal` from `succ_reaches_dom_N`.

**Difficulty**: The boundary cases fail because `succ(max(dom(N)))` in the full limit_dom might not be in `dom(N+1)`. However, we can potentially reformulate:

**Alternative stage induction**: Instead of showing succ^[k](a) = b for a,b in the same stage, show that for any a < b in limit_dom, there exists N such that both a and b are in dom(N), and within dom(N), a and b are connected by a finite chain of "adjacent" pairs. Since succ(x) <= next_in_dom(N)(x) for all x in dom(N), iterating succ from a eventually passes each adjacent pair boundary, reaching b.

**Problem**: This still requires showing succ passes each boundary, which hits the same issue.

**Assessment**: The boundary cases are intrinsically hard. Fixing them likely requires either (a) a stronger characterization of where succ(x) lands relative to the stage where x appears, or (b) a completely different proof structure.

### Approach D: Prove limit_dom Has LocallyFiniteOrder in the Discrete Case

**Idea**: Show that for any a < b in LimitDomSubtype, the set {c | a <= c <= b} is finite. Then IsSuccArchimedean follows by strong induction on the cardinality.

**Proof sketch**: Pick N such that a.val, b.val in dom(N). dom(N) is a Finset. Every limit_dom point c with a.val <= c.val <= b.val must appear at some stage. Claim: c must appear at a stage M where some dom(M) point is in the interval [a.val, b.val]. Since dom(M) grows by at most one point per step, and new points are inserted between existing points (or at boundaries), the number of points in [a.val, b.val] can only grow by the number of "adjacent pairs" that bracket [a.val, b.val], which is bounded.

**Difficulty**: The claim "c must appear at a stage M where some dom(M) point is in [a.val, b.val]" is not obviously true. A new point could be inserted in [a.val, b.val] even when the counterexample being resolved is far away (if the BurgessR3Maximal witness happens to land in this interval).

**Assessment**: Potentially viable but requires deep understanding of point insertion mechanics. The BurgessR3Maximal construction determines WHERE new points are placed -- proving they respect locality would be significant new infrastructure.

### Approach E: Direct Proof via Pred-Chain Contradiction

**Idea**: In the gap scenario, the pred-chain `p^[k](pb)` is strictly decreasing with values >= L, and the orbit `s^[n](a)` is strictly increasing with values < L. Consider what happens at the "boundary" between orbit and pred-chain.

For large n and k, the orbit point `s^[n](a)` and pred-chain point `p^[k](pb)` are very close. The successor of `s^[n](a)` must be some limit_dom point. If `succ(s^[n](a))` is below all pred-chain points (i.e., it's another orbit point), then its value is still < L. If `succ(s^[n](a))` is >= some pred-chain point, we get a contradiction with the gap structure.

Specifically: for large enough n, `s^[n](a)` is close to L from below. The pred-chain eventually has a point `p^[k](pb)` close to L from above. The successor of `s^[n](a)` must be <= `p^[k](pb)` (since `p^[k](pb)` is a limit_dom point after `s^[n](a)`). If `succ(s^[n](a))` = `p^[k](pb)` for some k, then `s^[n+1](a) = p^[k](pb)`, a pred-chain point, contradicting `h_lt_pred_chain` which says orbit < pred-chain at ALL indices.

More precisely: `h_lt_pred_chain k (n+1)` says `s^[n+1](a) < p^[k](pb)`, but if `s^[n+1](a) = p^[k](pb)`, contradiction. And if `s^[n+1](a) > p^[k](pb)` for some k, that also contradicts the gap structure.

So `succ(s^[n](a))` must be strictly between `s^[n](a)` and all pred-chain points. But that means `succ(s^[n](a)).val < p^[k](pb).val` for all k, so `succ(s^[n](a)).val <= L`. Combined with `succ(s^[n](a)).val > s^[n](a).val`, this gives another orbit point with value in `(s^[n](a).val, L]`.

This is consistent and doesn't immediately give a contradiction. The orbit just keeps growing, with each succ step getting closer to L but never reaching it. The real analysis part (convergence of the orbit to L) already handles this -- it's the setup for the entire gap scenario.

**Assessment**: The gap scenario IS self-consistent at the topological/order-theoretic level. The contradiction must come from the LOGIC (temporal axioms + MCS structure) or the CONSTRUCTION (omega-chain mechanics).

### Approach F: Bypass succ_cofinal via Reynolds/Doets Pipeline

**Idea**: Complete the `doets_countermodel_discrete` theorem in `WeakCanonical/Transfer.lean` directly (without falling back to the chronicle construction), thereby making `succ_cofinal` dead code.

**Status**: The Reynolds pipeline has `table_correctness` proved (sorry-free) but is blocked on:
1. `chronicle_is_good` -> `sum_preservation` (Doets 1.4)
2. ZIntervalStructure -> TaskFrame bridge

The WeakCanonical route has 12 sorries across OrderedSum, NEquivalence, IntegerModel, and TruthLemma files.

**Assessment**: This is a major parallel workstream. It would eliminate the need for `succ_cofinal` entirely, but requires 12+ sorries to be resolved, making it arguably harder than resolving `succ_cofinal` directly.

### Approach G: Add IsSuccArchimedean as a Construction Invariant

**Idea**: Modify the chronicle construction to maintain IsSuccArchimedean as an invariant at each finite stage. Since each dom(N) is finite and linearly ordered with SuccOrder, IsSuccArchimedean is trivially true for finite domains. The limit would then inherit it.

**Difficulty**: IsSuccArchimedean for finite dom(N) with SuccOrder is indeed trivial (finite linear order with succ). But the succ at stage N (defined by adjacency in dom(N)) is different from the succ in the full limit_dom. As new points are inserted in later stages, what was "adjacent" at stage N may no longer be adjacent in the limit.

However, `succ_orbit_convex` bridges this gap: if a <= b <= s^[n](a) in the limit_dom, then b is an orbit point. So if succ(a) in dom(N) is y, and limit_dom inserts points between a and y, those points are between a and y, and succ_orbit_convex ensures they are succ-reachable from a.

**Key insight**: For any a and b in dom(N) with a adjacent to b (next in dom(N)), we have:
1. succ(a) <= b (in limit_dom, since b is a limit_dom point > a)
2. succ(a) might be < b (if a point was inserted between a and b at a later stage)
3. But by iterating succ, we can reach or pass b: since succ^[k](a) is increasing and dom(N) finite, eventually succ^[k](a) >= b.

Wait, step 3 is EXACTLY the claim we're trying to prove (succ_cofinal)! So this is circular.

**Assessment**: Circular. The invariant approach doesn't avoid the fundamental difficulty.

## 5. Recommended Approach

### Primary Recommendation: Approach A+B Hybrid (Z1 + Construction-Level Constant MCS Elimination)

The proof should proceed in two parts:

**Part 1: Non-constant MCS case (Z1 argument)**

If the MCS labeling is non-constant on the orbit+pred-chain region, there exists a formula phi that distinguishes some orbit point from some non-orbit point. The backward_G, backward_F, and z1_in_mcs infrastructure then gives a contradiction via the Doets maximum principle argument.

The backward_G lemma is already proved at the sorry site. The Z1 argument would look like:
1. Find phi such that phi in limit_f(x) for some orbit point x but not in limit_f(y) for some y in the gap region (or vice versa).
2. Use backward_G to propagate truth/falsity.
3. Use Z1 to derive a "maximum point" where Gphi->phi fails.
4. Show this maximum is in the orbit (by orbit_below_L), giving a contradiction.

**Estimated effort**: 150-250 lines of Lean, moderate difficulty. Requires careful formula manipulation.

**Part 2: Constant MCS case (construction-level argument)**

If all limit_dom points in the orbit+pred-chain region have identical MCS, derive a contradiction from the omega-chain construction properties. The argument would need to show that the constant MCS case forces the construction to not insert any new points in the gap region, but seriality requires points on both sides, eventually forcing a connection.

**Estimated effort**: 200-400 lines, high difficulty. Requires interaction with `omega_chain_elim_result`, `BurgessR3Maximal`, `counterexample_enum`, and related construction internals.

### Secondary Recommendation: Approach F (Complete Reynolds Pipeline)

If the direct proof proves intractable, completing the Reynolds/Doets pipeline would bypass `succ_cofinal` entirely. This is a larger effort (12+ sorries in WeakCanonical) but follows a well-understood mathematical path (Doets 1987, Reynolds 1994).

### Tertiary Recommendation: Approach D (Prove LocallyFiniteOrder)

If the limit_dom can be shown to be locally finite in the discrete case (finitely many points in any bounded interval), then IsSuccArchimedean follows trivially. This would require proving that the omega-chain construction adds only finitely many points to any bounded interval, which is plausible but requires significant new infrastructure around the point insertion mechanics.

## 6. Risk Assessment

| Factor | Assessment |
|--------|-----------|
| Mathematical correctness | HIGH confidence -- the theorem IS mathematically true (IsSuccArchimedean holds for the discrete limit domain) |
| Z1 non-constant case | MODERATE -- the argument is mathematically clear but requires careful formula manipulation in Lean |
| Constant MCS case | HIGH RISK -- the construction-level argument has not been fully worked out mathematically, let alone in Lean |
| Construction interaction | HIGH RISK -- the elimination result, BurgessR3Maximal, and counterexample resolution are complex and deeply interdependent |
| Time estimate | 2-4 days for the non-constant case, 3-7 days for the constant case, if viable |

## 7. Other Sorries in the File

There are 4 other sorries in ChronicleToCountermodel.lean:
- Line 839: `dd_countermodel_chronicle_nondense_sorry` -- dead code (superseded by the purely discrete path via `doets_countermodel_discrete`)
- Lines 1297, 1450: `succ_reaches_dom_N` boundary cases -- alternative proof attempts for the same problem, not on the critical path (they would feed into succ_cofinal if completed)
- Line 1514: `limit_dom_points_are_succ_iterates` -- another alternative approach, also not on critical path

All are dominated by the line 1885 sorry. Resolving line 1885 resolves the entire sorry chain.

## 8. Context for Implementation Planning

### What an Implementation Plan Needs

1. A precise case split: constant MCS vs non-constant MCS in the gap region
2. For non-constant: the exact discriminating formula, the Z1 instantiation, and the maximum principle derivation
3. For constant: either a construction-level impossibility proof OR a decision to pursue Approach F instead
4. Verification that backward_G, backward_F, z1_in_mcs, orbit_below_L, and h_lt_pred_chain are sufficient (they are already in scope at the sorry site)

### Prerequisites

- No new imports needed (all required Mathlib is already imported)
- No new axioms needed (Z1 is already in the system)
- The backward_G truth lemma (proved within the succ_cofinal proof itself) breaks the circularity concern noted in the comments

### Downstream Impact

Resolving `succ_cofinal` would make:
- `limitDomSubtype_isSuccArchimedean` sorry-free
- `succ_embed_surjective` sorry-free
- `cantor_bfmcs_discrete_restricted_tc/fuc` sorry-free
- `dd_countermodel_chronicle_discrete` sorry-free
- `doets_countermodel_discrete` sorry-free (since it falls back to the chronicle path)
- `bx_completeness` free of `sorryAx` (assuming no other active sorries on the critical path)
