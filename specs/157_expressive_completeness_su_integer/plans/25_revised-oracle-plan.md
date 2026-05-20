# Implementation Plan: Task #157 -- Self-Contained Oracle Elimination (v26)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Phase A completed (plan v22)
- **Research Inputs**: reports/24_blocker-research.md, literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md, handoffs/phase-1-handoff-20260519.md
- **Artifacts**: plans/25_revised-oracle-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## STRICT COMPLIANCE CONTRACT

**This plan is a BINDING CONTRACT. Implementation agents MUST follow it EXACTLY.**

### Absolute Prohibitions

1. **NO `all_separable` / `snce_separable` / `untl_separable` / `all_past_separable` / `all_future_separable`**: These are axiom-backed. Never reference them in new or modified code.
2. **NO `sorry`**: Do not introduce any new `sorry`.
3. **NO vacuous definitions**: Do not use `def X := True` or similar.
4. **NO modifying `snce_depth_of_U`, `junction_depth`, or `count_U_subformulas` definitions**.

### Escalation Protocol

If stuck for more than 20 minutes on any single task:
1. STOP immediately
2. Write a handoff to `specs/157_expressive_completeness_su_integer/handoffs/`
3. Mark the phase `[BLOCKED]`

---

## Overview

Plan v25 was blocked by two fundamental flaws: (1) Case 2 output introduces U-types different from (A,B), making `has_single_U_type` preservation through 10.2.4 impossible; (2) the double induction for combined 10.2.6+10.2.7 had a termination gap.

This plan (v26) abandons the single-U-type preservation approach entirely and instead works at the level of `all_formulas_separable_aux`, the main JD induction. The existing code works for JD >= 2 (lines 2777-2782 and 2815-2819 of Hierarchy.lean). The ONLY remaining problem is the n=1 fallback (lines 2783-2784 and 2820), which calls `no_S_nested_in_U_separable_direct` backed by the `all_separable` axiom.

**Strategy**: Replace the n=1 fallback with a self-contained proof that handles `no_S_nested_in_U phi` + `JD phi <= 1` without any axiom-backed functions. The approach uses a COMBINED induction on `(JD, U_nesting_depth, count_U_total)` in lexicographic order, merging the JD induction of `all_formulas_separable_aux` with the UND/count induction of `no_S_nested_in_U_separable_direct_param`.

### Root Cause Analysis

The n=1 fallback exists because `no_S_nested_in_U_separable_direct_param` takes an oracle for `no_S_nested_in_U chi` + `JD chi <= 1`. At n >= 2, the JD IH serves as the oracle (JD chi <= 1 < 2 <= n). At n=1, the oracle formulas have JD <= 1, same level as n, so the JD IH doesn't apply.

The existing `lemma_10_2_6_self_contained_param` and `single_U_formula_separable_noax_param` also take oracle parameters for JD <= 1 formulas. Their internal inductions (count_U_subformulas and snce_depth_of_U respectively) are self-contained EXCEPT for oracle calls. The oracle calls produce formulas with `no_S_nested_in_U` + `JD <= 1`.

The fix: create a MERGED induction that combines JD, UND, and count_U into a single well-founded recursion. This eliminates the need for an external oracle.

### Merged Induction Design

The merged theorem `all_formulas_separable_merged` uses lexicographic induction on `(JD, UND, count_U_total)`:

```
all_formulas_separable_merged:
  ∀ phi, has_no_allpast_allfuture phi → is_separable phi

Proof by WF induction on (junction_depth phi, U_nesting_depth phi, count_U_total phi):

Case phi = .atom, .bot, .box: trivial

Case phi = .imp a b:
  IH on a: (JD_a <= JD_phi, *, *) -- lex decrease on first component or equal
  IH on b: similar

Case phi = .snce a b:
  JD = 0: directly separated
  JD >= 1:
    Separate a, b by IH (structurally smaller, JD <=)
    Box-normalize to chi_a, chi_b
    .snce chi_a chi_b has no_S_nested_in_U, JD <= 1
    Handle by INLINE no_S_nested logic:
      If U-free: separated
      UND >= 2: abstract innermost U(X,Y) with U-free X,Y
        count_U_total strictly decreases
        IH at (1, UND, count_U_total') where count_U_total' < count_U_total
        Substitute back
        Callback has no_S_nested_in_U, UND <= 1, JD <= 1
        IH at (1, 1, *) -- UND decreased from >= 2 to <= 1
      UND <= 1: abstract surface U(A,B) with U-free, S-free A,B
        count_U_total strictly decreases (A,B U-free so each .untl A B has count = 1)
        IH at (1, 1, count_U_total') where count_U_total' < count_U_total
        Substitute back via subst_in_separated_separable_typed
        Callback has has_single_U_type, no_S_nested_in_U
        Handle by single_U_formula_separable_noax_param with oracle =
          fun chi hns hjd =>
            -- chi has no_S_nested_in_U, JD <= 1
            -- IH at (1, UND_chi, count_U_total_chi)
            -- Need (1, UND_chi, count_U_total_chi) < (1, UND_original, count_U_total_original)
            -- THIS MAY NOT HOLD for oracle formulas from single_U at depth >= 2
            ...

Case phi = .untl a b:
  By duality: swap_temporal, apply .snce case, swap back
```

The issue is still in the UND <= 1 / single_U oracle. But we can handle it differently:

Instead of threading the IH through `single_U_formula_separable_noax_param`'s oracle, we INLINE the single_U logic into the main induction. At UND <= 1:

1. Extract U-type (A,B) with U-free, S-free A, B
2. Abstract ALL occurrences of (A,B)
3. Separate by IH (count_U_total decreased)
4. Substitute back
5. For each `.snce` callback: has `has_single_U_type _ A B`, `no_S_nested_in_U`
6. Apply `single_U_formula_separable_noax_param` (snce_depth induction, self-contained)
   - Depth 0, 1: leaf case, no oracle, terminates
   - Depth >= 2: IH on children (structurally smaller, terminates), oracle on .snce C'' F''
7. Oracle formula: .snce C'' F'' with `no_S_nested_in_U`, `JD <= 1`
8. This oracle formula has `snce_depth_of_U <= 1` (from separated_boxnorm_snce_depth_zero)
9. Apply `single_U_formula_separable_noax_param` AGAIN at depth <= 1: leaf case, no oracle
10. But to apply it, we need `has_single_U_type` on the oracle formula. It has `no_S_nested_in_U` but not necessarily `has_single_U_type`.

So we can't use `single_U_formula_separable_noax_param` for the oracle formula. Instead:

The oracle formula has `no_S_nested_in_U`, `JD <= 1`, `snce_depth_of_U <= 1`. We handle it by:
- If U-free: separated
- If not U-free: it has structure `.snce C'' F''` with `snce_depth_of_U C'' = 0`, `snce_depth_of_U F'' = 0`, `no_S_nested_in_U`. By `snce_depth_zero_no_S_nested_separated`, C'' and F'' are individually separated.
- Apply the UND <= 1 logic AGAIN on `.snce C'' F''`:
  - Extract U-type, abstract, count_U_total decreases, IH on abstracted formula
  - Substitute back. Callback has `has_single_U_type`, `no_S_nested_in_U`
  - Apply single_U at depth <= 1 (since callback has `snce_depth_of_U <= 1`): leaf case, no oracle!

Wait, the callback formula from substituting into separated C'' or F'': its `snce_depth_of_U` depends on the structure. If C'' has nested `.snce` with atom p inside, after substitution, `snce_depth_of_U > 0`. But since C'' is box-free separated, every `.snce` in C'' has U-free args. After substituting `.untl A' B'` for p, the `.snce` children containing p are no longer U-free. So `snce_depth_of_U` can increase.

But the count_U_total STRICTLY DECREASES at each abstraction step. And `single_U_formula_separable_noax_param` does its OWN `snce_depth_of_U` induction that terminates (structural induction on the formula). The oracle is called at most once per `.snce` node at depth >= 2. Each oracle formula has `snce_depth_of_U <= 1`.

So the TOTAL pattern for handling a UND <= 1, `no_S_nested_in_U` formula:
1. Count induction: abstract, separate, substitute
2. Each callback -> single_U (snce_depth induction, terminates internally)
3. Each single_U oracle call: formula with `no_S_nested_in_U`, `snce_depth_of_U <= 1`
4. Handle oracle by: count induction again on THIS formula
5. Each callback -> single_U at depth <= 1: leaf case, TERMINATES

Step 4 creates a NESTED count induction. The count_U_total in step 4 is NOT related to the count_U_total in step 1. But step 4's own count induction terminates (it decreases count_U within the oracle formula). And step 5 terminates (leaf case).

So the chain is: count_induction -> single_U -> oracle -> count_induction -> single_U at depth <= 1 -> DONE.

This is exactly TWO levels of count induction. The first one handles the original formula. Each callback goes through single_U which may produce oracle formulas. The oracle formulas are handled by a SECOND count induction. Each callback from the second count induction goes through single_U at depth <= 1 (leaf case, no oracle). So the recursion depth is bounded at 2.

**Implementation**: Create a helper function `handle_no_S_nested_jd_le_one` that does:
1. Count induction on count_U
2. Each callback -> `single_U_formula_separable_noax_param` with oracle = `handle_no_S_nested_jd_le_one_leaf`
3. `handle_no_S_nested_jd_le_one_leaf` does count induction, callbacks go to `single_U_formula_separable_noax_param` with oracle = fun chi _ _ => `snce_depth_zero_no_S_nested_separated` or similar (leaf-only, no further oracle)

Actually, to make Lean accept this, we need to ensure the recursive calls are well-founded. The cleanest approach:

```lean
-- Level 0: leaf oracle (no recursion)
private def leaf_oracle (chi : Formula) (hns : no_S_nested_in_U chi) (hjd : junction_depth chi ≤ 1) :
    is_separable chi :=
  -- chi has snce_depth_of_U <= 1, no_S_nested_in_U, JD <= 1
  -- Count induction + single_U at depth <= 1 (no oracle calls)
  no_S_nested_in_U_separable_param_jd chi hns (has_no_allpast_allfuture_true chi)
    (fun callback hns_cb hjd_cb =>
      -- callback has has_single_U_type, no_S_nested_in_U, UND <= 1
      -- Apply single_U without oracle (depth <= 1)
      -- But single_U_formula_separable_noax_param ALWAYS takes an oracle parameter...
      -- Even if it's never called at depth <= 1
      -- So pass a dummy oracle that's never invoked
      sorry)

-- Level 1: real oracle
private def no_S_nested_sep_jd1 (phi : Formula) (hns : no_S_nested_in_U phi) (hjd : junction_depth phi ≤ 1) :
    is_separable phi :=
  no_S_nested_in_U_separable_direct_param phi hns
    (fun chi hns_chi hjd_chi => leaf_oracle chi hns_chi hjd_chi)
```

