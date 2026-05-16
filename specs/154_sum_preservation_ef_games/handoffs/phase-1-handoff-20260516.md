# Phase 1 Handoff - Forward Oracle cd'

## Session
- **ID**: sess_1778947691_8318ca
- **Date**: 2026-05-16
- **Status**: PARTIAL - sz_le_n, consistent, and build_bicompat call remain

## Key Breakthroughs

### 1. h_idx' Fix (WORKING)
```lean
have h_idx' : ... :=
  fun p => by induction p using Fin.cases with | zero => rfl | succ k => exact h_idx k
```
Required `@Fin.cons n (fun _ => (orderedSum sig I ms).carrier)` explicit motive in the TYPE annotation to let `.fst` resolve.

### 2. Match on d for hbound (WORKING)
```lean
match d, hdn with
| 0, _ => trivial
| d' + 1, hdn' =>
have hbound : cd.sz j + 1 < budget := by have := cd.sz_le_n j; omega
```
Need `sz_le_n : forall j, sz j <= n` field added to CompData (line 310). Without it, `cd.sz j + 1 < budget` is NOT provable from `hsz : cd.sz j < budget` and `hdn` alone.

### 3. eM/eN Fields (WORKING)
```lean
eM := fun j' x => by
  by_cases h : j' = j
  . exact h ▸ @Fin.cons (cd.sz j) (fun _ => (ms j).carrier) c (cd.eM j) (Fin.cast (if_pos h) x)
  . exact cd.eM j' (Fin.cast (if_neg h) x)
```
- Must use tactic mode with `by_cases` (not term-mode `dite`)
- Must use `@Fin.cons` with explicit non-dependent motive
- `Fin.cast (if_pos h)` converts `Fin (if j' = j then ...)` to `Fin (cd.sz j + 1)`
- `h ▸` converts result from `(ms j).carrier` to `(ms j').carrier`

### 4. agree Field (WORKING)
```lean
agree := fun j' => by
  by_cases h : j' = j
  . subst h; intro nf
    exact hK_eq2 ▸ h_ext_agree (hK_eq2 ▸ nf)
  . intro nf; exact cd.agree j' nf
```
After `subst h`, the ite-in-types problem is AVOIDED because:
- `nf` keeps its ite-polluted type but `hK_eq2 ▸ nf` casts it using the K = budget - (sz+1) equality
- The eM/eN lambda in the goal was already reduced by subst (j' = j' becomes trivial for the dif)

### 5. bound Field (WORKING)
```lean
bound := fun j' => by
  by_cases h : j' = j
  . rw [if_pos h]; exact hbound
  . rw [if_neg h]; exact cd.bound j'
```

### 6. sz_le_n Field (NEEDS FIXING)
```lean
sz_le_n := fun j' => by
  by_cases h : j' = j
  . subst h; simp [if_pos rfl]; exact Nat.succ_le_succ (cd.sz_le_n j')
  . simp [if_neg h]; exact Nat.le_succ_of_le (cd.sz_le_n j')
```
Error: simp might not reduce `if_pos rfl` on `(if j' = j' then ...)` due to opaque DecidableEq.
Try: `rw [if_pos rfl]` or `rw [show (if j' = j' then ...) = ... from if_pos rfl]`

### 7. consistent Field (NEEDS REWRITE)
Current approach with `Fin.cast` doesn't match the tactic-mode eM/eN. Need to:
- After `simp [Fin.cons_zero]` in zero case, `hj' : j = j'` (or `j' = j` form)
- Use `subst hj'` then provide witness `⟨0, by simp [dif_pos rfl, Fin.cons_zero]⟩`
- In succ case, similarly subst or handle both by_cases branches

### 8. build_bicompat Call (WORKING conceptually)
```lean
exact build_bicompat (d' + 1) (n + 1) (by omega) _ _ _ h_atoms_ext cd'
```
Should work once cd' type-checks.

## Current Error Count
- Forward oracle: ~5 errors (sz_le_n + consistent)
- Backward oracle: 3 errors (same h_idx'/cd' pattern, unmodified)
- cd0: ~10 errors (unmodified)

## Immediate Next Action
1. Fix sz_le_n: try `rw [if_pos rfl]` instead of `simp [if_pos rfl]` after subst
2. Fix consistent: use `subst hj'` (or `subst (hj'.symm)`) and `dif_pos rfl`/`dif_neg`
3. Once forward oracle compiles, apply identical pattern to backward oracle
4. Fix cd0 (simpler: sz is 0 or 1, not incremented)

## File Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
  - Line 310: Added `sz_le_n : forall j : I, sz j <= n` field to CompData
  - Lines 547-604: Forward oracle rewritten
  - Lines 636-668: Backward oracle (NOT YET modified - same pattern as forward)
  - Lines 772-813: cd0 (NOT YET modified - needs sz_le_n field)
