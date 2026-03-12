# Research Report: Task #960

**Task**: 960 - Refactor documentation for bimodal Logos fragment
**Started**: 2026-03-12T00:00:00Z
**Completed**: 2026-03-12T00:30:00Z
**Effort**: Medium (3-5 hours for implementation)
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, WebFetch (logos-labs.ai)
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The repository currently frames the project as "Logos: A Logic for Interpreted and Verified AI Reasoning" with Bimodal as a fragment
- The Theories/Logos/ directory does NOT exist - only Theories/Bimodal/ exists with complete implementation
- Documentation references non-existent Logos paths (Theories/Logos/docs/, Theories/Logos/README.md, etc.)
- The primary paper link https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf ("The Construction of Possible Worlds") should be featured prominently
- The Logos website (logos-labs.ai) describes it as "a formal language of thought that enables AI systems to reason with mathematical certainty"
- Recommended approach: Reframe as "Bimodal Logic: TM for Tense and Modality" with Logos as the broader research context

## Context & Scope

### Task Description
Refactor README.md and documentation throughout this repository to:
1. Focus on the bimodal logic for tense and modality as the primary subject
2. Link to the paper https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf
3. Link to https://logos-labs.ai/ with brief explanation of the Logos
4. Move Logos-specific documentation to /home/benjamin/Projects/Logos/Theory/docs/boneyard/

### Constraints
- Keep Logos mentions brief - indicate what it is and provide a link
- Do not delete Logos-specific content - move to boneyard for later integration
- Focus the repository narrative on what is actually implemented (bimodal logic)

## Findings

### 1. Current Documentation State

#### Root README.md
- **Title**: "Logos: A Logic for Interpreted and Verified AI Reasoning"
- **Framing**: Positions Logos as the main project with Bimodal as a "fragment"
- **Issues**:
  - References non-existent paths: `Theories/Logos/docs/research/conceptual-engineering.md`, `Theories/Logos/docs/research/layer-extensions.md`, `Theories/Logos/latex/LogosReference.pdf`, `Theories/Logos/docs/reference/GLOSSARY.md`
  - Contains extensive Logos architecture diagrams (Constitutive Foundation, Dynamical Foundation, Extensions)
  - Discusses RL Training in context of Logos (this is forward-looking, not current implementation)

#### docs/README.md
- References Logos/docs/ which does not exist
- Contains table linking to non-existent Logos documentation

#### docs/research/bimodal-logic.md
- Good standalone document about Bimodal
- References `../../Theories/Logos/README.md` which does not exist

#### Theories/Bimodal/README.md
- Well-documented, accurate, production-ready
- Correctly describes what is implemented
- Should serve as model for project-level README

### 2. Directory Structure Analysis

**Existing Directories**:
```
Theories/
  Bimodal/           # EXISTS - Complete implementation
    Metalogic/
    Theorems/
    Automation/
    docs/            # Bimodal-specific docs
    latex/
    Semantics/
    Examples/
    Syntax/
    ProofSystem/
    Boneyard/
    typst/
```

**Non-Existent Directories Referenced**:
```
Theories/Logos/      # DOES NOT EXIST
  docs/
  SubTheories/
  latex/
```

### 3. Content to Move to Boneyard

The following content in the root README.md should be moved to `/home/benjamin/Projects/Logos/Theory/docs/boneyard/`:

1. **Logos Architecture Section** (lines 13-76): The layer extension diagram and descriptions
2. **Application Domains Section** (lines 138-167): Medical Planning, Legal Reasoning, Multi-Agent Coordination examples
3. **RL Training Section** (lines 103-121): Dual verification training context
4. **Motivations Section** (lines 124-135): Extensive Logos-specific planning rationale

**Note**: The boneyard directory exists at `/home/benjamin/Projects/Logos/Theory/docs/boneyard/` with an empty README.md

### 4. External Resources

#### Paper: "The Construction of Possible Worlds" (Brast-McKie, 2025)
- URL: https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf
- PDF format (WebFetch could not extract text)
- Already referenced in README at line 297
- Should be featured more prominently as the primary theoretical reference

#### Logos Website
- URL: https://logos-labs.ai/
- Description extracted: "The Logos is a formal language of thought that enables AI systems to reason with mathematical certainty. It functions as a formal logic system designed to generate verified synthetic reasoning data of arbitrary complexity, allowing AI to construct explicit semantic models of the world and draw inferences through abductive, deductive, and inductive reasoning."

### 5. Files Requiring Updates

