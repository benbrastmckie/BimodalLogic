# Phase 5 Handoff: Between-Zone Lemma is FALSE

## Immediate Next Action

Research dispatch to design the CharPart-threaded architecture for merged Phases 5+6, then implementation dispatch to execute.

## Current State

- Phase 5: BLOCKED (between-zone lemmas are FALSE as stated)
- Sorry count: 4 (unchanged from previous dispatch)
- Build: passes (988 jobs, all sorry are explicit)
- KampBypass.lean: 0 sorry (sorry-free, must not regress)

## Key Discovery: Counterexample

`depth0_3var_exist_transfer_until` and `depth0_3var_exist_transfer_since` (lines 200-345 in PriorComposition.lean) are **FALSE** as standalone lemmas. The between-zone case (Zone 3: t < w < x) cannot be proved from the available hypotheses.

### Counterexample

- **Structure**: M = N = (Z, <, P = {n in Z | n is even})
- **Points in M**: t = -1, x = 4, w = 0 (P(0) = true, -1 < 0 < 4)
- **Points in N**: t' = -1, x' = 0
- **Sigma**: P = true (the predicate pattern to transfer)

**Why NFs agree**:
- depth-2 1-var at x=4 / x'=0: Both are even, so P(4)=P(0)=true. By 2-periodicity of P = evens on Z, the local pattern around any even number is identical (same neighbor types, same between-zone patterns relative to neighbors). All depth-k 1-var NFs agree for any k.
- depth-2 1-var at t=-1 / t'=-1: Same point in same structure. Trivially same NF.

**Why Prior holds**: Z is discrete, so Prior-UZ and Prior-SZ hold for any atomMap (every non-empty set has a least element above any point and a greatest element below any point).

**Why transfer fails**: M has w=0 with -1 < 0 < 4 and P(0) = true. But in N, the interval (-1, 0) is empty (no integers strictly between -1 and 0). So there is no w' with -1 < w' < 0 and P(w') = true.

### Root Cause Analysis

The between-zone condition "exists w in (t, x) with predicates sigma" is a **2-variable property** of the pair (t, x). It cannot be determined from two independent 1-variable conditions:
- "exists s > t with sigma(s)" (from h_t depth-2 1-var)
- "exists s < x with sigma(s)" (from h_x depth-2 1-var)

Both conditions can be TRUE while the interval (t', x') has no sigma-point, if the witnesses s are outside (t', x').

The depth-2 1-var NF at t captures intervals (t, s) for various s, but s need not be x'. Similarly, the NF at x captures intervals (s, x) but s need not be t'. The two NFs independently do not constrain the specific interval (t', x').

## Recommended Fix: Merge Phases 5+6 with CharPart

### Architecture

1. Add `CharPart(K+1)` as a parameter to `prior_nonconstenv_2var_agree_until/since` and upstream callers (`prior_2var_transfer_until/since`).
2. Thread CharPart from `existPart_succ_n1_bypass` call sites where it's already available as `char_kp1`.
3. Remove or restructure `depth0_3var_exist_transfer_until/since` (FALSE as stated).
4. At K=0 base case: use `existPart_succ_n1_bypass_k0` with `char_1 : CharPart atomMap 1` to build temporal formula A for each depth-1 2-var NF. A has operator depth <= 2. Transfer A's truth via depth-2 1-var agreement (CharPart(2) correctness). This gives depth-1 2-var agreement at [x,t]/[x',t'] directly. Then depth-0 3-var transfer follows from depth-1 2-var quantifier part.
5. At K>0 inductive step: IH gives depth-(K+1) 2-var. Use `exist_transfer_3var_nonconstenv` with h_xt from IH. The sorry at lines 460/480 are resolved by the depth boost using CharPart(K+1).

### Why This Works

The key insight: depth-1 2-var agreement at [x,t]/[x',t'] INCLUDES the between-zone condition as one of its depth-0 3-var quantifier conditions. So if we can establish depth-1 2-var agreement WITHOUT first proving each 3-var condition independently, the between-zone follows.

The formula-level transfer achieves this: `existPart_succ_n1_bypass_k0` builds a formula A such that `temporal_truth M atomMap t A <-> exists x, nf_eval_nf M 1 2 [x, t] chi` for ALL Prior structures M. The formula A encodes the entire 2-var existential (including between-zone conditions) as a temporal formula at t. Since A works for both M and N, and A's truth is preserved by depth-2 1-var agreement, the entire depth-1 2-var existential transfers.

### Files to Modify

- `PriorComposition.lean`: Add CharPart parameter, restructure K=0 base case, close all 4 sorry
- `KampBypass.lean`: Thread CharPart through `prior_2var_transfer_until/since` calls
- `KampMutualInduction.lean`: Provide CharPart at call sites (already available)

## Sorry Inventory

| # | File | Line | Statement | Status |
|---|------|------|-----------|--------|
| 1 | PriorComposition.lean | 274 | depth0_3var_exist_transfer_until (between-zone) | STATEMENT FALSE |
| 2 | PriorComposition.lean | 345 | depth0_3var_exist_transfer_since (between-zone) | STATEMENT FALSE |
| 3 | PriorComposition.lean | 460 | exist_transfer_3var_nonconstenv forward | Phase 6 target |
| 4 | PriorComposition.lean | 480 | exist_transfer_3var_nonconstenv backward | Phase 6 target |

## Key Decisions

1. **Counterexample confirms FALSE**: Not a proof technique issue -- the lemma statements are mathematically false.
2. **Zones 1,2,4,5 are correct**: The non-between zones (w < t, w = t, w = x, w > x) are proved sorry-free using `cross_extend_bwd_1var` and direct witnesses.
3. **Merge Phases 5+6**: The between-zone problem at depth 0 and at general K share the same root cause (need CharPart for temporal formula transfer). Implementing them together avoids duplicated restructuring.
