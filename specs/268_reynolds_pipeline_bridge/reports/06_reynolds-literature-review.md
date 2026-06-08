# Reynolds 1994 Literature Review: Model Surgery and Alternative Paths

## 1. Reynolds 1994's Actual Proof Technique for Theorem 14

### 1.1 What Theorem 14 Says

Reynolds 1994, Section 7, Theorem 14 (p.129): "Suppose that ~M is a contemporaneous equivalence relation on a Prior structure M. Then the ~M-classes do not end at gaps."

This is the key structural result enabling the completeness proof. After establishing a Burgess-Xu model (Corollary 3, discrete countable Prior structure), Reynolds needs to show that the k-equivalence classes (~M, defined by very_good subintervals) form a gap-free partition, allowing lexicographic sum reassembly into a Z-interval model (Theorem 15, Lemma 16).

### 1.2 The Proof Structure (Lemmas 6-13)

Reynolds' proof of Theorem 14 uses a **seven-step model surgery argument** that critically depends on US expressive completeness over Prior structures (Theorem 5):

**Lemma 6** (Gap-detecting formula R): Given epsilon(x,y) defining ~M, construct the monadic formula rho(x) = "x's class ends in a gap on the right." Reynolds says: "Now by the expressive completeness of U and S there is temporal R true in any Prior structure exactly where rho(x) is." This is **Reynolds Theorem 5** applied to rho.

**Lemma 7** (R-interval structure): Maximal intervals where R holds are open, bounded by elements of M. Proof uses Prior-U applied to R directly, plus **a second application of expressive completeness** to construct the formula B = "the ~M-class we are in now begins with a point satisfying R AND K-(not-R)."

**Lemma 8** (No first/last class): "By expressive completeness, the formula rho(x) AND [x is in the first class of its R-interval] has a temporal equivalent." This is a **third application of expressive completeness**.

**Lemma 9** (Class homogeneity): "Using expressive completeness and epsilon, find B which is true at points only if A occurs somewhere in their ~M-class." Then C = "we are in a class whose left-hand end point also satisfies K-(B)." This involves **two more applications of expressive completeness**. The second statement (elementary equivalence of classes) uses relativization of monadic sentences to a class via epsilon, followed by **yet another application of expressive completeness**.

**Lemmas 10-11** (Bad intervals, formula propagation): Uses "expressive completeness" to find temporal formulas for class-relativized properties. Another application.

**Lemma 12** (Model surgery = truth preservation): Construct N = Q- UNION I UNION Q+ (excising a bad interval except for one representative class I). Prove temporal truth preservation M <-> N by induction on formula structure, with 13 subcases for U(A,B) (7 forward, 6 backward). This is the longest single step.

**Lemma 13** (Contradiction): In N, the class containing I ends at a point (not a gap), so R is false there. But truth preservation says R(t) in N iff R(t) in M, and R is true everywhere in M. Contradiction.

### 1.3 What Expressive Completeness Reynolds Actually Needs

Reynolds uses **Theorem 5** (US expressive completeness over Prior structures, p.123-124) as a black box throughout Lemmas 6-13. The theorem states:

> "The language with U and S is expressively complete for the class of Prior structures."

Reynolds' proof of Theorem 5 itself is elegant and short (4 lines on p.124):
1. By Stavi expressive completeness ({U,S,U',S'} over all linear orders, Theorem 4), it suffices to eliminate U' and S'.
2. U'(A,B) iff false on Prior structures (since B holding up to a gap then failing contradicts Prior-U applied to B).
3. S'(A,B) iff false similarly.
4. So U'(A,B) <-> bot and S'(A,B) <-> bot, reducing {U,S,U',S'} to {U,S}.

**This means Reynolds needs the full Stavi expressive completeness (GHR93 Theorem 9.3.1)** as a prerequisite, but then simplifies it to {U,S} via Prior axioms. There is no shortcut: Reynolds does NOT use EF games directly in the model surgery argument itself, but the Stavi theorem that Reynolds invokes as a black box IS proven via EF games (in GHR93 Chapter 9/11).

### 1.4 How Expressive Completeness Is Used in the Model Surgery

Reynolds applies Theorem 5 in a very specific pattern throughout Lemmas 6-13:

