# Implementation Plan: EF Game Automation Tactics

- **Task**: 195 - ef_game_automation_tactics
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: None (Task 155 benefits from Component A but is not a blocker)
- **Research Inputs**: reports/01_ef-game-tactics.md
- **Artifacts**: plans/01_ef-game-tactics.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build four custom tactic components targeting the highly repetitive EF game proof patterns in `Theories/Bimodal/Metalogic/WeakCanonical/`. The WeakCanonical directory contains 13,654 lines across two core files (EFGames.lean, ExpressivenessGeneral.lean) with 273 `game_tuple` references, 65 `pivot_chain_order` call sites, and 7 `same_order_type` proof blocks. All four components will live in a new `Theories/Bimodal/Automation/EFGameTactics.lean` file. The work is complete when the new file compiles, the tactics are applied to at least one existing proof block as validation, and `lake build` passes.

### Research Integration

Research report `reports/01_ef-game-tactics.md` confirmed:
- Zero existing automation targets EF game constructs (all 2,087 lines of existing automation target `DerivationTree`)
- Four private simp lemmas (`game_tuple_zero_eq`, `game_tuple_b_eq`, `game_tuple_y_eq`, `game_tuple_sel_eq`) in ExpressivenessGeneral.lean need to be made public and relocated
- `pivot_chain_order` and `pivot_chain_order_rev` are also private and need to be made public
- Two same_order_type variants exist: split case (L/R partition with `by_cases hjd' : a_bwd j' < d`) and no-split case (with `by_cases hjn : j'.val < n`)
- Component dependency order: B -> C -> D -> A

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals**:
- Create `EFGameTactics.lean` with four tactic components (B, C, D, A)
- Make `game_tuple_*_eq` lemmas and `pivot_chain_order`/`pivot_chain_order_rev` non-private and accessible from the new file
- Validate each tactic by applying it to at least one existing proof in ExpressivenessGeneral.lean
- Maintain `lake build` passing at each phase

