# Research Report: Wiring VecEADecomp into the Sorry

**Task**: 273 - Chronicle Gap Contradiction Proof
**Session**: sess_1781410465_3cee28
**Agent**: lean-research-hard-agent

## Reference Grounding (Tier 3 -- Implementation-backed)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| NfCharFormula.lean:540 | Sorry site | `nf_exist_backward_prior` | `h_formula : temporal_truth M atomMap t (nf_exist_formula ...) -> exists x, nf_eval_nf M (k+1) 2 (x,t) sub_nf` | SORRY |
| NfCharFormula.lean:610 | Existential wrapper | `nf_2var_exist_formula_prior` | `exists A, forall M h_UZ h_SZ t, (atoms match) -> (temporal_truth A <-> exists x, nf_eval_nf M k 2 (x,t) sub_nf)` | Sorry at k+1 via above |
| NegationClosure.lean:1716 | Alternative sorry | `nf_exist_formula_nested_backward` | Same goal, has `p2_k` extra hypothesis | SORRY |
| NegationClosure.lean:1740 | Master induction | `master_induction` | `(k : Nat) -> P1 atomMap k /\ P2 atomMap k` | Sorry at k>=1 |
| NegationClosure.lean:1820 | Fill theorem | `nf_2var_exist_formula_prior_fill` | Extracts P2 from master_induction | Sorry propagated |
| NegationClosure.lean:1590 | Helper | `backward_2var_nf_agreement` | Given h_quant, reconstructs full 2-var NF | SORRY-FREE |
| VecEADecomp.lean:837 | Depth-0 3-var | `nf_3var_exist_depth0_characterization` | Zone decomposition of 3-var existential | SORRY-FREE |
| NfComposition.lean:228 | Composition | `intra_structure_extend` | Depth-(K+1) n-var agreement -> depth-K (n+1)-var witness | SORRY-FREE |
| NfToVecEA.lean:702 | Depth-0 2-var | `nf_2var_exist_depth0_tl` | Depth-0 2-var existential is TL-definable | SORRY-FREE |

## Findings

### Q1: Exact Sorry Type Signature

The sorry at `NfCharFormula.lean:540` has this goal state:

```
sig : MonadicSignature
atomMap : Formula -> sig.preds
h_surj : forall p, exists a, atomMap (.atom a) = p
k : Nat
char_kp1 : NormalForm sig (k + 1) 1 -> Formula
M : OrderedMonadicStructure sig
char_kp1_correct : forall nf_1 s,
    temporal_truth M atomMap s (char_kp1 nf_1) <->
    nf_eval_nf M (k + 1) 1 (fun _ => s) nf_1
parent_atoms : AtomKind sig 1 -> Bool
sub_nf : NormalForm sig (k + 1) 2
h_UZ : semantic_prior_UZ M atomMap
h_SZ : semantic_prior_SZ M atomMap
t : M.carrier
h_atoms : forall a, atom_eval M (fun _ => t) a <-> parent_atoms a = true
h_formula : temporal_truth M atomMap t
    (nf_exist_formula atomMap h_surj (k + 1) char_kp1 parent_atoms sub_nf)
-- GOAL:
exists x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
```

Key features:
- `char_kp1_correct` is specialized to a fixed M (not universally quantified over M)
- `h_formula` is about `nf_exist_formula` (the SPECIFIC formula, not just any formula)
- The goal is existential -- we need to PRODUCE x
- This is for depth k+1, not depth 0

### Q2: Depth-1 Proof Walkthrough

At depth 1 (k=0 in the sorry), `sub_nf : NormalForm sig 1 2` with:
- `sub_nf.1 : AtomKind sig 2 -> Bool` (predicate atoms for x and t, order between x and t)
- `sub_nf.2 : NormalForm sig 0 3 -> Bool` (for each 3-var depth-0 NF ssn, whether `exists y, nf_eval_nf M 0 3 (y,x,t) ssn`)

The formula `nf_exist_formula` at depth 1 uses `char_kp1 = char_1` (depth-1 1-var characteristic formulas). It constructs `Until(disjunction of char_1(nf_x), top)` for the t < x case.

From `h_formula`, we extract:
1. There exists x > t (from Until) with `char_1(nf_x)` holding for some atom-compatible `nf_x`
2. From `char_kp1_correct`: `nf_eval_nf M 1 1 (fun _ => x) nf_x` holds

To show `nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf`:
- **Atom part**: predicates at x match `sub_nf.1(.pred p 0)` -- from `nf_x` atom compatibility. Predicates at t match `sub_nf.1(.pred p 1)` -- from `h_atoms` + t-compatibility. Order between x and t matches -- from Until direction.
- **Quantifier part**: For each `ssn : NormalForm sig 0 3`, need `(exists y, nf_eval_nf M 0 3 (y,x,t) ssn) <-> sub_nf.2 ssn = true`.

