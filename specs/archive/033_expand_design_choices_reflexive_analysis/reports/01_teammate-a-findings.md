# Research Report: Teammate A — Expressive Power and Frame Constraints

**Task**: 33 — Expand design-choices section with reflexive vs irreflexive semantics analysis
**Session**: sess_1774212234_48e1ac
**Date**: 2026-03-22
**Focus Area**: Expressive power differences and frame constraints between reflexive (≤) and
irreflexive (<) temporal semantics for G and H operators

---

## Key Findings

### Finding 1: Irreflexivity Is Not Modally Definable

The single most important result for understanding the expressive-power asymmetry between the
two semantics families is the **undefinability of irreflexivity**. As established by Blackburn,
de Rijke, and Venema (*Modal Logic*, Cambridge, 2001), no modal formula holds in exactly those
frames where the accessibility relation is irreflexive (¬Rww for all w). The proof proceeds by
constructing two bisimilar states — one in a reflexive frame, one in an irreflexive frame — and
noting that bisimulation-invariant languages (including all basic modal and tense languages)
cannot distinguish them.

**Consequence for TM**: The irreflexivity of the strict temporal order cannot be stated as a
tense-formula axiom. Under strict semantics, the proof system cannot "see" irreflexivity; it
must be handled by a meta-rule (Gabbay IRR rule, 1981) or an axiom declaration
(`canonicalR_irreflexive_axiom`). This is not a practical inconvenience but a fundamental
logical limitation.

### Finding 2: The Frame Class Collapse Under Reflexive Semantics

Under reflexive semantics (G quantifies over s ≥ t, H over s ≤ t), four axioms that are
genuinely non-trivial under strict semantics become provable on *every* reflexive transitive
linear order:

| Axiom | Strict semantics: requires | Reflexive semantics: trivially valid because |
|-------|---------------------------|---------------------------------------------|
| DN: `GGφ → Gφ` | DenselyOrdered | Take r = t in ∀ s ≥ t, ∀ r ≥ s, φ(r); r = t works |
| SF: `Gφ → Fφ` | NoMaxOrder (seriality) | T-axiom: t itself witnesses Fφ (since Fφ = ∃ s ≥ t, φ(s)) |
| SP: `Hφ → Pφ` | NoMinOrder (seriality) | T-axiom: t itself witnesses Pφ |
| DF: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` | SuccOrder (discreteness) | s = t witnesses F(Hφ) since Hφ(t) holds |

The collapse is not a coincidence — it follows directly from the T-axiom (Gφ → φ). Once the
present is included in temporal quantification, witnessing by the present moment makes
seriality and density conditions automatically satisfied.

### Finding 3: Under Strict Semantics, These Same Axioms Define Genuine Frame Classes

The converse of the collapse: under strict semantics (<), each of the above axioms corresponds
to a first-order frame property via van Benthem's correspondence theory and the Sahlqvist
theorem. Both the density axiom (GGφ → Gφ) and the seriality axiom (Gφ → Fφ) are Sahlqvist
formulas (positive antecedent conditions), meaning:

- They have computable first-order frame correspondents
- Logics axiomatised by them are canonical (complete w.r.t. the class of frames they define)
- They yield genuinely distinct logics: TM-Base (all linear), TM-Dense (densely ordered),
  TM-Discrete (discrete successor order)

A recent Sahlqvist-style correspondence result for LTL (Li & Belardinelli, arXiv:2206.05973,
2022) extends this to the full temporal language with F, G, X, U, confirming that strict
semantics supports the richest frame-correspondence theory for linear temporal logics.

### Finding 4: The Definability Relationships Between Reflexive and Strict Operators

The two operator families are inter-definable over a logic that contains both:

```
G' φ = φ ∧ Gφ       (reflexive "henceforth" = now-and-always)
H' φ = φ ∧ Hφ       (reflexive "heretofore" = now-and-always-was)

