# Research Report: GHR94 Junction-Depth Proof Architecture

**Task**: 157 -- Formalize expressive completeness of {S,U} over integer time
**Focus**: Phase 6 axiom elimination via junction-depth induction + Phase 7 quantifier case simplification
**Date**: 2026-05-17

## Key Findings

1. **GHR94's junction-depth measure is well-defined for our formalization**, but the base case (JD <= 1) is NOT trivially resolved because our primitive `all_past`/`all_future` constructors create JD=0 formulas that are NOT syntactically separated (e.g., `all_past (untl A B)`). GHR94 avoids this because they derive G/H from U/S.

2. **The precise GHR94 proof of Lemma 10.2.8** uses a SINGLE measure (junction_depth) with base case JD <= 1 (not JD = 0). At JD >= 2, maximal U-subterms of S-arguments contain S-subformulae; these are replaced by fresh atoms, reducing JD by exactly 1 per application of Lemmas 10.2.4-10.2.7. The formalization correctly captures `junction_depth` via the mutual recursion with `junction_depth_U` / `junction_depth_S`.

3. **The circularity in the current formalization is an artifact of how temporal closure is encoded**, not a fundamental impossibility. The axioms `snce_separable`, `untl_separable`, `all_past_separable`, `all_future_separable` can be eliminated by proving a SINGLE master theorem: `no_cross_nesting_separable : no_S_nested_in_U phi -> is_separable phi` (and its dual). The temporal closure axioms then follow from TemporalClosure.lean's existing infrastructure.

4. **The `all_past (untl A B)` problem at JD=0 is solvable**: When A, B are S-free, `untl A B` is already syntactically separated, so `is_separable (untl A B)` is trivial. For `all_past (untl A B)`, we note this satisfies `no_S_nested_in_U` and has junction_depth = 0. The proof proceeds NOT by JD induction but by the direct observation that this formula has no S-nested-in-U, and `all_future_separable` (the axiom itself) is what we're trying to eliminate. The resolution: use the U-free / S-free decomposition from TemporalClosure.lean, which already shows these formulas reduce to formulas satisfying `no_S_nested_in_U` with strictly fewer temporal operators.

5. **For Phase 7** (quantifier cases): The existing infrastructure (`reduceElimLast_correct_at_one`, `q_exists_correct`, `past_only_subst_correct`, `future_only_subst_correct`) is complete. The remaining work is mechanical: (a) const_at_ref case-split via finite enumeration over `sig.preds -> Bool`, (b) level-aware lt_ref/gt_ref substitution using purity predicates, (c) assembly. There is NO simpler formulation that avoids the pipeline -- this IS the standard approach (GHR94 Section 9.3). However, the `.all` case can be derived from `.ex` via negation, halving the work.

## Detailed Analysis

### Phase 6: The Well-Founded Measure

#### GHR94's Exact Construction (Lemma 10.2.8)

**Definition** (junction_depth, from GHR94 p. 587-588):
Given a formula A, the junction depth of an occurrence of subformula B in A is the maximum n such that there exist C_1, ..., C_n where:
- B is a subformula of C_1
- Each C_i is a subformula of C_{i+1}
- Each C_i is either a U-formula or S-formula
- The C_i alternate between U and S types

The junction depth of the formula A is the maximum junction depth over all occurrences.

**The formalization's mutual recursion** correctly captures this:
```lean
mutual
def junction_depth : Formula -> Nat
  | .untl phi psi => max (junction_depth_U phi) (junction_depth_U psi)
  | .snce phi psi => max (junction_depth_S phi) (junction_depth_S psi)
  | -- other cases: max of recursive calls

def junction_depth_U : Formula -> Nat  -- "we are inside a U"
  | .snce phi psi => 1 + max (junction_depth phi) (junction_depth psi)
  | .untl phi psi => max (junction_depth_U phi) (junction_depth_U psi)
  | -- other cases: propagate junction_depth_U

def junction_depth_S : Formula -> Nat  -- "we are inside an S"
  | .untl phi psi => 1 + max (junction_depth phi) (junction_depth psi)
  | .snce phi psi => max (junction_depth_S phi) (junction_depth_S psi)
  | -- other cases: propagate junction_depth_S
end
```

