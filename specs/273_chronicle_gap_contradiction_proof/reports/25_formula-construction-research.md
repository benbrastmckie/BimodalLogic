# Research Report: Formula Construction for nf_2var_exist_formula_prior

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Session**: sess_1781325641_3569a1
- **Date**: 2026-06-12
- **Agent**: lean-research-hard-agent
- **Status**: researched
- **Tier**: Tier 2 (documentation-backed, lean4 strict)

## Summary

The ONLY remaining sorry on the critical path is `nf_2var_exist_formula_prior` at
NfCharFormula.lean:572. This sorry has an EQUIVALENT sorry at NegationClosure.lean:1379
(`nf_exist_formula_nested_backward`). The two are not independent -- the NegationClosure
sorry is the ROOT, and NfCharFormula sorry closes when the NegationClosure sorry is filled
(via `nf_2var_exist_formula_prior_fill` which extracts P2 from `master_induction`).

The `generalized_composition` theorem (the Feferman-Vaught composition lemma for NormalForms)
was proved FALSE with a clean counterexample and has been removed. This means the backward
proof strategy that depends on composing 3-var NFs from 2-var projections is a dead end.

## Findings

### Finding 1: The Sorry Chain Structure

There are TWO sorry sites, but they are CAUSALLY linked:

| File | Line | Name | Role |
|------|------|------|------|
| NfCharFormula.lean | 572 | `nf_2var_exist_formula_prior` | Used by `nf_characterizable_temporal_prior_classical` |
| NegationClosure.lean | 1379 | `nf_exist_formula_nested_backward` | Used in `master_induction` P2(k+1) |

**Dependency**: `nf_2var_exist_formula_prior_fill` (NegationClosure.lean:1483-1498) extracts
P2 from `master_induction`. If `nf_exist_formula_nested_backward` is proved, `master_induction`
becomes sorry-free, `nf_2var_exist_formula_prior_fill` provides the same result as
`nf_2var_exist_formula_prior`, and the NfCharFormula sorry can be replaced with
`nf_2var_exist_formula_prior_fill`.

However: the NfCharFormula sorry takes `char_k` and `char_k_correct` as explicit parameters,
while `nf_2var_exist_formula_prior_fill` derives these internally from `master_induction`.
To fill the NfCharFormula sorry directly, one must either:
(a) Replace the `sorry` at NfCharFormula.lean:572 with a proof that constructs the formula
    and proves correctness using the given `char_k`/`char_k_correct`, or
(b) Modify `nf_characterizable_temporal_prior_classical` to use `nf_2var_exist_formula_prior_fill`
    directly instead of calling `nf_2var_exist_formula_prior`.

Option (b) is structurally cleaner: bypass NfCharFormula.lean:572 entirely by rewriting
`nf_characterizable_temporal_prior_classical` to call `nf_2var_exist_formula_prior_fill`.
This eliminates the sorry without proving it -- the proof obligation shifts to
`nf_exist_formula_nested_backward`.

### Finding 2: How the Base Case Works (k=0)

The base case is FULLY PROVED and sorry-free in `master_induction` (NegationClosure.lean:1408-1422).

**P2(0)**: The existence formula `nf_exist_formula` at depth 0 is correct in BOTH directions:
- **Forward** (`nf_exist_formula_forward'`): universal (works on all structures)
- **Backward** (`backward_depth0`): proved in NegationClosure.lean:79-197

The depth-0 backward direction works because at depth 0, the 2-var NF is purely atomic:
predicates + order. No quantifier conditions. The formula's Until/Since provides x with
the right order, and the characteristic depth-0 1-var NF formula ensures x has the right
predicates. The 2-var NF at (x,t) is then fully determined by atoms only.

**Key mechanism**: `nf_2var_depth0_components` (NegationClosure.lean:52-76) constructs the
depth-0 2-var NF evaluation from component data (pred matching at x, pred matching at t,
order matching). This is straightforward because `nf_eval_nf M 0 2 env nf` is just
`forall a, atom_eval M env a <-> nf a = true`.

### Finding 3: What P1(k) and P2(k) Are in master_induction

