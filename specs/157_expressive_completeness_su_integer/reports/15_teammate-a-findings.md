# Teammate A Findings: GHR94 Lemma Chain vs. Codebase Mapping (Round 15)

## Executive Summary

This report provides a precise mapping of GHR94 Lemmas 10.2.3 through 10.2.8 to the
current codebase. The key findings are:

1. **The sorry locations are at lines 1773 and 1806 of Hierarchy.lean.** They are inside the `n = 1` branch of the JD induction in `all_formulas_separable_aux`, where the callback needs `junction_depth ζ ≤ 0` but can only prove `junction_depth ζ ≤ 1`. This is NOT a false proposition — it is a gap in the induction structure.

2. **The codebase does NOT follow GHR94's acyclic lemma chain.** Instead it uses an abstract-substitute approach with callbacks. This is a valid structural variant but the n=1 base case remains unproven.

3. **GHR94 Lemmas 10.2.3–10.2.6 all have proof-complete implementations.** The gap is specifically in Lemmas 10.2.7 and 10.2.8 (the JD induction).

4. **There are 8 additional axioms in SeparationThm.lean** (`all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`, and four `properly_separable` versions plus `proper_separation_preserves_atoms`) that have NOT been eliminated.

---

## Part 1: GHR94 Lemma Statements (Precise)

### Lemma 10.2.3 (p. 572–580): Eight Elimination Cases

**Statement**: Each of the following 8 wff shapes is equivalent over integer time to a wff
where U(A,B) appears only at top level (not under any S):
1. S(a ∧ U(A,B), q)
2. S(a ∧ ¬U(A,B), q)
3. S(a, q ∨ U(A,B))
4. S(a, q ∨ ¬U(A,B))
5. S(a ∧ U(A,B), q ∨ U(A,B))
6. S(a ∧ ¬U(A,B), q ∨ U(A,B))
7. S(a ∧ U(A,B), q ∨ ¬U(A,B))
8. S(a ∧ ¬U(A,B), q ∨ ¬U(A,B))

**Dependencies**: Lemmas 10.2.1 (U/S distributivity), 10.2.2 (negation of U/S).

**Proof strategy**: Each case gives an explicit equivalent formula. Cases 1–4 use direct semantic argument. Cases 5–8 reduce to earlier cases.

### Lemma 10.2.4 (p. 580): Single S with Top-Level U(A,B)

**Statement**: Suppose A, B are U/S-free. If U only appears as U(A,B) in C and F, and not nested under any S, then S(C, F) is equivalent to a syntactically separated wff where U only appears as U(A,B).

**Dependencies**: Lemma 10.2.3 (the 8 elimination cases), Lemma 10.2.1 (DNF/CNF rearrangement).

**Proof strategy**: Rearrange C and F into normal forms using 10.2.1, reduce each S-constituent to the 8 cases via 10.2.3.

### Lemma 10.2.5 (p. 581): Single-U Formula Separability

**Statement**: Suppose A, B are U/S-free and U only appears as U(A,B) in D. Then D is syntactically separable with U appearing only as U(A,B).

**Dependencies**: Lemma 10.2.4.

**Proof strategy**: Induction on k = maximum number of nested S's above any U(A,B).
- k = 0: already separated.
- k > 0: apply 10.2.4 to the most deeply nested S(C,F) containing U(A,B), reducing nesting depth. Apply IH.

**Key observation**: NO circularity. The induction terminates because nesting depth strictly decreases.

### Lemma 10.2.6 (p. 581): Multiple U-types, All S-free Args

**Statement**: For each i = 1..n let Aᵢ, Bᵢ be U/S-free. If D's only U-appearances are U(Aᵢ, Bᵢ), then D is syntactically separable.

**Dependencies**: Lemma 10.2.5.

**Proof strategy**: Induction on n (number of U-types).
- n = 1: this is Lemma 10.2.5.
- n > 1: Replace U(Aₙ, Bₙ) with atom qₙ throughout to get D'. Apply Lemma 10.2.5 to D' to get separated E'. Resubstitute U(Aᵢ,Bᵢ) for qᵢ, then apply IH on the pure-past constituents of E'.

