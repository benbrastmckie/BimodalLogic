# Research Report: VecEA2-Level Lemma 5.1 Three-Case Decomposition

**Task**: 305 (rabinovich_ea_formula_implementation)
**Session**: sess_1782007020_9b132c
**Agent**: lean-research-hard-agent
**Reference Grounding Tier**: Tier 1 (literature-backed, Rabinovich 2014 Section 5)

## H3 Lemma Mapping Table (Paper to VecEA2-Level Code)

| Paper Reference | Paper Statement | Lean Name | Type Signature | Notes |
|---|---|---|---|---|
| Lemma 5.1 (p.7) | `not [alpha_0, beta_1, ..., alpha_n](z_0, z_1)` is V-EA | `neg_vecEA2_is_vvecEA2` | `forall (n : Nat) (vea : VecEA2 n), ... -> not vea.holds -> exists v : VVecEA2, v.holds` | Paper's alpha_0 = `endpointLeft`, alpha_n = `endpointRight`. Three cases operate on endpoint conditions, NOT existential witnesses. |
| Case 1 (p.10) | `not alpha_0(z_0)` | endpoint failure | `not vea.endpointLeft.eval_at M atomMap z0` | Trivial VVecEA2: single disjunct with `endpointLeft.neg` and bracket `trivial top`. No bracket negation needed. |
| Case 2 (p.10) | `alpha_0(z_0) AND beta_1 on (z_0, z_1)` | segment universal + bracket fails | `endpointLeft OK AND endpointRight OK AND segmentTypes(0) holds everywhere AND bracket.rightPart fails` | Reduces to negation of `BracketFormula n` via Corollary 5.4 or direct IH. This is where VecEA2-level avoids the beta_0(r_0) problem. |
| Case 3 (p.10) | `alpha_0(z_0) AND exists x with not beta_1(x)` | segment failure | `endpointLeft OK AND endpointRight OK AND exists x with not segmentTypes(0)(x)` | Find first failure point r via HasAttainedINF. Split at r. IH on sub-intervals. |
| Lemma 5.3 (p.8) | Negation of ordered-points | `neg_orderedPointsExist_is_vbracket` | `forall n Ps, exists v, v.holds <-> not orderedPointsExist` | COMPLETE (sorry-free). Model-independent biconditional. |
| Corollary 5.4 (p.9) | `not (exists z) bracket(z_0, z)` is V-EA | `neg_partialBracketExist_is_vbracket` | `forall n bf, exists v, v.holds <-> not partialBracketExist` | Forward COMPLETE (sufficient), backward SORRY at line 1172. |
| A_i^-(z_0, z) | Left sub-bracket | `BracketFormula.leftPart` | `BracketFormula (n+1) -> Fin (n+1) -> BracketFormula i.val` | COMPLETE (sorry-free). |
| A_i^+(z, z_1) | Right sub-bracket | `BracketFormula.rightPart` | `BracketFormula (n+1) -> Fin (n+1) -> BracketFormula (n - i.val)` | COMPLETE (sorry-free). Definitionally equal to Boneyard's `tail` at index 0. |
| A_i split/combine | Interval decomposition | `BracketFormula.splitAt_combine` | Combination direction: left+right+point -> whole | COMPLETE (sorry-free). |
| INF formula (5.2) | First-occurrence r_0 | `HasAttainedINF.first_occ` | Attained infimum on Prior structures | COMPLETE (sorry-free). |

## VecEA2-Level Proof Architecture

### Why VecEA2 Level, Not BracketFormula Level

The paper's Lemma 5.1 proves negation closure for formulas of the form (5.1):

    psi_0(z_0) AND psi_1(z_1) AND [alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)

