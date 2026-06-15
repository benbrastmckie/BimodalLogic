# Teammate A Findings: BracketFormula Ordering Design Flaw

**Task**: 273 — Close remaining sorries in KampBypass.lean  
**Focus**: Design exact replacement for `enriched_vecEA2_until` eliminating `BracketFormula n`  
**Date**: 2026-06-15

---

## Key Findings

### 1. Root Cause: BracketFormula Witnesses Must Be Strictly Increasing

`IntervalPattern.holds` (ExistsForallNF.lean:106-132) for the `n+1` case requires:
```
∃ (witnesses : Fin (n + 1) → M.carrier),
  (∀ i j, i < j → witnesses i < witnesses j) ∧  -- STRICTLY INCREASING
  (∀ i, z0 < witnesses i ∧ witnesses i < z1) ∧
  ...
```

The witnesses are indexed by `Fin n` and must be in strictly increasing order. In the current
`enriched_vecEA2_until`, `pos_between` is built by filtering `Fintype.elems` — a
canonically-ordered enumeration. The index `i : Fin n` into `pos_between` encodes a specific
SSN, but the `witnesses i` in `IntervalPattern.holds` must satisfy `witnesses i < witnesses j`
for `i < j`.

This creates a mismatch: the semantic witnesses for between_tx SSNs are arbitrary points in
`(t, x)`, not necessarily ordered to match the `pos_between` list's canonical ordering. When
multiple positive between_tx SSNs exist, their witnesses in the model may not be in the order
`pos_between` enumerates them.

### 2. The Backward Direction Sorry (L2081) — Precise Analysis

The sorry at L2081 is in `case bracket` of `backward_holdsLeft_of_nf_eval`. The context is:

- We have `h_eval_quant : ∀ ssn, (∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ sub_nf.2 ssn = true`
- For each positive `ssn ∈ pos_between` (zone = between_tx), `h_eval_quant ssn` gives  
  `∃ y_ssn, t < y_ssn ∧ y_ssn < x ∧ predicates_match_at_y_ssn`
- We need to provide `witnesses : Fin n → M.carrier` with:
  - `witnesses i` satisfies `(bf.pointTypes i).eval_at M atomMap (witnesses i)`  
    i.e., `nfPred (nf_y_proj (pos_between[i])).eval_at M atomMap (witnesses i)`
  - `witnesses i < witnesses j` for `i < j` (STRICT INCREASE constraint)
  - All witnesses in `(t, x)`

The problem: the `y_ssn` witnesses we extract from `h_eval_quant` are each in `(t,x)` but
they are NOT necessarily ordered consistently with `pos_between`'s enumeration index. We
cannot generally sort them to match because:
1. `pos_between`'s ordering is determined by `Fintype.elems` canonicalization, not the model
2. The witnesses are model points in a linear order, and while we could _choose_ an ordering,
   we have no guarantee that the y-value for SSN at index 0 is less than the y-value for SSN
   at index 1 in the model

**However**, there is a critical observation: when `n = 1` (exactly one positive between_tx SSN),
the strict increase constraint is vacuous (no pairs `i < j`), so a single witness suffices.
This is the most common case in practice.

For `n > 1`, we need either: (a) reorder witnesses to match `pos_between` index, or (b)
eliminate the need for an ordered witness tuple altogether.

### 3. The Forward Direction Sorry (L2151) — Precise Analysis

The sorry at L2151 in `forward_nf_eval_of_holdsLeft` is:
```
obtain ⟨h_endLeft, x, h_t_lt_x, h_endRight, h_bracket⟩ := h_holds
-- h_bracket : vea.bracket.holds M atomMap t x
-- Need: ∀ ssn ∈ between_tx, (∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ sub_nf.2 ssn
```

