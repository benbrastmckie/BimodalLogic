# B.2 Construction Fix: neg_interval_formula_indep Case Analysis

- **Task**: 305 -- rabinovich_ea_formula_implementation
- **Type**: lean4
- **Agent**: lean-research-agent
- **Date**: 2026-06-23

---

## 1. Problem Statement

`neg_interval_formula_indep` in `NegationIndep.lean` constructs a model-independent VBracketFormula for the negation of any BracketFormula. The forward proof (`neg_interval_formula_indep_correct`) is sorry-free. However, the backward direction is unprovable because Case B.2 emits `inf_bracket_formula P` which is not disjoint from the original bracket formula.

### Current Construction (lines 61-84)

```lean
| n + 1, bf =>
    let caseA := ⟨[⟨0, BracketFormula.trivial (bf.pointTypes ⟨0, _⟩).neg⟩]⟩
    let ih := neg_interval_formula_indep n bf.tail
    let caseB1 := VBracketFormula.prependAll (bf.pointTypes ⟨0, _⟩).neg
        (bf.pointTypes ⟨0, _⟩) ih
    let caseB2 := ⟨[⟨1, inf_bracket_formula (bf.pointTypes ⟨0, _⟩)⟩]⟩  -- PROBLEM
    ⟨caseA.disjuncts ++ caseB1.disjuncts ++ caseB2.disjuncts⟩
```

### The Deficiency

`inf_bracket_formula P` is `[P.neg, P, top](z0, z1)`, encoding:
- "There exists x in (z0,z1) with P(x) and not-P on (z0,x)"

