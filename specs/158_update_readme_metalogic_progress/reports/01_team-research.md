# Research Report: Task #158

**Task**: Update README.md to reflect metalogic progress and improve organization
**Date**: 2026-05-17
**Mode**: Team Research (4 teammates)

## Summary

The README.md is significantly outdated and misrepresents the project's current scope. The codebase has grown 42% (from ~30K to ~43K LOC), major metalogical results (soundness, completeness, decidability) are formalized across three frame classes, and the project has matured from a teaching resource into a publication-quality formalization. The README omits Until/Since operators, never mentions Logos Laboratories, has stale statistics, inconsistent paper URLs, and links to sorry-laden example files. A comprehensive rewrite with cleanup of pedagogical artifacts is needed.

## Key Findings

### 1. Codebase Statistics Are Stale (All teammates agree)

| Metric | README (stale) | Actual | Change |
|--------|---------------|--------|--------|
| Lean files | 162 | **189** | +17% |
| Lines of code | ~30,000 | **~42,700** | +42% |
| Comment lines | ~24,000 | **~28,400** | +18% |

### 2. Operators Missing from README

The current README omits the two most distinctive operators — **Until (U)** and **Since (S)** — which are primitive constructors in `Formula.lean` (`untl`, `snce`). These are the "BX" in the Burgess-Xu axiomatization and have 24 dedicated axioms. The complete operator set:

**Primitive**: `atom`, `bot` (⊥), `imp` (→), `box` (□), `all_past` (H), `all_future` (G), `untl` (U), `snce` (S)

**Derived**: `neg` (¬), `and` (∧), `or` (∨), `diamond` (◇), `some_past` (P), `some_future` (F), `always` (△ perpetuity), `sometimes` (▽), `next` (X), `prev` (Y)

### 3. Logos Connection Missing

The `lakefile.lean` declares `package Logos`, and `docs/research/bimodal-logic.md` already contains a "Logos Connection" paragraph that should be moved to the README intro:

> "Bimodal logic is a fragment of the **Logos**, a formal language of thought designed to enable AI systems to reason with mathematical certainty."

Link: https://logos-labs.ai/

### 4. Frame Class Hierarchy — Central Organizing Principle

The metalogic is structured around a 3-tier frame hierarchy (all teammates converge on this as the natural mermaid diagram structure):

```
LinearTemporalFrame (AddCommGroup + LinearOrder + IsOrderedAddMonoid)
        |
   SerialFrame (+ Nontrivial + NoMaxOrder + NoMinOrder)
      /    \
DenseTemporalFrame          DiscreteTemporalFrame
(+ DenselyOrdered)          (+ SuccOrder + PredOrder + IsSuccArchimedean)
```

### 5. Metalogical Results by Frame Class

**Base (all serial linear orders)**:
- Soundness: sorry-free, axiom-free
- Completeness (FMP): sorry-free, axiom-free
- Decidability: sorry-free, axiom-free (tableau-based)
- Deduction Theorem: fully proven
- Finite Model Property: proven with 2^|closure(φ)| bound
- Perpetuity Principles P1-P6: all proven

**Dense (dense linear orders, e.g. ℚ)**:
- Soundness: sorry-free (density axiom DN = Fφ → FFφ)
- Completeness: sorry-free (`dd_countermodel_chronicle_dense`)

**Discrete (discrete linear orders, e.g. ℤ)**:
- Soundness: sorry-free (Prior-UZ/SZ + Z1 axioms)
- Completeness: 1 root sorry remaining (`succ_cofinal` in `ChronicleToCountermodel.lean:1885`)

**Note** (from Critic): `bx_completeness` depends on `sorryAx` through the `succ_cofinal` dependency. The README must be transparent — say "1 sorry remaining on the discrete completeness critical path" rather than overclaiming full completeness.

### 6. "Task Semantics" Is Project-Specific Terminology

Critic flagged that "task semantics" / "task frame" / "task relation" is not standard temporal logic terminology. Standard literature uses "Kripke frame" or "birelational frame." The README should briefly explain that this terminology comes from the companion paper (Brast-McKie 2025) and relates to non-deterministic dynamical systems / compositional possible-worlds semantics.

### 7. Axiom System

