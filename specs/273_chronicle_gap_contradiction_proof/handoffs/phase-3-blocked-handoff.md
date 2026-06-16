# Phase 3 Blocked Handoff: Encoding Flaw in enriched_vecEA2_until

## Immediate Next Action

Fix `enriched_vecEA2_until` definition (KampBypass.lean L445-502) to add per-SSN
Since(char_y(ssn_i), seg_guard) conjuncts to endpointRight for each positive between_tx SSN.
Then re-prove backward direction (Phase 2) and forward direction (Phase 3).

## Current State

- Phase 3 BLOCKED: encoding flaw confirmed
- Build: GREEN (4 sorries at L2385, L2560, L2562, L2715 — unchanged from dispatch start)
- No new code committed (all forward proof attempts reverted)
- Plan updated with BLOCKER annotation

## Key Discovery: Encoding Flaw

The shared `pos_pt` encoding in `enriched_vecEA2_until` is insufficient for the forward direction.

**Problem**: The bracket uses `pos_pt` (disjunction of ALL positive between_tx char_y formulas)
as the CONSTANT pointType for ALL k bracket witnesses. This means `IntervalPattern.holds`
only requires each witness to satisfy SOME disjunct — not a SPECIFIC positive SSN.

**Counterexample**: Consider a model M with 2 positive between_tx SSNs (ssn_1, ssn_2) having
different nf_y_proj. If all points y in (t, x) have predicates matching ssn_1's nf_y_proj,
the bracket formula holds with k=2 (two distinct points both satisfying char_y(ssn_1),
which is one disjunct of pos_pt). But no point satisfies char_y(ssn_2), so the quantifier
evaluation ∃ y, nf_eval_nf M 0 3 ... ssn_2 fails. The biconditional breaks.

**Why per-SSN pointTypes don't work**: `IntervalPattern.holds` indexes pointTypes by SORTED
position. The sorting permutation (via `Finset.orderEmbOfFin`) depends on model values,
not syntax. So we can't assign a specific SSN to each sorted position at definition time.

## Proposed Fix

Add per-SSN existence conditions to endpointRight (L486-499):

```lean
| .between_tx =>
  if sub_nf.2 ssn then
    some (Formula.snce char_y (formula_conjList (neg_between.map fun ssn' =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')).neg)))
  else none  -- negative between_tx handled by seg_guard in bracket
```

This `Since(char_y(ssn_i), seg_guard)` at x means: ∃ y < x with char_y(ssn_i) at y AND
seg_guard holds between y and x. Combined with the bracket's structural bounds ensuring
witnesses are in (t, x), the forward direction becomes: extract y from Since, show t < y
using bracket/endpointLeft constraints, conclude nf_eval via bridge.

**Backward direction impact**: The backward proof (L2008-2318) gains new endpointRight
conjuncts for positive between_tx SSNs. Each follows from:
1. `seg_guard_on_interval` (L2168): seg_guard holds at all z in (t, x)
2. `nf_depth0_char_formula_correct`: char_y(ssn_i) holds at witness y_i
3. Since witness is y_i with y_i < x and seg_guard on (y_i, x)

## Work Completed (Not Committed)

The following proof structure was developed and verified conceptually but reverted:

1. **Atom proof** (complete): All 6 AtomKind variants for `nf_eval_nf` atom part
2. **Quantifier proof** (5/6 zones complete):
   - below_t, eq_t (mp/mpr): via h_endLeft + zone bridge lemmas
   - eq_x, above_x (mp/mpr): via h_endRight right_conjuncts + zone bridge lemmas
   - inconsistent: via ssn_order_consistent contradiction
   - between_tx: BLOCKED (see above)
3. **Helper lemma** `bracket_seg_holds_in_open_interval` (verified): Given bracket.holds with
   constant segType, any point y in (lo, hi) that is NOT at a bracket witness satisfies segType.

## Sorry Inventory

| # | File | Line | Statement | Status |
|---|------|------|-----------|--------|
| 1 | KampBypass.lean | 2385 | forward_nf_eval_of_holdsLeft | BLOCKED (encoding flaw) |
| 2 | KampBypass.lean | 2560 | existPart_succ_n1_bypass_k0_since forward | Phase 4 |
| 3 | KampBypass.lean | 2562 | existPart_succ_n1_bypass_k0_since backward | Phase 4 |
| 4 | KampBypass.lean | 2715 | existPart_succ_n1_bypass k>0 | Non-goal |

## References

- Plan: specs/273_chronicle_gap_contradiction_proof/plans/39_bracketformula-k-encoding.md
- KampBypass.lean: enriched_vecEA2_until definition (L445-502), forward proof (L2322-2385), backward proof (L2008-2318)
