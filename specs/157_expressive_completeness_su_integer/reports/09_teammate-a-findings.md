# Teammate A Findings: Primary Implementation Path for GHR94 10.2.5-10.2.8

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-18
**Angle**: Primary implementation strategy for the hierarchy theorem
**Confidence Level**: HIGH

## Key Findings

### 1. The Root Cause Is a Language Mismatch Between GHR94 and Our Formalization

GHR94 works exclusively with the language {S, U} (plus atoms and boolean connectives). Their proofs of Lemmas 10.2.5-10.2.8 never encounter `all_past` or `all_future` because these operators don't exist in their language.

Our formalization has `all_past` and `all_future` as *primitive Formula constructors* (not derived). Critically:
- `is_syntactically_separated (.all_past φ) = is_U_free φ` (Defs.lean:148)
- `is_syntactically_separated (.all_future φ) = is_S_free φ` (Defs.lean:149)

This means separated formulas CAN contain `all_past`/`all_future`. Cases 1-2 explicitly construct separated witnesses with them (Eliminations.lean:372, 458, 460, 515, 517). When we substitute `.untl A B` back into a separated formula containing `.all_past c'`, the callback receives `.all_past c'` where `c'` is NOT `has_no_allpast_allfuture`.

### 2. GHR94's Proof Architecture Makes Circularity Impossible — In THEIR Language

In GHR94's {S, U} language, the hierarchy is strictly non-circular:
- 10.2.4: Cases 1-8 (direct equivalences, no induction) ✓
- 10.2.5: Single U-type, induction on S-nesting depth k above U(A,B) ✓
- 10.2.6: Multi U-type (no S in U), induction on count n of distinct U-types ✓
- 10.2.7: No S nested in U, induction on U-nesting depth under S ✓
- 10.2.8: All formulas, induction on junction depth ✓

The key property at each level: the "substitute back into past constituents" step produces formulas with STRICTLY LOWER measure. The callback formula's complexity is bounded because:
- Separated formulas in {S, U} have `.snce` args that are U-free and `.untl` args that are S-free
- Substituting `.untl A B` for an atom in a U-free `.snce` arg creates a formula with exactly the substituted U-types (count known)
- No `all_past`/`all_future` appear because they don't exist

### 3. The Correct Fix: Redefine `is_syntactically_separated` to EXCLUDE `all_past`/`all_future`

This is the cleanest solution. It aligns our formalization with GHR94's language.

**Proposal**: Change `is_syntactically_separated` to:
```lean
def is_syntactically_separated : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_syntactically_separated φ && is_syntactically_separated ψ
  | .box _ => true
  | .all_past _ => false  -- CHANGED: was is_U_free φ
  | .all_future _ => false  -- CHANGED: was is_S_free φ
  | .untl φ ψ => is_S_free φ && is_S_free ψ
  | .snce φ ψ => is_U_free φ && is_U_free ψ
```

**Why this works**: After `expand_temporal`, no `all_past`/`all_future` exist. The hierarchy proof operates entirely on expanded formulas. The `all_formulas_separable` wrapper applies `expand_temporal` first, then calls `all_formulas_separable_aux` on the expanded (and now `has_no_allpast_allfuture`) formula.

**Impact**: Cases 1-2 in Eliminations.lean currently produce separated witnesses containing `all_past`/`all_future`. With the redefinition, these witnesses must be modified to use `¬S(¬φ, ⊤)` and `¬U(¬φ, ⊤)` instead. This is a routine refactoring — the semantic equivalences `all_past_equiv_neg_snce` and `all_future_equiv_neg_untl` are already proved (TemporalClosure.lean:608, 621).

### 4. Alternative: Keep the Definition, Use a 3-Component Lexicographic Measure

If redefining `is_syntactically_separated` is too disruptive, we can keep it and use:

```
Measure = (count_allpast_allfuture φ, count_U_subformulas φ, Formula.sizeOf φ)
```

with lexicographic ordering.

**How each case decreases the measure:**

- **all_past c** (with `no_S_nested_in_U`): Expand to `¬S(¬c, ⊤)`. This is `imp (snce (imp c bot) top') bot`. Count_allpast_allfuture decreases by 1 (first component decreases). Count_U unchanged. Apply IH.

