# Teammate B Findings: Reflexive Temporal Semantics in Published Proofs

**Task**: 83 - Close Restricted Coherence Sorries
**Round**: 31
**Focus**: Literature confirmation of temporal semantics conventions
**Date**: 2026-04-07

## Executive Summary

Published proofs use **consistent semantics** -- either all-reflexive or all-strict -- never mixed. The Burgess-Xu axiom system (the standard for Until/Since completeness) uses **all-reflexive** semantics: G, H, U, S all include the present moment. This project's mixed semantics (reflexive G/H, strict U/S) has no precedent in the literature and is the root cause of the `F_until_equiv` unsoundness.

## 1. Burgess (1982a, 1984) -- "Axioms for Tense Logic I: Since and Until" / "Basic Tense Logic"

### Publication Details
- **1982a**: "Axioms for Tense Logic I: 'Since' and 'Until'", Notre Dame Journal of Formal Logic 23(4), pp. 367-374.
- **1984**: "Basic Tense Logic", in Handbook of Philosophical Logic Vol. II (eds. Gabbay & Guenthner), Synthese Library 165, pp. 89-133.

### Semantics Convention: ALL REFLEXIVE

Burgess works over **reflexive linear orderings**. The SEP (Stanford Encyclopedia of Philosophy) explicitly states:

> "A complete axiomatic system for the Since-Until logic on the class of all **reflexive** linear orderings was provided by Burgess (1982a) and further simplified by Xu (1988)."

The Burgess-Xu axiom system includes **G(phi) -> phi** as its first axiom schema. This axiom is ONLY valid when G is reflexive (quantifies over s >= t, including s = t). Under strict G (s > t), this axiom would be invalid.

### Operators Covered
- **G, H**: Reflexive (G quantifies over s >= t, H over s <= t)
- **U, S**: Reflexive (U witness s >= t, S witness s <= t)
- **F, P**: Defined as duals: F(phi) = ~G(~phi), P(phi) = ~H(~phi)

### Complete Axiom System (Burgess-Xu, 7 schemata + duals)
1. G(phi) -> phi
2. G(phi -> psi) -> (phi U chi) -> (psi U chi)
3. G(phi -> psi) -> (chi U phi) -> (chi U psi)
4. phi & (chi U psi) -> chi U (psi & (chi S phi))
5. (phi U psi) -> ((phi & (phi U psi)) U psi)
6. phi U (phi & (phi U psi)) -> phi U psi
7. (phi U psi) & (chi U theta) -> ((phi & chi) U (psi & theta)) v ((phi & chi) U (psi & chi)) v ((phi & chi) U (phi & theta))

Plus mirror images (swapping G/H and U/S) and inference rules NEC_G, NEC_H.

### Frame Class
Completeness proved for: all reflexive linear orderings. Extensions by Venema (1993) and Reynolds (1994, 1996) handle strict orderings and specific classes (discrete, well-orderings, natural numbers).

### F-Until Relationship
Under reflexive Until: F(phi) = ~G(~phi) is equivalent to T U phi. This follows because:
- F(phi) at t means: exists s >= t such that phi(s)
- (T U phi) at t means: exists s >= t such that phi(s) and for all r in [t,s), T(r)
- The guard condition is trivially satisfied (T is always true)
- So both reduce to: exists s >= t, phi(s)

**This equivalence holds trivially under all-reflexive semantics.** It FAILS under mixed semantics (reflexive F, strict U).

### Does Burgess Have Until/Since?
**Yes.** The 1982a paper is specifically about axiomatizing the language with Until and Since. Burgess proves completeness for languages with {G, H, U, S} (and derived F, P).

## 2. Gabbay, Hodkinson, Reynolds (GHR 1994)

### Publication Details
- "Temporal Logic: Mathematical Foundations and Computational Aspects, Vol. 1", Oxford University Press, 1994.
- Also: Gabbay & Hodkinson (1990), "An Axiomatization of the Temporal Logic with Until and Since over the Real Numbers", J. Logic and Computation 1(2), pp. 229-259.

### Semantics Convention: STRICT (philosophical tradition)

The SEP states that GHR 1994 works within the philosophical tradition:

> "These are the 'strict' versions of S and U, prevalent in philosophy."

The strict definitions from the SEP (which GHR follows):
- **Until**: M, t |= phi U psi iff exists s such that t < s, M,s |= psi, and for all u with t < u < s, M,u |= phi
- **Since**: M, t |= phi S psi iff exists s such that s < t, M,s |= psi, and for all u with s < u < t, M,u |= phi

