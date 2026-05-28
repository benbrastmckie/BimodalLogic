# Teammate A: GHR93/GHR94 Literature Extraction for Until Witness Containment

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Extract the exact textbook argument for Until witness containment and sel_pn_ord from GHR93 Section 8 / GHR94 Chapter 12.

---

## 1. The Exact Textbook Argument for Containment

### 1.1 Verbatim from GHR94 Chapter 12, p.806

> Define $B = X_{a_n}$, and $b = \sup\{t \in (x, y) : M \models B(t)\} \in M_r$ (as before, either $b \in M$, $b = y$ or $b$ is an $r$-definable gap, defined on the right by $\sim B$). Define $b' \in N_r$ similarly. Then, clearly, $b' > a_n$.
>
> [...] So by the induction hypothesis $(*)_n$ she has a winning strategy $\tau$ for $G_{n, r+4}(N, c'b'; M, cb)$.
>
> Let her first use $\tau$ in response to $a_0, \ldots, a_{n-1}$. It delivers $n$ points $e_0, \ldots, e_{n-1} \in (c, b)_r$ [...] $M_r \models U(B, A)^\#(e_{n-1})$. Hence there is $z > e_{n-1}$ in $M$ with $M \models B(z)$ and $M \models A(t)$ for all $t \in (e_{n-1}, z)$. But $e_{n-1} < b$. Hence we can assume that $z \leq b$. $\exists$ defines $e_n$ to be such a $z$, completing her move.

### 1.2 The Containment Argument Unpacked

The GHR93/GHR94 argument for "we can assume z <= b" has THREE structural prerequisites:

**Prerequisite 1: The supremum b exists.**
GHR94 defines `b = sup{t in (x,y) : M |= B(t)}`. This supremum exists and is in M_r because B = X_{a_n} is a rank-r type formula, and by GHR93's general theory (Lemma 8.6 / 12.8.10), the supremum of a rank-r definable set is either an actual point, the endpoint y, or an r-definable gap. In all cases, b belongs to M_r (the extended carrier at rank r).

**Prerequisite 2: tau is played on [c', b'] -> [c, b], NOT on [c', y'] -> [c, y].**
This is critical. GHR94 defines tau as a winning strategy for `G_{n, r+4}(N, c'b'; M, cb)`. The interval endpoints are c and b (not c and y). Consequently, tau's responses e_0, ..., e_{n-1} are all in (c, b)_r. In particular, e_{n-1} < b.

**Prerequisite 3: z <= b by the supremum property.**
The Until witness z satisfies B(z), i.e., M |= X_{a_n}(z). Since b = sup{t in (x,y) : M |= B(t)}, if z is in (x, y), then z <= b. But we need z to be in (x, y) first.

