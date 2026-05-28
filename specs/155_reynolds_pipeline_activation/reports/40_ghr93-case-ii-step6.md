# GHR93 Case II: Precisely What Is the Response for Position n?

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Resolve exactly how GHR93 constructs the Duplicator response for the distinguished element a_n = p_n in Case II, and how the ordering condition is established.

---

## 1. Direct Answer: GHR93 Uses z (the U(B,A) Witness) as e_n

**The response for position n is z, the witness extracted from U(B,A) transfer through tau.** It is NOT the forward-game image of p_n. Here is the verbatim text from report 22, Section 3 (extracted from GHR93 pp.117-118):

> "Now clearly N_r |= U(B, A)(alpha_{n-1}): alpha_n is a witness to this. [...] U(B, A) has rank r+1, so as tau preserves formulas up to rank r+4, M_r |= U(B, A)^mu(e_{n-1}). Hence there is z > e_{n-1} in M with M |= B(z) and M |= A(t) for all t in (e_{n-1}, z). But e_{n-1} < b. Hence we can assume that z < b. **Duplicator defines e_n to be such a z**, completing her move."

The construction is:

1. tau gives resp_tau(0), ..., resp_tau(n-1) (responses for a_0, ..., a_{n-1})
2. N_r |= U(B, A)(a_{n-1}), because a_n witnesses it (B holds at a_n, A holds on (a_{n-1}, a_n))
3. tau preserves rank-(r+4) formulas; U(B,A) has rank r+1 <= r+4
4. Therefore M_r |= U(B, A)(resp_tau(n-1))
5. Unpack the Until: there exists z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z)
6. **Set e_n = z**

The forward game (h_fwd_n1) is NOT used to produce e_n. It is used only for the d-consistency argument (Claim 1) and strategy restriction.

---

## 2. How GHR93 Establishes the Ordering resp_tau(k) < e_n

**The ordering is trivial from the construction. It does NOT require a separate argument.**

Here is why:

- resp_tau(k) for k < n are responses from tau applied to a_0, ..., a_{n-1}
- tau plays on [d-bar, y'] / [c, y], producing responses in [c, y] (actually [c, b] per GHR93)
- tau's winning condition gives: a_0 < a_1 < ... < a_{n-1} correspond to resp_tau(0) < resp_tau(1) < ... < resp_tau(n-1) (same order type)
- In particular, resp_tau(n-1) is the LARGEST of the tau responses
- e_n = z > resp_tau(n-1) by construction (z is the U(B,A) witness, which satisfies z > e_{n-1} = resp_tau(n-1))
- Therefore resp_tau(k) <= resp_tau(n-1) < e_n for all k < n

**The ordering resp_tau(k) < e_n follows from the chain:**
```
resp_tau(k) ≤ resp_tau(n-1) < z = e_n
```

The first inequality is from tau's order preservation. The second is the defining property of the U(B,A) witness.

**There is no need for U(B,A) to establish this ordering separately.** The ordering is an immediate consequence of the Until witness being above the reference point resp_tau(n-1).

---

## 3. What U(B,A) Is Used For

U(B,A) serves **two** purposes in GHR93 Case II:

### Purpose 1: Constructing e_n itself
The Until formula provides the existence of a point z > resp_tau(n-1) with:
- B(z): z has the same rank-r type as a_n (so e_n and a_n agree on all rank-r formulas)
- A on (resp_tau(n-1), z): interval-type agreement between (resp_tau(n-1), e_n) in M and (a_{n-1}, a_n) in N

### Purpose 2: Interval decomposition for Round 2
The A-holding condition on (resp_tau(n-1), e_n) is used directly in Step 4.6 (round 2 verification). When Spoiler challenges with t in (resp_tau(n-1), e_n), GHR93 says:

> "If t in (e_{n-1}, e_n) then M |= A(t). By definition of A there is t' in (alpha_{n-1}, alpha_n) with N |= X_{t'}(t). Duplicator can then choose any such t' as her response."

So A holding on the interval is what makes the round-2 response possible for challenges in the (e_{n-1}, e_n) sub-interval.

**U(B,A) is NOT used for Cases III/IV.** Those cases use different formulas:
- Case III: left(B, D) -- gap detection formula, rank r+2
- Case IV: A and not-D and U(right(B,D), A) -- compound formula, rank r+3

---

## 4. What Happens to e_n from the Forward Game?

**GHR93 does NOT use a forward-game-produced e_n at all in Case II.**

The forward game is used in GHR93 for:
1. **Claim 1**: Proving d-consistency (the response to c must be d-bar)
2. **Claim 2 / Strategy restriction**: Getting sub-interval forward strategies, which the IH converts to sigma and tau

After sigma and tau are obtained, the forward game plays no further role in Case II. The element e_n is constructed entirely from tau's formula transfer capability plus the semantic content of U(B,A).

**The Lean code's old approach (lines 1244-1550 of CaseAnalysis.lean) was incorrect.** It constructed e_n by playing the forward game with resp_tau selections plus c, then challenging with p_n in round 2 to get e_n_pt. This is NOT what GHR93 does. The old approach produced an e_n that:
- Has rank-r formula agreement with p_n (correct, from the forward game winning condition)
- Has ordering compatibility via the forward game's order-type preservation (partially correct)
- But required complex machinery (d-compatible strategies, big-game orderings) that GHR93 does not need

---

## 5. The Rank Requirement and Why tau at Rank r Fails

### GHR93's rank structure
- Forward game: rank r+4(n+1)
- IH applied at base rank r+4: backward games at rank r+4
- sigma, tau: rank r+4
- U(B,A) has rank r+1
- Transfer via tau: r+1 <= r+4, so it works

### Current Lean code's rank structure
- Forward game: rank r (or rank r with h_fwd_r1 at rank r+2)
- sigma, tau: rank r+delta (with delta parameter, currently used as delta=0 in some places, delta=2 in others)
- If tau is at rank r: CANNOT transfer U(B,A) at rank r+1 (r+1 > r)
- If tau is at rank r+2 (via tau_r2): CAN transfer U(B,A) at rank r+1 (r+1 <= r+2)

**The fundamental issue**: The Lean code's tighter rank bounds mean that getting a FULL rank-r type formula B = X_{a_n} requires a formula of Stavi depth approximately 2r (due to nf_characterizable_by_stavi building formulas with depth ~2k). This makes U(B, sf_top) have depth ~2r+1, which cannot be transferred through tau at rank r+2.

Report 38 documents this "depth-agreement gap" in detail. The resolution paths are:
1. **Path B (recommended by report 39)**: Restructure the induction to give sigma/tau at rank r+4, matching GHR93
2. **Path C**: Use strategy composition (Proposition 12.8.18) to avoid the U(B,A) transfer entirely
3. **Path D**: Find a bridge from k_nf-depth agreement to rank-r agreement

---

## 6. Summary of Answers

### Q1: What is GHR93's response for position n?
**z, the U(B,A) witness.** Not e_n from the forward game. The forward game is not used for e_n construction in Case II. GHR93 constructs e_n entirely from the formula U(B,A) transferred through tau.

### Q2: How does GHR93 prove sel_pn_ord (resp_tau(k) < e_n)?
**It is trivial.** z > resp_tau(n-1) >= resp_tau(k) by construction. The Until witness z is defined to be above resp_tau(n-1) = e_{n-1}, and tau's order preservation gives resp_tau(k) <= resp_tau(n-1). No separate ordering argument is needed.

### Q3: Is U(B,A) used for sel_pn_ord?
**No.** U(B,A) is used to (a) construct e_n and (b) establish interval-type agreement for round-2 responses. The ordering is a free consequence of the witness definition.

### Q4: If z is the response, what happens to e_n from the forward game?
**There is no e_n from the forward game.** GHR93 never plays the forward game with p_n as a challenge point. The forward game produces c and d (via Claim 1), then sigma and tau (via Claim 2 + IH). After that, e_n is built from scratch using U(B,A) transfer through tau.

### Q5: What is GHR93's argument for resp_tau(k) < e_n?
The chain is:
```
resp_tau(k) ≤ resp_tau(n-1)    [tau preserves order: a_k < a_{n-1} implies resp(k) < resp(n-1)]
resp_tau(n-1) < z = e_n        [z is the Until witness: exists z > e_{n-1}]
```
Both steps follow directly from existing definitions with no additional proof work.

---

## 7. Implications for the Lean Implementation

### Current code architecture (old approach, lines 1244-1550)
The old Case II proof:
1. Plays the d-compatible forward game with resp_tau plus c
2. Challenges with p_n to get e_n_pt
3. Extracts ordering via big-game order preservation
4. Builds tau_r2, tau_left, tau_right, tau_composed for sub-interval games
5. Uses resp_mod (modified response function) for the equality case

This is architecturally wrong -- it does not follow GHR93 and introduces unnecessary complexity (600+ lines of ordering bookkeeping).

### Correct architecture (GHR93-faithful)
The correct Case II proof should:
1. Apply tau to a_0, ..., a_{n-1} to get resp_tau(0), ..., resp_tau(n-1)
2. Show U(B, A)(a_{n-1}) in N (a_n witnesses it)
3. Transfer U(B, A) to resp_tau(n-1) via tau's formula preservation at rank >= r+1
4. Extract witness z; set e_n = z
5. Return response (resp_tau(0), ..., resp_tau(n-1), e_n)
6. Verify round-2 winning condition by case split on b_sp position

**The blocker**: Step 3 requires tau at rank >= r+1. Currently tau is at rank r+delta. With delta >= 2 (ensured by `hd : 2 <= delta` in the current signature), tau is at rank r+2, which suffices for transferring U(B,A) at rank r+1. The remaining issue is materializing the "full rank-r type formula" B = X_{a_n} as a Stavi formula -- the depth-agreement gap documented in report 38.

### Two resolution paths
1. **Raise delta to 4** (matching GHR93): Eliminates the depth-agreement gap entirely. B at depth r, U(B,A) at depth r+1 <= r+4. Requires restructuring the induction (report 39).
2. **Use char_k approximation**: B at depth k_nf < r, U(B, sf_top) at depth <= r, transferable through tau at rank r+delta (delta >= 2). Produces only k_nf-depth agreement, not full rank-r agreement. Requires a bridge argument (report 38 Path D) or composition approach (report 38 Path C).
