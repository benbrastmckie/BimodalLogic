# GHR93 Claim 1 Case II: How the Literature Handles sel-vs-p_n Ordering

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-26
**Focus**: Resolve the sel-vs-p_n ordering gap by analyzing how GHR93 constructs e_n in Case II

---

## 1. The Blocker in Our Code

The combined (n+1)-round winning condition in Case II requires `same_order_type` across all pairs of positions, including between:
- **Selection positions** (a_init(k) on N-side, resp_tau(k) on M-side) for k < n
- **The n-th position** (extendPoint p_n on N-side, e_n on M-side)

Specifically, we need:
```
(a_init k < extendPoint p_n <-> resp_tau k < e_n) /\
(a_init k = extendPoint p_n <-> resp_tau k = e_n)
```
for all k < n.

Five approaches were attempted and all failed (detailed in the phase-3-handoff-impl-v2.md).

---

## 2. How GHR93 Constructs e_n (the Literature's Approach)

### 2.1 The GHR93 Case II Proof (pp. 117-118)

GHR93 Case II applies when all alpha_0,...,alpha_n lie in (d-bar, y') and alpha_n is a point (not a gap). The proof proceeds:

1. **Use tau for alpha_0,...,alpha_{n-1}**: Apply the backward strategy tau on [d-bar, b'] vs [c, b] to the first n selections. This produces e_0,...,e_{n-1} in (c, b)_r.

2. **Transfer U(B, A)**: The formula U(B, A) holds at alpha_{n-1} in N_r (witnessed by alpha_n: B holds at alpha_n, and A holds on (alpha_{n-1}, alpha_n)). Since tau preserves formulas up to rank r+4, and U(B,A) has rank r+1 <= r+4, we get M_r |= U(B, A)^mu(e_{n-1}).

3. **Find the witness z**: From M_r |= U(B, A)(e_{n-1}), there exists z > e_{n-1} in M with M |= B(z) and M |= A(t) for all t in (e_{n-1}, z). Set **e_n = z**.

**Key structural point**: e_n is constructed as a witness for the Until formula U(B,A) at the position e_{n-1}. It is NOT found by playing a separate forward game. The construction guarantees e_n > e_{n-1} by the semantics of U.

### 2.2 How the sel-vs-p_n Ordering is Established in GHR93

GHR93 assumes that Spoiler's selections are **strictly increasing**: x' < alpha_0 < alpha_1 < ... < alpha_n < y'. This means:

- **N-side**: a_init(k) = alpha_k < alpha_n = p_n for all k < n (trivially true from strict ordering)
- **M-side**: The tau game preserves strict ordering, so e_0 < e_1 < ... < e_{n-1}. Since e_n > e_{n-1} (from U(B,A) witness), we get e_k < e_n for all k < n.

**Therefore**, `a_init(k) < p_n <-> resp_tau(k) < e_n` reduces to `True <-> True`.

For equality: a_init(k) = p_n is impossible (strict ordering), and resp_tau(k) = e_n is impossible (since resp_tau(k) <= e_{n-1} < e_n). So `a_init(k) = p_n <-> resp_tau(k) = e_n` reduces to `False <-> False`.

**GHR93 does not need an explicit ordering lemma or a game that includes both selections and p_n.** The ordering falls out automatically from:
1. The tau game's ordering preservation on the first n positions
2. The transitivity of `<` through e_{n-1} (the pivotal position connecting tau outputs to e_n)

### 2.3 Why GHR93's Approach Avoids the Gap

The gap in our code arises because:
1. **Our e_n construction is wrong.** Our code finds e_n by playing the d-compatible forward game with p_n as a Round 2 challenge. This produces an e_n whose relationship to the tau responses (resp_tau) is mediated only through the pivot d/c, NOT through e_{n-1}.
2. **GHR93's e_n construction goes through e_{n-1}.** The Until witness z = e_n satisfies z > e_{n-1}, creating a direct ordering chain from every resp_tau(k) through e_{n-1} to e_n.

The difference is summarized in this table:

| Aspect | Our Code | GHR93 |
|--------|----------|-------|
| e_n source | d-compatible forward game Round 2 | U(B,A) witness above e_{n-1} |
| e_n > e_{n-1} | Not guaranteed | Guaranteed (Until semantics) |
| sel-vs-p_n ordering | Must be derived externally | Falls out from transitivity |
| Ordering chain | d/c -> p_n/e_n (fork, not chain) | resp_tau(k) < e_{n-1} < e_n (chain) |

---

## 3. Structural Comparison: Our Proof vs. the Literature

### 3.1 What Our Code Does (Current Architecture)

```
Forward game (d-compatible)
    |
    +--- Spoiler plays: resp_tau(0), ..., resp_tau(n-1), c
    |    Duplicator responds: a'_big(0), ..., a'_big(n-1), d
    |
    +--- Round 2: Spoiler challenges with p_n
    |    Duplicator responds with e_n_pt
    |
    +--- Winning condition gives:
    |      (c < e_n <-> d < p_n)          [hord_cd_en_pn]
    |      (a'_big(k) < p_n <-> resp_tau(k) < e_n)  [from big game]
    |      BUT a'_big(k) != a_init(k) in general!
    |
    BLOCKED: Cannot derive (a_init(k) < p_n <-> resp_tau(k) < e_n)
```

The problem is that a'_big(k) (the forward game's N-side responses to resp_tau(k)) are NOT the same as a_init(k) (Spoiler's backward choices). They are different N-points. The forward game tells us about a'_big, not about a_init.

### 3.2 What GHR93 Does

```
Tau game on [d-bar, b'] vs [c, b]:
    |
    +--- Spoiler plays: a_0, ..., a_{n-1}  (= a_init)
    |    Duplicator responds: e_0, ..., e_{n-1}  (= resp_tau)
    |
    +--- Tau preserves rank-(r+4) formulas
    |    In particular, U(B,A) has rank r+1 <= r+4
    |
    +--- N_r |= U(B,A)(a_{n-1}) [alpha_n witnesses it]
    |    => M_r |= U(B,A)(e_{n-1}) [formula transfer via tau]
    |
    +--- Extract U(B,A) witness: exists z > e_{n-1} with B(z) and A on (e_{n-1}, z)
    |    Set e_n = z.
    |
    +--- Ordering: e_k <= e_{n-1} < e_n for all k < n (tau + transitivity)
    |    And: a_k < a_n for all k < n (strict ordering assumption)
    |
    RESOLVED: (a_init(k) < p_n <-> resp_tau(k) < e_n) = (True <-> True)
```

### 3.3 The Divergence Point

The divergence occurs at Step 3 of ghr93_case_II (lines 1206-1247 of CaseAnalysis.lean). Instead of using tau's formula transfer to find e_n above e_{n-1}, the code plays a separate d-compatible forward game. This introduces a'_big (the forward game's N-side responses) as intermediaries that have no direct connection to a_init (the backward Spoiler's choices).

---

## 4. Concrete Recommendation

### 4.1 Primary Recommendation: Restructure e_n Construction to Match GHR93

Replace the d-compatible forward game approach (lines 1226-1247 of CaseAnalysis.lean) with the GHR93 U(B,A) transfer approach:

**Step A**: Establish N_r |= U(B,A)(a_{n-1})
- a_n is a point (Case II assumption)
- B = rank-r type of a_n, A = rank-r interval type of (a_{n-1}, a_n)
- alpha_n witnesses U(B,A) at alpha_{n-1}: B holds at alpha_n, A holds on (alpha_{n-1}, alpha_n)

**Step B**: Transfer U(B,A) via tau's formula preservation
- tau preserves rank-(r+4) formulas
- U(B,A) has rank r+1 <= r+4
- So M_r |= U(B,A)(resp_tau(n-1))

**Step C**: Extract the witness
- From U(B,A)(resp_tau(n-1)), get z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z)
- Set e_n = z

**Step D**: The sel-vs-p_n ordering now follows trivially
- For k < n: resp_tau(k) <= resp_tau(n-1) < e_n (from tau ordering + z > resp_tau(n-1))
- For k < n: a_init(k) < extendPoint p_n (from strict ordering assumption)
- The iff `(a_init(k) < p_n <-> resp_tau(k) < e_n)` is `(True <-> True)`
- The iff `(a_init(k) = p_n <-> resp_tau(k) = e_n)` is `(False <-> False)`

### 4.2 What This Approach Requires

1. **Strict ordering assumption**: GHR93 assumes x' < a_0 < ... < a_n < y'. Our game definition allows non-strict selections. However, this is fine because `same_order_type` in the winning condition only requires ORDER PRESERVATION, not strict ordering. If a_k = a_n, the tau game would give resp_tau(k) = resp_tau(n-1), and we'd need resp_tau(k) = e_n. But since e_n > resp_tau(n-1) = resp_tau(k), this is `False <-> False` (since a_k = a_n would require resp_tau(k) = e_n, which is false). So actually for the equality case we need to show: if a_init(k) = extendPoint p_n, then resp_tau(k) = e_n. But resp_tau(k) <= resp_tau(n-1) < e_n, so resp_tau(k) != e_n. And by the tau game's ordering preservation, if a_init(k) = a_init(n-1) then resp_tau(k) = resp_tau(n-1), and since resp_tau(n-1) < e_n, resp_tau(k) != e_n. For the N-side, a_init(k) = extendPoint p_n means a_k = a_n. But a_n was the (n+1)-th selection and a_k is the (k+1)-th, and they are the same. The tau game maps equal N-elements to equal M-elements, but resp_tau(k) corresponds to a_init(k) in the tau game (not to a_n). So if a_init(k) = a_n = extendPoint p_n, then resp_tau(k) should match any position mapped to a_n in a game including it. Since tau doesn't include a_n, we can't directly conclude. However, if a_init(k) = a_n, then tau maps a_k to resp_tau(k), and the U(B,A) construction gives e_n > resp_tau(n-1). If a_init(k) = a_n, tau ordering gives resp_tau(k) = resp_tau(n-1) (since a_k = a_n ≥ a_{n-1}, and tau preserves ordering). Wait -- a_init maps k to a_bwd(k) for k < n, and a_init(n-1) = a_bwd(n-1). If a_init(k) = a_bwd(n) = extendPoint p_n, then a_bwd(k) = a_bwd(n). By tau ordering: (a_init(k) < a_init(n-1) <-> resp_tau(k) < resp_tau(n-1)) and (a_init(k) = a_init(n-1) <-> resp_tau(k) = resp_tau(n-1)). Since a_init(k) = a_bwd(n) >= a_init(n-1) = a_bwd(n-1) (from the ordering among the backward selections), we get resp_tau(k) >= resp_tau(n-1). Then e_n > resp_tau(n-1) >= resp_tau(k), so... wait, this gives e_n > resp_tau(n-1) but resp_tau(k) >= resp_tau(n-1), so resp_tau(k) could be > resp_tau(n-1) too. We'd need resp_tau(k) < e_n.

   **Resolution**: The equality case `a_init(k) = extendPoint p_n` implies a_init(k) >= a_init(n-1) (since a_bwd(n) >= a_bwd(n-1) from their interval containment). Then resp_tau(k) >= resp_tau(n-1) by tau ordering. But also, U(B,A)(resp_tau(n-1)) gives a witness z = e_n > resp_tau(n-1). We need z > resp_tau(k) too. This is NOT guaranteed by the U(B,A) witness alone when resp_tau(k) > resp_tau(n-1).

   **This reveals a subtlety**: The GHR93 approach assumes strict ordering x' < a_0 < ... < a_n < y', which ensures a_k < a_n for all k < n, hence resp_tau(k) < resp_tau(n-1) for all k < n-1. In our code, if we don't enforce strict ordering, a_init(k) could equal a_n, giving resp_tau(k) >= resp_tau(n-1), and then e_n > resp_tau(n-1) doesn't guarantee e_n > resp_tau(k).

   **Fix**: Either (a) enforce strict ordering (GHR93 does this), or (b) handle the degenerate case separately (if a_init(k) = a_n, the ordering `a_init(k) < p_n` is False, and we need resp_tau(k) < e_n to also be False or resp_tau(k) = e_n to be False; since resp_tau(k) >= resp_tau(n-1) and e_n > resp_tau(n-1), we'd need resp_tau(k) = resp_tau(n-1) to conclude resp_tau(k) < e_n). In practice, the same_order_type grid only asks about `a_init(k) < p_n <-> resp_tau(k) < e_n`. If a_init(k) = p_n, then `a_init(k) < p_n` is False, and we need `resp_tau(k) < e_n` to also be... wait, no. We need `a_init(k) < p_n <-> resp_tau(k) < e_n`, so if a_init(k) = p_n (hence not < p_n), we need resp_tau(k) >= e_n, which contradicts e_n > resp_tau(n-1) >= resp_tau(k) unless resp_tau(k) = resp_tau(n-1) and e_n > resp_tau(n-1). So resp_tau(k) < e_n is True but a_init(k) < p_n is False -- the iff FAILS.

   **This means the strict ordering assumption IS needed.** We must ensure a_init(k) < a_n for all k < n. GHR93 gets this from x' < a_0 < ... < a_n < y'. In our code, this follows from the fact that same_order_type already requires the ordering to be preserved, so if Spoiler's selections are not strictly increasing, Duplicator's responses aren't either, and the winning condition handles it. But actually, Spoiler's selections CAN have repeats in our formulation.

   **Practical resolution**: We can use `pivot_chain_order'` through the intermediate point resp_tau(n-1)/a_init(n-1), since tau gives the sel-vs-sel(n-1) ordering, and the U(B,A) construction gives resp_tau(n-1) < e_n and a_init(n-1) < a_n (the latter from U(B,A) being witnessed by a_n which is strictly above a_{n-1}). This chains as: a_init(k) vs a_init(n-1) (from tau) composed with a_init(n-1) < a_n (from U(B,A) witness). But we need the iff, not just one direction.

2. **Formula materialization**: The U(B,A) transfer requires either materializing U(B,A) as a StaviFormula and using the tau game's formula agreement, or working at the semantic level with the tau game's winning condition.

3. **The existing d-compatible forward game infrastructure becomes unnecessary for Case II**. It would still be used for Claim 1 (d-consistency) and potentially Cases III/IV.

### 4.3 Alternative: Augmented Forward Game (Keep Current Architecture)

If restructuring e_n's construction is too invasive, an alternative is to modify the d-compatible forward game to include the a_init positions. Specifically:

- Pad a_pad_big to include BOTH resp_tau(0),...,resp_tau(n-1) AND a_init(0),...,a_init(n-1) as selections (mapped through the forward game)
- This would give ordering between a_init(k) and p_n directly from the forward game's winning condition

However, this requires (2n + 2) positions in the forward game (n from resp_tau, n from a_init, plus c and possibly others), which must fit within the (1+3n+1)-round budget. For n >= 1, 1+3n+1 = 3n+2, and we need 2n+2 selection slots. Since 2n+2 <= 3n+2 for n >= 0, this fits.

The challenge is that the N-side responses a'_big would need to recover a_init from the winning condition. This seems circular -- a_init are Spoiler's choices, not Duplicator's.

Actually, this won't work. In the forward game, Spoiler plays from M and Duplicator responds from N. So Spoiler plays resp_tau(k) (M-elements) and Duplicator responds with a'_big(k) (N-elements). We'd need a'_big(k) = a_init(k) for the ordering to transfer, but there's no reason the forward game's response at resp_tau(k) would equal a_init(k).

### 4.4 Alternative: Chain Through resp_tau(n-1)/a_init(n-1)

Instead of restructuring the e_n construction, add a `pivot_chain_order'` through the n-1 position:

For `(a_init(k) < p_n <-> resp_tau(k) < e_n)`:
- Chain: a_init(k) vs a_init(n-1) (from tau) + a_init(n-1) vs p_n (needed) → a_init(k) vs p_n
- Chain: resp_tau(k) vs resp_tau(n-1) (from tau) + resp_tau(n-1) vs e_n (needed) → resp_tau(k) vs e_n

So we need: `(a_init(n-1) < p_n <-> resp_tau(n-1) < e_n)`.

If e_n is constructed via U(B,A) at resp_tau(n-1), then resp_tau(n-1) < e_n is simply True. And a_init(n-1) < p_n would need to also be True (which holds if p_n witnesses U(B,A) at a_init(n-1), meaning p_n > a_init(n-1)).

In GHR93, a_n > a_{n-1} always holds (strict ordering). In our code, this is hd_le_an (d <= a_n) plus the ordering of a_bwd. If the selections are increasing (as in GHR93), a_bwd(n-1) < a_bwd(n) gives a_init(n-1) < p_n.

The equality case: a_init(n-1) = p_n would mean a_bwd(n-1) = a_bwd(n). Then resp_tau(n-1) vs e_n: if e_n = U(B,A) witness above resp_tau(n-1), then resp_tau(n-1) < e_n is True, but a_init(n-1) = p_n means a_init(n-1) < p_n is False. Contradiction in the iff. So this case must be ruled out or handled separately.

**This confirms**: the GHR93 approach fundamentally relies on strict ordering of selections. The restructured proof should either enforce strict ordering or handle the degenerate case (a_init(k) = p_n) separately.

---

## 5. Recommended Implementation Plan

### Phase 1: Restructure e_n Construction (~150-200 lines)

1. **Remove** the d-compatible forward game approach for e_n (lines 1226-1289 of CaseAnalysis.lean)
2. **Add** U(B,A) transfer through tau:
   - Show N_r |= U(B,A)(a_init(n-1)) where a_n witnesses it
   - Transfer via tau to M_r |= U(B,A)(resp_tau(n-1))
   - Extract witness z: set e_n = extendPoint z
3. **Derive** formula agreement between e_n and a_n from B = X_{a_n}
4. **Derive** ordering: resp_tau(n-1) < e_n (from U witness)

This requires:
- StaviFormula representation for U(B,A) or semantic-level Until transfer
- tau's rank-(r+4) formula preservation (already in SplitPointProps via the game rank)

### Phase 2: Replace Same-Order-Type Grid Dispatch (~50 lines)

With resp_tau(n-1) < e_n established:
1. For k < n-1: chain resp_tau(k) < resp_tau(n-1) < e_n (tau ordering + transitivity)
2. For k = n-1: resp_tau(n-1) < e_n directly
3. For the N-side: if a_init(k) < a_init(n-1) < p_n (from ordering of selections and U(B,A) witness), the iff holds
4. Handle the degenerate equality cases by showing they reduce to False <-> False

### Phase 3: Handle the n=0 Edge Case (~30 lines)

When n = 0, there are no tau selections (a_init is empty). The e_n construction via U(B,A) uses a_{-1} = d-bar and e_{-1} = c (as GHR93 specifies on p.118: "if n=0 we take alpha_{-1} to be d-bar and e_{-1} to be c"). The sel-vs-p_n ordering vacuously holds (no k < 0 exists).

### Alternative Quick Fix: Keep Forward Game, Add Explicit Game

If the U(B,A) restructure is too complex, keep the current forward-game construction but add a NEW game that includes both a_init positions and p_n:

- Play the forward game with selections (a_init(0),...,a_init(n-1), c) on the N-SIDE (reversed game direction)
- This gives M-side responses including one for p_n
- The winning condition then provides the sel-vs-p_n ordering

However, this is mathematically unsound in the current game direction (the forward game goes M->N, not N->M), so it would require an additional game inversion.

---

## 6. Summary

| Question | Answer |
|----------|--------|
| How does GHR93 handle a_n vs tau ordering? | Through the U(B,A) Until formula transfer; e_n is a witness ABOVE e_{n-1}, making e_k < e_n automatic |
| Does GHR93 use a single comprehensive game? | No. It uses tau for positions 0..n-1, then constructs e_n separately via Until |
| Does GHR93 prove the ordering separately? | No. It falls out from strict ordering of selections + transitivity through e_{n-1} |
| Does our proof structure match the literature? | NO. Our e_n is from a forward game; GHR93's e_n is from U(B,A) transfer |
| What is the root cause of the gap? | Wrong e_n construction: forward game gives a'_big != a_init; GHR93's U(B,A) gives e_n > e_{n-1} directly |
| What should we do? | Restructure e_n construction to use U(B,A) transfer through tau, matching GHR93 |
