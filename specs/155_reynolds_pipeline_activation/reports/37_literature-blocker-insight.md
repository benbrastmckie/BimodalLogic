# Report 37: Literature Insights for nf_2var_existence_characterizable Blocker

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: What does the literature say about closing the sorry at `nf_2var_existence_characterizable`?

---

## 1. Literature Files and Their Relevance

The `literature/` directory contains 28 PDFs and 28 corresponding markdown extractions. Three sources are directly relevant to this blocker:

### Directly Relevant (the core proof)

| File | Relevance |
|------|-----------|
| `Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` | **CRITICAL** -- Section 8 contains the complete proof of Theorem 3 (expressive completeness of U,S,U',S' over all linear time) via EF games. This is the "GHR93" paper cited in the sorry. Contains Proposition 7, Theorem 6, and the four-case proof. |
| `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md` | **CRITICAL** -- Chapter 12.8 presents the same proof in expanded textbook form. Theorem 12.8.15 = Theorem 6, Proposition 12.8.18 = Proposition 7. Cleaner notation, fuller details on all four cases. |
| `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` | **HIGH** -- Chapter 9 establishes that separation = expressive completeness (Theorem 9.3.1, Theorem 9.3.4). Provides the framework that the game proof plugs into. |

### Supporting Context

| File | Relevance |
|------|-----------|
| `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` | **MEDIUM** -- Chapter 10 proves separation for {U,S} over integer and Dedekind-complete time. Demonstrates the *separation-based* approach to expressive completeness (alternative to the game-based approach in Ch 12). Not directly usable for general linear time (needs Stavi connectives there). |
| `Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md` | **LOW** -- Only ToC + introduction extracted; the relevant Section 4 on expressive completeness is not in the markdown. |
| `Venema_2001_Temporal_Logic_Survey.md` | **LOW** -- Survey-level overview, no proof details for the gap case. |

### Not Relevant to This Blocker

The algebraic BAO papers (Venema 1993 Anti-Axioms, de Rijke-Venema 1995, etc.), the completeness-by-construction papers (Verbrugge 2004, Burgess 1982), and the mosaic method paper (Caleiro et al. 2013) address axiomatization and completeness of proof systems, not expressive completeness of temporal formulas.

---

## 2. The Core Argument in the Literature

### What the Sorry Needs

The sorry at line 1865 of `StaviCompleteness.lean` requires:

> For each `sub_nf : NormalForm sig k 2` and parent atom assignment, there exists a `StaviFormula sf` such that `sf` holds at `t` iff there exists `x` such that `nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`.

This is the existence claim: every 2-variable depth-k normal form type can be characterized by a temporal formula.

### What the Literature Proves (Two Approaches)

The literature provides TWO proof strategies for expressive completeness:

**Approach A: Separation (Ch 10, Ch 11)**
- Prove that every formula can be syntactically separated into pure past + pure present + pure future parts.
- Combined with Ch 9's "separation = expressive completeness" theorem, this yields expressive completeness.
- Ch 10 does this for {U,S} over integer time (clean 8-case elimination).
- Ch 11 (not extracted) does this for {U,S,U',S'} over all linear time.
- **Drawback**: Separation proofs are fundamentally about formula rewriting, not about constructing a formula that characterizes a specific model-theoretic property. They don't directly tell you *which* temporal formula characterizes a given NF type.

**Approach B: EF Games (GHR93 paper, Ch 12.8)**
- Prove that if two points satisfy the same temporal formulas of sufficient rank, they satisfy the same monadic first-order formulas of bounded quantifier depth.
- This is done via the "backward game" Theorem 6 / 12.8.15.
- Expressive completeness follows by taking the disjunction of all rank-R temporal type descriptions that are consistent with a given first-order formula.
- **This is the approach the Lean code follows**, and it is the one relevant to the blocker.

### The Key Theorems (Approach B)

From GHR93 Section 8 / Ch 12.8:

**Definition 12.8.13**: For `t` in `M_r`, define `X_t` = conjunction of all temporal formulas of rank <= r that hold at t. For `t < u`, define `X_{(t,u)}` = disjunction of `X_v` for all non-gap points v in (t,u).

