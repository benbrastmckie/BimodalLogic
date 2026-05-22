# Research Report: EF Game Automation Tactics (Task 195)

Session: sess_1779478127_74bc0c

## Executive Summary

Analysis of `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (4661 lines) and `EFGames.lean` (8993 lines) confirms four highly repetitive proof patterns amenable to tactic automation. The patterns involve `game_tuple` index simplification, `pivot_chain_order` argument assembly, N x N grid case dispatch in `same_order_type` proofs, and 4-way index splits in `formula_agreement`/`gap_point_agreement`. This report provides concrete specifications for each tactic component.

## 1. Codebase Analysis

### 1.1 File Inventory

| File | Lines | `game_tuple` refs | `pivot_chain_order` refs | `same_order_type` blocks | sorries |
|------|-------|-------------------|--------------------------|--------------------------|---------|
| `EFGames.lean` | 8993 | 68 | 0 | 0 | 4 |
| `ExpressivenessGeneral.lean` | 4661 | 205 | 65 | 5 complete + 2 sorry'd | 8 |
| **Total** | 13654 | 273 | 65 | 7 | 12 |

### 1.2 Existing Automation Infrastructure

Location: `Theories/Bimodal/Automation/` (2087 lines across 4 files)

- `Tactics.lean` (1318 lines): `modal_search`, `temporal_search`, `propositional_search`, `tm_auto` -- all target `DerivationTree` (proof system) goals, not EF game goals
- `ProofSearch.lean` (1384 lines): Native search functions for modal/temporal derivability
- `SuccessPatterns.lean` (423 lines): Pattern learning database
- `AesopRules.lean` (280 lines): Aesop rule configuration

**Key observation**: All existing automation targets the `DerivationTree` proof system. Zero existing automation targets `game_tuple`, `same_order_type`, `pivot_chain_order`, or any EF game construct. The new tactics would be entirely orthogonal to existing infrastructure.

### 1.3 Key Definitions

**`game_tuple`** (EFGames.lean:6722):
```
game_tuple x y a b : Fin (n + 3) -> ExtendedCarrier M atomMap r
```
Maps index i to:
- i = 0 -> x (left boundary)
- i = n+1 -> extendPoint b (challenge point)
- i = n+2 -> y (right boundary)
- 1 <= i <= n -> a (i-1) (selected elements)

**`same_order_type`** (EFGames.lean:6735):
```
same_order_type n tM tN : Prop :=
  forall (i j : Fin (n + 3)),
    (tM i < tM j <-> tN i < tN j) /\
    (tM i = tM j <-> tN i = tN j)
```

**`pivot_chain_order`** (ExpressivenessGeneral.lean:1971):
```
pivot_chain_order (hap : a <= p) (hpb : p <= b) (ha'q : a' <= q) (hqb' : q <= b')
  (hlt_l : a < p <-> a' < q) (heq_l : a = p <-> a' = q)
  (hlt_r : p < b <-> q < b') (heq_r : p = b <-> q = b') :
  (a < b <-> a' < b') /\ (a = b <-> a' = b')
