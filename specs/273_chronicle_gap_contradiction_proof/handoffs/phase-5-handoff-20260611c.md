# Phase 5 Handoff: Backward Direction -- Structure and Analysis

**Date**: 2026-06-11
**Session**: sess_1781193902_83bc5c
**Phase**: 5b (Backward Direction)
**Status**: IN PROGRESS (partial)

## Summary

Established the backward proof infrastructure: `backward_2var_nf_agreement` (atom+order+quant => nf_eval_nf), `nf_exist_formula_nested_backward` (formula truth => existential), and `nf_composition_depth0` (depth-0 composition). Wired the backward theorem into master_induction, replacing the inline sorry. Fixed pre-existing compat helper regression (Lean version change broke simp_all patterns).

## Current Sorry Inventory

1. **NegationClosure.lean:1256** -- `nf_exist_formula_nested_backward` sorry:
   The backward direction proof is reduced to a single sorry in the body of this theorem.
   The goal at the sorry point is the FULL backward direction:
   ```
   h_formula : temporal_truth M atomMap t (nf_exist_formula_nested k char_kp1 char_k parent_atoms sub_nf)
   |- exists x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
   ```

2. **NegationClosure.lean:830, 865** -- Pre-existing compat helper sorries:
   `nf_full_compat_right_of_eval` and `nf_full_compat_left_of_eval` have `all_goals sorry`
   due to a Lean 4.27.0-rc1 regression where `split_ifs` + `simp_all` no longer closes
   the y=x/y=t predicate atom matching cases. These were sorry-free at commit 6643d159c
   but broke with a Lean version update. NOT caused by this session's changes.

## Mathematical Analysis

The backward direction requires proving: from the formula, extract x and show `nf_eval_nf M (k+1) 2 (x,t) sub_nf`. This splits into:
- **Atom part**: Provable from atom_compat_x + h_atoms + order direction. Infrastructure in `backward_2var_nf_agreement` handles this.
- **Quantifier part**: For each `ssn : NormalForm sig k 3`, show `(exists y, nf_eval_nf M k 3 (y,x,t) ssn) <-> sub_nf.2 ssn = true`. THIS is the mathematical gap.

### Why the formula is insufficient for the quantifier part

The formula gives:
1. `nf_x` with `char_{k+1}(nf_x)` at x -- the depth-(k+1) 1-var NF of x
2. For each positive interval ssn, a y in (t,x) with `char_k(nf_y)` -- the depth-k 1-var NF of y
3. Non-interval ssn filtering via `nf_full_compat_right`

But the formula DOES NOT give:
- The depth-k 2-var NF of (y,t) -- needed to determine the 3-var NF at (y,x,t) via composition
- The depth-k 2-var NF of (y,x) -- also needed for composition
- Negative interval ssn information -- guard is `Formula.top`, so no y is excluded

The depth-k 1-var NF of y (from char_k) does NOT determine the depth-k 2-var NF of (y,t) at depth k >= 1 (the quantifier part of the 2-var NF involves 3-var interactions that are not captured by individual 1-var NFs).

### Required fix

The formula needs strengthening to encode more of sub_nf.2. Two approaches:

**Approach A (minimal)**: Replace `char_k(nf_y)` with `char_{k+1}(nf_y)` for interval witnesses.
The depth-(k+1) 1-var NF of y records all depth-k 2-var NFs at (z,y) for each z.
Combined with the composition lemma, this determines the 3-var NF at (y,x,t).
- PRO: Minimal formula change, char_{k+1} is available from p1_kp1
- CON: Changes the formula definition and breaks the forward proof

**Approach B (explicit encoding)**: For each positive interval ssn, add conjuncts
encoding the ssn-specific quantifier conditions using P2(k) sub-formulas.
- PRO: Directly encodes the needed information
- CON: More complex formula, significant rewrite

**Approach C (composition bypass)**: Prove the quantifier part without composition
by showing that the ACTUAL characteristic NF at (x,t) equals sub_nf. Use
`nf_eval_unique` to equate them, but this requires proving BOTH atom and
quantifier parts match -- circular for the quantifier part.

### Recommendation

Approach A is the most tractable. The change to `char_{k+1}` in the formula is
a single-line modification. The forward proof needs updating (replace char_k_correct
with char_kp1_correct for interval witnesses). The backward proof then uses
the composition lemma to bridge from the depth-(k+1) 1-var NF of y to the
depth-k 3-var NF at (y,x,t).

## Immediate Next Action

1. Modify `nf_exist_formula_nested` to use `char_kp1` instead of `char_k` for interval witnesses
2. Update the forward proof `nf_exist_formula_nested_forward` accordingly
3. Prove the composition lemma for all arities, by induction on depth
4. Complete the backward proof using composition

## Key Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean`
  - Added: backward_2var_nf_agreement, nf_exist_formula_nested_backward, nf_composition_depth0
  - Modified: master_induction (wired backward theorem)
  - Regressed: nf_full_compat_right_of_eval, nf_full_compat_left_of_eval (Lean version)

## Decisions Made

- The formula IS insufficient for the backward direction at depth k >= 1 (confirmed)
- The composition lemma IS needed (depth-k 3-var NF from 2-var projections)
- The formula needs modification (char_k -> char_{k+1} for interval witnesses)
- Pre-existing compat helper regression is orthogonal (temporary sorry)