**Theorem 12.8.15 (= GHR93 Theorem 6)**: The backward game theorem. If Duplicator has a winning strategy for `G_{1+3n, r+4n}(M, xy; N, x'y')`, then she has a winning strategy for `G_{n,r}(N, x'y'; M, xy)`. Four cases based on whether `a_n` is a point, a left-defined gap, or a right-defined gap.

**Proposition 12.8.18 (= GHR93 Proposition 7)**: The composition theorem. If Duplicator wins interval games `G_{f(n), g(n)}` in both directions for all sub-intervals, she wins the full EF game `G^n`.

**Corollary 12.8.19**: If x and y satisfy the same temporal formulas of rank g(n+1)+1, they satisfy the same first-order formulas of quantifier depth <= n.

**Expressive completeness conclusion**: Given phi(x) of quantifier depth n, take Phi = all temporal formulas of rank 1+g(n+1) that are "atoms" of the Boolean algebra. Let Phi' = those B in Phi such that some linear structure M has a point where both B and phi hold. Then phi is equivalent to the disjunction of Phi'.

---

## 3. The Critical Insight: What the Blocker Actually Needs

### Report 43's Analysis is Correct

The existing report 43 (`backward-direction-bridge.md`) correctly identifies the root cause: the current `nf_exist_sf` uses `sf_top` as the guard formula in Until/Since, which means "there exists x with the right 1-variable type and True holds at all intermediate points." This gives NO information about intermediate point types, so the backward direction (temporal formula truth implies NF satisfaction) cannot be proved.

### What GHR93 Actually Constructs

The GHR93 proof does NOT directly construct "the formula characterizing NF type tau." Instead, it proves that for sufficiently high rank R, the set of rank-R temporal formulas true at a point DETERMINES all first-order properties of bounded quantifier depth. The "formula" that characterizes an NF type is simply the rank-R type description X_t.

This is a NON-CONSTRUCTIVE characterization: given the NF type, you take the disjunction of all rank-R temporal types X that are consistent with that NF type being realized. You don't build a specific Until/Since formula encoding the NF type.

### The Implementation Gap

The Lean code tries to do something MORE SPECIFIC than what GHR93 proves: it tries to BUILD a concrete temporal formula (using Until/Since/Stavi connectives) that characterizes the 2-variable NF. The GHR93 proof only shows EXISTENCE of such a formula (as a Boolean combination of rank-R type atoms).

**Two paths forward**:

**Path 1: Follow GHR93's non-constructive approach**

Use `Classical.choice` to assert the existence of the characterizing formula without constructing it explicitly. The proof would go:
1. By Corollary 12.8.19 (already implicit in the game infrastructure), if two points satisfy the same rank-R temporal formulas, they satisfy the same FO formulas of quantifier depth <= n.
2. "There exists x with 2-var NF = sub_nf relative to t" is a monadic FO formula of bounded quantifier depth.
3. Therefore, there exists a temporal formula of rank R that is equivalent to it.
4. Take this formula as sf (via Classical.choice).

This avoids constructing the formula but requires establishing the correspondence between NF types and FO formulas.

