# Research Report: Task #33 (Team Research)

**Task**: Expand design-choices section with comprehensive reflexive vs irreflexive semantics analysis
**Date**: 2026-03-22
**Mode**: Team Research (4 teammates)
**Session**: sess_1774212234_48e1ac
**Focus**: Deep analysis of reflexive vs irreflexive semantics — expressive power, frame constraints, representation theorems, algebraic perspective, codebase history

---

## Executive Summary

Four teammates investigated complementary angles of the reflexive vs irreflexive semantics choice for TM's temporal operators G and H. The findings converge strongly: the choice represents a fundamental trade-off between **frame-definability expressiveness** (favoring strict/irreflexive) and **proof-theoretic and algebraic elegance** (favoring reflexive). The analysis covers six major dimensions that should be documented in an expanded design-choices section.

**Key cross-cutting finding**: The algebraic perspective (Teammate C) provides a unifying lens — G and H are **interior operators** on the Lindenbaum algebra if and only if the semantics is reflexive. This single algebraic fact explains why reflexive semantics yields cleaner completeness proofs (interior algebras have better representation theorems), why frame classes collapse (interior operators automatically satisfy S4 axioms on all frames), and why the T-axiom is the linchpin (it is exactly the deflationarity condition for interior operators).

---

## Key Findings

### 1. Algebraic Classification: The Interior Operator Perspective

**Finding** (Teammate C, confirmed by codebase): G, H, and □ are all **interior operators** on the Lindenbaum algebra under reflexive semantics. Under strict semantics, only □ retains this status; G and H degrade to mere monotone normal modal operators.

An interior operator I satisfies three conditions:
1. **Deflationary**: I(a) ≤ a (corresponds to T-axiom: Gφ → φ)
2. **Monotone**: a ≤ b → I(a) ≤ I(b) (corresponds to K-distribution)
3. **Idempotent**: I(I(a)) = I(a) (corresponds to 4-axiom + T-axiom)

The ProofChecker formalizes this in `InteriorOperators.lean`:
- `box_interior : InteriorOp LindenbaumAlg` — proven (always valid)
- `G_interior` and `H_interior` — existed under reflexive semantics (Task 967), removed under strict
- Under strict semantics, only `G_monotone` and `H_monotone` are provable

**The dual operators** F, P, ◇ are correspondingly **closure operators** (inflationary, monotone, idempotent) under reflexive semantics.

**McKinsey-Tarski connection**: S4 = logic of topological interior (McKinsey-Tarski 1944). Under reflexive semantics, TM's temporal fragment forms a **bimodal interior algebra** (tense algebra) — a well-studied algebraic structure. Under strict semantics, this rich structure is lost.

**Jónsson-Tarski representation**: Frame reflexivity corresponds precisely to operator deflationarity. The choice of reflexive semantics is algebraically equivalent to choosing that G and H are interior operators — this is the cleanest algebraic characterization of the design decision.

### 2. Expressive Power and Frame Definability

**Finding** (Teammate A): Strict semantics is provably **strictly more expressive** for frame-class distinction.

Under **strict semantics**, the following frame properties are modally definable:
| Frame Property | Axiom | Characterization |
|---------------|-------|-----------------|
| Density | DN: GGφ → Gφ | DenselyOrdered (Sahlqvist) |
| Seriality (future) | SF: Gφ → Fφ | NoMaxOrder |
| Seriality (past) | SP: Hφ → Pφ | NoMinOrder |
| Discreteness | DF: (F⊤ ∧ φ ∧ Hφ) → F(Hφ) | SuccOrder |

Under **reflexive semantics**, all four collapse to trivial validity:
| Axiom | Trivial Proof |
|-------|---------------|
| DN: GGφ → Gφ | r = t in ∀s≥t, ∀r≥s, φ(r) |
| SF: Gφ → Fφ | T-axiom: φ(t) witnesses Fφ |
| SP: Hφ → Pφ | T-axiom: φ(t) witnesses Pφ |
| DF: (F⊤ ∧ φ ∧ Hφ) → F(Hφ) | s = t witnesses F(Hφ) |

**Critical result**: Irreflexivity itself is NOT modally definable (Blackburn-de Rijke-Venema, bisimulation argument). No temporal formula can distinguish irreflexive from reflexive frames. This is the mathematical root cause of all proof complexity under strict semantics.

**Inter-definability**: Reflexive G' is definable from strict G (as φ ∧ Gφ), but strict G is NOT recoverable from reflexive G' alone — recovering it requires the ability to exclude the present moment, which demands hybrid logic or an additional axiom about strict inequality. The strict-to-reflexive direction is the "safe" translation.

**S4.3.1 alignment**: Under reflexive semantics, TM aligns with S4.3.1 (reflexive + transitive + linear + antisymmetric), a well-studied system with known completeness (Bull 1965, Segerberg 1970). Under strict semantics, the relevant comparison is K4.3 (transitive + linear, no T-axiom).

### 3. Frame Class Collapse: Feature or Bug?

