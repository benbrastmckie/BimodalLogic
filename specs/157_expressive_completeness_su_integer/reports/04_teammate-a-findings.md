# Teammate A Findings: Cases 5-8 Explicit Formulas on Integer Time

**Date**: 2026-05-17
**Focus**: Find correct explicit separated formulas for Cases 5-8 on integer time (ℤ), to break the circular dependency in the GHR94 separation proof.
**Session**: sess_1779040893_b6c1b2 (Phase 6 team research)

---

## Key Findings

### Finding 1: The GHR94 Explicit Formulas for Cases 5-8 Are All Incorrect on ℤ

The literature (GHR94 Lemma 10.2.3) provides explicit separated formulas for Cases 5-8, but ALL are incorrect for integer (discrete) time. The root cause is the same for all four cases: **vacuous B-guards on empty open intervals**.

On ℤ, the open interval (n, n+1)_ℤ = ∅. This means U(A,B)(n) can hold with A(n+1) as the witness and an empty B-guard — B is not required to hold at any point. GHR94's formulas for Cases 5-8 were designed with dense-time intuitions that assume U(A,B) forces B to hold somewhere in the evaluation interval.

**Confirmed counterexamples** (from existing report `02_case5-blocker-research.md`):

- **Case 5** (`S(a ∧ U(A,B), q ∨ U(A,B))`): GHR94's formula requires `A ∨ (B ∧ U(A,B))` at evaluation point t. Counterexample: a(0)=true, A(1)=true, B=false, q(1)=q(2)=true, t=3. LHS=TRUE, RHS=FALSE.

- **Case 5 corrected formula also fails**: The replacement of `[A ∨ (B ∧ U(A,B))]` with `¬S(¬q,¬A)` (the second published attempt at a fix) also fails because `S(¬q, ¬A)` is trivially true when `¬q(t-1)` holds — the interval (t-1, t)_ℤ is empty, making ¬A hold vacuously.

- **Cases 6, 7, 8**: GHR94 reduces these to earlier cases (6 → Cases 3, 5; 7 → Cases 4, 8; 8 → Cases 3, 5 via negation). Since Case 5's formula is wrong, all downstream formulas are also wrong.

### Finding 2: The Dense-Time Formulas Cannot Be Simply "Fixed" on ℤ

After extensive analysis documented in `02_case5-blocker-research.md`, every attempted correction to the Case 5 formula encounters the same fundamental problem: any formula that must encode "the U-chain from the S-witness covers up to the evaluation point" fails on ℤ because:

1. The B-guard in U(A,B) can be vacuous (empty interval)
2. Consecutive U-witnesses need not propagate B-coverage
3. Any formula using `¬S(¬q, ¬A)` as a density substitute fails because S witnesses at t-1 hold vacuously

The backward direction of any proposed formula for Case 5 always fails at the S-witness point u: we need `q(u) ∨ U(A,B)(u)` in the original guard, but the separated equivalent has the witness u as an event point, providing no information about `q(u)` or `U(A,B)(u)`.

**This is a fundamental obstacle, not a search failure.** The difficulty is structural.

### Finding 3: GHR94's True Proof Strategy Does Not Use Explicit Formulas for Cases 5-8

Reading GHR94 Chapter 10.2 carefully reveals that the ACTUAL proof structure does NOT rely on explicit formulas for Cases 5-8 in the way initially assumed. The proof hierarchy is:

```
Lemma 10.2.8 (junction_depth induction — main theorem)
  → Lemma 10.2.7 (no S within U — U-nesting induction)
  → Lemma 10.2.6 (multi-U — count induction)
  → Lemma 10.2.5 (single U — S-nesting induction)
  → Lemma 10.2.4 (single S with single U — normal form + 8 cases)
  → Lemma 10.2.3 (8 elimination cases)
```