- **all_future c** (with `no_S_nested_in_U`): This is the hard case.
  - If `is_S_free c`: `.all_future c` is syntactically separated. Done.
  - If NOT `is_S_free c`: Expand to `¬U(¬c, ⊤)` = `imp (untl (imp c bot) top') bot`. Count_allpast_allfuture decreases by 1 (removed one `all_future`). Count_U increases by 1. BUT: first component decreased, so lexicographic order gives us strict decrease!
  - PROBLEM: Does `no_S_nested_in_U` hold for the expanded formula? The new `.untl` has args `imp c bot` and `imp bot bot`. Need `is_S_free (imp c bot)` which requires `is_S_free c`. But we're in the case where c is NOT S-free! So `no_S_nested_in_U` FAILS.
  - RESOLUTION: We don't need `no_S_nested_in_U` of the expanded formula — we need `is_separable` of the expanded formula. Since the first component decreased, we can apply the IH, but the IH only gives separability when `no_S_nested_in_U` holds. Without that precondition, we'd need `all_formulas_separable_aux` which is the JD induction — circular.

**This alternative FAILS for `all_future c` when c is not S-free.**

### 5. The Hybrid Approach (RECOMMENDED): Redefine + Prove Both Theorems

**Phase A: Redefine `is_syntactically_separated` to exclude `all_past`/`all_future`** (~200 LOC of refactoring).

This makes separated formulas match GHR94's language exactly. The callback in `subst_in_separated_separable` never receives `all_past`/`all_future` formulas. The `has_no_allpast_allfuture` requirement on `no_S_nested_in_U_separable_param` becomes automatically satisfied.

**Phase B: Prove the hierarchy without `has_no_allpast_allfuture` baggage** (~400 LOC new).

