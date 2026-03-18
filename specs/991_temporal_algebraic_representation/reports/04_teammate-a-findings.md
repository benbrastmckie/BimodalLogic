# Research Report: Irreflexive Semantics for Temporal Logic

**Task**: 991 - Temporal Algebraic Representation
**Date**: 2026-03-18
**Focus**: Reflexive vs Strict Semantics Trade-offs

## Key Findings

### 1. Standard Literature Confirms Strict Semantics as Default

The temporal logic literature (Prior, Goldblatt, Blackburn et al., van Benthem) **predominantly uses strict semantics** as the standard approach:

- **Strict semantics (philosophy)**: G phi means "phi will hold at all strictly future instants" (excluding present)
- **Reflexive semantics (computer science)**: Uses reflexive closure, so G phi includes the present

The Stanford Encyclopedia of Philosophy explicitly states: "The temporal precedence relation is usually required to be a strict partial ordering, that is, an irreflexive, transitive, and hence asymmetric relation. However, in computer science, one often uses the reflexive closure."

**Key insight**: The ProofChecker's original reflexive semantics aligned with computer science conventions (LTL-style), but strict semantics is the standard in philosophical/mathematical logic.

### 2. T-Axiom Validity is Tied to Reflexivity

The T-axiom (`G phi -> phi` or `H phi -> phi`) has a precise correspondence:

| Semantics | T-Axiom | Frame Condition |
|-----------|---------|-----------------|
| Reflexive | **Valid** | Requires R to be reflexive |
| Strict    | **Invalid** | R is irreflexive by definition |

Under strict semantics, `G phi` says "phi at all s > t" which does NOT imply "phi at t". The T-axiom is precisely the modal formula that **defines** reflexivity - and irreflexivity cannot be defined by any modal formula.

### 3. Density Axiom Forms are Equivalent on Linear Orders

Both density axiom forms are valid on dense linear orders under strict semantics:

| Form | Statement | Validity |
|------|-----------|----------|
| Universal (Sahlqvist) | `GG phi -> G phi` | Valid iff dense |
| Existential | `F phi -> FF phi` | Valid iff dense |

**Proof sketch for `GG phi -> G phi`**:
- Assume GG phi at t (for all r > t, for all s > r, phi(s))
- Take any s > t. By density, there exists r with t < r < s
- By GG phi, we have G phi at r, so phi(s). Hence G phi at t.

**Key insight**: Under reflexive semantics, `F phi -> FF phi` is trivially valid (witness s = t for intermediate), making density meaningless. Strict semantics makes density a genuine frame condition.

### 4. The Irreflexivity Proof Problem is Real

The current implementation's blocker is well-founded. The naming set proof strategy relies on:

1. Construct naming set `{p, H(not p)} union atomFreeSubset M p`
2. Extend to MCS M'
3. Both `p in M'` and `H(not p) in M'`
4. **Under reflexive semantics**: T-axiom gives `not p in M'`, contradiction

**Under strict semantics**: Step 4 fails. `H(not p) in M'` does NOT imply `not p in M'`.

The seriality axiom `H phi -> P phi` only gives `P(not p) in M'`, which means "there exists some past time where not p held" - not that not p holds now.

### 5. Irreflexivity is Not Modally Definable

This is a fundamental result in modal logic: **no modal formula defines irreflexivity**. This has significant implications:

- Standard canonical model completeness cannot directly prove irreflexivity
- The Gabbay Irreflexivity Rule (IRR) was invented precisely for this
- Under strict semantics, irreflexivity should be "built in" to the definition

**The Gabbay IRR rule**: If `p and H(not p) -> A` is derivable and p doesn't occur in A, then A is derivable. This inference rule (not an axiom) forces irreflexivity.

### 6. Resolution: Irreflexivity Should Be Definitional, Not Derived

Under strict semantics, the canonical relation `CanonicalR M N := g_content M subset N` should be irreflexive by construction:

**Argument**: If `g_content M subset M`, then for any formula `G psi in M`, we would have `psi in M`. Combined with the temp_a axiom (`phi -> G(P phi)`), this creates a tension:
- Take any phi in M
- By temp_a: `G(P phi) in M`
- By closure: `P phi in M`
- `P phi = not H(not phi)`, so `H(not phi) not in M`