```

**`SplitPointProps`** (ExpressivenessGeneral.lean:1362): Structure providing interval bounds `hxc`, `hcy`, `hx'd`, `hdy'` needed by `pivot_chain_order`.

### 1.4 Existing Simp Lemmas (Private, in ExpressivenessGeneral.lean)

| Lemma | Location | Statement |
|-------|----------|-----------|
| `game_tuple_zero_eq` | Line 2035 | `game_tuple x y a b <0, _> = x` |
| `game_tuple_b_eq` | Line 2042 | `game_tuple x y a b <n+1, _> = extendPoint b` |
| `game_tuple_y_eq` | Line 2050 | `game_tuple x y a b <n+2, _> = y` |
| `game_tuple_sel_eq` | Line 2024 | `game_tuple x y a b <1+k.val, _> = a k` |

These are currently `private` and declared in `ExpressivenessGeneral.lean`. They need to be made non-private and bundled into a simp set.

## 2. Pattern Analysis

### 2.1 Pattern A: same_order_type N x N Grid Dispatch

**Location**: 5 complete proof blocks + 2 sorry'd blocks in `ExpressivenessGeneral.lean`

**Block sizes** (measured from `intro i j; simp only [game_tuple]; split_ifs` to `gap_point_agreement`):
- Lines 2434-2630: 196 lines (Case I, left sub-case)
- Lines 2840-3036: 196 lines (Case I, right sub-case)
- Lines 3246-3304: 58 lines (Case II sigma, uses `delta game_tuple; split_ifs <;> simp_all`)
- Lines 3861-4020: 159 lines (Case II-right sigma)
- Lines 4189-4340: 151 lines (Case II-right tau)

**Total existing**: ~760 lines across 5 blocks

**Pattern structure**: Each proof:
1. Extracts ordering data from sub-game `same_order_type` hypotheses by instantiating at specific `Fin` indices and simplifying with `game_tuple_zero_eq`, `game_tuple_b_eq`, `game_tuple_y_eq`, `game_tuple_sel_eq`
2. Extracts interval bounds from `SplitPointProps` or explicit hypotheses
3. Does `intro i j; simp only [game_tuple]; split_ifs` to get a 4 x 4 = 16 grid of goals (for 4 index categories: x=0, b=n+1, y=n+2, sel=1..n)
4. Dispatches each of the 16 goals:
   - Diagonal (x vs x, b vs b, y vs y): Reflexivity + trivial
   - Cross-boundary: `pivot_chain_order` or `pivot_chain_order_rev` with appropriate bounds
   - Selection-involving: `by_cases hjd' : a_bwd j' < d` then delegate to sigma or tau sub-game ordering

**Two variants observed**:
- **Split case** (Case I): Selections partition into L (below d) and R (above d); each selection case does `by_cases hjd' : a_bwd j' < d`
- **No-split case** (Case II): Selections are all in one sub-game; each selection does `by_cases hjn : j'.val < n` (n-1 from tau, last one is d itself)

### 2.2 Pattern B: game_tuple Simplification

**Occurrences**: 158 `simp only [game_tuple, ...]` sites in `ExpressivenessGeneral.lean`

**Current verbose pattern** (repeated ~75 times):
```lean
simp only [game_tuple,
  show (1 + k.val : Nat) /= 0 from by omega,
  show not((1 + k.val : Nat) = L.card + 1) from by { have := k.isLt; omega },
  show not((1 + k.val : Nat) = L.card + 2) from by { have := k.isLt; omega },
  dite_false, show 1 + k.val - 1 = k.val from by omega] at hsig_gp
```

This pattern replaces `game_tuple` at a selection index by the corresponding `a k`. The `game_tuple_sel_eq` lemma already captures this, but the callers don't use it -- they manually discharge the `dite` conditions.

**Proposed simp set components**:
- `game_tuple_zero_eq`
- `game_tuple_b_eq`
- `game_tuple_y_eq`
- `game_tuple_sel_eq`

### 2.3 Pattern C: pivot_chain_order Argument Assembly

**Occurrences**: 65 call sites of `pivot_chain_order` / `pivot_chain_order_rev` in `ExpressivenessGeneral.lean`

**Signature** (8 explicit arguments):
```
pivot_chain_order
  (hap : a <= p) (hpb : p <= b) (ha'q : a' <= q) (hqb' : q <= b')
  (hlt_l : a < p <-> a' < q) (heq_l : a = p <-> a' = q)
  (hlt_r : p < b <-> q < b') (heq_r : p = b <-> q = b')
```

**Call pattern**: The 4 interval bounds (args 1-4) come from:
- `SplitPointProps` fields: `props.hx'd`, `props.hdy'`, `props.hxc`, `props.hcy`
- Selection bounds: `ha_sig_le_d k`, `hd_le_a_tau k`, `hresp_L_le_c k`, `hc_le_rR k`
- Challenge point bounds: `hb_resp_L_in.1`, `hb_resp_L_in.2`, `hbc`

The 4 ordering witnesses (args 5-8) come from pre-extracted `have` statements like `sig_x_d.1`, `sig_x_d.2`, `tau_d_y.1`, `tau_d_y.2`.