Gφ = G'φ ∧ ¬G'(¬φ)  -- No; G is not directly G' restricted
```

The correct direction is one-way: **G' is definable from G** (as `φ ∧ Gφ`), but **G is NOT
definable from G' alone** in the basic tense language. To recover strict G from reflexive G',
one needs the present-exclusion condition, which requires either:
1. The ability to name the current moment (hybrid logic: `i → ¬◇i` for irreflexivity), or
2. An additional axiom about strict inequality

This asymmetry explains why the strict-to-reflexive translation is the "safe" direction: moving
to reflexive semantics loses no theorems (every theorem under reflexive semantics is also valid
on strict linear orders when the T-axiom is not assumed). Moving strict-to-reflexive adds the
T-axiom and gains simplicity, at the cost of being unable to distinguish frame classes that
differ only in density/seriality properties.

### Finding 5: S4.3 and S4.3.1 — The Reflexive Modal Analogs

The modal logic most closely analogous to reflexive bimodal temporal logic is **S4.3.1**:
- S4: reflexive + transitive frames
- S4.3: S4 + linear (connected) frames (axiom: Fφ ∧ Fψ → F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ))
- S4.3.1: S4.3 + antisymmetry (no two distinct points with mutual accessibility)

S4.3.1 is complete with respect to the class of frames that are reflexive, transitive, and
linearly ordered with antisymmetry — exactly the structure of the canonical model under
reflexive TM semantics. The original completeness proof by Bull (algebraic) and the Kripke
semantics proof by Segerberg are the standard references. The TM proof system under reflexive
semantics is essentially a bimodal extension of S4.3.1.

Under strict semantics, the relevant comparison is to **K4.3** (transitive + linear, without
T-axiom), which has a more complex canonical model construction requiring the Gabbay IRR rule
to handle irreflexivity.

### Finding 6: Expressive Power Summary

The strict (irreflexive) language is provably **strictly more expressive** than the reflexive
language on certain classes of frames:

1. **Next-time operator X**: On strict (irreflexive) linear orders, the discreteness axiom DF
   can be used to define an immediate-successor operator. On reflexive linear orders, this
   definition collapses (a point is its own successor). The expressive gap exists at the level
   of distinguishing discrete from dense frames.

2. **Kamp's Theorem**: On strict linear continuous orders, every first-order-definable temporal
   operator is expressible in Since/Until (Kamp 1968). On reflexive linear orders, the reflexive
   versions U^r and S^r are *strictly less expressive* than their strict counterparts U^s and
   S^s, as confirmed by the SEP Temporal Logic entry.

3. **Frame class separation**: Under strict semantics, the following frame classes are
   axiomatically distinguishable: (a) arbitrary linear order, (b) dense linear order, (c)
   linear order with discrete successor. Under reflexive semantics, all three collapse to a
   single axiom system (since DN, SF, SP, DF are all trivially valid).

For TM's specific purposes, points (1) and (3) are the most relevant. TM does not need the
Next-time operator or Kamp/Until, so the expressive gap that matters is the **frame class
distinction** — which is lost under reflexive semantics.

---

## Frame Constraint Analysis

### Frame Properties and Their Axiom Status Under Each Semantics

| Frame Property | First-Order Condition | Strict Semantics | Reflexive Semantics |
|----------------|----------------------|-----------------|---------------------|
| Transitivity | ∀x∀y∀z (Rxy ∧ Ryz → Rxz) | T4 axiom (non-trivial) | T4 axiom (non-trivial) |
| Linearity | ∀x∀y (Rxy ∨ Ryx ∨ x=y) | Linearity axiom | Linearity axiom |
| Antisymmetry | ∀x∀y (Rxy ∧ Ryx → x=y) | Canonical model property (provable) | Canonical model property (provable via T-axiom) |
| Irreflexivity | ∀x ¬Rxx | NOT modally definable | Absent (reflexivity is T-axiom) |
| Reflexivity | ∀x Rxx | T-axiom (INVALID under strict) | T-axiom (valid by definition) |
| Density | ∀x∀y (Rxy → ∃z (Rxz ∧ Rzy)) | DN axiom (non-trivial) | DN axiom (TRIVIALLY VALID) |
| Seriality (no max) | ∀x ∃y Rxy | SF axiom (non-trivial) | SF axiom (TRIVIALLY VALID) |
| Discreteness | SuccOrder typeclass | DF axiom (non-trivial) | DF axiom (TRIVIALLY VALID) |

**Observation**: The rows marked "TRIVIALLY VALID" under reflexive semantics are precisely the
axioms that collapse — they are valid on *any* reflexive transitive linear frame, not just
frames satisfying the corresponding first-order property.

### The NoMaxOrder / NoMinOrder Situation in TM

In the TM codebase, the canonical model construction under strict semantics uses
`canonicalR_irreflexive` to establish that serial witnesses are **strictly greater** than the
current world. Under reflexive semantics:
- `CanonicalR M M` holds (T-axiom)
- The seriality argument needs to produce `N ≠ M` (not just `CanonicalR M N`)
- The key property needed is `CanonicalR_antisymmetric` rather than irreflexivity

This is the "NoMaxOrder/NoMinOrder proof strategy" gap identified in the Wave 2 research
(05_team-research.md, section "Gaps Identified"). The antisymmetry proof relies on: if
`CanonicalR M N` and `M ≠ N`, then `¬CanonicalR N M`. This is established via the blocking
construction in the Lindenbaum lemma — distinct MCSes disagree on some formula, and that
disagreement prevents reverse inclusion.

### Density and Discreteness as Frame Properties vs. Axioms

A crucial distinction for the design-choices document:

Under **strict semantics**, density (DN) and discreteness (DF) are *semantic distinctions* that
can be *axiomatically characterized*. The three TM logics (Base, Dense, Discrete) are:
1. **Genuinely different proof systems** with different theorem sets
2. **Complete w.r.t. different frame classes** (all linear orders, dense orders, successor orders)
3. **Not inter-derivable**: a formula valid in all dense orders may fail in some discrete order

Under **reflexive semantics**, the three "logics" are identical as proof systems. The frame
classes still exist mathematically — ℚ is still dense, ℤ is still discrete — but:
1. No formula in the language distinguishes them
2. A single completeness theorem covers all linear orders
3. The FrameClass enum in the codebase becomes degenerate (all cases give the same logic)

---

## Expressive Power Comparison

### Formal Translation: What Is and Is Not Preserved

**Reflexive → Strict (downward translation)**:
Every theorem under reflexive semantics (with T-axioms) is valid on strict linear orders when
the T-axioms are not assumed — but the strict logic is *weaker* in the sense that it does not
prove `Gφ → φ`. The reflexive completeness theorem implies the strict soundness theorem (every
reflexive-logic theorem is sound for strict models only if T-axioms hold).

More precisely:
- If `⊢_reflex φ` (provable in reflexive TM), then φ is valid on all reflexive linear orders
- φ need not be valid on all strict linear orders (it may use T-axioms essentially)
- The mapping `G ↦ G', H ↦ H'` (reflexive versions) gives an interpretation of strict syntax
  in reflexive models, and vice versa via `G' φ ↦ φ ∧ Gφ`

