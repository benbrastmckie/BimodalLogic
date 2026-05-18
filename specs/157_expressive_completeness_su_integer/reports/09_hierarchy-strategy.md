# Hierarchy Strategy Report: Task #157 Phase 3

**Date**: 2026-05-18
**Focus**: Concrete implementation strategy for GHR94 Lemmas 10.2.5-10.2.8 in Lean 4

## Executive Summary

The hierarchy can be implemented by proving **one key lemma** non-circularly: `no_S_nested_in_U_separable`. Once this exists, `junction_depth_separable` follows by a standard strong induction, and all 9 axioms are eliminated. The critical insight is that `no_S_nested_in_U_separable` does NOT need temporal closure axioms — it can be proved by well-founded induction on `(count_U_subformulas, Formula.sizeOf)` using only Cases 1-8 and boolean closure.

## Analysis of the Circularity

### What `single_U_formula_separable` Currently Does (Hierarchy.lean:192)

```lean
theorem single_U_formula_separable (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable φ
```

This is proved by structural induction. The `.snce` case calls `snce_separable` (axiom). This is the ONLY use of temporal closure in the entire 10.2.5 proof.

### Why the `.snce` Case Is Actually Solvable

When we hit `.snce C F` where `C` and `F` have `has_single_U_type _ A B`:
- `C` and `F` each contain at most copies of `U(A,B)` with S-free A, B
- The U(A,B) copies appear under S — this is exactly the setup for `lemma_10_2_4`
- **Lemma 10.2.4** (`NormalForm.lean:348`) already proves this separable!

The existing `lemma_10_2_4` requires `a`, `q` to be U-free AND S-free. But in `.snce C F`:
- `C` and `F` are NOT U-free (they contain `U(A,B)`)
- We need to **decompose** `C` and `F` first

GHR94's approach (10.2.5 proof, lines 149-153): "Apply [10.2.4] to each of the most deeply nested S(C, F) in which U(A,B) appear." This is induction on S-nesting depth k of U(A,B):
- k=0: formula has U(A,B) only at top level (under boolean, not under S). Already separated.
- k>0: Find deepest S(C,F) containing U(A,B). Apply 10.2.4 to it. Result has lower k. IH.

BUT: the problem is that `lemma_10_2_4` requires its `a`, `q` arguments to be atoms-only (U-free, S-free). In a deeply nested formula, the arguments of the deepest S may be complex.

### The Actual Solution: Lemma 10.2.4 with Top-Level U

Look at what `lemma_10_2_4` actually does. For `S(C, F)` where C and F have `has_single_U_type _ A B` and U appears only at top level (not under S within C or F):

1. Event-split on U(A,B): `S(C, F) ↔ S(C∧U, F) ∨ S(C∧¬U, F)`
2. Each branch matches Cases 1-8 depending on whether F has ±U

The `lemma_10_2_4` in NormalForm.lean already handles all 8 patterns. And **Cases 1-8 are all proved non-circularly** in DedekindZ.lean.

The key insight: for `.snce C F` where `has_single_U_type C A B` and `has_single_U_type F A B`, we DON'T need the full generality of "arbitrary C, F." We just need that U(A,B) in C and F is NOT under any S. This is exactly `u_appearances_top_level_only` (Defs.lean:308).

### But Wait: What If U(A,B) IS Under S?

If `has_single_U_type (.snce C F) A B` and U(A,B) appears under S in C or F:

Example: `S(S(a, U(A,B)), q)` — U(A,B) is inside the inner S.

GHR94 10.2.5 says: apply 10.2.4 to the INNERMOST S containing U(A,B) first: `S(a, U(A,B))` → Case 3 → separable. The result is a boolean combination where U(A,B) is now at top level. Then proceed outward.

This is induction on S-nesting depth k (the measure in 10.2.5). The induction works because:
- After applying 10.2.4 to the innermost S, U(A,B) moves up one level
- S-nesting depth k decreases by 1
- Eventually k = 0 → separated

## Proposed Implementation

### Step 1: `no_S_nested_in_U_separable` (~250 LOC)

**Well-founded induction on `(count_U_subformulas φ, Formula.sizeOf φ)` with lexicographic ordering.**

```lean
theorem no_S_nested_in_U_separable (φ : Formula)
    (hexp : has_no_allpast_allfuture φ = true)
    (h : no_S_nested_in_U φ) :
    is_separable φ
```

**Proof sketch by cases on φ:**