**Path 2: Strengthen `nf_exist_sf` with interval guards (Report 43's recommendation)**

Replace `sf_top` with a guard formula that constrains intermediate point types. The guard would be:
```
B_guard = conjunction over all depth-k 1-var NFs nf_u of:
  (char_k nf_u ↔ "nf_u should appear in the interval according to sub_nf")
```

This is more constructive but requires encoding the 2-variable NF's quantifier structure into the guard formula, which is the substance of the argument.

---

## 4. Concrete Takeaways for Implementation

### The Simplest Approach (Classical Existence, ~100-200 lines)

The sorry has the form `∃ sf, ...`. It can be closed by:

1. Define "the FO formula phi(t) = exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf" (this is implicitly a monadic FO formula of quantifier depth 1, with predicates determined by the IH).

2. Apply the expressive completeness result: every monadic FO formula of quantifier depth n is equivalent to a temporal formula of rank g(n+1)+1 over all linear structures.

3. Classical.choose the temporal formula.

**Challenge**: Step 2 requires having the expressive completeness theorem (Corollary 12.8.19 / GHR93 Corollary 5) formalized in Lean. The game infrastructure (Composition.lean, Decomposition.lean) provides the building blocks, but the full chain (games -> FO formula equivalence -> temporal formula existence) may not be assembled yet.

### The Formula-Fix Approach (Report 43, ~200-300 lines)

If the approach in Report 43 is followed (replacing `sf_top` with an interval guard):

1. Redefine `nf_exist_sf` to use `interval_guard_formula` instead of `sf_top` (~20 lines changed in the definition).

2. The interval guard should constrain which 1-variable types appear at intermediate points, matching what `sub_nf.2` requires.

3. Re-prove `nf_exist_sf_forward` (~50 lines) -- the guard adds proof obligations but they follow from evaluating the IH formulas at intermediate points.

4. Prove `nf_exist_sf_backward` (~100-200 lines) -- the key argument: given the guard constraints on intermediate points + the witness type + the order, reconstruct the 2-variable NF. This uses:
   - `nf_eval_unique` to establish uniqueness
   - `nf_characteristic_satisfies` to establish the IH witness
   - The guard formula to establish intermediate point types match what `sub_nf.2` requires

### Which Literature Passages Map to Which Steps

| Step | Literature Source | Location |
|------|-----------------|----------|
| Interval type determines 2-var NF | GHR93 Theorem 6, Case II proof | Ch 12.8, pp. 800-807 |
| Guard formula constrains interval types | GHR93 Definition 12.8.13 (X_{(t,u)}) | Ch 12.8, p. 644 |
| Composition of sub-interval strategies | GHR93 Proposition 7 / Prop 12.8.18 | Ch 12.8, pp. 690-720 |
| Forward direction: existence -> formula | GHR93 Proposition 6 / Prop 12.8.16 | Ch 12.8, pp. 684-687 |
| Backward direction: formula -> game win | GHR93 Theorem 6 / Thm 12.8.15 | Ch 12.8, pp. 736-847 |

---

## 5. Is There a Simpler Approach?

### The 700-1000 Line Estimate

Report 43 estimates ~270 lines for the formula-fix approach. This is significantly less than 700-1000 lines. The larger estimate may have included game infrastructure that is already formalized in Composition.lean and Decomposition.lean.

### A Potentially Even Simpler Approach

The sorry is about EXISTENCE (`∃ sf, ...`), not about constructing a specific sf. If the project already has:
- `ghr93_game_iff_decomposition` (Decomposition.lean:302) -- game wins iff decomposition agreement
- `ghr93_strategy_compose` (Composition.lean:40) -- composition of strategies
- A way to go from "agreeing on all rank-R temporal formulas" to "same NF type"

Then the existence can be proved by:
1. Show that the rank-R temporal type X_t (as defined in GHR93 Def 12.8.13) determines the NF type
2. For each NF type tau, take the disjunction of all rank-R types X consistent with "exists x with 2-var NF tau"
3. This disjunction IS the characterizing formula sf

This is purely classical/logical and might require fewer lines than the guard-formula approach, at the cost of being less constructive.

### The Key Missing Piece

Regardless of approach, the core lemma needed is:

> **If two points t, t' in linear structures M, N agree on all temporal formulas of rank R (for sufficiently large R depending on k), and x has the same 1-var depth-k NF type in both structures, and the order relationship between t,x matches that between t',x', then the 2-var depth-k NF of (x,t) equals that of (x',t').**

This is a consequence of the EF game theory (Corollary 12.8.19): two-variable NFs of bounded depth are first-order properties of bounded quantifier depth, so they are determined by temporal formulas of sufficiently high rank. The Lean proof infrastructure may need this lemma explicitly.

---

## 6. Summary

1. **The literature fully describes the proof** -- GHR93 Section 8 and Ch 12.8 contain the complete argument.

2. **The blocker is a formula-construction problem** -- the current `nf_exist_sf` uses `sf_top` (trivial guard), which is too weak for the backward direction.

3. **Two fix approaches**: (a) Strengthen `nf_exist_sf` with proper interval guards (~200-300 lines), or (b) Use classical existence via the game-theoretic expressive completeness theorem (~100-200 lines).

4. **Report 43's analysis is correct** and its recommendation (replace `sf_top` with interval guard) is the more constructive approach.

5. **No new infrastructure theorems appear to be needed** -- `nf_eval_unique`, `nf_characteristic_satisfies`, and the game composition/decomposition lemmas in Composition.lean and Decomposition.lean provide the foundations. The gap is assembling these pieces into the backward-direction argument.

6. **Estimated complexity is 200-300 lines**, not 700-1000. The larger estimate likely counted infrastructure already present.
