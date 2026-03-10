# Teammate B Findings: Formal Displacements Alternative

**Task**: 956 - Construct D as translation group from syntax
**Session**: sess_1773100541_8069e4
**Run**: 021
**Date**: 2026-03-09
**Focus**: Evaluate the "D as Formal Displacements" approach (research-020 Section 9) as an alternative to the TranslationGroup (order automorphism) approach.

---

## Key Findings

### 1. What Are "Formal Displacements"?

Research-020 Section 9 proposes constructing D as:

> D = Free group on {F, P} / semantic equivalence

where a "formal displacement" is a finite sequence of F-steps (forward) and P-steps (backward), and two sequences are equivalent if they produce the same temporal displacement in ALL models of TM.

**How this differs from automorphisms**: The TranslationGroup approach starts with the canonical timeline T = BidirectionalQuotient and defines D = Additive(T ≃o T). This is a "top-down" construction: build T first, then extract D as its symmetry group. The formal displacements approach is "bottom-up": build D directly from the SYNTAX of temporal operators, then show it acts on any model.

**Algebraic structure**: Formal displacements form a group under concatenation:
- Identity: empty sequence (no displacement)
- Inverse: reverse the sequence and swap F<->P
- Composition: concatenation of sequences

The quotient by semantic equivalence inherits group structure via the standard quotient group construction.

### 2. Can Formal Displacements Be Built From Syntax?

**Yes, in principle.** The construction is:

1. **Generators**: Two generators, corresponding to "one F-step" and "one P-step"
2. **Free group**: `FreeGroup (Fin 2)` or `FreeGroup Bool` in Mathlib
3. **Relations**: The axioms of TM impose equalities between displacement sequences
4. **Quotient**: D = PresentedGroup(relations derived from TM axioms)

This is genuinely "from syntax" -- the generators ARE the temporal operators, and the relations ARE the axioms.

**However**, there is a fundamental problem with specifying the relations. The axioms of TM (temp_4, temp_A, temp_K, temp_linearity, density DN) constrain the temporal ORDER but do not directly impose EQUALITIES between displacement sequences. For example:

- **temp_4** (Gp -> GGp): This says the G-accessibility is transitive. In displacement terms, it constrains the ORDER on displacements (if d >= 0 and e >= 0 then d+e >= 0), not equalities between them.
- **temp_linearity**: Constrains D to be linearly ordered, not equality relations.
- **DN** (Fp -> FFp): Says between any two distinct positive displacements there is another -- a density condition on the ORDER, not an equality.

The axioms constrain the ORDERED GROUP structure of D, not specific relations in the group-theoretic sense (no axiom says "two F-steps equals one F-step" or similar). This means:

**The "semantic equivalence" relation cannot be expressed purely as a set of group relations in `PresentedGroup`.** It requires quantifying over all models, making it a second-order / meta-theoretic definition.

### 3. Detailed Comparison: TranslationGroup vs Formal Displacements

| Aspect | TranslationGroup | Formal Displacements |
|--------|-----------------|---------------------|
| **Carrier** | Additive(T ≃o T), where T = BidirectionalQuotient | FreeGroup({F,P}) / semantic_equiv |
| **From syntax?** | Yes (T is from MCSes, automorphisms are syntactic) | Yes (generators = temporal ops) |
| **AddGroup** | Proven (sorry-free, from RelIso.instGroup) | Would need: group structure on quotient |
| **AddCommGroup** | Needs Holder's theorem (OPEN) | Same issue: needs abelianness proof |
| **LinearOrder** | Needs eval-at-origin injectivity (OPEN) | Needs order definition on quotient (OPEN) |
| **Torsor/Action** | Needs homogeneity (HARD) | Needs: action on T is well-defined and simply transitive (HARD) |
| **DenselyOrdered** | 4 sorries in DenseQuotient.lean (HARD) | Would inherit from the same density difficulties |
| **Mathlib support** | RelIso.instGroup exists | FreeGroup, PresentedGroup, FreeAbelianGroup exist |
| **Effort estimate** | Current: ~280 lines, mostly done | Estimated: 500+ lines of new infrastructure |

