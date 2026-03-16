# Research Findings: Tense Logic Prior Art (Teammate A)

**Task**: 981 - Remove axiom technical debt from task 979
**Focus**: Tense logic prior art on discrete time completeness proofs
**Session**: sess_1773703227_76434d
**Run**: 002
**Date**: 2026-03-16

---

## Executive Summary

Standard discrete tense logic completeness proofs (Segerberg, Burgess, van Benthem, Goldblatt) handle the covering property through a **constructive method** that assigns immediate successors at odd stages of the model construction. The key insight is that these proofs **construct** the immediate successor relationship directly, rather than proving it holds for an independently defined canonical model. This fundamentally differs from the ProofChecker's approach, which constructs a canonical model first and then tries to prove it has the covering property.

**Confidence Level**: HIGH (85%)

**Key Finding**: The standard approach **avoids the covering lemma problem entirely** by constructing the order so that covering holds by definition.

---

## Key Findings from Literature

### 1. The Segerberg/Verbrugge Constructive Method

The most relevant prior art is the "completeness by construction" method, developed by Segerberg and systematized by Verbrugge and others.

**Source**: [Completeness by construction for tense logics of linear time](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)

**Key quote from search results**:
> "At each odd stage of the completeness proof, an immediate successor and an immediate predecessor is assigned to each point... the associated set of the immediate successor u is constructed for some t in such a way that in the union these points will still be immediate successors."

**Critical insight**: The proof constructs Gamma_u (the MCS for the immediate successor) with a specific formula:
```
Gamma_u = maximal consistent extension of:
  {phi | G(phi) in Gamma_t} ∪ {neg(psi) ∨ neg(G(psi)) | neg(G(psi)) in Gamma_t}
```

The second component `{neg(psi) ∨ neg(G(psi)) | neg(G(psi)) in Gamma_t}` ensures that u is an **immediate** successor - it forces u to witness all existential F-obligations of t while preventing any intermediate from satisfying them.

### 2. Why Standard Proofs Don't Face Our Problem

The standard constructive method differs from ProofChecker's approach in a fundamental way:

| Aspect | Standard Constructive Method | ProofChecker Approach |
|--------|------------------------------|----------------------|
| **Order construction** | Built incrementally at stages | Canonical model defined first |
| **Successor definition** | Constructed explicitly at odd stages | Derived from Lindenbaum extension |
| **Covering property** | Holds by construction | Must be proven as lemma |
| **Which MCS is successor** | Explicitly chosen/constructed | Non-deterministic Lindenbaum choice |

**Key difference**: In the constructive method, the immediate successor is **defined** to be the extension of a specific seed that includes the "blocking formulas" `{neg(psi) ∨ neg(G(psi))}`. This seed is designed so that no intermediate can exist between t and its constructed successor.

In ProofChecker, the forward witness W is constructed via Lindenbaum from `{psi} ∪ g_content(M)`, which does NOT include these blocking formulas. Hence W may not be the immediate successor - other MCSes could lie between M and W.

### 3. The DF Axiom and Covering

The discreteness axiom DF = `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` corresponds to:
> "Each time instant that has a successor has an immediate successor"

**Frame condition**: For all t with ∃s > t, there exists Order.succ(t) which is the least element > t.

The literature establishes that:
1. DF is **sound** on discrete frames (proven in Soundness.lean)
2. DF **corresponds** to the covering property semantically
3. The constructive method builds models that satisfy DF by construction

However, the literature does NOT directly provide a proof that:
> "Given an arbitrary canonical model satisfying DF, covering holds at the MCS level"

This is precisely the gap in ProofChecker.

### 4. The Infinitary Rules Issue

