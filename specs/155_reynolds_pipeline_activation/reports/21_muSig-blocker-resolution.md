# muSig Blocker Resolution: stavi_table_mu_correct stavi_untl/snce

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-21
**Session**: sess_1779402190_f77b09

## 1. Blocker Analysis

### What Is Blocked

Two sorries remain in `stavi_table_mu_correct` (EFGames.lean lines 4188, 4191):
- `stavi_untl A B` case
- `stavi_snce A B` case (past dual)

These prove that evaluating `stavi_table_mu atomMap (A.stavi_untl B)` -- the FO encoding of the Stavi U' connective -- matches `stavi_temporal_truth_mu` (the semantic definition).

### Root Cause (Verified by LSP Experiments)

The blocker is **NOT** about `Fin.cons` reduction at specific indices. The handoffs incorrectly identified this as the core problem. Experiments show:

1. `Fin.cons x f (Fin.mk k proof)` **does** reduce definitionally (confirmed by `rfl` tests at depth 4).
2. The `simp only [Fin.cons, Fin.cases]` step is **unnecessary and harmful** -- it creates `Fin.induction` residues that obscure the goal.
3. Without `simp only [Fin.cons, Fin.cases]`, the `rintro` patterns successfully destructure the existential/universal structure using definitional equality.

**The real blocker** is a **logical structure mismatch** between the FO encoding and the semantic definition:

- The FO formula `stavi_untl_fo` encodes disjunction as `not (and (not A) (not B))` because monadic FO has only `not`, `and`, `all`, `ex`.
- The semantic definition `stavi_temporal_truth_mu` uses clean Lean `Or` for the body disjunction.
- After `simp only [not_and, Classical.not_not]`, the FO side becomes `not A -> B` (an implication), **not** `A Or B`.
- Tactics like `rcases ... with ... | ...` and `left`/`right` expect `Or` and fail on implications.

### Evidence

An LSP `multi_attempt` test of the full block-comment proof (lines 4196-4506) with corrected parenthesization produces three specific errors:

1. **Forward direction (FO -> semantic), body case**: `rcases hbody_u hguard with (disj1, disj2) | (hall, hexv)` fails because after `simp only [not_and, Classical.not_not]`, `hbody_u hguard` has type `not_disj1 -> disj2` (an implication), not `Or`.

2. **Backward direction (semantic -> FO), body disjunct 1**: `left` fails because the target `not (not (exists v ...) and not (...))` is not an inductive `Or` type.

3. **Backward direction, init case**: `(lift3_iffB s uinit v).mpr (hinit v htv hvu hmu_v)` produces an `eval` term that gets incorrectly parsed as being applied to a subsequent parenthesized expression.

## 2. Mathlib Findings

### Relevant Lemmas

| Lemma | Type | Usage |
|-------|------|-------|
| `Fin.cons_zero` | `Fin.cons x p 0 = x` | Not needed (definitional equality suffices) |
| `Fin.cons_succ` | `Fin.cons x p i.succ = p i` | Not needed (definitional equality suffices) |
| `Fin.cons_one` | `Fin.cons x p 1 = p 0` | Not needed |
| `not_and` | `not (a and b) <-> (a -> not b)` | Used in proof (converts FO negation) |
| `Classical.not_not` | `not (not a) <-> a` | Used in proof (eliminates double negation) |
| `Classical.or_iff_not_imp_left` | `a or b <-> (not a -> b)` | **KEY MISSING LEMMA** -- bridges FO encoding to semantic Or |
| `not_and_or` | `not (a and b) <-> not a or not b` | Alternative to `not_and` that produces `Or` directly |

### Key Insight: `not_and_or` vs `not_and`

The previous sessions used `simp only [not_and, Classical.not_not]` which produces implications. Using `not_and_or` instead would produce `Or` directly:

- `not_and`: `not (A and B) <-> (A -> not B)` -- produces implication
- `not_and_or`: `not (A and B) <-> (not A or not B)` -- produces Or

However, the FO encoding for disjunction is `not (not A and not B)`, so:
- With `not_and_or`: `not (not A and not B) <-> not (not A) or not (not B) <-> A or B` (after `Classical.not_not`)
- This IS the right conversion.

## 3. Literature Context

