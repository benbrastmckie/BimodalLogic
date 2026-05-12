# Handoff: Stage Induction Boundary Cases

Task: 123 | Session: sess_1778596964_32e08b | Date: 2026-05-12

## Current State

File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

The proof body of `limitDomSubtype_isSuccArchimedean` (lines ~1190-1402) has been REPLACED with a stage induction approach. The old convergence proof (real analysis with iSup, gap-at-L) is gone. The new proof structure:

1. `succ_reaches_dom_N` (line 1160): Stage induction lemma. For any N and any a, b in dom(N) with a <= b, exists k with succ^[k](a) = b.

2. `limitDomSubtype_isSuccArchimedean` (line 1469): Wires up the stage induction. Picks N = max(M_a, M_b) where a in dom(M_a) and b in dom(M_b). Calls succ_reaches_dom_N.

### What Compiles

The file builds with 2 sorry sites in `succ_reaches_dom_N`. The following cases are proved:
- Base case (N=0): dom(0) = {0}, a = b = 0.
- Case 1: both a, b in dom(N) -- IH directly.
- Case 3-between: a in dom(N), b new, b between dom(N) points w < b < w_next. IH gives succ^[k](a) = w_next. Orbit convexity gives j with succ^[j](a) = b.
- Case 2-between: a new, b in dom(N), a between dom(N) points w < a < w_next. IH gives succ^[m](w) = b. Orbit convexity gives j with succ^[j](w) = a. Then succ^[m-j](a) = b.
- Case 4: both new -- dom_new_unique gives a = b.

### Two Sorry Sites

1. **Line ~1295**: Case 3-above-max. a in dom(N), b in dom(N+1)\dom(N), b > max(dom(N)). We have succ^[k1](a) = max_N_sub (from IH). Need succ^[k](a) = b. The difficulty: succ(max_N_sub) <= b but we can't show equality.

2. **Line ~1448**: Case 2-below-min. a in dom(N+1)\dom(N), b in dom(N), a < min(dom(N)). Need succ^[k](a) = b.

## Analysis: Why Boundary Cases Are Hard

### The Core Difficulty

The stage induction uses `induction N generalizing a b`. The IH gives the result for dom(N), but the boundary cases need the result at stage N+1 or later stages. Specifically:

- In Case 3-above-max: succ(max_N_sub) is the next limit_dom point after max(dom(N)). It may NOT be in dom(N+1) -- it enters at a potentially much later stage M+1. So succ(max_N_sub) and b are both in limit_dom, but succ(max_N_sub) might not be in dom(N+1).

- If succ(max_N_sub) = b: done. But if succ(max_N_sub) < b: need to iterate further, requiring succ_reaches_dom_N at a later stage -- which is what we're proving.

### Why succ(max_N_sub) might not equal b

The succ function uses limit_dom (the full union of all stages), not dom(N+1). succ(max_N_sub) is the C5-bot witness for max(dom(N)), which enters at the stage where C5-bot at max is processed. This could be:
- Stage N (if the elimination at N processes C5-bot at max): then succ(max) enters dom(N+1) = dom(N) union {succ(max)}. By dom_new_unique, succ(max) = b. DONE.
- Stage M > N (if C5-bot at max is processed later): succ(max) enters dom(M+1) with M+1 > N+1. succ(max) might not be b.

### Key Insight (ω + ω* impossibility)

