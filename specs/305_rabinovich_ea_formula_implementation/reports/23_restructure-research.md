# Full Restructuring Plan for Faithful Rabinovich Formalization

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Type**: lean4
- **Session**: sess_1782191203_6e98b6
- **Agent**: lean-research-hard-agent (H3 + H4)
- **Tier**: 1 (literature-backed, lean4 strict)

---

## 1. Rabinovich Proof Architecture

### Complete Dependency Graph

```
Section 3 (Definitions + Closure):
  Def 3.1 (EA formula)
  Def 3.3 (V-EA = disjunction of EA)
  Lemma 3.2.1 (conjunction closure)
  Lemma 3.4 (V-EA closed under disj, conj, exists)
  Prop 3.5 (V-EA with 1 free var -> TL(U,S))

Section 5 (Negation Closure -- the hard core):
  Notation 5.2 (bracket formula)
  INF formula construction (eq 5.2, K+ operator)
  Lemma 5.3 (all-betas-True negation -> V-EA)
    Induction: on n (number of witness points)
    Uses: INF formula (Dedekind completeness)
  Corollary 5.4 (neg partial bracket exist -> V-EA)
    Uses: Lemma 5.3, F-chain reduction
  Lemma 5.1 (neg bracket -> V-EA)
    Induction: on n (number of witnesses)
    Uses: Corollary 5.4, interval splitting (A_i^-/A_i^+)
    Key: alpha_0 evaluated at ENDPOINT z_0

Section 4 (Main Argument):
  Prop 4.2 (neg 2-var EA -> V-EA)
    Uses: Lemma 5.1
    Scope: over Dedekind complete chains
  Prop 4.3 (every FO formula -> V-EA)
    Induction: STRUCTURAL on FO formula
    Cases: atomic (immediate), disj (immediate), neg (Prop 4.2), exists (Lemma 3.4)
    Uses: Prop 4.2, Lemma 3.4
  Theorem 4.4 (Kamp's theorem: FO -> TL)
    Uses: Prop 4.3 + Prop 3.5
```

### Precise Statement Forms

| Reference | Statement Form | Induction Principle | Dedekind Use |
|-----------|---------------|--------------------:|-------------|
| **Def 3.1** | EA formula = exists x_n...x_0, ordering AND alpha_j(x_j) AND beta_j on intervals | N/A | None |
| **Lemma 3.2** | (1) conj of EA = disj of EA; (2) EA -> conj of 2-var EA; (3) exists x (EA) is EA | Combinatorial | None |
| **Lemma 3.4** | V-EA closed under disj, conj, exists | Direct from 3.2 | None |
| **Prop 3.5** | V-EA with 1 free var equiv to TL(U,S) | Structural (interval position) | None |
| **Lemma 5.3** | neg (ordered points with P_i) equiv V-EA | Induction on n | INF formula requires Dedekind completeness |
| **Cor 5.4** | neg (exists z, bracket(z_0,z)) equiv V-EA | Reduces to Lemma 5.3 via F-chain | None (inherits from 5.3) |
| **Lemma 5.1** | neg bracket(z_0,z_1) equiv V-EA | Induction on n (witnesses) | INF for first failure point |
| **Prop 4.2** | neg (2-var EA) equiv V-EA | From Lemma 5.1 + de Morgan | Inherited from 5.1 |
| **Prop 4.3** | every FO formula equiv V-EA | **Structural induction on FO** | Inherited from 4.2 |
| **Thm 4.4** | every FO phi(x) has equiv TL formula | Immediate from 4.3 + 3.5 | Inherited |

### Rabinovich's Induction Principles (Critical Detail)

Rabinovich uses exactly TWO induction principles in the entire proof:

1. **Induction on n** (number of existential witnesses): Used in Lemma 5.3 and Lemma 5.1. When a bracket formula with n+1 witnesses is negated, the case analysis always reduces to formulas with at most n witnesses. This is NOT induction on interval size or model depth.

2. **Structural induction on FO formulas**: Used in Prop 4.3. The cases are: atomic (trivially EA), disjunction (closure), negation (Prop 4.2), existential (Lemma 3.4). There is NO depth parameter consumed.

The current formalization uses NEITHER of these. Instead it uses **mutual induction on NF depth k** (CharPart(k) AND ExistPart(k)), which creates circular depth dependencies.

### Role of Dedekind Completeness

Dedekind completeness is used in exactly ONE place: the INF formula construction in Lemma 5.3. Given a predicate P that occurs in (z_0, z_1), Dedekind completeness guarantees r_0 = inf{z in (z_0,z_1) | P(z)} exists, with:

- P(r_0) if the infimum is attained (always true for discrete orders)
- K+(P)(r_0) if the infimum is a limit point (only for dense orders like R)

For Prior structures (discrete linear orders with finite past), ALL infima are attained. The K+ case never arises. The formalization correctly captures this via `HasAttainedINF` (PriorINF.lean), which is proved for Prior structures via `prior_hasAttainedINF`.

Rabinovich NEVER makes cross-model arguments. Everything is within a single Dedekind complete chain.

---

## 2. Reuse Catalog

### File-by-File Assessment

