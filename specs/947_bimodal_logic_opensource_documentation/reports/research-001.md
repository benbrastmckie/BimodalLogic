# Research Report: Task #947

**Task**: 947 - bimodal_logic_opensource_documentation
**Started**: 2026-02-27T00:00:00Z
**Completed**: 2026-02-27T00:30:00Z
**Effort**: Medium (documentation restructuring)
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, web search for licensing best practices
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Bimodal logic is already a complete, standalone implementation ready for opensource presentation as the foundational core under GPL-3.0
- Logos currently exists only as a thin wrapper importing Bimodal; the Logos-specific extensions (hyperintensional semantics, layered operators) are planned but not yet implemented
- Documentation restructuring should position Bimodal as the primary opensource product with Logos as the private research extension
- The open-core model with GPL-3.0 dual licensing is an established, proven approach for this architecture

## Context and Scope

This research analyzes the current codebase and documentation structure to determine how to present bimodal logic as the opensource foundational core (GNU GPL-3.0 license) while positioning Logos as a private extension that elaborates with additional operators.

### Research Questions

1. What is the current documentation structure?
2. What constitutes "bimodal logic" vs "Logos" in the codebase?
3. How should the README and documentation be restructured?
4. What are best practices for GPL dual licensing with opensource core?

## Findings

### 1. Current Documentation Structure

