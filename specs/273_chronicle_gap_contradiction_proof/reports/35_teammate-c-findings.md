# Teammate C (Critic) Findings — Task 273 Bracket Sorry

**Date**: 2026-06-15
**Role**: Critic — challenging assumptions and identifying gaps in the proposed fix

---

## Key Findings

### Finding 1: The Ordering Problem IS Real — But NOT Because of `Fintype.elems`

**Claim challenged**: "The ordering issue arises from `pos_between` being ordered by `Fintype.elems`."

**Reality**: The ordering problem is real but subtly different from what the plan states. Let me be precise.

`pos_between` is a `List (NormalForm sig 0 3)` filtered from `Fintype.elems.val.toList`. The bracket at L468-471 is:

```lean
let bracket : BracketFormula n :=
  { pointTypes := fun i =>
        nfPred atomMap h_surj (nf_y_proj (pos_between[i.val]'(by omega)))
    segmentTypes := fun _ => seg_guard }
```

The `IntervalPattern.holds` definition (ExistsForallNF.lean:115-132) requires:
```
∃ (witnesses : Fin n → M.carrier),
  (∀ i j, i < j → witnesses i < witnesses j) ∧  -- STRICTLY INCREASING
  (∀ i, z0 < witnesses i ∧ witnesses i < z1)    -- ALL IN (t, x)
  ...
```

The real ordering problem: we must produce witnesses `y_0 < y_1 < ... < y_{n-1}` where `y_i` witnesses ssn `pos_between[i]`. But from `h_eval_quant`, each `ssn ∈ pos_between` gives us an INDEPENDENT `y_ssn ∈ (t, x)`. These independent witnesses have NO guaranteed ordering relationship. If we extract `y_0` for `pos_between[0]` and `y_1` for `pos_between[1]`, we cannot guarantee `y_0 < y_1`.

**Conclusion**: The ordering problem is real. The plan's attribution to `Fintype.elems` ordering is misleading (that's the ordering of SSNs in the list, not witness ordering), but the core issue — independent witnesses from existential instantiation have no ordering guarantee — is correct.

---

### Finding 2: Permutation Invariance DOES WORK in This Case (Critical Insight)

**Claim challenged**: "Permutation-invariance is dismissed because reordering witnesses permutes alpha indices."

**Reality**: The bracket at L468-471 has `segmentTypes := fun _ => seg_guard` — the segment type is UNIFORM (identical `seg_guard` for ALL segment positions). Furthermore, looking at the point types: `pos_between[i.val]` are distinct SSNs, but the point types `nfPred atomMap h_surj (nf_y_proj (pos_between[i]))` assign DIFFERENT point types to each index `i`.

So permutation invariance does NOT work here in general: if we permute witnesses, we assign point type `alpha_j` to witness `y_i`, which requires `nfPred (nf_y_proj (pos_between[j]))` to hold at `y_i`. Since `y_i` satisfies `nf_y_proj (pos_between[i])` (its own NF), and the NFs for distinct SSNs may disagree on predicate assignments, we CANNOT freely permute.

**Exception**: If all positive between_tx SSNs have the SAME `nf_y_proj` (same y-predicate assignment), then all point types are identical and permutation works. But this is not guaranteed in general.

**Conclusion**: The plan is correct to dismiss simple permutation invariance. Point types are indexed to specific SSNs and witnesses satisfy THEIR OWN NFs, not arbitrary ones.

---

### Finding 3: The Proposed Conjunction-of-Existentials Replacement IS Unsound

**Claim being evaluated**: Replace `BracketFormula n` with individual `Formula.untl char_y top` conjuncts.

**Evidence from code**:

`Formula.untl char_y top` at t gives (from `above_x_temporal_iff` pattern in the file):
```
∃ y > t, char_y holds at y
```

This gives `∃ y, t < y ∧ nf_y_proj(ssn)(y)`. But it does NOT guarantee `y < x`.

The `BracketFormula.holds` requires `z0 < witnesses i < z1`, i.e., `t < y_i < x`. The individual `Formula.untl char_y top` evaluated at `t` gives `∃ y > t, ...` with no upper bound.

