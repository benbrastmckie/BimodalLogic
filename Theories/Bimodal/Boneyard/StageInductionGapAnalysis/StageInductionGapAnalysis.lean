/-!
# Stage Induction and Gap Analysis for IsSuccArchimedean (ARCHIVED)

Archived from `ChronicleToCountermodel.lean` (task 123, 2026-05-13).

These proof attempts for `IsSuccArchimedean` of the chronicle limit domain are
dead ends. The sorry at `succ_cofinal` represents a genuine limitation of the
Burgess chronicle construction under strict (irreflexive) temporal semantics:

- **Stage induction** (`succ_reaches_dom_N`): boundary cases intractable —
  `succ(max_N)` may enter the domain at an arbitrarily later stage.
- **Convergence** (`limit_dom_points_are_succ_iterates`): leads to the same
  gap scenario as `succ_cofinal`.
- **Z1/Doets gap elimination** (`succ_cofinal`): the constant-MCS case is
  consistent with all temporal axioms including Z1 and Prior-UZ. The "beyond
  the gap" problem prevents establishing FG(φ) at orbit points under strict
  semantics where G(φ)→φ is not valid.

Replacement: task 129 (weak/reflexive completeness + conservative extension)
provides IsSuccArchimedean via a Henkin canonical model.

This file does NOT compile — it is preserved for reference only.
-/

-- Original imports (from ChronicleToCountermodel.lean)
-- import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
-- etc.

/-! ## Stage Induction Approach (3 sorry sites: lines 1295, 1448, 1512) -/

-- [ARCHIVED CODE BELOW — extracted from ChronicleToCountermodel.lean lines 1134-1512]
-- See git history for the full code (commit before archival).
-- Key theorems:
--   succ_reaches_dom_N : stage induction with 2 boundary sorry sites
--   limit_dom_points_are_succ_iterates : convergence approach with 1 sorry site

/-! ## Convergence-Based Gap Analysis (1 sorry site: line 1883) -/

-- [ARCHIVED CODE BELOW — extracted from ChronicleToCountermodel.lean lines 1538-1884]
-- See git history for the full code (commit before archival).
-- Key theorem:
--   succ_cofinal : convergence proof with gap analysis, Z1 helpers, and sorry
--
-- The proof establishes:
--   - Monotone orbit s^[n](a) converging to L in ℝ
--   - orbit_below_L: all limit_dom points below L are orbit points
--   - h_lt_pred_chain: all orbit points below all pred-chain points
--   - backward_G, backward_F, backward_P: truth propagation lemmas
--   - z1_in_mcs: Z1 formula in every MCS (via Axiom.z1 constructor)
--
-- The sorry represents the gap elimination step where:
--   - Non-constant MCS: Z1 Doets argument blocked by "beyond the gap" problem
--   - Constant MCS: all axioms trivially satisfied, construction doesn't close gap
