# Teammate A Findings: Classical.dec and ite Reduction Testing

**Date**: 2026-05-16
**Role**: Teammate A — Classical.dec / ite Reduction
**Confidence**: HIGH for h_idx' fix, HIGH for agree pattern, MEDIUM for full cd' integration

## Key Findings

### Finding 1: Classical.propDecidable Does NOT Help (Neither Does DecidableEq)

Both `@ite _ (Classical.propDecidable _)` and `@ite _ (inferInstance)` are equally opaque in Lean 4. The `simp` tactic can reduce `ite (i = i) 1 0 = 1` in BOTH cases — the difference is NOT about which Decidable instance is used. The actual blocker was the `subst` tactic creating `ite (i = i)` in TYPE positions of dependent terms where `simp`/`rw` have motive errors.

**Tested**:
```lean
-- BOTH work with simp:
example (i : I) : @ite Nat (i = i) (Classical.propDecidable _) 1 0 = 1 := by simp
example (i : I) [DecidableEq I] : @ite Nat (i = i) (inferInstance) 1 0 = 1 := by simp
```

Classical.dec is a **red herring**. The issue is not which Decidable instance, but how the conditional interacts with dependent types after `subst`.

### Finding 2: h_idx' Fix — Verified at Line 550

The tactic-mode proof works with zero diagnostics:
```lean
-- Replace line 550:
fun p => by induction p using Fin.cases with | zero => rfl | succ k => rfl
```
In the `succ k` case, both sides reduce to the SAME metavariable (`?m.850 k.succ = ?m.850 k.succ`), so `rfl` works directly. This resolves the 6 h_idx' errors at lines 548-550 and 629-631.

### Finding 3: The Real Solution — Avoid `subst`, Use `by_cases` + `simp [if_pos h]` BEFORE `intro nf`

**This is the breakthrough finding.** The pattern that works for the agree field:

```lean
agree := fun j' => by
  by_cases h : j' = j
  · -- h : j' = j (but DON'T subst!)
    simp only [if_pos h]  -- Rewrites ite in the GOAL's type args
    -- Now goal has clean NormalForm types without ite
    intro nf
    ... -- rest of proof with clean types
  · simp only [if_neg h]
    exact cd.agree j'
```

The key insight: `simp only [if_pos h]` can reduce `if j' = j then X else Y` to `X` in the GOAL (including type positions) BEFORE `intro nf`. Once the ite is rewritten, `intro nf` gets `NormalForm sig (budget - (cd.sz j + 1)) (cd.sz j + 1)` directly — no opaque `ite` in the type.

**Why `subst` fails**: `subst h` with `h : j' = j` eliminates `j'` and replaces it with `j`, turning `if j' = j` into `if j = j`. But `ite (j = j) X Y` is NOT definitionally equal to `X` because `DecidableEq` is opaque. The `simp [if_pos h]` approach avoids subst entirely — it uses the proof `h` to rewrite the `ite` propositionally.

### Finding 4: Full CompData Extension Pattern — Sorry-Free in Standalone Test

I built and verified (via `#print axioms`) a complete sorry-free CompData extension in a standalone test. The pattern:

```lean
-- eM/eN: use dite in TERM mode (not tactic mode)
eM := fun j' q =>
  if h : j' = j then
    if q.val = 0 then a 
    else cd.eM j ⟨q.val - 1, by have := q.isLt; simp [if_pos h] at this; omega⟩
  else 
    cd.eM j' ⟨q.val, by have := q.isLt; simp [if_neg h] at this; exact this⟩

-- agree: use show + split_ifs to see through the dite structure
agree := fun j' k => by
  show (if h : j' = j then ... else ...) = (if h : j' = j then ... else ...)
  split_ifs with h1 h2
  · exact hab           -- j' = j, k.val = 0
  · exact cd.agree j _  -- j' = j, k.val ≠ 0
  · exact cd.agree j' _ -- j' ≠ j

-- bound: by_cases + simp [if_pos/if_neg] + omega
bound := fun j' => by
  by_cases h : j' = j
  · simp [if_pos h]; exact hbound  -- NEEDS cd.sz j + 1 < budget!
  · simp [if_neg h]; exact cd.bound j'
```

### Finding 5: Bound Blocker Confirmed — Needs External Proof

The `bound` field requires `cd.sz j + 1 < budget` in the `j' = j` case. This is NOT derivable from `cd.sz j < budget` alone. In `build_bicompat`, we have `hdn : d + 1 + n ≤ budget` and the consistent field implies `cd.sz j ≤ n`, so `cd.sz j + 1 ≤ n + 1 ≤ d + n ≤ budget - 1`, giving `cd.sz j + 1 < budget` when `d ≥ 1`. A `consistent_count_le` lemma is needed.

## Recommended Approach

1. **Fix h_idx'** at lines 550 and 631 with tactic-mode `rfl` proof (verified, zero diagnostics)
2. **Rewrite cd' body** using:
   - `by_cases h` instead of `split/subst` for agree
   - `simp only [if_pos h]` to reduce ite BEFORE intro
   - Term-mode dite for eM/eN (not tactic mode)
   - `show` + `split_ifs` for agree to see through dite
3. **Add `consistent_count_le` lemma** proving `cd.sz j ≤ n`
4. **Apply identical patterns** to both forward/backward oracle and sum_lift_one_var

## Evidence/Examples

| Test | Pattern | Result |
|------|---------|--------|
| 1-2 | Classical.propDecidable vs DecidableEq | Both work equally — not the issue |
| 3 | Transport with `▸` on ite-in-types | Works for simple cases |
| 4-5 | Structure with dependent ite fields | Works with by_cases + simp |
| 6-8 | Full CompData extension (simplified) | Sorry-free, `#print axioms` clean |
| 9-10 | Extension with agree referencing eM/eN | `show` + `split_ifs` closes agree |
| 16 | ite reduction in NormalForm type args | `simp [if_pos h]` before `intro nf` works |
| line 550 | h_idx' tactic-mode fix | Zero diagnostics via lean_multi_attempt |
