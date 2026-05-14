# Report: Multi-Relation Architecture — Mathematical Analysis

**Task**: 129 — weak_reflexive_completeness_conservative_extension
**Date**: 2026-05-14
**Type**: Mathematical deep-dive into Path 1 vs Path 2 viability
**Author**: lean-research-agent

---

## 1. Executive Summary

**Path 1 (multi-relation) is the only mathematically correct approach.** The plan's original single-relation conception (Path 2) contains a fatal mathematical error in the G forward direction: it attempts to derive `ψ ∈ y` from `reflCanR x y` and `Gψ ∈ x`, but `reflCanR` is defined via `g_w_content` (which uses `ψ∧Gψ ∈ x`) and this cannot be recovered from `Gψ ∈ x` alone in strict temporal logic. The multi-relation implementation correctly separates the frame preorder (`reflCanR`, needed for Reynolds's structural argument) from the strict temporal relations (`tempR_fwd` via `g_content`, `tempR_bwd` via `h_content`, needed for the truth lemma). The equivalence lemma proposed in report 05 (`tempR_fwd x y ↔ reflCanR x y ∧ y ≠ x`) is a red herring — it is not needed for the approach to work and its truth value is irrelevant to the approach's correctness.

**Confidence: HIGH** — the mathematical analysis is clear-cut and the fatal flaw in Path 2 is demonstrable from the definitions alone.

---

## 2. Precise Mathematical Definitions

### 2.1 Content Sets

Given an MCS `x : ReflCanDomain` (a subtype of all set-maximal consistent sets of TM formulas):

| Set | Definition | Lean type | Meaning |
|-----|-----------|-----------|---------|
| `g_content x` | `{ψ \| G(ψ) ∈ x.val}` | `Set Formula` | Formulas whose strict G is in x |
| `h_content x` | `{ψ \| H(ψ) ∈ x.val}` | `Set Formula` | Formulas whose strict H is in x |
| `g_w_content x` | `{ψ \| ψ ∧ G(ψ) ∈ x.val}` | `Set Formula` | Formulas that are "weakly in the future": both ψ itself and G(ψ) are in x |
| `h_w_content x` | `{ψ \| ψ ∧ H(ψ) ∈ x.val}` | `Set Formula` | Formulas that are "weakly in the past": both ψ itself and H(ψ) are in x |

Key containment: `g_w_content x ⊆ g_content x`. Proof: if `ψ ∧ Gψ ∈ x.val`, then by `rce` (right conjunction elimination), `Gψ ∈ x.val`, so `ψ ∈ g_content x`. This direction is strict — the reverse does NOT hold (see §4).

### 2.2 Accessibility Relations

| Relation | Definition | Lean type | Intuition |
|----------|-----------|-----------|-----------|
| `reflCanR x y` | `g_w_content x ⊆ y.val` | `ReflCanDomain → ReflCanDomain → Prop` | Reflexive frame preorder: y is "weakly in the future" of x |
| `tempR_fwd x y` | `g_content x ⊆ y.val` | `ReflCanDomain → ReflCanDomain → Prop` | Strict temporal future: y is strictly after x |
| `tempR_bwd x y` | `h_content y ⊆ x.val` | `ReflCanDomain → ReflCanDomain → Prop` | Strict temporal past: x is strictly after y |
| `canS5R x y` | `∀φ, □φ ∈ x.val → φ ∈ y.val` | `ReflCanDomain → ReflCanDomain → Prop` | S5 box-accessibility |

**Proved properties**:
- `reflCanR_refl`: `reflCanR x x` — frame preorder is reflexive
- `reflCanR_trans`: `reflCanR x y → reflCanR y z → reflCanR x z` — frame preorder is transitive
- `tempR_fwd_imp_reflCanR`: `tempR_fwd x y → reflCanR x y` — strict future implies weak future

### 2.3 Truth Definition

```lean
def reflCanTruth (x : ReflCanDomain) : Formula → Prop
  | all_future φ => ∀ (y : ReflCanDomain), tempR_fwd x y → reflCanTruth y φ
  | all_past φ   => ∀ (y : ReflCanDomain), tempR_bwd y x → reflCanTruth y φ
  | untl ψ₁ ψ₂  => ∃ y, tempR_fwd x y ∧ reflCanTruth y ψ₁ ∧ (∀ z, tempR_fwd x z → tempR_fwd z y → reflCanTruth z ψ₂)
  | snce ψ₁ ψ₂  => ∃ y, tempR_bwd y x ∧ reflCanTruth y ψ₁ ∧ (∀ z, tempR_bwd z y → tempR_bwd z x → reflCanTruth z ψ₂)
  | box φ        => ∀ y, canS5R x y → reflCanTruth y φ
  -- atom, bot, imp are straightforward
```

