# Phase 2 Handoff: good_of_split_at_succ (Second Attempt)

**Date**: 2026-05-16
**Session**: sess_1778968202_8779ea
**Status**: PARTIAL (2 sorries remain, down from 1 undifferentiated sorry)

## What Was Accomplished

The proof structure for `good_of_split_at_succ` is now formalized:
- `doets_lemma_1_4` is applied correctly (no sorry) with proper pieces/witnesses functions
- Transitivity composition (`h_iso.trans h_sum).trans hZ3`) assembles the chain
- The proof correctly uses `Bool`-indexed families for the ordered sum decomposition
- Full project builds cleanly (`lake build` passes)

## Remaining Sorries (2)

### Sorry 1: `h_iso` (line 350)
**Goal**: `k_equiv sig k (M.subinterval sig t u) (orderedSum sig Bool pieces)`

**What's needed**: 
- Build `OrderIso` from `(M.subinterval sig t u).carrier` to `(orderedSum sig Bool pieces).carrier`
- Forward map: `dite (x ≤ b)` sending to `⟨false, ...⟩` or `⟨true, ...⟩`
- Backward map: match on Sigma component
- Monotone forward: case split on `hxb : x ≤ b` and `hyb : y ≤ b`, use `@Sigma.Lex.le_def`
- Monotone backward: match on `(ia, ib)`, use `orderedSum_le_iff` to decompose ≤
- Predicate preservation: trivial (both use `M.interp p x`)

**Blocker**: Sigma.Lex typing mechanics. The `change @LE.le _ Sigma.Lex.linearOrder.toLE _ _` + `rw [@Sigma.Lex.le_def ...]` pattern was validated in `lean_run_code` but did not compile when embedded in the full file due to `simp only [dif_pos/dif_neg]` not reducing the orderedSum ≤ goal to the Sigma.Lex form expected by `change`. Alternative: define the OrderIso term-mode via `Equiv.toOrderIso` with separately-proved `Monotone` lemmas (the `interval_split_fwd_mono` pattern works in isolation but fails when used as argument to `Equiv.toOrderIso` because Lean can't unify the let-bound `e` application with the abstract `Monotone f` signature).

**Estimated effort to close**: 1-2 hours of careful Sigma.Lex manipulation.

### Sorry 2: `h_good` (line 361)
**Goal**: `good sig k (orderedSum sig Bool witnesses)`

**What's needed**:
- Show both Z-interval witnesses (Z1, Z2) are bounded (have `lo.isSome ∧ hi.isSome`)
- For k ≥ 2: use expressibility of "has a max/min" at depth 2 in NormalForm framework
- For k < 2: prove directly (k=0: all structures good; k=1: 1-type only captures pred combos)
- Once bounded: `Fintype Z.intervalCarrier` via `Set.Icc` finiteness
- `Sigma.instFintype` gives Fintype on orderedSum carrier
- `finite_structures_good` closes the goal

**Blocker**: The expressibility argument (`z_bounded_above_of_has_max`) requires digging into `nf_eval_nf` at depth 2 to show that "∃ x, ∀ y, ¬(x < y)" is captured. This is ~50-100 lines of NormalForm evaluation reasoning. The k < 2 cases need separate proofs.

**Estimated effort to close**: 3-4 hours (expressibility argument + k<2 cases).

## Key Validated Facts (from lean_run_code)

1. `good_at_zero` compiles: all nonempty structures are 0-equiv to any Z-interval
2. `Fintype (Set.Icc a b)` works with existing imports for ℤ
3. `Sigma.Lex.le_def` characterizes ≤ on orderedSum carrier
4. `Bool.false_lt_true` gives the cross-component ≤
5. Forward monotone pattern works: `by_cases hxb; rw [dif_pos/neg]; exact Sigma.Lex.le_def.mpr ...`
6. Backward monotone pattern works: `match ia, ib with | false, false => ...`
7. `doets_lemma_1_4` accepts `Bool`-indexed families directly

## Immediate Next Action

Close sorry 1 (interval_split_iso) first -- it's purely mechanical. Key approach:
1. Define the `Equiv` separately (left_inv/right_inv via `split_ifs <;> rfl` / `dif_pos/dif_neg; rfl`)
2. Define `Monotone fwd` as a standalone lemma with explicit `change` to Sigma.Lex form
3. Define `Monotone bwd` similarly
4. Use `Equiv.toOrderIso e mono_fwd mono_bwd`

The `simp only [dif_pos/dif_neg]` approach works for left/right_inv but NOT for monotone (doesn't reduce the ≤). Use `change` or `show` to expose the Sigma.Lex structure instead.