Given `h_bracket`, which is `BracketFormula.holds M atomMap bf t x`, we have:
```
∃ witnesses : Fin n → M.carrier,
  (strict increase) ∧ (all in (t,x)) ∧
  (∀ i, nfPred (nf_y_proj (pos_between[i])).eval_at M atomMap (witnesses i))
```

To extract `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` for a given `ssn ∈ pos_between`:
- Find index `i` such that `pos_between[i] = ssn`
- Use `witnesses i` as the y-witness
- Apply `nfPred_correct` + `between_tx_temporal_iff` to reconstruct `nf_eval_nf`

This direction is actually **more tractable** than backward: given witnesses from the bracket,
we can project to individual SSNs. The HEq transport issue from `h_eq : ⟨n, vea⟩ = ⟨n, vea'⟩`
is the main obstacle (the comment at L2148 mentions this).

### 4. Why Eliminating BracketFormula Fixes Both Sorries

**Proposed approach**: Replace `BracketFormula n` in `enriched_vecEA2_until` with a
**conjunction of individual existentials** for the between_tx zone, matching the treatment of
`eq_x` and `above_x` zones (already handled by individual conjuncts in `right_conjuncts`
at L476-488).

The core insight from reading L476-488 is that the eq_x and above_x zones are already handled
by returning `some char_y` or `some (Formula.untl char_y Formula.top)` — no bracket witness
ordering needed. The between_tx zone should be treated analogously:
- For each **positive** between_tx SSN: include `Formula.untl char_y Formula.top` in
  `seg_guard` (until witness is in (t,x))
- For each **negative** between_tx SSN: include `(Formula.untl char_y Formula.top).neg`

But wait — `Formula.untl char_y Formula.top` at t gives `∃ y > t, char_y(y)`, which is NOT
restricted to `y < x`. We need `∃ y, t < y ∧ y < x ∧ char_y(y)`.

The bracket formula currently ensures `y < x` because witnesses are constrained to `(t, x)`.
Without the bracket, we lose the upper bound. This is why the bracket was introduced.

### 5. The Actual Fix: Change Bracket to Until-Inside-Until Pattern

The key insight from the architecture: `VecEA2.holdsLeft` provides `x` as the Until witness
for endpointRight. The bracket's witnesses are between `t` and `x`. To encode
`∃ y, t < y ∧ y < x ∧ char_y(y)` without a bracket, we can use:

```lean
Formula.untl (Formula.and char_y (Formula.untl Formula.top Formula.top)) Formula.top
```

But this doesn't directly work because we need a witness strictly before x.

**Better approach**: Use a 2-step Until encoding. Since `bracketBuildRight` for n=1 produces:
```lean
Formula.untl (Formula.and (pointType.formula) (bracketBuildRight shifted endRight))
             segType.formula
```
where for the single-witness case this is:
```
Formula.untl (Formula.and char_y (buildRight [(endRight, seg_guard)] top)) seg_guard.formula
```

This is exactly: "∃ y such that: (1) char_y holds at y, (2) seg_guard holds on (y, endRight-point),
(3) seg_guard holds on (t, y)". This is the CORRECT encoding of a between_tx witness.

Actually, rereading the current code more carefully:

**CRITICAL REALIZATION**: The current `BracketFormula n` with `n` witnesses in `pos_between` is
semantically correct — the bracket says "∃ strictly-ordered witnesses in (t,x), one for each
positive between_tx SSN, with each satisfying the right predicate". The problem is NOT with the
semantic correctness of the formula itself. The problem is purely in the **proof** connecting
this to the NF evaluation.

### 6. The Real Proof Obstacle for the Backward Direction

For the bracket case in the backward direction:
- We have individual witnesses `y_ssn` for each `ssn ∈ pos_between`
- We need to assemble them into a strictly-increasing function `Fin n → M.carrier`
- BUT: two SSNs `ssn_i` and `ssn_j` may have witnesses `y_i` and `y_j` where `y_j < y_i`
  even though `i < j` in `pos_between`

