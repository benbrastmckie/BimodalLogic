# Teammate A Findings: GHR94 Section 10.2 Deep Analysis

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Focus**: GHR94 Section 10.2 Lemmas 10.2.1–10.2.8 — line-by-line proof structure analysis
**Artifact**: 23_teammate-a-findings.md
**Date**: 2026-05-19

---

## Key Findings

- **Finding 1: Cases 2,4,6,8 do NOT expand ¬U(A,B) in GHR94's output formulas.** The text's stated outputs still contain ¬U(A,B) literally (e.g., Case 2 output has `¬U(A,B)` at the top level). The expansion via Lemma 10.2.2 is used *during the derivation* to rewrite and simplify, but ¬U(A,B) reappears — unexpanded — in the final equivalent form. The current Lean code respects this: `elim_case_2` never eliminates the ¬U(A,B) node from the output; it uses `neg_until_equiv` internally to split into two branches and then reconstructs ¬U(A,B) in the backward direction.

- **Finding 2: `has_single_U_type` is NOT violated by ¬U(A,B).** The predicate `has_single_U_type phi A B` requires that every `.untl ψ₁ ψ₂` node satisfies `ψ₁ = A ∧ ψ₂ = B`. The formula `¬U(A,B) = Formula.neg (Formula.untl A B) = Formula.imp (Formula.untl A B) Formula.bot`. This has exactly one `.untl` node with args `(A, B)`. So `has_single_U_type (Formula.neg (.untl A B)) A B` holds trivially — the single `.untl` node in `¬U(A,B)` IS `(A, B)`. No violation.

- **Finding 3: The real problem is NOT about ¬U(A,B) expanding to introduce new U-types.** The code's Case 2 (`elim_case_2_gen`) uses `neg_until_equiv` *internally* to split into the G(¬A) branch and the U(¬A∧¬B, ¬A) branch. But for the G(¬A) branch, the code introduces `all_future (Formula.neg A)`, which expands to `Formula.neg (Formula.untl (Formula.neg Formula.bot) (Formula.neg A))`. This introduces a NEW `.untl` node with args `(¬⊤, ¬A)` — not `(A,B)`. So `has_single_U_type` of the output `psi_l = S(a, q∧¬A) ∧ ¬A ∧ G(¬A)` fails because `G(¬A) = all_future (¬A)` contains `.untl (¬⊤) (¬A)` with args ≠ `(A, B)`.

- **Finding 4: This is not a blocker for the current task.** Plan v22 Phase A (already COMPLETED) restructured `single_U_formula_separable_noax_param` to be oracle-free for `snce_depth_of_U ≤ 1`. The has_single_U_type preservation issue is relevant only for the `n ≥ 2` path that still uses the oracle. The current blocker (Phase B/C) is about making Lemmas 10.2.7 and 10.2.8 oracle-free, NOT about has_single_U_type in Cases 2,4,6,8.

- **Finding 5: The true encoding gap is G/H.** The `all_future` and `all_past` primitives in the Lean encoding are defined as `¬U(⊤, ¬φ)` and `¬S(⊤, ¬φ)`. These contain `.untl/.snce` nodes with args `(⊤, ¬φ)`, not `(A, B)`. GHR94 treats G/H as semantic abbreviations; the Lean encoding makes them syntactic, introducing new U-nodes in the output of Cases 2,3,4 (which use G/H). This does break `has_single_U_type` preservation, but only for the witness formulas — not for the semantic equivalence proofs, which are all correct.

---

## GHR94 Lemma-by-Lemma Analysis

### Lemma 10.2.1 — Distributivity of U/S over ∨/∧

**Statement**: Valid over all linear time:
- `U(A ∨ B, C) ↔ U(A,C) ∨ U(B,C)` and dual
- `U(A, B ∧ C) ↔ U(A,B) ∧ U(A,C)` and dual

**Dependencies**: None (semantic argument over linear orders)

**Key invariant**: U-type neutral — introduces multiple U-types when distributing over disjunctive events.

**How ¬U(A,B) is handled**: Not relevant; this lemma only handles positive U.

**Lean status**: Proved in `Distributivity.lean` (`since_distrib_or_left`, etc.). All axiom-free.

---

### Lemma 10.2.2 — Negation Equivalences

**Statement**: Over integer time:
- `¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A)`
- `¬S(A,B) ↔ H(¬A) ∨ S(¬A∧¬B, ¬A)`
(and two additional equivalent forms using `B∧¬A` in place of `¬A`)

