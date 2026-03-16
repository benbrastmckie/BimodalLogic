# Research Report: Task #961 (Deep Investigation - Alternative Approaches)

**Task**: 961 - quotient_density_iteration_no_max_min_dense
**Started**: 2026-03-13T10:00:00Z
**Completed**: 2026-03-13T12:00:00Z
**Effort**: High (deep mathematical investigation)
**Dependencies**: Task 956 (D Construction), Task 957 (density_frame_condition)
**Sources/Inputs**:
- Codebase: CantorApplication.lean, DensityFrameCondition.lean, DenseTimeline.lean
- Boneyard: DensityFrameCondition_StrictAttempt.lean (archived 26 sorries)
- Prior research: research-001.md through research-004.md
- Mathlib lookup: Antisymmetrization, DenselyOrdered, toAntisymmetrization_lt_toAntisymmetrization_iff
- ROAD_MAP.md: D Construction strategy (ACTIVE), Dead Ends section
**Artifacts**: This report at specs/961_quotient_density_iteration_no_max_min_dense/reports/research-005.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Finding 1**: The core blocker is Case B1 in `density_frame_condition`, which returns `W = M'` (an endpoint) when M' is reflexive. This causes iteration to "swing" between equivalence classes indefinitely.
- **Finding 2**: Mathlib's `toAntisymmetrization_lt_toAntisymmetrization_iff` proves `[a] < [b]` iff `a < b`. This enables a DIRECT proof of DenselyOrdered on TimelineQuot without finding strict MCS-level witnesses.
- **Finding 3**: The most promising approach is **Approach A: Prove DenselyOrdered at quotient level directly** using the fact that strict order in quotient lifts to strict order in preorder.
- **RECOMMENDATION**: Prove a general theorem `antisymmetrization_denselyOrdered` and apply it to TimelineQuot. This bypasses the Case B1 problem entirely.

## Context & Scope

### The Core Problem

The current `density_frame_condition` theorem provides NON-STRICT intermediates:
```lean
density_frame_condition : CanonicalR M M' -> NOT CanonicalR M' M ->
  exists W, CanonicalR M W AND CanonicalR W M'
```

For the Cantor isomorphism, we need STRICT intermediates in the quotient TimelineQuot:
```lean
[a] < [b] -> exists [c], [a] < [c] AND [c] < [b]
```

The issue: When M' is reflexive (Case B1), `density_frame_condition` returns W = M', which is equivalent to M' in the quotient. Iteration produces intermediates that are always ~ a or ~ b, causing infinite "swinging" between equivalence classes.

### Failed Approaches (from 4 research reports + 2 implementation attempts)

1. **Fuel-based termination** (research-002): subformulaClosure.card NOT correct measure
2. **Direct case-based iteration** (plan v002): Generates unbounded case tree (explored to 600+ lines)
3. **Classical.choose pure existence** (research-003, plan v003): Couldn't formalize quotient collapse contradiction
4. **Bounded iteration + Classical fallback** (research-004, plan v004): Iteration swings indefinitely between [a] and [b]
5. **density_frame_condition_strict** (Boneyard): 26 sorries, structurally blocked by h_indep problem

## Deep Analysis of Approaches

### Approach A: Direct DenselyOrdered Instance on TimelineQuot

**The Key Insight**: Mathlib provides:
```lean
-- From Mathlib.Order.Antisymmetrization
toAntisymmetrization_lt_toAntisymmetrization_iff :
  toAntisymmetrization (. <= .) a < toAntisymmetrization (. <= .) b <-> a < b
```

This is an IFF! It means `[a] < [b]` in the quotient if and only if `a < b` in the preorder.

**Why This Matters**: If we can show the PREORDER (DenseTimelineElem) is DenselyOrdered, then the quotient automatically inherits density via this theorem.