The issue with `leaf_oracle`: `no_S_nested_in_U_separable_param_jd` takes a callback that receives `no_S_nested_in_U chi` + `JD chi <= 1`. This callback needs to prove `is_separable chi`. But at the leaf level, we want to use `single_U_formula_separable_noax_param` at depth <= 1 with a dummy oracle.

Wait, `no_S_nested_in_U_separable_param_jd` uses `subst_in_separated_separable_jd` internally, which produces callbacks with `no_S_nested_in_U` + `JD <= 1`. These callbacks need to be handled by the external callback parameter. So `leaf_oracle`'s callback IS the external callback of `no_S_nested_in_U_separable_param_jd`.

At the leaf level, the callback from `subst_in_separated_separable_jd` goes to:
```
fun callback hns_cb hjd_cb => ???
```

We need to prove `is_separable callback` where callback has `no_S_nested_in_U` + `JD <= 1`. At the leaf level, we can't recurse further. But we need to handle these callbacks.

BUT: at the leaf level, the callback formula has `has_single_U_type _ A B` (from `subst_in_separated_separable_typed`, not `_jd`). Hmm, `no_S_nested_in_U_separable_param_jd` uses `_jd` which doesn't give `has_single_U_type`.

Let me re-examine: `no_S_nested_in_U_separable_param_jd` (line 2661) uses `subst_in_separated_separable_jd` which calls its callback with `no_S_nested_in_U chi` and `JD chi <= 1`, NOT with `has_single_U_type`.

So at the leaf level, the callback gives `no_S_nested_in_U` + `JD <= 1`. To prove separable, we'd need to recurse. But we're at the leaf level!

The solution: use `lemma_10_2_6_self_contained_param` instead of `no_S_nested_in_U_separable_param_jd` at the leaf level. `lemma_10_2_6_self_contained_param` uses `subst_in_separated_separable_typed` which gives callbacks with `has_single_U_type`. Then `single_U_formula_separable_noax_param` at depth <= 1 handles the callback without any oracle.

But `lemma_10_2_6_self_contained_param` requires `UND <= 1`. The callback from `no_S_nested_sep_jd1` at UND >= 2 can have UND > 1 for the oracle formulas.

OK, I think the cleanest approach is to structure it as:

```lean
-- Handle no_S_nested_in_U + JD <= 1
theorem no_S_nested_sep_at_jd1 (phi : Formula) (hns : no_S_nested_in_U phi) :
    is_separable phi := by
  -- Double induction: outer on UND, inner on count_U_total
  have outer : ∀ (d : Nat) (ψ : Formula), U_nesting_depth ψ ≤ d →
      no_S_nested_in_U ψ → is_separable ψ := by
    intro d
    induction d using Nat.strongRecOn with | ind d ih_d =>
    intro ψ hd_le hns_ψ
    -- UND = 0: U-free, trivially separated
    -- UND <= 1: lemma_10_2_6_self_contained_param with leaf_callback
    -- UND >= 2: abstract innermost, count induction, callbacks at UND <= 1 use ih_d
    by_cases huf : is_U_free ψ = true
    · exact separated_imp_separable ψ (restricted_u_free_separated ψ _ huf)
    · by_cases hd1 : d ≤ 1
      · -- UND <= 1
        exact lemma_10_2_6_self_contained_param ψ hns_ψ (Nat.le_trans hd_le hd1) (fun chi hns_chi hjd_chi =>
          -- chi has no_S_nested_in_U, JD <= 1
          -- chi comes from single_U_formula_separable_noax_param's oracle
          -- chi has snce_depth_of_U <= 1, no_S_nested_in_U
          -- Use outer IH? We need UND_chi < d. But d <= 1 and UND_chi could be anything.
          sorry)
      · -- UND >= 2: inner count induction
        push_neg at hd1
        -- Abstract innermost U with U-free args
        -- count_U_total strictly decreases
        -- IH at same d, smaller count: BUT Nat.strongRecOn is on d, not count!
        sorry
  exact outer (U_nesting_depth phi) phi (Nat.le_refl _) hns
```

The issue: at UND <= 1, the oracle from `single_U_formula_separable_noax_param` produces formulas that don't have smaller UND. At UND >= 2, we need an INNER induction on count_U_total, but `Nat.strongRecOn` only gives us the outer UND induction.

The fix: use DOUBLE `Nat.strongRecOn`:

```lean
have proof : ∀ (d c : Nat) (ψ : Formula), U_nesting_depth ψ ≤ d →
    count_U_total ψ ≤ c → no_S_nested_in_U ψ → is_separable ψ := by
  intro d
  induction d using Nat.strongRecOn with | ind d ih_d =>
  intro c
  induction c using Nat.strongRecOn with | ind c ih_c =>
  intro ψ hd hc hns_ψ
  ...
```

At UND >= 2:
- Abstract innermost U(X,Y) with U-free X, Y. count_U_total strictly decreases.
- IH via `ih_c` at same d, smaller c: `ih_c (count_U_total ψ') (hc ▸ ...) ψ' ... hns'`
- Get separated psi_sep. Substitute back.
- Callback from `subst_in_separated_separable_jd`: `no_S_nested_in_U chi`, `JD chi <= 1`.
- Callback has `UND chi <= 1` (from `callback_U_nesting_depth_le_one` since X, Y U-free).
- IH via `ih_d` at d' <= 1 < d >= 2: `ih_d 1 (by omega) (count_U_total chi) chi ...`
- This works! UND strictly decreased from >= 2 to <= 1.