The actual argument proceeds:
1. U(B,A)(e_{n-1}) holds in M_r. The Until semantics give: there exists z > e_{n-1} with mu_holds(z), B(z), and A on (e_{n-1}, z).
2. This z is in the FULL extended carrier M_r, not necessarily in (x, y).
3. However, since B = X_{a_n} defines the rank-r type of a_n, and B holds at z, the point z has the same rank-r type as a_n.
4. Since b = sup{t in (x,y) : M |= B(t)} and b is in M_r, we know that B-satisfying points exist in (x, y) (because a_n is such a point on the N side, and by formula transfer and structure theory, corresponding points exist on the M side below b).
5. The argument "we can assume z <= b" means: AMONG the witnesses z' > e_{n-1} satisfying U(B,A), we can choose one with z' <= b. This is possible because B-satisfying points exist in (e_{n-1}, b] (since e_{n-1} < b and points satisfying B accumulate up to b from below).
6. More precisely: if the first z from the existential is z0 > b, we can instead pick a DIFFERENT z' in (e_{n-1}, b] that still satisfies B. The Until property A on (e_{n-1}, z') is satisfied because (e_{n-1}, z') is a subset of (e_{n-1}, z0), and A held on the larger interval.

**Key insight**: The containment argument in GHR93 is NOT automatic from the Until witness. It requires the SUPREMUM b as an intermediate concept. The text "we can assume z <= b" is a non-trivial replacement of the raw Until witness with a better-positioned witness.

### 1.3 Why the Lean Formalization Lacks This

The Lean formalization (SplitPointProps) does NOT define or use the supremum b. Instead:

- tau plays on `[d, y'] -> [c, y]` (Lean's SplitPointProps.tau, line 97-101 of SplitPoint.lean)
- This is the FULL right sub-interval, not the restricted interval [c', b'] -> [c, b]
- The responses e_0, ..., e_{n-1} = resp_tau are in [c, y]
- There is no b to bound the Until witness

The consequence: `untl_extract_witness` returns z in `ExtendedCarrier M atomMap r` (the full structure). There is no guarantee that z is in [c, y], let alone in [x, y]. The witness z could be above y.

---

## 2. Does GHR93 Play Games on Sub-Intervals or the Full Structure?

### 2.1 Games ARE Played on Sub-Intervals

The `ghr93_duplicator_wins` definition (CustomGame.lean lines 285-303) makes this completely clear:

```lean
def ghr93_duplicator_wins ... (x y : ExtendedCarrier M atomMap r)
    (x' y' : ExtendedCarrier N atomMap r) : Prop :=
  forall (a : Fin n -> ExtendedCarrier M atomMap r),
    (forall i, inClosedInterval x y (a i)) ->  -- Spoiler picks from [x,y]
    exists (a' : Fin n -> ExtendedCarrier N atomMap r),
      (forall i, inClosedInterval x' y' (a' i)) /\  -- Duplicator responds in [x',y']
      ...
```

Spoiler picks from [x,y], Duplicator responds in [x',y']. The game tuple endpoints are x, y, x', y'. All elements are constrained to the sub-interval.

### 2.2 Formula Evaluation Is on the FULL Structure

However, `stavi_temporal_truth_mu` (TypeFormulas.lean lines 304-363) evaluates formulas on the FULL ExtendedCarrier:

```lean
  | .std_untl A B =>
    exists s : ExtendedCarrier M atomMap r, t < s /\ mu_holds s /\ ...
```

The quantifier `exists s : ExtendedCarrier M atomMap r` ranges over ALL elements of the extended carrier, not just those in [x, y]. This is correct mathematical semantics -- temporal formulas are evaluated on the entire structure, not restricted to a sub-interval.

### 2.3 The Gap This Creates

When tau's winning condition gives formula agreement at a position t in [c, y]:
- The formula U(B,A) is among the agreed-upon formulas (if its depth <= r+delta)
- So U(B,A)(t) holds in M iff U(B,A)(corresponding position) holds in N
- But U(B,A)(t) = "exists z > t with B(z) and A on (t,z)" -- and z ranges over the ENTIRE structure

This means: the formula transfer through tau correctly establishes that U(B,A) holds at resp_tau(n-1) in M. But the witness z from unpacking this existential is unconstrained in the full structure. The Lean formalization does not have the GHR93 supremum infrastructure to "choose a better z."

---

## 3. The Exact Textbook Argument for sel_pn_ord

### 3.1 Verbatim Reconstruction

GHR93/GHR94 does NOT have a separate "sel_pn_ord" proof. The ordering resp_tau(k) < e_n follows trivially from the construction:

1. tau is played on [c', b'] -> [c, b]
2. tau's responses are e_0, ..., e_{n-1} in (c, b)_r
3. tau preserves order: a_0 < a_1 < ... < a_{n-1} correspond to e_0 < e_1 < ... < e_{n-1}
4. e_n = z > e_{n-1} by the Until witness property (z > e_{n-1} is part of the existential)
5. Therefore: e_k <= e_{n-1} < z = e_n for all k < n

The chain is:
```
resp_tau(k) <= resp_tau(n-1) < z = e_n
```

**First inequality**: From tau's same_order_type condition. Since a_init is monotone (from h_mono applied to the first n elements of a_bwd), tau's order preservation gives resp_tau monotone.

**Second inequality**: From the Until witness: z > resp_tau(n-1) = e_{n-1}.

### 3.2 Status in the Lean Formalization

This argument works identically in the Lean code. It does NOT depend on the containment issue. Even if z is not in [x, y], we still have resp_tau(k) < z = e_n. The sel_pn_ord is genuinely trivial.

The problem is not sel_pn_ord itself, but rather that e_n must also satisfy `inClosedInterval x y e_n` for the final response to be valid. This is the containment issue, which is separate from ordering.

### 3.3 Does sel_pn_ord Require tau_left?

No. Report 40 is correct: sel_pn_ord does NOT require tau_left or any sub-interval decomposition. It follows directly from:
1. Tau's order preservation (resp_tau is monotone because a_init is monotone)
2. The Until witness being above resp_tau(n-1)

The current code's use of tau_left for sel_pn_ord (lines 1392-1414, 1415-1439 of CaseAnalysis.lean) is an artifact of the forward-game approach, not a necessity. The GHR93 rewrite eliminates this entirely.

---

## 4. Evaluation of the Three Mitigation Paths (Report 45, Section 8.1)

### 4.1 Path 1: Use forward game for existence, U(B,A) for formulas

**Report 45 recommends**: "Use the forward game (h_fwd_n1 or h_d_compat_left) to establish that there exists a type-matching point in [c, y], then separately show it satisfies the U(B,A) properties."

**Evaluation**: This is SOUND but NOT GHR93-faithful. The forward game gives e_n in [x, y] by construction (the game constrains responses to the interval). U(B,A) then provides the formula/interval-type data. The hybrid approach works because:
- e_n from the forward game is guaranteed to be in [x, y]
- e_n from the forward game has rank-r formula agreement with a_n (from the forward game winning condition)
- U(B,A) interval data can be obtained separately to simplify Round 2

**Risk**: This re-introduces dependency on the forward game for e_n construction, which is what the GHR93 rewrite was trying to eliminate. However, the forward game would be used in a much simpler way (just for existence, not for the complex a_pad_big construction).

### 4.2 Path 2: Prove witness is in [c, y] by structural argument

**Report 45 proposes**: "The tau game ensures that the formula content of [d, y'] is faithfully transferred to [c, y], so the Until witness must exist within [c, y]."

**Evaluation**: This is the GHR93-faithful approach, but it requires the supremum b. The argument is:
1. Define b = sup{t in (x,y) : M |= B(t)} (or equivalently, b = sup{t in [c,y] : M |= B(t)})
2. Show b exists in M_r (using the supremum lemma from GHR93 Lemma 8.6)
3. Show e_{n-1} < b (because tau plays on [c, b] or because B-satisfying points exist above e_{n-1})
4. Choose z <= b from among the Until witnesses

**The fundamental difficulty**: The Lean formalization does NOT have the supremum infrastructure. Specifically:
- `RDefinableGap` exists but there is no "supremum of a definable set" lemma
- The Lean code would need to construct b as either an actual point, y, or an r-definable gap
- This would require new infrastructure (~100-200 lines) establishing that the supremum of a rank-r definable set is in M_r

This is feasible but represents significant new infrastructure that does not exist in the codebase.

### 4.3 Path 3: Retain forward game for existence, simplify everything else

**Report 45's "worst case"**: "Retain the forward-game e_n for EXISTENCE but use U(B,A) for FORMULA properties."

**Evaluation**: This is essentially Path 1. It is the most pragmatic approach. The simplification gains from eliminating resp_mod, tau_left, tau_right, and the complex ordering bookkeeping are still realized. The forward game provides e_n in [x, y], and U(B,A) provides:
- The formula agreement between e_n and a_n (from B = X_{a_n})
- The interval-type agreement on (e_{n-1}, e_n) (from A = X_{(a_{n-1}, a_n)})
- The ordering sel_pn_ord (trivially, from resp_tau monotonicity + e_n above resp_tau(n-1))

The net benefit: ~400-500 lines of deletion (resp_mod, tau_left, tau_right, complex ordering), replaced by ~100-150 lines of U(B,A) formula construction and transfer, plus the existing forward game (retained, possibly simplified).

---

## 5. Literature Proof Structure

**Source**: GHR94 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 12, pp.792-810, Case II
**GHR93**: Section 8, pp.117-118

### Step Map

1. **Define B and supremum points b, b'** -- [GHR94] p.792 definition of $b = \sup\{t \in (x,y) : M \models B(t)\}$
   - B = X_{a_n} (rank-r type formula for a_n)
   - b is in M_r: either an actual point, y, or an r-definable gap
   - b' > a_n (since B holds at a_n)

2. **Restrict forward strategy to [c,b] x [c',b']** -- [GHR94] p.794, Claim 1 + strategy restriction
   - Play forward game with b and c among Spoiler's choices
   - Duplicator responds with b' and c'
   - Restrict to sub-interval [c,b] x [c',b']

3. **Apply IH to get tau on [c',b'] -> [c,b]** -- [GHR94] p.794
   - tau: G_{n, r+4}(N, c'b'; M, cb)
   - Key: tau is on the RESTRICTED interval [c,b], not [c,y]

4. **Play tau on a_0, ..., a_{n-1}** -- [GHR94] p.796-802
   - Delivers e_0, ..., e_{n-1} in (c, b)_r
   - In particular, e_{n-1} < b

5. **Transfer U(B,A) through tau** -- [GHR94] p.806
   - N_r |= U(B,A)(a_{n-1}): a_n witnesses it
   - U(B,A) has rank r+1 <= r+4, so transferable through tau
   - M_r |= U(B,A)(e_{n-1})

6. **Extract witness z and CHOOSE z <= b** -- [GHR94] p.806
   - Until gives z > e_{n-1} with B(z) and A on (e_{n-1}, z)
   - Since e_{n-1} < b and B(z) holds, we can choose z <= b
   - Set e_n = z
   - **THIS STEP REQUIRES THE SUPREMUM b**

7. **Verify Round 2 winning condition** -- [GHR94] p.808
   - 5-way case split on Spoiler's challenge position

### Formalization Gap

**Step 1 and Step 6 are the blockers.** The Lean formalization lacks:
- Step 1: Supremum infrastructure for rank-r definable sets
- Step 6: The ability to "choose z <= b" (requires knowing b exists and that B-satisfying points accumulate up to b)

The Lean formalization's SplitPointProps uses tau on [d, y'] -> [c, y] (step 3 uses the full interval, not the restricted one). This means step 4 gives e_{n-1} in [c, y] (not [c, b]), and step 6 cannot appeal to the supremum b to bound z.

---

## 6. Specific Answers to Research Questions

### Q1: How does the textbook handle containment of the Until witness?

The textbook introduces a SUPREMUM point b = sup{t in (x,y) : M |= B(t)}. The tau game is played on the restricted interval [c', b'] -> [c, b], so e_{n-1} < b. The Until witness z satisfies B(z), and since b is the supremum of B-satisfying points in (x,y), "we can assume z <= b." This is a CHOICE of witness, not an automatic property of the raw existential.

### Q2: Does GHR93 define Until semantics restricted to an interval?

No. Until semantics are on the FULL structure. GHR93/GHR94 page 806 says "there is z > e_{n-1} IN M" -- not "in [c, b]" or "in [x, y]". The containment z <= b comes from the supremum argument, not from restricted semantics.

### Q3: How does the textbook derive sel_pn_ord?

Trivially. It is an immediate consequence of tau's order preservation (resp_tau is monotone) combined with the Until witness being above resp_tau(n-1). No separate argument, no tau_left, no sub-interval decomposition. The chain is: resp_tau(k) <= resp_tau(n-1) < z = e_n.

### Q4: Are EF games played on the full linear order or on a sub-interval?

On a SUB-INTERVAL. The game `G_{n,r}(M, xy; N, x'y')` constrains Spoiler's picks to [x,y] and Duplicator's responses to [x',y']. However, FORMULA EVALUATION is on the full structure. This is the source of the containment issue: the game constrains element placement to the interval, but the Until formula's witness quantifier ranges over the full structure.

---

## 7. Recommended Resolution

### 7.1 Primary Recommendation: Hybrid Approach (Path 1/3)

Use the forward game (h_fwd_n1) to obtain e_n in [x, y] with formula agreement, then use U(B,A) for the interval-type data needed in Round 2. This avoids the need for supremum infrastructure while still simplifying the proof by ~400-500 lines.

Concretely:
1. Retain h_fwd_n1 or h_d_compat_left for e_n existence (e_n is in [x, y] by construction)
2. Construct B, A as CharacteristicFormula.lean provides
3. Transfer U(B,A) through tau for the interval-type agreement
4. Use the interval-type agreement for Round 2 Case B-interval (the (e_{n-1}, e_n) sub-case)
5. sel_pn_ord from resp_tau monotonicity + e_n from forward game ordering

### 7.2 Alternative: Full GHR93 Faithfulness (Path 2)

Requires building supremum infrastructure:
1. Lemma: sup of a rank-r definable set is in M_r
2. Define b = sup{t in (x,y) : M |= B(t)}
3. Prove b is in M_r
4. Restrict tau to [c', b'] -> [c, b] (or prove tau on [c', y'] -> [c, y] also works on [c', b'] -> [c, b] by monotonicity)
5. Use supremum to bound the Until witness

Estimated effort: ~200-300 lines of new infrastructure. This is the mathematically cleanest approach but has significant implementation cost.

### 7.3 NOT Recommended: Abandoning U(B,A) Entirely

The current forward-game-only approach (lines 1257-1439 of CaseAnalysis.lean) works but is 600+ lines of unnecessary complexity. Even with the containment issue, using U(B,A) for formula/interval-type data while keeping the forward game for existence is a significant net improvement.
