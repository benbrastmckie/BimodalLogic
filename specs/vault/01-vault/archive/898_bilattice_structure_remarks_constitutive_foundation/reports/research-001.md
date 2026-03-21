# Research Report: Task #898

**Task**: 898 - bilattice_structure_remarks_constitutive_foundation
**Started**: 2026-02-18T12:00:00Z
**Completed**: 2026-02-18T12:30:00Z
**Effort**: Low-Medium
**Dependencies**: None
**Sources/Inputs**:
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex` (lines 641-672)
- `/home/benjamin/Philosophy/Papers/IdentityAboutness/IdentityAboutness.tex` (lines 745-814)
- Web search on bilattice theory
**Artifacts**:
- This report: `specs/898_bilattice_structure_remarks_constitutive_foundation/reports/research-001.md`
**Standards**: report-format.md

## Executive Summary

- Two TODO tags at lines 649 and 663 in `02-ConstitutiveFoundation.tex` require bilattice improvements
- First TODO (line 649): Expand definitions of interlaced and distributive bilattices, add theorem that every distributive bilattice is interlaced (citing Fitting1990)
- Second TODO (line 663): Create separate remark for conjunction/disjunction as lub/glb, move remaining content with counterexamples from IdentityAboutness.tex
- Source material in IdentityAboutness.tex provides formal definitions, theorem statement, and detailed counterexamples
- Fitting1990 citation needs to be added to LogosReferences.bib

## Context & Scope

### Current State of 02-ConstitutiveFoundation.tex

The bilattice-related content spans lines 641-672:

1. **Definition 2.13 (Bilattice)** (lines 641-652): Defines bilattice structure with essence and ground orders, involutive negation, and a brief definition of interlaced. Contains TODO at line 649.

2. **Remark (bilattice-orders)** (lines 654-660): Explains constitutive/explanatory readings of essence and ground orders.

3. **Remark (bilattice-structure)** (lines 662-672): Contains TODO at line 663, currently discusses conjunction as lub for essence, disjunction as lub for ground, and notes the failure of interlacing.

### TODO Tag Details

**TODO 1 (line 649)**:
```
% TODO: draw on /home/benjamin/Philosophy/Papers/IdentityAboutness/IdentityAboutness.tex (line 801-2)
% to carefully define interlaced and distributive, adding a remark that every distributive bilattice
% is interlaced with a citation to Fitting1990 given in line 806
```

**TODO 2 (line 663)**:
```
% TODO: turn the fact that conjunction is the lub wrt \essence, and disjunction is the lub with
% respect to \ground into its own remark which also provides the definitions of the glb for \essence
% and \ground, commenting on what these mean. In addition to creating a new remark along these lines,
% also move the remainder of this remark to just below the definition of interlaced that provides
% the counterexamples to interlaced and distributive given in /home/benjamin/Philosophy/Papers/IdentityAboutness/IdentityAboutness.tex
```

## Findings

### Formal Definitions from IdentityAboutness.tex

**Interlaced (line 801)**:
A bilattice B = (P, sqsubseteq, leq, neg) is *interlaced* iff (X star Z) circ (Y star Z) if X circ Y, where star is any of the four lattice operations {wedge^sqsubseteq, wedge^leq, vee^sqsubseteq, vee^leq} and circ is either ordering {leq, sqsubseteq}.

In plain terms: Each of the four operations (conjunction and disjunction for both orderings) is order-preserving with respect to both orderings.

**Distributive (lines 802-803)**:
A bilattice B = (P, sqsubseteq, leq, neg) is *distributive* iff whenever star, ast are among {wedge^sqsubseteq, wedge^leq, vee^sqsubseteq, vee^leq}, then X star (Y ast Z) = (X star Y) ast (X star Z).

In plain terms: All twelve possible distributive laws involving the four operations hold.

**Key Theorem (line 806)**:
Every distributive bilattice is interlaced. This is attributed to Fitting (1990). The logic is that the distributive laws imply the order-preservation requirement that defines interlacing.

### Fitting1990 Citation

From IdentityAboutness.bib (lines 559-574):
```bibtex
@inproceedings{Fitting1990,
  author =        {Fitting, Melvin},
  booktitle =     {Proceedings of the Twentieth International
                   Symposium on Multiple-Valued Logic, 1990},
  month =         may,
  pages =         {238--246},
  title =         {Bilattices in Logic Programming},
  year =          {1990},
}
```

### Counterexamples from IdentityAboutness.tex

**Model M_D** (lines 608-633): A counterexample to distributivity.

Setup: Let M_D = (S_D, subseteq, |cdot|_D) with S_D = P({a,b,c,d,e,f}) where:
- |p_1|_D = ({a}, {b})
- |p_2|_D = ({c}, {d})
- |p_3|_D = ({e}, {f})

For pairwise distinct a, b, c, d, e, f.

**Counterexample to #Dist1** (A vee (B wedge C) equiv (A vee B) wedge (A vee C)):
- |p_1 vee (p_2 wedge p_3)|_D = ({a, {c,e}, {a,c,e}}, {{b,d}, {b,f}, {b,d,f}})
- |(p_1 vee p_2) wedge (p_1 vee p_3)|_D = ({a, {a,c}, {a,e}, {c,e}, {a,c,e}}, {{b,d}, {b,f}, {b,d,f}})

The verifier sets differ: the second includes {a,c} and {a,e} which the first lacks.

**Counterexample to #Dist2** (A wedge (B vee C) equiv (A wedge B) vee (A wedge C)):
- |p_1 wedge (p_2 vee p_3)|_D = ({{a,c}, {a,e}, {a,c,e}}, {b, {d,f}, {b,d,f}})
- |(p_1 wedge p_2) vee (p_1 wedge p_3)|_D = ({{a,c}, {a,e}, {a,c,e}}, {b, {b,d}, {b,f}, {d,f}, {b,d,f}})

The falsifier sets differ: the second includes {b,d} and {b,f} which the first lacks.

**Intuitive Reading** (lines 627-633): The counterexample can be understood with:
- {a} = the ball being black
- {c} = the ball being round
- {e} = the ball being iron
- p_1 = "The ball is coloured"
- p_2 = "The ball is shaped"
- p_3 = "The ball is metallic"

The fusion state {a,c} (ball being black and round) fails to exactly verify "The ball is coloured or both shaped and metallic" because {c} is irrelevant to colour.

### LUB/GLB for Essence and Ground

From IdentityAboutness.tex (line 778):
> "We may show that X wedge Y and X vee Y are the least upper bounds of X,Y in P_s with respect to sqsubseteq and leq, specifying clear theoretical roles for the semantics analogues of conjunction and disjunction to play within any bilattice of propositions B_s."

The current ConstitutiveFoundation.tex already has:
- Conjunction = lub with respect to essence
- Disjunction = lub with respect to ground

For the **glb** operators, they are referred to as "common essence" and "common ground" (footnote in IdentityAboutness.tex line 778):
> "One may also consider operators otimes and oplus for the greatest lower bounds with respect to sqsubseteq and leq, referring to these as *common essence* and *common ground*, respectively."

## Recommendations

### Implementation Structure

**Step 1**: Expand Definition 2.13 (Bilattice) at line 641-652

Add after line 651:
- Formal definition of interlaced (drawing from IdentityAboutness line 801)
- Formal definition of distributive (drawing from IdentityAboutness lines 802-803)
- Remark stating every distributive bilattice is interlaced, citing Fitting1990

**Step 2**: Add Fitting1990 to LogosReferences.bib

Copy the BibTeX entry from IdentityAboutness.bib.

**Step 3**: Create new Remark for LUB/GLB properties

Before the current Remark at line 662, create a new remark covering:
- Conjunction as lub wrt essence
- Disjunction as lub wrt ground
- Define glb operators (common essence, common ground)
- Explain their meanings

**Step 4**: Move counterexample content

The current content at lines 664-671 about non-interlacing should be moved/expanded:
- Place after the interlaced/distributive definitions
- Add the formal counterexamples from IdentityAboutness (M_D model)
- Include the intuitive ball example

### Suggested LaTeX Content

**For interlaced/distributive definitions**:
```latex
\begin{definition}[Interlaced Bilattice]\label{def:interlaced-bilattice}
A bilattice $\g{B}=\tuple{\g{P},\essence,\ground,\neg}$ is \emph{interlaced} iff
$(P \star R) \circ (Q \star R)$ whenever $P \circ Q$, where
$\star \in \set{\land^\essence, \land^\ground, \lor^\essence, \lor^\ground}$
and $\circ \in \set{\essence, \ground}$.
Equivalently, each of the four lattice operations is order-preserving with respect to both orderings.
\end{definition}

