# Phase 4 Handoff: C5 Forward Cases with Adjacent-Pair Guard

## Status: PARTIAL (2 of 6 forward cases fixed)

## Session: sess_1778114001_749277

## Changes Made

### 1. Strengthened h_actual Condition (line 668-670)

Changed the counterexample test from pointwise guard to adjacent-pair guard:

**Before**: `¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧ pc.ξ ∈ χ.g pc.x y`

**After**: `¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧ (∀ a b, Adjacent χ.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ χ.g a b)`

This makes the not-actual case trivial (push_neg gives the guard directly) and is used by h_no_wit in the actual branch.

### 2. Fixed h_no_wit Usage (line 836-843)

Updated `h_guard_implies_no_event` to construct the adjacent-pair guard from the pointwise guard at (pc.x, x'). Since (pc.x, x') is adjacent, any adjacent pair (a,b) with pc.x ≤ a and b ≤ x' must have a = pc.x and b = x'.

### 3. Fixed Not-Actual Case (line 1488-1492) -- TASK 4.1 DONE

Changed destructuring from `⟨y, hy_dom, hy_lt, hy_η, _⟩` to `⟨y, hy_dom, hy_lt, hy_η, h_guard⟩` and threaded guard through.

### 4. Fixed n=0 Case (line 685-787) -- TASK 4.2 DONE

Switched `lemma_2_4` → `lemma_2_4_with_guard` to extract `pc.ξ ∈ B`. Added guard proof: only adjacent pair (a,b) with pc.x ≤ a and b ≤ y is (max_old, y), and g'(max_old, y) = B, so ξ ∈ B gives the guard.

## Remaining Forward Errors (4 errors)

### Error 1: Walk A, u_max = max_old (line ~971)

**Problem**: The walk advances from x' to max_old and places y beyond. For the guard, need ξ ∈ g'(a,b) for ALL adjacent pairs between pc.x and y. The pair (max_old, y) is handled by lemma_2_4_with_guard. But OLD adjacent pairs along the walk (e.g., (x', x''), (x'', x'''), ...) need ξ ∈ g(a,b), which is NOT tracked by the current walk.