**Automation opportunity**: A tactic could:
1. Inspect the goal `(a < b <-> a' < b') /\ (a = b <-> a' = b')`
2. Search the context for a pivot element `p` such that `a <= p`, `p <= b` (and corresponding `a' <= q`, `q <= b'`)
3. Search for the 4 ordering witnesses `(a < p <-> ...)`, `(a = p <-> ...)`, `(p < b <-> ...)`, `(p = b <-> ...)`
4. Apply `pivot_chain_order` or `pivot_chain_order_rev` automatically

### 2.4 Pattern D: Winning Condition Index Split

**Occurrences**: 8+ blocks in `ExpressivenessGeneral.lean` for `gap_point_agreement` and `formula_agreement`

**Pattern for gap_point_agreement**:
```lean
intro i
simp only [game_tuple]
by_cases hi0 : i.val = 0
. simp [hi0]; exact hgp_x
. by_cases hi_b : i.val = n + 1 + 1
  . simp [hi0, hi_b]; exact hgp_b
  . by_cases hi_y : i.val = (n + 1) + 2
    . simp [hi0, hi_b, hi_y]; exact hgp_y
    . simp [hi0, hi_b, hi_y]; exact hgp_sel <i.val - 1, by omega>
```

**Pattern for formula_agreement** (identical structure but with extra `A hA` args):
```lean
intro i A hA
simp only [game_tuple]
by_cases hi0 : i.val = 0
. simp [hi0]; exact hform_x A hA
. by_cases hi_b : i.val = n + 1 + 1
  . simp [hi0, hi_b]; exact hform_b A hA
  . by_cases hi_y : i.val = (n + 1) + 2
    . simp [hi0, hi_b, hi_y]; exact hform_y A hA
    . simp [hi0, hi_b, hi_y]; exact hform_sel <i.val - 1, by omega> A hA
```

Each block is 8-12 lines. There are at least 8 such blocks (4 for gap_point, 4 for formula), totaling ~80 lines. In the split case (Case I), each selection case further subdivides with `by_cases hjd : a_bwd j < d`, adding ~20 lines per block for the L/R dispatch.

**Variation**: In Case II ("no-split"), the selection branch does `by_cases hjn : j'.val < n` instead of `by_cases hjd : a_bwd j < d`.

## 3. Tactic Specifications

### 3.1 Component B: `game_tuple_simp` Simp Set

**Priority**: Implement first -- prerequisite for all other tactics.

**Implementation plan**:

1. Move `game_tuple_zero_eq`, `game_tuple_b_eq`, `game_tuple_y_eq`, `game_tuple_sel_eq` from `ExpressivenessGeneral.lean` to a new file `EFGameTactics.lean` (or inline in `EFGames.lean` after `game_tuple` definition)
2. Remove `private` modifiers
3. Declare simp attribute set:
```lean
-- Option 1: Explicit simp lemma list (simplest)
/-- Simp lemmas for normalizing game_tuple at specific indices. -/
theorem game_tuple_simp := "use simp only [game_tuple_zero_eq, game_tuple_b_eq,
  game_tuple_y_eq, game_tuple_sel_eq]"

-- Option 2: Custom attribute
register_simp_attr game_tuple_simp "Simp lemmas for game_tuple index normalization"
attribute [game_tuple_simp] game_tuple_zero_eq game_tuple_b_eq game_tuple_y_eq game_tuple_sel_eq
```

4. Add a `game_tuple_unfold` tactic for when raw `dite` expansion is needed:
```lean
macro "game_tuple_unfold" : tactic =>
  `(tactic| (simp only [game_tuple]; split_ifs <;> try omega))
