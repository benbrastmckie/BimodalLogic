# Teammate C Findings: ChronicleToCountermodel Sorry Site Analysis

## Executive Summary

The 8 sorry sites in `ChronicleToCountermodel.lean` fall into THREE distinct categories with different blockers. The handoff's grouping of all 8 as "non-domain extension" is partially wrong: only 2 are genuinely about non-domain extension, 2 are about F/P witness transfer, and 4 are about Until/Since coherence transfer. All 8 share a common root cause: **the BFMCS coherence conditions quantify over ALL rationals, but the chronicle only provides guarantees at domain points**.

## The Root Problem: Domain vs Full-Carrier Mismatch

The FMCS type requires `mcs : D -> Set Formula` for ALL `D` (here `D = Rat`). The BFMCS restricted coherence conditions similarly quantify over ALL rationals:

```
restricted_temporally_coherent: forall fam, forall t : Rat, forall phi, ...
restricted_forward_until_since_coherent: forall fam, forall t : Rat, ...
  ... forall r : Rat, t <= r -> r < s -> phi in fam.mcs r
```

But the chronicle construction provides:
- `limit_f`: defined only on `limit_dom` (countable subset of Rat)
- `limit_forward_G`: requires BOTH x and y in `limit_dom`
- `limit_satisfies_c5_weak`: requires x in `limit_dom`, produces y in `limit_dom`
- `limit_F_resolution`: requires x in `limit_dom`

The `extended_limit_f` bridges this gap by assigning root MCS A to non-domain points, but this creates problems because the coherence conditions then need to hold at non-domain points where the assignment is A.

## Sorry Site Analysis: Individual Breakdown

### Sorry 1: chronicle_fmcs.forward_G (line 195)

**Goal**: `G(phi) in extended_limit_f(t) and t < t' implies phi in extended_limit_f(t')`

