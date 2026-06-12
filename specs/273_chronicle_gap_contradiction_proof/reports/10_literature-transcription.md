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

## Adversarial Verification (second reader)

**Reviewer**: logic-research-agent (adversarial pass)
**Date**: 2026-06-11

This section checks each load-bearing claim in the report against the primary literature, with special attention to rank/depth bookkeeping -- the exact failure mode of the three prior implementation attempts.

### Verdict: SOUND with two corrections needed

The overall approach (composition-based reduction of 3-var NFs to 2-var projections, with non-interval ssn conditions encoded as filtering) is mathematically correct and does correspond to what the published proofs support. However, two specific claims in the report are erroneous or misleading and must be corrected before implementation proceeds.

---

### Claim 1: "Equality of rank, not a rank increase" (line 216) -- citing Libkin Lemma 3.7

**Verdict: MISLEADING attribution, CORRECT conclusion for the NormalForm setting.**

The report cites Libkin Lemma 3.7 as support for the composition having no rank drop. But Libkin Lemma 3.7 actually states (ch3, p.62-66 of the extract):

> If L_1^{<=a} equiv_k L_2^{<=b} and L_1^{>=a} equiv_k L_2^{>=b}, then (L_1, a) equiv_{k-1} (L_2, b).

This is a rank **DROP** from k to k-1. The report's claim of "equality of rank" directly contradicts Libkin's statement.

**However**, the report's conclusion is correct for the NormalForm setting, for a subtle reason the report fails to articulate: The Libkin rank drop occurs because *naming a point* in an EF game costs one round (the spoiler can challenge whether two points "correspond"). In the NormalForm framework, all variables are already named -- they are part of the environment `env : Fin n -> M.carrier`. Splitting at an already-named variable y does not cost a quantifier depth: the depth-k 3-var NF at named points (y, x, t) decomposes into depth-k 2-var NFs at named points (y, x) and (y, t) because:

- At depth 0: atoms involve at most 2 variables, so they split cleanly. The (x, t) order relation is implied by transitivity when y is between t and x.
- At depth k+1: the quantifier part introduces a NEW variable z. The depth-k NF of (z, y, x, t) decomposes (by the induction hypothesis at depth k, for all arities) into depth-k NFs of the projections.

The correct citation for this no-rank-drop composition is **Doets 1989, Lemma 1.4**: ordered sum composition preserves n-equivalence without rank loss. Alternatively, the argument follows directly from the recursive structure of `NormalForm sig k n` in the Lean codebase: at each depth level, quantifier conditions reference depth-(k-1) NFs at arity n+1, and the induction on k handles increasing arity at each step.

**Correction needed**: Replace the Libkin 3.7 attribution with the Doets 1.4/1.5 attribution and add an explicit explanation of why the Libkin rank-drop does not apply in the NormalForm setting (variables are already named, not being added as new constants).

---

### Claim 2: Composition lemma nf_3var_composition_prior (lines 359-369) -- same depth k

**Verdict: CORRECT in principle, but the stated signature is INCOMPLETE.**

The report states the composition as:
```
nf_eval_nf M k 3 (y, x, t) ssn <->
  nf_eval_nf M k 2 (y, x) (proj_yx ssn) AND
  nf_eval_nf M k 2 (y, t) (proj_yt ssn)
```

The depth-0 case works: 3-var atoms split into the (y,x) and (y,t) pairs, with the (x,t) atoms determined by transitivity (since t < y < x implies t < x).