**Strict → Reflexive (upward translation)**:
Given a formula φ in the strict language, define φ* by replacing:
- Every occurrence of `G ψ` with `G' ψ = ψ ∧ G ψ` (using reflexive G')
- Similarly for H

Then: `⊢_strict φ` iff `⊢_reflex φ*` (modulo the T-axioms becoming definitionally valid).

This translation works because:
1. Every frame for strict semantics has a reflexive "companion" (add self-loops)
2. Adding self-loops does not invalidate any strict-logic theorem (since strict logic has no
   T-axioms to be falsified)
3. The T-axiom is valid in the companion frame

**What is lost in translation**: The translation φ ↦ φ* "forgets" the strict/reflexive
distinction. Formulas that distinguish dense from discrete frames in the strict language map to
formulas that are trivially valid in the reflexive language. The frame class information is
erased.

### Practical Consequence for TM Design Choices Document

The design-choices section should document:

1. **Under strict semantics**: The axiom system is expressive enough to distinguish frame
   classes. Three distinct proof systems exist. The cost is the irreflexivity obstacle in
   completeness proofs.

2. **Under reflexive semantics**: A single unified proof system. T-axioms are valid.
   Frame class distinctions are invisible to the logic. The cost is that density/seriality
   axioms become degenerate (trivially valid, providing no information about the frame).

3. **The expressive gap is a feature of strict semantics, not a defect of reflexive semantics**:
   If TM's goal is to reason about *a specific fixed linear order* (like ℤ for task management),
   the inability to distinguish dense from discrete frames by axioms is irrelevant — the frame
   is fixed externally, not by the axiom system.

4. **Irreflexivity undefinability is a feature of reflexive semantics**: By not requiring
   irreflexivity, reflexive semantics avoids the need for meta-rules (Gabbay IRR) or axiom
   declarations. This is a significant proof-engineering advantage.

---

## Evidence / References

### Primary Sources Confirmed

1. **Blackburn, de Rijke, Venema (2001)** *Modal Logic*, Cambridge University Press.
   - Section 3.4: Irreflexivity is not modally definable (bisimulation proof)
   - Section 4.1: Sahlqvist theorem and correspondence for canonical axioms
   - Chapter 7: Frame definability and completeness

2. **Goldblatt (1992)** *Logics of Time and Computation*, 2nd ed., CSLI Lecture Notes Vol. 7.
   - Chapters 3-5: Completeness proofs for strict-semantics tense logics
   - Frame correspondence for density, seriality, discreteness

3. **Stanford Encyclopedia of Philosophy, "Temporal Logic"**
   - Confirms: strict U^s/S^s are more expressive than reflexive U^r/S^r
   - Confirms: G and H as "strong" operators, F and P as "weak" (duals)
   - Confirms: "Not all first-order properties of temporal frames are definable by temporal
     formulae" and vice versa (second-order properties can be first-order definable in the logic)

4. **Gabbay (1981)** — IRR rule: `if ⊢ p ∧ H¬p → A and p not in A, then ⊢ A`
   - Required for irreflexivity in canonical model under strict semantics
   - Eliminates the need for this rule under reflexive semantics

5. **Li & Belardinelli (2022)** arXiv:2206.05973 "A Sahlqvist-style Correspondence Theorem
   for Linear-time Temporal Logic"
   - Extends Sahlqvist correspondence to LTL with F, G, X, U
   - Confirms richest frame-correspondence theory lives in strict semantics

6. **Bull (1965) / Segerberg (1970)** — S4.3.1 completeness w.r.t. linear orders (reflexive)
   - S4.3.1 is complete for reflexive+transitive+linear+antisymmetric frames
   - Foundation for the reflexive TM canonical model construction

7. **Open Logic Project, "Frame Definability"**
   - Chapter: Irreflexivity frame condition is NOT modally definable
   - Proof by bisimulation between reflexive and irreflexive points

### Internal Evidence from Prior TM Research

8. **Task 654, research-004.md** (vault archive)
   - Documents the original G/H vs G'/H' design decision in TM
   - Confirms: T-axiom required for "same MCS at all times" canonical history construction
   - Decision: keep G/H as primitive strict operators (prior to the Task 991/29 discussion)

9. **Task 29, 06_theoretical-analysis.md**
   - Confirms frame class collapse table (DN, DF, SF, SP trivially valid)
   - Confirms Gabbay IRR rule citation
   - Confirms S4.3.1 alignment for reflexive semantics

---

## Confidence Level

**High** for:
- Irreflexivity not modally definable (well-established result, confirmed by multiple sources)
- Frame class collapse (DN, DF, SF, SP trivially valid under reflexive semantics) — verified
  mathematically and confirmed in prior TM research
- S4.3.1 alignment for reflexive semantics
- Sahlqvist correspondence applying to density/seriality axioms under strict semantics

**Medium** for:
- The precise statement of the reflexive/strict inter-translation (G' = φ ∧ Gφ direction is
  correct; the reverse φ ↦ φ* translation is standard but I have not verified it in a formal
  source specific to bimodal logics with S5 box)
- The claim that strict U^s/S^s are strictly more expressive than U^r/S^r (confirmed by SEP
  for "continuous linear orders"; may have nuances for discrete orders)

**Low** for:
- Whether TM's specific interaction axioms (MF, TF) introduce any expressive-power asymmetry
  between reflexive and strict semantics that is not captured by the pure temporal analysis
  above — this would require analysis specific to the bimodal TM syntax

---

## Summary for Design Choices Document

The design-choices section should present the reflexive/strict choice as a **fundamental
trade-off**:

**Choose strict (irreflexive) semantics if**:
- Frame class taxonomy is a primary goal (density, seriality, discreteness must be
  axiomatically distinguishable)
- Working in the tradition of Priorian tense logic (G/H quantify strictly over future/past)
- The logic needs to support the Next-time operator or Since/Until with full expressive power
- Connecting to the standard temporal logic literature (Goldblatt, van Benthem)

**Choose reflexive semantics if**:
- Proof-engineering simplicity is paramount (T-axiom eliminates the irreflexivity obstacle)
- The intended frame is fixed externally (e.g., always ℤ or always ℚ — the frame class
  distinction need not be axiomatically visible)
- S5 modal structure is already present (as in TM) — the bimodal interaction with Box creates
  enough structure without relying on temporal frame class distinctions
- Completeness via canonical models is needed without Gabbay's IRR rule or axiom declarations

**The expressive power loss under reflexive semantics** is specifically:
1. Inability to axiomatically distinguish dense from discrete linear orders
2. Seriality axioms (Gφ → Fφ) become theorems rather than constraints
3. The three-variant completeness architecture collapses to one theorem

**This loss is acceptable for TM** because TM is designed for reasoning about tasks over a
fixed linear time domain, not for classifying frames by their density or successor structure.

Sources:
- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Modal Logic — Cambridge (Blackburn, de Rijke, Venema)](https://www.cambridge.org/core/books/modal-logic/F7CDB0A265026BF05EAD1091A47FCF5B)
- [Frame Definability — Open Logic Project](https://builds.openlogicproject.org/content/normal-modal-logic/frame-definability/frame-definability.pdf)
- [A Sahlqvist-style Correspondence Theorem for Linear-time Temporal Logic (arXiv:2206.05973)](https://arxiv.org/abs/2206.05973)
- [Logics of Time and Computation — Goldblatt (CSLI)](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- [S4.3 modal logic — On Strictly Positive Modal Logics with S4.3 Frames](http://www.aiml.net/volumes/volume12/Kikot-Kurucz-Wolter-Zakharyaschev.pdf)
- [Modal Consequence Relations Extending S4.3](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-57/issue-4/Modal-Consequence-Relations-Extending-S43--An-Application-of-Projective/10.1215/00294527-3636512.pdf)
- [van Benthem, Modal Frame Correspondences and Fixed-Points](https://link.springer.com/article/10.1007/s11225-006-8301-9)
- [Sahlqvist theorem — Wikipedia](https://en.wikipedia.org/wiki/Sahlqvist_formula)
- [Bisimulations for Temporal Logic — Springer](https://link.springer.com/article/10.1023/A:1008223921944)
