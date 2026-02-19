# Implementation Plan: Task #898

- **Task**: 898 - bilattice_structure_remarks_constitutive_foundation
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/898_bilattice_structure_remarks_constitutive_foundation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

This task improves the bilattice documentation in `02-ConstitutiveFoundation.tex` by: (1) adding formal definitions of interlaced and distributive bilattices with a theorem citing Fitting1990, and (2) restructuring the existing remarks to separate lub/glb content from non-interlacing content with counterexamples.

### Research Integration

- Formal definitions from IdentityAboutness.tex (lines 801-803) provide precise mathematical criteria
- Fitting1990 citation needs to be added to LogosReferences.bib
- Counterexamples from IdentityAboutness.tex (model M_D) demonstrate distributivity failure
- The lub/glb characterization establishes conjunction/disjunction as lattice operations

## Goals & Non-Goals

**Goals**:
- Add formal definitions of interlaced and distributive bilattices
- Add theorem that every distributive bilattice is interlaced (citing Fitting1990)
- Create new remark for lub/glb characterizations with common essence/ground
- Move non-interlacing discussion with counterexamples to new location
- Add Fitting1990 to bibliography

**Non-Goals**:
- Adding full computational details of M_D model verifier/falsifier sets
- Changing the main Definition 2.13 (Bilattice) structure
- Adding new theorems requiring proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Label conflicts with existing remarks | M | L | Check for cross-references before renaming |
| Notation inconsistency with IdentityAboutness | L | M | Translate all notation to ConstitutiveFoundation conventions |
| Citation style mismatch | L | L | Check existing citations in document for style |

## Implementation Phases

### Phase 1: Add Fitting1990 Citation to Bibliography [COMPLETED]

- **Dependencies**: None
- **Goal**: Add the Fitting1990 BibTeX entry to LogosReferences.bib

**Tasks**:
- [ ] Add Fitting1990 entry to /home/benjamin/Projects/Logos/Theory/latex/bibliography/LogosReferences.bib

**Timing**: 0.1 hours

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/latex/bibliography/LogosReferences.bib` - Add Fitting1990 entry

**BibTeX entry to add**:
```bibtex
@inproceedings{Fitting1990,
  author =        {Fitting, Melvin},
  booktitle =     {Proceedings of the Twentieth International Symposium on Multiple-Valued Logic, 1990},
  month =         may,
  pages =         {238--246},
  title =         {Bilattices in Logic Programming},
  year =          {1990},
}
```

**Verification**:
- Entry compiles without error when bibliography is processed

---

### Phase 2: Expand Definition 2.13 with Interlaced and Distributive Definitions [COMPLETED]

- **Dependencies**: Phase 1
- **Goal**: Add formal definitions of interlaced and distributive bilattices after the current informal definition, plus theorem citing Fitting1990

**Tasks**:
- [ ] Remove the TODO comment at line 649
- [ ] Replace the informal interlaced definition (lines 650-651) with formal definition
- [ ] Add formal definition of distributive bilattice
- [ ] Add remark that every distributive bilattice is interlaced with Fitting1990 citation

**Timing**: 0.5 hours

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 649-652

**Content to add** (replace lines 649-652):
```latex
A bilattice is \emph{interlaced} iff $(P \star R) \circ (Q \star R)$ whenever $P \circ Q$, where $\star \in \set{\land^\essence, \land^\ground, \lor^\essence, \lor^\ground}$ and $\circ \in \set{\essence, \ground}$.
Equivalently, each of the four lattice operations is order-preserving with respect to both orderings.

A bilattice is \emph{distributive} iff for any $\star, \ast \in \set{\land^\essence, \land^\ground, \lor^\essence, \lor^\ground}$:
\[P \star (Q \ast R) = (P \star Q) \ast (P \star R)\]
That is, all twelve possible distributive laws hold among the four lattice operations.
\end{definition}

\begin{remark}[Distributive Implies Interlaced]\label{rem:distributive-interlaced}
Every distributive bilattice is interlaced \citep{Fitting1990}.
The distributive laws imply that each lattice operation preserves both orderings.
\end{remark}
```

**Verification**:
- Document compiles without LaTeX errors
- Fitting1990 citation resolves correctly

---

### Phase 3: Create New LUB/GLB Remark [COMPLETED]

- **Dependencies**: Phase 2
- **Goal**: Create a new remark explaining conjunction/disjunction as lub and defining glb operations (common essence, common ground)

**Tasks**:
- [ ] Create new remark after rem:bilattice-orders (line 660)
- [ ] Include conjunction as lub wrt essence, disjunction as lub wrt ground
- [ ] Define common essence (glb wrt essence) and common ground (glb wrt ground)
- [ ] Explain the semantic significance of these identifications

**Timing**: 0.4 hours

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` - Insert after line 660

