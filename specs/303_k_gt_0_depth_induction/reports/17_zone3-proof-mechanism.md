# Research Report: Zone-3 Existential Transfer Proof Mechanism

- **Task**: 303 - k_gt_0_depth_induction
- **Focus**: Concrete proof mechanism for the 2 sorry in PriorComposition.lean (lines 283, 329)
- **Date**: 2026-06-19
- **Status**: Research complete -- proof architecture identified with actionable steps
- **Prior Work**: Extends report 16 (strong-d-induction-research.md) with adversarial verification

## 1. Exact Goal States at Sorry Positions

### Line 283 (Until zone: t < x)

```lean
case right
-- Available hypotheses:
h_x : ∀ nf : NF (K✝ + 2) 1, nf_eval_nf M (K✝ + 2) 1 (fun _ => x) nf ↔ nf_eval_nf N (K✝ + 2) 1 (fun _ => x') nf
h_t : ∀ nf : NF (K✝ + 2) 1, nf_eval_nf M (K✝ + 2) 1 (fun _ => t) nf ↔ nf_eval_nf N (K✝ + 2) 1 (fun _ => t') nf
h_order_M : t < x
h_order_N : t' < x'
char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula
char_correct : ∀ d ≤ K✝ + 1, ∀ nf_1 M h_UZ h_SZ t, temporal_truth M atomMap t (char_fn d nf_1) ↔ nf_eval_nf M d 1 (fun _ => t) nf_1
K : ℕ  -- strong induction variable (= K✝ renamed)
ih_strong : ∀ m < K, ∀ nf : NF (m + 2) 2,
    nf_eval_nf M (m + 2) 2 (Fin.cons x (fun _ => t)) nf ↔ nf_eval_nf N (m + 2) 2 (Fin.cons x' (fun _ => t')) nf
h_atom : ∀ a : AtomKind sig 2, atom_eval M (Fin.cons x (fun _ => t)) a ↔ atom_eval N (Fin.cons x' (fun _ => t')) a
sub_nf : NormalForm sig (K + 1) (2 + 1)

⊢ (∃ x_1, nf_eval_nf M (K + 1) (2 + 1) (Fin.cons x_1 (Fin.cons x fun x ↦ t)) sub_nf) ↔
    ∃ x, nf_eval_nf N (K + 1) (2 + 1) (Fin.cons x (Fin.cons x' fun x ↦ t')) sub_nf
```

### Line 329 (Since zone: x < t)

Identical structure but with `h_order_M : x < t` and `h_order_N : x' < t'`.

## 2. Available Infrastructure Assessment

### Directly Usable (no sorry, correct types)

| Lemma | File:Line | Gives |
|-------|-----------|-------|
| `nf_agreement_from_shared_nf` | NormalForm.lean:291 | Full NF agreement from shared characteristic |
| `nf_characteristic_satisfies` | NormalForm.lean:224 | Any structure satisfies its own characteristic |
| `nf_agreement_monotone` | NormalForm.lean:339 | Depth weakening: depth-k agreement => depth-m for m <= k |
| `cross_extend_bwd_1var` | KampComposition.lean:97 | From depth-(K+1) 1-var, given x: find x' with depth-K 2-var |
| `cross_extend_fwd_1var` | KampComposition.lean:76 | Symmetric: given x' find x |
| `exist_transfer_nvar_constenv` | KampComposition.lean:122 | Existential transfer on CONSTANT envs |
| `constenv_2var_determines` | NfComposition.lean:624 | 2-var determines n-var on constant envs |
| `pred_agree_cross` | KampComposition.lean:32 | Predicate agreement from 1-var NF agreement |
| `semantic_prior_UZ` | PriorDefs.lean:22 | First occurrence above (formula-based) |
| `semantic_prior_SZ` | PriorDefs.lean:33 | Last occurrence below (formula-based) |
| `generalExistPart_from_classical` | GeneralExistPart.lean:63 | Existential characterized as top/bot given full r-var NF env |