**Finding** (all teammates converge): The collapse is a **feature** for TM's goals but a genuine **loss** for frame taxonomy.

**Arguments for "feature" (simplification)**:
- TM's primary goal is completeness for linear temporal reasoning, not frame classification
- Three completeness theorems collapse to one
- The canonical model construction is simpler (no Gabbay IRR rule needed)
- The mathematical content of density/discreteness remains in the frame, just not in the axioms

**Arguments for "loss" (reduced expressiveness)**:
- Cannot axiomatically distinguish dense from discrete frames
- The three genuinely different logics (TM-Base, TM-Dense, TM-Discrete) become identical
- Loses connection to standard temporal logic hierarchy (Goldblatt, van Benthem)
- Seriality axioms (Gφ → Fφ) become theorems rather than constraints

**Resolution for TM**: The collapse is acceptable because:
1. TM reasons about a fixed linear time domain (not classifying frames)
2. The S5 modal structure provides enough expressiveness for TM's bimodal needs
3. The frame class distinction is preserved semantically (ℚ is still dense, ℤ still discrete) — only the axiomatic characterization is lost

### 4. Representation Theorem Challenges

**Finding** (Teammate B, confirmed by D): The canonical model construction differs fundamentally between the two semantics.

**Under strict semantics** (complex):
1. CanonicalR M N = g_content(M) ⊆ N
2. CanonicalR M M is "obviously false" semantically but NOT derivable from axioms
3. Requires Gabbay IRR meta-rule: "If ⊢ (p ∧ H¬p) → A and p ∉ A, then ⊢ A"
4. The IRR proof requires T-axiom at Step 7 — which is INVALID under strict semantics
5. Result: `canonicalR_irreflexive_axiom` is an unproven Lean axiom (1254 lines of infrastructure, ultimately fails)
6. Three separate completeness theorems needed (Base/Dense/Discrete)

**Under reflexive semantics** (simpler):
1. CanonicalR M M holds by T-axiom + MCS closure (proven: `canonicalR_reflexive`)
2. Instead of irreflexivity, establish **antisymmetry**: CanonicalR M N ∧ CanonicalR N M → M = N
3. T-axiom (Gφ → φ) carries the proof burden — definitionally valid
4. Single completeness theorem suffices
5. The Gabbay IRR infrastructure can be "reactivated" for antisymmetry proofs

**Active blocker** (Task 29 Phase 5): 25+ call sites use `canonicalR_irreflexive` via the pattern "CanonicalR M N + CanonicalR N M → CanonicalR M M → contradiction". Under reflexive semantics, the last step fails (CanonicalR M M is TRUE). Replacement requires proving antisymmetry — a non-trivial result needing new Gabbay-style infrastructure adapted for MCS equality.

### 5. Historical Context: Prior's Tradition vs. Modern Practice

**Finding** (Teammates A, D):

**Prior's original semantics (1957-1968)**: Strict operators. F ("it will be the case") and P ("it was the case") quantify over strictly future/past times. This tradition continued through Goldblatt, van Benthem, Blackburn-de Rijke-Venema.

**Computer science shift**: CTL/CTL* uses reflexive variants. LTL has both strict and weak operators. Model checking favors reflexive (finite state systems, discrete time steps).

**TM project history** (Teammate D — 4 semantic switches):

| Date | Task | Direction | Motivation |
|------|------|-----------|-----------|
| Initial | — | Reflexive (≤) | Project inception |
| 2026-03-09 | Task 956 | → Strict (<) | Density concern (later shown unfounded) |
| 2026-03-14 | Task 967 | → Reflexive (≤) | T-axiom needed for IRR proof |
| 2026-03-18 | Task 991 | → Strict (<) | Frame class separation |
| 2026-03-21 | Task 29 | → Reflexive (≤) | IRR proof broken under strict; theoretical analysis |

**Key vault discoveries**:
- **Task 658** (decisive): Independent Lindenbaum extensions are *mathematically impossible* to prove coherent without T-axiom. Not a proof difficulty — a mathematical impossibility.
- **Task 958**: CanonicalR irreflexivity is unprovable under strict semantics without T-axiom (confirms mathematical root cause).
- **Task 957**: Density frame conditions ARE provable under strict semantics (the density concern was unfounded).

### 6. IRR Soundness Under Reflexive Semantics

**Finding** (Teammate D): Under reflexive semantics, the Gabbay IRR rule's antecedent `p ∧ H(¬p)` becomes unsatisfiable — since H(¬p) at t includes t ≤ t, giving ¬p at t, contradicting p. The `IRRSoundness.lean` file has a sorry at line 322 for this reason.