With the redefinition, the existing infrastructure becomes sufficient:
1. `subst_in_separated_separable` callback receives only `.snce c' d'` (never `.all_past`)
2. These `.snce c' d'` have `no_S_nested_in_U` (by `subst_U_free_gives_no_S_nested`)
3. They have `has_no_allpast_allfuture` (because separated formulas can't contain `all_past`/`all_future`)
4. Count_U is bounded: fewer than original (the abstracted U-type is missing from `.snce` positions)

## Recommended Approach

### Step 1: Redefine `is_syntactically_separated` (Defs.lean)

```lean
def is_syntactically_separated : Formula → Bool
  | .all_past _ => false  -- was: is_U_free φ
  | .all_future _ => false  -- was: is_S_free φ
  -- all other cases unchanged
```

### Step 2: Refactor Cases 1-2 Witnesses (Eliminations.lean)

Cases 1 and 2 of Lemma 10.2.3 produce separated witnesses containing `all_past`/`all_future`.

- Case 1 witness uses `all_future (neg A)`. Replace with `neg (untl (neg (neg A)) top)` i.e. `neg (untl A top)`.
  Since A is an atom (S-free), `untl A top` has S-free args → separated.

- Case 2 witnesses use `all_past (neg a)`. Replace with `neg (snce (neg (neg a)) top)` i.e. `neg (snce a top)`.
  Since a is an atom (U-free), `snce a top` has U-free args → separated.

These are routine: the semantic equivalences are already proved.

### Step 3: Remove `has_no_allpast_allfuture` from `no_S_nested_in_U_separable_param`

After the redefinition, separated formulas never contain `all_past`/`all_future`. The callback formulas (from `subst_in_separated_separable`) are constructed from separated formula positions + substitution. Since:
- `.snce` positions in separated formulas have U-free args (no `all_past`/`all_future` by redefinition)
- Substituting `.untl A B` into a U-free formula with `has_no_allpast_allfuture` preserves `has_no_allpast_allfuture` (already proved: `subst_preserves_no_allpast_allfuture`, line 1167)

The callback formulas automatically satisfy `has_no_allpast_allfuture`.

New signature:
```lean
theorem no_S_nested_in_U_separable_noax' (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hexp : has_no_allpast_allfuture phi = true) :
    is_separable phi
```

The `hexp` requirement stays, but it's automatically satisfied for all callback formulas. This breaks the circularity.

### Step 4: Wire `all_formulas_separable_aux` (Hierarchy.lean)

Replace the `.untl a b` and `.snce a b` cases:

```lean
| untl a b ih_a ih_b =>
  -- a, b have has_no_allpast_allfuture (from hexp).
  -- Abstract S from U-args if present (10.2.8 technique).
  -- If no_S_nested_in_U: directly apply no_S_nested_in_U_separable_noax'
  -- If S nested in U: abstract_snce reduces junction_depth, apply IH
  sorry -- detailed below

| snce a b ih_a ih_b =>
  -- Dual of untl case
  sorry
```

For the `.untl a b` case:
1. Check if `no_S_nested_in_U (.untl a b)` (i.e., `is_S_free a ∧ is_S_free b`).
2. If yes: `(.untl a b)` is syntactically separated (S-free args). Done.
3. If no: some S appears in a or b. Find a `.snce E F` inside a or b.
   Abstract it to get `(.untl a' b')` where `a' = abstract_snce a E F p`, etc.
   This satisfies `no_S_nested_in_U` (the S was removed).
   Apply `no_S_nested_in_U_separable_noax'` to separate.
   Get separated ψ. Substitute back: `subst_formula ψ p (.snce E F)`.
   The callback formulas have JD < JD(original) by `abstract_snce_inside_untl_jd_lt`.
   Apply IH to each callback formula.

Wait — the issue is that `no_S_nested_in_U_separable_noax'` takes a callback. That callback is what provides separability for the `.snce`/`.all_past` constituents after substitution. The callback must call `all_formulas_separable_aux` on formulas with lower JD.

**The induction must be junction-depth induction on the OUTER theorem, with the inner theorem (`no_S_nested_in_U_separable_param`) using count-U induction WITHIN.**

```lean
theorem all_formulas_separable_aux (φ : Formula)
    (hexp : has_no_allpast_allfuture φ = true) : is_separable φ := by
  -- Induction on junction_depth
  induction h : junction_depth φ using Nat.strongRecOn generalizing φ with
  | ind n ih =>
  -- JD = 0: separated
  -- JD > 0: case split on formula
  --   .untl a b: if S-free args, separated. Else abstract_snce reduces JD -> IH
  --   .snce a b: if U-free args, separated. Else abstract_untl + subst -> callback
  --     callback formulas have JD < n -> IH applies
```

### Step 5: Prove the Dual `subst_in_separated_separable_snce`

The existing `subst_in_separated_separable` handles substituting `.untl A B` for an atom. We need the dual: substituting `.snce E F` (with U-free args) for an atom in a separated formula.

```lean
theorem subst_in_separated_separable_snce (ψ : Formula) (p : Atom) (E F : Formula)
    (hE_uf : is_U_free E = true) (hF_uf : is_U_free F = true)
    (hsep : is_syntactically_separated ψ = true)
    (ih_untl : ∀ (χ : Formula), no_U_nested_in_S χ → is_separable χ) :
    is_separable (subst_formula ψ p (.snce E F))
```

Where `no_U_nested_in_S` is the dual of `no_S_nested_in_U`.

### Step 6: Axiom Elimination

After `all_formulas_separable` is proved axiom-free, replace all 9 axioms:
```lean
theorem snce_separable (φ ψ : Formula) (_ : is_separable φ) (_ : is_separable ψ) :
    is_separable (.snce φ ψ) := all_formulas_separable _
```

## Evidence/Examples

### Evidence 1: Redefinition is sound

GHR94 Definition 10.3.3 (p. 585) for Dedekind time extends separation to include K± under S and K∓ under U. For integer time (Section 10.2), they use only {S, U}. Our `all_past`/`all_future` correspond to H/G = S(⊤,·)/U(⊤,·) which GHR94 treats as derived operators. The redefinition aligns with this.

`is_syntactically_separated` after redefinition says: a formula is a boolean combination of atoms, `.untl` with S-free args, and `.snce` with U-free args. This matches GHR94's definition for integer time exactly.

### Evidence 2: Cases 1-2 refactoring is bounded

Case 1 (Eliminations.lean:372) uses `all_future (neg A)` in one disjunct. Replace with `neg (untl A top)`. Since A is an atom, `is_S_free A = true`, so `untl A top` is separated.

Case 2 uses `all_past (neg a)` in two places (lines 458, 460, 515, 517). Replace with `neg (snce a top)`. Since a is an atom, `is_U_free a = true`, so `snce a top` is separated.

The semantic equivalences are already proved:
- `all_past_equiv_neg_snce` (TemporalClosure.lean:608)
- `all_future_equiv_neg_untl` (TemporalClosure.lean:621)

### Evidence 3: Count measure strictly decreases for the callback

After abstracting a U-type `U(A,B)` to atom p and separating, the separated ψ has no `all_past`/`all_future` (by redefinition). Substituting `.untl A B` for p in ψ:
- `.snce` positions: args were U-free. After substitution, args have `has_no_allpast_allfuture` (from `subst_preserves_no_allpast_allfuture`) and `no_S_nested_in_U` (from `subst_U_free_gives_no_S_nested`). The callback formula `.snce c' d'` has count_U ≤ count_U(original) - 1 because the abstracted U-type was removed from the formula, and the substitution only introduces it in `.snce` positions (NOT in `.untl` positions where it would be counted).

Actually let me be more precise: count_U of the callback `.snce c' d'` is bounded by the number of occurrences of p in the `.snce` arguments of ψ times 1 (each p becomes one `.untl A B`). The TOTAL count across all callback formulas is bounded by count_U(ψ_substituted) = count_U(original). But each INDIVIDUAL callback formula... the count is bounded by the atom-occurrences in its `.snce` sub-expression.

The correct argument: after abstracting U(A₁,B₁), the remaining formula has count_U(φ') = count_U(φ) - k where k ≥ 1 is the number of U(A₁,B₁) copies removed. After separating φ' to ψ and substituting back, U(A₁,B₁) appears in `.untl` positions (future, S-free → already separated) and `.snce` positions (past, these are the callbacks). Each callback `.snce c' d'` has no_S_nested_in_U and has at most count_U from the OTHER U-types (not U(A₁,B₁) since it was abstracted FROM .snce positions). So count_U(callback) ≤ count_U(φ) - 1. The IH applies.

## LOC Estimates

| Component | LOC | Risk |
|-----------|-----|------|
| Redefine `is_syntactically_separated` | 5 | Low |
| Refactor Cases 1-2 witnesses | 150 | Medium |
| Fix downstream lemmas (separated_imp_separable, etc.) | 100 | Medium |
| `subst_in_separated_separable_snce` (dual) | 80 | Low (mirror of existing) |
| `no_U_nested_in_S` predicate + preservation | 60 | Low |
| Wire `all_formulas_separable_aux` JD induction | 150 | High |
| Axiom replacement | 30 | Low |
| **Total** | **~575** | |

## Risks

1. **Cases 1-2 refactoring may cascade**: Changing the separated witnesses in Cases 1-2 may affect Case 3 (which uses Case 2's result) and Cases 5-8 in DedekindZ.lean. All these proofs use `is_separable_of_equiv` which is witness-agnostic, so the impact should be limited to the witness construction, not the separability proofs.

2. **`expanded_jd_zero_imp_separated` may need updating**: This lemma proves JD=0 implies separated. With the redefinition, `all_past`/`all_future` are no longer separated at JD=0, but they can't occur in expanded formulas anyway (guaranteed by `has_no_allpast_allfuture`).

3. **The `.untl a b` case in `all_formulas_separable_aux` needs abstract_snce infrastructure**: When `a` or `b` contains `.snce`, we must find the right `.snce` to abstract. The `snce_achieves_max_jdU` and `snce_inside_U_arg` predicates exist but may need refinement for a constructive extraction.

## Summary

The `all_past`/`all_future` complication is an artifact of our extended language, not present in GHR94. The cleanest fix is to redefine `is_syntactically_separated` to match GHR94's language (excluding `all_past`/`all_future`), refactor Cases 1-2 to produce equivalent witnesses without these operators, and then implement the hierarchy exactly as GHR94 describes. The existing infrastructure (substitution preservation, count decrease, junction-depth monotonicity) is sufficient. The total additional code is ~575 LOC.
