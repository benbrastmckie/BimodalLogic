# Teammate C (Critic) Findings: Task 158

**Task**: Update README.md to reflect metalogic progress and improve organization
**Date**: 2026-05-17
**Angle**: Gaps, blind spots, and assumption validation

## Key Findings

### 1. Missing Operators in README

The current README lists only 6 operators (Box, Diamond, H, G, P, F) but **omits Until (U) and Since (S)**, which are core primitives defined in `Formula.lean` as `untl` and `snce`. These are arguably the most distinctive operators in the logic — they distinguish it from a plain tense S5 system. The Axioms.lean file lists 24+ BX axioms specifically for Until/Since. This omission significantly misrepresents the logic's expressive power.

### 2. Paper URL Inconsistency

Two different URLs for the same paper appear in the README:
- Line 5: `https://benbrastmckie.com/wp-content/uploads/2026/05/possible_worlds.pdf`
- Line 163: `https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf`

The first has a 2026 date in the URL path (future-dated?), while the text says "(Brast-McKie, 2025)". These must be reconciled.

### 3. Package Name is "Logos" — Not Reflected in README

The `lakefile.lean` declares `package Logos`, directly confirming the project's relationship to Logos Laboratories. The current README never mentions this. The rewrite should prominently note that the package is named "Logos" and explain the relationship.

### 4. Codebase Size is Stale

Current README claims: 162 Lean files, ~30,000 lines of code, ~24,000 comments.
Actual (cloc): **189 Lean files, ~42,700 lines of code, ~28,400 comments**. This is a 42% increase in code that needs updating.

### 5. Sorry Status Nuances

The sorry picture is more nuanced than "complete":
- **Soundness**: 0 sorry tactics (truly sorry-free) across all three variants (general, dense, discrete)
- **Completeness (base, Completeness.lean)**: 0 sorry tactics
- **Completeness (BX extension, BXCanonical/Completeness.lean)**: 0 sorry tactics in file, BUT `bx_completeness` depends on `sorryAx` axiom through `dd_countermodel_chronicle` chain (1 critical-path sorry in `ChronicleToCountermodel.lean:1885` — `succ_cofinal`)
- **Decidability**: 0 sorry tactics (genuinely sorry-free)
- **ConservativeExtension**: 39 sorry mentions (handles axioms removed in BX)

The README should be transparent about which results are fully verified vs. which have remaining dependencies on `sorryAx`.

### 6. "Task Semantics" Terminology

"Task semantics" / "task frame" / "task relation" is project-specific terminology, not standard in the temporal logic literature. The paper reference in `TaskFrame.lean` calls it "The Perpetuity Calculus of Agency" which uses these terms. Standard literature would say "Kripke frame" or "birelational frame." The README should make clear this is the project's own terminology (defined in the companion paper) rather than implying it's standard.

### 7. Mermaid Diagram Feasibility

GitHub has supported mermaid diagrams in Markdown since February 2022. A diagram showing the logic extension hierarchy is appropriate. Recommended structure:
```
Base TM → Dense Extension (+ density axiom)
Base TM → Discrete Extension (+ discreteness axioms)
Base TM → BX Extension (Burgess-Xu complete axiomatization)
```
Risk: Complex mermaid diagrams can render poorly on small screens. Keep it simple — a directed graph with 4-5 nodes maximum.

### 8. Examples/ Directory Sorry Count

The Examples/ directory has significant sorry counts:
- `TemporalProofs.lean`: 25 sorries
- `TemporalProofStrategies.lean`: 18 sorries  
- `ModalProofs.lean`: 5 sorries
- `ModalProofStrategies.lean`: 5 sorries
- `Demo.lean`: 2 sorries (one in completeness direction)

If the user wants to remove these or stop linking to them from the README, that's reasonable. They represent a teaching-resource legacy. However, `Demo.lean` is still linked as the primary demo — any replacement should be identified.

## Gaps Identified

### A. No Badges
The README lacks GitHub badges (build status, Lean version, license). Comparable Lean 4 projects (mathlib4) use badges for build status and Lean version.

### B. No "Intensional" Explanation  
The user wants to describe this as the "intensional bimodal fragment" — but the current README never explains what "intensional" means in this context or why it matters. This should be briefly explained (compositional possible-worlds semantics vs. extensional/truth-functional approaches).

### C. Redundant Installation Instructions
Installation instructions appear twice: once in the "Installation" section and again verbatim in "Contributing > Development Setup." The rewrite should eliminate this duplication.

### D. Documentation Section Links Not Verified for Quality
All 20+ documentation links exist on disk, but their quality and currency is unknown. Some may be stale or beginner-oriented (e.g., USING_GIT.md is 453 lines of "What is GitHub?" content).

### E. Missing: What the Logic Can Express
No examples of what formulas or theorems the logic proves. A short formula example (e.g., perpetuity principle P1: □φ → Gφ) would make the logic concrete for readers.

### F. BimodalReference.pdf Accessibility
The PDF specification is checked into the repo but not hosted anywhere accessible without cloning. Consider whether GitHub renders it or if a link to an online version would be better.

## Risks

1. **Overclaiming completeness**: The README currently says "Complete" for Metalogic, but BX completeness still depends on `sorryAx`. The rewrite must accurately represent this — perhaps "Completeness proven for dense frames; discrete case has 1 remaining sorry on critical path."

2. **Stale links**: The paper URL with 2026 date is suspicious and may break. Verify which URL is canonical.

3. **Mermaid diagram complexity**: If the extension hierarchy is too complex, the diagram will be unreadable. Keep to ≤5 nodes.

4. **Removing Examples/ from README**: If examples with sorries are no-go, there needs to be an alternative entry point for new users exploring the codebase.

5. **"Intensional" terminology**: Could confuse readers who expect "intensional logic" in the Montague/Church sense. Brief clarification needed.

## Confidence Level

**High** — All findings are based on direct codebase inspection. The sorry audit, codebase metrics, and file existence checks are factual. The mermaid diagram assessment is based on known GitHub rendering capabilities.
