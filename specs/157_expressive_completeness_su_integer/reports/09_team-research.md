# Research Report: Task #157

**Task**: Formalize expressive completeness of {S,U} over integer time (GHR94 Ch 10)
**Date**: 2026-05-18
**Mode**: Team Research (4 teammates)
**Session**: sess_1779144447_32fc24

## Summary

All 4 teammates converge on a single root cause for 7+ failed hierarchy attempts: `is_syntactically_separated` (Defs.lean:148-149) accepts `all_past`/`all_future` as separated, causing Cases 1-2 to produce non-GHR94-conformant witnesses. When the hierarchy's `subst_in_separated_separable` encounters these in the callback, it creates irresolvable circularity. GHR94 works in `{S, U, boolean}` only — no `all_past`/`all_future` primitives. The fix is to eliminate these from separated witnesses, either by redefining `is_syntactically_separated` or introducing a second predicate `is_base_separated`. Both approaches require rewriting Cases 1-2 (and possibly 3-4, 5, 8) to produce GHR94-conformant separated equivalents.

## Key Findings

### 1. Root Cause: Language Mismatch Between GHR94 and Our Formalization (UNANIMOUS — all 4 teammates)

GHR94 Section 10.2 works exclusively in `{S, U, ¬, ∧}`. Their definition of "syntactically separated" (p. 571): "a boolean combination of atoms, wffs U(E,F) with E and F built without using S, and wffs S(E,F) with E and F built without using U." No `all_past`/`all_future` appears.

Our `is_syntactically_separated` (Defs.lean:148-149) widens this:
```lean
| .all_past φ => is_U_free φ    -- NOT in GHR94
| .all_future φ => is_S_free φ  -- NOT in GHR94
```

Cases 1-2 (Eliminations.lean) exploit this widening to produce separated witnesses containing `all_future(¬A)` (line 372) and `all_past(¬a)` (lines 458, 515). When the hierarchy theorem's callback receives these, expanding them either breaks `no_S_nested_in_U` or inflates `count_U`, creating irresolvable circularity.

**Every failed attempt (7+) accepted the Case 1-2 witnesses as given and tried to work around the `all_past`/`all_future` they produce. None attempted to fix the witnesses themselves.**

### 2. Simple Substitution Does NOT Work (HIGH CONFIDENCE — Teammate B's critical finding)

A naive fix — replacing `all_future(¬A)` with `¬U(A, ⊤)` inside `.snce` events — fails because:
- `¬U(A, ⊤)` = `.imp (.untl A .top) .bot` contains `.untl`
- Therefore `is_U_free` is `false` for the `.snce` event
- The formula is NOT syntactically separated

GHR94's actual Case 2 equivalent (literature lines 63-66) has a DIFFERENT structure:
```
[S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A,B)]           -- D1
∨ [¬A ∧ ¬B ∧ S(a, ¬A ∧ q)]               -- D2
∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q)       -- D3
```
Here `¬U(A,B)` is at the BOOLEAN LEVEL (not inside S), so it IS separated. The `.snce` events are all U-free. This formula is separated in the `{S, U, boolean}` language without `all_past`/`all_future`.

Cases 1-2 need STRUCTURAL rewrites to use GHR94's actual formulas, not just term substitutions.

### 3. Cases 3-4 Have a Simpler Fix (MEDIUM-HIGH CONFIDENCE — Teammates B, C)

Cases 3-4 use `Formula.neg (.all_past (Formula.neg a))` = `¬H(¬a)`. On integer time:
- `¬H(¬a) ≡ S(a, ⊤)` (semantic equivalence via `all_past_equiv_neg_snce`)
- `.snce a .top` has U-free args → separated without `all_past`

So Cases 3-4 can replace `¬(.all_past (¬a))` with `.snce a .top`. This is a structural substitution (no new semantic proof needed), unlike Cases 1-2 which require GHR94's full three-disjunct formulas.