**Source**: [Discrete tense logic with infinitary inference rules](https://link.springer.com/article/10.1007/BF00357842)

An important subtlety: Segerberg's original proof for discrete logic was incomplete because it used the Lindenbaum lemma, which is not directly available with infinitary rules.

**Quote from search results**:
> "Professor Segerberg's original proof idea turned out to be incomplete... because of the infinitary rules involved, immediate access to the Lindenbaum lemma was not available."

This suggests that the standard canonical model approach (which uses Lindenbaum) may have fundamental difficulties with discrete logics. The constructive method was developed partly to address this.

### 5. Mathlib Infrastructure

The Mathlib theorem `orderIsoIntOfLinearSuccPredArch` establishes:

```lean
{ι : Type} → [LinearOrder ι] → [SuccOrder ι] → [PredOrder ι] →
  [IsSuccArchimedean ι] → [NoMaxOrder ι] → [NoMinOrder ι] → [Nonempty ι] →
  ι ≃o ℤ
```

Requirements:
- `LinearOrder` (have via Antisymmetrization)
- `SuccOrder` (have via LocallyFiniteOrder axiom)
- `PredOrder` (have via LocallyFiniteOrder axiom)
- `IsSuccArchimedean` (automatic from LocallyFiniteOrder)
- `NoMaxOrder` (have from seriality)
- `NoMinOrder` (have from seriality)
- `Nonempty` (have from root MCS)

The bottleneck is `LocallyFiniteOrder`, which requires proving `Icc a b` is finite, which requires the covering lemma.

---

## Analysis: Why the Standard Approach Cannot Be Directly Applied

### The Core Tension

ProofChecker's canonical model construction:
1. Enumerates all formulas via `decodeFormulaStaged`
2. Creates forward witnesses for F-obligations as they appear
3. Uses Lindenbaum to extend seeds to MCSes

The problem is **Lindenbaum non-uniqueness**: The Lindenbaum extension of `{psi} ∪ g_content(M)` is not uniquely determined. Multiple MCSes can extend the same seed. The standard constructive method avoids this by:
1. Adding "blocking formulas" to the seed that force a specific extension
2. Explicitly constructing the successor MCS at odd stages
3. Ordering points so covering holds by construction

### Options for ProofChecker

**Option A: Adopt the Constructive Method**

Restructure the staged construction to explicitly assign immediate successors at odd stages, with the blocking formula seed:
```lean
immediate_succ_seed M :=
  g_content M ∪ {Formula.neg psi ∨ Formula.neg (Formula.all_future psi) |
                  Formula.neg (Formula.all_future psi) ∈ M}
```

**Pros**: Matches standard proofs, covering holds by construction
**Cons**: Major restructuring of StagedExecution.lean; different from current approach

**Option B: Prove Covering via DF Membership**

Use the DF axiom membership in MCSes to derive covering. This is the approach attempted in task 979.

**Key gap identified**: DF creates F(H(phi)) obligations in M, but these are existential - they can be witnessed by ANY forward MCS, not specifically the immediate successor. The standard proofs avoid this by constructing (not discovering) the immediate successor.

**Option C: Indirect via Well-Foundedness**

Prove that `Set.Icc a b` is well-founded under the covering relation, hence finite.

**Equivalent to covering**: As noted in research-004, all reformulations reduce to the same underlying problem.

---

## Recommended Approach Based on Prior Art

### Primary Recommendation: Adopt Constructive Method Structure (Option A)

The literature strongly suggests that the right way to prove discrete completeness is to **construct** the model so covering holds, not to prove covering for an arbitrary canonical model.

**Concrete proposal**:

1. **Define `discreteImmediateSuccSeed`**:
```lean
def discreteImmediateSuccSeed (M : Set Formula) : Set Formula :=
  g_content M ∪
  {Formula.or (Formula.neg psi) (Formula.neg (Formula.all_future psi)) |
   Formula.neg (Formula.all_future psi) ∈ M}
```

2. **Prove consistency of this seed** (using DF axiom membership in M)

3. **Define `discreteImmediateSucc M` as Lindenbaum extension of this seed**

4. **Prove covering by construction**: The blocking formulas ensure no intermediate can exist

5. **Instantiate SuccOrder directly** without going through LocallyFiniteOrder

### Secondary Recommendation: Accept Well-Documented Axiom

If Option A proves too invasive (requires restructuring StagedExecution), the axiom should be accepted as well-documented technical debt per proof-debt-policy.md.

The key justification: **The standard literature does not provide a proof of covering for arbitrary canonical models** - it provides constructions where covering holds by design. ProofChecker's approach is non-standard and may require a novel proof not found in the literature.

---

## References

### Primary Sources
- [Completeness by construction for tense logics of linear time](https://festschriften.illc.uva.nl/D65/verbrugge.pdf) - Verbrugge et al.
- [Discrete tense logic with infinitary inference rules](https://link.springer.com/article/10.1007/BF00357842) - Sundholm
- [Temporal Logic (SEP)](https://plato.stanford.edu/entries/logic-temporal/) - Stanford Encyclopedia

### Key Authors and Works
- **Segerberg (1970)**: Original constructive method for tense logic
- **Burgess (1979, 1984)**: Basic tense logic, S/U operator axiomatization
- **van Benthem (1983, 1995)**: Expressibility of temporal frame properties
- **Goldblatt (1992)**: Logics of Time and Computation - canonical models for discrete time

### Mathlib References
- [LinearLocallyFiniteOrder](http://florisvandoorn.com/carleson/docs/Mathlib/Order/SuccPred/LinearLocallyFinite.html)
- [LocallyFiniteOrder.ofFiniteIcc](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Order/Interval/Finset/Defs.html)
- `orderIsoIntOfLinearSuccPredArch` in Mathlib.Order.SuccPred.LinearLocallyFinite

---

## Appendix: Key Quotes from Literature

### On the Constructive Method
> "The logic D is strongly complete with respect to the discrete, successive, strict linear orders. At each odd stage of the completeness proof, an immediate successor and an immediate predecessor is assigned to each point."

### On the Segerberg Issue
> "Professor Segerberg's original proof idea turned out to be incomplete because it used the Lindenbaum lemma, as is usual in canonical model proofs, but because of the infinitary rules involved, immediate access to the Lindenbaum lemma was not available."

### On Frame Conditions
> "The forward-discreteness axiom (DISCR-F): (F⊤ ∧ φ ∧ Hφ) → FHφ captures the condition that each time instant that has a successor has an immediate successor."

---

## Summary

| Aspect | Finding | Confidence |
|--------|---------|------------|
| Standard proofs use constructive method | Yes, covering by construction | HIGH |
| Literature provides covering lemma proof | **No** - proofs construct, not prove | HIGH |
| DF correspondence to covering | Semantic only, not at MCS level | HIGH |
| Restructuring to constructive method | Feasible but invasive | MEDIUM |
| Axiom acceptance | Justified if restructuring rejected | HIGH |

**Bottom line**: The literature suggests ProofChecker's current approach (prove covering for arbitrary canonical model) may be novel and harder than the standard constructive approach. The recommended path forward is either (A) restructure to match the constructive method, or (B) accept the axiom with clear documentation that this is a non-standard approach where no literature proof exists.