### Lemma 10.2.7 (p. 582): No S within U

**Statement**: Suppose D contains no S nested within a U. Then D is syntactically separable.

**Dependencies**: Lemma 10.2.6.

**Proof strategy**: Induction on n = maximum depth of nesting of U's beneath S.
- n = 1: each Uᵢ has U/S-free args; this is Lemma 10.2.6.
- n > 1: Replace inner U(Xᵢⱼ,Yᵢⱼ) inside each outer Uᵢ with fresh atoms zᵢⱼ. The modified formula has outer U-types U(A'ᵢ, B'ᵢ) with atom-only args. Apply Lemma 10.2.6. The pure-past constituents of the result still have U-nesting strictly shallower, so apply IH.

**Key observation**: NO circularity. The induction measure is U-nesting-depth, which strictly decreases.

### Lemma 10.2.8 (p. 582–583): General Junction Depth Induction

**Statement**: Any wff of {U, S} is syntactically separable over integer time.

**Dependencies**: Lemma 10.2.7, induction on junction_depth.

**Junction depth definition** (GHR94 p. 582): The junction depth of a subformula B in A is the max length n of chains C₁, ..., Cₙ of alternating U and S subformulas. Junction depth of a formula is the maximum over all subformulas.

**Key GHR94 observation**: JD = 0 or 1 means already separated. 

