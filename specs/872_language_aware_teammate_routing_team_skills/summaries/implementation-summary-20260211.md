# Implementation Summary: Task #872

**Completed**: 2026-02-11
**Duration**: ~45 minutes

## Changes Made

Added language-aware teammate routing to all three team skills (skill-team-research, skill-team-plan, skill-team-implement). For Lean tasks, teammates are now spawned with Lean-specific prompts that include:
- lean-lsp MCP tool instructions and usage guidelines
- Blocked tools warnings (lean_diagnostic_messages, lean_file_outline)
- Context references (tactic-patterns.md, proof-debt-policy.md)
- Lean-specific workflow guidance (use lean_goal constantly, run lake build)

## Files Modified

- `.claude/utils/team-wave-helpers.md` - Added Language Routing Pattern section with:
  - Language routing lookup table (lean, latex, typst, general, meta)
  - Lean teammate prompt templates for research, implementation, debugging, and planning
  - Context references, blocked tools, and available tools per language

- `.claude/skills/skill-team-research/SKILL.md` - Added:
  - Language routing note in header/description
  - Stage 5a: Language Routing Decision (before teammate spawning)
  - Lean-specific teammate prompts with MCP tools and blocked tool warnings
  - Preserved generic prompts for non-Lean tasks

- `.claude/skills/skill-team-implement/SKILL.md` - Added:
  - Language routing note in header/description
  - Stage 5a: Language Routing Decision
  - Lean-specific phase implementer prompts with lean_goal workflow
  - Lean-specific debugger prompts with MCP tool access
  - lake build verification requirements for Lean
  - Preserved generic prompts for non-Lean tasks

- `.claude/skills/skill-team-plan/SKILL.md` - Added:
  - Language routing note in header/description
  - Stage 5a: Language Routing Decision
  - Lean-specific planner prompts with proof milestone guidance
  - tactic-patterns.md context references
  - lake build verification requirements
  - Preserved generic prompts for non-Lean tasks

- `.claude/CLAUDE.md` - Added:
  - Team Skill Language Routing note under Skill-to-Agent Mapping section

## Verification

- All skill files modified successfully
- Header descriptions updated to reflect language routing
- Lean teammate prompts include all required elements:
  - MCP tools list
  - Blocked tools warning
  - Context references
  - Verification requirements (lake build)
- Non-Lean task prompts unchanged from prior behavior

## Notes

The implementation follows the existing conditional routing pattern used in single-agent skills. Key design decisions:
1. Routing happens at Stage 5a (after team mode check, before spawning)
2. Lean prompts include full MCP tool list and blocked tools inline to ensure teammates have context
3. Generic prompts preserved unchanged to avoid regression
4. Helper patterns centralized in team-wave-helpers.md for reuse

Future enhancements could add similar routing for latex/typst languages if specialized teammate prompts become needed.