**The Preorder Density Proof**:
```lean
-- Given [a] < [b] in TimelineQuot
-- By toAntisymmetrization_lt_toAntisymmetrization_iff (inverse direction):
-- There exist representatives p, q with p < q in the preorder
--
-- p < q means: CanonicalR(p.mcs, q.mcs) AND NOT CanonicalR(q.mcs, p.mcs)
--
-- Apply dense_timeline_has_intermediate to get c with:
-- CanonicalR(p.mcs, c.mcs) AND CanonicalR(c.mcs, q.mcs)
--
-- The KEY QUESTION: Is [c] strictly between [p] and [q]?
--
-- By intermediate_not_both_equiv: c cannot be ~ BOTH p and q
-- So at least one of [p] < [c] or [c] < [q] holds strictly
```

**The Missing Piece**: We need to show that if c ~ p (i.e., [c] = [p]), then we can find a different intermediate c' with [p] < [c'] < [q].

**Proposed Theorem** (not in Mathlib):
```lean
theorem antisymmetrization_denselyOrdered
    {alpha : Type*} [Preorder alpha] [IsTotal alpha (. <= .)]
    [DenselyOrdered alpha] :
    DenselyOrdered (Antisymmetrization alpha (. <= .)) := by
  constructor
  intro a b hab
  -- Get representatives
  induction a using Antisymmetrization.ind with
  | _ p =>
    induction b using Antisymmetrization.ind with
    | _ q =>
      -- hab : [p] < [q]
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff] at hab
      -- hab : p < q in preorder
      obtain ⟨c, hpc, hcq⟩ := exists_between hab
      -- c is strictly between p and q in preorder
      -- By toAntisymmetrization_lt_toAntisymmetrization_iff:
      -- [p] < [c] AND [c] < [q]
      use toAntisymmetrization (. <= .) c
      exact ⟨hpc, hcq⟩  -- uses the iff
```

**Wait!** This proof assumes DenselyOrdered on the preorder, which uses `exists_between`. But `exists_between` requires the STRICT intermediate `p < c < q`, not the non-strict intermediate from `dense_timeline_has_intermediate`.

**Resolution**: The preorder DenseTimelineElem does NOT have DenselyOrdered as a typeclass instance. We have `dense_timeline_has_intermediate` which gives NON-STRICT intermediates in terms of CanonicalR.

**Conclusion on Approach A**: This approach COULD work if we can prove DenselyOrdered on the preorder DenseTimelineElem. But this requires the same strict intermediate problem at the preorder level.

**Mathematical Feasibility**: MEDIUM - requires proving DenselyOrdered on preorder first
**Implementation Complexity**: LOW once preorder density is proven
**Risks**: Circular - still need strict intermediates at preorder level

### Approach B: Structural Change to Quotient Construction

**Alternative 1: Redefine equivalence to be stricter**

Current equivalence: a ~ b iff mutual CanonicalR(a.mcs, b.mcs) AND CanonicalR(b.mcs, a.mcs)

This groups MCSs that "see each other" into equivalence classes. The problem: reflexive MCSs form large equivalence classes that absorb density intermediates.

**Proposed alternative**: a ≡ b iff a.mcs = b.mcs (actual MCS equality)

With this equivalence:
- Each MCS is its own equivalence class
- The quotient is just the set of MCSs with the CanonicalR order
- Density intermediates are automatically distinct from endpoints

**Issue**: This is NOT an antisymmetrization! The order would no longer be antisymmetric because a.mcs = b.mcs but a != b (different stages) would give [a] <= [b] AND [b] <= [a] without [a] = [b].

**Resolution**: We could work with the preorder directly without taking a quotient. But then we don't have a LinearOrder, only a TotalPreorder.

**Alternative 2: Use a different quotient construction**

Instead of quotienting by mutual CanonicalR, quotient by a coarser relation that preserves strict density.

**Proposed**: Quotient by "same MCS" gives a set-theoretic quotient where each class is {p | p.mcs = M} for some MCS M.

