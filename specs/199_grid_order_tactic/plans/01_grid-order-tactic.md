# Implementation Plan: Task #199 - Grid Order Tactic for same_order_type Dispatch

- **Task**: 199 - Grid order tactic for same_order_type dispatch
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Task 155 (Reynolds pipeline — provides context for CaseAnalysis.lean)
- **Research Inputs**: specs/199_grid_order_tactic/reports/01_grid-order-tactic.md
- **Artifacts**: plans/01_grid-order-tactic.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Create a `grid_order_tac` macro tactic in `EFGameTactics.lean` and a `fan_order` helper lemma to automate the `same_order_type` grid dispatch in `ghr93_case_II` (CaseAnalysis.lean). The Case B grid dispatch has 1 sorry at line 1960 with 5 remaining unclosed goals. The tactic must handle direct lemma matching (with symmetry), Fin bridging via `convert ... using 3`, hab_eq rewrites for p_n cases, impossible-direction proofs, and fan-order common-root patterns. After building the tactic, apply it to Case B (eliminating the sorry) and optionally refactor Case A (which is already sorry-free but verbose) to use the same tactic for maintainability.

### Research Integration

Key findings from the research report (01_grid-order-tactic.md):

- **Case A grid dispatch (lines 1442-1641) is already sorry-free.** The task description's "Case A sorry at line ~1631" is outdated.
- **Case B grid dispatch has 1 sorry at line 1960** with exactly 5 remaining unclosed goals after the existing `first | ... | sorry` chain.
- **Goals 2, 3, 4** are direct reverses of existing lemmas (tau_b_y', fwd_b_y, fwd_x_b) that fall through because the split_ifs/hab_eq interaction corrupts goal context or produces unexpected Fin indices.
- **Goal 1** (b_resp vs p_n) requires a new `fan_order` helper lemma for the common-root ordering pattern.
- **Goal 5** (sel(i) vs p_n with unrewritten a_bwd) needs manual hab_eq rewrite followed by sel_pn_ord.
- The existing tactic style in this project uses macros (`macro "name" : tactic`) rather than elaborators for this class of dispatch automation.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the completeness critical path by closing sorries in the GHR93 expressive completeness proof, which feeds into task 155 (Reynolds pipeline activation).

## Goals & Non-Goals

**Goals**:
- Create `fan_order` helper theorem in EFGameTactics.lean for common-root ordering patterns
- Create `grid_order_tac` macro tactic in EFGameTactics.lean that automates same_order_type grid dispatch
- Eliminate the sorry at CaseAnalysis.lean line 1960 (Case B grid dispatch)
- Verify zero build errors with `lake build`

**Non-Goals**:
- Closing the sel_pn_ord sorries (lines 1423, 1792) — those are Phase 3C obligations, not this task
- Refactoring Case A grid dispatch to use grid_order_tac (optional stretch goal if time permits)
- Building an elaborator-based tactic (macro approach is sufficient and matches project style)
- Closing the dead code sorry at line 2013 (unreachable code block)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fin bridging fails for some goal shapes | H | M | Test each of the 5 goals individually with `lean_multi_attempt` before committing |
| hab_eq rewrite corrupts goal context | M | M | Use `simp only [hab_eq _ _ <proof>]` instead of `rw` for more robust matching |
| fan_order proof is more complex than sketched | M | L | The proof sketch in the research report is well-analyzed; fall back to trichotomy argument |
| Tactic does not generalize to Case A | L | L | Case A is already sorry-free; generalization is a stretch goal, not a requirement |
| Some goals need impossible-direction proofs not covered by the tactic | M | L | Include impossible-direction patterns (lt_irrefl based) in the first chain |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: fan_order Helper Lemma [BLOCKED]

**Goal**: Create the `fan_order` theorem that handles the common-root ordering pattern where a pivot point p fans out to both a and b.

**Tasks**:
- [ ] Add `fan_order` theorem to `Theories/Bimodal/Automation/EFGameTactics.lean` after the existing `pivot_chain_order_rev'` theorem *(deviation: skipped -- fan_order is NOT a valid theorem; counterexample: p=0,a=1,b=2,q=0,a'=2,b'=1 satisfies all hypotheses but conclusion fails)*
- [ ] The signature should be:
  ```lean
  theorem fan_order {α β : Type*} [LinearOrder α] [LinearOrder β]
      {p a b : α} {q a' b' : β}
      (hpa : p ≤ a) (hpb : p ≤ b) (hqa' : q ≤ a') (hqb' : q ≤ b')
      (hord_a : (p < a ↔ q < a') ∧ (p = a ↔ q = a'))
      (hord_b : (p < b ↔ q < b') ∧ (p = b ↔ q = b')) :
      (a < b ↔ a' < b') ∧ (a = b ↔ a' = b')
  ```
- [ ] Prove using trichotomy on a vs b, transferring through the orderings from p/q *(deviation: skipped -- theorem is false)*
- [ ] Verify the lemma compiles with `lean_goal` / `lean_verify` *(deviation: skipped -- theorem is false)*

**BLOCKER** (Phase 1):
- **What failed**: `fan_order` as stated is NOT a valid theorem. The common-root fan pattern does NOT preserve ordering between branches.
- **What was tried**: Attempted full trichotomy proof. Got stuck in the `p < a, p < b, a < b` case trying to derive `a' < b'` from `q < a'` and `q < b'`. Constructed counterexample: p=0,a=1,b=2,q=0,a'=2,b'=1 where all hypotheses hold but a<b while a'>b'.
- **Why it's stuck**: Fan ordering from a common root does not constrain inter-branch ordering. Unlike pivot_chain_order which requires a LINEAR chain a<=p<=b, the fan pattern p<=a AND p<=b has insufficient structure.
- **What is needed**: The b_resp vs p_n ordering goals in Case B require a fundamentally different approach -- either extracting additional ordering information from the game structure, or restructuring the proof to establish a linear chain.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/EFGameTactics.lean` — add fan_order theorem after line ~102

**Verification**:
- `lean_verify` on `fan_order` shows no sorry
- The theorem type-checks and has the expected signature

---

### Phase 2: grid_order_tac Macro [BLOCKED]

**Goal**: Create the `grid_order_tac` macro that dispatches all same_order_type grid goals using a prioritized strategy chain.

**Tasks**:
- [ ] Add `grid_order_tac` macro to `EFGameTactics.lean` after the fan_order theorem
- [ ] Implement the following strategy chain (ordered by priority):
  1. `order_refl` — diagonal cases
  2. Direct lemma exact match (all non-quantified ordering lemmas and their `.symm` variants)
  3. Quantified lemma match with Fin bridging via `convert ... using 3 <;> (congr 1; exact Fin.ext (by omega))`
  4. `hab_eq` rewrite pass (for p_n cases where a_bwd needs rewriting) followed by re-try of strategies 2-3
  5. Pivot chain combinations (`pivot_chain_order'` and `pivot_chain_order_rev'` with all available bound/ordering pairs)
  6. Fan-order dispatch for common-root patterns
  7. Impossible-direction proofs (lt_irrefl based)
  8. sel_pn_ord / pn_sel_ord with Fin bridging
  9. Fallback: `sorry` (to identify any remaining unclosed goals)
- [ ] The macro should reference hypothesis names that are `have`-bound in the proof context (this is consistent with the existing macro style in EFGameTactics.lean)
- [ ] Verify the macro parses correctly (no syntax errors)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/EFGameTactics.lean` — add grid_order_tac macro

**Verification**:
- The macro definition compiles without errors
- The strategy chain covers all known goal patterns from the research report

---

### Phase 3: Apply to Case B and Close Sorry [PARTIAL]

**Goal**: Replace the sorry at CaseAnalysis.lean line 1960 by using `grid_order_tac` and iterating until all 5 goals are closed.

**Tasks**:
- [ ] In CaseAnalysis.lean, replace the inner `first` block (lines 1934-1960) with `grid_order_tac` *(deviation: altered -- instead of macro, added individual strategies to existing first chain)*
- [x] Run `lean_goal` at the sorry position to verify the tactic closes all 5 remaining goals *(deviation: altered -- identified 6 goals not 5, closed 3 of 6)*
- [x] If any goals remain unclosed (sorry still present), inspect each remaining goal with `lean_goal` and add the missing strategy to `grid_order_tac` *(completed -- added impossible-direction proofs for Goals 2,3,4 and hab_eq+sel_pn_ord variants for Goal 5)*
- [ ] Iterate: for each unclosed goal, determine the correct lemma/strategy, add it to the macro, re-test *(deviation: blocked -- remaining 3 goals require fan_order which is proved invalid)*
- [ ] Once all goals are closed, verify the entire same_order_type block compiles (no sorry)
- [ ] Consider whether the outer `first` chain (lines 1812-1960) can also be simplified to `grid_order_tac` — if so, replace the entire dispatch with `grid_order_tac` for readability *(deviation: skipped -- macro not created due to fan_order invalidity)*
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` to verify module compiles

**BLOCKER** (Phase 3):
- **What failed**: 3 of 6 goals remain at the sorry: (1) b_resp < p_n iff b_sp < e_n, (2) p_n < b_resp iff e_n < b_sp, (3) sel(i) vs p_n with unrewritten a_bwd on j-side.
- **What was tried**:
  - Goals 1,2: These are "fan ordering" goals requiring (b_resp vs p_n) ordering transfer through d/c as common root. Attempted pivot_chain_order' (wrong chain direction), fan_order (theorem proved invalid by counterexample). The b_resp is ABOVE d in Case B (d <= b_resp from hb_resp_in.1), unlike Case A where b_resp <= d (from sigma game), which prevents forming a linear chain d -> b_resp -> p_n.
  - Goal 3: Attempted rw [show a_bwd ... = extendPoint p_n from hab_eq _ _ (by assumption)] + exact/convert sel_pn_ord. The rw fails on Fin proof mismatch.
- **Why it's stuck**: Goals 1,2 require ordering between b_resp and p_n which cannot be derived from available hypotheses using abstract order theory (proved by counterexample). The proof structure for Case B (d <= b_resp) differs fundamentally from Case A (b_resp <= d), and the Case B proof lacks a sigma game ordering that would provide the linear chain. Goal 3 has a Fin proof mismatch in the hab_eq rewrite.
- **What is needed**: For Goals 1,2: either (a) extract a new ordering from hord_big/hwin_big that directly relates b_resp to some big-game element, or (b) restructure the proof to use hwin_tau with e_n as the b-element (getting b_resp at the p_n position), or (c) derive the b_resp-p_n ordering via the full same_order_type of a combined game. For Goal 3: try convert-based hab_eq rewrite or explicit Fin.ext before the rw.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` — replace sorry fallback with grid_order_tac
- `Theories/Bimodal/Automation/EFGameTactics.lean` — add any missing strategies discovered during iteration

**Verification**:
- `lean_verify` on `ghr93_case_II` shows no new sorry from the grid dispatch
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes
- The sorry count at line 1960 is eliminated

---

### Phase 4: Full Build Verification and Optional Case A Refactor [NOT STARTED]

**Goal**: Verify the full project builds cleanly and optionally simplify Case A dispatch.

**Tasks**:
- [ ] Run `lake build` to verify zero build errors across the entire project
- [ ] Confirm the sorry at line 1960 is gone (search for remaining sorry sites in ghr93_case_II)
- [ ] (Optional) If time permits, test whether `grid_order_tac` also handles Case A dispatch (lines 1442-1641):
  - Replace the Case A `first | ... ` chain with `grid_order_tac`
  - If it closes all goals, keep the refactor (significant line reduction)
  - If not, revert — Case A is already sorry-free and functional
- [ ] Document any goals that required special handling in a brief comment above the grid_order_tac call

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` — optional Case A simplification

**Verification**:
- `lake build` passes with zero errors
- `grep -n 'sorry' CaseAnalysis.lean` shows only the expected sel_pn_ord sorries (lines ~1423, ~1792) and the dead code sorry (~2013), NOT the grid dispatch sorry
- No regression in other files

## Testing & Validation

- [ ] `fan_order` theorem compiles and has no sorry (`lean_verify`)
- [ ] `grid_order_tac` macro parses without syntax errors
- [ ] Case B sorry at line 1960 is eliminated
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes
- [ ] `lake build` full project passes with zero errors
- [ ] No new sorries introduced (only pre-existing sel_pn_ord sorries remain)

## Artifacts & Outputs

- `Theories/Bimodal/Automation/EFGameTactics.lean` — fan_order theorem + grid_order_tac macro
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` — sorry elimination at line 1960
- `specs/199_grid_order_tactic/plans/01_grid-order-tactic.md` — this plan

## Rollback/Contingency

If the tactic approach proves infeasible:
1. The fan_order lemma is independently useful and should be kept regardless
2. Fall back to manually adding the 5 missing lemma applications to the existing `first` chain (this is what the research report identifies as the minimal fix)
3. For Goal 1 (b_resp vs p_n), use `fan_order hb_resp_in.1 hd_le_pn (le_of_lt hc_lt_bsp) hc_le_en tau_d_b hord_cd_en_pn` directly
4. For Goals 2-4, add the `.symm` variants with appropriate Fin bridging
5. For Goal 5, add explicit `hab_eq` rewrite + `sel_pn_ord`
6. If even manual fixes fail, restore the sorry and report the blocker
