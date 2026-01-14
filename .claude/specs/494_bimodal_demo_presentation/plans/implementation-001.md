# Implementation Plan: Task #494

- **Task**: 494 - bimodal_demo_presentation
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/494_bimodal_demo_presentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Create a comprehensive demo presentation file (`Demo.lean`) for the Bimodal theory showcasing the fully proven soundness, deduction theorem, weak completeness, and decidability results. The demo will be structured as a layered tour with concrete examples using meaningful atom names, interactive decision procedure demonstrations, and the elegant P1-P6 perpetuity principles as highlights.

### Research Integration

Research report (research-001.md) identified:
- Complete Bimodal directory structure with proven metalogical results
- Six perpetuity principles (P1-P6) all fully proven - excellent demo material
- Decision procedure returning valid/invalid/timeout with proof/countermodel extraction
- Recommended layered demo format: Quick Tour, Interactive Exploration, Decision Procedure, Applications

## Goals & Non-Goals

**Goals**:
- Create `Theories/Bimodal/Examples/Demo.lean` with curated examples
- Demonstrate all major results: soundness, deduction, completeness, decidability
- Include `#eval` demonstrations for interactive decision procedure
- Use meaningful atom names (conservation_of_energy, lunar_eclipse, etc.) for pedagogical clarity
- Provide step-by-step proof construction examples

**Non-Goals**:
- Creating LaTeX slides (separate task if needed)
- Fixing remaining bridge lemma sorries (covered by task 488)
- Adding Paperproof visualization (requires external tooling)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import dependencies missing | Medium | Low | Verify imports compile first |
| `#eval` decision procedure slow | Medium | Medium | Use small example formulas, provide fallback static examples |
| Notation conflicts | Low | Low | Use explicit fully-qualified names where needed |

## Implementation Phases

### Phase 1: Demo File Setup and Quick Tour [NOT STARTED]

**Goal**: Create Demo.lean with proper imports and a quick tour section showcasing 5-8 key theorems

**Tasks**:
- [ ] Create `Theories/Bimodal/Examples/Demo.lean` with module header and imports
- [ ] Add Section 1: Quick Tour with curated theorem references
- [ ] Include soundness, deduction theorem, completeness, decidability highlights
- [ ] Add meaningful examples using perpetuity principles P1-P6
- [ ] Verify file compiles with no errors

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Examples/Demo.lean` - Main demo presentation file

**Verification**:
- File compiles with `lake build Theories.Bimodal.Examples.Demo`
- All referenced theorems resolve correctly

---

### Phase 2: Interactive Exploration Section [NOT STARTED]

**Goal**: Add step-by-step proof construction examples showing derivation tree building

**Tasks**:
- [ ] Add Section 2: Interactive Exploration
- [ ] Create worked example showing axiom application step-by-step
- [ ] Demonstrate modus ponens and necessitation rules
- [ ] Show proof of a simple theorem with intermediate goals annotated
- [ ] Include comments explaining each proof step

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Examples/Demo.lean` - Add interactive exploration section

**Verification**:
- All proofs compile and type-check
- Comments clearly explain each step

---

### Phase 3: Decision Procedure Demonstrations [NOT STARTED]

**Goal**: Add live demonstrations of the decide function with both valid and invalid formulas

**Tasks**:
- [ ] Add Section 3: Decision Procedure
- [ ] Create `#eval` examples for known valid formulas (Modal T, K distribution)
- [ ] Create `#eval` examples for known invalid formulas
- [ ] Demonstrate proof extraction from valid results
- [ ] Demonstrate countermodel extraction from invalid results
- [ ] Add timeout handling example

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Examples/Demo.lean` - Add decision procedure section

**Verification**:
- `#eval` commands produce expected results
- Valid formulas return proofs
- Invalid formulas return countermodels

---

### Phase 4: Applications and Polish [NOT STARTED]

**Goal**: Add concrete applications with meaningful names and final polish

**Tasks**:
- [ ] Add Section 4: Applications
- [ ] Create examples using concrete atom names (conservation laws, physical phenomena)
- [ ] Add philosophical/scientific interpretations in comments
- [ ] Include "puzzle" examples for audience participation
- [ ] Add module documentation header explaining demo purpose
- [ ] Final review and cleanup

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Examples/Demo.lean` - Add applications and polish

**Verification**:
- All examples compile correctly
- Documentation is clear and complete
- Demo file is presentation-ready

---

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Examples.Demo` completes without errors
- [ ] All `#check` statements show expected types
- [ ] All `#eval` statements produce expected output
- [ ] Demo can be walked through in ~30-45 minutes presentation time
- [ ] No new sorries introduced

## Artifacts & Outputs

- `Theories/Bimodal/Examples/Demo.lean` - Main demo presentation file
- `.claude/specs/494_bimodal_demo_presentation/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If implementation fails:
1. Demo.lean can be reverted via git
2. Existing Examples/ files remain unmodified
3. No changes to core Bimodal theory files