### GHR93 Section 3: The FO Table for U'(A,B)

From Gabbay, Hodkinson, Reynolds (1993), Section 3, the FO table for U'(p,q) over a monadic structure (T, <) is:

```
U'(p,q)(t) = exists s (
  t < s
  and forall u (t < u < s ->
    (exists v (u < v and forall w (t < w < v -> q(w)))
     OR
     (forall v (u < v < s -> p(v)) and exists v (t < v < u and not q(v)))))
  and exists u (t < u < s and not q(u))
  and exists u (t < u < s and forall v (t < v < u -> q(v)))
)
```

The OR in the body is the critical structure. In the Lean FO encoding (`stavi_untl_fo`), this OR is represented as `not (and (not disj1) (not disj2))` using De Bruijn indices and `MonadicFormula` constructors.

### The mu-Relativization

The Lean formalization adds mu-relativization: quantified variables u, v, w, v' are restricted to `IsPoint` (mu-points in the extended structure). The bound s is NOT mu-restricted (it marks where the gap is). This matches the GHR93 definition where the gap witness s is a supremum point that may not be in the original structure.

### Quantifier Depth

The stavi_untl_fo formula has 4 quantifier levels:
- Level 1: `exists s` (bound)
- Level 2: `forall u` (body), `exists u_fail`, `exists u_init`
- Level 3: `exists v` (disj1), `forall v` (disj2 hall), `exists v'` (disj2 hexv), `forall v` (init)
- Level 4: `forall w` (B-cofinal in disj1)

## 4. Recommended Strategy

### Problem With Previous Approaches

The block comment proof (lines 4196-4506) uses `simp only [not_and, Classical.not_not]` to normalize the FO negation encoding. LSP testing revealed this fails because `simp` applies `not_and` recursively to ALL `not (A and B)` subterms, including the disjunction encoding `not (not disj1 and not disj2)`. After simp, the disjunction becomes an implication `not disj1 -> disj2`, which `rcases ... | ...` and `left`/`right` cannot handle (they require `Or`).

Trying `not_and_or` instead has the opposite problem: it converts the outer guard encoding too, producing a deeply nested `Or` tree that cannot be applied as a function.

### Primary Fix: Two-Level Conversion with Local Helper

The fix uses a two-level strategy that separates implication conversion from disjunction conversion:

**Level 1** (outer `not (guard and not body)`): Use `simp only [not_and, Classical.not_not]` to get `guard -> body`. This is correct because the outer level IS an implication.

**Level 2** (inner `not (not disj1 and not disj2)`): Use a local helper to convert to `Or`:

```lean
have not_not_and_not : forall (P Q : Prop), not (not P and not Q) -> P or Q := by
  intro P Q h; by_contra hc; push_neg at hc; exact h (And.intro hc.1 hc.2)
```

Then at the point where we have `h : not (not disj1 and not disj2)`, apply `not_not_and_not _ _ h` to get `disj1 or disj2`, which `rcases` handles.

### Detailed Proof Approach for stavi_untl

1. **Lift infrastructure**: Copy lift lemmas 1-4 and IH-based iff lemmas from the block comment (lines 4196-4281). These are verified correct.

2. **Initial simp**: `simp only [stavi_table_mu, stavi_untl_fo, eval, stavi_temporal_truth_mu, extendedStructureWithMu, mu_holds]`. Do NOT add `Fin.cons` or `Fin.cases` to the simp set -- `Fin.cons` reduces definitionally at `Fin.mk` indices, confirmed by `rfl` tests at depth 4.

3. **Local helper**: Define `not_not_and_not` as above.

4. **Forward direction** (FO -> semantic):
   ```lean
   rintro (s, hts, hbody, (ufail, hmu_ufail, htuf, hufs, hnB_ufail), (uinit, ...))
   refine (s, hts, ?_, ?_, ?_)
   -- Body: 
   intro u htu hus hmu_u
   have hbody_u := hbody u
   simp only [not_and, Classical.not_not] at hbody_u   -- guard -> body
   have h := hbody_u (hmu_u, htu, hus)                -- body
   rcases not_not_and_not _ _ h with (disj1 | disj2)  -- Or!
   -- Fail and Init: same pattern as block comment
   ```