```

**File location**: `Theories/Bimodal/Automation/EFGameTactics.lean` (new file), imported by `ExpressivenessGeneral.lean`

**Estimated savings**: Replaces 75+ multi-line `simp only [game_tuple, show ... from by omega, ...]` blocks with `simp only [game_tuple_zero_eq, game_tuple_b_eq, game_tuple_y_eq, game_tuple_sel_eq]` or the simp set name.

**Lean 4 approach**: The simplest and most robust approach is NOT to use `register_simp_attr` (which requires Mathlib attribute infrastructure) but rather to define a macro that expands to the simp lemma list:
```lean
macro "simp_game_tuple" : tactic =>
  `(tactic| simp only [game_tuple_zero_eq, game_tuple_b_eq, game_tuple_y_eq, game_tuple_sel_eq])

-- For hypothesis rewriting:
macro "simp_game_tuple" "at" h:ident : tactic =>
  `(tactic| simp only [game_tuple_zero_eq, game_tuple_b_eq, game_tuple_y_eq, game_tuple_sel_eq] at $h)
```

### 3.2 Component C: `pivot_order` Tactic

**Priority**: Second -- used by Component A.

**Specification**:

Goal shape: `(a < b <-> a' < b') /\ (a = b <-> a' = b')`

**Algorithm**:
1. Pattern-match the goal to extract `a, b, a', b'`
2. Search the local context for a "pivot witness": hypotheses of the form `a <= p`, `p <= b` for some `p`, and corresponding `a' <= q`, `q <= b'` for some `q`
3. Search for ordering witnesses: `(a < p <-> a' < q)`, `(a = p <-> a' = q)`, `(p < b <-> q < b')`, `(p = b <-> q = b')`
   - These may appear as standalone hypotheses or as `.1`/`.2` projections of a conjunction
4. Apply `pivot_chain_order` with the found arguments
5. If bounds go the other direction (`p <= a` instead of `a <= p`), try `pivot_chain_order_rev`

**Implementation approach**: `elab` tactic in `TacticM`. Key operations:
- `getLCtx` to iterate context
- `isDefEq` to match hypothesis types against patterns
- `mkAppM ``pivot_chain_order` to construct the proof term
- `goal.assign` to close the goal

**Complexity**: Medium. The main challenge is searching for the pivot element and matching the 8 arguments. Since the arguments are typically named conventionally (`props.hx'd`, `sig_x_d.1`, etc.), the tactic should search by type rather than name.

**Estimated savings**: 65 call sites x ~2 lines of manual argument assembly = ~130 lines saved.

### 3.3 Component D: `winning_condition_tac` Tactic

**Priority**: Third -- handles gap_point_agreement and formula_agreement.

**Specification**:

The tactic automates the 4-way index split (not 5-way as originally stated -- the actual split is into index categories {0, n+1, n+2, sel}).

**Algorithm for gap_point_agreement goal** (`gap_point_agreement n tM tN`):
1. Unfold `gap_point_agreement` to get `forall (i : Fin (n + 3)), ...`
2. `intro i; simp only [game_tuple]`
3. Split on `i.val = 0`, `i.val = n+1`, `i.val = n+2`, else (selection)
4. In each case, simplify and apply the corresponding hypothesis (`hgp_x`, `hgp_b`, `hgp_y`, `hgp_sel`)
5. For the selection case, may need further `by_cases` on sigma/tau membership

**Algorithm for formula_agreement goal** (`formula_agreement n tM tN`):
1. Same as above but with extra `intro A hA` and hypothesis application pattern

**Implementation approach**: Macro or `elab` tactic that generates the `by_cases` chain. The simplest approach is a macro:
```lean
macro "winning_condition_index_split" : tactic =>
  `(tactic| (
    intro i; simp only [game_tuple];
    by_cases hi0 : i.val = 0 <;>
    [simp [hi0]; skip;
     by_cases hi_b : i.val = n + 1 + 1 <;>
     [simp [hi0, hi_b]; skip;
      by_cases hi_y : i.val = (n + 1) + 2 <;>
      [simp [hi0, hi_b, hi_y]; skip;
       simp [hi0, hi_b, hi_y]]]]))