- `atom`, `bot`, `box`: trivially separable
- `imp φ₁ φ₂`: `imp_separable` + IH on both (both smaller)
- `all_past`, `all_future`: impossible (blocked by `hexp`)
- `untl φ₁ φ₂`: `no_S_nested_in_U` forces `is_S_free φ₁` and `is_S_free φ₂`. Since `hexp` means no `all_past`/`all_future`, S-free + no all_past/all_future = syntactically separated. So `.untl φ₁ φ₂` is already separated.
- `snce C F`: This is the hard case. `no_S_nested_in_U (.snce C F)` gives `no_S_nested_in_U C ∧ no_S_nested_in_U F`.

**The `.snce C F` case in detail:**

Sub-case A: `is_U_free C = true ∧ is_U_free F = true`. Then `.snce C F` with U-free args and `hexp` gives `is_syntactically_separated` = true. Done.

Sub-case B: Some U(A,B) appears in C or F. Since `no_S_nested_in_U`, the U(A,B) has S-free args. Key sub-sub-cases:

B1: C and F contain only one type of U (say U(A₁,B₁)). Apply `lemma_10_2_4` to eliminate U from this S. Result is a boolean combination of atoms, U(A₁,B₁), and S-terms with U-free args. The S-terms with U-free args have `count_U_subformulas = 0 < count_U_subformulas(φ)`. Apply IH. Boolean closure gives separability.

B2: C and F contain multiple U-types U(A₁,B₁), ..., U(Aₙ,Bₙ). This is Lemma 10.2.6.

**For B2 (Lemma 10.2.6), abstract one U-type:**

1. Pick U(A₁,B₁). Let `p` be a fresh atom.
2. Let `C' = abstract_untl C A₁ B₁ p`, `F' = abstract_untl F A₁ B₁ p`.
3. `.snce C' F'` has `count_U_subformulas < count_U_subformulas(.snce C F)` (we removed all U(A₁,B₁) copies).
4. `.snce C' F'` still has `no_S_nested_in_U` (by `abstract_untl_preserves_no_S_nested`).
5. By IH: `.snce C' F'` is separable. Get separated witness `ψ`.
6. Now: `φ = .snce C F` is `int_equiv` to `subst_formula(ψ, p, U(A₁,B₁))` (by `abstract_untl_correct` + semantic argument).

**The substitution-back step** (the historically problematic step):

`ψ` is syntactically separated. `subst_formula(ψ, p, U(A₁,B₁))` replaces atom `p` with `.untl A₁ B₁` everywhere in `ψ`.

Since `ψ` is separated:
- In `.imp` positions: `p` → `.untl A₁ B₁`. Both sub-parts are separable by IH (they have fewer U-types since no U(A₁,B₁) was present in the abstracted version, and `p` → `.untl A₁ B₁` adds at most n-1 other U-types).
  
Wait — this is the circularity again. Substituting `.untl A₁ B₁` for `p` in a `.snce`-argument creates a non-U-free `.snce` argument, requiring `snce_separable`.

### The REAL Fix: Don't Substitute Into the Whole Formula

GHR94 10.2.6 (lines 167-169): "substitute U(Aᵢ, Bᵢ) for each qᵢ **in each Dⱼ**" — where Dⱼ are the **pure past** wffs of the separated E'.

Key insight: In a separated formula `ψ`, atom `p` can appear in three positions:
1. **As a standalone atom** in the boolean combination
2. **Inside a `.snce` argument** (which is U-free in separated form)
3. **Inside a `.untl` argument** (which is S-free in separated form)

Position 3 is impossible here because `p` was introduced by abstracting from inside a `.snce`, and `.untl` args in separated form are S-free — they can't contain the original `.snce` context where `p` was placed. Actually, wait — `p` is just an atom, and atoms can appear anywhere in a separated formula.

But here's what matters: **`.untl` arguments in a separated formula are S-free.** So `p` in a `.untl` argument means `.untl(...p..., ...p...)` where the args are S-free. Substituting `.untl A₁ B₁` for `p` gives `.untl(...U(A₁,B₁)..., ...U(A₁,B₁)...)` — which is S-free IF A₁, B₁ are S-free (they are, by `no_S_nested_in_U`). So **`.untl` arguments stay S-free after substitution.** The separated formula stays separated in its `.untl` positions.

**`.snce` arguments in a separated formula are U-free.** So `p` in a `.snce` argument is fine as an atom. After substituting `.untl A₁ B₁` for `p`, the `.snce` argument is NO LONGER U-free. This is where GHR94 says to apply the IH to each `Dⱼ`.

So the strategy is:

1. `ψ` is separated: `bool(atoms, U-terms, S-terms)`
2. Substitute `.untl A₁ B₁` for `p`:
   - Atoms: `p` → `.untl A₁ B₁` (a separated term since A₁, B₁ are S-free)
   - `.untl` args: stay S-free (since substituting S-free `.untl A₁ B₁` preserves S-freeness)
   - `.snce` args: were U-free, now contain `.untl A₁ B₁`. Each such `.snce D₁ D₂` now has `no_S_nested_in_U` (since the only new U is `.untl A₁ B₁` with S-free args, and the rest was already U-free hence trivially no_S_nested). And `count_U_subformulas` for each Dⱼ is at most n-1 (only the U-types from the original formula minus U(A₁,B₁)).
3. Apply IH to each `.snce Dⱼ₁ Dⱼ₂` (they have fewer U-subformulas)
4. Reassemble: boolean combination of separable = separable

### The Lean Infrastructure Needed

**A function to apply the IH to each past constituent:**

```lean
/-- Given a separated formula ψ and an atom p, substitute .untl A B for p
    and show the result is separable, by applying the IH to each .snce constituent. -/
theorem subst_in_separated_separable (ψ : Formula) (p : Atom)
    (A B : Formula) (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hsep : is_syntactically_separated ψ = true)
    (hexp : has_no_allpast_allfuture ψ = true)
    (ih : ∀ χ : Formula, 
      has_no_allpast_allfuture χ = true → 
      no_S_nested_in_U χ → 
      count_U_subformulas χ < count_U_subformulas (.untl A B ... ) → -- measure
      is_separable χ) :
    is_separable (subst_formula ψ p (.untl A B))
```

This is proved by structural induction on `ψ` (which is separated):

- `atom a`: if `a = p`, result is `.untl A B` which is separated (S-free args). If `a ≠ p`, result is `.atom a`, separated.
- `bot`: separated.
- `imp ψ₁ ψ₂`: both separated, both have no_allpast_allfuture. `imp_separable` + IH on both.
- `box`: separated.
- `all_past`, `all_future`: impossible (blocked by `hexp`).
- `untl ψ₁ ψ₂`: ψ₁, ψ₂ are S-free (separated). `subst_formula ψ₁ p (.untl A B)` is still S-free (substituting S-free `.untl A B` into S-free formula). Same for ψ₂. So the result `.untl (subst ψ₁) (subst ψ₂)` has S-free args → separated.
- `snce ψ₁ ψ₂`: ψ₁, ψ₂ are U-free (separated). After substitution, they contain `.untl A B` with S-free args → `no_S_nested_in_U`. Apply the IH. The count_U_subformulas of each substituted constituent is bounded by the number of occurrences of `p` in ψⱼ, which is at most n-1 (by the abstraction construction).

**Key lemma needed:**
```lean
theorem subst_S_free_preserves_S_free (ψ : Formula) (p : Atom) (r : Formula)
    (hψ : is_S_free ψ = true) (hr : is_S_free r = true) :
    is_S_free (subst_formula ψ p r) = true
```

This is straightforward by induction on ψ.

**Key lemma needed:**
```lean
theorem subst_U_free_gives_no_S_nested (ψ : Formula) (p : Atom) (A B : Formula)
    (hψ : is_U_free ψ = true) (hA : is_S_free A = true) (hB : is_S_free B = true) :
    no_S_nested_in_U (subst_formula ψ p (.untl A B))
```

This holds because: ψ is U-free, so after substitution the only `.untl` nodes are the newly-introduced `.untl A B` (with S-free args). Any `.snce` in ψ was not under `.untl` (ψ is U-free), and the new `.untl A B` contains only S-free A, B (no S nesting).

### Step 2: `junction_depth_separable` (~150 LOC)

```lean
theorem junction_depth_separable (φ : Formula)
    (hexp : has_no_allpast_allfuture φ = true) :
    is_separable φ
```

Proof by `Nat.strongRecOn` on `junction_depth φ`:

- **JD = 0**: `expanded_jd_zero_imp_separated` gives syntactically separated. Use `separated_imp_separable`.
- **JD = 1**: The formula has `.snce` or `.untl` but no S-U alternation. This means `no_S_nested_in_U` holds (JD=1 means U-args are S-free or vice versa, but not both nestings). Apply `no_S_nested_in_U_separable`.

  Actually wait — JD=1 doesn't quite imply `no_S_nested_in_U`. JD=1 means there's at most one level of alternation. For `.snce C F`, JD=1 means `junction_depth_S C ≤ 1` and `junction_depth_S F ≤ 1`, which means C and F have `junction_depth ≤ 0` for their `.untl` sub-parts (no S under U). So yes, JD ≤ 1 with `hexp` does imply `no_S_nested_in_U`.

  Actually I need to check this more carefully. `junction_depth (.snce C F) = max(junction_depth_S C, junction_depth_S F)`. `junction_depth_S` counts `.untl` appearances as `1 + max(jd a, jd b)`. So if `junction_depth_S C ≤ 1`, then any `.untl a b` in C has `max(jd a, jd b) = 0`, meaning a and b have no S-U alternation, meaning a and b are syntactically separated. So they are S-free (since separated `.untl` args are S-free). So `no_S_nested_in_U C` holds. Yes, JD ≤ 1 + hexp → `no_S_nested_in_U`.

- **JD ≥ 2**: The formula has S nested inside U (or vice versa) at depth ≥ 2. By duality, consider `.snce D₁ D₂` with JD ≥ 2.
  1. Find maximal U-subformulas U(Aᵢ,Bᵢ) in `.snce D₁ D₂`.
  2. Some have S inside their args (JD ≥ 2).
  3. Abstract those S-subformulas inside U-args with fresh atoms via `abstract_snce`.
  4. Result has `no_S_nested_in_U` → apply `no_S_nested_in_U_separable`.
  5. Substitute S-subformulas back into past constituents of separated form.
  6. Each past constituent now has JD < JD(φ) (the S-subformulas had JD ≤ JD-2, adding one level of S gives JD ≤ JD-1).
  7. Apply IH.

  This step needs the same `subst_in_separated_separable` infrastructure, but now substituting `.snce E F` for atom `z` instead of `.untl A B`. The symmetric case.

### Step 3: Replace 9 Axioms (~50 LOC)

```lean
theorem all_formulas_separable (φ : Formula) : is_separable φ :=
  let φ' := expand_temporal φ
  have hexp := expand_has_no_allpast_allfuture φ
  have hsep := junction_depth_separable φ' hexp
  is_separable_of_equiv (expand_temporal_equiv φ) hsep
```

Then each axiom becomes:
```lean
theorem snce_separable' (φ ψ : Formula) (h1 : is_separable φ) (h2 : is_separable ψ) :
    is_separable (.snce φ ψ) := all_formulas_separable _
```

## LOC Estimates

| Component | LOC | Notes |
|-----------|-----|-------|
| `subst_S_free_preserves_S_free` | 30 | Straightforward induction |
| `subst_U_free_gives_no_S_nested` | 40 | Key structural lemma |
| `subst_in_separated_separable` | 100 | Core substitution lemma |
| `no_S_nested_in_U_separable` | 150 | Main lemma, WF induction |
| `jd_le_1_implies_no_S_nested` | 30 | Bridge lemma |
| `junction_depth_separable` | 80 | Strong induction on JD |
| `all_formulas_separable` | 10 | Wrapper |
| Axiom replacements | 30 | 9 one-liners |
| Bridge + proper sep | 80 | syntactic → proper bridge |
| **Total** | **~550** | |

## Well-Founded Relation

For `no_S_nested_in_U_separable`:

```lean
-- Lexicographic order: (count_U_subformulas, sizeOf)
-- Both are natural numbers, so we use Prod.Lex Nat.lt Nat.lt
-- which is well-founded by WellFoundedRelation on (ℕ × ℕ)

-- In practice: Nat.strongRecOn on count_U_subformulas φ
-- with structural induction handling the sizeOf decrease for boolean cases
```

For `junction_depth_separable`:

```lean
-- Nat.strongRecOn on junction_depth φ
```

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| `subst_S_free_preserves_S_free` has corner cases | Low | Low | Simple structural induction |
| `subst_in_separated_separable` is complex | Medium | High | Can be split into per-constructor lemmas |
| Count measure doesn't decrease in some case | Low | High | The abstraction removes ALL copies of one U-type; count strictly decreases |
| JD=1 → no_S_nested bridge is wrong | Low | Medium | Verified by definition analysis above |
| Heartbeat issues on large proofs | Medium | Medium | Split into per-constructor lemmas, use `set_option maxHeartbeats` |

## Conclusion

The hierarchy IS implementable without circularity. The key missing infrastructure is `subst_in_separated_separable` — a function that, given a separated formula ψ, substitutes a temporal formula for an atom and shows the result is separable by applying the IH to each past/future constituent independently. This is ~100 LOC of structural induction on the separated formula, plus ~40 LOC of supporting freeness-preservation lemmas. The total implementation is ~550 LOC.
