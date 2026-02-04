# Implementation Summary: Task #859

**Completed**: 2026-02-04
**Duration**: ~30 minutes

## Changes Made

Expanded sorry-debt-policy.md into a comprehensive proof-debt-policy.md covering both sorries and axioms as forms of mathematical debt. Added Axiom Characterization sections to plan-format.md and report-format.md with framing rules parallel to the existing Sorry Characterization sections. Updated all active cross-references to use the new filename.

## Files Modified

### New/Renamed Files
- `.claude/context/project/lean4/standards/proof-debt-policy.md` - Renamed from sorry-debt-policy.md and expanded with:
  - Unified "proof debt" philosophy covering both sorries and axioms
  - New "Characterizing Axioms in Reports and Plans" section (parallel to sorries)
  - New "Axiom Categories" taxonomy (4 categories parallel to sorry categories)
  - Updated "Discovery Protocol" covering both sorries and axioms
  - Updated "Metrics Integration" documenting both sorry_count and axiom_count
  - Updated "Usage Checklist" covering both

### Format Files Updated
- `.claude/context/core/formats/plan-format.md` - Added "Axiom Characterization (Lean plans only)" section with:
  - Applicability, Purpose, Required Elements
  - Framing Rules (prohibited and required phrases)
  - Example showing proper axiom characterization

- `.claude/context/core/formats/report-format.md` - Added "Axiom Characterization (Lean reports only)" section with:
  - Applicability, Purpose, Required Elements
  - Framing Rules (prohibited and required phrases)
  - Example showing proper axiom characterization

### Cross-Reference Updates
- `.claude/rules/lean4.md` - Updated reference from sorry-debt-policy.md to proof-debt-policy.md
- `.claude/agents/lean-research-agent.md` - Updated 2 references to proof-debt-policy.md
- `.claude/agents/lean-implementation-agent.md` - Updated 2 references to proof-debt-policy.md
- `specs/ROAD_MAP.md` - Updated reference with new path and description
- `specs/856_implement_multifamily_saturated_bmcs/reports/research-003.md` - Updated policy reference
- `specs/856_implement_multifamily_saturated_bmcs/reports/research-004.md` - Updated policy reference

## Verification

- proof-debt-policy.md exists at new location (13,309 bytes)
- sorry-debt-policy.md has been removed
- plan-format.md contains new Axiom Characterization section
- report-format.md contains new Axiom Characterization section
- All active .claude/ files updated to reference new filename
- Archived files preserved with historical references (intentional)
- Framing rules consistent across all three files:
  - Prohibited: "acceptable axiom", "axiom-based solution", "add axiom to solve", "N acceptable axioms"
  - Required: "axiom as technical debt", "structural proof eliminates axiom", "inherits axiom dependency", "zero-axiom target"

## Notes

- Archived task files (specs/archive/) retain historical references to sorry-debt-policy.md intentionally
- Task descriptions in state.json and TODO.md for task 859 retain the historical reference as it describes what the task accomplished
- The new policy maintains full backward compatibility for sorry handling while adding parallel axiom guidance
