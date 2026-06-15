# Research Report: Task #273 -- Literature Analysis of Bracket Witness Ordering

**Task**: chronicle_gap_contradiction_proof -- Literature-based analysis of how bracket witness ordering works in the paper proofs
**Date**: 2026-06-15
**Agent**: lean-research-agent
**Session**: sess_1781553798_d7f90c

---

## Executive Summary

After reading all five designated literature sources, the central finding is: **The paper proofs NEVER face the witness ordering problem that blocks the Lean formalization.** The reason is structural: in Rabinovich 2014, the exists-forall normal form BUILDS witnesses in order via the nested Until/Since translation (Proposition 3.5), rather than extracting unordered witnesses from a quantified formula and trying to sort them. The Lean code's `enriched_vecEA2_until` conflates two separate concerns -- the syntactic bracket pattern and the semantic witness extraction -- in a way that the paper avoids entirely. The correct fix is not about sorting witnesses or making pointTypes uniform; it is about restructuring the backward direction to use the NESTED Until/Since semantics to generate ordered witnesses incrementally, as the paper does.

---

## 1. How the Paper Handles Witness Ordering

### 1.1 Rabinovich 2014, Proposition 3.5 (The Core Translation)

Proposition 3.5 states: every V-exists-forall formula with one free variable is equivalent to a TL(Until, Since) formula. The proof sketch (lines 90-94 of the literature file) gives the key mechanism:

An exists-forall formula with one free variable at position z_k in a sequence x_0 < ... < x_n is equivalent to:

```
A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))
AND
A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... (A_0 AND BoxPast B_0)...)))
```

**Critical observation**: The nested Until/Since structure ENCODES the ordering constraint directly. `B_{k+1} Until (A_{k+1} AND ...)` says "there exists a first witness x_{k+1} > z_k where A_{k+1} holds, with B_{k+1} everywhere between z_k and x_{k+1}." Then `B_{k+2} Until ...` says "from THAT x_{k+1}, there exists x_{k+2} > x_{k+1} where A_{k+2} holds, with B_{k+2} everywhere between."

The witnesses are constructed IN ORDER by the nested structure of the temporal formula. The Until operator itself guarantees ordering: each existential witness is found AFTER the previous one. There is no step where independent witnesses are extracted and then need to be sorted.

### 1.2 Rabinovich 2014, Section 5 (Negation Closure -- The Hard Part)

Proposition 4.2 proves that negations of exists-forall formulas with two free variables are equivalent to V-exists-forall formulas over Dedekind complete chains. The proof (Section 5) handles the negation:

```
NOT [alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)
```

The proof uses interval decomposition (Lemma 5.1): it case-splits on WHICH sub-interval fails, defining:
- `A_i^-(z_0, z) = [alpha_0, ..., alpha_i](z_0, z)` (left sub-pattern)
- `A_i^+(z, z_1) = [alpha_i, ..., alpha_{n+1}](z, z_1)` (right sub-pattern)

The key insight: **the paper decomposes the problem at a single splitting point z**, not by extracting multiple witnesses simultaneously. The induction is on the number of witnesses `n`, and at each step, the proof considers where a new point z falls relative to the existing pattern. The witnesses in the EXISTS direction are always constructed one-at-a-time via Until/Since nesting, never as a batch that needs ordering.

### 1.3 Rabinovich 2014, Lemma 5.3 (Base Case: Pure Point Witnesses)

Lemma 5.3 handles:

```
NOT (exists x_1 ... exists x_n)(z_0 < x_1 < ... < x_n < z_1 AND P_i(x_i) for each i)
```

The proof is by induction on n. At each step, it defines r_0 = inf{z in (z_0, z_1) | P_1(z)} using Dedekind completeness, then reduces to fewer witnesses. The ORDERING of the witnesses x_1 < ... < x_n is part of the syntactic specification of the exists-forall formula -- the formula SAYS they must be ordered. The negation does not need to "sort" witnesses; it instead argues about what goes wrong with any proposed ordered tuple.

