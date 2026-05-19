# Research Report: Task #157 — JD=1 Callback Circularity

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1779205467_c8785d
**Focus**: JD=1 callback circularity — systematic research into root cause and solutions

---

## Summary

Four research teammates investigated the JD=1 callback circularity in `Hierarchy.lean` from complementary angles: primary approaches (JD redefinition, well-founded measures), alternative structures (callback avoidance, alternative proofs), critical analysis (assumption validation, blind spots), and strategic horizons (project impact, creative alternatives). The synthesis resolves key conflicts and identifies the mathematically correct fix.

**Root cause**: The implementation's proof structure diverges from GHR94's acyclic lemma chain. GHR94 proves Lemmas 10.2.3 → 10.2.4 → 10.2.5 → 10.2.6 → 10.2.7 → 10.2.8 in strict order, each depending only on earlier lemmas. The implementation introduced a callback mechanism that creates a circular dependency absent from the original proof. Additionally, the Lean `junction_depth` definition is systematically off by 1 from GHR94's definition, causing the implementation's JD=1 (= GHR94's JD=2) to be treated as a base case when it is actually the first non-trivial inductive case.

---

## Key Findings

### Finding 1: The Sorry Asserts a False Proposition [HIGH confidence — A, C]

Line 1773 of `Hierarchy.lean` contains `by sorry` attempting to prove `junction_depth ζ ≤ 0`. The identity roundtrip counterexample shows ζ can have `junction_depth = 1`. This is provably false, not merely a gap. Any correct fix must approach the JD=1 case with a fundamentally different strategy — the current callback-to-JD-0 path is impossible.

### Finding 2: The Lean JD Definition Is Off by 1 from GHR94 [HIGH confidence — A, C, D]

All three teammates independently verified this definitional mismatch:

| Formula | Lean JD | GHR94 JD |
|---------|---------|----------|
| `.snce (.untl a b) q` (a,b,q atoms) | 1 | 2 |
| `.untl a b` (a,b atoms) | 0 | 1 |
| `atom p` | 0 | 0 |

GHR94's claim "JD ≤ 1 implies already separated" translates to Lean as "JD = 0 implies separated" — which IS proved as `expanded_jd_zero_imp_separated`. The sorry at Lean JD=1 corresponds to GHR94's first non-trivial inductive case (GHR94 JD=2), NOT a base case.

### Finding 3: GHR94's Proof Is NOT Circular [HIGH confidence — C]

GHR94 Lemmas 10.2.3 → 10.2.4 → 10.2.5 → 10.2.6 → 10.2.7 → 10.2.8 form an acyclic dependency chain. The "by the result we are proving" characterization in prior analyses is incorrect. The circularity exists entirely because the implementation chose a different proof structure (abstract-substitute with callback) that diverges from GHR94's approach. GHR94 Lemma 10.2.8 replaces S-subformulas INSIDE U-args to reduce JD, then applies the already-proved Lemma 10.2.7. The implementation inverts this by replacing U-occurrences and using callbacks.

### Finding 4: At JD=1, Extracted `.untl A B` Has `jd A = jd B = 0`, But A May Not Be U-free [HIGH confidence — A, B]

When `junction_depth(.snce χa χb) ≤ 1`, the extracted `.untl A B` satisfies:
- `jdS(.untl A B) ≤ 1` → `1 + max(jd A, jd B) ≤ 1` → `jd A = jd B = 0`
- A, B are S-free (from `extract_U_type_S_free`)

However, `jd A = 0` and S-free does NOT imply U-free. Counterexample: `A = .untl (atom p) (atom q)` has `jd = max(jdU(atom p), jdU(atom q)) = 0`, is S-free, but is NOT U-free. This corrects an error in prior analyses that assumed A, B must be boolean at JD=1.

### Finding 5: The +1 JD Redefinition Does NOT Work [HIGH confidence — A]

Adding +1 at `.snce`/`.untl` in `junction_depth` (to match GHR94's definition) makes `JD' ≤ 1` trivially separated — but DESTROYS the bounded callback property. Under +1, separated formulas like deeply nested `.untl(.untl(.untl...))` have UNBOUNDED JD'. The crucial lemma `snce_of_boxfree_sep_jd_le_one` breaks, removing the bound that makes the n ≥ 2 case (currently fully proved) work. This is the critical flaw that C's analysis did not account for.

**Resolution of A vs C conflict**: C correctly noted that at new JD=2, callbacks might have JD=1 < 2 (strict decrease). However, this argument assumes `snce_of_boxfree_sep_jd_le_one` still bounds callbacks — which it cannot under the +1 definition because separated formulas have unbounded JD'. A's analysis is definitive: +1 should NOT be pursued.

### Finding 6: The Sorry IS Mathematically Equivalent to `snce_separable` [HIGH confidence — A, B]

Both A and B independently confirmed through structural analysis that the 2 sorry calls are equivalent to the `snce_separable` axiom: given `is_separable a` and `is_separable b`, prove `is_separable (.snce a b)`. Every approach to fill the sorry within the current callback architecture reduces to this axiom. No single-formula measure (JD, count_U, sizeOf, snce_depth_of_U) decreases for the identity roundtrip case.

### Finding 7: The Problem Is More Constrained Than General `snce_separable` [MEDIUM confidence — C]

The actual callback formula has specific structure: `ζ = .snce (c[p:=.untl A B]) (d[p:=.untl A B])` where c, d are U-free, A, B are S-free with `jd = 0`, and `no_S_nested_in_U ζ` holds. This is narrower than arbitrary `snce_separable`. However, even this constrained form cannot be proved without `snce_separable` within the current architecture (A, B confirmed).

### Finding 8: Task 157 Is NOT on the Critical Path for `bx_completeness` [HIGH confidence — D]

Task 155 (Reynolds pipeline) uses the 9 axioms in `SeparationThm.lean` as a trusted black-box. They appear as named `axiom` declarations, not `sorryAx`. The single publication-path sorry is `succ_cofinal` in `ChronicleToCountermodel.lean`, entirely unrelated. Task 157's axiom elimination is a publication-quality enhancement, not a prerequisite.

---

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A says +1 doesn't work vs C says +1 might work | **A is correct.** C's argument that callbacks at new JD=2 would have JD=1 < 2 is valid in isolation, but fails because `snce_of_boxfree_sep_jd_le_one` breaks under +1 (separated formulas have unbounded JD'). The bound that constrains callbacks disappears. |
| B says sorry = snce_separable (intractable) vs C says GHR94 is not circular (tractable) | **Both are right, about different things.** The sorry IS equivalent to snce_separable within the current architecture (B). But GHR94's acyclic proof structure avoids this circularity entirely (C). The fix is to restructure the proof to follow GHR94 faithfully, not to solve the circularity within the current architecture. |
| D claims count_U IH handles callback at JD=1 vs A shows count_U can increase | **A is correct for the identity roundtrip.** The callback formula φ = `.snce (.untl A B) q` maps to itself: count_U(callback) = count_U(original). No decrease. D's lexicographic (JD, count_U) approach fails for the same reason. |

### Gaps Identified

1. **GHR94 Lemma 10.2.7 was never faithfully implemented.** The implementation uses `count_U_subformulas` induction; GHR94 uses `snce_depth_of_U` (depth of U-nesting beneath S). This difference is what introduces the callback circularity (C, confirmed by B). Nobody has attempted the faithful `snce_depth_of_U` approach.

2. **GHR94 Lemma 10.2.6 (multi-U-type no_S_nested separability) is not proved.** This is the upstream lemma that GHR94 Lemma 10.2.7 calls. The codebase jumps from individual Cases 1-8 (10.2.3) to the callback-based architecture, skipping the intermediate generalization steps 10.2.4-10.2.6.

3. **Generalized Cases 1-8 (non-atom arguments) were never attempted.** GHR94 Lemma 10.2.4 extends Cases 1-8 from atom arguments to formula arguments via DNF/CNF decomposition. This generalization may enable inline handling of callback formulas without recursion.

---

## Recommendations

### Path 1 — Immediate Fix: Route Through Existing Axiom [~30 minutes]

Replace the 2 sorry calls at `Hierarchy.lean` lines ~1773 and ~1806 with explicit invocations of the already-axiomatized `snce_separable`:

```lean
-- Instead of: ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ)
-- Use: snce_separable chi_a chi_b (all_separable chi_a) (all_separable chi_b)
```

This eliminates `sorryAx` from `lean_verify all_formulas_separable` by routing through the existing `snce_separable` axiom. No new axioms added. The 9 axioms in `SeparationThm.lean` remain, but the proof is honest (axiom invocation, not sorry).

**Benefit**: Immediate cleanup. `Hierarchy.lean` becomes sorry-free. `lean_verify` shows named axioms, not `sorryAx`.

### Path 2 — Correct Mathematical Fix: Faithful GHR94 Implementation [~300-500 LOC, 20-40 hours]

Restructure the proof to follow GHR94's acyclic lemma chain. This is the only path that eliminates the `snce_separable` axiom entirely:

1. **Prove GHR94 Lemma 10.2.4**: Generalize Cases 1-8 from atom to boolean formula arguments via DNF/CNF decomposition. Requires a `to_dnf`/`to_cnf` conversion for S-free + U-free formulas.

2. **Prove GHR94 Lemma 10.2.5**: Extend to arbitrary S-free arguments (formulas with no S but possibly containing U).

3. **Prove GHR94 Lemma 10.2.6**: Multi-U-type `no_S_nested_in_U` separability. Handle formulas with multiple `.untl` subformulas all having S-free arguments.

4. **Rewrite GHR94 Lemma 10.2.7**: Use `snce_depth_of_U` induction (already defined in codebase) instead of `count_U_subformulas`. At depth 0, formula has U-free `.snce` args → directly separated. At depth n+1, apply Lemma 10.2.6 to handle innermost S-nodes, reducing depth by 1.

5. **Simplify GHR94 Lemma 10.2.8** (`all_formulas_separable_aux`): Outer JD induction calls Lemma 10.2.7 (already proved) — no callback needed. JD=0 base case trivial. JD=1 (Lean) = GHR94 JD=2: reduce JD by replacing S-subformulas in U-args with atoms, apply Lemma 10.2.7, resubstitute. Output has JD ≤ n-1.

**Benefit**: Eliminates `snce_separable` and `untl_separable` axioms. Faithful to GHR94. Acyclic dependency chain.

### Path 3 — Alternative: Constructive `separate` Function [HIGH effort, STRONGEST result]

Build an explicit `separate : Formula → Formula` function with:
- `termination_by sizeOf phi` (structural decrease guaranteed by the abstract/substitute procedure)
- Lean's termination checker verifies directly
- Produces `is_syntactically_separated (separate phi)` and `int_equiv phi (separate phi)`

This avoids the existential formulation (`∃ ψ, ...`) that causes the callback circularity. A computable separation function is a stronger result (verified computationally).

**Benefit**: Strongest possible result. Avoids all circularity. Computationally verified.
**Risk**: Highest implementation effort. Requires significant restructuring.

### NOT Recommended

| Approach | Why Not |
|----------|---------|
| +1 JD definition change | Destroys `snce_of_boxfree_sep_jd_le_one`, breaks n ≥ 2 case. Counterproductive. |
| Lexicographic (JD, count_U) | Identity roundtrip: count_U does not decrease in callbacks. |
| Fuel/gas parameter | Identity roundtrip consumes fuel without progress. Base case still needs `snce_separable`. |
| Automata-theoretic proof | 5000+ LOC for automata library. Enormous cost for the same result. |

---

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | Primary (JD redef + WF measures) | completed | Definitive refutation of +1 JD approach; confirmed identity roundtrip is fundamental | HIGH |
| B | Alternatives (callback avoidance + alt proofs) | completed | Confirmed Cases 1-8 barrier; found A,B have jd=0 at JD=1; confirmed sorry = snce_separable | HIGH |
| C | Critic | completed | Discovered GHR94 is NOT circular; identified sorry asserts FALSE; found `snce_depth_of_U` was never tried | HIGH |
| D | Horizons | completed | Strategic assessment (task 155 independent); lexicographic induction proposal; minimum-effort axiom routing | HIGH |

---

## References

### Primary Sources
- GHR94 Ch 10: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`
- Reynolds 1994: `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`

### Key Codebase Files
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` — Sorry sites (lines ~1773, ~1806)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` — JD definitions (lines 300-440)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` — Cases 1-5
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` — Cases 5-8
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` — 9 axioms
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` — abstract/substitute ops

### Prior Analysis
- `specs/157_expressive_completeness_su_integer/handoffs/jd1-circularity-analysis-20260519.md`
- `specs/157_expressive_completeness_su_integer/reports/13_jd1-gap-research-brief.md`