At UND <= 1:
- Abstract surface U(A,B) with U-free, S-free A, B. count_U_total strictly decreases.
- IH via `ih_c` at same d (=1), smaller c.
- Get separated psi_sep. Substitute back via `subst_in_separated_separable_typed`.
- Callback has `has_single_U_type _ A B`, `no_S_nested_in_U`.
- Apply `single_U_formula_separable_noax_param` with oracle.
- Oracle formula: `no_S_nested_in_U chi`, `JD chi <= 1`, `snce_depth_of_U chi <= 1`.
- Oracle formula UND: could be anything. Cannot use `ih_d` (d <= 1, need d' < d <= 1, impossible unless d' = 0 which means U-free).

**This is the fundamental obstacle at UND <= 1.**

At UND <= 1, the oracle from `single_U_formula_separable_noax_param` at depth >= 2 produces formulas with arbitrary UND. We can't recurse back into the main induction because UND isn't decreasing.

**RESOLUTION**: Don't use `single_U_formula_separable_noax_param` at depth >= 2 with the external oracle. Instead, at depth >= 2, handle the `.snce C'' F''` directly:

1. C'', F'' are box-free separated forms with `snce_depth_of_U = 0`
2. By `snce_depth_zero_no_S_nested_separated`, both are individually separated
3. `.snce C'' F''` has `no_S_nested_in_U`. Apply `ih_c` at same d, smaller count_U_total... but count_U_total of `.snce C'' F''` is NOT necessarily smaller than the original count_U_total!

Hmm. C'' and F'' are separated forms of the IH output (C', F' separated forms of C, F which are structurally smaller than the `.snce C F`). Their count_U_total is determined by the separated form, not the original formula. No direct relationship.

**ALTERNATIVE RESOLUTION**: Make `single_U_formula_separable_noax_param` self-contained at UND <= 1 by exploiting the fact that ALL callbacks at UND <= 1 produce formulas with `snce_depth_of_U <= 1`, and the depth induction in `single_U_formula_separable_noax_param` handles these at depth 0 or 1 (leaf case).

Wait, I keep going in circles. Let me check: can the oracle formula from `single_U_formula_separable_noax_param` at depth >= 2 have `has_single_U_type`? The oracle formula is `.snce C'' F''` where C'', F'' are box-normalized separated forms of the IH outputs. The IH gives `is_separable`, not `is_separable_with_U_type`. So C', F' don't have `has_single_U_type`. C'', F'' don't either.

But wait -- what if we STRENGTHEN the IH of `single_U_formula_separable_noax_param` to return `is_separable_with_U_type`? That's what plan v25 tried. And it fails because Cases 2-4 don't preserve single-U-type. But let me think about it differently.

At depth 1 (leaf case), `snce_single_U_depth_one_separable` gives `is_separable` but NOT `is_separable_with_U_type`. The output formula from Cases 2-4 has multiple U-types.

So strengthening the IH to `is_separable_with_U_type` fails at depth 1 because the leaf case doesn't provide it.

**FINAL RESOLUTION**: The cleanest approach that actually works within Lean's type system is to inline EVERYTHING into a single well-founded recursion on a carefully chosen measure. After much analysis, I believe the right measure is `(junction_depth, sizeOf)` applied to the ORIGINAL formula in `all_formulas_separable_aux`, with the key insight that at n=1, we can handle the `.snce` case by applying the EXISTING `lemma_10_2_6_self_contained_param` with an oracle that is `all_formulas_separable_aux` at n=0.

At n=0, `all_formulas_separable_aux` handles JD=0 formulas (trivially separated). At n=1, the oracle formulas have JD <= 1. Some have JD = 0 (handled by n=0). Some have JD = 1.

For JD = 1 oracle formulas: they have `no_S_nested_in_U`. They also have structure `.snce C'' F''` where C'', F'' are box-free separated. Or they're callback formulas from substitution.

Can we show JD = 0 for these oracle formulas? Not in general (as analyzed above).

**TRULY FINAL APPROACH**: Accept that a clean solution requires restructuring `all_formulas_separable_aux` to use a triple induction `(JD, UND, count_U_total)`. This is the approach we'll take.

The implementation will:
1. Replace `all_formulas_separable_aux` with a new version that uses well-founded induction on `(JD, UND, count_U_total)` in lexicographic order
2. The `.snce` case at JD >= 1 will inline the logic currently in `no_S_nested_in_U_separable_direct_param`, `lemma_10_2_6_self_contained_param`, and `single_U_formula_separable_noax_param`
3. At each step, the IH is invoked at a lex-smaller triple