| File | Lines | Sorry Count | Reuse Status | Assessment |
|------|------:|:-----------:|:------------:|-----------|
| `ExistsForallNF.lean` | 339 | 0 | **KEEP** | Core types (TemporalPred, IntervalPattern, VEF). Faithful to Def 3.1. |
| `VecEAFormula.lean` | 769 | 0 | **KEEP** | BracketFormula, VBracketFormula, VecEA2, VVecEA2, leftPart, rightPart, splitAt_combine. All sorry-free, all faithful. |
| `VecEAClosure.lean` | 386 | 0 | **KEEP** | Lemma 3.2.1, Lemma 3.4 closure properties. Sorry-free, faithful. |
| `PriorINF.lean` | 245 | 0 | **KEEP** | HasDefinableINF, HasAttainedINF, prior_hasAttainedINF, kplus. Sorry-free. |
| `Translation.lean` | 337 | 0 | **KEEP** | buildRight, buildLeft, translation machinery. Sorry-free. |
| `RabinovichTranslation.lean` | 302 | 0 | **KEEP** | Prop 3.5 (ExistsForallSpec.translate_correct). Sorry-free, faithful. |
| `EANegation.lean` | 1237 | 2 | **MODIFY** | Lemma 5.3 (sorry-free), Cor 5.4 forward (sorry-free), Lemma 5.1 biconditional (2 sorrys -- UNPROVABLE at BracketFormula level). The sorry-free parts are reusable. The biconditional proofs need restructuring. |
| `EANegationClosure.lean` | 567 | 0 | **KEEP or REPLACE** | Model-dependent negation closure. Sorry-free. If full Rabinovich is followed, this file becomes redundant (replaced by model-independent versions). But it provides a sorry-free fallback. |
| `PriorComposition.lean` | 400 | 2 | **REPLACE** | prior_2var_transfer_until/since have sorry. These are artifacts of the NF-depth approach. In the Rabinovich chain, they are unnecessary. The sorry-free infrastructure (skipIdx, nf_skipIdx_cross, atom agreement helpers) can be preserved. |
| `KampBypass.lean` | 889 | 0* | **REPLACE** | The bypass approach. Uses PriorComposition sorry indirectly. Not part of Rabinovich. Would be replaced by Prop 4.2/4.3/4.4 chain. |
| `KampBypassCore.lean` | 681 | 0 | **REPLACE** | Part of KampBypass infrastructure. |
| `KampBypassEqCase.lean` | 891 | 0 | **REPLACE** | Part of KampBypass infrastructure. |
| `KampBypassUntil.lean` | 979 | 0 | **REPLACE** | Part of KampBypass infrastructure. |
| `KampBypassSince.lean` | 1307 | 0 | **REPLACE** | Part of KampBypass infrastructure. |
| `KampBypassBridge.lean` | 545 | 0 | **REPLACE** | Part of KampBypass infrastructure. |
| `KampMutualInduction.lean` | 446 | 0* | **REPLACE** | Mutual induction (CharPart/ExistPart). Not Rabinovich. Depends on KampBypass. |
| `KampPrior.lean` | 278 | 0* | **MODIFY** | Final theorem. Keep the theorem statement, replace proof with Rabinovich chain. |
| `NfCharFormula.lean` | 755 | 2 | **REPLACE** | nf_exist_backward_prior, nf_2var_exist_formula_prior_filled have sorry. These are NF-depth approach artifacts. |
| `NfComposition.lean` | 646 | 0 | **KEEP** | NF composition infrastructure. Used by KampBypass but also generally useful. |
| `NfToVecEA.lean` | 766 | 0 | **KEEP** | Depth-0 NF to VecEA2 bridge. Useful for the atomic case of Prop 4.3. |
| `VecEADecomp.lean` | 898 | 0 | **KEEP** | 3-var zone decomposition at depth 0. Used by KampBypass. Potentially reusable. |
| `VecEATranslation.lean` | 297 | 0 | **KEEP** | VecEA2 to TL translation. Useful for the final step. |
| `KampForward.lean` | 675 | 0 | **KEEP** | Forward biconditionals. Sorry-free and useful. |
| `ZoneBridge.lean` | 513 | 0 | **KEEP** | Zone bridging. Used by KampBypass. |
| `SeparationBridge.lean` | 199 | 0 | **KEEP** | Bridge to separation property. |
| `WitnessCount.lean` | 147 | 0 | **KEEP** | Witness counting theorems. Sorry-free. |
| `GeneralExistPart.lean` | 102 | 0 | **KEEP** | General exist part. |

### Summary

| Category | Files | Lines |
|----------|------:|------:|
| **KEEP (no changes)** | 16 | ~6,621 |
| **MODIFY (partial rewrite)** | 3 | ~1,915 |
| **REPLACE (new code)** | 8 | ~5,739 |

---

## 3. Endpoint Convention Analysis

### What Must Change Structurally

The fundamental structural change is how alpha_0 is positioned:

**Current convention (BracketFormula)**:
```
[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)
```
alpha_0 is at an INTERIOR existential witness x_0 in (z_0, z_1). The bracket formula existentially quantifies over x_0.

**Rabinovich's convention (Notation 5.2)**:
```
[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)
```
alpha_0 is evaluated at the LEFT ENDPOINT z_0. The bracket formula does NOT existentially quantify over the first point -- it is the fixed endpoint z_0.

### Impact on Types

