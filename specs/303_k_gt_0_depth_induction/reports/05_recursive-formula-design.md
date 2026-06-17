# Research Report: Recursive Formula Design for Non-Constant-Env Existentials

**Task**: 303 (k_gt_0_depth_induction)
**Session**: sess_1781699606_7f7ccd
**Agent**: lean-research-hard-agent
**Date**: 2026-06-17
**Reference grounding tier**: Tier 1 (literature-backed, Rabinovich 2014)

## H3 Reference Grounding Table

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|--------------|-----------------|----------------|--------|
| Rabinovich 2014, Prop 3.5 | V-EA with one free var -> TL formula via nested Until/Since | `enriched_vecEA2_until` / `enriched_vecEA2_since` | N/A (definition, not theorem) | Implemented (k=0 only) |
| Rabinovich 2014, Prop 4.2 | Closure under negation for EA formulas | `existPart_succ` + `charPart_succ` | `ExistPart atomMap h_surj (k+1)` | Implemented (sorry at k>0) |
| Rabinovich 2014, Sec 5, Lemma 5.1 | Interval splitting: negate EA formula by decomposing zones | `ssn_zone_until` / `ssn_zone_since` | `NormalForm sig 0 3 -> YZone` | Implemented (k=0 only) |
| Rabinovich 2014, Sec 5, Corollary 5.4 | Nested temporal encoding of bounded existentials | `VecEA2.holdsLeft` / `VecEA2.holdsRight` | VecEA2 bracket formula semantics | Implemented (k=0 only) |
| Doets 1989, Def 1.6.1 | n-characteristics (Normal Forms) | `NormalForm sig k n` | `Nat -> Nat -> Type` | Implemented |
| Doets 1989, Lemma 1.4 | Composition: 2-var agreement on constant envs determines n-var | `constenv_2var_determines` | `nf_eval_nf M k (n+1) [x,t,...,t] nf <-> nf_eval_nf N k (n+1) [x',t',...,t'] nf` | Implemented |
| NEW (this report) | Generalized ExistPart for non-constant parent envs | `GeneralExistPart` (proposed) | See Section 2 | Design |

## Summary

