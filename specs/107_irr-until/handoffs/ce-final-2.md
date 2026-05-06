# Handoff: CE:861 and CE:1197 Analysis

Session: sess_1778014444_dca927

## Summary

Analyzed CE:861 and CE:1197 sorries in CounterexampleElimination.lean. Both require structural changes beyond filling in a sorry. The build passes with the original code (4 sorries: CE:861, CE:1197, CTC:634, CTC:638).

## CE:861 - Burgess 2.10 Condition (i) (Forward Until)

### Goal
```
exists B' D B'', BurgessR3Maximal (f pc.x) B' D
  /\ BurgessR3Maximal D B'' (f x')
  /\ SetMaximalConsistent D
  /\ pc.eta in D
```

### Hypotheses at the sorry point
- `h_eta_g : pc.eta notin g(pc.x, x')` -- eta NOT in g
- `h_eta_neg_g : pc.eta.neg in g(pc.x, x')` -- eta.neg IS in g
- `h_xi_g : pc.xi in g(pc.x, x')` -- xi IS in g
- `h_conj_g : xi /\ U(xi,eta) in g(pc.x, x')` -- conjunction in g
- `h_conj_x' : xi /\ U(xi,eta) in f(x')` -- conjunction in f(x')

### Why this is impossible as stated
The goal asks for D between f(pc.x) and f(x') with eta in D. ALL existing splitting lemmas (2.6, 2.7, 2.8) produce D that extends g (via the Burgess D0 seed: B subset D). Since eta.neg in g, eta.neg in D. But D is MCS, so eta notin D. **The splitting between f(pc.x) and f(x') with eta in D is mathematically impossible when eta.neg in g(pc.x,x').**

### Burgess's solution
This is exactly **Burgess 2.10 condition (i)**: "replace x by x'." Since xi /\ U(xi,eta) in f(x'), we get U(xi,eta) in f(x') by conjunction elimination. Point x' is also a C5 counterexample (U(xi,eta) in f(x'), eta notin f(x')), with strictly fewer domain points after it. Apply the induction hypothesis at x'.

### Required restructuring

The sorry is inside `h_split_result` (lines 794-904). The fix requires restructuring the n>=1 case (lines 749-1011) so that condition (i) is checked BEFORE h_split_result:

```
by_cases h_burgess_cond_i : <conjunction of 5 conditions>
  -- Condition (i) holds: build EliminationResult differently
  -- (not via splitting at (pc.x, x'))
  ...
  -- Condition (i) fails: existing h_split_result code (now sorry-free)
  -- because the sorry case is discharged by contradiction
  exact absurd h_conj_g (h_burgess_cond_i h_conj_x' h_eta_g h_eta_neg_g h_xi_g)
```

For the condition (i) positive branch, there are two sub-cases:

1. **x' = max_old**: Apply `lemma_2_4` at f(x') = f(max_old). Insert y > max_old. R3M(f(max_old), B_new, C) from lemma_2_4. Witness: y > pc.x with eta in f(y) = C. **This case is fully implementable** -- I wrote working code for it.

2. **x' != max_old**: Need to "propagate forward" to find a gap where the splitting works. This requires well-founded recursion on `(dom.filter (. > s)).card`. Two sub-sub-cases:
   - If eta in f(x''): x'' is already a witness. Return chi unchanged.
   - If eta notin f(x''): Apply the same splitting logic at (x', x''). If condition (i) holds there too, propagate further. Eventually either reach max_old (case 1) or find a gap where condition (i) fails.

### Implementation attempt
I attempted the restructuring (added ~490 lines). The condition (i) positive branch with x'=max was fully implemented. The x'!=max branch with eta in f(x'') was implemented. The deep nesting (condition (i) at (x',x'') too) still had a sorry due to the difficulty of proving R3M(D, B'', f(x'')) for the second half of a new splitting. The code had indentation issues that caused cascading build errors.

**Key technical blocker for the deep nesting**: After constructing D from forward_temporal_witness_seed at f(x') (giving eta in D and g_content(f(x')) subset D), we need R3M(D, B'', f(x'')). This requires either `g_content(D) subset f(x'')` or `h_content(f(x'')) subset D`. Neither is directly provable from the available hypotheses.

### Recommended approach
Write a **standalone recursive helper** `c5_forward_from_point` placed before `eliminate_potential_counterexample`, using `Nat.strongRecOn'` on `(dom.filter (. > s)).card`. This helper takes a starting point s with U(xi,eta) in f(s) and returns an EliminationResult. The recursive cases mirror the existing n=0/n>=1 logic but generalized from pc.x to s.

## CE:1197 - Since Mirror (Backward C5')

### Goal
```
exists B' D B'', BurgessR3Maximal (f x'') B' D
  /\ BurgessR3Maximal D B'' (f pc.x)
  /\ SetMaximalConsistent D
  /\ pc.eta in D
```

### Hypotheses
- `h_eta_g : pc.eta notin g(x'', pc.x)`
- `h_eta_neg_g : pc.eta.neg in g(x'', pc.x)`
- R3M(f(x''), g(x'',pc.x), f(pc.x))
- `h_since : S(xi,eta) in f(pc.x)` (Since formula in C)

### Analysis
Same fundamental issue as CE:861: eta.neg in g prevents eta in D via the standard splitting. This is the **backward mirror** of the Burgess 2.10 case.

Additionally, the existing code does NOT have the full case analysis for the Since direction. The comment says: "Deferred: requires implementing lemma_2_7_since or lemma_2_8_since."

The Since case needs:
1. `lemma_2_7_since`: Given R3M(A, B, C), S(xi,eta) in C, xi notin B, produce splitting with eta in D. ~300 lines (mirrors lemma_2_7).
2. `lemma_2_8_since`: Since mirror of lemma_2_8. ~200 lines.
3. Full case analysis mirroring the Until case (~100 lines).
4. Condition (i)' handling with recursion (same as CE:861 but backward).

## CTC:634 and CTC:638

These are in ChronicleToCountermodel.lean and require `limit_satisfies_c5_strong` / `limit_satisfies_c5'_strong` (full C5 with guard at the limit). These are a separate concern from CE:861/CE:1197 and are tracked in the previous handoff (phase7-fuc-fsc.md).

## Effort Estimate

| Sorry | Approach | Estimated Lines | Difficulty |
|-------|----------|-----------------|------------|
| CE:861 | Recursive helper + restructure | ~400 new + ~100 restructured | Hard |
| CE:1197 | lemma_2_7_since + lemma_2_8_since + case analysis + recursion | ~600 new | Hard |

Total: ~1100 lines of new proof code.

## Files Modified
None (reverted to clean state for build safety).

## Key Files
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (CE:861 at line 861, CE:1197 at line 1197)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (contains lemma_2_7, lemma_2_8, lemma_2_4)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (CTC:634, CTC:638)