**Dependencies**: Discreteness of Z (well-ordering to find the "first failure" point)

**Key invariant**: This is WHERE new U-types are introduced in GHR94. When `¬U(A,B)` is expanded, the right side contains `U(¬A∧¬B, ¬A)` — a NEW U-type with args `(¬A∧¬B, ¬A)` instead of `(A, B)`.

**How ¬U(A,B) is handled**: Fully expanded to `G(¬A) ∨ U(¬A∧¬B, ¬A)`. BUT — this is only an equivalence for *rewriting*; GHR94 uses it as a TOOL, not in the OUTPUT.

**Lean status**: Proved in `NegationEquiv.lean` (`neg_until_equiv`, `neg_since_equiv`). Fully axiom-free. Uses `Int.exists_least_above` for discreteness.

---

### Lemma 10.2.3 — The Eight Elimination Cases

**Statement**: Each of the 8 forms `S(a±U(A,B), q±U(A,B))` (with a, q, A, B atoms) is equivalent to a wff where every occurrence of U is as U(A,B) and no occurrence is under S.

**Critical observation about the OUTPUT formulas**: GHR94 states the OUTPUT (Cases 2,4,6,8 involving ¬U(A,B)) in terms that STILL contain ¬U(A,B) unexpanded:

- **Case 1 output**: `[S(a,q)∧S(a,B)∧B∧U(A,B)] ∨ [A∧S(a,B)∧S(a,q)] ∨ S(A∧q∧S(a,B)∧S(a,q), q)` — U appears only as U(A,B). No ¬U.
- **Case 2 output**: `[S(a,q∧¬A)∧¬A∧¬U(A,B)] ∨ [¬A∧¬B∧S(a,¬A∧q)] ∨ S(¬A∧¬B∧q∧S(a,¬A∧q), q)` — **¬U(A,B) appears UNEXPANDED** in the first disjunct.
- **Case 3 output**: `¬(H(¬a) ∨ [S(¬a∧¬q, ¬a∧¬A)∧¬A∧(¬U(A,B)∨¬B)] ∨ S(..., ¬a))` — ¬U(A,B) unexpanded.
- **Case 4 output**: `S(a, ¬a∧[S(¬q∧¬a, ¬a∧B) ⇒ ¬A]) ∧ (S(¬q∧¬a, ¬a∧B) ⇒ ¬[A∨(B∧U(A,B))])` — Uses U(A,B) and ¬A but not ¬U(A,B) in the innermost expression.
- **Case 5 output**: `[S(a,B)∧(A∨(B∧U(A,B)))] ∨ S(A∧S(a,B), A∨B∨¬S(¬q,¬A))∧(A∨(B∧U(A,B)))∧¬S(¬q,¬A)` — U(A,B) only.
- **Case 6 output**: `[S(a,q∧¬A)∧¬A∧¬(B∧U(A,B))] ∨ S(¬B∧¬A∧(q∨U(A,B))∧S(a,q∧¬A), q∨U(A,B))` — ¬(B∧U(A,B)) keeps U inside a negation. The formula does NOT expand ¬U to G(¬A)∨U'.
- **Case 7 output**: `[S(A∧(q∨¬U(A,B))∧S(a,B∧q), q∨¬U(A,B))] ∨ [S(a,B∧q)∧A] ∨ [S(a,B∧q)∧B∧U(A,B)]` — ¬U(A,B) unexpanded.
- **Case 8 output** (as ¬D): `H(¬a∨U(A,B)) ∨ S(¬q∧¬a∧U(A,B), ¬a∨U(A,B)) ∨ S(¬q∧U(A,B), ¬a∨U(A,B))` — U(A,B) unexpanded in this intermediate form.

**Summary**: GHR94's output formulas for Cases 2,4,6,7,8 keep `¬U(A,B)` as a syntactic UNIT (i.e., as `.imp (.untl A B) .bot`). They do NOT expand it into `G(¬A) ∨ U(¬A∧¬B, ¬A)`. The expansion via Lemma 10.2.2 is used DURING derivation steps to get FROM the original formula TO this output, but the output itself is expressed using the unexpanded ¬U(A,B).

**Key invariant**: In GHR94's output for each case, U appears ONLY as U(A,B) or as ¬U(A,B) = `.imp (.untl A B) .bot`. Both forms have the single `.untl` node with args exactly `(A, B)`. So `has_single_U_type` is preserved in GHR94's stated outputs.