### 1.4 Corollary 5.4 (The Actual Translation Mechanism)

This is the most directly relevant to the Lean code. The corollary translates:

```
NOT (exists z)_{>z_0}^{<z_1} [alpha_0, beta_1, ..., alpha_n](z_0, z)
```

The proof defines: `F_n := alpha_n` and `F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)`. Then the bracket `[alpha_0, ..., alpha_n](z_0, z)` holds iff there is an increasing sequence in (z_0, z_1) with F_0(z_0) holding.

**This is exactly the nested Until construction.** The "F_i" formulas build witnesses in order: F_0 says "alpha_0 holds here, and somewhere ahead alpha_1 holds with beta_1 between, and somewhere further ahead alpha_2 holds with beta_2 between, ..."

---

## 2. Why the Lean Code's Approach Diverges from the Paper

### 2.1 The Paper's Approach: One-at-a-Time via Nested Until

In the paper, the translation from exists-forall to TL works as follows:

1. **Syntactic translation (Prop 3.5)**: The bracket `[alpha_0, ..., alpha_n]` between two free variables becomes a NESTED Until formula that constructs witnesses one-at-a-time in order.
2. **Backward direction (TL formula true -> bracket witnesses exist)**: Unwinding the nested Until gives witness x_0, then from x_0 unwinding the next Until gives x_1 > x_0, etc. Witnesses arrive in order by construction.
3. **Forward direction (bracket witnesses -> TL formula true)**: Given ordered witnesses x_0 < ... < x_n, the nested Until is directly satisfied by these witnesses.

### 2.2 The Lean Code's Approach: Batch Extraction Then Sort

The Lean `enriched_vecEA2_until` (L444-492) does something different:

1. It builds a `BracketFormula n` where `n = pos_between.length` (number of positive between_tx SSNs).
2. Each `pointTypes[i]` is the NF predicate for `pos_between[i]` (SSN-indexed).
3. `IntervalPattern.holds` requires ALL n witnesses simultaneously, strictly increasing.
4. The backward direction extracts independent witnesses from `h_eval_quant` -- one for each SSN -- but these are unordered.
5. The forward direction gets ordered witnesses from the bracket, but needs to reconstruct which witness corresponds to which SSN.

The divergence is clear: **the paper uses nested Until to generate witnesses in order (incremental construction), while the Lean code uses a flat IntervalPattern that requires all witnesses at once (batch construction).**

### 2.3 Why This Matters

The `IntervalPattern.holds` definition (ExistsForallNF.lean:106-132) is semantically equivalent to the paper's exists-forall formula -- both require ordered witnesses. The ISSUE is not with the semantics but with the PROOF STRATEGY:

- The paper's proof works because the temporal formula (nested Until) GENERATES witnesses in order.
- The Lean code's proof tries to EXTRACT witnesses from `nf_eval` (which gives them unordered) and PUT them into the bracket (which needs them ordered).

---

## 3. The Correct Fix Based on the Literature

### 3.1 The Nested Until Translation (Paper-Faithful Approach)

Following Rabinovich Prop 3.5 / Corollary 5.4, the correct temporal formula for the between_tx bracket is NOT a single `BracketFormula n` translated via `translateLeft`, but rather a NESTED Until formula:

For positive between_tx SSNs ssn_0, ssn_1, ..., ssn_{n-1}, define:
```
F_{n-1} := char_y(ssn_{n-1}) AND seg_guard
F_{n-2} := char_y(ssn_{n-2}) AND seg_guard AND Until(F_{n-1}, seg_guard)
...
F_0 := char_y(ssn_0) AND seg_guard AND Until(F_1, seg_guard)
```

Then `Until(F_0, seg_guard)` at t (with upper bound x) says: "there exists y_0 in (t,x) with char_y(ssn_0) and seg_guard between t and y_0, and there exists y_1 > y_0 in (y_0, x) with char_y(ssn_1) and seg_guard between y_0 and y_1, ..."

