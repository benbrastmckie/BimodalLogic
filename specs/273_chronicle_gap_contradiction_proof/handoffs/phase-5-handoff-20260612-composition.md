# Phase 5 Handoff: Composition Lemma Required for Backward Direction

**Date**: 2026-06-12
**Session**: sess_1781193902_83bc5c
**Phase**: 5 (Backward Direction)
**Status**: BLOCKED on composition lemma

## Executive Summary

The char_{k+1} formula fix is complete and building. The only remaining sorry
in the Kamp/Rabinovich pipeline is `nf_exist_formula_nested_backward` at
`NegationClosure.lean:1371`. This sorry reduces to a single mathematical fact:
the **Feferman-Vaught composition lemma for NormalForms** (Doets 1989 Lemma 1.4/1.5).
Once that lemma is proved, the backward proof can be completed and all 3 remaining
sorries close (1 direct + 2 downstream).

## What Was Done This Session

### 1. char_{k+1} Formula Fix (commits 2fb5bd5b2, ef5a975b9)
- `nf_exist_formula_nested` changed: interval witnesses now use `char_kp1` (depth k+1) instead of `char_k` (depth k)
- `char_k` parameter removed from formula definition, forward/backward theorems, all call sites
- New `ssn_compat_var0'` helper for cross-depth atom compatibility
- Forward proof repaired (uses depth-(k+1) characteristic NFs for interval witnesses)

### 2. Pre-existing Compat Helper Fix (commit 2fb5bd5b2)
- `nf_full_compat_right_of_eval` and `nf_full_compat_left_of_eval` were broken by Lean 4.27.0-rc1
- Fixed with explicit y=x and y=t order derivation proofs (replacing fragile `split_ifs + simp_all`)

### 3. Interval SSN Filter Fix (commit 68c80dd5f)
- Found a real semantic defect: interval ssn's weren't checking var-1/var-2 atom compat
- Proved by counterexample on integer model M = (Z, <) with 1 predicate
- Fixed `nf_full_compat_right`/`nf_full_compat_left` to check `ssn_x_pred_compat && ssn_t_pred_compat && ssn_xt_order_compat` for interval ssn's
- Forward proofs rewritten with `by_cases hsub : sub_nf.2 ssn = true` strategy

## Sorry Inventory

| File | Line | Description | Closes when |
|------|------|-------------|-------------|
| NegationClosure.lean | 1371 | `nf_exist_formula_nested_backward` | Composition lemma proved |
| NfCharFormula.lean | 572 | `nf_2var_exist_formula_prior` | NegationClosure sorry-free |
| KampPrior.lean | 149 | `nf_characterizable_temporal_prior k+1` | NfCharFormula sorry-free |

## What Needs To Be Done

### Step 1: Composition Lemma (new file: NfComposition.lean)

**Statement** (arity-3 specialization, but prove arity-general):

```
theorem nf_composition {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k n : Nat)
    (env : Fin n → M.carrier)
    -- If two environments agree on all pairwise 2-var projections...
    (env' : Fin n → M.carrier)
    (h_pairwise : ∀ (i j : Fin n),
      nf_characteristic M k 2 (fun idx => if idx = 0 then env i else env j) =
      nf_characteristic M k 2 (fun idx => if idx = 0 then env' i else env' j)) :
    -- ...then they have the same n-var NF
    nf_characteristic M k n env = nf_characteristic M k n env'
```

Equivalently (easier to use in the backward proof):

```
theorem nf_3var_from_2var_projections {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (y x t_val : M.carrier)
    (ssn : NormalForm sig k 3)
    (h_yx : nf_eval_nf M k 2 (fun idx => if idx = 0 then y else x)
              (nf_2var_proj_yx ssn))
    (h_yt : nf_eval_nf M k 2 (fun idx => if idx = 0 then y else t_val)
              (nf_2var_proj_yt ssn))
    (h_xt : nf_eval_nf M k 2 (fun idx => if idx = 0 then x else t_val)
              (nf_2var_proj_xt ssn))
    : nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t_val))) ssn
```

where `nf_2var_proj_yx`, etc., are the 2-var projections of the 3-var NF.

**Proof by induction on k:**

- **k = 0**: Atoms at (y,x,t) split into per-variable predicates (available from any 2-var NF containing that variable) and order pairs (available from the 2-var NF containing both endpoints). Already proved as `nf_composition_depth0` in NegationClosure.lean.

