# Phase 11.32 handoff — closed with exclusions; the filed agreement is REFUTED

- **Verdict**: `cellAt_const_of_kappa_eq` is FALSE as filed (`cellAt_const_of_kappa_eq_schema_refuted`),
  `ladderRealized` with it (`no_fibre_equation_over_kappa`). Fourth section of
  `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`. Zero `sorry`.
- **Mechanism**: the gap `n - c` is read past (K4)'s clip. `thetaC := ⊡ X ⊡ ¬ P ¬p`, clip `3`,
  separates gap `-3` from gap `≤ -4`. `mixC (k + 2) k`: clip `2 k + 5`, separated gap `3 k + 4`.
- **Immediate next action**: a route decision, then `/revise`. Do not enter Phase 11.30 on plan
  v21 as written: its premise ("the parameter axis is already spent") is contradicted, and
  `certStabK_fails_of_contains_realized` shows the soundness leg inherits the defect.
- **Not settled**: whether a larger clip (both families die at `2 * (dBack + dFwd) + 2`) makes the
  agreement true; the tight family (gaps inside every clip).
- **Do not**: edit the Challenge block; strengthen `ParamsOk` without a ruling; read the candidate
  clip as a theorem.
- **Gates at close**: full `lake build` green (2975 jobs, 0 errors); evidence gate PASS (63 wired);
  `check-module-invariants.sh` ALL CHECKS PASSED; `verify-deploy.sh` exit 0.
- **Sentinel**: `.plan-revised.json` `revised_at` predates this dispatch's start; no hit.