### 4. Induction Measure Mismatch (HIGH CONFIDENCE — Teammates B, C)

GHR94's Lemma 10.2.6 uses induction on the NUMBER OF DISTINCT U-TYPES n, not on `count_U_subformulas` (total U-node count). The substitution-back step can INCREASE total U-node count (one atom occurrence becomes one `.untl` node, but the atom may appear multiple times). However, the number of DISTINCT U-types strictly decreases because the abstracted type U(An,Bn) appears only in future positions of the separated form, never in past positions where substitution occurs.

The current Lean code uses `count_U_subformulas` (total count). This must be changed to a distinct-type count or a different well-founded relation.

### 5. GHR94's Hierarchy Is Straightforward Once Witnesses Are Fixed (HIGH CONFIDENCE — Teammates A, C)

With base-separated witnesses (no `all_past`/`all_future`):
1. `subst_in_separated_separable` callback receives only `.snce c' d'` (never `.all_past`)
2. These `.snce c' d'` have `no_S_nested_in_U` (by `subst_U_free_gives_no_S_nested`)
3. They have `has_no_allpast_allfuture` (base-separated → no `all_past`/`all_future`)
4. Count of distinct U-types is strictly less than the original
5. The circularity disappears entirely

### 6. Task 155 Is NOT Blocked (HIGH CONFIDENCE — Teammate D)

`US_expressively_complete_over_Z` is already sorry-free. Task 155 (Reynolds pipeline) needs this theorem to exist, not to be axiom-free. Task 155 can proceed immediately. Axiom elimination is about proof quality (Roadmap Phase 2), not correctness.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Redefine `is_syntactically_separated` (A, B, C) vs Two-predicate approach (D) | **Both viable.** Redefinition is cleaner long-term but has cascade risk. Two-predicate is safer but adds conceptual overhead. If combined with task 116 (redefine G/H/F/P), redefinition is natural. For near-term fix, two-predicate avoids cascade. **Recommendation: two-predicate for speed, redefine as follow-up with task 116.** |
| Effort estimate: 350 LOC (D) vs 575 LOC (A) vs 400-600 LOC (B) | **Both estimates undercount the Case 1-2 rewrite.** Teammates A and C give 50-150 LOC for "simple" case fixes but B correctly identifies that Cases 1-2 need full GHR94 three-disjunct formula proofs (~150-200 LOC each). Cases 3-4 are simpler (~50 LOC each via `.snce a .top` substitution). **Realistic total: 400-600 LOC for case rewrites + hierarchy.** |
| `count_U_subformulas` vs distinct-type count (B, C) | **Use distinct-type count.** GHR94 explicitly uses this. May require a new measure function. Alternative: use existing `count_U_subformulas` but with the abstraction removing ALL copies of one U-type (which does strictly decrease total count). Need to verify this works. |
| Descope axiom elimination (D) vs continue (A, B, C) | **Continue but with clear path.** The fix (base-separated witnesses) is now well-understood. One more focused implementation attempt (4-8 hours) should suffice. If it fails, descope. |

### Gaps Identified

1. **No prototype exists.** Nobody has tried even a 10-line proof-of-concept: modifying Case 1 to use `¬(.untl A .top)` at the boolean level (where it IS separated) and verifying it compiles. This would validate the approach before investing in full rewrites.

2. **Cases 5 and 8 also use `all_past`/`all_future`** (DedekindZ.lean:1154, 1878). These need analysis of whether GHR94's direct formulas apply or if simpler substitutions suffice.

3. **The dual infrastructure `subst_in_separated_separable_snce`** (substituting `.snce E F` for atoms) is needed for the `.untl` case of the JD induction (10.2.8). Teammate A identified this. It's a mirror of the existing `subst_in_separated_separable` (~80 LOC).

4. **Well-founded relation for distinct-type count** needs precise definition. What constitutes a "distinct U-type"? Is `U(A, B)` distinct from `U(A', B')` when `A ≡ A'` semantically but `A ≠ A'` syntactically? GHR94 uses syntactic identity.

