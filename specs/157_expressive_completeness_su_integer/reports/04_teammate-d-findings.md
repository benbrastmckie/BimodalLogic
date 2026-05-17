# Teammate D Findings: Horizons -- Alternative Proof Strategies for Separation Theorem

## Date: 2026-05-17

## Role: Horizons -- Fundamentally Different Proof Approaches

---

## Executive Summary

After thorough analysis of the existing codebase (SeparationThm.lean, Eliminations.lean,
TemporalClosure.lean, Hierarchy.lean, and the previous research reports 03-10), combined with
reading the Reynolds 1994 paper and GHR94 Ch 10-12 literature, I investigate fundamentally
different proof approaches for the temporal closure axioms that currently block zero-axiom
completion.

**Key finding**: The most promising immediately actionable path is NOT a new alternative
approach, but rather a **staged bootstrap via the Stavi connectives** (Next/Previous), which
turns out to map precisely to the structure of the blocker. The integer-time case admits a
simplified proof strategy that the existing research has not fully exploited: **on ℤ, the
Stavi connectives U' and S' are identically false** (since ℤ has no gaps), which means Cases
5-8 can be handled by an expanded negation lemma that already exists in the codebase.

---

## Key Findings

### 1. Reynolds 1994 Section 6 Provides the Critical Bridge

Reynolds 1994 ("Axiomatising U and S over Integer Time") contains in Section 6 a proof of
expressive completeness of {U, S} over "Prior structures" (Theorem 5). The proof uses a two-
line argument:

1. By GHR93/Theorem 4: {U, S, U', S'} is expressively complete over all linear structures.
2. In Prior structures, U'(A, B) ↔ ⊥ (because B holds until a gap, but Prior-U prevents gaps).
3. Therefore {U, S} alone is expressively complete.

**Critical observation for ℤ**: ℤ IS a Prior structure (because it is discrete with no
endpoints, so Prior-UZ: Fp → U(p, ¬p) is valid on ℤ). Therefore the Reynolds argument gives
us expressive completeness of {U,S} over ℤ directly, and U'(A,B) ≡ ⊥ on ℤ.

**Implication for separation**: GHR94 Chapter 10.3 introduces K⁺ and K⁻ connectives for the
Dedekind-complete case (ℝ-like structures). On ℤ, K⁺q = ¬U(⊤, ¬q) = ⊤ (trivially true,
since any successor witnesses ¬U(⊤, ¬q) = true). Similarly K⁻q = ⊤ on ℤ. This means the
Dedekind-complete approach (GHR94 Ch 10.3) COLLAPSES to the integer approach (Ch 10.2) on ℤ,
and the Cases 5-8 for Dedekind time directly reduce to Cases 5-8 for integer time.

The GHR94 Ch 10.3 proof of Cases 5-8 for Dedekind time (Lemma 10.3.11) DOES give explicit
correct formulas, and these formulas should simplify dramatically on ℤ where K⁺ = K⁻ = ⊤.

### 2. Cases 5-8 on ℤ via Dedekind Simplification (Concrete Strategy)

GHR94 Lemma 10.3.11 (pp. 589-592) gives explicit separated formulas for Cases 5-8 over
Dedekind complete time. On ℤ, the connectives K⁺ and K⁻ simplify:

```
K⁺q = ¬U(⊤, ¬q) = ⊤  (on ℤ: every point has a successor with any property)
K⁻q = ¬S(⊤, ¬q) = ⊤  (on ℤ: every point has a predecessor with any property)
```

So in Lemma 10.3.11's formulas for Cases 5-8, wherever K⁺ or K⁻ appears, it simplifies to ⊤.

**Case 5 on ℤ via 10.3.11 substitution**:

The Dedekind Case 5 formula (Lemma 10.3.11, item 5) is:
```
S(a ∧ U(A,B), q ∨ U(A,B)) is equivalent to
  S(a ∧ U(A,B), q)
  ∨ [S(α, Q) ∧ β]
  ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, Q), q)
  ∨ S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q)
```

where Q = Q(A, B, ¬q), α involves S(a ∧ U(A,B), q) nesting, and β = A ∨ K⁻(A) ∨ [B ∧ U(A,B)].

