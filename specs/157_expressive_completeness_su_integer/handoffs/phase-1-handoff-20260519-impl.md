# Phase 1 Handoff: Measure Infrastructure Complete

## What was done
- Added `count_U_total` to Defs.lean (counts ALL `.untl` nodes at all depths)
- Added `count_U_total_zero_iff_U_free` to Defs.lean
- Added to Hierarchy.lean:
  - `abstract_untl_count_total_le` and `abstract_untl_count_total_lt_of_contains_deep`
  - `contains_untl_deep` predicate and `contains_untl_surface_implies_deep`
  - `s_free_implies_no_S_nested`
  - `extract_innermost_U_type` with companion lemmas:
    - `extract_innermost_U_type_S_free`
    - `extract_innermost_U_type_U_free` (KEY: gives U-free args at any depth)
    - `extract_innermost_U_type_contains_deep`

## Next action
Phase 2: Create oracle-free `no_S_nested_sep` theorem using double strong induction on `(UND, count_U_total)`.

## Key decisions
- `extract_innermost_U_type` recurses into `.untl` children using `s_free_implies_no_S_nested` to establish `no_S_nested_in_U` for the S-free arguments.
- `count_U_total` rather than `count_U_subformulas` is the right measure for innermost-U abstraction since it counts through `.untl` nesting.

## Build status
`lake build` succeeds with zero errors.