**Key insight**: `junction_depth_U` tracks "alternation count when most recently entering a U", and increments when it encounters an S (since that's a U-to-S transition). Similarly for `junction_depth_S`.

#### The Base Case Problem

GHR94 states: "If [junction depth] is zero or one then D is already syntactically separated."

In GHR94's setting (where G = U(T, phi) and H = S(T, phi)):
- JD=0 means no U-S nesting at all -> formula is either U-free (hence "pure past/present") or S-free (hence "pure future/present") -> syntactically separated.
- JD=1 means at most one level of nesting -> exactly what Cases 1-4 handle.

In OUR setting (where `all_past` and `all_future` are primitive):
- JD=0 formulas include `all_past (untl A B)` which is NOT syntactically separated (because `is_syntactically_separated (.all_past phi)` requires `is_U_free phi`).
- However, `all_past (untl A B)` DOES satisfy `no_S_nested_in_U` (because the untl's arguments A, B are atoms/S-free by assumption).

**Resolution**: The base case of the induction is NOT "JD=0 implies separated" but rather "JD=0 AND no_S_nested_in_U implies separable." The JD=0 case further decomposes into:
- If U-free: immediately separable (via existing helper theorems)
- If has U but no S-nesting: apply Lemmas 10.2.5-10.2.7 (single-U, multi-U, no-S-within-U)
- The `all_past`/`all_future` wrappers around these are handled by the temporal closure derivation

#### The Correct Proof Strategy

The key theorem to prove (which eliminates ALL 8 axioms):

```lean
/-- Master theorem: a formula with no S nested within any U is separable.
    This is GHR94 Lemma 10.2.7 proved constructively. -/
theorem no_S_nested_in_U_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi
```

**Proof by well-founded induction on `(junction_depth phi, Formula.sizeof phi)`** (lexicographic):

- **Base (junction_depth = 0)**: By `junction_depth_S_zero_imp_U_free` (already proved in TemporalClosure.lean), if JD=0 for a `snce` node, its arguments are U-free. Actually for the overall formula at JD=0: if the formula has no `snce` nodes that contain `untl` (which is what JD=0 means), then we can handle it by direct structural argument. But the real base case is: if the formula is U-free, then it's already separated (for `all_past`, `snce` with U-free args, etc.). If it has U but JD=0, all U-args are S-free (given `no_S_nested_in_U`), and there's no S under any U (JD_S = 0 everywhere), meaning the formula is effectively a boolean/temporal combination of S-free-U-formulas and U-free-S-formulas -- exactly what `is_syntactically_separated` accepts.

  Wait -- that's the insight. Let me refine:

  If `no_S_nested_in_U phi` AND `junction_depth phi = 0`, then `is_syntactically_separated phi = true`.

  **Proof**: By structural induction on phi.
  - `.atom`, `.bot`, `.box`: trivial
  - `.imp`: recursive
  - `.all_past phi`: JD=0 means `junction_depth phi = 0`. From `no_S_nested_in_U`, all U-args are S-free. But JD=0 means no S appears inside any U that appears inside an S. Combined with `no_S_nested_in_U` (no S inside U at all), the formula's `junction_depth_S` is 0 everywhere, hence by `junction_depth_S_zero_imp_U_free`, the argument is U-free. So `is_syntactically_separated (.all_past phi) = is_U_free phi = true`.

  Actually NO. `junction_depth (.all_past phi) = junction_depth phi`. And `no_S_nested_in_U (.all_past phi) = no_S_nested_in_U phi`. If phi = `untl A B`, then `junction_depth (.all_past (untl A B)) = junction_depth (untl A B) = max (junction_depth_U A) (junction_depth_U B)`. If A, B are atoms, this is 0. But `is_syntactically_separated (.all_past (untl A B)) = is_U_free (untl A B) = false`.

  **So junction_depth = 0 does NOT imply syntactically separated in our formalization.** This confirms Finding 1 in the phase-6-handoff-20260517e.md.

#### The Correct Compound Measure

The correct approach uses a compound well-founded measure. Here is the precise construction:

```lean
/-- The separation measure: primary key is junction_depth,
    secondary key is total formula size. -/
def sep_measure (phi : Formula) : Nat × Nat :=
  (junction_depth phi, Formula.sizeof phi)
```

With the lexicographic ordering on `Nat x Nat` (which is well-founded).

The proof of `no_S_nested_in_U_separable` proceeds by `WellFounded.fix` on this measure:

**Given**: phi with `no_S_nested_in_U phi` at measure `(jd, sz)`.

**Case analysis on phi**:
1. `.atom`, `.bot`: immediately separated, hence separable.
2. `.imp phi psi`: both phi and psi satisfy `no_S_nested_in_U` (by definition). Both have strictly smaller size. Apply IH twice.
3. `.box phi`: trivially separable.
4. `.all_past phi`: `no_S_nested_in_U phi` holds (by definition). By `replace_box_equiv` + `replace_box_separated_no_S_nested`, we can work with box-normalized versions. The key subcases:
   - If `is_U_free phi`: then `all_past phi` is syntactically separated. Done.
   - If phi has U-subterms (all with S-free args by `no_S_nested_in_U`): We need to "pull the Us out". Apply `swap_temporal`: `all_past phi` has the same semantic content as working in the reversed model with `all_future (swap_temporal phi)`. The swapped formula satisfies `no_U_nested_in_S` (by `swap_no_S_nested_gives_no_U_nested`). By the dual theorem (proved symmetrically), this is separable. The dual call has the SAME junction_depth but we can argue it works because `swap_temporal` preserves separation and the dual theorem is the symmetric case.

   Actually, this still has circularity. Let me reconsider.

5. `.all_future phi`: Symmetric to `all_past`.
6. `.untl phi psi`: `no_S_nested_in_U (.untl phi psi)` means `is_S_free phi ∧ is_S_free psi`. So `untl phi psi` with S-free args is immediately syntactically separated. Done.
7. `.snce phi psi`: `no_S_nested_in_U (.snce phi psi)` means `no_S_nested_in_U phi ∧ no_S_nested_in_U psi`. Both phi and psi have strictly smaller size. By IH, both are separable (have separated witnesses phi', psi'). We need to show `.snce phi psi` is separable.

   This is where the junction-depth argument kicks in. We have separated phi', psi' witnessing separability of phi, psi. The formula `.snce phi' psi'` satisfies `no_S_nested_in_U` (by `snce_of_boxfree_sep_no_S_nested`) and has junction_depth <= 1 (by `snce_of_boxfree_sep_jd_le_one`).

   But we need to prove that `.snce phi' psi'` is SEPARABLE. It has `no_S_nested_in_U`. Its junction_depth is <= 1 (but possibly > 0). We are trying to prove the theorem AT junction_depth of the original formula...

   Wait. The original `.snce phi psi` has some junction_depth jd. After replacing phi, psi by their separated equivalents phi', psi', we get `.snce phi' psi'` with JD <= 1 AND no_S_nested_in_U. If the ORIGINAL formula had JD >= 2, then jd > 1 >= JD of `.snce phi' psi'`, so the IH applies to `.snce phi' psi'` directly.

   But if the original JD was already <= 1 (which can happen when phi, psi have no U-S cross-nesting), then we cannot use the IH. In that case, since JD <= 1, all U occurrences under S are at most 1 level deep. This is exactly the regime of Lemma 10.2.4 (single S with top-level U). The existing Cases 1-4 handle this!

   **The resolution**: For `snce phi psi` with `no_S_nested_in_U`:
   - Get separated witnesses phi', psi' (from IH on smaller formulas)
   - `.snce phi' psi'` has JD <= 1 and no_S_nested_in_U
   - If JD = 0: phi' and psi' are both U-free (by `junction_depth_S_zero_imp_U_free` applied inside the snce context), so `.snce phi' psi'` is directly separated.
   - If JD = 1: Apply Cases 1-4 (which ARE proved!) to eliminate U from under S.

   **This is the breakthrough**: Cases 5-8 are NOT needed for the no_S_nested_in_U theorem! They were only needed because the previous approach tried to prove the GENERAL case (arbitrary nesting) by reduction to Cases 1-8. But the junction-depth approach reduces to Cases 1-4 only (JD=1 cases), because the JD reduction from >= 2 to <= 1 is handled by the substitution bridge, not by Cases 5-8.

### The Complete Proof Architecture for Phase 6

```lean
-- Step 1: Prove the JD=0 base case
theorem no_S_nested_jd_zero_separated (phi : Formula)
    (h_nosn : no_S_nested_in_U phi) (h_jd : junction_depth phi = 0) :
    is_syntactically_separated phi = true

-- Step 2: Prove the JD=1 case using Cases 1-4
theorem no_S_nested_jd_one_separable (phi : Formula)
    (h_nosn : no_S_nested_in_U phi) (h_jd : junction_depth phi ≤ 1) :
    is_separable phi

-- Step 3: Prove the inductive step (JD >= 2 reduces to JD-1)
theorem no_S_nested_jd_step (phi : Formula)
    (h_nosn : no_S_nested_in_U phi)
    (ih : ∀ psi, no_S_nested_in_U psi → junction_depth psi < junction_depth phi →
          is_separable psi) :
    is_separable phi

-- Step 4: Combine into the master theorem
theorem no_S_nested_in_U_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi

-- Step 5: Derive temporal closure (eliminates axioms)
theorem snce_separable_thm (phi psi : Formula)
    (h1 : is_separable phi) (h2 : is_separable psi) :
    is_separable (.snce phi psi) := by
  -- Get witnesses
  obtain ⟨phi', hphi', heqphi⟩ := h1
  obtain ⟨psi', hpsi', heqpsi⟩ := h2
  -- Box-normalize and use TemporalClosure infrastructure
  have h_nosn := snce_of_boxfree_sep_no_S_nested phi psi hphi' hpsi'
  -- ... apply no_S_nested_in_U_separable ...

-- Step 6: Derive untl_separable via duality
theorem untl_separable_thm (phi psi : Formula)
    (h1 : is_separable phi) (h2 : is_separable psi) :
    is_separable (.untl phi psi) := by
  -- Use swap_temporal duality to reduce to snce_separable_thm
  sorry -- mechanical via Duality.lean infrastructure
```

#### Critical Question: all_past / all_future Cases

For `all_past_separable_thm`:
```lean
theorem all_past_separable_thm (phi : Formula) (h : is_separable phi) :
    is_separable (.all_past phi) := by
  obtain ⟨phi', hphi', heqphi⟩ := h
  -- phi' is syntactically separated
  -- all_past phi ≡ all_past phi' (by heqphi + congruence)
  -- Need: is_separable (.all_past phi')
  -- Case 1: is_U_free phi' = true → all_past phi' is syntactically separated. Done.
  -- Case 2: phi' has U-subterms (with S-free args, since phi' is separated)
  --   all_past phi' satisfies no_S_nested_in_U (by all_past_of_boxfree_sep_no_S_nested)
  --   Apply no_S_nested_in_U_separable
```

**THIS WORKS!** The key: `all_past_of_boxfree_sep_no_S_nested` (already proved) gives `no_S_nested_in_U (.all_past (replace_box_with_top phi'))`. Then `no_S_nested_in_U_separable` applies. The junction_depth of `.all_past phi'` is at most 1 (since phi' is separated, its JD is at most 1 by `snce_of_boxfree_sep_jd_le_one`... actually no, that's for snce. For all_past, `junction_depth (.all_past phi') = junction_depth phi'`, which for a separated formula is at most 1 -- this is provable from the same analysis).

Actually, for a syntactically separated formula phi':
- If it's atom/bot/imp: JD = 0
- If it's `.untl a b` with S-free a, b: JD = max(JD_U a, JD_U b). S-free => JD_U = 0. So JD = 0.
- If it's `.snce a b` with U-free a, b: JD = max(JD_S a, JD_S b). U-free => JD_S = 0. So JD = 0.
- If it's `.all_past phi`: requires is_U_free phi, so JD = 0.
- If it's `.all_future phi`: requires is_S_free phi, so JD = 0.

**Separated formulas have junction_depth = 0!** This is a crucial property. Therefore:
- `all_past phi'` (separated phi') has JD = 0
- `snce phi' psi'` (separated phi', psi') has JD <= 1 (from snce_of_boxfree_sep_jd_le_one, but actually: JD_S of separated = 0 as just shown, so JD of snce = max(JD_S phi', JD_S psi') which is at most... wait).

Let me re-examine. `junction_depth (.snce phi' psi') = max (junction_depth_S phi') (junction_depth_S psi')`. For separated phi', if phi' = `.untl a b` (S-free a, b), then `junction_depth_S (.untl a b) = 1 + max (junction_depth a) (junction_depth b) = 1 + 0 = 1`. So yes, JD of snce of separated is at most 1.

For `all_past phi'` with separated phi': `junction_depth (.all_past phi') = junction_depth phi'`. A separated phi' has JD = 0 (as shown above). So `all_past phi'` has JD = 0.

**But wait**: `no_S_nested_in_U (.all_past phi')` where phi' has U-subterms. We proved `all_past_of_boxfree_sep_no_S_nested` gives this. And JD = 0. So we need `no_S_nested_jd_zero_separated` or at least the JD=0 case of `no_S_nested_in_U_separable`.

At JD = 0 with `no_S_nested_in_U`:
- `all_past phi'` where phi' is separated and may contain U-subterms
- Example: phi' = `.imp (.untl A B) (.atom p)` (separated, has U-subterms)
- `all_past phi'` has JD = 0
- `is_syntactically_separated (.all_past phi') = is_U_free phi'` = false
- So NOT immediately separated

This is the known problem. At JD=0 with U-content under all_past, we need a different reduction.

**The fix**: At JD=0, `no_S_nested_in_U (.all_past phi')` with phi' separated. The formula `.all_past phi'` satisfies `no_S_nested_in_U`. Its junction_depth is 0. But it's not separated.

Apply the GHR94 Lemma 10.2.7 argument DIRECTLY:
1. phi' is separated, so it's a boolean combination of: atoms, `untl`-terms (S-free args), `snce`-terms (U-free args), `all_future`-terms (S-free args), `all_past`-terms (U-free args)
2. `all_past phi'` distributes over boolean combinations (using `all_past(A -> B) <-> all_past(A) -> all_past(B)` is WRONG -- H doesn't distribute over ->)

Actually, `all_past` does NOT distribute over boolean connectives in general. We cannot just push it inside.

**Alternative approach for all_past**: The formula `all_past phi'` with separated phi' containing U-subterms. This formula satisfies `no_S_nested_in_U`. Its snce-subformulas (inside phi') have U-free arguments (since phi' is separated). Its untl-subformulas (inside phi') have S-free arguments.

