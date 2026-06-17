# Rabinovich Formula Analysis for existPart_succ_n1_bypass k>0

**Task**: 303 (k_gt_0_depth_induction)
**Agent**: lean-research-hard-agent
**Session**: sess_1781684058_bab646
**Reference Grounding Tier**: Tier 1 (literature-backed: Rabinovich 2014)
**Date**: 2026-06-17

---

## Focus Question 1: What formula does Rabinovich's proof construct?

### Rabinovich's Exists-Forall Decomposition (Proposition 3.5)

Rabinovich's Proposition 3.5 translates a V-exists-forall formula with one free variable at
position z_k in a sequence x_0 < ... < x_n into the conjunction of:

```
A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))
AND
A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... (A_0 AND Hitherto-Box B_0)...)))
```

where A_i are types at the witness points x_i and B_j are the interval types (beta_j) between
consecutive witnesses.

**The key insight**: The B_j (between-zone content) is encoded as the guard of the nested
Until/Since. This means the temporal formula **directly encodes** which NF types hold everywhere
in each interval between witnesses.

### Mapping to the Lean Code

The current code's formula for the Until zone (KampBypass.lean line 504):
```lean
let until_formula := Formula.and (char_kp1 nf_t0) (Formula.untl (char_kp1 nf_x0) Formula.top)
```

This corresponds to Rabinovich's pattern with:
- A_k = char_kp1(nf_t0) -- the type at the evaluation point t
- A_{k+1} = char_kp1(nf_x0) -- the type at the witness x
- B_{k+1} = Formula.top -- the between-zone content is **trivially true**

**The between-zone content B_{k+1} is set to Top.** This means the formula does NOT encode
what NF types are realized in the interval (t, x). This is exactly where the proof breaks
down: the backward direction finds x with the correct 1-var NF, but cannot reconstruct the
full 2-var NF at [x, t] because it has no information about the interval content.

### Rabinovich's Formula Would Use Non-Trivial B_{k+1}

In Rabinovich's framework, B_{k+1} would encode the interval type beta_{k+1} from the
exists-forall normal form. Translated to our NF framework, beta_{k+1} would specify:
- For each depth-k 1-var NF type tau, whether tau is realized in the interval (t, x)
- This is precisely the information needed for the 3-var quantifier conditions

However, encoding beta_{k+1} non-trivially requires exactly the same depth-k information that
the current approach cannot reconstruct -- it would need `char_k` formulas for every NF type
that might appear in the interval, plus a way to assert their absence/presence. This is what
the exists-forall normal form provides.

### The Disconnect

The current code operates at the NF (normal form) level rather than the exists-forall formula
level. Rabinovich's proof works because:

1. He starts with an FOMLO formula and converts it to exists-forall normal form
2. The exists-forall formula already encodes all interval types
3. Proposition 3.5 translates this to TL, preserving interval information
4. Proposition 4.2 (negation closure) works at the exists-forall level

The Lean code instead works with quantifier-depth NFs (Doets-style) and tries to construct a
TL formula for each NF. The NF framework does not natively provide exists-forall decomposition.

---

## Focus Question 2: How does Rabinovich encode between-zone content?

### Rabinovich's Interval Type Decomposition

In Section 5, when handling the negation of an interval-typed formula:
```
not [alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)
```

Rabinovich decomposes the interval at a new point z into:
- A_i^-(z_0, z) = [alpha_0, beta_1, ..., beta_i, alpha_i](z_0, z)  -- left sub-interval
- A_i^+(z, z_1) = [alpha_i, beta_{i+1}, ..., beta_{n+1}, alpha_{n+1}](z, z_1)  -- right sub-interval

The beta_j are quantifier-free (purely atomic) types that hold **universally** on each
sub-interval. This universality is critical: beta_j is not an existential condition but a
forall condition.

### The Key Structural Difference from NFs

In Rabinovich's exists-forall formulas, the between-zone beta_j are **universally quantified**
conditions (forall y in interval: beta_j(y)). In the NF framework, the quantifier conditions
are **existential** (exists y with depth-k NF type ssn).

This means:
- Rabinovich: "between every pair of consecutive witnesses, every point has type beta_j"
- NF framework: "for each sub-NF ssn, is there a witness y with that type?"

The NF existential conditions at [y, x, t] involve y in three possible zones:
1. y < t (below both): constant-env composition handles this
2. t < y < x (between): THIS is the problematic zone -- y's relationship to both x and t matters
3. x < y (above both): constant-env composition handles this

For zones 1 and 3, the environment looks like [y, x, t] where y is outside the
interval [t, x], so the [y, _] projection lands on a constant env relative to t or x
respectively. `cross_extend_bwd_1var` from h_t or h_x provides the witness.

For zone 2 (between), the witness y is BETWEEN t and x. Its 3-var NF type at [y, x, t]
depends on the content of the intervals (t, y) and (y, x). This is the non-constant-env
problem: the projection to [y, x] and [y, t] are both non-constant, and neither h_x nor
h_t alone gives us a witness with the right 3-var type.

### How Rabinovich Handles This

Rabinovich does NOT face this problem because:
1. His between-zone beta_j is a **universal** condition, not an existential one
2. The translation to TL via Proposition 3.5 uses beta_j as the **guard** of Until/Since,
   which naturally expresses "beta holds everywhere in the interval"
3. The negation closure (Proposition 4.2) is proved by case-splitting on what goes wrong
   at the first failure point, using Dedekind completeness to find infimum/supremum