This means:
- The IRR rule is **vacuously sound** under reflexive semantics (the antecedent is never satisfiable)
- But the current proof structure breaks because it was designed for strict semantics
- The proof needs fundamental redesign — either proving vacuous soundness directly, or removing IRR from the proof system (since it's not needed for reflexive completeness)

---

## Synthesis

### Conflicts Found: 0

All four teammates converge on the same fundamental conclusions. Minor framing differences:
- Teammate A frames the collapse as "loss of expressiveness"
- Teammate D frames it as "feature, not a bug"
- These are consistent perspectives on the same trade-off

### Gaps Identified: 3

1. **TM bimodal interior algebra in literature**: Whether TM's specific combination (S5 modal □ + reflexive G/H over linear orders) has been treated as a tense interior algebra in existing literature is unknown. This may be a novel algebraic formulation (Teammate C, low confidence).

2. **MF/TF interaction axiom impact**: Whether TM's bimodal interaction axioms (MF: □φ → □Gφ, TF: □φ → G□φ) introduce expressive-power asymmetries not captured by the pure temporal analysis is unknown (Teammate A, low confidence).

3. **IRR soundness redesign path**: The exact strategy for either proving vacuous soundness or removing IRR from the reflexive proof system is an open research question (Teammate D).

### Recommended Content Structure for Expanded Design-Choices Section

Based on the research, the expanded design-choices documentation should include:

**Section 1: The Semantic Distinction** (update existing definitions)
- Formal definitions of both semantics
- The T-axiom as the distinguishing property

**Section 2: Algebraic Classification** (NEW)
- G, H, □ as interior operators under reflexive semantics
- Loss of interior structure under strict semantics
- McKinsey-Tarski connection (S4 = topological interior)
- Jónsson-Tarski: frame reflexivity ↔ operator deflationarity

**Section 3: Expressive Power and Frame Definability** (NEW)
- Frame class collapse table (DN, DF, SF, SP)
- Sahlqvist correspondence under strict semantics
- Irreflexivity is not modally definable
- Inter-definability (G' from G, but not G from G')

**Section 4: Representation Theorem Challenges** (NEW)
- Canonical model under each semantics
- Gabbay IRR rule and its limitations
- Three-variant vs single completeness architecture
- The antisymmetry approach under reflexive semantics

**Section 5: Historical Context** (expand existing remark)
- Prior's strict tradition
- CS shift to reflexive (CTL/CTL*, model checking)
- S4.3.1 alignment for reflexive TM
- TM project's own semantic switches and lessons learned

**Section 6: Design Rationale for TM** (expand existing remark)
- Why reflexive semantics was chosen
- Trade-offs accepted (frame class collapse, departure from strict tradition)
- Mathematical necessity (indexed family coherence)
- Algebraic elegance (interior operator structure)

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Expressive power & frame constraints | completed | high | Strict more expressive for frame classes; collapse under reflexive; S4.3.1 alignment |
| B | Representation theorem challenges | completed | high | IRR unprovable under strict; 25+ sites need antisymmetry; 3→1 completeness collapse |
| C | Algebraic perspective (interior operators) | completed | high | G/H are interior operators iff reflexive; McKinsey-Tarski; Jónsson-Tarski |
| D | Codebase & vault archives | completed | high | 4 semantic switches; Task 658 mathematical impossibility; IRRSoundness sorry |

---

## References

### Academic Sources
- Blackburn, de Rijke, Venema (2001) *Modal Logic* — Chapter 3.3 (irreflexivity not definable), Chapter 4.1 (Sahlqvist), Chapter 7 (frame definability)
- Goldblatt (1992) *Logics of Time and Computation* — Chapters 3-5 (completeness for strict tense logics), tense algebras
- McKinsey & Tarski (1944) — S4 = topological interior
- Jónsson & Tarski (1952) — BAO representation theorem; frame reflexivity ↔ operator deflationarity
- Gabbay (1981) — IRR rule for irreflexive completeness
- Bull (1965), Segerberg (1970) — S4.3.1 completeness for reflexive linear orders
- Li & Belardinelli (2022) arXiv:2206.05973 — Sahlqvist correspondence for LTL
- Kamp (1968) — Expressive completeness of Until/Since on strict linear orders

### Codebase Evidence
- `InteriorOperators.lean` — box_interior proven; G_interior/H_interior documented
- `CanonicalIrreflexivity.lean` — canonicalR_reflexive (line 1206), canonicalR_irreflexive_axiom (line 1240)
- `IRRSoundness.lean` — sorry at line 322 (reflexive semantics incompatibility)
- `Truth.lean` — reflexive semantics (≤)
- `Axioms.lean` — 21 axioms including temp_t_future, temp_t_past
- `FMCSDef.lean` — reflexive coherence conditions (≤)

### Vault Archive Sources
- Task 658/730: Mathematical impossibility of indexed family approach under strict semantics
- Task 957: Density frame condition provable under strict (density concern unfounded)
- Task 958: Irreflexivity unprovable under strict without T-axiom
- Task 962: Reflexive-source density lemma asymmetry
- Task 801: Semantic switch desynchronization pattern

### Teammate Reports
- specs/033_expand_design_choices_reflexive_analysis/reports/01_teammate-a-findings.md
- specs/033_expand_design_choices_reflexive_analysis/reports/01_teammate-b-findings.md
- specs/033_expand_design_choices_reflexive_analysis/reports/01_teammate-c-findings.md
- specs/033_expand_design_choices_reflexive_analysis/reports/01_teammate-d-findings.md
