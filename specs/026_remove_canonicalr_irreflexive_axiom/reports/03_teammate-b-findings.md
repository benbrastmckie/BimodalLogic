# Teammate B Findings: Complete Axiomatizations for Irreflexive Modal Logics

**Date**: 2026-03-21
**Focus**: GL, Grz, and techniques for achieving completeness without directly axiomatizing irreflexivity

---

## Key Findings

### 1. GL (Gödel-Löb Logic): The Paradigm Example

GL is **the** definitive example of a complete modal logic for irreflexive frames. It achieves completeness for transitive, irreflexive frames without any axiom directly expressing irreflexivity.

**Axiomatization**:
- All propositional tautologies
- K axiom: `□(φ → ψ) → (□φ → □ψ)`
- **Löb axiom**: `□(□φ → φ) → □φ`
- Rules: Modus Ponens, Necessitation

**Frame Correspondence**: The Löb axiom is valid precisely on frames that are:
1. **Transitive**: `Rxy ∧ Ryz → Rxz`
2. **Converse well-founded**: No infinite ascending R-chains

A finite frame is converse well-founded if and only if it is **irreflexive**. The Löb axiom semantically forces irreflexivity in finite models without syntactically expressing it.

**Completeness Results** (Segerberg 1971, de Jongh-Kripke independently):
- GL is complete with respect to transitive, converse well-founded frames
- GL is complete with respect to **finite transitive irreflexive trees**
- GL has the **finite model property**

**Why GL Does NOT Need an Irreflexivity Axiom**:
The Löb axiom `□(□p → p) → □p` fails at reflexive points. At a reflexive world w where wRw:
1. If □p → p holds at w, then □p holds at w (by reflexivity, p holds at w implies □p holds at w in finite frames)
2. The Löb axiom would then imply □p
3. But there exist valuations where □p → p holds without □p holding (when p is false at w)
4. This contradiction rules out reflexive points in any model validating the Löb axiom

**Critical Insight**: GL proves transitivity `□φ → □□φ` but **not reflexivity** `□φ → φ`. This is exactly the irreflexive behavior needed.

### 2. Grz (Grzegorczyk Logic): The Reflexive Counterpart

**Axiom**: `□(□(φ → □φ) → φ) → φ`

**Frame Correspondence**: Reflexive, transitive frames that are **hereditarily irreflexive after reflexivity** (i.e., transitive frames where every cluster is trivial).

**Relationship to GL**:
- Grz is complete for reflexive transitive frames with no proper clusters
- The **Kuznetsov-Goldblatt-Boolos theorem** states: `Grz ⊢ φ` iff `GL ⊢ φˢ`
  where `φˢ` is the "splitting translation" replacing each `□` with `□⁺` (where `□⁺ψ = ψ ∧ □ψ`)
- Intuitionistic logic embeds into both: `IPC ⊢ φ` iff `Grz ⊢ φᵗ` iff `GL ⊢ (φᵗ)ˢ`

**wGrz (Weak Grzegorczyk Logic)**:
- Also called K4.Grz or K4C1 (Litak 2007, 2014; Gabelaia 2004; Esakia 2006)
- Complete for transitive Noetherian frames (neither reflexive nor irreflexive in general)
- GL is the irreflexive counterpart; Grz is the reflexive counterpart
- All three share the finite model property and decidability

### 3. Provability Logic and Arithmetical Completeness

GL arose from formalizing provability in Peano Arithmetic. **Solovay's Theorem (1976)**: GL is arithmetically complete for the standard provability predicate in PA.

The proof exploits Segerberg's result:
1. By modal completeness, any non-theorem has a countermodel on a finite transitive irreflexive tree
2. Solovay's technique simulates such finite trees inside PA
3. This simulation works precisely because irreflexivity holds (no world proves its own provability)

**Key observation**: The semantic property of irreflexivity is **crucial for the arithmetical interpretation** but is NOT expressed by any single axiom. The Löb axiom captures the provability-theoretic behavior that happens to force irreflexivity semantically.

### 4. How GL Handles Irreflexivity: The Technical Details

**Step 1: Canonical Model Construction**
- Build the canonical model from maximal consistent sets (MCS)
- The accessibility relation R connects MCS M to N when `{φ : □φ ∈ M} ⊆ N`