The gap-at-L scenario creates an ω + ω* substructure in limit_dom. This VIOLATES Prior-UZ (Axiom.prior_UZ). Proof: Consider the formula p = "the point is in the pred-chain part" (semantically). At orbit element c_0: F(p) holds (pred-chain elements are future points). Prior-UZ gives U(p, neg p). The U witness y must have p in f(y). But between c_0 and any pred-chain element, there are infinitely many orbit elements with neg p. However, the C5 guard requires neg p at all limit_dom between c_0 and y. If y is a pred-chain element d_k, then all orbit elements c_1, c_2, ... between c_0 and d_k must have neg p, which they do (they're orbit elements). But ALSO all pred-chain elements between d_k and c_0... wait, d_{k+1}, d_{k+2}, ... are also between c_0 and d_k and have p in f. So neg p DOESN'T hold at them. Contradiction with the U guard.

This means: the gap scenario forces some pred-chain element d_m between c_0 and d_k to have BOTH p and neg p, which is impossible in an MCS. Therefore, the gap scenario is impossible IF we can formalize this argument.

The challenge is that "p = is pred-chain" might not correspond to any FORMULA in the logic. We need a formula that holds at pred-chain elements but not orbit elements. Report 12 analyzes this and concludes it might not exist universally (constant-model case).

### Possible Resolution Paths

1. **Strong induction on N**: Change `induction N generalizing a b` to a strong induction where IH gives the result for ALL M <= N. Then in the boundary case, after computing succ(max_N_sub), find M such that succ(max_N_sub) and b are both in dom(M), and apply the result at stage M. This requires M <= N, which isn't guaranteed.

2. **WellFounded recursion on (N, distance)**: Use a lexicographic measure (N, |dom(N) cap [a,b]|) that strictly decreases. In the boundary case, the new point reduces dom(N+1) cap [succ(max), b] to a smaller interval.

3. **Close gap-at-L directly**: Restore the convergence proof and close the sorry using Prior-UZ or construction-specific arguments. The report 12 analysis shows Prior-UZ alone can't universally distinguish orbit from pred-chain. But the construction MIGHT guarantee enough structure.

4. **LocallyFiniteOrder**: Prove Set.Finite for limit_dom cap [a,b]. This is equivalent to proving IsSuccArchimedean but might be easier if we can show the omega-chain stabilizes in bounded intervals.

5. **Induction on (max(M_a, M_b) - min(M_a, M_b))**: Induct on the "spread" of stages where a and b enter. This might avoid boundary cases.

### Recommended Next Step

Option 1 (strong induction) seems most promising. The key change: replace `induction N generalizing a b` with strong induction. In the boundary case:
- Compute succ(max_N_sub) = z.
- z in dom(M_z+1) for some M_z.
- b in dom(N+1).
- Both z and b in dom(max(M_z+1, N+1)).
- Apply the theorem at stage max(M_z+1, N+1).
- But this stage might be > N+1, so we need the result at higher stages.
- With strong induction on N, the IH gives the result for all M <= N. But max(M_z+1, N+1) might be > N+1.

Actually this doesn't help either. The issue is that M_z is determined by the construction and could be arbitrarily large.

Alternative: don't induct on stages at all. Instead, use well-founded induction on some measure of (a, b) that decreases at each succ step. For example, since succ(a) > a and succ(a) <= b, the "distance" b - succ(a) < b - a in Q. But Q is not well-ordered under >.

The CORRECT approach might be to combine the stage induction with an additional argument specific to the boundary case:

For Case 3-above-max: The new point b above max(dom(N)) was placed by the C5 forward walk. In the discrete case, this walk terminates at the base case (when the source is max of dom). The base case creates a witness y = max+1 (or fresh). The guard between max and y is the ξ-guard from the C5 formula. If the C5 is for U(top, bot) (the C5-bot case): ξ = bot, and succ(max_sub) = y = b.

But the C5 at stage N might not be for U(top, bot). It could be for any U formula.

However, in dom(N+1), max_N and b are ADJACENT (no dom(N+1) points between them, since b > max_N and max_N is max of dom(N), and b is the only new point). The g(max_N, b) in dom(N+1) is set by the elimination.

Now, U(top, bot) in limit_f(max_N). By limit_satisfies_c5_strong: there exists a C5-bot witness z > max_N with bot guard. z = succ(max_N_sub) in limit_dom. z is between max_N and... what? Between max_N and succ(max_N_sub), no limit_dom.

b is also > max_N. b in limit_dom. So b >= succ(max_N_sub) = z.

If b = z: done.
If b > z: z is between max_N and b. z in limit_dom. z not in dom(N+1) (if z != b, and b is the unique new point). 

In dom(N+1), max_N and b are adjacent. z is a limit_dom point between them, but z not in dom(N+1). By adj_g_mem_limit_f: g(max_N, b) from dom(N+1) is in limit_f(z). If bot in g(max_N, b): then bot in limit_f(z), contradicting z being in limit_dom (bot_not_in_mcs).

So: IF bot in g(max_N, b) at stage N+1, THEN no limit_dom between max_N and b, so z >= b, so z = b (since z <= b), done.

IF bot NOT in g(max_N, b): then the C5-bot witness z is between max_N and b without contradiction. z < b. And we need more steps.

So the question reduces to: does g(max_N, b) at stage N+1 contain bot?

This depends on the specific elimination at stage N. If the C5 at stage N was U(eta, bot) at max_N: then xi = bot, and g(max_N, b) = B which contains bot. DONE.

If the C5 at stage N was U(eta, xi) with xi != bot: g(max_N, b) contains xi, not necessarily bot. And we CAN'T conclude z = b.

But ALSO: limit_satisfies_c5_strong at max_N for U(top, bot) gives z with bot guard in limit_g(max_N, z). This is a DIFFERENT C5 from the one at stage N. The z from limit_satisfies_c5_strong IS succ(max_N_sub).

The key: adj_g_mem_limit_f at (max_N, b) in dom(N+1) gives: for any w in limit_dom between max_N and b, g(max_N, b) from dom(N+1) is in limit_f(w). But we ALSO have the C5-bot giving: bot in limit_f(w) for all w between max_N and z (where z = succ(max_N_sub)).

These are DIFFERENT guards: the first is g(max_N, b) from dom(N+1), the second is the C5-bot guard from limit_satisfies_c5_strong.

The C5-bot guard: no limit_dom between max_N and z. So if b > z, then b is NOT between max_N and z (b > z > max_N). So the C5-bot guard doesn't say anything about points between z and b.

OK I think the boundary case genuinely cannot be handled by the simple stage induction. The proof needs a fundamentally different approach.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`:
  - Replaced proof body of `limitDomSubtype_isSuccArchimedean` (deleted convergence proof)
  - Added `succ_reaches_dom_N` lemma with 2 sorry boundary cases
  - Deleted helper lemmas: `succ_iter_le_pred_of_lt_forall`, `succ_iter_eq_gives_next`
  - File builds with sorry warnings
