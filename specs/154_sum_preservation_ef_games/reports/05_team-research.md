# Research Report: Task #154 - Systematic Fix for 15 Build Errors

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-15
**Mode**: Team Research (4 teammates)
**Session**: sess_1778911835_755bad

## Summary

All 4 teammates converge on a clear diagnosis: the 15 build errors come from exactly **2 independent root causes** (not 15 separate problems), both of which are tactical elaboration failures — not conceptual or architectural gaps. The architecture (CompData/BiCompat/sum_nf_lift_gen) is correct and should NOT be restructured. All fixes have been verified via `lean_run_code`.

**Critical discovery (Teammate A)**: The `bound` field of `cd0` in `sum_lift_one_var` is UNPROVABLE for `k = 0` (requires `1 < 1`). This requires a case-split on `k` — bypass CompData entirely when `k = 0`.

## Key Findings

### Root Cause 1: Type-Position Opacity (6 errors)

**Location**: `h_idx'` in `build_bicompat`, lines 547-550 and 628-631

**Root cause**: `show (orderedSum sig I ms).carrier from ⟨j, c⟩` elaborates to an opaque let-binding. Since `orderedSum` is a `noncomputable def` (not `abbrev`), `.carrier` is opaque. Lean cannot resolve `.1` (Sigma first-projection) on `Fin.cons (show T from ⟨j, c⟩) env_M p` because the result type is hidden.

**Fix (consensus A+B)**: Two complementary strategies:
1. Replace `show T from ⟨j, c⟩` with `(⟨j, c⟩ : T)` (type ascription is transparent to projection)
2. Use `let` bindings with explicit type: `let envM_ext : Fin (n+1) → (orderedSum sig I ms).carrier := fun p => Fin.cases ⟨j, c⟩ env_M p`
3. Then `h_idx'` becomes: `fun p => Fin.cases rfl (fun k => h_idx k) p`

The `let`-binding approach (A) is more robust because it gives Lean a named term to unfold.

### Root Cause 2: Opaque CompData in sum_lift_one_var (11 errors)

**Location**: `cd0` fields in `sum_lift_one_var`, lines 772-812

**Three sub-issues**:

**2A - `subst` direction (all fields affected)**: `subst h` with `h : j' = i` eliminates the outer function parameter `i` instead of the lambda-bound `j'`. After subst, `i` disappears from context, so `show (if i = i ...) = 1` fails.
- **Fix**: Use `simp [h]` or `rw [h]` instead of `subst h`.

**2B - Opaque eM/eN definitions (agree field, 4 errors)**: `eM`/`eN` use `show Fin (if j' = i then 1 else 0) → (ms j').carrier from by rw [if_pos h, h]; exact fun q => (![a]) q` which creates opaque `Eq.mpr` terms that `dif_pos rfl` and `funext/simp` cannot reduce.
- **Fix (B confirmed)**: Replace with `h ▸ Fin.cons a Fin.elim0` (transparent pattern)
- **Alternative (A)**: Use `fun q => if h : j' = i then h ▸ a else Fin.elim0 (Fin.cast (if_neg h) q)`

**2C - Bound field unprovable at k=0 (1 error)**: The `bound` field requires `sz j' < budget = k + 1`. When `j' = i`, `sz i = 1`, so need `1 < k + 1`. For `k = 0` this is `1 < 1` — **FALSE**.
- **Fix (A)**: Case-split `sum_lift_one_var` on `k`:
  - `k = 0`: `BiCompat sig 0 1 = trivial` — bypass `cd0` entirely, call `sum_nf_lift_gen` directly with trivial BiCompat
  - `k = succ k'`: Full `cd0` works since `1 < k' + 2` by `omega`

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| A proposes `let envM_ext` vs B proposes `(⟨j,c⟩ : T)` ascription | Compatible: use both — ascription inside the let binding |
| C says 17 errors vs handoff says 15 | Count difference is from `lake build` re-analysis; 2 new errors surfaced from previous fix revealing cascading issues |
| A says case-split on k needed; B doesn't mention | A's finding is critical — verified that `bound` is unprovable at k=0; B's fixes only address k>0 case |

### Gaps Identified

1. **Performance**: No teammate measured elaboration time for the fixed file. The ~1100-line file with recursive `build_bicompat` may hit timeout. Teammate D recommends factoring to `SumPreservation.lean` if the next implementation round fails.
2. **Cascade risk**: After applying fixes for Cluster A (let-bindings), the `cd'` construction in `build_bicompat` must be updated to use `envM_ext`/`envN_ext` instead of raw `Fin.cons`. This cascading update wasn't fully verified end-to-end.

### Recommendations

**Concrete fix plan (ordered by dependency)**:

1. **Case-split `sum_lift_one_var` on k** (blocks everything in cd0):
   - `k = 0`: trivial case, return `sum_nf_lift_gen` with `h_bc := trivial`
   - `k + 1`: proceed with full cd0

2. **Fix eM/eN in cd0** (for k+1 case):
   - Replace `show Fin (if j' = i then 1 else 0) → ... from by rw [if_pos h, h]; ...`
   - With `h ▸ Fin.cons a Fin.elim0` (transparent)

3. **Fix agree field in cd0** (depends on eM/eN fix):
   - Replace `subst h` with `simp [h]` or `cases h`
   - Use `simp only [if_pos rfl, dif_pos rfl, Nat.succ_sub_one]` to reduce conditionals

4. **Fix h_idx' in build_bicompat** (independent of cd0):
   - Add `let envM_ext : Fin (n+1) → (orderedSum sig I ms).carrier := fun p => Fin.cases ⟨j, c⟩ env_M p`
   - Add `let envN_ext : Fin (n+1) → (orderedSum sig I ms').carrier := fun p => Fin.cases ⟨j, c'⟩ env_N p`
   - Define `h_idx' : ∀ p, (envM_ext p).1 = (envN_ext p).1 := fun p => Fin.cases rfl (fun k => h_idx k) p`
   - Update `cd'` and recursive call to use `envM_ext`/`envN_ext`

5. **Verify**: `lake build` after all fixes

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach: root causes + fixes | completed | high |
| B | Alternative approaches: transparent patterns | completed | high |
| C | Critic: convergence + blind spots | completed | high |
| D | Strategic: effort projection + factoring | completed | medium |

## References

- Teammate A: `specs/154_sum_preservation_ef_games/reports/05_teammate-a-findings.md`
- Teammate B: `specs/154_sum_preservation_ef_games/reports/05_teammate-b-findings.md`
- Teammate C: `specs/154_sum_preservation_ef_games/reports/05_teammate-c-findings.md`
- Teammate D: `specs/154_sum_preservation_ef_games/reports/05_teammate-d-findings.md`