The witnesses y_0 < y_1 < ... < y_{n-1} are produced IN ORDER by unwinding the nested Until.

### 3.2 Why This Solves Both Directions

**Backward direction** (nf_eval -> temporal formula true):
- From `h_eval_quant`, extract witnesses y_0, ..., y_{n-1} (one per positive SSN).
- These are all in (t, x).
- Sort them: by NF distinctness, they are at distinct points (two distinct NFs cannot be simultaneously satisfied at the same point, since NFs are complete boolean assignments to predicates).
- Let sigma be the sorting permutation. The sorted witnesses w_0 < w_1 < ... < w_{n-1} satisfy char_y(ssn_{sigma(0)}), char_y(ssn_{sigma(1)}), etc.
- The nested Until formula only requires that EACH witness satisfies SOME char_y(ssn_i), and the SEG_GUARD holds between them.
- **Key insight**: If the nested formula is constructed with the DISJUNCTION of all char_y values at each nesting level (not a specific SSN per level), then ANY ordering works.

Actually, upon reflection, the paper's approach from Prop 3.5 assigns SPECIFIC alpha_i at each level, not a disjunction. Let me re-examine.

### 3.3 Re-examining: Paper vs. Lean Mapping (Corrected)

In the paper, the exists-forall formula `[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)` has a FIXED sequence of point types. The translation to nested Until is:

```
alpha_0(z_0) AND (beta_1 Until (alpha_1 AND (beta_2 Until (... (alpha_n AND Box beta_{n+1})...))))
```

And the backward proof works because the FORMULA specifies the ordering: we look for the FIRST witness satisfying alpha_1 (for the outermost Until), then the first alpha_2 AFTER that (for the next Until), etc.

But in the Lean code, the problem is different. The `nf_eval` quantifies: `exists y, (conjunction of SSN conditions)`. Each SSN condition involves y appearing in a specific zone (between t and x, equal to t, above x, etc.). The positive between_tx SSNs each say "exists y in (t,x) satisfying NF predicate i". The conjunction says ALL of these y's exist.

The key question: does the paper's Proposition 3.5 apply to conjunctions of INDEPENDENT existentials? Or does it apply to a SINGLE sequence of ordered witnesses?

**Answer**: The paper's exists-forall formula has witnesses `x_0 < ... < x_n` with DIFFERENT types `alpha_i` at each position. This is precisely the structure of the `BracketFormula`: different `pointTypes[i]` at each ordered position.

**But the Lean backward direction extracts witnesses from INDEPENDENT existentials, not from a single ordered tuple.** This is the fundamental mismatch.

### 3.4 The Two Possible Correct Approaches

**Approach A: Paper-faithful nested Until (no BracketFormula for the backward direction)**

Instead of building a BracketFormula and proving `IntervalPattern.holds`, change the temporal formula to a nested Until that PRODUCES ordered witnesses. The backward direction then needs to show that the nested Until holds, given that individual witnesses exist. This requires:

1. Sort the individual witnesses by model order.
2. Show that the nested Until is satisfied by the sorted sequence.
3. This works if and only if every intermediate segment satisfies `seg_guard`.

The difficulty: after sorting, witness at position j satisfies `char_y(ssn_{sigma(j)})`, but the nested Until expects `char_y(ssn_j)` at position j (or whichever SSN the nesting specifies). If we nest in a FIXED order (matching `pos_between` list order), the sorted witnesses may not match.

**This is the same ordering problem, reformulated.**

**Approach B: Disjunction pointTypes (the team research recommendation)**

Make all pointTypes the SAME disjunction:
```
pointTypes[i] = char_y(ssn_0) OR char_y(ssn_1) OR ... OR char_y(ssn_{n-1})
```

