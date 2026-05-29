# succ_cofinal Bypass: Three-Path Investigation

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Find a sorry-free path to `completeness_discrete` by closing or bypassing `succ_cofinal`

---

## 0. Exact Sorry Chain (Verified by lean_verify)

```
completeness_discrete  (Completeness.lean:308)
  calls countermodel_discrete_enriched  (Completeness.lean:222, private)
    calls cantor_bfmcs_discrete_restricted_tc  [sorryAx]
    calls cantor_bfmcs_discrete_restricted_fuc  [sorryAx]
    calls cantor_bfmcs_discrete_restricted_buc  [NO sorryAx -- sorry-free]
      uses succ_embed_squeeze_strict  [sorry-free]
    --> Both _tc and _fuc call:
        succ_embed_surjective  [sorryAx]
          calls limitDomSubtype_isSuccArchimedean  [sorryAx]
            calls succ_cofinal  [sorryAx -- ROOT SORRY, line 1885]
```

**Verification results** (lean_verify):

| Theorem | sorryAx? |
|---------|----------|
| `succ_cofinal` | YES |
| `limitDomSubtype_isSuccArchimedean` | YES |
| `succ_embed_surjective` | YES |
| `cantor_bfmcs_discrete_restricted_tc` | YES |
| `cantor_bfmcs_discrete_restricted_fuc` | YES |
| `cantor_bfmcs_discrete_restricted_buc` | NO |
| `cantor_bfmcs_discrete` | NO |
| `rooted_succ_discrete_fmcs` | NO |
| `succ_discrete_fmcs` | NO |
| `succ_embed_strictMono` | NO |
| `succ_embed_squeeze_strict` | NO |
| `succ_orbit_convex` | NO |
| `limit_satisfies_c5_strong` | NO |
| `limit_F_resolution` | NO |
| `limit_forward_G` | NO |

**Minimum cut point**: The sorry enters ONLY through `succ_embed_surjective`, which is called by both `_tc` and `_fuc`. The BUC proof uses `succ_embed_squeeze_strict` (sorry-free) instead, because C4 witnesses fall BETWEEN two known image points. TC and FUC witnesses may fall OUTSIDE the image range.

---

## 1. Path 1: Close succ_cofinal Directly

### What succ_cofinal Claims

```lean
private theorem succ_cofinal (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : forall x in limit_dom fc A h_mcs, next_top in limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b) :
    exists n, b <= (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a
```

This says: in the limit domain (a countable subset of Rat with SuccOrder/PredOrder from the discrete chronicle), any point `b > a` is reachable from `a` by finitely many successor applications. This is `IsSuccArchimedean`.

### The Limit Domain

`limit_dom` is the union of all finite domains in the omega-chain:
```
limit_dom = { x : Rat | exists n : Nat, x in (omega_chain_val n).dom }
```
Stage 0 has domain `{0}`. Each stage adds at most one rational point to resolve a C5/C4 counterexample. The limit domain is countable, dense in itself (if infinite), but NOT dense in Rat.

In the discrete case (every MCS has `U(T, bot)`), every domain point has an immediate successor and predecessor -- no other domain point between them. This gives `SuccOrder` and `PredOrder` on `LimitDomSubtype`.

### Proof State (8 of 9 Steps Complete)

The proof is by contradiction: assume `succ^[n](a) < b` for all `n`. Steps 1-8 (lines 1557-1696) establish:

1. All orbit points `<= pred(b)` -- done
2. Real-valued orbit sequence converges to `L <= b.val` -- done
3. Case split on `L > pred(b).val` vs `L <= pred(b).val` -- done
4. `L > pred(b).val` case: direct contradiction (orbit exceeds pred(b)) -- done (lines 1609-1621)
5. `L <= pred(b).val` case: orbit points are strictly below pred(b) -- done
6. `orbit_below_L`: any domain point with `a <= c` and `c.val < L` is an orbit point -- done (lines 1639-1656)
7. `backward_G`, `backward_F`, `backward_P` truth lemmas -- done (lines 1703-1839)
8. Pred-chain analysis: `pred^[k](pb)` values are all `>= L` and strictly decreasing -- done (lines 1686-1695)