The quantifier part at k=0 is where VecEADecomp is relevant. Since ssn is depth-0, the 3-var NF is purely atomic (predicates at y, x, t + orders). The existential `exists y, nf_eval_nf M 0 3 (y,x,t) ssn` reduces to zone analysis:
- If ssn requires y between t and x: need bracket witness -- handled by VecEADecomp
- If ssn requires y > x: need witness above x -- determined by predicates and M's structure
- If ssn requires y = x or y = t: trivially determined
- If ssn requires y < t: need witness below t -- determined by predicates and M's structure

**Critical gap for non-interval zones at depth 0**: Whether `exists y > x` with specific predicates is determined by the 1-var NF of x. Specifically, `nf_x.2(chi)` records whether `exists z, nf_eval_nf M 0 2 (z,x) chi`. The projection `atomProjDrop 2 (2) ssn` gives the (y,x) 2-var NF by dropping variable 2 (t). So `nf_x.2(atomProjDrop ssn)` tells us if `exists y, nf_eval_nf M 0 2 (y,x) (atomProjDrop ssn)`.

But `nf_eval_nf M 0 3 (y,x,t) ssn` is stronger than `nf_eval_nf M 0 2 (y,x) (atomProjDrop ssn)` -- it also requires predicates at t and the y-t order. However, t's predicates are fixed (from `h_atoms`) and the y-t order is determined by the y-x order and the x-t order (transitivity of linear orders). So at depth 0, the composition IS exact.

This is already encoded in `zone1_quant_check` and `zone24_quant_check` (NegationClosure.lean:607-626), which at k=0 check exact compatibility. The issue is only that `nf_full_compat_right_v2` has a design flaw for ssns with inconsistent y-t orders, not a fundamental mathematical gap.

### Q3: What `nf_exist_formula` Encodes

`nf_exist_formula` (NfCharFormula.lean:135-170) constructs:
1. t-compatibility check: predicates at t (via parent_atoms) match sub_nf at variable 1
2. Order consistency check: not both x<t and t<x
3. Witness type: `formula_disjList` of `char_k(nf_x)` for all atom-compatible nf_x
4. Wrapping: `Until(witness_type, top)` for t<x, `Since(witness_type, top)` for x<t, or `witness_type` for x=t

The formula truth gives us:
- An x in the right direction (from Until/Since)
- `char_k(nf_x)` holds at x for some atom-compatible nf_x (from the disjunction)
- From `char_kp1_correct`: `nf_eval_nf M (k+1) 1 (fun _ => x) nf_x`

The formula does NOT encode:
- Interval witnesses (y between t and x) -- this is only in `nf_exist_formula_nested`
- Non-interval zone quantifier conditions
- The full quantifier profile `sub_nf.2`

The backward direction fails because extracting x with `nf_eval_nf M (k+1) 1 ... nf_x` does NOT determine the full 2-var NF at (x,t). The 2-var NF includes quantifier conditions about 3-var NFs that involve both x and t.

### Q4: Can We Bypass `nf_exist_formula`?

**YES -- partially.** The theorem `nf_2var_exist_formula_prior` (line 610-661) only requires `exists (A : Formula)`. At depth k+1, the current proof commits to `A = nf_exist_formula ...` (line 643), but we could provide a different formula.

However, the bypass does NOT avoid the mathematical difficulty. Any formula A satisfying the biconditional `temporal_truth A <-> exists x, nf_eval_nf M (k+1) 2 (x,t) sub_nf` must encode the quantifier profile somehow. The fundamental question is always: how does the formula's truth at t determine the full 2-var NF at (x,t)?

**The NegationClosure.lean `nf_exist_formula_nested` approach** (line 793) IS such a bypass. It constructs a different formula using `char_kp1` (depth k+1 instead of depth k) and adds explicit interval Since/Until conditions. But it STILL hits the same blocker for non-interval zones (line 1705-1715).

**Alternative bypass via `intra_structure_extend`**: Instead of constructing an explicit formula, we could try to prove existence of A via a purely classical argument:

1. The set of all possible 2-var NFs at (x,t) partitions structures into finitely many classes
2. Each class is FO-definable at the right depth (by `doets_lemma_1_1`)
3. FO-definability implies temporal definability (by IH -- this is P1(k))
4. Therefore, the existential `exists x, nf_eval_nf M k 2 (x,t) sub_nf` is temporally definable