**How the Lean code handles this**:

- **Cases 1 and generalized versions**: Directly output `case1_psi` which contains `.untl A B` explicitly. `has_single_U_type` preserved.
- **Case 2 (elim_case_2_gen)**: Uses `neg_until_equiv` internally but the output is `Formula.or psi_l psi1`. Here `psi_l = S(a,q∧¬A) ∧ ¬A ∧ G(¬A)`. The term `G(¬A) = all_future (¬A) = .neg (.untl (.neg .bot) (.neg A))`. **This introduces `.untl (¬⊤) (¬A)` — NOT `(A,B)`. `has_single_U_type psi_l A B` fails.**
- **Cases 3 and 4 (elim_case_3, elim_case_4)**: Use `neg_since_equiv` and `all_past`. `all_past (¬a)` introduces `.snce` nodes (not `.untl`), so no U-type violation. These output formulas should preserve `has_single_U_type`.
- **Cases 5-8**: Use the Q_Z infrastructure and direct GHR94 formulas (Case 6 via `case6_equiv_Z`). These output formulas contain U only as U(A,B) or ¬U(A,B), so `has_single_U_type` should be preserved.

**Lean status**: Cases 1-4 have explicit witnesses. Cases 5-8 proved via `case5_separable_Z_gen`, `case6_separable_Z`, and equivalents — all proved as `is_separable` (existence) without needing `has_single_U_type` on the output.

---

### Lemma 10.2.4 — S with Single U-Type at Top Level is Separable

**Statement**: If A, B have no S or U, and C, F have U appearing only as U(A,B) and never nested under S, then S(C,F) is equivalent to a syntactically separated wff where U appears only as U(A,B).

**Dependencies**: Lemma 10.2.1 (distribution) and Lemma 10.2.3 (the 8 elimination cases)

**Key invariant**: U appears only as U(A,B) in the OUTPUT. This is the critical `has_single_U_type` property.

**Strategy**: 
1. Rearrange C,F into DNF/CNF using 10.2.1
2. Reduce to boolean combinations of `S(C₁, C₂±U(A,B))` or `S(C₁±U(A,B), C₂±U(A,B))`
3. Apply the 8 elimination cases from 10.2.3
4. Each elimination case outputs formulas where U appears only as U(A,B)

**Lean implementation**: `snce_single_U_depth_one_separable` (Lemma 10.2.4). Already correct and axiom-free per plan v22.

---

### Lemma 10.2.5 — One U-Type, Arbitrary Nesting Under S

**Statement**: If A, B have no S or U, and the only U in D is U(A,B), then D is separable to a wff where U appears only as U(A,B).

**Dependencies**: Lemma 10.2.4 (applied repeatedly)

**Induction measure**: Maximum number k of nested S's above any U(A,B)

**Key invariant**: Throughout induction, U appears ONLY as U(A,B). After each step of applying 10.2.4, U still only appears as U(A,B).

**Case k=0**: D already separated (U is not under any S)

**Case k>0**: Apply 10.2.4 to each most-deeply-nested S(C,F) containing U(A,B). After this step, U is still only U(A,B) and nesting depth decreases. Apply IH.

**Why `has_single_U_type` is preserved**: The IH states that after applying 10.2.4, the formula has U only as U(A,B). This is exactly `has_single_U_type`. So the induction is coherent: the IH assumption includes `has_single_U_type`, and 10.2.4's output preserves `has_single_U_type`.

**The Problem in Lean**: The Lean encoding of G (all_future) and H (all_past) introduces NEW `.untl/.snce` nodes. When Case 2 (elim_case_2_gen) is applied inside 10.2.4, its output contains `all_future (¬A)` which has `.untl (¬⊤) (¬A)`. This is NOT `has_single_U_type _ A B`. So 10.2.4's output does NOT preserve `has_single_U_type` in the Lean encoding.

**Lean implementation**: `single_U_formula_separable_noax_param`. Phase A (COMPLETED) makes depth ≤ 1 oracle-free. Depth ≥ 2 still uses oracle.

---

### Lemma 10.2.6 — Multiple U-Types, No Nesting

**Statement**: If U only appears as U(Aᵢ,Bᵢ) for i=1,...,n (with Aᵢ,Bᵢ atom-only), then D is separable.

**Dependencies**: Lemma 10.2.5 (n=1 case)

**Induction**: On n (number of distinct U-types)