### Step 9: The Sorry (Gap Elimination)

**Location**: Line 1885.

In the `L <= pred(b).val` case, the orbit `{succ^n(a)}` converges to L from below, and the pred-chain `{pred^k(b)}` has values >= L and strictly decreasing. There are no domain points with value in the "gap" near L.

**Three approaches investigated and failed** (documented in comments lines 1848-1884):

1. **Prior-UZ + c5_strong**: In the discrete case, consecutive succ-orbit points have no domain points between them, so guards are vacuously satisfied. No discriminating formula.

2. **Z1 (Doets maximum principle)**: `G(G(phi)->phi) -> (FG(phi)->G(phi))`. In the constant-MCS case (all domain points have identical formula assignments), this is vacuously true. In the non-constant case, controlling phi truth at ALL future points (not just orbit/pred-chain) is unsolved.

3. **Gap point analysis / infinite descent**: The pred-chain descends toward L, but `NoMinOrder` prevents termination. No contradiction reached.

### Is succ_cofinal Mathematically True?

**YES.** The theorem is mathematically true for the limit domain of the Burgess omega-chain construction. The limit domain in the discrete case is order-isomorphic to Z (the integers). The proof difficulty is FORMAL, not mathematical.

### What Would a Proof Look Like?

The most promising approach is a **construction-level argument**: show that the omega-chain construction cannot produce a domain with multiple Z-components.

**Key insight**: Every point in `limit_dom` was inserted at some finite stage to resolve a specific counterexample. When the construction inserts point `y` to resolve `U(eta, xi)` at point `x`, the point `y` is placed:
- ABOVE all existing points (if `x` is the current maximum, Lemma 2.4, line 1837)
- Between existing adjacent points (if `x` is interior)

In the discrete case, each succ-successor is the IMMEDIATE next domain point. If point `z` is inserted between `succ^k(a)` and `succ^{k+1}(a)` at some stage, then in the limit domain, `z` becomes the new successor of `succ^k(a)` and predecessor of (the old) `succ^{k+1}(a)`. This EXTENDS the orbit to include `z`.

The gap scenario requires a domain point `p` that is above ALL orbit points from 0. Such `p` was inserted at some finite stage `n_p`. At stage `n_p`, the existing domain is finite, so there is a maximum orbit point `succ^K(0)` in the existing domain at that stage. Point `p` is placed above `succ^K(0)`. But then `pred(p)` in the limit domain must be `succ^K(0)` or a later orbit point (since by `orbit_below_L`, all domain points below `p.val` and `>= 0` are orbit points). Thus `p = succ(pred(p)) = succ(succ^K(0)) = succ^{K+1}(0)`, which IS an orbit point. Contradiction.

**Difficulty**: This argument requires deep interaction with `omega_chain_elim_result`, `BurgessR3Maximal`, and showing that the ordering of insertion stages is compatible with the limit-domain succ structure. The key gap is formalizing: "if `p` was inserted at stage `n_p`, then `pred(p)` (in the limit domain) was already in the domain at stage `n_p`."

This last claim is NOT obviously true. When `p` is inserted at stage `n_p`, it becomes adjacent to two existing points `a_L < p < a_R`. In the LIMIT domain, `pred(p)` might be different from `a_L` if more points are inserted between `a_L` and `p` at later stages. In that case, `pred(p)` in the limit domain is a point inserted AFTER `p`, and the argument fails.

**However**, in the discrete case, `pred(p)` is the immediate predecessor -- no domain points between `pred(p)` and `p`. This means NO points are ever inserted between `pred(p)` and `p` after `pred(p)` is established. If `pred(p)` is an orbit point (which is true if `pred(p).val < L`), then `p = succ(pred(p))` is also an orbit point.

The gap scenario requires `pred(p).val >= L` for all points `p` above the orbit. But then `pred(p)` is a pred-chain point, and `pred(pred(p))` is also a pred-chain point, giving infinite descent -- except the descent converges to L and there is no minimum.

**This is the genuine mathematical difficulty**: the pred-chain from `p` descends toward L but never reaches it. One needs to show this pred-chain eventually reaches an orbit point, which is equivalent to the original claim.