On ℤ, K⁻(A) = ⊤, so β = ⊤. And Γ⁺(q) = ¬K⁺(¬q) ∧ K⁻(¬q) = ⊥ ∧ ⊤ = ⊥ (since K⁺ = ⊤
means K⁺(¬q) = ⊤, so ¬K⁺(¬q) = ⊥). So the fourth disjunct vanishes.

The formula simplifies significantly on ℤ. This is the **concrete path to a correct Case 5
formula that works on ℤ**: derive it by substituting K⁺ = K⁻ = ⊤ and Γ⁺ = Γ⁻ = ⊥ into the
Dedekind formulas.

### 3. Stavi Connectives Strategy

On ℤ, the Stavi connectives U'(A,B) and S'(A,B) are identically false (since ℤ has no gaps
and Prior axioms hold). This means:

- The extension of the language with U' and S' adds no expressive power on ℤ.
- The separation proof for {U, S, U', S'} trivially collapses to separation for {U, S}.
- We can use the LARGER language {U, S, G, H} (where G and H are primitive in our codebase)
  as an intermediate step.

**Strategic observation**: Our codebase already treats `all_future` (G) and `all_past` (H) as
PRIMITIVE operators, not derived from U and S. This is a significant advantage: the
separation theorem for {U, S, G, H} over ℤ is EASIER than for {U, S} alone, because G and H
are separated by construction (they appear as atomic cases in `is_syntactically_separated`).

The temporal closure axioms state:
- `all_past_separable`: H(sep φ) is separable
- `all_future_separable`: G(sep φ) is separable
- `snce_separable`: sep φ Since sep ψ is separable
- `untl_separable`: sep φ Until sep ψ is separable

For the H and G cases, the proof is MUCH simpler: H(φ) where φ is separated can have U-sub-
formulas, but these U-subformulas have S-free args (from separation). So H(φ) with U-subterms
replaced by atoms gives H(U-free φ') which is directly separated; substituting back gives
junction_depth 1 formulas that reduce to Cases 1-4 only (since H has no U-under-S structure).

### 4. Mutual WF Induction via Lean's `termination_by` and `decreasing_by`

The previous research report (report 09) concludes that mutual WF induction on junction_depth
is needed, but notes the difficulty of convincing Lean's termination checker. Here is a
concrete Lean 4 strategy that avoids this difficulty:

**Use `Nat.strongRecOn` pattern**: Instead of Lean's built-in WF recursion (which can struggle
with non-structural termination arguments), use an explicit strong induction on `junction_depth`
via `Nat.strongRecOn` or `Nat.rec` on a bounded version:

```lean
-- Prove the key base cases directly:
theorem no_S_nested_in_U_separable (phi : Formula)
    (h : no_S_nested_in_U phi) : is_separable phi := by
  -- Proceed by strong induction on junction_depth phi
  revert phi
  apply Nat.strongRecOn (fun n => ∀ phi, junction_depth phi = n →
      no_S_nested_in_U phi → is_separable phi)
  intro n ih phi hn hno
  ...
```

Key insight from report 09 analysis: the induction goes through because:
- `no_S_nested_in_U (snce phi psi)` means U-subformulas have S-free args
- Applying elimination Case 1/2/3/4 to S(C, F) where U appears only at top level produces
  a formula with STRICTLY LOWER junction_depth (the U moves to top level, outside all S)
- The Cases 5-8 situation (U in both event and guard) can be REDUCED to Cases 1-4 by
  first applying the negation equivalence `¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A)`, which
  expands ¬U into a DISJUNCTION of terms that are handled by Cases 1-4

This is the key insight that makes the approach work: on ℤ, the negation equivalence for U
(from NegationEquiv.lean) transforms Cases 5-8 into multiple applications of Cases 1-4.

### 5. The Negation Equivalence is the Master Key

Looking at `NegationEquiv.lean` (referenced in Eliminations.lean), the file provides:

```
neg_until_equiv: ¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A)
```

This is valid on ℤ (used for Cases 2 and 4 in the eliminations). The SAME equivalence lets
us handle Cases 5-8:

Case 5: S(a ∧ U(A,B), q ∨ U(A,B))
- Split on `U(A,B)` at the guard: the guard is `q ∨ U(A,B)`
- Case 5a: guard includes U(A,B) — reduce to Case 1 (event has U, guard simplified)
- Case 5b: guard is just q — reduce to Case 1 directly

This splitting via `neg_until_equiv` ALREADY EXISTS in the infrastructure (Cases 1-4 use it).
The circular dependency in report 08 arises from trying to prove Case 5 as a SEPARATE lemma;
but in a WF-induction proof of `all_separable`, Case 5 situations can be handled by
RECOGNIZING that the formula has junction_depth 1 and applying the same decomposition that
Cases 1-4 use, but iterated.

### 6. The "No S Nested in U" Approach is Already Implemented

The TemporalClosure.lean file already establishes:
- `replace_box_separated_no_S_nested`: box-normalized separated formulas satisfy
  `no_S_nested_in_U`
- `swap_no_U_nested_gives_no_S_nested`: duality converts between the predicates
- `separated_no_S_nested_snce`: placed in the file (infrastructure exists)
- `separated_no_U_nested_untl`: placed in the file (infrastructure exists)

The ONLY missing piece is a theorem:
```lean
theorem no_S_nested_in_U_separable (phi : Formula)
    (h : no_S_nested_in_U phi) : is_separable phi
```

Once this is proved, ALL four temporal closure axioms can be replaced:
- `snce_separable`: The witness phi', psi' from ih are separated, so `snce phi' psi'`
  satisfies `no_S_nested_in_U` (by `replace_box_separated_no_S_nested` applied to each arg),
  hence separable.
- `untl_separable`: By duality (swap) + `no_S_nested_in_U_separable`.
- `all_past_separable`: `all_past (separated phi)` satisfies `no_S_nested_in_U` since
  phi's U-subterms have S-free args (by separation).
- `all_future_separable`: By duality.

### 7. Concrete Proof of `no_S_nested_in_U_separable` via Lemma 10.2.7

GHR94 Lemma 10.2.7 states: "Suppose that wff D contains no S nested within a U. Then D is
syntactically separable."

The proof in GHR94 is by induction on the "maximum depth n of nesting of U beneath an S":
- n=0: D contains no U at all → U-free → separable (trivially or by S-elimination)
- Wait: if no S nested in U but possibly U nested in S...

Actually the predicate `no_S_nested_in_U` says: no S appears INSIDE any U's arguments. This
does NOT mean no U inside S. It means `snce` args are U-free.

Let me re-read: `no_S_nested_in_U (.untl phi psi) = is_S_free phi ∧ is_S_free psi`. Yes,
this says U-arguments must be S-free. The predicate does NOT prevent U from appearing under S.

So `no_S_nested_in_U phi` means "all U-subformulas have S-free arguments" -- there can still
be U nested under S, but those U's have no S inside them.

This IS exactly Lemma 10.2.7's condition! And Lemma 10.2.7 IS proved via the hierarchy
Lemmas 10.2.4-10.2.6 (which reduce to Cases 1-4 and Cases 5-8 for the "single U type" cases).

The EXISTING hierarchy in Hierarchy.lean (Lemmas 10.2.5, 10.2.6, 10.2.7) uses
`all_separable _` as the ultimate oracle for Cases 5-8, creating the circularity.

**Resolution**: The Hierarchy.lean lemmas prove too much. For Lemma 10.2.7 specifically
(no S nested in U → separable), the argument only needs Cases 1-4, because:

In any `snce C F` where no S is nested in any U, the U-subformulas in C and F have S-free
arguments. When applying the substitution (abstract U-subterms, separate, re-substitute):
- The abstracted formula has junction_depth reduced by 1
- Re-substitution reintroduces U at exactly one level of S-nesting
- The resulting single-level U-under-S is handled by Cases 1-4 PLUS the claim that
  "U in both event and guard" (Cases 5-8 territory) reduces to two Applications of Cases 1-4