Temporal connectives use `tempR_fwd`/`tempR_bwd` DIRECTLY — NOT `reflCanR` with `y ≠ x`.

---

## 3. Inventory of All Sorries

### 3.1 TruthLemma.lean (6 sorries)

| # | Location | Theorem | Type of Sorry | Lines |
|---|----------|---------|---------------|-------|
| 1 | Line 426 | `until_forward_mcs` | Intermediate guard condition | `∀z, tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val` |
| 2 | Line 454 | `until_backward_mcs` | Full theorem body | Counter-witness chain using BX5 self-accumulation |
| 3 | Line 490 | `since_forward_mcs` | Intermediate guard condition | Mirror of #1 for past direction |
| 4 | Line 497 | `since_backward_mcs` | Full theorem body | Mirror of #2 for past direction |
| 5 | Line 551 | `truth_lemma` untl backward | Semantic-to-syntactic step | `reflCanTruth x (untl φ ψ) → untl φ ψ ∈ x.val` |
| 6 | Line 566 | `truth_lemma` snce backward | Semantic-to-syntactic step | Mirror of #5 |

**Already proved (sorry-free)**: atom, bot, imp (all directions), box (both directions), G (both directions), H (both directions), Until forward (existence part), Since forward (existence part).

### 3.2 ReflexiveCanonical.lean (1 sorry)

| # | Location | Theorem | Type of Sorry |
|---|----------|---------|---------------|
| 7 | Line 337 | `canS5R_symm` | S5 symmetry — not needed for discrete completeness |

### 3.3 IntegerModel.lean (1 sorry)

| # | Location | Theorem | Type of Sorry |
|---|----------|---------|---------------|
| 8 | Line 100 | `canonical_model_is_good` | Full Phase 3 integration — requires Phase 2 infrastructure |

### 3.4 NEquivalence.lean (1 sorry)

| # | Location | Theorem | Type of Sorry |
|---|----------|---------|---------------|
| 9 | Line 67 | k-type finiteness or k-equiv definition | Phase 2 monadic FO infrastructure |

Total: **9 sorries**. Of these, 7 are in Phase 1 content (6 in TruthLemma + 1 in ReflexiveCanonical), 1 in Phase 2, 1 in Phase 3.

---

## 4. The Fatal Flaw in Path 2 (Single-Relation)

### 4.1 What the Plan Intended

The plan (03_doets-reynolds-plan.md, Phase 1, line 108) specifies for the G case:

> "Forward: G(psi) in x implies for all y with x R y and y != x, psi in y (by definition of R using g_content, not g_w_content)."

There is a critical internal contradiction in this sentence: R is defined via `g_w_content`, but the forward direction is said to use `g_content`. You cannot use `g_content` in a proof that's supposed to work with R — R doesn't give you access to `g_content`.

### 4.2 Formal Statement of the Problem

Under Path 2, the truth lemma for G forward would need to prove:

**(G-forward-single)** If `Gψ ∈ x.val`, `reflCanR x y` (i.e., `g_w_content x ⊆ y.val`), and `y ≠ x`, then `ψ ∈ y.val`.

But from `Gψ ∈ x.val` alone, we DO NOT get `ψ ∈ g_w_content x`. That would require `ψ ∧ Gψ ∈ x.val`, which requires `ψ ∈ x.val`. But `Gψ ∈ x.val` does NOT imply `ψ ∈ x.val` in strict temporal logic — `G` is not reflexive (there is no axiom `Gψ → ψ` in TM).

Concretely, given only `Gψ ∈ x.val` and `g_w_content x ⊆ y.val`:

- `g_w_content x` contains formulas of the form `χ` where `χ ∧ Gχ ∈ x.val`
- `ψ` itself is not guaranteed to be in `g_w_content x`
- Therefore `g_w_content x ⊆ y.val` gives us NO information about `ψ`

There is no way to connect `Gψ ∈ x` to `ψ ∈ y` through just `g_w_content x ⊆ y.val`. The proof is impossible without additional axioms.

