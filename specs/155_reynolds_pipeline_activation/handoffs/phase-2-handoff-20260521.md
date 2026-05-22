# Phase 2 Handoff: Lemma 9 Gap Detection Correctness

## Current State

Phase 2 is IN PROGRESS. 2 of 11 sorry sites closed in `left_formula_gap_detection`.

### Completed
- **base.imp** (was line 2759): Uses `gap_detection_unique` to show the unique D-defined gap satisfies `(f -> g)^mu`. Pattern: extract gap from `U'(top,D)`, use IH for f and g separately, apply gap uniqueness.
- **base.untl** (was line 2763): Uses `stavi_untl_gap_detection` to rewrite LHS, then bridges complement-point truth of `g AND U(f,g)` to `U(f,g)^mu` at gap. Key tool: `temporal_truth_mu_at_point` for converting between mu and standard truth at actual points.

### Remaining Sorry Sites (9 of 11)
1. **std_untl_gap_detection** (line 2682): Full theorem, ~120-160 lines. Analogous to stavi_untl_gap_detection but for standard Until.
2. **base.snce** (line 2899): Depends on std_untl_gap_detection (uses `std_untl compound D` pattern).
3. **stavi_untl backward** (line 3164): Needs FO-table shift lemma (~80-120 lines).
4. **stavi_snce case** (line 3168): Needs stavi_snce_gap_detection.
5. **std_untl backward** (line 3215): Similar to stavi_untl backward.
6. **std_snce case** (line 3219): Needs std_snce_gap_detection.
7. **stavi_snce_gap_detection** (line 3241): Dual of stavi_untl_gap_detection (~100-140 lines).
8. **std_snce_gap_detection** (line 3256): Dual of std_untl_gap_detection.
9. **right_formula_gap_detection** (line 3269): Dual of left_formula_gap_detection (~200-300 lines).

### Key Proof Pattern (Established)
For base cases in left_formula_gap_detection:
1. Unfold `left_formula_base` to reveal the StaviFormula structure
2. Apply the appropriate gap_detection helper (stavi_untl_gap_detection for untl, std_untl_gap_detection for snce)
3. Bridge between complement-point truth and mu-relativized truth at the gap using `temporal_truth_mu_at_point`
4. For compound cases (imp, neg, conj), use `gap_detection_unique` to ensure all sub-formulas evaluate at the SAME gap

### Technical Notes
- Gap ordering: `Sum.inr gamma < extendPoint u` requires `@LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr gamma) (extendPoint u)` for explicit type class resolution. Plain `show u notin cut AND NOT (u in cut)` pattern works inside `refine` goals but fails as term-mode `have` bindings.
- The `extendedLinearOrder` instance is noncomputable; direct `lt_of_not_le` may fail on type class synthesis. Use explicit `@LT.lt ... extendedLinearOrder.toLT` annotation.

### Next Steps
1. Prove std_untl_gap_detection (unblocks base.snce)
2. Prove stavi_snce_gap_detection (dual of stavi_untl_gap_detection)
3. Close backward directions (need FO-table shift lemma)

## Phase 1 Status
BLOCKED. See plan file for detailed blocker documentation.