This is **too weak** for the backward direction. It only says alpha_0 has a first occurrence with alpha_0.neg before it. It does NOT encode that beta_0 (the original bracket's first segment type) fails somewhere in (z0, first alpha_0).

### Concrete Counterexample (from plan v31)

Take `bf` with `n=1`, `pt(0)=P`, `pt(1)=Q`, all segments = `top`. On interval `(0,10)` with `P` holding only at 5, `Q` at 8:
- `bf.holds` with witnesses `(5, 8)` -- all segment types are `top`, so trivially satisfied
- `inf_bracket_formula(P).holds` with witness `5` -- `P.neg` on `(0,5)` holds, `P(5)` holds

Both hold simultaneously, so B.2 is not disjoint from the original bracket.

---

## 2. Literature Analysis: Rabinovich's Actual Construction

### Rabinovich's Bracket Convention (Critical Difference)

Rabinovich's notation `[alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1)` places `alpha_0` at the **endpoint** `z_0`, not an interior witness. The codebase's `BracketFormula n` places all `n` point types at **interior** witnesses.

This convention difference changes the case analysis structure entirely.

### Rabinovich's Three Cases (pp. 9-10)

Rabinovich's proof of Lemma 5.1 case-splits on what goes wrong with beta_1 (the first segment type), NOT on alpha_0 occurrence:

- **Case 1**: `not alpha_0(z_0)` or `K+(not beta_1)(z_0)` -- endpoint failure. Trivial since alpha_0 is at the endpoint.

- **Case 2**: `alpha_0(z_0)` and `beta_1` holds everywhere in `(z_0, z_1)`. Reduces to "there is no z in (z_0,z_1) with tail bracket holding" -- uses Corollary 5.4.

- **Case 3**: `alpha_0(z_0)` and `not K+(not beta_1)(z_0)`, and there exists `x` in `(z_0, z_1)` with `not beta_1(x)`. Uses INF formula for the first `beta_1` failure:
  ```
  INF^{neg beta_1}(z_0, z, z_1) := z_0 < z < z_1 AND
      (forall y in (z_0,z), beta_1(y)) AND
      (neg beta_1(z) OR K+(neg beta_1)(z))
  ```

### Why Rabinovich's Construction Is Disjoint

In Rabinovich's Case 3, `INF^{neg beta_1}` finds the point where `beta_1` fails. Since any valid bracket witness `x_1` must have `beta_1` holding on `(z_0, x_1)`, we know `x_1 >= z` (where `z` is the first `beta_1` failure). The negation formula uses this `z` to decompose the interval and apply the IH. The disjointness comes from the fact that the original bracket requires `beta_1` on `(z_0, x_1)`, but Case 3 guarantees `beta_1` fails at `z <= x_1`.

---

## 3. Translating to the Codebase's Convention

### The Codebase's Case Structure

Since the codebase's `BracketFormula` has all point types at interior witnesses (not endpoints), we need a different but analogous case split. The current code splits on alpha_0 occurrence, then on beta_0 on `(z_0, r_0)`. This is:

- **Case A**: alpha_0 doesn't occur in (z_0, z_1) -- bracket trivially fails
- **Case B**: alpha_0 occurs; let r_0 = first alpha_0 occurrence
  - **Case B.1**: beta_0 holds on (z_0, r_0) -- IH on tail from r_0
  - **Case B.2**: beta_0 fails on (z_0, r_0) -- PROBLEM CASE

### The Fix: Sub-Split Case B.2

When beta_0 fails on `(z_0, r_0)`, we know:
1. r_0 is the first alpha_0 occurrence in (z_0, z_1)
2. beta_0 fails somewhere in (z_0, r_0)

For the original bracket `bf` to hold, it would need witnesses `w_0 < w_1 < ... < w_n` in `(z_0, z_1)` with:
- `alpha_0(w_0)` (= `bf.pointTypes(0)`)
- `beta_0` on `(z_0, w_0)` (= `bf.segmentTypes(0)`)

Since r_0 is the FIRST alpha_0 point, any such w_0 must satisfy w_0 >= r_0. But beta_0 fails on (z_0, r_0), so beta_0 fails on (z_0, w_0) as well (since (z_0, r_0) is a sub-interval of (z_0, w_0)).

**Therefore, when B.2 fires, the original bracket CANNOT hold. The negation is simply TRUE.**

Wait -- this means Case B.2 actually implies the bracket fails! The issue is: can we encode this as a VBracketFormula?

### Re-Analysis: What Does B.2 Actually Need?

If Case B.2 fires (alpha_0 occurs, beta_0 fails on (z_0, r_0)), then:
- For any `w_0` with `alpha_0(w_0)` in (z_0, z_1): `w_0 >= r_0` (since r_0 is the first alpha_0 point)
- beta_0 fails at some `y` in `(z_0, r_0)`, hence also in `(z_0, w_0)` since `w_0 >= r_0 > y`
- So the bracket fails because its first segment type is violated

This means: whenever both "alpha_0 occurs in (z_0, z_1)" AND "beta_0 fails on (z_0, first_alpha_0)" hold, the bracket **necessarily fails**. The forward proof is therefore trivially correct for any VBracketFormula that encodes this condition.

**The problem is the BACKWARD direction**: we need a VBracketFormula `v` such that `v.holds(z_0, z_1)` IMPLIES the bracket fails. The current `inf_bracket_formula(alpha_0)` is too weak -- it only says alpha_0 occurs with alpha_0.neg before it, without mentioning beta_0.

### Proposed Fix: Encode beta_0 failure explicitly

Define a new bracket formula for Case B.2 that encodes BOTH conditions:
1. alpha_0 has a first occurrence (with alpha_0.neg before it) -- existing inf_bracket_formula
2. beta_0 fails somewhere before that first alpha_0 occurrence

The second condition can be encoded as a 1-witness bracket: `[beta_0.neg, top, top](z_0, r_0)` where r_0 is the first alpha_0 point. But we need to combine this with the INF formula.

**Concrete construction**: A 2-witness bracket formula:
```
neg_b2_bracket(alpha_0, beta_0) : BracketFormula 2
  pointTypes(0) = beta_0.neg    -- first witness: where beta_0 fails
  pointTypes(1) = alpha_0       -- second witness: first alpha_0 occurrence
  segmentTypes(0) = top         -- anything before beta_0 failure point
  segmentTypes(1) = alpha_0.neg -- no alpha_0 between beta_0 failure and first alpha_0
  segmentTypes(2) = top         -- anything after first alpha_0
```

This says: "there exist y < x in (z_0, z_1) with beta_0.neg(y) and alpha_0(x) and alpha_0.neg on (y, x)."

**Forward proof**: If alpha_0 occurs and beta_0 fails on (z_0, first_alpha_0):
- Let r_0 = first alpha_0 occurrence
- Let y be a point in (z_0, r_0) where beta_0 fails (exists by assumption)
- Set witness_0 = y, witness_1 = r_0
- beta_0.neg(y) holds, alpha_0(r_0) holds
- alpha_0.neg on (y, r_0): since r_0 is the first alpha_0 and y < r_0, no alpha_0 in (y, r_0)
- All other segment types are top

**Backward proof**: If neg_b2_bracket(alpha_0, beta_0).holds(z_0, z_1):
- We get witnesses y < x with beta_0.neg(y) and alpha_0(x) and alpha_0.neg on (y, x)
- For the original bracket to hold, any first witness w_0 needs alpha_0(w_0) and beta_0 on (z_0, w_0)
- But beta_0.neg(y) with z_0 < y < x <= w_0 means beta_0 fails on (z_0, w_0) -- contradiction

**Wait, there's a subtlety**: we need y < w_0 for the contradiction. We know z_0 < y < x (from the neg_b2_bracket witnesses) and alpha_0(x). For any bracket witness w_0 with alpha_0(w_0), we need w_0 >= some alpha_0 point. But w_0 could be any alpha_0 point, not necessarily >= x.

Actually, the backward proof works more directly. From neg_b2_bracket:
- We have y in (z_0, z_1) with beta_0.neg(y)
- For the original bracket bf.holds(z_0, z_1), we need witnesses w_0 < ... < w_n with beta_0 on (z_0, w_0)
- Since z_0 < y < z_1 and y is in (z_0, w_0) only if y < w_0
- But y < x < z_1 and w_0 could be <= y...
- Hmm, this is the issue. We need to ensure y < w_0.

**Better approach**: We don't need y < w_0. We just need beta_0.neg(y) and z_0 < y < w_0. But y might not be < w_0 if w_0 < y. In that case, beta_0 on (z_0, w_0) doesn't include y, so the contradiction doesn't fire.

This means the naive 2-witness bracket is NOT sufficient for the backward direction either. We need a stronger condition.

### Revised Analysis: The CORRECT B.2 Encoding

The key insight is that we need the beta_0 failure point to be in (z_0, w_0) for EVERY possible w_0 satisfying alpha_0(w_0). The current code uses the INF construction: r_0 = first alpha_0 occurrence. Any bracket witness w_0 with alpha_0(w_0) must satisfy w_0 >= r_0 (since r_0 is the FIRST). So the beta_0 failure point y (which is in (z_0, r_0)) satisfies y < r_0 <= w_0. This gives the contradiction.

So the encoding needs to capture: "the beta_0 failure point is BEFORE the first alpha_0 occurrence."

**Revised construction**: The 2-witness bracket above is almost right, but the segment type between the two witnesses needs to be `alpha_0.neg` (not just anything), ensuring the second witness (alpha_0 point) is the first one:

```lean
def neg_b2_bracket (alpha_0 beta_0 : TemporalPred) : BracketFormula 2 :=
  { pointTypes := fun i => if i.val = 0 then beta_0.neg else alpha_0
    segmentTypes := fun i =>
      match i.val with
      | 0 => alpha_0.neg    -- no alpha_0 before the beta_0 failure point
      | 1 => alpha_0.neg    -- no alpha_0 between beta_0 failure and first alpha_0
      | _ => TemporalPred.top }  -- anything after first alpha_0
```

Wait, but the segment BEFORE the first witness (segment 0) should be `alpha_0.neg` to ensure the second witness is the first alpha_0 point. Actually, for the backward proof, we need: for any bracket witness w_0 with alpha_0(w_0), we have w_0 >= witness_1 (the alpha_0 witness). This requires alpha_0.neg on all of (z_0, witness_1), i.e., on both segments 0 and 1.

**Final construction**:

```lean
def neg_b2_bracket (alpha_0 beta_0 : TemporalPred) : BracketFormula 2 :=
  { pointTypes := fun i => if i.val = 0 then beta_0.neg else alpha_0
    segmentTypes := fun i =>
      if i.val ≤ 1 then alpha_0.neg else TemporalPred.top }
```

This encodes: "there exist y < x in (z_0, z_1) with:
- beta_0.neg(y) (beta_0 fails at y)
- alpha_0(x) (alpha_0 holds at x)
- alpha_0.neg on (z_0, y) and on (y, x) (so x is the first alpha_0 point in (z_0, z_1))
- top on (x, z_1) (no constraint after)"

**Forward proof correctness**:
- Given: alpha_0 occurs in (z_0, z_1), beta_0 fails on (z_0, first alpha_0)
- Let r_0 = first alpha_0 occurrence via HasAttainedINF
- beta_0 fails at some y in (z_0, r_0)
- alpha_0.neg on (z_0, y): since r_0 is the first alpha_0 and y < r_0, alpha_0.neg holds on all of (z_0, r_0), hence on (z_0, y)
- alpha_0.neg on (y, r_0): same reasoning
- Set witnesses = (y, r_0), all conditions met

**Backward proof correctness**:
- Given: neg_b2_bracket(alpha_0, beta_0).holds(z_0, z_1) AND bf.holds(z_0, z_1)
- From neg_b2_bracket: get y < x with beta_0.neg(y), alpha_0(x), alpha_0.neg on (z_0, x)
- From bf.holds: get w_0 with alpha_0(w_0) and beta_0 on (z_0, w_0)
- alpha_0.neg on (z_0, x) means no alpha_0 point in (z_0, x), so w_0 >= x (since alpha_0(w_0))
- But if w_0 >= x > y > z_0, then y is in (z_0, w_0), and beta_0.neg(y) contradicts beta_0 on (z_0, w_0)
- Wait: w_0 could equal x. alpha_0.neg on (z_0, x) means alpha_0(w_0) requires w_0 >= x
- If w_0 = x, then y is in (z_0, w_0) = (z_0, x), so y < w_0 and beta_0.neg(y) contradicts beta_0 on (z_0, w_0)
- If w_0 > x, same argument

**This works!**

---

## 4. Proposed Fix: Concrete Lean 4 Pseudocode

### 4.1 New Definition

In `EANegationClosure.lean` (or `NegationIndep.lean`), define:

```lean
/-- The B.2 bracket formula: encodes that beta_0 fails before the first alpha_0.
    Two witnesses: y (beta_0 failure) < x (first alpha_0).
    Segments: alpha_0.neg on (z_0, y) and (y, x), top on (x, z_1). -/
def neg_b2_bracket_formula (alpha_0 beta_0 : TemporalPred) : BracketFormula 2 :=
  { pointTypes := fun i => if i.val = 0 then beta_0.neg else alpha_0
    segmentTypes := fun i =>
      if i.val ≤ 1 then alpha_0.neg else TemporalPred.top }
```

### 4.2 Forward Correctness

```lean
/-- If alpha_0 occurs in (z_0, z_1) and beta_0 fails on (z_0, first_alpha_0),
    then neg_b2_bracket_formula holds on (z_0, z_1). -/
theorem neg_b2_bracket_formula_hasINF
    {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    (alpha_0 beta_0 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x, z0 < x ∧ x < z1 ∧ alpha_0.eval_at M atomMap x)
    (r0 : M.carrier) (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPr0 : alpha_0.eval_at M atomMap r0)
    (h_neg_before : ∀ y, z0 < y → y < r0 → ¬alpha_0.eval_at M atomMap y)
    (h_seg_fail : ¬∀ y, z0 < y → y < r0 → beta_0.eval_at M atomMap y) :
    (neg_b2_bracket_formula alpha_0 beta_0).holds M atomMap z0 z1 := by
  -- Extract the beta_0 failure point
  push_neg at h_seg_fail
  obtain ⟨y, hy_above, hy_below, h_beta_neg⟩ := h_seg_fail
  -- Construct witnesses: y < r0
  simp only [neg_b2_bracket_formula, BracketFormula.holds, BracketFormula.toIntervalPattern,
             IntervalPattern.holds]
  refine ⟨fun i => if i.val = 0 then y else r0, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Strictly monotone
    sorry -- straightforward: y < r0
  · -- All in (z0, z1)
    sorry -- y ∈ (z0, r0) ⊂ (z0, z1), r0 ∈ (z0, z1)
  · -- Point types
    sorry -- beta_0.neg(y), alpha_0(r0)
  · -- Segment 0: alpha_0.neg on (z0, y)
    sorry -- y < r0 and r0 is first alpha_0, so alpha_0.neg on (z0, r0) ⊃ (z0, y)
  · -- Segment 1: alpha_0.neg on (y, r0)
    sorry -- same reasoning
  · -- Segment 2: top on (r0, z1)
    sorry -- trivial
```

### 4.3 Backward Correctness (The Key New Theorem)

```lean
/-- If neg_b2_bracket_formula holds, the original bracket formula fails. -/
theorem neg_b2_bracket_formula_disjoint
    {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (alpha_0 beta_0 : TemporalPred) (z0 z1 : M.carrier)
    {n : Nat} (bf : BracketFormula (n + 1))
    (h_pt : bf.pointTypes ⟨0, by omega⟩ = alpha_0)  -- or use alpha_0 directly
    (h_seg : bf.segmentTypes ⟨0, by omega⟩ = beta_0)
    (h_b2 : (neg_b2_bracket_formula alpha_0 beta_0).holds M atomMap z0 z1) :
    ¬bf.holds M atomMap z0 z1 := by
  intro h_bf
  -- From h_b2: get witnesses y < x with beta_0.neg(y), alpha_0(x),
  --   alpha_0.neg on (z0, x)
  -- From h_bf: get w_0 with alpha_0(w_0) and beta_0 on (z0, w_0)
  -- alpha_0.neg on (z0, x) forces w_0 >= x
  -- y < x <= w_0 means y ∈ (z0, w_0)
  -- beta_0.neg(y) contradicts beta_0 on (z0, w_0)
  sorry -- ~30 lines of detailed proof
```

### 4.4 Modified neg_interval_formula_indep

```lean
def neg_interval_formula_indep : (n : Nat) → BracketFormula n → VBracketFormula
  | 0, bf => -- unchanged
    let neg_seg : BracketFormula 1 :=
      { pointTypes := fun _ => (bf.segmentTypes ⟨0, by omega⟩).neg
        segmentTypes := fun _ => TemporalPred.top }
    ⟨[⟨1, neg_seg⟩]⟩
  | n + 1, bf =>
    let alpha_0 := bf.pointTypes ⟨0, by omega⟩
    let beta_0 := bf.segmentTypes ⟨0, by omega⟩
    -- Case A: alpha_0 does not occur in (z_0, z_1) -- UNCHANGED
    let caseA : VBracketFormula :=
      ⟨[⟨0, BracketFormula.trivial alpha_0.neg⟩]⟩
    -- Case B1: alpha_0 occurs, beta_0 holds on prefix, tail negated -- UNCHANGED
    let ih := neg_interval_formula_indep n bf.tail
    let caseB1 : VBracketFormula :=
      VBracketFormula.prependAll alpha_0.neg alpha_0 ih
    -- Case B2: alpha_0 occurs, beta_0 FAILS before first alpha_0 -- CHANGED
    let caseB2 : VBracketFormula :=
      ⟨[⟨2, neg_b2_bracket_formula alpha_0 beta_0⟩]⟩  -- was: inf_bracket_formula alpha_0
    ⟨caseA.disjuncts ++ caseB1.disjuncts ++ caseB2.disjuncts⟩
```

---

## 5. Impact Analysis on Forward Proof

### What Changes

The forward proof `neg_interval_formula_indep_correct` has three cases corresponding to A, B1, B2. Only Case B2 (lines 154-161) needs modification.

### Current Case B2 Forward Proof (lines 154-161)

```lean
· -- Case B2: segmentTypes(0) fails on (z0, r0) → INF bracket
  have h_inf := inf_bracket_formula_hasINF h_INF
    (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
  refine ⟨⟨1, inf_bracket_formula (bf.pointTypes ⟨0, by omega⟩)⟩, ?_, h_inf⟩
  simp only [List.mem_append]
  right
  exact List.mem_singleton.mpr rfl
```

### New Case B2 Forward Proof

Replace `inf_bracket_formula_hasINF` with `neg_b2_bracket_formula_hasINF`. The proof structure is similar but uses the beta_0 failure point in addition to the first alpha_0 occurrence:

```lean
· -- Case B2: segmentTypes(0) fails on (z0, r0) → neg_b2_bracket
  have h_b2 := neg_b2_bracket_formula_hasINF h_INF
    (bf.pointTypes ⟨0, by omega⟩) (bf.segmentTypes ⟨0, by omega⟩)
    z0 z1 h_lt h_exists r0 hr0_above hr0_below hPr0 h_neg_before h_seg
  refine ⟨⟨2, neg_b2_bracket_formula ... ⟩, ?_, h_b2⟩
  simp only [List.mem_append]
  right
  exact List.mem_singleton.mpr rfl
```

### Assessment

- **Cases A and B1**: Completely unchanged. The VBracketFormula structure is the same (caseA ++ caseB1 ++ caseB2), just the B2 entry changes from a 1-witness to a 2-witness bracket.
- **Case B2**: The forward proof changes from `inf_bracket_formula_hasINF` to `neg_b2_bracket_formula_hasINF`. The new theorem takes the same hypotheses plus `h_seg` (beta_0 failure), which is already available in scope at that proof point.
- **Membership proof**: Changes from `⟨1, inf_bracket_formula ...⟩` to `⟨2, neg_b2_bracket_formula ...⟩`. The membership reasoning (`List.mem_append`, `right`, `List.mem_singleton`) is identical.

**Risk**: LOW. The forward proof modification is a surgical replacement of one lemma invocation with another. No structural changes to the proof flow.

---

## 6. Backward Proof Outline

### neg_interval_formula_indep_backward

```lean
theorem neg_interval_formula_indep_backward :
    ∀ (n : Nat) (bf : BracketFormula n),
    ∀ {sig : MonadicSignature}
      (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
      (z0 z1 : M.carrier), z0 < z1 →
      (neg_interval_formula_indep n bf).holds M atomMap z0 z1 →
      ¬bf.holds M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    -- neg_interval_formula_indep 0 bf = [beta_0.neg, top, top]
    -- If this holds, beta_0.neg at some y in (z0,z1)
    -- bf.holds requires beta_0 on all of (z0,z1) -- contradiction
    sorry -- ~15 lines
  | succ n ih =>
    -- Three sub-cases based on which disjunct holds:
    -- Case A: alpha_0.neg everywhere -> bracket needs alpha_0(w_0) -> contradiction
    -- Case B1: prepended IH -> by IH, tail fails; by bracket_tail_satisfiable, bf fails
    -- Case B2: neg_b2_bracket_formula -> by neg_b2_bracket_formula_disjoint, bf fails
    sorry -- ~50 lines
```

### Case-by-case outline

**Case A**: The disjunct is `BracketFormula.trivial alpha_0.neg`. This holds iff alpha_0.neg everywhere in (z_0, z_1). If bf.holds, then w_0 in (z_0, z_1) with alpha_0(w_0) -- contradiction with alpha_0.neg(w_0).

**Case B1**: The disjunct is some `bf_v.prepend alpha_0.neg alpha_0` from the IH. By `BracketFormula.prepend_holds_inv`, we extract r_0 with alpha_0(r_0), alpha_0.neg on (z_0, r_0), and bf_v.holds on (r_0, z_1). By IH (backward), bf.tail fails on (r_0, z_1). Assume bf.holds(z_0, z_1) with witnesses w_0 < ... < w_n. Since alpha_0.neg on (z_0, r_0) and alpha_0(w_0), w_0 >= r_0. If w_0 = r_0, bf.tail holds on (r_0, z_1) -- contradiction with IH. If w_0 > r_0... hmm, this requires more care.

Actually, for B1 the argument is: the prepended formula has witnesses {r_0} ++ {IH witnesses in (r_0, z_1)}. The IH says the tail bracket fails on (r_0, z_1). And `bracket_tail_satisfiable` says: if bf.tail holds on (r_0, z_1) with alpha_0(r_0) and beta_0 on (z_0, r_0), then bf holds on (z_0, z_1). The contrapositive is: if bf doesn't hold... wait, that's the wrong direction.

We need: neg_interval_formula_indep holds -> bf fails. For B1: we get from prepend_holds_inv that bf_v (an IH disjunct) holds on (r_0, z_1). By IH backward, bf.tail fails on (r_0, z_1).

Now if bf.holds(z_0, z_1), with witnesses w_0 < ... < w_n, we need alpha_0(w_0). Since alpha_0.neg on (z_0, r_0), w_0 >= r_0. Also alpha_0(r_0). If w_0 = r_0: then bf.tail.holds(r_0, z_1) using witnesses w_1 < ... < w_n, because bf.tail gets point types shifted by 1 and segment types shifted by 1. This contradicts the IH backward. If w_0 > r_0: the bracket still needs beta_0 on (z_0, w_0). The B1 case has alpha_0.neg on (z_0, r_0), which only constrains alpha_0, not the bracket's validity at w_0 > r_0. The tail would be the sub-bracket from w_0 to z_1, which is bf.tail from w_0 not r_0.

**This is a problem.** The B1 backward proof needs: IH says bf.tail fails on (r_0, z_1), but the actual bracket uses w_0 which could be > r_0. The tail from w_0 to z_1 is a different interval than from r_0 to z_1.

Wait -- the IH gives us not just "bf.tail fails on (r_0, z_1)" but "neg_interval_formula_indep(bf.tail).holds on (r_0, z_1)." By IH backward, this means bf.tail fails on (r_0, z_1). But we need bf.tail to fail on (w_0, z_1) for w_0 > r_0. The IH only covers (r_0, z_1).

**This means the backward proof for B1 has a gap.** It requires that if neg_interval_formula_indep(bf.tail) holds on (r_0, z_1), then bf.tail also fails on any (w_0, z_1) with w_0 > r_0. This is NOT obviously true -- the negation VBracketFormula is specific to the interval (r_0, z_1).

### Root Cause of B1 Backward Gap

The problem is fundamental to the approach of using model-independent bracket formulas. The construction builds a FIXED formula whose correctness depends on the interval. For the backward direction, we need: "the formula holds on (z_0, z_1) implies the bracket fails on (z_0, z_1)." The B1 case produces a formula that includes witnesses for the IH on (r_0, z_1), but r_0 is model-dependent (it's the first alpha_0 occurrence in the specific model).

**Wait -- r_0 is NOT model-dependent in the model-independent construction.** Let me re-read the construction. In `neg_interval_formula_indep`, the B1 disjuncts are `VBracketFormula.prependAll alpha_0.neg alpha_0 ih`. These are bracket formulas with a first witness having alpha_0.neg before it and alpha_0 at it. When such a formula holds on (z_0, z_1), we get r_0 from prepend_holds_inv.

For the backward proof: if bf.holds(z_0, z_1) with witnesses w, and one of the B1 disjuncts holds on (z_0, z_1) with the prepended witness at r_0:
- alpha_0.neg on (z_0, r_0) and alpha_0(r_0)
- bf.tail fails on (r_0, z_1) by IH backward
- We need: bf fails on (z_0, z_1)
- Contrapositive of bracket_tail_satisfiable: if bf.holds(z_0, z_1), then either alpha_0 doesn't hold at w_0, or beta_0 fails on (z_0, w_0), or bf.tail holds on (w_0, z_1)
- For bf.holds with witness w_0: alpha_0(w_0), beta_0 on (z_0, w_0), bf.tail on (w_0, z_1)
- From alpha_0.neg on (z_0, r_0): w_0 >= r_0
- If w_0 = r_0: bf.tail holds on (r_0, z_1) contradicts IH backward -- done
- If w_0 > r_0: bf.tail holds on (w_0, z_1). But IH backward says bf.tail fails on (r_0, z_1). Does bf.tail holding on (w_0, z_1) contradict bf.tail failing on (r_0, z_1)? **NO**, because they're different intervals. bf.tail could fail on (r_0, z_1) but hold on (w_0, z_1) with w_0 > r_0.

**This is a genuine gap.** The B1 backward proof is also incomplete, not just B2.

### Revised Assessment

The backward direction for `neg_interval_formula_indep` has gaps in BOTH B1 and B2. The issue is structural: the model-independent construction uses the model-dependent first alpha_0 occurrence to choose the split point, but in the model-independent version, the split point is chosen syntactically and may not match the actual witness arrangement.

This confirms the orchestrator handoff's assessment: the backward direction is fundamentally more difficult than the forward direction.

---

## 7. Alternative Approach: Avoid Backward Direction Entirely

### Option 1: Forward-Only Prop 4.2 + Transfer

The forward direction `neg_2var_vec_ea_indep_correct` is sorry-free: if the original VVecEA2 fails, the negation VVecEA2 holds. For the Prop 4.3 induction, we need: the negation of a V-EA formula is a V-EA formula. Specifically:

```
neg v = neg_2var_vec_ea_indep v
correctness: v fails -> neg v holds  (FORWARD -- have it)
we also need: neg v holds -> v fails  (BACKWARD -- blocked)
```

Without the backward direction, we cannot show that `neg v` is semantically equivalent to `not v`. However, for the Prop 4.3 structural induction, what we actually need is:

**For negation case**: Given `phi(z_0, z_1)` is equivalent to some VVecEA2 `v`, show `not phi(z_0, z_1)` is equivalent to some VVecEA2 `v'`.

This requires: `v'` holds iff `not phi` holds, i.e., `v'` holds iff `v` fails. So we need both directions.

### Option 2: Restructure the Decomposition (Rabinovich-Faithful)

Restructure `neg_interval_formula_indep` to match Rabinovich's actual case analysis:

**Case 1** (endpoint failure): Not applicable since codebase doesn't have endpoint types in BracketFormula. But can be handled differently:
- Sub-case A: alpha_0 doesn't occur -> trivial bracket with alpha_0.neg everywhere

**Case 2** (beta_0 holds everywhere): If beta_0 holds on all of (z_0, z_1), then the bracket `[alpha_0, beta_0, ...](z_0, z_1)` reduces to: there exists x_0 in (z_0, z_1) with alpha_0(x_0) and bf.tail holds on (x_0, z_1) with beta_0 holding between x_0 and the next witness. Since beta_0 already holds everywhere, this reduces to: exists x_0 in (z_0, z_1) with alpha_0(x_0) and bf.rightPart holds on (x_0, z_1).

The negation is: for all x_0 in (z_0, z_1), either not alpha_0(x_0) or bf.rightPart fails on (x_0, z_1). This is NOT directly a V-bracket formula on (z_0, z_1). It's a bounded universal over x_0, which is exactly Corollary 5.4's domain.

**This is the same Corollary 5.4 that has a sorry in EANegation.lean (S2).** The model-independent biconditional Corollary 5.4 is needed for Case 2.

### Option 3: Model-Dependent Forward-Only + Semantic Argument

Use the model-dependent forward-only theorems (sorry-free) to prove equivalence semantically, without requiring a syntactically fixed biconditional negation formula.

For Prop 4.3 negation case, what we need is: for every MonadicFormula phi equivalent to a VVecEA2, not phi is also equivalent to a VVecEA2.

Step 1: Forward (have it): not v implies neg_2var_vec_ea_indep(v) holds
Step 2: We also need: neg_2var_vec_ea_indep(v) holds implies not v

Step 2 is the backward direction, which is blocked.

**However**: if we frame this differently, we can potentially use the model-dependent theorem to construct the biconditional. The model-dependent `neg_2var_vec_ea` says: for each model M, if v fails, there exists SOME VVecEA2 that holds. The model-independent `neg_2var_vec_ea_indep` constructs a FIXED VVecEA2 that works for all models. For the forward direction, we've shown the fixed VVecEA2 works. For the backward direction, we need that the fixed VVecEA2 doesn't hold when v does.

This is fundamentally different from the model-dependent case because the model-dependent version chooses a different VVecEA2 per model, and the backward direction is trivial (the chosen VVecEA2 is always disjoint from v by construction).

---

## 8. Recommended Path Forward

### Assessment Summary

| Approach | Feasibility | Lines | Risk |
|----------|------------|-------|------|
| Fix B.2 only (this report's main proposal) | Partial -- B.1 backward also has gaps | ~100 new + ~30 modified | HIGH |
| Restructure to Rabinovich-faithful decomposition | Requires Cor 5.4 biconditional (currently sorry) | ~300-500 | HIGH |
| Forward-only + semantic transfer | Avoids backward entirely | ~200-400 | MEDIUM |
| VecEA_m approach bypassing backward entirely | Per plan v31 (if backward avoided) | ~950-1630 | MEDIUM |

### Recommendation

The B.2 fix alone is **insufficient** because B.1 backward also has gaps. The fundamental issue is that the model-independent construction cannot guarantee disjointness because the split point (first alpha_0 occurrence) is model-dependent.

**Two viable paths**:

1. **Restructure neg_interval_formula_indep to match Rabinovich exactly**: Case-split on beta_0 failure rather than alpha_0 occurrence. This requires:
   - Fixing Corollary 5.4 biconditional (S2 from report 20) for the "beta_0 everywhere" sub-case
   - Complete restructuring of the construction (~300-500 lines)
   - The forward proof must also be rewritten

2. **Bypass the backward direction**: Use the forward-only model-dependent Prop 4.2 and a semantic argument to close the Prop 4.3 negation case without requiring a syntactically fixed biconditional. This requires careful model-transfer reasoning but avoids touching the sorry-free forward proof.

**Path 2 is recommended** because it preserves all existing sorry-free code and avoids the Corollary 5.4 biconditional problem entirely.

---

## 9. Detailed Design for Path 2 (Bypass Backward)

The key insight: for Prop 4.3, we don't need a syntactic biconditional. We need: given phi equivalent to VVecEA2 v, produce VVecEA2 v' equivalent to not phi. 

Since v is equivalent to phi, we have: v holds iff phi holds. So not phi holds iff v fails.

Using the forward direction: v fails -> neg_2var_vec_ea_indep(v) holds.

We need: neg_2var_vec_ea_indep(v) holds -> v fails (the backward direction).

**Alternative**: Define v' differently. Instead of using neg_2var_vec_ea_indep(v), use the model-dependent neg_2var_vec_ea to show that "not v" is expressible as SOME VVecEA2 (exists v'). Then use model-independence to show the v' is fixed.

The model-dependent theorem says: for each model M, there exists v'_M such that v'_M.holds iff not v.holds on M. But v'_M depends on M.

**The model-independent version constructs a single v' that works for all M (forward)**. The question is whether this v' is also correct backward.

**Alternative framing**: For Prop 4.3, we may not even need the biconditional at the VVecEA2 level. The structural induction operates on MonadicFormula, and the equivalence is between MonadicFormula and VVecEA_m. If we can show that VVecEA_m is closed under negation (at the formula level, not the bracket level), the backward direction might be avoidable.

This is exactly what plan v31's VecEA_m approach attempts: using de Morgan on the consecutive-pair product to avoid needing the backward direction of Prop 4.2 per se.

---

## 10. File Map and Lines

| File | Role | Lines to Modify | Lines to Add |
|------|------|-----------------|-------------|
| `NegationIndep.lean` | B.2 construction | ~8 lines (replace inf_bracket_formula with neg_b2_bracket_formula) | ~0 |
| `EANegationClosure.lean` | New neg_b2_bracket_formula definition + theorems | ~0 modified | ~80-120 new |
| `NegationIndep.lean` | Forward proof Case B2 | ~8 lines (replace lemma invocation) | ~0 |
| `NegationIndep.lean` | Backward proof (if pursued) | ~0 modified | ~150-250 new |

**Total for B.2 fix only**: ~80-120 new lines in EANegationClosure + ~16 modified lines in NegationIndep

**Total if full backward proof is pursued**: add ~150-250 lines, but B.1 backward remains unresolved

---

## 11. Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| B.2 fix works but B.1 backward still fails | HIGH | HIGH | Pursue Path 2 (bypass backward entirely) |
| Forward proof breaks after B.2 modification | LOW | LOW | Surgery is minimal; test with lake build after each change |
| neg_b2_bracket_formula forward proof harder than expected | LOW | LOW | Uses same HasAttainedINF machinery as inf_bracket_formula |
| Full Rabinovich restructure needed after all | HIGH | MEDIUM | Pre-assess Cor 5.4 biconditional feasibility before committing |

---

## 12. Summary of Key Findings

1. **B.2 fix is designed and concrete**: Replace `inf_bracket_formula(alpha_0)` with `neg_b2_bracket_formula(alpha_0, beta_0)` -- a 2-witness bracket encoding both alpha_0 occurrence and beta_0 failure.

2. **B.2 fix is insufficient for the backward direction**: Even with B.2 fixed, B.1's backward proof has an analogous gap where the IH's interval doesn't match the bracket's witness interval.

3. **Both gaps stem from the same root cause**: Model-independent bracket negation requires model-dependent split points (first alpha_0 occurrence), creating a mismatch between the syntactic formula and the semantic witnesses.

4. **Rabinovich avoids this problem** by placing alpha_0 at the endpoint z_0 (not an interior witness), so the "first occurrence" logic applies to beta_1 failure, not alpha_0 occurrence. The codebase's BracketFormula convention makes direct translation infeasible without restructuring.

5. **Recommended path**: Bypass the backward direction entirely via the VecEA_m approach (plan v31 Phases 2-4) or a semantic transfer argument.
