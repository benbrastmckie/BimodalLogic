# Phase 6 Handoff v5: CaseAnalysis.lean Sorry Decomposition

**Date**: 2026-05-28
**Session**: sess_1780001766_2e723d
**Status**: PARTIAL (1 original sorry decomposed into 7 sub-sorries, all building cleanly)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

## What Was Done This Session

The sorry at line 3359 (non-degenerate case of `ghr93_cases_III_IV`) was decomposed into a structured skeleton with individual sorries for each sub-problem. The code builds cleanly with all sorries in place.

### Infrastructure Established (lines 3359-3383)

1. **Full-interval 0-round forward game** (lines 3360-3373): Extracted y/y' gap/point agreement, formula agreement, and x<y <-> x'<y' orderings from `props.h_fwd_n1`.

2. **`hgamma_eq_endpoint`** (line 3375-3376, SORRY): Lemma `Sum.inr gamma_N = y' -> Sum.inr gamma_M = y`. This is the CRITICAL infrastructure lemma.

3. **`h_pt_upper_of_lt`** (line 3378-3379, SORRY): Lemma `gamma_N < y' -> exists carrier point in [gamma_N, y']`. Standard isPoint_or_isGap argument (template at lines 3452-3469 in case neg).

4. **`hgamma_lt_of_lt`** (line 3381-3382, SORRY): Lemma `gamma_N < y' -> gamma_M < y`. Uses 0-round upper forward game.

5. **Case split on `b_sp <= gamma_M`** (line 3384):
   - **Case A** (b_sp <= gamma_M, line 3386-3406): Sub-game approach. Three sub-sorries for same_order_type, gap_point_agreement, formula_agreement.
   - **Case B** (b_sp > gamma_M, line 3407-3416): Fresh upper sub-game. One sorry.

### Key Type Issue: `<` on ExtendedCarrier

The `LT` instance for `ExtendedCarrier` comes from `extendedLinearOrder` (noncomputable). Lean fails to synthesize `LT` when using `(Sum.inr g : ExtendedCarrier M atomMap r) < y`. The fix is to use `@LT.lt (ExtendedCarrier M atomMap r) _ (Sum.inr g) y` explicitly.

## Remaining Sorries (7 total in the sorry region)

### 1. `hgamma_eq_endpoint` (line 3376) — HARD

**Goal**: `Sum.inr gamma_N = y' -> Sum.inr gamma_M = y`

**Difficulty**: This is the hardest remaining lemma. The analysis revealed:

- In the RIGHT gap detection case (`gap_definable_on_right`), when `y' = gamma_N`, the code at lines 2802-2834 already produces `gamma_M` with `Sum.inr gamma_M = y`. This is guaranteed by the tau game's gap/point agreement at y <-> y'.

- In the LEFT gap detection case (`gap_definable_on_left`), the situation is different. The gap detection finds `gamma_M` via the left_formula transfer, which gives `gamma_M < y` (strict, since m_M > gamma_M and m_M <= y).

- **Resolution**: Either (a) show LEFT case with gamma_N = y' is impossible in `case pos`, or (b) prove gamma_M = y for LEFT case via structural argument.

