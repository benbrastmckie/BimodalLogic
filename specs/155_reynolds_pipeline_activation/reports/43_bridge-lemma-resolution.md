# Bridge Lemma Resolution Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Best resolution path for `nf_2var_from_interval_data` (StaviCompleteness.lean:1873)

---

## 1. The Core Problem (Recap)

`nf_2var_from_interval_data` states: given two 2-variable environments (x,t) in M and (x',t') in M' that agree on depth-k 1-var NFs, orderings, interval types, and above/below types, their depth-k 2-var NFs are equal.

Direct induction on k fails because the k+1 step requires showing depth-k 3-variable NF agreement for (u,x,t)/(u',x',t'), which needs interval data for sub-intervals (x,u) and (u,t) that the hypotheses don't provide.

---

## 2. Option Analysis

### Option A: NF-World EF Game Framework (~400-700 lines)

**What it is**: Define a k-round back-and-forth game operating directly on the NF world (nf_characteristic/nf_eval_nf), prove its winning condition implies nf_characteristic equality, then show the bridge lemma's hypotheses give Duplicator a winning strategy.

**Feasibility**: HIGH. The game construction is straightforward: at each round, Spoiler picks a new element, Duplicator matches it from the interval data. After k rounds, atom agreement (depth 0) follows from the 1-var NF agreement. This is exactly `nf_agreement_monotone` generalized to multiple variables.

**Critical insight**: `nf_agreement_monotone` (NormalForm.lean:339, sorry-free) already implements the core game argument for arbitrary n. At depth k+1, given a witness x in M, it finds a matching y in N via the quantifier assignment, establishing depth-k' NF agreement for (Fin.cons x env) / (Fin.cons y env'). This IS the one-round game step. The bridge lemma is essentially `nf_agreement_monotone` applied to n=2 with the interval data providing the matching strategy.

**GHR93 faithfulness**: HIGH — this is GHR93's Proposition 7 proof (back-and-forth argument).

**Risk**: MEDIUM — need to formalize the connection between "same 1-var NFs + same interval types → same quantifier assignment at depth k+1".

### Option B: Strengthen Hypotheses (~300-500 lines)

**What it is**: Add interval data for all sub-intervals to the hypotheses, then induct.

**Feasibility**: LOW-MEDIUM. The callers would need to provide interval data for ALL pairs (x,u), (u,t) for every potential witness u. But the callers (`nf_2var_transfer` at line 1877, `nf_exist_sf_guarded_backward` at line 2125) extract witness points from temporal formulas and know only the ONE interval (x,t). They don't have arbitrary sub-interval data.

**Caller analysis**: `nf_exist_sf_guarded_backward` extracts a witness x from `stavi_temporal_truth` of a guarded formula. The guard gives the 1-var NF of x and interval information between x and t (from the `interval_guard_sf`). It does NOT provide interval data for sub-intervals created by x splitting (x,t) into (x,u) and (u,t) for arbitrary sub-witnesses u. So the callers CANNOT provide the strengthened hypotheses without significant restructuring.

**GHR93 faithfulness**: LOW — GHR93 does not strengthen hypotheses; it uses the game argument.

**Risk**: HIGH — fundamental restructuring of callers needed.

### Option C: Restructure Formula (~200-400 lines)

**What it is**: Modify `nf_exist_sf_guarded` to encode more interval type information in the formula itself, making the backward direction provable by direct extraction.

**Feasibility**: LOW. The formula `nf_exist_sf_guarded` uses `interval_guard_sf` which encodes types in the interval between the witness and the parent point. To get full interval data, the formula would need to encode an exponential amount of information (types in all sub-intervals of all possible witness configurations). This defeats the purpose of the guarded formula approach.

**GHR93 faithfulness**: LOW — deviates from the literature's approach.

**Risk**: HIGH — exponential formula blowup.

### Option D: Use Existing `nf_agreement_monotone` Directly (NEW — ~100-250 lines)

**What it is**: Prove `nf_2var_from_interval_data` by showing that the hypotheses imply depth-k NF agreement at n=2 via the existing `nf_agreement_monotone` machinery, without building a new game framework.