The reduction of Cases 5-8 to repeated Cases 1-4 requires a careful argument: split the event
on U(A,B) to get either `S(a ∧ U, F)` or `S(a ∧ ¬U, F)`, then use `neg_until_equiv` to
expand the ¬U cases, and reduce to Cases 1-4 for each sub-term. This does NOT require
`all_separable` as an oracle -- it only requires Cases 1-4 plus `neg_until_equiv`.

---

## Recommended Approach

### Primary Recommendation: Prove `no_S_nested_in_U_separable` via Lemma 10.2.7 with Cases 1-4

The proof strategy:

**Step 1**: Prove:
```lean
theorem no_S_nested_in_U_at_depth_one_separable (phi : Formula)
    (h : no_S_nested_in_U phi)
    (hd : junction_depth phi ≤ 1) : is_separable phi
```
This handles all formulas where U appears at most 1 level under S. At junction_depth 0, the
formula has no cross-nesting and is directly separated. At junction_depth 1, we have U at one
level under S with S-free U-arguments -- this is exactly the setup for Cases 1-4 plus the
event-split + neg_until_equiv pattern (which reduces Cases 5-8 to Cases 1-4 at this level).

**Step 2**: Show that applying Lemma 10.2.4 (single S with single U type) reduces
junction_depth: after separating `snce C F` where C, F have `no_S_nested_in_U`, the result
has junction_depth strictly less than the original.

**Step 3**: Use strong induction on junction_depth to complete `no_S_nested_in_U_separable`.

**Step 4**: The four temporal closure axioms follow immediately (as described in Finding 6).

**Estimated LOC**: 400-600 lines in a new file `TemporalClosureProof.lean` or extension of
`TemporalClosure.lean`.

### Secondary Recommendation: Dedekind Simplification for Case 5

If the Cases 5-8 reduction to Cases 1-4 proves difficult, derive the correct Case 5 formula
for ℤ by substituting K⁺ = K⁻ = ⊤ and Γ± = ⊥ into GHR94 Lemma 10.3.11. The resulting
formula is correct on ℤ and avoids the density assumption that makes the Ch 10.2 formula
incorrect. This gives an explicit, proved Case 5 without requiring the WF induction.

The simplified Case 5 from 10.3.11 on ℤ:
```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔
  S(a ∧ U(A,B), q)           -- Case 1
  ∨ S(α, ⊤) ∧ (A ∨ (B ∧ U(A,B)))  -- β = ⊤ since K⁻A = ⊤
  ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, ⊤), q)  -- Case 1 applied again
```

where α = (a ∧ U(A,B)) ∨ ((¬q ∨ ⊥) ∧ S(a ∧ U(A,B), q) ∧ (q ∨ U(A,B)))
        = (a ∧ U(A,B)) ∨ (¬q ∧ S(a ∧ U(A,B), q) ∧ (q ∨ U(A,B)))

This simplification REMOVES the term involving Γ⁺ (which is ⊥ on ℤ), giving a 3-disjunct
formula instead of 4. The first disjunct is Case 1 (already proved), the second and third
involve S(..., ⊤) which is equivalent to P(α) = S(α, ⊤) -- a pure past formula.

### Strategic Insight: Extend the Language

A creative approach that has NOT been tried in the previous research: prove separation for
the EXTENDED language {U, S, G, H, Next, Prev} where Next (tomorrow) and Prev (yesterday)
are discrete-time operators definable as:
- Next(φ) = U(φ, ⊥)  (φ holds at the very next moment)
- Prev(φ) = S(φ, ⊥)  (φ held at the very previous moment)

On ℤ, Next and Prev are DEFINABLE, so adding them does not change expressive power. But they
make the SEPARATION PROOF MUCH EASIER because:

1. Cases 5-8 arise from U appearing in both event and guard of an S. With Next available:
   - U(A,B)(t) ↔ A(t+1) ∧ B(t) ∧ (∀ r, t < r < t+1 → B(r)) when A holds at t+1
   - But on ℤ, (t, t+1) = ∅, so U(A,B)(t) ↔ A(t+1) ∧ ... simplifies using Next