5. **Backward direction** (semantic -> FO):
   ```lean
   rintro (s, hts, hbody, (ufail, ...), (uinit, ...))
   refine (s, hts, ?_, ?_, ?_)
   -- Body:
   intro u
   simp only [not_and, Classical.not_not]
   rintro (hmu_u, htu, hus)
   -- Need to produce: not (not disj1_fo and not disj2_fo)
   -- Use: intro (h1, h2); apply h1 or h2 using Or from semantic side
   rcases hbody u htu hus hmu_u with (... | ...)
   -- For each disjunct, construct intro (hn1, hn2); exact hn1 (v, ...) or hn2 (...)
   ```

6. **Inner levels**: The innermost quantifiers (`forall w` in disj1, `forall v` in disj2) use simple `not (guard and not eval)` which `simp only [not_and, Classical.not_not]` handles correctly as `guard -> eval`.

### Backward Direction Detail

For the backward direction body, after `simp only [not_and, Classical.not_not]` + `rintro (hmu_u, htu, hus)`, the goal is:
```
not (not disj1_fo and not disj2_fo)
```

To prove this from `hbody u htu hus hmu_u : disj1_sem or disj2_sem`:
```lean
intro (hn1, hn2)
rcases hbody u htu hus hmu_u with (... | ...)
-- Case disj1_sem: construct disj1_fo, contradicting hn1
-- Case disj2_sem: construct disj2_fo, contradicting hn2
```

This is a standard `intro (hn1, hn2)` proof-by-contradiction pattern.

### stavi_snce: Past Dual

The stavi_snce case is the exact past dual: swap the ordering direction (`t < u < s` becomes `s < u < t`). The proof is structurally identical to stavi_untl. The lift lemmas are symmetric.

### Implementation Estimate

- **Lines of code**: ~130 lines per case (stavi_untl + stavi_snce = ~260 total)
- **Key changes from block comment**:
  1. Add `not_not_and_not` helper (~3 lines)
  2. Replace `rcases hbody_u hguard with ...` with two-step: apply guard, then `not_not_and_not` (forward direction, 2 locations)
  3. Replace `left`/`right` with `intro (hn1, hn2); rcases ...` (backward direction, 1 location)
  4. Replace inner `simp [not_and_or]` with `simp [not_and]` + helper where needed
- **Risk**: Low -- individual pieces validated by LSP testing
- **Complexity**: Medium -- the proof is large but follows a mechanical pattern

## 5. Alternative Approaches

### Alternative A: Use `push_neg` Instead of Manual Negation Handling

`push_neg` is a Mathlib tactic that pushes negations inward. After getting `h : not (not disj1 and not disj2)`, `push_neg at h` would convert it to `not disj1 -> disj2` (equivalent to Or but as implication). This still doesn't give `Or`, but the implication form might be workable with `by_cases`.

### Alternative B: `not_not_and_not` as `@[simp]` Lemma in MonadicFO.lean

Define a reusable simp lemma:
```lean
@[simp] theorem not_not_and_not (a b : Prop) : not (not a and not b) <-> (a or b) := by
  constructor
  . intro h; by_contra hc; push_neg at hc; exact h (And.intro hc.1 hc.2)
  . rintro (ha | hb) (hna, hnb); exact hna ha; exact hnb hb
```

Then use `simp only [not_and, Classical.not_not, not_not_and_not]` which would handle all levels correctly. This is cleaner than the helper-function approach but requires adding to the simp set carefully to avoid loops.

### Alternative C: Use `tauto` for Propositional Matching

After establishing lift iff lemmas and unfolding definitions, `tauto` might close each sub-goal that is purely propositional. Worth trying on each sub-case, but likely too slow on the full 4-level structure with quantifiers.

### Alternative D: Factor as `stavi_untl_fo_eval_iff`

Factor out the correctness proof as a standalone lemma. Does not avoid the core `Or`-vs-negation issue.

### Recommendation

**Use the primary fix** (two-level conversion with local `not_not_and_not` helper). The block comment proof (lines 4196-4506) is structurally correct -- only the disjunction encoding mismatch needs fixing. The helper function approach is the most surgical fix: it changes ~5 lines per case while preserving the 100+ lines of verified proof structure.