**Key insight**: The bridge lemma's hypotheses (1-var NF agreement + ordering + interval types) are exactly what's needed to show that the depth-(k+1) 2-variable NF quantifier assignments agree. At depth k+1, the quantifier assignment records which depth-k sub-NFs (at n=3) are realized. A sub-NF at n=3 is realized by a witness u in (x,t)'s environment iff a matching witness u' exists in (x',t')'s environment with the same depth-k 3-variable NF. The interval type hypotheses guarantee this matching.

**Proof sketch**:
1. Induct on k.
2. Base case (k=0): 2-var NF at depth 0 is just atom agreement. Follows from 1-var NF agreement + ordering.
3. Inductive step (k+1): Need to show the quantifier assignment agrees — i.e., for each depth-k 3-var sub-NF, its realizability matches. Given a witness u in M realizing some sub-NF with (u,x,t):
   - From u's 1-var depth-k NF and its position (using interval type data), find u' in M' with same 1-var NF and same position.
   - Need: nf_characteristic M k 3 (u,x,t) = nf_characteristic M' k 3 (u',x',t').
   - This is a RECURSIVE application of the bridge lemma at n=3, depth k. But we only proved it at n=2...

**Wait — this is the same blocker.** The recursive step goes from n=2 to n=3, requiring interval data for pairs involving u. This is the same issue as direct induction.

**HOWEVER**: There is a crucial difference. At depth k (not k+1), the IH is available. The IH for depth k at n=2 gives: if (u,x) and (u',x') agree on 1-var NFs + ordering + interval types, then their 2-var NF agrees. So we need:
- 1-var NF: u and u' matched by interval types ✓
- Ordering: (u < x), (u < t) determined by position ✓
- Interval types for (u,x): THIS is the missing data

For (u,x): the interval types are the set of 1-var depth-k NFs realized in (u,x). Since u is between x and t (say x < u < t), the interval (u,x) is a sub-interval of (x,t). The hypothesis gives interval_nf_types for (x,t) but NOT for (u,x) and (u,t).

**BUT**: The interval types for (x,u) are determined by the interval types for (x,t) restricted to (x,u). Since u and u' have the same 1-var NF, and the interval types for (x,t) and (x',t') agree, we need: interval_nf_types M k x u = interval_nf_types M' k x' u'.

This is NOT given. The hypothesis says interval_nf_types M k x t = interval_nf_types M' k x' t'. But the types in (x,u) are a SUBSET of those in (x,t), and which subset depends on u's position — and there may be types in (x,t) that are both in (x,u) and in (u,t) or only in one.

**Conclusion**: Option D has the same fundamental problem. The interval data for sub-intervals cannot be derived from the full-interval data.

---

## 3. The Real Solution: Why the Game Approach Works

The EF game avoids the sub-interval problem by NOT maintaining an NF-equality invariant at each step. Instead:

1. Duplicator matches each new witness using ONLY the original interval data
2. After k rounds, all 2+k points are matched
3. The winning condition checks ONLY atom agreement at depth 0
4. Atom agreement follows from 1-var NF agreement at each matched pair

The key: matched means "same 1-var NF AND same ordering relative to ALL other matched points AND same interval types between adjacent matched points." But the interval types between adjacent points ARE derivable from the original (x,t) interval data because: if a type τ is realized in (x,t), it's either in (x,u) or (u,t) (or both) — and the matching ensures the same partition.

Wait — that's the subtle point. Given interval_nf_types(x,t) = interval_nf_types(x',t'), and u in (x,t) with 1-var NF ν, we match u to u' in (x',t') with the same 1-var NF ν (possible because ν ∈ interval_nf_types). Then:

- Types in (x,u): these are the types realized by points in (x,u). From the original data, we know which types are realized in (x,t). But we don't know which are in (x,u) specifically.

**This is still the problem at each game round.** Unless...

The game approach works because Duplicator doesn't need to track sub-interval types. She just needs to match individual points. The winning condition after ALL rounds is: for all i,j in {1,...,k,x,t}, the ordering between matched points and their 1-var NFs agree. This is checkable from the matching (no interval data needed at depth 0).