The two remaining sorry sites at KampBypass.lean:617 and :669 require transferring depth-(k'+1) arity-3 existentials between (M, [y,x,t]) and (M0, [y0,x0,t0]) where x != t. The existing ExistPart only handles constant-parent environments [y, z, z, ..., z]. This report designs a recursive construction that generalizes ExistPart to handle arbitrary parent environments.

## 1. Problem Statement

### 1.1 The Sorry Goal

At both sorry sites (Until:617, Since:669), the goal is:

```
forall ssn : NormalForm sig (k'+1) 3,
  (exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) <->
  sub_nf.2 ssn = true
```

Available hypotheses include `h_eval0_quant` giving the same for M0 at `[y0, x0, t0]`, and cross-structure 1-var agreements `h_x_agree` and `h_t_agree` at depth (k'+2).

### 1.2 Why ExistPart Fails

`ExistPart(k)` produces formulas for:
```
exists x, nf_eval M k (n+1) (Fin.cons x (fun _ => t)) sub_nf'
```
The tail environment is always constant `(fun _ => t)`. For the non-constant environment `Fin.cons x (fun _ => t)` (which has TWO distinct values: x and t), there is no way to call `ih_exist` because the parent_atoms parameter encodes only t's predicates, not x's.

### 1.3 Why Transfer Fails Without Formula Enrichment

The existing formula `char_kp1(nf_t0) AND (char_kp1(nf_x0) Until top)` provides:
- 1-var NF agreement at x/x0 (depth k'+2)
- 1-var NF agreement at t/t0 (depth k'+2)
- Order: t < x (Until) or x < t (Since)

This is insufficient because 1-var agreements at x and t SEPARATELY do not determine the 2-var NF at [x,t] (counterexample: Z with (0,2) vs (0,1)). The 2-var NF depends on what exists BETWEEN x and t, which 1-var agreements cannot constrain.

## 2. The Correct Approach: Generalize ExistPart

### 2.1 Overview

Instead of a standalone recursive formula definition, the correct approach is to **strengthen ExistPart** to handle non-constant parent environments. This means replacing the current formula construction to directly encode the 3-var quantifier conditions in the temporal formula.

The key insight: the enriched formula for the Until/Since zone must carry explicit temporal conjuncts for EACH depth-(k'+1) arity-3 sub-NF ssn, just as the eq-zone case (KampBypass.lean:700-716) already does. The difference is that the eq-zone case can use `ih_exist` directly (because x=t makes the env constant), while the non-constant case requires building the ssn formulas by a different mechanism.

### 2.2 Proposed Definition: `GeneralExistPart`

```lean
/-- GeneralExistPart(k): for all arities r >= 1, given:
    - depth-k characteristic formulas for 1-var NFs
    - NF types of the r parent environment elements
    - a depth-k (r+1)-var sub-NF ssn
    there exists a temporal formula A such that for any Prior structure M
    and any environment e : Fin r -> M.carrier matching the given NF types,
    the truth of A at e(0) iff exists y, nf_eval M k (r+1) (Fin.cons y e) ssn. -/
abbrev GeneralExistPart {sig : MonadicSignature}
    (atomMap : Formula -> sig.preds)
    (h_surj : forall p, exists a, atomMap (.atom a) = p)
    (k : Nat) : Prop :=
  forall (r : Nat) (_ : r >= 1)
    (char_k : NormalForm sig k 1 -> Formula)
    (char_k_correct : forall (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) <->
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (env_nfs : Fin r -> NormalForm sig (k+1) 1)
    (ssn : NormalForm sig k (r + 1)),
    exists (A : Formula),
      forall (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (e : Fin r -> M.carrier),
        (forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)) ->
        (temporal_truth M atomMap (e 0) A <->
         exists y, nf_eval_nf M k (r+1) (Fin.cons y e) ssn)
```

### 2.3 Why This is the Right Abstraction

1. **Subsumes ExistPart**: When all env elements have the same NF type (constant env), GeneralExistPart reduces to ExistPart. The parent_atoms parameter of ExistPart is derivable from `env_nfs`.

2. **Closes the Sorry**: At the sorry site, we need to show each ssn's existential matches sub_nf.2. With GeneralExistPart(k'+1) at r=2 with env_nfs = [nf_x0, nf_t0], we get a formula A for each ssn. The formula's truth at x (evaluated at e(0) = x in Until, with e(1) = t) gives the required biconditional.

3. **Recursion terminates**: The proof of GeneralExistPart(k) requires GeneralExistPart(k-1) at arity r+1, with k strictly decreasing. The base case k=0 is purely atomic.

## 3. Zone Decomposition at Depth k > 0

### 3.1 Structure of the Existential

For `exists y, nf_eval M k (r+1) (Fin.cons y e) ssn` where e = [x, t] (r=2) and k = k'+1:

```
nf_eval M (k'+1) 3 [y, x, t] ssn  =
  (forall a : AtomKind sig 3, atom_eval M [y,x,t] a <-> ssn.1 a = true) AND
  (forall sub : NF(k') 4,
    (exists z, nf_eval M k' 4 [z, y, x, t] sub) <-> ssn.2 sub = true)
```

### 3.2 Atom Conditions Determine Zone

The atom part of ssn encodes:
- y's predicates (matching some 1-var NF type tau_y)
- x's predicates (must match nf_x0, known from env_nfs)
- t's predicates (must match nf_t0, known from env_nfs)
- Orders: y < x?, x < y?, y < t?, t < y? (determines y's zone relative to x and t)

For the Until zone (t < x), the zones for y are:
- **y < t**: y is below both. Temporal encoding: `Since(char(tau_y), ...)` from t.
- **y = t**: y coincides with t. Trivially evaluable at t.
- **t < y < x**: y is between. Temporal encoding: `...(char(tau_y) Until ...)` from t toward x.
- **y = x**: y coincides with x. Trivially evaluable at x.
- **y > x**: y is above both. Temporal encoding: `Until(char(tau_y), ...)` from x.

### 3.3 Quantifier Conditions: Recursive Decomposition

For each zone, the existential further decomposes. At zone t < y < x:

```
exists y in (t, x), 
  nf_eval M (k'+1) 3 [y, x, t] ssn
```

This requires:
1. y has 1-var NF type tau_y (atom part) -- encodable via `char(k'+1)(tau_y)`
2. For each sub : NF(k', 4), the existential `exists z, nf_eval M k' 4 [z, y, x, t] sub` matches ssn.2(sub)

Condition 2 is the recursive case: it's `GeneralExistPart(k')` at arity r=3 with env = [y, x, t].

The temporal formula for the between-zone becomes:
```
exists y in (t, x) with:
  char(k'+1)(tau_y) AND (conjunction of GeneralExistPart(k') formulas for each sub)
```

The "exists y in (t, x)" structure maps to `NOT(NOT(P) Until char(x_type))` from t, where P is the point guard (the conjunction above). This is precisely the Rabinovich Prop 3.5 pattern.

### 3.4 Zones with Constant-Env Reduction

For zones where y equals one of the env elements (y = x or y = t), the existential reduces:
- **y = x zone**: env [y, x, t] = [x, x, t], but y = x is forced. The existential becomes "does nf_eval [x, x, t] ssn hold?" The quantifier conditions at [z, x, x, t] have z relative to {x, t} -- this is a 2-element constant-like structure.
- **y = t zone**: similarly reduces.

For zones where y is OUTSIDE the (t, x) interval:
- **y > x zone**: env [y, x, t] has y > x > t. The [z, y, x, t] conditions have z relative to a 3-element ordered set. But z can be encoded temporally from y as evaluation point.
- **y < t zone**: mirror.

### 3.5 The Full Recursive Formula (Pseudocode)

```
generalExistFormula(k, r, char_k, env_nfs, ssn) :=
  -- For each compatible 1-var NF type tau_y of y:
  disjunction over tau_y with ssn.atom_part matching at var 0:
    -- For each zone of y relative to the env:
    case zone of
    | eq_i (y = e_i): 
        -- Check if ssn's conditions hold at e_i
        -- Uses char(k+1)(tau_y) at e_i plus quantifier conjunction
        -- Quantifier conditions: for each sub : NF(k-1, r+2),
        --   generalExistFormula(k-1, r+1, char_{k-1}, [tau_y] ++ env_nfs, sub)
        --   evaluated at e_i
        conjunction of:
          char(k+1)(tau_y)  -- evaluated at e_i
          for each sub: if ssn.2(sub) then 
            generalExistFormula(k-1, r+1, char_{k-1}, [tau_y]++env_nfs, sub)
          else
            neg(generalExistFormula(k-1, r+1, char_{k-1}, [tau_y]++env_nfs, sub))

    | between(e_i, e_{i+1}) (e_i < y < e_{i+1}):
        -- Encode "exists y in (e_i, e_{i+1}) with point_guard(y)"
        -- point_guard(y) = char(k+1)(tau_y) AND quant_conj(y)
        -- Temporal encoding from e_i: NOT(NOT(point_guard) Until char(e_{i+1}_type))
        let point_guard := char(k+1)(tau_y) AND 
          conjunction over sub : NF(k-1, r+2):
            if ssn.2(sub) then 
              generalExistFormula(k-1, r+1, ...)
            else neg(generalExistFormula(k-1, r+1, ...))
        NOT(NOT(point_guard) Until char(k+1)(env_nfs(i+1)))
        -- evaluated at e_i

    | above_all (y > max(env)):
        -- Until(point_guard, top) from the max env element
        Until(point_guard, top) at e_max

    | below_all (y < min(env)):
        -- Since(point_guard, top) from the min env element
        Since(point_guard, top) at e_min

  -- Base case k = 0: NF(0, r+1) is purely atomic.
  -- All conditions reduce to order + predicate checks.
  -- Zone decomposition yields direct temporal encoding
  -- (matching existing KampBypassUntil.lean infrastructure).
```

## 4. Integration with KampBypass.lean

### 4.1 The Enriched Formula

The Until zone formula (KampBypass.lean:579) currently is:
```lean
let until_formula := Formula.and (char_kp1 nf_t0) (Formula.untl (char_kp1 nf_x0) Formula.top)
```

This must be replaced with:
```lean
let char_k := fun nf_k => (ih_char nf_k).choose
-- Build quant_conj using GeneralExistPart(k'+1) at r=2
let quant_formulas : NormalForm sig (k'+1) 3 -> Formula := fun ssn =>
  (generalExistPart_proof (k'+1) 2 (by omega) char_k char_k_correct
    ![nf_x0, nf_t0] ssn).choose
let quant_conj := formula_conjList
  ((Fintype.elems).val.toList.map fun ssn =>
    if sub_nf.2 ssn then quant_formulas ssn
    else (quant_formulas ssn).neg)
let until_formula := Formula.and
  (Formula.and (char_kp1 nf_t0)
    (Formula.untl (char_kp1 nf_x0) Formula.top))
  quant_conj
```

### 4.2 How the Sorry Closes

With the enriched formula, the backward proof at line 617 proceeds:

1. From `temporal_truth M atomMap t until_formula`:
   - Extract `h_t_nf`, `h_until` (as before, giving x with t < x and char at x)
   - Extract `h_quant` from the conjunct
   
2. From `h_until`, get x with 1-var NF agreement h_x_agree.

3. From `h_quant`, for each ssn : NF(k'+1, 3):
   - `GeneralExistPart(k'+1)` correctness gives:
     ```
     temporal_truth M atomMap x (quant_formulas ssn) <->
     exists y, nf_eval M (k'+1) 3 [y, x, t] ssn
     ```
   - The formula's truth (from h_quant) directly yields the required iff.

4. Combine atom part (from h_atom_agree, already proved) with quantifier part to get full `nf_eval_nf M (k'+2) 2 [x, t] sub_nf`.

### 4.3 Evaluation Point Issue

There is a subtlety: `GeneralExistPart` formulas are evaluated at `e(0)`. In the Until zone, e = [x, t], so e(0) = x. But the `until_formula` is evaluated at t (the parent evaluation point).

The temporal encoding handles this: the formula evaluated at t says `char(nf_t0) AND (enriched_point_type(nf_x0) Until top)`, where the `enriched_point_type` includes ALL quantifier conjuncts. The "Until" part finds x > t satisfying enriched_point_type at x, which includes the quantifier conjuncts evaluated at x.

So the quantifier formulas are NOT top-level conjuncts of until_formula. Instead, they are INSIDE the Until's left operand:

```lean
let enriched_x_type := Formula.and (char_kp1 nf_x0) quant_conj_at_x
let until_formula := Formula.and (char_kp1 nf_t0)
  (Formula.untl enriched_x_type Formula.top)
```

Here `quant_conj_at_x` is evaluated at x (the Until witness). Its temporal_truth at x encodes the quantifier conditions via GeneralExistPart.

But wait -- GeneralExistPart formulas for ssn with env = [x, t] are evaluated at e(0) = x. We need them to be formulas that, when evaluated at x, give the right answer. This works because:
- The formula's correctness holds for ANY M, h_UZ, h_SZ, and ANY e matching env_nfs.
- When the Until gives us x with char_kp1(nf_x0) true at x, and we know t satisfies char_kp1(nf_t0), the hypotheses are met.

The remaining issue: GeneralExistPart formulas for ssn might need evaluation at x (for the x-related conditions) but also reference t. Since the formula is temporal, evaluated at x, it can reference t via Since (since t < x in the Until zone).

This is exactly correct: the formula says "exists y in the right zone relative to x AND t". To reference t from x, use "Since(char(nf_t0), ...)" which finds t below x. But we need to be careful: we don't need to "find" t; we need the formula to be correct GIVEN that t has the right NF type. The key insight is that `GeneralExistPart` takes `env_nfs` as a parameter, and the formula is correct for ANY e matching those NFs. So the formula at x can use temporal connectives that probe the structure around x, and as long as the semantics match, the biconditional holds.

### 4.4 Concrete Integration Pattern

The enriched Until formula becomes:
```lean
-- For each compatible nf_x (1-var NF type of x):
-- Build the enriched point type at x:
let enriched_pt (nf_x : NormalForm sig (k'+2) 1) : Formula :=
  Formula.and (char_kp1 nf_x) (quant_conj_for nf_x)

where quant_conj_for nf_x :=
  formula_conjList
    (NF(k'+1, 3).list.filterMap fun ssn =>
      if ssn_compatible_with nf_x nf_t0 sub_nf ssn then
        let A := generalExistFormula(k'+1, 2, char_k, ![nf_x, nf_t0], ssn)
        if sub_nf.2 ssn then some A else some A.neg
      else none)

-- The main formula:
let until_formula := Formula.and (char_kp1 nf_t0)
  (Formula.untl (enriched_pt nf_x0) Formula.top)
```

## 5. Proof Strategy for GeneralExistPart

### 5.1 Induction on k

```
GeneralExistPart(0):
  NF(0, r+1) is purely atomic (AtomKind sig (r+1) -> Bool).
  The existential is: exists y, forall a, atom_eval M [y, e_1, ..., e_r] a <-> ssn(a).
  Zone decomposition + temporal encoding (Since/Until for y's position).
  This generalizes the k=0 infrastructure (KampBypassUntil/Since).
  
GeneralExistPart(k+1) from CharPart(k+1) + GeneralExistPart(k):
  NF(k+1, r+1) = (atoms, quantifiers) where quantifiers : NF(k, r+2) -> Bool.
  The existential splits into:
    exists y, [atom_conditions(y)] AND [quant_conditions(y)]
  
  atom_conditions: determined by tau_y (1-var NF type of y) and zone.
  quant_conditions: for each sub : NF(k, r+2),
    (exists z, nf_eval M k (r+2) [z, y, e_1, ..., e_r] sub) <-> ssn.2(sub)
  
  The inner existential is GeneralExistPart(k) at arity r+1 with
  env_nfs = [tau_y, nf_1, ..., nf_r]. Depth decreases from k+1 to k.
```

### 5.2 Base Case (k=0)

For `exists y, forall a : AtomKind sig (r+1), atom_eval M [y, e_1, ..., e_r] a <-> ssn(a)`:

The atom conditions decompose into:
1. **Predicates at y**: determine tau_y's predicate assignment.
2. **Predicates at e_i**: must match env_nfs(i) -- these are guaranteed by hypothesis.
3. **Orders y < e_i and e_i < y**: determine y's zone.
4. **Orders e_i < e_j**: determined by env_nfs -- fixed by hypothesis.

So the existential reduces to: "does there exist y in zone Z with 1-var NF type tau_y?" This is purely a temporal question encodable as:
- Zone y = e_i: just check tau_y at e_i (using char_0).
- Zone y in (e_i, e_{i+1}): `NOT(NOT(char_0(tau_y)) Until char_0(env_nf(i+1)))` from e_i.
- Zone y > max(env): `Until(char_0(tau_y), top)` from max.
- Zone y < min(env): `Since(char_0(tau_y), top)` from min.

But wait: at k=0, we need the formula to be evaluated at e(0). The zones involving e(j) for j > 0 need temporal encoding FROM e(0), not from e(j). This is the Rabinovich nested Until/Since pattern:

To encode "exists y in (e_i, e_{i+1})" as a formula at e(0):
- If i = 0: "exists y in (e_0, e_1)" is directly encodable at e_0 using Until.
- If i > 0: must first navigate to e_i using Until/Since, then probe the (e_i, e_{i+1}) interval.

This navigation uses the Rabinovich Prop 3.5 nested encoding:
```
A_0 AND (B_1 Until (A_1 AND (B_2 Until ... (A_n AND Box B_{n+1})...)))
```

where A_i is the point type at e_i and B_j is the segment type between e_{j-1} and e_j.

### 5.3 Line Count Estimate

| Component | Estimated Lines |
|-----------|----------------|
| `GeneralExistPart` definition | 20 |
| `generalExistPart_zero` (k=0 base case) | 200-300 |
| `generalExistPart_succ` (k+1 step) | 300-400 |
| Zone decomposition at general arity | 150-200 |
| Integration with KampBypass.lean (enriched formula) | 150-200 |
| Helper lemmas (env manipulation, NF projections) | 100-150 |
| **Total** | **920-1250** |

## 6. Alternative: Avoid GeneralExistPart via Transfer Theorem

### 6.1 The Transfer Approach

Instead of building a recursive formula, prove a TRANSFER theorem: if M and M0 have cross-structure 1-var agreements at each env element at depth (K+2), then for any depth-(K+1) (r+1)-var NF ssn:

```lean
theorem nonconstenv_exist_transfer
    (M N : OrderedMonadicStructure sig) (K r : Nat)
    (e_M : Fin r -> M.carrier) (e_N : Fin r -> N.carrier)
    (h_agrees : forall i, forall nf : NF(K+2, 1),
      nf_eval_nf M (K+2) 1 (fun _ => e_M i) nf <->
      nf_eval_nf N (K+2) 1 (fun _ => e_N i) nf)
    (h_orders : forall i j, e_M i < e_M j <-> e_N i < e_N j)
    (ssn : NormalForm sig (K+1) (r+1)) :
    (exists y, nf_eval_nf M (K+1) (r+1) (Fin.cons y e_M) ssn) <->
    (exists y, nf_eval_nf N (K+1) (r+1) (Fin.cons y e_N) ssn)
```

### 6.2 Why Transfer Alone is Insufficient

This transfer theorem would let us close the sorry DIRECTLY without changing the formula: from h_eval0_quant (giving the M0 answer) and the transfer (giving equivalence), we'd get the M answer.

However, this theorem is FALSE in general. The counterexample from NfComposition.lean applies: on Z, envs [0, 2] and [0, 1] have the same 1-var NFs (by translation symmetry) and the same order pattern, but different 2-var NFs because the interval (0, 2) contains 1 while (0, 1) is empty.

### 6.3 Transfer on Prior Structures

On Prior structures (Dedekind complete chains satisfying UZ/SZ), the situation may be different. The Prior structure axiom guarantees first/last occurrence properties, which constrain the interval structure.

But Prior structures include Z, which has the counterexample above. So the transfer theorem remains false even on Prior structures.

### 6.4 Conclusion

The transfer approach is NOT viable. The formula enrichment approach (GeneralExistPart) is necessary.

## 7. Feasibility Assessment

### 7.1 Termination

The recursion is well-founded: k strictly decreases while r increases. At each recursive call, depth drops from k to k-1. After k steps, depth reaches 0 (base case). Lean's termination checker handles structural recursion on Nat.

### 7.2 K=0 Base Case

The k=0 base case is handled by existing infrastructure. The depth-0 zone decomposition (KampBypassCore.lean) and temporal encoding (KampBypassUntil.lean, KampBypassSince.lean) generalize to arbitrary arity. The existing code handles arity 3 (r=2); the generalization to arbitrary r follows the same pattern but with r-1 reference points creating 2r-1 zones.

**Concern**: The existing k=0 code (KampBypassUntil.lean: 979 lines) is specialized to r=2 (arity 3) with exactly 5 zones. Generalizing to arbitrary r requires:
- Variable-arity zone classification
- Variable-length nested Until/Since formulas (Rabinovich Prop 3.5 pattern)
- Permutation tracking for between-zone witnesses (as in VecEA2)

This is the most complex part of the construction.

### 7.3 K=0 Simplification for the Immediate Problem

For the immediate sorry at KampBypass.lean, we only need GeneralExistPart(k'+1) at r=2. At the recursive step, this requires GeneralExistPart(k') at r=3, then GeneralExistPart(k'-1) at r=4, ..., down to GeneralExistPart(0) at r=k'+2.

We could avoid full generality by proving GeneralExistPart(0) for ALL r (which is the correct thing to do for the base case anyway) and then having the inductive step handle the arity increase.

### 7.4 Formula Size

The formula grows exponentially with depth k. At depth k with arity r:
- Number of NF types: |NF(k, r+1)| (doubly exponential in k)
- Each NF type spawns a recursive formula at depth k-1
- Total formula size is O(|NF(k, r+1)| * formula_size(k-1, r+1))

This is not a problem for the FORMALIZATION (we just need existence of a formula, proved constructively via the recursion), but the actual formula object is astronomically large. Since we're proving an existential (`exists A, ...`), we only need to exhibit A, not compute with it efficiently.

### 7.5 Does the Construction Require Modifying the Mutual Induction?

**No**. The critical observation:

The current mutual induction structure is:
```
CharPart(k) + ExistPart(k) for all k
```

GeneralExistPart(k) can be proved as a COROLLARY of CharPart(k+1) + ExistPart(k), using the same available hypotheses. Specifically:

- `ih_char` gives CharPart(k'+1): depth-(k'+1) char formulas
- `ih_exist` gives ExistPart(k'+1): constant-env existentials at depth k'+1

To prove GeneralExistPart(k'+1) at r=2, we need:
1. CharPart(k'+2) -- available (it's the step we're proving)
2. GeneralExistPart(k') at r=3 -- proved by sub-induction on k'
3. The sub-induction bottoms at GeneralExistPart(0) at r=k'+2 -- base case

The proof of GeneralExistPart is a SEPARATE induction on k, sitting alongside the main kamp_mutual_induction. It does NOT require restructuring the mutual induction.

**Concretely**: Define and prove `generalExistPart_induction` in a new file, using the outputs of `kamp_mutual_induction` (CharPart(k) and ExistPart(k) for all k) as inputs. Then use it inside `existPart_succ_n1_bypass` to close the sorry.

Wait -- there is a circularity concern. `existPart_succ_n1_bypass` is used by `existPart_succ`, which is used in the proof of `kamp_mutual_induction`. If GeneralExistPart requires the OUTPUT of kamp_mutual_induction, we have a circular dependency.

Let me reconsider. The available hypotheses at the sorry site are:
- `ih_char`: CharPart(k'+1) -- depth-(k'+1) char formulas
- `ih_exist`: ExistPart(k'+1) -- constant-env existentials at depth k'+1
- `char_kp1`: CharPart(k'+2) -- depth-(k'+2) char formulas

These are the INDUCTION HYPOTHESES, not the full mutual induction output. GeneralExistPart(k'+1) needs to be provable from these hypotheses.

Can we prove GeneralExistPart(k'+1) from CharPart(k'+2) + ExistPart(k'+1) + CharPart(k'+1)?

The recursive step of GeneralExistPart requires GeneralExistPart(k') at higher arity. GeneralExistPart(k') in turn needs CharPart(k'+1) + GeneralExistPart(k'-1), and so on down to GeneralExistPart(0).

So we need to prove GeneralExistPart by induction on k INSIDE the mutual induction. This means adding GeneralExistPart as a THIRD conjunct to the mutual induction:

```lean
theorem kamp_mutual_induction (k : Nat) :
    CharPart(k) AND ExistPart(k) AND GeneralExistPart(k)
```

This is the cleanest approach and avoids circularity. The cost: modifying `kamp_mutual_induction` in KampMutualInduction.lean.

### 7.6 Modified Mutual Induction Structure

```
CharPart(0):       nf_depth0_char_formula (sorry-free)
ExistPart(0):      nf_2var_exist_formula_prior (sorry-free)  
GeneralExistPart(0): NEW -- base case for general arity

CharPart(k+1):       from CharPart(k) + ExistPart(k) (sorry-free, unchanged)
ExistPart(k+1):      from CharPart(k+1) + ExistPart(k) + GeneralExistPart(k)
                      (the sorry closes because GeneralExistPart(k) handles non-constant envs)
GeneralExistPart(k+1): from CharPart(k+1) + GeneralExistPart(k)
                        (recursive construction with depth decreasing)
```

### 7.7 Revised Line Count

| Component | Lines |
|-----------|-------|
| GeneralExistPart definition | 30 |
| generalExistPart_zero (k=0, all arities) | 250-400 |
| generalExistPart_succ (k+1 step) | 300-500 |
| Zone decomposition helpers (general arity) | 150-250 |
| Modify kamp_mutual_induction | 50-80 |
| Integration with KampBypass.lean | 100-150 |
| Misc helpers (env manipulation, NF projection) | 100-150 |
| **Total** | **980-1560** |

## 8. Adversarial Self-Verification

### 8.1 Challenge: Does GeneralExistPart(0) Generalize from Existing k=0 Code?

**Claim**: The existing k=0 infrastructure (VecEADecomp, KampBypassUntil) handles arity-3 depth-0 existentials; this generalizes to arbitrary arity.

**Verification**: The existing code handles `exists y, nf_eval M 0 3 [y, x, t] ssn` with 5 zones for y relative to {x, t}. For arity r+1, y has 2r+1 zones relative to {e_1, ..., e_r} (r equality zones + r+1 interval zones). The temporal encoding of each zone uses the same Until/Since primitives, but the nested encoding (Prop 3.5) grows in complexity.

**Assessment**: The generalization is CONCEPTUALLY sound but MECHANICALLY complex. The between-zone encoding uses VecEA2 (vector of exists-forall points with bracket formula), which assumes exactly one between-zone. With r > 2 reference points, there are multiple between-zones. The VecEA2 machinery would need to be generalized to VecEA_n or a list-based variant.

**Risk**: HIGH -- the VecEA2 generalization to arbitrary arity is the most labor-intensive part. Estimated 200-400 additional lines for the generalized bracket formula infrastructure.

### 8.2 Challenge: Is There Circularity?

**Claim**: Adding GeneralExistPart as a third mutual induction conjunct avoids circularity.

**Verification**: 
- CharPart(k+1) depends on CharPart(k) + ExistPart(k) -- no GeneralExistPart dependency.
- ExistPart(k+1) at n=1 depends on CharPart(k+1) + ExistPart(k) + GeneralExistPart(k) -- GeneralExistPart at LOWER depth.
- ExistPart(k+1) at n>=2 depends on ExistPart(k+1) at n=1 + constenv_2var_determines -- no direct GeneralExistPart dependency.
- GeneralExistPart(k+1) depends on CharPart(k+1) + GeneralExistPart(k) -- at LOWER depth.

**Assessment**: VERIFIED -- no circularity. Each conjunct at depth k+1 depends only on conjuncts at depth k (or the same depth for CharPart->ExistPart, which is already handled).

### 8.3 Challenge: Can the Between-Zone Formula Be Evaluated at e(0)?

**Claim**: All zone formulas can be expressed as temporal formulas evaluated at e(0).

**Verification**: For y in a between-zone (e_i, e_{i+1}) where i > 0:
- From e(0), navigate to e_i using nested Until/Since (the reference points are known via their char formulas).
- Probe the (e_i, e_{i+1}) interval using another Until/Since.

This requires the formula to "find" e_i from e(0). On a Prior structure, this uses `semantic_prior_UZ`: the first occurrence of char(env_nfs(i)) above (or below) the current position. This is exactly Rabinovich's Prop 3.5 nested encoding.

**Assessment**: VERIFIED conceptually. The Rabinovich encoding is:
```
A_0 AND (B_1 Until (A_1 AND (B_2 Until ... )))
```
This navigates through e_0 < e_1 < ... < e_r, testing conditions at each point and between consecutive points. The between-zone existential is encoded within the appropriate B_j segment.

**Risk**: MEDIUM -- the evaluation-point mismatch (formula evaluated at e(0) but conditions involve other env elements) requires careful bookkeeping. Prior UZ/SZ ensures the navigational Until/Since correctly find the reference points.

### 8.4 Challenge: Does ExistPart(k+1, n>=2) Still Work?

**Claim**: The existing ExistPart(k+1) at n>=2 (KampMutualInduction.lean:310-375) is unchanged.

**Verification**: The n>=2 case uses `constenv_2var_determines` to reduce to n=1. It calls `existPart_succ_n1_bypass` for the 2-var case, which is where the sorry lives. Once the sorry is closed, the n>=2 case remains sorry-free.

**Assessment**: VERIFIED -- n>=2 is unaffected.

### 8.5 Uncertain Claims

| Claim | Confidence | Basis |
|-------|-----------|-------|
| GeneralExistPart(0) can reuse VecEA2 infrastructure | 60% | VecEA2 is hardcoded for exactly 2 reference points; generalization unclear |
| The nested Prop 3.5 encoding works at general arity | 85% | Mathematically sound per Rabinovich; Lean encoding may require new machinery |
| GeneralExistPart(k+1) proof is 300-500 lines | 70% | Depends on helper lemma availability; could be higher |
| No modification to CharPart(k+1) needed | 95% | CharPart doesn't depend on GeneralExistPart |
| Lean termination checker accepts the recursion | 95% | Structural recursion on Nat (depth k) |

### 8.6 Revised Recommendation

The VecEA2 generalization risk (Section 8.1) suggests a **staged approach**:

**Stage 1**: Prove GeneralExistPart(k'+1) at r=2 ONLY (the immediate need). This avoids generalizing VecEA2 to arbitrary arity -- we only need 5 zones for y relative to {x, t}, which the existing infrastructure handles.

**Stage 2**: Close the sorry using Stage 1.

**Stage 3** (future): Generalize to arbitrary r if needed.

The key question for Stage 1: does GeneralExistPart(k'+1) at r=2 require GeneralExistPart(k') at r=3? Yes, because the quantifier conditions at depth k' have arity 4, with env [y, x, t]. But the formula for the depth-k' existential at env [y, x, t] is evaluated at y, and needs to encode "exists z in (y, x, t) structure". This is a 3-reference-point problem (arity 4), requiring 7 zones.

So even Stage 1 requires handling r=3 at depth k'-1, which requires r=4 at depth k'-2, ..., down to r=k'+2 at depth 0. The k=0 base case must handle ALL arities.

**Revised line count for Stage 1**:
- GeneralExistPart(0) at all arities: 300-500 (this is the bulk)
- GeneralExistPart(k+1) at r=2: 200-350 (specialized, not fully general)
- Integration: 100-150
- Modified mutual induction: 50-80
- Helpers: 100-150
- **Total Stage 1**: 750-1230

## 9. Recommended Implementation Strategy

### 9.1 New File: `NonconstenvExist.lean`

Place the GeneralExistPart definition and inductive proof in a new file:
```
Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NonconstenvExist.lean
```

### 9.2 Implementation Phases

**Phase A** (200-300 lines): Define GeneralExistPart. Prove the k=0 base case for all arities. This requires:
- General zone classification for y relative to r reference points on a linear order
- Temporal encoding of each zone using nested Until/Since (Rabinovich Prop 3.5)
- Correctness proof at k=0

**Phase B** (200-350 lines): Prove the inductive step GeneralExistPart(k+1) from CharPart(k+1) + GeneralExistPart(k). This requires:
- Decomposing the depth-(k+1) existential into atom + quantifier parts
- For each zone of y, building the enriched point guard using recursive formulas
- Proving forward and backward directions

**Phase C** (150-230 lines): Integrate into the mutual induction and close the sorry.
- Modify `kamp_mutual_induction` to include GeneralExistPart
- Build the enriched Until/Since formula in `existPart_succ_n1_bypass`
- Close sorry at lines 617 and 669

### 9.3 Key Risk Mitigation

1. **VecEA2 generalization**: Instead of generalizing VecEA2, encode the Rabinovich Prop 3.5 pattern directly as nested Until/Since formulas. This avoids the complex permutation tracking.

2. **Base case complexity**: The k=0 case at general arity is conceptually simple (zone decomposition + temporal encoding) but mechanically tedious. Consider proving it via a general "exists-forall formula to temporal formula" conversion.

3. **Evaluation point navigation**: Use the Rabinovich navigational pattern: from e(0), use nested Until to reach each reference point. Prior UZ guarantees first-occurrence properties needed for navigation.

## 10. Tactic Survey Results

No specific tactic survey was conducted for this research task, as the problem is a design question rather than a proof-completion question. The relevant tactics for the implementation are:

- `funext` for environment equality proofs (Fin.cons extensionality)
- `simp only [atom_eval, Fin.cons]` for atom evaluation unfolding
- `rw [formula_conjList_iff]` for conjunction list reasoning
- `omega` for Fin bounds
- `Fin.ext` for Fin equality
- Standard logic: `constructor`, `intro`, `obtain`, `exact`, `apply`

The eq-zone case (KampBypass.lean:686-825) provides the template for how the quantifier conjunction proof should proceed.
