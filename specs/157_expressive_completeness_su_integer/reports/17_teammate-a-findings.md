# Teammate A Findings: Primary Approach for Axiom-Free Separation

**Task**: 157
**Date**: 2026-05-19
**Angle**: Primary implementation approach
**Status**: Complete

---

## Key Findings

### 1. The Root Cause: Wrong Induction Strategy in `single_U_formula_separable`

The current `single_U_formula_separable` (Hierarchy.lean:170) uses **structural induction** on the formula. At the `.snce ψ₁ ψ₂` case it calls `snce_separable` (axiom) because structural induction provides no decreasing measure — `ψ₁` and `ψ₂` are structurally smaller but the proof needs to handle the S-nesting of U(A,B) within them.

GHR94 Lemma 10.2.5 uses **induction on `snce_depth_of_U`** (the max number k of nested S-nodes above any U(A,B)). At depth k > 0, it applies Lemma 10.2.4 to the most deeply nested S(C,F) containing U(A,B), reducing the depth by 1. This is fundamentally different from structural induction.

### 2. The Existing Infrastructure Is Sufficient

The codebase already has ALL the pieces needed for an axiom-free proof:

| Component | Location | Status |
|-----------|----------|--------|
| Cases 1-4 (S with atoms + U) | `Eliminations.lean` | Axiom-free ✓ |
| Cases 5-8 (S with atoms + U) | `DedekindZ.lean` | Axiom-free ✓ |
| All 8 case wrappers | `NormalForm.lean:113-193` | Axiom-free ✓ |
| `lemma_10_2_4` (combined) | `NormalForm.lean:346-367` | Axiom-free ✓ |
| `since_event_split` | `Eliminations.lean:697` | Axiom-free ✓ |
| `since_event_split_separable` | `NormalForm.lean:379-384` | Axiom-free ✓ |
| `replace_untl` + properties | `Hierarchy.lean:1514-1610` | Axiom-free ✓ |
| `single_U_and_conj_simplify` | `Hierarchy.lean:1612-1625` | Axiom-free ✓ |
| `snce_depth_of_U` + properties | `Hierarchy.lean:1281-1339` | Axiom-free ✓ |
| `snce_depth_zero_no_S_nested_separated` | `Hierarchy.lean:1356-1377` | Axiom-free ✓ |

### 3. GHR94 10.2.4's Actual Proof Strategy

GHR94 10.2.4 says: Given S(C, F) where C and F contain only U(A,B) at top level (not under any S), rearrange into CNF/DNF w.r.t. U(A,B) to get boolean combinations of the 8 standard cases.

The codebase approximation is:
1. **Event-split** on U(A,B): `S(C, F) ↔ S(C ∧ U(A,B), F) ∨ S(C ∧ ¬U(A,B), F)` (via `since_event_split`)
2. **Simplify events**: `C ∧ U(A,B) ≡ C[U:=⊤] ∧ U(A,B)` where `C[U:=⊤]` is U-free (via `single_U_and_conj_simplify`). Similarly for `¬U(A,B)`.
3. **Guard-split** on U(A,B): Split F into U-free part and U(A,B)-containing part
4. **Match to Cases 1-8**: Each resulting form matches exactly one case

**Critical requirement**: The event-splitting produces `a = replace_untl C A B ⊤` (or `⊥`) which is U-free. But Cases 1-8 also require `a` to be **S-free**. Since `snce_depth_of_U C = 0` and `has_single_U_type C A B`, the `.snce` nodes in C must have U-free args (depth 0 means if-branch triggers, meaning both args are U-free). But C itself might contain `.snce` — however, since C is an arg of the **outermost** S and the U(A,B) in C are at depth 0, C must be S-free for those U's. Wait — this needs careful analysis.

Actually, re-reading GHR94 10.2.4 carefully: "both wffs C and F are such that each appearance of U in either of them is as U(A, B) and **is not nested under any Ss**." This means C and F have NO S-nodes containing U(A,B) at all. The U(A,B) appearances are at the **top level** of C and F (not under S within C or F). 

In our formalization: `snce_depth_of_U C = 0` means every `.snce` node in C has U-free args. If `has_single_U_type C A B` and `snce_depth_of_U C = 0`, then any `.snce` in C has U-free (hence U(A,B)-free) args. The U(A,B) nodes in C are outside all `.snce` subformulas. After `replace_untl C A B r`, the result is U-free. But is it S-free? No — C can contain `.snce` nodes with U-free args (those are pure-past subformulas). So `replace_untl C A B ⊤` may contain `.snce`.