`P1(k)` (NegationClosure.lean:1383-1389): For every depth-k arity-1 NF, there EXISTS a
temporal Formula characterizing it on all Prior structures.
```
P1 atomMap k := forall nf : NormalForm sig k 1, exists A : Formula,
  forall M h_UZ h_SZ t, temporal_truth M atomMap t A <-> nf_eval_nf M k 1 (fun _ => t) nf
```

`P2(k)` (NegationClosure.lean:1391-1400): For every depth-k arity-2 sub-NF with fixed
parent atom assignment, there EXISTS a temporal Formula characterizing the existential
"exists x such that (x,t) has the right 2-var NF" on all Prior structures.
```
P2 atomMap k := forall parent_atoms sub_nf, exists A : Formula,
  forall M h_UZ h_SZ t,
    (forall a, atom_eval M (fun _ => t) a <-> parent_atoms a = true) ->
    (temporal_truth M atomMap t A <->
     exists x, nf_eval_nf M k (1+1) (Fin.cons x (fun _ => t)) sub_nf)
```

**The induction structure**:
- P1(0): `nf_depth0_char_formula` (sorry-free)
- P2(0): `nf_exist_formula` with `backward_depth0` (sorry-free)
- P1(k+1): from P1(k) + P2(k) via `nf_char_kp1_from_2var` (sorry-free once P1(k),P2(k) are)
- P2(k+1): uses `nf_exist_formula_nested` with SORRY at `nf_exist_formula_nested_backward`

So the sorry is ONLY in P2(k+1). P1(k+1) from P2(k) is sorry-free.

### Finding 4: The Backward Direction Blocker

The sorry at NegationClosure.lean:1379 (`nf_exist_formula_nested_backward`) needs to prove:

Given the formula `nf_exist_formula_nested k char_kp1 parent_atoms sub_nf` is true at t,
show there exists x such that `nf_eval_nf M (k+1) (1+1) (Fin.cons x (fun _ => t)) sub_nf`.

**What the formula provides** (for the Until case, t < x):
1. An x with t < x such that `char_kp1 nf_x` holds at x AND for each positive interval
   ssn, `Since(disj(char_kp1 nf_y), top)` holds at x
2. From `char_kp1_correct`: `nf_eval_nf M (k+1) 1 (fun _ => x) nf_x`
3. Atom compatibility between nf_x and sub_nf at variable 0
4. Full compatibility (`nf_full_compat_right`) which filters out atom-incompatible
   non-interval ssn's

**What must be shown** (via `backward_2var_nf_agreement`):
For each `ssn : NormalForm sig k 3`:
```
(exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn)
  <-> sub_nf.2 ssn = true
```

**The gap** (identified in phase-5-handoff-20260611e.md and phase-5-handoff-20260612-composition.md):

At depth k >= 1, `nf_eval_nf M k 3 (y,x,t) ssn` requires both atom agreement AND quantifier
agreement. The quantifier part involves depth-(k-1) arity-4 NFs at (z,y,x,t). Bridging from
the available 2-var NF information to 3-var (and then 4-var) NF evaluation requires the
**Feferman-Vaught composition lemma**: the depth-k n-var NF is determined by all pairwise
depth-k 2-var NFs.

