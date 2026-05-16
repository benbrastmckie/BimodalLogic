# Research Report: Task #154 - Hands-On Prototyping for Build Error Fix

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-16
**Mode**: Team Research (4 teammates, prototyping focus)
**Session**: sess_1778942548_2fb4d8

## Summary

After 17+ failed approaches across 3 implementation attempts, this focused prototyping round found **THREE independently verified working patterns** for extending CompData without the ite-in-types blocker. All three share the same core insight: **use term-mode `dite` (not tactic-mode `by_cases`) with `Fin.cast` to bridge the type gap, avoiding `subst` entirely**. The key breakthrough (Teammate A): `simp only [if_pos h]` can reduce `ite` in goal types BEFORE introducing dependent variables, which avoids the motive error that `subst` creates.

## Key Findings

### The Core Insight (All Teammates Converge)

The previous 17+ approaches all failed because they used TACTIC-mode case splitting (`by_cases`, `rcases`, `split`, `subst`), which either:
- Eliminates the wrong variable (`subst h` with `h : j' = j` kills `j'` and leaves `if j = j` which is not definitionally `True`)
- Creates opaque `Decidable.casesOn` metavariables that downstream fields can't see through

**The fix**: Use **term-mode `dite`** for field definitions and **`Fin.cast`** to bridge between `Fin (if j' = j then cd.sz j + 1 else cd.sz j')` and concrete `Fin (cd.sz j + 1)` or `Fin (cd.sz j')`. The `Fin.cast` takes a propositional equality proof (`if_pos h` or `if_neg h`) and cleanly converts between Fin types without the ite needing to reduce in TYPE positions.

### Approach 1: Term-Mode dite + Fin.cast + @Fin.cons (Teammate B — RECOMMENDED)

All CompData fields defined using term-mode `dite`:

```lean
eM := fun j' x =>
  if h : j' = j then
    @Fin.cons (cd.sz j) (fun _ => (ms j).carrier) c (cd.eM j) (Fin.cast (if_pos h) x)
  else
    cd.eM j' (Fin.cast (if_neg h) x)

agree := fun j' x y =>
  if h : j' = j then
    ext_agree (Fin.cast (by rw [if_pos h]) x) (Fin.cast (if_pos h) y)
  else
    cd.agree j' (Fin.cast (by rw [if_neg h]) x) (Fin.cast (if_neg h) y)

bound := fun j' =>
  if h : j' = j then by rw [if_pos h]; exact hbound
  else by rw [if_neg h]; exact cd.bound j'

consistent := -- Use Fin.cast (if_pos h).symm for witnesses, no subst
```

**Confidence**: HIGH — all fields verified via `lean_run_code`.

### Approach 2: by_cases + simp BEFORE intro (Teammate A)

For fields where tactic mode is needed (agree), use `by_cases h` + `simp only [if_pos h]` before introducing dependent variables:

```lean
agree := fun j' => by
  by_cases h : j' = j
  · simp only [if_pos h]  -- Rewrites ite in GOAL types
    intro nf               -- Now nf has clean type, no ite
    ...
  · simp only [if_neg h]
    exact cd.agree j'
```

**Confidence**: HIGH — verified at actual line 550 via `lean_multi_attempt`, full CompData extension verified sorry-free in standalone test.

### Approach 3: Function.update + Named def (Teammate D)

Use `Function.update cd.sz j (cd.sz j + 1)` instead of `fun j' => if j' = j then cd.sz j + 1 else cd.sz j'`:

```lean
sz := Function.update cd.sz j (cd.sz j + 1)
eM := extendFn j (Fin.cons c (cd.eM j)) cd.eM  -- named def with dite + Fin.cast
```

Then `simp [Function.update_self]`, `simp [Function.update_of_ne h]`, and `simp [extendFn]` work for all downstream fields.

**Confidence**: HIGH — end-to-end prototype verified.

### Bound Blocker (All Teammates Agree)

`cd.sz j + 1 < budget` must be provided as an explicit parameter `hbound`. Derivable at call sites from:
- `hdn : d + 1 + n ≤ budget` in build_bicompat (where d ≥ 1)
- `cd.sz j ≤ n` (provable from the consistent field — each environment element maps to a unique Fin index)

### h_idx' Fix (Teammate A — Verified at Line 550)

```lean
-- Replace line 550 and 631:
fun p => by induction p using Fin.cases with | zero => rfl | succ k => rfl
```

Zero diagnostics via `lean_multi_attempt`. Independent of the cd' fix.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| A uses `by_cases` (tactic) vs B uses `dite` (term) for agree | Both work. B's term-mode approach is cleaner for eM/eN; A's `simp before intro` is more natural for agree. Combine: term-mode `dite` for eM/eN, tactic `by_cases` + `simp` for agree. |
| C says no tactic fix exists vs A/B verified working fixes | C's diagnosis applies to STRUCTURE LITERAL syntax with tactic-mode `by_cases` (which creates `Decidable.casesOn`). A/B's solutions use TERM-mode `dite` or `simp before intro`, which don't create opaque terms. Both are correct. |
| D proposes `Function.update` vs B uses raw `dite` | Compatible. `Function.update` is syntactically cleaner but may require importing `Mathlib.Logic.Function.Basic`. Raw `dite` + `Fin.cast` works without extra imports. |

### Gaps Identified

1. **Integration risk**: All solutions verified in standalone `lean_run_code`, not in the actual 1133-line file. The cd' block interacts with `build_bicompat`'s recursive call and `extend_atoms` proof. Integration is the remaining risk.
2. **`consistent_count_le` lemma**: Not yet proven. Need to show `cd.sz j ≤ n` from the consistent field's injective mapping.
3. **Exact `agree` field proof**: The standalone tests use simplified agree. The real agree involves `nf_eval_nf` with complex arguments. The `Fin.cast` transport on NormalForm arguments needs exact verification.
4. **Backward oracle**: The backward oracle (lines 628-668) is structurally identical to the forward oracle but hasn't been independently tested.

### Recommendations — Implementation Plan

**Phase 1: Fix h_idx' (2 lines, verified)**
Replace lines 550 and 631 with tactic-mode proof. Run `lake build` to reveal true cd' error set.

**Phase 2: Rewrite cd' body (lines 554-587, 635-668)**
Use Teammate B's pattern (term-mode dite + Fin.cast + @Fin.cons) for eM/eN/bound/consistent.
Use Teammate A's pattern (by_cases + simp before intro) for agree.
Pass `hbound : cd.sz j + 1 < budget` as parameter (derived from `hdn` at call site).

**Phase 3: Fix sum_lift_one_var cd0 (lines 772-816)**
Same patterns. k-split first (k=0 bypasses cd0). For k+1, use dite + Fin.cast.

**Phase 4: Verify with `lake build`**

**Verification protocol**: `lake build` after each phase. No snippet-level verification.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Classical.dec / simp-before-intro | completed | high |
| B | dite + Fin.cast + @Fin.cons | completed | high |
| C | Structural analysis / CompDataLite | completed | high (diagnosis) |
| D | Function.update + named def | completed | high |

## References

- Teammate A: `specs/154_sum_preservation_ef_games/reports/07_teammate-a-findings.md`
- Teammate B: `specs/154_sum_preservation_ef_games/reports/07_teammate-b-findings.md`
- Teammate C: `specs/154_sum_preservation_ef_games/reports/07_teammate-c-findings.md`
- Teammate D: `specs/154_sum_preservation_ef_games/reports/07_teammate-d-findings.md`
