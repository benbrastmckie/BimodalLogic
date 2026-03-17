# Teammate A Findings: Representation Theorem Approaches

**Task**: 990 - Representation theorem design for parametric durations
**Date**: 2026-03-17
**Focus**: Primary approaches in the literature: Henkin-style completeness, Prior/Burgess/Goldblatt, D-from-syntax vs D-parametric

---

## Key Findings

### 1. Standard Henkin-Style Completeness for Modal Logic

The canonical model construction for normal modal logic (as documented in Blackburn-de Rijke-Venema 2001 and the OpenLogic Project) builds worlds and accessibility from pure syntax:

- **Worlds** = maximal consistent sets (MCSs) — entirely syntactic objects
- **Accessibility relation** `R_G(U, V)` = `{φ | Gφ ∈ U} ⊆ V` — defined by G-content inclusion
- **Truth lemma** = φ ∈ U ↔ U ⊨ φ in the canonical model — proved by structural induction
- **Frame structure** = derived from syntax, not introduced as a parameter

This is the classical Henkin completeness strategy: the canonical frame IS the syntactic structure lifted to a semantic object. D (the time domain) is NOT a separate parameter in pure Kripke semantics — the ordering of worlds IS the accessibility relation.

### 2. Tense Logic Completeness: The Two Schools

The literature on tense logic (Segerberg 1970, Rescher-Urquhart 1971, Burgess 1979, Goldblatt 1992) reveals two distinct approaches:

**School A: Specific-Time-Domain Completeness** (Prior/Burgess/Goldblatt tradition)

The completeness theorem is stated for a specific time domain, e.g.:
- Qt is complete for ⟨Q, <⟩ (rationals with standard order)
- Zt is complete for ⟨Z, <⟩ (integers with standard order)
- Rt is complete for ⟨R, <⟩ (reals with standard order)

In this approach, the time domain ⟨Q, <⟩ is a **given mathematical structure**, not constructed from syntax. The proof typically uses the finite model property or filtration. The density axiom (DENSE: GGφ → Gφ) constrains which models satisfy the logic; it does not build Q from scratch.

**School B: Canonical Model Construction** (Goldblatt 1992 algebraic approach, BdRV 2001)

The completeness proof proceeds by constructing a canonical model whose worlds ARE the MCSs and whose ordering IS defined by g-content inclusion. The density axiom forces the canonical accessibility relation to be dense via a "G-witness construction":

> If Fφ ∈ U, construct V (G-witness) with g-content(U) ⊆ V but φ ∉ V, then construct W with g-content(V) ⊆ W and φ ∈ W. The density axiom ensures this intermediate W exists.

**Key insight from the literature**: The density axiom is used as a *constraint on syntax* to force the canonical accessibility relation to have density. The time domain (Q or Z) is the *target* that the canonical construction approximates, not the *source*.

### 3. D-From-Syntax Approaches: Cantor's Theorem

The project's existing "D Construction from Canonical Timeline" strategy follows a non-standard path not explicitly found in the tense logic literature:

1. Build MCSs via staged construction (dovetailing witnessing)
2. Order them by CanonicalR accessibility
3. Quotient by mutual accessibility (Antisymmetrization) → TimelineQuot
4. Prove Cantor prerequisites: Countable, DenselyOrdered, NoMaxOrder, NoMinOrder
5. Apply Cantor's uniqueness theorem → TimelineQuot ≃o Q
6. Transfer AddCommGroup structure along the isomorphism → D with group structure
7. Build TaskFrame using this D

This approach constructs D ≃ Q **from syntax itself**. It is architecturally elegant (D emerges from axioms) but faces a critical practical obstacle: the **domain mismatch problem**.

The domain mismatch arises because:
- The truth lemma (ParametricTruthLemma.lean) requires `[LinearOrder D]`
- CanonicalMCS has only `[Preorder]`, not `[LinearOrder]`
- TimelineQuot (the quotient) has LinearOrder but may not contain all required witness MCSs
- The forward_F witness from `canonical_forward_F` produces a CanonicalMCS element, not necessarily a TimelineQuot element

From `CanonicalDomain.lean` and `research-014.md`: the staged construction at step m > 2k does not guarantee the F-witness for formula k was added.

### 4. D-Parametric Approaches: The Current Algebraic Path

The current `ParametricRepresentation.lean` and `ParametricCanonical.lean` implement the D-parametric approach:

```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

The construction works for **any** totally ordered abelian group D:
- WorldState = MCSs (D-independent)
- task_rel(M, d, N) = if d > 0 then CanonicalR M N else if d < 0 then CanonicalR N M else M = N
- The TaskFrame axioms hold for arbitrary D

This is a **uniform representation theorem**: D is a parameter constrained by axioms (AddCommGroup + LinearOrder + IsOrderedAddMonoid), not constructed from syntax.

The Lindenbaum-Tarski BAO approach (Jónsson-Tarski 1951/1952, Goldblatt 1976) supports this: the Stone dual of the modal algebra gives worlds (ultrafilters), and the temporal ordering emerges from the G-operator. The duration type D is then an **external parameter** that indexes the task_rel ternary relation.

### 5. The Fundamental Tension

The project faces a tension between two architecturally correct but practically different approaches:

| Dimension | D-from-Syntax | D-Parametric |
|-----------|--------------|-------------|
| D source | Built from MCSs via Cantor | External parameter |
| Completeness scope | Specific D (e.g., TimelineQuot ≃ Q) | Any D satisfying axioms |
| Domain mismatch | Yes — witnesses may be outside TimelineQuot | No — all MCSs serve as worlds |
| sorry-free status | Dense case: mostly sorry-free (depends on axiom); Base case: open | Yes, conditional on BFMCS construction |
| Literature precedent | Constructive/categorical; unusual in classical tense logic | Standard Henkin approach |
| Lean proof challenge | BFMCS must use TimelineQuot; forward_F in TimelineQuot is hard | Must construct temporally coherent BFMCS over any D |

### 6. The Base Logic Gap (Critical Finding)

From `CanonicalDomain.lean` section "Base Case":

> "The base axiom system (without density or discreteness) has no characterization theorem to identify its canonical timeline with a known group. Without DN or DF, the timeline's order-theoretic properties are underdetermined..."

This is the most critical finding for task 990: **the D-from-syntax approach has no solution for the base logic**. Without DN or DF axioms, there is no characterization theorem (Cantor or Z-characterization) to identify the canonical timeline with Q or Z. The D-parametric approach does not have this problem — it works for any D satisfying the group+order constraints.

In the standard tense logic literature, the base logic Kt (without density or discreteness) is complete for the class of all linear orders (possibly with endpoints). A natural parametric completeness statement is: "⊢ φ iff φ is valid in all TaskFrames over all totally ordered abelian groups D." This is exactly what the D-parametric approach delivers.

---

## Recommended Approach

**Recommendation: D-Parametric as Primary, D-from-Syntax as Optional Specialization**

The D-parametric approach should be the primary completeness architecture for the following reasons:

**1. Literary alignment**: The classical tense logic literature (Qt is complete for ⟨Q, <⟩) treats the time domain as a given structure, not derived from syntax. The representation theorem proves: "for any non-provable φ, there exists a countermodel over some D." This is parametric.

**2. Base logic coverage**: The D-from-syntax approach has an open problem for the base logic. The D-parametric approach handles all cases uniformly (base, dense, discrete) by instantiating D = Int, Rat, or any other ordered abelian group.

**3. No domain mismatch**: The D-parametric approach eliminates the fundamental blocker in task 982 by construction. The 18 sorries in the TimelineQuot-based path all stem from the domain mismatch.

**4. Standard Henkin pattern**: The canonical worlds are MCSs, the accessibility is CanonicalR, and D is an external parameter. This matches the Henkin/BAO tradition exactly.

**5. Practical sorry-free path**: The conditional representation theorem (`parametric_algebraic_representation_conditional`) is already sorry-free. The gap is only in the BFMCS construction for specific D values.

**For density/discreteness extensions**:
- Dense completeness = D-parametric theorem instantiated with D = Rat (or any DenselyOrdered group), plus the algebraic proof that the DN axiom forces the canonical accessibility relation to be dense.
- Discrete completeness = instantiated with D = Int, plus the algebraic proof that DF forces covering.

The density/discreteness axioms **constrain the accessibility relation** in the canonical model (School B above) rather than building D from scratch.

**On the D-from-syntax approach (DFromCantor.lean)**:
It provides a beautiful categorical perspective (characterization functors, transfer functors) and is worth keeping for the dense case where it is mostly sorry-free. However, it should not be the primary completeness path due to the base logic gap and domain mismatch problems.

---

## Evidence/Examples

### Evidence 1: Stanford Encyclopedia confirms D is a "given structure"

From the temporal logic SEP entry: Qt is complete for ⟨Q, <⟩ — the rational time domain is introduced as a pre-existing structure that the logic characterizes, not built from syntax. The density axiom constrains which models satisfy the logic.

### Evidence 2: OpenLogic Project canonical model construction

The OpenLogic canonical model for normal modal logic defines worlds = MCSs and accessibility = formula-set inclusion. The frame structure is derived from syntax. There is no separate "time domain D" — this parameter is TaskFrame-specific.

### Evidence 3: The BdRV (Blackburn-de Rijke-Venema) two-step

From research-001-teammate-a-findings.md (task 985): BdRV Chapter 4 proves completeness by:
1. Constructing the canonical model with worlds = MCSs
2. Proving the truth lemma by induction
3. Showing the canonical frame has the required properties

The density axiom forces a "G-witness construction" that makes the canonical accessibility relation dense. This is the algebraic alternative to D-from-syntax.

### Evidence 4: Domain mismatch is the blocking problem

From research-014.md (task 982): "18 sorries across 6 files. Primary blocker: TimelineQuot forward_F/backward_P witnesses (5 sorries in ClosureSaturation.lean)." This confirms the D-from-syntax approach is practically blocked.

### Evidence 5: Parametric approach is conditionally sorry-free

`ParametricRepresentation.lean` provides `parametric_algebraic_representation_conditional` which is sorry-free but requires a BFMCS constructor. The base logic path via CanonicalMCS (task 987) is sorry-free for the FMCS construction.

### Evidence 6: Prior/Burgess tradition uses specific domains as targets

Burgess (1979) proves completeness of various tense logics for specific time domains (Q, R, Z, omega). These are not "constructed" from syntax but are well-known mathematical structures that the syntax is designed to axiomatize. The completeness proof then shows the syntax is adequate for these target domains.

### Evidence 7: Goldblatt 1992 algebraic canonical model

Goldblatt's algebraic approach (referenced throughout the codebase) uses ultrafilters of the Lindenbaum algebra as the canonical model points, with the accessibility relation defined by operator content. This is exactly the ParametricCanonical.lean approach, generalized to parametric D.

---

## Confidence Level

**High confidence** (8/10) on the following claims:

1. The D-parametric approach is the correct primary architecture for the TM base logic.
2. D should be treated as a parameter with axioms (AddCommGroup + LinearOrder + IsOrderedAddMonoid) constraining its structure.
3. The density axiom (DN) forces the canonical accessibility relation to be dense, enabling specialization to dense completeness without building D from scratch.
4. The base logic has no pure-syntax D construction (confirmed by CanonicalDomain.lean explicitly).
5. The conditional representation theorem in ParametricRepresentation.lean is the right statement.

**Medium confidence** (6/10) on:

6. Whether D-from-syntax (DFromCantor.lean) can be salvaged for dense completeness specifically — it depends on resolving the forward_F witness coverage problem in TimelineQuot.
7. The exact relationship between the D-parametric approach and a "base completeness" that would connect to the existing BFMCS infrastructure.

**Explanation of uncertainty**: The literature is clear on the approach (parametric D, Henkin-style worlds = MCSs), but the project-specific TaskFrame structure (with its ternary task_rel rather than binary accessibility) introduces non-standard complexities. The transition from Henkin's binary-relation worlds to TaskFrame's history-and-time-point structure adds genuine novel challenges not covered in standard references.

---

## Synthesis: The Design Decision for Task 990

The fundamental question is: **Should D be constructed from pure syntax, or be parametric with axioms?**

**Answer: Parametric with axioms is the mathematically correct and practically superior choice.**

The key insight from the literature: in tense logic completeness proofs, the time domain Q, Z, or R is never constructed from syntax. It is either:
(a) A given target structure the logic is designed for (Prior/Burgess approach), or
(b) Implicitly present as a property of the canonical accessibility relation (Goldblatt/BdRV approach)

In both cases, D is **not emergent from syntax** — it is either given externally or appears as a derived property of the accessibility relation (which is itself syntactically defined, but whose structure (dense, discrete) follows from the axioms).

For TM base logic specifically:
- Base logic: D must be parametric (no characterization theorem exists)
- Dense logic: D can be specialized to DenselyOrdered groups, but the parametric theorem is stronger
- Discrete logic: D can be specialized to Z or SuccOrder groups

The D-from-syntax approach (DFromCantor.lean) is a mathematically interesting construction but is better understood as a **model-existence theorem** (showing that a particular syntactically-constructed structure satisfies the required properties) rather than the primary completeness path.

**Implementation recommendation**: Keep D-parametric as primary. Treat D-from-syntax as an optional additional result showing that the canonical timeline itself satisfies the required group structure (when DN axioms are present), which can then be used to instantiate the parametric theorem.