In our NF framework, the analogous statement would be: the depth-(K+1) 3-var existential
transfer on [y, x, t]/[y', x', t'] where t < y < x follows from Prior-UZ/SZ because
Prior structures have discrete order (equivalent to Dedekind completeness for countable
chains), and on discrete orders the between-zone has finitely many points, each of which
can be matched by the opponent using UZ/SZ to find first/last occurrences.

---

## Focus Question 3: The mutual induction structure

### The Induction in KampMutualInduction.lean

The mutual induction is on depth k alone:
- CharPart(k): every 1-var depth-k NF has a TL characteristic formula
- ExistPart(k): for all n >= 1, every (n+1)-var depth-k existential is TL-characterizable

The dependency:
```
CharPart(0)    <- sorry-free
ExistPart(0)   <- sorry-free
CharPart(k+1)  <- CharPart(k) + ExistPart(k)  -- sorry-free
ExistPart(k+1) <- CharPart(k+1) + ExistPart(k) -- SORRY at k>0
```

ExistPart(k+1) at n=1 dispatches to `existPart_succ_n1_bypass`, which:
- At k=0: is sorry-free (979 lines in KampBypassUntil.lean)
- At k>0: constructs the enriched Until/Since formula, proves forward, delegates backward
  to `prior_2var_transfer_until/since` from PriorComposition.lean

### The Depth Reduction

The backward direction at depth k+1 STAYS at depth k+1 (not reducing to k). Specifically:
- `prior_nonconstenv_2var_agree_until` proves depth-(K+2) 2-var agreement at [x,t]/[x',t']
  from depth-(K+2) 1-var agreement at x/x' and t/t'
- Its proof uses strong induction on K: the IH gives depth-(K+1) 2-var agreement,
  and then delegates to `exist_transfer_3var_nonconstenv` for the quantifier lift

The depth does reduce by 1 through `nf_extend_fwd`/`nf_extend_bwd` (depth-(K+1) r-var
agreement gives depth-K (r+1)-var witnesses), but this is NOT enough to close the gap.
`nf_extend_fwd` gives c_K with depth-K 3-var agreement and c with depth-(K+1) 2-var
agreement, but cannot merge these into depth-(K+1) 3-var agreement.

### The Exact Depth Mismatch

At the sorry site (line 231), the goal is:
```
exists y', nf_eval_nf N (K + 1) 3 (Fin.cons y' (Fin.cons x' (fun _ => t'))) sub_nf
```

Available:
- h_3var_K: depth-K 3-var agreement at [y,x,t]/[c_K,x',t'] (from hex_K)
- h_2var_Kp1: depth-(K+1) 2-var agreement at [y,x]/[c,x'] (from hex_x)
- h_c_1var: depth-(K+1) 1-var agreement at y/c (from h_2var_Kp1 projection)

The witness should be c (not c_K), since c has the right depth-(K+1) 2-var agreement
with y at [y,x]/[c,x']. But to prove c satisfies sub_nf at [c, x', t'], we need:

(a) **Atoms at [c, x', t']**: predicates at c match y (from h_c_1var), predicates at
    x'/t' match x/t (from h_x/h_t). Order c < x' iff y < x (from h_2var_Kp1 atom part).
    Order c vs t': requires knowing y < t iff c < t' or y > t iff c > t'.
    **This is the gap**: c comes from hex_x which only knows about [y,x]/[c,x'].
    The c-t' order is not determined by the available hypotheses unless c_K and c
    are in the same zone relative to t' (which would follow if they have the same
    depth-K 1-var type in the correct zone).

(b) **Quantifiers**: depth-K 4-var existential transfer at [w,y,x,t]/[w',c,x',t'].
    This is even harder -- it requires the EF game argument or a recursive
    application of the composition theorem at arity 4.

---

## H3 Reference Grounding Table (Tier 1: Rabinovich 2014)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|--------------|-----------------|---------------|--------|
| Rabinovich 2014, Def 3.1 | Exists-forall formula | `NormalForm sig k n` | `NormalForm : MonadicSignature -> Nat -> Nat -> Type` | Partial analogue (depth-based NF vs interval-based EA) |
| Rabinovich 2014, Prop 3.5 | V-EA -> TL translation | `existPart_succ_n1_bypass` | `... -> exists A : Formula, ...` | Proved for k=0, sorry at k>0 |
| Rabinovich 2014, Prop 4.2 | Negation closure for 2-var EA | `prior_nonconstenv_2var_agree_{until,since}` | `... -> forall nf : NormalForm sig (K+2) 2, nf_eval_nf M ... nf <-> nf_eval_nf N ... nf` | 4 sorries in PriorComposition.lean |
| Rabinovich 2014, Lemma 5.1 | Interval splitting core | `exist_transfer_3var_nonconstenv` | `... -> (exists y, nf_eval_nf M (K+1) 3 ...) <-> (exists y', nf_eval_nf N (K+1) 3 ...)` | 2 sorries (fwd/bwd), THE blocking lemma |
| Rabinovich 2014, Lemma 5.3 | Base case (all beta = True) | K=0 cases in `prior_nonconstenv_2var_agree_{until,since}` | `... -> (exists x, nf_eval_nf M 0 3 ...) <-> (exists x, nf_eval_nf N 0 3 ...)` | 2 sorries (purely atomic transfer) |
| Rabinovich 2014, Cor 5.4 | Negation of bounded-exists | (implicit in `kamp_mutual_induction`) | -- | Structure present in mutual induction |
| Rabinovich 2014, Thm 2.1 | Kamp's theorem | `completeness_discrete` (downstream) | -- | Blocked by the above |
| Prior axioms | UZ/SZ (discreteness) | `semantic_prior_UZ`, `semantic_prior_SZ` | `... -> exists s, t < s /\ ... /\ forall r, ... -> ... -> ...` | Defined, used in hypotheses |
| Doets 1989, Def 1.6.1 | Quantifier-depth NF | `NormalForm` | (recursive: atom assignment + quantifier assignment) | Sorry-free |
| NfComposition.lean | ExistPart_r is FALSE | counterexample on (Z, <) | -- | Confirmed: general composition fails for n >= 2 |

---

## Analysis of Approaches

### Approach (a): Keep enriched formula + prove Prior composition (current path)

**Status**: 4 sorries in PriorComposition.lean, all flowing into `exist_transfer_3var_nonconstenv`.

**The core difficulty at the inductive case (lines 231, 239)**: To prove
`exists y', nf_eval_nf N (K+1) 3 [y', x', t'] sub_nf`, we use witness c from hex_x.
We need depth-(K+1) 3-var eval at [c, x', t']. We have:
- depth-(K+1) 2-var at [c, x'] (from hex_x)
- depth-(K+1) 1-var at c (from projection of 2-var)
- depth-K 3-var at [c_K, x', t'] (from hex_K, different witness)

The missing piece: merge these into depth-(K+1) 3-var at [c, x', t']. This requires
knowing the c-t' relationship AND all depth-K 4-var quantifier conditions.

**Feasibility assessment**: This is essentially the EF game composition theorem for
non-constant environments on Prior structures. The standard proof uses back-and-forth
(Fraisse's method) or the Feferman-Vaught composition theorem. On Prior structures,
the UZ/SZ axioms provide the missing zone-matching: if c and c_K are in the same zone
relative to t', then they can be unified (pick one that satisfies both the 2-var and
3-var constraints). UZ/SZ guarantee first/last occurrences, enabling zone refinement.

**However**, the formalization of this argument is non-trivial. It requires:
1. Zone classification of c, c_K relative to t' (or x')
2. Zone-matching argument using UZ/SZ to find a SINGLE witness satisfying both constraints
3. Possibly a recursive argument on zone depth (# of distinct NF types in the interval)

**The K=0 base case (lines 322, 399)** is significantly simpler:

At depth 0, `nf_eval_nf M 0 3 env ssn3` is purely atomic:
```
forall (a : AtomKind sig 3), atom_eval M env a <-> (ssn3 a = true)
```

The transfer `(exists w, nf_eval_nf M 0 3 [w, x, t] ssn3) <-> (exists w', nf_eval_nf N 0 3 [w', x', t'] ssn3)` requires finding w' with:
- Matching predicates at w' (same as w)
- Correct w'-x' order (same as w-x)
- Correct w'-t' order (same as w-t)

Zone analysis for w relative to x and t:
- **w < t < x**: w is below both. Need w' < t' < x'. Use `cross_extend_bwd_1var` from
  h_t to find w' with depth-1 2-var at [w,t]/[w',t']. This gives matching predicates
  and w' < t' (from order part). Then w' < x' follows from w' < t' < x'.
- **t < w < x**: w is in the between zone. Need t' < w' < x'. Use Prior-UZ: since
  w has predicates matching some NF type tau, and t' < x', Prior-UZ/SZ provides a
  point in (t', x') with the same predicate assignment (at depth 0, this is just
  unary predicates). **But**: at depth 0, we do NOT have UZ/SZ available for NF
  types, only for temporal formulas. We need a bridge lemma that converts depth-0
  1-var NF types to temporal formulas (which is `char_0` from CharPart(0), the
  atom literal conjunction). This is available.
- **t < x < w**: w is above both. Use `cross_extend_bwd_1var` from h_x to find w'
  with depth-1 2-var at [w,x]/[w',x']. Matching predicates and w > x gives w' > x'.
  Then w' > t' follows from x' > t'.
- **w = t or w = x**: Special cases, handled by the constant-env or equality cases.

**This analysis shows the K=0 base case IS closable** using existing infrastructure
plus CharPart(0) to convert NF types to temporal formulas for UZ/SZ application.

### Approach (b): Change the formula to encode more information

This would mean replacing `Formula.top` in the Until guard with a formula encoding
the between-zone content. Specifically:
```lean
let beta := [conjunction encoding which depth-k 1-var NFs are realized in (t, x)]
let until_formula := Formula.and (char_kp1 nf_t0) (Formula.untl (char_kp1 nf_x0) beta)
```

where beta = conjunction over all depth-k NFs tau of:
- If tau is realized in (t0, x0) in M0: (tau Until Top) OR (tau Since Top) OR tau
- If tau is NOT realized: their negations

**Problem**: This encoding is circular. To characterize which depth-k NFs are realized
in an interval, we need the depth-(k+1) 2-var NF of the interval endpoints, which is
exactly what we are trying to establish. The formula construction uses Classical.em
over satisfiability, so the formula depends on some model M0 -- but the backward
direction needs to work for ALL models, not just M0.

Moreover, encoding interval content in the Until guard changes the semantics of the
Until: `(char_kp1 nf_x0) Until beta` now means "there exists x above t with type nf_x0
such that beta holds everywhere in (t, x)". The backward direction would then give us
beta holds in (t, x), which is the interval content we need -- but we would still need
to prove that the interval content (in terms of depth-k NF types realized) matches
M0's interval content, which is the same Prior composition problem.

**Conclusion**: Approach (b) does not avoid the non-constant-env composition problem; it
just moves it from the 3-var transfer to the Until guard verification. Not recommended.

### Approach (c): Restructure the induction

One could try to restructure the mutual induction to avoid non-constant environments
entirely, by internalizing the interval splitting in the formula. This is essentially
what Rabinovich does: his proof never needs to compare NF types across structures at
non-constant environments because the exists-forall formulas encode all information
in a flat (1-variable) temporal formula.

This would require:
1. Replacing the NF-based characterization with an exists-forall-based characterization
2. Re-proving all of CharPart and ExistPart in the new framework
3. Discarding the 4488 lines of sorry-free work in KampBypass*.lean

**Conclusion**: Approach (c) is a complete rewrite. Not recommended given the existing
sorry-free infrastructure.

---

## Recommendation: Approach (a), Prioritizing the K=0 Base Case

### Rationale

1. **The K=0 base case (lines 322, 399) is the true bottleneck.** The inductive case
   (lines 231, 239) delegates to `exist_transfer_3var_nonconstenv` with h_xt from the
   IH. But the IH itself depends on the K=0 base case. Once K=0 is closed, the
   inductive case is structurally identical but with the IH hypothesis available.

2. **The K=0 case is purely atomic and should be closable.** At depth 0, NF eval is
   just atom matching. The zone analysis above shows each zone can be handled:
   - Outside zones: `cross_extend_bwd_1var` from h_x or h_t
   - Between zone: Prior-UZ/SZ applied to `char_0(tau)` formulas
   - Equality zones: trivial

3. **The inductive case may follow the same pattern.** Once K=0 works, the inductive
   case has h_xt (depth-(K+1) 2-var agreement from IH), giving depth-K 3-var transfer.
   The depth-K 3-var transfer handles the "quantifier part" of the 3-var NF. The
   "atom part" is handled by the same zone analysis as K=0. The remaining gap
   (merging c and c_K) may be closable by showing they can be unified in the same zone
   using UZ/SZ.

### Concrete Next Steps

**Phase 1: Close K=0 base case (lines 322, 399)**

Goal: `(exists w, nf_eval_nf M 0 3 [w, x, t] ssn3) <-> (exists w', nf_eval_nf N 0 3 [w', x', t'] ssn3)`

Available context:
- h_x: depth-2 1-var agreement at x/x'
- h_t: depth-2 1-var agreement at t/t'
- h_order_M: t < x, h_order_N: t' < x'
- h_UZ_M, h_SZ_M, h_UZ_N, h_SZ_N: Prior axioms

Strategy:
1. Case-split ssn3 on the order atoms:
   - ssn3(.order(0,1)): w < x?
   - ssn3(.order(1,0)): x < w?
   - ssn3(.order(0,2)): w < t?
   - ssn3(.order(2,0)): t < w?
   These determine w's zone relative to x and t.

2. For w outside [t,x] (zones w < t or w > x):
   Use `cross_extend_bwd_1var` from h_t (for w < t) or h_x (for w > x)
   to get w' with depth-1 2-var agreement. Extract matching predicates
   and compatible orders.

3. For w in (t, x) (between zone):
   - Extract w's depth-0 1-var NF (just predicate assignment) from ssn3
   - Convert to temporal formula using `nf_depth0_char_formula` (CharPart(0))
   - Apply semantic_prior_UZ to M to get first w in (t, x) with that predicate
     type (or show w exists directly since we have it)
   - Apply semantic_prior_UZ to N with the same char_0 formula to get w' in
     (t', x') with matching predicates
   - Show w' satisfies ssn3 (predicates match, orders match by zone)

4. For w = t or w = x: use the existing point directly.

**Phase 2: Attempt inductive case (lines 231, 239)**

With K=0 closed, re-examine whether the structural argument generalizes.
The key question: can UZ/SZ provide a witness c' in N such that:
- depth-(K+1) 1-var at y/c' (from UZ/SZ applied to char_{K+1}(nf_y))
- c' is in the same zone relative to x' and t' as y is relative to x and t
- depth-K 3-var conditions follow from hex_K and zone matching

This would likely require a new lemma:
```lean
theorem prior_zone_witness (M N : OrderedMonadicStructure sig)
    (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
    (t' x' : N.carrier) (h_order : t' < x')
    (char_formula : Formula) (h_exists : exists y, t' < y /\ y < x' /\ temporal_truth N atomMap y char_formula) :
    exists y', t' < y' /\ y' < x' /\ temporal_truth N atomMap y' char_formula /\
      [optional first/last property from UZ/SZ]
```

**Phase 3: If Phase 2 fails, consider EF-game wrapper**

As a fallback, wrap the `exist_transfer_3var_nonconstenv` in a finite EF-game argument:
at depth K+1 with 3 variables, Duplicator has a winning strategy using the available
hypotheses (h_x, h_t, h_xt) plus Prior-UZ/SZ. This is the "game-theoretic argument"
referenced in the sorry comments. The game argument would be a self-contained inductive
proof on the number of rounds remaining, using the back-and-forth technique.

---

## Adversarial Self-Verification (H4)

### Challenged Claims

1. **Claim: "The K=0 base case IS closable using existing infrastructure plus CharPart(0)"**

   **Challenge**: The between-zone witness requires finding w' in (t', x') with matching
   predicates. Prior-UZ gives a FIRST occurrence of a formula, but does it guarantee the
   occurrence is in the right interval?

   **Verification**: semantic_prior_UZ says: if psi holds somewhere above t', there exists
   a first s > t' with psi, and psi.neg holds in (t', s). If we want w' in (t', x'),
   we need to know that psi (the char_0 formula) holds somewhere in (t', x') in N. We
   know it holds somewhere in (t', x') in M (that is w). We need to transfer this
   existence to N.

   But wait -- transferring existence of a point with a given NF type in an interval IS
   the non-constant-env composition problem we are trying to solve. This is CIRCULAR
   for the general case.

   **However, at K=0**, the NF type is just a predicate assignment, and the existence
   of such a point in the interval (t, x) can be expressed as: "there exists w with
   t < w < x and char_0(tau) holds at w". This is expressible as a temporal formula
   evaluated at t: `char_0(tau) Until char_0(nf_x)` (approximately). Using the
   depth-2 1-var agreement at t/t' and x/x', we can transfer this temporal assertion.

   **Wait, this requires temporal truth transfer at t/t', which requires... the
   completeness theorem we are trying to prove.** This IS circular.

   **REVISED APPROACH for K=0**: Instead of using UZ/SZ with temporal formulas, use
   the direct existential transfer from depth-2 1-var agreement. Specifically:

   - From h_x (depth-2 1-var at x/x'), get depth-1 2-var transfer at [w,x]/[w',x']
     via `cross_extend_bwd_1var`.
   - From h_t (depth-2 1-var at t/t'), get depth-1 2-var transfer at [w,t]/[w',t']
     via `cross_extend_bwd_1var`.

   But these give TWO DIFFERENT witnesses w'_x and w'_t. Can we get a SINGLE w' with
   all three orders matching?

   For the between zone (t < w < x, so t' < w' < x'):
   - From h_x: exists w'_x with depth-1 2-var at [w,x]/[w'_x,x']. This gives
     w < x iff w'_x < x' (both true) and matching predicates at w/w'_x.
   - From h_t: exists w'_t with depth-1 2-var at [w,t]/[w'_t,t']. This gives
     w > t iff w'_t > t' (both true) and matching predicates at w/w'_t.
   - **Both w'_x and w'_t have the same depth-1 1-var NF as w** (from
     cross_1var_from_2var). Since depth-1 1-var determines depth-0 1-var
     (by monotonicity), they have the same predicates.
   - But w'_x < x' and w'_t > t' -- are they in the same interval?
     w'_x < x' is guaranteed. But is w'_x > t'? Not directly!
     w'_t > t' is guaranteed. But is w'_t < x'? Not directly!

   **This is the fundamental gap.** We get two witnesses in the right half-planes but
   cannot guarantee either is in the intersection (t', x').

   **RESOLUTION**: At depth 0, we do not need a witness in N at all from UZ/SZ. We can
   use the **constant-env composition applied to h_x** or **h_t** directly, because at
   depth 0, `nf_eval_nf M 0 3 [w, x, t] ssn3` is just atom matching, and for the
   between zone, we need `w > t AND w < x` -- but the witness from `cross_extend_bwd_1var`
   via h_x gives `w'_x < x'` and matching predicates, and we need to also show `w'_x > t'`.

   The 2-var agreement at [w,x]/[w'_x,x'] gives at depth 1: the quantifier part says
   for every depth-0 2-var NF chi, `(exists z, nf_eval M 0 2 [z,w] chi) <-> (exists z',
   nf_eval N 0 2 [z',w'_x] chi)`. At depth 0 this means: the realization of 1-point
   types relative to w and w'_x match. In particular, we can ask about the depth-0 type
   [t, w] vs [t', w'_x]:

   Actually, this does not help directly because the existential is over z inserted
   above w (or below w), not about existing t. But t is already a fixed point.

   **CORRECTED RESOLUTION**: The right approach for the between zone at K=0 is:

   Use the fact that at depth 0, ssn3 completely specifies the predicate assignment
   at w and the order relationships. Since h_x and h_t give us **depth-2** 1-var
   agreement, they give depth-1 quantifier transfer. The depth-1 quantifier transfer
   at x/x' says: `(exists w, nf_eval M 1 2 [w,x] chi2) <-> (exists w', nf_eval N 1 2
   [w',x'] chi2)`. We can choose chi2 to be the depth-1 2-var NF of [w,x] in M.
   Then w'_x has depth-1 2-var agreement with w at [w,x]/[w'_x,x'].

   From depth-1 2-var at [w,x]/[w'_x,x'], extract:
   - depth-0 2-var at [w,x]/[w'_x,x'] (by monotonicity): just atom matching at pairs
   - In particular, w < x iff w'_x < x' (both true, from orders)

   Now for w > t iff w'_x > t': we also have depth-1 2-var at [w,t]/[w'_t,t'] from h_t.
   Both w'_x and w'_t have depth-1 1-var agreement with w. So they have the same
   depth-1 1-var NF. If the structure N has ONLY ONE point with that 1-var NF in (t', x'),
   then w'_x = w'_t and we are done. But N can have many points with the same NF.

   **THE ACTUAL RESOLUTION at K=0**: Since ssn3 is depth-0 arity-3, `nf_eval_nf M 0 3
   [w, x, t] ssn3` just says every atom evaluates correctly. The atoms are:
   - pred(p, 0) for w, pred(p, 1) for x, pred(p, 2) for t: predicates at each point
   - order(0,1) for w < x, order(1,0) for x < w, order(0,2) for w < t, etc.

   For the forward direction, given w in M with all atoms matching, we need w' in N.
   The predicate assignment at w is determined by ssn3 (atoms at variable 0). The order
   constraints determine the zone. For the between zone (t < w < x), we need w' with:
   - Same predicates as w (equivalently, same as ssn3 prescribes at var 0)
   - t' < w' < x'

   At depth 0, the predicates at w' are just the unary predicates. The question is:
   does N have a point in (t', x') with the right predicate assignment?

   We CAN use Prior-UZ here, but not via temporal_truth directly. Instead:
   - From h_x (depth-2 1-var at x/x'), by the quantifier part at depth 1, we get
     depth-1 2-var existential transfer. Specifically, the depth-0 2-var NF of [w,x]
     in M is transferable to [w'_x, x'] in N.
   - The depth-0 2-var NF of [w,x] includes the order w < x and the predicates at
     both w and x. Since w < x and w'_x has the same depth-0 2-var NF, we get
     w'_x < x' and matching predicates at w'_x.
   - Similarly from h_t, we get w'_t with depth-0 2-var at [w,t]/[w'_t,t'], giving
     w'_t > t' and matching predicates.

   Now the question: is w'_x > t'?

   From depth-0 2-var at [w,x]/[w'_x,x']:
   - w < x iff w'_x < x' (TRUE)
   - preds match at w, w'_x

   From depth-2 1-var at t/t' and depth-0 1-var at w/w'_x:
   - w'_x has the same depth-0 1-var NF as w (from depth-0 2-var at [w,x])
   - w has the same depth-0 1-var NF as w'_t (from depth-0 2-var at [w,t])
   - So w'_x and w'_t have the same depth-0 1-var NF

   But depth-0 1-var is just predicate assignment -- it says nothing about order
   relative to other points!

   **FUNDAMENTAL ISSUE**: Even at K=0, the between-zone transfer requires showing
   that N has a point with the right predicates IN THE RIGHT INTERVAL. The depth-2
   1-var hypotheses give us points with the right predicates relative to x' OR
   relative to t', but not simultaneously relative to both.

   **THIS IS PRECISELY THE NON-CONSTANT-ENV COMPOSITION PROBLEM.**

   **REVISED RESOLUTION**: This is where the Prior-UZ/SZ axioms enter. On Prior
   structures, the intervals are constrained: if there exists a point with predicate
   assignment tau in (t, x) in M, and M satisfies UZ, then the char_0 formula for
   tau can be expressed temporally. The UZ/SZ axioms, when applied to N with the same
   temporal formula, constrain where matching points appear. But this requires temporal
   truth transfer, which requires completeness, which is what we are proving.

   **HOWEVER**: the temporal truth transfer for depth-0 formulas IS available. CharPart(0)
   gives us temporal formulas for depth-0 NFs. The depth-2 1-var agreement at t/t'
   implies depth-2 sentence agreement (0-var NF agreement) by the quantifier tower:
   depth-2 1-var -> depth-1 2-var (via quantifier) -> depth-0 3-var (via quantifier).
   But this is existential transfer at the sentence level, which is not quite what we need.

   Actually, the key missing step is much simpler. We should use the **h_xt hypothesis**
   that `exist_transfer_3var_nonconstenv` receives. In the K=0 base case, h_xt is
   constructed inline (lines 304-322). Looking at the proof structure:

   The base case calls `exist_transfer_3var_nonconstenv M x t N x' t' h_x h_t
   (fun nf2 => ...) sub_nf` where the third argument builds h_xt (depth-1 2-var at
   [x,t]/[x',t']). Inside `exist_transfer_3var_nonconstenv`, h_xt gives depth-0 3-var
   transfer (from hex_K), which is EXACTLY what the sorry needs.

   Wait -- re-reading the code. `exist_transfer_3var_nonconstenv` receives h_xt at
   depth-(K+1) 2-var. At K=0, this is depth-1 2-var. The hex_K derived from h_xt is
   depth-0 3-var transfer. **hex_K is depth-K = depth-0 3-var transfer!**

   So at K=0, hex_K already gives us: for every depth-0 3-var NF chi,
   `(exists w, nf_eval M 0 3 [w, x, t] chi) <-> (exists w', nf_eval N 0 3 [w', x', t'] chi)`.

   **THIS IS EXACTLY THE GOAL AT LINE 322 (with ssn3 for chi).**

   BUT WAIT -- the h_xt at line 304 is being CONSTRUCTED, not given. The sorry is INSIDE
   the construction of h_xt. Let me re-read.

   Lines 304-322: `exist_transfer_3var_nonconstenv M x t N x' t' h_x h_t (fun nf2 => ...)`.
   The `(fun nf2 => ...)` lambda is constructing h_xt. The sorry at line 322 is INSIDE this
   lambda -- it is proving the quantifier part of the depth-1 2-var agreement at [x,t]/[x',t']
   that will serve as h_xt for the outer `exist_transfer_3var_nonconstenv` call.

   So the sorry at line 322 is: prove depth-0 3-var existential transfer at [w, x, t] /
   [w', x', t'] given:
   - h_x1: depth-1 1-var at x/x' (from monotonicity of h_x)
   - h_t1: depth-1 1-var at t/t' (from monotonicity of h_t)
   - h_atom1: atom agreement at [x,t]/[x',t']
   - h_order_M/N: t < x, t' < x'
   - h_UZ_M, h_SZ_M, h_UZ_N, h_SZ_N: Prior axioms
   - **NO h_xt hypothesis** -- that is what we are constructing

   And `exist_transfer_3var_nonconstenv` needs h_xt to derive hex_K. Without h_xt, hex_K
   is not available.

   **So my earlier analysis was wrong about hex_K being available at K=0.**

   At K=0, the proof builds h_xt inline as the third argument to
   `exist_transfer_3var_nonconstenv`. Inside that construction, the sorry is asking
   for depth-0 3-var transfer WITHOUT hex_K (because hex_K would come from h_xt which
   we haven't built yet).

   **REVISED CONCLUSION**: The K=0 sorry is NOT trivially closable from hex_K. It requires
   a direct proof of depth-0 3-var existential transfer on non-constant environments [x,t]/[x',t']
   from depth-1 1-var agreement at x/x' and t/t' plus Prior-UZ/SZ. This is the same
   fundamental problem as the general case but at the purely atomic level.

2. **Claim: "Approach (b) does not help"**

   **Challenge**: What if the enriched formula encodes the between-zone content not via
   Until guards but via explicit existential conjuncts?

   **Verification**: The current code's eq-zone case (lines 596-734) already does this:
   it uses ih_exist formulas to encode each quantifier condition as a temporal conjunct.
   This works for the eq zone because the environment is constant [t, t]. For the Until
   zone, the ih_exist formulas would need to encode `exists y, nf_eval M k 3 [y, x, t] ssn`
   which requires ExistPart(k) at n=2 (arity 3). But ExistPart(k) at n=2 uses
   `existPart_succ_n1_bypass` at n=1 plus `constenv_2var_determines` -- this only works
   on constant environments. For non-constant [x, t], it would need the very
   non-constant-env transfer we are trying to prove. **CONFIRMED: circular.**

3. **Claim: "The inductive case may follow the same pattern as K=0"**

   **Challenge**: Even if K=0 is closed, does the pattern actually generalize?

   **Verification**: At the inductive step (K+1), the IH gives depth-(K+1) 2-var at
   [x,t]/[x',t'] (h_xt_IH at line 345). This h_xt_IH is passed to
   `exist_transfer_3var_nonconstenv`. Inside that function, hex_K is derived from h_xt_IH,
   giving depth-K 3-var transfer. So the inductive case has hex_K available (unlike K=0).
   The remaining gap is the same: merge c and c_K into a single witness with depth-(K+1)
   3-var agreement. **CONFIRMED: the inductive case is structurally different from K=0.**

### Summary of Adversarial Verification

The adversarial verification triggered a significant REVISION:

**ORIGINAL recommendation**: Close K=0 first using existing infrastructure.

**REVISED understanding**: The K=0 sorry is NOT inside `exist_transfer_3var_nonconstenv`
but inside the construction of h_xt that feeds into it. K=0 needs a DIRECT proof of
depth-0 3-var existential transfer without any IH hypothesis.

**The corrected dependency structure**:
- Lines 322, 399 (K=0 base): depth-0 3-var transfer WITHOUT h_xt, using only h_x1, h_t1
  (depth-1 1-var) plus Prior-UZ/SZ. This is the foundation.
- Lines 231, 239 (inductive): depth-(K+1) 3-var transfer WITH h_xt (from IH), using
  hex_K + hex_x plus the merging argument.

**Both cases need Prior-UZ/SZ**, but in different ways:
- K=0: UZ/SZ needed to find witnesses in the between zone with correct atom assignments
- Inductive: UZ/SZ needed to ensure the witness from hex_x is in the correct zone relative
  to t'/x', or to find a new witness that combines the zone information from c_K and c.

---

## Revised Direction

The adversarial verification revealed that ALL four sorries reduce to variants of the same
fundamental problem: **zone-aware existential witness transfer on non-constant environments,
using Prior-UZ/SZ to constrain the between zone.**

### Recommended Path Forward

**Step 1**: Prove a `depth0_3var_transfer_prior` lemma that handles the K=0 case directly.

```lean
theorem depth0_3var_transfer_prior {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : forall nf : NormalForm sig 1 1,
      nf_eval_nf M 1 1 (fun _ => x) nf <-> nf_eval_nf N 1 1 (fun _ => x') nf)
    (h_t : forall nf : NormalForm sig 1 1,
      nf_eval_nf M 1 1 (fun _ => t) nf <-> nf_eval_nf N 1 1 (fun _ => t') nf)
    (h_order_M : t < x) (h_order_N : t' < x')
    (ssn3 : NormalForm sig 0 3) :
    (exists w, nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) ssn3) <->
    (exists w', nf_eval_nf N 0 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) ssn3)
```

Key insight for proof: at depth 0, `nf_eval_nf M 0 3 [w,x,t] ssn3` is just atom evaluation.
The atoms are predicates at w,x,t and orders between them. The x-predicates, t-predicates,
and x-t order are determined by the context. The only unknowns are w-predicates, w-x order,
and w-t order.

Zone case split on ssn3's order atoms:
- w below t (w < t < x): needs w' < t' with matching predicates. Use h_t's quantifier part.
- w between t and x (t < w < x): THE HARD CASE. Needs w' with t' < w' < x' and matching preds.
- w above x (t < x < w): needs w' > x' with matching predicates. Use h_x's quantifier part.
- w = t: use t' directly
- w = x: use x' directly

For the between zone: the depth-1 1-var agreement at x/x' gives depth-0 2-var transfer
at [w,x]/[w'_x, x']. This gives w'_x < x' with matching predicates at w. The depth-1
1-var agreement at t/t' gives depth-0 2-var transfer at [w,t]/[w'_t, t']. This gives
w'_t > t' with matching predicates.

Now: w'_x from h_x satisfies preds + (w'_x < x'). Is w'_x > t'?
And: w'_t from h_t satisfies preds + (w'_t > t'). Is w'_t < x'?

This is the gap. We need EITHER w'_x > t' OR w'_t < x'.

**Possible resolution**: From depth-0 2-var at [w,x]/[w'_x,x'], we have atom matching at
positions 0 and 1 (w and x). This includes orders: w < x iff w'_x < x'. The 2-var NF at
depth 0 also includes the quantifier condition (depth-(-1) which does not exist -- at depth
0, there IS no quantifier part). So we only get atoms.

From depth-1 1-var at x/x', the quantifier part gives depth-0 2-var existential transfer.
The depth-0 2-var NF of [w,x] encodes: preds at w, preds at x, and order w vs x. Since
w < x, the 2-var NF has order(0,1) = true. We transfer to w'_x with the same depth-0
2-var NF -- so w'_x < x' and matching preds. Nothing about t'.

**The between-zone gap at depth 0 appears to require a new argument.** The candidate
approaches are:

(i) **Direct Prior-UZ/SZ argument**: Since N satisfies UZ/SZ, and we know x' has certain
predicates, and there exists some temporal formula (constructible from depth-0 NF types)
that distinguishes the predicate assignment tau (= the assignment ssn3 prescribes at var 0),
apply UZ to N starting from t' looking for char_0(tau). UZ gives a first occurrence s in
(t', something). If that something is x' or beyond, we need to show s < x'.

This requires knowing that char_0(tau) holds somewhere in (t', x') in N. We know it holds
in (t, x) in M (namely at w). But transferring "char_0(tau) holds in (t, x)" to
"char_0(tau) holds in (t', x')" is exactly a depth-0 between-zone transfer -- CIRCULAR.

(ii) **Use h_x at depth 2 (not just depth 1)**: The original h_x is depth-2, not depth-1.
The code currently weakens to h_x1 at depth 1. If we use the FULL h_x at depth 2, the
quantifier part gives depth-1 2-var existential transfer at [w,x]/[w'_x,x']. Depth-1
2-var NF at [w,x] includes:
- Atoms: preds at w, preds at x, order w < x
- Quantifiers: for each depth-0 3-var NF chi, (exists z, nf_eval M 0 3 [z,w,x] chi) is
  determined.

The depth-0 3-var NF chi at [z, w, x] tells us about points z relative to BOTH w and x.
In particular, if we choose chi to encode "z > w, z < x, z has preds of t" (i.e., z is
between w and x with t's predicates), then:
- M has such a z iff the interval (w, x) contains a point with t's predicates
- Since t is in (w, x)... wait, t < w < x is NOT the case in the between zone.
  In the between zone, t < w < x. So t < w, meaning t is NOT in (w, x).

Hmm, but we could choose chi to encode "z < w, z has t's preds", which would capture t
itself. Then: exists z with depth-0 3-var at [z, w, x] = [t, w, x] encoding "z < w, z < x,
z has t's preds" -- yes, z = t works in M. Transfer via depth-1 2-var: exists z' with same
depth-0 3-var at [z', w'_x, x'] = ... meaning z' < w'_x, z' < x', z' has t's preds.

Now z' has t's predicates (same as t by h_t at depth-0). And z' < w'_x. This tells us
something about the structure around w'_x, but still doesn't directly give w'_x > t'.

**HOWEVER**: We can use the CONVERSE argument. Instead of transferring w from M to N,
we can show that if N does NOT have a point in (t', x') with the right predicates, then
M also doesn't -- contradicting our hypothesis.

Specifically: suppose for contradiction that N has no w' in (t', x') with the predicate
assignment tau. Then every point in (t', x') has a different predicate assignment. But
from depth-2 1-var at x/x' (which gives depth-1 2-var transfer), we can transfer the
existence of a point between t and x with predicates tau... but this again requires
knowing the 2-var NF at non-constant env.

**I believe this is genuinely hard and may require a dedicated argument about discrete
linear orders (Prior structures).** The key property of Prior/discrete orders not yet
exploited is that between any two consecutive points, there are no other points. On a
discrete order, intervals are either empty or contain finitely many points, and the
interval structure is completely determined by the order type (number of points) and the
predicate assignments.

**Step 2**: If the depth-0 direct approach fails, consider a REFORMULATION of
`exist_transfer_3var_nonconstenv` that builds h_xt directly (using the Prior-UZ/SZ
axioms and CharPart(0) / ExistPart(0)) rather than taking h_xt as a parameter.

The key idea: at the K=0 base case, instead of trying to build h_xt (depth-1 2-var)
from scratch and then feeding it to `exist_transfer_3var_nonconstenv`, build the
depth-2 2-var agreement DIRECTLY using a zone-by-zone argument:

For each 3-var sub-NF ssn3, classify the outermost variable's zone relative to x and t.
For each zone, use the appropriate 1-var hypothesis (h_x or h_t) to find a witness.
For the between zone, use a dedicated Prior-structure lemma that exploits discreteness.

---

## Tactic Survey Results

No tactic attempts were made in this research phase. The sorries require new lemma
construction, not tactic application.

---

## Key Findings Summary

1. **Rabinovich's proof avoids the non-constant-env problem entirely** by working with
   exists-forall formulas that encode interval types directly. The NF-based approach in
   the Lean code does not have this luxury.

2. **The current formula (char_kp1(nf_t0) AND (char_kp1(nf_x0) Until Top)) loses
   between-zone information** by using Top as the Until guard. This is the root cause
   of the 4 sorries.

3. **Enriching the Until guard (approach b) does not help** because encoding between-zone
   content requires the same non-constant-env composition being proved.

4. **All 4 sorries reduce to the same fundamental problem**: transferring existential
   witnesses between structures on non-constant environments, using Prior-UZ/SZ to
   handle the between zone.

5. **The K=0 base case is NOT simpler than it initially appears.** Even at depth 0 (purely
   atomic), the between-zone transfer requires showing N has a point in the right
   interval with the right predicates. This is the zone-matching problem.

6. **Prior-UZ/SZ must be used in a non-circular way.** Direct application via temporal
   formulas requires completeness (circular). The UZ/SZ axioms must be applied at the
   semantic level, not via temporal truth transfer.

7. **The correct approach is likely a self-contained EF-game or back-and-forth argument**
   that proves the composition theorem for Prior structures from scratch, using the
   UZ/SZ axioms directly at the semantic level (not via temporal formulas).