### Feasibility: NEEDS MORE RESEARCH

**Estimated effort**: 300-600 lines of new Lean code. Requires:
1. Proving that the omega-chain construction places each C5 witness at a specific relationship to existing orbit points
2. A well-founded induction on construction stages showing orbit membership propagates
3. Possibly a new intermediate lemma: "every point added by the construction at stage n is in the succ-orbit of some point added at stage n-1"

**Risk**: MEDIUM-HIGH. The construction-level argument is subtle and may require new infrastructure for reasoning about finite-stage domains.

---

## 2. Path 2: Option D -- Direct Int-based MCS Chain

### Concept

Instead of:
```
Int --succ_embed--> LimitDomSubtype --limit_f--> Set Formula
```

Build the MCS chain directly on Int:
```
Int --constrained_successor--> Set Formula
```

Specifically:
- `MCS(0) = A` (the root MCS)
- `MCS(n+1) = Lindenbaum(constrained_successor_seed(MCS(n)))` (for n >= 0)
- `MCS(n-1) = Lindenbaum(constrained_predecessor_seed(MCS(n)))` (for n <= 0)

### Current Infrastructure Status

**Bundle/SuccExistence.lean** has three sorries:
- `constrained_successor_seed_consistent` (line 446): `g_content u subset u` under irreflexive semantics
- `successor_deferral_seed_consistent_axiom` (line 749): same issue
- `predecessor_deferral_seed_consistent_axiom` (line 823): `h_content u subset u` under irreflexive semantics

All three are about `g_content subset mcs` or `h_content subset mcs`, which requires `G(phi) -> phi` (reflexive G axiom BX1). Under the current strict/irreflexive semantics, BX1 was removed.

**Bundle/SuccRelation.lean** has seven sorries:
- `until_unfold_in_mcs` (line 558): TOMBSTONE (BX9 removed)
- `since_unfold_in_mcs` (line 567): TOMBSTONE (BX9 removed)
- `until_persists_through_succ` (line 591): BLOCKED under strict semantics
- `or_until_in_mcs` (line 620): TOMBSTONE (reflexive intro invalid)
- `or_since_in_mcs` (line 634): TOMBSTONE
- `g_content_subset_mcs` (line 645): BX1 removed
- `h_content_subset_mcs` (line 653): BX1' removed

**Critical**: NONE of these Bundle sorries are used by the Chronicle pipeline. They are all dead code for the current proof architecture. The Chronicle construction bypasses the Bundle entirely.

### Why Option D Reduces to Option A

The handoff document (phase-7-handoff) identifies this clearly (lines 106-111):

> Prove C5 for the succ_discrete_f chain DIRECTLY on Int, without going through the limit domain. This would require:
> 1. Showing that U(phi, psi) in MCS(t) implies phi holds at SOME integer-indexed point
> 2. This is equivalent to showing F(psi) in MCS(t) implies psi holds at some MCS(s) for s > t
> 3. This is equivalent to... succ_cofinal

The issue: even if we define the MCS chain directly on Int (bypassing limit_dom), we STILL need to prove that `U(phi, psi) in MCS(t)` implies phi holds at some `MCS(s)` for `s > t`. We know phi holds SOMEWHERE in the limit domain (by `limit_satisfies_c5_strong`), but pulling it back to an integer requires surjectivity of the embedding.

If we construct the chain without the limit domain, we lose access to `limit_satisfies_c5_strong` entirely. We would need to prove C5 for the integer chain from scratch, using the axioms and the MCS structure. This is equivalent to proving that the MCS chain is a model of the temporal logic, which is EXACTLY what `succ_cofinal` provides.

**Additional blocker**: The Bundle SuccExistence sorries mean we cannot even CONSTRUCT the constrained successor MCS without first resolving the `g_content subset u` issue. This is a separate problem from `succ_cofinal` and requires either:
- Restoring BX1 (changes the logic)
- Reproving g_content inclusion under strict semantics (new theorem)
- Using a different seed construction

### Feasibility: INFEASIBLE (without solving succ_cofinal or equivalent)