### Private but Reproducible

| Lemma | File | Pattern |
|-------|------|---------|
| `nf_extend_fwd` | KampBypass.lean:36 | From depth-(K+1) r-var agreement + c' in N: find c in M with depth-K (r+1)-var |
| `nf_extend_bwd` | KampBypass.lean:57 | Symmetric: from c in M find c' in N |
| `nf_skipIdx_cross` | PriorComposition.lean:448 | Project (n+1)-var agreement to n-var |

### Key Structural Facts

1. **nf_eval_nf at depth K+1, arity 3**: `(∀ a, atom_eval [w,x,t] a ↔ sub_nf.1 a = true) ∧ (∀ sub4 : NF K 4, (∃ v, nf_eval M K 4 [v,w,x,t] sub4) ↔ sub_nf.2 sub4 = true)`
2. **ih_strong at m = K-1** (when K > 0): gives depth-(K+1) 2-var agreement at [x,t]/[x',t']
3. **nf_extend_bwd from depth-(K+1) 2-var**: gives depth-K 3-var for matched witnesses
4. **Fundamental depth gap**: nf_extend from depth D gives depth-(D-1); goal is depth-D

## 3. The Fundamental Problem and Its Resolution

### Why the Depth Gap Exists

From `ih_strong` at m=K-1 (depth-(K+1) 2-var), `nf_extend_bwd` gives depth-K 3-var full agreement. But the goal requires depth-(K+1) 3-var existential transfer. Each application of `nf_extend` drops depth by 1. This gap is irreducible by purely algebraic NF machinery.

### Resolution: Prior-UZ/SZ + Recursive Depth Descent