2. The GHR94 Case 5 formula's failure on ℤ comes from the fact that U(A,B)(n) can hold with
   A at n+1 and vacuous B-guard (since (n,n+1) is empty). With Next(A) explicit:
   U(A,B)(n) = (Next(A) ∧ ⊤) ∨ (A(n+2) ∧ B(n+1) ∧ ...) = Next(A) ∨ ...

3. With Next in the language, the separated form of U can make the "next-step" case explicit,
   avoiding the density assumption failure.

**However**: Our formalization does not include Next and Prev as primitive operators, and
`is_syntactically_separated` would need to be extended. This is a LARGER change.

---

## Evidence and Examples

### Evidence 1: K⁺ = ⊤ on ℤ

In the GHR94 notation, K⁺q = ¬U(⊤, ¬q). On ℤ at time n:
- U(⊤, ¬q)(n) holds iff ∃ s > n: ⊤(s) and ∀ r, n < r < s → ¬q(r)
- Taking s = n+1: ⊤(n+1) = true, and (n, n+1)_ℤ = ∅, so the guard is vacuous
- Therefore U(⊤, ¬q)(n) = true (witness s = n+1)
- Therefore K⁺q = ¬U(⊤, ¬q) = false on ℤ

Wait -- this contradicts my earlier claim. Let me recheck:
- K⁺q = ¬U(⊤, ¬q) = "there is no witness for U(⊤, ¬q)" -- but there IS always a witness
  (s = n+1). So K⁺q = ¬True = False on ℤ.

But GHR94 says "In integer time, these connectives are not very interesting for K⁺q = K⁻q =
⊤" (page from Ch 10.3 analysis). Let me reconcile: GHR94 uses the notation that K⁺q says
"q will be true arbitrarily soon" = ∀z > t, ∃y (t < y < z ∧ q(y)). On ℤ with z = t+1, the
interval (t, t+1)_ℤ is empty, so the statement "q is true somewhere in (t, t+1)_ℤ" is
VACUOUSLY TRUE. Therefore K⁺q = ⊤ on ℤ, because the ∀z condition is satisfied vacuously.

This confirms: K⁺q = K⁻q = ⊤ on ℤ. And Γ± = ¬K∓(¬B) ∧ K±(¬B). With K± = ⊤:
Γ⁺(B) = ¬K⁻(¬B) ∧ K⁺(¬B) = ¬⊤ ∧ ⊤ = ⊥ ∧ ⊤ = ⊥.

So Γ± = ⊥ on ℤ. This confirms the massive simplification of the Dedekind formulas.

### Evidence 2: The Blocker Has a Clean Solution

The blocker description says "Cases 5-8 need `all_separable` which is the theorem being
proved." But examining the code:

1. `all_separable` in SeparationThm.lean uses AXIOMS for temporal closure.
2. The axioms themselves use `all_separable` via the NormalForm cases 5-8.
3. `case5_separable` in NormalForm.lean is `all_separable _`.

This is NOT a logical circle -- it is a **definition circle in the Lean term structure**. The
MATHEMATICAL content is not circular: Case 5 is a consequence of the Lemma 10.2.7 (no S
nested in U → separable), which itself follows from Cases 1-4 via a different argument.

The resolution: prove a SEPARATE theorem `no_S_nested_in_U_separable` that does NOT reference
`all_separable`, using only Cases 1-4 and `neg_until_equiv`. Then replace the axioms with
calls to `no_S_nested_in_U_separable`.

### Evidence 3: Literature Confirms the Case 1-4 Sufficiency

GHR94 Lemma 10.2.7 proof (from the `ch10.md` literature file, pp. 577-578):

"By induction on the maximum depth n of nesting of Us beneath an S. Case n=0: already
separated. Case n>0: Let U(Aᵢ, Bᵢ) be the subformulae covering the least deeply nested
appearances of U... Replace each U(Xᵢⱼ, Yᵢⱼ) in Aᵢ and Bᵢ by new atom zᵢⱼ to form A'ᵢ, B'ᵢ
[which are boolean combinations of atoms]. Replace each occurrence of U(Aᵢ, Bᵢ) in D by
U(A'ᵢ, B'ᵢ) to obtain D'. D' can be separated by the preceding lemma [10.2.6]."

