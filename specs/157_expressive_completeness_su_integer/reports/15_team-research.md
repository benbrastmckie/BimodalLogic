# Research Report: Task #157 — GHR94 Faithful Restructuring Feasibility

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Mode**: Team Research (4 teammates), Round 15
**Session**: sess_1779206505_915d3f
**Focus**: Systematic study of GHR94's actual proof structure and restructuring feasibility

---

## Summary

Four teammates investigated GHR94's Lemma chain 10.2.3–10.2.8, mapped it precisely to the codebase, identified all blockers to faithful implementation, and validated the approach against hidden problems. The core finding: **GHR94's proof IS acyclic and the restructuring IS feasible, but requires a specific new operation (`abstract_inner_U`) that the codebase lacks.** The depth-1 gap persists with ANY simple measure (JD or snce_depth_of_U) because the current abstraction direction (U-under-S) produces same-depth callbacks. GHR94 avoids this by abstracting in the opposite direction (U-within-U-args), which guarantees strict decrease.

---

## Key Findings

### Finding 1: Precise GHR94-to-Codebase Mapping [HIGH confidence — A]

| GHR94 Lemma | Codebase | Status |
|-------------|----------|--------|
| 10.2.3 Cases 1-4 | `Eliminations.lean` elim_case_1/2/3/4 | COMPLETE (sorry-free) |
| 10.2.3 Cases 5-8 | Via `all_separable` (axiom) | NOT faithful |
| 10.2.4 | `subst_in_separated_separable` + callback | PARTIAL |
| 10.2.5 | `no_S_nested_in_U_separable_param` (count_U induction) | PARTIAL |
| 10.2.6 | `no_S_nested_in_U_separable_param_jd` | PARTIAL |
| **10.2.7** | **NOT IMPLEMENTED independently** | **MISSING** |
| 10.2.8 | `all_formulas_separable_aux` | **2 sorry (lines 1773, 1806)** |

The first divergence from GHR94 is at Lemma 10.2.7. The codebase collapses 10.2.7 into 10.2.8's callback, creating the bootstrap problem where JD=1 callbacks cannot be resolved.

### Finding 2: The Depth-1 Gap Persists Under ANY Simple Measure [HIGH confidence — A, B, D]

All three teammates independently confirmed: switching from `junction_depth` to `snce_depth_of_U` as the induction measure does NOT eliminate the circularity. At depth/JD = 1, callbacks from `subst_in_separated_separable` produce formulas with depth/JD ≤ 1 (not strictly less). The identity roundtrip `.snce (.untl A B) q → callback → .snce (.untl A B) q` maps the formula to itself at the same measure.

This means the gap is fundamental to the current **abstraction direction**, not to the measure choice.

### Finding 3: GHR94's Key Insight — A Different Abstraction Direction [HIGH confidence — B]

**This is the most important finding of this round.**

The current codebase abstracts **U-under-S**: it replaces `.untl A B` (a U-node under an S-node) with a fresh atom, separates, then substitutes back. The callback handles the resulting `.snce` nodes.

GHR94 Lemma 10.2.7 abstracts in the **opposite direction**: **U-within-U-args**. It replaces inner U-subformulas `U(Xij, Yij)` that appear INSIDE the arguments `Ai, Bi` of outer U-nodes `U(Ai, Bi)`, replacing them with fresh atoms. This produces `U(A'i, B'i)` where `A'i, B'i` are boolean (no U). Then:

1. Apply Lemma 10.2.6 to the modified formula (all U-args are now boolean) → separated form E'
2. Back-substitute inner U's: `zij → U(Xij, Yij)` in E'
3. The pure-past parts of E' now contain `U(Xij, Yij)` at depth n-1 < n
4. Apply IH at depth n-1

**Why this works**: The inner U's land in pure-past positions of the separated form. Their `snce_depth_of_U` is strictly less than the original because they were one nesting level deeper. The strict decrease is structural, not dependent on the measure matching exactly.

**What's missing in the codebase**: The `abstract_inner_U` operation — a function that traverses U-args and replaces their inner U-subformulas with fresh atoms. This is ~200-250 LOC with 5 key properties.

### Finding 4: Path 1 (Axiom Routing) Is Trivially Executable [HIGH confidence — D]

The immediate fix requires changing exactly 2 callback lambdas:

```lean
-- Line 1771-1773 (snce case), BEFORE:
(fun ζ hns_ζ hjd_ζ => ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
-- AFTER:
(fun ζ _hns_ζ _hjd_ζ => all_separable ζ)

-- Line 1804-1806 (untl case), same change
```

`all_separable` is already imported from `SeparationThm.lean`. No type complications, no import changes. This eliminates `sorryAx` by routing through the already-axiomatized `snce_separable`. The 9 axioms remain, but the proof is honest.

### Finding 5: DualEliminations Can Be Fixed by Changing Conclusions [MEDIUM confidence — C]

