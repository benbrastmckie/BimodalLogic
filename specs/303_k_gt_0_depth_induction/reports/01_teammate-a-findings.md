# Teammate A Findings: Task 303 — k>0 Depth Induction for existPart_succ_n1_bypass

## Summary

The k>0 sorry in `existPart_succ_n1_bypass` (KampBypass.lean:104) is the sole
`sorryAx` blocker for `completeness_discrete`. The sorry is in the `succ k'` branch,
for `sub_nf : NormalForm sig (k'+2) 2`. The key insight: unlike the k=0 case where
3-var quantifier conditions are purely atomic, at depth k+1 those conditions involve
depth-k quantifier information — but the IH-based approach (`nf_2var_exist_formula_prior`
applied recursively) provides the necessary handle.

---

## Key Findings

### Finding 1: The Sorry Is a Pure Existential — No Composition Needed

The theorem `existPart_succ_n1_bypass` has type:

```
∃ (A : Formula), ∀ M h_UZ h_SZ t,
  (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
  (temporal_truth M atomMap t A ↔
   ∃ x : M.carrier, nf_eval_nf M (k+1) (1+1) (Fin.cons x (fun _ => t)) sub_nf)
```

This is an **existential** over formulas — it does not require constructing a specific
temporal formula, just asserting one exists. The `nf_exist_backward_prior` sorry at
NfCharFormula.lean:542 (which requires the "Prior composition property") is on the
**constructive backward direction** and lives at a different path. The bypass approach
was designed precisely to avoid needing that backward direction.

### Finding 2: The Call Chain Reveals a Circularity That Has Already Been Broken

The call from `nf_2var_exist_formula_prior` to `existPart_succ_n1_bypass`:
```
nf_2var_exist_formula_prior k+2 char_k char_k_correct
  = existPart_succ_n1_bypass (k+1) char_k char_k_correct   [NfCharFormula.lean:650]
```

But `existPart_succ_n1_bypass` takes `char_kp1 : NormalForm sig (k+1) 1 → Formula`
and `char_kp1_correct`. So the outer call supplies `char_k` for the depth-`(k+1)`
characteristic formula. Wait — let me reconcile:

- `nf_2var_exist_formula_prior` at outer depth `k` takes `char_k : NF sig k 1 → Formula`
  for depth-k 1-var NFs
- For the `k+2` branch, it calls `existPart_succ_n1_bypass (k+1) char_k ...`
  where `char_k` is depth-`k` (not depth-`k+1`)
- `existPart_succ_n1_bypass` signature takes `char_kp1 : NF sig (k+1) 1 → Formula`
  where `k+1` in the signature means the depth of `sub_nf`'s outer quantifiers

So `existPart_succ_n1_bypass (k+1) char_k` means: k parameter = k+1 in the theorem,
sub_nf : NF sig (k+2) 2, char_kp1 = char_k. The sorry branch is `succ k'`, which
handles k' ≥ 0, i.e., k ≥ 1.

### Finding 3: The Correct Approach Is Classical Existence via IH

The existing approach at `nf_2var_exist_formula_prior` depth-1 branch already shows
the pattern (NfCharFormula.lean:639–645):

```lean
| 1 =>
  exact existPart_succ_n1_bypass_k0 atomMap h_surj char_k char_k_correct
    parent_atoms sub_nf
```

For the `k+2` case, `existPart_succ_n1_bypass` is called — but **it has a sorry**.
The key question: can `existPart_succ_n1_bypass` for the `succ k'` branch use
`nf_2var_exist_formula_prior` recursively?

**The answer is yes, via classical existence.** Here is the argument:

For `sub_nf : NF sig (k'+2) 2`, the 2-var NF unfolds as:
```
(∀ a, atom_eval M [x,t] a ↔ sub_nf.1 a) ∧
(∀ ssn : NF sig (k'+1) 3, (∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn) ↔ sub_nf.2 ssn)
```

