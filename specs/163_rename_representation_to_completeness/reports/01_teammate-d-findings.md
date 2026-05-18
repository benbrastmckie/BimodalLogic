# Teammate D (Horizons) — Strategic Alignment Findings

**Task**: 163 — Rename representation theorems to completeness / Jónsson-Tarski refactoring
**Date**: 2026-05-18
**Angle**: Strategic alignment with roadmap, task scoping, long-term positioning

---

## Key Findings

### 1. The Roadmap Already Plans This — and Sequences It After Completeness

The ROADMAP explicitly places J-T representation as **Phase 4**, after:
- Phase 1: Sorry-free `bx_completeness` (1 sorry remains on critical path)
- Phase 2: Frame hierarchy + axiom cleanup (tasks 126, 124, 115, 116)
- Phase 3: Expressive extensions (tasks 127, 128)

This sequencing is deliberate: the representation theorem for the BAO with binary S/U and unary □ (task 125) has formal dependencies on tasks 116 (remove G/H as primitives, redefine via U/S), 122 (discrete BFMCS), and 123/124 (interaction axioms). The roadmap says: "Builds on Venema 1993 (Anti-Axioms), leveraging orthodox axiomatizability for ultraproduct closure."

**Strategic implication**: Starting J-T representation now means working against the declared dependency order. The axiom set is still in flux (TF may be derived and removed in task 124; G/H may be redefined in task 116). Building the complex algebra on a moving target risks rework.

### 2. Three Related Tasks Exist — Consolidation Needed

| Task | Status | Scope |
|------|--------|-------|
| 163 | [RESEARCHING] | Rename "representation" to "completeness" (small) |
| 992 | [ABANDONED] | STSA representation theorem implementation |
| 125 | [NOT STARTED] | Full J-T representation for S/U/□ (15-25 hrs, formal dependencies) |

Task 992 was abandoned but produced a thorough research report (01_stsa-algebraic-analysis.md) that maps the entire algebraic translation of BX axioms and identifies ~80% of formalization already existing. Task 125 is the canonical task for representation work. Task 163 was created as a simple rename.

**Strategic recommendation**: Keep task 163 as the simple rename it was designed to be. Do NOT overload it with representation work. The user's research focus (J-T representation, prior art, refactoring) should inform a **revised description for task 125**, not inflate task 163.

### 3. J-T Representation Is a Genuine Differentiator for Publication

No existing Lean, Coq, or Isabelle formalization of modal logic includes a Jónsson-Tarski representation theorem. Obendrauf 2024 (Lean formalization of coalition logic, in `literature/`) does completeness via a canonical model but no algebraic representation. The standard approach in the mechanized modal logic literature stops at Henkin/canonical completeness.

A formalized J-T representation for a bimodal logic with Since/Until would be:
- **First of its kind** in any proof assistant
- **Algebraically significant**: it connects the syntactic algebra (Lindenbaum-Tarski) to the semantic algebra (complex algebra of frames), which is a purely structural result with no mention of provability
- **Publication-worthy on its own**: separate from the completeness story

However, the completeness work is the **foundation** for the publication. A sorry-free `bx_completeness` is the non-negotiable core. J-T representation is the "cherry on top" — valuable, distinguishing, but not blocking.

### 4. Current Algebraic Module: What to Keep, Rename, Archive

**Keep and rename** (completeness infrastructure):
| File | Lines | Sorries | Action |
|------|-------|---------|--------|
| `AlgebraicRepresentation.lean` | 191 | 0 | Rename to `AlgebraicCompleteness.lean`, rename theorems |
| `ParametricRepresentation.lean` | 300 | 0 | Rename to `ParametricCompleteness.lean`, rename theorems |
| `BooleanStructure.lean` | 447 | 0 | Keep (reusable for representation too) |
| `LindenbaumQuotient.lean` | 440 | 2 | Keep (shared foundation) |
| `UltrafilterMCS.lean` | 1053 | 0 | Keep (needed for both completeness and representation) |
| `ParametricTruthLemma.lean` | 531 | 0 | Keep (completeness infrastructure) |
| `RestrictedParametricTruthLemma.lean` | 475 | 0 | Keep (completeness infrastructure) |
| `ParametricCanonical.lean` | 244 | 0 | Keep (completeness infrastructure) |
| `ParametricHistory.lean` | 173 | 0 | Keep (completeness infrastructure) |

**Keep but will need extension for representation**:
| File | Lines | Sorries | Action |
|------|-------|---------|--------|
| `TenseS5Algebra.lean` | 365 | 3 | Keep — core STSA typeclass, will extend for Until/Since operators |
| `InteriorOperators.lean` | 191 | 1 | Keep — reusable for representation |

