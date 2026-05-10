# Handoff: Birth-Monotonicity Approach Refuted

## Current State

The sorry remains at `limitDomSubtype_isSuccArchimedean` in
`Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (line 1068).
No code changes were committed. The plan's approach (lex-pair with birth-monotonicity)
is BLOCKED because birth-monotonicity is false.

## Key Finding: Birth-Monotonicity is FALSE

The plan's Phase 2 claims `birth(succ(z)) > birth(z)` for all z in LimitDomSubtype.
This is FALSE. Task 118's analysis (handoff at specs/118_.../handoffs/01_issucc-archimedean-analysis.md)
correctly identified this, and the task 119 research report's attempt to refute task 118
contains a critical error.

### The Research Report's Error

The research report (01_connectivity-proof-research.md, lines 59-86) argues:

> If succ(z).val in dom_{birth(z)}, both z and succ(z) are adjacent in dom_s.
> The C5 counterexample U(T, bot) at z is NOT resolved because bot not in g_n(z, succ(z))
> (since "g-values are consistent"). Therefore the C5 walk inserts a midpoint,
> contradicting the successor property.

**The flaw**: The claim "g-values are consistent" (hence bot not in g_n) is WRONG
for finite-stage g-values. The `BurgessR3Maximal` construction can produce
g-values equal to `Set.univ` (containing bot). The codebase explicitly states:
"at finite stages g-values can be Set.univ (inconsistent)" (ChronicleTypes.lean, line 356).

### Why g-values MUST contain bot in this case

For z and succ(z) to be adjacent in limit_dom (successor property), NO point can
ever be inserted between them. The only way to prevent insertion is for the C5
counterexample U(T, bot) at z to be RESOLVED at every processing stage. Resolution
requires bot in g_n(z.val, succ(z).val). Therefore:

1. The BurgessR3Maximal construction MUST choose an extension containing bot
   (i.e., g = Set.univ) for the pair (z.val, succ(z).val).
2. This makes the U(T, bot) counterexample resolved (witness = succ(z), with the
   guard vacuously satisfied since no dom_n between them).
3. No new point is inserted. z and succ(z) remain adjacent. Consistent.

The research report's contradiction argument is circular: it assumes bot not in g
to derive a contradiction, but bot MUST be in g precisely because z and succ(z)
are adjacent (which is what we're trying to prove about).

### Concrete Counterexample to Birth-Monotonicity

Consider: succ(z) is born at stage k (first in dom_k). z is born at stage m > k
(first in dom_m). At stage m, z is inserted between some point p and succ(z).val
in dom_{m-1} (since succ(z).val in dom_{m-1} and no limit_dom between z and succ(z)).
The pair (z.val, succ(z).val) becomes adjacent in dom_m. The g-value g_m(z, succ(z))
is constructed as BurgessR3Maximal = Set.univ. This seals the interval forever.
Result: birth(succ(z)) = k < m = birth(z). Birth-monotonicity violated.

## Why the Lex-Pair Approach Fails

The plan uses the lex-pair (domN_count, birth(b)) as a WF measure. When b.val not in dom_N,
the first component doesn't decrease, and the plan relies on birth(pred(b)) < birth(b)
(from birth-monotonicity via pred_birth_lt). Since birth-monotonicity is false,
there's no guarantee the second component decreases.

## Why Simple dom_N Induction Also Fails

Induction on |dom_N cap (a.val, b.val]| works when b.val in dom_N (count decreases by 1
going to pred(b)). But when pred(b).val not in dom_N, the count for pred(b) equals
the count for b minus 1 (good!). The problem arises when PROVING the IH: for pred(b)
itself, we need to handle pred(pred(b)), and if pred(b).val not in dom_N, then
pred(pred(b)) might have the SAME count as pred(b). The strong induction IH
requires STRICTLY smaller, which isn't guaranteed.

Wait -- actually, re-examining: |dom_N cap (a.val, pred(b).val]| = |dom_N cap (a.val, b.val]| - 1
ALWAYS (since b.val in dom_N and b.val is the only dom_N element in (pred(b).val, b.val]).
So from b to pred(b), the count ALWAYS decreases by exactly 1.

THIS MEANS THE SIMPLE INDUCTION SHOULD WORK! The key insight:
- Original b has b.val in dom_N, so count is at least 1 (b.val contributes)
- pred(b) has count = count(b) - 1 (always, regardless of whether pred(b).val in dom_N)
- IH applies to pred(b) directly (strictly smaller count)
- We DON'T need to recurse manually from pred(b) -- the IH handles it

The IH is: "for ALL b' with count < k and a <= b', exists n, succ^[n] a = b'"

This is a STRONG induction on the count. For count k:
- Take b' with count = k and a <= b'.
- If a = b': n = 0.
- If a < b': let pb = pred(b'). count(pb) = count(b') - 1 = k - 1 < k (since b'.val in dom_N).

BUT WAIT: in the IH application, we need b'.val in dom_N (to ensure count decreases).
For the ORIGINAL b, we have b.val in dom_N. But in the IH, b' is arbitrary with
count = k. Does b'.val have to be in dom_N?

count(b') = |dom_N cap (a.val, b'.val]|. If b'.val in dom_N, then b'.val contributes
to the count. If b'.val not in dom_N, the count could still be k (from other dom_N
elements in (a.val, b'.val] that aren't b'.val).

For the case b'.val NOT in dom_N:
- pred(b').val < b'.val
- No dom_N between pred(b') and b' (no limit_dom there)
- b'.val not in dom_N
- So dom_N cap (pred(b').val, b'.val] = empty
- Therefore count(pred(b')) = count(b') = k

The count DOESN'T decrease! We're stuck again.

## WAIT -- Correction: The Simple Approach DOES Work

Re-reading more carefully: the issue only arises if we enter the strong induction
with a b' where b'.val NOT in dom_N. But in the ORIGINAL call, b.val IS in dom_N.
And the strong induction just says: for the original (a, b) with count k, we can
apply IH to pred(b) which has count k-1.

The IH for count k-1 says: "for ALL b' with count <= k-1 and a <= b', the result holds."
To prove P(k-1), we'd take arbitrary b' with count k-1 and show exists n...

For such b': if b'.val in dom_N, pred(b') has count k-2, IH applies.
If b'.val NOT in dom_N: pred(b') has count k-1 = same. STUCK again.

So the simple induction genuinely fails for intermediate points not in dom_N.

## Viable Approaches (from Task 118 Analysis)

### Approach A: Topological / Real Analysis

Show limit_dom cap [a.val, b.val] is finite using:
- Bolzano-Weierstrass: infinite bounded set has accumulation point
- Accumulation point contradicts discreteness (isolated points)
- Requires: Mathlib real analysis + embedding limit_dom into R

Key difficulty: limit_dom is a subset of Q, not R. Need to reason about limits in R
of sequences in Q. Mathlib has infrastructure for this.

### Approach B: Direct Construction Analysis

Track which counterexample_enum indices produce points in (a.val, b.val) and show
only finitely many do. This requires detailed analysis of the enumeration structure.

### Approach C: WellFoundedGT on Set.Icc

If we can show Set.Icc a b (in LimitDomSubtype) is finite, then it's WellFoundedGT
and WellFoundedGT.toIsSuccArchimedean applies. But proving Set.Icc is finite is
equivalent to the original problem.

### Approach D: LocallyFiniteOrder

Prove `LocallyFiniteOrder (LimitDomSubtype A h_mcs)` using topological finiteness.
Then `IsSuccArchimedean` follows from the mathlib instance for LinearLocallyFiniteOrder.

## Recommendation

The most promising approach is **Approach A** (topological finiteness):

1. Define an order-embedding of LimitDomSubtype into Q (trivial, it's a subtype)
2. Show any infinite subset of Q in a bounded interval has an accumulation point (in R)
3. Show an accumulation point contradicts the discreteness (each point is isolated)
4. Conclude limit_dom cap [a.val, b.val] is finite
5. Use finite interval => WellFoundedGT => IsSuccArchimedean

This requires ~50-100 lines of Lean using Mathlib's real analysis infrastructure.
The main risk is ensuring the topological/metric arguments translate cleanly to the
subtype setting.

## Session Context

- Session: sess_1778426154_b531e1
- Task: 119 (issucc_archimedean_direct_proof)
- Plan: specs/119_issucc_archimedean_direct_proof/plans/01_lex-pair-proof.md
- All plan phases marked [BLOCKED]
