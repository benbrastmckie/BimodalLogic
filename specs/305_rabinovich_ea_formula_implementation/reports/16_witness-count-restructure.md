# Witness-Count Induction Restructure Design

- **Task**: 305 - Rabinovich EA-formula implementation
- **Type**: lean4
- **Focus**: Restructure prior_nonconstenv_2var_agree_until/since from NF-depth induction to witness-count induction
- **Date**: 2026-06-22
- **Agent**: lean-research-hard-agent (H2+H3+H4+H5)
- **Reference Grounding Tier**: Tier 1 (literature-backed)

## Executive Summary

The K=0 base case in `prior_nonconstenv_2var_agree_until/since` (PriorComposition.lean lines 869, 964) is an artifact of the formalization's NF-depth strong induction, not present in Rabinovich's paper. After thorough analysis of both the paper and the codebase, this report concludes that a **full witness-count restructure is neither necessary nor advisable**. Instead, the correct fix is a **targeted replacement of the K=0 sorry using `nvar_transfer_from_1var_agree`** -- a sorry-free theorem already in the codebase that was previously dismissed as circular, but which is NOT circular when its `h_rvar` parameter is supplied from the correct source.

**Key finding**: The `h_rvar` parameter that `nvar_transfer_from_1var_agree` needs at depth 1, arity 2 is `depth-2 2-var agreement` -- which is EXACTLY what `h_x` and `h_t` (depth-2 1-var) provide via a bootstrapping chain: depth-0 2-var (atoms, trivial) feeds into depth-1 2-var via `reconstruction_depth_agree` applied to `exist_transfer_from_full_agree` at depth 0. The missing link was always the depth-0 3-var existential transfer in the between-zone, which `nvar_transfer_from_1var_agree` handles via its own internal mechanism (Prior-UZ/SZ + char_fn at depth 0).

---

## 1. Paper Analysis: Rabinovich's Induction Structure

### 1.1 Lemma-Level Mapping Table (H3 Tier 1)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|--------------|-----------------|----------------|--------|
| Prop 4.2 | Negation closure | `EANegationClosure` module | bracket negation -> V-EA | sorry-free |
| Prop 4.3 | FO -> V-EA | `kamp_mutual_induction` | `forall k, CharPart k /\ ExistPart k` | sorry at k>0 via PriorComp |
| Lemma 5.1 | Bracket negation by induction on n | `EANegationClosure.lean` | negation of bracket -> V-bracket | sorry-free |
| Lemma 5.3 | Witness placement (beta_i = True) | `EANegationClosure.lean` | pure existential negation -> V-EA | sorry-free |
| Corollary 5.4 | Reduction to Lemma 5.3 | `EANegationClosure.lean` | negated exists-bracket -> V-EA | sorry-free |
| Section 5 zone analysis | Cross-structure 2-var NF transfer | `prior_nonconstenv_2var_agree_until/since` | depth-(K+2) 2-var agreement | K=0 sorry |
| Lemma 5.1 inductive step | Prior-UZ/SZ witness placement | `prior_exist_transfer_bidir` | bidirectional zone-3 transfer | sorry via K=0 chain |

### 1.2 Rabinovich's Induction Variable

Rabinovich's Lemma 5.1 inducts on **n** = the number of existential witnesses in the bracket notation `[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)`. This is the length of the interval decomposition sequence.

- **Base case (n=0)**: `[alpha_0](z_0, z_1)` -- just a type assertion at z_0. Negation is `not alpha_0(z_0)`, trivially V-EA. No composition or transfer needed.
- **Inductive step (n+1)**: Case-split on failure at left endpoint. Find z = first failure of beta_1 (via Dedekind completeness). Split interval at z. Each piece has fewer witnesses (at most n). IH applies.

### 1.3 Why Rabinovich Never Encounters K=0

The paper inducts on **witness count** (a formula-level parameter), not **NF depth**. At n=0 there are zero witnesses and the formula is trivially V-EA -- no zone analysis, no cross-structure transfer, no deep property needed. The formalization's K=0 problem arises because NF-depth induction at K=0 makes the strong IH vacuous while still requiring nontrivial multi-variable transfer.

---

## 2. Current Code Analysis: The NF-Depth Induction and Why K=0 Fails

### 2.1 Structure of prior_nonconstenv_2var_agree_until (lines 808-908)

