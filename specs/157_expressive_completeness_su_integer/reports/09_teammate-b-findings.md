# Teammate B Findings: Alternative Approaches to the all_past/all_future Circularity

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-18
**Teammate**: B (Alternative Approaches)
**Confidence Level**: HIGH

## Key Findings

### The Root Cause Is Precisely Located

The circularity in Phase 3 (hierarchy theorem) stems from exactly **one design decision**: `is_syntactically_separated` in `Defs.lean:148-151` accepts `all_past` and `all_future` as syntactically separated:

```lean
| .all_past φ => is_U_free φ
| .all_future φ => is_S_free φ
```

Because of this, the 8 elimination cases (Cases 1-4 in `Eliminations.lean`, Cases 5-8 in `DedekindZ.lean`) are free to construct separated witnesses containing `all_past`/`all_future`. And they **do**:

| Location | Witness uses | Reference |
|----------|-------------|-----------|
| `Eliminations.lean:372` (Case 2_gen) | `.all_future (Formula.neg A)` inside S event | G(¬A) abbreviation |
| `Eliminations.lean:415` (Case 2) | `.all_future (Formula.neg A)` inside S event | Same |
| `Eliminations.lean:458-460` (Case 3) | `Formula.neg (.all_past (Formula.neg a))` | ¬H(¬a) abbreviation |
| `Eliminations.lean:515-517` (Case 4) | `Formula.neg (.all_past (Formula.neg a))` | ¬H(¬a) abbreviation |
| `DedekindZ.lean:1154` (Case 5) | `.all_future (Formula.neg A)` | G(¬A) in equivalence |
| `DedekindZ.lean:1878` (Case 8) | `.all_past (Formula.neg ev)` | H(¬ev) in equivalence |

