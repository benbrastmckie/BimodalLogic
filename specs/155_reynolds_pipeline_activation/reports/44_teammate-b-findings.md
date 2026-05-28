# GHR93 Cases II-IV Ordering Proofs: Literature Extraction and Gap Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: What GHR93 says for Cases II, III, IV ordering proofs, and how the 6 sorry sites relate.

---

## 1. Sorry Site Inventory

CaseAnalysis.lean has exactly 6 sorry sites, all in `same_order_type` (ordering) proofs:

| # | Line | Location | Description |
|---|------|----------|-------------|
| 1 | 1668 | `ghr93_case_II`, Case A (b_sp <= c) | Grid dispatch: inner-index cases after `first` combinator |
| 2 | 1669 | `ghr93_case_II`, Case A | Unreachable companion sorry |
| 3 | 2031 | `ghr93_case_II`, Case B1 (c < b_sp <= e_n) | Grid dispatch: inner-index cases |
| 4 | 2032 | `ghr93_case_II`, Case B1 | Unreachable companion sorry |
| 5 | 2112 | `ghr93_case_II`, Case B2 (b_sp > e_n) | Full grid dispatch sorry (no `first` attempted) |
| 6 | 3355 | `ghr93_cases_III_IV` | Winning condition assembly (order + gp + form) |

**Key observation**: Sorries 1-5 are ALL in Case II's `same_order_type` proofs. Sorry 6 is the complete winning condition for Cases III/IV (ordering, gap/point, AND formula agreement all in one sorry).

---

## 2. Key Findings: GHR93 Proof Structure for Cases II-IV

### 2.1 Case II in GHR93 (pp. 117-118)

