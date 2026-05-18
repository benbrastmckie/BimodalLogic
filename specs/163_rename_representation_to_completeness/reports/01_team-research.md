# Research Report: Task #163

**Task**: Rename representation theorems to completeness in Algebraic module
**Date**: 2026-05-18
**Mode**: Team Research (4 teammates)
**Session**: sess_1779137275_b5dec8

## Summary

The current Algebraic/ module's "representation" theorems are correctly identified as completeness theorems (contrapositive Henkin: not provable implies countermodel exists). A genuine Jónsson-Tarski representation theorem — embedding an abstract STSA into the complex algebra of a frame — requires substantial new mathematical machinery but can leverage ~60% of existing infrastructure. The unanimous recommendation is to keep task 163 scoped as the simple rename, and channel the broader J-T representation work through task 125 (which has explicit roadmap dependencies). The literature collection is strong but has 3 critical gaps. No Algebraic/ files should be archived; one Boneyard file (UltrafilterChain.lean) should be recovered.

## Key Findings

### Primary Approach (from Teammate A)

**The diagnosis is unambiguous**: all current "representation" theorems are completeness. The key theorem `algebraic_representation_theorem` states `AlgSatisfiable φ ↔ AlgConsistent φ` — a syntactic-semantic bridge, not a structural algebraic result.

**A genuine J-T representation requires three new constructions:**

1. **Complex Algebra** (`S⁺`): Given a TaskFrame, form the powerset Boolean algebra `𝒫(WorldState)` with operators derived from frame relations (box from S5 accessibility, G/H from strict temporal ordering, U/S from the ternary Until/Since satisfaction conditions).

2. **Ultrafilter Frame** (`A₊`): Given an abstract STSA, construct a frame whose worlds are ultrafilters with canonical relations `R_G(U,V) = ∀a. G(a) ∈ U → a ∈ V` and `R_Box(U,V) = ∀a. □(a) ∈ U → a ∈ V`. The Boneyard file `StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` already defines exactly these relations for the specific Lindenbaum algebra — this code should be recovered and generalized.

3. **Representation Embedding**: The map `η(a) = {U ∈ Uf(A) | a ∈ U}` must be shown to be an injective STSA homomorphism preserving all operators.

**Recommended architecture**: Split Algebraic/ into `Core/` (shared: STSA typeclass, Lindenbaum quotient, Boolean structure, interior operators, ultrafilter machinery), `Completeness/` (renamed existing files), and `Representation/` (new: ComplexAlgebra, UltrafilterFrame, RepresentationEmbedding, FrameProperties).

**Reuse analysis**: TenseS5Algebra.lean (core), BooleanStructure.lean (shared), InteriorOperators.lean (shared), and UltrafilterMCS.lean (partial reuse) directly serve representation. The parametric completeness files need only renaming. Truth lemma infrastructure is shared.

### Alternative Approaches (from Teammate B)

**Literature survey**: The collection is strong with 6 algebraic BAO papers organized into Track B (Venema 2001 → Venema 1993 Anti-Axioms → de Rijke-Venema 1995 → Venema 1997 → GHV 2003 → Venema 1991). The README already identifies 3 critical missing papers.

**What the papers say about representation for tense logics:**

- **Venema 1991 Theorem A21**: `𝔉 ≅ At Cm 𝔉` — atom structures of complex algebras recover the frame (one half of J-T duality).
- **Venema 1997 Theorem 1.4**: For *conjugated* varieties (which includes tense operators since G/H are converses, and S/U have conjugate structure), all five desirable properties collapse: AO = AD = AC, and all conjugated varieties are atom-complex and atom-elementary.
- **de Rijke-Venema 1995 Theorem 3.5**: Sahlqvist varieties are canonical. All BX axioms (including S/U axioms A1–A7 and interaction axioms MF/TF/TA/TL) are Sahlqvist, so the STSA variety is canonical.
- **Venema 1993 Anti-Axioms**: Orthodox axiom systems (no IRR rule) ensure ultraproduct closure. The BX temporal fragment is orthodox.

**Key algebraic insight for S/U**: Since and Until are binary normal operators — additive in each argument when the other is fixed. They induce ternary canonical relations in the BAO framework. The complex algebra operation is `m_U(X,Y) = {t | ∃s>t: s∈X ∧ ∀u(t<u<s → u∈Y)}`. This is well-defined as a BAO operator because it distributes over unions in each argument separately.

