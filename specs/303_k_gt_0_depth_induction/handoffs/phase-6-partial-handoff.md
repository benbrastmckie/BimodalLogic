# Phase 6 Partial Handoff: Multi-Depth Char Refactor + Helper Factoring

## Session
sess_1781827486_855fab

## Status
PARTIAL - Parameter refactoring complete and compiling, sorry locations factored into clean helpers, proofs not yet closed.

## What Was Accomplished

### 1. Multi-Depth Char Parameter Refactoring (COMPLETE)
Changed all 4 theorems in PriorComposition.lean from single-depth `char_kp1_fn` to multi-depth `char_fn / char_correct`:

**Old**: `char_kp1_fn : NormalForm sig (K + 1) 1 -> Formula` with correctness at depth K+1 only
**New**: `char_fn : forall d, NormalForm sig d 1 -> Formula` with `char_correct` at all `d <= K+1`

### 2. Call Site Updates (COMPLETE)
- **KampBypass.lean**: Added `ih_all_char` parameter to `existPart_succ_n1_bypass`. Constructed `char_all_fn` with `dif_pos` conditional from `ih_all_char`. Updated both call sites (Until at line 642, Since at line 709).
- **KampMutualInduction.lean**: Added `ih_all_char` parameter to `existPart_succ`. Changed `kamp_mutual_induction` from simple induction to `Nat.strong_induction_on` to provide CharPart at all lower depths. Constructed `ih_all_char` from the strong IH.
- **NfCharFormula.lean**: Added third `sorry` parameter at line 651 to match the new signature.

### 3. Helper Theorem Factoring (COMPLETE)
Created two new private theorems factoring out the 3-var existential transfer:
- `nonconstenv_exist_transfer_until` (line 213)
- `nonconstenv_exist_transfer_since` (line 276)

Both take multi-depth char + Prior axioms + depth-(D+1) 1-var agreement at x/x' and t/t', and prove existential transfer of depth-D 3-var NFs.

The 4 original sorry in the main theorems are now replaced with calls to these 2 helpers.

### 4. Witness Scaffolding (PARTIAL)
Both helpers have forward/backward constructors with cross_extend_bwd/fwd witnesses extracted. Still sorry at the point where zone analysis + full 3-var NF agreement is needed.

## What Remains (Sorry Inventory)

4 sorry total in PriorComposition.lean (lines 256, 262, 301, 307):
- 2 in `nonconstenv_exist_transfer_until` (forward + backward)
- 2 in `nonconstenv_exist_transfer_since` (forward + backward)

## Key Technical Blocker

The proof requires showing that for a witness w' found via `cross_extend_bwd_1var`, the full depth-D 3-var NF at [w',x',t'] matches. The available hypotheses give:
- depth-D 2-var at [w,x]/[w',x'] (from `hw'_x`)
- depth-D 2-var at [w,t]/[w'_t,t'] (from `hw'_t`)
- depth-D 1-var at w/w' (from `h_w_wx`)

But the 3-var env [w,x,t] involves ALL THREE positions simultaneously, and the 2-var data covers only two at a time. Bridging from 2x(2-var) to 1x(3-var) is the core mathematical challenge.

### Why This Is Hard

1. **Not circular**: Cannot use 2-var agreement at [x,t]/[x',t'] to extend via nf_extend_bwd, because that's what the outer theorem is proving.

2. **Zone 3 (between zone)**: When t < w < x, need to find w' with t' < w' < x' and same depth-D 1-var NF. Requires Prior-UZ/SZ + char_fn. The witness w'_x from cross_extend satisfies w'_x < x' (from the 2-var order atom) but w'_x > t' is NOT guaranteed. Similarly w'_t > t' but w'_t < x' is not guaranteed.

3. **Depth cascade**: Even in outer zones where order matching is automatic, the quantifier part of the depth-D 3-var NF requires depth-(D-1) 4-var existential transfer, which has the same structure at higher arity.

### Suggested Approach for Next Dispatch

The proof needs induction on D (depth of sub_nf):

**D=0 (base case)**: Purely atomic, no quantifiers. Zone analysis + predicate matching from 1-var agreement + order matching from zone determines all 3-var atoms. Should be provable with `depth0_3var_witness_check` (already exists in this file).

**D=d+1 (inductive step)**: 
- Atoms: same zone argument
- Quantifiers (depth-d 4-var existentials): Use a GENERALIZED version of the helper at arity 4. This requires reformulating the theorem for arbitrary arity n >= 2 (not just n=3).

The generalized theorem would state: for all n >= 2, given depth-(D+1) 1-var agreement at each component pair with compatible orders and multi-depth char, transfer depth-D n-var existentials. The induction on D handles the quantifier cascade because each step reduces D by 1 and increases n by 1 (from n-var to (n+1)-var), but D reaches 0 after finitely many steps where everything is atomic.

## Immediate Next Action

1. Implement `nonconstenv_exist_transfer_until` for D=0 (purely atomic, no char_fn needed)
2. Generalize the helper to arbitrary arity n >= 2
3. Prove the generalized theorem by induction on D

## Build Status
Full `lake build` passes successfully.
