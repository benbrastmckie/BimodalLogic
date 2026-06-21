# Research Report: Faithful Lemma 5.1 Design

**Task**: 305 (rabinovich_ea_formula_implementation)
**Session**: sess_1782001521_502879
**Agent**: lean-research-hard-agent
**Reference Grounding Tier**: Tier 1 (literature-backed, Rabinovich 2014 Section 5)

## H3 Lemma Mapping Table (Paper to Code)

| Paper Reference | Paper Statement | Lean Name | Status | Divergence Notes |
|---|---|---|---|---|
| Lemma 5.3 (p.8) | Negation of ordered-points predicate (all betas True) is V-EA | `neg_orderedPointsExist_is_vbracket` | COMPLETE (sorry-free) | Faithful. Uses `HasAttainedINF` (stronger than paper's Dedekind complete, but Prior structures satisfy it). Model-independent biconditional. |
| Corollary 5.4 forward (p.9) | V-bracket holds implies negation of partial bracket existential | `neg_partialBracketExist_sufficient` | COMPLETE (sorry-free) | Faithful forward direction only. Uses F-chain reduction. |
| Corollary 5.4 full (p.9) | Negation of partial bracket existential IS V-bracket | `neg_partialBracketExist_is_vbracket` | SORRY at line 1172 | Backward direction (n+1 case) missing. Depends on Lemma 5.1 resolution. |
| Lemma 5.1 base (n=0) | Negation of 0-witness bracket is V-bracket | `neg_bracket_zero_is_vbracket` | COMPLETE (sorry-free) | Faithful. Model-independent biconditional. |
| Lemma 5.1 inductive (n+1) | Negation of (n+1)-witness bracket is V-bracket | `neg_bracket_is_vbracket` | SORRY at line 1047 | **Critical divergence**: attempts model-independent biconditional. Paper's Case 2 (beta_1 holds along interval) uses endpoint conditions at z_0 which are absent at BracketFormula level. |
| Lemma 5.1 Case 1 (p.10) | Not alpha_0(z_0) or K+(not beta_1)(z_0) | `neg_bracket_is_vbracket` CaseA | COMPLETE (forward+backward) | Faithful. No alpha_0 in interval. |
| Lemma 5.1 Case 3 (p.10) | alpha_0(z_0) AND not K+(not beta_1)(z_0) AND exists x with not beta_1(x) | `neg_bracket_is_vbracket` CaseC | COMPLETE (forward+backward) | Faithful. Beta_0 failure before first alpha_0. |
| Lemma 5.1 Case 2 sub-case: not beta_0(r_0) | alpha_0(r_0) AND not beta_0(r_0) | `neg_bracket_is_vbracket` CaseD (not beta_0) | COMPLETE (forward+backward) | Faithful. Prepend IH disjunct. |
| Lemma 5.1 Case 2 sub-case: beta_0(r_0) | alpha_0(r_0) AND beta_0(r_0) AND rightPart fails | `neg_bracket_is_vbracket` CaseD (beta_0) | **SORRY** at line 1047 | **Root cause of all failures**: at BracketFormula level there is no alpha_0(z_0) endpoint condition, so we cannot restrict the next first-witness choice to x_0 = r_0. |
| Prop 4.2 (p.6) | Negation of VecEA2 is VVecEA2 | Not in active code (Boneyard only) | NOT STARTED | Boneyard has complete forward-only proof in NegationClosureProp42.lean (archived). |
| Notation 5.2: INF formula | INF(z_0, r_0, z_1, P_1) defines infimum point | `HasAttainedINF` + `first_occ` | COMPLETE | Faithful. Prior structures have attained INF (no K+ case). |
| A_i^-(z_0, z) | Left sub-bracket | `BracketFormula.leftPart` | COMPLETE (sorry-free) | Faithful. |
| A_i^+(z, z_1) | Right sub-bracket | `BracketFormula.rightPart` | COMPLETE (sorry-free) | Faithful. rightPart at index 0 = Boneyard's `tail` (definitionally equal). |
| Corollary 5.4: F_n reduction | F_i = alpha_i AND (beta_{i+1} Until F_{i+1}) | `BracketFormula.fChainFrom` / `fChainPred` | COMPLETE (sorry-free) | Faithful. F-chain semantics proved in both directions. |

## Root Cause Analysis

### The Fundamental Problem

The sorry at line 1047 arises from a **type-level mismatch** between what Lemma 5.1 proves and how the codebase attempts to encode it.

**Paper's approach (Lemma 5.1 full proof, p.10)**: The paper proves negation closure for formulas WITH endpoint conditions -- i.e., at the VecEA2 level. The form is:

    not [alpha_0, beta_1, ..., alpha_n](z_0, z_1) where alpha_0 is the left ENDPOINT type

At this level, alpha_0(z_0) is a condition on the fixed endpoint z_0. There is no existential choice of a first witness -- z_0 IS the point where alpha_0 holds. Case 2 then says: "alpha_0(z_0) AND beta_1 holds along (z_0, z_1)". Since z_0 is fixed, the proof can decompose: find the first point where beta_1 fails (or show beta_1 holds everywhere), and recurse.

**Codebase's approach (neg_bracket_is_vbracket)**: The theorem proves negation closure for BracketFormula -- i.e., formulas WITHOUT endpoint conditions. The bracket formula has existentially chosen interior witnesses x_0, ..., x_n. The negation says "for ALL choices of x_0, ..., x_n in (z_0, z_1), the pattern fails somewhere."

In the backward direction, when we have `not bf.holds` and need to produce a V-bracket, the sub-case `beta_0(r_0) AND alpha_0(r_0) AND not rightPart(r_0, z_1)` is problematic because:

1. We found r_0 = first alpha_0 in (z_0, z_1) via HasAttainedINF
2. beta_0 holds on (z_0, r_0)  
3. beta_0(r_0) holds
4. rightPart fails at (r_0, z_1) -- so by IH we have v_r.holds(r_0, z_1)
5. But to block bf.holds on (z_0, z_1), we need to block ALL x_0 >= r_0 with alpha_0(x_0)
6. For x_0 > r_0: beta_0 may fail on (r_0, x_0), but we cannot guarantee this
7. For x_0 = r_0: rightPart fails, good. But x_0 > r_0 is also allowed.

The V-bracket must be constructed model-independently (before seeing M), so it cannot adapt to different structures where different x_0 > r_0 might succeed.

### Why Previous Dispatches Failed

All 6 previous dispatches tried to solve this at the BracketFormula level:

1. **F-chain V for biconditional** -- tried encoding via Until chains; fails because Until witnesses are unbounded
2. **Prepend with alpha_0.neg segment** -- captures CaseA/CaseD but not the beta_0(r_0) sub-case
3. **Segment-failure decomposition** -- cannot decompose when beta_0 holds continuously
4. **Split-at-every-position** -- would need infinitely many disjuncts
5. **fChainPred implies bracket** -- the reverse of F-chain reduction; unbounded Until witnesses
6. **3-disjunct CaseA/CaseC/CaseD** -- closest to paper; fails exactly at beta_0(r_0)

Each failed for the same structural reason: BracketFormula-level negation closure with model-independent V-bracket is strictly harder than what the paper proves (VecEA2-level) or what Proposition 4.2 needs (model-dependent forward direction).

## Recommended Proof Architecture

### Two-Track Strategy

**Track A (Recommended, immediate)**: Adopt the Boneyard's forward-only approach. This is the shortest path to eliminating all sorries.

**Track B (Optional, future)**: If the model-independent biconditional is ever needed, prove it at the VecEA2 level with endpoint induction.

### Track A: Model-Dependent Forward Direction

The Boneyard's `NegationClosure5.lean` contains complete, sorry-free proofs of:

1. `neg_interval_formula` (Lemma 5.1 forward): Given `not bf.holds M atomMap z0 z1`, produce `exists v : VBracketFormula, v.holds M atomMap z0 z1`. Model-dependent (M is a parameter). Induction on n with 3 cases: (A) no alpha_0, (B1) alpha_0 present + segment ok -> IH on tail, (B2) alpha_0 present + segment fails -> INF V-bracket.

2. `neg_bounded_exists` (Corollary 5.4 forward): Given `not (exists z, bf.holds z0 z)`, produce V-bracket.

3. `neg_vecEA2` (Prop 4.2 single conjunct): Given `not vea.holds`, produce VVecEA2 via 3 de Morgan cases.

4. `neg_2var_vec_ea` (Prop 4.2 full): Given `not vvea.holds`, produce VVecEA2 via conjunction closure.

**Why the Boneyard's approach avoids the beta_0(r_0) problem**: In Case B1, the case split is:

    by_cases h_seg : forall y, z0 < y -> y < r0 -> seg_0(y)

When `h_seg` holds (segment ok): `bf.tail` must fail on (r0, z1) (by contrapositive of `bracket_tail_satisfiable`). Apply IH on `bf.tail` (not `bf.rightPart`) to get V-bracket on (r0, z1). Prepend r0.

There is NO sub-case on beta_0(r_0). The point r_0 is simply the first alpha_0 occurrence. The `tail` of the bracket starting from r_0 either holds or does not; the IH handles either case. The beta_0 segment condition on (z_0, r_0) is checked, and if it fails, Case B2 (INF configuration) applies. beta_0(r_0) itself is irrelevant because `tail` starts its segment accounting from r_0 onward.

### Track B: Model-Independent Biconditional (if ever needed)

If a model-independent `neg_vecEA2_is_vvecEA2` is needed:

1. Define `neg_vecEA2_step` by induction on n, absorbing the left endpoint into the bracket's first segment condition
2. Case split: not endpointLeft(z_0) (trivial disjunct), not endpointRight(z_1) (trivial), endpointLeft(z_0) AND endpointRight(z_1) AND not bracket(z_0, z_1)
3. For case 3: the alpha_0 is now the endpoint condition at z_0. Since z_0 is fixed, there is no existential choice. The induction decreases n, and the beta_0(r_0) sub-case never arises because the "first witness" is z_0 itself.

This is significantly more complex and is NOT needed for Proposition 4.2.

## Refactoring Plan

### What to Keep

| Component | Location | Status | Action |
|---|---|---|---|
| `IntervalPattern.allBetaTrue` | EANegation.lean:44 | Complete | Keep |
| `orderedPointsExist` + helpers | EANegation.lean:57-103 | Complete | Keep |
| `BracketFormula.prepend` + holds | EANegation.lean:123-270 | Complete | Keep |
| `orderedPointsExist_decompose` | EANegation.lean:274-301 | Complete | Keep |
| `VBracketFormula.prependAll` | EANegation.lean:333-335 | Complete | Keep |
| `neg_orderedPointsExist_is_vbracket` (Lemma 5.3) | EANegation.lean:347-509 | Complete | Keep |
| `BracketFormula.fChainFrom/fChainPred` | EANegation.lean:552-569 | Complete | Keep (used by Cor 5.4 forward) |
| `BracketFormula.fChainFrom_base/step` | EANegation.lean:580-652 | Complete | Keep |
| `bracket_implies_fChainPred` | EANegation.lean:660-712 | Complete | Keep |
| `neg_partialBracketExist_sufficient` | EANegation.lean:725-751 | Complete | Keep |
| `neg_bracket_zero_is_vbracket` | EANegation.lean:770-818 | Complete | Keep |
| VecEAClosure conjunction/existential | VecEAClosure.lean | Complete | Keep |
| VecEA2/VVecEA2 definitions | VecEAFormula.lean:252-299 | Complete | Keep |
| leftPart/rightPart/splitAt_combine | VecEAFormula.lean:360-545 | Complete | Keep |
| HasAttainedINF / HasDefinableINF | PriorINF.lean | Complete | Keep |

### What to Restructure

| Component | Current State | Action |
|---|---|---|
| `neg_bracket_is_vbracket` (lines 826-1073) | Model-independent biconditional, SORRY at 1047 | **Replace** with model-dependent forward-only `neg_bracket_forward` (Boneyard's `neg_interval_formula` approach) |
| `neg_partialBracketExist_is_vbracket` (lines 1079-1174) | Biconditional, SORRY at 1172 | **Replace** with model-dependent forward-only `neg_partialBracketExist_forward` (Boneyard's `neg_bounded_exists` approach) |

### What to Add (New File: EANegationClosure.lean)

The following definitions/theorems should be ported from the Boneyard (`NegationClosure5.lean` + `NegationClosureProp42.lean`) and adapted to use current infrastructure:

| Definition/Theorem | Type Signature | Paper Reference |
|---|---|---|
| `BracketFormula.tail` | `BracketFormula (n+1) -> BracketFormula n` | Equivalent to `rightPart ⟨0, _⟩` (definitionally equal). Can use `rightPart` directly instead. |
| `bracket_tail_satisfiable` | `bf.holds z0 z <- hr0 -> hPt -> hSeg -> bf.tail.holds r0 z` | Helper for Case B1 contrapositive |
| `first_occurrence_prior_strict` | From `semantic_prior_UZ`, get first occurrence with strict bounds | Already available via `HasAttainedINF.first_occ` |
| `inf_formula_prior_is_vbracket` | INF configuration V-bracket | Case B2: segment failure before first occurrence |
| `neg_bracket_forward` | `not bf.holds -> exists v, v.holds` (model-dependent) | Lemma 5.1 forward |
| `neg_partialBracketExist_forward` | `not (exists z, bf.holds z0 z) -> exists v, v.holds` | Corollary 5.4 forward |
| `VBracketFormula.toVVecEA2WithEndpoints` | Lift V-bracket to VVecEA2 with endpoints | Helper for Prop 4.2 |
| `neg_vecEA2` | `not vea.holds -> exists v : VVecEA2, v.holds` | Prop 4.2 single conjunct |
| `neg_2var_vec_ea` | `not vvea.holds -> exists v : VVecEA2, v.holds` | Prop 4.2 full |

### Critical Type Signatures

```lean
-- Lemma 5.1 forward (model-dependent, replaces neg_bracket_is_vbracket)
theorem neg_bracket_forward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) :
    ∀ (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    z0 < z1 →
    ¬bf.holds M atomMap z0 z1 →
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1

-- Corollary 5.4 forward (model-dependent, replaces neg_partialBracketExist_is_vbracket)
theorem neg_partialBracketExist_forward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) :
    ∀ (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    z0 < z1 →
    ¬(∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z) →
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1

-- Prop 4.2 (single conjunct)
theorem neg_vecEA2 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (n : Nat) (vea : VecEA2 n) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : ¬vea.holds M atomMap z0 z1) :
    ∃ v : VVecEA2, v.holds M atomMap z0 z1

-- Prop 4.2 (full)
theorem neg_2var_vec_ea {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier)
    (h_lt : z0 < z1)
    (h_neg : ¬v.holds M atomMap z0 z1) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1
```

**Note**: The Boneyard uses `semantic_prior_UZ` directly while the current code uses `HasAttainedINF`. Since `prior_hasAttainedINF` derives `HasAttainedINF` from `semantic_prior_UZ`, the adapted versions should use `HasAttainedINF` for consistency with Phases 1-3.

### Migration Steps

1. **Create `EANegationClosure.lean`** importing `EANegation` and `VecEAClosure`
2. **Port `bracket_tail_satisfiable`** from Boneyard (or use `rightPart` + `splitAt_combine` directly)
3. **Port `inf_formula_prior_is_vbracket`** (INF V-bracket for Case B2) -- adapt to use `HasAttainedINF.first_occ` instead of `first_occurrence_prior_strict`
4. **Prove `neg_bracket_forward`** (Lemma 5.1) using Boneyard's 3-case structure
5. **Prove `neg_partialBracketExist_forward`** (Corollary 5.4) using Boneyard's structure
6. **Port `VBracketFormula.toVVecEA2WithEndpoints`** from Boneyard
7. **Prove `neg_vecEA2`** and **`neg_2var_vec_ea`** (Prop 4.2)
8. **Remove sorries** from `neg_bracket_is_vbracket` and `neg_partialBracketExist_is_vbracket` by either:
   - (a) Dropping the biconditional and keeping only forward direction, or
   - (b) Keeping them as sorry-marked "nice to have" theorems that are not on the critical path

### Dependencies on Existing Code Not Yet in Active Tree

The Boneyard's `NegationClosure5.lean` uses several helper definitions not yet in the active codebase:

| Boneyard Definition | Active Equivalent | Action Needed |
|---|---|---|
| `BracketFormula.purePoint` | `BracketFormula.single pt top top` | Define or inline |
| `BracketFormula.pureSeg` | `BracketFormula.trivial seg` | Already available as `trivial` |
| `TemporalPred.eval_at_neg` | Not present | Port from Boneyard (simple lemma) |
| `first_occurrence_prior_strict` | `HasAttainedINF.first_occ` | Already available |
| `inf_bracket_formula` | Not present | Port from Boneyard |
| `inf_bracket_formula_holds` | Not present | Port from Boneyard |
| `inf_formula_prior_is_vbracket` | Not present | Port from Boneyard |
| `BracketFormula.bracket_prepend_holds` | `BracketFormula.prepend_holds` | Already available (equivalent) |
| `prior_UZ_successor` | Not present | Port from Boneyard (used in Cor 5.4 n=0) |

## Adversarial Self-Verification (H4)

### Challenged Claims

| Claim | Challenge | Verdict |
|---|---|---|
| "The biconditional is unnecessary for Prop 4.2" | Could downstream consumers (Phase 6 rewire, KampBypass) need the biconditional? | **Verified**: No active file imports or references `neg_bracket_is_vbracket`. The Boneyard's `neg_vecEA2` (Prop 4.2) calls `neg_interval_formula` with only `h_neg : not bf.holds`, never uses backward direction. KampBypass.lean is sorry-free and does not reference EA negation at all. |
| "rightPart at index 0 equals tail" | Could there be a definitional mismatch? | **Verified**: `rightPart ⟨0, _⟩` has `pointTypes j = bf.pointTypes ⟨0 + 1 + j.val, _⟩` and `segmentTypes j = bf.segmentTypes ⟨0 + 1 + j.val, _⟩`. `tail` has `pointTypes i = bf.pointTypes ⟨i.val + 1, _⟩` and `segmentTypes i = bf.segmentTypes ⟨i.val + 1, _⟩`. Since `0 + 1 + j = j + 1` by Nat arithmetic, these are definitionally equal. |
| "The Boneyard proof is sorry-free" | The Boneyard file starts with `#exit` -- was it verified before archival? | **Uncertain**: The `#exit` means Lean does not check the file. However, the code was working before archival (per task 302 notes). The patterns used (case split, prepend, IH) are structurally identical to the sorry-free portions of EANegation.lean. **Risk**: some helper definitions (purePoint, pureSeg, eval_at_neg) may need small adaptations for current API. Confidence: HIGH that the proof structure is correct; MEDIUM that it will compile without changes. |
| "HasAttainedINF is sufficient (no need for semantic_prior_UZ directly)" | Could the Boneyard's use of `semantic_prior_UZ` be needed for properties `HasAttainedINF` doesn't cover? | **Verified**: The only place `semantic_prior_UZ` is used beyond `HasAttainedINF.first_occ` is `prior_UZ_successor` (getting an empty interval above z_0), which is needed for `neg_bounded_exists` base case (n=0). This is a property of Prior structures (discrete successor exists) that `HasAttainedINF` alone may not provide. **Action needed**: Either port `prior_UZ_successor` separately, or restructure the n=0 base case of `neg_partialBracketExist_forward` to use `HasAttainedINF` directly. The current `neg_partialBracketExist_is_vbracket` n=0 case already handles this using `by_cases` on segment failure, so the existing approach is viable. |
| "The plan's Phase 4 blocker analysis is correct" | Is the beta_0(r_0) sub-case truly unsolvable at BracketFormula level? | **Verified**: The sorry goal at line 1047 requires producing `VBracketFormula.holds M atomMap result z0 z1` when we have beta_0(r_0), alpha_0(r_0), and v_r.holds(r_0, z_1). The `result` V-bracket has disjuncts CaseA (no alpha_0), CaseC (beta_0 failure before alpha_0), and CaseD (prepended IH with alpha_0.conj(beta_0.neg) point type). None of these can fire when beta_0(r_0) holds: CaseD requires beta_0.neg at the first alpha_0 point. A new CaseE would need to encode "beta_0(r_0) AND v_r on (r_0, z_1)" but the prepend operation expects a point type at r_0 while the V-bracket v_r.holds(r_0, z_1) is a property of an interval, not a point type. This structural incompatibility confirms the sub-case is unsolvable at BracketFormula level with the current V-bracket construction. |

### Uncertain Claims (Confidence Levels)

| Claim | Confidence | Basis |
|---|---|---|
| Boneyard proof can be ported with < 200 lines of adaptation | 80% | The Boneyard uses the same `BracketFormula`, `VBracketFormula`, `IntervalPattern` types. Main adaptation: replace `semantic_prior_UZ` with `HasAttainedINF`, replace `BracketFormula.tail` with `rightPart ⟨0, _⟩`, replace `bracket_prepend_holds` with `prepend_holds`. |
| No other downstream consumers need the biconditional | 95% | Grep confirmed no references outside EANegation.lean. The Kamp theorem pipeline goes through KampBypass which is sorry-free and independent. |
| Phase 6 rewire can use model-dependent negation closure | 75% | The rewire needs to convert EA negation to temporal formulas. If the V-bracket is model-dependent, the translation pipeline must also be model-dependent, which it already is (all VecEA2 -> temporal translations take M as parameter). But need to verify the exact call site in KampBypass. |

### Recommendations Modified After Verification

1. **Original plan Phase 4**: Prove `neg_vecEA2_is_vvecEA2` (model-independent, VecEA2 level). **Revised**: Drop model-independent requirement. Use model-dependent forward direction from Boneyard.

2. **Original plan Phase 5**: Build on Phase 4's model-independent V-bracket. **Revised**: Phase 5 (`neg_vecEA2`) can directly use `neg_bracket_forward` since de Morgan decomposition is model-dependent anyway.

3. **Corollary 5.4 backward**: The plan expected to derive from Lemma 5.1. **Revised**: With model-dependent approach, the backward direction is simply the contrapositive of the forward direction applied to the bounded existential -- no separate sorry needed.

## Tactic Survey Results

No tactics were tested in this research dispatch since the focus was on architectural design rather than proof construction. The implementation phase should use:

- `by_cases` for Case A/B1/B2 splits (as in Boneyard)
- `push_neg` for negation unfolding
- `obtain` with `HasAttainedINF.first_occ` for first occurrence extraction
- `exact` with `BracketFormula.prepend_holds` for IH disjunct prepend

## Summary

The sorry at line 1047 in `neg_bracket_is_vbracket` is an artifact of attempting a model-independent biconditional at the BracketFormula level, which is strictly harder than what the paper proves or what Proposition 4.2 requires. The recommended fix is to adopt the Boneyard's model-dependent forward-only approach, which:

1. Eliminates the beta_0(r_0) sub-case entirely (Case B1 uses `tail`/`rightPart` and IH directly)
2. Is complete and (was) sorry-free in the Boneyard
3. Suffices for Proposition 4.2 and all downstream consumers
4. Can be ported with estimated 400-600 lines in a new `EANegationClosure.lean`

The second sorry at line 1172 (`neg_partialBracketExist_is_vbracket` backward) will also be resolved by the same approach: the forward-only `neg_partialBracketExist_forward` replaces it.