- **k+1**: Atom part same as k=0. Quantifier part: for each `sub4 : NormalForm sig k 4`, need `(exists z, nf_eval_nf M k 4 (z,y,x,t) sub4) <-> ssn.2 sub4 = true`. The key: by IH at depth k for arity 4, the 4-var NF at (z,y,x,t) is determined by pairwise 2-var NFs. The 2-var NFs involving z are:
  - (z,y) -- determined by nf_y.2 (the depth-(k+1) 1-var NF of y, which we have from char_kp1)
  - (z,x) -- determined by nf_x.2
  - (z,t) -- determined by nf_t.2 (= parent_atoms characterization)
  - The 2-var NFs among {y,x,t} are fixed (from h_yx, h_yt, h_xt).

  So: exists z with 4-var NF sub4 iff exists z with matching pairwise 2-var NFs. The "iff" uses the IH composition at arity 4.

**References**: Doets 1989 Lemma 1.4/1.5, Thomas 1997, Rabinovich 2014 Section 5.

**Estimated effort**: 200-400 lines. The base case is straightforward (atoms). The step case is the main work: showing that the quantifier part (exists z with matching pairwise NFs) is equivalent to the actual quantifier assignment.

### Step 2: Backward Proof Using Composition

Once the composition lemma exists, the backward proof in `nf_exist_formula_nested_backward` proceeds as:

1. **Unfold formula**, case split on order direction (Until / Since / x=t)
2. **Extract witness x** from Until/Since semantics
3. **Get nf_x** from disjunct selection, **get nf_eval_nf for x** from char_kp1_correct
4. **Get atom compat, order match, t-compat** from filter conditions
5. **Quantifier part** (the h_quant argument to backward_2var_nf_agreement):
   For each ssn : NormalForm sig k 3, show `(exists y, nf_eval_nf M k 3 (y,x,t) ssn) <-> sub_nf.2 ssn = true`:
   - **sub_nf.2 ssn = true -> exists y**: The formula encodes Since(disj(char_kp1 nf_y), top) for this ssn. Extract y from Since (Prior-SZ). From char_kp1_correct, get depth-(k+1) 1-var NF of y. This records the depth-k 2-var NFs at (z,y) for all z. The filter ensures atom compat at vars 1,2. Use composition lemma to build the 3-var NF.
   - **exists y -> sub_nf.2 ssn = true**: From the y witness with nf_eval_nf M k 3 (y,x,t) ssn, extract the 2-var projections. The characteristic NF at (x,t) is sub_nf (by backward_2var_nf_agreement / nf_eval_unique). The 3-var NF projects correctly by composition.
   - **sub_nf.2 ssn = false and ssn is non-interval**: Handled by nf_full_compat_right filter (which now checks all non-interval ssn conditions).
   - **sub_nf.2 ssn = false and ssn is interval**: Need to show no y in (t,x) realizes ssn. The filter now checks interval ssn atom compat. If the atoms don't match, no witness exists. If atoms match but sub_nf.2 = false, the composition lemma + nf_eval_unique gives a contradiction.

**Estimated effort**: 150-250 lines for the backward proof body, once composition is available.

### Step 3: Downstream Closure (Phase 6)

Once backward is sorry-free, master_induction becomes sorry-free, and:
- NfCharFormula.lean:572 closes (uses `nf_2var_exist_formula_prior_fill` which extracts P2 from master_induction)
- KampPrior.lean:149 closes (uses the NfCharFormula bridge)

Verify with `lake build`.

## Key Types and Definitions

```
NormalForm sig k n : Type
  | 0, n => AtomKind sig n -> Bool
  | k+1, n => (AtomKind sig n -> Bool) × (NormalForm sig k (n+1) -> Bool)

nf_eval_nf M k n env nf : Prop  -- env satisfies nf
nf_characteristic M k n env : NormalForm sig k n  -- the unique NF satisfied by env
nf_characteristic_satisfies : nf_eval_nf M k n env (nf_characteristic M k n env)
nf_eval_unique : nf_eval_nf M k n env nf1 -> nf_eval_nf M k n env nf2 -> nf1 = nf2
```

## Key Files

| File | Role |
|------|------|
| `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` | NF definitions, nf_eval_unique |
| `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` | Formula, forward/backward, master_induction |
| `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` | Downstream sorry |
| `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` | Downstream sorry |

## Build Verification

```bash
lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure  # passes, 1 sorry warning
```

## Git State

Branch: main (ahead of origin by ~30 commits)
Latest commits:
- 72377dee8 task 273 phase 5d: backward proof outline with composition sorry
- 68c80dd5f task 273 phase 5d: strengthen interval ssn compat filter
- 2fb5bd5b2 task 273 phase 5c: apply char_{k+1} fix to formula and repair forward proof
