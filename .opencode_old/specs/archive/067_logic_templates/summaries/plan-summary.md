# Plan Summary: Populate context/logic/templates/ Directory

**Version**: 001  
**Complexity**: Moderate  
**Estimated Effort**: 4-6 hours (255-360 minutes)

---

## Key Steps

1. **Phase 1: Modal Operator Template** (60-90 min)
   - Create modal-operator-template.md with 9 sections
   - Extract patterns from Formula.lean (primitives, derived, duality, complexity)
   - Include 3+ concrete examples
   - Add cross-references to 6 related files

2. **Phase 2: Kripke Model Template** (60-90 min)
   - Create kripke-model-template.md with 10 sections
   - Extract patterns from TaskFrame.lean, TaskModel.lean, WorldHistory.lean
   - Document polymorphic temporal types and constraints
   - Include 4+ concrete examples (frame, model, history, example frames)

3. **Phase 3: Soundness Template** (45-60 min)
   - Create soundness-template.md with 9 sections
   - Document three-stage proof structure (axiom validity → master → main)
   - Extract proof techniques by axiom category
   - Include 3+ complete proof examples

4. **Phase 4: Completeness Template** (60-75 min)
   - Create completeness-template.md with 12 sections
   - Document canonical model construction approach
   - Extract truth lemma inductive structure
   - Include proof obligation checklist and complexity estimation

5. **Phase 5: Integration & Verification** (30-45 min)
   - Create README.md with template index
   - Validate all cross-references (40-50 links)
   - Check standards compliance
   - Test template usability

---

## Dependencies

**Completed Prerequisites**:
- Research report (research-001.md) - Pattern analysis complete
- Logos codebase - All source files available
- Existing context files - Templates, standards, processes exist

**Required Files** (Read Access):
- Research: `.opencode/specs/067_logic_templates/reports/research-001.md`
- Logos: Formula.lean, TaskFrame.lean, TaskModel.lean, WorldHistory.lean, Soundness.lean, Completeness.lean
- Context: definition-template.md, documentation-standards.md, modal-proof-strategies.md

**Template Dependencies**:
```
modal-operator → kripke-model → soundness → completeness
```

---

## Success Criteria

**Files Created** (5):
- modal-operator-template.md (~450 lines)
- kripke-model-template.md (~550 lines)
- soundness-template.md (~500 lines)
- completeness-template.md (~600 lines)
- README.md (~175 lines)

**Quality Metrics**:
- 100% of code examples compile (verified from source)
- 100% of cross-references valid (40-50 links)
- 100% standards compliance
- 15-20 concrete examples from Logos codebase
- All templates pass usability test

**Validation**:
- All sections complete (no TODOs or placeholders)
- Consistent formatting across templates
- Clear navigation between templates
- Integration with existing context files

---

## Full Plan

See: `.opencode/specs/067_logic_templates/plans/implementation-001.md`

**Plan Size**: ~1,200 lines  
**Sections**: 15 major sections  
**Appendices**: 4 (Research Summary, Cross-Reference Map, Quality Checklist, Example Code)
