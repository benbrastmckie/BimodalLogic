# Report 36: Research on Closing nf_2var_existence_characterizable Sorry

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: Closing the sorry at `nf_2var_existence_characterizable` in StaviCompleteness.lean:1865

---

## 1. Exact Problem Statement

The single sorry at line 1865 of `StaviCompleteness.lean` is inside:

```lean
private theorem nf_2var_existence_characterizable
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (sf : StaviFormula),
      ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
          parent_atoms a = true) →
        (stavi_temporal_truth M atomMap t sf ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)
```

### What This Says

Given:
- An IH providing `char_k`: for each 1-var depth-k NF, a StaviFormula characterizing it
- A fixed parent atom assignment at t
- A fixed 2-var depth-k NF `sub_nf`

Produce a StaviFormula `sf` that correctly characterizes (for ALL structures M and ALL points t with the right atom assignment):

> "there exists x such that the 2-variable depth-k NF of (x, t) equals sub_nf"

### Why It's Hard

- For k=0: `sub_nf` is purely atomic (predicates at x, predicates at t, order between x and t). The formula is a simple Until/Since with the right predicates. This works with the existing `nf_exist_sf_depth0`.

- For k >= 1: `sub_nf = (atoms2, quant2)` where `quant2 : NormalForm sig (k-1) 3 -> Bool`. The formula must encode whether various 3-variable depth-(k-1) NFs are realizable by adding a third variable z to the pair (x, t). The IH only gives formulas for 1-var NFs at depth k, not 3-var NFs at depth k-1.

### The Gap

The existing `nf_exist_sf` formula uses `sf_top` as the guard in Until/Since:
```lean
.std_untl witness_type sf_top
```

This means: "there exists x above t such that x has some atom-compatible 1-var type, with no constraint on intermediate points." The FORWARD direction works (given a witness x, the formula holds). The BACKWARD direction fails: knowing that SOME atom-compatible 1-var type exists above t does not determine the 2-var NF of (x, t) when k >= 1.

---

## 2. Dependency Chain

```
stavi_expressive_completeness  (the main theorem)
  └── nf_characterizable_by_stavi  (NF → StaviFormula, by induction on k)
        ├── Base k=0: nf_base_sf  [DONE]
        └── Step k+1: nf_succ_sf + nf_2var_existence_characterizable
              ├── Forward direction: nf_exist_sf_forward  [DONE]
              └── Backward direction: SORRY at line 1865
```

The sorry blocks `nf_characterizable_by_stavi`, which blocks `stavi_expressive_completeness`. No other sorry exists in the EFGames directory.

---

## 3. Analysis of Previously Attempted Strategies

### Strategy 1: Backward of nf_exist_sf with sf_top guard
**Result**: Fails for k > 0.
**Why**: For k > 0, the 1-var type of x does not determine the 2-var type of (x,t). Multiple 2-var NFs share the same 1-var projection at variable 0.

### Strategy 2: "Good NF" disjunction
**Result**: Fails.
**Why**: The property "is this NF satisfiable?" has quantifier depth k+1, but char_k only gives depth-k formulas. Classical definability of the "good" predicate doesn't help because it requires depth-(k+1) formulas.

### Strategy 3: NF finiteness + definability
**Result**: Circular.
**Why**: Defining the formula requires `nf_characterizable_by_stavi` at depth k+1, which is what we're trying to prove.

### Strategy 4: Reduce to stavi_expressive_completeness
**Result**: Circular.
**Why**: `stavi_expressive_completeness` depends on `nf_characterizable_by_stavi` which depends on `nf_2var_existence_characterizable`.

### Strategy 5: Nested temporal formula
**Result**: Viable but estimated at 700-1000 lines.
**Why**: For each sub3 : NormalForm sig (k-1) 3, build a nested temporal formula encoding "exists z with 3-var type = sub3." This requires recursive construction over k and careful case analysis on the position of z relative to x and t.

---

## 4. New Analysis: Three Viable Approaches

### Approach A: Interval Guard Formula (Report 43's Recommendation)

**Idea**: Replace `sf_top` in `nf_exist_sf` with a formula constraining the types of intermediate points in (t, x).

**Construction**: For the Until case (t < x):
```
U(witness_type, guard_formula)
```
where `guard_formula` is a conjunction/disjunction over all 1-var depth-k NFs, encoding which types must (or must not) appear in the interval (t, x).

**Forward proof**: Given witness x with the right 2-var NF, the guard formula holds at all intermediate points because `nf_characteristic_satisfies` gives us their types, and the IH `char_k_correct` translates NF satisfaction to formula truth.

**Backward proof**: Given that the Until formula holds (witness x with right type AND guard constraining intermediate points), we must show the 2-var NF of (x,t) equals sub_nf.

**Critical issue**: The 2-var NF of (x,t) involves existentials over z that can be OUTSIDE the interval (t,x). Specifically, z can be:
- z > x (above the witness, unconstrained by the Until formula)
- z < t (below the reference point, unconstrained)
- z = x or z = t (at the boundary)

The interval guard only constrains points in (t,x), so points outside are free. This means the interval guard alone does NOT determine the 2-var NF unless we can show that the EXISTENCE of z with certain properties is fully determined by the 1-var type of x, the 1-var type of t, and the interval profile.

**Assessment**: The interval guard approach requires an auxiliary theorem proving that the interval profile + endpoint types determine the 2-var NF. This is the content of GHR93's game-theoretic argument (Proposition 7 + Lemma 11), which IS formalized in Composition.lean and Decomposition.lean, but operates on `ExtendedCarrier` and game-level types, not directly on `NormalForm`/`nf_eval_nf`. A bridge theorem is needed.