At depth k+1, the quantifier part of ssn involves `NormalForm sig k 4 -> Bool` (4-var NFs at (z, y, x, t)). The induction hypothesis would need composition at depth k for 4-var -> 3-var (splitting (z, y, x, t) at z's position). This works if the IH is stated for ALL arities at depth k.

**The gap**: The report's lemma signature is stated only for arity 3 -> 2. The actual induction requires a FAMILY of composition lemmas for all arities n >= 3, proved simultaneously by induction on k. The correct statement would be:

```
theorem nf_composition_prior (k : Nat) :
  forall (n : Nat) (h_n : n >= 3) (env : Fin n -> M.carrier)
    (i j : Fin n) (h_between : env j < env i.split_point < env ...)
    (ssn : NormalForm sig k n),
    nf_eval_nf M k n env ssn <->
    nf_eval_nf M k (n-1) (proj_left env ssn) AND
    nf_eval_nf M k (n-1) (proj_right env ssn)
```

This is a universally-quantified-over-arity lemma proved by induction on k. The report should state this explicitly rather than giving only the arity-3 instance.

**Practical impact**: For the implementation, only the arity-3 instance is directly needed (since sub_nf.2 references NormalForm sig k 3). But the proof of the arity-3 instance at depth k+1 requires the arity-4 instance at depth k, which requires arity-5 at depth k-1, etc. After k steps the recursion bottoms out at depth 0 where the composition is trivial for all arities. So the implementation needs either:
(a) A single lemma quantified over both k and n, proved by strong induction on k, or
(b) The arity-3 instance with an auxiliary lemma at all arities for the inductive step.

**Correction needed**: Expand the composition lemma statement to be quantified over arity n, and note that the induction on k requires all arities simultaneously.

---

### Claim 3: P2(k) formulas for (y,t) projections in interval conditions (lines 249-260)

**Verdict: OVERCOMPLICATED and partially incorrect.**

The report proposes adding "P2(k)-formula-for-(y,t)-projection" as a conjunct in the interval witness formula:
```
Since(char_k(nf_y) AND P2(k)-formula-for-(y,t)-projection(nf_yt), top)
```

This is **not the right decomposition**. P2(k) gives formulas for EXISTENTIALS: "exists z with given 2-var NF at (z, t)." But what we need for the interval condition is the FULL depth-k 2-var NF of (y, t), not just a single existential.

The depth-k 2-var NF of (y, t) at depth k+1 involves the quantifier assignment: for EACH depth-(k-1) 3-var NF tau, whether exists z with that 3-var NF at (z, y, t). Using P2(k) would require a separate formula for each tau, conjoined/negated according to the 2-var NF's quantifier assignment. This is feasible but verbose.

**The simpler and correct approach** (implied by the composition lemma but not articulated in the report): Given the composition lemma, the depth-k 3-var NF of (y, x, t) is determined by the depth-k 2-var NFs of (y, x) and (y, t). On Prior structures, the depth-k 2-var NF of (y, t) is itself determined by:
- The depth-k 1-var NF of y (= char_k(nf_y))
- The depth-k 1-var NF of t (= fixed, determined by parent_atoms via P1)
- The order relation between y and t
- **Plus the joint quantifier conditions** from the 2-var NF of (y, t)

The joint quantifier conditions are where the difficulty lies. Simply using char_k(nf_y) plus parent_atoms does NOT determine the 2-var NF of (y, t) at depth k >= 1, as the handoff document (phase-5-handoff-20260611.md, line 27) correctly observes.

**However**, the correct formula does NOT need P2(k) as a sub-formula. Instead, the interval witness formula should directly characterize the COMPATIBLE 3-var NFs:

For each positive interval ssn, the witness condition at y should be:
```
char_k(nf_y) where nf_y is the 1-var PROJECTION of ssn
AND
for each positive tau in ssn.2 with z between y and t:
  P2(k-1)-based formula for the (z, y, t) existential
AND
for each positive tau in ssn.2 with z between y and x:
  P2(k-1)-based formula for the (z, y, x) existential
AND ... (recursively)
```

This is a RECURSIVE nesting: the interval condition at depth k involves depth-(k-1) interval conditions, which involve depth-(k-2), etc. This exactly matches the nested Until/Since chain structure from Rabinovich Prop 3.5.

**In other words, the depth of temporal nesting in the formula mirrors the NF depth.** The formula for P2(k+1) has k+1 levels of Until/Since nesting, with each level encoding one depth of the NF quantifier part. This is what the existing plan v20 ("nested buildRight formula with k+1 levels") was attempting to capture, though it got the details wrong.

**Correction needed**: Replace the "P2(k)-formula-for-(y,t)-projection" claim with a description of recursive nesting: each depth level of the NF corresponds to one level of Until/Since nesting in the formula. The witness condition at depth k involves not just char_k(nf_y) but also the recursive sub-conditions for all positive ssn's in ssn.2 that have witnesses in sub-intervals.

---

### Claim 4: Non-interval ssn conditions as filtering on nf_x (lines 232-243)

**Verdict: CORRECT for the y > x case, INCOMPLETE for the y < t case.**

The report correctly identifies that for ssn's with y > x:
- The condition "exists y > x with given 3-var NF" decomposes into conditions on nf_x.2 (the quantifier part of x's depth-(k+1) 1-var NF)
- Specifically, nf_x.2 records which depth-k 2-var NFs at (y, x) are realized, so the (y, x) projection of the ssn can be checked against nf_x.2

**However**, the y > x ssn includes the (y, t) projection as well, which is NOT encoded in nf_x alone. By the composition lemma, the 3-var NF of (y, x, t) with y > x is determined by the 2-var NFs of (y, x) and (y, t). The (y, x) part is in nf_x.2. The (y, t) part involves conditions on y relative to t. Since y > x > t, the (y, t) conditions are also conditions at y relativized to the future of t. These conditions are encoded in the depth-(k+1) 1-var NF of y, which is itself constrained by being compatible with the (y, x) 2-var NF.

On Prior structures, this joint compatibility IS decidable at the filtering stage (it's a finite check over finitely many NF values), so the filtering approach is correct in principle. But the filter must check BOTH the (y, x) projection against nf_x.2 AND the consistency of the (y, t) projection with the available depth-(k+1) 1-var NFs of t.

For y < t: the dual argument applies, but now the condition involves the depth-(k+1) 1-var NF of t, which is NOT directly available as a hypothesis. The report claims (line 238) this is "a condition on parent_atoms," but parent_atoms is the depth-0 (atom-level) assignment at t, not the full depth-(k+1) 1-var NF of t. **The depth-(k+1) 1-var NF of t IS determined by the structure and the Prior axioms, but it is not a parameter of P2(k+1).** The formula cannot reference it as a filtering condition unless it is computed from parent_atoms and the structure.

**This gap may be resolvable**: since nf_eval_nf M (k+1) 2 (x, t) sub_nf includes the full atom assignment at t (= parent_atoms at depth 0) AND the quantifier conditions at t (via sub_nf.2 entries with y = t or y < t), the filtering can check consistency of y < t ssn conditions against the sub_nf.2 entries that describe t's quantifier behavior. This is a finite check on the sub_nf object itself, not on the structure.

**Correction needed**: Clarify that the y < t filtering condition checks against sub_nf.2 (which encodes t's quantifier behavior relative to x), not against "the depth-(k+1) 1-var NF of t" which is not directly available. The check is internal to the sub_nf structure.

---

### Claim 5: Rabinovich's construction is "not a 1-step operation" (lines 11-13, 87-91)

**Verdict: CORRECT and important.**

The report correctly identifies that Rabinovich's proof of Theorem 4.4 goes through Proposition 4.3 (structural induction reducing FOMLO to exists-forall formulas), which uses negation closure (Prop 4.2) at each step. The Lean P2(k+1) statement asks for a direct formula, not a multi-step reduction.

However, the report then proposes a direct formula construction (Section 5) that bypasses the full Rabinovich machinery. This is legitimate: the Lean induction structure (P1(k) + P2(k) simultaneously) is a DIFFERENT induction from Rabinovich's structural induction on FOMLO formulas. The Lean induction directly constructs the formula for each (parent_atoms, sub_nf) pair, using the IH at depth k. This is closer to the GHR93 game-based approach (which also works by induction on game length/quantifier depth) than to Rabinovich's exists-forall approach.

**No correction needed.**

---

### Summary of Required Corrections

1. **Line 216**: Replace "Libkin Lemma 3.7" attribution with "Doets 1989 Lemma 1.4/1.5" and explain why the Libkin rank-drop does not apply (variables already named in NormalForm setting).

2. **Lines 359-369**: Expand the composition lemma to be universally quantified over arity n, noting that the induction on k requires all arities simultaneously.

3. **Lines 249-260**: Replace "P2(k)-formula-for-(y,t)-projection" with a description of RECURSIVE nesting: each depth level of the NF corresponds to one level of Until/Since nesting. The formula has k+1 nesting levels, not a single P2(k) call.

4. **Line 238**: Clarify that y < t filtering checks against sub_nf.2 entries (which encode t's quantifier behavior), not against "the depth-(k+1) 1-var NF of t."

### Assessment of Overall Viability

The proposed approach IS mathematically viable. The composition lemma (depth-k n-var NF splits into depth-k (n-1)-var projections at a named interior point) is correct and follows from the recursive structure of NormalForm by induction on k for all arities. This gives a formula that encodes ALL of sub_nf.2:

- Non-interval ssn conditions become filtering conditions on nf_x compatibility (checking projections against nf_x.2 and sub_nf.2)
- Interval ssn conditions become recursively nested Until/Since chains, with each nesting level encoding one depth of the NF

The depth bookkeeping is sound: P2(k+1) uses P1(k+1), P1(k), and P2(k), all available from the master_induction. No depth increase occurs in the NormalForm sense (the formula is at NF depth k+1, using IH at depth k). The temporal rank of the formula does increase (approximately exponentially in k), but this does not affect the NF depth induction.

**The critical implementation risk** is the composition lemma, which must be proved for all arities simultaneously by induction on k. If the Lean proof of this lemma encounters difficulties (e.g., from the arity-increasing recursion at each depth level), the approach may require significant additional infrastructure. The report's estimate of ~100 lines for the composition lemma is likely too low given the all-arities requirement; ~200-300 lines is more realistic.