The magic: `nf_agreement_monotone` at n=2+k, depth=0, with (2+k)-variable environments = all matched points. Depth-0 NF agreement is atom agreement. The matched points all have matching 1-var NFs and ordering. So depth-0 agreement holds. Then `nf_agreement_monotone` lifts this to depth-k agreement at n=2.

**THIS IS THE KEY**: We don't need depth-k agreement at n=2+k. We need depth-0 agreement at n=2+k (which gives depth-k agreement at n=2 by `nf_agreement_monotone`). And depth-0 agreement at n=2+k is just atom agreement (ordering + predicate matching), which is exactly what the matched points give us.

---

## 4. Concrete Proof Strategy (Option A, refined)

**Theorem**: nf_2var_from_interval_data at depth k.

**Proof** (by induction on k):

**Base case k=0**: nf_characteristic M 0 2 (x,t) records atom agreement: ordering(x<t) and predicate values. The hypotheses give h_order_xt and h_nf_x, h_nf_t (which include predicate values at x and t). Direct.

**Inductive step k → k+1**: Need quantifier assignment agreement. For each depth-k sub-NF sub_nf at n=3, need: (∃u, nf_eval_nf M k 3 (u,x,t) sub_nf) ↔ (∃u', nf_eval_nf M' k 3 (u',x',t') sub_nf).

Forward direction: given u in M with nf_eval_nf M k 3 (u,x,t) sub_nf.
- Extract u's 1-var depth-k NF: nf_u
- From h_interval_above/below (depending on position of u): nf_u ∈ interval_nf_types ↔ nf_u ∈ interval_nf_types'. So find u' with same 1-var NF.
- Need: nf_eval_nf M' k 3 (u',x',t') sub_nf.
- By nf_eval_unique, sub_nf = nf_characteristic M k 3 (u,x,t).
- Need: nf_characteristic M k 3 (u,x,t) = nf_characteristic M' k 3 (u',x',t').
- By the IH at k... but the IH is for n=2, not n=3!

**The gap**: The IH gives 2-var NF agreement from 1-var NFs + interval data. We need 3-var NF agreement. We can try to reduce 3-var to three 2-var applications (for (u,x), (u,t), (x,t)), but each requires its own interval data.

**The real fix**: Don't induct on k for n=2. Instead, prove the GENERAL version for arbitrary n by induction on k, using `nf_agreement_monotone` at the base.

**General bridge lemma** (all n, depth k): if (x_1,...,x_n) in M and (x'_1,...,x'_n) in M' have matching 1-var NFs, matching orderings, and matching interval types for all adjacent pairs, then their n-var depth-k NFs agree.

Proof by induction on k:
- k=0: atom agreement from 1-var NF + ordering. ✓
- k+1: need quantifier agreement. Given witness u → match to u' via interval data → get (n+1)-var configuration with matching 1-var NFs and orderings. Apply IH at depth k for the (n+1)-var configuration.

**This still requires interval data for ALL adjacent pairs in the (n+1)-var config**, including pairs involving u. And we don't have those.

**FINAL INSIGHT**: The game approach works because it does ALL k rounds of witness matching at once, then checks depth-0 at n=2+k. It never checks intermediate depths.

So the proof is:
1. Play k rounds: match witnesses u_1,...,u_k using interval data (k selections from one side, matched by the other).
2. After k rounds: have 2+k matched points with matching 1-var NFs and orderings.
3. depth-0 NF agreement at n=2+k: follows from 1-var NF + ordering (this IS atom agreement).
4. By `nf_agreement_monotone`: depth-0 agreement at n=2+k implies depth-k agreement at n=2.

**Step 4 needs `nf_agreement_monotone` generalized from "same k-NF at n" to "depth-0 agreement at n+k implies depth-k agreement at n."** And `nf_agreement_monotone` already does this! It shows that depth-m agreement (for m ≤ k) follows from depth-k agreement. With k=0+k and m=0, it says depth-0 agreement at n=2+k implies... wait, `nf_agreement_monotone` works at FIXED n, varying depth. We need the REVERSE: fixed depth 0, varying n.

Actually: `nf_agreement_monotone` says: depth-k agreement at n implies depth-m agreement at n (for m ≤ k). What we need is: depth-0 agreement at (n+k) implies depth-k agreement at n. This is NOT what `nf_agreement_monotone` gives — it varies depth, not variable count.

