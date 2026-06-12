# Literature Transcription Report: Task 273 -- Backward Direction of P2(k+1)

**Task**: 273 - chronicle_gap_contradiction_proof
**Started**: 2026-06-11T21:00:00Z
**Completed**: 2026-06-11T23:30:00Z
**Task Type**: lean4

## Executive Summary

- **Chosen approach**: Rabinovich 2014 (composition-based exists-forall normal form), specialized to Prior structures. This is a **reformulation of nf_exist_formula_nested** that faithfully encodes ALL of sub_nf.2, not just the interval ssn's.
- The root cause of all three failed attempts is identified: **the formula must encode non-interval ssn conditions explicitly**, not defer them to char_{k+1}(nf_x). The 1-var NF of x does NOT determine what happens at points y outside the interval (t,x).
- The published construction (Rabinovich Prop 3.5 + Section 5) operates at the level of **exists-forall formulas with quantifier-free predicates** alpha_j, beta_j. It does NOT directly produce a formula for "exists x with a given 2-var NF." The bridge from normal forms to exists-forall formulas is Proposition 4.3, which reduces FOMLO formulas to disjunctions of exists-forall formulas. This is NOT a 1-step operation.
- **Key finding**: The Lean P2(k+1) statement asks for a SINGLE temporal formula equivalent to a specific existential. Rabinovich's construction gives this, but the formula is more complex than what nf_exist_formula_nested currently builds. Specifically, the formula must be a disjunction over ALL possible "interval decomposition patterns" consistent with sub_nf, including patterns that handle non-interval ssn's.

## Context and Scope

### What the sorry asks

At NegationClosure.lean:828, the goal is:

```
h_formula : temporal_truth M atomMap t (nf_exist_formula_nested k char_kp1 char_k parent_atoms sub_nf)
|- exists x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
```

This is the backward direction of P2(k+1): if the temporal formula for the existential `exists x, nf_eval_nf M (k+1) 2 (x, t) sub_nf` holds at t, then such an x actually exists.

### What sub_nf encodes

`sub_nf : NormalForm sig (k+1) 2` is a pair:
- `sub_nf.1 : AtomKind sig 2 -> Bool` -- the atom assignment (predicates at x and t, plus order x < t / t < x)
- `sub_nf.2 : NormalForm sig k 3 -> Bool` -- the quantifier assignment: for each depth-k arity-3 NF `ssn`, whether `exists y` with that 3-var NF at (y, x, t) holds