### 4.3 What Path 2 Would Actually Require

For Path 2 to work, one of the following would need to be true:

**(A)** `g_content x ⊆ g_w_content x` — i.e., `Gψ ∈ x` implies `ψ ∧ Gψ ∈ x`. This is equivalent to `Gψ → ψ` being a theorem, which it is NOT. Counterexample: take a model where `ψ` is false at a point x but true at all successors. Then `Gψ` holds at x, but `ψ` does not, so `ψ ∧ Gψ` is not in the MCS at x.

**(B)** The truth lemma does not need to connect `Gψ ∈ x` to the frame relation at all — instead, the G case is proved by a different method. But the inductive structure of the truth lemma requires matching the semantic definition of `reflCanTruth` for `all_future`, which under Path 2 would be:
```
reflCanTruth x (all_future φ) := ∀ y, reflCanR x y ∧ y ≠ x → reflCanTruth y φ
```
And the inductive proof would need `Gψ ∈ x.val` to imply this semantic condition. But as shown above, `reflCanR` doesn't carry information from `g_content`.

**(C)** Replace `reflCanR` with a relation defined via `g_content` instead of `g_w_content`. But then the relation would NOT be reflexive (since `Gψ ∈ x → ψ ∈ x` is not a theorem), losing the key "reflexive canonical model" property needed for Reynolds Theorem 15.

### 4.4 Conclusion on the Equivalence Lemma

The report 05_multi-relation-deviation.md proposed an equivalence lemma:
```
reflCanTruth x (all_future φ) (via tempR_fwd) ↔ ∀y, reflCanR x y ∧ y ≠ x → reflCanTruth y φ
```

This equivalence is irrelevant to the approach's correctness. The multi-relation approach is self-contained — it defines truth via `tempR_fwd` (for strict temporal) and `reflCanR` (for the frame preorder needed by Reynolds). There is no need to prove equivalence with a hypothetical single-relation definition, because that hypothetical definition is itself mathematically broken.

Moreover, the equivalence `tempR_fwd x y ↔ (reflCanR x y ∧ y ≠ x)` does not hold in general:
- **(→)** `tempR_fwd_imp_reflCanR` gives the `reflCanR` part. But `tempR_fwd x y → y ≠ x` is NOT provable: `tempR_fwd x x` (i.e., `g_content x ⊆ x.val`) can hold for some x, though it fails for typical x.
- **(←)** `reflCanR x y ∧ y ≠ x → tempR_fwd x y` is FALSE. Counterexample: take `ψ` with `Gψ ∈ x` but `ψ ∉ x`. Since `ψ ∉ x`, we know `ψ ∉ g_w_content x`. Now take y with `g_w_content x ⊆ y.val` (so `reflCanR x y`) and `y ≠ x`. Since `ψ ∈ g_content x` (from `Gψ ∈ x`) but we have NO guarantee that `g_content x ⊆ y.val`, we cannot conclude `ψ ∈ y.val`. In fact, we can construct y where `g_w_content x ⊆ y.val` holds but `g_content x ⊆ y.val` does NOT — for example, take y to be the MCS x itself (but then `y ≠ x` is violated), or more generally, any MCS that extends `g_w_content x` but not `g_content x`.

### 4.5 The Lindenbaum Extension Problem for Path 2

Even for the G BACKWARD direction, Path 2 has a problem. The backward direction requires:

Given `Gψ ∉ x.val`, construct `y` with `reflCanR x y`, `y ≠ x`, and `ψ ∉ y.val`.