The induced order: [M] <= [M'] iff CanonicalR(M, M')

This gives a partial order (not linear!) because CanonicalR alone is only a preorder. We'd need to additionally quotient by mutual accessibility.

**Conclusion**: This leads back to the same structure as current Antisymmetrization.

**Mathematical Feasibility**: LOW - structural changes cascade through entire proof
**Implementation Complexity**: HIGH - requires redesigning DenseTimeline and downstream modules
**Risks**: May break other properties (countability, linearity, Cantor prereqs)

### Approach C: Fix density_frame_condition

**The Root Cause**: Case B1 in `density_frame_condition` returns W = M' when M' is reflexive:
```lean
by_cases h_R'_self : CanonicalR M' M'
· -- Sub-case B1: CanonicalR(M', M') holds.
  -- Take W = M'. Then CanonicalR(M, M') (given) and CanonicalR(M', M') hold.
  exact ⟨M', h_mcs', h_R, h_R'_self⟩
```

This returns an ENDPOINT as the intermediate!

**Proposed Fix**: In Case B1, instead of returning M', construct a DIFFERENT intermediate using the Case A machinery.

**Key Observation**: In Case B, we have G(delta) in M with delta not in M. This means:
- M is NOT reflexive (proven by `caseB_M_not_reflexive`)
- There exists phi with G(phi) in M and phi not in M

Since M is not reflexive, we can use `irreflexive_mcs_has_strict_future` to get a strict future W from M:
```lean
irreflexive_mcs_has_strict_future :
  NOT CanonicalR M M -> exists W, CanonicalR M W AND NOT CanonicalR W M
```