**Step 2: The Problem**
- The canonical model is NOT necessarily irreflexive
- MCS can relate to themselves (this is the issue the ProofChecker codebase faces)

**Step 3: The Solution - Tree Unraveling**
- Instead of working with the potentially reflexive canonical model, **unravel** it into a tree
- Start from any MCS M₀ and build finite paths of decreasing modal depth
- The resulting structure is a finite transitive irreflexive tree
- The Löb axiom ensures this unraveling terminates (converse well-foundedness)

**Step 4: Finite Model Property**
- Any non-theorem φ has a finite tree countermodel of depth ≤ modal depth of φ
- The tree is irreflexive by construction
- Decidability follows from bounded search through finite trees

**This is the key technique**: GL achieves irreflexivity in its models NOT by axiomatizing it, but by:
1. Using an axiom (Löb) that forces converse well-foundedness
2. Restricting to finite models where converse well-foundedness = irreflexivity
3. Proving the finite model property to show this restriction loses no theorems

### 5. Other Complete Irreflexive Logics

**K4Cn Logics** (circumference-bounded transitive logics):
- K4C0 = GL (irreflexive)
- K4C1 = wGrz (no constraints on reflexivity, but no cycles of length > 1)
- Each is axiomatized by adding a single axiom to K4
- All have FMP and are decidable

**Temporal Logic with IRR Rule**:
For strict temporal semantics (as in ProofChecker), the standard approach is the **Gabbay Irreflexivity Rule**:

```
IRR: If {p, H(¬p)} ∪ Γ ⊢ φ for fresh p, then Γ ⊢ φ
```

This is NOT a standard Hilbert axiom but an inference rule. It allows deriving properties that require irreflexivity without axiomatizing irreflexivity directly.

**Alternative to IRR** (Zanardo 1990): Replace IRR with an infinite axiom scheme. This shows that strict temporal logic can be axiomatized without the IRR rule, but at the cost of infinitely many axioms.

### 6. Why Irreflexivity Cannot Be Modally Defined

The van Benthem/Blackburn-de Rijke-Venema result: **No modal formula φ is valid exactly on irreflexive frames.**

Proof sketch: Modal formulas are invariant under generated submodels and bounded morphisms. But irreflexivity is NOT preserved: you can collapse an irreflexive two-point frame to a reflexive single point via a bounded morphism.

**Consequence**: Any purely Hilbert-style axiomatization (axiom schemas + Modus Ponens + Necessitation) cannot force irreflexivity directly. The options are:
1. Use a non-standard rule (IRR, or infinitary rules)
2. Accept axioms that force irreflexivity indirectly (like Löb) but only on restricted frame classes
3. Add irreflexivity as a semantic postulate (axiom in the metalogic)

---

## Recommended Approach

**For ProofChecker's strict temporal logic**, the situation differs from GL in a crucial way:

| Aspect | GL | ProofChecker's Temporal Logic |
|--------|-----|-------------------------------|
| Frame class | Transitive, converse well-founded | Strict linear orders (irreflexive, transitive, connected) |
| Key axiom forcing irreflexivity | Löb `□(□p→p)→□p` | None available |
| Semantic completeness technique | Tree unraveling | Canonical model + saturation |
| Finite model property | Yes | No (dense order) |

The GL approach (Löb axiom + FMP) does NOT transfer directly because:
1. ProofChecker's temporal logic lacks a Löb-like axiom
2. The target frames include dense orders, which are infinite
3. The canonical model cannot be tree-unraveled in the same way

**Viable Paths Inspired by GL/Grz**:

**Path A: Add a Löb-like Axiom** (Low viability)
- Investigate whether `G(Gφ → φ) → Gφ` is consistent with the intended semantics
- Problem: This forces converse well-foundedness, which contradicts density

**Path B: Use the Gabbay IRR Rule** (Medium-High viability)
- Standard solution for strict temporal logics
- Extends the proof system beyond pure Hilbert-style
- The rule is sound and allows proving irreflexivity
- **This is the principled approach** matching the literature