The second conjunct involves depth-(k'+1) 3-var NFs. These have a temporal
characterization for Prior structures by the IH — specifically, `nf_characterizable_temporal_prior`
gives us formulas for depth-(k'+1) 1-var NFs, and `nf_2var_exist_formula_prior` gives
formulas for depth-(k'+1) 2-var NFs. But we need 3-var NFs.

### Finding 4: The Enriched Bypass Must Generalize char_{k+1} to Cover 3-var Conditions

At k=0 (inner depth 0), the bypass formula handles the 3-var existential
`∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` by zone decomposition (since NFs at depth 0
are purely atomic). This is `depth0_3var_exist_formula_zone`.

At k>0 (inner depth k'+1), the 3-var existential `∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn`
is NOT purely atomic — it involves depth-k' quantifier conditions for 4-var NFs.

**Key structural question**: Does `nf_2var_exist_formula_prior` apply recursively to
the 3-var case?

Looking at the type of `nf_2var_exist_formula_prior`:
```
(k : Nat) → (char_k : NF sig k 1 → Formula) → (parent_atoms : AtomKind sig 1 → Bool)
  → (sub_nf : NF sig k 2) → ∃ A, ...
```

This handles **2-var** NFs, not 3-var. The enriched bypass would need a 3-var
existential formula, which is not directly provided by the existing infrastructure.

### Finding 5: The Classical Existence Proof Approach

The cleanest approach mirrors `nf_characterizable_temporal_prior_classical`
(NfCharFormula.lean:656). Given:
- `char_kp1 : NF sig (k+1) 1 → Formula` with correctness
- `sub_nf : NF sig (k+1) 2`
- Prior structure hypotheses

We want `∃ A, ∀ M h_UZ h_SZ t, h_atoms → (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M (k+1) 2 [x,t] sub_nf)`.

**Step 1**: Use `nf_characterizable_temporal_prior_classical` to get characteristic
formulas for all depth-(k+1) 1-var NFs. The `char_kp1` hypothesis provides these.

**Step 2**: The 2-var NF `sub_nf : NF sig (k+1) 2` unfolds its atom part (determines
x-t zone and predicate atoms at x and t) and its quant part (for each `ssn : NF sig k 3`,
determines whether `∃ y, nf_eval_nf M k 3 [y,x,t] ssn`).

**Step 3**: The quant part at depth k+1 involves `NF sig k 3` (depth-k, 3-var). For
Prior structures, by induction we should have temporal characterizations for these.

**Step 4**: If we have `char_ssn : NF sig k 3 → Formula` with correctness on Prior
structures (characterizing `∃ y, nf_eval_nf M k 3 [y,x,t] ssn`), then the enriched
bypass formula can use these as the "quant profile" conjuncts instead of depth-0 zone
formulas.

**The gap**: Getting `char_ssn : NF sig k 3 → Formula` for 3-var NFs requires
generalizing `nf_2var_exist_formula_prior` to multi-variable NFs, or finding another
path.

### Finding 6: The Two Sorries Are Structurally Distinct

**Sorry 1** (`existPart_succ_n1_bypass` k>0 branch, KampBypass.lean:104):
Pure existential `∃ A` — just needs to produce SOME formula.

**Sorry 2** (`nf_exist_backward_prior`, NfCharFormula.lean:542):
Constructive backward direction of `nf_exist_formula` — requires Prior composition.

These are independent. The bypass approach (Sorry 1) was designed to AVOID needing
Sorry 2. Closing Sorry 1 does NOT automatically close Sorry 2. However, Sorry 2 is
currently not on the critical path — the code at NfCharFormula.lean:634–651 routes
through `existPart_succ_n1_bypass` for depth ≥ 2, bypassing `nf_exist_backward_prior`.

### Finding 7: The Classical/Non-Constructive Strategy for k>0

The strategy that avoids the "Prior composition at depth k+1" (which Sorry 2 would need):

Given `char_kp1_correct` (IH formulas for depth-(k+1) 1-var NFs on Prior structures),
use `nf_characterizable_temporal_prior_classical` to get:
- For each `nf_x : NF sig (k+1) 1`, `char_kp1 nf_x` characterizes depth-(k+1) 1-var NFs

The enriched bypass at k>0 should:
1. Zone-dispatch on sub_nf's order atoms (same as k=0)
2. For each zone, pick the "enriched point type" using `char_kp1 nf_x` for x's 1-var type
3. For the 3-var conditions at depth k, use CLASSICAL existence again:

The key lemma needed is:
```
∀ (ssn : NF sig k 3),
  ∃ (B_ssn : Formula),
  ∀ M h_UZ h_SZ (x t : M.carrier),
    temporal_truth M atomMap x B_ssn ↔ ∃ y, nf_eval_nf M k 3 [y,x,t] ssn
```

This would generalize `nf_2var_exist_formula_prior` from 2-var to 3-var.

### Finding 8: The n-var Generalization May Already Be Provable

The existing `nf_2var_exist_formula_prior` proves the 2-var case using induction on k.
The same induction should work for 3-var:

For depth k=0: depth-0 3-var NFs are purely atomic → zone decomposition (already done
in KampBypassCore.lean via `depth0_3var_exist_formula_zone`).

For depth k+1: by IH, 3-var depth-k NFs have temporal characterizations at depth 2.
This is where the recursion bottoms out the same way.

**However**, the n-var generalization quickly runs into the issue that `nf_2var_exist_formula_prior`
characterizes EXISTENCE (`∃ x, NF[x,t]`) as a temporal formula evaluated AT t. For 3-var,
we'd need to characterize `∃ y, NF[y,x,t]` as a temporal formula evaluated AT x — which
is exactly what the bypass does but parametrized differently.

---

## Recommended Approach

### Primary Recommendation: Classical Existence via `nf_characterizable_temporal_prior_classical`

The k>0 sorry should be closed by the following argument, staying entirely within the
classical existence framework already established:

**Step 1** (NF decomposition): For `sub_nf : NF sig (k'+2) 2`, unfold the 2-var NF at
depth k'+2. The atom part is `sub_nf.1 : AtomKind sig 2 → Bool`, which determines:
- Predicate values at x (matching x's 1-var NF)
- Predicate values at t (must match `parent_atoms`)
- x-t order direction (zone dispatch)

**Step 2** (Zone dispatch): Same as k=0 — match on order atoms to get Until/Since/Eq.

**Step 3** (Enriched point type at x): For each compatible `nf_x : NF sig (k'+2) 1`,
use `char_kp1 nf_x` as x's characteristic formula. This works because `char_kp1_correct`
gives us the correct biconditional.

**Step 4** (Quant profile): The quant part `sub_nf.2 : NF sig (k'+1) 3 → Bool` requires
for each `ssn : NF sig (k'+1) 3`, a temporal formula characterizing `∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn`.

At k'+1 > 0, this 3-var existential involves depth-k' conditions for 4-var NFs.
But for the CLASSICAL existence proof, we don't need to construct this formula — we
just need it to exist for Prior structures.

**Step 5** (Classical choice): By `nf_characterizable_temporal_prior_classical` applied
at depth k'+1 with n=3... but that theorem only handles 1-var NFs. The bridge is:

The `nf_2var_exist_formula_prior` at depth k'+1 (which is the outer recursion's IH)
says: for each `ssn' : NF sig (k'+1) 2`, there exists a formula characterizing
`∃ x, NF (k'+1) 2 [x,t] ssn'`. But we need 3-var.

**Alternative via induction parameter**: The theorem `existPart_succ_n1_bypass`
takes `k : Nat` and receives `char_kp1 : NF sig (k+1) 1 → Formula`. At the sorry
site, `k = succ k'`. The IH available from the `cases k` is that
`existPart_succ_n1_bypass_k0` handles k=0. For k>0, we need to invoke
`nf_2var_exist_formula_prior` at depth k'+1 recursively, but for 3 variables.

### Alternative: Prove an n-var Classical Existence Lemma

Define a lemma:
```lean
theorem nf_nvar_exist_formula_prior
    (k n : Nat) (char_k : NF sig k 1 → Formula) (char_k_correct : ...)
    (env_atoms : ...) (sub_nf : NF sig k (n+1)) :
    ∃ (A : Formula),
      ∀ M h_UZ h_SZ (env : Fin n → M.carrier),
        temporal_truth M atomMap (env 0) A ↔
        ∃ x, nf_eval_nf M k (n+1) (Fin.cons x env) sub_nf
```

This n-var version proves the 2-var case (n=1) as the base and the 3-var case (n=2)
as the inductive step. The 3-var case can then feed into the enriched bypass construction.

However, this n-var lemma is HARDER to prove than 2-var because the evaluation point
in temporal truth shifts with n.

### Most Feasible Approach: Use `Classical.choice` on the Outer Induction

Given that `nf_characterizable_temporal_prior_classical` already proves characterizability
at all depths using Classical.choose, and the IH gives us `char_kp1` formulas at depth k+1,
the k>0 case can be proved by:

1. Asserting CLASSICALLY that for any Prior structure M, the predicate
   `∃ x, nf_eval_nf M (k+1) 2 [x,t] sub_nf` is TL-definable on Prior structures
2. Using `nf_characterizable_temporal_prior_classical` as a template to run the
   same argument at depth k+1 with the outer dimension fixed

Concretely, the proof at KampBypass.lean:104 can be:

```lean
| succ k' =>
  -- Use the classical existence argument from nf_characterizable_temporal_prior_classical
  -- The outer IH (char_kp1 at depth k'+2) gives characteristic formulas for 1-var NFs.
  -- We need to show: ∃ A, temporal_truth ↔ ∃ x, NF (k'+2) 2 [x,t] sub_nf
  --
  -- Strategy: apply nf_2var_exist_formula_prior at depth (k'+2), feeding char_kp1_correct
  -- But nf_2var_exist_formula_prior at depth k'+2 itself calls existPart_succ_n1_bypass (k'+1)...
  -- which would be recursive on a smaller index! This is the induction.
  --
  -- The recursion: existPart_succ_n1_bypass k' already handles depth k'+1 (smaller).
  -- If we had a proof of existPart_succ_n1_bypass k' (by strong induction), we could use it.
  ...
```

This suggests the sorry can be closed by **strong induction on k**, using the
depth-(k'+1) case to handle the inner 3-var existentials at depth k'.

---

## Evidence/Examples

### The `nf_2var_exist_formula_prior` dispatch (NfCharFormula.lean:634–651)
```lean
match k with
| 0 => -- depth-0: VecEA2-based decomposition (sorry-free)
| 1 => exact existPart_succ_n1_bypass_k0 ...  -- handles k=0 case
| k + 2 => exact existPart_succ_n1_bypass ... (k + 1) ...  -- calls sorry branch
```

This means: when the outer depth is k+2 ≥ 2, it calls `existPart_succ_n1_bypass (k+1)`.
The k+1 ≥ 1 lands in the sorry branch. **The sorry in KampBypass.lean:104 IS the
k>0 branch being called here**.

### The enriched bypass at k=0 uses depth-0 3-var zone formulas (KampBypassCore.lean:146–182)
```lean
noncomputable def quant_profile_conj_depth0 ...
    (sub_nf : NormalForm sig 1 2) ...
  formula_conjList
    ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn ... then
        let phi := depth0_3var_exist_formula_v1 atomMap h_surj ssn
        ...
```

At k=0, the 3-var NFs iterated are `NF sig 0 3` (depth 0). At k>0, they would be
`NF sig k 3` (depth k). The generalization requires `depth_k_3var_exist_formula` which
does not yet exist in the codebase.

### The NfComposition.lean note on why generalized_composition fails (line 22–36)
This explains why the "Prior composition property" is NOT trivially available: the
counterexample with M = (Z, <) shows that 1-var NF agreement does NOT imply 2-var NF
agreement. This confirms that `nf_exist_backward_prior` (Sorry 2) genuinely requires
additional Prior-specific structure. The bypass approach (Sorry 1) is correct to avoid this.

---

## Confidence Level: **High**

The architecture is clear. The sorry at KampBypass.lean:104 needs to:
1. Produce a temporal formula (classical existence suffices)
2. For `sub_nf : NF sig (k'+2) 2`, prove the biconditional on Prior structures
3. The key difficulty is the 3-var depth-(k'+1) existential in the quant part

**Recommended implementation path**:

Option A (Inductive): Strengthen the theorem to use strong induction on k, proving
`existPart_succ_n1_bypass k` for all k simultaneously by using the k-1 case to handle
inner 3-var existentials. The k=0 base is already done (`existPart_succ_n1_bypass_k0`).

Option B (Classical shortcut): Apply `nf_characterizable_temporal_prior_classical` at
depth k'+2 directly to get a formula for the full 1-var NF. Then use `nf_2var_exist_formula_prior`
to get the 2-var existence formula. But this is circular — `nf_2var_exist_formula_prior`
at depth k'+2 CALLS `existPart_succ_n1_bypass (k'+1)`.

**The inductive approach (Option A) is the correct one**:

The proof should restructure `existPart_succ_n1_bypass` to use the IH from a recursive
call. In the `succ k'` branch, we have access to all the same hypotheses as the k=0 case,
but now:
- `char_kp1 : NF sig (k'+2) 1 → Formula` (depth k'+2)
- `sub_nf : NF sig (k'+2) 2`
- Inner quant conditions: `∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn`

The recursive call would be to `existPart_succ_n1_bypass k'` with:
- `char_k' : NF sig (k'+1) 1 → Formula` (depth k'+1) — obtained from IH
- But we need depth-(k'+2) formulas for x, not depth-(k'+1)

This suggests a mismatch: the recursion on `existPart_succ_n1_bypass` shifts the
depth by 1 each time, but the quant conditions involve a 3-var NF at the SAME outer
depth minus 1. The correct induction is:

For `existPart_succ_n1_bypass k'` where `sub_nf : NF sig (k'+1) 2`, the quant conditions
involve `∃ y, nf_eval_nf M k' 3 [y,x,t] ssn`. These need to be handled by depth-k'
3-var formulas. The bypass for depth k' uses char_k' for x's 1-var type and (recursively)
depth-(k'-1) 3-var formulas. This is a **well-founded recursion on k**.

**Estimated implementation**: 200-400 lines across 1-2 new helper definitions and
the corrected `succ k'` branch. The definitional work is:
1. `depthk_3var_exist_formula`: generalize `depth0_3var_exist_formula_zone` to depth k
2. `enriched_bypass_formula_depthk`: parametric version of the bypass formula
3. Correctness proofs for each direction

---

## Relationship to Task Description

The task description says "interval-splitting induction" from Rabinovich Section 5 Lemma 5.1.
This is consistent with the inductive approach above:
- At each depth k, x serves as the insertion point
- The interval [t, x] (or [x, t]) is split by y's position
- The 3-var existential at depth k-1 is handled by induction

The "k=0 infrastructure as template" is accurate — the generalization replaces
`depth0_3var_exist_formula_zone` (purely atomic) with a recursive call to depth-(k-1)
characterization formulas.

The "Prior composition property" (Sorry 2 / `nf_exist_backward_prior`) is NOT needed
for the bypass approach, confirming the bypass design is sound.