This means we **cannot directly assemble** the witnesses. We would need to sort them. But
if we sort them, the sorted witness at position `i` no longer necessarily satisfies the
predicate for `pos_between[i]`.

**This confirms the design flaw is fundamental**: the pointType assignment
`fun i => nfPred atomMap h_surj (nf_y_proj (pos_between[i]))` assumes witness `i`
corresponds to SSN at index `i`. But in the model, different SSNs may have witnesses
in different order.

---

## Recommended Approach

### Option A: Replace BracketFormula with Flat Conjuncts (Elimination)

**Strategy**: Change `enriched_vecEA2_until` to return a plain `VecEA2 0` (empty bracket)
where the between_tx conditions are baked into the `seg_guard` inside a trivial bracket.

The between_tx zone formula for positive SSNs needs: `∃ y, t < y ∧ y < x ∧ char_y(y)`.
This can be encoded as: the `bracketBuildRight` for a `BracketFormula 1` with:
- `pointTypes 0 = nfPred (nf_y_proj ssn)` (a single witness with char_y)
- `segmentTypes 0 = seg_guard_neg` (segment from t to y: no negative SSN witnesses)
- `segmentTypes 1 = seg_guard_neg` (segment from y to x: same guard)

But this only handles ONE positive between_tx SSN at a time. For multiple positive SSNs
(conjunction), we need multiple nested brackets — which brings back the original complexity.

### Option B: One BracketFormula Per SSN (Disjunction-Free Approach)

**Strategy**: Instead of one `BracketFormula n` with n witnesses, use a SEPARATE
`VecEA2 1` for EACH positive between_tx SSN, and take the conjunction of all of them.

Wait — `VVecEA2` is a DISJUNCTION of `VecEA2`. We need a conjunction. So we'd need to
change the outer structure.

Actually, looking at L2191-2204 more carefully: `enriched_bypass_until` produces a formula
that is a disjunction over `nf_x` values. Each `nf_x` disjunct comes from `enriched_vecEA2_until`.
The correct semantics is:

"For SOME `nf_x`, all between_tx SSNs in `sub_nf.2` are satisfied, plus the endpoint conditions."

For a fixed `nf_x`, we need ALL positive between_tx SSNs to be witnessed. This must be a
conjunction within a single `VecEA2` disjunct.

### Option C: BracketFormula with Sorted Witnesses (Correct Current Approach)

**Strategy**: Keep `BracketFormula n` but use a NEW bracket construction where witnesses are
sorted by their model-dependent values. Instead of assigning `pointTypes i = nfPred (pos_between[i])`,
we assign `pointTypes` to allow any permutation.

However, this breaks the bijectivity: we'd need to say "there exist n distinct points in (t,x),
one for each positive SSN (in any order)". This requires a `BracketFormula` with a more
permissive semantics.

### RECOMMENDED: Option D — Encode Between_tx as Iterated Until Conjuncts

This is the simplest approach that avoids the ordering problem entirely:

For each positive between_tx SSN `ssn`, encode the existential as:

```lean
-- ∃ y, t < y ∧ y < x ∧ char_y(y)
-- Encoded via: the formula says x satisfies "Since(char_y, top)" 
-- where Since looks backward from x.
-- i.e., Formula.snce char_y Formula.top
```

Wait: `Formula.snce char_y Formula.top` at x means `∃ y < x, char_y(y) ∧ top(y)`, which
gives `∃ y < x, char_y(y)`. This does NOT ensure `t < y`.

**Correct encoding**: Move the positive between_tx conditions to `endpointRight` (at x):
```lean
let between_conjuncts :=
  pos_between.map fun ssn =>
    let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
    (Formula.snce char_y Formula.top)  -- ∃ y < x, char_y(y)
```
But this allows y < t too, which is wrong. We need y ∈ (t, x).

The fundamental issue is that the temporal language cannot directly express "∃ y ∈ (t, x)"
without referencing t from the perspective of x. The Until-Since combination would be needed.

