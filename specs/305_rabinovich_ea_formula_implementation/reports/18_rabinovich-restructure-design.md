# Rabinovich-Faithful Restructure Design: Beta_0-Failure Case Split

- **Task**: 305 -- rabinovich_ea_formula_implementation
- **Type**: lean4
- **Agent**: lean-research-hard-agent
- **Date**: 2026-06-23
- **Session**: sess_1782258146_ff0e8d
- **Tier**: 3 (implementation-backed, Rabinovich paper as reference)
- **Artifact**: 18

---

## H3 Reference Grounding: Lemma-Level Mapping Table

| Rabinovich Concept | Prop/Location | Lean 4 Identifier | Type Signature | Status |
|---|---|---|---|---|
| Bracket notation [alpha,beta,...](z0,z1) | Notation 5.2 | `BracketFormula n` | `structure { pointTypes : Fin n -> TemporalPred, segmentTypes : Fin (n+1) -> TemporalPred }` | EXISTS (VecEAFormula.lean) |
| V-bracket formula (disjunction) | Def 3.3 | `VBracketFormula` | `structure { disjuncts : List (Sigma n, BracketFormula n) }` | EXISTS (VecEAFormula.lean) |
| Lemma 5.1 forward (model-dep) | pp.7-11 | `neg_interval_formula` | `HasAttainedINF -> ... -> not bf.holds -> exists v, v.holds` | SORRY-FREE (EANegationClosure.lean:247) |
| Lemma 5.1 forward (model-indep) | pp.7-11 | `neg_interval_formula_indep_correct` | `... -> not bf.holds -> (neg_interval_formula_indep n bf).holds` | SORRY-FREE (NegationIndep.lean:89) |
| Lemma 5.1 biconditional | pp.7-11 | `neg_bracket_is_vbracket` | `... -> exists v, v.holds <-> not bf.holds` | SORRY at line 1084 (EANegation.lean) |
| Corollary 5.4 forward (model-dep) | p.10 | `neg_bounded_exists` | `HasAttainedINF -> ... -> not (exists z, bf.holds z0 z) -> exists v, v.holds` | SORRY-FREE (EANegationClosure.lean:338) |
| Corollary 5.4 biconditional | p.9 | `neg_partialBracketExist_is_vbracket` | `... -> exists v, v.holds <-> not bf.partialBracketExist` | SORRY at line 1235 (EANegation.lean) |
| Prop 4.2 forward (model-dep) | p.6 | `neg_2var_vec_ea` | `HasAttainedINF -> ... -> not v.holds -> exists v', v'.holds` | SORRY-FREE (EANegationClosure.lean:566) |
| Prop 4.2 forward (model-indep) | p.6 | `neg_2var_vec_ea_indep_correct` | `... -> not v.holds -> (neg_2var_vec_ea_indep v).holds` | SORRY-FREE (NegationIndep.lean:316) |
| INF bracket formula | p.9 | `inf_bracket_formula` | `TemporalPred -> BracketFormula 1` | EXISTS (EANegationClosure.lean:179) |
| BracketFormula.tail | implicit | `BracketFormula.tail` | `BracketFormula (n+1) -> BracketFormula n` | EXISTS (EANegationClosure.lean:78) |
| First occurrence (HasAttainedINF) | implicit | `HasAttainedINF.first_occ_tp` | `... -> exists r0, z0 < r0 /\ ... /\ P r0 /\ (forall y, ... -> not P y)` | EXISTS (EANegationClosure.lean:58) |
| Prepend witness to bracket | implicit | `BracketFormula.prepend_holds` | `... -> bf.holds r0 z1 -> (bf.prepend segLeft ptType).holds z0 z1` | EXISTS (EANegation.lean) |
| Prepend inverse | implicit | `BracketFormula.prepend_holds_inv` | `... -> (bf.prepend segLeft ptType).holds z0 z1 -> exists r0, ...` | EXISTS (EANegation.lean:223) |
| Beta_0 failure bracket (NEW) | Case 3 analog | `neg_b2_bracket_formula` | `TemporalPred -> TemporalPred -> BracketFormula 2` | PROPOSED |
| Bounded-exists negation indep (NEW) | Cor 5.4 indep | `neg_bounded_exists_indep` | `Nat -> BracketFormula n -> VBracketFormula` | PROPOSED |

---

## 1. Problem Statement

The model-independent bracket negation construction `neg_interval_formula_indep` (NegationIndep.lean, lines 61-84) currently case-splits on **alpha_0 occurrence** (whether the first point type appears in the interval). The forward proof (`neg_interval_formula_indep_correct`) is sorry-free, but the backward direction (`V.holds -> not bf.holds`) is unprovable due to two structural gaps:

**Gap B.2**: `inf_bracket_formula(alpha_0)` is not disjoint from the original bracket. Concrete counterexample: `bf` with `pt(0)=P`, all segments=top on `(0,10)` with P at 5 makes both `bf.holds` (witness 5) and `inf_bracket_formula(P).holds` (witness 5, P.neg on (0,5)) simultaneously true.

**Gap B.1**: The IH gives `neg_interval_formula_indep(bf.tail).holds` on `(r0, z1)` where `r0` is the first alpha_0 occurrence, but the original bracket's witness `w_0` may satisfy `w_0 > r0`, so `bf.tail` failing on `(r0, z1)` does not imply `bf.tail` fails on `(w_0, z1)`.

Both gaps stem from the same root cause: the construction uses model-dependent split points (first alpha_0 occurrence) in a model-independent formula, creating mismatch between syntactic formulas and semantic witnesses.

The focus prompt asks for a restructuring that case-splits on **beta_0 failure** instead of alpha_0 occurrence, matching Rabinovich's actual proof structure.

---

## 2. Analysis: Why Beta_0-Failure Case Split Fixes B.1 But Creates a New Dependency

### 2.1 The Proposed Three Cases (Beta_0 Focus)

For `BracketFormula (n+1)` with `alpha_0 = bf.pointTypes(0)`, `beta_0 = bf.segmentTypes(0)`:

**Case A**: alpha_0 does NOT occur in `(z0, z1)`.
- Forward: trivially correct (bracket needs alpha_0 at some witness).
- Backward: alpha_0.neg everywhere -> any bracket witness w_0 has alpha_0(w_0) -> contradiction.
- VBracketFormula: `BracketFormula.trivial alpha_0.neg` (0 witnesses).
- **UNCHANGED from current construction.**