The Prior axioms bridge the gap. The proof proceeds by proving `nf_eval N (K+1) 3 [w',x',t'] sub_nf` directly (for a carefully chosen w'), decomposing into:

**(a) Atom part**: From matching 1-var NF types at w/w' (gives predicates) + known orders t' < w' < x' (zone 3 encoding). Provable from `pred_agree_cross` + order facts.

**(b) Quantifier part**: For each sub4 : NF K 4, prove `(∃ v', nf_eval N K 4 [v',w',x',t'] sub4) ↔ sub_nf.2 sub4 = true`. Since M satisfies sub_nf, sub_nf.2 sub4 = true iff ∃ v in M with the depth-K 4-var evaluation. The transfer of this existential uses the SAME zone-decomposition recursively at depth K-1 (and lower), terminating at depth 0 where NFs are purely atomic.

### Correct Architecture: Nested Strong Induction

```
prove_exist_transfer (K : Nat) (sub_nf : NF (K+1) 3) :
  (∃ w, nf_eval M (K+1) 3 [w,x,t] sub_nf) ↔ (∃ w', nf_eval N (K+1) 3 [w',x',t'] sub_nf)
```

The proof uses the OUTER strong induction variable K. At each K:
1. **Zone decomposition on w**: extract order profile from sub_nf.1 to determine which zone w occupies
2. **Zones 1, 5** (w < t or w > x): Use `cross_extend_bwd_1var` from h_t or h_x. The found w' has depth-(K+2-1) = depth-(K+1) 2-var agreement with w at a constant-env pair. Then `constenv_2var_determines` extends to higher arity. Transfer sub_nf via the resulting agreement.
3. **Zones 2, 4** (w = t or w = x): Use t' or x' directly as witness.
4. **Zone 3** (t < w < x): The hard case. See Section 4.

## 4. Zone-3 Proof Strategy (Detailed)

### Step 1: Find w' via Prior-UZ

Given w with t < w < x in M satisfying sub_nf:

1. Let `nf_w := nf_characteristic M (K+1) 1 (fun _ => w)` (the depth-(K+1) 1-var type of w)
2. From `char_correct` at d = K+1 (bound: K+1 ≤ K✝+1, satisfied with equality since K = K✝): `temporal_truth M atomMap w (char_fn (K+1) nf_w)` holds.
3. Since t < w: `∃ s > t, temporal_truth M atomMap s (char_fn (K+1) nf_w)` holds (witnessed by w).
4. Transfer "existence above t": By h_t (depth-(K+2) 1-var at t/t'), the quantifier condition of the depth-(K+2) NF at t encodes existentials at depth K+1 around t. Specifically, `cross_extend_bwd_1var` from h_t gives: for w in M, ∃ w₂ in N with depth-(K+1) 2-var agreement at [w,t]/[w₂,t']. Since w > t, the 2-var NF encodes w₂ > t'. So w₂ > t'.
5. Similarly from h_x: ∃ w₁ in N with depth-(K+1) 2-var at [w,x]/[w₁,x'] and w₁ < x' (since w < x).
6. Now: w₁ < x' satisfies char_fn (K+1) nf_w (from the 2-var agreement, project to 1-var: w₁ has same depth-(K+1) 1-var type as w). Similarly w₂ > t' satisfies it.
7. Apply `semantic_prior_UZ` at N, t', with formula `char_fn (K+1) nf_w`:
   - Precondition: ∃ s > t' with the formula (w₂ witnesses this)
   - Conclusion: ∃ w' > t', w' satisfies the formula, and all r between t' and w' satisfy the negation.
8. w' = first occurrence > t'. Since w₁ < x' also satisfies the formula and w₁ > t' (from w₁ < x' and t' < x'), w' ≤ w₁ < x'. So **t' < w' < x'** (zone 3 in N).
9. w' satisfies `char_fn (K+1) nf_w`, so by char_correct: `nf_eval_nf N (K+1) 1 (fun _ => w') nf_w`. By `nf_agreement_from_shared_nf`: full depth-(K+1) 1-var agreement at w/w'.

**Issue with Step 6**: Projecting from 2-var to 1-var loses one depth level. `cross_extend_bwd_1var` from h_t (depth-(K+2) 1-var) gives depth-(K+1) 2-var at [w,t]/[w₂,t']. Projecting via `cross_1var_from_2var` gives depth-(K+1) 1-var agreement between w and w₂. Since nf_w is at depth K+1, this confirms w₂ satisfies nf_w. Similarly for w₁. So Step 6 IS valid.

### Step 2: Prove w' Satisfies sub_nf (Atoms)

`nf_eval_nf N (K+1) 3 [w',x',t'] sub_nf` atom part:
- Predicates at w': from depth-(K+1) 1-var agreement with w + M's satisfaction of sub_nf
- Predicates at x': from h_x (depth-(K+2) 1-var) + M's satisfaction
- Predicates at t': from h_t + M's satisfaction
- Order w' vs x': w' < x' (from Step 1.8)
- Order w' vs t': t' < w' (from Step 1.8)
- Order x' vs t': t' < x' = h_order_N

All match sub_nf.1's encoding (which says index 0 > index 2 and index 0 < index 1 for zone 3 Until).

### Step 3: Prove w' Satisfies sub_nf (Quantifier Part)

For each sub4 : NF K 4, need: `(∃ v', nf_eval N K 4 [v',w',x',t'] sub4) ↔ sub_nf.2 sub4 = true`.

From M's satisfaction: `sub_nf.2 sub4 = true ↔ ∃ v, nf_eval M K 4 [v,w,x,t] sub4`.

So need: `(∃ v, nf_eval M K 4 [v,w,x,t] sub4) ↔ (∃ v', nf_eval N K 4 [v',w',x',t'] sub4)`.

**This is a depth-K 4-var existential transfer on non-constant env [w,x,t]/[w',x',t'].**

### Resolution of the Recursive Quantifier Part

From ih_strong at m = K-1 (when K >= 1): depth-(K+1) 2-var agreement at [x,t]/[x',t']. Via `nf_extend_bwd` (reproducible locally): for w in M, ∃ w'' in N with depth-K 3-var full agreement at [w,x,t]/[w'',x',t'].

**Key fact**: w'' from nf_extend_bwd has the same depth-K 3-var NF type as w at [w,x,t]. Since w' has the same depth-(K+1) 1-var type as w (from Step 1), and w'' has the same depth-K 3-var type as w at [w,x,t]:
- w' has depth-(K+1) 1-var matching w (strictly stronger)
- w'' has depth-K 3-var matching (weaker but in right env)

If we could show w' = w'' (or that w' has the same depth-K 3-var NF as w at [w,x,t]), then from depth-K 3-var full agreement, the quantifier condition gives depth-(K-1) 4-var existential transfer.

**But we need depth-K 4-var, not depth-(K-1).**

### The Correct Resolution: `generalExistPart_from_classical` Argument

The depth-K 4-var existential transfer follows from the following observation:

From depth-K 3-var full agreement at [w,x,t]/[w',x',t'] (where w' is determined by nf_extend, not Prior-UZ):
- `∀ nf3 : NF K 3, nf_eval M K 3 [w,x,t] nf3 ↔ nf_eval N K 3 [w',x',t'] nf3`
- Its quantifier condition gives: `(∃ v, nf_eval M (K-1) 4 [v,w,x,t] chi4) ↔ (∃ v', nf_eval N (K-1) 4 [v',w',x',t'] chi4)`

For depth-K 4-var: `nf_eval N K 4 [v',w',x',t'] sub4` = atoms at [v',w',x',t'] match sub4.1 + quantifier conditions at depth K-1.

The atoms are determined by: v's predicates/orders relative to w',x',t'. The quantifier conditions at depth K-1 ask about depth-(K-1) 5-var existentials. From depth-(K-1) 4-var agreement (gotten from nf_extend on the depth-K 3-var), we get depth-(K-2) 5-var existential transfer.

**The cascade terminates at depth 0** where everything is purely atomic. At each level:
- Atoms transfer from the matched NF agreement at one level below
- Quantifier existentials transfer from nf_extend at the level below THAT

Formally, this is the pattern of `generalExistPart_from_classical`: given depth-(D+1) r-var agreement, the existential at depth-D (r+1)-var transfers. The proof in GeneralExistPart.lean (lines 80-91) does exactly this: uses the quantifier condition of the agreement to find a matching witness, then applies nf_agreement_from_shared_nf.

**So the depth-K 4-var existential transfer follows directly from depth-(K+1) 3-var agreement at [w,x,t]/[w',x',t']... which is what we're trying to establish!**

### Breaking the Circularity: The Two-Witness Approach

The circularity is broken by using TWO witnesses:

1. **w_nf** (from nf_extend_bwd, using ih_strong at m=K-1): depth-K 3-var full agreement at [w,x,t]/[w_nf,x',t']. This gives the quantifier transfer but w_nf might not be in zone 3.

2. **w_prior** (from Prior-UZ/SZ): in zone 3 (t' < w_prior < x') with matching depth-(K+1) 1-var type. Gives atoms but not automatically the quant part.

If w_nf = w_prior (same point), we're done. But in general they differ.

**The key insight from `generalExistPart_from_classical`**: The formula characterizing the existential is either `top` (always satisfiable if env matches) or `bot` (never satisfiable). So:
- If sub_nf.2 sub4 = true for M at [w,x,t], then by generalExistPart, ANY structure/env satisfying the same depth-(K+1) 3-var NF as [w,x,t] also has the existential.
- We need w_prior to satisfy the same depth-(K+1) 3-var NF as w at [w,x,t].

The depth-(K+1) 3-var NF has atoms + quant conditions. We've shown atoms match for w_prior. The quant conditions ARE what we're trying to prove. So this is still circular at depth K+1.

**FINAL RESOLUTION**: The proof must use strong induction on K for the QUANTIFIER PART as well. Specifically:

For K = 0: depth-1 3-var NF = atoms + depth-0 4-var existentials. Depth-0 4-var is purely atomic (just predicate + order matching). The existential `∃ v, nf_eval N 0 4 [v,w',x',t'] sub4` asks: "is there a v with specific predicates and orders relative to w',x',t'?" On a Prior structure, this is determined by density. Zones for v:
- v < t' (or v > x', etc.): density from Prior-UZ/SZ guarantees existence if compatible
- v between any consecutive pair: same

So at K=0, the quantifier part can be proved directly using Prior density for each zone of v.

For K > 0: the strong IH gives the result at K-1. The quantifier part of depth-(K+1) 3-var asks about depth-K 4-var existentials. These involve depth-K 4-var NF evaluation, whose own quantifier part asks about depth-(K-1) 5-var existentials. By applying the SAME argument recursively (or using the strong IH on the "inner" K for sub-problems), the recursion terminates.

**The correct implementation**: Define a helper lemma proved by `Nat.rec` (or `Nat.strong_induction_on`) on K inside the strong induction body:

```lean
have quant_transfer : ∀ sub4 : NF K 4,
    (∃ v, nf_eval M K 4 [v,w,x,t] sub4) ↔ (∃ v', nf_eval N K 4 [v',w',x',t'] sub4) := by
  -- From depth-K 3-var agreement at [w,x,t]/[w_nf, x', t'] (via nf_extend from ih_strong at m=K-1)
  -- Apply the quantifier condition of this agreement
  ...
```

Actually, the cleanest approach is:

From depth-(K+1) 2-var agreement at [x,t]/[x',t'] (ih_strong at m=K-1):
- Quantifier condition: `∀ chi3, (∃ y, nf_eval M K 3 [y,x,t] chi3) ↔ (∃ y', nf_eval N K 3 [y',x',t'] chi3)`
- Take chi3 = nf_characteristic M K 3 [w,x,t]: the M-side is witnessed by w
- So ∃ w_nf in N with nf_eval N K 3 [w_nf,x',t'] (nf_char M K 3 [w,x,t])
- By nf_agreement_from_shared_nf: depth-K 3-var FULL agreement at [w,x,t]/[w_nf,x',t']
- The quantifier condition of THIS agreement: `∀ chi4, (∃ v, nf_eval M (K-1) 4 [v,w,x,t] chi4) ↔ (∃ v', nf_eval N (K-1) 4 [v',w_nf,x',t'] chi4)`

Now: w_prior (from Prior-UZ) has the same depth-(K+1) 1-var type as w. w_nf has the same depth-K 3-var type as w at [w,x,t]/[w_nf,x',t']. From depth-K 3-var agreement, projecting the first component (via nf_skipIdx_cross at j=0): w_nf has same depth-K 1-var type as w.

Since w_prior has depth-(K+1) 1-var matching w, and w_nf has depth-K 1-var matching w, w_prior has STRICTLY MORE information matching. In particular, w_prior's depth-K 1-var matches w_nf's. So w_prior and w_nf have the same depth-K 1-var NF type.

**If w_prior and w_nf have the same depth-K 3-var NF at [?,x',t']**: then they're interchangeable for the quantifier conditions. But having the same 1-var type at depth K does NOT give the same 3-var type at depth K.

## 5. Recommended Proof Architecture

After extensive analysis (corroborated by report 16), the viable approach is:

### Architecture: Zone Decomposition + Recursive Depth Descent

```lean
-- Inside the strong induction body, after obtaining h_atom:
intro sub_nf; rw [← h_N_quant sub_nf]
-- Goal: (∃ w, nf_eval M (K+1) 3 [w,x,t] sub_nf) ↔ (∃ w', nf_eval N (K+1) 3 [w',x',t'] sub_nf)
constructor
· -- Forward: ∃ w in M → ∃ w' in N
  rintro ⟨w, hw⟩
  -- Zone decomposition on w based on sub_nf atom part:
  -- Extract order encoding from sub_nf.1
  -- Case split on zone of w
  -- Zone 3 (t < w < x):
  --   1. Get depth-(K+1) 1-var type of w via nf_characteristic
  --   2. Transfer existence above t' via cross_extend_bwd_1var from h_t
  --   3. Apply Prior-UZ at N to get first occurrence w' in (t', x')
  --   4. Prove nf_eval N (K+1) 3 [w',x',t'] sub_nf:
  --      a. Atoms: from 1-var agreement + orders
  --      b. Quantifier: use ih_strong at m=K-1 for depth-K 3-var,
  --         then generalExistPart_from_classical pattern for depth-K 4-var transfer
  sorry
· -- Backward: symmetric
  sorry
```

### Estimated Complexity

- Zone decomposition (extracting order bits from sub_nf.1): ~50 lines
- Zones 1, 2, 4, 5 (straightforward transfers): ~100 lines each direction
- Zone 3 witness placement (Prior-UZ/SZ): ~100 lines
- Zone 3 atom part verification: ~50 lines
- Zone 3 quantifier part (key difficulty): ~200-400 lines
- Total per direction: ~500-700 lines
- Both directions + Since mirror: ~1200-1800 lines

### Key Risk: Quantifier Part Closure

The quantifier part at depth K+1 requires depth-K 4-var existential transfer. The most viable approach:

1. Use ih_strong at m=K-1 to get depth-(K+1) 2-var agreement
2. Apply nf_extend_bwd to get depth-K 3-var full agreement at [w,x,t]/[w_nf,x',t']
3. Since w_nf satisfies the same depth-K 3-var NF as w at [w,x,t]: the quantifier conditions of the depth-K 3-var NF give depth-(K-1) 4-var existential transfer for w_nf
4. Show w_prior has the same depth-K 3-var NF as w_nf at [?,x',t']: if w_prior's 1-var type at depth K+1 matches w's, and the env [x',t'] is the same, then by nf_agreement_from_shared_nf applied to the 2-var agreement at [w_prior,x']/[w,x] (from cross_extend_bwd on h_x), we can establish the 3-var matching.

**Alternative (simpler but requires more infrastructure)**: Prove a general `nonconstenv_exist_transfer` lemma that handles arbitrary non-constant env transfers on Prior structures via the top/bot characterization from `generalExistPart_from_classical`. The key insight: the formula is always top or bot, so the transfer depends only on whether the env has the RIGHT NF type — which follows from the atom matching + depth-K 3-var matching we already establish.

## 6. Adversarial Self-Verification

### Challenged Claims

| Claim | Status | Evidence |
|-------|--------|----------|
| ih_strong at m=K-1 gives depth-(K+1) 2-var | VERIFIED | m=K-1 < K, depth = m+2 = K+1, goal confirmed via lean_goal |
| char_correct covers d=K+1 | VERIFIED | Bound is d ≤ K✝+1, K=K✝ in strong induction body |
| cross_extend_bwd_1var from h_t gives w₂ > t' | VERIFIED | h_t is depth-(K+2) 1-var, cross_extend gives depth-(K+1) 2-var at [w,t]/[w₂,t']; 2-var NF encodes order, so w₂ > t' from zone-3 encoding |
| Prior-UZ squeeze places w' in (t', x') | VERIFIED | Existence above t' from h_t transfer + existence below x' from h_x transfer + UZ gives first occurrence ≤ the below-x' witness |
| nf_extend_bwd is private to KampBypass | VERIFIED | `private theorem` at line 57; must be reproduced locally or made public |
| Depth gap (D-2 vs D-1) from nf_extend | VERIFIED | nf_extend drops exactly 1 depth level |
| generalExistPart formula is always top or bot | VERIFIED | generalExistPart_from_classical uses Classical.em; satisfiable → top, else → bot |

### Uncertain Claims (Confidence < 80%)

1. **w_prior and w_nf can be shown to have same depth-K 3-var NF** (65%): w_prior has depth-(K+1) 1-var matching w. w_nf has depth-K 3-var matching w at [w,x,t]. The 1-var type at depth K+1 is STRONGER than 1-var at depth K. But 1-var type does NOT determine 3-var type (counterexample: different 2-var contexts can give different 3-var NFs for same 1-var type). This merging may require additional infrastructure.

2. **Zone 1/5 use constenv_2var_determines** (70%): For zone 1 (w < t < x), env [w,x,t] is NOT constant. The claim that constenv_2var_determines applies is WRONG for non-constant envs. Zone 1/5 need their own argument (possibly via nf_extend from h_t/h_x directly, then checking that the NF extends correctly).

3. **K=0 base case closes via Prior density alone** (75%): At K=0, depth-1 3-var quantifier part is depth-0 4-var existentials (purely atomic). But "finding a v with specific predicates + orders" on a Prior structure requires showing that Prior-UZ/SZ guarantees existence in each zone. For monadic predicates, this is true (Prior structures are P-separating), but the formal proof may be non-trivial.

### Revised Claims After Verification

- **Zone 1/5 approach**: Should use `cross_extend_bwd_1var` from h_t (for zone 1, w < t) or h_x (for zone 5, w > x) to find w' with depth-(K+1) 2-var agreement at [w,t]/[w',t'] (or [w,x]/[w',x']). Then prove the 3-var NF at [w',x',t'] by: atoms from 2-var agreement + projection, quantifier part from a similar recursive argument. NOT via constenv_2var_determines.

- **Quantifier part closure**: The most promising approach remains using `generalExistPart_from_classical`'s top/bot pattern: if the existential is satisfiable on ANY Prior structure realizing the correct (K+1) 3-var NF, it's satisfiable on ALL such structures. Since M witnesses it, N must too — IF N's env satisfies the same NF. This requires establishing the NF matching first (partial circularity).

## 7. Specific Risks

1. **Variable shadowing**: Nat.strong_induction_on K renames the outer K✝ to K inside the lambda body. Helper theorems defined outside cannot use the inner K directly. All helpers must be defined as `have` inside the body.

2. **Heartbeat limits**: Zone decomposition + recursive depth argument may exceed 200000 heartbeats. Need `set_option maxHeartbeats 800000` and factoring into multiple private theorems.

3. **Quantifier part closure may require additional infrastructure**: If the top/bot argument from `generalExistPart_from_classical` cannot be directly applied (because it requires the full env NF matching), a new helper lemma for "depth-K (n+1)-var existential transfer from depth-(K+1) n-var full agreement" (essentially making `nf_extend_bwd`'s conclusion public) would be needed.

4. **nf_extend_bwd is private**: Must either make it public, reproduce it locally in PriorComposition.lean, or use a different mechanism. The proof of nf_extend_bwd is 8 lines and easily reproduced.

5. **Since mirror**: The Since case (line 329) is symmetric but requires separate Prior-SZ (last occurrence below) instead of Prior-UZ. The order encoding in sub_nf.1 is reversed.

## 8. Concrete Next Steps

1. **Make nf_extend_bwd/fwd public** (or reproduce locally): ~15 lines.
2. **Implement zone decomposition**: extract order bits from sub_nf.1 to determine w's zone. ~50 lines.
3. **Implement K=0 base case**: purely atomic 4-var transfer via Prior density. ~150 lines.
4. **Implement zone 3 witness placement** (Prior-UZ/SZ + char_fn): ~100 lines.
5. **Implement zone 3 atom verification**: ~50 lines.
6. **Implement zone 3 quantifier transfer**: This is the crux. Use ih_strong + nf_extend_bwd + generalExistPart top/bot pattern. ~200-400 lines.
7. **Implement zones 1/5**: cross_extend + recursive argument. ~100 lines each.
8. **Implement zones 2/4**: trivial. ~20 lines each.
9. **Mirror for Since**: ~same structure with reversed orders. Factor shared helpers.

Total new code estimate: **800-1200 lines** replacing 2 sorry.