**Estimated effort**: ~200-400 lines (redefine formula ~30 lines, re-prove forward ~80 lines, bridge theorem ~100-200 lines, backward proof ~100 lines).

### Approach B: Full Profile Disjunction

**Idea**: Instead of using Until/Since with a guard, build a big disjunction over all possible "interval type profiles" and for each profile, directly encode whether the profile determines sub_nf.

**Construction**: An interval type profile between t and x is a subset of `Finset (NormalForm sig k 1)` -- the set of 1-var depth-k NFs that are realized by some point in the interval. Since `NormalForm sig k 1` is `Fintype`, there are finitely many possible profiles.

For each profile P (a subset of 1-var NFs) and each compatible 1-var NF nf_x for the witness:
1. Classically check: does this profile + nf_x + parent_atoms determine that the 2-var NF equals sub_nf? (This is a Decidable proposition over finite types.)
2. If yes, build: `U(char_k(nf_x) AND profile_check(P), profile_guard(P))` where `profile_guard(P)` constrains intermediate points to realize exactly the types in P, and `profile_check(P)` asserts the profile at x.

**Critical issue**: Same as Approach A -- we need the key theorem that the profile determines the 2-var NF. Additionally, building the profile guard (constraining which types are present/absent) is technically complex: presence requires U/S nested inside the guard.

**Assessment**: More complex than Approach A with the same fundamental dependency on the bridge theorem.

**Estimated effort**: ~500-700 lines.

### Approach C: Recursive Nested Temporal Formula (Strategy 5 refined)

**Idea**: Directly encode the 2-var NF condition as nested temporal formulas, recursing on k.

**Construction**: For `sub_nf : NormalForm sig k 2`:
- Atoms part: conjunction of atom literals for predicates at x + order between x and t (same as current).
- Quantifier part (k >= 1): for each `sub3 : NormalForm sig (k-1) 3` with `quant2 sub3 = true`, build a formula encoding "exists z such that the 3-var depth-(k-1) NF of (z, x, t) equals sub3." This formula must case-split on z's position relative to x and t (z < t, t < z < x, z > x, or z equals x or t).

For z in each position, the 3-var NF condition decomposes into:
- Atoms at z (predicates + order with x and t)
- If k-1 >= 1: quantifier part involving 4-var NFs, which requires further nesting

This gives a recursive construction: the formula for depth-k 2-var NFs involves formulas for depth-(k-1) 3-var NFs, which involve depth-(k-2) 4-var NFs, and so on until depth 0 (purely atomic).

**Forward proof**: By structural recursion, the witness at each level provides the formula truth.

**Backward proof**: By structural recursion, the formula truth provides the witness AND the correct NF evaluation. At each level, the formula explicitly encodes the NF condition, so the backward direction follows directly.

**Key advantage**: No bridge theorem needed. The formula directly encodes the NF condition, so both directions are provable by structural induction.

**Key disadvantage**: Very large formula. At depth k, the formula involves nesting through depths k, k-1, ..., 0 and variable counts 2, 3, ..., k+2. The total number of cases grows exponentially.

**Assessment**: This is the most self-contained approach but requires the most code.

**Estimated effort**: ~700-1000 lines.

---

## 5. Recommended Approach: Approach A with Bridge Theorem

### 5.1 Rationale

Approach A is the most economical if the bridge theorem can be proved. The existing game infrastructure (ghr93_strategy_compose, ghr93_game_iff_decomposition) already encodes the core content. The bridge theorem translates from game-level types to NF-level types.

### 5.2 Bridge Theorem Statement

```lean
theorem interval_profile_determines_2var_nf
    {sig : MonadicSignature} {k : Nat}
    {M : OrderedMonadicStructure sig}
    {x t : M.carrier}
    (nf_x : NormalForm sig k 1) (nf_t : NormalForm sig k 1)
    (h_x : nf_eval_nf M k 1 (fun _ => x) nf_x)
    (h_t : nf_eval_nf M k 1 (fun _ => t) nf_t)
    {N : OrderedMonadicStructure sig}
    {x' t' : N.carrier}
    (h_x' : nf_eval_nf N k 1 (fun _ => x') nf_x)
    (h_t' : nf_eval_nf N k 1 (fun _ => t') nf_t)
    -- Same ordering
    (h_ord : (x < t ↔ x' < t') ∧ (x = t ↔ x' = t'))
    -- Same interval profile: for each 1-var NF, presence in (t,x) ↔ presence in (t',x')
    (h_profile : ∀ nf_u : NormalForm sig k 1,
      (∃ u, t < u ∧ u < x ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) ↔
      (∃ u', t' < u' ∧ u' < x' ∧ nf_eval_nf N k 1 (fun _ => u') nf_u)) :
    nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
    nf_characteristic N k 2 (Fin.cons x' (fun _ => t'))
```

This says: if (M, x, t) and (N, x', t') agree on:
1. The 1-var depth-k NF of x (same nf_x)
2. The 1-var depth-k NF of t (same nf_t)
3. The ordering between x and t
4. Which 1-var depth-k NFs are present in the interval

Then the 2-var depth-k NF of (x,t) equals the 2-var depth-k NF of (x',t').

### 5.3 Can the Bridge Be Proved from Existing Infrastructure?

The existing infrastructure provides:
- `ghr93_game_iff_decomposition` (Decomposition.lean:302): game wins iff decomposition agreement
- `ghr93_strategy_compose` (Composition.lean:40): strategy composition
- `decomposition_agreement` (Decomposition.lean:62): captures matching types at all positions

These operate on `ExtendedCarrier` and `stavi_temporal_truth_mu`, not on `NormalForm` and `nf_eval_nf`. The translation requires:

1. Converting NF agreement to formula agreement (via `char_k_correct`)
2. Converting formula agreement to game wins (via n-equivalence definitions)
3. Applying game composition/decomposition
4. Converting back to NF equality (via `nf_eval_unique`)

This translation chain is feasible but non-trivial. The main obstacle is that the game infrastructure uses `ExtendedCarrier` (points + gaps) while the NF theory uses raw carrier points.

### 5.4 Alternative: Direct NF Proof of Bridge (No Game Infrastructure)

The bridge theorem can potentially be proved directly by induction on k without the game infrastructure:

**Base case (k=0)**: The 2-var depth-0 NF is just atoms at x, atoms at t, and order between x and t. These are directly determined by the 1-var types and ordering. No interval profile needed.

**Inductive step (k+1)**: The 2-var depth-(k+1) NF = (atoms2, quant2). Atoms are determined by the 1-var types. For quant2, need to show: for each sub3 : NormalForm sig k 3, the existence of z with nf_eval_nf M k 3 (cons z (cons x (fun _ => t))) sub3 is determined by the profile + endpoint types.

For a given z, the 3-var NF of (z, x, t) depends on:
- 1-var type of z at depth k (by IH, determines 2-var types of (z,x) and (z,t))
- Ordering of z relative to x and t
- The 2-var NF of (x,t) at depth k (by IH of the outer induction)

By the IH at depth k: knowing the 1-var types of z, x, t and their mutual orderings determines the 2-var types of all pairs, which determines the 3-var type of (z,x,t). But does it? The 3-var NF at depth k has a quantifier part asking about 4-var NFs, which by IH at depth k-1 are determined by 1-var types at depth k-1... but we have depth-k 1-var types, which include depth-(k-1) information.

Actually, this works by the FULL IH on k. At depth k, the bridge theorem says: 1-var depth-k types + orderings determine 2-var depth-k types. Applying this recursively: 1-var depth-k types of z, x, t + orderings determine all pairwise 2-var depth-k types, which determine the 3-var depth-k type.

Wait -- but the bridge theorem at depth k is what we're trying to prove! We need it at depth k for 3 variables to prove it at depth k for 2 variables. This would require a simultaneous induction on both k and n (number of variables), which is more complex but potentially cleaner.

### 5.5 Strengthened Bridge Theorem (Multi-Variable)

A cleaner formulation inducting on k for all n simultaneously:

```lean
theorem nf_determined_by_1var_types_and_order
    {sig : MonadicSignature} (k : Nat) (n : Nat) :
    ∀ {M N : OrderedMonadicStructure sig}
      {env_M : Fin n → M.carrier} {env_N : Fin n → N.carrier},
    -- Same 1-var depth-k types at each variable position
    (∀ i, nf_characteristic M k 1 (fun _ => env_M i) =
          nf_characteristic N k 1 (fun _ => env_N i)) →
    -- Same pairwise orderings
    (∀ i j, (env_M i < env_M j ↔ env_N i < env_N j) ∧
            (env_M i = env_M j ↔ env_N i = env_N j)) →
    -- Then same n-variable depth-k NF
    nf_characteristic M k n env_M = nf_characteristic N k n env_N
```

This says: 1-var depth-k types of all variables + pairwise orderings determine the n-var depth-k NF.

**Proof by induction on k**:

- **Base (k=0)**: The 0-depth n-var NF is `AtomKind sig n -> Bool`. AtomKind consists of predicates `pred p i` and orders `order i j`. Predicates at variable i are determined by the 1-var type of env(i). Orders are given by the pairwise ordering hypothesis.

- **Step (k+1)**: The (k+1)-depth n-var NF = (atoms, quant). Atoms part: same as base. Quant part: for each sub : NormalForm sig k (n+1), need to show (exists z, nf_eval_nf at (cons z env_M) sub) iff (exists z', nf_eval_nf at (cons z' env_N) sub). By nf_eval_unique and nf_characteristic:
  - (exists z, nf_eval_nf ... sub) iff sub = nf_characteristic M k (n+1) (cons z_0 env_M) for some z_0
  - Need to show: for each z_0 in M, exists z_0' in N with same (n+1)-var depth-k NF

  By the IH at depth k: the (n+1)-var depth-k NF of (z_0, env_M) is determined by:
  - 1-var depth-k types of z_0 and each env_M(i)
  - Pairwise orderings including z_0 vs each env_M(i)

  We need: for each z_0 in M with some 1-var depth-k type nf_z and some position relative to env_M, there exists z_0' in N with the same 1-var depth-k type and same position relative to env_N.

  **This is NOT guaranteed by the hypotheses!** The hypotheses only specify the types of env_M/env_N variables, not the existence of arbitrary points with arbitrary types and positions.

### 5.6 Revised Bridge Theorem (With Interval Profile)

The interval profile is what fills the gap. We need:

```lean
-- For each 1-var NF and each "position region" relative to env variables,
-- the NF is realized in M iff it is realized in N.
(∀ (nf_u : NormalForm sig k 1) (region : PositionRegion n),
  (∃ u, position_matches env_M u region ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) ↔
  (∃ u', position_matches env_N u' region ∧ nf_eval_nf N k 1 (fun _ => u') nf_u))
```

where `PositionRegion n` describes a position relative to n given variables (e.g., "between variable 1 and variable 2").

This is getting complex. For n=2 (the case we need), the position regions for z relative to (x, t) with x > t are:
- z > x
- z = x
- t < z < x (the interval)
- z = t
- z < t

The interval profile hypothesis covers the "t < z < x" region. For z > x, z = x, z = t, z < t, the profile is determined by the 1-var types of x and t.