1. **Construct a monadic FO formula phi(x) with one free variable** (using epsilon, quantifiers over the interval structure, etc.)
2. **Apply Theorem 5 to get temporal formula A equivalent to phi on Prior structures**
3. **Apply Prior-UZ (or Prior-SZ) to A** to show A cannot transition TRUE->FALSE at a gap (contradicting the gap hypothesis)

This pattern is used **at least 7 times** across Lemmas 6-13. Each use requires a DIFFERENT monadic formula phi, but each use relies on the SAME Theorem 5.

## 2. What Expressive Completeness Reynolds Actually Needs

### 2.1 Full {U,S} Expressive Completeness? Yes.

Reynolds uses **full {U,S} expressive completeness over Prior structures** (Theorem 5). He needs this for arbitrary monadic formulas with one free variable, not just for some restricted class. The monadic formulas he constructs in Lemmas 6-13 include:

- rho(x) = "x's class ends in a gap on the right" (involves epsilon with existential quantification)
- "x is in the first class of its R-interval" (involves R, epsilon, existential quantification over classes)
- "A occurs somewhere in x's class" (involves epsilon with existential quantification over class members)
- Class-relativized sentences (involves epsilon for quantifier relativization)

These are genuinely complex monadic formulas that cannot be simplified to something weaker than full expressive completeness.

### 2.2 Does He Need Full Stavi/EF Machinery? Indirectly, Yes.