The Bundle infrastructure has its own unsolved sorries, AND the C5 proof for the Int chain reduces to the same mathematical content as `succ_cofinal`. This path creates MORE work, not less.

---

## 3. Path 3: Parametric Canonical Model (Already in Use)

### Current Architecture

`completeness_discrete` already uses the parametric canonical model:
```
completeness_discrete
  -> countermodel_discrete_enriched (Completeness.lean:222)
    -> ParametricCanonicalTaskFrame Int
    -> ParametricCanonicalTaskModel Int
    -> ShiftClosedParametricCanonicalOmega (cantor_bfmcs_discrete ...)
    -> fully_restricted_parametric_completeness_from_neg_membership (...)
```

The parametric model is parameterized by `BFMCS Int` (a bundle of FMCS families). The `cantor_bfmcs_discrete` provides this bundle. It is sorry-free itself.

The sorries enter through the THREE coherence conditions passed to the completeness theorem:
1. `cantor_bfmcs_discrete_restricted_tc` -- [sorryAx]
2. `cantor_bfmcs_discrete_restricted_buc` -- sorry-free
3. `cantor_bfmcs_discrete_restricted_fuc` -- [sorryAx]

### Does cantor_bfmcs_discrete Depend on succ_cofinal?

**NO.** `cantor_bfmcs_discrete` is sorry-free. It constructs the BFMCS bundle using `rooted_succ_discrete_fmcs`, which uses `succ_discrete_f`, which uses `succ_embed` and `limit_f`. None of these depend on `succ_cofinal`.

The sorries enter ONLY when we try to PROVE the coherence conditions for this BFMCS.

### Why TC and FUC Carry Sorry

Both proofs follow the same pattern:
1. Get a formula `F(phi)` or `U(phi,psi)` in `fam.mcs(t)`
2. Translate to `limit_f(succ_embed(t + offset))`
3. Use `limit_F_resolution` or `limit_satisfies_c5_strong` to find witness `y` in limit_dom
4. Use `succ_embed_surjective` to convert `y` to integer `m` -- **THIS IS THE SORRY**
5. Return `(m - offset)` as the integer witness

### Why BUC Does Not Carry Sorry

BUC uses the CONTRAPOSITIVE approach:
1. Assume the conclusion fails (Until is NOT in MCS(t))
2. Get neg(Until) in MCS(t), translate to limit_f
3. Use `limit_satisfies_c4` to find C4 counterexample witness `z` BETWEEN succ_embed(t) and succ_embed(u)
4. Use `succ_embed_squeeze_strict` (sorry-free) to convert `z` to integer `k` -- works because z is BETWEEN two known image points
5. Derive contradiction

### Can We Rewrite TC/FUC to Avoid succ_embed_surjective?

**For TC (F/P resolution)**:

TC needs: `F(phi) in MCS(t) -> exists s > t, phi in MCS(s)`.

**Alternative approach**: Use discrete stepping. In the discrete case with `U(T, bot)`, every point has an immediate successor. If `F(phi) in MCS(t)`:
- `F(phi)` translates to `U(phi, T)` (via BX axiom `F_until_equiv`)
- `U(phi, T) in MCS(t)` means "phi holds somewhere strictly in the future"
- In the discrete case, step through: either phi at t+1, or U(phi, T) at t+1
- The deferral closure is finite (bounded by subformulas of root)
- By pigeonhole on the formula assignments, the stepping MUST terminate

This is the "finite model property" argument. In the integer chain, the MCS at each integer is determined by a finite set of subformulas. There are only finitely many possible MCS restrictions to any finite set. If `F(phi)` persists forever, the MCS assignments eventually cycle. A cycling MCS chain with `F(phi)` always present means `G(neg(phi))` is consistent with `F(phi)`, which is a contradiction.

**BUT**: Formalizing this requires:
1. Showing `F(phi)` persists through succ steps when phi doesn't hold
2. This is `F(phi) in MCS(n)` and `neg(phi) in MCS(n+1)` implies `F(phi) in MCS(n+1)`
3. This follows from the forward_G property: if `G(neg(phi))` were in MCS(n+1), then by backward propagation, `G(neg(phi))` would be in MCS(n), contradicting `F(phi)` in MCS(n). So `neg(G(neg(phi))) = F(phi)` is in MCS(n+1).

