# Research Report: Task #981 — Literature and Alternative Proof Methods

**Researcher**: Teammate B (Mathematical Logic Specialist)
**Date**: 2026-03-16
**Focus**: Literature review, alternative proof structures, frame conditions
**Confidence Level**: Mixed (see individual findings)

---

## Executive Summary

The key blocker is proving consistency of `discreteImmediateSuccSeed(M)`. The literature reveals:

1. **Frame conditions matter critically**: Segerberg/Verbrugge typically work with **reflexive** KT4/S4 frames where the present is included in "henceforth", not strict K4. This changes the G-inference step fundamentally.

2. **The X (Next) operator** is standard for discrete temporal logic and would make the immediate successor construction more direct, but our logic uses only G/F without X.

3. **The G-inference lifting gap** is the core technical issue: in K4 (strict future), necessitation from hypotheses is restricted, and the "partial lifting" step fails.

4. **Alternative approaches exist** in the literature that avoid this gap entirely.

---

## Key Findings

### Finding 1: Reflexive vs Strict Frame Conditions (HIGH confidence)

**Critical insight**: The classical Segerberg/Verbrugge completeness proofs typically work with **reflexive** temporal frames (KT4/S4 equivalents) where:
- `G(φ)` means "now and always in the future" (reflexive)
- The accessibility relation `R` satisfies `wRw` for all worlds

In contrast, our codebase uses **strict K4** where:
- `G(φ)` means "always in the strict future" (irreflexive)
- `NOT (wRw)` — no world accesses itself

**Why this matters**: The G-inference step "if `L ⊢ φ` then `G(L) ⊢ G(φ)`" works differently:
- In reflexive KT4: `G(φ) → φ` is an axiom (the T axiom), so G-formulas imply their contents
- In strict K4: `G(φ)` says nothing about the current world

**Evidence from SEP**: "The temporal precedence relation is usually required to be a strict partial ordering, that is, an irreflexive, transitive, and hence asymmetric relation. Sometimes, however, it is assumed to be reflexive..."

**Recommendation**: Verify which frame class is actually intended. If the codebase intends to model discrete linear time (Z, <), that is irreflexive. But many standard completeness proofs assume reflexivity.

---

### Finding 2: The DF Axiom Corresponds to Discreteness, Not Covering (MEDIUM-HIGH confidence)

The DF axiom `(F(⊤) ∧ φ ∧ H(φ)) → F(H(φ))` (called DISCR-F in the literature) characterizes **forward discreteness**: every instant with a successor has an immediate successor.

**What DF does**: It ensures the frame has the discreteness property.

**What DF does NOT directly give**: A syntactic proof that the blocking formula seed is consistent. The semantic property (discreteness) doesn't immediately translate to a syntactic proof of seed consistency.

**From Stanford Encyclopedia**: "(DISCR-F): (F⊤ ∧ φ ∧ Hφ) → FHφ" characterizes forward-discreteness in the presence of forward-linearity.

**Implication**: The gap is real — DF characterizes the model class but doesn't directly prove consistency of the construction.

---

### Finding 3: The Next Operator (X) Simplifies Discrete Logic (MEDIUM confidence)

Standard discrete temporal logic (like LTL over ω or Z) typically includes the **Next operator** X where:
- `X(φ)` is true at t iff φ is true at the immediate successor s(t)
- G can be defined from X: `G(φ) ≡ φ ∧ X(G(φ))` (fixed point)

**From Stanford Encyclopedia**: "In forward-discrete, linear temporal models without an end point, where every instant has a unique immediate successor, it is natural to add a new temporal operator X."

**Relevance to our blocker**: With X, the immediate successor construction would be:
- Seed for immediate successor: `{X⁻¹(φ) | X(φ) ∈ M}` (inverse next)
- Consistency follows more directly from M's consistency

**Why we don't have X**: The codebase uses a bimodal G/H logic without explicit X. Adding X would be a significant change but would simplify discrete completeness.

**Recommendation**: Consider whether X can be defined in terms of G/F/H/P for discrete frames, or if the logic should be extended.

---

### Finding 4: The Dum Axiom and Reverse Induction (MEDIUM confidence)

The **Dum axiom** expresses discreteness via reverse temporal induction:
```
◇□p ∧ □(□(p→□p)→□p) → p
```
("if eventually p holds forever, and p is precessive, then p holds now")

**Relevance**: This is an alternative axiomatization of discreteness that captures the "no gaps" property differently. It might suggest an alternative proof structure where we work backward from G-obligations rather than forward.

**From literature**: "Axiom D says that time is discrete, in the sense that a certain principle of 'reverse' temporal induction holds."

**Potential alternative approach**: Use Dum-style reasoning to show that if the seed were inconsistent, we could derive a violation of the reverse induction principle in M.

---

### Finding 5: Bulldozing Construction for Irreflexive Frames (MEDIUM confidence)

