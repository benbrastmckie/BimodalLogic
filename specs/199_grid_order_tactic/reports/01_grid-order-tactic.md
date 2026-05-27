# Research Report: grid_order_tac Tactic for Automating same_order_type Grid Dispatch

## Overview

Task 199 requests a bespoke `grid_order_tac` tactic to automate the `same_order_type` grid dispatch in `ghr93_case_II` (CaseAnalysis.lean). The file is 3000 lines, and the two instances of `same_order_type_grid` dispatch are in Case A (lines 1442-1641) and Case B (lines 1809-1960).

## Current Sorry Inventory

There are 4 sorry sites inside `ghr93_case_II`:

| Line | Type | Description |
|------|------|-------------|
| 1423 | sel_pn_ord (Case A) | `forall k, (a_init k < extendPoint p_n <-> resp_tau k < e_n) /\ ...` |
| 1792 | sel_pn_ord (Case B) | Identical statement, same sorry pattern |
| 1960 | Grid dispatch fallback (Case B) | `\| sorry` in the `first` chain -- 5 remaining goals |
| 2013 | Dead code (Case B) | Inside block-commented alternative proof, unreachable |

**Key finding**: The Case A grid dispatch (lines 1442-1641) is **sorry-free** -- all grid goals are handled. Only Case B's grid dispatch (lines 1809-1960) has a sorry fallback with 5 remaining unclosed goals.

The sel_pn_ord sorries (lines 1423, 1792) are **separate from the grid dispatch** problem. They represent a proof obligation that is sorry'd pending Phase 3C restructure. The grid dispatch tactic assumes `sel_pn_ord` is available in context (it is introduced via `have ... sorry`).

## Goal Shapes at the Case B Sorry (Line 1960)

After `same_order_type_grid <;> (try rw [hab_eq ...]) <;> (try rw [hab_eq ...]) <;> first | ... | sorry`, exactly 5 goals remain. Each has shape `(LHS_1 < RHS_1 <-> LHS_2 < RHS_2) /\ (LHS_1 = RHS_1 <-> LHS_2 = RHS_2)`.

### Goal 1: b_resp vs p_n (i = n+1+1, j = sel with not(j-1 < n))
```
⊢ (extendPoint b_resp < extendPoint p_n ↔ extendPoint b_sp < e_n) ∧
    (extendPoint b_resp = extendPoint p_n ↔ extendPoint b_sp = e_n)
```
Context: `h✝⁴: ↑i✝ = n + 1 + 1`, `h✝: ¬↑j✝ - 1 < n`

### Goal 2: y' vs b_resp (i = n+1+2, j = n+1+1)
```
⊢ (y' < extendPoint b_resp ↔ y < extendPoint b_sp) ∧
    (y' = extendPoint b_resp ↔ y = extendPoint b_sp)
```
Context: `h✝²: ↑i✝ = n + 1 + 2`, `h✝: ↑j✝ = n + 1 + 1`

### Goal 3: y' vs p_n (i = n+1+2, j = sel with not(j-1 < n))
```
⊢ (y' < extendPoint p_n ↔ y < e_n) ∧
    (y' = extendPoint p_n ↔ y = e_n)
```
Context: `h✝²: ↑i✝ = n + 1 + 2`, `h✝: ¬↑j✝ - 1 < n`

### Goal 4: p_n vs x' (i = sel with not(i-1 < n), j = 0)
```
⊢ (extendPoint p_n < x' ↔ e_n < x) ∧
    (extendPoint p_n = x' ↔ e_n = x)
```
Context: `h✝¹: ↑j✝ = 0`, `h✝: ¬↑i✝ - 1 < n`

### Goal 5: sel(i) vs p_n (i = sel with i-1 < n, j = sel with not(j-1 < n))
```
⊢ (a_bwd ⟨↑i✝ - 1, ⋯⟩ < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ resp_tau ⟨↑i✝ - 1, ⋯⟩ < e_n) ∧
    (a_bwd ⟨↑i✝ - 1, ⋯⟩ = a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ resp_tau ⟨↑i✝ - 1, ⋯⟩ = e_n)
```
Context: `h✝¹: ↑i✝ - 1 < n`, `h✝: ¬↑j✝ - 1 < n`

Note: In goal 5, the j-side `a_bwd` was NOT rewritten by `hab_eq` despite `¬(j-1 < n)` being in context. This suggests the `(try rw [hab_eq _ _ (by assumption)])` pattern fails for certain Fin index configurations. The tactic must handle this case by performing the `hab_eq` rewrite itself.

## Available Ordering Lemmas (Type Signatures)