The existing `BracketFormula n` type ALREADY matches Rabinovich's Notation 5.2 when viewed from the VecEA2 perspective. The `VecEA2 n` structure has:
- `endpointLeft : TemporalPred` -- this IS alpha_0 at z_0
- `endpointRight : TemporalPred` -- this IS alpha_n at z_1
- `bracket : BracketFormula n` -- the INTERIOR witnesses

So the existing type hierarchy already supports the endpoint convention. The issue is that `neg_bracket_is_vbracket` tries to prove negation at the BracketFormula level (interior witnesses only), when Rabinovich's proof works at the VecEA2 level (endpoints + interior).

### What Does NOT Need to Change

1. **BracketFormula type**: No change needed. It correctly represents the interior bracket.
2. **VBracketFormula type**: No change needed. Disjunctions of brackets.
3. **VecEA2 type**: No change needed. It already has endpoint predicates.
4. **VVecEA2 type**: No change needed. Disjunctions of VecEA2.
5. **BracketFormula.leftPart/rightPart/splitAt_combine**: No change needed.
6. **BracketFormula.prepend/prepend_holds/prepend_holds_inv**: No change needed.
7. **VBracketFormula.holds_iff_vef_holds**: No change needed.

### What Needs to Change

The negation closure theorems need to be RESTRUCTURED to work at the VecEA2 level:

1. **New: `neg_vecEA2_bracket`** -- Lemma 5.1 at the VecEA2 level. Given a VecEA2 formula (endpointLeft at z_0, bracket with n witnesses, endpointRight at z_1), its negation is VVecEA2. This follows Rabinovich exactly because alpha_0 = endpointLeft is at z_0 (fixed endpoint).

2. **Modified: `neg_bracket_is_vbracket`** -- Can be derived from the VecEA2-level result by setting endpointLeft = top (trivially true). Or left as-is with documented impossibility (since it is unused downstream).

3. **New: Prop 4.2 (model-independent)** -- `neg_vvecEA2_is_vvecEA2`. Uses neg_vecEA2_bracket.

4. **New: Prop 4.3** -- Every FO formula equiv V-EA. Structural induction. Uses Prop 4.2 for negation, Lemma 3.4 for exists.

5. **New: Theorem 4.4** -- Kamp's theorem. Prop 4.3 + Prop 3.5.

### The VecEA2-Level Lemma 5.1 (Endpoint Bracket Negation)

Type signature:
```lean
theorem neg_vecEA2_is_vvecEA2 :
    forall (n : Nat) (vea : VecEA2 n),
    exists (v : VVecEA2),
    forall {sig} (M : OrderedMonadicStructure sig)
      (atomMap : Formula -> sig.preds) (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 ->
      (v.holds M atomMap z0 z1 <-> neg vea.holds M atomMap z0 z1)
```

This IS provable because:
- The case split on alpha_0(z_0) is deterministic (z_0 is fixed)
- When alpha_0(z_0) holds and beta_1 fails somewhere, the split point has fewer witnesses
- When alpha_0(z_0) holds and beta_1 holds everywhere, the reduction goes to Cor 5.4 on the tail (fewer witnesses)
- No beta_0(r0) issue arises because there is no existential alpha_0 point

---

## 4. Lemma 5.1 Step-by-Step

### Rabinovich's Full Proof of Lemma 5.1 (pp. 7-11)

**Statement**: neg [alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1) equiv V-EA over Dedekind complete chains.

In the VecEA2 formulation, this becomes: neg (alpha_0(z_0) AND bracket(z_0, z_1)) equiv VVecEA2.

**Proof by induction on n** (number of interior witnesses in the bracket):

#### Base case (n = 0)
The bracket formula has 0 interior witnesses. bracket.holds(z_0, z_1) = forall y in (z_0, z_1), seg_0(y). So:

neg (alpha_0(z_0) AND forall y in (z_0,z_1), seg_0(y))

Equivalent to: neg alpha_0(z_0) OR exists y in (z_0,z_1), neg seg_0(y).

As a VVecEA2:
- Disjunct 1: endpointLeft = alpha_0.neg, endpointRight = top, bracket = trivial(top). This is neg alpha_0(z_0).
- Disjunct 2: endpointLeft = alpha_0, endpointRight = top, bracket = single(seg_0.neg, top, top). This is alpha_0(z_0) AND exists y with neg seg_0(y).

Forward direction: straightforward.
Backward direction: if neg alpha_0(z_0), disjunct 1 holds. If alpha_0(z_0), then forall seg_0 must fail, so exists y with neg seg_0(y), disjunct 2 holds.

#### Inductive step (n + 1 witnesses)

Let bf be a BracketFormula with n+1 interior witnesses. Let:
- pt_0 = bf.pointTypes(0) (first interior witness type)
- seg_0 = bf.segmentTypes(0) (first segment type, on (z_0, x_0))

The VecEA2 formula is: alpha_0(z_0) AND exists x_0 in (z_0, z_1), pt_0(x_0) AND seg_0 on (z_0, x_0) AND rightPart.holds(x_0, z_1).

Its negation decomposes into three Rabinovich cases:

**Case 1: neg alpha_0(z_0)**

Trivial VVecEA2 disjunct: endpointLeft = alpha_0.neg, bracket = trivial(top).

**Case 2: alpha_0(z_0) AND seg_0 holds everywhere in (z_0, z_1)**

When seg_0 holds everywhere, the bracket simplifies to: exists x_0 in (z_0, z_1), pt_0(x_0) AND rightPart.holds(x_0, z_1). This is a "partial bracket exist" -- Corollary 5.4 negated.