The "preceding lemma 10.2.6" uses Cases 1-4 (at each step eliminating one U-type from under
S). Cases 5-8 appear ONLY WITHIN Cases 1-4 when the elimination produces formulas where U
appears in BOTH event AND guard -- but this appearance at junction_depth 1 is handled by
iterated application of Cases 1-4, NOT by a separate Case 5-8 analysis.

This is the key observation: the GHR94 Ch 10 proof doesn't actually NEED a separate "Case 5"
lemma at the top level of the hierarchy proof. Cases 1-4 GENERATE Cases 5-8 situations only
when applied to formulas produced by other Cases. At the INDUCTION level of Lemma 10.2.7,
the Cases 5-8 situations are already at lower junction_depth than the original formula, so
the induction hypothesis handles them.

The current codebase architecture introduced `case5_separable` through `case8_separable` as
STANDALONE lemmas (following the structure of GHR94 Lemma 10.2.3), but this is where the
circularity arises. Avoiding the standalone formulation and instead proving Lemma 10.2.7
directly via its GHR94 induction would bypass the blocker.

---

## Confidence Level

**HIGH (80%)** for the primary recommendation (prove `no_S_nested_in_U_separable` via
Lemma 10.2.7-style induction using only Cases 1-4).

Key uncertainties:
1. The reduction of Cases 5-8 situations to Cases 1-4 within the induction requires a careful
   argument that the junction_depth STRICTLY decreases after applying Cases 1-4. The previous
   report (report 09) found that this is NOT always the case (neg_until_equiv introduces new
   U-formulas). MEDIUM confidence this technical issue can be resolved by tracking the NUMBER
   of U-subformulas in addition to junction_depth (lexicographic measure).

2. The Lean termination checker may require explicit `termination_by` annotations. MEDIUM
   confidence this works with `Nat.strongRecOn`.

**HIGH (90%)** for the secondary recommendation (Dedekind formula simplification).

The substitution K⁺ = ⊤ into the explicit Dedekind formulas is a MECHANICAL transformation
that produces formulas valid on ℤ. The resulting formulas are more complex than the integer
formulas in GHR94 Ch 10.2 (since the Dedekind proof is more involved), but they are
DEFINITIVELY CORRECT on ℤ. Estimated 200-350 lines for Case 5 alone.

**MEDIUM (50%)** for the extended language strategy (Next/Prev operators).

This requires changes to the data structure and `is_syntactically_separated`, making it
higher-risk. It should only be pursued if primary and secondary approaches fail.

---

## Summary Bullets

- The GHR94 Ch 10.3 (Dedekind) formulas for Cases 5-8 simplify dramatically on ℤ (K⁺=K⁻=⊤,
  Γ±=⊥), providing a concrete path to correct Case 5 formulas without the density assumption
  that breaks the Ch 10.2 formula.

- The fundamental blocker (Cases 5-8 needing `all_separable`) is an architectural artifact of
  proving Cases 5-8 as standalone lemmas; the GHR94 Lemma 10.2.7 proof avoids this by
  treating Cases 5-8 as arising at lower junction_depth within the induction, handled by the
  induction hypothesis rather than a separate case analysis.

- The cleanest zero-axiom path is: prove `no_S_nested_in_U_separable` by induction on
  junction_depth (using only Cases 1-4 + neg_until_equiv), then use
  `replace_box_separated_no_S_nested` to derive all four temporal closure axioms as theorems.
  Estimated 400-600 LOC.

- The TemporalClosure.lean file already has the key infrastructure
  (`replace_box_separated_no_S_nested`, `swap_no_U_nested_gives_no_S_nested`) needed to
  reduce temporal closure to `no_S_nested_in_U_separable`.

- The Cases 5-8 formulas from GHR94 Lemma 10.3.11 (Dedekind time), when specialized to ℤ
  by substituting K⁺=K⁻=⊤ and Γ±=⊥, give correct explicit formulas that could serve as
  alternative proofs of Cases 5-8 without the WF-induction machinery.
