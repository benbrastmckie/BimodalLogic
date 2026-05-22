# Phase 4C-W2 Handoff: Lemma 9 Gap Detection Correctness

## Status: BLOCKED

## Immediate Next Action

Prove `left_formula_gap_detection` and `right_formula_gap_detection` via case-specific constructions (NOT generic gap-equivalence).

## What Was Attempted

1. **Structural induction on A** with generic gap-equivalence helpers
2. The generic gap-equivalence `U'(X, D)^mu(m) ↔ ∃ gap γ with X^mu(γ)` was found to be INCORRECT
3. Easy cases (atom, bot, box) are trivial (both sides False)
4. Structural cases (neg, conj) work via IH + `gap_detection_unique` + `Subtype.ext`
5. Temporal cases (stavi_untl, std_untl, base.untl/snce/imp) require case-specific proofs

## Key Technical Finding

The naive "gap-equivalence" approach fails because:

- `left_formula (.stavi_untl A B) D = .stavi_untl (.conj B (.stavi_untl A B)) D`
- This is `U'(B ∧ U'(A,B), D)` at m
- The theorem needs: ↔ ∃ gap γ, ..., `U'(A,B)^mu(γ)`
- Forward direction: get `(B ∧ U'(A,B))^mu(γ)`, drop B to get `U'(A,B)^mu(γ)` -- OK
- Backward direction: from `U'(A,B)^mu(γ)` need `(B ∧ U'(A,B))^mu(γ)`, requires `B^mu(γ)`
- **B^mu(γ) is NOT guaranteed**: at a gap γ, atoms evaluate to False, but U'(A,B) can hold via mu-point witnesses above γ

The correct proof needs to directly construct the U' FO table witnesses without going through a biconditional gap-equivalence.

## Correct Proof Strategy (Not Yet Implemented)

For each temporal case, prove DIRECTLY:

### Forward Direction
Given `U'(B ∧ C, D)^mu(m)` with FO table witness `s`:
1. In the interval (m, s), identify the gap γ where D transitions from holding to failing
2. D holds at all mu-points between m and γ (points in γ.cut above m)
3. D fails at some mu-point above γ (using `gap_definable_on_left`)
4. Extract C^mu(γ) from the "A-region" of the FO table (condition 1, second disjunct)

### Backward Direction  
Given gap γ with D-def-left, D-between(m,γ), and C^mu(γ):
1. Find bound s above γ where D fails (using `γ.proper` + `complement_no_min`)
2. Construct FO table conditions:
   - (3): D holds initially above m (from D-between: D at cut-points above m)
   - (2): D fails at some point above γ (from gap_definable_on_left negation)
   - (1): For each mu-point u in (m, s), construct the disjunction:
     - If u is in γ.cut (below gap): use first disjunct (∃ v > u with D on (m,v))
     - If u is above gap: use second disjunct (formula on (u,s) + ∃ v' < u with ¬D)

The X = B ∧ C formulation is handled by:
- Forward: just project out C
- Backward: need to show B^mu(γ) ∧ C^mu(γ). For C = U'(A,B) or U(A,B), the FO table at γ DOES imply B holds at mu-points near γ. The question is whether B^mu(γ) follows.

**Key insight needed**: Perhaps `left_formula` should be reformulated so that X = C (not B ∧ C), or there's a property of B at gaps that makes B^mu(γ) automatic from the gap conditions. This requires re-reading GHR93 Definition 8.5 and understanding why B is included in the conjunction.

## Files Modified

None (reverted to original state with sorries).

## Infrastructure Available

- `gap_detection_unique`: proved, shows uniqueness of D-defined-left gaps (for neg/conj cases)
- `stavi_truth_mu_at_point`: converts between mu-relativized truth at points and standard truth
- `extendPoint_le_gap_iff`: `extendPoint x ≤ Sum.inr g ↔ x ∈ g.val.cut`
- Extended carrier ordering: `Sum.inl m < Sum.inr γ ↔ m ∈ γ.val.cut`

## Estimated Effort

~15-25 hours for the complete proof (case-specific constructions for 6-7 temporal cases, each ~100-200 lines).