**Three alternative approaches considered:**
- **A (Stone duality)**: More abstract, Mathlib has some Stone duality, but less constructive
- **B (Direct ultrafilter)**: Closest to existing code, well-understood
- **C (Parametric)**: The project's existing innovation — parametric over duration type D

**Recommended**: B+C hybrid. Keep the parametric innovation but make the algebraic embedding explicit.

### Gaps and Shortcomings (from Critic)

**8 concerns identified, 3 critical:**

1. **STSA typeclass is incomplete**: No Since/Until operators. For full TM representation, need binary `untl : α → α → α` and `sinc : α → α → α` with algebraic axioms. However, the basic {□, G, H} fragment is already complete.

2. **6 existing sorries block the STSA instance**: 3 in TenseS5Algebra.lean (`TA_quot`, `TL_quot`, `linearity_quot`), 1 in InteriorOperators.lean (`G_monotone`), 2 in LindenbaumQuotient.lean (`provEquiv_all_future_congr`). All stem from missing derivations (`temp_k_dist`, `temp_a`, `temp_l`). Any representation theorem building on STSA inherits these.

3. **Scope mismatch**: Task 163 is labeled "small" rename but user's research focus describes a major refactoring effort. Should spawn/revise a separate task.

**Linearity concern**: The algebraic linearity axiom `Fa ⊓ Fb ≤ F(a ⊓ b) ⊔ F(a ⊓ Fb) ⊔ F(Fa ⊓ b)` must be validated on the ultrafilter frame. GHV 2003 shows canonicity doesn't always imply elementary determination, BUT Wolter (2000) proved the converse of Fine's theorem holds for all normal extensions of linear tense logic.

**Nothing to archive**: All 12 Algebraic/ files serve either the completeness pipeline or the STSA foundation. The 6 sorries are engineering debt (derivable from BX), not dead ends.

### Strategic Horizons (from Horizons)

**Roadmap alignment**: The ROADMAP explicitly sequences J-T representation as Phase 4, after: Phase 1 (sorry-free `bx_completeness`), Phase 2 (frame hierarchy + axiom cleanup), Phase 3 (expressive extensions). Task 125 is the canonical task for this work, with dependencies on tasks 116, 122, 123, 124.

**Three related tasks exist:**
- Task 163: Simple rename (small, well-defined)
- Task 992: STSA representation (ABANDONED, but produced useful research report)
- Task 125: Full J-T representation for S/U/□ (15-25 hrs, formal dependencies)

**Publication positioning**: No existing Lean/Coq/Isabelle modal logic formalization includes a J-T representation theorem. This would be a genuine first and a strong publication differentiator — but the completeness story is the non-negotiable foundation. J-T representation is "cherry on top."

**Phased approach for task 125 (when ready):**
- Phase 1: Complex algebra (`Cm(F)` for TaskFrames)
- Phase 2: Ultrafilter frame (`Uf(A)` for abstract STSAs)
- Phase 3: Embedding theorem (`η : A ↪ Cm(Uf(A))`)
- Phase 4: Since/Until extension

**Start with basic tense fragment {□, G, H}** — validates infrastructure before the harder binary operator case.

## Synthesis

### Conflicts Resolved

**1. Since/Until normality (Teammate C vs. B)**

Teammate C claimed S/U are "NOT normal operators" and standard J-T doesn't apply. Teammate B provided the correct analysis: S/U *are* binary normal (additive) operators — they distribute over unions in each argument when the other is fixed, making them standard BAO operators with ternary canonical relations. Venema 1997 Theorem 1.4 confirms tense operators are conjugated, and de Rijke-Venema 1995 confirms all BX axioms are Sahlqvist. **Resolution**: Teammate B is correct. The standard BAO framework handles Since/Until via binary operators with ternary relations. The STSA typeclass needs extension (adding `untl`/`sinc` fields), but the mathematical theory is well-established. The "mixed quantifier structure" that concerned Teammate C is handled by the complex algebra definition: the guard universality is captured in the set-theoretic operation, and the resulting operator is still additive in each component.

**2. Architecture (Teammate A's 3-subdir vs. B's flat)**