\begin{definition}[Distributive Bilattice]\label{def:distributive-bilattice}
A bilattice $\g{B}=\tuple{\g{P},\essence,\ground,\neg}$ is \emph{distributive} iff
for any $\star, \ast \in \set{\land^\essence, \land^\ground, \lor^\essence, \lor^\ground}$:
\[P \star (Q \ast R) = (P \star Q) \ast (P \star R)\]
That is, all twelve possible distributive laws hold.
\end{definition}

\begin{remark}
Every distributive bilattice is interlaced \citep{Fitting1990}. The distributive laws imply
that each lattice operation preserves both orderings.
\end{remark}
```

**For lub/glb remark**:
```latex
\begin{remark}[Lattice Operations and Bounds]\label{rem:bilattice-bounds}
The propositional operations correspond to lattice bounds:
\begin{itemize}
  \item Conjunction $P \land Q$ is the least upper bound with respect to $\essence$
  \item Disjunction $P \lor Q$ is the least upper bound with respect to $\ground$
  \item The \emph{common essence} $P \otimes Q$ is the greatest lower bound with respect to $\essence$
  \item The \emph{common ground} $P \oplus Q$ is the greatest lower bound with respect to $\ground$
\end{itemize}
These identifications establish that the syntactic operations on sentences
induce the corresponding algebraic operations on propositions.
\end{remark}
```

## Decisions

1. **Citation style**: Use `\citep{Fitting1990}` consistent with natbib, though the current file shows no citations. If citations are not yet set up, may need `\citet` or plain `\cite`.

2. **Notation**: Use the existing notation from ConstitutiveFoundation.tex (`\essence`, `\ground`, `\land`, `\lor`) rather than the `\sqsubseteq`, `\leq` notation from IdentityAboutness.tex.

3. **Counterexample detail level**: Include the formal M_D model and the intuitive ball example, but not all the computational details of exact verifier/falsifier sets.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Fitting1990 citation not in bibliography | Add entry to LogosReferences.bib before using |
| Notation inconsistency with IdentityAboutness | Translate all notation to ConstitutiveFoundation conventions |
| Remark restructuring may disrupt numbering | Check for cross-references to existing remark labels |

## Appendix

### Search Queries Used
- "Melvin Fitting 1990 bilattice distributive interlaced theorem"
- "every distributive bilattice is interlaced" theorem proof
- "bilattice definition interlaced distributive Fitting Avron"

### Key Sources
- [The structure of interlaced bilattices (Cambridge Core)](https://www.cambridge.org/core/journals/mathematical-structures-in-computer-science/article/abs/structure-of-interlaced-bilattices/B4134AFCB598A5DA8413FF14D9BC0A83)
- [The logic of distributive bilattices (ResearchGate)](https://www.researchgate.net/publication/220245194_The_logic_of_distributive_bilattices)
- [Fitting's paper on bilattices in logic programming (1990)](https://philpapers.org/rec/FITBAT)

### Files Examined
- `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex`
- `/home/benjamin/Philosophy/Papers/IdentityAboutness/IdentityAboutness.tex`
- `/home/benjamin/Philosophy/Papers/IdentityAboutness/IdentityAboutness.bib`
- `/home/benjamin/Projects/Logos/Theory/latex/bibliography/LogosReferences.bib`