**README.md Analysis**:
- Currently titled "Logos: A Logic for Interpreted and Verified AI Reasoning"
- Bimodal is introduced in paragraph 2 as "a fragment of independent interest"
- Bimodal has its own detailed section (#bimodal-theory) at lines 170-183
- The layered architecture diagram (lines 17-50) describes Logos extensions that do not exist in the codebase
- License section (line 332-334) states GPL-3.0

**Key Documentation Files**:
| File | Current Focus | Needed Change |
|------|--------------|---------------|
| `README.md` | Logos-centric | Bimodal-centric |
| `docs/research/bimodal-logic.md` | Comparison document | Promote to primary reference |
| `Theories/Bimodal/README.md` | Complete, standalone | Could become project root |
| `docs/project-info/IMPLEMENTATION_STATUS.md` | Titled "Logos MVP" | Rename to Bimodal |
| `docs/development/CONTRIBUTING.md` | References "Logos" | Update to Bimodal |

### 2. Bimodal Logic Core Components

**Bimodal is fully implemented and ready for opensource**:

| Component | Status | Description |
|-----------|--------|-------------|
| `Theories/Bimodal/Syntax/` | Complete | Formula types, context, derived operators |
| `Theories/Bimodal/ProofSystem/` | Complete | 14 axiom schemata, 7 inference rules |
| `Theories/Bimodal/Semantics/` | Complete | TaskFrame, WorldHistory, TaskModel, Truth |
| `Theories/Bimodal/Metalogic/` | Complete | Soundness, Completeness, Deduction, Decidability |
| `Theories/Bimodal/Theorems/` | Complete | P1-P6 perpetuity principles, Modal S4/S5 |
| `Theories/Bimodal/Automation/` | Partial | Tactics, AesopRules, ProofSearch |
| `Theories/Bimodal/Examples/` | Complete | Demo, proof strategies |

**Bimodal Operators** (foundational, opensource):
- Boolean: `not`, `and`, `or`, `implies`, `iff`, `bottom`, `top`
- Modal S5: `box` (necessity), `diamond` (possibility)
- Temporal: `H` (always past), `G` (always future), `P` (sometime past), `F` (sometime future)
- Derived: `triangle` (always/perpetual), `nabla` (sometimes)

### 3. Logos Extensions (Private, Not Yet Implemented)

**Current Logos Implementation** (`Theories/Logos.lean`):
```lean
-- Re-export public API (Bimodal library is now the core implementation)
import Bimodal
```

Logos is currently just a namespace wrapper. The planned extensions do NOT exist in code:

| Planned Extension | Status | Would Add |
|------------------|--------|-----------|
| Constitutive Foundation | NOT IMPLEMENTED | Grounding, essence, propositional identity |
| Dynamical Foundation | NOT IMPLEMENTED | Counterfactuals, causal operators |
| Epistemic Extension | NOT IMPLEMENTED | Belief, knowledge, probability |
| Abilities Extension | NOT IMPLEMENTED | Can, STIT operators |
| Normative Extension | NOT IMPLEMENTED | Obligation, permission, preference |
| Choice Extension | NOT IMPLEMENTED | Free choice, best choice |
| Spatial Extension | NOT IMPLEMENTED | Location, spatial relations |
| Agential Extension | NOT IMPLEMENTED | Agent-indexed operators |
| Social Extension | NOT IMPLEMENTED | Common ground, group reasoning |
| Reflection Extension | NOT IMPLEMENTED | Metacognition, I operator |

**Implication**: The README describes a vision, not the current state. The documentation should focus on what EXISTS (Bimodal) as opensource.

### 4. License and Dual Licensing Considerations

**Current License** (`LICENSE`):
- GNU General Public License v3.0
- Copyright 2025 Benjamin Brast-McKie
- Full GPL-3.0 text referenced

**Open-Core Model Best Practices** (from web research):

1. **Core Completeness**: The opensource core (Bimodal) should be genuinely useful standalone. This is satisfied - Bimodal is complete with soundness, completeness, decidability.

2. **Clear Separation**: Commercial/private value (Logos extensions) should come from advanced features, not crippling the core.

3. **GPL Benefits**:
   - Competitors cannot embed without contributing back
   - Creates conversation opportunity with commercial users
   - Code remains free for research and community use

4. **Dual Licensing Option**: Copyright holder can offer alternative licensing to commercial entities wanting proprietary integration.

**No License File Changes Needed**: GPL-3.0 is already appropriate for the opensource core.

### 5. Recommended Documentation Structure

**Proposed README.md Restructure**:

```markdown
# Bimodal: A Complete Logic for Tense and Modality

**Bimodal** is a formal verification framework in Lean 4 implementing
a complete propositional bimodal logic combining S5 modal and linear
temporal operators. The library provides...

## Quick Start
...

## Features
- Complete propositional bimodal logic
- S5 modal operators (necessity, possibility)
- Linear temporal operators (past, future)
- Task frame semantics
- Proven soundness and completeness
- Decidability procedure

## Related Projects
- **Logos** (private): Hyperintensional extensions with layered operators
  for explanatory, epistemic, and normative reasoning
```

**Key Changes**:

1. **Title**: Change from "Logos" to "Bimodal"
2. **Opening Paragraph**: Lead with Bimodal as complete, standalone
3. **Architecture Diagram**: Remove or move Logos layers to separate doc
4. **Logos Section**: Brief mention as private extension, not detailed roadmap
5. **Demo/Specs**: Point to Bimodal artifacts (already exists)
6. **Remove**: Detailed Logos extension descriptions that don't exist in code

### 6. Files Requiring Revision

**Priority 1 (Core)**:
1. `README.md` - Complete restructure
2. `docs/development/CONTRIBUTING.md` - Replace "Logos" references
3. `docs/project-info/IMPLEMENTATION_STATUS.md` - Rename from "Logos MVP"

**Priority 2 (Secondary)**:
4. `Theories/README.md` - Update structure description
5. `docs/README.md` - Documentation hub alignment
6. `docs/research/bimodal-logic.md` - Keep as comparison, reference from README

**Priority 3 (Minor)**:
7. Various `*.md` files with "Logos" in text
8. `CITATION.cff` if it exists
9. GitHub repository description

## Decisions

1. **Bimodal is the product name for opensource**: The project should be presented as "Bimodal" for opensource, with "Logos" mentioned as a private research direction
2. **Remove unimplemented features from main documentation**: The layered extension architecture should not be prominently featured until implemented
3. **Keep GPL-3.0**: License is appropriate for open-core model
4. **Separate documentation concerns**: Bimodal has its own complete README; project-level docs should align

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Confusion between Bimodal/Logos naming | Medium | Medium | Clear documentation separation |
| Loss of vision communication | Low | Medium | Keep Logos roadmap in research docs |
| Contributor confusion on where to contribute | Medium | Low | CONTRIBUTING.md clarity |
| Breaking external links | Low | Low | Redirects/references |

## Appendix

### Search Queries Used

- Web search: "GPL-3.0 dual licensing opensource core private extensions best practices"
- Codebase search: `Glob **/*.lean`, `Grep "Logos"`, `Grep "Bimodal"`

### Key Documentation References

- `README.md` - Current project introduction
- `Theories/Bimodal/README.md` - Complete Bimodal documentation
- `docs/research/bimodal-logic.md` - Bimodal vs Logos comparison
- `docs/project-info/IMPLEMENTATION_STATUS.md` - Current implementation state
- `LICENSE` - GPL-3.0 license text

### External Sources

- [GNU GPL v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)
- [Open Core with GPL Dual Licensing](https://www.linkedin.com/pulse/why-open-core-gpl-dual-licensing-model-works-mark-curphey)
- [GPL FAQ](https://www.gnu.org/licenses/gpl-faq.en.html)