When the hierarchy theorem's `subst_in_separated_separable` (Hierarchy.lean:1261) traverses a separated formula and substitutes `.untl A B` for an atom, the `.all_past` case (line 1276-1279) produces `.all_past c'` where `c'` now contains `.untl A B`. This goes to the callback, which needs to prove `is_separable (.all_past c')` — but expanding `.all_past c'` to `¬S(¬c', ⊤)` doesn't decrease `count_U_subformulas`, creating an induction measure problem.

**Critical observation**: GHR94's Chapter 10.2 works with the language `{S, U, ¬, ∧}` — NO `G` or `H` operators. GHR94's separated equivalents for Cases 1-8 (Lemma 10.2.3, lines 52-118 of the literature file) do NOT use G or H in the final separated formulas. The G and H that appear in the *proof descriptions* of Cases 2-4 are intermediate steps, not part of the result.

## Three Approaches Analyzed

### Approach A: Redefine `is_syntactically_separated` to Exclude `all_past`/`all_future`

**What changes**:
1. `Defs.lean:148-149`: Change to `| .all_past _ => false` and `| .all_future _ => false`
2. Rewrite Cases 2/2_gen, 3, 4, 5, 8 to produce witnesses WITHOUT `all_past`/`all_future`
3. Update helper lemmas that rely on `is_syntactically_separated (.all_past _) = is_U_free _`

**Feasibility analysis**:

Cases 2/2_gen use G(¬A) as a shortcut. GHR94's actual Case 2 equivalent (literature lines 63-66) is:
```
[S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A,B)]
∨ [¬A ∧ ¬B ∧ S(a, ¬A ∧ q)]
∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q)
```
This uses only S, U, atoms, and boolean connectives. No G, no H.

Cases 3/4 use ¬H(¬a) as a shortcut. GHR94's Case 3 equivalent (literature lines 69-73) is:
```
¬( H(¬a)
∨ [S(¬a ∧ ¬q, ¬a ∧ ¬A) ∧ ¬A ∧ (¬U(A,B) ∨ ¬B)]
∨ S(¬A ∧ ¬B ∧ ¬a ∧ S(¬a ∧ ¬q, ¬A ∧ ¬a), ¬a) )
```
Wait — this DOES use H(¬a). But H(¬a) = ∀s<t.¬a(s). On integer time, this is `all_past(¬a)`. However, Case 3's proof says it's obtained by negating and using Case 2. The actual negation ¬S(a, q ∨ U) can be rewritten via Lemma 10.2.2 as `H(¬a) ∨ S(...)`. So the GHR94 equivalent DOES use H(¬a).

**BUT**: H(¬a) = ¬S(a, ⊤) on integer time (Lemma all_past_equiv_neg_snce in TemporalClosure.lean:608). So `¬H(¬a) = ¬¬S(a, ⊤) = S(a, ⊤)` on integer time (using excluded middle). Actually no: `H(¬a) ≡ ¬S(¬¬a, ⊤) ≡ ¬S(a, ⊤)` (where `¬¬a ≡ a` classically). So `¬H(¬a) ≡ S(a, ⊤)`. Wait, let me recalculate:

- `all_past(¬a)` at t means ∀s<t, ¬a(s)
- `¬snce(¬(¬a), ⊤)` at t means ¬∃s<t.(a(s) ∧ ∀r∈(s,t).⊤) = ¬∃s<t.a(s) = ∀s<t.¬a(s)
- So `H(¬a) ≡ ¬S(a, ⊤)`
- And `¬H(¬a) ≡ S(a, ⊤)`

So `S(a, ⊤)` is `¬H(¬a)`. And `S(a, ⊤)` is already syntactically separated (`snce a top`, where a and top are U-free)! This means we can replace `¬(.all_past (Formula.neg a))` with `.snce a Formula.top` and it's equivalent AND syntactically separated WITHOUT `all_past`.

Similarly, `G(¬A) = ¬U(A, ⊤)`. And in the context of Case 2, where `a ∧ G(¬A)` appears in a `.snce` event: `S(a ∧ G(¬A), q)`. We can replace `G(¬A)` with `¬U(A, ⊤)`, making the event `a ∧ ¬U(A, ⊤)`. Then `S(a ∧ ¬U(A, ⊤), q)` is... exactly Case 2 with U' = U(A, ⊤) instead of U(A, B)! So we'd be going in circles if we use Lemma 10.2.2 again.

**Better approach**: Instead of decomposing via 10.2.2, use GHR94's actual formulas directly. For Case 3, GHR94 says S(a, q ∨ U(A,B)) can be separated by "looking at its negation" and using other eliminations. The negation involves H(¬a), which is a problem. But we can substitute: H(¬a) ≡ ¬S(a, ⊤) on integer time. So `H(¬a) ∨ X ≡ ¬S(a, ⊤) ∨ X ≡ S(a, ⊤) → X`. The outer negation gives `¬(S(a,⊤) → X)`. In the final formula, every occurrence of H() or G() can be replaced by its S/U definition.

The replacement is:
- `H(φ)` = `all_past φ` → `¬S(¬φ, ⊤)` = `Formula.neg (.snce (Formula.neg φ) Formula.top)`
- `G(φ)` = `all_future φ` → `¬U(¬φ, ⊤)` = `Formula.neg (.untl (Formula.neg φ) Formula.top)`

These ARE syntactically separated when:
- For `¬S(¬φ, ⊤)`: `Formula.neg (.snce ...)` = `imp (.snce ...) bot`. `is_syntactically_separated (.imp (.snce ...) .bot)` = `is_syntactically_separated (.snce ...) && is_syntactically_separated .bot` = `is_U_free (¬φ) && is_U_free ⊤ && true`. So if φ is U-free and S-free (which it is — a, A are atoms), then ¬φ is also U-free, so this IS separated.
- For `¬U(¬φ, ⊤)`: Similarly, `imp (.untl (¬φ) ⊤) bot`. The `.untl` requires S-free args. `¬φ` is S-free (φ is an atom), and `⊤` is S-free. So this IS separated.

**So the witnesses ARE expressible without `all_past`/`all_future`, using the same underlying S/U definitions.**

**Impact on existing code**:

1. `Defs.lean`: 2 lines changed (all_past/all_future → false)
2. `Eliminations.lean`:
   - `u_free_s_free_imp_separated` (lines 43-57): Remove `.all_past` and `.all_future` cases. They become `| all_past _ => false; contradiction` since the predicate is now false for these.
   - `elim_case_2_gen` (line 372): Replace `.all_future (Formula.neg A)` with `Formula.neg (.untl (Formula.neg A) Formula.top)`. The proof argument changes slightly — instead of using `all_future` semantics directly, use `all_future_equiv_neg_untl`.
   - `elim_case_2` (line 415): Same change.
   - `elim_case_3` (line 458-460): Replace `.all_past (Formula.neg a)` with `Formula.neg (.snce a Formula.top)`. Use `all_past_equiv_neg_snce`.
   - `elim_case_4` (line 515-517): Same change.
   - Separation proofs for these witnesses need updating (minor — replace `simp [is_syntactically_separated, is_U_free, ...]` with the new structure).
3. `DedekindZ.lean`:
   - Line 1154 (Case 5): Replace `.all_future (Formula.neg A)` with `Formula.neg (.untl (Formula.neg A) Formula.top)`.
   - Line 1878 (Case 8): Replace `.all_past (Formula.neg ev)` with `Formula.neg (.snce ev Formula.top)`.
4. `NormalForm.lean` (lines 82-83): Remove `all_past`/`all_future` cases from `u_free_s_free_imp_separated` duplicate.
5. `Hierarchy.lean`:
   - `subst_in_separated_separable` (lines 1276-1285): The `.all_past` and `.all_future` cases DISAPPEAR entirely (since separated formulas can no longer have them). This is the **key benefit**.
   - `snce_depth_zero_single_U_separated` (lines 1451-1452): Cases become impossible.
   - Various helper lemmas: Minor simplifications.
6. `TemporalClosure.lean`:
   - `expanded_jd_zero_imp_separated` (lines 723-724): Cases become impossible (simplified).
   - `restricted_u_free_separated`: Simplified.

**Estimated LOC**: ~200-300 lines of changes across 5-6 files. Most changes are straightforward substitutions. The proof logic remains the same; only the witness formulas change.

**Risk**: MEDIUM. The actual proof arguments in Cases 2-4, 5, 8 need to be re-done with the new witnesses. The semantic equivalences are the same (since `all_past ≡ ¬S(¬_, ⊤)` and `all_future ≡ ¬U(¬_, ⊤)` are already proved in TemporalClosure.lean), but the separation proofs change structure.

### Approach B: `expand_temporal` BEFORE Separation

**What this means**: The hierarchy proves separability for expanded formulas (already: `all_formulas_separable_aux` takes `hexp : has_no_allpast_allfuture φ = true`). The problem is that the callback in the hierarchy receives formulas FROM separated witnesses that may contain `all_past`/`all_future`.

**To make this work**: Cases 1-8 would need to produce witnesses without `all_past`/`all_future`, OR the callback would need to expand the witness before applying the IH. But as documented in the handoff (phase-3-callback-analysis-20260518.md), expansion doesn't preserve `no_S_nested_in_U` or decrease the count measure.

**The key issue**: Even if we expand the callback formula, `expand_temporal(.all_future x)` introduces `.untl` with args `(neg (expand x))` and `top`. If `x` contained `.all_past y`, then `expand x` introduces `.snce`, breaking S-freeness. This creates a cascade that was thoroughly analyzed in the handoff.

**Verdict**: Approach B is essentially equivalent to Approach A but MORE complex, because you're fixing the problem at the callback level instead of at the source. The clean fix is at the source (don't generate `all_past`/`all_future` in witnesses at all).

**Risk**: HIGH. The analysis shows multiple dead ends when trying to handle expansion in the callback.

### Approach C: Two-Tier Separation

**What this means**: Define `is_strongly_separated` (like `is_syntactically_separated` but with `all_past`/`all_future` returning `false`), prove the hierarchy for `is_strongly_separated`, and then bridge to `is_syntactically_separated`.

**Analysis**: This is a strictly more complex version of Approach A. With Approach A, we change the ONE definition and all proofs produce strongly-separated witnesses. With Approach C, we maintain TWO definitions and need bridge lemmas. The only advantage of C is backward compatibility — existing code using `is_syntactically_separated` doesn't break. But since we WANT to change the cases anyway (they need to stop producing `all_past`/`all_future` witnesses), there's no benefit.

**Verdict**: Approach C adds complexity without benefit over Approach A.

**Risk**: LOW risk of correctness issues, HIGH risk of unnecessary complexity.

## Comparison Table

| Criterion | Approach A: Redefine `is_syntactically_separated` | Approach B: Expand in callback | Approach C: Two-tier |
|-----------|---------------------------------------------------|-------------------------------|---------------------|
| **LOC** | ~200-300 | ~400-600 | ~350-500 |
| **Files changed** | 5-6 | 2-3 (but deeper changes) | 6-7 (extra bridge) |
| **Risk** | Medium | High (documented dead ends) | Medium-High |
| **Cleanliness** | Clean — aligns with GHR94's actual language | Patch — works around the real problem | Over-engineered |
| **Effect on hierarchy** | `.all_past`/`.all_future` cases VANISH from `subst_in_separated_separable` | Callback needs complex measure | Same as A but with bridge |
| **GHR94 fidelity** | HIGH — matches GHR94's {S,U} language exactly | MEDIUM | MEDIUM |
| **Backward compat** | Breaks `all_past_separable`/`all_future_separable` axiom usage | Compatible | Compatible |

## Recommended Approach: A (Redefine `is_syntactically_separated`)

**Rationale**:

1. **Eliminates the root cause**: The `.all_past`/`.all_future` cases in `subst_in_separated_separable` simply DISAPPEAR because separated formulas can't have them. No callback circularity.

2. **Matches GHR94**: The original proof uses `{S, U, ¬, ∧}` language only. The formalization's inclusion of `all_past`/`all_future` in separated forms was a convenience that became a trap.

3. **Replacements are semantically trivial**: `all_past φ ≡ ¬S(¬φ, ⊤)` and `all_future φ ≡ ¬U(¬φ, ⊤)` are ALREADY PROVED in `TemporalClosure.lean`. The new witnesses are provably equivalent to the old ones.

4. **Cases 2-4, 5, 8 have straightforward rewrites**: The core semantics arguments are identical. Only the witness formulas change. The separation proofs update to check the new structure.

5. **The `all_past_separable`/`all_future_separable` axioms are being eliminated anyway**: They're 2 of the 9 axioms we're trying to remove. If the hierarchy succeeds, these become `all_formulas_separable _` applications. So breaking their usage is a feature, not a bug.

## Detailed Implementation Sketch (Approach A)

### Step 1: Change `is_syntactically_separated` (2 lines)
```lean
| .all_past _ => false     -- was: is_U_free φ
| .all_future _ => false   -- was: is_S_free φ
```

### Step 2: Update Eliminations.lean (~100-150 LOC changes)

**Case 2/2_gen**: Replace `let psi_l := Formula.snce (Formula.and a (.all_future (Formula.neg A))) q` with:
```lean
let psi_l := Formula.snce (Formula.and a (Formula.neg (.untl (Formula.neg A) Formula.top))) q
```
The separation proof: `.snce` args need `is_U_free`. The event is `a ∧ ¬U(¬A, ⊤)`. `a` is U-free (given). `¬U(¬A, ⊤) = imp (untl (imp A bot) (imp bot bot)) bot`. `is_U_free` of this is `false` because it contains `.untl`. **Problem: the event is NOT U-free!**

Wait — this means the replacement `¬U(¬A, ⊤)` inside a `.snce` event is NOT syntactically separated by the `.snce` check! The original `all_future(¬A)` was accepted because `is_U_free (.all_future (¬A)) = is_U_free (¬A) = true`. But `¬U(¬A, ⊤)` has `.untl` in it, so `is_U_free` is false.

**This means a direct substitution won't work**. The whole point of `all_future` being allowed in separated forms was that it provides a way to express "G(¬A)" without using U. If we remove `all_future` from separated forms, we can't express G(¬A) as a separated formula — because the equivalent `¬U(¬A, ⊤)` is NOT separated (it puts U inside the negation of an S event).

**Correction**: We need to re-examine the GHR94 Case 2 formula. GHR94's actual separated equivalent for Case 2 (lines 63-66) is:
```
[S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A,B)]
∨ [¬A ∧ ¬B ∧ S(a, ¬A ∧ q)]
∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q)
```

In this formula:
- `¬U(A,B)` is at the boolean top level, not under S. It's a negation of a U-formula. In terms of `is_syntactically_separated`, `Formula.neg (.untl A B)` = `.imp (.untl A B) .bot`. This needs `is_syntactically_separated (.untl A B)` = `is_S_free A && is_S_free B` (true since A, B are S-free) AND `is_syntactically_separated .bot` = `true`. So `¬U(A,B)` IS separated.
- All S-terms have U-free args: `S(a, q ∧ ¬A)`, `S(a, ¬A ∧ q)`, `S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q)` — all args are U-free (a, q, A, B are atoms).
- `¬A`, `¬B` are U-free and S-free.

**This IS syntactically separated WITHOUT `all_past`/`all_future`!**

The key insight: GHR94's equivalents DON'T decompose `¬U(A,B)` at all — they leave it as `¬U(A,B)` at the boolean level. The current code's approach of decomposing `¬U(A,B)` via Lemma 10.2.2 into `G(¬A) ∨ U(...)` is what introduces `all_future`. The fix is: **don't decompose `¬U(A,B)`** — use GHR94's direct equivalents instead.

But this means rewriting the PROOFS of Cases 2-4, not just the witnesses. The current proof strategy goes:
1. `¬U(A,B) ↔ G(¬A) ∨ U'` (Lemma 10.2.2)
2. Split: `S(a ∧ G(¬A), q)` and `S(a ∧ U', q)` (Case 1 applied to U')

GHR94's direct proof for Case 2 is different — it's a direct semantic argument producing the three-disjunct formula above. This would be a REWRITE of Cases 2-4, not just swapping `all_future` for `¬U`.

**Revised effort estimate**: Rewriting Cases 2-4 with GHR94's direct formulas requires new semantic proofs. Estimated ~300-500 LOC for Cases 2-4 rewrites (each case is ~100-150 LOC of proof). Cases 5 and 8 in DedekindZ.lean would also need adjustments.

Alternatively, the CURRENT proofs can be preserved with a different decomposition. Instead of `¬U(A,B) ↔ G(¬A) ∨ U'`, we can keep this decomposition BUT produce witnesses where `G(¬A)` is handled differently:

- When the proof reaches `S(a ∧ G(¬A), q)`, instead of constructing this as a separated formula directly, recognize it as equivalent to `S(a, q) ∧ S(a, ¬A ∧ q)` on integer time (since G(¬A) at s means ¬A holds for all t > s, so in particular between s and t). Wait, that's not right either.

Actually `S(a ∧ G(¬A), q)` at t means: ∃s<t such that a(s), G(¬A)(s), and q on (s,t). G(¬A)(s) means ∀r>s, ¬A(r). So for all r in (s,t), ¬A(r). And also ¬A at t, and ¬A for all r>t. So this is equivalent to `S(a, q ∧ ¬A) ∧ all_future(¬A)`. Hmm, still involves `all_future`.

On **integer time** specifically, `G(¬A)(s)` means ¬A holds at s+1, s+2, ... So `S(a ∧ G(¬A), q)` at t means: ∃s<t, a(s), ¬A(s+1), ¬A(s+2), ..., q(s+1), ..., q(t-1). This is `S(a, q ∧ ¬A) ∧ ¬A(t) ∧ G(¬A)(t)`. So we still need G(¬A).

**The conclusion for Approach A is more nuanced**: The witnesses need to follow GHR94's direct three-disjunct structure for Cases 2-4, which DO NOT use G/H. This means new proofs, not just substitutions. The effort is ~400-600 LOC of new proof code for Cases 2-4, plus updates to Cases 5, 8, plus the hierarchy simplification.

### Revised Assessment

The effort for Approach A is higher than initially estimated because:
1. Cases 2-4 need complete proof rewrites using GHR94's direct formulas
2. Cases 5 and 8 use `all_future`/`all_past` in non-trivial ways

However, the payoff is clean: the hierarchy's `.all_past`/`.all_future` cases simply vanish, and the proof structure matches GHR94 exactly.

## Alternative Within Approach A: Minimal Change via `count_allpast_allfuture` Measure

Instead of rewriting Cases 2-4, we could keep the current witnesses but fix the induction in `no_S_nested_in_U_separable_param` to use a lexicographic measure `(count_allpast_allfuture, count_U_subformulas)`:

1. When the callback receives `.all_past c'`, expand to `¬S(¬c', ⊤)` (i.e., `.imp (.snce (Formula.neg c') Formula.top) .bot`). The `count_allpast_allfuture` decreases by 1 (one fewer all_past). The `count_U` may increase, but the first component decreases.
2. The resulting `.snce` enters the `.snce` callback path, which has `no_S_nested_in_U` and the same count_U.
3. When `.all_future c'` appears — but this case is already handled directly in `subst_in_separated_separable` (line 1280-1285) without the callback, so it's fine.

**This approach doesn't require rewriting Cases 2-4 at all.** We only change the induction measure in `no_S_nested_in_U_separable_param` from `count_U_subformulas` to `(count_allpast_allfuture φ, count_U_subformulas φ)` with lexicographic ordering.

However: after expanding `.all_past c'` to `¬S(¬c', ⊤)`, the `.snce (¬c') ⊤` formula needs `no_S_nested_in_U`. Since `c'` has `no_S_nested_in_U` (proved by `subst_U_free_gives_no_S_nested`), `¬c'` also has it. `⊤` trivially has it. So `no_S_nested_in_U (.snce (¬c') ⊤)` holds.

And `has_no_allpast_allfuture`: the expanded form `.imp (.snce (Formula.neg c') Formula.top) .bot` has no `all_past`/`all_future` IF `c'` has none. But `c'` may have `all_past`/`all_future` (from the separated formula). So we may need to recursively expand.

BUT: `count_allpast_allfuture` strictly decreases with each expansion, and it's a natural number, so this is well-founded. The lexicographic measure `(count_allpast_allfuture, count_U_subformulas)` handles both dimensions.

**Wait** — there's a subtlety. After expanding `.all_past c'`, we get `.imp (.snce (Formula.neg c') Formula.top) .bot`. We need `is_separable` of this. By `imp_separable`, we need `is_separable (.snce (Formula.neg c') Formula.top)`. This `.snce` has `no_S_nested_in_U` and `count_allpast_allfuture` ≤ that of the original (since `c'` came from a separated formula, which CAN have `all_past`/`all_future` in it). The `count_allpast_allfuture` of `.snce (¬c') ⊤` = `count_allpast_allfuture(¬c') + 0`. And `c'` = `subst_formula c p (.untl A B)` where `c` was a subformula of the separated ψ. The count in `c'` ≤ count in `c` (substitution doesn't add `all_past`/`all_future` since `.untl A B` has none). And count in `c` ≤ count in `ψ`. So `count_allpast_allfuture` of the callback formula ≤ that of the original separated formula.