Reynolds' Theorem 5 depends on Theorem 4 (Stavi expressive completeness), which in turn requires either:
- The EF game argument (GHR93 Chapter 9/11), or
- The separation argument (GHR93 Chapter 6/Gabbay's technique)

However, Reynolds treats Theorem 4 as a black box and only applies the easy Theorem 5 reduction. The Lean formalization mirrors this structure exactly.

### 2.3 Restricted Form? No.

There is no restricted form of expressive completeness that would suffice. Reynolds needs expressive completeness for ALL monadic formulas with one free variable, because different steps of Lemmas 6-13 construct different (and progressively more complex) monadic formulas. The formula in Lemma 9 (class homogeneity) involves relativization of arbitrary monadic sentences to an equivalence class, which requires the full expressiveness theorem.

## 3. Comparison: Formalization's Approach vs. Reynolds' Approach

### 3.1 The Formalization Follows Reynolds Faithfully

The Lean formalization in `GoodStructuresModelSurgery.lean` follows Reynolds' proof structure remarkably closely:

| Reynolds Step | Lean Implementation | Sorry Status |
|---|---|---|
| Lemma 6 (gap formula R) | `gap_formula_R`, `right_gap_class_formula` | Sorry-free |
| R holds everywhere (Lemma 7-style) | `h_R_everywhere` (lines 1209-1238) | Sorry-free |
| Invariant formula constant (Lemma 9) | `invariant_formula_constant` (lines 1259-1308) | Sorry-free |
| Class spread (Lemma 9.1) | `class_spread` (lines 1411-1491) | Sorry-free |
| Ordered class spread (Lemma 11) | `ordered_spread_above/below` (lines 1529-1797) | Sorry-free |
| Truth preservation (Lemma 12) | `truth_pres` (lines 1801-1892) | Sorry-free |
| Prior-UZ/SZ on N (Lemma 12) | `h_prior_UZ_N`, `h_prior_SZ_N` (lines 1895-1932) | Sorry-free |
| R on N (Lemma 13) | `h_R_on_N` (lines 1933-1937) | Sorry-free |
| rgcf false on N | `h_rgcf_false_N` (lines 1944-1990) | Sorry-free |
| Contradiction (Theorem 14) | Line 2000 | Sorry-free |

**Key finding: `GoodStructuresModelSurgery.lean` itself is completely sorry-free (0 sorry terms in 2167 lines).** The full Reynolds model surgery argument (Lemmas 6-13, Theorem 14) has been formalized and proved.

### 3.2 Where the Sorry Actually Lives

The sorry chain for `completeness_discrete` enters through a **transitive dependency**:

```
completeness_discrete
  -> countermodel_discrete_reynolds_v2 (ReynoldsBridge.lean, sorry-free)
    -> no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean, sorry-free)
      -> gap_formula_R -> US_expressively_complete_over_prior (PriorExpressiveness.lean, sorry-free)
        -> stavi_expressive_completeness (StaviCompleteness.lean)
          -> nf_characterizable_by_stavi -> nf_2var_existence_characterizable
            -> nf_2var_exist_sf_classical -> nf_exist_sf_backward_guarded (SORRY, line 2805)
            -> nf_2var_from_interval_data (bridge lemma, SORRY, lines 2353, 2435)
```

The sorry sites are:
1. **`nf_exist_sf_backward_guarded`** (StaviCompleteness.lean:2805) -- backward direction of 2-variable NF existence characterization, sorry'd pending the bridge lemma
2. **`nf_2var_from_interval_data`** (StaviCompleteness.lean:2353, 2435) -- the GHR93 bridge lemma (2-variable quantifier depth transfer), sorry'd in both forward and backward directions of the 3-variable zone match

There are also 4 sorries in `Expressiveness/CaseAnalysis.lean` (lines 3403-3417), which appear to be on a separate path (gap detection case analysis) rather than the main completeness chain.

### 3.3 The Formalization Does NOT Over-Engineer

The formalization's use of `US_expressively_complete_over_prior` is exactly what Reynolds requires. The formalization:

1. **Correctly implements Reynolds' Theorem 5** (PriorExpressiveness.lean) as the composition of Stavi completeness + Prior-structure simplification.
2. **Correctly uses Theorem 5 as a black box** in the model surgery, exactly as Reynolds does.
3. **Does not import unnecessary EF game machinery into the model surgery** -- the EF games are encapsulated behind the `stavi_expressive_completeness` interface.

The architecture cleanly separates:
- **EF games layer** (StaviCompleteness.lean): proves {U,S,U',S'} expressive completeness
- **Prior reduction layer** (PriorExpressiveness.lean): reduces to {U,S} on Prior structures
- **Model surgery layer** (GoodStructuresModelSurgery.lean): uses {U,S} expressiveness as a black box

## 4. Whether the Formalization Over-Engineers by Importing Full Stavi/EF Machinery

### 4.1 Short Answer: No

The formalization does NOT over-engineer. Reynolds himself requires Stavi expressive completeness (Theorem 4) as a prerequisite for his Theorem 5, which he then uses ~7 times in the model surgery proof. The formalization mirrors this dependency exactly.

### 4.2 Could the EF Games Be Avoided Entirely?

**No.** Reynolds' Theorem 5 proof (p.124) explicitly invokes Theorem 4 (Stavi completeness). Without Stavi completeness, there is no known way to derive {U,S} expressive completeness over Prior structures. The three known proof routes for Stavi completeness are:

1. **EF games** (GHR93 Chapters 9/11) -- the route taken by the formalization
2. **Separation theorem** (Gabbay's technique, GHR93 Chapter 6) -- equally complex, arguably harder to formalize
3. **Automata-based** -- not described in Reynolds 1994 or GHR93

All three routes are substantial. The formalization's choice of EF games is reasonable and matches the standard reference (GHR93).

### 4.3 Could a Simpler Model Surgery Be Used Instead?

**No.** The model surgery argument IS Reynolds' argument. There is no known simplification. The key insight is that the model surgery proof requires expressive completeness at multiple points (not just once), and each use constructs a different monadic formula. The formalization has successfully implemented the full argument.

## 5. Recommended Path: Follow Reynolds More Closely, or Fix the EF Game Sorry?

### 5.1 Current Status Assessment

The situation is better than the task description suggests:

- **GoodStructuresModelSurgery.lean**: FULLY SORRY-FREE (2167 lines, 0 sorries)
- **PriorExpressiveness.lean**: FULLY SORRY-FREE
- **ReynoldsBridge.lean**: FULLY SORRY-FREE
- **StaviCompleteness.lean**: 3 sorry sites (the GHR93 bridge lemma)
- **CaseAnalysis.lean**: 4 sorry sites (gap detection case analysis, potentially separate path)

The model surgery is DONE. The remaining sorry is in the EF game layer, specifically the **GHR93 bridge lemma** (`nf_2var_from_interval_data`): proving that the 2-variable depth-k NF of (x,t) is determined by the depth-k 1-variable NFs of x and t, their ordering, and the set of depth-k 1-variable NFs realized in the interval between them.

### 5.2 Recommended Path: Fix the EF Game Bridge Lemma

**Recommendation: Fix the GHR93 bridge lemma sorry in StaviCompleteness.lean.**

Rationale:
1. The model surgery is already fully implemented following Reynolds. There is nothing to "follow more closely" -- the formalization already follows Reynolds precisely.
2. The remaining sorry is in the Stavi completeness proof, which is a dependency of Reynolds' Theorem 5.
3. The bridge lemma is a self-contained mathematical statement about EF games and NF types. It does not require architectural changes.
4. The sorry sites are well-localized: two instances of 3-variable zone-match quantifier transfer (lines 2353, 2435) and the backward direction of the guarded existence formula (line 2805, which depends on the bridge lemma).

### 5.3 Specific Tasks for the Bridge Lemma

The `nf_2var_from_interval_data` bridge lemma (StaviCompleteness.lean:2448-2530) needs:

1. **Duplicator strategy construction**: Given that two 2-variable environments (x,t) in M and (x',t') in M' have matching 1-var NFs, ordering, and interval type sets, construct a Duplicator winning strategy for the depth-k EF game.

2. **3-variable zone match**: The sorry sites at lines 2353 and 2435 need "4-var existential transfer at depth j'" -- finding a witness w in the target structure matching w' from the source structure, preserving the 3-variable NF. This requires using `zone_match` to locate the witness in the correct zone (above, below, or between x and t) and then inductively applying the bridge lemma at lower depth.

3. **The backward direction** (line 2805) follows from the bridge lemma once proved: if the guarded StaviFormula holds, extract the Until/Since witness, apply the bridge to get the correct 2-var NF, and conclude.

### 5.4 Alternative: Accept the Sorry as Axiom

If fixing the bridge lemma proves too difficult, the alternative is to:
1. Extract `nf_2var_from_interval_data` as an explicit axiom
2. Document it as "GHR93 Proposition 7 + Lemma 11, accepted as axiom"
3. Mark `completeness_discrete` as depending on this axiom

This would be mathematically defensible (the result is well-established in the literature) but would leave `sorryAx` in the axiom audit.

## 6. Summary of Key Findings

1. **Reynolds 1994 uses FULL {U,S} expressive completeness** (Theorem 5) throughout the model surgery argument (Lemmas 6-13). There is no restricted or simplified form that suffices.

2. **Theorem 5 depends on Stavi completeness** (Theorem 4 / GHR93 Theorem 9.3.1). This is the same EF game machinery the formalization uses. Reynolds treats it as a black box, exactly as the formalization does.

3. **The formalization does NOT over-engineer.** `GoodStructuresModelSurgery.lean` is completely sorry-free (0 sorries in 2167 lines) and faithfully implements Reynolds' Lemmas 6-13 + Theorem 14.

4. **The sorry does NOT enter through the model surgery.** It enters through `US_expressively_complete_over_prior` -> `stavi_expressive_completeness` -> `nf_characterizable_by_stavi` -> the GHR93 bridge lemma (`nf_2var_from_interval_data`) in StaviCompleteness.lean.

5. **The bridge lemma is the sole remaining blocker.** It is a self-contained statement about EF game zone-matching at the 3-variable level, with 3 sorry sites in StaviCompleteness.lean (lines 2353, 2435, 2805).

6. **Doets 1989 provides the k-equivalence framework** (condensation arguments, ordered sums, EF games) that Reynolds uses for Theorem 15. Doets' approach to proving structures are "good" does NOT require expressive completeness -- it uses definable induction and condensation arguments. However, Doets is used for Theorem 15 (the "good -> Z-interval" transfer), NOT for Theorem 14 (the model surgery). Theorem 14 is purely Reynolds' contribution and requires the full expressive completeness.

7. **GHR93 Chapter 12** presents an alternative proof of Stavi completeness using games directly (rather than separation), which is the approach the formalization takes. Chapter 12 also discusses gap hierarchies and gap connectives, but these are not needed for the model surgery argument.