All ordering lemmas available in the Case B grid dispatch context have the form
`(... < ... ↔ ... < ...) ∧ (... = ... ↔ ... = ...)`:

### Direct Lemmas (non-quantified)
| Name | N-side | M-side | Source |
|------|--------|--------|--------|
| `fwd_x_b` | x vs extendPoint p_n | x' vs extendPoint e_n | Forward game |
| `fwd_x_y` | x vs y | x' vs y' | Forward game |
| `fwd_b_y` | extendPoint p_n vs y | e_n vs y' | Forward game |
| `tau_d_b` | d vs extendPoint b_resp | c vs extendPoint b_sp | Tau game |
| `tau_d_y'` | d vs y' | c vs y | Tau game |
| `tau_b_y'` | extendPoint b_resp vs y' | extendPoint b_sp vs y | Tau game |
| `sig_x_d` | x' vs d | x vs c | Sigma extraction |
| `hord_cd_en_pn` | c vs e_n | d vs extendPoint p_n | Big game extraction |

### Quantified Lemmas (over Fin n)
| Name | N-side | M-side | Source |
|------|--------|--------|--------|
| `tau_d_sel k` | d vs a_init k | c vs resp_tau k | Tau game |
| `tau_sel_b k` | a_init k vs extendPoint b_resp | resp_tau k vs extendPoint b_sp | Tau game |
| `tau_sel_y k` | a_init k vs y' | resp_tau k vs y | Tau game |
| `tau_sel_sel k k'` | a_init k vs a_init k' | resp_tau k vs resp_tau k' | Tau game |
| `tau_b_sel k` | extendPoint b_resp vs a_init k | extendPoint b_sp vs resp_tau k | Tau game |
| `sel_pn_ord k` | a_init k vs extendPoint p_n | resp_tau k vs e_n | (sorry'd) |
| `pn_sel_ord k` | extendPoint p_n vs a_init k | e_n vs resp_tau k | Derived from sel_pn_ord |

### Pivot Lemma
```
pivot_chain_order' {a p b : α} {a' q b' : β}
    (hap : a ≤ p) (hpb : p ≤ b) (ha'q : a' ≤ q) (hqb' : q ≤ b')
    (hord_l : (a < p ↔ a' < q) ∧ (a = p ↔ a' = q))
    (hord_r : (p < b ↔ q < b') ∧ (p = b ↔ q = b')) :
    (a < b ↔ a' < b') ∧ (a = b ↔ a' = b')
```
Requires a LINEAR chain a ≤ p ≤ b.

### Bound Hypotheses
| Name | Statement |
|------|-----------|
| `hb_resp_in` | `inClosedInterval d y' (extendPoint b_resp)` -- .1 = d ≤ b_resp, .2 = b_resp ≤ y' |
| `hd_le_pn` | `d ≤ extendPoint p_n` |
| `hc_le_en` | `c ≤ e_n` |
| `hd_le_sel k` | `d ≤ a_init k` |
| `hc_le_rtau k` | `c ≤ resp_tau k` |
| `hp_n_in` | `inClosedInterval x' y' (extendPoint p_n)` -- .1 = x' ≤ p_n, .2 = p_n ≤ y' |
| `he_n_in` | `inClosedInterval x y e_n` -- .1 = x ≤ e_n, .2 = e_n ≤ y |
| `hb_sp` | `inClosedInterval x y (extendPoint b_sp)` |
| `hc_lt_bsp` | `c < extendPoint b_sp` |
| `props.hx'd` | `x' ≤ d` |
| `props.hxc` | `x ≤ c` |
| `props.hdy'` | `d ≤ y'` |
| `props.hcy` | `c ≤ y` |

## Analysis of Each Remaining Goal

### Goal 2 (y' vs b_resp): Direct reverse of tau_b_y'
Closable by: `exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩`

This goal SHOULD have been caught by line 1943 in the existing first chain: `| exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩`. The fact that it falls through suggests either (a) the `hab_eq` rewrite on one side corrupted the goal, or (b) the goal shape after split_ifs is slightly different from what the `exact` expects. Most likely, the `(try rw [hab_eq ...])` pass changed the goal structure for goals where j-1 = n, causing the subsequent `exact` to fail on metavar unification.

**Root cause hypothesis**: When i = n+1+2 (y') and j = n+1+1 (b_resp), the `(try rw [hab_eq ...])` passes should be no-ops since neither i nor j hits the "sel" index category. However, the split_ifs may have produced different hypothesis names or the dite reduction may not have fully simplified. The existing `| exact ⟨tau_b_y'.1.symm, tau_b_y'.2.symm⟩` at line 1943 is inside the INNER `first` at line 1934, which is itself inside the OUTER `first` at line 1812. The INNER first is only reached as the LAST alternative of the outer first. So goal 2 must have fallen through ALL outer alternatives before reaching the inner first, and then also through all inner alternatives.

Actually, looking at the control flow more carefully: the OUTER first chain (lines 1812-1960) tries each alternative. If the current goal doesn't match any alternative before line 1934, it enters the inner `first` at line 1934. So goals 2, 3, 4 (which are "simple" reverses) should have been caught by the outer chain's earlier entries at lines 1887, 1892, 1894. The fact they fall through is puzzling.

**Likely explanation**: The `(try rw [hab_eq ...]) <;> (try rw [hab_eq ...])` at lines 1810-1811 runs BEFORE the first chain for ALL goals. For goals where the j-index has `¬(j-1 < n)`, the rewrite `hab_eq` fires and replaces `a_bwd ⟨j-1,...⟩` with `extendPoint p_n`. But this rewrite changes the GOAL STRUCTURE even for goals 2, 3, 4 where the a_bwd doesn't appear -- because `split_ifs` may have left dite/ite sub-expressions that `hab_eq` can match unexpectedly.

Actually, the more likely explanation is that after `split_ifs`, each branch has specific hypotheses (`h✝: ↑i✝ = n+1+2`, etc.) and the goals ARE correctly reduced. But the `first` chain alternatives test each one by trying `exact`, and if `exact` fails due to some metavar issue, it moves to the next. The 5 goals that fall through are ones where none of the existing alternatives match.

### Goal 3 (y' vs p_n): Reverse of fwd_b_y
Closable by: `exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩`

This IS in the inner first chain at line 1941. Same puzzling fallthrough.

### Goal 4 (p_n vs x'): Reverse of fwd_x_b
Closable by: `exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩`

This IS in the inner first chain at line 1942.

### Goal 1 (b_resp vs p_n): Pivot through d/c with hord_cd_en_pn
This is the most complex remaining goal. Both b_resp and p_n are above d, so there's no linear chain for pivot_chain_order'. The existing attempts at lines 1944-1949 use `pivot_chain_order'` and `pivot_chain_order_rev'` with reversed hord_cd_en_pn, but these likely fail on unification because there's no linear chain d ≤ b_resp ≤ p_n.

**Solution approaches**:
1. **Convert + Fin bridging**: If the goal actually has `a_bwd ⟨j-1,...⟩` instead of `extendPoint p_n`, use `convert ... using 3 <;> (congr 1; exact Fin.ext (by omega))` to bridge the Fin mismatch.
2. **Manual case split**: Use `rcases lt_trichotomy (extendPoint b_resp) (extendPoint p_n)` and handle each case using tau_d_b and hord_cd_en_pn.
3. **New helper lemma**: Create a `fan_order` lemma that handles the common-root pattern: given d ≤ a, d ≤ b, c ≤ a', c ≤ b', (d < a ↔ c < a'), (d = a ↔ c = a'), (d < b ↔ c < b'), (d = b ↔ c = b'), prove (a < b ↔ a' < b').

### Goal 5 (sel(i) vs p_n with unrewritten a_bwd): hab_eq + sel_pn_ord
The j-side a_bwd was NOT rewritten by `(try rw [hab_eq ...])`. The tactic must:
1. Rewrite `a_bwd ⟨j-1,...⟩` to `extendPoint p_n` using `hab_eq`
2. Then apply `sel_pn_ord ⟨i-1, ...⟩`

The `(try rw [hab_eq _ _ (by assumption)])` failed because the Fin index didn't unify. The tactic should use `simp only [hab_eq _ _ ‹¬_ < n›]` or `convert` with Fin.ext bridging.

## The Fin n vs Fin (n+1) Bridging Issue

The `game_tuple` for `same_order_type (n+1)` uses `Fin (n+1+3)` indices. After `split_ifs`, selection indices produce `a_bwd ⟨i-1, proof_n+1⟩ : Fin (n+1)`. But the ordering lemmas like `tau_sel_y` take `k : Fin n` and return orderings on `a_init k` where `a_init k = a_bwd ⟨k.val, proof_n+1⟩`.

The mismatch: `a_bwd ⟨i-1, proof₁⟩` from split_ifs vs `a_bwd ⟨k.val, proof₂⟩` from lemma application. Even though both refer to the same element when `i-1 = k.val`, the Fin values carry different bound proofs, causing `exact` to fail.

**Bridging pattern**: `convert lemma using 3 <;> (congr 1; exact Fin.ext (by omega))`

This:
1. `convert ... using 3` -- matches the goal up to 3 levels of congruence
2. `congr 1` -- reduces Fin equality to value equality
3. `exact Fin.ext (by omega)` -- proves the value equality using omega

## The hab_eq Rewrite Pattern

`hab_eq : ∀ (k : Nat) (hk : k < n + 1), ¬(k < n) → a_bwd ⟨k, hk⟩ = extendPoint p_n`

When `¬(i-1 < n)` is in context (meaning i-1 = n), this rewrites `a_bwd ⟨i-1,...⟩` to `extendPoint p_n`. The rewrite is applied via:
```
(try rw [hab_eq _ _ (by assumption)])
```

**Failure modes**:
1. `by assumption` can't find `¬(_ < n)` if the hypothesis name is mangled
2. The `_` for `hk : k < n+1` can't be inferred from context
3. Multiple `a_bwd` sub-expressions exist and the wrong one gets rewritten

The tactic should handle this by using `simp only [hab_eq _ _ ‹¬_ < n›]` or by trying both `rw` and `simp only` variants.

## Existing Automation Patterns

### EFGameTactics.lean (main file)
- **`same_order_type_grid`**: Macro that does `intro i j; simp only [game_tuple]; split_ifs`
- **`order_refl`**: Closes diagonal goals `(a < a ↔ b < b) ∧ (a = a ↔ b = b)`
- **`simp_game_tuple`**: Simplifies game_tuple using index-category lemmas
- **`pivot_chain_order'`** / **`pivot_chain_order_rev'`**: Convenience wrappers for chain pivoting
- **`extract_order`**: Helper for extracting ordering data from sub-game hypotheses

### Tactics/Helpers.lean
- Uses `elab` and `TacticM` for custom tactic implementation
- Pattern: try multiple strategies in order (axiom match, assumption match, modus ponens)
- Uses `observing?` for non-destructive trial

### SuccessPatterns.lean
- Pattern learning infrastructure (unused but available)

### Tactic Style
- Tactics in this project are primarily defined as macros (`macro "name" : tactic`)
- More complex tactics use `elab "name" : tactic` with `TacticM`
- Heavy use of `first | ... | ...` chains for case dispatch
- Fin bridging via `convert ... using 3 <;> (congr 1; exact Fin.ext (by omega))`

## Recommendations for Tactic Design

### Architecture: Macro vs Elaborator

Given the complexity, a **hybrid approach** is recommended:

1. **Core dispatch as a macro** that tries each ordering lemma pattern
2. **Fan-order helper lemma** as a Lean theorem (not tactic metaprogramming)

### Proposed Tactic: `grid_order_tac`

The tactic should be placed in `Theories/Bimodal/Automation/EFGameTactics.lean` alongside the existing tactics.

#### Strategy (ordered by priority):

1. **order_refl**: Close diagonal goals `(a < a ↔ b < b)`
2. **Direct match**: Try each available ordering lemma and its `.symm` variant
3. **Quantified match with Fin bridging**: For quantified lemmas (tau_sel_y, etc.), try `convert lemma ⟨_, ‹_›⟩ using 3 <;> (congr 1; exact Fin.ext (by omega))`
4. **hab_eq rewrite + re-try**: If a_bwd appears, try `simp only [hab_eq _ _ ‹¬_ < n›]` then retry steps 2-3
5. **Pivot chain**: Try `pivot_chain_order'` and `pivot_chain_order_rev'` with all available bound/ordering combinations
6. **Impossible direction**: For goals where LHS < RHS is always False in both structures (both sides bounded), construct the impossibility proof
7. **Fan-order**: For goals needing a common-root ordering, apply a new `fan_order` lemma

#### New Helper Lemma: `fan_order`

```lean
theorem fan_order {α β : Type*} [LinearOrder α] [LinearOrder β]
    {p a b : α} {q a' b' : β}
    (hpa : p ≤ a) (hpb : p ≤ b) (hqa' : q ≤ a') (hqb' : q ≤ b')
    (hord_a : (p < a ↔ q < a') ∧ (p = a ↔ q = a'))
    (hord_b : (p < b ↔ q < b') ∧ (p = b ↔ q = b')) :
    (a < b ↔ a' < b') ∧ (a = b ↔ a' = b')
```

This handles the common-root pattern where p fans out to both a and b.

**Proof sketch**: By linear order on α, either a < b, a = b, or a > b. Use the orderings through p/q:
- If a < b: p ≤ a < b and p ≤ b. Then a ≠ p (since a < b and p ≤ b) or a = p. Use hord_a and hord_b to transfer.
- The proof is a trichotomy argument relating a,b via their orderings from p, then using hord_a/hord_b to transfer to a',b' via q.

This lemma would close Goal 1 (b_resp vs p_n) via:
```
fan_order hb_resp_in.1 hd_le_pn (le_of_lt hc_lt_bsp) hc_le_en tau_d_b hord_cd_en_pn
```

#### Macro Implementation Sketch

```lean
macro "grid_order_tac" : tactic =>
  `(tactic| first
    | order_refl
    -- hab_eq rewrite pass
    | (try simp only [hab_eq _ _ ‹¬_ < n›]) <;> first
      -- Direct lemmas and their symmetries
      | exact fwd_x_b | exact ⟨fwd_x_b.1.symm, fwd_x_b.2.symm⟩
      | exact fwd_x_y | exact ⟨fwd_x_y.1.symm, fwd_x_y.2.symm⟩
      | exact fwd_b_y | exact ⟨fwd_b_y.1.symm, fwd_b_y.2.symm⟩
      | exact tau_d_b | exact ⟨tau_d_b.1.symm, tau_d_b.2.symm⟩
      -- ... (all direct lemmas)
      -- Quantified with Fin bridging
      | exact tau_sel_y ⟨_, ‹_›⟩
      | (convert ⟨(tau_sel_y ⟨_, ‹_›⟩).1.symm, (tau_sel_y ⟨_, ‹_›⟩).2.symm⟩ using 3
         <;> (congr 1; exact Fin.ext (by omega)))
      -- ... (all quantified lemmas with convert)
      -- sel_pn_ord / pn_sel_ord
      | exact sel_pn_ord ⟨_, ‹_›⟩
      | (convert pn_sel_ord ⟨_, ‹_›⟩ using 3 <;> (congr 1; exact Fin.ext (by omega)))
      -- Pivot chain combinations
      | exact pivot_chain_order' ...
      -- Fan order (new helper)
      | exact fan_order hb_resp_in.1 hd_le_pn (le_of_lt hc_lt_bsp) hc_le_en tau_d_b hord_cd_en_pn
      -- Impossible direction
      | (exact ⟨⟨fun h => absurd (lt_of_lt_of_le h ...) (lt_irrefl _), ...⟩, ...⟩)
    )
```

### Problem: Context-Dependent Hypothesis Names

The tactic will reference hypothesis names like `tau_d_b`, `fwd_x_b`, etc., which are `have`-bound names in the proof context. This is fragile -- if the proof is restructured, the names change.

**Recommendation**: The tactic should be a MACRO rather than an elaborator, so it operates at the surface syntax level and naturally picks up `have`-bound names from the enclosing proof scope. This is exactly how the existing `order_refl` macro works.

### Alternative: Elaborator-Based Tactic

For a more robust solution, an elaborator-based tactic could:
1. Inspect the goal to extract the LHS/RHS of `<` and `=`
2. Search the local context for ordering hypotheses matching the pair
3. Try `exact`, then `exact ⟨...symm, ...symm⟩`, then `convert ... using 3`
4. If no direct match, search for pivot points and apply pivot_chain_order'

This is significantly more work but would be context-independent. Given the project's current tactic style (macros), a macro approach is recommended for the initial implementation, with a potential elaborator upgrade later.

### Usage

After implementing `grid_order_tac`, the grid dispatch in both Case A and Case B would become:

```lean
same_order_type_grid <;>
  (try rw [hab_eq _ _ (by assumption)]) <;>
  (try rw [hab_eq _ _ (by assumption)]) <;>
  grid_order_tac
```

## Scope Clarification

The task description mentions "replace the two sorry fallbacks in ghr93_case_II: Case A sorry at line ~1631 and Case B sorry at line ~1940". However:

- **Case A grid dispatch is already sorry-free** (lines 1442-1641 have no sorry)
- **Case B grid dispatch has one sorry at line 1960** (5 remaining goals)
- **The sel_pn_ord sorries (lines 1423, 1792)** are separate and NOT part of the grid dispatch

The tactic should focus on closing the 5 Case B fallthrough goals and could also simplify the existing 200+ line Case A/B dispatch chains into a single `grid_order_tac` call.

## Required New Definitions

1. **`fan_order` theorem** -- Common-root ordering (in EFGameTactics.lean or CustomGame.lean)
2. **`grid_order_tac` macro** -- The main dispatch tactic (in EFGameTactics.lean)

## Dependencies

- The tactic depends on `sel_pn_ord` and `pn_sel_ord` being available in context (even if sorry'd)
- It depends on the specific hypothesis naming convention used in ghr93_case_II
- It requires `hab_eq` to be available for the p_n rewrite cases
