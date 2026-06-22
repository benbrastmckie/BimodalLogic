# K=0 Base Case Design Report

- **Task**: 305 - Rabinovich EA-formula implementation
- **Type**: lean4
- **Focus**: K=0 base case in `prior_nonconstenv_2var_agree_until` / `_since`
- **Date**: 2026-06-22

## Executive Summary

The K=0 base case is the last structural blocker in PriorComposition.lean. This report analyzes the exact mechanism needed, compares with Rabinovich's paper, identifies why all existing approaches fail, and proposes a resolution.

**Key finding**: The K=0 problem is an artifact of the formalization's induction structure (strong induction on NF depth K), not present in Rabinovich's paper (which inducts on witness count n). The fundamental gap is **depth-0 between-zone predicate witness transfer**: given y in M with t < y < x and specific predicates, finding y' in N with t' < y' < x' and the same predicates. This requires encoding "between two endpoints" as a transferable property, which single-endpoint 1-var NF agreement cannot express.

---

## 1. Lean Code Analysis: Exact Proof State at K=0

### 1.1 Sorry Site Locations

| Line | Theorem | Goal |
|------|---------|------|
| 869 | `prior_nonconstenv_2var_agree_until` | depth-1 2-var at [x,t]/[x',t'] (Until: t < x) |
| 964 | `prior_nonconstenv_2var_agree_since` | depth-1 2-var at [x,t]/[x',t'] (Since: x < t) |

Both sorry sites have identical structure (modulo order direction). The exact goal at line 869:

```
⊢ ∀ (nf : NormalForm sig (0 + 1) 2),
    nf_eval_nf M (0 + 1) 2 envM_xt nf ↔ nf_eval_nf N (0 + 1) 2 envN_xt nf
```

### 1.2 Available Hypotheses at K=0

```
h_x : ∀ nf : NormalForm sig (0 + 2) 1,
    nf_eval_nf M 2 1 (fun _ => x) nf ↔ nf_eval_nf N 2 1 (fun _ => x') nf
h_t : ∀ nf : NormalForm sig (0 + 2) 1,
    nf_eval_nf M 2 1 (fun _ => t) nf ↔ nf_eval_nf N 2 1 (fun _ => t') nf
h_order_M : t < x
h_order_N : t' < x'
h_UZ_M/N : semantic_prior_UZ M/N atomMap
h_SZ_M/N : semantic_prior_SZ M/N atomMap
char_fn : (d : Nat) → NormalForm sig d 1 → Formula
char_correct : ∀ d ≤ 1, ∀ nf_1 S h_UZ h_SZ t,
    temporal_truth S atomMap t (char_fn d nf_1) ↔ nf_eval_nf S d 1 (fun _ => t) nf_1
```

**Notably absent**: `ih_strong` (the strong induction hypothesis on K) is vacuous at K=0 because there is no m < 0.

### 1.3 Full Sorry Inventory in PriorComposition.lean

| Line | Location | Goal Summary | Root Cause |
|------|----------|-------------|------------|
| 507 | `nf_eval_from_lower_agree` d=0 | depth-1 n-var from depth-0 | depth-0 (n+1)-var exist transfer |
| 555 | `nf_eval_from_lower_agree` d>=1, n=0 | depth-(d+2) 0-var exist | degenerate empty env |
| 642 | `zone_compatible_witness` d=0 | depth-0 (r+1)-var exist | per-component to joint witness |
| 647 | `zone_compatible_witness` d=1 | depth-1 (r+1)-var exist | depends on line 507 |
| 658 | `zone_compatible_witness` d>=2, r=0 | depth-(d+2) 1-var exist, empty env | degenerate |
| 869 | `prior_nonconstenv_2var_agree_until` K=0 | depth-1 2-var agreement | between-zone transfer |
| 964 | `prior_nonconstenv_2var_agree_since` K=0 | depth-1 2-var agreement | between-zone transfer (mirror) |

**Dependency chain**: Lines 869/964 (K=0) → `prior_exist_transfer_bidir` at d=1 → `zone_compatible_witness` d=1 (line 647) → `nf_eval_from_lower_agree` d=0 (line 507). All are manifestations of the same root problem.

### 1.4 What K>=1 Does (Working Case)