**Case B (new split)**: alpha_0 occurs in `(z0, z1)`. Sub-split on beta_0:

**Case B.2 (new)**: beta_0 FAILS somewhere in `(z0, z1)`.
- The `neg_b2_bracket_formula` (2-witness bracket, see Section 3) encodes: there exist `y < x` in `(z0, z1)` with `beta_0.neg(y)`, `alpha_0(x)`, and `alpha_0.neg` on `(z0, x)`.
- Forward: Given alpha_0 occurs, let `r0` = first alpha_0 via HasAttainedINF. Since beta_0 fails somewhere in `(z0, z1)` and `r0` is the first alpha_0, find the beta_0 failure point. If beta_0 fails at `y` in `(z0, r0)`: witnesses `(y, r0)` work directly. If beta_0 fails at `y` in `(r0, z1)`: witnesses `(y, ?)` -- but we also need an alpha_0 point after `y`. Use `r0` as alpha_0 point, but `r0 < y`. So we need to find an alpha_0 point AFTER `y`.

**CRITICAL ISSUE**: When beta_0 fails at `y > r0`, we cannot simply use `r0` as the alpha_0 witness because `r0 < y` and the formula needs `y < x`. We would need to find another alpha_0 point after `y`, which is not guaranteed.

**Wait -- re-read the requirement.** The `neg_b2_bracket_formula` encodes "beta_0 fails before the first alpha_0 point." If beta_0 fails somewhere in `(z0, z1)` but NOT in `(z0, r0)` (where `r0` = first alpha_0), then beta_0 only fails AFTER the first alpha_0. In that case, Case B.2 does NOT fire. Instead, beta_0 holds on `(z0, r0)` and we fall into Case B.1.

So the correct case split is:
- **Case B.1 (new)**: alpha_0 occurs AND beta_0 holds on ALL of `(z0, z1)`.
- **Case B.2 (new)**: alpha_0 occurs AND beta_0 FAILS somewhere in `(z0, z1)`.

But Case B.2 further sub-splits:
- **B.2a**: beta_0 fails in `(z0, r0)` where `r0` = first alpha_0. Then `neg_b2_bracket_formula` fires.
- **B.2b**: beta_0 holds on `(z0, r0)` but fails in `(r0, z1)`. This means beta_0 on `(z0, r0)` is satisfied, so the bracket's first segment condition is potentially met. The tail bracket from `r0` must fail on some sub-interval. But wait -- the bracket could have its first witness at `w_0 > r0`, and beta_0 fails at `y` in `(r0, w_0)`, killing the first segment. So in B.2b, the bracket still fails because `y > r0` is in `(z0, w_0)` for any `w_0 > y`.

Actually, B.2b is wrong. If `w_0 = r0`, then beta_0 on `(z0, r0)` is satisfied and the first segment condition holds. The bracket needs `bf.tail` to hold on `(r0, z1)`. Whether the bracket holds depends on the tail, not on beta_0 failing after `r0`.

**Revised correct sub-split**: The case split should be:
1. alpha_0 does NOT occur -> Case A
2. alpha_0 occurs; let `r0` = first alpha_0:
   - 2a. beta_0 fails on `(z0, r0)` -> B.2 (neg_b2_bracket_formula)
   - 2b. beta_0 holds on `(z0, r0)` -> B.1 (IH on tail from `r0`)

This is **exactly the current construction's case split**. The only change is in B.2: replace `inf_bracket_formula(alpha_0)` with `neg_b2_bracket_formula(alpha_0, beta_0)`.

### 2.2 Re-Examining the B.1 Gap Under the Restructured B.2

With the fixed B.2, let us re-examine whether B.1's backward direction works.

B.1 produces: `VBracketFormula.prependAll alpha_0.neg alpha_0 ih` where `ih = neg_interval_formula_indep n bf.tail`.

**B.1 Forward** (have, sorry-free): Given alpha_0 occurs at `r0` (first), beta_0 on `(z0, r0)`, and `not bf.tail.holds r0 z1`, the IH gives `neg_interval_formula_indep(bf.tail).holds r0 z1`. Prepending `r0` with `alpha_0` point type and `alpha_0.neg` segment gives a bracket holding on `(z0, z1)`.

**B.1 Backward** (the gap): Suppose a B.1 disjunct `bf_v.prepend(alpha_0.neg, alpha_0)` holds on `(z0, z1)`. By `prepend_holds_inv`, we get `r0` with:
- `alpha_0(r0)`, `alpha_0.neg` on `(z0, r0)`, `bf_v.holds(r0, z1)`
- By IH backward (if it exists): `not bf.tail.holds(r0, z1)`

Now suppose `bf.holds(z0, z1)` with witnesses `w_0 < ... < w_n`:
- `alpha_0(w_0)` and `alpha_0.neg` on `(z0, r0)` means `w_0 >= r0`
- If `w_0 = r0`: then `bf.tail.holds(r0, z1)` (from the bracket witnesses `w_1, ..., w_n`), contradicting IH backward.
- If `w_0 > r0`: then `bf.tail.holds(w_0, z1)`, but IH backward only says `bf.tail` fails on `(r0, z1)`, not on `(w_0, z1)`. **This is still a gap.**

### 2.3 The B.1 Gap Is Fundamental (Not Fixable by B.2 Change Alone)

The B.1 backward gap exists because `bf.tail` failing on `(r0, z1)` does NOT imply `bf.tail` failing on `(w_0, z1)` for `w_0 > r0`. The bracket `bf.tail` could hold on `(w_0, z1)` (a smaller interval) while failing on `(r0, z1)` (a larger interval) -- the additional points in `(r0, w_0)` could contain witnesses that make `bf.tail` fail on the larger interval.

Wait, that is backwards. If `bf.tail.holds(w_0, z1)`, the witnesses are in `(w_0, z1) subset (r0, z1)`. So `bf.tail` would also hold on... no, `bf.tail.holds` is evaluated from the LEFT endpoint. `bf.tail.holds(w_0, z1)` means witnesses in `(w_0, z1)` with `bf.tail.segmentTypes(0)` on `(w_0, first_witness)`. But `bf.tail.holds(r0, z1)` would use the same witnesses, with `bf.tail.segmentTypes(0)` now needing to hold on `(r0, first_witness)` -- a LARGER segment. Since the segment is (r0, first_witness) superset (w_0, first_witness), the segment condition is HARDER for the (r0, z1) interval.