Wait -- this IS provable! Let me trace the argument:

1. `F(phi) in MCS(n)` (given)
2. Assume `neg(F(phi)) = G(neg(phi)) in MCS(n+1)` (toward contradiction)
3. By forward_G property of the FMCS: `G(psi) in MCS(n)` and `n < n+1` implies `psi in MCS(n+1)`. But this goes the WRONG direction.
4. By backward_H property: `H(psi) in MCS(n+1)` and `n < n+1` implies `psi in MCS(n)`. But `G(neg(phi))` is not `H(...)`.

Actually, the FMCS only has forward_G and backward_H. There is no "backward_G" at the FMCS level. backward_G exists at the limit_dom level (`limit_forward_G`), but this is "forward G goes forward" -- if `G(psi) in limit_f(x)` and `x < y`, then `psi in limit_f(y)`.

Wait, I need to re-check. The FMCS has:
- `forward_G : t < t' -> G(psi) in mcs(t) -> psi in mcs(t')`
- `backward_H : t < t' -> H(psi) in mcs(t') -> psi in mcs(t)`

So if `G(neg(phi)) in MCS(n+1)` and `n+1 < n+2`, then `neg(phi) in MCS(n+2)`. And `neg(phi) in MCS(n+3)`, etc. So `neg(phi)` holds at ALL future points.

But we need `neg(phi)` at ALL future points from MCS(n), not MCS(n+1). We know `neg(phi)` holds at `n+1, n+2, ...` from forward_G. But does it hold at `n`? Not necessarily -- `F(phi) in MCS(n)` says `neg(G(neg(phi))) in MCS(n)`, so `G(neg(phi)) NOT in MCS(n)`. This means `neg(phi)` might or might not be in MCS(n).

Actually for the "F(phi) persists" argument, we want: if `F(phi) in MCS(n)` and `neg(phi) in MCS(n+1)`, then `F(phi) in MCS(n+1)`.

Proof: Assume toward contradiction that `neg(F(phi)) = G(neg(phi)) in MCS(n+1)`. Then by forward_G, `neg(phi) in MCS(n+2), MCS(n+3), ...` So `neg(phi)` holds at all points `>= n+1`. But this means `G(neg(phi)) in MCS(n)` -- WAIT, does it?

The FMCS has forward_G but not "backward G construction." We cannot conclude `G(neg(phi)) in MCS(n)` just from `neg(phi)` holding at all points `>= n+1`. We would need `neg(phi)` at all points `> n` (strictly), which is `n+1, n+2, ...` in the integer chain. This IS `G(neg(phi)) in MCS(n)` if the semantics is strict (irreflexive).

Under STRICT semantics, `G(neg(phi))` at position `n` means `neg(phi)` at all positions STRICTLY greater than `n`, which is `n+1, n+2, n+3, ...`. If we have `neg(phi) in MCS(m)` for all `m > n`, does the FMCS infrastructure give us `G(neg(phi)) in MCS(n)`?

This would be a "backward_G" property: if phi holds at all future points, then G(phi) holds at the current point. The FMCS does NOT have this property built in. It is a CONSEQUENCE of completeness, not a premise.

**However**, the `backward_G` property IS available at the limit_dom level: `backward_G` was proved in the `succ_cofinal` proof itself (lines 1703-1753). It uses `limit_F_resolution` and doesn't depend on `succ_cofinal`. But it's for the limit_dom points, not for the integer chain directly.

Can we transfer it? If `neg(phi) in limit_f(succ_embed(m))` for all `m > n`, then we need `G(neg(phi)) in limit_f(succ_embed(n))`. But `backward_G` at limit_dom level says: if `neg(phi) in limit_f(y)` for all `y > x` in limit_dom, then `G(neg(phi)) in limit_f(x)`. The succ_embed image might not cover ALL points `> x` in limit_dom -- there could be non-image points above x. So this doesn't directly work.