**This is the gap**: Cases 1-8 require `a` and `q` to be both U-free AND S-free. But the event after event-splitting, `replace_untl C A B ⊤`, is only guaranteed U-free, not S-free.

### 4. How GHR94 Handles This Gap

GHR94 10.2.4 says: "by rearrangement of C and F into disjunctive and conjunctive normal form, respectively, and repeated use of lemma 10.2.1 we can rewrite S(C, F) equivalently as a boolean combination of wffs S(C₁, C₂) with no U appearing and wffs of the form either S(C₁, C₂ ∨ ±U(A, B)) or S(C₁ ∧ ±U(A, B), C₂ ∨ ±U(A, B)) for some boolean combinations C₁ and C₂ of **atoms and pure past formulae**."

The key: after CNF/DNF decomposition, the atoms/pure-past parts become C₁ and C₂. Since U(A,B) is at top level and S(C₁, C₂) with no U is already separated, and the 8 cases handle the remaining forms... But wait — GHR94's C₁, C₂ are "boolean combinations of atoms and pure past formulae", not just atoms. The existing Cases 1-8 require `a`, `q` to be atoms (or at least U-free and S-free formulas).

**Looking at the actual theorem signatures**: `case5_separable_Z_gen` (DedekindZ.lean:991) requires `ha : is_U_free a = true`, `hq : is_U_free q = true`, `hA : is_U_free A = true`, `hB : is_U_free B = true`, `hA' : is_S_free A = true`, `hB' : is_S_free B = true`. It does NOT require `ha' : is_S_free a` or `hq' : is_S_free q`. 

Wait, let me re-check. `case5_separable_Z` has `_ha' : is_S_free a` and `_hq' : is_S_free q` but they're unused (prefixed with `_`). `case5_separable_Z_gen` drops these entirely and only requires `ha : is_U_free a` and `hq : is_U_free q`.

So Cases 5-8 via `_gen` variants DON'T require S-free `a`, `q`! They only need U-free `a`, `q` and S-free, U-free `A`, `B`.

But Cases 1-4 DO require S-free `a` and `q`. `elim_case_1_gen` requires `ha : is_U_free a` and `hq : is_U_free q` but drops S-free for a, q. Let me verify...

Actually, `elim_case_1_gen` (Eliminations.lean:179) requires U-free a, q and S-free, U-free A, B. Same for `elim_case_2_gen` (line 354). But let me check the wrappers in NormalForm.lean — `case1_separable` (line 113) requires both U-free AND S-free for a and q. This is because it calls `elim_case_1` not `elim_case_1_gen`.

**Key insight**: If we use `elim_case_1_gen` and `elim_case_2_gen` (which drop S-free requirements on a, q), and `case5_separable_Z_gen` through `case8_separable_Z_gen` (which drop S-free on a, q), then we can handle the case where `a` and `q` are merely U-free (not S-free).

### 5. The Path Forward: A New `single_U_formula_separable_noax`

The axiom-free version of GHR94 10.2.5 should use **strong induction on `snce_depth_of_U`** instead of structural induction:

```
theorem single_U_formula_separable_noax (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable φ
```

**Proof by strong induction on `snce_depth_of_U φ`**:

- **Base cases** (atom, bot, box, imp): Same as current structural induction — these are trivial.
  - `atom`: already separated
  - `bot`: already separated
  - `box`: already separated
  - `imp ψ₁ ψ₂`: by `imp_separable` applied to IH on ψ₁ and ψ₂ (which have `snce_depth_of_U ≤` original)

- **`.untl` case**: Since `has_single_U_type` forces `ψ₁ = A, ψ₂ = B`, this is `U(A,B)` with S-free args — directly separated.