**Approach**: The plan says to restructure by splitting at (pc.x, x') instead of walking. However, this doesn't work for ALL sub-cases of the splitting formula (specifically: when η ∉ g, η.neg ∈ g, ξ ∈ g, conj ∈ g, the splitting can't produce η ∈ D). See detailed analysis below.

**Alternative approach**: Keep the walk but prove the guard invariant. For each walk pair (a, b) where a ∈ U (walk set): since U(ξ,η) ∈ f(a) and (a,b) is adjacent, the BurgessR3Maximal structure may give ξ ∈ g(a,b) through a careful argument. This requires proving a walk invariant lemma.

### Error 2: Walk B Eta-Shortcut (line ~1044)

**Problem**: Returns χ unchanged when η ∈ f(u_next). The witness u_next has η ∈ f(u_next), but the adjacent-pair guard requires ξ ∈ g(a,b) for pairs from pc.x to u_next, which isn't available (same as Walk A).

**Approach**: Remove eta-shortcut and always fall through to splitting. But the splitting code uses `h_eta_u_next` (η ∉ f(u_next)) to derive `η.neg ∈ f(u_next)`. Removing the by_cases requires handling both cases in the splitting. The lemma_2_8 sub-case specifically needs η.neg ∈ f(u_next), so it fails when η ∈ f(u_next).

**Alternative**: Keep the eta-shortcut but prove the guard. This requires the same walk invariant as Walk A.

### Error 3: Walk B Splitting (line ~1223)

**Problem**: Split at (u_max, u_next) producing z = midpoint. Need ξ ∈ g'(a,b) for adjacent pairs from pc.x to z. The new pairs (u_max, z) and (z, u_next) get B' and B'' from splitting. Need ξ ∈ B'. Additionally, OLD pairs from pc.x to u_max need ξ ∈ g(a,b) -- same walk invariant issue.

**Approach if walk invariant solved**: g ⊆ B' from h_split_result gives ξ ∈ B' when ξ ∈ g(u_max, u_next). When ξ ∉ g(u_max, u_next): strengthened lemma_2_7 gives ξ ∈ B'. Need to thread this through h_split_result_u.

### Error 4: Not-Condition(i) Splitting (line ~1456)

**Problem**: Split at (pc.x, x') producing z = midpoint. Only one adjacent pair (pc.x, z) since z is between pc.x and x' (adjacent in old domain). Need ξ ∈ B' = g'(pc.x, z).

**Approach**: Add ξ ∈ B' to h_split_result return type. In all sub-cases:
- lemma_2_6 sub-cases with ξ ∈ g: g ⊆ B' → ξ ∈ B' ✓
- lemma_2_7 sub-cases: returns ξ ∈ B' directly (Phase 2 strengthening) ✓
- lemma_2_8 sub-cases: returns ξ ∈ B' (line 4044 of PointInsertion.lean) ✓
- lemma_2_7 with conj: returns conj ∈ B'. Since B' is CUD: ξ ∈ B' from conj = ξ∧U(ξ,η) via conjunction elimination in CUD set.
- lemma_2_6 with ξ ∉ g: this sub-case exists when both η.neg ∉ g and ξ ∉ g. Need to redirect to lemma_2_7 with ξ.

**This case is closest to being fixable** -- only the not-condition(i) branch is needed, and the guard proof is straightforward once h_split_result includes ξ ∈ B'.

## Deep Analysis: Why the Walk is Mathematically Essential

Burgess 2.10 case n=m+1 says: when condition (i) holds (conj ∈ f(x') AND ξ ∈ g(x,x')), "reduce to case n=m by replacing x by x'". This is INDUCTION, not splitting. The walk advances x to x', reducing the number of points after x by 1.

The plan (Task 4.4) proposed splitting at (pc.x, x') instead of walking. This works when the splitting produces η ∈ D. Analysis of sub-cases:

| η ∈ g? | η.neg ∈ g? | ξ ∈ g? | conj ∈ g? | Splitting approach | η ∈ D? | ξ ∈ B'? |
|---------|-----------|--------|----------|-------------------|--------|---------|
| Yes | No | Yes | * | lemma_2_6(η.neg) | Yes (dne) | Yes (g⊆B') |
| Yes | No | No | * | lemma_2_7(ξ) | Yes | Yes |
| No | Yes | Yes | Yes | **BLOCKED** | **No** | - |
| No | Yes | Yes | No | lemma_2_7(conj) via BX5 | Yes | Yes (B' CUD) |
| No | Yes | No | * | lemma_2_7(ξ) | Yes | Yes |
| No | No | Yes | * | lemma_2_6(η.neg) | Yes (dne) | Yes (g⊆B') |
| No | No | No | * | lemma_2_7(ξ) | Yes | Yes |

The BLOCKED case: η ∉ g, η.neg ∈ g, ξ ∈ g, conj ∈ g with condition (i). In this case:
- lemma_2_6 with any β ∉ g puts β.neg in D, not β. η ∉ g → D gets η.neg (wrong sign).
- lemma_2_7 needs some γ ∉ g with U(γ,η) ∈ f(pc.x). ξ ∈ g, conj ∈ g. No available γ.
- lemma_2_8 needs neg_disj ∈ f(x'). But conj ∈ f(x') (condition (i)), so conj.neg ∉ f(x'), making neg_disj = η.neg ∧ conj.neg ∉ f(x').

This sub-case requires the walk (induction on n). The walk is NOT avoidable.

## Recommended Next Steps

### Priority 1: Fix Not-Condition(i) Splitting (Error 4)

Modify h_split_result to return `pc.ξ ∈ B'` in all sub-cases. Then add guard proof to c5_forward_witness. This fixes 1 error and establishes the pattern.

Steps:
1. Add `pc.ξ ∈ B'` to h_split_result return type (change `∃ B' D B'' ...` to include extra conjunct)
2. In each sub-case:
   - lemma_2_6 + ξ ∈ g: use `h_g_sub_B' h_ξ_g`
   - lemma_2_7/2_8: extract from strengthened return type
   - lemma_2_7 with conj: use CUD property of B' + conj_left
   - lemma_2_6 + ξ ∉ g: redirect to lemma_2_7 with ξ
3. Add guard proof: `fun a b h_adj h_le_a h_le_b => by ... ` showing a = pc.x, b = z, and ξ ∈ B'

### Priority 2: Prove Walk Guard Invariant (Errors 1, 2, 3)

Create a lemma: for any adjacent pair (a,b) in the walk set U where a < b and both have U(ξ,η) ∈ f, prove ξ ∈ g(a,b). This likely requires:
1. Using BurgessR3Maximal(f(a), g(a,b), f(b))
2. Showing that the "obligation propagation" rRelation(f(a), g(a,b)) holds as a consequence of burgessR3
3. Then: untl(ξ,η) ∈ f(a) → η ∈ g ∨ (ξ ∈ g ∧ untl(ξ,η) ∈ g)
4. If η ∈ g(a,b): then for any intermediate point, η ∈ f. Combined with the guard at earlier pairs and h_no_wit, derive a contradiction. So η ∉ g(a,b). Therefore ξ ∈ g(a,b).

**Key question**: Does BurgessR3Maximal(f(a), g(a,b), f(b)) imply rRelation(f(a), g(a,b))? If yes, the walk invariant follows. This needs investigation.

### Priority 3: Handle Walk B Eta-Shortcut (Error 2)

If walk invariant is proved: keep eta-shortcut but add guard using walk invariant + h_no_wit.
If walk invariant fails: remove eta-shortcut and redirect all cases through splitting. This requires handling the η ∈ f(u_next) sub-case in the splitting code.

### Priority 4: Mirror for Since (Phase 5, 6 errors)

All 6 backward errors are exact mirrors of the forward cases.

## Key Infrastructure Available

- `lemma_2_4_with_guard` (PointInsertion.lean:5255): returns ξ ∈ B ✓
- `lemma_2_7` (PointInsertion.lean:3620): returns ξ ∈ B' (Phase 2) ✓
- `lemma_2_8` (PointInsertion.lean:4026): returns ξ ∈ B' ✓
- `Adjacent` (ChronicleTypes.lean:139): x ∈ dom ∧ y ∈ dom ∧ x < y ∧ ∀ z ∈ dom, ¬(x < z ∧ z < y)
- `g_sub_g_new`: old g-values propagate to sub-intervals
- `g_sub_f_insert`: old g-values flow into new f-values
- `burgessR_conj` / `burgessRSince_conj` (RRelation.lean:1062,1080): guard conjunction ✓
- `untl_conj_guard` / `snce_conj_guard` (RRelation.lean:972,1018): MCS-level conjunction ✓

## Convention Reminder
Our `untl(guard=ξ, event=η)` = Burgess `U(event=ξ, guard=η)`. SWAPPED.

## Important: BurgessR3Maximal vs rRelation

BurgessR3Maximal(A, B, C) uses `burgessRSet` (content-based), NOT `rRelation` (obligation propagation). These are DIFFERENT concepts (see ChronicleTypes.lean:275-285). The walk guard invariant proof may need to establish rRelation from BurgessR3Maximal, or use a different approach entirely.