Wait -- for z > x: the existence of z above x with a certain type is part of the 1-var depth-(k+1) NF of x, not the depth-k NF. But we only have depth-k information about x (from char_k). So we DON'T know about existence of points above x at depth k.

Hmm, but we DO know the depth-k NF of x, which includes information about existence of points with certain 2-var depth-(k-1) NFs. This includes some information about what's above x, but not all.

This is getting circular again. Let me step back and think about what the GHR93 proof actually uses.

### 5.7 Key Insight from GHR93

GHR93 doesn't prove the bridge theorem as I stated it. Instead, GHR93's approach is:

1. Define `X_t` = conjunction of all StaviFormulas of rank <= r true at t. This is a StaviFormula (up to logical equivalence, finitely many).
2. In the Until formula `U(B, A)`, B = X_{a_n} (point type of witness) and A = X_{(a_{n-1}, a_n)}` (disjunction of point types in interval).
3. The formula `U(B, A)` captures: "there exists x > t with type B, and all intermediate points have type in A."
4. The backward direction works because the formula ISN'T claiming to characterize a specific 2-var NF. Instead, it's used in the game argument where `U(B,A)` truth at equivalent points implies game-strategy transfer.

So GHR93 doesn't directly prove "interval profile determines 2-var NF." Instead, GHR93 uses a GAME argument: if two structures agree on all rank-r StaviFormulas, then Duplicator wins the game, which implies agreement on all depth-k FO formulas.

The formalization ALREADY has the game infrastructure. The question is how to use it for the specific sorry.

### 5.8 Approach A Revised: Use nf_characterizable_by_stavi at depth k Directly

Here's a cleaner version of Approach A:

**Key theorem needed**: For fixed parent atoms and sub_nf, there are only finitely many structures (M, t) up to depth-k 1-var NF equivalence. For each equivalence class, the truth value of "exists x with 2-var NF = sub_nf" is determined.

Since there are finitely many equivalence classes (NormalForm sig k 1 is Fintype), we can classically define:

```lean
let good_class : NormalForm sig k 1 → Bool :=
  fun nf_t => @decide (
    ∃ (M : OrderedMonadicStructure sig) (t : M.carrier),
      nf_eval_nf M k 1 (fun _ => t) nf_t ∧
      (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) ∧
      ∃ x, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
  ) (Classical.dec _)
```

Then define the formula as:
```lean
sf = sf_disjList (all_nfs.filterMap fun nf_t =>
  if good_class nf_t then some (char_k nf_t) else none)