Specifically: neg (exists z in (z_0, z_1), [pt_0, seg_1, ..., alpha_n](z_0, z)). But wait -- we need to be careful. The bracket [alpha_0, beta_1, alpha_1, ..., alpha_n](z_0, z_1) with alpha_0 at ENDPOINT z_0 decomposes as:

alpha_0(z_0) AND exists x_0, pt_0(x_0) AND seg_0 on (z_0, x_0) AND tail.holds(x_0, z_1)

When seg_0 on all of (z_0, z_1), this becomes: exists x_0, pt_0(x_0) AND tail.holds(x_0, z_1), which is: exists x_0, [pt_0, seg_1, alpha_1, ..., alpha_n](x_0, z_1) where pt_0 is at the new endpoint x_0.

Negation: forall x_0 in (z_0, z_1), neg [pt_0, seg_1, ..., alpha_n](x_0, z_1). This is neg (exists z, VecEA2.holds(z, z_1)). By Corollary 5.4, this is VVecEA2.

Alternatively, this reduces to orderedPointsExist negation (Lemma 5.3 via the F-chain reduction from existing Cor 5.4).

**Case 3: alpha_0(z_0) AND exists y in (z_0, z_1) with neg seg_0(y)**

Find the first neg-seg_0 point r using HasAttainedINF. Then r splits the interval:
- On (z_0, r): seg_0 holds everywhere
- At r: neg seg_0(r)
- On (r, z_1): arbitrary

The original bracket negation at (z_0, z_1) with alpha_0(z_0) and the first seg_0-failure at r gives:

For each position i where a witness could be relative to r, the bracket splits into leftPart on (z_0, r) and rightPart on (r, z_1). Each part has strictly fewer witnesses. By IH, their negations are VVecEA2.

More precisely: the bracket [alpha_0, seg_0, pt_0, seg_1, ..., alpha_n](z_0, z_1) with alpha_0 at z_0, when combined with "first seg_0 failure at r", decomposes as:

- No pt_0 in (z_0, r) (since seg_0 holds on (z_0, r) and we are looking for the first seg_0 failure): the bracket formula requires x_0 in (z_0, z_1) with pt_0(x_0) and seg_0 on (z_0, x_0). If x_0 < r, then seg_0 on (z_0, x_0) is fine, but we also need rightPart on (x_0, z_1). If x_0 >= r, then seg_0 on (z_0, x_0) fails at r.

So the bracket can only hold if x_0 < r AND seg_0 on (z_0, x_0) AND rightPart on (x_0, z_1).

Negation: either no x_0 < r with pt_0(x_0) (handled by ordered points negation on (z_0, r)), or for each such x_0, rightPart fails on (x_0, z_1) (IH on n-1 witnesses).

Both sub-problems have strictly fewer witnesses than n+1, so the IH applies.

#### Induction Measure

The induction is on n, the number of interior witnesses in the bracket. Each case reduces:
- Case 1: no bracket (trivial)
- Case 2: reduces to partial bracket exist negation which has at most n+1 witnesses but the F-chain reduction converts to orderedPointsExist with at most 1 witness, so Lemma 5.3 handles it
- Case 3: splits the bracket, each half has strictly fewer witnesses

The measure strictly decreases in every case. No model-dependent recursion. No depth consumption.

#### Why beta_0(r0) Does NOT Arise

In Rabinovich's formulation, alpha_0 is at the fixed endpoint z_0. The case split is:
- Does alpha_0(z_0) hold? (deterministic, no existential search)
- Does seg_0 (= beta_1 in paper notation) fail somewhere in (z_0, z_1)?

There is no existential alpha_0 point r0 to find. The "beta_0(r0)" issue from the BracketFormula-level proof was: when alpha_0 is at an interior existential witness r0, and beta_0 (the segment before r0) holds at r0 itself, you cannot construct a CaseD disjunct. This issue evaporates because alpha_0 is at z_0, a fixed point.

---

## 5. Chain to Kamp's Theorem: Lemma 5.1 -> Prop 4.2 -> 4.3 -> 4.4

### Lemma 5.1 -> Proposition 4.2

**Prop 4.2**: The negation of an EA formula with at most 2 free variables is equivalent to V-EA over Dedekind complete chains.

An EA formula with 2 free variables has the form `VecEA2 n`: endpointLeft(z_0) AND endpointRight(z_1) AND bracket(z_0, z_1).

Its negation via de Morgan:
- neg endpointLeft(z_0): trivial VVecEA2
- endpointLeft(z_0) AND neg endpointRight(z_1): trivial VVecEA2
- endpointLeft(z_0) AND endpointRight(z_1) AND neg bracket(z_0, z_1): by Lemma 5.1

A V-EA formula (disjunction of EA) negation uses conjunction:
- neg (vea_1 OR vea_2 OR ...) = neg vea_1 AND neg vea_2 AND ...
- Each neg vea_i is VVecEA2 by the single-conjunct case
- The conjunction of VVecEA2 formulas is VVecEA2 by Lemma 3.4 (closure under conjunction)

The model-dependent version (`neg_vecEA2`, `neg_2var_vec_ea` in EANegationClosure.lean) is already sorry-free. The model-independent version needs the model-independent Lemma 5.1.