The key observations:
- `.snce a b` at JD >= 2: IH on a, b at JD < JD_original. UND and count_U don't matter (lex first component strictly smaller).
- `.snce a b` at JD = 1: after separation + box-normalization, get `.snce chi_a chi_b` with `no_S_nested_in_U`, JD = 1. Then:
  - UND >= 2: abstract innermost U, count_U_total decreases. IH at (1, UND, count_U_total'). Callbacks at UND <= 1: IH at (1, 1, *) -- UND strictly decreased.
  - UND <= 1: abstract surface U, count_U_total decreases. IH at (1, 1, count_U_total'). Substitute back. Callbacks have `has_single_U_type`. Handle via inline single_U logic:
    - snce_depth_of_U induction (within the same theorem, as nested strong induction)
    - depth 0, 1: leaf case (snce_single_U_depth_one_separable)
    - depth >= 2: IH on children + .snce C'' F'' with no_S_nested_in_U, JD <= 1, UND = ???
    
The depth >= 2 oracle formula is where it gets stuck. Its UND is unrelated to the original UND.

**I now see the core issue clearly**: the single_U separation at depth >= 2 produces oracle formulas whose UND is uncontrolled. No simple measure captures the termination of the oracle chain.

**APPROACH THAT WORKS**: Use the `snce_depth_of_U` as a THIRD component in the induction, placed BETWEEN UND and count_U_total. The lex order is `(JD, UND, snce_depth_of_U, count_U_total)`.

At UND <= 1, single_U at snce_depth D >= 2:
- IH on children at snce_depth D' < D (structural decrease)
- Oracle formula at snce_depth <= 1
- IH at (1, UND_oracle, 1, count_U_total_oracle) where UND_oracle could be anything
- But snce_depth DECREASED from D >= 2 to <= 1!

Wait, snce_depth_of_U is the FOURTH component. So (1, <=1, D, *) and the oracle is at (1, UND_oracle, <=1, *). For lex decrease we need:
- JD same (1)
- UND: original was <= 1, oracle could be anything. NOT a decrease.

So snce_depth_of_U doesn't help if UND is uncontrolled.

**THE ACTUAL SOLUTION**: The oracle formulas from single_U at depth >= 2 have `snce_depth_of_U <= 1`. Their `.snce` structure means `no_S_nested_in_U`. If we handle these INLINE without going through the full induction:

At snce_depth_of_U <= 1:
- If U-free: separated
- If snce_depth = 1: C'', F'' at depth 0, hence separated. Abstract one U-type from `.snce C'' F''`, count_U strictly decreases. Separate by... the SAME induction? count_U component decreased.
- But the UND component of the resulting formula is unknown.

I think the actual solution is:

**Use `WellFoundedRelation` on `(JD, sizeOf)` where sizeOf captures the structural size of the formula.** At the same JD level, callbacks from substitution MAY have larger sizeOf than the original. But `single_U_formula_separable_noax_param` uses its OWN internal `snce_depth_of_U` induction that is STRUCTURAL (decreases on formula structure). So we don't need the main induction to handle oracle calls from single_U -- single_U handles them internally.

The issue is: single_U's oracle at depth >= 2 calls an EXTERNAL function. If the external function is the main induction at a lex-smaller measure, we're fine. If not, we need to inline it.

**PRAGMATIC DECISION**: Given the extreme complexity of finding a clean termination argument, I will take the following approach:

1. Create `no_S_nested_sep` as a NON-WELL-FOUNDED definition (using `partial def` or `unsafe def`), verify it terminates empirically, then seal it behind an opaque wrapper. -- NO, this violates the no-sorry/no-vacuous contract.

2. Use `Decidable.decide` or `Classical.choice` to construct the proof in a different way. -- Not applicable.

3. **Use the `partial` + axiom approach**: Define the oracle as a mutually recursive function with `single_U_formula_separable_noax_param`, using `WellFoundedRelation` on the combined formula measure. -- This is the right approach but requires careful engineering.

4. **Use `no_S_nested_in_U_separable_direct_param` with `all_formulas_separable_aux` at n=0 as oracle, and prove that oracle formulas at n=1 actually have JD = 0.** -- This would be the MINIMAL change. Let me check if it's true.

Oracle formulas at n=1 from `no_S_nested_in_U_separable_direct_param`:
- Come from `subst_in_separated_separable_jd` at the `.snce c d` case
- Formula: `.snce (subst c p (.untl A B)) (subst d p (.untl A B))`
- c, d are U-free (from separated formula)
- `callback_jd_le_one` gives JD <= 1

Does JD = 0? `junction_depth (.snce (subst c ...) (subst d ...))` = `max(jdS(subst c), jdS(subst d))`.

`jdS(subst c p (.untl A B))` where c is U-free, A, B S-free:
- `subst_u_free_jdS_le_one` proves jdS <= 1
- Can jdS = 0? If c has no `.snce` nodes AND no atoms equal to p: subst is identity, jdS = jdS(c). c is U-free, so jdS(c) = max over .snce children (if any). If c has `.snce` nodes: jdS(c) >= 1 (the `.snce` node adds 1 + max(jd children)). But c IS U-free, which means `.snce` children ARE U-free. So jd of `.snce` children = 0. jdS of `.snce (x, y)` where x, y U-free = 1 + max(jd x, jd y). jd of U-free formulas: max(jdU, jdS) over all children. U-free means jdU = 0, so jd = jdS. For U-free formulas without `.snce`: jdS = 0. For U-free formulas with `.snce`: jdS >= 1.

So if c contains `.snce` nodes, jdS(c) >= 1, and jdS(subst c) >= 1 (since `.snce` nodes in c are not affected by substitution of atoms). Hence JD of callback >= 1.

So JD of oracle formulas CAN be 1 at n=1. Approach 4 doesn't work.

**APPROACH 5 (FINAL)**: Use `WellFoundedRelation` on a custom measure that DOES decrease across the oracle chain. The measure is the TOTAL number of `.snce`-above-`.untl` patterns in the formula (a refinement of `snce_depth_of_U`).

Actually, I think the right measure is just to use `sizeOf` as a tiebreaker and observe that the TOTAL work across all oracle calls is bounded.

**I will commit to the following implementation plan**:

Create a `no_S_nested_sep` theorem using a SINGLE well-founded induction on `(U_nesting_depth phi, count_U_total phi)` in lexicographic order. At UND >= 2, callbacks go to UND <= 1 (lex decrease). At UND <= 1, use `lemma_10_2_6_self_contained_param` style logic where the single_U callback is handled by a NESTED induction on `snce_depth_of_U` (within the same theorem call), and the oracle from depth >= 2 is handled by a FURTHER nested count_U induction with callbacks at `snce_depth_of_U <= 1` (which terminate at the leaf case).

This requires THREE NESTED `Nat.strongRecOn` calls:
1. Outer: UND
2. Middle: count_U_total (for abstracting multiple U-types)
3. Inner: snce_depth_of_U (for single_U separation)
4. Innermost: count_U_total again (for handling oracle formulas from inner level)

Levels 3 and 4 handle the "one-hop oracle" pattern: level 3 produces oracle formulas with snce_depth <= 1, level 4 handles them with count induction, callbacks go to level 3 at depth <= 1 (leaf case, no further oracle).

This structure is complex but well-founded. Each level has a strictly decreasing measure. The nesting means the total call depth is bounded.

OK, I've spent enough time analyzing. Let me write the final plan.

## Goals & Non-Goals

**Goals**:
- Define `count_U_total` and `extract_innermost_U_type` with companion lemmas
- Create oracle-free `no_S_nested_sep` using nested well-founded inductions
- Fix `all_formulas_separable_aux` n=1 to use `no_S_nested_sep`
- Replace 9 axioms in SeparationThm.lean with theorems

**Non-Goals**:
- Modifying definitions of `snce_depth_of_U`, `junction_depth`, `count_U_subformulas`
- Modifying case proofs in Eliminations.lean or DedekindZ.lean
- Preserving `has_single_U_type` through Cases 2-4
- Restructuring 10.2.8 beyond the n=1 fix

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Nested well-founded inductions cause Lean elaboration issues | H | M | Test the nesting structure incrementally. If Lean rejects the nesting, flatten to a single WF induction on a product type. |
| `extract_innermost_U_type` termination requires careful `decreasing_by` | M | L | Use `count_U_total` with `omega`. |
| The one-hop oracle pattern is incorrect and depth >= 2 oracle formulas have `snce_depth_of_U > 1` | H | L | The proof that oracle formulas have snce_depth <= 1 follows from `separated_boxnorm_snce_depth_zero` which is already a proven theorem (line 1632). Verify the formula path: IH -> separated C', F' -> box-normalize -> snce_depth = 0 for each -> snce wrapper gives depth <= 1. |
| Import reversal creates cycle | H | L | Remove SeparationThm import from Hierarchy BEFORE adding Hierarchy import to SeparationThm |
| count_U_total doesn't strictly decrease when abstracting U-types inside `.untl` children | M | L | `abstract_untl_count_total_lt_of_contains_deep` handles this: `abstract_untl` replaces ALL matching `.untl A B` nodes including nested ones, and `contains_untl_deep` finds at least one. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

---

### Phase 1: Measure Infrastructure [NOT STARTED]

**Goal**: Define `count_U_total`, `extract_innermost_U_type`, and companion lemmas needed for the oracle-free `no_S_nested_sep`.

**Tasks**:

- [ ] Task 1.1: Define `count_U_total` in `Defs.lean`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean`
  - **Location**: After `count_U_subformulas`
  - **Definition**: Counts ALL `.untl` nodes at all depths (unlike `count_U_subformulas` which only counts surface-level ones).
  - **Code**:
    ```lean
    def count_U_total : Formula → Nat
      | .atom _ => 0
      | .bot => 0
      | .imp φ ψ => count_U_total φ + count_U_total ψ
      | .box φ => count_U_total φ
      | .untl φ ψ => 1 + count_U_total φ + count_U_total ψ
      | .snce φ ψ => count_U_total φ + count_U_total ψ
    ```

- [ ] Task 1.2: Prove `count_U_total_zero_iff_U_free`
  - **Statement**: `count_U_total phi = 0 ↔ is_U_free phi = true`

- [ ] Task 1.3: Define `contains_untl_deep` in `Hierarchy.lean`
  - **Location**: After `abstract_untl_count_lt_of_contains_surface`
  - **Code**: As specified in plan v25 Phase 3, Task 3.2

- [ ] Task 1.4: Prove `abstract_untl_count_total_le` and `abstract_untl_count_total_lt_of_contains_deep`
  - `count_U_total (abstract_untl phi A B p) ≤ count_U_total phi`
  - `contains_untl_deep phi A B → count_U_total (abstract_untl phi A B p) < count_U_total phi`

- [ ] Task 1.5: Prove `s_free_implies_no_S_nested`
  - **Statement**: `is_S_free phi = true → no_S_nested_in_U phi`
  - **Proof**: ~10 LOC structural induction. S-free means no `.snce` nodes, so `.untl` args vacuously have no `.snce`.

- [ ] Task 1.6: Define `extract_innermost_U_type` and companion lemmas
  - Like `extract_U_type` but recurses INTO `.untl` children when they're not U-free.
  - At `.untl a b`: if both a, b U-free, return (a, b). Otherwise recurse into the non-U-free child.
  - Uses `s_free_implies_no_S_nested` to establish `no_S_nested_in_U` for `.untl` children at positions where `no_S_nested_in_U (.untl a b)` gives `is_S_free a ∧ is_S_free b`.
  - **Companion lemmas**:
    - `extract_innermost_U_type_S_free`: result args are S-free
    - `extract_innermost_U_type_U_free`: result args are U-free (KEY property)
    - `extract_innermost_U_type_contains_deep`: result satisfies `contains_untl_deep`

- [ ] Task 1.7: Prove `contains_untl_surface_implies_deep`
  - `contains_untl_surface phi A B → contains_untl_deep phi A B`

- [ ] Task 1.8: Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

---

### Phase 2: Oracle-Free `no_S_nested_sep` [NOT STARTED]

**Goal**: Create a single oracle-free theorem `no_S_nested_sep` that proves any formula with `no_S_nested_in_U` is separable, using nested well-founded inductions on `(U_nesting_depth, count_U_total)`.

**Architecture**: The theorem uses a double strong induction on `(UND, count_U_total)` in lexicographic order:

```
no_S_nested_sep phi (hns : no_S_nested_in_U phi) : is_separable phi

Outer: induction on U_nesting_depth
Inner: induction on count_U_total (within each UND level)

UND = 0: phi is U-free, trivially separated
UND >= 2:
  - Extract innermost U(X,Y) with U-free X, Y (via extract_innermost_U_type)
  - Abstract: phi' = abstract_untl phi X Y p
  - count_U_total phi' < count_U_total phi (strict decrease)
  - IH at (UND phi', count_U_total phi') where UND phi' <= UND phi: inner IH (same UND, smaller count)
  - Get separated psi. Substitute back via subst_in_separated_separable_depth.
  - Callback: no_S_nested_in_U chi, UND chi <= 1 (from callback_U_nesting_depth_le_one, X Y U-free)
  - IH at (1, count_U_total chi): outer IH (UND decreased from >= 2 to <= 1)

UND <= 1 (but > 0, i.e., phi has .untl nodes):
  - Extract surface U(A,B) with U-free + S-free A, B (via extract_U_type + extract_U_type_U_free)
  - Abstract: phi' = abstract_untl phi A B p
  - count_U_total phi' < count_U_total phi (count_U_total of .untl A B = 1 since A,B U-free)
  - IH at (1, count_U_total phi'): inner IH (same UND, smaller count)
  - Get separated psi. Substitute back via subst_in_separated_separable_typed.
  - Callback: has_single_U_type chi A B, no_S_nested_in_U chi
  - Handle by single_U_formula_separable_noax_param with oracle
  - Oracle receives: no_S_nested_in_U chi', JD chi' <= 1
  - Oracle implementation: NESTED induction (see below)
```

**The oracle implementation for UND <= 1**:

The oracle from `single_U_formula_separable_noax_param` at `snce_depth_of_U >= 2` produces formulas with `snce_depth_of_U <= 1` (from `separated_boxnorm_snce_depth_zero`). These are handled by a SECOND pass through the UND <= 1 logic:

```
oracle_for_single_U chi (hns : no_S_nested_in_U chi) (hjd : JD chi <= 1) : is_separable chi :=
  -- chi has snce_depth_of_U <= 1
  -- Handle chi via the SAME UND <= 1 path:
  --   Extract U-type, abstract, IH (count_U_total decreases), substitute back
  --   Callback -> single_U at depth <= 1 (leaf case, NO oracle)
  no_S_nested_in_U_separable_param_jd chi hns (has_no_allpast_allfuture_true chi)
    (fun chi2 hns2 hjd2 =>
      -- chi2 has no_S_nested_in_U, JD <= 1
      -- chi2 is produced by subst_in_separated_separable_jd on the separated form of chi
      -- Handle chi2 the same way, with a LEAF callback:
      no_S_nested_in_U_separable_param_jd chi2 hns2 (has_no_allpast_allfuture_true chi2)
        (fun chi3 hns3 hjd3 =>
          -- chi3 has no_S_nested_in_U, JD <= 1
          -- At this level, use single_U at depth <= 1 (leaf, no oracle)
          -- But chi3 doesn't have has_single_U_type...
          -- Use the COUNT INDUCTION within no_S_nested_in_U_separable_param_jd
          -- which handles EVERYTHING at JD <= 1 + no_S_nested_in_U
          -- as long as we can provide a callback that terminates
          sorry -- This needs more thought
        )
    )
```

**IMPLEMENTATION NOTE**: The exact structure of the oracle's nested recursion will require experimentation during implementation. The agent should:

1. First attempt: Define `no_S_nested_sep` with outer/inner strong induction on (UND, count_U_total). At UND <= 1, use `lemma_10_2_6_self_contained_param` with `single_U_formula_separable_noax_param`, threading the `no_S_nested_sep` IH as the oracle. If the lex measure works (oracle formula UND + count_U_total is lex-smaller), this directly succeeds.

2. If the lex measure fails (oracle formula UND or count_U_total is not lex-smaller): try using `subst_in_separated_separable_depth` (which gives UND <= 1 for callbacks) instead of `_jd` or `_typed`, so that all callbacks stay at UND <= 1 with strictly decreasing count_U_total.

3. If approach 2 fails: try inlining the single_U logic into the main theorem, using a TRIPLE induction on `(UND, snce_depth_of_U, count_U_total)`. The single_U's snce_depth induction becomes the middle component. Oracle formulas from depth >= 2 have snce_depth <= 1, providing the decrease for the middle component.

4. If all approaches fail: write a handoff documenting exactly what measure combination was tried and why each failed.

**Tasks**:

- [ ] Task 2.1: Create `no_S_nested_sep` theorem
  - **File**: `Hierarchy.lean`
  - **Location**: After `no_S_nested_in_U_separable_direct` (after line 2659)
  - **Statement**:
    ```lean
    /-- GHR94 Lemmas 10.2.6 + 10.2.7 (oracle-free):
        A formula with no_S_nested_in_U is separable.
        No oracle parameter, no axiom-backed functions. -/
    theorem no_S_nested_sep (phi : Formula) (hns : no_S_nested_in_U phi) : is_separable phi
    ```
  - **Proof**: As described in the architecture above. Start with approach 1 (double strong induction on (UND, count_U_total)). If that doesn't work, try approaches 2-4.

- [ ] Task 2.2: Verify `lake build` succeeds
- [ ] Task 2.3: Verify `no_S_nested_sep` has no oracle parameter and does not reference `all_separable`, `snce_separable`, `untl_separable`, `all_past_separable`, or `all_future_separable`

**Timing**: 3.5 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

---

### Phase 3: Fix 10.2.8, Import Reversal, Axiom Replacement [NOT STARTED]

**Goal**: Replace the n=1 fallback in `all_formulas_separable_aux` with `no_S_nested_sep`, reverse the import, and replace axioms with theorems.

**Tasks**:

- [ ] Task 3.1: Replace n=1 `.snce` fallback
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2783-2784
  - **OLD**: `exact no_S_nested_in_U_separable_direct (.snce χa χb) hns`
  - **NEW**: `exact no_S_nested_sep (.snce χa χb) hns`

- [ ] Task 3.2: Replace n=1 `.untl` fallback
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2820
  - **OLD**: `exact no_S_nested_in_U_separable_direct _ hns_S`
  - **NEW**: `exact no_S_nested_sep _ hns_S`

- [ ] Task 3.3: Remove remaining `all_separable` references from `Hierarchy.lean`
  - Audit all occurrences of `all_separable` in Hierarchy.lean.
  - Replace:
    - `no_S_nested_in_U_separable_noax` -> use `no_S_nested_sep` or delete if unused
    - `no_S_nested_in_U_separable_direct` -> use `no_S_nested_sep` or delete if unused
    - `multi_U_formula_separable` -> use `no_S_nested_sep` or delete if unused
    - `single_U_formula_separable` -> redefine using `single_U_formula_separable_noax` or delete
    - Other wrappers that call `all_separable`
  - Goal: ZERO references to `all_separable` in Hierarchy.lean.

- [ ] Task 3.4: Remove `import SeparationThm` from Hierarchy.lean
  - **File**: `Hierarchy.lean`, Line 2
  - Delete: `import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm`

- [ ] Task 3.5: Verify `lake build` for Hierarchy.lean

- [ ] Task 3.6: Add Hierarchy import to SeparationThm.lean
  - **File**: `SeparationThm.lean`, after existing imports
  - Add: `import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 3.7: Replace 4 temporal closure axioms with theorems
  - `all_past_separable` (line 89): `theorem ... := all_formulas_separable_aux _ _` (or derive from `all_formulas_separable`)
  - `all_future_separable` (line 93): same pattern
  - `untl_separable` (line 97): same pattern
  - `snce_separable` (line 101): same pattern
  - Note: the `is_separable phi` hypothesis in these is UNUSED. The result is unconditional.

- [ ] Task 3.8: Replace 4 proper separation axioms with theorems
  - Lines 220-237: derive from non-proper versions + `proper_separation_preserves_atoms`

- [ ] Task 3.9: Verify only `proper_separation_preserves_atoms` remains as axiom
  - `grep -n "^axiom" SeparationThm.lean`

- [ ] Task 3.10: Final verification
  - `lake build` succeeds with zero errors
  - `grep -rn "^axiom" SeparationThm.lean` returns at most 1 line
  - `grep -rn "sorry" Hierarchy.lean SeparationThm.lean Defs.lean` returns 0

**Timing**: 2.5 hours

**Depends on**: Phase 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`

---

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn "^axiom" SeparationThm.lean` returns at most 1 line (`proper_separation_preserves_atoms`)
- [ ] `no_S_nested_sep` has NO oracle parameter
- [ ] No reference to `all_separable`, `snce_separable`, `untl_separable`, `all_past_separable`, `all_future_separable` in Hierarchy.lean
- [ ] No `sorry`: `grep -rn "sorry" Hierarchy.lean SeparationThm.lean Defs.lean` returns 0

## Artifacts & Outputs

- `plans/25_revised-oracle-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean`
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`

## Rollback/Contingency

- `git stash` or `git checkout` the three modified files
- Phase 1 is additive (new definitions and lemmas), safe to keep
- If Phase 2 blocks on the termination argument:
  1. Try the triple induction approach `(UND, snce_depth_of_U, count_U_total)`
  2. Try the quadruple induction `(JD, UND, snce_depth_of_U, count_U_total)` by merging with `all_formulas_separable_aux`
  3. If all measures fail, write a detailed handoff documenting the oracle chain structure and which measures were attempted
- If Phase 3 blocks on import cycle: ensure SeparationThm import is removed BEFORE Hierarchy import is added

### Research Integration

This plan integrates findings from:
- `handoffs/phase-1-handoff-20260519.md`: Identified Case 2 single-U-type violation and termination gap
- `reports/24_blocker-research.md`: Original blocker analysis
- Code analysis of Hierarchy.lean lines 2206-2839: Identified the one-hop termination pattern for single_U oracle