Each `ssn : NormalForm sig k 3` places the witness y in one of these order regions relative to x, t:
1. **y > x > t** (or y > x, x > t, etc. depending on sub_nf's order)
2. **y = x**
3. **t < y < x** (or x < y < t) -- the INTERVAL case
4. **y = t**
5. **y < t < x** (or y < x < t, etc.)

### Why the current formula fails

The current `nf_exist_formula_nested` (lines 421-522 of NegationClosure.lean) encodes:
- Atom compatibility of x with sub_nf.1 (correct)
- Order of x relative to t via Until/Since (correct)
- **Interval ssn's** (region 3): uses `Since(char_k(nf_y), top)` for positive ssn's with y in (t,x) -- this captures only the **1-var NF** of y, NOT the full 3-var NF ssn
- **Non-interval ssn's** (regions 1, 2, 4, 5): **NOT encoded at all**

Two distinct failures:
1. **Non-interval ssn's are dropped**: sub_nf.2 conditions for y > x, y = x, y = t, y < t appear nowhere in the formula. Two sub_nf's differing only on these conditions produce the same formula.
2. **Interval ssn's use 1-var char_k**: `char_k(nf_y)` captures the 1-var NF of y at depth k, but the 3-var NF `ssn` at (y, x, t) is NOT determined by the 1-var NFs of y, x, t (at depth k >= 1, the quantifier part of ssn involves 4-var interactions).

## Findings

### 1. What Rabinovich's Construction Actually Does

Rabinovich's proof has three layers:

**Layer 1 -- Exists-forall formulas (Section 3)**: An exists-forall formula `psi(z_0, ..., z_m)` has the form:
```
exists x_n ... exists x_0 (ordering on x_i, z_j)
  AND alpha_j(x_j) for each j    [point types]
  AND beta_j holds on (x_{j-1}, x_j) for each j  [interval types]
```
where alpha_j, beta_j are **quantifier-free** predicates (Boolean combinations of atoms).

**Layer 2 -- Translation to temporal formulas (Prop 3.5)**: An exists-forall formula with ONE free variable z_k (at position k in the sequence x_0 < ... < x_n) translates to:
```
A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1}) ...)))
AND
A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... (A_0 AND Hitherto B_0) ...)))
```
where A_j is the temporal formula for alpha_j and B_j is the temporal formula for beta_j.

**Layer 3 -- Negation closure (Prop 4.2 + Section 5)**: The negation of an exists-forall formula with at most 2 free variables is equivalent (over Dedekind-complete chains) to a **disjunction** of exists-forall formulas.

**Layer 0 -- From FOMLO to exists-forall (Prop 4.3)**: Every FOMLO formula is equivalent to a disjunction of exists-forall formulas, by structural induction using Layer 3 for the negation case.

### 2. The Gap Between Rabinovich and the Lean P2 Statement

The Lean P2(k) statement asks:

> For each parent_atoms and sub_nf : NormalForm sig k 2, there exists a temporal formula A such that A(t) <-> exists x, nf_eval_nf M k 2 (x, t) sub_nf.

The existential `exists x, nf_eval_nf M k 2 (x, t) sub_nf` is a FOMLO formula phi(t) with one free variable. By Rabinovich's Theorem 4.4, phi(t) is equivalent to a TL(Until, Since) formula over Dedekind-complete chains.

But Rabinovich's proof goes through SEVERAL intermediate steps:
1. phi(t) is equivalent to a disjunction of exists-forall formulas (Prop 4.3)
2. Each exists-forall formula with one free variable translates to a temporal formula (Prop 3.5)

Step 1 itself requires **induction on quantifier depth** and uses negation closure (Prop 4.2) at each step. This is NOT a direct translation -- it is a structural induction on the FOMLO formula phi.

### 3. How the Lean Induction Maps to Rabinovich

The Lean master_induction proves P1(k) and P2(k) simultaneously by induction on k. This is an induction on **quantifier depth** (depth of NormalForm).

**P1(k)**: For each depth-k arity-1 NF, there is a temporal formula characterizing it. This is the direct analog of "each n-characteristic (rank-k type) of a single point is definable by a temporal formula of rank <= f(k)."

**P2(k)**: For each depth-k arity-2 NF sub_nf, there is a temporal formula for the existential. This is the analog of "the existential quantification of a rank-k 2-variable formula has a temporal equivalent."

The key insight is that `nf_eval_nf M k 2 (x, t) sub_nf` **IS** a FOMLO formula of quantifier depth k with 2 free variables. The existential `exists x, ...` is a FOMLO formula of quantifier depth k with 1 free variable. By Rabinovich's argument, this should have a temporal equivalent.

But the proof of Prop 4.3 (every FOMLO formula -> disjunction of exists-forall formulas) is by structural induction on the FOMLO formula, and it uses **negation closure** (Prop 4.2). The induction goes:
- Atomic: trivial (exists-forall already)
- Disjunction: trivial
- **Negation**: Uses Prop 4.2 -- the hard part
- **Existential quantification**: Uses Lemma 3.4

The structure of `nf_eval_nf M (k+1) 2 (x, t) sub_nf` is:
```
(forall a : AtomKind sig 2, atom_eval M (x, t) a <-> sub_nf.1 a = true)
AND
(forall ssn : NormalForm sig k 3,
   (exists y, nf_eval_nf M k 3 (y, x, t) ssn) <-> sub_nf.2 ssn = true)
```

This is a conjunction of:
- Quantifier-free conditions (atoms)
- For each ssn with sub_nf.2(ssn) = true: `exists y, nf_eval_nf M k 3 (y, x, t) ssn`
- For each ssn with sub_nf.2(ssn) = false: `not exists y, nf_eval_nf M k 3 (y, x, t) ssn`

So `exists x, nf_eval_nf M (k+1) 2 (x, t) sub_nf` has the form:
```
exists x, [atoms(x,t)] AND [conjunction of existentials and negated existentials over y]
```

This is NOT directly an exists-forall formula (it has alternating quantifiers: exists x, forall/exists y). But each inner `exists y, nf_eval_nf M k 3 (y, x, t) ssn` is a depth-k formula, and by **P2(k) applied at arity n=3** (or by composition), this inner existential has a temporal equivalent -- which can be used as a **quantifier-free predicate** in the exists-forall framework.

### 4. The Published Construction, Faithfully Transcribed

Here is the construction that Rabinovich's argument gives for P2(k+1), mapped to the project's notation. The key idea: **use P2(k) to eliminate the inner quantifiers, reducing the depth-(k+1) existential to a depth-0 existential over an expanded signature**.

#### Step 1: Expand the signature

For each `ssn : NormalForm sig k 3` with `sub_nf.2 ssn = true`, the condition `exists y, nf_eval_nf M k 3 (y, x, t) ssn` is a depth-k formula in the free variables (x, t). By the composition/induction hypothesis, this condition has a temporal equivalent at fixed x when t is the evaluation point (or vice versa). However, this is a 2-variable condition, not a 1-variable condition.

**Critical observation (from Rabinovich Section 4, Definition 4.1)**: In the canonical TL(Until, Since)-expansion of M, each TL formula A defines a predicate `{a in M | M, a |= A}`. The 2-variable condition `exists y, nf_eval_nf M k 3 (y, x, t) ssn` becomes, for each fixed order region of y relative to x and t, a conjunction of conditions that can be expressed in terms of:

- 1-var temporal formulas at x (for conditions involving only y and x)
- 1-var temporal formulas at t (for conditions involving only y and t)
- interval conditions between t and x (for conditions involving y between t and x)

#### Step 2: Decompose by order region of y

For each ssn, the existential `exists y, nf_eval_nf M k 3 (y, x, t) ssn` decomposes according to where y sits:

**(a) y > x (assuming t < x)**: The condition `exists y > x, nf_eval_nf M k 3 (y, x, t) ssn` involves:
- Atoms: predicates at y, order y > x, y > t
- Quantifier part: `ssn.2 : NormalForm sig (k-1) 4 -> Bool` -- conditions on a fourth variable z relative to y, x, t

When restricted to the pair (y, x) with y > x, this is a depth-k arity-2 existential relativized to the future of x. By **P1(k)**, the depth-k 1-var NF of x captures the quantifier behavior of x, including `exists y > x with given depth-k NF`. So: **this condition is encoded in char_{k+1}(nf_x)** -- the depth-(k+1) 1-var NF of x includes, in its quantifier part, exactly whether `exists y > x` with each depth-k arity-2 NF of (y, x).

Wait -- this is only the (y, x) projection. The ssn is a 3-var NF of (y, x, t), not just a 2-var NF of (y, x). The 3-var NF includes conditions involving BOTH x and t, such as `exists z with z between y and t` or `exists z with z between x and t`. These conditions are NOT captured by the 1-var NF of x alone.

**This is EXACTLY the problem that killed all three Lean attempts.**

#### Step 3: The actual Rabinovich strategy (via canonical expansion)

Rabinovich does NOT try to encode the 3-var NF conditions directly. Instead, he works at the level of the **canonical TL expansion** (Definition 4.1). The key idea:

In the canonical expansion, every TL formula becomes an atom. So the "quantifier-free predicates" alpha_j and beta_j in the exists-forall formula are **Boolean combinations of TL formulas**, not just Boolean combinations of the original predicates.

This means the induction is on **quantifier depth of the FOMLO formula over the expanded signature**, where the atoms include all TL formulas of bounded rank.

For Rabinovich, the induction works as follows:
1. Start with `phi(t) = exists x, psi(x, t)` where psi has quantifier depth k in the original signature
2. In the canonical expansion by all TL formulas of rank r (for suitable r), psi becomes equivalent to a formula of **lower quantifier depth** (because some quantified conditions become atomic)
3. Apply the exists-forall machinery to this lower-depth formula

**This is exactly what the GHR93 Proposition 7 does explicitly**: the induction is on (n, r) pairs where n is the EF-game length and r is the rank of the temporal formulas used as atoms.

### 5. The Correct Construction for the Lean P2(k+1) Backward Direction

After careful analysis of all the literature, here is what the Lean proof needs:

**The formula `nf_exist_formula_nested` must encode ALL of sub_nf.2, including non-interval ssn's.** Here is how:

For each ssn : NormalForm sig k 3 with sub_nf.2(ssn) = true, the order region of variable 0 (y) relative to variable 1 (x) and variable 2 (t) is determined by ssn's atom assignment on order atoms. There are 5 regions (for the case t < x):

**Region 1 (y > x > t)**: `exists y > x, nf_eval_nf M k 3 (y,x,t) ssn`. This is a condition on x at depth k involving the pair (y, x). But it ALSO involves t via ssn. The condition decomposes:
- The (y, x) component is a depth-k arity-2 NF condition on the pair (y, x)
- The (y, t) component is a depth-k arity-2 NF condition on the pair (y, t)
- These are NOT independent: they share y

**This is the 3-variable problem.** The published proofs handle it in two different ways:

**(A) GHR93 Proposition 7 approach**: Induction on n (EF game length) with arity m as a parameter. The induction statement is:
> For all n, r: if Duplicator wins (1+3f(n))-round rank-(r+4f(n)) forward games on each interval, then Duplicator wins n-round rank-r backward games.

This handles all arities simultaneously because the EF game is played on the full structure, not on a fixed number of variables.

**(B) Rabinovich approach**: Work in the canonical expansion where TL formulas are atoms. The 3-variable existential becomes a 2-variable existential in the expanded signature (because the y-conditions that involve only y and one of x, t become atoms in the expansion).

**For the Lean formalization, the cleanest path is (B)**, because:
- P1(k) already gives temporal characterization formulas at depth k
- P2(k) at arity 2 gives existential formulas at depth k
- The depth-(k+1) 3-var existential `exists y, nf_eval_nf M k 3 (y, x, t) ssn` can be decomposed using P2(k) applied to **2-var projections**

#### The Decomposition (Composition Theorem for Prior Structures)

For a 3-var NF ssn at (y, x, t) with t < y < x (the interval case), the key observation is:

On **Prior structures**, the depth-k 3-var NF of (y, x, t) is **determined** by:
- The depth-k 2-var NF of (y, x) -- call it `proj_yx(ssn)`
- The depth-k 2-var NF of (y, t) -- call it `proj_yt(ssn)`
- The depth-k 1-var NF of y -- call it `proj_y(ssn)`

This is because on Prior structures (which are Dedekind complete), for any point z in a quantifier condition of ssn:
- If z is between y and x: determined by the (z, y, x) triple, which is captured by the (y, x) projection's quantifier part
- If z is between y and t: determined by the (z, y, t) triple, which is captured by the (y, t) projection
- If z is between t and x but not between y: z is either between t and y or between y and x, so still captured
- If z is outside [t, x]: captured by the 1-var NF of the relevant endpoint

**This is the Feferman-Vaught composition theorem specialized to linear orders** (Libkin Lemma 3.7, Thomas 1997): when a linear order is split at a point y, the type of the whole is determined by the types of the parts.

**Critical rank accounting**: The composition gives the depth-k 3-var NF of (y, x, t) from the depth-k 2-var NFs of (y, x) and (y, t). This is an **equality of rank**, not a rank increase. The proof is by induction on k, using the composition lemma at each step.

#### The Correct Formula

For P2(k+1) with sub_nf : NormalForm sig (k+1) 2 and t < x:

```
Formula := disjunction over all compatible nf_x : NormalForm sig (k+1) 1 of:
  Until(
    event = char_{k+1}(nf_x)
           AND [non-interval conditions encoded as char_{k+1}(nf_x) constraints]
           AND [interval positive conditions],
    guard = [interval negative conditions]
  )
```

where the non-interval conditions are:

For each ssn with sub_nf.2(ssn) = true and y NOT in the interval (t, x):
- **y > x**: This condition is `exists y > x with given 3-var NF`. On Prior structures, this decomposes into a condition on the (y, x) 2-var NF projection. By P2(k) applied to the (y, x) projection, this becomes a temporal formula at x. By P1(k+1), this condition is EXACTLY the question "does nf_x.2(proj_yx(ssn)) = true?" So: **check that nf_x is compatible with the y > x ssn conditions from sub_nf.2**.
- **y = x**: This is determined by atoms at x = the atom part of nf_x. **Check that nf_x.1 is compatible with the y = x ssn.**
- **y = t**: This is determined by atoms at t = parent_atoms. **Check that parent_atoms is compatible with the y = t ssn.**
- **y < t**: This condition is `exists y < t with given 3-var NF`. By the same decomposition, this becomes a condition on the depth-(k+1) 1-var NF of t. Since t's NF is fixed (determined by parent_atoms and the structure), this is a condition on parent_atoms. **Check by examining whether the NF of t (at depth k+1) has the required quantifier entries.**

**The non-interval conditions become FILTERING CONDITIONS on which nf_x are compatible with sub_nf.2.** They do NOT appear as temporal sub-formulas in the output -- they determine which nf_x's appear in the disjunction.

For each ssn with sub_nf.2(ssn) = false (negative conditions):
- Same decomposition, but now the condition is "no y exists with this 3-var NF." The check is that nf_x is compatible with the ABSENCE of such y. For y > x, this means nf_x.2(proj_yx(ssn)) = false. And so on.

**The interval conditions** (y between t and x) are the ones that need temporal encoding via nested Until/Since, using char_k to characterize the interval witnesses.

But even for interval ssn's, the 3-var NF includes interactions between y, x, AND t. The current formula uses only char_k(nf_y), which captures the 1-var NF of y. We need the **2-var NF of (y, t)** as well (since the (y, x) part is captured by the interval structure).

**On Prior structures with t < y < x**: the 2-var NF of (y, t) at depth k is characterizable by a temporal formula at y (by P2(k) with t as the parent). Specifically, for each depth-k 2-var NF `nf_yt`, P2(k) gives a formula `exist_formula_yt(nf_yt)` such that `exist_formula_yt(nf_yt)` holds at y iff `exists z, nf_eval_nf M k 3 (z, y, t) nf_yt` (or rather, the relevant quantifier condition). But we already HAVE P2(k) at the start of the k+1 step.

**So the interval witness formula for each positive interval ssn should be:**
```
Since(
  disjunction over compatible (nf_y, nf_yt) pairs of:
    char_k(nf_y) AND P2(k)-formula-for-(y,t)-projection(nf_yt),
  top
)
```

This replaces the current `Since(char_k(nf_y), top)` and captures the full 3-var NF by including the (y, t) 2-var NF condition.

### 6. The Backward Direction Proof Skeleton

Assume the formula holds at t. For concreteness, assume sub_nf says t < x.

**Step 1**: From the Until, extract witness x > t where the event formula holds. This gives us x with:
- char_{k+1}(nf_x) holds at x, so by P1(k+1) correctness, nf_eval_nf M (k+1) 1 (fun _ => x) nf_x holds
- All non-interval filtering conditions hold (by construction of the disjunction)
- All interval Since-conditions hold at x

**Step 2**: From char_{k+1}(nf_x) = nf_x, extract the 1-var NF of x at depth k+1. This gives atoms at x matching sub_nf.1 (by the atom_compat filtering), and for each non-interval ssn, nf_x.2 encodes the required quantifier conditions (by the filtering).

**Step 3**: For non-interval ssn's:
- y > x: nf_x.2(proj_yx(ssn)) is encoded in nf_x by the filtering. The 1-var NF of x at depth k+1 includes quantifier conditions `exists y > x with given depth-k 2-var NF`. By composition on Prior structures, the depth-k 2-var NF of (y, x) and the depth-k 2-var NF of (y, t) together determine the depth-k 3-var NF of (y, x, t). Since y > x > t and the structure is a Prior structure (Dedekind complete linear order), the composition holds: the 3-var NF is determined by the 2-var projections.
- y = x, y = t, y < t: Similar, using the filtering conditions and the atom compatibility.

**Step 4**: For interval ssn's (t < y < x): From `Since(char_k(nf_y) AND P2(k)-formula(nf_yt), top)` at x, by Prior-SZ (first occurrence is attained), extract actual y with t < y < x where char_k(nf_y) AND the P2(k) formula hold. This gives:
- 1-var NF of y = nf_y (by P1(k))
- The (y, t) projection condition holds (by P2(k))
- The (y, x) projection is determined by the interval structure
- By composition: the full 3-var NF ssn is recovered

**Step 5**: Assemble. We now have x with:
- Atoms matching sub_nf.1
- For each ssn: if sub_nf.2(ssn) = true, a witness y exists; if sub_nf.2(ssn) = false, no witness exists
- Therefore: nf_eval_nf M (k+1) 2 (x, t) sub_nf holds

### 7. The Forward Direction

The forward direction is easier: given actual x with nf_eval_nf, show the formula holds.

For non-interval ssn's: the filtering conditions are satisfied because the actual nf_x (determined by x) is compatible with sub_nf.2 at non-interval positions. So nf_x appears in the disjunction.

For interval ssn's: given y with the 3-var NF ssn, decompose into (y, x) and (y, t) projections. char_k(nf_y) holds at y (by P1(k)). The P2(k) formula for the (y, t) projection holds at y (by P2(k) forward direction). So the Since formula holds at x (since y is between t and x on a Prior structure, hence within the interval for Since).

### 8. Depth/Rank Bookkeeping

| Level | Depth | Arity | Note |
|-------|-------|-------|------|
| sub_nf | k+1 | 2 | The target existential |
| sub_nf.2 entries (ssn) | k | 3 | Quantifier conditions on y |
| ssn 2-var projections | k | 2 | P2(k) handles these |
| ssn 1-var projections | k | 1 | P1(k) handles these |
| char_{k+1}(nf_x) | k+1 | 1 | Built from P1(k) + P2(k) |
| char_k(nf_y) | k | 1 | Built from P1(k-1) + P2(k-1) |
| P2(k) formulas for (y,t) | k | 2 | Used in interval encoding |

**No depth increase occurs.** The P2(k+1) construction uses:
- P1(k+1) for char_{k+1}(nf_x) -- already available from the master_induction
- P1(k) for char_k(nf_y) -- available from previous step
- P2(k) for 2-var projection formulas -- available from previous step

The temporal formula's rank (nesting depth of Until/Since) does increase: it is approximately f(k+1) = some function of f(k), but this does not affect the logical depth of the NF, only the syntactic complexity of the formula.

## Differences from the Failed Attempts

### Failed Attempt 1 (nf_exist_formula -- simple char_k(nf_y))
**Dropped**: All non-interval ssn conditions. The 1-var NF of x does NOT determine the 3-var NF conditions for y > x, y = x, y < t, y = t. Also, interval ssn's used only 1-var NF of y, missing the (y, t) 2-var projection.

**Fix**: Non-interval conditions become filtering on nf_x (checking nf_x.2 compatibility with the 2-var projections of non-interval ssn's). Interval conditions add P2(k) formula for (y, t) projection alongside char_k(nf_y).

### Failed Attempt 2 (P2_gen arity generalization)
**Problem**: Temporal formulas are 1-variable objects. P2 for arity n > 2 parent variables cannot produce a temporal formula (it would need to be evaluated at multiple points). The attempt confused the FOMLO level (where arity is meaningful) with the temporal formula level (always arity 1).

**Fix**: The correct approach keeps P2 at arity 2 but uses **composition** to reduce 3-var conditions to 2-var conditions, and uses **filtering** (not encoding) for non-interval conditions.

### Failed Attempt 3 (doets depth trick)
**Problem**: Tried to show the depth-(k+1) existential is equivalent to a formula of depth k+1 (not k+2) on Prior structures. This was intended to make doets_lemma_1_1 sufficient at depth k+1. But the depth is already k+1 -- the problem was never about depth, but about **arity** (3-var vs 2-var conditions).

**Fix**: N/A (wrong diagnosis of the problem).

## Recommendations

### Primary Recommendation: Revised nf_exist_formula_nested

Modify `nf_exist_formula_nested` to:

1. **Add non-interval ssn filtering to nf_x compatibility**: Currently, atom_compat_x checks only predicate atoms. Extend to check that nf_x.2 is compatible with all non-interval ssn conditions in sub_nf.2. This requires computing the 2-var projections of each non-interval ssn and checking them against nf_x.2.

2. **Add P2(k) formulas for (y, t) projections in interval conditions**: For each positive interval ssn, the witness formula should be `char_k(nf_y) AND P2(k)-formula(proj_yt(ssn))`, not just `char_k(nf_y)`.

3. **Add negative interval conditions to the guard or event**: For each negative interval ssn (sub_nf.2(ssn) = false), the formula should encode that no y exists in the interval with the corresponding 3-var NF. On Prior structures, this is `H(neg(char_k(nf_y) AND P2(k)-formula(proj_yt(ssn))))` within the interval.

### Implementation Estimate

- **Projection functions** (ssn -> 2-var NF projection): ~50 lines
- **Extended compatibility check**: ~30 lines (extend atom_compat_x to check nf_x.2 against non-interval ssn projections)
- **Revised interval formulas**: ~40 lines (add P2(k) conjuncts)
- **Revised backward proof**: ~200 lines (the main effort; composition lemma + Prior-structure decomposition)
- **Revised forward proof**: ~100 lines (needs update for new formula)
- **Composition lemma for Prior structures**: ~100 lines (3-var NF determined by 2-var projections on Prior structures)

Total: ~520 lines of changes/additions.

### Prerequisite: Composition Lemma

The following lemma is needed and does not currently exist:

```
theorem nf_3var_composition_prior
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (k : Nat) (y x t : M.carrier) (h_order : t < y) (h_order2 : y < x)
    (ssn : NormalForm sig k 3) :
    nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn <->
    (nf_eval_nf M k 2 (Fin.cons y (fun _ => x)) (proj_yx ssn) AND
     nf_eval_nf M k 2 (Fin.cons y (fun _ => t)) (proj_yt ssn))
```

This is the Feferman-Vaught composition specialized to linear orders at a point y between t and x. The proof is by induction on k:
- Base (k=0): The 3-var atoms decompose cleanly into 2-var atoms (each atom involves at most 2 variables)
- Step (k+1): The quantifier part ssn.2 involves 4-var NFs. Each 4-var NF at (z, y, x, t) decomposes by the position of z. By the IH applied at depth k, the 4-var NF is determined by its 3-var projections, which are in turn determined by 2-var projections. On Prior structures, the Dedekind completeness ensures that the decomposition is exhaustive.

**Note**: This composition lemma requires that y is between t and x. For y outside the interval, different projections are needed, but those cases are handled by the filtering conditions (non-interval ssn's).

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Composition lemma is FALSE at depth k >= 1 | CRITICAL | The claim that the 3-var NF is determined by 2-var projections must be verified carefully. At depth 0, it is true (atoms decompose). At depth k+1, the quantifier part involves 4-var NFs, and the composition may require additional conditions. If it fails, fall back to the GHR93 game-based approach (Option A). |
| P2(k) formula for (y, t) projection requires parent_atoms for t, but we are evaluating at y | HIGH | P2(k) is parameterized by parent_atoms (the atom assignment at the "parent" point). When encoding the (y, t) condition at point y, the parent point is t, whose atoms are fixed (= parent_atoms). So P2(k) is applicable with parent_atoms unchanged. |
| nf_x compatibility check becomes computationally complex | LOW | All types are Fintype, so enumeration over NormalForm sig k 3 is finite. Lean handles this via Fintype.elems. |

## Appendix

### Search Queries Used

- Rabinovich 2014: Read full PDF pages 5-14, full markdown extract
- GHR93: Read full markdown extract (1672 lines), focusing on Proposition 7 and Theorem 6
- GHR94 Ch9: Read pages 1-11 (Theorem 9.3.1 proof structure)
- GHR94 Ch10: Read pages 1-20 (separation for S, U over integer time)
- GHR94 Ch12: Read pages 1-8 (gaps and expressive power)
- Doets 1989: Read full markdown extract (condensation arguments, composition lemma 1.4/1.5)
- Doets 1987: Read pages 1-25 (n-characteristics, Z-time completeness)
- Libkin 2004 Ch3: Read pages 1-20 (Lemma 3.7 composition for linear orders)
- Thomas 1997: Read full markdown extract (composition method survey)

### Key Literature References

1. **Rabinovich 2014**, Proposition 3.5: Exists-forall formulas with one free variable translate to nested Until/Since chains
2. **Rabinovich 2014**, Proposition 4.2 + Section 5: Negation closure for 2-free-variable exists-forall formulas over Dedekind-complete chains
3. **GHR93**, Proposition 7: Arity-general EF game composition -- the "depth x arity" induction
4. **Libkin 2004**, Lemma 3.7: Composition lemma for linear orders (splitting at a point)
5. **Doets 1989**, Lemma 1.4/1.5: Ordered sum composition preserves n-equivalence
6. **Doets 1987**, Definition 1.6.1: n-characteristics (= our NormalForm type)

### Lean Goal at the Sorry (NegationClosure.lean:828)

```
h_formula : temporal_truth M atomMap t (nf_exist_formula_nested k char_kp1 char_k parent_atoms sub_nf)
|- exists x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x fun x => t) sub_nf
```

Available hypotheses include P1(k), P2(k), char_k_correct, char_kp1_correct (_char_kp1_correct), Prior axioms h_UZ and h_SZ, and h_atoms (parent atom compatibility).