In the backward direction (formula → ∃ x, nf_eval): if `Formula.untl char_y top` holds at t, we get `y > t` but potentially `y > x`. Then we cannot reconstruct `nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x _)) ssn` where ssn has `between_tx` zone (requiring `t < y < x`), because y might be above x.

**This is a genuine soundness flaw** in the proposed replacement. The conjunction-of-existentials approach DROPS the upper bound constraint `y < x`.

**The Since case (L588) has the SAME flaw**: `Formula.untl char_y Formula.top` at x for a positive `x < y < t` SSN gives `∃ y > x, char_y` with no guarantee `y < t`. This is indeed the same unsoundness.

**Conclusion**: The conjunction-of-existentials approach is UNSOUND for the backward direction. The BracketFormula's upper bound `y < z1` cannot be replaced by individual Until formulas without losing the upper bound.

---

### Finding 4: The Bracket Sorry IS Provable With Existing Witnesses — Ordering Is The Only Gap

**Critical insight from the goal state at L2081**:

```
h_eval_quant :
  ∀ (sub_nf_1 : NormalForm sig 0 (1 + 1 + 1)),
    (∃ x_1, nf_eval_nf M 0 (1 + 1 + 1) (Fin.cons x_1 (Fin.cons x fun x ↦ t)) sub_nf_1) ↔
    sub_nf.2 sub_nf_1 = true

⊢ BracketFormula.holds M atomMap vea.snd.bracket t x
```

For each `ssn ∈ pos_between` (which means `sub_nf.2 ssn = true`), `h_eval_quant` gives:
```
∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn
```

Since `ssn_zone_until ssn = .between_tx`, this means `t < y < x` AND `nf_y_proj(ssn)(y)`.

So we have `n` independent witnesses `y_0, ..., y_{n-1}` with `y_i ∈ (t, x)`. The ONLY problem is they may not be ordered `y_0 < y_1 < ... < y_{n-1}`.

**But we CAN sort them!** Given `n` witnesses in the open interval `(t, x)` of a linear order, we can sort them into strictly increasing order using `Fin.orderIsoOfFin` or simply by choosing the witnesses in some canonical order.

However, if we sort `y_0, ..., y_{n-1}` into `y_{σ(0)} < ... < y_{σ(n-1)}`, the witness at position `i` is `y_{σ(i)}`, which satisfies `nf_y_proj(pos_between[σ(i)])`. But the BracketFormula requires witness at position `i` to satisfy `pointTypes i = nfPred(nf_y_proj(pos_between[i]))`.

Unless `σ` happens to be the identity, we get type mismatches: witness at position `i` has the wrong NF.

**Correct fix**: Rather than sorting witnesses, we need a DIFFERENT bracket construction where `pointTypes` is invariant to witness ordering. Since the NFs for distinct between_tx SSNs CAN differ, we cannot guarantee this.

**Alternative correct approach**: Instead of ONE bracket that handles ALL between_tx SSNs simultaneously, we need a DIFFERENT strategy:

Option A: Use a single bracket of size 1 for EACH positive between_tx SSN separately, and use a disjunction structure to handle any ordering. But this changes the formula structure significantly.

Option B: Use the existing `nf_vecEA2_future` / VecEA2 machinery for each SSN INDEPENDENTLY and AND them together. But AND of two holdsLeft properties requires witnesses to be compatible.

Option C: Recognize that for the BETWEEN zone, `h_eval_quant` gives existence of individual witnesses, and we need to build a bracket that ONLY has uniform point types so that any ordering of witnesses satisfies it.

---

### Finding 5: The Since Case (L2308) Is Completely Independent of the Bracket Flaw

**Claim challenged**: "Phase 4 (Since) blocks on the BracketFormula design flaw."

**Evidence from goal state at L2308**:

```
⊢ ∃ A,
    ∀ (M : OrderedMonadicStructure sig) ...,
      (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x ↦ t) sub_nf)
```