This is essentially the approach in `nf_characterizable_temporal_prior_classical`, which already works! The issue is that this theorem calls `nf_2var_exist_formula_prior` (line 696), creating the dependency on the sorry.

The FIX is to break the circular dependency by refactoring the classical existence proof to not go through `nf_2var_exist_formula_prior` at all. The `master_induction` in NegationClosure.lean does this (it inlines the classical construction), but hits the backward direction of `nf_exist_formula_nested`.

### Q5: Import Feasibility

Import graph (arrows = imports):
```
ExistsForallNF
  ^      ^
  |      |
Translation  VecEAFormula
  ^            ^
  |            |
VecEATranslation
  ^
  |
NfToVecEA   PriorDefs
  ^      ^     ^
  |      |     |
  VecEADecomp  |
               |
NfCharFormula ---> NfToVecEA (already imported)
              ---> ExistsForallNF
              ---> PriorINF
              ---> Translation
              ---> NormalForm
              ---> KampTranslation
```

**VecEADecomp does NOT import NfCharFormula.** So NfCharFormula CAN import VecEADecomp without creating a cycle. Add:
```lean
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp
```

**NegationClosure.lean already imports NfCharFormula** (which transitively imports NfToVecEA). To use VecEADecomp from NegationClosure, add:
```lean
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp
```
No cycle -- VecEADecomp -> NfToVecEA, NegationClosure -> NfCharFormula -> NfToVecEA, so VecEADecomp is strictly below NegationClosure.

### Q6: What VecEADecomp Provides

Key theorems (all sorry-free):

1. **`nf_3var_exist_depth0_characterization`** (line 837): The 3-var depth-0 existential decomposes by order consistency. If any pair has contradictory orders -> False. Otherwise -> tautology (the existential equals itself). This is NOT directly useful -- it just removes inconsistent ssns.

2. **`nf_3var_bracket_tyx_correct`** (line 120): For the bracket zone t < y < x, VecEA2.holds(t,x) iff exists y between t and x with the right NF. This converts the 3-var existential in this zone to a VecEA2 formula.

3. **`nf_3var_bracket_xyt_correct`** (line 244): Symmetric for x < y < t.

4. **Zone correctness theorems** (lines 528, 592, 656, 717): For non-bracket zones (y < t < x, t < x < y, y < x < t, x < t < y), convert existentials to VecEA2.holds with endpoint predicates incorporating Since/Until witness predicates.

5. **Equality cases** (lines 771, 798): When y=t or y=x, the existential reduces to direct NF evaluation.

**For the wiring**: VecEADecomp handles depth-0 3-var existentials only. At depth k+1, the 3-var NFs have quantifier structure (sub_nf.2 : NormalForm sig k 3 -> Bool maps to existence of 4th-variable witnesses). VecEADecomp cannot directly handle this higher-depth case.

## Recommended Wiring Approach

### Strategy C: Classical Composition via `intra_structure_extend`

The most promising approach avoids both `nf_exist_formula` backward and `nf_exist_formula_nested` backward. Instead:

**Core idea**: Prove `nf_2var_exist_formula_prior` at depth k+1 by showing that the 2-var existential is temporally definable, using only:
- P1(k): depth-k 1-var NFs have temporal characterizations (IH)
- P2(k): depth-k 2-var existentials have temporal formulas (IH)
- `intra_structure_extend`: the NF-level composition theorem
- `doets_lemma_1_1`: formula preservation under NF agreement

**Proof sketch** (for the backward direction):

Given t in M with parent_atoms matching, and the formula truth at t, we need `exists x, nf_eval_nf M (k+1) 2 (x,t) sub_nf`.

Step 1: The formula places x via Until/Since with `char_kp1(nf_x)` holding, giving `nf_eval_nf M (k+1) 1 (fun _ => x) nf_x` via `char_kp1_correct`.

Step 2: Atom part of sub_nf follows from nf_x atom compatibility + h_atoms + order direction.

Step 3: Quantifier part -- need for each ssn: `(exists y, nf_eval_nf M k 3 (y,x,t) ssn) <-> sub_nf.2 ssn = true`.

Step 3a (positive, interval zones): The formula (if using `nf_exist_formula_nested`) provides Since/Until witnesses for interval ssns. For these, the existential is directly satisfied.

Step 3b (positive, non-interval zones): Need `exists y` with specific NF. Since nf_x has depth-(k+1) 1-var NF, its quantifier part `nf_x.2(chi)` records `exists z, nf_eval_nf M k 2 (z,x) chi`. The non-interval 3-var existential can be related to a 2-var existential via projection.