For logics like GL (provability logic) that require **irreflexive transitive** frames, the standard approach is **bulldozing**:

1. Build the canonical model (which may have reflexive points)
2. "Bulldoze" reflexive clusters into irreflexive chains by copying and concatenating

**From Segerberg (1971)**: Bulldozing "destroys undesirable states" by inserting a strict partial order into each cluster.

**Relevance**: Our discrete timeline construction might benefit from a similar two-phase approach:
1. First build a model with potentially non-immediate successors
2. Then "refine" it to have only immediate successors

**Downside**: This is a semantic/model-theoretic approach, not a direct syntactic proof of seed consistency.

---

### Finding 6: The Restricted Necessitation Rule (HIGH confidence)

**The deduction theorem issue**: In modal logic, the standard necessitation rule `if ⊢ φ then ⊢ □φ` cannot be applied when φ depends on open hypotheses.

**From Hakli & Negri**: "When a traditional Hilbert-type system is generalized into a system for derivations from assumptions, the necessitation rule has to be modified to restrict its use to cases where the premiss does not depend on assumptions."

**Why this blocks our proof**: The G-inference step wants to go from:
```
L_g ∪ {¬G(ψ)} ⊢ ⊥
```
to:
```
G(L_g) ∪ {¬G(ψ)} ⊢ ⊥
```

But this is applying G-necessitation to formulas that depend on the hypothesis `¬G(ψ)`. The restricted necessitation rule forbids this.

**Implication**: The "partial G-lifting" approach at `DiscreteSuccSeed.lean:316-318` is fundamentally problematic due to the restricted necessitation rule.

---

### Finding 7: The Step-by-Step Construction Builds Consistency Incrementally (MEDIUM-HIGH confidence)

The Verbrugge et al. "completeness by construction" method builds the model **incrementally**:

1. Start with a root MCS
2. At each stage, add immediate successors and predecessors
3. Consistency at each stage is proven by **induction on stage number**

**Key technique**: Rather than proving the full seed is consistent all at once, the construction adds formulas one at a time, maintaining consistency inductively.

**From research materials**: "The frame is constructed in stages such that after stage n there is a linearly ordered set with a maximal consistent set associated to each point satisfying the required properties."

**Potential application**: Instead of proving `g_content(M) ∪ blockingFormulas(M)` is consistent directly, we could:
1. Start with `g_content(M)` (known consistent)
2. Add blocking formulas one at a time
3. Prove each addition preserves consistency

---

### Finding 8: Alternative Seed Construction — Minimal Distinguishing Formula (LOW-MEDIUM confidence)

Rather than blocking formulas, an alternative approach uses **minimal distinguishing formulas**:

For the immediate successor W of M, find φ such that:
- `φ ∈ W` and `φ ∉ M` (distinguishes W from M)
- φ is "minimal" in some ordering

**Potential construction**:
- Seed: `g_content(M) ∪ {δ}` where δ is the minimal distinguishing formula
- The minimality of δ ensures no intermediate K can contain it

**Challenge**: Defining "minimal" in a constructive way and proving the seed is consistent.

---

## Literature Summary

### Segerberg (1970/1971)
- Proved completeness for discrete tense logics
- Used filtration and "bulldozing" to transform models
- Typically assumed **reflexive** frames (KT4 style)
- The bulldozing technique handles irreflexivity as a post-processing step

### Verbrugge et al. (2004) "Completeness by construction for tense logics of linear time"
- Constructive method building models stage-by-stage
- Proved completeness for Lin, P, D, Z, Q, R logics
- D = discrete successive strict linear orders (our target)
- Method assigns immediate successors/predecessors at each stage

### Goldblatt (1992) "Logics of Time and Computation"
- Comprehensive treatment of temporal logic completeness
- Covers discrete (integer), dense (rational), continuous (real) time
- Discusses propositional dynamic logic of regular programs

### Åqvist (1979) "Discrete tense logic with infinitary inference rules"
- Axiomatizes discrete tense logic over Z
- Uses infinitary rules and frame constants
- Handles irreflexivity via "now" operator and frame constants

---

## Alternative Approaches (Prioritized)

### Approach A: Switch to KT4 (Reflexive) Frame Semantics (RECOMMENDED if appropriate)
**Effort**: Low-Medium
**Confidence**: HIGH

If the application allows, interpret G as "now and henceforth" (reflexive). Then:
- `G(φ) ∈ M` implies `φ ∈ M` directly (T axiom)
- The seed consistency proof simplifies significantly
- The G-inference step becomes valid

**Caveat**: This changes the logic's semantics. May not be appropriate for the project's goals.

### Approach B: Stage-by-Stage Incremental Construction
**Effort**: Medium-High
**Confidence**: MEDIUM-HIGH