**Content to add**:
```latex
\begin{remark}[Lattice Operations and Bounds]\label{rem:bilattice-bounds}
The propositional operations correspond to lattice bounds in the bilattice:
\begin{itemize}
  \item Conjunction $P \land Q$ is the least upper bound with respect to $\essence$
  \item Disjunction $P \lor Q$ is the least upper bound with respect to $\ground$
  \item The \emph{common essence} $P \otimes Q$ is the greatest lower bound with respect to $\essence$
  \item The \emph{common ground} $P \oplus Q$ is the greatest lower bound with respect to $\ground$
\end{itemize}
These identifications establish that the syntactic operations on sentences induce the corresponding algebraic operations on propositions.
\end{remark}
```

**Verification**:
- Document compiles without LaTeX errors
- Remark label is unique and not conflicting

---

### Phase 4: Restructure Non-Interlacing Remark with Counterexamples [COMPLETED]

- **Dependencies**: Phase 3
- **Goal**: Move the non-interlacing content to follow the interlaced/distributive definitions and add counterexamples from IdentityAboutness.tex

**Tasks**:
- [ ] Remove TODO comment at line 663
- [ ] Rewrite rem:bilattice-structure to focus on non-interlacing of bilateral propositions
- [ ] Add counterexample model M_D description
- [ ] Add intuitive ball/colour/shape/metallic explanation
- [ ] Remove the now-redundant lub content (moved to Phase 3's remark)

**Timing**: 0.5 hours

**Files to modify**:
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 662-672

**Content to replace rem:bilattice-structure**:
```latex
\begin{remark}[Non-Interlacing of Bilateral Propositions]\label{rem:bilattice-non-interlacing}
The bilateral propositions form a \emph{non-interlaced} bilattice: the two orders need not interact uniformly.
The failure of interlacing reflects the hyperintensionality of the semantics, where giving up Boolean identities allows the two orders to diverge.

Moreover, the bilattice of bilateral propositions is not distributive.
Consider a model $\model_D$ with state space $\statespace_D = \powerset{\set{a,b,c,d,e,f}}$ where atomic sentences $p_1$, $p_2$, $p_3$ are interpreted as:
\begin{itemize}
  \item $\interp{p_1}_{\model_D} = (\set{a}, \set{b})$
  \item $\interp{p_2}_{\model_D} = (\set{c}, \set{d})$
  \item $\interp{p_3}_{\model_D} = (\set{e}, \set{f})$
\end{itemize}
One may verify that $\interp{p_1 \lor (p_2 \land p_3)}_{\model_D} \neq \interp{(p_1 \lor p_2) \land (p_1 \lor p_3)}_{\model_D}$: the verifier sets differ because the latter includes fusion states $\set{a,c}$ and $\set{a,e}$ that the former lacks.

Intuitively, if $\set{a}$ is the ball being black, $\set{c}$ is the ball being round, and $\set{e}$ is the ball being iron, then the fusion state $\set{a,c}$ (the ball being black and round) fails to exactly verify ``The ball is coloured or both shaped and metallic'' because the roundness is irrelevant to colour.
\end{remark}
```

**Verification**:
- Document compiles without LaTeX errors
- Counterexample notation matches document conventions
- Remark flows logically after the interlaced/distributive definitions

---

## Testing & Validation

- [ ] Document compiles with `pdflatex` without errors
- [ ] Bibliography compiles with `bibtex` without missing citation warnings
- [ ] Fitting1990 citation appears correctly in references
- [ ] All new remark labels are unique
- [ ] Mathematical notation is consistent with existing document style

## Artifacts & Outputs

- Modified: `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex`
- Modified: `/home/benjamin/Projects/Logos/Theory/latex/bibliography/LogosReferences.bib`

## Rollback/Contingency

If implementation fails or introduces errors:
1. Revert changes to `02-ConstitutiveFoundation.tex` using git
2. Revert changes to `LogosReferences.bib` using git
3. The original TODO comments remain as markers for future work