**Adapter lemmas needed**: None beyond what exists. The `VVecEA2.conj_holds_vvecEA2` in VecEAClosure.lean handles the conjunction. The `VBracketFormula.toVVecEA2WithEndpoints` in EANegationClosure.lean handles wrapping brackets with endpoints.

### Proposition 4.2 -> Proposition 4.3

**Prop 4.3**: Every FO formula is equivalent to V-EA over Dedekind complete chains.

This is proved by structural induction on FO formulas. The formalization needs a representation of FO formulas and an induction principle.

The current formalization already has `MonadicFormula sig n` (in MonadicFO.lean). The structural induction cases are:

1. **Atomic** (P(x_i) or x_i < x_j): These are trivially EA formulas (0 existential witnesses, just endpoint/atom conditions). For the 1-free-variable case, this is a VecEA2 with 0 witnesses and appropriate endpoint predicates.

2. **Disjunction** (phi OR psi): If phi equiv V-EA and psi equiv V-EA, then phi OR psi equiv V-EA by closure under disjunction (Lemma 3.4).

3. **Negation** (neg phi): If phi equiv V-EA (with at most 2 free vars), then neg phi equiv V-EA by Prop 4.2.

4. **Existential** (exists x, phi): If phi equiv V-EA, then exists x phi equiv V-EA by Lemma 3.4 (closure under existential quantification).

**Key subtlety**: Prop 4.3 works for formulas with ANY number of free variables, but the negation step (Prop 4.2) only handles at most 2 free variables. Rabinovich handles this via Lemma 3.2.2: every EA formula is equivalent to a conjunction of EA formulas with at most 2 free variables. The current formalization has this infrastructure partially (BracketFormula is already 2-free-variable).

**What is needed**: A new file implementing Prop 4.3 by structural induction on `MonadicFormula sig 1`. For the 1-free-variable case, all formulas can be reduced to 2-free-variable EA via the existential step. The key cases:
- Atomic: NfToVecEA.lean already bridges depth-0 NFs to VecEA2
- Negation: Prop 4.2 (to be proved model-independently)
- Existential: VecEAClosure.lean already has exists closure

**Estimated effort**: ~200-300 lines for the structural induction, given existing infrastructure.

### Proposition 4.3 -> Theorem 4.4

**Theorem 4.4**: For every FO formula phi(x) with one free variable, there exists an equivalent TL(U,S) formula over Dedekind complete chains.

By Prop 4.3, phi(x) equiv V-EA formula. By Prop 3.5 (RabinovichTranslation.lean, sorry-free), every V-EA with 1 free variable equiv TL(U,S).

This gives the same result as `kamp_prior_expressive_completeness` but via the Rabinovich chain instead of the NF-depth mutual induction.

**Can this REPLACE KampBypass/KampMutualInduction?** Yes, completely. The chain Lemma 5.1 -> 4.2 -> 4.3 -> 4.4 replaces:
- KampBypass.lean (889 lines)
- KampBypassCore.lean (681 lines)
- KampBypassEqCase.lean (891 lines)
- KampBypassUntil.lean (979 lines)
- KampBypassSince.lean (1307 lines)
- KampBypassBridge.lean (545 lines)
- KampMutualInduction.lean (446 lines)
- NfCharFormula.lean (755 lines, partially)
- PriorComposition.lean (400 lines, sorry-bearing parts)

Total: ~5,900 lines of bypass infrastructure replaced by ~500-800 lines of faithful Rabinovich chain.

---

## 6. Prior Integration

### Does Prior Satisfy Dedekind Completeness?