The construction extends `g_content x ∪ {¬ψ}` to an MCS y via Lindenbaum. This gives:
- `g_content x ⊆ y.val` → `ψ ∈ g_content x` would imply `ψ ∈ y.val`, contradiction with `¬ψ ∈ y`
- `g_content x ⊆ y.val` PLUS `tempR_fwd_imp_reflCanR` gives `reflCanR x y` ✓
- `y ≠ x`: This requires `¬(g_content x ∪ {¬ψ} ⊆ x.val)`. Since `g_content x ⊆ x.val` is not generally true (as argued above), we can find a counterexample. However, for the SPECIFIC case where `Gψ ∉ x`, we can use `¬ψ ∈ y` and the fact that... actually, could `y = x`? If `y = x`, then `g_content x ⊆ x.val` and `¬ψ ∈ x`. But `g_content x ⊆ x.val` would mean for all χ with Gχ ∈ x, we have χ ∈ x. This is not provably false (it's a specific property of x). So `y ≠ x` is NOT guaranteed by the Lindenbaum construction alone.

For Path 1 (multi-relation), `y ≠ x` is never needed — the truth lemma for G backward only needs `tempR_fwd x y`, which we get from `g_content x ⊆ y.val` (the result of the Lindenbaum construction). 

---

## 5. Per-Sorry Analysis: Which Path Resolves It?

| Sorry # | Theorem | Path 1 (multi-relation) | Path 2 (single-relation) |
|---------|---------|------------------------|--------------------------|
| 1 | `until_forward_mcs` guard | Same difficulty — needs chain construction, independent of relation choice | Same difficulty |
| 2 | `until_backward_mcs` | Same difficulty — needs BX5 self-accumulation chain porting | Same difficulty |
| 3 | `since_forward_mcs` guard | Same difficulty (mirror) | Same difficulty |
| 4 | `since_backward_mcs` | Same difficulty (mirror) | Same difficulty |
| 5 | `truth_lemma` untl backward | Semantic-to-syntactic over `tempR_fwd` | Would need same over `reflCanR ∧ y≠x` — **harder** (needs extra bridge lemma) |
| 6 | `truth_lemma` snce backward | Semantic-to-syntactic over `tempR_bwd` | Would need same over `reflCanR ∧ y≠x` — **harder** |
| 7 | `canS5R_symm` | Unchanged (not needed) | Unchanged |
| 8 | `canonical_model_is_good` | **Easier**: frame preorder `reflCanR` already exists; truth lemma uses `tempR_fwd` — these are separate, no conflict | **Harder**: truth lemma must work with `reflCanR ∧ y≠x` AND the frame preorder must also be `reflCanR` — conflating the two creates tension |
| 9 | NEquivalence | Unchanged | Unchanged |

**For sorries 5 and 8 specifically, Path 1 is mathematically easier.** For sorries 1-4, both paths face identical difficulty. For sorries 7 and 9, the relation choice is irrelevant.

**No sorry is easier under Path 2.** Several are harder.

---

## 6. Role of `reflCanR` in the Multi-Relation Architecture

A natural question: if the truth lemma never uses `reflCanR` for temporal connectives, what is it for?

### 6.1 Frame Structure for Reynolds

The Reynolds Theorem 15 construction needs a DISCRETE REFLEXIVE PREORDER on the canonical model domain. This preorder defines:
- The linear order of points
- Intervals between points
- The "good/very good" classification over subintervals
- The contemporaneous equivalence ~M

`reflCanR` serves this role. It is reflexive (proved), transitive (proved), and provides the structural backbone for the Z-model extraction.

### 6.2 Bridge from Strict to Weak

The lemma `tempR_fwd_imp_reflCanR` ensures that any point in the strict temporal future is also in the frame preorder future. This means: when the truth lemma says "G(φ) is true at x because φ holds at all tempR_fwd-successors," every such successor is also a reflCanR-successor, so the frame structure encompasses all truth-relevant points.

### 6.3 Why Not Use `reflCanR` + `y ≠ x` for Everything?

Because, as shown in §4, you cannot derive `Gψ ∈ x → ψ ∈ y` from `reflCanR x y` and `y ≠ x` alone. The frame preorder is too weak — it only tracks `g_w_content`, not `g_content`. You need the stronger `tempR_fwd` (= `g_content`-based) relation for the truth lemma to connect G-formula membership to accessibility.

---

## 7. A Note on `g_content x ⊆ g_w_content x`

The question "is `g_content x ⊆ g_w_content x` provable?" is central to understanding why Path 2 fails. This would mean: `Gψ ∈ x → ψ ∈ x` (to get `ψ ∧ Gψ ∈ x`). In strict TM logic:

**This is false.** The temporal logic TM does not include `temp_t: Gψ → ψ` as an axiom. The G operator is strict: `Gψ` means "ψ holds at all STRICT future points," which does not imply ψ holds at the current point.

**Constructive counterexample**: Take a discrete temporal model with two points x and y (strictly ordered x < y). At x, let ψ be false and at y, let ψ be true. Then `Gψ` holds at x (since the only future point y has ψ true), but `ψ` does NOT hold at x. Thus in the canonical model, the MCS at x would contain `Gψ` but not `ψ`.

Therefore `g_content x ⊈ g_w_content x` in general.

---

## 8. Definitive Recommendation

### Path 1 (Multi-Relation) — STRONGLY RECOMMEND

**Mathematical justification**:
1. **Definitions are self-consistent**: Each relation captures exactly one mathematical concept — frame preorder (`reflCanR`), strict temporal future (`tempR_fwd`), strict temporal past (`tempR_bwd`). There is no conflation of distinct concepts.
2. **Truth lemma G forward is trivial**: `Gψ ∈ x → ∀y, tempR_fwd x y → ψ ∈ y` follows directly from `tempR_fwd := g_content x ⊆ y.val`, because `Gψ ∈ x` means `ψ ∈ g_content x`. No extra lemmas needed.
3. **No `y ≠ x` condition needed**: The irreflexivity of `tempR_fwd` (i.e., whether `tempR_fwd x x` holds) is irrelevant — the truth definition quantifies over ALL `tempR_fwd`-successors, and if `tempR_fwd x x` happens to hold for some x, the semantics gracefully handles it.
4. **Frame preorder is cleanly separated**: `reflCanR` is available for the Reynolds structural argument without being conflated with truth-evaluation semantics.
5. **Matches BXCanonical patterns**: The existing Frame.lean already has `g_content`/`h_content` based relations. The multi-relation design reuses this proven infrastructure.

**What it needs** (same as single-relation): close the 6 truth lemma sorries (chain construction infrastructure for Until/Since).

### Path 2 (Single-Relation) — REJECTED

**Mathematical justification for rejection**:
1. **Fatal flaw in G forward direction**: Cannot derive `ψ ∈ y` from `Gψ ∈ x` and `reflCanR x y` — the plan's "by definition of R using g_content, not g_w_content" is a category error (R is defined via g_w_content, not g_content).
2. **Equivalence lemma would be a patch, not a proof**: Proving `tempR_fwd x y ↔ (reflCanR x y ∧ y ≠ x)` would only show that the implementation's `tempR_fwd` is EQUIVALENT to what the plan INTENDED. But the plan's intention was mathematically incoherent — the proof of this equivalence would require showing that `g_content x ⊆ y.val` is equivalent to `(g_w_content x ⊆ y.val) ∧ (y ≠ x)`, which does not hold in general (see §4.4).
3. **Requires additional axioms or lemmas**: To make Path 2 work, you'd need to add `temp_t` as an axiom (making G reflexive, which defeats the purpose of the strict temporal logic) or find a different structural lemma that bridges `g_content` and `g_w_content` without adding axioms — and no such lemma exists.

---

## 9. Confidence Assessment

**Recommendation confidence: HIGH (95%)**

The core argument is structural: `reflCanR` defined via `g_w_content` cannot propagate `g_content` information, which is needed for the G forward direction. This is not a matter of finding the right proof — it's a type-theoretic impossibility given the definitions. No proof exists because the implication is not valid in the underlying logic.

The only way to salvage Path 2 would be to change the definition of `reflCanR` to use `g_content` instead of `g_w_content`, but this would lose reflexivity (breaking the Reynolds construction) and would actually make it identical to `tempR_fwd` — at which point you've reinvented Path 1.

The remaining sorries (Until/Since chain construction) are independently hard in both paths and are the genuine implementation challenge. The relation architecture choice does not affect their difficulty.

---

## 10. Recommendation for Report 05

The report 05_multi-relation-deviation.md recommended Path A as "the safer choice" pragmatically. This analysis shows that Path 1 is not just pragmatically safer — it is **mathematically necessary**. The recommendation to "add an equivalence lemma (~50 lines)" should be dropped: such a lemma is neither provable nor needed. The multi-relation approach is the correct formulation of the mathematical problem; it doesn't need to prove equivalence with a flawed single-relation formulation.

**Action item**: Update report 05 or add a note referencing this analysis.

---

## References

- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` — relation definitions and frame properties
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` — truth definition and truth lemma (partial)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` — `g_content`, `h_content` definitions
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` — MCS closure properties (`all_future_all_future`, etc.)
- `specs/129_weak_reflexive_completeness_conservative_extension/plans/03_doets-reynolds-plan.md` — original plan
- `specs/129_weak_reflexive_completeness_conservative_extension/reports/05_multi-relation-deviation.md` — prior analysis