| File | Action | Notes |
|------|--------|-------|
| `README.md` | Major rewrite | Reframe as Bimodal project, move Logos content to boneyard |
| `docs/README.md` | Update | Remove Logos references, update as docs hub for Bimodal |
| `docs/research/bimodal-logic.md` | Minor updates | Fix broken Logos links, make standalone |
| `docs/research/README.md` | Update | Remove Logos research references |
| `docs/user-guide/README.md` | Update | Remove Logos quick start references |
| `docs/reference/README.md` | Update | Remove Logos glossary/axiom references |
| `docs/project-info/README.md` | Update | Remove Logos status references |
| `Theories/README.md` | Update | Remove Logos section |

### 6. Proposed New README Structure

```markdown
# Bimodal Logic: Tense and Modality (TM)

A Lean 4 implementation of bimodal logic combining S5 modal and linear temporal
operators with verified soundness and completeness proofs.

**Paper**: ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) (Brast-McKie, 2025)

**Specifications**: [BimodalReference](Theories/Bimodal/latex/BimodalReference.pdf)

**Demo**: [Interactive Demo](Theories/Bimodal/Examples/Demo.lean)

---

## Overview

[Brief description of bimodal logic and what this codebase implements]

## The Logos Connection

This codebase implements the bimodal fragment of the [Logos](https://logos-labs.ai/),
a formal language of thought designed to enable AI systems to reason with mathematical
certainty. The Logos aims to generate verified synthetic reasoning data for training
AI systems, combining proof theory with recursive semantics for interpreted and
verified reasoning.

The bimodal fragment captures the fundamental relationship between time and modality,
providing a complete propositional intensional logic that serves as a foundational
component for more expressive extensions.

[Rest of README focused on bimodal implementation...]
```

## Decisions

1. **Reframe project identity**: Change from "Logos project with Bimodal fragment" to "Bimodal Logic project that is a fragment of the Logos"
2. **Relocate Logos content**: Move detailed Logos architecture and planning content to boneyard, not delete
3. **Feature paper prominently**: Make the "Construction of Possible Worlds" paper the primary external reference
4. **Brief Logos explanation**: Include 2-3 sentences about what the Logos is, with link to logos-labs.ai
5. **Fix broken links**: Remove or redirect all references to non-existent Theories/Logos/ paths

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Broken links after refactor | Create comprehensive link inventory before changes, verify all links after |
| Lost valuable Logos content | Move to boneyard rather than delete; create clear migration record |
| Confusion about project scope | Clear "Logos Connection" section explaining relationship |
| Search/discovery issues | Update README title/description for accurate discoverability |

## Recommendations

### Implementation Order

1. **Phase 1: Create boneyard content** (30 min)
   - Create `/home/benjamin/Projects/Logos/Theory/docs/boneyard/proofchecker-logos-content.md`
   - Move Logos architecture diagram and layer descriptions
   - Move Application Domains section
   - Move RL Training section
   - Move Motivations section

2. **Phase 2: Rewrite root README.md** (60 min)
   - New title and opening
   - Brief Logos connection section
   - Focus on Bimodal implementation
   - Update all internal links

3. **Phase 3: Update docs/ files** (45 min)
   - docs/README.md
   - docs/research/bimodal-logic.md
   - docs/research/README.md
   - docs/user-guide/README.md
   - docs/reference/README.md
   - docs/project-info/README.md

4. **Phase 4: Update Theories/README.md** (15 min)
   - Remove Logos Theory section
   - Focus on Bimodal as the primary theory

5. **Phase 5: Verify and test** (30 min)
   - Check all internal links work
   - Verify no broken references remain
   - Run any documentation tests

## Appendix

### Search Queries Used
- `Glob **/*.md` - Find all markdown files
- `Grep "Logos"` - Find Logos references
- `Grep "Theories/Logos"` - Find Logos path references
- `Grep "Logos/docs"` - Find Logos documentation references

### Key Files Examined
- `/home/benjamin/Projects/ProofChecker/README.md`
- `/home/benjamin/Projects/ProofChecker/docs/README.md`
- `/home/benjamin/Projects/ProofChecker/Theories/README.md`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/README.md`
- `/home/benjamin/Projects/ProofChecker/docs/research/bimodal-logic.md`
- `/home/benjamin/Projects/ProofChecker/docs/project-info/IMPLEMENTATION_STATUS.md`

### External Resources Fetched
- https://logos-labs.ai/ - Logos description
- https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf - Paper (PDF, text not extractable)

### Boneyard Location Verified
- `/home/benjamin/Projects/Logos/Theory/docs/boneyard/` exists with empty README.md