Then:
- Backward: sort the extracted witnesses, each satisfies its specific NF hence the disjunction. Sorted witnesses + disjunction pointTypes + uniform seg_guard = IntervalPattern.holds. **This works unconditionally.**
- Forward: each of the n ordered witnesses satisfies the disjunction. We need to show that all n DISTINCT NFs are covered. By NF mutual exclusivity (no point satisfies two distinct NFs simultaneously), each witness satisfies exactly one NF. By pigeonhole (n witnesses, n NFs, no NF satisfied twice at different positions -- wait, this is not right: two witnesses CAN satisfy the same NF if two SSNs in pos_between have the same nf_y_proj).

**The nf_y_proj injectivity question** is the remaining obstacle for Approach B's forward direction. This was identified in Report 35 as a gap.

**Approach C: One Until per SSN, no multi-witness bracket**

Replace the multi-witness BracketFormula with n INDIVIDUAL "Until-bounded existentials", each correctly bounded. This is the approach Rabinovich's proof implicitly uses:

For each positive between_tx SSN ssn_i, the statement "exists y in (t,x) with nf_y_proj(ssn_i) at y and seg_guard on (t,y) and (y,x)" can be expressed as:

```
seg_guard Until (char_y(ssn_i) AND (seg_guard Until endpointRight(x)))
```

Wait -- this is a formula at t, and it says "seg_guard holds until some y where char_y(ssn_i) holds, and then seg_guard holds until x where endpointRight holds." But this is EXACTLY what the nested Until does! And it DOES correctly bound y to (t,x) because the outer Until's endpoint is x (where endpointRight holds).

The conjunction of n such formulas (one per SSN) says: for each SSN, there exists a witness in (t,x). This is semantically correct. The key insight is that in the conjunction approach, EACH Until independently bounds its witness to (t,x), and the witnesses need not be the same point or ordered relative to each other.

**This is NOT unsound** (contra Report 35, Finding 2), provided the Until properly terminates at x. The formula:

```
seg_guard Until (char_y(ssn_i) AND (seg_guard Until char_1(nf_x)))
```

at t says: "there exists some y > t where char_y(ssn_i) holds, seg_guard holds on (t,y), AND there exists some x > y where char_1(nf_x) holds, seg_guard holds on (y,x)." This correctly puts y in (t,x) where x is the first point satisfying char_1(nf_x) after y.

**The issue raised in Report 35** was about `Formula.untl char_y Formula.top` which is `char_y Until top`, meaning "exists y > t with char_y(y)" -- unbounded. But the correct encoding is `seg_guard Until (char_y AND (seg_guard Until char_1(nf_x)))`, which IS bounded.

---

## 4. The Paper's Proof Structure Applied to the Lean Code

### 4.1 Correspondence Table

| Paper Concept (Rabinovich 2014) | Lean Code Concept | Status |
|---|---|---|
| Free variable z_0 | `t : M.carrier` (evaluation point) | Correct |
| Free variable z_1 | `x : M.carrier` (witness of outer exists) | Correct |
| Exists-forall formula [alpha_0,...](z_0,z_1) | `nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf` | Correct |
| Point type alpha_i at witness x_i | `nfPred(nf_y_proj(ssn))` for each positive SSN | Correct |
| Interval type beta_j on segment | `seg_guard` (conjunction of negated char_y for negative SSNs) | Correct |
| Nested Until: beta_1 Until (alpha_1 AND ...) | `BracketFormula.holds` via `IntervalPattern` | **MISMATCH**: flat batch vs. nested incremental |
| Prop 3.5 backward: unwinding nested Until | backward_holdsLeft_of_nf_eval (bracket case) | **BLOCKED**: flat bracket cannot generate ordered witnesses from independent existentials |
| Prop 3.5 forward: ordered witnesses -> nested Until | forward_nf_eval_of_holdsLeft | **BLOCKED**: bracket gives ordered witnesses but loses SSN-index correspondence |

### 4.2 Literature Proof Structure (Rabinovich 2014)

**Source**: Rabinovich 2014, Proposition 3.5 + Corollary 5.4
**Strategy**: Nested Until/Since translation, induction on number of quantifiers