- **Possible approach (a)**: In the LEFT case, m_N is a cut element with m_N < gamma_N. If gamma_N = y': m_N < y'. And m_M is found in [x, y] with m_M > gamma_M. If y is also a gap (from hgp_yy'), y = Sum.inr g_y. Then m_M < g_y (since m_M is a carrier point <= y = Sum.inr g_y). The left_formula conditions applied to g_y might force g_y = gamma_M via gap_detection_unique_left.

- **Possible approach (b)**: Use hD_def to case-split on LEFT/RIGHT at the sorry site, handle each case separately.

### 2. `h_pt_upper_of_lt` (line 3379) — EASY

**Goal**: `gamma_N < y' -> exists carrier point in [gamma_N, y']`

**Approach**: Copy the isPoint_or_isGap argument from the case neg branch (lines 3452-3469). Use `rcases isPoint_or_isGap y'`. If point: use it directly. If gap: find carrier between gamma_N and the gap using Set.not_subset.

**Complication**: Must use `@LT.lt` notation for `<` comparisons, not type ascription.

### 3. `hgamma_lt_of_lt` (line 3382) — MEDIUM

**Goal**: `gamma_N < y' -> gamma_M < y`

**Approach**: Construct 0-round forward game on [gamma_M, y] x [gamma_N, y'] using `h_r1_univ r`. Challenge with carrier point from `h_pt_upper_of_lt`. Extract ordering gamma_M vs y <-> gamma_N vs y'. Since gamma_N < y': gamma_M < y.

### 4-6. Case A winning condition (lines 3402, 3404, 3406) — LARGE BUT MECHANICAL

**Goal**: same_order_type, gap_point_agreement, formula_agreement for the (n+1)-game.

**Approach**: Follow the degenerate case template (lines 3462-3543). Key orderings:
- Positions k < n: from sub-game `hord_sub`, `hgp_sub`, `hform_sub`
- Position n (gap): from `hgamma_M_form`, `hgamma_gp`, `hord_xgamma`/`hord_bgamma` from sub-game
- Endpoint y/y': from `hgp_yy'`, `hform_yy'`, and pivot orderings
- b_resp vs y': always true (carrier point < gap <= y')
- b_sp vs y: always true (carrier point < gap <= y)

**Key detail**: The y' = a_bwd(k) <-> y = a'_resp(k) ordering for k < n requires hgamma_eq_endpoint (when a_init(k) = gamma_N). For k = n: uses hgamma_eq_endpoint directly.

**Fin coercion**: When intro-ing `Fin (n+1)` and branching on `k < n`, use `Fin.ext (by omega)` for k = n equalities. Avoid destructuring Fin as `(k, hk_bound)` — use pattern matching or work with the Fin value directly.

### 7. Case B (line 3416) — LARGE

**Goal**: Handle b_sp > gamma_M using fresh upper sub-game.

**Available data**:
- `hgamma_N_lt_y'`: gamma_N < y' (derived from Case B + hgamma_eq_endpoint)
- `hgamma_M_lt_y`: gamma_M < y (derived from b_sp > gamma_M)
- `h_fwd_upper`: Forward game on [gamma_M, y] x [gamma_N, y']
- `h_pt_upper_of_lt hgamma_N_lt_y'`: Carrier point in [gamma_N, y']

**Approach**:
1. Apply IH to h_fwd_upper with carrier point to get tau_upper: backward game on [gamma_N, y'] -> [gamma_M, y]
2. Play tau_upper with a_init (all in [gamma_N, y']) to get resp_upper in [gamma_M, y]
3. Challenge with b_sp (in [gamma_M, y]) to get b_resp_upper in [gamma_N, y']
4. Assemble winning condition combining sub-game orderings (positions 0..n-1) with upper game orderings (b, y positions)

**Assembly pattern**: The orderings combine lower sub-game (x/x' to gamma) with upper game (gamma to y/y'). Position n (gap) acts as pivot.

## Critical Observation: ExtendedCarrier LT Instance

Throughout the proof, `<` on `ExtendedCarrier` must be written as `@LT.lt (ExtendedCarrier M atomMap r) _` to avoid "failed to synthesize instance of type class" errors. The linear order instance `extendedLinearOrder` is noncomputable and Lean's instance search doesn't find it from `(Sum.inr g : ExtendedCarrier M atomMap r) < y` syntax.

## File State

- Lines modified: 3359-3416 (was 1 sorry, now 7 sorries + infrastructure)
- Build: CLEAN (all sorries accepted)
- Commit: `a0301b777` "task 155 phase 6: scaffold non-degenerate sorry"

## Recommended Next Steps

1. Fill `h_pt_upper_of_lt` and `hgamma_lt_of_lt` (straightforward)
2. Fill `hgamma_eq_endpoint` (requires gap detection analysis — case split on hD_def)
3. Fill Case A winning condition (mechanical but verbose — ~100 lines)
4. Fill Case B (needs upper game construction + assembly — ~100 lines)

## What NOT to Try

1. Do NOT use type ascription `(Sum.inr g : ExtendedCarrier M atomMap r)` before `<` — use `@LT.lt` explicitly
2. Do NOT try to prove gamma_M = y from formula agreement alone — gaps can share rank-r formulas
3. Do NOT destructure `Fin (n+1)` as `(k, hk_bound)` for selection orderings — work with Fin values