```

**Forward**: If exists x with 2-var NF = sub_nf, then t has some 1-var type nf_t, and (M, t) witnesses that nf_t is good. So char_k nf_t holds at t, and it's in the disjunction.

**Backward**: If the disjunction holds, then char_k nf_t holds at t for some good nf_t. So nf_t is good, meaning some (M', t') with the same 1-var type has the existential. But does (M, t) have it?

**The backward direction fails again!** Just because some other structure (M', t') with the same 1-var depth-k type has the existential doesn't mean (M, t) has it. Different structures with the same 1-var depth-k type can differ on their 2-var depth-k NFs.

Wait -- but actually, the parent atom constraint means t has a fixed predicate assignment. And the 1-var depth-k type of t captures more than just atoms -- it captures all the existential quantifiers at lower depths. But the 2-var NF involves the JOINT behavior of (x, t), which goes beyond the 1-var types of x and t individually.

So this approach fails for the same fundamental reason: 1-var types don't determine 2-var types.

### 5.9 Approach A Revised Again: Use depth-(k+1) 1-var NF of t

Actually, here's a crucial observation. The theorem `nf_2var_existence_characterizable` is called in the context of building `nf_characterizable_by_stavi` at depth k+1. The IH gives `char_k` for depth-k types. But the existence "∃x, nf_eval_nf M k 2 (cons x (fun _ => t)) sub_nf" is determined by the depth-(k+1) 1-var NF of t (it's literally part of the quantifier assignment of that NF).

So two structures (M, t) and (N, s) with the same depth-(k+1) 1-var NF agree on this existential. But we don't have `char_{k+1}` yet -- that's what we're building!

This circularity is fundamental. The depth-(k+1) characterization requires the 2-var characterization, which requires the depth-(k+1) characterization.

The resolution is that the formula for the existential must use ONLY depth-k information (char_k), with additional structural constraints that break the circularity. The interval guard approach does this by adding constraints on intermediate points that, combined with the depth-k types of the endpoints, determine the 2-var NF.

---

## 6. Definitive Assessment of Approach A (Interval Guard)

### 6.1 Why It Works (Despite Points Outside the Interval)

The key insight I was missing: the 2-var depth-k NF of (x,t) depends on existentials over z. For each z:

- z's 1-var depth-k type determines z's behavior at depth k
- z's position relative to x and t is fixed
- The existential "∃z with 3-var depth-(k-1) NF = sub3" depends on z's depth-(k-1) information

But at depth (k-1), the 2-var NF of (z,x) is determined by the 1-var depth-(k-1) types of z and x plus their ordering. And the 1-var depth-(k-1) type of z is contained in the 1-var depth-k type of z (by the NF hierarchy: depth-k includes depth-(k-1) via the structure of NormalForm).

More precisely: `NormalForm sig k 1` at k+1 = `(AtomKind sig 1 -> Bool) x (NormalForm sig (k-1) 2 -> Bool)`. So the depth-k 1-var NF of z includes all depth-(k-1) 2-var existential information about z.

For z in the interval (t, x): the interval guard constrains the 1-var depth-k type of z. By the IH at depth (k-1), this determines the 2-var depth-(k-1) NFs of (z,x), (z,t).

For z outside (t, x) (z > x or z < t): the existence of z with some type is part of the depth-k NF of x or t. Since we know the depth-k types of x and t, we know which z's exist outside the interval.

Wait -- that's still not quite right. The depth-k 1-var NF of x includes "∃y, nf_eval_nf M (k-1) 2 (cons y (fun _ => x)) sub2" for each sub2. This tells us about the existence of points y relative to x with certain 2-var NFs. But y can be above or below x, and the 2-var NF of (y, x) doesn't directly tell us about the 3-var NF of (y, x, t).

I think the correct argument requires a deeper recursive analysis. Let me outline the correct proof structure:

**Theorem**: For n=2, if (M, x, t) and (N, x', t') satisfy:
1. Same depth-k 1-var types at x and x', t and t'
2. Same ordering (x > t iff x' > t')
3. Same interval profile: for each depth-k 1-var NF, realized in (t,x) iff realized in (t',x')

Then same depth-k 2-var NF at (x,t) and (x',t').

**Proof**: By induction on k.

k=0: Atoms only. Predicates determined by 1-var types. Order determined by hypothesis 2. Done.

k=k'+1: Need same atoms (same as k=0) AND same quant. The quant asks: for each sub3 : NormalForm sig k' 3, does there exist z with nf_eval_nf M k' 3 (cons z (cons x (fun _ => t))) sub3?

For a given z, the depth-k' 3-var NF of (z, x, t) is determined by:
- Atoms at z, x, t (determined by 1-var types)
- Order between all pairs (z vs x, z vs t, x vs t -- determined by position + hypothesis)
- If k' >= 1: quant part of 3-var NF at depth k', involving 4-var depth-(k'-1) NFs

By the IH at depth k' (for n=3): if (M, z, x, t) and (N, z', x', t') have same 1-var depth-k' types at each variable and same orderings, then same 3-var depth-k' NF.

But wait, we need depth-k' 1-var types, and we have depth-(k'+1) = depth-k 1-var types, which contain depth-k' types. So this works!

For the EXISTENCE part: we need "∃z in M with depth-k' 3-var NF = sub3" iff "∃z' in N with same." Given z in M:
- z has some 1-var depth-k type nf_z
- z has some position relative to x and t (above both, between, or below both)

We need z' in N with:
- Same 1-var depth-k type nf_z
- Same position relative to x', t'

For z in (t, x): the interval profile hypothesis guarantees existence of z' in (t', x') with the same depth-k 1-var type. Since z has depth-k type nf_z, z' also has depth-k type nf_z, which includes depth-k' type. By IH, same 3-var depth-k' NF.

For z = x: take z' = x'. Same depth-k type by hypothesis 1.

For z = t: take z' = t'. Same depth-k type by hypothesis 1.

For z > x: z has some depth-k 1-var type nf_z. The depth-k 1-var NF of x includes the existential "∃y > x, nf_eval_nf M (k'+1-1) 2 (cons y (fun _ => x)) sub2_zx" where sub2_zx is the depth-(k-1) 2-var NF of (z, x). Since x and x' have the same depth-k 1-var NF, the same existential holds at x', giving z' > x' with the same depth-(k-1) 2-var NF of (z', x').

BUT: does the depth-(k-1) 2-var NF of (z, x) determine the depth-k' 3-var NF of (z, x, t)? We need the depth-k' = depth-(k-1) 3-var NF, and we have the depth-(k-1) 2-var NF of (z,x). These are different: 2-var vs 3-var.

So for z > x, we need more than just the depth-(k-1) 2-var NF of (z,x). We also need the depth-(k-1) 2-var NF of (z,t) and the full ordering. The 2-var NF of (z,t) involves the relationship between z and t, which goes through the relationship between z and x (z > x > t, so z > t is determined).

Actually, the depth-(k-1) 2-var NF of (z, t) where z > t can be derived from:
- 1-var depth-(k-1) type of z (contained in depth-k type nf_z)
- 1-var depth-(k-1) type of t (contained in depth-k type of t)
- z > t (determined by z > x > t)
- Interval profile of (t, z) at depth (k-1) -- this includes points in (t, x) and in (x, z)

For points in (t, x): we have the interval profile at depth k, which includes depth-(k-1) info.
For points in (x, z): we need the interval profile between x and z... but this isn't given!

So the argument for z > x requires knowing what types exist between x and z, which isn't part of our hypotheses. This means the interval profile of (t, x) alone does NOT determine the 2-var NF of (x, t) when there are existentials involving z > x.

**Conclusion**: The simple interval guard approach DOES NOT WORK as stated. The full argument requires a more complex formula or a different proof structure.

---

## 7. The Correct Construction (Nested Temporal Formula)

After careful analysis, Approach C (nested temporal formula) appears to be the only approach that avoids the circularity and outside-interval issues. Here is the refined design:

### 7.1 Core Idea

The formula for "∃x, nf_eval_nf M k 2 (cons x (fun _ => t)) sub_nf" directly encodes the FULL 2-var NF condition, not just the 1-var type of x:

```
exists_2var_formula k sub_nf parent_atoms char_k =
  case k of
  | 0 => nf_exist_sf_depth0 (existing, works)
  | k'+1 =>
    let (atoms2, quant2) = sub_nf
    -- Atom constraints on x: predicates + order
    let x_pred_constraints = conjunction of atom literals for x's predicates
    -- Order constraint on x vs t
    let order_constraint = match direction of
      | x > t => Until
      | x < t => Since
      | x = t => identity
    -- Quantifier constraints: for each sub3 : NormalForm sig k' 3 with quant2 sub3 = true,
    -- "∃z, nf_eval_nf M k' 3 (cons z (cons x (fun _ => t))) sub3"
    -- This ITSELF is a nested existential, encoded recursively.
    let quant_constraints = conjunction over sub3 of:
      if quant2 sub3 then exists_3var_formula k' sub3 ...
      else neg (exists_3var_formula k' sub3 ...)
    -- Combine: Until/Since(x_pred_constraints AND quant_constraints, guard)
```

The recursive encoding for 3-var existentials:
```
exists_3var_formula k' sub3 parent_env_atoms char_k' =
  -- For each possible position of z relative to x and t:
  -- z > x > t, t < z < x, z = x, z = t, z < t
  disjunction over positions of:
    appropriate nested Until/Since encoding with
    z's atom constraints AND z's own quantifier constraints (recursive)
```

This recursion terminates because:
- exists_2var_formula at depth k calls exists_3var_formula at depth k-1
- exists_3var_formula at depth k-1 calls exists_4var_formula at depth k-2
- ...
- exists_(k+2)var_formula at depth 0 is purely atomic (no quantifier part)

### 7.2 Complexity

At each level, the number of variables increases by 1 and the depth decreases by 1. Starting from 2 variables at depth k, we reach (k+2) variables at depth 0. The number of NormalForm sub-cases at each level is Fintype.card (NormalForm sig (depth) (n+1)), which is finite but grows super-exponentially with depth.

The FORMULA is huge but finite. The PROOF of correctness at each level is structurally similar (case split on position, use IH for sub-formulas).

### 7.3 Implementation Strategy

Rather than defining the full recursive formula constructor, define a helper:

```lean
/-- Build a StaviFormula for "∃z, nf_eval_nf M k n (cons z env) sub_nf"
    given char_k for 1-var depth-k NFs and the parent environment's atom assignment. -/
noncomputable def nf_multivar_exist_sf
    (atomMap : ...) (h_surj : ...)
    (k : Nat) (n : Nat)  -- n = number of existing variables
    (char_k : NormalForm sig k 1 → StaviFormula)
    (parent_atoms : AtomKind sig n → Bool)
    (sub_nf : NormalForm sig k (n + 1))
    (env_order : list of order constraints)
    : StaviFormula
```

This function recurses on k (decreasing depth) with increasing n. The recursion is well-founded on k.

### 7.4 Why Forward and Backward Both Work

**Forward**: Given z with the right (n+1)-var NF, the formula holds because:
- Atom constraints follow from the NF's atom part
- Quantifier constraints follow by recursive application of the forward direction

**Backward**: Given that the formula holds, extract z from the temporal witness:
- Position of z is determined by the Until/Since structure
- Atom assignment of z is determined by the atom constraints
- Quantifier part: for each sub in the next level, the recursive formula's truth gives the required existential (by IH)
- By nf_eval_unique, the (n+1)-var NF of (z, env) equals sub_nf

---

## 8. Line Count Estimate

### Approach A (Interval Guard)
- Redefine nf_exist_sf: ~30 lines
- Re-prove forward: ~80 lines
- Bridge theorem (if it works): ~150-200 lines
- Backward proof: ~100 lines
- **Total: ~360-410 lines**
- **Risk: HIGH** -- the bridge theorem may not be provable as stated (outside-interval issue)

### Approach C (Nested Temporal Formula)
- Define nf_multivar_exist_sf: ~50 lines
- Forward direction proof: ~150-200 lines
- Backward direction proof: ~200-300 lines
- Helper lemmas (position case analysis, Fin.cons manipulation): ~200-300 lines
- **Total: ~600-800 lines**
- **Risk: LOW** -- the construction is self-contained and provably correct

### Hybrid Approach: Nested Formula with Simplified Recursion
If we observe that at depth 0, the multi-var NF is purely atomic and can be handled by direct construction (no recursion needed), and at depth 1, the sub-formulas are at depth 0 (atomic), we might simplify:
- Depth 0 case: existing nf_exist_sf_depth0 works (~0 new lines)
- Depth 1 case: ~200 lines (one level of nesting, sub-formulas are atomic)
- General case: ~400-600 additional lines
- **Total: ~400-600 lines for depth <= 1 case, ~800 for general**

---

## 9. Recommendation

### Primary: Approach C (Nested Temporal Formula)

Implement the recursive `nf_multivar_exist_sf` construction with correctness proofs by structural recursion on depth k.

**Rationale**:
1. Self-contained: no dependency on game infrastructure bridge
2. Both directions provable by structural recursion
3. No risk of outside-interval issue (formula explicitly encodes all conditions)
4. Terminates: recursion on k is well-founded (decreasing depth)

### Decomposition into Phases

1. **Phase 1** (~100 lines): Define `nf_multivar_exist_sf` for k=0 (reuse existing depth-0 infrastructure)
2. **Phase 2** (~200 lines): Define `nf_multivar_exist_sf` for k+1 (the recursive case)
3. **Phase 3** (~200 lines): Forward direction proof by structural recursion
4. **Phase 4** (~300 lines): Backward direction proof by structural recursion
5. **Phase 5** (~50 lines): Wire up to `nf_2var_existence_characterizable` and verify build

### Alternative: Approach A (Interval Guard) if Bridge is Provable

If further analysis shows the bridge theorem can handle the outside-interval issue (perhaps by strengthening the hypotheses to include the full depth-k 1-var NF which embeds existential information about points outside the interval), Approach A would be more concise (~400 lines) but carries higher risk.

---

## 10. Existing Infrastructure to Reuse

| Component | Location | Purpose |
|-----------|----------|---------|
| `nf_exist_sf_depth0` | StaviCompleteness.lean:1497 | Depth-0 existence formula (complete) |
| `nf_x_preds_sf` | StaviCompleteness.lean:1485 | Predicate constraints for quantified variable |
| `sf_conjList` / `sf_disjList` | StaviCompleteness.lean:1274-1358 | Finite conjunction/disjunction with correctness |
| `sf_atom_literal` / `atomKind_to_sf_literal` | StaviCompleteness.lean:1364-1395 | Atom literal builders |
| `nf_order_0_1` | StaviCompleteness.lean:1461 | Order direction extraction |
| `nf_t_consistent` | StaviCompleteness.lean:1475 | t-consistency check |
| `nf_characteristic_satisfies` | NormalForm.lean:224 | Canonical NF satisfaction |
| `nf_eval_unique` | NormalForm.lean:245 | NF uniqueness |
| `nf_exists_unique` | NormalForm.lean:277 | Existence + uniqueness |
| `char_k_correct` (IH) | (parameter) | 1-var depth-k NF characterization |

---

## 11. Reassessment: Interval Guard vs Nested Formula (Response to Literature Analysis)

Report 43 and the parallel literature research suggest the interval guard approach (Approach A) at ~200-300 lines. My Section 6 analysis identified a potential flaw: points z outside the interval (t,x) are unconstrained by the Until guard, so the interval profile alone may not determine the 2-var NF.

### 11.1 Revisiting the Outside-Interval Issue

For z > x (above the witness): the existence of z with a certain depth-k 1-var type nf_z and its relationship to (x, t) involves:
- The depth-(k-1) 2-var NF of (z, x) -- determined by depth-(k-1) 1-var types of z and x plus ordering (by IH at depth k-1)
- The depth-(k-1) 2-var NF of (z, t) -- determined similarly
- But the depth-(k-1) 2-var NFs of (z,x) and (z,t) need the interval profiles between (x,z) and (t,z) at depth (k-1)

The question is whether the depth-k 1-var type of x already encodes enough information about what exists above x to determine these.

The depth-k 1-var NF of x includes: for each sub2 : NormalForm sig (k-1) 2, whether ∃y with nf_eval_nf M (k-1) 2 (cons y (fun _ => x)) sub2. This tells us which 2-var depth-(k-1) NFs are realized with one extra point relative to x. But it does NOT tell us the interval profiles between x and those points.

### 11.2 When the Issue Doesn't Matter

For k=0 (base case): no quantifier part, so no outside-interval issue. The existing construction works.

For k=1: sub_nf = (atoms2, quant2) where quant2 : NormalForm sig 0 3 -> Bool. The depth-0 3-var NFs are purely atomic (no quantifier part). So the 3-var depth-0 NF of (z, x, t) is determined by:
- Predicates at z, x, t (from 1-var types at ANY depth)  
- Order between all pairs (from position)

No interval profiles are needed at depth 0. So the interval guard approach WORKS for k=1 without any bridge theorem about points outside the interval.

For k=2: sub_nf has quant2 involving depth-1 3-var NFs, which have quant parts involving depth-0 4-var NFs. The depth-0 4-var NFs are again purely atomic. So the existence of z with the right depth-1 3-var NF depends on:
- Depth-0 atoms at (z, x, t) -- from 1-var types and positions
- For each depth-0 4-var NF sub4, whether ∃w with the right atoms at (w, z, x, t) -- this depends on what w's exist, which is constrained by the depth-1 1-var types of z and x

At depth 1, the 1-var NF of z includes whether ∃w with depth-0 2-var NF of (w, z) matching each assignment. The depth-0 2-var NF of (w, z) is purely atomic (predicates at w, z and order w vs z). Since we know z's predicates (from z's 1-var type), the existence of w with the right 2-var type depends on whether there exists w with the right predicates at w AND the right order relative to z.

For w at a specific position relative to z (say w > z), the question "∃w > z with predicates matching" is about the STRUCTURE M, not about the interval (t, x). This means the interval guard CANNOT determine this.

But wait: for the depth-1 case, the interval guard constrains what depth-1 1-var types exist in (t, x). The depth-1 1-var type of u ∈ (t, x) includes "∃w with depth-0 2-var NF = sub2 relative to u." So the interval guard at depth k=1 does constrain the depth-0 existentials about points in the interval.

For points OUTSIDE the interval: the depth-k 1-var type of x (at k=1, say) includes "∃w with depth-0 2-var NF = sub2 relative to x." Since M and N have the same depth-k type at x, they agree on these existentials. So points above x ARE constrained by the depth-k type of x, even though they're outside the interval.

### 11.3 Resolution of the Outside-Interval Issue

The key insight I was missing: the depth-k 1-var NF of x DOES encode information about points outside the interval, via the quantifier part. Specifically:

- depth-k 1-var NF of x tells us: for each sub2 : NormalForm sig (k-1) 2, whether ∃y, nf_eval_nf at (y, x) = sub2. This includes y above x, below x, or equal to x.
- Similarly, depth-k 1-var NF of t tells us about existentials relative to t.
- The interval profile tells us about existentials in (t, x).

Together, these three pieces (depth-k type of x, depth-k type of t, interval profile at depth k) determine the depth-k 2-var NF of (x, t). The argument proceeds by STRONG induction on k:

**Strong induction hypothesis**: At depth k' < k, the depth-k' multi-variable NF is determined by depth-k' 1-var types and orderings (for finitely many variables).

**At depth 0**: Purely atomic, trivially determined.

**At depth k** (assuming result for all k' < k): The depth-k 2-var NF of (x,t) = (atoms, quant) where quant(sub3) asks ∃z, nf_eval at depth (k-1) with 3 vars. By the IH at depth (k-1), the 3-var depth-(k-1) NF of (z, x, t) is determined by the depth-(k-1) 1-var types of z, x, t plus orderings. Since depth-k types contain depth-(k-1) types, we know the depth-(k-1) types of x and t. For z, we need:
1. z's depth-(k-1) 1-var type
2. z's position relative to x and t

Given z's type and position, the 3-var depth-(k-1) NF is determined. The question "∃z with type nf_z at position P" is determined by:
- For P = "between t and x": the interval profile at depth k (which includes depth-(k-1) info)
- For P = "above x": the depth-k type of x (includes "∃y > x with depth-(k-1) NF = ...")
- For P = "below t": the depth-k type of t
- For P = "equals x": directly known
- For P = "equals t": directly known

But wait -- does the depth-k type of x tell us "∃y > x with depth-(k-1) 1-var type = nf_z"? Let me check.

The depth-k 1-var NF of x has quant part: NormalForm sig (k-1) 2 -> Bool. This tells us for each sub2, whether ∃y, nf_eval at depth (k-1) with 2 vars at (y, x) = sub2. The sub2 encodes both the type of y AND its relationship to x (atoms at y, atoms at x, order between y and x). So "∃y > x with depth-(k-1) type nf_z" is captured IF we pick sub2 with:
- atoms for variable 0 (= y) matching nf_z at depth (k-1)
- order(0,1) = true (y > x) or order(1,0) = true (x < y)
- atoms for variable 1 matching x's atoms

And the quant part tells us this sub2 is satisfiable. So YES, the depth-k 1-var type of x determines whether there exists y > x with depth-(k-1) 1-var type nf_z.

BUT: this only tells us about the depth-(k-1) 1-var type of z, not the full depth-(k-1) relationship between z and ALL of {x, t}. The 3-var depth-(k-1) NF of (z, x, t) requires knowing the depth-(k-1) 2-var NFs of (z,x), (z,t), AND (x,t). We know (z,x) from the sub2 in x's quant part. We can deduce (z,t) because we know z's position relative to t (z > x > t implies z > t). And we know (x,t) from the interval profile and endpoint types.

Actually, for (z,t) when z > x > t: we need the depth-(k-1) 2-var NF of (z, t). By the IH at depth (k-1), this is determined by:
- depth-(k-1) 1-var types of z and t
- z > t
- Interval profile of (t, z) at depth (k-1)

The interval (t, z) = (t, x) union {x} union (x, z). We know:
- (t, x) profile at depth (k-1): contained in the depth-k interval profile
- x's depth-(k-1) type: known
- (x, z) profile at depth (k-1): NOT directly known

So we still need the interval profile of (x, z) at depth (k-1). This is where the argument gets subtle.

However, the depth-k type of x includes existential information about ALL points y relative to x (from x's quant part). For a specific z > x, the depth-(k-1) 2-var NF of (z, x) is a specific sub2, and x's quant part tells us whether such a z exists. But it doesn't tell us the profile of (x, z) -- it only tells us the type of z itself.

### 11.4 Final Assessment

After deep analysis, the outside-interval issue appears to be REAL for k >= 2 in the general case. The interval guard approach may work for small k (k=0, k=1 confirmed) but requires a more sophisticated argument for k >= 2.

However, there may be a way around this: instead of proving the bridge theorem for arbitrary structures, prove it for the SPECIFIC formula construction. The backward direction of `nf_2var_existence_characterizable` asks: given that U(witness_type, interval_guard) holds at t, prove ∃x, nf_eval_nf M k 2 (cons x (fun _ => t)) sub_nf. The Until formula provides a specific witness x and specific intermediate-point information. The proof can use this specific witness and the NF uniqueness arguments to close the goal.

The key would be: after extracting x from the Until witness, compute the ACTUAL depth-k 2-var NF of (x, t) as nf_actual = nf_characteristic M k 2 (cons x (fun _ => t)), and then show nf_actual = sub_nf. This requires showing that every component of nf_actual matches sub_nf:
- Atom part: from the atom constraints in the formula
- Quant part (for k >= 1): for each sub3, ∃z iff sub_nf.2 sub3

For the quant part, the argument needs that "the specific Until formula + interval guard" determines whether each sub3 is satisfiable. This is where the nested temporal formula approach (Approach C) has an advantage: it EXPLICITLY encodes the quant constraints, so the backward direction is structural.

### 11.5 Revised Recommendation

Given the subtlety of the outside-interval issue for k >= 2, and the self-contained correctness of Approach C:

1. **Primary recommendation remains Approach C** (nested temporal formula, ~600-800 lines). This is guaranteed to work and avoids all bridge theorem issues.

2. **If line count is a concern**: Approach A (interval guard) may work but requires careful handling of the k >= 2 case. Estimated ~300-500 lines if the bridge theorem argument works, but carries risk of encountering the outside-interval issue during formalization.

3. **Hybrid approach**: Implement Approach A for the formula construction (~30 lines), prove forward (~80 lines), and for backward, use a game-theoretic argument that leverages the existing ghr93_strategy_compose and ghr93_game_iff_decomposition infrastructure. This would require a bridge from game wins to NF equality, which is the content of the Decomposition.lean infrastructure. Estimated ~200-400 lines but requires careful type-level bridging between ExtendedCarrier and raw carrier.

4. **Simplest approach (potentially ~200 lines)**: Prove the result ONLY for k=0 as a separate lemma (base case, purely atomic), then for k >= 1, use a simultaneous Classical.choice construction where ALL sub_nf formulas are chosen at once based on the fact that only finitely many depth-(k+1) 1-var NFs exist. This avoids constructing any formula explicitly but relies on classical definability of the "good class" predicate. Needs careful analysis to avoid the circularity identified in Section 5.8.