**Setup**: All selections a_0 < ... < a_n lie in (d-bar, y'), and a_n is a point (not a gap).

**GHR93's construction**:
1. Apply tau to a_0, ..., a_{n-1} to get e_0, ..., e_{n-1} in (c, b).
2. Define B = X_{a_n} (rank-r type formula), A = X_{(a_{n-1}, a_n)} (interval type formula).
3. Observe N_r |= U(B, A)(a_{n-1}).
4. Transfer U(B, A) through tau at rank r+4 to get M_r |= U(B, A)(e_{n-1}).
5. Extract witness z > e_{n-1} with B(z) and A on (e_{n-1}, z). Set e_n = z.
6. Round 2: 5-way case split on Spoiler's challenge point.

**GHR93's ordering argument**: GHR93 DOES NOT prove sel-vs-p_n ordering explicitly. It follows trivially because:
- Spoiler's choices are strictly ordered: a_k < a_n for all k < n.
- Duplicator's responses are strictly ordered: e_k < e_{n-1} < e_n (from tau + U(B,A) witness).
- The biconditional is True iff True.

### 2.2 Formalization Divergence: The e_n Construction

The formalization constructs e_n via a **d-compatible forward game** (line 1282-1288), NOT via the U(B,A) transfer from GHR93. This creates a fundamental structural problem:

- In GHR93: e_n is a U(B,A) witness above e_{n-1}, so e_{n-1} < e_n is immediate.
- In the formalization: resp_tau(k) and e_n come from DIFFERENT games. The tau backward game gives resp_tau, while the d-compatible forward game gives e_n. There is no direct ordering relationship between them.

The formalization compensates by using a "modified response" (`resp_mod`) that replaces resp_tau(k) with e_n when a_init(k) = p_n, and a `sel_pn_ord` helper (line 1430-1439). The `sel_pn_ord` is proved using `hord_left_sel_pn` from the tau_left sub-game.

### 2.3 Why the Grid Dispatch Fails

The `same_order_type_grid` tactic generates 16 goals from the 4x4 grid of categories: {x, sel(k), b_sp/b_resp, p_n/e_n, y} vs the same set. After `split_ifs`, the `first` combinator tries each alternative on each surviving goal.

The sorry sites at lines 1668 and 2031 arise because the `first` combinator's alternatives cannot handle certain **inner-index** goals where:
- Both i and j index selection positions (i.val - 1 < n AND j.val - 1 < n)
- OR one indexes a selection and the other indexes p_n/e_n

The technical blocker (documented in plan v43 Phase 3) is that after `split_ifs`, the Fin variables become inaccessible (`i_dagger`, `j_dagger`), and `rename_i` cannot handle variable-length inaccessible lists within `first` alternatives.

### 2.4 Cases III-IV in GHR93 (pp. 118-119)

**Case III**: a_n is a gap defined on the left by formula D of rank <= r.
- Construct delta_III = left(B, D) at rank r+2.
- N_r |= U(delta_III, A)(a_{n-1}).
- Transfer through tau at rank r+4 (depth ceiling: max(r+2, r) + 2 = r+4).
- Extract gap witness in M via Lemma 9.

**Case IV**: a_n is a gap NOT defined on the left.
- Must be definable on the right by some D of rank <= r.
- delta_IV = A AND NOT(D) AND U(right(B,D), A) at rank r+3.
- Transfer through tau at rank r+4.
- Extract gap witness in M via right_formula.

**The formalization's Cases III/IV status**: The gap detection transfer (finding gamma_M matching gamma_N with formula agreement) is COMPLETE and sorry-free. What remains sorry'd at line 3355 is the **winning condition assembly** -- constructing a'_resp, getting b_resp, and proving same_order_type + gap_point_agreement + formula_agreement for the full (n+1)-round game.

---

## 3. Detailed Analysis of Each Sorry Site

### 3.1 Sorries 1-2 (Lines 1668-1669): Case A Grid Dispatch

**Context**: Case A is b_sp <= c (Spoiler's Round 2 challenge is on sigma's side). The `first` combinator at lines 1581-1669 handles ~30 goal alternatives successfully, leaving approximately 8 goals.

**What the surviving goals require**: These are sel-vs-sel and sel-vs-boundary goals where the `first` alternatives do not match because:
1. The inner index variable (from split_ifs) refers to a selection position, requiring a `by_cases hlt : i.val - 1 < n` sub-split.
2. After this sub-split, the sel-vs-p_n ordering (`sel_pn_ord`) and sel-vs-sel ordering (`tau_sel_sel`) need to be applied, but the variables are inaccessible.

**What is mathematically needed**: For each surviving goal, the pattern is one of:
- `(a_bwd j < a_bwd i iff a'_resp j < a'_resp i)` where both are selection positions: use `tau_sel_sel` or `sel_pn_ord` depending on whether i or j equals n.
- `(a_bwd j < p_n iff a'_resp j < e_n)`: use `sel_pn_ord`.
- Cross-boundary orderings through d/c: use `pivot_chain_order'`.

**Fix approach**: Replace the `first` block with explicit case-splits on the inner index variables. For each of the ~8 remaining goals after the `first` block catches easy cases, introduce:
```lean
| (by_cases hlt_i : (i✝ : Fin _).val - 1 < n <;> by_cases hlt_j : (j✝ : Fin _).val - 1 < n <;> ...)
```
OR restructure the proof to avoid `same_order_type_grid` entirely and instead do manual `intro i j; by_cases` before unfolding `game_tuple`.

### 3.2 Sorries 3-4 (Lines 2031-2032): Case B1 Grid Dispatch

**Context**: Case B1 is c < b_sp <= e_n. The structure mirrors Case A exactly. The same 8-ish goals survive after the `first` block.

**What is mathematically needed**: Same as Case A -- sel-vs-sel and sel-vs-p_n orderings. The available lemmas are identical: `tau_sel_sel`, `sel_pn_ord`, `pn_sel_ord`, `tau_sel_y`, `hord_fwd_x_en`, `hord_fwd_en_y`.

**Fix approach**: Same as 3.1.

### 3.3 Sorry 5 (Line 2112): Case B2 Grid Dispatch

**Context**: Case B2 is b_sp > e_n. Here, NO `first` block was attempted -- the entire `same_order_type` proof is sorry'd.

**What is mathematically needed**: The full 16-goal grid. The available data is:
- tau_left ordering for selections (resp_left / a_init)
- tau_right ordering for b_resp (from tau_right at [p_n, y'] / [e_n, y])
- Forward game orderings for x/y and e_n/p_n boundaries
- sel_pn_ord for selection-vs-p_n
- pn_sel_ord for p_n-vs-selection

The key new element vs Cases A/B1: b_resp comes from `tau_right` (the sub-game on [p_n, y'] / [e_n, y]) rather than sigma or tau_left. The orderings b_resp vs other positions must be derived from tau_right's winning condition.

**Fix approach**: Write the full grid dispatch for Case B2 following the same pattern as Cases A/B1 but using `hord_right_b` for b_resp orderings. This is the largest of the Case II sorries (~100-150 lines).

### 3.4 Sorry 6 (Line 3355): Cases III/IV Winning Condition Assembly

**Context**: The gap detection transfer is complete. gamma_M has been found with formula agreement. The response function a'_resp has been constructed (resp_tau for positions 0..n-1, Sum.inr gamma_M for position n). What remains is the full winning condition for the point challenge.

**What is mathematically needed**:
1. **Get b_resp**: Use the d-compatible forward game to get b_resp with cross-boundary orderings between c/d and b_sp/b_resp.
2. **same_order_type**: Prove the full (n+1+3)-position ordering grid. The grid has the same structure as Case II but with Sum.inr gamma_M at position n instead of extendPoint e_n_pt.
3. **gap_point_agreement**: For each position, prove the gap/point iff. Selections use tau's data; position n uses the gap iff from gamma_M/gamma_N; endpoints use forward game data.
4. **formula_agreement**: For each position and formula A with depth <= r, prove the truth iff. Selections use tau's data; position n uses gamma_M_form; endpoints use forward game data.

**GHR93's argument**: The paper says the Round 2 verification "mirrors Case II structure" -- the case split on Spoiler's challenge point is the same 5-way split (below c, between e_k and e_{k+1}, between e_{n-1} and e_n, at e_n, above e_n), with the gap e_n replacing the point e_n from Case II.

**Fix approach**: This requires ~200 lines mirroring the Case II assembly pattern. The components:
- Get b_resp via d-compatible forward game (same pattern as Case II).
- same_order_type: same grid dispatch pattern as Case II with `Sum.inr gamma_M` at position n. The ordering between gamma_M and other positions follows from interval membership (gamma_M in [x, y], resp_tau(k) in [c, y], d <= a_init(k), gamma_M above m_M, etc.).
- gap_point_agreement: gamma_M is a gap, gamma_N is a gap, so IsGap iff is trivially true. IsPoint iff is trivially false at position n.
- formula_agreement: gamma_M_form provides the agreement at position n.

---

## 4. Recommended Approach

### 4.1 For Case II Sorries (1-5): Restructure the Grid Proof

**Option A (recommended): Manual intro + by_cases before split_ifs**

Replace `same_order_type_grid <;> first | ... | sorry` with a structured proof that handles index categories explicitly:

```lean
intro i j
-- Classify i
rcases (decide (i.val = 0), decide (i.val = n + 2), decide (i.val = n + 3)) with ...
-- For each i-category, classify j similarly
-- Apply the appropriate lemma
```

This avoids the inaccessible variable problem entirely because variables are named before `split_ifs`.

**Option B: Custom tactic**

Write a `grid_inner_dispatch` tactic in EFGameTactics.lean that introspects the goal to find Fin variables by type, performs `by_cases` on `.val - 1 < n`, and applies ordering lemmas. Estimated ~100-150 lines of tactic code.

**Option C: Factor out the inner-index sub-proof**

Extract a helper lemma that proves the sel-vs-sel ordering given `tau_sel_sel`, `sel_pn_ord`, and `pn_sel_ord`:

```lean
private theorem case_II_sel_sel_ord (k k' : Fin n)
    (tau_sel_sel : (a_init k < a_init k' iff resp_mod k < resp_mod k') ...)
    (sel_pn_ord : ...)
    (pn_sel_ord : ...) :
    (a_bwd ⟨k.val, ...⟩ < a_bwd ⟨k'.val, ...⟩ iff a'_resp ⟨k.val, ...⟩ < a'_resp ⟨k'.val, ...⟩) ...
```

Then use this helper in the `first` block.

### 4.2 For Sorry 6 (Cases III/IV): Follow Case II Template

The winning condition assembly for Cases III/IV follows the SAME pattern as Case II. The key differences:

1. Position n has `Sum.inr gamma_M` (a gap) instead of `extendPoint e_n_pt` (a point). This means:
   - gap_point_agreement at position n is trivial (both gaps).
   - formula_agreement at position n comes from `gamma_M_form`.
   - Ordering at position n uses interval membership rather than forward game data.

2. The b_resp acquisition is the same: use the d-compatible forward game.

3. The grid dispatch uses the same pivot-chain pattern through d/c for cross-boundary orderings.

**Estimated effort**:
- Case II sorries: 100-200 lines (restructuring existing grid proofs)
- Cases III/IV sorry: 200-300 lines (new winning condition assembly)

### 4.3 Priority Order

1. **Fix Case B2 (sorry 5)**: This is the most isolated sorry -- a full grid dispatch with no `first` block attempted. Writing this from scratch using the pattern of Case I's grid dispatch (which is sorry-free) would validate the approach.

2. **Fix Cases A/B1 (sorries 1-4)**: These require restructuring the existing `first` blocks to handle the remaining inner-index goals. The same fix applies to both.

3. **Fix Cases III/IV (sorry 6)**: This is the largest task but follows the well-established Case II template.

---

## 5. Evidence: Specific GHR93 References

### 5.1 Case II Ordering

GHR93 p. 117: "Let her first use tau in response to alpha_0, ..., alpha_{n-1}. It delivers n points e_0, ..., e_{n-1} in (c, b)_r."

The ordering e_0 < ... < e_{n-1} follows from tau's winning condition (same order type preservation). e_n > e_{n-1} follows from e_n being a U(B,A) witness.

GHR94 ch. 12 p. 29: "cf Lemma 12.8.12" confirms ordering from winning condition.

### 5.2 Case III-IV Gap Detection

GHR93 Definition 8.5: left(A, D) and right(A, D) definitions by structural induction.
GHR93 Lemma 9: Correctness of left/right (gap detection equivalence).
GHR93 pp. 118-119: Cases III/IV proof using left(B,D) and right(B,D).
GHR94 ch. 12, pp. 812-850: Expanded treatment.

### 5.3 Rank Arithmetic

- Case II: U(B, A) has rank r+1 (max(r, r) + 1 in GHR93 convention = max(r, r) + 2 in stavi_depth convention... but the formalization uses sf_untl_depth = max(depth B, depth A) + 2, giving r+2). Since r+2 <= r+4, transfer through tau works.
- Case III: left(B, D) has depth <= max(r, r) + 4 = r+4. U(left(B,D), A) has depth max(r+4, r) + 2 = r+6... This EXCEEDS r+4.

**CORRECTION**: The formalization avoids this issue because it does NOT use U(left(B,D), A) for the transfer. Instead, it transfers left_formula(A, D) directly at the reference point m_N, which has depth <= r+4. The transfer is point-to-point (m_N to m_M), not via an Until formula. This is a key architectural difference from GHR93 that avoids the rank ceiling problem.

---

## 6. Confidence Level

**High confidence** on:
- The characterization of all 6 sorry sites
- The root cause of the grid dispatch failure (inaccessible variables after split_ifs)
- The mathematical content needed for each sorry (ordering lemmas are available)
- The Case II sorry pattern being amenable to restructuring

**Medium confidence** on:
- The estimated line counts (could be 50% more in practice)
- Option A being the cleanest fix (Option B/C may be needed for maintainability)
- Cases III/IV assembly being a straightforward mirror of Case II (edge cases with degenerate intervals may add complexity)

**Low confidence** on:
- Whether the grid dispatch fix can be done without touching the `same_order_type_grid` tactic itself
- Whether Case B2 (sorry 5) has all needed ordering lemmas pre-extracted (some may need additional `hord_right_b` extractions)