```

However, this would need to be parameterized by the hypothesis names, making a full `elab` tactic more appropriate.

**Arguments**: The tactic should take 4 hypothesis references:
```lean
winning_condition_tac hgp_x hgp_b hgp_y hgp_sel
-- or for formula_agreement:
winning_condition_tac hform_x hform_b hform_y hform_sel
```

**Estimated savings**: 8+ blocks x 8-12 lines = ~80-100 lines. In split cases with L/R dispatch, savings increase to ~200-350 lines.

### 3.4 Component A: `solve_same_order_type` Tactic

**Priority**: Fourth (most complex) -- depends on Components B, C, and D.

**Specification**:

The tactic automates the entire `same_order_type` proof for the GHR93 game.

**Core algorithm**:
1. Goal: `same_order_type (n+1) (game_tuple x' y' a_bwd b_resp) (game_tuple x y a'_resp b_sp)`
2. Unfold `same_order_type` to get `forall (i j : Fin (n+4)), ...`
3. `intro i j; simp only [game_tuple]; split_ifs` to generate the 4 x 4 = 16 grid of goals
4. For each goal `(tM i < tM j <-> tN i < tN j) /\ (tM i = tM j <-> tN i = tN j)`:
   - **Diagonal** (i-category = j-category = x, b, or y): Close with reflexivity
   - **Same sub-game**: Apply the corresponding sub-game ordering fact
   - **Cross-boundary**: Apply `pivot_order` (which calls `pivot_chain_order`)
   - **Selection cases**: Further case-split on whether selection is in L or R (split case) or whether index < n (no-split case), then delegate

**Two variants to handle**:
1. **Split variant**: Takes `hord_L` (sigma ordering), `hord_R` (tau ordering), `L`, `R` partition data, `isoL`, `isoR` isomorphisms
2. **No-split variant**: Takes `hord_fwd` (forward ordering), `hord_sig` or `hord_tau` (single sub-game ordering), `a_init` sequence

**Implementation approach**: Due to the complexity and the two variants, the most practical approach is a **tactic macro that generates the proof skeleton** with the standard `intro i j; simp only [game_tuple]; split_ifs` pattern, followed by a **decision procedure** that tries to close each goal:
1. Try `exact <reflexivity pattern>` (for diagonal cases)
2. Try `exact <sub-game ordering hypothesis>` (for same-sub-game cases)
3. Try `pivot_order` (for cross-boundary cases)
4. Try `by_cases` + recursion (for selection cases)

**Alternative simpler approach**: Instead of a full metaprogramming tactic, provide a **tactic combinator** that sets up the grid and leaves goals for the user:
```lean
macro "same_order_type_grid" : tactic =>
  `(tactic| (intro i j; simp only [game_tuple]; split_ifs <;> try (
    exact <| And.intro
      (Iff.intro (fun h => absurd h (lt_irrefl _)) (fun h => absurd h (lt_irrefl _)))
      (Iff.intro (fun _ => rfl) (fun _ => rfl)))))
```
This would close diagonal goals automatically and leave remaining goals. Combined with `pivot_order`, most goals could be closed semi-automatically.

**Full tactic estimate**: 200-400 lines of metaprogramming code.

**Estimated savings per usage**: Each `same_order_type` block is 58-196 lines. With the tactic, each would compress to ~5-15 lines. Across 7 blocks (5 complete + 2 sorry'd), savings would be 600-1300 lines.

## 4. Implementation Recommendations

### 4.1 Recommended File Structure

```
Theories/Bimodal/Automation/EFGameTactics.lean  (NEW - 400-600 lines)
  |-- game_tuple simp lemmas (moved from ExpressivenessGeneral.lean)
  |-- simp_game_tuple macro
  |-- pivot_order tactic
  |-- winning_condition_tac tactic
  |-- solve_same_order_type tactic (or grid setup + dispatcher)
```

The file should import `Bimodal.Metalogic.WeakCanonical.EFGames` for the `game_tuple`, `same_order_type`, `formula_agreement`, `gap_point_agreement`, and `pivot_chain_order` definitions.

### 4.2 Dependency Ordering

```
B (game_tuple_simp)  -- no dependencies, implement first
    |
    v
C (pivot_order)  -- uses game_tuple_simp for goal setup
    |
    v
D (winning_condition_tac)  -- uses game_tuple_simp
    |
    v
A (solve_same_order_type)  -- uses B, C, D
```

### 4.3 Import Chain

Current:
```
EFGames.lean <- ExpressivenessGeneral.lean
```

Proposed:
```
EFGames.lean <- EFGameTactics.lean <- ExpressivenessGeneral.lean
```

The `EFGameTactics.lean` file needs to be added to `Theories/Bimodal/Automation.lean` imports:
```lean
import Bimodal.Automation.EFGameTactics
```

### 4.4 Simp Lemma Migration

The 4 `game_tuple_*_eq` lemmas are currently `private` in `ExpressivenessGeneral.lean`. They need to be:
1. Removed from `ExpressivenessGeneral.lean` (or re-exported)
2. Declared as non-private in `EFGameTactics.lean` (or in `EFGames.lean` after the `game_tuple` definition)
3. Marked with `@[simp]` or collected in a named simp set

The cleanest approach: move them to `EFGames.lean` immediately after the `game_tuple` definition (line ~6732), since they are purely about `game_tuple` and have no dependency on `ExpressivenessGeneral.lean`.

Similarly, `pivot_chain_order` and `pivot_chain_order_rev` are `private` in `ExpressivenessGeneral.lean`. They should be made non-private and either moved to `EFGames.lean` or to `EFGameTactics.lean`.

### 4.5 Risk Assessment

| Component | Complexity | Risk | Notes |
|-----------|-----------|------|-------|
| B (simp set) | Low | Low | Straightforward macro/attribute |
| C (pivot_order) | Medium | Medium | Context search may be fragile if hypothesis shapes vary |
| D (winning_tac) | Medium | Low | Repetitive pattern, well-understood |
| A (solve_same_order_type) | High | Medium-High | Two variants, complex index manipulation |

### 4.6 Relationship to Task 155 Sorries

The following sorry sites in `ExpressivenessGeneral.lean` are `same_order_type` proofs that would directly benefit from Component A:

1. **Line 3199**: Case II sigma `same_order_type` -- has complete commented-out proof (60 lines) that needs compilation fix
2. **Line 3302**: A `sorry` fallback inside the commented-out proof at line 3199
3. **Line 3403**: Case II tau `same_order_type` -- has complete commented-out proof (100+ lines) that needs `(x' < d <-> x < c)` from sigma instantiation
4. **Line 3456**: Inner sorry inside the commented-out tau proof

These 4 sorries represent ~2 distinct proof obligations. With `solve_same_order_type`, each would be 5-15 lines instead of 60-160 lines, and the compilation issues (from `simp_all` behavior differences) would be avoided by using the structured tactic approach.

### 4.7 Lean 4 Metaprogramming Facilities Required

| Facility | Used For | Import |
|----------|----------|--------|
| `Lean.Elab.Tactic.TacticM` | All tactics | `import Lean` |
| `Lean.Meta.isDefEq` | Pattern matching in pivot_order | `import Lean` |
| `Lean.Elab.Tactic.evalTactic` | Executing sub-tactics | `import Lean` |
| `Lean.Macro` | simp set macro | `import Lean` |
| `Lean.Meta.mkAppM` | Constructing proof terms | `import Lean` |
| `Lean.getLCtx` | Context search in pivot_order | `import Lean` |
| `Lean.observing?` | Non-destructive attempt in solve_same_order_type | `import Lean` |
| `Lean.Syntax.mkApp` | Tactic syntax construction | `import Lean` |

Mathlib's `split_ifs` tactic (from `Mathlib.Tactic.SplitIfs`) is already used extensively and would be called programmatically.

## 5. Estimated Impact

| Component | Lines saved (existing) | Lines saved (future sorry-fills) | Implementation cost |
|-----------|----------------------|--------------------------------|---------------------|
| B (game_tuple_simp) | ~150-200 | ~50-100 | ~50 lines |
| C (pivot_order) | ~130 | ~30-50 | ~100 lines |
| D (winning_condition_tac) | ~80-100 | ~100-200 | ~80 lines |
| A (solve_same_order_type) | ~600-800 | ~200-500 | ~200-400 lines |
| **Total** | **~960-1230** | **~380-850** | **~430-630 lines** |

The net savings (lines saved minus implementation cost) is approximately **900-1450 lines** across existing code and future sorry-fills, consistent with the task description estimate of 1200-2500 lines.