However, the projection drops variable 2 (t), losing the y-t interaction. At depth 0, the y-t order is determined by the zone. At depth k >= 1, the y-t quantifier conditions (involving 4th variables) are NOT determined by the y-x projection alone.

**This is where `intra_structure_extend` helps**: If we could establish that (x,t) has a specific depth-(k+1) 2-var NF (which IS sub_nf), then `intra_structure_extend` gives us witness transfer for the 3-var existentials. But establishing that (x,t) has NF sub_nf IS the goal -- circular.

### Strategy D: Reformulate `nf_exist_formula_nested` to encode ALL ssns

Instead of filtering non-interval ssns via `nf_full_compat_right` (which only checks atoms), encode ALL quantifier conditions directly in the formula:

For each ssn with sub_nf.2(ssn) = true:
- Interval zone (y between t and x): Already encoded via nested Since/Until
- Zone 1 (y > x): Encode as `Until(char_k(nf_y'), top)` at x, where nf_y' ranges over depth-k 1-var NFs compatible with ssn at var 0
- Zone 5 (y < t): Encode as `Since(char_k(nf_y'), top)` at t -- but we evaluate at t, not x!

**Problem**: Encoding zone 5 (y < t) requires evaluating a Since formula at t, but the outer formula is evaluated at t and places x via Until. We cannot "go back to t" from within the Until event. This is a fundamental limitation of the temporal logic formalism.

### Strategy E: Use P2(k) recursively for non-interval zones

The `nf_exist_formula_nested_backward` in NegationClosure.lean has `p2_k` as a hypothesis. At depth k+1, the 3-var quantifier conditions `exists y, nf_eval_nf M k 3 (y,x,t) ssn` are depth-k existentials. By `nf_drop_last`, these can be related to depth-k 2-var existentials.

Specifically, for a non-interval ssn in zone 1 (y > x > t):
- `exists y, nf_eval_nf M k 3 (y,x,t) ssn` involves a depth-k 3-var NF
- At depth k, this is equivalent to: atoms at (y,x,t) match + for each ssn' : NormalForm sig (k-1) 4, `(exists w, nf_eval_nf M (k-1) 4 (w,y,x,t) ssn') <-> ssn.2 ssn' = true`

This is an arity-climbing induction. Each level increases arity but decreases depth. It terminates because depth strictly decreases.

The arity-climbing induction can be encoded using `intra_structure_extend` at each level:
1. At depth k+1, arity 2: prove via P2(k+1) -- this is what we're trying to show
2. To prove P2(k+1), need depth-k arity-3 existentials -- these are P2(k) applied with arity 3
3. But P2(k) only gives arity 2!

**This is the fundamental structural mismatch**: P2(k) characterizes arity-2 existentials, but the quantifier conditions at depth k+1 involve arity-3 existentials at depth k.

### Recommended Path: Generalize P2 to Arbitrary Arity

The correct approach (matching Rabinovich 2014 Section 5) is to generalize P2 to:

```
P2_gen(k, n) : forall (parent_atoms : ...) (sub_nf : NormalForm sig k (n+1)),
  exists A, forall M h_UZ h_SZ (env : Fin n -> M.carrier),
    (env atoms match parent) ->
    (temporal_truth M atomMap (env 0) A <->
     exists x, nf_eval_nf M k (n+1) (Fin.cons x env) sub_nf)
```

Then:
- P2_gen(0, n) is provable for all n (depth-0 NFs are purely atomic)
- P2_gen(k+1, 1) uses P2_gen(k, 2) for the 3-var quantifier conditions
- P2_gen(k+1, n) uses P2_gen(k, n+1) for the (n+2)-var quantifier conditions
- The induction is on k with n as a parameter
- Terminates because depth k strictly decreases

This requires:
1. Generalizing `nf_exist_formula` and its forward direction to arbitrary arity
2. Proving the backward direction at arbitrary arity
3. Using `intra_structure_extend` at the arity-generalized level

**This is a significant refactoring** but is the mathematically correct approach. It is what `RabinovichGeneralized.lean` attempts (see `existPart_succ` at line 382+), but with a sorry at the n>=2 case.

### Simplest Path Forward: Direct Composition at the Formula Level

A simpler alternative that avoids arity generalization:

1. **Observe**: The 2-var NF of (x,t) at depth k+1 is uniquely determined by the depth-(k+1) NF agreement class. By `doets_lemma_1_1`, any monadic formula of depth <= k+1 has its truth at (x,t) determined by this NF.

2. **The existential `exists x, nf_eval_nf M (k+1) 2 (x,t) sub_nf`** is a sentence (after fixing t and quantifying over x). It is equivalent to `eval M (fun _ => t) (.ex (nf_to_formula sub_nf))`, which is a depth-(k+1) monadic formula in 1 free variable.

