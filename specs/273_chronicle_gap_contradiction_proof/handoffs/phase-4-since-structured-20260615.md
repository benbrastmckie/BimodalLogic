# Phase 4 Handoff: Since Case Structured + Permutation Lemma Deleted

## Immediate Next Action

The next dispatch should address the fundamental encoding flaw that blocks both the Until forward direction (L2205) and the Since forward/backward directions (L2380, L2382). The encoding issue is:

**Problem**: Positive between_tx (Until) and between_xt (Since) SSNs are encoded using unbounded temporal operators (`Formula.snce char_y Formula.top` at x for Until, `Formula.untl char_y Formula.top` at x for Since). These provide one bound (y < x or y > x) but lose the other bound (y > t or y < t).

**Fix Required**: Change the encoding in both `enriched_vecEA2_until` (line 481-484) and `enriched_bypass_since` (line 585-587) to use a bounded encoding. Two approaches:
- **(A) Nested Until/Since**: Replace between_tx Since at x with nested Until at t. Replace between_xt Until at x with nested Since at t. This guarantees both bounds by construction.
- **(B) BracketFormula k**: Use BracketFormula with k = number of positive between SSNs. Witnesses are bounded to (t, x) by bracket semantics. Requires solving the witness ordering problem for k >= 2 (different SSN types at different positions).

Approach (A) is recommended. For Until direction: replace `Formula.snce char_y Formula.top` at x (line 484) with `Formula.untl (char_y.and (Formula.untl (char_1 nf_x) seg_guard_f)) seg_guard_f` at t (in endpointLeft). For Since direction: mirror with `Formula.snce`.

## Current State

- Phase 4 partially complete (incompatible cases proved, compatible case blocked)
- Build: GREEN (993 jobs)
- Sorry sites in KampBypass.lean:
  - L2205: `forward_nf_eval_of_holdsLeft` (Until forward, blocked by encoding)
  - L2380: Since forward direction (blocked by encoding)
  - L2382: Since backward direction (blocked by missing zone bridges)
  - L2535: k>0 case (out of scope)
- VecEAFormula.lean: sorry-free (permutation lemma deleted)
- KampBypass sorry count: 4 sorry lines (was 4: 3 original + 1 restructured into 2)

## Key Decisions

1. **Deleted BracketFormula.holds_of_unordered_distinct**: The permutation lemma was incorrectly stated. Even with a correct statement, the BracketFormula n approach for n >= 2 has an inherent ordering issue (witnesses for different SSN types are at model-determined positions that cannot be reordered).

2. **Structured Since proof**: Instead of a single total sorry, the Since case now has 3 proved cases (incompatible) and 2 sorry's (compatible case forward/backward). This reduces the scope of remaining work.

3. **Confirmed encoding flaw is shared**: Both Until and Since directions have the same fundamental encoding problem for positive between-zone SSNs.

## Sorry Inventory

| File | Line | Statement | Why Deferred | Next Dispatch |
|------|------|-----------|-------------|---------------|
| KampBypass.lean | 2205 | forward_nf_eval_of_holdsLeft | Encoding loses y > t for positive between_tx | Fix enriched_vecEA2_until encoding |
| KampBypass.lean | 2380 | existPart_succ_n1_bypass_k0_since (forward) | Encoding loses y < t for positive between_xt | Fix enriched_bypass_since encoding |
| KampBypass.lean | 2382 | existPart_succ_n1_bypass_k0_since (backward) | Missing zone bridge lemmas for Since direction | Create zone bridges OR fix encoding |
| KampBypass.lean | 2535 | existPart_succ_n1_bypass (k > 0) | Out of scope (depth IH) | Separate task |

## References

- Plan: specs/273_chronicle_gap_contradiction_proof/plans/37_bounded-until-fix.md
- enriched_vecEA2_until definition: KampBypass.lean:444-490
- enriched_bypass_since definition: KampBypass.lean:513-592
- Until backward proof (reference for Since): KampBypass.lean:1932-2135
- Zone bridges (Until only): KampBypass.lean:1628-1930