Follow Verbrugge et al. more closely:
1. Build the discrete timeline stage by stage
2. At each stage, prove consistency of that stage's MCS collection
3. Use induction on stage number
4. The immediate successor is constructed with its properties guaranteed by the stage structure

**Advantage**: Avoids the problematic G-lifting step entirely.
**Disadvantage**: May require significant restructuring of `DiscreteSuccSeed.lean`.

### Approach C: Semantic Argument via Model Construction
**Effort**: Medium
**Confidence**: MEDIUM

Instead of proving seed consistency syntactically:
1. Construct a model M' that extends M
2. Show M' satisfies all seed formulas
3. By soundness, the seed is consistent

**Concrete idea**:
- Let M' be the Kripke model whose world is the canonical model restricted to {M, W} where W is defined semantically as the immediate successor
- Show this 2-world model satisfies the seed

### Approach D: Use Cut Elimination / Proof-Theoretic Approach
**Effort**: High
**Confidence**: LOW-MEDIUM

Work in a sequent calculus rather than Hilbert system:
1. The cut rule allows the substitution of blocking formula ↔ trigger
2. Cut elimination ensures this transformation preserves provability
3. May avoid the necessitation restriction issue

**Disadvantage**: Would require significant proof-theoretic machinery not currently in the codebase.

### Approach E: Accept Axiom with Explicit LocallyFiniteOrder Constraint
**Effort**: Very Low
**Confidence**: HIGH (for pragmatic resolution)

Keep the axiom as documented technical debt:
- Add `LocallyFiniteOrder` as explicit typeclass requirement
- The axiom is mathematically correct for discrete orders
- Document clearly as a gap to be filled in future work

---

## Frame Conditions Analysis

### The Logic's Intended Frame Class

Based on codebase analysis:
- **Frame**: (Z, <) — integers with strict less-than
- **Properties**: Irreflexive, transitive, linear, unbounded both directions, discrete (immediate successors exist)
- **Modal axioms**: K4_t (bimodal K with G4: G(G(φ)) → G(φ))

### Axiom Characterization

| Axiom | Frame Property | Present in Codebase? |
|-------|---------------|---------------------|
| K | Distribution | Yes |
| 4 | Transitivity | Yes (G4) |
| T | Reflexivity | **NO** (strict future) |
| Lin | Linearity | Yes |
| DF | Forward-discreteness | Yes |
| DP | Backward-discreteness | Yes |
| NoMax | No maximum | Yes |
| NoMin | No minimum | Yes |

### Key Observation

The codebase uses **strict K4** without the **T axiom**. This is the source of the G-inference difficulty:
- In KT4: `G(φ) → φ` is valid, so G-formulas are "partially unboxed"
- In K4: `G(φ)` is strictly about the future, creating the gap

---

## Recommendations (Prioritized)

1. **Verify frame class intention** (CRITICAL)
   - Is reflexive or irreflexive intended?
   - If reflexive (KT4) is acceptable, the proof simplifies dramatically

2. **Try incremental seed construction** (if K4 is required)
   - Add blocking formulas one at a time
   - Prove consistency inductively
   - This matches the Verbrugge step-by-step approach

3. **Explore semantic consistency argument**
   - Build a 2-world model witnessing consistency
   - Avoids the syntactic G-lifting issue

4. **As fallback, accept axiom explicitly**
   - Document as frame condition assumption
   - Refactor typeclass to make constraint visible

---

## Appendix: Web Sources Consulted

### Academic References
- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Modal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-modal/)
- [Provability Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-provability/)
- [Completeness by construction for tense logics of linear time](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Discrete tense logic with infinitary inference rules](https://link.springer.com/article/10.1007/BF00357842)

### Technical Resources
- [The discreteness of time (Dum axiom)](https://www.dcs.ed.ac.uk/home/pgh/dummet.html)
- [Does the deduction theorem fail for modal logic?](https://link.springer.com/article/10.1007/s11229-011-9905-9)
- [Canonical models for normal logics](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)

### Book References
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes.
- Segerberg, K. (1970). Modal logics with linear alternative relations. *Theoria*, 36, 301–322.
- Segerberg, K. (1971). An Essay in Classical Modal Logic. Uppsala.

---

## Summary Table

| Finding | Confidence | Impact on Blocker |
|---------|------------|-------------------|
| Reflexive vs strict frames | HIGH | May resolve blocker entirely if KT4 allowed |
| DF ≠ covering proof | MEDIUM-HIGH | Explains why direct approach fails |
| Next operator X | MEDIUM | Alternative approach if logic extended |
| Dum axiom | MEDIUM | Potential reverse induction proof |
| Bulldozing | MEDIUM | Model-theoretic alternative |
| Restricted necessitation | HIGH | Explains why G-lifting fails |
| Stage-by-stage | MEDIUM-HIGH | Most promising alternative |
| Minimal distinguishing | LOW-MEDIUM | Speculative alternative |