Under strict semantics, **all operators are strict consistently**:
- G(phi) at t: for all s > t, phi(s) -- does NOT include present
- H(phi) at t: for all s < t, phi(s) -- does NOT include present
- F(phi) at t: exists s > t, phi(s) -- strictly future
- P(phi) at t: exists s < t, phi(s) -- strictly past

**G(phi) -> phi is NOT an axiom** under strict semantics. Instead, this is replaced by frame-dependent axioms.

### Quasimodel Construction
The quasimodel approach constructs a temporal model by:
1. Defining "types" (maximal consistent sets of subformulas)
2. Building a directed graph of types respecting temporal constraints
3. "Unraveling" the graph into a linear order that satisfies all eventualities

F-resolution in the quasimodel works by ensuring every unfulfilled F-eventuality is eventually witnessed. Under strict semantics, F(psi) requires a strictly future witness, and U(phi, psi) also requires a strictly future witness -- these are **compatible** because both use the same strict convention.

### Key Insight for This Project
GHR's completeness proof works because **all temporal operators use the same strictness convention**. The quasimodel's F-resolution step matches the semantics of Until exactly because both use strict future witnesses. If F were reflexive while Until were strict, the quasimodel construction would have exactly the gap this project discovered.

## 3. Other Sources and the Standard Convention

### Kamp (1968)
Kamp's original thesis used **strict** semantics. The SEP states:
> "Hans Kamp (1968) proved that every temporal operator... is expressible in terms of S^s and U^s."

The superscript "s" denotes "strict". Kamp's theorem is specifically about strict Until and Since.

### Venema (1993) -- "Completeness via Completeness"
Extended the Burgess axiomatization to **strict** linear orderings. Added axioms like F^s(T) -> (bot U^s T) to connect strict F with strict Until on discrete orders.

### Computer Science Convention (LTL)
Wikipedia's LTL article defines Until with **reflexive** semantics:
> "there exists i >= 0 such that w_i |= psi and for all 0 <= k < i, w_k |= phi"

Here i >= 0 means the witness can be the current state. F, G are also reflexive. This is the **all-reflexive** convention, consistent within itself.

### SEP Summary
> "In computer science, usually reflexive versions of the semantics clauses are considered."

The two standard traditions are:
1. **Philosophy**: All strict (Kamp, GHR, Venema)
2. **Computer science**: All reflexive (LTL, Burgess-Xu)

**No published source uses mixed semantics.**

### Prior's Original Tense Logic
Prior used strict G and H (quantifying over strictly future/past times). Under strict G:
- G(phi) -> phi is NOT valid
- This is why Prior's minimal tense logic K_t does not include the T-axiom

## 4. The Two Traditions Compared

| Feature | All-Reflexive (CS/Burgess) | All-Strict (Phil/GHR/Kamp) |
|---------|---------------------------|----------------------------|
| G(phi) at t | for all s >= t, phi(s) | for all s > t, phi(s) |
| H(phi) at t | for all s <= t, phi(s) | for all s < t, phi(s) |
| F(phi) at t | exists s >= t, phi(s) | exists s > t, phi(s) |
| P(phi) at t | exists s < t, phi(s) | exists s < t, phi(s) |
| phi U psi at t | exists s >= t, psi(s) & ... | exists s > t, psi(s) & ... |
| phi S psi at t | exists s <= t, psi(s) & ... | exists s < t, psi(s) & ... |
| G(phi) -> phi | VALID (axiom BX1) | NOT VALID |
| F(phi) <-> T U phi | VALID (trivially) | VALID (trivially) |
| X(phi) = bot U phi | BROKEN (= phi) | VALID (on discrete orders) |
| Mixed semantics | N/A | N/A |

## 5. The Next Operator Problem Under Reflexive Until

This is the critical obstacle to switching to all-reflexive semantics.

### The Problem
Under reflexive Until: X(phi) := bot U phi
- Means: exists s >= t, phi(s) and for all r in [t,s), bot(r)
- When s = t: interval [t,t) is empty, so guard is vacuously true. Result: phi(t).
- So X(phi) reduces to phi -- **the Next operator becomes trivial**.

### How Published Proofs Handle This

The SEP explicitly addresses this:

> "On irreflexive, forward-discrete, linear temporal orders without end point, S and U also allow for a definition of the Next Time operator X: X(phi) := bot U phi. **This definition fails on reflexive temporal orders.**"

Published proofs handle Next in one of three ways:

1. **Strict semantics (GHR, Kamp)**: X = bot U phi works perfectly because Until is strict. bot U phi means: exists s > t, phi(s), and for all r in (t,s), bot. On discrete orders, the only such s is t+1, so X(phi) = phi(t+1).

2. **Reflexive semantics without Next (Burgess)**: Burgess's system does not include a Next operator. The language is {G, H, U, S} only. On dense/continuous orders (like R), there IS no "next moment", so Next is meaningless anyway.