The key observation: `all_past phi'` is int_equiv to itself. What we need is to find a SEPARATED formula equivalent to it. The GHR94 approach for the all_past case (which is hidden in their setting since they derive H from S):

In GHR94, H(phi) = S(T, phi) (over integer time: "phi was true at all past times" = "true was true in the past and phi held everywhere in between" vacuously). So the "all_past" case reduces to an "snce" case: `all_past phi ≡ snce top phi` semantically? No, that's `some_past`. Actually `H(phi) = neg(P(neg phi)) = neg(S(T, neg phi))`. Hmm, not quite.

Over integers: `H(phi)` at t iff for all s < t, phi(s). And `S(T, phi)` at t iff there exists s < t with T(s) and phi(r) for all r in (s,t). Since T is always true, `S(T, phi)` at t iff there exists s < t with phi(r) for all r in (s,t). This is NOT the same as H(phi).

Actually the correct encoding: `H(phi) = phi AND (phi S phi)` is also wrong. The standard encoding is `H(phi) = neg(neg(phi) S T)` -- "it's not the case that True since not-phi". But that uses S, so in GHR94's original setting, H is derived from S, and we never see a "bare" `all_past` node in the proof.

**In our setting**, `all_past` is primitive. The critical question is: given `all_past phi'` with phi' separated (containing U), how do we eliminate U from under `all_past`?