This is a top-level existential over `A : Formula`. The Since case sorry is a COMPLETELY SEPARATE theorem with its own proof obligation. It uses `enriched_bypass_since` (L515-594) which uses `formula_disjList` and `Formula.snce`, NOT `VecEA2`/`BracketFormula`.

The Since case DOES have its own problems (as noted in Finding 3: `Formula.untl char_y top` at x for positive between_xt zone is unsound for the same reason). But these are independent of the bracket sorry.

**Conclusion**: The Since case can be analyzed and potentially fixed independently. The dependency in the plan ("Phase 2-3 block Phase 4") is overstated. The Since sorry is a separate proof obligation at the formula-existence level.

---

### Finding 6: The n=0 Case Is Trivially Provable

**Challenge**: When `pos_between.length = 0` (no positive between_tx SSNs), does the bracket sorry hold trivially?

**Answer**: YES. When `n = 0`, `BracketFormula.holds M atomMap bf t x` reduces to `IntervalPattern.holds` with `n = 0`, which is:
```
∀ y, t < y → y < x → (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
```
i.e., `seg_guard` holds everywhere in `(t, x)`.

The `seg_guard` is the conjunction of `(char_y).neg` for NEGATIVE between_tx SSNs. For each negative SSN `ssn`, `sub_nf.2 ssn = false`, so `h_eval_quant ssn` gives `¬∃ y_ssn ∈ (t,x), nf_y_proj(ssn)(y)`. This means for ALL `y ∈ (t,x)`, `¬ nf_y_proj(ssn)(y)` (by Rabinovich's key density/saturation argument, or by the fact that the NF characteristic is a COMPLETE characterization). The segment guard negatives hold everywhere in (t,x) — this is precisely what `h_eval_quant` with negative ssns says.

**Important caveat**: This reasoning requires knowing that for each y in (t,x), y's NF is exactly the NF that WOULD be selected by `Fintype.elems`. This follows from `nf_characteristic_satisfies`. So for each y in (t,x), either y's NF is one of the positive between_tx SSNs (then `∃` holds) or it's a negative one (then `¬∃` holds, and `char_y.neg` holds at y).

The segment guard `seg_guard = ∧_{neg ssn} (char_y).neg` holds at all y ∈ (t,x) because:
1. For each negative SSN `ssn`, `¬∃ z, nf_eval M 0 3 (z, x, t) ssn` (by h_eval_quant)
2. `nf_depth0_char_formula` correctly characterizes the NF
3. So for any `y ∈ (t,x)`: if y's NF matches the negative SSN `ssn`, then `char_y` holds at y, but `h_eval_quant` says the NF is NOT satisfiable — WAIT.

Actually, the seg_guard argument is more subtle: the issue is whether `nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)` holds at a specific y. It holds at y iff y has the SAME predicate assignment as `nf_y_proj(ssn)`. The negation `char_y.neg` then holds at all y NOT having that predicate assignment. But that's NOT what we want: we want `char_y.neg` to hold at y iff `ssn` is NOT satisfied by ANY z with `t < z < x, z = y` (but since z=y, it's whether y satisfies the NF's y-predicates).

Actually the segment guard is: for each y ∈ (t,x), `(char_neg_ssn).neg` holds at y iff y does NOT have the predicate profile of the negative SSN. This is trivially true for most y, but we need it to hold for ALL y ∈ (t,x).

**This requires deeper analysis**: The segment guard proof is non-trivial even in the n=0 case. But the n=0 case IS accessible (no witness ordering problem).

---

### Finding 7: What Was Actually Tried in 4 Failed Cycles

From reading the file structure, the 4 failed cycles appear to have attempted:
1. Directly constructing bracket witnesses without addressing ordering (would fail at the Lean type level)
2. Using `sorry` as placeholder then backtracking
3. The conjunction-of-existentials approach (would compile but is semantically wrong)
4. Ordering witnesses by sorting (fails due to point-type mismatch after permutation)

There is no evidence in the code that a formally verified sorting argument was attempted and found to fail for a specific reason.

---

## Recommended Approach

### For the Bracket Sorry (L2081) — Correct Strategy

The correct approach requires addressing the ordering problem WITHOUT permuting point-type indices.

**Recommended Fix**: Change the bracket construction so that the `n` bracket witnesses correspond to a SINGLE canonical ordering that we can CONSTRUCT directly, not extract independently.

Specifically, instead of having one BracketFormula with `n` witnesses (one per positive SSN), the correct construction should:

1. Extract witnesses `y_0, ..., y_{n-1}` from `h_eval_quant` for each positive SSN
2. Sort them using `List.mergeSort` or equivalent to get `y_{σ(0)} < ... < y_{σ(n-1)}`
3. Construct `witnesses : Fin n → M.carrier` as `i ↦ y_{σ(i)}`
4. Verify that sorted witnesses satisfy `IntervalPattern.holds`:
   - Strict monotonicity: guaranteed by sort
   - All in (t, x): preserved by sort (sort doesn't change elements)
   - Point types: witness `i` satisfies `pointTypes (σ⁻¹(i))` NOT `pointTypes i`

Step 4 fails because point types are indexed to SSNs, not sorted witnesses.

**Alternative Fix (Recommended)**: Redesign `enriched_vecEA2_until` so that when there are multiple positive between_tx SSNs, instead of encoding them as SEPARATE witnesses with different point types, encode them using NESTED Until formulas (as the VecEA2 translation naturally does). This aligns with `bracketBuildRight` which builds a chain `∃ y0 > t, char_y0 ∧ ∃ y1 > y0, char_y1 ∧ ...`, where each witness is found SEQUENTIALLY (guaranteed increasing by construction).

The key insight: `bracketBuildRight` for a BracketFormula with `n` witnesses builds a NESTED Until chain where each witness is AFTER the previous one. If we use this translation to PROVE the bracket holds (rather than using it as a formula), we need a PROOF that such a sequential chain exists. This reduces to: given `n` independent witnesses in `(t,x)`, we can find `n` witnesses IN ORDER.

**Concrete proof strategy**: For n ≥ 2, use induction and the ordering property of `M.carrier` (a linear order). Given n independent witnesses in (t,x), sort them. The i-th sorted witness `y_i` is in (t,x). But it satisfies `nf_y_proj(pos_between[σ(i)])`, not `nf_y_proj(pos_between[i])`.

**TRUE fix**: The bracket's `pointTypes` should NOT be indexed by SSN list position. Instead, we should verify that EACH witness in the sorted order satisfies SOME positive SSN's NF, and the bracket formula should say "each witness satisfies SOME positive between_tx NF" rather than "witness i satisfies SSN i's NF."

This requires changing `pointTypes := fun i => nfPred atomMap h_surj (nf_y_proj (pos_between[i]))` to something like the DISJUNCTION of all positive NFs: `pointTypes := fun _ => nfPred_disj (pos_between.map (nf_y_proj))`. Then permutation invariance DOES hold because all point types are identical (all = disjunction).

**Segment guard handling**: The disjunction-point-type approach means: each witness in (t,x) satisfies SOME positive between_tx NF. The negative segment guard ensures no point in (t,x) satisfies a NEGATIVE NF. Together these give the correct semantic content: for each witness in (t,x), it satisfies exactly one between_tx NF, and all negative ones are ruled out everywhere.

### For the Since Sorry (L2308)

The Since sorry at L2308 is a pure `∃ A, ...` obligation. The proposed `enriched_bypass_since` at L515-594 uses `Formula.snce` and `Formula.untl char_y top`. The `Formula.untl char_y top` at x for positive `x < y < t` SSNs gives `∃ y > x, char_y` without upper bound `y < t` — this IS unsound for the backward direction.

**Recommended fix for Since**: Mirror the bracket approach: use a VecEA2 for the Since direction too, with a bracket going backwards from t to x, and the `VecEA2.holdsRight` semantics. The existing `holdsRight` definition in NfToVecEA.lean (L41-47) and `enriched_bypass_since` needs to be redesigned similarly to `enriched_bypass_until` using `VecEA2.holdsRight`.

This is a substantial redesign. The Since sorry at L2308 is NOT a simple fix.

---

## Evidence / Examples

### Goal State at L2081 (Bracket Sorry)

```
h_eval_quant :
  ∀ (sub_nf_1 : NormalForm sig 0 (1 + 1 + 1)),
    (∃ x_1, nf_eval_nf M 0 (1 + 1 + 1) (Fin.cons x_1 (Fin.cons x fun x ↦ t)) sub_nf_1) ↔
    sub_nf.2 sub_nf_1 = true

⊢ BracketFormula.holds M atomMap vea.snd.bracket t x
```

where `vea.snd.bracket` is constructed with:
- `n = pos_between.length`
- `pointTypes i = nfPred atomMap h_surj (nf_y_proj (pos_between[i.val]))`
- `segmentTypes _ = seg_guard` (UNIFORM)

### Goal State at L2308 (Since Sorry)

```
⊢ ∃ A,
    ∀ (M : OrderedMonadicStructure sig) ...,
      (temporal_truth M atomMap t A ↔
       ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x ↦ t) sub_nf)
```

This is a standalone formula-existence theorem with no bracket dependency.

### IntervalPattern.holds witness ordering requirement (ExistsForallNF.lean:117)

```lean
(∀ i j : Fin (n + 1), i < j → witnesses i < witnesses j)
```

Witnesses MUST be strictly increasing. Independent existential instantiation gives NO such guarantee.

### Uniform segmentTypes at L468-471

```lean
segmentTypes := fun _ => seg_guard
```

ALL segment positions use the SAME `seg_guard`. This means the segment-type uniformity IS present, which enables permutation invariance FOR SEGMENT TYPES — but NOT for point types, which differ by SSN.

---

## Confidence Level

| Claim | Confidence |
|-------|-----------|
| Ordering problem is real | HIGH |
| Conjunction-of-existentials is unsound | HIGH |
| Since sorry is independent of bracket sorry | HIGH |
| Permutation invariance fails due to non-uniform point types | HIGH |
| n=0 case is easier but still non-trivial | MEDIUM |
| Disjunction-of-NFs fix for point types would work | MEDIUM |
| Since sorry requires VecEA2 holdsRight redesign | MEDIUM |
| 4 failed cycles attempted ordering sort | LOW (not verified from code) |

---

## Risk Assessment

### High Risk: The Proposed Fix is Unsound

The conjunction-of-existentials replacement for the bracket formula loses the `y < x` upper bound constraint. If implemented, the backward direction (formula → ∃ x, nf_eval) would fail to reconstruct the `between_tx` zone constraint. This is not a gap in proof effort — it is a logical unsoundness.

### Medium Risk: Correct Fix Requires Redesign, Not Local Patch

The correct fix for the bracket sorry requires either:
1. Changing `pointTypes` to use a disjunction over all positive between_tx NFs (so witnesses are permutation-invariant)
2. Or proving a sorting argument that works despite the point-type index mismatch

Option 1 changes the definition of `enriched_vecEA2_until`, which may break existing proofs that depend on the specific point-type assignment.

### Medium Risk: Since Case Has Independent Unsoundness

The `enriched_bypass_since` formula at L515-594 uses `Formula.untl char_y top` at x for positive `x < y < t` SSNs. This gives `∃ y > x, char_y` without upper bound `y < t`. The Since sorry at L2308 is currently unprovable with the existing `enriched_bypass_since` formula because the formula is wrong for the backward direction. It needs a VecEA2 holdsRight redesign.

### Low Risk: The n=0 Bracket Case

When there are no positive between_tx SSNs, the bracket reduces to a pure universal over `(t,x)` with the segment guard. This case is more tractable and may be provable without the witness ordering issue. If the plan prioritizes the most common case in practice, starting with n=0 is lower risk.

### Low Risk: 4-Cycle Pattern Suggests Deep Structural Issue

The fact that 4 implementation cycles have failed suggests this is not a surface-level proof gap but a DESIGN issue with the formula encoding. Any fix that doesn't redesign `enriched_vecEA2_until`'s point-type assignment is likely to fail for the same reason.