But we need it to be STRICTLY LESS than the original formula's count. The original formula going into `no_S_nested_in_U_separable_param` has `has_no_allpast_allfuture = true`, meaning `count_allpast_allfuture = 0`. The callback formula has `count_allpast_allfuture ≥ 0`. So the first component is `0 → possible > 0`. **This means the first component INCREASES, not decreases!**

The issue: `no_S_nested_in_U_separable_param` requires `has_no_allpast_allfuture φ = true` (count = 0). The callback receives formulas with count > 0. Expanding reduces their count, but not below the original's count (which is 0).

**This is the SAME dead end documented in the handoff.** The minimal-change approach within Approach A doesn't work for the same reason.

**Final verdict**: Approach A (full rewrite to use GHR94's direct formulas) is the only clean path. It's more work than initially estimated but eliminates the root cause permanently.

## Estimated Effort by Approach

| Approach | LOC | Risk | Recommendation |
|----------|-----|------|----------------|
| A (full GHR94 rewrite) | 400-600 | Medium | **RECOMMENDED** |
| A (minimal measure fix) | 100-150 | High (dead end, same blocker) | Not viable |
| B (expand in callback) | 400-600 | High (documented dead ends) | Not recommended |
| C (two-tier) | 500-700 | Medium-High | Over-complex |

## References

- GHR94 Chapter 10.2, Lemma 10.2.3 items 2-4 (direct formulas without G/H)
- `TemporalClosure.lean:608-629`: `all_past_equiv_neg_snce`, `all_future_equiv_neg_untl`
- `Hierarchy.lean:1261-1297`: `subst_in_separated_separable` callback mechanism
- `specs/157_expressive_completeness_su_integer/handoffs/phase-3-callback-analysis-20260518.md`: Prior analysis of dead ends
- `specs/157_expressive_completeness_su_integer/reports/10_allpast-allfuture-analysis.md`: Confirmation that separated formulas contain `all_past`/`all_future`