3. **By the IH (P1(k+1))**: Every depth-(k+1) 1-variable monadic formula has a temporal formula. But P1(k+1) is what we're building FROM P2(k+1) -- so this is circular too.

4. **Break the cycle**: P1(k+1) depends on P2(k), not P2(k+1). So if we can express the 2-var existential as a depth-k 1-var property plus temporal operators, we avoid needing P2(k+1).

This is exactly what the existing approach does -- and the gap is precisely at the non-interval zones.

## Summary of Sorry Chain

```
kamp_prior_expressive_completeness (KampPrior.lean, sorry-free wrapper)
  |
  v
nf_characterizable_temporal_prior (KampPrior.lean:127, sorry-free)
  |
  v
nf_characterizable_temporal_prior_classical (NfCharFormula.lean:666, sorry-free)
  |
  v
nf_2var_exist_formula_prior (NfCharFormula.lean:610, SORRY at k+1)
  |
  v (at k+1 case, line 657)
nf_exist_backward_prior (NfCharFormula.lean:501, SORRY at line 540)
```

Alternative path:
```
nf_2var_exist_formula_prior_fill (NegationClosure.lean:1820)
  |
  v
master_induction (NegationClosure.lean:1740, sorry at k>=1)
  |
  v (P2(k+1) case, line 1810)
nf_exist_formula_nested_backward (NegationClosure.lean:1664, SORRY at line 1716)
```

Both paths hit the same mathematical wall: establishing 3-var quantifier conditions from 1-var NF knowledge.

## Adversarial Self-Verification

### Challenged Claims

1. **Claim**: "VecEADecomp can directly fill the sorry at NfCharFormula.lean:540"
   **Verdict**: REFUTED. VecEADecomp handles depth-0 3-var existentials only. The sorry is at depth k+1 (arbitrary k). At k=0, the depth-0 case is already sorry-free (line 634 uses `nf_2var_exist_depth0_tl`). VecEADecomp is not directly applicable at depth k+1.

2. **Claim**: "The bypass approach (providing a different formula A) can avoid the mathematical difficulty"
   **Verdict**: PARTIALLY REFUTED. The existential `exists A` allows choosing any formula, but any correct formula must encode the quantifier profile. The mathematical difficulty (composition for non-interval zones) remains regardless of which formula is chosen.

3. **Claim**: "Import cycle prevents wiring"
   **Verdict**: REFUTED. VecEADecomp does not transitively depend on NfCharFormula. Either file can import VecEADecomp without cycles.

4. **Claim**: "`intra_structure_extend` solves the composition"
   **Verdict**: PARTIALLY VERIFIED. `intra_structure_extend` provides the NF-level composition, but requires depth-(k+1) n-var agreement as input. The gap is establishing this agreement from the formula truth (which only gives 1-var NF knowledge).

### Uncertain Claims (with confidence)

- The arity-generalization approach (P2_gen(k,n)) would work: 70% confidence. It matches Rabinovich's paper structure but the Lean formalization may encounter technical difficulties with dependent types at variable arity.
- The `zone1_quant_check` design flaw is fixable: 85% confidence. The fix (add ssn_yt_order guards) is well-understood but the `nf_full_compat_right_v2` is not on the critical path anyway.

### Recommendations Modified After Verification

- Removed recommendation to "directly wire VecEADecomp into the sorry" -- this is not possible at depth k+1.
- Changed recommendation from "bypass nf_exist_formula" to "understand that the bypass approach (nf_exist_formula_nested) hits the same wall."
- Added recommendation: the composition lemma needed is `intra_structure_extend` applied at the right level, but requires establishing 2-var NF agreement from 1-var NF knowledge + order + atoms, which is the content of `backward_2var_nf_agreement` GIVEN the quantifier hypothesis.

## Conclusion

The sorry at NfCharFormula.lean:540 requires proving that for non-interval zones (y outside [t,x]), the 3-var quantifier conditions `exists y, nf_eval_nf M k 3 (y,x,t) ssn` are determined by:
- x's depth-(k+1) 1-var NF (from the formula's char_kp1)
- t's predicates (from parent_atoms)
- The x-t order (from the formula's Until/Since)
- Prior-UZ/SZ axioms

This is a composition theorem for Prior linear orders. At depth 0, it holds because 3-var NFs are purely atomic. At depth k+1, it requires either:
- (A) Arity-generalized induction (P2_gen(k,n) for all n)
- (B) A formula construction that encodes ALL zone conditions (not just interval zones)
- (C) A direct classical existence proof using the finite-model property of NFs on Prior structures