### 4. Does the Formal Displacement Approach Avoid the Freeness/Holder Issues?

**No.** The formal displacement approach faces the SAME fundamental obstacles, just reformulated:

#### Holder's Theorem (Commutativity)
- **TranslationGroup**: Need to prove Aut+(T) is abelian when acting freely on a linearly ordered set.
- **Formal Displacements**: Need to prove the quotient group D is abelian. Since the semantic equivalence is defined by "same displacement in all models," and all models of TM have D as an ordered abelian group, the quotient IS abelian. But PROVING this requires essentially the same argument as Holder's theorem: linearly ordered groups with no proper convex subgroups are abelian.

#### Homogeneity (Torsor Property)
- **TranslationGroup**: Need every pair (a, b) in T to have a unique automorphism mapping a to b.
- **Formal Displacements**: Need the action of D on T to be simply transitive. This requires showing that every temporal displacement between MCSes can be realized by a formal displacement sequence. This is essentially the same transitivity/homogeneity requirement.

#### Density
- **TranslationGroup**: Need DenselyOrdered on T (4 sorries).
- **Formal Displacements**: Need DenselyOrdered on D itself (under DN). The density of the formal displacement group inherits from the density of T, so the SAME Lindenbaum collapse issue persists.

**Key insight**: The formal displacement approach REFORMULATES the blockers but does not ELIMINATE them. The mathematical content is identical; only the presentation differs.

### 5. The Bimodal Complication

TM is bimodal: it includes BOTH tense operators (G, H, F, P) AND modal operators (Box, Diamond). The formal displacement approach only addresses the TEMPORAL dimension.

In a TaskFrame, histories are functions `h : D -> World`, and modal operators (Box/Diamond) quantify over histories sharing the same world at the current time. The formal displacement group D is purely temporal -- it does not interact with the modal dimension.

This means:
- Formal displacements only capture TEMPORAL structure
- The modal structure (Box/Diamond, accessibility between histories) is orthogonal
- The formal displacement approach for D is compatible with the bimodal setting but does not simplify it

### 6. Mathlib Infrastructure Assessment

**Available for formal displacement construction**:

| Mathlib Component | Exists? | Relevant? |
|-------------------|---------|-----------|
| `FreeGroup α` | Yes | Carrier type for displacement words |
| `FreeGroup.instGroup` | Yes | Group structure on free group |
| `FreeGroup.freeGroupUnitEquivInt` | Yes | `FreeGroup Unit ≃ Z` (relevant: single generator = Z!) |
| `PresentedGroup rels` | Yes | Quotient by relations |
| `FreeAbelianGroup α` | Yes | `Additive (Abelianization (FreeGroup α))` |
| `FreeAbelianGroup.lift` | Yes | Universal property for abelian quotients |
| `FreeAbelianGroup.addCommGroup` | Yes | Abelian group instance |
| `QuotientGroup.Quotient.group` | Yes | Group structure on quotient |
| `Subgroup.normalClosure` | Yes | Normal closure for relation quotients |

**Critical observation**: `FreeGroup Unit ≃ Z`. A single-generator free group is Z. If we model displacements with a SINGLE generator (one "unit step" with F = +1, P = -1), then D = Z trivially. But this is exactly Strategy E (D = Z), which was rejected by the user as "not from syntax."

For the formal displacement approach to be DIFFERENT from "D = Z," we need MULTIPLE generators or non-trivial relations. But:
- TM does not impose equalities between different displacement magnitudes
- Under DN (density), every positive displacement has another between it and zero
- This means infinitely many generators, or a quotient that collapses the free group

**The formal displacement group with a single generator IS Z.** With density (DN), the group would need to be dense, requiring infinitely many generators or a dense quotient -- but then we need the density proof again.

**Not available in Mathlib**:
- No `LinearOrder` on `FreeGroup` or `FreeAbelianGroup`
- No `IsOrderedAddMonoid` on any free group construction
- No Holder's theorem
- No "ordered presented group" construction
- No infrastructure for ordered quotients of free groups