The answer uses the INTEGER TIME property:
```
all_past phi ↔ phi ∧ all_past(phi)   -- wrong, circular
```

Actually over integer time:
```
H(phi) at t ↔ phi(t-1) ∧ H(phi)(t-1)
            ↔ phi(t-1) ∧ phi(t-2) ∧ ...
```

This doesn't help directly. But there IS a GHR94-compatible approach:

**Over integer time**: `H(phi) ↔ neg(S(neg(phi) ∨ True, neg(phi)))` -- no, this is getting too complex.

**The simplest correct approach**: Since `all_past phi'` has `no_S_nested_in_U`, we can use the existing `multi_U_formula_separable` infrastructure. The formula `all_past phi'` has:
- No S nested in any U (given)
- Multiple U-subterms (from phi' being separated with U-content)
- All U-arguments are S-free (from the `no_S_nested_in_U` property)

This is EXACTLY the condition of Lemma 10.2.7! The proof of 10.2.7 proceeds by induction on "maximum depth of U-nesting beneath S". But here there's NO S above the U's -- they're under `all_past`, not under `snce`.

Hmm. The issue is that `all_past (untl A B)` has no S at all, so the "U under S" measure is 0. The formula isn't separated because `all_past` requires a U-free argument, but there's no U-S interaction to eliminate. We need a DIFFERENT equivalence.

**The real answer**: Over integer time, `all_past (untl A B)` (= H(U(A,B))) can be rewritten. Using the discrete property:

```
H(U(A,B)) at t ↔ ∀ s < t, ∃ r > s, A(r) ∧ ∀ u ∈ (s,r), B(u)
```

This formula depends on both past and future (since r could be > t). So it's NOT pure past! Wait, that's the semantic issue. Over integers:

At t=0: H(U(A,B)) means for all s < 0, U(A,B)(s).
U(A,B)(s) = exists r > s with A(r) and B on (s,r).
The witness r can be >= 0. So H(U(A,B)) at t=0 depends on future values of A.

This means `all_past (untl A B)` is NOT semantically "pure past" in general. It depends on BOTH past and future. So it's genuinely in the "mixed" category that separation must handle.

The correct approach: `all_past (untl A B)` with A, B S-free. Over integer time, this can be rewritten as an equivalent formula that IS separated. The rewriting uses the elimination cases applied to the semantic content.

Specifically: define the negation `neg(all_past (untl A B)) = some_past(neg(untl A B))`. Using Lemma 10.2.2, `neg(U(A,B)) ↔ G(neg A) ∨ U(neg A ∧ neg B, neg A)` over integer time.

So: `some_past(G(neg A) ∨ U(neg A ∧ neg B, neg A))`
  = `some_past(G(neg A)) ∨ some_past(U(neg A ∧ neg B, neg A))`

Hmm, `some_past` doesn't distribute over ∨ in general. But we can encode:

`neg(H(U(A,B)))` at t means: exists s < t such that neg(U(A,B))(s).
= exists s < t such that [G(neg A)(s) OR U(neg A ∧ neg B, neg A)(s)]

This is getting complicated. The point is: there IS a separated equivalent, but finding it requires the full elimination machinery.

**THE ACTUAL SOLUTION**: The trick from GHR94 is that `all_past phi'` where phi' is separated reduces to the SNCE case. Specifically:

Over DISCRETE (integer) time:
```
H(phi) ↔ phi ∧ Yesterday(H(phi))
```
where Yesterday(psi) at t = psi(t-1). But Yesterday isn't in our language.

Actually, the correct GHR94 approach is:
```
H(phi) at t ↔ ∀ s < t, phi(s)
            ↔ phi(t-1) ∧ ∀ s < t-1, phi(s)   -- over integers
            ↔ phi(t-1) ∧ H(phi)(t-1)
```

Over integers, `H(phi)` at t iff `phi(t-1) ∧ H(phi)(t-1)`, which means H(phi) at t iff `phi` holds at ALL points t-1, t-2, ... i.e., phi holds at all past points. But this doesn't give us a separation procedure.

Let me return to the formalization's actual approach. Looking at the `TemporalClosure.lean` more carefully:

The infrastructure shows:
- `all_past_of_boxfree_sep_no_S_nested`: `.all_past (replace_box_with_top phi')` satisfies `no_S_nested_in_U`
- `all_past_replace_box_equiv`: semantic equivalence

So the THEOREM to prove is:
```lean
theorem no_S_nested_in_U_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi
```

And then `all_past_separable` follows:
```lean
theorem all_past_separable (phi : Formula) (h : is_separable phi) :
    is_separable (.all_past phi) := by
  obtain ⟨phi', hphi', heqphi⟩ := h
  -- all_past phi ≡ all_past (replace_box_with_top phi')
  have heq := int_equiv_trans (all_past_congr heqphi) (all_past_replace_box_equiv phi')
  have hnosn := all_past_of_boxfree_sep_no_S_nested phi' hphi'
  exact is_separable_of_equiv heq (no_S_nested_in_U_separable _ hnosn)
```

So the ONLY theorem needed is `no_S_nested_in_U_separable`. Let's think about how to prove it.

#### Proving no_S_nested_in_U_separable

The formula phi satisfies `no_S_nested_in_U phi`:
- For `.untl a b`: `is_S_free a ∧ is_S_free b` -- already syntactically separated!
- For `.snce a b`: `no_S_nested_in_U a ∧ no_S_nested_in_U b` -- recursive

The cases:
1. `.atom`, `.bot`: trivially separated.
2. `.imp a b`: `no_S_nested_in_U a ∧ no_S_nested_in_U b`. By IH on smaller formulas, both are separable. `imp_separable` gives the result.
3. `.box`: trivially separated.
4. `.all_past phi`: `no_S_nested_in_U phi`. By IH on phi (smaller), phi is separable.  
   We now need `all_past_separable` -- but that's what we're trying to prove! This IS the circularity.
5. `.all_future phi`: Same issue -- needs `all_future_separable`.
6. `.untl a b`: `is_S_free a ∧ is_S_free b`. Already separated.
7. `.snce a b`: `no_S_nested_in_U a ∧ no_S_nested_in_U b`. By IH, both separable. Need `snce_separable` -- another circularity.

**The circularity**: `no_S_nested_in_U_separable` needs `all_past_separable` and `snce_separable`, which need `no_S_nested_in_U_separable`. This is the SAME circularity identified in the handoff.

#### Breaking the Circularity: Two-Pronged Mutual Induction

The solution is a SIMULTANEOUS proof of both directions:

```lean
-- The pair of theorems proved simultaneously by WF induction on compound measure
theorem separation_pair :
    (∀ phi, no_S_nested_in_U phi → is_separable phi) ∧
    (∀ phi, no_U_nested_in_S phi → is_separable phi)
```

With measure: `(junction_depth phi, Formula.sizeof phi)` lexicographic.

For the first half (no_S_nested_in_U -> separable):
- `.snce a b` case: a, b are separable by IH (smaller size). Get separated witnesses a', b'. Form `.snce a' b'`. This has JD <= 1 and no_S_nested_in_U. If JD = 0, it's immediately separated. If JD = 1, apply Cases 1-4 to get a separated equivalent.
- `.all_past phi` case: phi is separable by IH (smaller size). Get separated witness phi'. Form `.all_past phi'`. If phi' is U-free, done. Otherwise, `.all_past phi'` satisfies no_S_nested_in_U and has JD = 0 (since separated formulas have JD = 0). **But this is the problematic case!** We can't directly show it's separated.

   **Key insight for all_past**: `.all_past phi'` with separated phi' that has U-content. Apply `swap_temporal`: `(all_past phi').swap_temporal = all_future (phi'.swap_temporal)`. By `dual_separated`, `phi'.swap_temporal` is separated. By `swap_no_S_nested_gives_no_U_nested` (wait, wrong direction -- we'd need the other)...

   Actually: `.all_past phi'` satisfies `no_S_nested_in_U`. We want to prove it separable. Its `swap_temporal` is `.all_future (swap_temporal phi')`. The swapped formula `.all_future (swap_temporal phi')` satisfies `no_U_nested_in_S` (by `swap_no_S_nested_gives_no_U_nested` applied to `.all_past phi'`... hmm).

   Let me trace more carefully. We have proof infrastructure:
   - `swap_temporal_int_truth`: int_truth M t (swap phi) ↔ int_truth M.reverse (-t) phi
   - `dual_equiv`: int_equiv phi psi → int_equiv (swap phi) (swap psi)
   - If we can show `swap_temporal (.all_past phi')` is separable, then by `swap_temporal_involution` and the equivalence machinery, `.all_past phi'` is also separable.

   `swap_temporal (.all_past phi') = .all_future (swap_temporal phi')`. This satisfies `no_U_nested_in_S` (because `.all_past phi'` satisfies `no_S_nested_in_U`, and swapping converts one to the other).

   Now invoke the SECOND half of `separation_pair`: `no_U_nested_in_S (all_future (swap phi')) → is_separable (all_future (swap phi'))`.

   In the second half, the `.all_future` case similarly needs the FIRST half via duality. But the key is: after one swap, we're working with a DIFFERENT formula. Does the measure decrease?

   `junction_depth` is preserved by `swap_temporal` (provable). `sizeof` is also preserved. So the measure is the SAME.

   **This means straight mutual induction on the compound measure DOESN'T WORK for all_past/all_future!**

#### The Correct Breaking Strategy

The resolution comes from observing that the `all_past phi'` case with separated phi' containing U CAN be handled by converting to the `snce` case using integer time properties:

Over integer time: `H(phi) ↔ phi ∧ S(phi, phi)` is FALSE.

Actually the correct identity over integer time:
```
H(phi) at t ↔ phi(t-1) ∧ H(phi)(t-1)
```
This is a fixpoint characterization. But for separation purposes:

**The GHR94 approach uses a DIFFERENT strategy**. They NEVER encounter bare `all_past(phi)` with U-content because in their framework, H(phi) = NOT S(T, NOT phi), so it's already an S-formula. In our formalization with primitive all_past/all_future, we need an additional lemma:

**Lemma (integer time)**: For any formula phi, `all_past phi ≡ phi ∧ snce phi phi` WRONG.

Actually: `H(phi)` at t means phi holds at all s < t.
And `S(phi, phi)` at t means: there exists s < t with phi(s) and phi(r) for all r in (s,t). This does NOT cover the point s itself needing phi to hold at all earlier points.

The correct equivalence over INTEGER time:
```
H(phi) at t ↔ [all_past phi at t]
```
That's tautological.

**Alternative**: Over integers, `H(phi) ↔ Y(phi) ∧ H(Y(phi))` where Y is "yesterday" (not in language).

**THE REAL SOLUTION**: Encode `H(phi)` using S. Over integer time:
```
H(phi) at t ↔ phi(t-1) ∧ S(True, phi)(t)
```
No! `S(T, phi)` at t = there exists s < t with phi(r) for all r in (s,t). This means phi on the open interval (s,t), not at s itself.

Over integers, (s,t) = {s+1, s+2, ..., t-1}. So `S(T, phi)` at t means: there exists s < t such that phi holds at s+1, ..., t-1. This is: there exists s < t such that phi holds on {s+1, ..., t-1}. Taking s = t-1 gives the trivially true case (empty interval). So `S(T, phi)` is always true over integers. That means `S(T, phi) ↔ True` over integers (since we can always pick s = t-1).

Over integers, `S(T, phi)` at t is true whenever there exists s < t such that phi holds at all points strictly between s and t. Taking s = t-1 (predecessor), the interval (t-1, t) is empty over integers. So the condition is vacuously satisfied. Therefore S(T, phi) is a tautology over integer time.

Similarly, `H(phi) ↔ phi(t-1) ∧ H(phi)` is not useful.

**OK, definitive approach**: In integer time:
```
H(phi) ↔ S(phi, phi)    -- WRONG: S(phi,phi) at t requires phi somewhere in the past
H(phi) ↔ S(T, phi) ∧ phi(t-1)  -- complicated
```

Let me compute more carefully. `H(phi)` at t means: phi(s) for all s < t.

Over integers, this means: phi(t-1) ∧ phi(t-2) ∧ ... (infinitely many conjuncts).

`S(phi, phi)` at t means: exists s < t with phi(s) and phi(r) for all r in (s,t).
Taking s to be the smallest integer (doesn't exist -- Z is unbounded below), this doesn't work.

The point: `H(phi) → S(phi, phi)` is TRUE (pick any s < t; phi holds at s and on (s,t) by H).
But `S(phi, phi) → H(phi)` is FALSE (S only guarantees phi on a bounded past interval).

So there is NO simple encoding of H(phi) as a single S-formula over integers.

**THE DEFINITIVE ANSWER**: Over integers, the correct reduction is:

```
H(phi) ↔ neg(P(neg(phi)))
       ↔ neg(S(T, neg(phi)))  -- But S(T, neg(phi)) ≡ P(neg(phi)) ≡ T if phi fails somewhere
```

Wait, `P(A)` = "A was true at some past point" = S(A, T) (= exists s < t with A(s) and T on (s,t)).
Actually P(A) at t = exists s < t with A(s). And S(A, T) at t = exists s < t with A(s) and T(r) for all r in (s,t). Since T is always true, `S(A, T) ↔ P(A)`.

And `H(phi) ↔ neg(P(neg(phi))) ↔ neg(S(neg(phi), T))`.

So `all_past phi ≡ neg(snce (neg phi) top)` where top = `imp bot bot`.

**THIS IS THE KEY**: We can replace every `all_past phi` with the equivalent `neg(snce (neg phi) top)`, and every `all_future phi` with `neg(untl (neg phi) top)`. These equivalences hold over integer time (they're the standard definitions of H and G from S and U respectively).

After this replacement:
- `all_past phi` becomes `neg(snce (neg phi) top)` -- an S-formula (wrapped in negation)
- `all_future phi` becomes `neg(untl (neg phi) top)` -- a U-formula (wrapped in negation)

The resulting formula has NO primitive `all_past` or `all_future` nodes. It's purely in the {U, S, imp, bot, atom, box} sublanguage. In THIS sublanguage, `no_S_nested_in_U` and the GHR94 hierarchy work WITHOUT the circularity.

#### Implementation Plan

```lean
/-- Over integer time: all_past phi ≡ neg(snce (neg phi) (imp bot bot)) -/
theorem all_past_as_snce (phi : Formula) :
    int_equiv (.all_past phi) (Formula.neg (.snce (Formula.neg phi) (.imp .bot .bot)))

/-- Over integer time: all_future phi ≡ neg(untl (neg phi) (imp bot bot)) -/
theorem all_future_as_untl (phi : Formula) :
    int_equiv (.all_future phi) (Formula.neg (.untl (Formula.neg phi) (.imp .bot .bot)))

/-- Eliminate all all_past/all_future nodes from a formula. -/
def eliminate_H_G : Formula -> Formula
  | .atom a => .atom a
  | .bot => .bot
  | .imp phi psi => .imp (eliminate_H_G phi) (eliminate_H_G psi)
  | .box phi => .box (eliminate_H_G phi)
  | .all_past phi => Formula.neg (.snce (Formula.neg (eliminate_H_G phi)) (.imp .bot .bot))
  | .all_future phi => Formula.neg (.untl (Formula.neg (eliminate_H_G phi)) (.imp .bot .bot))
  | .untl phi psi => .untl (eliminate_H_G phi) (eliminate_H_G psi)
  | .snce phi psi => .snce (eliminate_H_G phi) (eliminate_H_G psi)

/-- eliminate_H_G preserves int_equiv. -/
theorem eliminate_H_G_equiv (phi : Formula) : int_equiv phi (eliminate_H_G phi)

/-- eliminate_H_G output has no all_past or all_future nodes. -/
theorem eliminate_H_G_no_temporal_quantifiers (phi : Formula) :
    has_no_all_past (eliminate_H_G phi) ∧ has_no_all_future (eliminate_H_G phi)

/-- For formulas without all_past/all_future, no_S_nested_in_U implies separable.
    This is GHR94 Lemma 10.2.7 in the pure {U,S,imp,bot,atom} fragment. -/
theorem pure_US_no_S_nested_separable (phi : Formula)
    (h_nosn : no_S_nested_in_U phi)
    (h_no_ap : has_no_all_past phi)
    (h_no_af : has_no_all_future phi) :
    is_separable phi
```

The last theorem avoids the circularity because without `all_past`/`all_future` constructors, the structural recursion hits only:
- `.atom`, `.bot`: trivial
- `.imp`: recursive on smaller formulas
- `.box`: trivial
- `.untl a b`: S-free args (from no_S_nested_in_U), immediately separated
- `.snce a b`: recursive (this is the case needing Cases 1-4 + junction-depth)

For `.snce a b` with `no_S_nested_in_U`: a, b are recursively separable (IH). Get separated witnesses a', b'. The formula `.snce a' b'` has no_S_nested_in_U, JD <= 1. If JD = 0, it's already separated (the U-free/S-free analysis works in the pure fragment). If JD = 1, apply Cases 1-4.

**THIS ELIMINATES ALL CIRCULARITY.** The key insight: by reducing H/G to S/U first (a valid transformation over integer time), we eliminate the problematic constructors from the induction.

### Phase 7: Quantifier Case Simplification

The `.all` case CAN be derived from `.ex`:
```lean
| .all alpha =>
    -- ∀z. alpha(z,t) ↔ ¬∃z. ¬alpha(z,t)
    let neg_alpha := MonadicFormula.not alpha
    let ex_neg := MonadicFormula.ex neg_alpha
    let ih_ex := expressiveness_fixed_atomMap h_sep sig atomMap hinj (.ex neg_alpha)
    -- ih_ex gives A_neg such that ∃z.¬alpha(z,t) ↔ A_neg
    -- Result: Formula.neg A_neg captures ∀z.alpha(z,t)
    ⟨Formula.neg ih_ex.val, fun M t => ...⟩
```

This halves the work: only implement `.ex`, derive `.all` via negation.

For `.ex`, there is NO simpler formulation that avoids the atom-elimination pipeline. The pipeline IS the standard proof. However, the existing infrastructure (`reduceElimLast_correct_at_one`, `q_exists_correct`, purity substitution lemmas) makes it mechanical. Estimated remaining: ~350 LOC for Sub-tasks A, B, C combined.

## Recommended Approach

### Phase 6: Axiom Elimination (Priority: HIGH)

**Strategy**: "Reduce H/G to S/U, then induct without circularity"

1. **Prove `all_past_as_snce` and `all_future_as_untl`** (~30 LOC each). These are simple semantic proofs over integer time using the fact that S(T, phi) is always satisfiable (take predecessor as witness for the empty interval).

2. **Define `eliminate_H_G`** (~20 LOC) and prove `eliminate_H_G_equiv` (~40 LOC).

3. **Prove `pure_US_no_S_nested_separable`** (~200-300 LOC). This is the core induction, using:
   - Cases 1-4 (already proved) for the JD=1 subcases
   - The abstract_untl infrastructure (already proved) for multi-U reduction
   - Junction-depth as the well-founded measure
   - NO `all_past`/`all_future` cases to worry about

4. **Derive the 8 temporal closure theorems** (~50 LOC each, ~100 LOC total leveraging duality):
   ```lean
   theorem snce_separable_proved ... := by
     -- Get witnesses, eliminate H/G, apply pure_US_no_S_nested_separable
   theorem untl_separable_proved ... := by
     -- Duality from snce_separable_proved
   theorem all_past_separable_proved ... := by
     -- Reduce to snce case via all_past_as_snce
   theorem all_future_separable_proved ... := by
     -- Duality from all_past_separable_proved
   ```

5. **Replace axioms** in SeparationThm.lean with the proved theorems.

**Total estimated**: ~400-500 LOC

### Phase 7: Quantifier Elimination (Priority: MEDIUM)

1. Implement `.all` via negation of `.ex` (~20 LOC)
2. Implement `.ex` case with:
   - Sub-task A: const_at_ref case-split (~150 LOC)
   - Sub-task B: lt_ref/gt_ref level-aware substitution (~200 LOC)  
   - Sub-task C: extAtomMap injectivity (~50 LOC)
   - Assembly (~80 LOC)

**Total estimated**: ~500 LOC

## Evidence/Examples

### Example: all_past_as_snce correctness

Over integer time, at point t:
- LHS: `all_past phi` at t iff phi(s) for all s < t
- RHS: `neg(snce (neg phi) top)` at t
  - snce (neg phi) top at t = exists s < t with (neg phi)(s) and top(r) for all r in (s,t)
  - = exists s < t with NOT phi(s) [top is always true]
  - = NOT(all_past phi) at t
  - So neg(snce (neg phi) top) ↔ all_past phi

### Example: JD=0 base case in pure {U,S} fragment

Formula: `.snce (.imp (.untl A B) (.atom p)) (.atom q)` with A, B atoms.
- `no_S_nested_in_U`: the untl args are atoms (S-free). Check.
- `junction_depth`: JD_S of `.untl A B` = 1 + max(JD(A), JD(B)) = 1. So JD of the snce = max(1, 0) = 1.
- Apply Cases 1-4: The event contains U(A,B) directly. This is Case 1 pattern: S(event ∧ U(A,B), guard).

After DNF decomposition of the event, we get:
- `S(untl A B ∧ neg(atom p), atom q)` -- Case 2 pattern (neg U in event)  
- `S(untl A B ∧ atom p, atom q)` -- Case 1 pattern (U in event)

Both handled by existing proved Cases 1 and 2.

### Example: Pure {U,S} induction terminates

Starting formula: `.snce (.snce (.untl A B) (.atom p)) (.untl C D)` (JD = 2)
1. Both args satisfy no_S_nested_in_U. IH gives separated witnesses.
2. Witnesses are e.g. `.imp (.untl A B) (.snce (.atom p) (.atom p))` (JD=1) etc.
3. `.snce witness1 witness2` has JD <= 1 (by snce_of_boxfree_sep_jd_le_one).
4. Since JD dropped from 2 to 1, WF induction applies.
5. At JD=1, Cases 1-4 handle it directly.

## Confidence Level

- **Phase 6 strategy correctness**: HIGH (90%). The `all_past_as_snce` reduction eliminates the circularity cleanly. The only risk is if `eliminate_H_G` creates formulas that don't satisfy `no_S_nested_in_U` in all the right places, but the semantic equivalence ensures the separated equivalent exists regardless.

- **Phase 6 implementability**: MEDIUM-HIGH (75%). The pure {U,S} induction is straightforward once H/G are eliminated. The main complexity is setting up the WF induction correctly in Lean 4 (may need `WellFounded.fix` with explicit measures).

- **Phase 7 strategy**: HIGH (95%). The approach is entirely mechanical given existing infrastructure. Main risk is LOC count (could be 600+ rather than 500).

- **Zero-sorry achievability**: MEDIUM (65%). Both phases are solvable without sorry, but the complexity of the WF setup for Phase 6 and the case-split enumeration for Phase 7 create significant implementation surface area. A disciplined implementation following this plan should succeed.

## Summary

The central insight for Phase 6 is: **reduce all_past/all_future to snce/untl via integer-time equivalences BEFORE applying junction-depth induction**. This converts the problem from one with circular dependencies (temporal closure axioms depend on themselves) into a straightforward well-founded induction on the pure {U, S, imp, bot, atom} fragment where the only temporal cases are snce (handled by Cases 1-4 + JD measure) and untl (immediately separated when no_S_nested_in_U holds).

For Phase 7, there is no simpler alternative to the atom-elimination pipeline, but the `.all` case derives from `.ex` via negation, and the existing purity/substitution lemmas provide most of the needed infrastructure.