3. **Reflexive semantics with separate Next (CS/LTL)**: In LTL on discrete time (omega-words), Next is a **primitive** operator, not derived from Until. It is given its own semantic clause: X(phi) at position i holds iff phi at position i+1. Until is reflexive but Next is independently defined.

### Implication for This Project
If the project uses reflexive Until, it CANNOT define Next as bot U phi. If Next is needed, it must be:
- A primitive formula constructor with its own semantic clause, OR
- The project must use strict Until (where the definition works), OR
- The project must work on dense/continuous time where Next is not needed

## 6. What If All Operators Were Strict?

Under all-strict semantics:
- G(phi) -> phi becomes INVALID -- must be REMOVED as an axiom
- The current axioms `temp_t_future` and `temp_t_past` would need to be dropped
- F(phi) <-> T U phi holds (both strict)
- X(phi) = bot U phi works on discrete orders
- The `F_until_equiv` sorry disappears

This is exactly what the existing report 11 (strict-refactor-specification.md) proposes. The strict refactor is well-supported by the literature (GHR 1994, Kamp 1968, Venema 1993).

### What Changes
- Remove: G(phi) -> phi (temp_t_future), H(phi) -> phi (temp_t_past)
- Add: Explicit "phi -> G(P(phi))" and similar interaction axioms
- The T-axiom for modality (box(phi) -> phi) remains -- it's a modal axiom, not temporal
- All temporal operators become consistently strict

### Frame Class Considerations
Under strict semantics on Z (integers with <):
- G, H are strict (exclude present)
- U, S are strict (exclude present)
- F(phi) = ~G(~phi) = exists s > t, phi(s)
- Seriality axioms G(phi) -> F(phi) remain valid (Z has no maximum/minimum)
- X(phi) = bot U phi = phi(t+1) works correctly

## 7. Is There ANY Published Proof Using Mixed Semantics?

**No.** After extensive search, I found no published proof, axiom system, completeness result, or standard reference that uses mixed semantics (reflexive G/H with strict U/S). Every source either:
- Uses all-reflexive (Burgess-Xu, LTL, CS tradition)
- Uses all-strict (Kamp, GHR, Venema, philosophical tradition)
- Explicitly discusses the translation between the two conventions

The mixed semantics in this project appears to be an implementation artifact, not a deliberate design choice grounded in any published framework.

## 8. Concrete Recommendation

**Switch to all-strict semantics** (the GHR/Kamp convention). Reasons:

1. **Fixes F_until_equiv**: F(psi) -> T U psi becomes valid because both F and U use strict future witnesses.
2. **Preserves Next operator**: X(phi) = bot U phi continues to work correctly.
3. **Well-supported by literature**: GHR 1994 proves completeness using exactly this convention.
4. **Report 11 already specifies the refactor**: The strict-refactor-specification.md has a complete 33-axiom system ready for implementation.
5. **Minimal disruption**: Only 2 axioms removed (temp_t_future, temp_t_past), 3 added, 6 replaced.
6. **Avoids reflexive-Until Next problem**: No need to make Next a primitive or restructure the formula type.

The alternative (all-reflexive) would require:
- Changing Truth.lean Until/Since from `t < s` to `t <= s`
- Making Next a primitive formula constructor (breaking the current formula inductive type)
- Reproving all existing Until/Since theorems with the new semantics
- Significantly more disruption for no clear benefit

**The strict convention is the right choice for this project.**

## Sources

- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Burgess-Xu Axiomatic System (SEP Supplement)](https://plato.stanford.edu/entries/logic-temporal/burgess-xu.html)
- [Linear Temporal Logic (Wikipedia)](https://en.wikipedia.org/wiki/Linear_temporal_logic)
- [Burgess 1982a - Notre Dame J. Formal Logic](https://projecteuclid.org/euclid.ndjfl/1093870149)
- [Burgess 1984 - Basic Tense Logic (Springer)](https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2)
- [Gabbay & Hodkinson 1990 - J. Logic and Computation](https://academic.oup.com/logcom/article-abstract/1/2/229/1267137)
- [GHR 1994 - Oxford University Press](https://global.oup.com/academic/product/temporal-logic-9780198537694)
- [Venema 1993 - Completeness via Completeness](https://link.springer.com/chapter/10.1007/978-94-015-8242-1_12)
- [Kamp 1968 Thesis](https://www.ims.uni-stuttgart.de/archiv/kamp/files/1968.kamp.thesis.pdf)
- [Hodkinson & Reynolds - Separation Past Present Future](https://www.doc.ic.ac.uk/~imh/papers/sep.pdf)