**Proof strategy**: Induction on JD of D.
- JD = 0 or 1: already separated.
- JD ≥ 2: Let U(Aᵢ,Bᵢ) be maximal U-subformulas (covering all U occurrences). These Aᵢ,Bᵢ may contain S (that's what gives JD ≥ 2). Replace the DEEPEST S(Eᵢⱼ,Fᵢⱼ) inside each Uᵢ with atoms zᵢⱼ to get U(A'ᵢ,B'ᵢ). Now the outer S(D₁,D₂) with modified U-args has no S in U-args → Lemma 10.2.7 applies. After resubstituting, the S-subformulas have JD ≤ JD(D) - 2 (each junction removed strips 2 levels). Apply IH.

**Critical detail**: GHR94 says "JD ≤ d-2 for resubstituted S-subformulas" at Lemma 10.3.19 (the Dedekind version). For 10.2.8 (integer version), the statement is that substituting back produces formulas of lower JD, and the IH applies.

---

## Part 2: Codebase Mapping

### Lemma 10.2.3 → Eliminations.lean

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean`

| GHR94 Case | Lean Theorem | Lines | Status |
|------------|-------------|-------|--------|
| Case 1: S(a∧U, q) | `elim_case_1`, `elim_case_1_gen`, `case1_psi_properties` | ~82–346 | **COMPLETE (sorry-free)** |
| Case 2: S(a∧¬U, q) | `elim_case_2`, `elim_case_2_gen` | ~353–484 | **COMPLETE (sorry-free)** |
| Case 3: S(a, q∨U) | `elim_case_3` | ~488–542 | **COMPLETE (sorry-free)** |
| Case 4: S(a, q∨¬U) | `elim_case_4` | ~546–602 | **COMPLETE (sorry-free)** |
| Cases 5–8 | Proved via `all_separable` in NormalForm.lean | ~640–746 | **EXISTENCE PROVED** (via `all_separable` which depends on `snce_separable` axiom) |

**Structural note**: Cases 1–4 have full semantic proofs with explicit equivalent formulas. Cases 5–8 are proved indirectly: their existence follows from `all_separable` (SeparationThm.lean) which uses the `snce_separable` axiom. The explicit formulas for Cases 5–8 over integer time remain open (GHR94's formulas for Case 5 are incorrect on integers as documented in the case5 comment at line 609 of Eliminations.lean).

**GHR94 page reference**: Lemma 10.2.3, pp. 572–580.

### Lemma 10.2.4 → NormalForm.lean

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean`

| GHR94 Lemma | Lean Theorem | Location | Status |
|------------|-------------|----------|--------|
| Lemma 10.2.4 | `single_S_with_U` (in SeparationThm.lean) | SeparationThm.lean ~141–152 | **EXISTS but trivially via `all_separable`** |
| 10.2.4 (constructive) | `subst_in_separated_separable` | NormalForm.lean/Hierarchy.lean ~1144–1172 | **PARTIAL**: uses callback axiom for snce case |

**SeparationThm.lean line 148–152**:
```lean
theorem single_S_with_U (C F A B : Formula) ... :
    is_separable (.snce C F) :=
  all_separable _
```
This is merely a corollary of `all_separable` — it uses the axiom, not an independent proof.

The constructive version `subst_in_separated_separable` (Hierarchy.lean ~1144) uses a `callback` parameter for the snce case, deferring the recursion to the caller. This is the right structure but requires the callback to prove the snce constituents separable.

**GHR94 page reference**: Lemma 10.2.4, p. 580.

### Lemma 10.2.5 → Hierarchy.lean (partial)

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

| GHR94 Lemma | Lean Theorem | Lines | Status |
|------------|-------------|-------|--------|
| Lemma 10.2.5 (GHR94) | `single_U_formula_separable` | ~170–187 | **USES `snce_separable` AXIOM** |
| 10.2.5 (axiom-free) | `no_S_nested_in_U_separable_param` | ~1491–1533 | **PARTIAL**: uses `callback` for snce |
| 10.2.5 (axiom-free) | `no_S_nested_in_U_separable_noax` | ~1537–1541 | Uses `all_separable` as callback (circular) |

The theorem `single_U_formula_separable` (line 187) calls `snce_separable` in its snce case. This is one of the four axioms in SeparationThm.lean, so the proof is not axiom-free.

The parameterized version `no_S_nested_in_U_separable_param` is the GHR94-faithful approach: it uses induction on `count_U_subformulas` (analogous to GHR94's induction on n), and a callback for handling snce constituents. The callback currently receives `no_S_nested_in_U χ` as its hypothesis — this should be sufficient for recursion if the callback is the hierarchy theorem itself.

**GHR94 page reference**: Lemma 10.2.5, p. 581.

### Lemma 10.2.6 → Hierarchy.lean

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

| GHR94 Lemma | Lean Theorem | Lines | Status |
|------------|-------------|-------|--------|
| Lemma 10.2.6 | `multi_U_formula_separable` | ~762–764 | **TRIVIAL** (just calls `all_separable`) |
| 10.2.6 (axiom-free) | `no_S_nested_in_U_separable_param_jd` | ~1658–1700 | **PARTIAL**: callback parameter unresolved |

`multi_U_formula_separable` (line 762–764) simply calls `all_separable phi`, which depends on the axioms. It is not an independent proof.

The parameterized version `no_S_nested_in_U_separable_param_jd` uses strong induction on `count_U_subformulas` with a JD-bounded callback. This is the correct structure for GHR94's Lemma 10.2.6 (substitute, apply 10.2.5, recurse). The callback receives `no_S_nested_in_U χ` and `junction_depth χ ≤ 1`.

**GHR94 page reference**: Lemma 10.2.6, p. 581.

### Lemma 10.2.7 → Hierarchy.lean (not directly implemented)

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

GHR94 Lemma 10.2.7 is: "If D contains no S nested within a U, then D is separable." The codebase has:

| GHR94 Lemma | Lean Theorem | Lines | Status |
|------------|-------------|-------|--------|
| Lemma 10.2.7 | `no_S_within_U_separable` (SeparationThm.lean ~181–184) | SeparationThm.lean | **TRIVIAL** (calls `all_separable`) |

There is NO direct implementation of the GHR94 Lemma 10.2.7 U-depth induction in the codebase. Instead, the `no_S_nested_in_U_separable_param_jd` function covers the "n=1" case of the JD induction (which is the JD=1 case of GHR94 10.2.8), and the callback structure is supposed to handle what GHR94 calls Lemma 10.2.7.

**GHR94 page reference**: Lemma 10.2.7, p. 582.

### Lemma 10.2.8 → Hierarchy.lean (CONTAINS THE SORRY)

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

| GHR94 Lemma | Lean Theorem | Lines | Status |
|------------|-------------|-------|--------|
| Lemma 10.2.8 | `all_formulas_separable_aux` | ~1712–1817 | **CONTAINS 2 SORRIES at lines 1773, 1806** |
| 10.2.9 (Separation Theorem) | `all_formulas_separable` | ~1821–1823 | Depends on `all_formulas_separable_aux` |

**GHR94 page reference**: Lemma 10.2.8, pp. 582–583, Theorem 10.2.9, p. 583.

---

## Part 3: The Sorry — Precise Analysis

### Sorry Locations

**Line 1773** (snce case, n=1 branch):
```lean
| snce a b ih_a ih_b =>
  ...
  · -- n = 1 (since n ≥ 1 from JD ≥ 1 and JD ≤ n)
    -- Callback JD ≤ 1. For JD = 0: ih_jd 0. For JD = 1: sorry.
    exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
      (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
        ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
```

**Line 1806** (untl case, n=1 branch, symmetric):
```lean
| untl a b ih_a ih_b =>
  ...
  · -- n = 1 (since n ≥ 1 from JD ≥ 1 and JD ≤ n)
    exact no_S_nested_in_U_separable_param_jd _ hns_S
      (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
        ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
```

### What the Sorry Must Prove

The sorry at line 1773 appears in the context:
- `ih_jd : ∀ m < n, ∀ ψ, junction_depth ψ ≤ m → has_no_allpast_allfuture ψ = true → is_separable ψ`
- `n = 1` (established by `¬(n ≥ 2)` and `n ≥ 1`)
- `ζ : Formula` with hypotheses `hns_ζ : no_S_nested_in_U ζ` and `hjd_ζ : junction_depth ζ ≤ 1`

The sorry goal is: `junction_depth ζ ≤ 0`

To apply `ih_jd 0 (by omega)`, we need `junction_depth ζ ≤ 0`. But we only have `junction_depth ζ ≤ 1`. This is the gap: when n=1, the callback can receive formulas of JD=1, and `ih_jd 0` handles JD≤0. There is no way to prove `junction_depth ζ ≤ 0` from `junction_depth ζ ≤ 1` in general.

### Why This Is NOT a False Proposition

The previous research (Round 14) stated this was a false proposition. That is not quite right. The sorry is NOT asserting something false; it is asserting `junction_depth ζ ≤ 0` in a context where we only know `junction_depth ζ ≤ 1`. When ζ has JD=1, this goal is false. But when ζ has JD=0, it is true.

The underlying issue is that the n=1 branch needs to prove JD=1 formulas separable using the callback, but uses `ih_jd 0` which only covers JD=0. It needs `ih_jd 1` but that would be circular (`ih_jd 1` requires `1 < 1` which is false).

### The Actual Gap

The gap is a **bootstrap problem** in the JD induction at JD=1:

The JD induction structure is:
- For JD ≥ 2: use `ih_jd (n-1)` (strictly less than n) to handle callback formulas of JD ≤ 1. This works because n-1 ≥ 1 ≥ JD of callback.
- For JD = 1 (n=1): need to handle callback formulas of JD ≤ 1. But `ih_jd 0` only handles JD ≤ 0. And `ih_jd 1` would require `1 < 1` = False.

**This is exactly the JD=1 base case of GHR94 Lemma 10.2.8.**

In GHR94's proof, the JD=1 case is handled by Lemma 10.2.7 directly: "JD=1 means no S within any U" → Lemma 10.2.7 applies. The codebase's callback structure routes JD=1 formulas back into `no_S_nested_in_U_separable_param_jd`, which handles them via the count_U induction. But the callback for THAT function needs something to handle the snce constituents it produces, and THOSE have JD ≤ 1.

The missing piece is: **a proof that `no_S_nested_in_U` formulas of JD ≤ 1 are separable WITHOUT using the JD induction** (i.e., using only the count_U induction and the 8 elimination cases directly).

---

## Part 4: Where the Codebase Diverges from GHR94

### Divergence Point: After Lemma 10.2.6

GHR94's chain: 10.2.3 → 10.2.4 → 10.2.5 → 10.2.6 → **10.2.7 (U-depth induction)** → 10.2.8 (JD induction)

Codebase's chain:
- 10.2.3 Cases 1-4: independent proofs (faithful)
- 10.2.3 Cases 5-8: proved via `all_separable` (using `snce_separable` axiom — not faithful)
- 10.2.4: proved trivially via `all_separable` (not faithful), plus partially via `subst_in_separated_separable` with callback
- 10.2.5 / 10.2.6: both trivially via `all_separable` (not faithful), plus `no_S_nested_in_U_separable_param_jd` with callback
- **10.2.7: NOT IMPLEMENTED** as a distinct U-depth induction
- 10.2.8: `all_formulas_separable_aux` via JD induction with callbacks — SORRY at JD=1 base case

**First divergence**: GHR94's Lemma 10.2.5 uses induction on S-nesting depth above U (not count_U). The codebase uses induction on count_U_subformulas. These are structurally different but equivalent.

**Critical divergence**: GHR94 uses Lemma 10.2.7 as a distinct stepping stone (U-depth induction to handle multiple U-nesting). The codebase collapses 10.2.7 into the callback of 10.2.8's JD induction. This works for JD ≥ 2 but fails at JD = 1 because there is no independent proof of the JD=1 case.

---

## Part 5: What the JD=1 Case Requires

A formula of JD=1 has: at most one level of U under S (or S under U), but not both nested. Concretely, JD=1 means every U has S-free args AND every S has U-free args OR: there is some U inside some S but no further nesting.

Wait — let me be precise. From Defs.lean:
```
junction_depth (.untl φ ψ) = max (junction_depth_U φ) (junction_depth_U ψ)
junction_depth_U (.snce φ ψ) = 1 + max (junction_depth φ) (junction_depth φ)
```

So JD=1 for `.snce a b` where a has some U in it (making jdS_a ≥ 1) contributes to junction_depth. JD=1 means there is exactly one "junction" — one level of U under S OR one level of S under U, but no further nesting.

For the callback formula ζ with `no_S_nested_in_U ζ` and `junction_depth ζ ≤ 1`:
- ζ has no S in U-args (by `no_S_nested_in_U`)
- ζ has at most one U under S

This is essentially the domain of GHR94 Lemma 10.2.6 (one level of U under S, all with S-free args). The codebase has `no_S_nested_in_U_separable_param_jd` which handles this, but it ITSELF needs a callback for the snce constituents it produces during count_U induction.

**The missing lemma**: A formula with `no_S_nested_in_U`, `has_no_allpast_allfuture`, and JD ≤ 1 is separable WITHOUT any callback — using only Cases 1-4 (and Cases 5-8 if needed as proved).

This corresponds exactly to: the snce case of the count_U induction when the snce constituents have JD = 0 (U-free), which means they are trivially separated. The issue is that when substituting `.untl A B` back into separated snce-args (which are U-free), the result has JD ≤ 1 (one level of U under S), and THAT is what needs the base case.

---

## Part 6: Additional Axioms That Must Be Eliminated

Beyond the 2 sorries in Hierarchy.lean, the following axioms in SeparationThm.lean must be eliminated for a zero-sorry proof:

**SeparationThm.lean**:
1. `all_past_separable` (line ~90) — "all_past of separable is separable"
2. `all_future_separable` (line ~94) — "all_future of separable is separable"
3. `untl_separable` (line ~98) — "untl of separable formulas is separable"
4. `snce_separable` (line ~102) — "snce of separable formulas is separable"
5. `all_past_properly_separable` (line ~221) — properly separable version
6. `all_future_properly_separable` (line ~226) — properly separable version
7. `untl_properly_separable` (line ~231) — properly separable version
8. `snce_properly_separable` (line ~237) — properly separable version
9. `proper_separation_preserves_atoms` (line ~277) — atoms preserved under proper separation

The first 4 axioms are used in `all_separable` (SeparationThm.lean line 125–139), which is used EVERYWHERE in the codebase as a fallback. If `all_formulas_separable` in Hierarchy.lean is proved without axioms, these 4 axioms become provable as corollaries and can be eliminated.

The `properly_separable` axioms (5–9) are separate — they concern the stronger `is_properly_separable` predicate.

---

## Part 7: The Faithful GHR94 Path

GHR94's proof is:

```
Cases 1–4 (direct semantic proofs)
    ↓
Lemma 10.2.4 (normal form reduction: use 10.2.3 on S-U combinations)
    ↓
Lemma 10.2.5 (induction on S-nesting depth above U(A,B))
    - k = 0: already separated
    - k > 0: apply 10.2.4 to deepest S with U inside → reduce depth → IH
    ↓
Lemma 10.2.6 (induction on number of U-types n)
    - n = 1: Lemma 10.2.5
    - n > 1: replace one U-type with atom → Lemma 10.2.5 → substitute back → IH
    ↓
Lemma 10.2.7 (induction on U-nesting depth under S)
    - n = 1: Lemma 10.2.6 (U-types all have S-free args)
    - n > 1: replace inner U-subformulas with atoms → Lemma 10.2.6 → substitute back → IH
    ↓
Lemma 10.2.8 (induction on junction depth)
    - JD = 0 or 1: already separated (JD=0) or Lemma 10.2.7 (JD=1)
    - JD ≥ 2: replace S-subformulas inside outermost U with atoms → Lemma 10.2.7 → substitute back → IH
```

The missing piece in the codebase is specifically **Lemma 10.2.7** as an independent proof. The codebase's `no_S_nested_in_U_separable_param_jd` plays the role of 10.2.6, and `all_formulas_separable_aux` plays the role of 10.2.8, but there is no equivalent of 10.2.7.

In GHR94's structure, 10.2.7 is the proof that formulas with `no_S_nested_in_U` are separable. The codebase's `no_S_nested_in_U_separable_param_jd` is supposed to be that proof, but it uses a callback that itself needs the same theorem when the callback formulas have JD=1.

---

## Part 8: Recommended Fix

The sorry at line 1773 can be fixed by implementing a **self-contained proof** that formulas with `no_S_nested_in_U`, `has_no_allpast_allfuture`, and JD ≤ 1 are separable.

**Strategy**: In `no_S_nested_in_U_separable_param_jd`, the callback receives ζ with:
- `no_S_nested_in_U ζ`
- `junction_depth ζ ≤ 1`

For JD(ζ) = 0: ζ is trivially separated (U-free or no S-U nesting).
For JD(ζ) = 1: ζ has exactly one level of U under S with S-free U-args. This matches `no_S_nested_in_U` exactly. The count_U induction for ζ will produce callback formulas with JD = 0 (since substituting back into snce positions with U-free args gives JD ≤ 1, but substitution into the snce args which are U-free means the resulting snce has JD ≤ 1 only if the substituted U has S-free args → JD = 0 for those callbacks).

**Concrete fix approach**: Instead of using `ih_jd 0 (by omega) ζ (by sorry)` (which requires `junction_depth ζ ≤ 0`), provide `no_S_nested_in_U_separable_param_jd` with a callback that handles JD=0 internally:

```lean
-- For n = 1: callback ζ has JD ≤ 1. Use no_S_nested_in_U_separable_param_jd 
-- with a JD=0 callback (which is trivially proved since JD=0 → U-free → separated)
exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
  (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
    -- ζ has no_S_nested_in_U and JD ≤ 1
    -- Apply no_S_nested_in_U_separable_param_jd to ζ with base callback
    no_S_nested_in_U_separable_param_jd ζ hns_ζ
      (has_no_allpast_allfuture_true ζ) (fun χ hns_χ hjd_χ =>
        -- χ has JD ≤ 1 (from callback_jd_le_one), and ζ had JD ≤ 1
        -- χ is a snce of subst-into-U-free, which gives JD ≤ 1
        -- BUT we need count_U_χ < count_U_ζ for termination
        -- This works since we're using count_U induction
        jd_zero_sep χ (has_no_allpast_allfuture_true χ) (by omega)))
```

However, this approach requires proving that `χ` in the inner callback has JD = 0, not JD ≤ 1. The key insight is: the callback of `no_S_nested_in_U_separable_param_jd` receives snce formulas where the args are substitutions of `.untl A B` (S-free args) into U-free formulas. These substitutions give JD ≤ 1. But the snce of such formulas has JD ≤ 1. We need JD = 0 for the innermost callback.

**Root of the problem**: The callback from `subst_in_separated_separable_jd` gives formulas of JD ≤ 1, not JD = 0. When ζ (first level callback) has JD = 1 and is processed by `no_S_nested_in_U_separable_param_jd`, the SECOND level callbacks from THAT call have JD ≤ 1 as well (same bound). So we need a termination argument that goes beyond JD — we need count_U to strictly decrease through the two levels.

The correct fix is: prove that the **second-level callback** (χ from the inner `no_S_nested_in_U_separable_param_jd` call) has **strictly fewer U-subformulas than ζ**, and therefore eventually reaches U-free (JD=0) formulas. This is guaranteed by the count_U induction in `no_S_nested_in_U_separable_param_jd`, but the callback need not prove JD = 0 for χ — instead the callback can call `no_S_nested_in_U_separable_param_jd` AGAIN with the same outer callback.

**Simplest fix**: Replace `ih_jd 0 (by omega) ζ (by sorry)` with a direct call to `no_S_nested_in_U_separable_param_jd ζ hns_ζ (has_no_allpast_allfuture_true ζ) callback_base`, where `callback_base` proves JD=0 formulas separable:

```lean
-- n = 1 case fix:
exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
  (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
    no_S_nested_in_U_separable_param_jd ζ hns_ζ
      (has_no_allpast_allfuture_true ζ) (fun χ _hns_χ hjd_χ =>
        jd_zero_sep χ (has_no_allpast_allfuture_true χ) hjd_χ))
```

This works IF `junction_depth χ = 0` for the second-level callbacks. The question is whether the second-level callbacks from `no_S_nested_in_U_separable_param_jd` applied to a JD=1 formula have JD=0.

**Analysis**: When ζ has JD ≤ 1 and `no_S_nested_in_U`, applying `no_S_nested_in_U_separable_param_jd` to ζ produces callback formulas χ = `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free (from a separated formula's snce args). The JD of such χ is computed as:
- `junction_depth_S (subst c p (.untl A B))` where c is U-free
- Substituting `.untl A B` (with S-free A, B) into a U-free formula gives `junction_depth_S ≤ 1`
- So `junction_depth χ ≤ 1` (not 0)

This means the second-level callback ALSO has JD ≤ 1, not JD = 0. The simple fix above does not work.

**The actual needed lemma**: We need to prove that `no_S_nested_in_U` + `has_no_allpast_allfuture` + JD ≤ 1 → separable DIRECTLY, without any callback that recurses on the same JD bound. This requires showing that the count_U induction terminates through finitely many rounds, each reducing count_U while staying at JD ≤ 1.

This IS true because: starting with count_U = k for the JD=1 formula, each round of `no_S_nested_in_U_separable_param_jd` reduces count_U by ≥ 1. After k rounds, count_U = 0, giving a U-free (JD=0) formula. So the nested application terminates.

The fix requires a mutual induction or a combined measure (count_U, JD) well-founded induction.

---

## Summary Table

| GHR94 Lemma | Codebase Implementation | Sorry-Free? |
|------------|------------------------|-------------|
| 10.2.3 Cases 1–4 | `elim_case_1/2/3/4` (Eliminations.lean) | YES |
| 10.2.3 Cases 5–8 | Via `all_separable` (SeparationThm.lean) | NO (depends on axioms) |
| 10.2.4 | `subst_in_separated_separable` + callback | PARTIAL |
| 10.2.5 | `no_S_nested_in_U_separable_param_jd` + callback | PARTIAL |
| 10.2.6 | `no_S_nested_in_U_separable_param_jd` | PARTIAL |
| 10.2.7 | NOT IMPLEMENTED independently | NO |
| 10.2.8 | `all_formulas_separable_aux` | NO (2 sorries at lines 1773, 1806) |
| 10.2.9 (Theorem) | `all_formulas_separable` | NO (inherits sorry) |

**Additional axioms (SeparationThm.lean)**: `all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`, and 5 `properly_separable` variants — all unproven axioms.