- **`.snce ψ₁ ψ₂` case** (THE KEY): This is where the axiom was needed. Now:
  1. If both ψ₁, ψ₂ are U-free: `snce_depth_of_U (.snce ψ₁ ψ₂) = 0`, so the formula is already separated by `snce_depth_zero_no_S_nested_separated` (if we can show `no_S_nested_in_U`... but actually we just need U-free args for `snce` to be separated).

     Actually, if both ψ₁ and ψ₂ are U-free, `.snce ψ₁ ψ₂` is syntactically separated (since snce args are U-free). Done.

  2. If not both U-free: `snce_depth_of_U (.snce ψ₁ ψ₂) = 1 + max(snce_depth_of_U ψ₁, snce_depth_of_U ψ₂) ≥ 1`.
  
     Apply GHR94 10.2.4 reasoning:
     - Event-split on U(A,B): `S(ψ₁, ψ₂) ↔ S(ψ₁ ∧ U(A,B), ψ₂) ∨ S(ψ₁ ∧ ¬U(A,B), ψ₂)` via `since_event_split`.
     - Simplify: `ψ₁ ∧ U(A,B) ≡ ψ₁[U:=⊤] ∧ U(A,B)` via `single_U_and_conj_simplify` (needs `snce_depth_of_U ψ₁ = 0`... but this might not hold if U(A,B) is nested under S in ψ₁!).

     **Problem**: `single_U_and_conj_simplify` requires `snce_depth_of_U C = 0`. But at `.snce ψ₁ ψ₂`, ψ₁ can have arbitrary `snce_depth_of_U`. The simplification only works at depth 0.

     **GHR94's approach**: "Apply [10.2.4] to each of the **most deeply nested** S(C,F) in which U(A,B) appear." This means finding the INNERMOST `.snce` containing U(A,B) and applying the event-split + cases there, not at the outermost level.

     This is the crux: we need to find the innermost `.snce` containing U(A,B), apply 10.2.4 there (which reduces `snce_depth_of_U` by 1 at that point), and then use the IH.

### 6. Implementing "Apply at Innermost S"

The GHR94 approach requires a function that:
1. Finds the innermost `.snce C F` in φ where U(A,B) appears in C or F
2. At that innermost `.snce`, applies Lemma 10.2.4 (event-split + cases) to produce an equivalent formula
3. The result has `snce_depth_of_U` strictly decreased

This is essentially a **rewriting operation** that works at the innermost S-node containing U. We can implement this as:

```lean
def reduce_innermost_S_containing_U (φ A B : Formula) 
    (h_single : has_single_U_type φ A B) : Formula × Proof_of_equivalence
```

At each `.snce C F` where not both C, F are U-free:
- If `snce_depth_of_U C = 0 ∧ snce_depth_of_U F = 0`: This IS the innermost S. Apply event-split + Cases 1-8. The result is a boolean combination of S-free-U-free formulas, U(A,B), and S(X,Y) where X,Y don't contain U(A,B). In the result, `snce_depth_of_U` is 0 for these components.
- If `snce_depth_of_U C > 0` or `snce_depth_of_U F > 0`: Recurse into C or F to find the innermost S.

**However**, this is complex to implement in Lean 4 because it requires building up equivalence proofs through formula context. A simpler approach exists.

### 7. Simpler Alternative: Two-Level Induction in `no_S_nested_in_U_separable_param`

Instead of modifying `single_U_formula_separable`, we can bypass it entirely by making `no_S_nested_in_U_separable_param_jd` self-sufficient.

The existing `no_S_nested_in_U_separable_param_jd` (Hierarchy.lean:1801) takes a callback `∀ (χ : Formula), no_S_nested_in_U χ → junction_depth χ ≤ 1 → is_separable χ`. The callback formulas have:
- `no_S_nested_in_U χ`
- `junction_depth χ ≤ 1`
- `χ = .snce (subst_formula c p (.untl A B)) (subst_formula d p (.untl A B))` where c, d are U-free

**Critical observation**: The callback formula `χ` has `has_single_U_type χ A B` (because c, d are U-free from the separated form, so substituting p → U(A,B) produces single-U-type formulas). And the U-args A, B are S-free (from `extract_U_type_S_free`).

So if we had an axiom-free `single_U_formula_separable`, the callback would work. The problem circles back to making `single_U_formula_separable` axiom-free.

### 8. The Simplest Viable Approach

After careful analysis, I believe the simplest approach is:

**Write `single_U_formula_separable_depth` using strong induction on `snce_depth_of_U`**:

```lean
theorem single_U_formula_separable_depth (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable φ := by
  induction h : snce_depth_of_U φ using Nat.strongRecOn generalizing φ with
  | ind k ih =>
  match φ, h_single with
  | .atom _, _ => exact ⟨.atom _, rfl, int_equiv_refl _⟩
  | .bot, _ => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | .imp ψ₁ ψ₂, ⟨h1, h2⟩ =>
    exact imp_separable
      (ih _ (by simp [snce_depth_of_U] at h; omega) ψ₁ h1 rfl)
      (ih _ (by simp [snce_depth_of_U] at h; omega) ψ₂ h2 rfl)
  | .box ψ, _ => exact ⟨.box ψ, rfl, int_equiv_refl _⟩
  | .untl ψ₁ ψ₂, ⟨heq1, heq2⟩ =>
    subst heq1; subst heq2
    exact untl_s_free_separable hA_sf hB_sf
  | .snce C F, ⟨hC_single, hF_single⟩ =>
    -- THIS is the key case
    -- snce_depth_of_U (.snce C F) = if U-free then 0 else 1 + max(...)
    by_cases huf : is_U_free C = true ∧ is_U_free F = true
    · -- Both U-free: already syntactically separated
      exact ⟨.snce C F, by simp [is_syntactically_separated, huf.1, huf.2],
             int_equiv_refl _⟩
    · -- Not both U-free: depth ≥ 1
      -- Apply Lemma 10.2.4 at the outermost level:
      -- We need snce_depth_of_U C = 0 AND snce_depth_of_U F = 0
      -- i.e., U(A,B) is at top level in C and F (not under nested S)
      -- If not, we need to recurse into C or F first.
      --
      -- But with strong induction on snce_depth_of_U, we can handle this:
      -- C has snce_depth_of_U C < snce_depth_of_U (.snce C F)
      -- F has snce_depth_of_U F < snce_depth_of_U (.snce C F)
      -- So by IH, C is separable and F is separable.
      -- Then... we still need snce_separable!
      --
      -- Wait. This doesn't work. Strong induction on snce_depth_of_U
      -- with structural sub-cases doesn't help because knowing C and F
      -- are individually separable doesn't prove .snce C F is separable
      -- without snce_separable.
      sorry
```

**The fundamental issue**: Even with `snce_depth_of_U` induction, at the `.snce C F` case we know C and F are separable by IH, but we need to prove `.snce C F` is separable, which IS `snce_separable`.

**GHR94's proof does NOT say "C is separable and F is separable, therefore S(C,F) is separable."** Instead, it says **"apply 10.2.4 to the innermost S containing U to reduce the depth."** This is a DIFFERENT operation — it transforms the formula, not its sub-formulas.

### 9. The Correct GHR94-Faithful Approach

The correct implementation requires a function `reduce_snce_depth` that:

Given `.snce C F` with `snce_depth_of_U (.snce C F) = k + 1` and `has_single_U_type`:
1. If `snce_depth_of_U C = 0 ∧ snce_depth_of_U F = 0`: Apply Lemma 10.2.4 directly (event-split + Cases 1-8). The result is a separated equivalent. Done.
2. If `snce_depth_of_U C > 0`: C has the form ... with inner `.snce` nodes containing U(A,B). By IH on C (which has `snce_depth_of_U C < snce_depth_of_U (.snce C F)`), C is equivalent to a formula C' where `snce_depth_of_U C' < snce_depth_of_U C`. But that uses the IH on C as a whole formula, not on `.snce C F`.

Actually, wait. Let me re-read GHR94 10.2.5 once more:

> "Apply the preceding lemma [10.2.4] to each of the most deeply nested S(C, F) in which U(A, B) appear and then we have an equivalent wff in which the maximum depth of nesting of U(A,B) is reduced."

GHR94 is saying: find ALL innermost S-nodes containing U(A,B) in the whole formula D, apply 10.2.4 to each one, and the result is equivalent to D with reduced depth. This is a global formula transformation, not a sub-formula-by-sub-formula approach.

The simplest implementation in Lean:

```lean
def reduce_all_innermost_S (D A B : Formula) : Formula
-- traverses D, at each .snce C F where snce_depth_of_U (.snce C F) = 1
-- (meaning C, F both have snce_depth = 0, meaning U(A,B) is at top level in C, F),
-- replaces .snce C F with its Lemma-10.2.4 separated equivalent.
-- At .snce C F where depth > 1, recurses into C and F.
-- The result has snce_depth_of_U strictly less than the original.
```

This is feasible but requires building the separated equivalent constructively (not just existentially). Cases 1-8 in Eliminations and DedekindZ produce `is_separable` which is `∃ psi, is_syntactically_separated psi ∧ int_equiv φ psi` — they're existential, not constructive.

**However**, we don't need constructive witnesses. We just need to prove the EXISTS claim. The approach:

```lean
theorem single_U_formula_separable_noax (D A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
    (h_single : has_single_U_type D A B) :
    is_separable D := by
  -- Strong induction on snce_depth_of_U D
  induction h : snce_depth_of_U D using Nat.strongRecOn generalizing D with
  | ind k ih =>
  cases D with
  | snce C F =>
    -- Case: .snce C F
    by_cases huf : is_U_free C = true ∧ is_U_free F = true
    · -- Depth 0: U-free args → syntactically separated
      exact ⟨.snce C F, by simp [is_syntactically_separated, huf.1, huf.2], int_equiv_refl _⟩
    · -- Depth ≥ 1
      have h_depth : snce_depth_of_U (.snce C F) ≥ 1 := by
        simp [snce_depth_of_U, huf]; omega
      -- C and F have snce_depth < depth of .snce C F
      have hC_lt : snce_depth_of_U C < k := by simp [snce_depth_of_U, huf] at h; omega
      have hF_lt : snce_depth_of_U F < k := by simp [snce_depth_of_U, huf] at h; omega
      -- By IH: C and F are separable
      have hC_sep := ih _ hC_lt C h_single.1 rfl
      have hF_sep := ih _ hF_lt F h_single.2 rfl
      -- Get separated witnesses
      obtain ⟨C', hC'_sep, hC'_equiv⟩ := hC_sep
      obtain ⟨F', hF'_sep, hF'_equiv⟩ := hF_sep
      -- .snce C F ≡ .snce C' F'
      have hequiv := snce_congr hC'_equiv hF'_equiv
      -- Now: .snce C' F' where C' and F' are syntactically separated
      -- A syntactically separated formula has U-free .snce-args and S-free .untl-args
      -- So C' is U-free and F' is U-free (from is_syntactically_separated)
      -- Therefore .snce C' F' is syntactically separated!
      have hC'_uf : is_U_free C' = true := separated_implies_U_free C' hC'_sep
      have hF'_uf : is_U_free F' = true := separated_implies_U_free F' hF'_sep
      exact is_separable_of_equiv hequiv
        ⟨.snce C' F', by simp [is_syntactically_separated, hC'_uf, hF'_uf], int_equiv_refl _⟩
  | -- other cases: atom, bot, imp, box, untl
    ...
```

**Wait — this actually WORKS!** Here's the key insight I missed:

When we have `.snce C F` with `has_single_U_type` and we inductively separate C and F (by IH on `snce_depth_of_U`), we get C' and F' that are **syntactically separated**. A syntactically separated formula has **U-free** `.snce` args and **S-free** `.untl` args. Since C' is syntactically separated, it must be U-free (because for `.snce` nodes, `is_syntactically_separated` requires both args to be U-free). Similarly F' is U-free.

So `.snce C' F'` has **U-free** args, which means it IS syntactically separated!

**But wait**: Is `is_syntactically_separated` defined such that a syntactically separated formula's top level is U-free? Let me check.

Actually no — `is_syntactically_separated` for `.snce a b` checks `is_U_free a ∧ is_U_free b`. For `.untl a b` it checks `is_S_free a ∧ is_S_free b`. For `.imp a b` it checks `is_syntactically_separated a ∧ is_syntactically_separated b`. For `.box a` it's `true` (always separated). For `.atom` and `.bot` it's `true`.

So a syntactically separated formula at its **top level** is a boolean combination of:
- Atoms and bot (trivially U-free and S-free)
- `.box φ` (which could contain anything)
- `.untl a b` with S-free a, b (which IS U-free only if a, b are U-free... but they could contain U)
- `.snce a b` with U-free a, b

So `is_syntactically_separated C' = true` does NOT imply `is_U_free C' = true`. For example, `U(A, B)` is syntactically separated (`.untl A B` with S-free A, B) but NOT U-free!

**Correction**: A syntactically separated formula can still contain U at the top level (as `.untl` with S-free args). So C' being syntactically separated doesn't mean C' is U-free.

However, the GHR94 claim is stronger: GHR94 10.2.5 says "D is equivalent to a syntactically separated wff **in which U only appears as the formula U(A, B)**." This means the separated equivalent preserves the single-U-type property. So C' has `has_single_U_type C' A B` AND is syntactically separated. The U in C' is only as `U(A,B)`.

In fact, for our purposes we need something different. We need `.snce C' F'` to be separable, not just C' and F' individually. And the critical point is: with the IH approach, C' and F' are separated, which means they're boolean combinations of pure-past and pure-future parts. A `.snce` of two separated formulas should be separable... but proving this IS `snce_separable`.

**Conclusion**: The IH-on-subformulas approach doesn't work because it reduces to `snce_separable`.

### 10. The Actually Correct Approach: Rewrite-at-Innermost

GHR94 10.2.5's proof is NOT "separate C, separate F, then conclude S(C,F) is separable." It's: "find the innermost S containing U in the WHOLE formula D, rewrite that S using 10.2.4 to remove U from under it, and repeat." The result is a formula equivalent to D with no U under any S, which is syntactically separated.

This requires implementing a **context-aware rewriting operation** on the formula D. Here's a clean implementation:

```lean
/-- Apply Lemma 10.2.4 at the innermost .snce containing U(A,B).
    When snce_depth_of_U = 0: identity (nothing to do).
    When snce_depth_of_U > 0: find innermost .snce with U-containing args,
    replace it with its separated equivalent (from Cases 1-8). -/
noncomputable def apply_10_2_4_at_innermost (D A B : Formula) 
    (h_single : has_single_U_type D A B) : 
    {D' : Formula // int_equiv D D' ∧ snce_depth_of_U D' < snce_depth_of_U D 
                   ∧ has_single_U_type D' A B}
```

Actually, this is hard because the separated equivalent from Cases 1-8 is existential, not constructive. And we'd need to prove `has_single_U_type` is preserved, and `snce_depth_of_U` strictly decreases.

**A much simpler approach** exists: instead of rewriting at the innermost level, we can use **two-level strong induction** on `(snce_depth_of_U, sizeOf)` in lexicographic order.

At `.snce C F`:
- The sub-formulas C and F have `snce_depth_of_U C < snce_depth_of_U (.snce C F)` (when not both U-free).
- By IH, there exist C' ≡ C and F' ≡ F that are separated with single U-type U(A,B).
- `.snce C F ≡ .snce C' F'`
- C' is separated: boolean combo of atoms, U(A,B), and pure-past formulas
- F' is separated: same
- `.snce C' F'` has `has_single_U_type` with U(A,B) and `snce_depth_of_U ≤ 1` (since C' and F' are separated, any U in C' is at top level, so `snce_depth_of_U C' = 0` and `snce_depth_of_U F' = 0`)

Wait, that's the key: if C' is syntactically separated and has single U-type, then `snce_depth_of_U C' = 0` because every `.snce` node in C' has U-free args (from `is_syntactically_separated`), and every U in C' is at top level.

So `.snce C' F'` has `snce_depth_of_U (.snce C' F') = 1` (since C' or F' has U(A,B) at top level, so not both U-free, depth = 1 + max(0, 0) = 1).

This is exactly the depth-1 case — Lemma 10.2.4! And we have the infrastructure for this (Cases 1-8 via event-split).

**But**: 10.2.4 requires the formula to have the form S(C, F) where C and F have U(A,B) at top level only. And C' and F' ARE such formulas (syntactically separated with single U-type means U only at top level). However, C' and F' are NOT atoms — they're boolean combinations. The 8 cases require `a`, `q` to be U-free (and the `_gen` variants handle non-S-free).

This means we need to **decompose** `.snce C' F'` using the event-split and CNF/DNF infrastructure to reduce to Cases 1-8. The existing `replace_untl` + `single_U_and_conj_simplify` already handles the key step: `C' ∧ U(A,B) ≡ C'[U:=⊤] ∧ U(A,B)` where `C'[U:=⊤]` is U-free.

**Complete strategy for `.snce C F` case at depth k + 1**:

1. By IH, get C' ≡ C (separated, single-U-type) and F' ≡ F (same)
2. `.snce C F ≡ .snce C' F'`
3. `snce_depth_of_U C' = 0` and `snce_depth_of_U F' = 0` (from separated + single-U-type)
4. Apply event-split: `.snce C' F' ≡ S(C' ∧ U(A,B), F') ∨ S(C' ∧ ¬U(A,B), F')`
5. Simplify events: `C' ∧ U(A,B) ≡ C'[U:=⊤] ∧ U(A,B)`, `C' ∧ ¬U(A,B) ≡ C'[U:=⊥] ∧ ¬U(A,B)` (using `single_U_and_conj_simplify` — works because `snce_depth_of_U C' = 0`)
6. Guard-split F' similarly
7. Each resulting term has form S(a ∧ ±U(A,B), q ∨ ±U(A,B)) where a, q are U-free
8. Apply Cases 1-8 (via `_gen` variants that only need U-free, not S-free)
9. Each case produces a separable formula; combine via `or_separable`, `and_separable`

**But step 8 has a subtlety**: Cases 1-8 require a, q to be U-free AND S-free for some variants. The `_gen` variants of Cases 5-8 only need U-free. But Cases 3 and 4 (`elim_case_3`, `elim_case_4`) require both U-free and S-free for a and q.

After step 5, `a = replace_untl C' A B ⊤` is U-free (proved by `replace_untl_U_free`). But is it S-free? C' is syntactically separated, so it can contain `.snce` nodes (with U-free args). After `replace_untl`, the `.snce` nodes remain. So `a` may NOT be S-free.

**This means we need generalized versions of Cases 3 and 4 that only require U-free, not S-free.** Or we need to decompose further using distributivity.

Actually, looking at `case3_equiv_Z_general` in DedekindZ.lean, let me check if there are `_gen` versions...

The DedekindZ file has `case3_equiv_Z_general` (line 480) but it's for a different purpose. The standard versions in NormalForm.lean all require S-free. 

**Alternative**: Instead of event-splitting, we can use the **existing `no_S_nested_in_U_separable_param`** which already handles the decomposition correctly. The key insight is:

If we can provide an axiom-free callback to `no_S_nested_in_U_separable_param`, the whole chain works. The callback receives formulas with `no_S_nested_in_U` that come from substituting U(A,B) into U-free positions of a separated form. These callback formulas have `has_single_U_type` and `snce_depth_of_U ≤ 1`.

So the callback IS exactly the depth-1 case of `single_U_formula_separable_depth`! And at depth 1, the `.snce` case has `snce_depth_of_U C = 0` and `snce_depth_of_U F = 0`, meaning U(A,B) is at top level in both C and F. This is exactly the situation where `single_U_and_conj_simplify` works, and we can apply Cases 1-8.

**The remaining question**: Can we handle the Cases 3, 4 (which need S-free a, q) at depth 1?

At depth 1, C and F have `snce_depth_of_U = 0` AND `has_single_U_type`. Any `.snce` node in C has U-free args (from depth 0). Does C being a subformula of a `no_S_nested_in_U` formula help? Yes! `no_S_nested_in_U` means every `.untl` arg is S-free. Since C is an arg of `.snce` (not `.untl`), this doesn't directly help. But the callback formula comes from `subst_in_separated_separable` which produces `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free. The question is whether `subst c p (.untl A B)` (with U-free c) can contain `.snce` nodes.

Yes! c is U-free but not necessarily S-free (it's a sub-formula of a separated form, which can contain `.snce` in the "past" branches). So after substitution, `subst c p (.untl A B)` can contain `.snce` nodes from c.

**However**, for depth 1 with `has_single_U_type`, `replace_untl C A B ⊤` removes all U(A,B) from C, leaving only the S-structure. The resulting `a = replace_untl C A B ⊤` is U-free but may contain `.snce`. For Cases 1-8 to work with non-S-free a, we need `_gen` variants.

`elim_case_1_gen` (Eliminations.lean:179) and `elim_case_2_gen` (line 354) already exist and drop the S-free requirement on a, q. `case5_separable_Z_gen` (DedekindZ.lean:991) also drops S-free on a, q. We need to verify Cases 3, 4, 6, 7, 8 have similar `_gen` variants or can work without S-free a, q.

---

## Recommended Approach

### Step 1: Verify/Create `_gen` Variants for All 8 Cases (~2-4 hours)

Ensure all 8 elimination cases have versions requiring only:
- `is_U_free a = true`, `is_U_free q = true` (NOT S-free)
- `is_U_free A = true`, `is_U_free B = true`, `is_S_free A = true`, `is_S_free B = true`

Cases 1, 2, 5 already have `_gen` variants. Cases 3, 4, 6, 7, 8 may need new `_gen` variants or the existing proofs may work with weakened hypotheses.

### Step 2: Implement `snce_depth_1_separable` (~3-4 hours)

A theorem handling `.snce C F` with `has_single_U_type C A B`, `has_single_U_type F A B`, `snce_depth_of_U C = 0`, `snce_depth_of_U F = 0`, and S-free, U-free A, B:

```lean
theorem snce_depth_1_separable (C F A B : Formula)
    (hA_sf : is_S_free A) (hB_sf : is_S_free B)
    (hA_uf : is_U_free A) (hB_uf : is_U_free B)
    (hC_single : has_single_U_type C A B)
    (hF_single : has_single_U_type F A B)
    (hC_depth : snce_depth_of_U C = 0)
    (hF_depth : snce_depth_of_U F = 0) :
    is_separable (.snce C F)
```

Proof via event-split on U(A,B), simplification to U-free event using `single_U_and_conj_simplify`, guard analysis, and application of Cases 1-8 `_gen` variants.

### Step 3: Implement `single_U_formula_separable_noax` (~2 hours)

Strong induction on `snce_depth_of_U`:
- Depth 0 (all cases except `.snce` with U-containing args): structural
- `.snce` case: IH gives separated C' ≡ C and F' ≡ F. Then `snce_depth_of_U C' = 0` and `snce_depth_of_U F' = 0` (separated + single-U-type). Apply `snce_depth_1_separable`.

### Step 4: Use `single_U_formula_separable_noax` as Callback (~1 hour)

Replace `all_separable` callback with `single_U_formula_separable_noax` in:
- `no_S_nested_in_U_separable_param` (directly, or via a new wrapper)
- `all_formulas_separable_aux` n=1 case

### Step 5: Eliminate Axioms (~2 hours)

Once `all_formulas_separable` is axiom-free, replace all 9 axioms in SeparationThm.lean.

---

## Evidence/Examples

### The Key Equivalence Chain

```
.snce C F                                    -- has_single_U_type, depth k+1
≡ .snce C' F'                               -- by IH: C' ≡ C, F' ≡ F separated
  where snce_depth_of_U C' = 0, snce_depth_of_U F' = 0
≡ S(C'∧U, F') ∨ S(C'∧¬U, F')              -- event-split
≡ S(a∧U, F') ∨ S(a'∧¬U, F')               -- simplify (a = C'[U:=⊤], a' = C'[U:=⊥])
  where a, a' are U-free
≡ [Cases 1-8 decomposition]                  -- guard-split F' and match
→ is_separable                               -- each case proved axiom-free
```

### Proof That `snce_depth_of_U C' = 0` When C' Is Separated with Single U-Type

If `is_syntactically_separated C' = true` and `has_single_U_type C' A B`:
- Every `.snce` node in C' has U-free args (from `is_syntactically_separated`)
- Since args are U-free, `snce_depth_of_U` at each `.snce` is 0 (the if-branch triggers)
- `snce_depth_of_U` is max over subterms, so `snce_depth_of_U C' = 0`

This follows from `snce_depth_of_U_zero_of_U_free` for the `.snce` sub-formulas, plus structural induction showing max over sub-formulas is 0.

Actually, this needs a small lemma: `is_syntactically_separated C' → snce_depth_of_U C' = 0`. This should be straightforward by induction on C'.

---

## Confidence Level

**Medium-High**

The overall strategy is sound — GHR94 10.2.5 via `snce_depth_of_U` induction is the correct approach, and the codebase has nearly all the infrastructure. The main uncertainty is:

1. **Whether `_gen` variants exist or are easy to create for Cases 3, 4, 6, 7, 8** — these need U-free (not S-free) a, q. The semantic arguments in the proofs may or may not depend on S-freeness of a, q.

2. **The guard analysis in Step 2** — decomposing F into q-part and U-part requires careful handling. The existing `guard_lem_equiv` infrastructure helps but may need extension.

3. **The snce_depth_of_U = 0 claim for separated formulas** — this seems correct but needs a clean proof.

Estimated total effort: 10-14 hours for the complete axiom elimination, starting from the current state (Phase 3 tasks 3.1-3.3 done).
