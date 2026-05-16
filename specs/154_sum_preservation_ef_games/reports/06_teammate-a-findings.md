# Teammate A Findings: Primary Approach for Task 154

**Date**: 2026-05-16
**Role**: Primary Approach Researcher
**Confidence**: HIGH

## Key Findings

### Finding 1: Cluster 1+2 Fix is a TRIVIAL One-Line Change (VERIFIED)

The 6 errors in `build_bicompat` (lines 548-550 and 629-631) are fixed by replacing the proof term on lines 550 and 631.

**Current code (line 550)**:
```lean
  Fin.cases rfl (fun k => h_idx k)
```

**Fixed code (line 550)**:
```lean
  fun p => by induction p using Fin.cases with | zero => rfl | succ k => rfl
```

**Why this works**: The term-mode `Fin.cases rfl (fun k => h_idx k)` fails because Lean can't unify `h_idx k : (env_M k).fst = (env_N k).fst` with the expected `(Fin.cons ... env_M (Fin.succ k)).1 = ...` — the `show ... from` pattern makes `Fin.cons` opaque to `.1` projection.

However, using `induction p using Fin.cases` in tactic mode, the `succ k` case produces goal `?m.850 k.succ = ?m.850 k.succ` where BOTH sides have the same metavariable — so `rfl` works directly. The key insight: Lean's tactic elaboration treats the projections more uniformly than term-mode elaboration.

**Verified**: `lean_multi_attempt` at lines 550 and 631 both return zero diagnostics with this fix.

**The type annotation (lines 547-549) does NOT need to change.** Only the proof term (line 550) changes.

Same fix applies identically to line 631 (backward oracle).

### Finding 2: Cluster 3 Requires Two Independent Sub-Fixes

The 11 errors in `sum_lift_one_var` (lines 788-812) have two independent root causes:

#### Sub-Fix A: Case-Split on k (fixes `bound` unprovability)

The `bound` field requires `sz j' < k + 1`. When `j' = i`, `sz i = 1`, requiring `1 < k + 1`. For `k = 0`, this is `1 < 1` — **FALSE**. This is an inherent impossibility, not a tactic failure.

**Fix**: Before constructing `cd0`, case-split on `k`:
- `k = 0`: `BiCompat sig 0 1` is definitionally `True` (line 165 of the file). Call `sum_nf_lift_gen` directly with `h_bc := trivial`. Skip `cd0` entirely.
- `k = Nat.succ k'`: Build `cd0` with `budget = k' + 2`. Now `bound` requires `1 < k' + 2`, provable by `omega`.

**Important**: This case-split does NOT change the function signature. Callers pass `k` explicitly; the split is internal.

#### Sub-Fix B: Transparent eM/eN + Non-Destructive Agree (fixes remaining 10 errors for k > 0)

After the k-split, the remaining errors in `cd0` for `k = succ k'` come from:

1. **`subst h` eliminating `i`** (errors 788): After `by_cases h : j' = i` then `subst h`, the variable `i` is eliminated from context. The `if j' = j' then ...` patterns don't reduce because `DecidableEq` on a free variable is opaque.

2. **Opaque eM/eN** (errors 792-802): The `show Fin (if j' = i then 1 else 0) → (ms j').carrier from by rw [if_pos h, h]; exact ...` pattern creates `Eq.mpr` wrappers that block `simp`, `convert`, and `funext`.

3. **Consistent field** (error 812): `rfl` can't prove `0 < if i = i then 1 else 0` because `if i = i then ...` doesn't reduce.

**Recommended approach for k > 0 branch**: Replace opaque `eM`/`eN` with `cast`-based definitions and replace `subst h` with `simp [h]` in agree field. Alternatively, avoid the `by_cases h : j' = i` pattern in agree entirely and use `nf_agreement_monotone` to bridge.

### Finding 3: Why Previous Fixes Failed When Combined

Previous attempts applied fixes atomically (one field at a time) and verified with `lean_multi_attempt`. But CompData is a **structure** — ALL fields must typecheck simultaneously. The specific cascading issue:

1. Fixing `h_idx'` (Cluster 1) changes the TYPE of `cd'` — specifically which `h_idx'` it references
2. Fixing `eM`/`eN` (cd0) changes what the `agree` field sees
3. Fixing `agree` changes what `consistent` expects
4. The `bound` fix (k-split) restructures the entire proof flow

The v7 handoff correctly identified this: "ALL changes to a single CompData construction must be applied atomically." But the deeper issue is that the k-split restructures the proof around `cd0`, not just the fields within it.

### Finding 4: Separation into Independent Parts

The fix divides cleanly into **TWO independent parts**:

| Part | Scope | Lines | Errors Fixed | Dependencies |
|------|-------|-------|-------------|--------------|
| **Part 1**: h_idx' proof term | Lines 550, 631 | 6 | None (standalone) |
| **Part 2**: sum_lift_one_var restructure | Lines 772-816 | 11 | None (standalone) |

**Part 1** can be applied and verified independently with `lake build` — it will reduce errors from 17 to 11.

