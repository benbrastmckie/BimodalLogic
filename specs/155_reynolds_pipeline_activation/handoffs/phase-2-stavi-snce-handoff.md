# Phase 2 Handoff: stavi_snce case

## Completed
- stavi_snce FORWARD direction closed (242 lines). Gap construction identical to std_snce. S'(A,B)^mu(γ) constructed by extending S'(A,B)(s) FO table from (s₂, s) to (s₂, γ) using B∧D at cut points above s.

## Remaining: stavi_snce BACKWARD (line ~3885)

Goal: given D-gap γ with S'(A,B)^mu(γ), construct std_untl(compound, D)(m).

Approach (mirrors std_snce backward, lines 3901-4012):
1. Destructure S'(A,B)^mu(γ) via `simp only [stavi_temporal_truth_mu]` to get bound t_pt, body, fail (uf), init (ui)
2. Choose cut point s above m, t_pt, uf, AND ui (so all S' witnesses are in (t_pt, s))
3. Prove D(s), B(s) from gap structure (identical to std_snce)
4. Construct S'(A,B)(s) with bound t_pt by RESTRICTING the mu-FO-table from (t_pt, γ) to (t_pt, s):
   - body: for u ∈ (t_pt, s), body^mu(u) at carrier point = body(u) via stavi_truth_mu_at_point
   - fail: uf ∈ (t_pt, s) with ¬B(uf)
   - init: ui ∈ (t_pt, s) with B on (ui, s) — need to show B on (ui, s) from B^mu on (ui, γ) restricted
5. Construct U'(⊤, B∧D)(s) and ¬U'(D, B∧D)(s) (identical to base.snce backward, lines 3195-3269)
6. Prove D-between(m, s) (identical to std_snce)

Key subtlety for step 4: The body condition at mu-points gives results in the mu-relativized form. At carrier points, `stavi_truth_mu_at_point` converts back to standard form. The body's left disjunct (B cofinal below u) and right disjunct (A above s₂, ¬B above u) transfer directly since all witnesses are carrier points in the cut.

Estimated: ~150 lines.
