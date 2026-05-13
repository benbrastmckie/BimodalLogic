# Research Report: Task #123 — Gap Elimination Strategy (Team Research)

**Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
**Date**: 2026-05-12
**Mode**: Team Research (4 teammates)
**Session**: sess_1778652412_550f7d

## Summary

Four teammates investigated paths to close the `succ_cofinal` sorry (ChronicleToCountermodel.lean:1869). The constant-MCS gap is confirmed as genuine — no temporal axiom rules it out, and the construction can produce it. The research identifies a two-track approach: Z1/Doets for non-constant MCS (tractable, ~80 lines), plus either a construction-level or direct Z-construction argument for constant-MCS.

## Key Findings

### 1. Constant-MCS Gap is Genuine (Confirmed)

All four teammates agree: the constant-MCS scenario (all limit_dom points have identical MCS label A) is consistent with ALL axioms including Z1 and Prior-UZ. The codebase uses the Burgess convention `untl(event, guard)` where the first argument is the event (at the witness) and the second is the guard (at intermediates). Under this convention:

- Prior-UZ: `F(φ) → U(φ, ¬φ)` with p ∈ A gives a witness at succ(x) where p ∈ A (event satisfied), and ¬p at intermediates is vacuous (no intermediate points between x and succ(x)).
- Z1: trivially satisfied when all MCS labels are identical.
- **Teammate D incorrectly claimed Prior-UZ contradicts constant-MCS** — this was based on misreading the Until argument order. Verified against Axioms.lean:377-378.

### 2. Doets Henkin Approach (Teammate A)

- Full Doets implementation: 1400-2500 lines, 3-6 weeks
- Avoids constant-MCS entirely (each point = distinct MCS)
- Does NOT help close current sorry (would be a full replacement)
- Can coexist with chronicle construction as `Metalogic/DoetsCanonical/`
- Enables frame definability, n-characteristics, conservation results
- **Verdict**: Right long-term approach, wrong tool for task 123

### 3. Discrete Completeness Without IsSuccArchimedean (Teammate B)

- No weaker frame class exists in the codebase
- IsSuccArchimedean cannot be avoided: `valid_discrete` requires it
- Prior-UZ and Z1 are unsound on non-Z discrete orders
- Elementary equivalence approach is circular
- **Verdict**: Not viable. Must prove IsSuccArchimedean.

### 4. Stage Induction for Constant-MCS (Teammate D)

- Boundary sorry sites (lines 1295, 1448) are NOT on the critical path
- `succ_cofinal` uses a different proof strategy than `succ_reaches_dom_N`
- Boundary cases are stage-combinatorial, not simplified by constant-MCS
- **Verdict**: Stage induction is a dead end for this problem.

### 5. Critical Assessment (Teammate C)

- Z1/Doets approach requires discriminating formula → works only for non-constant MCS
- Most promising unexplored direction: direct Z-construction bypassing limit domain
- Risk assessment: Z1/Doets non-constant case 35-65%, direct Z-construction 55%

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Evidence |
|----------|------------|----------|
| Teammate D claimed Prior-UZ contradicts constant-MCS | REJECTED — Until arguments reversed in Burgess convention | Axioms.lean:127,377-378 |
| Teammate A vs B on frame class factoring | B is correct — no viable weaker frame class | Semantics analysis shows valid_discrete requires IsSuccArchimedean |
| Teammate C vs D on stage induction | C is correct — boundary cases are intractable regardless of MCS | Lines 1295/1448 are stage-combinatorial |

### Gaps Identified

1. No teammate fully analyzed the "direct Z-construction" approach (Teammate C mentioned it at 55% confidence but didn't develop it)
2. Nobody investigated whether `limit_satisfies_c5_strong` has different behavior when the guard formula has specific properties related to the gap
3. The possibility of modifying the construction to FORCE gap-filling points was mentioned but not deeply analyzed

### Recommended Path Forward

**Two-track approach for task 123:**

**Track 1 — Non-constant MCS (Z1 Doets, ~80 lines, 65% confidence):**
- Extract discriminating formula from MCS symmetric difference
- Apply Z1 maximum principle to get "maximum φ-point" k
- By `orbit_below_L`, k is an orbit point, succ(k) is also orbit
- Forward_G gives ¬φ at succ(k), contradicting φ at all orbit points
- This is the tractable case and should be attempted first

**Track 2 — Constant MCS (construction-level argument, ~60 lines, 50% confidence):**
- Show the construction CANNOT produce constant MCS in the gap region
- Key idea: the counterexample enumeration covers ALL (point, formula) pairs
- At some stage, a counterexample requires a witness whose placement forces a non-A MCS
- This requires understanding `eliminate_potential_counterexample` deeply
- **Alternative**: direct Z-construction bypassing the limit domain entirely (55%, 500-800 lines)

**Fallback — Full Doets Henkin (task 126+, 70% confidence, 1400-2500 lines):**
- If both tracks fail, create a new task for the Doets approach
- Can coexist with existing chronicle construction
- Is the "right" long-term solution for integer completeness

### ROADMAP Implications

**Immediate** (task 123):
- Close `succ_cofinal` → sorry-free discrete pipeline
- Unblocks: `limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective`, `dd_countermodel_chronicle_discrete`

**Next** (task 122):
- Nondense BFMCS → sorry-free `bx_completeness`

**Medium-term**:
- Doets Henkin construction → independent integer completeness proof
- Frame definability results
- n-characteristic normal forms

**Long-term**:
- Decidability
- Algebraic representation (BAO)
- Mixed completeness

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Doets Henkin approach | completed | medium (scope too large for task 123) |
| B | Discrete completeness | completed | high (conclusively ruled out) |
| C | Critical assessment | completed | high (risk analysis accurate) |
| D | Stage induction + Horizons | completed | medium (Prior-UZ claim incorrect, strategic analysis sound) |

## References

- Doets 1987: Completeness and Definability (Claims 9-11)
- Reynolds 1994: Axiomatising U and S over Integer Time (Sections 7-10)
- Axioms.lean:127 — Burgess convention `untl(event, guard)`
- Axioms.lean:377-378 — Prior-UZ definition
- SoundnessLemmas.lean:2425-2426 — Z1 requires IsSuccArchimedean
- ChronicleToCountermodel.lean:1869 — the sorry site