**Part 2** must be applied atomically (the entire cd0 block + the k-split wrapper), but is independent of Part 1.

## Recommended Approach

### Part 1: Fix h_idx' (Lines 550, 631) — APPLY FIRST, VERIFY

Replace line 550:
```lean
-- OLD:
  Fin.cases rfl (fun k => h_idx k)
-- NEW:
  fun p => by induction p using Fin.cases with | zero => rfl | succ k => rfl
```

Identical replacement on line 631.

Run `lake build` to confirm errors drop from 17 to 11.

### Part 2: Restructure sum_lift_one_var (Lines 772-816) — ATOMIC REPLACEMENT

Replace lines 772-816 with:

```lean
  rcases Nat.eq_zero_or_pos k with rfl | hk_pos
  · -- k = 0: BiCompat sig 0 1 is trivially True
    exact sum_nf_lift_gen sig 0 1 I ms ms'
      (fun m hm => h_comp m (by omega)) envM envN h_atoms_1 trivial sub_nf
  · -- k > 0: build CompData
    obtain ⟨k', rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.pos_iff_ne_zero.mp hk_pos)
    have cd0 : CompData sig I ms ms' (k' + 2) envM envN h_idx_1 := {
      sz := fun j' => if j' = i then 1 else 0
      eM := fun j' => if h : j' = i then
        cast (by rw [if_pos h]) (h ▸ (Fin.cons a Fin.elim0))
        else cast (by rw [if_neg h]) Fin.elim0
      eN := fun j' => if h : j' = i then
        cast (by rw [if_pos h]) (h ▸ (Fin.cons b Fin.elim0))
        else cast (by rw [if_neg h]) Fin.elim0
      agree := fun j' => by
        by_cases h : j' = i
        · subst h
          intro nf
          simp only [if_pos rfl] at nf ⊢
          -- Goal: nf_eval_nf at depth (k'+2-1)=k'+1 with 1 var
          -- Use nf_agreement_monotone to bridge cast in eM/eN
          sorry -- needs concrete exploration
        · intro nf
          simp only [if_neg h] at nf ⊢
          -- Goal: nf_eval_nf at depth k'+2 with 0 vars = h_comp
          exact h_comp (k' + 2) le_rfl j' nf
      bound := fun j' => by
        by_cases h : j' = i
        · simp [if_pos h]; omega
        · simp [if_neg h]; omega
      consistent := fun p j' hj' => by
        fin_cases p
        simp only [h_envM, h_envN] at hj'
        subst hj'
        -- Need to show existence of q in sz i = 1 matching envM/envN
        sorry -- needs concrete exploration
    }
    have h_bc := build_bicompat (budget := k' + 2) (k' + 1) 1 (by omega) envM envN h_idx_1 h_atoms_1 cd0
    exact sum_nf_lift_gen sig (k' + 1) 1 I ms ms'
      (fun m hm => h_comp m (by omega)) envM envN h_atoms_1 h_bc sub_nf
```

**Note**: The `sorry` markers in agree and consistent fields need further exploration of the exact tactic sequences. The structural approach (k-split + cast-based eM/eN) is sound but the agree field's interaction with cast needs concrete verification. The `cast` approach replaces the opaque `show ... from by rw ...` with explicit `cast (by rw ...)` which is potentially MORE transparent to simp lemmas like `cast_eq`.

### Alternative for Part 2 Agree Field

Instead of `cast`-based eM/eN, consider defining eM/eN without ANY branching at the type level:

```lean
eM := fun j' => Fin.elim0  -- sz j' = 0 for j' ≠ i; unused for j' = i since overridden
eN := fun j' => Fin.elim0  -- same
```

But this doesn't work because `Fin.elim0 : Fin 0 → T` and `sz i = 1` means `Fin 1 → T` is needed.

The cleanest approach may be to define `sz` as just `fun _ => 0` and use a DIFFERENT CompData that doesn't track the single element in the component at all — instead delegating entirely to `h_agree_comp`. But this would break `consistent`.

## Evidence/Examples

1. **Cluster 1+2 fix verified**: `lean_multi_attempt` at lines 550 and 631 with `fun p => by induction p using Fin.cases with | zero => rfl | succ k => rfl` returns zero diagnostics
2. **k=0 bound unprovability confirmed**: The goal `1 < 1` at line 805 has no proof (omega correctly fails)
3. **subst elimination of i confirmed**: `lean_goal` at line 786 after `subst h` shows `i` replaced by `j'` with non-reducing `if j' = j' then ...`
4. **Cascading interaction confirmed**: Previous handoffs document 5+ failed attempts at atomic field fixes

## Confidence Level

- **Part 1 (h_idx')**: **HIGH** — verified fix, zero diagnostics
- **Part 2 (sum_lift_one_var structure)**: **HIGH** for the k-split approach, **MEDIUM** for the specific eM/eN implementation. The `cast`-based approach needs concrete verification of the agree field after cast simplification. The k-split itself is mathematically sound and the k=0 bypass is trivially correct.