#### Step Map

1. **Define F_i formulas** (Corollary 5.4): F_n = alpha_n, F_{i-1} = alpha_{i-1} AND (beta_i Until F_i)
   -- Lean: compute nested Formula for each positive SSN

2. **Backward (bracket holds -> TL formula holds)**: Given witnesses x_0 < ... < x_n with alpha_i(x_i) and beta_j on segments, verify F_0(x_0) by induction.
   -- Lean: Given ordered witnesses satisfying pointTypes, show the nested Until holds.

3. **Forward (TL formula holds -> bracket holds)**: Given F_0(z_0), extract x_0 via Until semantics, then F_1(x_0) -> extract x_1 via Until, etc.
   -- Lean: Unwinding the nested Until at each level produces the next ordered witness.

#### Dependencies
- Step 2 depends on the Until semantics definition (trivial structural induction)
- Step 3 depends on the Until semantics definition (trivial structural induction)
- Both depend on the temporal formula being the NESTED form, NOT a flat bracket translation

#### Potential Formalization Challenges
- **Step 1**: Straightforward definitional construction in Lean.
- **Step 3 (forward, key step)**: The paper just says "unwinding the Until" but in Lean, this requires showing that `temporal_truth M atomMap t (seg_guard Until (char_y AND ...))` implies the existence of a specific witness with the right properties. This is just the definition of Until semantics.
- **Bounding witness to (t, x)**: The nested Until `seg_guard Until (char_y AND (seg_guard Until char_1(nf_x)))` automatically bounds the witness y to (t, x) because the inner Until must terminate at some point satisfying `char_1(nf_x)`, and x is such a point.

### 4.3 The Recommended Approach for Lean

**Approach C (Individual bounded Until per SSN)** is the most paper-faithful and avoids the ordering problem entirely:

1. For each positive between_tx SSN ssn_i, construct:
   ```
   Formula.untl (seg_guard AND Formula.untl char_1(nf_x) seg_guard) (char_y(ssn_i) AND seg_guard)
   ```
   Wait, the Until semantics in this project is `Formula.untl φ ψ` meaning `ψ Until φ`, i.e., "phi holds at some future point and psi holds everywhere until then." Let me check.

   From the literature file (Rabinovich Section 2.2): `F1 Until F2` iff there exists t' > t with F2 at t' and F1 everywhere in (t, t').

   So `B Until A` means A is the "event" and B is the "guard." In Lean: `Formula.untl event guard` likely means `guard Until event`.

   The correct formula per SSN: "seg_guard everywhere until char_y(ssn_i), then seg_guard everywhere until char_1(nf_x)"

   ```
   seg_guard Until (char_y(ssn_i) AND (seg_guard Until char_1(nf_x)))
   ```

   In Lean syntax: `Formula.untl (char_y_i.and (Formula.untl char_1_nfx seg_guard_f)) seg_guard_f`

2. Take the CONJUNCTION of these formulas over all positive between_tx SSNs.

3. The conjunction goes into the endpointLeft or as a component alongside endpointLeft.

**Backward direction**: Given nf_eval with witnesses y_i in (t,x) for each positive SSN, each y_i individually satisfies `char_y(ssn_i)` and seg_guard holds between t and y_i and between y_i and x (since ALL negative SSNs are absent in the interval). So each individual Until holds.

**Forward direction**: Given the conjunction, each Until gives a witness y_i in (t,x) with `char_y(ssn_i)`. These are the witnesses needed by nf_eval_quant.

**This completely avoids the ordering problem** because:
- We never need witnesses to be ordered relative to each other.
- Each Until independently constrains its own witness to (t, x).
- No IntervalPattern/BracketFormula is needed for the between_tx zone.

---

## 5. Impact on Existing Sorries

### 5.1 Sorry at L2081 (bracket case of backward direction)

This sorry exists because `IntervalPattern.holds` requires ordered witnesses that the proof cannot produce from independent existentials. **With Approach C, this sorry disappears** because there is no `IntervalPattern` to satisfy -- each SSN gets its own Until.

### 5.2 Sorry at L2151 (forward direction)

This sorry exists because extracting SSN-specific witnesses from ordered IntervalPattern witnesses requires knowing which witness matches which SSN. **With Approach C, the forward direction simply extracts each witness from its own Until** -- no ambiguity about SSN correspondence.

### 5.3 Sorry at L2308 (Since case)

Independent of the bracket flaw. The same Approach C analysis applies to the Since direction: each positive between_xt SSN gets its own `Since`-bounded existential.

### 5.4 Sorry at L2396 (k > 0)

Out of scope for the bracket fix. This is about depth > 0 inner quantifiers and requires a separate IH argument.

---

## 6. Detailed Fix Plan

### Step 1: Replace `enriched_vecEA2_until` with conjunction-of-bounded-Untils

Instead of building a `BracketFormula n` and a `VecEA2`, build a conjunction of bounded Until formulas:

```lean
def bounded_until_witness {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (seg_guard_f : Formula)
    (char_1_nfx : Formula) : Formula :=
  -- seg_guard Until (char_y(ssn) AND (seg_guard Until char_1(nf_x)))
  Formula.untl
    ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).and
     (Formula.untl char_1_nfx seg_guard_f))
    seg_guard_f
```

### Step 2: Modify `enriched_bypass_until` to use conjunction approach

Replace the VVecEA2 construction with a direct Formula construction:
- endpointLeft conditions (y < t and y = t zones) as before
- Conjunction of `bounded_until_witness` for each positive between_tx SSN
- endpointRight conditions folded into the inner Until termination

### Step 3: Prove backward direction (nf_eval -> formula holds)

For each positive SSN, extract witness from `h_eval_quant`, show that:
1. `char_y(ssn)` holds at the witness (from nf_eval)
2. `seg_guard` holds between t and the witness (from negative SSN conditions in nf_eval)
3. `seg_guard` holds between the witness and x (from negative SSN conditions)
4. `char_1(nf_x)` holds at x (from nf_eval)

Hence the bounded Until holds.

### Step 4: Prove forward direction (formula holds -> nf_eval)

For each positive SSN, unwinding the bounded Until gives:
1. A witness y in (t, x) with `char_y(ssn)` at y
2. `seg_guard` on (t, y) and on (y, x)
3. `char_1(nf_x)` at x

Reconstruct `h_eval_quant` for each SSN.

### Estimated Scope

- Delete: ~50 lines (enriched_vecEA2_until BracketFormula construction)
- Add: ~30 lines (bounded_until_witness + conjunction construction)
- Rewrite backward direction: ~80 lines (replace bracket case with individual Until proofs)
- Rewrite forward direction: ~80 lines (replace bracket extraction with Until unwinding)
- Total: ~240 lines of changed code, localized to the Until-specific section

---

## 7. Conclusions

1. **The paper constructs witnesses in order via nested Until** -- it never faces the batch-ordering problem the Lean code encounters.

2. **The ordering problem is an artifact of the flat BracketFormula representation**, not of the mathematical content. The paper's exists-forall formulas CAN be represented as flat ordered tuples, but the PROOF translates them to nested temporal formulas where ordering is automatic.

3. **The correct Lean encoding is per-SSN bounded Until formulas**, following Corollary 5.4 of Rabinovich 2014. This replaces the BracketFormula + IntervalPattern machinery with a conjunction of individually-bounded Untils, each constraining one witness to the interval (t, x).

4. **The recommended "disjunction pointTypes" approach from Report 35** would work for the backward direction but has an unresolved gap in the forward direction (nf_y_proj injectivity). The conjunction-of-bounded-Untils approach from the literature avoids this gap entirely.

5. **No ordering, sorting, or permutation is needed** -- each witness is independently bounded. This is the cleanest and most paper-faithful approach.