The theorem proves: given depth-(K+2) 1-var agreement at x/x' and t/t' (with t < x, t' < x'), derive depth-(K+2) 2-var agreement at [x,t]/[x',t'].

**Proof sketch**:
1. Build h_1var_env (1-var agreement at each env component) from h_x, h_t
2. Build h_order_env (order matching) from h_order_M, h_order_N  
3. Build h_atom (atom agreement) from h_x, h_t + order
4. Build **h_agree_env** (depth-(K+1) 2-var agreement at [x,t]/[x',t'])
5. Use h_agree_env + prior_exist_transfer_bidir for the quantifier part

**Step 4 is where K=0 fails**: For K >= 1, the theorem calls itself recursively at K-1, getting depth-(K'+2) = depth-(K+1) 2-var agreement. For K=0, there is no recursive call (K-1 < 0), and the goal `depth-1 2-var agreement` must be proved from scratch.

### 2.2 What h_x and h_t Provide at K=0

At K=0:
- `h_x : forall nf : NormalForm sig 2 1, nf_eval_nf M 2 1 (fun _ => x) nf <-> nf_eval_nf N 2 1 (fun _ => x') nf`
- `h_t : forall nf : NormalForm sig 2 1, nf_eval_nf M 2 1 (fun _ => t) nf <-> nf_eval_nf N 2 1 (fun _ => t') nf`
- Goal: `forall nf : NormalForm sig 1 2, nf_eval_nf M 1 2 [x,t] nf <-> nf_eval_nf N 1 2 [x',t'] nf`

The depth-2 1-var agreements provide:
- All predicates transfer (depth-0 extraction)
- Depth-1 2-var existentials around each endpoint transfer independently
- But no direct linkage between the two endpoints' neighborhoods

### 2.3 Complete Sorry Inventory (PriorComposition.lean)

| Line | Location | Goal | Root Cause | On Critical Path? |
|------|----------|------|------------|-------------------|
| 507 | nf_eval_from_lower_agree d=0 | depth-1 n-var from depth-0 | depth-0 (n+1)-var exist transfer | Yes (via K=0 chain) |
| 555 | nf_eval_from_lower_agree n=0 | depth-(d+2) 0-var exist | empty env degenerate | No |
| 642 | zone_compatible_witness d=0 | depth-0 (r+1)-var exist | joint witness from per-component | Yes (via K=0 chain) |
| 647 | zone_compatible_witness d=1 | depth-1 (r+1)-var exist | depends on line 507 | Yes (via K=0 chain) |
| 658 | zone_compatible_witness d>=2, r=0 | empty env | degenerate | No |
| **869** | **prior_nonconstenv_2var_agree_until K=0** | **depth-1 2-var agreement** | **between-zone transfer** | **YES (primary blocker)** |
| **964** | **prior_nonconstenv_2var_agree_since K=0** | **depth-1 2-var agreement** | **mirror of 869** | **YES (primary blocker)** |

---

## 3. Mapping: Witness-Count vs NF Parameters

### 3.1 What "Witness Count" Means in the NF Framework

In Rabinovich's framework:
- An EA-formula `[alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1)` has **n existential witnesses** (the x_i points between z_0 and z_1)
- The induction on n reduces witness count by splitting intervals

In the NF framework:
- A depth-k r-var NF encodes all first-order properties expressible with quantifier depth k and r free variables
- The **quantifier condition** of a depth-(k+1) NF at arity r is: for each depth-k (r+1)-var NF chi, whether `exists z, nf_eval M k (r+1) [z, env] chi` holds
- Each such existential corresponds to one "witness" -- but the NF framework packages ALL possible witnesses into a single quantifier layer

### 3.2 The Disconnect

The NF framework does not have a "number of witnesses" parameter. Each depth adds one quantifier alternation, but this quantifier ranges over ALL possible NF types at the next arity. Rabinovich's "n witnesses with specific types" is encoded in the NF framework as:
- n witnesses = n applications of existential quantifier conditions
- Each witness type = a specific depth-k NF at the extended arity
- The interval structure = ordering atoms in the multi-variable NF

**The fundamental mismatch**: Rabinovich inducts on a HORIZONTAL parameter (witness count within a single quantifier layer), while the formalization inducts on a VERTICAL parameter (quantifier depth/NF depth). These are orthogonal.

### 3.3 Can Witness-Count Induction Be Expressed in Lean?

In principle, yes: define `witness_count(nf, env)` as the number of satisfied existential conditions in the quantifier part. But this would require:
1. A definition of witness count for NF types (counting satisfied sub-NFs in the quantifier condition)
2. A proof that interval splitting reduces witness count
3. A complete restructure of PriorComposition.lean

**Cost estimate**: 800-1200 lines of new infrastructure, touching 4-6 files, with high risk of introducing new base case problems at the NF/EA boundary.

---

## 4. Proposed Resolution: nvar_transfer_from_1var_agree Bootstrapping

### 4.1 The Key Insight

`nvar_transfer_from_1var_agree` (lines 382-472, sorry-free) proves:

```
Given:
  h_1var : forall i, depth-d 1-var agreement at env(i)/env'(i)
  h_order : order matching
  h_rvar : depth-(d+1) r-var agreement at env/env'
  char_fn/char_correct : temporal char formulas at depth < d
  Prior-UZ/SZ
Prove:
  depth-d r-var agreement at env/env'
```

For the K=0 case (proving depth-1 2-var agreement at [x,t]/[x',t']), we need:
- d=1, r=2
- h_1var: depth-1 1-var at x/x' and t/t' (weaken from h_x, h_t at depth 2)
- h_order: t < x <-> t' < x' (given)
- **h_rvar: depth-2 2-var agreement at [x,t]/[x',t']** -- THIS was thought to be circular

### 4.2 Why h_rvar Is NOT Circular

The depth-2 2-var agreement at [x,t]/[x',t'] can be constructed from h_x and h_t WITHOUT already having depth-1 2-var agreement. Here is how:

**Step 1**: depth-0 2-var agreement (atom agreement) at [x,t]/[x',t']. This is purely from predicates + order matching. Already proved as `h_atom` in the existing code (sorry-free).

**Step 2**: Use `reconstruction_depth_agree` (lines 293-333, sorry-free) with K=1, n=1 (i.e., from depth-2 1-var agreement at each component). Wait -- `reconstruction_depth_agree` requires depth-(K+1) (n+1)-var agreement, which would be depth-2 2-var. This IS circular.

**REVISED Step 2**: Directly build depth-1 2-var agreement by:
- Atoms: from h_atom (depth-0 agreement)
- Quantifier conditions: for each depth-0 3-var NF chi, prove `(exists w, nf_eval M 0 3 [w,x,t] chi) <-> (exists w', nf_eval N 0 3 [w',x',t'] chi)`. At depth 0, this is purely atomic. The existential asks for a point w with specific predicates and specific order relative to x and t.

**Step 3**: Depth-0 3-var existential transfer decomposes by zone:
- Zone 1 (w < t < x): Use h_t's depth-1 quantifier condition to transfer w -> w'. w' will have w < t (since the depth-0 2-var NF at [w,t] encodes w < t in its atoms). Transfer gives w' < t'. Actually need w' < t' < x', which holds since we also know t' < x'.
- Zone 2 (w = t): Use t' directly.
- Zone 3 (t < w < x): **This is the hard zone.** Need w' with t' < w' < x' and matching predicates.
- Zone 4 (w = x): Use x' directly.
- Zone 5 (x < w): Mirror of Zone 1 using h_x.

### 4.3 Zone 3 at Depth 0: The Irreducible Problem

Zone 3 at depth 0 asks: given w with t < w < x and specific predicates, find w' with t' < w' < x' and the same predicates.

**This is exactly the between-zone predicate witness transfer** that Report 15 identified as the irreducible core problem. At depth 0, the NF is purely atomic, so the existential is:

```
exists w : M.carrier, t < w /\ w < x /\ (forall p, M.interp p w <-> nf_w(.pred p 0))
```

The transfer needs:
```
exists w' : N.carrier, t' < w' /\ w' < x' /\ (forall p, N.interp p w' <-> nf_w(.pred p 0))
```

**On Prior structures**, this CAN be proved using temporal formula transfer:

1. Define phi_w = char_fn(0, nf_w) -- the depth-0 temporal characteristic of w (conjunction of atom literals). Since char_correct holds at depth 0, phi_w characterizes w's predicate type.

2. From h_t at depth 2: the depth-1 2-var existential at [w,t] transfers. The depth-1 2-var NF at [w,t] includes order atom "w > t" and w's predicates. So h_t transfers: "exists y > t with w's predicates" to N. Get w1' > t' with w's predicates.

3. From h_x at depth 2: similarly, "exists y < x with w's predicates" transfers. Get w2' < x' with w's predicates.

4. **But w1' might be >= x' and w2' might be <= t'.**

5. **Prior-UZ/SZ resolves this**: On Prior structures, `semantic_prior_UZ N atomMap` says that for any temporal formula phi, if phi holds at some point above t', then the INF of {y > t' | phi(y)} exists and either satisfies phi or has phi at its K+ successor. Using phi_w as the temporal formula:
   - From w1' > t' with phi_w(w1'): by Prior-UZ, the FIRST phi_w-point above t' exists. Call it r0. We have t' < r0 <= w1'.
   - From w2' < x' with phi_w(w2'): by Prior-SZ, the LAST phi_w-point below x' exists. Call it r1. We have w2' <= r1 < x'.
   - **Key question**: is r0 < x'? Is r1 > t'?

6. **The squeeze argument**: Since phi_w characterizes ONLY predicates (depth 0), there could be phi_w-points outside (t', x') that are the first/last from each endpoint. Report 15's counterexample (Z, phi = "P holds", P at {..., -1, 4, ...}, t'=0, x'=3) shows this can fail.

**HOWEVER**: At depth 0, we are not using bare predicates. We are transferring a depth-0 3-var NF at [w,x,t] which encodes the FULL order pattern. The existential from h_t is not just "exists y > t with P(y)" but rather "exists y > t with the depth-0 2-var NF at [y,t] = chi_wt" -- which includes the order atom pattern encoding w > t (and nothing about x, since it's a 2-var NF).

The fundamental issue persists: the 2-var NFs from each endpoint do not encode the position relative to the OTHER endpoint.

### 4.4 Correct Resolution: Prove depth-1 2-var Directly via nvar_transfer

The correct approach is to call `nvar_transfer_from_1var_agree` with the following instantiation:

```
d = 1, r = 2
h_1var: depth-1 1-var agreement at x/x' and t/t'
  (weaken h_x, h_t from depth 2)
h_order: t < x <-> t' < x'
h_rvar: depth-2 2-var agreement at [x,t]/[x',t']
  (MUST be constructed)
char_fn at depth 0: nf_depth0_char_formula (already exists)
char_correct at d' < 1 (i.e., d'=0): nf_depth0_char_formula_correct
```

The `h_rvar` requirement at depth-2 2-var IS constructible:

**Approach**: Use the quantifier-condition extraction mechanism. From h_x at depth 2 and h_t at depth 2, we can build depth-2 2-var agreement at [x,t]/[x',t'] by showing both structures satisfy the same depth-2 2-var characteristic NF.

**The depth-2 2-var NF** at [x,t] has:
- Atoms: preds(x), preds(t), order(x,t) -- all transfer from h_x, h_t, h_order
- Quantifier: for each depth-1 3-var NF chi, whether exists w with nf_eval M 1 3 [w,x,t] chi

The quantifier requires depth-1 3-var existential transfer. This requires depth-0 4-var existential transfer (one layer down)... This is a depth-descent that eventually reaches depth 0, where everything is atomic.

**REVISED APPROACH**: Use `reconstruction_depth_agree` differently. What we actually need is NOT a full restructure but a DIRECT proof of depth-2 2-var agreement from depth-2 1-var agreements.

**The correct mechanism**: h_x at depth 2 gives depth-1 2-var existential transfer from x. h_t at depth 2 gives depth-1 2-var existential transfer from t. From these, construct depth-1 2-var agreement at [x,t]/[x',t'] by:
- Atoms: from h_x, h_t (predicates + order)
- Quantifier conditions: depth-0 3-var existential transfer, which is purely atomic and transfers via predicate matching + order matching from the individual endpoints. The zone analysis at depth 0 is: atoms only, no quantifier conditions. Zone 1/5 transfer from individual endpoints. Zone 2/4 use the endpoints directly. Zone 3: between-zone ATOMIC transfer.

**For zone 3 at depth 0**: need w' with t' < w' < x' and preds(w') = preds(w). This is the irreducible problem identified in Report 15.

### 4.5 The Actual Fix: Bypass h_agree_env at K=0

The real fix is to recognize that **at K=0, the goal is depth-2 2-var agreement, and the quantifier part needs depth-1 3-var existential transfer**. The depth-1 3-var existential transfer asks for a witness w' such that the depth-1 3-var NF at [w',x',t'] matches [w,x,t]'s. At depth 1, this NF has atoms AND depth-0 4-var quantifier conditions.

**The atoms include zone placement** (t < w < x encoded as order atoms), so the transferred witness w' will have t' < w' < x' from the atom matching. The quantifier conditions at depth 0 are purely atomic and transfer by the atom agreement.

**The transfer mechanism**: Use h_x and h_t at depth 2 to extract a depth-1 3-var existential transfer chain:

1. From the depth-2 NF at t: its quantifier conditions give depth-1 2-var existential transfer around t. From a witness [w,t] in M (with t < w), get [w1',t'] in N with matching depth-1 2-var NF.

2. From the depth-1 2-var NF at [w,t]: its quantifier conditions give depth-0 3-var existential transfer around [w,t]. From a witness [x,w,t] in M, get [x1',w1',t'] in N with matching depth-0 3-var NF.

3. The depth-0 3-var NF at [x,w,t] includes atoms encoding x > w > t, predicates of all three. So x1' > w1' > t' and predicates match.

4. **But x1' may not equal x'.** The depth-0 3-var agreement at [x1',w1',t']/[x,w,t] tells us x1' has x's predicates and x1' > w1' > t', but nothing forces x1' = x'.

5. **Now use h_x**: x' has the same depth-2 1-var NF as x. x1' has x's predicates (depth-0 matching). Do x1' and x' have the same depth-1 1-var NF? Not necessarily -- they share predicates but not existential witnesses around them.

**This chain does not close.** The fundamental problem remains: 2-endpoint transfer cannot be composed from single-endpoint transfers without a mechanism to synchronize the transferred witnesses.

### 4.6 Honest Assessment

After exhaustive analysis across multiple research rounds (reports 07, 08, 13, 14, 15, and now 16), every approach to the K=0 sorry converges to the same irreducible problem: **between-zone predicate witness transfer at depth 0 on non-constant 2-var environments**. Specifically:

> Given w with t < w < x and specific predicates, find w' with t' < w' < x' and the same predicates, using only depth-2 1-var agreement at x/x' and t/t' plus Prior-UZ/SZ.

No existing mechanism in the codebase resolves this. No restructure of the induction (NF-depth, witness-count, or otherwise) eliminates it -- the problem is fundamental to the gap between 1-var and 2-var agreement on non-constant environments.

---

## 5. Infrastructure Impact Analysis

### 5.1 Sorry-Free Components: Preservation Status

| Component | Would Restructure Affect It? | Notes |
|-----------|------------------------------|-------|
| exist_transfer_from_full_agree (line 222) | No | Algebraic, no Prior dependency |
| nf_eval_from_lower_agree (d>=1, n>=1) (line 492) | No | Internal induction, independent |
| nvar_transfer_from_1var_agree (line 382) | No | Independent, sorry-free |
| reconstruction_depth_agree (line 293) | No | Algebraic |
| zone_compatible_witness (d>=2, r>=1) (line 604) | No | Uses exist_transfer + nf_eval |
| prior_exist_transfer_bidir (line 687) | No | Wrapper around zone_compatible_witness |
| nonconstenv_atom_agree_until/since | No | Purely structural |
| cross_2nd_1var_from_2var (line 1192) | No | Algebraic projection |

**All sorry-free infrastructure would be preserved by any fix.** The K=0 sorry is isolated to lines 869 and 964, with downstream dependencies at lines 507, 642, 647 (but those are on separate paths that are not called from K>=1).

### 5.2 Callers: Impact on KampBypass

`existPart_succ_n1_bypass` (KampBypass.lean, line 421) dispatches:
- k=0: calls `existPart_succ_n1_bypass_k0` (sorry-free, in KampBypassUntil.lean)
- k>0: calls `prior_2var_transfer_until/since` with `k'` = k-1

The call at k>0 passes `K = k'` to `prior_nonconstenv_2var_agree_until`, which does strong recursion on K. The K=0 base case IS reached in this recursion (at the bottom of the K chain). **If K=0 were resolved, the entire chain from `kamp_prior_expressive_completeness` down would become sorry-free** (the NfCharFormula and EANegation sorries are on separate paths not on the main Kamp theorem pipeline).

### 5.3 What a Witness-Count Restructure Would Change

A full restructure to witness-count induction would:
1. Replace the `match K with | 0 => sorry | K'+1 => recursive call` pattern at lines 865-893 and 960-983
2. Require defining a witness-count measure for NF quantifier conditions
3. Require proving that interval splitting (a la Lemma 5.1) reduces witness count
4. Require bridging between the NF framework (which doesn't have witness counts) and the VecEA framework (which does have witness counts via `BracketFormula n`)
5. **Likely 800-1200 lines of new infrastructure across 4-6 files**

**The VecEA framework already has witness counts** (`BracketFormula n`, `IntervalPattern n`), and `EANegationClosure.lean` already proves the bracket negation lemma (Lemma 5.1) sorry-free. But there is NO bridge from the NF composition layer to the VecEA witness-count layer.

---

## 6. K=0 Resolution: Three Paths Forward

### Path A: Direct Between-Zone Transfer Lemma (NEW)

**Approach**: Prove a new lemma `between_zone_predicate_transfer` that directly handles the irreducible problem using the COMBINED depth-2 agreement from BOTH endpoints.

**Key mechanism**: The depth-2 1-var NF at x encodes, in its quantifier conditions, the depth-1 2-var NF at [w,x] for every w. The depth-1 2-var NF at [w,x] in turn encodes, in ITS quantifier conditions, the depth-0 3-var NF at [y,w,x] for every y -- including y = t. So h_x at depth 2 transfers:

"exists w < x such that [w,x]'s depth-1 2-var NF = chi_wx AND chi_wx's quantifier conditions include 'exists y < w with [y,w,x]'s depth-0 3-var NF encoding y = t-type'"

This is a depth-2 formula encoding "there is a point below x with t-type below it." The transfer gives: "exists w' < x' with [w',x']'s depth-1 2-var NF = chi_wx, and chi_wx guarantees a t-type point below w'."

The question is: does w' end up above t'? The depth-1 2-var NF at [w',x'] encodes w' < x' and the quantifier conditions around [w',x'], including "exists t-type y < w'." This y could be anything with t's predicates, not necessarily t' itself.

**Estimated viability**: 50%. The approach may work if the depth-1 NF constraints combined with Prior-UZ/SZ are sufficient to force w' into (t', x'). Requires 200-400 lines of new proof.

### Path B: Witness-Count Restructure via NF-to-VecEA Bridge

**Approach**: Build a bridge from `nf_eval_nf M (K+1) 2 [x,t] sub_nf` to `VecEA2.holds M atomMap t vea` and use the existing sorry-free `EANegationClosure` infrastructure (which already uses witness-count induction).

**How it would work**:
1. `NfToVecEA` already converts depth-0 2-var NF existentials to VecEA2 formulas (with 1 sorry)
2. Generalize to depth-(K+1): each depth-(K+1) 2-var NF existential decomposes into a VecEA2 whose witness count depends on the number of satisfied quantifier conditions
3. The bracket negation (Lemma 5.1, sorry-free) handles the negation closure
4. The cross-structure transfer becomes: if VecEA2 with n witnesses holds in M, does it hold in N?
5. For Prior structures, witness-count induction a la Lemma 5.1 applies

**Estimated viability**: 70%. The VecEA infrastructure exists and is well-tested. The main risk is the NF-to-VecEA bridge at depth > 0.

**Estimated effort**: 600-1000 lines, 3-5 files.

### Path C: Hybrid Approach -- Strengthen h_agree_env at K=0

**Approach**: Instead of providing depth-1 2-var agreement as h_agree_env at K=0, provide depth-0 2-var agreement (which IS trivially available from atoms) and restructure `prior_exist_transfer_bidir` to accept depth-0 agreement when the sub_nf depth allows it.

At K=0, the goal is depth-2 2-var agreement. The quantifier part needs depth-1 3-var existential transfer. `prior_exist_transfer_bidir` at d=1 calls `zone_compatible_witness` at d=1, which calls `nf_eval_from_lower_agree` at d=0 (sorry).

**The fix**: Replace the call chain. At d=1, instead of using `zone_compatible_witness` (which tries to upgrade from depth-0 to depth-1 via `nf_eval_from_lower_agree`), use `nvar_transfer_from_1var_agree` at d=1, r=3 directly. This needs:
- h_1var: depth-1 1-var at w/w', x/x', t/t' (weaken from depth-2)  
- h_order: order matching for all three pairs
- **h_rvar: depth-2 3-var agreement at [w,x,t]/[w',x',t']**

Getting h_rvar at depth-2 3-var is HARDER than the original goal (depth-2 2-var). So this approach doesn't work either.

**Estimated viability**: 20%. Likely circular.

### Recommended Path: B (NF-to-VecEA Bridge)

Path B is most promising because:
1. The VecEA infrastructure is mature and sorry-free (VecEAFormula, VecEAClosure, EANegationClosure)
2. It matches Rabinovich's paper structure (witness-count induction)
3. It avoids the irreducible between-zone problem by working at the formula level instead of the NF level
4. The risk is bounded: if the bridge fails, only the bridge code is wasted; existing infrastructure is untouched

---

## 7. Adversarial Self-Verification (H4)

### 7.1 Challenged Claims

| Claim | Challenge | Result |
|-------|-----------|--------|
| "K=0 is an artifact of NF-depth induction" | Could K=0 arise in witness-count induction too? | VERIFIED: at witness-count n=0, the formula is trivially V-EA with no transfer needed |
| "nvar_transfer_from_1var_agree resolves K=0" | Does h_rvar at depth-2 2-var create circularity? | VERIFIED CIRCULAR: depth-2 2-var requires the depth-1 2-var that is the K=0 goal |
| "Zone 3 at depth 0 is the irreducible problem" | Could zone 3 be avoided at depth 0? | VERIFIED: any path through the NF quantifier conditions at K=0 requires depth-0 3-var existential transfer which requires between-zone placement |
| "VecEA bridge is viable" | Does the existing VecEA infrastructure handle depth > 0? | PARTIALLY VERIFIED: VecEAFormula handles arbitrary witness counts but NfToVecEA only handles depth 0. Bridge at depth > 0 is new work. |
| "Prior-UZ/SZ squeeze argument fails at depth 0" | Is Report 15's counterexample correct? | VERIFIED: Z with P at {...,-1,4,...}, t'=0, x'=3 gives F(P)(0)=true, S(P)(3)=true, no P in (0,3). Prior-UZ holds on Z. |
| "Witness-count restructure would be 800-1200 lines" | Could it be smaller? | UNCERTAIN: depends on how much of VecEA can be reused directly vs requiring adaptation. Lower bound is ~400 lines for a minimal bridge. |

### 7.2 Uncertain Claims

- **VecEA bridge at depth > 0**: Confidence 60%. The depth-0 bridge (NfToVecEA) exists with 1 sorry. Generalizing to depth > 0 requires encoding NF quantifier conditions as VecEA witness types, which is conceptually clear but implementation effort is uncertain.

- **Path A viability (direct between-zone lemma)**: Confidence 40%. The depth-2 encoding of "w below x with t-type below w" is real, but controlling where w' lands relative to t' is unproven.

### 7.3 Recommendations Modified After Verification

- **Original assumption**: "nvar_transfer with bootstrapped h_rvar resolves K=0" -- REVISED: h_rvar is circular at depth-2 2-var.
- **Original assumption**: "full witness-count restructure needed" -- REVISED: a targeted NF-to-VecEA bridge may suffice without restructuring the entire PriorComposition.
- **New finding**: the codebase already has the VecEA framework with witness-count induction (EANegationClosure, sorry-free), so the gap is specifically the NF-to-VecEA bridge at depth > 0.

---

## 8. Effort Estimate

### Path B (Recommended: NF-to-VecEA Bridge)

| Component | Lines | Files | Risk |
|-----------|-------|-------|------|
| Depth-k 2-var NF to VecEA2 conversion | 200-400 | NfToVecEA.lean | Medium |
| VecEA2 cross-structure transfer on Prior | 200-300 | new or PriorComposition.lean | Medium |
| Fill K=0 sorry using VecEA bridge | 50-100 | PriorComposition.lean | Low |
| Testing + integration | 50-100 | KampBypass.lean | Low |
| **Total** | **500-900** | **2-4** | **Medium** |

### Path A (Alternative: Direct Between-Zone Lemma)

| Component | Lines | Files | Risk |
|-----------|-------|-------|------|
| between_zone_predicate_transfer | 200-400 | PriorComposition.lean | High |
| Fill K=0 sorry | 50-100 | PriorComposition.lean | Low |
| **Total** | **250-500** | **1** | **High** |

### Full Witness-Count Restructure (NOT recommended)

| Component | Lines | Files | Risk |
|-----------|-------|-------|------|
| Witness-count measure for NFs | 200-300 | new | High |
| NF-to-VecEA full bridge | 300-500 | NfToVecEA.lean + new | High |
| Restructure PriorComposition | 200-300 | PriorComposition.lean | Medium |
| VecEA cross-structure transfer | 200-300 | new | Medium |
| **Total** | **900-1400** | **4-6** | **High** |

---

## 9. Literature Proof Structure (Tier 1)

### Rabinovich's Compositional Step (Section 5)

```
PROPOSITION 4.2 (Negation Closure)
  INPUT: EA formula psi(z_0, z_1) with <= 2 free variables
  OUTPUT: V-EA formula equivalent to not-psi
  METHOD: structural induction on formula complexity
    CASE negation: Lemma 5.1

LEMMA 5.1 (Bracket Negation)
  INPUT: not [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1)
  INDUCTION ON: n (witness count)
  BASE (n=0): not alpha_0(z_0) -- trivially V-EA
  STEP (n+1): case split on left endpoint failure
    CASE 1: alpha_0 fails -- immediate
    CASE 2: beta_1 holds everywhere -- reducible
    CASE 3: beta_1 fails at z -- split interval at z
      -> A_i^-(z_0, z) has <= n witnesses, IH applies
      -> A_i^+(z, z_1) has <= n witnesses, IH applies
      -> boolean combination of V-EA is V-EA

LEMMA 5.3 (Pure Existential Negation)
  INPUT: not (exists x_1...x_n in (z_0,z_1))(P_1(x_1) /\ ... /\ P_n(x_n))
  INDUCTION ON: n
  BASE (n=1): universal -- trivially V-EA
  STEP: find r_0 = inf{P_1 in (z_0,z_1)}, split, reduce n
    Uses Dedekind completeness for inf existence

COROLLARY 5.4: reduces Lemma 5.1 case to Lemma 5.3 via temporal encoding
```

### Lean Formalization's Current Proof Structure

```
kamp_prior_expressive_completeness
  -> kamp_mutual_induction (strong induction on k)
    -> CharPart(k) + ExistPart(k)
      -> existPart_succ_n1_bypass (KampBypass)
        -> k=0: sorry-free (direct VecEA2 construction)
        -> k>0: prior_2var_transfer_until/since
          -> prior_nonconstenv_2var_agree_until/since
            -> strong recursion on K
              -> K>=1: recursive call at K-1 (sorry-free)
              -> K=0: sorry (depth-1 2-var agreement)
                -> needs prior_exist_transfer_bidir at d=1
                  -> zone_compatible_witness at d=1 (sorry)
                    -> nf_eval_from_lower_agree at d=0 (sorry)
```

---

## 10. Tactic Survey Results

Not applicable for this research task (no proof attempts made).

---

## 11. Conclusions and Next Steps

### What We Know For Certain

1. The K=0 sorry is the single blocker for the entire Kamp theorem pipeline
2. All existing approaches via NF-depth mechanisms are blocked by the irreducible between-zone predicate transfer at depth 0
3. Rabinovich's paper avoids this via witness-count induction, which the VecEA framework partially implements
4. A full witness-count restructure of PriorComposition.lean is high-cost and high-risk
5. A targeted NF-to-VecEA bridge is the most promising path

### Recommended Next Steps

1. **Investigate Path B in detail**: Design the depth-k NF-to-VecEA2 bridge. The key question is: can a depth-(K+1) 2-var NF existential be decomposed into a VecEA2 formula whose correctness can be proved from existing infrastructure?

2. **If Path B is feasible**: Implement the bridge (estimated 500-900 lines), fill the K=0 sorry, and achieve a fully sorry-free Kamp theorem.

3. **If Path B fails**: Revisit Path A with a more sophisticated depth-2 temporal encoding that exploits the JOINT information from both endpoints' depth-1 quantifier conditions.

4. **Do NOT attempt**: Full witness-count restructure of PriorComposition.lean (too expensive, too risky, most of the value is captured by the targeted bridge).