**Nothing to archive**: All 12 Algebraic files are either sorry-free completeness infrastructure or the STSA typeclass foundation. The 6 sorries (3 in TenseS5Algebra, 2 in LindenbaumQuotient, 1 in InteriorOperators) are all `temp_k_dist`/`temp_a`/`temp_l` stubs — derivable from BX axioms but not yet proved. These are engineering debt, not dead ends.

### 5. The 6 Algebraic Sorries Are a Risk for Both Rename and Representation

All 6 sorries involve axioms that were removed as primitives from the BX system. The comments say "temp_k_dist derivable from BX" and "temp_a removed in BX" and "temp_l removed in BX." These must be derived from the current axiom set. If the rename (task 163) touches these files, it should note these sorries as blockers for representation work. They should be resolved before or alongside any representation implementation.

### 6. Phased Approach to Representation (When the Time Comes)

For task 125, a natural decomposition:

**Phase 1** — Complex algebra construction: Define the complex algebra `Cm(F)` of a task frame `F`. For each frame operation (accessibility, temporal ordering, shift), define the corresponding Boolean operator on `P(W)`. Prove `Cm(F)` is an STSA. This is self-contained and testable.

**Phase 2** — Ultrafilter frame: Given an STSA `A`, construct the ultrafilter frame `Uf(A)`. Each ultrafilter of `A` becomes a world. Define temporal ordering and accessibility from the algebraic operators. Prove frame properties.

**Phase 3** — Embedding theorem: Prove the canonical embedding `η : A → Cm(Uf(A))` is an injective STSA morphism. This is the representation theorem proper.

**Phase 4** — Since/Until extension: Extend STSA with binary Until/Since operators (this is where Venema 1993 Anti-Axioms and GHV 2003 become critical). The key question is whether orthodox axiomatizability (no non-orthodox rules like IRR) guarantees that the canonical extension preserves the equations — which it does for TM since the BX system is purely equational (no IRR rule used).

### 7. Mathlib Integration Opportunity

Mathlib already has:
- `BooleanAlgebra` — the base structure
- `Ultrafilter` — used in `UltrafilterMCS.lean`
- `Order.BooleanAlgebra` — order-theoretic Boolean algebra operations
- No `BAO` or `InteriorAlgebra` typeclass yet

This means the STSA typeclass (already defined in `TenseS5Algebra.lean`) is the right abstraction level. A future contribution to Mathlib could be a general `InteriorAlgebra` or `BAO` typeclass, but that's out of scope.

### 8. Basic Tense Fragment First Is the Right Strategy

Proving representation for `{□, G, H}` first (without S/U) is strategically sound:
- The unary operator case is well-studied (standard BAO theory, Jónsson-Tarski 1951)
- The STSA typeclass already covers this fragment
- Binary operators (S/U) require the more delicate "relation algebraic" treatment from Venema 1993
- A working representation for the basic fragment validates the infrastructure before extending

---

## Recommended Approach

1. **Execute task 163 as originally scoped**: Rename "representation" to "completeness" in the 7 theorems, 4 call sites, 2 files, and update docstrings. This is a clean 1-2 hour task. Do not inflate it.

2. **Revise task 125's description** to incorporate the user's broader vision (refactoring Algebraic/ for genuine J-T representation). Mark task 992 as superseded by 125 if not already.

3. **Resolve the 6 Algebraic sorries** as a prerequisite task. These `temp_k_dist`/`temp_a`/`temp_l` derivations are needed regardless of which direction the Algebraic module takes.

4. **Defer representation implementation until Phase 2 of the roadmap** (frame hierarchy + axiom cleanup) is at least partially complete. Task 116 (redefine G/H via U/S) directly changes the algebraic signature the representation must respect.

5. **When ready, phase the representation**: Complex algebra → Ultrafilter frame → Embedding → S/U extension. Start with the basic `{□, G, H}` fragment.

6. **Archive nothing from Algebraic/** — all 12 files are either actively used or form the foundation for future representation work.

---

## Evidence/Examples

- ROADMAP Phase 4 explicitly sequences J-T after completeness, frame hierarchy, and expressive extensions
- Task 125 has formal dependencies on 116, 122, 123, 124 — none are completed
- Task 992 research report identifies ~80% of algebraic infrastructure already existing
- All 12 Algebraic files have zero or minimal sorries — no dead code to archive
- The 6 sorries are all "derivable from BX" stubs, not mathematical impossibilities
- Obendrauf 2024 (literature/) confirms no prior Lean formalization includes J-T representation

---

## Confidence Level

**High** on task scoping (keep 163 simple, use 125 for representation).
**High** on nothing needing archival in Algebraic/.
**Medium** on timing — the dependency argument is strong, but if the user's priority has shifted toward algebraic work over completing the last sorry, that's a valid strategic choice. The sorries in the algebraic module itself are small enough to resolve in parallel.