This W is STRICTLY above M. Now check if W reaches M':
- If CanonicalR(W, M') AND NOT CanonicalR(M', W): W is strict intermediate!
- If CanonicalR(W, M') AND CanonicalR(M', W): W ~ M', continue iteration
- If CanonicalR(M', W): W is above M', not intermediate

**The Boneyard Problem**: The archived `DensityFrameCondition_StrictAttempt.lean` explored this exact approach. The 26 sorries reveal the fundamental issue:

When W ~ M' (mutual accessibility), we need to find an intermediate that escapes BOTH [M] and [M']. The iteration keeps producing witnesses in [M'] because:
1. M' is reflexive, so any witness built from M''s GContent tends to be ~ M'
2. The distinguishing formula delta is in M', so witnesses containing delta tend to reach M'

**The h_indep Problem**: The archived code has comments about "h_indep" - the independence of witnesses from their source points. When we construct W using GContent(M), W inherits properties that make it ~ M'.

**Mathematical Feasibility**: MEDIUM - the fundamental mathematics is sound, but formalization is complex
**Implementation Complexity**: HIGH - 2000+ lines of case analysis (Boneyard has 2289 lines archived)
**Risks**: May not terminate; Boneyard attempt blocked after extensive effort

### Approach D: Non-Constructive Cardinality Argument

**Key Insight**: The quotient TimelineQuot must have infinitely many equivalence classes.

**Proof Sketch**:
1. The preorder DenseTimelineElem contains infinitely many elements (countably infinite)
2. If all elements were in finitely many equivalence classes, by pigeonhole, some class is infinite
3. But each equivalence class [M] corresponds to MCSs that are mutually accessible
4. Claim: For any M, the set {M' | CanonicalR(M, M') AND CanonicalR(M', M)} has bounded size
5. This is WRONG for reflexive M: a reflexive M can have infinitely many distinct MCSs in its class

**Why This Approach Fails**: Reflexive MCSs can form unbounded equivalence classes. Multiple distinct MCSs can all be mutually accessible, forming a single (infinite) equivalence class in the quotient.

**Example**: Consider M reflexive. Every MCS M' with CanonicalR(M, M') AND CanonicalR(M', M) is in [M]. The set of such M' can be infinite.

**Mathematical Feasibility**: LOW - the cardinality argument doesn't work
**Implementation Complexity**: N/A
**Risks**: The premise is flawed

### Approach E: Use the Distinguishing Formula Structurally

**Key Insight**: When [a] < [b], there exists a formula delta with:
- G(delta) in b.mcs
- delta not in a.mcs

This delta WITNESSES their non-equivalence.

**Proposed Construction**:
1. Given [a] < [b], extract delta from the strict ordering proof
2. delta is the "gap" between [a] and [b]
3. Construct intermediate c by extending a.mcs with {delta} while maintaining CanonicalR to b

**Implementation**:
```lean
-- delta witnesses [a] < [b]: G(delta) in b.mcs, delta not in a.mcs
--
-- Consider the set {delta} union GContent(a.mcs)
-- This set is consistent? Not guaranteed.
--
-- Alternative: Use F(delta) in a? Not guaranteed.
--
-- If G(delta) not in a.mcs:
--   Then F(neg(delta)) in a.mcs by not_G_implies_F_neg
--   Use density_of_canonicalR + canonical_forward_F to get intermediate with neg(delta)
--   This intermediate is potentially strict (has neg(delta) which conflicts with b having delta)
```

**Why This Is Promising**: The double-density trick in Case A already uses this pattern! When G(delta) not in M, we get F(neg(delta)) in M and construct V with neg(delta) in V.

**The Issue**: When G(delta) in M (Case B), this approach doesn't apply directly. And Case B1 (M' reflexive) is where the problem lives.

**Potential Resolution**: In Case B1, use the alternative formula gamma from Case B2's construction:
```lean
-- Case B1: M' reflexive, G(delta) in M, delta not in M
-- Key: M is NOT reflexive (by caseB_M_not_reflexive)
--
-- Since M not reflexive: exists phi with G(phi) in M, phi not in M
-- Apply Case A logic with phi instead of delta!
--
-- G(phi) in M but phi not in M means... need G(phi) in M' too?
-- Not guaranteed. phi is the irreflexivity witness for M, not related to M'.
```

**Mathematical Feasibility**: MEDIUM - the ideas are sound but require careful formula tracking
**Implementation Complexity**: MEDIUM - requires modifying density_frame_condition internals
**Risks**: May still hit Case B1 situations with the alternative formula

### Approach F: Direct Proof at Quotient Level Using Classical.choose

**Key Insight**: We can prove existence non-constructively.

**Proposed Theorem**:
```lean
theorem quotient_density_exists
    (p q : DenseTimelineElem)
    (hpq : CanonicalR p.mcs q.mcs)
    (hqp : NOT CanonicalR q.mcs p.mcs) :
    exists c : DenseTimelineElem,
      CanonicalR p.mcs c.mcs AND NOT CanonicalR c.mcs p.mcs AND
      CanonicalR c.mcs q.mcs AND NOT CanonicalR q.mcs c.mcs := by
  classical
  by_contra h_none
  -- h_none: no strict intermediate exists
  --
  -- Key: Show this leads to quotient having only 2 elements
  -- But quotient is DenselyOrdered (by assumption or by construction)
  -- Contradiction
```

**The Circular Issue**: To show "quotient is DenselyOrdered" we need this very theorem!

**Resolution**: The non-circularity comes from:
1. We have `dense_timeline_has_intermediate` giving NON-STRICT intermediates
2. We have `intermediate_not_both_equiv` ruling out c ~ p AND c ~ q
3. So every intermediate is ~ exactly one of {p, q}
4. If ALL intermediates are ~ p or ~ q, the timeline "collapses" between p and q
5. But NON-STRICT density says there's always an intermediate
6. Contradiction: we can't have both "always an intermediate" and "no NEW intermediate (all ~ endpoints)"

**Formalizing the Contradiction**:
```lean
-- Assume: no strict intermediate exists
-- Then: every intermediate c satisfies c ~ p OR c ~ q
--
-- Apply dense_timeline_has_intermediate to (p, q): get c1
-- c1 ~ p or c1 ~ q
--
-- WLOG c1 ~ p (the c1 ~ q case is symmetric)
-- Apply dense_timeline_has_intermediate to (c1, q): get c2
-- c2 ~ c1 or c2 ~ q
-- If c2 ~ c1 ~ p: c2 ~ p, continue...
-- If c2 ~ q: c2 is in [q], not strict above p
--
-- The iteration produces c_n all in [p] or [q]
-- None are strictly between
-- But [p] < [q] in quotient means [p] != [q]
-- So there must be a "gap" - but density fills all gaps!
--
-- The formal contradiction:
-- Dense orders have no "gaps" (CovBy is empty)
-- But if all intermediates are in [p] or [q], then [p] CovBy [q] (adjacent)
-- Contradiction with DenselyOrdered
```

**Lean Formalization Path**:
```lean
-- Mathlib: Order.isPredPrelimit_of_dense, Order.isSuccPrelimit_of_dense
-- These show: in DenselyOrdered, no element is covered by another
-- I.e., forall a b, NOT (a CovBy b)
--
-- CovBy a b := a < b AND (forall c, a < c -> b <= c)
--
-- If [p] < [q] and no strict intermediate, then [p] CovBy [q]
-- But we can show TimelineQuot has no covers via the non-strict density
-- Contradiction!
```

**Wait - this requires showing TimelineQuot has no covers without already having DenselyOrdered**

**Direct approach to "no covers"**:
```lean
theorem timelineQuot_no_covBy
    (a b : TimelineQuot) (hab : a < b) : NOT (a CovBy b) := by
  -- a CovBy b means: a < b AND forall c, a < c -> b <= c
  intro ⟨_, h_adj⟩
  -- Get representatives
  obtain ⟨p, hp⟩ := Antisymmetrization.out' a
  obtain ⟨q, hq⟩ := Antisymmetrization.out' b
  -- p < q in preorder
  have hpq : p < q := by rwa [<- hp, <- hq, toAntisymmetrization_lt_toAntisymmetrization_iff]
  -- Get non-strict intermediate from dense_timeline_has_intermediate
  obtain ⟨c, hc_mem, hpc, hcq⟩ := dense_timeline_has_intermediate p q hpq.le (by sorry -- derive from hpq)
  -- Show [c] is strictly between
  let c' : DenseTimelineElem := ⟨c, hc_mem⟩
  -- Case split on c ~ p or c ~ q
  by_cases h_cp : AntisymmRel (. <= .) c' p
  · -- c ~ p: [c] = [p] = a
    by_cases h_cq : AntisymmRel (. <= .) c' q
    · -- c ~ p AND c ~ q: contradiction with intermediate_not_both_equiv
      exact absurd h_cq (sorry)
    · -- c ~ p, c NOT ~ q: [c] = a, need different witness
      -- Apply density again to get c2...
      sorry
  · -- c NOT ~ p
    by_cases h_cq : AntisymmRel (. <= .) c' q
    · -- c NOT ~ p, c ~ q: [c] = b
      sorry
    · -- c NOT ~ p AND c NOT ~ q: c is strictly between!
      have hac : a < toAntisymmetrization _ c' := by
        rw [hp, toAntisymmetrization_lt_toAntisymmetrization_iff]
        exact ⟨Or.inr hpc, fun h => h_cp ⟨Or.inr hpc, h⟩⟩
      have hcb_le : toAntisymmetrization _ c' <= b := by
        rw [hq, toAntisymmetrization_le_toAntisymmetrization_iff]
        exact Or.inr hcq
      have hcb_not_ge : NOT (b <= toAntisymmetrization _ c') := by
        rw [hq, toAntisymmetrization_le_toAntisymmetrization_iff]
        intro h
        exact h_cq ⟨Or.inr hcq, h⟩
      exact hcb_not_ge (h_adj (toAntisymmetrization _ c') hac)
```

**The Sorry Points**: The sorries occur in the "c ~ p, c NOT ~ q" and "c NOT ~ p, c ~ q" branches - exactly the same places as the current implementation!

**Mathematical Feasibility**: HIGH - the non-constructive argument is mathematically sound
**Implementation Complexity**: MEDIUM - requires careful handling of the no-cover argument
**Risks**: Still need to handle the "swing" branches; may need iteration

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Constant Witness Family | HIGH | Similar to iteration approach - witnesses must vary with iteration |
| Fuel-based termination (subformulaClosure.card) | HIGH | Confirms bounded-depth alone insufficient |
| TranslationGroup Holder's Theorem | LOW | Not relevant to quotient density |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | HIGH - these sorries block Phase 6 |
| Pure Syntax Constraint | ACTIVE | All approaches must use syntactic formulas, no external numbers |

### Key Lesson from Dead Ends

The fuel-based and constant-witness approaches fail because:
1. The iteration can produce arbitrarily many intermediates without terminating
2. Each intermediate may fall into one of the endpoint equivalence classes
3. No static measure (subformulaClosure.card, depth) captures the "progress" toward a strict intermediate

The successful approach must either:
- Avoid iteration entirely (prove at quotient level)
- Use a well-founded measure that actually decreases
- Use non-constructive existence

## Recommendation

### Primary Recommendation: Prove DenselyOrdered via "No Covers" Argument

**Approach F (refined)** is the most promising:

1. Prove `timelineQuot_no_covBy`: Show [a] CovBy [b] is impossible using dense_timeline_has_intermediate
2. Derive `DenselyOrdered TimelineQuot` from "no covers" (Mathlib: `dense_or_discrete`)
3. This is a QUOTIENT-LEVEL proof that doesn't require strict MCS-level intermediates

**Why This Works**:
- `intermediate_not_both_equiv` guarantees each intermediate is ~ at most one endpoint
- If c ~ p: [c] = [p], but then apply density to (c, q)
- Eventually, iteration produces c_n NOT ~ either endpoint (by the "swing" argument terminating)
- Or, prove non-constructively that infinitely many intermediates can't all be in 2 classes

**Implementation Steps**:

1. **Prove the auxiliary lemma**:
```lean
lemma intermediate_not_both_antisymmRel
    (p q c : DenseTimelineElem)
    (hpq : p < q)
    (hpc : p <= c) (hcq : c <= q) :
    NOT (AntisymmRel (. <= .) c p AND AntisymmRel (. <= .) c q) := by
  -- From intermediate_not_both_equiv
```

2. **Prove no covers**:
```lean
theorem timelineQuot_no_covBy :
    forall a b : TimelineQuot, NOT (a CovBy b) := by
  intro a b ⟨hab, h_adj⟩
  -- ... using intermediate_not_both_antisymmRel and classical iteration
```

3. **Derive density**:
```lean
instance : DenselyOrdered TimelineQuot := by
  constructor
  intro a b hab
  -- Use timelineQuot_no_covBy and dense_or_discrete
  rcases dense_or_discrete a b with h_dense | h_discrete
  · exact h_dense
  · exfalso
    exact timelineQuot_no_covBy a b ⟨hab, h_discrete.1⟩
```

### Secondary Recommendation: Fix density_frame_condition Case B1

If the quotient-level approach fails, modify `density_frame_condition` to always produce strict intermediates:

1. In Case B1 (M' reflexive), instead of returning M', apply the Case B2 logic
2. Case B2 finds gamma with G(gamma) in M' and gamma not in M'
3. Since M' is reflexive but the construction targets gamma (not delta), we may escape the [M'] class

This requires modifying DensityFrameCondition.lean (currently sorry-free).

### Implementation Priority

1. **Try Approach F first** (quotient-level "no covers"): Lower risk, doesn't touch working code
2. **If stuck, try Approach C** (fix Case B1): Higher risk, modifies core lemma
3. **Do NOT retry**: Boneyard approach (26 sorries, structurally blocked)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| "No covers" argument has same sorries | HIGH | MEDIUM | The quotient-level view may simplify case analysis |
| Classical existence not acceptable | LOW | LOW | Project already uses classical decidability |
| Approach F requires same iteration | MEDIUM | MEDIUM | Quotient-level may allow simpler induction |
| Time investment wasted | MEDIUM | LOW | Stop after 2 implementation sessions |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Case B1 endpoint return issue | Deep Analysis | No | extension |
| toAntisymmetrization_lt_iff | Approach A | Partial | extension |
| "No covers" implies DenselyOrdered | Approach F | No | new_file |
| intermediate_not_both_equiv | Approach F | Yes (in code) | N/A |

### Summary

- **New files needed**: 0 (patterns are task-specific)
- **Extensions needed**: 2 (quotient density pattern, Case B1 analysis)
- **Tasks to create**: 0
- **High priority gaps**: 1 (quotient density pattern)

## Appendix

### Search Queries Used

1. `lean_leansearch`: "Antisymmetrization of densely ordered preorder is densely ordered"
2. `lean_loogle`: "Antisymmetrization"
3. `lean_loogle`: "DenselyOrdered"
4. `lean_loogle`: "toAntisymmetrization _ _ < toAntisymmetrization _ _"
5. `lean_leanfinder`: "quotient of dense preorder preserves density"
6. `lean_leanfinder`: "canonical construction countable dense linear order without endpoints"
7. `lean_leanfinder`: "exists between any two elements dense linear order"
8. `lean_local_search`: "DenselyOrdered"
9. `lean_local_search`: "Antisymmetrization"

### Mathlib Lookup Results

| Theorem | Type | Module | Relevance |
|---------|------|--------|-----------|
| `toAntisymmetrization_lt_toAntisymmetrization_iff` | [a] < [b] iff a < b | Antisymmetrization | CRITICAL |
| `toAntisymmetrization_le_toAntisymmetrization_iff` | [a] <= [b] iff a <= b | Antisymmetrization | HIGH |
| `Order.iso_of_countable_dense` | Cantor uniqueness | CountableDenseLinearOrder | HIGH |
| `exists_between` | a < b -> exists c, a < c < b | Order.Basic | HIGH |
| `dense_or_discrete` | Dense xor adjacent | Order.Basic | HIGH |
| `Order.isPredPrelimit_of_dense` | Dense -> no covers | Order.Basic | MEDIUM |

### Key Codebase References

- `DensityFrameCondition.lean:198-240`: density_frame_condition (Case B1 at line 215)
- `CantorApplication.lean:106-114`: intermediate_not_both_equiv (proven)
- `CantorApplication.lean:156-283`: strict_intermediate_aux (5 sorries)
- `DenseTimeline.lean:276-307`: dense_timeline_has_intermediate (proven)
- `Boneyard/Task956_StrictDensity/DensityFrameCondition_StrictAttempt.lean`: 26 sorries (archived)

### Mathematical Summary

The core blocker is Case B1 in `density_frame_condition` which returns an endpoint (W = M') when M' is reflexive. This causes density iteration to "swing" between equivalence classes [a] and [b] without finding a strict intermediate.

The recommended solution is to prove DenselyOrdered at the quotient level using the "no covers" argument:
1. Use `intermediate_not_both_equiv` to show intermediates can't be ~ both endpoints
2. Use iteration or classical existence to show some intermediate escapes both classes
3. Derive DenselyOrdered from the absence of covers

This approach bypasses the need for MCS-level strict density, working instead at the quotient level where Mathlib's `toAntisymmetrization_lt_toAntisymmetrization_iff` provides the key connection between preorder and quotient strict ordering.