**Strategy**: Replace U(Aᵢ,Bᵢ) (i<n) with fresh atoms qᵢ, apply 10.2.5 for U(Aₙ,Bₙ), back-substitute, apply IH on the remaining U-types in the past subformulas.

**Key invariant**: After abstraction and 10.2.5, the separated form has atoms qᵢ in past subformulas. Back-substituting U(Aᵢ,Bᵢ) for qᵢ in past subformulas gives formulas with multiple U-types, handled by IH.

**Lean implementation**: `lemma_10_2_6_self_contained_param`. Depends on `single_U_formula_separable_noax_param` (oracle-parameter).

---

### Lemma 10.2.7 — No S in U, Arbitrary U Nesting Under S

**Statement**: If D has no S nested within U, then D is separable.

**Dependencies**: Lemma 10.2.6

**Induction**: On maximum depth n of U beneath S

**Case n=1**: Lemma 10.2.6

**Case n>1**: 
1. Find maximal U(Aᵢ,Bᵢ) — the least-nested copies where every U is inside one of these
2. The arguments Aᵢ,Bᵢ contain inner U-subformulas U(Xᵢⱼ,Yᵢⱼ)
3. Replace each U(Xᵢⱼ,Yᵢⱼ) in Aᵢ,Bᵢ with fresh atoms zᵢⱼ to get A'ᵢ,B'ᵢ (boolean combinations of atoms)
4. Replace U(Aᵢ,Bᵢ) with U(A'ᵢ,B'ᵢ) in D to get D'
5. D' has no S in U and U-depth 1 → apply Lemma 10.2.6
6. Back-substitute: pure past subformulas with zᵢⱼ become impure when zᵢⱼ → U(Xᵢⱼ,Yᵢⱼ)
7. Apply IH to these now-impure-past formulas (they have strictly smaller U-nesting depth)

**Why IH applies**: U(Xᵢⱼ,Yᵢⱼ) is strictly nested inside U(Aᵢ,Bᵢ), so depth of U in U(Xᵢⱼ,Yᵢⱼ) < depth in U(Aᵢ,Bᵢ). After back-substitution, the measure strictly decreases.

**Lean status**: `no_S_nested_in_U_separable_direct_param` — currently Phase B [BLOCKED] in plan v22. The oracle threading approach fails because at JD=1, the callback receives back the original formula (no measure decrease).

---

### Lemma 10.2.8 — Full Separation by Junction Depth

**Statement**: Any wff in {U,S} is separable over integer time.

**Dependencies**: Lemma 10.2.7

**Induction**: On junction depth d of D (alternation depth of U/S nesting)

**Case d ≤ 1**: Already separated.