**generalized_composition IS FALSE** (counterexample in NfComposition.lean docstring):
M = (Z, <), env1 = (0, 2), env2 = (0, 1), k = 1. All integers have the same depth-k
1-var NF, and 0 < 2 iff 0 < 1, but the depth-1 2-var NFs differ (the zone "strictly
between" is nonempty for (0,2) but empty for (0,1)).

This means the composition approach to the backward direction is MATHEMATICALLY BLOCKED
in its previous formulation.

### Finding 5: Alternative Approaches

Three potential paths remain:

#### Path A: Budget-Parameter Composition (Plan v25)

Plan v25 proposed: instead of "matching 1-var NFs implies matching n-var NFs" (FALSE),
use **strong induction on b = k + n** where b is a "budget" parameter. The key insight:
`intra_structure_extend` (NfComposition.lean:228-245) is already proved sorry-free and
provides exactly the witness transfer needed for the quantifier step:

```lean
theorem intra_structure_extend (M : ...) (K n : Nat)
    (env1 env2 : Fin n -> M.carrier)
    (h : forall nf, nf_eval_nf M (K+1) n env1 nf <-> nf_eval_nf M (K+1) n env2 nf)
    (z : M.carrier) :
    exists z', forall nf, nf_eval_nf M K (n+1) (Fin.cons z env1) nf <->
                           nf_eval_nf M K (n+1) (Fin.cons z' env2) nf
```

This says: if two n-var environments are depth-(K+1) NF-equivalent, then for any z
there exists z' preserving depth-K (n+1)-var NF equivalence.

The composition would be stated as:
```
theorem generalized_composition_budget (M : ...) (b : Nat) :
    forall k n, k + n <= b + 1 -> forall env1 env2 : Fin n -> M.carrier,
    (forall i j, nf_characteristic M (k+1) 2 (...) = nf_characteristic M (k+1) 2 (...)) ->
    nf_characteristic M k n env1 = nf_characteristic M k n env2
```

**Problem**: The counterexample also refutes this! M = (Z, <), env1 = (0,2), env2 = (0,1),
k = 1, n = 2. All pairwise depth-2 2-var NFs match (every pair of integers has the same
depth-2 2-var NF by Z's translation invariance), but the depth-1 2-var NFs differ.

The correct statement needs depth-(k+1) pairwise agreement, not depth-k:
```
(forall i j, nf_characteristic M (k+1) 2 (...) = ...) ->
nf_characteristic M k n env1 = nf_characteristic M k n env2
```

This IS proved by `intra_structure_extend` (one step at a time): given depth-(k+1) n-var
NF agreement, we get depth-k (n+1)-var NF agreement. But the backward proof needs the
REVERSE: from depth-(k+1) 1-var NFs (via char_kp1) and the formula, reconstruct
depth-k 3-var NFs. The formula provides char_kp1 for the 1-var NFs of x and interval
witnesses y. Each 1-var NF at depth k+1 records which depth-k 2-var NFs are realized.
So in principle:

- depth-(k+1) 1-var NF of x = nf_x encodes: for all ssn_2 : NormalForm sig k 2,
  exists z with nf_eval_nf M k 2 (z, x) ssn_2 iff nf_x.2 ssn_2 = true
- depth-(k+1) 1-var NF of y = nf_y encodes: for all ssn_2 : NormalForm sig k 2,
  exists z with nf_eval_nf M k 2 (z, y) ssn_2 iff nf_y.2 ssn_2 = true

We need: nf_eval_nf M k 3 (y, x, t) ssn. This requires atoms + quantifier transfer.
The quantifier part at depth k requires: for all sub4, exists z with
nf_eval_nf M (k-1) 4 (z, y, x, t) sub4.

**The key observation**: the actual x from the formula lives in the SAME model M as
the original sub_nf evaluation. We do not need an abstract composition theorem. We
need only show that the SPECIFIC x extracted from the formula has the right 2-var NF
at (x, t) equal to sub_nf.

#### Path B: Direct Proof via Prior Structure Properties

On Prior structures, `semantic_prior_UZ` and `semantic_prior_SZ` provide first/last
occurrence properties. The backward direction could potentially be proved by:

1. The formula truth gives x with `nf_eval_nf M (k+1) 1 (fun _ => x) nf_x`
2. For non-interval ssn's: `nf_full_compat_right` filters ensure consistency
3. For interval ssn's: the formula provides y with `nf_eval_nf M (k+1) 1 (fun _ => y) nf_y`
4. Need: `nf_eval_nf M k 3 (y, x, t) ssn`

Step 4 requires showing the depth-k 3-var NF at (y, x, t) equals ssn. At depth 0,
this is just atoms (proved). At depth k+1, this requires quantifier transfer.

The **critical missing step**: given that nf_x (depth k+1, arity 1) records all
depth-k 2-var NFs at (z, x), and we know nf_y (depth k+1, arity 1), and we know
the order y < x and t < y < x, can we recover the depth-k 3-var NF at (y, x, t)?

This reduces to: given depth-(k+1) 1-var NFs of y, x, t and the order relation,
determine the depth-k 3-var NF. This is exactly the `generalized_composition`
theorem... which is FALSE.

**However**: we are not in the GENERAL case. We are in a SINGLE model M with
SPECIFIC points y, x, t. The 3-var NF at (y, x, t) is DETERMINED by the model.
The question is whether the formula provides enough information to IDENTIFY which
3-var NF it is.

The formula provides `sub_nf.2 ssn = true` (for positive ssn's with
`ssn_in_interval_right`). The backward proof needs to show that `sub_nf.2 ssn`
equals the ACTUAL quantifier assignment of the characteristic NF at (x, t).

#### Path C: Bypass the Backward Direction Entirely

**Key insight**: `nf_2var_exist_formula_prior` asks for the EXISTENCE of a formula A,
not the construction of a specific formula. The approach in `nf_characterizable_temporal_prior_classical`
(NfCharFormula.lean:577-692) uses Classical.choose on the existence. So we need:

```
exists A, forall M h_UZ h_SZ t,
  (forall a, atom_eval M (fun _ => t) a <-> parent_atoms a = true) ->
  (temporal_truth M atomMap t A <->
   exists x, nf_eval_nf M k (1+1) (Fin.cons x (fun _ => t)) sub_nf)
```

This is a classical existence statement. It says: there EXISTS SOME temporal formula
that is semantically equivalent to the monadic FO sentence `exists x, nf_eval_nf ...`.

One approach: use the VecEA/Rabinovich Prop 3.5 translation, which converts any
exists-forall formula to a TL(U,S) formula. The sentence
`exists x, nf_eval_nf M k (1+1) (Fin.cons x (fun _ => t)) sub_nf` IS a monadic FO
sentence (it is `eval M (fun _ => t) (MonadicFormula.ex (nf_to_formula sub_nf))`).

If we can show that this monadic FO sentence has an equivalent TL(U,S) formula
on Prior structures, we are done. This is EXACTLY what
`kamp_prior_expressive_completeness` proves... but that theorem DEPENDS on the sorry
we are trying to fill (circular).

However, there may be a way to prove the special case directly. The monadic FO
sentence `exists x, phi(x, t)` where phi is quantifier-free at depth 0, or has
bounded quantifier depth at depth k, might be expressible via a simpler argument.

#### Path D: Replace nf_2var_exist_formula_prior with nf_2var_exist_formula_prior_fill

The simplest resolution: if we can prove `nf_exist_formula_nested_backward` for
the SPECIFIC formula `nf_exist_formula_nested`, we get P2(k+1) from `master_induction`,
which gives `nf_2var_exist_formula_prior_fill`.

Then modify `nf_characterizable_temporal_prior_classical` to NOT call
`nf_2var_exist_formula_prior` (the sorry'd theorem) but instead call
`nf_2var_exist_formula_prior_fill` (which is sorry-free once `nf_exist_formula_nested_backward`
is filled).

**But this is circular**: the backward direction IS the sorry.

### Finding 6: The Root Mathematical Difficulty

The composition lemma `generalized_composition` is FALSE in its naive form:
"same depth-(k+1) 1-var NFs + matching orders implies same depth-k n-var NFs."

The CORRECT statement requires depth-(k+1) PAIRWISE 2-var NF agreement (not just
1-var NFs). But the formula only provides 1-var NF information for each point.

The missing piece: from the depth-(k+1) 1-var NFs of y, x, and t, plus the fact
that they are in a specific order (y < x, t < y), can we determine the depth-k
2-var NFs of (y, x), (y, t), and (x, t)?

For (x, t): this IS sub_nf (that's what we're trying to prove, so using it is circular).

For (y, x) and (y, t): these are NOT determined by the 1-var NFs alone (that's the
counterexample). However, on Prior structures, the `semantic_prior_UZ/SZ` axioms
ensure first/last occurrence properties. The question is whether these properties
somehow constrain the 2-var NFs enough.

**Conclusion**: The mathematical approach needs to either:
1. Work at the formula level (Rabinovich Prop 3.5 + 4.2 negation closure) rather
   than the NF composition level, or
2. Use a direct induction argument that avoids the composition lemma entirely, or
3. Find the correct composition statement that IS true on Prior structures
   (e.g., depth-(k+1) 1-var NFs + order + Prior axioms determine depth-k 3-var NFs)

### Finding 7: Reusable Codebase Infrastructure

The following sorry-free lemmas are available:

| Lemma | File | What it does |
|-------|------|-------------|
| `backward_depth0` | NegationClosure.lean:79 | Backward direction at depth 0 (sorry-free) |
| `nf_2var_depth0_components` | NegationClosure.lean:52 | Build depth-0 2-var NF from components |
| `nf_exist_formula_forward'` | NfCharFormula.lean:349 | Forward direction (universal) |
| `nf_exist_formula_nested_forward` | NegationClosure.lean:990 | Forward direction of nested formula |
| `backward_2var_nf_agreement` | NegationClosure.lean:1248 | Build 2-var NF from atom + quant data |
| `nf_full_compat_right_of_eval` | NegationClosure.lean:819 | Compat filter passes for real witnesses |
| `ssn_compat_of_witness` | NegationClosure.lean:739 | Witness y implies all compat checks pass |
| `intra_structure_extend` | NfComposition.lean:228 | Witness transfer across NF-equivalent envs |
| `nf_drop_last` | NfComposition.lean:100 | Projection preserves NF agreement |
| `nf_1var_from_2var_agree` | NfComposition.lean:199 | 2-var agreement implies 1-var agreement |
| `neg_until_equiv_prior` | SeparationBridge.lean:132 | GHR94 Lemma 10.2.2 (negation of Until) |
| `neg_since_equiv_prior` | SeparationBridge.lean:153 | GHR94 Lemma 10.2.2 (negation of Since) |
| `nf_char_kp1_from_2var` | NegationClosure.lean:204 | P1(k+1) from P1(k) + P2(k) |
| `master_induction` | NegationClosure.lean:1403 | Simultaneous induction framework |
| `nf_composition_depth0` | NegationClosure.lean:1226 | Depth-0 3-var NF from witness atoms |

### Finding 8: Estimated Effort and Recommended Strategy

The backward direction at depth k+1 is a HARD mathematical problem. The naive composition
approach has been disproved. Three strategies remain viable:

**Strategy 1 (Recommended): Direct intra-structure argument (200-400 lines)**

Instead of an abstract composition theorem, prove the backward direction DIRECTLY for the
specific model and points involved:

1. The formula gives x such that `nf_eval_nf M (k+1) 1 (fun _ => x) nf_x` (from char_kp1)
2. The formula gives, for each positive interval ssn, y such that `nf_eval_nf M (k+1) 1 (fun _ => y) nf_y`
3. Use `intra_structure_extend` to build depth-k 3-var NF: given that the characteristic
   NF at depth-(k+1) 1-var agrees between the formula's x and some reference x_0 (where
   sub_nf is the characteristic 2-var NF at (x_0, t_0)), the witness transfer gives us
   a z' matching any z in the depth-k (n+1)-var NF.

The key new lemma needed: if x has depth-(k+1) 1-var NF nf_x and t has the right
predicates (parent_atoms), and sub_nf is a depth-(k+1) 2-var NF that is atom-compatible
with nf_x and parent_atoms, and the quantifier conditions from sub_nf.2 are satisfied
(which is what backward_2var_nf_agreement's h_quant parameter asks for), then
`nf_eval_nf M (k+1) 2 (x, t) sub_nf`.

The h_quant condition needs: for each ssn, `(exists y, nf_eval_nf M k 3 (y,x,t) ssn) <-> sub_nf.2 ssn = true`.

For the forward direction of h_quant (exists y -> sub_nf.2 ssn = true): this requires
showing that if some y realizes ssn at (y,x,t), then sub_nf.2 ssn = true. But sub_nf is
just a parameter -- we cannot prove this without knowing that sub_nf IS the characteristic
2-var NF at (x,t). This is circular.

**The fundamental circularity**: we need to prove that the characteristic 2-var NF at (x,t)
equals sub_nf, but backward_2var_nf_agreement requires h_quant as a hypothesis, and
h_quant requires knowing the 2-var NF equals sub_nf.

**Strategy 2: Change the proof architecture (400-600 lines)**

Instead of using `nf_exist_formula_nested` + backward_2var_nf_agreement, prove
`nf_2var_exist_formula_prior` directly by a different method:

- Use the master_induction structure but with a DIFFERENT formula for P2(k+1)
- Instead of building a specific formula and proving it correct in both directions,
  use a classical existence argument: the monadic FO sentence
  `exists x, nf_eval_nf M k 2 ...` is temporally definable on Prior structures
  by a general argument (e.g., the Gabbay separation theorem for discrete time)
- This avoids the need for a constructive formula and backward proof entirely

**Strategy 3: Formula-level approach via Rabinovich Prop 3.5 (600-1000 lines)**

Implement the full Rabinovich Section 5 proof at the formula level:
- Convert `exists x, nf_eval_nf M k 2 (x, t) sub_nf` to an exists-forall formula
  (it already IS one: the NF evaluation expands to quantifier-free atoms + bounded
   quantifiers)
- Use Prop 3.5 to convert the exists-forall formula to TL(U,S)
- Show the resulting TL formula is equivalent to the original monadic FO sentence

This is the most principled approach but requires the most new code.

## Adversarial Self-Verification

### Challenged Claims

1. **Claim**: "nf_2var_exist_formula_prior and nf_exist_formula_nested_backward are causally linked."
   **Verification**: CONFIRMED. `nf_2var_exist_formula_prior_fill` (NegationClosure.lean:1483-1498)
   directly calls `(master_induction atomMap h_surj k).2`, and master_induction's P2(k+1) uses
   `nf_exist_formula_nested_backward`. The dependency chain is:
   nf_exist_formula_nested_backward -> P2(k+1) in master_induction -> nf_2var_exist_formula_prior_fill.

2. **Claim**: "generalized_composition is FALSE."
   **Verification**: CONFIRMED. The counterexample is documented in NfComposition.lean:20-36 and
   committed. The false theorem was removed, NfComposition.lean has zero sorries.

3. **Claim**: "Strategy 1 (direct intra-structure argument) is viable."
   **Verification**: CHALLENGED. The fundamental circularity identified in Strategy 1's analysis
   makes it unclear whether backward_2var_nf_agreement can be used. The h_quant condition
   requires knowing sub_nf = characteristic 2-var NF of (x,t), which is what we are trying
   to prove. This circularity needs to be broken somehow.

4. **Claim**: "Path C (bypass backward entirely) is circular."
   **Verification**: CONFIRMED for the approach using kamp_prior_expressive_completeness.
   However, the existence could potentially be proved by a DIRECT argument (e.g., induction
   on quantifier depth of the monadic FO formula) without going through the full
   kamp_prior_expressive_completeness.

### Uncertain Claims (confidence levels)

- Strategy 2 is viable (confidence: 70%). Requires implementing enough of the Gabbay
  separation theorem to handle the specific case of monadic FO existentials.
- Strategy 3 is viable (confidence: 85%). The Rabinovich proof is published and the
  VecEA infrastructure exists. But it requires 600-1000 lines of new code.
- The correct composition theorem on Prior structures (depth-(k+1) 1-var NFs + Prior
  axioms -> depth-k 3-var NFs) might be TRUE even though the general version is FALSE
  (confidence: 40%). Prior structures have additional first/last occurrence properties
  that might constrain zone structures.

### Recommendations Modified After Verification

Originally recommended Strategy 1. After adversarial verification, the circularity in
h_quant makes Strategy 1 incomplete as stated. The recommendation shifts to:

**Primary recommendation**: Investigate whether `backward_2var_nf_agreement` can be
replaced with a direct proof that avoids the circular h_quant condition. Specifically:
instead of proving sub_nf.2 ssn = true for ALL ssn and THEN building the 2-var NF,
prove `nf_eval_nf M (k+1) 2 (x, t) sub_nf` directly by showing the characteristic
2-var NF at (x, t) equals sub_nf. This requires:
- Atom part: already available from filter conditions
- Quantifier part: for each ssn, show `(exists y, nf_eval_nf M k 3 (y,x,t) ssn)
  <-> sub_nf.2 ssn = true`. For the POSITIVE direction (sub_nf.2 ssn = true ->
  exists y), the formula provides interval witnesses. For the NEGATIVE direction
  (exists y -> sub_nf.2 ssn = true), this is where the composition is needed.

**The negative direction** (if some y in the model realizes ssn at (y,x,t), then
sub_nf.2 ssn must be true) is equivalent to asking: is sub_nf the CHARACTERISTIC
2-var NF at (x,t)? If x is the specific x from the formula, this is exactly
what we want to prove. So the negative direction is NOT independently provable --
it IS the theorem we are trying to prove.

**Revised recommendation**: Either:
(A) Find a formula construction where the backward direction avoids needing the
    negative h_quant direction (i.e., drop the <-> to just ->, proving only
    sub_nf.2 ssn = true -> exists y). This would prove
    `nf_eval_nf M (k+1) 2 (x,t) SUB_NF' where SUB_NF' is the ACTUAL characteristic
    NF at (x,t), not sub_nf. Then use nf_eval_unique to show SUB_NF' = the
    characteristic NF. But we need SUB_NF' = sub_nf specifically.
(B) Work at the formula level (Strategy 3 / Rabinovich Prop 3.5 + 4.2).
(C) Accept that the backward direction needs a substantially different proof
    architecture and research whether the "correct" composition theorem for
    Prior structures exists.

## Tactic Survey Results

Not applicable -- this is pure research, no proof tactics were tested.

## Literature Proof Structure

### Rabinovich 2014 Structure

The Rabinovich proof proceeds:
1. **Prop 3.5**: Every V-exists-forall formula with 1 free variable -> TL(U,S) formula
2. **Prop 4.2**: Negation of exists-forall formula with <= 2 free variables -> V-exists-forall (on Dedekind complete chains)
3. **Prop 4.3**: Every FO formula -> V-exists-forall (structural induction using Prop 4.2 for negation)
4. **Theorem 4.4**: Kamp's theorem (combine Prop 4.3 + Prop 3.5)

**The composition enters at Prop 4.2**: the negation closure argument (Section 5) uses the
interval decomposition where inserting a new point z into an interval requires determining
how z interacts with existing points. On Dedekind complete chains, the infimum exists
(INF formula, Lemma 5.3).

**On Prior structures**: the INF formula works because Prior-UZ/SZ provides first/last
occurrence. The composition step still requires determining how the new point z's NF
relates to existing points' NFs.

### GHR94 Chapter 10.2 Structure

The GHR94 approach works SYNTACTICALLY:
1. **Lemma 10.2.3**: 8 elimination cases for nested temporal connectives
2. **Lemma 10.2.8**: Junction depth induction (each case reduces junction depth)
3. **Theorem 10.2.9**: Separation for {U,S} over discrete time
4. **Theorem 10.2.10**: Expressive completeness from separation

This approach avoids composition entirely but is specific to discrete time (integers).
The bridge from Z to general Prior structures requires showing that separation
properties transfer, which was blocked in plan v24 phase 3.

## Recommendations

1. **Do not attempt the Feferman-Vaught composition lemma again.** It has been proved
   FALSE in its naive form and the budget-parameter variant faces the same counterexample.

2. **The most promising approach** is to investigate whether there exists a formula
   construction where the backward direction only requires the POSITIVE h_quant direction
   (sub_nf.2 ssn = true -> exists y). The current `nf_exist_formula_nested` already
   encodes positive ssn's. If the formula were strengthened to also encode the NEGATIVE
   ssn's (sub_nf.2 ssn = false -> forall y, not nf_eval_nf), then the backward proof
   would only need the positive direction.

3. **Alternative**: prove `nf_2var_exist_formula_prior` by a completely different method
   that avoids the constructive formula + backward proof pattern. For example:
   - Prove that the set of temporally definable properties is closed under existential
     quantification on Prior structures (this is what `nf_2var_exist_formula_prior` states)
   - Use the fact that Prior structures have the same first-order theory as (Z, <) for
     sentences in the temporal language (if this is true)

4. **Estimated effort**: 400-800 lines of new Lean code depending on approach.

## Memory Candidates

### Candidate 1: generalized_composition counterexample
**Category**: lean4-pattern
**Content**: The Feferman-Vaught composition lemma "same depth-(k+1) 1-var NFs + matching
orders implies same depth-k n-var NFs" is FALSE for n >= 2 on general linear orders.
Counterexample: M = (Z, <), env1 = (0, 2), env2 = (0, 1), k = 1. Zone structure
(empty vs nonempty between points) is not captured by individual 1-var NFs.
**Keywords**: composition, NormalForm, Feferman-Vaught, counterexample, zone structure

### Candidate 2: backward direction circularity
**Category**: lean4-pattern
**Content**: In the Kamp/Rabinovich backward proof for nf_exist_formula_nested, proving
h_quant (exists y with 3-var NF ssn <-> sub_nf.2 ssn = true) is circular: the negative
direction (exists y -> sub_nf.2 ssn = true) requires knowing sub_nf IS the characteristic
2-var NF at (x,t), which is what the backward proof is trying to establish.
**Keywords**: backward direction, circularity, h_quant, 2-var NF, composition