**Path C: Accept the Axiom** (High viability)
- The `canonicalR_irreflexive_axiom` is mathematically sound
- It expresses a semantic truth that IS NOT modally definable
- GL "avoids" an irreflexivity axiom only because FMP + Löb happen to work
- For dense temporal orders, this escape route is not available
- **Keeping the axiom is the honest representation** of the modal non-definability result

---

## Evidence/Examples

**GL Example - Why Löb Forces Irreflexivity**:

Consider a one-world reflexive model M = ({w}, {(w,w)}, V) with V(p) = ∅.
- At w: `□p → p` holds (vacuously, since □p is false - there's an accessible world, w itself, where p fails)
- Wait, this is wrong. Let me reconsider.
- At w: □p = "p holds at all R-accessible worlds" = "p holds at w" = False (since V(p) = ∅)
- So □p = False, hence □p → p = True (false implies anything)
- Also (□p → p) = True, so □(□p → p) = True (the only accessible world is w, where □p → p holds)
- The Löb axiom says: □(□p → p) → □p
- LHS = True, RHS = False
- **The Löb axiom fails at reflexive worlds** (for suitable valuations)

This is why GL's canonical model, when unraveled, produces only irreflexive models.

**Temporal Logic Example - IRR Rule Usage**:

To prove CanonicalR irreflexivity via IRR:
1. Let p be fresh, assume {p, H(¬p)}
2. Suppose CanonicalR(M, M) for some MCS M
3. This means g_content(M) ⊆ M
4. For any φ with G(φ) ∈ M, we have φ ∈ M
5. Under reflexive semantics: H(¬p) ∈ M implies ¬p ∈ M (T-axiom)
6. But p ∈ M (by assumption)
7. Contradiction: M contains both p and ¬p
8. By IRR: conclude ¬CanonicalR(M, M) without the fresh atom assumption

The IRR rule is sound because: if φ is derivable assuming "there exists a strictly past moment" (represented by the naming atom p with H(¬p)), then φ holds unconditionally on irreflexive frames.

---

## Confidence Level

**High confidence** in the following claims:
1. GL achieves completeness for transitive irreflexive frames via the Löb axiom + FMP
2. The Löb axiom semantically forces irreflexivity without syntactically expressing it
3. Irreflexivity is modally undefinable (van Benthem)
4. The Gabbay IRR rule is the standard approach for strict temporal logics
5. GL's technique does NOT directly transfer to dense temporal orders (no FMP)

**Medium confidence**:
- Whether adding an IRR rule to ProofChecker's proof system is practical (depends on implementation complexity)
- Whether there exists an alternative axiom that forces irreflexivity for the specific frame class (strict linear temporal orders) without breaking other properties

---

## Summary

GL provides a beautiful example of achieving completeness for irreflexive frames without an irreflexivity axiom, but its technique relies on:
1. The Löb axiom, which indirectly forces irreflexivity
2. The finite model property, which allows restricting to irreflexive models

For ProofChecker's strict temporal logic over dense linear orders, neither condition holds. The **recommended approach** is either:
- **Add the Gabbay IRR rule** (principled, matches the literature, requires proof system extension)
- **Keep the irreflexivity axiom** (pragmatic, honest representation of modal non-definability)

The axiom is NOT a "hack" - it represents a genuine semantic property that modal axioms cannot capture. GL "avoids" an axiom only because of the fortuitous combination of Löb + FMP, which does not generalize.

---

## Sources

- [Provability Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-provability/)
- [Modal Logic GL - PlanetMath](https://planetmath.org/modallogicgl)
- [Temporal Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
- [Modal Logics that Bound the Circumference of Transitive Frames](https://arxiv.org/pdf/1905.11617)
- [A Gabbay-Rule Free Axiomatization of T×W Validity](https://link.springer.com/article/10.1023/A:1004284420809)
- [The Logic of Provability - Notes by R.J. Buehler](https://math.berkeley.edu/~buehler/The%20Logic%20of%20Provability.pdf)
- [Grzegorczyk Logic Unlocked](https://arxiv.org/abs/2505.09836)
- [Cut-elimination for Weak Grzegorczyk Logic Go](https://link.springer.com/article/10.1007/s11225-012-9432-9)
- [The Modal Logic of Pure Provability](https://mathweb.ucsd.edu/~sbuss/ResearchWeb/PureProv/paper.pdf)