At K>=1, `prior_nonconstenv_2var_agree_until` calls itself recursively at K-1:
```lean
| K' + 1 =>
    exact prior_nonconstenv_2var_agree_until atomMap h_surj K' M x t N x' t'
      ... h_x_weak h_t_weak h_order_M h_order_N char_fn char_correct_weak
```
This provides `h_agree_env` at depth-(K'+2) = depth-(K+1) 2-var. The quantifier conditions of this agreement give depth-K 3-var existential transfer, which `prior_exist_transfer_bidir` uses for the zone-3 witness placement.

---

## 2. Rabinovich Paper Analysis

### 2.1 Paper's Induction Structure

Rabinovich's proof does NOT use strong induction on NF depth. Instead:
- **Lemma 5.1** inducts on n = number of interval segments
- **Lemma 5.3** inducts on n = number of existential witnesses
- **Proposition 4.2/4.3** uses structural induction on formula complexity

### 2.2 How the Paper Handles the Base Case

At n=0 (zero witnesses), the EA formula is purely universal over a single interval. Its negation is a single existential, trivially V-EA. No Dedekind completeness or zone analysis needed.

At n=1 (one witness), the formula "not exists x_1 P_1(x_1)" reduces to "forall y, not P_1(y)". This is immediate.

**The paper never encounters a state where the inductive hypothesis is vacuous AND a nontrivial composition is needed.** The K=0 problem is an artifact of the formalization's choice of NF-depth induction.

### 2.3 Why the Formalization Diverges

The formalization uses NF-depth strong induction because:
1. The NF infrastructure (`nf_eval_nf`, `nf_characteristic`, etc.) is depth-indexed
2. The composition theorem (`exist_transfer_from_full_agree`) works at the NF level
3. The Prior-UZ/SZ zone mechanisms operate on temporal formulas via `char_fn`

The paper's witness-count induction avoids the depth-0 base case entirely because it works at the formula level (EA-formulas), not the NF level.

---

## 3. Comparison Table

| Aspect | Rabinovich 2014 | Lean Formalization | Gap |
|--------|----------------|-------------------|-----|
| Induction variable | n (witness count) | K (NF depth, strong) | Different structure |
| Base case | n=0: vacuously V-EA | K=0: ih_strong vacuous | Paper's base is trivial |
| Between-zone mechanism | Lemma 5.1 case decomposition | h_agree_env quantifier conditions | Formalization needs 2-var agreement |
| K=0 zone placement | Not applicable | MISSING (sorry) | Core gap |
| Zone-3 witness source | INF formula (eq 5.2) | prior_exist_transfer_bidir + zone_compatible_witness | Both use Prior-UZ/SZ |
| Depth-0 existential | Part of n=1 base case | Separate sorry chain (lines 507, 642, 647) | Formalization isolates this |

---

## 4. Depth-2 1-var Analysis: What h_t and h_x Provide

### 4.1 Structure of h_t (depth-2 1-var at t/t')

The depth-2 1-var NF at t has:
- **Atoms**: predicates of t
- **Quantifier**: for each depth-1 2-var NF chi, `(∃ y, nf_eval M 1 2 [y,t] chi) ↔ quant(chi)`

Each depth-1 2-var NF chi at [y,t] encodes:
- Atoms: preds(y), preds(t), order(y,t)
- Quantifier: depth-0 3-var existentials around [y,t]

So h_t transfers ALL depth-1 2-var existentials around t. Given w > t with specific properties, `cross_extend_bwd_1var` yields w1' > t' with depth-1 2-var agreement at [w,t]/[w1',t'].

### 4.2 What Transfers and What Doesn't

**Transfers from h_t**: "exists point above t with specific depth-1 2-var NF" (including predicates, order relative to t, and depth-0 3-var quant conditions relative to t).

**Does NOT transfer**: "exists point above t AND below x" -- because the depth-1 2-var NF at [w,t] encodes no information about x specifically. It may encode "exists x-type point above w" but that x-type point need not be x'.

**Transfers from h_x**: "exists point below x with specific depth-1 2-var NF" (symmetric).

**Combined**: We get w1' > t' with w's predicates (from h_t) and w2' < x' with w's predicates (from h_x). But w1' might be >= x' and w2' might be <= t'. No single point is guaranteed in (t', x').

### 4.3 The Depth Barrier

Encoding "between t and x" from t's perspective requires a formula like F(P ∧ F(Q_x))(t) = "exists P-point above t with Q_x-type above it." This has temporal depth 3 (F(F(Q_x)) = depth 1+1+1). But h_t provides only depth-2 agreement, insufficient for depth-3 formulas.

The general principle: expressing a relationship involving TWO reference points from ONE endpoint requires temporal nesting depth proportional to the number of reference points. With depth-2 1-var agreement, we can only transfer properties involving ONE reference point (the endpoint itself).

---

## 5. Analysis of Resolution Paths

### Path A: Restructure Induction to Avoid K=0

**Status**: NOT VIABLE.

All restructurings (ordinary induction, well-founded induction on depth, starting at K=1) converge to the same gap: at the lowest level, depth-0 multi-var existential transfer on non-constant environments requires more than endpoint 1-var agreements. The `nf_eval_from_lower_agree` d=0 sorry (line 507) is the irreducible core, and it appears in any architecture.

### Path B: Direct Depth-0 Zone Analysis

**Status**: NOT VIABLE as standalone.

The deleted theorems `depth0_3var_exist_transfer_until/since` were marked FALSE (line 191, with counterexample reference). On general linear orders, depth-2 1-var + matching orders does NOT imply depth-0 3-var zone-3 transfer. On Prior structures it should be true (Prior-UZ/SZ constrains zone occupancy), but the current mechanism (temporal formula transfer from individual endpoints) cannot encode the "between" constraint.

The `zone_bridge_between_tx` theorem (ZoneBridge.lean:184) confirms the reduction: zone-3 existential ↔ `∃ y, t < y ∧ y < x ∧ predicates_match(y)`. The transfer of this between-zone predicate witness is the irreducible problem.

### Path C: nvar_transfer_from_1var_agree with Alternative h_rvar

**Status**: NOT VIABLE (circular).

`nvar_transfer_from_1var_agree` at d=1, r=2 needs h_rvar = depth-2 2-var agreement, which is the outer theorem's conclusion. The circularity is inherent.

### Path D: Mutual Induction (depth + between-zone existence)

**Status**: MOST PROMISING -- needs design.

Instead of the current architecture (strong induction on K alone), use a mutual induction that simultaneously proves:
1. Depth-(K+2) 2-var agreement at [x,t]/[x',t']
2. Between-zone predicate witness transfer: for any predicate type P with a representative in (t,x), there's one in (t',x')

At K=0, the between-zone transfer (statement 2) can be proved INDEPENDENTLY using only:
- h_t at depth 2 (provides F(P) transfer at t/t')
- h_x at depth 2 (provides S(P) transfer at x/x')  
- Prior-UZ/SZ (provides first/last occurrence)
- A NEW lemma connecting the transferred witnesses

The key new lemma would be: **on Prior structures, if F(P)(t') and S(P)(x') and t' < x', then ∃ y ∈ (t', x'), P(y).**

This is plausibly TRUE on Prior structures because Prior-UZ guarantees a first P-occurrence above t', and if there's a P-point below x' (from S(P)), the first occurrence above t' must be at most the last P-point below x'. But this argument needs careful handling of the case where all P-points below x' are also below t'.

Actually, the argument is: from F(P)(t') we get ∃ r > t' with P(r) (call it r). From S(P)(x') we get ∃ s < x' with P(s) (call it s). If r < x': done (r is between). If s > t': done (s is between). If r >= x' AND s <= t': then all P-points above t' are >= x', and all P-points below x' are <= t'. But r > t' and P(r) and r >= x'. And s < x' and P(s) and s <= t'. So P(r) with r >= x' > t'. By Prior-UZ at t': the FIRST P above t' is some r0 with t' < r0, P(r0). Is r0 < x'? We only know r0 <= r (first occurrence). But r >= x', so r0 could be anywhere in [t', r]. If r0 >= x': then the first P above t' is already past x'. And s <= t' means the P below x' is also below t'. So no P in (t', x').

**Is "no P in (t', x') despite F(P)(t') and S(P)(x')" possible on Prior structures?**

Yes! Consider N = Z, t' = 0, x' = 3. P holds at {..., -1, 4, 5, ...}. F(P)(0) = true (r=4). S(P)(3) = true (s=-1). No P in (0,3). Prior-UZ holds on Z (integers). This is a valid counterexample.

**Therefore, Path D as stated is ALSO insufficient.** The squeeze argument fails even on Prior structures.

### Path E: Depth-1 CharPart Temporal Encoding

**Status**: MOST PROMISING -- needs refined design.

Use `char_fn 1 nf_1var_w` (the depth-1 temporal formula characterizing w's full depth-1 1-var NF) instead of `char_fn 0 nf_w` (predicates only). The depth-1 NF of w encodes:
- w's predicates
- For each depth-0 2-var NF chi2, whether ∃ z with [z,w] matching chi2

In particular, nf_1var_w encodes: "∃ z < w with t's predicates" AND "∃ z > w with x's predicates." So a point w1' with this full depth-1 NF has: w1's predicates + "t-type below me" + "x-type above me."

The formula F(char_fn 1 nf_1var_w)(t) has temporal depth 2 (char_fn 1 has depth 1, F adds 1). This IS captured by h_t at depth 2.

Transfer via h_t: ∃ w1' > t' with depth-1 1-var NF = nf_1var_w.

From nf_1var_w's quantifier conditions:
- ∃ z1 < w1' with t's predicates (from "t-type below w" condition)
- ∃ z2 > w1' with x's predicates (from "x-type above w" condition)

Now the key question: is z1 ≥ t' and z2 ≤ x'? Not necessarily. z1 is some t-type point below w1', which could be anything. z2 is some x-type point above w1', which could be anything.

**However**: the FULL depth-1 1-var NF encodes ALL depth-0 2-var types around w. This includes negative conditions: types that do NOT exist around w. In M, w has a specific set of realized depth-0 2-var types. w1' has the same set. This constrains what can exist around w1', but does NOT constrain w1' relative to x' specifically.

The depth barrier persists: depth-2 1-var at individual endpoints cannot constrain the mutual ordering between a transferred witness and the OTHER endpoint.

### Path F: Joint Temporal Formula at Depth 2 from h_t

**Status**: NEEDS INVESTIGATION -- potentially viable.

Consider: instead of transferring a SINGLE point with F(char_fn 1 nf_1var_w)(t), can we transfer a more complex property?

h_t at depth 2 transfers ALL depth-1 2-var existentials around t. Among these: the depth-1 2-var NF at [w,t] encodes depth-0 3-var existentials around [w,t]. The specific depth-0 3-var NF of [x,w,t] (with x > w, x > t, preds(x)) is encoded. The depth-1 2-var NF at [x,t] is ALSO transferred by h_t (since h_t at depth 2 includes depth-1 2-var existentials around t, and x is one such point above t).

So h_t transfers: ∃ y > t with depth-1 2-var [y,t] = chi_wt (w's projection onto t) AND ∃ y > t with depth-1 2-var [y,t] = chi_xt (x's projection onto t).

The depth-1 2-var NFs chi_wt and chi_xt encode relationships to t but not to each other. We can't guarantee the transferred w-like and x-like points maintain their mutual ordering.

**HOWEVER**: the depth-1 2-var NF at [x,t] (= chi_xt) includes in its quantifier conditions: "∃ z with t < z < x and preds(z) = preds(w)" (this is the depth-0 3-var NF at [w,x,t] being satisfied). This is the BETWEEN-ZONE EXISTENTIAL we need!

The transfer via h_t gives: ∃ x1' > t' with depth-1 2-var [x1',t'] = chi_xt. The quantifier conditions of [x1',t'] include: "∃ z with t' < z < x1' and preds(z) = preds(w)".

If x1' = x': then we're done! We get ∃ z with t' < z < x' and preds(z) = preds(w).

But x1' ≠ x' in general. x1' is a point with x's depth-1 2-var NF relative to t', but it's not necessarily x'.

**KEY INSIGHT**: h_t at depth 2 transfers the depth-1 2-var NF at [x,t] to [x1',t']. But we separately know (from h_x and h_t) that x' has the same depth-2 1-var NF as x, and t' has the same as t. The depth-1 2-var NF at [x,t] can be derived from h_t's quantifier conditions. And [x',t']'s depth-1 2-var NF should be derivable from h_t's quantifier conditions applied to x' (since x' above t' has depth-1 2-var [x',t'] = ?).

Do [x,t] and [x',t'] have the same depth-1 2-var NF? This is EXACTLY the h_agree_env we're trying to prove! So this is again circular at depth 1.

BUT: at depth 0, the story is different. The depth-0 2-var NF at [x,t] is purely atomic (predicates + order). Since preds(x) = preds(x') (from h_x) and preds(t) = preds(t') (from h_t) and t < x ↔ t' < x', the depth-0 2-var NFs at [x,t] and [x',t'] AGREE. This is h_atom.

What about depth-1 2-var? The quantifier conditions need depth-0 3-var existential transfer at [w,x,t]/[w',x',t']. Which is the zone-3 problem. Circular at depth 1 but potentially breakable at depth 0.

---

## 6. Proposed K=0 Mechanism

### 6.1 The Viable Approach: Depth-1 2-var NF at [x,t] Transferred via h_t

The depth-2 1-var NF at t has quantifier conditions encoding ALL depth-1 2-var existentials around t. In particular, for the specific chi_xt = nf_characteristic M 1 2 [x, t]:

"∃ y, nf_eval M 1 2 [y,t] chi_xt" is TRUE in M (witnessed by y = x).

This quantifier condition transfers via h_t: "∃ y', nf_eval N 1 2 [y',t'] chi_xt" in N. So ∃ x1' > t' with depth-1 2-var NF at [x1',t'] = chi_xt = [x,t]'s NF.

chi_xt includes in its quantifier conditions: "∃ z with depth-0 3-var [z,x,t] = chi_wxt" (the between-zone NF), which is TRUE because w exists.

Transfer: "∃ z' with depth-0 3-var [z',x1',t'] = chi_wxt" in N. This z' has:
- t' < z' < x1' (from order atoms of chi_wxt)
- preds(z') = preds(w)

**If x1' = x'**: then z' is between t' and x' with w's predicates. Done.

**If x1' ≠ x'**: z' is between t' and x1' (not necessarily between t' and x'). The approach fails for general x1'.

### 6.2 Making x1' = x': The Depth-0 Projection Argument

From h_t: ∃ x1' with depth-1 2-var [x1',t'] matching [x,t]. From h_x: x' has depth-2 1-var matching x.

Can we show x1' and x' have the same depth-1 2-var NF relative to t'? If depth-1 2-var [x1',t'] = depth-1 2-var [x',t'], then the between-zone existential from [x1',t'] also holds from [x',t']. But proving this equality IS the h_agree_env problem at depth 1.

**Alternative**: we don't need x1' = x'. We need the between-zone existential from [x1',t'] to imply one from [x',t']. For the specific between-zone chi_wxt (depth-0 3-var), the existential reduces to:

"∃ z, t' < z < x1' ∧ preds(z) = preds(w)" (from [x1',t'])
"∃ z, t' < z < x' ∧ preds(z) = preds(w)" (what we need for [x',t'])

These are DIFFERENT if x1' ≠ x' (different upper bounds). We can't conclude one from the other.

### 6.3 The Resolution: Restructure to Prove h_agree_env at Depth 0 First

Depth-0 2-var agreement at [x,t]/[x',t'] IS provable (it's purely atomic, proved as h_atom). Use this as the base for a bootstrapping argument:

1. **Depth-0 2-var**: h_atom (proved, sorry-free)
2. **Depth-0 3-var existential transfer**: Use `exist_transfer_from_full_agree` from depth-0 2-var... wait, this needs depth-1 2-var (k+1 = 1, n+1 = 2). Circular again.

Actually, `exist_transfer_from_full_agree` at k=0 says: from depth-1 2-var agreement, get depth-0 3-var existential transfer. We need depth-1 2-var, which is what we're trying to prove.

### 6.4 Final Proposed Architecture

After exhaustive analysis, the resolution requires a **purpose-built depth-0 between-zone predicate witness transfer lemma** that operates differently from all existing mechanisms:

**Statement**: On Prior structures, given:
- h_x: depth-2 1-var at x/x'
- h_t: depth-2 1-var at t/t'  
- t < x, t' < x'
- w in M with t < w < x and predicates nf_w

Prove: ∃ w' in N with t' < w' < x' and predicates nf_w.

**Proposed proof mechanism**: Use the CONJUNCTION of two temporal formulas:

At x in M: the depth-2 1-var NF at x has quantifier conditions including the depth-1 2-var NF at [w,x]. This NF [w,x] has atom part including w < x and t < x (captured in the 2-var NF's atoms via an encoding of relevant atoms). Wait -- the depth-1 2-var NF at [w,x] only involves variables w and x, not t.

**Revised mechanism**: The resolution likely requires defining a NEW lemma `between_zone_transfer` that:
1. Takes h_t at depth 2, h_x at depth 2, Prior-UZ/SZ, and char_fn at depth ≤ 1
2. Uses the COMBINED information from both endpoints' depth-1 2-var quantifier conditions
3. Uses Prior-UZ/SZ to find a first/last occurrence in the interval
4. Requires a careful case analysis showing that on Prior structures, the squeeze works when using depth-1 characteristic formulas

The key technical step would be proving that on Prior structures, if char_fn(1, nf_w) occurs above t' and below x' (possibly at different points), then it occurs between t' and x'. This is NOT true for depth-0 char (counterexample on Z), but MAY be true for depth-1 char because the depth-1 NF encodes constraints about what exists NEAR the point. Specifically, nf_1var_w at depth 1 says "t-type below me and x-type above me" -- a point with this property can only exist between a t-type and an x-type point, which constrains its position.

**This requires further investigation** to determine if depth-1 NF constraints are sufficient to force the squeeze.

---

## 7. Adversarial Self-Verification (H4)

### 7.1 Challenged Claims

| Claim | Verification | Result |
|-------|-------------|--------|
| "K=0 is an artifact of formalization" | Paper analysis confirms no K=0 analog | VERIFIED |
| "Depth-2 1-var transfers F(P) and S(P)" | Confirmed via quantifier condition decomposition | VERIFIED |
| "Squeeze fails on Z" | Counterexample: P at {...,-1,4,...}, t'=0, x'=3 | VERIFIED |
| "nvar_transfer is circular at K=0" | h_rvar = depth-2 2-var = outer goal | VERIFIED |
| "zone_compatible_witness d=1 depends on nf_eval_from_lower_agree d=0" | Code trace confirms dependency chain | VERIFIED |
| "Depth-1 char_fn encodes t-type/x-type near w" | depth-0 2-var quant conditions include these | VERIFIED |
| "Depth-1 char constrains w' between t' and x'" | NOT VERIFIED -- depth-1 constraints on nearby types don't force specific ordering relative to t'/x' | UNCERTAIN |

### 7.2 Uncertain Claims

- **Depth-1 NF squeeze viability** (confidence: 40%): The depth-1 1-var NF at w encodes what types exist near w, but these are generic witnesses, not t'/x' specifically. A point with "t-type below and x-type above" could exist anywhere, not just between t' and x'.

- **New between_zone_transfer lemma feasibility** (confidence: 60%): The mechanism is theoretically sound on Prior structures but the exact proof path is unclear. The depth-1 encoding MAY constrain placement enough, but this needs a formal argument.

### 7.3 Recommendations Modified After Verification

- Original belief: "depth-0 char_fn + Prior-UZ is sufficient" → **Revised**: counterexample proves this false
- Original belief: "depth-1 char_fn forces squeeze" → **Revised**: uncertain, needs further analysis
- Original belief: "restructuring avoids K=0" → **Revised**: all restructurings converge to the same gap

---

## 8. Risk Assessment

| Risk | Impact | Likelihood | Notes |
|------|--------|------------|-------|
| Depth-1 NF squeeze is insufficient | HIGH | Medium | Would require depth-3+ mechanism or entirely different approach |
| K=0 requires genuine proof restructuring | HIGH | Medium | May need to change from depth-induction to witness-count induction |
| Between-zone transfer needs new infrastructure | Medium | High | No existing lemma handles this case |
| Proof of between-zone lemma is long | Medium | High | Zone analysis + case splitting on Prior structures |

---

## 9. Recommended Next Steps

1. **Investigate depth-1 NF squeeze**: Determine if having "t-type below and x-type above" in the depth-1 NF, combined with Prior-UZ/SZ, forces the witness between t' and x'. This is the most promising path.

2. **If depth-1 squeeze works**: Implement `between_zone_predicate_transfer` using char_fn at depth 1 + Prior-UZ/SZ. Then use it to fill the K=0 sorry and propagate through the dependency chain.

3. **If depth-1 squeeze fails**: Consider restructuring the entire proof to use witness-count induction (matching the paper) instead of NF-depth induction. This is a major refactor but avoids the K=0 problem entirely.

4. **Parallel track**: Investigate whether the degenerate sorries (lines 555, 658 for r=0/n=0) can be solved independently, reducing the sorry surface area.
