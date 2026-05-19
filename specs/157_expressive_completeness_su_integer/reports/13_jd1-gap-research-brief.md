# Research Brief: JD=1 Callback Circularity in Separation Theorem

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Status**: Phase 3 BLOCKED
**Priority**: Critical — blocks Phases 3-6 of the plan

---

## Problem Statement

The hierarchy theorem (`all_formulas_separable_aux` in `Hierarchy.lean`) proves that every formula in bimodal logic TM has a syntactically separated equivalent. The proof follows GHR94 (Gabbay, Hodkinson, Reynolds 1994) Lemmas 10.2.5–10.2.8.

The proof architecture uses two layers of induction:
1. **Outer**: `Nat.strongRecOn` on `junction_depth` (JD)
2. **Inner**: `count_U_subformulas` induction within `no_S_nested_in_U_separable_param_jd`

At each inner step, a `.untl A B` is abstracted (replaced by a fresh atom), the simpler formula is proved separable by the count_U IH, separated, and `.untl A B` is substituted back. The substitution step uses `subst_in_separated_separable_jd`, which invokes a **callback** on `.snce` nodes where the substitution breaks U-freeness.

**The gap**: Callback formulas have `junction_depth ≤ 1` (proved by `callback_jd_le_one`). For JD level n ≥ 2, the outer IH handles them (1 < n). For JD level n = 1, the IH requires JD < 1 = 0, but callbacks can have JD = 1. **Two sorry calls remain** at Hierarchy.lean lines ~1773 and ~1806.

## Why This Is Hard

The gap is not a Lean technicality — it reflects a genuine proof-theoretic challenge. The abstract-substitute roundtrip at count_U = 1 is an **identity operation**:

```
φ = .snce (.untl A B) q          -- count_U = 1, JD = 1
abstract:  .snce (atom p) q       -- count_U = 0, separated
substitute back: .snce (.untl A B) q = φ   -- SAME FORMULA
```

The callback returns the exact input. No formula-level measure decreases. This creates genuine non-termination if the callback calls itself recursively.

The 2 sorry calls are **mathematically equivalent to the `snce_separable` axiom**: given `is_separable a` and `is_separable b`, prove `is_separable (.snce a b)`. This is the temporal closure property — the very axiom the task aims to eliminate.

## Prior Work and Approaches Tried

### What Exists (proved, no sorry)
| Theorem | Location | What it proves |
|---------|----------|----------------|
| `callback_jd_le_one` | Hierarchy.lean ~1579 | Callback formulas have JD ≤ 1 |
| `subst_in_separated_separable_jd` | ~1620 | JD-bounded version of subst_in_separated_separable |
| `no_S_nested_in_U_separable_param_jd` | ~1656 | Count_U induction with JD-bounded callback |
| `all_formulas_separable_aux` (JD ≥ 2) | ~1725 | Fully proved for JD ≥ 2 and JD = 0 |
| `single_U_formula_separable` | ~170 | Handles single-U-type formulas (but uses `snce_separable` axiom) |
| Cases 1-8 | Eliminations.lean, DedekindZ.lean | Handle specific `.snce(.untl(...))` patterns |
| `expand_temporal_id` | TemporalClosure.lean | expand_temporal is a no-op (6-constructor language) |
| `has_no_allpast_allfuture_true` | TemporalClosure.lean | Trivially true for all formulas |

### Approaches Tried and Why They Failed
| # | Approach | Failure reason |
|---|----------|----------------|
| 1 | Self-referential callback (`no_S_nested_sep_callback`) | Genuinely non-terminating (identity roundtrip) |
| 2 | Prove callback JD = 0 at n=1 | Disproved by counterexample |
| 3 | Lexicographic (count_U, sizeOf) | Neither component decreases for identity roundtrip |
| 4 | `snce_depth_of_U` measure | Can increase through substitution |
| 5 | Process χa, χb separately | Gives `is_separable a` + `is_separable b` but not `is_separable (.snce a b)` |
| 6 | Cases 1-8 directly at JD=1 | Require A, B to be U-free; S-free args can contain `.untl` |
| 7 | Change JD definition (+1 at temporal operators) | Shifts gap to higher JD level without eliminating it |
| 8 | Fuel-based recursion | Identity roundtrip consumes fuel without making progress; no finite fuel suffices |
| 9 | `partial def` | Lean rejects: `is_separable` is Prop, not Inhabited |
| 10 | Mutual recursion (`all_sep` + `snce_sep`) | Lean detects unprovable size decreases across mutual calls |

Full analysis: `specs/157_expressive_completeness_su_integer/handoffs/jd1-circularity-analysis-20260519.md`

## Research Questions

### Question 1: Can the JD definition be modified to make JD=1 trivial WITHOUT shifting the gap?

The current definition:
```
junction_depth(.untl a b) = max(jdU a, jdU b)        -- no +1
junction_depth(.snce a b) = max(jdS a, jdS b)        -- no +1
junction_depth_U(.snce a b) = 1 + max(jd a, jd b)    -- +1 at alternation
junction_depth_S(.untl a b) = 1 + max(jd a, jd b)    -- +1 at alternation
```

With +1 at temporal operators: `JD(.untl a b) = 1 + max(jdU a, jdU b)`. This makes JD=0 mean "no temporal operators" and JD=1 mean "temporal with non-temporal args" (trivially separated). But does the callback JD bound still give strict decrease at the new critical level?

**Specific sub-questions**:
- With the +1 definition, what is `callback_jd_le_N` for the new definition? Is it still ≤ 1, or does it become ≤ 2?
- At the new critical JD level (where the gap would be), are the `.untl A B` args guaranteed to be BOTH S-free AND U-free?
- How many existing JD lemmas need re-proving? (Estimate: ~20-50 in Defs.lean, TemporalClosure.lean, Hierarchy.lean)