Teammate A proposed `Core/`, `Completeness/`, `Representation/` subdirectories. Teammate B proposed a flatter structure with new files alongside existing ones. **Resolution**: The subdirectory approach (A) is better for this codebase — it cleanly separates the three concerns, mirrors the existing pattern of subdirectories in Metalogic/ (Bundle/, BXCanonical/, etc.), and makes the architectural intent explicit. However, this restructuring should happen as part of task 125, not task 163.

**3. Timing (now vs. roadmap Phase 4)**

Teammate D argues strongly for deferring to roadmap Phase 4. The user explicitly asked to research this now. **Resolution**: The *research* is timely and valuable — it clarifies what representation actually requires and informs task scoping. The *implementation* should follow the roadmap dependency order: resolve the 6 algebraic sorries → complete axiom cleanup (tasks 116, 124) → implement representation (task 125). Task 163 proceeds as the simple rename.

### Gaps Identified

1. **3 critical missing papers** (identified by both B and the existing README):
   - Jónsson & Tarski 1951/1952 (AJM 73:891–939, 74:127–162) — foundational
   - Blackburn, de Rijke & Venema 2001, Ch. 5 ("Algebras and General Frames") — textbook treatment
   - Goldblatt 1989 ("Varieties of Complex Algebras", APAL 44:173–242) — standard BAO reference

2. **6 algebraic sorries** from missing BX derivations (`temp_k_dist`, `temp_a`, `temp_l`). These block the Lindenbaum STSA instance and would propagate to any representation theorem.

3. **STSA typeclass needs Since/Until extension** for full representation. The basic {□, G, H} fragment is ready now.

4. **Duration type D construction** for the ultrafilter frame: how to construct a TaskFrame (with specific D) from an abstract STSA requires careful treatment. The parametric approach (already the project's innovation) may be the answer.

5. **Task 992 research artifacts** should be reviewed and incorporated into task 125's planning.

### Recommendations

**Immediate (task 163):**
1. Execute the simple rename as originally scoped: 7 theorem renames, 4 call site updates, 2 file renames, docstring updates
2. Do NOT restructure directories or add new files

**Near-term:**
3. Resolve the 6 algebraic sorries (derive `temp_k_dist`, `temp_a`, `temp_l` from BX axioms) — prerequisite for both completeness and representation
4. Obtain the 3 critical missing papers and add to `literature/`
5. Review task 992's research report (`01_stsa-algebraic-analysis.md`) for transferable insights
6. Revise task 125's description to incorporate this research

**Medium-term (task 125, after roadmap Phase 2):**
7. Implement representation in phases: Complex algebra → Ultrafilter frame → Embedding → S/U extension
8. Start with basic {□, G, H} fragment to validate infrastructure
9. Restructure Algebraic/ into Core/, Completeness/, Representation/ subdirectories
10. Recover `UltrafilterChain.lean` definitions from Boneyard, generalize for arbitrary STSAs

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: implementation architecture | completed | high |
| B | Alternatives: literature survey & methods | completed | high |
| C | Critic: gaps and feasibility | completed | high |
| D | Horizons: strategic alignment | completed | high |

## References

### In literature/ (directly relevant)
- Goldblatt, Hodkinson & Venema 2003 — BAOs and Modal Logic
- de Rijke & Venema 1995 — Sahlqvist theorem for BAOs
- Venema 1991 — Many-Dimensional Modal Logics (Ch. 2, App. A-B)
- Venema 1993 — Derivation Rules as Anti-Axioms (orthodox axiomatizability)
- Venema 1993 — Since and Until (orthodox axiomatization of S/U)
- Venema 1997 — Atom Structures and Sahlqvist Equations
- Venema 2001 — Temporal Logic Survey
- Burgess 1982 — Axioms for Tense Logic with Since and Until

### Missing (critical, should be obtained)
- Jónsson & Tarski 1951/1952 — Boolean Algebras with Operators I & II (AJM)
- Blackburn, de Rijke & Venema 2001 — Modal Logic, Ch. 5 (CUP)
- Goldblatt 1989 — Varieties of Complex Algebras (APAL)

### Supporting (already in literature/)
- Hodkinson & Reynolds 2006 — Temporal Logic Handbook Ch. 11
- Gabbay, Hodkinson & Reynolds 1994 — Temporal Logic Vol. 1 (Ch. 9, 10, 12)
- Thomason 1984 — Combinations of Tense and Modality
- Caleiro, Viganò & Volpe 2013 — Mosaic Method for Tense+Modal
