# Research Report: Tactic Solutions for same_order_type_grid and maxErrors

## Summary

The sorry sites at lines 1594 and 1866 in CaseAnalysis.lean are caused by a small number of residual grid cases (3 and ~8 respectively) that fall through the `first | ... | sorry` chain. The sorry at line 1919 is inside a block comment and is not live. The root cause is a combination of Fin index mismatches and anonymous hypothesis issues from `split_ifs`. The recommended solution replaces the `same_order_type_grid <;> first | ... | sorry` pattern with structured focused proofs using bullet notation and named `split_ifs with` hypotheses.

## Problem Analysis

### What same_order_type_grid Currently Does

**Definition** (EFGameTactics.lean, line 202):
```lean
macro "same_order_type_grid" : tactic =>
  `(tactic| (intro i j; simp only [game_tuple]; split_ifs))
```

It introduces index variables `i` and `j`, unfolds `game_tuple`, and performs `split_ifs` on the index conditions. For an (n+1)-element game tuple with positions {x=0, b=n+1, y=n+2, sel(0..n-1), p_n=n}, this produces a 5x5 grid of 25 goals (with sel further split by `k < n` vs `k = n`).

The `split_ifs` without `with` clause produces inaccessible hypothesis names (`h✝`, `h✝¹`, etc.), preventing targeted use in subsequent tactics.

### Sorry Site at Line 1594 (Case II-A Sigma)

**Location**: `ghr93_case_II`, Case A (b_sp <= c branch), same_order_type proof.

**Goals remaining** (3 goals):
1. `(y' < a_bwd ⟨j-1, _⟩ ↔ y < resp_tau ⟨j-1, _⟩) ∧ ...` — y' vs sel(j-1), with `i = n+1+2` (y), `j-1 < n`
2. `(a_bwd ⟨i-1, _⟩ < a_bwd ⟨j-1, _⟩ ↔ resp_tau ⟨i-1, _⟩ < e_n) ∧ ...` — sel(i-1) vs p_n, with `i-1 < n`, `¬(j-1 < n)`
3. `(extendPoint p_n < a_bwd ⟨j-1, _⟩ ↔ e_n < resp_tau ⟨j-1, _⟩) ∧ ...` — p_n vs sel(j-1), with `¬(i-1 < n)`, `j-1 < n`

**Root cause**: The `a_bwd ⟨j-1, _⟩` in the goal refers to `a_bwd` with a Fin bound proof `⟨j.val - 1, sorry_proof⟩` where the proof term differs from the Fin bound in `a_init ⟨j-1, h_j_lt_n⟩`. The `convert ... using 3 <;> congr 1 <;> Fin.ext (by omega)` pattern should work but the surrounding `first | ...` chain's anonymous hypotheses prevent `⟨_, ‹_›⟩` from finding the right hypothesis to construct the Fin value.

### Sorry Site at Line 1866 (Case II-B Tau)

**Location**: `ghr93_case_II`, Case B (c < b_sp branch), same_order_type proof.

**Goals remaining** (~8 goals, similar patterns):
- b_resp vs p_n, y' vs b_resp, y' vs sel(j-1), y' vs p_n, p_n vs x', p_n vs b_resp, sel(i-1) vs p_n, p_n vs sel(j-1)

**Root cause**: Same as line 1594 — anonymous hypotheses and Fin index mismatches.

### Sorry Site at Line 1919 (Dead Code)

**NOT LIVE**: This sorry is inside a block comment (`/- ... -/`) starting at line 1867. The `lean_goal` tool confirms no goals exist at this position. This is preserved reference code from an earlier proof attempt.

### maxErrors Issue

When `first | tac1 | tac2 | ... | tacN` fails on a goal, each alternative generates an error message before the `sorry` fallback catches it. With ~25 grid goals × ~40 alternatives, this can produce 1000+ error messages, exceeding Lean's default `maxErrors = 100` and aborting compilation.

## Solution Analysis

### Approach 1: Structured Proof with Named Hypotheses (RECOMMENDED)

Replace `same_order_type_grid <;> first | ... | sorry` with the pattern used in Case I (lines 478-650):

```lean
intro i j; simp only [game_tuple]; split_ifs with
  hi0 hj0 _ _ _ hjb _ hjy _ hjd hjlt
  -- ... (carefully enumerate all hypothesis names)
```

Then handle each of the 16-25 goals individually with `·` bullets and local `split_ifs with` for the sel/p_n sub-cases.

**Advantages**:
- Named hypotheses enable targeted rewrites (`rw [hab_eq _ (by omega) (by omega)]`)
- No `first | ...` combinator, so no error multiplication
- Each goal is self-contained and debuggable
- Matches the working pattern from Case I and the dead-code reference (lines 1924-2021)
- No maxErrors issue since each branch either succeeds or fails clearly

**Disadvantages**:
- More verbose (Case I's structured proof is ~180 lines for 16 goals)
- Need to carefully count and name the `split_ifs` hypotheses

**Implementation pattern** for sel vs p_n goals:
```lean
-- sel(i) vs sel(j) — inner split on i-1<n and j-1<n
· split_ifs with hin hjn
  -- both i-1<n and j-1<n: direct tau_sel_sel
  · exact tau_sel_sel ⟨_, hin⟩ ⟨_, hjn⟩
  -- i-1<n but ¬(j-1<n), so j-1=n, a_bwd(j-1)=p_n
  · rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
      by congr 1; exact Fin.ext (by omega), hab_n]
    exact pivot_chain_order' (hd_le_sel ⟨_, hin⟩) hd_le_pn
      (hc_le_rtau ⟨_, hin⟩) hc_le_en (tau_d_sel ⟨_, hin⟩) hord_cd_en_pn
  -- ¬(i-1<n) but j-1<n: reverse
  · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
      by congr 1; exact Fin.ext (by omega), hab_n]
    exact pivot_chain_order_rev' hd_le_pn (hd_le_sel ⟨_, hjn⟩)
      hc_le_en (hc_le_rtau ⟨_, hjn⟩) hord_cd_en_pn (tau_d_sel ⟨_, hjn⟩)
  -- both ¬(i-1<n) and ¬(j-1<n): both = p_n, order_refl
  · rw [show a_bwd ⟨i.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
      by congr 1; exact Fin.ext (by omega),
      show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
      by congr 1; exact Fin.ext (by omega)]
    order_refl
```

### Approach 2: set_option maxErrors + Fix Remaining Alternatives

Add `set_option maxErrors 500` before the proof and add missing alternatives to the `first | ...` chain.

```lean
set_option maxErrors 500 in
-- ... (existing proof)
        same_order_type_grid <;>
          (try rw [hab_eq _ _ (by assumption)]) <;>
          (try rw [hab_eq _ _ (by assumption)]) <;>
          first
          | order_refl
          | ... (existing alternatives)
          -- NEW: additional alternatives for the failing cases
          | (convert ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, (tau_sel_y ⟨_, ‹_›⟩).2.symm⟩ using 3
             <;> (congr 1; exact Fin.ext rfl))
          | sorry
```

**Advantages**:
- Minimal code change
- Doesn't require counting hypothesis names

**Disadvantages**:
- Still uses anonymous hypotheses, fragile to Lean version changes
- `‹_›` may not find the right hypothesis in all Fin configurations
- maxErrors=500 is a workaround, not a fix — increases build time
- Doesn't solve the fundamental naming problem

### Approach 3: Refactored same_order_type_grid_with Macro

Create a variant macro that names hypotheses:

```lean
macro "same_order_type_grid_named" : tactic =>
  `(tactic| (intro i j; simp only [game_tuple]; split_ifs with
    hi0 hj0 _ _ _ hjb _ hjy _ hjd hjlt
    hib hj0 _ _ _ hjb _ hjy _ hjd hjlt
    hiy hj0 _ _ _ hjb _ hjy _ hjd hjlt
    hid hidlt hj0 _ _ _ hjb _ hjy _ hjd hjlt))
```

**Problem**: The number and pattern of hypotheses varies with `n` (how many selection indices), making a fixed naming template unreliable. This approach doesn't generalize.

### Approach 4: rename_i After split_ifs

```lean
same_order_type_grid
rename_i hi hj  -- or more specific patterns
```

**Problem**: `rename_i` only renames inaccessible hypotheses by position, and after `split_ifs` on a game_tuple with variable-length indices, the number of hypotheses per goal varies. This is fragile and would require different `rename_i` calls per goal.

### Approach 5: simp-Based Normalization (Not Feasible)

Using `simp only [...] at *` to normalize all hypotheses is not feasible because:
- The ordering goals involve `<` and `=` on `ExtendedCarrier` which is `M.carrier ⊕ GapType`
- There's no rewrite rule that can normalize `a_bwd ⟨i-1, proof₁⟩` to `a_init ⟨i-1, proof₂⟩` since these are definitionally equal but the Fin bound proofs differ
- `omega` and `decide` don't work on these non-arithmetic goals

### Approach 6: conv Targeting by Structure

Using `conv` to target hypotheses by type pattern rather than name is theoretically possible but extremely verbose for 25 goals and doesn't solve the fundamental matching issue.

## Recommended Solution

### Phase 1: Replace `first | ... | sorry` with Structured Proofs

For **both sorry sites** (lines 1594 and 1866), replace the `same_order_type_grid <;> first | ... | sorry` pattern with:

1. Keep `intro i j; simp only [game_tuple]; split_ifs with <names>` (inlined, not using the macro)
2. Handle each goal with `·` bullets
3. For sel-category goals, use inner `split_ifs with hin/hjn` to distinguish sel(k<n) from sel(k=n)
4. Use the explicit `rw [show a_bwd ⟨k-1, _⟩ = a_bwd ⟨n, by omega⟩ from by congr 1; exact Fin.ext (by omega), hab_n]` pattern for the p_n rewrites

The dead-code block (lines 1924-2021) provides a complete template for Case B (line 1866). Case A (line 1594) needs a similar structure using `hord_sig` instead of `hord_tau` for the sigma-game orderings.

### Phase 2: maxErrors Mitigation

Once the structured proof is in place, the `first | ...` chain is eliminated, so the maxErrors issue vanishes. As a temporary measure during development, add:

```lean
set_option maxErrors 500 in
```

before the theorem definition.

### Phase 3: Optional — Tactic Helper for Fin Rewriting

If this pattern appears in future proofs, consider a helper tactic:

```lean
/-- Rewrite `a_bwd ⟨i-1, _⟩` to `a_bwd ⟨n, _⟩` when i-1=n. -/
macro "rw_fin_eq" h:ident "to" val:term : tactic =>
  `(tactic| (rw [show a_bwd ⟨$h.val - 1, _⟩ = a_bwd ⟨$val, by omega⟩ from
    by congr 1; exact Fin.ext (by omega)]))
```

## Tactic Survey Results

| Goal Pattern | Tactic | Result | Notes |
|------|--------|--------|-------|
| y' vs sel (Fin mismatch) | `convert ⟨tau_sel_y.1.symm, ...⟩ using 3` | works | Needs named Fin arg |
| sel vs p_n (Fin mismatch) | `rw [hab_eq]; pivot_chain_order'` | works | Needs named `hin` |
| p_n vs sel (Fin mismatch) | `rw [hab_eq]; pivot_chain_order_rev'` | works | Needs named `hjn` |
| b_resp vs p_n | `pivot_chain_order'` through d/c | works | Direct application |
| p_n vs b_resp | `pivot_chain_order_rev'` through d/c | works | Direct application |
| y' vs p_n | `⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩` | works | Direct |
| p_n vs x' | `⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩` | works | Direct |
| order_refl (diagonal) | `order_refl` | works | Macro from EFGameTactics |
| `omega` | N/A | fail | Goals are not arithmetic |
| `aesop` | N/A | timeout | Too complex for default rules |
| `simp only [...]` | N/A | fail | Cannot resolve Fin mismatches |

## Effort Estimate

- **Case A (line 1594)**: The existing `first | ...` chain at lines 1422-1594 handles ~22 of 25 cases. Replacing with structured proof: ~200 lines, based on the Case I template. Much of the existing `exact` terms can be reused verbatim.
- **Case B (line 1866)**: The existing chain at lines 1745-1866 handles ~17 of 25 cases. The dead-code block (lines 1924-2021) provides a near-complete template for structured proof. Main gap: it references `hd_le_an` and `hord_fwd` which have different names in the current context (use `h_no_split` and extracted `fwd_*` hypotheses instead). Estimated: ~200 lines.
- **maxErrors**: Zero work once the `first | ...` chains are removed. Temporary: 1 line of `set_option maxErrors 500`.

## Key Hypothesis Mapping (for Implementation)

When converting from the `first | ... | sorry` chain to structured proof:

| Anonymous (current) | Named equivalent | Source |
|---------------------|-----------------|--------|
| `h✝ : i-1 < n` | `hin : i.val - 1 < n` | `split_ifs with ... hin ...` |
| `h✝ : ¬(j-1 < n)` | `hjn : ¬(j.val - 1 < n)` | `split_ifs with ... hjn` |
| `‹_ : i-1 < n›` | `hin` | Named by structured proof |

Critical rewrite pattern for p_n cases:
```lean
rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
  by congr 1; exact Fin.ext (by omega), hab_n]
```

This converts `a_bwd ⟨j-1, bound_proof⟩` to `extendPoint p_n` when `¬(j-1 < n)` implies `j-1 = n`.