The contradiction arises from the interaction of temp_a with the linearity axiom, but the current proof structure doesn't exploit this correctly.

## Recommended Approach

### Option A: Seriality in Base (Recommended)

Add seriality axioms (`G phi -> F phi`, `H phi -> P phi`) to the BASE axiom set rather than discrete extension only. This:

1. Makes the frame unbounded (no first/last element)
2. Combined with temp_a and linearity, provides the irreflexivity derivation
3. Aligns with standard tense logic Kt.Li (linear, unbounded)

**Trade-off**: Changes the logic slightly - base logic now requires unbounded frames.

### Option B: Different Proof Strategy

Instead of the naming set approach, prove irreflexivity via:
1. Assume g_content M subset M
2. Use temp_a to show M is "temporally saturated"
3. Use linearity to derive that M would need to be both before and after itself
4. Contradiction from strict ordering

This is more complex but keeps seriality in the discrete extension.

### Option C: Accept Frame-Theoretic Irreflexivity

Since irreflexivity is not definable, treat it as a frame-theoretic constraint rather than a derivable property. The canonical model construction would:
1. Build the quotient of MCSs
2. Note that the semantic interpretation uses strict < by definition
3. Truth lemma works because G/H quantify strictly

**Trade-off**: This is conceptually clean but may complicate the truth lemma proof.

## Evidence/Examples

### Example: Naming Set Consistency under Strict Semantics

Consider M = some MCS containing p and many other formulas.
Naming set N = {p, H(not p)} union (atomFree(M, p))

Under strict semantics, N is consistent because:
- p says "p is true now"
- H(not p) says "not p at all strictly past times"
- These are NOT contradictory - there can be a "first time" where p becomes true

The MCS extension M' of N satisfies both p in M' and H(not p) in M'.
To get a contradiction, we need seriality: H(not p) -> P(not p), giving P(not p) in M'.
But P(not p) = not H(not(not p)) = not H(p).
So H(p) not in M'. This still doesn't give not p in M' directly.

### Counter-Example: Why the Current Proof Fails

The current proof assumes:
```
H(not p) in M' --> not p in M'    (via T-axiom)
```

But under strict semantics, we can only get:
```
H(not p) in M' AND seriality --> P(not p) in M'
```

P(not p) means "not p at some past time", not "not p now".

## Confidence Level

**High confidence** in the analysis of the problem and the literature review.

**Medium confidence** in the recommended solutions - Option A (seriality in base) appears cleanest but changes the logic. Option B requires developing a new proof strategy. Option C is semantically correct but may have implementation challenges.

## References

### Primary Sources
- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/) - Comprehensive overview distinguishing strict vs reflexive semantics
- [Frame Definability (Open Logic Project)](https://builds.openlogicproject.org/content/normal-modal-logic/frame-definability/frame-definability.pdf) - Irreflexivity non-definability
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes.
- van Benthem, J. (1983). *The Logic of Time*. Reidel.
- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*. Oxford University Press.
- Burgess, J.P. (1979). "Logic and time". *Journal of Symbolic Logic*, 44: 566-582.

### Secondary Sources
- [Temporal Logic (Wikipedia)](https://en.wikipedia.org/wiki/Temporal_logic) - Overview of operator semantics
- [Completeness by construction for tense logics](https://festschriften.illc.uva.nl/D65/verbrugge.pdf) - Kt completeness
- [Canonical models slides (ICL)](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf) - Canonical model techniques

## Summary

The refactoring to strict semantics is **mathematically correct and standard**, but the irreflexivity proof requires rethinking. The claim in research-003 that irreflexivity becomes "nearly definitional" is **partially correct in spirit but technically incomplete** - the proof still requires either:
1. Adding seriality to base axioms, or
2. A different proof strategy exploiting temp_a and linearity directly, or
3. Treating irreflexivity as a frame-theoretic definition rather than a derived property

The recommended path is **Option A** (seriality in base) as it is the simplest and aligns with standard tense logic over unbounded linear time.
