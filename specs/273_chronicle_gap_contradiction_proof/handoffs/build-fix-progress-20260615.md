# Handoff: KampBypass Build Error Fix Progress

**Date**: 2026-06-15
**Session**: sess_1781509717_4de986
**Status**: partial (12/39 errors fixed, 27 remain)

## Immediate Next Action

Continue fixing compilation errors in `eq_case_iff` proof at `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`. The 27 remaining errors are all in lines 1067-1481. Five error patterns identified with validated fix techniques.

## What Was Done

1. **Fintype.complete fix** (3 sites: L948, L971, L1245): Changed `Fintype.complete p` to `Multiset.mem_toList.mpr (Fintype.complete p)`. Mathlib API change -- `List.all_eq_true` after simp now gives `∀ x ∈ Fintype.elems.val.toList` (List membership) but `Fintype.complete` returns Multiset membership.

2. **rw to simp fix** (2 sites: L955, L975): Changed `rw [<- h_x_pred]; exact h_eval_p` to `simp only [h_x_pred]; simp only [nf_characteristic, atom_eval] at h_eval_p ⊢; exact h_eval_p`. The `rw` fails due to Fin proof-term mismatches after `Multiset.mem_toList.mpr` wrapping.

3. **Order consistency v_eq fix** (1 site: L1482-1491): Replaced broken `cases h1 ... <;> cases h2 ... <;> simp_all` + `.mpr` usage with a cleaner proof. Derives `v[2] = v[1]` via `le_antisymm` from `h12`/`h21` (order 1↔2 both false), then rewrites `h_o02`/`h_o20` and uses `Bool.eq_iff_iff.mpr` with Iff transitivity.

## Remaining Error Patterns (27 errors)

### Pattern 1: `.mpr` on simplified Iff (13 instances)
After `cases h : ssn _ <;> simp_all`, Iff hypotheses get simplified to bare `≤` propositions. Code uses `.mpr` which fails on non-Iff types.

**Fix**: Use `mt h_o.mp (Bool.eq_false_iff.mp h_case)` contrapositive, or the `v_eq` approach for order consistency blocks.

**Lines**: L1176, L1181, L1194, L1197, L1203, L1204, L1209, L1210, L1215, L1456, L1461, L1472, L1475

### Pattern 2: Unsolved goals after simp_all (4 instances)  
`cases ... <;> simp_all` leaves goals where `nf_x_1var` (a let-binding) doesn't unfold, and `h_eval_ssn`/`h_eval_1` are consumed by `simp_all` before they can bridge the gap.

**Fix**: Use `simp_all [nf_x_1var]` and then handle remaining `nf_x.1 (pred p 0) = ...` goals using `h_atoms`. Or restructure to avoid `cases` on both ssn and nf_x values.

**Lines**: L1153, L1163, L1436, L1444

### Pattern 3: Cascade failures (6 instances)
`introN` fails because upstream unsolved goals change the proof structure.

**Fix**: Resolves automatically when patterns 1-2 are fixed.

**Lines**: L1220-1224, L1479-1481

### Pattern 4: Type mismatch at L1067 (2 instances)
`eq_case_t_pred_1` called with wrong argument structure.

**Fix**: Investigate `eq_case_t_pred_1` signature after nf_characteristic change.

### Pattern 5: Duplicate order consistency blocks
L1194-1231 and L1456-1481 are nearly identical order consistency proofs, both broken the same way. Apply the validated `v_eq` approach from the L1482-1491 fix.

## Key Decisions

- Used `simp only [h_x_pred]` instead of `rw [<- h_x_pred]` to handle Fin proof-term mismatches
- Used `mt h_o.mp (Bool.eq_false_iff.mp h)` pattern to avoid `.mpr` on post-simp_all hypotheses
- Used `le_antisymm + not_lt.mp` approach for deriving value equality from order atom falsity

## Sorry Inventory

| File | Line | Statement | Status |
|------|------|-----------|--------|
| KampBypass.lean | 2096 | bracket case | BLOCKED (Phase 2) |
| KampBypass.lean | 2154 | forward direction | BLOCKED (build errors) |
| KampBypass.lean | 2266 | since case | Phase 4 scope |
| KampBypass.lean | 2354 | depth>=2 | Out of scope |