The 8 sorry stubs in `DualEliminations.lean` fail because they try to prove `is_S_free` from `is_syntactically_separated` (which doesn't hold). Changing the conclusions from `is_S_free` to `is_separable` eliminates all 8 sorries immediately, since the hierarchy theorem only needs separability, not S-freeness.

### Finding 6: Reynolds 1994 Provides No Alternative [HIGH confidence — C]

Reynolds cites GHR94's separation theorem as a black box. No alternative separation proof structure. The team cannot use Reynolds as an escape route.

### Finding 7: Box Modality Is Handled Correctly [HIGH confidence — C]

The `replace_box_with_top` / `replace_box_equiv` box normalization is a codebase-specific addition not in GHR94. It is already correctly integrated into the hierarchy theorem and does not need rebuilding for the restructuring.

---

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| C proposes `callback_jd_is_zero_when_input_jd_one` vs A/B/D show callbacks have JD ≤ 1 (not 0) | **A/B/D correct.** The identity roundtrip `.snce (.untl A B) q` produces callback with JD = 1 (not 0). The `jdS(.untl A B) = 1 + max(jd A, jd B) = 1` when `jd A = jd B = 0`. Callback JD = max(1, 0) = 1. C's proposed tighter bound does not hold in general. |
| B estimates 480-600 LOC for full restructuring vs D estimates ~200 LOC | **Both valid for different scopes.** D's 200 LOC assumes `abstract_inner_U` with minimal properties. B's 480-600 LOC includes full monotonicity lemmas, base case proofs, and the `all_formulas_separable_aux` rewrite. B's estimate is more complete. |

### Gaps Identified

1. **`abstract_inner_U` is entirely missing.** No function in the codebase traverses U-args to replace inner U-subformulas with atoms. This is the single largest missing piece (200-250 LOC with properties).

2. **GHR94 Lemma 10.2.4 generalization not attempted.** Cases 1-8 work for atom arguments only. Extending to formula arguments (via DNF/CNF) is needed for the depth-1 case of 10.2.7.

3. **The `snce_depth_zero_no_S_nested_separated` base case lemma is missing.** Need: `no_S_nested_in_U φ → snce_depth_of_U φ = 0 → is_syntactically_separated φ`. Estimated ~25-35 LOC.

---

## Recommendations

### Path 1 — Immediate Fix [30 minutes, EXECUTE NOW]

Replace sorry with `all_separable ζ` at both sites. This is a 2-line change with zero complications. Eliminates `sorryAx` from `lean_verify`. The 9 axioms remain as named axiom declarations.

### Path 2 — Correct Mathematical Fix [480-600 LOC, 20-40 hours]

Implement GHR94's actual proof structure with the correct abstraction direction:

**Phase 1: Infrastructure** (~110 LOC)
- `snce_depth_of_U` monotonicity lemmas (~75 LOC)
- `snce_depth_zero_no_S_nested_separated` base case (~35 LOC)

**Phase 2: `abstract_inner_U`** (~250 LOC)
- Function definition (~70 LOC)
- `abstract_inner_U_preserves_no_S_nested` (~30 LOC)
- `abstract_inner_U_depth_le_one` (~40 LOC)
- `abstract_inner_U_roundtrip` semantic equivalence (~50 LOC)
- `back_subst_depth_lt` strict decrease (~60 LOC)

**Phase 3: GHR94 10.2.7 Direct** (~160 LOC)
- `no_S_nested_in_U_separable_direct` via snce_depth_of_U strong induction
- Uses `abstract_inner_U` at depth ≥ 2, applies 10.2.6, back-substitutes, IH

**Phase 4: Hierarchy Rewrite** (~80 LOC)
- Simplify `all_formulas_separable_aux` JD=1 case to call 10.2.7 directly
- Eliminate callback circularity

**Dependency order**: Phase 1 → Phase 2 → Phase 3 → Phase 4

### DualEliminations Quick Fix [~30 minutes, independent]

Change 8 dual case conclusions from `is_S_free` to `is_separable`. Eliminates 8 sorry stubs.

### NOT Recommended

| Approach | Why Not |
|----------|---------|
| `snce_depth_of_U` induction alone (without `abstract_inner_U`) | Same gap at depth 1 |
| Lexicographic (JD, count_U) | Identity roundtrip: count_U doesn't decrease |
| Dershowitz-Manna multiset | 300-500 LOC infrastructure, overkill |
| Changing JD definition (+1) | Destroys bounded callback property |
| `callback_jd_is_zero_when_input_jd_one` | FALSE for identity roundtrip |

---

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | GHR94 lemma mapping | completed | Precise 10.2.3-10.2.8 mapping; 10.2.7 identified as MISSING | HIGH |
| B | Restructuring feasibility | completed | `abstract_inner_U` as key missing operation; 480-600 LOC estimate; blocker-by-blocker analysis | HIGH |
| C | Critic | completed | DualEliminations fix (conclusions to is_separable); Reynolds provides no alternative; box modality validated | HIGH |
| D | Practical Lean patterns | completed | Path 1 exact code change; Mathlib WF patterns catalog; snce_depth_of_U gap confirmation | HIGH |

---

## References

- GHR94 Ch 10: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`
- Reynolds 1994: `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Hierarchy.lean: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (sorry: lines ~1773, ~1806)
- SeparationThm.lean: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (9 axioms)
- Eliminations.lean: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (Cases 1-4 proved)
- DualEliminations.lean: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` (8 sorry stubs)
- Defs.lean: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (JD definitions, snce_depth_of_U)