**The key insight**: Cases 5-8 in Lemma 10.2.3 are used only INSIDE Lemma 10.2.4. Lemma 10.2.4's call to Cases 5-8 is NOT a direct semantic equivalence — it passes through Lemma 10.2.6's multi-U induction machinery. When Case 5 introduces a second U-type (via `neg_until_equiv` expansion of `¬U(A,B)`), the resulting two-U situation is handled by Lemma 10.2.6 (induction on U-count), NOT by needing a single explicit separated formula for the two-U case.

GHR94's Case 5 explicit formula is presented as a SHORTCUT that happens to be incorrect for ℤ. The correct proof for ℤ goes through the full hierarchy.

### Finding 4: The Junction-Depth Induction Avoids All Cases 5-8 Issues

The junction-depth induction (Lemma 10.2.8) resolves the circular dependency without needing correct explicit formulas for Cases 5-8:

1. **Base case** (junction_depth ≤ 1): Formula is already syntactically separated by definition.

2. **Inductive step** (junction_depth ≥ 2):
   - Find maximal U-subformulas U(A_i, B_i) covering all U in the formula
   - Find S-subformulas S(E_ij, F_ij) INSIDE those U's
   - Replace them with fresh atoms z_ij
   - The resulting formula has "no S nested within U" (satisfies Lemma 10.2.7's hypothesis)
   - Apply Lemma 10.2.7 (which uses Cases 1-4 ONLY when S-free args appear in U-contexts)
   - Resubstitute: each S(E_ij, F_ij) has junction_depth ≤ d-2
   - Apply the IH

**Crucially**: In the inductive step of Lemma 10.2.8, the formula passed to Lemma 10.2.7 has all S-subformulas REMOVED from inside U's. The remaining U-formulas have S-free args. This means the formula satisfies `no_S_nested_in_U`, and the 8-case elimination in Lemma 10.2.4 is called ONLY on formulas where U-args of U(A,B) are S-free. In this restricted setting, Cases 5-8 situations (U in both event and guard of S) can be handled differently.

### Finding 5: The Remaining Obstacle in Our Lean Formalization Is NOT Cases 5-8

The blocker reported in the Phase 6 handoff frames the problem as "Cases 5-8 need explicit formulas or use all_separable circularly." This is technically accurate but misidentifies the root cause.

The real obstacle is that our formalization **lacks the GHR94 hierarchical proof structure**. Specifically:

- `all_separable` is proved by structural induction with temporal closure AXIOMS for the temporal cases
- The temporal closure axioms assert that temporal operators preserve separability
- These axioms encapsulate Lemmas 10.2.4-10.2.8 of GHR94
- Cases 5-8 (in NormalForm.lean) call `all_separable _` — they use the CONCLUSION as a premise (circular)

The circularity is not between "Cases 5-8 and all_separable" specifically, but between "the temporal closure axioms and all_separable." Cases 5-8 happen to be a visible symptom.

### Finding 6: The Correct Path Requires Implementing Lemma 10.2.8 (Junction-Depth Induction)

From reading reports `09_junction-depth-approach.md` and `10_ghr94-junction-depth-literature.md`:

The approach that genuinely breaks the circularity is a **well-founded induction on junction_depth** that replaces the 4 temporal closure axioms. The `junction_depth` function is already implemented in `Defs.lean`.

**Critical complication in our formalization**: GHR94 treats G (all_future) and H (all_past) as DERIVED from U/S. In our formalization, they are PRIMITIVE constructors. This means:

- `all_future(snce p q)` has junction_depth = 0 in our formalization (all_future is transparent)
- But in GHR94, `G(S(p,q)) = neg U(neg S(p,q), top)` has junction_depth = 1

This discrepancy means the junction_depth = 0 base case is NOT trivially separated in our formalization. The formula `all_past(untl A B)` has junction_depth = 0 but is NOT syntactically separated (all_past requires U-free arg, but untl is not U-free).

This is documented in `phase-6-handoff-20260517e.md` as "Finding 1: junction_depth_zero does NOT imply syntactically_separated."

---

## Recommended Approach

**The primary focus for breaking the circularity is NOT finding explicit formulas for Cases 5-8, but rather implementing the junction-depth induction hierarchy.**

### Recommended Implementation: Mutual WF Induction

Based on reports `09` and `10`, the recommended approach is a mutual well-founded induction:

```lean
theorem no_S_nested_in_U_separable (phi : Formula)
    (h : no_S_nested_in_U phi) : is_separable phi

theorem no_U_nested_in_S_separable (phi : Formula)
    (h : no_U_nested_in_S phi) : is_separable phi
```

Where each calls the other at strictly lower junction_depth. The well-founded measure is `(junction_depth phi, count_U_subformulas phi + count_S_subformulas phi)` with lexicographic ordering.

**Key structural facts that make this work**:
1. In a syntactically separated formula, all `untl` nodes have S-free args (from `is_syntactically_separated` definition)
2. S-free args have junction_depth = 0 (proved: `s_free_junction_depth_zero`)
3. Therefore `junction_depth_S(.untl A B) = 1` when A, B are S-free
4. Therefore `junction_depth(.snce phi' psi') ≤ 1` when phi', psi' are separated (proved: `snce_of_boxfree_sep_jd_le_one`)
5. For junction_depth ≤ 1, the formula has at most one level of U-under-S — this IS handled by Cases 1-4 alone (the Cases 5-8 issue arises only when U appears simultaneously in event and guard, which requires a specific structural configuration that Cases 1-4 do handle for appropriate argument shapes)

**On Cases 5-8 specifically**: When the junction_depth is bounded at 1, Cases 5-8 arise from `snce (untl A B) (untl A B)` or similar. In the junction-depth proof, when we encounter such a formula:
- It satisfies `no_S_nested_in_U` (since A, B are S-free)
- The mutual induction handles it via the single-U abstraction approach: abstract one `untl A B` to a fresh atom, get a Case 1-4 pattern, substitute back, apply IH

The substitution back introduces a new `untl A B` under S, but this is at a LOWER position in the formula hierarchy (the fresh atom is now gone, so count decreases) — making the measure strictly decrease.

### Estimated Implementation Effort

| Component | LOC | Priority |
|-----------|-----|----------|
| `abstract_snce` (dual of `abstract_untl`) | ~100 | High |
| `count_S_subformulas` | ~30 | High |
| `junction_depth_decrease` lemmas | ~100 | High |
| `no_S_nested_in_U_separable` theorem | ~200 | High |
| `no_U_nested_in_S_separable` theorem (via duality) | ~100 | High |
| Integration into SeparationThm.lean | ~50 | High |
| **Total** | **~580** | |

---

## Evidence and Examples

### Evidence 1: GHR94's Case 6 Proof Explicitly Reduces to Cases 3 and 5

GHR94 Lemma 10.2.3.6 text (from our markdown): "Eliminations (3) and (5) can be used to finish the separating." This explicit reference to Case 5 as a subcase confirms that Cases 6-8 in GHR94 are NOT proved by explicit formulas — they reduce to earlier cases. Our formalization must implement this reduction, but doing so requires the hierarchical proof framework.

### Evidence 2: GHR94's Case 8 Uses Negation Reduction

GHR94 Lemma 10.2.3.8 (from our markdown): The case reduces by:
```
¬D ↔ H(¬a ∨ U(A,B)) ∨ S(¬q ∧ U(A,B) ∧ ¬a, ¬a ∨ U(A,B))
```
(where the third disjunct is redundant). This is then handled by "elimination (5)" — i.e., Case 5. So Case 8 depends on Case 5, and Case 5 is proved by GHR94 with an incorrect explicit formula. The correct proof must go through the hierarchical framework.

### Evidence 3: The `snce_of_boxfree_sep_jd_le_one` Lemma Already Exists

In `TemporalClosure.lean`, the key bound is already proved:
```lean
theorem snce_of_boxfree_sep_jd_le_one
```
This establishes that `.snce phi' psi'` with box-normalized separated phi', psi' has junction_depth ≤ 1. This is the foundation for the mutual WF induction approach.

### Evidence 4: Duality Infrastructure Is Already in Place

From `Duality.lean`, the `swap_temporal` duality is available. This means the `no_U_nested_in_S_separable` direction can be derived from `no_S_nested_in_U_separable` via:
```
no_U_nested_in_S(phi) → no_S_nested_in_U(swap phi) → separable(swap phi) → separable(phi)
```
This reduces the implementation to proving only ONE direction of the mutual induction.

---

## What Was NOT Found

**There are no correct explicit separated formulas for Cases 5-8 on ℤ in any of the literature surveyed.** This includes:

- GHR94 Volume 1 (formula is incorrect for ℤ)
- Reynolds 1994 "Axiomatising U and S over integer time" (proves expressive completeness via completeness proof, does not give explicit separation formulas)
- Hodkinson & Reynolds 2006 "Temporal Logic" Handbook Chapter 11 (cites GHR94 without correction)
- Gabbay 1989 "The declarative past and imperative future" (original source for GHR94 Chapter 10.2, similarly has the dense-time formula)

The search for explicit formulas for ℤ is almost certainly a genuinely open mathematical problem. The formulas are known to EXIST (by the semantic argument), but their explicit form is not in the literature.

---

## Confidence Level

**High confidence** in findings 1-5. The counterexamples are verified and the structural analysis of GHR94's proof hierarchy is well-documented across multiple research reports.

**Medium confidence** in the recommended approach. The mutual WF induction is the theoretically correct approach, but:
- The `all_past`/`all_future` primitive constructor issue adds complexity (junction_depth = 0 does not imply separated in our formalization)
- Lean's termination checker may require explicit `decreasing_by` annotations for the compound lexicographic measure
- The `abstract_snce` infrastructure needs to be built from scratch

**The blocker is real** but is NOT "find explicit formulas for Cases 5-8" — it is "implement the junction-depth induction hierarchy from GHR94 Lemmas 10.2.4-10.2.8." This is a mathematical engineering task, not an open research problem.

---

## Interaction with the Phase 6 Blocker

The circularity:
```
all_separable → temporal closure axioms → Cases 5-8 proofs → all_separable
```

Is broken by the mutual WF induction approach:
```
no_S_nested_in_U_separable (WF on measure) → no_U_nested_in_S_separable (via duality)
→ snce_separable (separated + snce has jd ≤ 1 → no_S_nested_in_U)
→ all_separable (structural induction, temporal cases use snce_separable etc.)
```

Cases 5-8 situations that arise during the WF induction are handled by the **fresh-atom abstraction technique** (abstract one untl, apply Cases 1-4, substitute back, use WF IH on the reduced count measure) — NOT by explicit separated formulas.

The elimination case theorems in `Eliminations.lean` (Cases 1-4) remain unchanged. The axioms in `SeparationThm.lean` are replaced by theorems proved via the WF induction. The `case5_separable` through `case8_separable` theorems in `NormalForm.lean` can be replaced by direct calls to `no_S_nested_in_U_separable` (which handles these cases as part of the general machinery).

---

## References

- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1*. Chapter 10. (Literature copy: `/home/benjamin/Projects/ProofChecker/literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`)
- Reynolds, M. (1994). "Axiomatising first-order temporal logic: Until and since over linear time." (Literature copy: `/home/benjamin/Projects/ProofChecker/literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`)
- Previous research: reports 02, 05, 08, 09, 10 in `specs/157_expressive_completeness_su_integer/reports/`
- Phase 6 handoff: `specs/157_expressive_completeness_su_integer/handoffs/phase-6-handoff-20260517e.md`
- Lean source: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/`
  - `Eliminations.lean` (Cases 1-4 proved; Cases 5-8 comments explain the issue)
  - `SeparationThm.lean` (temporal closure axioms)
  - `TemporalClosure.lean` (infrastructure including `snce_of_boxfree_sep_jd_le_one`)
  - `NormalForm.lean` (case5_separable through case8_separable using `all_separable _`)