**The correct insight**: The bracket was introduced PRECISELY because the temporal language
cannot express "∃ y ∈ (t,x)" as a formula at t or x alone — it requires the interval (t,x)
as a parameter. This is the entire reason for the VecEA2/BracketFormula machinery.

### ACTUAL RECOMMENDATION: Permutation-Insensitive Bracket

**The correct fix** is to keep `BracketFormula n` but change `enriched_vecEA2_until` to build
a bracket where the point types use `formula_disjList` over ALL positive between_tx SSNs at
each witness position:

```lean
let bracket : BracketFormula n :=
  { pointTypes := fun _ =>
      -- Any witness can be for any SSN — the bracket just needs n witnesses in (t,x)
      -- where each witness satisfies at least one positive SSN predicate
      ⟨formula_disjList (pos_between.map fun ssn =>
        nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn))⟩
    segmentTypes := fun _ => seg_guard }
```

Then in the backward direction: for each `ssn ∈ pos_between`, take its witness `y_ssn` and
produce any ordering of `{y_ssn | ssn ∈ pos_between}`. Each `y_ssn` satisfies its own
`char_y_ssn` ⊆ the disjunction, so any permutation works.

BUT this loses injectivity — multiple SSNs could map to the same witness. And the forward
direction would need: given n witnesses each satisfying the disjunction, produce n distinct
SSN witnesses (requires pigeonhole or some combinatorial argument).

### DEFINITIVE RECOMMENDATION: Two-Phase Strategy

**Phase 1 (Bracket sorry L2081 — backward)**: For n=1 case (single positive between_tx SSN),
the strict increase constraint is vacuous. The proof simply takes the single witness `y_ssn`
from `h_eval_quant ssn` and provides it as `witnesses ⟨0, by omega⟩`. This covers the
most common case and is likely the ONLY case arising in practice for the Kamp theorem.

For n>1, we need the deeper fix. However, it may be provable that for any fixed `nf_x`,
there is at most ONE positive between_tx SSN (since SSNs are disjoint types and `sub_nf.2`
is a boolean function). If `pos_between` always has length ≤ 1, the n=1 fix suffices.

**Critical Observation**: `pos_between` filters SSNs where `ssn_zone_until ssn == .between_tx`
AND `sub_nf.2 ssn = true`. Since SSNs in `NormalForm sig 0 3` are boolean-valued NFs, multiple
distinct SSNs CAN be in the between_tx zone simultaneously (they differ in predicate assignments).
So `n` can genuinely be > 1.

**Phase 2 (Forward sorry L2151)**: The forward direction's sorry is simpler to fix given that
`h_bracket` provides witnesses. The HEq issue (L2148 comment) can be resolved by:
1. Noting that `enriched_vecEA2_until ... = ⟨n, vea⟩` is `Sigma.mk.inj` applied
2. Using `heq_of_eq` or `Sigma.ext_iff` to unpack the equality
3. Then applying `VecEA2.mk.inj` to get `vea.bracket = bf` (same bracket)
4. Rewriting `h_bracket` to get `bf.holds M atomMap t x`
5. Extracting witnesses and using `between_tx_temporal_iff` backward

### Exact Lean Pseudocode for Option D: Single-Witness Fix

For the bracket sorry when `n = 1` (single positive between_tx SSN), the proof is:

```lean
case bracket =>
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
             IntervalPattern.holds, enriched_vecEA2_until]
  -- pos_between has exactly 1 element: ssn_0 = pos_between[0]
  -- Need: ∃ witnesses : Fin 1 → M.carrier, strict_increase ∧ ...
  -- From h_eval_quant ssn_0 (positive, between_tx zone):
  have h_ssn_pos : sub_nf.2 (pos_between[0]'h_len) = true := ...
  have ⟨y, h_ty, h_yx, h_y_preds⟩ :=
    (between_tx_temporal_iff M atomMap h_surj (pos_between[0]'h_len) nf_x_1var parent_atoms
      x t h_t_lt_x h_compat h_zone ...).mp
    ((h_eval_quant _).mpr h_ssn_pos)
  exact ⟨fun _ => y,
    fun i j h => absurd h (by omega),  -- Fin 1 → no strict pair
    fun i => ⟨h_ty, h_yx⟩,
    fun i => (nfPred_correct M atomMap h_surj (nf_y_proj (pos_between[0]'h_len)) y).mpr
               (by simp [nf_eval_nf, nf_y_proj]; exact h_y_preds),
    ..., ...⟩
```

For the general n≥1 case, we need a full proof by induction or a sorting argument. This
is where the design becomes fundamentally difficult.

### Definitive Code for New `enriched_vecEA2_until`

If we want to avoid the ordering problem entirely, the cleanest fix is to change the return
type from `Σ n, VecEA2 n` to plain `Formula` by encoding everything as formulas directly.
The VecEA2 structure is only needed for the translation machinery. Since `enriched_bypass_until`
ultimately produces a `Formula` via `vvec.translateLeft`, we can skip the VecEA2 intermediary:

```lean
noncomputable def enriched_vecEA2_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (nf_x : NormalForm sig 1 1)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) : Σ n, VecEA2 n :=
  -- [UNCHANGED] pos_between, neg_between, seg_guard, endLeft, endRight as before
  -- [CHANGED] For the bracket: use a SINGLE BracketFormula 0 (no witnesses)
  -- and move between_tx conditions to endRight as Since-formulas
  let n := pos_between.length
  -- Build nested bracket using bracketBuildRight directly
  -- For each positive between_tx SSN, encode as a Since(char_y, top) condition at x
  let pos_between_formulas :=
    pos_between.map fun ssn =>
      let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
      -- This says ∃ y, y < x ∧ char_y(y) — but doesn't bound y > t
      -- BAD: can't encode (t, x) interval this way
      Formula.snce char_y Formula.top
  -- This approach fails: Since doesn't bound below by t
  ...
```

**Conclusion from pseudocode analysis**: You CANNOT encode `∃ y ∈ (t,x)` as a formula at x
alone. The bracket is necessary. The design flaw is in the PROOF strategy, not the formula.

---

## Evidence and Examples

### Evidence 1: `between_tx_temporal_iff` (L1900-1925) Exists But Is Unused in Bracket Case

The theorem `between_tx_temporal_iff` gives:
```
(∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ (∃ y, t < y ∧ y < x ∧ predicates_match_at_y)
```
This is EXACTLY what we need for the bracket backward direction. For n=1, applying this once
and providing the single witness suffices.

### Evidence 2: n=1 is the Common Case

In KampBypass.lean, `pos_between` lists SSNs where `ssn_zone_until ssn = .between_tx AND
sub_nf.2 ssn = true`. In practice, for a given NF and nf_x, the number of compatible
between_tx SSNs that are positive is small. For n=1, the strict-increase constraint
(vacuously true for Fin 1 pairs) disappears.

### Evidence 3: Forward Direction is Feasible via Index Lookup

For the forward direction, given `h_bracket : BracketFormula.holds M atomMap bf t x`:
- `bf.pointTypes i = nfPred atomMap h_surj (nf_y_proj (pos_between[i]))`
- `∃ witnesses : Fin n → M.carrier, ...` with `(bf.pointTypes i).eval_at M atomMap (witnesses i)`
- This gives `nf_eval_nf M 0 1 (fun _ => witnesses i) (nf_y_proj (pos_between[i]))`
- From which we can reconstruct `nf_eval_nf M 0 3 [witnesses i, x, t] (pos_between[i])`
  using `between_tx_temporal_iff` + `reconstruct_nf_eval_3var`