### 7. A Fundamental Problem: The Semantic Equivalence is Circular

The formal displacement construction defines:

> (w1, w2) ~ (w3, w4) iff they represent the same displacement in ALL models of TM

This definition quantifies over ALL models. But we are trying to BUILD a model (the canonical model). Using "all models" in the definition of D creates a circularity:

1. To define D, we need to know what all models look like
2. To define a model, we need D (as part of the TaskFrame)
3. To know what all models look like, we need completeness (which we're trying to prove)

**Resolution attempts**:
- **Syntactic equivalence**: Replace "same in all models" with "provably equal in TM." But TM has no axiom schema for displacement equality -- its axioms are about formula validity, not displacement identity.
- **Order-theoretic equivalence**: Two displacement sequences are equivalent if they yield the same ordering relationship. But this just means "the net number of F-steps minus P-steps is the same," which gives D = Z again.
- **Operational equivalence**: Two sequences are equivalent if applying them to any MCS yields the same result. This avoids the "all models" quantification but requires defining what "applying a displacement to an MCS" means, which brings us back to canonical_forward_F and canonical_backward_P -- i.e., the BidirectionalFragment infrastructure that already exists.

### 8. The Operational Variant and Its Relationship to TranslationGroup

If we define formal displacements operationally:

> d1 ~ d2 iff for all MCS M in the canonical fragment, applying d1 to M yields the same result as applying d2

Then each equivalence class of formal displacements defines an order-preserving bijection on the fragment (send M to "the result of applying displacement d to M"). This is precisely an ORDER AUTOMORPHISM of the fragment.

**Therefore: the operational formal displacement group IS the TranslationGroup, constructed differently.**

The formal displacement approach, when made precise and non-circular, REDUCES to the TranslationGroup approach. The only difference is presentational:
- TranslationGroup: "D is the group of order automorphisms of T"
- Formal displacements: "D is generated by forward/backward steps, quotiented by operational equivalence on MCSes"

Both produce the same mathematical object.

---

## Comparison Summary

| Criterion | TranslationGroup (Current) | Formal Displacements |
|-----------|---------------------------|---------------------|
| Mathematical content | Aut+(T) | Same (when made precise) |
| Philosophical purity | High (T is syntactic) | High (generators are syntactic) |
| Implementation effort | LOW (280 lines, done) | HIGH (500+ new lines needed) |
| Blockers avoided | None | None |
| New blockers introduced | None | Circularity, ordering on free group |
| Mathlib support | Good (RelIso.instGroup) | Partial (FreeGroup exists, no ordered version) |
| Code reuse | Leverages BidirectionalReachable | Would need new infrastructure |

---

## Evidence

### Codebase References
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` (281 lines, sorry-free): Current construction, D = Additive(T ≃o T)
- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` (700 lines, 4 sorries): Density proof blockers that would persist in ANY approach
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` (888 lines, sorry-free): Fragment infrastructure that formal displacements would also need

### Mathlib References
- `Mathlib.GroupTheory.FreeGroup.Basic`: FreeGroup, instGroup, freeGroupUnitEquivInt
- `Mathlib.GroupTheory.FreeAbelianGroup`: FreeAbelianGroup, addCommGroup, lift (universal property)
- `Mathlib.GroupTheory.PresentedGroup`: PresentedGroup = FreeGroup / normalClosure(rels)
- `Mathlib.Algebra.AddTorsor.Defs`: AddTorsor class definition
- `Mathlib.Order.Antisymmetrization`: Used by BidirectionalQuotient

### Research References
- research-020.md Section 9: Original "Fresh Approach" proposal
- research-020.md Sections 5-6: Strategy comparison table (G through K)
- research-020.md Section 8: Root cause analysis of density blocker

---

## Confidence Level

**HIGH** with justification:

1. The analysis that formal displacements reduce to the TranslationGroup (when made precise) is a mathematical equivalence, not a heuristic judgment.
2. The Mathlib infrastructure assessment is based on direct tool queries (lean_leansearch, lean_loogle, lean_leanfinder, lean_local_search) confirming what exists and what does not.
3. The blocker analysis is grounded in the existing DenseQuotient.lean code (4 specific sorries examined) and the 700-line proof attempt documenting exactly where each approach fails.
4. The single-generator observation (FreeGroup Unit ≃ Z) is a proven Mathlib theorem, not speculation.

---

## Recommendations

### Primary Recommendation: Do NOT pursue the formal displacements approach.

**Rationale**:

1. **Mathematical equivalence**: When made precise and non-circular, formal displacements produce the same group as TranslationGroup. There is no mathematical advantage.

2. **Implementation cost**: The TranslationGroup is already built (281 lines, sorry-free). Formal displacements would require 500+ lines of new infrastructure for the same result.

3. **No blocker avoidance**: The density blocker (4 sorries in DenseQuotient.lean), Holder's theorem requirement, and homogeneity requirement persist identically in both approaches.

4. **Circularity risk**: The "semantic equivalence" definition requires quantifying over all models, creating a circularity that must be resolved -- and every resolution reduces to the existing TranslationGroup.

### Secondary Recommendation: The TranslationGroup IS already "from syntax."

The user's philosophical concern (D should emerge from syntax) is already satisfied by the current construction:
- T = BidirectionalQuotient (from MCSes = sets of formulas)
- D = Additive(T ≃o T) (automorphisms of a syntactic structure)
- No external mathematical object (Q, Z, R) is imported as a primitive

The remaining blockers are MATHEMATICAL (density, Holder's, homogeneity), not PHILOSOPHICAL. The formal displacements approach repackages the same mathematics with more infrastructure overhead and no philosophical advantage.

### Tertiary Recommendation: Focus effort on the density blocker.

Regardless of whether D is constructed as TranslationGroup or formal displacements, the density of the canonical timeline under DN is the root blocker. The 4 sorries in DenseQuotient.lean represent the hard mathematical content. Resolving those would unblock BOTH approaches simultaneously. The most productive path is:

1. Investigate the K-Relational approach from research-020 Section 10 (prove density at MCS level, not quotient level)
2. Or: accept D = Q as a representation target (Strategy K) where Q is DISCOVERED, not imported
3. Or: prove completeness for relational frames first (Strategy J), deferring the TaskFrame assembly

---

## Appendix: Search Queries Used

### Mathlib Lookups
- `lean_leansearch`: "free group on a type quotient by normal subgroup" -> PresentedGroup, FreeGroup, QuotientGroup
- `lean_leansearch`: "free abelian group universal property lift homomorphism" -> FreeAbelianGroup.lift
- `lean_loogle`: "FreeGroup" -> FreeGroup, instGroup, freeGroupUnitEquivInt
- `lean_loogle`: "FreeAbelianGroup" -> FreeAbelianGroup, addCommGroup, of
- `lean_leanfinder`: "free abelian group generated by a set with quotient relations" -> FreeAbelianGroup, PresentedGroup
- `lean_leanfinder`: "presented group with generators and relations quotient of free group" -> PresentedGroup, mk, of, one_of_mem
- `lean_leanfinder`: "Holder theorem order automorphism group of linearly ordered set is abelian" -> No match (not in Mathlib)
- `lean_leanfinder`: "free group on unit type is isomorphic to integers Z" -> freeGroupUnitEquivInt
- `lean_leanfinder`: "order isomorphism group composition automorphism of linear order" -> OrderIso.mulLeft, OrderIso.bijective
- `lean_local_search`: "AddTorsor" -> AddTorsor class in Mathlib.Algebra.AddTorsor.Defs

### Codebase Searches
- Grep "formal.?displacement|FormalDisplacement" -> Only found in research reports (not implemented)
- Grep "free.?group|FreeGroup" in Theories/ -> No hits (not used in codebase)
- Grep "Holder|holder" in *.lean -> References in comments only (TranslationGroup.lean, Boneyard files)
- Grep "sorry" in DenseQuotient.lean -> 4 sorries at lines 347, 349, 351, 698