So `bf.tail.holds(w_0, z1)` does NOT imply `bf.tail.holds(r0, z1)` -- in fact the reverse monotonicity holds. And `not bf.tail.holds(r0, z1)` does NOT imply `not bf.tail.holds(w_0, z1)`.

**This confirms the B.1 gap is fundamental.** The current construction structure (alpha_0-occurrence-first, then beta_0 on prefix) inherently creates this interval mismatch.

### 2.4 Why Rabinovich's Approach Avoids Both Gaps

In Rabinovich's convention, `alpha_0` is at the **endpoint** `z_0`, not an interior witness. His case split on beta_1 (first segment type) works because:

- **Case 2** (beta_1 everywhere): Reduces to "no z in `(z_0, z_1)` with tail bracket" -- this is exactly `neg partialBracketExist`, i.e., Corollary 5.4. The interval for the bounded existential is `(z_0, z_1)` -- the SAME interval, no mismatch.

- **Case 3** (beta_1 fails at some point): The INF formula finds where beta_1 fails at `z`. For any bracket witness, beta_1 must hold on `(z_0, w_1)`, so `w_1 >= z`. The tail bracket from `z` then gives a strictly smaller problem. The key is that `z` is an INTERIOR point (not an existential bracket witness), so the interval `(z, z_1)` for the IH is well-defined independently of the bracket's witnesses.

In the codebase's convention, `alpha_0` is interior, which means:
- The "does alpha_0 occur" question already introduces a model-dependent split point.
- The tail bracket's interval depends on which alpha_0 point is chosen.

### 2.5 The True Restructuring Required

To match Rabinovich exactly while respecting the codebase's interior-witness convention, we need to restructure the case analysis to avoid depending on the first alpha_0 occurrence as a split point for the IH interval. The approach:

**Case A**: alpha_0 does not occur -> trivial (unchanged).