This is exactly `VecEA2 n`:
- `endpointLeft` = psi_0 (the paper's endpoint type at z_0)
- `endpointRight` = psi_1 (the paper's endpoint type at z_1)
- `bracket` = `BracketFormula n` encoding the interior witnesses

The paper's three cases reference `alpha_0(z_0)` which is the ENDPOINT condition `psi_0(z_0) = endpointLeft.eval_at M atomMap z_0`, NOT a condition on an existential witness. The current code's `neg_bracket_is_vbracket` attempts negation closure at the BracketFormula level where there is no fixed endpoint -- the first witness is existentially quantified. This is why the beta_0(r_0) sub-case is unsolvable at BracketFormula level.

### Exact Mapping of Paper's Three Cases to VecEA2

Given `not (vea.holds M atomMap z0 z1)` where `vea : VecEA2 n`:

**Unfolding**: `vea.holds = endpointLeft(z0) AND endpointRight(z1) AND bracket.holds(z0, z1)`

So `not vea.holds` gives (by de Morgan): `not endpointLeft(z0) OR not endpointRight(z1) OR (endpointLeft(z0) AND endpointRight(z1) AND not bracket.holds(z0, z1))`

**Case 1: Endpoint failure** (`not endpointLeft(z0)` or `not endpointRight(z1)`)

This produces a trivial VVecEA2. Two sub-cases:
- `not endpointLeft(z0)`: VVecEA2 with single disjunct `{ endpointLeft := endpointLeft.neg, endpointRight := top, bracket := trivial top }`
- `not endpointRight(z1)`: VVecEA2 with single disjunct `{ endpointLeft := top, endpointRight := endpointRight.neg, bracket := trivial top }`

No bracket negation involved. Both endpoints produce valid VVecEA2 disjuncts because `endpointLeft.neg` evaluates to True at z0 (since `endpointLeft` evaluates to False there).

**Case 2: Both endpoints hold, bracket fails** (`endpointLeft(z0) AND endpointRight(z1) AND not bracket.holds(z0, z1)`)

This is where the induction on n applies. The negation `not bracket.holds(z0, z1)` must be expressed as a VBracketFormula, which is then wrapped with the original endpoints to form a VVecEA2.

At VecEA2 level, this case decomposes as:
- `not bracket.holds(z0, z1)` means: for ALL choices of n interior witnesses x_0 < ... < x_{n-1} in (z0, z1), the bracket pattern fails somewhere.

The paper's further sub-case analysis (for n >= 1):
- If `segmentTypes(0)` (the first segment type beta_1) holds everywhere in (z0, z1): then the bracket failure must come from the interior witnesses or later segments. This is where the paper WOULD do Corollary 5.4 style reduction. In the Boneyard's approach, this becomes: find first occurrence of `pointTypes(0)` (the first interior witness type), then the `tail`/`rightPart` must fail, apply IH.
- If `segmentTypes(0)` fails somewhere in (z0, z1): find the first failure point, and the bracket is refutable via that failure.

**Case 3 is absorbed into Case 2** at the VecEA2 level because the endpoint conditions are separate from the bracket's interior structure.

### Key Insight: VecEA2-Level Avoids beta_0(r_0)

The beta_0(r_0) problem arises in the current `neg_bracket_is_vbracket` (line 1047) because:
1. At BracketFormula level, the "first witness" alpha_0 is existentially quantified
2. Finding r_0 = first alpha_0 in (z0, z1), when beta_0(r_0) holds AND beta_0 holds on (z0, r_0), the proof needs to block ALL possible first witnesses x_0 >= r_0
3. For x_0 > r_0: beta_0 may hold on (z0, x_0) or may fail on (r_0, x_0) -- this is model-dependent and cannot be encoded in a model-independent VBracketFormula

At VecEA2 level, there IS no "first existential witness" to worry about. The endpoint condition `endpointLeft(z_0)` is a FIXED condition on the KNOWN point z_0. The bracket's interior witnesses are handled by `neg_bracket_forward` (model-dependent forward direction from the Boneyard), which uses `bf.tail`/`rightPart` at index 0 and the contrapositive of `bracket_tail_satisfiable`.

The Boneyard's `neg_interval_formula` (= `neg_bracket_forward`) case B1 handles the situation where segment holds on (z0, r0) by noting that `bf.tail.holds(r0, z1)` must fail (otherwise `bracket_tail_satisfiable` would reconstruct `bf.holds`). It applies IH to `bf.tail` (which has n witnesses, one fewer). There is NO sub-case on beta_0(r_0) because the `tail` starts from r_0's position onward, and the segment from z0 to r0 has already been checked.

### How to Structure `neg_vecEA2_is_vvecEA2`

The recommended theorem signature:

```lean
theorem neg_vecEA2_is_vvecEA2 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (n : Nat) (vea : VecEA2 n) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : not vea.holds M atomMap z0 z1) :
    exists v : VVecEA2, v.holds M atomMap z0 z1
```

This is model-dependent (M is a parameter) and forward-only (given `not vea.holds`, produce `exists v, v.holds`). The model-independent biconditional is NOT needed for Proposition 4.2.

**Proof structure**:

```
by_cases hL : vea.endpointLeft.eval_at M atomMap z0
. by_cases hR : vea.endpointRight.eval_at M atomMap z1
  . -- Case 2: both endpoints hold, bracket fails
    have h_neg_bracket : not vea.bracket.holds M atomMap z0 z1 := h_neg hL hR
    -- Apply neg_bracket_forward (Boneyard's neg_interval_formula)
    obtain <v_bracket, hv_bracket> := neg_bracket_forward M atomMap h_INF n vea.bracket z0 z1 h_lt h_neg_bracket
    -- Wrap with original endpoints
    exact <v_bracket.toVVecEA2WithEndpoints vea.endpointLeft vea.endpointRight,
           v_bracket.toVVecEA2WithEndpoints_holds M atomMap ... hL hR hv_bracket>
  . -- Case 1b: endpointRight fails
    exact <trivial VVecEA2 with endpointRight.neg>
. -- Case 1a: endpointLeft fails
  exact <trivial VVecEA2 with endpointLeft.neg>
```

This structure has PERFECT alignment with the paper:
- Cases 1a/1b = paper's Case 1 (endpoint failure)
- Case 2 = paper's Case 2 + Case 3 combined (bracket interior fails)

The bracket-level negation `neg_bracket_forward` is a separate, model-dependent theorem that handles the induction on n with no beta_0(r_0) problem.

## Case Analysis: What Each Case Produces as VVecEA2

### Case 1a (endpointLeft fails)

Input: `not endpointLeft.eval_at M atomMap z0`
Output:
```lean
VVecEA2 with single disjunct:
  { endpointLeft := endpointLeft.neg    -- True at z0
    endpointRight := TemporalPred.top   -- True everywhere
    bracket := BracketFormula.trivial TemporalPred.top }  -- vacuous
```

### Case 1b (endpointRight fails)

Input: `not endpointRight.eval_at M atomMap z1`
Output:
```lean
VVecEA2 with single disjunct:
  { endpointLeft := TemporalPred.top    -- True everywhere
    endpointRight := endpointRight.neg  -- True at z1
    bracket := BracketFormula.trivial TemporalPred.top }  -- vacuous
```

### Case 2 (both endpoints hold, bracket fails)

Input: `endpointLeft(z0) AND endpointRight(z1) AND not bracket.holds(z0, z1)`
Output: `neg_bracket_forward` produces `v : VBracketFormula` with `v.holds M atomMap z0 z1`. Then `v.toVVecEA2WithEndpoints endpointLeft endpointRight` produces the VVecEA2.

Each bracket disjunct in v becomes a VecEA2 disjunct wrapped with the ORIGINAL endpoint conditions. This preserves the endpoint information for downstream consumers.

## Induction Structure for neg_bracket_forward

The bracket-level negation closure `neg_bracket_forward` (adapted from Boneyard's `neg_interval_formula`) uses induction on n:

**Base (n = 0)**: `bf.holds z0 z1 = forall y in (z0, z1), segmentTypes(0)(y)`.
Negation: `exists y in (z0, z1), not segmentTypes(0)(y)`.
VBracketFormula: single disjunct with 1 witness (the failure point y) and `segmentTypes(0).neg` as point type.

**Step (n + 1)**: Three sub-cases:
- **A** (pointTypes(0) absent): `pureSeg (pointTypes(0).neg)` -- 0-witness bracket.
- **B1** (pointTypes(0) present, first segment OK): Find r0 = first pointTypes(0). Segment holds on (z0, r0). Then `bf.tail`/`rightPart(0)` must fail on (r0, z1) (by contrapositive of `bracket_tail_satisfiable`). IH on tail gives VBracket on (r0, z1). Prepend r0 with `pointTypes(0).neg` segment to get VBracket on (z0, z1).
- **B2** (pointTypes(0) present, first segment fails): INF configuration is VBracket (1-witness bracket with pointTypes(0) and pointTypes(0).neg segment).

**Crucially**: Case B1 does NOT split on beta_0(r_0). It uses `bracket_tail_satisfiable` which combines r_0 with the tail witnesses, checking the FULL bracket's first segment on (z0, r0). The point r_0 is the first occurrence of pointTypes(0), and the segment check is on (z0, r_0), which has been verified by `h_seg`. There is no separate handling of the value at r_0 itself.

## Reusability Assessment

### From EANegation.lean (Active Code)

| Component | Lines | Status | Reusable For | Action |
|---|---|---|---|---|
| `neg_orderedPointsExist_is_vbracket` (Lemma 5.3) | 347-509 | COMPLETE | Not directly needed by neg_bracket_forward | Keep as-is |
| `BracketFormula.prepend` + holds/holds_inv | 123-270 | COMPLETE | Used by neg_bracket_forward's Case B1 | Reuse directly |
| `BracketFormula.fChainFrom/fChainPred` | 552-712 | COMPLETE | Used by Cor 5.4 forward | Reuse for Cor 5.4 |
| `neg_partialBracketExist_sufficient` (Cor 5.4 fwd) | 725-751 | COMPLETE | Forward direction of Cor 5.4 | Reuse directly |
| `neg_bracket_zero_is_vbracket` (base case) | 770-818 | COMPLETE | Base case for neg_bracket_forward | Can use, but Boneyard's base is simpler |
| `neg_bracket_is_vbracket` | 826-1073 | SORRY at 1047 | None (will be superseded) | Replace or keep as optional |
| `neg_partialBracketExist_is_vbracket` | 1079-1174 | SORRY at 1172 | None (will be superseded) | Replace or keep as optional |

### From Boneyard (NegationClosure5.lean)

| Component | Lines | Status | Action |
|---|---|---|---|
| `BracketFormula.purePoint` | 72-74 | COMPLETE (behind #exit) | Port to active code |
| `BracketFormula.pureSeg` | 78-80 | COMPLETE (behind #exit) | Port to active code |
| `TemporalPred.eval_at_neg` | 112-117 | COMPLETE (behind #exit) | Port to active code |
| `first_occurrence_prior_strict` | 288-306 | COMPLETE (behind #exit) | Already available via `HasAttainedINF.first_occ` (no need to port) |
| `inf_bracket_formula` + holds | 313-346 | COMPLETE (behind #exit) | Port to active code |
| `inf_formula_prior_is_vbracket` | 364-373 | COMPLETE (behind #exit) | Port to active code |
| `BracketFormula.tail` | 716-718 | COMPLETE (behind #exit) | Definitionally equal to `rightPart ⟨0, _⟩`. Can use `rightPart` directly. |
| `bracket_tail_satisfiable` | 726-818 | COMPLETE (behind #exit) | Port, or re-derive using `splitAt_combine` |
| `neg_interval_formula` (Lemma 5.1 forward) | 966-1031 | COMPLETE (behind #exit) | Port as `neg_bracket_forward` |
| `neg_bounded_exists` (Cor 5.4 forward) | 859-937 | COMPLETE (behind #exit) | Port as `neg_partialBracketExist_forward` |

### From Boneyard (NegationClosureProp42.lean)

| Component | Lines | Status | Action |
|---|---|---|---|
| `VBracketFormula.toVVecEA2WithEndpoints` + holds | 47-66 | COMPLETE (behind #exit) | Port to active code |
| `neg_vecEA2` (Prop 4.2 single) | 75-116 | COMPLETE (behind #exit) | Port; replace `semantic_prior_UZ` with `HasAttainedINF` |
| `neg_disjunct_list` (helper) | 125-153 | COMPLETE (behind #exit) | Port |
| `neg_2var_vec_ea` (Prop 4.2 full) | 159-169 | COMPLETE (behind #exit) | Port |

## Comparison: VecEA2-Level vs BracketFormula-Level

| Aspect | BracketFormula-Level (Current) | VecEA2-Level (Proposed) |
|---|---|---|
| Theorem statement | Model-independent biconditional | Model-dependent forward-only |
| Endpoint handling | No endpoints (pure interval) | Endpoints as separate conditions |
| Case 1 | Not applicable | `not endpointLeft(z0)` or `not endpointRight(z1)` -- trivial |
| Case 2 (beta_0(r_0) sub-case) | **SORRY**: cannot encode in model-independent VBracket | **Avoided**: Boneyard's `neg_interval_formula` handles via tail/rightPart with no beta_0(r_0) split |
| Case 3 (segment failure) | Handled (CaseC in current code) | Handled (B2 in Boneyard) |
| Induction target | `n` = witness count in BracketFormula | `n` = witness count in BracketFormula (same induction, different wrapper) |
| Downstream compatibility | Would feed into model-independent pipeline | Feeds into Prop 4.2 which is already model-dependent |
| Sorry count | 2 (lines 1047, 1172) | 0 (Boneyard proof is sorry-free) |

## Recommended Implementation Strategy

### New File: `EANegationClosure.lean`

Create a new file importing `EANegation` and `VecEAClosure`:

1. **Port helpers** from Boneyard: `purePoint`, `pureSeg`, `eval_at_neg`, `inf_bracket_formula`, `bracket_tail_satisfiable`
2. **Port `neg_interval_formula`** as `neg_bracket_forward` using `HasAttainedINF` instead of `semantic_prior_UZ`
3. **Port `neg_bounded_exists`** as `neg_partialBracketExist_forward` (resolves sorry at line 1172)
4. **Port `VBracketFormula.toVVecEA2WithEndpoints`** + holds
5. **Prove `neg_vecEA2_is_vvecEA2`** using de Morgan + `neg_bracket_forward` + toVVecEA2WithEndpoints
6. **Prove `neg_2var_vec_ea`** using `neg_vecEA2_is_vvecEA2` + conjunction closure

### Adaptation Notes

The Boneyard uses `semantic_prior_UZ` while active code uses `HasAttainedINF`. Since `prior_hasAttainedINF` derives `HasAttainedINF` from `semantic_prior_UZ`, and `HasAttainedINF.first_occ` provides exactly the same `first_occurrence_prior_strict` functionality, the adaptation is:

```lean
-- Boneyard pattern:
obtain <r0, ...> := first_occurrence_prior_strict M atomMap h_UZ P z0 z1 h_lt h_exists

-- Adapted pattern:
obtain <r0, hr0_above, hr0_below, h_no_before, h_P_r0> :=
  h_INF.first_occ P.formula z0 z1 h_lt (by obtain <x, hx1, hx2, hx3> := h_exists; exact <x, hx1, hx2, hx3>)
```

The `prior_UZ_successor` helper (used in `neg_bounded_exists` n=0 base case) needs either:
- Porting separately, or
- Restructuring the n=0 case to use the existing `neg_partialBracketExist_is_vbracket` n=0 base (which already handles this with a `by_cases` on segment failure)

The existing `neg_partialBracketExist_is_vbracket` n=0 case (lines 1087-1159) is already sorry-free and handles the base case correctly using `HasAttainedINF`. It can serve as the base case for `neg_partialBracketExist_forward`.

### Estimated Scope

| Component | Estimated Lines | Difficulty |
|---|---|---|
| Port helpers (purePoint, pureSeg, etc.) | 60-80 | Low |
| `bracket_tail_satisfiable` (using existing `splitAt_combine`) | 40-60 | Medium |
| `neg_bracket_forward` (Lemma 5.1) | 80-120 | Medium |
| `neg_partialBracketExist_forward` (Cor 5.4) | 80-120 | Medium |
| `VBracketFormula.toVVecEA2WithEndpoints` | 30-40 | Low |
| `neg_vecEA2_is_vvecEA2` (Prop 4.2 single) | 40-60 | Low |
| `neg_2var_vec_ea` (Prop 4.2 full) | 40-60 | Low |
| **Total** | **370-540** | |

## Adversarial Self-Verification (H4)

### Challenged Claims

| Claim | Challenge | Verdict |
|---|---|---|
| "VecEA2-level avoids beta_0(r_0)" | Does the Boneyard's `neg_interval_formula` truly avoid a beta_0(r_0) sub-case, or does it just hide it? | **Verified**: Boneyard line 1000-1007 shows Case B1: `by_cases h_seg : forall y, z0 < y -> y < r0 -> segmentTypes(0)(y)`. When `h_seg` holds (segment OK): `bf.tail.holds r0 z1` must fail (line 1004-1007, via contrapositive of `bracket_tail_satisfiable`). Apply IH to `bf.tail` (line 1009). There is NO split on beta_0(r_0). The segment check is on the OPEN interval (z0, r0), not at r0 itself. The point r0 is handled by `bracket_tail_satisfiable` which requires `pointTypes(0)(r0)` and `segmentTypes(0) on (z0, r0)` -- it does NOT require `segmentTypes(0)(r0)`. |
| "rightPart at index 0 equals tail" | Checked via lean_local_search and Boneyard code. | **Verified**: `rightPart ⟨0, _⟩ : BracketFormula (n - 0) = BracketFormula n` with `pointTypes j = bf.pointTypes ⟨0 + 1 + j.val, _⟩ = bf.pointTypes ⟨j.val + 1, _⟩` and `segmentTypes j = bf.segmentTypes ⟨0 + 1 + j.val, _⟩ = bf.segmentTypes ⟨j.val + 1, _⟩`. This is definitionally `tail`. |
| "Boneyard proof was correct before archival" | The `#exit` means Lean does not check the file. | **High confidence**: Code was moved to Boneyard by task 302. The proof patterns are structurally identical to sorry-free code in EANegation.lean. The main risk is small API changes (e.g., `BracketFormula.prepend` vs `bracket_prepend_holds`) -- but the active code already has `BracketFormula.prepend_holds` which is the same. |
| "HasAttainedINF suffices for all steps" | Could `semantic_prior_UZ` be needed for something `HasAttainedINF` does not provide? | **Verified with one caveat**: `HasAttainedINF.first_occ` provides exactly the same first-occurrence functionality. The caveat is `prior_UZ_successor` (Boneyard line 823-840) used in `neg_bounded_exists` n=0 base. This uses `semantic_prior_UZ` to find a point with an empty open interval below it. This is derivable from `HasAttainedINF` by applying `first_occ` to Formula.top, but the existing `neg_partialBracketExist_is_vbracket` n=0 case already handles this differently (by_cases on segment failure + HasAttainedINF for first failure point). |
| "The VVecEA2 produced by this approach is correct for downstream" | Does anything downstream need the biconditional? | **Verified**: grep confirms no active file references `neg_bracket_is_vbracket`. Boneyard's `neg_vecEA2` calls `neg_interval_formula` with forward direction only. `KampBypass.lean` is sorry-free and independent. The downstream pipeline (`neg_2var_vec_ea` for Prop 4.2) only needs the forward direction. |

### Uncertain Claims

| Claim | Confidence | Basis |
|---|---|---|
| Port from Boneyard compiles with < 100 lines of adaptation | 85% | Same types, same infrastructure. Main change: `semantic_prior_UZ` -> `HasAttainedINF`, `BracketFormula.tail` -> `rightPart ⟨0, _⟩`, `bracket_prepend_holds` -> `prepend_holds`. |
| `bracket_tail_satisfiable` can be derived from `splitAt_combine` | 90% | `splitAt_combine` proves the combination direction. `bracket_tail_satisfiable` is essentially `splitAt_combine` specialized at index 0 with explicit leftPart argument. Should be a short wrapper. |
| Total implementation is 370-540 lines | 75% | Depends on how much proof text needs adjustment for current API. The Boneyard proofs are ~400 lines total but some helpers are already in the active codebase. |

### Recommendations Modified After Verification

1. **Use `rightPart ⟨0, _⟩` instead of porting `BracketFormula.tail`**: They are definitionally equal, and `rightPart` is already in the active codebase with proved semantics (`rightPart_holds`).

2. **Derive `bracket_tail_satisfiable` from `splitAt_combine`**: Rather than porting the 90-line Boneyard proof verbatim, prove it as a corollary of `splitAt_combine` (already proved) which handles the general case. The specialization to index 0 should be much shorter.

3. **Keep existing `neg_bracket_is_vbracket` with sorries**: Do not delete it. Mark it as "nice-to-have model-independent version" that is NOT on the critical path. The new `neg_bracket_forward` supersedes it for Prop 4.2.

## Tactic Survey Results

No tactics tested in this dispatch (architecture-focused). Recommended tactics for implementation:
- `by_cases` for endpoint and segment case splits
- `push_neg` for negation unfolding in the backward direction
- `obtain` with destructuring for `HasAttainedINF.first_occ`
- `exact` with `BracketFormula.prepend_holds` for Case B1 prepend
- `simp only [VecEA2.holds]` followed by `push_neg` for de Morgan on the VecEA2 conjunction

## Summary

The VecEA2-level three-case decomposition maintains PERFECT alignment with Rabinovich's paper:
1. Cases 1a/1b (endpoint failure) are trivial VVecEA2 constructions
2. Case 2 (bracket interior fails) delegates to `neg_bracket_forward` which uses the Boneyard's sorry-free three-case structure at the BracketFormula level
3. The beta_0(r_0) problem that blocked 6+ dispatches is structurally avoided because the Boneyard's approach uses `tail`/`rightPart` + contrapositive of `bracket_tail_satisfiable`, which never needs to case-split on the value of beta_0 at the first-occurrence point r_0
4. The full pipeline `neg_vecEA2_is_vvecEA2` -> `neg_2var_vec_ea` eliminates both sorries (lines 1047 and 1172) in EANegation.lean
5. Estimated 370-540 lines in a new `EANegationClosure.lean` file