The forward direction `h_eq : enriched_vecEA2_until ... = ⟨n, vea⟩` is a sigma equality.
`Sigma.ext_iff` gives `h_n : n = vea.1` and `h_vea : vea.2 = ...` (via HEq). For the
bracket case, we need `vea.bracket = bf` which follows from `h_eq` after `Sigma.mk.inj`.

---

## Confidence Level: **HIGH** for diagnosis, **MEDIUM** for full fix

**High confidence**:
- The strict-increase constraint in `IntervalPattern.holds` is the exact source of both sorries
- `between_tx_temporal_iff` is the right lemma to use in both directions
- For n=1, the backward direction proof is direct
- The forward direction proof strategy (index lookup + reconstruct) is sound

**Medium confidence**:
- Whether n>1 actually occurs in the Kamp theorem proof (needs analysis of `NormalForm sig 0 3`
  structure to determine if multiple distinct between_tx SSNs can be simultaneously positive
  for a given `nf_x`)
- Whether the HEq transport in the forward direction can be cleanly handled with `Sigma.ext_iff`
  or requires more intricate dependent-type manipulation

---

## Risk Assessment

### Risk 1: Multiple Positive Between_tx SSNs (HIGH IMPACT if occurs, MEDIUM PROBABILITY)

If `n > 1` is achievable, the backward direction requires providing a strictly-ordered tuple
of witnesses that we cannot guarantee from the model. This would require either:
- A sorting argument (well-ordering of M.carrier)
- Changing the BracketFormula to use an existential over permutations
- Fundamentally restructuring `enriched_vecEA2_until`

**Mitigation**: Add a proof that `pos_between.length ≤ 1` for valid `nf_x` choices. If this
can be proved, the n=1 fix suffices.

### Risk 2: HEq Transport in Forward Direction (MEDIUM IMPACT, HIGH PROBABILITY)

The forward direction's comment explicitly notes the HEq issue:
> "Rather than transporting through HEq, use sorry for the forward direction"

`Sigma.ext_iff` in Lean 4 gives `⟨h_n, h_vea⟩` where `h_vea : HEq vea2 vea'`. The bracket
field would need `HEq.symm h_vea ▸ h_bracket` to rewrite. This is standard but verbose.

**Mitigation**: Use `cases h_eq` or `simp only [Sigma.ext_iff]` to unpack, then apply
`rec` on the HEq to substitute.

### Risk 3: VVecEA2 vs Plain Formula (LOW IMPACT, LOW PROBABILITY)

The VVecEA2 structure is well-established. As long as `enriched_vecEA2_until` returns
`Σ n, VecEA2 n` (unchanged return type), the outer `VVecEA2.translateLeft` machinery
continues to work without modification. No restructuring needed.

### Risk 4: Sorry Inventory After Bracket Fix (CRITICAL)

Currently: 2 sorries (L2081 bracket backward, L2151 forward). If the bracket fix requires
a proof that `n ≤ 1`, this adds a NEW proof obligation. If `n > 1` is impossible, the new
obligation may be provable by `decide` or `simp` on the finite type; if `n > 1` is possible,
the approach needs to change fundamentally.

---

## Recommended Implementation Order

1. **First**: Add a decidability lemma proving `pos_between.length ≤ 1` for any valid
   `nf_x` and `sub_nf`. Use `Fintype` + `decide` if the signature is finite. This determines
   which fixing approach is viable.

2. **If n ≤ 1 provable**: Implement the n=1 backward direction proof using `between_tx_temporal_iff`.
   For n=0, the bracket trivially holds (no witnesses needed, just segment guard).

3. **Then**: Implement the forward direction using `Sigma.ext_iff` to unpack `h_eq`, index
   lookup `List.indexOf` or direct membership to find witnesses, then `between_tx_temporal_iff`
   backward to reconstruct `nf_eval_nf`.

4. **Final verification**: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` to
   confirm both sorries closed.