**Case d ≥ 2**:
1. Focus on S(D₁,D₂) subformulas (U case dual)
2. Find maximal U(Aᵢ,Bᵢ) inside the formula
3. U(Aᵢ,Bᵢ) contain S-subformulas S(Eᵢⱼ,Fᵢⱼ) (since JD ≥ 2, there's S inside U)
4. Replace each S(Eᵢⱼ,Fᵢⱼ) inside U(Aᵢ,Bᵢ) with fresh atom zᵢⱼ → get U(A'ᵢ,B'ᵢ)
5. Apply Lemma 10.2.7 to get separated E'
6. E' has subformulas of form zᵢⱼ, atoms, S(C₁,C₂), U(C₁,C₂), etc.
7. Back-substitute S(Eᵢⱼ,Fᵢⱼ) for zᵢⱼ
8. The resulting S(Eᵢⱼ,Fᵢⱼ) have JD ≤ d-2, so apply IH

**Why measure decreases**: Abstracting innermost S from U-args reduces JD by 2 (one U-S alternation removed). After back-substitution, resulting subformulas have JD ≤ d-2 < d.

**Lean status**: `all_formulas_separable_aux` — currently Phase C [NOT STARTED] in plan v22.

---

### Theorem 10.2.9 — Separation Theorem (Corollary of 10.2.8)

**Statement**: Each wff in {U,S} is equivalent to a separated wff over integers.

**Lean status**: `all_separable` in `SeparationThm.lean`. Currently relies on axioms (the oracle chain).

---

## Witness Formula Analysis

### Does the Lean Code Keep ¬U(A,B) Unexpanded in Outputs?

**Case 2 (`elim_case_2_gen`)**: Output is `Formula.or psi_l psi1` where:
- `psi1 = case1_psi a q (¬A∧¬B) (¬A)` — contains `.untl (¬A∧¬B) (¬A)`, NOT `(A,B)`. **New U-type introduced.**
- `psi_l = S(a,q∧¬A) ∧ ¬A ∧ G(¬A)` where `G(¬A) = all_future(¬A) = ¬U(⊤,¬A)`. **New U-type `.untl (¬⊤) (¬A)` introduced.**

In both disjuncts, new `.untl` types are introduced. The output does NOT keep ¬U(A,B) unexpanded in the way GHR94 states. **This is the encoding gap.**

**GHR94's Case 2 output**: `[S(a,q∧¬A) ∧ ¬A ∧ ¬U(A,B)] ∨ [¬A∧¬B∧S(a,¬A∧q)] ∨ S(¬A∧¬B∧q∧S(a,¬A∧q), q)`. Note:
- First disjunct has `¬U(A,B)` LITERALLY (unexpanded)
- Second and third disjuncts are U-free
- No `G(¬A)` appears in the output at all

**The Lean code's divergence**: The code uses `neg_until_equiv` to split the ¬U(A,B) at the EVENT point into two branches (G(¬A) branch and U(¬A∧¬B, ¬A) branch). But GHR94 does something more subtle: it uses `G_s(¬A)` (i.e., ¬A holds globally from s forward) to SIMPLIFY `S(a∧G(¬A), q)` into `S(a, q∧¬A) ∧ ¬A ∧ G(¬A)` — but then G(¬A) is "absorbed" into the conjunction and `¬U(A,B)` is RECONSTRUCTED using the equivalence in reverse. The key step is:

```
S(a∧G_s(¬A), q) ↔ S(a, q∧¬A) ∧ ¬A(t) ∧ G_t(¬A)
                 ↔ S(a, q∧¬A) ∧ ¬U(A,B)  [via: ¬A everywhere + ¬B trivially → ¬U]
```

Wait — this is not quite right. Let me re-examine. GHR94's output for Case 2 has `¬U(A,B)` in the FIRST disjunct alongside `S(a,q∧¬A) ∧ ¬A`. The book is saying:

- When G_s(¬A) holds at s (the event point), then: ¬A on (s,t), ¬A(t), and ¬A everywhere after t. This means ¬U(A,B) at every point in (s,t], plus ¬U(A,B) at t itself. In particular, `¬U(A,B)(t)` holds.
- So `S(a∧G_s(¬A), q)` at t implies `S(a,q∧¬A)(t) ∧ ¬A(t) ∧ ¬U(A,B)(t)`.

The output first disjunct `S(a,q∧¬A) ∧ ¬A ∧ ¬U(A,B)` uses `¬U(A,B)` as a CONCISE way to encode "¬A holds globally into the future (at t)". GHR94 knows this is equivalent to `G(¬A)` on integer time but writes `¬U(A,B)` instead because it is syntactically simpler and still has `has_single_U_type`.

**Conclusion**: GHR94 deliberately keeps ¬U(A,B) in the output of Case 2 (first disjunct) to maintain `has_single_U_type`. The Lean code instead introduces `G(¬A) = all_future(¬A)`, which is semantically equivalent but breaks `has_single_U_type` because `all_future(¬A)` unfolds to `.untl (¬⊤) (¬A)`, a new U-type.

**Case 4 output**: The Lean code outputs `¬(all_past(¬a)) ∧ ¬psi1`. Here `all_past(¬a)` contains `.snce` nodes (not `.untl`), so no U-type violation. Case 4 is OK.

**Cases 6, 7, 8**: The `case6_equiv_Z` output is:
```
[S(a,q∧¬A) ∧ ¬A ∧ ¬(B∧U(A,B))] ∨ S(¬B∧¬A∧(q∨U(A,B))∧S(a,q∧¬A), q∨U(A,B))
```
This contains only `U(A,B)` and `¬(B∧U(A,B))`. No new U-types. `has_single_U_type` preserved in the GHR94 direct formula.

---

## The Real Problem

The actual blocker for plan v22 is **Phase B (Lemma 10.2.7 oracle-free)**. The `has_single_U_type` issue is a symptom that appears in an earlier diagnostic but is NOT the fundamental blocker.

**What actually blocks Phase B**: The `no_S_nested_in_U_separable_direct_param` uses an oracle parameter (a callback) to handle IH invocations. At JD=1, the callback is supposed to call a "lower-level" lemma, but at JD=1 the formula already has no S-in-U, so the callback immediately returns it to `all_formulas_separable_aux` which then calls `no_S_nested_in_U_separable_direct_param` again — no measure decrease.

**The fix (per report 21 and plan 22)**: GHR94's structure avoids this circularity by having the layers be genuinely self-contained:
- 10.2.5 uses 10.2.4 (not 10.2.6/7/8)
- 10.2.6 uses 10.2.5 (not 10.2.7/8)
- 10.2.7 uses 10.2.6 (not 10.2.8)
- 10.2.8 uses 10.2.7

The oracle threading in `no_S_nested_in_U_separable_direct_param` inverts this by calling back into 10.2.8. GHR94 never does this.

**Specific problem for has_single_U_type**: Even after making each layer oracle-free, the `has_single_U_type` preservation issue means that applying `snce_single_U_depth_one_separable` (10.2.4) to a formula requires that the C,F arguments have `has_single_U_type`. But after applying Case 2 to eliminate a U from inside an S, the output contains `G(¬A)` which introduces new U-types. This means the NEXT call to 10.2.4 cannot directly use 10.2.3's Case 2 output — it must first handle the new U-types.

However, GHR94 avoids this by using `has_single_U_type`-preserving outputs (keeping `¬U(A,B)` literal). The Lean code introduces `all_future` as a primitive, breaking this invariant.

---

## Recommended Approach

### Short-term (for plan v22 completion)

**Option 1 (Preferred): Modify Case 2 output to keep ¬U(A,B) literal**

Replace the current Case 2 Lean output which introduces `G(¬A)` with an output that keeps `¬U(A,B)` literally, matching GHR94's stated output:

```
Case 2 correct output = [S(a,q∧¬A) ∧ ¬A ∧ ¬U(A,B)] ∨ [¬A∧¬B∧S(a,¬A∧q)] ∨ S(¬A∧¬B∧q∧S(a,¬A∧q), q)
```

This keeps `has_single_U_type` and matches GHR94 exactly. The proof strategy:
- For the G(¬A) branch: instead of outputting `S(a,q∧¬A) ∧ ¬A ∧ G_t(¬A)`, output `S(a,q∧¬A) ∧ ¬A ∧ ¬U(A,B)` since `G_t(¬A) → ¬U(A,B)` on integers.
- The backward direction must verify that `S(a,q∧¬A) ∧ ¬A ∧ ¬U(A,B)` implies `S(a∧¬U(A,B), q)`.

This approach requires revising `elim_case_2_gen` but keeps all downstream lemmas intact.

**Option 2: Use the has_single_U_type-free `is_separable` path**

Plan v22 Phase A already took this route for the depth ≤ 1 case: prove `is_separable` (existence) rather than preserving `has_single_U_type`. Phase B can do the same: prove `no_S_nested_in_U_separable_direct` without needing `has_single_U_type` on the output. GHR94's 10.2.7 proof produces a separable equivalent; it does not say the output has `has_single_U_type`.

This is already the direction of plan v22 (Phase B uses `is_separable`, not a `has_single_U_type`-bearing statement). So there is no actual blocker from `has_single_U_type` for phases B/C/D/E.

### Why Phase B Is The Real Blocker

Phase B needs to prove `no_S_nested_in_U_separable_direct_param` without oracle threading. The fix is:
1. Abstract inner U-subformulas U(Xᵢⱼ,Yᵢⱼ) from U-args using fresh atoms (GHR94 step 3 in 10.2.7)
2. Apply `lemma_10_2_6_self_contained_param` (already oracle-free after Phase A)
3. Back-substitute and use IH (IH is valid because U(Xᵢⱼ,Yᵢⱼ) is strictly nested inside U(Aᵢ,Bᵢ))

The induction measure is `U_depth_under_S`, which strictly decreases. No oracle threading needed.

---

## Confidence Level

- **GHR94 output analysis**: HIGH (read text directly, confirmed outputs)
- **has_single_U_type analysis**: HIGH (read Lean definitions, confirmed which cases break it)
- **Encoding gap (G/H as primitives)**: HIGH (observed directly in code)
- **Plan v22 phase status**: HIGH (read plan, phases A.1, A.2 marked COMPLETED)
- **Phase B fix direction**: MEDIUM-HIGH (consistent with GHR94 10.2.7 structure, but have not traced the full Lean proof attempt)
- **Case 2 GHR94 output vs. Lean divergence**: HIGH (text is unambiguous: ¬U(A,B) literal, not expanded)