## Recommendations

### Implementation Strategy (ordered by priority)

**Phase 0: Prototype Validation (30 min)**
- Modify Case 1 in Eliminations.lean to NOT use `.all_future`
- Verify the modified witness is `is_syntactically_separated` (or `is_base_separated`)
- Run `lake build` to check nothing breaks
- This validates the approach before investing in full rewrites

**Phase 1: Define `is_base_separated` and Rewrite Cases (4-6 hours, ~300 LOC)**

Option A (two-predicate, lower risk):
1. Define `is_base_separated` in Defs.lean (~10 LOC) — same as `is_syntactically_separated` but `all_past`/`all_future` return `false`
2. Prove Case 1-2 equivalents that produce `is_base_separated` witnesses:
   - Case 1: Use GHR94's direct formula (no `G(¬A)`)
   - Case 2: Use GHR94's three-disjunct formula (lines 63-66)
   - Case 3: Replace `¬H(¬a)` with `.snce a .top` (~50 LOC)
   - Case 4: Same as Case 3 (~50 LOC)
   - Cases 5, 8: Analyze whether they need full rewrites or simpler fixes
3. Prove `lemma_10_2_4_base` variant that produces `is_base_separable` results

Option B (redefine, cleaner long-term):
1. Change `is_syntactically_separated` to exclude `all_past`/`all_future` (2 lines)
2. Fix all compilation errors (cascade from Cases 1-2, lemmas depending on `all_past`/`all_future` being separated)
3. This is better combined with task 116

**Phase 2: Prove Hierarchy (~300 LOC)**
1. `no_S_nested_in_U_separable_base` — the existing parameterized version works once callback never gets `all_past`/`all_future`
2. `junction_depth_separable` — strong induction on JD, uses `no_S_nested_in_U_separable_base` and `subst_in_base_separated_separable`
3. `all_formulas_base_separable` — wrapper: expand_temporal + JD induction

**Phase 3: Axiom Elimination (~50 LOC)**
1. Bridge `is_base_separable → is_separable` (trivial)
2. Prove `all_formulas_separable` from `all_formulas_base_separable`
3. Replace 9 axioms with `all_formulas_separable _`

### Minimum Viable Target

If full axiom elimination proves too complex:
1. Eliminate the 4 `is_separable` axioms (highest value) — these follow directly from `all_formulas_separable`
2. Document the 4 `is_properly_separable` + 1 atom preservation axioms as follow-up
3. Mark task as PARTIAL with clear next steps

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary Implementation | completed | high | Detailed implementation path: redefine + hierarchy architecture, exact Lean signatures |
| B | Alternative Approaches | completed | high | Critical finding: simple substitution fails — need GHR94's actual three-disjunct formulas. Approach comparison table |
| C | Critic | completed | high | Root cause validation: Cases 1-2 produce non-GHR94 witnesses. Audit of all 7+ failed attempts shows same structural error. Induction measure mismatch |
| D | Strategic Horizons | completed | high | Cost-benefit analysis (task 155 not blocked), two-predicate approach, alignment with task 116 |

## References

- GHR94 Ch 10.2, Lemma 10.2.3 items 1-4 (Cases 1-4 direct formulas WITHOUT G/H)
- GHR94 Ch 10.2, Lemmas 10.2.5-10.2.8 (hierarchy structure)
- `TemporalClosure.lean:608-629`: `all_past_equiv_neg_snce`, `all_future_equiv_neg_untl`
- `Hierarchy.lean:1261-1297`: `subst_in_separated_separable` callback mechanism
- `specs/157_expressive_completeness_su_integer/handoffs/phase-3-callback-analysis-20260518.md`: Prior blocker analysis
- `specs/157_expressive_completeness_su_integer/reports/10_allpast-allfuture-analysis.md`: Separated formulas contain `all_past`/`all_future`
