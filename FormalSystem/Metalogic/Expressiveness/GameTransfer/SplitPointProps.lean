/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.GameTransfer.DConsistencyTransport

/-!
# Split-Point Properties

The `SplitPointProps` structure: the bundle of facts about a split point that the inductive step
of GHR93 Theorem 6 consumes. It is stated here, apart from its construction, so that
`GameTransfer/CaseAnalysis.lean`, which only uses the structure's fields, does not depend on the
long proof that builds it. The construction is `obtain_split_point_props` in
`GameTransfer/SplitPoint.lean`.
-/

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax

/-! ## GHR93 Theorem 6: Inductive Step Infrastructure

The inductive step of Theorem 6 converts a forward (4+3n)-round strategy
into a backward (n+1)-round strategy. The proof introduces key quantities
from the GHR93 argument:

- **d**: A "split point" in N_r that separates the interval [x',y'] based on
  where the forward strategy's type pattern changes. Formally, d is defined
  using the interval type A = X_{(a_{n-1}, a_n)} and a continuation formula C.

- **c**: The corresponding split point in M_r, obtained by applying the
  forward strategy to d.

- **σ, τ**: Backward strategies on sub-intervals [x',d]/[x,c] and
  [d,y']/[c,y], obtained by restricting the master forward strategy and
  applying the inductive hypothesis (*)_n.

The proof then splits into four cases based on the nature of a_n (Spoiler's
last selection in the backward game). -/

/-- Properties of the split points c, d that are needed for the case analysis.

    **GHR93 rank structure**: The `delta` parameter captures the rank offset
    between the backward game's rank `r` and the rank at which sigma/tau play.
    In GHR93, the induction peels off 4 from the rank at each step, so sigma/tau
    end up at rank `r + delta` (with delta = 4 in the inductive step). Positions
    c, d, x, y, x', y' live at rank `r`, and sigma/tau play on rank-embedded
    positions via `rankEmbed (by omega : r ≤ r + delta)`.

    When `delta = 0`, this reduces to the original structure (sigma/tau at rank r). -/
structure SplitPointProps {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (n : Nat) (delta : Nat)
    (x y : ExtendedCarrier M atomMap r)
    (x' y' : ExtendedCarrier N atomMap r)
    (c : ExtendedCarrier M atomMap r)
    (d : ExtendedCarrier N atomMap r)
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r) where
  /-- c is in [x, y] -/
  hc_interval : inClosedInterval x y c
  /-- d is in [x', y'] -/
  hd_interval : inClosedInterval x' y' d
  /-- The split point d is ≤ a_n (Spoiler's last backward pick).
      When d = infimum of ContinuationSet (GHR93 d̄), this holds because
      a_bwd(n) ∈ ContinuationSet and the infimum ≤ every member.
      Case I uses ≤ only. Case II is restructured to work without =. -/
  hd_le_an : d ≤ a_bwd ⟨n, by omega⟩
  /-- x ≤ c (for sub-interval well-formedness) -/
  hxc : x ≤ c
  /-- c ≤ y (for sub-interval well-formedness) -/
  hcy : c ≤ y
  /-- x' ≤ d (for sub-interval well-formedness) -/
  hx'd : x' ≤ d
  /-- d ≤ y' (for sub-interval well-formedness) -/
  hdy' : d ≤ y'
  /-- There exists an actual M-point in [x, c], or x = c (and x' = d) with c a gap.
      Degenerate case: GHR93 allows the sub-interval to be a single gap point.
      The x' = d condition ensures the N-side sub-interval is also degenerate. -/
  h_pt_xc : (∃ (p : M.carrier), inClosedInterval x c (extendPoint p)) ∨
             (x = c ∧ x' = d ∧ IsGap c ∧ IsGap d)
  /-- There exists an actual M-point in [c, y], or c = y (and d = y') with c a gap.
      Degenerate case: GHR93 allows the sub-interval to be a single gap point.
      The d = y' condition ensures the N-side sub-interval is also degenerate. -/
  h_pt_cy : (∃ (p : M.carrier), inClosedInterval c y (extendPoint p)) ∨
             (c = y ∧ d = y' ∧ IsGap c ∧ IsGap d)
  /-- Formula agreement between c and d at rank r.
      Used in degenerate gap cases (GHR93 implicit: game on [d,d] vs [c,c]). -/
  hcd_form : ∀ (A : StaviFormula), staviDepth A ≤ r →
      (StaviTemporalTruthMu M atomMap r c A ↔
       StaviTemporalTruthMu N atomMap r d A)
  /-- Gap/point correspondence between c and d.
      Used in degenerate gap cases and Case II point derivation. -/
  hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d)
  /-- Backward strategy σ on the left sub-interval at rank r + delta:
      Duplicator wins G_{n; r+delta}(N, x'd; M, xc) on rank-embedded positions.
      GHR93: sigma lives at rank r+4 (delta=4) from the IH applied at base rank r+4. -/
  sigma : Ghr93DuplicatorWins N M atomMap n (r + delta)
    (rankEmbed (by omega : r ≤ r + delta) x')
    (rankEmbed (by omega : r ≤ r + delta) d)
    (rankEmbed (by omega : r ≤ r + delta) x)
    (rankEmbed (by omega : r ≤ r + delta) c)
  /-- Backward strategy τ on the right sub-interval at rank r + delta:
      Duplicator wins G_{n; r+delta}(N, dy'; M, cy) on rank-embedded positions.
      GHR93: tau lives at rank r+4 (delta=4) from the IH applied at base rank r+4. -/
  tau : Ghr93DuplicatorWins N M atomMap n (r + delta)
    (rankEmbed (by omega : r ≤ r + delta) d)
    (rankEmbed (by omega : r ≤ r + delta) y')
    (rankEmbed (by omega : r ≤ r + delta) c)
    (rankEmbed (by omega : r ≤ r + delta) y)
  /-- (n+1)-round forward strategy on the full interval.
      Derived from the (4+3n)-round forward strategy via round_mono.
      Used in Case II to construct e_n and establish ordering compatibility. -/
  h_fwd_n1 : Ghr93DuplicatorWins M N atomMap (n + 1) r x y x' y'
  /-- D-compatible (1+3n+1)-round forward strategy: for any selection ending
      with c, there exists a response ending with d and satisfying the winning
      condition. Used in Case II to derive cross-boundary orderings between
      d/c and p_n/e_n. -/
  h_d_compat_left :
    ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨1 + 3 * n, by omega⟩ = c →
      ∃ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) ∧
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            Ghr93WinningCondition (1 + 3 * n + 1)
              (gameTuple x y a_pad b) (gameTuple x' y' a'_full b')) ∧
        a'_full ⟨1 + 3 * n, by omega⟩ = d

end FormalSystem.Metalogic.Expressiveness