**Conclusion**: The "F(phi) persists" / pigeonhole approach also ultimately requires knowing that the succ_embed image covers all relevant domain points, which is `succ_embed_surjective`.

### Feasibility: INFEASIBLE as a bypass, but HIGHLIGHTS the exact needed property

The parametric architecture is the RIGHT architecture. The problem reduces to EXACTLY `succ_embed_surjective` (equivalently `succ_cofinal`). There is no way around it within this architecture.

---

## 4. Summary and Recommendation

| Path | Verdict | Key Blocker |
|------|---------|-------------|
| Path 1: Close succ_cofinal | NEEDS MORE RESEARCH | Gap elimination in L <= pred(b) case; construction-level argument needed |
| Path 2: Direct Int chain | INFEASIBLE | Reduces to succ_cofinal + has own Bundle sorries |
| Path 3: Parametric bypass | INFEASIBLE | Same succ_embed_surjective dependency |

### The Single Remaining Sorry

The ENTIRE completeness_discrete theorem depends on exactly ONE sorry: `succ_cofinal` at ChronicleToCountermodel.lean line 1885. All other infrastructure is sorry-free. Closing this sorry eliminates sorryAx from `completeness_discrete`.

### Recommended Approach: Construction-Level Proof of succ_cofinal

The most viable path is a construction-level argument for Step 9 of `succ_cofinal`. The argument structure:

1. **Show that the pred-chain from b eventually reaches an orbit point.**

   Key: Every pred-chain point `pred^k(b)` was inserted at some finite stage of the omega-chain. At that stage, its predecessor (in the then-current domain) was some existing point. As more points are inserted, the limit-domain predecessor of `pred^k(b)` might change, but it is always a domain point with a smaller rational value.

2. **Use omega-chain stage induction.**

   For each point `p` in limit_dom, define `stage(p)` = the first stage where `p` enters the domain. Then:
   - `stage(0) = 0`
   - If `pred(p)` in the limit domain was already in the domain at stage `stage(p)`, then `pred(p)` has `stage(pred(p)) <= stage(p)`
   - If `pred(p)` was added LATER than `p`, things are more complex

3. **The hard case**: a point `p` is added at stage `n`, and its limit-domain predecessor is added at stage `m > n`. This means points were inserted between the previous predecessor of `p` and `p` itself, with the final (limit-domain) predecessor being inserted last.

   In the discrete case, this should be impossible: once `p` and its neighbor `q < p` are in the domain with no points between them, the discrete property (no domain points between consecutive succ/pred pairs) PREVENTS further insertions between `q` and `p`. The omega-chain only adds points between ADJACENT pairs in the current domain, and if `q` and `p` are adjacent with the guard formula being `bot` (from `U(T, bot)` resolution), then no C5 resolution will insert between them.

**This insight** -- that discrete adjacency with bot guard is STABLE under the construction -- could be the key to the formal proof.

### Estimated Effort

- Construction-level succ_cofinal proof: 200-400 lines
- Requires new lemmas about omega-chain stage stability for discrete adjacency
- Key new infrastructure: "if x and succ(x) are adjacent at stage n with bot guard, they remain adjacent in all later stages"

### Alternative: Task 129 (Henkin Model)

If the construction-level argument proves too difficult to formalize, task 129 (Henkin model approach) provides an alternative. The Henkin model avoids the omega-chain construction entirely, building a model that is `IsSuccArchimedean` by construction. This is a different proof architecture but achieves the same goal. Estimated effort: 500-800 lines.

---

## 5. Key Files

| File | Role | Sorry? |
|------|------|--------|
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean:1885` | `succ_cofinal` sorry | ROOT SORRY |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean:2817` | `succ_embed_surjective` | depends on succ_cofinal |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean:3142` | `restricted_tc` | depends on surjective |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean:3197` | `restricted_fuc` | depends on surjective |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean:3066` | `restricted_buc` | sorry-free |
| `Metalogic/BXCanonical/Completeness.lean:308` | `completeness_discrete` | inherits sorry |
| `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean:1430` | `limit_satisfies_c5_strong` | sorry-free |
| `Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean:1810` | `eliminate_potential_counterexample` | sorry-free |