44 axiom constructors in 7 layers (from Teammate A's detailed analysis):
1. Propositional (4): K, S, ex falso, Peirce
2. S5 Modal (5): T, 4, B, 5-collapse, K-distribution
3. BX Temporal (24): 12 future/past pairs for Until/Since
4. Modal-Temporal Interaction (1): □φ → □Gφ
5. Uniformity (5): discrete symmetry, propagation, box necessity
6. Prior (2): prior-UZ, prior-SZ
7. Z1 (1): successor Archimedean characteristic

7 inference rules: axiom, assumption, modus ponens, necessitation, temporal necessitation, temporal duality, weakening.

### 8. Paper URL Inconsistency

Two URLs appear in the current README (Critic finding):
- `https://benbrastmckie.com/wp-content/uploads/2026/05/possible_worlds.pdf`
- `https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf`

These must be reconciled to a single canonical URL.

### 9. Literature for Citation Section

Core references to cite (from Teammates A, B, D):

1. **Brast-McKie (2025)** — "The Construction of Possible Worlds" — task semantics, perpetuity calculus
2. **Burgess (1982)** — "Axioms for tense logic: Since and Until" — original BX axiomatization
3. **Xu (1988)** — "On some U,S-tense logics" — completeness extension
4. **Reynolds (1994)** — "Axiomatising U and S over integer time" — discrete pipeline
5. **Venema (1993)** — "Since and Until" — extensions to strict/discrete time
6. **Gabbay, Hodkinson & Reynolds (1994)** — *Temporal Logic: Mathematical Foundations* Vol. 1
7. **Blackburn, de Rijke, Venema (2002)** — *Modal Logic* — canonical model theory
8. **Doets (1987/89)** — Monadic FO framework for completeness

## Cleanup Targets

### Files to Remove

**Examples with sorries** (6 files, ~65 sorries total):
- `Theories/Bimodal/Examples/TemporalProofs.lean` (25-30 sorries)
- `Theories/Bimodal/Examples/TemporalProofStrategies.lean` (18-19 sorries)
- `Theories/Bimodal/Examples/ModalProofs.lean` (5 sorries)
- `Theories/Bimodal/Examples/ModalProofStrategies.lean` (5 sorries)
- `Theories/Bimodal/Examples/BimodalProofStrategies.lean` (2 sorries)
- `Theories/Bimodal/Examples/Demo.lean` (2-4 sorries — currently linked from README)

**Keep**: `BimodalProofs.lean` (0 sorries), `TemporalStructures.lean` (0 sorries)

**Pedagogical docs to remove**:
- `docs/installation/USING_GIT.md` — 453 lines of "What is GitHub?"
- `docs/installation/GETTING_STARTED.md` — terminal basics, VS Code setup
- `docs/installation/CLAUDE_CODE.md` — AI-specific install guide
- `docs/tts-stt-integration.md` — completely unrelated (TTS/STT for Neovim)

**Docs to demote** (keep in docs/ but don't link from README):
- `docs/development/DOC_QUALITY_CHECKLIST.md`
- `docs/development/PHASED_IMPLEMENTATION.md`
- `docs/project-info/MAINTENANCE.md`
- `docs/bfmcs-architecture.md` (outdated sorry counts)

### CI Badge

`.github/workflows/ci.yml` exists with `leanprover/lean-action@v1` but no badge in README. Add:
```
![CI](https://github.com/benbrastmckie/ProofChecker/actions/workflows/ci.yml/badge.svg)
```

## Synthesis

### Conflicts Resolved

1. **Sorry count in Demo.lean**: Teammates report 2-4 sorries. Both counts may be valid depending on whether `sorry` in comments/strings is counted. Resolution: the file has sorries regardless — recommend removal or fix.

2. **Axiom count**: Teammate A reports 44 total axiom constructors; Teammate B says "17 base axioms" and Teammate D says "34 base axioms." Resolution: The 44 total is correct (from detailed Axioms.lean inspection). The "34 base" count likely excludes the 5 uniformity + 2 Prior + 1 Z1 extension-specific axioms. For the README, present the base system separately from extension-specific axioms.

3. **Mermaid diagram**: Teammates propose 3-5 node diagrams with varying detail. Resolution: Use a clean 3-node diagram (Base → Dense, Base → Discrete) with result status annotations. Keep it simple per Critic's advice (≤5 nodes for mobile readability).

4. **README section ordering**: All teammates propose similar orderings with minor variations. Synthesized order below.

### Gaps Identified

1. **"Intensional" explanation**: The user wants to call this the "intensional bimodal fragment" but no teammate addressed what "intensional" means in this context. The README should briefly explain compositional possible-worlds semantics vs. extensional/truth-functional approaches.

2. **Demo replacement**: If Demo.lean is removed, what replaces it as the entry point? `BimodalProofs.lean` is sorry-free but may not be as demonstrative. Consider whether to fix Demo.lean or point to BimodalProofs.lean.

3. **BimodalReference.pdf accessibility**: The specification PDF is checked into the repo but not hosted online. Consider whether to link to it or host it separately.

### Recommendations

**Recommended README Section Order**:
1. Title + CI badge + one-sentence description
2. Logos context paragraph (intensional bimodal fragment, link to Logos Labs)
3. Paper link + demo link + specification link
4. Codebase size table (end of intro area, as user requested)
5. Operators table (complete, including U/S/△/▽)
6. Task Frame Semantics (brief paragraph, explain terminology)
7. Project Structure (updated directory tree, highlight Metalogic/)
8. Installation (streamlined: elan + lake build)
9. Metalogical Results (mermaid diagram + results table per frame class, honest about 1 sorry)
10. Documentation (curated links only — no beginner guides)
11. Related Projects (ModelChecker + Logos Labs)
12. Citation (BibTeX for paper + software, key literature references)
13. License

**Audience** (from Horizons): Primary = formal methods researchers; Secondary = logic/philosophy researchers; Tertiary = Lean 4 developers. The README should NOT target students learning Git basics.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary (structure, operators, metalogic) | completed | high |
| B | Alternatives (cleanup, literature, docs audit) | completed | high |
| C | Critic (gaps, assumptions, sorry nuances) | completed | high |
| D | Horizons (positioning, audience, strategy) | completed | high |

## References

- Burgess, J.P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." Notre Dame J. Formal Logic, 23(4), 367-374.
- Xu, M. (1988). "On some U,S-tense logics." J. Philosophical Logic, 17(2), 181-202.
- Brast-McKie, B. (2025). "The Construction of Possible Worlds."
- Reynolds, M. (1994). "Axiomatising U and S over integer time." Advances in Modal Logic.
- Venema, Y. (1993). "Since and Until." Advances in Modal Logic.
- Gabbay, D., Hodkinson, I., & Reynolds, M. (1994). Temporal Logic: Mathematical Foundations and Computational Aspects, Vol. 1.
- Blackburn, P., de Rijke, M., & Venema, Y. (2002). Modal Logic. Cambridge University Press.
- Doets, K. (1987). Completeness and Definability: Applications of the Ehrenfeucht Game in Second-Order and Intensional Logic.