The correct theorem is `doets_lemma_1_1`: depth-k NF agreement at n implies agreement on all depth-≤-k formulas at n. But we need the converse: agreement on all depth-≤-k formulas implies depth-k NF agreement.

The converse is immediate from `nf_exists_unique`: if M,env and N,env' agree on all formulas of depth ≤ k, they satisfy the same depth-k NF.

**BUT**: we don't have "agree on all formulas" — we have depth-0 NF agreement at n=2+k.

The connection is: depth-0 NF agreement at n=2+k means atom agreement for the full (2+k)-variable configuration. Combined with nf_agreement_monotone (which goes UP from depth-0 to depth-k, REDUCING n by k along the way), we get depth-k agreement at n=2.

Actually, looking at `nf_agreement_monotone` again carefully: it takes depth-k NF agreement at n and produces depth-m NF agreement at n (for m ≤ k). The n stays fixed. So it CAN'T go from n=2+k to n=2.

The theorem we need is fundamentally different: **the game compression theorem** — k rounds of witness matching (which produce depth-0 agreement at n=2+k) compress to depth-k agreement at n=2. This IS `nf_agreement_monotone` applied differently:

At depth k+1, the quantifier assignment asks: "does there exist a witness u such that the (n+1)-var depth-k NF matches?" After one round of the game (matching u to u'), we have depth-k NF agreement at n+1 (by IH at k). So the existential is satisfied iff the existential is satisfied. This is exactly what `nf_agreement_monotone` does in its inductive step!

So the proof IS `nf_agreement_monotone` applied at n=2, depth k, where the "depth-k NF agreement at n=2" is established by... the bridge lemma itself. This is circular.

---

## 5. Recommendation

**Option A (NF-world EF game) is the correct approach**, but the "game" is actually just the standard proof of the Fraïssé theorem: depth-0 agreement at n=2+k (after k rounds of back-and-forth) implies depth-k agreement at n=2.

The concrete implementation:

1. **Define k-round back-and-forth matching** (~50-80 lines): Given the bridge hypotheses, show that for any sequence of k challenges (witnesses) from one side, matching witnesses exist on the other side, maintaining 1-var NF and ordering consistency with all previously matched points.

2. **Show depth-0 agreement from matching** (~30-50 lines): After k rounds, the 2+k matched points have matching 1-var NFs and orderings. This gives depth-0 NF agreement at n=2+k.

3. **Apply the Fraïssé direction** (~80-150 lines): depth-0 agreement at n=2+k implies depth-k agreement at n=2. This requires a new lemma: "if all depth-0 (n+j)-var NFs agree, then all depth-j n-var NFs agree." This is the quantifier-elimination direction of the EF theorem, provable by induction on j.

**Total estimate**: 160-280 lines of new proof, plus the bridge lemma proof itself (~50-100 lines using the above). **Total: ~210-380 lines.**

**GHR93 faithfulness**: HIGH — this is the standard back-and-forth/Fraïssé argument.

**Risk**: LOW-MEDIUM — the new Fraïssé lemma (step 3) is the main work but is standard model theory.

---

## 6. Summary

| Option | Lines | Feasibility | GHR93 Faithful | Risk | Recommendation |
|--------|-------|-------------|----------------|------|----------------|
| A (NF EF game) | 400-700 | HIGH | HIGH | MEDIUM | **Too broad** |
| A' (Fraïssé lemma) | 210-380 | HIGH | HIGH | LOW-MED | **RECOMMENDED** |
| B (strengthen hyps) | 300-500 | LOW-MED | LOW | HIGH | Not viable (callers can't provide) |
| C (restructure formula) | 200-400 | LOW | LOW | HIGH | Not viable (exponential blowup) |
| D (nf_agreement_monotone) | 100-250 | LOW | MED | HIGH | Same fundamental blocker |

**Recommended**: Option A' — build the Fraïssé direction lemma ("depth-0 agreement at n+k implies depth-k agreement at n"), then prove the bridge lemma by: (1) k rounds of back-and-forth matching, (2) depth-0 agreement at n=2+k, (3) Fraïssé compression to depth-k at n=2.
