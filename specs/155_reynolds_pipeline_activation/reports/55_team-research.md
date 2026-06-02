# Research Report: Task #155 (Team Research Round 8)

**Task**: 155 - Fix no_gaps_discrete import cycle for sorry-free discrete completeness
**Date**: 2026-06-02
**Mode**: Team Research (4 teammates)
**Session**: sess_1780409977_dd2238

## Summary

All four teammates converge on a fundamental diagnosis: **the formalization has been trying to prove something the literature never proves** (that the Burgess chronicle is Z-isomorphic), when the literature proves a weaker claim (no definable gaps between equivalence classes) that cascades through existing infrastructure to give IsSuccArchimedean anyway. The 55 failed plans stem from this misframing. The correct approach is to close `no_gaps_discrete` via Reynolds' Theorem 14 model surgery, after which the existing code cascade delivers sorry-free `completeness_discrete`.

## Key Findings

### 1. The Sorry Chain (Confirmed by All Teammates)

```
completeness_discrete (Completeness.lean:309)
  → countermodel_discrete_reynolds (Transfer.lean:1203)
    → cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:1993)
      → succ_embed_surjective (ChronicleToCountermodel.lean:1667)
        → limitDomSubtype_isSuccArchimedean (:790)
          → succ_cofinal (:776)
            → chronicle_gap_contradiction (:489) — SORRY
```

The "dead code" label at ChronicleToCountermodel.lean:55-73 is **stale and incorrect** — these definitions ARE on the active critical path.

### 2. Why the Dense Case Succeeds (Structural Asymmetry)

The dense case is sorry-free because **Cantor's theorem gives a free order isomorphism** `LimitDomSubtype ≃o Rat`. A countable dense linear order without endpoints is uniquely characterized — automatic bijection, no surjectivity lemma needed. The discrete case has no analogous free isomorphism: countable discrete orders without endpoints can be Z, Z+Z, Z·Q, etc. The Z-isomorphism requires proving `IsSuccArchimedean`, which is the root sorry.

### 3. The Literature Does NOT Prove What Plans v50-v55 Try to Prove

No published proof attempts to show the Burgess chronicle is Z-isomorphic. Instead:

- **Reynolds 1994 (Theorem 14-15-18)**: Defines contemporaneous equivalence ~M on the chronicle ("a ~M b iff M|[a,b] is very good"). Proves class boundaries don't end at gaps (Theorem 14, via model surgery). Concludes discreteness forces one class (Theorem 15). Gets Z k-equivalent model.

- **Venema 1993**: Uses Doets' transfer theorem to get models of the target order type from models with no definable gaps.

- **Burgess 1982**: Never proves discrete completeness at all — punts to "routine exercise."

### 4. The Critical Cascade (Teammate A's Key Insight)

Closing `no_gaps_discrete` cascades through EXISTING sorry-free infrastructure:

```
no_gaps_discrete (GoodStructures.lean:820) — close via Reynolds Theorem 14
  → one_class (GoodStructures.lean:887) — follows from no_gaps_discrete
    → one_class_implies_very_good (ShiftAndGlue.lean) — SORRY-FREE
      → very_good_implies_good (ShiftAndGlue.lean) — SORRY-FREE
        → chronicle is good → M ≃o Z-interval
          → IsSuccArchimedean — follows from Z-isomorphism
            → succ_embed_surjective — follows
              → completeness_discrete — follows
```

This means the CURRENT `completeness_discrete` wiring through `succ_embed_surjective` IS the right architecture. The only missing piece is `no_gaps_discrete`.

### 5. What `no_gaps_discrete` Requires (Reynolds Model Surgery)

Reynolds' Theorem 14 proof uses Lemmas 6-13:
- **Lemma 6**: Gap-detecting formula R exists (by US expressive completeness)
- **Lemma 7-8**: R defines maximal open intervals with specific properties
- **Lemma 9**: All equivalence classes in such intervals are elementarily equivalent
- **Lemma 12** (the bulk): Truth preservation under model surgery (replacing an interval by one of its classes)
- **Lemma 13**: Contradiction — R holds in surgery model but the gap was removed