**Four sub-cases by domain membership of t, t'**:
1. **t in dom, t' in dom**: Reduces to `limit_forward_G` (sorry-free). CLOSABLE.
2. **t in dom, t' not in dom**: Need `G(phi) in limit_f(t) implies phi in A`. Requires `G(phi) -> phi` which is NOT valid under strict semantics (G quantifies over STRICT future). BLOCKED.
3. **t not in dom, t' in dom**: Need `G(phi) in A implies phi in limit_f(t')`. This would follow if A has forward_G coherence with limit_f, but there is no such guarantee. BLOCKED.
4. **t not in dom, t' not in dom**: Need `G(phi) in A implies phi in A`. Same issue: `G(phi) -> phi` is NOT an axiom of strict temporal logic. BLOCKED.

**True blocker**: Cases 2-4 are genuinely about non-domain extension. The assignment of A to non-domain points is semantically wrong under strict temporal semantics.

**Cantor isomorphism resolution**: YES, this would eliminate cases 2-4 entirely by making every rational a domain point.

### Sorry 2: chronicle_fmcs.backward_H (line 200)

**Goal**: `H(phi) in extended_limit_f(t) and t' < t implies phi in extended_limit_f(t')`

**Analysis**: Exact mirror of forward_G. Same four sub-cases, same blockers.

**True blocker**: Non-domain extension (identical to forward_G).

### Sorry 3: restricted_tc forward (line 372)

**Goal**: `F(phi) in shifted_chronicle_fmcs(t) implies exists s > t, phi in shifted_chronicle_fmcs(s)`

**Unfolded**: `F(phi) in extended_limit_f(t-s) implies exists s' > t, phi in extended_limit_f(s'-s)`

**Sub-cases**:
1. **t-s in dom**: `limit_F_resolution` gives witness y in `limit_dom` with y > t-s and phi in limit_f(y). Then extended_limit_f(y) = limit_f(y) by `extended_limit_f_eq_at_domain`. Set s' = y+s. CLOSABLE (modulo re-indexing).
2. **t-s not in dom**: `extended_limit_f(t-s) = A`, so F(phi) in A. Need a witness s' > t with phi in extended_limit_f(s'-s). Since 0 is in dom and limit_f(0) = A, we can use limit_F_resolution at 0 to get y > 0 in dom with phi in limit_f(y). But we need s' > t, i.e., y+s > t, i.e., y > t-s. We have y > 0 but t-s could be anything. BLOCKED unless we can find a domain point near t-s.

**True blocker**: NOT purely non-domain extension. Even with Cantor isomorphism (making all rationals domain), this becomes directly closable because limit_F_resolution applies at every point.

**Alternative without Cantor**: Could be partially addressed by density. limit_dom is dense, so for any t-s there exist domain points arbitrarily close to it. If F(phi) in A and A = limit_f(0), we can propagate F(phi) forward along the chronicle... but this requires forward_G which is itself sorry'd.

### Sorry 4: restricted_tc backward (line 375)

**Goal**: `P(phi) in shifted_chronicle_fmcs(t) implies exists s < t, phi in shifted_chronicle_fmcs(s)`

**Analysis**: Exact mirror of sorry 3. Same sub-cases.

**True blocker**: Same as sorry 3 -- requires domain membership of the query point or a way to transfer to a domain point.

### Sorry 5: restricted_buc Until (line 394)

**Goal**: Given witness s > t with psi in fam.mcs(s) and phi at all r in [t,s), derive `untl(phi,psi) in fam.mcs(t)`

**Unfolded**: This is the BACKWARD direction of Until coherence. Given:
- `s_wit > t` (a rational)
- `psi in extended_limit_f(s_wit - s)` (event at witness)
- `forall r, t <= r -> r < s_wit -> phi in extended_limit_f(r - s)` (guard at ALL intermediates)

Need: `untl(phi,psi) in extended_limit_f(t - s)`

**Key observation**: The guard quantifies over ALL rationals r in [t, s_wit), not just domain points. This means we have phi at every rational in the interval, which is STRONGER than what the chronicle provides.

**Approach**: This direction does NOT need C5. It needs the Until introduction axiom: if psi holds at some future point and phi holds throughout the interval, then Until(phi,psi) holds now. In the MCS setting, this requires:
- If we already have phi in fam.mcs(r) for all r in (t,s_wit) and psi in fam.mcs(s_wit), this should give untl(phi,psi) in fam.mcs(t) by the COMPLETENESS direction of the Until truth lemma.

**But**: The proof must work through the axiom system. The relevant axiom would be something like an Until introduction rule. In Burgess's system, this is typically derived from the completeness of the Until/Since axioms. The restricted parametric truth lemma handles this, but here we're at the pre-truth-lemma level (constructing the BFMCS that the truth lemma will use).

**True blocker**: This is a genuine logical challenge -- proving that the MCS-level Until introduction holds when you have the witness pattern at ALL time points (not just domain points). With Cantor isomorphism, every rational is a domain point, and this becomes the standard chronicle backward Until argument. Without it, it requires forward_G to propagate guard values from domain to non-domain points.

### Sorry 6: restricted_buc Since (line 397)

**Mirror of sorry 5** for Since. Same analysis applies.

### Sorry 7: restricted_fuc Until (line 426)

**Goal**: `untl(phi,psi) in fam.mcs(t) implies exists s > t, psi in fam.mcs(s) and phi at intermediates`

**Unfolded**: `untl(phi,psi) in extended_limit_f(t-s) implies exists s' > t, psi in extended_limit_f(s'-s) and forall r in [t,s'), phi in extended_limit_f(r-s)`

**Sub-cases**:
1. **t-s in dom**: `limit_satisfies_c5_weak` gives y in limit_dom with y > t-s and psi in limit_f(y). But C5_weak DOES NOT give the guard condition. The full C5 (Chronicle.c5) gives `gamma in f(z)` for intermediate DOMAIN points z. For the BFMCS, we need the guard at ALL rationals r in [t, s'), which is strictly stronger.
2. **t-s not in dom**: extended_limit_f returns A, so untl(phi,psi) in A. No direct chronicle infrastructure to produce witnesses from A.

**True blocker**: TWO issues:
1. C5_weak is too weak -- doesn't provide the guard condition even at domain points
2. The BFMCS guard quantifies over ALL rationals, not just domain points

**With Cantor isomorphism**: Issue 2 goes away (all rationals are domain). Issue 1 remains -- the full C5 gives the guard at domain points, but with Cantor this means all points.

**Critical finding**: We need the FULL C5, not just C5_weak. The full C5 provides:
```
exists y in dom, x < y, delta in f(y),
  AND forall z in dom, x < z < y -> gamma in f(z) AND untl(gamma,delta) in f(z)
```
With Cantor isomorphism, "z in dom" becomes "z in Rat" = all rationals, directly satisfying the BFMCS guard condition (almost -- we get `gamma in f(z)` for `x < z < y`, but the BFMCS needs `phi in fam.mcs(r)` for `t <= r < s`, which includes `r = t`. At `r = t`, we need `phi in fam.mcs(t)`, but from `untl(phi,psi) in fam.mcs(t)`, the guard inclusion `untl(gamma,delta) -> gamma` follows from the Until unfolding axiom).

**Is full C5 proved at the limit?** NO. Only C5_weak is proved. The full limit_c5 (with guard) is NOT in the codebase. This is a missing piece.

### Sorry 8: restricted_fuc Since (line 429)

**Mirror of sorry 7** for Since. Same analysis applies.

## Does the BFMCS Framework Require Rat?

Yes, in the current design. The `BFMCS` is parameterized by `D`:
```
structure BFMCS (D : Type*) [Preorder D]
```
And `chronicle_bfmcs` is defined as `BFMCS Rat`. The FMCS requires `mcs : Rat -> Set Formula` covering ALL rationals.

The framework does NOT support a subtype. Changing to `BFMCS (Subtype limit_dom)` would require rewriting the entire parametric representation theorem infrastructure. The Cantor isomorphism approach keeps `D = Rat` but makes every rational a domain point.

## dd_countermodel_chronicle Structure

Defined at line 448. It:
1. Instantiates `Rat` as the time domain with `AddCommGroup`, `LinearOrder`, etc.
2. Uses `ParametricCanonicalTaskFrame Rat` and `ParametricCanonicalTaskModel Rat`
3. Uses `ShiftClosedParametricCanonicalOmega (chronicle_bfmcs M h_mcs)` for the Omega set
4. Uses `shifted_chronicle_fmcs M h_mcs 0` as the evaluation family at time 0
5. Calls `fully_restricted_parametric_representation_from_neg_membership` which requires:
   - `chronicle_bfmcs_restricted_tc` (sorry 3, 4)
   - `chronicle_bfmcs_restricted_buc` (sorry 5, 6)
   - `chronicle_bfmcs_restricted_fuc` (sorry 7, 8)

All 8 sorries flow through to `dd_countermodel_chronicle`. The 2 `chronicle_fmcs` sorries (1, 2) are indirect dependencies: they're needed to construct the FMCS that the BFMCS uses, and the BFMCS coherence proofs implicitly depend on them (e.g., box_stable_in_chronicle_fmcs uses forward_G).

## Classification Summary

| Sorry | Line | Category | With Cantor | Without Cantor |
|-------|------|----------|-------------|----------------|
| 1. forward_G | 195 | Non-domain extension | Eliminated | Blocked |
| 2. backward_H | 200 | Non-domain extension | Eliminated | Blocked |
| 3. restricted_tc fwd | 372 | F/P witness transfer | Closable via limit_F_resolution | Blocked |
| 4. restricted_tc bwd | 375 | F/P witness transfer | Closable via limit_P_resolution | Blocked |
| 5. restricted_buc U | 394 | Until backward coherence | Closable (needs argument) | Blocked by forward_G |
| 6. restricted_buc S | 397 | Since backward coherence | Closable (needs argument) | Blocked by forward_G |
| 7. restricted_fuc U | 426 | Until forward coherence | Needs FULL C5 (not just C5_weak) | Blocked x2 |
| 8. restricted_fuc S | 429 | Since forward coherence | Needs FULL C5' (not just C5'_weak) | Blocked x2 |

## Key Finding: Full C5 is Missing

The most important finding is that even WITH the Cantor isomorphism, sorries 7-8 require the FULL C5/C5' with guard conditions at intermediate points, not just C5_weak. The full C5 states:

```
exists y in dom, x < y, delta in f(y),
  AND forall z in dom, x < z < y -> gamma in f(z) AND untl(gamma,delta) in f(z)
```

This full version is the `Chronicle.c5` definition (ChronicleTypes.lean:336-342). However, `limit_satisfies_c5_weak` only proves the weak version without the guard. A `limit_satisfies_c5_full` theorem is NEEDED and does not exist yet.

**Can full C5 be proved at the limit?** The guard condition `gamma in f(z)` for intermediate domain points should follow from the omega-chain's step-by-step C5 elimination, which inserts witnesses with the guard property. Whether the guard transfers to the limit depends on whether the omega-chain step preserves the guard condition when new points are inserted between the original witnesses. This is plausible but needs verification.

## Recommended Priority

1. **Cantor isomorphism** (eliminates sorries 1-2, enables 3-6) -- confirmed as correct approach
2. **Full limit C5/C5'** (enables sorries 7-8) -- the missing piece not identified in the handoff
3. **Until backward coherence argument** (closes sorries 5-6) -- may need Until unfolding axiom

The handoff's estimate of "8-10 hours for Cantor isomorphism" should be revised upward to account for the full C5 proof, which is an additional piece of work beyond what was identified.