**Non-Goals**:
- Refactoring all 7 same_order_type blocks (that is follow-up work after tactics are validated)
- Filling the 12 sorry sites (that is Task 155 scope)
- Modifying EFGames.lean definitions or core semantics
- Full metaprogramming tactic for solve_same_order_type (start with the simpler grid-setup + dispatcher approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Moving private lemmas breaks ExpressivenessGeneral.lean compilation | H | M | Move lemmas to EFGames.lean (after `game_tuple` def) where they naturally belong; update imports incrementally; run `lake build` after each move |
| `pivot_order` context search is fragile with varied hypothesis shapes | M | M | Start with explicit-argument version; add context-search automation incrementally; fall back to explicit application if search fails |
| `same_order_type` grid dispatch has two variants with different case-split logic | H | L | Implement grid setup macro first (shared by both variants); implement variant-specific dispatchers separately |
| Import cycle between EFGameTactics.lean and ExpressivenessGeneral.lean | H | L | EFGameTactics imports EFGames (not ExpressivenessGeneral); lemmas move to EFGames or EFGameTactics, not the other direction |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Lemma Migration and File Scaffolding [COMPLETED]

**Goal**: Make private lemmas public, create the EFGameTactics.lean file with correct imports, and establish the import chain EFGames <- EFGameTactics <- ExpressivenessGeneral.

**Tasks**:
- [x] Make `game_tuple_sel_eq`, `game_tuple_zero_eq`, `game_tuple_b_eq`, `game_tuple_y_eq` non-private in ExpressivenessGeneral.lean (remove `private` keyword) *(completed — moved to EFGames.lean without private)*
- [x] Make `pivot_chain_order` and `pivot_chain_order_rev` non-private in ExpressivenessGeneral.lean *(completed — moved to EFGames.lean without private)*
- [x] Move the 4 `game_tuple_*_eq` lemmas from ExpressivenessGeneral.lean (lines 2024-2056) into EFGames.lean immediately after the `game_tuple` definition (after line 6731)
- [x] Move `pivot_chain_order` and `pivot_chain_order_rev` from ExpressivenessGeneral.lean (lines 1971-2020) into EFGames.lean (after the game_tuple lemmas)
- [x] Create `Theories/Bimodal/Automation/EFGameTactics.lean` with `import Bimodal.Metalogic.WeakCanonical.EFGames` and `import Lean`
- [x] Add `import Bimodal.Automation.EFGameTactics` to `Theories/Bimodal/Automation.lean`
- [x] Add `import Bimodal.Automation.EFGameTactics` to the imports of ExpressivenessGeneral.lean (so it can use tactics from the new file)
- [x] Run `lake build` and verify compilation passes

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` - Add 6 relocated lemmas after `game_tuple` definition
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` - Remove private lemmas, add EFGameTactics import
- `Theories/Bimodal/Automation/EFGameTactics.lean` - Create with scaffolding
- `Theories/Bimodal/Automation.lean` - Add EFGameTactics import

**Verification**:
- `lake build` passes with no new errors
- `game_tuple_sel_eq` etc. are accessible from ExpressivenessGeneral.lean without `private` prefix
- EFGameTactics.lean compiles and can reference `game_tuple`, `same_order_type`, `pivot_chain_order`

---

### Phase 2: Component B -- game_tuple_simp Macro [COMPLETED]

**Goal**: Create the `simp_game_tuple` tactic macro that bundles all four game_tuple simplification lemmas into a single invocation, plus a `game_tuple_unfold` macro for raw dite expansion.

**Tasks**:
- [x] Define `simp_game_tuple` macro in EFGameTactics.lean expanding to `simp only [game_tuple_zero_eq, game_tuple_b_eq, game_tuple_y_eq, game_tuple_sel_eq]`
- [x] Define variant `simp_game_tuple at h` for hypothesis rewriting *(completed — single macro handles both via optional location parameter)*
- [x] Define `game_tuple_unfold` macro expanding to `simp only [game_tuple]; split_ifs <;> try omega`
- [x] Validate by replacing one verbose `simp only [game_tuple, show ... from by omega, ...]` block in ExpressivenessGeneral.lean with `simp_game_tuple at ...` *(completed — replaced 15 call sites across Case I proof)*
- [x] Run `lake build` and verify

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/EFGameTactics.lean` - Add simp macros (~30 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` - Replace 1-2 verbose simp blocks as validation

**Verification**:
- `simp_game_tuple` correctly simplifies `game_tuple x y a b (0, _)` to `x` (and similarly for other indices)
- At least one existing proof uses the macro and `lake build` passes
- `simp_game_tuple at h` works on hypotheses

---

### Phase 3: Component C -- pivot_order Tactic [NOT STARTED]

**Goal**: Create a tactic that automates `pivot_chain_order` / `pivot_chain_order_rev` argument assembly by searching the local context for interval bounds and ordering witnesses.

**Tasks**:
- [ ] Define `pivot_order` as an `elab` tactic in `TacticM` that:
  1. Pattern-matches the goal for `(a < b <-> a' < b') /\ (a = b <-> a' = b')`
  2. Searches the local context (`getLCtx`) for a pivot element `p` with bounds `a <= p`, `p <= b` and corresponding `a' <= q`, `q <= b'`
  3. Searches for the 4 ordering witnesses `(a < p <-> a' < q)`, `(a = p <-> a' = q)`, `(p < b <-> q < b')`, `(p = b <-> q = b')`
  4. Applies `pivot_chain_order` with the found arguments
  5. Falls back to trying `pivot_chain_order_rev` if forward bounds are not found
- [ ] Add a simpler explicit-argument variant `pivot_order_with hap hpb haq hqb hlt_l heq_l hlt_r heq_r` as a macro fallback
- [ ] Validate by replacing 2-3 explicit `pivot_chain_order` calls in ExpressivenessGeneral.lean with `pivot_order`
- [ ] Run `lake build` and verify

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/EFGameTactics.lean` - Add pivot_order tactic (~100-150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` - Replace 2-3 pivot_chain_order call sites as validation

**Verification**:
- `pivot_order` closes goals of the form `(a < b <-> a' < b') /\ (a = b <-> a' = b')` when context contains appropriate bounds and witnesses
- Replaced call sites compile and produce the same proofs
- `lake build` passes

---

### Phase 4: Component D -- winning_condition_tac [NOT STARTED]

**Goal**: Create a tactic that automates the 4-way index split pattern used in `gap_point_agreement` and `formula_agreement` proofs.

**Tasks**:
- [ ] Define `gap_point_index_split hgp_x hgp_b hgp_y hgp_sel` tactic that:
  1. Introduces `i`, applies `simp only [game_tuple]`
  2. Does `by_cases hi0 : i.val = 0` and dispatches with `hgp_x`
  3. Does `by_cases hi_b : i.val = n + 1 + 1` and dispatches with `hgp_b`
  4. Does `by_cases hi_y : i.val = (n + 1) + 2` and dispatches with `hgp_y`
  5. In the else case, applies `hgp_sel (i.val - 1, by omega)`
- [ ] Define `formula_index_split hform_x hform_b hform_y hform_sel` tactic (same but with extra `intro A hA`)
- [ ] Validate by replacing one `gap_point_agreement` proof block (lines 2630-2640 in ExpressivenessGeneral.lean) with the tactic
- [ ] Validate by replacing one `formula_agreement` proof block (lines 2641-2651) with the tactic
- [ ] Run `lake build` and verify

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/EFGameTactics.lean` - Add winning condition tactics (~80-100 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` - Replace 2 proof blocks as validation

**Verification**:
- `gap_point_index_split` closes gap_point_agreement goals with appropriate hypotheses
- `formula_index_split` closes formula_agreement goals with appropriate hypotheses
- Replaced proof blocks compile identically
- `lake build` passes

---

### Phase 5: Component A -- same_order_type Grid Setup [NOT STARTED]

**Goal**: Create a tactic combinator for same_order_type proofs that sets up the 4x4 grid, closes diagonal goals automatically, and provides helpers for cross-boundary and selection cases.

**Tasks**:
- [ ] Define `same_order_type_grid` macro that generates `intro i j; simp only [game_tuple]; split_ifs` and automatically closes diagonal goals (where both indices have the same category) using reflexivity
- [ ] Define `order_refl` helper tactic that closes `(a < a <-> b < b) /\ (a = a <-> b = b)` goals
- [ ] Define `order_from_subgame h i j` helper macro that extracts ordering data from a sub-game `same_order_type` hypothesis `h` at indices `i`, `j` and simplifies with `simp_game_tuple`
- [ ] Validate by partially refactoring one no-split same_order_type block (e.g., lines 3246-3304 which uses `delta game_tuple; split_ifs <;> simp_all`) to use the grid setup
- [ ] Run `lake build` and verify

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Automation/EFGameTactics.lean` - Add grid setup tactic + helpers (~150-200 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` - Partially refactor 1 same_order_type block as validation

**Verification**:
- `same_order_type_grid` generates the 16-goal grid and closes diagonal goals
- `order_from_subgame` correctly extracts ordering at specific indices
- At least one same_order_type block is shorter using the new tactics
- `lake build` passes
- Total EFGameTactics.lean file is 400-600 lines

## Testing & Validation

- [ ] `lake build` passes at each phase boundary
- [ ] Each tactic component is validated against at least one existing proof in ExpressivenessGeneral.lean
- [ ] `simp_game_tuple` correctly normalizes game_tuple at all 4 index categories (0, n+1, n+2, sel)
- [ ] `pivot_order` closes at least 2 pivot_chain_order call sites via context search
- [ ] `gap_point_index_split` and `formula_index_split` close their respective 4-way split patterns
- [ ] `same_order_type_grid` correctly sets up the 16-goal grid and closes diagonal goals
- [ ] No regressions in existing proofs (no new sorries, no removed theorems)
- [ ] EFGameTactics.lean final size is 400-600 lines

## Artifacts & Outputs

- `Theories/Bimodal/Automation/EFGameTactics.lean` - New file with all 4 tactic components
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` - Modified with relocated lemmas
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` - Modified with validation applications
- `Theories/Bimodal/Automation.lean` - Modified with new import

## Rollback/Contingency

If compilation breaks during lemma migration (Phase 1), the private lemmas can be duplicated rather than moved -- create non-private versions in EFGames.lean while keeping the private versions in ExpressivenessGeneral.lean as a transitional step. If any tactic component is too complex to implement within its time budget, implement the simpler explicit-argument macro variant and defer context-search automation. The `pivot_order` tactic is the highest-risk component; if context search proves unreliable, fall back to `pivot_order_with` explicit argument form. If `same_order_type_grid` is too complex, the grid setup macro alone (without automatic diagonal closure) still provides value. All changes can be reverted by removing EFGameTactics.lean, restoring the private lemmas, and removing the import lines.