**Case B.2**: beta_0 fails somewhere in `(z0, z1)`. Let `s` = first beta_0 failure. Then:
- alpha_0 does not occur in `(z0, s)` (since if it did, and beta_0 holds on `(z0, s)`, then beta_0.neg(s) with s being the first failure means the bracket's first segment from z0 to any alpha_0 point includes a beta_0 failure). Actually, we DON'T know alpha_0 doesn't occur in `(z0, s)`.
- Hmm, this is not the right approach either.

**Alternative restructuring** (matching Rabinovich Case 2/3 directly):

Since the codebase convention puts alpha_0 at interior witnesses, we translate Rabinovich's Cases as:

**Case B.1 (beta_0 everywhere)**: beta_0 holds on ALL of `(z0, z1)`. Then `bf.holds(z0, z1)` iff there exists `w_0` in `(z0, z1)` with `alpha_0(w_0)` and `bf.tail.holds(w_0, z1)` (since beta_0 on `(z0, w_0)` is automatic). This is `bf.partialBracketExist_tail(z0, z1)` -- a bounded existential over the first witness. The negation is: for all `w_0` in `(z0, z1)`, either `not alpha_0(w_0)` or `not bf.tail.holds(w_0, z1)`. This is Corollary 5.4 applied to a modified bracket.

**Wait -- this is exactly right.** When beta_0 holds everywhere in `(z0, z1)`, the bracket `bf` reduces to:
```
exists w_0 in (z0, z1), alpha_0(w_0) AND bf.tail.holds(w_0, z1)
```
because the first segment condition beta_0 on `(z0, w_0)` is automatically satisfied.

The negation becomes:
```
forall w_0 in (z0, z1), not alpha_0(w_0) OR not bf.tail.holds(w_0, z1)
```

This is NOT exactly `partialBracketExist` because `partialBracketExist` has `bf.holds(z0, z)` (bracket from z0 to z), whereas here we have `bf.tail.holds(w_0, z1)` (bracket from w_0 to z1).

Define: `tailBracketExist bf z0 z1 := exists w in (z0, z1), alpha_0(w) AND bf.tail.holds(w, z1)`.

The negation of `tailBracketExist` is: for all `w` in `(z0, z1)`, `not alpha_0(w)` or `not bf.tail.holds(w, z1)`.

This is a universal quantifier over an interval -- it can be expressed as a VBracketFormula via the same technique as Corollary 5.4, but with the bracket extending from `w` to `z1` rather than from `z0` to `w`.

**Case B.2 (beta_0 fails)**: beta_0.neg occurs somewhere in `(z0, z1)`. Let `s` = first beta_0.neg via HasAttainedINF. Then beta_0 holds on `(z0, s)` and beta_0.neg(s). For any bracket witness arrangement, if `w_0 > s`, then `s` is in `(z0, w_0)` and beta_0.neg(s) contradicts beta_0 on `(z0, w_0)`. If `w_0 <= s`, then beta_0 on `(z0, w_0)` is satisfied (since beta_0 holds on `(z0, s)` and `w_0 <= s`).

So with `w_0 <= s`: alpha_0(w_0), beta_0 on `(z0, w_0)`, and `bf.tail.holds(w_0, z1)`. The tail bracket on `(w_0, z1)` must hold with witnesses `w_1, ..., w_n`.

Now we need the negation to cover: for all possible w_0 with alpha_0(w_0) in `(z0, s]`:
- If `w_0 = s`: alpha_0(s) and bf.tail.holds(s, z1). The tail has first segment type beta_1 = bf.segmentTypes(1).
- If `w_0 < s`: alpha_0(w_0) and bf.tail.holds(w_0, z1).

This is again a bounded existential negation problem, but now bounded to `(z0, s]` instead of `(z0, z1)`.

**Hmm, this decomposition is getting complex.** Let me step back and think about this differently.

---

## 3. The neg_b2_bracket_formula Fix (Self-Contained)

Report 17 proposed `neg_b2_bracket_formula(alpha_0, beta_0) : BracketFormula 2` as a replacement for `inf_bracket_formula(alpha_0)` in Case B.2. This encodes:

```lean
def neg_b2_bracket_formula (alpha_0 beta_0 : TemporalPred) : BracketFormula 2 :=
  { pointTypes := fun i => if i.val = 0 then beta_0.neg else alpha_0
    segmentTypes := fun i =>
      if i.val <= 1 then alpha_0.neg else TemporalPred.top }
```

Semantics: "there exist `y < x` in `(z0, z1)` with `beta_0.neg(y)`, `alpha_0(x)`, `alpha_0.neg` on `(z0, y)` and `(y, x)`, `top` on `(x, z1)`."

This means x is the first alpha_0 point (since alpha_0.neg on all of (z0, x)), and y is a beta_0 failure before the first alpha_0.

### 3.1 B.2 Forward Proof (with neg_b2_bracket_formula)

Given: alpha_0 occurs at first occurrence `r0`, beta_0 fails on `(z0, r0)`.
- Find beta_0 failure point `y` in `(z0, r0)` (exists by hypothesis).
- Set witness_0 = y, witness_1 = r0.
- beta_0.neg(y): by hypothesis.
- alpha_0(r0): by first occurrence.
- alpha_0.neg on `(z0, y)`: since `y < r0` and `r0` is first alpha_0.
- alpha_0.neg on `(y, r0)`: same reasoning.
- top on `(r0, z1)`: trivial.

**Status: straightforward, ~30 lines.**

### 3.2 B.2 Backward Proof (with neg_b2_bracket_formula)

Given: `neg_b2_bracket_formula(alpha_0, beta_0).holds(z0, z1)`.
Suppose `bf.holds(z0, z1)` with witnesses `w_0 < ... < w_n`.

From neg_b2_bracket_formula: get `y < x` with `beta_0.neg(y)`, `alpha_0(x)`, `alpha_0.neg` on `(z0, x)`.
From bf.holds: `alpha_0(w_0)` and `beta_0` on `(z0, w_0)`.

Since `alpha_0.neg` on `(z0, x)` and `alpha_0(w_0)`: `w_0 >= x`.
Since `z0 < y < x <= w_0`: `y` is in `(z0, w_0)`.
But `beta_0.neg(y)` contradicts `beta_0` on `(z0, w_0)`.

**Status: straightforward, ~20 lines. This is a clean contradiction.**

### 3.3 Combined Assessment

Replacing `inf_bracket_formula(alpha_0)` with `neg_b2_bracket_formula(alpha_0, beta_0)` in Case B.2 fixes the B.2 backward gap. The forward proof requires a minor change (use `neg_b2_bracket_formula_hasINF` instead of `inf_bracket_formula_hasINF`).

**But B.1 backward remains broken.** See Section 2.3.

---

## 4. The B.1 Backward Gap: A Fundamental Interval Mismatch

### 4.1 The Problem

The B.1 disjunct `bf_v.prepend(alpha_0.neg, alpha_0)` holds on `(z0, z1)` with a prepend witness at some `r0`. By IH backward (assuming it exists for bf.tail), `bf.tail` fails on `(r0, z1)`. But the original bracket `bf` could hold with `w_0 > r0`, using `bf.tail` on `(w_0, z1)` which is a different interval.

### 4.2 Why the Forward Proof Works But Backward Doesn't

The forward proof chooses `r0` = first alpha_0 occurrence, so ANY bracket witness `w_0` satisfies `w_0 >= r0`. When `w_0 = r0`, the tail contradiction applies directly. When `w_0 > r0`, the beta_0 segment `(z0, w_0)` includes `(z0, r0)` where beta_0 holds (by B.1 hypothesis), but also `(r0, w_0)` -- and we know nothing about beta_0 on `(r0, w_0)`.

Wait, actually the forward proof does NOT use the IH backward at all. Let me re-read:

The **forward** direction of `neg_interval_formula_indep_correct` (NegationIndep.lean, lines 119-172) assumes `not bf.holds(z0, z1)` and shows `neg_interval_formula_indep.holds(z0, z1)`. For B.1: assumes alpha_0 occurs at first `r0`, beta_0 on `(z0, r0)`, so `bf.tail` must fail on `(r0, z1)` (by contrapositive of `bracket_tail_satisfiable`). By IH forward, `neg_interval_formula_indep(bf.tail).holds(r0, z1)`. Prepend to get the B.1 disjunct holding on `(z0, z1)`.

This is correct. The issue is only in the backward direction.

### 4.3 Root Cause: The IH Backward Requires a Specific Interval

The B.1 backward proof needs: "neg_interval_formula_indep(bf.tail).holds(r0, z1) implies bf.tail fails on (w_0, z1) for ALL w_0 >= r0."

This is a MONOTONICITY property: if the negation VBracketFormula holds on `(r0, z1)`, it should also hold on `(w_0, z1)` for `w_0 >= r0`, and this should imply `bf.tail` fails on `(w_0, z1)`.

The first part (monotonicity of V-bracket holds) is FALSE in general. A VBracketFormula that holds on a larger interval may not hold on a sub-interval.

For example, `neg_interval_formula_indep(bf.tail)` on `(r0, z1)` could have a disjunct with a witness in `(r0, w_0)`, which doesn't exist in `(w_0, z1)`.

**This is why the B.1 backward direction is broken regardless of the B.2 fix.**

---

## 5. Corollary 5.4 Biconditional Analysis

### 5.1 Current State

`neg_partialBracketExist_is_vbracket` (EANegation.lean:1123) attempts to prove:
```lean
exists v, v.holds <-> not bf.partialBracketExist
```
where `partialBracketExist M atomMap bf z0 z1 := exists z, z0 < z /\ z < z1 /\ bf.holds M atomMap z0 z`.

The `n = 0` case is fully proved (biconditional). The `n >= 1` case has:
- Forward (V.holds -> not partialBracketExist): proved via `neg_partialBracketExist_sufficient`.
- Backward (not partialBracketExist -> V.holds): **sorry** (line 1235).

### 5.2 Why the Backward is Hard

The backward direction needs: "if no z in (z0, z1) has bf.holds(z0, z), show V.holds(z0, z1)."

The existing `neg_partialBracketExist_sufficient` uses the F-chain predicate: it constructs a VBracketFormula from `neg_orderedPointsExist_is_vbracket 1 (fun _ => bf.fChainPred)`, where `fChainPred` encodes the chain `alpha_0 AND (beta_1 U (alpha_1 AND ...))`.

For the forward direction: V.holds implies no ordered-point with fChainPred, which implies no partial bracket exist (because bracket implies fChainPred witness).

For the backward direction: not partialBracketExist needs to imply V.holds. Contrapositively: not V.holds implies partialBracketExist. Not V.holds means orderedPointsExist 1 fChainPred -- there exists x0 with fChainPred(x0). FChainPred(x0) = alpha_0(x0) AND (beta_1 U (alpha_1 AND ...)). The Until witness `s` satisfies `alpha_1(s) AND ...` with `beta_1` on `(x0, s)`. But `s` is NOT bounded by `z1` -- it could be outside `(z0, z1)`.

**This is the Until-unboundedness issue**: the F-chain Until witnesses are not interval-bounded.

### 5.3 Fixing Corollary 5.4

The Corollary 5.4 biconditional could be fixed by either:

**Option A**: Use a different V-bracket construction that avoids the F-chain. Instead of encoding the negation of partialBracketExist via F-chain negation, use the induction structure of neg_interval_formula directly. Define:

```lean
def neg_partialBracketExist_indep (n : Nat) (bf : BracketFormula n) : VBracketFormula
```

that constructs a V-bracket for `not (exists z in (z0,z1), bf.holds z0 z)`.

**Option B**: Prove that on HasAttainedINF structures, the F-chain Until witnesses CAN be bounded. This would require showing that `fChainPred(x0)` with `x0 in (z0, z1)` implies the Until witnesses are also in `(z0, z1)`.

**Option C**: Use a mutual induction between Lemma 5.1 and Corollary 5.4 that avoids both the B.1 gap and the Until-unboundedness issue.

### 5.4 Option C: Mutual Induction (Rabinovich's Actual Structure)

Rabinovich's proof of Lemma 5.1 USES Corollary 5.4 in Case 2 (beta_1 everywhere). And Corollary 5.4 is proved USING Lemma 5.1 (induction step). This is a mutual induction on n.

In the codebase, if we restructure `neg_interval_formula_indep` to case-split on beta_0 failure:
- Case A: alpha_0 doesn't occur (unchanged)
- Case B.2: beta_0 fails (use `neg_b2_bracket_formula`, fixed by Section 3)
- Case B.1: beta_0 holds everywhere AND alpha_0 occurs -> reduces to `tailBracketExist` negation (Corollary 5.4 analog)

And `neg_partialBracketExist_indep` (Corollary 5.4) would:
- For n = 0: trivial
- For n >= 1: case-split using Lemma 5.1 on the tail bracket, giving a mutual induction

The mutual induction parameter is `n` (number of witnesses in the bracket formula):
- `neg_interval_formula_indep(n+1, bf)` calls `neg_tailBracketExist_indep(n, bf.tail)`
- `neg_tailBracketExist_indep(n, bf)` calls `neg_interval_formula_indep(n, bf)` or `neg_tailBracketExist_indep(n-1, bf.tail)`

But wait -- `neg_tailBracketExist_indep(n, bf)` for `BracketFormula n` with alpha_0 occurring: the tail bracket has `n-1` witnesses. So `neg_interval_formula_indep` is called on `BracketFormula (n-1)`, which is a smaller problem. And `neg_tailBracketExist_indep(n-1, bf.tail)` is called on `BracketFormula (n-1)`, also smaller. So the mutual recursion terminates.

**However, this does NOT fix the B.1 backward gap.** The issue remains: the Corollary 5.4 analog produces a V-bracket whose backward direction has the same interval mismatch problem (the bounded existential's witness determines the sub-interval, and different witnesses give different intervals).

---

## 6. The Fundamental Obstacle: Model-Independent Biconditionals

### 6.1 Why Both Gaps Are Unfixable at BracketFormula Level

The B.1 backward gap and the Corollary 5.4 backward gap share the same root cause: a model-independent V-bracket formula encodes a FIXED syntactic pattern, but the backward direction requires reasoning about ALL possible witness arrangements, which vary per model.

Specifically, for the B.1 backward direction:
- The V-bracket says "there exists `r0` with alpha_0(r0) and IH-negation on `(r0, z1)`"
- The original bracket says "there exists `w_0` with alpha_0(w_0) and tail on `(w_0, z1)`"
- `r0` and `w_0` are potentially different points

For the negation to be a biconditional, we need: "IH-negation on `(r0, z1)`" implies "bf.tail fails on `(w_0, z1)`" for all valid `w_0`. This requires the IH-negation V-bracket to express a condition that's UNIVERSALLY quantified over all alpha_0 points -- but a V-bracket is an EXISTENTIALLY quantified statement.

### 6.2 This Is the Same Obstruction Documented in EANegation.lean:1047-1083

The sorry at EANegation.lean:1084 documents this exact obstruction. The comment says:

> Adding a CaseE with alpha_0.conj beta_0 at r0 would fix the backward direction, but breaks the forward direction: A CaseE disjunct on (z0, z1) decomposes to give r0 with IH-bracket on (r0, z1). For the forward direction (CaseE.holds -> not bf.holds), we need to show: for ALL x0 with alpha_0(x0) and seg_0 on (z0, x0), rightPart fails at (x0, z1). The IH gives not-rightPart at (r0, z1), but says nothing about x0 > r0.

### 6.3 Assessment: The Model-Independent Biconditional at BracketFormula Level Is Unprovable

The model-independent biconditional `neg_bracket_is_vbracket` and `neg_partialBracketExist_is_vbracket` are both unprovable at the BracketFormula level with the codebase's interior-witness convention. The obstruction is structural: V-bracket formulas are existentially quantified, but the backward direction requires universal quantification over model-dependent witness arrangements.

**The B.2 fix alone is insufficient** -- it fixes one of two gaps, but B.1 remains.

**The beta_0-failure restructuring is insufficient** -- it reorganizes the cases but doesn't eliminate the fundamental existential-vs-universal mismatch.

---

## 7. Viable Paths Forward

### 7.1 Path A: Accept Forward-Only and Use Model-Dependent for Completeness

**Status**: Already implemented and sorry-free.

The model-dependent theorems (`neg_interval_formula`, `neg_bounded_exists`, `neg_2var_vec_ea` in EANegationClosure.lean) are all sorry-free. The model-independent forward-only theorems (`neg_interval_formula_indep_correct`, `neg_2var_vec_ea_indep_correct` in NegationIndep.lean) are also sorry-free.

The sorry in `neg_bracket_is_vbracket` (EANegation.lean:1084) and `neg_partialBracketExist_is_vbracket` (EANegation.lean:1235) do NOT block completeness because the completeness proof uses the model-dependent versions.

**Impact on plan v31**: Plan v31's VecEA_m approach (Phase 1, currently BLOCKED) needs `neg_2var_vec_ea_indep_backward`. This backward direction is ALSO unprovable with the current construction (same root cause).

### 7.2 Path B: VecEA2-Level Biconditional Via Endpoint Absorption

At the VecEA2 level (not BracketFormula level), the biconditional might be provable because VecEA2 has **endpoint predicates**. The endpoint predicates add information that could resolve the model-dependent split:

A VecEA2 has `endpointLeft(z0) AND endpointRight(z1) AND bracket(z0, z1)`. When negating:
- Case 1a: not endpointLeft -> trivial VVecEA2 (just endpointLeft.neg)
- Case 1b: not endpointRight -> trivial VVecEA2 (just endpointRight.neg)
- Case 2: both endpoints hold, bracket fails -> need bracket negation

For Case 2, the backward direction at VecEA2 level would need: "if neg_vecEA2_indep(vea).holds(z0, z1), then not vea.holds(z0, z1)."

Cases 1a and 1b have trivial backward directions (the neg endpoint directly contradicts the original endpoint). Case 2 reduces to the BracketFormula level backward direction, which is the unsolved problem.

**So VecEA2-level does NOT help either.** The obstacle is at the BracketFormula level.

### 7.3 Path C: Semantic Biconditional Without Syntactic Fixed Point

Instead of producing a FIXED VVecEA2 that's a biconditional, prove the SEMANTIC statement:

```lean
theorem neg_2var_vec_ea_semantic :
    forall v : VVecEA2,
    exists v' : VVecEA2,
    forall M atomMap h_INF z0 z1 h_lt,
      v'.holds M atomMap z0 z1 <-> not v.holds M atomMap z0 z1
```

This is a stronger statement than the forward-only version but weaker than a syntactically-fixed biconditional. The `v'` is chosen using classical logic (axiom of choice), not constructively.

**This is actually provable**: For each model M, the model-dependent `neg_2var_vec_ea` gives a VVecEA2 that works. By compactness / definability arguments (or by explicit construction), a single VVecEA2 works for all models.

In fact, `neg_2var_vec_ea_indep v` is already a fixed VVecEA2 that works forward. The backward direction -- the claim that `neg_2var_vec_ea_indep(v).holds -> not v.holds` -- is the only missing piece.

### 7.4 Path D: Restructure BracketFormula to Match Rabinovich Convention

Add `endpointType` to BracketFormula: `alpha_0` at `z0` (the endpoint), with interior witnesses being `alpha_1, ..., alpha_n`. This makes the codebase match Rabinovich's notation exactly, eliminating the interior-witness mismatch.

**Cost**: Massive refactor of VecEAFormula.lean, ExistsForallNF.lean, EANegation.lean, EANegationClosure.lean, NegationIndep.lean, VecEAClosure.lean, and all downstream files. Estimated 1000+ lines changed.

**Not recommended** due to the amount of sorry-free code that would need rewriting.

### 7.5 Path E: Bypass Biconditional Via De Morgan (Plan v31 Modified)

Plan v31's VecEA_m approach uses de Morgan on a consecutive-pair product of VVecEA2 components. The negation of a conjunction is a disjunction of negations. Each component negation uses `neg_2var_vec_ea_indep` (forward-only). The question is whether the de Morgan approach also needs the backward direction.

For `VecEA_m.neg(v)` to be a biconditional:
```
VecEA_m.neg(v).holds <-> not v.holds
```
Expanding:
```
disj_i(neg_component_i.holds) <-> not (conj_i(component_i.holds))
```
By de Morgan:
```
disj_i(neg_component_i.holds) <-> disj_i(not component_i.holds)
```

This requires: `neg_component_i.holds <-> not component_i.holds` for each component. Which is exactly the VVecEA2 biconditional -- the same unsolved problem.

**Unless** we weaken to: `neg_component_i.holds <- not component_i.holds` (forward only). Then:
```
disj_i(neg_component_i.holds) <- disj_i(not component_i.holds) = not conj_i(component_i.holds) = not v.holds
```

This gives the forward direction of the VecEA_m negation. For the backward direction:
```
disj_i(neg_component_i.holds) -> not v.holds
```
This requires: for each i, `neg_component_i.holds -> not component_i.holds`. Which is the backward direction of the VVecEA2 biconditional -- the SAME unsolved problem.

**So plan v31 also needs the backward direction**, unless a different approach to negation is used.

---

## 8. Key Finding: The B.2 Fix Is Correct But Insufficient

### 8.1 What the B.2 Fix Achieves

- Replaces `inf_bracket_formula(alpha_0)` with `neg_b2_bracket_formula(alpha_0, beta_0)`
- Fixes the B.2 forward proof (minor surgical change)
- **Proves the B.2 backward direction** (new, ~20 lines)
- Does NOT fix the B.1 backward gap
- Does NOT fix the Corollary 5.4 backward sorry

### 8.2 Impact on Downstream

- `neg_interval_formula_indep_correct` (forward): minor change in Case B.2, remains sorry-free
- `neg_2var_vec_ea_indep_correct` (forward): unchanged, remains sorry-free
- `neg_bracket_is_vbracket` (biconditional): B.2 backward fixed, B.1 backward still has sorry
- `neg_partialBracketExist_is_vbracket` (biconditional): unchanged, still has sorry at n >= 1
- Plan v31 Phase 1: still BLOCKED (needs full backward direction, not just B.2)

### 8.3 Recommended Action

1. **Implement the B.2 fix** (`neg_b2_bracket_formula` and its proofs) as a standalone improvement. This makes the construction better and documents the B.1 gap more precisely.

2. **Do NOT attempt the full backward biconditional** at BracketFormula level. The B.1 gap is fundamental.

3. **For plan v31**: pursue the VecEA_m approach but acknowledge that de Morgan negation requires the component-level backward direction. Investigate whether the backward direction can be proved at VVecEA2 level using a different V-bracket construction than `neg_2var_vec_ea_indep`.

---

## 9. Concrete Type Signatures for the B.2 Fix

### 9.1 New Definition

```lean
/-- The B.2 bracket formula: encodes that beta_0 fails before the first alpha_0.
    Two witnesses: y (beta_0 failure) < x (first alpha_0).
    Segments: alpha_0.neg on (z_0, y) and (y, x), top on (x, z_1). -/
def neg_b2_bracket_formula (alpha_0 beta_0 : TemporalPred) : BracketFormula 2 :=
  { pointTypes := fun i => if i.val = 0 then beta_0.neg else alpha_0
    segmentTypes := fun i =>
      if i.val <= 1 then alpha_0.neg else TemporalPred.top }
```

### 9.2 Forward Correctness

```lean
/-- If alpha_0 occurs in (z0, z1) and beta_0 fails on (z0, first_alpha_0),
    then neg_b2_bracket_formula holds on (z0, z1). -/
theorem neg_b2_bracket_formula_hasINF
    {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (alpha_0 beta_0 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (r0 : M.carrier) (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPr0 : alpha_0.eval_at M atomMap r0)
    (h_neg_before : ∀ y, z0 < y → y < r0 → ¬alpha_0.eval_at M atomMap y)
    (h_seg_fail : ¬∀ y, z0 < y → y < r0 → beta_0.eval_at M atomMap y) :
    (neg_b2_bracket_formula alpha_0 beta_0).holds M atomMap z0 z1
```

### 9.3 Backward Correctness (Disjointness)

```lean
/-- If neg_b2_bracket_formula holds on (z0, z1) and bf has alpha_0 as its first
    point type and beta_0 as its first segment type, then bf cannot hold. -/
theorem neg_b2_bracket_formula_disjoint
    {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n : Nat} (bf : BracketFormula (n + 1))
    (alpha_0 beta_0 : TemporalPred)
    (h_pt : bf.pointTypes ⟨0, by omega⟩ = alpha_0)
    (h_seg : bf.segmentTypes ⟨0, by omega⟩ = beta_0)
    (z0 z1 : M.carrier)
    (h_b2 : (neg_b2_bracket_formula alpha_0 beta_0).holds M atomMap z0 z1)
    (h_bf : bf.holds M atomMap z0 z1) : False
```

### 9.4 Modified neg_interval_formula_indep (B.2 branch only)

```lean
-- In the | n + 1, bf => branch, replace:
let caseB2 : VBracketFormula :=
  ⟨[⟨1, inf_bracket_formula (bf.pointTypes ⟨0, by omega⟩)⟩]⟩
-- With:
let caseB2 : VBracketFormula :=
  ⟨[⟨2, neg_b2_bracket_formula (bf.pointTypes ⟨0, by omega⟩)
                                (bf.segmentTypes ⟨0, by omega⟩)⟩]⟩
```

### 9.5 Modified forward proof (B.2 case only)

```lean
-- Replace lines 154-161 in neg_interval_formula_indep_correct:
· -- Case B2: segmentTypes(0) fails on (z0, r0) → neg_b2_bracket
  have h_b2 := neg_b2_bracket_formula_hasINF h_INF
    (bf.pointTypes ⟨0, by omega⟩) (bf.segmentTypes ⟨0, by omega⟩)
    z0 z1 h_lt r0 hr0_above hr0_below hPr0 h_neg_before h_seg
  refine ⟨⟨2, neg_b2_bracket_formula (bf.pointTypes ⟨0, by omega⟩)
                                      (bf.segmentTypes ⟨0, by omega⟩)⟩, ?_, h_b2⟩
  simp only [List.mem_append]
  right
  exact List.mem_singleton.mpr rfl
```

---

## 10. Corollary 5.4 Model-Independent Biconditional: Provability Analysis

### 10.1 New Formulation Needed

The current `neg_partialBracketExist_is_vbracket` uses the F-chain approach. For a model-independent biconditional, we need a different approach entirely.

Define `neg_partialBracketExist_indep`:
```lean
def neg_partialBracketExist_indep (n : Nat) (bf : BracketFormula n) : VBracketFormula
```

that constructs a V-bracket for the negation of `exists z in (z0, z1), bf.holds z0 z`.

### 10.2 Construction Sketch

For `n = 0`: `partialBracketExist` = `exists z in (z0, z1), forall y in (z0, z), seg_0(y)`. On HasAttainedINF, this holds iff `(z0, z1)` is non-empty (the n=0 case is already fully proved). The V-bracket is `BracketFormula.trivial top.neg`.

For `n + 1`: `partialBracketExist` = `exists z in (z0, z1), bf.holds z0 z`. Case split on whether alpha_0 occurs in (z0, z1):
- If alpha_0 doesn't occur: no bracket witness can exist -> partialBracketExist fails -> negation holds trivially
- If alpha_0 occurs at first `r0`: case split on beta_0:
  - beta_0 holds on `(z0, r0)`: then the partial bracket reduces to `exists z in (r0, z1), bf.tail.holds r0 z`. Apply IH to get `neg_partialBracketExist_indep(n, bf.tail)` holding on `(r0, z1)`. Prepend `r0`.
  - beta_0 fails on `(z0, r0)`: need to show partialBracketExist fails.

Wait -- for the "beta_0 fails on `(z0, r0)`" case: any bracket witness `w_0` needs alpha_0(w_0) (so `w_0 >= r0`) and beta_0 on `(z0, w_0)`. Since beta_0 fails in `(z0, r0)` and `(z0, r0) subset (z0, w_0)` (for `w_0 >= r0`), beta_0 fails on `(z0, w_0)`. So the bracket cannot hold for ANY z. The negation is trivially true.

Encode this as a `neg_b2_bracket_formula` analog. But `neg_partialBracketExist` has a bounded existential, not just a bracket.

Hmm, the partialBracketExist is `exists z in (z0, z1), bf.holds z0 z`, and `bf.holds z0 z` requires `n+1` witnesses in `(z0, z)`. The first witness `w_0` must have `alpha_0(w_0)` and `beta_0` on `(z0, w_0)`.

If beta_0 fails before first alpha_0: then for ANY z, any bracket witness `w_0` in `(z0, z)` with alpha_0(w_0) has `w_0 >= r0` (first alpha_0 in (z0, z1)), and beta_0 fails on `(z0, w_0)`. So `bf.holds z0 z` fails for all z. The partialBracketExist is false.

So the V-bracket for this case just needs to assert "beta_0 fails before first alpha_0", which is `neg_b2_bracket_formula(alpha_0, beta_0)`.

For the "beta_0 holds on `(z0, r0)` and alpha_0 at `r0`" case: the partial bracket `exists z in (z0, z1), bf.holds z0 z` reduces. For any such `z`, the bracket has first witness `w_0 >= r0` with alpha_0(w_0). If `w_0 = r0`: beta_0 on `(z0, r0)` is satisfied, and we need bf.tail.holds(r0, z) for some z in (r0, z1). If `w_0 > r0`: beta_0 on `(z0, w_0)` requires beta_0 on `(r0, w_0)` too (since beta_0 holds on `(z0, r0)`, we need it on `(r0, w_0)` as well). But we DON'T know beta_0 holds on `(r0, w_0)`.

This means the reduction is NOT clean: `partialBracketExist` does NOT reduce to `exists z in (r0, z1), bf.tail.holds r0 z` when beta_0 holds on `(z0, r0)`.

**This is the same interval mismatch problem again.** The first bracket witness could be `r0` or any later alpha_0 point, and the beta_0 condition on `(z0, w_0)` depends on which `w_0` is chosen.

### 10.3 Conclusion on Corollary 5.4

The model-independent biconditional for Corollary 5.4 suffers from the same fundamental obstacle as Lemma 5.1 backward: the V-bracket formula is existentially quantified over witnesses, but the condition being negated involves a universal quantification over all possible witness arrangements.

**The Corollary 5.4 biconditional at BracketFormula level is also unprovable** with the interior-witness convention.

---

## 11. Adversarial Self-Verification

### Claim 1: "The B.2 fix (neg_b2_bracket_formula) has a correct backward proof."

**Verification**: The argument is: from neg_b2_bracket_formula.holds, we get y < x with beta_0.neg(y), alpha_0(x), alpha_0.neg on (z0, x). From bf.holds, we get w_0 with alpha_0(w_0). Since alpha_0.neg on (z0, x), w_0 >= x > y, so y in (z0, w_0), and beta_0.neg(y) contradicts beta_0 on (z0, w_0).

**Verdict**: HIGH confidence. The argument is a straightforward chain: (1) alpha_0.neg on (z0, x) forces w_0 >= x, (2) y < x <= w_0 puts y in (z0, w_0), (3) beta_0.neg(y) contradicts beta_0 on (z0, w_0). Each step is elementary order theory.

### Claim 2: "The B.1 backward gap is fundamental and unfixable at BracketFormula level."

**Verification**: The argument is that V-bracket formulas are existentially quantified (there exist witnesses...), but the backward direction requires universal quantification (for all possible bracket witness arrangements...). The IH gives negation on one specific sub-interval (r0, z1), but the bracket's first witness w_0 could be > r0, giving a different sub-interval (w_0, z1).

**Verdict**: HIGH confidence. This is the same obstruction documented in the EANegation.lean comment at lines 1047-1083. The concrete counterexample with alpha_0.conj.beta_0 at r0 (CaseE) confirms the impossibility: the forward direction of CaseE requires showing rightPart fails at ALL alpha_0 points, not just r0, which is impossible with a finite model-independent formula.

### Claim 3: "The Corollary 5.4 biconditional is also unprovable with interior-witness convention."

**Verification**: The argument parallels Claim 2. The partial bracket existential involves any witness w_0 in (z0, z) for varying z, and the negation requires the V-bracket to handle all such arrangements.

**Verdict**: HIGH confidence. The F-chain Until-unboundedness issue (documented at EANegation.lean:1211-1228) is a special case of this same obstacle.

### Claim 4: "Plan v31's de Morgan approach also requires the backward direction."

**Verification**: VecEA_m negation via de Morgan produces `disj_i(neg_component_i)`. For this to be a biconditional with `not conj_i(component_i)`, we need each `neg_component_i` to be a biconditional with `not component_i`. This is exactly the VVecEA2 backward direction.

**Verdict**: HIGH confidence. The de Morgan distributivity is exact: `disj_i(f_i) <-> not conj_i(g_i)` iff `f_i <-> not g_i` for each i (assuming the index set is finite and the disjunction/conjunction are over the same index set). The weakening to forward-only gives only one direction.

### Claim 5: "Type signatures in Section 9 are correct."

**Verification**: Compared against existing signatures in the codebase.
- `neg_b2_bracket_formula`: BracketFormula 2 with 2 point types and 3 segment types. The Fin indices are correct (pointTypes has Fin 2, segmentTypes has Fin 3).
- `neg_b2_bracket_formula_hasINF`: Takes the same hypotheses as the current B.2 case plus h_seg_fail. Compatible with the proof context at NegationIndep.lean line 128.
- `neg_b2_bracket_formula_disjoint`: Takes bf : BracketFormula (n+1), alpha_0, beta_0 as parameters. The h_pt/h_seg equality hypotheses could be simplified by inlining.

**Verdict**: HIGH confidence. The signatures are well-formed and compatible with the existing infrastructure.

### Revised Claims: None revised.

---

## 12. Summary of Key Findings

1. **The B.2 fix (neg_b2_bracket_formula) is correct and implementable.** It replaces `inf_bracket_formula(alpha_0)` with a 2-witness bracket encoding both alpha_0 occurrence and beta_0 failure. The forward proof is a minor change; the backward proof (disjointness) is ~20 lines of elementary reasoning. Estimated effort: 80-120 new lines in EANegationClosure.lean + 16 modified lines in NegationIndep.lean.

2. **The B.1 backward gap is fundamental and unfixable at BracketFormula level.** The obstruction is that V-bracket formulas are existentially quantified but the backward direction requires universal quantification over model-dependent witness arrangements. This is the same obstruction documented in EANegation.lean:1047-1083. No reorganization of the case split (including the beta_0-failure approach) can fix this.

3. **The Corollary 5.4 biconditional is also unprovable** with the interior-witness convention, for the same structural reason.

4. **Plan v31's de Morgan approach also requires the component-level backward direction**, making it subject to the same obstruction. The VecEA_m approach cannot bypass this without a fundamentally different negation strategy.

5. **These sorrys do NOT block completeness.** The model-dependent forward-only theorems in EANegationClosure.lean are sorry-free and sufficient for the completeness proof. The model-independent biconditionals are a stronger result that would be nice to have but are not needed.

6. **The only viable path to eliminating the KampPrior.lean:287 sorry** is through the VecEA_m approach (plan v31), but it must find a way to handle negation without requiring the component-level backward direction. Possible approaches: (a) use the model-dependent neg_2var_vec_ea for each model and then argue that the result is model-independent by construction; (b) reformulate VecEA_m negation to avoid the de Morgan decomposition.