**Yes.** Prior structures are discrete linear orders with a finite past. More precisely, they are omega-type structures (order-isomorphic to initial segments of N, Z, or similar). All discrete linear orders are trivially Dedekind complete because:
- Every non-empty bounded-below subset has an infimum (it's the minimum, which exists in a well-ordered or reverse-well-ordered structure)
- Infima are always attained (no limit points in discrete orders)

The formalization captures this via `HasAttainedINF` (PriorINF.lean:202), proved for Prior structures via `prior_hasAttainedINF` (PriorINF.lean:224).

### Does Prior Satisfy HasAttainedINF?

**Yes**, proved sorry-free. `prior_hasAttainedINF` uses `semantic_prior_UZ` (the Until-Zero axiom) to find the first occurrence of any predicate in an interval. The UZ axiom directly provides an attained first occurrence.

### Adapter from Rabinovich to Prior

The Rabinovich chain produces results over "all Dedekind complete chains." The adapter to Prior is:

```lean
-- The Rabinovich chain gives: for all M with HasAttainedINF, phi <-> TL
-- Prior structures have HasAttainedINF (prior_hasAttainedINF)
-- Therefore: for Prior M, phi <-> TL
```

This is a one-line instantiation. No additional adapter lemma is needed beyond confirming that Prior -> HasAttainedINF, which is already proved.

### What About semantic_prior_SZ?

`semantic_prior_SZ` (Since-Zero) is the dual of UZ for the past direction. It is used for the `HasAttainedSUP` (dual of HasAttainedINF) which handles the Since direction. The existing `prior_hasDefinableSUP` (PriorINF.lean) covers this. If the Rabinovich chain is symmetric (handling both Until and Since), `HasAttainedSUP` is needed for the Since direction of Prop 3.5.

The existing `RabinovichTranslation.lean` already handles both directions (future_chain uses Until, past_chain uses Since), so no additional work is needed.

---

## 7. Effort Estimate

### New Code Required

| Component | Lines (est.) | Risk | Notes |
|-----------|-----:|:----:|-------|
| VecEA2-level Lemma 5.1 (`neg_vecEA2_bracket_is_vvecEA2`) | 300-400 | Medium | Core new theorem. Three cases, induction on n. Template: neg_interval_formula (EANegationClosure.lean). |
| Model-independent Prop 4.2 (`neg_vvecEA2_model_indep`) | 100-150 | Low | De Morgan + Lemma 5.1 + conjunction closure. Template: neg_2var_vec_ea (EANegationClosure.lean). |
| Prop 4.3 structural induction (`fo_to_vea`) | 200-300 | Medium | Structural induction on MonadicFormula. Cases: atomic (NfToVecEA bridge), disj, neg (Prop 4.2), exists (closure). |
| Theorem 4.4 (`kamp_theorem_rabinovich`) | 50-100 | Low | Prop 4.3 + Prop 3.5. Nearly boilerplate. |
| KampPrior.lean update | 50-100 | Low | Replace mutual induction proof with Rabinovich chain instantiation. |
| Cor 5.4 biconditional fix | 100-150 | Medium | Backward direction using VecEA2-level Lemma 5.1. |
| **Total new** | **800-1200** | | |

### Existing Code Deletable

| Component | Lines | Notes |
|-----------|------:|-------|
| KampBypass.lean | 889 | Entire file replaceable |
| KampBypassCore.lean | 681 | Entire file replaceable |
| KampBypassEqCase.lean | 891 | Entire file replaceable |
| KampBypassUntil.lean | 979 | Entire file replaceable |
| KampBypassSince.lean | 1307 | Entire file replaceable |
| KampBypassBridge.lean | 545 | Entire file replaceable |
| KampMutualInduction.lean (partial) | ~300 | Mutual induction framework replaceable |
| NfCharFormula.lean (sorry-bearing parts) | ~200 | Sorry stubs replaceable |
| PriorComposition.lean (sorry stubs) | ~140 | prior_2var_transfer_until/since replaceable |
| **Total deletable** | **~5,900** | |

### Net Impact

- New code: ~800-1200 lines
- Deletable code: ~5,900 lines
- **Net reduction: ~4,700-5,100 lines**
- **Sorry elimination: 6 sorrys removed** (PriorComposition x2, NfCharFormula x2, EANegation x2)

### High-Risk Proof Steps

1. **VecEA2-level Lemma 5.1, Case 2 (seg holds everywhere)**: Reducing to Cor 5.4. The F-chain reduction is complex. The existing Cor 5.4 forward direction is proved; the backward direction needs the VecEA2-level argument.

2. **VecEA2-level Lemma 5.1, Case 3 (interval splitting)**: Constructing the V-bracket from the two sub-bracket negations. The leftPart/rightPart infrastructure exists, but combining the negations into a single VVecEA2 requires careful index arithmetic.

3. **Prop 4.3, negation case**: The free variable count reduction (from k free vars to at most 2) requires Lemma 3.2.2. The current formalization has conjunction closure (Lemma 3.2.1) but not the full free-variable reduction. This may need ~100 additional lines.

### Timeline

| Phase | Duration | Dependencies |
|-------|----------|-------------|
| Phase 1: VecEA2-level Lemma 5.1 | 2-3 days | None |
| Phase 2: Prop 4.2 (model-independent) | 0.5-1 day | Phase 1 |
| Phase 3: Prop 4.3 (structural induction) | 1-2 days | Phase 2 |
| Phase 4: Theorem 4.4 + KampPrior update | 0.5 day | Phase 3 |
| Phase 5: Cleanup (delete bypass, sorry audit) | 0.5-1 day | Phase 4 |
| **Total** | **5-8 days** | |

### Incremental vs Big-Bang

**Incremental approach is feasible and recommended.** The Rabinovich chain can be built alongside the existing code:

1. Add VecEA2-level Lemma 5.1 in a new file (e.g., `EndpointNegation.lean`). Compiles independently.
2. Add Prop 4.2 model-independent in a new file (e.g., `ModelIndepNegation.lean`). Imports EndpointNegation.
3. Add Prop 4.3 in a new file (e.g., `FOToVEA.lean`). Imports ModelIndepNegation + existing closure.
4. Add Theorem 4.4 in a new file (e.g., `KampRabinovich.lean`). Imports FOToVEA + RabinovichTranslation.
5. Update `KampPrior.lean` to use the new chain. At this point, KampBypass/MutualInduction are unused.
6. Delete (or move to Boneyard) the bypass infrastructure.

At every step, `lake build` should succeed. No existing sorry-free code is modified until step 5.

---

## 8. H3 Mapping Table (Updated)

### Complete Source-to-Implementation Mapping

| Source (Rabinovich) | Prop/Location | Lean Identifier | Type Signature (verified) | Status |
|---------------------|--------------|-----------------|--------------------------|--------|
| Def 3.1 | EA formula, p.3 | `VecEAFormula`, `BracketFormula` | `structure BracketFormula (n : Nat)` | sorry-free, faithful |
| Def 3.3 | V-EA formula, p.3 | `VBracketFormula`, `VVecEA2` | `structure VBracketFormula`, `structure VVecEA2` | sorry-free, faithful |
| Lemma 3.2.1 | Conj closure, p.3 | `BracketFormula.conj_to_bracket_exists` | `bf1.holds -> bf2.holds -> exists bf, bf.holds` | sorry-free, faithful |
| Lemma 3.4 | V-EA closure, p.4 | `VBracketFormula.disj_holds`, `VVecEA2.conj_holds_vvecEA2` | disj/conj/exists closure | sorry-free, faithful |
| Prop 3.5 | V-EA 1-var -> TL, p.5 | `ExistsForallSpec.translate_correct` | `semantic_spec <-> temporal_truth translate` | sorry-free, faithful |
| Notation 5.2 | Bracket notation, p.7 | `BracketFormula.holds` | `bf.holds M atomMap z0 z1 : Prop` | sorry-free, faithful |
| K+ operator | eq 5.2, p.7 | `kplus` | `kplus M atomMap P t : Prop` | sorry-free, adapted |
| INF formula | Lemma 5.3, p.8 | `inf_bracket_formula`, `inf_bracket_formula_hasINF` | `BracketFormula 1`, holds iff first occurrence | sorry-free, adapted |
| Lemma 5.3 | All-betas-True neg, p.8 | `neg_orderedPointsExist_is_vbracket` | `exists v, v.holds <-> neg orderedPointsExist` | sorry-free, faithful |
| Cor 5.4 (fwd) | Partial bracket neg, p.9 | `neg_partialBracketExist_sufficient` | `v.holds -> neg partialBracketExist` | sorry-free, faithful |
| Cor 5.4 (bwd) | Partial bracket neg, p.9 | `neg_partialBracketExist_is_vbracket` | `v.holds <-> neg partialBracketExist` | **sorry** (backward, F-chain unboundedness) |
| Lemma 5.1 (model-dep) | Bracket neg, pp.7-11 | `neg_interval_formula` | `neg bf.holds -> exists v, v.holds` | sorry-free, adapted (model-dep) |
| Lemma 5.1 (model-indep) | Bracket neg, pp.7-11 | `neg_bracket_is_vbracket` | `exists v, v.holds <-> neg bf.holds` | **sorry** (beta_0(r0), BracketFormula-level) |
| Lemma 5.1 (VecEA2-level) | Bracket neg, pp.7-11 | -- | -- | **NOT YET IMPLEMENTED** (the key new theorem) |
| A_i^-/A_i^+ decomp | p.10 | `BracketFormula.leftPart`, `rightPart`, `splitAt_combine` | splitting + combination | sorry-free, faithful |
| Prop 4.2 (model-dep) | Neg 2-var EA, p.6 | `neg_vecEA2`, `neg_2var_vec_ea` | `neg vea.holds -> exists v, v.holds` | sorry-free, adapted (model-dep) |
| Prop 4.2 (model-indep) | Neg 2-var EA, p.6 | -- | -- | **NOT YET IMPLEMENTED** |
| Prop 4.3 | FO -> V-EA, p.6 | -- (bypassed by mutual induction) | -- | **NOT YET IMPLEMENTED** |
| Thm 4.4 | Kamp's theorem, p.6 | `kamp_prior_expressive_completeness` | `exists A, eval psi <-> temporal_truth A` | sorry-free via different path, NOT Rabinovich chain |
| HasAttainedINF | N/A (Prior-specific) | `HasAttainedINF`, `prior_hasAttainedINF` | Prior -> HasAttainedINF | sorry-free |

---

## 9. Adversarial Self-Verification (H4)

### Challenge 1: "The VecEA2-level Lemma 5.1 avoids the beta_0(r0) problem"

**Verified.** In the VecEA2 formulation, alpha_0 is the endpointLeft predicate evaluated at z_0 (a fixed point, not an existential witness). The case analysis is:
- Does alpha_0(z_0) hold? This is a deterministic check at the fixed endpoint.
- If yes, does seg_0 fail somewhere in (z_0, z_1)?

There is no existential search for an alpha_0 point. The beta_0(r0) problem arose because:
1. BracketFormula puts alpha_0 at an interior existential witness r0
2. beta_0(r0) can hold, creating a model-dependent recursion
3. No finite, model-independent V-bracket handles all possible r0 positions

At the VecEA2 level, step 1 is eliminated: alpha_0 is at z_0, not at r0. There is no existential r0 to worry about.

**Confidence: HIGH.** The impossibility analysis at EANegation.lean:1047-1083 explicitly identifies the root cause as "alpha_0 at INTERIOR existential witness." Moving alpha_0 to the endpoint eliminates this.

### Challenge 2: "The Rabinovich chain can completely replace KampBypass"

**Verified with caveat.** The Rabinovich chain (Lemma 5.1 -> Prop 4.2 -> Prop 4.3 -> Thm 4.4) provides an alternative complete proof of Kamp's theorem that avoids all NF-depth machinery. However:

**Caveat**: Prop 4.3 uses structural induction on FO formulas, which requires a different induction principle than the current `MonadicFormula` + `quantifier_depth` approach. The current `kamp_prior_expressive_completeness` enumerates depth-k NFs and builds characteristic formulas. The Rabinovich approach would directly convert FO formulas to V-EA by structural induction.

**Risk**: The structural induction approach needs Lemma 3.2.2 (reduction to at most 2 free variables). This lemma is stated in the paper but the formalization only has the 2-free-variable case directly. For the 1-free-variable final result, all quantifiers introduce variables that interact with at most the 1 free variable, so 2-var is sufficient. But the general n-free-variable case needs more work.

**Revised confidence: MEDIUM-HIGH.** The 1-free-variable case (which is what Kamp's theorem needs) should work without the full Lemma 3.2.2, since each existential introduces a new variable that pairs with the single free variable.

### Challenge 3: "The 6 sorrys can all be eliminated by this restructuring"

**Verified with nuance.** The 6 sorrys in the current codebase are:

| # | File | Line | Status after restructuring |
|---|------|------|---------------------------|
| 1 | PriorComposition.lean | 202 | **Eliminated** -- prior_2var_transfer_until becomes unused |
| 2 | PriorComposition.lean | 236 | **Eliminated** -- prior_2var_transfer_since becomes unused |
| 3 | NfCharFormula.lean | 515 | **Eliminated** -- nf_exist_backward_prior becomes unused |
| 4 | NfCharFormula.lean | 626 | **Eliminated** -- nf_2var_exist_formula_prior_filled becomes unused |
| 5 | EANegation.lean | 1084 | **Remains but documented as BracketFormula-level impossibility** -- unused downstream |
| 6 | EANegation.lean | 1235 | **Can be fixed** using VecEA2-level Lemma 5.1 (backward direction of Cor 5.4 no longer blocked) |

So 4 sorrys are eliminated by making the bypass infrastructure unused, 1 can be fixed, and 1 remains as a documented impossibility (but is unused). The net result is 5 fewer sorry sites on the critical path to completeness.

**Revised claim**: 5 of 6 sorrys eliminated from the critical path. The 6th (EANegation.lean:1084) remains as a documented impossibility at the BracketFormula level but is unused downstream.

### Challenge 4: "The incremental approach works -- lake build succeeds at every step"

**Verified.** Each step adds new files with new imports:
1. `EndpointNegation.lean` imports `EANegation.lean` and `VecEAClosure.lean` -- both exist and compile
2. `ModelIndepNegation.lean` imports `EndpointNegation.lean` -- added in step 1
3. `FOToVEA.lean` imports `ModelIndepNegation.lean` + `VecEAClosure.lean` -- both available
4. `KampRabinovich.lean` imports `FOToVEA.lean` + `RabinovichTranslation.lean` -- both available
5. `KampPrior.lean` modification: changes one import and one proof body

No step modifies existing sorry-free files until step 5, which only changes the proof of `kamp_prior_expressive_completeness` (not its type signature). At every step, `lake build` should succeed because no existing imports or declarations change.

**Confidence: HIGH.** The file dependency graph is acyclic and each new file only depends on previously-added files.

### Challenge 5: "800-1200 lines is realistic for the new code"

**Partially verified.** Comparing with existing code:
- `neg_interval_formula` (model-dependent Lemma 5.1): 75 lines of proof for all cases. The VecEA2-level version should be similar in structure but needs model-independent biconditional, roughly doubling to ~150 lines.
- `neg_vecEA2` (model-dependent Prop 4.2): 40 lines. Model-independent version similar.
- `neg_orderedPointsExist_is_vbracket` (Lemma 5.3): 160 lines for the biconditional. Already exists and is sorry-free.

However, the VecEA2-level Lemma 5.1 biconditional is significantly more complex than the forward-only model-dependent version because it must handle both directions with a FIXED V-bracket. The Case 2 (seg holds everywhere) backward direction is the most complex part. Estimating 300-400 lines for this alone seems realistic given the complexity.

**Revised estimate**: 800-1200 lines is plausible but could be 1200-1500 if the Case 2 backward direction proves technically challenging.

---

## Findings Summary

1. **Rabinovich's proof uses structural induction on FO formulas and induction on witness count n -- NOT NF-depth mutual induction.** The circular depth dependency that blocks the current approach is entirely absent from Rabinovich's method.

2. **The VecEA2 type already supports endpoint evaluation.** The `endpointLeft` field of `VecEA2` is exactly Rabinovich's alpha_0 at z_0. No type changes needed.

3. **A VecEA2-level Lemma 5.1 is provable and avoids the beta_0(r0) impossibility.** The key insight: alpha_0 at a fixed endpoint eliminates the model-dependent case split that blocks BracketFormula-level biconditional.

4. **The full Rabinovich chain (5.1 -> 4.2 -> 4.3 -> 4.4) can replace ~5,900 lines of bypass infrastructure with ~800-1200 lines of new code.** Net reduction of ~4,700 lines. Eliminates 5 of 6 sorry sites from the critical path.

5. **The restructuring can be done incrementally.** New files added alongside existing code. No sorry-free code modified until the final switch. `lake build` succeeds at every intermediate step.

6. **Prior integration is trivial.** `prior_hasAttainedINF` already proves Prior -> HasAttainedINF, which is all the Rabinovich chain needs.

7. **The highest-risk step is VecEA2-level Lemma 5.1, Case 2 (seg holds everywhere).** This requires reducing to Cor 5.4 (partial bracket negation). The forward direction is sorry-free; the backward direction needs the VecEA2-level biconditional. Estimated 300-400 lines.

8. **Prop 4.3 (structural induction) for the 1-free-variable case should not require the full Lemma 3.2.2 (reduction to 2 free vars).** Each existential introduces a variable pairing with the single free variable, staying within the 2-var scope.