**Key files**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (JD definitions, lines 300-440)

### Question 2: Can `no_S_nested_in_U_separable_param` be restructured to avoid callbacks?

The callback in `subst_in_separated_separable` handles `.snce` nodes where substituting `.untl A B` breaks U-freeness. What if instead of calling an external callback, we handle these `.snce` nodes INLINE using Cases 1-8?

**Specific sub-questions**:
- Do Cases 1-8 cover ALL `.snce(.untl(...))` patterns that arise from substitution into separated forms? Or only specific shapes?
- Can Cases 1-8 be applied with `.untl A B` where A is S-free but NOT U-free? (Current Cases require both.)
- If Cases 1-8 don't directly apply, can a "flattening" lemma convert S-free-but-not-U-free args to U-free equivalents?
- What is the structural relationship between the callback `.snce` formula and the original formula? Is the callback `.snce` always a structural sub-expression of the separated form?

**Key files**: 
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (Cases 1-8)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (Cases 5-8)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (subst_in_separated_separable, lines 1144-1172)

### Question 3: Is there an alternative proof of the separation theorem that avoids the callback pattern?

GHR94's proof inherently uses "by the result we are proving" — a fixed-point argument. Are there alternative proofs of temporal separation/expressive completeness that are constructively valid?

**Specific sub-questions**:
- Does the automata-theoretic proof of expressive completeness (via temporal logic ↔ counter-free automata) avoid the circularity?
- Can the separation theorem be proved model-theoretically (show every formula has a separated model-equivalent) instead of syntactically?
- Is there a game-theoretic or Ehrenfeucht-Fraïssé approach?
- How do other Lean 4 formalizations handle similar "proof by the result we are proving" patterns? (Check Mathlib for examples.)

**Key literature**:
- `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` — GHR94 Chapter 10 (primary source)
- `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` — GHR94 Chapter 9 (related)

### Question 4: Can a well-founded global measure be defined that accounts for the entire callback chain?

The individual callback doesn't decrease any formula-level measure, but the TOTAL computation IS finite. Can we define a measure on the entire computation tree (not just individual formulas) that's well-founded?

**Specific sub-questions**:
- Can multiset orderings (Dershowitz-Manna) capture the termination argument?
- Can the computation be modeled as a decreasing chain in `ω²` (pairs of naturals with lexicographic ordering)?
- Is there a "total work" measure (summing across all callback levels) that strictly decreases?
- Can `Acc.intro` be used to manually construct an accessibility proof without a computable measure?

**Key Lean 4 concepts**: `WellFoundedRelation`, `InvImage`, `Prod.Lex`, `Multiset.lt`, `Acc.intro`

## Codebase State

### File locations
```
Theories/Bimodal/Metalogic/WeakCanonical/Separation/
  Defs.lean          -- JD definitions, predicates, simp lemmas
  TemporalClosure.lean -- expand_temporal, has_no_allpast_allfuture (trivially true)
  Hierarchy.lean     -- Main hierarchy proof (2 sorry at lines ~1773, ~1806)
  Eliminations.lean  -- Cases 1-5 (elimination procedures)
  DedekindZ.lean     -- Cases 6-8 (Dedekind specialization)
  SeparationThm.lean -- 9 axioms (to be eliminated)
  DualEliminations.lean -- 8 sorry (dual cases)
  FormulaOps.lean    -- abstract_untl, abstract_snce, subst_formula
  NormalForm.lean, Distributivity.lean, NegationEquiv.lean, IntHelpers.lean, Duality.lean
```

### Key theorem signatures
```lean
-- The 2 sorry calls are in the callback for this:
theorem no_S_nested_in_U_separable_param_jd (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hexp : has_no_allpast_allfuture phi = true)
    (callback : ∀ (χ : Formula), no_S_nested_in_U χ → junction_depth χ ≤ 1 → is_separable χ) :
    is_separable phi

-- The callback is invoked here (line ~1170):
theorem subst_in_separated_separable_jd (ψ : Formula) (p : Atom) (A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hsep : is_syntactically_separated ψ = true)
    (ih_snce : ∀ (χ : Formula), no_S_nested_in_U χ → junction_depth χ ≤ 1 → is_separable χ) :
    is_separable (subst_formula ψ p (.untl A B))

-- The axiom we're trying to eliminate:
axiom snce_separable (φ ψ : Formula) (h1 : is_separable φ) (h2 : is_separable ψ) :
    is_separable (.snce φ ψ)
```

### Build and verify commands
```bash
lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy
lean_verify all_formulas_separable  -- should show NO sorryAx when fixed
grep -n "sorry" Hierarchy.lean      -- should return empty when fixed
```

## Handoff Files (Prior Analysis)
- `handoffs/jd1-circularity-analysis-20260519.md` — Exhaustive analysis of all 10 approaches tried
- `handoffs/jd-induction-handoff-20260519.md` — JD induction restructuring notes
- `handoffs/phase-3-callback-analysis-20260518.md` — Detailed callback chain analysis (20 pages)
- `handoffs/phase-3-callback-blocker-20260518.md` — Callback blocker documentation
- `handoffs/phase-3-constituent-subst-20260518.md` — Constituent substitution analysis

## Success Criteria

Phase 3 is complete when:
1. `grep -n "sorry" Hierarchy.lean` returns empty
2. `lean_verify all_formulas_separable` shows `["propext", "Classical.choice", "Quot.sound"]` — NO `sorryAx`
3. `grep -n "all_separable" Hierarchy.lean` returns only comments
4. `lake build` passes