The infrastructure partially exists:
- `gap_contradicts_prior` (GoodStructuresModelSurgery.lean) — sorry-free
- `no_boundary_at_successor` — sorry-free
- `contemp_equiv_is_equiv` — sorry-free
- `US_expressively_complete_over_prior` — sorry-free
- `right_gap_class_formula` — defined

Missing: the full model surgery argument (~700 lines), specifically `gap_prior_UZ_contradiction` and `gap_prior_SZ_contradiction`.

### 6. The Constant-MCS Problem Is a Red Herring

Previous plans worried about a "constant-MCS case" where all domain points have the same MCS. Teammate A clarifies: Reynolds' equivalence ~M is defined by "very goodness" of subintervals, NOT k-type equality. Even with constant MCS, subintervals can fail to be very good (contain bad subintervals). The model surgery on ~M classes handles this automatically — the constant-MCS case doesn't arise as a separate concern.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Path A (prove chronicle is Z) vs Path B (k-equivalence transfer) | Both arrive at the same result. Closing `no_gaps_discrete` gives one_class → very_good → good → Z-iso → IsSuccArchimedean. The cascade IS Reynolds' Theorem 15. |
| Frozen guard (v55) vs model surgery | Model surgery is the literature-faithful approach. Frozen guard may be true but has resisted 55 plans. |
| Verbrugge direct Z construction vs Reynolds surgery | Both are viable. Reynolds surgery reuses more existing infrastructure (~700 lines vs ~500-1000 lines). |
| "Dead code" vs active critical path | The docstring is WRONG — succ_embed_surjective IS on the active critical path. |

### Gaps Identified

1. **The model surgery (Lemmas 10-13)** is the main missing piece. Previous implementation (task 202, cycle 17) got blocked on De Bruijn index arithmetic — a fixable engineering problem.

2. **Two UZ/SZ sorries** in `chronicle_is_good_direct` (ShiftAndGlue.lean:984,990) need chronicle_temporal_truth which requires the section property. Fix: weaken `no_gaps_discrete` to bounded-depth formulas.

3. **The import cycle** between GoodStructures.lean and GoodStructuresModelSurgery.lean needs resolution (this was the original task 155 description).

### Recommendations

**Primary**: Close `no_gaps_discrete` via Reynolds' model surgery in GoodStructuresModelSurgery.lean (~700 lines). This is the mathematically honest approach that follows the literature. The existing cascade through one_class → very_good → good → Z-iso → IsSuccArchimedean → succ_embed_surjective handles the rest.

**Fallback**: If the model surgery stalls on Lean engineering issues (De Bruijn indices), consider Teammate B's Verbrugge-style direct Z construction (~500-1000 lines). This builds the BFMCS on Z directly, bypassing the chronicle entirely.

**Do NOT**: Continue trying to prove `chronicle_gap_contradiction` directly (plans v50-v55). The literature doesn't prove this, and 55 plans have failed.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary | completed | high | Identified the cascade: no_gaps_discrete → one_class → very_good → good → Z-iso → IsSuccArchimedean. Showed Reynolds model surgery is both necessary and sufficient. |
| B | Alternatives | completed | high | Identified Verbrugge direct Z construction as viable fallback. Proved orbit restriction is equivalent to succ_cofinal (circular). Showed only restricted_tc and restricted_fuc need surjectivity. |
| C | Critic | completed | high | Diagnosed the fundamental misframing: 55 plans try to prove something stronger than the literature requires. Confirmed frozen guard argument has merit at finite-stage level but boundary cases are intractable. |
| D | Horizons | completed | high | Deep literature analysis confirming no published proof proves chronicle ≃o Z. Extracted precise mathematical chain from Reynolds/Doets. Estimated 43-75 hours for full formalization. |

## References

- Reynolds 1994: Theorems 5, 14, 15, 18 (discrete completeness over Z)
- Venema 1993: "Completeness via Completeness" (Doets transfer pattern)
- Doets 1989: Theorem 3.8 (definably well-ordered → well-ordered n-equivalents)
- Burgess 1982: Chronicle construction (dense models only)
- Verbrugge 2004: Theorem 6 (direct Z construction via step-by-step)
- Task 202 reports 13, 17: Prior analysis of Reynolds pipeline and model surgery plan
